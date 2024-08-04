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
                        features: [
                            byYearMonth[1960]![month]!,
                            byYearMonth[1961]![month]!,
                            byYearMonth[1962]![month]!,
//                            byYearMonth[1963]![month]!,
//                            byYearMonth[1964]![month]!,
                            
//                            byYearMonth[1965]![month]!,
                            byYearMonth[1966]![month]!,
                            byYearMonth[1967]![month]!,
                            byYearMonth[1968]![month]!,
                            byYearMonth[1969]![month]!,
                            
                            byYearMonth[1970]![month]!,
                            byYearMonth[1971]![month]!,
                            byYearMonth[1972]![month]!,
                            byYearMonth[1973]![month]!,
                            byYearMonth[1974]![month]!,
                            
                            byYearMonth[1975]![month]!,
                            byYearMonth[1976]![month]!,
                            byYearMonth[1977]![month]!,
                            byYearMonth[1978]![month]!,
                            byYearMonth[1979]![month]!,
                            
                            byYearMonth[1980]![month]!,
                            byYearMonth[1981]![month]!,
                            byYearMonth[1982]![month]!,
                            byYearMonth[1983]![month]!,
                            byYearMonth[1984]![month]!,
                            
                            byYearMonth[1985]![month]!,
                            byYearMonth[1986]![month]!,
                            byYearMonth[1987]![month]!,
//                            byYearMonth[1988]![6]!,
//                            byYearMonth[1989]![6]!,
                            
                            byYearMonth[1990]![month]!,
                            byYearMonth[1991]![month]!,
                            byYearMonth[1992]![month]!,
                            byYearMonth[1993]![month]!,
                            byYearMonth[1994]![month]!,
                            
                            byYearMonth[1995]![month]!,
                            byYearMonth[1996]![month]!,
                            byYearMonth[1997]![month]!,
                            byYearMonth[1998]![month]!,
                            byYearMonth[1999]![month]!,
                            
                            byYearMonth[2000]![month]!,
                            byYearMonth[2001]![month]!,
                            byYearMonth[2002]![month]!,
                            byYearMonth[2003]![month]!,
                            byYearMonth[2004]![month]!,
                            
                            byYearMonth[2005]![month]!,
                            byYearMonth[2006]![month]!,
                            byYearMonth[2007]![month]!,
                            byYearMonth[2008]![month]!,
                            byYearMonth[2009]![month]!,
                            
                            byYearMonth[2010]![month]!,
//                            byYearMonth[2011]![6]!,
                            byYearMonth[2012]![month]!,
                            byYearMonth[2013]![month]!,
                            byYearMonth[2014]![month]!,
                            
                            byYearMonth[2015]![month]!,
                            byYearMonth[2016]![month]!,
                            byYearMonth[2017]![month]!,
                            byYearMonth[2018]![month]!,
                            byYearMonth[2019]![month]!,
                            
                            byYearMonth[2020]![month]!,
                            byYearMonth[2021]![month]!,
                            byYearMonth[2022]![month]!,
                            byYearMonth[2023]![month]!,
                            byYearMonth[2024]![month]!,
                        ]
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
}

#Preview {
    ContentView()
}
