require "ffi"
require "zstandard/version"

module Zstandard
  extend FFI::Library
  
  ffi_lib "zstd"

  # simple compression
  attach_function :zstd_compress,       :ZSTD_compress,      [:pointer, :size_t, :pointer, :size_t, :int], :size_t
  attach_function :zstd_compress_bound, :ZSTD_compressBound, [:size_t], :size_t
  attach_function :zstd_decompress,     :ZSTD_decompress,    [:pointer, :size_t, :pointer, :size_t], :size_t
  attach_function :zstd_is_error,       :ZSTD_isError,       [:size_t], :uint
  attach_function :zstd_version_number, :ZSTD_versionNumber, [], :uint

  # buffer-less streaming decompression
  attach_function :zstd_create_dctx,                :ZSTD_createDCtx,              [], :pointer
  attach_function :zstd_decompress_begin,           :ZSTD_decompressBegin,         [:pointer], :size_t
  attach_function :zstd_decompress_continue,        :ZSTD_decompressContinue,      [:pointer, :pointer, :size_t, :pointer, :size_t], :size_t
  attach_function :zstd_next_src_size_to_deompress, :ZSTD_nextSrcSizeToDecompress, [:pointer], :size_t

  # helper
  attach_function :zstd_get_error_name,   :ZSTD_getErrorName,   [:size_t], :pointer
  attach_function :zstd_get_frame_params, :ZSTD_getFrameParams, [:pointer, :pointer, :size_t], :size_t
  attach_function :zstd_is_error,         :ZSTD_isError,        [:size_t], :uint

  class ZstdParameters < FFI::Struct
    layout(
      :srcSize,      :uint64,        # optional : tells how much bytes are present in the frame. Use 0 if not known
      :windowLog,    :uint32,        # largest match distance : larger == more compression, more memory needed during decompression */
      :contentLog,   :uint32,        # full search segment : larger == more compression, slower, more memory (useless for fast) */
      :hashLog,      :uint32,        # dispatch table : larger == faster, more memory
      :searchLog,    :uint32,        # nb of searches : larger == more compression, slower */
      :searchLength, :uint32,        # match length searched : larger == faster decompression, sometimes less compression */
      :targetLength, :uint32,        # acceptable match size for optimal parser (only) : larger == more compression, slower */
      :strategy,     :int            # in facet an enum
    )
  end

  # dont forget to free context after usage !!!

  def self.deflate(string, level = 6)
    string = "123456789"* 60000
    src = FFI::MemoryPointer.from_string(string)
    dst = FFI::MemoryPointer.new(dst_capacity = zstd_compress_bound(src.size))
    error_code_or_size = zstd_compress(dst, dst_capacity, src, src.size, 1)

    if zstd_is_error(error_code_or_size) >= 0
      dst.read_bytes(error_code_or_size)
    else
      raise "error"
    end
    .tap do |r|
      inflate(r)
    end
  end

  def self.inflate(string)
    dctx = zstd_create_dctx
    zstd_decompress_begin(dctx)

    src = FFI::MemoryPointer.from_string(string)
    dst1 = FFI::MemoryPointer.new(dst_capacity = 200000)
    dst2 = FFI::MemoryPointer.new(dst_capacity = 200000)

    index = 0
    buffer = []
    
    while (src_size = zstd_next_src_size_to_deompress(dctx)) != 0
      result = 0
      binding.pry
      # result = zstd_decompress_continue(dctx, dst, dst_capacity, src + index, src_size)
      if zstd_is_error(result) > 0
        binding.pry
      elsif result > 0
        # buffer << dst.read_bytes(src_size)
        binding.pry
      end
        
      index += src_size
    end

    result = buffer.join
    binding.pry
  end
end
