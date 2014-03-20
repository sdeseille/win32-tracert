use strict;
use warnings;
use utf8;


 
use Test::More tests => 4;

my $target='127.0.0.1';

use_ok 'Win32::Tracert';

my $route = Win32::Tracert->new(destination => "$target");

$route->to_trace;

ok($route->found(),"Is route Found");

is ($route->hops(),1,"Hops number to reach destination");

is ($route->to_trace->found->hops,1,"Chained methods call in order to find number of Hops to reach destination");