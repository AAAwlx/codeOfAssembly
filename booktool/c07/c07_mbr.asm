         ;代码清单7-1
         ;文件名：c07_mbr.asm
         ;文件说明：硬盘主引导扇区代码
         ;创建日期：2011-4-13 18:02
         
         jmp near start
	
 message db '1+2+3+...+100=';规定字符串内容
        
 start:
         mov ax,0x7c0           ;设置数据段的段基地址 
         mov ds,ax

         mov ax,0xb800          ;设置附加段基址到显示缓冲区
         mov es,ax

         ;以下显示字符串 
         mov si,message     ;start的地址减去massage的地址即为字符串的长度     
         mov di,0
         mov cx,start-message
     @g:
         mov al,[si]
         mov [es:di],al ;将字符串中的内容逐个由数据段寄存器移动到附加段寄存器中，后显示到屏幕
         inc di
         mov byte [es:di],0x07
         inc di ;令di和si自增访问到下一个字符
         inc si
         loop @g

         ;以下计算1到100的和 
         xor ax,ax ;将ax中的值清零
         mov cx,1
     @f:
         add ax,cx;令cx自增并将cx加到ax中
         inc cx
         cmp cx,100;比较cx中的值和100的大小，超过100后跳出循环
         jle @f

         ;以下计算累加和的每个数位 
         xor cx,cx              ;设置堆栈段的段基地址
         mov ss,cx
         mov sp,cx

         mov bx,10
         xor cx,cx
     @d:
         inc cx;记录一共有多少数位
         xor dx,dx
         div bx
         or dl,0x30;dl的前四位为0,～的后四位为0,使用逻辑或做加法，使用add会改变标志标致位的状态
         push dx
         cmp ax,0
         jne @d

         ;以下显示各个数位 
     @a:
         pop dx
         mov [es:di],dl
         inc di
         mov byte [es:di],0x07
         inc di
         loop @a
       
         jmp near $ 
       

times 510-($-$$) db 0
                 db 0x55,0xaa