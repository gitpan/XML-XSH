# $Id: XSH.pm,v 1.2 2002/03/08 18:29:49 pajas Exp $

package XML::XSH;

use strict;
use vars qw(@EXPORT_OK @ISA $VERSION);

use Exporter;
use XML::XSH::Functions qw(:default);
use XML::XSH::Completion;

BEGIN {
  $VERSION   = '1.0';
  @ISA       = qw(Exporter);
  @EXPORT_OK = @XML::XSH::Functions::EXPORT_OK;
}

1;
