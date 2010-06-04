#!/opt/loca/bin/perl
#____________________________________________________________________ 
# File: test.pl
#____________________________________________________________________ 
#  
# Author: Shaun ASHBY <Shaun.Ashby@gmail.com>
# Update: 2010-06-04 14:02:57+0200
# Revision: $Id$ 
#
# Copyright: 2010 (C) Shaun ASHBY
#
#--------------------------------------------------------------------
use strict;
use warnings;
use Pixelisation::Config qw(:all);

use PX::Status::LDAP::Entry;
use PX::Status::LDAP::LDIF;

my $entries = [];

map {
    push(@$entries, PX::Status::LDAP::Entry->new({ cn => $_, ou => 'ISGRI', keyword => 'dsComplete', value => 'TRUE' }));
} qw( 0001 0002 0003);

my $ldif = PX::Status::LDAP::LDIF->new( { entries => $entries });

# Write to a variable:
my $var = '';
$ldif->write(\$var);

print "\n".$var."\n";
