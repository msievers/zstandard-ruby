require_relative "./ffi_bindings"

module Zstandard
  # Internal API layer to abstract different libzstd calling semantics/versions
  module API
    #
    # Tries to gather the size of the decompressed data.
    #
    # @param [String] string Compressed data
    # @return [Integer] size of the decompressed data or 0
    #
    def self.decompressed_size(string)
      if FFIBindings.zstd_version_number < 600
        parameters = FFIBindings::ZSTD_parameters.new
        FFIBindings.zstd_get_frame_params(parameters, string, string.bytesize)
        parameters[:srcSize]
      else
        frame_params = FFIBindings::ZSTD_frameParams.new
        FFIBindings.zstd_get_frame_params(frame_params, string, string.bytesize)
        frame_params[:frameContentSize]
      end
    end
  end
end
