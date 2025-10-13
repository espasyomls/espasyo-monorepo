# Data Model: Docker Port Standardization

## Port Block Schema

### PortBlock Entity
Represents a reserved range of ports for a specific service category.

**Fields:**
- `name`: String (primary key) - Service category name (e.g., "frontend", "microservices")
- `range_start`: Integer - Starting port number (e.g., 3000)
- `range_end`: Integer - Ending port number (e.g., 3999)
- `description`: String - Purpose and usage guidelines
- `max_services`: Integer - Maximum recommended services in this block
- `reserved_ports`: Array<Integer> - Specific ports with special meaning

**Validation Rules:**
- `range_start` < `range_end`
- `range_end` - `range_start` >= 100 (minimum block size)
- No overlap with other blocks
- `range_start` >= 1024 (avoid system ports)
- `range_end` <= 65535 (valid port range)

**Relationships:**
- One-to-many with Service entities
- Referenced by PortAssignment entities

### Service Entity
Represents an individual Docker service that requires a port.

**Fields:**
- `name`: String (primary key) - Service name (e.g., "user-profile-service")
- `category`: String (foreign key to PortBlock.name) - Service category
- `current_port`: Integer - Currently assigned port
- `target_port`: Integer - Target port after standardization
- `status`: Enum - Migration status (planned, in_progress, completed, conflict)
- `dependencies`: Array<String> - Other services this depends on

**Validation Rules:**
- `current_port` and `target_port` must be within assigned block's range
- `category` must reference existing PortBlock
- No duplicate ports within same block

### PortAssignment Entity
Tracks the mapping of services to specific ports within blocks.

**Fields:**
- `service_name`: String (foreign key to Service.name)
- `port_number`: Integer - Assigned port
- `block_name`: String (foreign key to PortBlock.name)
- `assigned_date`: DateTime - When assignment was made
- `assigned_by`: String - Who made the assignment
- `notes`: String - Special considerations or constraints

**Validation Rules:**
- `port_number` must be within `block_name` range
- Unique `port_number` across all assignments
- `service_name` must exist in Service entity

## State Transitions

### Service Migration States
```
planned → in_progress → completed
    ↓         ↓
  conflict   conflict
```

**Transitions:**
- `planned` → `in_progress`: When migration begins
- `in_progress` → `completed`: When service successfully moved to target port
- `any` → `conflict`: When port conflict detected or migration fails

## Business Rules

### Port Allocation Rules
1. **Block Ownership**: Each service category owns its port block exclusively
2. **Sequential Assignment**: Ports within blocks assigned sequentially starting from range_start
3. **Reserved Ports**: Certain ports within blocks may be reserved for special services
4. **Gap Prevention**: Minimize gaps in port assignments within blocks
5. **Future Proofing**: Reserve blocks for anticipated future services

### Conflict Resolution Rules
1. **Detection**: Automatically detect port conflicts during validation
2. **Priority**: Existing services take priority over new services
3. **Migration Path**: Provide clear migration path for conflicting services
4. **Rollback**: Ability to rollback changes if conflicts cannot be resolved

### Validation Rules
1. **Range Compliance**: All ports must be within assigned block ranges
2. **Uniqueness**: No duplicate ports across all services
3. **Category Consistency**: Services must use ports from their assigned category block
4. **Dependency Awareness**: Consider service dependencies when assigning ports

## Data Flow

### Port Assignment Process
1. **Service Registration**: New service requests port assignment
2. **Category Determination**: Service assigned to appropriate category
3. **Port Selection**: Next available port in category block selected
4. **Conflict Check**: Validate no conflicts with existing assignments
5. **Assignment Record**: Create PortAssignment record
6. **Configuration Update**: Update Docker Compose files

### Migration Process
1. **Current State Analysis**: Inventory existing port assignments
2. **Target State Planning**: Plan moves to standardized ports
3. **Conflict Resolution**: Resolve any identified conflicts
4. **Gradual Migration**: Move services to new ports incrementally
5. **Validation**: Verify all services work with new assignments