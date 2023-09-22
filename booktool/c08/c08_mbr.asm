         ;代码清单8-1
         ;文件名：c08_mbr.asm
         ;文件说明：硬盘主引导扇区代码（加载程序） 
         ;创建日期：2011-5-5 18:17
         
         app_lba_start equ 100           ;声明常数（用户程序起始逻辑扇区号）
                                         ;常数的声明不会占用汇编地址
                                    
SECTION mbr align=16 vstart=0x7c00;标记程序起始地址，在计算物理内存的时候都会按照+7c00计算                                     

         ;设置堆栈段和栈指针 
         mov ax,0      
         mov ss,ax
         mov sp,ax
      
         mov ax,[cs:phy_base]            ;计算用于加载用户程序的逻辑段地址 
         mov dx,[cs:phy_base+0x02]
         mov bx,16   ;十六字节对齐，除十六即为右移四位     
         div bx            
         mov ds,ax                       ;令DS和ES指向该段以进行操作
         mov es,ax                        ;初始化段寄存器
    
         ;以下读取程序的起始部分 
         xor di,di
         mov si,app_lba_start            ;程序在硬盘上的起始逻辑扇区号 
         xor bx,bx                       ;加载到DS:0x0000处 
         call read_hard_disk_0
      
         ;以下判断整个程序有多大
         mov dx,[2]                      ;将用户程序的大小放入dx与ax中，程序头部的即为用户程序大小
         mov ax,[0]
         mov bx,512                      ;512字节每扇区
         div bx                          ;除512,若有余数说明需要回填不是整数，ax中的结果则表示需要的扇区
         cmp dx,0
         jnz @1                          ;未除尽，因此结果比实际扇区数少1 
         dec ax                          ;已经读了一个扇区，扇区总数减1 
   @1:
         cmp ax,0                        ;考虑实际长度小于等于512个字节的情况 
         jz direct
         
         ;读取剩余的扇区
         push ds                         ;以下要用到并改变DS寄存器 

         mov cx,ax                       ;循环次数（剩余扇区数）
   @2:
         mov ax,ds
         add ax,0x20                     ;得到下一个以512字节为边界的段地址
         mov ds,ax                       ;防止地址回绕，每读一个扇区逻辑地址加0x20,对应物理地址为0x200
                              
         xor bx,bx                       ;每次读时，偏移地址始终为0x0000 
         inc si                          ;下一个逻辑扇区 
         call read_hard_disk_0
         loop @2                         ;循环读，直到读完整个功能程序 

         pop ds                          ;恢复数据段基址到用户程序头部段 
      
         ;计算入口点代码段基址 
   direct:
         mov dx,[0x08]
         mov ax,[0x06]
         call calc_segment_base
         mov [0x06],ax                   ;回填修正后的入口点代码段基址 
      
         ;开始处理段重定位表
         mov cx,[0x0a]                   ;需要重定位的项目数量
         mov bx,0x0c                     ;重定位表首地址
          
 realloc:
         mov dx,[bx+0x02]                ;32位地址的高16位 
         mov ax,[bx]
         call calc_segment_base
         mov [bx],ax                     ;回填段的基址
         add bx,4                        ;下一个重定位项（每项占4个字节） 
         loop realloc 
      
         jmp far [0x04]                  ;转移到用户程序  
 
;-------------------------------------------------------------------------------
read_hard_disk_0:                        ;从硬盘读取一个逻辑扇区
                                         ;输入：DI:SI=起始逻辑扇区号
                                         ;      DS:BX=目标缓冲区地址
         push ax
         push bx
         push cx
         push dx
      
         mov dx,0x1f2
         mov al,1
         out dx,al                       ;读取的扇区数

         inc dx                          ;0x1f3
         mov ax,si
         out dx,al                       ;LBA地址7~0

         inc dx                          ;0x1f4
         mov al,ah
         out dx,al                       ;LBA地址15~8

         inc dx                          ;0x1f5
         mov ax,di
         out dx,al                       ;LBA地址23~16
                                
         inc dx 
         inc dx                          ;0x1f7
         mov al,0x20                     ;读命令
         out dx,al;将端口0x1f7输出到al中

  .waits:
         in al,dx
         and al,0x88;与操作，除了第7位和第3位全部清零
         cmp al,0x08;比较是否只有第三位为一
         jnz .waits ;若只有第三位为一，则表明不忙，且硬盘已准备好数据传输 
         mov cx,256                      ;总共要读取的字数
         mov dx,0x1f0
  .readw:
         in ax,dx
         mov [bx],ax
         add bx,2
         loop .readw

         pop dx
         pop cx
         pop bx
         pop ax
      
         ret

;-------------------------------------------------------------------------------
calc_segment_base:                       ;计算16位段地址
                                         ;输入：DX:AX=32位物理地址
                                         ;返回：AX=16位段基地址 
         push dx                          
         
         add ax,[cs:phy_base]
         adc dx,[cs:phy_base+0x02]
         shr ax,4;右移四位将高四位空出来，将物理地址转换为汇编地址
         ror dx,4;将dx寄存器中的值由低四位移动到高四位。
         and dx,0xf000;使用and指令将低12位清理
         or ax,dx;将dx与ax相加并存入ax
         pop dx
         
         ret

;-------------------------------------------------------------------------------
         phy_base dd 0x10000             ;用户程序被加载的物理起始地址
         
 times 510-($-$$) db 0
                  db 0x55,0xaa