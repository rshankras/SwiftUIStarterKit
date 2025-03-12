//
//  Transaction.swift
//  Transact
//
//  Created by Ravi Shankar on 11/03/25.
//

import Foundation

struct Transaction:Identifiable, Equatable {
    let id: UUID
    let date: Date
    let amount: Double
    let description: String
    let type: TransactionType
}

enum TransactionType {
    case credit, debit
}


