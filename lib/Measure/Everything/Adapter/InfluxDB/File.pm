package Measure::Everything::Adapter::InfluxDB::File;
use strict;
use warnings;

# ABSTRACT: Write stats formatted as InfluxDB lines into a file

use Config;
use Fcntl qw/:flock/;

use base qw(Measure::Everything::Adapter::Base);
use InfluxDB::LineProtocol qw(data2line);

my $HAS_FLOCK = $Config{d_flock} || $Config{d_fcntl_can_lock} || $Config{d_lockf};

sub init {
    my $self = shift;
    my $file = $self->{file};
    open( $self->{fh}, ">>", $file )
      or die "cannot open '$file' for append: $!";
    $self->{fh}->autoflush(1);
}

sub write {
    my $self = shift;
    my $line = data2line(@_);

    flock($self->{fh}, LOCK_EX) if $HAS_FLOCK;
    $self->{fh}->print($line."\n");
    flock($self->{fh}, LOCK_UN) if $HAS_FLOCK;
}

1;

