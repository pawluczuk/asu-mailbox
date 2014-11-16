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
$mailprog = '/usr/sbin/sendmail';

# change this to your own email address

$recipient = 'mpawluc1@mion.elka.pw.edu.pl';
 
# this opens an output stream and pipes it directly to the 
# sendmail program.  If sendmail can't be found, abort nicely 
# by calling the dienice subroutine (see below)

open (MAIL, "|$mailprog -t") or dienice("Can't access 
$mailprog!\n");

# here we're printing out the header info for the mail 
# message. You must specify who it's to, or it won't be 
# delivered:

print MAIL "To: $recipient\n";

# Reply-to can be set to the email address of the sender, 
# assuming you have actually defined a field in your form
# called 'email'.

print MAIL "Reply-to: $FORM{'email'} ($FORM{'name'})\n";

# print out a subject line so you know it's from your form cgi.
# The two \n\n's end the header section of the message.  
# anything you print after this point will be part of the 
# body of the mail.

print MAIL "Subject: Form Data\n\n";

# here you're just printing out all the variables and values, 
# just like before in the previous script, only the output 
# is to the mail message rather than the followup HTML page.

foreach $key (keys(%FORM)) {
    print MAIL "$key = $FORM{$key}\n";
}

# when you finish writing to the mail message, be sure to 
# close the input stream so it actually gets mailed.

close(MAIL);

# now print something to the HTML page, usually thanking 
# the person for filling out the form, and giving them a 
# link back to your homepage

print <<EndHTML;
<h2>Thank You</h2>
Thank you for writing.  Your mail has been delivered.<p>
Return to our <a href="index.html">home page</a>.
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