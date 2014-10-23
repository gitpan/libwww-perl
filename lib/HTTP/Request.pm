package HTTP::Request;

# $Id: Request.pm,v 1.34 2003/10/24 10:25:16 gisle Exp $

require HTTP::Message;
@ISA = qw(HTTP::Message);
$VERSION = sprintf("%d.%02d", q$Revision: 1.34 $ =~ /(\d+)\.(\d+)/);

use strict;



sub new
{
    my($class, $method, $uri, $header, $content) = @_;
    my $self = $class->SUPER::new($header, $content);
    $self->method($method);
    $self->uri($uri);
    $self;
}


sub clone
{
    my $self = shift;
    my $clone = bless $self->SUPER::clone, ref($self);
    $clone->method($self->method);
    $clone->uri($self->uri);
    $clone;
}


sub method
{
    shift->_elem('_method', @_);
}


sub uri
{
    my $self = shift;
    my $old = $self->{'_uri'};
    if (@_) {
	my $uri = shift;
	if (!defined $uri) {
	    # that's ok
	}
	elsif (ref $uri) {
	    Carp::croak("A URI can't be a " . ref($uri) . " reference")
		if ref($uri) eq 'HASH' or ref($uri) eq 'ARRAY';
	    Carp::croak("Can't use a " . ref($uri) . " object as a URI")
		unless $uri->can('scheme');
	    $uri = $uri->clone;
	    unless ($HTTP::URI_CLASS eq "URI") {
		# Argh!! Hate this... old LWP legacy!
		eval { local $SIG{__DIE__}; $uri = $uri->abs; };
		die $@ if $@ && $@ !~ /Missing base argument/;
	    }
	}
	else {
	    $uri = $HTTP::URI_CLASS->new($uri);
	}
	$self->{'_uri'} = $uri;
    }
    $old;
}

*url = \&uri;  # legacy


sub as_string
{
    my $self = shift;
    my @result;
    #push(@result, "---- $self -----");
    my $req_line = $self->method || "[NO METHOD]";
    my $uri = $self->uri;
    $uri = (defined $uri) ? $uri->as_string : "[NO URI]";
    $req_line .= " $uri";
    my $proto = $self->protocol;
    $req_line .= " $proto" if $proto;

    push(@result, $req_line);
    push(@result, $self->headers_as_string);
    my $content = $self->content;
    if (defined $content) {
	push(@result, $content);
    }
    #push(@result, ("-" x 40));
    join("\n", @result, "");
}


1;

__END__

=head1 NAME

HTTP::Request - HTTP style request message

=head1 SYNOPSIS

 require HTTP::Request;
 $request = HTTP::Request->new(GET => 'http://www.example.com/');

and usually used like this:

 $ua = LWP::UserAgent->new;
 $response = $ua->request($request);

=head1 DESCRIPTION

C<HTTP::Request> is a class encapsulating HTTP style requests,
consisting of a request line, some headers, and a content body. Note
that the LWP library uses HTTP style requests even for non-HTTP
protocols.  Instances of this class are usually passed to the
request() method of an C<LWP::UserAgent> object.

C<HTTP::Request> is a subclass of C<HTTP::Message> and therefore
inherits its methods.  The following additional methods are available:

=over 4

=item $r = HTTP::Request->new( $method, $uri )

=item $r = HTTP::Request->new( $method, $uri, $header )

=item $r = HTTP::Request->new( $method, $uri, $header, $content )

Constructs a new C<HTTP::Request> object describing a request on the
object $uri using method $method.  The $method argument must be a
string.  The $uri argument can be either a string, or a reference
to a C<URI> object.  The optional $header argument should be a
reference to an C<HTTP::Headers> object.  The optional $content
argument should be a string of bytes.

=item $r->method

=item $r->method( $val )

This is used to get/set the method attribute.  The method should be a
short string like "GET", "HEAD", "PUT" or "POST".

=item $r->uri

=item $r->uri( $val )

This is used to get/set the uri attribute.  The $val can be a
reference to a URI object or a plain string.  If a string is given,
then it should be parseable as an absolute URI.

=item $r->header( $field )

=item $r->header( $field => $value )

This is used to get/set header values and it is inherited from
C<HTTP::Headers> via C<HTTP::Message>.  See L<HTTP::Headers> for
details and other similar methods that can be used to access the
headers.

=item $r->content

=item $r->content( $content )

This is used to get/set the content and it is inherited from the
C<HTTP::Message> base class.  See L<HTTP::Message> for details and
other methods that can be used to access the content.

Note that the content should be a string of bytes.  Strings in perl
can contain characters outside the range of a byte.  The C<Encode>
module can be used to turn such strings into a string of bytes.

=item $r->as_string

Method returning a textual representation of the request.
Mainly useful for debugging purposes. It takes no arguments.

=back

=head1 SEE ALSO

L<HTTP::Headers>, L<HTTP::Message>, L<HTTP::Request::Common>,
L<HTTP::Response>

=head1 COPYRIGHT

Copyright 1995-2001 Gisle Aas.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

