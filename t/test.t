#!/usr/bin/perl -w

use Test::More tests => 16;

BEGIN { use_ok 'Sub::Delete' };


# Tests subs:

sub thing {}
++$thing[0];
sub foo {}
()=\&bar;
use constant baz => 'dotodttoto';

{package Phoo;
	sub thing {}
	++$thing[0];
	sub foo {}
	()=\&bar;
	use constant baz => 'dotodttoto';
 }

is +()=delete_sub('thing'), 0, 'no retval';
ok !exists &{'thing'}, 'glob / sub that shares its symbol table entry';
is ${'thing'}[0], 1, 'the array in the same glob was left alone';
delete_sub 'foo';
ok !exists &{'foo'}, 'sub that has its own symbol table entry';
delete_sub 'bar';
ok !exists &{'bar'}, 'stub';
delete_sub 'baz';
ok !exists &{'baz'}, 'constant';

delete_sub 'Phoo::thing';
ok !exists &{'Phoo::thing'},
	'sub in another package that shares its symbol table entry';
is ${'Phoo::thing'}[0], 1,
	'the array in the same glob (in the other package) was left alone';
delete_sub 'Phoo::foo';
ok !exists &{'Phoo::foo'},
	'sub in another package w/its own symbol table entry';
delete_sub 'Phoo::bar';
ok !exists &{'Phoo::bar'}, 'stub in another package';
delete_sub 'Phoo::baz';
ok !exists &{'Phoo::baz'}, 'constant in another package';


@ISA = 'Foo';
{no warnings qw 'once';
*Foo::thing = *Foo::foo = *Foo::bar = *Foo::baz = sub {1};}

# Make sure there really are no stubs left that would affect methods:
ok +main->$_, 'it really *has* been deleted'
	for qw w thing foo bar baz w;
