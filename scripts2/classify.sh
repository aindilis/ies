#!/bin/sh

./convert-ies-to-mallet-sequence-tagger.pl -t textmine -f /var/lib/myfrdcsa/codebases/minor/ies/data-git/classify.txt --classify > stest
# ./convert-ies-to-mallet-sequence-tagger.pl -f /var/lib/myfrdcsa/codebases/minor/ies/data-git/classify.txt --classify > stest
./test-mallet.sh
