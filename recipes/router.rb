#
# Cookbook Name:: deis-router
# Recipe:: default
#
# Copyright 2013, OpDemand LLC
#
# All rights reserved - Do Not Redistribute
#
docker_image node.deis.router.repository do
  repository node.deis.router.repository
  tag node.deis.router.tag
  action node.deis.autoupgrade ? :pull : :pull_if_missing
  cmd_timeout node.deis.router.image_timeout
  notifies :redeploy, "docker_container[#{node.deis.router.container}]", :immediately
end

docker_container node.deis.router.container do
  container_name node.deis.router.container
  detach true
  env ["ETCD=#{node.deis.public_ip}:#{node.deis.etcd.port}",
       "HOST=#{node.deis.public_ip}",
       "PORT=#{node.deis.router.port}"]
  image "#{node.deis.router.repository}:#{node.deis.router.tag}"
  port "#{node.deis.router.port}:#{node.deis.router.port}"
  volume VolumeHelper.router(node)
  cmd_timeout 600
end

ruby_block 'wait-for-router' do
  block do
    EtcdHelper.wait_for_key(node.deis.public_ip, node.deis.etcd.port,
                            '/deis/router/host')
  end
end

chef_gem 'redis' do
  version '3.0.7'
  action :install
end

require 'redis'

# initialize some routable hostnames into Redis
ruby_block 'initialize-default-routes' do
  redis = Redis.new
  # set default route to deis-controller
  redis.set(node.deis.public_ip, "#{node.deis.public_ip}:8000")
end
