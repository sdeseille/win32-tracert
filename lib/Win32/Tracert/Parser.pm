package Win32::Tracert;
use strict;
use warnings;

# ABSTRACT: Call Win32 tracert tool or parse Win32 tracert output;
use Net::hostent;
use Socket;
use Data::Dumper;

sub to_find{
    my $hosttocheck=shift;
    die "Bad format $hosttocheck\n" unless $hosttocheck =~ /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/;
    my @tracert_output=`tracert $hosttocheck`;
    return \@tracert_output;
}

sub found{
    my $hosttocheck=shift;
    my $tracert_result=shift;
    my $iptocheck;
    if ($hosttocheck =~ /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/) {
        $iptocheck=$hosttocheck;
    }
    else{
        my $h;
        my $ipadress;
        if ($h = gethost($hosttocheck)){
            $ipadress = inet_ntoa($h->addr);
            $iptocheck=$ipadress;
        }
        else{
            die "$0: no such host: $hosttocheck\n";
        }
    }
    
    if (exists $tracert_result->{"$iptocheck"}) {
        if ("$iptocheck" eq $tracert_result->{"$iptocheck"}->{'HOPS'}->[-1]->{'IPADRESS'}) {
            #I found it
            return 1;
        }
        else{
            #route to target undetermined
            return 0;
        }
    }
    else{
        die "No traceroute result for $hosttocheck\n";
    }    
}

sub hops{
    my $iptocheck=shift;
    my $tracert_result=shift;
    print "nombre de saut(s): ",scalar(@{$tracert_result->{"$iptocheck"}->{'HOPS'}}),"\n";
    return scalar(@{$tracert_result->{"$iptocheck"}->{'HOPS'}});
}

sub parse{
    my $arg=shift;
    _parse($arg);
}

sub _parse{
    my $tracert_outpout=shift;
    die "Attending ARRAY REF and got something else ! \n" unless ref($tracert_outpout) eq "ARRAY";
    
    my $tracert_result={};
    my $host_targeted;
    my $ip_targeted;

    LINE:
    foreach my $curline (@{$tracert_outpout}){
        #remove empty line
        next LINE if $curline =~ /^$/;
        next LINE if "$curline" !~ /(\w|\d)+/;
        
        #We looking for the target (NB: It is only sure with IP V4 Adress )
        #If we have DNS solving we record hostname and IP Adress
        #Else we keep only IP Adress
        if ($curline =~ /^\S+.*\[\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\]/) {
            ($host_targeted,$ip_targeted)=(split(/\s/, $curline))[-2..-1];
            $ip_targeted =~ s/(\[|\])//g;
            chomp $ip_targeted;
            #Data Structure initalization with first results
            $tracert_result->{"$ip_targeted"}={'IPADRESS' => "$ip_targeted", 'HOSTNAME' => "$host_targeted", 'HOPS' => []};
            next LINE;
        }
        elsif($curline =~ /^\S+.*\s\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\s/){
            $ip_targeted = $curline;
            $ip_targeted =~ s/.*?(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}).*$/$1/;
            chomp $ip_targeted;
            #Data Structure initalization with first results
            $tracert_result->{"$ip_targeted"}={'IPADRESS' => "$ip_targeted", 'HOPS' => []};
            next LINE;
        }
        
        #Working on HOPS to reach Target
        if ($curline =~ /^\s+\d+\s+(?:\*|\<1|\d+)\sms\s+(?:\*|\<1|\d+)\sms\s+(?:\*|\<1|\d+)\sms\s+.*$/) {
            my $hop_ip;
            my $hop_host="NA";
            #We split Hop result to create and feed our data structure
            my (undef, $hopnb, $p1_rt, $p1_ut, $p2_rt, $p2_ut, $p3_rt, $p3_ut, $hop_identity) = split(/\s+/,$curline,9);
            #If we have hostname and IP Adress we keep all else we have only IP Adress to keep
            if ($hop_identity =~ /.*\[\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\]/) {
                $hop_identity =~ s/(\[|\])//g;
                ($hop_host,$hop_ip)=split(/\s+/, $hop_identity);
            }
            elsif($hop_identity =~ /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/){
                $hop_ip=$hop_identity;
                $hop_ip =~ s/\s//g;
            }
            else{
                die "Bad format $hop_identity\n";
            }
            #Cleaning IP data to be sure not to have carriage return
            chomp $hop_ip;
            
            #We store our data across hashtable reference
            my $hop_data={'HOPID' => $hopnb,
                          'HOSTNAME' => $hop_host,
                          'IPADRESS' => $hop_ip,
                          'PACKET1_RT' => $p1_rt,
                          'PACKET2_RT' => $p2_rt,
                          'PACKET3_RT' => $p3_rt,
                           };
            #Each data record is store to table in ascending order 
            push $tracert_result->{"$ip_targeted"}->{'HOPS'}, $hop_data;
            next LINE;
        }
    }
    return $tracert_result;
}

1;