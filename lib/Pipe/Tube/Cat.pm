package Pipe::Tube::Cat;
use strict;
use warnings;

use base 'Pipe::Tube';

our $VERSION = '0.04';

sub init {
    my ($self, @files) = @_;
    @{ $self->{files} } = @files;

    return $self;
}

# implement <> here
sub run {
    my ($self, @files) = @_;

    push @{ $self->{files} }, @files;

    my $fh = $self->{fh};
    while (1) {
        if (not defined $fh) {
            $fh = $self->_next_file;
        }
        return if not $fh;
        my $row = <$fh>;
        if (defined $row) {
            $self->logger("Row read: $row");
            return $row;
        } else {
            $fh = undef;
        }
    }
}

sub _next_file {
    my ($self) = @_;
    while (my $file = shift @{ $self->{files} }) {
        $self->logger("Opening file '$file'");
        if (open my $fh, "<", $file) {
            return $self->{fh} = $fh;
        } else {
            warn "Could not open '$file'. $!\n";
        }
    }
}

1;

