# $Id: Completion.pm,v 1.5 2002/10/22 16:48:32 pajas Exp $

package XML::XSH::Completion;

use XML::XSH::CompletionList;
use strict;

sub cpl {
  my($word,$line,$pos) = @_;
  if ($line=~/^\s*[^=\s]*$/) {
     return grep { index($_,$word)==0 } @XML::XSH::CompletionList::XSH_COMMANDS;
  } else {
    return eval { map { s:\@$::; $_ } readline::rl_filename_list($_[0]); };
  }
}

sub gnu_cpl {
    my($text, $line, $start, $end) = @_;
    my(@perlret);
    if ($line=~/^\s*[^=\s]*$/) {
      @perlret = grep { index($_,$text)==0 } @XML::XSH::CompletionList::XSH_COMMANDS;
    } else {
      eval {
	@perlret = map { s:\@$::; $_ } Term::ReadLine::GNU::XS::rl_filename_list($_[0]);
      };
    }

    # find longest common match. Can anybody show me how to peruse
    # T::R::Gnu to have this done automatically? Seems expensive.
    return () unless @perlret;
    my($newtext) = $text;
    for (my $i = length($text)+1;;$i++) {
        last unless length($perlret[0]) && length($perlret[0]) >= $i;
        my $try = substr($perlret[0],0,$i);
        my @tries = grep {substr($_,0,$i) eq $try} @perlret;
        # warn "try[$try]tries[@tries]";
        if (@tries == @perlret) {
            $newtext = $try;
        } else {
            last;
        }
    }
    ($newtext,@perlret);
}

1;

