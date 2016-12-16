require_relative "./zstandard/api"
require_relative "./zstandard/parameters"
require_relative "./zstandard/version"

module Zstandard
  class Error < ::StandardError; end;
  class DecompressedSizeUnknownError < Error; end;
  class LibraryVersionNotSupportedError < Error; end;

  def self.deflate(string, level = nil)
    API.simple_compress(string, level: level)
  end

  def self.inflate(string)
    decompressed_size = API.decompressed_size(string)

    if decompressed_size > 0 && decompressed_size <= Parameters::MAX_SIMPLE_DECOMPRESS_SIZE
      API.simple_decompress(string)
    else
      API.streaming_decompress(string)
    end
  end
end
