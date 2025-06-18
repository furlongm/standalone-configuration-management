class locale {

  $locale = 'en_US.UTF-8'
  $timezone = 'America/New_York'

  $locale_package = $facts['os']['family'] ? {
    'Debian' => 'locales',
    'Fedora' => 'glibc-common',
    'RedHat' => 'glibc-common',
    'Suse'   => 'glibc-locale',
  }

  package { $locale_package:
    ensure => installed,
  }

  if $facts['os']['family'] == 'Debian' {
    file { '/etc/locale.gen':
      content => "${locale} UTF-8\n",
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
    }

    file { '/etc/environment':
      content => template('locale/environment.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
    }

    exec { 'locale-gen':
      command     => '/usr/sbin/locale-gen',
      refreshonly => true,
      subscribe   => File['/etc/locale.gen'],
    }
  }

  if $facts['containerized'] == 'false' {
    exec { 'set-locale':
      path    => '/usr/bin:/usr/sbin:/bin:/sbin',
      command => "localectl set-locale LANG=${locale}",
      unless  => "localectl status | grep ${locale}",
    }

    exec { 'set-timezone':
      path    => '/usr/bin:/usr/sbin:/bin:/sbin',
      command => "timedatectl set-timezone ${timezone}",
      unless  => "timedatectl status | grep ${timezone}"
    }
  }
}
