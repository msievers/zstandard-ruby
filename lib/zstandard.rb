require_relative "./zstandard/bufferless_streaming_decompressor"
require_relative "./zstandard/simple_compressor"
require_relative "./zstandard/version"

module Zstandard
  def self.deflate(string, level = 6)
    SimpleCompressor.call(string: string, level: level)
  end

  def self.inflate(string = compressed_data)
    BufferlessStreamingDecompressor.call(string: string)
  end
end
