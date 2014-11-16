#!/usr/bin/perl

print "Content-type:text/html\n\n";

# parse the form data.
read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
@pairs = split(/&/, $buffer);
foreach $pair (@pairs) {
    ($name, $value) = split(/=/, $pair);
    $value =~ tr/+/ /;  
    $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
    $FORM{$name} = $value;
}

# where is the mail program?
$mailprog = '/usr/sbin/ssmtp';

# mail details
$from = 'mpawluc1@mion.elka.pw.edu.pl';
$recipient = $FORM{'recipient'};
$subject = $FORM{'subject'};
$body = $FORM{'body'};

open (MAIL, "|$mailprog -t") or dienice("Can't access 
$mailprog!\n");

print MAIL "From: $from\n";
print MAIL "To: $recipient\n";
print MAIL "Subject: $subject\n\n";
print MAIL "$body";
close(MAIL);

# now print something to the HTML page, usually thanking 
# the person for filling out the form, and giving them a 
# link back to your homepage

print <<EndHTML;
<h2>Your mail has been sent</h2>
Return to inbox <a href="/cgi-bin/inbox.pl">home page</a>.
</body></html>
EndHTML

# The dienice subroutine, for handling errors.
sub dienice {
    my($errmsg) = @_;
    print "<h2>Error</h2>\n";
    print "$errmsg<p>\n";
    print "</body></html>\n";
    exit;
}
