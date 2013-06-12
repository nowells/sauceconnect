require 'minitest/spec'

describe_recipe 'sauceproxy::server' do

  it 'runs as a daemon' do
    service('sauceproxy').must_be_running
  end

end
