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
                    if titleText == nil {
                        img
                            .resizable()
                            .scaledToFill()
                    } else {
                        img
                            .resizable()
                            .scaledToFit()
                    }
                }
                if let txt = titleText {
                    txt
                }
            }
        }
        .padding(10)
        .frame(width: 80,height: 100)
        .background(Color.yellow)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20, style: .circular).stroke(Color.black, lineWidth:2))
        .shadow(radius: 15,x:5,y:5)

    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonView(
            action: {
            },
            titleImage: Image("carmera"),
            titleText:nil)
    }
}
