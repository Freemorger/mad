#!/usr/bin/perl
use strict;
use warnings;
use v5.35;

my $MAD_VERSION = "v0.2"; 

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

    if ($#ARGV + 1 < 1) {
        die "Usage: mad.pl recipe";
    }
    my $recipe = $ARGV[0];

    my $need_list = 0;
    my $need_help = 0;
    if ($recipe =~ /list/) {
        $need_list = 1;
    } elsif ($recipe =~ /--version/) {
        say $MAD_VERSION;
        return;
    } elsif (($recipe =~ /[A-Za-z-0-9]/) && (defined($ARGV[1]))) {
        if ($ARGV[1] eq "help") {
            $need_help = 1;
        }
    }

    my %vars = ();
    my $tgt = 0; # if we're parsing needed recipe 
    foreach my $line (@lines) {
        chomp $line;
        $line =~ s{(#.*)}{}g;
        my $comment = $1;
        my @seped = split(" ", $line);

        $_ = $line;
        if (/recipe\s*([A-Za-z0-9]*)\s*+/) {
            my $name = $1;
            if ($need_help && !($name cmp $recipe)) {
                say "$name: $comment";
                return;
            }
            if ($need_list) {
                say $name;
            } elsif (!($name cmp $recipe)) {
                $tgt = 1;
            }
        }
        if (/[}]\send[;]/) {
            $tgt = 0;
        }
        if (!$tgt) {
            next;
        }

        if (/\b[A-Z]+\b\s*[=]+/) { # variable
            $vars{$seped[0]} = join(" ", @seped[2..$#seped]);
        } elsif (/\b[A-Z]+\b\s*\?=+/) { # cmd assign 
            my @cmd_args = @seped[2..$#seped];
            my $cmd = parse_com(\@cmd_args, \%vars);
            my $cmd_res = `$cmd`;
            $vars{$seped[0]} = $cmd_res;
        } elsif (/CMD+/) {
            my @cmd_args = @seped[1..$#seped];
            my $exp = parse_com(\@cmd_args, \%vars);
            say "CMD ", $exp;
            system $exp;
        }
    }
}

main;
