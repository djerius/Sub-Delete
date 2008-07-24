#!/usr/bin/perl -w

use Test::More tests => 13;

BEGIN { use_ok 'Sub::Delete' };


# Tests subs:

sub thing {}
++$thing[0];
sub foo {}
()=\&bar;
use constant baz => 'dotodttoto';
sub thang {}

is +()=delete_sub('thing'), 0, 'no retval';
ok !exists &{'thing'}, 'glob / sub that shares its symbol table entry';
is ${'thing'}[0], 1, 'the array in the same glob was left alone';
delete_sub 'foo';
ok !exists &{'foo'}, 'sub that has its own symbol table entry';
delete_sub 'bar';
ok !exists &{'bar'}, 'stub';
delete_sub 'baz';
ok !exists &{'baz'}, 'constant';
{package Foo; main::delete_sub 'main::thang';
 ::ok !exists &{'main::thang'}, 'sub in another package'
}

@ISA = 'Foo';
{no warnings 'once';
*Foo::thing = *Foo::foo = *Foo::bar = *Foo::baz = *Foo::thang = sub {1};}

ok +main->$_, 'it really *has* been deleted'
	for qw w thing foo bar baz thang w;
