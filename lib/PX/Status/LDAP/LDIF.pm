#____________________________________________________________________ 
# File: LDIF.pm
#____________________________________________________________________ 
#  
# Author: Shaun ASHBY <Shaun.Ashby@gmail.com>
# Update: 2010-05-25 13:28:00+0200
# Revision: $Id$ 
#
# Copyright: 2010 (C) Shaun ASHBY
#
#--------------------------------------------------------------------
package PX::Status::LDAP::LDIF;

use strict;
use warnings;

use Carp qw(croak);
use Template;

use Pixelisation::Config qw(:all);

sub new() {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = (@_ == 0) ?             # Error if no params given
	croak("No params given.\n")
	: (ref($_[0]) eq 'HASH') ? shift
	: croak("Needs a parameter hash ref");
    if (!exists($self->{entries})) {	
	$self->{entries} = [];
    }
    
    $self->{data} = {
	entries => $self->{entries},
	basedn => $self->{basedn} || PX_DEFAULT_LDAP_BASEDN,
    };
    
    # TT config:
    $self->{tt} = Template->new(
	config => {
	    START_TAG => '[%',
	    END_TAG => '%]',
	    INCLUDE_PATH => $ENV{PX_TEMPLATE_PATH} || PX_TEMPLATE_PATH,
	});
    return bless($self,$class);
}

sub entries { return shift->{entries}; }

sub write() {
    my $self = shift;
    my $output = shift;
    $self->{tt}->process(\*DATA, $self->{data},$output) || die $self->{tt}->error();
}

1;

__DATA__
[% FOREACH entry IN entries %]
dn: cn=[% entry.cn %],ou=[% entry.ou %],[% basedn %]
changetype: modify
replace: [% entry.keyword %]
[% entry.keyword %]: [% entry.value %]

[% END %]
