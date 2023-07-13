//
//  CameraAccesDeninedView.swift
//  readingGlasses
//
//  Created by 서창열 on 2023/07/13.
//

import SwiftUI

struct CameraAccesDeninedView: View {
    var body: some View {
        VStack {
            Text("Camera Access Denind Title")
                .font(.title)
            Text("Camera Access Denine desc")
                .font(.caption)
            Button {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            } label: {
                Text("Go to Setting")
            }
        }
        
    }
}

struct CameraAccesDeninedView_Previews: PreviewProvider {
    static var previews: some View {
        CameraAccesDeninedView()
    }
}
