$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

if !ENV["CI"]
  require "simplecov"
  SimpleCov.start
end

require "zstandard"

begin
  require "pry"
rescue LoadError # rubocop:disable Lint/HandleExceptions
end
