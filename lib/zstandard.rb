require_relative "./zstandard/bufferless_streaming_decompressor"
require_relative "./zstandard/simple_compressor"
require_relative "./zstandard/version"

module Zstandard
  def self.deflate(string, level = 1)
    SimpleCompressor.call(string, level: level)
  end

  def self.inflate(string)
    BufferlessStreamingDecompressor.call(string)
  end
end
