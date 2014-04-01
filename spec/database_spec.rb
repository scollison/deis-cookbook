require 'spec_helper'

describe 'deis::database' do
  before do
    stub_command('/opt/chef/embedded/bin/gem list macaddr | grep "(1.6.1)"').and_return(false)
  end
  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end

  it 'should include deis::default' do
    expect(chef_run).to include_recipe('deis::default')
  end

  it 'pulls database_data image if missing' do
    expect(chef_run).to pull_if_missing_docker_image(node.deis.database_data.repository)
  end

  it 'runs database_data image' do
    expect(chef_run).to run_docker_container(chef_run.node.deis.database_data.container)
  end

  context 'when autoupgrade is true' do
    it 'pulls database image' do
      expect(chef_run).to pull_docker_image(chef_run.node.deis.database.repository)
    end
  end

  context 'when autoupgrade is false' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['deis']['autoupgrade'] = false
      runner.converge(described_recipe)
    end

    it 'pulls database image if missing' do
      expect(chef_run).to pull_if_missing_docker_image(chef_run.node.deis.database.repository)
    end
  end

  it 'notifies the database container to redeploy' do
    image = chef_run.docker_image(chef_run.node.deis.database.repository)
    expect(image).to notify("docker_container[#{chef_run.node.deis.database.container}]").to(:redeploy).immediately
  end

  it 'runs the database container' do
    expect(chef_run).to run_docker_container(chef_run.node.deis.database.container)
  end
end
