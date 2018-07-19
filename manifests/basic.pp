class dev_environments::basic {
  package { 'vim':
    ensure => installed
  }

  include dev_environments::git
}
