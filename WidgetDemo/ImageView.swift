//
//  ImageView.swift
//  WidgetDemo
//
//  Created by Changyeol Seo on 2023/07/04.
//

import SwiftUI
import ActivityView

struct ImageView: View {
    let image:UIImage
    init(image:UIImage? = nil) {
        self.image = image ?? AppGroup.getSavedUIImage(imageSize: .small) ?? UIImage(named: "cat")!
    }
    @State var activityItem:ActivityItem? = nil
        
    
    var imageView : some View {
        Image(uiImage: image)
        .resizable().scaledToFill().clipped()
            .ignoresSafeArea()
    }
    
    var body: some View {
        NavigationView {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    imageView
                    .toolbar {
                        Button {
                            activityItem = .init(itemsArray: [image])
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
