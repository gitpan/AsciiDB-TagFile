#!./perl -w

use AsciiDB::TagFile;

print "1..7\n";

tie %tietag, 'AsciiDB::TagFile',
	DIRECTORY => 'tdata',
	SUFIX => '.tfr', 
	LOCK => 1,
	SCHEMA => { ORDER => ['a', 'b', 'c'] };

print "ok 1\n";

($tietag{'record1'}{'a'} eq 'Fa') or print "not ";
print "ok 2\n";

($tietag{'record2'}{'b'} eq 'Fb') or print "not ";
print "ok 3\n";

(exists $tietag{'record2'}) or print "not ";
print "ok 4\n";

(!exists $tietag{'NOEXISTS'}) or print "not ";
print "ok 5\n";

# Test record copy
$tietag{'record1'} = $tietag{'record1'};
$tietag{'record3'} = $tietag{'record1'};
$tietag{'record3'}{'a'} = 'AValueForRecord3';
($tietag{'record3'}{'a'} ne $tietag{'record1'}{'a'}) or print "not ";
print "ok 6\n";

($tietag{'record3'}{'b'} eq $tietag{'record1'}{'b'}) or print "not ";
print "ok 7\n";
