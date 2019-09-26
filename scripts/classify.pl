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

my $command = "./convert-ies-to-mallet-sequence-tagger.pl $tokenizer -f /var/lib/myfrdcsa/codebases/minor/ies/data-git/classify.txt --classify > /var/lib/myfrdcsa/codebases/minor/ies/scripts/stest";
system $command;
system "./test-mallet.sh > /var/lib/myfrdcsa/codebases/minor/ies/scripts/untokenize/output.txt";
system "cd /var/lib/myfrdcsa/codebases/minor/ies/scripts/untokenize && ./untokenize.pl";
# system "cat /var/lib/myfrdcsa/codebases/minor/ies/scripts/untokenize/labeled.txt";
