#!/usr/bin/perl -w
use strict;

use Test::More tests => 36;
use Pipe;
use Data::Dumper;
#$Pipe::DEBUG = 1;

my $warn;
$SIG{__WARN__} = sub {$warn = shift;};

{
    $warn = '';
    eval {Pipe->no_such();};
    like $@, qr{^Could not load 'Pipe::Tube::No_such'}, "exception on missing tube";
    is $warn, '', "no warning";
}


{
    $warn = '';
    my @input = Pipe->cat();
    is $warn, '', "no warning";
    is_deeply \@input, [], "empty array";
}

{
    unlink "pipe.log";
    local $Pipe::DEBUG = 1;
    Pipe->cat();
    ok -e "pipe.log", "log was created";
}


{
    $warn = '';
    my @input = Pipe->cat("t/data/file1");
    is $warn, '', "no warning";
    @ARGV = ("t/data/file1");
    my @expected = <>;
    is_deeply \@input, \@expected, "reading one file";
}

{
    $warn = '';
    my @input = Pipe->cat("t/data/file1", "t/data/file2");
    is $warn, '', "no warning";
    @ARGV = ("t/data/file1", "t/data/file2");
    my @expected = <>;
    is_deeply \@input, \@expected, "reading two files";
}

# with a non-existing file, (give error message but go on processing)
{
    $warn = '';
    my @input = Pipe->cat("t/data/file1", "t/data/file_not_there", "t/data/file2");
    like $warn, qr{^\QCould not open 't/data/file_not_there'.}, "warn about a missing file";
    @ARGV = ("t/data/file1", "t/data/file2");
    my @expected = <>;
    is_deeply \@input, \@expected, "reading two files";
    
}


{
    $warn = '';
    my @input = Pipe->cat("t/data/file1", "t/data/file2")->chomp;
    is $warn, '', "no warning";
    @ARGV = ("t/data/file1", "t/data/file2");
    my @expected = <>;
    chomp @expected;
    is_deeply \@input, \@expected, "reading two files and piping through chomp";
}

{
    $warn = '';
    my @input = Pipe->cat("t/data/numbers1")->uniq->chomp;
    is $warn, '', "no warning";
    my @expected = (23, 17, 2, 43, 23);
    is_deeply \@input, \@expected, "reading a file and piping through uniq and chomp";
}

{
    $warn = '';
    my @input = Pipe->cat("t/data/numbers1")->chomp->uniq;
    is $warn, '', "no warning";
    my @expected = (23, 17, 2, 43, 23);
    is_deeply \@input, \@expected, "reading a file and piping through chomp and uniq";
}



{
    $warn = '';
    my @input = Pipe->cat("t/data/file1", "t/data/file2")->grep(qr/test/);
    is $warn, '', "no warning";
    @ARGV = ("t/data/file1", "t/data/file2");
    my @expected = grep /test/, <>;
    is_deeply \@input, \@expected, "reading two files and piping through grep with regex";
}

{
    $warn = '';
    #my @input = Pipe->cat("t/data/file1", "t/data/file2")->grep( sub { index($_[0], "testing") > -1 } );
    my @input = Pipe->cat("t/data/file1", "t/data/file2")->grep( sub { index($_, "testing") > -1 } );
    is $warn, '', "no warning";
    @ARGV = ("t/data/file1", "t/data/file2");
    my @expected = grep { index($_, "testing") > -1 } <>;
    is_deeply \@input, \@expected, "reading two files and piping through grep with block";
}

{
    $warn = '';
    my @input = Pipe->cat("t/data/numbers1")->chomp->sort;
    is $warn, '', "no warning";
    @ARGV = ("t/data/numbers1");
    my @expected = sort <>;
    chomp @expected;
    is_deeply \@input, \@expected, "reading file sorting";
}

{
    $warn = '';
    my @input = Pipe->cat("t/data/numbers1")->chomp->sort( sub { $_[0] <=> $_[1] } );
    is $warn, '', "no warning";
    @ARGV = ("t/data/numbers1");
    my @expected = sort {$a <=> $b} <>;
    chomp @expected;
    is_deeply \@input, \@expected, "reading file sorting numerically";
}

{
    $warn = '';
    my @files = Pipe->glob("t/data/file*");
    is $warn, '', "no warning";
    my @expected = glob "t/data/file*";
    is_deeply \@files, \@expected, "glob on two files";
}

{
    $warn = '';
    my @input = Pipe->glob("t/data/file[12]")
        ->cat;
    is $warn, '', "no warning";
    @ARGV = ("t/data/file1", "t/data/file2");
    my @expected = <>;
    is_deeply \@input, \@expected, "reading two files and piping through another cat";
}

{
    $warn = '';
    my @input = Pipe->cat("t/data/file1", "t/data/file2")
                    ->map(  sub {{str => $_[0], long => length $_[0]}} );
    is $warn, '', "no warning";
    @ARGV = ("t/data/file1", "t/data/file2");
    my @expected = map {{ str => $_, long => length $_}} <>;
    is_deeply \@input, \@expected, "reading two files and maping the lines";

}

{
    $warn = '';
    my @input = Pipe->cat("t/data/file1", "t/data/file2")
                    ->map(  sub {{str => $_[0], long => length $_[0]}} )
                    ->sort( sub {$_[0]->{long} <=> $_[1]->{long}} )
                    ->map(  sub { $_[0]->{str} } );
    is $warn, '', "no warning";
    @ARGV = ("t/data/file1", "t/data/file2");
    my @expected = sort {length $a <=> length $b} <>;
    is_deeply \@input, \@expected, "reading two files and piping through Schwartzian transformation";
}
{
    $warn = '';
    my @array_names   = qw(one two three);
    my @array_numbers = (1, 2, 3);
    
    my @out = Pipe->for(@array_names);
    is_deeply \@array_names, \@out, "for elements of array";
    is $warn, '', "no warning";

    #my @all = Pipe->pairs(\@array_names, \@array_numbers);
    #my @expected = 
    
}

{
    $warn = '';
    my @files = Pipe->find("t");
    diag Dumper \@files;
    is $warn, '', "no warning";
}


#Pipe->cat("t/data/file1", "t/data/file2")->print;
#Pipe->cat("t/data/file1", "t/data/file2")->print("out");
#Pipe->cat("t/data/file1", "t/data/file2")->print(':a', "out");



