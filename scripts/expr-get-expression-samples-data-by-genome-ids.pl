#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use Carp;
use Config::Simple;
use Bio::KBase::ExpressionServices::ExpressionServicesClient; 

my $DESCRIPTION =
qq^
NAME
    get_expression_samples_data_by_genome_ids

DESCRIPTION
     given a list of Genome IDs, a SampleType ( controlled vocabulary : microarray, RNA-Seq, qPCR, or proteomics) 
     and a int indicating WildTypeOnly (1 = true, 0 = false) , it returns a GenomeExpressionDataSamplesMapping , 
     GenomeId -> StrainId -> ExpressionDataSample. StrainId -> 
        ExpressionSampleDataStructure {genome_id -> {strain_id -> {sample_id -> expressionSampleDataStructure}}}

    Arguments : 
        -genomeID : kbase genome ids.  If have multiple genome ids do the following :  " -genomeID='kb|g.20848'  -genomeID='kb|g.1' "
        -sampleType : the type of sample type to limit results to.  Acceptable values (case ignored): 'microarray', 'RNA-Seq', 'qPCR' or 'proteomics'. 
            Any other passed value will be evaluated to no filter on sample type, thus including all sample types.
        -wildTypeOnly : wildTypeOnly is a flag.  If equal to '1','Y' or 'TRUE' then only strains that are wild type will be included in the results. 

        -h, --help Displays this message and ignores all other arguments   
        -help, --help Displays this message and ignores all other arguments 
        -man, --help Displays this message and ignores all other arguments  
    
    Returns : a genomeExpressionDataSamplesMapping

    genomeExpressionDataSamplesMapping = obj->get_expression_samples_data_by_genome_ids(genomeIDs, sampleType, wildTypeOnly)    

    Details : 
        genomeIDs is a GenomeIDs
        sampleType is a SampleType
        wildTypeOnly is a WildTypeOnly
        genomeExpressionDataSamplesMapping is a GenomeExpressionDataSamplesMapping
        GenomeIDs is a reference to a list where each element is a GenomeID
        GenomeID is a string
        SampleType is a string
        WildTypeOnly is an string ('Y','TRUE','1','N','FALSE','0')      
        GenomeExpressionDataSamplesMapping is a reference to a hash where the key is a GenomeID and the value is a StrainExpressionDataSamplesMapping
        StrainExpressionDataSamplesMapping is a reference to a hash where the key is a StrainID and the value is an ExpressionDataSamplesMap
        StrainID is a string
        ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
        SampleID is a string
        ExpressionDataSample is a reference to a hash where the following keys are defined:
        sampleID has a value which is a SampleID
        sourceID has a value which is a string
        sampleTitle has a value which is a string
        sampleDescription has a value which is a string
        molecule has a value which is a string
        sampleType has a value which is a SampleType
        dataSource has a value which is a string
        externalSourceID has a value which is a string
        externalSourceDate has a value which is a string
        kbaseSubmissionDate has a value which is a string
        custom has a value which is a string 
        originalLog2Median has a value which is a float
        strainID has a value which is a StrainID
        referenceStrain has a value which is a string
        wildtype has a value which is a string
        strainDescription has a value which is a string
        genomeID has a value which is a GenomeID
        genomeScientificName has a value which is a string
        platformID has a value which is a string
        platformTitle has a value which is a string
        platformTechnology has a value which is a string
        experimentalUnitID has a value which is an ExperimentalUnitID
        experimentMetaID has a value which is an ExperimentMetaID
        experimentTitle has a value which is a string
        experimentDescription has a value which is a string
        environmentID has a value which is a string
        environmentDescription has a value which is a string
        protocolID has a value which is a string
        protocolDescription has a value which is a string
        protocolName has a value which is a string
        sampleAnnotations has a value which is a SampleAnnotations
        seriesIDs has a value which is a SeriesIDs
        personIDs has a value which is a PersonIDs
        sampleIDsAveragedFrom has a value which is a SampleIDsAveragedFrom
        dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
        ExperimentalUnitID is a string
        ExperimentMetaID is a string
        SampleAnnotations is a reference to a list where each element is a SampleAnnotation
        SampleAnnotation is a reference to a hash where the following keys are defined:
        sampleAnnotationID has a value which is a SampleAnnotationID
        ontologyID has a value which is an OntologyID
        ontologyName has a value which is an OntologyName
        ontologyDefinition has a value which is an OntologyDefinition
        SampleAnnotationID is a string
        OntologyID is a string
        OntologyName is a string
        OntologyDefinition is a string
        SeriesIDs is a reference to a list where each element is a SeriesID
        SeriesID is a string
        PersonIDs is a reference to a list where each element is a PersonID
        PersonID is a string
        SampleIDsAveragedFrom is a reference to a list where each element is a SampleID
        DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Measurement
        FeatureID is a string
        Measurement is a float

EXAMPLES
    perl expr-get-expression-samples-data-by-genome-ids.pl -genomeID='kb|g.20848' -genomeID='kb|g.0' -sampleType='microarray' -wildTypeOnly='Y'

AUTHORS
    Jason Baumohl (jkbaumohl\@lbl.gov)
^;


my @genomeID;
my $sampleType = '';
my $wildTypeOnly = undef;
my $help = undef;
my $h = undef;
my $man = undef;

# first parse command line options
my $opt = GetOptions (
        "help" => \$help,
        "h" => \$h,
        "man" => \$man,
        "genomeID=s" => \@genomeID,
        "sampleType=s" => \$sampleType,
        "wildTypeOnly=s" => \$wildTypeOnly,
    );
if (defined($h) || defined($help) || defined($man)) {
    print $DESCRIPTION;
    exit 0;
}
if (scalar(@genomeID) < 1 )
{
    print "NOTE This requires genomeIDs to passed in.\n    ".
	  $DESCRIPTION;
    exit 1;
}


our $cfg = {};
if (defined $ENV{KB_DEPLOYMENT_CONFIG} && -e $ENV{KB_DEPLOYMENT_CONFIG}) 
{
    $cfg = new Config::Simple($ENV{KB_DEPLOYMENT_CONFIG}) or
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => Config::Simple->error(),
							       method_name => 'new');
}
else {
    $cfg = new Config::Simple(syntax=>'ini') or
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => Config::Simple->error(),
							       method_name => 'new'); 
    $cfg->param('ExpressionServices.dbName', 'expression');
    $cfg->param('ExpressionServices.dbUser', 'expressionSelect');
    $cfg->param('ExpressionServices.userData', 'expressionSelect/');
    $cfg->param('ExpressionServices.dbhost', 'db1.chicago.kbase.us');
    $cfg->param('ExpressionServices.dbms', 'mysql');
}
my $service_url = "http://localhost:7075";
my $client = Bio::KBase::ExpressionServices::ExpressionServicesClient->new($service_url); 

print Dumper($client->get_expression_samples_data_by_genome_ids(\@genomeID,$sampleType,$wildTypeOnly));

exit 0; 


