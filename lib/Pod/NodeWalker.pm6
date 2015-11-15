unit class Pod::NodeWalker;

use Pod::NodeListener;

has Pod::NodeListener $!listener;

submethod BUILD (Pod::NodeListener :$!listener) { }

method walk-pod (Any:D $node) {
    given $node {
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
                $!listener.start($node);
                $node.contents.map({ self.walk-pod($_) });
                $!listener.end($node);
            }
            else {
                die "Unknown node type {$node.WHAT}!";
            }
        }
    }
}
