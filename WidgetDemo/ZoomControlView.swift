//
//  ZoomControlView.swift
//  readingGlasses
//
//  Created by Changyeol Seo on 2023/09/20.
//

import SwiftUI

struct ZoomControlView: View {
    @Binding var zoom:CGFloat {
        didSet {
            setBarHeight()
        }
    }
    @State var barHeight:CGFloat = 0
    @State var isControl:Bool = false
    @State var startLocation:CGPoint? = nil
    @State var moveLocation:CGPoint = .zero {
        didSet {
            zoom -= moveLocation.y * 0.2
            if zoom < 1 {
                zoom = 1
            }
            if zoom > 80 {
                zoom = 80
            }
            print(" zoom : \(zoom) \(moveLocation)")
            setBarHeight()
            NotificationCenter.default.post(name: .carmeraZoomChangedWithZoomController, object: zoom)
        }
    }
    
    var frameHeight:CGFloat {
       300
    }
    
    func setBarHeight() {
        barHeight = frameHeight * zoom / 80
        if barHeight < 0 {
            barHeight = 0
        }
        if barHeight > frameHeight {
            barHeight = frameHeight
        }
    }
    
    func setZoom(locaton:CGPoint) {
        let h = frameHeight - locaton.y
        zoom =  h / frameHeight
        print("zoom : \(zoom) location.y : \(locaton.y)")
    }
    
    var body: some View {
        Group {
            if isControl == false {
                Button {
                    isControl = true
                } label: {
                    HStack {
                        Image(systemName:"magnifyingglass")
                            .resizable()
                            .scaledToFit()
                            .frame(width:30)
                            .foregroundColor(.white)
                            .padding(5)
                        Text("\(String(format: "%.2f",zoom))x")                            
                    }
                }
                .padding(10)
                .background(Color.black.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(20)
                .shadow(radius: 20)

                
            } else {
                ZStack(alignment: .bottom) {
                    HStack {
                        
                    }
                    .frame(width:70, height: barHeight)
                    .background(Color.red.opacity(0.5))
                    .cornerRadius(20)
                    .overlay (
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(lineWidth: 2)
                    )
                    Text("\(String(format: "%.2f",zoom))x")
                        .frame(width:100, height: frameHeight)
                        .background(Color.yellow.opacity(0.3))
                        .cornerRadius(20)
                }
                .frame(width:100,height: frameHeight)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(lineWidth: 2)
        )
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if let start = startLocation {
                        moveLocation = gesture.location - start
                    }
                    startLocation = gesture.location
                    print(gesture.location)
                    
                }
                .onEnded { gesture in
                    startLocation = nil
                    isControl = false
                    print("end : \(gesture.location)")
                }
        )
        .onAppear {
            setBarHeight()
        }
    }
}

#Preview {
    ZoomControlView(zoom: .constant(1.0))
}
