//
//  RecurringTransactionsView.swift
//  BudgetTracker
//
//  Created by Srilu Rao on 2/19/25.
//

import SwiftUI

struct RecurringTransactionsView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @State private var isEditMode: EditMode = .inactive

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Recurring Expenses Section
                    if !viewModel.recurringExpenses.isEmpty {
                        SectionView(
                            title: "Recurring Expenses",
                            transactions: viewModel.recurringExpenses,
                            onDelete: { indexSet in
                                viewModel.deleteRecurringTransaction(at: indexSet, isExpense: true)
                            }
                        )
                    }

                    // Recurring Income Section
                    if !viewModel.recurringIncome.isEmpty {
                        SectionView(
                            title: "Recurring Income",
                            transactions: viewModel.recurringIncome,
                            onDelete: { indexSet in
                                viewModel.deleteRecurringTransaction(at: indexSet, isExpense: false)
                            }
                        )
                    }

                    // Empty State
                    if viewModel.recurringExpenses.isEmpty && viewModel.recurringIncome.isEmpty {
                        EmptyStateView()
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Recurring Transactions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .environment(\.editMode, $isEditMode) // Enable edit mode
        }
    }
}

// MARK: - SectionView
struct SectionView: View {
    let title: String
    let transactions: [Transaction]
    let onDelete: (IndexSet) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            // Use a List for swipe-to-delete functionality
            List {
                ForEach(transactions) { transaction in
                    TransactionCard(transaction: transaction)
                        .padding(.vertical, 5)
                }
                .onDelete(perform: onDelete) // Enable swipe-to-delete
            }
            .listStyle(PlainListStyle()) // Remove default list styling
            .frame(height: CGFloat(transactions.count) * 80) // Adjust height dynamically
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - TransactionCard
struct TransactionCard: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            // Icon for Recurring Transactions
            Image(systemName: "repeat")
                .foregroundColor(.blue)
                .frame(width: 30, height: 30)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 5) {
                Text(transaction.category)
                    .font(.headline)
                if let interval = transaction.recurrenceInterval {
                    Text(interval.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }

            Spacer()

            Text("\(transaction.type == .income ? "+" : "-")$\(transaction.amount, specifier: "%.2f")")
                .font(.subheadline)
                .foregroundColor(transaction.type == .income ? .green : .red)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

// MARK: - EmptyStateView
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "repeat")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            Text("No Recurring Transactions")
                .font(.headline)
                .foregroundColor(.primary)
            Text("Add recurring expenses or income to see them here.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    RecurringTransactionsView(viewModel: TransactionViewModel())
}
