#!/bin/sh

./convert-ies-to-mallet-sequence-tagger.pl -f train.txt --train > sample
./train-mallet.sh

./convert-ies-to-mallet-sequence-tagger.pl -f test.txt --classify > stest
./test-mallet.sh
