# Makefile.PL -- Makefile for tt2site	-*-perl-*-
# Author          : Johan Vromans
# Created On      : Tue Nov 30 18:37:07 2004
# Last Modified By: Johan Vromans
# Last Modified On: Sun Dec  5 12:59:46 2004
# Update Count    : 23
# Status          : Experimental

use strict;

# There's nothing to install, so just check around a bit.

# 'ttree' should be in path.
checkexec("ttree");

my $ok = 0;
eval {
    require Template;
    Template->import;
    if ( $Template::VERSION < 2.13 ) {
	warn("Template version 2.13 required, you have $Template::VERSION\n");
    }
    else {
	warn("Good, found Template version $Template::VERSION\n");
	$ok++;
    }
    if ( $Template::VERSION < 2.14 ) {
	warn("Template version 2.14 or later preferred\n");
    }
};
warn($@) if $@;
warn("\nWARNING: Prerequisite 'Template' version 2.13 or later not found\n")
  unless $ok;

$ok = 0;
eval {
    require AppConfig;
    AppConfig->import;
    if ( $AppConfig::VERSION < 1.56 ) {
	warn("AppConfig version 1.56 required, you have $AppConfig::VERSION\n");
    }
    else {
	warn("Good, found AppConfig version $AppConfig::VERSION\n");
	$ok++;
    }
};
warn($@) if $@;
warn("\nWARNING: Prerequisite 'AppConfig' version 1.56 or later not found\n")
  unless $ok;

use Cwd;
my $cwd = getcwd;
my $dir = $cwd . "/src/TT2SITE_LIB";
if ( $ENV{TT2SITE_LIB} ) {
    if ( $ENV{TT2SITE_LIB} ne $dir ) {
	warn("\nWARNING: Environment variable TT2SITE_LIB is set, but does\n",
	     "not point to the correct location of this installation.\n",
	     "Please correct this before using Template::TT2Site, e.g.\n",
	     "  TT2SITE_LIB=$dir; export TT2SITE_LIB   (sh)\n",
	     "  setenv TT2SITE_LIB $dir                (csh)\n");
    }
}
else {
    warn("\nNOTE: To use Template::TT2Site, please set environment variable\n",
	 "TT2SITE_LIB to the 'src/TT2SITE_LIB' directory of this installation, e.g.\n",
	 "  TT2SITE_LIB=$dir; export TT2SITE_LIB   (sh)\n",
	 "  setenv TT2SITE_LIB $dir                (csh)\n");
}

my $dirp = quotemeta($dir);

if ( $ENV{PERL5LIB} ) {
    if ( $ENV{PERL5LIB} !~ /(^|:)$dirp(:|$)/ ) {
	warn("\nWARNING: Environment variable PERL5LIB is set, but does\n",
	     "not contain the correct location of this installation.\n",
	     "Please correct this before using Template::TT2Site, e.g.\n",
	     "  PERL5LIB=\${TT2SITE_LIB}:\$PERL5LIB; export PERL5LIB   (sh)\n",
	     "  setenv PERL5LIB \${TT2SITE_LIB}:\$PERL5LIB             (csh)\n");
    }
}
else {
    warn("\nNOTE: To use Template::TT2Site, please set environment variable\n",
	 "PERL5LIB to include 'src/TT2SITE_LIB' directory of this installation, e.g.\n",
	 "  PERL5LIB=\$TT2SITE_LIB; export PERL5LIB   (sh)\n",
	 "  setenv PERL5LIB \$TT2SITE_LIB            (csh)\n");
}

warn("\n=== There's nothing needed to make or install.\n",
     "=== Use 'perldoc $dir/Template/TT2Site.pm'\n",
     "=== to read the details.\n");

sub checkexec {
    my ($exec) = @_;
    my $path = findbin($exec);
    if ( $path ) {
	print STDERR ("Good, found $path\n");
	return 1;
    }
    print STDERR ("Hmm. Couldn't find $exec in PATH\n");
    0;
}

sub findbin {
    my ($bin) = @_;
    foreach ( split(":", $ENV{PATH}) ) {
	return "$_/$bin" if -x "$_/$bin";
    }
    undef;
}
