# Data Model: Create 3 Dashboard Pages

**Date**: October 5, 2025
**Feature**: 002-create-3-dashboard

## Entities

### User
**Purpose**: Represents system users with role-based access and personalization

**Fields**:
- `id`: string (UUID) - Primary identifier
- `email`: string - Authentication identifier
- `name`: string - Display name
- `role`: UserRole - Access level (administrator, agent, user)
- `profileComplete`: boolean - Whether user has completed profile setup
- `createdAt`: DateTime - Account creation timestamp
- `lastLoginAt`: DateTime - Last authentication timestamp
- `preferences`: UserPreferences - Dashboard customization settings

**Validation Rules**:
- `email`: Must be valid email format, unique across system
- `role`: Must be one of defined UserRole values
- `name`: Required, 2-100 characters
- `profileComplete`: Defaults to false, set to true after profile completion

**Relationships**:
- One-to-one with UserRole (composition)
- One-to-many with Dashboard (user can access one dashboard at a time)

### UserRole
**Purpose**: Defines permissions and determines accessible dashboard and features

**Fields**:
- `id`: string (UUID) - Primary identifier
- `name`: string - Role name (Administrator, Agent, Regular User)
- `permissions`: Permission[] - Array of granted permissions
- `dashboardPath`: string - Route path for role's dashboard
- `description`: string - Human-readable role description

**Validation Rules**:
- `name`: Must be one of predefined role names
- `dashboardPath`: Must be valid Next.js route path
- `permissions`: Array of valid permission strings

**Relationships**:
- One-to-one with User (inverse of User.role)
- One-to-one with Dashboard (determines which dashboard is accessible)

### Dashboard
**Purpose**: Role-specific interface containing relevant widgets, metrics, and navigation

**Fields**:
- `id`: string (UUID) - Primary identifier
- `role`: UserRole - Associated user role
- `title`: string - Dashboard display title
- `widgets`: DashboardWidget[] - Array of dashboard components
- `navigation`: NavigationItem[] - Sidebar navigation structure
- `metrics`: DashboardMetric[] - Key performance indicators
- `customizable`: boolean - Whether users can customize layout

**Validation Rules**:
- `role`: Must reference valid UserRole
- `widgets`: Array of valid widget configurations
- `navigation`: Must include required navigation items for role

**Relationships**:
- One-to-one with UserRole (inverse of UserRole.dashboardPath)
- Many-to-one with User (users access their role's dashboard)

## Supporting Types

### UserPreferences
```typescript
interface UserPreferences {
  theme: 'light' | 'dark' | 'system';
  language: string;
  notifications: boolean;
  dashboardLayout: 'grid' | 'list';
  itemsPerPage: number;
}
```

### Permission
```typescript
type Permission =
  | 'admin.system_metrics'
  | 'admin.user_management'
  | 'admin.content_moderation'
  | 'admin.platform_settings'
  | 'agent.listings_manage'
  | 'agent.client_communication'
  | 'agent.analytics_view'
  | 'agent.commission_tracking'
  | 'user.searches_save'
  | 'user.properties_favorite'
  | 'user.account_settings'
  | 'user.viewing_history';
```

### DashboardWidget
```typescript
interface DashboardWidget {
  id: string;
  type: 'metric' | 'chart' | 'list' | 'action';
  title: string;
  position: { x: number; y: number; width: number; height: number };
  config: Record<string, any>;
  required: boolean;
}
```

### NavigationItem
```typescript
interface NavigationItem {
  id: string;
  label: string;
  path: string;
  icon: string;
  children?: NavigationItem[];
  required: boolean;
}
```

### DashboardMetric
```typescript
interface DashboardMetric {
  id: string;
  label: string;
  value: number | string;
  trend: 'up' | 'down' | 'neutral';
  format: 'number' | 'currency' | 'percentage';
  timeframe: string;
}
```

## State Transitions

### User Role Assignment
1. **Registration**: User registers → role = 'user' (default)
2. **Self-Selection**: User chooses role during onboarding → pending approval
3. **Admin Approval**: Administrator reviews → role updated
4. **Role Change**: Administrator changes user role → dashboard access updated

### Dashboard Access
1. **Login**: User authenticates → redirect to role-based dashboard
2. **Role Check**: Middleware validates access → allow/deny
3. **Unauthorized Access**: Wrong role attempts access → generic error message

## Data Flow

1. **Authentication**: NextAuth.js handles login, populates session with user + role
2. **Route Protection**: Middleware checks session.role against route requirements
3. **Dashboard Loading**: Server component fetches user-specific data based on role
4. **Real-time Updates**: WebSocket/API calls update dashboard metrics
5. **State Persistence**: Zustand stores user preferences and temporary state

## Validation Constraints

- Users can only have one active role at a time
- Dashboard widgets must be role-appropriate
- Navigation items must respect permission boundaries
- Metrics must be calculable for the user's role scope
- Preferences must be persistable and retrievable