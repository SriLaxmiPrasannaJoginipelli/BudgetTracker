//
//  AddMonthBudgetView.swift
//  BudgetTracker
//
//  Created by Srilu Rao on 2/20/25.
//
import SwiftUI

struct AddMonthBudgetView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @State private var budgetAmount: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Enter your budget for this month")
                    .font(.title)
                    .padding()
                
                TextField("Budget Amount", text: $budgetAmount)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                Button(action: saveBudget) {
                    Text("Save Budget")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Set Budget")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func saveBudget() {
        guard let amount = Double(budgetAmount), amount > 0 else { return }
        viewModel.setBudget(amount: amount) // Method to set the budget
        presentationMode.wrappedValue.dismiss()
    }
}
