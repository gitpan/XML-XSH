# $Id: Functions.pm,v 1.3 2002/03/08 18:01:49 pajas Exp $

package XML::XSH::Functions;

use strict;
no warnings;

use XML::LibXML;
use Text::Iconv;
use XML::XSH::Help;

use Exporter;
use vars qw/@ISA @EXPORT_OK %EXPORT_TAGS $VERSION $OUT $LAST_ID $LOCAL_ID $LOCAL_NODE
            $_xsh $_parser $_encoding $_qencoding
            $_quiet $_debug $_test $_newdoc $_indent
            %_doc %_files %_iconv %_defs/;

BEGIN {
  $VERSION='0.9';
  @ISA=qw(Exporter);
  @EXPORT_OK=qw(&xsh_init &xsh
                &xsh_set_output &xsh_set_parser
                &set_opt_q &set_opt_d &set_opt_c
		&create_doc &open_doc &set_doc
	       );
  %EXPORT_TAGS = (default => [@EXPORT_OK]);

  $LAST_ID='';
  $_indent=1;
  $_encoding='iso-8859-2';
  $_qencoding='iso-8859-2';
  $_newdoc=1;
}

sub OK			{ 1 }
sub PARSE_ERROR		{ 2 }
sub INCOMPLETE_COMMAND	{ 3 }

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

sub set_validation { $_parser->validation($_[0]); }
sub set_expand_entities { $_parser->expand_entities($_[0]); }
sub set_keep_blanks { $_parser->keep_blanks($_[0]); }
sub set_pedantic_parser { $_parser->pedantic_parser($_[0]); }
sub set_load_ext_dtd { $_parser->load_ext_dtd($_[0]); }
sub set_complete_attributes { $_parser->complete_attributes($_[0]); }
sub set_expand_xinclude { $_parser->expand_xinclude($_[0]); }
sub set_indent { $_indent=$_[0]; }

sub xsh {
  if (ref($_xsh)) {
    return $_xsh->startrule($_[0]);
  } else {
    return 0;
  }
}

sub xsh_set_output {
  $OUT=$_[0];
  return 1;
}

sub xsh_set_parser {
  $_xsh=$_[0];
  return 1;
}

sub set_last_id {
  $LAST_ID=$_[0];
  return 1;
}

sub print_version {
  print $OUT "Main program:   $::VERSION $::REVISION\n";
  print $OUT "XML::XSH::Functions: $VERSION\n";
  print $OUT "XML::LibXML     $XML::LibXML::VERSION\n";
  print $OUT "XML::LibXSLT    $XML::LibXSLT::VERSION\n" if defined($XML::LibXSLT::VERSION);
  return 1;
}

sub files {
  print $OUT map { "$_ = $_files{$_}\n" } sort keys %_files;
  return 1;
}

sub variables {
  no strict;
  foreach (keys %{"XML::XSH::Map::"}) {
    print $OUT "\$$_=",${"XML::XSH::Map::$_"},"\n" if defined(${"XML::XSH::Map::$_"});
  }
  return 1;
}

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

sub _check_err {
  if ($_[0]) {
    print STDERR "$_[0]\n";
    return 0;
  } else {
    return 1;
  }
}

sub get_local_element {
  my ($id)=@_;
  if ($LOCAL_NODE and $id eq $LOCAL_ID) {
    return $LOCAL_NODE;
  } else {
    return $_doc{$id} ? $_doc{$id}->getDocumentElement() : undef;
  }
}


sub _id {
  my ($id)=@_;
  if ($id ne "") {
    print STDERR "setting last id $id\n" if $_debug;
    $LAST_ID=$id;
  } else {
    $id=$LAST_ID;
    print STDERR "using last id $id\n" if $_debug;
  }
  return wantarray ? ($id,$_doc{$id}) : $id;
}

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

sub expand {
  return wantarray ? (map { _expand($_) } @_) : _expand($_[0]);
}

sub _assign {
  my ($name,$value)=@_;
  no strict 'refs';
  $name=~/^\$(.+)/;
  ${"XML::XSH::Map::$1"}=$value;
  print STDERR "\$$1=",${"XML::XSH::Map::$1"},"\n" unless "$_quiet";
  return 1;
}

sub xpath_assign {
  my ($name,$xp)=@_;
  _assign($name,count($xp));
  return 1;
}


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
    $_doc{$id}=$doc;
    $_files{$id}="new_document$_newdoc.xml";
    $_newdoc++;
  };
  return _check_err($@) ? $doc : undef;
}

sub set_doc {
  my ($id,$doc,$file)=@_;
  $_doc{$id}=$doc;
  $_files{$id}=$file;
  return $doc;
}

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
      $_doc{$id}=$doc;
      $_files{$id}=$file;
    };
    return _check_err($@);
  } else {
    print STDERR "file not exists: $file\n";
    return 0;
  }
}

sub close_doc {
  my ($id)=expand(@_);
  $id=_id($id);
  print $OUT "closing file $_files{$id}\n" unless "$_quiet";
  delete $_files{$id};
  delete $_doc{$id};
  return 1;
}

sub save_as {
  my ($id,$file,$enc)= expand(@_);
  ($id,my $doc)=_id($id);
  return unless ref($doc);
  $file=$_files{$id} if $file eq "";
  print STDERR "$id=$_files{$id} --> $file ($enc)\n" unless "$_quiet";
  $enc=$doc->getEncoding() unless ($enc ne "");
  local *F;
  $file=~/^\s*[|>]/ ? open(F,$file) : open(F,">$file");
#  if ($enc=~/^utf-?8$/i) {
#    eval {
#      local $SIG{INT}=\&sigint;
#      print F $doc->toString($_indent);
#    }; print STDERR "$@" if ($@);
#    print STDERR "saved $id=$_files{$id} as $file in $enc encoding\n" unless "$_quiet";
#  } else {
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

sub list {
  my ($id,$query)=(undef,undef);
  ($id,$query)=expand(@{$_[0]});
  ($id,my $doc)=_id($id);
  if ($id eq "" or $query eq "") {
    return files();
  }
  print STDERR "listing $query from $id=$_files{$id}\n" unless "$_quiet";
  return 0 unless ref($doc);
  eval {
    local $SIG{INT}=\&sigint;
    my $qconv=mkconv($_qencoding,"utf-8");
    my @ql=get_local_element($id)->findnodes($qconv ? $qconv->convert($query) : $query);
    my $conv=mkconv($doc->getEncoding,$_encoding);
    if ($conv) {
      foreach (@ql) {
	print $OUT $conv->convert(ref($_) ? $_->toString() : $_),"\n";
      }
    } else {
      foreach (@ql) {
	print $OUT ((ref($_) ? $_->toString() : $_),"\n");
      }
    }
    print STDERR "\nFound ",scalar(@ql)," nodes.\n" unless "$_quiet";
  };
  return _check_err($@);
}

sub count {
  my ($id,$query)= expand @{$_[0]};
  ($id,my $doc)=_id($id);
  return if ($id eq "" or $query eq "");
  unless (ref($doc)) {
    print STDERR "No such document: $id\n";
    return undef;
  }
  print STDERR "Query $query on $id=$_files{$id}\n" if $_debug;
  my $result=undef;
  eval {
    local $SIG{INT}=\&sigint;
    my $qconv=mkconv($_qencoding,"utf-8");
    $result=get_local_element($id)->find($qconv ? $qconv->convert($query) : $query);
  };
  if ($@) {
    print STDERR "$@\n";
    return undef;
  }
  if (ref($result)) {
    return $result->size() if ($result->isa('XML::LibXML::NodeList'));
    if ($result->isa('XML::LibXML::Literal')) {
      my $conv=mkconv($doc->getEncoding(),$_encoding);
      return $conv ? $conv->convert($result->value()) : $result->value();
    }
    return $result->value() if (
				$result->isa('XML::LibXML::Number') or
				$result->isa('XML::LibXML::Boolean')
			       );
  } else {
    return undef;
  }
}

sub prune {
  my ($id,$query)=expand @{$_[0]};
  ($id, my $doc)=_id($id);
  return unless ref($doc);
  my $i=0;
  eval {
    local $SIG{INT}=\&sigint;
    my $qconv=mkconv($_qencoding,"utf-8");

    foreach my $node (get_local_element($id)->
		      findnodes($qconv ? $qconv->convert($query) : $query)) {
      remove_node($node);
      $i++;
    }
    print STDERR "$i nodes removed from $id=$_files{$id}\n" unless "$_quiet";
  };
  return _check_err($@);
}

sub eval_substitution {
  my ($pat,$inenc,$outenc);
  ($_,$pat,$inenc,$outenc)=@_;

  $_=$inenc ? $inenc->convert($_) : $_;

  eval "package XML::XSH::Map; no strict 'vars'; $pat";

  if ($@) {
    print STDERR "$@\n";
    return "";
  }
  $_=$outenc ? $outenc->convert($_) : $_;
  return $_;
}

sub perlmap {
  my ($q, $pattern)=@_;
  my ($id,$query)=expand @{$q};
  ($id,my $doc)=_id($id);
  print STDERR "Executing $pattern on $query in $id=$_files{$id}\n" unless "$_quiet";
  unless ($doc) {
    print STDERR "No such document $id\n";
    return;
  }
  eval {
    local $SIG{INT}=\&sigint;

    my $sdoc=get_local_element($id);
    my $qconv=mkconv($_qencoding,"utf-8");
    my $inconv=mkconv($doc->getEncoding(),$_qencoding);
    my $outconv=mkconv($_qencoding,$doc->getEncoding());

    $pattern=$qconv ? $qconv->convert($pattern) : $pattern;

    foreach my $node ($sdoc->findnodes($qconv ? $qconv->convert($query) : $query)) {
      if ($node->nodeType eq XML_ATTRIBUTE_NODE) {
	my $val=$node->getValue();
	$node->setValue(eval_substitution($val,$pattern,$inconv,$outconv));
      } elsif ($node->nodeType eq XML_ELEMENT_NODE) {
	my $val=$node->getName();
	$node->setName(eval_substitution($val,$pattern,$inconv,$outconv));
      } elsif ($node->can('setData') and $node->can('getData')) {
	my $val=$node->getData();
	$node->setData(eval_substitution($val,$pattern,$inconv,$outconv));
      }
    }
  };
  return _check_err($@);
}

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
	$dest->unbindNode();
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
      $dest->unbindNode();
    } else {
      $dest->parentNode()->insertBefore($copy,$dest);
    }
  }
  return 1;
}

sub copy {
  my ($fid,$fq)=expand @{$_[0]}; # from ID, from query
  my ($tid,$tq)=expand @{$_[1]}; # to ID, to query
  my ($where,$all_to_all)=($_[2],$_[3]);

  ($fid,my $fdoc)=_id($fid);
  ($tid,my $tdoc)=_id($tid);
  return unless (ref($fdoc) and ref($tdoc));
  my (@fp,@tp);
  eval {
    local $SIG{INT}=\&sigint;
    my $qconv=mkconv($_qencoding,"utf-8");
    $fq=$qconv ? $qconv->convert($fq) : $fq;
    $tq=$qconv ? $qconv->convert($tq) : $tq;
    @fp=get_local_element($fid)->findnodes($fq);
    @tp=get_local_element($tid)->findnodes($tq);
  };
  return _check_err($@) if ($@);
  unless (@tp) {
    print STDERR "No matching nodes found for $tq in $tid=$_files{$tid}\n" unless "$_quiet";
    return 0;
  }
  eval {
    local $SIG{INT}=\&sigint;
    my $ns;
    if ($all_to_all) {
      my $to=($where eq 'replace' ? 'after' : $where);
      foreach my $tp (@tp) {
	foreach my $fp (@fp) {
	  $ns=$fp->getNamespaceURI();
	  insert_node($fp,$tp,$tdoc,$to,$ns);
	}
	$tp->unbindNode() if $where eq 'replace';
      }
    } else {
      while (ref(my $fp=shift @fp) and ref(my $tp=shift @tp)) {
	$ns=$fp->getNamespaceURI();
	insert_node($fp,$tp,$tdoc,$where,$ns);
      }
    }
  };
  return _check_err($@);
}

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

sub insert {
  my ($type,$exp,$xpath,$where,$ns,$to_all)=@_;
  $exp = expand($exp);
  $ns  = expand($ns);

  my ($tid,$tq)=expand @{$xpath}; # to ID, to query

  ($tid,my $tdoc)=_id($tid);
  return 0 unless ref($tdoc);

  eval {
    my @nodes;
    unless ($type eq 'chunk') {
      @nodes=grep {ref($_)} create_nodes($type,$exp,$tdoc,$ns);
      return unless @nodes;
    }
    local $SIG{INT}=\&sigint;
    my $qconv=mkconv($_qencoding,"utf-8");
    $tq=$qconv ? $qconv->convert($tq) : $tq;
    my @tp=get_local_element($tid)->findnodes($tq);

    if ($to_all) {
      my $to=($where eq 'replace' ? 'after' : $where);
      foreach my $tp (@tp) {
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
	$tp->unbindNode() if $where eq 'replace';
      }
    } else {
      if ($type eq 'chunk') {
	if ($tp[0]->nodeType == XML_ELEMENT_NODE) {
	  $tp[0]->appendWellBalancedChunk($exp);
	} else {
	  print STDERR "Target node is not an element!\n";
	}
      } else {
	foreach my $node (@nodes) {
	  insert_node($node,$tp[0],$tdoc,$where,$ns) if ref($tp[0]);
	}
      }
    }
  };
  return _check_err($@);
}

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

sub validate_doc {
  my ($id)=expand @_;
  ($id, my $doc)=_id($id);
  return unless $doc;
  local $SIG{INT}=\&sigint;
  eval { print STDERR $doc->validate(); };
  return _check_err($@);
}

sub process_xinclude {
  my ($id)=expand @_;
  ($id, my $doc)=_id($id);
  return unless $doc;
  local $SIG{INT}=\&sigint;
  eval { $_parser->processXIncludes($doc); };
  return _check_err($@);
}


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

sub clone {
  my ($id1,$id2)=@_;
  ($id2, my $doc)=_id(expand $id2);

  return if ($id2 eq "" or $id2 eq "" or !ref($doc));
  print STDERR "duplicating $id2=$_files{$id2}\n" unless "$_quiet";
  $_files{$id1}=$_files{$id2};
  eval {
    local $SIG{INT}=\&sigint;
    $_doc{$id1}=$_parser->parse_string($doc->toString());
    print STDERR "done.\n" unless "$_quiet";
  };
  return _check_err($@);
}

sub remove_node {
  my ($node)=@_;
  my $sibling=$node->getNextSibling();
  if ($sibling and
      $sibling->nodeType eq XML_TEXT_NODE and
      $sibling->getData =~ /^\s+$/) {
    $sibling->unbindNode;
  }
  $node->unbindNode();
}

sub move {
  my ($src)=@_;
  my @sourcenodes;
  my ($id,$query)= expand @{$src};
  ($id,my $doc)=_id($id);
  return unless ref($doc);
  my $i=0;
  eval {
    local $SIG{INT}=\&sigint;
    my $qconv=mkconv($_qencoding,"utf-8");
    @sourcenodes=get_local_element($id)->
      findnodes($qconv ? $qconv->convert($query) : $query);
  };
  if (copy(@_)) {
    eval {
      local $SIG{INT}=\&sigint;
      foreach my $node (@sourcenodes) {
	remove_node($node);
	$i++;
      }
    };
    return _check_err($@);
  } else {
    return 0;
  }
}

sub sh {
  eval {
    local $SIG{INT}=\&sigint;
    my $cmd=expand($_[0]);
    print $OUT `$cmd`;
  };
  return $@ ? 0 : 1;
}

sub print_count {
  my $count=count(@_);
  print $OUT "$count\n";
  return $count;
}

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

sub cd {
  unless (chdir $_[0]) {
    print STDERR "Can't change directory to $_[0]\n";
    return 0;
  }
  return 1;
}

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

sub while_statement {
  my ($xp,$command)=@_;
  my $result=1;
  while(count($xp)) {
    $result = run_commands($command) && $result;
  }
  return $result;
}

sub foreach_statement {
  my ($xp,$command)=@_;
  my ($id,$query)=expand @{$xp};
  ($id, my $doc)=_id($id);
  return unless ref($doc);
  eval {
    local $SIG{INT}=\&sigint;
    my $qconv=mkconv($_qencoding,"utf-8");
    $query=$qconv ? $qconv->convert($query) : $query;
    local $LOCAL_ID=$id;
    local $LOCAL_NODE=$LOCAL_NODE;
    foreach $LOCAL_NODE (get_local_element($id)->findnodes($query)) {
      run_commands($command)
    }
  };
  return _check_err($@);

}

sub if_statement {
  my ($xp,$command,$else)=@_;
  if (count($xp)) {
    return run_commands($command);
  } else {
    return $else ? run_commands($else) : 1;
  }
}

sub unless_statement {
  my ($xp,$command,$else)=@_;
  unless (count($xp)) {
    return run_commands($command);
  } else {
    return $else ? run_commands($else) : 1;
  }
}

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
      $_doc{$newid}=$st->transform($_doc{$id},%params);
      $stylefile=~s/\..*$//;
      $_files{$newid}="$stylefile"."_transformed_".$_files{$id};

      open (STDERR,">&SAVE");
      close SAVE;

    } else {
      die "File not exists $stylefile\n";
    }
  };
  return _check_err($@);
}

sub call {
  my ($name)=expand @_;
  if (exists $_defs{$name}) {
    return run_commands($_defs{$name});
  } else {
    print STDERR "ERROR: $name not defined\n";
    return 0;
  }
}

sub def {
  my ($name,$command)=@_;
  $name=expand $name;
  $_defs{$name}=$command;
  return 1;
}

sub list_defs {
  print $OUT join("\n",sort keys (%_defs)),"\n";
  return 1;
}


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

sub include {
  my $l=load(expand $_[0]);
  return $_xsh->startrule($l);
}

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

sub quit {
  exit(int($_[0]));
}

1;

package XML::XSH::Map;

sub echo {
  print $::OUT @_;
  return 1;
}

1;
