# $Id: Makefile.PL,v 1.5 2002/03/20 17:47:58 pajas Exp $

use strict;

use ExtUtils::MakeMaker;

$| = 1;

WriteMakefile(
    'NAME'      => 'XML::XSH',
    'VERSION_FROM' => 'lib/XML/XSH/Functions.pm',
    'EXE_FILES' => ['xsh'],
    'PREREQ_PM' => {
		    'XML::LibXML' => 1.31,
		    'Text::Iconv' => 1.2,
		    'Parse::RecDescent' => 1.79,
		    'XML::XUpdate::LibXML' => 0.2,
		   },
     AUTHOR       => 'Petr Pajas (pajas@matfyz.cz)',
     ABSTRACT     => 'XML Editing Shell',
    'dist' => {
         COMPRESS  => 'gzip',
         SUFFIX    => 'gz',
	 CI        => 'cvs ci',
	 RCS_LABEL => 'cvs admin -Nv$(VERSION_SYM):',
    },
);

sub MY::postamble {
'
xml:
	tools/gen_grammar.pl src/xsh_grammar.xml > lib/XML/XSH/Grammar.pm
	tools/gen_help.pl src/xsh_grammar.xml > lib/XML/XSH/Help.pm
	tools/gen_completions.pl src/xsh_grammar.xml > lib/XML/XSH/CompletionList.pm
	cd lib/XML/XSH; perl -MGrammar -e XML::XSH::Grammar::compile
'
}

