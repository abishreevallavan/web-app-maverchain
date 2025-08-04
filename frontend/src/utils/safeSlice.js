/**
 * Safely slice a string with fallback for undefined/null values
 * @param {string} str - The string to slice
 * @param {number} start - Start index
 * @param {number} end - End index (optional)
 * @param {string} fallback - Fallback text if string is undefined/null
 * @returns {string} - Sliced string or fallback
 */
export const safeSlice = (str, start, end, fallback = 'Unknown') => {
  if (!str || typeof str !== 'string') return fallback;
  if (end !== undefined) {
    return str.slice(start, end);
  }
  return str.slice(start);
};

/**
 * Format an address with ellipsis for display
 * @param {string} address - The address to format
 * @param {number} startLength - Number of characters to show at start
 * @param {number} endLength - Number of characters to show at end
 * @param {string} fallback - Fallback text if address is undefined/null
 * @returns {string} - Formatted address
 */
export const formatAddress = (address, startLength = 6, endLength = 4, fallback = 'Unknown') => {
  if (!address || typeof address !== 'string') return fallback;
  if (address.length <= startLength + endLength) return address;
  return `${address.slice(0, startLength)}...${address.slice(-endLength)}`;
};

/**
 * Format a transaction hash for display
 * @param {string} hash - The transaction hash to format
 * @param {number} startLength - Number of characters to show at start
 * @param {number} endLength - Number of characters to show at end
 * @param {string} fallback - Fallback text if hash is undefined/null
 * @returns {string} - Formatted transaction hash
 */
export const formatTransactionHash = (hash, startLength = 10, endLength = 8, fallback = 'Unknown') => {
  if (!hash || typeof hash !== 'string') return fallback;
  if (hash.length <= startLength + endLength) return hash;
  return `${hash.slice(0, startLength)}...${hash.slice(-endLength)}`;
}; 