package com.vaishnavi.transaction.service;


import com.vaishnavi.transaction.model.Transaction;
import com.vaishnavi.transaction.repository.TransactionRepository;
import org.springframework.stereotype.Service;

@Service
public class TransactionService {

    private final TransactionRepository repository;

    public TransactionService(TransactionRepository repository) {
        this.repository = repository;
    }

    public Transaction create (
            String merchantId,
            String requestKey,
            long amountMinor,
            String currency
    ) {

        Transaction transaction = new Transaction(merchantId, requestKey, amountMinor, currency);
        return repository.save(transaction);

    }
}
