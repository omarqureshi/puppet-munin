# host.pp - the master host of the munin installation
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

class munin::host inherits munin
{
    package {"munin": ensure => installed, }

    File <<| tag == 'munin' |>>

    file{'/etc/munin/munin.conf.header':
        source => [ "puppet:///modules/site-munin/config/host/${hostname}/munin.conf.header",
                    "puppet:///modules/site-munin/config/host/munin.conf.header.$operatingsystem",
                    "puppet:///modules/site-munin/config/host/munin.conf.header",
                    "puppet:///modules/munin/config/host/munin.conf.header.$operatingsystem",
                    "puppet:///modules/munin/config/host/munin.conf.header" ],
        notify => Exec['concat_/etc/munin/munin.conf'],
        owner => root, group => 0, mode => 0644;
    }

    concatenated_file { "/etc/munin/munin.conf":
        dir => '/var/lib/puppet/modules/munin/nodes',
        header => "/etc/munin/munin.conf.header",
    }

    include munin::plugins::muninhost

    if $munin_do_cgi_graphing {
        include munin::host::cgi
    }

  # from time to time we cleanup hanging munin-runs
  file{'/etc/cron.d/munin_kill':
    content => "4,34 * * * * root if $(ps ax | grep -v grep | grep -q munin-run); then killall munin-run; fi\n",
    owner => root, group => 0, mode => 0644;
  }
  if $use_shorewall {
    include shorewall::rules::out::munin
  }
}
