'''
Original Created on Dec 19th, 2012
Rewriteen for massive format change 3/28/2013

@author: jkbaumohl@lbl.gov
'''

from biokbase.exchangeformatsupport.argumentspecs import \
    StringArgument as _StringArgument, DateTimeArgument as _DateTimeArgument, \
    LongStringArgument as _LongStringArgument, \
    SemiBooleanArgument as _SemiBooleanArgument, \
    FloatArgument as _FloatArgument, IntArgument as _IntArgument, \
    KBaseID_Argument as _KBaseID_Argument, \
    ManyToManyArgument as _ManyToManyArgument, \
    PubID_Argument as _PubID_Argument, TextArgument as _TextArgument, \
    SourceOrKBID_Argument as _SourceOrKBID_Argument, RelInfo as _RelInfo, \
    UnitsArgument as _UnitsArgument, URL_Argument as _URL_Argument, \
    StringEnumerationArgument as _StringEnumerationArgument, StringID_Argument as _StringID_Argument    
from biokbase.exchangeformatsupport.exceptions import \
    ExchangeFormatValueError as _ExchangeFormatValueError
from biokbase.exchangeformatsupport.exchangeformat import \
    ExchangeFormat as _ExchangeFormat, \
    ExchangeFormatRelationship as _ExchangeFormatRelationship, \
    PublicationEntity as _PublicationEntity, \
    create_m2m_relclass as _create_m2m_relclass, \
    createkeyvalueclass as _createkeyvalueclass, \
    ExchangeFormatEntity as _ExchangeFormatEntity
from biokbase.exchangeformatsupport.kbaseid import \
    PublicationID as _PublicationID
from biokbase.experiment.exchangeformat.argumentspecs import \
    CompoundArgument as _CompoundArgument
from biokbase.experiment.exchangeformat.constants import \
    COMPOUND_COL_SEP as _COMPOUND_COL_SEP, \
    EF_NO_ENTRY_SYMBOL as _EF_NO_ENTRY_SYMBOL, \
    PERSON_COL_SEP as _PERSON_COL_SEP, PARAM_COL_SEP as _PARAM_COL_SEP, \
    PARAM_ROW_SEP as _PARAM_ROW_SEP, PERSON_ROW_SEP as _PERSON_ROW_SEP, \
    PUBLICATION_ROW_SEP as _PUBLICATION_ROW_SEP, EF_LINE_SEP as _EF_LINE_SEP, \
    KNOCKOUT_ROW_SEP as _KNOCKOUT_ROW_SEP, \
    COMPOUND_ROW_SEP as _COMPOUND_ROW_SEP
from biokbase.experiment.exchangeformat.mixins import \
    HasCompounds as _HasCompounds
from collections import defaultdict as _defaultdict
import datetime

FILE_SUFFIX = '.tab'
EF_NAME = 'Expression'

_PERSONSAMPLE_ROW_SEP = ','
_SAMPLE_ROW_SEP = ',';

ALLOWED_MOLECULES = frozenset(['total RNA', 'polyA RNA', 'cytoplasmic RNA', 'nuclear RNA','protein','total RNA/genomic DNA',
								'polyA RNA/genomic DNA','cytoplasminc RNA/genomic DNA','nuclear RNA/genomic DNA'])
ALLOWED_TYPES = frozenset(['microarray','RNA-Seq','qPCR','proteomics'])
ALLOWED_CONFIDENCE_TYPES = frozenset(['pValue','Zscore','null'])
ALLOWED_UNITS = frozenset(['vol%', 'g/L', 'mol/L'])

###############################################
#
# Docs
#
###############################################

PREAMBLE = '''
EXPRESSION EXCHANGE FORMAT:
This exchange format describes the files included in the exchange for expression data.  
This includes microarray, RNA-Seq (expression), qPCR and proteomics data.
The files included in this exchange are:

1.	sample.tab
2.	series.tab
3.	platform.tab
4.	measurement.tab 
5.	sample_annotation.tab 
6.	person.tab
7.	protocol.tab
8.	publication.tab
9.	strain.tab
10.	environment.tab
11.	media.tab
12.	time_series.tab
13.	experimentMeta.tab
14.	experimentalUnit.tab
15.     measurementDescription.tab

The sample.tab and log2level.tab are the truly important files.  
The other tables are primarily to attach meta data to the sample.
'''

VERSION = 2

docs = _defaultdict(dict)

# SAMPLE TABLE - 1

docs['sam']['pre'] = '''
A sample is typically a single expression experiment (ex: individual microarray, or RNA-Seq run).  
Potentially replicates could be collapsed/averaged into one sample.  
A sample is some biological sample run in a particular combination of platform, environment, protocol and media.'''
docs['sam']['title'] = 'The title of sample.'
docs['sam']['description'] = 'The description of the sample.' 
docs['sam']['molecule'] = '''
Enumerated values [total RNA, polyA RNA, cytoplasmic RNA, nuclear RNA, protein, total RNA/genomic DNA,  
polyA RNA/genomic DNA,  cytoplasmic RNA/genomic DNA, nuclear RNA/genomic DNA]'''
docs['sam']['type'] = 'Enumerated values [microarray, RNA-Seq, qPCR, proteomics]'
docs['sam']['externalSourceId'] = 'A way to identify the external source of the sample, typically maps to a GEO Sample (GSM#).'
docs['sam']['dataSource'] = '''
The Data Source will be a way to identify where the data came from.  
Examples might be : GEO, SEED Expression Pipeline, CSHL Expression Pipeline, Enigma, M3D.'''
docs['sam']['kbaseSubmissionDate'] = 'Date that the sample was uploaded to KBase.  If empty defaults to the date of the upload.'
docs['sam']['externalSourceDate'] = 'Date associated with the external source (ex: GEO submission date).'
docs['sam']['originalLog2Median'] = '''
The original median of the log2level values for the sample in log2 space.  
If the data already has a median of zero, this column should be empty "."
If the median for the log2levels for a each sample have not been set to a median of zero, then 
the uploader should do it themselves or run the log2level.tab and sample.tab file through the preprocessor.
The Prepreprocessor will adjust the log2levels for each sample so that the median is zero.  Additionally the preprocessor
will update the originalLog2Median field for each sample in the sample file with what the originalLog2Median was for a given sample.
This allows for original values to be obtained, but also puts the data in comparable space.'''
docs['sam']['custom'] = '''
Custom refers to a sample being created from the averaging of existing samples, typically replicates.
Always FALSE, as Custom operations will be done through a future web interface and 
this exchange format does not support custom averagings.'''
docs['sam']['persons'] = 'Comma separated list of source ids (from the person tab) of the contact people for the sample.'
docs['sam']['strain'] = 'The KBase identifier or source-id for the Strain that the sample was for (refers to the strain tab).'
docs['sam']['platform'] = 'The KBase identifier or source-id for the Platform that the sample was for.'
docs['sam']['protocol'] = 'The KBase identifier or source id of the protocol associated with the sample.'
docs['sam']['experimentalUnit'] = 'The KBase identifier or source-id for the Experimental unit that this sample is associated with.'
docs['sam']['defaultControlSampleId'] = 'The KBase identifier or source-id for the sample that should be used for this sample for default comparisons.'


# SERIES TABLE - 2

docs['ser']['pre'] = 'A series is a collection of samples that are grouped as a single scientific study/publication.'
docs['ser']['title'] = 'Title of the series.'
docs['ser']['summary'] = 'Summary of the series.'
docs['ser']['design'] = 'Design of the Series'
docs['ser']['externalSourceId'] = 'A way to identify the external source of the sample, typically maps to a GEO Series (GSE#).'
docs['ser']['kbaseSubmissionDate'] = 'Date that the series was uploaded to KBase.  If empty defaults to the date of the upload.'
docs['ser']['externalSourceDate'] = 'Date associated with the external source (ex: GEO submission date).'
docs['ser']['publicationIds'] = 'Comma separated list of all the KBase ID or source-id of the publication.'
docs['ser']['samples'] = '''
Comma separated list of all the samples that make up the series.  
Note the sample identifiers can be Kbase ids or sample source-ids.'''


# PLATFORM TABLE - 3

docs['plt']['pre'] = 'A platform is an identifier for the layout of the microarray or at least identifying the technology'
docs['plt']['title'] = 'The title of platform.'
docs['plt']['technology'] = 'Technology used.  Brand name/ model.'
docs['plt']['type'] = 'Enumerated values [microarray, RNA-Seq, qPCR, proteomics].'
docs['plt']['externalSourceId'] = 'Typically maps to a GEO Platform (GPL#).'
docs['plt']['strain'] = '''
The KBase identifier or source-id for the Strain that the platform was designed for.  
Note that it is possible the platform to be designed for a different strain than what the sample run on it is.  
Refers to strain tab.'''


# MEASUREMENT TABLE - 4                                                                                                                      
 
docs['meas']['pre'] = '''                                          
Holds the measurement values for all of the features normalized so that the measurements are in Log2 space.  
The log2level measurement median of the sample is zero 
(the measurement median of the sample is subtracted out from each level within the sample).     
NOTE IT IS REQUIRED that the measurements are in log2 level space and have been normalized so that the median      
of all a sample's levels for features equals zero.  If this has not been done, convert your levels into log2level space and then        
have the preprocessor process the measurement.tab and sample.tab files.  After that the data should be good to upload.'''
docs['meas']['post'] = '''                                                                                                               
*Note that log2Level needs to be in log2 space.  Additionally the median of all log2Levels for a    
given sample need to be normalized so that there median is equal to zero.  The original median log2 level
should be stored in the sample table.''' 
docs['meas']['sampleId'] = '''                                             
The source or KBase ID of the sample to which the measurement belongs.''' 
docs['meas']['desc'] = '''                                                             
The source or KBase ID of the measurement description that describes this                                                                 
measurement.  Note that the measurements need to be in log2 space and with median
of all the measurements for a given sample set to zero.''' 
docs['meas']['feat'] = '''                                                                                                                
The KBase id of the feature (e.g. gene/RNA etc.) that this measurement                                                                    
quantifies.''' 
docs['meas']['val'] = '''
The value is abundance of for expression for a feature.  This value needs to be in Log2 space.  
The median of all the values for a given sample needs to be set to zero.  
Note if the values are in log2 space but not normalized with a zero median just run the 
preprocessor from the directory that has the measurement.tab and sample.tab file in it.
This is a required field.''' 
docs['meas']['mean'] = '''                                                                                                                
The mean of the measurement if multiple replicates were taken.''' 
docs['meas']['med'] = '''                                                                                                                 
The median of the measurement if multiple replicates were taken.'''
docs['meas']['std'] = '''                                                                                                                 
The standard deviation of the measurement if multiple replicates were taken.''' 
docs['meas']['N'] = 'The number of replicates, if taken.'
docs['meas']['pval'] = '''                                                                                                                
The p-value of multiple replicates if they are included in the measurement.                                                               
The exact meaning of the p-value is specified in the Measurement Description                                                              
object for this measurement.''' 
docs['meas']['Z'] = '''                                                                                                                   
The Z-score of multiple replicates if they are included in the measurement.                                                               
The exact meaning of the p-value is specified in the Measurement Description                                                              
object for this measurement.''' 


# SAMPLE_ANNOTATION TABLE - 5
docs['sam_ann']['pre'] = 'Holds annotation information for a sample'
docs['sam_ann']['ontologyID']= '''
This is a reference to the id in the Ontology table.  The Ontology table
is a controlled vocabulary table that contains the ontology terms from 3 ontology databases.
The ontologies could be Plant Ontologies (PO#s), Plant Environmental Ontologies (EO#s), Bacterial Environmental Ontologies (ENVO#s).
The ontology id entered here should be the corresponding KBase id in the Ontology for the ontology term desired.
'''
docs['sam_ann']['annotationDate'] = 'Date of the annotation.  If empty defaults to the date of the upload.'
docs['sam_ann']['ontologyTerm'] = 'The ontology term from the controlled vocabulary ontology table.  Must already exist in the DB.'
docs['sam_ann']['person'] = 'Source id of the person that performed the annotation.  If empty it is assumed to be done by an automated process.'
docs['sam_ann']['sample'] = 'The KBase identifier or source-id for the Sample that this annotation is for.'


# PERSON TABLE - 6

docs['per']['pre'] = 'A person is a human being involved with an experiment.'
docs['per']['name'] = 'The given name of the person.'
docs['per']['sur'] = 'The surname of the person.'
docs['per']['email'] = 'The email address of the person.'
docs['per']['inst'] = 'The institution where the person works.'


# PROTOCOL TABLE - 7

docs['pro']['pre'] = '''
A protocol is a set of instructions for performing a particular measurement.'''
docs['pro']['name'] = 'The name of the protocol.'
docs['pro']['desc'] = '''
A detailed description of the protocol, e.g. materials and methods.'''
docs['pro']['pub'] = '''
The publication ID of the publication describing this experiment.'''


# PUBLICATION TABLE - 8

docs['pub']['pre'] = 'A publication describes an experiment and/or protocol.'
docs['pub']['date'] = "The publication's publication date."
docs['pub']['title'] = 'The title of the publication.'


# STRAIN TABLE - 9

docs['str']['pre'] = '''
A strain is an engineered version of a genome with zero or more gene
knockouts.'''
docs['str']['post'] = '''
*  A wildtype strain cannot have a parent strain or knockouts.
* A reference strain cannot have AggregateData = True and must have
Wildtype = True'''
docs['str']['name'] = '''
The common or laboratory name of the strain, e.g. DH5a or JMP1004.'''
docs['str']['desc'] = '''
A description of the strain, e.g. 'E. coli MG1655 with a glnA knockout.\''''
docs['str']['agg'] = '''
Denotes whether this entity represents a physical strain (False) or aggregate
data calculated from one or more strains (True).'''
docs['str']['wt'] = '''
Boolean that denotes that this strain is a wildtype strain presumably identical
to the parent genome.'''
docs['str']['ref'] = '''
Boolean that denotes this strain is identical to the parent genome. In contrast
to Wildtype, a reference strain is abstract and does not actually exist, but is
used for data that references a genome but not a particular strain. Before
adding a reference strain to a load, ensure that one does not already exist in
KBase. If a RF exists, link to that reference strain rather than creating a new
one.'''
docs['str']['gen'] = 'Kbase ID of the genome this strain was derived from.'
docs['str']['str'] = '''The source or KBase ID of the strain from which this
strain was derived.'''
docs['str']['ko'] = '''The KBase IDs of all the Features that are knocked out
in this strain in the format knockout1;knockout2;'''


# ENVIRONMENT TABLE - 10

docs['env']['pre'] = '''
The environment specifies the conditions used for an experiment, including the
media, any additional compounds, and arbitrary parameters specified by the
user.'''
docs['env']['desc'] = 'The description of the environment.'
docs['env']['temp'] = 'The temperature of the environment in Kelvin.'
docs['env']['oxy'] = '''The oxygen concentration in the environment in Molar
(mol/L). A value of -1 indicates that there is oxygen in the environment but
the concentration is not known (e.g. an open air shake flask experiment).'''
docs['env']['pH'] = 'The pH of the environment.'
docs['env']['med'] = 'The source or KBase ID of the media in this environment.'
docs['env']['cond'] = '''The names and/or KBase IDs of compounds and
their concentrations and units in this environment above and beyond the media
content in the format
compound1$concentration$units!compound2$concentration$units!...
Allowed units are g/L, mol/L, and vol%.'''
docs['env']['param'] = '''Arbitrary key-value pairs associated with this
environment in the format key1,value1;key2,value2;... For example:
Flask size,200ml;Shaker speed,200rpm;...'''


# MEDIA TABLE - 11

docs['med']['pre'] = '''
A media defines the constituents of an experimental media.'''
docs['med']['name'] = 'The name of the media.'
docs['med']['desc'] = 'A description of the use and contents of the media.'
docs['med']['min'] = '''
Whether the media is a minimal media (True) or not (False).'''
docs['med']['def'] = 'Whether the media is defined (True) or not (False).'
docs['med']['solid'] = 'Whether the media is solid (True) or liquid (False).'
docs['med']['date'] = '''
The date of the last time this media definition was modified or created.'''
docs['med']['type'] = '''
The media type, e.g. experimental, biolog, predicted, rescue.'''
docs['med']['cond'] = '''
The names and/or KBase IDs of compounds and their concentrations and units in
the media in the format
compound1$concentration$units!compound2$concentration$units!'''
docs['med']['unit'] = 'Allowed units are g/L, mol/L, and vol%.'


# TIME SERIES TABLE - 12

docs['ts']['pre'] = 'A time series orders experimental units temporally.'
docs['ts']['name'] = 'The name of this time series.'
docs['ts']['comm'] = 'Any comments on this time series.'
docs['ts']['unit'] = '''
The units of time for this time series, e.g. 'seconds', 'hours', or more
abstractly, 'number of times culture grown to saturation.\''''


# EXPERIMENT META TABLE - 13

docs['meta']['pre'] = '''
The experiment meta information includes the name, description, etc. of
the experiment, which consists of several experimental units. The description
should provide the experimental plan, general results, and conclusions, if
possible.'''
docs['meta']['title'] = 'The title of this experiment.'
docs['meta']['desc'] = 'Description of the experiment.'
docs['meta']['date'] = 'The date this experiment was started.'
docs['meta']['comm'] = 'Any comments for the experiment.'
docs['meta']['ppl'] = '''
The source or KBase IDs and roles (e.g. PI, Experimentalist, Technician, etc.)
of people that participated in this experiment and their roles in the format
personid,role;personid,role;. '''
docs['meta']['pub'] = '''
The publication IDs of the publications describing this experiment in the
format pub1;pub2;pub3'''


# EXPERIMENTAL UNIT TABLE - 14

docs['eu']['pre'] = '''
An experimental unit denotes a particular strain used in an experiment and the
environment the experiment was performed in and links measurements to that
pairing. Each experimental unit belongs to a particular experiment.'''
docs['eu']['post'] = '''
* If a Timeseries-id is supplied a Time value must be supplied.'''
docs['eu']['exp'] = '''
The source or KBase ID of the ExperimentMeta entity to which the experimental
unit belongs'''
docs['eu']['env'] = '''
The source or KBase ID of the environment used for the experimental unit.'''
docs['eu']['str'] = '''
The source or KBase ID of the strain in the experimental unit.  Leave this
field empty to denote a control experimental unit without a strain.'''
docs['eu']['grp'] = '''
The source or KBase ID of the group this experimental unit belongs to.'''
docs['eu']['loc'] = '''
The location of the experimental unit in the group. Often a plate locator,
e.g. 'G11' for 96 well plates.'''
docs['eu']['gmet'] = '''
Boolean that denotes that this ExperimentalUnit's data measures the group of
EUs as a whole - for example, summary statistics. False if the EU is not part
of a group. Generally there should be at most one meta EU per group.'''
docs['eu']['ts'] = '''
The source or KBase ID of the time series this experimental unit belongs to.'''
docs['eu']['time'] = 'The time at which the data was taken.'
docs['eu']['tsmet'] = '''
Boolean that denotes that this ExperimentalUnit's data measures the
time series as a whole - for example, lag and doubling times for bacterial
growth curves. False if the EU is not part of a time series. Generally there
should be at most one meta EU per time series.'''

# MEASUREMENT DESCRIPTION TABLE - 15

docs['md']['pre'] = '''A measurement description (MD) explains what a                       
particular measurement represents. The measurement table is a generic table used to store all measurements.
For the case of expression all the measurements should be some  Please try   
to use MDs that already exist in kbase as algorithms are keyed to MDs.  
NOTE * Really this file should not exist (or not have values) unless there is some sort of special measurement 
type that you are doing that has not been previously described (not previously stored in the database).''' 
docs['md']['name'] = 'The name of the measurement.' 
docs['md']['desc'] = '''       
The description of the measurement and what it means. Contains which attributes  
in the Measurement table should be filled in for this measurement description 
and what those values represent. Generally either the value and/or one or more  
of the statistical fields should be included.''' 
docs['md']['unit'] = 'The units for the measurement.' 
docs['md']['cat'] = '''    
The category the measurement fits into, for example phenotype, experimental
input, or environment.'''



###############################################
#
# Relationships
#
###############################################

class CompoundRel(_ExchangeFormatRelationship):

    SEPARATOR = _COMPOUND_COL_SEP

    ORDER = ['compound', 'concentration', 'units']

    DEF = {'compound': _CompoundArgument('compound'),
           'concentration': _FloatArgument('concentration', greaterthan=0),
           'units': _UnitsArgument('units', ALLOWED_UNITS),
           }

    # I suppose g/L should really be converted to mol/L, but not always
    #possible
    def __lt__(self, other):
        return (self.compound, self.units, self.concentration) < \
            (other.compound, self.units, self.concentration)

    def get_id_with_spec(self):
        return self.compound.get_id(), self.DEF['compound']


class ConditionsArgument(_ManyToManyArgument, _HasCompounds):

    DOC_TYPE = 'See description'

    def __init__(self, argumentName, relinfo, docs=None, noentryok=False,
                 unique=True):
        super(ConditionsArgument, self).__init__(
            argumentName, CompoundRel, _COMPOUND_ROW_SEP, relinfo, docs=docs,
            noentryok=noentryok, unique=unique)

    def compounds(self, argument):
        return [item.compound for item in argument]


class PersonRel(_ExchangeFormatRelationship):

    SEPARATOR = _PERSON_COL_SEP

    ORDER = ['personID', 'role']

    DEF = {'personID': _SourceOrKBID_Argument('personID', 'Person'),
           'role': _StringArgument('role'),
           }

    def __lt__(self, other):
        return (str(self.personID).lower(), self.role.lower()) < \
               (str(other.personID).lower(), self.role.lower())

PublicationRel = _create_m2m_relclass('PublicationRel', _PubID_Argument,
                                     'Publication')

KnockoutRel = _create_m2m_relclass('KnockoutRel', _KBaseID_Argument,
                                  'Feature')

ParameterRel = _createkeyvalueclass('ParameterRel', 'value', _PARAM_COL_SEP,
                                   'Parameter')

PersonRelSample = _create_m2m_relclass('PersonRelSample', _SourceOrKBID_Argument, 'Person')

SampleSeriesRel = _create_m2m_relclass('SampleSeriesRel', _SourceOrKBID_Argument, 'Sample')


###########################################
#
# Entities
#
#   1.  sample.tab
#   2.  series.tab
#   3.  platform.tab
#   4.  measurement.tab 
#   5.  sample_annotation.tab 
#   6.  person.tab
#   7.  protocol.tab
#   8.  publication.tab
#   9.  strain.tab
#   10. environment.tab
#   11. media.tab
#   12. time_series.tab
#   13. experimentMeta.tab
#   14. experimentalUnit.tab
#   15. measurementDescription.tab      
# 
###########################################

# Sample - 1

class Sample(_ExchangeFormatEntity):

    DOC_PRE = docs['sam']['pre']

    ID_PREFIX = 'kb|sample'

    INC_ID = 'sample'

    DEF = { 'title': _LongStringArgument('title', docs=docs['sam']['title'], cdsname='title',noentryok = 'R', unique = False),
            'description': _LongStringArgument('description', docs=docs['sam']['description'], cdsname='description', noentryok = 'R', unique = False),
            'molecule': _StringEnumerationArgument('molecule', ALLOWED_MOLECULES, docs=docs['sam']['molecule'], cdsname='molecule', unique = False),
            'type': _StringEnumerationArgument('type', ALLOWED_TYPES, docs=docs['sam']['type'], cdsname='type', unique = False),
            'externalSourceId': _StringArgument('externalSourceId', docs=docs['sam']['externalSourceId'], cdsname='externalSourceId', noentryok = 'O', unique = False),
            'dataSource': _StringArgument('dataSource', docs=docs['sam']['dataSource'], cdsname='dataSource', noentryok = 'O', unique = False),
            'kbaseSubmissionDate': _DateTimeArgument('kbaseSubmissionDate', docs=docs['sam']['kbaseSubmissionDate'], 
                                                 cdsname='kbaseSubmissionDate', noentryok = 'R', unique=False),
            'externalSourceDate': _DateTimeArgument('externalSourceDate', docs=docs['sam']['externalSourceDate'], 
                                                cdsname='externalSourceDate', noentryok = 'O',unique=False),
            'originalLog2Median': _FloatArgument('originalLog2Median', docs=docs['sam']['originalLog2Median'], cdsname='originalLog2Median',
                                                 noentryok='R', unique=False),
            'custom': _SemiBooleanArgument('custom', docs=docs['sam']['custom'], cdsname='custom', unique=False),
            'persons': _ManyToManyArgument('persons', PersonRelSample, _PERSONSAMPLE_ROW_SEP, 
                                           _RelInfo('SampleContactPerson',reverse=True), docs=docs['sam']['persons'], 
                                           noentryok ='O', unique=False),
            'strain': _SourceOrKBID_Argument('strain-id', 'Strain', _RelInfo('StrainWithSample'),
                                             docs=docs['sam']['strain'], unique=False),
            'platform': _SourceOrKBID_Argument('platform-id', 'Platform', _RelInfo('PlatformWithSamples'),
                                               docs=docs['sam']['platform'], noentryok='R', unique=False),
            'protocol': _SourceOrKBID_Argument('protocol-id', 'Protocol', _RelInfo('ProtocolForSample'),
                                               docs=docs['sam']['protocol'], noentryok='R', unique=False),
            'experimentalUnit': _SourceOrKBID_Argument('experimentalUnit-id', 'ExperimentalUnit', _RelInfo('HasExpressionSample'),
                                                       docs=docs['sam']['experimentalUnit'], noentryok='R', unique=False),
            'defaultControlSampleId': _SourceOrKBID_Argument('defaultControlSample-id', 'Sample', _RelInfo('DefaultControlSample'), 
                                                       docs=docs['sam']['defaultControlSampleId'], noentryok='R', unique=False), 
            'dataQualityLevel': _IntArgument(None, cdsname='dataQualityLevel', unique = False), 
          }

    def __init__(self, sourceID, title, description, molecule, type, externalSourceId, 
                 dataSource, kbaseSubmissionDate, externalSourceDate, originalLog2Median, custom,
                         persons, strain, platform, protocol, experimentalUnit, defaultControlSampleId):
        if kbaseSubmissionDate in ('', None, self.NO_ENTRY_SYM):
            kbaseSubmissionDate = str(datetime.datetime.now())
        dataQualityLevel = 1
        super(Sample, self).__init__(sourceID, title, description, molecule, type, externalSourceId, 
                 dataSource, kbaseSubmissionDate, externalSourceDate, originalLog2Median, custom,
                         persons, strain, platform, protocol, experimentalUnit, defaultControlSampleId, dataQualityLevel)


# Series - 2

class Series(_ExchangeFormatEntity):

    DOC_PRE = docs['ser']['pre']
	
    ID_PREFIX = 'kb|series'
	
    INC_ID = 'series'
	
    DEF = { 'title': _LongStringArgument('title', docs=docs['ser']['title'], cdsname='title', unique = False),
	    'summary': _LongStringArgument('summary', docs=docs['ser']['summary'], cdsname='summary', noentryok = 'R', unique = False),
	    'design': _LongStringArgument('design', docs=docs['ser']['design'], cdsname='design', noentryok = 'R', unique = False),
	    'externalSourceId': _StringArgument('externalSourceId', docs=docs['ser']['externalSourceId'], cdsname='externalSourceId', noentryok = 'O', unique = False),
	    'kbaseSubmissionDate': _DateTimeArgument('kbaseSubmissionDate', docs=docs['ser']['kbaseSubmissionDate'], 
						 cdsname='kbaseSubmissionDate', noentryok = 'R', unique=False),
	    'externalSourceDate': _DateTimeArgument('externalSourceDate', docs=docs['ser']['externalSourceDate'], 
                                                cdsname='externalSourceDate', noentryok = 'O',unique=False),
	    'publicationIds': _ManyToManyArgument('publicationIds', PublicationRel, _PUBLICATION_ROW_SEP, 
						  _RelInfo('SeriesPublishedIn', reverse=True), docs=docs['ser']['publicationIds'], noentryok='O'),
	    'samples': _ManyToManyArgument('samples', SampleSeriesRel, _SAMPLE_ROW_SEP, _RelInfo('SampleInSeries'),docs=docs['ser']['samples']),
          }
			
    def __init__(self, sourceID, title, summary, design, externalSourceId, 
                 kbaseSubmissionDate, externalSourceDate, publicationIds, samples):
        if kbaseSubmissionDate in ('', None, self.NO_ENTRY_SYM): 
            kbaseSubmissionDate = str(datetime.datetime.now())
        super(Series, self).__init__(sourceID, title, summary, design, externalSourceId, 
                                     kbaseSubmissionDate, externalSourceDate, publicationIds, samples)


# Platform - 3			
			
class Platform(_ExchangeFormatEntity):

    DOC_PRE = docs['plt']['pre']
	
    ID_PREFIX = 'kb|platform'
	
    INC_ID = 'platform'
	
    DEF = { 'title': _LongStringArgument('title', docs=docs['plt']['title'], cdsname='title', noentryok = 'R', unique = False),
	    'technology': _LongStringArgument('technology', docs=docs['plt']['technology'], cdsname='technology', noentryok = 'R', unique = False),
	    'type': _StringEnumerationArgument('type', ALLOWED_TYPES, docs=docs['plt']['type'], cdsname='type', unique = False),
	    'externalSourceId': _StringArgument('externalSourceId', docs=docs['plt']['externalSourceId'], cdsname='externalSourceId', noentryok = 'O', unique = False),
	    'strain': _SourceOrKBID_Argument('strain-id', 'Strain', _RelInfo('StrainWithPlatforms'), docs=docs['plt']['strain'], unique=False),
           }
			

 
 
class Measurement(_ExchangeFormatEntity): 
 
    DOC_PRE = docs['meas']['pre'] 
 
    DOC_POST = docs['meas']['post'] 
 
    ID_PREFIX = 'kb|meas' 
 
    INC_ID = 'measurement' 
 
    ORDER = ['sampleID', 'measdescID', 'featureKBID', 'value', 'mean', 
             'median', 'stddev', 'N', 'pvalue', 'zscore'] 
 
    DEF = {'sampleID': _SourceOrKBID_Argument(
                            'sample-id', 'Sample',
                            _RelInfo('SampleMeasurements'),
                            docs=docs['meas']['sampleId'], unique=False),
           'measdescID': _SourceOrKBID_Argument(
                             'measurement-description-id', 'MeasurementDescription',
                             _RelInfo('DescribesMeasurement'), 
                             docs=docs['meas']['desc'], unique=False),
           'featureKBID': _KBaseID_Argument( 
                              'KB-feature-id', 'Feature', 
                              _RelInfo('FeatureMeasuredBy'),
                              docs=docs['meas']['feat'], 
                              unique=False), 
           'value': _FloatArgument('value', docs=docs['meas']['val'],
                                   cdsname='value',
                                   unique=False),
           'mean': _FloatArgument('mean', docs=docs['meas']['mean'],
                                  cdsname='mean', noentryok='O', 
                                  unique=False), 
           'median': _FloatArgument('median', docs=docs['meas']['med'], 
                                    cdsname='median', noentryok='O', 
                                    unique=False), 
           'stddev': _FloatArgument( 
                         'standard-deviation', docs=docs['meas']['std'], 
                         cdsname='stddev', noentryok='O', unique=False, 
                         greaterthanorequal=0), 
           'N': _IntArgument('N', docs=docs['meas']['N'], noentryok='O', 
                             unique=False, greaterthanorequal=2), 
           'pvalue': _FloatArgument( 
                         'p-value', docs=docs['meas']['pval'], 
                         cdsname='p-value', noentryok='O', unique=False, 
                         greaterthanorequal=0, lessthanorequal=1), 
           'zscore': _FloatArgument('Z-score', docs=docs['meas']['Z'], 
                                    cdsname='Z-score', noentryok='O', 
                                    unique=False), 
           }  # completely identical measurements ok                                                                                      

# SampleAnnotation - 5

class SampleAnnotation(_ExchangeFormatEntity):

   DOC_PRE = docs['sam_ann']['pre']
	
   ID_PREFIX = 'kb|sampAnn'

   INC_ID = 'sample_annotation'
	
   DEF = { 'ontologyID': _StringID_Argument('ontology-id', 'Ontology', _RelInfo('OntologyForSample'),
                                        docs=docs['sam_ann']['ontologyID']),
           'annotationDate': _DateTimeArgument('annotationDate', docs=docs['sam_ann']['annotationDate'], 
                                                cdsname='annotationDate', noentryok= 'R', unique=False), 
           'person': _SourceOrKBID_Argument('person-id', 'Person', _RelInfo('PersonAnnotatedSample'),
                                            docs=docs['sam_ann']['person'], noentryok='O', unique=False),
           'sample': _SourceOrKBID_Argument('sample-id', 'Sample', _RelInfo('SampleHasAnnotations'),
                                            docs=docs['sam_ann']['sample']),
         }  
   def __init__(self, sourceID, ontologyID, annotationDate, person, sample):
       if annotationDate in ('', None, self.NO_ENTRY_SYM): 
           annotationDate = str(datetime.datetime.now()) 
       super(SampleAnnotation, self).__init__(sourceID, ontologyID, annotationDate, person, sample)

			
# Person - 6

class Person(_ExchangeFormatEntity):

    DOC_PRE = docs['per']['pre']

    ID_PREFIX = 'kb|per'

    INC_ID = 'person'

    DEF = {'firstName': _StringArgument('First-Name', docs=docs['per']['name'],
                                        cdsname='firstName'),
           'lastName': _StringArgument('Last-Name', docs=docs['per']['sur'],
                                       cdsname='lastName'),
           'contactEmail': _StringArgument('Contact-Email',
                                           docs=docs['per']['email'],
                                           cdsname='contactEmail'),
           'institution': _StringArgument('Institution',
                                          docs=docs['per']['inst'],
                                          cdsname='institution'),
           }

		   
# Protocol - 7

class Protocol(_ExchangeFormatEntity):

    DOC_PRE = docs['pro']['pre']

    ID_PREFIX = 'kb|pro'

    INC_ID = 'protocol'

    DEF = {'name': _StringArgument('Name', docs=docs['pro']['name'],
                                   cdsname='name'),
           'description': _TextArgument('Description',
                                        docs=docs['pro']['desc'],
                                        cdsname='description'),
           'publication': _PubID_Argument(
                              'Publication', 'Publication',
                              _RelInfo('PublishedProtocol'),
                              docs=docs['pro']['pub'], noentryok='O'),
           }


# Publication - 8

class Publication(_PublicationEntity):

    DOC_PRE = docs['pub']['pre']

    INC_ID = 'publication'

    DEF = {'link': _URL_Argument(None, cdsname='link'),
           # TODO eventually get 2 below from link
           'pubdate': _DateTimeArgument('Pubdate', docs=docs['pub']['date'],
                                    cdsname='pubdate', unique=False),
           'title': _StringArgument('Title', docs=docs['pub']['title'],
                                    cdsname='title', unique=False)
           }

    def __init__(self, sourceID, pubdate, title):
        link = _PublicationID(sourceID).getlink()
        super(Publication, self).__init__(sourceID, pubdate, title, link)

		
# Strain - 9

class Strain(_ExchangeFormatEntity):

    DOC_PRE = docs['str']['pre']

    DOC_POST = docs['str']['post']

    ID_PREFIX = 'kb|str'

    INC_ID = 'strain'

    DEF = {'name': _StringArgument('Name', docs=docs['str']['name'],
                                   cdsname='name', noentryok='R',
                                   unique=False),
           'description': _StringArgument(
                              'Description', docs=docs['str']['desc'],
                              cdsname='description', noentryok='R',
                              unique=False),
           'aggregateData': _SemiBooleanArgument(
                                'AggregateData', docs=docs['str']['agg'],
                                cdsname='aggregateData', unique=False),
           'wildtype': _SemiBooleanArgument('Wildtype', docs=docs['str']['wt'],
                                            cdsname='wildtype', unique=False),
           'referenceStrain': _SemiBooleanArgument(
                                  'Reference-strain', docs=docs['str']['ref'],
                                  cdsname='referenceStrain', unique=False),
           'genomeID': _KBaseID_Argument(
                           'Genome-id', 'Genome', _RelInfo('GenomeParentOf'),
                           docs=docs['str']['gen'], unique=False),
           'strainID': _SourceOrKBID_Argument('Parent-strain-id', 'Strain',
                                              _RelInfo('StrainParentOf'),
                                              docs=docs['str']['str'],
                                              noentryok='O', unique=False),
           'knockouts': _ManyToManyArgument(
                            'Knockouts', KnockoutRel, _KNOCKOUT_ROW_SEP,
                            _RelInfo('HasKnockoutIn', reverse=True),
                            docs=docs['str']['ko'], noentryok='O',
                            unique=False),
           }  # can have completely identical strains in the DB

    def _finishtypecheck(self):
        if self.referenceStrain:
            if not self.wildtype:
                raise _ExchangeFormatValueError('A reference strain must ' +
                                               'always be wildtype')
            if self.aggregateData:
                raise _ExchangeFormatValueError('A reference strain cannot ' +
                                               'represent aggregate data')
        if self.wildtype and (self.strainID or self.knockouts):
            raise _ExchangeFormatValueError('A wildtype strain cannot have ' +
                                            'a strain parent or knockouts')


# Environment - 10

class Environment(_ExchangeFormatEntity):

    INC_ID = 'environment'

    ID_PREFIX = 'kb|env'

    DOC_PRE = docs['env']['pre']

    DEF = {'description': _StringArgument(
                              'Description', docs=docs['env']['desc'],
                              cdsname='description', noentryok='R',
                              unique=False),
           'temperature': _FloatArgument(
                              'Temperature', docs=docs['env']['temp'],
                              cdsname='temperature', greaterthan=0),
           'oxygenConcentration': _FloatArgument(
                                      'OxygenConcentration',
                                      docs=docs['env']['oxy'],
                                      cdsname='oxygenConcentration',
                                      greaterthanorequal=-1),
           'pH': _FloatArgument('pH', docs=docs['env']['pH'], noentryok='O'),
           'mediaID': _SourceOrKBID_Argument(
                          'Media-id', 'Media', docs=docs['env']['med'],
                          relinfo=_RelInfo('UsedIn'), noentryok='O'),
           'conditions': ConditionsArgument(
                             'Conditions', docs=docs['env']['cond'],
                             relinfo=_RelInfo('IncludesAdditionalCompounds',
                                               reverse=True),
                             noentryok='O'),
           'parameters': _ManyToManyArgument(
                             'Parameters', ParameterRel, _PARAM_ROW_SEP,
                             docs=docs['env']['param'],
                             relinfo=_RelInfo('HasParameter', reverse=True),
                             noentryok='O')
           }


# Media - 11

class Media(_ExchangeFormatEntity):

    DOC_PRE = docs['med']['pre']

    ID_PREFIX = 'kb|med'

    INC_ID = 'media'

    DEF = {'name': _StringArgument('Name', docs=docs['med']['name'],
                                   cdsname='name', unique=False),
           'description': _StringArgument(
                              'Description', docs=docs['med']['desc'],
                              cdsname='description', unique=False,
                              noentryok='R'),
           'minimal': _SemiBooleanArgument(
                          'Is-minimal', docs=docs['med']['min'],
                          cdsname='is-minimal'),
           'defined': _SemiBooleanArgument(
                          'Is-defined', docs=docs['med']['def'],
                          cdsname='is-defined'),
           'solid': _SemiBooleanArgument('Solid', docs=docs['med']['solid'],
                                         cdsname='solid'),
           'mod_date': _DateTimeArgument('Mod-date', docs=docs['med']['date'],
                                     cdsname='mod-date', unique=False),
           'type': _StringArgument('Type', docs=docs['med']['type'],
                                   cdsname='type', unique=False),
           'conditions': ConditionsArgument(
                             'Conditions',
                             _RelInfo('HasPresenceOf', reverse=True),
                             docs=docs['med']['cond'], noentryok='O')}   


# TimeSeries - 12

class TimeSeries(_ExchangeFormatEntity):

    DOC_PRE = docs['ts']['pre']

    ID_PREFIX = 'kb|ts'

    INC_ID = 'time_series'

    DEF = {'name': _StringArgument('Name', docs['ts']['name'], cdsname='name',
                                   noentryok='R', unique=False),
           'comments': _StringArgument('Comments', docs['ts']['comm'],
                                       cdsname='comments', noentryok='O',
                                       unique=False),
           'timeUnits': _StringArgument('TimeUnits', docs['ts']['unit'],
                                        cdsname='timeUnits', unique=False),
           }  # ok to have identical time series other than the source id

 
# ExperimentMeta - 13

class ExperimentMeta(_ExchangeFormatEntity):

    DOC_PRE = docs['meta']['pre']

    ID_PREFIX = 'kb|expm'

    INC_ID = 'experiment_meta'

    DEF = {'title': _StringArgument('Title', docs=docs['meta']['title'],
                                    cdsname='title'),
           'description': _TextArgument('Description',
                                        docs=docs['meta']['desc'],
                                        cdsname='description', noentryok='R'),
           'startDate': _DateTimeArgument('Start-date', docs=docs['meta']['date'],
                                      cdsname='startDate'),
           'comments': _TextArgument('Comments', docs=docs['meta']['comm'],
                                     cdsname='comments', noentryok='O'),
           'people': _ManyToManyArgument('People', PersonRel, _PERSON_ROW_SEP,
                                         _RelInfo('PerformedExperiment'),
                                         docs=docs['meta']['ppl']),
           'publications': _ManyToManyArgument(
                               'Publication', PublicationRel,
                               _PUBLICATION_ROW_SEP,
                               _RelInfo('PublishedExperiment'),
                               docs=docs['meta']['pub'], noentryok='O'),
           }

		   
# ExperimentalUnit - 14

class ExperimentalUnit(_ExchangeFormatEntity):

    # TODO if group type is microarray all envIDs for EUs should be same

    DOC_PRE = docs['eu']['pre']

    DOC_POST = docs['eu']['post']

    ID_PREFIX = 'kb|expu'

    INC_ID = 'experimental_unit'

    ORDER = ['experimentID', 'environmentID', 'strainID', 'groupID',
             'location', 'groupmeta', 'timeseriesID', 'time', 'timemeta']

    DEF = {'experimentID': _SourceOrKBID_Argument(
                               'Experiment-id', 'ExperimentMeta',
                               _RelInfo('HasExperimentalUnit'),
                               docs=docs['eu']['exp']),
           'environmentID': _SourceOrKBID_Argument(
                                'Environment-id', 'Environment',
                                _RelInfo('IsContextOf'),
                                docs=docs['eu']['env']),
           'strainID': _SourceOrKBID_Argument(
                           'Strain-id', 'Strain', _RelInfo('EvaluatedIn'),
                           docs=docs['eu']['str'], noentryok='O'),
           'groupID': _SourceOrKBID_Argument(
                          'Group-id', 'ExperimentalUnitGroup',
                          _RelInfo('ContainsExperimentalUnit',
                                   ('location', 'groupmeta')),
                          docs=docs['eu']['grp'], noentryok='O'),
           'location': _StringArgument('Location', cdsname='location',
                                       docs=docs['eu']['loc'], noentryok='O'),
           'groupmeta': _SemiBooleanArgument(
                            'Group-meta', docs=docs['eu']['gmet'],
                            cdsname='groupMeta'),
           'timeseriesID': _SourceOrKBID_Argument(
                               'Timeseries-id', 'TimeSeries',
                               _RelInfo('OrdersExperimentalUnit',
                                        ('time', 'timemeta')),
                               docs=docs['eu']['ts'], noentryok='O'),
           'time': _FloatArgument('Time', docs=docs['eu']['time'],
                                  cdsname='time', noentryok='C'),
           'timemeta': _SemiBooleanArgument('Time-meta',
                                            docs=docs['eu']['tsmet'],
                                            cdsname='timeMeta'),
           }

    def _finishtypecheck(self):
        if self.timeseriesID and self.time is None:
            raise _ExchangeFormatValueError(
                'If a time series ID is specified a time value must be ' +
                'provided.')


class MeasurementDescription(_ExchangeFormatEntity): 
 
    DOC_PRE = docs['md']['pre'] 
 
    ID_PREFIX = 'kb|measdesc' 
 
    INC_ID = 'measurement_description' 
 
    DEF = {'name': _StringArgument('Name', docs=docs['md']['name'], 
                                   cdsname='name', unique=False), 
           'description': _TextArgument('Description', docs=docs['md']['desc'], 
                                        cdsname='description'), 
           'unitOfMeasure': _StringArgument('Units', docs=docs['md']['unit'], 
                                           cdsname='unitOfMeasure'), 
           'category': _StringArgument('Category', docs=docs['md']['cat'], 
                                       cdsname='category'), 
           } 

 
EXCHANGE_FORMAT = _ExchangeFormat(EF_NAME, PREAMBLE, VERSION, FILE_SUFFIX,
                    _EF_NO_ENTRY_SYMBOL, _EF_LINE_SEP,
                    [Sample, Series, Platform, Measurement, SampleAnnotation, 
                     Person, Protocol, Publication, Strain, Environment,
                     Media, TimeSeries, ExperimentMeta, ExperimentalUnit, MeasurementDescription])
