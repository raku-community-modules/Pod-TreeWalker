use v6;
use Test;
use lib 'lib';
use Pod::NodeWalker;

class Listener does Pod::NodeListener {
    has @.events;

    method start-code-block (Pod::Block::Code $node) {
        @.events.push( { :start, type => 'code' } );
    }
    method end-code-block (Pod::Block::Code $node) {
        @.events.push( { :end, type => 'code' } );
    }

    method start-comment-block (Pod::Block::Comment $node) {
        @.events.push( { :start, type => 'comment' } );
    }
    method end-comment-block (Pod::Block::Comment $node) {
        @.events.push( { :end, type => 'comment' } );
    }

    method start-declarator-block (Pod::Block::Declarator $node) {
        @.events.push( { :start, type => 'declarator' } );
    }
    method end-declarator-block (Pod::Block::Declarator $node) {
        @.events.push( { :end, type => 'declarator' } );
    }

    method start-named-block (Pod::Block::Named $node) {
        @.events.push( { :start, type => 'named', name => $node.name } );
    }
    method end-named-block (Pod::Block::Named $node) {
        @.events.push( { :end, type => 'named', name => $node.name } );
    }

    method start-para-block (Pod::Block::Para $node) {
        @.events.push( { :start, type => 'para' } );
    }
    method end-para-block (Pod::Block::Para $node) {
        @.events.push( { :end, type => 'para' } );
    }

    method start-table-block (Pod::Block::Table $node) {
        @.events.push( { :start, type => 'table' } );
    }
    method end-table-block (Pod::Block::Table $node) {
        @.events.push( { :end, type => 'table' } );
    }

    method start-formatting-code (Pod::Block::Table $node) {
        @.events.push( { :start, type => 'formatting-code', type => $node.type, meta => $node.meta } );
    }
    method end-formatting-code (Pod::Block::Table $node) {
        @.events.push( { :end, type => 'formatting-code', type => $node.type, meta => $node.meta } );
    }

    method start-heading (Pod::Heading $node) {
        @.events.push( { :start, type => 'heading', level => $node.level } );
    }
    method end-heading (Pod::Heading $node) {
        @.events.push( { :end, type => 'heading', level => $node.level } );
    }

    method start-item (Pod::Item $node) {
        @.events.push( { :start, type => 'item', level => $node.level} );
    }
    method end-item (Pod::Item $node) {
        @.events.push( { :end, type => 'item', level => $node.level } );
    }

    method config (Pod::Config $node) {
        @.events.push( { config => $node.config } );
    }
    method raw (Pod::Raw $node) {
        @.events.push( { config => $node.config } );
    }

    method text (Str $text) {
        @.events.push( { text => $text } );
    }
}

=begin pod
=head1 HEADING
=end pod

subtest {
    my $l = Listener.new;
    Pod::NodeWalker.new(:listener($l)).walk-pod($=pod[0]);

    my @expect = (
         { :start, type => 'named', name => 'pod' },
         { :start, type => 'heading', level => 1 },
         { :start, type => 'para' },
         { text => 'HEADING' },
         { :end, type => 'para' },
         { :end, type => 'heading', level => 1 },
         { :end, type => 'named', name => 'pod' },
    );

    is-deeply $l.events, @expect, 'got expected events';
}, 'single =head1';

=begin pod
=head1 HEADING
=title TITLE GOES HERE

And a paragraph of text
=end pod

subtest {
    my $l = Listener.new;
    Pod::NodeWalker.new(:listener($l)).walk-pod($=pod[1]);

    my @expect = (
         { :start, type => 'named', name => 'pod' },
         { :start, type => 'heading', level => 1 },
         { :start, type => 'para' },
         { text => 'HEADING' },
         { :end, type => 'para' },
         { :end, type => 'heading', level => 1 },
         { :start, type => 'named', name => 'title' },
         { :start, type => 'para' },
         { text => 'TITLE GOES HERE' },
         { :end, type => 'para' },
         { :end, type => 'named', name => 'title' },
         { :start, type => 'para' },
         { text => 'And a paragraph of text' },
         { :end, type => 'para' },
         { :end, type => 'named', name => 'pod' },
    );

    is-deeply $l.events, @expect, 'got expected events';
}, 'heading, named block, and paragraph';

done-testing;
