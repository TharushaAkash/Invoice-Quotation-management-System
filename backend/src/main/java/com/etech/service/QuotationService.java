package com.etech.service;

import com.etech.model.Quotation;
import com.etech.model.QuotationItem;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;

@Service
public class QuotationService {

    @Autowired
    private Firestore firestore;

    @Autowired
    private CustomerService customerService;

    private static final String COLLECTION = "quotations";

    public Quotation createQuotation(Quotation quotation) throws ExecutionException, InterruptedException {
        quotation.setId(null);
        quotation.setQuotationDate(LocalDateTime.now());
        quotation.setCreatedAt(LocalDateTime.now());
        quotation.setUpdatedAt(LocalDateTime.now());
        
        // Generate quotation number
        if (quotation.getQuotationNumber() == null || quotation.getQuotationNumber().isEmpty()) {
            quotation.setQuotationNumber("QUO-" + System.currentTimeMillis());
        }
        
        // Calculate totals
        calculateTotals(quotation);
        
        // Get customer name
        if (quotation.getCustomerId() != null) {
            var customer = customerService.getCustomer(quotation.getCustomerId());
            if (customer != null) {
                quotation.setCustomerName(customer.getName());
            }
        }
        
        var docRef = firestore.collection(COLLECTION).document();
        quotation.setId(docRef.getId());
        docRef.set(quotation).get();
        
        return quotation;
    }

    public Quotation getQuotation(String id) throws ExecutionException, InterruptedException {
        var doc = firestore.collection(COLLECTION).document(id).get().get();
        if (doc.exists()) {
            Quotation quotation = doc.toObject(Quotation.class);
            quotation.setId(doc.getId());
            return quotation;
        }
        return null;
    }

    public List<Quotation> getAllQuotations() throws ExecutionException, InterruptedException {
        List<Quotation> quotations = new ArrayList<>();
        var querySnapshot = firestore.collection(COLLECTION).get().get();
        
        for (QueryDocumentSnapshot document : querySnapshot.getDocuments()) {
            Quotation quotation = document.toObject(Quotation.class);
            quotation.setId(document.getId());
            quotations.add(quotation);
        }
        
        return quotations;
    }

    public Quotation updateQuotation(String id, Quotation quotation) throws ExecutionException, InterruptedException {
        quotation.setId(id);
        quotation.setUpdatedAt(LocalDateTime.now());
        
        calculateTotals(quotation);
        
        firestore.collection(COLLECTION).document(id).set(quotation).get();
        return quotation;
    }

    public void deleteQuotation(String id) throws ExecutionException, InterruptedException {
        firestore.collection(COLLECTION).document(id).delete().get();
    }

    private void calculateTotals(Quotation quotation) {
        double subtotal = 0.0;
        if (quotation.getItems() != null) {
            for (QuotationItem item : quotation.getItems()) {
                item.setTotal(item.getQuantity() * item.getUnitPrice());
                subtotal += item.getTotal();
            }
        }
        quotation.setSubtotal(subtotal);
        quotation.setTax(quotation.getTax() != null ? quotation.getTax() : 0.0);
        quotation.setTotal(subtotal + quotation.getTax());
    }
}


