# $Id: LibXMLCompat.pm,v 1.7 2002/10/25 16:01:50 pajas Exp $

package XML::XSH::LibXMLCompat;

use strict;
use XML::LibXML;


sub module {
  return "XML::LibXML";
}

sub version {
  return $XML::LibXML::VERSION;
}

sub toStringUTF8 {
  my ($class,$node,$mode)=@_;
  if ($class->is_document($node)) {
    return XML::LibXML::encodeToUTF8($node->getEncoding(),$node->toString($mode));
  } else {
    return $node->can('toString') ? $node->toString($mode) : $node->to_literal();
  }
}

sub new_parser {
  return XML::LibXML->new();
}

sub owner_document {
  my ($self,$node)=@_;
  if ($self->is_document($node)) {
    return $node
  } else {
    return $node->ownerDocument()
  }
}

sub doc_URI {
  my ($class,$dom)=@_;
  return $dom->URI();
}

sub doc_encoding {
  my ($class,$dom)=@_;
  return $dom->getEncoding();
}

sub set_encoding {
  my ($class,$dom,$encoding)=@_;
  return $dom->setEncoding($encoding);
}

sub xml_equal {
  my ($class,$a,$b)=@_;
  return $a->isSameNode($b);
}

sub count_xpath {
  my ($class,$node,$xp)=@_;
  my $result;
  $result=$node->find($xp);

  if (ref($result)) {
    if ($result->isa('XML::LibXML::NodeList')) {
      return $result->size();
    } elsif ($result->isa('XML::LibXML::Literal')) {
      return $result->value();
    } elsif ($result->isa('XML::LibXML::Number') or
	     $result->isa('XML::LibXML::Boolean')) {
      return $result->value();
    }
  } else {
    return $result;
  }
}

sub doc_process_xinclude {
  my ($class,$parser,$doc)=@_;
  $parser->processXIncludes($doc);
}

sub init_parser {
  my ($class,$parser)=@_;
   $parser->validation($XML::XSH::Functions::VALIDATION);
   $parser->recover($XML::XSH::Functions::RECOVERING) if $parser->can('recover');
   $parser->expand_entities($XML::XSH::Functions::EXPAND_ENTITIES);
   $parser->keep_blanks($XML::XSH::Functions::KEEP_BLANKS);
   $parser->pedantic_parser($XML::XSH::Functions::PEDANTIC_PARSER);
   $parser->load_ext_dtd($XML::XSH::Functions::LOAD_EXT_DTD);
   $parser->complete_attributes($XML::XSH::Functions::COMPLETE_ATTRIBUTES);
   $parser->expand_xinclude($XML::XSH::Functions::EXPAND_XINCLUDE);
}


sub parse_string {
  my ($class,$parser,$str)=@_;
  $class->init_parser($parser);
   return $parser->parse_string($str);
}

sub parse_html_file {
  my ($class,$parser,$file)=@_;
  $class->init_parser($parser);
  my $doc=$parser->parse_html_file($file);
  return $doc;
}

sub parse_html_fh {
  my ($class,$parser,$fh)=@_;
  $class->init_parser($parser);
  print STDERR ("$parser $fh\n");
  my $doc=$parser->parse_html_fh($fh);
  return $doc;
}

sub parse_sgml_file {
  my ($class,$parser,$file,$encoding)=@_;
  $class->init_parser($parser);
  my $doc=$parser->parse_sgml_file($file,$encoding);
  return $doc;
}

sub parse_sgml_fh {
  my ($class,$parser,$fh,$encoding)=@_;
  $class->init_parser($parser);
  my $doc=$parser->parse_sgml_fh($fh,$encoding);
  return $doc;
}

sub parse_fh {
  my ($class,$parser,$fh)=@_;
  $class->init_parser($parser);
  return $parser->parse_fh($fh);
}

sub parse_file {
  my ($class,$parser,$file)=@_;
  $class->init_parser($parser);
  return $parser->parse_file($file);
}

sub is_xinclude_start {
  my ($class,$node)=@_;
  return $node->nodeType == XML::LibXML::XML_XINCLUDE_START();
}

sub is_xinclude_end {
  my ($class,$node)=@_;
  return $node->nodeType == XML::LibXML::XML_XINCLUDE_END();
}

sub is_element {
  my ($class,$node)=@_;
  return $node->nodeType == XML::LibXML::XML_ELEMENT_NODE();
}

sub is_attribute {
  my ($class,$node)=@_;
  return $node->nodeType == XML::LibXML::XML_ATTRIBUTE_NODE();
}

sub is_text {
  my ($class,$node)=@_;
  return $node->nodeType == XML::LibXML::XML_TEXT_NODE();
}

sub is_text_or_cdata {
  my ($class,$node)=@_;
  return $node->nodeType == XML::LibXML::XML_TEXT_NODE() || $node->nodeType == XML::LibXML::XML_CDATA_SECTION_NODE();
}

sub is_cdata_section {
  my ($class,$node)=@_;
  return $node->nodeType == XML::LibXML::XML_CDATA_SECTION_NODE();
}


sub is_pi {
  my ($class,$node)=@_;
  return $node->nodeType == XML::LibXML::XML_PI_NODE();
}

sub is_entity_reference {
  my ($class,$node)=@_;
  return $node->nodeType == XML::LibXML::XML_ENTITY_REF_NODE();
}

sub is_document {
  my ($class,$node)=@_;
  return $node->nodeType == XML::LibXML::XML_DOCUMENT_NODE();
}

sub is_document_fragment {
  my ($class,$node)=@_;
  return $node->nodeType == XML::LibXML::XML_DOCUMENT_FRAG_NODE();
}

sub is_comment {
  my ($class,$node)=@_;
  return $node->nodeType == XML::LibXML::XML_COMMENT_NODE();
}

sub is_namespace {
  my ($class,$node)=@_;
  return $node->nodeType == XML::LibXML::XML_NAMESPACE_DECL();
}

sub has_dtd {
  my ($class,$doc)=@_;
  foreach my $node ($doc->childNodes()) {
    if ($node->nodeType == XML::LibXML::XML_DTD_NODE()) {
      return 1;
    }
  }
  return 0;
}

sub get_dtd {
  my ($class,$doc,$quiet)=@_;
  my $dtd;
  foreach my $node ($doc->childNodes()) {
    if ($node->nodeType == XML::LibXML::XML_DTD_NODE()) {
      if ($node->hasChildNodes()) {
	$dtd=$node;
      } elsif (get_load_ext_dtd()) {
	my $str=$node->toString();
	my $name=$node->getName();
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
	  $system_id="$1$system_id" if ($class->doc_URI($doc)=~m(^(.*/)[^/]+$));
	}
	print STDERR "loading external dtd: $system_id\n" unless $quiet;
	$dtd=XML::LibXML::Dtd->new($public_id, $system_id)
	  if $system_id ne "";
	if ($dtd) {
	  $dtd->setName($name);
	} else {
	  print STDERR "failed to load dtd: $system_id\n" unless $quiet;
	}
      }
    }
  }
  return $dtd;
}

sub clone_node {
  my ($class, $dom, $node)=@_;
  return $dom->importNode($node);
}

sub remove_node {
  my ($class,$node)=@_;
  return $node->unbindNode();
}

1;

