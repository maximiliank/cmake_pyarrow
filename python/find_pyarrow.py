import pyarrow as pa

print(f"ARROW_INCLUDE_DIR={pa.get_include()};ARROW_LIB_PATH={pa.get_library_dirs()[0]}")
