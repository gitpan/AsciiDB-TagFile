#!./perl -w

use AsciiDB::TagFile;

print "1..3\n";

tie %tietag, 'AsciiDB::TagFile',
	DIRECTORY => 'tdata',
	SUFIX => '.tfr', 
	READONLY => 1,
	SCHEMA => { ORDER => ['a', 'b', 'c'] };

print "ok 1\n";

$tietag{'record2'}{'b'} = 'NOTVALID';
($tietag{'record2'}{'b'} eq 'Fb') or print "not ";
print "ok 2\n";

delete $tietag{'record2'};
print "not " if ! -f 'tdata/record2.tfr';
print "ok 3\n";

unlink 'tdata/record2.tfr' if -f 'tdata/record2.tfr';
