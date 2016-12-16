require_relative "./ffi_bindings"
require_relative "./parameters"

module Zstandard
  # Internal API layer to abstract different libzstd calling semantics/versions
  module API
    def self.streaming_decompress(string, options = {})
      dst_size = window_size(string)

      # The docs propose to check the dst size (windowSize), because it could be manipulated
      raise "Invalid dst size!" if dst_size <= 0 || dst_size > Parameters::MAX_STREAMING_DECOMRPESS_BUFFER_SIZE

      src = FFI::MemoryPointer.from_string(string) # we need the pointer for arithmetics
      dst = FFI::MemoryPointer.new(:char, dst_size)

      dst_offset = 0
      src_offset = 0
      result = []

      dctx = FFIBindings.zstd_create_dctx
      FFIBindings.zstd_decompress_begin(dctx)

      while (src_size = FFIBindings.zstd_next_src_size_to_deompress(dctx)) != 0
        nbytes = FFIBindings.zstd_decompress_continue(
          dctx,
          dst + dst_offset,
          (dst + dst_offset).size,
          src + src_offset,
          src_size
        )

        if FFIBindings.zstd_is_error(error_code = nbytes) > 0
          raise FFIBindings.zstd_get_error_name(error_code)
        elsif nbytes > 0
          result << (dst + dst_offset).read_bytes(nbytes)
          dst_offset += nbytes
          dst_offset = 0 if (dst + dst_offset).size == 0
        end

        src_offset += src_size
      end

      FFIBindings.zstd_free_dctx(dctx)
      dst.free

      result.join
    end

    #
    # Tries to gather the size of the decompressed data.
    #
    # @param [String] string Compressed data
    # @return [Integer] size of the decompressed data or 0
    #
    def self.decompressed_size(string)
      if FFIBindings.zstd_version_number < 600
        parameters = FFIBindings::ZSTD_parameters.new
        FFIBindings.zstd_get_frame_params(parameters, string, string.bytesize)
        parameters[:srcSize]
      else
        frame_params = FFIBindings::ZSTD_frameParams.new
        FFIBindings.zstd_get_frame_params(frame_params, string, string.bytesize)
        frame_params[:frameContentSize]
      end
    end

    def self.simple_compress(string, options = {})
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

    def self.simple_decompress(string, options = {})
      #
      # The docs state, that one should be carefull when using the simple decompress API, because
      # it relies on the upfront knowledge of the decompressed (dst) size. This information may
      # by present within the frame header (or not). If it's present, it can be very large and/or
      # intentionally modified, so it's vital to check that this value is within the systems limits
      # and fallback to streaming decompression if unsure.
      #
      dst = FFI::MemoryPointer.new(:char, dst_size = API.decompressed_size(string))
      error_code = number_of_bytes = FFIBindings.zstd_decompress(dst, dst_size, string, string.bytesize)

      if FFIBindings.zstd_is_error(error_code) != 0
        raise FFIBindings.zstd_get_error_name(error_code).read_string
      else
        dst.read_bytes(number_of_bytes)
      end
    end

    def self.window_size(string)
      if FFIBindings.zstd_version_number < 600
        parameters = FFIBindings::ZSTD_parameters.new
        FFIBindings.zstd_get_frame_params(parameters, string, string.bytesize)
        2 ** parameters[:windowLog]
      elsif FFIBindings.zstd_version_number < 700
        frame_params = FFIBindings::ZSTD_frameParams.new
        FFIBindings.zstd_get_frame_params(frame_params, string, string.bytesize)
        2 ** frame_params[:windowLog]
      else
        frame_params = FFIBindings::ZSTD_frameParams.new
        FFIBindings.zstd_get_frame_params(frame_params, string, string.bytesize)
        frame_params[:windowSize]
      end
    end
  end
end
