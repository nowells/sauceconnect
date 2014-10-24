#
# Cookbook Name:: sauceconnect
# Recipe:: server
#
# Copyright 2012-2013, SecondMarket Labs, LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'runit'

user node['sauceconnect']['server']['user'] do
  comment 'SauceLabs Proxy User'
  system true
  action :create
end

directory node['sauceconnect']['server']['install_dir'] do
  owner node['sauceconnect']['server']['user']
  mode 00755
  action :create
end

execute 'untar-saucelabs-proxy' do
  cwd node['sauceconnect']['server']['install_dir']
  command "tar xfz #{Chef::Config[:file_cache_path]}/#{node['sauceconnect']['server']['tarball']} --strip-components=1"
  user node['sauceconnect']['server']['user']
  action :nothing
  notifies :restart, 'service[sauceconnect]'
end

remote_file "#{Chef::Config[:file_cache_path]}/#{node['sauceconnect']['server']['tarball']}" do
  source "#{node['sauceconnect']['server']['download_url']}/#{node['sauceconnect']['server']['tarball']}"
  action :create
  notifies :run, 'execute[untar-saucelabs-proxy]', :immediately
end

runit_service 'sauceconnect' do
  options({
    :user => node['sauceconnect']['server']['user'],
    :api_user => node['sauceconnect']['server']['api_user'],
    :api_key => node['sauceconnect']['server']['api_key'],
    :log_file => node['sauceconnect']['server']['log_file'],
    :install_dir => node['sauceconnect']['server']['install_dir'],
    :tunnel_domains => node['sauceconnect']['server']['tunnel_domains'].join(','),
    :tunnel_id => node['sauceconnect']['server']['tunnel_id']
    })
end
