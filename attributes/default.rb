default['tcc']['user'] = "tcc"
default['tcc']['group'] = "tcc"

case node.platform_family
when 'windows'
  default['tcc']['home'] = "c:/Users/#{node['tcc']['user']}"
when 'mac_os_x'
  default['tcc']['home'] = "/Users/#{node['tcc']['user']}"
else
  default['tcc']['home'] = "/home/#{node['tcc']['user']}"
end

default['tcc']['location'] = "#{node['tcc']['home']}/tcc"

default['tcc']['version'] = "1.5.1"
default['tcc']['bundle_name'] = "tcc-#{node['tcc']['version']}.tar.gz"
default['tcc']['bundle_url'] = "http://seges.github.io/download/tcc/#{node['tcc']['bundle_name']}"

default['tcc']['template_config'] = {
  "tomcat7" => {
    "version" => "7.0.54"
  }
}

# in case the recipe is called from different cookbook, you can place some templates in the cookbook instead of this one
default['tcc']['template_cookbooks'] = "tcc"

