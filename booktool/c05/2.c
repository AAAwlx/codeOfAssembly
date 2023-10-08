#include <stdio.h>
#include <stdlib.h>

#define N 12

int chessboard[N][N] = {0};
int cnt = 0;
int sum = 0;
int step[8][2] = {{2, 1},   {1, 2},   {-1, 2}, {-2, 1},
                  {-2, -1}, {-1, -2}, {1, -2}, {2, -1}};

typedef struct {
    int x;
    int y;
    int next_step;
} StackNode;

StackNode stack[N * N]; // Use a stack to mimic recursion
int top = -1;

void Push(int x, int y, int next_step) {
    top++;
    stack[top].x = x;
    stack[top].y = y;
    stack[top].next_step = next_step;
}

void Pop() {
    top--;
}

int IsEmpty() {
    return top == -1;
}

void PrintChess() {
    printf("马踏棋盘的结果为：\n");
    for (int i = 2; i < 10; i++) {
        for (int j = 2; j < 10; j++) {
            printf("%2d ", chessboard[i][j]);
        }
        printf("\n");
    }
}

int IsValidMove(int x, int y) {
    return (x >= 2 && x <= 9 && y >= 2 && y <= 9 && chessboard[x][y] == 0);
}

void Horse() {
    int x = 2, y = 2;

    chessboard[x][y] = ++cnt;
    Push(x, y, 0);

    while (!IsEmpty()) {
        if (cnt >= 64) {
            sum++;
            PrintChess();
            cnt--;
            Pop();
        } else {
            int current_x = stack[top].x;
            int current_y = stack[top].y;
            int next_step = stack[top].next_step;

            if (next_step < 8) {
                int new_x = current_x + step[next_step][0];
                int new_y = current_y + step[next_step][1];

                if (IsValidMove(new_x, new_y)) {
                    cnt++;
                    chessboard[new_x][new_y] = cnt;
                    Push(new_x, new_y, 0);
                } else {
                    stack[top].next_step++; // Try the next possible move
                }
            } else {
                // No more valid moves from this position, backtrack
                chessboard[current_x][current_y] = 0;
                cnt--;
                Pop();
            }
        }
    }
}

int main(void) {
    int i, j,x,y;
    printf("请输入初始位置\n");
   
    while (1)
    {
        if (x<0||y<0||x>8||y>8)
        {    scanf("%d %d", &x, &y);
            printf("您输入的位置不符合规范请再试一次\n");
        }else{
            break;
        }
    }
    
   
    
    for (i = 0; i < N; i++) {
        for (j = 0; j < N; j++) {
            if (i == 0 || i == 1 || i == 10 || i == 11 || j == 0 || j == 1 ||
                j == 10 || j == 11) {
                chessboard[i][j] = -1;
            }
        }
    }

    Horse();
    return 0;
}
