package Pipe::Tube::Chomp;
use strict;
use warnings;

use base 'Pipe::Tube';

our $VERSION = '0.04';

sub run {
    my ($self, @input) = @_;
    chomp @input;
    return @input;
}

1;

