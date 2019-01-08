#! /usr/local/bin/perl

use strict;
use warnings;
use utf8;
use open ':std', ':encoding(utf8)';
$| = 1;

##################################################################
# A script to scrape cumulated "Elf des Tages" data from kicker.de
# Written by Simon Meier-Vieracker, www.fussballlinguistik.de
##################################################################

my %names;
my %teams;

my $start = "http://www.kicker.de/news/fussball/bundesliga/spieltag/1-bundesliga/2017-18/0/elf-des-tages-am-spieltag.html";
my $start_html = qx(curl -s $start);
my $seasonlist;
if ($start_html =~ /SelectOutList\('saisonlist'\);">([\w\W]+?)<\/dl>/) {
	$seasonlist = $1;
}
my @seasons = split(/<dt>/,$seasonlist);
my $season;
my $nr;
my $seasons_nr = scalar @seasons - 2;
print "$seasons_nr Saisons insgesamt.\n";
print "Wie viele Saisons sollen berücksichtigt werden? ";
my $string=<STDIN>;
chomp $string;
$string = $string + 1;
for (@seasons[2..$string]) {
	if ($_ =~ /1-bundesliga\/(\S+)\/0\//) {
		$season = $1;
	}
	print "\nSaison $season\n";
	for (my $i = 1; $i < 35; $i++) {
		my $url = "http://www.kicker.de/news/fussball/bundesliga/spieltag/1-bundesliga/$season/$i/elf-des-tages-am-spieltag.html";
		my $html = qx(curl -s $url);
		print "\r\tSpieltag $i";
		my @players = split(/<div style="position/,$html);
		shift @players;
		foreach my $player (@players) {
			if ($player =~ /<a href="\/news\/fussball\/bundesliga\/.+?\/spieler_(.+?)\.html" id="/) {
				$names{$1}++;
			}
			if ($player =~ /<div class="vereinslogo">.+? title="(.+?)"/) {
				$teams{$1}++;
			}
		}
	}
}
print "\nSpieler:\n";
foreach (sort {$names{$b} <=> $names{$a}} keys %names) {
	print "$_\t$names{$_}\n";
}
print "-----------\nClubs:\n";
foreach (sort {$teams{$b} <=> $teams{$a}} keys %teams) {
	print "$_\t$teams{$_}\n";
}
