#!/usr/bin/perl -w
use strict;
use Getopt::Long;

my $input = {};   

if (scalar(@ARGV) <= 0) {
    option();
}

else

{
my @m; my $m; my $d=""; my $t="";
GetOptions ('m=s'=>\$m, 'd=s'=>\$d, 't=s'=>\$t);
if (($t<=>1)and($t<=>0)) {die $!;}
my $dirlength=length $d; my $lastchar=substr($d, $dirlength-1, 1);
if ($lastchar cmp "/") {$d=$d."/";}

my $outputname;
$outputname=$d.$m.".constance" if ($t==0);
$outputname=$d.$m.".trimmed" if ($t==1);

my $switch; my @gene; my @read; my $genecount; my @coverage; my $min=9999;

my @head;
open out_pattern, ">$outputname" or die $!;
print out_pattern "\t";
for (my $run=1; $run<=120; $run++)
{
    print out_pattern "$run";
    print out_pattern "\t" if ($run<120);
}
print out_pattern "\n";

open cov_chr, "$m" or die $!;
for (my $file=1; $file<=5; $file++)
{
    print "Loading Annotation of Chromosome $file...\n";
    open at_anno, "/home/chongyuan/bioinformatics/Reference/NCBI_chr$file.tbl" or die $!;
    $switch=0; $genecount=0;
        
        while (<at_anno>)
        {
            chop $_;
            @read=split("\t", $_);
            if (($read[2])and($read[2]eq"gene"))
            {
                $switch=1;
                if ($read[0]<$read[1]) {$gene[$genecount][0]=1;} else {$gene[$genecount][0]=-1;}
                $gene[$genecount][1]=$read[0];$gene[$genecount][2]=$read[1];
            }
            elsif ($switch==1)
            {
                $switch=0; $gene[$genecount][3]=$read[4];
                $genecount++;
            }
        }
        $genecount--;
        
    close at_anno;
    print "$genecount\tDONE\n"; 
    
    print "Loading Coverage Data for Chr$file...\n";
    my $basecount=-1; my $read=1;
    while ($read==1)
    {
        $_=<cov_chr>;
        $read=0 if (!$_);
        if ($read==1)
        {
            $read=0 if (substr($_,0,1) eq "S");
            if ($read==1)
            {
                chop $_;
                $basecount++;
                @read=split(/\t/,$_);
                $coverage[$basecount]=$read[1];
            }
        }        
    }
    print "$basecount\n";    
    print "DONE\n";
    
    print "Calculating Coverage Over Gene Bodies for Chromosome $file...\n";
    my $head; my $tail; my $step; my $length; my $store; my $sum; my $baseleft; my $pos; my $dist;
    
    for (my $gene=0; $gene<=$genecount; $gene++)
    {
        $head=$gene[$gene][1]-($gene[$gene][0]*1000); $tail=$gene[$gene][1]+($gene[$gene][0]*5000);
        if (($head<$basecount)and($head>0)and($tail>0)and($tail<$basecount))
        {
            for (my $run=0; $run<=120; $run++) {$head[$run]=0;}
            
            $length=abs($gene[$gene][1]-$gene[$gene][2]);
            if ($t==1)
            {
                if ($length>5000) { $dist=5999; }
                else { $dist=$length+999; }
            }
            else {$dist=5999;}
            
            $step=1;
            while ($step<=$dist)
            {
                $pos=int($step/50);
                $head[$pos]=$head[$pos]+($coverage[$head]/50);
                $head=$head+$gene[$gene][0];
                $step++;
            }
            
            print out_pattern "$gene[$gene][3]\t";
            for (my $run=0; $run<=119; $run++)
            {
                print out_pattern "$head[$run]";
                print out_pattern "\t" if ($run<119);
            }
            
            print out_pattern "\n";    
        }        
    }
    print "DONE\n";
}
close out_pattern;
}

sub option
{
    print "Constant_TSS_mapping.pl\nChongyuan Luo, Biotech, Rutgers\nAug. 2009\n\nOptions\n";
    print "-m input coverage file\n";
    print "-d output path\n";
    print "-t 1: trim tags mapped outside of gene body 0: no trimming\n";
}                                                                                                                                                                                                                                          