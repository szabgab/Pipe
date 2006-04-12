use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Pipe',
    license             => 'perl',
    dist_author         => 'Gabor Szabo <gabor@pti.co.il>',
    dist_abstract       => 'Framework to create pipes using iterators',
    create_makefile_pl  => 'traditional',
    create_readme       => 1,
    requires            => {
        'Want'                => '0',
        'Test::More'          => '0.47',
        'File::Find::Rule'    => '0',
    },
);

$builder->create_build_script();
