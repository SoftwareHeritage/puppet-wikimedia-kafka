$fqdn = 'kafka-node01.domain.org'

class { 'kafka':
  hosts => {
    'kafka-node01.domain.org' => { 'id' => 1, 'port' => 12345 },
    'kafka-node02.domain.org' => { 'id' => 2 },
  },
  zookeeper_hosts => ['zk-node01:2181', 'zk-node02:2181', 'zk-node03:2181'],
}
class { 'kafka::server': }