import { database } from '../firebase-config.js';
import { ref, push, set, get, remove } from 'firebase/database';

export class InventoryService {
    constructor() {
        this.path = 'inventory';
    }

    async create(item) {
        const itemRef = ref(database, this.path);
        const newRef = push(itemRef);
        await set(newRef, item);
        return newRef.key;
    }

    async update(id, item) {
        const itemRef = ref(database, `${this.path}/${id}`);
        await set(itemRef, item);
    }

    async delete(id) {
        const itemRef = ref(database, `${this.path}/${id}`);
        await remove(itemRef);
    }

    async get(id) {
        const itemRef = ref(database, `${this.path}/${id}`);
        const snapshot = await get(itemRef);
        if (snapshot.exists()) {
            return { id: snapshot.key, ...snapshot.val() };
        }
        return null;
    }

    async getAll() {
        const itemsRef = ref(database, this.path);
        const snapshot = await get(itemsRef);
        const items = [];
        if (snapshot.exists()) {
            snapshot.forEach(child => {
                items.push({ id: child.key, ...child.val() });
            });
        }
        return items;
    }

    async getLowStockItems() {
        const items = await this.getAll();
        return items.filter(item => {
            const quantity = item.quantity || 0;
            const minStock = item.minStockLevel || 0;
            return quantity <= minStock;
        });
    }
}

export const inventoryService = new InventoryService();




