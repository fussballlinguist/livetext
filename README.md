# Live Text

This project comes up with some simple Perl scripts to scrape live text commentaries and other data from German, English and Russian football websites and transform them in nice and handy xml files.

## Getting Started

All scripts are stand alone scripts. Just define some variables as described in the script files and there you go.

## Use

All scripts are run from the command line: 
```perl script.pl```

On Unix systems, the xsl stylesheets can be run from the command line with xsltproc:
```xsltproc stylesheet.xsl input.xml > output.xml```

## Scripts

**weltfussball_livetext.pl**, **kicker_livetext.pl**, **sportal.pl** (all German) and **sportsmole_livetext.pl** (English) will download all live text commentaries from one season or tournament.
The output format (one file per season) is compatible to https://github.com/spinfo/Ticker2Chirp, a java package to prepare some data for [AutoChirp](https://autochirp.spinfo.uni-koeln.de/home), a web application for automatized and prescheduled tweets.

**kicker_matchreport.pl** (German) and **sportsmole_matchreport.pl** (English) will download all match reports of one season (tested with Bundesliga on kicker and Premier League on sportsmole, other competetions might require some minor changes in the regexes).

If you want to use the data with corpus linguistic applications like Corpus Workbench or AntConc, a xsl-transformation that pushes the metadata to xml-attributes, will be necessary. You can use **livetext.xsl** and **matchreport.xsl** for this purpose. 

## Use Cases

To see some examples how the data can be used, please visit http://www.fussballlinguistik.de, https://twitter.com/randomlivetext or https://twitter.com/retrolivetext

## Authors

Simon Meier-Vieracker, Berlin (http://www.fussballlinguistik.de)

## License

This project is licensed under the GNU General Public License v2.0
