# == Function: kakfa_config(string cluster_name, hash|nil clusters, hash|array zookeeper_hosts)
#
# Reworks various variables to be in a format suitable for supplying them
# to the kafka module classes.
#

module Puppet::Parser::Functions
  newfunction(:kafka_config, :type => :rvalue, :arity => 3) do |args|
    cluster_name, clusters, zk_hosts = *args
    # nil is sometimes passed as 'undef' by Puppet, so get around this stupidity
    clusters = Hash.new unless clusters.kind_of?(Hash)
    zk_hosts = zk_hosts.keys.sort if zk_hosts.kind_of?(Hash)
    cluster = clusters[cluster_name] || {
      'brokers' => {
        lookupvar('fqdn').to_s => { 'id' => '1' }
      }
    }
    brokers = cluster['brokers']
    jmx_port = 9999
    conf = {
      'brokers'   => {
        'hash'     => brokers,
        'array'    => brokers.keys,
        'string'   => brokers.map { |host, port| "#{host}:#{port || 9092}" }.sort.join ',',
        'graphite' => brokers.keys.map { |b| "#{b.tr '.', '_'}_#{jmx_port}" }.join ',',
        'size'     => brokers.keys.size
      },
      'jmx_port'  => jmx_port,
      'zookeeper' => {
        'hosts'  => zk_hosts,
        'chroot' => "/kafka/#{cluster_name}",
        'url'    => "#{zk_hosts.join ','}/kafka/#{cluster_name}"
      }
    }
  end
end

