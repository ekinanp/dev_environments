class dev_environments::git(
  String $author_name = 'Enis Inan',
  String $username = 'ekinanp',
  String $email = 'enis.inan@puppet.com'
) {
  Exec {
    path => '/usr/bin:/usr/sbin:/bin'
  }

  package { 'git':
    ensure => installed
  }

  # Set-up the git config. file
  #  TODO: Maybe parametrize the user home directory? We're using root for now to make
  #  it easier
  $user_home = "/root"
  file { "${user_home}/.gitconfig":
    ensure  =>  present,
    content =>  template("dev_environments/git_config.erb"),
  }

  # TODO: Set-up ssh keys!
  $ssh_dir = "${user_home}/.ssh"
  $ssh_key_file = "${ssh_dir}/id_rsa"
  $ssh_public_key_file = "${ssh_key_file}.pub"

  $ssh_keygen_cmd = "ssh-keygen -t rsa -b 4096 -f ${ssh_key_file} -N '' -C ${email}"
  exec { "${ssh_keygen_cmd}":
    unless => "test -f ${ssh_key_file}"
  }

  $ssh_agent_file = "${ssh_dir}/ssh_agent_added_key"
  $ssh_agent_cmd = "bash -c 'eval `ssh-agent -s` && ssh-add -k ${ssh_key_file}' && touch ${ssh_agent_file}"
  exec { "${ssh_agent_cmd}":
    unless  => "test -f ${ssh_agent_file}",
    require => Exec[$ssh_keygen_cmd]
  }

  # Now add github.com as a known host. Hacky b/c known_hosts can exist but whatever. Who cares.
  # This is mostly for my personal use anyways.
  $ssh_known_hosts = "${ssh_dir}/known_hosts"
  $ssh_keyscan_cmd = "ssh-keyscan github.com >> ${ssh_known_hosts}"
  exec { "${ssh_keyscan_cmd}":
    unless  => "test -f ${ssh_known_hosts}",
    require => Exec[$ssh_agent_cmd],
  }

  # TODO: Now add this ssh key to your GitHub. Set the GITHUB_API_TOKEN as an env. variable on the machines.
  # This should probably be a simple API call.
  $ruby = "/opt/puppetlabs/puppet/bin/ruby"
  $script_path = "/tmp/set_github_ssh_key.rb"
  file { "${script_path}":
    ensure  => present,
    content => template("dev_environments/set_github_ssh_key.rb.erb"),
    mode    => "0777",
    require => Exec[$ssh_keyscan_cmd]
  }

  exec { "${ruby} ${script_path}":
    require => File[$script_path]
  }
}
