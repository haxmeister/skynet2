package Skynet::AllianceManager;
use v5.36;
use parent qw( IO::Async::Notifier );
use experimental 'try';
use Skynet::Alliance;


sub new($class, $dbi){
    my $self = $class->SUPER::new(notifier_name => "manager");
    $self->{dbi} = $dbi;
    $self->make_lobby();
    return $self;
}

# create a lobby to handle unguilded users or
# users that have not logged in yet
sub make_lobby($self){
    $self->add_child(
        Skynet::Alliance->new("lobby")
    );
}

# accepts a Skynet::User object and moves the user to the
# appropriate alliance object
sub assign_user($self, $user){
    $user->remove_from_parent;
    if($user->alliance){
        my $alliance = $self->alliance_by_name($user->alliance) || $self->add_alliance($user->alliance);
        $alliance->add_child($user);
    }else{
        $self->alliance_by_name('lobby')->add_child($user);
    }
}

# find an alliance by name
sub alliance_by_name($self, $name){
    my @children = $self->children();
    foreach my $child(@children){
        if ($child->notifier_name eq $name){
            return $child;
        }
    }
    return 0;
}

sub add_alliance($self, $name){
    my $new_alliance = Skynet::Alliance->new(notifier_name => $name);
    $self->add_child($new_alliance);
    return $new_alliance;
}

sub dbi($self){
    return $self->{dbi};
}
1;