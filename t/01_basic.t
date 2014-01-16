use strict;
use warnings;
use Data::Dumper;

 
use Test::More tests => 5;
 
use_ok 'Win32::Tracert';

my $target_ip='127.0.0.1';

my $parse_result=Win32::Tracert::parse(Win32::Tracert::to_find($target_ip));

ok(ref($parse_result) eq 'HASH', 'Parsing return an HASH ref');

my $is_determined=Win32::Tracert::found($target_ip,$parse_result);

ok($is_determined, "Route to $target_ip determined");

ok(Win32::Tracert::hops($target_ip,$parse_result), "Nombre saut");


use_ok 'Win32::TracertOO';