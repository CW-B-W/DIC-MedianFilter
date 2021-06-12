#include <iostream>
#include <cstdint>
#include <cstring>
#include <algorithm>

using namespace std;

uint8_t img[128][128];
uint8_t mem[128][128];
uint8_t god[128][128];

void median_filter()
{
    for (int y_center = 0; y_center < 128; ++y_center) {
        int mat_rd_idx = 0;
        uint8_t mat[9];
        for (int x_center = 0; x_center < 128; ++x_center) {
            /* Read matrix */
            for (; mat_rd_idx < 9; ++mat_rd_idx) {
                int dx = mat_rd_idx / 3 - 1;
                int dy = mat_rd_idx % 3 - 1; 
                memmove(mat, mat+1, sizeof(uint8_t)*8);
                int x = x_center + dx;
                int y = y_center + dy;
                if (x < 0 || x >= 128 || y < 0 || y >= 128)
                    mat[8] = 0;
                else
                    mat[8] = img[y][x];
            }

            /* Sort */
            uint8_t mat_sort[9];
            memcpy(mat_sort, mat, sizeof(uint8_t)*9);
            sort(mat_sort, mat_sort+9);

            /* Write back */
            int median = mat_sort[4];
            mem[y_center][x_center] = median;
            mat_rd_idx = 0;
        }
    }
}

void readfiles()
{
    FILE* rf = NULL;
    rf = fopen("./img.dat", "r");
    assert(rf != NULL);
    for (int i = 0; i < 128; ++i) {
        for (int j = 0; j < 128; ++j) {
            fscanf(rf, "%hx", &img[i][j]);
        }
    }
    fclose(rf);

    rf = fopen("./golden.dat", "r");
    assert(rf != NULL);
    for (int i = 0; i < 128; ++i) {
        for (int j = 0; j < 128; ++j) {
            fscanf(rf, "%hx", &god[i][j]);
        }
    }
    fclose(rf);
}

void verify()
{
    int errcnt = 0;
    for (int i = 0; i < 128; ++i) {
        for (int j = 0; j < 128; ++j) {
            if (mem[i][j] != god[i][j]) {
                cout << "at " << i << ' ' << j << ": ";
                cout << "expected " << (int)god[i][j] << ", but get " << (int)mem[i][j] << endl;
                errcnt++;
            }
        }
    }
    if (errcnt)
        cout << "Total errors: " << errcnt << endl;
    else
        cout << "All correct" << endl;
}

int main()
{
    readfiles();
    median_filter();
    verify();
    return 0;
}