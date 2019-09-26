#!/usr/bin/perl -w

use BOSS::Config;
use PerlLib::SwissArmyKnife;

$specification = q(
	-t <tokenizer>		Tokenizer to use
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
# $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";

my $tokenizer = '';
if (exists $conf->{'-t'} and $conf->{'-t'} ne 'default') {
  $tokenizer = '-t '.shell_quote($conf->{'-t'});
}

system "./convert-ies-to-mallet-sequence-tagger.pl $tokenizer -f /var/lib/myfrdcsa/codebases/minor/ies/data-git/train.txt --train > sample";
system "./train-mallet.sh";
