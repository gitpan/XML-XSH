# $Id: GDOMECompat.pm,v 1.4 2002/08/30 17:10:37 pajas Exp $

package XML::XSH::GDOMECompat;

use XML::GDOME;
use strict;
use Carp;

sub module {
  return "XML::GDOME";
}

sub version {
  return $XML::GDOME::VERSION;
}

sub new_parser {
  return XML::GDOME->new();
}

sub toStringUTF8 {
  my ($class,$node,$mode)=@_;
  # this is wrong, we should recode from doc encoding
  # but how to find out which it is?
  if ($class->is_document($node)) {
    return $node->toString($mode);
  } else {
    return $node->toString();
  }
}

sub doc_URI {
  return undef;
}

sub doc_encoding {
  my ($class,$dom)=@_;
  return '';			# not implemented ?
}

sub xml_equal {
  my ($class,$a,$b)=@_;
  return 0 unless (ref($a) and ref($b));
  return $a->gdome_ref == $b->gdome_ref
}

sub count_xpath {
  my ($class,$node,$xp)=@_;
  my $res = $node->xpath_evaluate($xp);

  my $type = $res->resultType;
  if ($type == XML::GDOME::UNORDERED_NODE_ITERATOR_TYPE ||
      $type == XML::GDOME::ORDERED_NODE_ITERATOR_TYPE) {
    my $count=0;
    while ($res->iterateNext) {
      $count++;
    }
    return $count;
  }
  elsif ($type == XML::GDOME::NUMBER_TYPE()) {
    return $res->numberValue;
  }
  elsif ($type == XML::GDOME::STRING_TYPE()) {
    return $res->stringValue;
  }
  elsif ($type == XML::GDOME::BOOLEAN_TYPE()) {
    return $res->booleanValue;
  }
  else {
    croak("Unknown result type");
  }
}

sub doc_process_xinclude {
  my ($class,$parser,$doc)=@_;
  $doc->process_xinclude();
}

sub parser_options {
  my $mode=GDOME_LOAD_PARSING;
  $mode |= GDOME_LOAD_VALIDATING if $XML::XSH::Functions::VALIDATION;
  $mode |= GDOME_LOAD_RECOVERING if $XML::XSH::Functions::RECOVERING;
  $mode |= GDOME_LOAD_SUBSTITUTE_ENTITIES if $XML::XSH::Functions::EXPAND_ENTITIES;
  $mode |= GDOME_LOAD_COMPLETE_ATTRS if $XML::XSH::Functions::COMPLETE_ATTRIBUTES;
}

sub parse_html_file {
  croak "HTML parsing not supported by GDOME\n";
  return undef;
}

sub parse_string {
  my ($class,$parser,$str)=@_;
  my $doc =$parser->createDocFromString($str,parser_options());
  if ( $XML::XSH::Functions::EXPAND_XINCLUDE ) {
    $doc->process_xinclude();
  }
  return $doc;
}

sub parse_fh {
  my ($class,$parser,$fh)=@_;
  local $/ = undef;
  my $str = <$fh>;
  my $doc = $parser->createDocFromString($str,parser_options());
  if ( $XML::XSH::Functions::EXPAND_XINCLUDE ) {
    $doc->process_xinclude();
  }
  return $doc;
}

sub parse_file {
  my ($class,$parser, $uri) = @_;
  my $doc = $parser->createDocFromURI($uri,parser_options());
  if ( $XML::XSH::Functions::EXPAND_XINCLUDE ) {
    $doc->process_xinclude();
  }
  return $doc;
}

sub is_xinclude_start {
  return 0;			# not supported
}

sub is_xinclude_end {
  return 0;			# not supported
}

sub is_element {
  my ($class,$node)=@_;
  return $node->nodeType == ELEMENT_NODE;
}

sub is_attribute {
  my ($class,$node)=@_;
  my $type=$node->getNodeType();
  my $attype=ATTRIBUTE_NODE();
  return $type == $attype;
}

sub is_text {
  my ($class,$node)=@_;
  return $node->nodeType == TEXT_NODE;
}

sub is_text_or_cdata {
  my ($class,$node)=@_;
  return $node->nodeType == TEXT_NODE || $node->nodeType == CDATA_SECTION_NODE;
}

sub is_cdata_section {
  my ($class,$node)=@_;
  return $node->nodeType == CDATA_SECTION_NODE;
}


sub is_pi {
  my ($class,$node)=@_;
  return $node->nodeType == PROCESSING_INSTRUCTION_NODE;
}

sub is_entity {
  my ($class,$node)=@_;
  return $node->nodeType == ENTITY_NODE;
}

sub is_document {
  my ($class,$node)=@_;
  return $node->nodeType == DOCUMENT_NODE;
}

sub is_document {
  my ($class,$node)=@_;
  return $node->nodeType == DOCUMENT_FRAGMENT_NODE;
}

sub is_comment {
  my ($class,$node)=@_;
  return $node->nodeType == COMMENT_NODE;
}

sub is_namespace {
  my ($class,$node)=@_;
  return $node->nodeType == XPATH_NAMESPACE_NODE;
}

sub get_dtd {
  die "Not implemented for GDOME\n";
}

sub clone_node {
  my ($class, $dom, $node)=@_;
  return $dom->importNode($node,1);
}

sub remove_node {
  my ($class,$node)=@_;
  my $parent=$node->getParentNode();
  if ($parent) {
    return $parent->removeChild($node);
  }
}

package XML::GDOME::Document;

sub getEncoding {
  return "utf-8";
}

1;

