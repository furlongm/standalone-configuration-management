class epel {

  if $::osfamily == 'RedHat' {

    file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => 'puppet:///modules/epel/RPM-GPG-KEY-EPEL-7',
    }

    package { 'epel-release':
      ensure  => installed,
      require => File['/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7'],
      notify  => Exec['yum_makecache'],
    }

    exec { 'yum_makecache':
      command     => '/bin/yum -y makecache',
      refreshonly => true,
    }
  }
}
