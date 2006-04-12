#!/usr/bin/perl -w
use strict;

use Test::More tests => 16;
use Pipe;
#$Pipe::DEBUG = 1;

{
    my @input = Pipe->cat();
    is_deeply \@input, [], "empty array";
}

{
    my @input = Pipe->cat("t/data/file1");
    @ARGV = ("t/data/file1");
    my @expected = <>;
    is_deeply \@input, \@expected, "reading one file";
}

{
    my @input = Pipe->cat("t/data/file1", "t/data/file2");
    @ARGV = ("t/data/file1", "t/data/file2");
    my @expected = <>;
    is_deeply \@input, \@expected, "reading two files";
}

# with a non-existing file, (give error message but go on processing)
{
    my @input = Pipe->cat("t/data/file1", "t/data/file_not_there", "t/data/file2");
    @ARGV = ("t/data/file1", "t/data/file2");
    my @expected = <>;
    is_deeply \@input, \@expected, "reading two files";
    #TODO: and reporting about a missing file
}


{
    my @input = Pipe->cat("t/data/file1", "t/data/file2")->chomp;
    @ARGV = ("t/data/file1", "t/data/file2");
    my @expected = <>;
    chomp @expected;
    is_deeply \@input, \@expected, "reading two files and piping through chomp";
}

{
    my @input = Pipe->cat("t/data/numbers1")->uniq->chomp;
    my @expected = (23, 17, 2, 43, 23);
    is_deeply \@input, \@expected, "reading a file and piping through uniq and chomp";
}

{
    my @input = Pipe->cat("t/data/numbers1")->chomp->uniq;
    my @expected = (23, 17, 2, 43, 23);
    is_deeply \@input, \@expected, "reading a file and piping through chomp and uniq";
}



{
    my @input = Pipe->cat("t/data/file1", "t/data/file2")->grep(qr/test/);
    @ARGV = ("t/data/file1", "t/data/file2");
    my @expected = grep /test/, <>;
    is_deeply \@input, \@expected, "reading two files and piping through grep with regex";
}

{
    #my @input = Pipe->cat("t/data/file1", "t/data/file2")->grep( sub { index($_[0], "testing") > -1 } );
    my @input = Pipe->cat("t/data/file1", "t/data/file2")->grep( sub { index($_, "testing") > -1 } );
    @ARGV = ("t/data/file1", "t/data/file2");
    my @expected = grep { index($_, "testing") > -1 } <>;
    is_deeply \@input, \@expected, "reading two files and piping through grep with block";
}

{
    my @input = Pipe->cat("t/data/numbers1")->chomp->sort;
    @ARGV = ("t/data/numbers1");
    my @expected = sort <>;
    chomp @expected;
    is_deeply \@input, \@expected, "reading file sorting";
}

{
    my @input = Pipe->cat("t/data/numbers1")->chomp->sort( sub { $_[0] <=> $_[1] } );
    @ARGV = ("t/data/numbers1");
    my @expected = sort {$a <=> $b} <>;
    chomp @expected;
    is_deeply \@input, \@expected, "reading file sorting numerically";
}

{
    my @files = Pipe->glob("t/data/file*");
    my @expected = glob "t/data/file*";
    is_deeply \@files, \@expected, "glob on two files";
}

{
    my @input = Pipe->glob("t/data/file[12]")
        ->cat;
    @ARGV = ("t/data/file1", "t/data/file2");
    my @expected = <>;
    is_deeply \@input, \@expected, "reading two files and piping through another cat";
}

{
    my @input = Pipe->cat("t/data/file1", "t/data/file2")
                    ->map(  sub {{str => $_[0], long => length $_[0]}} );
    use Data::Dumper;
    @ARGV = ("t/data/file1", "t/data/file2");
    my @expected = map {{ str => $_, long => length $_}} <>;
    is_deeply \@input, \@expected, "reading two files and maping the lines";

}

{
    my @input = Pipe->cat("t/data/file1", "t/data/file2")
                    ->map(  sub {{str => $_[0], long => length $_[0]}} )
                    ->sort( sub {$_[0]->{long} <=> $_[1]->{long}} )
                    ->map(  sub { $_[0]->{str} } );
    @ARGV = ("t/data/file1", "t/data/file2");
    my @expected = sort {length $a <=> length $b} <>;
    is_deeply \@input, \@expected, "reading two files and piping through Schwartzian transformation";
}
{
    my @array_names   = qw(one two three);
    my @array_numbers = (1, 2, 3);
    
    my @out = Pipe->for(@array_names);
    is_deeply \@array_names, \@out, "for elements of array";

    #my @all = Pipe->pairs(\@array_names, \@array_numbers);
    #my @expected = 
    
}




#Pipe->cat("t/data/file1", "t/data/file2")->print;
#Pipe->cat("t/data/file1", "t/data/file2")->print("out");
#Pipe->cat("t/data/file1", "t/data/file2")->print(':a', "out");



