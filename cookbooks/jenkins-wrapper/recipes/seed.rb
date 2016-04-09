xml = File.join(Chef::Config[:file_cache_path], "#{node.jbb.seedjob.name}-config.xml")

template xml do
  source 'seed.xml.erb'
end

jenkins_job "#{node.jbb.seedjob.name}" do
  config xml
end

# Run seed job for the first time
jenkins_script 'run_seed_job_once' do
  command <<-EOH.gsub(/^ {4}/, '')
    import jenkins.model.*
    def jenkins = Jenkins.getInstance()
    def seedjob = jenkins.getItem("#{node.jbb.seedjob.name}") 
    if ( seedjob.getLastBuild() == null ) {
      jenkins.queue.schedule(seedjob)
    }
  EOH
end
