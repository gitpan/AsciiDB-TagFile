#!./perl -w

# Test bug fixed in 1.03
# 	Create record
#	Delete record
#	Destroy record (no file should be created at this point)

use AsciiDB::TagFile;

print "1..2\n";

{ # Open scope

tie %tietag, 'AsciiDB::TagFile',
	DIRECTORY => 'tdata',
	SUFIX => '.tfr', 
	SCHEMA => { ORDER => ['a', 'b', 'c'] };

print "ok 1\n";

$tietag{'removed'}{'a'} = 1;
delete $tietag{'removed'};
} # Close scope

print "not " if -e 'tdata/removed.tfr';
print "ok 2\n";
