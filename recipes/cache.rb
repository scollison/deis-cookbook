#
# Cookbook Name:: deis
# Recipe:: cache
#
# Copyright 2013, OpDemand LLC
#

include_recipe 'deis::default'

docker_image node.deis.cache.repository do
  repository node.deis.cache.repository
  tag node.deis.cache.tag
  action node.deis.autoupgrade ? :pull : :pull_if_missing
  notifies :redeploy, "docker_container[#{node.deis.cache.container}]", :immediately
end

docker_container node.deis.cache.container do
  container_name node.deis.cache.container
  detach true
  env ["ETCD=#{node.deis.public_ip}:#{node.deis.etcd.port}",
       "HOST=#{node.deis.public_ip}",
       "PORT=#{node.deis.cache.port}"]
  image "#{node.deis.cache.repository}:#{node.deis.cache.tag}"
  volume VolumeHelper.cache(node)
  port "#{node.deis.cache.port}:#{node.deis.cache.port}"
end
