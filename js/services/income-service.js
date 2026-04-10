import { database } from '../firebase-config.js';
import { ref, push, set, get, remove } from 'firebase/database';

export class IncomeService {
    constructor() {
        this.path = 'income';
    }

    async create(income) {
        const incomeRef = ref(database, this.path);
        const newRef = push(incomeRef);
        await set(newRef, income);
        return newRef.key;
    }

    async update(id, income) {
        const incomeRef = ref(database, `${this.path}/${id}`);
        await set(incomeRef, income);
    }

    async delete(id) {
        const incomeRef = ref(database, `${this.path}/${id}`);
        await remove(incomeRef);
    }

    async get(id) {
        const incomeRef = ref(database, `${this.path}/${id}`);
        const snapshot = await get(incomeRef);
        if (snapshot.exists()) {
            return { id: snapshot.key, ...snapshot.val() };
        }
        return null;
    }

    async getAll() {
        const incomeRef = ref(database, this.path);
        const snapshot = await get(incomeRef);
        const incomes = [];
        if (snapshot.exists()) {
            snapshot.forEach(child => {
                incomes.push({ id: child.key, ...child.val() });
            });
        }
        return incomes;
    }

    async getByDateRange(startDate, endDate) {
        const incomes = await this.getAll();
        return incomes.filter(income => {
            const incomeDate = new Date(income.date);
            return incomeDate >= startDate && incomeDate <= endDate;
        });
    }

    async getTotal(startDate, endDate) {
        const incomes = await this.getByDateRange(startDate, endDate);
        return incomes.reduce((sum, income) => sum + (income.amount || 0), 0);
    }
}

export const incomeService = new IncomeService();




