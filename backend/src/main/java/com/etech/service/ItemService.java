package com.etech.service;

import com.etech.model.Item;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;

@Service
public class ItemService {

    @Autowired
    private Firestore firestore;

    private static final String COLLECTION = "items";

    public Item createItem(Item item) throws ExecutionException, InterruptedException {
        item.setId(null);
        item.setCreatedAt(LocalDateTime.now());
        item.setUpdatedAt(LocalDateTime.now());
        
        var docRef = firestore.collection(COLLECTION).document();
        item.setId(docRef.getId());
        docRef.set(item).get();
        
        return item;
    }

    public Item getItem(String id) throws ExecutionException, InterruptedException {
        var doc = firestore.collection(COLLECTION).document(id).get().get();
        if (doc.exists()) {
            Item item = doc.toObject(Item.class);
            item.setId(doc.getId());
            return item;
        }
        return null;
    }

    public List<Item> getAllItems() throws ExecutionException, InterruptedException {
        List<Item> items = new ArrayList<>();
        var querySnapshot = firestore.collection(COLLECTION).get().get();
        
        for (QueryDocumentSnapshot document : querySnapshot.getDocuments()) {
            Item item = document.toObject(Item.class);
            item.setId(document.getId());
            items.add(item);
        }
        
        return items;
    }

    public Item updateItem(String id, Item item) throws ExecutionException, InterruptedException {
        item.setId(id);
        item.setUpdatedAt(LocalDateTime.now());
        
        firestore.collection(COLLECTION).document(id).set(item).get();
        return item;
    }

    public void deleteItem(String id) throws ExecutionException, InterruptedException {
        firestore.collection(COLLECTION).document(id).delete().get();
    }

    public Item updateStock(String id, Integer quantityChange) throws ExecutionException, InterruptedException {
        Item item = getItem(id);
        if (item != null) {
            item.setStockQuantity(item.getStockQuantity() + quantityChange);
            return updateItem(id, item);
        }
        return null;
    }
}


