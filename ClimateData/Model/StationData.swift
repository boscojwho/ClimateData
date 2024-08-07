//
//  StationData.swift
//  ClimateData
//
//  Created by Bosco Ho on 2024-08-03.
//

import Foundation

struct Geometry: Codable {
    let type: String
    let coordinates: [Double]
}

struct Properties: Codable, Identifiable {
    let heatingDegreeDays: Double?
    let provinceCode: String?
    let minTemperature: Double?
    let snowOnGroundFlag: String?
    let maxRelHumidityFlag: String?
    let maxTemperatureFlag: String?
    let coolingDegreeDaysFlag: String?
    let meanTemperature: Double?
    let localYear: Int
    let totalPrecipitationFlag: String?
    let minRelHumidity: Double?
    let localDate: String
    let coolingDegreeDays: Double?
    let speedMaxGust: Double?
    let speedMaxGustFlag: String?
    let localDay: Int
    let minTemperatureFlag: String?
    let totalRain: Double?
    let totalSnowFlag: String?
    let heatingDegreeDaysFlag: String?
    let directionMaxGustFlag: String?
    let meanTemperatureFlag: String?
    let id: String
    let totalPrecipitation: Double?
    let maxTemperature: Double?
    let maxRelHumidity: Double?
    let totalSnow: Double?
    let minRelHumidityFlag: String?
    let snowOnGround: Double?
    let climateIdentifier: String
    let stationName: String
    let directionMaxGust: Double?
    let totalRainFlag: String?
    let localMonth: Int
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case heatingDegreeDays = "HEATING_DEGREE_DAYS"
        case provinceCode = "PROVINCE_CODE"
        case minTemperature = "MIN_TEMPERATURE"
        case snowOnGroundFlag = "SNOW_ON_GROUND_FLAG"
        case maxRelHumidityFlag = "MAX_REL_HUMIDITY_FLAG"
        case maxTemperatureFlag = "MAX_TEMPERATURE_FLAG"
        case coolingDegreeDaysFlag = "COOLING_DEGREE_DAYS_FLAG"
        case meanTemperature = "MEAN_TEMPERATURE"
        case localYear = "LOCAL_YEAR"
        case totalPrecipitationFlag = "TOTAL_PRECIPITATION_FLAG"
        case minRelHumidity = "MIN_REL_HUMIDITY"
        case localDate = "LOCAL_DATE"
        case coolingDegreeDays = "COOLING_DEGREE_DAYS"
        case speedMaxGust = "SPEED_MAX_GUST"
        case speedMaxGustFlag = "SPEED_MAX_GUST_FLAG"
        case localDay = "LOCAL_DAY"
        case minTemperatureFlag = "MIN_TEMPERATURE_FLAG"
        case totalRain = "TOTAL_RAIN"
        case totalSnowFlag = "TOTAL_SNOW_FLAG"
        case heatingDegreeDaysFlag = "HEATING_DEGREE_DAYS_FLAG"
        case directionMaxGustFlag = "DIRECTION_MAX_GUST_FLAG"
        case meanTemperatureFlag = "MEAN_TEMPERATURE_FLAG"
        case id = "ID"
        case totalPrecipitation = "TOTAL_PRECIPITATION"
        case maxTemperature = "MAX_TEMPERATURE"
        case maxRelHumidity = "MAX_REL_HUMIDITY"
        case totalSnow = "TOTAL_SNOW"
        case minRelHumidityFlag = "MIN_REL_HUMIDITY_FLAG"
        case snowOnGround = "SNOW_ON_GROUND"
        case climateIdentifier = "CLIMATE_IDENTIFIER"
        case stationName = "STATION_NAME"
        case directionMaxGust = "DIRECTION_MAX_GUST"
        case totalRainFlag = "TOTAL_RAIN_FLAG"
        case localMonth = "LOCAL_MONTH"
        
        var keyPath: PartialKeyPath<Properties> {
            switch self {
            case .heatingDegreeDays:
                \.heatingDegreeDays
            case .provinceCode:
                \.provinceCode
            case .minTemperature:
                \.minTemperature
            case .snowOnGroundFlag:
                \.snowOnGroundFlag
            case .maxRelHumidityFlag:
                \.maxRelHumidityFlag
            case .maxTemperatureFlag:
                \.maxTemperatureFlag
            case .coolingDegreeDaysFlag:
                \.coolingDegreeDaysFlag
            case .meanTemperature:
                \.meanTemperature
            case .localYear:
                \.localYear
            case .totalPrecipitationFlag:
                \.totalPrecipitationFlag
            case .minRelHumidity:
                \.minRelHumidity
            case .localDate:
                \.localDate
            case .coolingDegreeDays:
                \.coolingDegreeDays
            case .speedMaxGust:
                \.speedMaxGust
            case .speedMaxGustFlag:
                \.speedMaxGustFlag
            case .localDay:
                \.localDay
            case .minTemperatureFlag:
                \.minTemperatureFlag
            case .totalRain:
                \.totalRain
            case .totalSnowFlag:
                \.totalSnowFlag
            case .heatingDegreeDaysFlag:
                \.heatingDegreeDaysFlag
            case .directionMaxGustFlag:
                \.directionMaxGustFlag
            case .meanTemperatureFlag:
                \.meanTemperatureFlag
            case .id:
                \.id
            case .totalPrecipitation:
                \.totalPrecipitation
            case .maxTemperature:
                \.maxTemperature
            case .maxRelHumidity:
                \.maxRelHumidity
            case .totalSnow:
                \.totalSnow
            case .minRelHumidityFlag:
                \.minRelHumidityFlag
            case .snowOnGround:
                \.snowOnGround
            case .climateIdentifier:
                \.climateIdentifier
            case .stationName:
                \.stationName
            case .directionMaxGust:
                \.directionMaxGust
            case .totalRainFlag:
                \.totalRainFlag
            case .localMonth:
                \.localMonth
            }
        }
    }
}

struct Link: Codable {
    let type: String
    let rel: String
    let title: String
    let href: String
}

struct Feature: Codable, Identifiable, Hashable {
    let id: String
    let type: String
    let geometry: Geometry
    let properties: Properties
    
    static func == (lhs: Feature, rhs: Feature) -> Bool {
        lhs.id == rhs.id && lhs.type == rhs.type
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(type)
    }
}

struct FeatureCollection: Codable {
    let type: String
    let features: [Feature]
    let numberMatched: Int
    let numberReturned: Int
    let links: [Link]
    let timeStamp: String
}
