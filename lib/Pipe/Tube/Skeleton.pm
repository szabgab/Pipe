package PIPE::Skeleton;
use strict;
use warnings;

use PIPE;

sub new {
    my ($class, $pipe, @args) = @_;

    my $self = bless {}, $class;
    $self->{pipe} = $pipe;
    $self->init(@args);
}

# methods to be implemnetd in subclass:
sub init {
    return $_[0];
}

sub run {
    return;
}

sub finish {
    return;
}

sub _log {
    my ($self, $msg) = @_;
    PIPE->_log($msg, $self);
}



1;

