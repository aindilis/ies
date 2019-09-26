#!/usr/bin/perl -w

use BOSS::Config;
use PerlLib::SwissArmyKnife;
use Rival::String::Tokenizer;

$specification = q(
	-f <file>	File

	-t <tokenizer>	Tokenizer
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
# $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";

die "need to specify a valid file with -f\n" unless exists $conf->{'-f'} and -f $conf->{'-f'};

my $text = read_file($conf->{'-f'});

# extract out standoff annotation

my $tokenizer = Rival::String::Tokenizer->new();

my @lines = split /\n/, $text;
my @dropped = splice(@lines,3,-1);
my $truncatedtext = join("\n", @dropped);

my @results;

my @final;
my @sequence;
my @totokenize;
my @chars = split //, $truncatedtext;
my $state = 0;
my $currenttags = {};
while (@chars) {
  my $c = shift @chars;
  if ($state == 0) {
    if ($c eq '<') {
      $state = 1;
    } else {
      push @totokenize, $c;
      push @sequence, $c;
    }
  } elsif ($state == 1) {
    if ($c eq '<') {
      $state = 0;
      push @sequence, '<';
      push @totokenize, '<';
    } elsif ($c eq '>') {
      # ProcessToTokenize(\@totokenize);
      $state = 0;
      my $tag = join('',@queue);
      if ($tag =~ /^\/(.*?)$/) {
	push @results, [$1,join('',@{$currenttags->{$1}})];
	delete $currenttags->{$1};
      } else {
	$currenttags->{$tag} = [];
      }
      push @sequence, '<<<'.$tag.'>>>';
      @queue = ();
    } else {
      push @queue, $c;
    }
  }
  foreach my $tag (keys %$currenttags) {
    push @{$currenttags->{$tag}}, $c;
  }
}
foreach my $result (@results) {
  $result->[1] =~ s/^>//s;
  my $tag = $result->[0];
  $result->[1] =~ s/<\/$tag$//s;
  $result->[0] =~ s/^x-nlu-//;
}
# print Dumper(\@results);
foreach my $result (@results) {
  print $result->[0].': '.$result->[1]."\n";
}

# ProcessToTokenize(\@totokenize);


sub ProcessToTokenize {
  my $totokenize = shift @_;
  my @args;
  if ($conf->{'-t'}) {
    push @args, 'Tokenizer';
    push @args, $conf->{'-t'};
  }
  $tokenizer->tokenize(join('',@$totokenize),@args);
  my @tokens = $tokenizer->getTokens();
  @totokenize = ();
  my @tags = sort keys %$currenttags;
  if (! scalar @tags) {
    @tags = ('none');
  }
  if ($conf->{'--train'}) {
    foreach my $token (@tokens) {
      push @final, [$token,@tags];
    }
  } elsif ($conf->{'--classify'}) {
    foreach my $token (@tokens) {
      push @final, [$token];
    }
  }
}

# foreach my $entry (@final) {
#   print join(' ', @$entry)."\n";
# }
