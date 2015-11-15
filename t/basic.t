use v6;
use Test;
use lib 'lib', 't/lib';;
use Pod::NodeWalker;
use TestListener;

my $pod_i = 0;

=begin pod
=head1 HEADING1
=head2 HEADING2
=end pod

subtest {
    my $l = TestListener.new;
    Pod::NodeWalker.new(:listener($l)).walk-pod($=pod[$pod_i++]);

    my @expect = (
         { :start, :type('named'), :name('pod') },
         { :start, :type('heading'), :level(1) },
         { :start, :type('para') },
         { :text('HEADING1') },
         { :end, :type('para') },
         { :end, :type('heading'), :level(1) },
         { :start, :type('heading'), :level(2) },
         { :start, :type('para') },
         { :text('HEADING2') },
         { :end, :type('para') },
         { :end, :type('heading'), :level(2) },
         { :end, :type('named'), :name('pod') },
    );

    is-deeply $l.events, @expect, 'got expected events';
}, 'single =head1';

=begin pod

    $code.goes-here;

=end pod

subtest {
    my $l = TestListener.new;
    Pod::NodeWalker.new(:listener($l)).walk-pod($=pod[$pod_i++]);

    my @expect = (
         { :start, :type('named'), :name('pod') },
         { :start, :type('code'), :allowed([]) },
         { :text('$code.goes-here;') },
         { :end, :type('code'), :allowed([]) },
         { :end, :type('named'), :name('pod') },
    );

    is-deeply $l.events, @expect, 'got expected events';
}, 'code block';

=begin pod

=comment Trenchant

=end pod

subtest {

    my $l = TestListener.new;
    Pod::NodeWalker.new(:listener($l)).walk-pod($=pod[$pod_i++]);

    my @expect = (
         { :start, :type('named'), :name('pod') },
         { :start, :type('comment') },
         { :text("Trenchant\n") },
         { :end, :type('comment') },
         { :end, :type('named'), :name('pod') },
    );

    is-deeply $l.events, @expect, 'got expected events';
}, 'pod comment';

=begin pod

A simple paragraph.

And another.

=end pod

subtest {

    my $l = TestListener.new;
    Pod::NodeWalker.new(:listener($l)).walk-pod($=pod[$pod_i++]);

    my @expect = (
         { :start, :type('named'), :name('pod') },
         { :start, :type('para') },
         { :text("A simple paragraph.") },
         { :end, :type('para') },
         { :start, :type('para') },
         { :text("And another.") },
         { :end, :type('para') },
         { :end, :type('named'), :name('pod') },
    );

    is-deeply $l.events, @expect, 'got expected events';
}, 'two paragraphs';

=begin pod

=begin table :caption<Foo and Bar>

    Name    Color    Size
    ===========================
    Foo     Blue     Fourty-Two
    Bar     Green    Seven

=end table

=end pod

subtest {
    my $l = TestListener.new;
    Pod::NodeWalker.new(:listener($l)).walk-pod($=pod[$pod_i++]);

    my @expect = (
         { :start, :type('named'), :name('pod') },
         { :start, :type('table'), :caption('Foo and Bar'), :headers([< Name Color Size >]) },
         { :table-row([< Foo Blue Fourty-Two > ]) },
         { :table-row([< Bar Green Seven > ]) },
         { :end, :type('table') },
         { :end, :type('named'), :name('pod') },
    );

    is-deeply $l.events, @expect, 'got expected events';
}, 'table';

=begin pod

B<Bold>, I<italic>, and C<code>.

=end pod

subtest {
    my $l = TestListener.new;
    Pod::NodeWalker.new(:listener($l)).walk-pod($=pod[$pod_i++]);

    my @expect = (
         { :start, :type('named'), :name('pod') },
         { :start, :type('para') },
         { :start, :type('formatting-code'), :code-type('B'), :meta([]) },
         { :text('Bold') },
         { :end, :type('formatting-code'), :code-type('B'), :meta([]) },
         { :text(', ') },
         { :start, :type('formatting-code'), :code-type('I'), :meta([]) },
         { :text('italic') },
         { :end, :type('formatting-code'), :code-type('I'), :meta([]) },
         { :text(', and ') },
         { :start, :type('formatting-code'), :code-type('C'), :meta([]) },
         { :text('code') },
         { :end, :type('formatting-code'), :code-type('C'), :meta([]) },
         { :text('.') },
         { :end, :type('para') },
         { :end, :type('named'), :name('pod') },
    );

    is-deeply $l.events, @expect, 'got expected events';
}, 'formatting codes';

=begin pod
=config everything :with<feeling> :formatting<pretty>
=end pod

subtest {
    my $l = TestListener.new;
    Pod::NodeWalker.new(:listener($l)).walk-pod($=pod[$pod_i++]);

    my @expect = (
         { :start, :type('named'), :name('pod') },
         { :config-type('everything'), :config({ :with('feeling'), :formatting('pretty') }) },
         { :end, :type('named'), :name('pod') },
    );

    is-deeply $l.events, @expect, 'got expected events';
}, 'code block';

=begin pod

=item1 First
=item1 Second
=item2 .2
=item1 Third

=end pod

subtest {
    my $l = TestListener.new;
    Pod::NodeWalker.new(:listener($l)).walk-pod($=pod[$pod_i++]);

    my @expect = (
         { :start, :type('named'), :name('pod') },
         { :start, :type('item'), :level(1) },
         { :start, :type('para') },
         { :text('First') },
         { :end, :type('para') },
         { :end, :type('item'), :level(1) },
         { :start, :type('item'), :level(1) },
         { :start, :type('para') },
         { :text('Second') },
         { :end, :type('para') },
         { :end, :type('item'), :level(1) },
         { :start, :type('item'), :level(2) },
         { :start, :type('para') },
         { :text('.2') },
         { :end, :type('para') },
         { :end, :type('item'), :level(2) },
         { :start, :type('item'), :level(1) },
         { :start, :type('para') },
         { :text('Third') },
         { :end, :type('para') },
         { :end, :type('item'), :level(1) },
         { :end, :type('named'), :name('pod') },
    );

    is-deeply $l.events, @expect, 'got expected events';
}, 'items';

=begin pod
=head1 HEADING
=title TITLE GOES HERE

And a paragraph of text
=end pod

subtest {
    my $l = TestListener.new;
    Pod::NodeWalker.new(:listener($l)).walk-pod($=pod[$pod_i++]);

    my @expect = (
         { :start, :type('named'), :name('pod') },
         { :start, :type('heading'), :level(1) },
         { :start, :type('para') },
         { :text('HEADING') },
         { :end, :type('para') },
         { :end, :type('heading'), :level(1) },
         { :start, :type('named'), :name('title') },
         { :start, :type('para') },
         { :text('TITLE GOES HERE') },
         { :end, :type('para') },
         { :end, :type('named'), :name('title') },
         { :start, :type('para') },
         { :text('And a paragraph of text') },
         { :end, :type('para') },
         { :end, :type('named'), :name('pod') },
    );

    is-deeply $l.events, @expect, 'got expected events';
}, 'heading, named block, and paragraph';

done-testing;
