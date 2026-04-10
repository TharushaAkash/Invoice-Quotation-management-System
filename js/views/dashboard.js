import { invoiceService } from '../services/invoice-service.js';
import { quotationService } from '../services/quotation-service.js';
import { inventoryService } from '../services/inventory-service.js';
import { expenseService } from '../services/expense-service.js';
import { incomeService } from '../services/income-service.js';

window.initDashboard = async function() {
    await loadStatistics();
};

async function loadStatistics() {
    try {
        // Load invoices
        const invoices = await invoiceService.getAll();
        document.getElementById('stat-invoices').textContent = invoices.length;

        // Load quotations
        const quotations = await quotationService.getAll();
        document.getElementById('stat-quotations').textContent = quotations.length;

        // Load inventory
        const inventory = await inventoryService.getAll();
        document.getElementById('stat-inventory').textContent = inventory.length;
        
        const lowStock = inventory.filter(item => {
            const qty = item.quantity || 0;
            const min = item.minStockLevel || 0;
            return qty <= min;
        });
        document.getElementById('stat-low-stock').textContent = lowStock.length;

        // Load monthly income and expenses
        const now = new Date();
        const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
        const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0);

        const totalIncome = await incomeService.getTotal(startOfMonth, endOfMonth);
        document.getElementById('stat-income').textContent = window.formatCurrency(totalIncome);

        const totalExpenses = await expenseService.getTotal(startOfMonth, endOfMonth);
        document.getElementById('stat-expenses').textContent = window.formatCurrency(totalExpenses);
    } catch (error) {
        console.error('Error loading dashboard statistics:', error);
    }
}

// Refresh dashboard when it becomes active
document.addEventListener('DOMContentLoaded', () => {
    const dashboardNav = document.querySelector('[data-view="dashboard"]');
    if (dashboardNav) {
        dashboardNav.addEventListener('click', () => {
            setTimeout(loadStatistics, 100);
        });
    }
});




