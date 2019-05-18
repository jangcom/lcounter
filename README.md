# lcounter

<?xml version="1.0" ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<link rev="made" href="mailto:" />
</head>

<body>



<ul id="index">
  <li><a href="#NAME">NAME</a></li>
  <li><a href="#SYNOPSIS">SYNOPSIS</a></li>
  <li><a href="#DESCRIPTION">DESCRIPTION</a></li>
  <li><a href="#OPTIONS">OPTIONS</a></li>
  <li><a href="#EXAMPLES">EXAMPLES</a></li>
  <li><a href="#REQUIREMENTS">REQUIREMENTS</a></li>
  <li><a href="#SEE-ALSO">SEE ALSO</a></li>
  <li><a href="#AUTHOR">AUTHOR</a></li>
  <li><a href="#COPYRIGHT">COPYRIGHT</a></li>
  <li><a href="#LICENSE">LICENSE</a></li>
</ul>

<h1 id="NAME">NAME</h1>

<p>lcounter - Count the numbers of lines of text files</p>

<h1 id="SYNOPSIS">SYNOPSIS</h1>

<pre><code>    perl lcounter.pl [file ...] [-comment_symbs=symb ...]
                     [-report_path=path] [-report=file]
                     [-nofm] [-nopause]</code></pre>

<h1 id="DESCRIPTION">DESCRIPTION</h1>

<pre><code>    lcounter counts the numbers of lines of the designated text files.
    Multiple text files can be designated simultaneously and, therefore,
    the total numbers of lines of source code consisting of multiple
    module/package files can be counted as a whole.
    Lines are counted as:
    - Comment line
    - Blank line
    - Plain line</code></pre>

<h1 id="OPTIONS">OPTIONS</h1>

<pre><code>    file ...
        Text files whose lines will be counted.

    -comment_symbs=symb ... (short form: -comment, default: #)
        Comment symbols of the designated text files.
        Multiple symbols are separated by the comma (,).

    -report_path=path (short form: -path, default: current working directory)
        The path in which the report file will be stored.

    -report=file (short form: -rpt, default: lcounter_result.txt)
        The report file to which the counted numbers of lines will be written.

    -nofm
        The front matter will not be displayed at the beginning of the program.

    -nopause
        The shell will not be paused at the end of the program.</code></pre>

<h1 id="EXAMPLES">EXAMPLES</h1>

<pre><code>    perl lcounter.pl lcounter.pl ./lib/My/Toolset.pm ./lib/My/Aux.pm
    perl lcounter.pl ms.tex -comment=%
    perl lcounter.pl depl.bat -comment=rem
    perl lcounter.pl mapdl.mac -comment=! -rpt=mac_num_lines.txt
    perl lcounter.pl accv.gp -comment=#,%
    perl lcounter.pl USAGE -path=./lines_counted</code></pre>

<h1 id="REQUIREMENTS">REQUIREMENTS</h1>

<p>Perl 5</p>

<h1 id="SEE-ALSO">SEE ALSO</h1>

<p><a href="https://github.com/jangcom/lcounter">lcounter on GitHub</a></p>

<h1 id="AUTHOR">AUTHOR</h1>

<p>Jaewoong Jang &lt;jangj@korea.ac.kr&gt;</p>

<h1 id="COPYRIGHT">COPYRIGHT</h1>

<p>Copyright (c) 2018-2019 Jaewoong Jang</p>

<h1 id="LICENSE">LICENSE</h1>

<p>This software is available under the MIT license; the license information is found in &#39;LICENSE&#39;.</p>


</body>

</html>
