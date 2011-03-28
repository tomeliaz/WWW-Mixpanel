use strict;
use warnings;
use Test::More tests => 26;
use Test::Exception;
use WWW::Mixpanel;

my $YOUR_TESTING_API_TOKEN = $ENV{MIXPANEL_TESTING_API_TOKEN};
my $YOUR_TESTING_API_KEY   = $ENV{MIXPANEL_TESTING_API_KEY};
my $YOUR_TESTING_API_SEC   = $ENV{MIXPANEL_TESTING_API_SEC};

my $skip = 0;
if ( !$YOUR_TESTING_API_TOKEN || !$YOUR_TESTING_API_KEY || !$YOUR_TESTING_API_SEC ) {
  $skip = 1;
  my $d = <<INFO;

  To run the data request tests, you must set the following env vars:
  MIXPANEL_TESTING_API_TOKEN, MIXPANEL_TESTING_API_KEY, MIXPANEL_TESTING_API_SEC
  and re-run the tests.

  These can be obtained from your mixpanel account page.
INFO

  diag $d;
}

SKIP: {
  skip '', 26 unless !$skip;
  ok( my $mp = WWW::Mixpanel->new( $YOUR_TESTING_API_TOKEN, 0, $YOUR_TESTING_API_KEY,
                                   $YOUR_TESTING_API_SEC ) );
  ok( $mp->track( 'www-mixpanel data1', 'distinct_id' => 'abc' ), 'Submit Data1' );
  ok( $mp->track( 'www-mixpanel data2', 'distinct_id' => 'abc', prop => 'prop1' ), 'Submit Data2' );

  # This funnel is used for testing, and will go away after about 2 weeks of non-use
  ok( $mp->track( 'mp_funnel',
                  distinct_id => 'abcd',
                  gender      => 'male',
                  funnel      => 'test_funnel',
                  step        => 1,
                  goal        => 'mygoal' ),
      'Submit Funnel' );
  ok( $mp->track( 'mp_funnel',
                  distinct_id => 'abc',
                  gender      => 'male',
                  funnel      => 'test_funnel',
                  step        => 1,
                  goal        => 'mygoal' ),
      'Submit Funnel' );
  ok( $mp->track( 'mp_funnel',
                  distinct_id => 'abc',
                  gender      => 'male',
                  funnel      => 'test_funnel',
                  step        => 2,
                  goal        => 'mygoal2' ),
      'Submit Funnel' );

  sleep(2);

  is( $mp->data( 'events',
                 event    => [ 'www-mixpanel data1', 'www-mixpanel data2' ],
                 type     => 'general',
                 unit     => 'day',
                 interval => '2' )->{legend_size},
      2, 'events' );

  ok( $mp->data( 'events',
                 event    => [ 'www-mixpanel data1', 'www-mixpanel data2' ],
                 type     => 'general',
                 unit     => 'day',
                 format   => 'csv',
                 interval => '2' ),
      'events csv' );

  ok( $mp->data( [qw/events top/], type => 'general', ), 'events top' );

  ok( $mp->data( 'events/top', type => 'general', ), 'events/top' );

  is( @{ $mp->data( 'events/top', type => 'general', limit => 2 )->{events} },
      2, 'events/top limit=>2' );

  ok( $mp->data( 'events/names', type => 'unique' ), 'events/names' );

  is( @{ $mp->data( 'events/names', type => 'general', limit => 2 ) }, 2, 'events/names limit=>2' );

  ok( $mp->data( 'events/retention',
                 event    => 'www-mixpanel data2',
                 unit     => 'day',
                 interval => 2 ),
      'events/retention' );

  ok( @{$mp->data( 'events/properties',
                   event    => 'www-mixpanel data2',
                   name     => 'prop',
                   type     => 'general',
                   unit     => 'hour',
                   interval => 2, )->{data}->{series} },
      'events/properties' );

  is( $mp->data( 'events/properties',
                 event    => 'www-mixpanel data2',
                 name     => 'prop',
                 type     => 'general',
                 unit     => 'hour',
                 values   => 'prop1',
                 interval => 1 )->{legend_size},
      1,
      'events/properties value' );

  is( $mp->data( 'events/properties',
                 event    => 'www-mixpanel data2',
                 name     => 'prop',
                 type     => 'general',
                 unit     => 'hour',
                 values   => [ 'unknown1', 'unknown2' ],
                 interval => 1 )->{legend_size},
      0,
      'events/properties values' );

  ok( defined( $mp->data( 'events/properties/top',
                          event    => 'www-mixpanel data2',
                          type     => 'general',
                          unit     => 'hour',
                          interval => 3 )->{prop} ),
      'events/properties/top' );

  is( @{$mp->data( 'events/properties/values',
                   event    => 'www-mixpanel data2',
                   name     => 'prop',
                   type     => 'unique',
                   unit     => 'month',
                   interval => 1,
                   limit    => 1, ) }[0],
      'prop1',
      'events/properties/values' );

  ok( $mp->data( 'funnels',
                 funnel   => 'test_funnel',
                 unit     => 'week',
                 interval => 3 )->{test_funnel},
      'funnels' );

  ok( @{$mp->data( 'funnels/names',
                   unit     => 'week',
                   interval => 1 ) },
      'funnels/names' );

  ok( $mp->data( 'funnels/dates',
                 funnel => [qw/test_funnel unknown_funnel/],
                 unit   => 'week' )->{test_funnel},
      'funnels/dates' );

  ok( $mp->data( 'funnels/properties',
                 funnel   => 'test_funnel',
                 name     => 'gender',
                 unit     => 'week',
                 interval => 1 ),
      'funnels/properties' );

  ok( $mp->data( 'funnels/properties/names',
                 funnel   => 'test_funnel',
                 unit     => 'week',
                 interval => 2 )->{gender}->{count},
      'funnels/properties/names' );

  # Test malformed JSON request
  dies_ok {
    $mp->data( 'events',
               event    => [ 'www-mixpanel data1', 'www-mixpanel data2' ],
               type     => 'general',
               unit     => 'day2',
               interval => '2' );
  }
  'Malformed Unit Dies Ok';

  # # Test malformed CSV request
  dies_ok {
    $mp->data( 'events',
               event    => [ 'www-mixpanel data1', 'www-mixpanel data2' ],
               type     => 'general',
               unit     => 'day2',
               format   => 'csv',
               interval => '2' );
  }
  'Malformed Unit CSV dies ok';
} # end SKIP

done_testing;
