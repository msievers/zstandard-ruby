require_relative "./ffi_bindings"

module Zstandard
  module SimpleCompressor
    def self.call(options = {})
      src = FFI::MemoryPointer.from_string(string)
      dst = FFI::MemoryPointer.new(dst_capacity = FFIBindings.zstd_compress_bound(src.size-1))
      error_code_or_size = FFIBindings.zstd_compress(dst, dst_capacity, src, src.size-1, 1)

      if FFIBindings.zstd_is_error(error_code_or_size) >= 0
        dst.read_bytes(error_code_or_size)
      else
        raise "error"
      end
    end
  end
end
