#!/bin/sh

./convert-ies-to-mallet-sequence-tagger.pl -t textmine -f /var/lib/myfrdcsa/codebases/minor/ies/data-git/train.txt --train > sample
# ./convert-ies-to-mallet-sequence-tagger.pl -f /var/lib/myfrdcsa/codebases/minor/ies/data-git/train.txt --train > sample

./train-mallet.sh
