require "date"

def time_since(start_time)
  start = DateTime.strptime(start_time,"%Y-%m-%dT%H:%M:%SZ")
  start_ts = start.strftime("%s").to_i
  now_ts = Time.now.getutc.strftime("%s").to_i
  diff_ts = now_ts - start_ts
  if(diff_ts > 60 * 60 * 24)
      time = (diff_ts / 60 / 60 / 24).floor.to_s + "d"
  elsif(diff_ts > 60 * 60)
      time = (diff_ts / 60 / 60).floor.to_s + "h" + (diff_ts % 24).floor.to_s + "m"
  elsif(diff_ts > 60)
      time = (diff_ts / 60).floor.to_s + "m" + (diff_ts % 60).to_s + "s"
  else
      time = (diff_ts).to_s + "s"
  end

  return time
end

class FieldFormatter
  def initialize(arr)
    @fields = Hash.new
    arr.each do |e|
      @fields[e] = e.length
    end
    @header_names = arr
    @lock_headers = []
  end

  # locks the specified header so it does not resize on a set() call.  
  #   Useful for fields like event messages which can be really long but
  #   have built in carriage returns
  def lock(str)
    @lock_headers << str
  end

  def set(arr)
    arr.each_with_index do |a, i|
      next if @lock_headers.include?(@header_names[i])
      @fields[@header_names[i]] = a.to_s.length if a.to_s.length > @fields[@header_names[i]]
    end
  end

  def print_header()
    str_format = self.str_format()
    puts str_format % @fields.keys 
  end

  def print_element(arr)
    str_format = self.str_format()
    puts str_format % arr
  end

  def str_format()
    str_format = ""
    @fields.each_key do |k|
      str_format = str_format + "%-#{@fields[k] + 4}s "
    end
    str_format
  end
end