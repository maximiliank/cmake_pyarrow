#include "MyLib/library.h"
#include <iostream>
#include <numeric>

int mylib_square(const int x)
{
    return x * x;
}
double mylib_array(const std::span<const double> a)
{
    return std::accumulate(a.begin(), a.end(), 0.);
}
std::size_t mylib_total_string_length(const std::vector<std::string_view>& strings)
{
    std::size_t ret{0};
    for (const auto sv : strings)
        ret += sv.size();
    return ret;
}
void mylib_complex_calculation(const std::vector<std::string_view>& names,
                               std::span<const double> numbers,
                               const std::vector<std::span<const double>>& nestedNumbers)
{
    for (auto i = 0; i < names.size(); ++i)
    {
        std::cout << names[i] << ": " << numbers[i] << " =>";
        for (const auto value : nestedNumbers[i])
            std::cout << " " << value;
        std::cout << '\n';
    }
    std::cout.flush();
}
