use warnings;
use DateTime;
use Data::Dumper;
use Bio::KBase::ExpressionServices::ExpressionServicesClient;

#restore hash from the input file
#my $infile = $ARGV[0];
#open FILE, $infile;
#undef $/;
#my $href = eval <FILE>;
#close FILE;

my $client = Bio::KBase::ExpressionServices::ExpressionServicesClient->new("http://localhost:7075");
my $href = $client->get_GEO_GSE('GSE22671',1);

# open .tab files for writing
open(SER, ">series.tab");
open(SAM, ">sample.tab");
open(PER, ">person.tab");
open(PRO, ">protocol.tab");
open(PLA, ">platform.tab");

# write header line for each .tab file
print SER "source-id\texternalSourceId\tkbaseSubmissionDate\texternalSourceDate\tpublicationIds\tsamples\ttitle\tsummary\tdesign\n";
print SAM "source-id\tmolecule\ttype\texternalSourceId\tdataSource\tkbaseSubmissionDate\texternalSourceDate\toriginalLog2Median\tpersons\tstrain-id\tplatform-id\tprotocol-id\texperimentalUnit-id\tdefaultControlSample-id\taveragedFromSamples\ttitle\tdescription\n";
print PER "source-id\tContact-Email\tFirst-Name\tLast-Name\tInstitution\n";
print PRO "source-id\tPublication\tName\tDescription\n";
print PLA "source-id\tstrain-id\ttype\ttechnology\texternalSourceId\ttitle\n";

# Common Data Fields: source-id base string and today's date
my $providerId = "kumari\@cshl.edu";
my $loadId = "PlantExpr";
my $ver = 1;
my $sourceIdBase = "$providerId:$loadId.$ver|";
my $dt = DateTime->now;   # Store current date and time as datetime object
my $d  = $dt->ymd;        # Retrieve date as in 'yyyy-mm-dd' format

my %persons = ();
my %platforms = ();
my %samples = (); # holds GSM to sample source-id mapping

# write data to series.tab
my $gseId = $href->{'gseID'};
my $gseSubmissionDate =  $href->{'gseSubmissionDate'};
my $gsePubMedID = $href->{'gsePubMedID'};
my $gsmref = $href->{'gseSamples'};
my $gsm = "";
foreach my $k (keys(%{$gsmref})) {
	$gsm .= "$sourceIdBase$k,";
}
$gsm =~ s/,$//;
my $title = $href->{'gseTitle'};
$title = substr($title,0,500);
my $summary = $href->{'gseSummary'};
$summary = substr($summary,0,500);
my $design = $href->{'gseDesign'};
$design = substr($design,0,500);
my $seriesSrcId = "$sourceIdBase$gseId";
print SER "$seriesSrcId\t$gseId\t$d\t$gseSubmissionDate\t$gsePubMedID\t$gsm\t$title\t$summary\t$design\n";

# write data to sample.tab
# NOTE: gsmPlatform{'gplID' => 'GPL198'}
foreach my $g (keys(%{$href->{'gseSamples'}})) {
	my $gsmOrganism = $gsmref->{$g}->{'gsmSampleOrganism'};
	$gsmOrganism =~ s/\s+/_/;
	my $sampleSrcId = "$sourceIdBase$g";
	$samples{$g} = $sampleSrcId; # store GSM source-id
	my $molecule = $gsmref->{$g}->{'gsmMolecule'};
	my $type = "microarray";                                       #$gsmref->{$g}->{''};
	my $dataSource = "GEO";                                        #$gsmref->{$g}->{''};
	my $externalSourceDate = $gsmref->{$g}->{'gsmSubmissionDate'};
	my $originalLog2Median = ".";                                  #$gsmref->{$g}->{''};
	my $person = "";
	my $pref = $gsmref->{$g}->{'contactPeople'};
	foreach my $email (keys(%{$pref})) {
		my $fn = $pref->{$email}->{'contactFirstName'};
		my $ln = $pref->{$email}->{'contactLastName'};
		my $inst = $pref->{$email}->{'contactInstitution'};
		my $personSrcId = "$email:$loadId.$ver|$fn$ln";
		$person = $person.$personSrcId.",";
		$persons{"$personSrcId\t$email\t$fn\t$ln\t$inst"} = 1;
	}
	$person =~ s/,$//;
	my $strainId = $gsmref->{$g}->{'gsmTaxID'};
	my $platformRef = $gsmref->{$g}->{'gsmPlatform'};
	my $gpl = $platformRef->{'gplID'};
	my $platformSrcId = "$providerId:$strainId.$ver|$gpl";
	my $strainSrcId = "$providerId:$strainId.$ver|$gsmOrganism";
	if(!defined($platforms{$platformSrcId})) {
		#my $gplTaxId = $platformRef->{'gplTaxID'};
		my $gplTechnology = $platformRef->{'gplTechnology'};
		my $gplTitle = $platformRef->{'gplTitle'};
		$platforms{$platformSrcId} = "$strainSrcId\t$type\t$gplTechnology\t$gpl\t$gplTitle";
	}
	my $gsmProtocolDesc = $gsmref->{$g}->{'gsmProtocol'};
	my $protocolSrcId = "$providerId:$g.$ver|$gpl";
	print PRO "$protocolSrcId\t.\tno-name\t$gsmProtocolDesc\n";
	my $experimentalUnitId = ".";                                  #$gsmref->{$g}->{''};
	my $defaultControlSampleId = ".";                              #$gsmref->{$g}->{''};
	my $averagedFromSamples = ".";                                 #$gsmref->{$g}->{''};
	my $title = $gsmref->{$g}->{'gsmTitle'};
	my $description = $gsmref->{$g}->{'gsmDescription'};
	print SAM "$sampleSrcId\t$molecule\t$type\t$g\t$dataSource\t$d\t$externalSourceDate\t$originalLog2Median\t$person\t$strainSrcId\t$platformSrcId\t$protocolSrcId\t$experimentalUnitId\t$defaultControlSampleId\t$averagedFromSamples\t$title\t$description\n";
}

# write data to person.tab
foreach my $k (keys(%persons)) {
	print PER "$k\n";
}

# write data to platform.tab
foreach my $k (keys(%platforms)) {
	print PLA "$k\t".$platforms{$k}."\n";
}

# close all open files
close SER;
close SAM;
close PER;
close PRO;
close PLA;
