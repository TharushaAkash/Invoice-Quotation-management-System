package com.etech.controller;

import com.etech.service.CustomerService;
import com.etech.service.InvoiceService;
import com.etech.service.ItemService;
import com.etech.service.QuotationService;
import com.etech.service.TransactionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/dashboard")
@CrossOrigin(origins = "*")
public class DashboardController {

    @Autowired
    private CustomerService customerService;

    @Autowired
    private ItemService itemService;

    @Autowired
    private InvoiceService invoiceService;

    @Autowired
    private QuotationService quotationService;

    @Autowired
    private TransactionService transactionService;

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getDashboardStats() {
        try {
            Map<String, Object> stats = new HashMap<>();
            
            int customerCount = customerService.getAllCustomers().size();
            int itemCount = itemService.getAllItems().size();
            int invoiceCount = invoiceService.getAllInvoices().size();
            int quotationCount = quotationService.getAllQuotations().size();
            
            int currentYear = java.time.LocalDateTime.now().getYear();
            int currentMonth = java.time.LocalDateTime.now().getMonthValue();
            Map<String, Object> monthlyReport = transactionService.getFinancialReport(currentYear, currentMonth);
            
            stats.put("totalCustomers", customerCount);
            stats.put("totalItems", itemCount);
            stats.put("totalInvoices", invoiceCount);
            stats.put("totalQuotations", quotationCount);
            stats.put("monthlyIncome", monthlyReport.get("totalIncome"));
            stats.put("monthlyExpense", monthlyReport.get("totalExpense"));
            stats.put("monthlyProfit", monthlyReport.get("profit"));
            
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            return ResponseEntity.status(500).build();
        }
    }
}


