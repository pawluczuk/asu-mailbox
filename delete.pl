#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use Encode;
use HTML::Template;
use Path::Class;
use autodie; # die if problem reading or writing a file

# open mailbox
my $file = file("/home/monika/mbox");
my $content = $file->slurp();
my $file_handle = $file->openr();

my $query = new CGI();
my $startLine = $query->param('start');
my $endLine = $query->param('end');

sub start {
	my $counter = 1;
	my $buffer = '';
	# Read in line at a time
	while( my $line = $file_handle->getline() ) {
		if ($counter < $startLine || $counter >= $endLine)
		{
			$buffer .= "$line";
		}
		$counter++;
	}
	$file_handle = $file->openw();
	$file_handle->print($buffer);
	#print "Content-type: text/html\n\n";
	print $query->redirect(-uri=>"/cgi-bin/inbox.pl");
}

start();
