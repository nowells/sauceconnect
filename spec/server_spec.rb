require 'chef/config'
require 'spec_helper'

describe 'sauceconnect::server' do

  let :chef_run do
    runner = ChefSpec::Runner.new(
      :platform => 'centos',
      :version => '6.4'
    )
    runner.node.set['sauceconnect']['server']['user'] = 'fake'
    runner.node.set['sauceconnect']['server']['install_dir'] = '/tmp/fake'
    runner.node.set['sauceconnect']['server']['version'] = '3.14159'
    runner.converge('sauceconnect::server')
  end

  context 'setting up the system' do

    it 'installs unzip to unpack the zipfile' do
      expect(chef_run).to install_package('unzip')
    end

    it 'creates a user to run sauceconnect under' do
      expect(chef_run).to create_user('fake')
    end

    it 'creates a sauceconnect directory with the right ownership' do
      expect(chef_run).to create_directory('/tmp/fake').with(:user => 'fake')
    end

    it 'creates a sysconfig file' do
      expect(chef_run).to create_template('/etc/sysconfig/sauceconnect').with(:user => 'root', :group => 'root', :mode => 00644)
    end

    it 'creates an init script' do
      expect(chef_run).to create_template('/etc/init.d/sauceconnect').with(:user => 'root', :group => 'root', :mode => 00755)
    end
  end

  context 'downloading from SauceLabs' do
    it 'downloads a remote_file from Sauce Labs' do
      expect(chef_run).to create_remote_file(::File.join(Chef::Config[:file_cache_path], 'Sauce-Connect-3.14159.zip'))
    end
    it 'notifies the extraction' do
      resource = chef_run.remote_file(::File.join(Chef::Config[:file_cache_path], 'Sauce-Connect-3.14159.zip'))
      expect(resource).to notify('execute[unzip-saucelabs-proxy]').to(:run).immediately
      expect(resource).to_not notify('execute[unzip-saucelabs-proxy]').to(:run).delayed
    end
    it 'only runs the extraction if notified' do
      expect(chef_run).to_not run_execute('unzip-saucelabs-proxy')
    end
  end

  it 'should start a service called sauceconnect' do
    expect(chef_run).to enable_service('sauceconnect')
    expect(chef_run).to start_service('sauceconnect')
    expect(chef_run).to_not disable_service('sauceconnect')
    expect(chef_run).to_not stop_service('sauceconnect')
  end
end
