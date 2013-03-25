# NAME
    WWW::Mixpanel

# VERSION
    version 0.04

# SYNOPSIS
```perl
  use WWW::Mixpanel;
  my $mp = WWW::Mixpanel->new(<API TOKEN>,<USE SSL>);
  $mp->track('login', distinct_id => 'username', source => 'twitter');
```
or if you also want to access the data api

```perl
  my $mp = WWW::Mixpanel->new(<API TOKEN>,<USE SSL>,<API KEY>,<API SECRET>);
  $mp->track('login', distinct_id => 'username', source => 'twitter');
  my $enames = $mp->data('events/names', type => 'unique');
  my $funnels = $mp->data('funnels/ist');
```

* Tokens available in the Mixpanel Account Settings

# DESCRIPTION

The WWW::Mixpanel module is an implementation of the
[Mixpanel API](http://mixpanel.com) which provides realtime online analytics.
Mixpanel receives events from your application's perl code,
javascript, email open and click tracking, and many more sources, and
provides visualization and publishing of analytics.

Currently, this module mirrors the event 
[tracking API]( <https://mixpanel.com/docs/api-documentation> ), 
and will be extended to include the powerful data access and platform parts
of the api. FEATUREREQUESTS are always welcome, as are patches.

    This module is designed to dies on failure, please use something like
    Try::Tiny.

# METHODS
```perl
  new( $token, [$use_ssl], [$api_key], [$api_secret] )
```
Returns a new instance of this class. You must supply the API token for
your mixpanel project. HTTP is used to connect unless you provide a true
value for use_ssl.

```perl
  track('<event name>', time => timestamp, param => val, ...)
```
Send an event to the API with the given event name, which is a required
parameter. If you do not include a time parameter, the value of `time()`
is set for you automatically. Other parameters are optional, and are
included as-is as parameters in the API.

Per the Mixpanel API, a 1 return indicates the event reached the
mixpanel.com API and was properly formatted. 1 does not indicate the
event was actually written to your project, in cases such as bad API
token. This is a limitation of the service.

You can supply ip as a parameter similar to distinct_id,
to geolocate users. You can supply `mp_user_name` as well for friendly user display.

This method returns 1 or dies with a message.

```perl
data('<path/path>', param => val, param => val ...)
```
Obtain data from mixpanel.com using the [Data API](https://mixpanel.com/docs/api-documentation/data-export-api).
The first parameter to the method identifies the path off the api root.

For example to access the `events/top` endpoint you would pass the string
`events/top` to the data method.

Some parameters of the data api are of array type, for example the endpoint
`events/properties` parameter `values`. In every case where a parameter is
of array type, you may supply the parameter as either an ArrayRef or a
single string.

By default the data method returns a perl object (json decoded from the API).

If you specify `format => 'csv'`, this method will return the csv return
string unchanged.

This method will die on errors, including malformed parameters,
indicated by bad return codes from the API. It dies with the text of
the API reply directly, often a JSON string indicating which parameter
was malformed.

# TODO
    /track to accept array of events
        Track should accept many events, and bulk-send
        them to mixpanel in one call if possible.

    /platform support
        The Platform API will be supported. Let me know if this is a feature
        you'd like to use.

# FEATURE REQUESTS
please send feature requests to me via rt or github. Patches are always
welcome.

# BUGS
Do your thing on CPAN or github.

# AFFILIATION
I am not affiliated with mixpanel, I just use and like the service.

# AUTHOR
Tom Eliaz

# COPYRIGHT AND LICENSE
This software is copyright (c) 2012 by Tom Eliaz.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

