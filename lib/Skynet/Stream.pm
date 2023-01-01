package Skynet::Stream;
use v5.36;
use parent qw(IO::Async::Stream);
use JSON;

sub _init ($self, @params){
    $self->SUPER::_init( @params );

}

sub on_read{
    my ( $self, $buffref, $eof ) = @_;
    return if $eof;
    while( $$buffref =~ s/^(.*)\r\n// ) {
        $self->parent->_msg_received($1);
    }
    return 0;
}

1;
