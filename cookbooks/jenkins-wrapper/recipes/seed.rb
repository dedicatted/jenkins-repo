xml = File.join(Chef::Config[:file_cache_path], "#{node.jbb.seedjob.name}-config.xml")

template xml do
  source 'seed.xml.erb'
end

jenkins_job "#{node.jbb.seedjob.name}" do
  config xml
end
