use strict;
use warnings;
use Data::Printer;
use utf8;


 
use Test::More tests => 6;

use_ok 'Win32::Tracert';

my $tracert_output="./t/incomplete_trace_tracert.txt";
my $target='testmybadhost';

open my $th, '<:encoding(Windows-1252):crlf', "$tracert_output" or die "Impossible de lire le fichier $tracert_output\n";
my @trace_out=<$th>;
close $th;

eval {my $route = Win32::Tracert->new(circuit => \@trace_out, destination => "$target")};
ok(defined $@, 'Yes constructor die if you set circuit and destination together');

my $route = Win32::Tracert->new(destination => "$target");
eval {$route->to_trace};
ok(defined $@, "[$@]");

$route = Win32::Tracert->new(circuit => \@trace_out);
ok(! defined $route->to_trace->found, 'Route undetermined');

@trace_out=();
eval {my $route = Win32::Tracert->new(circuit => \@trace_out)};
ok(defined $@, 'Yes constructor die if [circuit] attribute is empty');

@trace_out=undef;
eval {my $route = Win32::Tracert->new(circuit => \@trace_out)};
ok(defined $@, 'Yes constructor die if [circuit] attribute is undefined');