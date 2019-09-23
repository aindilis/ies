# ies
Information Extraction System (an Emacs annotation/labeling system)

This system allows one to highlight text with Emacs properties, and 
save them in enriched-mode.  Text will get xml-tags like:

```
This system, <x-nlu-name>IES</x-nlu-name>, <x-nlu-description>allows 
one to label text and extract it using MALLET and hopefully other 
learners soon.</x-nlu-description>  It is available at 
<x-nlu-url>https://github.com/aindilis/ies</x-nlu-url>.
```

Assuming everything is working, different tags will be highlighted 
with different colors.

One can then select some annotated text in a region, and enter "ct" 
to generate a model from it.  Then highlight another text region to 
be labeled, and run "cc" to label it.  At time time of writing, the
untokenization step has not been completed.

Note that there is a dependency on the NLU system 
(https://github.com/aindilis/nlu) as well as on UniLang, but anyone 
with ELisp experience can probably factor out the UniLang dependency.
