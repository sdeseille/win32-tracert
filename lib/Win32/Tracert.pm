package Win32::Tracert;
use strict;
use warnings;

use Net::hostent;
use Socket qw ();
use Object::Tiny qw (destination circuit);
use Win32::Tracert::Parser;

# ABSTRACT: Call Win32 tracert tool or parse Win32 tracert output

my %tracert_result;

#redefine constuctor
sub new {
    my $class = shift;
    my $self  = $class->SUPER::new( @_ );
    # Extra checking and such
    die "You must define [destination] attribute or [circuit] attribute" if ((! defined $self->destination) && (! defined $self->circuit));
    die "constructor can't accept [circuit] and [destination] together" if ((defined $self->circuit) && (defined $self->destination));
    die "Attribute [circuit] have to contain a Tracert result" if ((! defined $self->destination) && (scalar(@{$self->circuit}) == 0));
    die "Attribute [destination] have to contain a hostname or IP address" if ((! defined $self->circuit) && ($self->destination eq ""));
    
    return $self;
}



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
            die "No such host: $hosttocheck\n";
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
            die "No such host: $hosttocheck\n";
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

=encoding utf8

=head1 SYNOPSIS

    use Win32::Tracert;

    my $target = "127.0.0.1";
    my $route = Win32::Tracert->new(destination => "$target");
    
    if ($route->to_trace->found){
        my $hops_value=$route->hops;
        if($hops_value >= 1) {
            print $route->destination_ip,"\n";
            print $route->destination_hostname,"\n";
            print "I got it\n";
        }
    }
    
=head2 Attributes
    
=over 1

=item *circuit

This attribute is used as argument before creating object.
It contain the result of tracert output slurp from file.
The result must be in array and dereferenced

=item *destination

This attribute is used as argument before creating object.
It containt IP adress or Hostname used by tracert to
trace the path.

=back

=method path

This method is a mutator. It set its value if you pass an argument to it.
Otherwise it return its current value like a standard get method.
Path is call and set in S<to_trace> method. 

=method destination_hostname

This method returns the destination hostname.
This information is defined if a route is found to destination.

=method destination_ip

This method returns the destination ip address.
This information is defined if a route is found to destination.

=method to_trace

This method create a Win32::Tracert::Parser object from S<destination> or  S<circuit> attribute.
it set S<path> attribute with the value return by S<to_parse> method from Win32::Tracert::Parser object 

=method found

This method check from tracert result if we reach the target destination.

=method hops

This method returns number of hops followed by tracert to reach destination.
Value returned is a scalar.

=head1 SEE ALSO

=for :list

* L<Win32::Tracert::Parser>
