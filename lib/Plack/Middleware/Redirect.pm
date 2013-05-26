package Plack::Middleware::Redirect;
use 5.008005;
use strict;
use warnings;

use parent 'Plack::Middleware';

use Plack::Util::Accessor qw/url_map/;

our $VERSION = "0.01";

sub call {
    my ( $self, $env ) = @_;

    my $path  = $env->{PATH_INFO};
    my $query = $env->{QUERY_STRING};

    my $url_map = $self->url_map;

    for ( my $i = 0; $i < scalar(@$url_map); $i += 2 ) {
        my $from = $url_map->[$i];
        my $to   = $url_map->[ $i + 1 ];

        next unless $path =~ /$from/;

        # if $to is code ref, execute the code ref
        if ( ref $to eq 'CODE' ) {
            $path = $to->( $env, $from );
        }

        # else assume $to is regexp string and do a substitution
        else {
            eval '$path =~ s|' . $from . '|' . $to . '|';
            die $@ if $@;
        }

        # append the query string
        if ($query) {
            $path .= $path =~ /\?/    #
                ? '&' . $query
                : '?' . $query;
        }                                                                                                                                                      

        return [ 301, [ 'Location' => $path ], [] ];
    }

    return $self->app->($env);
}


1;
__END__

=encoding utf-8

=head1 NAME

Plack::Middleware::Redirect - Perform 301 redirects based on regexps

=head1 SYNOPSIS

    use Plack::Middleware::Redirect;

    builder {
        enable 'Redirect', url_map => [
            '^/profile/batman$' => '/user/batman',
            '^/awe.*'           => '/awesome', 
            '^/dinosore/(.*)'   => '/dinosaur?angerlevel=$1',

            '^/bot(.*)'         => sub { 
                my ($env, $regex) = @_;

                my $path = $env->{PATH_INFO};
                $path =~ s|$regex|botulism/$1|;

                return $path;
            },
        ];
        $app;
    }

=head1 DESCRIPTION

Plack::Middleware::Redirect performs a redirect (HTML status code 301) for urls
which match a list of regular expressions. The redirect happens before $app is
called which means $app is completely bypassed if a url matches.

Plack's PATH_INFO environment variable is the part of the url that looks like
C</path/to/a/resource>.

Plack's QUERY_STRING environment variable is the part of the url that looks
like c<?rubbery='octopus'&fluffy='bunny'>.

Currently the regexps are only applied to PATH_INFO. The QUERY_STRING is always
appended unaltered to the end of the new redirected url.

=head1 LICENSE

Copyright (C) Eric Johnson.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Eric Johnson <lt>eric.git@iijo.org<gt>

=cut

