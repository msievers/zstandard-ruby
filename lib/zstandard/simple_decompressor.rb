require_relative "./ffi_bindings"

module Zstandard
  module SimpleDecompressor
    #
    # The docs state, that one should be carefull when using the simple decompress API, because
    # it relies on the upfront knowledge of the decompressed (dst) size. This information may
    # by present within the frame header (or not). If it's present, it can be very large and/or
    # intentionally modified, so it's vital to check that this value is within the systems limits
    # and fallback to streaming decompression if unsure.
    #
    def self.call(string, options = {})
      dst = FFI::MemoryPointer.new(:char, dst_size = API.decompressed_size(string))
      error_code = number_of_bytes = FFIBindings.zstd_decompress(dst, dst_size, string, string.bytesize)

      if FFIBindings.zstd_is_error(error_code) != 0
        raise FFIBindings.zstd_get_error_name(error_code).read_string
      else
        dst.read_bytes(number_of_bytes)
      end
    end
  end
end
