#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use Encode;
use File::Slurp;

my $text = decode("UTF-8", scalar(read_file($ARGV[0])));

sub strip_newlines { $_[0] =~ s/\n/ /rg }

$text =~ s/<font size="6" style="font-size: \d+pt">(.*?)<\/font>/"# " . strip_newlines($1)/gems;
$text =~ s/<font size="5" style="font-size: \d+pt">(.*?)<\/font>/"## " . strip_newlines($1)/gems;
$text =~ s/<h2[^>]+>(.*?)<\/h2>/"#### " . strip_newlines($1)/gems;
$text =~ s/<h3[^>]+>(.*?)<\/h3>/"##### " . strip_newlines($1)/gems;
$text =~ s/<b>\s*(.*?)\s*<\/b>/ **$1** /g;
$text =~ s/<i>\s*(.*?)\s*<\/i>/ *$1* /g;
$text =~ s/\n/ /g;
$text =~ s/  / /g;
$text =~ s/<br\/>/\n/g;
$text =~ s/<\/p>/\n/g;
$text =~ s/<[^>]+>//g;
$text =~ s/^ +//gms;
$text =~ s/[“”]/"/g;
$text =~ s/’/'/g;
$text =~ s/(#+)/\n\n$1/g;

print encode("UTF-8",$text);
