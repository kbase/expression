use strict;


my @elements_to_ignore = @ARGV;

foreach my $line (<STDIN>) {
    my $ok_to_print = 1;
    foreach my $element_to_ignore (@elements_to_ignore)
    {
	if ($line =~ m/Entity $element_to_ignore has no ID/)
	{
	    $ok_to_print = 0;
	}
    }
    if ($ok_to_print == 1)
    {
	print $line;
    }
}
