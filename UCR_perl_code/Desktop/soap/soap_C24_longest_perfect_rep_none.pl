#!/usr/bin/perl -w
# batch map clean seq to the 

use strict;

my $usage = "$0 <clean_seqs_dir> <soap_out_dir> <database>";

die $usage unless(@ARGV == 3);

my ($indir, $outdir, $db) = @ARGV[0..2];

opendir (INDIR, $indir) or die "Cannot open dir $indir:$!";

my @files = grep {/\.fasta$/} readdir INDIR;

foreach my $file(@files){
     if($file =~ /(\S+)\.fasta$/){
		 my $pre = $1;
		 my $output = $pre . "_vs_C24_cDNA_SNPonly_logest.soapout";
		 my $cmd = "/mnt/disk2/kai/soap/soap2.19release/soap -a $indir/$file -D $db -v 0 -M 0 -r 0 -o $outdir/$output";
		 
		 print $cmd, "\n";
		 #$cmd .= " 2>&1";
		 #my $msg = `$cmd 2>&1`;
		 #print $msg, "\n";
		 `$cmd`;
	 }
}

exit;