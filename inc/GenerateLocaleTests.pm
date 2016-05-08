package inc::GenerateLocaleTests;

use strict;
use warnings;
use namespace::autoclean;

use DateTime::Locale 1.03;
use Dist::Zilla::File::InMemory;

use Moose;

with(
    'Dist::Zilla::Role::FileGatherer',
    'Dist::Zilla::Role::TextTemplate',
);

my $template = <<'EOF';
use strict;
use warnings;

use Test::More 0.96;
use Test::Fatal;

use DateTime::Format::Strptime;
use DateTime::Locale;
use DateTime;

my $code_meth = DateTime::Locale->load('en')->can('code') ? 'code' : 'id';

my $locale = '{{$code}}';
test_days($locale);
test_months($locale);
test_am_pm($locale);
test_locale($locale);

done_testing();

sub test_days {
    my $locale = shift;

    subtest(
        'days',
        sub {
            foreach my $day ( 1 .. 7 ) {
                subtest(
                    "Day $day",
                    sub { _test_one_day( $locale, $day ); },
                );
            }
        }
    );
}

sub _test_one_day {
    my $locale = shift;
    my $day    = shift;

    _utf8_output();

    my $pattern = '%Y-%m-%d %A';

    my $dt = DateTime->now( locale => $locale )->set( day => $day );
    my $input = $dt->strftime($pattern);

    my $strptime;
    is(
        exception {
            $strptime = DateTime::Format::Strptime->new(
                pattern  => $pattern,
                locale   => $locale,
                on_error => 'croak',
            );
        },
        undef,
        'constructor with day name in pattern (%A)'
    ) or return;

    my $parsed_dt;
    is(
        exception {
            $parsed_dt = $strptime->parse_datetime($input)
        },
        undef,
        "parsed $input"
    ) or return;

    is(
        $parsed_dt->strftime($pattern),
        $input,
        'strftime output matches input'
    );
}

sub test_months {
    my $locale = shift;

    subtest(
        'months',
        sub {
            foreach my $month ( 1 .. 12 ) {
                subtest(
                    "Month $month",
                    sub { _test_one_month( $locale, $month ) },
                );
            }
        }
    );
}

sub _test_one_month {
    my $locale = shift;
    my $month  = shift;

    _utf8_output();

    my $pattern = '%Y-%m-%d %B';

    my $dt
        = DateTime->now( locale => $locale )->truncate( to => 'month' )
        ->set( month => $month );
    my $input = $dt->strftime($pattern);
    my $strptime;
    is(
        exception {
            $strptime = DateTime::Format::Strptime->new(
                pattern  => $pattern,
                locale   => $locale,
                on_error => 'croak',
            );
        },
        undef,
        'constructor with month name (%B)'
    ) or return;

    my $parsed_dt;
    is(
        exception {
            $parsed_dt = $strptime->parse_datetime($input)
        },
        undef,
        "parsed $input"
    ) or return;

    is(
        $parsed_dt->strftime($pattern),
        $input,
        'strftime output matches input'
    );
}

sub test_am_pm {
    my $locale = shift;

    subtest(
        'am/pm',
        sub {
            foreach my $hour ( 0, 11, 12, 23 ) {
                subtest(
                    "Hour $hour",
                    sub { _test_one_hour( $locale, $hour ); },
                );
            }
        }
    );
}

sub _test_one_hour {
    my $locale = shift;
    my $hour   = shift;

    _utf8_output();

    my $pattern = '%Y-%m-%d %H:%M %p';

    my $dt = DateTime->now( locale => $locale )->set( hour => $hour );
    my $input = $dt->strftime($pattern);
    my $strptime;
    is(
        exception {
            $strptime = DateTime::Format::Strptime->new(
                pattern  => $pattern,
                locale   => $locale,
                on_error => 'croak',
            );
        },
        undef,
        'constructor with meridian (%p)'
    ) or return;

    my $parsed_dt;
    is(
        exception {
            $parsed_dt = $strptime->parse_datetime($input)
        },
        undef,
        "parsed $input",
    ) or return;

    is(
        $parsed_dt->strftime($pattern),
        $input,
        'strftime output matches input'
    );
}

sub test_locale {
    my $locale = shift;

    my $strptime;
    is(
        exception {
            $strptime = DateTime::Format::Strptime->new(
                pattern  => '%Y-%m-%d',
                locale   => $locale,
                on_error => 'croak',
            );
        },
        undef,
        'constructor with locale'
    ) or return;

    my $input = '2015-01-30';
    my $parsed_dt;
    is(
        exception {
            $parsed_dt = $strptime->parse_datetime($input)
        },
        undef,
        "parsed $input",
    ) or return;

    is(
        $parsed_dt->locale->$code_meth,
        $locale,
        "code of locale for DateTime returned by parser is $locale"
    );
}

sub _utf8_output {
    binmode $_, ':encoding(UTF-8)'
        for map { Test::Builder->new->$_ }
        qw( output failure_output todo_output );
}

EOF

sub gather_files {
    my $self = shift;

    my %non_author = map { $_ => 1 } qw( en de ga pt zh );
    for my $code ( DateTime::Locale->codes ) {
        my $filename
            = $non_author{$code}
            ? "t/locale-$code.t"
            : "xt/author/locale-$code.t";

        $self->add_file(
            Dist::Zilla::File::InMemory->new(
                name    => $filename,
                content => $self->fill_in_string(
                    $template,
                    { code => $code },
                ),
            )
        );
    }
}

1;
