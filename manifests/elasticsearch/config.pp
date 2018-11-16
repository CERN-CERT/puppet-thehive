# == Class: thehive::elasticsearch::config
#
# Perform configuration for TheHive package. This involves creating the ElasticSearch container using Docker.
class thehive::elasticsearch::config inherits thehive {
  require ::docker
  # Ensure the directory is present and the owner is TheHive.
  # Required for ElasticSearch to create the node structure.
  file { [$thehive::elasticsearch_docker_volume_path_parent,
          $thehive::elasticsearch_docker_volume_path]:
    ensure => directory,
    owner  => $thehive::user,
    group  => $thehive::group,
    mode   => '0660',
  }

  docker::image { $thehive::elasticsearch_docker_image: }

  docker::run { 'elasticsearch':
    hostname => 'elasticsearch',
    username => "${thehive::elasticsearch_uid}:${thehive::elasticsearch_uid}",
    image    => $thehive::elasticsearch_docker_image,
    ports    => ['127.0.0.1:9200:9200', "${thehive::elasticsearch_host_address}:\
${thehive::elasticsearch_host_port}:${thehive::elasticsearch_host_port}"],
    volumes  => "${thehive::elasticsearch_docker_volume_name}:${thehive::elasticsearch_docker_volume_path}",
    env      => ["http.host=${thehive::elasticsearch_transport_host_address}",
                  "transport.host=${thehive::elasticsearch_transport_host_address}",
                  "xpack.security.enabled=${thehive::elasticsearch_xpack_enabled}",
                  "cluster.name=${thehive::elasticsearch_cluster_name}",
                  "thread_pool.search.queue_size=${thehive::elasticsearch_thread_pool_search_queue_size}"],
    require  => [File[$thehive::elasticsearch_docker_volume_path],
                  Docker::Image[$thehive::elasticsearch_docker_image]],
  }
}
