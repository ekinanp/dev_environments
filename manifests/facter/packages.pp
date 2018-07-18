class facter::packages(
  String $branch
) {
  # Install the EPEL-release RPM (needed to install yaml-cpp)
  if $::operatingsystem == 'CentOS' {
    package { "epel-release-7":
      ensure   => installed,
      provider =>  'rpm',
      source   => "https://dl.fedoraproject.org/pub/epel/epel-release-latest-${operatingsystemmajrelease}.noarch.rpm",
      before   => Package["yaml-cpp-devel"]
    }
  }
 
  case $::operatingsystem {
    'CentOS': {
      $reqd_packages = [ 'boost-devel', 'openssl-devel', 'yaml-cpp-devel', 'libblkid-devel', 'libcurl-devel', 'gcc-c++', 'make', 'tar', 'cmake3', 'vim' ]
    }
  }
 
  # Install the base packages
  package { $reqd_packages:
    ensure   => installed
  }
 
  # Create symlink for cmake => cmake3 for Centos platforms
  if $::operatingsystem == "CentOS" {
    file { "/usr/bin/cmake":
      ensure  => "link",
      target  => "/usr/bin/cmake3",
      require =>  Package["cmake3"]
    }
  }
}
