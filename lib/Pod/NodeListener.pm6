unit role Pod::NodeListener;

# These multi methods cause the interpreter to complain about ambiguous calls,
# even though it seems like the role method should be shadowed by the class's
# method.

multi method start (Pod::Block:D $node) { }

# multi method start (Pod::Block::Code $node) {  }
# multi method end (Pod::Block::Code $node) {  }
# multi method start (Pod::Block::Comment $node) {  }
# multi method end (Pod::Block::Comment $node) {  }
# multi method start (Pod::Block::Declarator $node) {  }
# multi method end (Pod::Block::Declarator $node) {  }
# multi method start (Pod::Block::Named $node) {  }
# multi method end (Pod::Block::Named $node) {  }
# multi method start (Pod::Block::Para $node) {  }
# multi method end (Pod::Block::Para $node) {  }
# multi method start (Pod::Block::Table $node) {  }
# multi method end (Pod::Block::Table $node) {  }
# multi method start (Pod::FormattingCode $node) {  }
# multi method end (Pod::FormattingCode $node) {  }
# multi method start (Pod::Heading $node) {  }
# multi method end (Pod::Heading $node) {  }
# multi method start (Pod::Item $node) {  }
# multi method end (Pod::Item $node) {  }
# multi method start (Pod::Raw $node) {  }
# multi method end (Pod::Raw $node) {  }

method table-row (Array $row) { }
method config (Pod::Config $node) {  }
method text (Str $text) {  }
