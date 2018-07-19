define dev_environments::git::repo(
  String $url,
  String $dir,
  String $branch
) {
  Exec {
    path => '/usr/bin:/usr/sbin:/bin'
  }

  $git_clone_title = "Clone ${title} repo"
  exec { $git_clone_title : 
    command => "git clone ${url}",
    unless  => "test -d ${dir}"
  }

  $git_create_branch_title = "Create ${branch} for ${title} repo"
  exec { $git_create_branch_title :
    command => "git checkout -b ${branch} origin/${branch}",
    cwd     => $dir,
    unless  => "git rev-parse --verify ${branch}",
    require => Exec[$git_clone_title]
  }

  exec { "Checkout ${branch} for ${title} repo" :
    command => "git checkout ${branch}",
    cwd     => $dir,
    require => Exec[$git_create_branch_title]
  }
}
