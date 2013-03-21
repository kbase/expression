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
#my $client = ExpressionServicesClient->new($url); 
my $client = Bio::KBase::ExpressionServices::ExpressionServicesClient->new($url);
ok(defined($client),"instantiating ExpressionServices client");

my $result;

#Test get_expression_samples_data
#Test 4 - 51
#most heavily tested since all but 1 other ExpressionServices method eventually calls this method
print "\n#get_expression_samples_data portion\n";
eval {
    $result = $client->get_expression_samples_data([]);
};
ok($@ eq '',"get_expression_samples_data call ". $@);
ok($result,"get_expression_samples_data([]) returned");
ok(ref($result) eq 'HASH','get_expression returns a hash');
ok(scalar(keys(%{$result})) == 0, 'get_expression_samples_data([]) appropriately has no entries');
$result = undef;
eval { 
    $result = $client->get_expression_samples_data(['Not A real ID','kb|not Real']);
}; 
ok($@ eq '',"get_expression_samples_data call ". $@);
ok($result,"get_expression_samples_data(['Not A real ID','kb|not Real']) returned"); 
ok(scalar(keys(%{$result})) == 0, "get_expression_samples_data(['Not A real ID','kb|not Real']) appropriately has no entries");
$result = undef;
eval {
    $result = $client->get_expression_samples_data(['kb|sample.2','kb|sample.3']); 
}; 
ok($@ eq '',"get_expression_samples_data call ". $@);
ok($result,"get_expression_samples_data(['kb|sample.2','kb|sample.3']) returned");
ok(scalar(keys(%{$result})) == 2, "get_expression_samples_data('kb|sample.2','kb|sample.3']) appropriately has 2 entries");
my @expected_keys = ('environmentDescription','kbaseSubmissionDate','genomeID','sampleTitle','experimentDescription',
		     'originalLog2Median','experimentMetaID','dataExpressionLevelsForSample','protocolId','wildtype',
		     'platformTitle','platformId','referenceStrain','personIds','experimentTitle','externalSourceDate',
		     'molecule','protocolName','platformTechnology','protocolDescription','environmentId','dataSource',
		     'custom','experimentalUnitID','strainID','sourceId','strainDescription','seriesIds',
		     'sampleAnnotationIDs','genomeScientificName','sampleId','externalSourceId','sampleType');
#check that each Key exists  33 checks 11-43
#print Dumper($result);
foreach my $exp_key (@expected_keys)
{
    ok(exists($result->{'kb|sample.2'}->{$exp_key}), 'get_expression_samples_data() sample has the key : '.$exp_key);
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

#Test get_expression_samples_data_by_series_ids
#Test 52 - 61
print "\n#get_expression_samples_data_by_series_ids portion\n";
$result = undef;
eval { 
    $result = $client->get_expression_samples_data_by_series_ids([]); 
}; 
ok($@ eq '',"get_expression_samples_data_by_series_id call ". $@);
ok($result,"get_expression_samples_data_by_series_ids([]) returned"); 
ok(ref($result) eq 'HASH','get_expression_samples_data_by_series_ids returns a hash'); 
ok(scalar(keys(%{$result})) == 0, 'get_expression_samples_data_by_series_ids([]) appropriately has no entries'); 
$result = undef;
eval { 
    $result = $client->get_expression_samples_data_by_series_ids(['Not A real ID','kb|not Real']); 
}; 
ok($@ eq '',"get_expression_samples_data_by_series_id call ". $@);
ok($result,"get_expression_samples_data_by_series_ids(['Not A real ID','kb|not Real']) returned"); 
ok(scalar(keys(%{$result})) == 0, "get_expression_samples_data_by_series_ids(['Not A real ID','kb|not Real']) appropriately has no entries"); 
$result = undef;
eval { 
    $result = $client->get_expression_samples_data_by_series_ids(['kb|series.0','kb|series.3']); 
}; 
ok($@ eq '',"get_expression_samples_data_by_series_id call ". $@);
ok($result,"get_expression_samples_data_by_series_ids(['kb|series.0','kb|series.1']) returned"); 
ok(scalar(keys(%{$result})) == 2, "get_expression_samples_data_by_series_ids('kb|series.0','kb|series.1']) appropriately has 2 entries"); 
#print Dumper($result);

#Test get_expression_samples_data_by_experimental_unit_ids 
#Test 62 - 71             
print "\n#get_expression_samples_data_by_experimental_unit_ids portion\n";
$result = undef;
eval { 
    $result = $client->get_expression_samples_data_by_experimental_unit_ids([]); 
};
ok($@ eq '',"get_expression_samples_data_by_experimental_unit_ids call ". $@);
ok($result,"get_expression_samples_data_by_experimental_unit_ids([]) returned"); 
ok(ref($result) eq 'HASH','get_expression_samples_data_by_experimental_unit_ids returns a hash'); 
ok(scalar(keys(%{$result})) == 0, 'get_expression_samples_data_by_experimental_unit_ids([]) appropriately has no entries'); 
$result = undef;
eval { 
    $result = $client->get_expression_samples_data_by_experimental_unit_ids(['Not A real ID','kb|not Real']); 
}; 
ok($@ eq '',"get_expression_samples_data_by_experimental_unit_ids call ". $@);
ok($result,"get_expression_samples_data_by_experimental_unit_ids(['Not A real ID','kb|not Real']) returned"); 
ok(scalar(keys(%{$result})) == 0, "get_expression_samples_data_by_experimental_unit_ids(['Not A real ID','kb|not Real']) appropriately has no entries"); 
$result = undef;
eval { 
    $result = $client->get_expression_samples_data_by_experimental_unit_ids(['kb|expu.3167770','kb|expu.3167762']); 
}; 
ok($@ eq '',"get_expression_samples_data_by_experimental_unit_ids call ". $@);
ok($result,"get_expression_samples_data_by_experimental_unit_ids(['kb|expu.3167770','kb|expu.3167762']) returned");
ok(scalar(keys(%{$result})) == 2, "get_expression_samples_data_by_experimental_unit_ids(['kb|expu.3167770','kb|expu.3167762']) appropriately has 2 entries");
#print Dumper($result);

#Test get_expression_experimental_unit_samples_data_by_experiment_meta_ids 
#Test 72 - 81      
print "\n#get_expression_experimental_unit_samples_data_by_experiment_meta_ids portion\n";
$result = undef;
eval { 
    $result = $client->get_expression_experimental_unit_samples_data_by_experiment_meta_ids([]); 
}; 
ok($@ eq '',"get_expression_experimental_unit_samples_data_by_experiment_meta_ids call ". $@);
ok($@ eq '',"get_expression_experimental_unit_samples_data_by_experiment_meta_ids([]) ". $@);
ok($result,"get_expression_experimental_unit_samples_data_by_experiment_meta_ids([]) returned"); 
ok(ref($result) eq 'HASH','get_expression_experimental_unit_samples_data_by_experiment_meta_ids returns a hash'); 
ok(scalar(keys(%{$result})) == 0, 'get_expression_experimental_unit_samples_data_by_experiment_meta_ids([]) appropriately has no entries'); 
$result = undef;
eval { 
    $result = $client->get_expression_experimental_unit_samples_data_by_experiment_meta_ids(['Not A real ID','kb|not Real']); 
}; 
ok($@ eq '',"get_expression_experimental_unit_samples_data_by_experiment_meta_ids call ". $@);
ok($result,"get_expression_experimental_unit_samples_data_by_experiment_meta_ids(['Not A real ID','kb|not Real']) returned"); 
ok(scalar(keys(%{$result})) == 0, "get_expression_experimental_unit_samples_data_by_experiment_meta_ids(['Not A real ID','kb|not Real']) appropriately has no entries"); 
$result = undef;
eval { 
    $result = $client->get_expression_experimental_unit_samples_data_by_experiment_meta_ids(['kb|expm.16','kb|expm.15']); 
}; 
ok($@ eq '',"get_expression_experimental_unit_samples_data_by_experiment_meta_ids call ". $@);
ok($result,"get_expression_experimental_unit_samples_data_by_experiment_meta_ids(['kb|expm.16','kb|expm.15']) returned"); 
ok(scalar(keys(%{$result})) == 2, "get_expression_experimental_unit_samples_data_by_experiment_meta_ids(['kb|expm.16','kb|expm.15']) appropriately has 2 entries"); 
#print Dumper($result);

#Test get_expression_samples_data_by_strain_ids            
#Test 82 - 91 
print "\n#get_expression_samples_data_by_strain_ids portion\n";
$result = undef;
eval { 
    $result = $client->get_expression_samples_data_by_strain_ids([],'microarray'); 
}; 
ok($@ eq '',"get_expression_samples_data_by_strain_ids call ". $@);
ok($result,"get_expression_samples_data_by_strain_ids([]) returned");
ok(ref($result) eq 'HASH','get_expression_samples_data_by_strain_ids returns a hash');
ok(scalar(keys(%{$result})) == 0, 'get_expression_samples_data_by_strain_ids([]) appropriately has no entries');
#print Dumper($result);
$result = undef;
eval { 
    $result = $client->get_expression_samples_data_by_strain_ids(['Not A real ID','kb|not Real'],'microarray');
}; 
ok($@ eq '',"get_expression_samples_data_by_strain_ids call ". $@);
ok($result,"get_expression_samples_data_by_strain_ids(['Not A real ID','kb|not Real']) returned");
ok(scalar(keys(%{$result})) == 0, "get_expression_samples_data_by_strain_ids(['Not A real ID','kb|not Real']) appropriately has no entries");
#print Dumper($result);
$result = undef;
eval { 
    $result = $client->get_expression_samples_data_by_strain_ids(['kb|str.7634'],'microarray');
}; 
ok($@ eq '',"get_expression_samples_data_by_strain_ids call ". $@);
ok($result,"get_expression_samples_data_by_strain_ids(['kb|str.7634']) returned"); 
ok(scalar(keys(%{$result})) == 1, "get_expression_samples_data_by_strain_ids(['kb|str.7634']) appropriately has 1 entry");
#print Dumper($result);
 
#Test get_expression_samples_data_by_genome_ids 
#Test 92 - 101     
print "\n#get_expression_samples_data_by_genome_ids portion\n";
$result = undef;
eval { 
    $result = $client->get_expression_samples_data_by_genome_ids([],'microarray','N'); 
}; 
ok($@ eq '',"get_expression_samples_data_by_genome_ids call ". $@);
ok($result,"get_expression_samples_data_by_genome_ids([]) returned");
ok(ref($result) eq 'HASH','get_expression_samples_data_by_genome_ids returns a hash');
ok(scalar(keys(%{$result})) == 0, 'get_expression_samples_data_by_genome_ids([]) appropriately has no entries');
#print Dumper($result);
$result = undef;
eval { 
    $result = $client->get_expression_samples_data_by_genome_ids(['Not A real ID','kb|not Real'],'microarray','N');
}; 
ok($@ eq '',"get_expression_samples_data_by_genome_ids call ". $@);
ok($result,"get_expression_samples_data_by_genome_ids(['Not A real ID','kb|not Real']) returned");
ok(scalar(keys(%{$result})) == 0, "get_expression_samples_data_by_genome_ids(['Not A real ID','kb|not Real']) appropriately has no entries");
#print Dumper($result);
$result = undef;
eval { 
    $result = $client->get_expression_samples_data_by_genome_ids(['kb|g.20848'],'microarray','N');
}; 
ok($@ eq '',"get_expression_samples_data_by_genome_ids call ". $@);
ok($result,"get_expression_samples_data_by_genome_ids(['kb|g.20848']) returned"); 
ok(scalar(keys(%{$result})) == 1, "get_expression_samples_data_by_genome_ids(['kb|g.20848']) appropriately has 1 entry");
#print Dumper($result);



Server::stop($pid);

done_testing($n_tests);
