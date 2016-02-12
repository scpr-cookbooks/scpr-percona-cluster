name 'scpr-percona-cluster'
maintainer 'Southern California Public Radio'
maintainer_email 'erichardson@scpr.org'
license 'mit'
description 'Installs/Configures a Percona XtraDB Cluster'
long_description 'Installs/Configures a Percona XtraDB Cluster'
version '0.1.7'

depends "percona"
depends 'scpr-consul', "~> 0.2"
depends 'sudo'
depends 'scpr-logstash-forwarder'