//
//  Transaction.swift
//  BudgetTracker
//
//  Created by Srilu Rao on 2/19/25.
//

import Foundation

enum TransactionType: String, Codable {
    case income
    case expense
}

struct Transaction : Identifiable, Codable {
    var id: UUID
    var amount: Double
    var category: String
    var date: Date
    var type: TransactionType// "income" or "expense"
}
