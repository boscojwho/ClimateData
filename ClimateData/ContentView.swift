//
//  ContentView.swift
//  ClimateData
//
//  Created by Bosco Ho on 2024-08-03.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var climateData: FeatureCollection?
    @State private var byYear: [Int : [Feature]]?
    @State private var byYearMonth: [Int : [Int : [Feature]]]?
    @State private var features: [[Feature]] = []
    @State private var domain: [Double] = [0, 0]
    @State private var stationDataFileUrl: URL? = Bundle.main.url(
        forResource: "vancouver_harbour_daily_1924_2024",
        withExtension: "json"
    )

    var body: some View {
        NavigationSplitView {
            ScrollView {
                filters()
                    .padding()
                    .id(stationDataFileUrl)
            }
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
                        .onChange(of: stationDataFileUrl) {
                            let features = features(
                                Int(selectedMinYear)...Int(selectedMaxYear),
                                month: Int(selectedMonth)
                            )
                            let domain = findDomain(in: byYear.values.compactMap { $0 })
                            self.features = features
                            self.domain = domain
                        }
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
            .task(id: stationDataFileUrl) {
                if let stationDataFileUrl {
                    do {
                        try loadStationData(url: stationDataFileUrl)
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    private func loadStationData(url: URL) throws {
        let decoder = JSONDecoder()
        let data = try Data(contentsOf: url)
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
    
    @ViewBuilder private func stationData() -> some View {
        if let feature = climateData?.features.first,
            let lat = feature.geometry.coordinates.last,
            let long = feature.geometry.coordinates.first {
            let stationName = feature.properties.stationName
            GroupBox {
                Text(stationName)
                Map(
                    bounds: .init(minimumDistance: 1000,maximumDistance: 15000),
                    interactionModes: [.zoom, .pan]
                ) {
                    Marker(
                        stationName,
                        coordinate: .init(latitude: lat, longitude: long)
                    )
                    .mapOverlayLevel(level: .aboveLabels)
                }
                .mapStyle(.standard)
                .mapControlVisibility(.hidden)
            }
            .aspectRatio(1, contentMode: .fit)
        } else {
            EmptyView()
        }
    }
    
    @State private var selectedProperty: Properties.CodingKeys = .maxTemperature
    @State private var selectedMinYear: Double = 1900
    @State private var selectedMaxYear: Double = 2024
    @State private var selectedMonth: Double = 1
    
    @State private var setHighlightsYear = true
    @State private var highlightYear: Double = 2024
    
    @State private var isHoveringOverDropZone = false
    @State private var isDroppingClimateDataFile = false
    
    @ViewBuilder
    private func filters() -> some View {
        if let climateData {
            let years: [Int] = Array(byYear!.keys.sorted { $0 < $1 })
            VStack {
                stationData()
                GroupBox {
                    VStack(alignment: .leading) {
                        Text("Loaded ^[\(climateData.numberReturned) day](inflect: true) of data.")
                        Text("Data Source: https://climatedata.ca/download/#station-download")
                    }
                    GroupBox {
                        ContentUnavailableView {
                            Image(systemName: "arrow.down")
                                .symbolRenderingMode(.monochrome)
                                .symbolVariant(.circle)
                                .bold()
                                .symbolEffect(.scale.up, options: .repeating, isActive: isDroppingClimateDataFile)
                        } description: {
                            Text("Drag and drop ClimateData station data in GeoJSON format here")
                                .font(.body)
                        }
                    }
                    .onHover(perform: { hovering in
                        if isDroppingClimateDataFile == false {
                            isHoveringOverDropZone = hovering
                        }
                    })
                    .climateDataFileDrop(
                        fileUrl: $stationDataFileUrl,
                        isTargeted: $isDroppingClimateDataFile
                    )
                    .foregroundStyle(isDroppingClimateDataFile ? .blue : Color.secondary)
                    .symbolEffect(.pulse, options: .repeating, isActive: isDroppingClimateDataFile)
                    .symbolEffect(.bounce.byLayer, value: isHoveringOverDropZone)
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
