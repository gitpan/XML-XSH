# This file was automatically generated from src/xsh_grammar.xml on 
# Mon Sep  2 17:38:12 2002


package XML::XSH::Grammar;

use strict;
use Parse::RecDescent;
use vars qw/$grammar/;

$Parse::RecDescent::skip = '(\s|\n|#[^\n]*)*';
$grammar=<<'_EO_GRAMMAR_';

  
  command:
	    /(backups)/
		{ [\&XML::XSH::Functions::set_backups,1] }
  	
	  | /(nobackups)/
		{ [\&XML::XSH::Functions::set_backups,0] }
  	
	  | /(quiet)/
		{ [\&XML::XSH::Functions::set_opt_q,1] }
  	
	  | /(verbose)/
		{ [\&XML::XSH::Functions::set_opt_q,0] }
  	
	  | /(test-mode|test_mode)/
		{ ["test-mode"] }
  	
	  | /(run-mode|run_mode)/
		{ ["run-mode"] }
  	
	  | /(debug)/
		{ [\&XML::XSH::Functions::set_opt_d,1] }
  	
	  | /(nodebug)/
		{ [\&XML::XSH::Functions::set_opt_d,0] }
  	
	  | /(version)/
		{ [\&XML::XSH::Functions::print_version,0] }
  	
	  | /(validation)\s/ <commit> expression
		{ [\&XML::XSH::Functions::set_validation,$item[3]] }
  	
	  | /(recovering)\s/ <commit> expression
		{ [\&XML::XSH::Functions::set_recovering,$item[3]] }
  	
	  | /(parser-expands-entities|parser_expands_entities)\s/ <commit> expression
		{ [\&XML::XSH::Functions::set_expand_entities,$item[3]] }
  	
	  | /(keep-blanks|keep_blanks)\s/ <commit> expression
		{ [\&XML::XSH::Functions::set_keep_blanks,$item[3]] }
  	
	  | /(pedantic-parser|pedantic_parser)\s/ <commit> expression
		{ [\&XML::XSH::Functions::set_pedantic_parser,$item[3]] }
  	
	  | /(parser-completes-attributes|complete_attributes|complete-attributes|parser_completes_attributes)\s/ <commit> expression
		{ [\&XML::XSH::Functions::set_complete_attributes,$item[3]] }
  	
	  | /(indent)\s/ <commit> expression
		{ [\&XML::XSH::Functions::set_indent,$item[3]] }
  	
	  | /(parser-expands-xinclude|parser_expands_xinclude)\s/ <commit> expression
		{ [\&XML::XSH::Functions::set_expand_xinclude,$item[3]] }
  	
	  | /(load-ext-dtd|load_ext_dtd)\s/ <commit> expression
		{ [\&XML::XSH::Functions::set_load_ext_dtd,$item[3]] }
  	
	  | /(encoding)\s/ <commit> expression
		{ [\&XML::XSH::Functions::set_encoding,$item[3]] }
  	
	  | /(query-encoding|query_encoding)\s/ <commit> expression
		{ [\&XML::XSH::Functions::set_qencoding,$item[3]] }
  	
	  | /(options|flags)/ <commit>
		{ [\&XML::XSH::Functions::list_flags] }
  	
	  | /(copy|cp)\s/ <commit> xpath loc xpath
		{ [\&XML::XSH::Functions::copy,@item[3,5,4]] }
  	
	  | /(xcopy|xcp)\s/ <commit> xpath loc xpath
		{ [\&XML::XSH::Functions::copy,@item[3,5,4],1] }
  	
	  | /(move|mv)\s/ <commit> xpath loc xpath
		{ [\&XML::XSH::Functions::move,@item[3,5,4]] }
  	
	  | /(xmove|xmv)\s/ <commit> xpath loc xpath
		{ [\&XML::XSH::Functions::move,@item[3,5,4],1] }
  	
	  | /(ls|list)\s/ xpath expression
		{ [\&XML::XSH::Functions::list,$item[2],$item[3]] }
  	
	  | /(ls|list)\s/ xpath
		{ [\&XML::XSH::Functions::list,$item[2],-1] }
  	
	  | /(ls|list)/
		{ [\&XML::XSH::Functions::list,[undef,'.'],1] }
  	
	  | /(exit|quit)/ <commit> optional_expression(?)
		{ [\&XML::XSH::Functions::quit,@{$item[3]}] }
  	
	  | /(remove|rm|prune|delete|del)\s/ <commit> xpath
		{ [\&XML::XSH::Functions::prune,$item[3]] }
  	
	  | /(map|sed)\s/ <commit> perl_code xpath
		{ [\&XML::XSH::Functions::perlmap,@item[4,3]] }
  	
	  | /(sort)\s/ <commit> block block perl_code nodelistvariable
		{ [\&XML::XSH::Functions::perlsort,@item[3..6]] }
  	
	  | /(close)\s/ <commit> expression
		{ [\&XML::XSH::Functions::close_doc,$item[3]] }
  	
	  | /(open-HTML|open_HTML)\s/ <commit> id_or_var /\s*=\s*/ filename
		{ [\&XML::XSH::Functions::open_doc,@item[3,5],'html'] }
  	
	  | /(open-PIPE|open_PIPE)\s/ <commit> id_or_var /\s*=\s*/ expression
		{ [\&XML::XSH::Functions::open_doc,@item[3,5],'pipe'] }
  	
	  | /(validate)/ <commit> optional_expression(?)
		{ [\&XML::XSH::Functions::validate_doc,@{$item[3]}] }
  	
	  | /(valid)/ <commit> optional_expression(?)
		{ [\&XML::XSH::Functions::valid_doc,@{$item[3]}] }
  	
	  | /(dtd)/ <commit> optional_expression(?)
		{ [\&XML::XSH::Functions::list_dtd,@{$item[3]}] }
  	
	  | /(enc)/ <commit> optional_expression(?)
		{ [\&XML::XSH::Functions::print_enc,@{$item[3]}] }
  	
	  | /(lcd|chdir)/ <commit> optional_expression(?)
		{ [\&XML::XSH::Functions::cd,@{$item[3]}] }
  	
	  | /(clone|dup)\s/ <commit> id_or_var /\s*=\s*/ expression
		{ [\&XML::XSH::Functions::clone,@item[3,5]] }
  	
	  | /(count|print_value|get)\s/ <commit> xpath
		{ [\&XML::XSH::Functions::print_count,$item[3]] }
  	
	  | /(perl|eval)\s/ <commit> perl_code
		{ [\&XML::XSH::Functions::print_eval,$item[3]] }
  	
	  | /(saveas|save-as|save_as)\s/ <commit> expression filename encoding_param(?)
		{ [\&XML::XSH::Functions::save_as,@item[3,4],@{$item[5]}] }
  	
	  | /(save-xinclude|save_xinclude)\s/ <commit> expression encoding_param(?)
		{ [\&XML::XSH::Functions::save_xinclude,$item[3],@{$item[4]}] }
  	
	  | /(save-HTML|save_HTML)\s/ <commit> expression filename encoding_param(?)
		{ [\&XML::XSH::Functions::save_as_html,@item[3,4],@{$item[5]}] }
  	
	  | /(save)\s/ <commit> expression encoding_param(?)
		{ [\&XML::XSH::Functions::save_as,$item[3],@{$item[4]}] }
  	
	  | /(files)/
		{ [\&XML::XSH::Functions::files] }
  	
	  | /(xslt|transform|xsl|xsltproc|process)\s/ <commit> expression filename expression xslt_params(?)
		{ [\&XML::XSH::Functions::xslt,@item[3,4,5],@{$item[6]}] }
  	
	  | /(insert|add)\s/ <commit> nodetype expression namespace(?) loc xpath
		{ [\&XML::XSH::Functions::insert,@item[3,4,7,6],$item[5][0],0] }
  	
	  | /(xinsert|xadd)\s/ <commit> nodetype expression namespace(?) loc xpath
		{ [\&XML::XSH::Functions::insert,@item[3,4,7,6],$item[5][0],1] }
  	
	  | /(help|\?)/ <commit> optional_expression(?)
		{ [\&XML::XSH::Functions::help,@{$item[3]}] }
  	
	  | /(exec|system)\s/ <commit> expression(s)
		{ [\&XML::XSH::Functions::sh,join(" ",@{$item[3]})] }
  	
	  | /(call)\s/ <commit> expression
		{ [\&XML::XSH::Functions::call,$item[3]] }
  	
	  | /(include|\.)\s/ <commit> filename
		{ [\&XML::XSH::Functions::include,$item[3]] }
  	
	  |( /(assign)\s/
	   )(?) variable '=' xpath
		{ [\&XML::XSH::Functions::xpath_assign,$item[2],$item[4]] }
  	
	  |( /(assign)\s/
	   )(?) nodelistvariable '=' xpath
		{ [\&XML::XSH::Functions::nodelist_assign,$item[2],$item[4]] }
  	
	  | variable
		{ [\&XML::XSH::Functions::print_var,$item[1]] }
  	
	  | /(variables|vars|var)/
		{ [\&XML::XSH::Functions::variables] }
  	
	  | /(print|echo)\s/ <commit> expression(s?)
		{ [\&XML::XSH::Functions::echo,@{$item[3]}] }
  	
	  | /(create|new)\s/ <commit> expression expression
		{ [\&XML::XSH::Functions::create_doc,@item[3,4]] }
  	
	  | /(defs)/ <commit>
		{ [\&XML::XSH::Functions::list_defs] }
  	
	  | /(select)\s/ <commit> expression
		{ [\&XML::XSH::Functions::set_local_xpath,[$item[3],"/"]] }
  	
	  | /(if)\s/ <commit> condition command
		{ [\&XML::XSH::Functions::if_statement,$item[3],[$item[4]]] }
  	
	  | /(unless)\s/ <commit> condition command
		{ [\&XML::XSH::Functions::unless_statement,$item[3],[$item[4]]] }
  	
	  | /(while)\s/ <commit> condition command
		{ [\&XML::XSH::Functions::while_statement,$item[3],[$item[4]]] }
  	
	  | /(foreach|for)\s/ <commit> condition command
		{ [\&XML::XSH::Functions::foreach_statement,$item[3],[$item[4]]] }
  	
	  | /(def|define)\s/ <commit> ID block
		{ [\&XML::XSH::Functions::def,$item[3],$item[4]] }
  	
	  | /(process-xinclude|process_xinclude|process-xincludes|process_xincludes|xinclude|xincludes|load_xincludes|load-xincludes|load_xinclude|load-xinclude)/ <commit> optional_expression(?)
		{ [\&XML::XSH::Functions::process_xinclude,@{$item[3]}] }
  	
	  | /(cd|chxpath)/ <commit> optional_xpath(?)
		{ [\&XML::XSH::Functions::set_local_xpath,@{$item[3]}] }
  	
	  | /(pwd)/
		{ [\&XML::XSH::Functions::print_pwd] }
  	
	  | /(locate)/ <commit> optional_xpath(?)
		{ [\&XML::XSH::Functions::locate,@{$item[3]}] }
  	
	  | /(xupdate)\s/ <commit> expression expression(?)
		{ [\&XML::XSH::Functions::xupdate,$item[3],@{$item[4]}] }
  	
	  | /(open)\s/ <commit> id_or_var /\s*=\s*/ filename
		{ [\&XML::XSH::Functions::open_doc,@item[3,5]] }
  	
	  | ID /\s*=\s*/ <commit> filename
		{ [\&XML::XSH::Functions::open_doc,@item[1,4]] }
  	
	  | /(fold)\s/ xpath expression(?)
		{ [\&XML::XSH::Functions::mark_fold,$item[2],@{$item[3]}] }
  	
	  | /(unfold)\s/ xpath
		{ [\&XML::XSH::Functions::mark_unfold,$item[2]] }
  	

  statement:
	   ( if
	  | unless
	  | while
	  | foreach
	  | def
	   )
		{ $item[1] }
  	
	  | <error>

  complex_command:
	    ';'
	  | command trail(?)
	  ( ';'
	  | ... /^\s*(}|\Z)/
	   )
		{ 
	  my $r=$item[1];
	  if (scalar(@{$item[2]})) {
	    if ($item[2][0][0] eq 'pipe') {
  	      $r=[\&XML::XSH::Functions::pipe_command,[$r],$item[2][0][1]]
	    } else {
   	      $r=[\&XML::XSH::Functions::string_pipe_command,[$r],$item[2][0][1]]
	    }
          }
	  $r
	 }
  	
	  | <error>

  statement_or_command:
	    statement
	  | complex_command

  block:
	    '{' <commit> statement_or_command(s) '}'
		{ [grep ref,@{$item[3]}] }
  	

  type:
	   

  TOKEN:
	    /\S+/

  STRING:
	    /([^'"\$\\ \t\n\r\|;\{\}]|\$[^{]|\$\{[^{}]*\}|]|\\.)+/

  single_quoted_string:
	    /\'([^\'\\]|\\\'|\\\\|\\[^\'\\])*\'/
		{ 
	  local $_=$item[1];
	  s/^\'|\'$//g;
	  s/\\([^\$])/$1/g;
	  $_;
	 }
  	

  double_quoted_string:
	    /\"([^\"\\]|\\.)*\"/
		{ 
	  local $_=$item[1];
	  s/^\"|\"$//g;
	  s/\\(.)/$1/g;
	  $_;
	 }
  	

  exp_part:
	    STRING
	  | exp_inline_count
	  | single_quoted_string
	  | double_quoted_string

  exp_inline_count:
	    /\${{([^}]|}[^}])*}}/

  expression:
	    exp_part <skip:""> expression(?)
		{ $item[1].join("",@{$item[3]}) }
  	

  ws:
	    /(\s|\n|#[^\n]*)+/

  optional_expression:
	    <skip:""> ws expression
		{ $item[3] }
  	

  optional_expressions:
	    <skip:""> ws expression(s)
		{ $item[3] }
  	

  optional_xpath:
	    <skip:""> ws xpath
		{ $item[3] }
  	

  enc_string:
	    expression

  ID:
	    /[a-zA-Z_][a-zA-Z0-9_]*/

  id_or_var:
	    ID
	  | variable

  filename:
	    expression

  xpath:
	    id_or_var <skip:""> /:(?!:)/ xp
		{ [$item[1],$item[4]] }
  	
	  | xp
		{ [undef,$item[1]] }
  	
	  | <error>

  xpcont:
	   ( xpfilters
	  | xpbrackets
	   ) <skip:""> xp(?)
		{ $item[1].join("",@{$item[3]}) }
  	

  xp:
	    xpsimple <skip:""> xpcont(?)
		{ $item[1].join("",@{$item[3]}) }
  	
	  | xpstring

  xpfilters:
	    xpfilter(s)
		{ join("",@{$item[1]}) }
  	

  xpfilter:
	    '[' xpinter ']'
		{ "[$item[2]]" }
  	

  xpbracket:
	    '(' xpinter ')'
		{ "($item[2])" }
  	

  xpbrackets:
	    xpbracket <skip:""> xpfilters(?)
		{ join "",$item[1],@{$item[3]} }
  	

  xpintercont:
	   ( xpfilters
	  | xpbrackets
	   ) <skip:""> xpinter(?)
		{ join("",$item[1],@{$item[3]}) }
  	

  xpinter:
	    xps <skip:""> xpintercont(?)
		{ join("",$item[1],@{$item[3]}) }
  	

  xps:
	    /([^][()'"]|'[^']*'|"[^"]*")*/

  xpstring:
	    /'[^']*'|"[^"]*"/

  xpsimple:
	    /[^]|"' [();]+/
	  | xpbrackets

  perl_expression:
	    expression

  variable:
	    '$' <skip:""> ID
		{ "$item[1]$item[3]" }
  	

  nodelistvariable:
	    '%' <skip:""> id_or_var
		{ $item[3] }
  	

  eof:
	    /^\Z/
		{ 1; }
  	

  startrule:
	    shell <commit> eof
		{ XML::XSH::Functions::run_commands($item[1]) }
  	
	  | statement_or_command(s) eof
		{ XML::XSH::Functions::run_commands($item[1]) }
  	

  trail:
	    '|>' <commit> variable
		{ ['var',$item[3]] }
  	
	  | '|' <commit> shline
		{ ['pipe',$item[3]] }
  	

  shline_nosc:
	    /([^;()\\"'\|]|\|[^>]|\\.|\"([^\"\\]|\\.)*\"|\'([^\'\\]|\\\'|\\\\|\\[^\'\\])*\')*/

  shline_inter:
	    /([^()\\"']|\\.|\"([^\"\\]|\\.)*\"|\'([^\'\\]|\\\'|\\\\|\\[^\'\\])*\')*/

  shline_bracket:
	    '(' shline_inter shline_bracket(?) shline_inter ')'
		{ join("",'(',$item[2],@{$item[3]},$item[4],')') }
  	

  shline:
	    shline_nosc shline_bracket(?) shline_nosc
		{ join("",$item[1],@{$item[2]},$item[3]) }
  	

  shell:
	    /!\s*/ /.*/
		{ [[\&XML::XSH::Functions::sh,$item[2]]] }
  	

  condition:
	    <perl_codeblock>
	  | xpath

  else_block:
	    /(else)\s/ <commit> block
		{ $item[3] }
  	

  if:
	    /(if)\s/ <commit> condition block else_block(?)
		{ [\&XML::XSH::Functions::if_statement,$item[3],$item[4],@{$item[5]}] }
  	

  unless:
	    /(unless)\s/ <commit> condition block else_block(?)
		{ [\&XML::XSH::Functions::unless_statement,$item[3],$item[4],@{$item[5]}] }
  	

  while:
	    /(while)\s/ <commit> condition block
		{ [\&XML::XSH::Functions::while_statement,$item[3],$item[4]] }
  	

  foreach:
	    /(foreach|for)\s/ <commit> condition block
		{ [\&XML::XSH::Functions::foreach_statement,$item[3],$item[4]] }
  	

  def:
	    /(def|define)\s/ <commit> ID block
		{ [\&XML::XSH::Functions::def,$item[3],$item[4]] }
  	

  xslt_params:
	    /(params|parameters)\s/ param(s)
		{ $item[2] }
  	

  param:
	    /[^=\s]+/ '=' expression
		{ [$item[1],$item[3]] }
  	

  nodetype:
	    /element|attribute|attributes|text|cdata|pi|comment|chunk|entity_reference/

  namespace:
	    /namespace\s/ expression
		{ $item[2] }
  	

  loc:
	    /after\s/
		{ "after" }
  	
	  | /before\s/
		{ "before" }
  	
	  | /(to|into|as child( of)?)\s/
		{ "as_child" }
  	
	  | /(replace|instead( of)?)\s/
		{ "replace" }
  	

  perl_code:
	    <perl_codeblock>
	  | perl_expression

  encoding_param:
	    /encoding\s/ expression
		{ $item[2] }
  	



_EO_GRAMMAR_

sub compile {
  Parse::RecDescent->Precompile($grammar,"XML::XSH::Parser");
}

sub new {
  return new Parse::RecDescent ($grammar);
}

1;

  