//
//  ImageView.swift
//  WidgetDemo
//
//  Created by Changyeol Seo on 2023/07/04.
//

import SwiftUI

struct ImageView: View {
    @State var image:Image = AppGroup.savedImage
    var body: some View {
        image
            .resizable()
            .scaledToFill()
            .edgesIgnoringSafeArea(.all)
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView()
    }
}
