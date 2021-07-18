# 
# Generated via Dumpling v0.1.0 (https://github.com/obviousscholar/dumpling)
# Be kind; make cool stuff.
# Gohu font from https://font.gohu.org
# 

require "base64"
require "compress/gzip"

module Gohu14UnicodeData
  extend self
  DATA_STRING = "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"

  def unpack
    gzip_bytes = IO::Memory.new(Base64.decode(DATA_STRING))
    io_bytes = IO::Memory.new()
    Compress::Gzip::Reader.open(gzip_bytes) do |gzip|
      IO.copy gzip, io_bytes
    end
    io_bytes
  end

  def unpack_bytes
    unpack.to_slice
  end

  def unpack_string
    String.new unpack_bytes
  end
end
