import { database } from '../firebase-config.js';
import { ref, push, set, get, remove } from 'firebase/database';

export class ExpenseService {
    constructor() {
        this.path = 'expenses';
    }

    async create(expense) {
        const expenseRef = ref(database, this.path);
        const newRef = push(expenseRef);
        await set(newRef, expense);
        return newRef.key;
    }

    async update(id, expense) {
        const expenseRef = ref(database, `${this.path}/${id}`);
        await set(expenseRef, expense);
    }

    async delete(id) {
        const expenseRef = ref(database, `${this.path}/${id}`);
        await remove(expenseRef);
    }

    async get(id) {
        const expenseRef = ref(database, `${this.path}/${id}`);
        const snapshot = await get(expenseRef);
        if (snapshot.exists()) {
            return { id: snapshot.key, ...snapshot.val() };
        }
        return null;
    }

    async getAll() {
        const expensesRef = ref(database, this.path);
        const snapshot = await get(expensesRef);
        const expenses = [];
        if (snapshot.exists()) {
            snapshot.forEach(child => {
                expenses.push({ id: child.key, ...child.val() });
            });
        }
        return expenses;
    }

    async getByDateRange(startDate, endDate) {
        const expenses = await this.getAll();
        return expenses.filter(expense => {
            const expenseDate = new Date(expense.date);
            return expenseDate >= startDate && expenseDate <= endDate;
        });
    }

    async getTotal(startDate, endDate) {
        const expenses = await this.getByDateRange(startDate, endDate);
        return expenses.reduce((sum, expense) => sum + (expense.amount || 0), 0);
    }
}

export const expenseService = new ExpenseService();




