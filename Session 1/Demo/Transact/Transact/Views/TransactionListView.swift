//
//  TransactionListView.swift
//  Transact
//
//  Created by Ravi Shankar on 11/03/25.
//

import SwiftUI

struct TransactionListView: View {
    @State private var transactions: [Transaction] = []
    @State private var isShowingAddTransaction: Bool = false
    
    var body: some View {
        NavigationStack {
            List(transactions) { transaction in
                NavigationLink(destination: TransactionDetailView(transaction: transaction)) {
                    TransactionRow(transaction: transaction)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        deleteItem(transaction: transaction)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Transactions")
            .navigationBarItems(trailing: Button(action: {
                isShowingAddTransaction = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $isShowingAddTransaction) {
                AddTransactionView(transactions: $transactions)
            }
            .onAppear {
                loadTransactions()
            }
            .refreshable {
                loadTransactions()
            }
        }
    }
    
    private func deleteItem(transaction: Transaction) {
        if let index = transactions.firstIndex(of: transaction) {
            transactions.remove(at: index)
        }
    }
    
    private func loadTransactions() {
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.transactions = [
                Transaction(id: UUID(), date: Date().addingTimeInterval(-86400 * 2), amount: 120.50, description: "Grocery Shopping", type: .debit),
                Transaction(id: UUID(), date: Date().addingTimeInterval(-86400), amount: 1500.00, description: "Salary Deposit", type: .credit),
                Transaction(id: UUID(), date: Date().addingTimeInterval(-43200), amount: 65.00, description: "Restaurant Bill", type: .debit),
                Transaction(id: UUID(), date: Date().addingTimeInterval(-21600), amount: 200.00, description: "ATM Withdrawal", type: .debit),
                Transaction(id: UUID(), date: Date(), amount: 35.99, description: "Online Subscription", type: .debit),
                Transaction(id: UUID(), date: Date().addingTimeInterval(-129600), amount: 520.00, description: "Rent Payment", type: .debit),
                Transaction(id: UUID(), date: Date().addingTimeInterval(-172800), amount: 50.00, description: "Friend Transfer", type: .credit),
                Transaction(id: UUID(), date: Date().addingTimeInterval(-259200), amount: 80.75, description: "Utility Bill", type: .debit),
                Transaction(id: UUID(), date: Date().addingTimeInterval(-345600), amount: 160.00, description: "Clothing Purchase", type: .debit),
                Transaction(id: UUID(), date: Date().addingTimeInterval(-432000), amount: 1000.00, description: "Bonus Payment", type: .credit)
            ]
        }
    }
}

struct TransactionRow: View {
    var transaction: Transaction
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.description)
                    .font(.headline)
                Text(transaction.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(String(format: "$%.2f", transaction.amount))
                .foregroundColor(transaction.type == .credit ? .green : .red)
        }
    }
}

#Preview {
    TransactionListView()
}

