$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

if !ENV["CI"]
  begin
    require "pry"
  rescue LoadError # rubocop:disable Lint/HandleExceptions
  end

  require "simplecov"
  SimpleCov.start
end

require "zstandard"
