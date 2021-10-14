import pandas as pd
import pyarrow as pa
import numpy as np
import pymylib


# Call a simple pybind11 function
print(pymylib.cpp.mylib_square(11))

# Create a pyarrow DoubleArray. The argument will be wrapped to std::span<const double>
x = pa.array(pd.Series([1.1, 2.2]))
print(pymylib.cpp.mylib_array(x))

# Create a pyarrow StringArray. The argument will be wrapped to std::vector<std::string_view>
y = pa.array(["My", "StringArray", "binding"])
print(y)
print(pymylib.cpp.mylib_total_string_length(y))

# Create a pandas DataFrame with strings, double array and nested double arrays.
df = pd.DataFrame(
    {'name': ['A', 'B', 'C'],
     'a': np.array([1., 2., 3.]),
     'b': [np.array([1., 2.]), np.array([1., 2., 3., 4.]), np.array([100.])]})

pymylib.my_lib_calc(df)
