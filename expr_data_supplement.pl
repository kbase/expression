#------------------------------------------------------------------------------#
# Documentation Section                                                        #
#------------------------------------------------------------------------------#

=head1 NAME

expr_data_supplement.pl - supplements expression data object with additional info.

=head1 SYNOPSIS

 expr_data_supplement.pl [--? --m] --i --s --r --o
   --i <input expression object file (hash dump)>
   --s <input supplemental information file (sample ontology)>
   --r <input supplemental information file (sample relicate ID)>
   --o <output file name>

=head1 DESCRIPTION

This scripts supplemnets expression object with sample ontology information.

=head1 OPTIONS

=over 4

=item B<--i>

        Required parameter to input expression data object file. The file must be
        the perl hash structure dump.

=item B<--s>

        Required parameter to input sample ontologies. The file must be a tab
        delimited ASCII text file (sample_id\tcomma-separated_list_of_PO/EO_Ids).

=item B<--r>
	Optional input parameter to supplement expression metadata with sample
	replicate information. The input file must be tab delimited ASCII text
	file (sample_id\tsample_short_description\tsample_replicate_id).

=item B<--o>

	Output file name where this script would dump the expression data
	object (hash structure dump).

=item B<--help or -? or -h>

        Print quick help message on using expr_data_supplement.pl and exit

=item B<--man or -m>

        Print complete documentation on using expr_data_supplement.pl and exit

=back

=head1 AUTHOR

Dr. Sunita Kumari

=head1 DATE

Fri Dec 13 09:00:06 EST 2013

=head1 USAGE EXAMPLE

How to use expr_data_supplement.pl
 perl expr_data_supplement.pl --i=expr_data --s=ont --r=rep --o=expr_data_supplement
 perl expr_data_supplement.pl --m # use this option only to read the documentation

=cut

#------------------------------------------------------------------------------#
# Import Section: Import perl modules on which this script depends             #
#------------------------------------------------------------------------------#
use Getopt::Long;
use Pod::Usage;
use warnings;
use Data::Dumper;

#------------------------------------------------------------------------------#
# Boiler plate code for extracting command-line options & displaying help/man  #
#------------------------------------------------------------------------------#

my $help;
my $man;
my %opts = ("help" => \$help, "man" => \$man);
Getopt::Long::Configure("bundling", "auto_abbrev");
GetOptions(\%opts, "help|?|h","man|m","i=s","s=s","r=s","o=s");
pod2usage(1) if $help;
pod2usage(-verbose => 2) if $man;

my $inpfile = $opts{'i'} || die "Expression object file required\n".pod2usage(1);
my $ontfile = $opts{'s'} || die "Ontology annotation file required\n".pod2usage(1);
my $repfile = $opts{'r'}; # || die "Sample replicate annotation file required\n".pod2usage(1);
my $outfile = $opts{'o'} || die "Output file required\n".pod2usage(1);

#------------------------------------------------------------------------------#
# Start: expr_data_supplement.pl Main Logic                                    #
#------------------------------------------------------------------------------#

$Data::Dumper::Purity = 1;

# restore hash from the input file
open(FILE, "<$inpfile");
#undef $/;
#my $str = <FILE>;
my $str = "";
while(<FILE>) {
	$str .= $_;
}
close FILE;
$str =~ s/^GSE OBJECT //;
my $href = eval $str; warn $@ if $@;#eval{$str;};warn $@ if $@;
print "Expression object not read\n" if(!defined($href));

#redefine the default file read delimiter
#$/ = "\n";

# read ontology file
open(IN, "<$ontfile");
my %ont = ();
while(<IN>) {
        chomp;
        my @a = split/\t/;
        $ont{$a[0]} = $a[1];
}
close IN;

# read sample replicate annotation file
my %rep = ();
if(defined $repfile) {
	open(IN, "<$repfile");
	while(<IN>) {
        	chomp;
        	my @a = split/\t/;
		$rep{$a[0]} = $a[2];
	}
	close IN;
}

# supplement expression object with ontology and write it out to the file
open(O, ">$outfile");
foreach my $k (keys(%{$href->{'gseSamples'}})) {
	my @onts = split(',', $ont{$k});
        $href->{'gseSamples'}->{$k}->{'gsmOntologies'} = \@onts;
        $href->{'gseSamples'}->{$k}->{'gsmReplicateId'} = $rep{$k} if(defined $repfile);
}

# turn off STDOUT buffering i.e. flush immediately
#$| = 1;

print O "GSE OBJECT ";
print O Dumper $href;
close O;
