require "json"
require_relative '../util'

def run_get_pods(namespace_restrict)
  columns = ["NAMESPACE", "NAME", "READY", "STATUS", "RESTARTS", "AGE", "NODE"]
  formatter = FieldFormatter.new(columns)

  basedir = "cluster-resources/pods/"
  pods = []
  Dir.entries(basedir).each do |nsfile|
    full_path = File.join(basedir, nsfile)
    next if !File.file? full_path
    file = File.open full_path
    data = JSON.load file
    namespace = File.basename(nsfile, File.extname(nsfile))
    next if(!namespace_restrict.nil? && namespace_restrict != namespace)

    data.each do |pod|
      name = pod["metadata"]["name"]

      containerstatuses = pod["status"]["containerStatuses"] || []

      status = pod["status"]["phase"]

      startTime = pod["status"]["startTime"]
      time = time_since(startTime) if startTime

      ready_count = 0
      restart_count = 0
      containerstatuses.each do |c|
          ready_count = ready_count + 1 if c["ready"]
          restart_count = restart_count + c["restartCount"]
      end

      count = containerstatuses.count

      ready_count = "#{ready_count}/#{count}"

      node = pod["spec"]["nodeName"]

      values = [namespace, name, ready_count, status, restart_count, time, node]
      formatter.set(values)
      pods << values
    end
  end

  formatter.print_header()
  pods.sort_by {|p| [p[0], p[1]] }.each do |p|
    formatter.print_element(p)
  end
end