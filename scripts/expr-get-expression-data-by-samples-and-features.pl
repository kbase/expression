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
    get_expression_data_by_samples_and_features.pl

DESCRIPTION
    given a list of sample ids and feature ids it returns a LabelDataMapping {sampleID}->{featureId => value}}. 

    Arguments : 
        -sampleID kbase sample ids.  If have multiple sample ids do the following : " -sampleID='kb|sample.2' -sampleID='kb|sample.3' "
        -featureID kbase sample ids.  If have multiple feature ids do the following : "  -featureID='kb|g.20848.CDS.1800' -featureID='kb|g.20848.CDS.1687' "
           (If no featureIDs entered, then all features with measurment values will be returned.)

        -h, --help Displays this message and ignores all other arguments   
        -help, --help Displays this message and ignores all other arguments 
        -man, --help Displays this message and ignores all other arguments  
    
    Returns : an ExpressionDataSamplesMap 

    labelDataMapping = obj->get_expression_data_by_samples_and_features(sampleIDs, featureIDs)

    Details : 
        sampleIDs is a SampleIDs
        featureIDs is a FeatureIDs
        labelDataMapping is a LabelDataMapping
        SampleIDs is a reference to a list where each element is a SampleID
        SampleID is a string
        FeatureIDs is a reference to a list where each element is a FeatureID
        FeatureID is a string
        LabelDataMapping is a reference to a hash where the key is a SampleID and the value is a DataExpressionLevelsForSample
        DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Measurement
        Measurement is a float

EXAMPLES
    perl get_expression_data_by_samples_and_features.pl -sampleID='kb|sample.2' -sampleID='kb|sample.3' -featureID='kb|g.20848.CDS.1800' -featureID='kb|g.20848.CDS.1687'
	   OR perl get_expression_data_by_samples_and_features.pl -sampleID='kb|sample.2' -sampleID='kb|sample.3'  (if you want all features with measurments) 

AUTHORS
    Jason Baumohl (jkbaumohl\@lbl.gov)
^;


my @sampleID;
my @featureID;
my $help = undef;
my $h = undef;
my $man = undef;

# first parse command line options
my $opt = GetOptions (
        "help" => \$help,
        "h" => \$h,
        "man" => \$man,
        "sampleID=s" => \@sampleID,
        "featureID=s" => \@featureID,
    );
if (defined($h) || defined($help) || defined($man)) {
    print $DESCRIPTION;
    exit 0;
}
if (scalar(@sampleID) < 1 )
{
    print "NOTE This requires SampleIDs to passed in.\n    
           Ex: perl get_expression_data_by_samples_and_features.pl -sampleID='kb|sample.2' -sampleID='kb|sample.3'  
           -featureID='kb|g.20848.CDS.1800' -featureID='kb|g.20848.CDS.1687' \n".
	  "OR perl get_expression_data_by_samples_and_features.pl -sampleID='kb|sample.2' -sampleID='kb|sample.3'  (if you want all features with measurments). \n".
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

print Dumper($client->get_expression_data_by_samples_and_features(\@sampleID,\@featureID));

exit 0; 


