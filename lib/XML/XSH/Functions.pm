# $Id: Functions.pm,v 1.4 2002/03/14 17:39:10 pajas Exp $

package XML::XSH::Functions;

use strict;
no warnings;

use XML::LibXML;
use Text::Iconv;
use XML::XSH::Help;

use Exporter;
use vars qw/@ISA @EXPORT_OK %EXPORT_TAGS $VERSION $OUT $LOCAL_ID $LOCAL_NODE
            $_xsh $_parser $_encoding $_qencoding %_nodelist
            $_quiet $_debug $_test $_newdoc $_indent $SIGSEGV_SAFE
            %_doc %_files %_iconv %_defs/;

BEGIN {
  $VERSION='1.1';
  @ISA=qw(Exporter);
  @EXPORT_OK=qw(&xsh_init &xsh
                &xsh_set_output &xsh_set_parser
                &set_opt_q &set_opt_d &set_opt_c
		&create_doc &open_doc &set_doc
		&xsh_pwd &xsh_local_id
	       );
  %EXPORT_TAGS = (default => [@EXPORT_OK]);

  $SIGSEGV_SAFE=0;
  $_indent=1;
  $_encoding='iso-8859-2';
  $_qencoding='iso-8859-2';
  $_newdoc=1;
  %_nodelist=();
}

# initialize XSH and XML parsers
sub xsh_init {
  shift unless ref($_[0]);
  if (ref($_[0])) {
    $OUT=$_[0];
  } else {
    $OUT=\*STDOUT;
  }
  $_parser = XML::LibXML->new();
  $_parser->load_ext_dtd(1);
  $_parser->validation(1);

  if (eval { require XML::XSH::Parser; }) {
    $_xsh=XML::XSH::Parser->new();
  } else {
    print STDERR "Parsing raw grammar...\n";
    require XML::XSH::Grammar;
    $_xsh=XML::XSH::Grammar->new();
    print STDERR "... done.\n";
    unless ($_quiet) {
      print STDERR << 'EOF';
NOTE: To avoid this, you should regenerate the XML::XSH::Parser.pm
      module from XML::XSH::Grammar.pm module by changing to XML/XSH/
      directory in your load-path and running the following command:

         perl -MGrammar -e XML::XSH::Grammar::compile

EOF
    }
  }
  return $_xsh;
}

sub set_validation	     { $_parser->validation($_[0]); return 1; }
sub set_expand_entities	     { $_parser->expand_entities($_[0]); 1; }
sub set_keep_blanks	     { $_parser->keep_blanks($_[0]); 1; }
sub set_pedantic_parser	     { $_parser->pedantic_parser($_[0]); 1; }
sub set_load_ext_dtd	     { $_parser->load_ext_dtd($_[0]); 1; }
sub set_complete_attributes  { $_parser->complete_attributes($_[0]); 1; }
sub set_expand_xinclude	     { $_parser->expand_xinclude($_[0]); 1; }
sub set_indent		     { $_indent=$_[0]; 1; }

# evaluate a XSH command
sub xsh {
  if (ref($_xsh)) {
    return $_xsh->startrule($_[0]);
  } else {
    return 0;
  }
}

# setup output stream
sub xsh_set_output {
  $OUT=$_[0];
  return 1;
}

# store a pointer to an XSH-Grammar parser
sub xsh_set_parser {
  $_xsh=$_[0];
  return 1;
}

# print version info
sub print_version {
  print $OUT "Main program:        $::VERSION $::REVISION\n";
  print $OUT "XML::XSH::Functions: $VERSION\n";
  print $OUT "XML::LibXML          $XML::LibXML::VERSION\n";
  print $OUT "XML::LibXSLT         $XML::LibXSLT::VERSION\n"
    if defined($XML::LibXSLT::VERSION);
  return 1;
}

# print a list of all open files
sub files {
  print $OUT map { "$_ = $_files{$_}\n" } sort keys %_files;
  return 1;
}

# print a list of XSH variables and their values
sub variables {
  no strict;
  foreach (keys %{"XML::XSH::Map::"}) {
    print $OUT "\$$_=",${"XML::XSH::Map::$_"},"\n" if defined(${"XML::XSH::Map::$_"});
  }
  return 1;
}

# print value of an XSH variable
sub print_var {
  no strict;
  if ($_[0]=~/^\$?(.*)/) {
    print $OUT "\$$1=",${"XML::XSH::Map::$1"},"\n" if defined(${"XML::XSH::Map::$1"});
    return 1;
  }
  return 0;
}

sub echo { print $OUT (join " ",expand(@_)),"\n"; return 1; }
sub set_opt_q { $_quiet=$_[0]; return 1; }
sub set_opt_d { $_debug=$_[0]; return 1; }
sub set_opt_c { $_test=$_[0]; return 1; }
sub set_encoding { $_encoding=expand($_[0]); return 1; }
sub set_qencoding { $_qencoding=expand($_[0]); return 1; }

sub sigint {
  print $OUT "\nCtrl-C pressed. \n";
  die "Interrupted by user.";
};


# prepair and return conversion object
sub mkconv {
  my ($from,$to)=@_;
  $from="utf-8" unless $from ne "";
  $to="utf-8" unless $to ne "";
  if ($_iconv{"$from->$to"}) {
    return $_iconv{"$from->$to"};
  } else {
    my $conv;
    eval { $conv= Text::Iconv->new($from,$to); }; print STDERR "@_\n" if ($@);
    if ($conv) {
      $_iconv{"$from->$to"}=$conv;
      return $conv;
    } else {
      print "Sorry, Iconv cannot convert from $from to $to\n";
      return undef;
    }
  }
}

# if the argument is non-void then print it and return 0; return 1 otherwise
sub _check_err {
  if ($_[0]) {
    print STDERR "$_[0]\n";
    return 0;
  } else {
    return 1;
  }
}

# return current document id
sub xsh_local_id {
  return $LOCAL_ID;
}


# return current node for given document or document root if
# current node is not from the given document
sub get_local_node {
  my ($id)=@_;
  if ($SIGSEGV_SAFE) {
    # do not allow xpath searches directly from document node
    if ($LOCAL_NODE and $id eq $LOCAL_ID) {
      if ($LOCAL_NODE->nodeType == XML_DOCUMENT_NODE) {
	return $LOCAL_NODE->getDocumentElement();
      } else {
	return $LOCAL_NODE;
      }
    } else {
      $id=$LOCAL_ID if ($id eq "");
      return $_doc{$id} ? $_doc{$id}->getDocumentElement() : undef;
    }
  } else {
    if ($LOCAL_NODE and $id eq $LOCAL_ID) {
      return $LOCAL_NODE;
    } else {
      $id=$LOCAL_ID if ($id eq "");
      return $_doc{$id} ? $_doc{$id} : undef;
    }
  }
}

# return current document's id (and optionally the doc itself) if id is void
sub _id {
  my ($id)=@_;
  if ($id eq "") {
    $id=$LOCAL_ID;
    print STDERR "using last id $id\n" if $_debug;
  }
  return wantarray ? ($id,$_doc{$id}) : $id;
}

# extract document id, xpath query string and document pointer from XPath type
sub _xpath {
  my ($id,$query)=expand(@{$_[0]});
  ($id,my $doc)=_id($id);
  return ($id,$query,$doc);
}

# make given document and node current (no checking!)
sub set_local_node {
  my ($id,$node)=@_;
  $LOCAL_ID=$id;
  $LOCAL_NODE=$node;
}

# set current node to given XPath
sub set_local_xpath {
  my ($xp)=@_;
  my ($id,$query,$doc)=_xpath($xp);
  if ($query eq "") {
    set_local_node($id,$_doc{$id});
    return 1;
  }
  return 0 unless ref($doc);
  my ($newlocal);
  eval {
    local $SIG{INT}=\&sigint;
    $newlocal=find_nodes($xp)->[0];
  };
  unless ($@) {
    if (ref($newlocal)) {
      set_local_node($id,$newlocal);
    }
  }
  return _check_err($@);
}

# return XPath identifying a node within its parent's subtree
sub node_address {
  my ($node)=@_;
  my $name;
  if ($node->nodeType == XML_ELEMENT_NODE) {
    $name=$node->nodeName();
  } elsif ($node->nodeType == XML_TEXT_NODE or
	   $node->nodeType == XML_CDATA_SECTION_NODE) {
    $name="text()";
  } elsif ($node->nodeType == XML_COMMENT_NODE) {
    $name="comment()";
  } elsif ($node->nodeType == XML_PI_NODE) {
    $name="processing-instruction()";
  } elsif ($node->nodeType == XML_ATTRIBUTE_NODE) {
    return "@".$node->nodeName();
  }
  if ($node->parentNode) {
    my @children=$node->parentNode->findnodes("./$name");
    if (@children == 1 and $node->isEqual($children[0])) {
      return "$name";
    }
    for (my $pos=0;$pos<@children;$pos++) {
      return "$name"."[".($pos+1)."]"
	if ($node->isEqual($children[$pos]));
    }
    return undef;
  } else {
    return ();
  }
}

# parent element (even for attributes)
sub tree_parent_node {
  my $node=$_[0];
  if ($node->nodeType==XML_ATTRIBUTE_NODE) {
    return $node->getOwnerElement();
  } else {
    return $node->parentNode();
  }
}

# return canonical xpath for the given or current node
sub pwd {
  my $node=$_[0] || $LOCAL_NODE || $_doc{$LOCAL_ID};
  return undef unless ref($node);
  my @pwd=();
  do {
    unshift @pwd,node_address($node);
    $node=tree_parent_node($node);
  } while ($node);
  my $pwd="/".join "/",@pwd;
  return $pwd;
}

# return canonical xpath for current node (encoded)
sub xsh_pwd {
  my $pwd;
  my ($id, $doc)=_id();
  return undef unless $doc;
  eval {
    local $SIG{INT}=\&sigint;
    $pwd=pwd();
    my $conv=mkconv($doc->getEncoding,$_encoding);
    if ($conv) {
      $pwd=$conv->convert($pwd);
    }
  };
  if ($@) {
    _check_err($@);
    return undef;
  }
  return $pwd;
}

# print current node's xpath
sub print_pwd {
  my $pwd=xsh_pwd();
  if ($pwd) {
    print $OUT "$pwd\n\n";
    return $pwd;
  } else {
    return 0;
  }
}

# evaluate variable and xpath expresions given string
sub _expand {
  my $l=$_[0];
  my $k;
  no strict;
  $l=~/^/o;
  while ($l !~ /\G$/gsco) {
    if ($l=~/\G\\(.)/gsco or $l=~/\G([^\\\$]+)/gsco) {
      $k.=$1;
    } elsif ($l=~/\G\$\{([a-zA-Z_-][a-zA-Z0-9_-]*)\}/gsco
	     or $l=~/\G\$([a-zA-Z_-][a-zA-Z0-9_-]*)/gsco) {
      $k.=${"XML::XSH::Map::$1"};
    } elsif ($l=~/\G\$\{\{([a-zA-Z_][a-zA-Z0-9_]*):(\\.|[^}]*|\}[^}]*)\}\}/gsco) {
      $k.=count([$1,$2]);
    } elsif ($l=~/\G\$\{\{((?:\\.|[^}]*|\}[^}])*)\}\}/gsco) {
      $k.=count([undef,$1]);
    } elsif ($l=~/\G(.|\n)/gsco) {
      $k.=$1;
    }
  }
  return $k;
}

# expand one or all parameters (according to return context)
sub expand {
  return wantarray ? (map { _expand($_) } @_) : _expand($_[0]);
}

# assign a value to a variable
sub _assign {
  my ($name,$value)=@_;
  no strict 'refs';
  $name=~/^\$(.+)/;
  ${"XML::XSH::Map::$1"}=$value;
  print STDERR "\$$1=",${"XML::XSH::Map::$1"},"\n" unless "$_quiet";
  return 1;
}

# evaluate xpath and assign thre result to a variable
sub xpath_assign {
  my ($name,$xp)=@_;
  _assign($name,count($xp));
  return 1;
}

# findnodes wrapper which handles both xpaths and nodelist variables
sub _find_nodes {
  my ($context,$query)=@_;
  if ($query=~/^\%([a-zA-Z_][a-zA-Z0-9_]*)(.*)$/) {
    $query=$2;
    my $name=$1;
    return [] unless exists($_nodelist{$name});
    if ($query ne "") {
      if ($query =~m|^\s*\[(\d+)\](.*)$|) {
	return $_nodelist{$name}->[1]->[$1] ?
	  [ $_nodelist{$name}->[1]->[$1]->findnodes('./self::*'.$2) ] : [];
      } elsif ($query =~m|^\s*\[|) {
	return [ map { ($_->findnodes('./self::*'.$query)) }
		 @{$_nodelist{$name}->[1]}
	       ];
      }
      return [ map { ($_->findnodes('.'.$query)) }
	       @{$_nodelist{$name}->[1]}
	     ];
    } else {
      return $_nodelist{$name}->[1];
    }
  } else {
    return [$context->findnodes($query)];
  }
}

# _find_nodes wrapper with q-decoding
sub find_nodes {
  my ($id,$query,$doc)=_xpath($_[0]);
  if ($id eq "" or $query eq "") { $query="."; }
  return undef unless ref($doc);
  my $qconv=mkconv($_qencoding,"utf-8");
  return _find_nodes(get_local_node($id),$qconv ? $qconv->convert($query) : $query);
}

# assign a result of xpath search to a nodelist variable
sub nodelist_assign {
  my ($name,$xp)=@_;
  my ($id,$query,$doc)=_xpath($xp);
  $_nodelist{$name}=[$doc,find_nodes($xp)];
  print STDERR "\nStored ",scalar(@{$_nodelist{$name}->[1]})," nodes.\n" unless "$_quiet";
}

# remove given node and all its descendants from all nodelists
sub remove_node_from_nodelists {
  my ($node,$doc)=@_;
  foreach my $list (values(%_nodelist)) {
    if ($doc->isEqual($list->[0])) {
      $list->[1]=[ grep { !is_ancestor_or_self($node,$_) } @{$list->[1]} ];
    }
  }
}

# create new document
sub create_doc {
  my ($id,$root_element)=expand @_;
  $id=_id($id);
  my $doc;
  $root_element="<$root_element/>" unless ($root_element=~/^\s*</);
  $root_element=mkconv($_encoding,'utf-8')->convert($root_element);
  my $xmldecl;
  $xmldecl="<?xml version='1.0' encoding='utf-8'?>" unless $root_element=~/^\s*\<\?xml /;
  eval {
    local $SIG{INT}=\&sigint;
    $doc=$_parser->parse_string($xmldecl.$root_element);
    set_doc($id,$doc,"new_document$_newdoc.xml");
    $_newdoc++;
  };
  if (_check_err($@)) {
    set_local_node($id,$doc);
    return $doc;
  } else {
    return undef;
  }
}

# bind a document with a given id and filename
sub set_doc {
  my ($id,$doc,$file)=@_;
  $_doc{$id}=$doc;
  $_files{$id}=$file;
  return $doc;
}

# create a new document by parsing a file
sub open_doc {
  my ($id,$file)=@_;
  print STDERR "open [$file] as [$id]\n" if "$_debug";
  $file=expand $file;
  $id=_id($id);
  print STDERR "open [$file] as [$id]\n" if "$_debug";
  if ($id eq "" or $file eq "") {
    print STDERR "hint: open identifier=file-name\n" unless "$_quiet";
    return;
  }
  if ((-f $file) || (-f ($file="$file.gz"))) {
    print STDERR "parsing $file\n" unless "$_quiet";
    eval {
      local $SIG{INT}=\&sigint;
      my $doc=$_parser->parse_file($file);
      print STDERR "done.\n" unless "$_quiet";
      set_doc($id,$doc,$file);
      set_local_node($id,$doc);
    };
    return _check_err($@);
  } else {
    print STDERR "file not exists: $file\n";
    return 0;
  }
}

# close a document and destroy all nodelists that belong to it
sub close_doc {
  my ($id)=expand(@_);
  $id=_id($id);
  print $OUT "closing file $_files{$id}\n" unless "$_quiet";
  delete $_files{$id};
  foreach (values %_nodelist) {
    if ($_->[0]==$_doc{$id}) {
      delete $_nodelist{$_};
    }
  }
  delete $_doc{$id};
  if (xsh_local_id() eq $id) {
    if ($_doc{'scratch'}) {
      set_local_xpath(['scratch','/']);
    } else {
      set_local_node(undef,undef);
    }
  }
  return 1;
}

# close a document and destroy all nodelists that belong to it
sub save_as {
  my ($id,$file,$enc)= expand(@_);
  ($id,my $doc)=_id($id);
  return unless ref($doc);
  $file=$_files{$id} if $file eq "";
  print STDERR "$id=$_files{$id} --> $file ($enc)\n" unless "$_quiet";
  $enc=$doc->getEncoding() unless ($enc ne "");
  local *F;
  $file=~/^\s*[|>]/ ? open(F,$file) : open(F,">$file");
  eval {
    local $SIG{INT}=\&sigint;
    my $conv=mkconv($doc->getEncoding(),$enc);
    my $t;
    if ($conv) {
      $t=$conv->convert($doc->toString($_indent));
      $t=~s/(\<\?xml(?:\s+[^<]*)\s+)encoding=(["'])[^'"]+/$1encoding=$2${enc}/;
    } else {
      $t=$doc->toString($_indent);
    }
    print F $t;
    close F;
    $_files{$id}=$file unless $file=~/^\s*[|>]/; # no change in case of pipe
  };
  print STDERR "saved $id=$_files{$id} as $file in $enc encoding\n" unless ($@ or "$_quiet");
  return _check_err($@);
}

# create start tag for an element
sub start_tag {
  my ($element)=@_;
  return "<".$element->nodeName().
    join("",map { " ".$_->nodeName()."=".$_->getValue() } 
	 $element->attributes)
    .($element->hasChildNodes() ? ">" : "/>");
}

# create close tag for an element
sub end_tag {
  my ($element)=@_;
  return $element->hasChildNodes() ? "</".$element->nodeName().">" : "";
}

# convert a subtree to an XML string to the given depth
sub to_string {
  my ($node,$depth)=@_;
  if ($node) {
    if ($depth<0) {
      return ref($node) ? $node->toString() : $node;
    } elsif ($depth>0) {
      if (!ref($node)) {
	return $node;
      } elsif ($node->nodeType == XML_ELEMENT_NODE) {
	my $out=start_tag($node);
	my $out= start_tag($node).
	  join("",map { to_string($_,$depth-1) } $node->childNodes).
	    end_tag($node);
	return $out;
      } elsif ($node->nodeType == XML_DOCUMENT_NODE) {
	return 
	  '<?xml version="'.$node->getVersion().
	  '" encoding="'.$node->getEncoding().'"?>'."\n".
	  join("\n",map { to_string($_,$depth-1) } $node->childNodes);
      } {
	return $node->toString();
      }
    } else {
      if (ref($node) and $node->nodeType == XML_ELEMENT_NODE) {
	return start_tag($node).
	  ($node->hasChildNodes() ? "...".end_tag($node) : "");
      } else {
	return ref($node) ? $node->toString() : $node;
      }
    }
  }
}

# list nodes matching given XPath argument to a given depth
sub list {
  my ($xp,$depth)=@_;
  my ($id,$query,$doc)=_xpath($xp);

  print STDERR "listing $query from $id=$_files{$id}\n\n" if "$_debug";
  return 0 unless ref($doc);
  eval {
    local $SIG{INT}=\&sigint;
    my $ql=find_nodes($xp);
    my $conv=mkconv($doc->getEncoding,$_encoding);
    if ($conv) {
      foreach (@$ql) { my $out=to_string($_,$depth);
		       print $OUT $conv->convert($out),"\n"; 
		     }
    } else {
      foreach (@$ql) { print $OUT to_string($_,$depth),"\n"; }
    }
    print STDERR "\nFound ",scalar(@$ql)," node(s).\n" unless "$_quiet";
  };
  return _check_err($@);
}

# print canonical xpaths identifying nodes matching given XPath
sub locate {
  my ($xp)=@_;
  my ($id,$query,$doc)=_xpath($xp);

  print STDERR "locating $query from $id=$_files{$id}\n\n" if "$_debug";
  return 0 unless ref($doc);
  eval {
    local $SIG{INT}=\&sigint;
    my $ql=find_nodes($xp);
    my $conv=mkconv($doc->getEncoding,$_encoding);
    if ($conv) {
      foreach (@$ql) { print $OUT $conv->convert(pwd($_)),"\n"; }
    } else {
      foreach (@$ql) { print $OUT pwd($_),"\n"; }
    }
    print STDERR "\nFound ",scalar(@$ql)," node(s).\n" unless "$_quiet";
  };
  return _check_err($@);
}

# evaluate given xpath and output the result
sub count {
  my ($xp)=@_;
  my ($id,$query,$doc)= _xpath($xp);

  return if ($id eq "" or $query eq "");
  unless (ref($doc)) {
    print STDERR "No such document: $id\n";
    return undef;
  }
  print STDERR "Query $query on $id=$_files{$id}\n" if $_debug;
  my $result=undef;
  eval {
    local $SIG{INT}=\&sigint;
    if ($query=~/^%/) {
      $result=find_nodes($xp);
      $result=XML::LibXML::Number->new(scalar(@$result));
    } else {
      my $qconv=mkconv($_qencoding,"utf-8");
      $result=get_local_node($id)->find($qconv ? $qconv->convert($query) : $query);
    }
  };
  if ($@) {
    print STDERR "$@\n";
    return undef;
  }
  if (ref($result)) {
    if ($result->isa('XML::LibXML::NodeList')) {
      return $result->size();
    } elsif ($result->isa('XML::LibXML::Literal')) {
      my $conv=mkconv($doc->getEncoding(),$_encoding);
      return $conv ? $conv->convert($result->value()) : $result->value();
    } elsif ($result->isa('XML::LibXML::Number') or
	     $result->isa('XML::LibXML::Boolean')) {
      return $result->value();
    }
  }
  return undef;
}

# remove nodes matching given XPath from a document and
# remove all their descendants from all nodelists
sub prune {
  my ($xp)=@_;
  my ($id,$query,$doc)=_xpath($xp);
  return unless ref($doc);
  my $i=0;
  eval {
    local $SIG{INT}=\&sigint;
    my $ql=find_nodes($xp);
    foreach my $node (@$ql) {
      remove_node($node);
      $i++;
    }
    print STDERR "$i node(s) removed from $id=$_files{$id}\n" unless "$_quiet";
  };
  return _check_err($@);
}

# evaluate given perl expression
sub eval_substitution {
  my ($expr,$inenc,$outenc);
  ($_,$expr,$inenc,$outenc)=@_;

  $_=$inenc ? $inenc->convert($_) : $_;

  eval "package XML::XSH::Map; no strict 'vars'; $expr";

  if ($@) {
    print STDERR "$@\n";
    return "";
  }
  $_=$outenc ? $outenc->convert($_) : $_;
  return $_;
}

# Evaluate given perl expression over every element matching given XPath.
# The element is passed to the expression by its name or value in the $_
# variable.
sub perlmap {
  my ($q, $expr)=@_;
  my ($id,$query,$doc)=_xpath($q);

  print STDERR "Executing $expr on $query in $id=$_files{$id}\n" unless "$_quiet";
  unless ($doc) {
    print STDERR "No such document $id\n";
    return;
  }
  eval {
    local $SIG{INT}=\&sigint;

    my $sdoc=get_local_node($id);
    my $qconv=mkconv($_qencoding,"utf-8");
    my $inconv=mkconv($doc->getEncoding(),$_qencoding);
    my $outconv=mkconv($_qencoding,$doc->getEncoding());

    $expr=$qconv ? $qconv->convert($expr) : $expr;
    my $ql=_find_nodes($sdoc,$qconv ? $qconv->convert($query) : $query);
    foreach my $node (@$ql) {
      if ($node->nodeType eq XML_ATTRIBUTE_NODE) {
	my $val=$node->getValue();
	$node->setValue(eval_substitution($val,$expr,$inconv,$outconv));
      } elsif ($node->nodeType eq XML_ELEMENT_NODE) {
	my $val=$node->getName();
	$node->setName(eval_substitution($val,$expr,$inconv,$outconv));
      } elsif ($node->can('setData') and $node->can('getData')) {
	my $val=$node->getData();
	$node->setData(eval_substitution($val,$expr,$inconv,$outconv));
      }
    }
  };
  return _check_err($@);
}

# insert given node to given destination performing
# node-type conversion if necessary
sub insert_node {
  my ($node,$dest,$dest_doc,$where,$ns)=@_;
  if ($node->nodeType == XML_TEXT_NODE           ||
      $node->nodeType == XML_CDATA_SECTION_NODE  ||
      $node->nodeType == XML_COMMENT_NODE        ||
      $node->nodeType == XML_PI_NODE             ||
      $node->nodeType == XML_ENTITY_NODE
      and $dest->nodeType == XML_ATTRIBUTE_NODE) {
    my $val=$node->getData();
    $val=~s/^\s+|\s+$//g;
    $dest->getParentNode()->setAttributeNS("$ns",$dest->getName(),$val);
  } elsif ($node->nodeType == XML_ATTRIBUTE_NODE) {
    if ($dest->nodeType == XML_ATTRIBUTE_NODE) {
      my ($name,$value);
      if ($where eq 'replace') {
	$dest->getParentNode()->setAttributeNS("$ns",$node->getName(),$node->getValue());
	remove_node($dest);
      } elsif ($where eq 'after') {
	$dest->getParentNode()->setAttributeNS("$ns",$dest->getName(),$dest->getValue().$node->getValue());
      } elsif ($where eq "as_child") {
	$dest->getParentNode()->setAttributeNS("$ns",$dest->getName(),$node->getValue());
      } else { #before
	$dest->getParentNode()->setAttributeNS("$ns",$dest->getName(),$node->getValue().$dest->getValue());
      }
    } elsif ($dest->nodeType == XML_ELEMENT_NODE) {
      $dest->setAttributeNS("$ns",$node->getName(),$node->getValue());
    } elsif ($dest->nodeType == XML_TEXT_NODE          ||
	     $dest->nodeType == XML_CDATA_SECTION_NODE ||
	     $dest->nodeType == XML_COMMENT_NODE       ||
	     $dest->nodeType == XML_PI_NODE) {
      if ($where eq 'replace') {
	$dest->setData($node->getValue());
      } elsif ($where eq 'after' or $where eq 'as_child') {
	$dest->setData($dest->getData().$node->getValue());
      } else {
	$dest->setData($node->getValue().$dest->getData());
      }
    }
  } else {
    my $copy=$node->cloneNode(1);
    $copy->setOwnerDocument($dest_doc);
    if ($where eq 'after') {
      $dest->parentNode()->insertAfter($copy,$dest);
    } elsif ($where eq 'as_child') {
      $dest->appendChild($copy);
    } elsif ($where eq 'replace') {
      $dest->parentNode()->insertAfter($copy,$dest);
      remove_node($dest);
    } else {
      $dest->parentNode()->insertBefore($copy,$dest);
    }
  }
  return 1;
}

# copy nodes matching one XPath expression to locations determined by
# other XPath expression
sub copy {
  my ($fxp,$txp,$where,$all_to_all)=@_;
  my ($fid,$fq,$fdoc)=_xpath($fxp); # from xpath
  my ($tid,$tq,$tdoc)=_xpath($txp); # to xpath

  return unless (ref($fdoc) and ref($tdoc));
  my ($fl,$tl);
  eval {
    local $SIG{INT}=\&sigint;
    $fl=find_nodes($fxp);
    $tl=find_nodes($txp);
  };
  return _check_err($@) if ($@);
  unless (@$tl) {
    print STDERR "No matching nodes found for $tq in $tid=$_files{$tid}\n" unless "$_quiet";
    return 0;
  }
  eval {
    local $SIG{INT}=\&sigint;
    my $ns;
    if ($all_to_all) {
      my $to=($where eq 'replace' ? 'after' : $where);
      foreach my $tp (@$tl) {
	foreach my $fp (@$fl) {
	  $ns=$fp->getNamespaceURI();
	  insert_node($fp,$tp,$tdoc,$to,$ns);
	}
	remove_node($tp) if $where eq 'replace';
      }
    } else {
      while (ref(my $fp=shift @$fl) and ref(my $tp=shift @$tl)) {
	$ns=$fp->getNamespaceURI();
	insert_node($fp,$tp,$tdoc,$where,$ns);
      }
    }
  };
  return _check_err($@);
}

# parse a string and create attribute nodes
sub create_attributes {
  my ($exp)=@_;
  my (@ret,$value,$name);
  while ($exp!~/\G$/gsco) {
    if ($exp=~/\G\s*([^\s=]+)=/gsco) {
      my $name=$1;
      print STDERR "attribute_name=$1\n" if $_debug;
      if ($exp=~/\G"((?:[^\\"]|\\.)*)"/gsco or
	  $exp=~/\G'((?:[^\\']|\\.)*)'/gsco or
	  $exp=~/\G(\S+)/gsco) {
	$value=$1;
	$value=~s/\\(.)/$1/g;
	print STDERR "creating $name=$value attribute\n" if $_debug;
	push @ret,[$name,$value];
      } else {
	$exp=~/\G(\S*\s*)/gsco;
	print STDERR "ignoring $name=$1\n";
      }
    }
  }
  return @ret;
}

# create nodes from their textual representation
sub create_nodes {
  my ($type,$exp,$doc,$ns)=@_;
  my @nodes=();
#  return undef unless ($exp ne "" and ref($doc));
  if ($type eq 'attribute') {
    foreach (create_attributes($exp)) {
      push @nodes,
       ($ns ne "") 
	 ? $doc->createAttribute($_->[0],$_->[1])
	 : $doc->createAttributeNS($ns,$_->[0],$_->[1]);
    }
  } elsif ($type eq 'element') {
    my ($name,$attributes);
    if ($exp=~/^\<?([^\s\/<>]+)(\s+.*)?(?:\/?\>)?\s*$/) {
      print STDERR "element_name=$1\n" if $_debug;
      print STDERR "attributes=$2\n" if $_debug;
      my ($elt,$att)=($1,$2);
      my $el= ($ns ne "") 
	? $doc->createElement($elt)
	 : $doc->createElementNS($ns,$elt);
      if ($att ne "") {
	$att=~s/\/?\>?$//;
	foreach (create_attributes($att)) {
	  print STDERR "atribute: ",$_->[0],"=",$_->[1],"\n" if $_debug;
	  if ($ns ne "") {
	    print STDERR "NS: $ns\n" if $_debug;
	    $el->setAttributeNS($ns,$_->[0],$_->[1]);
	  } else {
	    $el->setAttribute($_->[0],$_->[1]);
	  }
	}
      }
      push @nodes,$el;
    } else {
      print STDERR "invalid element $exp\n" unless "$_quiet";
    }
  } elsif ($type eq 'text') {
    push @nodes,$doc->createTextNode($exp);
    print STDERR "text=$exp\n" if $_debug;
  } elsif ($type eq 'cdata') {
    push @nodes,$doc->createCDATASection($exp);
    print STDERR "cdata=$exp\n" if $_debug;
  } elsif ($type eq 'pi') {
    my ($name,$data)=split /\s/,$exp,2;
    my $pi = $doc->createProcessingInstruction($name);
    $pi->setData($data);
    print STDERR "pi=$name $data\n" if $_debug;
    push @nodes,$pi;
#    print STDERR "cannot add PI yet\n" if $_debug;
  } elsif ($type eq 'comment') {
    push @nodes,$doc->createComment($exp);
    print STDERR "comment=$exp\n" if $_debug;
  }
  return @nodes;
}

# create new nodes from an expression and insert them to locations
# identified by XPath
sub insert {
  my ($type,$exp,$xpath,$where,$ns,$to_all)=@_;
  $exp = expand($exp);
  $ns  = expand($ns);

  my ($tid,$tq,$tdoc)=_xpath($xpath); # destination(s)

  return 0 unless ref($tdoc);
  eval {
    my @nodes;
    unless ($type eq 'chunk') {
      @nodes=grep {ref($_)} create_nodes($type,$exp,$tdoc,$ns);
      return unless @nodes;
    }
    local $SIG{INT}=\&sigint;
    my $tl=find_nodes($xpath);

    if ($to_all) {
      my $to=($where eq 'replace' ? 'after' : $where);
      foreach my $tp (@$tl) {
	if ($type eq 'chunk') {
	  if ($tp->nodeType == XML_ELEMENT_NODE) {
	    $tp->appendWellBalancedChunk($exp);
	  } else {
	    print STDERR "Target node is not an element!\n";
	  }
	} else {
	  foreach my $node (@nodes) {
	    insert_node($node,$tp,$tdoc,$to,$ns);
	  }
	}
	remove_node($tp) if $where eq 'replace';
      }
    } else {
      if ($type eq 'chunk') {
	if ($tl->[0]->nodeType == XML_ELEMENT_NODE) {
	  $tl->[0]->appendWellBalancedChunk($exp);
	} else {
	  print STDERR "Target node is not an element!\n";
	}
      } else {
	foreach my $node (@nodes) {
	  insert_node($node,$tl->[0],$tdoc,$where,$ns) if ref($tl->[0]);
	}
      }
    }
  };
  return _check_err($@);
}

# fetch document's DTD
sub get_dtd {
  my ($doc)=@_;
  my $dtd;

  eval {
    local $SIG{INT}=\&sigint;
    foreach ($doc->childNodes()) {
      if ($_->nodeType == XML_DTD_NODE) {
	if ($_->hasChildNodes()) {
	  $dtd=$_;
	} elsif ($_parser->load_ext_dtd) {
	  my $str=$_->toString();
	  my $name=$_->getName();
	  my $public_id;
	  my $system_id;
	  if ($str=~/PUBLIC\s+(\S)([^\1]*\1)\s+(\S)([^\3]*)\3/) {
	    $public_id=$2;
	    $system_id=$4;
	  }
	  if ($str=~/SYSTEM\s+(\S)([^\1]*)\1/) {
	    $system_id=$2;
	  }
	  if ($system_id!~m(/)) {
	    $system_id="$1$system_id" if ($doc->URI()=~m(^(.*/)[^/]+$));
	  }
	  print STDERR "loading external dtd: $system_id\n" unless "$_quiet";
	  $dtd=XML::LibXML::Dtd->new($public_id, $system_id)
	    if $system_id ne "";
	  if ($dtd) {
	    $dtd->setName($name);
	  } else {
	    print STDERR "failed to load dtd: $system_id\n" unless ("$_quiet");
	  }
	}
      }
    }
  };
  return _check_err($@) && $dtd;
}

# check document validity
sub valid_doc {
  my ($id)=expand @_;
  ($id,my $doc)=_id($id);
  return unless $doc;
  eval {
    local $SIG{INT}=\&sigint;
    print $OUT ($doc->is_valid() ? "yes\n" : "no\n");
  };
  return _check_err($@);
}

# validate document
sub validate_doc {
  my ($id)=expand @_;
  ($id, my $doc)=_id($id);
  return unless $doc;
  local $SIG{INT}=\&sigint;
  eval { print STDERR $doc->validate(); };
  return _check_err($@);
}

# process XInclude elements in a document
sub process_xinclude {
  my ($id)=expand @_;
  ($id, my $doc)=_id($id);
  return unless $doc;
  local $SIG{INT}=\&sigint;
  eval { $_parser->processXIncludes($doc); };
  return _check_err($@);
}

# print document's DTD
sub list_dtd {
  my ($id)=expand @_;
  ($id, my $doc)=_id($id);
  return unless $doc;
  my $dtd=get_dtd($doc);

  eval {
    local $SIG{INT}=\&sigint;
    if ($dtd) {
    my $conv=mkconv($doc->getEncoding(),$_encoding);
      print $OUT ($conv ? $conv->convert($dtd->toString()) : 
		  $dtd->toString()),"\n";
    }
  };
  return _check_err($@);
}

# print document's encoding
sub print_enc {
  my ($id)=expand @_;
  ($id, my $doc)=_id($id);
  return unless $doc;
  eval {
    local $SIG{INT}=\&sigint;
    print $OUT $doc->getEncoding(),"\n";
  };
  return _check_err($@);
}

# create an identical copy of a document
sub clone {
  my ($id1,$id2)=@_;
  ($id2, my $doc)=_id(expand $id2);

  return if ($id2 eq "" or $id2 eq "" or !ref($doc));
  print STDERR "duplicating $id2=$_files{$id2}\n" unless "$_quiet";
  eval {
    local $SIG{INT}=\&sigint;
    set_doc($id1,$_parser->parse_string($doc->toString($_indent)),$_files{$id2});
    print STDERR "done.\n" unless "$_quiet";
  };
  return _check_err($@);
}

# test if $nodea is an ancestor of $nodeb
sub is_ancestor_or_self {
  my ($nodea,$nodeb)=@_;
  while ($nodeb) {
    if ($nodea->isEqual($nodeb)) {
      return 1;
    }
    $nodeb=tree_parent_node($nodeb);
  }
}

# remve node and all its surrounding whitespace textual siblings
# from a document; remove all its descendant from all nodelists
# change current element to the nearest ancestor
sub remove_node {
  my ($node)=@_;
  if (is_ancestor_or_self($node,$LOCAL_NODE)) {
    $LOCAL_NODE=tree_parent_node($node);
  }
  my $doc=$node->ownerDocument();
  my $sibling=$node->getNextSibling();
  if ($sibling and
      $sibling->nodeType eq XML_TEXT_NODE and
      $sibling->getData =~ /^\s+$/) {
    remove_node_from_nodelists($sibling,$doc);
    $sibling->unbindNode;
  }
  remove_node_from_nodelists($node,$doc);
  $node->unbindNode();
}

# move nodes matching one XPath expression to locations determined by
# other XPath expression
sub move {
  my ($xp)=@_; #source xpath
  my ($id,$query,$doc)= _xpath($xp);
  my $sourcenodes;
  return unless ref($doc);
  my $i=0;
  eval {
    local $SIG{INT}=\&sigint;
    $sourcenodes=find_nodes($xp);
  };
  if (copy(@_)) {
    eval {
      local $SIG{INT}=\&sigint;
      foreach my $node (@$sourcenodes) {
	remove_node($node);
	$i++;
      }
    };
    return _check_err($@);
  } else {
    return 0;
  }
}

# call a shell command and print out its output
sub sh {
  eval {
    local $SIG{INT}=\&sigint;
    my $cmd=expand($_[0]);
    print $OUT `$cmd`;
  };
  return $@ ? 0 : 1;
}

# print the result of evaluating an XPath expression in scalar context
sub print_count {
  my $count=count(@_);
  print $OUT "$count\n";
  return $count;
}

# evaluate a perl expression and print out the result
sub print_eval {
  my ($expr)=@_;
  my $result=eval("package XML::XSH::Map; no strict 'vars'; $expr");
  if ($@) {
    print STDERR "$@\n";
    return 0;
  }
  print $OUT "$result\n" unless "$_quiet";
  return 1;
}

# change current node
sub cd {
  unless (chdir $_[0]) {
    print STDERR "Can't change directory to $_[0]\n";
    return 0;
  }
  return 1;
}

# call methods from a list
sub run_commands {
  return 0 unless ref($_[0]) eq "ARRAY";
  my @cmds=@{$_[0]};
  my $result=0;

  my ($cmd,@params);
  foreach my $run (@cmds) {
    if (ref($run) eq 'ARRAY') {
      ($cmd,@params)=@$run;
      if ($cmd eq "test-mode") { $_test=1; $result=1; next; }
      if ($cmd eq "run-mode") { $_test=0; $result=1; next; }
      next if $_test;
      $result=&{$cmd}(@params);
    }
  }
  return $result;
}

# redirect output and call methods from a list
sub pipe_command {
  return 1 if $_test;

  local $SIG{PIPE}=sub { };
  my ($cmd,$pipe)=@_;

  return 0 unless (ref($cmd) eq 'ARRAY');

  if ($pipe ne '') {
    my $out=$OUT;
    local *PIPE;
    local *O=*$OUT;
    print STDERR "openning pipe $pipe\n" if $_debug;
    eval {
      # open(PIPE,"| $pipe >&O") || die "cannot open pipe $pipe\n";
      open(PIPE,"| $pipe") || die "cannot open pipe $pipe\n";
      $OUT=\*PIPE;
      run_commands($cmd);
      $OUT=$out;
      close PIPE;
    };
    return _check_err($@);
  }
  return 0;
}

# call methods as long as given XPath returns positive value
sub while_statement {
  my ($xp,$command)=@_;
  my $result=1;
  while(count($xp)) {
    $result = run_commands($command) && $result;
  }
  return $result;
}

# call methods on every node matching an XPath
sub foreach_statement {
  my ($xp,$command)=@_;
  my ($id,$query,$doc)=_xpath($xp);
  return unless ref($doc);
  eval {
    local $SIG{INT}=\&sigint;
    local $LOCAL_ID=$id;
    local $LOCAL_NODE;
    my $ql=find_nodes($xp);
    foreach $LOCAL_NODE (@$ql) {
      run_commands($command)
    }
  };
  return _check_err($@);

}

# call methods if given XPath holds
sub if_statement {
  my ($xp,$command,$else)=@_;
  if (count($xp)) {
    return run_commands($command);
  } else {
    return $else ? run_commands($else) : 1;
  }
}

# call methods unless given XPath holds
sub unless_statement {
  my ($xp,$command,$else)=@_;
  unless (count($xp)) {
    return run_commands($command);
  } else {
    return $else ? run_commands($else) : 1;
  }
}

# transform a document with an XSLT stylesheet
# and create a new document from the result
sub xslt {
  my ($id,$stylefile,$newid)=expand @_[0..2];
  $id=_id($id);
  my $params=$_[3];
  print STDERR "running xslt on @_\n";
  return unless $_doc{$id};
  eval {
    my %params=@$params;
    local $SIG{INT}=\&sigint;
    if (-f $stylefile) {
      require XML::LibXSLT;

      local *SAVE;
      local *O=*$OUT;

      open (SAVE,">&STDERR");
      open (STDERR,">/dev/null");

      my $_xsltparser=XML::LibXSLT->new();
#      unless ($_xsltparser) {
#	$_xsltparser=XML::LibXSLT->new();
#      }
      my $st=$_xsltparser->parse_stylesheet_file($stylefile);
      $stylefile=~s/\..*$//;
      set_doc($newid,$st->transform($_doc{$id},%params),
	      "$stylefile"."_transformed_".$_files{$id});
      open (STDERR,">&SAVE");
      close SAVE;

    } else {
      die "File not exists $stylefile\n";
    }
  };
  return _check_err($@);
}

# call a named set of commands
sub call {
  my ($name)=expand @_;
  if (exists $_defs{$name}) {
    return run_commands($_defs{$name});
  } else {
    print STDERR "ERROR: $name not defined\n";
    return 0;
  }
}

# define a named set of commands
sub def {
  my ($name,$command)=@_;
  $name=expand $name;
  $_defs{$name}=$command;
  return 1;
}

# list all named commands
sub list_defs {
  print $OUT join("\n",sort keys (%_defs)),"\n";
  return 1;
}

# load a file
sub load {
  my ($file)=@_;
  my $l;
  print STDERR "loading file $file\n" unless "$_quiet";
  local *F;
  if (open F,"$file") {
    return join "",<F>;
  } else {
    print STDERR "ERROR: couldn't open input file $file\n";
    return undef;
  }
}

# call XSH to evaluate commands from a given file
sub include {
  my $l=load(expand $_[0]);
  return $_xsh->startrule($l);
}

# print help
sub help {
  my ($command)=expand @_;
  if ($command) {
    if (exists($XML::XSH::Help::HELP{$command})) {
      print $OUT $XML::XSH::Help::HELP{$command}->[0];
    } else {
      print $OUT "no detailed help available on $command\n";
      return 0;
    }
  } else {
    print $OUT $XML::XSH::Help::HELP;
  }
  return 1;
}

# quit
sub quit {
  exit(int($_[0]));
}

1;

package XML::XSH::Map;

# make this command available from perl expressions
sub echo {
  print $::OUT @_;
  return 1;
}

package XML::LibXML::Document;

# A hack to prevent XML::LibXML segfaults. We are hacking this so that
# findnodes is never called on the document itself
sub XML::LibXML::Document::findnodes {
    my ($self, $xpath) = @_;
    my $dom=$self->getDocumentElement();

    if ($xpath!~m/^\s*\//) {
      $xpath='/'.$xpath;
    }
    my @nodes = $dom->findnodes($xpath);
    if (wantarray) {
      return @nodes;
    }
    else {
      return XML::LibXML::NodeList->new(@nodes);
    }
}

1;
