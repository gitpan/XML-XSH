#!/usr/bin/perl

# $Id: gen_help.pl,v 1.3 2002/03/14 17:32:06 pajas Exp $

use strict;
use XML::LibXML;
use Text::Wrap qw(wrap);

if ($ARGV[0]=~'^(-h|--help)?$') {
  print <<EOF;
Generates help module from RecDescentXML source.

Usage: $0 <source.xml>

EOF
  exit;
}

my $parser=XML::LibXML->new();
$parser->load_ext_dtd(1);
$parser->validation(1);
my $doc=$parser->parse_file($ARGV[0]);

my $dom=$doc->getDocumentElement();
my ($rules)=$dom->findnodes('./rules');

my $ruledoc;
my $title;
my @aliases;
my @seealso;
my $usage;
my $desc;


print "# This file was automatically generated from $ARGV[0] on \n# ",scalar(localtime),"\n";
print <<'PREAMB';

package XML::XSH::Help;
use strict;
use vars qw($HELP %HELP);


PREAMB

print "\$HELP=<<'END';\n";
print "General notes:\n\n";
($desc)=$dom->findnodes('./description');
print_description($desc,"  ","  ") if ($desc);
print "END\n\n";

foreach my $r ($rules->findnodes('./rule')) {
  my ($ruledoc)=$r->findnodes('./documentation');
  next unless $ruledoc;
  my $name=get_name($r);

  print "\$HELP{'$name'}=[<<'END'];\n";
  ($title)=$ruledoc->findnodes('./title');
  print get_text($title),"\n\n" if ($title);

  ($usage)=$ruledoc->findnodes('./usage');
  if ($usage) {
    print "usage:       ",get_text($usage),"\n\n";
  }
  @aliases=$r->findnodes('./aliases/alias');
  if (@aliases) {
    print "aliases:     ",join " ",map { get_name($_) } @aliases;
    print "\n\n";
  }
  ($desc)=$ruledoc->findnodes('./description');
  if ($desc) {
    print "description:";
    print_description($desc," "," "x(13));
  }
  @seealso=$ruledoc->findnodes('./description/see-also/ruleref');
  if (@seealso) {
    print "see also:     ",join " ",
      map { get_name($_) } @seealso;
    print "\n\n";
  }

  print "END\n\n";

  foreach (@aliases) {
    print "\$HELP{'",get_name($_),"'}=\$HELP{$name};\n";
  }
  print "\n";

}

print "\n1;\n__END__\n\n";

exit;

## ================================================

sub strip_space {
  my ($text)=@_;
  $text=~s/^\s*//;
  $text=~s/\s*$//;
  return $text;
}

sub get_name {
  my ($r)=@_;
  return $r->getAttribute('name') ne ""
    ? $r->getAttribute('name')
      : $r->getAttribute('id');
}

sub get_text {
  my ($node,$no_strip)=@_;
  my $text="";
  foreach my $n ($node->childNodes()) {
    if ($n->nodeType() == XML_TEXT_NODE ||
	$n->nodeType() == XML_CDATA_SECTION_NODE) {
      $text.=$n->getData();
    } elsif ($n->nodeType() == XML_ELEMENT_NODE) {
      if ($n->nodeName() eq 'link') {
	$text.="<".get_text($n,1).">";
      } elsif ($n->nodeName() eq 'xref') {
	$text.="<";
	my ($ref)=$node->findnodes("id('".$n->getAttribute('linkend')."')");
	if ($ref) {
	  $text.=get_name($ref);
	} else {
	  print STDERR "Reference to undefined identifier: ",$n->getAttribute('linkend'),"\n";
	}
	$text.=">";
      } elsif ($n->nodeName() eq 'typeref') {
	foreach (split /\s/,$n->getAttribute('types')) {
	  $text.=join ", ", sort map { get_name($_) } $node->findnodes("//rules/rule[\@type='$_']");
	}
      } else {
	$text.=get_text($n);
      }
    }
  }
  return $no_strip ? $text : strip_space($text);
}

sub max { ($_[0] > $_[1]) ? $_[0] : $_[1] }

sub  print_description {
  my ($desc,$indent,$bigindent)=@_;
  foreach my $c ($desc->childNodes()) {
    if ($c->nodeType == XML_ELEMENT_NODE) {
      if ($c->nodeName eq 'para') {
	my $t=get_text($c);
	$t=~s/\s+/ /g;
	print wrap($indent,$bigindent,$t),"\n\n";
	$indent=$bigindent;
      } elsif ($c->nodeName eq 'example') {
	foreach (map { get_text($_) } $c->findnodes('./title')) {
	  s/\s+/ /g;
	  print wrap("",$bigindent,"Example:"." "x(max(1,length($bigindent)-8))."$_\n");
	}
	print "\n";
	foreach (map { get_text($_) } $c->findnodes('./code')) {
	  s/\n[ \t]+/\n$bigindent/g;
	  s/\\\n/\\\n  /g;
	  print "$bigindent$_\n";
	}
	print "\n";
      }
    }
  }
}
