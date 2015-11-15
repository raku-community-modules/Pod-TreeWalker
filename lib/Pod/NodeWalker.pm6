unit class Pod::NodeWalker;

use Pod::NodeListener;

has Pod::NodeListener $!listener;

submethod BUILD (Pod::NodeListener :$!listener) { }

method walk-pod ($pod) {
    self!visit($pod);
}

method !visit ($node) {
    given $node.WHAT {
        when Pod::Block::Code {
            $!listener.start-code-block($node);
            $node.contents.map: { self.walk-pod($_) };
            $!listener.end-code-block($node);
        }
        when Pod::Block::Comment {
            $!listener.start-comment-block($node);
            $node.contents.map: { self.walk-pod($_) };
            $!listener.end-comment-block($node);
        }
        when Pod::Block::Declarator {
            $!listener.start-declarator-block($node);
            $node.contents.map: { self.walk-pod($_) };
            $!listener.end-declarator-block($node);
        }
        when Pod::Block::Named {
            $!listener.start-named-block($node);
            $node.contents.map: { self.walk-pod($_) };
            $!listener.end-named-block($node);
        }
        when Pod::Block::Para {
            $!listener.start-para-block($node);
            $node.contents.map: { self.walk-pod($_) };
            $!listener.end-para-block($node);
        }
        when Pod::Block::Table {
            $!listener.start-table-block($node);
            $node.contents.map: { self.walk-pod($_) };
            $!listener.ed-table-block($node);
        }
        when Pod::FormattingCode {
            $!listener.start-formatting-code($node);
            $node.contents.map: { self.walk-pod($_) };
            $!listener.end-formatting-code($node);
        }
        when Pod::Heading {
            $!listener.start-heading($node);
            $node.contents.map: { self.walk-pod($_) };
            $!listener.end-heading($node);
        }
        when Pod::Item {
            $!listener.start-item($node);
            $node.contents.map: { self.walk-pod($_) };
            $!listener.end-item($node);
        }
        when Pod::Raw {
            $!listener.start-raw($node);
            $node.contents.map: { self.walk-pod($_) };
            $!listener.end-raw($node);
        }
        when Pod::Config {
            $!listener.config($node);
        }
        when Str {
            $!listener.text($node);
        }
        default {
            die "Unknown node type {$node.WHAT}!";
        }
    }
}
