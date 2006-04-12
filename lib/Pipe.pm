package PIPE;
use strict;
use warnings;

use Want qw(want);
our $DEBUG;

sub _log {
    my ($self, $msg, $class) = @_;
    return if not $DEBUG;
    $class = $self if not $class;
    my $t = localtime;
    print "[$t] [$class] $msg\n";
}

our $AUTOLOAD;

AUTOLOAD {
    my ($self) = @_;
    my $module = $AUTOLOAD;
    $module =~ s/.*:://;
    $module =~ s/=.*//;
    my $class = "PIPE::" . ucfirst $module;
    $self->_log("AUTOLOAD: '$AUTOLOAD', module: '$module', class: '$class'");
    eval "use $class";
    die "Could not load '$class' $@\n" if $@;

    # let user register pipes ?
    # check if this pipe is registered?

    if ($self eq "PIPE") {
        $self = bless {}, "PIPE";
    }
    my $last_thingy = (want('VOID') or want('LIST') or (want('SCALAR') and not want('OBJECT')) ? 1 : 0);
    $self->_log("context: $_: " . want($_)) for (qw(VOID SCALAR LIST OBJECT));

    $self->_log("params: " . join "|", @_);
    my $obj = $class->new(@_);
    push @{ $self->{PIPE} }, $obj;

    if ($last_thingy) {
        $self->_log("last thingy");
        return $self->run_pipe;
    }
    return $self;
}

sub run_pipe {
    my ($self) = @_;
    $self->_log("PIPE::run called");
    return if not @{ $self->{PIPE} };

    my $in = shift @{ $self->{PIPE} };
    my $in_finished = 0;
    my @results;
    while (1) {
        $self->_log("PIPE::run calls in: $in");
        my @res = $in->run;
        $self->_log("PIPE::run resulted in " . join "|", @res);
        if (not @res) {
            @res = $in->finish();
            $in_finished = 1;
        }
        foreach my $i (0..@{ $self->{PIPE} }-1) {
            my $call = $self->{PIPE}[$i];
            $self->_log("PIPE::run calls: $call");
            @res = $call->run(@res);
            $self->_log("PIPE::run results: {" . join("}{", @res) . "}");
            last if not @res;
        }
        push @results, @res;
        if ($in_finished) {
            $self->_log("IN finished");
            $in = shift @{ $self->{PIPE} };
            last if not defined $in;
            $in_finished = 0;
        }
    }
    return @results;
}




DESTROY {
   # to avoid trouble because of AUTOLOAD catching this as well 
}

=head1 NAME

PIPE - Framework to create lazy pipes as iterators

=head1 SYNOPSIS

 use PIPE;
 my @input = PIPE->cat("t/data/file1", "t/data/file2");
 my @lines = PIPE->cat("t/data/file1", "t/data/file2")->chomp;
 my @uniqs = PIPE->cat("t/data/file1", "t/data/file2")->chomp->uniq;

 PIPE->cat("t/data/file1", "t/data/file2")->uniq->print("t/data/out");


=head1 WARNING

This is Alpha version. The user API might still change

=head1 DESCRIPTION

Build a low memory consumption iterating pipe with prebuilt tubes and add
your own kit.

Currently available tubes:

=head2 PIPE::Cat

Read in the lines of one or more file.


=head2 PIPE::Chomp

Remove trailing newlines from each line

=head2 PIPE::Grep

Can be used either with a regex:

 ->grep( qr/regex/ )

Or with a sub:

 ->grep( sub { length($_) > 12 } )



=head2 PIPE::Uniq

Similary to the unix uniq command eliminate duplicate conscutive values.

23, 23, 19, 23     becomes  23, 19, 23


=head1 How to build your own tube ?

If you would like to add a tube called "thing" create a module called 
PIPE::Thing that inherits from PIPE::Skeleton.

Implement on or more of these methods in your subclass as you please.

=head2 init

Will be called once when initializing the pipeline. 
It will get ($self, @args)  where $self is the PIPE::Thing object
and @args are the values given as parameters to the ->thing(@args) call.


=head2 run

Will be called every time the previous tube in the pipe returns a value.
It can return a list of values that will be passed on to the next tube.

=head2 finish

Will be called once, immediately after the preceding tube finished its work 
(and returned empty string), It can return a list of values that will be 
passed on to the next thingy.


=head2 Debugging your tube

You can call $self->_log("some message") from your tube. It will be printed to STDOUT
if someone sets $PIPE::DEBUG = 1;

=head1 BUGS

Probably plenty.

One issue I know about is that if there is a tube such as "sort" that needs all the data
in order to run, the rest of the pipe will also work on the whole data. 
This is probably the right behavior but I am not yet sure. I could add a flag to flatten
the file again after such tubes but it won't save any memory as we already have all the
input in memory anyway.


=head1 Development

The Subversion repository is here: http://svn1.hostlocal.com/szabgab/trunk/PPT/

=head1 AUTHOR

Gabor Szabo <gabor@pti.co.il>

=head1 Copyright

Copyright 2006 by Gabor Szabo <gabor@pti.co.il>.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=head1 See Also

L<Shell::Autobox>


=cut


# Every pipe element have 
# @output = $obj->run(@input)
# @output = $obj->finish is called when the previous thing in the pipe finishes
#
# The run function of a pipe element should return () if it has nothing more to do 
#    (either because of lack of input or some other reason. e.g. sort cannot output anything
#    until it has all the its input data ready and thus its finish method was called
# The finish method also returns the output or () if notthing to say
# 
# the PIPE manager can recognize that a Pipe element finished if it is the first element (so it has nothing 
#    else to wait for) and its run method returned (). Then its finish method is called and it is dropped
#    
# the PIPE can easily recognize which is the first piece (it is called as class method)
# 
# the PIPE needs to recognize what is the last call, we can enforce it by a speciall call ->run
#      but if would be also nice to recognize it in other way
#      using the Want module: 
#      $o->thing         VOID
#      $z = $o->thing    SCALAR
#      if ($o->thing)    SCALAR and BOOL  
#      @ret = $o->thing  LIST

#      $o->thing->other  SCALAR and OBJECT



1;

