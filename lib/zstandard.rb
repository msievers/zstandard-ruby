require "benchmark/ips"
require 'securerandom'
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

  #
  # buffer-less streaming decompression
  #

  # ZSTD_DCtx* ZSTD_createDCtx(void)
  attach_function :zstd_create_dctx,                :ZSTD_createDCtx,              [], :pointer

  # size_t ZSTD_decompressBegin(ZSTD_DCtx* dctx)
  attach_function :zstd_decompress_begin,           :ZSTD_decompressBegin,         [:pointer], :size_t

  # size_t ZSTD_decompressContinue(ZSTD_DCtx* dctx, void* dst, size_t maxDstSize, const void* src, size_t srcSize)
  attach_function :zstd_decompress_continue,        :ZSTD_decompressContinue,      [:pointer, :pointer, :size_t, :pointer, :size_t], :size_t
  
  # size_t ZSTD_freeDCtx(ZSTD_DCtx* dctx)
  attach_function :zstd_free_dctx,                  :ZSTD_freeDCtx,                [:pointer], :size_t

  # size_t ZSTD_nextSrcSizeToDecompress(ZSTD_DCtx* dctx)
  attach_function :zstd_next_src_size_to_deompress, :ZSTD_nextSrcSizeToDecompress, [:pointer], :size_t

  #
  # helper
  #
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
    #string = "1234567890" * 100 * 1024 * 16
    src = FFI::MemoryPointer.from_string(string)
    dst = FFI::MemoryPointer.new(dst_capacity = zstd_compress_bound(src.size-1))
    error_code_or_size = zstd_compress(dst, dst_capacity, src, src.size-1, 1)

    if zstd_is_error(error_code_or_size) >= 0
      dst.read_bytes(error_code_or_size)
    else
      raise "error"
    end
    .tap do |r|
      #binding.pry
      #inflate(r)
    end
  end

  def self.inflate(string = compressed_data)
    src = FFI::MemoryPointer.from_string(string)
    zstd_get_frame_params(frame_params = ZstdParameters.new, src, src.size)
    dst = FFI::MemoryPointer.new(:char, 2 ** frame_params[:windowLog]) # TODO: check value befor allocating buffer

    index = 0
    capacity = 0
    buffer = []

    dctx = zstd_create_dctx
    zstd_decompress_begin(dctx)

    while (src_size = zstd_next_src_size_to_deompress(dctx)) != 0
      result = zstd_decompress_continue(dctx, dst + capacity, (dst + capacity).size, src + index, src_size)
      if zstd_is_error(result) > 0
        raise "Error"
      elsif result > 0
        buffer << (dst + capacity).read_bytes(result)
        capacity += result
        capacity = 0 if (dst + capacity).size == 0
      end
      
      index += src_size
    end

    zstd_free_dctx(dctx)
    src.free
    dst.free

    result = buffer.join
  end

  def self.benchmark
    string = SecureRandom.hex(1024*1024*16)
    zlib_compressed_data = Zlib.deflate(string)
    zstd_compressed_data = deflate(string)

    Benchmark.ips do |x|
      # Configure the number of seconds used during
      # the warmup phase (default 2) and calculation phase (default 5)
      x.config(:time => 5, :warmup => 2)

      # Typical mode, runs the block as many times as it can
      x.report("zlib") { Zlib.inflate(zlib_compressed_data) }
      x.report("zstd") { inflate(zstd_compressed_data) }

      # Compare the iterations per second of the various reports!
      x.compare!
    end
  end
end
