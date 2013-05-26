# NAME

Plack::Middleware::Redirect - Perform 301 redirects based on regexps

# SYNOPSIS

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

# DESCRIPTION

Plack::Middleware::Redirect performs a redirect (HTML status code 301) for urls
which match a list of regular expressions. The redirect happens before $app is
called which means $app is completely bypassed if a url matches.

Plack's PATH\_INFO environment variable is the part of the url that looks like
`/path/to/a/resource`.

Plack's QUERY\_STRING environment variable is the part of the url that looks
like c<?rubbery='octopus'&fluffy='bunny'>.

Currently the regexps are only applied to PATH\_INFO. The QUERY\_STRING is always
appended unaltered to the end of the new redirected url.

# LICENSE

Copyright (C) Eric Johnson.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Eric Johnson <lt>eric.git@iijo.org<gt>
