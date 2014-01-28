package Win32::Tracert;
use strict;
use warnings;
use Object::Tiny qw (destination circuit);
use Win32::Tracert::Parser;

# ABSTRACT: Call Win32 tracert tool or parse Win32 tracert output;
use Net::hostent;
use Socket;
use Data::Dumper;

#my @tracert_output;
my %tracert_result;
my $iptocheck;


sub _to_find{
    my $self=shift;
    my $hosttocheck=$self->destination;
    
    if ($hosttocheck =~ /(?:\d{1,3}\.){3}\d{1,3}/) {
        $iptocheck=$self->destination;
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
    
    #Executing tracert call before to send its result to Parser
    my @tracert_output=`tracert $hosttocheck`;
    return \@tracert_output;
}

sub to_trace{
    my $self=shift;
    my $result = defined $self->destination ? $self->_to_find : $self->circuit ;
    my $path=Win32::Tracert::Parser->new(input => $result);
    
    return $self, $path->to_parse;
}

sub has_found{
    my $self=shift;
    my $tracert_result=shift;
    
    my $hosttocheck;
    my $iptocheck;
    
    if (defined $self->destination) {
        $hosttocheck=$self->destination;
    }
    else{
        ($hosttocheck)=keys %{$tracert_result};
    }
    
    if ($hosttocheck =~ /(?:\d{1,3}\.){3}\d{1,3}/) {
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
    my $self=shift;
    my $tracert_result=shift;
    my $hosttocheck;
    my $iptocheck;
    
    if (defined $self->destination) {
        $hosttocheck=$self->destination;
    }
    else{
        ($hosttocheck)=keys %{$tracert_result};
    }
    
    if ($hosttocheck =~ /(?:\d{1,3}\.){3}\d{1,3}/) {
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

    return scalar(@{$tracert_result->{"$iptocheck"}->{'HOPS'}});
}


1;