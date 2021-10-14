import pandas as pd
import pyarrow as pa
from typing import List, Tuple


class PyArrowConverter:
    def __init__(self, fields: List[Tuple[str, pa.DataType]]):
        pa_fields = [ pa.field(name, pa_type) for name, pa_type in fields]
        self._schema = pa.schema(pa_fields)

    def __call__(self, df: pd.DataFrame) -> pa.RecordBatch:
        return pa.RecordBatch.from_pandas(df, self._schema)
