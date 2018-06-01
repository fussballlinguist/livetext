#! /usr/bin/perl -w

use strict;
use warnings;
use HTML::Entities;
use utf8;
use open ':std', ':encoding(utf8)';

##########################################################################
# A script to crawl live texts from sportal.de as nice and handy xml-files
##########################################################################

my $url_report;
my @urls;
my $url_game;
my $title;
my $date;
my $team1;
my $team2;
my $result;
my $kickoff;
my $time;
my $ticker;
my $counter_game;
my $length;
my $filename;

my $start_url = "http://www.sportal.de/fussball/bundesliga/spielplan/spielplan-chronologisch-saison-2017-2018/";
# --> Define the start page (to find under Liga -> Spielplan) 

if ($start_url =~ /spielplan\/(.+?)\//) {
	$filename = $1;
}

my $path = "/define/path/$filename.xml";
# --> Define path 

############################
# no changes below this line
############################

unlink($path);
my $start_html = qx(curl -s '$start_url');
my @lines = split /\n/, $start_html;
my $counter = 0;
foreach my $line (@lines) {
	if ($line =~ m/<li class="score"><a href="(.+?)"/) {
		$url_report = "http://www.sportal.de" . $1;
		my $html_report = qx(curl -s '$url_report');
		$counter++;
		print "Fetching URLs: $counter\n";
		if ($html_report =~ /<a href="(.+?)" title="Live">Live<\/a>/) {
			$url_game = "http://www.sportal.de" . $1;
		}
		push @urls, $url_game;
	}
}

$counter_game = 0;
$length = scalar @urls;
open OUT, ">> $path" or die $!;
print OUT "<corpus>\n";
foreach my $url_game (@urls) {

	my $html = qx(curl -s '$url_game');
	$counter_game++;
	print "Lade Nr. $counter_game von $length\n";

	if ($html =~ /\/(\d+-\d+-\d+)\.html/) {
		$date = $1;
	}
	if ($html =~ /<title>(.+?)<\/title>/) {
		$title = $1;
		decode_entities($title);
	}
	if ($html =~ /<div class="scoreboardTeamrowTeam1Name">(.+?)<\/div>/) {
		$team1 = $1;
	}
	if ($html =~ /<div class="scoreboardTeamrowTeam2Name">(.+?)<\/div>/) {
		$team2 = $1;
	}
	if ($html =~ /<div class="scoreboardTeamrowScoreFullscore">(.+?)<\/div>/) {
		$result = $1;
		$result =~ s/ //g;
	}
	if ($html =~ /<div class="scoreboardDatarowKickoff">.+? (\d+:\d+)</) {
		$kickoff = $1;
	}	

	print OUT "<text>
	<url>$url_game</url>
	<title>$title</title>
	<team1>$team1</team1>
	<team2>$team2</team2>
	<date>$date</date>
	<kickoff>$kickoff</kickoff>
	<result>$result</result>\n";		
	
	my @posts = split /<div id="mc_commentary_item/, $html;
	foreach my $post (@posts) {
		if ($post =~ /<div id="mc_commentary_time">(.+?)</) {
			$time = $1;
			$time =~ s/<.+?>//g;
		}
		if ($time eq "&nbsp;") {
			$time = "<time/>";
		} else {
			$time = "<time>$time</time>";
		}
		if ($post =~ /<div id="mc_commentary_comment"><.+?>(.+?)</) {
			$ticker = $1;
		}
		print OUT "\t$time\n\t<p>$ticker</p>\n" if defined ($ticker);
		undef $time;
		undef $ticker;
	}
	print OUT "</text>\n";
}
print OUT "</corpus>\n";
