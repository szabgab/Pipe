package Pipe::Tube;
use strict;
use warnings;

use Pipe;

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
    Pipe->_log($msg, $self);
}



1;

