#! /usr/bin/perl -w

use strict;
use warnings;
use HTML::Entities;
use utf8;
use open ':std', ':encoding(utf8)';

############################################################################
# A script to crawl match reports from kicker.de as nice and handy xml-files
############################################################################

my $url;
my @urls;
my $title;
my $date;
my $kickoff;
my $team1;
my $team2;
my $head;
my $teaser;
my $p;
my $filename;
my $result;

my $start_url = "https://www.sportsmole.co.uk/football/premier-league/2017-18/results.html";
# --> Define the start page (open this URL in your browswer and choose by the dropdown menu) 

if ($start_url =~ /premier-league\/(.+?)\//) {
	$filename = $1;
}

my $path = "/Users/Simon/Korpora/Fussball/sportsmole/Matchreports/$filename.xml";
# --> Define path and outpute filename

############################
# no changes below this line
############################

unlink($path);
print "Fetching URLs…";
my $start_html = qx(curl -s '$start_url');
my @lines = split /\n/, $start_html;
foreach my $line (@lines) {
	if ($line =~ m/href="(.+?)">Match Report<\/a>/) {
		$url = "https://www.sportsmole.co.uk" . $1;
		push @urls, $url;
	}
}
print " Done!\n";

my $counter = 0;
my $length = scalar @urls;
open OUT, ">> $path" or die $!;
print OUT "<corpus>\n";

foreach my $url_game (@urls) {
	my $html = qx(curl -s '$url_game');	

	$counter++;
	print "Get no. $counter of $length\n";

	my @lines = split /\n/, $html;
	foreach my $line (@lines) {
		if ($line =~ /<title>(.+?)<\/title>/) {
			$title = $1;
		}
		if ($line =~ /property="og:description" content="(.+?)">/) {
			$teaser = $1;
			decode_entities($teaser);
			$teaser =~ s/&/&amp;/g;
		}		
		if ($line =~ /class="game_header_score">(.+?)</) {
			$result = $1;
		}
		if ($line =~ /datetime="(.+?)T(.+?):00\+.+?"/) {
			$date = $1;
			$kickoff = $2;
		}
		if ($line =~ /<h1 id="title_text" itemprop="headline">(.+?)<\/h1>/) {
			$head = $1;
			$head =~ s/&/&amp;/g;
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

	my @paragraphs = split /<p/, $html;
	foreach my $paragraph (@paragraphs) {
		if ($paragraph =~ m/^>([\w\W]+?)<\/p>/g) {
			$p .= "\t<p>" . $1 . "</p>\n";
			$p =~ s/<a[\w\W]+?>//g;
			$p =~ s/<strong\n[\w\W]+?>//g;
			$p =~ s/<div\n[\w\W]+?>//g;
			$p =~ s/<img\n[\w\W]+?<\/span>//g;
			$p =~ s/<\/strong>//g;
			$p =~ s/<\/div>//g;
			$p =~ s/<\/span>//g;
			$p =~ s/<\/a>//g;
			$p =~ s/\t<p><\/p>\n//g;
			$p =~ s/<br\n\/>//g;
			$p =~ s/\t<p><strong>.+?\n//gi;
		}
	}
	$p =~ s/&/&amp;/g;
		
	print OUT "\t<head>$head</head>\n" if defined $head;
	print OUT "\t<teaser>$teaser</teaser>\n" if defined $teaser;
	print OUT $p;
	print OUT "</text>\n";
	undef $p;
	undef $team1;
	undef $team2;
	undef $date;
	undef $kickoff;
	undef $head;
	sleep rand 3;
}
print OUT "</corpus>\n";
close OUT;

open FILE, "< /Users/Simon/Korpora/Fussball/sportsmole/Matchreports/$filename.xml" or die $!;
while (<FILE>) {
	$_ =~ s/&/&amp;/g;
}
close FILE;