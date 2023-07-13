//
//  CameraAccesDeninedView.swift
//  readingGlasses
//
//  Created by 서창열 on 2023/07/13.
//

import SwiftUI
import AVKit

struct CameraAccesDeninedView: View {
    var body: some View {
        VStack {
            Text("Camera Access Denind Title")
                .font(.title)
                .padding(.bottom, 30)
            Text("Camera Access Denine desc")
                .font(.caption)
            Button {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            } label: {
                Text("Go to Setting")
            }
            .padding(.top, 20)
        }
        
    }
}

struct CameraAccesDeninedView_Previews: PreviewProvider {
    @State var isAllow = false
    static var previews: some View {
        CameraAccesDeninedView()
    }
}
