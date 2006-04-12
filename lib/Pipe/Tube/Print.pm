package Pipe::Tube::Print;
use strict;
use warnings;

use base 'Pipe::Tube';

sub add {
    my ($self, $file) = @_;
    # file can be either undef -> STDOUT or a filehandle, or a filename -> print into that file,
    open my $fh, ">", $file or dir $!;
    $self->{fh} = $fh;
    push @{ $self->{PIPES} }, "_out";

    $self->do;
    #return $self;
}

sub call {
    my ($self, $line) = @_;
    my $fh = $self->{fh};
    print $fh $line;
}


1;

