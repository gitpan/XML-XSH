#!/usr/bin/perl
# -*- cperl -*-

# $Id: xsh,v 1.8 2002/08/30 17:08:13 pajas Exp $

use FindBin;
use lib ("$FindBin::RealBin", "$FindBin::RealBin/../lib",
         "$FindBin::Bin","$FindBin::Bin/../lib",
	 "$FindBin::Bin/lib", "$FindBin::RealBin/lib"
	);

package main;

use strict;

use Getopt::Std;
use vars qw/$opt_q $opt_w $opt_i $opt_h $opt_V $opt_E $opt_e $opt_d $opt_c $opt_s
            $opt_f $opt_g/;
use vars qw/$VERSION $REVISION/;

use IO::Handle;

use XML::XSH qw(&xsh_set_output &xsh_get_output &xsh &xsh_init
		&xsh_pwd &xsh_local_id &set_opt_q &set_opt_d
		&set_opt_c);

require Term::ReadLine if $opt_i;

BEGIN {
  getopts('scqgwdfhViE:e:');
  $VERSION='0.9';
  $REVISION='$Revision: 1.8 $';
  $ENV{PERL_READLINE_NOWARN}=1;
}

if ($opt_h) {
  print "Usage: $0 [options] <commands>\n";
  print "or $0 -h or $0 -V\n\n";
  print "   -g   use XML::GDOME instead of XML::LibXML\n";
  print "   -e   output encoding (default is the document encoding)\n";
  print "   -E   query encoding (default is the output encoding)\n\n";
  print "   -q   quiet\n\n";
  print "   -i   interactive\n\n";
  print "   -f   ignore ~/.xshrc\n\n";
  print "   -d   print debug messages\n\n";
  print "   -c   compile (parse) only and report errors\n\n";
  print "   -s   try to prevent XML::LibXML segmentation faults\n\n";
  print "   -w   start with validation 0 and load_ext_dtd 0\n\n";
  print "   -V   print version\n\n";
  print "   -h   help\n\n";
  exit 1;
}

if ($opt_V) {
  my $rev=$REVISION;
  $rev=~s/\s*\$//g;
  print "$XML::XSH::Functions::VERSION/$VERSION ($rev)\n";
  exit 1;
}

$::RD_ERRORS = 1; # Make sure the parser dies when it encounters an error
$::RD_WARN   = 1; # Enable warnings. This will warn on unused rules &c.
$::RD_HINT   = 1; # Give out hints to help fix problems.

my $module;
if ($opt_g) {
  $module="XML::XSH::GDOMECompat";
} else {
  $module="XML::XSH::LibXMLCompat"
}

xsh_init($module);

set_opt_q($opt_q);
set_opt_d($opt_d);
set_opt_c($opt_c);

if ($opt_w) {
  XML::XSH::Functions::set_validation(0);
  XML::XSH::Functions::set_load_ext_dtd(0);
}

$XML::XSH::Functions::SIGSEGV_SAFE=$opt_s;

my $doc=XML::XSH::Functions::create_doc("scratch","scratch");
#XML::XSH::Functions::set_last_id("scratch");
XML::XSH::Functions::set_local_xpath(['scratch','/']);

my $string=join " ",@ARGV;
my $l;

eval {
  if (-r "$ENV{HOME}/.xshrc") {
    open INI,"$ENV{HOME}/.xshrc" || die "cannot open $ENV{HOME}/.xshrc";
    xsh(join("",<INI>));
    close INI;
  }
};
if ($@) {
  print STDERR "Error occured while reading ~/.xshrc\n";
  print STDERR "$@\n";
}

if ($opt_i) {
  $SIG{INT}=sub {
    xsh_get_output()->print("\nCtrl-C pressed. Type exit to exit.\n");
    xsh_get_output()->print(prompt());
  };
  $XML::XSH::Functions::TRAP_SIGINT=1;
  unless ($opt_q) {
    my $rev=$REVISION;
    $rev=~s/\s*\$//g;
    $rev=" xsh - XML Editing Shell version $XML::XSH::Functions::VERSION/$VERSION ($rev)\n";
    print STDERR "-"x length($rev),"\n";
    print STDERR $rev;
    print STDERR "-"x length($rev),"\n\n";
    print STDERR "Copyright (c) 2002 Petr Pajas.\n";
    print STDERR "This is free software, you may use it and distribute it under\n";
    print STDERR "either the GNU GPL Version 2, or under the Perl Artistic License.\n";
  }
}

if ($string) {
  print "xsh> $string\n" if ($opt_i and not $opt_q);
  xsh($string);
  print "\n" if ($opt_i and not $opt_q);
}

if ($opt_i) {
  my $term;
  $term = new Term::ReadLine('xsh');
  $XML::XSH::Functions::_on_exit=
    [sub { 
       my ($exit_code,$term)=@_;
       eval {
	 print STDERR "saving $ENV{HOME}/.xsh_history\n";
	 open HIST,"> $ENV{HOME}/.xsh_history" || die "cannot open $ENV{HOME}/.xsh_history";
	 print HIST join("\n",@readline::rl_History),"\n";
	 close HIST;
       };
       if ($@) {
	 print STDERR "Error occured while writing to ~/.xsh_history\n";
	 print STDERR "$@\n";
       }
     },$term
    ];

  eval {
    if (-r "$ENV{HOME}/.xsh_history") {
      open HIST,"$ENV{HOME}/.xsh_history";
      $term->addhistory(map { chomp; $_ } <HIST>);
      close HIST;
    }
  };
  if ($@) {
    print STDERR "Error occured while writing to ~/.xsh_history\n";
    print STDERR "$@\n";
  }

  XML::XSH::Completion::cpl();
  if ($term->ReadLine eq "Term::ReadLine::Gnu") {
    my $attribs = $term->Attribs;
    $attribs->{attempted_completion_function} = \&XML::XSH::Completion::gnu_cpl;
  } else {
    $readline::rl_completion_function =
      $readline::rl_completion_function = 'XML::XSH::Completion::cpl';
  }

  xsh_set_output($term->OUT) if ($term->OUT);
  unless ("$opt_q") {
    print STDERR "Using terminal type: ",$term->ReadLine,"\n";
      print STDERR "Hint: Type `help' or `help | less' to get more help.\n";
  }
  while (defined ($l = $term->readline(prompt()))) {
    while ($l=~/\\+\s*$/) {
      $l=~s/\\+\s*$//;
      $l .= $term->readline('> ');
    }
    if ($l=~/\S/) {
      xsh($l);
      $term->addhistory($l);
    }
  }

} elsif ($string eq "") {

  xsh(join "",<STDIN>);
}

print STDERR "Good bye!\n" if $opt_i and not "$opt_q";

sub prompt {
  return 'xsh '.xsh_local_id().":".xsh_pwd().'> ';
}
