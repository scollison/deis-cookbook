require 'spec_helper'

describe 'deis::controller' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end

  it 'should include the default recipe' do
    expect(chef_run).to include_recipe('deis::default')
  end

  it 'should include the discovery recipe' do
    expect(chef_run).to include_recipe('deis::discovery')
  end

  it 'should include the registry recipe' do
    expect(chef_run).to include_recipe('deis::registry')
  end

  it 'should include the logger recipe' do
    expect(chef_run).to include_recipe('deis::logger')
  end

  it 'should include the database recipe' do
    expect(chef_run).to include_recipe('deis::database')
  end

  it 'should include the cache recipe' do
    expect(chef_run).to include_recipe('deis::cache')
  end

  it 'should include the server recipe' do
    expect(chef_run).to include_recipe('deis::server')
  end

  it 'should include the builder recipe' do
    expect(chef_run).to include_recipe('deis::builder')
  end
end
