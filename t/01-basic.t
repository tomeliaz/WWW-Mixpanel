use strict;
use warnings;
use Test::More;
use WWW::Mixpanel;

my $YOUR_TESTING_API_TOKEN = $ENV{MIXPANEL_TESTING_API_TOKEN};

if ( !$YOUR_TESTING_API_TOKEN ) {
  my $d = <<INFO;

  If you would like to run Mixpanel tests against your API token to observe the results,
  please set the environment variable MIXPANEL_TESTING_API_TOKEN
  and re-run the tests. You can clear your project data after testing.

  Mixpanel does not provide a testing token, and only returns 1 / 0
  if the data is properly encoded.
INFO

  diag $d;
}

SKIP: {
  skip 'No personal API token provided, skipping Live tests', 6 unless $YOUR_TESTING_API_TOKEN;

  ok( my $mp = WWW::Mixpanel->new($YOUR_TESTING_API_TOKEN) );
  ok( $mp->track('www-mixpanel test1'), 'Track event, auto-supply time' );
  ok( $mp->track( 'www-mixpanel test2', time => time() - 60 ), 'Track event, time supplied' );
  ok( $mp->track( 'www-mixpanel test3',
                  mp_source   => 'www-mixpanel',
                  distinct_id => 'user1',
                  attribute1  => 'a1',
                  attribute2  => 'a2' ),
      'Track event 3' );
  my $eventparams = { mp_source   => 'www-mixpanel',
                      distinct_id => 'user1',
                      attribute1  => 'a1',
                      attribute2  => 'a2' };
  ok( $mp->track( 'www-mixpanel test4', %$eventparams ), 'Track event 4' );
}

done_testing;
