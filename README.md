# Kafka Puppet Module

A Puppet module for installing and managing [Apache Kafka](http://kafka.apache.org/) brokers.
This module is maintained at https://github.com/wikimedia/puppet-kafka.

This module is currently being maintained by The Wikimedia Foundation at
[operations/puppet/kafka](https://gerrit.wikimedia.org/r/gitweb?p=operations%2Fpuppet%2Fkafka.git;a=summary)
and mirrored on [GitHub](https://github.com/wikimedia/operations-puppet-kafka).
It was originally developed at https://github.com/wikimedia/puppet-kafka.


## Requirements:
- Java
- An Apache Kafka package.  You can use one available at
[the Wikimedia apt repository](http://apt.wikimedia.org/wikimedia/pool/universe/k/kafka/),
or build your own using [operations/debs/kakfa](https://gerrit.wikimedia.org/r/gitweb?p=operations/debs/kafka.git;a=summary).

## Usage:

### Just the package and client configs:
```puppet
# install the kafka package and configure kafka.
class { "kafka":
  zookeeper_hosts => ["zk1:2181", "zk2:2181", "zk3:2181"],
}
```

### Start a kafka broker server
```puppet
# kafka::server requires base kafka class
class { "kafka":
  zookeeper_hosts => ["zk1:2181", "zk2:2181", "zk3:2181"],
}
class { "kafka::server":
    log_dir => "/var/lib/kafka",
}
```

If you do not set```broker_id``` on ```kafka::server```, the ```broker_id```
will be inferred from integers in the node's hostname.  E.g. kafka01 will
render ```server.properties``` with ```brokerid``` == 1.
