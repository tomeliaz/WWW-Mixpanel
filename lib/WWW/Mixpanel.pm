package WWW::Mixpanel;

BEGIN {
  $WWW::Mixpanel::VERSION = '0.01';
}

use strict;
use warnings;
use LWP::UserAgent;
use JSON::Any;
use MIME::Base64;
use JSON::Any;
use Carp;

my $ua = LWP::UserAgent->new;
$ua->timeout(30);
$ua->env_proxy;

my $json = JSON::Any->new;

sub new {
  my ( $class, $token, $use_ssl ) = @_;

  croak "You must provide your API token." unless $token;

  $use_ssl ||= 0;
  $use_ssl = 1 if $use_ssl;

  bless { token => $token, use_ssl => $use_ssl }, $class;
}

sub track {
  my ( $self, %params ) = @_;

  my $event = delete $params{event};

  croak "You must provide an event name" unless $event;

  $params{time} = $params{time} || time();
  $params{token} = $self->{token};

  my $data = { event      => $event,
               properties => \%params, };

  my $res = $ua->post( $self->{use_ssl}
                       ? 'https://api.mixpanel.com/track/'
                       : 'http://api.mixpanel.com/track/',
                       { 'data' => encode_base64( $json->to_json($data), '' ) } );

  if ( $res->is_success ) {
    if ( $res->content == 1 ) {
      return 1;
    }
    else {
      croak "Failure from api: " . $res->content;
    }
  }
  else {
    croak "Failed sending event: " . $self->_res($res);
  }
}

sub _res {
  my ( $self, $res ) = @_;

  if ( $res->code == 500 ) {
    return "Mixpanel service error. The service might be down.";
  }
  else {
    return "Unknown error. " . $res->message;
  }
}

1;

__END__

=pod

=head1 SYNOPSIS

  use WWW::Mixpanel;
  my $mp = WWW::Mixpanel->new( '1827378adad782983249287292a', 1 );
  $mp->track(event => 'login', distinct_id => 'username', mp_source => 'twitter');

=head1 DESCRIPTION

The WWW::Mixpanel module is a young implementation of the L<http://mixpanel.com> API which provides realtime online analytics. L<Mixpanel.com> receives events from your application's perl code, javascript, email open and click tracking, and many more sources, and provides visualization and publishing of analytics.

Currently, this module mirrors the event tracking API (L<http://mixpanel.com/api/docs/specification>), and can be extended to include the powerful data access and platform parts of the api. B<FEATURE REQUESTS> are always welcome, as are patches.

This module is designed to croak on failure, please use something like Try::Tiny.

=head1 METHODS

=head2 new( $token, [$use_ssl] )

Returns a new instance of this class. You must supply the API token for your mixpanel project.
HTTP is used to connect unless you provide a true value for use_ssl.

=head2 track( event => '<event name>', [time => timestamp, ...])

Send an event to the API with the given event name, which is a required parameter.
If you do not include a time parameter, the value of time() is set for you automatically.
Other parameters are optional, and are included as-is as parameters in the api.

Today, there is no way to set 'URL' parameters such as ip, callback, img, redirect.

This method returns 1 or croaks with a message.
Per the Mixpanel API, a 1 return indicates the event reached the mixpanel.com API and was properly formatted. 1 does not indicate the event was actually written to your project, in cases such as bad API token. This is a limitation of the service.

You are strongly encouraged to use something like C<Try::Tiny> to wrap calls to this API.

=head1 TODO

=over 4

=item /track to accept array of events

Track will shortly be extended to accept an array of hashrefs. These will be sent as a batch of events to the /track API in a single bulk call. This will greatly help you if you are able to pull multiple events from a queue.

=item /platform support

The Platform API will be supported. Let me know if this is a feature you'd like to use.

=back

=head1 FEATURE REQUESTS

Please send feature requests to me via rt or email. Patches are always welcome.

=head1 BUGS

Do your thing at L<http://rt.cpan.org>.

=head1 AFFILIATION

I am not affiliated with mixpanel, I just use and like the service.

=cut
