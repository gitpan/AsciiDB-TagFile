package AsciiDB::TagFile;

require 5.003;

# Copyright (c) 1997 Jose A. Rodriguez. All rights reserved.
# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

require Tie::Hash;
@ISA = (Tie::Hash);

use vars qw($VERSION);

$VERSION = '1.00';

use Carp;
use AsciiDB::TagRecord;

sub TIEHASH {
	my $class = shift;
	my %params = @_;

	my $self = {};
	$self->{_DIRECTORY} = $params{DIRECTORY} || '.';
	$self->{_SUFIX} = $params{SUFIX} || '';
	$self->{_SCHEMA} = $params{SCHEMA};
	$self->{_READONLY} = $params{READONLY};
	$self->{_RECORDS} = {};

	bless $self, $class;
}

sub FETCH {
	my ($self, $key) = @_;

	return $self->{$key} if defined ($self->{$key});

	my %record;
	$self->{_RECORDS}{$key} = tie %record, 'AsciiDB::TagRecord',
        	FILENAME => "$self->{_DIRECTORY}/$key" . $self->{_SUFIX},
        	SCHEMA => $self->{_SCHEMA},
		READONLY => $self->{_READONLY};
	
	$self->{$key} = \%record;
	return $self->{$key};
}

sub STORE {
	my ($self, $key, $value) = @_;

	$self->{$key} = $value;
}

sub FIRSTKEY {
	my $self = shift;

	# Current keys are the union of saved keys and new created but
	# not saved keys
	my %currentKeys;

	my $sufix = $self->{_SUFIX};
	map { $currentKeys{$_} = 1 } grep { $_  =~ /\/([^\/]+)$sufix$/; 
		my $accept = -f $_; $_ = $1; $accept; } 
		glob $self->{_DIRECTORY} . '/*' . $sufix;
	map { $currentKeys{$_} = 1 } grep(!/^_/, keys %$self);

	my @currentKeys = keys %currentKeys;
	$self->{_ITERATOR} = \@currentKeys;

	shift @{$self->{_ITERATOR}};
}

sub NEXTKEY {
	my $self = shift;
	
	shift @{$self->{_ITERATOR}};
}

sub DELETE {
	my ($self, $key) = @_;

	return if $self->{_READONLY};

	unlink "$self->{_DIRECTORY}/$key" . $self->{_SUFIX};

	$self->{_OBJECTS}->{$key}->deleteRecord()
		if defined $self->{_OBJECTS}->{$key};

	delete $self->{$key} if defined $self->{$key};
}

sub sync {
	my $self = shift;

	foreach my $record (values %{$self->{_RECORDS}}) {
		$record->sync();
	}
}

1;
__END__

=head1 NAME

AsciiDB::TagFile - Tie class for a simple ASCII database

=head1 SYNOPSIS

 # Bind the hash to the class
 $tieObj = tie %hash, 'AsciiDB::TagFile',
        DIRECTORY => $directory,
        SUFIX => $sufix,
	READONLY => $bool,
        SCHEMA => { 
		ORDER => $arrayRef 
	};

 # Save to disk all changed records
 $tieObj->sync(); 

 # Get all record keys
 @array = keys %hash; 

 # Get a field
 $scalar = $hash{$recordKey}{$fieldName};

 # Assign a field
 $hash{$recordKey}{$fieldName} = $value; 

=head1 DESCRIPTION

The B<AsciiDB::TagFile> provides a hash-table-like interface to a simple ASCII
database.

The ASCII database stores each record in a file:

	$directory/recordKey1.$sufix
	$directory/recordKey2.$sufix
	...
	$directory/recordKeyI<N>.$sufix

And a record has this format:

	[fieldName1]: value1
	[fieldName2]: value2
	...
	[fieldNameI<N>]: value2

After you've tied the hash you can access this database as access a hash of 
hashes:

	$hash{recordKey1}{fieldName1} = ...

To bind the %hash to the class AsciiDB::TagFile you have to use the tie
function:

	tie %hash, 'AsciiDB::TagFile', PARAM1 => $param1, ...;

The parameters are:

=over 4

=item DIRECTORY

The directory where the records will be stored or readed from.
The default value is the current directory.

=item SUFIX

The records are stored as files. The file name of a record is the
key plus this sufix (if supplied).

For example, if the record with key 'josear' and sufix '.record', will
be stored into file: 'josear.record'.

If this parameter is not supplied the records won't have a sufix.

=item READONLY

If you set this parameter to 1 the database will be read only and
all changes will be discarted.

The default value is 0, i.e. the database can be changed.

=item SCHEMA

This parameter is a hash reference that contains the database definition.
Currently you can specify only in which order fields will be saved in the
file.

For example,

        SCHEMA => {
                ORDER => [ 'fieldHi', 'field2There', 'fieldWorld' ]
        };

will save the record this way:

	[fieldHi]: ...
	[fieldThere]: ...
	[fieldWorld]: ...

Note: this parameter is mandatory, and you have to specify all the
fields. B<If you forget to list a field it will not be saved>.

=back

The data will be saved to disk when the hash is destroyed (and garbage
collected by perl), so if you need for safety to write the updated data
you can call the B<sync> method to do it.

=head1 EXAMPLES

 $dbObj = tie %tietag, 'AsciiDB::TagFile',
        DIRECTORY => 'data',
        SUFIX => '.tfr',
        SCHEMA => { ORDER => ['name', 'address'] };

 $tietag{'jose'}{'name'} = 'Jose A. Rodriguez';
 $tietag{'jose'}{'address'} = 'Granollers, Barcelona, SPAIN';
 $tietag{'cindy'}{'name'} = 'Cindy Crawford';
 $tietag{'cindy'}{'address'} = 'Unknown';

 foreach my $key (keys %tietag) {
	print $tietag{$key}{'name'}, "\t", $tietag{$key}{'address'}, 
		"\n";
 }
