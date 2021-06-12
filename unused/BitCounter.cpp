#include <iostream>
#include <cstdio>
#include <cstdint>
#include <cstdlib>
#include <stdexcept>
#include <random>
#include <algorithm>
#include <tuple>

using namespace std;

class BitCounter
{
    using BlockType = uint64_t;
public:
   /* 
    * Description:
    *       A counter for counting the occurrence of numbers.
    *       Number ranging from 0 to max_num.
    *
    * Parameter:
    *       max_num: The max possible value
    *       max_cnt: The max occurrence of a number
    */
    BitCounter(int max_num, int max_occurrence)
    {
        this->max_num = max_num;
        this->max_occurrence = max_occurrence;

        BlockType high_bit = max_occurrence;
        while (high_bit & (high_bit-1)) {
            high_bit &= (high_bit-1);
        }
        bits_per_num = __builtin_ctzll(high_bit << 1);
        while (bits_per_num & (bits_per_num-1)) {
            bits_per_num &= (bits_per_num-1);
        }
        bits_per_num <<= 1; /* always make bits_per_num be 2's power */
        if (bits_per_num > block_size)
            throw invalid_argument("[BitCounter::BitCounter(int, int)] max_occurrence is too large.");

        block_list.resize(((max_num+1) * bits_per_num + (block_size-1)) / block_size);
    }

    void inc(int num)
    {
        if (num > max_num)
            throw range_error("[BitCounter::inc(int)] num > max_num.");

        tuple<int, int, BlockType> num_info = get_num_info(num);
        int block_idx = get<0>(num_info);
        int offset = get<1>(num_info);
        BlockType cnt = get<2>(num_info);
        cnt += 1;
        if (cnt > max_occurrence)
            throw runtime_error("[BitCounter::inc(int)] count exceeded max_occurrence after increasing.");
        set_count(block_idx, offset, cnt);
    }

    void dec(int num)
    {
        if (num > max_num)
            throw range_error("[BitCounter::dec(int)] num > max_num.");

        tuple<int, int, BlockType> num_info = get_num_info(num);
        int block_idx = get<0>(num_info);
        int offset = get<1>(num_info);
        BlockType cnt = get<2>(num_info);
        cnt -= 1;
        if (cnt < 0)
            throw runtime_error("[BitCounter::dec(int)] count is less than zero after decreasing.");
        set_count(block_idx, offset, cnt);
    }

    void clear_count(int num)
    {
        if (num > max_num)
            throw range_error("[BitCounter::clear_count(int)] num > max_num.");

        tuple<int, int, BlockType> num_info = get_num_info(num);
        int block_idx = get<0>(num_info);
        int offset = get<1>(num_info);
        clear_count(block_idx, offset);
    }

    int get_count(int num)
    {
        return get<2>(get_num_info(num));
    }

    int get_smallest_number()
    {
        for (int block_idx = 0; block_idx < block_list.size(); ++block_idx) {
            BlockType block = block_list.at(block_idx);
            if (block != 0) {
                BlockType lowest_bit = block & (-block);
                int offset = __builtin_ctzll(lowest_bit);
                int num = offset / bits_per_num + block_idx * block_size / bits_per_num;
                return num;
            }
        }
        return -1;
    }

private:
    int max_num;
    int max_occurrence;

    int bits_per_num;

    constexpr static int block_size = 8 * sizeof(BlockType);
    vector<BlockType> block_list;

    tuple<int, int, BlockType> get_num_info(int num)
    {
        int block_idx = num * bits_per_num / block_size;
        int offset = num * bits_per_num - block_idx * block_size;
        BlockType cnt = (block_list.at(block_idx) >> offset) & ((1<<bits_per_num) - 1);
        return make_tuple(block_idx, offset, cnt);
    }

    void clear_count(int block_idx, int offset)
    {
        BlockType block = block_list.at(block_idx);
        BlockType cnt = ((1<<bits_per_num)-1);
        block &= ~(cnt << offset);
        block_list.at(block_idx) = block;
    }

    void set_count(int block_idx, int offset, BlockType cnt)
    {
        clear_count(block_idx, offset);
        BlockType block = block_list.at(block_idx);
        block |= cnt << offset;
        block_list.at(block_idx) = block;
    }
};

int find_median(BitCounter bit_counter)
{
    int n = 5;
    int smallest;
    int occurrence;
    while (n > 0) {
        smallest = bit_counter.get_smallest_number();
        occurrence = bit_counter.get_count(smallest);
        bit_counter.clear_count(smallest);
        n -= occurrence;
    }
    return smallest;
}

int main()
{
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<> distrib(0, 255);

    for (int t = 0; t < 100; ++t) {
        vector<int> v;
        BitCounter bit_counter(255, 9);
        for (int i = 0; i < 9; ++i) {
            int rnd = distrib(gen);
            bit_counter.inc(rnd);
            v.emplace_back(rnd);
        }
        sort(v.begin(), v.end());
        if (v.at(4) != find_median(bit_counter))
            cout << "Diff" << endl;;
    }
    return 0;
}