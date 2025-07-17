//
//  ImageView.swift
//  WidgetDemo
//
//  Created by Changyeol Seo on 2023/07/04.
//

import SwiftUI
import ActivityView

struct ImageView: View {
    @State var image:Image = AppGroup.getSavedImage(imageSize: .small) ?? Image("cat")
    @State var activityItem:ActivityItem? = nil
    
    var imageView : some View {
        image.resizable().scaledToFill().clipped()
            .ignoresSafeArea()
    }
    
    var body: some View {
        NavigationView {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    imageView
                    .toolbar {
                        Button {
                            if let data = image.getUIImage(newSize: UIScreen.main.bounds.size)?.jpegData(compressionQuality: 7) {
                                activityItem = .init(itemsArray: [data])
                            }
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.white)
                                .padding(.init(top: 5, leading: 10, bottom: 10, trailing: 10))
                                .overlay {
                                    Circle()
                                        .stroke(lineWidth: 2.5)
                                        .foregroundColor(.white)
                                }
                                .background {
                                    Circle()
                                        .fill(.black.opacity(0.5))
                                }
                                .shadow(radius: 20)
                                
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
