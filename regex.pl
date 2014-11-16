#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use HTML::Template;
use Path::Class;
use autodie; # die if problem reading or writing a file
use Encode;

# open the html template
# open mailbox
my $file = file("../mbox");
# Read in the entire contents of a file
my $content = $file->slurp();

# openr() returns an IO::File object to read from
my $file_handle = $file->openr();
my $regexBeginning = qr/^From[^:].*/;
my $regexHeaderPart = qr/^[\w\-]+:/;
#my $regexMailAddres = qr/^From:.*[\s<]([a-zA-Z0-9\-\.]+@[a-zA-Z0-9\-\.]+[A-Za-z]+)[\s\n>].*/;
my $regexMailAddress = qr/^From:\s(.*)/;
my $regexSubject = qr/^Subject:\s(.*)/;
my $regexDate = qr/^Date:\s(.*)/;
my $tableOutput = "";

sub getSender {
   my $mailAddr = $_[0];
   my $regexSimpleAddr = qr/([a-zA-Z0-9\-\.]+\@[a-zA-Z0-9\-\.]+)/;
   if ($mailAddr =~ $regexSimpleAddr)
   {
   	 	return $1;
   }
   else
   {
   		return "";
   }
   return "";
}

sub getSubject {
	my $subject = $_[0];
	my $decoded = decode('MIME-Header', $subject);
	return $decoded;
}

sub generateHeading {
	my @mailTable = @_;
	if (scalar(@mailTable) != 5)
	{
		return;
	}
	my $subject = $mailTable[1];
	my $date = $mailTable[2];
	my $startLine = $mailTable[3];
	my $endLine = $mailTable[4];

 	my $parsedMailAddr = getSender($mailTable[0]); 
 	my $parsedSubject = getSubject($mailTable[1]);

 	#print $parsedSubject, "\n";

 	$tableOutput .= "$parsedMailAddr";
	$tableOutput .= "$parsedSubject";
	
}

sub start {
	my $mailBeginning = 0;
	my $mailAddress = 0;
	my $subject = 0;
	my $mailAddressDefined = 0;
	my $subjectDefined = 0;
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
			$mailAddressDefined = 0;
			$subjectDefined = 0;
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
			if ($line =~ $regexHeaderPart)
			{
				$mailAddress = 0;
				$subject = 0;
			}

			if ($line =~ $regexMailAddress && $mailAddressDefined == 0)
			{	
				$mailAddress = 1;
				$mailAddressDefined = 1;
				$onemail[0] .= $1;
			}

			if ($line !~ $regexHeaderPart && $mailAddress == 1)
			{
				$onemail[0] .= $line;
			}

			if ($line !~ $regexHeaderPart && $subject == 1)
			{
				$onemail[1] .= $line;
			}

			if ($line =~ $regexSubject && $subjectDefined == 0)
			{
				$mailAddress = 0;
				$subject = 1;
				$subjectDefined = 1;
				$onemail[1] = $1;
			}

			if ($line =~ $regexDate)
			{
				$mailAddress = 0;
				$subject = 0;
				$onemail[2] = $1;
			}
		}
	}
	#print $tableOutput;
}

start();
