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

###########################################################################

# MAKE SURE WE LOCALLY HAVE JSON RPC LIBS
#--
use_ok("JSON::RPC::Client");
use_ok("Bio::KBase::ExpressionServices::ExpressionServicesClient");
 
#NEW VERSION WITH AUTO START / STOP SERVICE
#--
use Server;
my ($pid, $url) = Server::start('ExpressionServices');
print "-> attempting to connect to:'".$url."' with PID=$pid\n";
#Next line works as well
#my $client = ExpressionServicesClient->new($url); 
#next line was not working for a while compile typespec portion of Makefile was to blame.  Now works
my $client = Bio::KBase::ExpressionServices::ExpressionServicesClient->new($url);
ok(defined($client),"instantiating ExpressionServices client");

 
#############################################################################                                                                   
# HERE IS A LIST OF METHODS AND PARAMETERS THAT WE WANT TO TEST                                                                                 
# NOTE THAT THE PARAMETERS ASSUME the initial load of Adam D's data is loaded.                                                                  
# Currently this is using the expression schema as the tables are not in the CDS yet.                                                        
my $func_calls = { 
                get_expression_samples_data=>[['kb|sample.2','kb|sample.3']], 
		get_expression_data_by_samples_and_features=>[['kb|sample.2','kb|sample.3','kb|sample.7','kb|sample.10'], 
                                       ['kb|g.20848.CDS.1800','kb|g.20848.CDS.1687','kb|g.20848.CDS.180','kb|g.20848.CDS.1085']], 
                get_expression_samples_data_by_series_ids=>[['kb|series.1','kb|series.0']], 
		get_expression_sample_ids_by_series_ids=>[['kb|series.1','kb|series.0']], 
                get_expression_samples_data_by_experimental_unit_ids=>[['kb|expu.3167770','kb|expu.3167762']],
		get_expression_sample_ids_by_experimental_unit_ids=>[['kb|expu.3167770','kb|expu.3167762']], 
                get_expression_samples_data_by_experiment_meta_ids=>[['kb|expm.16','kb|expm.15']],
		get_expression_sample_ids_by_experiment_meta_ids=>[['kb|expm.16','kb|expm.15']],  
                get_expression_samples_data_by_strain_ids=>[['kb|str.18124','kb|str.7634','kb|str.999'],'microarray'],
		get_expression_sample_ids_by_strain_ids=>[['kb|str.18124'],'microarray'], 
		get_expression_samples_data_by_genome_ids=>[['kb|g.20848','kb|g.0'],'microarray','Y'], 
		get_expression_sample_ids_by_genome_ids=>[['kb|g.20848','kb|g.0'],'microarray','Y'],
                get_expression_samples_data_by_ontology_ids=>[['ENVO:02000086','PO:0030086','PO:0030085'],'or','kb|g.20848','microarray','Y'], 
                get_expression_samples_data_by_ontology_ids=>[['ENVO:02000086','PO:0030086'],'and','kb|g.20848','microarray','Y'], 
		get_expression_sample_ids_by_ontology_ids=>[['ENVO:02000086','PO:0030086'],'and','kb|g.20848','microarray','Y'],
		get_expression_sample_ids_by_ontology_ids=>[['ENVO:02000086','PO:0030086','PO:0030085'],'or','kb|g.20848','microarray','Y'],
                get_expression_data_by_feature_ids=>[['kb|g.20848.CDS.1800','kb|g.20848.CDS.1687'],'microarray','Y'], 
                compare_samples=>[{   'numerator1'=>{'feature1'=>1,'feature2'=>2,'feature3'=>3}, 
				      'numerator2'=>{'feature1'=>-1,'feature2'=>0,'feature3'=>0.5}}, 
				  {    'denominator1'=>{'feature1'=>1.5,'feature2'=>2,'feature3'=>-1}, 
				       'denominator2'=>{'feature1'=>-.5,'feature2'=>0}}], 
                compare_samples_vs_default_controls=>[['kb|sample.3','kb|sample.8','kb|sample.1']], 
                compare_samples_vs_the_average=>[['kb|sample.3','kb|sample.8','kb|sample.1'], ['kb|sample.3','kb|sample.8','kb|sample.1']], 
                get_on_off_calls=>[$client->compare_samples({   'numerator1'=>{'feature1'=>1,'feature2'=>2,'feature3'=>3}, 
								'numerator2'=>{'feature1'=>-1,'feature2'=>0,'feature3'=>0.5}}, 
							    {    'denominator1'=>{'feature1'=>1.5,'feature2'=>2,'feature3'=>-1}, 
								 'denominator2'=>{'feature1'=>-.5,'feature2'=>0}}),-1,1], 
                get_top_changers=>[$client->compare_samples_vs_default_controls(['kb|sample.3','kb|sample.8','kb|sample.1']),'BOTH',10],
		get_expression_samples_titles=>[['kb|sample.2','kb|sample.3']],
		get_expression_samples_descriptions=>[['kb|sample.2','kb|sample.3']],
		get_expression_samples_molecules=>[['kb|sample.2','kb|sample.3']],
		get_expression_samples_types=>[['kb|sample.2','kb|sample.3']], 
		get_expression_samples_external_source_ids=>[['kb|sample.2','kb|sample.3']],
		get_expression_samples_original_log2_medians=>[['kb|sample.2','kb|sample.3']],
		get_expression_series_titles=>[['kb|series.1','kb|series.0']],
		get_expression_series_summaries=>[['kb|series.1','kb|series.0']],
		get_expression_series_designs=>[['kb|series.1','kb|series.0']], 
		get_expression_series_external_source_ids=>[['kb|series.1','kb|series.0']], 
};
###########################################################################     
my $n_tests = (scalar(keys %$func_calls)+3); # set this to be the number of function calls + 3;   


# LOOP THROUGH ALL THE REMOTE CALLS AND MAKE SURE WE GOT SOMETHING
my $method_name;
for $method_name (keys %$func_calls) {
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
