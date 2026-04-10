import { incomeService } from '../services/income-service.js';

let currentIncome = null;

window.openIncomeModal = function(income = null) {
    currentIncome = income;
    const modal = createIncomeModal(income);
    document.getElementById('modal-container').innerHTML = modal;
    document.getElementById('income-modal').classList.add('active');
};

function createIncomeModal(income) {
    return `
        <div id="income-modal" class="modal active">
            <div class="modal-content">
                <div class="modal-header">
                    <h3>${income ? 'Edit Income' : 'New Income'}</h3>
                    <button class="modal-close" onclick="closeModal('income-modal')">&times;</button>
                </div>
                <form id="income-form">
                    <div class="form-group">
                        <label>Date</label>
                        <input type="date" id="income-date" value="${income?.date || new Date().toISOString().split('T')[0]}" required>
                    </div>
                    <div class="form-group">
                        <label>Source</label>
                        <select id="income-source" required>
                            <option value="">Select Source</option>
                            <option value="Invoice Payment" ${income?.source === 'Invoice Payment' ? 'selected' : ''}>Invoice Payment</option>
                            <option value="Service Fee" ${income?.source === 'Service Fee' ? 'selected' : ''}>Service Fee</option>
                            <option value="Other" ${income?.source === 'Other' ? 'selected' : ''}>Other</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Description</label>
                        <input type="text" id="income-description" value="${income?.description || ''}" required>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>Amount</label>
                            <input type="number" id="income-amount" value="${income?.amount || 0}" step="0.01" min="0" required>
                        </div>
                        <div class="form-group">
                            <label>Payment Method</label>
                            <select id="income-payment-method" required>
                                <option value="CASH" ${income?.paymentMethod === 'CASH' ? 'selected' : ''}>Cash</option>
                                <option value="BANK" ${income?.paymentMethod === 'BANK' ? 'selected' : ''}>Bank</option>
                                <option value="CARD" ${income?.paymentMethod === 'CARD' ? 'selected' : ''}>Card</option>
                                <option value="CHEQUE" ${income?.paymentMethod === 'CHEQUE' ? 'selected' : ''}>Cheque</option>
                            </select>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>Customer Name</label>
                            <input type="text" id="income-customer-name" value="${income?.customerName || ''}">
                        </div>
                        <div class="form-group">
                            <label>Invoice ID (if applicable)</label>
                            <input type="text" id="income-invoice-id" value="${income?.invoiceId || ''}">
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Notes</label>
                        <textarea id="income-notes">${income?.notes || ''}</textarea>
                    </div>
                    <div class="modal-actions">
                        <button type="button" class="btn btn-secondary" onclick="closeModal('income-modal')">Cancel</button>
                        <button type="submit" class="btn btn-primary">Save</button>
                    </div>
                </form>
            </div>
        </div>
    `;
}

document.addEventListener('DOMContentLoaded', () => {
    loadIncomes();
    
    document.addEventListener('submit', async (e) => {
        if (e.target.id === 'income-form') {
            e.preventDefault();
            await saveIncome();
        }
    });
});

async function loadIncomes() {
    try {
        const incomes = await incomeService.getAll();
        const tbody = document.getElementById('income-table-body');
        
        if (incomes.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" class="empty-state">No income records found. Record your first income!</td></tr>';
            return;
        }
        
        tbody.innerHTML = incomes.map(income => `
            <tr>
                <td>${window.formatDate(income.date)}</td>
                <td>${income.source || 'N/A'}</td>
                <td>${income.description || 'N/A'}</td>
                <td>${window.formatCurrency(income.amount || 0)}</td>
                <td>${income.customerName || 'N/A'}</td>
                <td>
                    <div class="action-buttons">
                        <button class="action-btn action-btn-edit" onclick='openIncomeModal(${JSON.stringify(income)})'>Edit</button>
                        <button class="action-btn action-btn-delete" onclick="deleteIncome('${income.id}')">Delete</button>
                    </div>
                </td>
            </tr>
        `).join('');
    } catch (error) {
        console.error('Error loading income:', error);
        document.getElementById('income-table-body').innerHTML = 
            '<tr><td colspan="6" class="empty-state">Error loading income records. Please check Firebase configuration.</td></tr>';
    }
}

async function saveIncome() {
    try {
        const income = {
            date: document.getElementById('income-date').value,
            source: document.getElementById('income-source').value,
            description: document.getElementById('income-description').value,
            amount: parseFloat(document.getElementById('income-amount').value) || 0,
            paymentMethod: document.getElementById('income-payment-method').value,
            customerName: document.getElementById('income-customer-name').value,
            invoiceId: document.getElementById('income-invoice-id').value,
            notes: document.getElementById('income-notes').value
        };
        
        if (currentIncome?.id) {
            await incomeService.update(currentIncome.id, income);
            alert('Income updated successfully!');
        } else {
            await incomeService.create(income);
            alert('Income recorded successfully!');
        }
        
        closeModal('income-modal');
        loadIncomes();
    } catch (error) {
        console.error('Error saving income:', error);
        alert('Error saving income. Please try again.');
    }
}

window.deleteIncome = async function(id) {
    if (!confirm('Are you sure you want to delete this income record?')) return;
    
    try {
        await incomeService.delete(id);
        alert('Income deleted successfully!');
        loadIncomes();
    } catch (error) {
        console.error('Error deleting income:', error);
        alert('Error deleting income. Please try again.');
    }
};

