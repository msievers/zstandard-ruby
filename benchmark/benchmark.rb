require "benchmark/ips"

module Benchmark
  def self.benchmark
  string = SecureRandom.hex(1024*1024*16)
  zlib_compressed_data = Zlib.deflate(string)
  zstd_compressed_data = deflate(string)

  inflate(string)

  Benchmark.ips do |x|
    # Configure the number of seconds used during
    # the warmup phase (default 2) and calculation phase (default 5)
    x.config(:time => 5, :warmup => 2)

    # Typical mode, runs the block as many times as it can
    x.report("zlib") { Zlib.inflate(zlib_compressed_data) }
    x.report("zstd") { inflate(zstd_compressed_data) }

    # Compare the iterations per second of the various reports!
    x.compare!
  end
end
