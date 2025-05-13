NAME
====

Pod::TreeWalker::Listener - Role for classes which handle events produced by Pod::TreeWalker

SYNOPSIS
========

```raku
class MyListener does Pod::TreeWalker::Listener {
    multi method start(Pod::Heading $node --> False) {
        say "Heading level {$node.level}";
    }

    multi method end(  Pod::Heading $node --> False) {
        say "Heading level {$node.level}";
    }

    method table-row (Array $row) { ... }
}
```

DESCRIPTION
===========

This role defines the API which objects passed to `Pod::TreeWalker`'s constructor are expected to implement.

METHODS TO BE IMPLEMENTED
=========================

start
-----

```raku
$listener.start(... $node --> False)
```

The `start` method is a multi method which is called for most Pod objects. It is passed a [doc:Pod::Block](doc:Pod::Block) object of some sort.

If this method returns `False`, then the `Pod::TreeWalker` will not look at the contents of the node, nor will it call the corresponding `end` method for the node.

### Tables

The headers of a table (from `$node.headers`) are passed as an array of [Pod::Blocks](Pod::Blocks).

end
---

```raku
$listener.end(  ... $node --> False)
```

The `end` is a multi method that is called for most Pod objects. It is passed a `Pod::Block` object of some sort.

start-list
----------

```raku
$listener.start-list(Int :$level, Bool :numbered)
```

This method is called whenever a new list level is encountered. It can be called multiple times in a row if a list item is introduced that skips levels, for example:

    =item1 start-list is called once
    =item3 start-list is called twice

end-list
--------

```raku
$listener.end-list(Int :$level, Bool :numbered)
```

This method is called whenever a list level is done. List `start-list`, it can be called multiple times in a row.

table-row
---------

```raku
$listener.table-row(Array $row)
```

This method is called once for each row in a table. Each element of `$row` will in turn be a [Pod::Block](Pod::Block).

config
------

```raku
$listener.config(Pod::Config $node --> False)
```

This method is called for Pod config declarations.

text
----

```raku
$listener.text(Str $text)
```

This method is called for plain text, usually inside a paragraph block.

AUTHOR
======

Dave Rolsky

COPYRIGHT AND LICENSE
=====================

Copyright 2015 - 2018 Dave Rolsky

Copyright 2019 - 2025 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

