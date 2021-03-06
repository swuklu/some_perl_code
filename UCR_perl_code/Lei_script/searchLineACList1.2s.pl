#!/usr/bin/perl
# Copyright (c)  2008--
# Program:			searchLineACList
# Author:			Gaolei <highlei@gmail.com>
# Program Date:		2008.10.17
# Modifier:			Gaolei <highlei@gmail.com>
# Last Modified:	2008.10.17
# Description:		extract lines from database file according to filelist or name
# version: 1.2
# **************************
# Version: 1.0s	for the two name list (both -i and -l have only one column)
# Version: 1.1s	add $col_Lst and $col_DB
# Version: 1.2s add print special line e.g. ^> or ^#
# **************************


# e-mail:highlei@gmail.com
# ^-^

my $version="1.2s";
print STDERR ("\n============================================================\n");

my $start = time();
my $Time_Start = sub_format_datetime(localtime(time())); #运行开始时间
print STDERR "Now = $Time_Start\n\n";


use Getopt::Std;
getopts("hi:s:l:r:c:d:p:");
my $infile		= $opt_i;
my $string		= $opt_s;
my $filelist	= (defined $opt_l) ? $opt_l : "";
my $reversive	= (defined $opt_r) ? $opt_r : "";
my $col_Lst		= (defined $opt_c) ? $opt_c-1 : 0;	## the column
my $col_DB		= (defined $opt_d) ? $opt_d-1 : 0;	## the column
my $specialLine	= (defined $opt_p) ? $opt_p : "";


if ($opt_h || $infile eq "" || ($string eq "" && $filelist eq "")) {
	usage();
}
use FileHandle;
use strict;

my $head = 100;
my $tail = 100;

my ($i,$j,$k,$m,$n,$k1,$k2,$k3,$file,$flag,$line,$key,$end);
my (%gnm);
my $skipLst	= "";
my $skipDB	= "";




#===========================================================================================================
#====================                  main
#===========================================================================================================
for ($k1 = 0;$k1 < $col_Lst ;$k1++) {
	$skipLst	.= "\\S+\\s+";
}
for ($k1 = 0;$k1 < $col_DB ;$k1++) {
	$skipDB	.= "\\S+\\s+";
}
if ($string ne "") {
	if (exists($gnm{$string})) {
		print STDERR "the string occupy many time!!\n";
	} else {
		$string =~ s/(\W)/\\$1/g;
		$gnm{$string} = 1;
	}
}

$k1	= 0;
if ($filelist ne "") {
	$file = new FileHandle("$filelist") || die("Cannot open file: $filelist!\n");
	while (<$file>) {
#		$_ =~s/^[\s|\t]+//g;
#		$_ =~s/[\s|\t|\r|\n]+$//g;
		if ($_ =~ /^>?$skipLst(\S+)/) {
			if (exists($gnm{$1})) {
				$_ =~s/[\s|\t|\r|\n]+$//g;
				print STDERR "this keyword:$1 in $_ at line $k1 occurs many time!!\n";
			} else {
				$gnm{$1} = 1;	$k1++;	#print STDERR "$1,";
			}
		}
	}
	close $file || die;
}

print STDERR "\nThere are $k1 tags in $filelist!\n";

$m = 0;	$flag	= 0;	$n	= 0;
$file = new FileHandle ("$infile") || die("Cannot open file $infile!");
#$i= <$file>;	print	$i;
while ($j=<$file>) {
	$j=~s/^[\s|\t]+//g;
#	$j=~s/[\s|\t|\r|\n]+$//g;
	if ($specialLine ne "" && $j =~/$specialLine/) {
		print $j; next;
	}
	$j=~/^>?$skipDB(\S+)/;
	$i	= $1;
#	foreach $key (keys(%gnm)) {
	#	$key	= quotemeta($key);
		if (exists($gnm{$i}) && $reversive eq "") {
			print $j;	#print STDERR "--$i,$key;==\n";
			$m++;	$flag	= 2;	$m%100000!=0 || printf STDERR "%d,",$m;
#			last;
		} elsif (exists($gnm{$i})) {
			$flag	= 2;#	last;
		}
#	}
	$n++%500 == 0 && print STDERR $n,",";
	if ($flag	== 0 && $reversive ne "") {
		print $j;
		$m++;	$flag	= 0;printf STDERR "%d,",$m;
#		print STDERR $m," ";
	} elsif ($flag	== 2) {
		$flag = 0;
	} 
}

close $file || die("Wrong!");

print STDERR "\nthere is $m sequences in this file\n";

print STDERR ("============================================================\n");
my $Time_End = sub_format_datetime(localtime(time()));
print STDERR "Running from [$Time_Start] to [$Time_End]\n";
$end = time();
printf STDERR ("Total execute time : %.2f s\n",$end-$start);
print STDERR ("............................................................\n");

#############################################################################################################
####################################                                         ################################
####################################              "main end"                 ################################
####################################                                         ################################
#############################################################################################################


sub usage
{
	print "Contact : Gaolei <highlei\@gmail.com>";
	print "\nProgram : $0\nVersion: $version\n";
	print "Usage:\n	$0 \n";
	print "-i	input infile\n";
	print "			eg: anc.001\n";
	print "-s	input querry sting\n";
	print "			eg: ARGTK\n";
	print "-l	input sequence name list file\n";
	print "			eg: seqname.lis\n";
	print "-r	reverse the result!\n";
	print "			eg: -r n; default: donot reverse\n";
	print "-c	use the nth column in -l filelist\n";
	print "			eg: -c 2; default: 1, ie the 1st column\n";
	print "-d	use the nth column in -i infile\n";
	print "			eg: -d 2; default: 1, ie the 1st column\n";
	print "-p	output the special line.\n";
	print "			eg: ^> or ^#; default: no\n";
	print "-h	display this lines\n";
	print "\nExample:\n";
	print "$0 -i anc.001 -l seqname.lis\n";
	print "$0 -i anc.001 -l seqname.lis -r n \n";
	print "$0 -i anc.001 -l seqname.lis -c 1 -d 1\n";
	print"\n============================================================\n\n";

    exit(0);
}
############################################################################################################
######################                  sub_format_datetime
############################################################################################################

sub sub_format_datetime #时间子程序
{
    my ($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = @_;
    sprintf("%4d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon+1, $day, $hour, $min, $sec);
}


