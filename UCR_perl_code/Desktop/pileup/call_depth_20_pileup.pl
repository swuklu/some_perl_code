#!/usr/bin/perl -w
# batch convert fastq file to fasta file
use strict;

my $usage = "$0 <in>";
die $usage unless(@ARGV >= 1);
my $inFile = $ARGV[0];

my $IN;

open ($IN, '<', $inFile)
  or die "Cannot open $inFile: $!";

  my $gene_count = 0;
  my $position_count = 0;
  my $transcript_count = 0;
  my $line;
  my @parts;
  my %genes;
  my $gene;
  my %transcripts;
  
  while($line = <$IN>)
  {
	chomp($line);
	
	@parts = split /\t/,$line;

    if ($parts[3] >= 20)
    {
     	 $position_count++;
     	 $gene = substr($parts[0],0,9);
     	 
     	 if (exists $genes{$gene} )
     	 {
     	    ;
     	 }
     	 else
     	 {
     	 	$genes{$gene} = -1;
     	 	$gene_count++;
     	 }
     	 
     	 if (exists $transcripts{$parts[0]} )
     	 {
     	    ;
     	 }
     	 else
     	 {
     	 	$transcripts{$parts[0]}  = -1;
     	 	$transcript_count++;
     	 }
     }
  }

  close ($IN);
  print "position which depth >= 20:$position_count\n",
  "total genes:$gene_count\n";
  
  print "total transcripts:$transcript_count\n";
  
  print "\a";
  exit;
  
  