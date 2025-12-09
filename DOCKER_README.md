

# Docker Deployment for Next.js Supabase SaaS Kit

This guide explains how to deploy the Next.js Supabase SaaS Kit using Docker Compose.

## Prerequisites

- Docker installed and running
- Docker Compose installed
- At least 4GB of RAM available for Docker containers

## Quick Start

### 1. Build and start the containers

```bash
docker-compose up -d --build
```

This will:
- Build the Next.js application
- Start Supabase services (PostgreSQL, Auth, REST API, Realtime, Storage)
- Start the Next.js application
- Set up all necessary networking

### 2. Access the application

- **Next.js App**: http://localhost:3000
- **Supabase Studio**: http://localhost:54323
- **Supabase REST API**: http://localhost:54320
- **Supabase Auth**: http://localhost:54321
- **Email Testing (Inbucket)**: http://localhost:54326

### 3. Stop the containers

```bash
docker-compose down
```

## Development Mode

For development with hot-reloading:

```bash
docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d --build
```

This will:
- Use the development configuration
- Mount your local code for hot-reloading
- Run the Next.js dev server

## Environment Variables

The Docker setup includes all required environment variables:

- **Supabase Configuration**: Pre-configured with local development keys
- **Email Configuration**: Uses Inbucket for email testing
- **Feature Flags**: Account and organization deletion enabled

## Customization

### Changing Environment Variables

To customize environment variables, create a `.env.local` file and add your variables. Then modify the `docker-compose.yml` file to include them.

### Adding Stripe Support

If you need Stripe support, add the following to your environment variables:

```yaml
environment:
  - NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=your_publishable_key
  - STRIPE_SECRET_KEY=your_secret_key
  - STRIPE_WEBHOOK_SECRET=your_webhook_secret
```

## Database Persistence

The setup includes persistent volumes for:
- PostgreSQL database data
- Supabase storage files

Your data will be preserved between container restarts.

## Troubleshooting

### Port Conflicts

If you get port conflicts, you can:
1. Stop other services using those ports
2. Modify the port mappings in `docker-compose.yml`

### Memory Issues

If Docker runs out of memory:
1. Increase Docker's memory allocation in settings
2. Reduce the number of services running simultaneously

### Build Issues

If the build fails:
1. Ensure you have enough disk space
2. Try `docker-compose build --no-cache`
3. Check the logs with `docker-compose logs`

## Production Deployment

For production deployment:

1. Use the main `docker-compose.yml` (not the override)
2. Set `NODE_ENV=production`
3. Configure proper secrets and keys
4. Set up proper SSL certificates
5. Consider using a reverse proxy like Nginx or Traefik

## Services Overview

| Service | Port | Description |
|---------|------|-------------|
| nextjs | 3000 | Next.js application |
| supabase-db | 54322 | PostgreSQL database |
| supabase-studio | 54323 | Supabase admin interface |
| supabase-auth | 54321 | Authentication service |
| supabase-rest | 54320 | REST API service |
| supabase-realtime | 4000 | Realtime service |
| supabase-storage | 5000 | Storage service |
| supabase-inbucket | 54326 | Email testing service |

## Cleanup

To completely remove all containers, networks, and volumes:

```bash
docker-compose down -v
```

This will remove all data, so use with caution.

