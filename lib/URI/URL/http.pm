package URI::URL::http;
require URI::URL::_generic;
@ISA = qw(URI::URL::_generic);

sub default_port { 80 }

require Carp;

*user     = \&URI::URL::bad_method;
*password = \&URI::URL::bad_method;


# @ISA = qw(AutoLoader)      # This comment is needed by AutoSplit.
sub keywords;
sub query_form;
1;
__END__

# Note that the following two methods does not return the old
# value if they are used to set a new value.
# The risk of croaking is to high :-)

# Handle ...?dog+bones type of query
sub keywords {
    my $self = shift;
    $old = $self->{'query'};
    if (@_) {
	# Try to set query string
	$self->equery(join('+', map { URI::Escape::uri_escape($_, $URI::URL::reserved . "+") } @_));
	return undef;
    }
    return undef unless defined $old;
    Carp::croak("Query is not keywords") if $old =~ /=/;
    map { URI::Escape::uri_unescape($_) } split(/\+/, $old);
}

# Handle ...?foo=bar&bar=foo type of query
sub query_form {
    my $self = shift;
    $old = $self->{'query'};
    if (@_) {
	# Try to set query string
	my @query;
	my($key,$val);
	while (($key,$val) = splice(@_, 0, 2)) {
	    for ($key, $val) {
		$_ = '' unless defined;
		$_ = URI::Escape::uri_escape($_, $URI::URL::reserved);
	    }
	    push(@query, "$key=$val");
	}
	$self->equery(join('&', @query));
	return undef;
    }
    return undef unless defined $old;
    return () unless length $old;
    Carp::croak("Query is not a form") unless $old =~ /=/;
    map { URI::Escape::uri_unescape($_) }
	 map { split(/=/, $_, 2)} split(/&/, $old);
}

1;
