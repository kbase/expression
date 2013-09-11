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
use DBI;
use Storable qw(dclone);
use Config::Simple;
use Data::Dumper; 
use IO::Uncompress::Gunzip qw(gunzip $GunzipError) ;
use IO::File; 
use LWP::Simple; 
use Bio::DB::Taxonomy;
use Bio::KBase;
use Bio::KBase::CDMI::CDMIClient; 
use Bio::KBase::ExpressionServices::FunctionsForGEO;

sub trim($)
{
    #removes beginning and trailing white space
    my $string = shift;
    if (defined($string))
    {
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
    }
    return $string;
}
#END_HEADER

sub new
{
    my($class, @args) = @_;
    my $self = {
    };
    bless $self, $class;
    #BEGIN_CONSTRUCTOR
#foreach my $key (keys %ENV) { 
#print "$key = $ENV{$key}\n"; 
#} 
    #Copied from M. Sneddon's TreeImpl.pm from trees.git f63b672dc14f4600329424bc6b404b507e9c2503   
    my($deploy) = @args; 
#print "\nARGS : ".join("___",@args). "\n";
    if (! $deploy) { 
#print "\nIN DEPLOY IF \n";
        # if not, then go to the config file defined by the deployment and import                                                      
        # the deployment settings   
	my %params; 
#print "DEPLOYMENT_CONFIG ". $ENV{KB_DEPLOYMENT_CONFIG} . "\n";
        if (my $e = $ENV{KB_DEPLOYMENT_CONFIG}) { 
#print "IN CONFIG IF\n"; 
#print "CONFIG FILE $e \n\n";
            my $EXPRESSION_SERVICE_NAME = $ENV{KB_SERVICE_NAME}; 
            my $c = Config::Simple->new(); 
            $c->read($e); 
#print "CONFIG FILE C: $c \n\n";
	    my %temp_hash = $c->vars();
#foreach my $c_key (keys(%temp_hash))
#{
#print "CKEY: $c_key : Val $temp_hash{$c_key} \n";
#}
            my @param_list = qw(dbName dbUser dbhost); 
#print "PAram list : ".join(":",@param_list)."\n";
            for my $p (@param_list) 
            { 
#print "$EXPRESSION_SERVICE_NAME.$p \n\n";
                my $v = $c->param("$EXPRESSION_SERVICE_NAME.$p"); 
#print "IN LOOP P: $p v $v \n";
                if ($v) 
                { 
#print "IN V IF\n"; 
                    $params{$p} = $v; 
                    $self->{$p} = $v; 
                } 
            } 
        } 
        else 
        { 
            $self->{dbName} = 'expression'; 
            $self->{dbUser} = 'expressionselect'; 
            $self->{dbhost} = 'db1.chicago.kbase.us'; 
#print "IN CONFIG ELSE\n"; 
        } 
        #Create a connection to the EXPRESSION (and print a logging debug mssg)              
	if( 0 < scalar keys(%params) ) { 
            warn "Connection to Expression Service established with the following non-default parameters:\n"; 
            foreach my $key (sort keys %params) { warn "   $key => $params{$key} \n"; } 
        } else { warn "Connection to Expression established with all default parameters.\n"; } 
#print "IN IF\n"; 
    } 
    else 
    { 
#        $self->{dbName} = 'CS_expression'; 
#        $self->{dbUser} = 'expressionSelect'; 
#        $self->{dbhost} = 'localhost'; 
         $self->{dbName} = 'expression'; 
         $self->{dbUser} = 'expressionselect';
         $self->{dbhost} = 'db1.chicago.kbase.us'; 
#print "IN ELSE\n"; 
    } 
#print "\nDBNAME : ".  $self->{dbName}; 
#print "\nDBUSER : ".  $self->{dbUser}; 
#print "\nDBHOST : ".  $self->{dbhost} . "\n"; 
    #END_CONSTRUCTOR

    if ($self->can('_init_instance'))
    {
	$self->_init_instance();
    }
    return $self;
}

=head1 METHODS



=head2 get_expression_samples_data

  $expressionDataSamplesMap = $obj->get_expression_samples_data($sampleIDs)

=over 4

=item Parameter and return types

=begin html

<pre>
$sampleIDs is a SampleIDs
$expressionDataSamplesMap is an ExpressionDataSamplesMap
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleID has a value which is a SampleID
	sourceID has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceID has a value which is a string
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
	platformID has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentID has a value which is a string
	environmentDescription has a value which is a string
	protocolID has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotations has a value which is a SampleAnnotations
	seriesIDs has a value which is a SeriesIDs
	personIDs has a value which is a PersonIDs
	sampleIDsAveragedFrom has a value which is a SampleIDsAveragedFrom
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
SampleType is a string
StrainID is a string
GenomeID is a string
ExperimentalUnitID is a string
ExperimentMetaID is a string
SampleAnnotations is a reference to a list where each element is a SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sampleAnnotationID has a value which is a SampleAnnotationID
	ontologyID has a value which is an OntologyID
	ontologyName has a value which is an OntologyName
	ontologyDefinition has a value which is an OntologyDefinition
SampleAnnotationID is a string
OntologyID is a string
OntologyName is a string
OntologyDefinition is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
SampleIDsAveragedFrom is a reference to a list where each element is a SampleID
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Measurement
FeatureID is a string
Measurement is a float

</pre>

=end html

=begin text

$sampleIDs is a SampleIDs
$expressionDataSamplesMap is an ExpressionDataSamplesMap
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleID has a value which is a SampleID
	sourceID has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceID has a value which is a string
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
	platformID has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentID has a value which is a string
	environmentDescription has a value which is a string
	protocolID has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotations has a value which is a SampleAnnotations
	seriesIDs has a value which is a SeriesIDs
	personIDs has a value which is a PersonIDs
	sampleIDsAveragedFrom has a value which is a SampleIDsAveragedFrom
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
SampleType is a string
StrainID is a string
GenomeID is a string
ExperimentalUnitID is a string
ExperimentMetaID is a string
SampleAnnotations is a reference to a list where each element is a SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sampleAnnotationID has a value which is a SampleAnnotationID
	ontologyID has a value which is an OntologyID
	ontologyName has a value which is an OntologyName
	ontologyDefinition has a value which is an OntologyDefinition
SampleAnnotationID is a string
OntologyID is a string
OntologyName is a string
OntologyDefinition is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
SampleIDsAveragedFrom is a reference to a list where each element is a SampleID
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Measurement
FeatureID is a string
Measurement is a float


=end text



=item Description

core function used by many others.  Given a list of KBase SampleIds returns mapping of SampleId to expressionSampleDataStructure (essentially the core Expression Sample Object) : 
{sample_id -> expressionSampleDataStructure}

=back

=cut

sub get_expression_samples_data
{
    my $self = shift;
    my($sampleIDs) = @_;

    my @_bad_arguments;
    (ref($sampleIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"sampleIDs\" (value was \"$sampleIDs\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_data:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($expressionDataSamplesMap);
    #BEGIN get_expression_samples_data
    $expressionDataSamplesMap = {};
    if (0 == @{$sampleIDs}) 
    { 
        my $msg = "get_expression_samples_data requires a list of valid sample ids. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'get_expression_samples_data'); 
    } 
#    if (0 == @{$sampleIDs})
#    {
#	return $expressionDataSamplesMap;
#    }

#    my $dbh = DBI->connect('DBI:mysql:CS_expression:localhost', 'expressionSelect', '', 
#                           { RaiseError => 1, ShowErrorStatement => 1 } 
#        ); 

    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '',
			   { RaiseError => 1, ShowErrorStatement => 1 } 
    ); 
    my $get_sample_meta_data_q = qq^select sam.id, sam.source_id, sam.title as sample_title, sam.description as sample_description,  
                                    sam.molecule, sam.type, sam.dataSource, sam.externalSourceId, 
                                    FROM_UNIXTIME(sam.kbaseSubmissionDate), FROM_UNIXTIME(sam.externalSourceDate),  
                                    sam.custom, sam.originalLog2Median, 
                                    str.id, str.referenceStrain, str.wildtype, str.description,  
                                    gen.id, gen.scientific_name, 
                                    plt.id, plt.title as platform_title, plt.technology, eu.id,  
                                    em.id, em.title as experiment_title, em.description as experiment_description, 
                                    env.id, env.description as env_description, 
                                    pro.id, pro.description, pro.name 
                                    from Sample sam  
                                    inner join StrainWithSample sws on sam.id = sws.to_link 
                                    inner join Strain str on sws.from_link = str.id 
                                    inner join GenomeParentOf gpo on str.id = gpo.to_link 
                                    inner join kbase_sapling_v1.Genome gen on gpo.from_link = gen.id 
                                    left outer join PlatformWithSamples pws on sam.id = pws.to_link 
                                    left outer join Platform plt on pws.from_link = plt.id 
                                    left outer join HasExpressionSample hes on sam.id = hes.to_link 
                                    left outer join ExperimentalUnit eu on hes.from_link = eu.id 
                                    left outer join HasExperimentalUnit heu on eu.id = heu.to_link 
                                    left outer join ExperimentMeta em on heu.from_link = em.id 
                                    left outer join IsContextOf ico on eu.id = ico.to_link 
                                    left outer join Environment env on ico.from_link = env.id 
                                    left outer join ProtocolForSample pfs on sam.id = pfs.to_link 
                                    left outer join Protocol pro on pfs.from_link = pro.id 
                                    where sam.id in ( ^. 
				 join(",", ("?") x @{$sampleIDs}) . ") "; 
    my $get_sample_meta_data_qh = $dbh->prepare($get_sample_meta_data_q) or die "Unable to prepare : get_sample_meta_data_q : ".
	                          $get_sample_meta_data_q . " : " .$dbh->errstr();
    $get_sample_meta_data_qh->execute(@{$sampleIDs}) or die "Unable to execute : get_sample_meta_data_q : ".$get_sample_meta_data_qh->errstr();
    while(my ($sample_id, $sample_source_id, $sample_title, $sample_description, $sample_molecule, $sample_type, 
              $sample_dataSource, $sample_externalSourceId, $sample_kbaseSubmissionDate, $sample_externalSourceDate,
              $sample_custom, $sample_originalLog2Median, $strain_id, $referenceStrain, $wildtype, $strain_description, 
	      $genome_id, $scientific_name, $platform_id, $platform_title, $platform_technology, $experimental_unit_id, 
              $experiment_meta_id, $experiment_meta_title, $experiment_meta_description, $environment_id, $environment_description,
              $protocol_id, $protocol_description, $protocol_name) = $get_sample_meta_data_qh->fetchrow_array())
    {
	$expressionDataSamplesMap->{$sample_id}={"sampleID" => $sample_id,
						 "sourceID" => $sample_source_id,
						 "sampleTitle" => $sample_title,
						 "sampleDescription" => $sample_description,
						 "molecule" => $sample_molecule,
						 "sampleType" => $sample_type,
						 "dataSource" => $sample_dataSource,
						 "externalSourceID" => $sample_externalSourceId,
						 "externalSourceDate" => $sample_externalSourceDate,
						 "kbaseSubmissionDate" => $sample_kbaseSubmissionDate,
						 "custom" => $sample_custom,
						 "originalLog2Median" => $sample_originalLog2Median,
						 "strainID" => $strain_id,
						 "referenceStrain" => $referenceStrain,
						 "wildtype" => $wildtype,
						 "strainDescription" => $strain_description,
						 "genomeID" => $genome_id,
						 "genomeScientificName" => $scientific_name,
						 "platformID" => $platform_id,
						 "platformTitle" => $platform_title,
						 "platformTechnology" => $platform_technology,
						 "experimentalUnitID" => $experimental_unit_id,
						 "experimentMetaID" => $experiment_meta_id,
						 "experimentTitle" => $experiment_meta_title,
						 "experimentDescription" => $experiment_meta_description,
						 "environmentID" => $environment_id,
						 "environmentDescription" => $environment_description,
						 "protocolID" => $protocol_id,
						 "protocolDescription" => $protocol_description,
						 "protocolName" => $protocol_name,
						 "sampleAnnotationIDs" => [],
						 "seriesIDs" => [],
						 "sampleIDsAveragedFrom" => [],
						 "personIDs" => [],
						 "dataExpressionLevelsForSample" => {}};
    }

    #Sample Annotations
    my $get_sample_annotations_q = qq^select sam.id, san.id, ont.id, ont.name, ont.definition  
                                      from Sample sam  
                                      inner join SampleHasAnnotations sha on sam.id = sha.from_link 
                                      inner join SampleAnnotation san on sha.to_link = san.id 
                                      inner join OntologyForSample ofs on ofs.to_link = san.id 
                                      inner join Ontology ont on ont.id = ofs.from_link 
                                      where sam.id in (^.
                                  join(",", ("?") x @{$sampleIDs}) . ") "; 
    my $get_sample_annotations_qh = $dbh->prepare($get_sample_annotations_q) or die "Unable to prepare get_sample_annotations_q : ".
	$get_sample_annotations_q . " : " . $dbh->errstr();
    $get_sample_annotations_qh->execute(@{$sampleIDs}) or die "Unable to execute get_sample_annotations_q : ".$get_sample_annotations_q.
                                    " : " .$get_sample_annotations_qh->errstr();
    while (my ($sample_id,$sample_annotation_id, $ontology_id, $ontology_name, $ontology_definition) 
	   = $get_sample_annotations_qh->fetchrow_array()) 
    { 
	my %temp_hash;
	$temp_hash{"sampleAnnotationID"} = $sample_annotation_id;
	$temp_hash{"ontologyID"} = $ontology_id;
	$temp_hash{"ontologyName"} = $ontology_name;
	if (($ontology_definition eq '' )||(defined($ontology_definition)))
	{
	    $temp_hash{"ontologyDefinition"} = $ontology_definition;
	}
        push(@{$expressionDataSamplesMap->{$sample_id}->{"sampleAnnotationIDs"}},\%temp_hash);
    }        

    #SeriesIds
    my $get_sample_series_ids_q = qq^select sam.id, ser.id
                                     from Sample sam
                                     inner join SampleInSeries sis on sam.id = sis.from_link
                                     inner join Series ser on sis.to_link = ser.id
                                     where sam.id in (^.
                                  join(",", ("?") x @{$sampleIDs}) . ") "; 
    my $get_sample_series_ids_qh = $dbh->prepare($get_sample_series_ids_q) or die "Unable to prepare : get_sample_series_ids_q : ".
	$get_sample_series_ids_q . " : " .$dbh->errstr();
    $get_sample_series_ids_qh->execute(@{$sampleIDs}) or die "Unable to execute : get_sample_series_ids_q : ".$get_sample_series_ids_qh->errstr();
    while (my ($sample_id,$series_id) = $get_sample_series_ids_qh->fetchrow_array())
    {
          push(@{$expressionDataSamplesMap->{$sample_id}->{"seriesIDs"}},$series_id);
    }

    #SampleIDsAveragedFrom
    my $get_sample_ids_averaged_from_q = qq^select saf.from_link, saf.to_link
                                            from SampleAveragedFrom saf
                                            where saf.to_link in (^. 
                                         join(",", ("?") x @{$sampleIDs}) . ") "; 
    my $get_sample_ids_averaged_from_qh = $dbh->prepare($get_sample_ids_averaged_from_q) or die "Unable to prepare : get_sample_ids_averaged_from_q : ". 
        $get_sample_ids_averaged_from_q . " : " .$dbh->errstr(); 
    $get_sample_ids_averaged_from_qh->execute(@{$sampleIDs}) or die "Unable to execute : get_sample_ids_averaged_from_q : ".$get_sample_ids_averaged_from_qh->errstr(); 
    while (my ($averaged_from_sample_id, $averaged_to_sample_id) = $get_sample_ids_averaged_from_qh->fetchrow_array()) 
    { 
          push(@{$expressionDataSamplesMap->{$averaged_to_sample_id}->{"sampleIDsAveragedFrom"}},$averaged_from_sample_id); 
    } 
    
    #PersonIds     
    my $get_sample_person_ids_q = qq^select sam.id, per.id 
                                     from Sample sam 
                                     inner join SampleContactPerson scp on sam.id = scp.from_link 
                                     inner join Person per on scp.to_link = per.id 
                                     where sam.id in (^.
                                  join(",", ("?") x @{$sampleIDs}) . ") ";
    my $get_sample_person_ids_qh = $dbh->prepare($get_sample_person_ids_q) or die "Unable to prepare : get_sample_person_ids_q : ".           
                                   $get_sample_person_ids_q . " : " .$dbh->errstr();        
    $get_sample_person_ids_qh->execute(@{$sampleIDs}) or die "Unable to execute : get_sample_person_ids_q : ".$get_sample_person_ids_qh->errstr();  
    while (my ($sample_id,$person_id) = $get_sample_person_ids_qh->fetchrow_array())
    {
        push(@{$expressionDataSamplesMap->{$sample_id}->{"personIDs"}},$person_id);
    }

    #log2Levels
    my $get_log2levels_q = qq^select sam.id, fea.id, mea.value
                              from Sample sam
                              inner join SampleMeasurements sme on sam.id = sme.from_link
                              inner join Measurement mea on sme.to_link = mea.id
                              inner join FeatureMeasuredBy fmb on mea.id = fmb.to_link
                              inner join kbase_sapling_v1.Feature fea on fmb.from_link = fea.id
                              where sam.id in (^. 
                           join(",", ("?") x @{$sampleIDs}) . ") ";  
    my $get_log2levels_qh = $dbh->prepare($get_log2levels_q) or die "Unable to prepare get_log2levels_q : ".
                            $get_log2levels_q . " : " . $dbh->errstr();
    $get_log2levels_qh->execute(@{$sampleIDs}) or die "Unable to execute get_log2levels_q : " . $get_log2levels_q . " : ".
                            $get_log2levels_qh->errstr();
    while(my ($sample_id, $feature_id, $log2level) = $get_log2levels_qh->fetchrow_array())
    {
        $expressionDataSamplesMap->{$sample_id}->{"dataExpressionLevelsForSample"}->{$feature_id} = $log2level;
    }
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




=head2 get_expression_data_by_samples_and_features

  $labelDataMapping = $obj->get_expression_data_by_samples_and_features($sampleIDs, $featureIDs)

=over 4

=item Parameter and return types

=begin html

<pre>
$sampleIDs is a SampleIDs
$featureIDs is a FeatureIDs
$labelDataMapping is a LabelDataMapping
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string
FeatureIDs is a reference to a list where each element is a FeatureID
FeatureID is a string
LabelDataMapping is a reference to a hash where the key is a string and the value is a DataExpressionLevelsForSample
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Measurement
Measurement is a float

</pre>

=end html

=begin text

$sampleIDs is a SampleIDs
$featureIDs is a FeatureIDs
$labelDataMapping is a LabelDataMapping
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string
FeatureIDs is a reference to a list where each element is a FeatureID
FeatureID is a string
LabelDataMapping is a reference to a hash where the key is a string and the value is a DataExpressionLevelsForSample
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Measurement
Measurement is a float


=end text



=item Description

given a list of sample ids and feature ids it returns a LabelDataMapping {sampleID}->{featureId => value}}.  
If feature list is an empty array [], all features with measurment values will be returned.

=back

=cut

sub get_expression_data_by_samples_and_features
{
    my $self = shift;
    my($sampleIDs, $featureIDs) = @_;

    my @_bad_arguments;
    (ref($sampleIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"sampleIDs\" (value was \"$sampleIDs\")");
    (ref($featureIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"featureIDs\" (value was \"$featureIDs\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_data_by_samples_and_features:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_data_by_samples_and_features');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($labelDataMapping);
    #BEGIN get_expression_data_by_samples_and_features
    $labelDataMapping = {};
    if (0 == @{$sampleIDs}) 
    { 
	my $msg = "get_expression_data_by_samples_and_features requires a list of valid sample ids.  Note that feature ids can be empty.  ".
	    "If features are empty all features for the sample will be returned";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
							       method_name => 'get_expression_data_by_samples_and_features'); 
    } 
 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 } 
	); 

    my $get_feature_log2level_q = qq^select sam.id, fea.id, mea.value   
                                     from Sample sam           
                                     inner join SampleMeasurements sms on sam.id = sms.from_link      
                                     inner join Measurement mea on sms.to_link = mea.id       
                                     inner join FeatureMeasuredBy fmb on mea.id = fmb.to_link      
                                     inner join kbase_sapling_v1.Feature fea on fmb.from_link = fea.id       
                                     where sam.id in (^.
				     join(",", ("?") x @{$sampleIDs}). ") ";
    if (scalar(@{$featureIDs}) > 0)
    {
	$get_feature_log2level_q .= qq^ and fea.id in (^. join(",", ("?") x @{$featureIDs}). ") ";
    }

    my $get_feature_log2level_qh = $dbh->prepare($get_feature_log2level_q) or die "Unable to prepare get_feature_log2level_q : ".
        $get_feature_log2level_q . " : " .$dbh->errstr();
    $get_feature_log2level_qh->execute(@{$sampleIDs},@{$featureIDs})  or die "Unable to execute get_feature_log2level_q : ".
        $get_feature_log2level_q . " : " .$get_feature_log2level_qh->errstr();
    while(my ($sample_id,$feature_id,$log2level) = $get_feature_log2level_qh->fetchrow_array())
    { 
        $labelDataMapping->{$sample_id}->{$feature_id}=$log2level;
    } 

    #END get_expression_data_by_samples_and_features
    my @_bad_returns;
    (ref($labelDataMapping) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"labelDataMapping\" (value was \"$labelDataMapping\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_data_by_samples_and_features:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_data_by_samples_and_features');
    }
    return($labelDataMapping);
}




=head2 get_expression_samples_data_by_series_ids

  $seriesExpressionDataSamplesMapping = $obj->get_expression_samples_data_by_series_ids($seriesIDs)

=over 4

=item Parameter and return types

=begin html

<pre>
$seriesIDs is a SeriesIDs
$seriesExpressionDataSamplesMapping is a SeriesExpressionDataSamplesMapping
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
SeriesExpressionDataSamplesMapping is a reference to a hash where the key is a SeriesID and the value is an ExpressionDataSamplesMap
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleID has a value which is a SampleID
	sourceID has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceID has a value which is a string
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
	platformID has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentID has a value which is a string
	environmentDescription has a value which is a string
	protocolID has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotations has a value which is a SampleAnnotations
	seriesIDs has a value which is a SeriesIDs
	personIDs has a value which is a PersonIDs
	sampleIDsAveragedFrom has a value which is a SampleIDsAveragedFrom
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
SampleType is a string
StrainID is a string
GenomeID is a string
ExperimentalUnitID is a string
ExperimentMetaID is a string
SampleAnnotations is a reference to a list where each element is a SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sampleAnnotationID has a value which is a SampleAnnotationID
	ontologyID has a value which is an OntologyID
	ontologyName has a value which is an OntologyName
	ontologyDefinition has a value which is an OntologyDefinition
SampleAnnotationID is a string
OntologyID is a string
OntologyName is a string
OntologyDefinition is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
SampleIDsAveragedFrom is a reference to a list where each element is a SampleID
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Measurement
FeatureID is a string
Measurement is a float

</pre>

=end html

=begin text

$seriesIDs is a SeriesIDs
$seriesExpressionDataSamplesMapping is a SeriesExpressionDataSamplesMapping
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
SeriesExpressionDataSamplesMapping is a reference to a hash where the key is a SeriesID and the value is an ExpressionDataSamplesMap
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleID has a value which is a SampleID
	sourceID has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceID has a value which is a string
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
	platformID has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentID has a value which is a string
	environmentDescription has a value which is a string
	protocolID has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotations has a value which is a SampleAnnotations
	seriesIDs has a value which is a SeriesIDs
	personIDs has a value which is a PersonIDs
	sampleIDsAveragedFrom has a value which is a SampleIDsAveragedFrom
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
SampleType is a string
StrainID is a string
GenomeID is a string
ExperimentalUnitID is a string
ExperimentMetaID is a string
SampleAnnotations is a reference to a list where each element is a SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sampleAnnotationID has a value which is a SampleAnnotationID
	ontologyID has a value which is an OntologyID
	ontologyName has a value which is an OntologyName
	ontologyDefinition has a value which is an OntologyDefinition
SampleAnnotationID is a string
OntologyID is a string
OntologyName is a string
OntologyDefinition is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
SampleIDsAveragedFrom is a reference to a list where each element is a SampleID
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Measurement
FeatureID is a string
Measurement is a float


=end text



=item Description

given a list of SeriesIDs returns mapping of SeriesID to expressionDataSamples : {series_id -> {sample_id -> expressionSampleDataStructure}}

=back

=cut

sub get_expression_samples_data_by_series_ids
{
    my $self = shift;
    my($seriesIDs) = @_;

    my @_bad_arguments;
    (ref($seriesIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"seriesIDs\" (value was \"$seriesIDs\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_data_by_series_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_series_ids');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($seriesExpressionDataSamplesMapping);
    #BEGIN get_expression_samples_data_by_series_ids
    $seriesExpressionDataSamplesMapping = {};
    if (0 == @{$seriesIDs})
    { 
        my $msg = "get_expression_samples_data_by_series_ids requires a list of valid series ids. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                                             method_name => 'get_expression_samples_data_by_series_ids');
    } 

    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '',
                           { RaiseError => 1, ShowErrorStatement => 1 }
	);


    my $get_sample_ids_by_series_ids_q = 
        qq^select ser.id, sam.id
           from Sample sam 
           inner join SampleInSeries sis on sam.id = sis.from_link
           inner join Series ser on sis.to_link = ser.id
           where ser.id in (^.
	join(",", ("?") x @{$seriesIDs}) . ") "; 
    my $get_sample_ids_by_series_ids_qh = $dbh->prepare($get_sample_ids_by_series_ids_q) or die
                                                "Unable to prepare get_sample_ids_by_series_ids_q : ". 
                                                $get_sample_ids_by_series_ids_q . " : " . dbh->errstr() . "\n\n"; 
    $get_sample_ids_by_series_ids_qh->execute(@{$seriesIDs}) or die "Unable to execute get_sample_ids_by_series_ids_q : ".
			    $get_sample_ids_by_series_ids_q . " : " . $get_sample_ids_by_series_ids_qh->errstr() . "\n\n";
    my %series_id_sample_id_hash; # {seriesID}->{sample_id}=1		
    my %sample_ids_hash; #hash to get unique sample_id_hash
    while (my ($series_id, $sample_id) = $get_sample_ids_by_series_ids_qh->fetchrow_array())			   
    { 
	$sample_ids_hash{$sample_id} = 1; 
	$series_id_sample_id_hash{$series_id}->{$sample_id}=1;
    }
    # Get the ExpressionDataSamples  			    
    my @distinct_sample_ids = keys(%sample_ids_hash); 

    my $sample_ids_data_hash_ref = $self->get_expression_samples_data(\@distinct_sample_ids);

    my %sample_ids_data_hash = %{$sample_ids_data_hash_ref};    
    my %series_id_sample_data_hash; # {series}->{sample_id}->data_hash               
    foreach my $series_id (keys(%series_id_sample_id_hash))
    { 
        foreach my $sample_id (keys(%{$series_id_sample_id_hash{$series_id}}))
	{ 
	    $series_id_sample_data_hash{$series_id}->{$sample_id} = $sample_ids_data_hash{$sample_id};
	} 
    } 
    $seriesExpressionDataSamplesMapping = \%series_id_sample_data_hash;
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




=head2 get_expression_sample_ids_by_series_ids

  $sampleIDs = $obj->get_expression_sample_ids_by_series_ids($seriesIDs)

=over 4

=item Parameter and return types

=begin html

<pre>
$seriesIDs is a SeriesIDs
$sampleIDs is a SampleIDs
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string

</pre>

=end html

=begin text

$seriesIDs is a SeriesIDs
$sampleIDs is a SampleIDs
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string


=end text



=item Description

given a list of SeriesIDs returns a list of Sample IDs

=back

=cut

sub get_expression_sample_ids_by_series_ids
{
    my $self = shift;
    my($seriesIDs) = @_;

    my @_bad_arguments;
    (ref($seriesIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"seriesIDs\" (value was \"$seriesIDs\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_sample_ids_by_series_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_series_ids');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($sampleIDs);
    #BEGIN get_expression_sample_ids_by_series_ids
    if (0 == @{$seriesIDs}) 
    { 
        my $msg = "get_expression_sample_ids_by_series_ids requires a list of valid series ids. ";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
							     method_name => 'get_expression_sample_ids_by_series_ids'); 
    } 

    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 } 
        ); 
 
    my $get_sample_ids_by_series_ids_q = 
        qq^select sam.id 
           from Sample sam  
           inner join SampleInSeries sis on sam.id = sis.from_link  
           inner join Series ser on sis.to_link = ser.id  
           where ser.id in (^. 
	   join(",", ("?") x @{$seriesIDs}) . ") "; 
    my $get_sample_ids_by_series_ids_qh = $dbh->prepare($get_sample_ids_by_series_ids_q) or die 
                                                "Unable to prepare get_sample_ids_by_series_ids_q : ". 
                                                $get_sample_ids_by_series_ids_q . " : " . dbh->errstr() . "\n\n"; 
    $get_sample_ids_by_series_ids_qh->execute(@{$seriesIDs}) or die "Unable to execute get_sample_ids_by_series_ids_q : ". 
	$get_sample_ids_by_series_ids_q . " : " . $get_sample_ids_by_series_ids_qh->errstr() . "\n\n"; 
    my %sample_ids_hash; #hash to get unique sample_id_hash 
    while (my ($sample_id) = $get_sample_ids_by_series_ids_qh->fetchrow_array()) 
    { 
	$sample_ids_hash{$sample_id} = 1;
    } 
    my @temp_arr = keys(%sample_ids_hash);
    $sampleIDs = \@temp_arr;
    #END get_expression_sample_ids_by_series_ids
    my @_bad_returns;
    (ref($sampleIDs) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"sampleIDs\" (value was \"$sampleIDs\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_sample_ids_by_series_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_series_ids');
    }
    return($sampleIDs);
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
	sampleID has a value which is a SampleID
	sourceID has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceID has a value which is a string
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
	platformID has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentID has a value which is a string
	environmentDescription has a value which is a string
	protocolID has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotations has a value which is a SampleAnnotations
	seriesIDs has a value which is a SeriesIDs
	personIDs has a value which is a PersonIDs
	sampleIDsAveragedFrom has a value which is a SampleIDsAveragedFrom
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
SampleType is a string
StrainID is a string
GenomeID is a string
ExperimentMetaID is a string
SampleAnnotations is a reference to a list where each element is a SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sampleAnnotationID has a value which is a SampleAnnotationID
	ontologyID has a value which is an OntologyID
	ontologyName has a value which is an OntologyName
	ontologyDefinition has a value which is an OntologyDefinition
SampleAnnotationID is a string
OntologyID is a string
OntologyName is a string
OntologyDefinition is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
SampleIDsAveragedFrom is a reference to a list where each element is a SampleID
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Measurement
FeatureID is a string
Measurement is a float

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
	sampleID has a value which is a SampleID
	sourceID has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceID has a value which is a string
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
	platformID has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentID has a value which is a string
	environmentDescription has a value which is a string
	protocolID has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotations has a value which is a SampleAnnotations
	seriesIDs has a value which is a SeriesIDs
	personIDs has a value which is a PersonIDs
	sampleIDsAveragedFrom has a value which is a SampleIDsAveragedFrom
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
SampleType is a string
StrainID is a string
GenomeID is a string
ExperimentMetaID is a string
SampleAnnotations is a reference to a list where each element is a SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sampleAnnotationID has a value which is a SampleAnnotationID
	ontologyID has a value which is an OntologyID
	ontologyName has a value which is an OntologyName
	ontologyDefinition has a value which is an OntologyDefinition
SampleAnnotationID is a string
OntologyID is a string
OntologyName is a string
OntologyDefinition is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
SampleIDsAveragedFrom is a reference to a list where each element is a SampleID
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Measurement
FeatureID is a string
Measurement is a float


=end text



=item Description

given a list of ExperimentalUnitIDs returns mapping of ExperimentalUnitID to expressionDataSamples : {experimental_unit_id -> {sample_id -> expressionSampleDataStructure}}

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
    $experimentalUnitExpressionDataSamplesMapping = {};
    if (0 == @{$experimentalUnitIDs}) 
    { 
        my $msg = "get_expression_samples_data_by_experimental_unit_ids requires a list of valid experimental unit ids. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'get_expression_samples_data_by_experimental_unit_ids'); 
    } 

    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '',
                           { RaiseError => 1, ShowErrorStatement => 1 }
	); 
    my $get_sample_ids_by_experimental_unit_ids_q = 
        qq^select eu.id, sam.id           
           from  Sample sam
           inner join HasExpressionSample hes on sam.id = hes.to_link
           inner join ExperimentalUnit eu on hes.from_link = eu.id
           where eu.id in (^.
	   join(",", ("?") x @{$experimentalUnitIDs}) . ") "; 
    my $get_sample_ids_by_experimental_unit_ids_qh = $dbh->prepare($get_sample_ids_by_experimental_unit_ids_q) or die 
                                                              "Unable to prepare get_sample_ids_by_experimental_unit_ids_q : ". 
                                                              $get_sample_ids_by_experimental_unit_ids_q . " : " . dbh->errstr() . "\n\n"; 
    $get_sample_ids_by_experimental_unit_ids_qh->execute(@{$experimentalUnitIDs}) or die "Unable to execute get_sample_ids_by_experimental_unit_ids_q : ". 
        $get_sample_ids_by_experimental_unit_ids_q . " : " . $get_sample_ids_by_experimental_unit_ids_qh->errstr() . "\n\n"; 
    my %experimental_unit_sample_list_hash; # {experimentalUnitID}->[Sample_IDS]                                                                                                                                                                                                               
    my %sample_ids_hash; #hash to get unique sample_id_hash                                                                                                                                                                                                                                    
    while (my ($experimental_unit_id, $sample_id) = $get_sample_ids_by_experimental_unit_ids_qh->fetchrow_array()) 
    { 
        $sample_ids_hash{$sample_id} = 1; 
        if (exists($experimental_unit_sample_list_hash{$experimental_unit_id})) 
        { 
            push(@{$experimental_unit_sample_list_hash{$experimental_unit_id}},$sample_id); 
        } 
        else 
        { 
            $experimental_unit_sample_list_hash{$experimental_unit_id} = [$sample_id]; 
        } 
    } 
    # Get the ExpressionDataSamples                                                                                                                                                                                                                                                            
    my @distinct_sample_ids = keys(%sample_ids_hash); 
    my %sample_ids_data_hash = %{$self->get_expression_samples_data(\@distinct_sample_ids)}; 
    my %exp_unit_sample_data_hash; # {exp_unit_id}->{sample_id}->data_hash                                                                                                                                                                                                                     
    foreach my $experimental_unit_id (keys(%experimental_unit_sample_list_hash)) 
    { 
        foreach my $sample_id (@{$experimental_unit_sample_list_hash{$experimental_unit_id}}) 
        { 
            $exp_unit_sample_data_hash{$experimental_unit_id}->{$sample_id} = $sample_ids_data_hash{$sample_id}; 
        } 
    } 
    $experimentalUnitExpressionDataSamplesMapping = \%exp_unit_sample_data_hash; 
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




=head2 get_expression_sample_ids_by_experimental_unit_ids

  $sampleIDs = $obj->get_expression_sample_ids_by_experimental_unit_ids($experimentalUnitIDs)

=over 4

=item Parameter and return types

=begin html

<pre>
$experimentalUnitIDs is an ExperimentalUnitIDs
$sampleIDs is a SampleIDs
ExperimentalUnitIDs is a reference to a list where each element is an ExperimentalUnitID
ExperimentalUnitID is a string
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string

</pre>

=end html

=begin text

$experimentalUnitIDs is an ExperimentalUnitIDs
$sampleIDs is a SampleIDs
ExperimentalUnitIDs is a reference to a list where each element is an ExperimentalUnitID
ExperimentalUnitID is a string
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string


=end text



=item Description

given a list of ExperimentalUnitIDs returns a list of Sample IDs

=back

=cut

sub get_expression_sample_ids_by_experimental_unit_ids
{
    my $self = shift;
    my($experimentalUnitIDs) = @_;

    my @_bad_arguments;
    (ref($experimentalUnitIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"experimentalUnitIDs\" (value was \"$experimentalUnitIDs\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_sample_ids_by_experimental_unit_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_experimental_unit_ids');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($sampleIDs);
    #BEGIN get_expression_sample_ids_by_experimental_unit_ids
    $sampleIDs = [];
    if (0 == @{$experimentalUnitIDs}) 
    { 
        my $msg = "get_expression_sample_ids_by_experimental_unit_ids requires a list of valid experimental unit ids. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                                             method_name => 'get_expression_sample_ids_by_experimental_unit_ids'); 
    } 
 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 } 
        ); 
    my $get_sample_ids_by_experimental_unit_ids_q = 
        qq^select distinct sam.id   
           from  Sample sam  
           inner join HasExpressionSample hes on sam.id = hes.to_link  
           inner join ExperimentalUnit eu on hes.from_link = eu.id
           where eu.id in (^. 
           join(",", ("?") x @{$experimentalUnitIDs}) . ") "; 
    my $get_sample_ids_by_experimental_unit_ids_qh = $dbh->prepare($get_sample_ids_by_experimental_unit_ids_q) or die 
                                                              "Unable to prepare get_sample_ids_by_experimental_unit_ids_q : ". 
                                                              $get_sample_ids_by_experimental_unit_ids_q . " : " . dbh->errstr() . "\n\n"; 
    $get_sample_ids_by_experimental_unit_ids_qh->execute(@{$experimentalUnitIDs}) or die "Unable to execute get_sample_ids_by_experimental_unit_ids_q : ". 
        $get_sample_ids_by_experimental_unit_ids_q . " : " . $get_sample_ids_by_experimental_unit_ids_qh->errstr() . "\n\n"; 
    while (my ($sample_id) = $get_sample_ids_by_experimental_unit_ids_qh->fetchrow_array()) 
    { 
	push(@$sampleIDs,$sample_id);
    } 
    #END get_expression_sample_ids_by_experimental_unit_ids
    my @_bad_returns;
    (ref($sampleIDs) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"sampleIDs\" (value was \"$sampleIDs\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_sample_ids_by_experimental_unit_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_experimental_unit_ids');
    }
    return($sampleIDs);
}




=head2 get_expression_samples_data_by_experiment_meta_ids

  $experimentMetaExpressionDataSamplesMapping = $obj->get_expression_samples_data_by_experiment_meta_ids($experimentMetaIDs)

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
	sampleID has a value which is a SampleID
	sourceID has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceID has a value which is a string
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
	platformID has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentID has a value which is a string
	environmentDescription has a value which is a string
	protocolID has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotations has a value which is a SampleAnnotations
	seriesIDs has a value which is a SeriesIDs
	personIDs has a value which is a PersonIDs
	sampleIDsAveragedFrom has a value which is a SampleIDsAveragedFrom
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
SampleType is a string
StrainID is a string
GenomeID is a string
SampleAnnotations is a reference to a list where each element is a SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sampleAnnotationID has a value which is a SampleAnnotationID
	ontologyID has a value which is an OntologyID
	ontologyName has a value which is an OntologyName
	ontologyDefinition has a value which is an OntologyDefinition
SampleAnnotationID is a string
OntologyID is a string
OntologyName is a string
OntologyDefinition is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
SampleIDsAveragedFrom is a reference to a list where each element is a SampleID
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Measurement
FeatureID is a string
Measurement is a float

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
	sampleID has a value which is a SampleID
	sourceID has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceID has a value which is a string
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
	platformID has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentID has a value which is a string
	environmentDescription has a value which is a string
	protocolID has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotations has a value which is a SampleAnnotations
	seriesIDs has a value which is a SeriesIDs
	personIDs has a value which is a PersonIDs
	sampleIDsAveragedFrom has a value which is a SampleIDsAveragedFrom
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
SampleType is a string
StrainID is a string
GenomeID is a string
SampleAnnotations is a reference to a list where each element is a SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sampleAnnotationID has a value which is a SampleAnnotationID
	ontologyID has a value which is an OntologyID
	ontologyName has a value which is an OntologyName
	ontologyDefinition has a value which is an OntologyDefinition
SampleAnnotationID is a string
OntologyID is a string
OntologyName is a string
OntologyDefinition is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
SampleIDsAveragedFrom is a reference to a list where each element is a SampleID
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Measurement
FeatureID is a string
Measurement is a float


=end text



=item Description

given a list of ExperimentMetaIDs returns mapping of {experimentMetaID -> {experimentalUnitId -> {sample_id -> expressionSampleDataStructure}}}

=back

=cut

sub get_expression_samples_data_by_experiment_meta_ids
{
    my $self = shift;
    my($experimentMetaIDs) = @_;

    my @_bad_arguments;
    (ref($experimentMetaIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"experimentMetaIDs\" (value was \"$experimentMetaIDs\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_data_by_experiment_meta_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_experiment_meta_ids');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($experimentMetaExpressionDataSamplesMapping);
    #BEGIN get_expression_samples_data_by_experiment_meta_ids
    $experimentMetaExpressionDataSamplesMapping = {}; 
    if (0 == @{$experimentMetaIDs}) 
    { 
        my $msg = "get_expression_samples_data_by_experimental_meta_ids requires a list of valid experimental unit ids. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'get_expression_samples_data_by_experiment_meta_ids'); 
    } 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 } 
        ); 
 
    my %experimentMetaExpressionDataSamplesMapping_hash; 
    my %experimental_unit_ids_hash; 
    my $get_experimental_unit_ids_by_experiment_meta_ids_q = 
        qq^select em.id, eu.id   
           from Sample sam  
           inner join HasExpressionSample hes on sam.id = hes.to_link     
           inner join ExperimentalUnit eu on hes.from_link = eu.id        
           inner join HasExperimentalUnit heu on eu.id = heu.to_link   
           inner join ExperimentMeta em on heu.from_link = em.id   
           where em.id in (^. 
	join(",", ("?") x @{$experimentMetaIDs}) . ") "; 
    my $get_experimental_unit_ids_by_experiment_meta_ids_qh = $dbh->prepare($get_experimental_unit_ids_by_experiment_meta_ids_q) or die 
                                                              "Unable to prepare get_experimental_unit_ids_by_experiment_meta_ids_q : ". 
    $get_experimental_unit_ids_by_experiment_meta_ids_q . " : " . dbh->errstr() . "\n\n"; 
    $get_experimental_unit_ids_by_experiment_meta_ids_qh->execute(@{$experimentMetaIDs}) or 
			       die "Unable to execute get_experimental_unit_ids_by_experiment_meta_ids_q : ". 
    $get_experimental_unit_ids_by_experiment_meta_ids_q . " : " . $get_experimental_unit_ids_by_experiment_meta_ids_qh->errstr() . "\n\n"; 
    while (my ($experiment_meta_id, $experimental_unit_id) = $get_experimental_unit_ids_by_experiment_meta_ids_qh->fetchrow_array()) 
    { 
	$experimentMetaExpressionDataSamplesMapping_hash{$experiment_meta_id}->{$experimental_unit_id}=1; 
	$experimental_unit_ids_hash{$experimental_unit_id}=1; 
    } 
    my @distinct_experimental_unit_ids = keys(%experimental_unit_ids_hash); 
    my %experimentalUnitExpressionDataSamplesMapping = %{$self->get_expression_samples_data_by_experimental_unit_ids(\@distinct_experimental_unit_ids)}; 
    my %return_expmeta_data_hash; 
    foreach my $experiment_meta_id (keys(%experimentMetaExpressionDataSamplesMapping_hash)) 
    { 
	my %exp_unit_hash = %{$experimentMetaExpressionDataSamplesMapping_hash{$experiment_meta_id}}; 
        foreach my $experimental_unit_id (keys(%exp_unit_hash)) 
        { 
            $return_expmeta_data_hash{$experiment_meta_id}->{$experimental_unit_id}=$experimentalUnitExpressionDataSamplesMapping{$experimental_unit_id}; 
        } 
    } 
    $experimentMetaExpressionDataSamplesMapping = \%return_expmeta_data_hash; 
    #END get_expression_samples_data_by_experiment_meta_ids
    my @_bad_returns;
    (ref($experimentMetaExpressionDataSamplesMapping) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"experimentMetaExpressionDataSamplesMapping\" (value was \"$experimentMetaExpressionDataSamplesMapping\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_data_by_experiment_meta_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_experiment_meta_ids');
    }
    return($experimentMetaExpressionDataSamplesMapping);
}




=head2 get_expression_sample_ids_by_experiment_meta_ids

  $sampleIDs = $obj->get_expression_sample_ids_by_experiment_meta_ids($experimentMetaIDs)

=over 4

=item Parameter and return types

=begin html

<pre>
$experimentMetaIDs is an ExperimentMetaIDs
$sampleIDs is a SampleIDs
ExperimentMetaIDs is a reference to a list where each element is an ExperimentMetaID
ExperimentMetaID is a string
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string

</pre>

=end html

=begin text

$experimentMetaIDs is an ExperimentMetaIDs
$sampleIDs is a SampleIDs
ExperimentMetaIDs is a reference to a list where each element is an ExperimentMetaID
ExperimentMetaID is a string
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string


=end text



=item Description

given a list of ExperimentMetaIDs returns a list of Sample IDs

=back

=cut

sub get_expression_sample_ids_by_experiment_meta_ids
{
    my $self = shift;
    my($experimentMetaIDs) = @_;

    my @_bad_arguments;
    (ref($experimentMetaIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"experimentMetaIDs\" (value was \"$experimentMetaIDs\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_sample_ids_by_experiment_meta_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_experiment_meta_ids');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($sampleIDs);
    #BEGIN get_expression_sample_ids_by_experiment_meta_ids
    $sampleIDs = [];
    if (0 == @{$experimentMetaIDs}) 
    { 
        my $msg = "get_expression_sample_ids_by_experimental_meta_ids requires a list of valid experimental unit ids. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'get_expression_sample_ids_by_experiment_meta_ids'); 
    } 

    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 } 
        ); 
     my $get_experimental_unit_ids_by_experiment_meta_ids_q = 
        qq^select distinct sam.id
           from Sample sam   
           inner join HasExpressionSample hes on sam.id = hes.to_link 
           inner join ExperimentalUnit eu on hes.from_link = eu.id   
           inner join HasExperimentalUnit heu on eu.id = heu.to_link  
           inner join ExperimentMeta em on heu.from_link = em.id  
           where em.id in (^. 
	   join(",", ("?") x @{$experimentMetaIDs}) . ") "; 
    my $get_experimental_unit_ids_by_experiment_meta_ids_qh = $dbh->prepare($get_experimental_unit_ids_by_experiment_meta_ids_q) or die 
                                                              "Unable to prepare get_experimental_unit_ids_by_experiment_meta_ids_q : ". 
							      $get_experimental_unit_ids_by_experiment_meta_ids_q . " : " . dbh->errstr() . "\n\n"; 
    $get_experimental_unit_ids_by_experiment_meta_ids_qh->execute(@{$experimentMetaIDs}) or 
                               die "Unable to execute get_experimental_unit_ids_by_experiment_meta_ids_q : ". 
			       $get_experimental_unit_ids_by_experiment_meta_ids_q . " : " . $get_experimental_unit_ids_by_experiment_meta_ids_qh->errstr() . "\n\n"; 
    while (my ($sample_id) = $get_experimental_unit_ids_by_experiment_meta_ids_qh->fetchrow_array()) 
    { 
	push(@$sampleIDs,$sample_id);
    } 
    #END get_expression_sample_ids_by_experiment_meta_ids
    my @_bad_returns;
    (ref($sampleIDs) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"sampleIDs\" (value was \"$sampleIDs\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_sample_ids_by_experiment_meta_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_experiment_meta_ids');
    }
    return($sampleIDs);
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
	sampleID has a value which is a SampleID
	sourceID has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceID has a value which is a string
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
	platformID has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentID has a value which is a string
	environmentDescription has a value which is a string
	protocolID has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotations has a value which is a SampleAnnotations
	seriesIDs has a value which is a SeriesIDs
	personIDs has a value which is a PersonIDs
	sampleIDsAveragedFrom has a value which is a SampleIDsAveragedFrom
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
GenomeID is a string
ExperimentalUnitID is a string
ExperimentMetaID is a string
SampleAnnotations is a reference to a list where each element is a SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sampleAnnotationID has a value which is a SampleAnnotationID
	ontologyID has a value which is an OntologyID
	ontologyName has a value which is an OntologyName
	ontologyDefinition has a value which is an OntologyDefinition
SampleAnnotationID is a string
OntologyID is a string
OntologyName is a string
OntologyDefinition is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
SampleIDsAveragedFrom is a reference to a list where each element is a SampleID
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Measurement
FeatureID is a string
Measurement is a float

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
	sampleID has a value which is a SampleID
	sourceID has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceID has a value which is a string
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
	platformID has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentID has a value which is a string
	environmentDescription has a value which is a string
	protocolID has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotations has a value which is a SampleAnnotations
	seriesIDs has a value which is a SeriesIDs
	personIDs has a value which is a PersonIDs
	sampleIDsAveragedFrom has a value which is a SampleIDsAveragedFrom
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
GenomeID is a string
ExperimentalUnitID is a string
ExperimentMetaID is a string
SampleAnnotations is a reference to a list where each element is a SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sampleAnnotationID has a value which is a SampleAnnotationID
	ontologyID has a value which is an OntologyID
	ontologyName has a value which is an OntologyName
	ontologyDefinition has a value which is an OntologyDefinition
SampleAnnotationID is a string
OntologyID is a string
OntologyName is a string
OntologyDefinition is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
SampleIDsAveragedFrom is a reference to a list where each element is a SampleID
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Measurement
FeatureID is a string
Measurement is a float


=end text



=item Description

given a list of Strains, and a SampleType (controlled vocabulary : microarray, RNA-Seq, qPCR, or proteomics) , it returns a StrainExpressionDataSamplesMapping,  
StrainId -> ExpressionSampleDataStructure {strain_id -> {sample_id -> expressionSampleDataStructure}}

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
    $strainExpressionDataSamplesMapping = {};
    if (0 == scalar(@{$strainIDs})) 
    { 
        my $msg = "get_expression_samples_data_by_strain_ids requires a list of valid strain ids. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'get_expression_samples_data_by_strain_ids'); 
    } 
    my $sample_type_part = ""; 
    if ((uc($sampleType) eq "RNA-SEQ") || (uc($sampleType) eq "RNA_SEQ") || (uc($sampleType) eq "RNASEQ") || (uc($sampleType) eq "RNA SEQ")) 
    { 
        $sample_type_part = " and sam.type = 'RNA-Seq' "; 
    } 
    elsif(uc($sampleType) eq "QPCR") 
    { 
        $sample_type_part = " and sam.type = 'qPCR' "; 
    } 
    elsif(uc($sampleType) eq "MICROARRAY") 
    { 
        $sample_type_part = " and sam.type = 'microarray' "; 
    } 
    elsif(uc($sampleType) eq "PROTEOMICS") 
    { 
        $sample_type_part = " and sam.type = 'proteomics' "; 
    } 
    else 
    { 
        #ASSUME "ALL" DO NOT HAVE A SAMPLE TYPE FILTER keep it empty.                                                                                                                                                           
    } 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '',
                           { RaiseError => 1, ShowErrorStatement => 1 }
	);

    my $get_sample_ids_by_strain_ids_q = 
        qq^select str.id, sam.id
           from Sample sam 
           inner join StrainWithSample sws on sam.id = sws.to_link
           inner join Strain str on sws.from_link = str.id 
           where str.id in (^. 
	join(",", ("?") x @{$strainIDs}) . ") ".
	$sample_type_part;
    my $get_sample_ids_by_strain_ids_qh = $dbh->prepare($get_sample_ids_by_strain_ids_q) or die 
                                                              "Unable to prepare get_sample_ids_by_strain_ids_q : ". 
                                                              $get_sample_ids_by_strain_ids_q . " : " . dbh->errstr() . "\n\n"; 
    $get_sample_ids_by_strain_ids_qh->execute(@{$strainIDs}) or die "Unable to execute get_sample_ids_by_strain_ids_q : ". 
        $get_sample_ids_by_strain_ids_q . " : " . $get_sample_ids_by_strain_ids_qh->errstr() . "\n\n"; 
    my %strain_id_sample_id_hash; # {strainID}->{sample_id}=1     
    my %sample_ids_hash; #hash to get unique sample_id_hash      
    while (my ($strain_id, $sample_id) = $get_sample_ids_by_strain_ids_qh->fetchrow_array()) 
    { 
        $sample_ids_hash{$sample_id} = 1; 
	$strain_id_sample_id_hash{$strain_id}->{$sample_id}=1;
    } 
    # Get the ExpressionDataSamples                                                                                                                                                                                            
    my @distinct_sample_ids = keys(%sample_ids_hash); 
    my %sample_ids_data_hash = %{$self->get_expression_samples_data(\@distinct_sample_ids)}; 
    my %strain_id_sample_data_hash; # {strain}->{sample_id}->data_hash                  
    foreach my $strain_id (keys(%strain_id_sample_id_hash)) 
    { 
        foreach my $sample_id (keys(%{$strain_id_sample_id_hash{$strain_id}})) 
        { 
            $strain_id_sample_data_hash{$strain_id}->{$sample_id} = $sample_ids_data_hash{$sample_id}; 
        } 
    } 
    $strainExpressionDataSamplesMapping = \%strain_id_sample_data_hash; 
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




=head2 get_expression_sample_ids_by_strain_ids

  $sampleIDs = $obj->get_expression_sample_ids_by_strain_ids($strainIDs, $sampleType)

=over 4

=item Parameter and return types

=begin html

<pre>
$strainIDs is a StrainIDs
$sampleType is a SampleType
$sampleIDs is a SampleIDs
StrainIDs is a reference to a list where each element is a StrainID
StrainID is a string
SampleType is a string
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string

</pre>

=end html

=begin text

$strainIDs is a StrainIDs
$sampleType is a SampleType
$sampleIDs is a SampleIDs
StrainIDs is a reference to a list where each element is a StrainID
StrainID is a string
SampleType is a string
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string


=end text



=item Description

given a list of Strains, and a SampleType, it returns a list of Sample IDs

=back

=cut

sub get_expression_sample_ids_by_strain_ids
{
    my $self = shift;
    my($strainIDs, $sampleType) = @_;

    my @_bad_arguments;
    (ref($strainIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"strainIDs\" (value was \"$strainIDs\")");
    (!ref($sampleType)) or push(@_bad_arguments, "Invalid type for argument \"sampleType\" (value was \"$sampleType\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_sample_ids_by_strain_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_strain_ids');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($sampleIDs);
    #BEGIN get_expression_sample_ids_by_strain_ids
    $sampleIDs = [];
    if (0 == @{$strainIDs}) 
    { 
        my $msg = "get_expression_sample_ids_by_strain_ids requires a list of valid strain ids. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'get_expression_sample_ids_by_strain_ids'); 
    } 
    my $sample_type_part = ""; 
    if ((uc($sampleType) eq "RNA-SEQ") || (uc($sampleType) eq "RNA_SEQ") || (uc($sampleType) eq "RNASEQ") || (uc($sampleType) eq "RNA SEQ")) 
    { 
        $sample_type_part = " and sam.type = 'RNA-Seq' "; 
    } 
    elsif(uc($sampleType) eq "QPCR") 
    { 
        $sample_type_part = " and sam.type = 'qPCR' "; 
    } 
    elsif(uc($sampleType) eq "MICROARRAY") 
    { 
        $sample_type_part = " and sam.type = 'microarray' "; 
    } 
    elsif(uc($sampleType) eq "PROTEOMICS") 
    { 
        $sample_type_part = " and sam.type = 'proteomics' "; 
    } 
    else 
    { 
        #ASSUME "ALL" DO NOT HAVE A SAMPLE TYPE FILTER keep it empty. 
    } 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 } 
        ); 
 
    my $get_sample_ids_by_strain_ids_q = 
        qq^select distinct sam.id 
           from Sample sam 
           inner join StrainWithSample sws on sam.id = sws.to_link 
           inner join Strain str on sws.from_link = str.id   
           where str.id in (^. 
	   join(",", ("?") x @{$strainIDs}) . ") ". 
	   $sample_type_part; 
    my $get_sample_ids_by_strain_ids_qh = $dbh->prepare($get_sample_ids_by_strain_ids_q) or die
                                                              "Unable to prepare get_sample_ids_by_strain_ids_q : ".
							      $get_sample_ids_by_strain_ids_q . " : " . dbh->errstr() . "\n\n";
    $get_sample_ids_by_strain_ids_qh->execute(@{$strainIDs}) or die "Unable to execute get_sample_ids_by_strain_ids_q : ".
	$get_sample_ids_by_strain_ids_q . " : " . $get_sample_ids_by_strain_ids_qh->errstr() . "\n\n";
    while (my ($sample_id) = $get_sample_ids_by_strain_ids_qh->fetchrow_array()) 
    { 
	push(@$sampleIDs,$sample_id);
    } 
    #END get_expression_sample_ids_by_strain_ids
    my @_bad_returns;
    (ref($sampleIDs) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"sampleIDs\" (value was \"$sampleIDs\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_sample_ids_by_strain_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_strain_ids');
    }
    return($sampleIDs);
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
	sampleID has a value which is a SampleID
	sourceID has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceID has a value which is a string
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
	platformID has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentID has a value which is a string
	environmentDescription has a value which is a string
	protocolID has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotations has a value which is a SampleAnnotations
	seriesIDs has a value which is a SeriesIDs
	personIDs has a value which is a PersonIDs
	sampleIDsAveragedFrom has a value which is a SampleIDsAveragedFrom
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
ExperimentalUnitID is a string
ExperimentMetaID is a string
SampleAnnotations is a reference to a list where each element is a SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sampleAnnotationID has a value which is a SampleAnnotationID
	ontologyID has a value which is an OntologyID
	ontologyName has a value which is an OntologyName
	ontologyDefinition has a value which is an OntologyDefinition
SampleAnnotationID is a string
OntologyID is a string
OntologyName is a string
OntologyDefinition is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
SampleIDsAveragedFrom is a reference to a list where each element is a SampleID
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Measurement
FeatureID is a string
Measurement is a float

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
	sampleID has a value which is a SampleID
	sourceID has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceID has a value which is a string
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
	platformID has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentID has a value which is a string
	environmentDescription has a value which is a string
	protocolID has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotations has a value which is a SampleAnnotations
	seriesIDs has a value which is a SeriesIDs
	personIDs has a value which is a PersonIDs
	sampleIDsAveragedFrom has a value which is a SampleIDsAveragedFrom
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
ExperimentalUnitID is a string
ExperimentMetaID is a string
SampleAnnotations is a reference to a list where each element is a SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sampleAnnotationID has a value which is a SampleAnnotationID
	ontologyID has a value which is an OntologyID
	ontologyName has a value which is an OntologyName
	ontologyDefinition has a value which is an OntologyDefinition
SampleAnnotationID is a string
OntologyID is a string
OntologyName is a string
OntologyDefinition is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
SampleIDsAveragedFrom is a reference to a list where each element is a SampleID
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Measurement
FeatureID is a string
Measurement is a float


=end text



=item Description

given a list of Genomes, a SampleType ( controlled vocabulary : microarray, RNA-Seq, qPCR, or proteomics) 
and a int indicating WildTypeOnly (1 = true, 0 = false) , it returns a GenomeExpressionDataSamplesMapping   ,  
GenomeId -> StrainId -> ExpressionDataSample.  StrainId -> ExpressionSampleDataStructure {genome_id -> {strain_id -> {sample_id -> expressionSampleDataStructure}}}

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
    $genomeExpressionDataSamplesMapping = {};
    if (0 == @{$genomeIDs}) 
    { 
        my $msg = "get_expression_samples_data_by_genome_ids  requires a list of valid genome ids. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'get_expression_samples_data_by_genome_ids'); 
    } 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '',
                           { RaiseError => 1, ShowErrorStatement => 1 }
	);

    my $wild_type_part = "";
    if (($wildTypeOnly eq "1") || (uc($wildTypeOnly) eq "Y") || (uc($wildTypeOnly) eq "TRUE"))
    {
	$wild_type_part = " and str.wildType = 'Y' ";
    }
    my $sample_type_part = "";
    if ((uc($sampleType) eq "RNA-SEQ") || (uc($sampleType) eq "RNA_SEQ") || (uc($sampleType) eq "RNASEQ") || (uc($sampleType) eq "RNA SEQ"))
    {
	$sample_type_part = " and sam.type = 'RNA-Seq' ";
    }
    elsif(uc($sampleType) eq "QPCR")
    {
	$sample_type_part = " and sam.type = 'qPCR' ";
    }
    elsif(uc($sampleType) eq "MICROARRAY")
    {
	$sample_type_part = " and sam.type = 'microarray' ";
    }
    elsif(uc($sampleType) eq "PROTEOMICS")
    {
        $sample_type_part = " and sam.type = 'proteomics' ";
    }
    else 
    {
	#ASSUME "ALL" DO NOT HAVE A SAMPLE TYPE FILTER keep it empty.
    }
    my %strain_ids_hash; 
    my %genome_strain_id_hash;
    my $get_strain_ids_by_genome_ids_q = 
        qq^select gen.id, str.id
           from Sample sam 
           inner join StrainWithSample sws on sam.id = sws.to_link
           inner join Strain str on sws.from_link = str.id
           inner join GenomeParentOf gpo on str.id = gpo.to_link
           inner join kbase_sapling_v1.Genome gen on gpo.from_link = gen.id
           where gen.id in (^.
	   join(",", ("?") x @{$genomeIDs}). ") ". 
	   $wild_type_part . 
	   $sample_type_part;
    my $get_strain_ids_by_genome_ids_qh = $dbh->prepare($get_strain_ids_by_genome_ids_q) or die 
                                                              "Unable to prepare get_strain_ids_by_genome_ids_q : ". 
                                                              $get_strain_ids_by_genome_ids_q . " : " . dbh->errstr() . "\n\n"; 
    $get_strain_ids_by_genome_ids_qh->execute(@{$genomeIDs}) or die "Unable to execute get_strain_ids_by_genome_ids_q : ". 
        $get_strain_ids_by_genome_ids_q . " : " . $get_strain_ids_by_genome_ids_qh->errstr() . "\n\n"; 
    while (my ($genome_id, $strain_id) = $get_strain_ids_by_genome_ids_qh->fetchrow_array()) 
    { 
        $genome_strain_id_hash{$genome_id}->{$strain_id}=1; 
        $strain_ids_hash{$strain_id}=1; 
    } 
    my @distinct_strain_ids = keys(%strain_ids_hash); 
    my %strainExpressionDataSamplesMapping = %{$self->get_expression_samples_data_by_strain_ids(\@distinct_strain_ids, $sampleType)}; 
 
    my %return_genome_data_hash; 
    foreach my $genome_id (keys(%genome_strain_id_hash)) 
    { 
	my %strain_hash = %{$genome_strain_id_hash{$genome_id}};
	foreach my $strain_id (keys(%strain_hash))
	{
	    $return_genome_data_hash{$genome_id}->{$strain_id} = $strainExpressionDataSamplesMapping{$strain_id};
	}
    } 
    $genomeExpressionDataSamplesMapping = \%return_genome_data_hash;              
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




=head2 get_expression_sample_ids_by_genome_ids

  $sampleIDs = $obj->get_expression_sample_ids_by_genome_ids($genomeIDs, $sampleType, $wildTypeOnly)

=over 4

=item Parameter and return types

=begin html

<pre>
$genomeIDs is a GenomeIDs
$sampleType is a SampleType
$wildTypeOnly is a WildTypeOnly
$sampleIDs is a SampleIDs
GenomeIDs is a reference to a list where each element is a GenomeID
GenomeID is a string
SampleType is a string
WildTypeOnly is an int
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string

</pre>

=end html

=begin text

$genomeIDs is a GenomeIDs
$sampleType is a SampleType
$wildTypeOnly is a WildTypeOnly
$sampleIDs is a SampleIDs
GenomeIDs is a reference to a list where each element is a GenomeID
GenomeID is a string
SampleType is a string
WildTypeOnly is an int
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string


=end text



=item Description

given a list of GenomeIDs, a SampleType ( controlled vocabulary : microarray, RNA-Seq, qPCR, or proteomics) 
and a int indicating WildType Only (1 = true, 0 = false) , it returns a list of Sample IDs

=back

=cut

sub get_expression_sample_ids_by_genome_ids
{
    my $self = shift;
    my($genomeIDs, $sampleType, $wildTypeOnly) = @_;

    my @_bad_arguments;
    (ref($genomeIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"genomeIDs\" (value was \"$genomeIDs\")");
    (!ref($sampleType)) or push(@_bad_arguments, "Invalid type for argument \"sampleType\" (value was \"$sampleType\")");
    (!ref($wildTypeOnly)) or push(@_bad_arguments, "Invalid type for argument \"wildTypeOnly\" (value was \"$wildTypeOnly\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_sample_ids_by_genome_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_genome_ids');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($sampleIDs);
    #BEGIN get_expression_sample_ids_by_genome_ids
    $sampleIDs = [];
    if (0 == @{$genomeIDs}) 
    { 
        my $msg = "get_expression_sample_ids_by_genome_ids requires a list of valid genome ids. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'get_expression_sample_ids_by_genome_ids'); 
    } 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 } 
        ); 
 
    my $wild_type_part = ""; 
    if (($wildTypeOnly eq "1") || (uc($wildTypeOnly) eq "Y") || (uc($wildTypeOnly) eq "TRUE")) 
    { 
        $wild_type_part = " and str.wildType = 'Y' "; 
    } 
    my $sample_type_part = ""; 
    if ((uc($sampleType) eq "RNA-SEQ") || (uc($sampleType) eq "RNA_SEQ") || (uc($sampleType) eq "RNASEQ") || (uc($sampleType) eq "RNA SEQ")) 
    { 
        $sample_type_part = " and sam.type = 'RNA-Seq' "; 
    } 
    elsif(uc($sampleType) eq "QPCR") 
    { 
        $sample_type_part = " and sam.type = 'qPCR' "; 
    } 
    elsif(uc($sampleType) eq "MICROARRAY") 
    { 
        $sample_type_part = " and sam.type = 'microarray' "; 
    } 
    elsif(uc($sampleType) eq "PROTEOMICS") 
    { 
        $sample_type_part = " and sam.type = 'proteomics' "; 
    } 
    else 
    { 
        #ASSUME "ALL" DO NOT HAVE A SAMPLE TYPE FILTER keep it empty.   
    } 
    my $get_strain_ids_by_genome_ids_q = 
        qq^select distinct sam.id  
           from Sample sam 
           inner join StrainWithSample sws on sam.id = sws.to_link 
           inner join Strain str on sws.from_link = str.id 
           inner join GenomeParentOf gpo on str.id = gpo.to_link 
           inner join kbase_sapling_v1.Genome gen on gpo.from_link = gen.id     
           where gen.id in (^. 
	   join(",", ("?") x @{$genomeIDs}). ") ". 
           $wild_type_part . 
	   $sample_type_part; 
    my $get_strain_ids_by_genome_ids_qh = $dbh->prepare($get_strain_ids_by_genome_ids_q) or die
	"Unable to prepare get_strain_ids_by_genome_ids_q : ".
	$get_strain_ids_by_genome_ids_q . " : " . dbh->errstr() . "\n\n";
    $get_strain_ids_by_genome_ids_qh->execute(@{$genomeIDs}) or die "Unable to execute get_strain_ids_by_genome_ids_q : ".
	$get_strain_ids_by_genome_ids_q . " : " . $get_strain_ids_by_genome_ids_qh->errstr() . "\n\n";
    while (my ($sample_id) = $get_strain_ids_by_genome_ids_qh->fetchrow_array())
    {
	push(@$sampleIDs,$sample_id);
    }
    #END get_expression_sample_ids_by_genome_ids
    my @_bad_returns;
    (ref($sampleIDs) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"sampleIDs\" (value was \"$sampleIDs\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_sample_ids_by_genome_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_genome_ids');
    }
    return($sampleIDs);
}




=head2 get_expression_samples_data_by_ontology_ids

  $ontologyExpressionDataSampleMapping = $obj->get_expression_samples_data_by_ontology_ids($ontologyIDs, $AndOr, $genomeId, $sampleType, $wildTypeOnly)

=over 4

=item Parameter and return types

=begin html

<pre>
$ontologyIDs is an OntologyIDs
$AndOr is a string
$genomeId is a GenomeID
$sampleType is a SampleType
$wildTypeOnly is a WildTypeOnly
$ontologyExpressionDataSampleMapping is an OntologyExpressionDataSampleMapping
OntologyIDs is a reference to a list where each element is an OntologyID
OntologyID is a string
GenomeID is a string
SampleType is a string
WildTypeOnly is an int
OntologyExpressionDataSampleMapping is a reference to a hash where the key is an OntologyID and the value is an ExpressionDataSamplesMap
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleID has a value which is a SampleID
	sourceID has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceID has a value which is a string
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
	platformID has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentID has a value which is a string
	environmentDescription has a value which is a string
	protocolID has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotations has a value which is a SampleAnnotations
	seriesIDs has a value which is a SeriesIDs
	personIDs has a value which is a PersonIDs
	sampleIDsAveragedFrom has a value which is a SampleIDsAveragedFrom
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
StrainID is a string
ExperimentalUnitID is a string
ExperimentMetaID is a string
SampleAnnotations is a reference to a list where each element is a SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sampleAnnotationID has a value which is a SampleAnnotationID
	ontologyID has a value which is an OntologyID
	ontologyName has a value which is an OntologyName
	ontologyDefinition has a value which is an OntologyDefinition
SampleAnnotationID is a string
OntologyName is a string
OntologyDefinition is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
SampleIDsAveragedFrom is a reference to a list where each element is a SampleID
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Measurement
FeatureID is a string
Measurement is a float

</pre>

=end html

=begin text

$ontologyIDs is an OntologyIDs
$AndOr is a string
$genomeId is a GenomeID
$sampleType is a SampleType
$wildTypeOnly is a WildTypeOnly
$ontologyExpressionDataSampleMapping is an OntologyExpressionDataSampleMapping
OntologyIDs is a reference to a list where each element is an OntologyID
OntologyID is a string
GenomeID is a string
SampleType is a string
WildTypeOnly is an int
OntologyExpressionDataSampleMapping is a reference to a hash where the key is an OntologyID and the value is an ExpressionDataSamplesMap
ExpressionDataSamplesMap is a reference to a hash where the key is a SampleID and the value is an ExpressionDataSample
SampleID is a string
ExpressionDataSample is a reference to a hash where the following keys are defined:
	sampleID has a value which is a SampleID
	sourceID has a value which is a string
	sampleTitle has a value which is a string
	sampleDescription has a value which is a string
	molecule has a value which is a string
	sampleType has a value which is a SampleType
	dataSource has a value which is a string
	externalSourceID has a value which is a string
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
	platformID has a value which is a string
	platformTitle has a value which is a string
	platformTechnology has a value which is a string
	experimentalUnitID has a value which is an ExperimentalUnitID
	experimentMetaID has a value which is an ExperimentMetaID
	experimentTitle has a value which is a string
	experimentDescription has a value which is a string
	environmentID has a value which is a string
	environmentDescription has a value which is a string
	protocolID has a value which is a string
	protocolDescription has a value which is a string
	protocolName has a value which is a string
	sampleAnnotations has a value which is a SampleAnnotations
	seriesIDs has a value which is a SeriesIDs
	personIDs has a value which is a PersonIDs
	sampleIDsAveragedFrom has a value which is a SampleIDsAveragedFrom
	dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample
StrainID is a string
ExperimentalUnitID is a string
ExperimentMetaID is a string
SampleAnnotations is a reference to a list where each element is a SampleAnnotation
SampleAnnotation is a reference to a hash where the following keys are defined:
	sampleAnnotationID has a value which is a SampleAnnotationID
	ontologyID has a value which is an OntologyID
	ontologyName has a value which is an OntologyName
	ontologyDefinition has a value which is an OntologyDefinition
SampleAnnotationID is a string
OntologyName is a string
OntologyDefinition is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
PersonIDs is a reference to a list where each element is a PersonID
PersonID is a string
SampleIDsAveragedFrom is a reference to a list where each element is a SampleID
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Measurement
FeatureID is a string
Measurement is a float


=end text



=item Description

given a list of ontologyIDs, AndOr operator (and requires sample to have all ontology IDs, or sample has to have any of the terms), GenomeId, 
SampleType ( controlled vocabulary : microarray, RNA-Seq, qPCR, or proteomics), wildTypeOnly returns OntologyID(concatenated if Anded) -> ExpressionDataSample

=back

=cut

sub get_expression_samples_data_by_ontology_ids
{
    my $self = shift;
    my($ontologyIDs, $AndOr, $genomeId, $sampleType, $wildTypeOnly) = @_;

    my @_bad_arguments;
    (ref($ontologyIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"ontologyIDs\" (value was \"$ontologyIDs\")");
    (!ref($AndOr)) or push(@_bad_arguments, "Invalid type for argument \"AndOr\" (value was \"$AndOr\")");
    (!ref($genomeId)) or push(@_bad_arguments, "Invalid type for argument \"genomeId\" (value was \"$genomeId\")");
    (!ref($sampleType)) or push(@_bad_arguments, "Invalid type for argument \"sampleType\" (value was \"$sampleType\")");
    (!ref($wildTypeOnly)) or push(@_bad_arguments, "Invalid type for argument \"wildTypeOnly\" (value was \"$wildTypeOnly\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_data_by_ontology_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_ontology_ids');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($ontologyExpressionDataSampleMapping);
    #BEGIN get_expression_samples_data_by_ontology_ids
    $ontologyExpressionDataSampleMapping = {}; 
    if (0 == @{$ontologyIDs}) 
    { 
        my $msg = "get_expression_samples_data_by_ontology_ids requires a list of valid ontology ids. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
							       method_name => 'get_expression_samples_data_by_ontology_ids'); 
    } 
    if (uc($AndOr) eq 'AND')
    {
	$AndOr = 'and';
    }
    elsif (uc($AndOr) eq 'OR')
    {
	$AndOr = 'or';
    }
    else  #DEFAULTS TO OR : Really should have a warning or error message, but this is undefined KBase wide.  Meantime will default.
    {
	$AndOr = 'or';
    }
    my $wild_type_part = ""; 
    if (($wildTypeOnly eq "1") || (uc($wildTypeOnly) eq "Y") || (uc($wildTypeOnly) eq "TRUE")) 
    { 
        $wild_type_part = " and str.wildType = 'Y' "; 
    } 
    my $sample_type_part = ""; 
    if ((uc($sampleType) eq "RNA-SEQ") || (uc($sampleType) eq "RNA_SEQ") || (uc($sampleType) eq "RNASEQ") || (uc($sampleType) eq "RNA SEQ")) 
    { 
        $sample_type_part = " and sam.type = 'RNA-Seq' "; 
    } 
    elsif(uc($sampleType) eq "QPCR") 
    { 
        $sample_type_part = " and sam.type = 'qPCR' "; 
    } 
    elsif(uc($sampleType) eq "MICROARRAY") 
    { 
        $sample_type_part = " and sam.type = 'microarray' "; 
    } 
    elsif(uc($sampleType) eq "PROTEOMICS") 
    { 
        $sample_type_part = " and sam.type = 'proteomics' "; 
    } 
    else 
    { 
        #ASSUME "ALL" DO NOT HAVE A SAMPLE TYPE FILTER keep it empty.          
    } 
    my %distinct_ontologies;
    foreach my $ont_id (@{$ontologyIDs})
    {
	$distinct_ontologies{$ont_id} = 1;
    }
    my $distinct_ontology_count = scalar(keys(%distinct_ontologies));

    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 } 
	); 
    my $get_sample_ids_by_ontology_ids_q = 
	    qq^select distinct sam.id as samid, ont.id as ontid
               from Sample sam  
               inner join StrainWithSample sws on sam.id = sws.to_link 
               inner join Strain str on sws.from_link = str.id 
               inner join GenomeParentOf gpo on str.id = gpo.to_link 
               inner join kbase_sapling_v1.Genome gen on gpo.from_link = gen.id 
               inner join SampleHasAnnotations sha on sha.from_link = sam.id
               inner join OntologyForSample ofs on ofs.to_link = sha.to_link
               inner join Ontology ont on ofs.from_link = ont.id
               where gen.id = ? ^.
	       $sample_type_part .
	       $wild_type_part .
	    qq^ and ont.id in ( ^.
            join(",", ("?") x $distinct_ontology_count). ") "; 

    if (($AndOr eq 'or') || ($distinct_ontology_count == 1)) 
    { 
	my $get_sample_ids_by_ontology_ids_qh = $dbh->prepare($get_sample_ids_by_ontology_ids_q) or die 
                                                              "Unable to prepare get_sample_ids_by_ontolgy_ids_q : ". 
                                                              $get_sample_ids_by_ontology_ids_q . " : " . dbh->errstr() . "\n\n"; 
	$get_sample_ids_by_ontology_ids_qh->execute($genomeId, keys(%distinct_ontologies)) 
	    or die "Unable to execute get_sample_ids_by_ontology_ids_q : ". 
	    $get_sample_ids_by_ontology_ids_q . " : " . $get_sample_ids_by_ontology_ids_qh->errstr() . "\n\n"; 
	my %ontology_id_sample_id_hash; # {ontologyID}->{sample_id}=1   
	my %sample_ids_hash; #hash to get unique sample_id_hash    
	while (my ($sample_id, $ontology_id) = $get_sample_ids_by_ontology_ids_qh->fetchrow_array()) 
	{ 
	    $sample_ids_hash{$sample_id} = 1; 
	    $ontology_id_sample_id_hash{$ontology_id}->{$sample_id}=1; 
	} 
	# Get the ExpressionDataSamples     
	my @distinct_sample_ids = keys(%sample_ids_hash);
	my %sample_ids_data_hash = %{$self->get_expression_samples_data(\@distinct_sample_ids)};
	my %ontology_id_sample_data_hash; # {ontology_id}->{sample_id}->data_hash                                                                            
	foreach my $ontology_id (keys(%ontology_id_sample_id_hash))
	{
	    foreach my $sample_id (keys(%{$ontology_id_sample_id_hash{$ontology_id}}))
	    { 
		$ontology_id_sample_data_hash{$ontology_id}->{$sample_id} = $sample_ids_data_hash{$sample_id}; 
	    } 
	} 
	$ontologyExpressionDataSampleMapping = \%ontology_id_sample_data_hash; 
    }
    elsif ($AndOr eq 'and')
    {
	$get_sample_ids_by_ontology_ids_q =  
	    qq^select results.samid from ( ^.
	    $get_sample_ids_by_ontology_ids_q .
	    qq^) results
               group by results.samid
               having count(results.ontid) = ^ . $distinct_ontology_count;
	#print "QUERY : " . $get_sample_ids_by_ontology_ids_q . "\n";
    
        my $get_sample_ids_by_ontology_ids_qh = $dbh->prepare($get_sample_ids_by_ontology_ids_q) or die
                                                              "Unable to prepare get_sample_ids_by_ontolgy_ids_q : ".
                                                              $get_sample_ids_by_ontology_ids_q . " : " . dbh->errstr() . "\n\n";
        $get_sample_ids_by_ontology_ids_qh->execute($genomeId, keys(%distinct_ontologies)) 
	    or die "Unable to execute get_sample_ids_by_ontology_ids_q : ".
            $get_sample_ids_by_ontology_ids_q . " : " . $get_sample_ids_by_ontology_ids_qh->errstr() . "\n\n";
        my %ontology_id_sample_data_hash; # {ontologyID}->{sample_id}=1 
        my @sample_ids_arr; #unique sample_ids   
        while (my ($sample_id) = $get_sample_ids_by_ontology_ids_qh->fetchrow_array())
        {
	    push(@sample_ids_arr,$sample_id);
	}
	if (scalar(@sample_ids_arr) > 0)
	{
	    my %sample_ids_data_hash = %{$self->get_expression_samples_data(\@sample_ids_arr)}; 
	    my $ontology_and_key = join(",",sort(keys(%distinct_ontologies)));
	    $ontology_id_sample_data_hash{$ontology_and_key}= \%sample_ids_data_hash; 
	}
	$ontologyExpressionDataSampleMapping = \%ontology_id_sample_data_hash; 
    }
    #END get_expression_samples_data_by_ontology_ids
    my @_bad_returns;
    (ref($ontologyExpressionDataSampleMapping) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"ontologyExpressionDataSampleMapping\" (value was \"$ontologyExpressionDataSampleMapping\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_data_by_ontology_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_data_by_ontology_ids');
    }
    return($ontologyExpressionDataSampleMapping);
}




=head2 get_expression_sample_ids_by_ontology_ids

  $sampleIDs = $obj->get_expression_sample_ids_by_ontology_ids($ontologyIDs, $AndOr, $genomeId, $sampleType, $wildTypeOnly)

=over 4

=item Parameter and return types

=begin html

<pre>
$ontologyIDs is an OntologyIDs
$AndOr is a string
$genomeId is a GenomeID
$sampleType is a SampleType
$wildTypeOnly is a WildTypeOnly
$sampleIDs is a SampleIDs
OntologyIDs is a reference to a list where each element is an OntologyID
OntologyID is a string
GenomeID is a string
SampleType is a string
WildTypeOnly is an int
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string

</pre>

=end html

=begin text

$ontologyIDs is an OntologyIDs
$AndOr is a string
$genomeId is a GenomeID
$sampleType is a SampleType
$wildTypeOnly is a WildTypeOnly
$sampleIDs is a SampleIDs
OntologyIDs is a reference to a list where each element is an OntologyID
OntologyID is a string
GenomeID is a string
SampleType is a string
WildTypeOnly is an int
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string


=end text



=item Description

given a list of ontologyIDs, AndOr operator (and requires sample to have all ontology IDs, or sample has to have any of the terms), GenomeId, 
SampleType ( controlled vocabulary : microarray, RNA-Seq, qPCR, or proteomics), wildTypeOnly returns a list of SampleIDs

=back

=cut

sub get_expression_sample_ids_by_ontology_ids
{
    my $self = shift;
    my($ontologyIDs, $AndOr, $genomeId, $sampleType, $wildTypeOnly) = @_;

    my @_bad_arguments;
    (ref($ontologyIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"ontologyIDs\" (value was \"$ontologyIDs\")");
    (!ref($AndOr)) or push(@_bad_arguments, "Invalid type for argument \"AndOr\" (value was \"$AndOr\")");
    (!ref($genomeId)) or push(@_bad_arguments, "Invalid type for argument \"genomeId\" (value was \"$genomeId\")");
    (!ref($sampleType)) or push(@_bad_arguments, "Invalid type for argument \"sampleType\" (value was \"$sampleType\")");
    (!ref($wildTypeOnly)) or push(@_bad_arguments, "Invalid type for argument \"wildTypeOnly\" (value was \"$wildTypeOnly\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_sample_ids_by_ontology_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_ontology_ids');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($sampleIDs);
    #BEGIN get_expression_sample_ids_by_ontology_ids
    $sampleIDs = [];
    if (0 == @{$ontologyIDs})
    { 
        my $msg = "get_expression_sample_ids_by_ontology_ids requires a list of valid ontology ids. ";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							     method_name => 'get_expression_sample_ids_by_ontology_ids');
    } 
    if (uc($AndOr) eq 'AND')
    { 
        $AndOr = 'and'; 
    } 
    elsif (uc($AndOr) eq 'OR') 
    { 
        $AndOr = 'or'; 
    } 
    else  #DEFAULTS TO OR : Really should have a warning or error message, but this is undefined KBase wide.  Meantime will default.  
    { 
        $AndOr = 'or'; 
    } 
    my $wild_type_part = ""; 
    if (($wildTypeOnly eq "1") || (uc($wildTypeOnly) eq "Y") || (uc($wildTypeOnly) eq "TRUE")) 
    { 
        $wild_type_part = " and str.wildType = 'Y' "; 
    } 
    my $sample_type_part = ""; 
    if ((uc($sampleType) eq "RNA-SEQ") || (uc($sampleType) eq "RNA_SEQ") || (uc($sampleType) eq "RNASEQ") || (uc($sampleType) eq "RNA SEQ")) 
    { 
        $sample_type_part = " and sam.type = 'RNA-Seq' "; 
    } 
    elsif(uc($sampleType) eq "QPCR") 
    { 
        $sample_type_part = " and sam.type = 'qPCR' "; 
    } 
    elsif(uc($sampleType) eq "MICROARRAY")
    {
        $sample_type_part = " and sam.type = 'microarray' ";
    } 
    elsif(uc($sampleType) eq "PROTEOMICS") 
    { 
        $sample_type_part = " and sam.type = 'proteomics' "; 
    } 
    else 
    { 
        #ASSUME "ALL" DO NOT HAVE A SAMPLE TYPE FILTER keep it empty.         
    } 
    my %distinct_ontologies; 
    foreach my $ont_id (@{$ontologyIDs}) 
    { 
        $distinct_ontologies{$ont_id} = 1; 
    } 
    my $distinct_ontology_count = scalar(keys(%distinct_ontologies)); 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 }
        ); 
    my $get_sample_ids_by_ontology_ids_q_p1 = qq^select distinct sam.id as samid ^;
    my $get_sample_ids_by_ontology_ids_q_sub = ", ont.id as ontid "; 
    my $get_sample_ids_by_ontology_ids_q_p2 =
            qq^from Sample sam
               inner join StrainWithSample sws on sam.id = sws.to_link  
               inner join Strain str on sws.from_link = str.id               
               inner join GenomeParentOf gpo on str.id = gpo.to_link    
               inner join kbase_sapling_v1.Genome gen on gpo.from_link = gen.id   
               inner join SampleHasAnnotations sha on sha.from_link = sam.id  
               inner join OntologyForSample ofs on ofs.to_link = sha.to_link  
               inner join Ontology ont on ofs.from_link = ont.id  
               where gen.id = ? ^.
               $sample_type_part . 
               $wild_type_part . 
            qq^ and ont.id in ( ^. 
            join(",", ("?") x $distinct_ontology_count). ") ";
    if (($AndOr eq 'or') || ($distinct_ontology_count == 1)) 
    { 
	my $get_sample_ids_by_ontology_ids_q = $get_sample_ids_by_ontology_ids_q_p1 . $get_sample_ids_by_ontology_ids_q_p2;
        my $get_sample_ids_by_ontology_ids_qh = $dbh->prepare($get_sample_ids_by_ontology_ids_q) or die 
                                                              "Unable to prepare get_sample_ids_by_ontolgy_ids_q : ".
                                                              $get_sample_ids_by_ontology_ids_q . " : " . dbh->errstr() . "\n\n";
        $get_sample_ids_by_ontology_ids_qh->execute($genomeId, keys(%distinct_ontologies))
            or die "Unable to execute get_sample_ids_by_ontology_ids_q : ". 
            $get_sample_ids_by_ontology_ids_q . " : " . $get_sample_ids_by_ontology_ids_qh->errstr() . "\n\n";
        while (my ($sample_id) = $get_sample_ids_by_ontology_ids_qh->fetchrow_array())
        {
            push(@$sampleIDs,$sample_id);
        } 
    }
    elsif ($AndOr eq 'and') 
    { 
        my $get_sample_ids_by_ontology_ids_q = 
            qq^select results.samid from ( ^. 
	    $get_sample_ids_by_ontology_ids_q_p1 .
	    $get_sample_ids_by_ontology_ids_q_sub . 
	    $get_sample_ids_by_ontology_ids_q_p2.
            qq^) results  
               group by results.samid  
               having count(results.ontid) = ^ . $distinct_ontology_count; 
        #print "QUERY : " . $get_sample_ids_by_ontology_ids_q . "\n";  
	my $get_sample_ids_by_ontology_ids_qh = $dbh->prepare($get_sample_ids_by_ontology_ids_q) or die 
                                                              "Unable to prepare get_sample_ids_by_ontolgy_ids_q : ". 
                                                              $get_sample_ids_by_ontology_ids_q . " : " . dbh->errstr() . "\n\n"; 
        $get_sample_ids_by_ontology_ids_qh->execute($genomeId, keys(%distinct_ontologies)) 
            or die "Unable to execute get_sample_ids_by_ontology_ids_q : ". 
            $get_sample_ids_by_ontology_ids_q . " : " . $get_sample_ids_by_ontology_ids_qh->errstr() . "\n\n"; 
        while (my ($sample_id) = $get_sample_ids_by_ontology_ids_qh->fetchrow_array()) 
        { 
            push(@$sampleIDs,$sample_id); 
        } 
    }
    #END get_expression_sample_ids_by_ontology_ids
    my @_bad_returns;
    (ref($sampleIDs) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"sampleIDs\" (value was \"$sampleIDs\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_sample_ids_by_ontology_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_ontology_ids');
    }
    return($sampleIDs);
}




=head2 get_expression_data_by_feature_ids

  $featureSampleMeasurementMapping = $obj->get_expression_data_by_feature_ids($featureIDs, $sampleType, $wildTypeOnly)

=over 4

=item Parameter and return types

=begin html

<pre>
$featureIDs is a FeatureIDs
$sampleType is a SampleType
$wildTypeOnly is a WildTypeOnly
$featureSampleMeasurementMapping is a FeatureSampleMeasurementMapping
FeatureIDs is a reference to a list where each element is a FeatureID
FeatureID is a string
SampleType is a string
WildTypeOnly is an int
FeatureSampleMeasurementMapping is a reference to a hash where the key is a FeatureID and the value is a SampleMeasurementMapping
SampleMeasurementMapping is a reference to a hash where the key is a SampleID and the value is a Measurement
SampleID is a string
Measurement is a float

</pre>

=end html

=begin text

$featureIDs is a FeatureIDs
$sampleType is a SampleType
$wildTypeOnly is a WildTypeOnly
$featureSampleMeasurementMapping is a FeatureSampleMeasurementMapping
FeatureIDs is a reference to a list where each element is a FeatureID
FeatureID is a string
SampleType is a string
WildTypeOnly is an int
FeatureSampleMeasurementMapping is a reference to a hash where the key is a FeatureID and the value is a SampleMeasurementMapping
SampleMeasurementMapping is a reference to a hash where the key is a SampleID and the value is a Measurement
SampleID is a string
Measurement is a float


=end text



=item Description

given a list of FeatureIDs, a SampleType ( controlled vocabulary : microarray, RNA-Seq, qPCR, or proteomics) 
and an int indicating WildType Only (1 = true, 0 = false) returns a FeatureSampleMeasurementMapping: {featureID->{sample_id->measurement}}

=back

=cut

sub get_expression_data_by_feature_ids
{
    my $self = shift;
    my($featureIDs, $sampleType, $wildTypeOnly) = @_;

    my @_bad_arguments;
    (ref($featureIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"featureIDs\" (value was \"$featureIDs\")");
    (!ref($sampleType)) or push(@_bad_arguments, "Invalid type for argument \"sampleType\" (value was \"$sampleType\")");
    (!ref($wildTypeOnly)) or push(@_bad_arguments, "Invalid type for argument \"wildTypeOnly\" (value was \"$wildTypeOnly\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_data_by_feature_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_data_by_feature_ids');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($featureSampleMeasurementMapping);
    #BEGIN get_expression_data_by_feature_ids
    $featureSampleMeasurementMapping = {};
    if (0 == @{$featureIDs}) 
    { 
        my $msg = "get_expression_data_by_feature_ids requires a list of valid feature ids. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'get_expression_data_by_feature_ids'); 
    } 

    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '',
                           { RaiseError => 1, ShowErrorStatement => 1 }
	);

    my $wild_type_part = ""; 
    if (($wildTypeOnly eq "1") || (uc($wildTypeOnly) eq "Y") || (uc($wildTypeOnly) eq "TRUE")) 
    { 
        $wild_type_part = " and str.wildType = 'Y' "; 
    } 
    my $sample_type_part = ""; 
    if ((uc($sampleType) eq "RNA-SEQ") || (uc($sampleType) eq "RNA_SEQ") || (uc($sampleType) eq "RNASEQ") || (uc($sampleType) eq "RNA SEQ")) 
    { 
        $sample_type_part = " and sam.type = 'RNA-Seq' "; 
    } 
    elsif(uc($sampleType) eq "QPCR") 
    { 
        $sample_type_part = " and sam.type = 'qPCR' "; 
    } 
    elsif(uc($sampleType) eq "MICROARRAY") 
    { 
        $sample_type_part = " and sam.type = 'microarray' "; 
    } 
    elsif(uc($sampleType) eq "PROTEOMICS") 
    { 
        $sample_type_part = " and sam.type = 'proteomics' "; 
    } 
    else 
    { 
        #ASSUME "ALL" DO NOT HAVE A SAMPLE TYPE FILTER keep it empty.   
    } 
    my $get_feature_log2level_q = qq^select sam.id, fea.id, mea.value  
                                     from Sample sam  
                                     inner join SampleMeasurements sms on sam.id = sms.from_link     
                                     inner join Measurement mea on sms.to_link = mea.id 
                                     inner join FeatureMeasuredBy fmb on mea.id = fmb.to_link 
                                     inner join kbase_sapling_v1.Feature fea on fmb.from_link = fea.id 
                                     inner join StrainWithSample sws on sam.id = sws.to_link 
                                     inner join Strain str on sws.from_link = str.id  
                                     where fea.id in (^.
                                 join(",", ("?") x @{$featureIDs}). ") ". 
                                 $wild_type_part . 
                                 $sample_type_part; 
    my $get_feature_log2level_qh = $dbh->prepare($get_feature_log2level_q) or die "Unable to prepare get_feature_log2level_q : ".
	$get_feature_log2level_q . " : " .$dbh->errstr();
    $get_feature_log2level_qh->execute(@{$featureIDs})  or die "Unable to execute get_feature_log2level_q : ".
        $get_feature_log2level_q . " : " .$get_feature_log2level_qh->errstr(); 
    while(my ($sample_id,$feature_id,$log2level) = $get_feature_log2level_qh->fetchrow_array())
    {
	$featureSampleMeasurementMapping->{$feature_id}->{$sample_id}=$log2level;
    }
    #END get_expression_data_by_feature_ids
    my @_bad_returns;
    (ref($featureSampleMeasurementMapping) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"featureSampleMeasurementMapping\" (value was \"$featureSampleMeasurementMapping\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_data_by_feature_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_data_by_feature_ids');
    }
    return($featureSampleMeasurementMapping);
}




=head2 compare_samples

  $sampleComparisonMapping = $obj->compare_samples($numeratorsDataMapping, $denominatorsDataMapping)

=over 4

=item Parameter and return types

=begin html

<pre>
$numeratorsDataMapping is a LabelDataMapping
$denominatorsDataMapping is a LabelDataMapping
$sampleComparisonMapping is a SampleComparisonMapping
LabelDataMapping is a reference to a hash where the key is a string and the value is a DataExpressionLevelsForSample
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Measurement
FeatureID is a string
Measurement is a float
SampleComparisonMapping is a reference to a hash where the key is a SampleID and the value is a DenominatorSampleComparison
SampleID is a string
DenominatorSampleComparison is a reference to a hash where the key is a ComparisonDenominatorLabel and the value is a DataSampleComparison
ComparisonDenominatorLabel is a string
DataSampleComparison is a reference to a hash where the key is a FeatureID and the value is a Log2Ratio
Log2Ratio is a float

</pre>

=end html

=begin text

$numeratorsDataMapping is a LabelDataMapping
$denominatorsDataMapping is a LabelDataMapping
$sampleComparisonMapping is a SampleComparisonMapping
LabelDataMapping is a reference to a hash where the key is a string and the value is a DataExpressionLevelsForSample
DataExpressionLevelsForSample is a reference to a hash where the key is a FeatureID and the value is a Measurement
FeatureID is a string
Measurement is a float
SampleComparisonMapping is a reference to a hash where the key is a SampleID and the value is a DenominatorSampleComparison
SampleID is a string
DenominatorSampleComparison is a reference to a hash where the key is a ComparisonDenominatorLabel and the value is a DataSampleComparison
ComparisonDenominatorLabel is a string
DataSampleComparison is a reference to a hash where the key is a FeatureID and the value is a Log2Ratio
Log2Ratio is a float


=end text



=item Description

Compare samples takes two data structures labelDataMapping  {sampleID or label}->{featureId or label => value}}, 
the first labelDataMapping is the numerator, the 2nd is the denominator in the comparison. returns a 
SampleComparisonMapping {numerator_sample_id(or label)->{denominator_sample_id(or label)->{feature_id(or label) -> log2Ratio}}}

=back

=cut

sub compare_samples
{
    my $self = shift;
    my($numeratorsDataMapping, $denominatorsDataMapping) = @_;

    my @_bad_arguments;
    (ref($numeratorsDataMapping) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"numeratorsDataMapping\" (value was \"$numeratorsDataMapping\")");
    (ref($denominatorsDataMapping) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"denominatorsDataMapping\" (value was \"$denominatorsDataMapping\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to compare_samples:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'compare_samples');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($sampleComparisonMapping);
    #BEGIN compare_samples
    $sampleComparisonMapping = {};
    my @numerator_keys = keys(%{$numeratorsDataMapping});
    my @denominator_keys = keys(%{$denominatorsDataMapping});
    if ((0 == scalar(@numerator_keys)) || (0 == scalar(@denominator_keys)))
    { 
	my $msg = "The numerator and/or denominator keys passed to compare_samples are empty \n";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'compare_samples'); 
    } 
    my %empty_numerator_keys;
    my %empty_denominator_keys;
    foreach my $numerator_key (@numerator_keys)
    {
	if(scalar(keys(%{$numeratorsDataMapping->{$numerator_key}})) == 0)
	{
	    $empty_numerator_keys{$numerator_key} = 1;
	}
    }
    foreach my $denominator_key (@denominator_keys)
    {
        if(scalar(keys(%{$denominatorsDataMapping->{$denominator_key}})) == 0)
        {
            $empty_denominator_keys{$denominator_key} = 1;
        }
    }
    if ((scalar(keys(%empty_numerator_keys)) > 0) ||
	(scalar(keys(%empty_denominator_keys)) > 0))
    {
	my $msg = "The numerator and/or denominator keys passed had the following empty subhashes:\n";
	if (scalar(keys(%empty_numerator_keys)) > 0)
	{
	    $msg .= "NUMERATOR SUBHASHES : \n";
	    foreach my $numerator_key (keys(%empty_numerator_keys))
	    {
		$msg .= $numerator_key . "\n";
	    }
	}
        if (scalar(keys(%empty_denominator_keys)) > 0)
        {
            $msg .= "DENOMINATOR SUBHASHES : \n";
            foreach my $denominator_key (keys(%empty_denominator_keys))
            {
                $msg .= $denominator_key . "\n";
            } 
        }
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'compare_samples');
    }

    #Create average of denominator_values
    my %denominator_average_hash;  #feature_id -> {running_total->val, count->val}

    foreach my $denominator_key (@denominator_keys)
    {
	foreach my $feature_id (keys(%{$denominatorsDataMapping->{$denominator_key}}))
	{
	    if(exists($denominator_average_hash{$feature_id})) #add to values
	    {
		$denominator_average_hash{$feature_id}{'running_total'} = $denominator_average_hash{$feature_id}{'running_total'} + 
		    $denominatorsDataMapping->{$denominator_key}->{$feature_id} ;
		$denominator_average_hash{$feature_id}{'count'} = $denominator_average_hash{$feature_id}{'count'} + 1;
	    }
	    else #initialize values
	    {
		$denominator_average_hash{$feature_id}{'running_total'} = $denominatorsDataMapping->{$denominator_key}->{$feature_id} ;
		$denominator_average_hash{$feature_id}{'count'} = 1;
	    }
	}
    }
    foreach my $feature_id (keys(%denominator_average_hash)) 
    { 
        $denominator_average_hash{$feature_id}{'average'} = $denominator_average_hash{$feature_id}{'running_total'} / 
            $denominator_average_hash{$feature_id}{'count'}; 
    } 
    my $final_denominator_key; 
    if (scalar(@denominator_keys) == 1) 
    { 
        $final_denominator_key = $denominator_keys[0];
    } 
    else 
    { 
        $final_denominator_key = "Average of samples : ". join (", ",sort(@denominator_keys));
    } 
    #Generate comparisons vs the average.
    foreach my $numerator_key (@numerator_keys)
    {
	foreach my $feature_id (keys(%{$numeratorsDataMapping->{$numerator_key}}))
	{
	    if (exists($denominator_average_hash{$feature_id}->{'average'}))
	    {
		$sampleComparisonMapping->{$numerator_key}->{$final_denominator_key}->{$feature_id} = 
		    $numeratorsDataMapping->{$numerator_key}->{$feature_id} - 
		    $denominator_average_hash{$feature_id}->{'average'};
	    }
	}
    }
    #END compare_samples
    my @_bad_returns;
    (ref($sampleComparisonMapping) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"sampleComparisonMapping\" (value was \"$sampleComparisonMapping\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to compare_samples:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'compare_samples');
    }
    return($sampleComparisonMapping);
}




=head2 compare_samples_vs_default_controls

  $sampleComparisonMapping = $obj->compare_samples_vs_default_controls($numeratorSampleIDs)

=over 4

=item Parameter and return types

=begin html

<pre>
$numeratorSampleIDs is a SampleIDs
$sampleComparisonMapping is a SampleComparisonMapping
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string
SampleComparisonMapping is a reference to a hash where the key is a SampleID and the value is a DenominatorSampleComparison
DenominatorSampleComparison is a reference to a hash where the key is a ComparisonDenominatorLabel and the value is a DataSampleComparison
ComparisonDenominatorLabel is a string
DataSampleComparison is a reference to a hash where the key is a FeatureID and the value is a Log2Ratio
FeatureID is a string
Log2Ratio is a float

</pre>

=end html

=begin text

$numeratorSampleIDs is a SampleIDs
$sampleComparisonMapping is a SampleComparisonMapping
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string
SampleComparisonMapping is a reference to a hash where the key is a SampleID and the value is a DenominatorSampleComparison
DenominatorSampleComparison is a reference to a hash where the key is a ComparisonDenominatorLabel and the value is a DataSampleComparison
ComparisonDenominatorLabel is a string
DataSampleComparison is a reference to a hash where the key is a FeatureID and the value is a Log2Ratio
FeatureID is a string
Log2Ratio is a float


=end text



=item Description

Compares each sample vs its defined default control.  If the Default control is not specified for a sample, then nothing is returned for that sample .
Takes a list of sampleIDs returns SampleComparisonMapping {sample_id ->{denominator_default_control sample_id ->{feature_id -> log2Ratio}}}

=back

=cut

sub compare_samples_vs_default_controls
{
    my $self = shift;
    my($numeratorSampleIDs) = @_;

    my @_bad_arguments;
    (ref($numeratorSampleIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"numeratorSampleIDs\" (value was \"$numeratorSampleIDs\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to compare_samples_vs_default_controls:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'compare_samples_vs_default_controls');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($sampleComparisonMapping);
    #BEGIN compare_samples_vs_default_controls
    $sampleComparisonMapping = {};
    if (scalar(@{$numeratorSampleIDs} == 0)) 
    { 
        my $msg = "compare_samples_vs_default_controls requires a list of valid sample ids. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'compare_samples_vs_default_controls'); 
    } 
 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 } 
        ); 

    my $get_default_sample_ids_q = qq^select to_link as num_sample_id, from_link as control_sample_id 
                                      from DefaultControlSample
                                      where to_link in (^.
                                   join(",", ("?") x @{$numeratorSampleIDs}). ") "; 
    my $get_default_sample_ids_qh = $dbh->prepare($get_default_sample_ids_q) or die "Unable to prepare get_default_sample_ids_q : ".
	$get_default_sample_ids_q , " : " . $dbh->errstr();
    $get_default_sample_ids_qh->execute(@{$numeratorSampleIDs})  or die "Unable to execute get_default_sample_ids_q : ".
        $get_default_sample_ids_q , " : " . $get_default_sample_ids_qh->errstr();
    my %distinct_sample_ids_hash;
    my %numerator_control_mappings;
    while (my ($numerator_sample_id,$control_sample_id) = $get_default_sample_ids_qh->fetchrow_array())
    {
	$distinct_sample_ids_hash{$numerator_sample_id} = 1;
	$distinct_sample_ids_hash{$control_sample_id} = 1;
	$numerator_control_mappings{$numerator_sample_id} = $control_sample_id;
    }
    if (scalar(keys(%distinct_sample_ids_hash)) == 0)
    {
	return $sampleComparisonMapping;
    }
    #log2Levels
    my $get_log2levels_q = qq^select sam.id, fea.id, mea.value
                              from Sample sam 
                              inner join SampleMeasurements sme on sam.id = sme.from_link 
                              inner join Measurement mea on sme.to_link = mea.id  
                              inner join FeatureMeasuredBy fmb on mea.id = fmb.to_link 
                              inner join kbase_sapling_v1.Feature fea on fmb.from_link = fea.id  
                              where sam.id in (^. 
			      join(",", ("?") x scalar(keys(%distinct_sample_ids_hash))) . ") "; 
    my $get_log2levels_qh = $dbh->prepare($get_log2levels_q) or die "Unable to prepare get_log2levels_q : ".
	$get_log2levels_q . " : " . $dbh->errstr(); 
    $get_log2levels_qh->execute(keys(%distinct_sample_ids_hash)) or die "Unable to execute get_log2levels_q : " . $get_log2levels_q . " : ".
	$get_log2levels_qh->errstr(); 
    my %sample_data_hash; # key $sample_id -> {$feature_id => value}
    while(my ($sample_id, $feature_id, $log2level) = $get_log2levels_qh->fetchrow_array())
    { 
        $sample_data_hash{$sample_id}{$feature_id} = $log2level;
    }
    
    foreach my $numerator_sample_id (keys(%numerator_control_mappings))
    {
	my $temp_num_hash->{$numerator_sample_id}=$sample_data_hash{$numerator_sample_id};
	my $temp_control_hash->{$numerator_control_mappings{$numerator_sample_id}} = 
	    $sample_data_hash{$numerator_control_mappings{$numerator_sample_id}};
	my $temp_comparison_hash_ref = $self->compare_samples($temp_num_hash,$temp_control_hash);	
	$sampleComparisonMapping->{$numerator_sample_id}->{$numerator_control_mappings{$numerator_sample_id}} = 
	    $temp_comparison_hash_ref->{$numerator_sample_id}->{$numerator_control_mappings{$numerator_sample_id}};
    }
    #END compare_samples_vs_default_controls
    my @_bad_returns;
    (ref($sampleComparisonMapping) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"sampleComparisonMapping\" (value was \"$sampleComparisonMapping\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to compare_samples_vs_default_controls:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'compare_samples_vs_default_controls');
    }
    return($sampleComparisonMapping);
}




=head2 compare_samples_vs_the_average

  $sampleComparisonMapping = $obj->compare_samples_vs_the_average($numeratorSampleIDs, $denominatorSampleIDs)

=over 4

=item Parameter and return types

=begin html

<pre>
$numeratorSampleIDs is a SampleIDs
$denominatorSampleIDs is a SampleIDs
$sampleComparisonMapping is a SampleComparisonMapping
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string
SampleComparisonMapping is a reference to a hash where the key is a SampleID and the value is a DenominatorSampleComparison
DenominatorSampleComparison is a reference to a hash where the key is a ComparisonDenominatorLabel and the value is a DataSampleComparison
ComparisonDenominatorLabel is a string
DataSampleComparison is a reference to a hash where the key is a FeatureID and the value is a Log2Ratio
FeatureID is a string
Log2Ratio is a float

</pre>

=end html

=begin text

$numeratorSampleIDs is a SampleIDs
$denominatorSampleIDs is a SampleIDs
$sampleComparisonMapping is a SampleComparisonMapping
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string
SampleComparisonMapping is a reference to a hash where the key is a SampleID and the value is a DenominatorSampleComparison
DenominatorSampleComparison is a reference to a hash where the key is a ComparisonDenominatorLabel and the value is a DataSampleComparison
ComparisonDenominatorLabel is a string
DataSampleComparison is a reference to a hash where the key is a FeatureID and the value is a Log2Ratio
FeatureID is a string
Log2Ratio is a float


=end text



=item Description

Compares each numerator sample vs the average of all the denominator sampleIds.  Take a list of numerator sample IDs and a list of samples Ids to average for the denominator.
returns SampleComparisonMapping {numerator_sample_id->{denominator_sample_id ->{feature_id -> log2Ratio}}}

=back

=cut

sub compare_samples_vs_the_average
{
    my $self = shift;
    my($numeratorSampleIDs, $denominatorSampleIDs) = @_;

    my @_bad_arguments;
    (ref($numeratorSampleIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"numeratorSampleIDs\" (value was \"$numeratorSampleIDs\")");
    (ref($denominatorSampleIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"denominatorSampleIDs\" (value was \"$denominatorSampleIDs\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to compare_samples_vs_the_average:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'compare_samples_vs_the_average');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($sampleComparisonMapping);
    #BEGIN compare_samples_vs_the_average
    if((scalar(@{$numeratorSampleIDs}) == 0) || (scalar(@{$denominatorSampleIDs}) == 0))
    { 
	my $msg = "A list of valid sample ids must be present for both the numerator and denominator\n";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
							 method_name => 'compare_samples_vs_average');
    } 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 } 
        ); 
    my %distinct_sample_ids_hash; 
    my %numerator_sample_ids_hash; 
    my %denominator_sample_ids_hash; 
    foreach my $numerator_sample_id (@{$numeratorSampleIDs})
    {
	$numerator_sample_ids_hash{$numerator_sample_id} = 1;
	$distinct_sample_ids_hash{$numerator_sample_id} = 1;
    }
    foreach my $denominator_sample_id (@{$denominatorSampleIDs})
    {
        $denominator_sample_ids_hash{$denominator_sample_id} = 1;
        $distinct_sample_ids_hash{$denominator_sample_id} = 1;
    } 
    #log2Levels                                                                     
    my $get_log2levels_q = qq^select sam.id, fea.id, mea.value              
                              from Sample sam                                  
                              inner join SampleMeasurements sme on sam.id = sme.from_link       
                              inner join Measurement mea on sme.to_link = mea.id                         
                              inner join FeatureMeasuredBy fmb on mea.id = fmb.to_link              
                              inner join kbase_sapling_v1.Feature fea on fmb.from_link = fea.id                    
                              where sam.id in (^. 
                              join(",", ("?") x scalar(keys(%distinct_sample_ids_hash))) . ") "; 
    my $get_log2levels_qh = $dbh->prepare($get_log2levels_q) or die "Unable to prepare get_log2levels_q : ". 
        $get_log2levels_q . " : " . $dbh->errstr(); 
    $get_log2levels_qh->execute(keys(%distinct_sample_ids_hash)) or 
	die "Unable to execute get_log2levels_q : " . $get_log2levels_q . " : ". 
	$get_log2levels_qh->errstr(); 
    my %sample_data_hash; # key $sample_id -> {$feature_id => value}               
    while(my ($sample_id, $feature_id, $log2level) = $get_log2levels_qh->fetchrow_array()) 
    { 
        $sample_data_hash{$sample_id}{$feature_id} = $log2level; 
    } 
    my %numerator_parameter_hash;
    my %denominator_parameter_hash;
    foreach my $sample_id (keys(%sample_data_hash))
    {
	if (exists($numerator_sample_ids_hash{$sample_id}))
	{
	    $numerator_parameter_hash{$sample_id}=$sample_data_hash{$sample_id};
	}
        if (exists($denominator_sample_ids_hash{$sample_id}))
        {
            $denominator_parameter_hash{$sample_id}=$sample_data_hash{$sample_id};
        } 
    }
    $sampleComparisonMapping = $self->compare_samples(\%numerator_parameter_hash,\%denominator_parameter_hash); 
    #END compare_samples_vs_the_average
    my @_bad_returns;
    (ref($sampleComparisonMapping) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"sampleComparisonMapping\" (value was \"$sampleComparisonMapping\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to compare_samples_vs_the_average:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'compare_samples_vs_the_average');
    }
    return($sampleComparisonMapping);
}




=head2 get_on_off_calls

  $onOffMappings = $obj->get_on_off_calls($sampleComparisonMapping, $off_threshold, $on_threshold)

=over 4

=item Parameter and return types

=begin html

<pre>
$sampleComparisonMapping is a SampleComparisonMapping
$off_threshold is a float
$on_threshold is a float
$onOffMappings is a SampleComparisonMapping
SampleComparisonMapping is a reference to a hash where the key is a SampleID and the value is a DenominatorSampleComparison
SampleID is a string
DenominatorSampleComparison is a reference to a hash where the key is a ComparisonDenominatorLabel and the value is a DataSampleComparison
ComparisonDenominatorLabel is a string
DataSampleComparison is a reference to a hash where the key is a FeatureID and the value is a Log2Ratio
FeatureID is a string
Log2Ratio is a float

</pre>

=end html

=begin text

$sampleComparisonMapping is a SampleComparisonMapping
$off_threshold is a float
$on_threshold is a float
$onOffMappings is a SampleComparisonMapping
SampleComparisonMapping is a reference to a hash where the key is a SampleID and the value is a DenominatorSampleComparison
SampleID is a string
DenominatorSampleComparison is a reference to a hash where the key is a ComparisonDenominatorLabel and the value is a DataSampleComparison
ComparisonDenominatorLabel is a string
DataSampleComparison is a reference to a hash where the key is a FeatureID and the value is a Log2Ratio
FeatureID is a string
Log2Ratio is a float


=end text



=item Description

Takes in comparison results.  If the value is >= on_threshold it is deemed on (1), if <= off_threshold it is off(-1), meets none then 0.  Thresholds normally set to zero.
returns SampleComparisonMapping {numerator_sample_id(or label)->{denominator_sample_id(or label)->{feature_id(or label) -> on_off_call (possible values 0,-1,1)}}}

=back

=cut

sub get_on_off_calls
{
    my $self = shift;
    my($sampleComparisonMapping, $off_threshold, $on_threshold) = @_;

    my @_bad_arguments;
    (ref($sampleComparisonMapping) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"sampleComparisonMapping\" (value was \"$sampleComparisonMapping\")");
    (!ref($off_threshold)) or push(@_bad_arguments, "Invalid type for argument \"off_threshold\" (value was \"$off_threshold\")");
    (!ref($on_threshold)) or push(@_bad_arguments, "Invalid type for argument \"on_threshold\" (value was \"$on_threshold\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_on_off_calls:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_on_off_calls');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($onOffMappings);
    #BEGIN get_on_off_calls
    if (scalar(keys(%{$sampleComparisonMapping})) == 0)
    {
        my $msg = "The sampleComparisonMapping (1st argument, the hash was empty)";	 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
							     method_name => 'get_on_off_calls'); 
    }
    #Check that thresholds are numbers or empty 
    if ($on_threshold ne '')
    {
	if(!($on_threshold =~ m/^[-+]?[0-9]*\.?[0-9]+$/))
	{ 
	    my $msg = "The on threshold must be a valid number";
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
								   method_name => 'get_on_off_calls');
	} 
    }
    else
    {
	$on_threshold = 0;
    }
    if ($off_threshold ne '')
    {
	if(!($off_threshold =~ m/^[-+]?[0-9]*\.?[0-9]+$/))
	{
	    my $msg = "The off threshold must be a valid number";
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
								   method_name => 'get_on_off_calls'); 
	} 
    }
    else
    {
	$off_threshold = 0;
    }
    if ($on_threshold < $off_threshold)
    {
        my $msg = "The on_threshold must >= the off_threshold"; 
        Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                                             method_name => 'get_on_off_calls'); 	
    }
    foreach my $numerator_key (keys(%{$sampleComparisonMapping}))
    {
	foreach my $denominator_key (keys(%{$sampleComparisonMapping->{$numerator_key}}))
	{
	    foreach my $feature_id (keys(%{$sampleComparisonMapping->{$numerator_key}->{$denominator_key}}))
	    {
		my $tested_value = $sampleComparisonMapping->{$numerator_key}->{$denominator_key}->{$feature_id};
		my $call = 0;
		if ($tested_value >= $on_threshold)
		{
		    $call = 1;
		}
		elsif ($tested_value < $off_threshold)
		{
		    $call = -1;
		}
		$onOffMappings->{$numerator_key}->{$denominator_key}->{$feature_id} = $call;
	    }
	}
    }
    #END get_on_off_calls
    my @_bad_returns;
    (ref($onOffMappings) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"onOffMappings\" (value was \"$onOffMappings\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_on_off_calls:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_on_off_calls');
    }
    return($onOffMappings);
}




=head2 get_top_changers

  $topChangersMappings = $obj->get_top_changers($sampleComparisonMapping, $direction, $count)

=over 4

=item Parameter and return types

=begin html

<pre>
$sampleComparisonMapping is a SampleComparisonMapping
$direction is a string
$count is an int
$topChangersMappings is a SampleComparisonMapping
SampleComparisonMapping is a reference to a hash where the key is a SampleID and the value is a DenominatorSampleComparison
SampleID is a string
DenominatorSampleComparison is a reference to a hash where the key is a ComparisonDenominatorLabel and the value is a DataSampleComparison
ComparisonDenominatorLabel is a string
DataSampleComparison is a reference to a hash where the key is a FeatureID and the value is a Log2Ratio
FeatureID is a string
Log2Ratio is a float

</pre>

=end html

=begin text

$sampleComparisonMapping is a SampleComparisonMapping
$direction is a string
$count is an int
$topChangersMappings is a SampleComparisonMapping
SampleComparisonMapping is a reference to a hash where the key is a SampleID and the value is a DenominatorSampleComparison
SampleID is a string
DenominatorSampleComparison is a reference to a hash where the key is a ComparisonDenominatorLabel and the value is a DataSampleComparison
ComparisonDenominatorLabel is a string
DataSampleComparison is a reference to a hash where the key is a FeatureID and the value is a Log2Ratio
FeatureID is a string
Log2Ratio is a float


=end text



=item Description

Takes in comparison results. Direction must equal 'up', 'down', or 'both'.  Count is the number of changers returned in each direction.
returns SampleComparisonMapping {numerator_sample_id(or label)->{denominator_sample_id(or label)->{feature_id(or label) -> log2Ratio (note that the features listed will be limited to the top changers)}}}

=back

=cut

sub get_top_changers
{
    my $self = shift;
    my($sampleComparisonMapping, $direction, $count) = @_;

    my @_bad_arguments;
    (ref($sampleComparisonMapping) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"sampleComparisonMapping\" (value was \"$sampleComparisonMapping\")");
    (!ref($direction)) or push(@_bad_arguments, "Invalid type for argument \"direction\" (value was \"$direction\")");
    (!ref($count)) or push(@_bad_arguments, "Invalid type for argument \"count\" (value was \"$count\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_top_changers:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_top_changers');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($topChangersMappings);
    #BEGIN get_top_changers
    if (scalar(keys(%{$sampleComparisonMapping})) == 0) 
    { 
        my $msg = "The sampleComparisonMapping (1st argument, the hash was empty)"; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'get_top_changers'); 
    } 
    if (!((uc($direction) eq 'UP') || 
	  (uc($direction) eq 'DOWN') || 
	  (uc($direction) eq 'BOTH')))
    { 
        my $msg = "The Direction (2nd argument) must be equal to 'UP','DOWN', or 'BOTH'"; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'get_top_changers'); 
    } 
    if(!($count =~ m/^\d+$/))
    {
        my $msg = "The count of top changers returned has to be a positive integer";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'get_top_changers'); 
    }
    foreach my $numerator_key (keys(%{$sampleComparisonMapping}))
    { 
        foreach my $denominator_key (keys(%{$sampleComparisonMapping->{$numerator_key}}))
        { 
	    my %data_hash = %{$sampleComparisonMapping->{$numerator_key}->{$denominator_key}};
	    if ((uc($direction) eq 'UP') || (uc($direction) eq 'BOTH'))
	    {
		#get top up changers
		my $counter = 0;
		foreach my $feature_id(sort {$data_hash{$b} <=> $data_hash{$a}} (keys %data_hash))
		{
		    if ($counter < $count)
		    {
			$topChangersMappings->{$numerator_key}->{$denominator_key}->{$feature_id} = 
			    $data_hash{$feature_id};
		    }
		    else {last;}
		    $counter++;
		}
	    }
            if ((uc($direction) eq 'DOWN') || (uc($direction) eq 'BOTH')) 
            {
                #get top down changers                                         
                my $counter = 0;
                foreach my $feature_id(sort {$data_hash{$a} <=> $data_hash{$b}} (keys %data_hash))
                { 
                    if ($counter < $count)
                    {
                        $topChangersMappings->{$numerator_key}->{$denominator_key}->{$feature_id} = 
                            $data_hash{$feature_id};
                    } 
                    else {last;}
		    $counter++;
                } 
            } 
        } 
    }     
    #END get_top_changers
    my @_bad_returns;
    (ref($topChangersMappings) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"topChangersMappings\" (value was \"$topChangersMappings\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_top_changers:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_top_changers');
    }
    return($topChangersMappings);
}




=head2 get_expression_samples_titles

  $samplesTitlesMap = $obj->get_expression_samples_titles($sampleIDs)

=over 4

=item Parameter and return types

=begin html

<pre>
$sampleIDs is a SampleIDs
$samplesTitlesMap is a SamplesStringMap
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string
SamplesStringMap is a reference to a hash where the key is a SampleID and the value is a string

</pre>

=end html

=begin text

$sampleIDs is a SampleIDs
$samplesTitlesMap is a SamplesStringMap
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string
SamplesStringMap is a reference to a hash where the key is a SampleID and the value is a string


=end text



=item Description

given a List of SampleIDs, returns a Hash (key : SampleID, value: Title of Sample)

=back

=cut

sub get_expression_samples_titles
{
    my $self = shift;
    my($sampleIDs) = @_;

    my @_bad_arguments;
    (ref($sampleIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"sampleIDs\" (value was \"$sampleIDs\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_titles:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_titles');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($samplesTitlesMap);
    #BEGIN get_expression_samples_titles
    $samplesTitlesMap = {}; 
    if (0 == @{$sampleIDs}) 
    { 
        my $msg = "get_expression_samples_titles requires a list of valid sample ids. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'get_expression_samples_titles'); 
    } 

    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 } 
	); 
    my $get_samples_titles_q = qq^select id, title from Sample where id in (^.
				    join(",", ("?") x @{$sampleIDs}) . ") "; 
    my $get_samples_titles_qh = $dbh->prepare($get_samples_titles_q) or die "Unable to prepare : get_samples_titles_q : ". 
	$get_samples_titles_q . " : " .$dbh->errstr(); 
    $get_samples_titles_qh->execute(@{$sampleIDs}) or die "Unable to execute : get_samples_titles_q : ".$get_samples_titles_qh->errstr(); 
    while (my ($sample_id, $title) = $get_samples_titles_qh->fetchrow_array())
    {
	$samplesTitlesMap->{$sample_id} = $title;
    }
    #END get_expression_samples_titles
    my @_bad_returns;
    (ref($samplesTitlesMap) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"samplesTitlesMap\" (value was \"$samplesTitlesMap\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_titles:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_titles');
    }
    return($samplesTitlesMap);
}




=head2 get_expression_samples_descriptions

  $samplesDescriptionsMap = $obj->get_expression_samples_descriptions($sampleIDs)

=over 4

=item Parameter and return types

=begin html

<pre>
$sampleIDs is a SampleIDs
$samplesDescriptionsMap is a SamplesStringMap
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string
SamplesStringMap is a reference to a hash where the key is a SampleID and the value is a string

</pre>

=end html

=begin text

$sampleIDs is a SampleIDs
$samplesDescriptionsMap is a SamplesStringMap
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string
SamplesStringMap is a reference to a hash where the key is a SampleID and the value is a string


=end text



=item Description

given a List of SampleIDs, returns a Hash (key : SampleID, value: Description of Sample)

=back

=cut

sub get_expression_samples_descriptions
{
    my $self = shift;
    my($sampleIDs) = @_;

    my @_bad_arguments;
    (ref($sampleIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"sampleIDs\" (value was \"$sampleIDs\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_descriptions:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_descriptions');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($samplesDescriptionsMap);
    #BEGIN get_expression_samples_descriptions
    $samplesDescriptionsMap = {}; 
    if (0 == @{$sampleIDs})
    { 
        my $msg = "get_expression_samples_descriptions requires a list of valid sample ids. ";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                                             method_name => 'get_expression_samples_descriptions');
    } 
 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '',
                           { RaiseError => 1, ShowErrorStatement => 1 }
        ); 
    my $get_samples_descriptions_q = qq^select id, description from Sample where id in (^.
	join(",", ("?") x @{$sampleIDs}) . ") "; 
    my $get_samples_descriptions_qh = $dbh->prepare($get_samples_descriptions_q) or die "Unable to prepare : get_samples_descriptions_q : ".
        $get_samples_descriptions_q . " : " .$dbh->errstr(); 
    $get_samples_descriptions_qh->execute(@{$sampleIDs}) or die "Unable to execute : get_samples_descriptions_q : ".$get_samples_descriptions_qh->errstr();
    while (my ($sample_id, $description) = $get_samples_descriptions_qh->fetchrow_array())
    { 
        $samplesDescriptionsMap->{$sample_id} = $description;
    } 
    #END get_expression_samples_descriptions
    my @_bad_returns;
    (ref($samplesDescriptionsMap) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"samplesDescriptionsMap\" (value was \"$samplesDescriptionsMap\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_descriptions:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_descriptions');
    }
    return($samplesDescriptionsMap);
}




=head2 get_expression_samples_molecules

  $samplesMoleculesMap = $obj->get_expression_samples_molecules($sampleIDs)

=over 4

=item Parameter and return types

=begin html

<pre>
$sampleIDs is a SampleIDs
$samplesMoleculesMap is a SamplesStringMap
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string
SamplesStringMap is a reference to a hash where the key is a SampleID and the value is a string

</pre>

=end html

=begin text

$sampleIDs is a SampleIDs
$samplesMoleculesMap is a SamplesStringMap
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string
SamplesStringMap is a reference to a hash where the key is a SampleID and the value is a string


=end text



=item Description

given a List of SampleIDs, returns a Hash (key : SampleID, value: Molecule of Sample)

=back

=cut

sub get_expression_samples_molecules
{
    my $self = shift;
    my($sampleIDs) = @_;

    my @_bad_arguments;
    (ref($sampleIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"sampleIDs\" (value was \"$sampleIDs\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_molecules:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_molecules');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($samplesMoleculesMap);
    #BEGIN get_expression_samples_molecules
    $samplesMoleculesMap = {}; 
    if (0 == @{$sampleIDs})
    { 
        my $msg = "get_expression_samples_molecules requires a list of valid sample ids. ";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                                             method_name => 'get_expression_samples_molecules');
    } 
 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '',
                           { RaiseError => 1, ShowErrorStatement => 1 }
        ); 
    my $get_samples_molecules_q = qq^select id, molecule from Sample where id in (^.
	join(",", ("?") x @{$sampleIDs}) . ") "; 
    my $get_samples_molecules_qh = $dbh->prepare($get_samples_molecules_q) or die "Unable to prepare : get_samples_molecules_q : ".
        $get_samples_molecules_q . " : " .$dbh->errstr(); 
    $get_samples_molecules_qh->execute(@{$sampleIDs}) or die "Unable to execute : get_samples_molecules_q : ".$get_samples_molecules_qh->errstr();
    while (my ($sample_id, $molecule) = $get_samples_molecules_qh->fetchrow_array())
    { 
        $samplesMoleculesMap->{$sample_id} = $molecule;
    } 
    #END get_expression_samples_molecules
    my @_bad_returns;
    (ref($samplesMoleculesMap) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"samplesMoleculesMap\" (value was \"$samplesMoleculesMap\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_molecules:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_molecules');
    }
    return($samplesMoleculesMap);
}




=head2 get_expression_samples_types

  $samplesTypesMap = $obj->get_expression_samples_types($sampleIDs)

=over 4

=item Parameter and return types

=begin html

<pre>
$sampleIDs is a SampleIDs
$samplesTypesMap is a SamplesStringMap
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string
SamplesStringMap is a reference to a hash where the key is a SampleID and the value is a string

</pre>

=end html

=begin text

$sampleIDs is a SampleIDs
$samplesTypesMap is a SamplesStringMap
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string
SamplesStringMap is a reference to a hash where the key is a SampleID and the value is a string


=end text



=item Description

given a List of SampleIDs, returns a Hash (key : SampleID, value: Type of Sample)

=back

=cut

sub get_expression_samples_types
{
    my $self = shift;
    my($sampleIDs) = @_;

    my @_bad_arguments;
    (ref($sampleIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"sampleIDs\" (value was \"$sampleIDs\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_types:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_types');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($samplesTypesMap);
    #BEGIN get_expression_samples_types
    $samplesTypesMap = {}; 
    if (0 == @{$sampleIDs})
    { 
        my $msg = "get_expression_samples_types requires a list of valid sample ids. ";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                                             method_name => 'get_expression_samples_types');
    } 
 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '',
                           { RaiseError => 1, ShowErrorStatement => 1 }
        ); 
    my $get_samples_types_q = qq^select id, type from Sample where id in (^.
	join(",", ("?") x @{$sampleIDs}) . ") "; 
    my $get_samples_types_qh = $dbh->prepare($get_samples_types_q) or die "Unable to prepare : get_samples_types_q : ".
        $get_samples_types_q . " : " .$dbh->errstr(); 
    $get_samples_types_qh->execute(@{$sampleIDs}) or die "Unable to execute : get_samples_types_q : ".$get_samples_types_qh->errstr();
    while (my ($sample_id, $type) = $get_samples_types_qh->fetchrow_array())
    { 
        $samplesTypesMap->{$sample_id} = $type;
    } 
    #END get_expression_samples_types
    my @_bad_returns;
    (ref($samplesTypesMap) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"samplesTypesMap\" (value was \"$samplesTypesMap\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_types:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_types');
    }
    return($samplesTypesMap);
}




=head2 get_expression_samples_external_source_ids

  $samplesExternalSourceIdMap = $obj->get_expression_samples_external_source_ids($sampleIDs)

=over 4

=item Parameter and return types

=begin html

<pre>
$sampleIDs is a SampleIDs
$samplesExternalSourceIdMap is a SamplesStringMap
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string
SamplesStringMap is a reference to a hash where the key is a SampleID and the value is a string

</pre>

=end html

=begin text

$sampleIDs is a SampleIDs
$samplesExternalSourceIdMap is a SamplesStringMap
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string
SamplesStringMap is a reference to a hash where the key is a SampleID and the value is a string


=end text



=item Description

given a List of SampleIDs, returns a Hash (key : SampleID, value: External_Source_ID of Sample (typically GSM))

=back

=cut

sub get_expression_samples_external_source_ids
{
    my $self = shift;
    my($sampleIDs) = @_;

    my @_bad_arguments;
    (ref($sampleIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"sampleIDs\" (value was \"$sampleIDs\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_external_source_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_external_source_ids');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($samplesExternalSourceIdMap);
    #BEGIN get_expression_samples_external_source_ids
    $samplesExternalSourceIdMap = {}; 
    if (0 == @{$sampleIDs})
    { 
        my $msg = "get_expression_samples_external_source_ids requires a list of valid sample ids. ";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                                             method_name => 'get_expression_samples_external_source_ids');
    } 
 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '',
                           { RaiseError => 1, ShowErrorStatement => 1 }
        ); 
    my $get_samples_ex_id_q = qq^select id, externalSourceId from Sample where id in (^.
	join(",", ("?") x @{$sampleIDs}) . ") "; 
    my $get_samples_ex_id_qh = $dbh->prepare($get_samples_ex_id_q) or die "Unable to prepare : get_samples_ex_id_q : ".
        $get_samples_ex_id_q . " : " .$dbh->errstr(); 
    $get_samples_ex_id_qh->execute(@{$sampleIDs}) or die "Unable to execute : get_samples_ex_id_q : ".$get_samples_ex_id_qh->errstr();
    while (my ($sample_id, $ex_id) = $get_samples_ex_id_qh->fetchrow_array())
    { 
        $samplesExternalSourceIdMap->{$sample_id} = $ex_id;
    } 
    #END get_expression_samples_external_source_ids
    my @_bad_returns;
    (ref($samplesExternalSourceIdMap) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"samplesExternalSourceIdMap\" (value was \"$samplesExternalSourceIdMap\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_external_source_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_external_source_ids');
    }
    return($samplesExternalSourceIdMap);
}




=head2 get_expression_samples_original_log2_medians

  $samplesFloatMap = $obj->get_expression_samples_original_log2_medians($sampleIDs)

=over 4

=item Parameter and return types

=begin html

<pre>
$sampleIDs is a SampleIDs
$samplesFloatMap is a SamplesFloatMap
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string
SamplesFloatMap is a reference to a hash where the key is a SampleID and the value is a float

</pre>

=end html

=begin text

$sampleIDs is a SampleIDs
$samplesFloatMap is a SamplesFloatMap
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string
SamplesFloatMap is a reference to a hash where the key is a SampleID and the value is a float


=end text



=item Description

given a List of SampleIDs, returns a Hash (key : SampleID, value: OriginalLog2Median of Sample)

=back

=cut

sub get_expression_samples_original_log2_medians
{
    my $self = shift;
    my($sampleIDs) = @_;

    my @_bad_arguments;
    (ref($sampleIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"sampleIDs\" (value was \"$sampleIDs\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_samples_original_log2_medians:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_original_log2_medians');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($samplesFloatMap);
    #BEGIN get_expression_samples_original_log2_medians
    $samplesFloatMap = {}; 
    if (0 == @{$sampleIDs})
    { 
        my $msg = "get_expression_samples_original_log2_medians requires a list of valid sample ids. ";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                                             method_name => 'get_expression_samples_original_log2_medians');
    } 
 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 }
        ); 
    my $get_samples_olog2_q = qq^select id, originalLog2Median from Sample where id in (^.
	join(",", ("?") x @{$sampleIDs}) . ") ";
    my $get_samples_olog2_qh = $dbh->prepare($get_samples_olog2_q) or die "Unable to prepare : get_samples_olog2_q : ".
        $get_samples_olog2_q . " : " .$dbh->errstr();
    $get_samples_olog2_qh->execute(@{$sampleIDs}) or die "Unable to execute : get_samples_olog2_q : ".$get_samples_olog2_qh->errstr();
    while (my ($sample_id, $olog2) = $get_samples_olog2_qh->fetchrow_array()) 
    { 
        $samplesFloatMap->{$sample_id} = $olog2; 
    } 

    #END get_expression_samples_original_log2_medians
    my @_bad_returns;
    (ref($samplesFloatMap) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"samplesFloatMap\" (value was \"$samplesFloatMap\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_samples_original_log2_medians:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_samples_original_log2_medians');
    }
    return($samplesFloatMap);
}




=head2 get_expression_series_titles

  $seriesStringMap = $obj->get_expression_series_titles($seriesIDs)

=over 4

=item Parameter and return types

=begin html

<pre>
$seriesIDs is a SeriesIDs
$seriesStringMap is a SeriesStringMap
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
SeriesStringMap is a reference to a hash where the key is a SeriesID and the value is a string

</pre>

=end html

=begin text

$seriesIDs is a SeriesIDs
$seriesStringMap is a SeriesStringMap
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
SeriesStringMap is a reference to a hash where the key is a SeriesID and the value is a string


=end text



=item Description

given a List of SeriesIDs, returns a Hash (key : SeriesID, value: Title of Series)

=back

=cut

sub get_expression_series_titles
{
    my $self = shift;
    my($seriesIDs) = @_;

    my @_bad_arguments;
    (ref($seriesIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"seriesIDs\" (value was \"$seriesIDs\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_series_titles:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_series_titles');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($seriesStringMap);
    #BEGIN get_expression_series_titles
    $seriesStringMap = {}; 
    if (0 == @{$seriesIDs})
    { 
        my $msg = "get_expression_series_titles requires a list of valid series ids. ";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                                             method_name => 'get_expression_series_titles');
    } 
 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 }
        ); 
    my $get_series_info_q = qq^select id, title from Series where id in (^.
        join(",", ("?") x @{$seriesIDs}) . ") ";
    my $get_series_info_qh = $dbh->prepare($get_series_info_q) or die "Unable to prepare : get_series_info_q : ".
        $get_series_info_q . " : " .$dbh->errstr();
    $get_series_info_qh->execute(@{$seriesIDs}) or die "Unable to execute : get_series_info_q : ".$get_series_info_qh->errstr();
    while (my ($series_id, $info) = $get_series_info_qh->fetchrow_array()) 
    { 
        $seriesStringMap->{$series_id} = $info; 
    } 
    #END get_expression_series_titles
    my @_bad_returns;
    (ref($seriesStringMap) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"seriesStringMap\" (value was \"$seriesStringMap\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_series_titles:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_series_titles');
    }
    return($seriesStringMap);
}




=head2 get_expression_series_summaries

  $seriesStringMap = $obj->get_expression_series_summaries($seriesIDs)

=over 4

=item Parameter and return types

=begin html

<pre>
$seriesIDs is a SeriesIDs
$seriesStringMap is a SeriesStringMap
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
SeriesStringMap is a reference to a hash where the key is a SeriesID and the value is a string

</pre>

=end html

=begin text

$seriesIDs is a SeriesIDs
$seriesStringMap is a SeriesStringMap
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
SeriesStringMap is a reference to a hash where the key is a SeriesID and the value is a string


=end text



=item Description

given a List of SeriesIDs, returns a Hash (key : SeriesID, value: Summary of Series)

=back

=cut

sub get_expression_series_summaries
{
    my $self = shift;
    my($seriesIDs) = @_;

    my @_bad_arguments;
    (ref($seriesIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"seriesIDs\" (value was \"$seriesIDs\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_series_summaries:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_series_summaries');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($seriesStringMap);
    #BEGIN get_expression_series_summaries
    $seriesStringMap = {}; 
    if (0 == @{$seriesIDs})
    { 
        my $msg = "get_expression_series_summaries requires a list of valid series ids. ";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_series_summaries');
    } 
 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 }
        ); 
    my $get_series_info_q = qq^select id, summary from Series where id in (^.
        join(",", ("?") x @{$seriesIDs}) . ") ";
    my $get_series_info_qh = $dbh->prepare($get_series_info_q) or die "Unable to prepare : get_series_info_q : ".
        $get_series_info_q . " : " .$dbh->errstr();
    $get_series_info_qh->execute(@{$seriesIDs}) or die "Unable to execute : get_series_info_q : ".$get_series_info_qh->errstr();
    while (my ($series_id, $info) = $get_series_info_qh->fetchrow_array()) 
    { 
        $seriesStringMap->{$series_id} = $info; 
    } 
    #END get_expression_series_summaries
    my @_bad_returns;
    (ref($seriesStringMap) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"seriesStringMap\" (value was \"$seriesStringMap\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_series_summaries:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_series_summaries');
    }
    return($seriesStringMap);
}




=head2 get_expression_series_designs

  $seriesStringMap = $obj->get_expression_series_designs($seriesIDs)

=over 4

=item Parameter and return types

=begin html

<pre>
$seriesIDs is a SeriesIDs
$seriesStringMap is a SeriesStringMap
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
SeriesStringMap is a reference to a hash where the key is a SeriesID and the value is a string

</pre>

=end html

=begin text

$seriesIDs is a SeriesIDs
$seriesStringMap is a SeriesStringMap
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
SeriesStringMap is a reference to a hash where the key is a SeriesID and the value is a string


=end text



=item Description

given a List of SeriesIDs, returns a Hash (key : SeriesID, value: Design of Series)

=back

=cut

sub get_expression_series_designs
{
    my $self = shift;
    my($seriesIDs) = @_;

    my @_bad_arguments;
    (ref($seriesIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"seriesIDs\" (value was \"$seriesIDs\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_series_designs:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_series_designs');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($seriesStringMap);
    #BEGIN get_expression_series_designs
    $seriesStringMap = {}; 
    if (0 == @{$seriesIDs})
    { 
        my $msg = "get_expression_series_designs requires a list of valid series ids. ";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_series_designs');
    } 
 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 }
        ); 
    my $get_series_info_q = qq^select id, design from Series where id in (^.
        join(",", ("?") x @{$seriesIDs}) . ") ";
    my $get_series_info_qh = $dbh->prepare($get_series_info_q) or die "Unable to prepare : get_series_info_q : ".
        $get_series_info_q . " : " .$dbh->errstr();
    $get_series_info_qh->execute(@{$seriesIDs}) or die "Unable to execute : get_series_info_q : ".$get_series_info_qh->errstr();
    while (my ($series_id, $info) = $get_series_info_qh->fetchrow_array()) 
    { 
        $seriesStringMap->{$series_id} = $info; 
    } 
    #END get_expression_series_designs
    my @_bad_returns;
    (ref($seriesStringMap) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"seriesStringMap\" (value was \"$seriesStringMap\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_series_designs:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_series_designs');
    }
    return($seriesStringMap);
}




=head2 get_expression_series_external_source_ids

  $seriesStringMap = $obj->get_expression_series_external_source_ids($seriesIDs)

=over 4

=item Parameter and return types

=begin html

<pre>
$seriesIDs is a SeriesIDs
$seriesStringMap is a SeriesStringMap
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
SeriesStringMap is a reference to a hash where the key is a SeriesID and the value is a string

</pre>

=end html

=begin text

$seriesIDs is a SeriesIDs
$seriesStringMap is a SeriesStringMap
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string
SeriesStringMap is a reference to a hash where the key is a SeriesID and the value is a string


=end text



=item Description

given a List of SeriesIDs, returns a Hash (key : SeriesID, value: External_Source_ID of Series (typically GSE))

=back

=cut

sub get_expression_series_external_source_ids
{
    my $self = shift;
    my($seriesIDs) = @_;

    my @_bad_arguments;
    (ref($seriesIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"seriesIDs\" (value was \"$seriesIDs\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_series_external_source_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_series_external_source_ids');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($seriesStringMap);
    #BEGIN get_expression_series_external_source_ids
    $seriesStringMap = {}; 
    if (0 == @{$seriesIDs})
    { 
        my $msg = "get_expression_series_external_source_ids requires a list of valid series ids. ";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_series_external_source_ids');
    } 
 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 }
        ); 
    my $get_series_info_q = qq^select id, externalSourceId from Series where id in (^.
        join(",", ("?") x @{$seriesIDs}) . ") ";
    my $get_series_info_qh = $dbh->prepare($get_series_info_q) or die "Unable to prepare : get_series_info_q : ".
        $get_series_info_q . " : " .$dbh->errstr();
    $get_series_info_qh->execute(@{$seriesIDs}) or die "Unable to execute : get_series_info_q : ".$get_series_info_qh->errstr();
    while (my ($series_id, $info) = $get_series_info_qh->fetchrow_array()) 
    { 
        $seriesStringMap->{$series_id} = $info; 
    } 
    #END get_expression_series_external_source_ids
    my @_bad_returns;
    (ref($seriesStringMap) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"seriesStringMap\" (value was \"$seriesStringMap\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_series_external_source_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_series_external_source_ids');
    }
    return($seriesStringMap);
}




=head2 get_expression_sample_ids_by_sample_external_source_ids

  $sampleIDs = $obj->get_expression_sample_ids_by_sample_external_source_ids($ExternalSourceIDs)

=over 4

=item Parameter and return types

=begin html

<pre>
$ExternalSourceIDs is an ExternalSourceIDs
$sampleIDs is a SampleIDs
ExternalSourceIDs is a reference to a list where each element is an ExternalSourceID
ExternalSourceID is a string
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string

</pre>

=end html

=begin text

$ExternalSourceIDs is an ExternalSourceIDs
$sampleIDs is a SampleIDs
ExternalSourceIDs is a reference to a list where each element is an ExternalSourceID
ExternalSourceID is a string
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string


=end text



=item Description

get sample ids by the sample's external source id : Takes a list of sample external source ids, and returns a list of sample ids

=back

=cut

sub get_expression_sample_ids_by_sample_external_source_ids
{
    my $self = shift;
    my($ExternalSourceIDs) = @_;

    my @_bad_arguments;
    (ref($ExternalSourceIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"ExternalSourceIDs\" (value was \"$ExternalSourceIDs\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_sample_ids_by_sample_external_source_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_sample_external_source_ids');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($sampleIDs);
    #BEGIN get_expression_sample_ids_by_sample_external_source_ids
    my $external_source_ids = $ExternalSourceIDs;
    $sampleIDs = []; 
    if (0 == @{$external_source_ids}) 
    { 
        my $msg = "get_expression_sample_ids_by_sample_external_source_ids requires a list of valid external source ids for the sample.  ".
	    "These are typically GSM numbers. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							     method_name => 'get_expression_sample_ids_by_sample_external_source_ids');
    }
 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '',
                           { RaiseError => 1, ShowErrorStatement => 1 }
        ); 
    my $get_samples_q = qq^select id from Sample where externalSourceId in (^.
        join(",", ("?") x @{$external_source_ids}) . ") ";
    my $get_samples_qh = $dbh->prepare($get_samples_q) or die "Unable to prepare : get_samples_q : ". 
        $get_samples_q . " : " .$dbh->errstr(); 
    $get_samples_qh->execute(@{$external_source_ids}) or die "Unable to execute : get_samples_q : ".$get_samples_qh->errstr(); 
    while (my ($sample_id) = $get_samples_qh->fetchrow_array())
    {
	push(@{$sampleIDs},$sample_id);
    } 
    #END get_expression_sample_ids_by_sample_external_source_ids
    my @_bad_returns;
    (ref($sampleIDs) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"sampleIDs\" (value was \"$sampleIDs\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_sample_ids_by_sample_external_source_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_sample_external_source_ids');
    }
    return($sampleIDs);
}




=head2 get_expression_sample_ids_by_platform_external_source_ids

  $sampleIDs = $obj->get_expression_sample_ids_by_platform_external_source_ids($ExternalSourceIDs)

=over 4

=item Parameter and return types

=begin html

<pre>
$ExternalSourceIDs is an ExternalSourceIDs
$sampleIDs is a SampleIDs
ExternalSourceIDs is a reference to a list where each element is an ExternalSourceID
ExternalSourceID is a string
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string

</pre>

=end html

=begin text

$ExternalSourceIDs is an ExternalSourceIDs
$sampleIDs is a SampleIDs
ExternalSourceIDs is a reference to a list where each element is an ExternalSourceID
ExternalSourceID is a string
SampleIDs is a reference to a list where each element is a SampleID
SampleID is a string


=end text



=item Description

get sample ids by the platform's external source id : Takes a list of platform external source ids, and returns a list of sample ids

=back

=cut

sub get_expression_sample_ids_by_platform_external_source_ids
{
    my $self = shift;
    my($ExternalSourceIDs) = @_;

    my @_bad_arguments;
    (ref($ExternalSourceIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"ExternalSourceIDs\" (value was \"$ExternalSourceIDs\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_sample_ids_by_platform_external_source_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_platform_external_source_ids');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($sampleIDs);
    #BEGIN get_expression_sample_ids_by_platform_external_source_ids
    my $external_source_ids = $ExternalSourceIDs; 
    $sampleIDs = []; 
    if (0 == @{$external_source_ids}) 
    { 
        my $msg = "get_expression_sample_ids_by_platform_external_source_ids requires a list of valid external source ids for the platform.  ". 
            "These are typically GPL numbers. "; 
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'get_expression_sample_ids_by_platform_external_source_ids'); 
    } 
 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 } 
        ); 
    my $get_samples_q = qq^select s.id from Sample s inner join PlatformWithSamples ps on s.id = ps.to_link ^.
	                qq^inner join Platform p on p.id = ps.from_link where p.externalSourceId in (^. 
        join(",", ("?") x @{$external_source_ids}) . ") "; 
    my $get_samples_qh = $dbh->prepare($get_samples_q) or die "Unable to prepare : get_samples_q : ". 
        $get_samples_q . " : " .$dbh->errstr(); 
    $get_samples_qh->execute(@{$external_source_ids}) or die "Unable to execute : get_samples_q : ".$get_samples_qh->errstr(); 
    while (my ($sample_id) = $get_samples_qh->fetchrow_array()) 
    { 
        push(@{$sampleIDs},$sample_id); 
    } 
    #END get_expression_sample_ids_by_platform_external_source_ids
    my @_bad_returns;
    (ref($sampleIDs) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"sampleIDs\" (value was \"$sampleIDs\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_sample_ids_by_platform_external_source_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_sample_ids_by_platform_external_source_ids');
    }
    return($sampleIDs);
}




=head2 get_expression_series_ids_by_series_external_source_ids

  $seriesIDs = $obj->get_expression_series_ids_by_series_external_source_ids($ExternalSourceIDs)

=over 4

=item Parameter and return types

=begin html

<pre>
$ExternalSourceIDs is an ExternalSourceIDs
$seriesIDs is a SeriesIDs
ExternalSourceIDs is a reference to a list where each element is an ExternalSourceID
ExternalSourceID is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string

</pre>

=end html

=begin text

$ExternalSourceIDs is an ExternalSourceIDs
$seriesIDs is a SeriesIDs
ExternalSourceIDs is a reference to a list where each element is an ExternalSourceID
ExternalSourceID is a string
SeriesIDs is a reference to a list where each element is a SeriesID
SeriesID is a string


=end text



=item Description

get series ids by the series's external source id : Takes a list of series external source ids, and returns a list of series ids

=back

=cut

sub get_expression_series_ids_by_series_external_source_ids
{
    my $self = shift;
    my($ExternalSourceIDs) = @_;

    my @_bad_arguments;
    (ref($ExternalSourceIDs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"ExternalSourceIDs\" (value was \"$ExternalSourceIDs\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expression_series_ids_by_series_external_source_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_series_ids_by_series_external_source_ids');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($seriesIDs);
    #BEGIN get_expression_series_ids_by_series_external_source_ids
    my $external_source_ids = $ExternalSourceIDs; 
    $seriesIDs = []; 
    if (0 == @{$external_source_ids}) 
    { 
        my $msg = "get_expression_series_ids_by_series_external_source_ids requires a list of valid external source ids for the series.  ".
            "These are typically GSE numbers. ";
      Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg, 
                                                             method_name => 'get_expression_series_ids_by_series_external_source_ids');
    } 
 
    my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '', 
                           { RaiseError => 1, ShowErrorStatement => 1 } 
        ); 
    my $get_series_q = qq^select s.id from Series s where s.externalSourceId in (^.
			join(",", ("?") x @{$external_source_ids}) . ") ";
    my $get_series_qh = $dbh->prepare($get_series_q) or die "Unable to prepare : get_series_q : ".
        $get_series_q . " : " .$dbh->errstr(); 
    $get_series_qh->execute(@{$external_source_ids}) or die "Unable to execute : get_series_q : ".$get_series_qh->errstr(); 
    while (my ($series_id) = $get_series_qh->fetchrow_array()) 
    { 
        push(@{$seriesIDs},$series_id); 
    } 
    #END get_expression_series_ids_by_series_external_source_ids
    my @_bad_returns;
    (ref($seriesIDs) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"seriesIDs\" (value was \"$seriesIDs\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expression_series_ids_by_series_external_source_ids:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expression_series_ids_by_series_external_source_ids');
    }
    return($seriesIDs);
}




=head2 get_GEO_GSE

  $gseObject = $obj->get_GEO_GSE($gse_input_id, $metaDataOnly)

=over 4

=item Parameter and return types

=begin html

<pre>
$gse_input_id is a string
$metaDataOnly is a MetaDataOnly
$gseObject is a GseObject
MetaDataOnly is an int
GseObject is a reference to a hash where the following keys are defined:
	gseID has a value which is a string
	gseTitle has a value which is a string
	gseSummary has a value which is a string
	gseDesign has a value which is a string
	gseSubmissionDate has a value which is a string
	pubMedID has a value which is a string
	gseSamples has a value which is a GseSamples
	gseWarnings has a value which is a GseWarnings
	gseErrors has a value which is a GseErrors
GseSamples is a reference to a hash where the key is a string and the value is a GsmObject
GsmObject is a reference to a hash where the following keys are defined:
	gsmID has a value which is a string
	gsmTitle has a value which is a string
	gsmDescription has a value which is a string
	gsmMolecule has a value which is a string
	gsmSubmissionDate has a value which is a string
	gsmTaxID has a value which is a string
	gsmSampleOrganism has a value which is a string
	gsmSampleCharacteristics has a value which is a GsmSampleCharacteristics
	gsmProtocol has a value which is a string
	gsmValueType has a value which is a string
	gsmOriginalLog2Median has a value which is a float
	gsmPlatform has a value which is a GPL
	gsmContactPeople has a value which is a ContactPeople
	gsmData has a value which is a GsmData
	gsmFeatureMappingApproach has a value which is a string
	gsmWarning has a value which is a GsmWarnings
	gsmErrors has a value which is a GsmErrors
GsmSampleCharacteristics is a reference to a list where each element is a string
GPL is a reference to a hash where the following keys are defined:
	gplID has a value which is a string
	gplTitle has a value which is a string
	gplTechnology has a value which is a string
	gplTaxID has a value which is a string
	gplOrganism has a value which is a string
ContactPeople is a reference to a hash where the key is a ContactEmail and the value is a ContactPerson
ContactEmail is a string
ContactPerson is a reference to a hash where the following keys are defined:
	contactFirstName has a value which is a ContactFirstName
	contactLastName has a value which is a ContactLastName
	contactInstitution has a value which is a ContactInstitution
ContactFirstName is a string
ContactLastName is a string
ContactInstitution is a string
GsmData is a reference to a hash where the key is a FeatureID and the value is a FullMeasurement
FeatureID is a string
FullMeasurement is a reference to a hash where the following keys are defined:
	value has a value which is a float
	N has a value which is a float
	stddev has a value which is a float
	Z_score has a value which is a float
	p_value has a value which is a float
	median has a value which is a float
	mean has a value which is a float
GsmWarnings is a reference to a list where each element is a string
GsmErrors is a reference to a list where each element is a string
GseWarnings is a reference to a list where each element is a string
GseErrors is a reference to a list where each element is a string

</pre>

=end html

=begin text

$gse_input_id is a string
$metaDataOnly is a MetaDataOnly
$gseObject is a GseObject
MetaDataOnly is an int
GseObject is a reference to a hash where the following keys are defined:
	gseID has a value which is a string
	gseTitle has a value which is a string
	gseSummary has a value which is a string
	gseDesign has a value which is a string
	gseSubmissionDate has a value which is a string
	pubMedID has a value which is a string
	gseSamples has a value which is a GseSamples
	gseWarnings has a value which is a GseWarnings
	gseErrors has a value which is a GseErrors
GseSamples is a reference to a hash where the key is a string and the value is a GsmObject
GsmObject is a reference to a hash where the following keys are defined:
	gsmID has a value which is a string
	gsmTitle has a value which is a string
	gsmDescription has a value which is a string
	gsmMolecule has a value which is a string
	gsmSubmissionDate has a value which is a string
	gsmTaxID has a value which is a string
	gsmSampleOrganism has a value which is a string
	gsmSampleCharacteristics has a value which is a GsmSampleCharacteristics
	gsmProtocol has a value which is a string
	gsmValueType has a value which is a string
	gsmOriginalLog2Median has a value which is a float
	gsmPlatform has a value which is a GPL
	gsmContactPeople has a value which is a ContactPeople
	gsmData has a value which is a GsmData
	gsmFeatureMappingApproach has a value which is a string
	gsmWarning has a value which is a GsmWarnings
	gsmErrors has a value which is a GsmErrors
GsmSampleCharacteristics is a reference to a list where each element is a string
GPL is a reference to a hash where the following keys are defined:
	gplID has a value which is a string
	gplTitle has a value which is a string
	gplTechnology has a value which is a string
	gplTaxID has a value which is a string
	gplOrganism has a value which is a string
ContactPeople is a reference to a hash where the key is a ContactEmail and the value is a ContactPerson
ContactEmail is a string
ContactPerson is a reference to a hash where the following keys are defined:
	contactFirstName has a value which is a ContactFirstName
	contactLastName has a value which is a ContactLastName
	contactInstitution has a value which is a ContactInstitution
ContactFirstName is a string
ContactLastName is a string
ContactInstitution is a string
GsmData is a reference to a hash where the key is a FeatureID and the value is a FullMeasurement
FeatureID is a string
FullMeasurement is a reference to a hash where the following keys are defined:
	value has a value which is a float
	N has a value which is a float
	stddev has a value which is a float
	Z_score has a value which is a float
	p_value has a value which is a float
	median has a value which is a float
	mean has a value which is a float
GsmWarnings is a reference to a list where each element is a string
GsmErrors is a reference to a list where each element is a string
GseWarnings is a reference to a list where each element is a string
GseErrors is a reference to a list where each element is a string


=end text



=item Description

given a GEO GSE ID and a flag (1 = MetaDataOnly, 0 = IncludeData), it will return a complex data structure to be put into the upload tab files

=back

=cut

sub get_GEO_GSE
{
    my $self = shift;
    my($gse_input_id, $metaDataOnly) = @_;

    my @_bad_arguments;
    (!ref($gse_input_id)) or push(@_bad_arguments, "Invalid type for argument \"gse_input_id\" (value was \"$gse_input_id\")");
    (!ref($metaDataOnly)) or push(@_bad_arguments, "Invalid type for argument \"metaDataOnly\" (value was \"$metaDataOnly\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_GEO_GSE:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_GEO_GSE');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($gseObject);
    #BEGIN get_GEO_GSE
    $gseObject ={};

    # create new functionsForGEO
    my $functionsForGEO = Bio::KBase::ExpressionServices::FunctionsForGEO->new();
print "FUNCTIONS FOR GEO NEW : ". Dumper($functionsForGEO);
    $gseObject = $functionsForGEO->get_GEO_GSE_data($gse_input_id,1);
    #END get_GEO_GSE
    my @_bad_returns;
    (ref($gseObject) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"gseObject\" (value was \"$gseObject\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_GEO_GSE:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_GEO_GSE');
    }
    return($gseObject);
}




=head2 get_GEO_GSM

  $gsmObject = $obj->get_GEO_GSM($gsm_input_id, $metaDataOnly)

=over 4

=item Parameter and return types

=begin html

<pre>
$gsm_input_id is a string
$metaDataOnly is a MetaDataOnly
$gsmObject is a GsmObject
MetaDataOnly is an int
GsmObject is a reference to a hash where the following keys are defined:
	gsmID has a value which is a string
	gsmTitle has a value which is a string
	gsmDescription has a value which is a string
	gsmMolecule has a value which is a string
	gsmSubmissionDate has a value which is a string
	gsmTaxID has a value which is a string
	gsmSampleOrganism has a value which is a string
	gsmSampleCharacteristics has a value which is a GsmSampleCharacteristics
	gsmProtocol has a value which is a string
	gsmValueType has a value which is a string
	gsmOriginalLog2Median has a value which is a float
	gsmPlatform has a value which is a GPL
	gsmContactPeople has a value which is a ContactPeople
	gsmData has a value which is a GsmData
	gsmFeatureMappingApproach has a value which is a string
	gsmWarning has a value which is a GsmWarnings
	gsmErrors has a value which is a GsmErrors
GsmSampleCharacteristics is a reference to a list where each element is a string
GPL is a reference to a hash where the following keys are defined:
	gplID has a value which is a string
	gplTitle has a value which is a string
	gplTechnology has a value which is a string
	gplTaxID has a value which is a string
	gplOrganism has a value which is a string
ContactPeople is a reference to a hash where the key is a ContactEmail and the value is a ContactPerson
ContactEmail is a string
ContactPerson is a reference to a hash where the following keys are defined:
	contactFirstName has a value which is a ContactFirstName
	contactLastName has a value which is a ContactLastName
	contactInstitution has a value which is a ContactInstitution
ContactFirstName is a string
ContactLastName is a string
ContactInstitution is a string
GsmData is a reference to a hash where the key is a FeatureID and the value is a FullMeasurement
FeatureID is a string
FullMeasurement is a reference to a hash where the following keys are defined:
	value has a value which is a float
	N has a value which is a float
	stddev has a value which is a float
	Z_score has a value which is a float
	p_value has a value which is a float
	median has a value which is a float
	mean has a value which is a float
GsmWarnings is a reference to a list where each element is a string
GsmErrors is a reference to a list where each element is a string

</pre>

=end html

=begin text

$gsm_input_id is a string
$metaDataOnly is a MetaDataOnly
$gsmObject is a GsmObject
MetaDataOnly is an int
GsmObject is a reference to a hash where the following keys are defined:
	gsmID has a value which is a string
	gsmTitle has a value which is a string
	gsmDescription has a value which is a string
	gsmMolecule has a value which is a string
	gsmSubmissionDate has a value which is a string
	gsmTaxID has a value which is a string
	gsmSampleOrganism has a value which is a string
	gsmSampleCharacteristics has a value which is a GsmSampleCharacteristics
	gsmProtocol has a value which is a string
	gsmValueType has a value which is a string
	gsmOriginalLog2Median has a value which is a float
	gsmPlatform has a value which is a GPL
	gsmContactPeople has a value which is a ContactPeople
	gsmData has a value which is a GsmData
	gsmFeatureMappingApproach has a value which is a string
	gsmWarning has a value which is a GsmWarnings
	gsmErrors has a value which is a GsmErrors
GsmSampleCharacteristics is a reference to a list where each element is a string
GPL is a reference to a hash where the following keys are defined:
	gplID has a value which is a string
	gplTitle has a value which is a string
	gplTechnology has a value which is a string
	gplTaxID has a value which is a string
	gplOrganism has a value which is a string
ContactPeople is a reference to a hash where the key is a ContactEmail and the value is a ContactPerson
ContactEmail is a string
ContactPerson is a reference to a hash where the following keys are defined:
	contactFirstName has a value which is a ContactFirstName
	contactLastName has a value which is a ContactLastName
	contactInstitution has a value which is a ContactInstitution
ContactFirstName is a string
ContactLastName is a string
ContactInstitution is a string
GsmData is a reference to a hash where the key is a FeatureID and the value is a FullMeasurement
FeatureID is a string
FullMeasurement is a reference to a hash where the following keys are defined:
	value has a value which is a float
	N has a value which is a float
	stddev has a value which is a float
	Z_score has a value which is a float
	p_value has a value which is a float
	median has a value which is a float
	mean has a value which is a float
GsmWarnings is a reference to a list where each element is a string
GsmErrors is a reference to a list where each element is a string


=end text



=item Description

given a GEO GSM ID and a flag (1 = MetaDataOnly, 0 = IncludeData), it will return a complex data structure to be put into the upload tab files

=back

=cut

sub get_GEO_GSM
{
    my $self = shift;
    my($gsm_input_id, $metaDataOnly) = @_;

    my @_bad_arguments;
    (!ref($gsm_input_id)) or push(@_bad_arguments, "Invalid type for argument \"gsm_input_id\" (value was \"$gsm_input_id\")");
    (!ref($metaDataOnly)) or push(@_bad_arguments, "Invalid type for argument \"metaDataOnly\" (value was \"$metaDataOnly\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_GEO_GSM:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_GEO_GSM');
    }

    my $ctx = $Bio::KBase::ExpressionServices::Service::CallContext;
    my($gsmObject);
    #BEGIN get_GEO_GSM
    #END get_GEO_GSM
    my @_bad_returns;
    (ref($gsmObject) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"gsmObject\" (value was \"$gsmObject\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_GEO_GSM:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_GEO_GSM');
    }
    return($gsmObject);
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



=head2 Measurement

=over 4



=item Description

Measurement Value (Zero median normalized within a sample) for a given feature


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



=head2 SampleIDsAveragedFrom

=over 4



=item Description

List of KBase Sample IDs thatt his sample was averaged from


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

Kbase Series ID


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

list of KBase Series IDs


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

Kbase ExperimentMeta ID


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

list of KBase ExperimentMeta IDs


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

Kbase ExperimentalUnitID


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

list of KBase ExperimentalUnitIDs


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



=head2 SamplesStringMap

=over 4



=item Description

Mapping between sample id and corresponding value.   Used as return for get_expression_samples_(titles,descriptions,molecules,types,external_source_ids)


=item Definition

=begin html

<pre>
a reference to a hash where the key is a SampleID and the value is a string
</pre>

=end html

=begin text

a reference to a hash where the key is a SampleID and the value is a string

=end text

=back



=head2 SamplesFloatMap

=over 4



=item Description

Mapping between sample id and corresponding value.   Used as return for get_expression_samples_original_log2_median


=item Definition

=begin html

<pre>
a reference to a hash where the key is a SampleID and the value is a float
</pre>

=end html

=begin text

a reference to a hash where the key is a SampleID and the value is a float

=end text

=back



=head2 SeriesStringMap

=over 4



=item Description

Mapping between sample id and corresponding value.   Used as return for get_series_(titles,summaries,designs,external_source_ids)


=item Definition

=begin html

<pre>
a reference to a hash where the key is a SeriesID and the value is a string
</pre>

=end html

=begin text

a reference to a hash where the key is a SeriesID and the value is a string

=end text

=back



=head2 DataExpressionLevelsForSample

=over 4



=item Description

mapping kbase feature id as the key and measurement as the value


=item Definition

=begin html

<pre>
a reference to a hash where the key is a FeatureID and the value is a Measurement
</pre>

=end html

=begin text

a reference to a hash where the key is a FeatureID and the value is a Measurement

=end text

=back



=head2 LabelDataMapping

=over 4



=item Description

Mapping from Label (often a sample id, but free text to identify} to DataExpressionLevelsForSample


=item Definition

=begin html

<pre>
a reference to a hash where the key is a string and the value is a DataExpressionLevelsForSample
</pre>

=end html

=begin text

a reference to a hash where the key is a string and the value is a DataExpressionLevelsForSample

=end text

=back



=head2 ComparisonDenominatorLabel

=over 4



=item Description

denominator label is the label for the denominator in a comparison.  
This label can be a single sampleId (default or defined) or a comma separated list of sampleIds that were averaged.


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



=head2 Log2Ratio

=over 4



=item Description

Log2Ratio Log2Level of sample over log2Level of another sample for a given feature.  
Note if the Ratio is consumed by On Off Call function it will have 1(on), 0(unknown), -1(off) for its values


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



=head2 DataSampleComparison

=over 4



=item Description

mapping kbase feature id as the key and log2Ratio as the value


=item Definition

=begin html

<pre>
a reference to a hash where the key is a FeatureID and the value is a Log2Ratio
</pre>

=end html

=begin text

a reference to a hash where the key is a FeatureID and the value is a Log2Ratio

=end text

=back



=head2 DenominatorSampleComparison

=over 4



=item Description

mapping ComparisonDenominatorLabel to DataSampleComparison mapping


=item Definition

=begin html

<pre>
a reference to a hash where the key is a ComparisonDenominatorLabel and the value is a DataSampleComparison
</pre>

=end html

=begin text

a reference to a hash where the key is a ComparisonDenominatorLabel and the value is a DataSampleComparison

=end text

=back



=head2 SampleComparisonMapping

=over 4



=item Description

mapping Sample Id for the numerator to a DenominatorSampleComparison.  This is the comparison data structure {NumeratorSampleId->{denominatorLabel -> {feature -> log2ratio}}}


=item Definition

=begin html

<pre>
a reference to a hash where the key is a SampleID and the value is a DenominatorSampleComparison
</pre>

=end html

=begin text

a reference to a hash where the key is a SampleID and the value is a DenominatorSampleComparison

=end text

=back



=head2 SampleAnnotationID

=over 4



=item Description

Kbase SampleAnnotation ID


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



=head2 OntologyID

=over 4



=item Description

Kbase OntologyID


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



=head2 OntologyIDs

=over 4



=item Description

list of Kbase Ontology IDs


=item Definition

=begin html

<pre>
a reference to a list where each element is an OntologyID
</pre>

=end html

=begin text

a reference to a list where each element is an OntologyID

=end text

=back



=head2 OntologyName

=over 4



=item Description

Kbase OntologyName


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



=head2 OntologyDefinition

=over 4



=item Description

Kbase OntologyDefinition


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



=head2 SampleAnnotation

=over 4



=item Description

Data structure for top level information for sample annotation and ontology


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
sampleAnnotationID has a value which is a SampleAnnotationID
ontologyID has a value which is an OntologyID
ontologyName has a value which is an OntologyName
ontologyDefinition has a value which is an OntologyDefinition

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
sampleAnnotationID has a value which is a SampleAnnotationID
ontologyID has a value which is an OntologyID
ontologyName has a value which is an OntologyName
ontologyDefinition has a value which is an OntologyDefinition


=end text

=back



=head2 SampleAnnotations

=over 4



=item Description

list of Sample Annotations associated with the Sample


=item Definition

=begin html

<pre>
a reference to a list where each element is a SampleAnnotation
</pre>

=end html

=begin text

a reference to a list where each element is a SampleAnnotation

=end text

=back



=head2 ExternalSourceID

=over 4



=item Description

externalSourceId (could be for Platform, Sample or Series)(typically maps to a GPL, GSM or GSE from GEO)


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



=head2 ExternalSourceIDs

=over 4



=item Description

list of externalSourceIDs


=item Definition

=begin html

<pre>
a reference to a list where each element is an ExternalSourceID
</pre>

=end html

=begin text

a reference to a list where each element is an ExternalSourceID

=end text

=back



=head2 PersonID

=over 4



=item Description

Kbase Person ID


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

list of KBase PersonsIDs


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

KBase StrainID


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

list of KBase StrainIDs


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

KBase GenomeID


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

list of KBase GenomeIDs


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

Data structure for all the top level metadata and value data for an expression sample.  Essentially a expression Sample object.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
sampleID has a value which is a SampleID
sourceID has a value which is a string
sampleTitle has a value which is a string
sampleDescription has a value which is a string
molecule has a value which is a string
sampleType has a value which is a SampleType
dataSource has a value which is a string
externalSourceID has a value which is a string
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
platformID has a value which is a string
platformTitle has a value which is a string
platformTechnology has a value which is a string
experimentalUnitID has a value which is an ExperimentalUnitID
experimentMetaID has a value which is an ExperimentMetaID
experimentTitle has a value which is a string
experimentDescription has a value which is a string
environmentID has a value which is a string
environmentDescription has a value which is a string
protocolID has a value which is a string
protocolDescription has a value which is a string
protocolName has a value which is a string
sampleAnnotations has a value which is a SampleAnnotations
seriesIDs has a value which is a SeriesIDs
personIDs has a value which is a PersonIDs
sampleIDsAveragedFrom has a value which is a SampleIDsAveragedFrom
dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
sampleID has a value which is a SampleID
sourceID has a value which is a string
sampleTitle has a value which is a string
sampleDescription has a value which is a string
molecule has a value which is a string
sampleType has a value which is a SampleType
dataSource has a value which is a string
externalSourceID has a value which is a string
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
platformID has a value which is a string
platformTitle has a value which is a string
platformTechnology has a value which is a string
experimentalUnitID has a value which is an ExperimentalUnitID
experimentMetaID has a value which is an ExperimentMetaID
experimentTitle has a value which is a string
experimentDescription has a value which is a string
environmentID has a value which is a string
environmentDescription has a value which is a string
protocolID has a value which is a string
protocolDescription has a value which is a string
protocolName has a value which is a string
sampleAnnotations has a value which is a SampleAnnotations
seriesIDs has a value which is a SeriesIDs
personIDs has a value which is a PersonIDs
sampleIDsAveragedFrom has a value which is a SampleIDsAveragedFrom
dataExpressionLevelsForSample has a value which is a DataExpressionLevelsForSample


=end text

=back



=head2 ExpressionDataSamplesMap

=over 4



=item Description

Mapping between sampleID and ExpressionDataSample


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

mapping between seriesIDs and all Samples it contains


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

mapping between experimentalUnitIDs and all Samples it contains


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

mapping between experimentMetaIDs and ExperimentalUnitExpressionDataSamplesMapping it contains


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

mapping between strainIDs and all Samples it contains


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

mapping between genomeIDs and all StrainExpressionDataSamplesMapping it contains


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



=head2 OntologyExpressionDataSampleMapping

=over 4



=item Description

mapping between ontologyIDs (concatenated if searched for with the and operator) and all the Samples that match that term(s)


=item Definition

=begin html

<pre>
a reference to a hash where the key is an OntologyID and the value is an ExpressionDataSamplesMap
</pre>

=end html

=begin text

a reference to a hash where the key is an OntologyID and the value is an ExpressionDataSamplesMap

=end text

=back



=head2 SampleMeasurementMapping

=over 4



=item Description

mapping kbase sample id as the key and a single measurement (for a scpecified feature id, one mapping higher) as the value


=item Definition

=begin html

<pre>
a reference to a hash where the key is a SampleID and the value is a Measurement
</pre>

=end html

=begin text

a reference to a hash where the key is a SampleID and the value is a Measurement

=end text

=back



=head2 FeatureSampleMeasurementMapping

=over 4



=item Description

mapping between FeatureIds and the mappings between samples and log2level mapping


=item Definition

=begin html

<pre>
a reference to a hash where the key is a FeatureID and the value is a SampleMeasurementMapping
</pre>

=end html

=begin text

a reference to a hash where the key is a FeatureID and the value is a SampleMeasurementMapping

=end text

=back



=head2 GPL

=over 4



=item Description

Data structure for a GEO Platform


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
gplID has a value which is a string
gplTitle has a value which is a string
gplTechnology has a value which is a string
gplTaxID has a value which is a string
gplOrganism has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
gplID has a value which is a string
gplTitle has a value which is a string
gplTechnology has a value which is a string
gplTaxID has a value which is a string
gplOrganism has a value which is a string


=end text

=back



=head2 ContactEmail

=over 4



=item Description

Email for the GSM contact person


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



=head2 ContactFirstName

=over 4



=item Description

First Name of GSM contact person


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



=head2 ContactLastName

=over 4



=item Description

Last Name of GSM contact person


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



=head2 ContactInstitution

=over 4



=item Description

Institution of GSM contact person


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



=head2 ContactPerson

=over 4



=item Description

Data structure for GSM ContactPerson


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
contactFirstName has a value which is a ContactFirstName
contactLastName has a value which is a ContactLastName
contactInstitution has a value which is a ContactInstitution

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
contactFirstName has a value which is a ContactFirstName
contactLastName has a value which is a ContactLastName
contactInstitution has a value which is a ContactInstitution


=end text

=back



=head2 ContactPeople

=over 4



=item Description

Mapping between key : ContactEmail and value : ContactPerson Data Structure


=item Definition

=begin html

<pre>
a reference to a hash where the key is a ContactEmail and the value is a ContactPerson
</pre>

=end html

=begin text

a reference to a hash where the key is a ContactEmail and the value is a ContactPerson

=end text

=back



=head2 FullMeasurement

=over 4



=item Description

Measurement data structure


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
value has a value which is a float
N has a value which is a float
stddev has a value which is a float
Z_score has a value which is a float
p_value has a value which is a float
median has a value which is a float
mean has a value which is a float

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
value has a value which is a float
N has a value which is a float
stddev has a value which is a float
Z_score has a value which is a float
p_value has a value which is a float
median has a value which is a float
mean has a value which is a float


=end text

=back



=head2 GsmData

=over 4



=item Description

mapping kbase feature id as the key and FullMeasurement Structure as the value


=item Definition

=begin html

<pre>
a reference to a hash where the key is a FeatureID and the value is a FullMeasurement
</pre>

=end html

=begin text

a reference to a hash where the key is a FeatureID and the value is a FullMeasurement

=end text

=back



=head2 GsmWarnings

=over 4



=item Description

List of GSM level warnings


=item Definition

=begin html

<pre>
a reference to a list where each element is a string
</pre>

=end html

=begin text

a reference to a list where each element is a string

=end text

=back



=head2 GseWarnings

=over 4



=item Description

List of GSE level warnings


=item Definition

=begin html

<pre>
a reference to a list where each element is a string
</pre>

=end html

=begin text

a reference to a list where each element is a string

=end text

=back



=head2 GsmErrors

=over 4



=item Description

List of GSM level errors


=item Definition

=begin html

<pre>
a reference to a list where each element is a string
</pre>

=end html

=begin text

a reference to a list where each element is a string

=end text

=back



=head2 GseErrors

=over 4



=item Description

List of GSE level errors


=item Definition

=begin html

<pre>
a reference to a list where each element is a string
</pre>

=end html

=begin text

a reference to a list where each element is a string

=end text

=back



=head2 GsmSampleCharacteristics

=over 4



=item Description

List of GSM Sample Characteristics from ch1


=item Definition

=begin html

<pre>
a reference to a list where each element is a string
</pre>

=end html

=begin text

a reference to a list where each element is a string

=end text

=back



=head2 GsmObject

=over 4



=item Description

GSM OBJECT


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
gsmID has a value which is a string
gsmTitle has a value which is a string
gsmDescription has a value which is a string
gsmMolecule has a value which is a string
gsmSubmissionDate has a value which is a string
gsmTaxID has a value which is a string
gsmSampleOrganism has a value which is a string
gsmSampleCharacteristics has a value which is a GsmSampleCharacteristics
gsmProtocol has a value which is a string
gsmValueType has a value which is a string
gsmOriginalLog2Median has a value which is a float
gsmPlatform has a value which is a GPL
gsmContactPeople has a value which is a ContactPeople
gsmData has a value which is a GsmData
gsmFeatureMappingApproach has a value which is a string
gsmWarning has a value which is a GsmWarnings
gsmErrors has a value which is a GsmErrors

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
gsmID has a value which is a string
gsmTitle has a value which is a string
gsmDescription has a value which is a string
gsmMolecule has a value which is a string
gsmSubmissionDate has a value which is a string
gsmTaxID has a value which is a string
gsmSampleOrganism has a value which is a string
gsmSampleCharacteristics has a value which is a GsmSampleCharacteristics
gsmProtocol has a value which is a string
gsmValueType has a value which is a string
gsmOriginalLog2Median has a value which is a float
gsmPlatform has a value which is a GPL
gsmContactPeople has a value which is a ContactPeople
gsmData has a value which is a GsmData
gsmFeatureMappingApproach has a value which is a string
gsmWarning has a value which is a GsmWarnings
gsmErrors has a value which is a GsmErrors


=end text

=back



=head2 GseSamples

=over 4



=item Description

Mapping of Key GSMID to GSM Object


=item Definition

=begin html

<pre>
a reference to a hash where the key is a string and the value is a GsmObject
</pre>

=end html

=begin text

a reference to a hash where the key is a string and the value is a GsmObject

=end text

=back



=head2 GseObject

=over 4



=item Description

GSE OBJECT


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
gseID has a value which is a string
gseTitle has a value which is a string
gseSummary has a value which is a string
gseDesign has a value which is a string
gseSubmissionDate has a value which is a string
pubMedID has a value which is a string
gseSamples has a value which is a GseSamples
gseWarnings has a value which is a GseWarnings
gseErrors has a value which is a GseErrors

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
gseID has a value which is a string
gseTitle has a value which is a string
gseSummary has a value which is a string
gseDesign has a value which is a string
gseSubmissionDate has a value which is a string
pubMedID has a value which is a string
gseSamples has a value which is a GseSamples
gseWarnings has a value which is a GseWarnings
gseErrors has a value which is a GseErrors


=end text

=back



=head2 MetaDataOnly

=over 4



=item Description

Single integer 1= metaDataOnly, 0 means returns data


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



=cut

1;
