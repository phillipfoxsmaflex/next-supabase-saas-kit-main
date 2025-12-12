
#!/bin/bash

# Port Fix Verification Script
# This script verifies that the port conflict has been resolved

echo "=== Port Fix Verification ==="
echo ""

# Check if docker-compose.yml has been updated
echo "1. Checking docker-compose.yml for port 5001 mapping..."
if grep -q '"5001:5000"' docker-compose.yml; then
    echo "✅ docker-compose.yml correctly maps port 5001:5000"
else
    echo "❌ docker-compose.yml does not have the correct port mapping"
    exit 1
fi

# Check if internal service references are correct
echo "2. Checking kong.yml for internal service references..."
if grep -q "http://supabase-storage:5000" supabase/kong.yml; then
    echo "✅ kong.yml correctly references supabase-storage:5000 (internal)"
else
    echo "❌ kong.yml does not have correct internal service reference"
    exit 1
fi

# Check if documentation has been updated
echo "3. Checking documentation for updated port references..."
if grep -q "localhost:5001" DOCKER_FIX_GUIDE.md && \
   grep -q "5001" DOCKER_README.md && \
   grep -q "5001" DOCKER_COMPLETE_SOLUTION.md; then
    echo "✅ Documentation correctly references port 5001"
else
    echo "❌ Documentation has not been fully updated"
    exit 1
fi

# Check that old port references are removed from docs
echo "4. Checking that old port 5000 references are updated in docs..."
if grep -q "localhost:5000" DOCKER_FIX_GUIDE.md; then
    echo "❌ DOCKER_FIX_GUIDE.md still contains old port 5000 reference"
    exit 1
else
    echo "✅ DOCKER_FIX_GUIDE.md does not contain old port 5000 reference"
fi

if grep -q "localhost:5000" DOCKER_README.md; then
    echo "❌ DOCKER_README.md still contains old port 5000 reference"
    exit 1
else
    echo "✅ DOCKER_README.md does not contain old port 5000 reference"
fi

echo ""
echo "=== Verification Complete ==="
echo "✅ All checks passed! The port conflict should be resolved."
echo ""
echo "Summary of changes:"
echo "- Changed supabase-storage port mapping from 5000:5000 to 5001:5000"
echo "- Updated all documentation to reference port 5001 instead of 5000"
echo "- Internal service references remain unchanged (using supabase-storage:5000)"
echo ""
echo "The application should now start without port conflicts."
