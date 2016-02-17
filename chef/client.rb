run_path = '/srv/chef'
local_file = 'local.yaml'
if File.exists?(local_file)
  yaml = YAML.load_file(local_file)
  if yaml.key?('run_path')
    run_path = yaml['run_path']
  end
end
file_cache_path = run_path
cookbook_path = run_path + "/cookbooks"

puts "file_cache_path: " + file_cache_path
puts "cookbook_path: " + cookbook_path
