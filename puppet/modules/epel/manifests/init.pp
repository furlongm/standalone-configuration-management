class epel {

  if $::osfamily == 'RedHat' {

    file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => 'puppet:///modules/epel/RPM-GPG-KEY-EPEL-7',
    }

    $epel_release_uri = $::operatingsystem ? {
      'CentOS' => 'epel-release',
      default  => 'https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm',
    }

    package { $epel_release_uri:
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
