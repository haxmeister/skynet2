package Skynet::Notifier;
use v5.36;
use parent qw(IO::Async::Notifier);

sub _init ($self, @params){
    $self->SUPER::_init( @params );

}

sub notifier_by_name( $self, $name ){

    my @queue = $self->loop->notifiers;

    while (my $child = shift (@queue)){
        if ($child->notifier_name eq $name){
            return $child;
        }else{
            push @queue, @{$child->children} ;
        }
    }
}
1;
