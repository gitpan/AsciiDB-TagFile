#!./perl -w

use AsciiDB::TagFile;

print "1..2\n";

tie %tietag, 'AsciiDB::TagFile',
	DIRECTORY => 'tdata',
	SUFIX => '.tfr', 
	SCHEMA => { ORDER => ['a', 'b', 'c'] };

print "ok 1\n";

($tietag{'record1'}{'a'} eq 'Fa') or print "not ";
($tietag{'record2'}{'b'} eq 'Fb') or print "not ";

print "ok 2\n";
