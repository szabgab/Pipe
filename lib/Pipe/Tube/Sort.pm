package Pipe::Tube::Sort;
use strict;
use warnings;

use base 'Pipe::Tube';

our $VERSION = '0.04';

sub init {
    my ($self, $expr) = @_;
    $self->logger("Receiving the sort expression: '" . (defined $expr ? $expr : '') .  "'");
    $self->{expr} = $expr;
    $self->{data} = [];
    return $self;
}

sub run {
    my ($self, @input) = @_;
    push @{ $self->{data} }, @input;
    return;
}

sub finish {
    my ($self) = @_;
    $self->logger("The sort expression: " . (defined $self->{expr} ? $self->{expr} : ''));
    my $sub = $self->{expr};
    if (defined $sub) {
        return sort { $sub->($a, $b) } @{ $self->{data} };
    } else {
        return sort @{ $self->{data} };
    }
}

1;

