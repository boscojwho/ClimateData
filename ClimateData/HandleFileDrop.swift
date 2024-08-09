//
//  HandleFileDrop.swift
//  ClimateData
//
//  Created by Bosco Ho on 2024-08-06.
//

import SwiftUI

extension View {
    func climateDataFileDrop(fileUrl: Binding<URL?>, isTargeted: Binding<Bool>?) -> some View {
        modifier(
            HandleClimateDataFileDrop(
                fileUrl: fileUrl,
                isTargeted: isTargeted
            )
        )
    }
}

struct HandleClimateDataFileDrop: ViewModifier {
    let fileUrl: Binding<URL?>
    let isTargeted: Binding<Bool>?
    func body(content: Content) -> some View {
        content
            .onDrop(of: [.url], isTargeted: isTargeted) { providers in
                for item in providers {
                    if item.canLoadObject(ofClass: URL.self) {
                        let _ = item.loadObject(ofClass: URL.self) { url, error in
                            fileUrl.wrappedValue = url
                        }
                    }
                }
                return true
            }
    }
}
