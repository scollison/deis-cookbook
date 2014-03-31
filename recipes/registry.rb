#
# Cookbook Name:: deis
# Recipe:: registry
#
# Copyright 2013, OpDemand LLC
#

include_recipe 'deis::default'

require 'etcd'
ruby_block 'publish-registry-config' do
  block do
    client = Etcd.client(host: node.deis.public_ip, port: node.deis.etcd.port)
    client.set('/deis/registry/s3accessKey', node.deis.registry.s3.access_key)
    client.set('/deis/registry/s3secretKey', node.deis.registry.s3.secret_key)
    client.set('/deis/registry/s3bucket', node.deis.registry.s3.bucket)
    client.set('/deis/registry/s3encrypt', node.deis.registry.s3.encrypt)
    client.set('/deis/registry/s3secure', node.deis.registry.s3.secure)
    client.set('/deis/registry/smtpHost', node.deis.registry.smtp.host)
    client.set('/deis/registry/smtpPort', node.deis.registry.smtp.port)
    client.set('/deis/registry/smtpLogin', node.deis.registry.smtp.login)
    client.set('/deis/registry/smtpPassword', node.deis.registry.smtp.password)
    client.set('/deis/registry/smtpSecure', node.deis.registry.smtp.secure)
    client.set('/deis/registry/smtpFrom', node.deis.registry.smtp.from)
    client.set('/deis/registry/smtpTo', node.deis.registry.smtp.to)
    client.set('/deis/registry/swiftAuthURL', node.deis.registry.swift.auth_url)
    client.set('/deis/registry/swiftContainer', node.deis.registry.swift.container)
    client.set('/deis/registry/swiftUser', node.deis.registry.swift.username)
    client.set('/deis/registry/swiftPassword', node.deis.registry.swift.password)
    client.set('/deis/registry/swiftTenantName', node.deis.registry.swift.tenant_name)
    client.set('/deis/registry/swiftRegionName', node.deis.registry.swift.region_name)
  end
  not_if do
    begin
      client = Etcd.client(host: node.deis.public_ip, port: node.deis.etcd.port)
      client.get('/deis/registry')
      true
    rescue Net::HTTPServerException, Net::HTTPFatalError
      false
    end
  end
end

docker_image node.deis.registry_data.repository do
  repository node.deis.registry_data.repository
  tag node.deis.registry_data.tag
  action :pull_if_missing
end

docker_container node.deis.registry_data.container do
  container_name node.deis.registry_data.container
  detach true
  init_type false
  image "#{node.deis.registry_data.repository}:#{node.deis.registry_data.tag}"
  volume VolumeHelper.registry_data(node)
end

docker_image node.deis.registry.repository do
  repository node.deis.registry.repository
  tag node.deis.registry.tag
  action node.deis.autoupgrade ? :pull : :pull_if_missing
  notifies :redeploy, "docker_container[#{node.deis.registry.container}]", :immediately
end

docker_container node.deis.registry.container do
  container_name node.deis.registry.container
  detach true
  env ["ETCD=#{node.deis.public_ip}:#{node.deis.etcd.port}",
       "HOST=#{node.deis.public_ip}",
       "PORT=#{node.deis.registry.port}",
       "SETTINGS_FLAVOR=#{node.deis.registry.settings_flavor}"]
  image "#{node.deis.registry.repository}:#{node.deis.registry.tag}"
  port "#{node.deis.registry.port}:#{node.deis.registry.port}"
  volume VolumeHelper.registry(node)
end

ruby_block 'wait-for-registry' do
  block do
    EtcdHelper.wait_for_key(
      node.deis.public_ip,
      node.deis.etcd.port,
      '/deis/registry/host',
      60
    )
  end
end
