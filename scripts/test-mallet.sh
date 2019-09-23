#!/bin/sh

export MALLET_HOME="/var/lib/myfrdcsa/sandbox/mallet-2.0.8/mallet-2.0.8"

# java -cp "$MALLET_HOME/class:$MALLET_HOME/lib/mallet-deps.jar" cc.mallet.fst.SimpleTagger --model-file nouncrf stest2
java -cp "$MALLET_HOME/class:$MALLET_HOME/lib/mallet-deps.jar" cc.mallet.fst.SimpleTagger --include-input true --model-file nouncrf stest
