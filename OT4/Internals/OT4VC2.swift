//
//  OT4VC2.swift
//  OT4View
//
//  Created by Henry on 2019/05/18.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation
import AppKit

///
///
/// Outline tree controller exposed internally for easier testing.
///
/// Sole purpose of this class is exposing internal controller
/// to test facility. To test states at each stage, all internal
/// states are exposed publicly but SHOULD NOT be modified
/// externally. To prevent such access all properties are
/// externally read-only, but I couldn't prevent access to mutators
/// of reference-types.
///
/// Access only `control/note` directly. DO NOT modify
/// any other properties.
///
/// The only stuffs are allowed to access are;
/// - `control`
/// - `note`
/// - `outlineView` to place the view instance on a superview.
///   DO NOT modify any of its properties externally.
///
/// - Note:
///     When you write test code, please note that `control`/`note`
///     are all asynchronous. You need to cycle main thread GCDQ
///     to make sure them finished. Easy way to do this is
///     pushing your checking code to `OperationQueue.main`.
///
final class OT4VC2<Source,ItemView>:
    NSObject,
    NSOutlineViewDataSource,
    NSOutlineViewDelegate
    where
    Source: OT4SourceProtocol,
    Source.Timeline.Snapshot: OT4DefaultProtocol,
    ItemView: OT4ItemViewProtocol,
ItemView.State == Source.Timeline.Snapshot.State {
    typealias View = OT4View<Source,ItemView>
    typealias Snapshot = Source.Timeline.Snapshot
    typealias RefProxy = OT4RefProxy2<Snapshot.Identity>
    typealias Interaction = View.Interaction
    typealias Control = View.Control
    typealias Note = View.Note

    override init() {
        super.init()
        outlineView.allowsMultipleSelection = true
        outlineView.addTableColumn(outlineColumn)
        outlineView.outlineTableColumn = outlineColumn
        outlineView.dataSource = self
        outlineView.delegate = self
        outlineView.reloadData()
        // This line is REQUIRED to make `NSTableView`
        // to position `NSTableCellView.textField`.
        // Otherwise, it won't position it properly.
        outlineView.rowSizeStyle = .default
        outlineView.headerView = nil
    }
    /// Enqueues a control message and processes at ready.
    func control(_ c: Control) {
        // TODO: Pause processing while NSOutlineView is performing an animation.
        OperationQueue.main.addOperation({ [weak self] in self?.process(c) })
    }
    var note: ((Note) -> Void)?

    /// DO NOT modify any properties of this view except layout/positioning
    /// stuffs.
    var view: NSView {
        return outlineView
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    /// All members under this line are practically private
    /// but exposed externally for testing and OBJC compatibility only.
    /// Most of these methods can work properly under a certain condition
    /// therefore state-ful. DO NOT call these methods from external world.
    /// Instead, use `control/note` method/delegate.
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    let outlineView = NSOutlineView()
    let outlineColumn = NSTableColumn()
    let cellViewID = NSUserInterfaceItemIdentifier(NSStringFromClass(ItemView.self))
    private(set) var renderedVersion = AnyHashable(OT4Identity())
    private(set) var renderedSnapshot = Snapshot.default
    private(set) var proxyTable = OT4Snapshot<Snapshot.Identity,RefProxy>()
//    private(set) var visibilityTracking = VisibilityTrackingController?.none
    private(set) var visibilityTracking2 = VisibilityTracking2Controller()

    /// Executes a control message immediately.
    func process(_ c: Control) {
        switch c {
        case .render(let s):
            assert(!s.timeline.isEmpty)
            guard !s.timeline.isEmpty else { break }
            if let i = s.timeline.findIndex(for: renderedVersion) {
                // Found matching version.
                // We can keep context by re-using same node references.
                // Apply changes since the version.
                let snapshot = s.timeline[i]
                let snapshot1 = s.timeline.last!
                let diffs = s.timeline.difference(in: i..<s.timeline.endIndex)
                var insertions = Set<Snapshot.Identity>()
                var updates = Set<Snapshot.Identity>()
                var removings = Set<Snapshot.Identity>()
                for k in diffs {
                    let a = snapshot.contains(k)
                    let b = snapshot1.contains(k)
                    switch (a,b) {
                    case (true,true):   updates.insert(k)
                    case (false,true):  insertions.insert(k)
                    case (true,false):  removings.insert(k)
                    case (false,false): break
                    }
                }

                // Sort them.
                // Removing should be reversed becuase;
                // - we found them from old snapshot.
                // - removing items in tree can change indices.
                let rkidxps = removings.map({ k in (k,snapshot.index(of: k)) }).sorted(by: { a,b in a.1 < b.1 }).reversed()
                let ukidxps = updates.map({ k in (k,snapshot1.index(of: k)) }).sorted(by: { a,b in a.1 < b.1 })
                let ikidxps = insertions.map({ k in (k,snapshot1.index(of: k)) }).sorted(by: { a,b in a.1 < b.1 })

                // Remove first, update second, insert at last.
                renderedVersion = s.timeline.lastVersion
                renderedSnapshot = snapshot1
                outlineView.beginUpdates()
                for (k,idxp) in rkidxps {
                    let pk = proxyTable.parent(of: k)
                    let ppx = pk == nil ? nil : proxyTable.state(of: pk!)
                    proxyTable.removeSubtree(for: k)
                    visibilityTracking2.remove(at: idxp)
                    outlineView.removeItems(
                        at: idxp == [] ? [0] : [idxp.last!] as IndexSet,
                        inParent: ppx,
                        withAnimation: [])
                }
                for (k,_) in ukidxps {
                    // No need to update ref-proxy or visibility tree.
                    let px = proxyTable.state(of: k)
                    outlineView.reloadItem(px, reloadChildren: false)
                }
                for (k,idxp) in ikidxps {
                    // Insert proxy first.
                    let px = RefProxy(identity: k)
                    proxyTable.insert(px, for: k, at: idxp)
                    let pk = proxyTable.parent(of: k)
                    let ppx = pk == nil ? nil : proxyTable.state(of: pk!)
                    visibilityTracking2.insert(at: idxp)
                    outlineView.insertItems(
                        at: idxp == [] ? [0] : [idxp.last!] as IndexSet,
                        inParent: ppx,
                        withAnimation: [])
                }
                outlineView.endUpdates()
                return
            }
            else {
                // No matching version.
                // It's impossible to keep context.
                // Remake whole tree.
                let ss = s.timeline.last!
                renderedVersion = s.timeline.lastVersion
                renderedSnapshot = ss
                renewProxyTableToCurrentRenderedSnapshot()
                visibilityTracking2 = VisibilityTracking2Controller(ss, scan: outlineView, with: proxyTable)
                outlineView.reloadData()
                return
            }
        }
    }
    private func renewProxyTableToCurrentRenderedSnapshot() {
        proxyTable = OT4Snapshot<Snapshot.Identity,RefProxy>()
        guard !renderedSnapshot.isEmpty else { return }
        let id = renderedSnapshot.identity(at: [])
        insertRefProxyToCurrentRenderedSnapshot(for: id, at: [])
    }
    private func insertRefProxyToCurrentRenderedSnapshot(for id: Snapshot.Identity, at idxp: IndexPath) {
        let px = RefProxy(identity: id)
        proxyTable.insert(px, for: id, at: idxp)
        let cids = renderedSnapshot.children(of: id)
        for (ci,cid) in cids.enumerated() {
            let cidxp = idxp.appending(ci)
            insertRefProxyToCurrentRenderedSnapshot(for: cid, at: cidxp)
        }
    }

    /// Executes a control message immediately.
    /// This method can work properly only at certain state.
    /// And that condition can be managed and satisfied
    /// by `control` method. Therefore you SHOULD NOT
    /// call this method outside.
    /// Internally exposed only for test code access.
    func process(_ n: ItemView.Note) {
        fatalError("Unimplemented yet.")
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        let px = item as! RefProxy
        let id = px.identity
        let xp = renderedSnapshot.branchability(of: id) == .branch
        return xp
    }
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        let px = item as! RefProxy?
        if let px = px {
            assert(proxyTable.children(of: px.identity).count == renderedSnapshot.children(of: px.identity).count)
            return proxyTable.children(of: px.identity).count
        }
        else {
            return proxyTable.isEmpty ? 0 : 1
        }
    }
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        let px = item as! RefProxy?
        if let px = px {
            assert(proxyTable.children(of: px.identity)[index] == renderedSnapshot.children(of: px.identity)[index])
            let id = proxyTable.children(of: px.identity)[index]
            return proxyTable.state(of: id)
        }
        else {
            let id = proxyTable.identity(at: [])
            return proxyTable.state(of: id)
        }
    }
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        func findExistingView() -> ItemView? {
            let v = outlineView.makeView(withIdentifier: cellViewID, owner: self)
            assert(v is ItemView?)
            return v as! ItemView?
        }
        let cv = findExistingView() ?? ItemView()
        let px = item as! RefProxy
        let id = px.identity
        let st = renderedSnapshot.state(of: id)
        cv.identifier = cellViewID
        cv.control(.render(st))
        cv.note = { n in
            OperationQueue.main.addOperation({ [weak self] in self?.process(n) })
        }
        return cv
    }

    // Delegations.
    func outlineViewItemWillExpand(_ notification: Notification) {
    }
    func outlineViewItemDidExpand(_ notification: Notification) {
        let px = notification.userInfo!["NSObject"] as! RefProxy
        let id = px.identity
        let idxp = renderedSnapshot.index(of: id)
        visibilityTracking2.setExpanded(true, at: idxp)
        assert(outlineView.isItemExpanded(px) == visibilityTracking2.isExpanded(at: idxp))

        // DO NOT FIRE NOTE HERE.
        // See `outlineViewItemDidCollapse` for details.
    }
    func outlineViewItemWillCollapse(_ notification: Notification) {
    }
    func outlineViewItemDidCollapse(_ notification: Notification) {
        let px = notification.userInfo!["NSObject"] as! RefProxy
        // Here visibility tracker cannot track index-path properly
        // because expansion state has been changed and has not been
        // integrated into visibility tracker itself.
        // We cannot use visibility tracker to find index-path
        // from selection.
        //
        // INCONSISTENT STATE ISSUE
        // ------------------------
        // When you collapse a node in a `NSOutlineView`,
        // it collapses all descendant expanded nodes and fires collapse
        // event for each one of them in leaf-to-root order.
        // The problem is, all of these events are getting fired AFTER
        // the collapse operation fully finished.
        //
        // For example, if end-user collapses A in this given tree,
        //
        //      - A
        //        - B
        //          - C
        //            - D
        //
        // It becomes like this.
        //
        //      + A
        //
        //  And `NSOutlineView` sends collapse event 3 times for
        //  each of C, B and A. C at first, A at last.
        //  If you catch the event for C and query expansion state
        //  in `NSOutlineView`, you would expect something like this.
        //
        //      - A
        //        - B
        //          + C
        //
        //  But actually, it shows this tree.
        //
        //      + A
        //
        //  First event (for C) gets fired AFTER all collapsing has
        //  been finished. At this point, actual state of
        //  `NSOutlineView` is different with your expectation,
        //  and I consider this as *inconsistent state*.
        //
        // This is obviously a bug as `NSOutlineView` is supposed to
        // work in synchronous manner.
        //
        // WORKAROUND
        // ----------
        // The best way to deal with this is not firing note on
        // collapse/expand events. On these events, I just update
        // the visibility informations and do not fire a note.
        // Instead, I fire note only for selection-change event
        // because at the point of the event, state is fully
        // consistent.
        //
        let id = px.identity
        let idxp = renderedSnapshot.index(of: id)
        visibilityTracking2.setExpanded(false, at: idxp)
        assert(outlineView.isItemExpanded(px) == visibilityTracking2.isExpanded(at: idxp))

        // DO NOT FIRE NOTE HERE.
    }
    func outlineViewSelectionIsChanging(_ notification: Notification) {
    }
    func outlineViewSelectionDidChange(_ notification: Notification) {
        let ix = scanInteraction()
        note?(.interaction(ix))
    }
}

final class OT4RefProxy2<Identity> {
    var identity: Identity
    init(identity id: Identity) {
        identity = id
    }
}

