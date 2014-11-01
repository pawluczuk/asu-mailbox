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
my $regexMailAddres = qr/^From:.*[\s<]([a-zA-Z0-9\-\.]+@[a-zA-Z0-9\-\.]+[A-Za-z]+)[\s\n>].*/;
my $regexSubject = qr/^Subject:\s(.*)/;
my $regexDate = qr/^Date:\s(.*)/;
my $currentMail = 0;
my @mailContainer;
my @onemail;
my $currentState = 0;
my %parserStates = (
	0 => 'FROM',
	1 => 'DATE',
	2 => 'SUBJECT'
);

# Read in line at a time
while( my $line = $file_handle->getline() ) {
	# start reading file: we're looking for sender 
	if ($. == 1) 
	{
		$currentState = 0;
	}
	# state FROM
	if ($currentState == 0)
	{
		if ($line =~ $regexMailAddres)
		{
			$onemail[$currentState] = $1;
			$currentState = 1;
		}
	}
	# state DATE
	if ($currentState == 1)
	{
		if ($line =~ $regexDate)
		{
			$onemail[$currentState] = $1;
			$currentState = 2;
		}
	}
	# state SUBJECT
	if ($currentState == 2)
	{
		if ($line =~ $regexSubject)
		{
			$onemail[$currentState] = $1;
			$mailContainer[$currentMail] = [$onemail[0], $onemail[1], $onemail[2]];
			$currentMail++;
			$currentState = 0;
		}
	}
	# 'from' addreses types
	# 1 email@email.com
	# 2 abc def <email@email.com>
	# 3 "abc def" email@email.com
	# 4 przedmioty@elka.pw.edu.pl [mailto:przedmioty@elka.pw.edu.pl] On =
	# 5 =?UTF-8?B?S2FtaWwgS2/FgnR5xZs=?= <K.J.Koltys@elka.pw.edu.pl>
	# 6 "=?utf-8?Q?Realtimeboard_Team?=" <notification@realtimeboard.com>
	# 7 mpawluc1 [mailto:M.E.Pawluczuk@stud.elka.pw.edu.pl]=20
}

print $mailContainer[1][1];