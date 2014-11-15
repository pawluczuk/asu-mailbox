#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use HTML::Template;
use Path::Class;
use autodie;

print "Conent-type: text/html\n\n";

my $file = file("/home/monika/mbox");
my $content = $file->slurp();
my $file_handle = $file->openr();

my $query = new CGI();
my $start = $query->param('start');
my $end = $query->param('end');

print "$start \t $end";

while (my $line = $file_handle->getLine() ) {
	print "$line";
}
