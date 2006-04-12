package Pipe;
use strict;
use warnings;

use Want qw(want);
our $DEBUG;

our $VERSION = '0.02';

sub logger {
    my ($self, $msg, $class) = @_;
    return if not $DEBUG;
    $class = $self if not $class;
    my $t = localtime;
    open my $fh, ">>", "pipe.log" or return;
    print $fh "[$t] [$class] $msg\n";
}

our $AUTOLOAD;

AUTOLOAD {
    my ($self) = @_;
    my $module = $AUTOLOAD;
    $module =~ s/.*:://;
    $module =~ s/=.*//;
    my $class = "Pipe::Tube::" . ucfirst $module;
    $self->logger("AUTOLOAD: '$AUTOLOAD', module: '$module', class: '$class'");
    eval "use $class";
    die "Could not load '$class' $@\n" if $@;

    if ($self eq "Pipe") {
        $self = bless {}, "Pipe";
    }
    my $last_thingy = (want('VOID') or want('LIST') or (want('SCALAR') and not want('OBJECT')) ? 1 : 0);
    $self->logger("context: $_: " . want($_)) for (qw(VOID SCALAR LIST OBJECT));

    $self->logger("params: " . join "|", @_);
    my $obj = $class->new(@_);
    push @{ $self->{Pipe} }, $obj;

    if ($last_thingy) {
        $self->logger("last thingy");
        return $self->run_pipe;
    }
    return $self;
}

sub run_pipe {
    my ($self) = @_;
    $self->logger("Pipe::run_pipe called");
    return if not @{ $self->{Pipe} };

    my $in = shift @{ $self->{Pipe} };
    my $in_finished = 0;
    my @results;
    while (1) {
        $self->logger("Pipe::run_pipe calls in: $in");
        my @res = $in->run;
        $self->logger("Pipe::run_pipe resulted in " . join "|", @res);
        if (not @res) {
            @res = $in->finish();
            $in_finished = 1;
        }
        foreach my $i (0..@{ $self->{Pipe} }-1) {
            my $call = $self->{Pipe}[$i];
            $self->logger("Pipe::run_pipe calls: $call");
            @res = $call->run(@res);
            $self->logger("Pipe::run_pipe results: {" . join("}{", @res) . "}");
            last if not @res;
        }
        push @results, @res;
        if ($in_finished) {
            $self->logger("IN finished");
            $in = shift @{ $self->{Pipe} };
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

Pipe - Framework to create pipes using iterators

=head1 SYNOPSIS

 use Pipe;
 my @input = Pipe->cat("t/data/file1", "t/data/file2");
 my @lines = Pipe->cat("t/data/file1", "t/data/file2")->chomp;
 my @uniqs = Pipe->cat("t/data/file1", "t/data/file2")->chomp->uniq;

 Pipe->cat("t/data/file1", "t/data/file2")->uniq->print("t/data/out");



=head1 WARNING

This is Alpha version. The user API might still change

=head1 DESCRIPTION

Building an iterating pipe with prebuilt and home made tubes.

Tubes available in this distibution:

=head2 cat

Read in the lines of one or more file.

=head2 chomp

Remove trailing newlines from each line.


=head2 for

Pipe->for(@array)

Iterates over the elements of an array. Basically the same as the for or foreach loop of Perl.

=head2 glob

Implements the Perl glob function.

=head2 grep

Selectively pass on values.

Can be used either with a regex:

 ->grep( qr/regex/ )

Or with a sub:

 ->grep( sub { length($_[0]) > 12 } )


Very similar to the built-in grep command of Perl but instead of regex
you have to pass a compiled regex using qr// and instead of a block you
have to pass an anonymous   sub {}

=head2 map

Similar to the Perl map construct, except that instead of a block you pass
an anonymous function sub {}.

 ->map(  sub {  length $_[0] } );

=head2 print

TODO Not implemented yet

Prints out its input.
By default it prints to STDOUT but the user can supply a filename or a filehandle.

 Pipe->cat("t/data/file1", "t/data/file2")->print;
 Pipe->cat("t/data/file1", "t/data/file2")->print("out.txt");
 Pipe->cat("t/data/file1", "t/data/file2")->print(':a', "out.txt");

=head2 sort

Similar to the built in sort function of Perl. As sort needs to have all 
the data in the memory, once you use sort in the Pipe it stops being
an iterator for the rest of the pipe.

By default it sorts based on ascii table but you can provide your own
sorting function. The two values to be compared are passed to this function.

 Pipe->cat("t/data/numbers1")->chomp->sort( sub { $_[0] <=> $_[1] } );

=head2 uniq

Similary to the unix uniq command eliminate duplicate conscutive values.

23, 23, 19, 23     becomes  23, 19, 23

Warning: as you can see from the example this method does not give real unique
values, it only eliminates consecutive duplicates.


=head1 Building your own tube

If you would like to add a tube called "thing" create a module called 
Pipe::Tube::Thing that inherits from Pipe::Tube, our abstract Tube.

Implement one or more of these methods in your subclass as you please.

=head2 init

Will be called once when initializing the pipeline. 
It will get ($self, @args)  where $self is the Pipe::Tube::Thing object
and @args are the values given as parameters to the ->thing(@args) call
in the pipeline.

=head2 run

Will be called every time the previous tube in the pipe returns one or more values.
It can return a list of values that will be passed on to the next tube.
If based on the current state of Thing there is nothing to do you should call
return; with no parameters.

=head2 finish

Will be called once when the Pipe Manager notices that this Thing should be finished.
This happens when Thing is the first active element in the pipe (all the previous tubes
have already finshed) and its run() method returns an empty list.

The finish() method should return a list of values that will be passed on to the next 
tube in the pipe. This is especially useful for Tubes such as sort that can to their thing
only after they have received all the input.


=head2 Debugging your tube

You can call $self->logger("some message") from your tube. 
It will be printed to pipe.log if someone sets $Pipe::DEBUG = 1;

=head1 BUGS

Probably plenty.

=head1 Development

The Subversion repository is here: http://svn1.hostlocal.com/szabgab/trunk/Pipe/

=head1 Thanks

to Gaal Yahas

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
# the Pipe manager can recognize that a Pipe element finished if it is the first element (so it has nothing 
#    else to wait for) and its run method returned (). Then its finish method is called and it is dropped
#    
# the Pipe can easily recognize which is the first piece (it is called as class method)
# 
# the Pipe needs to recognize what is the last call, we can enforce it by a speciall call ->run
#      but if would be also nice to recognize it in other way
#      using the Want module: 
#      $o->thing         VOID
#      $z = $o->thing    SCALAR
#      if ($o->thing)    SCALAR and BOOL  
#      @ret = $o->thing  LIST

#      $o->thing->other  SCALAR and OBJECT

# TODO 
#   find
#   flat (put in after a sort and it will flaten out the calls.
#   Pipe->sub( sub {} ) can get any subroutine and will insert it in the pipe
#   split up the input stream
# process groups of values

#=head2 flat

#Will flatten a pipe. I am not sure it is useful at all.
#The issue is that most of the tubes are iterators but "sort" needs to collect all the inputs
#before it can do its job. Then, once its done, it returns the whole array in its finish() 
#method. The rest of the pipe will get copies of this array. Including a ->flat tube in the
#pipe will receive all the array but then will serve them one by one
#
# Actualy I think ->for will do the same
#



1;

