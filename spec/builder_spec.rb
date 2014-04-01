require 'spec_helper'

describe 'deis::builder' do
  before do
    stub_command('/opt/chef/embedded/bin/gem list macaddr | grep "(1.6.1)"').and_return(false)
  end
  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end

  it 'should include deis::default' do
    expect(chef_run).to include_recipe('deis::default')
  end

  context 'when buildpacks directory is specified' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['deis']['builder']['packs']['dir'] = '/var/lib/deis/buildpacks'
      runner.converge(described_recipe)
    end

    it 'should create the buildpacks directory' do
      expect(chef_run).to create_directory(chef_run.node.deis.builder.packs.dir)
    end

    it 'syncs the buildpacks' do
      chef_run.node.deis.builder.packs.defaults.each_pair do |path, repo|
        expect(chef_run).to sync_git("#{chef_run.node.deis.builder.packs.dir}/#{path}")
      end
    end
  end

  context 'when buildpacks directory is nil' do
    it 'should not create the buildpacks directory' do
      expect(chef_run).not_to create_directory(chef_run.node.deis.builder.packs.dir)
    end
  end

  context 'when autoupgrade is true' do
    it 'pulls builder image' do
      expect(chef_run).to pull_docker_image(chef_run.node.deis.builder.repository)
    end
  end

  context 'when autoupgrade is false' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['deis']['autoupgrade'] = false
      runner.converge(described_recipe)
    end

    it 'pulls builder image if missing' do
      expect(chef_run).to pull_if_missing_docker_image(chef_run.node.deis.builder.repository)
    end
  end

  it 'notifies the builder container to redeploy' do
    image = chef_run.docker_image(chef_run.node.deis.builder.repository)
    expect(image).to notify("docker_container[#{chef_run.node.deis.builder.container}]").to(:redeploy).immediately
  end

  it 'runs the builder container' do
    expect(chef_run).to run_docker_container(chef_run.node.deis.builder.container)
  end
end
