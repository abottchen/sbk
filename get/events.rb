require "json"
require_relative '../util'

Event = Struct.new(:namespace, :lastseen, :type, :reason, :object, :message)

def run_get_events(namespace_restrict)
  columns = ["NAMESPACE", "LAST SEEN", "TYPE", "REASON", "OBJECT", "MESSAGE"]
  formatter = FieldFormatter.new(columns)
  formatter.lock("MESSAGE")

  basedir = "cluster-resources/events/"
  events = []
  Dir.entries(basedir).each do |nsfile|
    full_path = File.join(basedir, nsfile)
    next if !File.file? full_path
    file = File.open full_path
    data = JSON.load file
    namespace = File.basename(nsfile, File.extname(nsfile))
    next if(!namespace_restrict.nil? && namespace_restrict != namespace)

    data.each do |event|
      type = event["type"]

      reason = event["reason"]

      object = event["involvedObject"]["kind"].downcase + "/" + event["involvedObject"]["name"] 

      message = event["message"]

      if(event["lastTimestamp"].nil?)
        event_last_seen = event["metadata"]["creationTimestamp"]
      else
        event_last_seen = event["lastTimestamp"]
      end

      last_seen = time_since(event_last_seen)

      values = [namespace, last_seen, type, reason, object, message]
      formatter.set(values)
      events << values
    end
  end

  formatter.print_header()
  events.each do |e|
    formatter.print_element(e)
  end
end