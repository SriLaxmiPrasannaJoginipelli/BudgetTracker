//
//  TransactionViewModel.swift
//  BudgetTracker
//
//  Created by Srilu Rao on 2/19/25.
//


import Foundation
import SwiftUI



class TransactionViewModel: ObservableObject {
    private let transactionManager = TransactionManager()
    private let userDefaultsKey = "transactions"
    private let budgetUserDefaultsKey = "totalBudget"
    private let balanceUserDefaultsKey = "userBalance"
    @Published var showAlertForBudget = false
    
    @Published var totalBudget: Double?{
        didSet {
            // Save the budget whenever it is set
            UserDefaults.standard.set(totalBudget, forKey: budgetUserDefaultsKey)
        }
    }
    
    @Published var balance: Double = 0.0 {
        didSet {
            UserDefaults.standard.set(balance, forKey: balanceUserDefaultsKey)
        }
    }
    
    init() {
        
        fetchBalance()
        fetchTransactions()
    }
    
    
    @Published var transactions: [Transaction] = [
        Transaction(id: UUID(), amount: 500.0, category: "Salary", date: Date(), type: TransactionType.income, isRecurring: false),
        Transaction(id: UUID(), amount: 50.0, category: "Groceries", date: Date(), type: TransactionType.expense, isRecurring: false),
        Transaction(id: UUID(), amount: 100.0, category: "Rent", date: Date(), type: TransactionType.expense, isRecurring: false),
        Transaction(id: UUID(), amount: 20.0, category: "Entertainment", date: Date(), type: TransactionType.expense, isRecurring: false),
        Transaction(id: UUID(), amount: 200.0, category: "Freelance", date: Date(), type: TransactionType.income, isRecurring: false),
        Transaction(id: UUID(), amount: 100.0, category: "ExtraHours", date: Date(), type: TransactionType.income, isRecurring: false),
        Transaction(id: UUID(), amount: 200.0, category: "Business", date: Date(), type: TransactionType.income, isRecurring: false),
        Transaction(id: UUID(), amount: 700.0, category: "SocialMedia", date: Date(), type: TransactionType.income, isRecurring: false),
        Transaction(id: UUID(), amount: 100.0, category: "ExtraHours-1", date: Date(), type: TransactionType.income, isRecurring: false),
        Transaction(id: UUID(), amount: 200.0, category: "Business-2", date: Date(), type: TransactionType.income, isRecurring: false),
        Transaction(id: UUID(), amount: 700.0, category: "SocialMedia-2", date: Date(), type: TransactionType.income, isRecurring: false),
    ]
    
    // Formatted data for Pie Charts
    var totalIncome: Double {
        transactionManager.totalIncome(from: transactions)
    }
    
    var totalExpenses: Double {
        transactionManager.totalExpenses(from: transactions)
    }
    
    // Income Breakdown Data (Category-wise)
    var incomeBreakdown: [String: Double] {
        transactionManager.incomeBreakdown(from: transactions)
    }
    
    // Expense Breakdown Data (Category-wise)
    var expenseBreakdown: [String: Double] {
        transactionManager.expenseBreakdown(from: transactions)
    }
    
    var highestIncomeCategory: String? {
        incomeBreakdown.max { $0.value < $1.value }?.key
    }
    
    var highestExpenseCategory: String?{
        expenseBreakdown.max{ $0.value < $1.value}?.key
    }
    
    //    func addIncome(amount: Double, category: String) {
    //        transactionManager.addIncome(amount: amount, category: category, to: &transactions)
    //        saveTransactions()
    //        updateBalance()
    //    }
    
    //    func addExpense(amount: Double, category: String) {
    //        transactionManager.addExpense(amount: amount, category: category, to: &transactions)
    //        saveTransactions()
    //        updateBalance()
    //    }
    
    func addIncome(transaction: Transaction) {
        transactionManager.addIncome(transaction: transaction, to: &transactions)
        saveTransactions()
        updateBalance()
    }
    
    func addExpense(transaction: Transaction) {
        transactionManager.addExpense(transaction: transaction, to: &transactions)
        saveTransactions()
        updateBalance()
    }
    
    
    func deleteIncome(at offsets: IndexSet) {
        for index in offsets {
            let transaction = transactions[index]
            transactionManager.deleteIncome(with: transaction.id, from: &transactions)
            saveTransactions()
            updateBalance()
        }
    }
    
    func deleteExpense(at offsets: IndexSet) {
        for index in offsets {
            let transaction = transactions[index]
            transactionManager.deleteExpense(with: transaction.id, from: &transactions)
            saveTransactions()
            updateBalance()
        }
    }
    
    
    func fetchTransactions() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            do {
                var savedTransactions = try JSONDecoder().decode([Transaction].self, from: data)
                let recurringTransactions = transactionManager.generateRecurringTransactions(from: savedTransactions)
                savedTransactions.append(contentsOf: recurringTransactions)
                transactions = savedTransactions
            } catch {
                print("Failed to decode transactions: \(error)")
            }
        }
        updateBalance()
    }
    
    private func saveTransactions() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(transactions)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Failed to encode transactions: \(error)")
        }
    }
    
    func setBudget(amount: Double) {
        self.totalBudget = amount
    }
    
    private func fetchBudget() {
        if let savedBudget = UserDefaults.standard.value(forKey: budgetUserDefaultsKey) as? Double {
            totalBudget = savedBudget
        }
    }
    
    private func updateBalance() {
        print("income : \(totalIncome)")
        print("expenses : \(totalExpenses)")
        balance = totalIncome - totalExpenses
    }
    
    func fetchBalance() {
        if let savedBalance = UserDefaults.standard.value(forKey: balanceUserDefaultsKey) as? Double {
            balance = savedBalance
        }
    }
    
    // Method to calculate the remaining budget
    func remainingBudget() -> Double {
        guard let totalBudget = totalBudget else {
            return 0.0
        }
        
        let remainingBudget = totalBudget - totalExpenses
        
        print("Total budget: \(totalBudget)")
        print("Total expenses: \(totalExpenses)")
        print("Remaining budget: \(remainingBudget)")
        
        showAlertForBudget = remainingBudget < 200
        
        return remainingBudget
    }
    
    var recurringExpenses: [Transaction] {
        transactions.filter { $0.type == .expense && $0.isRecurring }
    }
    
    // Computed property for non-recurring expenses
    var nonRecurringExpenses: [Transaction] {
        transactions.filter { $0.type == .expense && !$0.isRecurring }
    }
    
    var recurringIncome: [Transaction] {
        transactions.filter { $0.type == .income && $0.isRecurring }
    }
    
    func deleteRecurringTransaction(at offsets: IndexSet, isExpense: Bool) {
        let filteredTransactions = isExpense ? recurringExpenses : recurringIncome
        for index in offsets {
            let transaction = filteredTransactions[index]
            transactions.removeAll { $0.id == transaction.id }
        }
        saveTransactions()
        updateBalance()
    }
    
    
}
