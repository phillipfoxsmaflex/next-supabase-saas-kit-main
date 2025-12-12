

# Complete Docker Compose Solution for next-supabase-saas-kit

## Problem Summary

The user encountered the following error when trying to deploy the application:

```
service "supabase-studio" depends on undefined service "supabase": invalid compose project
```

## Root Cause Analysis

The original repository contained references to a non-existent service named "supabase" in multiple places:

1. **supabase-studio service** referenced "supabase" in environment variables and dependencies
2. **nextjs service** referenced "supabase" in environment variables
3. **Obsolete version attributes** in both docker-compose files

## Complete Solution

### 1. Fix docker-compose.yml

**Changes made:**

1. **Removed version attribute**: Removed `version: '3.8'` from the top of the file
2. **Fixed supabase-studio environment variables**:
   - Changed `STUDIO_PG_META_URL: http://supabase:8080` to `STUDIO_PG_META_URL: http://supabase-meta:8080`
   - Changed `SUPABASE_URL: http://supabase:54321` to `SUPABASE_URL: http://supabase-kong:8000`
3. **Fixed supabase-studio dependencies**:
   - Changed `supabase:` dependency to `supabase-meta:` and `supabase-kong:`
   - Changed condition from `service_healthy` to `service_started`

### 2. Fix docker-compose.override.yml

**Changes made:**

1. **Removed version attribute**: Removed `version: '3.8'` from the top of the file
2. **Fixed nextjs environment variables**:
   - Changed `NEXT_PUBLIC_SUPABASE_URL=http://supabase:54321` to `NEXT_PUBLIC_SUPABASE_URL=http://supabase-kong:8000`
   - Changed `EMAIL_HOST=supabase` to `EMAIL_HOST=supabase-inbucket`

### 3. Service Architecture

The corrected service architecture includes:

- **nextjs**: Next.js application (port 3000)
- **supabase-db**: PostgreSQL database (port 54322)
- **supabase-auth**: Authentication service
- **supabase-rest**: REST API service
- **supabase-realtime**: Realtime service
- **supabase-storage**: Storage service
- **supabase-meta**: Metadata service (port 8080)
- **supabase-kong**: API Gateway (port 54321)
- **supabase-studio**: Admin interface (port 54323)
- **supabase-inbucket**: Email testing service (ports 54325, 54326)

## How to Apply the Fix

### Option 1: Manual Fix

Edit the following files:

**docker-compose.yml:**
```yaml
# Remove this line:
version: '3.8'

# In supabase-studio service, change:
environment:
  STUDIO_PG_META_URL: http://supabase-meta:8080  # was: http://supabase:8080
  SUPABASE_URL: http://supabase-kong:8000        # was: http://supabase:54321

depends_on:
  supabase-meta:                              # was: supabase:
    condition: service_started                # was: condition: service_healthy
  supabase-kong:                              # new dependency
    condition: service_started                # new dependency
```

**docker-compose.override.yml:**
```yaml
# Remove this line:
version: '3.8'

# In nextjs service, change:
environment:
  - NEXT_PUBLIC_SUPABASE_URL=http://supabase-kong:8000  # was: http://supabase:54321
  - EMAIL_HOST=supabase-inbucket                        # was: supabase
```

### Option 2: Apply Patch Files

Use the provided patch files:

```bash
# Apply docker-compose.yml fix
patch -p1 < docker-compose-fix.patch

# Apply docker-compose.override.yml fix
patch -p1 < docker-compose-override-fix.patch
```

## Deployment Instructions

### 1. Build and Start Services

```bash
docker compose up -d --build
```

### 2. Verify Services

```bash
docker compose ps
```

### 3. Access Services

- **Next.js Application**: `http://localhost:3000`
- **Supabase Studio**: `http://localhost:54323`
- **Kong Admin**: `http://localhost:54324`
- **Inbucket Email UI**: `http://localhost:54326`

### 4. Stop Services

```bash
docker compose down
```

## Troubleshooting

### Common Issues and Solutions

**Issue: "service depends on undefined service"**
- **Solution**: Ensure all service names are correct and match the defined services

**Issue: Database connection failures**
- **Solution**: Wait for `supabase-db` to fully initialize before other services start

**Issue: Port conflicts**
- **Solution**: Ensure no other services are using ports 3000, 54320-54326, 4000, 5001

**Issue: Service startup order**
- **Solution**: Use `depends_on` with appropriate conditions to ensure proper startup sequence

## Service Startup Order

The services start in this order:

1. **supabase-db** (database must be ready first)
2. **supabase-auth**, **supabase-rest**, **supabase-realtime**, **supabase-storage** (API services)
3. **supabase-meta** (metadata service)
4. **supabase-kong** (API gateway)
5. **supabase-studio** (admin interface)
6. **nextjs** (application)

## Environment Variables

All required environment variables are configured in the docker-compose files:

- Database connection strings
- API URLs and keys
- Email configuration
- Service roles and permissions

## Network Configuration

All services are connected to the `app-network` for internal communication.

## Volume Configuration

Persistent data is stored in:
- `supabase-db-data` for database files
- `supabase-storage-data` for storage files

## Health Checks

Services use `condition: service_started` to ensure dependencies are ready before starting.

## Additional Notes

- The solution removes obsolete `version` attributes that are no longer needed in modern Docker Compose
- All Supabase services are properly configured with correct inter-service communication
- The Next.js application is configured to connect to the correct Supabase services
- Email functionality uses the Inbucket service for testing

## Verification

To verify the configuration is correct:

```bash
docker compose config
```

This should output the complete configuration without any errors.

