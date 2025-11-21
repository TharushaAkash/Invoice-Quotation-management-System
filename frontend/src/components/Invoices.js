import React, { useState, useEffect } from 'react';
import api from '../config/api';
import { toast } from 'react-toastify';
import { format } from 'date-fns';

function Invoices() {
  const [invoices, setInvoices] = useState([]);
  const [customers, setCustomers] = useState([]);
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editingInvoice, setEditingInvoice] = useState(null);
  const [formData, setFormData] = useState({
    customerId: '',
    items: [],
    tax: 0,
    status: 'DRAFT',
    notes: '',
  });
  const [currentItem, setCurrentItem] = useState({
    itemId: '',
    quantity: 1,
  });

  useEffect(() => {
    fetchData();
  }, []);

  async function fetchData() {
    try {
      const [invoicesRes, customersRes, itemsRes] = await Promise.all([
        api.get('/invoices'),
        api.get('/customers'),
        api.get('/items'),
      ]);
      setInvoices(invoicesRes.data);
      setCustomers(customersRes.data);
      setItems(itemsRes.data);
    } catch (error) {
      toast.error('Failed to fetch data');
    } finally {
      setLoading(false);
    }
  }

  function handleOpenModal(invoice = null) {
    if (invoice) {
      setEditingInvoice(invoice);
      setFormData({
        customerId: invoice.customerId,
        items: invoice.items || [],
        tax: invoice.tax || 0,
        status: invoice.status,
        notes: invoice.notes || '',
      });
    } else {
      setEditingInvoice(null);
      setFormData({
        customerId: '',
        items: [],
        tax: 0,
        status: 'DRAFT',
        notes: '',
      });
    }
    setShowModal(true);
  }

  function handleCloseModal() {
    setShowModal(false);
    setEditingInvoice(null);
    setFormData({
      customerId: '',
      items: [],
      tax: 0,
      status: 'DRAFT',
      notes: '',
    });
    setCurrentItem({ itemId: '', quantity: 1 });
  }

  function addItemToInvoice() {
    const item = items.find(i => i.id === currentItem.itemId);
    if (item && currentItem.quantity > 0) {
      const newItem = {
        itemId: item.id,
        itemName: item.name,
        quantity: parseInt(currentItem.quantity),
        unitPrice: item.unitPrice,
        total: item.unitPrice * parseInt(currentItem.quantity),
      };
      setFormData({
        ...formData,
        items: [...formData.items, newItem],
      });
      setCurrentItem({ itemId: '', quantity: 1 });
    }
  }

  function removeItemFromInvoice(index) {
    setFormData({
      ...formData,
      items: formData.items.filter((_, i) => i !== index),
    });
  }

  async function handleSubmit(e) {
    e.preventDefault();
    try {
      if (editingInvoice) {
        await api.put(`/invoices/${editingInvoice.id}`, formData);
        toast.success('Invoice updated successfully');
      } else {
        await api.post('/invoices', formData);
        toast.success('Invoice created successfully');
      }
      handleCloseModal();
      fetchData();
    } catch (error) {
      toast.error('Failed to save invoice');
    }
  }

  async function handleDelete(id) {
    if (window.confirm('Are you sure you want to delete this invoice?')) {
      try {
        await api.delete(`/invoices/${id}`);
        toast.success('Invoice deleted successfully');
        fetchData();
      } catch (error) {
        toast.error('Failed to delete invoice');
      }
    }
  }

  async function handleMarkPaid(id) {
    try {
      await api.post(`/invoices/${id}/mark-paid`);
      toast.success('Invoice marked as paid');
      fetchData();
    } catch (error) {
      toast.error('Failed to mark invoice as paid');
    }
  }

  function getStatusBadge(status) {
    const badges = {
      DRAFT: 'badge-info',
      SENT: 'badge-warning',
      PAID: 'badge-success',
      OVERDUE: 'badge-danger',
    };
    return badges[status] || 'badge-info';
  }

  const subtotal = formData.items.reduce((sum, item) => sum + item.total, 0);
  const total = subtotal + (formData.tax || 0);

  if (loading) {
    return <div className="loading">Loading invoices...</div>;
  }

  return (
    <div className="container">
      <div className="card">
        <div className="card-header">
          <h1 className="card-title">Invoices</h1>
          <button className="btn btn-primary" onClick={() => handleOpenModal()}>
            Create Invoice
          </button>
        </div>

        {invoices.length === 0 ? (
          <div className="empty-state">
            <div className="empty-state-icon">📄</div>
            <p>No invoices found. Create your first invoice!</p>
          </div>
        ) : (
          <table className="table">
            <thead>
              <tr>
                <th>Invoice #</th>
                <th>Customer</th>
                <th>Date</th>
                <th>Total</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {invoices.map((invoice) => (
                <tr key={invoice.id}>
                  <td>{invoice.invoiceNumber}</td>
                  <td>{invoice.customerName}</td>
                  <td>
                    {invoice.invoiceDate
                      ? format(new Date(invoice.invoiceDate), 'MMM dd, yyyy')
                      : '-'}
                  </td>
                  <td>${invoice.total?.toFixed(2)}</td>
                  <td>
                    <span className={`badge ${getStatusBadge(invoice.status)}`}>
                      {invoice.status}
                    </span>
                  </td>
                  <td>
                    <button
                      className="btn btn-secondary"
                      style={{ marginRight: '0.5rem' }}
                      onClick={() => handleOpenModal(invoice)}
                    >
                      Edit
                    </button>
                    {invoice.status !== 'PAID' && (
                      <button
                        className="btn btn-success"
                        style={{ marginRight: '0.5rem' }}
                        onClick={() => handleMarkPaid(invoice.id)}
                      >
                        Mark Paid
                      </button>
                    )}
                    <button
                      className="btn btn-danger"
                      onClick={() => handleDelete(invoice.id)}
                    >
                      Delete
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {showModal && (
        <div className="modal-overlay" onClick={handleCloseModal}>
          <div className="modal" style={{ maxWidth: '800px' }} onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2 className="modal-title">
                {editingInvoice ? 'Edit Invoice' : 'Create Invoice'}
              </h2>
              <button className="modal-close" onClick={handleCloseModal}>
                ×
              </button>
            </div>
            <form onSubmit={handleSubmit}>
              <div className="form-group">
                <label className="form-label">Customer</label>
                <select
                  className="form-select"
                  value={formData.customerId}
                  onChange={(e) => setFormData({ ...formData, customerId: e.target.value })}
                  required
                >
                  <option value="">Select a customer</option>
                  {customers.map((customer) => (
                    <option key={customer.id} value={customer.id}>
                      {customer.name}
                    </option>
                  ))}
                </select>
              </div>

              <div className="form-group">
                <label className="form-label">Add Item</label>
                <div style={{ display: 'flex', gap: '1rem' }}>
                  <select
                    className="form-select"
                    style={{ flex: 1 }}
                    value={currentItem.itemId}
                    onChange={(e) => setCurrentItem({ ...currentItem, itemId: e.target.value })}
                  >
                    <option value="">Select an item</option>
                    {items.map((item) => (
                      <option key={item.id} value={item.id}>
                        {item.name} - ${item.unitPrice?.toFixed(2)}
                      </option>
                    ))}
                  </select>
                  <input
                    type="number"
                    className="form-input"
                    style={{ width: '100px' }}
                    value={currentItem.quantity}
                    onChange={(e) =>
                      setCurrentItem({ ...currentItem, quantity: e.target.value })
                    }
                    min="1"
                    placeholder="Qty"
                  />
                  <button
                    type="button"
                    className="btn btn-primary"
                    onClick={addItemToInvoice}
                  >
                    Add
                  </button>
                </div>
              </div>

              {formData.items.length > 0 && (
                <div className="form-group">
                  <table className="table">
                    <thead>
                      <tr>
                        <th>Item</th>
                        <th>Quantity</th>
                        <th>Unit Price</th>
                        <th>Total</th>
                        <th>Action</th>
                      </tr>
                    </thead>
                    <tbody>
                      {formData.items.map((item, index) => (
                        <tr key={index}>
                          <td>{item.itemName}</td>
                          <td>{item.quantity}</td>
                          <td>${item.unitPrice?.toFixed(2)}</td>
                          <td>${item.total?.toFixed(2)}</td>
                          <td>
                            <button
                              type="button"
                              className="btn btn-danger"
                              onClick={() => removeItemFromInvoice(index)}
                            >
                              Remove
                            </button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                  <div style={{ marginTop: '1rem', textAlign: 'right' }}>
                    <p>Subtotal: ${subtotal.toFixed(2)}</p>
                    <div className="form-group" style={{ marginTop: '0.5rem' }}>
                      <label className="form-label">Tax</label>
                      <input
                        type="number"
                        step="0.01"
                        className="form-input"
                        value={formData.tax}
                        onChange={(e) =>
                          setFormData({ ...formData, tax: parseFloat(e.target.value) || 0 })
                        }
                      />
                    </div>
                    <p style={{ fontSize: '1.25rem', fontWeight: 'bold', marginTop: '0.5rem' }}>
                      Total: ${total.toFixed(2)}
                    </p>
                  </div>
                </div>
              )}

              <div className="form-group">
                <label className="form-label">Status</label>
                <select
                  className="form-select"
                  value={formData.status}
                  onChange={(e) => setFormData({ ...formData, status: e.target.value })}
                >
                  <option value="DRAFT">Draft</option>
                  <option value="SENT">Sent</option>
                  <option value="PAID">Paid</option>
                  <option value="OVERDUE">Overdue</option>
                </select>
              </div>

              <div className="form-group">
                <label className="form-label">Notes</label>
                <textarea
                  className="form-textarea"
                  value={formData.notes}
                  onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
                />
              </div>

              <div style={{ display: 'flex', gap: '1rem', justifyContent: 'flex-end' }}>
                <button type="button" className="btn btn-secondary" onClick={handleCloseModal}>
                  Cancel
                </button>
                <button type="submit" className="btn btn-primary">
                  {editingInvoice ? 'Update' : 'Create'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}

export default Invoices;


