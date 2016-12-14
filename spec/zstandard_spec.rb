require "benchmark/ips"

describe Zstandard do
  describe ".deflate" do
    it "does something useful" do
      string = SecureRandom.hex(1024*1024*16)

      compressed = Zstandard.deflate(string)
      decompressed = Zstandard.inflate(compressed)

      expect(decompressed).to eq(string)
    end

    it "benchmarks" do
      string = SecureRandom.hex(1024*1024*4)
      zlib_compressed_data = Zlib.deflate(string)
      zstd_compressed_data = Zstandard.deflate(string)

      Benchmark.ips do |x|
        # Configure the number of seconds used during
        # the warmup phase (default 2) and calculation phase (default 5)
        x.config(:time => 10, :warmup => 2)

        # Typical mode, runs the block as many times as it can
        x.report("zlib") { Zlib.inflate(zlib_compressed_data) }
        x.report("zstd") { Zstandard.inflate(zstd_compressed_data) }

        # Compare the iterations per second of the various reports!
        x.compare!
      end
    end
  end
end
