#!/bin/env perl

use Authen::Captcha;
use CGI;
use strict;
use warnings;

my $captcha_length = 8;

my $cgi = CGI->new;

my $captcha = Authen::Captcha->new(
  data_folder => '../captcha_tmp/keys',
  output_folder => '../captcha_tmp/captcha',
);

my $token = $captcha->generate_code($captcha_length);

my $cookie = $cgi->cookie(-name=>'captcha_token', -value=>$token, -path=>'/');
print $cgi->header(-type=>'image/png', -cookie=>$cookie);

my $imagePath = "../captcha_tmp/captcha/$token.png";
open my $img_fh, '<', $imagePath or die "Could not open $imagePath: $!";
binmode $img_fh;  # very important for binary files
my $image_data = do { local $/; <$img_fh> };
close $img_fh;

print $image_data;
print $cgi->header(-type => 'image/png', -charset => undef);
