
# Complete Docker Deployment Fixes for Next.js Supabase SaaS Kit

This document provides a comprehensive overview of all the fixes that have been applied to resolve Docker deployment issues for the Next.js Supabase SaaS Kit.

## Summary of Issues and Fixes

### 1. Service Dependency Issue (RESOLVED)

**Problem**: The `supabase-studio` service was trying to depend on an undefined service called `supabase`.

**Solution**: Updated the dependencies to reference the correct service names:
- `supabase-meta` (metadata service)
- `supabase-kong` (API gateway)

**Files Modified**:
- `docker-compose.yml`

### 2. Inbucket Image Version Issue (RESOLVED)

**Problem**: The Inbucket Docker image version `v3.0.3` does not exist on Docker Hub.

**Solution**: Changed the image version to `latest` to use the most recent stable version.

**Files Modified**:
- `docker-compose.yml`

### 3. Supabase Studio Image Version Issue (RESOLVED)

**Problem**: The Supabase Studio Docker image version `2024-04-10-65b9a96` does not exist on Docker Hub.

**Solution**: Changed the image version to `latest` to use the most recent stable version.

**Files Modified**:
- `docker-compose.yml`

### 4. Next.js Dependency Conflict Issue (RESOLVED)

**Problem**: Dependency conflict between `next@14.2.5` and `next-contentlayer@0.3.4` which requires `next@^12 || ^13`.

**Solution**: Added `--legacy-peer-deps` flag to the npm install command in the Dockerfile to ignore peer dependency conflicts.

**Files Modified**:
- `Dockerfile`

## Patch Files Available

All fixes have been provided as patch files for easy application:

1. `docker-compose-fix.patch` - Fixes service dependencies and Inbucket image
2. `docker-compose-override-fix.patch` - Fixes environment variables in override file
3. `studio-fix.patch` - Fixes Supabase Studio image version
4. `dockerfile-npm-fix.patch` - Fixes Next.js dependency conflict

## How to Apply the Fixes

### Option 1: Apply Patch Files

```bash
# Apply all patches
git apply docker-compose-fix.patch
git apply docker-compose-override-fix.patch
git apply studio-fix.patch
git apply dockerfile-npm-fix.patch
```

### Option 2: Manual Fixes

1. **Fix docker-compose.yml**:
   - Change `supabase-studio` dependencies from `supabase` to `supabase-meta` and `supabase-kong`
   - Change Inbucket image from `v3.0.3` to `latest`
   - Change Supabase Studio image from `2024-04-10-65b9a96` to `latest`

2. **Fix Dockerfile**:
   - Change `RUN npm install` to `RUN npm install --legacy-peer-deps`

## Verification

After applying the fixes, verify the configuration:

```bash
# Check Docker Compose configuration
docker compose config

# Build and start the services
docker compose up -d --build
```

## Deployment Instructions

1. **Build and start the services**:
   ```bash
   docker compose up -d --build
   ```

2. **Access the services**:
   - Next.js application: `http://localhost:3000`
   - Supabase Studio: `http://localhost:54323`
   - Supabase database: `postgresql://postgres:postgres@localhost:54322/postgres`

3. **Stop the services**:
   ```bash
   docker compose down
   ```

## Troubleshooting

If you encounter any issues:

1. **Check container logs**:
   ```bash
   docker compose logs
   ```

2. **Rebuild specific services**:
   ```bash
   docker compose build nextjs
   docker compose up -d nextjs
   ```

3. **Clean and rebuild**:
   ```bash
   docker compose down -v
   docker compose up -d --build
   ```

## Additional Notes

- All Supabase services are configured with proper health checks and dependencies
- The Next.js application is built in a multi-stage Docker build for optimal performance
- Environment variables are properly configured for both development and production
- The `.dockerignore` file ensures only necessary files are included in the build context

The deployment should now work without any dependency or configuration issues.
