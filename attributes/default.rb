default['scpr_percona_cluster']['cluster_name'] = "scpr"
default['scpr_percona_cluster']['data_dir'] = "/data/mysql"

default['scpr_percona_cluster']['databag'] = 'public_keys'
default['scpr_percona_cluster']['databag_item'] = 'db_backups'

default['scpr_percona_cluster']['innodb_buffer_percent'] = 0.7
default['scpr_percona_cluster']['innodb_buffer_size'] = (node.memory.total.to_i * node.scpr_percona_cluster.innodb_buffer_percent).to_i.to_s + "K"

#----------

include_attribute "percona"

default['percona']['version'] = "5.6"
default['percona']['auto_restart'] = false
#default['percona']['skip_passwords'] = true
default['percona']['server']['bind_address'] = '0.0.0.0'

default['percona']['server']['role'] = 'cluster'

default["percona"]["apt"]["key"] = "1C4CBDCDCD2EFD2A"
default["percona"]["apt"]["keyserver"] = "hkp://keys.gnupg.net"

default['percona']['server']['root_password'] = nil
default['percona']['server']['datadir'] = node.scpr_percona_cluster.data_dir

default['percona']['server']['skip_name_resolve'] = true
default["percona"]["server"]["innodb_log_file_size"] = '32M'

default['percona']['server']['max_connections'] = 200
default['percona']['server']['innodb_buffer_pool_size'] = node.scpr_percona_cluster.innodb_buffer_size

default['percona']['cluster']['wsrep_cluster_name'] = node.scpr_percona_cluster.cluster_name
default['percona']['cluster']['wsrep_sst_method'] = "xtrabackup-v2"
default['percona']['cluster']['wsrep_sst_auth'] = "root:"
default['percona']['cluster']['wsrep_sst_receive_address'] = node.ipaddress

#----------

# FIXME: This should probably go in scpr-base
include_attribute "sudo"

default['authorization']['sudo']['include_sudoers_d'] = true