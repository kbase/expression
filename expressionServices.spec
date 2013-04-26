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
    
    /* list of KBase ExperimentUnitIDs */
    typedef list<ExperimentalUnitID> ExperimentalUnitIDs;
    
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

    /* mapping kbase feature id as the key and log2lRatio as the value */ 
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
    
    /* Data structure for all the top level metadata and value data for an expression sample */
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

    /*FUNCTIONS*/
    
    /* core function used by many others.  Given a list of SampleIds returns mapping of SampleId to SampleDataStructure */
    funcdef get_expression_samples_data(SampleIDs sampleIDs) returns (ExpressionDataSamplesMap expressionDataSamplesMap);

    /* given a list of SeriesIDs returns mapping of SeriesID to expressionDataSamples */
    funcdef get_expression_samples_data_by_series_ids(SeriesIDs seriesIDs) returns (SeriesExpressionDataSamplesMapping seriesExpressionDataSamplesMapping);
    
    /* given a list of ExperimentalUnitIDs returns mapping of ExperimentalUnitID to expressionDataSamples */
    funcdef get_expression_samples_data_by_experimental_unit_ids(ExperimentalUnitIDs experimentalUnitIDs) returns (ExperimentalUnitExpressionDataSamplesMapping experimentalUnitExpressionDataSamplesMapping);
    
    /* given a list of ExperimentMetaIDs returns mapping of ExperimentID to experimentalUnitExpressionDataSamplesMapping */
    funcdef get_expression_experimental_unit_samples_data_by_experiment_meta_ids(ExperimentMetaIDs experimentMetaIDs) returns (ExperimentMetaExpressionDataSamplesMapping experimentMetaExpressionDataSamplesMapping);

    /* given a list of ExperimentMetaIDs returns mapping of ExperimentID to experimentalUnitExpressionDataSamplesMapping */ 
    funcdef get_expression_samples_data_by_experiment_meta_ids(ExperimentMetaIDs experimentMetaIDs) returns (ExperimentMetaExpressionDataSamplesMapping experimentMetaExpressionDataSamplesMapping); 
    
    /* given a list of Strains, and a SampleType, it returns a StrainExpressionDataSamplesMapping,  StrainId -> ExpressionDataSample*/
    funcdef get_expression_samples_data_by_strain_ids(StrainIDs strainIDs, SampleType sampleType) returns (StrainExpressionDataSamplesMapping strainExpressionDataSamplesMapping);

    /* given a list of Genomes, a SampleType and a int indicating WildType Only (1 = true, 0 = false) , it returns a GenomeExpressionDataSamplesMapping   ,  Genome -> StrainId -> ExpressionDataSample*/
    funcdef get_expression_samples_data_by_genome_ids(GenomeIDs genomeIDs, SampleType sampleType, WildTypeOnly wildTypeOnly) returns (GenomeExpressionDataSamplesMapping genomeExpressionDataSamplesMapping);

    /* given a list of ontologyIDs, AndOr operator (and requires sample to have all ontology IDs, or sample has to have any of the terms, GenomeId, wildTypeOnly returns OntologyID(concatenated if Anded) -> ExpressionDataSample  */
    funcdef get_expression_samples_data_by_ontology_ids(OntologyIDs ontologyIDs, string AndOr, GenomeID genomeId, WildTypeOnly wildTypeOnly) 
        returns (OntologyExpressionDataSampleMapping ontologyExpressionDataSampleMapping);

    /* given a list of FeatureIDs, a SampleType and a int indicating WildType Only (1 = true, 0 = false) returns a FeatureSampleMeasurementMapping: featureID->{sample_id->measurement}*/
    funcdef get_expression_data_by_feature_ids(FeatureIDs featureIDs, SampleType sampleType, WildTypeOnly wildTypeOnly) 
        returns (FeatureSampleMeasurementMapping featureSampleMeasurementMapping);

    /* Compare samples takes two data structures labelDataMapping, the first is numerator, the 2nd is the denominator in the comparison. returns a SampleComparisonMapping */
    funcdef compare_samples(LabelDataMapping numeratorsDataMapping, LableDataMapping denominatorsDataMapping) returns (SampleComparisonMapping sampleComparisonMapping);

    /* Compares each sample vs its defined default control.  If the Default control is not specified for a sample, then nothing is returned for that sample */
    funcdef compare_samples_vs_default_controls(SampleIDs numeratorSampleIDs) returns (SampleComparisonMapping sampleComparisonMapping);

    /* Compares each numerator sample vs the average of all the denominator sampleIds*/
    funcdef compare_samples_vs_the_average(SampleIDs numeratorSampleIDs, SampleIDs denominatorSampleIDs) returns (SampleComparisonMapping sampleComparisonMapping);

    /* Takes in comparison results.  If the value is >= on_threshold it is deemed on (1), if <= off_threshold it is off(-1), meets none then 0.  Thresholds normally set to zero */
    funcdef get_on_off_calls(SampleComparisonMapping sampleComparisonMapping, float off_threshold, float on_threshold) returns (SampleComparisonMapping onOffMappings);

    /* Takes in comparison results. Direction must equal 'up', 'down', or 'both'.  Count is the number of changers returned in each direction */
    funcdef get_top_changers(SampleComparisonMapping sampleComparisonMapping, string direction, integer count) returns (SampleComparisonMapping onOffMappings);
}; 
