use strict;
use warnings;
use utf8;

use lib 't/lib';

use T qw( run_tests_from_data test_datetime_object );
use Test::More 0.96;
use Test::Fatal;

use DateTime::Format::Strptime;

run_tests_from_data( \*DATA );

subtest(
    'parsing whitespace',
    sub {
        my $parser = DateTime::Format::Strptime->new(
            pattern  => '%n%Y%t%m%n',
            on_error => 'croak',
        );

        my $dt = $parser->parse_datetime(<<"EOF");
\t
  2015
12
EOF

        my %expect = (
            year  => 2015,
            month => 12,
        );
        test_datetime_object( $dt, \%expect );
    }
);

subtest(
    'parser time zone is set on returned object',
    sub {
        my $parser = DateTime::Format::Strptime->new(
            pattern   => '%Y %H:%M:%S %Z',
            time_zone => 'America/New_York',
            on_error  => 'croak',
        );

        my $dt     = $parser->parse_datetime('2003 23:45:56 MDT');
        my %expect = (
            year                => 2003,
            hour                => 0,
            minute              => 45,
            second              => 56,
            time_zone_long_name => 'America/New_York',
        );

        test_datetime_object( $dt, \%expect );
    }
);

done_testing();

__DATA__
[ISO8601]
%Y-%m-%dT%H:%M:%S
2015-10-08T15:39:44
year   => 2015
month  => 10
day    => 8
hour   => 15
minute => 39
second => 44

[date with 4-digit year]
%Y-%m-%d
1998-12-31
year  => 1998
month => 12
day   => 31

[date with 2-digit year]
%y-%m-%d
98-12-31
year  => 1998
month => 12
day   => 31

[date with leading space on month]
%e-%b-%Y
 3-Jun-2010
year  => 2010
month => 6
day   => 3

[year and day of year]
%Y years %j days
1998 years 312 days
year  => 1998
month => 11
day   => 8

[date with abbreviated month]
%b %d %Y
Jan 24 2003
year  => 2003
month => 1
day   => 24

[date with abbreviated month is case-insensitive]
%b %d %Y
jAN 24 2003
skip round trip
year  => 2003
month => 1
day   => 24

[date with full month]
%B %d %Y
January 24 2003
year  => 2003
month => 1
day   => 24

[date with full month is case-insensitive]
%B %d %Y
jAnUAry 24 2003
skip round trip
year  => 2003
month => 1
day   => 24

[24 hour time]
%H:%M:%S
23:45:56
year   => 1
month  => 1
day    => 1
hour   => 23
minute => 45
second => 56

[12 hour time (PM)]
%l:%M:%S %p
11:45:56 PM
year   => 1
month  => 1
day    => 1
hour   => 23
minute => 45
second => 56

[12 hour time (am) and am/pm is case-insensitive]
%l:%M:%S %p
11:45:56 am
skip round trip
year   => 1
month  => 1
day    => 1
hour   => 11
minute => 45
second => 56

[24-hour time]
%T
23:34:45
hour   => 23
minute => 34
second => 45

[12-hour time]
%r
11:34:45 PM
hour   => 23
minute => 34
second => 45

[24-hour time without second]
%R
23:34
hour   => 23
minute => 34
second => 0

[US style date]
%D
11/30/03
year  => 2003
month => 11
day   => 30

[ISO style date]
%F
2003-11-30
year  => 2003
month => 11
day   => 30

[nanosecond with no length]
%H:%M:%S.%N
23:45:56.123456789
hour       => 23
minute     => 45
second     => 56
nanosecond => 123456789

[nanosecond with length of 6]
%H:%M:%S.%6N
23:45:56.123456
hour       => 23
minute     => 45
second     => 56
nanosecond => 123456000

[nanosecond with length of 3]
%H:%M:%S.%3N
23:45:56.123
hour       => 23
minute     => 45
second     => 56
nanosecond => 123000000

[nanosecond with no length but < 9 digits]
%H:%M:%S.%N
23:45:56.543
skip round trip
hour       => 23
minute     => 45
second     => 56
nanosecond => 543000000

[time zone as numeric offset]
%H:%M:%S %z
23:45:56 +1000
hour       => 23
minute     => 45
second     => 56
offset     => 36000

[time zone as abbreviation]
%H:%M:%S %Z
23:45:56 AEST
skip round trip
hour       => 23
minute     => 45
second     => 56
offset     => 36000

[time zone as abbreviation with short name of +07]
%H:%M:%S %Z
23:45:56 +07
skip round trip
hour       => 23
minute     => 45
second     => 56
offset     => 25200

[time zone as Olson name]
%H:%M:%S %O
23:45:56 America/Chicago
hour   => 23
minute => 45
second => 56
time_zone_long_name => America/Chicago

[escaped percent]
%Y%%%m%%%d
2015%05%14
year  => 2015
month => 5
day   => 14

[escaped percent followed by letter token]
%Y%%%m%%%d%%H
2015%05%14%H
year  => 2015
month => 5
day   => 14

[every pattern]
%a %b %B %C %d %e %h %H %I %j %k %l %m %M %n %N %O %p %P %S %U %u %w %W %y %Y %s %G %g %z %Z %%Y %%
Wed Nov November 20 05  5 Nov 21 09 309 21  9 11 34 \n 123456789 America/Denver PM pm 45 44 3 3 44 03 2003 1068093285 2003 03 -0700 MST %Y %
year   => 2003
month  => 11
day    => 5
hour   => 21
minute => 34
second => 45
nanosecond => 123456789
time_zone_long_name => America/Denver

[Australian date]
%x
31/12/98
locale = en-AU
skip round trip
year  => 1998
month => 12
day   => 31

[Australian time]
%X
13:34:56
locale = en-AU
skip round trip
hour   => 13
minute => 34
second => 56

[Australian date/time]
%c
AU_THU 31 AU_DEC 1998 13:34:56 AEDT
locale = en-AU
skip round trip
year   => 1998
month  => 12
day    => 31
hour   => 13
minute => 34
second => 56
offset => 39600

[US date]
%x
12/31/1998
locale = en-US
skip round trip
year  => 1998
month => 12
day   => 31

[US time]
%X
01:34:56 PM
locale = en-US
skip round trip
hour   => 13
minute => 34
second => 56

[US date/time]
%c
Thu 31 Dec 1998 01:34:56 PM MST
locale = en-US
skip round trip
year   => 1998
month  => 12
day    => 31
hour   => 13
minute => 34
second => 56
offset => -25200

[UK date]
%x
31/12/98
locale = en-GB
skip round trip
year  => 1998
month => 12
day   => 31

[UK time]
%X
13:34:56
locale = en-GB
skip round trip
hour   => 13
minute => 34
second => 56

[UK date/time]
%c
Thu 31 Dec 1998 13:34:56 GMT
locale = en-GB
skip round trip
year   => 1998
month  => 12
day    => 31
hour   => 13
minute => 34
second => 56
offset => 0

[French (France) date]
%x
31/12/1998
locale = fr-FR
skip round trip
year  => 1998
month => 12
day   => 31

[French (France) time]
%X
13:34:56
locale = fr-FR
skip round trip
hour   => 13
minute => 34
second => 56

[French (France) date/time]
%c
jeu. 31 Déc. 1998 13:34:56 CEST
locale = fr-FR
skip round trip
year   => 1998
month  => 12
day    => 31
hour   => 13
minute => 34
second => 56
offset => 7200

[French (Generic) date]
%x
12/31/98
locale = fr
skip round trip
year  => 1998
month => 12
day   => 31

[French (Generic) time]
%X
13:34:56
locale = fr
skip round trip
hour   => 13
minute => 34
second => 56

[French (Generic) date/time]
%c
jeu. Déc. 31 13:34:56 1998
locale = fr
skip round trip
year   => 1998
month  => 12
day    => 31
hour   => 13
minute => 34
second => 56

[epoch without time zone]
%s
42
epoch => 42
time_zone_long_name => floating

[epoch with time zone]
%s %Z
42 UTC
epoch  => 42
offset => 0

[epoch with nanosecond]
%s %N
42 000000034
epoch => 42
nanosecond => 34
