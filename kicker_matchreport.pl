#! /usr/bin/perl -w

use strict;
use warnings;
use HTML::Entities;
use utf8;
use open ':std', ':encoding(utf8)';
$| = 1;

############################################################################
# A script to crawl match reports from kicker.de as nice and handy xml-files
# Written by Simon Meier-Vieracker (fussballlinguistik.de
############################################################################

my $url;
my @urls;
my $title;
my $date;
my $kickoff;
my $team1;
my $team2;
my $home_goal;
my $away_goal;
my $topline;
my $head;
my $teaser;
my $article;
my $p;

my $start_url = "https://www.kicker.de/news/fussball/bundesliga/spieltag/1-bundesliga/2016-17/-1/0/spieltag.html";
# --> Define the start page (to find under Liga -> Spieltag/Tabelle -> alle) 

my $path = "/define/path/BL1617.xml";
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
	print "\rLade Nr. $counter von $length…";

	if ($html =~ /<title>(.+?)<\/title>/) {
		$title = $1;
	}
	if ($html =~ /Anstoß:<\/b><\/div>\s+<div class="wert">(.+?)\.(.+?)\.(.+?) (.+?) Uhr/) {
		$date = "$3-$2-$1";
		$kickoff = $4;
	}		
	if ($html =~ /<h1><a href=".+?">(.+?)<\/a><\/h1>\s+<\/td>\s+<td class="lttabst"/) {
		$team1 = $1;
	}
	if ($html =~ /<h1><a href=".+?">(.+?)<\/a><\/h1>\s+<\/td>\s+<td class="lttablig/) {
		$team2 = $1;
	}
	if ($html =~ /class="boardH">(\d)<\/div>/) {
		$home_goal = $1;
	}
	if ($html =~ /class="boardA">(\d)<\/div>/) {
		$away_goal = $1;
	}

	if ($html =~ /<h2 class="topline">(.+?)<\/h2>/) {
			$topline = decode_entities($1);
			$topline =~ s/&/\&amp;/g;
	}
	if ($html =~ /h2><h1>(.+?)<\/h1>/) {
			$head = decode_entities($1);
			$head =~ s/&/\&amp;/g;
	}
	if ($html =~ /<p class="teaser">(.+?)<\/p>/) {
			$teaser = decode_entities($1);
			$teaser =~ s/&/\&amp;/g;
	}

	print OUT "<text>
	<url>$url_game</url>
	<title>$title</title>
	<team1>$team1</team1>
	<team2>$team2</team2>
	<date>$date</date>
	<kickoff>$kickoff</kickoff>
	<result>$home_goal:$away_goal</result>
	<topline>$topline</topline>
	<head>$head</head>
	<teaser>$teaser</teaser>\n";

	if ($html =~ /<!-- content -->([\w\W]+?)<!--/) {
		$article = $1;
	}
	my @paragraphs = split /<[hp]/, $article;
	foreach my $paragraph (@paragraphs) {
		if ($paragraph =~ m/^3?>(.+?)<\/[ph]3?>/g) {
			$p = $1;
			$p =~ s/<.+?>//g;
			$p = decode_entities($p);
			$p =~ s/&/\&amp;/g;
			$p = "\t<p>$p</p>\n";
			print OUT $p if defined $p;
		}
	}
	
	print OUT "</text>\n";
	sleep rand 3;
}

print OUT "</corpus>\n";
close OUT;
print "\nDone!\n";
