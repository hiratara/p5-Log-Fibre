package Log::Fibre;
use 5.008_001;
use strict;
use warnings;

our $VERSION = '0.01';

sub new {
    my ($class, $logger) = @_;
    bless {logger => $logger, fibres => {}} => $class;
}

sub fibre {
    my $self = shift;
    my $meth = shift;
    my $option = pop if ref $_[-1] eq 'HASH';

    my $time = time;

    my (undef, $file, $line) = caller;
    my $fibre_name = join "\t" => $file, $line;

    my $fibre = $self->{fibres}{$fibre_name} //= {
        start_time => $time, count => 0,
        last_method => undef, last_log => undef,
    };
    $fibre->{count}++;

    if ($option->{max} && $fibre->{count} >= $option->{max}) {
        $self->{logger}->$meth(@_);
        delete $self->{fibres}{$fibre_name};
    } elsif ($option->{duration} &&
             $time - $fibre->{start_time} >= $option->{duration}) {
        $self->{logger}->$meth(@_);
        delete $self->{fibres}{$fibre_name};
    } else {
        $fibre->{last_method} = $meth;
        $fibre->{last_log} = [@_];
    }
}

sub DESTROY {
    my $self = shift;
    for (keys %{$self->{fibres}}) {
        my $fibre = $self->{fibres}{$_};
        my $meth = $fibre->{last_method};
        $self->{logger}->$meth(@{$fibre->{last_log}});
    }
}

sub AUTOLOAD {
    my $self = shift;
    (my $method = our $AUTOLOAD) =~ s/^.*:://;
    $self->{logger}->$method(@_);
}

1;
__END__

=head1 NAME

Log::Fibre - Perl extention to do something

=head1 VERSION

This document describes Log::Fibre version 0.01.

=head1 SYNOPSIS

    use Log::Fibre;

=head1 DESCRIPTION

# TODO

=head1 INTERFACE

=head2 Functions

=head3 C<< hello() >>

# TODO

=head1 DEPENDENCIES

Perl 5.8.1 or later.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 SEE ALSO

L<perl>

=head1 AUTHOR

Masahiro Honma E<lt>hiratara@cpan.orgE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2013, Masahiro Honma. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
