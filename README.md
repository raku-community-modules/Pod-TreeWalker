[![Actions Status](https://github.com/raku-community-modules/Pod-TreeWalker/actions/workflows/linux.yml/badge.svg)](https://github.com/raku-community-modules/Pod-TreeWalker/actions) [![Actions Status](https://github.com/raku-community-modules/Pod-TreeWalker/actions/workflows/macos.yml/badge.svg)](https://github.com/raku-community-modules/Pod-TreeWalker/actions) [![Actions Status](https://github.com/raku-community-modules/Pod-TreeWalker/actions/workflows/windows.yml/badge.svg)](https://github.com/raku-community-modules/Pod-TreeWalker/actions)

NAME
====

Pod::TreeWalker - Walk a Pod tree and generate an event for each node

SYNOPSIS
========

```raku
use Pod::TreeWalker;

my $L = My::Listener.new;
my $o = Pod::TreeWalker.new: :listener($L);
my @events = $o.walk-pod($=pod);
```

DESCRIPTION
===========

This class provides an API for walking a pod tree (as provided by `$=pod`). Each node in the tree will trigger one or more events. These events cause methods to be called on a listener object that you provide. This lets you do something with a Pod document without having to know much about the underlying tree structure of Pod.

Note: Use distribution `Pod::Load` for an easy way to access the Pod from a file or a string.

METHODS
=======

new
---

```raku
my $walker = Pod::TreeWalker.new: :listener($object);
```

The constructor requires a single named argument `:listener`. This object must implement the `Pod::TreeWalker::Listener` API as demonstrated in file './t/lib/TestListener.rakumod'. See more details in [LISTENER](./LISTENER.md).

walk-pod
--------

```raku
my @events = $walker.walk-pod($pod);
```

This method walks through a pod tree starting with the top node in `$pod`. You can provide either an array of pod nodes (as stored in `$=pod`) or a single top-level node (such as `$=pod[0]`). The `@events` list provides the details of each pod node encountered.

text-content-of
---------------

```raku
say $walker.text-contents-of($pod)
```

Given a `Pod::Block` of any sort, this method recursively descends the blocks contents and returns the concatenation of all the plain text that it finds.

AUTHOR
======

Dave Rolsky

COPYRIGHT AND LICENSE
=====================

Copyright 2015 - 2018 Dave Rolsky

Copyright 2019 - 2025 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

