package com.etech.service;

import com.etech.model.Invoice;
import com.etech.model.InvoiceItem;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;

@Service
public class InvoiceService {

    @Autowired
    private Firestore firestore;

    @Autowired
    private CustomerService customerService;

    @Autowired
    private ItemService itemService;

    @Autowired
    private TransactionService transactionService;

    private static final String COLLECTION = "invoices";

    public Invoice createInvoice(Invoice invoice) throws ExecutionException, InterruptedException {
        invoice.setId(null);
        invoice.setInvoiceDate(LocalDateTime.now());
        invoice.setCreatedAt(LocalDateTime.now());
        invoice.setUpdatedAt(LocalDateTime.now());
        
        // Generate invoice number
        if (invoice.getInvoiceNumber() == null || invoice.getInvoiceNumber().isEmpty()) {
            invoice.setInvoiceNumber("INV-" + System.currentTimeMillis());
        }
        
        // Calculate totals
        calculateTotals(invoice);
        
        // Get customer name
        if (invoice.getCustomerId() != null) {
            var customer = customerService.getCustomer(invoice.getCustomerId());
            if (customer != null) {
                invoice.setCustomerName(customer.getName());
            }
        }
        
        var docRef = firestore.collection(COLLECTION).document();
        invoice.setId(docRef.getId());
        docRef.set(invoice).get();
        
        // Update inventory if status is not DRAFT
        if (!"DRAFT".equals(invoice.getStatus())) {
            updateInventory(invoice);
        }
        
        return invoice;
    }

    public Invoice getInvoice(String id) throws ExecutionException, InterruptedException {
        var doc = firestore.collection(COLLECTION).document(id).get().get();
        if (doc.exists()) {
            Invoice invoice = doc.toObject(Invoice.class);
            invoice.setId(doc.getId());
            return invoice;
        }
        return null;
    }

    public List<Invoice> getAllInvoices() throws ExecutionException, InterruptedException {
        List<Invoice> invoices = new ArrayList<>();
        var querySnapshot = firestore.collection(COLLECTION).get().get();
        
        for (QueryDocumentSnapshot document : querySnapshot.getDocuments()) {
            Invoice invoice = document.toObject(Invoice.class);
            invoice.setId(document.getId());
            invoices.add(invoice);
        }
        
        return invoices;
    }

    public Invoice updateInvoice(String id, Invoice invoice) throws ExecutionException, InterruptedException {
        invoice.setId(id);
        invoice.setUpdatedAt(LocalDateTime.now());
        
        calculateTotals(invoice);
        
        firestore.collection(COLLECTION).document(id).set(invoice).get();
        return invoice;
    }

    public void deleteInvoice(String id) throws ExecutionException, InterruptedException {
        firestore.collection(COLLECTION).document(id).delete().get();
    }

    public Invoice markAsPaid(String id) throws ExecutionException, InterruptedException {
        Invoice invoice = getInvoice(id);
        if (invoice != null) {
            invoice.setStatus("PAID");
            invoice.setUpdatedAt(LocalDateTime.now());
            firestore.collection(COLLECTION).document(id).set(invoice).get();
            
            // Create income transaction
            transactionService.createTransaction(
                "INCOME",
                "INVOICE_PAYMENT",
                invoice.getTotal(),
                "Payment for invoice " + invoice.getInvoiceNumber(),
                invoice.getId()
            );
        }
        return invoice;
    }

    private void calculateTotals(Invoice invoice) {
        double subtotal = 0.0;
        if (invoice.getItems() != null) {
            for (InvoiceItem item : invoice.getItems()) {
                item.setTotal(item.getQuantity() * item.getUnitPrice());
                subtotal += item.getTotal();
            }
        }
        invoice.setSubtotal(subtotal);
        invoice.setTax(invoice.getTax() != null ? invoice.getTax() : 0.0);
        invoice.setTotal(subtotal + invoice.getTax());
    }

    private void updateInventory(Invoice invoice) throws ExecutionException, InterruptedException {
        if (invoice.getItems() != null) {
            for (InvoiceItem item : invoice.getItems()) {
                itemService.updateStock(item.getItemId(), -item.getQuantity());
            }
        }
    }
}


