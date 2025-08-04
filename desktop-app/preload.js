const { contextBridge, ipcRenderer } = require('electron');

// Expose protected methods that allow the renderer process to use
// the ipcRenderer without exposing the entire object
contextBridge.exposeInMainWorld('electronAPI', {
  // App info
  getAppVersion: () => ipcRenderer.invoke('get-app-version'),
  getAppName: () => ipcRenderer.invoke('get-app-name'),
  
  // Menu actions
  onMenuNewTransaction: (callback) => ipcRenderer.on('menu-new-transaction', callback),
  onMenuOpenDashboard: (callback) => ipcRenderer.on('menu-open-dashboard', callback),
  onMenuAbout: (callback) => ipcRenderer.on('menu-about', callback),
  
  // Remove listeners
  removeAllListeners: (channel) => ipcRenderer.removeAllListeners(channel),
  
  // Platform info
  platform: process.platform,
  isDev: process.env.NODE_ENV === 'development'
});

// Handle menu actions in the renderer
window.addEventListener('DOMContentLoaded', () => {
  // Handle menu actions
  window.electronAPI.onMenuNewTransaction(() => {
    // Navigate to new transaction page
    if (window.location.pathname !== '/manufacturer') {
      window.location.href = '/manufacturer';
    }
  });

  window.electronAPI.onMenuOpenDashboard(() => {
    // Navigate to dashboard
    if (window.location.pathname !== '/dashboard') {
      window.location.href = '/dashboard';
    }
  });

  window.electronAPI.onMenuAbout(() => {
    // Show about dialog
    alert('MedChain Desktop v1.0.0\n\nBlockchain-based Pharmaceutical Supply Chain Management\n\nBuilt with React, Electron, and CNCF Technologies');
  });
}); 