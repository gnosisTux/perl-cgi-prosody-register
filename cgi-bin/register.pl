#!/bin/env perl

use Authen::Captcha;
use CGI;
use strict;
use warnings;
use utf8;
use Expect;
use CGI::Carp qw(fatalsToBrowser warningsToBrowser);

my $cgi = CGI->new;

my $usuario = $cgi->param('usuario');
my $dominio = $cgi->param('dominio');
my $password = $cgi->param('password');
my $password_check = $cgi->param('password_check');
my $captcha_input = $cgi->param('captcha');
my $token = $cgi->cookie('captcha_token');

my $error = '<!DOCTYPE html><html lang="es"><head><link rel="stylesheet" href="../styles.css"><meta charset="UTF-8"><title>Error</title></head><body>';
my $sucess = '<!DOCTYPE html><html lang="es"><head><link rel="stylesheet" href="../styles.css"><meta charset="UTF-8"><title>Success</title></head><body>';

do "../config.pl" or die $!;  # load config.pl
our @dominios;

unless ($usuario =~ /^[a-zA-Z0-9_\-\.\/ ]+$/) {
  print $cgi->header('text/html');
  print "$error<p style='color:red'>That username is not valid</p><body></html>";
  exit;
}

if (length($usuario) > 15) {
  print $cgi->header('text/html');
  print "$error<p style='color:red'>Usernames longer than 15 characters are not allowed</p><body></html>";
  exit;
}

if (length($password) > 50) {
  print $cgi->header('text/html');
  print "$error<p style='color:red'>Passwords longer than 50 characters are not allowed</p><body></html>";
  exit;
}

unless (grep {$_ eq $dominio } @dominios) {
  print $cgi->header('text/html');
  print "$error<p style='color:red'>That domain is not valid<body></html>";
  exit;
}

if($password_check ne $password) {
  print $cgi->header('text/html');
  print "$error<p style='color:red'>Passwords do not match</body></html>";
  exit;
}

my $captcha = Authen::Captcha->new(
    data_folder   => '../keys',
    output_folder => '../captcha',
);

my $result = $captcha->check_code($captcha_input, $token);

unless ($result == 1) {
  print $cgi->header('text/html');
  print "$error<p style='color:red'>Invalid or expired captcha. <bold>Reload the page to generate another<bold></p></body></html>";
  exit;  
}

my $jid = "$usuario\@$dominio";

my $exp = Expect->new;
$exp->log_stdout(0);
$exp->spawn("doas", "/usr/local/bin/prosodyctl", "adduser", "$jid")
    or die "could not spawn prosodyctl: $!";
$exp->expect(10,
    [ qr/Enter new password:/ => sub { $exp->send("$password\n"); exp_continue; } ],
    [ qr/Retype new password:/ => sub { $exp->send("$password\n"); exp_continue; } ],
);
my $salida = $exp->before();   
$exp->soft_close();

if ($salida =~ /User exists/i) {
  print $cgi->header('text/html');
  print "$error<p style='color:red'>A user with the JID: $jid already exists!</p></body></html>";
  exit;  
} 

if ($salida =~ /Created/i) {
  print $cgi->header('text/html');
  print "$sucess<p>Your account has been created successfully!</p><p style='color:yellow'>$jid<br></p><p style='color:yellow'>$password</p><br><p>To start using your XMPP account we recommend the client <a style='color:purple' href='https://gajim.org/'>Gajim</a> which is available on Mac, Linux, and Windows.</body></html>";
  exit;
}
