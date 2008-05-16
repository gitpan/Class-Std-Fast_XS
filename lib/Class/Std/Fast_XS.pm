package Class::Std::Fast_XS;

use strict;
use warnings;

our $VESION = 0.1;

use base qw(DynaLoader);

BEGIN {
    bootstrap Class::Std::Fast_XS 0.1;

    require Class::Std::Fast;

    my $attributes_of_ref = {};

    Class::Std::Fast_XS::init($attributes_of_ref);

    no warnings qw(redefine);

    *Class::Std::Fast::__create_getter = sub {
        # my ($package, $referent, $getter, $name) = @_;
        $attributes_of_ref->{ "$_[0]::$_[3]" } ||= $_[1];
        newxs_getter("$_[0]::get_$_[2]", "$_[0]::$_[2]")
    };

    *Class::Std::Fast::__create_setter = sub {
        # my ($package, $referent, $setter, $name) = @_;
        $attributes_of_ref->{ "$_[0]::$_[3]" } ||= $_[1];
        newxs_setter("$_[0]::set_$_[2]", "$_[0]::$_[2]")
    };
}

1;

__END__

=pod

=head1 NAME

Class::Std::Fast_XS - speed up Class::Std::Fast by adding some XS code

=head1 SYNOPSIS

 require Class::Std::Fast_XS

=head1 DESCRIPTION

Speeds up Class::Std::Fast by replacing it's accessors/mutators by XS
variants.

The speed gain varies by platform:

Using perl 5.8.8 on Ubuntu 8.04 (32bit) Linux, the measured speed gain
is around 7.5% for accessors (getters) and around 35% for mutators
(setters).

On a RHEL 5.0 box (64bit) with perl-5.8.8 the speed gain is around
40% for getters and around 60% for setters.

The speed gain on ActivePerl 5.8.8 (822) on Windows XP built with
MinGW/MSYS/gcc is around 45%

ActivePerl 5.10 (1001) on Windows XP yielded around 30% for accessors
and 50% for mutators.

=head1 USAGE

All you have to do is to require this module before you load/create
Class::Std::Fast- based classes. More precisely, all Class::Std::Fast-based
attributes (:ATTR) after loading Class::Std::Fast_XS will be affected.

=head1 BUGS AND LIMITATIONS

Only attributes detected after loading are affected.

=head1 ACKNOWLEDGEMENTS

Based on L<Class::XSAccessor|Class::XSAccessor> and L<AutoXS> by Steffen Müller.

=head1 LICENSE AND COPYRIGHT

Copyright 2008 Martin Kutter.

This library is free software. You may distribute/modify it under
the same terms as perl itself

=head1 AUTHOR

Martin Kutter E<lt>martin.kutter fen-net.deE<gt>

=head1 REPOSITORY INFORMATION

 $Rev: 583 $
 $LastChangedBy: kutterma $
 $Id: $
 $HeadURL: $

=cut
