# Create a user account for our database backups

user  = 'db_backups'
home  = '/home/db_backups'

user user do
  action :create
  shell '/bin/bash'
  home home
  supports manage_home:true
end

directory "#{home}/.ssh" do
  action :create
  mode 0700
  user user
end

keys_doc = begin data_bag_item(node.scpr_percona_cluster.databag,node.scpr_percona_cluster.databag_item) rescue nil end

file "#{home}/.ssh/authorized_keys" do
  action    :create
  user      user
  mode      0600
  content   keys_doc ? keys_doc.keys.join("\n") : ""
end

template "/etc/sudoers.d/10-db_backups" do
  action :create
  source "backups_user.sudo"
  user "root"
  group "root"
  mode 0440
end