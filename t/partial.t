#!/usr/bin/env perl

use strict;

use Test::More;
use Test::Deep;

use JSON;
use JSON::Schema::Fit;

my $schema = {
    type => 'object',
    additionalProperties => 0,
    properties => {
        aa => { type => 'boolean' },
        bb => { type => 'integer', multipleOf => 5 },
        cc => { type => 'number', multipleOf => 0.01 },
        dd => { type => 'string' },
        ee => { type => 'number', maximum => 6 },
        ff => { type => 'number', maximum => 6 },
        gg => { type => 'number', minimum => 6.4 },
        hh => { type => 'number', minimum => 6.4 },
    },
};

my $raw_data = {
    aa => 1,
    bb => "22",
    cc => "33.333333",
    dd => 77,
    ee => 8,
    ff => 4,
    gg => 10,
    hh => 6.4,
    _debug => "stacktrace",
};

my @tests = (
    [ full =>           JSON::Schema::Fit->new(),                   {aa => JSON::true, bb => 20, cc => 33.33, dd => "77", ee => 6, ff => 4, gg => 10, hh => 6.4} ],

    [ no_booleans =>    JSON::Schema::Fit->new(booleans => 0),      {aa => 1, bb => 20, cc => 33.33, dd => "77", ee => 6, ff => 4, gg => 10, hh => 6.4} ],
    [ no_rounding =>    JSON::Schema::Fit->new(round_numbers => 0), {aa => JSON::true, bb => 22, cc => 33.333333, dd => "77", ee => 6, ff => 4, gg => 10, hh => 6.4} ],
    [ no_numbers =>     JSON::Schema::Fit->new(numbers => 0),       {aa => JSON::true, bb => "22", cc => "33.333333", dd => "77", ee => "8", ff => "4", gg => "10", hh => "6.4"} ],
    [ no_limits =>     JSON::Schema::Fit->new(limits => 0),       {aa => JSON::true, bb => 20, cc => 33.33, dd => 77, ee => 8, ff => 4, gg => 10, hh => 6.4} ],
    [ no_strings =>     JSON::Schema::Fit->new(strings => 0),       {aa => JSON::true, bb => 20, cc => 33.33, dd => 77, ee => 6, ff => 4, gg => 10, hh => 6.4} ],
    [ no_hash_keys =>   JSON::Schema::Fit->new(hash_keys => 0),     {aa => JSON::true, bb => 20, cc => 33.33, dd => "77", ee => 6, ff => 4, gg => 10, hh => 6.4, _debug => "stacktrace"} ],

    [ disable_all =>    JSON::Schema::Fit->new(map {$_ => 0} qw/booleans numbers round_numbers strings hash_keys limits/), $raw_data ],
);

for my $test ( @tests ) {
    my ($name, $jsf, $expected) = @$test;
    cmp_deeply $jsf->get_adjusted($raw_data, $schema), $expected, $name;
}


done_testing();

