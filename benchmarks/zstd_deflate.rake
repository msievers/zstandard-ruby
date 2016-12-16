require "benchmark/ips"
require "ruby-progressbar"
require "zlib"
require_relative "../lib/zstandard"
require "pry"

namespace :benchmarks do
  task :deflate do
    [
      [
        "random string",
        SecureRandom.base64(1024*1024*16)[0..(1024*1024*16-1)]
      ],
      [
        "Wikipedia Zstandard article (html)",
        File.read(File.join(File.dirname(__FILE__), "assets", "wikipedia_zstandard.html"))
      ],
      [
        "Twitter API response (json)",
        File.read(File.join(File.dirname(__FILE__), "assets", "twitter_api_response.json"))
      ]
    ]
    .each do |description, content|
      [[1, 1], [6, 6]].each do |levels|
        zlib_compressed_size = Zlib.deflate(content, levels.first).bytesize
        zstd_compressed_size = Zstandard.deflate(content, levels.last).bytesize

        show_bar = -> (title, size, compressed_size) do
          ProgressBar.create(title: title, total: size, starting_at: compressed_size, format: "%t: |%B| %c byte").stop
        end

        puts ""
        puts "Deflate, #{description}, #{content.bytesize} bytes, zlib: level=#{levels.first || 'default'}, zstd: level=#{levels.last || 'default'}"
        puts ""

        show_bar.call("uncompressed     ", content.bytesize, content.bytesize)
        show_bar.call("compressed (zlib)", content.bytesize, zlib_compressed_size)
        show_bar.call("compressed (zstd)", content.bytesize, zstd_compressed_size)

        puts

        Benchmark.ips do |x|
          x.config(:time => 5, :warmup => 2)

          x.report("zlib") { Zlib.deflate(content, levels.first) }
          x.report("zstd") { Zstandard.deflate(content, levels.last) }

          x.compare!
        end
      end
    end
  end
end
