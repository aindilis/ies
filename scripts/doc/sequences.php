<html>

<head>
<title>Sequences</title>
<link rel="stylesheet" type="text/css" href="mallet.css"/>
</head>

<body>


<div class="header">

<div class="logo">
<a href="index.php"><img src="logo3.png"/></a>
</div>

<div class="slogan">
MAchine Learning for LanguagE Toolkit
</div>

<div class="umass">
<img src="id_comb_1.gif"/>
</div>

<div class="clearing"></div>

</div>



<div class="sidebar">
<div><a href="index.php">Home</a></div>
<div><a href="mallet-tutorial.pdf">Tutorial slides</a> /
<a href="http://vimeo.com/76668996">video</a></div>
<div><a href="download.php">Download</a></div>
<div><a href="api">API</a></div>
<div><a href="quick-start.php">Quick Start</a></div>
<div><a href="sponsors.php">Sponsors</a></div>
<div><a href="mailinglist.php">Mailing List</a></div>
<div><a href="about.php">About</a></div>
<div>&mdash;</div>
<div><a href="import.php">Importing Data</a></div>
<div><a href="classification.php">Classification</a></div>
<div><a href="sequences.php">Sequence Tagging</a></div>
<div><a href="topics.php">Topic Modeling</a></div>
<div><a href="optimization.php">Optimization</a></div>
<div><a href="grmm/index.php">Graphical Models</a></div>
<div><a href=""></a></div>

<div class="note">MALLET is open source software 
[<a href="http://www.opensource.org/licenses/cpl1.0.php">License</a>].
For research use, please remember to <a href="about.php">cite MALLET</a>.
</div>
</div>


<div class="text-column">

<h2>Working with sequences</h2>

<div>
Many data sets, such as text collections and genetic databases,
consist of sequences of distinct values. 
MALLET includes implementations of
widely used sequence algorithms including hidden Markov models (HMMs) and 
linear chain conditional random fields (CRFs). 
These algorithms support applications such as gene finding and
named-entity recognition.
</div>

<div>
For a general introduction to CRFs, there are tutorials such as 
<a href="http://homepages.inf.ed.ac.uk/csutton/publications/crf-tutorial.pdf">Sutton and McCallum (2006)</a>. 
A developer's guide is available for <a href="fst.php">sequence tagging in MALLET</a>.
The <a href="api">MALLET Javadoc API</a> contains information for programmers
interested in incorporating sequence tagging into their own work, in the <tt>cc.mallet.fst</tt> package.  
For semi-supervised sequence labeling, see <a href="semi-sup-fst.php">this tutorial</a>.
</div>

<h3>SimpleTagger</h3>

<div>SimpleTagger is a command line interface to the MALLET Conditional
Random Field (CRF) class. Here we present an
extremely simple example showing the use of SimpleTagger to label
a sequence of text.</div>

<div>Your input file should be in the following format:</div>

<pre>        Bill CAPITALIZED noun
        slept non-noun
        here LOWERCASE STOPWORD non-noun

</pre>
<div>That is, each line represents one token, and has the format:
</div>
<pre> feature1 feature2 ... featuren label
</pre>
<div>Then you can train a CRF using SimpleTagger like this (on one line):
</div><div><br /> 
</div>
<pre>hough@gobur:~/tagger-test$ java -cp 
 "/home/hough/mallet/class:/home/hough/mallet/lib/mallet-deps.jar"
 cc.mallet.fst.SimpleTagger
  --train true --model-file nouncrf  sample

</pre>
<div>This assumes that mallet has been installed and built in /home/hough/mallet. Note that we specify the MALLET
build directory (/home/hough/mallet/class) and the necessary MALLET jar files
(/home/hough/mallet/mallet-deps.jar) in the classpath.
The <tt >--train true</tt > option specifies that we are training, and 
<tt >--model-file nouncrf</tt > specifies where we would like the CRF written to.
</div><div>This produces a trained CRF in the file "nouncrf".
</div><div>If we have a file "stest" we would like labelled:
</div><div><br /> 
</div>
<pre>CAPITAL Al
        slept
        here

</pre>
<div>we can do this with the CRF in file <tt >nouncrf</tt > by typing:
</div><div><br /> 
</div>
<pre>hough@gobur:~/tagger-test$ java -cp
"/home/hough/mallet/class:/home/hough/mallet/lib/mallet-deps.jar"
 cc.mallet.fst.SimpleTagger
--model-file nouncrf  stest

</pre>
<div>which produces the following output:
</div><div><br /> 
</div>
<pre>Number of predicates: 5
noun CAPITAL Al
non-noun  slept
non-noun  here

</pre>

<div>
To use multi-threaded CRF training, specify the number of threads with <tt>--threads</tt>:
</div>
<pre>
hough@gobur:~/tagger-test$ java -cp
 "/home/hough/mallet/class:/home/hough/mallet/lib/mallet-deps.jar"
 cc.mallet.fst.SimpleTagger
  --train true --model-file nouncrf --threads 8 sample

</pre>
<div>A list of all the options available with SimpleTagger can be obtained
by specifying the <tt >--help</tt > option:
</div><div><br /> 
</div>
<pre>hough@gobur:~/tagger-test$ java -cp
"/home/hough/mallet/class:/home/hough/mallet/lib/mallet-deps.jar"
 cc.mallet.fst.SimpleTagger
--help
</pre>

</div> <!-- end text-column -->


<div class="clearing"></div>

<div class="footer">Copyright 2018</div>

</body>


</html>
