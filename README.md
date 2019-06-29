SUSPENDED!
----------
This library has been replaced by 
[`LTView`](https://github.com/eonil/swift-ltview) 
for more simplicity and won't be maintained anymore
until I need for it.



OT4
====
A persistent datastructure based idempotent outline-view.
Eonil, May 2019.


This is one of trials to make `AppKit` less painful.
Using Apple `AppKit` is painful even for Apple fanatics,
and one of the most painful point is `NSOutlineView`.
As like other classes in `AppKit`, this class is designed
as a half-finished assembly, and you need to implement
the rest to use it. 

There're many opinions about the rest part. 
Apple's original answer for convenience was
Cocoa Binding with `NSTreeController`, but IMO, 
Cocoa Binding is deprecated, and not the solution.



Painless Tree Interaction
----------------------------
`OT4View` is persistent datastructure based tree rendering view with fully idempotent
rendering behavior.

    typealias Source = OT4Source<Int,String>
    typealias View = OT4View<Source,OT4ItemView<String>> 
    let v = View()
    var s = Source() 
    s.timeline.insert("This", for: 1, at: [])
    s.timeline.insert("is", for: 2, at: [0])
    s.timeline.insert("a", for: 3, at: [0,0])
    s.timeline.insert("demo!", for: 4, at: [1])
    v.control(.render(s))

    // Done!

You'll get this.

![ScreenShot](OT4Demo/ScreenShot.png)

Let's consider hash-table look-up and tree navigation as `O(1)`.

As `Source` is persistent, it keeps all versions of snapshots and changed key set.
With that informations, view can recover diff information quickly in `O(d)` 
time where `d` is number of changed nodes. 
Tree mutators like inserting/updating/removing node takes `O(1)` time.

Regardless of how many operations you performed, only last 4 operations 
will be tracked at maximum. Tracking informations for any older operation will be lost.
(only tracking informations, final snapshot will be kept)
If diff information is lost and the view cannot continuously track the state, 
rendering takes `O(n)` time where `n` is total number of nodes in the tree.

Also rendering is fully **idempotent**. Passing same value to the view always
provides same final rendering.

    v.control(.render(s))
    v.control(.render(s))
    v.control(.render(s))

    // Same result.

You also can track selections.

    v.note = { [weak self] n 
        switch n {
        case .interaction(let ix):
        let ids = Array(ix.selectedIdentities)
        print("selected: \(ids)")
    }

You gonna see something like this.

    selected: [111]
    selected: [222]
    selected: [444]
    
    

For Snapshot to Snapshot Rendering
-----------------------------------------------
`OT4Source` based rendering requires you to keep once
created value and mutate it in-place to keep internally
generated diff informations. But sometimes you can't always
build your data, and need only snapshots without intermediate
operations. In that case, you can use `OT4SnapshotView` 
instead of for snapshot to snapshot rendering.

    let v = OT4SnapshotView<OT4KeyValueTree>
    var s = OT4KeyValueTree(key: 111, value: "top") 
    s.subtrees.append(OT4KeyValueTree(key: 222, value: "first")
    s.subtrees.append(OT4KeyValueTree(key: 333, value: "second")
    s.subtrees.append(OT4KeyValueTree(key: 444, value: "third")
    v.control(.render(s))

    // Done!

But rendering with `OT4SnapshotView` always takes
`O(n log n)` where `n` is total number of nodes in tree.
Choose if you need something quick and dirty working stuff.

Or if you're willing to write more code, you can implement
`OT4SourceProtocol` yourself. All data consumption is
protocol based. You can wrap your data to feed it to 
`OT4View`.



Safety
--------
`OT4SnapshotView` and `OT4View` provide full type-safety.
You don't need to worry and check types becuase compiler
will do the job for you. Also as it is fully type annotated,
your IDE can provide nice auto-completion support.

Performance
----------------
In my benchmark, `OT4View` performs at 1,000 ops/s with 
100,000 existing items with a few seconds of initial dealy. 
Single operation takes about 1ms to finish. 
It seems major bottleneck is in my HAMT implementation.

But It Does Not Cover Everything
----------------------------------------
Some features of `NSOutlineView` is context-sensitive, therefore
cannot be represented as value. For example, there's `clickedRow`
property. When you open a context-menu on a node, this property
provides end-user clicked-row, but only at the moment, and
disappears immediately.
Therefore, I cannot support the feature. Therefore, `OT4View` also
provides some members to access such features synchronously.



License & Credits
----------------------
This code is licensed under "MIT License".
Contributions will also be under "MIT License".
Copyright Eonil, Hoon H.. 2019.
