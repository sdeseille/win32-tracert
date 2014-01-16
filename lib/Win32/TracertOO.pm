package TracertOO;
use Object::Tiny qw (destination);
use strict;
use warnings;
use Net::hostent;
use Socket;

sub to_find{
    my $self=shift;
    my $hosttocheck=$self->destination;
    my $iptocheck;
    
    if ($hosttocheck =~ /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/) {
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
    
    my @tracert_output=`tracert $hosttocheck`;
    return \@tracert_output;
}

1;
