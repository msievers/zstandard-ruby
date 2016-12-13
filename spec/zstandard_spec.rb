require "securerandom"

describe Zstandard do
  puts "\nffi_libs #{Zstandard::FFIBindings.instance_variable_get(:@ffi_libs).map(&:name)}"

  def random_string(length)
    # Needs to be truncated because the length of the result of base64 is about 4/3 of length
    SecureRandom.base64(length)[0..(length - 1)]
  end

  specify ".deflate" do
    string = random_string(1024)
    compressed_string = Zstandard.deflate(string)
    expect(Zstandard.inflate(compressed_string)).to eq(string)
  end

  describe ".inflate" do
    specify "if decompressed size is <= MAX_SIMPLE_DECOMPRESS_SIZE" do
      string = random_string(Zstandard::Config::MAX_SIMPLE_DECOMPRESS_SIZE)
      compressed_string = Zstandard.deflate(string)
      expect(Zstandard.inflate(compressed_string)).to eq(string)
    end

    specify "if decompressed size is > MAX_SIMPLE_DECOMPRESS_SIZE" do
      string = random_string(Zstandard::Config::MAX_SIMPLE_DECOMPRESS_SIZE + 1)
      compressed_string = Zstandard.deflate(string)
      expect(Zstandard.inflate(compressed_string)).to eq(string)
    end
  end
end
