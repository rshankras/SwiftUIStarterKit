//
//  ExchangeRateService.swift
//  LiveCurrency
//
//  Created by Ravi Shankar on 18/09/24.
//

import Foundation
import SwiftyJSON

class ExchangeRateService {
    static let shared = ExchangeRateService()
    private let baseURL = "https://open.er-api.com/v6/latest/USD"
    
    private init() {}
    
    func fetchExchangeRates() async throws -> [String: Double] {
        guard let url = URL(string: baseURL) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSON(data: data)
        
        guard let rates = json["rates"].dictionary else {
            throw NSError(domain: "ParseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse rates"])
        }
        
        return rates.mapValues { $0.doubleValue }
    }
}
