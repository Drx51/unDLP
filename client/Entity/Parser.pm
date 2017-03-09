#!/usr/bin/perl

# ---------------------------------------------- #
#                                                #
# The Parser package parse the unDLP arguments.  #
#                                                #
# ---------------------------------------------- #

package Parser;

use Carp;
use Getopt::Long;
use Moose;

has delay => (
    is      =>  'rw',
    isa     =>  'Int',
    default =>  0
);

has dest => (
    is  =>  'rw',
    isa =>  'Str'
);

has files => (
    is      =>  'rw',
    isa     =>  'ArrayRef[Str]',
    traits  =>  ['Array'],
    default =>  sub { [] },
    handles =>  {
        getFiles => "elements"
    }
);

has help => (
    is      =>  'rw',
    isa     =>  'Int',
    default =>  0
);

has method => (
    is  =>  'rw',
    isa =>  'Str'
);

has size => (
    is      =>  'rw',
    isa     =>  'Int',
    default =>  1024
);

has encryptionKey => (
    is      =>  'rw',
    isa     =>  'Str',
    default =>  ''
);

#
# Parse the command line arguments.
#
sub parse {
    my $self = shift;
    my @args = @_;

    GetOptions(
        'f=s{1,}'   =>  $self->{files},
        'd=s'       =>  \$self->{dest},
        'm=s'       =>  \$self->{method},
        'e=s'       =>  \$self->{encryptionKey},
        'delay=i'   =>  \$self->{delay},
        'size=i'    =>  \$self->{size},
        'help|h'    =>  \$self->{help}
    ) or croak usage();

    if (scalar @args < 1 || $self->help || scalar $self->getFiles == 0 || !$self->dest || !$self->method) {
        usage()
    }
}

#
# Display the unDLP usage.
#
sub usage {
    print "\nusage: unDLP.pl -f [FILE, ...] -d DESTINATION -m [HTTPS] [--e PASSWORD] [--size SIZE] [--delay DELAY] [--help|h]\n\n";
    print "\t -f: File to transfer.\n";
    print "\t -d: Destination.\n";
    print "\t -m: Exfiltration method.\n";
    print "\t --e: Set the encryption password.\n";
    print "\t --size: Set the transfer size.\n";
    print "\t --delay: Set the transfer speed (in second).\n";
    print "\t --help|h: Display the helper.\n";

    exit;
}

1;
