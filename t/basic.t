#!/usr/bin/perl

use Test::More tests => 3;

BEGIN { use_ok("Template::TT2Site"); }
BEGIN { use_ok("Template::TT2Site::Plugin::Mapper"); }

if ( $ENV{TT2SITE_LIB} ) {
    diag("\n".
	 "You have the environment variable TT2SITE_LIB set.\n".
	 "This is no longer necessary, and may cause malfunctioning.\n".
	 "Please remove the setting before proceeding.\n");
    ok(0, "TT2SITE_LIB");
}
else {
    ok(1, "TT2SITE_LIB");
}
