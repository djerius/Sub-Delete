use 5.008003;

package Sub::Delete;

$VERSION = '0.02';
@EXPORT = delete_sub;
use Exporter 5.57 'import';

sub delete_sub {
	# This code is slightly problematic because a glob  always  has  a
	# scalar slot. That scalar might have been use-varsed, or there may
	# be a reference to it elsewhere, so I can’t just delete the entire
	# glob if the CODE slot is the only thing that apparently needs to
	# be there.  So this just leaves an empty glob  floating  around.

	my $sub = shift;
	my($stashname, $key) = $sub =~ /(.*::)((?:(?!::).)*)\z/s
		? ($1,$2) : (caller()."::", $sub);
	exists +(my $stash = \%$stashname)->{$key} or return;
	ref $stash->{$key} eq 'SCALAR' and  # perl5.10 constant
		delete $stash->{$key}, return;
	my $globname = "$stashname$key"; 
	my $glob = \*$globname; # autovivify the glob in case future perl
        delete $stash->{$key};  # versions add new funny stuff
	my $newglob = \*$globname;
	defined *$glob{$_} and *$newglob = *$glob{$_}
		for qw "SCALAR ARRAY HASH IO FORMAT";
	return # nothing;
}

1;

__END__

=head1 NAME

Sub::Delete - Perl module enabling one to delete subroutines

=head1 VERSION

0.02 (beta)

=head1 SYNOPSIS

    use Sub::Delete;
    sub foo {}
    delete_sub 'foo';
    eval 'foo();1' or die; # dies

=head1 DESCRIPTION

This module provides one function, C<delete_sub>, that deletes the
subroutine whose name is passed to it. (To load the module without
importing the function, write S<C<use Sub::Delete();>>.)

This does more than simply undefine
the subroutine in the manner of C<undef &foo>, which leaves a stub that
can trigger AUTOLOAD (and, consequently, won't work for deleting methods).
The subroutine is completely obliterated from the
symbol table (though there may be
references to it elsewhere, including in compiled code).

=head1 PREREQUISITES

This module requires L<perl> 5.8.3 or higher.

=head1 BUGS

If you find any bugs, please report them to the author via e-mail.

=head1 AUTHOR & COPYRIGHT

Copyright (C) 2008 Father Chrysostomos (sprout at, um, cpan dot org)

This program is free software; you may redistribute or modify it (or both)
under the same terms as perl.

=head1 SEE ALSO

L<perltodo>, which has C<delete &sub> listed as a possible future feature

=cut
