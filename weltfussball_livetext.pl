#! /usr/bin/perl -w

################################################################################
# A script to scrape live texts from weltfussball.de as nice and handy xml-files
################################################################################

use strict;
use warnings;
$| = 1;

my $url;
my @urls;
my $title;
my $date;
my $kickoff;
my $result;
my $time;
my $ticker;
my $team1;
my $team2;
my $filename;

my $start_url = "http://www.weltfussball.de/alle_spiele/bundesliga-2017-2018/";
# --> Define the start page (to find under Liga -> Spielplan) 

if ($start_url =~ /alle_spiele\/(.+?)\//) {
	$filename = $1;
}
my $path = "/define/path/$filename.xml";
# --> Define path

############################
# no changes below this line
############################

unlink($path);
my $start_html = qx(curl -s -L '$start_url');
my @lines = split /\n/, $start_html;
foreach my $line (@lines) {
	if ($line =~ m/(\/spielbericht\/.+?)"/) {
		$url = "https://www.weltfussball.de" . $1 . "liveticker/";
		push @urls, $url;
	}
}
my $length = scalar @urls;
my $counter = 0;
open OUT, ">> $path" or die $!;
print OUT "<corpus>\n";
foreach my $url_game (@urls) {
	my $html = qx(curl -s -L '$url_game');
	$counter++;
	print "\rGetting no. $counter of $length";
	my @lines = split /\n/, $html;
	foreach my $line (@lines) {
		if ($line =~ /<title>(.+?)<\/title>/) {
			$title = $1;
		}
	}
	my @headers = split /table class="standard_tabelle" cellpadding="3" cellspacing="1"/, $html;
	foreach my $header (@headers) {
		if ($header =~ /<th align="center" width="35%">[\w\W]+?<th align="center">\s+(.+?)<br\/>(.+?) Uhr\s+<\/th>/) {
			$date = $1;
			$kickoff = $2;
		}
		if ($header =~ /<div class="resultat">\s+(.+?) \t+<\/div>/) {
			$result = $1;
		}
		if ($header =~ /<tr>\s+<th align="center" width="35%">[\w\W]+?<a href=".+?" title="(.+?)"/) {
			$team1 = $1;
		}
		if ($header =~ /<\/th>\s+<th align="center" width="35%">[\w\W]+?<a href=".+?" title=".+?">(.+?)<\/a>\s+<\/th>/) {
			$team2 = $1;
		}
	}
	print OUT "<text>
	<url>$url_game</url>
	<title>$title</title>
	<team1>$team1</team1>
	<team2>$team2</team2>
	<date>$date</date>
	<kickoff>$kickoff</kickoff>
	<result>$result</result>\n";
	my @posts = split /gross" width="50" align="center"/, $html;
	foreach my $post (@posts) {
		if ($post =~ /^>[\w\W]+?(\d+')/) {
			$time = $1;
		}
		if ($post =~ /<div class="wfb-tickertext">([\w\W]+?)<\/div>/g) {
			$ticker = $1;
			$ticker =~ s/<br>/ /g; 
			$ticker =~ s/<br.+?>/ /g; 
			$ticker =~ s/<.+?>//g;
			$ticker =~ s/\n//g;
			$ticker =~ s/&/&amp;/g;
			$ticker =~ s/>/&gt;/g;
			$ticker =~ s/</&lt;/g;
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
	sleep rand(3);
}
print OUT "</corpus>\n";
close OUT;
