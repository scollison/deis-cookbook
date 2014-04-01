require 'spec_helper'

describe 'deis::controller' do
  before do
    stub_command('/opt/chef/embedded/bin/gem list macaddr | grep "(1.6.1)"').and_return(false)
  end

  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end

  it 'includes the default recipe' do
    expect(chef_run).to includes_recipe('deis::default')
  end

  it 'includes the discovery recipe' do
    expect(chef_run).to includes_recipe('deis::discovery')
  end

  it 'includes the registry recipe' do
    expect(chef_run).to includes_recipe('deis::registry')
  end

  it 'includes the logger recipe' do
    expect(chef_run).to includes_recipe('deis::logger')
  end

  it 'includes the database recipe' do
    expect(chef_run).to includes_recipe('deis::database')
  end

  it 'includes the cache recipe' do
    expect(chef_run).to includes_recipe('deis::cache')
  end

  it 'includes the server recipe' do
    expect(chef_run).to includes_recipe('deis::server')
  end

  it 'includes the builder recipe' do
    expect(chef_run).to includes_recipe('deis::builder')
  end
end
