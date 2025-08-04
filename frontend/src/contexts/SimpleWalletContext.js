import React, { createContext, useContext, useState, useEffect } from 'react';

const SimpleWalletContext = createContext();

export const useSimpleWallet = () => {
  const context = useContext(SimpleWalletContext);
  if (!context) {
    throw new Error('useSimpleWallet must be used within a SimpleWalletProvider');
  }
  return context;
};

export const SimpleWalletProvider = ({ children }) => {
  const [account, setAccount] = useState('0x70997970C51812dc3A010C7d01b50e0d17dc79C8');
  const [isConnected, setIsConnected] = useState(true);
  const [isConnecting, setIsConnecting] = useState(false);
  const [network, setNetwork] = useState({ name: 'localhost', chainId: 31337 });
  const [balance, setBalance] = useState('1000.0');
  const [userRole, setUserRole] = useState('manufacturer');

  // Auto-connect on load
  useEffect(() => {
    console.log('🚀 Auto-connecting to MedChain...');
    setTimeout(() => {
      setIsConnected(true);
      console.log('✅ Connected to MedChain successfully!');
      console.log('🎯 Account:', account);
      console.log('🌐 Network: Localhost (31337)');
      console.log('💰 Balance: 1000.0 ETH');
      console.log('👤 Role: Manufacturer');
    }, 1000);
  }, []);

  const connectWallet = async () => {
    try {
      setIsConnecting(true);
      console.log('🔗 Connecting to MedChain...');
      
      // Simulate connection delay
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      setIsConnected(true);
      console.log('✅ Connected successfully!');
      
      return true;
    } catch (error) {
      console.error('❌ Connection error:', error);
      return false;
    } finally {
      setIsConnecting(false);
    }
  };

  const disconnectWallet = () => {
    console.log('🔌 Disconnecting...');
    setIsConnected(false);
    setAccount(null);
  };

  const switchRole = (newRole) => {
    console.log(`🔄 Switching role from ${userRole} to ${newRole}`);
    setUserRole(newRole);
  };

  const getShortAddress = (address) => {
    if (!address) return '';
    return `${address.slice(0, 6)}...${address.slice(-4)}`;
  };

  const updateBalance = async () => {
    // Simulate balance update
    const newBalance = (Math.random() * 1000 + 500).toFixed(2);
    setBalance(newBalance);
    console.log(`💰 Balance updated: ${newBalance} ETH`);
  };

  const value = {
    account,
    isConnected,
    isConnecting,
    network,
    balance,
    userRole,
    connectWallet,
    disconnectWallet,
    switchRole,
    getShortAddress,
    updateBalance
  };

  return (
    <SimpleWalletContext.Provider value={value}>
      {children}
    </SimpleWalletContext.Provider>
  );
}; 