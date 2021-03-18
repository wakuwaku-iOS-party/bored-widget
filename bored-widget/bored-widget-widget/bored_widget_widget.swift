//
//  bored_widget_widget.swift
//  bored-widget-widget
//
//  Created by Kohei Kawaguchi on 2021/03/18.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> BoredEntry {
        BoredEntry(date: Date(), activity: "ハワイにイケ")
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (BoredEntry) -> ()) {
        let entry = BoredEntry(date: Date(), activity: "ハワイにイケ")
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [BoredEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = BoredEntry(date: entryDate, activity: "ボーリングに行こう")
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)

//        URLSession("https://hogehoge.com")
//            .send()
//            .subscribe({
//                 let timeline = makeTimeline($0)
//                 completion(timeline)
//            })


        completion(timeline)
    }
}

struct BoredEntry: TimelineEntry {
    var date: Date
    let activity: String
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct bored_widget_widgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.activity)
    }
}

@main
struct bored_widget_widget: Widget {
    let kind: String = "bored_widget_widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            bored_widget_widgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct bored_widget_widget_Previews: PreviewProvider {
    static var previews: some View {
        bored_widget_widgetEntryView(entry: BoredEntry(date: Date(), activity: "ハワイにイケ"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
