require_relative "./zstandard/api"
require_relative "./zstandard/bufferless_streaming_decompressor"
require_relative "./zstandard/simple_compressor"
require_relative "./zstandard/simple_decompressor"
require_relative "./zstandard/version"

module Zstandard
  # Threshold for switching to streaming decompression
  MAX_SIMPLE_DECOMPRESS_SIZE = (ENV["ZSTANDARD_MAX_SIMPLE_DECOMPRESS_SIZE"] || 1024 * 1024 * 32).to_i

  class Error < ::StandardError; end;
  class DecompressedSizeUnknownError < Error; end;
  class LibraryVersionNotSupportedError < Error; end;

  def self.deflate(string, level = 1)
    SimpleCompressor.call(string, level: level)
  end

  def self.inflate(string)
    decompressed_size = API.decompressed_size(string)

    if decompressed_size > 0 && decompressed_size <= MAX_SIMPLE_DECOMPRESS_SIZE
      SimpleDecompressor.call(string)
    else
      BufferlessStreamingDecompressor.call(string)
    end
  end
end
