#!/usr/bin/perl
#
# Copyright (C) 2008 Aurelien Lefebvre <alefebvre@mandriva.com>
#
# Licensed under the GNU General Public License Version 2
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#

use strict;

use lib;
use File::Basename;

BEGIN {
  push @INC, dirname($0);
}

use urpm;
use urpm::args;
use urpm::media;
use urpmi_backend::tools;
use MDK::Common;

use perl_packagekit::prints;

# One argument (package ids)
$#ARGV > -1 or exit 1;

my $urpm = urpm->new_parse_cmdline;
urpm::media::configure($urpm);

my @pkgids = @ARGV;

foreach (@pkgids) {
  print_package_details($urpm, $_);
}

sub print_package_details {

  my ($urpm, $pkgid) = @_;
  
  my $pkg = get_package_by_package_id($urpm, $pkgid);
  $pkg or return;

  my $medium = pkg2medium($pkg, $urpm);
  my $xml_info = 'info';
  my $xml_info_file = urpm::media::any_xml_info($urpm, $medium, $xml_info, undef, undef);
  
  if(!$xml_info_file) {
    pk_print_details(get_package_id($pkg), "N/A", $pkg->group, "N/A", "N/A", 0);
    exit 0;
  }
  
  require urpm::xml_info;
  require urpm::xml_info_pkg;
  my $name = urpm_name($pkg);
  my %nodes = eval { urpm::xml_info::get_nodes($xml_info, $xml_info_file, [ $name ]) };
  my %xml_info_pkgs;
  put_in_hash($xml_info_pkgs{$name} ||= {}, $nodes{$name});
  my $description = $xml_info_pkgs{$name}{description};
  $description =~ s/\n/;/g;
  $description =~ s/\t/ /g;
  
  pk_print_details(get_package_id($pkg), "N/A", $pkg->group, ensure_utf8($description), "N/A", $pkg->size);
}

