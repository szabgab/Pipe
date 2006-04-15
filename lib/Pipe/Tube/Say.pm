package Pipe::Tube::Say;
use strict;
use warnings;

use base 'Pipe::Tube::Print';



sub run {
  my ($self, @input) = @_;
  my @unchomped =  map { "$_\n" } @input;
  $self->SUPER::run(@unchomped);
}


1;



