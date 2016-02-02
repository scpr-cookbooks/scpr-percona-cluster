default['scpr_percona_cluster']['cluster_name'] = "scpr"

#----------

include_attribute "percona"

default['percona']['version'] = "5.6"
default['percona']['auto_restart'] = false
#default['percona']['skip_passwords'] = true
default['percona']['server']['bind_address'] = '0.0.0.0'

default['percona']['server']['role'] = 'cluster'

default["percona"]["apt"]["key"] = "1C4CBDCDCD2EFD2A"
default["percona"]["apt"]["keyserver"] = "hkp://keys.gnupg.net"

default['percona']['cluster']['wsrep_cluster_name'] = node.scpr_percona_cluster.cluster_name

default['percona']['server']['root_password'] = nil