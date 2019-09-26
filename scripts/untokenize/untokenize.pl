#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

my $fh = IO::File->new();
$fh->open('> /var/lib/myfrdcsa/codebases/minor/ies/scripts/untokenize/labeled.txt') or die "ouch!\n";

# print $fh "Content-Type: text/enriched\n";
# print $fh "Text-Width: 70\n";
# print $fh "\n\n\n";

my $c1 = read_file('/var/lib/myfrdcsa/codebases/minor/ies/scripts/untokenize/output.txt');
my $c2 = read_file('/var/lib/myfrdcsa/codebases/minor/ies/data-git/classify.txt');

my @lines = split /\n/, $c1;
# shift @lines;
foreach my $line (@lines) {
  my @features = split /\s+/, $line;
  my $label = shift @features;
  my $word = pop @features;
  push @items, [$label,\@features,$word];
}

my $res1 = ReapplyLabels
  (
   Items => \@items,
   Text => $c2,
  );
if ($res1->{Success}) {
  # print $res1->{Result}."\n";
}

sub ReapplyLabels {
  my (%args) = @_;
  my @total;

  my $c = $args{Text};
  my @text_chars = split //, $c;

  while (@{$args{Items}}) {
    my $item = shift @{$args{Items}};
    my $label = $item->[0];
    my $word = $item->[2];
    # print "<$word>\n";
    my @word_chars = split //, $word;
    my @passed_chars;
    while (scalar @word_chars) {
      while (scalar @text_chars and ($text_chars[0] ne $word_chars[0])) {
	my $t1 = shift @text_chars;
	# print "<$t1>\n";
	push @passed_chars, [$t1,$label];
      }

      my $t1 = shift @text_chars;
      # print "<$t1>\n";
      push @passed_chars, [$t1,$label];

      shift @word_chars;
    }
    # print Dumper(\@passed_chars);
    foreach my $entry (@passed_chars) {
      push @total, $entry;
    }
  }
  my @passed_chars_2 = ();
  foreach my $char (@text_chars) {
    push @passed_chars_2, [$char,'none'];
  }
  foreach my $entry (@passed_chars_2) {
    push @total, $entry;
  }
  # print Dumper(\@total);
  my $lastlabel = 'none';
  my $opennext = '';
  foreach my $entry (@total) {
    if ($entry->[1] ne $lastlabel) {
      if ($lastlabel ne 'none') {
	push @row, '</'.$lastlabel.'>';
	push @row, $entry->[0];
      } elsif ($entry->[1] ne 'none') {
	push @row, $entry->[0];
	push @row, '<'.$entry->[1].'>';
	# $opennext = '<'.$entry->[1].'>';
      }
    } else {
      push @row, $entry->[0];
      # if ($opennext) {
      # 	push @row, $opennext;
      # 	$opennext = '';
      # }
    }
    $lastlabel = $entry->[1];
  }
  my $result = join('',@row);
  print $fh $result."\n";
}

$fh->close();
