require_relative "./ffi_bindings"

module Zstandard
  module BufferlessStreamingDecompressor
    #attach_function :zstd_get_frame_params, :ZSTD_getFrameParams, [:pointer, :pointer, :size_t], :size_t
    
    def self.call(options = {})
      src = FFI::MemoryPointer.from_string(string)
      zstd_get_frame_params(frame_params = ZstdParameters.new, src, src.size)
      binding.pry
      dst = FFI::MemoryPointer.new(:char, 2 ** frame_params[:windowLog]) # TODO: check value befor allocating buffer

      index = 0
      capacity = 0
      buffer = []

      dctx = FFIBindings.zstd_create_dctx
      FFIBindings.zstd_decompress_begin(dctx)

      while (src_size = FFIBindings.zstd_next_src_size_to_deompress(dctx)) != 0
        result = FFIBindings.zstd_decompress_continue(dctx, dst + capacity, (dst + capacity).size, src + index, src_size)
        if FFIBindings.zstd_is_error(result) > 0
          raise "Error"
        elsif result > 0
          buffer << (dst + capacity).read_bytes(result)
          capacity += result
          capacity = 0 if (dst + capacity).size == 0
        end

        index += src_size
      end

      FFIBindings.zstd_free_dctx(dctx)
      src.free
      dst.free

      buffer.join
    end
  end
end
