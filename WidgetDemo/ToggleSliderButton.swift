//
//  ToggleSliderButton.swift
//  readingGlasses
//
//  Created by Changyeol Seo on 2023/07/10.
//

import SwiftUI

struct ToggleSliderButton: View {
    let titleOn:Image
    let titleOff:Image
    @State var isUp = false
    @State var point = 0.0
    let onToggleBtn:(_ isOn:Bool)->Void
    let onChangeSlider:(_ value:Double)->Void
    var body: some View {
        HStack {
            Button {
                isUp.toggle()
                onToggleBtn(isUp)
            } label: {
                (isUp ? titleOn : titleOff)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40)
            }
            if isUp {
                Slider(value: $point) {value in
                    onChangeSlider(point)
                }
                Text(String(format: "%0.2f", point))
            }
        }.padding(10)

    }
}

struct ToggleSliderButton_Previews: PreviewProvider {
    static var previews: some View {
        ToggleSliderButton(
            titleOn: Image(systemName: "plusminus.circle.fill"),
            titleOff: Image(systemName: "plusminus.circle"), onToggleBtn: { isOn in
            
        }, onChangeSlider: { value in
            
        }) 

    }
}
