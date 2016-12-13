$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

if RUBY_ENGINE == "ruby"
  if ENV["CI"]
    # CI stuff
  else
    begin
      require "pry"
    rescue LoadError
    end

    begin
      require "simplecov"
      SimpleCov.start
    rescue LoadError
    end
  end
end

require "zstandard"
