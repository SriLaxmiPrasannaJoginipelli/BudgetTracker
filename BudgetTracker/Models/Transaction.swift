//
//  Transaction.swift
//  BudgetTracker
//
//  Created by Srilu Rao on 2/19/25.
//

import Foundation


struct Transaction : Identifiable, Codable {
    var id: UUID
    var amount: Double
    var category: String
    var date: Date
    var type: String// "income" or "expense"
}
