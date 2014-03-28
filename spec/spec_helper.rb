require 'chefspec'
require 'chefspec/berkshelf'

# Specify defaults -- these can be overridden
RSpec.configure do |config|
  config.platform = 'ubuntu'
  config.version = '12.04'
end

ChefSpec::Coverage.start!
