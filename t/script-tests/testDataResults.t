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
use lib "lib"; 
use lib "t"; 
use Bio::KBase::ExpressionServices::ExpressionServicesClient; 
use Server; 


my %print_hash;
if (scalar(@ARGV)>0)
{
    foreach my $arg (@ARGV)
    {
	$print_hash{$arg} = 1;
    }
}

print "NOTE THIS TEST SCRIPT HAS AN OPTION TO PASS ADDITIONAL INTEGER ARGUMENTS TO IT\n".
"The following integers being present will result in the Data Dumper of the returned results to be printed for the following calls:\n".
"**********************************************************************************************************************************\n".
"1 - client->get_expression_samples_data(['kb|sample.2','kb|sample.3']); \n".
"2 - client->get_expression_samples_data_by_series_ids(['kb|series.0','kb|series.3']); \n".
"3 - client->get_expression_samples_data_by_experimental_unit_ids(['kb|expu.3167770','kb|expu.3167762']); \n".
"4 - client->get_expression_samples_data_by_experiment_meta_ids(['kb|expm.16','kb|expm.15']); \n".
"5 - client->get_expression_samples_data_by_strain_ids(['kb|str.7634'],'microarray'); \n".
"6 - client->get_expression_samples_data_by_genome_ids(['kb|g.20848'],'microarray','N'); \n".
#"7 - client->get_expression_samples_data_by_ontology_ids(['ENVO:02000086','PO:0030086','PO:0030085'],'or','kb|g.20848','microarray','Y');\n". 
"8 - client->get_expression_data_by_feature_ids(['kb|g.20848.CDS.1800','kb|g.20848.CDS.1687'],'microarray','Y'); \n". 
"9 - client->compare_samples({   'numerator1'=>{'feature1'=>1,'feature2'=>2,'feature3'=>3}, 
                                 'numerator2'=>{'feature1'=>-1,'feature2'=>0,'feature3'=>0.5}}, 
                             {    'denominator1'=>{'feature1'=>1.5,'feature2'=>2,'feature3'=>-1}, 
                                  'denominator2'=>{'feature1'=>-.5,'feature2'=>0}}); \n". 
"10- client->compare_samples_vs_default_controls(['kb|sample.3','kb|sample.8','kb|sample.1']); \n". 
"11- client->compare_samples_vs_the_average(['kb|sample.3','kb|sample.8','kb|sample.1'], ['kb|sample.3','kb|sample.8','kb|sample.1']); \n". 
"12- client->get_on_off_calls(client->compare_samples({   'numerator1'=>{'feature1'=>1,'feature2'=>2,'feature3'=>3}, 
                                                           'numerator2'=>{'feature1'=>-1,'feature2'=>0,'feature3'=>0.5}}, 
                                                {    'denominator1'=>{'feature1'=>1.5,'feature2'=>2,'feature3'=>-1}, 
                                                     'denominator2'=>{'feature1'=>-.5,'feature2'=>0}}),-1,1); \n". 
"13- client->get_top_changers(client->compare_samples_vs_default_controls(['kb|sample.3','kb|sample.8','kb|sample.1']),'BOTH',10); \n".
"14- client->get_expression_sample_ids_by_series_ids(['kb|series.0','kb|series.3']);\n".
"15- client->get_expression_sample_ids_by_series_ids('kb|expu.3167770','kb|expu.3167762']);\n".
"16- client->get_expression_sample_ids_by_experiment_meta_ids(['kb|expm.16','kb|expm.15']); \n".
"17- client->get_expression_sample_ids_by_strain_ids(['kb|str.7634'],'microarray'); \n".
"18- client->get_expression_sample_ids_by_genome_ids(['kb|g.20848'],'microarray','N'); \n".
"19- client->get_expression_samples_titles(['kb|sample.2','kb|sample.3']); \n".
"20- client->get_expression_samples_descriptions(['kb|sample.2','kb|sample.3']); \n".
"21- client->get_expression_samples_molecules(['kb|sample.2','kb|sample.3']); \n".
"22- client->get_expression_samples_types(['kb|sample.2','kb|sample.3']); \n".
"23- client->get_expression_samples_external_source_ids(['kb|sample.2','kb|sample.3']); \n".
"24- client->get_expression_sample_original_log2_medians(['kb|sample.2','kb|sample.3']); \n". 
"25- client->client->get_expression_series_titles(['kb|series.1','kb|series.0']); \n".
"26- client->client->get_expression_series_summaries(['kb|series.1','kb|series.0']); \n".
"27- client->client->get_expression_series_designs(['kb|series.1','kb|series.0']); \n".
"28- client->client->get_expression_series_external_source_ids(['kb|series.1','kb|series.0']); \n".

"**********************************************************************************************************************************\n";

my $n_tests = 188; 

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
#Test 4 - 49
#most heavily tested since all but 1 other ExpressionServices method eventually calls this method
print "\n#get_expression_samples_data portion\n";
eval {
    $result = $client->get_expression_samples_data([]);
};
ok($@ =~ /requires a list of valid/,"get_expression_samples_data([]) without samples throws exception properly");
$result = undef;
eval { 
    $result = $client->get_expression_samples_data(['Not A real ID','kb|not Real']);
}; 
ok($@ eq '',"get_expression_samples_data call ". $@);
ok($result,"get_expression_samples_data(['Not A real ID','kb|not Real']) returned"); 
ok(ref($result) eq 'HASH','get_expression returns a hash');
ok(scalar(keys(%{$result})) == 0, "get_expression_samples_data(['Not A real ID','kb|not Real']) appropriately has no entries");
$result = undef;
eval {
    $result = $client->get_expression_samples_data(['kb|sample.2','kb|sample.3']); 
}; 
ok($@ eq '',"get_expression_samples_data call ". $@);
ok($result,"get_expression_samples_data(['kb|sample.2','kb|sample.3']) returned");
ok(scalar(keys(%{$result})) == 2, "get_expression_samples_data('kb|sample.2','kb|sample.3']) appropriately has 2 entries");
my @expected_keys = ('environmentDescription','kbaseSubmissionDate','genomeID','sampleTitle','experimentDescription',
		     'originalLog2Median','experimentMetaID','dataExpressionLevelsForSample','protocolID','wildtype',
		     'platformTitle','platformID','referenceStrain','personIDs','experimentTitle','externalSourceDate',
		     'molecule','protocolName','platformTechnology','protocolDescription','environmentID','dataSource',
		     'custom','experimentalUnitID','strainID','sourceID','strainDescription','seriesIDs',
		     'sampleAnnotationIDs','genomeScientificName','sampleID','externalSourceID','sampleType');
#check that each Key exists  33 checks 11-43
if (exists($print_hash{1})) 
{ 
    print Dumper($result); 
} 
foreach my $exp_key (@expected_keys)
{
    ok(exists($result->{'kb|sample.2'}->{$exp_key}), 'get_expression_samples_data() sample has the key : '.$exp_key);
}
#check that keys that point to a data structure are that data structure.
ok(ref($result->{'kb|sample.2'}->{'dataExpressionLevelsForSample'}) eq 'HASH',
   'get_expression_samples_data does contain a hash of log levels');
ok(scalar(keys(%{$result->{'kb|sample.2'}->{'dataExpressionLevelsForSample'}})) > 1000,
   'get_expression_samples_data does contains many log levels');
ok(ref($result->{'kb|sample.2'}->{'personIDs'}) eq 'ARRAY', 
   'get_expression_samples_data has an array for PersonIds');
ok(ref($result->{'kb|sample.2'}->{'seriesIDs'}) eq 'ARRAY',
   'get_expression_samples_data has an array for SeriesIds');
ok(ref($result->{'kb|sample.2'}->{'sampleAnnotationIDs'}) eq 'ARRAY',
   'get_expression_samples_data has an array for sampleAnnotationIDs');

#Test get_expression_samples_data_by_series_ids
#Test 50 - 54
print "\n#get_expression_samples_data_by_series_ids portion\n";
$result = undef;
eval { 
    $result = $client->get_expression_samples_data_by_series_ids([]); 
}; 
ok($@ =~ /requires a list of valid/,"get_expression_samples_data_by_series([]) without series_ids throws exception properly");
$result = undef;
eval { 
    $result = $client->get_expression_samples_data_by_series_ids(['Not A real ID','kb|not Real']); 
}; 
ok($@ =~ /requires a list of valid/,"get_expression_samples_data_by_series(['Not A real ID','kb|not Real']) throws exception properly because fake series IDS will not have real sample ids associated with them.");
$result = undef;
eval { 
    $result = $client->get_expression_samples_data_by_series_ids(['kb|series.0','kb|series.3']); 
}; 
ok($@ eq '',"get_expression_samples_data_by_series_id call ". $@);
ok($result,"get_expression_samples_data_by_series_ids(['kb|series.0','kb|series.1']) returned"); 
ok(scalar(keys(%{$result})) == 2, "get_expression_samples_data_by_series_ids('kb|series.0','kb|series.1']) appropriately has 2 entries"); 
if (exists($print_hash{2})) 
{ 
    print Dumper($result);
} 


#Test get_expression_samples_data_by_experimental_unit_ids 
#Test 55 - 59             
print "\n#get_expression_samples_data_by_experimental_unit_ids portion\n";
$result = undef;
eval { 
    $result = $client->get_expression_samples_data_by_experimental_unit_ids([]); 
};
ok($@ =~ /requires a list of valid/,"get_expression_samples_data_by_experimental_unit_ids([]) without experimental_unit_ids throws exception properly");
$result = undef;
eval { 
    $result = $client->get_expression_samples_data_by_experimental_unit_ids(['Not A real ID','kb|not Real']); 
}; 
ok($@ =~ /requires a list of valid/,"get_expression_samples_data_by_experimental_unit_ids(['Not A real ID','kb|not Real']) throws exception properly because fake experimental_unit_ids will not have real sample ids associated with them.");
$result = undef;
eval { 
    $result = $client->get_expression_samples_data_by_experimental_unit_ids(['kb|expu.3167770','kb|expu.3167762']); 
}; 
ok($@ eq '',"get_expression_samples_data_by_experimental_unit_ids call ". $@);
ok($result,"get_expression_samples_data_by_experimental_unit_ids(['kb|expu.3167770','kb|expu.3167762']) returned");
ok(scalar(keys(%{$result})) == 2, "get_expression_samples_data_by_experimental_unit_ids(['kb|expu.3167770','kb|expu.3167762']) appropriately has 2 entries");
if (exists($print_hash{3})) 
{ 
    print Dumper($result);
} 


#Test get_expression_samples_data_by_experiment_meta_ids 
#Test 60-64      
print "\n#get_expression_samples_data_by_experiment_meta_ids portion\n";
$result = undef;
eval { 
    $result = $client->get_expression_samples_data_by_experiment_meta_ids([]); 
}; 
ok($@ =~ /requires a list of valid/,"get_expression_samples_data_by_experiment_meta_ids([]) without experiment_meta_ids throws exception properly");
$result = undef;
eval { 
    $result = $client->get_expression_samples_data_by_experiment_meta_ids(['Not A real ID','kb|not Real']); 
}; 
ok($@ =~ /requires a list of valid/,"get_expression_samples_data_by_experiment_meta_ids(['Not A real ID','kb|not Real']) throws exception properly because fake experiment_meta_ids will not have real experimental_unit_ids associated with them.");
$result = undef;
eval { 
    $result = $client->get_expression_samples_data_by_experiment_meta_ids(['kb|expm.16','kb|expm.15']); 
}; 
ok($@ eq '',"get_expression_samples_data_by_experiment_meta_ids call ". $@);
ok($result,"get_expression_samples_data_by_experiment_meta_ids(['kb|expm.16','kb|expm.15']) returned"); 
ok(scalar(keys(%{$result})) == 2, "get_expression_samples_data_by_experiment_meta_ids(['kb|expm.16','kb|expm.15']) appropriately has 2 entries"); 
if (exists($print_hash{4})) 
{ 
    print Dumper($result);
} 


#Test get_expression_samples_data_by_strain_ids            
#Test 65 - 69 
print "\n#get_expression_samples_data_by_strain_ids portion\n";
$result = undef;
eval { 
    $result = $client->get_expression_samples_data_by_strain_ids([],'microarray'); 
};
ok($@ =~ /requires a list of valid/,"get_expression_samples_data_by_strain_ids([]) without strain_ids throws exception properly"); 
#print "\n ERROR MESSAGE ". $@ . "\n";
$result = undef;
eval { 
    $result = $client->get_expression_samples_data_by_strain_ids(['Not A real ID','kb|not Real'],'microarray');
}; 
ok($@ =~ /requires a list of valid/,"get_expression_samples_ids_by_strain_ids(['Not A real ID','kb|not Real'],'microarray') throws exception properly because fake strain_ids will not have sample_ids associated with them.");
$result = undef;
eval { 
    $result = $client->get_expression_samples_data_by_strain_ids(['kb|str.18124'],'microarray');
}; 
ok($@ eq '',"get_expression_samples_data_by_strain_ids call ". $@);
ok($result,"get_expression_samples_data_by_strain_ids(['kb|str.18124']) returned"); 
ok(scalar(keys(%{$result})) == 1, "get_expression_samples_data_by_strain_ids(['kb|str.18124']) appropriately has 1 entry");
if (exists($print_hash{5}))
{ 
    print Dumper($result);
} 

 
#Test get_expression_samples_data_by_genome_ids 
#Test 70 - 74     
print "\n#get_expression_samples_data_by_genome_ids portion\n";
$result = undef;
eval { 
    $result = $client->get_expression_samples_data_by_genome_ids([],'microarray','N'); 
}; 
ok($@ =~ /requires a list of valid/,"get_expression_samples_data_by_genome_ids([]) without genome_ids throws exception properly"); 
$result = undef;
eval { 
    $result = $client->get_expression_samples_data_by_genome_ids(['Not A real ID','kb|not Real'],'microarray','N');
}; 
ok($@ =~ /requires a list of valid/,"get_expression_samples_ids_by_genome_ids(['Not A real ID','kb|not Real'],'microarray') throws exception properly because fake genome_ids will not have strain_ids associated with them.");
$result = undef;
eval { 
    $result = $client->get_expression_samples_data_by_genome_ids(['kb|g.20848'],'microarray','N');
}; 
ok($@ eq '',"get_expression_samples_data_by_genome_ids call ". $@);
ok($result,"get_expression_samples_data_by_genome_ids(['kb|g.20848']) returned"); 
ok(scalar(keys(%{$result})) == 1, "get_expression_samples_data_by_genome_ids(['kb|g.20848']) appropriately has 1 entry");
if (exists($print_hash{6}))
{ 
    print Dumper($result);
} 

#Test get_expression_samples_data_by_ontology_ids  
#Test 75 - 76 
print "\n#get_expression_samples_data_by_ontology_ids portion\n";
$result = undef; 
eval { 
    $result = $client->get_expression_samples_data_by_ontology_ids([],'or','kb|g.20848','microarray','N');
};
ok($@ =~ /requires a list of valid/,"get_expression_samples_data_by_ontology_ids([],'or','kb|g.20848','microarray','N') without ontology_ids throws exception properly");
$result = undef;
eval { 
    $result = $client->get_expression_samples_data_by_ontology_ids(['Not A real ID','kb|not Real'],'or','kb|g.20848','microarray','N'); 
}; 
ok($@ =~ /requires a list of valid/,"get_expression_samples_data_by_ontology_ids(['Not A real ID','kb|not Real'],'or','kb|g.20848','microarray','N') throws exception properly because fake ontology_ids.");
$result = undef;
eval { 
    $result = $client->get_expression_samples_data_by_ontology_ids(['ENVO:02000086','PO:0030086','PO:0030085'],'or','kb|g.20848','microarray','Y');
};
#
# THIS REQUIRES MORE TESTING BEING ADDED ONCE WE HAVE DATA THAT ACTUALLY HAS ONTOLOGY IDS/ SAMPLE ANNOTATIONS
#
if (exists($print_hash{7})) 
{ 
    print Dumper($result);
} 
 
#Test get_expression_data_by_feature_ids
#Test 77 - 83
print "\n#get_expression_expression_data_by_feature_ids portion\n"; 
$result = undef; 
eval { 
    $result = $client->get_expression_data_by_feature_ids([],'microarray','N'); 
}; 
ok($@ =~ /requires a list of valid/,"get_expression_data_by_feature_ids([]) without feature_ids throws exception properly"); 
$result = undef; 
eval { 
    $result = $client->get_expression_data_by_feature_ids(['Not A real ID','kb|not Real'],'microarray','N'); 
}; 
ok($@ eq '',"get_expression_data_by_feature_ids call ". $@); 
ok($result,"get_expression_data_by_feature_ids(['Not A real ID','kb|not Real']) returned"); 
ok(scalar(keys(%{$result})) == 0, "get_expression_data_by_feature_ids(['Not A real ID','kb|not Real']) appropriately has no entries"); 
#print Dumper($result);   
$result = undef; 
eval { 
    $result = $client->get_expression_data_by_feature_ids(['kb|g.20848.CDS.1800','kb|g.20848.CDS.1687'],'microarray','N'); 
}; 
ok($@ eq '',"get_expression_data_by_feature_ids call ". $@); 
ok($result,"get_expression_data_by_feature_ids(['kb|g.20848.CDS.1800','kb|g.20848.CDS.1687']) returned"); 
ok(scalar(keys(%{$result})) == 2, "get_expression_data_by_feature_ids(['kb|g.20848.CDS.1800','kb|g.20848.CDS.1687']) appropriately has 2 entries");
if (exists($print_hash{8}))
{ 
    print Dumper($result);
} 

#Test compare_samples 
#Test 84 - 88  
print "\n#compare_samples portion\n";
$result = undef; 
eval { 
    $result = $client->compare_samples({},{}); 
}; 
ok($@ =~ /The numerator and.or denominator keys passed to compare_samples are empty/,"compare_samples({},{}); throws the empty hashes exception properly"); 
$result = undef; 
eval {
    $result = $client->compare_samples({'numerator1'=>{}},{'denominator1'=>{}}); 
};
ok($@ =~ /The numerator and.or denominator keys passed had the following empty subhashes/,"compare_samples({'numerator1'=>{}},{'denominator1'=>{}}); throws the empty subhashes exception properly");
$result = undef;
eval { 
    $result = $client->compare_samples({   'numerator1'=>{'feature1'=>1,'feature2'=>2,'feature3'=>3},
					   'numerator2'=>{'feature1'=>-1,'feature2'=>0,'feature3'=>0.5}}, 
				       {   'denominator1'=>{'feature1'=>1.5,'feature2'=>2,'feature3'=>-1},
					   'denominator2'=>{'feature1'=>-.5,'feature2'=>0}});
}; 
ok($@ eq '',"compare_samples({   'numerator1'=>{'feature1'=>1,'feature2'=>2,'feature3'=>3}, 
                                           'numerator2'=>{'feature1'=>-1,'feature2'=>0,'feature3'=>0.5}}, 
                                       {   'denominator1'=>{'feature1'=>1.5,'feature2'=>2,'feature3'=>-1}, 
                                           'denominator2'=>{'feature1'=>-.5,'feature2'=>0}}); 
             call ". $@); 
ok($result,"compare_samples({   'numerator1'=>{'feature1'=>1,'feature2'=>2,'feature3'=>3},
                                           'numerator2'=>{'feature1'=>-1,'feature2'=>0,'feature3'=>0.5}},
                                       {   'denominator1'=>{'feature1'=>1.5,'feature2'=>2,'feature3'=>-1},
                                           'denominator2'=>{'feature1'=>-.5,'feature2'=>0}});
            returned"); 
ok(scalar(keys(%{$result})) == 2, "compare_samples({   'numerator1'=>{'feature1'=>1,'feature2'=>2,'feature3'=>3},            
                                           'numerator2'=>{'feature1'=>-1,'feature2'=>0,'feature3'=>0.5}},
                                       {   'denominator1'=>{'feature1'=>1.5,'feature2'=>2,'feature3'=>-1},
                                           'denominator2'=>{'feature1'=>-.5,'feature2'=>0}}); 
                                  appropriately has 2 entries");
if (exists($print_hash{9}))
{ 
    print Dumper($result); 
} 

#Test Compare_samples_vs_default_controls
#Test 89 - 98
print "\ncompare_samples_vs_default_controls\n";
$result = undef;
eval {
    $result = $client->compare_samples_vs_default_controls([]); 
};
ok($@ =~ /requires a list of valid/,"compare_samples_vs_default_controls([]) without sample_ids throws exception properly"); 
$result = undef; 
eval {
    $result = $client->compare_samples_vs_default_controls(['kb|sample.25']);
};
ok($@ eq '',"compare_samples_vs_default_controls(['kb|sample.25']) call");
ok($result,"compare_samples_vs_default_controls(['kb|sample.25']) returned object");
ok(scalar(keys(%{$result}))== 0 ,"compare_samples_vs_default_controls(['kb|sample.25']) returned object has 0 elements (sample 25 has no control)");
$result = undef; 
eval {
    $result = $client->compare_samples_vs_default_controls(['kb|sample.3','kb|sample.8','kb|sample.25']);
}; 
ok($@ eq '',"compare_samples_vs_default_controls(['kb|sample.3','kb|sample.8','kb|sample.25']) call");
ok($result,"compare_samples_vs_default_controls(['kb|sample.3','kb|sample.8','kb|sample.24']) returned object");
ok(scalar(keys(%{$result}))== 2 ,"compare_samples_vs_default_controls(['kb|sample.3','kb|sample.8','kb|sample.25']) returned object has 2 elements (sample 25 has no control)");
$result = undef; 
eval {
    $result = $client->compare_samples_vs_default_controls(['kb|sample.3','kb|sample.8','kb|sample.1']); 
};
ok($@ eq '',"compare_samples_vs_default_controls(['kb|sample.3','kb|sample.8','kb|sample.1']) call");
ok($result,"compare_samples_vs_default_controls(['kb|sample.3','kb|sample.8','kb|sample.1']) returned object");
ok(scalar(keys(%{$result}))== 3 ,"compare_samples_vs_default_controls(['kb|sample.3','kb|sample.8','kb|sample.1']) returned object has 3 elements");
if (exists($print_hash{10})) 
{ 
    print Dumper($result); 
} 


#Test compare_samples_vs_the_average 
#Test 99 - 103
print "\n#compare_samples_vs_the_average portion\n"; 
$result = undef; 
eval { 
    $result = $client->compare_samples_vs_the_average([],[]); 
}; 
ok($@ =~ /A list of valid sample ids must be present for both the numerator and denominator/,"compare_samples_vs_the_average([],[]); properly throws an exception"); 
$result = undef; 
eval { 
    $result = $client->compare_samples_vs_the_average(['fake sample id'],['fake sample id']); 
}; 
ok($@ =~ /The numerator and.or denominator keys passed to compare_samples are empty/,"compare_samples_vs_the_average(['fake sample id'],['fake sample id']); empty hashes passed to through to the compare_samples function: exception thrown properly"); 
$result = undef; 
eval { 
    $result = $client->compare_samples_vs_the_average(['kb|sample.3','kb|sample.8','kb|sample.1'], ['kb|sample.3','kb|sample.8','kb|sample.1']);
};
ok($@ eq '',"compare_samples_vs_the_average(['kb|sample.3','kb|sample.8','kb|sample.1'], ['kb|sample.3','kb|sample.8','kb|sample.1']); call");
ok($result,"compare_samples_vs_the_average(['kb|sample.3','kb|sample.8','kb|sample.1'], ['kb|sample.3','kb|sample.8','kb|sample.1']); returned object");
ok(scalar(keys(%{$result}))== 3 ,"compare_samples_vs_the_average(['kb|sample.3','kb|sample.8','kb|sample.1'], ['kb|sample.3','kb|sample.8','kb|sample.1']); returned object has 3 elements"); 
if (exists($print_hash{11}))
{ 
    print Dumper($result); 
} 

#Test get_on_off_calls
#Test 104 - 108
print "\nget_on_off_calls portion\n";
$result = undef;
eval { 
    $result = $client->get_on_off_calls({},-1,1); 
};
ok($@ =~ /The sampleComparisonMapping .1st argument, the hash was empty/,"get_on_off_calls({},-1,1); properly throws an exception"); 
$result = undef; 
eval {
    $result = $client->get_on_off_calls($client->compare_samples({   'numerator1'=>{'feature1'=>1,'feature2'=>2,'feature3'=>3}, 
								     'numerator2'=>{'feature1'=>-1,'feature2'=>0,'feature3'=>0.5}}, 
								 {   'denominator1'=>{'feature1'=>1.5,'feature2'=>2,'feature3'=>-1},
								     'denominator2'=>{'feature1'=>-.5,'feature2'=>0}}),'A',1);
};
ok($@ =~ /The off threshold must be a valid number/,"get_on_off_calls($client->compare_samples(
                                                                 {   
                                                                     'numerator1'=>{'feature1'=>1,'feature2'=>2,'feature3'=>3},
                                                                     'numerator2'=>{'feature1'=>-1,'feature2'=>0,'feature3'=>0.5}},
                                                                 {   'denominator1'=>{'feature1'=>1.5,'feature2'=>2,'feature3'=>-1}, 
                                                                     'denominator2'=>{'feature1'=>-.5,'feature2'=>0}}),'A',1); 
                                                      properly throws an exception");
$result = undef;
eval {
    $result = $client->get_on_off_calls($client->compare_samples({   'numerator1'=>{'feature1'=>1,'feature2'=>2,'feature3'=>3},
                                                                     'numerator2'=>{'feature1'=>-1,'feature2'=>0,'feature3'=>0.5}},
                                                                 {   'denominator1'=>{'feature1'=>1.5,'feature2'=>2,'feature3'=>-1}, 
                                                                     'denominator2'=>{'feature1'=>-.5,'feature2'=>0}}),0,'jghhe'); 
}; 
ok($@ =~ /The on threshold must be a valid number/,"get_on_off_calls($client->compare_samples( 
                                                                           {
									       'numerator1'=>{'feature1'=>1,'feature2'=>2,'feature3'=>3},
									       'numerator2'=>{'feature1'=>-1,'feature2'=>0,'feature3'=>0.5}},
									   {   'denominator1'=>{'feature1'=>1.5,'feature2'=>2,'feature3'=>-1},
									       'denominator2'=>{'feature1'=>-.5,'feature2'=>0}}),'A',1);
                                                      properly throws an exception"); 
$result = undef; 
eval {
    $result = $client->get_on_off_calls($client->compare_samples({   'numerator1'=>{'feature1'=>1,'feature2'=>2,'feature3'=>3},
                                                                     'numerator2'=>{'feature1'=>-1,'feature2'=>0,'feature3'=>0.5}}, 
                                                                 {   'denominator1'=>{'feature1'=>1.5,'feature2'=>2,'feature3'=>-1}, 
                                                                     'denominator2'=>{'feature1'=>-.5,'feature2'=>0}}),'','');
}; 
ok($@ eq '',"Worked with empty thresholds get_on_off_calls($client->compare_samples( 
									  {                                                                        
									      'numerator1'=>{'feature1'=>1,'feature2'=>2,'feature3'=>3},           
                                                                               'numerator2'=>{'feature1'=>-1,'feature2'=>0,'feature3'=>0.5}}, 
                                                                           {   'denominator1'=>{'feature1'=>1.5,'feature2'=>2,'feature3'=>-1}, 
                                                                               'denominator2'=>{'feature1'=>-.5,'feature2'=>0}}),'','');"); 
$result = undef; 
eval {
    $result = $client->get_on_off_calls($client->compare_samples({   'numerator1'=>{'feature1'=>1,'feature2'=>2,'feature3'=>3},
                                                                     'numerator2'=>{'feature1'=>-1,'feature2'=>0,'feature3'=>0.5}}, 
                                                                 {   'denominator1'=>{'feature1'=>1.5,'feature2'=>2,'feature3'=>-1}, 
                                                                     'denominator2'=>{'feature1'=>-.5,'feature2'=>0}}),-1,1); 
}; 
ok($@ eq '',"Worked with filled thresholds get_on_off_calls($client->compare_samples(  
                                                                          {   
                                                                              'numerator1'=>{'feature1'=>1,'feature2'=>2,'feature3'=>3}, 
                                                                               'numerator2'=>{'feature1'=>-1,'feature2'=>0,'feature3'=>0.5}}, 
                                                                           {   'denominator1'=>{'feature1'=>1.5,'feature2'=>2,'feature3'=>-1},
                                                                               'denominator2'=>{'feature1'=>-.5,'feature2'=>0}}),'','');"); 
if (exists($print_hash{12}))
{ 
    print Dumper($result);
} 



#Test get_top_changers   
#Test 109 - 113                                           
print "\nget_top_changers portion\n";
$result = undef;
eval {
    $result = $client->get_top_changers({},'BOTH',10);
};
ok($@ =~ /The sampleComparisonMapping .1st argument, the hash was empty/,"get_top_changers({},'BOTH',10); properly throws an exception");
$result = undef;
eval { 
    $result = $client->get_top_changers($client->compare_samples_vs_default_controls(['kb|sample.3','kb|sample.8','kb|sample.1']),'blah',10);
}; 
ok($@ =~ /The Direction .2nd argument. must be equal to 'UP','DOWN', or 'BOTH'/,"get_top_changers(client->compare_samples_vs_default_controls(['kb|sample.3','kb|sample.8','kb|sample.1']),'blah',10); properly throws an exception"); 
$result = undef; 
eval {
    $result = $client->get_top_changers($client->compare_samples_vs_default_controls(['kb|sample.3','kb|sample.8','kb|sample.1']),'BOTH',-1);
};
ok($@ =~ /The count of top changers returned has to be a positive integer/,"get_top_changers(client->compare_samples_vs_default_controls(['kb|\
sample.3','kb|sample.8','kb|sample.1']),'BOTH',-1); properly throws an exception"); 
$result = undef;
eval {
    $result = $client->get_top_changers($client->compare_samples_vs_default_controls(['kb|sample.3','kb|sample.8','kb|sample.1']),'BOTH','dfgjh');
}; 
ok($@ =~ /The count of top changers returned has to be a positive integer/,"get_top_changers(client->compare_samples_vs_default_controls(['kb|sample.3','kb|sample.8','kb|sample.1']),'BOTH','dfgjh'); properly throws an exception"); 
$result = undef;
eval {
    $result = $client->get_top_changers($client->compare_samples_vs_default_controls(['kb|sample.3','kb|sample.8','kb|sample.1']),'BOTH',10);
}; 
ok($@ eq '', "get_top_changers(client->compare_samples_vs_default_controls(['kb|sample.3','kb|sample.8','kb|sample.1']),'BOTH',10); returned ");
if (exists($print_hash{13}))
{
    print Dumper($result);
}
 
#Test get_expression_sample_ids_by_series_ids
#Test 114 - 118
print "\nget_expression_sample_ids_by_series_ids portion\n";
$result = undef; 
eval { 
    $result = $client->get_expression_sample_ids_by_series_ids([]);
}; 
ok($@ =~ /requires a list of valid/,"get_expression_sample_ids_by_series([]) without series_ids throws exception properly");
$result = undef; 
eval { 
    $result = $client->get_expression_sample_ids_by_series_ids(['Not A real ID','kb|not Real']);
}; 
ok(scalar(@{$result}) == 0,"get_expression_sample_ids_by_series(['Not A real ID','kb|not Real']) throws exception properly because  fake series IDS will not have real sample ids associated with them."); 
$result = undef; 
eval { 
    $result = $client->get_expression_sample_ids_by_series_ids(['kb|series.0','kb|series.3']);
}; 
ok($@ eq '',"get_expression_sample_ids_by_series_id call ". $@); 
ok($result,"get_expression_samples_data_by_series_ids(['kb|series.0','kb|series.1']) returned");
ok(scalar(@{$result}) == 36, "get_expression_sample_ids_by_series_ids('kb|series.0','kb|series.1']) appropriately has 36 elements in the array");
if (exists($print_hash{14}))
{ 
    print Dumper($result);
} 



#Test get_expression_sample_ids_by_experimental_unit_ids 
#Test 119 - 123      
print "\nget_expression_sample_ids_by_experimental_unit_ids portion\n"; 
$result = undef; 
eval { 
    $result = $client->get_expression_sample_ids_by_experimental_unit_ids([]);
}; 
ok($@ =~ /requires a list of valid/,"get_expression_sample_ids_by_experimental_unit_ids([]) without experimental_unit_ids throws exception properly");
$result = undef;
eval { 
    $result = $client->get_expression_sample_ids_by_experimental_unit_ids(['Not A real ID','kb|not Real']);
}; 
ok(scalar(@{$result}) == 0,"get_expression_sample_ids_by_experimental_unit_ids(['Not A real ID','kb|not Real']) throws exception properly because fake exp unit IDS will not have real sample ids associated with them."); 
$result = undef;
eval { 
    $result = $client->get_expression_sample_ids_by_experimental_unit_ids(['kb|expu.3167770','kb|expu.3167762']); 
}; 
ok($@ eq '',"get_expression_sample_ids_by_experimental_unit_ids call ". $@);
ok($result,"get_expression_samples_data_by_experimental_unit_ids(['kb|expu.3167770','kb|expu.3167762']) returned"); 
ok(scalar(@{$result}) == 2, "get_expression_sample_ids_by_series_ids('kb|expu.3167770','kb|expu.3167762']) appropriately has 2 elements in the array");
if (exists($print_hash{15})) 
{ 
    print Dumper($result);
} 
 

#Test get_expression_sample_ids_by_experiment_meta_ids      
#Test 124 - 128 
print "\n#get_expression_sample_ids_by_experiment_meta_ids portion\n"; 
$result = undef; 
eval { 
    $result = $client->get_expression_sample_ids_by_experiment_meta_ids([]);
}; 
ok($@ =~ /requires a list of valid/,"get_expression_sample_ids_by_experiment_meta_ids([]) without experiment_meta_ids throws exception properly");
$result = undef; 
eval { 
    $result = $client->get_expression_sample_ids_by_experiment_meta_ids(['Not A real ID','kb|not Real']);
}; 
ok(scalar(@{$result}) == 0,"get_expression_sample_ids_by_experiment_meta_ids(['Not A real ID','kb|not Real']) throws exception properly because fake experiment_meta_ids will not have real experimental_unit_ids associated with them."); 
$result = undef;
eval { 
    $result = $client->get_expression_sample_ids_by_experiment_meta_ids(['kb|expm.16','kb|expm.15']);
}; 
ok($@ eq '',"get_expression_sample_ids_by_experiment_meta_ids call ". $@);
ok($result,"get_expression_sample_ids_by_experiment_meta_ids(['kb|expm.16','kb|expm.15']) returned"); 
ok(scalar(@{$result}) == 14, "get_expression_samples_data_by_experiment_meta_ids(['kb|expm.16','kb|expm.15']) appropriately has 14 entries"); 
if (exists($print_hash{16})) 
{ 
#    print "\n" .scalar(@{$result}) . "\n";
    print Dumper($result);
} 

#Test get_expression_sample_ids_by_strain_ids  
#Test 129 - 133     
print "\n#get_expression_sample_ids_by_strain_ids portion\n"; 
$result = undef; 
eval {
    $result = $client->get_expression_sample_ids_by_strain_ids([],'microarray');
};
ok($@ =~ /requires a list of valid/,"get_expression_sample_ids_by_strain_ids([]) without strain_ids throws exception properly");
$result = undef; 
eval { 
    $result = $client->get_expression_sample_ids_by_strain_ids(['Not A real ID','kb|not Real'],'microarray'); 
}; 
ok(scalar(@{$result}) == 0,"get_expression_samples_ids_by_strain_ids(['Not A real ID','kb|not Real'],'microarray') throws exception properly because fake strain_ids will not have sample_ids associated with them."); 
$result = undef; 
eval { 
    $result = $client->get_expression_sample_ids_by_strain_ids(['kb|str.18124'],'microarray'); 
}; 
ok($@ eq '',"get_expression_sample_ids_by_strain_ids call ". $@); 
ok($result,"get_expression_sample_ids_by_strain_ids(['kb|str.18124']) returned"); 
ok(scalar(@{$result}) == 36, "get_expression_sample_ids_by_strain_ids(['kb|str.18124']) appropriately has 36 entries"); 
if (exists($print_hash{17})) 
{ 
    print Dumper($result); 
} 


#Test get_expression_sample_ids_by_genome_ids  
#Test 134 - 138  
print "\n#get_expression_sample_ids_by_genome_ids portion\n"; 
$result = undef; 
eval {
    $result = $client->get_expression_sample_ids_by_genome_ids([],'microarray','N'); 
}; 
ok($@ =~ /requires a list of valid/,"get_expression_sample_ids_by_genome_ids([]) without genome_ids throws exception properly");
$result = undef; 
eval { 
    $result = $client->get_expression_sample_ids_by_genome_ids(['Not A real ID','kb|not Real'],'microarray','N');
}; 
ok(scalar(@{$result}) == 0,"get_expression_sample_ids_by_genome_ids(['Not A real ID','kb|not Real'],'microarray') throws exception properly because fake genome_ids will not have strain_ids associated with them.");
$result = undef;
eval {
    $result = $client->get_expression_sample_ids_by_genome_ids(['kb|g.20848'],'microarray','N');
}; 
ok($@ eq '',"get_expression_sample_ids_by_genome_ids call ". $@); 
ok($result,"get_expression_sample_ids_by_genome_ids(['kb|g.20848']) returned");
ok(scalar(@{$result}) == 36, "get_expression_sample_ids_by_genome_ids(['kb|g.20848']) appropriately has 36 entries");
if (exists($print_hash{18}))
{ 
    print Dumper($result);
} 

#Test get_expression_samples_titles
#Test 139 - 143
print "\n#get_expression_samples_titles portion \n";
$result = undef;
eval {
    $result = $client->get_expression_samples_titles([]);
};
ok($@ =~ /requires a list of valid/,"get_expression_sample_titles([]) without sample_ids throws exception properly"); 
$result = undef; 
eval { 
    $result = $client->get_expression_sample_titles(['Not A real ID','kb|not Real']);
}; 
ok(scalar(keys(%{$result})) == 0,"get_expression_sample_titles(['Not A real ID','kb|not Real']) throws exception properly because fake sample_ids will not have titles associated with them."); 
eval {
    $result = $client->get_expression_samples_titles(['kb|sample.2','kb|sample.3']);
};
ok($@ eq '',"get_expression_sample_titles call ". $@); 
ok($result,"get_expression_sample_titles(['kb|sample.2','kb|sample.3']); returned");
ok(scalar(keys(%{$result})) == 2, "get_expression_sample_titles(['kb|sample.2','kb|sample.3']); appropriately has 2 entries");
if (exists($print_hash{19}))
{ 
    print Dumper($result); 
} 

#Test get_expression_samples_descriptions         
#Test 144 - 148      
print "\n#get_expression_samples_descriptions portion \n"; 
$result = undef; 
eval { 
    $result = $client->get_expression_samples_descriptions([]); 
}; 
ok($@ =~ /requires a list of valid/,"get_expression_sample_descriptions([]) without sample_ids throws exception properly"); 
$result = undef; 
eval { 
    $result = $client->get_expression_sample_descriptions(['Not A real ID','kb|not Real']);
}; 
ok(scalar(keys(%{$result})) == 0,"get_expression_sample_descriptions(['Not A real ID','kb|not Real']) throws exception properly because fake sample_ids will not have data associated with them.");
eval {
    $result = $client->get_expression_samples_descriptions(['kb|sample.2','kb|sample.3']); 
}; 
ok($@ eq '',"get_expression_sample_descriptions call ". $@);
ok($result,"get_expression_sample_descriptions(['kb|sample.2','kb|sample.3']); returned"); 
ok(scalar(keys(%{$result})) == 2, "get_expression_sample_descriptions(['kb|sample.2','kb|sample.3']); appropriately has 2 entries");
if (exists($print_hash{20})) 
{ 
    print Dumper($result);
} 

#Test get_expression_samples_molecules
#Test 149 - 153      
print "\n#get_expression_samples_molecules portion \n"; 
$result = undef; 
eval { 
    $result = $client->get_expression_samples_molecules([]); 
}; 
ok($@ =~ /requires a list of valid/,"get_expression_sample_molecules([]) without sample_ids throws exception properly"); 
$result = undef; 
eval { 
    $result = $client->get_expression_sample_molecules(['Not A real ID','kb|not Real']); 
}; 
ok(scalar(keys(%{$result})) == 0,"get_expression_sample_molecules(['Not A real ID','kb|not Real']) throws exception properly because fake sample_ids will not have data associated with them."); 
eval { 
    $result = $client->get_expression_samples_molecules(['kb|sample.2','kb|sample.3']); 
}; 
ok($@ eq '',"get_expression_sample_molecules call ". $@); 
ok($result,"get_expression_sample_molecules(['kb|sample.2','kb|sample.3']); returned"); 
ok(scalar(keys(%{$result})) == 2, "get_expression_sample_molecules(['kb|sample.2','kb|sample.3']); appropriately has 2 entries"); 
if (exists($print_hash{21})) 
{ 
    print Dumper($result); 
} 


#Test get_expression_samples_types
#Test 154 - 158                 
print "\n#get_expression_samples_types portion \n";
$result = undef; 
eval {
    $result = $client->get_expression_samples_types([]); 
}; 
ok($@ =~ /requires a list of valid/,"get_expression_sample_types([]) without sample_ids throws exception properly");
$result = undef;
eval { 
    $result = $client->get_expression_sample_types(['Not A real ID','kb|not Real']);
}; 
ok(scalar(keys(%{$result})) == 0,"get_expression_sample_types(['Not A real ID','kb|not Real']) throws exception properly because fake sample_ids will not have data associated with them.");
eval { 
    $result = $client->get_expression_samples_types(['kb|sample.2','kb|sample.3']);
};
ok($@ eq '',"get_expression_sample_types call ". $@);
ok($result,"get_expression_sample_types(['kb|sample.2','kb|sample.3']); returned");
ok(scalar(keys(%{$result})) == 2, "get_expression_sample_types(['kb|sample.2','kb|sample.3']); appropriately has 2 entries");
if (exists($print_hash{22}))
{ 
    print Dumper($result); 
} 
 

#Test get_expression_samples_external_source_ids
#Test 159 - 163                
print "\n#get_expression_samples_external_source_ids portion \n";
$result = undef; 
eval {
    $result = $client->get_expression_samples_external_source_ids([]); 
}; 
ok($@ =~ /requires a list of valid/,"get_expression_sample_external_source_ids([]) without sample_ids throws exception properly");
$result = undef;
eval { 
    $result = $client->get_expression_sample_external_source_ids(['Not A real ID','kb|not Real']);
}; 
ok(scalar(keys(%{$result})) == 0,"get_expression_sample_external_source_ids(['Not A real ID','kb|not Real']) throws exception properly because fake sample_ids will not have data associated with them.");
eval { 
    $result = $client->get_expression_samples_external_source_ids(['kb|sample.2','kb|sample.3']);
};
ok($@ eq '',"get_expression_sample_external_source_ids call ". $@);
ok($result,"get_expression_sample_external_source_ids(['kb|sample.2','kb|sample.3']); returned");
ok(scalar(keys(%{$result})) == 2, "get_expression_sample_external_source_ids(['kb|sample.2','kb|sample.3']); appropriately has 2 entries");
if (exists($print_hash{23}))
{ 
    print Dumper($result); 
} 
 

#Test get_expression_samples_original_log2_medians                                                                          
#Test 164 - 168                    
print "\n#get_expression_samples_original_log2_medians portion \n";
$result = undef;
eval {
    $result = $client->get_expression_samples_original_log2_medians([]);
};
ok($@ =~ /requires a list of valid/,"get_expression_sample_original_log2_medians([]) without sample_ids throws exception properly");
$result = undef;
eval {
    $result = $client->get_expression_sample_original_log2_medians(['Not A real ID','kb|not Real']);
};
ok(scalar(keys(%{$result})) == 0,"get_expression_sample_original_log2_medians(['Not A real ID','kb|not Real']) throws exception properly because fake sample_ids will not have data associated with them.");
eval {
    $result = $client->get_expression_samples_original_log2_medians(['kb|sample.2','kb|sample.3']);
}; 
ok($@ eq '',"get_expression_sample_original_log2_medians call ". $@); 
ok($result,"get_expression_sample_original_log2_medians(['kb|sample.2','kb|sample.3']); returned"); 
ok(scalar(keys(%{$result})) == 2, "get_expression_sample_original_log2_medians(['kb|sample.2','kb|sample.3']); appropriately has 2 entries"); 
if (exists($print_hash{24})) 
{ 
    print Dumper($result); 
} 
 
#Test get_expression_series_titles  
#Test 169-173
print "\n#get_expression_series_titles portion \n";
$result = undef; 
eval {
    $result = $client->get_expression_series_titles([]);
};
ok($@ =~ /requires a list of valid/,"get_expression_series_titles([]) without series_ids throws exception properly");
$result = undef;
eval {
    $result = $client->get_expression_series_titles(['Not A real ID','kb|not Real']);
};
ok(scalar(keys(%{$result})) == 0,"get_expression_series_titles(['Not A real ID','kb|not Real']) throws exception properly because fake series_ids will not have data associated with them.");
eval {
    $result = $client->get_expression_series_titles(['kb|series.1','kb|series.0']);
};
ok($@ eq '',"get_expression_series_titles call ". $@);
ok($result,"get_expression_series_titles(['kb|series.1','kb|series.0']); returned");
ok(scalar(keys(%{$result})) == 2, "get_expression_series_titles(['kb|series.1','kb|series.0']); appropriately has 2 entries");
if (exists($print_hash{25}))
{
    print Dumper($result);
}
 
#Test get_expression_series_summaries  
#Test 174 - 178        
print "\n#get_expression_series_summaries portion \n";
$result = undef; 
eval { 
    $result = $client->get_expression_series_summaries([]);
}; 
ok($@ =~ /requires a list of valid/,"get_expression_series_summaries([]) without series_ids throws exception properly");
$result = undef; 
eval { 
    $result = $client->get_expression_series_summaries(['Not A real ID','kb|not Real']);
}; 
ok(scalar(keys(%{$result})) == 0,"get_expression_series_summaries(['Not A real ID','kb|not Real']) throws exception properly because fake series_ids will not have data associated with them.");
eval { 
    $result = $client->get_expression_series_summaries(['kb|series.1','kb|series.0']);
}; 
ok($@ eq '',"get_expression_series_summaries call ". $@);
ok($result,"get_expression_series_summaries(['kb|series.1','kb|series.0']); returned");
ok(scalar(keys(%{$result})) == 2, "get_expression_series_summaries(['kb|series.1','kb|series.0']); appropriately has 2 entries");
if (exists($print_hash{26})) 
{ 
    print Dumper($result); 
} 



#Test get_expression_series_designs   
#Test 179 - 183                                                                                         
print "\n#get_expression_series_designs portion \n";
$result = undef; 
eval {
    $result = $client->get_expression_series_designs([]);
};
ok($@ =~ /requires a list of valid/,"get_expression_series_designs([]) without series_ids throws exception properly");
$result = undef;
eval {
    $result = $client->get_expression_series_designs(['Not A real ID','kb|not Real']);
};
ok(scalar(keys(%{$result})) == 0,"get_expression_series_designs(['Not A real ID','kb|not Real']) throws exception properly because fake series_ids will not have data associated with them.");
eval {
    $result = $client->get_expression_series_designs(['kb|series.1','kb|series.0']);
};
ok($@ eq '',"get_expression_series_designs call ". $@);
ok($result,"get_expression_series_designs(['kb|series.1','kb|series.0']); returned");
ok(scalar(keys(%{$result})) == 2, "get_expression_series_designs(['kb|series.1','kb|series.0']); appropriately has 2 entries");
if (exists($print_hash{27}))
{
    print Dumper($result);
}
 
#Test get_expression_series_external_source_ids  
#Test 184 - 188         
print "\n#get_expression_series_external_source_ids portion \n"; 
$result = undef; 
eval { 
    $result = $client->get_expression_series_external_source_ids([]); 
}; 
ok($@ =~ /requires a list of valid/,"get_expression_series_external_source_ids([]) without series_ids throws exception properly"); 
$result = undef; 
eval { 
    $result = $client->get_expression_series_external_source_ids(['Not A real ID','kb|not Real']); 
}; 
ok(scalar(keys(%{$result})) == 0,"get_expression_series_external_source_ids(['Not A real ID','kb|not Real']) throws exception properly because fake series_ids will not have data associated with them."); 
eval { 
    $result = $client->get_expression_series_external_source_ids(['kb|series.1','kb|series.0']); 
}; 
ok($@ eq '',"get_expression_series_external_source_ids call ". $@); 
ok($result,"get_expression_series_external_source_ids(['kb|series.1','kb|series.0']); returned"); 
ok(scalar(keys(%{$result})) == 2, "get_expression_series_external_source_ids(['kb|series.1','kb|series.0']); appropriately has 2 entries"); 
if (exists($print_hash{28})) 
{ 
    print Dumper($result); 
} 





Server::stop($pid);

done_testing($n_tests);
