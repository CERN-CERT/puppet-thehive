# == Class: thehive::service
#
# Enable TheHive package.
class thehive::service {
  require ::thehive::config

  service { 'thehive.service':
    ensure => running,
    enable => true,
  }
}
