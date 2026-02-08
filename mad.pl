#!/usr/bin/perl
use strict;
use warnings;
use v5.35;

my $MAD_VERSION = "v0.3"; 
my $MAD_TIMESTAMP = localtime() . "";

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

sub parse_wildcards {
    my ($args_ref) = @_;
    my @args = @$args_ref;

    my @parsed = ();
    foreach my $arg (@args) {
        if ($arg =~ /(\*\.[A-Za-z0-9_]+)$/) {
            my @files = glob($arg);

            foreach my $file (@files) {
                push @parsed, $file;
            }
        } else {
            push @parsed, $arg;
        }
    }
    return @parsed;
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
        if (defined($ARGV[1]) && $ARGV[1] eq "help") {
            $need_help = 1;
        }
    } elsif ($recipe =~ /--version/) {
        say $MAD_VERSION;
        return;
    } elsif (($recipe =~ /[A-Za-z-0-9]/) && (defined($ARGV[1]))) {
        if ($ARGV[1] eq "help") {
            $need_help = 1;
        }
    }

    my %vars = (
        MAD_VERSION => $MAD_VERSION,
        MAD_TIMESTAMP => $MAD_TIMESTAMP,
    );

    my $tgt = 0; # if we're parsing needed recipe 
    my $skip_ctr = 0;
    my $idx = 0;
    my $comment = "";
    my $last_comment = "";

    foreach my $line (@lines) {
        if ($skip_ctr > 0) {
            $skip_ctr--;
            $idx++;
            next;
        }

        chomp $line;
        $line =~ s{(#.*)}{}g;
        $last_comment = $comment;
        $comment = $1;
        my @seped = split(" ", $line);

        $_ = $line;
        if (/recipe\s*([A-Za-z0-9]*)\s*+/) {
            my $name = $1;
            if ($need_help && ($name eq $recipe)) {
                say "$name: $last_comment";
                return;
            }
            if ($need_list) {
                $need_help ? say "$name: $last_comment" : say "$name";
            } elsif ($name eq $recipe) {
                $tgt = 1;
            }
        }
        if (/[}]\send[;]/) {
            $tgt = 0;
        }
        if (!$tgt) {
            $idx++;
            next;
        }

        if (/\b[A-Z]+\b\s*[=]+/) { # variable 
            my @val = @seped[2..$#seped];
            
            if ($line =~ /\\\s*$/) {
                my $current_idx = $idx + 1;

                while ($current_idx <= $#lines) {
                        my $nline = $lines[$current_idx];
                        chomp $nline;
                        $skip_ctr++;

                        my @nextvals = split(" ", $nline);
                        push @val, @nextvals;

                        last unless $nline =~ /\\\s*$/;

                        $current_idx++;
                }
            }

            @val = parse_wildcards(\@val);
            foreach my $ith (@val) {
                $ith =~ s/\\//g;
            } 

            $vars{$seped[0]} = join(" ", @val);
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

        $idx++;
    }
}

main;
