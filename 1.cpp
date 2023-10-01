#include <iostream>
#include <stack>
using namespace std;

int chessboard[12][12] = {0};

struct Move {
    int x, y;
};

int cnt = 0;
int sum = 0;
int step[8][2] = {{2, 1},   {1, 2},   {-1, 2}, {-2, 1},
                  {-2, -1}, {-1, -2}, {1, -2}, {2, -1}};

void PrintChess();
void Horse(int x,int y);

int main() {
    int i, j;
    for (i = 0; i < 12; i++) {
        for (j = 0; j < 12; j++) {
            if (i == 0 || i == 1 || i == 10 || i == 11 || j == 0 || j == 1 ||
                j == 10 || j == 11) {
                chessboard[i][j] = -1;
            }
        }
    }

    chessboard[2][2] = ++cnt;
    cout << "请输入初始位置" << endl;
    int x, y;
    cin >> x;
    cin >> y;
    Horse(x+2,y+2);
    return 0;
}

void Horse(int x,int y) {
    stack<Move> moveStack;
    Move initialMove = {x, y};
    moveStack.push(initialMove);
    while (!moveStack.empty()) {
        Move currentMove = moveStack.top();
        moveStack.pop();
        int x = currentMove.x;
        int y = currentMove.y;
        if (cnt >= 64) {
            sum++;
            cnt--; 
            PrintChess();
            continue;
        }

        for (int i = 0; i < 8; i++) {
            int a = x + step[i][0];
            int b = y + step[i][1];
            if (chessboard[a][b] == 0) {
                cnt++;
                chessboard[a][b] = cnt;
                Move nextMove = {a, b};
                moveStack.push(nextMove);
            }
        }
    }
}

void PrintChess() {
    cout << "马踏棋盘第 " << sum << "组解为:" << endl;
    int i, j;
    for (i = 2; i < 10; i++) {
        for (j = 2; j < 10; j++) {
            cout << " " << chessboard[i][j];
        }
        cout << endl;
    }
}
