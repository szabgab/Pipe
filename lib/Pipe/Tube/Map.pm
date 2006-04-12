package Pipe::Tube::Map;
use strict;
use warnings;

use base 'Pipe::Tube';

sub init {
    my ($self, $expr) = @_;
    $self->_log("Receiving the map expression: $expr");
    $self->{expr} = $expr;
    return $self;
}

sub run {
    my ($self, @input) = @_;

    $self->_log("The map expression: $self->{expr}");
    if ("Regexp" eq ref $self->{expr}) {
        return map /$self->{expr}/, @input;
    } else {
        my $sub = $self->{expr};
        return map { $sub->($_) } @input;
    }
}

1;

