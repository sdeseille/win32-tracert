use strict;
use warnings;
use Data::Dumper;

 
use Test::More tests => 3;

my $target_ip='127.0.0.1';

use_ok 'Win32::Tracert';
my $route = Win32::Tracert->new(destination => "$target_ip");
#print Dumper $route->to_find->parse;

$target_ip='10.0.0.2';
my $route2 = Win32::Tracert->new(destination => "$target_ip");

ok($route->to_find->parse->found,"Is route Found");
print "call method: ",$route->destination,"\n";

my $route3 = Win32::Tracert->new(destination => "buggy");
$route3->to_find;

ok($route2->to_find->parse->found,"Is route Found");

