class git(
  String $name = 'Enis Inan'
  String $username = 'ekinanp',
  String $email = 'enis.inan@puppet.com'
) {
  package { 'git':
    ensure => installed
  }

  # Set-up the git config. file
  #  TODO: Maybe parametrize the user home directory? We're using root for now to make
  #  it easier
  $user_home = "/root"
  file { "${home_dir}/.gitconfig":
    ensure  =>  present,
    content =>  template("dev_environments/git_config.erb"),
  }

  # TODO: Set-up ssh keys!
  $ssh_dir = "${user_home}/.ssh"
  $ssh_key_file = "${ssh_dir}/id_rsa"

  $ssh_keygen_cmd = "ssh-keygen -t rsa -b 4096 -f ${ssh_key_file} -N '' -C ${email}"
  exec { "${ssh_keygen_cmd}":
    unless => "test -f ${ssh_key_file}"
  }

  $ssh_agent_file = "${ssh_dir}/ssh_agent_added_key"
  $ssh_agent_cmd = "eval '$(ssh-agent -s)' && ssh-add -k ${ssh_key_file} && touch ${ssh_agent_file}"
  exec { "${ssh_agent_cmd}":
    unless  => "test -f ${ssh_agent_file}",
    require => Exec[$ssh_keygen_cmd]
  }

  # TODO: Now add this ssh key to your GitHub. Set the GITHUB_API_TOKEN as an env. variable on the machines.
  # This should probably be a simple API call.
}
