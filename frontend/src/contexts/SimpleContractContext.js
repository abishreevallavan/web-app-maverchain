import React, { createContext, useContext, useState, useEffect } from 'react';
import { useSimpleWallet } from './SimpleWalletContext';

const SimpleContractContext = createContext();

export const useSimpleContract = () => {
  const context = useContext(SimpleContractContext);
  if (!context) {
    throw new Error('useSimpleContract must be used within a SimpleContractProvider');
  }
  return context;
};

export const SimpleContractProvider = ({ children }) => {
  const { account, userRole } = useSimpleWallet();
  const [batches, setBatches] = useState([]);
  const [loading, setLoading] = useState(false);

  // Simulate blockchain transaction
  const simulateTransaction = async (operation, data) => {
    const transactionHash = '0x' + Math.random().toString(16).substr(2, 64);
    const blockNumber = Math.floor(Math.random() * 1000000) + 1000000;
    const gasUsed = Math.floor(Math.random() * 100000) + 50000;
    
    console.log(`🔗 ${operation} transaction:`, transactionHash);
    console.log(`📦 Block: ${blockNumber}, Gas: ${gasUsed}`);
    
    // Simulate confirmation delay
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    return {
      hash: transactionHash,
      blockNumber,
      gasUsed,
      status: 'success'
    };
  };

  // Create drug batch
  const createBatch = async (drugName, quantity, expiryDate) => {
    try {
      setLoading(true);
      console.log('🏭 Creating drug batch...');
      
      const tx = await simulateTransaction('CREATE_BATCH', { drugName, quantity, expiryDate });
      
      const newBatch = {
        id: batches.length + 1,
        drugName,
        quantity: parseInt(quantity),
        expiryDate,
        manufacturer: account,
        status: 'active',
        createdAt: new Date().toISOString(),
        transactionHash: tx.hash,
        blockNumber: tx.blockNumber
      };
      
      setBatches(prev => [...prev, newBatch]);
      console.log('✅ Batch created successfully:', newBatch);
      
      return newBatch.id;
    } catch (error) {
      console.error('❌ Error creating batch:', error);
      throw error;
    } finally {
      setLoading(false);
    }
  };

  // Get manufacturer batches
  const getManufacturerBatches = async (manufacturerAddress) => {
    console.log('📋 Loading batches for:', manufacturerAddress);
    return batches.filter(batch => batch.manufacturer === manufacturerAddress);
  };

  // Transfer batch
  const transferBatch = async (batchId, recipient) => {
    try {
      setLoading(true);
      console.log('🚚 Transferring batch...');
      
      const tx = await simulateTransaction('TRANSFER_BATCH', { batchId, recipient });
      
      setBatches(prev => prev.map(batch => 
        batch.id === batchId 
          ? { ...batch, recipient, status: 'transferred', transferHash: tx.hash }
          : batch
      ));
      
      console.log('✅ Batch transferred successfully');
      return tx;
    } catch (error) {
      console.error('❌ Error transferring batch:', error);
      throw error;
    } finally {
      setLoading(false);
    }
  };

  // Grant role
  const grantRole = async (role, address) => {
    try {
      console.log(`🎯 Granting ${role} role to ${address}...`);
      
      const tx = await simulateTransaction('GRANT_ROLE', { role, address });
      
      console.log('✅ Role granted successfully');
      return tx;
    } catch (error) {
      console.error('❌ Error granting role:', error);
      throw error;
    }
  };

  // Get user role
  const getUserRole = () => {
    return userRole;
  };

  // Request drugs
  const requestDrugs = async (drugName, quantity, reason) => {
    try {
      setLoading(true);
      console.log('📋 Requesting drugs...');
      
      const tx = await simulateTransaction('REQUEST_DRUGS', { drugName, quantity, reason });
      
      console.log('✅ Drug request submitted');
      return tx;
    } catch (error) {
      console.error('❌ Error requesting drugs:', error);
      throw error;
    } finally {
      setLoading(false);
    }
  };

  // Approve request
  const approveRequest = async (requestId) => {
    try {
      setLoading(true);
      console.log('✅ Approving request...');
      
      const tx = await simulateTransaction('APPROVE_REQUEST', { requestId });
      
      console.log('✅ Request approved');
      return tx;
    } catch (error) {
      console.error('❌ Error approving request:', error);
      throw error;
    } finally {
      setLoading(false);
    }
  };

  // Reject request
  const rejectRequest = async (requestId) => {
    try {
      setLoading(true);
      console.log('❌ Rejecting request...');
      
      const tx = await simulateTransaction('REJECT_REQUEST', { requestId });
      
      console.log('✅ Request rejected');
      return tx;
    } catch (error) {
      console.error('❌ Error rejecting request:', error);
      throw error;
    } finally {
      setLoading(false);
    }
  };

  // Get drug request
  const getDrugRequest = async (requestId) => {
    console.log('📋 Getting drug request:', requestId);
    return {
      id: requestId,
      drugName: 'Paracetamol',
      quantity: 500,
      reason: 'Low stock',
      status: 'pending',
      requester: '0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC'
    };
  };

  // Force reinitialize
  const forceReinitialize = async () => {
    console.log('🔄 Reinitializing contract connection...');
    await new Promise(resolve => setTimeout(resolve, 1000));
    console.log('✅ Contract reinitialized');
  };

  const value = {
    createBatch,
    getManufacturerBatches,
    transferBatch,
    grantRole,
    getUserRole,
    requestDrugs,
    approveRequest,
    rejectRequest,
    getDrugRequest,
    forceReinitialize,
    loading,
    batches
  };

  return (
    <SimpleContractContext.Provider value={value}>
      {children}
    </SimpleContractContext.Provider>
  );
}; 