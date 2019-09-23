#!/bin/sh

./convert-ies-to-mallet-sequence-tagger.pl -t textmine -f train2.txt --train > sample
# ./convert-ies-to-mallet-sequence-tagger.pl -f train2.txt --train > sample
./train-mallet.sh

./convert-ies-to-mallet-sequence-tagger.pl -t textmine -f test2.txt --classify > stest
# ./convert-ies-to-mallet-sequence-tagger.pl -f test2.txt --classify > stest
./test-mallet.sh
