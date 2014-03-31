require 'spec_helper'

describe 'deis::builder' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end

  it 'should include deis::default' do
    expect(chef_run).to include_recipe 'deis::default'
  end

  context 'when buildpacks directory is specified' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['deis']['builder']['packs'] = '/var/lib/deis/buildpacks'
      runner.converge(described_recipe)
    end

    it 'should create the buildpacks directory' do
      expect(chef_run).to create_directory(chef_run.node.deis.builder.packs)
    end

    it 'syncs the buildpacks' do
      chef_run.node.deis.builder.packs.defaults.each_pair do |path, repo|
        expect(chef_run).to sync_git("#{chef_run.node.deis.builder.packs}/#{path}")
      end
    end
  end

  context 'when buildpacks directory is nil' do
    it 'should not create the buildpacks directory' do
      expect(chef_run).not_to create_directory(chef_run.node.deis.builder.packs)
    end
  end

  context 'when autoupgrade is true' do
    it 'pulls image' do
      expect(chef_run).to pull_docker_image(chef_run.node.deis.builder.repository)
    end
  end

  context 'when autoupgrade is false' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['deis']['autoupgrade'] = false
      runner.converge(described_recipe)
    end

    it 'pulls image if missing' do
      expect(chef_run).to pull_if_missing_docker_image(chef_run.node.deis.builder.repository)
    end
  end

  it 'runs the container' do
    expect(chef_run).to run_docker_container(chef_run.node.deis.builder.container)
  end
end
