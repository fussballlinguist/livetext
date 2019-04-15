#! /usr/bin/perl -w

use strict;
use warnings;
use HTML::Entities;
use utf8;
use open ':std', ':encoding(utf8)';
$| = 1;

##########################################################################
# A script to scrape live texts from kicker.de as nice and handy xml-files
# Written by Simon Meier-Vieracker, www.fussballlinguistik.de
##########################################################################

my $url;
my @urls;
my $title;
my $date;
my $kickoff;
my $team1;
my $team2;
my $home_goal;
my $away_goal;
my $time;
my $ticker;

my $start_url = "https://www.kicker.de/news/fussball/bundesliga/spieltag/1-bundesliga/2017-18/-1/0/spieltag.html";
# --> Define the start page (to find under Liga -> Spieltag/Tabelle -> alle) 

my $path = "/path/to/filename.xml";
# --> Define path and outpute filename

############################
# no changes below this line
############################

unlink($path);
print "Hole die URLs…\n";
my $start_html = qx(curl -s $start_url);
my @lines = split /\n/, $start_html;
foreach my $line (@lines) {
	if ($line =~ m/<td><a class="link" href="(.+?)">Analyse/) {
		$url = "https://www.kicker.de" . $1;
		$url =~ s/spielanalyse/spielverlauf/;
		push @urls, $url;
	}
}
my $counter = 0;
my $length = scalar @urls;
open OUT, ">> $path" or die $!;
print OUT "<corpus>\n";
foreach my $url_game (@urls) {
	my $html = qx(curl -s $url_game);
	$counter++;
	print "\rLade Nr. $counter von $length";
	if ($html =~ /<title>(.+?)<\/title>/) {
			$title = $1;
	}
	if ($html =~ /Anstoß:<\/b><\/div>\s+<div class="wert">(\d+).(\d+).(\d+) (.+?) Uhr/) {
		$date = "$3-$2-$1";
		$kickoff = $4;
	}
	if ($html =~ /<a href=".+?">(.+?)<\/a><\/h1>\s+<\/td>\s+<td class="lttabst"/) {
		$team1 = $1;
	}
	if ($html =~ /<a href=".+?">(.+?)<\/a><\/h1>\s+<\/td>\s+<td class="lttablig lttabReload">/) {
		$team2 = $1;
	}
	if ($html =~ /class="boardH">(\d)<\/div>/) {
		$home_goal = $1;
	}
	if ($html =~ /class="boardA">(\d)<\/div>/) {
		$away_goal = $1;
	}	
	print OUT "<text>
	<url>$url_game</url>
	<title>$title</title>
	<team1>$team1</team1>
	<team2>$team2</team2>
	<date>$date</date>
	<kickoff>$kickoff</kickoff>
	<result>$home_goal:$away_goal</result>\n";	
	my @posts = split /<td class="lttdspinfo">/, $html;
	foreach my $post (@posts) {
		if ($post =~ /<div class="ltspst">(.+?) Uhr<\/div>/) {
			$time = $1;
		}
		if ($post =~ /<div class="ltereigkurz">\s+([\w\W]+?)\s+<\/div>/g) {
			$ticker = $1;
			decode_entities($ticker);
			$ticker =~ s/<br>/ /g;  
			$ticker =~ s/<br.+?>/ /g; 
			$ticker =~ s/<.+?>//g;
			$ticker =~ s/\n//g;
			$ticker =~ s/&/&amp;/g;
			$ticker =~ s/>/&gt;/g;
			$ticker =~ s/</&lt;/g;
			$ticker =~ s/\r//g;
		}
		if (defined $time) {
			$time = "<time>$time</time>";
		} else {
			$time = "<time/>";
		}
		print OUT "\t$time\n\t<p>$ticker</p>\n" if defined ($ticker);
		undef $time;
		undef $ticker;
	}
	print OUT "</text>\n";
}
print OUT "</corpus>\n";
close OUT;
print "Fertig!\n";
