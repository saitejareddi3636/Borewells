# Firebase Firestore Security Rules

## Overview
These security rules implement role-based access control and organization-based data isolation for the ServiceMaster application. They ensure that users can only access data within their organization and according to their role (Admin or Driver).

## Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper Functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isAdmin() {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    function isDriver() {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'driver';
    }
    
    function getUserOrganization() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.organizationId;
    }
    
    function isSameOrganization(orgId) {
      return isAuthenticated() && getUserOrganization() == orgId;
    }
    
    function isAssignedDriver(driverId) {
      return isAuthenticated() && request.auth.uid == driverId;
    }
    
    // Users Collection
    match /users/{userId} {
      // Users can read their own profile
      allow read: if isAuthenticated() && request.auth.uid == userId;
      
      // Admins can read all users in their organization
      allow read: if isAdmin() && isSameOrganization(resource.data.organizationId);
      
      // Allow user creation during signup
      allow create: if isAuthenticated() && request.auth.uid == userId;
      
      // Users can update their own profile
      allow update: if isAuthenticated() && request.auth.uid == userId;
      
      // Admins can update users in their organization
      allow update: if isAdmin() && isSameOrganization(resource.data.organizationId);
      
      // Only admins can delete users in their organization
      allow delete: if isAdmin() && isSameOrganization(resource.data.organizationId);
    }
    
    // Vehicles Collection
    match /vehicles/{vehicleId} {
      // Admins can read all vehicles in their organization
      allow read: if isAdmin() && isSameOrganization(resource.data.organizationId);
      
      // Drivers can read vehicles assigned to them
      allow read: if isDriver() && 
                     isSameOrganization(resource.data.organizationId) &&
                     isAssignedDriver(resource.data.driverId);
      
      // Only admins can create vehicles
      allow create: if isAdmin() && isSameOrganization(request.resource.data.organizationId);
      
      // Admins can update vehicles in their organization
      allow update: if isAdmin() && isSameOrganization(resource.data.organizationId);
      
      // Drivers can update only hours and km for their assigned vehicles
      allow update: if isDriver() && 
                       isSameOrganization(resource.data.organizationId) &&
                       isAssignedDriver(resource.data.driverId) &&
                       request.resource.data.diff(resource.data).affectedKeys().hasOnly(['hours', 'km', 'updatedAt']);
      
      // Only admins can delete vehicles
      allow delete: if isAdmin() && isSameOrganization(resource.data.organizationId);
    }
    
    // Maintenance Items Collection
    match /maintenanceItems/{itemId} {
      // Get vehicle organization for this maintenance item
      function getVehicleOrg() {
        return get(/databases/$(database)/documents/vehicles/$(resource.data.vehicleId)).data.organizationId;
      }
      
      function getVehicleOrgFromRequest() {
        return get(/databases/$(database)/documents/vehicles/$(request.resource.data.vehicleId)).data.organizationId;
      }
      
      // Admins can read all maintenance items for vehicles in their organization
      allow read: if isAdmin() && isSameOrganization(getVehicleOrg());
      
      // Drivers can read maintenance items for their assigned vehicles
      allow read: if isDriver() && 
                     isSameOrganization(getVehicleOrg()) &&
                     isAssignedDriver(get(/databases/$(database)/documents/vehicles/$(resource.data.vehicleId)).data.driverId);
      
      // Admins can create maintenance items for vehicles in their organization
      allow create: if isAdmin() && isSameOrganization(getVehicleOrgFromRequest());
      
      // Admins can update maintenance items
      allow update: if isAdmin() && isSameOrganization(getVehicleOrg());
      
      // Drivers can update status and completion fields for their assigned vehicles
      allow update: if isDriver() && 
                       isSameOrganization(getVehicleOrg()) &&
                       isAssignedDriver(get(/databases/$(database)/documents/vehicles/$(resource.data.vehicleId)).data.driverId) &&
                       request.resource.data.diff(resource.data).affectedKeys()
                         .hasOnly(['status', 'lastPerformed', 'currentKm', 'currentHours', 'updatedAt']);
      
      // Only admins can delete maintenance items
      allow delete: if isAdmin() && isSameOrganization(getVehicleOrg());
    }
    
    // Maintenance Logs Collection
    match /maintenanceLogs/{logId} {
      // Get vehicle organization for this maintenance log
      function getLogVehicleOrg() {
        return get(/databases/$(database)/documents/vehicles/$(resource.data.vehicleId)).data.organizationId;
      }
      
      function getLogVehicleOrgFromRequest() {
        return get(/databases/$(database)/documents/vehicles/$(request.resource.data.vehicleId)).data.organizationId;
      }
      
      // Admins can read all logs for vehicles in their organization
      allow read: if isAdmin() && isSameOrganization(getLogVehicleOrg());
      
      // Drivers can read logs for their assigned vehicles
      allow read: if isDriver() && 
                     isSameOrganization(getLogVehicleOrg()) &&
                     isAssignedDriver(get(/databases/$(database)/documents/vehicles/$(resource.data.vehicleId)).data.driverId);
      
      // Admins can create logs for vehicles in their organization
      allow create: if isAdmin() && isSameOrganization(getLogVehicleOrgFromRequest());
      
      // Drivers can create logs for their assigned vehicles
      allow create: if isDriver() && 
                       isSameOrganization(getLogVehicleOrgFromRequest()) &&
                       isAssignedDriver(get(/databases/$(database)/documents/vehicles/$(request.resource.data.vehicleId)).data.driverId) &&
                       request.resource.data.performedBy == request.auth.uid;
      
      // Admins can update logs
      allow update: if isAdmin() && isSameOrganization(getLogVehicleOrg());
      
      // Users can update their own logs
      allow update: if isAuthenticated() && 
                       resource.data.performedBy == request.auth.uid &&
                       isSameOrganization(getLogVehicleOrg());
      
      // Only admins can delete logs
      allow delete: if isAdmin() && isSameOrganization(getLogVehicleOrg());
    }
    
    // Organizations Collection (if you add one for organization metadata)
    match /organizations/{orgId} {
      // Users can read their own organization
      allow read: if isAuthenticated() && isSameOrganization(orgId);
      
      // Only admins can update their organization
      allow update: if isAdmin() && isSameOrganization(orgId);
    }
    
    // Deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

## Rule Explanation

### Authentication
All operations require authentication (`isAuthenticated()`). Anonymous access is not permitted.

### Role-Based Access

#### Admin Users
- **Read**: All data within their organization
- **Write**: Full CRUD operations on vehicles, maintenance items, and logs within their organization
- **Users**: Can manage users in their organization

#### Driver Users
- **Read**: Only vehicles and maintenance items assigned to them
- **Write**: 
  - Update vehicle hours/km for assigned vehicles
  - Create maintenance logs for assigned vehicles
  - Update maintenance item status for assigned vehicles
  - Update their own profile

### Organization Isolation
All data access is restricted by `organizationId`:
- Users can only access data from their own organization
- Cross-organization data access is prevented
- Each organization's data is completely isolated

### Specific Permissions

#### Vehicles
- **Create**: Admin only
- **Read**: Admin (all in org), Driver (assigned only)
- **Update**: Admin (full), Driver (hours/km only for assigned)
- **Delete**: Admin only

#### Maintenance Items
- **Create**: Admin only
- **Read**: Admin (all in org), Driver (assigned vehicles only)
- **Update**: Admin (full), Driver (status/completion for assigned)
- **Delete**: Admin only

#### Maintenance Logs
- **Create**: Admin (all), Driver (own vehicles)
- **Read**: Admin (all in org), Driver (assigned vehicles)
- **Update**: Admin (all), User (own logs)
- **Delete**: Admin only

## Indexes Required

For optimal query performance, create these composite indexes in Firestore:

```
Collection: vehicles
Fields: organizationId (Ascending), status (Ascending)

Collection: vehicles
Fields: organizationId (Ascending), driverId (Ascending)

Collection: maintenanceItems
Fields: vehicleId (Ascending), status (Ascending)

Collection: maintenanceItems
Fields: vehicleId (Ascending), nextDue (Ascending)

Collection: maintenanceLogs
Fields: vehicleId (Ascending), date (Descending)

Collection: maintenanceLogs
Fields: vehicleId (Ascending), performedBy (Ascending), date (Descending)
```

## Deployment

### Using Firebase Console
1. Go to Firebase Console > Firestore Database
2. Click on "Rules" tab
3. Copy and paste the security rules above
4. Click "Publish"

### Using Firebase CLI
1. Save rules to `firestore.rules` file in project root
2. Run: `firebase deploy --only firestore:rules`

## Testing Rules

### Using Firebase Emulator
```bash
firebase emulators:start --only firestore
```

### Test Cases
1. **Admin Access**: Verify admin can access all org data
2. **Driver Access**: Verify driver can only access assigned vehicles
3. **Organization Isolation**: Verify users cannot access other org data
4. **Write Permissions**: Verify role-specific write restrictions
5. **Unauthenticated Access**: Verify all unauthenticated requests are denied

## Security Best Practices

1. **Never disable rules**: Always have rules enabled for production
2. **Regular audits**: Review access logs regularly
3. **Principle of least privilege**: Grant minimum necessary permissions
4. **Test thoroughly**: Test rules with Firebase Emulator before deployment
5. **Monitor**: Use Firebase Console to monitor denied requests
6. **Version control**: Keep rules in version control
7. **Document changes**: Document all rule changes and reasons

## Common Issues

### Issue: Permission Denied Error
**Cause**: User doesn't have required permissions
**Solution**: Verify user role and organization in Firestore

### Issue: Slow Queries
**Cause**: Missing composite indexes
**Solution**: Create required indexes in Firestore Console

### Issue: Can't Read Assigned Vehicle
**Cause**: driverId not set correctly
**Solution**: Ensure vehicle.driverId matches user.id

## Maintenance

Review and update these rules when:
- Adding new collections
- Changing data models
- Modifying user roles
- Adding new features
- Security requirements change

---

**Last Updated**: November 2025
**Version**: 1.0
**Status**: Production Ready
