module Zstandard
  module Config
    LIBRARY_PATH = ENV["ZSTANDARD_LIBRARY"] || "zstd"

    # Threshold for switching to streaming decompression
    MAX_SIMPLE_DECOMPRESS_SIZE =
    begin
      default = 1024 * 1024 * 32
      env_param = ENV["ZSTANDARD_MAX_SIMPLE_DECOMPRESS_SIZE"].to_i
      env_param > 0 ? env_param : default
    end
    .freeze

    # Caps the window size of compressed data to prohibit abuse (e.g. by
    # manipulated frame headers). The docs propose to support at least 8MB.
    MAX_STREAMING_DECOMRPESS_BUFFER_SIZE =
    begin
      default = 1024 * 1024 * 8
      env_param = ENV["ZSTANDARD_MAX_STREAMING_DECOMRPESS_BUFFER_SIZE"].to_i
      env_param > 0 ? env_param : default
    end
    .freeze
  end
end
