package TT2SiteModuleBuilder;

use strict;

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
