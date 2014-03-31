require 'spec_helper'

describe 'deis::default' do
  before do
    stub_command('/opt/chef/embedded/bin/gem list macaddr | grep "(1.6.1)"').and_return(false)
  end
  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end

  it 'should not remove an old macaddr gem before reinstalling' do
    expect(chef_run).to install_chef_gem('macaddr').with(version: '1.6.1')
  end

  it 'should install etcd gem' do
    expect(chef_run).to install_chef_gem('etcd').with(version: '0.0.6')
  end

  it 'should install lxc' do
    expect(chef_run).to install_package('lxc').with(options: '--force-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"')
  end

  it 'should include docker::default' do
    expect(chef_run).to include_recipe('docker::default')
  end

  it 'should install fail2ban' do
    expect(chef_run).to install_package('fail2ban')
  end

  it 'should install git' do
    expect(chef_run).to install_package('git')
  end

  it 'should install make' do
    expect(chef_run).to install_package('make')
  end

  it 'should create deis user' do
    expect(chef_run).to create_user(chef_run.node['deis']['username'])
  end

  it 'should create directory' do
    expect(chef_run).to create_directory(chef_run.node['deis']['dir'])
  end

  it 'should setup sudo for deis user' do
    expect(chef_run).to install_sudo(chef_run.node['deis']['username'])
  end

  it 'should create log directory' do
    expect(chef_run).to create_directory(chef_run.node['deis']['log_dir'])
  end
end
