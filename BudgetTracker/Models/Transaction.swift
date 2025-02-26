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

enum RecurrenceInterval: String, Codable {
    case daily
    case weekly
    case monthly
}

struct Transaction : Identifiable, Codable {
    var id: UUID
    var amount: Double
    var category: String
    var date: Date
    var type: TransactionType// "income" or "expense"
    var isRecurring: Bool // Indicates if the transaction is recurring
    var recurrenceInterval: RecurrenceInterval?
}
