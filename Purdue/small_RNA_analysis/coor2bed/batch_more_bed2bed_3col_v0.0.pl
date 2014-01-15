#!/usr/bin/perl -w

#use File::Spec;
#my $outFile_ge9 = File::Spec->catfile($outDir, join(".", @parts) . "_ge9." . $ext);
# my ($volume,$directories,$file) =          File::Spec->splitpath( $path );


use strict;
use File::Spec;

my $debug = 0;

my $script = "/Users/tang58/scripts_all/perl_code/Purdue/small_RNA_analysis/coor2bed/more_bed2bed_3col_v0.0.pl";

die unless (-e $script);

if($debug){
	print STDERR "debug = 1\n\n";
}
my $usage = "$0 \n <indir> <outdir>\n\n";
die $usage unless(@ARGV == 2);

my $indir = shift or die;
my $outdir = shift or die;

die unless (-d $indir);
die unless (-d $outdir);

opendir(DIR, $indir) or die "cannot open $indir: $!";
my @files = grep /txt$/, readdir DIR;
closedir DIR;

foreach my $file (@files){
	if ( $file =~ /(\S+)\.txt$/) {
		my $pre = $1;
		my $input = File::Spec->catfile($indir, $file);
		die unless (-e $input);
		my $output = File::Spec->catfile($outdir, $pre . "_bed.txt");
		my $cmd = "perl $script $input $output";
		print STDERR $cmd, "\n\n";
		if (!$debug) {
			`$cmd`;
		}
		
	}
	
}

exit;