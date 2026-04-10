import { database } from '../firebase-config.js';
import { ref, push, set, get, remove, query, orderByChild, limitToLast } from 'firebase/database';

export class QuotationService {
    constructor() {
        this.path = 'quotations';
    }

    async create(quotation) {
        const quotationRef = ref(database, this.path);
        const newRef = push(quotationRef);
        await set(newRef, quotation);
        return newRef.key;
    }

    async update(id, quotation) {
        const quotationRef = ref(database, `${this.path}/${id}`);
        await set(quotationRef, quotation);
    }

    async delete(id) {
        const quotationRef = ref(database, `${this.path}/${id}`);
        await remove(quotationRef);
    }

    async get(id) {
        const quotationRef = ref(database, `${this.path}/${id}`);
        const snapshot = await get(quotationRef);
        if (snapshot.exists()) {
            return { id: snapshot.key, ...snapshot.val() };
        }
        return null;
    }

    async getAll() {
        const quotationsRef = ref(database, this.path);
        const snapshot = await get(quotationsRef);
        const quotations = [];
        if (snapshot.exists()) {
            snapshot.forEach(child => {
                quotations.push({ id: child.key, ...child.val() });
            });
        }
        return quotations;
    }

    async generateQuotationNumber() {
        const quotationsRef = ref(database, this.path);
        const q = query(quotationsRef, orderByChild('quotationNumber'), limitToLast(1));
        const snapshot = await get(q);
        
        let nextNumber = 1;
        if (snapshot.exists()) {
            snapshot.forEach(child => {
                const quotation = child.val();
                if (quotation.quotationNumber) {
                    const match = quotation.quotationNumber.match(/\d+/);
                    if (match) {
                        nextNumber = parseInt(match[0]) + 1;
                    }
                }
            });
        }
        
        return `QUO-${String(nextNumber).padStart(4, '0')}`;
    }
}

export const quotationService = new QuotationService();




