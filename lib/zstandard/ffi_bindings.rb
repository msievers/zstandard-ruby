require "ffi"
require_relative "./config"

module Zstandard
  module FFIBindings
    extend FFI::Library
    begin
      ffi_lib Config::LIBRARY_PATH
    rescue LoadError => e
      STDERR.puts "Could not open #{Config::LIBRARY_PATH} shared library!"
      STDERR.puts
      STDERR.puts "Please be sure you have zstd installed. This can be accomplished via"
      STDERR.puts "- your systems package management (e.g. apt-get install zstd)"
      STDERR.puts "- compiled/installed by yourself (use ZSTANDARD_LIBRARY env variable for non-default paths)"
      STDERR.puts
      raise e
    end

    # this is placed upfront because it's needed for various conditionals
    attach_function :zstd_version_number, :ZSTD_versionNumber, [], :uint

    raise Zstandard::LibraryVersionNotSupportedError if zstd_version_number < 500

    #
    # @!group Simple API
    #

    # @!method self.zstd_compress(dst, dstCapacity, src, srcSize, compressionLevel)
    #   @param [void*] dst
    #   @param [size_t] dstCapacity
    #   @param [const void*] src
    #   @param [size_t] srcSize
    #   @param [int] compressionLevel
    #   @return [size_t] the compressed size
    attach_function :zstd_compress, :ZSTD_compress, [:pointer, :size_t, :pointer, :size_t, :int], :size_t


    # @!method self.zstd_compress_bound(srcSize)
    #   @param [size_t] srcSize
    #   @return [size_t]
    attach_function :zstd_compress_bound, :ZSTD_compressBound, [:size_t], :size_t

    # @!method self.zstd_decompress(dst, dstCapacity, src, compressedSize)
    #   @param [void*] dst
    #   @param [size_t] dstCapacity
    #   @param [const void*] src
    #   @param [size_t] compressedSize
    #   @return [size_t] the decompressed size
    attach_function :zstd_decompress, :ZSTD_decompress, [:pointer, :size_t, :pointer, :size_t], :size_t

    #
    # @!group Buffer-less streaming decompression
    #

    # @!method self.zstd_create_dctx
    #   @return [ZSTD_DCtx*]
    attach_function :zstd_create_dctx, :ZSTD_createDCtx, [], :pointer

    # @!method self.zstd_decompress_begin(dctx)
    #   @param [ZSTD_DCtx*] dctx
    #   @return [size_t]
    attach_function :zstd_decompress_begin, :ZSTD_decompressBegin, [:pointer], :size_t

    # @!method self.zstd_decompress_continue(dctx, dst, dstCapacity, src, srcSize)
    #   @param [ZSTD_DCtx*] dctx
    #   @param [void*] dst
    #   @param [size_t] dstCapacity
    #   @param [const void*] src
    #   @param [size_t] srcSize
    #   @return [size_t]
    attach_function :zstd_decompress_continue, :ZSTD_decompressContinue, [:pointer, :pointer, :size_t, :pointer, :size_t], :size_t

    # @!method self.zstd_free_dctx(dctx)
    #   @param [ZSTD_DCtx*] dctx
    #   @return [size_t]
    attach_function :zstd_free_dctx, :ZSTD_freeDCtx, [:pointer], :size_t

    # @!method self.zstd_get_frame_params(fparamsPtr, src, srcSize)
    #   @param [ZSTD_parameters,ZSTD_frameParams] fparamsPtr (type depends on the version of `libzstd`, from `>= 0.6.0`, it's {ZSTD_frameParams}, before it's {ZSTD_parameters})
    #   @param [const void*] src
    #   @param [size_t] srcSize
    #   @return [size_t]
    # size_t ZSTD_getFrameParams(ZSTD_frameParams* fparamsPtr, const void* src, size_t srcSize)
    attach_function :zstd_get_frame_params, :ZSTD_getFrameParams, [:pointer, :pointer, :size_t], :size_t

    # @!method zstd_next_src_size_to_deompress(dctx)
    #   @param [ZSTD_DCtx*] dctx
    #   @return [size_t]
    attach_function :zstd_next_src_size_to_deompress, :ZSTD_nextSrcSizeToDecompress, [:pointer], :size_t

    #
    # @!group Helpers
    #

    # @!method zstd_get_error_name(code)
    #   @param [size_t] code
    #   @return [const char*]
    attach_function :zstd_get_error_name, :ZSTD_getErrorName, [:size_t], :pointer

    # @!method zstd_is_error(code)
    #   @param [size_t] code
    #   @return [unsigned] an integer indicating if this is an error code. A value > 0 indicates `true`.
    # unsigned ZSTD_isError(size_t code)
    attach_function :zstd_is_error, :ZSTD_isError, [:size_t], :uint

    # @!method zstd_version_number
    #   @return [uint]

    # @!endgroup Helpers

    #
    # (Advanced) types (requires zstd_version_number to be attached for conditionals)
    #
    
    if zstd_version_number < 600
      enum :ZSTD_strategy, [:ZSTD_fast, :ZSTD_greedy, :ZSTD_lazy, :ZSTD_lazy2, :ZSTD_btlazy2]
    elsif zstd_version_number < 800
      enum :ZSTD_strategy, [:ZSTD_fast, :ZSTD_greedy, :ZSTD_lazy, :ZSTD_lazy2, :ZSTD_btlazy2, :ZSTD_btopt]
    else
      enum :ZSTD_strategy, [:ZSTD_fast, :ZSTD_dfast, :ZSTD_greedy, :ZSTD_lazy, :ZSTD_lazy2, :ZSTD_btlazy2, :ZSTD_btopt]
    end

    # The format of this struct depends on the version of `libzstd` you are using.
    #
    # `<= v0.6.x`
    # ```
    # typedef struct {
    #   U64 frameContentSize;
    #   U32 windowLog;
    # } ZSTD_frameParams;
    # ```
    #
    # `>= v0.7.x`
    # ```
    # typedef struct {
    #   unsigned long long frameContentSize;
    #   unsigned windowSize;
    #   unsigned dictID;
    #   unsigned checksumFlag;
    # } ZSTD_frameParams;
    # ```
    class ZSTD_frameParams < FFI::Struct
      # @!method [](member)
      if Zstandard::FFIBindings.zstd_version_number < 700
        # `<= v0.6.x`
        # @overload [](member)
        #   @param [:frameContentSize, :windowLog] member
        layout(
          frameContentSize: :uint64,
          windowLog:        :uint32
        )
      elsif Zstandard::FFIBindings.zstd_version_number < 800
        # `>= v0.7.x`
        # @overload [](member)
        #   @param [:frameContentSize, :windowSize, :dictID, :checksumFlag] member
        layout(
          :frameContentSize, :uint64,
          :windowSize,       :uint32,
          :dictID,           :uint32,
          :checksumFlag,     :uint32
        )
      else
        layout(
          :frameContentSize, :ulong_long,
          :windowSize,       :uint,
          :dictID,           :uint,
          :checksumFlag,     :uint
        )
      end
    end

    class ZSTD_parameters < FFI::Struct
      # @!method[](member)
      if Zstandard::FFIBindings.zstd_version_number < 600
        # `<= v0.5.x`
        # @overload [](member)
        #   @param [:srcSize, :windowLog, :contentLog, :hashLog, :searchLog, :searchLength, :targetLength, :strategy]
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
    end
  end
end
