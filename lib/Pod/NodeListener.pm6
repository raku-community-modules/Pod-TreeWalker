unit role Pod::NodeListener;

method start-code-block (Pod::Block::Code $node) { }
method end-code-block (Pod::Block::Code $node) { }
method start-comment-block (Pod::Block::Comment $node) { }
method end-comment-block (Pod::Block::Comment $node) { }
method start-declarator-block (Pod::Block::Declarator $node) { }
method end-declarator-block (Pod::Block::Declarator $node) { }
method start-named-block (Pod::Block::Named $node) { }
method end-named-block (Pod::Block::Named $node) { }
method start-para-block (Pod::Block::Para $node) { }
method end-para-block (Pod::Block::Para $node) { }
method start-table-block (Pod::Block::Table $node) { }
method end-table-block (Pod::Block::Table $node) { }
method start-formatting-code (Pod::FormattingCode $node) { }
method end-formatting-code (Pod::FormattingCode $node) { }
method start-heading (Pod::Heading $node) { }
method end-heading (Pod::Heading $node) { }
method start-item (Pod::Item $node) { }
method end-item (Pod::Item $node) { }
method start-raw (Pod::Raw $node) { }
method end-raw (Pod::Raw $node) { }

method config (Pod::Config $node) { }
method text (Str $text) { }
