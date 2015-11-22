unit class Pod::NodeWalker;

use Pod::NodeListener;

has Pod::NodeListener $!listener;

submethod BUILD (Pod::NodeListener :$!listener) { }

method walk-pod (Any:D $node) {
    given $node {
        when Array {
            $node.map({ self.walk-pod($_) });
        }
        when Pod::Block::Table {
            $!listener.start($node);
            $node.contents.map({ $!listener.table-row($_) });
            $!listener.end($node);
        }
        when Pod::Config {
            $!listener.config($node);
        }
        when Str {
            # A paragraph that begins with a formatting code produces an empty
            # string in its contents, which is useless to pass on.
            $!listener.text($node) if $node.chars;
        }
        default {
            if $node.can('contents') {
                if $!listener.start($node) {
                    $node.contents.map({ self.walk-pod($_) });
                    $!listener.end($node);
                }
            }
            else {
                die "Unknown node type {$node.WHAT}!";
            }
        }
    }
}

method text-contents-of(Pod::Block:D $node) {
    my @text = gather {
        for $node.contents -> $thing {
            if $thing ~~ Str {
                take $thing;
            }
            else {
                take self.text-contents-of($thing);
            }
        }
    };
    return [~] @text;
}

=begin pod

=NAME Pod::NodeWalker

Walk a Pod tree and generate an event for each node.

=SYNOPSIS

    my $to-html = Pod::To::HTML.new(...);
    Pod::NodeWalker.new( :listener($to-html) ).walk-pod($=pod);

=DESCRIPTION

This class provides an API for walking a pod tree (as provided by
C<$=pod>). Each node in the tree will trigger one or more events. These events
cause methods to be called on a listener object that your provide. This lets
you do something without a Pod document without having to know much about the
underlying tree structure of Pod.

=METHOD Pod::NodeWalker.new( :listener( Pod::NodeListener $object ) )

The constructor expects a single argument named C<listener>. This object must
implement the L<Pod::NodeListener> API.

=METHOD $walker.walk-pod($pod)

This method walks through a pod tree starting with the top node in
C<$pod>. You can provide either an array of pod nodes (as stored in C<$=pod>)
or a single top-level node (such as C<$=pod[0]>).

=METHOD $walker.text-contents-of($pod)

Given a L<Pod::Block> of any sort, this method recursively descends the blocks
contents and returns the concatenation of all the plain text that it finds.

=AUTHOR Dave Rolsky <autarch@urth.org>

=COPYRIGHT

This software is copyright (c) 2015 by Dave Rolsky.

=LICENSE

This is free software; you can redistribute it and/or modify it under the
terms of The Artistic License 2.0.

=end pod
