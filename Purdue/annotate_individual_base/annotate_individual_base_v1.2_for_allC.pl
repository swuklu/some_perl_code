#!/usr/bin/perl -w

#v1.2 annotate all C;
use strict;
my $debug = 0;
if($debug){
	print STDERR "debug:$debug\n";
}
#pos_id  genome  chr     pos     strand  type
#1       Ath_Col0        chr1    1       +       CHH

my $ath_file = "/Users/tang58/deep_seq_analysis/Bisulfite/work_with_Liu/data_UCR_server/ath_col0_position.txt";
die "ath_col0_position.txt" unless (-e $ath_file);

my $protein_gene_RNA_list = "/Users/tang58/DataBase/TAIR10/TAIR10_blastsets/name_list/representative_gene_model_for_protein_coding_gene.txt";
die "protein_gene_RNA_list" unless (-e $protein_gene_RNA_list);

my $protein_gene_list = "/Users/tang58/DataBase/TAIR10/TAIR10_blastsets/name_list/protein_coding_gene_name_27416.txt";
die "protein_gene_list" unless (-e $protein_gene_list);

my (%genes, %RNAs);

open(RNA, $protein_gene_RNA_list) or die "RNA:$!";
while(<RNA>){
	last if (/ATC/);
	chomp;
	$RNAs{$_} = 1;
}
close(RNA);

print STDERR "RNA: ", scalar (keys %RNAs), "\n";#27206

open(GENE, $protein_gene_list) or die "protein_gene_list:$!";
while(<GENE>){
	last if (/ATC/);
	chomp;
	$genes{$_} = 1;
}
close(GENE);

print STDERR "gene: ", scalar (keys %genes), "\n";



my $upstream_file = "/Users/tang58/DataBase/TAIR10/TAIR10_blastsets/TAIR10_upstream_1000_20101104_33602_head_file.txt";
my $utr5_file = "/Users/tang58/DataBase/TAIR10/TAIR10_blastsets/TAIR10_5_utr_20101028_head_file.txt";
my $exon_file = "/Users/tang58/DataBase/TAIR10/TAIR10_blastsets/TAIR10_exon_20101028_including_UTR_head_file.txt";
my $intron_file = "/Users/tang58/DataBase/TAIR10/TAIR10_blastsets/TAIR10_intron_20101028_head_file.txt";
my $utr3_file = "/Users/tang58/DataBase/TAIR10/TAIR10_blastsets/TAIR10_3_utr_20101028_head_file.txt";
my $downstream_file = "/Users/tang58/DataBase/TAIR10/TAIR10_blastsets/TAIR10_downstream_1000_20101104_33602_head_file.txt";
#1:up
#2:5'_UTR
#3:CDS
#4:intron
#5:3'UTR
#6:down

                           #because exon file include utr
#down -> up  ->  CDS -> 3UTR-> 5UTR -> intron
my %types; 

my $num_debug = 0;

#>AT1G08520 | chr1:2700960-2701959 FORWARD LENGTH=1000
open (DOWN, $downstream_file) or die "downstream_file: $!";
while(<DOWN>){
	chomp;
	if(/>(AT\dG\d\d\d\d\d)\s+\|\s+(chr\d):(\d+)-(\d+)/){
		my ($gene, $chr, $start, $end) = ($1, $2, $3, $4);
		if(defined $genes{$gene}){
			$num_debug++;
			for my $i($start..$end){
				$types{$chr}->[$i] = 6;
			}
		}
	}
}
close(DOWN);

print STDERR "down: " , $num_debug, "\n";

$num_debug = 0;
#>AT1G08520 | chr1:2695412-2696411 FORWARD LENGTH=1000
open(UP, $upstream_file) or die "upstream_file: $!";
while(<UP>){
	chomp;
	if(/>(AT\dG\d\d\d\d\d)\s*\|\s*(chr\d):(\d+)-(\d+)/){
		my ($gene, $chr, $start, $end) = ($1, $2, $3, $4);
		if(defined $genes{$gene}){
			$num_debug++;
			for my $i($start..$end){
				$types{$chr}->[$i] = 1;
			}
		}
	}
}
close UP;
print STDERR "up: " , $num_debug, "\n";


$num_debug = 0;
#>AT1G01010.1|exon-1 | 1-283 | chr1:3631-3913 FORWARD LENGTH=283
open (EX, $exon_file) or die "exon_file: $!";
while(<EX>){
	chomp;
	if(/>(AT\dG\d\d\d\d\d\.\d+)\s*\|\s*exon-\d+\s*\|\s*\d+-\d+\s*\|\s*(chr\d):(\d+)-(\d+)/){
		my ($RNA, $chr, $start, $end) = ($1, $2, $3, $4);
		if(defined $RNAs{$RNA}){
			$num_debug ++;
			for my $i($start..$end){
				$types{$chr}->[$i] = 3;
			}
		}
	}
}
close(EX);
print STDERR "exon: " , $num_debug, "\n";

$num_debug = 0;
#>AT1G51370.2 | [1135-1211] | chr1:19046749-19046825 FORWARD LENGTH=77
open (UTR3, $utr3_file) or die "utr3_file: $!";
while(<UTR3>){
	chomp;
	if(/>(AT\dG\d\d\d\d\d\.\d+)\s*\|.+\|\s*(chr\d):(\d+)-(\d+)/){
		my ($RNA, $chr, $start, $end) = ($1, $2, $3, $4);
		if(defined $RNAs{$RNA}){
			$num_debug ++;
			for my $i($start..$end){
				$types{$chr}->[$i] = 5;
			}
		}
	}
}
close(UTR3);
print STDERR "3UTR: " , $num_debug, "\n";

$num_debug = 0;
#>AT1G50920.1 | [1-104] [403-416] | chr1:18870139-18870554 FORWARD LENGTH=118
open (UTR5, $utr5_file) or die "utr5_file: $!";
while(<UTR5>){
	chomp;
	if(/>(AT\dG\d\d\d\d\d\.\d+)\s*\|.+\|\s*(chr\d):(\d+)-(\d+)/){
		my ($RNA, $chr, $start, $end) = ($1, $2, $3, $4);
		if(defined $RNAs{$RNA}){
			$num_debug ++;
			for my $i($start..$end){
				$types{$chr}->[$i] = 2;
			}
		}
	}

}
close(UTR5);
print STDERR "5UTR: " , $num_debug, "\n";

$num_debug = 0;
#>AT1G51370.2-1 | 874-966 | chr1:19046488-19046580 FORWARD LENGTH=93
open (IN, $intron_file) or die "intron_file: $!";
while(<IN>){
	chomp;
	if(/>(AT\dG\d\d\d\d\d\.\d+)-\d+\s*\|\s*\d+-\d+\s*\|\s*(chr\d):(\d+)-(\d+)/){
		my ($RNA, $chr, $start, $end) = ($1, $2, $3, $4);
		if(defined $RNAs{$RNA}){
			$num_debug ++;
			for my $i($start..$end){
				$types{$chr}->[$i] = 4;
			}
		}
	}
}
close(IN);
print STDERR "intron: " , $num_debug, "\n";

my @num_array = (0, 0, 0, 0, 0, 0, 0);
my $max_id = 42859753;
my $const = 3000000;
#pos_id  genome  chr     pos     strand  type
# 1    Ath_Col0  chr1    1       +       CHH
# 0			1	 2	     3       4        5	
my $l = 0;
open (ATH, $ath_file) or die "ath_file: $!";
my $head = <ATH>;
while(<ATH>){
	my @a = split "\t";
	last if ($a[0] > $max_id);
	$l++;
	if($l % $const == 0){
		print STDERR $l,"..done\n";
	}
	if(defined $types{$a[2]}->[$a[3]]){
		$num_array[ $types{$a[2]}->[$a[3]] ] ++;
	}
	else{
		$num_array[0]++;
	}
}
close(ATH);

print STDERR "line: $l\n";

#foreach my $chr (sort keys %idm1_real_pos){
#	foreach my $pos(sort {$a <=> $b} keys %{$idm1_real_pos{$chr}}){
#		if(defined $types{$chr}->[$pos]){
#			my $temp = $types{$chr}->[$pos];
#			$num_array[ $temp ] ++;
#		}
#		else{
#			$num_array[0]++;
#		}
#	}	
#}

#1:up
#2:5'_UTR
#3:CDS
#4:intron
#5:3'UTR
#6:down

my $sum = 0;
for my $i(0..6){
	$sum += $num_array[$i];
}
print STDERR "total num C: $sum\n";

my @pers = map {sprintf ("%.2f", 100 * $_ / $sum) } @num_array;

print join("\t", ("intergenic", "upstream_1000bp", "5'_UTR", "CDS", "intron", "3'_UTR", "downstream_1000bp")),"\n";
print join("\t", @num_array), "\n";
print join("\t", @pers), "\n";
exit;


sub read_file{
	my ($file, $ref_hyper, $ref_hypo) = @_;
#	print STDERR "reading $file...\t";
	open (IN, $file) or die "cannot open $file: $!";

	while(<IN>){
		chomp;
		my @a = split "\t";
		my $p_value = $a[-1] + 0;
		
	#	if($p_value <= $P_value_cutoff and $a[4] <= $depth_cutoff){
			my $sum = $a[7] + $a[10];
			if($sum > 0){
				if (  (   ($a[8] * $a[7] + $a[11] * $a[10]) / $sum ) > $a[5] ){
					${$ref_hyper}{$a[0]}->{$a[1]} = 1;
				}
				else{
					${$ref_hypo}{$a[0]}->{$a[1]} = 1;
				}
			}
			
			else{
				${$ref_hypo}{$a[0]}->{$a[1]} = 1;
			}
		#}
	}
#	print STDERR "done\n";
	close(IN);
}


sub cal_met{
	my ($ref) = @_;
	my $num = 0;
	foreach my $chr (sort keys %{$ref}){
		$num += scalar(keys %{${$ref}{$chr}})
	}
	return $num;
}