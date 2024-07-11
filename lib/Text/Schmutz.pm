package Text::Schmutz;

use v5.20;
use utf8;

use Moo;

use Types::Common qw( ArrayRef Bool NumRange StrLength );

use experimental qw( postderef signatures );

my $Prob = NumRange [ 0, 1 ];

has prob => (
    is      => 'ro',
    isa     => $Prob,
    default => 0.1,
);

has use_small => (
    is      => 'lazy',
    isa     => Bool,
    default => sub($self) { return !( $self->use_large || $self->strike_out ) },
);

has use_large => (
    is      => 'ro',
    isa     => Bool,
    default => 0,
);

has strike_out => (
    is      => 'ro',
    isa     => Bool,
    default => 0,
);

has _schmutz => (
    is      => 'lazy',
    isa     => ArrayRef [ StrLength [1] ],
    builder => sub($self) {
        my @schmutz;

        push @schmutz, ( "\x{0323}", "\x{0307}", "\x{0312}" ) if $self->use_small;
        push @schmutz, ( "\x{0314}", "\x{031C}", "\x{0358}", "\x{0353}", "\x{0335}" ) if $self->use_large;
        push @schmutz,
          ( "\x{0337}", "\x{0338}", "\x{0336}", "\x{0335}", "\x{20d2}", "\x{20d3}", "\x{20e5}", "\x{20e6}", "\x{20eb}" )
          if $self->strike_out;
        return \@schmutz;

    },
    init_arg => undef,
);

sub mangle ( $self, $text, $prob = undef ) {

    my @schmutz = $self->_schmutz->@*;
    my $size    = scalar(@schmutz);

    $Prob->assert_valid( $prob //= $self->prob );

    return join( "", map { rand(1) <= $prob ? $_ . $schmutz[ int( rand($size) ) ] : $_ } split //, $text );
}

1;
