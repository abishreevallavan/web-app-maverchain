import React, { useState, useEffect, createContext, useContext } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { CheckCircle, XCircle, Clock, AlertCircle, ExternalLink } from 'lucide-react';

// Create context for transaction notifications
const TransactionNotificationContext = createContext();

export const useTransactionNotifications = () => {
  const context = useContext(TransactionNotificationContext);
  if (!context) {
    throw new Error('useTransactionNotifications must be used within a TransactionNotificationProvider');
  }
  return context;
};

export const TransactionNotificationProvider = ({ children }) => {
  const [notifications, setNotifications] = useState([]);

  const showTransactionNotification = (message, status, transaction = null, error = null) => {
    const notification = {
      id: Date.now() + Math.random(),
      message,
      status, // 'pending', 'success', 'error', 'warning'
      transaction,
      error,
      timestamp: new Date(),
      read: false
    };
    
    setNotifications(prev => [notification, ...prev.slice(0, 9)]); // Keep last 10 notifications
    
    // Auto-remove after 15 seconds for success/error, 30 seconds for pending
    const autoRemoveDelay = status === 'pending' ? 30000 : 15000;
    setTimeout(() => {
      setNotifications(prev => prev.filter(n => n.id !== notification.id));
    }, autoRemoveDelay);
  };

  const markAsRead = (notificationId) => {
    setNotifications(prev => 
      prev.map(n => n.id === notificationId ? { ...n, read: true } : n)
    );
  };

  const removeNotification = (notificationId) => {
    setNotifications(prev => prev.filter(n => n.id !== notificationId));
  };

  const clearAllNotifications = () => {
    setNotifications([]);
  };

  const value = {
    notifications,
    showTransactionNotification,
    markAsRead,
    removeNotification,
    clearAllNotifications
  };

  return (
    <TransactionNotificationContext.Provider value={value}>
      {children}
      <TransactionNotificationContainer />
    </TransactionNotificationContext.Provider>
  );
};

const TransactionNotificationContainer = () => {
  const { notifications, markAsRead, removeNotification, clearAllNotifications } = useTransactionNotifications();

  const getStatusIcon = (status) => {
    switch (status) {
      case 'success':
        return <CheckCircle className="w-5 h-5 text-green-500" />;
      case 'error':
        return <XCircle className="w-5 h-5 text-red-500" />;
      case 'pending':
        return <Clock className="w-5 h-5 text-yellow-500 animate-spin" />;
      case 'warning':
        return <AlertCircle className="w-5 h-5 text-orange-500" />;
      default:
        return <CheckCircle className="w-5 h-5 text-blue-500" />;
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'success':
        return 'border-green-500/30 bg-green-500/10';
      case 'error':
        return 'border-red-500/30 bg-red-500/10';
      case 'pending':
        return 'border-yellow-500/30 bg-yellow-500/10';
      case 'warning':
        return 'border-orange-500/30 bg-orange-500/10';
      default:
        return 'border-blue-500/30 bg-blue-500/10';
    }
  };

  const getStatusText = (status) => {
    switch (status) {
      case 'success':
        return 'Confirmed';
      case 'error':
        return 'Failed';
      case 'pending':
        return 'Pending';
      case 'warning':
        return 'Warning';
      default:
        return 'Info';
    }
  };

  const formatTransactionHash = (hash) => {
    if (!hash) return 'Unknown';
    return `${hash.slice(0, 10)}...${hash.slice(-8)}`;
  };

  const formatGasUsed = (gasUsed) => {
    if (!gasUsed) return 'Unknown';
    return gasUsed.toLocaleString();
  };

  const formatGasCost = (gasUsed, gasPrice) => {
    if (!gasUsed || !gasPrice) return 'Unknown';
    const costInWei = gasUsed * gasPrice;
    const costInEth = costInWei / 1e18;
    return `${costInEth.toFixed(6)} ETH`;
  };

  const openBlockExplorer = (hash) => {
    if (!hash) return;
    // For local blockchain, we'll simulate a block explorer
    window.open(`https://localhost:8545/tx/${hash}`, '_blank');
  };

  return (
    <div className="fixed top-4 right-4 z-50 space-y-2 max-w-md">
      {/* Header */}
      {notifications.length > 0 && (
        <div className="flex justify-between items-center mb-2">
          <h3 className="text-white font-semibold text-sm">
            Blockchain Transactions ({notifications.length})
          </h3>
          <button
            onClick={clearAllNotifications}
            className="text-white/60 hover:text-white text-xs px-2 py-1 rounded hover:bg-white/10 transition-colors"
          >
            Clear All
          </button>
        </div>
      )}

      <AnimatePresence>
        {notifications.map((notification) => (
          <motion.div
            key={notification.id}
            initial={{ opacity: 0, x: 300, scale: 0.8 }}
            animate={{ opacity: 1, x: 0, scale: 1 }}
            exit={{ opacity: 0, x: 300, scale: 0.8 }}
            transition={{ duration: 0.3, ease: "easeOut" }}
            className={`relative backdrop-blur-lg border rounded-lg p-4 shadow-2xl ${getStatusColor(notification.status)} ${
              notification.read ? 'opacity-60' : ''
            }`}
            onClick={() => markAsRead(notification.id)}
          >
            {/* Header */}
            <div className="flex items-start justify-between mb-3">
              <div className="flex items-center space-x-2">
                {getStatusIcon(notification.status)}
                <div>
                  <h4 className="text-white font-semibold text-sm">
                    {notification.message}
                  </h4>
                  <p className="text-white/60 text-xs">
                    {notification.timestamp.toLocaleTimeString()}
                  </p>
                </div>
              </div>
              <span className={`px-2 py-1 text-xs font-semibold rounded-full ${
                notification.status === 'success' ? 'bg-green-500/20 text-green-300' :
                notification.status === 'error' ? 'bg-red-500/20 text-red-300' :
                notification.status === 'pending' ? 'bg-yellow-500/20 text-yellow-300' :
                notification.status === 'warning' ? 'bg-orange-500/20 text-orange-300' :
                'bg-blue-500/20 text-blue-300'
              }`}>
                {getStatusText(notification.status)}
              </span>
            </div>

            {/* Transaction Details */}
            {notification.transaction && (
              <div className="space-y-2 mt-3 p-3 bg-white/5 rounded-lg border border-white/10">
                <div className="grid grid-cols-2 gap-2 text-xs">
                  <div>
                    <span className="text-white/60">Transaction Hash:</span>
                    <div className="flex items-center space-x-1">
                      <span className="text-white font-mono">
                        {formatTransactionHash(notification.transaction.hash)}
                      </span>
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          openBlockExplorer(notification.transaction.hash);
                        }}
                        className="text-blue-400 hover:text-blue-300 transition-colors"
                      >
                        <ExternalLink className="w-3 h-3" />
                      </button>
                    </div>
                  </div>
                  <div>
                    <span className="text-white/60">Block Number:</span>
                    <p className="text-white font-mono">
                      {notification.transaction.blockNumber?.toLocaleString() || 'Unknown'}
                    </p>
                  </div>
                  <div>
                    <span className="text-white/60">Gas Used:</span>
                    <p className="text-white font-mono">
                      {formatGasUsed(notification.transaction.gasUsed)}
                    </p>
                  </div>
                  <div>
                    <span className="text-white/60">Gas Cost:</span>
                    <p className="text-white font-mono">
                      {formatGasCost(notification.transaction.gasUsed, notification.transaction.gasPrice)}
                    </p>
                  </div>
                </div>

                {/* Action Details */}
                {notification.transaction.action && (
                  <div className="mt-2 pt-2 border-t border-white/10">
                    <span className="text-white/60 text-xs">Action:</span>
                    <p className="text-white text-xs font-semibold">
                      {notification.transaction.action.replace('_', ' ')}
                    </p>
                    {notification.transaction.metadata && (
                      <div className="mt-1">
                        <span className="text-white/60 text-xs">Details:</span>
                        <div className="text-white text-xs">
                          {Object.entries(notification.transaction.metadata).map(([key, value]) => (
                            <div key={key} className="flex justify-between">
                              <span className="text-white/60">{key}:</span>
                              <span className="text-white">{String(value)}</span>
                            </div>
                          ))}
                        </div>
                      </div>
                    )}
                  </div>
                )}
              </div>
            )}

            {/* Error Details */}
            {notification.error && (
              <div className="mt-3 p-3 bg-red-500/10 rounded-lg border border-red-500/20">
                <div className="flex items-center space-x-2 mb-2">
                  <XCircle className="w-4 h-4 text-red-400" />
                  <span className="text-red-300 text-sm font-semibold">Error Details</span>
                </div>
                <p className="text-red-300 text-xs">
                  {notification.error.message || notification.error.toString()}
                </p>
              </div>
            )}

            {/* Progress Bar for Pending Transactions */}
            {notification.status === 'pending' && (
              <div className="mt-3">
                <div className="w-full bg-white/10 rounded-full h-1">
                  <motion.div
                    className="bg-yellow-500 h-1 rounded-full"
                    initial={{ width: 0 }}
                    animate={{ width: "100%" }}
                    transition={{ duration: 30, ease: "linear" }}
                  />
                </div>
                <p className="text-white/60 text-xs mt-1 text-center">
                  Confirming transaction...
                </p>
              </div>
            )}

            {/* Close Button */}
            <button
              onClick={(e) => {
                e.stopPropagation();
                removeNotification(notification.id);
              }}
              className="absolute top-2 right-2 text-white/40 hover:text-white/60 transition-colors"
            >
              <XCircle className="w-4 h-4" />
            </button>
          </motion.div>
        ))}
      </AnimatePresence>
    </div>
  );
};

// Individual notification component for reuse
export const TransactionNotification = ({ notification }) => {
  const { markAsRead } = useTransactionNotifications();

  return (
    <motion.div
      initial={{ opacity: 0, y: -20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -20 }}
      className="backdrop-blur-lg border border-white/20 rounded-lg p-4 shadow-lg"
      onClick={() => markAsRead(notification.id)}
    >
      <div className="flex items-center space-x-3">
        {getStatusIcon(notification.status)}
        <div className="flex-1">
          <h4 className="text-white font-semibold text-sm">
            {notification.message}
          </h4>
          {notification.transaction && (
            <p className="text-white/60 text-xs">
              TX: {formatTransactionHash(notification.transaction.hash)}
            </p>
          )}
        </div>
      </div>
    </motion.div>
  );
};

// Helper function to get status icon
const getStatusIcon = (status) => {
  switch (status) {
    case 'success':
      return <CheckCircle className="w-5 h-5 text-green-500" />;
    case 'error':
      return <XCircle className="w-5 h-5 text-red-500" />;
    case 'pending':
      return <Clock className="w-5 h-5 text-yellow-500 animate-spin" />;
    case 'warning':
      return <AlertCircle className="w-5 h-5 text-orange-500" />;
    default:
      return <CheckCircle className="w-5 h-5 text-blue-500" />;
  }
};

// Helper function to format transaction hash
const formatTransactionHash = (hash) => {
  if (!hash) return 'Unknown';
  return `${hash.slice(0, 10)}...${hash.slice(-8)}`;
}; 