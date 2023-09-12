//
//  ImageView.swift
//  WidgetDemo
//
//  Created by Changyeol Seo on 2023/07/04.
//

import SwiftUI
import ActivityView

struct ImageView: View {
    @State var image:Image = AppGroup.savedImage ?? Image("cat")
    @State var activityItem:ActivityItem? = nil
    
    var imageView : some View {
        PinchZoomPanImageView(image: image)
    }
    
    var body: some View {
        NavigationView {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    GeometryReader { proxy in
                        imageView
                    }
                    .navigationTitle("share")
                    .toolbar {
                        Button {
                            if let data = image.getUIImage(newSize: UIScreen.main.bounds.size)?.jpegData(compressionQuality: 7) {
                                activityItem = .init(itemsArray: [data])
                            }
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }

                    }
                }
            } else {
                imageView
            }
        }
        .activitySheet($activityItem)
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView()
    }
}
