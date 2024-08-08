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
    @State private var features: [[Feature]] = []
    @State private var domain: [Double] = [0, 0]

    var body: some View {
        NavigationSplitView {
            filters()
                .padding()
                .navigationSplitViewColumnWidth(min: 280, ideal: 280)
        } detail: {
            HStack {
                if let climateData, let byYearMonth, let byYear {
                    VStack {
                        ChartView(
                            features: features,
                            yProperty: selectedProperty.keyPath,
                            yCodingKey: selectedProperty,
                            yDomain: domain,
                            highlightForegroundValue: setHighlightsYear ? highlightYear : nil
                        )
                        .onChange(of: selectedProperty, initial: true) { _, newValue in
                            let features = features(
                                Int(selectedMinYear)...Int(selectedMaxYear),
                                month: Int(selectedMonth)
                            )
                            let domain = findDomain(in: byYear.values.compactMap { $0 })
                            self.features = features
                            self.domain = domain
                        }
                        .onChange(of: selectedMonth) {
                            self.features = features(
                                Int(selectedMinYear)...Int(selectedMaxYear),
                                month: Int(selectedMonth)
                            )
                        }
                        .onChange(of: selectedMinYear) {
                            self.features = features(
                                Int(selectedMinYear)...Int(selectedMaxYear),
                                month: Int(selectedMonth)
                            )
                        }
                        .onChange(of: selectedMaxYear) {
                            self.features = features(
                                Int(selectedMinYear)...Int(selectedMaxYear),
                                month: Int(selectedMonth)
                            )
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            .frame(minWidth: 720)
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
        .sorted { lhs, rhs in
            guard let l = lhs.first, let r = rhs.first else { return false }
            return l.properties.localYear < r.properties.localYear
        }
    }
    
    @State private var selectedProperty: Properties.CodingKeys = .maxTemperature
    @State private var selectedMinYear: Double = 1900
    @State private var selectedMaxYear: Double = 2024
    @State private var selectedMonth: Double = 1
    
    @State private var setHighlightsYear = true
    @State private var highlightYear: Double = 2024
    
    @ViewBuilder
    private func filters() -> some View {
        if let climateData {
            let years: [Int] = Array(byYear!.keys.sorted { $0 < $1 })
            VStack {
                GroupBox {
                    Text("Loaded ^[\(climateData.numberReturned) day](inflect: true) of data.")
                }
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
                        VStack(alignment: .leading) {
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
                        VStack(alignment: .leading) {
                            Text(verbatim: "Start Year: \(Int(selectedMinYear))")
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
                        VStack(alignment: .leading) {
                            Text(verbatim: "End Year: \(Int(selectedMaxYear))")
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
                GroupBox {
                    VStack(alignment: .leading) {
                        Text(verbatim: "Highlight Year: \(Int(highlightYear))")
                        Slider(
                            value: $highlightYear,
                            in: Double(years.first!)...Double(years.last!),
                            step: 1
                        ) {
                            EmptyView()
                        } minimumValueLabel: {
                            EmptyView()
                        } maximumValueLabel: {
                            EmptyView()
                        } onEditingChanged: { _ in
                            /// no-op
                        }
                        .disabled(setHighlightsYear == false)
                        Toggle("Show Highlight", isOn: $setHighlightsYear)
                    }
                }
            }
        } else {
            ProgressView()
        }
    }
    
    private func findDomain(in features: [[Feature]]) -> [Double] {
        var minDomain: Double = 0
        var maxDomain: Double = 0
        for feature in features {
            guard let first = feature.first else {
                continue
            }
            
            var min = first.properties[keyPath: selectedProperty.keyPath] as? Double ?? 0
            var max = first.properties[keyPath: selectedProperty.keyPath] as? Double ?? 0
            
            for data in feature {
                let val = data.properties[keyPath: selectedProperty.keyPath] as? Double ?? 0
                if val < min {
                    min = val
                }
                if val > max {
                    max = val
                }
            }
//            print(min, max)
            if min < minDomain {
                minDomain = min
            }
            if max > maxDomain {
                maxDomain = max
            }
                
        }
        
//        print(minDomain, maxDomain)
        return [minDomain, maxDomain]
    }
}

#Preview {
    ContentView()
}
