use strict;
use Data::Dumper;
use Carp;

#
# This is a SAS Component
#

=head1 get_expression_samples_data

Example:

    get_expression_samples_data [arguments] < input > output

The standard input should be a tab-separated table (i.e., each line
is a tab-separated set of fields).  Normally, the last field in each
line would contain the identifer. If another column contains the identifier
use

    -c N

where N is the column (from 1) that contains the identifier.

This is a pipe command. The input is taken from the standard input, and the
output is to the standard output.

=head2 Documentation for underlying call

This script is a wrapper for the CDMI-API call get_expression_samples_data. It is documented as follows:

core function used by many others.  Given a list of SampleIds returns mapping of SampleId to SampleDataStructure

=over 4

=item Parameter and return types

=begin html

<pre>
$sampleIds is a SampleIDs
$expressionDataSamplesMap is an ExpressionDataSamplesMap
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleId has a value which is a SampleID
	sourceId has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceId has a value which is a string
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
	platformId has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentId has a value which is a string
	environmentDescription has a value which is a string
	protocolId has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotationIDs has a value which is a SampleAnnotationIDs
	seriesIds has a value which is a SeriesIDs
	personIds has a value which is a PersonIDs
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
SampleType is a string
StrainID is a string
GenomeID is a string
ExperimentalUnitID is a string
ExperimentMetaID is a string
SampleAnnotationIDs is a reference to a list where each element is a SampleAnnotationID
SampleAnnotationID is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Log2Level
FeatureID is a string
Log2Level is a float

</pre>

=end html

=begin text

$sampleIds is a SampleIDs
$expressionDataSamplesMap is an ExpressionDataSamplesMap
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleId has a value which is a SampleID
	sourceId has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceId has a value which is a string
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
	platformId has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentId has a value which is a string
	environmentDescription has a value which is a string
	protocolId has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotationIDs has a value which is a SampleAnnotationIDs
	seriesIds has a value which is a SeriesIDs
	personIds has a value which is a PersonIDs
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
SampleType is a string
StrainID is a string
GenomeID is a string
ExperimentalUnitID is a string
ExperimentMetaID is a string
SampleAnnotationIDs is a reference to a list where each element is a SampleAnnotationID
SampleAnnotationID is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Log2Level
FeatureID is a string
Log2Level is a float


=end text

=back

=head2 Command-Line Options

=over 4

=item -c Column

This is used only if the column containing the identifier is not the last column.

=item -i InputFile    [ use InputFile, rather than stdin ]

=back

=head2 Output Format

The standard output is a tab-delimited file. It consists of the input
file with extra columns added.

Input lines that cannot be extended are written to stderr.

=cut

use SeedUtils;

my $usage = "usage: get_expression_samples_data [-c column] < input > output";

use Bio::KBase::CDMI::CDMIClient;
use Bio::KBase::Utilities::ScriptThing;

my $column;

my $input_file;

my $kbO = Bio::KBase::CDMI::CDMIClient->new_for_script('c=i' => \$column,
				      'i=s' => \$input_file);
if (! $kbO) { print STDERR $usage; exit }

my $ih;
if ($input_file)
{
    open $ih, "<", $input_file or die "Cannot open input file $input_file: $!";
}
else
{
    $ih = \*STDIN;
}

while (my @tuples = Bio::KBase::Utilities::ScriptThing::GetBatch($ih, undef, $column)) {
    my @h = map { $_->[0] } @tuples;
    my $h = $kbO->get_expression_samples_data(\@h);
    for my $tuple (@tuples) {
        #
        # Process output here and print.
        #
        my ($id, $line) = @$tuple;
        my $v = $h->{$id};

        if (! defined($v))
        {
            print STDERR $line,"\n";
        }
        elsif (ref($v) eq 'ARRAY')
        {
            foreach $_ (@$v)
            {
                print "$line\t$_\n";
            }
        }
        else
        {
            print "$line\t$v\n";
        }
    }
}
