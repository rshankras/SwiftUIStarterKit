//
//  TransactionDetailView.swift
//  Transact
//
//  Created by Ravi Shankar on 11/03/25.
//

import SwiftUI

struct TransactionDetailView: View {
    @State var transaction: Transaction
    var body: some View {
        VStack (alignment: .leading) {
            Text(transaction.description)
                .font(.title)
            Text(transaction.date, style: .date)
            Text(String(format: "$%.2f", transaction.amount))
                .font(.title2)
                .foregroundColor(transaction.type == .credit ? .green : .red)
            Text("Type: \(transaction.type == .credit ? "Credit" : "Debit")")
            Spacer()
        }
    }
}

#Preview {
    TransactionDetailView(transaction:Transaction(id: UUID(), date: Date().addingTimeInterval(-86400 * 2), amount: 120.50, description: "Grocery Shopping", type: .debit))
}
