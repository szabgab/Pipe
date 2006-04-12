package PIPE::Chomp;
use strict;
use warnings;

use base 'PIPE::Skeleton';

sub run {
    my ($self, @input) = @_;
    chomp @input;
    return @input;
}

1;

