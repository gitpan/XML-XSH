# -*- cperl -*-
use Test;
BEGIN {
  @xsh_test=split /\n\n/, <<'EOF';
list;

list | wc 1>&2

count /;

insert element foo into /*;

count count(//foo)>0;

assign $bar=0;

count $bar=0;

while count(//foo)<10 { insert element "<foo bar='$bar\' count=${{count(//foo)}}" into /*; $bar=$bar+1 };

count count(//foo)=10;

count count(//foo[@bar="8"])=1;

count count(//foo[@count and @bar=string(@count)-1])>0;

perl { 1+1; };

exec list -l;

! echo -n " sh test: "; echo " (success)";

clone t=scratch;

list | wc 1>&2;

def myfunc { defs; encoding iso-8859-2; };

call myfunc;

files;

foreach scratch://foo { insert text "no. " into .; copy ./@bar after ./text() };

indent 1;

if count(//foo/text()[starts-with(.,'no. 8')])!=1 { eval die };

map $_=uc //foo/text();

unless count(//foo/text()[starts-with(.,'NO. 8')])=1 { eval die };

map { $_=join "",reverse split "",$_; } //foo;

count count(//oof)=10

if 1+1!=2 { eval die } else { unless (1+2!=3) { eval 1 } else { eval die } };

if 1+1=2 { unless 1+2=3 { eval die } else { eval 1 } } else { eval die };

test-mode; eval die;

run-mode;

move scratch://oof[not(@bar)] into t://foo[@bar='1'];

count scratch:count(/scratch/oof)=9;

count t:count(/scratch/foo/oof)=1;

remove t://oof;

count t:count(/scratch/foo/oof)=0;

select scratch;

count t:count(//foo)=10;

create new1 test

count count(//*)=1;

create new2
"<?xml version='1.0' encoding='iso-8859-1'?>
<!DOCTYPE root [
  <!ELEMENT root (#PCDATA | br)*>
  <!ATTLIST root id ID #REQUIRED>
  <!ELEMENT br EMPTY>
]>
<root id='root1'>
My test document <br/>is quite nice and <br/>simple.
</root>
"

count id('root1');
count //root;
count count(//br)=2;
count //text()[contains(.,'simple')];

dtd;

valid;

validate;

xinsert element silly after //br

count count(//br[./following-sibling::silly])=2

ls scratch:/ | cat 1>&2
ls t:/ | cat 1>&2
ls new1:/ | cat 1>&2
ls new2:/ | cat 1>&2
EOF

  plan tests => 4+@xsh_test;
}
END { ok(0) unless $loaded; }
use XML::XSH qw/&xsh &xsh_init &set_opt_q/;
$loaded=1;
ok(1);

($::RD_ERRORS,$::RD_WARN,$::RD_HINT)=(1,1,1);

$::RD_ERRORS = 1; # Make sure the parser dies when it encounters an error
$::RD_WARN   = 1; # Enable warnings. This will warn on unused rules &c.
$::RD_HINT   = 1; # Give out hints to help fix problems.

set_opt_q(0);
xsh_init();

print STDERR "\n";
ok(1);

print STDERR "\n";
ok ( XML::XSH::Functions::create_doc("scratch","scratch") );

print STDERR "\n";
ok ( XML::XSH::Functions::set_last_id("scratch") );

foreach (@xsh_test) {
  print STDERR "\n";
  ok( xsh($_) );
}