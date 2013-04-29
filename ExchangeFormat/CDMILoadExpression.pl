#!/usr/bin/perl -w

#
# Copyright (c) 2003-2006 University of Chicago and Fellowship
# for Interpretations of Genomes. All Rights Reserved.
#
# This file is part of the SEED Toolkit.
#
# The SEED Toolkit is free software. You can redistribute
# it and/or modify it under the terms of the SEED Toolkit
# Public License.
#
# You should have received a copy of the SEED Toolkit Public License
# along with this program; if not write to the University of Chicago
# at info@ci.uchicago.edu or the Fellowship for Interpretation of
# Genomes at veronika@thefig.info or download a copy from
# http://www.theseed.org/LICENSE.TXT.
#

use strict;
use Bio::KBase::CDMI::CDMILoader;
use Bio::KBase::CDMI::CDMI;

    $| = 1;
    my ($clear, $keep);
    # Connect to the CDMI and create the loader object.
    print "Connecting to database.\n";
    my $cdmi = Bio::KBase::CDMI::CDMI->new_for_script(clear => \$clear, keep => \$keep);
    my $loader = Bio::KBase::CDMI::CDMILoader->new($cdmi);
    # Get the directories.
    my ($inDirectory) = @ARGV;
    if (! $inDirectory) {
        die "No input directory specified.";
    } elsif (! -d $inDirectory) {
        die "Invalid input directory $inDirectory.";
    }
    # Get the statistics object.
    my $stats = $loader->stats;
    
    my @tables = qw(
                    Publication SampleInSeries IsContextOf Media
                    Environment Platform ContainsExperimentalUnit SampleAnnotation
                    GenomeParentOf UsedIn HasKnockoutIn Parameter
                    PerformedExperiment EvaluatedIn ExperimentMeta SampleContactPerson
                    StrainWithSample DefaultControlSample PlatformWithSamples HasExperimentalUnit
                    IncludesAdditionalCompounds OntologyForSample HasParameter FeatureMeasuredBy
                    SeriesPublishedIn SampleMeasurements Person TimeSeries
                    SampleHasAnnotations PublishedExperiment PublishedProtocol ExperimentalUnit
                    DescribesMeasurement Protocol OrdersExperimentalUnit Series
                    ProtocolForSample StrainWithPlatforms Sample Strain
                    PersonAnnotatedSample HasExpressionSample HasPresenceOf Measurement
                    MeasurementDescription StrainParentOf
                    );
    
     # Clear the tables, if necessary.
    if ($clear) {
        for my $table (@tables) {
            print "Recreating $table.\n";
            $cdmi->CreateTable($table, 1);
        }
    }
    
    # Initialize the relation loaders.
    $loader->SetRelations(@tables);
    # Load the simple files. 
    
    $loader->SimpleLoad($inDirectory, 'Publication.load', 'Publication', { id => 0, link => 1, pubdate => [2, 'timeStamp', 0], title => [3, 'copy', ''] }, 1);
    $loader->SimpleLoad($inDirectory, 'SampleInSeries.load', 'SampleInSeries', { from_link => 0, to_link => 1 }, 1);
    $loader->SimpleLoad($inDirectory, 'IsContextOf.load', 'IsContextOf', { from_link => 0, to_link => 1 }, 1);
    $loader->SimpleLoad($inDirectory, 'Media.load', 'Media', { source_id => 0, id => 1, name => [2, 'copy', ''], solid => [3, 'semi-boolean', '?'], is_defined => [4, 'semi-boolean', '?'], mod_date => [5, 'timeStamp', 0], type => [6, 'copy', ''], is_minimal => [7, 'semi-boolean', '?'], description => [8, 'copy', ''] }, 1);
    $loader->SimpleLoad($inDirectory, 'Environment.load', 'Environment', { source_id => 0, id => 1, oxygenConcentration => 2, description => [3, 'copy', ''], pH => 4, temperature => 5 }, 1);
    $loader->SimpleLoad($inDirectory, 'Platform.load', 'Platform', { source_id => 0, id => 1, technology => 2, type => 3, externalSourceId => [4, 'copy', ''], title => 5 }, 1);
    $loader->SimpleLoad($inDirectory, 'ContainsExperimentalUnit.load', 'ContainsExperimentalUnit', { from_link => 0, to_link => 1, location => [2, 'copy', ''], groupMeta => [3, 'semi-boolean', '?'] }, 1);
    $loader->SimpleLoad($inDirectory, 'SampleAnnotation.load', 'SampleAnnotation', { source_id => 0, id => 1, annotationDate => [2, 'timeStamp', 0] }, 1);
    $loader->SimpleLoad($inDirectory, 'GenomeParentOf.load', 'GenomeParentOf', { from_link => 0, to_link => 1 }, 1);
    $loader->SimpleLoad($inDirectory, 'UsedIn.load', 'UsedIn', { from_link => 0, to_link => 1 }, 1);
    $loader->SimpleLoad($inDirectory, 'HasKnockoutIn.load', 'HasKnockoutIn', { from_link => 0, to_link => 1 }, 1);
    $loader->SimpleLoad($inDirectory, 'Parameter.load', 'Parameter', { id => 0 }, 1);
    $loader->SimpleLoad($inDirectory, 'PerformedExperiment.load', 'PerformedExperiment', { from_link => 0, to_link => 1, role => [2, 'copy', ''] }, 1);
    $loader->SimpleLoad($inDirectory, 'EvaluatedIn.load', 'EvaluatedIn', { from_link => 0, to_link => 1 }, 1);
    $loader->SimpleLoad($inDirectory, 'ExperimentMeta.load', 'ExperimentMeta', { source_id => 0, id => 1, startDate => [2, 'timeStamp', 0], description => [3, 'copy', ''], title => [4, 'copy', ''], comments => [5, 'copy', ''] }, 1);
    $loader->SimpleLoad($inDirectory, 'SampleContactPerson.load', 'SampleContactPerson', { from_link => 0, to_link => 1 }, 1);
    $loader->SimpleLoad($inDirectory, 'StrainWithSample.load', 'StrainWithSample', { from_link => 0, to_link => 1 }, 1);
    $loader->SimpleLoad($inDirectory, 'DefaultControlSample.load', 'DefaultControlSample', { from_link => 0, to_link => 1 }, 1);
    $loader->SimpleLoad($inDirectory, 'PlatformWithSamples.load', 'PlatformWithSamples', { from_link => 0, to_link => 1 }, 1);
    $loader->SimpleLoad($inDirectory, 'HasExperimentalUnit.load', 'HasExperimentalUnit', { from_link => 0, to_link => 1 }, 1);
    $loader->SimpleLoad($inDirectory, 'IncludesAdditionalCompounds.load', 'IncludesAdditionalCompounds', { from_link => 0, to_link => 1, units => 2, concentration => 3 }, 1);
    $loader->SimpleLoad($inDirectory, 'OntologyForSample.load', 'OntologyForSample', { from_link => 0, to_link => 1 }, 1);
    $loader->SimpleLoad($inDirectory, 'HasParameter.load', 'HasParameter', { from_link => 0, to_link => 1, value => [2, 'copy', ''] }, 1);
    $loader->SimpleLoad($inDirectory, 'FeatureMeasuredBy.load', 'FeatureMeasuredBy', { from_link => 0, to_link => 1 }, 1);
    $loader->SimpleLoad($inDirectory, 'SeriesPublishedIn.load', 'SeriesPublishedIn', { from_link => 0, to_link => 1 }, 1);
    $loader->SimpleLoad($inDirectory, 'SampleMeasurements.load', 'SampleMeasurements', { from_link => 0, to_link => 1 }, 1);
    $loader->SimpleLoad($inDirectory, 'Person.load', 'Person', { source_id => 0, id => 1, contactEmail => [2, 'copy', ''], lastName => [3, 'copy', ''], institution => [4, 'copy', ''], firstName => [5, 'copy', ''] }, 1);
    $loader->SimpleLoad($inDirectory, 'TimeSeries.load', 'TimeSeries', { source_id => 0, id => 1, timeUnits => [2, 'copy', ''], name => [3, 'copy', ''], comments => [4, 'copy', ''] }, 1);
    $loader->SimpleLoad($inDirectory, 'SampleHasAnnotations.load', 'SampleHasAnnotations', { from_link => 0, to_link => 1 }, 1);
    $loader->SimpleLoad($inDirectory, 'PublishedExperiment.load', 'PublishedExperiment', { from_link => 0, to_link => 1 }, 1);
    $loader->SimpleLoad($inDirectory, 'PublishedProtocol.load', 'PublishedProtocol', { from_link => 0, to_link => 1 }, 1);
    $loader->SimpleLoad($inDirectory, 'ExperimentalUnit.load', 'ExperimentalUnit', { source_id => 0, id => 1 }, 1);
    $loader->SimpleLoad($inDirectory, 'DescribesMeasurement.load', 'DescribesMeasurement', { from_link => 0, to_link => 1 }, 1);
    $loader->SimpleLoad($inDirectory, 'Protocol.load', 'Protocol', { source_id => 0, id => 1, description => [2, 'copy', ''], name => [3, 'copy', ''] }, 1);
    $loader->SimpleLoad($inDirectory, 'OrdersExperimentalUnit.load', 'OrdersExperimentalUnit', { from_link => 0, to_link => 1, time => 2, timeMeta => [3, 'semi-boolean', '?'] }, 1);
    $loader->SimpleLoad($inDirectory, 'Series.load', 'Series', { source_id => 0, id => 1, title => 2, summary => 3, externalSourceDate => [4, 'timeStamp', 0], design => 5, externalSourceId => [6, 'copy', ''], kbaseSubmissionDate => [7, 'timeStamp', 0] }, 1);
    $loader->SimpleLoad($inDirectory, 'ProtocolForSample.load', 'ProtocolForSample', { from_link => 0, to_link => 1 }, 1);
    $loader->SimpleLoad($inDirectory, 'StrainWithPlatforms.load', 'StrainWithPlatforms', { from_link => 0, to_link => 1 }, 1);
    $loader->SimpleLoad($inDirectory, 'Sample.load', 'Sample', { source_id => 0, id => 1, externalSourceDate => [2, 'timeStamp', 0], description => 3, title => 4, molecule => 5, dataSource => [6, 'copy', ''], custom => [7, 'semi-boolean', '?'], kbaseSubmissionDate => [8, 'timeStamp', 0], dataQualityLevel => 9, type => 10, originalLog2Median => 11, externalSourceId => [12, 'copy', ''] }, 1);
    $loader->SimpleLoad($inDirectory, 'Strain.load', 'Strain', { source_id => 0, id => 1, aggregateData => [2, 'semi-boolean', '?'], name => [3, 'copy', ''], wildtype => [4, 'semi-boolean', '?'], referenceStrain => [5, 'semi-boolean', '?'], description => [6, 'copy', ''] }, 1);
    $loader->SimpleLoad($inDirectory, 'PersonAnnotatedSample.load', 'PersonAnnotatedSample', { from_link => 0, to_link => 1 }, 1);
    $loader->SimpleLoad($inDirectory, 'HasExpressionSample.load', 'HasExpressionSample', { from_link => 0, to_link => 1 }, 1);
    $loader->SimpleLoad($inDirectory, 'HasPresenceOf.load', 'HasPresenceOf', { from_link => 0, to_link => 1, units => 2, concentration => 3 }, 1);
    $loader->SimpleLoad($inDirectory, 'Measurement.load', 'Measurement', { source_id => 0, id => 1, Z_score => 2, median => 3, value => 4, N => 5, stddev => 6, p_value => 7, mean => 8 }, 1);
    $loader->SimpleLoad($inDirectory, 'MeasurementDescription.load', 'MeasurementDescription', { source_id => 0, id => 1, category => [2, 'copy', ''], unitOfMeasure => [3, 'copy', ''], name => [4, 'copy', ''], description => [5, 'copy', ''] }, 1);
    $loader->SimpleLoad($inDirectory, 'StrainParentOf.load', 'StrainParentOf', { from_link => 0, to_link => 1 }, 1);
    
    # Unspool the relation loaders.
    print "Loading database relations.\n";
    $loader->LoadRelations($keep);
    print "All done: " . $stats->Show();
     
     
     