//
//  widget.swift
//  widget
//
//  Created by Changyeol Seo on 2023/06/28.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), image:nil, configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), image:AppGroup.getSavedImage(imageSize: .small), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        var size:AppGroup.ImageSize {
            let w = context.displaySize.width
            if w < 200 {
                return .small
            }
            if w < 400 {
                return .medium
            }
            return .large
        }
        
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let image = AppGroup.getSavedImage(imageSize: size)
            
            let entry = SimpleEntry(date: entryDate,image: image, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let image: Image?
    let configuration: ConfigurationIntent
}

struct widgetEntryView : View {
    var entry: Provider.Entry
    var currentImage: Image {
        entry.image ?? Image("cat")
    }
    
    var backgroundView : some View {
        currentImage
            .resizable()
            .scaledToFill()
            .opacity(0.3)
            .background(Color("WidgetBackground"))
    }
    
    var imageView : some View {
        VStack {
            currentImage
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 2)
                }
                .cornerRadius(10)
            
        }
    }
    
    var body: some View {
        imageView
            .shadow(radius: 20)
            .onAppear {
                WidgetCenter.shared.reloadAllTimelines()
            }
            .widgetBackground(backgroundView: backgroundView)
            .onReceive(NotificationCenter.default.publisher(for: .carmeraTakePhotoSaveFinish)) { _ in
                WidgetCenter.shared.reloadAllTimelines()
            }
    }
    
}

struct widget: Widget {
    let kind: String = "app-title"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            widgetEntryView(entry: entry)
        }
        .configurationDisplayName("widget-title")
        .description("widget-description")
    }
}


struct widget_Previews: PreviewProvider {
    static var previews: some View {
        widgetEntryView(entry: SimpleEntry(date: Date(), image: AppGroup.getSavedImage(imageSize: .small), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
