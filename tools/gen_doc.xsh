# xsh

open x = xsh_grammar.xml;

validation 0;

create d '<!DOCTYPE article PUBLIC "-//OASIS//DTD DocBook XML V4.1.2//EN" "file:///home/pajas/share/sgml/dtd/docbookx/docbookx.dtd">
<article>
<title>XSH Reference</title>
<section id="intro">
  <title>Preliminary Remarks</title>
</section>
<section id="commands">
  <title>Command Reference</title>
</section>
<section id="types">
  <title>Type Reference</title>
</section>
</article>';

xcopy x:/recdescent-xml/description/node() into d:/article/section[@id='intro'];

foreach { qw(command type) } {
  print "FILLING: ${__}s"; print "";
  %sec=d:/article/section[@id='${__}s'];
  if ('$__'='type') $__='argtype';
  foreach x:(//rule[@type='$__']) {
    $ref=string(@id);

    cd x:id('$ref');
    # TITLE
    add element "section id='$ref'" into %sec;

    %section=%sec/section[last()];

    if (./documentation/title) {
      xcopy ./documentation/title into %section;
    } else {
      add chunk "<title>${{string(@name)}}</title>" into %section;
    }
    map { s/\s+argument\s+type//i; $_=lcfirst } %section/title/text();


    #USAGE
    if (./documentation/usage) {
      add chunk "<simplesect><title>Usage</title></simplesect>" into %section;
      foreach (./documentation/usage) {
	add element para into %section/simplesect[last()];
      }
      copy ./documentation/usage into %section/simplesect[last()]/para;
      map { $_='literal' } %section/simplesect[last()]/para/usage;
    }

    #ALIASES
    if (./aliases) {
      add chunk "<simplesect><title>Aliases</title><para><literal> </literal></para></simplesect>" into %section;
      foreach (./aliases/alias) {
	copy ./@name after %section/simplesect[last()]/para/literal/text()[last()];
	if (following-sibling::alias) {
	  add text ", " after %section/simplesect[last()]/para/literal/text()[last()];;
	}
      }
    }

    #DESCRIPTION
    if (./documentation/description) {
      add chunk "<simplesect><title>Description</title></simplesect>" into %section;
      xcopy ./documentation/description/node() into %section/simplesect[last()];
    }

    #SEE ALSO
    if (./documentation/see-also) {
      add chunk "<simplesect><title>See Also</title><para/></simplesect>" into %section;
      foreach (./documentation/see-also/ruleref) {
	add element "<xref linkend='${{string(@ref)}}'/>" into %section/simplesect[last()]/para;
	if (following-sibling::ruleref) {
	  add text ", " into %section/simplesect[last()]/para;
	}
      }
    }
  }
};

map { $_='programlisting' } d://code;
foreach d://xref {
  map { $_='link' } .;
  $linkend=string(@linkend);
  if x:id('$linkend')/@name { assign $content=x:string(id('$linkend')/@name) }
    else { assign $content=x:string(id('$linkend')/@id) }
  print "$linkend -- $content";
  insert text $content into .;
};

indent 1;

saveas d xsh_reference.xml;
