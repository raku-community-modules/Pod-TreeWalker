unit role Pod::TreeWalker::Listener;

# Only include bare Pod::Block objects by default.  You will need
# to add other candidates to allow other node types.
multi method start(Pod::Block:D $node) { self.WHAT =:= Pod::Block }
multi method end(  Pod::Block:D $node) { self.WHAT =:= Pod::Block }

method start-list(Int :$level, Bool :$numbered) { }
method end-list(Int :$level, Bool :$numbered) { }
method table-row(Array:D $row) { }
method config(Pod::Config:D $node) {  }
method text(Str:D $text) {  }

=begin pod

=head1 NAME

Pod::TreeWalker::Listener - Role for classes which handle events produced by Pod::TreeWalker

=head1 SYNOPSIS

=begin code :lang<raku>

class MyListener does Pod::TreeWalker::Listener {
    multi method start(Pod::Heading $node --> False) {
        say "Heading level {$node.level}";
    }

    multi method end(  Pod::Heading $node --> False) {
        say "Heading level {$node.level}";
    }

    method table-row (Array $row) { ... }
}

=end code

=head1 DESCRIPTION

This role defines the API which objects passed to C<Pod::TreeWalker>'s
constructor are expected to implement.

=head1 METHODS TO BE IMPLEMENTED

=head2 start

=begin code :lang<raku>

$listener.start(... $node --> False)

=end code

The C<start> method is a multi method which is called for most Pod objects. It
is passed a L<doc:Pod::Block> object of some sort.

If this method returns C<False>, then the C<Pod::TreeWalker> will not look
at the contents of the node, nor will it call the corresponding C<end> method
for the node.

=head3 Tables

The headers of a table (from C<$node.headers>) are passed as an array of
L<Pod::Blocks>.

=head2 end

=begin code :lang<raku>

$listener.end(  ... $node --> False)

=end code

The C<end> is a multi method that is called for most Pod objects.  It is
passed a C<Pod::Block> object of some sort.

=head2 start-list

=begin code :lang<raku>

$listener.start-list(Int :$level, Bool :numbered)

=end code

This method is called whenever a new list level is encountered. It can be
called multiple times in a row if a list item is introduced that skips levels,
for example:

=begin code

=item1 start-list is called once
=item3 start-list is called twice

=end code

=head2 end-list

=begin code :lang<raku>

$listener.end-list(Int :$level, Bool :numbered)

=end code

This method is called whenever a list level is done. List C<start-list>, it
can be called multiple times in a row.

=head2 table-row

=begin code :lang<raku>

$listener.table-row(Array $row)

=end code

This method is called once for each row in a table. Each element of C<$row>
will in turn be a L<Pod::Block>.

=head2 config

=begin code :lang<raku>

$listener.config(Pod::Config $node --> False)

=end code

This method is called for Pod config declarations.

=head2 text

=begin code :lang<raku>

$listener.text(Str $text)

=end code

This method is called for plain text, usually inside a paragraph block.

=head1 AUTHOR

Dave Rolsky

=head1 COPYRIGHT AND LICENSE

Copyright 2015 - 2018 Dave Rolsky

Copyright 2019 - 2025 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
