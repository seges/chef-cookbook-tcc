#
# Cookbook Name:: tcc
# Recipe:: newrelic
#
# Copyright 2014, Seges
#
# All rights reserved - Do Not Redistribute
#

include_recipe "newrelic::repository"
include_recipe "newrelic::server-monitor-agent"
include_recipe "newrelic::java-agent"

node['tcc']['instances'].each do |key,params|
  instances_dir = "#{node.tcc.location}/instances"
  inst_dir = "#{node.tcc.location}/instances/#{key}"
  newrelic_dir = "#{inst_dir}/newrelic"
  log_dir = "#{newrelic_dir}/logs"

  directory newrelic_dir do
    owner params.user
    group node['tcc']['group']
  end

  directory log_dir do
    owner params.user
    group node['tcc']['group']
  end


#  newrelic_yml "#{newrelic_dir}/newrelic.yml" do
#    owner params.user
#    group node['tcc']['group']
#    app_name "#{key}@#{node['hostname']}"
#    log_file_path log_dir
#  end
end

