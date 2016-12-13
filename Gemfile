source "https://rubygems.org"

# Specify your gem's dependencies in zstandard.gemspec
gemspec

group :development do
  gem "benchmark-ips"
  gem "bundler"
  gem "rake"
  gem "rubocop", "~> 0.41", require: false
  gem "rspec",   "~> 3.0"
  gem "simplecov"

  if !ENV["CI"] && RUBY_ENGINE == "ruby"
    gem "pry"

    if RUBY_VERSION < "2.0.0"
      gem "pry-nav"
    else
      gem "pry-byebug"
    end
  end
end
