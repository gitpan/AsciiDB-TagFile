#!./perl -w

use AsciiDB::TagFile;

print "1..2\n";

tie %tietag, 'AsciiDB::TagFile',
	DIRECTORY => 'tdata',
	SUFIX => '.tfr', 
	SCHEMA => { ORDER => ['a', 'b', 'c'] };

print "ok 1\n";

delete $tietag{'record1'};

print "not " if -f 'tdata/record1.trf';

print "ok 2\n";
