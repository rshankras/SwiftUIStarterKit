//
//  CurrencyViewModel.swift
//  LiveCurrency
//
//  Created by Ravi Shankar on 18/09/24.
//

import Foundation
import SwiftUI

struct Currency: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let symbol: String
    var conversionRate: Double
}

class CurrencyViewModel: ObservableObject {
    @Published var currencies: [Currency] = [
        Currency(name: "US Dollar", symbol: "USD", conversionRate: 1.0),
        Currency(name: "Euro", symbol: "EUR", conversionRate: 1.0),
        Currency(name: "British Pound", symbol: "GBP", conversionRate: 1.0),
        Currency(name: "Japanese Yen", symbol: "JPY", conversionRate: 1.0),
        Currency(name: "Indian Rupees", symbol: "INR", conversionRate: 1.0)
    ]
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedFromCurrency: Currency?
    @Published var selectedToCurrency: Currency?
    
    init() {
         // Set default selections
         selectedFromCurrency = currencies.first(where: { $0.symbol == "USD" })
         selectedToCurrency = currencies.first(where: { $0.symbol == "EUR" })
     }
     
    
    func updateExchangeRates() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let rates = try await ExchangeRateService.shared.fetchExchangeRates()
                await MainActor.run {
                    for i in 0..<currencies.count {
                        currencies[i].conversionRate = rates[currencies[i].symbol] ?? 1.0
                    }
                    // Update selected currencies with new rates
                    if let fromIndex = currencies.firstIndex(where: { $0.symbol == selectedFromCurrency?.symbol }) {
                        selectedFromCurrency = currencies[fromIndex]
                    }
                    if let toIndex = currencies.firstIndex(where: { $0.symbol == selectedToCurrency?.symbol }) {
                        selectedToCurrency = currencies[toIndex]
                    }
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to fetch exchange rates: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
    
    func swapCurrencies() {
          let temp = selectedFromCurrency
          selectedFromCurrency = selectedToCurrency
          selectedToCurrency = temp
      }
}
