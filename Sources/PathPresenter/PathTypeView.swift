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
     Used internally for combining view with information about how it needs to be presented
     See `PathType`
     */
    enum PathTypeView: Hashable, Identifiable {
        case plain(view: AnyView,
                   hash: Int,
                   zIndex: Double)
        case animated(view: AnyView,
                      transition: AnyTransition,
                      animation: Animation,
                      hash: Int,
                      zIndex: Double)
        case sheet(view: AnyView,
                   hash: Int,
                   onDismiss: Action)

        public var id: Int {
            switch self {
            case .plain(_, let hash, _):
                return hash
            case .animated( _, _, _, let hash, _):
                return hash
            case .sheet( _, let hash, _):
                return hash
            }
        }

        var zIndex: Double {
            get {
                switch self {
                case .plain(view: _, hash: _, zIndex: let zIndex):
                    return zIndex
                case .animated(view: _,
                               transition: _,
                               animation: _,
                               hash: _,
                               zIndex: let zIndex):
                    return zIndex
                case .sheet:
                    return -1
                }
            }
            set {
                switch self {
                case .plain(let view, let hash, _):
                    self = .plain(view: view, hash: hash, zIndex: newValue)
                case .animated(let view,
                               let transition,
                               let animation,
                               let hash,
                               _):
                    self = .animated(
                        view: view,
                        transition: transition,
                        animation: animation,
                        hash: hash,
                        zIndex: newValue)
                case .sheet:
                    break
                }
            }
        }

        public static func == (lhs: PathPresenter.PathTypeView,
                               rhs: PathPresenter.PathTypeView) -> Bool {
            switch lhs {
            case .plain(_, hash: let hash, _):
                if case .plain(_, hash: let hashSecond, _) = rhs {
                    return hash == hashSecond
                }
                return false
            case .animated(_, _, _, hash: let hash, _):
                if case .animated(_, _, _, let hashSecond, _) = rhs {
                    return hash == hashSecond
                }
                return false
            case .sheet(_, hash: let hash, _):
                if case .sheet(_, let hashSecond, _) = rhs {
                    return hash == hashSecond
                }
                return false
            }
        }

        public func hash(into hasher: inout Hasher) {
            switch self {
            case .plain(_, let hash, _):
                hasher.combine(hash)
            case .animated(_, _, _, let hash, _):
                hasher.combine(hash)
            case .sheet(_, let hash, _):
                hasher.combine(hash)
            }
        }

        var isSheet: Bool {
            if case .sheet = self {
                return true
            }
            return false
        }
    }
}
