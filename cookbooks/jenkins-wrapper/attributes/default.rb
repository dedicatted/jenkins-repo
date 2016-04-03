node.default[:java][:jdk_version] = '7'
node.default[:jenkins][:master][:install_method] = 'war'
node.default[:jenkins][:master][:host] = 'jenkins-test.ec.home'

node.default[:jenkins_admin][:username] = 'admin'
node.default[:jenkins_admin][:fullname] = 'Administrator'
node.default[:jenkins_admin][:email] = 'admin@example.com'

node.default[:jenkins_chef][:username] = 'chef'
node.default[:jenkins_chef][:fullname] = 'Chef system user'
node.default[:jenkins_chef][:email] = 'chef@example.com'

node.default[:jbb][:seedjob][:name] = 'seed'
node.default[:jbb][:seedjob][:description] = 'seed job'
node.default[:jbb][:seedjob][:git] = 'https://github.com/dedicatted/jenkins-jobs'
node.default[:jbb][:config][:dir] = '/etc/jenkins_jobs'
node.default[:jbb][:config][:user] = node[:jenkins_chef][:username]
