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

extension PathPresenter {
    public typealias Action = () -> Void

    /**
     Main library view.
     Presents path to user
     */
    struct RoutingView: View {
        /**
         Stored path state. Not used if initialized with Binding
         */
        @State private var pathStored: Path = Path()

        /**
         Refers to internal state if initialized without binding
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
         Init with external path state
         */
        init(path: Binding<Path>) {
            self._path = path
        }

        /**
         Init with external path state and provide `rootView`
         */
        init<RootView: View>(path: Binding<Path>,
                             @ViewBuilder rootView:() -> RootView) {
            self.init(path: path)
            self.rootView = AnyView(rootView())
        }

        /**
         Use internal path state
         */
        init() {
            self._path = Binding.constant(Path())
            self.rootView = nil

            self._path = $pathStored
        }

        /**
         Use internal path state and provide `rootView`
         */
        init<RootView: View>(@ViewBuilder rootView: () -> RootView) {
            self.init()
            self.rootView = AnyView(rootView())
        }

        /**
         Acceses used path binding
         */
        public var pathBinding: Binding<Path> {
            $path
        }

        /**
         Constructs intrnal view structure
         */
        private func presenter(content: [PathTypeView], sheet: Bool = false) -> some View {
            ZStack(alignment: .topLeading) {
                if let rootView = rootView, !sheet {
                    rootView
                }
                ForEach(content, id: \.hashValue) { elem in
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
        @ViewBuilder var shitView: some View {
            presenter(content: path.onlySheet, sheet: true)
        }

        /**
         Final view structure
         */
        var body: some View {
            coreView
                .sheet(isPresented: $path.sheetPresented,
                       onDismiss: {
                    path.sheetDismissed()
                }, content: {
                    shitView
                })
                .animation(path.relevantAnimation, value: path)
        }
    }
}
