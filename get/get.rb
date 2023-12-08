require_relative 'pods'
require_relative 'events'
require_relative 'nodes'

def run_get(action, namespace)
    case(action)
    when /pods?/
        run_get_pods(namespace)
    when /events?/
        run_get_events(namespace)
    when /nodes?/
        run_get_nodes()
    else
        usage(action, ["pod[s]","event[s]","node[s]"])
    end
end
