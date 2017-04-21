# == Class: kibana5::proxy
#
class kibana5::proxy {

  class { 'nginx': }

  # Create password file
  httpauth { 'kibana':
    file      => '/etc/nginx/.htpasswd',
    password  => $kibana5::kibana_password,
    mechanism => basic,
    ensure    => present,
    notify    => Service['nginx'],
    require   => Class['nginx::config'],
  }

  # Set correct permissions on password file
  file { '/etc/nginx/.htpasswd':
    mode    => '0644',
    require => Httpauth['kibana']
  }

  # Create proxy
  nginx::resource::upstream { 'kibana':
    members => ['localhost:5601', ],
  }
  
  nginx::resource::vhost { 'kibana':
    proxy                => 'http://localhost:5601',
    auth_basic           => 'Restricted Content',
    auth_basic_user_file => '/etc/nginx/.htpasswd',
    require              => Httpauth['kibana']
  }
  
}
