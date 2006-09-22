#!/usr/bin/perl -w
use strict;

use Test::More;
my $tests;
plan tests => $tests;
#49;
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
    BEGIN { $tests += 2; }
}


{
    $warn = '';
    my @input = Pipe->cat();
    is $warn, '', "no warning";
    is_deeply \@input, [], "empty array";
    BEGIN { $tests += 2; }
}

{
    unlink "pipe.log";
    local $Pipe::DEBUG = 1;
    Pipe->cat();
    ok -e "pipe.log", "log was created";
    BEGIN { $tests += 1; }
}


{
    $warn = '';
    my @input = Pipe->cat("t/data/file1");
    is $warn, '', "no warning";
    @ARGV = ("t/data/file1");
    my @expected = <>;
    is_deeply \@input, \@expected, "reading one file";
    BEGIN { $tests += 2; }
}

{
    $warn = '';
    my @input = Pipe->cat("t/data/file1", "t/data/file2");
    is $warn, '', "no warning";
    @ARGV = ("t/data/file1", "t/data/file2");
    my @expected = <>;
    is_deeply \@input, \@expected, "reading two files";
    BEGIN { $tests += 2; }
}

# with a non-existing file, (give error message but go on processing)
{
    $warn = '';
    my @input = Pipe->cat("t/data/file1", "t/data/file_not_there", "t/data/file2");
    like $warn, qr{^\QCould not open 't/data/file_not_there'.}, "warn about a missing file";
    @ARGV = ("t/data/file1", "t/data/file2");
    my @expected = <>;
    is_deeply \@input, \@expected, "reading two files";
    
    BEGIN { $tests += 2; }
}


{
    $warn = '';
    my @input = Pipe->cat("t/data/file1", "t/data/file2")->chomp;
    is $warn, '', "no warning";
    @ARGV = ("t/data/file1", "t/data/file2");
    my @expected = <>;
    chomp @expected;
    is_deeply \@input, \@expected, "reading two files and piping through chomp";
    BEGIN { $tests += 2; }
}

{
    $warn = '';
    my @input = Pipe->cat("t/data/numbers1")->uniq->chomp;
    is $warn, '', "no warning";
    my @expected = (23, 17, 2, 43, 23);
    is_deeply \@input, \@expected, "reading a file and piping through uniq and chomp";
    BEGIN { $tests += 2; }
}

{
    $warn = '';
    my @input = Pipe->cat("t/data/numbers1")->chomp->uniq;
    is $warn, '', "no warning";
    my @expected = (23, 17, 2, 43, 23);
    is_deeply \@input, \@expected, "reading a file and piping through chomp and uniq";
    BEGIN { $tests += 2; }
}



{
    $warn = '';
    my @input = Pipe->cat("t/data/file1", "t/data/file2")->grep(qr/test/);
    is $warn, '', "no warning";
    @ARGV = ("t/data/file1", "t/data/file2");
    my @expected = grep /test/, <>;
    is_deeply \@input, \@expected, "reading two files and piping through grep with regex";
    BEGIN { $tests += 2; }
}

{
    $warn = '';
    #my @input = Pipe->cat("t/data/file1", "t/data/file2")->grep( sub { index($_[0], "testing") > -1 } );
    my @input = Pipe->cat("t/data/file1", "t/data/file2")->grep( sub { index($_, "testing") > -1 } );
    is $warn, '', "no warning";
    @ARGV = ("t/data/file1", "t/data/file2");
    my @expected = grep { index($_, "testing") > -1 } <>;
    is_deeply \@input, \@expected, "reading two files and piping through grep with block";
    BEGIN { $tests += 2; }
}

{
    $warn = '';
    my @input = Pipe->cat("t/data/numbers1")->chomp->sort;
    is $warn, '', "no warning";
    @ARGV = ("t/data/numbers1");
    my @expected = sort <>;
    chomp @expected;
    is_deeply \@input, \@expected, "reading file sorting";
    BEGIN { $tests += 2; }
}

{
    $warn = '';
    my @input = Pipe->cat("t/data/numbers1")->chomp->sort( sub { $_[0] <=> $_[1] } );
    is $warn, '', "no warning";
    @ARGV = ("t/data/numbers1");
    my @expected = sort {$a <=> $b} <>;
    chomp @expected;
    is_deeply \@input, \@expected, "reading file sorting numerically";
    BEGIN { $tests += 2; }
}

{
    $warn = '';
    my @files = Pipe->glob("t/data/file*");
    is $warn, '', "no warning";
    my @expected = glob "t/data/file*";
    is_deeply \@files, \@expected, "glob on two files";
    BEGIN { $tests += 2; }
}

{
    $warn = '';
    my @input = Pipe->glob("t/data/file[12]")
        ->cat;
    is $warn, '', "no warning";
    @ARGV = ("t/data/file1", "t/data/file2");
    my @expected = <>;
    is_deeply \@input, \@expected, "reading two files and piping through another cat";
    BEGIN { $tests += 2; }
}

{
    $warn = '';
    my @input = Pipe->cat("t/data/file1", "t/data/file2")
                    ->map(  sub {{str => $_[0], long => length $_[0]}} );
    is $warn, '', "no warning";
    @ARGV = ("t/data/file1", "t/data/file2");
    my @expected = map {{ str => $_, long => length $_}} <>;
    is_deeply \@input, \@expected, "reading two files and maping the lines";

    BEGIN { $tests += 2; }
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
    BEGIN { $tests += 2; }
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
    
    BEGIN { $tests += 2; }
}

{
    $warn = '';
    my @files = Pipe->find("t");
    #diag Dumper \@files;
    is $warn, '', "no warning";
    BEGIN { $tests += 1; }
}

#Pipe->cat("t/data/file1", "t/data/file2")->print;
{
    unlink "out";
    $warn = '';
    Pipe->cat("t/data/file1", "t/data/file2")->print("out");
    is $warn, '', "no warning";
    
    @ARGV = ("t/data/file1", "t/data/file2");
    my @expected = <>;
    @ARGV = ("out");
    my @received = <>;
    is_deeply \@received, \@expected, "reading two files and piping through print to filename";
    BEGIN { $tests += 2; }
}

{
    unlink "out";
    $warn = '';
    open my $out, ">", "out" or die $!;
    Pipe->cat("t/data/file1", "t/data/file2")->print($out);
    close $out;
    is $warn, '', "no warning";

    @ARGV = ("t/data/file1", "t/data/file2");
    my @expected = <>;
    @ARGV = ("out");
    my @received = <>;
    is_deeply \@received, \@expected, "reading two files and piping through print to filehandle";
    BEGIN { $tests += 2; }
}

#Pipe->cat("t/data/file1", "t/data/file2")->chomp->say;
{
    unlink "out";
    $warn = '';
    Pipe->cat("t/data/file1", "t/data/file2")->chomp->say("out");
    is $warn, '', "no warning";
    
    @ARGV = ("t/data/file1", "t/data/file2");
    my @expected = <>;
    @ARGV = ("out");
    my @received = <>;
    is_deeply \@received, \@expected, "reading two files and piping through print to filename";
    BEGIN { $tests += 2; }
}

{
    unlink "out";
    $warn = '';
    open my $out, ">", "out" or die $!;
    Pipe->cat("t/data/file1", "t/data/file2")->chomp->say($out);
    close $out;
    is $warn, '', "no warning";

    @ARGV = ("t/data/file1", "t/data/file2");
    my @expected = <>;
    @ARGV = ("out");
    my @received = <>;
    is_deeply \@received, \@expected, "reading two files and piping through print to filehandle";
    BEGIN { $tests += 2; }
}


{
    my @a = qw(foo bar baz moo);
    my @b = qw(23  37  77  42);

    my @one_tuple = Pipe->tuple(\@a);
    is_deeply \@one_tuple, [['foo'], ['bar'], ['baz'], ['moo']], "1-tuple";

    my @two_tuple = Pipe->tuple(\@a, \@b);
    is_deeply \@two_tuple, [['foo', 23], ['bar', 37], ['baz', 77], ['moo', 42]], "2-tuple";

    # catch die in case array was passed insted of arrayref ?
    BEGIN { $tests += 2; }
}


{
    my @input = (
        "abc =   def",
        "a=b",
    );
    my @result = Pipe->for(@input)->split(qr/\s*=\s*/);
    is_deeply \@result, [ ["abc", "def"], ["a", "b"] ], "split with regex";

    my @result_2 = Pipe->for(@input)->split("=");
    is_deeply \@result_2, [ ["abc ", "   def"], ["a", "b"] ], "split with string";
    BEGIN { $tests += 2; }
}

{
    my @input = (
        "abc|bcd",
        "a|b",
    );
    my @result = Pipe->for(@input)->split("|");
    is_deeply \@result, [ ["abc", "bcd"], ["a", "b"] ], "split with | as string";
    BEGIN { $tests += 1; }
}



