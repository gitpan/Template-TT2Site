#!/usr/bin/perl -w
my $RCS_Id = '$Id: configure.pl,v 1.1.1.1 2004/12/01 21:52:18 jv Exp $ ';

# This script determines the correct root directory for the project
# (the parent of the 'bin' directory in which it is located), and then
# calls ttree to process all files under the skeleton directory,
# storing output relative to the project root directory (e.g.,
# skeleton/bin/build => bin/build).
#
# This is free software distributed under the same terms as Perl.
#
# Author          : Johan Vromans
# Created On      : Tue Mar  2 10:53:23 2004
# Last Modified By: Johan Vromans
# Last Modified On: Tue Nov 30 22:08:13 2004
# Update Count    : 38
# Status          : Unknown, Use with caution!

################ Common stuff ################

use strict;

# Package or program libraries, if appropriate.
# $LIBDIR = $ENV{'LIBDIR'} || '/usr/local/lib/sample';
# use lib qw($LIBDIR);
# require 'common.pl';

# Package name.
my $my_package = 'SPPN';
# Program name and version.
my ($my_name, $my_version) = $RCS_Id =~ /: (.+).pl,v ([\d.]+)/;
# Tack '*' if it is not checked in into RCS.
$my_version .= '*' if length('$Locker:  $ ') > 12;

################ Command line parameters ################

use Getopt::Long 2.13;

# Command line options.
my $verbose = 0;		# verbose processing

# Development options (not shown with -help).
my $debug = 0;			# debugging
my $trace = 0;			# trace (show process)
my $test = 0;			# test mode.

# Process command line options.
app_options();

# Post-processing.
$trace |= ($debug || $test);

################ Presets ################

my $TMPDIR = $ENV{TMPDIR} || $ENV{TEMP} || '/usr/tmp';

################ The Process ################

use File::Spec;

my $sitelib = $ENV{TT2SITE_LIB};
die("Please set TT2SITE_LIB\n") unless $sitelib;

my $dir  = File::Spec->rel2abs(File::Spec->curdir);
my $skel = File::Spec->catfile($sitelib, 'setup', 'data');

# Find ttree.
my $sep = File::Spec->devnull eq "nul" ? ";" : ":";
my $ttree = "ttree";
foreach my $p ( split($sep, $ENV{PATH}) ) {
    if ( -s "$p/$ttree.pl" ) {
	$ttree = "$p/$ttree.pl";
	last;
    }
    if ( -s "$p/$ttree" && -x _ ) {
	$ttree = "$p/$ttree";
	last;
    }
}
die("Could not find ttree or ttree.pl in PATH\n")
  if $ttree eq "ttree";

# Hand over to ttree.
unshift(@ARGV,
	'-s', $skel,
	'-d', $dir,
	'-f', File::Spec->catfile($sitelib, 'setup', 'etc', 'ttree.cfg'),
	'--define', "dir=$dir",
	'--define', "sitelib=".$ENV{TT2SITE_LIB},
	'--define', "tmplsrc=src",
	'--define', "debug=$debug");

warn("+ $ttree @ARGV\n") if $trace;
do $ttree or die("ttree did not complete\n");

################ Subroutines ################

sub app_options {
    my $help = 0;		# handled locally
    my $ident = 0;		# handled locally

    # Process options, if any.
    # Make sure defaults are set before returning!
    return unless @ARGV > 0;

    if ( !GetOptions(
		     'ident'	=> \$ident,
		     'verbose'	=> \$verbose,
		     'trace'	=> \$trace,
		     'help|?'	=> \$help,
		     'debug'	=> \$debug,
		    ) or $help )
    {
	app_usage(2);
    }
    app_ident() if $ident;
}

sub app_ident {
    print STDERR ("This is $my_package [$my_name $my_version]\n");
}

sub app_usage {
    my ($exit) = @_;
    app_ident();
    print STDERR <<EndOfUsage;
Usage: $0 [options] [file ...]
    -debug		enable debugging
    -help		this message
    -ident		show identification
    -verbose		verbose information
EndOfUsage
    exit $exit if defined $exit && $exit != 0;
}
