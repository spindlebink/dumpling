require "colorize"
require "option_parser"
require "base64"
require "compress/gzip"

VERSION = "0.1.0"

CODE_TEMPLATE =
%(# 
# Generated via Dumpling v#{VERSION} (https://github.com/obviousscholar/dumpling)
# Be kind; make cool stuff.
# ##NOTE##

require "base64"
require "compress/gzip"

module ##MODULE_NAME##
  extend self
  DATA_STRING = "##DATA_STRING_CONTENTS##"

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
)

in_file = ""
out_file = ""
module_name = ""
output_code = true
note = ""

args = ARGV.dup

OptionParser.parse(args) do |parser|
  parser.banner = "Usage: dumpling [arguments]"
  parser.on "-f FILE", "--file=FILE", "The input file. Defaults to the first argument if no named argument is provided." do |f|
    in_file = f
  end
  parser.on "-o OUTPUT", "--out=OUTPUT", "The output file. Defaults to the second argument if no named argument is provided." do |f|
    out_file = f
  end
  parser.on "-m MODULE", "--module=MODULE", "The name of the module in the output code. Defaults to a cleaned version of the filename." do |m|
    module_name = m
  end
  parser.on "-n NOTE", "--note=NOTE", "An optional note to include at the top of the output code (i.e. original license). Defaults to nothing." do |n|
    note = "#{n}\n# "
  end
  parser.on "-r", "--output-raw", "Output as Base64 instead of as Crystal loader module." do |c|
    output_code = false
  end
  parser.on "-v", "--version", "Show the version" do |v|
    puts "Dumpling v#{VERSION}"
    exit
  end
  parser.on "-h", "--help", "Show this help" do |h|
    puts parser
    exit
  end
end

if in_file.empty?
  if args.size > 0
    in_file = args[0]
    args.shift
  end
end

if out_file.empty?
  if args.size > 0
    out_file = args[0]
    args.shift
  end
end

if in_file.empty?
  err = String.build do |str|
    str << "error: ".colorize(:red)
    str << "must provide a file to read. Use the "
    str << "-f FILE".colorize(:green)
    str << " / "
    str << "--file=FILE".colorize(:green)
    str << " option or an unnamed first argument to the command."
  end
  puts err
  exit 1
end

if out_file.empty?
  err = String.build do |str|
    str << "error: ".colorize(:red)
    str << "must provide a file to output. Use the "
    str << "-o OUTPUT".colorize(:green)
    str << " / "
    str << "--out=OUTPUT".colorize(:green)
    str << " option or an unnamed second argument to the command."
  end
  puts err
  exit 1
end

File.open(in_file, "r") do |file|
  out_bytes = IO::Memory.new
  Compress::Gzip::Writer.open(out_bytes) do |gzip|
    IO.copy(file, gzip)
  end

  if module_name.empty?
    module_name = File.basename(file.path, File.extname(file.path)).camelcase + "Data"
    module_name = module_name.gsub(/[^A-Za-z0-9]/, "")
  end

  out_string = Base64.strict_encode(out_bytes.to_slice)
  out_file_contents = out_string

  if output_code
    out_file_contents = CODE_TEMPLATE.gsub(/(##MODULE_NAME##|##DATA_STRING_CONTENTS##|##NOTE##)/, {"##MODULE_NAME##" => module_name, "##DATA_STRING_CONTENTS##" => out_string, "##NOTE##" => note})
  end

  File.open(out_file, "w") do |out_file_io|
    out_file_io << out_file_contents
  end
end
