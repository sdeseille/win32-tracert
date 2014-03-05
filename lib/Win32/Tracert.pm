package Win32::Tracert;
use strict;
use warnings;

use Net::hostent;
use Socket qw ();
use Object::Tiny qw (destination circuit);
use Win32::Tracert::Parser;

# ABSTRACT: Call Win32 tracert tool or parse Win32 tracert output;

my %tracert_result;

sub path {
    my ($self,$value)=@_;
    if (@_ == 2) {
        $self->{path}=$value;
    }
    
    return $self->{path};
}

sub _destination_hostname{
    my ($self,$value)=@_;
    if (@_ == 2) {
        $self->{_destination_hostname}=$value;
    }
    
    return $self->{_destination_hostname};
}

sub destination_hostname{
    my $self=shift;
    return $self->_destination_hostname;
}

sub _destination_ip{
    my ($self,$value)=@_;
    if (@_ == 2) {
        $self->{_destination_ip}=$value;
    }
    
    return $self->{_destination_ip};
}

sub destination_ip{
    my $self=shift;
    return $self->_destination_ip;
}

sub _to_find{
    my $self=shift;
    my $hosttocheck=$self->destination;
    my $iptocheck;
    
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

sub _get_target_ip{
    my $self=shift;
    my $hosttocheck=shift;
    my $iptocheck;
    
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
    
    return $iptocheck;
}

sub to_trace{
    my $self=shift;
    my $result = defined $self->destination ? $self->_to_find : $self->circuit ;
    my $path=Win32::Tracert::Parser->new(input => $result);
    
    #put returned result from [to_parse] method in current [path] attribute
    $self->path($path->to_parse);
    
    return $self;
}

sub found{
    my $self=shift;
    my $tracert_result=$self->path();
    
    my $hosttocheck;
    my $iptocheck;
    
    if (defined $self->destination) {
        $hosttocheck=$self->destination;
    }
    else{
        ($hosttocheck)=keys %{$tracert_result};
    }
    
    $iptocheck=$self->_get_target_ip($hosttocheck);
    
    if (exists $tracert_result->{"$iptocheck"}) {
        if ("$iptocheck" eq $tracert_result->{"$iptocheck"}->{'HOPS'}->[-1]->{'IPADRESS'}) {
            #If we find path to destination we can initialise following private writable attributes 
            $self->_destination_ip($tracert_result->{"$iptocheck"}->{'HOPS'}->[-1]->{'IPADRESS'});
            $self->_destination_hostname($tracert_result->{"$iptocheck"}->{'HOPS'}->[-1]->{'HOSTNAME'});
            
            return $self;
        }
        else{
            #route to target undetermined
            return undef;
        }
    }
    else{
        die "No traceroute result for $hosttocheck\n";
    }
}

sub hops{
    my $self=shift;
    my $tracert_result=$self->path();
    my $hosttocheck;
    my $iptocheck;
    
    if (defined $self->destination) {
        $hosttocheck=$self->destination;
    }
    else{
        ($hosttocheck)=keys %{$tracert_result};
    }
    $iptocheck=$self->_get_target_ip($hosttocheck);

    return scalar(@{$tracert_result->{"$iptocheck"}->{'HOPS'}});
}


1;

=head1 SYNOPSIS

use Win32::Tracert;

my $target = "127.0.0.1";
my $route = Win32::Tracert->new(destination => "$target");

my $path = $route->to_trace;

if ($route->found){
    my $hops = $route->hops;
    if($hops >= 1) {
        print "I got it\n"
    }
}

=method method_x

This method does something experimental.

=method method_y

This method returns a reason.

=head1 SEE ALSO

=for :list

* L<Win32::Tracert::Parser>
