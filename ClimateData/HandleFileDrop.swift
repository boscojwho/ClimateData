//
//  HandleFileDrop.swift
//  ClimateData
//
//  Created by Bosco Ho on 2024-08-06.
//

import SwiftUI

extension View {
    
}

struct HandleClimateDataFileDrop: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onDrop(of: [.url], isTargeted: nil) { providers in
                for item in providers {
                    if item.canLoadObject(ofClass: URL.self) {
                        item.loadObject(ofClass: URL.self) { url, error in
                            
                        }
                    }
                }
                return true
            }
    }
}
