#!/usr/bin/perl
#  
#  The purpose of this test is to make sure we recieve some response from the server for the list of functions
#  given.  Each of these functions listed should return some value, but the actual value is not checked here.
#  Thus, this test is ideal for making sure you are actually recieving something from a service call even if
#  that service is not yet implemented yet.
#
#  If you add functionality to the expression services, you should add an appropriate test here.
#
#  author:  jkbaumohl
#  created: 3/19/2013

use strict; 
use warnings;
use Data::Dumper; 
use Test::More;
use lib "../lib/Bio/KBase/ExpressionServices"; 
use lib "lib"; 
use lib "../lib"; 
use ExpressionServicesClient;

#############################################################################
# HERE IS A LIST OF METHODS AND PARAMETERS THAT WE WANT TO TEST
# NOTE THAT THE PARAMETERS ASSUME the initial load of Adam D's data is loaded.
# Currently this is using the CS_expression schema as the tables are not in the CDS yet.
my $func_calls = {
		get_expression_samples_data=>[['kb|sample.2','kb|sample.3']],
		get_expression_samples_data_by_series_ids=>[['kb|series.1','kb|series.0']],
		get_expression_samples_data_by_experimental_unit_ids=>[['kb|expu.3167770','kb|expu.3167762']],
		get_expression_experimental_unit_samples_data_by_experiment_meta_ids=>[['kb|expm.16','kb|expm.15']],
		get_expression_samples_data_by_strain_ids=>[['kb|str.7634','kb|str.999'],'microarray'],
		get_expression_samples_data_by_genome_ids=>[['kb|g.20848','kb|g.0'],'microarray','Y'],
		get_expression_data_by_feature_ids=>[['kb|g.20848.CDS.1800','kb|g.20848.CDS.1687'],'microarray','Y'],
		};

###########################################################################
my $n_tests = 100; 

# MAKE SURE WE LOCALLY HAVE JSON RPC LIBS
#--
use_ok("JSON::RPC::Client");
use_ok("Bio::KBase::ExpressionServices::ExpressionServicesClient");
 
#NEW VERSION WITH AUTO START / STOP SERVICE
#--
use Server;
my ($pid, $url) = Server::start('ExpressionServices');
print "-> attempting to connect to:'".$url."' with PID=$pid\n";
my $client = ExpressionServicesClient->new($url); 
#my $client = Bio::KBase::ExpressionServices::ExpressionServicesClient->new($url);
ok(defined($client),"instantiating ExpressionServices client");

my $result;

#Test get_expression_samples_data
#Test 4 - 49
eval {
    $result = $client->get_expression_samples_data([]);
};
ok($result,"get_expression_samples_data([]) returned");
ok(ref($result) eq 'HASH','get_expression returns a hash');
ok(scalar(keys(%{$result})) == 0, 'get_expression_samples_data([]) appropriately has no entries');
eval { 
    $result = $client->get_expression_samples_data(['Not A real ID','kb|not Real']);
}; 
ok($result,"get_expression_samples_data(['Not A real ID','kb|not Real']) returned"); 
ok(scalar(keys(%{$result})) = 0, "get_expression_samples_data(['Not A real ID','kb|not Real']) appropriately has no entrie=s");
eval {
    $result = $client->get_expression_samples_data(['kb|sample.2','kb|sample.3']); 
}; 
ok($result,"get_expression_samples_data(['kb|sample.2','kb|sample.3']) returned");
ok(scalar(keys(%{$result})) == 2, "get_expression_samples_data('kb|sample.2','kb|sample.3']) appropriately has 2 entries");
my %sample_record_hash = $result->{'kb|sample_2'};
my @expected_keys = ('environmentDescription','kbaseSubmissionDate','genomeID','sampleTitle','experimentDesciption',
		     'originalLog2Median','experimentMetaID','dataExpressionLevelsForSample','protocolId','wildtype',
		     'platformTitle','platformId','referenceStrain','personIds','experimentTitle','externalSourceDate',
		     'molecule','protocolName','platformTechnology','protocolDescription','environmentId','dataSource',
		     'custom','experimentalUnitID','strainID','sourceId','strainDescription','seriesIds',
		     'sampleAnnotationIDs','genomeScientificName','sampleId','externalSourceId','sampleType');
#check that each Key exists  33 checks 12-44
#print Dumper($result);
foreach my $exp_key (@expected_keys)
{
    ok(exists($sample_record_hash{$exp_key}), 'get_expression_samples_data() sample has the key : $exp_key');
}
#check that keys that point to a data structure are that data structure.
ok(ref($result->{'kb|sample.2'}->{'dataExpressionLevelsForSample'}) eq 'HASH',
   'get_expression_samples_data does contain a hash of log levels');
ok(scalar(keys(%{$result->{'kb|sample.2'}->{'dataExpressionLevelsForSample'}})) > 1000,
   'get_expression_samples_data does contains many log levels');
ok(ref($result->{'kb|sample.2'}->{'personIds'}) eq 'ARRAY', 
   'get_expression_samples_data has an array for PersonIds');
ok(ref($result->{'kb|sample.2'}->{'seriesIds'}) eq 'ARRAY',
   'get_expression_samples_data has an array for SeriesIds');
ok(ref($result->{'kb|sample.2'}->{'sampleAnnotationIDs'}) eq 'ARRAY',
   'get_expression_samples_data has an array for sampleAnnotationIDs');




# LOOP THROUGH ALL THE REMOTE CALLS AND MAKE SURE WE GOT SOMETHING
#my $method_name;
#for $method_name (keys %$func_calls) {
#    #print "==========\n$method_name => @{ $func_calls->{$method_name}}\n";
#    #my $n_args = scalar @{ $func_calls->{$method_name}};
#    my $result;
#    print "calling function: \"$method_name\"\n";
#    {
#	no strict "refs";
#	eval {
#	     $result = $client->$method_name(@{ $func_calls->{$method_name}});
#	};
#	my $client_error = $@;
#	if ($client_error) {
#	   print $client_error->message."\n";
#	}
#   }
#    ok($result,"looking for a response from \"$method_name\"");
#}

Server::stop($pid);

done_testing($n_tests);
