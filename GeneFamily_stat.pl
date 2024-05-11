#!/usr/bin/env perl
use strict;

die "$0 <input.gff> <input.pIkD>  > genefamily_out.table\n" unless @ARGV ==2;

my $gff = shift;
my $pI = shift;

my %pI;
open PI, $pI or die  $!;
while(<PI>){
	chomp;
	my @t = split /\s+/;
	my $id = shift @t;
	$pI{$id} = join "\t", @t;
}
close PI;


print "geneID\tChr\tstart\tend\taalen\tMolWt\n";
open GFF, $gff or die  $!;
while(<GFF>) {
	chomp;
	next if /^#/;
	my @t = split /\t/;
	if($t[2] eq  "mRNA"){
		$t[8] =~ /ID=([^;]+)/;
		if(exists $pI{$1}){
			print "$1\t$t[0]\t$t[3]\t$t[4]\t$pI{$1}\n";
		}
	}
}
close GFF;


