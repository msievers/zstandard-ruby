require_relative "./ffi_bindings"

module Zstandard
  module BufferlessStreamingDecompressor
    MAX_VALID_DST_SIZE = 1024 * 1024 * 8 # The docs propose to support at least 8MB (windowSize)

    def self.call(string, options = {})
      dst_size = 0

      if FFIBindings.zstd_version_number < 600
        parameters = FFIBindings::ZSTD_parameters.new
        FFIBindings.zstd_get_frame_params(parameters, string, string.bytesize)
        dst_size = 2 ** parameters[:windowLog]
      elsif FFIBindings.zstd_version_number < 700
        frame_params = FFIBindings::ZSTD_frameParams.new
        FFIBindings.zstd_get_frame_params(frame_params, string, string.bytesize)
        dst_size = 2 ** frame_params[:windowLog]
      else
        frame_params = FFIBindings::ZSTD_frameParams.new
        FFIBindings.zstd_get_frame_params(frame_params, string, string.bytesize)
        dst_size = frame_params[:windowSize]
      end

      # The docs propose to check the dst size (windowSize), because it could be manipulated
      raise "Invalid dst size!" if dst_size <= 0 || dst_size > MAX_VALID_DST_SIZE

      src = FFI::MemoryPointer.from_string(string) # we need the pointer for arithmetics
      dst = FFI::MemoryPointer.new(:char, dst_size)

      dst_offset = 0
      src_offset = 0
      result = []

      dctx = FFIBindings.zstd_create_dctx
      FFIBindings.zstd_decompress_begin(dctx)

      while (src_size = FFIBindings.zstd_next_src_size_to_deompress(dctx)) != 0
        nbytes = FFIBindings.zstd_decompress_continue(dctx, dst + dst_offset, (dst + dst_offset).size, src + src_offset, src_size)

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
  end
end
