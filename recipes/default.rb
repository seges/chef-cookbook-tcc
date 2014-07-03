#
# Cookbook Name:: tcc
# Recipe:: default
#
# Copyright 2013, Seges
#
# All rights reserved - Do Not Redistribute
#

tcc_down_path = "#{Chef::Config['file_cache_path']}/#{node.tcc.bundle_name}"

group node.tcc.group 

user node.tcc.user do
  supports :manage_home => true
  gid node.tcc.group
  home "#{node.tcc.home}"
  shell "/bin/bash"
  action :create
  not_if "id #{node.tcc.user}"
end


remote_file "tcc_bundle" do
  path tcc_down_path
  owner node.tcc.user
  source node.tcc.bundle_url
  mode 00644
end

directory "#{node.tcc.location}" do
  owner node.tcc.user
  group node.tcc.group
  mode 00644
  recursive true
  action :create
end

bash "extract_tcc" do
  cwd ::File.dirname(tcc_down_path)
  code <<-EOH
    tar xzf #{tcc_down_path} -C #{File.join(node.tcc.location, "..")}
    chown -R #{node.tcc.user}:#{node.tcc.group} #{node.tcc.location}
    chmod -R g+rw #{node.tcc.location}
    chmod ug+x #{node.tcc.location}/bin/*
    EOH
end

