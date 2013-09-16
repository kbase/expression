#------------------------------------------------------------------------------#
# Documentation Section                                                        #
#------------------------------------------------------------------------------#

=head1 NAME

fetchexprdata.pl - extracts expresion values for each sample from old plant expression DB.

=head1 SYNOPSIS

 fetchexprdata.pl [--? --m] --p --l --v
   --p <provider identifier: data loader's email address e.g. kumari@cshl.edu>
   --l <load space identifier: e.g. PlantExprAffyPipeline>
   --v <version number: positive integet starting from 1>

=head1 DESCRIPTION

This scripts extracts each sample's expression values from old plant expression
database (devdb1.newyork.kbase.us/kbase_plant OR db1.chicago.kbase.us) and outputs
them in a single file that is identified by the GSE# corresponding to the samples.
The output files are KBase plant expression exchange format ready for further 
processing by the expression DB loading script. Note, the output files follow the 
measurement_<GSE#>.tab naming convention. The database loading script relying 
strictly on the exchange format naming conventions may have to drop the _<GSE#> 
portion from the file names before processing these files.

=head1 OPTIONS

=over 4

=item B<--p or -p>

        Required parameter for the data provider's identifier. See the Appendix
        section (source-id structure - [provider ID]:[load ID].[version]|[data ID])
        of the expression exchange service for more details. Provider-id usually is
        the email address of the data loader.

=item B<--l or -l>

        Required parameter for the data load portion of the source-id -
        [provider ID]:[load ID].[version]|[data ID]. For example,
        PlantExprAffyPipeline can be used as the load-id for plant expression data.

=item B<--v or -v>

        Required parameter corresponding to the version part of the load-id as
        defined in the source-id structure section of the Appendix of the
        expression exchange service.

=item B<--help or -? or -h>

        Print quick help message on using fetchexprdata.pl and exit

=item B<--man or -m>

        Print complete documentation on using fetchexprdata.pl and exit

=back

=head1 AUTHOR

Dr. Sunita Kumari

=head1 DATE

Fri Aug 20 15:24:30 EST 2013

=head1 USAGE EXAMPLE

How to use fetchexprdata.pl
 perl fetchexprdata.pl --p=kumari@cshl.edu --l=PlantExprAffyPipeline --v=1
 perl fetchexprdata.pl --m # use this option only to read the documentation

=cut

#------------------------------------------------------------------------------#
# Import Section: Import perl modules on which this script depends             #
#------------------------------------------------------------------------------#
use Getopt::Long;
use Pod::Usage;
use strict;
use warnings;
use DBI;

#------------------------------------------------------------------------------#
# Boiler plate code for extracting command-line options & displaying help/man  #
#------------------------------------------------------------------------------#

my $help;
my $man;
my %opts = ("help" => \$help, "man" => \$man);
Getopt::Long::Configure("bundling", "auto_abbrev");
GetOptions(\%opts, "help|?|h", "man|m", "p=s", "l=s", "v=i");
pod2usage(1) if $help;
pod2usage(-verbose => 2) if $man;

#------------------------------------------------------------------------------#
# Start: fetchexprdata.pl Main Logic                                           #
#------------------------------------------------------------------------------#

# Common Data Fields: source-id base string
my $providerId = $opts{'p'} || die pod2usage(1); #"kumari\@cshl.edu";
my $loadId = $opts{'l'} || die pod2usage(1);     #"PlantExprAffyPipeline";
my $ver = $opts{'v'} || die pod2usage(1);        #1;
my $sourceIdBase = "$providerId:$loadId.$ver|";

my $dbh = DBI->connect('DBI:mysql:kbase_plant;host=devdb1.newyork.kbase.us', 'networks_pdev', '', {'RaiseError' => 1, 'ShowErrorStatement' = > 1}) || die "Can't open database connection\n";

# Obtain list of all distinct GSEs from the old plant expression database.
my $sth = $dbh->prepare('SELECT distinct eid from eid2cid');
$sth->execute();
my @gses;
while(my $ref = $sth->fetchrow_arrayref()) {
	push(@gses, $$ref[0]);
}
$sth->finish();
my $numgses = $#gses+1;

# extract expression values for each sample in the input list of GSEs
$sth = $dbh->prepare("select a.at as ext_gene_id, c.signal as log2Level, b.ci as sample_id, a.fid as 'feature-id' from at2id_int a, ci2id b, expression_org c, eid2cid d where d.eid=? and d.cid=b.ci and a.id=c.geneID and b.id=c.sampleID");
$|++;  # Turn off STDOUT buffering; $|-- will enable the buffering again.
for(my $i = 0; $i < $numgses; $i++) {
	print "\rProcessing $gses[$i] (".($i+1)." of $numgses) ...";
	open(F, ">measurement_$gses[$i].tab");
	$sth->execute($gses[$i]);
	my $names = $sth->{'NAME'};
	my $cols = $sth->{'NUM_OF_FIELDS'};
	#print F "source-id\tlog2Level\tstdDev\tnumberOfMeasurements\tconfidenceScore\tconfidenceType\tsample-id\tfeature-id\n";
	print F "source-id\tsample-id\tmeasurement-description-id\tKB-feature-id\tvalue\tmean\tmedian\tstandard-deviation\tN\tp-value\tZ-score\n";
#	for(my $j = 0; $j < $cols; $j++) {
#		print F $$names[$j];
#		if($j != $cols-1) {
#			print F "\t";
#		} else {
#			print F "\n";
#		}
#	}
	while(my $rowref = $sth->fetchrow_arrayref) {
		#print F "$sourceIdBase".$$rowref[0]."\t".$$rowref[1]."\t.\t.\t.\tnull\t$sourceIdBase".$$rowref[2]."\t".$$rowref[3]."\n";
		print F "$sourceIdBase".$$rowref[0]."\t$sourceIdBase".$$rowref[2]."\tkb|measdesc.6\t".$$rowref[3]."\t".$$rowref[1]."\t.\t.\t.\t1\t.\t.\n";
#		for(my $k = 0; $k < $cols; $k++) {
#			print F $$rowref[$k];
#			if($k != $cols-1) {
#				print F "\t";
#			} else {
#				print F "\n";
#			}
#		}
	}
	close(F);
}
print "\n";
$|--; # enable STDOUT buffering again

#close statement
$sth->finish();
# close database connection
$dbh->disconnect();
