#include <iostream>
#include <cstdio>
#include <vector>
#include <algorithm>
#include <memory>
#include <cassert>

using namespace std;

constexpr int IMG_WIDTH  = 128;
constexpr int IMG_HEIGHT = 128;

vector< vector<int> > median_filter(const vector< vector<int> > &img, int kernel_size = 3)
{
    assert(kernel_size & 1);

    vector< vector<int> > img_filtered(img.size(), vector<int>(img[0].size()));

    int range = kernel_size / 2;
    
    for (int row = 0; row < img.size(); ++row) {
        for (int col = 0; col < img[row].size(); ++col) {
            vector<int> sorted;
            for (int i = -range; i <= range; ++i) {
                for (int j = -range; j <= range; ++j) {
                    int x = row + i;
                    int y = col + j;
                    if (x < 0 || x >= IMG_HEIGHT || y < 0 || y >= IMG_WIDTH) {
                        sorted.emplace_back(0);
                    }
                    else {
                        sorted.emplace_back(img[x][y]);
                    }
                }
            }
            sort(sorted.begin(), sorted.end());
            img_filtered[row][col] = sorted[4];
        }
    }

    return img_filtered;
}

int main()
{
    assert(IMG_WIDTH == IMG_HEIGHT);

    FILE* img_dat = fopen("img.dat", "r");
    vector< vector<int> > img(IMG_HEIGHT, vector<int>(IMG_WIDTH));
    int row = 0;
    int col = 0;
    int in;
    while (fscanf(img_dat, "%x", &in) != EOF) {
        try {
            img.at(row).at(col) = in;
        }
        catch (const out_of_range &oor) {
            fprintf(stderr, "img threw out_of_range exception\n");
            fprintf(stderr, "\tat (%d, %d)\n", row, col);
            exit(1);
        }
        col += 1;
        if (col % IMG_WIDTH == 0) {
            col = 0;
            row += 1;
        }
    }
    fclose(img_dat);

    vector< vector<int> > img_filtered = median_filter(img);
    FILE* golden_dat = fopen("golden_cpp.dat", "w");
    for (int i = 0; i < img_filtered.size(); ++i) {
        for (int j = 0; j < img_filtered[i].size(); ++j) {
            fprintf(golden_dat, "%02x\r\n", img_filtered[i][j]);
        }
    }
    fclose(golden_dat);
    
    return 0;
}
