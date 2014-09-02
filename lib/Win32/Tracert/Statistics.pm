package Win32::Tracert::Statistics;

use strict;
use warnings;

use Object::Tiny qw (input);

# ABSTRACT: Permit access to some statistics from determined Win32::Tracert path

#redefine constuctor
sub new {
    my $class = shift;
    my $self  = $class->SUPER::new( @_ );
    # Extra checking and such
    die "You must define [input] attribute" if (! defined $self->input);
    die "Attending HASH REF and got something else ! \n" unless ref($self->input) eq "HASH";
    
    return $self;
}

sub average_responsetime_for{
    my ($self,$packet_sample)=@_;
    
    foreach my $ipaddress (keys %{$self->input}){
        my %responsetime_sample=map {$_->{HOPID} => _rounding_value_to_1($_->{$packet_sample})} @{$self->input->{$ipaddress}{HOPS}};
        my @initial_responsetime_values=_list_responsetime_values(\%responsetime_sample);
        my @filtered_responsetime_values=_exclude_star_value(@initial_responsetime_values);
        my $sum_responsetime=0;
        map { $sum_responsetime+=$_ } @filtered_responsetime_values;
        my $average_responsetime=_average_responsetime($sum_responsetime,scalar @filtered_responsetime_values);
        my $number_of_excluded_values=_responsetime_values_excluded(scalar @initial_responsetime_values, scalar @filtered_responsetime_values);
        
        return $average_responsetime, $number_of_excluded_values;
    }
}

sub average_responsetime_global{
    my ($self)=@_;
    my %result;
    foreach my $packetsmp ($self->list_packet_samples){
        my ($result,$number_of_excluded_values)=$self->average_responsetime_for("$packetsmp");
        $result{$packetsmp}=[$result,$number_of_excluded_values];
    }
    my $total_sample=scalar $self->list_packet_samples;
    my $sum_responsetime=0;
    my $sum_of_excluded_values=0;
    map { $sum_responsetime+=$_->[0], $sum_of_excluded_values+=$_->[1] } values %result;
    my $average_responsetime=_average_responsetime($sum_responsetime,$total_sample);
    my $average_number_of_excluded_values=$sum_of_excluded_values / $total_sample;
    
    return $average_responsetime, $average_number_of_excluded_values;
}    

sub list_packet_samples{
    my ($self)=@_;
    my ($ipaddress) = keys %{$self->input};
    my @packetsmp_list=grep {$_ =~ /PACKET/} keys %{$self->input->{$ipaddress}{HOPS}[0]};
    return @packetsmp_list;
}

sub _list_responsetime_values{
    my $responsetime_hashref=shift;
    return values %$responsetime_hashref;
}

sub _exclude_star_value{
    my @values_to_check=@_;
    return grep {$_ ne '*'} @values_to_check;
}

sub _rounding_value_to_1{
    my $value=shift;
    my $rounded_value = $value eq '<1' ? 1 : $value;
    return $rounded_value;
}

sub _average_responsetime{
    my ($sum_of_values,$number_of_values)=@_;
    return $sum_of_values / $number_of_values;
}

sub _responsetime_values_excluded{
    my ($initial_values,$filtered_values)=@_;
    return $initial_values - $filtered_values;
}

1;