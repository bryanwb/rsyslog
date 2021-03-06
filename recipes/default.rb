#
# Cookbook Name:: rsyslog
# Recipe:: default
#
# Copyright 2009-2011, Opscode, Inc.
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

if platform?("ubuntu") && node['platform_version'].to_f == 8.04
  apt_repository "hardy-rsyslog-ppa" do
    uri "http://ppa.launchpad.net/a.bono/rsyslog/ubuntu"
    distribution "hardy"
    components ["main"]
    keyserver "keyserver.ubuntu.com"
    key "C0061A4A"
    action :add
    notifies :run, "execute[apt-get update]", :immediately
  end
end

package "rsyslog" do
  action :install
end

template node["rsyslog"]["override_defaults_file"] do
  source "rsyslog.default.erb"
  owner "root"
  group "root"
  mode 0644
end

directory "/etc/rsyslog.d" do
  owner "root"
  group "root"
  mode 0755
end

unless platform?("redhat","centos","fedora") 
  directory "/var/spool/rsyslog" do
    owner "syslog"
    group "adm"
    mode 0755
  end
end
  
template "/etc/rsyslog.conf" do
  source "rsyslog.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables(:protocol => node['rsyslog']['protocol'])
  notifies :restart, "service[rsyslog]"
end

if platform?("ubuntu")
  template "/etc/rsyslog.d/50-default.conf" do
    source "50-default.conf.erb"
    backup false
    owner "root"
    group "root"
    mode 0644
  end
end

service "rsyslog" do
  service_name "rsyslogd" if platform?("arch")
  supports :restart => true, :reload => true
  action [:enable, :start]
end
