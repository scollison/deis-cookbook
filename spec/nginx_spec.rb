require 'spec_helper'

describe 'deis::nginx' do
  before do
    stub_command('/opt/chef/embedded/bin/gem list macaddr | grep "(1.6.1)"').and_return(false)
  end

  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end

  it 'includes the apt::default recipe' do
    expect(chef_run).to include_recipe('apt::default')
  end

  it 'adds nginx-ppa apt repository' do
    expect(chef_run).to add_apt_repository('nginx-ppa')
  end

  it 'installs nginx' do
    expect(chef_run).to install_package('nginx')
  end

  it 'deletes default nginx site' do
    expect(chef_run).to delete_link('/etc/nginx/sites-enabled/default')
    expect(chef_run.link('/etc/nginx/sites-enabled/default')).to notify('service[nginx]').to(:restart).delayed
  end

  it 'creates default response template' do
    expect(chef_run).to create_template('/etc/nginx/sites-enabled/default-response')
    expect(chef_run.template('/etc/nginx/sites-enabled/default-response')).to notify('service[nginx]').to(:restart).delayed
  end

  it 'creates nginx config' do
    expect(chef_run).to create_template('/etc/nginx/nginx.conf')
    expect(chef_run.template('/etc/nginx/nginx.conf')).to notify('service[nginx]').to(:restart).delayed
  end

  it 'enables nginx service' do
    expect(chef_run).to enable_service('nginx')
  end
end
