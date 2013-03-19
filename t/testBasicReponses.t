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
use lib "../lib/Bio/KBase/expressionServices"; 
#use lib "../lib/"; 
#use ExpressionServicesClient;
 
my $client = ExpressionServicesClient->new("http://localhost:9999"); 
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
my $n_tests = (scalar(keys %$func_calls)+3); # set this to be the number of function calls + 3; 

# MAKE SURE WE LOCALLY HAVE JSON RPC LIBS
use_ok("JSON::RPC::Client");
use_ok("Bio::KBase::ExpressionServices::Client");
 
my $client = ExpressionServicesClient->new("http://localhost:9999"); 

#NEW VERSION WITH AUTO START / STOP SERVICE
#use Server;
#my ($pid, $url) = Server::start('ExpressionServices');
#print "-> attempting to connect to:'".$url."' with PID=$pid\n";
#my $client = Bio::KBase::ExpressionServices::Client->new($url);

ok(defined($client),"instantiating tree client");

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

done_testing($n_tests);
