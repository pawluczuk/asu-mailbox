#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use Encode;
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

my $regexBeginning = qr/^From[^:].*/;
my $regexHeaderPart = qr/^[\w\-]+:/;
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

sub start {
	my $readingMailAddress = 0;
	my $readingSubject = 0;
	my $mailAddressDefined = 0;
	my $subjectDefined = 0;
	my $counter = 1;
	my $mail = "";
	my $from = "";
	my $subject = "";
	my $date = "";
	# Read in line at a time
	while( my $line = $file_handle->getline() ) {
		if ($counter >= $startLine && $counter < $endLine)
		{
			$mail .= $line;
			if ($line =~ $regexHeaderPart)
			{
				$readingMailAddress = 0;
				$readingSubject = 0;
			}

			if ($line =~ $regexMailAddress && $mailAddressDefined == 0)
			{	
				$readingMailAddress = 1;
				$mailAddressDefined = 1;
				$from .= $1;
			}

			if ($line !~ $regexHeaderPart && $readingMailAddress == 1)
			{
				$from .= $line;
			}

			if ($line !~ $regexHeaderPart && $readingSubject == 1)
			{
				$subject .= $line;
			}

			if ($line =~ $regexSubject && $subjectDefined == 0)
			{
				$readingMailAddress = 0;
				$readingSubject = 1;
				$subjectDefined = 1;
				$subject .= $1;
			}

			if ($line =~ $regexDate)
			{
				$readingMailAddress = 0;
				$readingSubject = 0;
				$date .= $1;
			}
		}
		$counter++;
	}

	$subject = getSubject($subject);
	$from = getSender($from);
	$template->param(SUBJECT => $subject);
	$template->param(DATE => $date);
	$template->param(FROM => $from);
	$template->param(MAIL => $mail);
	print "Content-type: text/html\n\n", $template->output;
}

start();
