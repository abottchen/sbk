require "json"
require_relative '../util'

def run_get_nodes()
  columns = ["NAME", "STATUS", "ROLES", "AGE", "VERSION"] 
  formatter = FieldFormatter.new(columns)
  nodes = []

  full_path = "cluster-resources/nodes.json"
  file = File.open full_path
  data = JSON.load file

  data.each do |node|
    name = node["metadata"]["name"]

    status_arr = []
    node["status"]["conditions"].each do |c|
      if(c["status"] == "True")
        status_arr << c["type"]
      end 
    end
    status = status_arr.join(",")

    roles = ""
    node["metadata"]["labels"].each do |k,v|
      if(role_label = k.match(/node-role.kubernetes.io\/(.*)/))
        roles = role_label[1]
      end
    end

    age = time_since(node["metadata"]["creationTimestamp"])

    version = node["status"]["nodeInfo"]["kubeletVersion"]

    values = [name, status, roles, age, version]
    formatter.set(values)
    nodes << values
  end

  formatter.print_header()
  nodes.sort_by {|n| [n[0]] }.each do |n|
    formatter.print_element(n)
  end
end