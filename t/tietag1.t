#!./perl -w

use UNIVERSAL qw(isa);

use AsciiDB::TagFile;

print "1..4\n";

tie %tietag, 'AsciiDB::TagFile',
	DIRECTORY => 'tdata',
	SUFIX => '.tfr', 
	SCHEMA => { ORDER => ['a', 'b', 'c'] };

print "ok 1\n";

$tietag{'record1'}{'a'} = 'Fa';
$tietag{'record1'}{'b'} = 'F1b';
$tietag{'record2'}{'b'} = 'Fb';
tied(%tietag)->sync();

print "ok 2\n";

($tietag{'record1'}{'a'} eq 'Fa') or print "not ";
($tietag{'record2'}{'b'} eq 'Fb') or print "not ";

print "ok 3\n";

isa(tied(%tietag), 'AsciiDB::TagFile') or print "not ";
print "ok 4\n";
