package Skynet::Alliance;
use v5.36;
use parent qw( IO::Async::Notifier );
use experimental 'try';
use Skynet::Roid;


sub new($class, $name){
    my $self = $class->SUPER::new(notifier_name => $name);
    say "generated alliance $name";
    # TODO: check database and retreive alliance info
    return $self;
}

sub broadcast($self, $hash){
    my @children = $self->children();
    foreach my $child (@children){
        $child->write($hash);
    }
}

sub scan($self, $hash){
    my @data = split("\n", $hash->{data}->{data});
    my %ores = (
        sector   => $hash->{sender}{sectorid},
        objectId => $hash->{data}{objectid},
        alliance => $self->notifier_name(),
    );

    foreach my $item(@data){
        if ($item =~ /^Temp/){next;}
        if ($item =~ /^Minerals/){next;}
        $item =~ s/\%//g;
        $item =~ s/Ore//g;
        $item =~ s/ //g;
        my ($ore, $percent) =  split(":",$item);
        $ores{$ore} = $percent;
    }
    my $roid = Skynet::Roid->new(%ores);
    say "roid scan completed";
    $self->parent->dbi->add_roid($roid);
}



1;
