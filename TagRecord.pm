package AsciiDB::TagRecord;

# Copyright (c) 1997 Jose A. Rodriguez. All rights reserved.
# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

require Tie::Hash;
@ISA = (Tie::Hash);

$VERSION = '1.00';

use Carp;

sub TIEHASH {
	my $class = shift;
	my %params = @_;

	my $self = {};
	$self->{_FILENAME} = $params{FILENAME};
	$self->{_SCHEMA} = $params{SCHEMA};
	$self->{_READONLY} = $params{READONLY};

	bless $self, $class;
}

sub FETCH {
	my ($self, $key) = @_;

	$self->load() unless exists $self->{_LOADED};

	return $self->{$key};	
}

sub STORE {
	my ($self, $key, $value) = @_;

	return if $self->{_READONLY};

	$self->load() unless 
		exists ($self->{_LOADED}) or (! -f $self->{_FILENAME});

	$self->{$key} = $value;
	$self->{_LOADED} = 1;
	$self->{_UPDATED} = 1;
}

sub FIRSTKEY {
	my $self = shift;
	
	my %schema = %{$self->{_SCHEMA}};
	my @iterator = @{$schema{ORDER}};
	$self->{_ITERATOR} = \@iterator;

	shift @{$self->{_ITERATOR}};
}

sub NEXTKEY {
	my $self = shift;
	
	shift @{$self->{_ITERATOR}};
}

sub DELETE {
	my ($self, $key) = @_;

	$self->load() unless exists $self->{_LOADED};

	delete $self->{$key};
	$self->{_UPDATED} = 1;
}

sub DESTROY {
	my $self = shift;

	$self->sync ();
}

sub load {
	my $self = shift;

	my $fieldName = '';

	open (RECORD, $self->{_FILENAME})
		or croak "Can't open @{[$self->{_FILENAME}]} record";
	my $line;
	while (defined ($line = <RECORD>)) {
		if ($line =~ /^\[(.+)\]:\s?(.*)$/) {
			$self->{$fieldName = $1} = $2;
			next;
		}
	
		chomp $line;
		$self->{$fieldName} .= "\n$line";
	}
	close (RECORD);

	$self->{_LOADED} = 1;
	delete $self->{_UPDATED};
}

sub deleteRecord {
	my $self = shift;

	$self->{_LOADED} = 1;
	$self->{_UPDATED} = 0;
}

sub sync {
	my $self = shift;

	return if $self->{_READONLY} || ! $self->{_UPDATED};

	open (RECORD, "> @{[$self->{_FILENAME}]}")
		or croak "Can't create @{[$self->{_FILENAME}]} record";
	my %schema = %{$self->{_SCHEMA}};
	foreach my $fieldName (@{$schema{ORDER}}) {
		print RECORD "[$fieldName]: ", 
			($self->{$fieldName} || ''), "\n";
	}
	close (RECORD);

	delete $self->{_UPDATED};
}

1;
