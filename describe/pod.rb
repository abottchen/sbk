require "json"
require_relative '../util'

def print_pod_array_of_hash(a, s, i)
  str = ""
  if(a.is_a?(Array))
    a.each do |e|
      str += sprintf("%sIP:%s%s\n", " " * i, " " * s, e["ip"])
    end
  end
  return str
end

def print_pod_hash(h, s, sep="=")
  str = ""
  spacing = nil
  if(h.is_a?(Hash))
    h.each do |l,v|
      str += sprintf("%s%s%s%s\n", spacing, l, sep, v)
      spacing = " " * s
    end
  end
  return str
end

def print_pod(pod)
  puts "%-14s %s" % ["Name:", pod["metadata"]["name"]]
  puts "%-14s %s" % ["Namespace:", pod["metadata"]["namespace"]] 
  puts "%-14s %s" % ["Priority:", pod["spec"]["priority"]] 
  puts "%-14s %s" % ["Node:", pod["spec"]["nodeName"]] 
  puts "%-14s %s" % ["Start Time:", pod["spec"]["startTime"]] 
  puts "%-14s %s" % ["Labels:", print_pod_hash(pod["metadata"]["labels"], 15)] 
  puts "%-14s %s" % ["Annotations:", print_pod_hash(pod["metadata"]["annotations"], 15, ": ")] 
  puts "%-14s %s" % ["Status:", pod["status"]["phase"]]
  puts "%-14s %s" % ["IP:", pod["status"]["podIP"]]
  puts "%-14s" % ["IPs:"]
  puts print_pod_array_of_hash(pod["status"]["podIPs"], 10, 2)
end

def run_describe_pod(target_name, namespace_restrict)
  basedir = "cluster-resources/pods/"
  found = 0
  Dir.entries(basedir).each do |nsfile|
    full_path = File.join(basedir, nsfile)
    next if !File.file? full_path
    file = File.open full_path
    data = JSON.load file
    namespace = File.basename(nsfile, File.extname(nsfile))
    next if(!namespace_restrict.nil? && namespace_restrict != namespace)

    data.each do |pod|
      name = pod["metadata"]["name"]
      next if(name != target_name)

      found = found + 1
      print_pod(pod)
    end
  end

  if(found < 1)
    ns_str = namespace_restrict.nil? ? "" : " in namespace #{namespace_restrict}"
    puts "Pod #{target_name} not found#{ns_str}"
  elsif(found > 1)
    puts "Multiple pods found with the name #{target_name}.  You may want to specify a namespace."
  end
end