package PIPE::Grep;
use strict;
use warnings;

use base 'PIPE::Skeleton';

sub init {
    my ($self, $expr) = @_;
    $self->_log("Receiving the grep expression: $expr");
    $self->{expr} = $expr;
    return $self;
}

sub run {
    my ($self, @input) = @_;

    $self->_log("The grep expression: $self->{expr}");
    if ("Regexp" eq ref $self->{expr}) {
        return grep /$self->{expr}/, @input;
    } else {
        my $sub = $self->{expr};
        return grep { $sub->($_) } @input;
    }
}

1;

