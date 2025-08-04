/**
 * Blockchain Transaction Simulator
 * Provides realistic blockchain interactions for the MedChain application
 * Simulates transaction confirmations, gas fees, and block numbers
 */

class BlockchainSimulator {
  constructor() {
    this.transactionCounter = 0;
    this.blockNumber = 1;
    this.pendingTransactions = [];
    this.confirmedTransactions = [];
    this.networkId = 31337; // Hardhat local network
    this.chainId = '0x7A69'; // Hex representation
    this.gasPrice = 20000000000; // 20 gwei
    this.maxPriorityFeePerGas = 2000000000; // 2 gwei
    this.maxFeePerGas = 40000000000; // 40 gwei
  }

  /**
   * Simulate a blockchain transaction
   * @param {string} action - The action being performed (CREATE_BATCH, TRANSFER, etc.)
   * @param {object} data - Transaction data
   * @param {string} from - Sender address
   * @param {string} to - Recipient address (optional)
   * @returns {Promise<object>} Transaction result
   */
  async simulateTransaction(action, data, from = null, to = null) {
    this.transactionCounter++;
    
    // Generate realistic transaction hash
    const transactionHash = this.generateTransactionHash();
    
    // Calculate gas usage based on action type
    const gasUsed = this.calculateGasUsage(action, data);
    
    // Calculate gas cost
    const gasCost = gasUsed * this.gasPrice;
    
    // Create transaction object
    const transaction = {
      hash: transactionHash,
      blockNumber: this.blockNumber,
      blockHash: this.generateBlockHash(),
      from: from || this.generateAddress(),
      to: to || this.generateContractAddress(),
      gas: gasUsed + Math.floor(gasUsed * 0.1), // Add 10% buffer
      gasUsed: gasUsed,
      gasPrice: this.gasPrice,
      maxPriorityFeePerGas: this.maxPriorityFeePerGas,
      maxFeePerGas: this.maxFeePerGas,
      value: '0x0',
      nonce: this.transactionCounter,
      data: this.encodeTransactionData(action, data),
      status: 'pending',
      timestamp: Date.now(),
      action: action,
      metadata: data
    };

    // Add to pending transactions
    this.pendingTransactions.push(transaction);

    // Simulate blockchain confirmation delay
    await this.simulateBlockConfirmation();

    // Update transaction status
    transaction.status = 'confirmed';
    transaction.confirmations = 1;
    transaction.confirmedAt = Date.now();

    // Move to confirmed transactions
    this.confirmedTransactions.push(transaction);
    this.pendingTransactions = this.pendingTransactions.filter(tx => tx.hash !== transactionHash);

    // Increment block number
    this.blockNumber++;

    return transaction;
  }

  /**
   * Generate a realistic transaction hash
   * @returns {string} Transaction hash
   */
  generateTransactionHash() {
    const timestamp = Date.now().toString(16);
    const random = Math.random().toString(16).substr(2, 56);
    return '0x' + timestamp + random;
  }

  /**
   * Generate a realistic block hash
   * @returns {string} Block hash
   */
  generateBlockHash() {
    const blockNumber = this.blockNumber.toString(16);
    const random = Math.random().toString(16).substr(2, 56);
    return '0x' + blockNumber + random;
  }

  /**
   * Generate a realistic Ethereum address
   * @returns {string} Ethereum address
   */
  generateAddress() {
    const address = '0x' + Math.random().toString(16).substr(2, 40);
    return address;
  }

  /**
   * Generate a contract address
   * @returns {string} Contract address
   */
  generateContractAddress() {
    const address = '0x' + Math.random().toString(16).substr(2, 40);
    return address;
  }

  /**
   * Calculate gas usage based on action type
   * @param {string} action - Transaction action
   * @param {object} data - Transaction data
   * @returns {number} Gas used
   */
  calculateGasUsage(action, data) {
    const baseGas = 21000;
    
    switch (action) {
      case 'CREATE_BATCH':
        return baseGas + 50000 + (data.drugName?.length || 0) * 100;
      case 'TRANSFER_BATCH':
        return baseGas + 30000;
      case 'DISPENSE_TO_PATIENT':
        return baseGas + 40000;
      case 'VERIFY_DRUG':
        return baseGas + 25000;
      case 'GRANT_ROLE':
        return baseGas + 35000;
      case 'REQUEST_DRUGS':
        return baseGas + 45000;
      case 'APPROVE_REQUEST':
        return baseGas + 30000;
      case 'REJECT_REQUEST':
        return baseGas + 25000;
      case 'UPDATE_HEALTH_RECORD':
        return baseGas + 60000;
      case 'REPORT_EXPIRED_DRUG':
        return baseGas + 40000;
      default:
        return baseGas + 30000;
    }
  }

  /**
   * Encode transaction data for the action
   * @param {string} action - Transaction action
   * @param {object} data - Transaction data
   * @returns {string} Encoded data
   */
  encodeTransactionData(action, data) {
    // Simulate function signature and parameters
    const functionSignatures = {
      'CREATE_BATCH': 'createDrugBatch(string,uint256,uint256)',
      'TRANSFER_BATCH': 'transferToDistributor(uint256,address)',
      'DISPENSE_TO_PATIENT': 'dispenseToPatient(uint256,address,uint256)',
      'VERIFY_DRUG': 'verifyDrug(uint256,bytes32,bytes32[])',
      'GRANT_ROLE': 'grantRole(bytes32,address)',
      'REQUEST_DRUGS': 'requestDrugs(address,uint256,uint256,string)',
      'APPROVE_REQUEST': 'approveRequest(uint256)',
      'REJECT_REQUEST': 'rejectRequest(uint256)',
      'UPDATE_HEALTH_RECORD': 'updateHealthRecord(address,string)',
      'REPORT_EXPIRED_DRUG': 'reportExpiredDrug(uint256,string)'
    };

    const signature = functionSignatures[action] || 'unknown()';
    const signatureHash = this.hashFunction(signature);
    
    // Simulate encoded parameters
    const encodedParams = this.encodeParameters(data);
    
    return signatureHash + encodedParams;
  }

  /**
   * Hash a function signature
   * @param {string} signature - Function signature
   * @returns {string} Function hash
   */
  hashFunction(signature) {
    // Simulate Keccak-256 hash of function signature
    const hash = '0x' + Math.random().toString(16).substr(2, 64);
    return hash.substring(0, 10); // Return first 4 bytes (function selector)
  }

  /**
   * Encode parameters for transaction data
   * @param {object} data - Transaction data
   * @returns {string} Encoded parameters
   */
  encodeParameters(data) {
    // Simulate ABI encoding
    let encoded = '';
    
    for (const [key, value] of Object.entries(data)) {
      if (typeof value === 'string') {
        // Simulate string encoding
        encoded += '0x' + Math.random().toString(16).substr(2, 64);
      } else if (typeof value === 'number') {
        // Simulate uint256 encoding
        encoded += '0x' + value.toString(16).padStart(64, '0');
      } else if (typeof value === 'boolean') {
        // Simulate bool encoding
        encoded += value ? '0x0000000000000000000000000000000000000000000000000000000000000001' : '0x0000000000000000000000000000000000000000000000000000000000000000';
      }
    }
    
    return encoded;
  }

  /**
   * Simulate blockchain confirmation delay
   * @returns {Promise<void>}
   */
  async simulateBlockConfirmation() {
    // Simulate 2-5 second confirmation time (realistic for local blockchain)
    const delay = Math.random() * 3000 + 2000;
    await new Promise(resolve => setTimeout(resolve, delay));
  }

  /**
   * Get pending transactions
   * @returns {Array} Pending transactions
   */
  getPendingTransactions() {
    return [...this.pendingTransactions];
  }

  /**
   * Get confirmed transactions
   * @returns {Array} Confirmed transactions
   */
  getConfirmedTransactions() {
    return [...this.confirmedTransactions];
  }

  /**
   * Get transaction by hash
   * @param {string} hash - Transaction hash
   * @returns {object|null} Transaction object or null
   */
  getTransaction(hash) {
    const allTransactions = [...this.pendingTransactions, ...this.confirmedTransactions];
    return allTransactions.find(tx => tx.hash === hash) || null;
  }

  /**
   * Get network information
   * @returns {object} Network information
   */
  getNetworkInfo() {
    return {
      chainId: this.chainId,
      networkId: this.networkId,
      name: 'Hardhat Localhost',
      blockNumber: this.blockNumber,
      gasPrice: this.gasPrice,
      maxPriorityFeePerGas: this.maxPriorityFeePerGas,
      maxFeePerGas: this.maxFeePerGas
    };
  }

  /**
   * Simulate network status
   * @returns {object} Network status
   */
  getNetworkStatus() {
    return {
      isConnected: true,
      isSyncing: false,
      peerCount: Math.floor(Math.random() * 10) + 1,
      latestBlock: this.blockNumber,
      pendingTransactions: this.pendingTransactions.length
    };
  }

  /**
   * Simulate account balance
   * @param {string} address - Account address
   * @returns {string} Account balance in wei
   */
  getBalance(address) {
    // Simulate balance between 0.1 and 10 ETH
    const balance = Math.random() * 9.9 + 0.1;
    return (balance * 1e18).toString();
  }

  /**
   * Simulate gas estimation
   * @param {string} action - Transaction action
   * @param {object} data - Transaction data
   * @returns {object} Gas estimation
   */
  estimateGas(action, data) {
    const gasUsed = this.calculateGasUsage(action, data);
    const gasLimit = gasUsed + Math.floor(gasUsed * 0.2); // Add 20% buffer
    
    return {
      gasUsed,
      gasLimit,
      gasPrice: this.gasPrice,
      maxPriorityFeePerGas: this.maxPriorityFeePerGas,
      maxFeePerGas: this.maxFeePerGas,
      estimatedCost: (gasLimit * this.gasPrice).toString()
    };
  }

  /**
   * Reset simulator state (for testing)
   */
  reset() {
    this.transactionCounter = 0;
    this.blockNumber = 1;
    this.pendingTransactions = [];
    this.confirmedTransactions = [];
  }
}

// Create singleton instance
const blockchainSimulator = new BlockchainSimulator();

export default blockchainSimulator;
export { BlockchainSimulator }; 