#------------------------------------------------------------------------------#
# Documentation Section                                                        #
#------------------------------------------------------------------------------#

=head1 NAME

fetchsampleannot.pl - extracts sample annotation (PO, EO) from old plant expression DB.

=head1 SYNOPSIS

 fetchsampleannot.pl [--? --m] --p --l --v --o
   --p <provider identifier: data loader's email address e.g. kumari@cshl.edu>
   --l <load space identifier: e.g. PlantExprAffyPipeline>
   --v <version number: positive integet starting from 1>
   --i <input list of good GSEs and GSMs>
   --o <directory for files to output>

=head1 DESCRIPTION

This scripts extracts each sample's ontology annotation (PO, EO) from old expression
database (devdb1.newyork.kbase.us/kbase_plant OR db1.chicago.kbase.us) and outputs
them to sample_annotation.tab file in KBase expression exchange format for further 
processing by the expression DB loading script.

=head1 OPTIONS

=over 4

=item B<--p>

        Required parameter for the data provider's identifier. See the Appendix
        section (source-id structure - [provider ID]:[load ID].[version]|[data ID])
        of the expression exchange service for more details. Provider-id usually is
        the email address of the data loader.

=item B<--l>

        Required parameter for the data load portion of the source-id -
        [provider ID]:[load ID].[version]|[data ID]. For example,
        PlantExprAffyPipeline can be used as the load-id for plant expression data.

=item B<--v>

        Required parameter corresponding to the version part of the load-id as
        defined in the source-id structure section of the Appendix of the
        expression exchange service.

=item B<--i>

	Required parameter to input list of good GSEs and GSMs that didn't produce
	any error during geotoexch.pl processing. This must be the file generated
	by geotoexch.pl named (Good_GSE_GSM) in the following format:
	GSE<#>\tGSM<#>\tSampleSourceID

=item B <--o>

	Optional parameter; tell the directory where the output files should go.
	Default location for output files is the current working directory.

=item B<--help or -? or -h>

        Print quick help message on using fetchexprdata.pl and exit

=item B<--man or -m>

        Print complete documentation on using fetchexprdata.pl and exit

=back

=head1 AUTHOR

Dr. Sunita Kumari

=head1 DATE

Fri September 01 10:45:00 EST 2013

=head1 USAGE EXAMPLE

How to use fetchsampleannot.pl
 perl fetchsampleannot.pl --p=kumari@cshl.edu --l=PlantExprAffyPipeline --v=1
 perl fetchsampleannot.pl --m # use this option only to read the documentation

=cut

#------------------------------------------------------------------------------#
# Import Section: Import perl modules on which this script depends             #
#------------------------------------------------------------------------------#
use Getopt::Long;
use Pod::Usage;
use strict;
use warnings;
use DBI;
use DateTime;

#------------------------------------------------------------------------------#
# Boiler plate code for extracting command-line options & displaying help/man  #
#------------------------------------------------------------------------------#

my $help;
my $man;
my %opts = ("help" => \$help, "man" => \$man);
Getopt::Long::Configure("bundling", "auto_abbrev");
GetOptions(\%opts, "help|?|h", "man|m", "p=s", "l=s", "v=i", "i=s", "o=s");
pod2usage(1) if $help;
pod2usage(-verbose => 2) if $man;

#------------------------------------------------------------------------------#
# Start: fetchsampleannot.pl Main Logic                                        #
#------------------------------------------------------------------------------#

# Common Data Fields: source-id base string
my $providerId = $opts{'p'} || die pod2usage(1); #"kumari\@cshl.edu";
my $loadId = $opts{'l'} || die pod2usage(1);     #"PlantExprAffyPipeline";
my $ver = $opts{'v'} || die pod2usage(1);        #1;
my $in = $opts{'i'} || die pod2usage(1);         # Good_GSE_GSM file
my $odir = $opts{'o'};
$odir = "." if(!defined($odir));

my $sourceIdBase = "$providerId:$loadId.$ver|";
my $dt = DateTime->now->ymd;

my %gses = ();
my %samples = ();
open(IN, "<$in");
while(<IN>) {
	chomp;
	my @a = split /\t/;
	$gses{$a[0]} = 1;
	$samples{$a[1]} = $a[2];
}
close IN;

my $dbh = DBI->connect('DBI:mysql:kbase_plant;host=devdb1.newyork.kbase.us', 'networks_pdev', '', {'RaiseError' => 1}) || die "Can't open database connection\n";

# open file to output ontologies in exchange format
open(SA, ">$odir/sample_annotation.tab");
print SA "source-id\tontology-id\tannotationDate\tperson-id\tsample-id\n";

$|++;  # Turn off STDOUT buffering; $|-- will enable the buffering again.

print "\rProcessing PO ...";
# Obtain list of all samples' PO annotation
my $sth = $dbh->prepare('select sid_extern as GSM, poid_extern as PO from sample a, smpl_po b, po c where a.sid=b.sid and b.poid=c.poid');
$sth->execute();
while(my $ref = $sth->fetchrow_arrayref()) {
	my $srcId = $samples{$$ref[0]};
	next if(!defined($srcId));
	my $po = $$ref[1];
	$po =~ s/:/_/g;
	print SA "$sourceIdBase".$$ref[0]."_$po\t".$$ref[1]."\t$dt\t.\t$srcId\n";
}
$sth->finish();

print "\rProcessing EO ...";
# Obtain list of all samples' EO annotation
$sth = $dbh->prepare('select sid_extern as GSM, eoid_extern as EO from sample a, smpl_eo b, eo c where a.sid=b.sid and b.eoid=c.eoid');
$sth->execute();
while(my $ref = $sth->fetchrow_arrayref()) {
	my $srcId = $samples{$$ref[0]};
	next if(!defined($srcId));
	my $eo = $$ref[1];
	$eo =~ s/:/_/g;
	print SA "$sourceIdBase".$$ref[0]."_$eo\t".$$ref[1]."\t$dt\t.\t$srcId\n";
}
$sth->finish();

print "\n";
$|--; # enable STDOUT buffering again

# close database connection
$dbh->disconnect();
close(SA);
