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
    get_expression_data_by_feature_ids.pl

DESCRIPTION
    given a list of feature ids it returns a featureSampleMeasurementMapping {featureID}->{sampleID => value}}. 

    Arguments : 
        -featureID : kbase feature ids.  If have multiple feature ids do the following : " -featureID='kb|g.20848.CDS.1800' -featureID='kb|g.20848.CDS.1687'  "
           (If no featureIDs entered, then all features with measurment values will be returned.)
        -sampleType : the type of sample type to limit results to.  Acceptable values (case ignored): 'microarray', 'RNA-Seq', 'qPCR' or 'proteomics'.
            Any other passed value will be evaluated to no filter on sample type, thus including all sample types.    
        -wildTypeOnly : wildTypeOnly is a flag.  If equal to '1','Y' or 'TRUE' then only strains that are wild type will be included in the results. 

        -h, --help Displays this message and ignores all other arguments   
        -help, --help Displays this message and ignores all other arguments 
        -man, --help Displays this message and ignores all other arguments  
    
    Returns : a featureSampleMeasurementMapping

    featureSampleMeasurementMapping = obj->get_expression_data_by_feature_ids(featureIDs, sampleType, wildTypeOnly)

    Details : 
        featureIDs is a FeatureIDs
        sampleType is a SampleType
        wildTypeOnly is a WildTypeOnly
        featureSampleMeasurementMapping is a FeatureSampleMeasurementMapping
        FeatureIDs is a reference to a list where each element is a FeatureID
        FeatureID is a string
        SampleType is a string
        WildTypeOnly is an string ('Y','TRUE','1','N','FALSE','0')
        FeatureSampleMeasurementMapping is a reference to a hash where the key is a FeatureID and the value is a SampleMeasurementMapping
        SampleMeasurementMapping is a reference to a hash where the key is a SampleID and the value is a Measurement
        SampleID is a string
        Measurement is a float

EXAMPLES
    perl expr-get-expression-data-by-feature-ids.pl -featureID='kb|g.20848.CDS.1800' -featureID='kb|g.20848.CDS.1687' -sampleType='microarray' -wildTypeOnly='Y'

AUTHORS
    Jason Baumohl (jkbaumohl\@lbl.gov)
^;


my @featureID;
my $sampleType = undef;
my $wildTypeOnly = undef;
my $help = undef;
my $h = undef;
my $man = undef;

# first parse command line options
my $opt = GetOptions (
    "help" => \$help,
    "h" => \$h,
    "man" => \$man,
    "featureID=s" => \@featureID,
    "sampleType=s" =>\$sampleType,
    "wildTypeOnly=s" => \$wildTypeOnly
    );
if (defined($h) || defined($help) || defined($man)) {
    print $DESCRIPTION;
    exit 0;
}
if (scalar(@featureID) < 1 )
{
    print "NOTE This requires FeatureIDs to passed in.\n    ".
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

print Dumper($client->get_expression_data_by_feature_ids(\@featureID,$sampleType,$wildTypeOnly));

exit 0; 


