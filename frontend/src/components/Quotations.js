import React, { useState, useEffect } from 'react';
import api from '../config/api';
import { toast } from 'react-toastify';
import { format } from 'date-fns';

function Quotations() {
  const [quotations, setQuotations] = useState([]);
  const [customers, setCustomers] = useState([]);
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editingQuotation, setEditingQuotation] = useState(null);
  const [formData, setFormData] = useState({
    customerId: '',
    items: [],
    tax: 0,
    status: 'DRAFT',
    validUntil: '',
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
      const [quotationsRes, customersRes, itemsRes] = await Promise.all([
        api.get('/quotations'),
        api.get('/customers'),
        api.get('/items'),
      ]);
      setQuotations(quotationsRes.data);
      setCustomers(customersRes.data);
      setItems(itemsRes.data);
    } catch (error) {
      toast.error('Failed to fetch data');
    } finally {
      setLoading(false);
    }
  }

  function handleOpenModal(quotation = null) {
    if (quotation) {
      setEditingQuotation(quotation);
      setFormData({
        customerId: quotation.customerId,
        items: quotation.items || [],
        tax: quotation.tax || 0,
        status: quotation.status,
        validUntil: quotation.validUntil
          ? format(new Date(quotation.validUntil), 'yyyy-MM-dd')
          : '',
        notes: quotation.notes || '',
      });
    } else {
      setEditingQuotation(null);
      setFormData({
        customerId: '',
        items: [],
        tax: 0,
        status: 'DRAFT',
        validUntil: '',
        notes: '',
      });
    }
    setShowModal(true);
  }

  function handleCloseModal() {
    setShowModal(false);
    setEditingQuotation(null);
    setFormData({
      customerId: '',
      items: [],
      tax: 0,
      status: 'DRAFT',
      validUntil: '',
      notes: '',
    });
    setCurrentItem({ itemId: '', quantity: 1 });
  }

  function addItemToQuotation() {
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

  function removeItemFromQuotation(index) {
    setFormData({
      ...formData,
      items: formData.items.filter((_, i) => i !== index),
    });
  }

  async function handleSubmit(e) {
    e.preventDefault();
    try {
      const payload = {
        ...formData,
        validUntil: formData.validUntil ? new Date(formData.validUntil).toISOString() : null,
      };
      
      if (editingQuotation) {
        await api.put(`/quotations/${editingQuotation.id}`, payload);
        toast.success('Quotation updated successfully');
      } else {
        await api.post('/quotations', payload);
        toast.success('Quotation created successfully');
      }
      handleCloseModal();
      fetchData();
    } catch (error) {
      toast.error('Failed to save quotation');
    }
  }

  async function handleDelete(id) {
    if (window.confirm('Are you sure you want to delete this quotation?')) {
      try {
        await api.delete(`/quotations/${id}`);
        toast.success('Quotation deleted successfully');
        fetchData();
      } catch (error) {
        toast.error('Failed to delete quotation');
      }
    }
  }

  function getStatusBadge(status) {
    const badges = {
      DRAFT: 'badge-info',
      SENT: 'badge-warning',
      ACCEPTED: 'badge-success',
      REJECTED: 'badge-danger',
      EXPIRED: 'badge-danger',
    };
    return badges[status] || 'badge-info';
  }

  const subtotal = formData.items.reduce((sum, item) => sum + item.total, 0);
  const total = subtotal + (formData.tax || 0);

  if (loading) {
    return <div className="loading">Loading quotations...</div>;
  }

  return (
    <div className="container">
      <div className="card">
        <div className="card-header">
          <h1 className="card-title">Quotations</h1>
          <button className="btn btn-primary" onClick={() => handleOpenModal()}>
            Create Quotation
          </button>
        </div>

        {quotations.length === 0 ? (
          <div className="empty-state">
            <div className="empty-state-icon">📋</div>
            <p>No quotations found. Create your first quotation!</p>
          </div>
        ) : (
          <table className="table">
            <thead>
              <tr>
                <th>Quotation #</th>
                <th>Customer</th>
                <th>Date</th>
                <th>Valid Until</th>
                <th>Total</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {quotations.map((quotation) => (
                <tr key={quotation.id}>
                  <td>{quotation.quotationNumber}</td>
                  <td>{quotation.customerName}</td>
                  <td>
                    {quotation.quotationDate
                      ? format(new Date(quotation.quotationDate), 'MMM dd, yyyy')
                      : '-'}
                  </td>
                  <td>
                    {quotation.validUntil
                      ? format(new Date(quotation.validUntil), 'MMM dd, yyyy')
                      : '-'}
                  </td>
                  <td>${quotation.total?.toFixed(2)}</td>
                  <td>
                    <span className={`badge ${getStatusBadge(quotation.status)}`}>
                      {quotation.status}
                    </span>
                  </td>
                  <td>
                    <button
                      className="btn btn-secondary"
                      style={{ marginRight: '0.5rem' }}
                      onClick={() => handleOpenModal(quotation)}
                    >
                      Edit
                    </button>
                    <button
                      className="btn btn-danger"
                      onClick={() => handleDelete(quotation.id)}
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
                {editingQuotation ? 'Edit Quotation' : 'Create Quotation'}
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
                    onClick={addItemToQuotation}
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
                              onClick={() => removeItemFromQuotation(index)}
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
                <label className="form-label">Valid Until</label>
                <input
                  type="date"
                  className="form-input"
                  value={formData.validUntil}
                  onChange={(e) => setFormData({ ...formData, validUntil: e.target.value })}
                />
              </div>

              <div className="form-group">
                <label className="form-label">Status</label>
                <select
                  className="form-select"
                  value={formData.status}
                  onChange={(e) => setFormData({ ...formData, status: e.target.value })}
                >
                  <option value="DRAFT">Draft</option>
                  <option value="SENT">Sent</option>
                  <option value="ACCEPTED">Accepted</option>
                  <option value="REJECTED">Rejected</option>
                  <option value="EXPIRED">Expired</option>
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
                  {editingQuotation ? 'Update' : 'Create'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}

export default Quotations;


