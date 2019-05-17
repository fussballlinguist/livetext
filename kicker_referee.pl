#! /usr/bin/perl -w

use strict;
use warnings;
use HTML::Entities;
use utf8;
use open ':std', ':encoding(utf8)';
$| = 1;

##############################################################################
# A script to crawl referee reviews from kicker.de as nice and handy xml-files
##############################################################################

my $path = "/path/to/outputfile.xml";
# --> Define path and outpute filename

############################
# no changes below this line
############################

my $url;
my $url_game;
my @urls;
my $title;
my $date;
my $kickoff;
my $team1;
my $team2;
my $home_goal;
my $away_goal;
my $article;
my $referee;
my $mark;
my $p;
my $start_url = "https://www.kicker.de/news/fussball/bundesliga/spieltag/1-bundesliga/2017-18/-1/0/spieltag.html";
for (my $i = 2017; $i > 1995; $i--) {
	my $j = $i + 1;
	my $end = substr($j, -2, 2);
	my $start_url = "https://www.kicker.de/news/fussball/bundesliga/spieltag/1-bundesliga/$i-$end/-1/0/spieltag.html";
	print "\nHole die URLs… von Saison $i-$end\n";
	my $start_html = qx(curl -s '$start_url');
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
		if ($html =~ /<div class="schiedsrichter">([\w\W]+?)<div class="spldesspiels">/) {
			$article = $1;
		}
		if ($article =~ m/<a class="link".+?>(.+?)<\/a>.+?Note (\S+)<br \/>/s) {
			$referee = $1;
			$mark = $2;
		}
		if ($article =~ /<br \/>(.+?)<\/div>/s) {
			$p = $1;
			$p =~ s/[\r\n]//g;
		}
		print OUT "<text>
		<url>$url_game</url>
		<title>$title</title>
		<team1>$team1</team1>
		<team2>$team2</team2>
		<date>$date</date>
		<kickoff>$kickoff</kickoff>
		<result>$home_goal:$away_goal</result>
		<referee>$referee</referee>
		<mark>$mark</mark>
		<p>$p</p>\n";
		print OUT "</text>\n";
		sleep rand 1;
	}
	close OUT;
	undef @urls;
}
print "\nDone!\n";
