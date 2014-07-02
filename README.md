tcc Cookbook
============
Handles the installation and configuration of Tomcat Control Center environment and its instances.

https://github.com/seges/tomcat-control-center

Requirements
------------

#### packages
See metadata.rb

Attributes
----------

#### tcc::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['tcc']['user']</tt></td>
    <td>String</td>
    <td>Main TCC user (not particular instance user)</td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>['tcc']['home']</tt></td>
    <td>String</td>
    <td>Where TCC home is and later the TCC installation is usually placed - usually at TCC's user home</td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>['tcc']['location']</tt></td>
    <td>String</td>
    <td>Where TCC installation resides - usually at TCC's user home/platform/tcc</td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>['tcc']['url']</tt></td>
    <td>String</td>
    <td>Where to download TCC bundle (tar.gz) from</td>
    <td><tt></tt></td>
  </tr>

</table>

#### tcc::templates
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['tcc']['templates']</tt></td>
    <td>Hash</td>
    <td>Contains a map of templates. Key is a template name. It contains list of params: type, libs. Currently only supported type = "tomcat7". "libs" is an array of objects with keys: repo, artifact_id. Now supported "repo" is "maven" only. "artifact_id" is in the colon-separated Maven artifact notation.</td>
    <td><tt></tt></td>
  </tr>
</table>

#### tcc::instances
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['tcc']['instances']</tt></td>
    <td>Hash</td>
    <td>Contains a map of instances. Key is an instance name. It contains list of params: template, user. "template" is the name of a template defined in node['tcc']['templates']. "user" is the assigned user for the instance.</td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>['tcc']['template_cookbooks']</tt></td>
    <td>String</td>
    <td>Defines the cookbook where templates for resources and setenv are located. It should be overriden by every wrapper cookbook because that cookbook contains proper TCC configurations</td>
    <td><tt></tt></td>
  </tr>

</table>



Usage
-----
#### tcc::default
Installs Tomcat Control Center environment for the specified user.

e.g.
Just include `tcc` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[tcc]"
  ]
}
```

#### tcc::instances
Installs general environmnent for all instances. Utilizes TCC's central resource management.

In the wrapper cookbook you have to create CSV resource templates in the pattern:

```
resources-<type>.csv.<environment>.erb
```

```
setenv.csv.<environment>.erb
```

where:

- `type` - one of known TCC resource types - connector, db, env, mail, rmi
- `environment` - chef's configured environment assigned to the node

#### tcc::newrelic

Utilizes the list of TCC instances defined in node.tcc.instances in order to create NewRelic Java configuration. It automatically installs NewRelic server monitoring as well.

Later on if you want to enable NewRelic for an instance, all you need to do is to enable NewRelic agent in setenv.csv.<environment>.erb template and the configuration will be automatically taken.

The recipe needs at least following attributes if you are going to include it in wrapper cookbook:

```
default['newrelic']['license'] = "supersecretlicensekey_from_newrelic"
default['newrelic']['server_monitoring']['license'] = default['newrelic']['license']
default['newrelic']['application_monitoring']['license'] = default['newrelic']['license']
default['newrelic']['plugin_monitoring']['license'] = default['newrelic']['license']
override['newrelic']['java-agent']['execute_install'] = false
```

You will find the generated configuration in <instance_home>/newrelic/newrelic.yml

NOTE: unless https://github.com/escapestudios-cookbooks/newrelic/pull/47 is merged the recipe creates just required directories

Contributing
------------

1. Fork the repository on Github - https://github.com/seges/chef-cookbook-tcc
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Author:: Ladislav Gazo (<gazo@seges.sk>)
Copyright:: 2014, Seges Ltd.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

