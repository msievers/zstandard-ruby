require "ffi"

module Zstandard
  module FFIBindings
    extend FFI::Library
    ffi_lib "zstd"

    attach_function :zstd_version_number, :ZSTD_versionNumber, [], :uint

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
