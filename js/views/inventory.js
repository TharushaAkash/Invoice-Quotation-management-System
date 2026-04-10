import { inventoryService } from '../services/inventory-service.js';

let currentItem = null;

window.openInventoryModal = function(item = null) {
    currentItem = item;
    const modal = createInventoryModal(item);
    document.getElementById('modal-container').innerHTML = modal;
    document.getElementById('inventory-modal').classList.add('active');
};

function createInventoryModal(item) {
    return `
        <div id="inventory-modal" class="modal active">
            <div class="modal-content">
                <div class="modal-header">
                    <h3>${item ? 'Edit Item' : 'New Inventory Item'}</h3>
                    <button class="modal-close" onclick="closeModal('inventory-modal')">&times;</button>
                </div>
                <form id="inventory-form">
                    <div class="form-group">
                        <label>Item Code</label>
                        <input type="text" id="item-code" value="${item?.itemCode || ''}" required>
                    </div>
                    <div class="form-group">
                        <label>Name</label>
                        <input type="text" id="item-name" value="${item?.name || ''}" required>
                    </div>
                    <div class="form-group">
                        <label>Description</label>
                        <textarea id="item-description">${item?.description || ''}</textarea>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>Category</label>
                            <input type="text" id="item-category" value="${item?.category || ''}">
                        </div>
                        <div class="form-group">
                            <label>Unit</label>
                            <input type="text" id="item-unit" value="${item?.unit || 'pcs'}" placeholder="pcs, kg, m, etc.">
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>Quantity</label>
                            <input type="number" id="item-quantity" value="${item?.quantity || 0}" min="0" required>
                        </div>
                        <div class="form-group">
                            <label>Min Stock Level</label>
                            <input type="number" id="item-min-stock" value="${item?.minStockLevel || 0}" min="0">
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>Unit Cost</label>
                            <input type="number" id="item-unit-cost" value="${item?.unitCost || 0}" step="0.01" min="0">
                        </div>
                        <div class="form-group">
                            <label>Selling Price</label>
                            <input type="number" id="item-selling-price" value="${item?.sellingPrice || 0}" step="0.01" min="0" required>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>Supplier</label>
                            <input type="text" id="item-supplier" value="${item?.supplier || ''}">
                        </div>
                        <div class="form-group">
                            <label>Location</label>
                            <input type="text" id="item-location" value="${item?.location || ''}">
                        </div>
                    </div>
                    <div class="modal-actions">
                        <button type="button" class="btn btn-secondary" onclick="closeModal('inventory-modal')">Cancel</button>
                        <button type="submit" class="btn btn-primary">Save</button>
                    </div>
                </form>
            </div>
        </div>
    `;
}

document.addEventListener('DOMContentLoaded', () => {
    loadInventory();
    
    document.addEventListener('submit', async (e) => {
        if (e.target.id === 'inventory-form') {
            e.preventDefault();
            await saveItem();
        }
    });
});

async function loadInventory() {
    try {
        const items = await inventoryService.getAll();
        const tbody = document.getElementById('inventory-table-body');
        
        if (items.length === 0) {
            tbody.innerHTML = '<tr><td colspan="7" class="empty-state">No inventory items found. Add your first item!</td></tr>';
            return;
        }
        
        tbody.innerHTML = items.map(item => {
            const isLowStock = (item.quantity || 0) <= (item.minStockLevel || 0);
            return `
                <tr>
                    <td>${item.itemCode || 'N/A'}</td>
                    <td>${item.name || 'N/A'}</td>
                    <td>${item.category || 'N/A'}</td>
                    <td>${item.quantity || 0}</td>
                    <td>${window.formatCurrency(item.sellingPrice || 0)}</td>
                    <td><span class="status-badge ${isLowStock ? 'status-overdue' : 'status-paid'}">${isLowStock ? 'Yes' : 'No'}</span></td>
                    <td>
                        <div class="action-buttons">
                            <button class="action-btn action-btn-edit" onclick='openInventoryModal(${JSON.stringify(item)})'>Edit</button>
                            <button class="action-btn action-btn-delete" onclick="deleteInventoryItem('${item.id}')">Delete</button>
                        </div>
                    </td>
                </tr>
            `;
        }).join('');
    } catch (error) {
        console.error('Error loading inventory:', error);
        document.getElementById('inventory-table-body').innerHTML = 
            '<tr><td colspan="7" class="empty-state">Error loading inventory. Please check Firebase configuration.</td></tr>';
    }
}

async function saveItem() {
    try {
        const item = {
            itemCode: document.getElementById('item-code').value,
            name: document.getElementById('item-name').value,
            description: document.getElementById('item-description').value,
            category: document.getElementById('item-category').value,
            unit: document.getElementById('item-unit').value,
            quantity: parseInt(document.getElementById('item-quantity').value) || 0,
            minStockLevel: parseInt(document.getElementById('item-min-stock').value) || 0,
            unitCost: parseFloat(document.getElementById('item-unit-cost').value) || 0,
            sellingPrice: parseFloat(document.getElementById('item-selling-price').value) || 0,
            supplier: document.getElementById('item-supplier').value,
            location: document.getElementById('item-location').value
        };
        
        if (currentItem?.id) {
            await inventoryService.update(currentItem.id, item);
            alert('Item updated successfully!');
        } else {
            await inventoryService.create(item);
            alert('Item added successfully!');
        }
        
        closeModal('inventory-modal');
        loadInventory();
    } catch (error) {
        console.error('Error saving item:', error);
        alert('Error saving item. Please try again.');
    }
}

window.deleteInventoryItem = async function(id) {
    if (!confirm('Are you sure you want to delete this item?')) return;
    
    try {
        await inventoryService.delete(id);
        alert('Item deleted successfully!');
        loadInventory();
    } catch (error) {
        console.error('Error deleting item:', error);
        alert('Error deleting item. Please try again.');
    }
};

