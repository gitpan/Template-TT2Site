package Template::TT2Site;

( $VERSION ) = '$Revision: 1.4 $ ' =~ /\$Revision:\s+([^\s]+)/;

# NOTE: This is a documentation-only module.

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

=head2 Structure

A TT2Site site is configured to take templates from two sources: from
the local directory, and from the C<TT2SITE_LIB>. The templates in the
C<TT2SITE_LIB> directory provide (almost) all the necessary
information to create the site (except for the contents, of course),
the library templates can be overruled locally to customize a
particular site.

The library templates reside in the C<lib> directory. Its major
subdirectories are C<config> (configuration data), C<page> (page
formatting), and C<util> (utility functions).

For the time being, the contents of the files need to be taken as a
guide how to write your own. Here is a short description of some
files:

=over 4

=item site/main

This file controls which other files from the site directory are taken
into account.

=item site/config

The site data like title and subject. This file must be overridden
with actual data.

=item site/images

The definition of images to be used with the C<util/image> template
function.

=item site/lang

The definition of the languages to be used by this site.

=item page/wrapper

This fike controls what templates are applied when processing user
files.

=item page/html

This template provides the general HTML structure of the generated
pages.

=item page/layout

This template defines the structure of the generated pages. It uses
the familiar table approach with cells containing the logo, header,
menu, contents, footer, and so on.

=back

=head2 Getting Started

B<Template::TT2Site> needs to be installed before it can be
used. You can do this by unpacking the kit it in an arbitrary
location, and issue the following commands:

  perl Build.PL
  Build
  Build install

(To see what gets installed, and where, use the target C<fakeinstall>
instead of C<install>).

Alternatively, you can use the C<CPAN> or C<CPANPLUS> tools to install
C<t2site> for you.

Note that the last command requires write access to your local Perl
installtion.

(To see what gets installed, and where, use the target C<fakeinstall>
instead of C<install>).

To set up a new C<TT2Site> site, create a new directory. In this
directory, issue the following command:

  $ tt2site setup

This will populate the directory with the necessary files and
directories to create the web site. You can now use the C<tt2site>
program with the following subcommands:

=over 4

=item *

B<build> (default)

Run the C<ttree> application to update all site data.

=item *

B<rebuild>

Run C<ttree> to completely rebuild all site data.

=item *

B<clean>

Cleanup the generated data (and some other things, like editor backup
files).

=item *

B<realclean>

Cleanup the generated data and the files originally installed with the
setup. If you modified any of them, you'll lose your changes.

=back

Almost for certain, you'll have to create in the C<lib> directory, the
templates C<config/site> and C<config/images>. If you want to make a
multi-language site you need to create an appropriate C<config/lang>.
But in many cases this will be all you need to get started creating
your web pages.

=head2 Menu Construction

Most web sites use a menu to navigate. B<Template::TT2Site>
automatically creates the menu, using B<.map> files placed in the
directories to navigate. The avantage of B<.map> files is that they
can easily be maintained with the directory data, and directories can
be moved to another location taking the map data with them.

The B<.map> files contain lines as follows:

  menu "Title" target

The target will appear in the menu as "Title".
The target can be an HTML page (if the file I<target>C<.html> exists),
a directory (if it exists, introducing a new level of navigation),
otherwise it will be taken to be an arbitrary URL.

In addition, the top level C<.map> must contain an entry

  title "Menu Title"

=head2 Multi-language Sites

To create a multi-language site, specify the supported languages in the
B<site.lang> variable (file B<config/lang>) using standard ISO codes
for the languages, e.g.,

  site.languages = [ 'en', 'nl' ]

Consult the supplied B<config/lang> for details.

A multi-language site contains one top-level C<index.html>, and
sub-trees of information in directories named after the language code.
When set up this way, each page, e.g., C<en/product/desc.html> will be
automatically linked to C<nl/product/desc.html>, and vice versa.

=head1 EXAMPLE SITES

Two example sites are included in the distribution. C<sample0> is a
simple site basically containing this documentation. C<sample1> is the
same site in multi-language form. To use either site, change to the
appropriate directory, and issue the commands:

  $ tt2site setup
  $ tt2site build
  ... point your browser at html/index.html ...
  $ tt2site realclean

=head1 DEPENDENCIES

B<Template::TT2Site> requires the following Perl modules, all
available on CPAN:

=over 4

=item *

Template::Toolkit, version 2.13 (preferrably 2.14) or later.

B<Template::TT2Site> uses the B<ttree> tool, which is assumed to be
available in your execution path.

=item *

AppConfig. This is used by the B<ttree> tool.

=back

=head1 BUGS AND PROBLEMS

This product is better than this documentation.

=head1 AUTHOR AND CREDITS

Johan Vromans (jvromans@squirrel.nl) wrote this software.

Many things were borrowed and adapted from the Template Toolkit
materials and the Badger book.

Web site: L<http://www.squirrel.nl/people/jvromans/tt2site/index.html>.

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

1;

# $Id: TT2Site.pm,v 1.4 2004/12/10 22:08:56 jv Exp $
