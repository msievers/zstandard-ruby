source "https://rubygems.org"

# Specify your gem's dependencies in zstandard.gemspec
gemspec

group :development do
  gem "benchmark-ips"
  gem "bundler"
  gem "rake"
  gem "ruby-progressbar", "~> 1.0"
  gem "rspec", "~> 3.0"

  if RUBY_ENGINE == "ruby"
    gem "simplecov" if RUBY_VERSION >= "2.0.0"

    if !ENV["CI"]
      gem "pry"

      if RUBY_VERSION < "2.0.0"
        gem "pry-nav"
      else
        gem "pry-byebug"
      end

      # yard and friends
      gem "redcarpet"
      gem "github-markup"
      gem "yard"
    end
  end
end
