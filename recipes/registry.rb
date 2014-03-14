
require 'etcd'
ruby_block 'publish-registry-config' do
  block do
    client = Etcd.client(host: node.deis.public_ip, port: node.deis.etcd.port)
    client.set('/deis/registry/s3accessKey', "REPLACEME")
    client.set('/deis/registry/s3secretKey', "REPLACEME")
    client.set('/deis/registry/s3bucket', "REPLACEME")
    client.set('/deis/registry/s3encrypt', "REPLACEME")
    client.set('/deis/registry/s3secure', "REPLACEME")
    client.set('/deis/registry/smtpHost', "REPLACEME")
    client.set('/deis/registry/smtpPort', "REPLACEME")
    client.set('/deis/registry/smtpLogin', "REPLACEME")
    client.set('/deis/registry/smtpPassword', "REPLACEME")
    client.set('/deis/registry/smtpSecure', "REPLACEME")
    client.set('/deis/registry/smtpFrom', "REPLACEME")
    client.set('/deis/registry/smtpTo', "REPLACEME")
    client.set('/deis/registry/swiftAuthURL', "REPLACEME")
    client.set('/deis/registry/swiftContainer', "REPLACEME")
    client.set('/deis/registry/swiftUser', "REPLACEME")
    client.set('/deis/registry/swiftPassword', "REPLACEME")
    client.set('/deis/registry/swiftTenantName', "REPLACEME")
    client.set('/deis/registry/swiftRegionName', "REPLACEME")
  end
  not_if {
    begin
      client = Etcd.client(host: node.deis.public_ip, port: node.deis.etcd.port)
      client.get('/deis/registry')
      true
    rescue Net::HTTPServerException, Net::HTTPFatalError
      false
    end
  }
end

docker_image node.deis.registry_data.repository do
  repository node.deis.registry_data.repository
  tag node.deis.registry_data.tag
  action :pull_if_missing
  cmd_timeout node.deis.registry_data.image_timeout
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
  cmd_timeout node.deis.registry.image_timeout
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
  cmd_timeout 600
end

ruby_block 'wait-for-registry' do
  block do
    EtcdHelper.wait_for_key(node.deis.public_ip, node.deis.etcd.port,
                            '/deis/registry/host', seconds=60)
  end
end
