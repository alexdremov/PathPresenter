//
// Created in 2022
// Using Swift 5.0
// On 24.07.2022 by Alex Dremov
// 
//

import Foundation
import SwiftUI

public typealias Action = () -> Void

/**
 Main library view.
 Presents path to user
 */
public struct RoutingView<PathSpecific: Path>: View {
    /**
     Stored path state. Not used if initialized with Binding
     */
    @Binding private var path: PathSpecific

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
    public init(path: Binding<PathSpecific>) {
        self._path = path
    }

    /**
     Init with external path state and provide `rootView`
     */
    public init<RootView: View>(path: Binding<PathSpecific>,
                         @ViewBuilder rootView:() -> RootView) {
        self.init(path: path)
        self.rootView = AnyView(rootView())
    }

    /**
     Acceses used path binding
     */
    public var pathBinding: Binding<PathSpecific> {
        $path
    }

    /**
     Constructs intrnal view structure
     */
    private func presenter(content: [PathTypeView], sheet: Bool = false) -> some View {
        ZStack(alignment: .topLeading) {
            Color.clear
            if let rootView = rootView, !sheet {
                rootView
                    .zIndex(-1)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            .sheet(isPresented: .init(get: {
                sheetVisible = path.sheetPresented
                return sheetVisible
            }, set: { newValue in
                sheetVisible = newValue
            }),
                   onDismiss: {
                path.sheetDismissed()
            }, content: {
                sheetView
            })
    }
}
