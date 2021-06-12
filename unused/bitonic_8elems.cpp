/* Bitonic Sort for 8 elements */
/* https://www.geeksforgeeks.org/bitonic-sort */

#include <iostream>
#include <algorithm>

using namespace std;

void p1(int a[8]) {
    for (int i = 0; i < 8; i += 4) {
        if (a[i] > a[i+1])
            swap(a[i], a[i+1]);
    }
    for (int i = 2; i < 8; i += 4) {
        if (a[i] < a[i+1])
            swap(a[i], a[i+1]);
    }
}

void p2(int a[8]) {
    for (int i = 0; i < 2; i += 1) {
        if (a[i] > a[i+2])
            swap(a[i], a[i+2]);
    }
    for (int i = 4; i < 6; i += 1) {
        if (a[i] < a[i+2])
            swap(a[i], a[i+2]);
    }
}

void p3(int a[8]) {
    for (int i = 0; i < 4; i += 2) {
        if (a[i] > a[i+1])
            swap(a[i], a[i+1]);
    }
    for (int i = 4; i < 8; i += 2) {
        if (a[i] < a[i+1])
            swap(a[i], a[i+1]);
    }
}

void p4(int a[8])
{
    for (int i = 0; i < 4; i += 1) {
        if (a[i] > a[i+4])
            swap(a[i], a[i+4]);
    }
}

void p5(int a[8])
{
    for (int i = 0; i < 2; i += 1) {
        if (a[i] > a[i+2])
            swap(a[i], a[i+2]);
    }
    for (int i = 4; i < 6; i += 1) {
        if (a[i] > a[i+2])
            swap(a[i], a[i+2]);
    }
}

void p6(int a[8])
{
    for (int i = 0; i < 8; i += 2) {
        if (a[i] > a[i+1])
            swap(a[i], a[i+1]);
    }
}

int main() {
    int a[8] = {3, 7, 4, 8, 6, 2, 1, 5};
    p1(a);
    p2(a);
    p3(a);
    for (int i : a)
        cout << i << ' ';
    cout << endl;
    
    p4(a);
    p5(a);
    p6(a);
    for (int i : a)
        cout << i << ' ';
    cout << endl;
    return 0;
}