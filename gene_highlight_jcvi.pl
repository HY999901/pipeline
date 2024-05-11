#!/usr/bin/env perl
use strict;

die "perl $0 <geneID.list> <jcvi.anchors.new>  < jcvi.anchors.simple> >  out.highlight.simple\n" unless @ARGV==3 ;

my $ids = shift;
my $anchors = shift;
my $simple = shift;

my %id ;
open ID, $ids or die $!;
while(<ID>){
	chomp;
	my @t = split ;
	$id{$t[0]} = 1;
}
close ID;

my %block;
open AN, $anchors or die $!;
$/="###";
while(my $block = <AN>){
	chomp $block;
	next if ($block =~ /^\s*$/);
	$block =~ s/^\s+//;
	$block =~s/\s+$//;

	my @t = split /\n/, $block;
	my @ids ;
	my @tar ;
	my $flag = 0;
	foreach my $line (@t){
		my @f = split /\s+/,$line;
		if(exists $id{$f[0]} || exists $id{$f[1]}){
			$flag = 1;
		}
		push @ids, $f[0];
		push @tar, $f[1];
	}
	if($flag == 1){
		my $key = join "\t", sort ($ids[0], $ids[$#ids]);
		my $val = join "\t", sort ($tar[0], $tar[$#tar]);
		$block{$key} = $val ;
	}
}
close AN;
$/="\n";

# =cut
open SP, $simple || die $!;
while(<SP>){
	chomp;
	my @t = split ;
	my $flag = 0;
	my $id1 = join "\t", sort ($t[0], $t[1]);
	my $id2 = join "\t", sort ($t[2],$t[3]);
	if(exists $block{$id1} && $block{$id1} eq $id2 ){
		$flag = 1;
	}

	if($flag == 1){
		print "r*$_\n";
	}
	else{
		print "$_\n";
	}
}
close SP;

