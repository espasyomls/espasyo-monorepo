# Quickstart: Docker Port Standardization

## Overview
This guide provides step-by-step instructions for implementing and validating Docker port standardization across the Espasyo MLS project.

## Prerequisites
- Docker and Docker Compose installed
- Access to espasyo-infrastructure repository
- Basic understanding of Docker port mapping

## Port Block Reference

| Category | Port Block | Purpose | Key Services |
|----------|------------|---------|--------------|
| Frontend | 3000-3999 | User-facing web apps | Next.js applications |
| Microservices | 4000-4999 | Business logic services | User Profile, Agent, Verification, etc. |
| eDSL | 5000-5999 | Service orchestration | API Gateway, Service Layer |
| Monitoring | 6000-6999 | Observability | Prometheus, Grafana, Node Exporter |
| AWS Services | 7000-7999 | Cloud emulation | LocalStack |
| Databases | 8000-8999 | Data storage | PostgreSQL, Redis |
| Dev Tools | 9000-9999 | Development aids | pgAdmin, testing tools |
| Infrastructure | 2000-2999 | Core systems | Load balancers, proxies |

## Implementation Steps

### Step 1: Validate Current Setup
```bash
# Check current port usage
cd /home/boggss/espasyoMLS/espasyo-infrastructure
docker ps --format "table {{.Names}}\t{{.Ports}}"

# Verify no conflicts exist
docker-compose -f docker-compose.local.yml config
```

### Step 2: Update Docker Compose Files

#### Infrastructure Services
Edit `espasyo-infrastructure/docker-compose.local.yml`:

```yaml
# Current → Standardized
user-profile-service:
  ports:
    - "3001:3001"  # ✓ Already correct

agent-service:
  ports:
    - "3002:3002"  # ✓ Already correct

# ... other microservices remain in 3000s for now

# Move eDSL to 5000 block
edsl:
  ports:
    - "5000:8080"  # Changed from 8080 to 5000

# Monitoring services (when added)
prometheus:
  ports:
    - "9090:9090"  # ✓ Already in monitoring block

grafana:
  ports:
    - "6001:3000"  # Changed from 3001 to 6001 (moved to monitoring block)
```

#### Monitoring Setup
Update `espasyo-infrastructure/monitoring/setup-monitoring.sh`:

```bash
# Change Grafana port from 3001 to 6001
grafana:
  ports:
    - "6001:3000"  # Avoids conflict with user-profile-service
```

### Step 3: Update Service Dependencies

#### Update Service URLs
If services reference each other by hardcoded ports, update them:

```yaml
# In service configurations
USER_PROFILE_SERVICE_URL=http://user-profile-service:3001
EDSL_URL=http://edsl:5000  # Updated from 8080
GRAFANA_URL=http://grafana:6001  # Updated from 3001
```

#### Update Documentation
Update any documentation referencing old ports:
- README files
- API documentation
- Deployment guides

### Step 4: Test Changes

#### Start Services
```bash
# Start infrastructure services
cd /home/boggss/espasyoMLS/espasyo-infrastructure
docker-compose -f docker-compose.local.yml up -d

# Verify all services started
docker ps
```

#### Validate Port Assignments
```bash
# Check that services are on correct ports
curl http://localhost:3001/health  # User Profile
curl http://localhost:5000/health  # eDSL (moved from 8080)

# Test monitoring (when implemented)
curl http://localhost:6001/  # Grafana (moved from 3001)
```

#### Test Integrations
```bash
# Test that dependent services still work
# Example: Test frontend can reach backend services
curl http://localhost:3000/api/health
```

### Step 5: Update Development Environment

#### Update .env files
```bash
# espasyo-frontend/.env.local
NEXT_PUBLIC_EDSL_URL=http://localhost:5000

# Update any hardcoded port references
```

#### Update Docker Development Scripts
If you have development scripts that reference specific ports, update them to use the new standardized ports.

### Step 6: Validation Checklist

- [ ] All services start without port conflicts
- [ ] Frontend can communicate with backend services
- [ ] Monitoring dashboard accessible on new port
- [ ] API endpoints respond correctly
- [ ] No breaking changes to existing functionality
- [ ] Documentation updated with new ports

## Troubleshooting

### Port Conflicts
```bash
# Check what's using a port
lsof -i :3001

# Find conflicting containers
docker ps --filter "publish=3001"
```

### Service Won't Start
```bash
# Check service logs
docker logs espasyo-user-profile

# Validate docker-compose syntax
docker-compose -f docker-compose.local.yml config
```

### Integration Issues
```bash
# Test service connectivity
docker exec espasyo-user-profile curl http://edsl:5000/health

# Check network connectivity
docker network ls
docker network inspect espasyo-infrastructure_espasyo-network
```

## Rollback Plan

If issues arise, rollback by reverting Docker Compose changes:

```bash
# Revert eDSL port
edsl:
  ports:
    - "8080:8080"  # Back to original

# Revert Grafana port
grafana:
  ports:
    - "3001:3000"  # Back to original (if needed)
```

## Future Considerations

### Adding New Services
When adding new services, follow this process:

1. Determine service category
2. Find next available port in category block
3. Update Docker Compose file
4. Test integration
5. Update documentation

### Scaling Considerations
- Monitor port usage within blocks
- Plan for block expansion if needed
- Consider service discovery for large deployments

## Support

For issues with port standardization:
1. Check this quickstart guide
2. Review the implementation plan
3. Consult the feature specification
4. Create an issue with port conflict details