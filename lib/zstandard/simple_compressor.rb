require_relative "./ffi_bindings"

module Zstandard
  module SimpleCompressor
    def self.call(string, options = {})
      level = options[:level] || 1

      dst_size = FFIBindings.zstd_compress_bound(string.bytesize)
      dst = FFI::MemoryPointer.new(:char, dst_size)

      error_code = number_of_bytes = FFIBindings.zstd_compress(dst, dst_size, string, string.bytesize, level)

      if FFIBindings.zstd_is_error(error_code) >= 0
        dst.read_bytes(number_of_bytes)
      else
        raise "error"
      end
    end
  end
end
