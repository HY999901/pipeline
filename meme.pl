#!/usr/bin/env perl 
use strict;

die "perl $0 <input.meme.txt>  <output.prefix> \n" unless @ARGV==2;

my $meme = shift;
my $out  = shift;

open O1, ">$out.motif_seq.txt" or die  $!;
open O2, ">$out.motif_prot.bed" or die  $!;
open O3, ">$out.motif_prot.txt" or die  $!;
open MEME , $meme or die  $!;
while(<MEME>){
	chomp;
	if(/^\s+Motif (\S+) (MEME-\d+) sites sorted by position p-value/){
		my $meme = $2;
		my $seq = $1;
		print O1 "$meme\t$seq\n";
		<MEME>;
		<MEME>;
		<MEME>;
		
		while( my $line = <MEME>){
			chomp $line;
			last if $line =~ /^----------/;
			my ($id, $st, $pval, $up ,$seq, $down) = split /\s+/,$line;
			my $ed = $st + length($seq) - 1;
			my $st1 = $st - 1 ;
			print O2  "$id\t$st1\t$ed\t$meme\n";
			print O3  "$id\t$st\t$ed\t$seq\t$meme\t$pval\n";
		}
	}
}
close MEME;
close O1;
close O2;
close O3;
