# == Class: thehive::service
#
# Enable TheHive package.
class thehive::service {
  require ::thehive::config

  service { 'thehive.service':
    enable   => true,
  }
}
