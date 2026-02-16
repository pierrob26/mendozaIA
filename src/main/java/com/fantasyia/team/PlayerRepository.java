package com.fantasyia.team;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
public interface PlayerRepository extends JpaRepository<Player, Long> {
    
    List<Player> findByOwnerId(Long ownerId);
    
    List<Player> findByOwnerIdAndPosition(Long ownerId, String position);
    
    // Find free agents (players without contracts)
    List<Player> findByOwnerIdIsNull();
    
    // Find players without contracts (regardless of ownership)
    List<Player> findByContractLengthIsNullAndContractAmountIsNull();
    
    @Query("SELECT p FROM Player p WHERE p.ownerId = :ownerId " +
           "AND (:position IS NULL OR :position = '' OR p.position = :position) " +
           "AND (:minContract IS NULL OR p.contractLength >= :minContract) " +
           "AND (:maxContract IS NULL OR p.contractLength <= :maxContract) " +
           "AND (:minSalary IS NULL OR p.contractAmount >= :minSalary) " +
           "AND (:maxSalary IS NULL OR p.contractAmount <= :maxSalary)")
    List<Player> findPlayersWithFilters(@Param("ownerId") Long ownerId,
                                      @Param("position") String position,
                                      @Param("minContract") Integer minContract,
                                      @Param("maxContract") Integer maxContract,
                                      @Param("minSalary") Double minSalary,
                                      @Param("maxSalary") Double maxSalary);
    
    // Clear all contracts for all players (make them free agents)
    @Modifying
    @Transactional
    @Query("UPDATE Player p SET p.contractLength = null, p.contractAmount = null, p.ownerId = null")
    void clearAllContracts();
    
    // Release specific players to free agency
    @Modifying
    @Transactional
    @Query("UPDATE Player p SET p.contractLength = null, p.contractAmount = null, p.ownerId = null WHERE p.id IN :playerIds")
    void releasePlayersToFreeAgency(@Param("playerIds") List<Long> playerIds);
}