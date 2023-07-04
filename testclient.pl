#!/usr/bin/env perl
use v5.36;

use IO::Async;
use IO::Async::Loop;
use IO::Async::Stream;

my $loop = IO::Async::Loop->new();

$loop->add(IO::Async::Stream->new_for_stdin(
    on_read => \&cl_input,
));

sub cl_input ($self, $buffref, $eof){
    while ($$buffref =~ s/^(.*)\n//){
        say "you typed a line: $1";
    }
    return 0;
}

$loop->run();
