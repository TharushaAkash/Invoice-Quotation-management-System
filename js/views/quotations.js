import { quotationService } from '../services/quotation-service.js';

let currentQuotation = null;

window.openQuotationModal = function(quotation = null) {
    currentQuotation = quotation;
    const modal = createQuotationModal(quotation);
    document.getElementById('modal-container').innerHTML = modal;
    document.getElementById('quotation-modal').classList.add('active');
    
    if (!quotation) {
        quotationService.generateQuotationNumber().then(num => {
            document.getElementById('quotation-number').value = num;
        });
    }
};

function createQuotationModal(quotation) {
    const validUntil = quotation?.validUntil || new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
    
    return `
        <div id="quotation-modal" class="modal active">
            <div class="modal-content">
                <div class="modal-header">
                    <h3>${quotation ? 'Edit Quotation' : 'New Quotation'}</h3>
                    <button class="modal-close" onclick="closeModal('quotation-modal')">&times;</button>
                </div>
                <form id="quotation-form">
                    <div class="form-group">
                        <label>Quotation Number</label>
                        <input type="text" id="quotation-number" value="${quotation?.quotationNumber || ''}" required>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>Date</label>
                            <input type="date" id="quotation-date" value="${quotation?.date || new Date().toISOString().split('T')[0]}" required>
                        </div>
                        <div class="form-group">
                            <label>Valid Until</label>
                            <input type="date" id="quotation-valid-until" value="${validUntil}" required>
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Customer Name</label>
                        <input type="text" id="quotation-customer-name" value="${quotation?.customerName || ''}" required>
                    </div>
                    <div class="form-group">
                        <label>Customer Address</label>
                        <textarea id="quotation-customer-address">${quotation?.customerAddress || ''}</textarea>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>Customer Phone</label>
                            <input type="text" id="quotation-customer-phone" value="${quotation?.customerPhone || ''}">
                        </div>
                        <div class="form-group">
                            <label>Tax Rate (%)</label>
                            <input type="number" id="quotation-tax-rate" value="${quotation?.taxRate || 0}" step="0.01">
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Status</label>
                        <select id="quotation-status">
                            <option value="DRAFT" ${quotation?.status === 'DRAFT' ? 'selected' : ''}>Draft</option>
                            <option value="SENT" ${quotation?.status === 'SENT' ? 'selected' : ''}>Sent</option>
                            <option value="ACCEPTED" ${quotation?.status === 'ACCEPTED' ? 'selected' : ''}>Accepted</option>
                            <option value="REJECTED" ${quotation?.status === 'REJECTED' ? 'selected' : ''}>Rejected</option>
                            <option value="EXPIRED" ${quotation?.status === 'EXPIRED' ? 'selected' : ''}>Expired</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Notes</label>
                        <textarea id="quotation-notes">${quotation?.notes || ''}</textarea>
                    </div>
                    <div class="modal-actions">
                        <button type="button" class="btn btn-secondary" onclick="closeModal('quotation-modal')">Cancel</button>
                        <button type="submit" class="btn btn-primary">Save</button>
                    </div>
                </form>
            </div>
        </div>
    `;
}

document.addEventListener('DOMContentLoaded', () => {
    loadQuotations();
    
    document.addEventListener('submit', async (e) => {
        if (e.target.id === 'quotation-form') {
            e.preventDefault();
            await saveQuotation();
        }
    });
});

async function loadQuotations() {
    try {
        const quotations = await quotationService.getAll();
        const tbody = document.getElementById('quotations-table-body');
        
        if (quotations.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" class="empty-state">No quotations found. Create your first quotation!</td></tr>';
            return;
        }
        
        tbody.innerHTML = quotations.map(quotation => `
            <tr>
                <td>${quotation.quotationNumber || 'N/A'}</td>
                <td>${window.formatDate(quotation.date)}</td>
                <td>${quotation.customerName || 'N/A'}</td>
                <td>${window.formatCurrency(quotation.total || 0)}</td>
                <td><span class="status-badge status-${quotation.status?.toLowerCase() || 'draft'}">${quotation.status || 'DRAFT'}</span></td>
                <td>
                    <div class="action-buttons">
                        <button class="action-btn action-btn-edit" onclick='openQuotationModal(${JSON.stringify(quotation)})'>Edit</button>
                        <button class="action-btn action-btn-delete" onclick="deleteQuotation('${quotation.id}')">Delete</button>
                    </div>
                </td>
            </tr>
        `).join('');
    } catch (error) {
        console.error('Error loading quotations:', error);
        document.getElementById('quotations-table-body').innerHTML = 
            '<tr><td colspan="6" class="empty-state">Error loading quotations. Please check Firebase configuration.</td></tr>';
    }
}

async function saveQuotation() {
    try {
        const quotation = {
            quotationNumber: document.getElementById('quotation-number').value,
            date: document.getElementById('quotation-date').value,
            validUntil: document.getElementById('quotation-valid-until').value,
            customerName: document.getElementById('quotation-customer-name').value,
            customerAddress: document.getElementById('quotation-customer-address').value,
            customerPhone: document.getElementById('quotation-customer-phone').value,
            taxRate: parseFloat(document.getElementById('quotation-tax-rate').value) || 0,
            status: document.getElementById('quotation-status').value,
            notes: document.getElementById('quotation-notes').value,
            items: currentQuotation?.items || [],
            subtotal: currentQuotation?.subtotal || 0,
            taxAmount: currentQuotation?.taxAmount || 0,
            total: currentQuotation?.total || 0
        };
        
        if (currentQuotation?.id) {
            await quotationService.update(currentQuotation.id, quotation);
            alert('Quotation updated successfully!');
        } else {
            await quotationService.create(quotation);
            alert('Quotation created successfully!');
        }
        
        closeModal('quotation-modal');
        loadQuotations();
    } catch (error) {
        console.error('Error saving quotation:', error);
        alert('Error saving quotation. Please try again.');
    }
}

window.deleteQuotation = async function(id) {
    if (!confirm('Are you sure you want to delete this quotation?')) return;
    
    try {
        await quotationService.delete(id);
        alert('Quotation deleted successfully!');
        loadQuotations();
    } catch (error) {
        console.error('Error deleting quotation:', error);
        alert('Error deleting quotation. Please try again.');
    }
};

