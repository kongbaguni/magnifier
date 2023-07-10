//
//  ButtonView.swift
//  readingGlasses
//
//  Created by Changyeol Seo on 2023/07/10.
//

import SwiftUI

struct ButtonView: View {
    let action:()->Void
    let titleImage:Image?
    let titleText:Text?
    var body: some View {
        Button {
            action()
        } label: {
            VStack {
                if let img = titleImage {
                    img
                        .resizable()
                        .scaledToFit()
                }
                if let txt = titleText {
                    txt
                }
            }
        }
        .frame(width: 80,height: 100)
        .background(Color.yellow)
        .clipShape(Capsule())

    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonView(
            action: {
            },
            titleImage: Image("carmera"),
            titleText: Text("text"))
    }
}
