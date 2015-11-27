unit class Pod::NodeWalker;

use Pod::NodeListener;

has Pod::NodeListener $!listener;

has Int $!list-level = 0;
has Int $!list-start-depth = 0;
has Bool $!last-list-was-numbered = False;

submethod BUILD (Pod::NodeListener :$!listener) { }

method walk-pod (Any:D $node, Int $depth = 0) {
    self!maybe-end-all-lists( $node, $depth );

    given $node {
        when Array {
            $node.map({ self.walk-pod( $_, $depth + 1 ) });
        }
        when Pod::Item {
            if $node.level > $!list-level {
                $!list-start-depth ||= $depth;
                $!listener.start-list( :level($_), :numbered( ?$node.config<numbered> ) )
                    for ($!list-level + 1) .. $node.level;
                $!list-level = $node.level;
                $!last-list-was-numbered = ?$node.config<numbered>;
            }
            elsif $!list-level > $node.level {
                self!end-lists-to( $node.level );
            }
            
            self!send-events-for-node( $node, $depth );
        }
        # See https://rt.perl.org/Ticket/Display.html?id=114480 - table
        # content should be parsed as POD, not just passed along as raw
        # text. For now we fix it ourselves.
        when Pod::Block::Table {
            # As of 2015-11-26 $node.caption isn't populated. See
            # https://rt.perl.org/Ticket/Display.html?id=126740. The caption in
            # the config includes quotes from :caption('foo'). See
            # https://rt.perl.org/Ticket/Display.html?id=126742.
            my $caption = $node.caption;
            if ! $caption && $node.config<caption> {
                $caption = $node.config<caption>:delete;
                $caption.subst-mutate( /^<[ ' " ]> |<[ ' " ]>$/, q{}, :g );
            }

            my $new-node = Pod::Block::Table.new(
                :caption($caption),
                :config( $node.config ),
                :headers( $node.headers.map({ self!podify($_) }) ),
                :contents( $node.contents ),
            );

            $!listener.start($new-node);
            for $new-node.contents -> $row {
                $!listener.table-row( [ $row.map({ self!podify($_) } ) ] );
            }
            $!listener.end($new-node);
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
            self!send-events-for-node( $node, $depth );
        }
    }
}

method !send-events-for-node (Pod::Block $node, Int $depth) {
    if $node.can('contents') {
        if $!listener.start($node) {
            $node.contents.map({ self.walk-pod( $_, $depth + 1 ) });
            self!maybe-end-all-lists( $node, $depth );
            $!listener.end($node);
        }
    }
    else {
        die "Unknown node type {$node.WHAT}!";
    }
}

method !maybe-end-all-lists (Any $node, Int $depth) {
    return unless $!list-level;
    return unless $depth <= $!list-start-depth;
    return if  $node.isa(Pod::Item);

    self!end-lists-to(0);
    $!list-start-depth = 0;
}

method !end-lists-to (Int $level) {
    $!listener.end-list( :level($_), :numbered( $!last-list-was-numbered ) )
        for $!list-level ... $level + 1;
    $!list-level = $level;
}

method !podify (Any $thing) {
    return $thing
       if $thing ~~ Pod::Block;

    return EVAL("=begin pod\n\n$thing\n\n=end pod\n; \$=pod[0]");
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
