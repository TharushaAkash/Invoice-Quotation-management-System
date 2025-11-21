import React, { useState, useEffect } from 'react';
import api from '../config/api';
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';

function Dashboard() {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchStats();
  }, []);

  async function fetchStats() {
    try {
      const response = await api.get('/dashboard/stats');
      setStats(response.data);
    } catch (error) {
      console.error('Error fetching stats:', error);
    } finally {
      setLoading(false);
    }
  }

  if (loading) {
    return <div className="loading">Loading dashboard...</div>;
  }

  if (!stats) {
    return <div className="loading">Failed to load dashboard</div>;
  }

  const chartData = [
    { name: 'Income', value: stats.monthlyIncome || 0 },
    { name: 'Expense', value: stats.monthlyExpense || 0 },
    { name: 'Profit', value: stats.monthlyProfit || 0 },
  ];

  return (
    <div className="container">
      <h1 style={{ marginBottom: '2rem' }}>Dashboard</h1>
      
      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-label">Total Customers</div>
          <div className="stat-value">{stats.totalCustomers || 0}</div>
        </div>
        <div className="stat-card">
          <div className="stat-label">Total Items</div>
          <div className="stat-value">{stats.totalItems || 0}</div>
        </div>
        <div className="stat-card">
          <div className="stat-label">Total Invoices</div>
          <div className="stat-value">{stats.totalInvoices || 0}</div>
        </div>
        <div className="stat-card">
          <div className="stat-label">Total Quotations</div>
          <div className="stat-value">{stats.totalQuotations || 0}</div>
        </div>
        <div className="stat-card">
          <div className="stat-label">Monthly Income</div>
          <div className="stat-value" style={{ color: '#28a745' }}>
            ${(stats.monthlyIncome || 0).toFixed(2)}
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-label">Monthly Expense</div>
          <div className="stat-value" style={{ color: '#dc3545' }}>
            ${(stats.monthlyExpense || 0).toFixed(2)}
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-label">Monthly Profit</div>
          <div className="stat-value" style={{ color: stats.monthlyProfit >= 0 ? '#28a745' : '#dc3545' }}>
            ${(stats.monthlyProfit || 0).toFixed(2)}
          </div>
        </div>
      </div>

      <div className="card">
        <h2 className="card-title">Monthly Financial Overview</h2>
        <ResponsiveContainer width="100%" height={300}>
          <BarChart data={chartData}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="name" />
            <YAxis />
            <Tooltip formatter={(value) => `$${value.toFixed(2)}`} />
            <Legend />
            <Bar dataKey="value" fill="#667eea" />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}

export default Dashboard;


