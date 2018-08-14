#! /usr/bin/perl -w

use strict;
use warnings;
use HTML::Entities;
use utf8;
use open ':std', ':encoding(utf8)';
$| = 1;

#############################################################################
# A script to scrape match reports from kicker.de as nice and handy xml-files
#############################################################################

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
my $p;

my $start_url = "http://www.kicker.de/news/fussball/bundesliga/spieltag/1-bundesliga/2017-18/-1/0/spieltag.html";
# --> Define the start page (to find under Liga -> Spieltag/Tabelle -> alle) 

my $path = "/define/path/filename.xml";
# --> Define path and outpute filename

############################
# no changes below this line
############################

unlink($path);
my $start_html = qx(curl -s '$start_url');
my @lines = split /\n/, $start_html;
foreach my $line (@lines) {
	if ($line =~ m/<td><a class="link" href="(.+?)">Analyse/) {
		$url = "http://www.kicker.de" . $1;
		push @urls, $url;
	}
}

my $counter = 0;
my $length = scalar @urls;
open OUT, ">> $path" or die $!;
print OUT "<corpus>\n";

foreach my $url_game (@urls) {
	my $html = qx(curl -s '$url_game');	

	$counter++;
	print "\rLade Nr. $counter von $length";
	my @lines = split /\n/, $html;
	foreach my $line (@lines) {
		if ($line =~ /<title>(.+?)<\/title>/) {
			$title = $1;
		}
	}		

	my @infos = split /<h3 class="thead336">\nSpielinfo/, $html;
	foreach my $info (@infos) {
		if ($info =~ /Anstoß:<\/b><\/div>\s+<div class="wert">(.+?) (.+?) Uhr/) {
			$date = $1;
			$kickoff = $2;
		}
	}		

	my @headers = split /<h1>/, $html;
	foreach my $header (@headers) {
		if ($header =~ /<a href=".+?">(.+?)<\/a><\/h1>\s+<\/td>\s+<td class="lttabst"/) {
			$team1 = $1;
		}
		if ($header =~ /<a href=".+?">(.+?)<\/a><\/h1>/) {
			$team2 = $1;
		}
		if ($header =~ /class="boardH">(\d)<\/div>/) {
			$home_goal = $1;
		}
		if ($header =~ /class="boardA">(\d)<\/div>/) {
			$away_goal = $1;
		}	
	}

	print OUT "<text>
	<url>$url_game</url>
	<title>$title</title>
	<team1>$team1</team1>
	<team2>$team2</team2>
	<date>$date</date>
	<kickoff>$kickoff</kickoff>
	<result>$home_goal:$away_goal</result>\n";		

	my @headlines = split /<div id="ovContent">/, $html;
	foreach my $headline (@headlines) {
		if ($headline =~ /<h2 class="topline">(.+?)<\/h2>/) {
			$topline = $1;
		}
		if ($headline =~ /h2><h1>(.+?)<\/h1>/) {
			$head = $1;
		}
		if ($headline =~ /<p class="teaser">(.+?)<\/p>/) {
			$teaser = $1;
		}
	}	

	my @paragraphs = split /<p/, $html;
	foreach my $paragraph (@paragraphs) {
		if ($paragraph =~ m/^>(.+?)<\/p>/g) {
			$p .= "\t<p>" . $1 . "</p>\n";
			$p =~ s/<a .+?>//g;
			$p =~ s/<b>//g;
			$p =~ s/<div .+?>//g;
			$p =~ s/<\/div>//g;
			$p =~ s/<\/[ab]>//g;
		}
	}	

	print OUT "\t<topline>$topline</topline>\n" if defined $topline;
	print OUT "\t<head>$head</head>\n" if defined $head;
	print OUT "\t<teaser>$teaser</teaser>\n" if defined $teaser;
	print OUT $p;
	print OUT "</text>\n";
	undef $p;
	sleep rand 3;
}
print OUT "</corpus>\n";
close OUT;
