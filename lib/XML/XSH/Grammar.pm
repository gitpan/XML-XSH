# This file was automatically generated from src/xsh_grammar.xml on 
# Fri Mar  8 18:58:17 2002


package XML::XSH::Grammar;

use strict;
use Parse::RecDescent;
use vars qw/$grammar/;

$Parse::RecDescent::skip = '(\s|\n|#[^\n]*)*';
$grammar=<<'_EO_GRAMMAR_';

  
  TOKEN:
	    /\S+/

  STRING:
	    /([^'"\$\\ \t\n\r|;]|\$[^{]|\$\{[^{]|]|\\.)+/

  single_quoted_string:
	    /\'([^\'\\]|\\\'|\\\\|\\[^\'\\])*\'/
		{ 
       local $_=$item[1];
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
  	

  exp_inline_count:
	    /\${{([^}]|}[^}])*}}/

  exp_part:
	    STRING
	  | exp_inline_count
	  | single_quoted_string
	  | double_quoted_string

  expressions:
	    expression expressions
		{ [$item[1],@{$item[2]}] }
  	
	  | expression
		{ [$item[1]] }
  	

  expression:
	    exp_part <skip:""> expression
		{ "$item[1]$item[3]" }
  	
	  | exp_part
		{ $item[1] }
  	

  enc_string:
	    expression

  ID:
	    /[a-zA-Z_][a-zA-Z0-9_]*/

  filename:
	    expression

  xpath:
	    ID ':' xp
		{ [@item[1,3]] }
  	
	  | xp
		{ [undef, $item[1]] }
  	
	  | <error>

  xp:
	    xpsimple <skip:"">
	  ( xpfilters
	  | xpbrackets
	   ) <skip:""> xp
		{ "$item[1]$item[3]$item[5]" }
  	
	  | xpsimple <skip:"">
	  ( xpfilters
	  | xpbrackets
	   )
		{ "$item[1]$item[3]" }
  	
	  | xpsimple
	  | xpstring

  xpfilters:
	    xpfilter <skip:""> xpfilters
		{ "$item[1]$item[3]" }
  	
	  | xpfilter

  xpfilter:
	    '[' xpinter ']'
		{ "[$item[2]]" }
  	

  xpbracket:
	    '(' xpinter ')'
		{ "($item[2])" }
  	

  xpbrackets:
	    xpbracket <skip:""> xpfilters
		{ "$item[1]$item[3]" }
  	
	  | xpbracket

  xpinter:
	    xps
	  ( xpfilters
	  | xpbrackets
	   ) <skip:""> xpinter
		{ "$item[1]$item[2]$item[4]" }
  	
	  | xps

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
  	

  eof:
	    /$/
		{ 1; }
  	

  startrule:
	    statement eof
		{ $item[1] }
  	
	  | <error>

  pipe:
	    command '|' cmdline
		{ [[\&XML::XSH::Functions::pipe_command,$item[1],$item[3]]] }
  	

  statement:
	    commands
		{ XML::XSH::Functions::run_commands($item[1]) }
  	
	  | <error:error while parsing line $thisline near $text>

  shell:
	    /!\s*/ cmdline
		{ [[\&XML::XSH::Functions::sh,$item[2]]] }
  	

  cmdline:
	    /[^\n]*(\n|$)/
		{ chomp($item[1]); $item[1] }
  	

  option:
	    quiet
	  | verbose
	  | test_mode
	  | run_mode
	  | debug
	  | nodebug
	  | version
	  | validation
	  | parser_expands_entities
	  | keep_blanks
	  | pedantic_parser
	  | complete_attributes
	  | indent
	  | parser_expands_xinclude
	  | load_ext_dtd
	  | encoding
	  | query_encoding

  quiet:
	    /(quiet)/
		{ [\&XML::XSH::Functions::set_opt_q,1] }
  	

  verbose:
	    /(verbose)/
		{ [\&XML::XSH::Functions::set_opt_q,0] }
  	

  test_mode:
	    /(test-mode)/
		{ ["test-mode"] }
  	

  run_mode:
	    /(run-mode)/
		{ ["run-mode"] }
  	

  debug:
	    /(debug)/
		{ [\&XML::XSH::Functions::set_opt_d,1] }
  	

  nodebug:
	    /(nodebug)/
		{ [\&XML::XSH::Functions::set_opt_d,0] }
  	

  version:
	    /(version)/
		{ [\&XML::XSH::Functions::print_version,0] }
  	

  validation:
	    /(validation)\s/ expression
		{ [\&XML::XSH::Functions::set_validation,$item[2]] }
  	

  parser_expands_entities:
	    /(parser_expands_entities)\s/ expression
		{ [\&XML::XSH::Functions::set_expand_entities,$item[2]] }
  	

  keep_blanks:
	    /(keep_blanks)\s/ expression
		{ [\&XML::XSH::Functions::set_keep_blanks,$item[2]] }
  	

  pedantic_parser:
	    /(pedantic_parser)\s/ expression
		{ [\&XML::XSH::Functions::set_pedantic_parser,$item[2]] }
  	

  complete_attributes:
	    /(complete_attributes)\s/ expression
		{ [\&XML::XSH::Functions::set_complete_attributes,$item[2]] }
  	

  indent:
	    /(indent)\s/ expression
		{ [\&XML::XSH::Functions::set_indent,$item[2]] }
  	

  parser_expands_xinclude:
	    /(parser_expands_xinclude)\s/ expression
		{ [\&XML::XSH::Functions::set_expand_xinclude,$item[2]] }
  	

  load_ext_dtd:
	    /(load_ext_dtd)\s/ expression
		{ [\&XML::XSH::Functions::set_expand_xinclude,$item[2]] }
  	

  encoding:
	    /(encoding)\s/ expression
		{ [\&XML::XSH::Functions::set_encoding,$item[2]] }
  	

  query_encoding:
	    /(query-encoding)\s/ expression
		{ [\&XML::XSH::Functions::set_qencoding,$item[2]] }
  	

  cmd_or_pipe:
	    shell
	  | pipe
	  | command

  commands:
	    command ';' commands
		{ [ @{$item[1]},@{$item[3]} ] }
  	
	  |( pipe
	  | shell
	   ) commands
		{ [ @{$item[1]},@{$item[2]} ] }
  	
	  | cmd_or_pipe ';'
		{ $item[1] }
  	
	  | cmd_or_pipe

  block:
	    '{' commands '}'
		{ $item[2] }
  	

  command:
	   ( copy_command
	  | xcopy_command
	  | move_command
	  | xmove_command
	  | list_command
	  | exit_command
	  | prune_command
	  | map_command
	  | close_command
	  | open_command
	  | validate_command
	  | valid_command
	  | list_dtd_command
	  | print_enc_command
	  | cd_command
	  | clone_command
	  | count_command
	  | eval_command
	  | save_command
	  | saveas_command
	  | files_command
	  | xslt_command
	  | insert_command
	  | xinsert_command
	  | help_command
	  | exec_command
	  | call_command
	  | include_command
	  | assign_command
	  | print_var_command
	  | var_command
	  | print_command
	  | create_command
	  | list_defs_command
	  | select_command
	  | option
	  | if
	  | unless
	  | while
	  | foreach
	  | def
	  | process_xinclude_command
	   )
		{ [$item[1]] }
  	

  command_block:
	   ( cmd_or_pipe
	  | block
	   )

  if:
	    /(if)\s/ xpath
	  ( cmd_or_pipe
	  | block
	   ) /else\s/
	  ( cmd_or_pipe
	  | block
	   )
		{ [\&XML::XSH::Functions::if_statement,$item[2],$item[3],$item[5]] }
  	
	  | /(if)\s/ xpath
	  ( cmd_or_pipe
	  | block
	   )
		{ [\&XML::XSH::Functions::if_statement,$item[2],$item[3]] }
  	

  unless:
	    /(unless)\s/ xpath
	  ( cmd_or_pipe
	  | block
	   ) /else\s/
	  ( cmd_or_pipe
	  | block
	   )
		{ [\&XML::XSH::Functions::unless_statement,$item[2],$item[3],$item[5]] }
  	
	  | /(unless)\s/ xpath
	  ( cmd_or_pipe
	  | block
	   )
		{ [\&XML::XSH::Functions::unless_statement,$item[2],$item[3]] }
  	

  while:
	    /(while)\s/ xpath command_block
		{ [\&XML::XSH::Functions::while_statement,$item[2],$item[3]] }
  	

  foreach:
	    /(foreach)\s/ xpath command_block
		{ [\&XML::XSH::Functions::foreach_statement,$item[2],$item[3]] }
  	

  def:
	    /(def|define)\s/ ID command_block
		{ [\&XML::XSH::Functions::def,$item[2],$item[3]] }
  	

  assign_command:
	    /(assign)\s/ variable '=' xpath
		{ [\&XML::XSH::Functions::xpath_assign,$item[2],$item[4]] }
  	
	  | variable '=' xpath
		{ [\&XML::XSH::Functions::xpath_assign,$item[1],$item[3]] }
  	

  print_var_command:
	    variable
		{ [\&XML::XSH::Functions::print_var,$item[1]] }
  	

  list_defs_command:
	    /(defs)/
		{ [\&XML::XSH::Functions::list_defs] }
  	

  include_command:
	    /(include|\.)\s/ filename
		{ [\&XML::XSH::Functions::include,$item[2]] }
  	

  call_command:
	    /(call)\s/ ID
		{ [\&XML::XSH::Functions::call,$item[2]] }
  	

  help_command:
	    /(help|\?)\s/ expression
		{ [\&XML::XSH::Functions::help,$item[2]] }
  	
	  | /(help|\?)/
		{ [\&XML::XSH::Functions::help] }
  	

  exec_command:
	    /(exec|system)\s/ expressions
		{ [\&XML::XSH::Functions::sh,join(" ",@{$item[2]})] }
  	

  xslt_command:
	    /(xslt|transform|xsl|xsltproc|process)\s/ ID filename ID /(params|parameters)\s/ paramlist
		{ [\&XML::XSH::Functions::xslt,@item[2,3,4,6]] }
  	
	  | /(xslt|transform|xsl|xsltproc|process)\s/ ID filename ID
		{ [\&XML::XSH::Functions::xslt,@item[2,3,4]] }
  	

  paramlist:
	    param paramlist
		{ [@{$item[1]},@{$item[2]}] }
  	
	  | param

  param:
	    /[^=\s]+/ '=' expression
		{ [$item[1],$item[3]] }
  	

  files_command:
	    /(files)/
		{ [\&XML::XSH::Functions::files] }
  	

  var_command:
	    /(variables|var|vars)/
		{ [\&XML::XSH::Functions::variables] }
  	

  copy_command:
	    /(copy|cp)\s/ xpath loc xpath
		{ [\&XML::XSH::Functions::copy,@item[2,4,3]] }
  	

  xcopy_command:
	    /(xcopy|xcp)\s/ xpath loc xpath
		{ [\&XML::XSH::Functions::copy,@item[2,4,3],1] }
  	

  cd_command:
	    /(cd|chdir)\s/ filename
		{ [\&XML::XSH::Functions::cd,$item[2]] }
  	
	  | /(cd|chdir)/
		{ [\&XML::XSH::Functions::cd] }
  	

  insert_command:
	    /(insert|add)\s/ nodetype expression loc xpath
		{ [\&XML::XSH::Functions::insert,@item[2,3,5,4],undef,0] }
  	
	  | /(insert|add)\s/ nodetype expression namespace loc xpath
		{ [\&XML::XSH::Functions::insert,@item[2,3,6,5,4],0] }
  	

  xinsert_command:
	    /(xinsert|xadd)\s/ nodetype expression loc xpath
		{ [\&XML::XSH::Functions::insert,@item[2,3,5,4],undef,1] }
  	
	  | /(xinsert|xadd)\s/ nodetype expression namespace loc xpath
		{ [\&XML::XSH::Functions::insert,@item[2,3,6,5,4],1] }
  	

  nodetype:
	    /element|attribute|attributes|text|cdata|pi|comment|chunk/

  namespace:
	    /namespace\s/ expression
		{ $item[2] }
  	

  loc:
	    'after'
	  | 'before'
	  | 'to'
		{ "as_child" }
  	
	  | 'into'
		{ "as_child" }
  	
	  | 'as child of'
		{ "as_child" }
  	
	  | 'as child'
		{ "as_child" }
  	
	  | 'replace'
	  | 'instead of'
		{ "replace" }
  	
	  | 'instead'
		{ "replace" }
  	

  move_command:
	    /(move|mv)\s/ xpath loc xpath
		{ [\&XML::XSH::Functions::move,@item[2,4,3]] }
  	

  xmove_command:
	    /(xmove_command|xmv)\s/ xpath loc xpath
		{ [\&XML::XSH::Functions::move,@item[2,4,3],1] }
  	

  clone_command:
	    /(clone|dup)\s/ ID /\s*=\s*/ ID
		{ [\&XML::XSH::Functions::clone,@item[2,4]] }
  	

  list_command:
	    /(list|ls)\s/ xpath
		{ [\&XML::XSH::Functions::list,$item[2]] }
  	
	  | /(list|ls)/
		{ [\&XML::XSH::Functions::list] }
  	

  count_command:
	    /(count)\s/ xpath
		{ [\&XML::XSH::Functions::print_count,$item[2]] }
  	

  perl_code:
	    <perl_codeblock>
	  | perl_expression

  eval_command:
	    /(eval|perl)\s/ perl_code
		{ [\&XML::XSH::Functions::print_eval,$item[2]] }
  	

  prune_command:
	    /(remove|rm|prune|delete|del)\s/ xpath
		{ [\&XML::XSH::Functions::prune,$item[2]] }
  	

  print_command:
	    /(print|echo)\s/ expressions
		{ [\&XML::XSH::Functions::echo,@{$item[2]}] }
  	
	  | /(print|echo)/
		{ [\&XML::XSH::Functions::echo] }
  	

  map_command:
	    /(map|sed)\s/ perl_code xpath
		{ [\&XML::XSH::Functions::perlmap,@item[3,2]] }
  	

  close_command:
	    /(close)\s/ ID
		{ [\&XML::XSH::Functions::close_doc,$item[2]] }
  	

  select_command:
	    /(select)\s/ ID
		{ [\&XML::XSH::Functions::set_last_id,$item[2]] }
  	

  open_command:
	    /(open)\s/ ID /\s*=\s*/ filename
		{ [\&XML::XSH::Functions::open_doc,@item[2,4]] }
  	
	  | ID /\s*=\s*/ filename
		{ [\&XML::XSH::Functions::open_doc,@item[1,3]] }
  	

  create_command:
	    /(create|new)\s/ ID expression
		{ [\&XML::XSH::Functions::create_doc,@item[2,3]] }
  	

  save_command:
	    /(save)\s/ ID /encoding\s/ expression
		{ [\&XML::XSH::Functions::save_as,$item[2],$item[4]] }
  	
	  | /(save)\s/ ID
		{ [\&XML::XSH::Functions::save_as,$item[2]] }
  	

  saveas_command:
	    /(saveas)\s/ ID filename /encoding\s/ expression
		{ [\&XML::XSH::Functions::save_as,@item[2,3,5]] }
  	
	  | /(saveas)\s/ ID filename
		{ [\&XML::XSH::Functions::save_as,@item[2,3]] }
  	

  list_dtd_command:
	    /(dtd)\s/ ID
		{ [\&XML::XSH::Functions::list_dtd,$item[2]] }
  	
	  | /(dtd)/
		{ [\&XML::XSH::Functions::list_dtd,undef] }
  	

  print_enc_command:
	    /(print_enc_command)\s/ ID
		{ [\&XML::XSH::Functions::print_enc,$item[2]] }
  	
	  | /(print_enc_command)/
		{ [\&XML::XSH::Functions::print_enc,undef] }
  	

  validate_command:
	    /(validate)\s/ ID
		{ [\&XML::XSH::Functions::validate_doc,$item[2]] }
  	
	  | /(validate)/
		{ [\&XML::XSH::Functions::validate_doc,undef] }
  	

  valid_command:
	    /(valid)\s/ ID
		{ [\&XML::XSH::Functions::valid_doc,$item[2]] }
  	
	  | /(valid)/
		{ [\&XML::XSH::Functions::valid_doc,undef] }
  	

  exit_command:
	    /(exit|quit)\s/ expression
		{ [\&XML::XSH::Functions::quit,$item[2]] }
  	
	  | /(exit|quit)/
		{ [\&XML::XSH::Functions::quit,0] }
  	

  process_xinclude_command:
	    /(process_xinclude|process_xincludes|xinclude|xincludes|load_xincludes|load_xinclude)\s/ ID
		{ [\&XML::XSH::Functions::process_xinclude,$item[2]] }
  	
	  | /(process_xinclude|process_xincludes|xinclude|xincludes|load_xincludes|load_xinclude)/
		{ [\&XML::XSH::Functions::process_xinclude,undef] }
  	



_EO_GRAMMAR_

sub compile {
  Parse::RecDescent->Precompile($grammar,"XML::XSH::Parser");
}

sub new {
  return new Parse::RecDescent ($grammar);
}

1;

  