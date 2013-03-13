package Bio::KBase::ExpressionServices::ExpressionServicesImpl;
use strict;
use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org 
our $VERSION = "0.1.0";

=head1 NAME

ExpressionServices

=head1 DESCRIPTION



=cut

#BEGIN_HEADER
#END_HEADER

sub new
{
    my($class, @args) = @_;
    my $self = {
    };
    bless $self, $class;
    #BEGIN_CONSTRUCTOR
    #END_CONSTRUCTOR

    if ($self->can('_init_instance'))
    {
	$self->_init_instance();
    }
    return $self;
}

=head1 METHODS



=head2 get_expression_samples_data

  $expressionDataSamplesMap = $obj->get_expression_samples_data($sampleIds)

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



=item Description

core function used by many others.  Given a list of SampleIds returns mapping of SampleId to SampleDataStructure

=back

=cut

sub get_expression_samples_data
{
    my $self = shift;
    my($sampleIds) = @_;

    my @_bad_arguments;
    (ref($sampleIds) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"sampleIds\" (value was \"$sampleIds\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_data:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($expressionDataSamplesMap);
    #BEGIN get_expression_samples_data
    #END get_expression_samples_data
    my @_bad_returns;
    (ref($expressionDataSamplesMap) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"expressionDataSamplesMap\" (value was \"$expressionDataSamplesMap\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_data:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data');
    }
    return($expressionDataSamplesMap);
}




=head2 get_expression_samples_data_by_series_ids

  $seriesExpressionDataSamplesMapping = $obj->get_expression_samples_data_by_series_ids($seriesIds)

=over 4

=item Parameter and return types

=begin html

<pre>
$seriesIds is a SeriesIDs
$seriesExpressionDataSamplesMapping is a SeriesExpressionDataSamplesMapping
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
SeriesExpressionDataSamplesMapping is a reference to a hash where the key is a SeriesID and the value is an ExpressionDataSamplesMap
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
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
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Log2Level
FeatureID is a string
Log2Level is a float

</pre>

=end html

=begin text

$seriesIds is a SeriesIDs
$seriesExpressionDataSamplesMapping is a SeriesExpressionDataSamplesMapping
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
SeriesExpressionDataSamplesMapping is a reference to a hash where the key is a SeriesID and the value is an ExpressionDataSamplesMap
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
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
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Log2Level
FeatureID is a string
Log2Level is a float


=end text



=item Description

given a list of SeriesIds returns mapping of SeriesId to expressionDataSamples

=back

=cut

sub get_expression_samples_data_by_series_ids
{
    my $self = shift;
    my($seriesIds) = @_;

    my @_bad_arguments;
    (ref($seriesIds) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"seriesIds\" (value was \"$seriesIds\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_data_by_series_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_series_ids');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($seriesExpressionDataSamplesMapping);
    #BEGIN get_expression_samples_data_by_series_ids
    #END get_expression_samples_data_by_series_ids
    my @_bad_returns;
    (ref($seriesExpressionDataSamplesMapping) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"seriesExpressionDataSamplesMapping\" (value was \"$seriesExpressionDataSamplesMapping\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_data_by_series_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_series_ids');
    }
    return($seriesExpressionDataSamplesMapping);
}




=head2 get_expression_samples_data_by_experimental_unit_ids

  $experimentalUnitExpressionDataSamplesMapping = $obj->get_expression_samples_data_by_experimental_unit_ids($experimentalUnitIDs)

=over 4

=item Parameter and return types

=begin html

<pre>
$experimentalUnitIDs is an ExperimentalUnitIDs
$experimentalUnitExpressionDataSamplesMapping is an ExperimentalUnitExpressionDataSamplesMapping
ExperimentalUnitIDs is a reference to a list where each element is an ExperimentalUnitID
ExperimentalUnitID is a string
ExperimentalUnitExpressionDataSamplesMapping is a reference to a hash where the key is an ExperimentalUnitID and the value is an ExpressionDataSamplesMap
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
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

$experimentalUnitIDs is an ExperimentalUnitIDs
$experimentalUnitExpressionDataSamplesMapping is an ExperimentalUnitExpressionDataSamplesMapping
ExperimentalUnitIDs is a reference to a list where each element is an ExperimentalUnitID
ExperimentalUnitID is a string
ExperimentalUnitExpressionDataSamplesMapping is a reference to a hash where the key is an ExperimentalUnitID and the value is an ExpressionDataSamplesMap
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
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



=item Description

given a list of ExperimentalUnitIds returns mapping of ExperimentalUnitId to expressionDataSamples

=back

=cut

sub get_expression_samples_data_by_experimental_unit_ids
{
    my $self = shift;
    my($experimentalUnitIDs) = @_;

    my @_bad_arguments;
    (ref($experimentalUnitIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"experimentalUnitIDs\" (value was \"$experimentalUnitIDs\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_data_by_experimental_unit_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_experimental_unit_ids');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($experimentalUnitExpressionDataSamplesMapping);
    #BEGIN get_expression_samples_data_by_experimental_unit_ids
    #END get_expression_samples_data_by_experimental_unit_ids
    my @_bad_returns;
    (ref($experimentalUnitExpressionDataSamplesMapping) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"experimentalUnitExpressionDataSamplesMapping\" (value was \"$experimentalUnitExpressionDataSamplesMapping\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_data_by_experimental_unit_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_experimental_unit_ids');
    }
    return($experimentalUnitExpressionDataSamplesMapping);
}




=head2 get_expression_experimental_unit_samples_data_by_experiment_meta_ids

  $experimentMetaExpressionDataSamplesMapping = $obj->get_expression_experimental_unit_samples_data_by_experiment_meta_ids($experimentMetaIDs)

=over 4

=item Parameter and return types

=begin html

<pre>
$experimentMetaIDs is an ExperimentMetaIDs
$experimentMetaExpressionDataSamplesMapping is an ExperimentMetaExpressionDataSamplesMapping
ExperimentMetaIDs is a reference to a list where each element is an ExperimentMetaID
ExperimentMetaID is a string
ExperimentMetaExpressionDataSamplesMapping is a reference to a hash where the key is an ExperimentMetaID and the value is an ExperimentalUnitExpressionDataSamplesMapping
ExperimentalUnitExpressionDataSamplesMapping is a reference to a hash where the key is an ExperimentalUnitID and the value is an ExpressionDataSamplesMap
ExperimentalUnitID is a string
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
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

$experimentMetaIDs is an ExperimentMetaIDs
$experimentMetaExpressionDataSamplesMapping is an ExperimentMetaExpressionDataSamplesMapping
ExperimentMetaIDs is a reference to a list where each element is an ExperimentMetaID
ExperimentMetaID is a string
ExperimentMetaExpressionDataSamplesMapping is a reference to a hash where the key is an ExperimentMetaID and the value is an ExperimentalUnitExpressionDataSamplesMapping
ExperimentalUnitExpressionDataSamplesMapping is a reference to a hash where the key is an ExperimentalUnitID and the value is an ExpressionDataSamplesMap
ExperimentalUnitID is a string
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
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



=item Description

given a list of ExperimentMetaIds returns mapping of ExperimentId to experimentalUnitExpressionDataSamplesMapping

=back

=cut

sub get_expression_experimental_unit_samples_data_by_experiment_meta_ids
{
    my $self = shift;
    my($experimentMetaIDs) = @_;

    my @_bad_arguments;
    (ref($experimentMetaIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"experimentMetaIDs\" (value was \"$experimentMetaIDs\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_experimental_unit_samples_data_by_experiment_meta_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_experimental_unit_samples_data_by_experiment_meta_ids');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($experimentMetaExpressionDataSamplesMapping);
    #BEGIN get_expression_experimental_unit_samples_data_by_experiment_meta_ids
    #END get_expression_experimental_unit_samples_data_by_experiment_meta_ids
    my @_bad_returns;
    (ref($experimentMetaExpressionDataSamplesMapping) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"experimentMetaExpressionDataSamplesMapping\" (value was \"$experimentMetaExpressionDataSamplesMapping\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_experimental_unit_samples_data_by_experiment_meta_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_experimental_unit_samples_data_by_experiment_meta_ids');
    }
    return($experimentMetaExpressionDataSamplesMapping);
}




=head2 get_expression_samples_data_by_strain_ids

  $strainExpressionDataSamplesMapping = $obj->get_expression_samples_data_by_strain_ids($strainIDs, $sampleType)

=over 4

=item Parameter and return types

=begin html

<pre>
$strainIDs is a StrainIDs
$sampleType is a SampleType
$strainExpressionDataSamplesMapping is a StrainExpressionDataSamplesMapping
StrainIDs is a reference to a list where each element is a StrainID
StrainID is a string
SampleType is a string
StrainExpressionDataSamplesMapping is a reference to a hash where the key is a StrainID and the value is an ExpressionDataSamplesMap
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
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

$strainIDs is a StrainIDs
$sampleType is a SampleType
$strainExpressionDataSamplesMapping is a StrainExpressionDataSamplesMapping
StrainIDs is a reference to a list where each element is a StrainID
StrainID is a string
SampleType is a string
StrainExpressionDataSamplesMapping is a reference to a hash where the key is a StrainID and the value is an ExpressionDataSamplesMap
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
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



=item Description

given a list of Strains, and a SampleType, it returns a StrainExpressionDataSamplesMapping,  StrainId -> ExpressionDataSample

=back

=cut

sub get_expression_samples_data_by_strain_ids
{
    my $self = shift;
    my($strainIDs, $sampleType) = @_;

    my @_bad_arguments;
    (ref($strainIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"strainIDs\" (value was \"$strainIDs\")");
    (!ref($sampleType)) or push(@_bad_arguments, "Invalid type for argument \"sampleType\" (value was \"$sampleType\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_data_by_strain_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_strain_ids');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($strainExpressionDataSamplesMapping);
    #BEGIN get_expression_samples_data_by_strain_ids
    #END get_expression_samples_data_by_strain_ids
    my @_bad_returns;
    (ref($strainExpressionDataSamplesMapping) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"strainExpressionDataSamplesMapping\" (value was \"$strainExpressionDataSamplesMapping\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_data_by_strain_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_strain_ids');
    }
    return($strainExpressionDataSamplesMapping);
}




=head2 get_expression_samples_data_by_genome_ids

  $genomeExpressionDataSamplesMapping = $obj->get_expression_samples_data_by_genome_ids($genomeIDs, $sampleType, $wildTypeOnly)

=over 4

=item Parameter and return types

=begin html

<pre>
$genomeIDs is a GenomeIDs
$sampleType is a SampleType
$wildTypeOnly is a WildTypeOnly
$genomeExpressionDataSamplesMapping is a GenomeExpressionDataSamplesMapping
GenomeIDs is a reference to a list where each element is a GenomeID
GenomeID is a string
SampleType is a string
WildTypeOnly is an int
GenomeExpressionDataSamplesMapping is a reference to a hash where the key is a GenomeID and the value is a StrainExpressionDataSamplesMapping
StrainExpressionDataSamplesMapping is a reference to a hash where the key is a StrainID and the value is an ExpressionDataSamplesMap
StrainID is a string
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
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

$genomeIDs is a GenomeIDs
$sampleType is a SampleType
$wildTypeOnly is a WildTypeOnly
$genomeExpressionDataSamplesMapping is a GenomeExpressionDataSamplesMapping
GenomeIDs is a reference to a list where each element is a GenomeID
GenomeID is a string
SampleType is a string
WildTypeOnly is an int
GenomeExpressionDataSamplesMapping is a reference to a hash where the key is a GenomeID and the value is a StrainExpressionDataSamplesMapping
StrainExpressionDataSamplesMapping is a reference to a hash where the key is a StrainID and the value is an ExpressionDataSamplesMap
StrainID is a string
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
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



=item Description

given a list of Genomes, a SampleType and a int indicating WildType Only (1 = true, 0 = false) , it returns a GenomeExpressionDataSamplesMapping   ,  Genome -> StrainId -> ExpressionDataSample

=back

=cut

sub get_expression_samples_data_by_genome_ids
{
    my $self = shift;
    my($genomeIDs, $sampleType, $wildTypeOnly) = @_;

    my @_bad_arguments;
    (ref($genomeIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"genomeIDs\" (value was \"$genomeIDs\")");
    (!ref($sampleType)) or push(@_bad_arguments, "Invalid type for argument \"sampleType\" (value was \"$sampleType\")");
    (!ref($wildTypeOnly)) or push(@_bad_arguments, "Invalid type for argument \"wildTypeOnly\" (value was \"$wildTypeOnly\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_data_by_genome_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_genome_ids');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($genomeExpressionDataSamplesMapping);
    #BEGIN get_expression_samples_data_by_genome_ids
    #END get_expression_samples_data_by_genome_ids
    my @_bad_returns;
    (ref($genomeExpressionDataSamplesMapping) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"genomeExpressionDataSamplesMapping\" (value was \"$genomeExpressionDataSamplesMapping\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_data_by_genome_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_genome_ids');
    }
    return($genomeExpressionDataSamplesMapping);
}




=head2 get_expression_data_by_feature_ids

  $featureSampleLog2LevelMapping = $obj->get_expression_data_by_feature_ids($featureIds, $sampleType, $wildTypeOnly)

=over 4

=item Parameter and return types

=begin html

<pre>
$featureIds is a FeatureIDs
$sampleType is a SampleType
$wildTypeOnly is a WildTypeOnly
$featureSampleLog2LevelMapping is a FeatureSampleLog2LevelMapping
FeatureIDs is a reference to a list where each element is a FeatureID
FeatureID is a string
SampleType is a string
WildTypeOnly is an int
FeatureSampleLog2LevelMapping is a reference to a hash where the key is a FeatureID and the value is a SampleLog2LevelMapping
SampleLog2LevelMapping is a reference to a hash where the key is a SampleID and the value is a Log2Level
SampleID is a string
Log2Level is a float

</pre>

=end html

=begin text

$featureIds is a FeatureIDs
$sampleType is a SampleType
$wildTypeOnly is a WildTypeOnly
$featureSampleLog2LevelMapping is a FeatureSampleLog2LevelMapping
FeatureIDs is a reference to a list where each element is a FeatureID
FeatureID is a string
SampleType is a string
WildTypeOnly is an int
FeatureSampleLog2LevelMapping is a reference to a hash where the key is a FeatureID and the value is a SampleLog2LevelMapping
SampleLog2LevelMapping is a reference to a hash where the key is a SampleID and the value is a Log2Level
SampleID is a string
Log2Level is a float


=end text



=item Description

given a list of FeatureIds, a SampleType and a int indicating WildType Only (1 = true, 0 = false) returns a FeatureSampleLog2LevelMapping : featureId->{sample_id->log2Level}

=back

=cut

sub get_expression_data_by_feature_ids
{
    my $self = shift;
    my($featureIds, $sampleType, $wildTypeOnly) = @_;

    my @_bad_arguments;
    (ref($featureIds) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"featureIds\" (value was \"$featureIds\")");
    (!ref($sampleType)) or push(@_bad_arguments, "Invalid type for argument \"sampleType\" (value was \"$sampleType\")");
    (!ref($wildTypeOnly)) or push(@_bad_arguments, "Invalid type for argument \"wildTypeOnly\" (value was \"$wildTypeOnly\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_data_by_feature_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_data_by_feature_ids');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($featureSampleLog2LevelMapping);
    #BEGIN get_expression_data_by_feature_ids
    #END get_expression_data_by_feature_ids
    my @_bad_returns;
    (ref($featureSampleLog2LevelMapping) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"featureSampleLog2LevelMapping\" (value was \"$featureSampleLog2LevelMapping\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_data_by_feature_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_data_by_feature_ids');
    }
    return($featureSampleLog2LevelMapping);
}




=head2 version 

  $return = $obj->version()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a string
</pre>

=end html

=begin text

$return is a string

=end text

=item Description

Return the module version. This is a Semantic Versioning number.

=back

=cut

sub version {
    return $VERSION;
}

=head1 TYPES



=head2 FeatureID

=over 4



=item Description

KBase Feature ID for a feature, typically CDS/PEG


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 FeatureIDs

=over 4



=item Description

KBase list of Feature IDs , typically CDS/PEG


=item Definition

=begin html

<pre>
a reference to a list where each element is a FeatureID
</pre>

=end html

=begin text

a reference to a list where each element is a FeatureID

=end text

=back



=head2 Log2Level

=over 4



=item Description

Log2Level (Zero median normalized within a sample) for a given feature


=item Definition

=begin html

<pre>
a float
</pre>

=end html

=begin text

a float

=end text

=back



=head2 SampleID

=over 4



=item Description

KBase Sample ID for the sample


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 SampleIDs

=over 4



=item Description

List of KBase Sample IDs


=item Definition

=begin html

<pre>
a reference to a list where each element is a SampleID
</pre>

=end html

=begin text

a reference to a list where each element is a SampleID

=end text

=back



=head2 SampleType

=over 4



=item Description

Sample type controlled vocabulary : microarray, RNA-Seq, qPCR, or proteomics


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 SeriesID

=over 4



=item Description

Kbase Series Id


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 SeriesIDs

=over 4



=item Description

list of KBase Series Ids


=item Definition

=begin html

<pre>
a reference to a list where each element is a SeriesID
</pre>

=end html

=begin text

a reference to a list where each element is a SeriesID

=end text

=back



=head2 ExperimentMetaID

=over 4



=item Description

Kbase ExperimentMeta Id


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 ExperimentMetaIDs

=over 4



=item Description

list of KBase ExperimentMeta Ids


=item Definition

=begin html

<pre>
a reference to a list where each element is an ExperimentMetaID
</pre>

=end html

=begin text

a reference to a list where each element is an ExperimentMetaID

=end text

=back



=head2 ExperimentalUnitID

=over 4



=item Description

Kbase ExperimentalUnitId


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 ExperimentalUnitIDs

=over 4



=item Description

list of KBase ExperimentUnitIds


=item Definition

=begin html

<pre>
a reference to a list where each element is an ExperimentalUnitID
</pre>

=end html

=begin text

a reference to a list where each element is an ExperimentalUnitID

=end text

=back



=head2 DataExpressionLevelsForSample

=over 4



=item Description

mapping kbase feature id as the key and log2level as the value


=item Definition

=begin html

<pre>
a reference to a hash where the key is a FeatureID and the value is a Log2Level
</pre>

=end html

=begin text

a reference to a hash where the key is a FeatureID and the value is a Log2Level

=end text

=back



=head2 SampleAnnotationID

=over 4



=item Description

Kbase SampleAnnotation Id


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 SampleAnnotationIDs

=over 4



=item Description

list of KBase SampleAnnotation Ids


=item Definition

=begin html

<pre>
a reference to a list where each element is a SampleAnnotationID
</pre>

=end html

=begin text

a reference to a list where each element is a SampleAnnotationID

=end text

=back



=head2 PersonID

=over 4



=item Description

Kbase Person Id


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 PersonIDs

=over 4



=item Description

list of KBase PersonsIds


=item Definition

=begin html

<pre>
a reference to a list where each element is a PersonID
</pre>

=end html

=begin text

a reference to a list where each element is a PersonID

=end text

=back



=head2 StrainID

=over 4



=item Description

KBase StrainId


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 StrainIDs

=over 4



=item Description

list of KBase StrainIds


=item Definition

=begin html

<pre>
a reference to a list where each element is a StrainID
</pre>

=end html

=begin text

a reference to a list where each element is a StrainID

=end text

=back



=head2 GenomeID

=over 4



=item Description

KBase GenomeId


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 GenomeIDs

=over 4



=item Description

list of KBase GenomeIds


=item Definition

=begin html

<pre>
a reference to a list where each element is a GenomeID
</pre>

=end html

=begin text

a reference to a list where each element is a GenomeID

=end text

=back



=head2 WildTypeOnly

=over 4



=item Description

Single integer 1= WildTypeonly, 0 means all strains ok


=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 ExpressionDataSample

=over 4



=item Description

Data structure for all the top level metadata and value data for an expression sample


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
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

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
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


=end text

=back



=head2 ExpressionDataSamplesMap

=over 4



=item Description

Mapping between sampleId and ExpressionDataSample


=item Definition

=begin html

<pre>
a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
</pre>

=end html

=begin text

a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample

=end text

=back



=head2 SeriesExpressionDataSamplesMapping

=over 4



=item Description

mapping between seriesIds and all Samples it contains


=item Definition

=begin html

<pre>
a reference to a hash where the key is a SeriesID and the value is an ExpressionDataSamplesMap
</pre>

=end html

=begin text

a reference to a hash where the key is a SeriesID and the value is an ExpressionDataSamplesMap

=end text

=back



=head2 ExperimentalUnitExpressionDataSamplesMapping

=over 4



=item Description

mapping between experimentalUnitIds and all Samples it contains


=item Definition

=begin html

<pre>
a reference to a hash where the key is an ExperimentalUnitID and the value is an ExpressionDataSamplesMap
</pre>

=end html

=begin text

a reference to a hash where the key is an ExperimentalUnitID and the value is an ExpressionDataSamplesMap

=end text

=back



=head2 ExperimentMetaExpressionDataSamplesMapping

=over 4



=item Description

mapping between experimentMetaIds and ExperimentalUnitExpressionDataSamplesMapping it contains


=item Definition

=begin html

<pre>
a reference to a hash where the key is an ExperimentMetaID and the value is an ExperimentalUnitExpressionDataSamplesMapping
</pre>

=end html

=begin text

a reference to a hash where the key is an ExperimentMetaID and the value is an ExperimentalUnitExpressionDataSamplesMapping

=end text

=back



=head2 StrainExpressionDataSamplesMapping

=over 4



=item Description

mapping between strainIds and all Samples it contains


=item Definition

=begin html

<pre>
a reference to a hash where the key is a StrainID and the value is an ExpressionDataSamplesMap
</pre>

=end html

=begin text

a reference to a hash where the key is a StrainID and the value is an ExpressionDataSamplesMap

=end text

=back



=head2 GenomeExpressionDataSamplesMapping

=over 4



=item Description

mapping between genomeIds and all StrainExpressionDataSamplesMapping it contains


=item Definition

=begin html

<pre>
a reference to a hash where the key is a GenomeID and the value is a StrainExpressionDataSamplesMapping
</pre>

=end html

=begin text

a reference to a hash where the key is a GenomeID and the value is a StrainExpressionDataSamplesMapping

=end text

=back



=head2 SampleLog2LevelMapping

=over 4



=item Description

mapping kbase sample id as the key and a single log2level (for a scpecified feature id, one mapping higher) as the value


=item Definition

=begin html

<pre>
a reference to a hash where the key is a SampleID and the value is a Log2Level
</pre>

=end html

=begin text

a reference to a hash where the key is a SampleID and the value is a Log2Level

=end text

=back



=head2 FeatureSampleLog2LevelMapping

=over 4



=item Description

mapping between FeatureIds and the mappings between samples and log2level mapping


=item Definition

=begin html

<pre>
a reference to a hash where the key is a FeatureID and the value is a SampleLog2LevelMapping
</pre>

=end html

=begin text

a reference to a hash where the key is a FeatureID and the value is a SampleLog2LevelMapping

=end text

=back



=cut

1;
