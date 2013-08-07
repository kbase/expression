use strict;
use Data::Dumper;
use Test::More;
use Bio::KBase::ExpressionServices::ExpressionServicesClient;

my $client = Bio::KBase::ExpressionServices::ExpressionServicesClient->new("http://localhost:7075");
my $n_tests = 0;

# retrieve sample ids for Shewanella
my $result = $client->get_expression_sample_ids_by_genome_ids(['kb|g.20848'], 'microarray', 0);
ok(defined($result), 'Got a result back for Shewanella samples');
$n_tests++;
ok(@$result > 0, 'Shewanella samples non-empty');
$n_tests++;
# get all the sample data back so we can search it
$result = $client->get_expression_samples_data($result);
ok(defined($result), 'Got a result back for sample data');
$n_tests++;
# get two samples that represent different growth media
my ($acetate, $lactate);

foreach my $sampleid (keys %$result) {
    if ($result->{$sampleid}->{'externalSourceID'} eq 'GSM969611') {
	$acetate = $sampleid;
    }
    elsif ($result->{$sampleid}->{'externalSourceID'} eq 'GSM969612') {
	$lactate = $sampleid;
    }
}
ok(defined($acetate), "Found GSM969611: $acetate");
$n_tests++;
ok(defined($lactate), "Found GSM969612: $lactate");
$n_tests++;
# test getting specific expression values
my $levels = $client->get_expression_data_by_samples_and_features([$acetate, $lactate],
								  ['kb|g.20848.CDS.807','kb|g.20848.CDS.2504']);
ok(defined($levels), "Got levels for lactate permease and acetate kinase");
$n_tests++;
# do a differential analysis
my $comparison = $client->compare_samples({ $acetate => $result->{$acetate}->{'dataExpressionLevelsForSample'} },
					  {  $lactate => $result->{$lactate}->{'dataExpressionLevelsForSample'} });
ok(defined($comparison),'comparison of samples is defined');
$n_tests++;
# determine genes turned on and off from the first condition to the second
my $on_off = $client->get_on_off_calls($comparison, 0, 0);
ok(defined($on_off),'on-off comparison is defined');
$n_tests++;
# verify that lactate permease is turned on
ok($on_off->{$acetate}->{$lactate}->{'kb|g.20848.CDS.807'} == 1, 'lactate permease is turned on');
$n_tests++;
# verify that acetate kinase is turned off
ok($on_off->{$acetate}->{$lactate}->{'kb|g.20848.CDS.2504'} == -1, 'acetate kinase is turned off');
$n_tests++;
# find the top changers
my $changers = $client->get_top_changers($comparison, "both", 100);
ok(defined($changers),'changers is defined');
$n_tests++;
my $found = 0;
foreach my $cds (keys %{$changers->{$acetate}->{$lactate}}) {
    if ($cds eq 'kb|g.20848.CDS.2504') {
	$found = 1;
	last;
    }
}
ok($found == 1, 'acetate kinase is one of the top changers');
$n_tests++;

done_testing($n_tests);
