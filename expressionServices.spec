module ExpressionServices { 

    /* KBase Feature ID for a feature, typically CDS/PEG */
    typedef string FeatureID;
    
    /* KBase list of Feature IDs , typically CDS/PEG */
    typedef list<FeatureID> FeatureIDs;
    
    /* Measurement Value (Zero median normalized within a sample) for a given feature */
    typedef float Measurement;
    
    /* KBase Sample ID for the sample */
    typedef string SampleID;
    
    /* List of KBase Sample IDs */
    typedef list<SampleID> SampleIDs;

    /* List of KBase Sample IDs thatt his sample was averaged from */
    typedef list<SampleID> SampleIDsAveragedFrom;
    
    /* Sample type controlled vocabulary : microarray, RNA-Seq, qPCR, or proteomics */
    typedef string SampleType;
    
    /* Kbase Series ID */ 
    typedef string SeriesID; 
    
    /* list of KBase Series IDs */
    typedef list<SeriesID> SeriesIDs;
    
    /* Kbase ExperimentMeta ID */ 
    typedef string ExperimentMetaID; 
    
    /* list of KBase ExperimentMeta IDs */
    typedef list<ExperimentMetaID> ExperimentMetaIDs;
    
    /* Kbase ExperimentalUnitID */ 
    typedef string ExperimentalUnitID; 
    
    /* list of KBase ExperimentalUnitIDs */
    typedef list<ExperimentalUnitID> ExperimentalUnitIDs;
    
    /* Mapping between sample id and corresponding value.   Used as return for get_expression_samples_(titles,descriptions,molecules,types,external_source_ids)*/
    typedef mapping<SampleID sampleID, string value> SamplesStringMap;

    /* Mapping between sample id and corresponding value.   Used as return for get_expression_samples_original_log2_median*/ 
    typedef mapping<SampleID sampleID, float originalLog2Median> SamplesFloatMap;

    /* Mapping between sample id and corresponding value.   Used as return for get_series_(titles,summaries,designs,external_source_ids)*/ 
    typedef mapping<SeriesID seriesID, string value> SeriesStringMap; 

    /* mapping kbase feature id as the key and measurement as the value */
    typedef mapping<FeatureID featureID, Measurement measurement> DataExpressionLevelsForSample; 

    /*Mapping from Label (often a sample id, but free text to identify} to DataExpressionLevelsForSample */
    typedef mapping<string label, DataExpressionLevelsForSample dataExpressionLevelsForSample> LabelDataMapping;

    /* denominator label is the label for the denominator in a comparison.  
    This label can be a single sampleId (default or defined) or a comma separated list of sampleIds that were averaged.*/
    typedef string ComparisonDenominatorLabel;

    /* Log2Ratio Log2Level of sample over log2Level of another sample for a given feature.  
    Note if the Ratio is consumed by On Off Call function it will have 1(on), 0(unknown), -1(off) for its values */ 
    typedef float Log2Ratio; 

    /* mapping kbase feature id as the key and log2Ratio as the value */ 
    typedef mapping<FeatureID featureID, Log2Ratio log2Ratio> DataSampleComparison; 

    /* mapping ComparisonDenominatorLabel to DataSampleComparison mapping */
    typedef mapping<ComparisonDenominatorLabel comparisonDenominatorLabel, DataSampleComparison dataSampleComparison> DenominatorSampleComparison;

    /* mapping Sample Id for the numerator to a DenominatorSampleComparison.  This is the comparison data structure {NumeratorSampleId->{denominatorLabel -> {feature -> log2ratio}}} */
    typedef mapping<SampleID sampleID, DenominatorSampleComparison denominatorSampleComparison> SampleComparisonMapping;

    /* Kbase SampleAnnotation ID */ 
    typedef string SampleAnnotationID; 
 
    /* Kbase OntologyID  */ 
    typedef string OntologyID; 
    
    /* list of Kbase Ontology IDs */
    typedef list<OntologyID> OntologyIDs;

    /* Kbase OntologyName */
    typedef string OntologyName;

    /* Kbase OntologyDefinition */
    typedef string OntologyDefinition;

    /* Data structure for top level information for sample annotation and ontology */
    typedef structure {
	SampleAnnotationID sampleAnnotationID;
	OntologyID ontologyID;
	OntologyName ontologyName;
	OntologyDefinition ontologyDefinition;
    } SampleAnnotation;
    
    /* list of Sample Annotations associated with the Sample */
    typedef list<SampleAnnotation> SampleAnnotations;

    /* externalSourceId (could be for Platform, Sample or Series)(typically maps to a GPL, GSM or GSE from GEO) */
    typedef string ExternalSourceID;

    /* list of externalSourceIDs */
    typedef list<ExternalSourceID> ExternalSourceIDs;

    /* Kbase Person ID */ 
    typedef string PersonID; 
    
    /* list of KBase PersonsIDs */
    typedef list<PersonID> PersonIDs;
    
    /* KBase StrainID */
    typedef string StrainID;
    
    /* list of KBase StrainIDs */
    typedef list<StrainID> StrainIDs;
    
    /* KBase GenomeID */
    typedef string GenomeID;
    
    /* list of KBase GenomeIDs */
    typedef list<GenomeID> GenomeIDs;
    
    /* Single integer 1= WildTypeonly, 0 means all strains ok */
    typedef int WildTypeOnly;
    
    /* Data structure for all the top level metadata and value data for an expression sample.  Essentially a expression Sample object.*/
    typedef structure {
	SampleID sampleID;
	string sourceID;
	string sampleTitle;
	string sampleDescription;
	string molecule;
	SampleType sampleType;
	string dataSource;
	string externalSourceID;
	string externalSourceDate;
	string kbaseSubmissionDate;
	string custom;
	float originalLog2Median;
	StrainID strainID;
	string referenceStrain;
	string wildtype;
	string strainDescription;
	GenomeID genomeID;
	string genomeScientificName;
	string platformID;
	string platformTitle;
	string platformTechnology;
	ExperimentalUnitID experimentalUnitID;
	ExperimentMetaID experimentMetaID;
	string experimentTitle;
	string experimentDescription;
	string environmentID;
	string environmentDescription;
	string protocolID;
	string protocolDescription;
	string protocolName;
	SampleAnnotations sampleAnnotations;
	SeriesIDs seriesIDs;
	PersonIDs personIDs;
	SampleIDsAveragedFrom sampleIDsAveragedFrom;
	DataExpressionLevelsForSample dataExpressionLevelsForSample;
	} ExpressionDataSample;
    
    /* Mapping between sampleID and ExpressionDataSample */
    typedef mapping<SampleID sampleID, ExpressionDataSample> ExpressionDataSamplesMap;

    /*mapping between seriesIDs and all Samples it contains*/
    typedef mapping<SeriesID seriesID, ExpressionDataSamplesMap> SeriesExpressionDataSamplesMapping;
    
    /*mapping between experimentalUnitIDs and all Samples it contains*/
    typedef mapping<ExperimentalUnitID experimentalUnitID, ExpressionDataSamplesMap> ExperimentalUnitExpressionDataSamplesMapping;

    /*mapping between experimentMetaIDs and ExperimentalUnitExpressionDataSamplesMapping it contains*/
    typedef mapping<ExperimentMetaID experimentMetaID, ExperimentalUnitExpressionDataSamplesMapping> ExperimentMetaExpressionDataSamplesMapping;
    
    /*mapping between strainIDs and all Samples it contains*/
    typedef mapping<StrainID strainID, ExpressionDataSamplesMap> StrainExpressionDataSamplesMapping;

    /*mapping between genomeIDs and all StrainExpressionDataSamplesMapping it contains*/
    typedef mapping<GenomeID genomeID, StrainExpressionDataSamplesMapping> GenomeExpressionDataSamplesMapping;

    /*mapping between ontologyIDs (concatenated if searched for with the and operator) and all the Samples that match that term(s)*/
    typedef mapping<OntologyID ontologyID, ExpressionDataSamplesMap> OntologyExpressionDataSampleMapping;

    /* mapping kbase sample id as the key and a single measurement (for a scpecified feature id, one mapping higher) as the value */
    typedef mapping<SampleID sampleID, Measurement measurement> SampleMeasurementMapping; 
    
    /*mapping between FeatureIds and the mappings between samples and log2level mapping*/
    typedef mapping<FeatureID featureID, SampleMeasurementMapping sampleMeasurementMapping> FeatureSampleMeasurementMapping;

    /*DATA STRUCTURES FOR GEO PARSING*/

    /*Data structure for a GEO Platform */
    typedef structure { 
        string gplID;
	string gplTitle;
        string gplTechnology; 
    } GPL; 
     
    /*Email for the GSM contact person*/
    typedef string ContactEmail;
 
    /*First Name of GSM contact person*/
    typedef string ContactFirstName;

    /*Last Name of GSM contact person*/
    typedef string ContactLastName;

    /*Institution of GSM contact person*/
    typedef string ContactInstitution;

    /*Data structure for GSM ContactPerson*/
    typedef structure {
	ContactFirstName contactFirstName;
	ContactLastName contactLastName;
	ContactInstitution contactInstitution;
    } ContactPerson;

    /*Mapping between key : ContactEmail and value : ContactPerson Data Structure*/
    typedef mapping<ContactEmail contactEmail, ContactPerson contactPerson> ContactPeople;

    /*Measurement data structure */
    typedef structure { 
        float value;
        float N;
        float stddev;
	float Z_score;
	float p_value;
	float median;
	float mean;
    } FullMeasurement;
    
    /* mapping kbase feature id as the key and FullMeasurement Structure as the value */ 
    typedef mapping<FeatureID featureID, FullMeasurement fullMeasurement> GsmData; 
    
    /* List of GSM level warnings */ 
    typedef list<string> GsmWarnings;

    /* List of GSE level warnings */
    typedef list<string> GseWarnings;

    /* List of GSM level errors */
    typedef list<string> GsmErrors;

    /* List of GSE level errors */
    typedef list<string> GseErrors;

    /* List of GSM Sample Characteristics from ch1 */
    typedef list<string> GsmSampleCharacteristics;

    /* GSM OBJECT */
    typedef structure {
	string gsmID;
	string gsmTitle;
	string gsmDescription;
	string gsmMolecule;
	string gsmSubmissionDate;
	string gsmTaxID;
	string gsmSampleOrganism;
        GsmSampleCharacteristics gsmSampleCharacteristics;
	string gsmProtocol;
	string gsmValueType;
	float gsmOriginalLog2Median;
	GPL gsmPlatform;
	ContactPeople gsmContactPeople;
	GsmData gsmData;
	string gsmFeatureMappingApproach;
	GsmWarnings gsmWarning;
	GsmErrors gsmErrors;
    } GsmObject;

    /* Mapping of Key GSMID to GSM Object */
    typedef mapping<string gsmKeyId, GsmObject gsmObject> GseSamples;

    /* GSE OBJECT */
    typedef structure {
	string gseID;
	string gseTitle;
	string gseSummary;
	string gseDesign;
	string gseSubmissionDate;
	string pubMedID;
	GseSamples gseSamples;
	GseWarnings gseWarnings;
	GseErrors gseErrors;
    } GseObject;

    /* Single integer 1= metaDataOnly, 0 means returns data */
    typedef int MetaDataOnly; 


    /*FUNCTIONS*/
    
    /* core function used by many others.  Given a list of KBase SampleIds returns mapping of SampleId to expressionSampleDataStructure (essentially the core Expression Sample Object) : 
    {sample_id -> expressionSampleDataStructure}*/
    funcdef get_expression_samples_data(SampleIDs sampleIDs) returns (ExpressionDataSamplesMap expressionDataSamplesMap);

    /* given a list of sample ids and feature ids it returns a LabelDataMapping {sampleID}->{featureId => value}}.  
	If feature list is an empty array [], all features with measurment values will be returned. */
    funcdef get_expression_data_by_samples_and_features(SampleIDs sampleIDs, FeatureIDs featureIDs) returns (LabelDataMapping labelDataMapping);

    /* given a list of SeriesIDs returns mapping of SeriesID to expressionDataSamples : {series_id -> {sample_id -> expressionSampleDataStructure}}*/
    funcdef get_expression_samples_data_by_series_ids(SeriesIDs seriesIDs) returns (SeriesExpressionDataSamplesMapping seriesExpressionDataSamplesMapping);

    /* given a list of SeriesIDs returns a list of Sample IDs */
    funcdef get_expression_sample_ids_by_series_ids(SeriesIDs seriesIDs) returns (SampleIDs sampleIDs);
    
    /* given a list of ExperimentalUnitIDs returns mapping of ExperimentalUnitID to expressionDataSamples : {experimental_unit_id -> {sample_id -> expressionSampleDataStructure}}*/
    funcdef get_expression_samples_data_by_experimental_unit_ids(ExperimentalUnitIDs experimentalUnitIDs) returns (ExperimentalUnitExpressionDataSamplesMapping experimentalUnitExpressionDataSamplesMapping);

    /* given a list of ExperimentalUnitIDs returns a list of Sample IDs */
    funcdef get_expression_sample_ids_by_experimental_unit_ids(ExperimentalUnitIDs experimentalUnitIDs) returns (SampleIDs sampleIDs); 
    
    /* given a list of ExperimentMetaIDs returns mapping of {experimentMetaID -> {experimentalUnitId -> {sample_id -> expressionSampleDataStructure}}} */ 
    funcdef get_expression_samples_data_by_experiment_meta_ids(ExperimentMetaIDs experimentMetaIDs) returns (ExperimentMetaExpressionDataSamplesMapping experimentMetaExpressionDataSamplesMapping); 

    /* given a list of ExperimentMetaIDs returns a list of Sample IDs */ 
    funcdef get_expression_sample_ids_by_experiment_meta_ids(ExperimentMetaIDs experimentMetaIDs) returns (SampleIDs sampleIDs); 
    
    /* given a list of Strains, and a SampleType (controlled vocabulary : microarray, RNA-Seq, qPCR, or proteomics) , it returns a StrainExpressionDataSamplesMapping,  
    StrainId -> ExpressionSampleDataStructure {strain_id -> {sample_id -> expressionSampleDataStructure}}*/
    funcdef get_expression_samples_data_by_strain_ids(StrainIDs strainIDs, SampleType sampleType) returns (StrainExpressionDataSamplesMapping strainExpressionDataSamplesMapping);

    /* given a list of Strains, and a SampleType, it returns a list of Sample IDs*/
    funcdef get_expression_sample_ids_by_strain_ids(StrainIDs strainIDs, SampleType sampleType) returns (SampleIDs sampleIDs); 

    /* given a list of Genomes, a SampleType ( controlled vocabulary : microarray, RNA-Seq, qPCR, or proteomics) 
    and a int indicating WildTypeOnly (1 = true, 0 = false) , it returns a GenomeExpressionDataSamplesMapping   ,  
    GenomeId -> StrainId -> ExpressionDataSample.  StrainId -> ExpressionSampleDataStructure {genome_id -> {strain_id -> {sample_id -> expressionSampleDataStructure}}}*/
    funcdef get_expression_samples_data_by_genome_ids(GenomeIDs genomeIDs, SampleType sampleType, WildTypeOnly wildTypeOnly) returns (GenomeExpressionDataSamplesMapping genomeExpressionDataSamplesMapping);

    /* given a list of GenomeIDs, a SampleType ( controlled vocabulary : microarray, RNA-Seq, qPCR, or proteomics) 
    and a int indicating WildType Only (1 = true, 0 = false) , it returns a list of Sample IDs*/ 
    funcdef get_expression_sample_ids_by_genome_ids(GenomeIDs genomeIDs, SampleType sampleType, WildTypeOnly wildTypeOnly) returns (SampleIDs sampleIDs); 

    /* given a list of ontologyIDs, AndOr operator (and requires sample to have all ontology IDs, or sample has to have any of the terms), GenomeId, 
    SampleType ( controlled vocabulary : microarray, RNA-Seq, qPCR, or proteomics), wildTypeOnly returns OntologyID(concatenated if Anded) -> ExpressionDataSample  */
    funcdef get_expression_samples_data_by_ontology_ids(OntologyIDs ontologyIDs, string AndOr, GenomeID genomeId, SampleType sampleType, WildTypeOnly wildTypeOnly) 
        returns (OntologyExpressionDataSampleMapping ontologyExpressionDataSampleMapping);

    /* given a list of ontologyIDs, AndOr operator (and requires sample to have all ontology IDs, or sample has to have any of the terms), GenomeId, 
    SampleType ( controlled vocabulary : microarray, RNA-Seq, qPCR, or proteomics), wildTypeOnly returns a list of SampleIDs  */ 
    funcdef get_expression_sample_ids_by_ontology_ids(OntologyIDs ontologyIDs, string AndOr, GenomeID genomeId, SampleType sampleType, WildTypeOnly wildTypeOnly) 
        returns (SampleIDs sampleIDs); 

    /* given a list of FeatureIDs, a SampleType ( controlled vocabulary : microarray, RNA-Seq, qPCR, or proteomics) 
    and an int indicating WildType Only (1 = true, 0 = false) returns a FeatureSampleMeasurementMapping: {featureID->{sample_id->measurement}}*/
    funcdef get_expression_data_by_feature_ids(FeatureIDs featureIDs, SampleType sampleType, WildTypeOnly wildTypeOnly) 
        returns (FeatureSampleMeasurementMapping featureSampleMeasurementMapping);

    /* Compare samples takes two data structures labelDataMapping  {sampleID or label}->{featureId or label => value}}, 
    the first labelDataMapping is the numerator, the 2nd is the denominator in the comparison. returns a 
    SampleComparisonMapping {numerator_sample_id(or label)->{denominator_sample_id(or label)->{feature_id(or label) -> log2Ratio}}} */
    funcdef compare_samples(LabelDataMapping numeratorsDataMapping, LabelDataMapping denominatorsDataMapping) returns (SampleComparisonMapping sampleComparisonMapping);

    /* Compares each sample vs its defined default control.  If the Default control is not specified for a sample, then nothing is returned for that sample .
    Takes a list of sampleIDs returns SampleComparisonMapping {sample_id ->{denominator_default_control sample_id ->{feature_id -> log2Ratio}}} */
    funcdef compare_samples_vs_default_controls(SampleIDs numeratorSampleIDs) returns (SampleComparisonMapping sampleComparisonMapping);

    /* Compares each numerator sample vs the average of all the denominator sampleIds.  Take a list of numerator sample IDs and a list of samples Ids to average for the denominator.
    returns SampleComparisonMapping {numerator_sample_id->{denominator_sample_id ->{feature_id -> log2Ratio}}} */
    funcdef compare_samples_vs_the_average(SampleIDs numeratorSampleIDs, SampleIDs denominatorSampleIDs) returns (SampleComparisonMapping sampleComparisonMapping);

    /* Takes in comparison results.  If the value is >= on_threshold it is deemed on (1), if <= off_threshold it is off(-1), meets none then 0.  Thresholds normally set to zero.
    returns SampleComparisonMapping {numerator_sample_id(or label)->{denominator_sample_id(or label)->{feature_id(or label) -> on_off_call (possible values 0,-1,1)}}} */
    funcdef get_on_off_calls(SampleComparisonMapping sampleComparisonMapping, float off_threshold, float on_threshold) returns (SampleComparisonMapping onOffMappings);

    /* Takes in comparison results. Direction must equal 'up', 'down', or 'both'.  Count is the number of changers returned in each direction.
    returns SampleComparisonMapping {numerator_sample_id(or label)->{denominator_sample_id(or label)->{feature_id(or label) -> log2Ratio (note that the features listed will be limited to the top changers)}}} */
    funcdef get_top_changers(SampleComparisonMapping sampleComparisonMapping, string direction, int count) returns (SampleComparisonMapping topChangersMappings);

    /* given a List of SampleIDs, returns a Hash (key : SampleID, value: Title of Sample) */
    funcdef get_expression_samples_titles(SampleIDs sampleIDs) returns (SamplesStringMap samplesTitlesMap);

    /* given a List of SampleIDs, returns a Hash (key : SampleID, value: Description of Sample) */
    funcdef get_expression_samples_descriptions(SampleIDs sampleIDs) returns (SamplesStringMap samplesDescriptionsMap);

    /* given a List of SampleIDs, returns a Hash (key : SampleID, value: Molecule of Sample) */
    funcdef get_expression_samples_molecules(SampleIDs sampleIDs) returns (SamplesStringMap samplesMoleculesMap);

    /* given a List of SampleIDs, returns a Hash (key : SampleID, value: Type of Sample) */
    funcdef get_expression_samples_types(SampleIDs sampleIDs) returns (SamplesStringMap samplesTypesMap);

    /* given a List of SampleIDs, returns a Hash (key : SampleID, value: External_Source_ID of Sample (typically GSM)) */
    funcdef get_expression_samples_external_source_ids(SampleIDs sampleIDs) returns (SamplesStringMap samplesExternalSourceIdMap);

    /* given a List of SampleIDs, returns a Hash (key : SampleID, value: OriginalLog2Median of Sample) */ 
    funcdef get_expression_samples_original_log2_medians(SampleIDs sampleIDs) returns (SamplesFloatMap samplesFloatMap);

    /* given a List of SeriesIDs, returns a Hash (key : SeriesID, value: Title of Series) */
    funcdef get_expression_series_titles(SeriesIDs seriesIDs) returns (SeriesStringMap seriesStringMap);
 
    /* given a List of SeriesIDs, returns a Hash (key : SeriesID, value: Summary of Series) */
    funcdef get_expression_series_summaries(SeriesIDs seriesIDs) returns (SeriesStringMap seriesStringMap);

    /* given a List of SeriesIDs, returns a Hash (key : SeriesID, value: Design of Series) */
    funcdef get_expression_series_designs(SeriesIDs seriesIDs) returns (SeriesStringMap seriesStringMap);

    /* given a List of SeriesIDs, returns a Hash (key : SeriesID, value: External_Source_ID of Series (typically GSE)) */
    funcdef get_expression_series_external_source_ids(SeriesIDs seriesIDs) returns (SeriesStringMap seriesStringMap);

    /* get sample ids by the sample's external source id : Takes a list of sample external source ids, and returns a list of sample ids  */
    funcdef get_expression_sample_ids_by_sample_external_source_ids(ExternalSourceIDs) returns (SampleIDs sampleIDs);

    /* get sample ids by the platform's external source id : Takes a list of platform external source ids, and returns a list of sample ids  */   
    funcdef get_expression_sample_ids_by_platform_external_source_ids(ExternalSourceIDs) returns (SampleIDs sampleIDs);   
 
    /* get series ids by the series's external source id : Takes a list of series external source ids, and returns a list of series ids  */          
    funcdef get_expression_series_ids_by_series_external_source_ids(ExternalSourceIDs) returns (SeriesIDs seriesIDs);  

    /* given a GEO GSE ID and a flag (1 = MetaDataOnly, 0 = IncludeData), it will return a complex data structure to be put into the upload tab files*/
    funcdef get_GEO_GSE(string gse_input_id, MetaDataOnly metaDataOnly) returns (GseObject gseObject);

    /* given a GEO GSM ID and a flag (1 = MetaDataOnly, 0 = IncludeData), it will return a complex data structure to be put into the upload tab files*/
    funcdef get_GEO_GSM(string gsm_input_id, MetaDataOnly metaDataOnly) returns (GsmObject gsmObject);

}; 
