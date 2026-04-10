import { invoiceService } from '../services/invoice-service.js';

let currentInvoice = null;

window.openInvoiceModal = function(invoice = null) {
    currentInvoice = invoice;
    const modal = createInvoiceModal(invoice);
    document.getElementById('modal-container').innerHTML = modal;
    document.getElementById('invoice-modal').classList.add('active');
    
    if (!invoice) {
        invoiceService.generateInvoiceNumber().then(num => {
            document.getElementById('invoice-number').value = num;
        });
    }
};

function createInvoiceModal(invoice) {
    return `
        <div id="invoice-modal" class="modal active">
            <div class="modal-content">
                <div class="modal-header">
                    <h3>${invoice ? 'Edit Invoice' : 'New Invoice'}</h3>
                    <button class="modal-close" onclick="closeModal('invoice-modal')">&times;</button>
                </div>
                <form id="invoice-form">
                    <div class="form-group">
                        <label>Invoice Number</label>
                        <input type="text" id="invoice-number" value="${invoice?.invoiceNumber || ''}" required>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>Date</label>
                            <input type="date" id="invoice-date" value="${invoice?.date || new Date().toISOString().split('T')[0]}" required>
                        </div>
                        <div class="form-group">
                            <label>Due Date</label>
                            <input type="date" id="invoice-due-date" value="${invoice?.dueDate || ''}">
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Customer Name</label>
                        <input type="text" id="invoice-customer-name" value="${invoice?.customerName || ''}" required>
                    </div>
                    <div class="form-group">
                        <label>Customer Address</label>
                        <textarea id="invoice-customer-address">${invoice?.customerAddress || ''}</textarea>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>Customer Phone</label>
                            <input type="text" id="invoice-customer-phone" value="${invoice?.customerPhone || ''}">
                        </div>
                        <div class="form-group">
                            <label>Tax Rate (%)</label>
                            <input type="number" id="invoice-tax-rate" value="${invoice?.taxRate || 0}" step="0.01">
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Status</label>
                        <select id="invoice-status">
                            <option value="DRAFT" ${invoice?.status === 'DRAFT' ? 'selected' : ''}>Draft</option>
                            <option value="SENT" ${invoice?.status === 'SENT' ? 'selected' : ''}>Sent</option>
                            <option value="PAID" ${invoice?.status === 'PAID' ? 'selected' : ''}>Paid</option>
                            <option value="OVERDUE" ${invoice?.status === 'OVERDUE' ? 'selected' : ''}>Overdue</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Notes</label>
                        <textarea id="invoice-notes">${invoice?.notes || ''}</textarea>
                    </div>
                    <div class="modal-actions">
                        <button type="button" class="btn btn-secondary" onclick="closeModal('invoice-modal')">Cancel</button>
                        <button type="submit" class="btn btn-primary">Save</button>
                    </div>
                </form>
            </div>
        </div>
    `;
}

document.addEventListener('DOMContentLoaded', () => {
    loadInvoices();
    
    // Handle form submission
    document.addEventListener('submit', async (e) => {
        if (e.target.id === 'invoice-form') {
            e.preventDefault();
            await saveInvoice();
        }
    });
});

async function loadInvoices() {
    try {
        const invoices = await invoiceService.getAll();
        const tbody = document.getElementById('invoices-table-body');
        
        if (invoices.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" class="empty-state">No invoices found. Create your first invoice!</td></tr>';
            return;
        }
        
        tbody.innerHTML = invoices.map(invoice => `
            <tr>
                <td>${invoice.invoiceNumber || 'N/A'}</td>
                <td>${window.formatDate(invoice.date)}</td>
                <td>${invoice.customerName || 'N/A'}</td>
                <td>${window.formatCurrency(invoice.total || 0)}</td>
                <td><span class="status-badge status-${invoice.status?.toLowerCase() || 'draft'}">${invoice.status || 'DRAFT'}</span></td>
                <td>
                    <div class="action-buttons">
                        <button class="action-btn action-btn-edit" onclick='openInvoiceModal(${JSON.stringify(invoice)})'>Edit</button>
                        <button class="action-btn action-btn-delete" onclick="deleteInvoice('${invoice.id}')">Delete</button>
                    </div>
                </td>
            </tr>
        `).join('');
    } catch (error) {
        console.error('Error loading invoices:', error);
        document.getElementById('invoices-table-body').innerHTML = 
            '<tr><td colspan="6" class="empty-state">Error loading invoices. Please check Firebase configuration.</td></tr>';
    }
}

async function saveInvoice() {
    try {
        const invoice = {
            invoiceNumber: document.getElementById('invoice-number').value,
            date: document.getElementById('invoice-date').value,
            dueDate: document.getElementById('invoice-due-date').value || null,
            customerName: document.getElementById('invoice-customer-name').value,
            customerAddress: document.getElementById('invoice-customer-address').value,
            customerPhone: document.getElementById('invoice-customer-phone').value,
            taxRate: parseFloat(document.getElementById('invoice-tax-rate').value) || 0,
            status: document.getElementById('invoice-status').value,
            notes: document.getElementById('invoice-notes').value,
            items: currentInvoice?.items || [],
            subtotal: currentInvoice?.subtotal || 0,
            taxAmount: currentInvoice?.taxAmount || 0,
            total: currentInvoice?.total || 0
        };
        
        if (currentInvoice?.id) {
            await invoiceService.update(currentInvoice.id, invoice);
            alert('Invoice updated successfully!');
        } else {
            await invoiceService.create(invoice);
            alert('Invoice created successfully!');
        }
        
        closeModal('invoice-modal');
        loadInvoices();
    } catch (error) {
        console.error('Error saving invoice:', error);
        alert('Error saving invoice. Please try again.');
    }
}

window.deleteInvoice = async function(id) {
    if (!confirm('Are you sure you want to delete this invoice?')) return;
    
    try {
        await invoiceService.delete(id);
        alert('Invoice deleted successfully!');
        loadInvoices();
    } catch (error) {
        console.error('Error deleting invoice:', error);
        alert('Error deleting invoice. Please try again.');
    }
};

