require 'spec_helper'

describe 'deis::server' do
  before do
    stub_command('/opt/chef/embedded/bin/gem list macaddr | grep "(1.6.1)"').and_return(false)
  end
  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end

  it 'should include deis::default' do
    expect(chef_run).to include_recipe('deis::default')
  end

  context 'when autoupgrade is true' do
    it 'pulls server image' do
      expect(chef_run).to pull_docker_image(chef_run.node.deis.server.repository)
    end
  end

  context 'when autoupgrade is false' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['deis']['autoupgrade'] = false
      runner.converge(described_recipe)
    end

    it 'pulls server image if missing' do
      expect(chef_run).to pull_if_missing_docker_image(chef_run.node.deis.server.repository)
    end
  end

  it 'notifies the server container to redeploy' do
    image = chef_run.docker_image(chef_run.node.deis.server.repository)
    expect(image).to notify("docker_container[#{chef_run.node.deis.server.container}]").to(:redeploy).immediately
  end

  it 'runs the server container' do
    expect(chef_run).to run_docker_container(chef_run.node.deis.server.container)
  end
end
