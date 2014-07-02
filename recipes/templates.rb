#
# Cookbook Name:: tcc
# Recipe:: templates
#
# Copyright 2013, Seges
#
# All rights reserved - Do Not Redistribute
#

case node.platform_family
when 'windows'
  archive_ext = "zip"
else
  archive_ext = "tar.gz"
end

log "TCC templates to process #{node.tcc.templates}" do
  level :warn
end

node.tcc.templates.each do |key,item|
  log "#{key}: #{item} and type #{item.type}"

  if item.type == "tomcat7"
    version = "7.0.47"
    archive_name = "apache-tomcat-#{version}"
    filename = "#{archive_name}.#{archive_ext}"
    url = "http://archive.apache.org/dist/tomcat/tomcat-7/v#{version}/bin/#{filename}"
  else
    next
  end

  templates_dir = "#{node.tcc.location}/templates"
  template_dir = "#{node.tcc.location}/templates/#{key}"

  # TODO: there is a problem if the configuration changes, it will never get applied, you have to manually delete the template on the node - https://github.com/seges/chef-cookbook-tcc/issues/1
  if ::File.exists?(template_dir)
    log "Skipping template #{template_dir} because it exists already."
    next
  end


  tmp_file = "#{Chef::Config[:file_cache_path]}/#{filename}"

  remote_file tmp_file do
    source url
  end

  directory "#{templates_dir}" do
    owner node.tcc.user
    group node.tcc.group
    mode 00774
    recursive true
    action :create
  end

  directory template_dir do
    action :delete
    recursive true
    ignore_failure true
  end

  bash "extract_archive" do
    cwd ::File.dirname(tmp_file)
    code <<-EOH
      tar xzf #{tmp_file} -C #{templates_dir}
      mv #{templates_dir}/#{archive_name} #{template_dir}
      chown -R #{node.tcc.user}:#{node.tcc.group} #{template_dir}
      EOH
  end

  ["context.xml"].each do |item|
    template "#{template_dir}/conf/#{item}" do
      action :create
      owner node.tcc.user
      mode 00644
      source "tcc/templates/#{key}/conf/#{item}.erb"
      cookbook node.tcc.template_cookbooks
      ignore_failure true
    end
  end

  if item.has_key?("libs")
    item.libs.each do |lib|
      parts = lib.artifact_id.split(":")
      parts[0] = parts[0].gsub(".", "/")

      tmp_name = lib.artifact_id.gsub(":","_")
      local_file = "#{template_dir}/lib/#{parts[1]}-#{parts[2]}.jar"
      tmp_file = "#{Chef::Config[:file_cache_path]}/#{tmp_name}.jar"
      log "Local lib file #{local_file} exists (#{tmp_file})? #{ ::File.exists?(local_file) }"

      remote_file tmp_name do
        user node.tcc.user
        group node.tcc.group
        source "http://search.maven.org/remotecontent?filepath=#{parts[0]}/#{parts[1]}/#{parts[2]}/#{parts[1]}-#{parts[2]}.jar"
        path local_file
        action :create
#        not_if { ::File.exists?(local_file) }
      end

#      file local_file do
#        owner node.tcc.user
#        group node.tcc.group
#        mode 0644
#        content ::File.open(tmp_file).read
#        action :create_if_missing
#        only_if { !::File.exists?(local_file) }
#      end
    end
  end
end

