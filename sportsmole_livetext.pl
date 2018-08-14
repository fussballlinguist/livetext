#! /usr/bin/perl -w

use strict;
use warnings;
use HTML::Entities;
use utf8;
use open ':std', ':encoding(utf8)';

############################################################################
# A script to crawl match reports from kicker.de as nice and handy xml-files
############################################################################

my $url_overview;
my $url_game;
my @urls;
my $title;
my $date;
my $kickoff;
my $team1;
my $team2;
my $p;
my $time;
my $filename;
my $result;

my $start_url = "https://www.sportsmole.co.uk/football/premier-league/2017-18/results.html";
# --> Define the start page (open this URL in your browswer and choose by the dropdown menu) 

if ($start_url =~ /premier-league\/(.+?)\//) {
	$filename = $1;
}

my $path = "/Users/Simon/Korpora/Fussball/sportsmole/Liveticker/$filename.xml";
# --> Define path and outpute filename

############################
# no changes below this line
############################

unlink($path);
print "Fetching URLs…\n";
my $start_html = qx(curl -s '$start_url');
my @lines = split /\n/, $start_html;
my $counter = 0;
foreach my $line (@lines) {
	if ($line =~ m/href="(.+?_game_\d+\.html)"/) {
		$url_overview = "https://www.sportsmole.co.uk" . $1;
		my $html_overview = qx(curl -s '$url_overview');
		if ($html_overview =~ /class="game_match" href="(.+?)"><div\nclass="game_match_name">Live Commentary<\/div>/) {
			$url_game = "https://www.sportsmole.co.uk" . $1;
		}
		push @urls, $url_game if defined $url_game;
		$counter++ if defined $url_game;
		print "Fetching URL no. $counter: $url_game\n" if defined $url_game;
	}
}
my $counter_game = 0;
my $length = scalar @urls;
print " Done! $length URls fetched.\n";
open OUT, ">> $path" or die $!;
print OUT "<corpus>\n";#
foreach my $url_game (@urls) {
	my $html = qx(curl -s '$url_game');
	$counter_game++;
	print "Get no. $counter_game of $length\n";
	my @lines = split /\n/, $html;
	foreach my $line (@lines) {
		if ($line =~ /<title>(.+?)<\/title>/) {
			$title = $1;
		}
		if ($line =~ /class="game_header_score">(.+?)</) {
			$result = $1;
		}
		if ($line =~ /datetime="(.+?)T(.+?):00\+.+?"/) {
			$date = $1;
			$kickoff = $2;
		}
	}
	if ($html =~ /class="game_header_bar_team left">(.+?)</) {
		$team1 = $1;
	}
	if ($html =~ /class="game_header_bar_team left"><span[\w\W]+?desktop_only">(.+?)</) {
		$team1 = $1;
	}
	if ($html =~ /class="game_header_bar_team">(.+?)</) {
		$team2 = $1;
	}
	if ($html =~ /class="game_header_bar_team"><span[\w\W]+?desktop_only">(.+?)</) {
		$team2 = $1;
	}
	$team1 =~ s/&/&amp;/g;
	$team2 =~ s/&/&amp;/g;
	print OUT "<text>
	<url>$url_game</url>
	<title>$title</title>
	<team1>$team1</team1>
	<team2>$team2</team2>
	<date>$date</date>
	<kickoff>$kickoff</kickoff>
	<result>$result</result>\n";
	my @paragraphs = split /class="livecomm"/, $html;
	foreach my $paragraph (@paragraphs) {
		if ($paragraph =~ m/class="period">(.+?)<\/a>/g) {
			$time = $1;
		}
		if ($paragraph =~ m/class="post">([\w\W]+?)<\/span>/) {
			$p = decode_entities($1);
			$p =~ s/\n//g;
			$p =~ s/<p>/ /g;
			$p =~ s/<.+?>//g;
			$p =~ s/&/&amp;/g;
		}
		print OUT "\t<time>$time</time>\n\t<p>$p</p>\n" if defined $time;
		undef $time;
		undef $p;
	}
	print OUT "</text>\n";
	sleep rand 3;
}
print OUT "</corpus>\n";
close OUT;