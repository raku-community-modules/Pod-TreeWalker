use v6;
use Test;
use lib 'lib', 't/lib';;
use Pod::TreeWalker;
use TestListener;

my $pod_i = 0;

=begin pod

Para 1

=item1 Item

Para 2

=end pod

subtest {
    my $l = TestListener.new;
    Pod::TreeWalker.new(:listener($l)).walk-pod($=pod[$pod_i++]);

    my @expect = (
         { :start, :type('named'), :name('pod') },
         { :start, :type('para') },
         { :text('Para 1') },
         { :end, :type('para') },
         { :start, :type('list'), :level(1), :!numbered },
         { :start, :type('item'), :level(1) },
         { :start, :type('para') },
         { :text('Item') },
         { :end, :type('para') },
         { :end, :type('item'), :level(1) },
         { :end, :type('list'), :level(1), :!numbered },
         { :start, :type('para') },
         { :text('Para 2') },
         { :end, :type('para') },
         { :end, :type('named'), :name('pod') },
    );

    is-deeply $l.events, @expect, 'got expected events';
}, 'single-item list surrounded by paragraphs';

=begin pod

=for item1 :numbered
First

=for item1 :numbered
Second

=end pod

subtest {
    my $l = TestListener.new;
    Pod::TreeWalker.new(:listener($l)).walk-pod($=pod[$pod_i++]);

    my @expect = (
         { :start, :type('named'), :name('pod') },
         { :start, :type('list'), :level(1), :numbered },
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
         { :end, :type('list'), :level(1), :numbered },
         { :end, :type('named'), :name('pod') },
    );

    is-deeply $l.events, @expect, 'got expected events';
}, '=for item with numbered items';

=begin pod

=item1 First
=item1 Second
=item2 .2
=item1 Third

=end pod

subtest {
    my $l = TestListener.new;
    Pod::TreeWalker.new(:listener($l)).walk-pod($=pod[$pod_i++]);

    my @expect = (
         { :start, :type('named'), :name('pod') },
         { :start, :type('list'), :level(1), :!numbered },
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
         { :start, :type('list'), :level(2), :!numbered },
         { :start, :type('item'), :level(2) },
         { :start, :type('para') },
         { :text('.2') },
         { :end, :type('para') },
         { :end, :type('item'), :level(2) },
         { :end, :type('list'), :level(2), :!numbered },
         { :start, :type('item'), :level(1) },
         { :start, :type('para') },
         { :text('Third') },
         { :end, :type('para') },
         { :end, :type('item'), :level(1) },
         { :end, :type('list'), :level(1), :!numbered },
         { :end, :type('named'), :name('pod') },
    );

    is-deeply $l.events, @expect, 'got expected events';
}, '2 levels of =item';

=begin pod

=item2 Straight to 2nd
=item4 and then 4th
=item3 what, 3rd?
=item1 First?!
=item1 I'm lost now

=end pod

subtest {
    my $l = TestListener.new;
    Pod::TreeWalker.new(:listener($l)).walk-pod($=pod[$pod_i++]);

    my @expect = (
         { :start, :type('named'), :name('pod') },
         { :start, :type('list'), :level(1), :!numbered },
         { :start, :type('list'), :level(2), :!numbered },
         { :start, :type('item'), :level(2) },
         { :start, :type('para') },
         { :text('Straight to 2nd') },
         { :end, :type('para') },
         { :end, :type('item'), :level(2) },
         { :start, :type('list'), :level(3), :!numbered },
         { :start, :type('list'), :level(4), :!numbered },
         { :start, :type('item'), :level(4) },
         { :start, :type('para') },
         { :text('and then 4th') },
         { :end, :type('para') },
         { :end, :type('item'), :level(4) },
         { :end, :type('list'), :level(4), :!numbered },
         { :start, :type('item'), :level(3) },
         { :start, :type('para') },
         { :text('what, 3rd?') },
         { :end, :type('para') },
         { :end, :type('item'), :level(3) },
         { :end, :type('list'), :level(3), :!numbered },
         { :end, :type('list'), :level(2), :!numbered },
         { :start, :type('item'), :level(1) },
         { :start, :type('para') },
         { :text('First?!') },
         { :end, :type('para') },
         { :end, :type('item'), :level(1) },
         { :start, :type('item'), :level(1) },
         { :start, :type('para') },
         { :text(q{I'm lost now}) },
         { :end, :type('para') },
         { :end, :type('item'), :level(1) },
         { :end, :type('list'), :level(1), :!numbered },
         { :end, :type('named'), :name('pod') },
    );

    is-deeply $l.events, @expect, 'got expected events';
}, 'jumble of list items skipping levels up and down';

done-testing;
