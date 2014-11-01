#!usr/bin/perl
use strict;
use warnings;

use Path::Class;
use autodie; # die if problem reading or writing a file

my $file = file("../mbox");

# Read in the entire contents of a file
my $content = $file->slurp();

# openr() returns an IO::File object to read from
my $file_handle = $file->openr();
my $regexBeginning = qr/^From[^:].*/;
#my $regexMailAddres = qr/^From:.*[\s<]([a-zA-Z0-9\-\.]+@[a-zA-Z0-9\-\.]+[A-Za-z]+)[\s\n>].*/;
my $regexMailAddres = qr/^From:.*[\s<](.*)[\s>].*/;
my $regexSubject = qr/^Subject:\s(.*)/;
my $regexDate = qr/^Date:\s(.*)/;
my $currentMail = 0;
my @mailContainer;
my $currentState = 0;
my %parserStates = (
	0 => 'FROM',
	1 => 'DATE',
	2 => 'SUBJECT'
);


sub generateHeading {
	my @mailTable = @_;
}

sub getOneMail {
	my $mail = $_[0];
	my @onemail;
	foreach my $line (split /\n/ ,$mail) {
	    if ($line =~ $regexMailAddres)
		{	#print "$line\n";
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
	#print "$onemail[0]\n";
	if ($onemail[0] && $onemail[1] && $onemail[2])
	{
		generateHeading(@onemail);
	}
}

sub start {
	my $mailBeginning = 0;
	my $onemail = "";
	my $startline = 0;
	my $endline = 0;
	# Read in line at a time
	while( my $line = $file_handle->getline() ) {
		if ($line =~ $regexBeginning && $mailBeginning == 1)
		{
			if ($onemail)
			{
				$endline = $.;
				getOneMail($onemail);
			}
			$onemail = "";
			$startline = $.;
			$onemail .= $line;
		}
		if ($line =~ $regexBeginning && $mailBeginning == 0) 
		{
			$startline = $.;
			$onemail .= $line;
			$mailBeginning = 1;
		}
		if ($line !~ $regexBeginning && $mailBeginning == 1)
		{
			$onemail .= $line;
		}
	}
}

start();