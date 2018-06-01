# Live Text

This project comes up with some simple Perl scripts to crawl live text commentaries and other data from German football websites and transform them in nice and handy xml files.

## Getting Started

All scripts are stand alone scripts. Just define some variables as described in the script files and there you go.

## Use

All script are run from the command line: perl script.pl

### Scripts

Both weltfussball_livetext.pl and kicker_livetext will download all live text commentaries from one season or tournament.
The output format is compatible to https://github.com/spinfo/Ticker2Chirp, a java package to prepare some data for AutoChirp (https://autochirp.spinfo.uni-koeln.de/home), a web application for automatized and prescheduled tweets.

If you want to use the data with corpus linguistic applications like Corpus Workbench or AntConc, a xsl-transformation that pushes the metadata to xml-attributes, will be necessary. You can use livetext.xsl for this purpose. 

## Purpose

To see some examples how the data can be used, please visit http://www.fussballlinguistik.de, https://twitter.com/randomlivetext or https://twitter.com/retrolivetext

## Authors

* Simon Meier-Vieracker

## License

This project is licensed under the GNU General Public License v2.0
