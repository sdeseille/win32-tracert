use strict;
use warnings;

 
use Test::More tests => 7;

use_ok 'Win32::Tracert';

my $route = new_ok('Win32::Tracert');

can_ok($route,'to_trace');

can_ok($route,'found');

can_ok($route,'hops');

can_ok($route,'path');

my $parser_object=new_ok('Win32::Tracert::Parser');