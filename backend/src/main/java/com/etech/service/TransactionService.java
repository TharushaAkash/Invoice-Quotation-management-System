package com.etech.service;

import com.etech.model.Transaction;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;

@Service
public class TransactionService {

    @Autowired
    private Firestore firestore;

    private static final String COLLECTION = "transactions";

    public Transaction createTransaction(String type, String category, Double amount, 
                                        String description, String invoiceId) 
            throws ExecutionException, InterruptedException {
        Transaction transaction = new Transaction();
        transaction.setType(type);
        transaction.setCategory(category);
        transaction.setAmount(amount);
        transaction.setDescription(description);
        transaction.setInvoiceId(invoiceId);
        transaction.setTransactionDate(LocalDateTime.now());
        transaction.setCreatedAt(LocalDateTime.now());
        transaction.setUpdatedAt(LocalDateTime.now());
        
        var docRef = firestore.collection(COLLECTION).document();
        transaction.setId(docRef.getId());
        docRef.set(transaction).get();
        
        return transaction;
    }

    public Transaction createTransaction(Transaction transaction) throws ExecutionException, InterruptedException {
        transaction.setId(null);
        if (transaction.getTransactionDate() == null) {
            transaction.setTransactionDate(LocalDateTime.now());
        }
        transaction.setCreatedAt(LocalDateTime.now());
        transaction.setUpdatedAt(LocalDateTime.now());
        
        var docRef = firestore.collection(COLLECTION).document();
        transaction.setId(docRef.getId());
        docRef.set(transaction).get();
        
        return transaction;
    }

    public List<Transaction> getAllTransactions() throws ExecutionException, InterruptedException {
        List<Transaction> transactions = new ArrayList<>();
        var querySnapshot = firestore.collection(COLLECTION).get().get();
        
        for (QueryDocumentSnapshot document : querySnapshot.getDocuments()) {
            Transaction transaction = document.toObject(Transaction.class);
            transaction.setId(document.getId());
            transactions.add(transaction);
        }
        
        return transactions;
    }

    public Map<String, Object> getFinancialReport(int year, int month) throws ExecutionException, InterruptedException {
        List<Transaction> allTransactions = getAllTransactions();
        
        double totalIncome = 0.0;
        double totalExpense = 0.0;
        
        for (Transaction transaction : allTransactions) {
            LocalDateTime date = transaction.getTransactionDate();
            if (date.getYear() == year && (month == 0 || date.getMonthValue() == month)) {
                if ("INCOME".equals(transaction.getType())) {
                    totalIncome += transaction.getAmount();
                } else if ("EXPENSE".equals(transaction.getType())) {
                    totalExpense += transaction.getAmount();
                }
            }
        }
        
        Map<String, Object> report = new HashMap<>();
        report.put("year", year);
        report.put("month", month);
        report.put("totalIncome", totalIncome);
        report.put("totalExpense", totalExpense);
        report.put("profit", totalIncome - totalExpense);
        
        return report;
    }
}


