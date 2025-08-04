import React, { createContext, useContext, useState, useEffect } from 'react';
import { useWallet } from './WalletContext';
import { useTransactionNotifications } from '../components/TransactionNotifications';
import blockchainSimulator from '../utils/blockchain-simulator';

const SimulatedContractContext = createContext();

export const useSimulatedContract = () => {
  const context = useContext(SimulatedContractContext);
  if (!context) {
    throw new Error('useSimulatedContract must be used within a SimulatedContractProvider');
  }
  return context;
};

export const SimulatedContractProvider = ({ children }) => {
  const { account, isConnected } = useWallet();
  const { showTransactionNotification } = useTransactionNotifications();
  const [loading, setLoading] = useState(false);
  const [userRole, setUserRole] = useState(null);
  const [batches, setBatches] = useState([]);
  const [currentBatchId, setCurrentBatchId] = useState(0);

  // Simulate user role based on account
  useEffect(() => {
    if (account) {
      // Simulate role assignment based on account address
      const accountLower = account.toLowerCase();
      if (accountLower.includes('manufacturer') || accountLower.includes('0x7099')) {
        setUserRole('MANUFACTURER');
      } else if (accountLower.includes('distributor') || accountLower.includes('0x3c44')) {
        setUserRole('DISTRIBUTOR');
      } else if (accountLower.includes('hospital') || accountLower.includes('0x90f7')) {
        setUserRole('HOSPITAL');
      } else if (accountLower.includes('patient') || accountLower.includes('0x15d3')) {
        setUserRole('PATIENT');
      } else if (accountLower.includes('admin') || accountLower.includes('0xf39f')) {
        setUserRole('ADMIN');
      } else {
        setUserRole('UNKNOWN');
      }
    }
  }, [account]);

  // Simulate contract initialization
  useEffect(() => {
    if (isConnected && account) {
      showTransactionNotification(
        'Connected to blockchain network',
        'success',
        {
          hash: blockchainSimulator.generateTransactionHash(),
          blockNumber: blockchainSimulator.blockNumber,
          action: 'CONNECT_WALLET',
          metadata: { account }
        }
      );
    }
  }, [isConnected, account, showTransactionNotification]);

  // Drug batch creation
  const createDrugBatch = async (drugName, quantity, expiryDate, manufacturingDate = null) => {
    if (!account) {
      throw new Error('Wallet not connected');
    }

    try {
      setLoading(true);
      
      // Show pending notification
      showTransactionNotification(
        'Creating drug batch on blockchain...',
        'pending'
      );

      // Simulate blockchain transaction
      const transaction = await blockchainSimulator.simulateTransaction(
        'CREATE_BATCH',
        {
          drugName,
          quantity: parseInt(quantity),
          expiryDate: Math.floor(new Date(expiryDate).getTime() / 1000),
          manufacturingDate: manufacturingDate ? Math.floor(new Date(manufacturingDate).getTime() / 1000) : Math.floor(Date.now() / 1000)
        },
        account
      );

      // Create batch object
      const newBatch = {
        id: currentBatchId + 1,
        drugName,
        manufacturer: account,
        currentHolder: account,
        quantity: parseInt(quantity),
        expiryDate: Math.floor(new Date(expiryDate).getTime() / 1000),
        manufacturingDate: manufacturingDate ? Math.floor(new Date(manufacturingDate).getTime() / 1000) : Math.floor(Date.now() / 1000),
        status: 0, // Available
        merkleRoot: '0x' + Math.random().toString(16).substr(2, 64),
        ipfsHash: 'Qm' + Math.random().toString(16).substr(2, 44),
        createdAt: Math.floor(Date.now() / 1000),
        transactionHash: transaction.hash
      };

      // Update state
      setBatches(prev => [newBatch, ...prev]);
      setCurrentBatchId(prev => prev + 1);

      // Show success notification
      showTransactionNotification(
        `Drug batch "${drugName}" created successfully!`,
        'success',
        transaction
      );

      return transaction;
    } catch (error) {
      showTransactionNotification(
        'Failed to create drug batch',
        'error',
        null,
        error
      );
      throw error;
    } finally {
      setLoading(false);
    }
  };

  // Transfer batch to distributor
  const transferToDistributor = async (batchId, distributorAddress) => {
    if (!account) {
      throw new Error('Wallet not connected');
    }

    try {
      setLoading(true);
      
      showTransactionNotification(
        'Transferring batch to distributor...',
        'pending'
      );

      const transaction = await blockchainSimulator.simulateTransaction(
        'TRANSFER_BATCH',
        {
          batchId: parseInt(batchId),
          distributorAddress
        },
        account,
        distributorAddress
      );

      // Update batch status
      setBatches(prev => prev.map(batch => 
        batch.id === parseInt(batchId) 
          ? { ...batch, currentHolder: distributorAddress, status: 1 } // In Transit
          : batch
      ));

      showTransactionNotification(
        `Batch #${batchId} transferred to distributor successfully!`,
        'success',
        transaction
      );

      return transaction;
    } catch (error) {
      showTransactionNotification(
        'Failed to transfer batch',
        'error',
        null,
        error
      );
      throw error;
    } finally {
      setLoading(false);
    }
  };

  // Transfer batch to hospital
  const transferToHospital = async (batchId, hospitalAddress) => {
    if (!account) {
      throw new Error('Wallet not connected');
    }

    try {
      setLoading(true);
      
      showTransactionNotification(
        'Transferring batch to hospital...',
        'pending'
      );

      const transaction = await blockchainSimulator.simulateTransaction(
        'TRANSFER_BATCH',
        {
          batchId: parseInt(batchId),
          hospitalAddress
        },
        account,
        hospitalAddress
      );

      // Update batch status
      setBatches(prev => prev.map(batch => 
        batch.id === parseInt(batchId) 
          ? { ...batch, currentHolder: hospitalAddress, status: 2 } // Delivered
          : batch
      ));

      showTransactionNotification(
        `Batch #${batchId} transferred to hospital successfully!`,
        'success',
        transaction
      );

      return transaction;
    } catch (error) {
      showTransactionNotification(
        'Failed to transfer batch to hospital',
        'error',
        null,
        error
      );
      throw error;
    } finally {
      setLoading(false);
    }
  };

  // Dispense to patient
  const dispenseToPatient = async (batchId, patientAddress, quantity) => {
    if (!account) {
      throw new Error('Wallet not connected');
    }

    try {
      setLoading(true);
      
      showTransactionNotification(
        'Dispensing medication to patient...',
        'pending'
      );

      const transaction = await blockchainSimulator.simulateTransaction(
        'DISPENSE_TO_PATIENT',
        {
          batchId: parseInt(batchId),
          patientAddress,
          quantity: parseInt(quantity)
        },
        account,
        patientAddress
      );

      // Update batch quantity
      setBatches(prev => prev.map(batch => 
        batch.id === parseInt(batchId) 
          ? { ...batch, quantity: Math.max(0, batch.quantity - parseInt(quantity)) }
          : batch
      ));

      showTransactionNotification(
        `${quantity} units dispensed to patient successfully!`,
        'success',
        transaction
      );

      return transaction;
    } catch (error) {
      showTransactionNotification(
        'Failed to dispense medication',
        'error',
        null,
        error
      );
      throw error;
    } finally {
      setLoading(false);
    }
  };

  // Verify drug
  const verifyDrug = async (batchId, leaf, proof) => {
    if (!account) {
      throw new Error('Wallet not connected');
    }

    try {
      setLoading(true);
      
      showTransactionNotification(
        'Verifying drug authenticity...',
        'pending'
      );

      const transaction = await blockchainSimulator.simulateTransaction(
        'VERIFY_DRUG',
        {
          batchId: parseInt(batchId),
          leaf,
          proof
        },
        account
      );

      // Simulate verification result
      const isValid = Math.random() > 0.1; // 90% success rate

      if (isValid) {
        showTransactionNotification(
          'Drug verification successful! Authentic medication.',
          'success',
          transaction
        );
      } else {
        showTransactionNotification(
          'Drug verification failed! Counterfeit detected.',
          'error',
          transaction
        );
      }

      return { isValid, transaction };
    } catch (error) {
      showTransactionNotification(
        'Drug verification failed',
        'error',
        null,
        error
      );
      throw error;
    } finally {
      setLoading(false);
    }
  };

  // Grant role
  const grantRole = async (role, address) => {
    if (!account) {
      throw new Error('Wallet not connected');
    }

    try {
      setLoading(true);
      
      showTransactionNotification(
        `Granting ${role} role...`,
        'pending'
      );

      const transaction = await blockchainSimulator.simulateTransaction(
        'GRANT_ROLE',
        {
          role,
          address
        },
        account
      );

      showTransactionNotification(
        `${role} role granted successfully!`,
        'success',
        transaction
      );

      return transaction;
    } catch (error) {
      showTransactionNotification(
        'Failed to grant role',
        'error',
        null,
        error
      );
      throw error;
    } finally {
      setLoading(false);
    }
  };

  // Request drugs
  const requestDrugs = async (distributorAddress, batchId, quantity, reason) => {
    if (!account) {
      throw new Error('Wallet not connected');
    }

    try {
      setLoading(true);
      
      showTransactionNotification(
        'Submitting drug request...',
        'pending'
      );

      const transaction = await blockchainSimulator.simulateTransaction(
        'REQUEST_DRUGS',
        {
          distributorAddress,
          batchId: parseInt(batchId),
          quantity: parseInt(quantity),
          reason
        },
        account,
        distributorAddress
      );

      showTransactionNotification(
        'Drug request submitted successfully!',
        'success',
        transaction
      );

      return transaction;
    } catch (error) {
      showTransactionNotification(
        'Failed to submit drug request',
        'error',
        null,
        error
      );
      throw error;
    } finally {
      setLoading(false);
    }
  };

  // Approve request
  const approveRequest = async (requestId) => {
    if (!account) {
      throw new Error('Wallet not connected');
    }

    try {
      setLoading(true);
      
      showTransactionNotification(
        'Approving drug request...',
        'pending'
      );

      const transaction = await blockchainSimulator.simulateTransaction(
        'APPROVE_REQUEST',
        {
          requestId: parseInt(requestId)
        },
        account
      );

      showTransactionNotification(
        'Drug request approved successfully!',
        'success',
        transaction
      );

      return transaction;
    } catch (error) {
      showTransactionNotification(
        'Failed to approve request',
        'error',
        null,
        error
      );
      throw error;
    } finally {
      setLoading(false);
    }
  };

  // Reject request
  const rejectRequest = async (requestId) => {
    if (!account) {
      throw new Error('Wallet not connected');
    }

    try {
      setLoading(true);
      
      showTransactionNotification(
        'Rejecting drug request...',
        'pending'
      );

      const transaction = await blockchainSimulator.simulateTransaction(
        'REJECT_REQUEST',
        {
          requestId: parseInt(requestId)
        },
        account
      );

      showTransactionNotification(
        'Drug request rejected successfully!',
        'success',
        transaction
      );

      return transaction;
    } catch (error) {
      showTransactionNotification(
        'Failed to reject request',
        'error',
        null,
        error
      );
      throw error;
    } finally {
      setLoading(false);
    }
  };

  // Get batches for current user
  const getBatches = () => {
    if (!account) return [];
    
    return batches.filter(batch => {
      switch (userRole) {
        case 'MANUFACTURER':
          return batch.manufacturer.toLowerCase() === account.toLowerCase();
        case 'DISTRIBUTOR':
          return batch.currentHolder.toLowerCase() === account.toLowerCase() && batch.status === 1;
        case 'HOSPITAL':
          return batch.currentHolder.toLowerCase() === account.toLowerCase() && batch.status === 2;
        case 'PATIENT':
          return batch.currentHolder.toLowerCase() === account.toLowerCase();
        case 'ADMIN':
          return true; // Admin can see all batches
        default:
          return false;
      }
    });
  };

  // Get all batches (for admin)
  const getAllBatches = () => {
    return [...batches];
  };

  // Get network information
  const getNetworkInfo = () => {
    return blockchainSimulator.getNetworkInfo();
  };

  // Get network status
  const getNetworkStatus = () => {
    return blockchainSimulator.getNetworkStatus();
  };

  // Get account balance
  const getBalance = (address) => {
    return blockchainSimulator.getBalance(address);
  };

  // Estimate gas for transaction
  const estimateGas = (action, data) => {
    return blockchainSimulator.estimateGas(action, data);
  };

  const value = {
    loading,
    userRole,
    batches,
    currentBatchId,
    createDrugBatch,
    transferToDistributor,
    transferToHospital,
    dispenseToPatient,
    verifyDrug,
    grantRole,
    requestDrugs,
    approveRequest,
    rejectRequest,
    getBatches,
    getAllBatches,
    getNetworkInfo,
    getNetworkStatus,
    getBalance,
    estimateGas
  };

  return (
    <SimulatedContractContext.Provider value={value}>
      {children}
    </SimulatedContractContext.Provider>
  );
}; 