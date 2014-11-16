#!/usr/bin/perl
use strict;
use warnings;
use HTML::Template;

my $template = HTML::Template->new(filename => 'newmail.tmpl');
print "Content-type: text/html\n\n", $template->output;