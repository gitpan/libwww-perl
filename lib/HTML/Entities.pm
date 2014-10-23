package HTML::Entities;

# $Id: Entities.pm,v 1.1 1995/09/05 23:03:51 aas Exp $

=head1 NAME

decode - Expand HTML entites in a string

encode - Encode chars in a string using HTML entities

=head1 SYNOPSIS

 require HTML::Entities;

 $a = "V&aring;re norske tegn b&oslash;r &#230res";
 HTML::Entities::decode($a);
 HTML::Entities::encode($a, "\200-\377");

=head1 DESCRIPTION

The HTML::Entities::decode() routine replace valid HTML entities found
in the string with the corresponding character.  The
HTML::Entities::encode() routine replace the characters specified by the
second argument with their entity representation.  The default set of
characters to expand are control chars, high bit chars and '<', '&', '>'
and '"'.

Both routines modify the string and return it.

=head1 COPYRIGHT

Copyright (c) 1995 Gisle Aas. All rights reserved.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 AUTHOR

Gisle Aas <aas@oslonett.no>

=cut


require Exporter;
@ISA = qw(Exporter);

@EXPORT_OK = qw(encode decode);

$VERSION = sprintf("%d.%02d", q$Revision: 1.1 $ =~ /(\d+)\.(\d+)/);
sub Version { $VERSION; }


%entity2char = (

 'lt'     => '<',
 'gt'     => '>',
 'amp'    => '&',
 'quot'   => '"',
 'nbsp'   => "\240",

 'Aacute' => '�',
 'Acirc'  => '�',
 'Agrave' => '�',
 'Aring'  => '�',
 'Atilde' => '�',
 'Auml'   => '�',
 'Ccedil' => '�',
 'ETH'    => '�',
 'Eacute' => '�',
 'Ecirc'  => '�',
 'Egrave' => '�',
 'Euml'   => '�',
 'Iacute' => '�',
 'Icirc'  => '�',
 'Igrave' => '�',
 'Iuml'   => '�',
 'Ntilde' => '�',
 'AElig'  => '�',
 'Oacute' => '�',
 'Ocirc'  => '�',
 'Ograve' => '�',
 'Oslash' => '�',
 'Otilde' => '�',
 'Ouml'   => '�',
 'THORN'  => '�',
 'Uacute' => '�',
 'Ucirc'  => '�',
 'Ugrave' => '�',
 'Uuml'   => '�',
 'Yacute' => '�',
 'aelig'  => '�',
 'aacute' => '�',
 'acirc'  => '�',
 'agrave' => '�',
 'aring'  => '�',
 'atilde' => '�',
 'auml'   => '�',
 'ccedil' => '�',
 'eacute' => '�',
 'ecirc'  => '�',
 'egrave' => '�',
 'eth'    => '�',
 'euml'   => '�',
 'iacute' => '�',
 'icirc'  => '�',
 'igrave' => '�',
 'iuml'   => '�',
 'ntilde' => '�',
 'oacute' => '�',
 'ocirc'  => '�',
 'ograve' => '�',
 'oslash' => '�',
 'otilde' => '�',
 'ouml'   => '�',
 'szlig'  => '�',
 'thorn'  => '�',
 'uacute' => '�',
 'ucirc'  => '�',
 'ugrave' => '�',
 'uuml'   => '�',
 'yacute' => '�',
 'yuml'   => '�',

 # Netscape extentions
 'reg'    => '�',
 'copy'   => '�',

);

# Make the oposite mapping
while (($entity, $char) = each(%entity2char)) {
    $char2entity{$char} = "&$entity;";
}

# Fill inn missing entities
for (0 .. 255) {
    next if exists $char2entity{chr($_)};
    $char2entity{chr($_)} = "&#$_;";
}


sub decode
{
    for (@_) {
	s/(&\#(\d+);?)/$2 < 256 ? chr($2) : $1/eg;
	s/(&(\w+);?)/$entity2char{$2} || $1/eg;
    }
    $_[0];
}

sub encode
{
    if (defined $_[1]) {
	$_[0] =~ s/([$_[1]])/$char2entity{$1}/g;
    } else {
	# Encode control chars, high bit chars and '<', '&', '>', '"'
	$_[0] =~ s/([^\n\t !#$%'-;=?-~])/$char2entity{$1}/g;
    }
    $_[0];
}

1;
