package Bio::KBase::ExpressionServices::FunctionsForGEO;
use strict;
#use Bio::KBase::Exceptions;
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

#require Exporter;

our (@ISA,@EXPORT);
@ISA = qw(Exporter);
@EXPORT = qw(new get_GEO_GSE_data);

 
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

sub column_header_checker
{
    my $col_name = shift;
    my $reg_ex = shift; 
    my $column_exists_flag = shift; 
    my $counter = shift; 
    if ($col_name =~ m/$reg_ex/i)
    { 
        if (defined($column_exists_flag))
        { 
            return "duplicate"; 
        } 
        else 
        { 
            return $counter;
        } 
    } 
    else 
    { 
        return $column_exists_flag; 
    } 
}

sub parse_gse_series_portion
{
    my $lines_array_ref = shift;
    my $gse_object = shift;
    my @lines = @{$lines_array_ref};

    my $gseID = undef;
    my $gseTitle = undef;
    my $gseSummary = undef;
    my $gseDesign = undef;
    my $gseSubmissionDate = undef;
    my $gsePubMedID = undef;
    my @gseErrors = ();
    my @gseWarnings = ();
    my %listed_gsm_hash;

    foreach my $line (@lines)
    {
	if ($line =~ m/\!Series_sample_id = /)
	{
	    my @temp_arr = split(/\s*=\s*/,$line);
	    $listed_gsm_hash{trim($temp_arr[1])} = 0;
	}
	if ($line =~ m/^\^SERIES = /)
	{
	    my @temp_arr = split(/\s*=\s*/,$line);
	    $gseID = trim($temp_arr[1]);
	}
        if ($line =~ m/^\!Series_title =/)
        {
            my @temp_arr = split(/\s*=\s*/,$line); 
            $gseTitle = trim($temp_arr[1]);
        }
	if ($line =~ m/^\!Series_summary = /) 
	{ 
	    my @temp_arr = split(/\s*=\s*/,$line);
	    if (defined($gseSummary))
	    {
		$gseSummary .= " :: " . trim($temp_arr[1]);
	    }
	    else
	    {
		$gseSummary = trim($temp_arr[1]);
	    }
	}
        if ($line =~ m/^\!Series_overall_design = /) 
        { 
            my @temp_arr = split(/\s*=\s*/,$line); 
            $gseDesign = trim($temp_arr[1]);
        } 
        if ($line =~ m/^\!Series_submission_date = /) 
        { 
            my @temp_arr = split(/\s*=\s*/,$line); 
            $gseSubmissionDate = trim($temp_arr[1]);
        } 
	if ($line =~ m/^\!Series_pubmed_id = /)
	{
	    my @temp_arr = split(/\s*=\s*/,$line);
	    $gsePubMedID = trim($temp_arr[1]);
	}
    }
    if (!(defined($gseID)))
    {
	push(@gseErrors,"No GEO Series ID found");
    }
    $gse_object={"gseID" => $gseID,
		  "gseTitle" => $gseTitle,
		  "gseSummary" => $gseSummary,
		  "gseDesign" => $gseDesign,
		  "gseSubmissionDate" => $gseSubmissionDate,
		  "gsePubMedID" => $gsePubMedID,
		  "gseErrors" => \@gseErrors,
		  "gseWarnings" => \@gseWarnings};
    return ($gse_object,\%listed_gsm_hash);
}


sub parse_gse_platform_portion
{ 
    my $platform_hash_ref = shift;
    my %platform_hash = %{$platform_hash_ref};
    my $metaDataOnly = shift;
    my $lines_array_ref = shift; 
    my @lines = @{$lines_array_ref};
    my $gsm_info_hash_ref = shift;
    my %gsm_platform_info_hash = %{$gsm_info_hash_ref};  #Hash that has GSMID as key (or "ALL_GSMS" as single key) -> {"organism"=>value,
                                #                                                             "taxID"=>value,
                                #                                                             "platform"=>GPLID}
                                #  NOTE THIS GETS VERY COMPLICATED IF NOT METADATA ONLY.  Remember multiple GPLs can exist per GSE
    my $self = shift; 
    my %gsm_id_feature_hash;    #  Need to return a map for probe mapping for the GSMs to use if this is not metadata only
                                #  key GSMID or "ALL_GSMS" -> {platform_id->feature_id it maps to 

    my @temp_arr = split(/\s*=\s*/,$lines[0]);
    my $gplID = trim($temp_arr[1]);
    my $gplTitle = undef;
    my $gplTechnology = undef;
    my $gplTaxID = undef;
    my $gplManufacturer = undef;
    my $gplOrganism = undef;

    $platform_hash{$gplID}->{"warnings"}=[];
    $platform_hash{$gplID}->{"errors"}=[];
    my $platform_table_begin = undef;
    my $platform_line_counter = 0;

    foreach my $line (@lines)
    {
	if ($line =~ m/^\!Platform_title =/) 
	{ 
	    my @temp_arr = split(/\s*=\s*/,$line); 
	    $gplTitle = trim($temp_arr[1]); 
	} 
        if ($line =~ m/^\!Platform_technology =/) 
        { 
            my @temp_arr = split(/\s*=\s*/,$line); 
            $gplTechnology = trim($temp_arr[1]);
        } 
        if ($line =~ m/^\!Platform_taxid =/)
        {
            my @temp_arr = split(/\s*=\s*/,$line);
            $gplTaxID = trim($temp_arr[1]);
        }
        if ($line =~ m/^\!Platform_manufacturer =/)
        {
            my @temp_arr = split(/\s*=\s*/,$line);
            $gplManufacturer = trim($temp_arr[1]);
        }
        if ($line =~ m/^\!Platform_organism =/)
        { 
            my @temp_arr = split(/\s*=\s*/,$line);
            $gplOrganism = trim($temp_arr[1]);
        } 
	if ($line =~ m/^\!platform_table_begin/)
	{
	    $platform_table_begin = $platform_line_counter + 1;
	    last;
	}
	$platform_line_counter++;
    }
    unless(defined($gplTitle))
    {
	push(@{$platform_hash{$gplID}->{"warnings"}},"The platform has no title");
    }
    $platform_hash{$gplID}->{"gplTitle"}=$gplTitle;

    unless(defined($gplTaxID))
    {
	push(@{$platform_hash{$gplID}->{"warnings"}},"The platform has no taxID");
    } 
    $platform_hash{$gplID}->{"gplTaxID"}=$gplTaxID;

    unless(defined($gplOrganism)) 
    { 
        push(@{$platform_hash{$gplID}->{"warnings"}},"The platform has no listed organism");
    } 
    $platform_hash{$gplID}->{"gplOrganism"}=$gplOrganism;
    
    if(defined($gplTechnology))
    {
	if (defined($gplManufacturer))
	{
	    $gplTechnology .= " :: ". $gplManufacturer; 
	}
    }
    else
    {
	if (defined($gplManufacturer))
	{
	    $gplTechnology = "Unknown :: ". $gplManufacturer;
	} 
    }
    $platform_hash{$gplID}->{"gplTechnology"}=$gplTechnology;
print "METADATA ONLY : $metaDataOnly :\n";
    if ($metaDataOnly == 0)
    {
#	push(@{$platform_hash{$gplID}->{"errors"}},"THIS CURRENTLY ONLY SUPPORTS METADATA ONLY!");
	my $dbh = DBI->connect('DBI:mysql:'.$self->{dbName}.':'.$self->{dbhost}, $self->{dbUser}, '',
			       { RaiseError => 1, ShowErrorStatement => 1 }
	    ); 
	my %genome_ids_hash;
#print Dumper(%gsm_platform_info_hash);
	foreach my $temp_gsm_id (keys(%gsm_platform_info_hash))
	{
	    my $ncbi_db = Bio::DB::Taxonomy->new(-source=>"entrez");
	    #IF GSM uses current GPL
	    if ($gsm_platform_info_hash{$temp_gsm_id}->{"platform"} eq $gplID)
	    {
		#Check for the GSMs Tax ID vs NCBI and get Scientific name.  Then look up genome by that scientific name.
		my $ncbi_taxon = $ncbi_db->get_taxon(-taxonid=>$gsm_platform_info_hash{$temp_gsm_id}->{"taxID"});
#print Dumper($ncbi_taxon);
		my @ncbi_scientific_names = @{$ncbi_taxon->{'_names_hash'}->{'scientific'}};
#print "SCIENTIFIC NAME ". join(',',@ncbi_scientific_names). " \n";
		my $get_genome_ids_q = "select id from kbase_sapling_v1.Genome where scientific_name in (".
		    join(",", ("?") x @ncbi_scientific_names) . ") ";
		my $get_genome_ids_qh = $dbh->prepare($get_genome_ids_q) or die "Unable to prepare get_genome_ids_q : $get_genome_ids_q ".
		    $dbh->errstr();
		$get_genome_ids_qh->execute(@ncbi_scientific_names) or die "Unable to execute get_genome_ids_q : $get_genome_ids_q " .
		    $get_genome_ids_qh->errstr();
		while (my ($genome_id) = $get_genome_ids_qh->fetchrow_array())
		{
		    $genome_ids_hash{$genome_id} = 1;
		}
		if (scalar(keys(%genome_ids_hash)) > 1)
		{
#MULTIPLE GENOME IDS - WHICH ONE TO TAKE?
		    push(@{$platform_hash{$gplID}->{"errors"}},"The Tax ID ". $gsm_platform_info_hash{$temp_gsm_id}->{"taxID"} . 
			 " maps to multiple genome ids (" . join (", ",keys(%genome_ids_hash)) . ").");      
		}
print "GENOME IDS : (". join (", ",keys(%genome_ids_hash)) . ").\n";
		
		#determine if a sequence column exists 
		my @platform_map_lines = @lines[$platform_table_begin..(scalar(@lines)-2)];
#print "PLATFORM MAP LINES : ". Dumper(@platform_map_lines); 
		my ($probe_sequence_hash_ref, $probe_sequence_warning) = make_platform_sequence_hash(\@platform_map_lines);
#print "WARNINGS: $probe_sequence_warning \n";
		my %probe_sequence_hash = %{$probe_sequence_hash_ref};
		my @blat_files_to_clean_up_after;
		if (!defined($probe_sequence_warning))
		{
		    #It has a sequence column it does prepare a blat_db file and build query file
		    my $min_probe_length = 500;
		    my $blat_platform_query_file = "/kb/dev_container/modules/expression/blat_files/".$gplID."_blat_query_file";
		    push(@blat_files_to_clean_up_after, $blat_platform_query_file);
		    open (BLAT_QUERY_FILE, ">".$blat_platform_query_file) or die "Unable to make $blat_platform_query_file \n";
		    foreach my $probe_id (keys(%probe_sequence_hash))
		    {
			my $probe_sequence = $probe_sequence_hash{$probe_id};
			print BLAT_QUERY_FILE ">".$probe_id."\n".$probe_sequence."\n";
			if (length($probe_sequence) < $min_probe_length)
			{
			    $min_probe_length = length($probe_sequence);
			}
		    }
		    $min_probe_length = $min_probe_length - 1; #allows for 1 base mismatch in blat
		    close (BLAT_QUERY_FILE);
		    #FOREACH MATCHING GENOME
		    #Create DB file of CDS
		    #Run blat
		    #create mapping platform_id -> feature_id
		    #remove files
		    foreach my $genome_id (keys(%genome_ids_hash))
		    {
			#create Blat DB File
			my $file_genome_id = $genome_id;
			$file_genome_id =~ s/\|/__/; 
			my $blat_genome_db_file = "/kb/dev_container/modules/expression/blat_files/".$file_genome_id."_blat_db_file";
			push(@blat_files_to_clean_up_after, $blat_genome_db_file);
			open (BLAT_DB_FILE, ">".$blat_genome_db_file) or die "Unable to make $blat_genome_db_file \n";
			my $kb = Bio::KBase->new();
			my $cdmi_client = $kb->central_store;
			my $genome_fids_hash_ref = $cdmi_client->genomes_to_fids([$genome_id],['CDS']);
			my $fid_sequence_hash = $cdmi_client->fids_to_dna_sequences($genome_fids_hash_ref->{$genome_id}); 
			foreach my $fid_key (keys(%{$fid_sequence_hash})) 
			{ 
			    print BLAT_DB_FILE ">".$fid_key."\n".$fid_sequence_hash->{$fid_key}."\n"; 
			} 
			close(BLAT_DB_FILE); 
			# Run Blat
			my $blat_results_file = "/kb/dev_container/modules/expression/blat_files/".$gplID."_".$file_genome_id."_blat_results.psl";
			my $cmd = "/usr/local/bin/blat -t=dna -q=dna -tileSize=6 -repMatch=1000000 -minIdentity=95 -fine -minMatch=0 -out=psl -minScore=$min_probe_length ".
                                  "$blat_genome_db_file $blat_platform_query_file $blat_results_file"; 
print "Running blat: $cmd\n"; 
			system($cmd) == 0 || die "Cannot run blat"; 
			die "blat failed" unless -e $blat_results_file; 
			push(@blat_files_to_clean_up_after, $blat_results_file);
		    }
#print "MAPPING: ".Dumper(\%probe_sequence_hash);	       
		}
		else
		{
		    #no sequence column exists, see if a locus tag/aliases column exists
		    #create mapping platform_id -> feature_id
		    

		}
	    }

	}

	#ADD ALL SORTS OF MAPPING (by sequence or gene aliases) OF PROBES TO FEATURES LOGIC IN HERE
	#PLATFORM TABLE is located in @lines[$platform_table_start..(scalar(@lines))]
	#Will populate the     $platform_hash{$gplID}->{"id_to_feature_mappings"}={id from Platform section mapped to the feature_id};
	#Will populate the     $platform_hash{$gplID}->{"mapping_approach"}=text "sequence" or "alias";
    }
    $platform_hash{$gplID}->{"processed"}=1; 
    return (\%platform_hash,\%gsm_id_feature_hash);
}



sub make_platform_sequence_hash
{
    my $lines_array_ref = shift; 
    my @lines = @{$lines_array_ref}; 

    my @header_columns = split(/\t/,shift(@lines));
    my $id_col_exists = undef;
    my $header_counter = 0;
    my $warning = undef;
    my %sequence_hash_counter;  #Hash with column position (integer starting at zero) and number of values that are DNA
    my $percent_threshold = .75;
    my %probe_hash; #key = platform id, value = sequence.  This hash will be used to create the Blat query file.

    foreach my $header_column (@header_columns)
    {
	$id_col_exists = column_header_checker(trim($header_column),'^id$',$id_col_exists,$header_counter);
	$sequence_hash_counter{$header_counter} = 0;
	$header_counter++;
    }
    if ($id_col_exists eq 'duplicate')
    {
	$warning = "There is more than one 'ID' column";
    }
    elsif (!defined($id_col_exists))
    {
	$warning = "An 'ID' column was not found in this platform";
    }
    else
    {
	#determine which column has the most sequences.
	foreach my $line (@lines)
	{
	    my @line_elements = split(/\t/,$line);
	    for (my $i = 0; $i < scalar(@line_elements); $i++)
	    {
		if ((trim($line_elements[$i]) =~ m/^[ACGTacgt]*$/) && (length(trim($line_elements[$i])) >= 20)) 
		{ 
		    $sequence_hash_counter{$i} =  $sequence_hash_counter{$i} + 1;
		}
	    }
	}
	my $max_index = undef;
	my $max_value = 0;
	foreach my $col_index (keys(%sequence_hash_counter))
	{
	    if ($sequence_hash_counter{$col_index} > $max_value)
	    {
		$max_value = $sequence_hash_counter{$col_index};
		$max_index = $col_index;
	    }
	}
#print "MAX VALUE : ". $max_value . "\n";
#print "MAX INDEX : ". $max_index . "\n";
#print "ID COL : ". $id_col_exists . "\n";
#print "THRESHOLD REQ : ".($percent_threshold * scalar(@lines))."\n";
	if ($max_value < ($percent_threshold * scalar(@lines)))
	{
	    $warning = "A column did not exist in the platform that passed thresholds for being a sequence column";
	}
	else
	{
	    #create map of probe_hash
	    foreach my $line (@lines)
	    { 
		my @line_elements = split(/\t/,$line); 
                if ((trim($line_elements[$max_index]) =~ m/^[ACGTacgt]*$/) && (length(trim($line_elements[$max_index])) >= 20))
                { 
                    $probe_hash{trim($line_elements[$id_col_exists])} = trim($line_elements[$max_index]);
                }
	    }
	}
    }
#print "NUMBER OF ELEMENTS IN PROBE HASH : ". scalar(keys(%probe_hash))."\n";
#print "PROBE MAPPING HASH : ". Dumper(%probe_hash)."\n";
    return (\%probe_hash,$warning);
}

sub parse_gse_sample_info_for_platform
{
    my $lines_array_ref = shift;
    my @lines = @{$lines_array_ref}; 

    my $gsm_id = undef;
    my %gsm_platform_info_hash; #Hash that has GSMID as key (or "ALL_GSMS" as single key) -> {"organism"=>value,          
                                #                                                             "taxID"=>value,      
                                #                                                             "platform"=>GPLID}       
    foreach my $line (@lines) 
    {
        if ($line =~ m/^\^SAMPLE = /)
        {
            my @temp_arr = split(/\s*=\s*/,$line); 
            $gsm_id = trim($temp_arr[1]);
        } 
        if ($line =~ m/^\!Sample_taxid_ch1 = /) 
        { 
            my @temp_arr = split(/\s*=\s*/,$line); 
            $gsm_platform_info_hash{$gsm_id}->{"taxID"} = trim($temp_arr[1]); 
        } 
        if ($line =~ m/^\!Sample_organism_ch1 = /)
        { 
            my @temp_arr = split(/\s*=\s*/,$line);
            $gsm_platform_info_hash{$gsm_id}->{"organism"} = trim($temp_arr[1]); 
        }
        if ($line =~ m/^\!Sample_platform_id = /) 
        { 
            my @temp_arr = split(/\s*=\s*/,$line); 
            $gsm_platform_info_hash{$gsm_id}->{"platform"} = trim($temp_arr[1]); 
        } 
    }
    return \%gsm_platform_info_hash;
}


sub parse_gse_sample_portion
{
    my $metaDataOnly = shift;
    my $platform_hash_ref = shift;
    my $lines_array_ref = shift;
    my @lines = @{$lines_array_ref};

    my %gsm_hash;
    my $gsm_id = undef;
    my $gsm_title = undef;
    my $gsm_description = undef;
    my %gsm_molecule_hash;
    my $gsm_molecule = undef;
    my $gsm_submission_date = undef;
    my $gsm_tax_id = undef;
    my $gsm_sample_organism = undef;
    my @gsm_sample_characteristics = ();
    my @gsm_protocols_array = ();
    my $gsm_value_type = undef;
    my $gsm_original_log2_median = undef;
    my $gsm_contact_email = undef;
    my $gsm_contact_first_name = undef;
    my $gsm_contact_last_name = undef;
    my $gsm_contact_institution = undef;

    my $gpl_id = undef;

    my $sample_table_start = undef;
    my $sample_line_counter = 0;

    #print "\nPlatform hash : ". Dumper($platform_hash_ref)."\n";

    foreach my $line (@lines)
    { 
        if ($line =~ m/^\^SAMPLE = /)
        { 
            my @temp_arr = split(/\s*=\s*/,$line); 
            $gsm_id = trim($temp_arr[1]);
        } 
        if ($line =~ m/^\!Sample_title = /)
        { 
            my @temp_arr = split(/\s*=\s*/,$line);
            $gsm_title = trim($temp_arr[1]); 
        }
        if ($line =~ m/^\!Sample_description = /)
        { 
            my @temp_arr = split(/\s*=\s*/,$line);
            $gsm_description = trim($temp_arr[1]); 
        }
        if ($line =~ m/^\!Sample_molecule_ch. = /)
        {
            my @temp_arr = split(/\s*=\s*/,$line);
            $gsm_molecule_hash{trim($temp_arr[0])} = trim($temp_arr[1]);
        } 
        if ($line =~ m/^\!Sample_submission_date = /)
        { 
            my @temp_arr = split(/\s*=\s*/,$line);
            $gsm_submission_date = trim($temp_arr[1]); 
        }
        if ($line =~ m/^\!Sample_taxid_ch1 = /)
        { 
            my @temp_arr = split(/\s*=\s*/,$line);
            $gsm_tax_id = trim($temp_arr[1]); 
        }
        if ($line =~ m/^\!Sample_characteristics_ch1 = /)
        { 
            my @temp_arr = split(/\s*=\s*/,$line);
            push(@gsm_sample_characteristics,trim($temp_arr[1])); 
        }
        if (($line =~ m/^\!Sample_treatment_protocol_ch1 = /) ||
	    ($line =~ m/^\!Sample_growth_protocol_ch1 = /))
	{
	    push(@gsm_protocols_array,$line);
	}
	if ($line =~ m/^\!Sample_organism_ch1 = /)
	{
	    my @temp_arr = split(/\s*=\s*/,$line);
            $gsm_sample_organism = trim($temp_arr[1]);
	}
        if ($line =~ m/^\!Sample_contact_email = /) 
        { 
            my @temp_arr = split(/\s*=\s*/,$line);
            $gsm_contact_email = trim($temp_arr[1]);
        } 
        if ($line =~ m/^\!Sample_contact_name = /) 
        { 
            my @temp_arr = split(/\s*=\s*/,$line);
	    my @temp_arr2 = split(/\,/,trim($temp_arr[1]));
	    $gsm_contact_first_name = trim($temp_arr2[0]);
	    if (scalar(@temp_arr2) == 2)
	    {
		$gsm_contact_last_name = trim($temp_arr2[1]);
	    }
            if (scalar(@temp_arr2) == 3)
            {
                $gsm_contact_last_name = trim($temp_arr2[2]); 
            }
        } 
        if ($line =~ m/^\!Sample_contact_institute = /)
        {
            my @temp_arr = split(/\s*=\s*/,$line);
            $gsm_contact_institution = trim($temp_arr[1]);
        } 
        if ($line =~ m/^\#VALUE = /) 
        {
            my @temp_arr = split(/\s*=\s*/,$line);
            $gsm_value_type = trim($temp_arr[1]);
        } 
	if ($line =~ m/^\!Sample_platform_id = /)
	{ 
	    my @temp_arr = split(/\s*=\s*/,$line);
	    $gpl_id = trim($temp_arr[1]);
	}
#IF DATA try to see if pvalue or Zscore present
        if ($line =~ m/^\!sample_table_begin/)
        { 
            $sample_table_start = $sample_line_counter;
            last; 
        } 
	$sample_line_counter++;
    }

    unless(defined($gsm_id))
    {
        $gsm_hash{"UNKNOWN GSM ID"}->{"errors"} = ["COULD NOT FIND THE GSM ID"];
	return \%gsm_hash;
    }
    else
    {
	my @emp_array;
	$gsm_hash{$gsm_id}->{"warnings"}=[]; 
	$gsm_hash{$gsm_id}->{"errors"}=[]; 
	$gsm_hash{$gsm_id}->{"gsmID"}=$gsm_id;
    }

    #check for metadata only warnings errors
    unless(defined($gsm_title)) 
    { 
        push(@{$gsm_hash{$gsm_id}->{"warnings"}},"The sample has no title");
    } 
    $gsm_hash{$gsm_id}->{"gsmTitle"}=$gsm_title;
    unless(defined($gsm_description))
    {
	$gsm_description = $gsm_title;
    }
    $gsm_hash{$gsm_id}->{"gsmDescription"}=$gsm_description;

    #NEED TO ADD SOME LOGIC FOR MOLECULE TYPE (some will not be allowed - logratio )
    #Sample Molecules
    #Possible values for each channel: total RNA, polyA RNA, cytoplasmic RNA, nuclear RNA, genomic DNA, protein, or other
    #Only can process 
    #LOG LEVEL: Total RNA / Genomic DNA
    #PolyA RNA / Genomic DNA
    #Cytoplasmic RNA / Genomic DNA
    #Total RNA
    #Genomic DNA
    #PolyA RNA
    #Cytoplasmic RNA
    my %accepted_molecule_hash = ('total rna' => 1, 
				  'polyA rna' =>1,
				  'cytoplasmic rna' => 1,
				  'nuclear rna' => 1, 
				  'genomic dna' => 1, 
				  'protein' => 1);

    if (scalar(keys(%gsm_molecule_hash)) > 2)
    {
        push(@{$gsm_hash{$gsm_id}->{"errors"}},"The sample has more than 2 molecule types.");
    }
    elsif ((scalar(keys(%gsm_molecule_hash)) == 1) || (scalar(keys(%gsm_molecule_hash)) == 2)) 
    { 
        if (defined($gsm_molecule_hash{"!Sample_molecule_ch1"}))
        { 
            if (lc($gsm_molecule_hash{"!Sample_molecule_ch1"}) eq 'genomic dna')
            { 
                push(@{$gsm_hash{$gsm_id}->{"errors"}}, 
                     "This is sample has Genomic DNA in channel 1.");
            } 
            elsif(defined($accepted_molecule_hash{lc($gsm_molecule_hash{"!Sample_molecule_ch1"})}))
            { 
                $gsm_molecule = $gsm_molecule_hash{"!Sample_molecule_ch1"};
            } 
            else
            { 
                push(@{$gsm_hash{$gsm_id}->{"errors"}}, 
                     "The molecule type in channel 1 is not an accepted type.");
            }
        } 
	else 
	{ 
	    push(@{$gsm_hash{$gsm_id}->{"errors"}}, 
		 "The molecule type has 1 or 2 entries, but none map to channel 1."); 
	} 
    } 
    #print "\nMOLECULE HASH : \n".Dumper(\%gsm_molecule_hash)."\n";
    if (scalar(keys(%gsm_molecule_hash)) == 2)
    {
        if (defined($gsm_molecule_hash{"!Sample_molecule_ch2"}))
        {
	    if ($gsm_molecule_hash{"!Sample_molecule_ch2"} ne "Genomic DNA")
	    {
		push(@{$gsm_hash{$gsm_id}->{"errors"}},
		     "This is a 2 channel array with the 2nd array not being Genomic DNA.  This suggests log ratio and not log level values.");
	    }
	    else
	    {
		$gsm_molecule .= " / " . $gsm_molecule_hash{"!Sample_molecule_ch2"};
	    }
        }
        else 
        { 
            push(@{$gsm_hash{$gsm_id}->{"errors"}}, 
                 "The molecule type has 2 entries, but none map to channel 2.");
        } 
    }
    $gsm_hash{$gsm_id}->{"gsmMolecule"}=$gsm_molecule; 
    $gsm_hash{$gsm_id}->{"gsmSubmissionDate"}=$gsm_submission_date; 
    unless(defined($gsm_tax_id))
    { 
        push(@{$gsm_hash{$gsm_id}->{"errors"}},"The sample has no tax id.  Will not be able to get feature ids for this.");
    } 
    $gsm_hash{$gsm_id}->{"gsmTaxID"}=$gsm_tax_id; 
    $gsm_hash{$gsm_id}->{"gsmSampleOrganism"}=$gsm_sample_organism;
    $gsm_hash{$gsm_id}->{"gsmSampleCharacteristics"}=\@gsm_sample_characteristics;
    my $gsm_protocol = join(' :: ',sort(@gsm_protocols_array));
    $gsm_hash{$gsm_id}->{"gsmProtocol"}=$gsm_protocol;

    #Get Value type
    if ($metaDataOnly eq '0')
    {
	$gsm_hash{$gsm_id}->{"gsmValueType"}=$gsm_value_type;
    }

    #GET Platform Info (propogate platfrom warnings and errors)
    if(!(defined($gpl_id)))
    {
        push(@{$gsm_hash{$gsm_id}->{"warnings"}},"The sample does not have a platform");
    }
    elsif(!defined($platform_hash_ref->{$gpl_id}))
    {
        push(@{$gsm_hash{$gsm_id}->{"warnings"}},"The platform $gpl_id was not found in the platform hash");
    }
    else
    {
	my @we_types = ("warnings","errors");
	foreach my $we_type (@we_types)
	{
	    foreach my $we_msg (@{$platform_hash_ref->{$gpl_id}->{$we_type}})
	    {
		push(@{$gsm_hash{$gsm_id}->{$we_type}},$we_msg);
	    }
	}
	my %gpl_hash = ("gplID" => $gpl_id,
		     "gplTitle" => $platform_hash_ref->{$gpl_id}->{"gplTitle"},
		     "gplTaxID" => $platform_hash_ref->{$gpl_id}->{"gplTaxID"},
		     "gplTechnology" => $platform_hash_ref->{$gpl_id}->{"gplTechnology"},
		     "gplOrganism" => $platform_hash_ref->{$gpl_id}->{"gplOrganism"});
	$gsm_hash{$gsm_id}->{"gsmPlatform"}=\%gpl_hash;
    }


    #Get Contact person info
    unless(defined($gsm_contact_email))
    {
	push(@{$gsm_hash{$gsm_id}->{"warnings"}},"The sample has no contact email.");
    }
    my %contact_hash = ($gsm_contact_email => {"contactFirstName" => $gsm_contact_first_name,
					       "contactLastName" => $gsm_contact_last_name,
					       "contactInstitution" => $gsm_contact_institution});
    $gsm_hash{$gsm_id}->{"contactPeople"}=\%contact_hash;


    #DATA (only if metadata only = 0)(original median).
    #FEATURE MAPPING APPROACH (only if metadata only = 0).
    #only populate value if not metadata only

    #If not metadata only check for warnings/errors (intensity type, value ranges, reasonable number of mapped genes)
    #map to values to features average across all probes that hit that feature.
    
    return \%gsm_hash;
}


sub get_GEO_GSE_data
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

    if (($metaDataOnly eq "1") || (uc($metaDataOnly) eq "Y") || (uc($metaDataOnly) eq "TRUE")) 
    { 
        $metaDataOnly = 1;
    } 
    else
    {
        $metaDataOnly = 0;
    }
 
    my $gse_url = 'ftp://ftp.ncbi.nih.gov/pub/geo/DATA/SOFT/by_series/' . $gse_input_id . "/"; 
    my $gzip_file_ls_line = get($gse_url); 
    my @gse_file_records = split (/\n/,$gzip_file_ls_line); 
    foreach my $gse_record (@gse_file_records) 
    { 
	if (scalar(@gse_file_records) > 1)
	{
	    $gseObject->{"gseErrors"}->[0] = "Error there appears to multiple GSE SOFT files associated with $gse_input_id :  ".
		"These are the records listed ". join(",",@gse_file_records).".";
	    return($gseObject);
	}

	#print "GSE RECORD : $gse_record \n"; 
	my @line_segments = split (/GSE/,$gse_record); 
	my $gzip_file = "GSE".$line_segments[-1]; 
	#print "GZIP FILE : $gzip_file \n"; 
	chomp($gzip_file); 
	my $gzip_url = $gse_url.$gzip_file; 
	my $gzip_output = get($gzip_url); 
 
	my $gse_output = new IO::Uncompress::Gunzip \$gzip_output 
	    or die "IO::Uncompress::Gunzip failed: $GunzipError\n"; 
 
	my $line_count = 0;

	my @gse_lines = <$gse_output>;

	#series vars 
	my $gse_series_line_start = undef;
	my $gse_series_line_end = undef;
	my $gse_series_section_parsed = 0;
	my $listed_gsm_hash_ref;

	#platform vars
	my @platform_start_lines; #start lines for each platform in the platforms section
	my @platform_end_lines; #start lines for each platform in the platforms section
	my %platform_hash; #key is the platform name

	#vars for dealing with mapping probes to features
	my %gsm_id_feature_hash; #key GSM ID (or "ALL_GSMS") ->{id from platform => feature_id}  ONLY GETS populated if NOT metadata only
	my %gsm_platform_info_hash;  #Hash that has GSMID as key (or "ALL_GSMS" as single key) -> {"organism"=>value,                
                                #                                                             "taxID"=>value,     
                                #                                                             "platform"=>GPLID}     

        #sample vars  
        my @sample_start_lines; #start lines for each sample in the samples section  
        my @sample_end_lines; #start lines for each sample in the samples section 
	my %GSMs_hash; #key gsmID -> value Hash (essentially for GSM object)

	#IF METADATA ONLY = 0, means we need to deal with the Platform sections to create id->feature id hash.
        #The platform parsing section will need more information need to populate the %gsm_info_hash
	if ($metaDataOnly == 0)
	{
	    my @md_sample_start_lines;
	    my @md_sample_end_lines;
	    my $md_line_count = 0;
	    foreach my $gse_line (@gse_lines) 
	    { 
		if ($gse_line =~ m/^\^SAMPLE = /)
		{
		    push(@md_sample_start_lines,$md_line_count);
		} 
		if ($gse_line =~ m/^\!sample_table_end/)
		{ 
		    push(@md_sample_end_lines,$md_line_count);
		}		
		$md_line_count++;
	    }
#print "STARTS : ". Dumper(@md_sample_start_lines);
#print "ENDS : ". Dumper(@md_sample_end_lines);

	    #LOOP Through each sample and parse.                
	    if (scalar(@sample_start_lines) != scalar(@sample_end_lines)) 
	    { 
		push(@{$gseObject->{"gseErrors"}},"The samples do not have the same number of start positions (" .
		     scalar(@sample_start_lines) . 
		     ") as end positions (" . scalar(@sample_end_lines) . ")");
	    } 
	    else 
	    { 
		for (my $md_sample_counter = 0; $md_sample_counter < scalar(@md_sample_start_lines); $md_sample_counter++)
		{
		    my @md_sample_lines = @gse_lines[$md_sample_start_lines[$md_sample_counter]..$md_sample_end_lines[$md_sample_counter]]; 
		    my %temp_sample_hash = %{parse_gse_sample_info_for_platform(\@md_sample_lines)};
#print "TEMP SAMPLE HASH: " . Dumper(%temp_sample_hash); 
		    my ($temp_gsm_id) = keys(%temp_sample_hash);
		    $gsm_platform_info_hash{$temp_gsm_id} = $temp_sample_hash{$temp_gsm_id}; 
		} 
		my %unique_platforms_hash;
		my %unique_tax_ids_hash;
		my %unique_organisms_hash;
		foreach my $temp_gsm_id (keys(%gsm_platform_info_hash))
		{
		    $unique_platforms_hash{$gsm_platform_info_hash{$temp_gsm_id}->{"platform"}} = 1;
		    $unique_tax_ids_hash{$gsm_platform_info_hash{$temp_gsm_id}->{"taxID"}} = 1;
		    $unique_organisms_hash{$gsm_platform_info_hash{$temp_gsm_id}->{"organism"}} = 1;
		}
		if ((scalar(keys(%unique_platforms_hash)) == 1) &&
		    (scalar(keys(%unique_tax_ids_hash)) == 1) &&
		    (scalar(keys(%unique_organisms_hash)) == 1))
		{
		    #means there is only one Platform for all GSMs  (usually the case)  
		    #Need to make only 1 key, so only make 1 probe map that all GSMs can use.
		    undef %gsm_platform_info_hash;
		    my ($uniq_platform) = keys(%unique_platforms_hash);
		    my ($uniq_tax_id) = keys(%unique_tax_ids_hash);
		    my ($uniq_organism) = keys(%unique_organisms_hash);
		    $gsm_platform_info_hash{"ALL_GSMS"}={"platform" => $uniq_platform,
							 "taxID" => $uniq_tax_id,
							 "organism" => $uniq_organism};
		}
	    }
	}

	foreach my $gse_line (@gse_lines)
	{ 
	    #SERIES SECTION OF GSE
	    if ($gse_line =~ m/^\^SERIES = /)
	    {
		$gse_series_line_start = $line_count;
	    }
	    if ($gse_line =~ m/^\^PLATFORM = /)
	    {
		$gse_series_line_end = $line_count -1;
	    }
	    if (defined($gse_series_line_start) && defined($gse_series_line_end) && $gse_series_section_parsed == 0)
	    {
		#need to process SERIES PORTION OF GSE
		$gse_series_section_parsed = 1;
		my @gse_portion_lines = @gse_lines[$gse_series_line_start..$gse_series_line_end];
		($gseObject,$listed_gsm_hash_ref) = parse_gse_series_portion(\@gse_portion_lines,$gseObject);
	    }

	    #PLATFORM(S) SECTION OF GSE
            if ($gse_line =~ m/^\^PLATFORM = /)
            { 
                push(@platform_start_lines,$line_count);
		my @temp_arr = split(/\s*=\s*/,$gse_line);
		my $gplID = trim($temp_arr[1]);
		$platform_hash{$gplID}={"processed" => 0}; 
            } 
	    if ($gse_line =~ m/^\!platform_table_end/)
	    {
		push(@platform_end_lines,$line_count);
	    }
            if (($gse_line =~ m/^\^SAMPLE = /)  && ($platform_end_lines[-1] == ($line_count - 1)))
	    {
print "PLATFORM END LINES -1 :". $platform_end_lines[-1] . ":\nLINE COUNT -1 :".($line_count - 1)."\n";
		#need to process platform section of GSE
		if (scalar(@platform_start_lines) != scalar(@platform_end_lines))
		{
		    push(@{$gseObject->{"gseErrors"}},"The platforms do not have the same number of start positions (" . 
			 scalar(@platform_start_lines) . 
			 ") as end positions (" . scalar(@platform_end_lines) . ")");
		}
		else
		{
		    for (my $platform_counter = 0; $platform_counter < scalar(@platform_start_lines); $platform_counter++) 
		    {
			my @gse_platform_lines = @gse_lines[$platform_start_lines[$platform_counter]..$platform_end_lines[$platform_counter]];
			my ($platform_hash_ref,$gsm_id_feature_hash_ref) = parse_gse_platform_portion(\%platform_hash,$metaDataOnly,
												      \@gse_platform_lines,\%gsm_platform_info_hash, $self);
			%platform_hash = %{$platform_hash_ref};
			%gsm_id_feature_hash = %{$gsm_id_feature_hash_ref};
		    }
		}
		foreach my $temp_gpl_id (keys(%platform_hash))
		{
		    if ($platform_hash{$temp_gpl_id} == 0)
		    {
			push(@{$gseObject->{"gseErrors"}},"GEO Platform $temp_gpl_id was not able to processed");
		    }
		}
	    }
            if ($gse_line =~ m/^\^SAMPLE = /)
	    {
		push(@sample_start_lines,$line_count);
	    }
	    if ($gse_line =~ m/^\!sample_table_end/)
	    {
		push(@sample_end_lines,$line_count);
	    }
	    $line_count++; 
	}

	#LOOP Through each sample and parse.
	if (scalar(@sample_start_lines) != scalar(@sample_end_lines)) 
	{ 
	    push(@{$gseObject->{"gseErrors"}},"The samples do not have the same number of start positions (" . 
		 scalar(@sample_start_lines) . 
		 ") as end positions (" . scalar(@sample_end_lines) . ")"); 
	} 
	else 
	{
	    for (my $sample_counter = 0; $sample_counter < scalar(@sample_start_lines); $sample_counter++) 
	    { 
		my @gse_sample_lines = @gse_lines[$sample_start_lines[$sample_counter]..$sample_end_lines[$sample_counter]]; 
		my %sample_hash = %{parse_gse_sample_portion($metaDataOnly,\%platform_hash,\@gse_sample_lines)}; 
		my ($gsm_id) = keys(%sample_hash);
		$gseObject->{"gseSamples"}->{$gsm_id} = $sample_hash{$gsm_id};
		delete $listed_gsm_hash_ref->{$gsm_id};
	    } 
	    foreach my $not_parsed_gsm (keys(%{$listed_gsm_hash_ref}))
	    {
		push(@{$gseObject->{"gseErrors"}},"The sample $not_parsed_gsm was in the series header but the sample was not found in the body"); 
	    }
	}
	#print "FINAL LINE COUNT $line_count \n"; 
	#print "GSM LISTED HASH : \n".Dumper($listed_gsm_hash_ref);
    } 
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




1;
