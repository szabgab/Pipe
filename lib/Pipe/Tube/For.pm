package Pipe::Tube::For;
use strict;
use warnings;

use base 'Pipe::Tube';

sub init {
    my ($self, @values) = @_;
    $self->_log("Receiving values for for loop: " .  join "|", @values);
    $self->{data} = \@values;
    return $self;
}

sub run {
    my ($self) = @_;
    $self->_log("Current values in for loop: " .  join "|", @{ $self->{data} });
    return @{ $self->{data}} ?  shift @{ $self->{data} } : ();
}

1;

