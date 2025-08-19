# Export Compliance Documentation for Nestory

## Overview

This document details Nestory's encryption usage and export compliance status for App Store submission and international distribution.

## Compliance Status

**✅ EXEMPT - No Export Compliance Required**

Nestory qualifies for export compliance exemption under the following provisions:
- Uses only standard iOS cryptographic libraries
- Encryption is limited to authentication and data protection
- No proprietary encryption algorithms
- Falls under exemption category 5D002 (mass market software)

## Encryption Usage

### What Nestory Uses Encryption For:

1. **HTTPS Communications** (Exempt)
   - Standard TLS/SSL for network requests
   - App Store Connect API communications
   - iCloud synchronization

2. **Data Protection** (Exempt)
   - iOS native file encryption (Data Protection API)
   - Keychain services for credential storage
   - Face ID/Touch ID authentication

3. **iCloud Sync** (Exempt)
   - CloudKit encryption (managed by Apple)
   - End-to-end encryption for user data

### What Nestory Does NOT Do:

- ❌ No proprietary encryption algorithms
- ❌ No encryption key exchanges with users
- ❌ No VPN or tunneling features
- ❌ No encrypted messaging features
- ❌ No cryptocurrency features

## Info.plist Configuration

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

This key indicates that Nestory uses only exempt encryption, eliminating the need for:
- Export compliance documentation
- Annual self-classification reports
- Encryption registration numbers (ERN)
- CCATS (Commodity Classification Automated Tracking System) filing

## French Encryption Declaration

**Status: Not Required**

Under French law (Article 30 of Law No. 2004-575), Nestory is exempt from declaration requirements because:
- Uses only standard cryptographic libraries
- No custom encryption implementation
- Falls under "free use" category for standard protocols

## U.S. Export Administration Regulations (EAR)

**Classification: 5D002**
- Mass market software with standard encryption
- Publicly available via App Store
- No license required for export

## Countries/Regions

Nestory can be distributed to all App Store territories except:
- None (no restrictions apply)

Standard Apple App Store availability restrictions still apply based on:
- Local App Store presence
- Regional content policies
- Sanctions and embargoes (automatically handled by Apple)

## Annual Self-Classification Report

**Not Required** ✅

Since Nestory uses only exempt encryption (HTTPS, standard iOS crypto), no annual self-classification report to the U.S. Bureau of Industry and Security (BIS) is required.

## Compliance Checklist

- [x] Uses only standard iOS cryptographic APIs
- [x] HTTPS/TLS for network communications only
- [x] No proprietary encryption algorithms
- [x] No encrypted communication between users
- [x] ITSAppUsesNonExemptEncryption set to false
- [x] Encryption limited to authentication and data protection
- [x] No export license required
- [x] No annual reporting required

## App Store Connect Questionnaire Answers

When submitting to App Store Connect, answer the encryption questions as follows:

1. **Does your app use encryption?**
   - Answer: YES (due to HTTPS and iOS data protection)

2. **Does your app qualify for any encryption exemptions?**
   - Answer: YES

3. **Does your app implement any encryption algorithms that are proprietary or not accepted as standard?**
   - Answer: NO

4. **Does your app implement any standard encryption algorithms instead of, or in addition to, using or accessing the encryption in iOS and macOS?**
   - Answer: NO

5. **Is your app using or accessing encryption for:**
   - Authentication: YES
   - Copy protection: NO
   - Secure channels: YES (HTTPS)
   - Other: NO

6. **Is your app available only in the U.S. and Canada?**
   - Answer: NO (available worldwide)

## Verification

To verify compliance status:

1. **Check Info.plist**:
   ```bash
   grep ITSAppUsesNonExemptEncryption App-Main/Info.plist
   ```

2. **Review encryption usage**:
   - All network calls use HTTPS
   - No custom crypto implementations
   - Standard iOS security features only

## Updates and Changes

If encryption usage changes in future versions:
1. Update this document
2. Modify Info.plist if needed
3. Update App Store Connect submission answers
4. Consult legal counsel if adding:
   - Custom encryption
   - User-to-user encrypted messaging
   - VPN features
   - Cryptocurrency features

## References

- [Apple's Export Compliance Overview](https://developer.apple.com/documentation/security/complying_with_encryption_export_regulations)
- [U.S. Export Administration Regulations](https://www.bis.doc.gov/index.php/regulations/export-administration-regulations-ear)
- [French Encryption Declaration Requirements](https://www.ssi.gouv.fr/en/regulation/cryptology/)
- [App Store Connect Help - Encryption](https://developer.apple.com/help/app-store-connect/manage-your-app/provide-export-compliance-documentation)

## Contact for Compliance Questions

For questions about Nestory's encryption compliance:
- Email: compliance@nestory.app
- Legal Counsel: [To be determined]

---

*Last Updated: August 2025*
*Document Version: 1.0*