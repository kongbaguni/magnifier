//
//  ContentView.swift
//  WidgetDemo
//
//  Created by Changyeol Seo on 2023/06/28.
//

import SwiftUI


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
        NotificationCenter.default.addObserver(forName: .carmeraPreviewLog, object: nil, queue: nil) {[self] noti in
            if let notilog = noti.object as? String {
                log.append(notilog)
            }
        }
        
        NotificationCenter.default.addObserver(forName: .carmeraPhotoOutput, object: nil, queue: nil) { noti in
            if let img = noti.object as? UIImage {
                self.image = img
            }
        }
        isAddedObserver = true;
    }
    
    var body: some View {
        ZStack {
            CameraPreview()
                .border(Color.blue,width: 1)
            VStack{
                ScrollView{
                    ForEach(0..<log.count,id:\.self) { idx in
                        let str = log[idx]
                        Text(str)
                            .foregroundColor(.secondary)
                    }
                }.frame(height: 200)
                
                Text("zoom:\(zoom)")
                if let img = image {
                    Image(uiImage: img)
                        .resizable()
                        .frame(width: img.size.width / 10, height: img.size.height / 10)
                }
                HStack {
                    Button {
                        zoom += 0.5;
                        if(zoom > 10) {
                            zoom = 10;
                        }
                        print("확대")
                        NotificationCenter.default.post(name: .carmeraCtlZoom, object: zoom)
                    } label: {
                        Text("확대")
                            .padding(30)
                            .border(.primary,width: 2)
                    }
                    .frame(height: 100)
                    
                    Button {
                        zoom -= 0.5;
                        if(zoom < 0.5) {
                            zoom = 0.5
                        };
                        print("축소")
                        NotificationCenter.default.post(name: .carmeraCtlZoom, object: zoom)
                    } label: {
                         Text("축소")
                            .padding(30)
                            .border(.primary, width: 2)
                    }
                    .frame(height: 100)
                    
                    Button {
                        NotificationCenter.default.post(name: .carmeraTakePhoto, object: zoom)
                    } label: {
                         Text("촬영")
                            .padding(30)
                            .border(.primary, width: 2)
                    }
                    .frame(height: 100)

                }

            }
        }
        .padding()
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
