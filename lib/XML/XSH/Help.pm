# This file was automatically generated from src/xsh_grammar.xml on 
# Mon Sep  2 17:38:13 2002

package XML::XSH::Help;
use strict;
use vars qw($HELP %HELP);


$HELP=<<'END';
General notes:

  XSH acts as a command interpreter. Individual commands must be separated
  with a semicolon. Each command may be followed by a pipeline redirection
  to capture the command's output. In the interactive shell, backslash may
  be used at the end of line to indicate that the command follows on the
  next line.

  A pipeline redirections may be used either to feed the command's output
  to a unix command or to store it in a XSH string variable.

  In the first case, the syntax is `xsh-command | shell-command ;' where
  `xsh-command' is any XSH command and `shell-command' is any command (or
  code) recognized by the default shell interpreter of the operating system
  (i.e. on UNIX systems by `sh' or `csh', on Windows systems by `cmd').
  Brackets may be used to join more shell commands (may depend on which
  shell is used).

Example: Count any attributes that contain string foo in its name or value.

  xsh> list //words/attribute() | grep foo | wc

  In order to store a command's output in a string variable, the pipeline
  redirection must take the form `xsh-command |> $variable' where
  `xsh-command' is any XSH command and `$variable' is any valid name for a
  string <variable>variable.

Example: Store the number of all words in a variable named count.

  xsh> count //words |> $count

  `<help> command' gives a list of all XSH commands.

  `<help> type' gives a list of all argument types.

  `<help>' followed by a command or type name gives more information on the
  particular command or argument type.

END

$HELP{'command'}=[<<'END'];
List of XSH commands

description:
	     assign, backups, call, cd, clone, close, copy, count, create,
	     debug, def, defs, dtd, enc, encoding, exec, exit, files, fold,
	     foreach, help, if, include, indent, insert, keep-blanks, lcd,
	     load-ext-dtd, locate, ls, map, move, nobackups, nodebug, open,
	     open-HTML, open-PIPE, options, parser-completes-attributes,
	     parser-expands-entities, parser-expands-xinclude,
	     pedantic-parser, perl, print, process-xinclude, pwd,
	     query-encoding, quiet, recovering, remove, run-mode, save,
	     save-HTML, save-xinclude, saveas, select, sort, test-mode,
	     unfold, unless, valid, validate, validation, variables,
	     verbose, version, while, xcopy, xinsert, xmove, xslt, xupdate

END


$HELP{'command-block'}=[<<'END'];
command-block argument type

description:
	     XSH command or a block of semicolon-separated commands
	     enclosed within curly brackets.

Example:     Count paragraphs in each chapter

             $i=0;
             foreach //chapter {
             $c=./para;
             $i=$i+1;
             print "$c paragraphs in chapter no.$i";
             }

END


$HELP{'type'}=[<<'END'];
List of command argument types

description:
	     command-block, enc-string, expression, filename, id, location,
	     node-type, perl-code, xpath

END


$HELP{'expression'}=[<<'END'];
expression argument type

description:
	     A string consisting of unquoted characters other than
	     whitespace or semicolon, single quote or double quote
	     characters or quoted characters of any kind. By quoting we
	     mean preceding a single character with a backslash or
	     enclosing a part of the string into single quotes '...' or
	     double quotes "...". Quoting characters are removed from the
	     string so they must be quoted themselves if they are a part of
	     the expression: \\, \' or " ' ", \" or ' " '.

	     Variable interpolation is performed on expressions. That means
	     that any substrings of the forms $id or ${id} where $ is
	     unquoted and id is an identifier are substituted with the
	     value of the variable named $id.

	     XPath interpolation is performed on expressions. That means
	     that any substring enclosed in between ${{ and }} is evaluated
	     in the same way as in the count command and the result of the
	     evaluation is substituted in its place.

END


$HELP{'enc-string'}=[<<'END'];
enc_string argument type

description:
	     An <expression> which interpolates to a valid encoding string,
	     e.g. to utf-8, utf-16, iso-8859-1, iso-8859-2, windows-1250
	     etc.

END


$HELP{'id'}=[<<'END'];
id argument type

description:
	     An identifier, that is, a string beginning with a letter or
	     underscore, and containing letters, underscores, and digits.

END


$HELP{'filename'}=[<<'END'];
Filename argument type

description:
	     An <expression> which interpolates to a valid file name.

END


$HELP{'xpath'}=[<<'END'];
Xpath argument type

description:
	     Any XPath expression as defined in W3C recommendation at
	     http://www.w3.org/TR/xpath optionally preceded with a document
	     identifier followed by colon. If no identifier is used, the
	     current document is used.

Example:     Open a document and count all sections containing a subsection
	     in it

             xsh> open v = mydocument.xml;
             xsh> count v://section[subsection];

END


$HELP{'if'}=[<<'END'];
usage:       if <xpath>|<perl-code> <command>
             if <xpath>|<perl-code>
	  <command-block> [ else <command-block> ]
             
description:
	     Execute <command-block> if the given <xpath> or <perl-code>
	     expression evaluates to a non-emtpty node-list, true
	     boolean-value, non-zero number or non-empty literal.

END


$HELP{'unless'}=[<<'END'];
usage:       unless <xpath>|<perl-code>
	  <command>
             unless <xpath>|<perl-code>
	  <command-block> [ else <command-block> ]
             
description:
	     Like if but negating the result of the expression.

END


$HELP{'while'}=[<<'END'];
usage:       while <xpath>|<perl-code> <command-block>
             
description:
	     Execute <command-block> as long as the given <xpath> or
	     <perl-code> expression evaluates to a non-emtpty node-list,
	     true boolean-value, non-zero number or non-empty literal.

Example:     The commands have the same results

             xsh> while /table/row remove /table/row[1];
             xsh> remove /table/row;

END


$HELP{'foreach'}=[<<'END'];
usage:       foreach <xpath>|<perl-code> 
	  <command>
	  <command-block>
             
aliases:     for

description:
	     If the first argument is an <xpath> expression, execute the
	     command-block for each node matching the expression making it
	     temporarily the current node, so that all relative XPath
	     expressions are evaluated in its context.

	     If the first argument is a <perl-code>, it is evaluated and
	     the resulting perl-list is iterated setting the variable $__
	     (note that there are two underscores!) to be each element of
	     the list in turn. It works much like perl's foreach, except
	     that the variable used consists of two underscores.

Example:     Move all employee elements in a company element into a staff
	     subelement of the same company

             xsh> foreach //company xmove ./employee into ./staff;

Example:     List content of all XML files in current directory

             xsh> foreach { glob('*.xml') } { open f=$__; list f:/; }

END

$HELP{'for'}=$HELP{'foreach'};

$HELP{'def'}=[<<'END'];
usage:       def <id> <command-block>
             
aliases:     define

description:
	     Define a new XSH routine named <id>. The <command-block> may
	     be later invoked using the `<call> <id>' command.

END

$HELP{'define'}=$HELP{'def'};

$HELP{'assign'}=[<<'END'];
usage:       assign $<id>=<xpath>
             $<id>=<xpath>
             assign %<id>=<xpath>
             %<id>=<xpath>
             
description:
	     In the first two cases (where dollar sign appears) store the
	     result of evaluation of the <xpath> in a variable named $<id>.
	     In this case, <xpath> is evaluated in a simmilar way as in the
	     case of the <count>: if it results in a literal value this
	     value is used. If it results in a node-list, number of nodes
	     occuring in that node-list is used. Use the `string()' XPath
	     function to obtain a literal values in these cases.

Example:     String expressions

             xsh> $a=string(chapter/title)
             xsh> $b="hallo world"

Example:     Arithmetic expressions

             xsh> $a=5*100
             xsh> $a
             $a=500
             xsh> $a=(($a+5) div 10)
             xsh> $a
             $a=50.5

Example:     Counting nodes

             xsh> $a=//chapter
             xsh> $a
             $a=10
             xsh> %chapters=//chapter
             xsh> $a=%chapters
             xsh> $a
             $a=10

Example:     Some caveats of counting node-lists

             xsh> ls ./creature
             <creature race='hobbit' name="Bilbo"/>

             ## WRONG (@name results in a singleton node-list) !!!
             xsh> $name=@name
             xsh> $name
             $a=1

             ## CORRECT (use string() function)
             xsh> $name=string(@name)
             xsh> $name
             $a=Biblo

	     In the other two cases (where percent sign appears) find all
	     nodes matching the given <xpath> and store the resulting
	     node-list in the variable named %<id>. The variable may be
	     later used instead of an XPath expression.

END


$HELP{'options'}=[<<'END'];
usage:       options
             
aliases:     flags

description:
	     List current values of all XSH flags and options (such as
	     validation flag or query-encoding).

Example:     Store current settings in your .xshrc

             xsh> options | cat > ~/.xshrc

END

$HELP{'flags'}=$HELP{'options'};

$HELP{'defs'}=[<<'END'];
usage:       defs
             
description:
	     List names of all defined XSH routines.

END


$HELP{'include'}=[<<'END'];
usage:       include <filename>
             
aliases:     .

description:
	     Include a file named <filename> and execute all XSH commands
	     therein.

END

$HELP{'.'}=$HELP{'include'};

$HELP{'call'}=[<<'END'];
usage:       call <id>
             
description:
	     Call an XSH subroutine named <id> previously created using
	     def.

END


$HELP{'help'}=[<<'END'];
usage:       help <command>|argument-type
             
aliases:     ?

description:
	     Print help on a given command or argument type.

END

$HELP{'?'}=$HELP{'help'};

$HELP{'exec'}=[<<'END'];
usage:       exec <expression> [<expression> ...]
             
aliases:     system

description:
	     execute the system command(s) in <expression>s.

Example:     Count words in "hallo wold" string, then print name of your
	     machine's operating system.

             exec echo hallo world;                 # prints hallo world
             exec "echo hallo word | wc"; # counts words in hallo world
             exec uname;                            # prints operating system name

END

$HELP{'system'}=$HELP{'exec'};

$HELP{'xslt'}=[<<'END'];
usage:       xslt <id> <filename> <id> [(params|parameters) name=<expression> [name=<expression> ...]]
             
aliases:     transform xsl xsltproc process

description:
	     Load an XSLT stylesheet from a file and use it to transform
	     the document of the first <id> into a new document named <id>.
	     Parameters may be passed to a stylesheet after params keyword
	     in the form of a list of name=value pairs where name is the
	     parameter name and value is an <expression> interpolating to
	     its value. The resulting value is interpretted by XSLT
	     processor as an XPath expression so e.g. quotes surrounding a
	     XPath string have to be quoted themselves to preveserve them
	     during the XSH expression interpolation.


             xslt src stylesheet.xsl rslt params font="'14pt'" color="'red'"

END

$HELP{'transform'}=$HELP{'xslt'};
$HELP{'xsl'}=$HELP{'xslt'};
$HELP{'xsltproc'}=$HELP{'xslt'};
$HELP{'process'}=$HELP{'xslt'};

$HELP{'files'}=[<<'END'];
usage:       files
             
description:
	     List open files and their identifiers.

END


$HELP{'variables'}=[<<'END'];
usage:       variables
             
aliases:     vars var

description:
	     List all defined variables and their values.

END

$HELP{'vars'}=$HELP{'variables'};
$HELP{'var'}=$HELP{'variables'};

$HELP{'copy'}=[<<'END'];
usage:       copy <xpath> <location> <xpath>
             
aliases:     cp

description:
	     Copies nodes matching the first <xpath> to the destinations
	     determined by the <location> directive relative to the second
	     <xpath>. If more than one node matches the first <xpath> than
	     it is copied to the position relative to the corresponding
	     node matched by the second <xpath> according to the order in
	     which are nodes matched. Thus, the n'th node matching the
	     first <xpath> is copied to the location relative to the n'th
	     node matching the second <xpath>. The possible values for
	     <location> are: after, before, into, replace and cause copying
	     the source nodes after, before, into (as the last child-node).
	     the destination nodes. If replace <location> is used, the
	     source node is copied before the destination node and the
	     destination node is removed.

	     Some kind of type conversion is used when the types of the
	     source and destination nodes are not equal. Thus, text, cdata,
	     comment or processing instruction node data prepend, append or
	     replace value of a destination attribute when copied
	     before,after/into or instead (replace) an attribute, and vice
	     versa.

	     Attributes may be copied after, before or into some other
	     attribute to append, prepend or replace the destination
	     attribute value. They may also replace the destination
	     attribute completely (both its name and value).

	     To simply copy an attribute from one element to another,
	     simply copy the attribute node into the destination element.

	     Elements may be copied into other elements (which results in
	     appending the child-list of the destination element), or
	     before, after or instead (replace) other nodes of any type
	     except attributes.

Example:     Replace living-thing elements in the document b with the
	     coresponding creature elements of the document a.

             xsh> copy a://creature replace b://living-thing

END

$HELP{'cp'}=$HELP{'copy'};

$HELP{'xcopy'}=[<<'END'];
usage:       xcopy <xpath> <location> <xpath>
             
aliases:     xcp

description:
	     xcopy is similar to copy, but copies *all* nodes matching the
	     first <xpath> to *all* destinations determined by the
	     <location> directive relative to the second <xpath>. See copy
	     for detailed description of xcopy arguments.

Example:     Copy all middle-earth creatures within the document a into
	     every world of the document b.

             xsh> xcopy a:/middle-earth/creature into b://world

END

$HELP{'xcp'}=$HELP{'xcopy'};

$HELP{'lcd'}=[<<'END'];
usage:       lcd <expression>
             
aliases:     chdir

description:
	     Changes the filesystem working directory to <expression>, if
	     possible. If <expression> is omitted, changes to the directory
	     specified in HOME environment variable, if set; if not,
	     changes to the directory specified by LOGDIR environment
	     variable.

END

$HELP{'chdir'}=$HELP{'lcd'};

$HELP{'insert'}=[<<'END'];
usage:       insert <node-type> <expression> [namespace <expression>] <location><xpath>
             
aliases:     add

description:
	     Works just like xadd, except that the new node is attached
	     only the first node matched.

END

$HELP{'add'}=$HELP{'insert'};

$HELP{'xinsert'}=[<<'END'];
usage:       xinsert <node-type> <expression> [namespace <expression>] <location><xpath>
             
aliases:     xadd

description:
	     Use the <expression> to create a new node of a given
	     <node-type> in the <location> relative to the given <xpath>.

	     For element nodes, the format of the <expression> should look
	     like "<element-name att-name='attvalue' ...>". The `<' and `>'
	     characters are optional. If no attributes are used, the
	     expression may simply consist the element name. Note, that in
	     the first case, the quotes are required since the expression
	     contains spaces.

	     Attribute nodes use the following syntax: "att-name='attvalue'
	     [...]".

	     For the other types of nodes (text, cdata, comments) the
	     expression should contain the node's literal content. Again,
	     it is necessary to quote all whitespace and special characters
	     as in any expression argument.

	     The <location> argument should be one of: `after', `before',
	     `into' and `replace'. You may use `into' location also to
	     attach an attribute to an element or to append some data to a
	     text, cdata or comment node. Note also, that `after' and
	     `before' locations may be used to append or prepend a string
	     to a value of an existing attribute. In that case, attribute
	     name is ignored.

	     The namespace <expression> is only valid for elements and
	     attributes and must evaluate to the namespace URI. In that
	     case, the element or attribute name must have a prefix. The
	     created node is associated with the given namespace.

Example:     Append a new Hobbit element to the list of middle-earth
	     creatures and name him Bilbo.

             xsh> xadd element "<creature race='hobbit' manner='good'> \
               into /middle-earth/creatures
             xsh> xadd attribute "name='Bilbo'" \
               into /middle-earth/creatures/creature[@race='hobbit'][last()]

END

$HELP{'xadd'}=$HELP{'xinsert'};

$HELP{'node-type'}=[<<'END'];
Node-type argument type

description:
	     One of: element, attribute, text, cdata, comment, chunk and
	     (EXPERIMENTALLY!) entity_reference. A chunk is a character
	     string which forms a well-balanced peace of XML.


             add element hobbit into //middle-earth/creatures;
             add attribute 'name="Bilbo"' into //middle-earth/creatures/hobbit[last()];
             add chunk '<hobbit name="Frodo">A small guy from <place>Shire</place>.</hobbit>' 
             into //middle-earth/creatures;

END


$HELP{'location'}=[<<'END'];
Location argument type

description:
	     One of: after, before, into/to/as child/as child of,
	     replace/instead/instead of.

END


$HELP{'move'}=[<<'END'];
usage:       move <xpath> <location> <xpath>
             
aliases:     mv

description:
	     Like copy, except that move removes the source nodes after a
	     succesfull copy. See copy for more detail.

END

$HELP{'mv'}=$HELP{'move'};

$HELP{'xmove'}=[<<'END'];
usage:       xmove <xpath> <location> <xpath>
             
aliases:     xmv

description:
	     Like xcopy, except that xmove removes the source nodes after a
	     succesfull copy. See copy for more detail.

END

$HELP{'xmv'}=$HELP{'xmove'};

$HELP{'clone'}=[<<'END'];
usage:       clone <id>=<id>
             
aliases:     dup

description:
	     Make a copy of the document identified by the <id> following
	     the equal sign assigning it the identifier of the first <id>.

END

$HELP{'dup'}=$HELP{'clone'};

$HELP{'ls'}=[<<'END'];
usage:       list <xpath> [<expression>]
             
aliases:     list

description:
	     List the XML representation of all nodes matching <xpath>. The
	     optional <expression> argument may be provided to specify the
	     depth of XML tree listing. If negative, the tree will be
	     listed to unlimited depth. If the <expression> results in the
	     word `fold', elements marked with the <fold> command are
	     folded, i.e. listed only to a certain depth (this feature is
	     still EXPERIMENTAL!).

	     Unless in quiet mode, this command prints also number of nodes
	     matched on stderr.

	     If the <xpath> parameter is omitted, current context node is
	     listed to the depth of 1.

END

$HELP{'list'}=$HELP{'ls'};

$HELP{'count'}=[<<'END'];
usage:       count <xpath>
             
aliases:     print_value get

description:
	     Calculate the given <xpath> expression. If the result is a
	     node-list, return number of nodes in the node-list. If the
	     <xpath> results in a boolean, numeric or literal value, return
	     the value.

END

$HELP{'print_value'}=$HELP{'count'};
$HELP{'get'}=$HELP{'count'};

$HELP{'perl-code'}=[<<'END'];
Perl-code argument type

description:
	     A block of perl code enclosed in curly brackets or an
	     expression which interpolates to a perl expression. Variables
	     defined in XSH are visible in perl code as well. Since, in the
	     interactive mode, XSH redirects output to the terminal, you
	     cannot simply use perl print function for output if you want
	     to filter the result with a shell command. Instead use
	     predefined perl routine `echo ...' which is equivalent to
	     `print $::OUT ...'. The $::OUT perl-variable stores the
	     referenc to the terminal file handle.


             xsh> $i="foo";
             xsh> eval { echo "$i-bar\n"; } # prints foo-bar
             xsh> eval 'echo "\$i-bar\n";'  # exactly the same as above
             xsh> eval 'echo "$i-bar\n";'   # prints foo-bar too, but $i is
             # interpolated by XSH. Perl actually evaluates echo "foo-bar\n";

END


$HELP{'perl'}=[<<'END'];
usage:       eval <perl-code>
             
aliases:     eval

description:
	     Evaluate the given perl expression and print the return value.

END

$HELP{'eval'}=$HELP{'perl'};

$HELP{'remove'}=[<<'END'];
usage:       remove <xpath>
             
aliases:     rm prune delete del

description:
	     Remove all nodes matching <xpath>.

Example:     Get rid of all evil creatures.

             xsh> del //creature[@manner='evil']

END

$HELP{'rm'}=$HELP{'remove'};
$HELP{'prune'}=$HELP{'remove'};
$HELP{'delete'}=$HELP{'remove'};
$HELP{'del'}=$HELP{'remove'};

$HELP{'print'}=[<<'END'];
usage:       print <expression> [<expression> ...]
             
aliases:     echo

description:
	     Interpolate and print given expression(s).

END

$HELP{'echo'}=$HELP{'print'};

$HELP{'sort'}=[<<'END'];
usage:       sort <command-block> <command-block> <perl-code> %<id>
             
description:
	     EXPERIMENTAL! This command is not yet guaranteed to remain in
	     the future releases.

	     This command may be used to sort the node-list stored in the
	     node-list variable <id>. On each comparizon, first the two
	     <command-block> are evaluated, each in a context of one of the
	     nodes to compare. These <command-block> are supposed to
	     prepair any variables needed for later order comparizon in the
	     <perl-code>. The nodes to be compared are available in %a and
	     %b node-lists. It is the <perl-code> that is responsible for
	     deciding which node comes first. Therefore it should return
	     either -1, 0, or 1.

Example:     Sort creatures by name

             xsh> %c=//creatures
             xsh> sort { $a=string(@name) }{ $b=string(@name) }{ $a cmp $b } %c
             xsh> ls %c/@name

END


$HELP{'map'}=[<<'END'];
usage:       map <perl-code> <xpath>
             
aliases:     sed

description:
	     Each of the nodes matching <xpath> is processed with the
	     <perl-code> in the following way: if the node is an element,
	     its name is processed, if it is an attribute, its value is
	     used, if it is a cdata section, text node, comment or
	     processing instruction, its data is used. The expression
	     should expect the data in the $_ variable and should use the
	     same variable to store the modified data.

Example:     Renames all hobbits to halflings

             xsh> map $_='halfling' //hobbit

Example:     Capitalises all hobbit names

             xsh> map { $_=ucfirst($_) } //hobbit/@name

Example:     Changes goblins to orcs in all hobbit tales.

             xsh> on s/goblin/orc/gi //hobbit/tale/text()

END

$HELP{'sed'}=$HELP{'map'};

$HELP{'close'}=[<<'END'];
usage:       close <id>
             
description:
	     Close the document identified by <id>, removing its parse-tree
	     from memory.

END


$HELP{'select'}=[<<'END'];
usage:       select <id>
             
description:
	     Make <id> the document identifier to be used in the next xpath
	     evaluation without identifier prefix.


             xsh> a=mydoc1.xml       # opens and selects a
             xsh> list /             # lists a
             xsh> b=mydoc2.xml       # opens and selects b
             xsh> list /             # lists b
             xsh> list a:/           # lists and selects a
             xsh> select b           # does nothing except selecting b
             xsh> list /             # lists b

END


$HELP{'open'}=[<<'END'];
usage:       [open] <id>=<filename>
             
description:
	     Open a new document assigning it a symbolic name of <id>. To
	     identify the document, use simply <id> in commands like close,
	     save, validate, dtd or enc. In commands which work on document
	     nodes, use <id>: prefix is XPath expressions to point the
	     XPath into the document.


             xsh> open x=mydoc.xml # open a document

             # quote file name if it contains whitespace
             xsh> open y="document with a long name with spaces.xml"

             # you may omit the word open (I'm clever enough to find out).
             xsh> z=mybook.xml

             # use z: prefix to identify the document opened with the
             # previous comand in an XPath expression.
             xsh> list z://chapter/title

END


$HELP{'open-HTML'}=[<<'END'];
usage:       open_HTML <id>=<filename>
             
aliases:     open_HTML

description:
	     Open a new HTML document assigning it a symbolic name of <id>.
	     To save it as HTML, use save_HTML command (use of just save or
	     saveas would change it to XHTML without changing the DOCTYPE
	     declaration).

END

$HELP{'open_HTML'}=$HELP{'open-HTML'};

$HELP{'open-PIPE'}=[<<'END'];
usage:       open_PIPE <id>=<expression>
             
aliases:     open_PIPE

description:
	     Run the system command resluting from interpoation of the
	     <expression> and parse its output as XML, associating the
	     resulting DOM tree with the given <id>.

END

$HELP{'open_PIPE'}=$HELP{'open-PIPE'};

$HELP{'create'}=[<<'END'];
usage:       create <id> <expression>
             
aliases:     new

description:
	     Create a new document using <expression> to form the root
	     element and associate it with the given identifier.


             xsh> create t1 root
             xsh> ls /
             <?xml version="1.0" encoding="utf-8"?>
             <root/>

             xsh> create t2 "<root id='r0'>Just a <b>test</b></root>"
             xsh> ls /
             <?xml version="1.0" encoding="utf-8"?>
             <root id='r0'>Just a <b>test</b></root>
             xsh> files
             scratch = new_document.xml
             t1 = new_document1.xml
             t2 = new_document2.xml

END

$HELP{'new'}=$HELP{'create'};

$HELP{'save'}=[<<'END'];
usage:       save <id> [encoding <enc-string>]
             
description:
	     Save the document identified by <id> to its original XML file,
	     optionally converting it from its original encoding to
	     <enc-string>.

END


$HELP{'save-HTML'}=[<<'END'];
usage:       save_HTML <id> <filename> [encoding <enc-string>]
             
aliases:     save_HTML

description:
	     Save the document identified by <id> as a HTML file named
	     <filename>, optionally converting it from its original
	     encoding to <enc-string> Note, that this does just the
	     character conversion, so you must specify the correct encoding
	     in the META tag yourself.

END

$HELP{'save_HTML'}=$HELP{'save-HTML'};

$HELP{'saveas'}=[<<'END'];
usage:       saveas <id> <filename> [encoding <enc-string>]
             
aliases:     save-as save_as

description:
	     Save the document identified by <id> as a XML file named
	     <filename>, optionally converting it from its original
	     encoding to <enc-string>.

END

$HELP{'save-as'}=$HELP{'saveas'};
$HELP{'save_as'}=$HELP{'saveas'};

$HELP{'save-xinclude'}=[<<'END'];
usage:       save_xinclude <id> [encoding <enc-string>]
             
aliases:     save_xinclude

description:
	     Save the document identified by <id> while saving all expanded
	     XInclude sections to the original files (optionally converting
	     it from its original encoding to <enc-string>). Once expanded,
	     sections included with XInclude mechanism cannot be normally
	     distinguished from other parts of the DOM tree by any XPath
	     expression or XSH command. Internally, however, they are
	     marked with special DOM nodes. This command uses these nodes
	     to find the sections and save them to their original documents
	     while restoring the <xi:include> tags in the root document.
	     More over, this command may be used to split the document to
	     new fragments included back by means of XInclude, since all
	     non-empty fragments containded within

	     elements are saved to separate files too, leaving only empty
	     xi:include element in the root file.

END

$HELP{'save_xinclude'}=$HELP{'save-xinclude'};

$HELP{'dtd'}=[<<'END'];
usage:       dtd [<id>]
             
description:
	     Print external or internal DTD for the given document. If no
	     document identifier is given, the current document is used.

END


$HELP{'enc'}=[<<'END'];
usage:       enc [<id>]
             
description:
	     Print the original document encoding string. If no document
	     identifier is given, the current document is used.

END


$HELP{'validate'}=[<<'END'];
usage:       validate [<id>]
             
description:
	     Try to validate the document identified with <id> according to
	     its DTD, report all validity errors. If no document identifier
	     is given, the current document is used.

END


$HELP{'valid'}=[<<'END'];
usage:       valid [<id>]
             
description:
	     Check and report the validity of a document. Prints "yes" if
	     the document is valid and "no" otherwise. If no document
	     identifier is given, the current document is used.

END


$HELP{'exit'}=[<<'END'];
usage:       exit [<expression>]
             
aliases:     quit

description:
	     Exit xsh immediately, optionally with the exit-code resulting
	     from the given expression.

	     WARNING: No files are saved on exit.

END

$HELP{'quit'}=$HELP{'exit'};

$HELP{'process-xinclude'}=[<<'END'];
usage:       process_xinclude [<id>]
             
aliases:     process_xinclude process-xincludes process_xincludes xinclude xincludes load_xincludes load-xincludes load_xinclude load-xinclude

description:
	     Process any xinclude tags in the document <id>.

END

$HELP{'process_xinclude'}=$HELP{'process-xinclude'};
$HELP{'process-xincludes'}=$HELP{'process-xinclude'};
$HELP{'process_xincludes'}=$HELP{'process-xinclude'};
$HELP{'xinclude'}=$HELP{'process-xinclude'};
$HELP{'xincludes'}=$HELP{'process-xinclude'};
$HELP{'load_xincludes'}=$HELP{'process-xinclude'};
$HELP{'load-xincludes'}=$HELP{'process-xinclude'};
$HELP{'load_xinclude'}=$HELP{'process-xinclude'};
$HELP{'load-xinclude'}=$HELP{'process-xinclude'};

$HELP{'cd'}=[<<'END'];
usage:       cd [<xpath>]
             
aliases:     chxpath

description:
	     Change current context node (and current document) to the
	     first node matching the given <xpath> argument.

END

$HELP{'chxpath'}=$HELP{'cd'};

$HELP{'pwd'}=[<<'END'];
usage:       pwd
             
description:
	     Print XPath leading to the current context node. This is
	     equivalent to `locate .'.

END


$HELP{'locate'}=[<<'END'];
usage:       locate <xpath>
             
description:
	     Print canonical XPaths leading to nodes matched by the <xpath>
	     given.

END


$HELP{'xupdate'}=[<<'END'];
usage:       xupdate <id> [<id>]
             
description:
	     Modify the current document or the document specified by the
	     second <id> argument according to XUpdate commands of the
	     first <id> document. XUpdate is a XML Update Language which
	     aims to be a language for updating XML documents.

	     XUpdate langauge is described in XUpdate Working Draft at
	     http://www.xmldb.org/xupdate/xupdate-wd.html.

	     XUpdate output can be generated for example by Python xmldiff
	     utility from http://www.logilab.org/xmldiff/. Unfortunatelly,
	     there are few bugs (or, as I tend to say In case of Python,
	     white-space problems) in their code, so its XUpdate output is
	     not always correct.

END


$HELP{'verbose'}=[<<'END'];
usage:       verbose
             
description:
	     Turn on verbose messages (default).

END


$HELP{'test-mode'}=[<<'END'];
usage:       test-mode
             
aliases:     test_mode

description:
	     Switch into test mode in which no commands are actually
	     executed and only command syntax is checked.

END

$HELP{'test_mode'}=$HELP{'test-mode'};

$HELP{'run-mode'}=[<<'END'];
usage:       run-mode
             
aliases:     run_mode

description:
	     Switch into normal XSH mode in which all commands are
	     executed.

END

$HELP{'run_mode'}=$HELP{'run-mode'};

$HELP{'debug'}=[<<'END'];
usage:       debug
             
description:
	     Turn on debugging messages.

END


$HELP{'nodebug'}=[<<'END'];
usage:       nodebug
             
description:
	     Turn off debugging messages.

END


$HELP{'version'}=[<<'END'];
usage:       version
             
description:
	     Prints program version as well as versions of
	     XML::XSH::Functions, XML::LibXML, and XML::LibXSLT modules
	     used.

END


$HELP{'validation'}=[<<'END'];
usage:       validation <expression>
             
description:
	     Turn on validation during the parse process if the
	     <expression> is non-zero or off otherwise. Defaults to on.

END


$HELP{'recovering'}=[<<'END'];
usage:       recovering <expression>
             
description:
	     Turn on recovering parser mode if the <expression> is non-zero
	     or off otherwise. Defaults to off. Note, that the in the
	     recovering mode, validation is not performed by the parser
	     even if the validation flag is on and that recovering mode
	     flag only influences parsing of XML documents (not HTML).

	     The recover mode helps to efficiently recover documents that
	     are almost well-formed. This for example includes documents
	     without a close tag for the document element (or any other
	     element inside the document).

END


$HELP{'parser-expands-entities'}=[<<'END'];
usage:       parser_expands_entities <expression>
             
aliases:     parser_expands_entities

description:
	     Turn on the entity expansion during the parse process if the
	     <expression> is non-zero on or off otherwise. If entity
	     expansion is off, any external parsed entities in the document
	     are left as entities. Defaults to on.

END

$HELP{'parser_expands_entities'}=$HELP{'parser-expands-entities'};

$HELP{'keep-blanks'}=[<<'END'];
usage:       keep_blanks <expression>
             
aliases:     keep_blanks

description:
	     Allows you to turn off XML::LibXML's default behaviour of
	     maintaining whitespace in the document. Non-zero expression
	     forces the XML parser to preserve all whitespace.

END

$HELP{'keep_blanks'}=$HELP{'keep-blanks'};

$HELP{'pedantic-parser'}=[<<'END'];
usage:       pedantic_parser <expression>
             
aliases:     pedantic_parser

description:
	     If you wish, you can make XML::LibXML more pedantic by passing
	     a non-zero <expression> to this command.

END

$HELP{'pedantic_parser'}=$HELP{'pedantic-parser'};

$HELP{'parser-completes-attributes'}=[<<'END'];
usage:       parser-completes-attributes <expression>
             
aliases:     complete_attributes complete-attributes parser_completes_attributes

description:
	     If the expression is non-zero, this command allows XML parser
	     to complete the elements attributes lists with the ones
	     defaulted from the DTDs. By default, this option is enabled.

END

$HELP{'complete_attributes'}=$HELP{'parser-completes-attributes'};
$HELP{'complete-attributes'}=$HELP{'parser-completes-attributes'};
$HELP{'parser_completes_attributes'}=$HELP{'parser-completes-attributes'};

$HELP{'indent'}=[<<'END'];
usage:       indent <expression>
             
description:
	     If the <expression> is non-zero, format the XML output while
	     saving a document by adding some nice ignorable whitespace.

END


$HELP{'parser-expands-xinclude'}=[<<'END'];
usage:       parser_expands_xinclude <expression>
             
aliases:     parser_expands_xinclude

description:
	     If the <expression> is non-zero, the parser is allowed to
	     expand XIinclude tags imidiatly while parsing the document.

END

$HELP{'parser_expands_xinclude'}=$HELP{'parser-expands-xinclude'};

$HELP{'load-ext-dtd'}=[<<'END'];
usage:       load_ext_dtd <expression>
             
aliases:     load_ext_dtd

description:
	     If the expression is non-zero, XML parser loads external DTD
	     subsets while parsing. By default, this option is enabled.

END

$HELP{'load_ext_dtd'}=$HELP{'load-ext-dtd'};

$HELP{'encoding'}=[<<'END'];
usage:       encoding <enc-string>
             
description:
	     Set the default output character encoding.

END


$HELP{'query-encoding'}=[<<'END'];
usage:       query-encoding <enc-string>
             
aliases:     query_encoding

description:
	     Set the default query character encoding.

END

$HELP{'query_encoding'}=$HELP{'query-encoding'};

$HELP{'quiet'}=[<<'END'];
usage:       quiet
             
description:
	     Turn off verbose messages.

END


$HELP{'backups'}=[<<'END'];
usage:       backups
             
description:
	     Enable creating backup files on save (default).

END


$HELP{'nobackups'}=[<<'END'];
usage:       nobackups
             
description:
	     Disable creating backup files on save.

END


$HELP{'fold'}=[<<'END'];
usage:       fold <xpath> [<expression>]
             
description:
	     This feature is still EXPERIMENTAL! Fold command may be used
	     to mark elements matching the <xpath> with a `xsh:fold'
	     attribute from the `http://xsh.sourceforge.net/xsh/'
	     namespace. When listing the DOM tree using `<ls> <xpath>
	     fold', elements marked in this way are folded to the depth
	     given by the <expression> (default depth is 0 = fold
	     immediately).


             xsh> fold //chapter 1
             xsh> ls //chapter[1] fold
             <chapter id="intro" xsh:fold="1">
             <title>...</title>
             <para>...</para>
             <para>...</para>
             </chapter>

END


$HELP{'unfold'}=[<<'END'];
usage:       unfold <xpath>
             
description:
	     This feature is still EXPERIMENTAL! Unfold command removes
	     `xsh:fold' attributes from all elements matching given <xpath>
	     created by previous usage of <fold>. Be aware, that
	     `xmlns:xsh' namespace declaration may still be present in the
	     document even when all elements are unfolded.

END



1;
__END__

