#!/usr/bin/perl -w
# v1.6: input file has a head, start with chr,start,end
# add annotation to the identified methylated regions

#v1.7 use TAIR10

#v1.8 modified from v1.7
# add a column to annotate promoter (1kb upstream of TSS)

#v1.9 modified from v1.8; Dec 17, 2013
# add a column to annotated down_1kb (1kb from 3UTR)

#v1.9.1 modifed from v1.9; Dec 17, 2013
# change the code in man for sub

=head2
version 1.5(from v3)

add strand information
perl add_annotation.pl at1g54840.bed ~/data/ath/tair9/TAIR9_GFF3_genes_transposons.gff ~/data/ath/tair9/TAIR9_functional_descriptions 
~/data/ath/tair9/TAIR9_Transposable_Elements.txt ~/data/ath/tair9/TAIR9_intergenic_20090619 >at1g54840_bed_with_annot.txt

use bed input, no trimmean.
=cut

use strict;
use Bio::SeqIO;

my $debug = 0;
my $usage = "$0 \n <vcf_file_withHead> <output>\n\n";
die $usage unless(@ARGV == 2);
#my $bed= $ARGV[0];
my $bed = shift or die;
my $output = shift or die;

die if (-e $output);
open(OUT, ">>$output") or die;

open(MT, $bed) or die "Can't open $bed:$!";

#my $func = "/Users/tang58/DataBase/TAIR_Col0_genome/TAIR9_functional_descriptions";
my $func = "/Users/tang58/DataBase/TAIR10/TAIR10_functional_descriptions.txt";
open(FF, $func) or die "Can't open $func: $!";

#my $gene_TE = "/Users/tang58/DataBase/TAIR_Col0_genome/TAIR9_GFF3_genes_transposons.gff";
my $gene_TE = "/Users/tang58/DataBase/TAIR10/GFF/TAIR10_GFF3_genes_transposons.gff";
open(GFF, $gene_TE) or die "Can't open $gene_TE:$!";

#my $TE_frag = "/Users/tang58/DataBase/TAIR_Col0_genome/TAIR9_Transposable_Elements.txt";
my $TE_frag = "/Users/tang58/DataBase/TAIR10/TAIR10_Transposable_Elements.txt";
open(TF, $TE_frag) or die "Can't open $TE_frag:$!";

#my $inter_file = "/Users/tang58/DataBase/TAIR_Col0_genome/TAIR9_intergenic_20090619";
my $inter_file = "/Users/tang58/DataBase/TAIR10/TAIR10_intergenic_20101028";
open(INTER , $inter_file) or die "cannot open $inter_file:$!";
close(INTER);

my $promoter_file = "/Users/tang58/DataBase/TAIR10/GFF/TAIR10_GFF3_protein_coding_gene_loci_5chr_sorted_1kb_promoter.txt";
die "promoter_file file " unless (-e $promoter_file);

#open(PRO, $promoter_file)  or die "cannot open $promoter_file: $!";

#############
# v1.9
############
my $down_1kb_file = "/Users/tang58/DataBase/TAIR10/GFF/TAIR10_GFF3_protein_coding_gene_loci_5chr_sorted_1kb_downstream.txt";
die "down_1kb file " unless (-e $down_1kb_file);
#open(DOWN, $down_1kb_file) or die "cannot open $down_1kb_file: $!";
####################
my $bed_head = <MT>;
chomp $bed_head;

my %descs;# record the whole line

#read input file
my %mat_regions; # chr->start=\@
while(<MT>){
	next if(/^browser/);
	next if(/^track/);
	next unless(/\w+/);
	chomp;
	#my ($chr, $start, $end) = split /\t/;
	my ($chr, $start, $id, $ref, $alt) = split /\t/;
	my $end = $start + length($alt);
	$chr = lc $chr;
	if($chr eq "chloroplast"){
		$chr = "chrc";
	}
	if($chr eq "mitochondria"){
		$chr = "chrm";
	}
	if ($chr !~ /^chr/) {
		$chr = "chr".$chr;
	}
	
	$mat_regions{$chr}->{$start} = [$start, $end];
	$descs {$chr}->{$start} = $_;
}

close(MT);

my %func;
#open(FF, $func) or die "Can't open $func: $!";
while(<FF>){
	next if(/^Model_name/);
	chomp;
	my @temp = split /\t/;
	if($temp[0] =~ /(AT\wG\d+)\.\d+/){
		my $gene = $1;
		if(!defined $func{$gene}){
			if(defined $temp[2] && $temp[2] =~ /\w+/){
			   $func{$gene} = $temp[2];
			}elsif(defined $temp[3] && $temp[3] =~ /\w+/){
				$func{$gene} = $temp[3];
			}elsif(defined $temp[4] && $temp[4] =~ /\w+/){
				$func{$gene} = $temp[4];
			}else{
				$func{$gene} = "NONE";
			}
		}
	}else{
		die "gene name ", $temp[0], " does not match pattern";
	}
}

close(FF);

######
my %strands;
#####


my %genes;
my %notes;
my %annot;
#open(GFF, $gene_TE) or die "Can't open $gene_TE:$!";
while(<GFF>){
	chomp;
	my @temp = split /\t/;
	my $chr = lc $temp[0];
	if($temp[2] eq "gene" || $temp[2] eq "pseudogene" || $temp[2] eq "transposable_element_gene"){
		foreach my $st(keys %{$mat_regions{$chr}}){
		#	my ($start, $end, $p,$mstart, $mend) = @{$mat_regions{$chr}->{$st}};
			my ($start, $end) = @{$mat_regions{$chr}->{$st}};
		
			if(!($end < $temp[3] || $start > $temp[4])){
				my @tag_vals = split /;/, $temp[8];
				my %vals;
				foreach my $tag_val(@tag_vals){
					my @t = split /=/, $tag_val;
					$vals{$t[0]} = $t[1];
				}
				my $id = "NONE";
				if(defined $vals{"ID"}){
					$id = $vals{"ID"};
				}
				my $note = "NONE";
				if(defined $vals{"Note"}){
					$note = $vals{"Note"};
				}
                
				my $fun = "NONE";
				
				############
				$strands{$chr}->{$start} = $temp[6];
				############
				
				if(defined $func{$id}){
					$fun = $func{$id};
				}
				if(defined $genes{$chr}->{$start}){
					$genes{$chr}->{$start} .= ";$id";
					$notes{$chr}->{$start} .= ";$note";
					$annot{$chr}->{$start} .= ";$fun";
				}else{
					$genes{$chr}->{$start} = $id;
					$notes{$chr}->{$start} = $note;
					$annot{$chr}->{$start} = $fun;
				}
			}
		}
	}
}

close(GFF);

my %TE;
my %TE_family;
#open(TF, $TE_frag) or die "Can't open $TE_frag:$!";
while(<TF>){
	next if(/^Transposon_Name/);
	chomp;
	my @temp = split /\t/;
	my $chr = "chr1";
	if($temp[0] =~ /AT(\d)TE/){
		$chr = "chr" . $1;
	}else{
		die "Transposon ", $temp[0], " doesn't match pattern";
	}
	foreach my $st(keys %{$mat_regions{$chr}}){
		my ($start, $end) = @{$mat_regions{$chr}->{$st}};
		if(!($end < $temp[2] || $start > $temp[3])){
			if(defined $TE{$chr}->{$start}){
				$TE{$chr}->{$start} .= ";" . $temp[0];
				$TE_family{$chr}->{$start} .= ";" . $temp[4] . ":" . $temp[5];
			}else{
				$TE{$chr}->{$start} = $temp[0];
				$TE_family{$chr}->{$start} = $temp[4] . ":" . $temp[5];
			}
		}
	}

}
close(TF);


my %promoters;
find_patterns($promoter_file, \%mat_regions, \%promoters);
=head

while(<PRO>){
	chomp;
	my @temp = split "\t";
	my $chr = lc($temp[0]);
	
	foreach my $st(keys %{$mat_regions{$chr}}){
		my ($start, $end) = @{$mat_regions{$chr}->{$st}};
		if(!($end < $temp[1] || $start > $temp[2])){
			if(defined $promoters{$chr}->{$start}){
				$promoters{$chr}->{$start} .= ";" . $temp[3];
			}else{
				$promoters{$chr}->{$start} = $temp[3];
			}
		}
	}
}

close(PRO);
=cut

#############
# v1.9 downstream_1kb
############
my %down_1kbs;
find_patterns( $down_1kb_file, \%mat_regions, \%down_1kbs);

=head
while (<DOWN>) {
	chomp;
	my @temp = split "\t";
	my $chr = lc($temp[0]);
	foreach my $st(keys %{$mat_regions{$chr}}){
		my ($start, $end) = @{$mat_regions{$chr}->{$st}};
		if(!($end < $temp[1] || $start > $temp[2])){
			if(defined $down_1kbs{$chr}->{$start}){
				$down_1kbs{$chr}->{$start} .= ";" . $temp[3];
			}else{
				$down_1kbs{$chr}->{$start} = $temp[3];
			}
		}
	}
}
close (DOWN);
=cut
########################

## now intergenic
my $seqin = Bio::SeqIO->new(-file=>$inter_file, -format=>'fasta');
my %intergenic;
while(my $seq = $seqin->next_seq){
	my $chr = "chr1";
	my ($s, $e) = (0,0);
	if($seq->desc =~ /(chr\w):(\d+)\-(\d+)/){
		$chr = lc  $1;
	    ($s, $e) = ($2, $3);
		if($debug){
		    print STDERR "Intergenic start=$s, end=$e\n";
		}
	}else{
		die "Intergenic seq ", $seq->id, " does not have expected description: ", $seq->desc;
	}
	foreach my $st(keys %{$mat_regions{$chr}}){
			my ($start, $end, $p,$mstart, $mend) = @{$mat_regions{$chr}->{$st}};
			if(!($end < $s || $start > $e)){
				if(defined $intergenic{$chr}->{$start}){
					$intergenic{$chr}->{$start} .= ";" . $seq->id;
				}else{
					if($debug){
						print STDERR "Adding intergenic ", $seq->id, "\n";
					}
					$intergenic{$chr}->{$start} = $seq->id;
				}
			}
		}
}
#print join("\t", ("Chr", "Peak_Start", "Peak_End","Gene", "Strand","GeneType", "GeneAnnot",
 #                 "TE", "TEFamily", "Intergenic")), "\n";
 
 


#print join("\t", ($bed_head,"Gene", "Strand","GeneType", "GeneAnnot",
 #                 "TE", "TEFamily", "Intergenic", "Promoter_1kb")), "\n";
#############
# v1.9 downstream_1kb
############
print OUT join("\t", ($bed_head,"Gene", "Strand","GeneType", "GeneAnnot",
                  "TE", "TEFamily", "Intergenic", "Promoter_1kb", "Downstream_1kb")), "\n";
################################################
foreach my $chr(sort keys %mat_regions){
	my %reg = %{$mat_regions{$chr}};
    foreach my $start(sort {$a <=> $b} keys %reg){
	#	my ($start, $end, $p,$mstart, $mend) = @{$reg{$start}};
		my ($start, $end) = @{$reg{$start}};
	
		#my ($gene, $geneType, $geneAnnot, $TE, $TEFamily, $inter , $strand, $pro) = 
		#("NONE", "NONE", "NONE", "NONE", "NONE", "NONE" , "NONE", "NONE");
		my ($gene, $geneType, $geneAnnot, $TE, $TEFamily, $inter , $strand, $pro, $down) = 
		("NONE", "NONE", "NONE", "NONE", "NONE", "NONE" , "NONE", "NONE", "NONE");
		
		if (defined $down_1kbs{$chr}->{$start}) {
			$down = $down_1kbs{$chr}->{$start}
		}
		
		
		if(defined $genes{$chr}->{$start}){
			$gene = $genes{$chr}->{$start};
		}
		if(defined $notes{$chr}->{$start}){
			$geneType = $notes{$chr}->{$start};
		}
		if(defined $annot{$chr}->{$start}){
			$geneAnnot = $annot{$chr}->{$start};
		}
		if(defined $TE{$chr}->{$start}){
			$TE = $TE{$chr}->{$start};
		}
		if(defined $TE_family{$chr}->{$start}){
			$TEFamily = $TE_family{$chr}->{$start};
		}
		if(defined $intergenic{$chr}->{$start}){
			$inter = $intergenic{$chr}->{$start};
		}
		if(defined $strands{$chr}->{$start}){
			$strand = $strands{$chr}->{$start};
		}
		
		if(defined $promoters{$chr}->{$start}){
			$pro = $promoters{$chr}->{$start}
		}
		
	#	print join("\t", ($chr, $start, $end, $gene, $strand, $geneType, $geneAnnot,
	#	     $TE, $TEFamily, $inter)), "\n";
		#print join("\t", ($descs {$chr}->{$start}, $gene, $strand, $geneType, $geneAnnot,
		 #    $TE, $TEFamily, $inter, $pro)), "\n";
		print OUT join("\t", ($descs {$chr}->{$start}, $gene, $strand, $geneType, $geneAnnot,
		    $TE, $TEFamily, $inter, $pro, $down )), "\n";
	}
}			
close OUT;

exit;

=head
while (<DOWN>) {
	chomp;
	my @temp = split "\t";
	my $chr = lc($temp[0]);
	foreach my $st(keys %{$mat_regions{$chr}}){
		my ($start, $end) = @{$mat_regions{$chr}->{$st}};
		if(!($end < $temp[1] || $start > $temp[2])){
			if(defined $down_1kbs{$chr}->{$start}){
				$down_1kbs{$chr}->{$start} .= ";" . $temp[3];
			}else{
				$down_1kbs{$chr}->{$start} = $temp[3];
			}
		}
	}
}
close (DOWN);
=cut
#find_patterns( $down_1kb_file, \%mat_regions, \%down_1kbs);

sub find_patterns{
	my ($file, $mat_ref, $ref_feature) = @_;
	die "file $file do not exists" unless(-e $file);
	open(IN, $file) or die;
	while (<IN>) {
		chomp;
		my @temp = split "\t";
		my $chr = lc($temp[0]);
		foreach my $st(keys %{$mat_ref->{$chr}}){
			my ($start, $end) = @{$mat_ref->{$chr}->{$st}};
			if(!($end < $temp[1] || $start > $temp[2])){
				if(defined $ref_feature->{$chr}->{$start}){
					$ref_feature->{$chr}->{$start} .= ";" . $temp[3];
				}else{
					$ref_feature->{$chr}->{$start} = $temp[3];
				}
			}
		}
	}
	close(IN);
}