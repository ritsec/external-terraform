#!/bin/bash
# Copy out certificate
cat > ${certificate_path} << EOF
${certificate}
EOF
chmod 0644 ${certificate_path}
chown root:root ${certificate_path}
# Copy out private key
cat > ${key_path} << EOF
${key}
EOF
chmod 0600 ${key_path}
chown root:root ${key_path}