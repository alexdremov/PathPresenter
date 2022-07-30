//
// Created in 2022
// Using Swift 5.0
// On 24.07.2022 by Alex Dremov
// 
//

import Foundation
import SwiftUI

public extension PathPresenter {
    /**
     Storage for path information
     */
    struct Path: Equatable {
        /**
         Helper structure as `ForEach` works with `Identifiable` instances only
         */
        private struct ViewIdentifiable<T: View>: View, Identifiable {
            var id = UUID()
            let body: T
        }

        /**
         Current views in path
         */
        internal private(set) var path = [PathTypeView]()

        /**
         Is the last view in `path` is sheet
         */
        var sheetPresented = false

        public var isEmpty: Bool {
            path.isEmpty
        }

        public var count: Int {
            path.count
        }

        /**
         Path filtered without sheets
         */
        internal var noSheet: [PathTypeView] {
            path.filter({!$0.isSheet})
        }

        /**
         Path filtered with sheets only
         */
        internal var onlySheet: [PathTypeView] {
            path.filter({$0.isSheet})
        }

        /**
         Animation to be used for the last view
         */
        public var relevantAnimation: Animation?

        /**
         Extracted animatons from path
         */
        private var animations: [Animation?] {
            path.map {value -> Animation? in
                if case .animated(_, _, animation: let animation, _, _)
                    = value {
                    return animation
                } else {
                    return nil
                }
            }
        }

        /**
         Animation of the last view
         */
        public var lastAnimation: Animation? {
            (animations.last ?? nil)
        }

        /**
         Create empty path
         */
        public init() {}

        /**
         Initialize path with `Sequence` of views
         - type will be used for all views
         */
        public init<S: Sequence>(views: S, type: PathType = .plain)
            where S.Element: View {
                append(contentsOf: views, type: type)
        }

        /**
         Initialize with sequence of some items and ViewBuilder that can construct
         a view using an item.
         */
        public init<S: Sequence, Items: View>
        (data: S,
         type: PathType = .plain,
         @ViewBuilder content: (S.Element) -> Items) {
            append(data: data, type: type, content: content)
        }

        /**
         The last transition
         */
        public var relevantTransition: AnyTransition {
            path.map {value in
                if case .animated(_, let transition, _, _, _) = value {
                    return transition
                }
                return AnyTransition.identity
            }.last ?? AnyTransition.identity
        }

        /**
         Get sheet view from the `path.last` if possible
         */
        public var lastSheet: AnyView? {
            if case .sheet(view: let view, _, _) = path.last {
                return view
            }
            return nil
        }

        /**
         Append one view to the path
         */
        public mutating func append<V: View>(_ value: V, type: PathType = .plain) {
            append(ViewIdentifiable(body: value), type: type)
        }

        /**
         Append contents of sequence
         */
        public mutating func append<S: Sequence>(contentsOf: S, type: PathType = .plain)
        where S.Element: View {
            for view in contentsOf {
                append(view, type: type)
            }
        }

        /**
         Append a sequence of some items with ViewBuilder that can construct
         a view using an item.
         */
        public mutating func append<S: Sequence, Items: View>
        (data: S,
         type: PathType = .plain,
         @ViewBuilder content: (S.Element) -> Items) {
            append(contentsOf: data.map {content($0)}, type: type)
        }

        /**
         Append single `Identifiable` view
         */
        public mutating func append<V: View & Identifiable>(_ value: V, type: PathType = .plain) {
            defer { updateSheet() }

            let typeErased = AnyView(value)
            let zIndex = Double(path.count)
            switch type {
            case .plain:
                relevantAnimation = nil
                path.append(.plain(view: typeErased, hash: value.id.hashValue, zIndex: zIndex))
            case .animated(transition: let anyTransition, animation: let animation):
                relevantAnimation = animation
                path.append(
                    .animated(view: typeErased,
                              transition: anyTransition,
                              animation: animation,
                              hash: value.id.hashValue,
                              zIndex: zIndex))
            case .sheet(onDismiss: let onDismiss):
                relevantAnimation = nil
                path.append(.sheet(view: typeErased,
                                   hash: value.id.hashValue,
                                   onDismiss: onDismiss))
            }
        }

        /**
         Removes the last view
         - Note: Can fail if path is empty
         */
        public mutating func removeLast() {
            removeLast(1)
        }

        /**
         Removes the last several views
         - Note: Can fail if path is empty
         */
        public mutating func removeLast(_ kNumber: Int) {
            defer { updateSheet() }

            relevantAnimation = lastAnimation
            path.removeLast(kNumber)
        }

        /**
         Remove all views from path instantly
         */
        public mutating func drain() {
            relevantAnimation = nil
            removeLast(path.count)
        }

        /**
         Used to remove the last view if it is sheet from the path
         */
        private mutating func removeLastSheet() -> Action? {
            defer { updateSheet() }

            let onDismissAction: Action?
            if let lastIndexOfSheet = path.lastIndex(where: {elem in
                if case .sheet = elem {
                    return true
                }
                return false
            }), lastIndexOfSheet + 1 == path.count {
                if case .sheet(_,
                               _,
                               onDismiss: let onDismiss)
                    = path[lastIndexOfSheet] {
                    onDismissAction = onDismiss
                } else {
                    onDismissAction = nil
                }
                path.remove(at: lastIndexOfSheet)
                for i in lastIndexOfSheet..<count {
                    path[i].zIndex = Double(i)
                }
            } else {
                onDismissAction = nil
            }
            return onDismissAction
        }

        /**
         Update `sheetPresented` state
         */
        private mutating func updateSheet() {
            if path.last?.isSheet ?? false {
                sheetPresented = true
            } else {
                sheetPresented = false
            }
        }

        /**
         Called when sheet gets dismissed
         */
        public mutating func sheetDismissed() {
            let dismiss = removeLastSheet()
            dismiss?()
        }
        
        public mutating func reverse() {
            defer { updateSheet() }
            let oldPath = path
            path = []
            
            for elem in oldPath.reversed() {
                append(elem.view, type: elem.type)
            }
        }
    }
}
