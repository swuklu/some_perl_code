#!/usr/bin/perl -w
use strict;
use File::Spec;

my $debug = 0;

# 8/2 = 4
# 8:dividend
#2: divisor
my $usage = "$0 \n <input_db_mut> <in_db_wt>  <outdir> <outpre> <exp_cutoff>  <fold_change> \n\n";
die $usage unless(@ARGV == 6);

my $input_mut   = shift or die;
my $input_wt    = shift or die;

my $outdir = shift or die;
my $outpre = shift or die;

my $exp_cutoff  = shift or die;
my $fold_change = shift or die;

my $out_enrich   = File::Spec->catfile($outdir, $outpre . "_enriched_exp" . $exp_cutoff. "_fold" . $fold_change . ".txt" );
my $out_depleted = File::Spec->catfile($outdir, $outpre . "_depleted_exp" . $exp_cutoff. "_fold" . $fold_change . ".txt");

die unless (-e $input_mut);
die unless (-e $input_wt);
die if     ( -e $out_enrich);
die if     ( -e $out_depleted);

if($debug){
	print STDERR join( "\n", (  $out_enrich,  $out_depleted  )), "\n\n";
	exit;
}

#open( IN, "samtools view $input |") or die;
#open( , ">>$output") or die "cannot open $output: $!";

open(WT,  $input_wt) or die;
open(MUT, $input_mut) or die;

open( EN, ">>$out_enrich") or die "cannot open $out_enrich: $!";
open( DE, ">>$out_depleted") or die "cannot open $out_depleted: $!";

my $temp;
 $temp = <WT>;
 print EN "#WT\t", $temp;
 print DE "#WT\t", $temp;
 
 $temp = <MUT>;
 print EN "#mut\t", $temp;
 print DE "#mut\t", $temp;
 
 $temp = <MUT>;
 chomp $temp;
 my @a = split "\t", $temp;
 print EN join("\t", ("coordinate", "total_exp", "fold_change", @a[1..$#a]) ), "\t";
 print DE join("\t", ("coordinate", "total_exp", "fold_change", @a[1..$#a]) ), "\t";
 
 $temp = <WT>;
 chomp $temp;
@a = split "\t", $temp;
 print EN join("\t", ( @a[1..$#a]) ), "\n";
 print DE join("\t", ( @a[1..$#a]) ), "\n";
 
my ($l_wt, $l_mut);
while($l_wt = <WT>, $l_mut = <MUT>){
	chomp $l_wt;
	chomp $l_mut;
	my @a_wt  = split "\t", $l_wt;
	my @a_mut = split "\t", $l_mut;
	die  $l_wt unless ( $a_wt[0] eq $a_mut[0]);
	my $exp_wt = $a_wt[3];
	my $exp_mut = $a_mut[3];
	
	my $total_exp =  $exp_wt +  $exp_mut ;
	
	next unless ( $total_exp >= $exp_cutoff );
	
	#en
	if( $exp_mut >=  ($exp_wt * $fold_change) ) {
		my $fold = "inf";
		if( $exp_wt != 0 ){
			$fold = sprintf( "%.4f", $exp_mut / $exp_wt );
		}
		
		print EN join("\t", ( $a_wt[0], $total_exp,  $fold, @a_mut[1..$#a_mut], @a_wt[1..$#a_wt] )) , "\n"
		
	}elsif( $exp_wt >= ( $fold_change *  $exp_mut)  ){
		my $fold = "inf";
		if( $exp_mut != 0 ){
			$fold = sprintf( "%.4f", $exp_wt / $exp_mut );
		}
		print DE join("\t", ( $a_wt[0], $total_exp,  $fold, @a_mut[1..$#a_mut], @a_wt[1..$#a_wt] )) , "\n"
	}
}
close MUT;
close WT;
close DE;
close EN;

exit;

