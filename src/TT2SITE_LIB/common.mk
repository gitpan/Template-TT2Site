# $Id: common.mk,v 1.5 2004/12/05 17:20:34 jv Exp $

PERL := perl

build : setup
	$(PERL) $(TT2SITE_LIB)/bin/build.pl -f etc/ttree.cfg

rebuild : setup
	$(PERL) $(TT2SITE_LIB)/bin/build.pl -f etc/ttree.cfg -a

setup : .setupdone

.setupdone :
	$(PERL) $(TT2SITE_LIB)/setup/bin/configure.pl
	cp $(TT2SITE_LIB)/setup/data/generic.mk Makefile
	touch .setupdone

clean ::
	rm -rf html
	find * -name '*~' -exec rm {} \;

realclean :: clean
	@echo "WARNING: Your customisations to copied files will be lost!"
	@echo -n "Hit Enter to continue, Control-C to cancel "; head -1 > /dev/null
	rm -f Makefile
	find $(TT2SITE_LIB)/setup/data -type f -name '*.???' \
	   -printf "rm -f %P\n" | sh -x
	rm -f .setupdone

