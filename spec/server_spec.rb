require 'chef/config'
require 'spec_helper'

describe 'sauceconnect::server' do

  let (:chef_run) do
    runner = ChefSpec::ChefRunner.new(
      platform: 'centos',
      version: '6.3'
    )
    runner.node.set['sauceconnect']['server']['user'] = 'fake'
    runner.node.set['sauceconnect']['server']['install_dir'] = '/tmp/fake'
    runner.node.set['sauceconnect']['server']['version'] = '3.14159'
    runner.converge('sauceconnect::server')
  end

  it 'should install unzip to unpack the zipfile' do
    expect(chef_run).to install_package('unzip')
  end

  it 'should create a user to run sauceconnect under' do
    expect(chef_run).to create_user('fake')
  end

  it 'should create a sauceconnect directory with the right ownership' do
    expect(chef_run).to create_directory('/tmp/fake')
    expect(chef_run.directory('/tmp/fake')).to be_owned_by('fake')
  end

  it 'should create a sysconfig file' do
    expect(chef_run).to create_file('/etc/sysconfig/sauceconnect')
    file = chef_run.template('/etc/sysconfig/sauceconnect')
    expect(file).to be_owned_by('root', 'root')
    expect(file.mode).to eq(00644)
  end

  it 'should create an init script' do
    expect(chef_run).to create_file('/etc/init.d/sauceconnect')
    file = chef_run.template('/etc/init.d/sauceconnect')
    expect(file).to be_owned_by('root', 'root')
    expect(file.mode).to eq(00755)
  end

  pending 'should download a remote_file from Sauce Labs' do
    # Doesn't currently work due to some weird chefspec error
    expect(chef_run).to create_remote_file(::File.join(Chef::Config[:file_cache_path], 'Sauce-Connect-3.14159.zip'))
  end

  it 'should start a service called sauceconnect' do
    expect(chef_run).to start_service('sauceconnect')
    expect(chef_run).to set_service_to_start_on_boot('sauceconnect')
  end
end
