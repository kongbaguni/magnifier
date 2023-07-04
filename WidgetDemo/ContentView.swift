//
//  ContentView.swift
//  WidgetDemo
//
//  Created by Changyeol Seo on 2023/06/28.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    @State var zoom:CGFloat = 1.0
    @State var log = LimitedArray<String>(limit: 20)
    @State var isAddedObserver = false
    @State var image:UIImage? = UIImage(named: "cat")
    
    private func addObserver() {
        if(isAddedObserver) {
            return;
        }
        log.append("addOberver");
        NotificationCenter.default.addObserver(forName: .carmeraPreviewLog, object: nil, queue: nil) { noti in
            if let notilog = noti.object as? String {
                log.append(notilog)
            }
        }
        
        NotificationCenter.default.addObserver(forName: .carmeraPhotoOutput, object: nil, queue: nil) { noti in
            if let img = noti.object as? UIImage {
                image = img
            }
        }
        NotificationCenter.default.addObserver(forName: .carmeraZoomChanged, object: nil, queue: nil) { noti in
            if let zoomFector = noti.object as? CGFloat {
                zoom = zoomFector
            }
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { noti in
            WidgetCenter.shared.reloadAllTimelines()
        }
        isAddedObserver = true;
    }
    
    var body: some View {
        ZStack {
            CameraPreview()

            VStack{
                Spacer()
                Text("zoom:\(zoom)")
                HStack {
                    Button {
                        
                    } label: {
                        if let img = image {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFit()
                                .frame(width:80, height: 80)
                                .border(.primary, width: 2)
                        }
                    }
                                   
                    Button {
                        NotificationCenter.default.post(name: .carmeraTakePhoto, object: zoom)
                    } label: {
                         Text("촬영")
                            .frame(width:80, height: 80)
                            .border(.primary, width: 2)
                    }
                    .frame(height: 100)
                    
                    Spacer()

                }

            }
            .padding(.leading, 5)
            .padding(.trailing, 5)
            .padding(.bottom,
                     (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.bottom ?? 0)
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear{
            self.addObserver();
            if let img = AppGroup.savedImage {
                image = img
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
