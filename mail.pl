#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use HTML::Template;
use Path::Class;
use autodie; # die if problem reading or writing a file

#print "Content-Type: text/html\n\n";
# open the html template
my $template = HTML::Template->new(filename => 'inbox.tmpl');
# open mailbox
my $file = file("/home/monika/mbox");
# Read in the entire contents of a file
my $content = $file->slurp();

# openr() returns an IO::File object to read from
my $file_handle = $file->openr();

sub start {
	my $counter = 0;
	# Read in line at a time
	while( my $line = $file_handle->getline() ) {
		# we're on the first line of the next mail
		$counter++;
		print "$counter";
	}
	
    print "Content-type: text/html\n\n";
}

start();
