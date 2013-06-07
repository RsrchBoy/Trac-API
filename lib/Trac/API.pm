package Trac::API;

# ABSTRACT: A simple interface to Trac's JSON-RPC service

use v5.8;
use utf8;

use strict;
use warnings;

use Moose;
use namespace::autoclean;
use MooseX::AttributeShortcuts;
use MooseX::AlwaysCoerce;
use Moose::Util::TypeConstraints 'class_type';
use MooseX::Types::URI ':all';

use autobox::Core;
use autobox::Base64;
use autobox::JSON;

# debugging...
#use Smart::Comments '###';
#use Carp::Always::Color;

with 'MooseX::RelatedClasses' => {
    -version  => '0.005',
    name      => 'UserAgent',
    namespace => 'LWP',
};

=required url

The name of the trac server endpoint we're targeting.

=cut

has url => (
    is  => 'lazy',
    isa => Uri,
);

=lazy ua

Our constructed user-agent instance.

=cut

# TODO:  this should be allowed to be HTTP::Tiny, too
has ua => (
    is      => 'lazy',
    isa     => class_type('LWP::UserAgent'),
    builder => sub {
        my $self = shift @_;

        return $self->user_class->new(
            cookie_jar => {},
            keep_alive => 1,
            default_headers => {
                'Content-Type' => 'application/json',
                Authorization  => 'Basic ' . $self->auth_string,
            },
        );
    },
);

=required auth_string

The base64-encoded digest string to be used in HTTP basic authentication.  e.g.
(if you're using L<autobox::Base64>):

    auth_string => 'user:pass'->encode_base64

=method auth_string

Returns the set authorization string.

=cut

has auth_string => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

=attr current_id

Stores the id of the request last sent to the server.  This is an integer; new
values simply increment off the last value.

=method current_id

Returns the value of the last request sent to the server.

=cut

has current_id => (
    traits  => ['Counter'],
    is      => 'ro',
    isa     => 'Int',
    builder => sub { 0 },
    handles => {
        _next_id => [ inc => 1 ],
    },
);

=method call

Call a method on the trac server.

=cut

sub call {
    my ($self, $method, $args) = @_;

    ### $method
    ### $args
    my $res = $self->ua->get($self->url,
        Content => {
            method => $method,
            params => $args,
            id     => $self->next_id,
        },
    );

    ### $res
    confess $res->status_line
        unless $res->is_success;

    my $decoded = $res->content->decode_json;

    confess $decoded->{error}->encode_json
        if defined $decoded->{error};

    return $decoded->{result};
}

!!42;
__END__

=head1 SYNOPSIS

    use Moose;
    use namespace::autoclean;

    use Trac::API;

    my $trac = Trac::API->new(url => ..., auth_string => ...);
    $trac->call('ticket.assignAllMineToSomeoneElse', ...);

    # relax!

=head1 DESCRIPTION

A simple, in-the-works interface to the Trac JSON-RPC (generally comes along
with the XML-RPC) interface.

=cut
