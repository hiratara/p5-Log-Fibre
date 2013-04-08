package MyLogger;
use strict;
use warnings;
sub new { bless {warn => [], info => []} => $_[0] }
sub info { push @{shift->{info}}, @_ }
sub warn { push @{shift->{warn}}, @_ }

package main;
use strict;
use warnings;
use Log::Fibre;
use Test::More;
use Time::HiRes ();

{
    my $logger = MyLogger->new;
    my $fibre = Log::Fibre->new($logger);
    $fibre->warn("log1");
    $fibre->info("log2");
    is_deeply $logger->{warn}, [qw(log1)];
    is_deeply $logger->{info}, [qw(log2)];
}

{
    my $logger = MyLogger->new;
    my $fibre = Log::Fibre->new($logger);
    for (1 .. 6) {
        $fibre->fibre(warn => "log1-$_", {max => 3});
        $fibre->fibre(warn => "log2-$_", {max => 6});
    }
    is @{$logger->{warn}}, 3;
    like $logger->{warn}[0], qr/log1-3/;
    like $logger->{warn}[1], qr/log1-6/;
    like $logger->{warn}[2], qr/log2-6/;

    note $_ for @{$logger->{warn}};
}

{
    my $logger = MyLogger->new;
    my $fibre = Log::Fibre->new($logger);
    for (1 .. 7) { # 1.8 sec
        $fibre->fibre(info => "log1-$_", {duration => 1});
        $fibre->fibre(info => "log2-$_", {duration => 2});
        Time::HiRes::sleep .3;
    }
    undef $fibre;

    cmp_ok +(grep {/log1/} @{$logger->{info}}), '<=', 3;
    cmp_ok +(grep {/log2/} @{$logger->{info}}), '<=', 2;

    note $_ for @{$logger->{info}};
}

done_testing;
