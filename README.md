Example using pyarrow and pybind11
==================================

This example demonstrates how one can setup an hybrid python package, e.g. using python code and C++ code via pybind11.
Further it shows how one can integrate pyarrow.

The following pybind11 type casters are added:

* `std::shared_ptr<arrow::DoubleArray>`
* `std::shared_ptr<arrow::StringArray>`
* `std::shared_ptr<arrow::Table>`
* `std::shared_ptr<arrow::RecordBatch>`

see [pyarrow_casters.hpp](python/src/cpp/pyarrow_casters.hpp).

It also shows how once can forward the columns of an `arrow::RecordBatch` to your own non `arrow` function, e.g. there
wrapper to apply the following transformations:

| pyarrow Type                              |      Forwarded Type                    |
|-------------------------------------------|:--------------------------------------:|
| pyarrow.lib.DoubleArray                   |  std::span\<const double>              |
| pyarrow.lib.StringArray                   |  std::vector\<std::string_view>        |
| pyarrow.lib.ListArray[list<item: double>] | std::vector\<std::span\<const double>> |

The [example](examples/example.py) shows how from a `pandas.DataFrame` an `pyarrow.RecordBatch` according to a specific
schema can be extracted and the passed to the internal library via pybind11.

The `python/package` contains a configuration to build (PyPackageBuild) and install (PyPackageInstall) your package
using the target MyLib. This is convenient during development as you do not have to recompile everything.

The actual `setup.py` file for distribution is located in the `python` folder, and you can create/install a `wheel` file
by running the following command from the `python` folder:

```shell
python setup.py bdist_wheel
pip install dist/pymylib-0.0.1-cp39-cp39-linux_x86_64.whl
```

Arrow
-----

In case you need to build the arrow library (and pyarrow) from source have a look at `buikd_arrow.sh`.
