//
// Created in 2022
// Using Swift 5.0
// On 24.07.2022 by Alex Dremov
// 
//

import Foundation
import SwiftUI

public extension PathPresenter {
    enum PathType {
        /**
         * Just show a view. No animation, no transition.
         * Show view above all other views
         */
        case plain

        /**
         * Show view with in and out transitions.
         * Transition animation also can be specified.
         */
        case animated(transition: AnyTransition, animation: Animation)

        /**
         * Show view in .sheet()
         * - Note: If you want to present several views in sheet,
         * you can create a second RoutingView and use it in sheet!
         */
        case sheet(onDismiss: Action)
    }
}
