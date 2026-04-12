#!/bin/bash
# test_python.sh — test Python environment inside the container

set -e

conda run -n physicsbox python << 'EOF'
import numpy
import scipy
import matplotlib
print("✓ numpy", numpy.__version__)
print("✓ scipy", scipy.__version__)
print("✓ matplotlib", matplotlib.__version__)
EOF

echo "✓ Python imports OK"
