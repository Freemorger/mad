#!/usr/bin/perl
use strict;
use warnings;
use v5.35;

sub parse_com {
    # arg passing here are smth...
    my ($args_ref, $vars_ref) = @_;
    my @args = @$args_ref;
    my %vars = %$vars_ref;

    my $expanded = "";
    foreach my $tok (@args) {
        $_ = $tok;
        if (/[.]+/) {
            my $nodot = substr $tok, 1, length($tok);
            $expanded .= "$vars{$nodot} ";
        } else {
            $expanded .= "$tok ";
        }
    }
    return $expanded;
}

sub main {
    open(my $contents, "<", "MADFile") or die "Can't open MADFile!";
    my @lines = <$contents>;

    my %vars = ();
    foreach my $line (@lines) {
        chomp $line;
        my @seped = split(" ", $line);
        $_ = $line;
        if (/\b[A-Z]+\b/ && !(/CMD+/)) { # variable
            $vars{$seped[0]} = join(" ", @seped[1..$#seped]);
        }
        if (/CMD+/) {
            my @cmd_args = @seped[1..$#seped];
            my $exp = parse_com(\@cmd_args, \%vars);
            say "CMD ", $exp;
            system $exp;
        }
    }
}

main;
