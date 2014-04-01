#
# Cookbook Name:: deis
# Recipe:: builder
#
# Copyright 2013, OpDemand LLC
#

include_recipe 'deis::default'

if node.deis.builder.packs.dir
  directory node.deis.builder.packs.dir do
    user node.deis.username
    group node.deis.group
    mode 0755
  end

  # synchronize buildpacks to use during slugbuilder execution
  node.deis.builder.packs.defaults.each_pair do |path, repo|
    url, rev = repo
    git "#{node.deis.builder.packs.dir}/#{path}" do
      user node.deis.username
      group node.deis.group
      repository url
      revision rev
      action :sync
    end
  end
end

docker_image node.deis.builder.repository do
  repository node.deis.builder.repository
  tag node.deis.builder.tag
  action node.deis.autoupgrade ? :pull : :pull_if_missing
  notifies :redeploy, "docker_container[#{node.deis.builder.container}]", :immediately
end

docker_container node.deis.builder.container do
  container_name node.deis.builder.container
  detach true
  privileged true
  env ["ETCD=#{node.deis.public_ip}:#{node.deis.etcd.port}",
       "HOST=#{node.deis.public_ip}",
       'PORT=22']
  image "#{node.deis.builder.repository}:#{node.deis.builder.tag}"
  port "#{node.deis.builder.port}:22"
  volume VolumeHelper.builder(node)
end
