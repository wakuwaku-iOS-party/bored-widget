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
        BoredEntry(
            date: Date(),
            bored: .init(
                activity: "hoge",
                type: "hoge",
                participants: 2,
                price: 0.5,
                key: "hoge",
                accessibility: 0.3
            ),
            catStatus: .init(data: .init())
        )
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (BoredEntry) -> ()) {
        let entry = BoredEntry(
            date: Date(),
            bored: .init(
                activity: "hoge",
                type: "hoge",
                participants: 2,
                price: 0.5,
                key: "hoge",
                accessibility: 0.3
            ),
            catStatus: .init(data: .init())
        )
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [BoredEntry] = []
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .second, value: hourOffset, to: currentDate)!


            getBored { bored in
                getStatusCode { catStatusCode in
                    let entry = BoredEntry(
                        date: entryDate,
                        bored: bored,
                        catStatus: catStatusCode
                    )
                    entries.append(entry)
                    if hourOffset == 4 {
                        let timeline = Timeline(entries: entries, policy: .atEnd)
                        completion(timeline)
                    }
                }
            }
        }
    }

    func getBored(completion: @escaping ((_ :Bored) -> Void)) {
        URLSession.shared
            .dataTask(
                with: URL(
                    string: "https://www.boredapi.com/api/activity"
                )!
            ) { data, _ ,error in
                if let error = error {
                    return
                }

                do {
                    let data = try JSONDecoder()
                        .decode(
                            Bored.self,
                            from: data!
                        )
                    completion(data)
                }
                catch {
                    print("failed")
                }
            }.resume()
    }

    func getStatusCode(completion: @escaping (_ :CatStatusCode) -> Void) {
        URLSession
            .shared
            .dataTask(
                with: URL(string: "https://http.cat/200")!
            ) { data, _, error in
                if error != nil {
                    return
                }

                if let data = data {
                    let catStatusCode = CatStatusCode(
                        data: data
                    )
                    completion(catStatusCode)
                }
            }.resume()
    }
}

struct Bored: Codable {
    let activity: String
    let type: String
    let participants: Int
    let price: Double
    let key: String
    let accessibility: Double
}

struct CatStatusCode: Codable {
    let data: Data
}

struct BoredEntry: TimelineEntry {
    var date: Date
    let bored: Bored
    let catStatus: CatStatusCode
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct bored_widget_widgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Image(
                uiImage: UIImage(
                    data: entry.catStatus.data
                ) ?? .init()
            )
            .resizable()
            .scaledToFill()
            Text(entry.bored.activity)
        }
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
        bored_widget_widgetEntryView(entry: BoredEntry(
            date: Date(),
            bored: .init(
                activity: "hoge",
                type: "hoge",
                participants: 2,
                price: 0.5,
                key: "hoge",
                accessibility: 0.3
            ),
            catStatus: .init(data: .init())
        )
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
