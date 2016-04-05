## jenkins repository

### Prerequisites

There are few steps you have to complete in order to use this chef repository.

1. Create data bag 'jenkins' with two items: 'keys' and 'admin_password' (look for the example in the repository 'data bags' directory).
   keys - the private key which will be used by the chef-client and jbb to access jenkins-cli.
   admin_password - the password for the administrative account of Jenkins server.
2. Encrypt these data bag items with your own 'encrypted_data_bag_secret' key.
3. Provide your Jenkins node with this key in order to let the chef client access the encrypted values (copy the key to '/etc/chef' directory on your node).
4. Create your own 'jenkins jobs' repository (use sample from here: https://github.com/dedicatted/jenkins-jobs) and set its address in the cookbook attributes file ( node.default[:jbb][:seedjob][:git] ).
5. Add "Jenkins (Git plugin)" to your 'jenkins jobs' repository and setup the URL of your Jenkins node.

### Usage

The cookbook provides two recipes:

#### default

Installs the Jenkins server (including Git and GitHub plugins) and the Jenkins Job Builder, creates Jenkins users and turns on Jenkins security.

#### seed

Creates the 'seed' job.
