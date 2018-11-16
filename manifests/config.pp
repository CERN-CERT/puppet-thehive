# == Class: thehive::config
#
# Perform configuration for TheHive package. This adds the configuration file from
# templates, which is requried for starting the server.
class thehive::config inherits thehive {
  require ::thehive::install

  group { $thehive::group:
    ensure => 'present',
  }

  user { $thehive::user:
    ensure => 'present',
    gid    => $thehive::group,
  }

  file { $thehive::config_dir:
    ensure => directory,
    owner  => $thehive::user,
    group  => $thehive::group,
    mode   => '0550',
  }

  file { "${thehive::config_dir}/${thehive::config_file}":
    ensure  => file,
    content => template('thehive/application.erb'),
    owner   => $thehive::user,
    group   => $thehive::group,
    mode    => '0440',
  }

  sysctl { 'vm.max_map_count':
    val => $thehive::vm_max_map_count,
  }

  if $thehive::elasticsearch_enabled {
    contain ::thehive::elasticsearch::config
  }
}
