#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use HTML::Template;
use Path::Class;
use autodie; # die if problem reading or writing a file

# open the html template
my $template = HTML::Template->new(filename => 'mail.tmpl');
# open mailbox
my $file = file("/home/monika/mbox");
my $content = $file->slurp();
my $file_handle = $file->openr();

my $query = new CGI();
my $startLine = $query->param('start');
my $endLine = $query->param('end');

sub start {
	my $counter = 1;
	my $mail = "";
	# Read in line at a time
	while( my $line = $file_handle->getline() ) {
		if ($counter >= $startLine && $counter < $endLine)
		{
			$mail .= $line;
		}
		$counter++;
	}	
	$template->param(MAIL => $mail);
	print "Content-type: text/html\n\n", $template->output;
}

start();
