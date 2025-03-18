//
//  ContentView.swift
//  LiveCurrency
//
//  Created by Ravi Shankar on 18/09/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CurrencyViewModel()
    @State private var amount: String = ""
    
    private var convertedAmount: Double {
        guard let amountDouble = Double(amount),
              let fromCurrency = viewModel.selectedFromCurrency,
              let toCurrency = viewModel.selectedToCurrency else { return 0 }
        let inUSD = amountDouble / fromCurrency.conversionRate
        return inUSD * toCurrency.conversionRate
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Amount to convert")) {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("From")) {
                    Picker("From", selection: $viewModel.selectedFromCurrency) {
                        ForEach(viewModel.currencies) { currency in
                            Text(currency.name).tag(currency as Currency?)
                        }
                    }
                }
                
                Section(header: Text("To")) {
                    Picker("To", selection: $viewModel.selectedToCurrency) {
                        ForEach(viewModel.currencies) { currency in
                            Text(currency.name).tag(currency as Currency?)
                        }
                    }
                }
                
                Section(header: Text("Converted Amount")) {
                    Text(convertedAmount, format: .currency(code: viewModel.selectedToCurrency?.symbol ?? "USD"))
                        .font(.largeTitle)
                        .foregroundColor(.green)
                }
                
                Section {
                    Button("Swap Currencies") {
                        viewModel.swapCurrencies()
                    }
                    .buttonStyle(InteractiveButtonStyle())
                }
                
                if viewModel.isLoading {
                    ProgressView()
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Currency Converter")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        viewModel.updateExchangeRates()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
        .onAppear {
            viewModel.updateExchangeRates()
        }
    }
}

struct InteractiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(configuration.isPressed ? Color.orange : Color.green)
            .cornerRadius(10)
            .frame(minWidth: 0, maxWidth: .infinity)
            .foregroundColor(.white)
    }
}

#Preview {
    ContentView()
}
