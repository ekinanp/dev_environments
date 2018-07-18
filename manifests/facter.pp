class dev_environments::facter(
  String $branch,
  String $dir = '/root'
) {
  # TODO:
  #  (X) Install the packages
  #  () Set-up the git configuration (scripts can export an env. variable for my GitHub token for security to the VMs)
  #  () Clone each of the PA components leatherman, cpp-hocon then build them
  #  () Clone the facter repo and don't do anything else.
  class { 'facter::packages':
    branch => $branch
  }
}
