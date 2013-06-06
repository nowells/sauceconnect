require 'spec_helper'

describe 'sauceproxy::server' do

  let (:chef_run) do
    runner = ChefSpec::ChefRunner.new(
      platform: 'centos',
      version: '6.3'
    )
    runner.node.set['sauceproxy'] = Hash.new
    runner.node.set['sauceproxy']['server'] = Hash.new
    runner.node.set['sauceproxy']['server']['user'] = 'fake'
    runner.node.set['sauceproxy']['server']['install_dir'] = '/tmp/fake'
    runner.converge('sauceproxy::server')
  end

  it 'should create a sauceproxy directory with the right ownership' do
    expect(chef_run).to create_directory('/tmp/fake')
    expect(chef_run.directory('/tmp/fake')).to be_owned_by('fake')
#    Haven't got this working yet. Need to figure out how to retrieve Chef::Config[:file_cache_path]
#    from within RSpec
#    chef_run.should create_remote_file '/var/cache/chef/Sauce-Connect-3.0-r21.zip'
  end

  it 'should start a service called sauceproxy' do
    expect(chef_run).to start_service('sauceproxy')
    expect(chef_run).to set_service_to_start_on_boot('sauceproxy')
  end
end
