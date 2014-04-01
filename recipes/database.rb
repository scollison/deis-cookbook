#
# Cookbook Name:: deis
# Recipe:: database
#
# Copyright 2013, OpDemand LLC
#

include_recipe 'deis::default'

docker_image node.deis.database_data.repository do
  repository node.deis.database_data.repository
  tag node.deis.database_data.tag
  action :pull_if_missing
end

docker_container node.deis.database_data.container do
  container_name node.deis.database_data.container
  detach true
  image "#{node.deis.database_data.repository}:#{node.deis.database_data.tag}"
  init_type false
  volume VolumeHelper.database_data(node)
end

docker_image node.deis.database.repository do
  repository node.deis.database.repository
  tag node.deis.database.tag
  action node.deis.autoupgrade ? :pull : :pull_if_missing
  notifies :redeploy, "docker_container[#{node.deis.database.container}]", :immediately
end

docker_container node.deis.database.container do
  container_name node.deis.database.container
  detach true
  env ["ETCD=#{node.deis.public_ip}:#{node.deis.etcd.port}",
       "HOST=#{node.deis.public_ip}",
       "PORT=#{node.deis.database.port}"]
  image "#{node.deis.database.repository}:#{node.deis.database.tag}"
  port "#{node.deis.database.port}:#{node.deis.database.port}"
  volume VolumeHelper.database(node)
  volumes_from node.deis.database_data.container
end
