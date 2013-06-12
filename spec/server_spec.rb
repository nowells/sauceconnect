require 'chef/config'
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
    runner.node.set['sauceproxy']['server']['version'] = '3.14159'
    runner.converge('sauceproxy::server')
  end

  it 'should install unzip to unpack the zipfile' do
    expect(chef_run).to install_package('unzip')
  end

  it 'should create a user to run sauceproxy under' do
    expect(chef_run).to create_user('fake')
  end

  it 'should create a sauceproxy directory with the right ownership' do
    expect(chef_run).to create_directory('/tmp/fake')
    expect(chef_run.directory('/tmp/fake')).to be_owned_by('fake')
  end

  pending 'should download a remote_file from Sauce Labs' do
    # Doesn't currently work due to some weird chefspec error
    expect(chef_run).to create_remote_file(::File.join(Chef::Config[:file_cache_path], 'Sauce-Connect-3.14159.zip'))
  end

  it 'should start a service called sauceproxy' do
    expect(chef_run).to start_service('sauceproxy')
    expect(chef_run).to set_service_to_start_on_boot('sauceproxy')
  end
end
