package PIPE::Uniq;
use strict;
use warnings;

use base 'PIPE::Skeleton';

sub run {
    my ($self, @input) = @_;

    my @result;
    foreach my $v (@input) {
        next if defined $self->{last} and $self->{last} eq $v;

        $self->{last} = $v;
        push @result, $v;
    }
    return @result;
}


1;



