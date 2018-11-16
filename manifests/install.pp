# == Class: thehive::install
#
# Ensure TheHive and Docker packages are present.
class thehive::install inherits thehive {
  package { 'thehive':
    ensure => present,
  }
}
