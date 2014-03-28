# This should live in the sudo project: https://github.com/opscode-cookbooks/sudo/pull/44/files
if defined?(ChefSpec)
  def install_sudo(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:sudo, :install, resource_name)
  end

  def remove_sudo(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:sudo, :remove, resource_name)
  end
end
