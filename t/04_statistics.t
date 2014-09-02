use strict;
use warnings;
use utf8;
use Data::Printer;

 
use Test::More tests => 8;

use_ok 'Win32::Tracert';

my $tracert_output="./t/trace_tracert.txt";
my $target='testmybadhost';

open my $th, '<:encoding(Windows-1252):crlf', "$tracert_output" or die "Impossible de lire le fichier $tracert_output\n";
my @trace_out=<$th>;
close $th;

my $route = Win32::Tracert->new(circuit => \@trace_out);
isa_ok($route,'Win32::Tracert');

$route->to_trace;

use Win32::Tracert::Statistics;

my $result;
my $number_of_excluded_values;
my $statistic=Win32::Tracert::Statistics->new(input => $route->path);
isa_ok($statistic,'Win32::Tracert::Statistics');

foreach my $packetsmp (qw (PACKET1_RT PACKET2_RT PACKET3_RT)){
    ($result,$number_of_excluded_values)=$statistic->average_responsetime_for("$packetsmp");
    eval {($result,$number_of_excluded_values)=$statistic->average_responsetime_for("$packetsmp")};
    ok( defined $result && defined $number_of_excluded_values, "$packetsmp: Average response time is $result for $number_of_excluded_values value(s) excluded");
}

($result,$number_of_excluded_values)=$statistic->average_responsetime_global;
is ($result,'56.9753086419753',"Global Average responsetime is correct");
is ($number_of_excluded_values,1, "Global Average excluded value is correct");