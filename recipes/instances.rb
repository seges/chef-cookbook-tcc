#
# Cookbook Name:: tcc
# Recipe:: instances
#
# Copyright 2013, Seges
#
# All rights reserved - Do Not Redistribute
#

node.tcc.instances.each do |key,item|
  log "#{key}: #{item} and template #{item.template}"

  instances_dir = "#{node.tcc.location}/instances"
  inst_dir = "#{node.tcc.location}/instances/#{key}"
  template_dir = "#{node.tcc.location}/templates/#{item.template}"

  directory inst_dir do
    owner item.user
    group node.tcc.group
    action :create
  end

  bash "copy_template" do
    cwd ::File.dirname(node.tcc.location)
    code <<-EOH
      cp -R #{node.tcc.location}/templates/tcc_template/* #{inst_dir}
      chown -R #{item.user}:#{node.tcc.group} #{inst_dir}
      EOH
  end

  link "#{inst_dir}/bin/setenv.sh" do
    to "#{node.tcc.location}/bin/setenv.sh"
  end

  bash "link_conf_files" do
    cwd ::File.dirname(node.tcc.location)
    code <<-EOH
      TMPL_CONF="#{template_dir}/conf"
      INST_CONF="#{inst_dir}/conf"
      echo "`ls $TMPL_CONF` in $INST_CONF - $TMPL_CONF" > /tmp/a 
      for CONF in `ls $TMPL_CONF` ; do
        TMPL_CONF_FILE="$TMPL_CONF/$CONF";
        if [ ! -d "$TMPL_CONF_FILE" ] && [ "$CONF" != "server.xml" ] ; then
          INST_CONF_FILE="$INST_CONF/$CONF"
          if [ -f "$INST_CONF_FILE" ]; then
            rm "$INST_CONF_FILE"
          fi
          ln -s "$TMPL_CONF_FILE" "$INST_CONF_FILE"
        fi
      done
      EOH
  end

  bash "copy_server_xml" do
    cwd ::File.dirname(node.tcc.location)
    code <<-EOH
      TMPL_CONF="#{template_dir}/conf"
      INST_CONF="#{inst_dir}/conf"
      cp $TMPL_CONF/server.xml $INST_CONF
      chown #{item.user}:#{node.tcc.group} $INST_CONF/server.xml
      EOH
  end

  # write instance configuration
  template "#{instances_dir}/config.properties" do
    owner node.tcc.user
    group node.tcc.group
    mode 00644
    source "config.properties.erb"
    variables(
      :instances => node.tcc.instances
    )
  end 

  ["connector", "db", "env", "mail", "rmi"].each do |res|
    instance_resource = "#{instances_dir}/resources-#{res}.csv"

    template "#{instance_resource}" do
      action :create
      owner node.tcc.user
      mode 00644
      source "tcc/templates/#{key}/conf/resources-#{res}.csv.#{node.chef_environment}.erb"
      cookbook node.tcc.template_cookbooks
      ignore_failure true
    end

    bash "execute_tomcat_resource #{res}" do
      user item.user
      cwd ::File.dirname("#{instances_dir}")
      code <<-EOH
        cd #{instances_dir}
        python TomcatResources.py #{res} update
        EOH
      only_if "cat #{instance_resource}"
    end
  end

  template "#{instances_dir}/setenv.csv" do
    action :create
    owner node.tcc.user
    mode 00644
    source "tcc/templates/#{key}/conf/setenv.csv.#{node.chef_environment}.erb"
    variables(
      :instance_user => item.user
    )
    cookbook node.tcc.template_cookbooks
    ignore_failure true
  end

  case node.platform_family
  when 'windows'
    instance_home = "c:/Users/#{item.user}"
  when 'mac_os_x'
    instance_home = "/Users/#{item.user}"
  else
    instance_home = "/home/#{item.user}"
  end

  template "#{instance_home}/jmx.properties" do
    action :create
    owner node.tcc.user
    mode 00400
    source "tcc/templates/#{key}/conf/jmx.properties.erb"
    cookbook node.tcc.template_cookbooks
    ignore_failure true
  end

end

