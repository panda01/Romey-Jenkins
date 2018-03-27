require 'spec_helper'

describe file('/etc/jenkins_jobs/jobs') do
  it { should be_directory }
end
describe docker_container('romey-jenkins') do
  it { should exist }
  it { should be_running }
  it { should have_volume('/home/admin', '/home/vagrant')}
  it { should have_volume('/var/jenkins_home',
                          '/var/lib/docker/volumes/jenkins_home/_data') }
end

describe
describe port(8080) do
  it { should be_listening }
end
