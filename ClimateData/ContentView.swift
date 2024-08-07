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
    
    var body: some View {
        HStack {
            if let climateData, let byYearMonth, let byYear {
                VStack {
                    GroupBox {
                        Text("Loaded ^[\(climateData.numberReturned) day](inflect: true) of data.")
                    }
                    ChartView(
                        features: features(
                            Int(selectedMinYear)...Int(selectedMaxYear),
                            month: Int(selectedMonth)
                        ),
                        yProperty: selectedProperty.keyPath
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
        .inspectorColumnWidth(480)
        .inspector(isPresented: .constant(true)) {
            filters()
                .padding()
        }
    }
    
    private func features(_ rangeByYear: ClosedRange<Int>, month: Int) -> [[Feature]] {
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
    
    @State private var selectedProperty: Properties.CodingKeys = .maxTemperature
    @State private var selectedMinYear: Double = 1900
    @State private var selectedMaxYear: Double = 2024
    @State private var selectedMonth: Double = 1
    
    @ViewBuilder
    private func filters() -> some View {
        if let climateData {
            VStack {
                GroupBox {
                    Picker(selection: $selectedProperty) {
                        ForEach(Properties.CodingKeys.allCases, id: \.self) { p in
                            Text(p.stringValue)
                                .tag(p.stringValue)
                        }
                    } label: {
                        Text("Data Property")
                    }
                }
                GroupBox {
                    VStack(spacing: 12) {
                        VStack {
                            Text(String(selectedMonth))
                            Slider(value: $selectedMonth, in: 1...12, step: 1) {
                                EmptyView()
                            } minimumValueLabel: {
                                Text("Jan.")
                            } maximumValueLabel: {
                                Text("Dec.")
                            } onEditingChanged: { _ in
                                /// no-op
                            }
                        }
                        
                        let years: [Int] = Array(byYear!.keys.sorted { $0 < $1 })
                        
                        VStack {
                            Text("Start Year: \(selectedMinYear)")
                            Slider(value: .init(get: {
                                selectedMinYear
                            }, set: { newValue in
                                if newValue >= selectedMaxYear {
                                    if selectedMaxYear == Double(years.last!) {
                                        selectedMinYear = max(newValue - 1, Double(years.first!))
                                    } else {
                                        selectedMaxYear = min(newValue + 1, Double(years.last!))
                                    }
                                } else {
                                    selectedMinYear = newValue
                                }
                            }), in: Double(years.first!)...Double(years.last!), step: 1) {
                                EmptyView()
                            } minimumValueLabel: {
                                EmptyView()
                            } maximumValueLabel: {
                                EmptyView()
                            } onEditingChanged: { _ in
                                /// no-op
                            }
                        }
                        
                        VStack {
                            Text("End Year: \(selectedMaxYear)")
                            Slider(value: .init(get: {
                                selectedMaxYear
                            }, set: { newValue in
                                if newValue <= selectedMinYear {
                                    if selectedMinYear == Double(years.first!) {
                                        selectedMaxYear = max(newValue + 1, Double(years.last!))
                                    } else {
                                        selectedMinYear = max(newValue - 1, Double(years.first!))
                                    }
                                } else {
                                    selectedMaxYear = newValue
                                }
                            }), in: Double(years.first!)...Double(years.last!), step: 1) {
                                EmptyView()
                            } minimumValueLabel: {
                                EmptyView()
                            } maximumValueLabel: {
                                EmptyView()
                            } onEditingChanged: { _ in
                                /// no-op
                            }
                        }
                    }
                }
            }
        } else {
            ProgressView()
        }
    }
}

#Preview {
    ContentView()
}
