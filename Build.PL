# Makefile.PL -- Makefile for tt2site	-*-perl-*-
# Author          : Johan Vromans
# Created On      : Tue Nov 30 18:37:07 2004
# Last Modified By: Johan Vromans
# Last Modified On: Tue Jan  4 13:30:11 2005
# Update Count    : 84
# Status          : Experimental

use strict;
use Config;
use Module::Build 0.2606;

my @scripts = qw(tt2site);

my $usrbin = "/usr/bin";
my $installscript = $Config{installscript};

print STDERR <<EOD unless $installscript eq $usrbin;

WARNING: This Build file will install a user accessible script.
The default location for user accessible scripts is
$installscript.
Please consult section "How Installation Paths are Determined"
of the Module::Build documentation section if you want to change
this location.
EOD

# 'ttree' should be in path.
checkexec("ttree");

use TT2SiteModuleBuilder;

my $build = TT2SiteModuleBuilder->new
  (
   dist_name => 'Template-TT2Site',
   dist_version => '0.91',
   license => 'perl',
   requires => {
		'Getopt::Long' => 2.1,
		'Template' => 2.13,
		'AppConfig' => 1.56,
	       },
   recommends => {
		'Getopt::Long' => 2.32,
		'Template' => 2.14,
	       },
   script_files => [ map { File::Spec->catfile("scripts", $_) } @scripts ],
   );

$build->add_build_element('setup');
$build->add_build_element('tt2lib');
$build->create_build_script;

sub checkexec {
    my ($exec) = @_;
    my $path = findbin($exec);
    if ( $path ) {
	open (my $f, "<$path") or die("Cannot open $path: $!\n");
	my $line = <$f>;
	close($f);
	if ( $line =~ m;^#!.*\bperl\b; ) {
	    print STDERR ("Good, found ttree [Perl program] in $path\n");
	}
	else {
	    print STDERR ("Found ttree in $path, but it doesn't seem".
			  " to be a Perl program.\n",
			  "TT2Site needs the Perl program to execute.\n",
			  "Please make it available.\n");
	}
    }
    else {
	print STDERR ("Hmm. Couldn't find $exec in PATH\n");
    }
}

sub findbin {
    my ($bin) = @_;
    foreach ( split(":", $ENV{PATH}) ) {
	return "$_/$bin" if -x "$_/$bin";
    }
    undef;
}
