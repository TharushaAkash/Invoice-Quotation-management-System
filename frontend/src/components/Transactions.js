import React, { useState, useEffect } from 'react';
import api from '../config/api';
import { toast } from 'react-toastify';
import { format } from 'date-fns';
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';

function Transactions() {
  const [transactions, setTransactions] = useState([]);
  const [report, setReport] = useState(null);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [formData, setFormData] = useState({
    type: 'EXPENSE',
    category: '',
    amount: '',
    description: '',
    transactionDate: format(new Date(), 'yyyy-MM-dd'),
  });

  useEffect(() => {
    fetchData();
  }, []);

  async function fetchData() {
    try {
      const [transactionsRes, reportRes] = await Promise.all([
        api.get('/transactions'),
        api.get('/transactions/reports'),
      ]);
      setTransactions(transactionsRes.data);
      setReport(reportRes.data);
    } catch (error) {
      toast.error('Failed to fetch transactions');
    } finally {
      setLoading(false);
    }
  }

  function handleOpenModal() {
    setFormData({
      type: 'EXPENSE',
      category: '',
      amount: '',
      description: '',
      transactionDate: format(new Date(), 'yyyy-MM-dd'),
    });
    setShowModal(true);
  }

  function handleCloseModal() {
    setShowModal(false);
    setFormData({
      type: 'EXPENSE',
      category: '',
      amount: '',
      description: '',
      transactionDate: format(new Date(), 'yyyy-MM-dd'),
    });
  }

  async function handleSubmit(e) {
    e.preventDefault();
    try {
      await api.post('/transactions', {
        ...formData,
        amount: parseFloat(formData.amount),
        transactionDate: new Date(formData.transactionDate).toISOString(),
      });
      toast.success('Transaction created successfully');
      handleCloseModal();
      fetchData();
    } catch (error) {
      toast.error('Failed to create transaction');
    }
  }

  const chartData = transactions
    .filter(t => t.transactionDate)
    .sort((a, b) => new Date(a.transactionDate) - new Date(b.transactionDate))
    .slice(-10)
    .map(t => ({
      date: format(new Date(t.transactionDate), 'MMM dd'),
      income: t.type === 'INCOME' ? t.amount : 0,
      expense: t.type === 'EXPENSE' ? t.amount : 0,
    }));

  if (loading) {
    return <div className="loading">Loading transactions...</div>;
  }

  return (
    <div className="container">
      {report && (
        <div className="stats-grid" style={{ marginBottom: '2rem' }}>
          <div className="stat-card">
            <div className="stat-label">Total Income</div>
            <div className="stat-value" style={{ color: '#28a745' }}>
              ${(report.totalIncome || 0).toFixed(2)}
            </div>
          </div>
          <div className="stat-card">
            <div className="stat-label">Total Expense</div>
            <div className="stat-value" style={{ color: '#dc3545' }}>
              ${(report.totalExpense || 0).toFixed(2)}
            </div>
          </div>
          <div className="stat-card">
            <div className="stat-label">Profit</div>
            <div
              className="stat-value"
              style={{ color: report.profit >= 0 ? '#28a745' : '#dc3545' }}
            >
              ${(report.profit || 0).toFixed(2)}
            </div>
          </div>
        </div>
      )}

      <div className="card">
        <h2 className="card-title">Money Flow Chart</h2>
        <ResponsiveContainer width="100%" height={300}>
          <LineChart data={chartData}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="date" />
            <YAxis />
            <Tooltip formatter={(value) => `$${value.toFixed(2)}`} />
            <Legend />
            <Line type="monotone" dataKey="income" stroke="#28a745" name="Income" />
            <Line type="monotone" dataKey="expense" stroke="#dc3545" name="Expense" />
          </LineChart>
        </ResponsiveContainer>
      </div>

      <div className="card">
        <div className="card-header">
          <h1 className="card-title">Transactions</h1>
          <button className="btn btn-primary" onClick={handleOpenModal}>
            Add Transaction
          </button>
        </div>

        {transactions.length === 0 ? (
          <div className="empty-state">
            <div className="empty-state-icon">💰</div>
            <p>No transactions found. Add your first transaction!</p>
          </div>
        ) : (
          <table className="table">
            <thead>
              <tr>
                <th>Date</th>
                <th>Type</th>
                <th>Category</th>
                <th>Description</th>
                <th>Amount</th>
              </tr>
            </thead>
            <tbody>
              {transactions.map((transaction) => (
                <tr key={transaction.id}>
                  <td>
                    {transaction.transactionDate
                      ? format(new Date(transaction.transactionDate), 'MMM dd, yyyy')
                      : '-'}
                  </td>
                  <td>
                    <span
                      className={`badge ${
                        transaction.type === 'INCOME' ? 'badge-success' : 'badge-danger'
                      }`}
                    >
                      {transaction.type}
                    </span>
                  </td>
                  <td>{transaction.category}</td>
                  <td>{transaction.description}</td>
                  <td
                    style={{
                      color: transaction.type === 'INCOME' ? '#28a745' : '#dc3545',
                      fontWeight: 'bold',
                    }}
                  >
                    {transaction.type === 'INCOME' ? '+' : '-'}$
                    {transaction.amount?.toFixed(2)}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {showModal && (
        <div className="modal-overlay" onClick={handleCloseModal}>
          <div className="modal" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2 className="modal-title">Add Transaction</h2>
              <button className="modal-close" onClick={handleCloseModal}>
                ×
              </button>
            </div>
            <form onSubmit={handleSubmit}>
              <div className="form-group">
                <label className="form-label">Type</label>
                <select
                  className="form-select"
                  value={formData.type}
                  onChange={(e) => setFormData({ ...formData, type: e.target.value })}
                  required
                >
                  <option value="INCOME">Income</option>
                  <option value="EXPENSE">Expense</option>
                </select>
              </div>
              <div className="form-group">
                <label className="form-label">Category</label>
                <input
                  type="text"
                  className="form-input"
                  value={formData.category}
                  onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                  placeholder="e.g., Salary, Rent, Utilities"
                  required
                />
              </div>
              <div className="form-group">
                <label className="form-label">Amount</label>
                <input
                  type="number"
                  step="0.01"
                  className="form-input"
                  value={formData.amount}
                  onChange={(e) => setFormData({ ...formData, amount: e.target.value })}
                  required
                />
              </div>
              <div className="form-group">
                <label className="form-label">Description</label>
                <textarea
                  className="form-textarea"
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  required
                />
              </div>
              <div className="form-group">
                <label className="form-label">Date</label>
                <input
                  type="date"
                  className="form-input"
                  value={formData.transactionDate}
                  onChange={(e) => setFormData({ ...formData, transactionDate: e.target.value })}
                  required
                />
              </div>
              <div style={{ display: 'flex', gap: '1rem', justifyContent: 'flex-end' }}>
                <button type="button" className="btn btn-secondary" onClick={handleCloseModal}>
                  Cancel
                </button>
                <button type="submit" className="btn btn-primary">
                  Create
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}

export default Transactions;


