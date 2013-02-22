# == Class kafka
# Installs Kafka package and sets up defaults configs for clients (producer & consumer).
#
# == Parameters:
# $zookeeper_hosts                  - Array of zookeeper hostname/IP(:port)s.  Default: none, localhost will be used as the Kafka Broker list.
# $zookeeper_connectiontimeout_ms   - Timeout in ms for connecting to zookeeper.  Default: 1000000
# $kafka_log_file                   - File in which to store Kafka logs (not event data).  Default: /var/log/kafka/kafka.log
# $producer_type                    - Specifies whether the messages are (by default) sent asynchronously (async) or synchronously (sync).  Default: async
# $producer_batch_size              - The number of messages batched at the producer.  Default: 200
#
class kafka(
  $zookeeper_hosts                = undef,
  $zookeeper_connectiontimeout_ms = 1000000,
  $kafka_log_file                 = '/var/log/kafka/kafka.log',
  $producer_type                  = 'async',
  $producer_batch_size            = 200)
{
  package { 'kafka': ensure => 'installed' }

  file { '/etc/kafka/log4j.properties':
    content => template('kafka/log4j.properties.erb'),
    require => Package['kafka'],
  }

  file { '/etc/kafka/producer.properties':
    content => template('kafka/producer.properties.erb'),
    require => Package['kafka'],
  }

  file { '/etc/kafka/consumer.properties':
    content => template('kafka/consumer.properties.erb'),
    require => Package['kafka'],
  }
}
