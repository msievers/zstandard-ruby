# zstandard-ruby

[![Build Status](https://travis-ci.org/msievers/zstandard-ruby.svg?branch=master)](https://travis-ci.org/msievers/zstandard-ruby)

* [Installation](#installation)
* [Usage](#usage)
* [Advanced Usage](#advanced-usage)
* [Configuration](#configuration)
* [Docs](#docs)
* [Examples for installing `libzstd`](#examples-for-installing-libzstd)
* [Contributing](#contributing)
* [License](#license)

This gem implements FFI based bindings to the [Zstandard](https://facebook.github.io/zstd) compression library `libzstd`. The [Zstandard](https://facebook.github.io/zstd) compression algorithm shines because it compresses data with the same or better ratio as *Zlib* but does this (much) faster, depending on the input. For the majority of cases it's **faster and better** then *Zlib*. It is tested to work with MRI from 1.9.3 to 2.6.x and with JRuby from >= 1.7.24, including 9.2.x.

It **does not** ship the actual `libzstd` library but expects some version to be present on your system.

This gem *is activly maintained*. The tests are updated regularly, to keep up with the latest zstd version.

## Installation

Make sure you have `libzstd` installed on your system. In doubt, have a look at the [examples for installing `libzstd`](#examples-for-installing-libzstd).

Add this line to your application's Gemfile:

```ruby
gem "zstandard"
```

And then execute:

```
bundle
```

Or install it yourself as:

```
gem install zstandard
```

## Usage

The gem provides an API which aims compatibility the with `zlib` gem. There are two module methods
* `deflate(string, level)`
* `inflate(compressed_string)`

The only difference between this and the `zlib` gem is the interpretation of the compression level. For `zlib`, this is a value between `1..9`, whereas for `Zstandard` it's between `1..22`.

For most use cases, you should try to keep the compression level (very) low for `Zstandard`, because often compression time increases without significant better compression ratios. If in doubt, *do not specify* a compression level at all, which will use the default compression level.

```ruby
require "zstandard"

compressed_string = Zstandard.deflate(string)
decompressed_string = Zstandard.inflate(compressed_string)
```

## Advanced Usage

*This is not intended to be used by regular users.*

Besides the high level API which targets compatibility with the well known `zlib` gem there are two additional layers you can interact with. There is a low-level API which tries to cover differences between various `libzstd` version, e.g. different *frame header* formats. You should only use this if you know, what you are doing.

```ruby
require "zstandard"

compressed_string = Zstandard::API.simple_compress(string)
decompressed_string = Zstandard::API.simple_decompress(compressed_string)
```

The most low-level bindings are exposed via `Zstandard::FFIBindings`. If there is any reason for this, you can do the following.

```ruby
require "zstandard"

zstd_library_version = Zstandard::FFIBindings.zstd_version_number
```

## Configuration

This gem can be configured by setting various environment variables. Please be carefull if you decide to change/overwrite any of these. The default values are carefully choosen and there should be no need to alter one of these for regular use cases.

### `ZSTANDARD_LIBRARY`

If you have `libzstd` installed in some unusual location or if you want to explictly tell, which library to use, you can set `ZSTANDARD_LIBRARY` to the path of the library you want to use. This can be handy for example if you have the latest version compiled in `/usr/local/lib`, but your system has an old version in `/usr/lib`.

```
ZSTANDARD_LIBRARY=/usr/local/lib/libzstd.so bundle exec rspec
```

### `ZSTANDARD_MAX_SIMPLE_DECOMPRESS_SIZE`

This specifies the maximum (decompressed) size of a string for which the simple decompression approach should be used. In order minimise memory consumption, if the expected decompressed size exceeds this limit, streaming decompression is used.

### `ZSTANDARD_MAX_STREAMING_DECOMRPESS_BUFFER_SIZE`

For streaming decompression, this specifies the size of the decompression bufffer.

## Docs

Yard generated docs can be found at [http://www.rubydoc.info/github/msievers/zstandard-ruby](http://www.rubydoc.info/github/msievers/zstandard-ruby).

## Examples for installing `libzstd`

* [Debian](#debian)
* [Fedora](#fedora)
* [FreeBSD](#freebsd)
* [Mac](#mac)
* [NetBSD](#netbsd)
* [Ubuntu](#ubuntu)

### Debian

#### Jessie (8.x)

The package is only included in `sid`, the unstable Debian version. There are guides describing how to install unstable packages into a stable Debian, for example at [Linuxaria](https://linuxaria.com/howto/how-to-install-a-single-package-from-debian-sid-or-debian-testing) or [serverfault.com](https://serverfault.com/questions/22414/how-can-i-run-debian-stable-but-install-some-packages-from-testing).

```
# run as root

apt-get install zstd
```

### Fedora

#### Fedora 23

```
sudo dnf install libzstd
```

### FreeBSD

#### FreeBSD 10

```
# run as root

portsnap fetch && portsnap extract

cd /usr/ports/archivers/zstd
make install
```

### Mac

```
brew install zstd
```

### NetBSD

#### NetBSD 7

```
# run as root

# the following assumes you are running a x86_64 system with NetBSD 7.0.x

export PATH="/usr/pkg/sbin:$PATH"
export PKG_PATH="ftp://ftp.netbsd.org/pub/pkgsrc/packages/NetBSD/x86_64/7.0_current/All/"

pkg_add zstd
```

### Ubuntu

#### Xenial Xerus (16.04) and above

```
sudo apt-get install zstd
```

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/msievers/zstandard-ruby](https://github.com/msievers/zstandard-ruby).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
