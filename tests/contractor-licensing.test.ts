import { describe, it, expect, beforeEach } from 'vitest';

describe('Contractor Licensing Contract', () => {
  // Mock state
  let mockState = {
    contractorLicenses: {},
    admin: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
    blockHeight: 100 // Mock current block height
  };
  
  // Mock tx-sender
  let txSender = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM';
  
  // Mock contract functions
  const registerContractor = (licenseNumber, specialization, validityPeriod) => {
    if (txSender !== mockState.admin) {
      return { type: 'err', value: 100 };
    }
    
    mockState.contractorLicenses[txSender] = {
      licenseNumber: licenseNumber,
      specialization: specialization,
      expirationBlock: mockState.blockHeight + validityPeriod,
      isActive: true
    };
    
    return { type: 'ok', value: true };
  };
  
  const isLicenseValid = (contractorId) => {
    const license = mockState.contractorLicenses[contractorId];
    if (!license) return false;
    
    return license.isActive && mockState.blockHeight < license.expirationBlock;
  };
  
  const revokeLicense = (contractorId) => {
    if (txSender !== mockState.admin) {
      return { type: 'err', value: 100 };
    }
    
    if (!mockState.contractorLicenses[contractorId]) {
      return { type: 'err', value: 101 };
    }
    
    mockState.contractorLicenses[contractorId].isActive = false;
    return { type: 'ok', value: true };
  };
  
  // Reset state before each test
  beforeEach(() => {
    mockState = {
      contractorLicenses: {},
      admin: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
      blockHeight: 100
    };
    txSender = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM';
  });
  
  it('should register a contractor successfully', () => {
    const result = registerContractor('LIC-001', 'GENERAL', 1000);
    expect(result.type).toBe('ok');
    expect(mockState.contractorLicenses[txSender]).toBeDefined();
    expect(mockState.contractorLicenses[txSender].isActive).toBe(true);
  });
  
  it('should fail to register a contractor if not admin', () => {
    txSender = 'ST2PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM'; // Different sender
    const result = registerContractor('LIC-001', 'GENERAL', 1000);
    expect(result.type).toBe('err');
    expect(result.value).toBe(100);
  });
  
  it('should correctly validate an active license', () => {
    registerContractor('LIC-001', 'GENERAL', 1000);
    expect(isLicenseValid(txSender)).toBe(true);
  });
  
  it('should correctly invalidate an expired license', () => {
    registerContractor('LIC-001', 'GENERAL', 1000);
    mockState.blockHeight = 1200; // Move past expiration
    expect(isLicenseValid(txSender)).toBe(false);
  });
  
  it('should revoke a license successfully', () => {
    registerContractor('LIC-001', 'GENERAL', 1000);
    const result = revokeLicense(txSender);
    expect(result.type).toBe('ok');
    expect(mockState.contractorLicenses[txSender].isActive).toBe(false);
    expect(isLicenseValid(txSender)).toBe(false);
  });
});
