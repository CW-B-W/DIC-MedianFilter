#include <iostream>
#include <cassert>
#include <algorithm>
#include <cstdlib>
#include <cstring>

using namespace std;

void bitonic_sort(int* begin, int* end)
{
    int N = end - begin;
    /* assert (end-begin) is 2^exp */
    assert((N != 0) && (N & (N - 1)) == 0);

    /* iteratively merge every two consecutive size = g_size Bitonic sequences */
    for (int g_size = 1; g_size < N; g_size <<= 1) {
        int n_group = N / g_size;
        /* merge consecutive Bitonic sequences */
        for (int gid = 0; gid < n_group; gid += 2) {
            bool inc = !(gid/2 & 1); /* indicates the merged array is sorted in increasing or not */
            int* g = begin + gid * g_size; /* g is the merged array */

            /* merging the two Bitonic sequences */
            for (int sg_size = g_size; sg_size >= 1; sg_size >>= 1) {
                int n_sgroup = 2*g_size / sg_size;
                /* sorting two consecutive subgroups */
                for (int sgid = 0; sgid < n_sgroup; sgid += 2) {
                    int* sg0 = g + sgid * sg_size;
                    int* sg1 = g + sgid * sg_size + sg_size;
                    for (int i = 0; i < sg_size; ++i) {
                        if ((sg0[i] > sg1[i]) == inc) {
                            swap(sg0[i], sg1[i]);
                        }
                    }
                }
            }
        }
    }
}

int main() {
    int n;
    for (int n = 4; n <= (1<<16); n *= 2) {
        int* a = new int[n];
        for (int i = 0; i < n; ++i) {
            a[i] = rand();
        }
        int* a_std = new int[n];
        int* a_bit = new int[n];
        memcpy(a_std, a, sizeof(int)*n);
        memcpy(a_bit, a, sizeof(int)*n);
        sort(a_std, a_std+n);
        bitonic_sort(a_bit, a_bit+n);
        for (int i = 0; i < n; ++i) {
            assert(a_std[i] == a_bit[i]);
        }
        delete[] a;
        delete[] a_std;
        delete[] a_bit;
    }
    return 0;
}