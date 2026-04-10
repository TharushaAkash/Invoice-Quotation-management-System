import { expenseService } from '../services/expense-service.js';

let currentExpense = null;

window.openExpenseModal = function(expense = null) {
    currentExpense = expense;
    const modal = createExpenseModal(expense);
    document.getElementById('modal-container').innerHTML = modal;
    document.getElementById('expense-modal').classList.add('active');
};

function createExpenseModal(expense) {
    return `
        <div id="expense-modal" class="modal active">
            <div class="modal-content">
                <div class="modal-header">
                    <h3>${expense ? 'Edit Expense' : 'New Expense'}</h3>
                    <button class="modal-close" onclick="closeModal('expense-modal')">&times;</button>
                </div>
                <form id="expense-form">
                    <div class="form-group">
                        <label>Date</label>
                        <input type="date" id="expense-date" value="${expense?.date || new Date().toISOString().split('T')[0]}" required>
                    </div>
                    <div class="form-group">
                        <label>Category</label>
                        <select id="expense-category" required>
                            <option value="">Select Category</option>
                            <option value="Rent" ${expense?.category === 'Rent' ? 'selected' : ''}>Rent</option>
                            <option value="Utilities" ${expense?.category === 'Utilities' ? 'selected' : ''}>Utilities</option>
                            <option value="Supplies" ${expense?.category === 'Supplies' ? 'selected' : ''}>Supplies</option>
                            <option value="Salaries" ${expense?.category === 'Salaries' ? 'selected' : ''}>Salaries</option>
                            <option value="Marketing" ${expense?.category === 'Marketing' ? 'selected' : ''}>Marketing</option>
                            <option value="Transport" ${expense?.category === 'Transport' ? 'selected' : ''}>Transport</option>
                            <option value="Other" ${expense?.category === 'Other' ? 'selected' : ''}>Other</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Description</label>
                        <input type="text" id="expense-description" value="${expense?.description || ''}" required>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>Amount</label>
                            <input type="number" id="expense-amount" value="${expense?.amount || 0}" step="0.01" min="0" required>
                        </div>
                        <div class="form-group">
                            <label>Payment Method</label>
                            <select id="expense-payment-method" required>
                                <option value="CASH" ${expense?.paymentMethod === 'CASH' ? 'selected' : ''}>Cash</option>
                                <option value="BANK" ${expense?.paymentMethod === 'BANK' ? 'selected' : ''}>Bank</option>
                                <option value="CARD" ${expense?.paymentMethod === 'CARD' ? 'selected' : ''}>Card</option>
                            </select>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>Vendor</label>
                            <input type="text" id="expense-vendor" value="${expense?.vendor || ''}">
                        </div>
                        <div class="form-group">
                            <label>Receipt Number</label>
                            <input type="text" id="expense-receipt" value="${expense?.receiptNumber || ''}">
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Notes</label>
                        <textarea id="expense-notes">${expense?.notes || ''}</textarea>
                    </div>
                    <div class="modal-actions">
                        <button type="button" class="btn btn-secondary" onclick="closeModal('expense-modal')">Cancel</button>
                        <button type="submit" class="btn btn-primary">Save</button>
                    </div>
                </form>
            </div>
        </div>
    `;
}

document.addEventListener('DOMContentLoaded', () => {
    loadExpenses();
    
    document.addEventListener('submit', async (e) => {
        if (e.target.id === 'expense-form') {
            e.preventDefault();
            await saveExpense();
        }
    });
});

async function loadExpenses() {
    try {
        const expenses = await expenseService.getAll();
        const tbody = document.getElementById('expenses-table-body');
        
        if (expenses.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" class="empty-state">No expenses found. Record your first expense!</td></tr>';
            return;
        }
        
        tbody.innerHTML = expenses.map(expense => `
            <tr>
                <td>${window.formatDate(expense.date)}</td>
                <td>${expense.category || 'N/A'}</td>
                <td>${expense.description || 'N/A'}</td>
                <td>${window.formatCurrency(expense.amount || 0)}</td>
                <td>${expense.paymentMethod || 'N/A'}</td>
                <td>
                    <div class="action-buttons">
                        <button class="action-btn action-btn-edit" onclick='openExpenseModal(${JSON.stringify(expense)})'>Edit</button>
                        <button class="action-btn action-btn-delete" onclick="deleteExpense('${expense.id}')">Delete</button>
                    </div>
                </td>
            </tr>
        `).join('');
    } catch (error) {
        console.error('Error loading expenses:', error);
        document.getElementById('expenses-table-body').innerHTML = 
            '<tr><td colspan="6" class="empty-state">Error loading expenses. Please check Firebase configuration.</td></tr>';
    }
}

async function saveExpense() {
    try {
        const expense = {
            date: document.getElementById('expense-date').value,
            category: document.getElementById('expense-category').value,
            description: document.getElementById('expense-description').value,
            amount: parseFloat(document.getElementById('expense-amount').value) || 0,
            paymentMethod: document.getElementById('expense-payment-method').value,
            vendor: document.getElementById('expense-vendor').value,
            receiptNumber: document.getElementById('expense-receipt').value,
            notes: document.getElementById('expense-notes').value
        };
        
        if (currentExpense?.id) {
            await expenseService.update(currentExpense.id, expense);
            alert('Expense updated successfully!');
        } else {
            await expenseService.create(expense);
            alert('Expense recorded successfully!');
        }
        
        closeModal('expense-modal');
        loadExpenses();
    } catch (error) {
        console.error('Error saving expense:', error);
        alert('Error saving expense. Please try again.');
    }
}

window.deleteExpense = async function(id) {
    if (!confirm('Are you sure you want to delete this expense?')) return;
    
    try {
        await expenseService.delete(id);
        alert('Expense deleted successfully!');
        loadExpenses();
    } catch (error) {
        console.error('Error deleting expense:', error);
        alert('Error deleting expense. Please try again.');
    }
};

