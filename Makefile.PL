use ExtUtils::MakeMaker;

my %opts = (
    NAME	     => 'Pipe',
    VERSION_FROM => 'lib/Pipe.pm',
    AUTHOR       => 'Gabor Szabo <gabor@pti.co.il>',
    ABSTRACT     => 'Framework to create pipes using iterators',
    LICENSE      => 'perl',
    PREREQ_PM    => {
        'Want'                => '0',
        'Test::More'          => '0.47',
        'File::Find::Rule'    => '0',
    },
    META_MERGE        => {
       resources => {
           repository  =>  'https://github.com/szabgab/Pipe',
       },
	},
);

WriteMakefile( %opts );
