# == Class kafka::server
# Sets up a Kafka Broker Server and ensures that it is running.
#
# == Parameters:
# $broker_id                                 - Unique integer ID of this broker.  Default: uses numbers extracted from the node's hostname
# $data_dir                                  - Directory in which the broker will store its received log event data. (This is log.dir in server.properties).  Default: /var/lib/kafka/data
# $port                                      - Broker listen port.  Default: 9092
# $num_threads                               - The number of processor threads the socket server uses for receiving and answering requests.  Default: # of cores
# $num_partitions                            - The number of logical event partitions per topic per server.  Default: 1
# $socket_send_buffer                        - The byte size of the send buffer (SO_SNDBUF) used by the socket server,  Default: 1048576
# $socket_receive_buffer                     - The byte size of receive buffer (SO_RCVBUF) used by the socket server.  Default: 1048576
# $max_socket_request_bytes                  - The maximum size of a request that the socket server will accept.  Default: 104857600
# $log_flush_interval                        - The number of messages to accept before forcing a flush of data to disk.  Default 10000
# $log_default_flush_scheduler_interval_ms   - The maximum amount of time a message can sit in a log before we force a flush: Default 1000 (1 second)
# $log_retention_hours                       - The minimum age of a log file to be eligible for deletion.  Default 1 week.
# $log_retention_size                        - A size-based retention policy for logs.  Default: -1 (disabled)
# $log_file_size                             - The maximum size of a log segment file. When this size is reached a new log segment will be created:  Default 536870912 (512MB)
# $log_cleanup_interval_mins                 - The interval at which log segments are checked to see if they can be deleted according to the retention policies.  Default: 1
#
class kafka::server(
  $broker_id                               = undef,
  $data_dir                                = '/var/lib/kafka/data',
  $port                                    = 9092,
  $num_threads                             = undef,
  $num_partitions                          = 1,
  $socket_send_buffer                      = 1048576,
  $socket_receive_buffer                   = 1048576,
  $max_socket_request_bytes                = 104857600,
  $log_flush_interval                      = 10000,
  $log_default_flush_interval_ms           = 1000,
  $log_default_flush_scheduler_interval_ms = 1000,
  $log_retention_hours                     = 168, # 1 week
  $log_retention_size                      = -1,
  $log_file_size                           = 536870912,
  $log_cleanup_interval_mins               = 1)
{
  # kafka class must be included before kafka::servver
  Class['kafka'] -> Class['kafka::server']

  # Infer the $brokerid from numbers in the hostname
  # if is not manually passed in as $broker_id
  $brokerid = $broker_id ? {
    undef   => inline_template('<%= hostname.gsub(/[^\d]/, "").to_i %>'),
    default => $broker_id
  }

  # define local variables from kafka class for use in ERb template.
  $zookeeper_hosts                = $kafka::zookeeper_hosts
  $zookeeper_connectiontimeout_ms = $kafka::zookeeper_connectiontimeout_ms

  file { '/etc/kafka/server.properties':
    content => template('kafka/server.properties.erb'),
  }

  file { $data_dir:
    ensure  => 'directory',
    owner   => 'kafka',
    group   => 'kafka',
    mode    => '0755',
  }

  # Start the Kafka server.
  # We don't want to subscribe to the config files here.
  # It will be better to manually restart Kafka when
  # the config files changes.
  service { 'kafka':
    ensure     => running,
    require    => [File['/etc/kafka/server.properties'], File[$data_dir]],
    provider   => 'upstart',
  }
}
