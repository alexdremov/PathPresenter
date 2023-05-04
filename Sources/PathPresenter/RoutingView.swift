//
// Created in 2022
// Using Swift 5.0
// On 24.07.2022 by Alex Dremov
// 
//

import Foundation
import SwiftUI

/**
 Module namespace
 */
public enum PathPresenter {}

private extension View {
    func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> TupleView<(Self?, Content?)> {
        if conditional { return TupleView((nil, content(self))) } else { return TupleView((self, nil)) }
    }
}

public extension PathPresenter {
    typealias Action = () -> Void

    /**
     Main library view.
     Presents path to user
     */
    struct RoutingView: View {
        /**
         Stored path state. Not used if initialized with Binding
         */
        @Binding private var path: Path

        /**
         Does the last view has `.sheet` type
         */
        @State private var sheetVisible: Bool = false

        /**
         Root view is always presented. Can be nil if no view specified
         */
        var rootView: AnyView?
        
        /**
         PathPresenter views will try to occupy as much space as possible
         */
        private let enforceFullScreen: Bool
        
        
        /**
         PathPresenter shows all views in path, this may lead to inapropriate .onAppear fire.
         This option asks it to show only the last view
         */
        private let showOnlyLast: Bool

        /**
         Init with external path state
         */
        public init(
            path: Binding<Path>,
            enforceFullScreen: Bool = true,
            showOnlyLast: Bool = false
        ) {
            self._path = path
            self.enforceFullScreen = enforceFullScreen
            self.showOnlyLast = showOnlyLast
        }

        /**
         Init with external path state and provide `rootView`
         */
        public init<RootView: View>(
            path: Binding<Path>,
            enforceFullScreen: Bool = true,
            showOnlyLast: Bool = false,
            @ViewBuilder rootView:() -> RootView
        ) {
            self.init(path: path, enforceFullScreen: enforceFullScreen, showOnlyLast: showOnlyLast)
            self.rootView = AnyView(rootView())
        }

        /**
         Acceses used path binding
         */
        public var pathBinding: Binding<Path> {
            $path
        }
        
        @ViewBuilder
        private func getElementView(element elem: PathTypeView) -> some View {
            switch elem {
                case .plain(let view, hash: _, zIndex: let zIndex):
                    view
                        .zIndex(zIndex)
                case .animated(let view,
                               transition: let transition,
                               animation: _,
                               hash: _,
                               zIndex: let zIndex):
                    view
                        .zIndex(zIndex)
                        .transition(transition)
                case .sheet(let view, _, _):
                    view
            }
        }
        
        private func getLastNotSheet(content: [PathTypeView]) -> PathTypeView? {
            content.last{!$0.isSheet}
        }

        /**
         Constructs intrnal view structure
         */
        private func presenter(content: [PathTypeView], sheet: Bool = false) -> some View {
            ZStack(alignment: .topLeading) {
                if enforceFullScreen {
                    Color.clear
                }
                if let rootView = rootView, !sheet {
                    rootView
                        .zIndex(-1)
                }
                if showOnlyLast {
                    if let elem = getLastNotSheet(content: content) {
                        getElementView(element: elem)
                    }
                } else {
                    ForEach(content, id: \.hashValue) { elem in
                        getElementView(element: elem)
                    }
                }
            }
            .if(enforceFullScreen) {
                $0.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }

        /**
         All views without sheet
         */
        @ViewBuilder var coreView: some View {
            presenter(content: path.noSheet)
        }

        /**
         Only sheet views
         */
        @ViewBuilder var sheetView: some View {
            presenter(content: path.onlySheet, sheet: true)
        }

        /**
         Final view structure
         */
        public var body: some View {
            coreView
                .animation(path.relevantAnimation, value: path)
                .sheet(isPresented: $path.sheetPresented,
                       onDismiss: {
                    path.sheetDismissed()
                }, content: {
                    sheetView
                })
        }
    }
}
