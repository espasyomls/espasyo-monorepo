# Research: Standardize Docker Ports

## Current State Analysis

### Existing Port Usage
Based on analysis of `espasyo-infrastructure/docker-compose.local.yml`:

**Current Services and Ports:**
- Frontend: 3000 (Next.js default)
- User Profile Service: 3001
- Agent Service: 3002
- Verification Service: 3003
- Property Service: 3004
- Geocoding Service: 3005
- Listing Service: 3006
- Document Service: 3007
- Media Service: 3008
- Search Service: 3009
- Notification Service: 3010
- eDSL: 8080
- Redis: 6379
- LocalStack: 4566
- PostgreSQL: 5432 (internal)

**Planned Monitoring Services:**
- Prometheus: 9090
- Grafana: 3001 (conflicts with User Profile!)
- Node Exporter: 9100

### Identified Issues
1. **Port Conflicts**: Grafana wants port 3001 but User Profile Service already uses it
2. **No Standardization**: Services use arbitrary ports without clear grouping
3. **Limited Scalability**: No reserved ranges for future services

## Research Findings

### Decision: Port Block Allocation Strategy
**Chosen Approach**: Allocate 1000-port blocks to each service category for future scalability

**Rationale**:
- 1000 ports per block provides ample room for growth (up to 100 services per category)
- Clear separation prevents conflicts
- Easy to remember and document
- Aligns with common Docker port allocation patterns

**Alternatives Considered**:
- Smaller blocks (100 ports): Too restrictive for microservices architecture
- Larger blocks (10,000 ports): Wasteful and harder to manage
- Dynamic port allocation: More complex, harder to debug and document

### Decision: Service Category Definitions
**Chosen Categories**:
- Frontend (3000-3999): User-facing web applications
- Microservices (4000-4999): Business logic services
- eDSL (5000-5999): Extensible Digital Service Layer
- Monitoring (6000-6999): Observability and metrics
- AWS Services (7000-7999): Cloud service emulations
- Databases (8000-8999): Data storage services
- Development Tools (9000-9999): Development and testing tools
- Infrastructure (2000-2999): Core infrastructure services

**Rationale**:
- Logical grouping based on service purpose
- Matches existing service architecture
- Reserves space for future categories
- Avoids system ports (< 1024) and common application ports

### Decision: Grafana Port Resolution
**Chosen Solution**: Move Grafana to 6001 (within monitoring block)

**Rationale**:
- Maintains monitoring services in their designated block
- Avoids conflict with existing User Profile Service
- Follows the new standardization scheme
- Minimal impact on monitoring setup

**Alternatives Considered**:
- Move User Profile Service: Would break existing integrations
- Use dynamic ports: Reduces predictability and debuggability

### Decision: Implementation Approach
**Chosen Approach**: Gradual migration with backward compatibility

**Rationale**:
- Allows testing of changes without breaking existing setups
- Enables rollback if issues discovered
- Follows infrastructure best practices

**Validation Strategy**:
- Port conflict detection script
- Docker Compose validation
- Integration testing with existing services

## System Port Considerations

### Safe Port Ranges
- **System Ports** (0-1023): Avoid - require root privileges
- **User Ports** (1024-49151): Safe for applications
- **Dynamic Ports** (49152-65535): Avoid for predictability

### Reserved Common Ports
- 22: SSH
- 80/443: HTTP/HTTPS
- 5432: PostgreSQL (internal use OK)
- 6379: Redis (internal use OK)
- 8080: Common web port (already in use)

**Conclusion**: All proposed blocks (2000-9999) are in safe ranges and avoid common conflicts.

## Migration Strategy

### Phase 1: Documentation
- Create port allocation registry
- Document migration plan
- Update service documentation

### Phase 2: Implementation
- Update Docker Compose files
- Modify monitoring setup scripts
- Update LocalStack configuration

### Phase 3: Validation
- Test all services start without conflicts
- Verify integrations still work
- Update CI/CD if needed

### Phase 4: Cleanup
- Remove old port references
- Update documentation
- Communicate changes to team