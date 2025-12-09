
# Docker Compose Fix Guide

## Issue Description

The user is encountering the following error when trying to run `docker-compose up -d --build`:

```
service "supabase-studio" depends on undefined service "supabase": invalid compose project
```

## Root Cause

The original repository contains references to a service named "supabase" in the `supabase-studio` service configuration. However, the repository doesn't actually define a "supabase" service - instead, it uses individual Supabase services like `supabase-kong`, `supabase-meta`, `supabase-db`, etc.

## Required Fixes

The following changes need to be made to the `docker-compose.yml` file:

### 1. Fix supabase-studio environment variables

**Original (incorrect):**
```yaml
environment:
  STUDIO_PG_META_URL: http://supabase:8080
  SUPABASE_URL: http://supabase:54321
```

**Fixed:**
```yaml
environment:
  STUDIO_PG_META_URL: http://supabase-meta:8080
  SUPABASE_URL: http://supabase-kong:8000
```

### 2. Fix supabase-studio dependencies

**Original (incorrect):**
```yaml
depends_on:
  supabase:
    condition: service_started
```

**Fixed:**
```yaml
depends_on:
  supabase-meta:
    condition: service_started
  supabase-kong:
    condition: service_started
```

## Complete Solution

Here are the exact changes needed in the `docker-compose.yml` file:

1. **Line 58**: Change `http://supabase:8080` to `http://supabase-meta:8080`
2. **Line 60**: Change `http://supabase:54321` to `http://supabase-kong:8000`
3. **Line 63**: Change `supabase:` to `supabase-meta:` and `supabase-kong:`

## Additional Recommendations

1. **Remove version attributes**: The `version: '3.8'` attributes in both `docker-compose.yml` and `docker-compose.override.yml` should be removed as they are obsolete in newer Docker Compose versions.

2. **Use `docker compose` instead of `docker-compose`**: Modern Docker installations use `docker compose` (without hyphen) as the command.

3. **Service startup order**: The Supabase services need to start in a specific order:
   - `supabase-db` first (database)
   - Then `supabase-auth`, `supabase-rest`, `supabase-realtime`, `supabase-storage` (API services)
   - Then `supabase-meta` (metadata service)
   - Then `supabase-kong` (API gateway)
   - Finally `supabase-studio` (admin interface)

## Inbucket Image Fix

An additional issue was discovered: the Inbucket Docker image version `v3.0.3` does not exist on Docker Hub. This needs to be changed to a valid version.

**Original (incorrect):**
```yaml
supabase-inbucket:
  image: inbucket/inbucket:v3.0.3
```

**Fixed:**
```yaml
supabase-inbucket:
  image: inbucket/inbucket:latest
```

This change ensures that the latest stable version of Inbucket is used, which is always available and maintained.

## Supabase Studio Image Fix

Another issue was discovered: the Supabase Studio Docker image version `2024-04-10-65b9a96` does not exist on Docker Hub.

**Original (incorrect):**
```yaml
supabase-studio:
  image: supabase/studio:2024-04-10-65b9a96
```

**Fixed:**
```yaml
supabase-studio:
  image: supabase/studio:latest
```

This change ensures that the latest stable version of Supabase Studio is used, which is always available and maintained.

## Next.js Dependency Conflict Fix

A dependency conflict was discovered during the Docker build process. The `next-contentlayer@0.3.4` package requires `next@^12 || ^13` as a peer dependency, but the project uses `next@14.2.5`. This causes npm to fail with an ERESOLVE error.

**Original (incorrect):**
```dockerfile
RUN npm install
```

**Fixed:**
```dockerfile
RUN npm install --legacy-peer-deps
```

This change tells npm to ignore peer dependency conflicts and proceed with the installation, which is a common practice for Docker builds where you want to ensure the build completes successfully.

## Verification

After making these changes, you can verify the configuration is correct by running:

```bash
docker compose config
```

This should output the complete configuration without any errors.

## Running the Application

To start the application:

```bash
docker compose up -d --build
```

To stop the application:

```bash
docker compose down
```

## Port Mapping

The services are exposed on the following ports:

- Next.js application: `http://localhost:3000`
- Supabase Studio: `http://localhost:54323`
- Supabase Kong API Gateway: `http://localhost:54321`
- Supabase Kong Admin: `http://localhost:54324`
- Supabase Database: `localhost:54322`
- Supabase Auth: `localhost:54321`
- Supabase Rest API: `localhost:54320`
- Supabase Realtime: `localhost:4000`
- Supabase Storage: `localhost:5000`
- Inbucket (email testing): `http://localhost:54325` (SMTP), `http://localhost:54326` (web UI)
