require 'json'

def fetch_data
  username = `whoami`.strip
  hostname = `hostname`.strip
  user_shell = `echo $SHELL`.strip
  cpu_name = `lscpu | grep "Model name" | cut -d':' -f2`.strip
  {
    username: username,
    hostname: hostname,
    user_shell: user_shell,
    cpu_name: cpu_name,
  }
end


def update_cache(data)
  File.open('fetch_cache.json', 'w') do |file|
    file.write(data.to_json)
  end
end

def read_cache
  JSON.parse(File.read('fetch_cache.json'), symbolize_names: true)
rescue Errno::ENOENT
  {}
end

def different_data?(old_data, new_data)
  old_data_hash = old_data.map { |key, value| [key, value.hash] }.to_h
  new_data_hash = new_data.map { |key, value| [key, value.hash] }.to_h
  old_data_hash != new_data_hash
end

def format_data(data)
  output = []
  output << "#{data[:username]}@#{data[:hostname]}"
  output << data[:cpu_name]
  output << data[:user_shell]
end

# Fetch data
new_data = fetch_data

# Read cache
old_data = read_cache

# Compare data
if different_data?(old_data, new_data)
  update_cache(new_data)
  output_data = format_data(new_data)
else
  output_data = format_data(old_data)
end

# Output data
puts output_data.join("\n")
