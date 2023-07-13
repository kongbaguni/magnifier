//
//  CameraAccesDeninedView.swift
//  readingGlasses
//
//  Created by 서창열 on 2023/07/13.
//

import SwiftUI
import AVKit

struct CameraAccesDeninedView: View {
    @Binding var isAllow:Bool
    let authStatus:AVAuthorizationStatus
    var body: some View {
        VStack {
            Text("Camera Access Denind Title")
                .font(.title)
                .padding(.bottom, 30)
            Text("Camera Access Denine desc")
                .font(.caption)
            HStack {
                if authStatus == .notDetermined {
                    Button {
                        AVCaptureDevice.requestAccess(for: .video) { _ in
                            isAllow = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
                        }
                    } label : {
                        Text("Request Camera Access")
                    }
                }
                Button {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                } label: {
                    Text("Go to Setting")
                }
            }
            .padding(.top, 30)
        }
        
    }
}
