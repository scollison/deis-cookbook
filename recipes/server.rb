#
# Cookbook Name:: deis
# Recipe:: server
#
# Copyright 2013, OpDemand LLC
#

include_recipe 'deis::default'

docker_image node.deis.server.repository do
  repository node.deis.server.repository
  tag node.deis.server.tag
  action node.deis.autoupgrade ? :pull : :pull_if_missing
  notifies :redeploy, "docker_container[#{node.deis.server.container}]", :immediately
end

docker_container node.deis.server.container do
  container_name node.deis.server.container
  detach true
  env ["ETCD=#{node.deis.public_ip}:#{node.deis.etcd.port}",
       "HOST=#{node.deis.public_ip}",
       "PORT=#{node.deis.server.port}"]
  image "#{node.deis.server.repository}:#{node.deis.server.tag}"
  port "#{node.deis.server.port}:#{node.deis.server.port}"
  volume VolumeHelper.server(node)
end
