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
my $content = $file->slurp(iomode => '<:encoding(UTF-8)');

# openr() returns an IO::File object to read from
my $file_handle = $file->openr();
my $regexBeginning = qr/^From[^:].*/;
#my $regexMailAddres = qr/^From:.*[\s<]([a-zA-Z0-9\-\.]+@[a-zA-Z0-9\-\.]+[A-Za-z]+)[\s\n>].*/;
my $regexMailAddres = qr/^From:.*[\s<]+(.*)[\s>].*/;
my $regexSubject = qr/^Subject:\s(.*)/;
my $regexDate = qr/^Date:\s(.*)/;

my $tableOutput = "";
sub generateHeading {
	my @mailTable = @_;
	if (scalar(@mailTable) != 5)
	{
		return;
	}
	my $mailAddr = $mailTable[0];
	my $subject = $mailTable[1];
	my $date = $mailTable[2];
	my $startLine = $mailTable[3];
	my $endLine = $mailTable[4];
	$tableOutput .= "<tr><td>$mailAddr</td>";
	$tableOutput .= "<td>$subject</td>";
	$tableOutput .= "<td>$date</td></tr>";
}

sub start {
	my $mailBeginning = 0;
	my @onemail = ();
	my $counter = 0;
	# Read in line at a time
	while( my $line = $file_handle->getline() ) {
		# we're on the first line of the next mail
		if ($line =~ $regexBeginning && $mailBeginning == 1)
		{
			if (scalar(@onemail) == 4)
			{
				$onemail[4] = $.;
				generateHeading(@onemail);
				$counter++;
			}
			@onemail = ();
			$mailBeginning = 0;
		}
		# we're iterating through new mail
		if ($line =~ $regexBeginning && $mailBeginning == 0) 
		{
			$onemail[3] = $.;
			$mailBeginning = 1;
		}
		# we're in the middle of the mail
		if ($line !~ $regexBeginning && $mailBeginning == 1)
		{
			if ($line =~ $regexMailAddres)
			{	
				$onemail[0] = $1;
			}
			if ($line =~ $regexSubject)
			{
				$onemail[1] = $1;
			}
			if ($line =~ $regexDate)
			{
				$onemail[2] = $1;
			}
		}
	}
	# fill in some parameters
	$template->param(HOME => "bb");
    	$template->param(PATH => "aa");
	$template->param(TABLE => $tableOutput);
	# send the obligatory Content-Type and print the template output
    	print "Content-type: text/html\n\n", $template->output;
	#print $template->output;
}

start();
