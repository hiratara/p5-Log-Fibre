#!perl -w
use strict;
use Test::More tests => 1;

BEGIN {
    use_ok 'Log::Fibre';
}

diag "Testing Log::Fibre/$Log::Fibre::VERSION";
