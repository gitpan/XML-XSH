#!/usr/bin/perl

# $Id: gen_grammar.pl,v 1.1 2002/03/05 13:59:48 pajas Exp $

use strict;
use XML::LibXML;

if ($ARGV[0]=~'^(-h|--help)?$') {
  print <<EOF;
Generates RecDescent grammar from RecDescentXML source.

Usage: $0 <source.xml>

EOF
  exit;
}

my $parser=XML::LibXML->new();
my $doc=$parser->parse_file($ARGV[0]);

my $dom=$doc->getDocumentElement();
my ($rules)=$dom->getElementsByTagName('rules');
my ($preamb)=$dom->getElementsByTagName('preamb');
my ($postamb)=$dom->getElementsByTagName('postamb');

print "# This file was automatically generated from $ARGV[0] on \n# ",scalar(localtime),"\n";

print get_text($preamb,1);
foreach my $r ($rules->getElementsByTagName('rule')) {
  print "\n  ",$r->getAttribute('id'),":\n\t   ";
  print join("\n\t  |",create_productions($r)),"\n";
}
print get_text($postamb,1);

exit;

## ================================================

sub strip_space {
  my ($text)=@_;
  $text=~s/^\s*//;
  $text=~s/\s*$//;
  return $text;
}

sub get_text {
  my ($node,$no_strip)=@_;
  my $text="";
  foreach ($node->childNodes()) {
    if ($_->nodeType() == XML_TEXT_NODE ||
	$_->nodeType() == XML_CDATA_SECTION_NODE) {
      $text.=$_->getData();
    }
  }
  return $no_strip ? $text : strip_space($text);
}

sub create_productions {
  my ($rule)=@_;
  return map { create_rule_production($rule,$_) }
    $rule->getElementsByTagName('production');
}

sub has_sibling {
  my ($node)=@_;
  return 0 unless $node;
  $node=$node->nextSibling();
  while ($node) {
    return 1 if ($node->nodeType == XML_ELEMENT_NODE
		 and
		 $node->nodeName ne 'action'
		 and
		 $node->nodeName ne 'directive'
		);
    $node=$node->nextSibling();
  }
  return 0;
}

sub create_rule_production {
  my ($rule,$prod)=@_;
  my $result;
  my $name;
  foreach my $item ($prod->childNodes()) {
    next unless $item->nodeType == XML_ELEMENT_NODE;
    $name=$item->nodeName();
    if ($name eq 'regexp') {
      $result.=" /".get_text($item)."/";
    } elsif ($name eq 'directive') {
      my $text=get_text($item);
      $result.=" <".$item->getAttribute('type');
      $result.=":$text" if ($text ne "");
      $result.=">";
    } elsif ($name eq 'ruleref') {
      $result.=" ".$item->getAttribute('ref');
    } elsif ($name eq 'literal') {
      $result.=" '".get_text($item)."'";
    } elsif ($name eq 'action') {
      $result.="\n\t\t{ ".get_text($item,1)." }\n  \t";
    } elsif ($name eq 'group') {
      $result.="\n\t  " unless $result eq "";
      $result.="("
	     . join("\n\t  |",create_productions($item))
             . "\n\t   )";
    } elsif ($name eq 'selfref') {
      $result.=' /('
	.join("|", map { $_->getAttribute('regexp') ne "" ?
			   $_->getAttribute('regexp') :
			   $_->getAttribute('name')
		       }
	      $rule,$rule->findnodes("./aliases/alias"))
	. ')'
	. (has_sibling($item) ? '\s/' : '/');
    }
  }

  return $result;
}

