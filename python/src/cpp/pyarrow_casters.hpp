#pragma once

#include <arrow/array/array_primitive.h>
#include <arrow/python/pyarrow.h>
#include <pybind11/pybind11.h>

namespace pybind11 {
    namespace detail {
        template<typename ArrayType>
        struct gen_type_caster {
        public:
            // this doesn't work: PYBIND11_TYPE_CASTER(std::shared_ptr<ArrayType>, _(ArrayType::TypeClass::type_name()));
            PYBIND11_TYPE_CASTER(std::shared_ptr<ArrayType>, _("pyarrow::Array"));
            // Python -> C++
            bool load(handle src, bool)
            {
                PyObject* source = src.ptr();
                if (!arrow::py::is_array(source))
                    return false;
                arrow::Result<std::shared_ptr<arrow::Array>> result =
                        arrow::py::unwrap_array(source);
                if (!result.ok())
                    return false;
                value = std::dynamic_pointer_cast<ArrayType>(result.ValueOrDie());
                return static_cast<bool>(value);
            }
            // C++ -> Python
            static handle cast(std::shared_ptr<ArrayType> src, return_value_policy /* policy */,
                               handle /* parent */)
            {
                return arrow::py::wrap_array(src);
            }
        };
        template<>
        struct type_caster<std::shared_ptr<arrow::DoubleArray>>
            : public gen_type_caster<arrow::DoubleArray> {
        };

        template<>
        struct type_caster<std::shared_ptr<arrow::StringArray>>
            : public gen_type_caster<arrow::StringArray> {
        };
    }// namespace detail
}// namespace pybind11


namespace pybind11::detail {
    template<>
    struct type_caster<std::shared_ptr<arrow::Table>> {
    public:
        PYBIND11_TYPE_CASTER(std::shared_ptr<arrow::Table>, _("pyarrow::Table"));

        // Python -> C++
        bool load(handle src, bool)
        {
            PyObject* source = src.ptr();
            if (!arrow::py::is_table(source))
                return false;
            arrow::Result<std::shared_ptr<arrow::Table>> result = arrow::py::unwrap_table(source);
            if (!result.ok())
                return false;
            value = std::static_pointer_cast<arrow::Table>(result.ValueOrDie());
            return true;
        }
        // C++ -> Python
        static handle cast(std::shared_ptr<arrow::Table> src, return_value_policy /* policy */,
                           handle /* parent */)
        {
            return arrow::py::wrap_table(src);
        }
    };
}// namespace pybind11::detail

namespace pybind11::detail {
    template<>
    struct type_caster<std::shared_ptr<arrow::RecordBatch>> {
    public:
        PYBIND11_TYPE_CASTER(std::shared_ptr<arrow::RecordBatch>, _("pyarrow::RecordBatch"));

        // Python -> C++
        bool load(handle src, bool)
        {
            PyObject* source = src.ptr();
            if (!arrow::py::is_batch(source))
                return false;
            arrow::Result<std::shared_ptr<arrow::RecordBatch>> result =
                    arrow::py::unwrap_batch(source);
            if (!result.ok())
                return false;
            value = std::static_pointer_cast<arrow::RecordBatch>(result.ValueOrDie());
            return true;
        }
        // C++ -> Python
        static handle cast(std::shared_ptr<arrow::RecordBatch> src,
                           return_value_policy /* policy */, handle /* parent */)
        {
            return arrow::py::wrap_batch(src);
        }
    };
}// namespace pybind11::detail
