import pandas as pd
import pyarrow as pa
from .py_arrow_converter import PyArrowConverter
from pymylib.lib.pymylib import my_lib_calculate


def my_lib_calc(df: pd.DataFrame):
    # Configure converter to have required columns
    converter = PyArrowConverter([('name', pa.utf8()),
                                  ('a', pa.float64()),
                                  ('b', pa.list_(pa.float64()))])
    record_batch = converter(df)
    # Call C++ bindings
    my_lib_calculate(record_batch)

