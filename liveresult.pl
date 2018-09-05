#! /usr/bin/perl -w

use strict;
use warnings;
use HTML::Entities;
use utf8;
use open ':std', ':encoding(utf8)';
use List::MoreUtils qw(uniq);
$| = 1;

##############################################################################
# A script to scrape live texts from liveresult.ru as nice and handy xml-files
# Written by Simon Meier-Vieracker www.fussballlinguistik.de
##############################################################################

my $start_url = "https://www.liveresult.ru/football/Russia/Premier-League/2017-2018/results/";
# --> Define the start page

my $path = "/define/path/premjerliga1718.xml";
# --> Define path and output filename

############################
# no changes below this line
############################

my $url_report;
my @urls;
my $url;
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

unlink($path);
my $start_html = qx(curl -s '$start_url');
my @lines = split /\n/, $start_html;
foreach my $line (@lines) {
	if ($line =~ m/href="(.+?)" class="matches-list-match"/) {
		$url = "https://www.liveresult.ru" . $1;
		$url =~ s/matches/txt/;
		push @urls, $url;
	}
}
@urls = uniq(@urls);
$counter_game = 0;
$length = scalar @urls;
open OUT, ">> $path" or die $!;
print OUT "<corpus>\n";
foreach my $url_game (@urls) {
	my $html = qx(curl -s '$url_game');
	$counter_game++;
	print "\rLade Nr. $counter_game von $length";
	$html =~ s/<div class="block-forecast">[\w\W]+?<\/html>//;
	if ($html =~ /itemprop="startDate" content="(.+?)T/) {
		$date = $1;
	}
	if ($html =~ /<title>(.+?)<\/title>/) {
		$title = $1;
		decode_entities($title);
	}
	if ($html =~ /itemprop="homeTeam">(.+?)</) {
		$team1 = $1;
	}
	if ($html =~ /itemprop="awayTeam">(.+?)</) {
		$team2 = $1;
	}
	if ($html =~ /<span class="score" id="score">(.+?)</) {
		$result = $1;
	}
	if ($html =~ /itemprop="startDate" content=".+?T(\d+:\d+):/) {
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
	my @posts = split /<div class="txtm m clearfix"/, $html;
	foreach my $post (@posts) {
		if ($post =~ /<div class="min">(.+?)</) {
			$time = "<time/>";
		}
		if ($post =~ /<div class="min".+?>(.+?)</) {
			$time = "<time>$1</time>";
		}
		if ($post =~ /<div class="m">(.+?)<\/div>/s) {
			$ticker = $1;
			$ticker =~ s/<script>.+?<\/script>//g;
			$ticker =~ s/<br \/>/ /g;
			$ticker =~ s/<.+?>//g;
			$ticker =~ s/&nbsp;//g;
			$ticker =~ s/\n+/ /g;
		}
		print OUT "\t$time\n\t<p>$ticker</p>\n" if defined ($ticker);
		undef $time;
		undef $ticker;
	}
	print OUT "</text>\n";
	sleep rand(3);
}
print OUT "</corpus>\n";
print "\nDone!\n";
close OUT;
