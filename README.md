# ies
Information Extraction System (an Emacs annotation/labeling system)

This system allows one to highlight text with Emacs properties, and 
save them in enriched-mode.  Text will get xml-tags like:

```
This system, <x-nlu-name>IES</x-nlu-name>, <x-nlu-description>allows 
one to label some text, and then train a model and automatically 
label more text and extract it using MALLET and hopefully other 
learners soon.</x-nlu-description>  It is available at 
<x-nlu-url>https://github.com/aindilis/ies</x-nlu-url>.
```

Assuming everything is working, different tagged text will be 
highlighted  with different colors (although you won't actually see 
the x-nlu-... tags, unless you find-file-literally).

Note this is not a standalone version - this one depends on FRDCSA.  
A standalone version will probably be released eventually.

One can then select some annotated text in a region, and enter "ct" 
to generate a model from it.  Then highlight another text region to 
be labeled, and run "cc" to label it.  At time time of writing, the
untokenization step has some bugs, but this version will replace the 
unlabelled region with the automatically labeled text and highlight
it.

Note that there is a dependency on the NLU system 
(https://github.com/aindilis/nlu) as well as on UniLang, but anyone 
with ELisp experience can probably factor out the UniLang dependency.

MALLET 2.0.8 is confirmed to work with this and is available at:
http://mallet.cs.umass.edu/dist/mallet-2.0.8.tar.gz
You have to set the MALLET path in scripts2/train-mallet.sh and 
scripts2/test-mallet.sh

This system is a work in progress and is going to be hard to use
and rough around the edges.  It probably depends on a lot of other
FRDCSA software, most notably KMax (https://github.com/aindilis/kmax).
One would benefit from knowing a lot about Emacs text properties in
order to use this system until the interface gets cleaned up.

This latest version introduced dependencies on BOSS::Config and 
PerlLib::SwissArmyKnife which are in https://github.com/aindilis/boss 
and https://github.com/aindilis/perllib respectively.
