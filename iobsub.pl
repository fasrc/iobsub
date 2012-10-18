#!/usr/bin/env perl

$index_fs = '/n/sw/openlava/index_fs';

@df = `df -P .`;
($fs, $b, $u, $a, $c, $mp) = split(' ', $df[1]);

if ($fs =~ m/^(\w+):(.+)$/) {
  $host = $1;
  $fs = $2;
}
else {
  $host = 'localhost';
}

$match = 0;
open(FSLIST, $index_fs)
  or die "Can't open $index_fs for reading: $!";
while (<FSLIST>) {
  chomp;
  ($h, $e, $m) = split;
  if ($host eq 'localhost' and $mp eq $e) {
    $host = $h;
    $mp = $m;
    $fs = $e;
    $match = 1;
    last;
  }
  elsif ($host eq $h and $m eq $mp) {
    $match = 1;
    last;
  } 
}
close(FSLIST);

if (not $match) {
  print "Cannot find fileserver for current working directory.\n";
  exit(1);
}

@newargs = ();
foreach $arg (@ARGV) {
  next if $arg eq $0;
  # get rid of any passed -m argument
  if ($arg eq '-m') {
    shift @ARGV;
    print "Warning: iobsub sets -m automatically, so passed -m option is ignored.\n";
    next;
  }
  $arg = "'$arg'" if $arg =~ m/[\s]/;
  push(@newargs, $arg);
}

# add our -m option
unshift(@newargs, $host);
unshift(@newargs, '-m');
unshift(@newargs, "bsub");

print "Submitting job to run on fileserver $host\n";

exec @newargs
  or die "Can't exec bsub: $!";
