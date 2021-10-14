#pragma once

#include <span>
#include <string_view>
#include <vector>

int mylib_square(int x);

double mylib_array(std::span<const double> a);

std::size_t mylib_total_string_length(const std::vector<std::string_view>& strings);

// more complex interface taking strings, doubles and nested double arrays
void mylib_complex_calculation(const std::vector<std::string_view>& names,
                               std::span<const double> numbers,
                               const std::vector<std::span<const double>>& nestedNumbers);
