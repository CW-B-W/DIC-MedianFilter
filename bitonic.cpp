/* Bitonic Sort for 8 elements */
/* https://www.geeksforgeeks.org/bitonic-sort */

#include <iostream>
#include <algorithm>

using namespace std;

void d1(int a[8]) {
    for (int i = 0; i < 8; i += 4) {
        if (a[i] > a[i+1])
            swap(a[i], a[i+1]);
    }
    for (int i = 2; i < 8; i += 4) {
        if (a[i] < a[i+1])
            swap(a[i], a[i+1]);
    }
}

void d2(int a[8]) {
    for (int i = 0; i < 2; i += 1) {
        if (a[i] > a[i+2])
            swap(a[i], a[i+2]);
    }
    for (int i = 4; i < 6; i += 1) {
        if (a[i] < a[i+2])
            swap(a[i], a[i+2]);
    }
}

void d3(int a[8]) {
    for (int i = 0; i < 4; i += 2) {
        if (a[i] > a[i+1])
            swap(a[i], a[i+1]);
    }
    for (int i = 4; i < 8; i += 2) {
        if (a[i] < a[i+1])
            swap(a[i], a[i+1]);
    }
}

void c1(int a[8])
{
    for (int i = 0; i < 4; i += 1) {
        if (a[i] > a[i+4])
            swap(a[i], a[i+4]);
    }
}

void c2(int a[8])
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

void c3(int a[8])
{
    for (int i = 0; i < 8; i += 2) {
        if (a[i] > a[i+1])
            swap(a[i], a[i+1]);
    }
}

int main() {
    int a[8] = {3, 7, 4, 8, 6, 2, 1, 5};
    d1(a);
    d2(a);
    d3(a);
    for (int i : a)
        cout << i << ' ';
    cout << endl;
    
    c1(a);
    c2(a);
    c3(a);
    for (int i : a)
        cout << i << ' ';
    cout << endl;
    return 0;
}