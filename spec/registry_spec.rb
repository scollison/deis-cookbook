require 'spec_helper'

describe 'deis::registry' do
  before do
    stub_command('/opt/chef/embedded/bin/gem list macaddr | grep "(1.6.1)"').and_return(false)
  end
  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end

  it 'includes deis::default' do
    expect(chef_run).to include_recipe('deis::default')
  end

  it 'publishes the registry config' do
    expect(chef_run).to run_ruby_block('publish-registry-config')
  end

  it 'pulls registry_data image if missing' do
    expect(chef_run).to pull_if_missing_docker_image(node.deis.registry_data.repository)
  end

  it 'runs registry_data image' do
    expect(chef_run).to run_docker_container(chef_run.node.deis.registry_data.container)
  end

  context 'when autoupgrade is true' do
    it 'pulls registry image' do
      expect(chef_run).to pull_docker_image(chef_run.node.deis.registry.repository)
    end
  end

  context 'when autoupgrade is false' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['deis']['autoupgrade'] = false
      runner.converge(described_recipe)
    end

    it 'pulls registry image if missing' do
      expect(chef_run).to pull_if_missing_docker_image(chef_run.node.deis.registry.repository)
    end
  end

  it 'notifies the registry container to redeploy' do
    image = chef_run.docker_image(chef_run.node.deis.registry.repository)
    expect(image).to notify("docker_container[#{chef_run.node.deis.registry.container}]").to(:redeploy).immediately
  end

  it 'runs the registry container' do
    expect(chef_run).to run_docker_container(chef_run.node.deis.registry.container)
  end
end
