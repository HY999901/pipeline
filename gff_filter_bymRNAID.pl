#!/usr/bin/env perl  -w
use strict;

my $a = scalar(@ARGV);
die "perl $0 <input.gff3>  <mRNA_id.list>   <out.IDtable>  <out.gff3>\n" unless (@ARGV == 4);

my $gff = shift;
my $ids = shift;
my $otab = shift;
my $ogff = shift;
my %gene2mRNA;
open GFF, $gff or die  $!;
while(<GFF>){
	chomp;
	next if /^#/;
	my @t = split /\t/;
	next unless  ($t[8] =~ /ID=/ &&  $t[8] =~ /Parent=/);

	$t[8] =~ /ID=([^;]+)/;
	my $id1 = $1;
	$t[8] =~ /Parent=([^;]+)/;
	my $id2 = $1;
	
	if($t[2] eq "mRNA"){
		$gene2mRNA{$id2}{$id1} = 1;
	}
}
close GFF;

my %mRNA;
open IN, "$ids" or die  $!;
while(<IN>){
	chomp;
	next if /^\s*$/;
	my @t = split ;
	$mRNA{$t[0]} = 1
}
close IN;


open O1, ">$otab" or die  $!; 
my %gene;
foreach my $geneID (keys %gene2mRNA) {
	my @mRNA = keys %{$gene2mRNA{$geneID}};
	my $flag = 0;
	foreach my $mRNA (@mRNA){
		if(exists $mRNA{$mRNA}){
			$flag ++;
			$gene{$geneID} = $mRNA;
			print O1 "$geneID\t$mRNA\n";
		}
	}
}
close O1;

open O2, ">$ogff" or die  $!; 
open GFF, $gff or die  $!;
while(my $line = <GFF>){
	chomp $line ;
	next if $line =~ /^#/;
	my @t = split /\t/, $line;
	next unless  ( @t == 9);

	my $id1 = "NA";
	my $id2 = "NA";
	if($t[8] =~ /ID=([^;]+)/){
		$id1 = $1;
	}

	if($t[8] =~ /Parent=([^;]+)/){
		$id2 = $1;
	}
	
	my $out = $line ;
	my $flag = 0;
	if($t[2] eq "gene"){
		next unless exists $gene{$id1}; 
		$flag = 1;
	}

	if($t[2] eq "mRNA"){
		next unless exists $mRNA{$id1};
		$flag = 1;
	}

	if($t[2] =~ /CDS/i || $t[2] =~ /exon/i || $t[2] =~  /UTR/i){
		next unless exists $mRNA{$id2};
		$flag = 1;
	}
	if($flag == 1){	
		print O2 "$out\n";
	}
}
close GFF;
close O2;


