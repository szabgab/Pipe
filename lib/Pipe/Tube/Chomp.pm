package Pipe::Tube::Chomp;
use strict;
use warnings;

use base 'Pipe::Tube';

sub run {
    my ($self, @input) = @_;
    chomp @input;
    return @input;
}

1;

