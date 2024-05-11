#!/usr/bin/env perl
use strict;

die "perl $0  <mcscan.gff>  <mcscanx.collinearity>  <geneID.list>   <out.pre> \n" unless @ARGV==4;

my $bed = shift;
my $anchors = shift;
my $ids = shift;
my $outpre = shift;

my $links = "$outpre.links.txt";
my $genePair = "$outpre.genepair.txt";
my $geneText = "$outpre.geneText.txt";
my $genelinks = "$outpre.geneBlocklinks.txt";


my %ids;
open ID , $ids or die  $!;
while(<ID>){
	chomp;
	next if /^\s*$/;
	my @t = split ;
	$ids{$t[0]} = 1;
}
close ID;

open TX ,">$geneText" or die  $!;

my %bed;
open BED, $bed or die  $!;
while(<BED>){
	chomp;
	my @t = split ;
	@{$bed{$t[1]}} = @t; 
	if(exists $ids{$t[1]}){
		print TX "$t[0]\t$t[2]\t$t[3]\t$t[1]\n";
	}
}
close BED;
close TX;

open LK, ">$links" or die  $!;
open GK, ">$genelinks" or die  $!;
open GP, ">$genePair"  or die  $!;

open AC, $anchors or die  $!;
$/="## Alignment";
<AC>;
while(<AC>){
	chomp;
	s/^\s+//;
	s/\s+$//;
	#print "***$_***\n\n\n";
	my @pair = split /\n/;
	shift @pair;
	#next if ($#pair < $min);
	my ($sN,$sA, $sB, $sE)  = split /\t+/,$pair[0];
	my ($eN,$eA, $eB, $eE) = split /\t+/,$pair[-1];
	my @A = ($bed{$sA}[0], int(($bed{$sA}[3]+$bed{$sA}[2])/2), int(($bed{$eA}[3]+$bed{$eA}[3])/2));
	my @B = ($bed{$sB}[0], int(($bed{$sB}[3]+$bed{$sB}[3])/2), int(($bed{$eB}[3]+$bed{$eB}[2])/2));
	my $A = join "\t" , @A;
	my $B = join "\t" , @B;
	#my $color = "lgrey";
	my $pair = 0;
	foreach my $p (@pair){
		my @t = split /\t/,$p;
		if( exists $ids{$t[1]} && exists $ids{$t[2]}){
			$color = "red";
			$pair = 1;
			print GP "$t[1]\t$t[2]\n";
		}
	}
	if($pair == 1){
		print GK "$B\t$A\n";
	}
	print LK "$B\t$A\n";
}
close AC;
close LK;
close GP;
close GK;
