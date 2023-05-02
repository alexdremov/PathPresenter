//
// Created in 2022
// Using Swift 5.0
// On 12.08.2022 by Alex Dremov
// 
//

import Foundation
import SwiftUI

public protocol Path: Equatable {
    mutating func sheetDismissed()
    
    var noSheet: [PathTypeView] { get }
    var onlySheet: [PathTypeView] { get }
    
    var relevantAnimation: Animation? { get }
    var relevantTransition: AnyTransition { get }
    var sheetPresented: Bool { get }
}
