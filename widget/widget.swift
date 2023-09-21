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
        let entry = SimpleEntry(date: Date(), image:AppGroup.savedImage, configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let image = AppGroup.savedImage
            
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

    var backgroundView : some View {
        VStack {
            if let img = entry.image {
                img
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .cornerRadius(10)
            }
            else {
                Image("cat")
                    .resizable()
                    .scaledToFill()
                    .border(Color("WidgetBackground"), width: 2)
                    .ignoresSafeArea()
                
            }
        }
        .opacity(0.3)
        .background(Color("WidgetBackground"))
    }
    
    var imageView : some View {
        VStack {
            if let img = entry.image {
                if #available(iOSApplicationExtension 15.0, *) {
                    img
                        .resizable()
                        .scaledToFit()
                        .ignoresSafeArea()
                        .cornerRadius(10)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 2)
                        }
                }
                else {
                    img
                        .resizable()
                        .scaledToFit()
                        .ignoresSafeArea()
                        .cornerRadius(10)
                }
            }
            else {
                Image("cat")
                    .resizable()
                    .scaledToFit()
                    .border(Color("WidgetBackground"), width: 2)
                    .ignoresSafeArea()
                
            }
        }
    }
    var body: some View {
        imageView
            .shadow(radius: 20)
            .onAppear {
                WidgetCenter.shared.reloadAllTimelines()
            }
            .widgetBackground(backgroundView: backgroundView)
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
        widgetEntryView(entry: SimpleEntry(date: Date(), image: AppGroup.savedImage, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
