require 'spec_helper'

describe 'deis::logger' do
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
    it 'pulls logger image' do
      expect(chef_run).to pull_docker_image(chef_run.node.deis.logger.repository)
    end
  end

  context 'when autoupgrade is false' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['deis']['autoupgrade'] = false
      runner.converge(described_recipe)
    end

    it 'pulls logger image if missing' do
      expect(chef_run).to pull_if_missing_docker_image(chef_run.node.deis.logger.repository)
    end
  end

  it 'notifies the logger container to redeploy' do
    image = chef_run.docker_image(chef_run.node.deis.logger.repository)
    expect(image).to notify("docker_container[#{chef_run.node.deis.logger.container}]").to(:redeploy).immediately
  end

  it 'runs the logger container' do
    expect(chef_run).to run_docker_container(chef_run.node.deis.builder.container)
  end
end
