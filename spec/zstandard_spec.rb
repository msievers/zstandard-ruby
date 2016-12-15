require "benchmark/ips"

describe Zstandard do
  puts "\nffi_libs #{Zstandard::FFIBindings.instance_variable_get(:@ffi_libs).map(&:name)}"

  describe ".deflate" do
    it "does something useful" do
      string = SecureRandom.hex(1024*1024*16)

      compressed = Zstandard.deflate(string)
      decompressed = Zstandard.inflate(compressed)

      expect(decompressed).to eq(string)
    end
=begin
    it "benchmarks" do
      string = SecureRandom.hex(1024*1024*4)
      zlib_compressed_data = Zlib.deflate(string)
      zstd_compressed_data = Zstandard.deflate(string)

      puts "Input sample (first 1000 chars of #{string.length}) SecureRandom.hex"
      puts " "
      puts string[0..1000]
      puts " "
      puts "uncompress: #{string.bytesize} bytes"
      puts "zlib:       #{zlib_compressed_data.bytesize} bytes"
      puts "zstd:       #{zstd_compressed_data.bytesize} bytes"
      puts " "

      Benchmark.ips do |x|
        # Configure the number of seconds used during
        # the warmup phase (default 2) and calculation phase (default 5)
        x.config(:time => 5, :warmup => 2)

        # Typical mode, runs the block as many times as it can
        x.report("zlib") { Zlib.inflate(zlib_compressed_data) }
        x.report("zstd") { Zstandard.inflate(zstd_compressed_data) }

        # Compare the iterations per second of the various reports!
        x.compare!
      end
    end
=end
  end
end
