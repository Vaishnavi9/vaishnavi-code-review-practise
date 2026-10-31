package com.vaishnavi.transaction.repository;


import com.vaishnavi.transaction.model.Transaction;
import org.springframework.data.repository.Repository;
import org.springframework.transaction.annotation.Transactional;


import java.util.Optional;
import java.util.UUID;

public interface TransactionRepository extends
        Repository<Transaction, UUID> {

    @Transactional
    <S extends Transaction> S save (S transaction);

    @Transactional(readOnly = true)
    Optional<Transaction> findByMerchantIdAndRequestKey(
            String merchantId,
            String requestKey
    );

    @Transactional(readOnly = true)
    Optional<Transaction> findByIdAndMerchantId(
            UUID id,
            String merchantId
    );

}