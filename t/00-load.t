use Test::More tests => 1;

BEGIN {
  use_ok('WWW::Mixpanel');
}

diag("Testing WWW::Mixpanel $WWW::Mixpanel::VERSION, Perl $], $^X");
