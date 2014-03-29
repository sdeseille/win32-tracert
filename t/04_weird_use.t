use strict;
use warnings;
use utf8;


 
use Test::More tests => 7;

use_ok 'Win32::Tracert';

my $tracert_output="./t/incomplete_trace_tracert.txt";
my $target='testmybadhost';

open my $th, '<:encoding(Windows-1252):crlf', "$tracert_output" or die "Impossible de lire le fichier $tracert_output\n";
my @trace_out=<$th>;
close $th;

eval {my $route = Win32::Tracert->new(circuit => \@trace_out, destination => "$target")};
ok(defined $@, "Yes ! Constructor die if you set [circuit] and [destination] together");

eval {my $route2 = Win32::Tracert->new()};
ok(defined $@, "Yes ! Constructor die if you don't set [circuit] or [destination]");

my @trace_empty=();
eval {my $route3 = Win32::Tracert->new(circuit => \@trace_empty)};
ok(defined $@, "Yes ! Constructor die if [circuit] attribute is empty");

my $target_empty='';
eval {my $route3 = Win32::Tracert->new(destination => "$target_empty")};
ok(defined $@, "Yes ! Constructor die if [destination] attribute is empty");


my $route = Win32::Tracert->new(destination => "$target");
eval {$route->to_trace};
ok(defined $@, "Yes ! Host $target doesn't exist");


my $route2 = Win32::Tracert->new(circuit => \@trace_out);
ok(! defined $route2->to_trace->found, 'Yes ! Route undetermined');

