#
# Cookbook Name:: deis
# Recipe:: nginx
#
# Copyright 2013, OpDemand LLC
#

include_recipe 'apt'

apt_repository 'nginx-ppa' do
  uri 'http://ppa.launchpad.net/ondrej/nginx/ubuntu'
  distribution node.lsb.codename
  components ['main']
  keyserver 'keyserver.ubuntu.com'
  key 'E5267A6C'
end

package 'nginx'

link '/etc/nginx/sites-enabled/default' do
  action :delete
  notifies :restart, 'service[nginx]', :delayed
end

template '/etc/nginx/sites-enabled/default-response' do
  user 'root'
  group 'root'
  mode 0644
  source 'nginx-default-response'
  notifies :restart, 'service[nginx]', :delayed
end

template '/etc/nginx/nginx.conf' do
  user 'root'
  group 'root'
  mode 0644
  source 'nginx.conf.erb'
  notifies :restart, 'service[nginx]', :delayed
end

service 'nginx' do
  action [:enable]
end
