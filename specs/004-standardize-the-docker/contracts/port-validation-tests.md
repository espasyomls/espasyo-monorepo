# Port Validation Contract Tests

## Test Scenarios

### Valid Port Assignments
**Given** a service requests port assignment
**When** the port is within the service's category block
**And** the port is not already assigned
**Then** the assignment should succeed

### Invalid Port Assignments - Out of Range
**Given** a service requests port assignment
**When** the port is outside the service's category block
**Then** the assignment should fail with "PORT_OUT_OF_RANGE" error

### Invalid Port Assignments - Conflict
**Given** a service requests port assignment
**When** the port is already assigned to another service
**Then** the assignment should fail with "PORT_CONFLICT" error

### Category Validation
**Given** a service belongs to category "microservices"
**When** it requests a port from the "frontend" block
**Then** the assignment should fail with "CATEGORY_MISMATCH" error

### Block Size Validation
**Given** a port block is defined
**When** the block size is less than 100 ports
**Then** the validation should fail with "INSUFFICIENT_BLOCK_SIZE" error

### Reserved Port Validation
**Given** a port is marked as reserved for a specific service
**When** a different service requests that port
**Then** the assignment should fail with "RESERVED_PORT_CONFLICT" error

### Maximum Services Validation
**Given** a port block has reached its maximum service limit
**When** a new service requests assignment in that block
**Then** the assignment should fail with "MAX_SERVICES_EXCEEDED" error

## Contract Test Implementation

### Port Block Validation Test
```bash
# Test: Valid range
validate_port_range 3000 3999  # Should return true

# Test: Invalid range (start >= end)
validate_port_range 4000 3000  # Should return false

# Test: System port range (below 1024)
validate_port_range 80 443     # Should return false

# Test: Overlapping ranges (adjacent blocks)
validate_port_range 3999 4000  # Should return false (overlaps with microservices)

# Test: Overlapping ranges (complete overlap)
validate_port_range 3000 4999  # Should return false (overlaps multiple blocks)

# Test: Insufficient block size (less than 100 ports)
validate_port_range 3000 3050  # Should return false

# Test: Invalid port numbers (above 65535)
validate_port_range 65000 66000  # Should return false

# Test: Reserved port conflict
validate_reserved_port 4566 "aws_services"  # Should return false (LocalStack gateway)
```

### Service Assignment Test
```bash
# Test: Valid assignment
assign_port "user-profile-service" 3001 "frontend"  # Should succeed

# Test: Invalid assignment - wrong category
assign_port "user-profile-service" 4001 "microservices"  # Should fail

# Test: Invalid assignment - port conflict
assign_port "agent-service" 3001 "frontend"  # Should fail (already assigned)

# Test: Invalid assignment - port outside any block
assign_port "test-service" 1500 "frontend"  # Should fail (port 1500 not in any block)

# Test: Category enforcement - microservice in frontend block
assign_port "verification-service" 3500 "frontend"  # Should fail (wrong category)

# Test: Reserved port assignment (only for designated service)
assign_port "grafana" 6001 "monitoring"  # Should succeed (reserved for Grafana)
assign_port "other-service" 6001 "monitoring"  # Should fail (reserved port)

# Test: Maximum services per block enforcement
# (After assigning 50 frontend services)
assign_port "service-51" 3999 "frontend"  # Should fail (exceeds max_services)
```

### Conflict Detection Test
```bash
# Test: No conflicts in valid assignments
detect_conflicts ["user-service:3001", "agent-service:4001", "grafana:6001"]
# Should return empty array

# Test: Port conflict detection
detect_conflicts ["user-service:3001", "agent-service:3001"]
# Should return [{"port": 3001, "services": ["user-service", "agent-service"]}]

# Test: Category violation detection
detect_category_violations ["frontend-service:4001"]  # 4001 is in microservices block
# Should return [{"service": "frontend-service", "port": 4001, "expected_category": "microservices", "actual_category": "frontend"}]

# Test: Block overlap detection
validate_block_overlap [{"name": "test1", "start": 3000, "end": 3500}, {"name": "test2", "start": 3400, "end": 4000}]
# Should return [{"blocks": ["test1", "test2"], "overlap_start": 3400, "overlap_end": 3500}]

# Test: Reserved port conflicts
detect_reserved_conflicts ["custom-service:4566"]  # 4566 reserved for LocalStack
# Should return [{"port": 4566, "service": "custom-service", "reserved_for": "LocalStack gateway"}]
```
```bash
# Test: Parse docker-compose file
# Test: Extract all port mappings
# Test: Validate each port against schema
# Test: Report conflicts and violations

validate_docker_compose "espasyo-infrastructure/docker-compose.local.yml"
# Expected: No conflicts, all ports within assigned blocks
```

## Integration Test Scenarios

### Full System Validation
**Given** all Docker Compose files are loaded
**When** port validation is run across all services
**Then** no conflicts should be detected
**And** all services should be within their assigned blocks

### Migration Validation
**Given** a service is moved to a new standardized port
**When** the Docker Compose file is updated
**And** the service is restarted
**Then** the service should be accessible on the new port
**And** dependent services should continue to work

### Monitoring Setup Validation
**Given** monitoring services are configured
**When** Grafana is assigned to port 6001
**Then** no conflict with User Profile Service (port 3001)
**And** monitoring dashboard is accessible