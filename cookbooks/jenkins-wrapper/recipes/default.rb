# Install Git
include_recipe 'git::default'

# Install Jenkins
include_recipe 'java::default'
include_recipe 'jenkins::master'

# Prepare SSH keys
require 'openssl'
require 'net/ssh'
jenkins_keys = data_bag_item('jenkins', 'keys')
key = OpenSSL::PKey::RSA.new(jenkins_keys['private_key'])
private_key = key.to_pem
public_key = "#{key.ssh_type} #{[key.to_blob].pack('m0')}"

# Create system Jenkins user with the public key
jenkins_user "#{node.jenkins_chef.username}" do
  full_name	"#{node.jenkins_chef.fullname}"
  email		"#{node.jenkins_chef.email}"
  public_keys [public_key]
end

# Create admin Jenkins user
jenkins_user "#{node.jenkins_admin.username}" do
  full_name	"#{node.jenkins_admin.fullname}"
  email		"#{node.jenkins_admin.email}"
  password     data_bag_item('jenkins', 'admin_password')['password']
end

# Set the private key on the Jenkins executor
node.run_state[:jenkins_private_key] = private_key

# Set the private key on the Jenkins executor
#ruby_block 'set private key' do
#  block { node.set['jenkins']['executor']['private_key'] = private_key }
#end

# Enable authentication.
jenkins_script 'add_authentication' do
  command <<-EOH.gsub(/^ {4}/, '')
    import jenkins.model.*
    import hudson.security.*
    import org.jenkinsci.plugins.*
    def instance = Jenkins.getInstance()
    def securityRealm = new HudsonPrivateSecurityRealm(false)
    instance.setSecurityRealm(securityRealm)
    def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
    instance.setAuthorizationStrategy(strategy)
    instance.save()
  EOH
end

# Install GitHub plugin
jenkins_plugin 'github' do
  notifies :restart, 'runit_service[jenkins]', :immediately
end

# Install Build Flow Plugin
jenkins_plugin 'build-flow-plugin' do
  notifies :restart, 'runit_service[jenkins]', :immediately
end

# Install Jenkins job builder
python_runtime '2'
python_package 'jenkins-job-builder'

# Create Jenkins job builder configuration file
directory "#{node.jbb.config.dir}" do
  owner 'root'
  group 'root'
  mode '0755'
end

template "#{node.jbb.config.dir}/jenkins_jobs.ini" do
  source 'jenkins_jobs.ini.erb'
  owner "#{node.jenkins.master.user}"
  group 'root'
  mode '0640'
end

# Get 'chef' user's API token and write it to JBB config
jenkins_script 'get_api_token' do
  command <<-EOH.gsub(/^ {4}/, '')
    import hudson.model.*
    import jenkins.security.*
    User u = User.get("#{node.jenkins_chef.username}")
    ApiTokenProperty t = u.getProperty(ApiTokenProperty.class)
    def token = t.getApiToken()
    def token_file = new File("#{node.jbb.config.dir}/jenkins_jobs.ini")
    token_file.append("password=$token" + System.getProperty("line.separator"))
  EOH
end
