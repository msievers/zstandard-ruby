require "ffi"

module Zstandard
  module FFIBindings
    extend FFI::Library
    ffi_lib "zstd"

    #
    # Simple api
    #

    # size_t ZSTD_compress(void* dst, size_t dstCapacity, const void* src, size_t srcSize, int compressionLevel)
    attach_function :zstd_compress, :ZSTD_compress, [:pointer, :size_t, :pointer, :size_t, :int], :size_t

    # size_t ZSTD_compressBound(size_t srcSize)
    attach_function :zstd_compress_bound, :ZSTD_compressBound, [:size_t], :size_t

    #
    # Buffer-less streaming decompression
    #

    # ZSTD_DCtx* ZSTD_createDCtx(void)
    attach_function :zstd_create_dctx, :ZSTD_createDCtx, [], :pointer

    # size_t ZSTD_decompressBegin(ZSTD_DCtx* dctx)
    attach_function :zstd_decompress_begin, :ZSTD_decompressBegin, [:pointer], :size_t

    # size_t ZSTD_decompressContinue(ZSTD_DCtx* dctx, void* dst, size_t dstCapacity, const void* src, size_t srcSize)
    attach_function :zstd_decompress_continue, :ZSTD_decompressContinue, [:pointer, :pointer, :size_t, :pointer, :size_t], :size_t

    # size_t ZSTD_freeDCtx(ZSTD_DCtx* dctx)
    attach_function :zstd_free_dctx, :ZSTD_freeDCtx, [:pointer], :size_t

    # size_t ZSTD_nextSrcSizeToDecompress(ZSTD_DCtx* dctx)
    attach_function :zstd_next_src_size_to_deompress, :ZSTD_nextSrcSizeToDecompress, [:pointer], :size_t

    #
    # Helpers
    #

    # const char* ZSTD_getErrorName(size_t code)
    attach_function :zstd_get_error_name, :ZSTD_getErrorName, [:size_t], :pointer

    # unsigned ZSTD_isError(size_t code)
    attach_function :zstd_is_error, :ZSTD_isError, [:size_t], :uint

    # unsigned ZSTD_versionNumber (void)
    attach_function :zstd_version_number, :ZSTD_versionNumber, [], :uint

    #
    # (Advanced) types (requires zstd_version_number to be attached for conditionals)
    #
    if zstd_version_number < 600
      enum :ZSTD_strategy, [:ZSTD_fast, :ZSTD_greedy, :ZSTD_lazy, :ZSTD_lazy2, :ZSTD_btlazy2]

      class ZSTD_parameters < FFI::Struct
        layout(
          :srcSize,      :uint64,
          :windowLog,    :uint32,
          :contentLog,   :uint32,
          :hashLog,      :uint32,
          :searchLog,    :uint32,
          :searchLength, :uint32,
          :targetLength, :uint32,
          :strategy,     :ZSTD_strategy
        )
      end
    elsif zstd_version_number < 800
      enum :ZSTD_strategy, [:ZSTD_fast, :ZSTD_greedy, :ZSTD_lazy, :ZSTD_lazy2, :ZSTD_btlazy2, :ZSTD_btopt]
    else
      enum :ZSTD_strategy, [:ZSTD_fast, :ZSTD_dfast, :ZSTD_greedy, :ZSTD_lazy, :ZSTD_lazy2, :ZSTD_btlazy2, :ZSTD_btopt]

      class ZSTD_compressionParameters < FFI::Struct
        layout(
          :windowLog,    :uint,
          :chainLog,     :uint,
          :hashLog,      :uint,
          :searchLog,    :uint,
          :searchLength, :uint,
          :targetLength, :uint,
          :strategy,     :ZSTD_strategy
        )
      end

      class ZSTD_frameParams < FFI::Struct
        layout(
          :frameContentSize, :ulong_long,
          :windowSize,       :uint,
          :dictID,           :uint,
          :checksumFlag,     :uint
        )
      end

      class ZSTD_parameters < FFI::Struct
        layout(
          :cParams, ZSTD_compressionParameters,
          :fParams, ZSTD_frameParams
        )
      end
    end
  end
end
