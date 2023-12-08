require_relative 'pod'

def usage(invalid, valid)
    prog = File.basename($0)
    puts "Invalid command '#{invalid}' for #{prog}"
    puts "Usage: #{prog} describe OBJECT TARGET"
    puts " Valid commands:"
    valid.each do |v|
        puts "%6s" % v
    end
    exit -1
end

def run_describe(action, name, namespace)
    case(action)
    when /pod/
        run_describe_pod(name, namespace)
    else
        usage(action, ["pod"])
    end
end
