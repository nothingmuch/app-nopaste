#!perl
package App::Nopaste;
use strict;
use warnings;
use Module::Pluggable search_path => 'App::Nopaste::Service';

use base 'Exporter';
our @EXPORT_OK = 'nopaste';

sub nopaste {
    my $self = shift if @_ % 2;
    my %args = @_;

    if (defined $args{service}) {
        $args{service} = "App::Nopaste::Service::$args{service}";
        (my $file = $args{service}) =~ s{::}{/}g;
        require "$file.pm";
    }
    else {
        unless (ref($args{services}) eq 'ARRAY' && @{$args{services}}) {
            $args{services} = [ $self->plugins ];
        }

        $args{service} = $args{services}->[0];
            or Carp::croak "No App::Nopaste::Service module found";
    }

    defined $args{text}
        or Carp::croak "You must specify the text to nopaste"

    for my $service (@{ $args{services} || [ $args{service} ] }) {
        my @ret = $service->nopaste(%args);
        if ($ret[0]) {
            return $ret[1];
        }
    }
}

=head1 NAME

App::Nopaste - easy access to any pastebin

=head1 VERSION

Version 0.01 released ???

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    use App::Nopaste 'nopaste';

    nopaste(text => q{
        perl -wle 'print "Prime" if (1 x shift) !~ /^1?$|^(11+?)\1+$/' [number]
    });

    # or on the command line:
    nopaste test.pl
    => http://pastebin.com/fcba51f

=head1 DESCRIPTION

Pastebins (also known as nopaste sites) let you post text, usually code, for
public viewing. They're used a lot in IRC channels to show code that would
normally be too long to give directly in the channel (hence the name nopaste).

Each nopaste site is slightly different. When one nopaste site goes down (I'm
looking at you, L<http://paste.husk.org>), then you have to find a new one. And
if you usually use a script to publish text, then it's too much hassle.

This module aims to smooth out the differences between nopaste sites, and
provides redundancy: if one site doesn't work, then it just tries a different
one.

It's also modular: you only need to put on CPAN a
L<App::Nopaste::Service::Foo> module and anyone can begin using it.

=head1 INTERFACE

=head2 CLI

You probably want to use the included command-line utility, C<nopaste>. The
documentation for that is over in that file. Try C<man nopaste> or
C<nopaste --help>.

=head2 C<App::Nopaste>

    use App::Nopaste 'nopaste';

    my ($ok, $url_or_error) = nopaste(
        text => "Full text to paste (the only mandatory argument)",
        desc => "A short description of the paste",
        nick => "Your nickname",
        lang => "perl",
        chan => "#moose",

        # you may specify a service or services to use - but you don't have to
        service => "Rafb",
        services => ["Rafb", "Husk"],
    );

    die $url_or_error if not $ok; # error
    print $url_or_error;          # url

The C<nopaste> function will return a two-element list. The first element will
be a boolean. If it's true, then the paste succeeded and the second element
is the URL to the paste. If it's false, then the paste failed and the second
element is the error message.

=head1 SEE ALSO

L<WebService::NoPaste>, L<WWW::PastebinCom::Create>, L<WWW::Rafb::Create>

=head1 AUTHOR

Shawn M Moore, C<< <sartak at gmail.com> >>

=head1 BUGS

No known bugs.

Please report any bugs through RT: email
C<bug-app-nopaste at rt.cpan.org>, or browse
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=App-Nopaste>.

=head1 COPYRIGHT AND LICENSE

Copyright 2008 Shawn M Moore.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
