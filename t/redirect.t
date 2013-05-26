use Test::Most;
use Plack::Test;
use Plack::Util;
use Plack::Builder;

{
    foreach my $test ( tests() ) {
        test_psgi
            app    => app(),
            client => client($test);
    }

    done_testing();
}

sub app {
    my $app = sub { [ 200, [ 'Content-Type' => 'text/plain' ], ["yo"] ] };

    builder {
        enable 'Redirect', url_map => [
            '/i/dinosaur.html' => '/i/dinosaur.jpg',
            '/i/batman.html'   => '/i/batman.jpg?bats=y',
            'icecream'         => 'ice_cream',
            '^/boop$'          => '/bop',
            '^/powe(r)$'       => '/po$1$1idge',
            '^/sub$'           => sub {
                my ($env, $regex) = @_;
                my $path = $env->{PATH_INFO};
                $path =~ s|$regex|/substitution|;
                return $path;
            },
        ];
        $app;
    };
}

sub client {
    my $test = shift;

    return sub {
        my $cb  = shift;
        my $url = "http://localhost" . $test->{url};
        my $req = HTTP::Request->new( GET => $url );
        my $res = $cb->($req);

        note " ";

        is $res->code(), $test->{code}, "    Code: $test->{code}";

        pass " Request: $test->{url}";

        if ( $test->{Location} ) {
            is $res->header('Location'), $test->{Location},    #
                "Response: $test->{Location}";
        }

    };
}

# -- everything below this line is test data

sub tests {
    return (
        # no redirect
        {   url  => '/zzzzzzzzzzzzzzzzz',
            code => '200',
        },

        # simple normal situation
        {   url      => '/i/dinosaur.html',
            Location => '/i/dinosaur.jpg',
            code     => '301',
        },

        # regexps
        {   url      => '/boop',
            Location => '/bop',
            code     => '301',
        },
        {   url      => '/power',
            Location => '/porridge',
            code     => '301',
        },

        # handles query params correctly
        {   url      => '/i/dinosaur.html?stegasaurus=yes',
            Location => '/i/dinosaur.jpg?stegasaurus=yes',
            code     => '301',
        },
        {   url      => '/i/batman.html?boop=yes',
            Location => '/i/batman.jpg?bats=y&boop=yes',
            code     => '301',
        },
        {   url      => '/woof/icecream.boop',
            Location => '/woof/ice_cream.boop',
            code     => '301',
        },

        # handles subs
        {   url      => '/sub',
            Location => '/substitution',
            code     => '301',
        },
    );
}                        

