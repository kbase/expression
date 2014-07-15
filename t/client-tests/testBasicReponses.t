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
#
#  modified for new data and the CDS 2/3/2014


use strict; 
use warnings; 
use Data::Dumper; 
use Test::More; 
use lib "lib"; 
use lib "t"; 
use Bio::KBase::KBaseExpression::KBaseExpressionClient; 
use Server; 

###########################################################################

# MAKE SURE WE LOCALLY HAVE JSON RPC LIBS
#--
use_ok("JSON::RPC::Client");
use_ok("Bio::KBase::KBaseExpression::KBaseExpressionClient");
 
#NEW VERSION WITH AUTO START / STOP SERVICE
#--
use Server;
#my ($pid, $url) = Server::start('ExpressionServices');
my ($pid, $url) = Server::start('KBaseExpression');
print "-> attempting to connect to:'".$url."' with PID=$pid\n";
#Next line works as well
#my $client = KBaseExpressionClient->new($url); 
#next line was not working for a while compile typespec portion of Makefile was to blame.  Now works
my $client = Bio::KBase::KBaseExpression::KBaseExpressionClient->new($url);
ok(defined($client),"instantiating KBaseExpression client");

 
#############################################################################                                                                   
# HERE IS A LIST OF METHODS AND PARAMETERS THAT WE WANT TO TEST                                                                                 
# NOTE THAT THE PARAMETERS ASSUME the initial load of Arabadopsis plant is loaded.                                                                  
my $func_calls = { 
                get_expression_samples_data=>[['kb|sample.3775','kb|sample.3776']], 
		get_expression_data_by_samples_and_features=>[['kb|sample.3775','kb|sample.3776','kb|sample.3777','kb|sample.3778'], 
                                       ['kb|g.3899.CDS.35409','kb|g.3899.CDS.35410','kb|g.3899.CDS.35411','kb|g.3899.CDS.35402'],'Log2 level intensities'], 
                get_expression_samples_data_by_series_ids=>[['kb|series.283','kb|series.284']], 
		get_expression_sample_ids_by_series_ids=>[['kb|series.283','kb|series.284']], 
#                get_expression_samples_data_by_experimental_unit_ids=>[['kb|expu.3167770','kb|expu.3167762']],
#		get_expression_sample_ids_by_experimental_unit_ids=>[['kb|expu.3167770','kb|expu.3167762']], 
#                get_expression_samples_data_by_experiment_meta_ids=>[['kb|expm.16','kb|expm.15']],
#		get_expression_sample_ids_by_experiment_meta_ids=>[['kb|expm.16','kb|expm.15']],  
                get_expression_samples_data_by_strain_ids=>[['kb|str.2'],'microarray'],
		get_expression_sample_ids_by_strain_ids=>[['kb|str.2'],'microarray'], 
		get_expression_samples_data_by_genome_ids=>[['kb|g.3907'],'microarray','Y'], 
		get_expression_sample_ids_by_genome_ids=>[['kb|g.3907'],'microarray','Y'],
                get_expression_samples_data_by_ontology_ids=>[['EO:0007174','PO:0000014','PO:0009025'],'or','kb|g.3899','microarray','Y'], 
                get_expression_samples_data_by_ontology_ids=>[['EO:0007174','PO:0000014','PO:0009025'],'and','kb|g.3899','microarray','Y'], 
		get_expression_sample_ids_by_ontology_ids=>[['EO:0007174','PO:0000014','PO:0009025'],'and','kb|g.3899','microarray','Y'],
		get_expression_sample_ids_by_ontology_ids=>[['EO:0007174','PO:0000014','PO:0009025'],'or','kb|g.3899','microarray','Y'],
                get_expression_data_by_feature_ids=>[['kb|g.3899.CDS.35409','kb|g.3899.CDS.35410'],'microarray','Y'], 
                compare_samples=>[{   'numerator1'=>{'feature1'=>1,'feature2'=>2,'feature3'=>3}, 
				      'numerator2'=>{'feature1'=>-1,'feature2'=>0,'feature3'=>0.5}}, 
				  {    'denominator1'=>{'feature1'=>1.5,'feature2'=>2,'feature3'=>-1}, 
				       'denominator2'=>{'feature1'=>-.5,'feature2'=>0}}], 
#                compare_samples_vs_default_controls=>[['kb|sample.3775','kb|sample.3776']], 
                compare_samples_vs_the_average=>[['kb|sample.3775','kb|sample.3776','kb|sample.3777'], ['kb|sample.3775','kb|sample.3776','kb|sample.3777']], 
                get_on_off_calls=>[$client->compare_samples({   'numerator1'=>{'feature1'=>1,'feature2'=>2,'feature3'=>3}, 
								'numerator2'=>{'feature1'=>-1,'feature2'=>0,'feature3'=>0.5}}, 
							    {    'denominator1'=>{'feature1'=>1.5,'feature2'=>2,'feature3'=>-1}, 
								 'denominator2'=>{'feature1'=>-.5,'feature2'=>0}}),-1,1], 
#                get_top_changers=>[$client->compare_samples_vs_default_controls(['kb|sample.3775','kb|sample.3776','kb|sample.1']),'BOTH',10],
		get_expression_samples_titles=>[['kb|sample.3775','kb|sample.3776']],
		get_expression_samples_descriptions=>[['kb|sample.3775','kb|sample.3776']],
		get_expression_samples_molecules=>[['kb|sample.3775','kb|sample.3776']],
		get_expression_samples_types=>[['kb|sample.3775','kb|sample.3776']], 
		get_expression_samples_external_source_ids=>[['kb|sample.3775','kb|sample.3776']],
		get_expression_samples_original_log2_medians=>[['kb|sample.3775','kb|sample.3776']],
		get_expression_series_titles=>[['kb|series.283','kb|series.284']],
		get_expression_series_summaries=>[['kb|series.283','kb|series.284']],
		get_expression_series_designs=>[['kb|series.283','kb|series.284']], 
		get_expression_series_external_source_ids=>[['kb|series.283','kb|series.284']], 
		get_expression_sample_ids_by_sample_external_source_ids=>[['GSM265857','GSM265858']],
		get_expression_sample_ids_by_platform_external_source_ids=>[['GPL198']],
		get_expression_series_ids_by_series_external_source_ids=>[['GSE10016']],
};
###########################################################################     
my $n_tests = (scalar(keys %$func_calls)+3); # set this to be the number of function calls + 3;   


# LOOP THROUGH ALL THE REMOTE CALLS AND MAKE SURE WE GOT SOMETHING
my $method_name;
for $method_name (reverse(sort(keys %$func_calls))) {
    #print "==========\n$method_name => @{ $func_calls->{$method_name}}\n";
    #my $n_args = scalar @{ $func_calls->{$method_name}};
    my $result;
    print "calling function: \"$method_name\"\n";
    {
	no strict "refs";
	eval {
	     $result = $client->$method_name(@{ $func_calls->{$method_name}});
	};
	my $client_error = $@;
	if ($client_error) {
	   print $client_error->message."\n";
	}
    }
    ok($result,"looking for a response from \"$method_name\"");
}

Server::stop($pid);

done_testing($n_tests);
