package TT2SiteModuleBuilder;

use strict;
use vars qw( $VERSION );

( $VERSION ) = '$Revision: 1.2 $ ' =~ /\$Revision:\s+([^\s]+)/;

use File::Spec;
use File::Find;
use File::Basename;

use base qw(Module::Build);

sub _cf { File::Spec->catfile(@_) }

sub process_setup_files {
    shift->process___files("setup");
}

sub process_tt2lib_files {
    shift->process___files("tt2lib");
}

sub process___files {
    my ($self, $topic) = @_;

    my @files;
    find({ wanted => sub {
	     return if /^\./;
	     return if /~\z/;
	     if ( /^CVS\z/s ) {
		 $File::Find::prune = 1;
		 return;
	     }
	     return unless -f $_;
	     push(@files, $File::Find::name);
	   },
	   follow => 1,
	 }, $topic);

    foreach my $file ( @files ) {
	my ($name, $path, $sfx) = fileparse($file);
	$path =~ s;^tt2lib/;lib/;;
	my $dest = _cf(qw(blib lib Template TT2Site), $path);
	my $res = $self->copy_if_modified(from => $file,
					  to => _cf($dest, $name));
    }
}

1;

__END__

=head1 NAME

TT2SiteModuleBuilder - Helper for Module::Build

=head1 SYNOPSIS

  my $build = TT2SiteModuleBuilder->new(...);
  $build->add_build_element('setup');
  $build->create_build_script;

=head1 DESCRIPTION

This module is a helper for Module::Build, to process some TT2Site
specific files.

It is only used during the build/install phase.

=head1 AUTHOR AND CREDITS

Johan Vromans (jvromans@squirrel.nl) wrote this software.

=head1 SEE ALSO

L<Module::Build>, L<Module::Build::Cookbook>.

=head1 COPYRIGHT AND DISCLAIMER

This software is Copyright 2004 by Squirrel Consultancy. All
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
