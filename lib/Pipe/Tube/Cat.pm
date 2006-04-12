package PIPE::Cat;
use strict;
use warnings;

use base 'PIPE::Skeleton';

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
            $self->_log("Row read: $row");
            return $row;
        } else {
            $fh = undef;
        }
    }
}

sub _next_file {
    my ($self) = @_;
    while (my $file = shift @{ $self->{files} }) {
        $self->_log("Opening file '$file'");
        if (open my $fh, "<", $file) {
            return $self->{fh} = $fh;
        } else {
            print STDERR $@;
        }
    }
}

1;

