//
//  ContentView.swift
//  ClimateData
//
//  Created by Bosco Ho on 2024-08-03.
//

import SwiftUI

struct ContentView: View {
    @State private var climateData: FeatureCollection?
    @State private var byYear: [Int : [Feature]]?
    @State private var byYearMonth: [Int : [Int : [Feature]]]?
    
    @State private var month = 6

    var body: some View {
        VStack {
            if let climateData, let byYearMonth, let byYear {
                VStack {
                    GroupBox {
                        Text("Loaded ^[\(climateData.numberReturned) day](inflect: true) of data.")
                    }
                    ChartView(
                        features: features(1995...2024)
                    )
                }
            } else {
                ProgressView()
            }
        }
        .padding()
        .task {
            let decoder = JSONDecoder()
            let url = Bundle.main.url(
                forResource: "vancouver_harbour_daily_1924_2024",
                withExtension: "json"
            )
            let data = try! Data(contentsOf: url!)
            do {
                let featureCollection = try decoder.decode(FeatureCollection.self, from: data)
                let byYear = Dictionary(grouping: featureCollection.features) {
                    $0.properties.localYear
                }
                let byMonth = byYear.mapValues { value in
                    Dictionary(grouping: value) {
                        $0.properties.localMonth
                    }
                }
                print("byMonth -> \(byMonth.count)")
                climateData = featureCollection
                self.byYear = byYear
                self.byYearMonth = byMonth
            } catch {
                print("Error decoding GeoJSON data:", error)
            }
        }
    }
    
    private func features(_ rangeByYear: ClosedRange<Int>) -> [[Feature]] {
        guard let byYearMonth else { return [] }
        let years = byYearMonth.filter { rangeByYear.contains($0.key) }
        return years.compactMap {
            let monthlyData = $0.value[month]
            #if DEBUG
            if monthlyData == nil {
                print("MISSING DATA -> \($0.key).\(month)")
            }
            #endif
            return monthlyData
        }
    }
}

#Preview {
    ContentView()
}
