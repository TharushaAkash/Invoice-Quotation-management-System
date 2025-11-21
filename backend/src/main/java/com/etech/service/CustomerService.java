package com.etech.service;

import com.etech.model.Customer;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;

@Service
public class CustomerService {

    @Autowired
    private Firestore firestore;

    private static final String COLLECTION = "customers";

    public Customer createCustomer(Customer customer) throws ExecutionException, InterruptedException {
        customer.setId(null);
        customer.setCreatedAt(LocalDateTime.now());
        customer.setUpdatedAt(LocalDateTime.now());
        
        var docRef = firestore.collection(COLLECTION).document();
        customer.setId(docRef.getId());
        docRef.set(customer).get();
        
        return customer;
    }

    public Customer getCustomer(String id) throws ExecutionException, InterruptedException {
        var doc = firestore.collection(COLLECTION).document(id).get().get();
        if (doc.exists()) {
            return doc.toObject(Customer.class);
        }
        return null;
    }

    public List<Customer> getAllCustomers() throws ExecutionException, InterruptedException {
        List<Customer> customers = new ArrayList<>();
        var querySnapshot = firestore.collection(COLLECTION).get().get();
        
        for (QueryDocumentSnapshot document : querySnapshot.getDocuments()) {
            Customer customer = document.toObject(Customer.class);
            customer.setId(document.getId());
            customers.add(customer);
        }
        
        return customers;
    }

    public Customer updateCustomer(String id, Customer customer) throws ExecutionException, InterruptedException {
        customer.setId(id);
        customer.setUpdatedAt(LocalDateTime.now());
        
        firestore.collection(COLLECTION).document(id).set(customer).get();
        return customer;
    }

    public void deleteCustomer(String id) throws ExecutionException, InterruptedException {
        firestore.collection(COLLECTION).document(id).delete().get();
    }
}


