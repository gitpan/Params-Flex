package Params::Flex;

use 5.008006;
use strict;
use warnings;

use base qw/ Exporter /;
our @EXPORT = qw(
	args
);
our @EXPORT_OK = qw(
	a
);
our $VERSION = '0.02';


my %selves;

sub args {
	my $caller = (caller)[0];
	
	if(ref $_[0] eq $caller){
		# $someObj->hoge(...);
		# Nothing to do.
	}
	elsif($_[0] eq $caller){
		# Some::Module->hoge(...):
		my $self = get_self($caller);
		splice(@_, 0, 1, $self)
	}
	else{
		# &hoge(...);
		my $self = get_self($caller);
		unshift(@_, $self);
	}
	return @_;
}


sub get_self {
	my $caller = shift;
	if(! $selves{$caller}){
		# create substitute $self.
		$selves{$caller} = {};
		bless $selves{$caller}, $caller;
	}
	return $selves{$caller};
}

{
	# alias
	no strict 'refs';
	*{__PACKAGE__ . '::a'} = \&args;
}

1;
__END__

=head1 NAME

Params::Flex - Write and Call methods in your style.


=head1 SYNOPSIS

  package Some::Module;
  use Params::Flex;
  
  # constructor
  sub new { bless {},shift };
  
  sub hoge {
	my ($self, $arg1, $arg2) = args(@_);
	
	# You can call other functions with $self.
	# Moreover, you can use $self as hash reference even 
	# this function was called in non object-oriented style.
	if($self->{_cache}){
		$rv = $self->{_cache}; # use cache
	}
	else{
		$rv = $self->other_function($arg1, $arg2);
		$self->{_cache} = $rv; # store cache
	}
	
	return $rv;
  }
  
  # in your script
  
  use Some::Module;
  
  my $obj = new Some::Module;
  print $obj->hoge('foo', 'bar'); # ok
  
  print Some::Module::hoge('foo', 'bar'); # ok
  # same as 
  print Some::Module->hoge('foo', 'bar'); # ok
  
  


=head1 DESCRIPTION

B<There's more than one way to do it!>

There are object oriented style and procedural style in this world.
But if you are using Params::Flex, you can write methods in your favorite style
and users can call it in their favorite style. 


=head2 EXPORT

Function "args" was imported by default.
B<If you don't want to import it>, write as below:


 use Params::Flex();


and in function write as below:


  sub hoge {
	my ($self, $arg1, $arg2) = Params::Flex::args(@_);
	...
  }


Instead of writing "Params::Flex::args(@_)", you can write "Params::Flex::a(@_)".
I don't like to write many chars.
This is why I named this module not "Params::Argument" but "Params::Flex".


=head1 FUNCTIONS

=head2 args()
 
  my ($self, $arg1, $arg2) = args(@_);
  # or 
  my ($self, @args) = args(@_);
 
Adjust function arguments.
Always function receives blessed hash reference ($self) as first argument.
Params::Flex creates and supplies it if first argument is not $self.
Auto-created $self is cached so three calling styles as below are equal.
They share same $self.


  Some::Module::func('foo', 'bar');
  Some::Module->func('foo', 'bar');
  func('foo', 'bar'); # if func() was imported.


Of course, $self will be different if function was called in object oriented style.


  $obj1->func('foo', 'bar');
  $obj2->func('foo', 'bar');


Notice that auto-created $self is not initialized.
It is created as an empty blessed hash reference.


=head2 a()

Alias of "args".

=head1 SEE ALSO


=head1 TO DO

I will make option which create object ( do "new Some::Module" ) and set it in
auto-created $self instead empty hash reference.




=head1 AUTHOR

Kagurazaka Mahito , E<lt> mahito@cpan.org E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Kagurazaka Mahito

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.


=cut
