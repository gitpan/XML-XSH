#!/usr/bin/perl

# $Id: gen_completions.pl,v 1.2 2002/03/06 08:51:27 pajas Exp $

use strict;
use XML::LibXML;
use Text::Wrap qw(wrap);

if ($ARGV[0]=~'^(-h|--help)?$') {
  print <<EOF;
Generates a command-list module from RecDescentXML source.

Usage: $0 <source.xml>

EOF
  exit;
}

print <<'EOF';
package XML::XSH::CompletionList;

use strict;
use vars qw(@XSH_COMMANDS);

@XSH_COMMANDS=qw(
EOF

sub get_name {
  my ($r)=@_;
  return $r->getAttribute('name') ne ""
    ? $r->getAttribute('name')
      : $r->getAttribute('id');
}

my $parser=XML::LibXML->new();
my $doc=$parser->parse_file($ARGV[0]);

my $dom=$doc->getDocumentElement();

foreach (sort map { get_name($_) }
	 $dom->findnodes('./rules/rule[@type="command"]'),
	 $dom->findnodes('./rules/rule[@type="command"]/aliases/alias')) {
  print "$_\n";
}

print ");\n\n1;\n";