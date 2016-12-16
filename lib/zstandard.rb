require_relative "./zstandard/api"
require_relative "./zstandard/version"

module Zstandard
  # The docs propose to support at least 8MB
  MAX_STREAMING_DECOMRPESS_BUFFER_SIZE = (ENV["ZSTANDARD_MAX_STREAMING_DECOMRPESS_BUFFER_SIZE"] || 1024 * 1024 * 8).to_i

  # Threshold for switching to streaming decompression
  MAX_SIMPLE_DECOMPRESS_SIZE = (ENV["ZSTANDARD_MAX_SIMPLE_DECOMPRESS_SIZE"] || 1024 * 1024 * 32).to_i

  class Error < ::StandardError; end;
  class DecompressedSizeUnknownError < Error; end;
  class LibraryVersionNotSupportedError < Error; end;

  def self.deflate(string, level = 1)
    API.simple_compress(string, level: level)
  end

  def self.inflate(string)
    decompressed_size = API.decompressed_size(string)

    if decompressed_size > 0 && decompressed_size <= MAX_SIMPLE_DECOMPRESS_SIZE
      API.simple_decompress(string)
    else
      API.streaming_decompress(string)
    end
  end
end
