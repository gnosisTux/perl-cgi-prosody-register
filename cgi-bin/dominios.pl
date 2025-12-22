#!/usr/bin/perl
use strict;
use warnings;
use CGI qw(:standard);

print header(-type => 'text/html; charset=UTF-8');

do "../config.pl" or die $!;  # carga config.pl
our @dominios;

foreach my $d (@dominios) {
    print qq{<option value="$d">$d</option>\n};
}
