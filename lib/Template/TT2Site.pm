package Template::TT2Site;

use strict;
use vars qw($VERSION);

$VERSION = sprintf("%d.%02d", q$Revision: 1.42 $ =~ /(\d+)\.(\d+)/);

use strict;

=head1 NAME

Template::TT2Site - Create standard web sites with the Template Toolkit

=head1 SYNOPSIS

  $ mkdir NewSite
  $ cd NewSite
  $ tt2site setup
  ... make your pages ...
  $ tt2site build
  ... point your browser at html/index.html ...

C<tt2site> is just a wrapper program. C<tt2site setup> is equivalent
to C<perl -MTemplate::TT2Site -e setup>, and so on.

=head1 DESCRIPTION

B<Template::TT2Site> is a framework to create web sites using the
Template Toolkit.

The technical structure of the site is patterned after the method
described in I<The Badger Book>. The structure has been slightly
simplified for ease of use, and a couple of neat features are added:

=over 4

=item *

The resultant site is position independent, i.e., it only uses
relative URLs to the extent possible. This makes it easy to build
partial sites, and to relocate the contents.

=item *

The necessary means are provided to create multi-language sites, where
each page gets a link to its translations.

=item *

The 'site.map' hash, required for site navigation, is created
automatically using minimal, position independent, directions.

=back

This module, B<Template::TT2Site>, provides the necessary methods to
setup and maintain a site. It is used by the wrapper program,
B<tt2site>.

For more information, see the
Web site: L<http://www.squirrel.nl/people/jvromans/tt2site/index.html>.

=head1 METHODS

The following methods are exported by default.

=over 8

=item B<setup>

Initialises a new site directory. This command must be run once before
you can do anything else.

=item B<build>

Run the C<ttree> application to update the site files.

=item B<rebuild>

Run the C<ttree> application to completely rebuild all site files.

=item B<clean>

Cleans the generated HTML files, and editor backup files.

=item B<realclean>

Cleans the generated HTML files, editor backup files, and all files
originally installed using the B<setup> command.

You'll be asked for confirmation before your files are removed.

=back

All other methods are for internal use only.

=head1 AUTHOR

Johan Vromans <jvromans@squirrel.nl>

=head1 COPYRIGHT

This programs is Copyright 2004, Squirrel Consultancy.

This program is free software; you can redistribute it and/or modify
it under the terms of the Perl Artistic License or the GNU General
Public License as published by the Free Software Foundation; either
version 2 of the License, or (at your option) any later version.

=head1 DEPENDENCIES

B<Template::TT2Site> requires the following Perl modules, all
available on CPAN:

=over 4

=item *

B<Template::Toolkit>, version 2.13 (preferrably 2.14) or later.

B<Template::TT2Site> uses the B<ttree> tool, which is assumed to be
available in your execution path I<as a Perl script>.

=item *

B<AppConfig>. This is used by the B<ttree> tool.

=back

=head1 BUGS AND PROBLEMS

This product is better than this documentation.

=head1 AUTHOR AND CREDITS

Johan Vromans (jvromans@squirrel.nl) wrote this software.

Many things were borrowed and adapted from the Template Toolkit
sample materials and the Badger book.

Web site: L<http://www.squirrel.nl/people/jvromans/tt2site/index.html>.

=head1 COPYRIGHT AND DISCLAIMER

This software is Copyright 2004-2005 by Squirrel Consultancy. All
rights reserved.

This program is free software; you can redistribute it and/or modify
it under the terms of either: a) the GNU General Public License as
published by the Free Software Foundation; either version 1, or (at
your option) any later version, or b) the "Artistic License" which
comes with Perl.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See either the
GNU General Public License or the Artistic License for more details.

=cut

use base qw(Exporter);
our (@EXPORT) = qw(build setup rebuild clean realclean);

my $my_name = __PACKAGE__;

my $realclean = 0;
my $verbose = 0;		# more verbosity

my $debug = 0;			# debugging
my $trace = 0;			# trace (show process)
my $test = 0;			# test mode.

################ Presets ################

my $setupdone = ".setupdone";
my $ttree = "ttree";
my $sitelib;

################ The Process ################

use File::Spec;
use File::Path;
use File::Find;
use Carp;

################ Subroutines ################

sub execute {
    my ($self, @args) = @_;
    local(@ARGV) = @args;
    @ARGV = qw(build) unless @ARGV;
    my $cmdname = lc(shift(@ARGV));
    my $cmd = __PACKAGE__->can($cmdname) if $cmdname =~ /^[a-z]/;
    _usage(1) unless $cmd;
    $cmd->(@ARGV);
}

sub _preamble($;$) {
    $my_name .= "::" . shift;
    _check_lib();
    _options(@_);
    _find_ttree();
    _check_setup() unless @_ && $_[0];
}

sub setup {
    _preamble("setup", 1);

    if ( -f $setupdone ) {
	carp("$my_name: \"setup\" already done\n");
	return 0;
    }

    my $dir  = File::Spec->rel2abs(File::Spec->curdir);
    my $lib  = _cf($sitelib, qw(Template TT2Site));
    my $skel = _cf($lib, qw(setup data));

    unshift(@ARGV,
	    '-s', $skel,
	    '-d', $dir,
	    '-f', _cf($lib, qw(setup etc ttree.cfg)),
	    '--define', "dir=$dir",
	    '--define', "sitelib=". $lib,
	    '--define', "tmplsrc=src",
	    '--define', "debug=$debug");

    unshift(@ARGV, "perl", $ttree);

    warn("+ @ARGV\n") if $trace;
    system $^X @ARGV;
    croak("$my_name: ttree did not complete\n") if $?;
    croak("$my_name: ttree did not complete\n")
      unless -f _cf(qw(etc ttree.cfg));

    chmod(0664, _cf(qw(etc ttree.cfg)));
    chmod(0664, _cf(qw(src css site.css)));
    chmod(0664, _cf(qw(src debug.html)));
    open(my $fh, ">$setupdone");

    return 0;
}

sub build {
    _preamble("build");

    my (@args) = qw(-f etc/ttree.cfg);

    unshift(@args, "perl", "-Mlib=$sitelib", $ttree);
    warn("+ @args\n") if $trace;
    system $^X @args;
    croak("$my_name: ttree did not complete\n$@") if $?;
    return 0;
}

sub rebuild {
    _preamble("rebuild");

    my (@args) = qw(-a -f etc/ttree.cfg);

    unshift(@args, "perl", "-Mlib=$sitelib", $ttree);
    warn("+ @args\n") if $trace;
    system $^X @args;
    croak("$my_name: ttree did not complete\n$@") if $?;
    return 0;
}

sub publish {
    _preamble("publish");

    croak("$my_name: \"publish\" not yet implemented\n");
    return 0;
}

sub clean {
    _preamble("clean") unless @_ && $_[0];

    rmtree(["html"], $verbose, 1);
    find(sub {
	     if ( /~$/ ) {
		 warn("+ rm $File::Find::name\n");
		 unlink($File::Find::name);
	     }
	 }, ".");
    return 0;
}

sub realclean {
    _preamble("realclean");
    print STDERR ("WARNING: ",
		  "Your customisations to copied files will be lost!\n",
		  "Hit Enter to continue, Control-C to cancel ");
    <STDIN>;

    clean(1);

    my @files;
    my @chfiles;
    use Cwd;
    my $cur = getcwd;
    chdir(_cf($sitelib, qw(Template TT2Site setup data)));
    find(sub {
	     return unless -f $_;
	     push(@{_differ($_, _cf($cur, $File::Find::name))
		  ? \@chfiles : \@files}, $File::Find::name);
	 }, ".");
    chdir($cur);

    if ( @chfiles ) {
	print STDERR ("WARNING: ",
		      "The following files were modified:\n",
		      "\t", join("\n\t", @chfiles), "\n",
		      "Your changes will be lost!\n",
		      "Hit Enter to continue, Control-C to cancel ");
	<STDIN>;
    }

    foreach my $file ( @files, @chfiles, $setupdone ) {
	warn("+ rm $file\n");
	unlink($file);
    }

    foreach my $dir ( _cf(qw(src images)),
		      _cf(qw(src css)),
		      _cf(qw(src)),
		      _cf(qw(etc)) ) {
	rmdir($dir) && warn("+ rmdir $dir\n");
    }

    return 0;
}

################ Helpers ################

sub _find_ttree {
    $ttree = "ttree";
    foreach my $p ( File::Spec->path ) {
	if ( -s "$p/$ttree.pl" ) {
	    $ttree = "$p/$ttree.pl";
	    last;
	}
	if ( -s "$p/$ttree" && -x _ ) {
	    $ttree = "$p/$ttree";
	    last;
	}
    }
    if ( $ttree eq "ttree" ) {
	croak("$my_name: Could not find ttree or ttree.pl in PATH\n")
    }
    else {
	open (my $f, "<$ttree") or die("Cannot open $ttree: $!\n");
	my $line = <$f>;
	close($f);
	if ( $line !~ m;^#!.*\bperl\b; ) {
	    croak("Found ttree in $ttree, but it doesn't seem".
		  " to be a Perl program.\n",
		  "TT2Site needs the Perl program to execute.\n",
		  "Please make it available.\n");
	}
    }
}

sub _check_setup {
    croak("$my_name: Please execute \"setup\" first\n")
      unless -f $setupdone;
}

sub _cf { File::Spec->catfile(@_) }

sub _check_lib {

    my $lib = $ENV{TT2SITE_LIB};
    if ( $lib ) {
	unless ( -f _cf($lib, qw(Template TT2Site.pm)) ) {
	    die("$my_name: Installation problem!\n",
		"Cannot find Template::TT2Site in $lib\n",
		"Please verify your installation, or set environment variable ",
		"TT2SITE_LIB to the directory containing Template/TT2Site.pm\n");
	}
	$sitelib = $lib;
    }
    else {
	foreach $lib ( @INC ) {
	    # warn("Trying: " . _cf($lib, qw(Template TT2Site.pm)) . "\n");
	    $sitelib = $lib, last if -f _cf($lib, qw(Template TT2Site.pm))
	}
    }

    unless ( -f _cf($sitelib, qw(Template TT2Site.pm)) ) {
	die("$my_name: Installation problem!\n",
	    "Cannot find Template::TT2Site in $sitelib or \@INC\n",
	    "Please verify your installation, or set environment variable ",
	    "TT2SITE_LIB to the directory containing Template/TT2Site.pm\n");
    }
}

sub _differ {
    # Perl version of the 'cmp' program.
    # Returns 1 if the files differ, 0 if the contents are equal.
    my ($old, $new) = @_;
    unless ( open (F1, $old) ) {
	print STDERR ("$old: $!\n");
	return 1;
    }
    unless ( open (F2, $new) ) {
	print STDERR ("$new: $!\n");
	return 1;
    }
    my ($buf1, $buf2);
    my ($len1, $len2);
    binmode(F1);
    binmode(F1);
    while ( 1 ) {
	$len1 = sysread (F1, $buf1, 10240);
	$len2 = sysread (F2, $buf2, 10240);
	return 0 if $len1 == $len2 && $len1 == 0;
	return 1 if $len1 != $len2 || ( $len1 && $buf1 ne $buf2 );
    }
}

################ Command Line Options ################

use Getopt::Long 2.00;

sub _options {

    GetOptions(verbose	   => \$verbose,

	       # development options
	       test	   => \$test,
	       trace	   => \$trace,
	       debug	   => \$debug)
      or usage(2);

    # Post-processing.
    $trace |= ($debug || $test);
}

1;
