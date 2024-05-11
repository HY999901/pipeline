#!/usr/bin/env perl -w 
use strict;

die "perl $0 <genome.len>  <mcscanx.gff>  <tandem.pair>  <genelist>  > out.mct\n" unless @ARGV==4;

my $len = shift;
my $gff = shift;
my $tandem = shift;
my $ids = shift;

print "$len\n";
my %len;
open LEN, $len or die $!;
while(<LEN>){
	chomp;
	my @t = split;
	$len{$t[0]} = $t[1];
}
close LEN;

my %ids;
open ID , $ids or die $!;
while(<ID>){
        chomp;
        next if /^\s*$/;
        my @t = split ;
        $ids{$t[0]} = 1;
}
close ID;


my %bed;
open BED, $gff or die $!;
while(<BED>){
        chomp;
        my @t = split ;
	if(exists $ids{$t[1]}){
		@{$bed{$t[0]}{$t[2]}} = @t;
	}
}
close BED;

open PR, $tandem or die $!;
while(<PR>){
	chomp;
	my @t = split /,/;
	foreach my $t (@t){
		if(exists $ids{$t}){
			$ids{$t} = "tandem";		
		}
	}
}
close PR;

foreach my $chr (sort keys %bed){
	my @pos = sort {$a<=>$b}  keys %{$bed{$chr}};
	## Mb
	my $E = $len{$chr}/1000000 ;
	print "chrom   $chr   S=0   E=$E\n";
	foreach my $p (@pos){
		my $id =  $bed{$chr}{$p}[1];
		my $ed =  $bed{$chr}{$p}[3];
		my $pp = ($ed + $p) / 2 / 1000000;
		my $color = "C2";
		if($ids{$id} eq "tandem"){
			$color = "C1";
		}
		print "$id  $pp  $color\n";
	}
}



