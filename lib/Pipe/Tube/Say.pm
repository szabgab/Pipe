package Pipe::Tube::Say;
use strict;
use warnings;

use base 'Pipe::Tube::Print';

our $VERSION = '0.04';


sub run {
  my ($self, @input) = @_;
  my @unchomped =  map { "$_\n" } @input;
  $self->SUPER::run(@unchomped);
}


1;



