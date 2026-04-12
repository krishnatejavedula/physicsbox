#!/bin/bash
# test_packages.sh — check all expected conda packages are installed

set -e

VARIANT=$(cat /etc/physicsbox/build_variant)
echo "Build variant: $VARIANT"

conda run -n physicsbox conda list --no-pip -q \
    | awk 'NR>3 {print $1}' > /tmp/installed.txt

conda run -n physicsbox python << EOF > /tmp/expected.txt
import yaml
with open('/etc/physicsbox/environment.${VARIANT}.yml') as f:
    env = yaml.safe_load(f)
deps = [d.split('=')[0] for d in env.get('dependencies', [])
        if isinstance(d, str) and d != 'pip']
print('\n'.join(deps))
EOF

MISSING=()
while IFS= read -r pkg; do
    [ -z "$pkg" ] && continue
    if ! grep -qi "^${pkg}$" /tmp/installed.txt; then
        MISSING+=("$pkg")
    fi
done < /tmp/expected.txt

if [ ${#MISSING[@]} -gt 0 ]; then
    echo "✗ Missing packages: ${MISSING[*]}"
    exit 1
fi

echo "✓ All expected packages installed"
