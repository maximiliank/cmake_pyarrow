#include "MyLib/library.h"
#include "pyarrow_casters.hpp"
#include <pybind11/pybind11.h>

#include <arrow/array.h>
#include <arrow/record_batch.h>
#include <iostream>

namespace PyConversions {

    std::span<const double> forwardToView(const std::shared_ptr<arrow::DoubleArray>& array)
    {
        if (array->null_count() != 0)
            throw std::runtime_error("Could not convert arrow::DoubleArray including Null "
                                     "values to std::span<const double>");
        return {array->raw_values(), static_cast<std::size_t>(array->length())};
    }
    std::vector<std::string_view> forwardToView(const std::shared_ptr<arrow::StringArray>& array)
    {
        if (array->null_count() != 0)
            throw std::runtime_error("Could not convert arrow::StringArray including Null "
                                     "values to std::vector<std::string_view>");
        std::vector<std::string_view> ret;
        ret.reserve(array->length());
        for (int i = 0; i < array->length(); ++i)
        {
            std::string_view sv = array->Value(i);
            ret.emplace_back(sv.begin(), sv.end());
        }
        return ret;
    }
    std::vector<std::span<const double>>
    forwardToView(const std::shared_ptr<arrow::ListArray>& array)
    {
        if (array->null_count() != 0)
            throw std::runtime_error("Could not convert arrow::ListArray including Null values "
                                     "to std::vector<...>");
        const auto& value_array = array->values();
        const auto value_type = value_array->type();
        if (value_type->Equals(arrow::float64()))
        {
            std::vector<std::span<const double>> ret;
            ret.reserve(array->length());
            auto values = std::static_pointer_cast<arrow::DoubleArray>(value_array);
            if (values->null_count() != 0)
                throw std::runtime_error("Could not convert arrow::ListArray including Null "
                                         "values to std::vector<std::span<const double>>");
            const double* ptr = values->raw_values();
            for (auto i = 0; i < array->length(); ++i)
            {
                const double* first = ptr + array->value_offset(i);
                const double* last = ptr + array->value_offset(i + 1);
                ret.emplace_back(first, last);
            }
            return ret;
        }
        else
            throw std::runtime_error("Unsupported datatype in arrow::ListArray");
    }
}// namespace PyConversions

template<typename F, typename... Args>
auto wrap_function_impl(F&& f, Args&&... args)
{
    using R = std::invoke_result_t<F, Args...>;
    if constexpr (std::is_void_v<R>)
    {
        std::invoke(std::forward<F>(f), std::forward<Args>(args)...);
    }
    else
    {
        auto result = std::invoke(std::forward<F>(f), std::forward<Args>(args)...);
        return std::move(result);
    }
}

template<typename... Args>
struct Wrapper {
    template<typename F>
    static auto wrap(F&& f)
    {
        return [fn = std::forward<F>(f)](Args&&... args) {
            return wrap_function_impl(fn,
                                      PyConversions::forwardToView(std::forward<Args>(args))...);
        };
    }
};

template<typename ArrayType>
auto getView(std::shared_ptr<arrow::Array> array)
{
    auto array_casted = std::static_pointer_cast<ArrayType>(array);
    return PyConversions::forwardToView(array_casted);
}
void my_lib_calculate(std::shared_ptr<arrow::RecordBatch> rb)
{
    // Verify the expected schema
    std::vector<std::shared_ptr<arrow::Field>> schema_vector = {
            arrow::field("name", arrow::utf8()), arrow::field("a", arrow::float64()),
            arrow::field("b", arrow::list(arrow::float64()))};
    auto expected_schema = std::make_shared<arrow::Schema>(schema_vector);

    if (!expected_schema->Equals(*rb->schema()))
    {
        throw std::runtime_error("Schemas are not matching!");
    }

    std::cout << "Rows: " << rb->num_rows() << std::endl;

    for (auto i = 0; i < rb->schema()->num_fields(); ++i)
    {
        std::cout << "Found column: " << rb->schema()->field(i)->name() << std::endl;
    }

    const auto names = getView<arrow::StringArray>(rb->GetColumnByName("name"));
    const auto a = getView<arrow::DoubleArray>(rb->GetColumnByName("a"));
    const auto b = getView<arrow::ListArray>(rb->GetColumnByName("b"));

    mylib_complex_calculation(names, a, b);
}

namespace py = pybind11;

PYBIND11_MODULE(pymylib, m)
{
    arrow::py::import_pyarrow();
    m.def("mylib_square", &mylib_square);
    m.def("mylib_array", Wrapper<std::shared_ptr<arrow::DoubleArray>>::wrap(&mylib_array),
          py::call_guard<py::gil_scoped_release>());
    m.def("mylib_total_string_length",
          Wrapper<std::shared_ptr<arrow::StringArray>>::wrap(&mylib_total_string_length),
          py::call_guard<py::gil_scoped_release>());
    m.def("my_lib_calculate", &my_lib_calculate, py::call_guard<py::gil_scoped_release>());
}
