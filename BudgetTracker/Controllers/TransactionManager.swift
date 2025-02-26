//
//  TransactionManager.swift
//  BudgetTracker
//
//  Created by Srilu Rao on 2/19/25.
//

import Foundation

protocol TransactionService {
    func addIncome(amount: Double, category: String, to transactions: inout [Transaction])
    func addExpense(amount: Double, category: String, to transactions: inout [Transaction])
    func deleteIncome(with id: UUID, from transactions:  inout [Transaction])
    func deleteExpense(with id: UUID, from transactions: inout [Transaction])
}

class TransactionManager : TransactionService{
    
    
    func totalIncome(from transactions: [Transaction]) -> Double {
        transactions.filter { $0.type.rawValue == TransactionType.income.rawValue }.map { $0.amount }.reduce(0, +)
    }
    
    func totalExpenses(from transactions: [Transaction]) -> Double {
        transactions.filter { $0.type.rawValue == TransactionType.expense.rawValue }.map { $0.amount }.reduce(0, +)
    }
    
    func incomeBreakdown(from transactions: [Transaction]) -> [String: Double] {
        var breakdown = [String: Double]()
        for transaction in transactions.filter({ $0.type.rawValue == TransactionType.income.rawValue }) {
            breakdown[transaction.category, default: 0] += transaction.amount
        }
        return breakdown
    }
    
    func expenseBreakdown(from transactions: [Transaction]) -> [String: Double] {
        var breakdown = [String: Double]()
        for transaction in transactions.filter({ $0.type.rawValue == TransactionType.expense.rawValue }) {
            breakdown[transaction.category, default: 0] += transaction.amount
        }
        return breakdown
    }
    
    func addIncome(amount: Double, category: String, to transactions: inout [Transaction]) {
        let newTransaction = Transaction(id: UUID(), amount: amount, category: category, date: Date(), type: TransactionType(rawValue: TransactionType.income.rawValue) ?? TransactionType.income)
        transactions.append(newTransaction)
    }
    
    // Delete an income transaction by ID
    func deleteIncome(with id: UUID, from transactions: inout [Transaction]) {
        transactions.removeAll { $0.id == id }
    }
    
    func addExpense(amount: Double, category: String, to transactions: inout [Transaction]) {
        let newTransaction = Transaction(id: UUID(), amount: amount, category: category, date: Date(), type: TransactionType(rawValue: TransactionType.expense.rawValue) ?? TransactionType.expense)
        transactions.append(newTransaction)
    }
    
    func deleteExpense(with id: UUID, from transactions: inout [Transaction]) {
        transactions.removeAll { $0.id == id }
    }

    
}
