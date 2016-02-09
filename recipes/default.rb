#
# Cookbook Name:: scpr-percona-cluster
# Recipe:: default
#
# The MIT License (MIT)
#
# Copyright (c) 2016 Southern California Public Radio
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

if !File.exists?("/etc/mysql/.scpr_percona_deployed")
  node.override.percona.auto_restart = true
end

include_recipe "scpr-consul"

# -- Use consul-template to manage cluster members -- #

include_recipe "scpr-consul::consul-template"

directory node.percona.server.includedir do
  action    :create
  recursive true
end

template "#{node.percona.server.includedir}/cluster_members.consul" do
  action :create
end

consul_template_config "percona-cluster-members" do
  action :create
  templates([
    {
      source:       "#{node.percona.server.includedir}/cluster_members.consul",
      destination:  "#{node.percona.server.includedir}/cluster_members.cnf",
      #command:      "service haproxy reload",
    }
  ])
  notifies :restart, "service[consul-template]", :immediately
end

# -- Set up Percona -- #

include_recipe 'percona::cluster'
include_recipe 'percona::toolkit'

# -- logstash-forwarder -- #

log_forward "percona-cluster-#{node.scpr_percona_cluster.cluster_name}" do
  paths ["#{node.scpr_percona_cluster.data_dir}/#{node.name}.err"]
  fields({
    type: "pxc",
    cluster: node.scpr_percona_cluster.cluster_name,
  })
end

# -- Set up a Consul service -- #

consul_service_def "mysql-#{node.scpr_percona_cluster.cluster_name}" do
  action    :create
  port      node["percona"]["server"]["port"]

  check(
    interval: "5s",
    script:   'mysql -u root -e "SHOW PROCESSLIST"'
  )

  notifies  :reload, "service[consul]"
end

# -- note a successful run -- #

execute "create-scpr-percona-deploy" do
  command "touch /etc/mysql/.scpr_percona_deployed"
  not_if { File.exists?("/etc/mysql/.scpr_percona_deployed") }
end

