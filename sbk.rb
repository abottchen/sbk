#!/usr/bin/ruby

require 'optparse'
require_relative 'get/get'
require_relative 'describe/describe'

def usage(invalid, valid)
    prog = File.basename($0)
    puts "Invalid command '#{invalid}' for #{prog}"
    puts "Usage: #{prog} COMMAND TARGET"
    puts " Valid commands:"
    valid.each do |v|
        puts "%6s" % v
    end
    exit -1
end

verb = ARGV[0];
action = ARGV[1];

$options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename($0)} COMMAND TARGET"
  opts.on("-n NAMESPACE","--namespace NAMESPACE","Restrict output to a specific namespace") do |n|
    $options[:namespace] = n
  end
  opts.on("-h", "--help", "Usage") do
    puts opts
    exit
  end
end.parse!

case(verb)
when "get"
    run_get(action, $options[:namespace])
when "describe"
    run_describe(action, ARGV[2], $options[:namespace])
else
    usage(verb, ["get"])
end