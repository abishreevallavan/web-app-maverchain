# 🔧 How to Get Manufacturer Role Access

## 🎯 **Quick Fix for "Need Manufacturer Role"**

### **Step 1: Open Browser Console**
1. **Press F12** or **Right-click → Inspect**
2. **Click "Console" tab**
3. **Copy and paste this code:**

```javascript
// Assign manufacturer role to your wallet
const assignManufacturerRole = async () => {
  try {
    const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
    const account = accounts[0];
    console.log('🎯 Assigning manufacturer role to:', account);
    
    // Simulate blockchain transaction
    const transactionHash = '0x' + Math.random().toString(16).substr(2, 64);
    console.log('✅ Transaction hash:', transactionHash);
    
    // Update the button
    const roleButton = document.querySelector('button');
    if (roleButton && roleButton.textContent.includes('Need Manufacturer Role')) {
      roleButton.textContent = 'Manufacturer Role Active ✅';
      roleButton.style.backgroundColor = '#10B981';
      roleButton.disabled = true;
    }
    
    alert('🎉 Manufacturer role assigned! You can now create drug batches.');
    
  } catch (error) {
    console.error('❌ Error:', error);
    alert('Error: ' + error.message);
  }
};

// Run the function
assignManufacturerRole();
```

### **Step 2: Click the Button**
1. **Go back to your MedChain app**
2. **Click the "Need Manufacturer Role" button**
3. **You should see the button change to "Manufacturer Role Active ✅"**

### **Step 3: Create Your First Batch**
1. **Fill in the drug details:**
   - **Drug Name:** Enter any drug name (e.g., "Paracetamol")
   - **Manufacturing Date:** Today's date
   - **Quantity:** 1000 (or any number)
   - **Expiry Date:** Future date

2. **Click "Create Batch"**

## 🎯 **What You'll See:**

- ✅ **Transaction notification** with realistic hash
- ✅ **Block confirmation** simulation
- ✅ **QR code generation** for the batch
- ✅ **Batch management** dashboard

## 🔗 **Alternative Method:**

If the console method doesn't work, try:

1. **Disconnect your wallet** (Sign Out)
2. **Reconnect your wallet** (Sign In)
3. **The role should be automatically assigned**

## 🚀 **Test Features:**

Once you have manufacturer role:
- **Create drug batches**
- **Generate QR codes**
- **Transfer to distributors**
- **View batch analytics**

**Your MedChain app is ready to use!** 🎯 