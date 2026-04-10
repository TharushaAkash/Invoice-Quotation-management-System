import { database } from '../firebase-config.js';
import { ref, push, set, get, remove, query, orderByChild, limitToLast } from 'firebase/database';

export class InvoiceService {
    constructor() {
        this.path = 'invoices';
    }

    async create(invoice) {
        const invoiceRef = ref(database, this.path);
        const newRef = push(invoiceRef);
        await set(newRef, invoice);
        return newRef.key;
    }

    async update(id, invoice) {
        const invoiceRef = ref(database, `${this.path}/${id}`);
        await set(invoiceRef, invoice);
    }

    async delete(id) {
        const invoiceRef = ref(database, `${this.path}/${id}`);
        await remove(invoiceRef);
    }

    async get(id) {
        const invoiceRef = ref(database, `${this.path}/${id}`);
        const snapshot = await get(invoiceRef);
        if (snapshot.exists()) {
            return { id: snapshot.key, ...snapshot.val() };
        }
        return null;
    }

    async getAll() {
        const invoicesRef = ref(database, this.path);
        const snapshot = await get(invoicesRef);
        const invoices = [];
        if (snapshot.exists()) {
            snapshot.forEach(child => {
                invoices.push({ id: child.key, ...child.val() });
            });
        }
        return invoices;
    }

    async generateInvoiceNumber() {
        const invoicesRef = ref(database, this.path);
        const q = query(invoicesRef, orderByChild('invoiceNumber'), limitToLast(1));
        const snapshot = await get(q);
        
        let nextNumber = 1;
        if (snapshot.exists()) {
            snapshot.forEach(child => {
                const invoice = child.val();
                if (invoice.invoiceNumber) {
                    const match = invoice.invoiceNumber.match(/\d+/);
                    if (match) {
                        nextNumber = parseInt(match[0]) + 1;
                    }
                }
            });
        }
        
        return `INV-${String(nextNumber).padStart(4, '0')}`;
    }
}

export const invoiceService = new InvoiceService();




