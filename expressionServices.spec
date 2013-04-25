module ExpressionServices { 

    /* KBase Feature ID for a feature, typically CDS/PEG */
    typedef string FeatureID;
    
    /* KBase list of Feature IDs , typically CDS/PEG */
    typedef list<FeatureID> FeatureIDs;
    
    /* Log2Level (Zero median normalized within a sample) for a given feature */
    typedef float Log2Level;
    
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
    
    /* mapping kbase feature id as the key and log2level as the value */
    typedef mapping<FeatureID featureID, Log2Level log2level> DataExpressionLevelsForSample; 

    /* Log2Ratio Log2Level of sample over log2Level of another sample for a given feature */ 
    typedef float Log2Ratio; 

    /* mapping kbase feature id as the key and log2lRatio as the value */
    typedef mapping<FeatureID featureID, Log2Ratio log2Ratio> DataSampleComparison;

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
    typdef list<SampleAnnotation> SampleAnnotations;

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

    /* mapping kbase sample id as the key and a single log2level (for a scpecified feature id, one mapping higher) as the value */
    typedef mapping<SampleID sampleID, Log2Level log2level> SampleLog2LevelMapping; 
    
    /*mapping between FeatureIds and the mappings between samples and log2level mapping*/
    typedef mapping<FeatureID featureID, SampleLog2LevelMapping sampleLog2LevelMapping> FeatureSampleLog2LevelMapping;

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

    /* given a list of FeatureIDs, a SampleType and a int indicating WildType Only (1 = true, 0 = false) returns a FeatureSampleLog2LevelMapping : featureID->{sample_id->log2Level} */
    funcdef get_expression_data_by_feature_ids(FeatureIDs featureIDs, SampleType sampleType, WildTypeOnly wildTypeOnly) returns (FeatureSampleLog2LevelMapping featureSampleLog2LevelMapping);
    
}; 
