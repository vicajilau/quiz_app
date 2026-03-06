---
description: Add missing GPL-3.0 license headers to Dart source files
---

1. Create a script called `add_licenses.sh` in the project root:

```bash
#!/bin/bash

# Target header
HEADER="// Copyright (C) 2026 Víctor Carreras
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
"

export HEADER

# Find all dart files except generated ones
find lib test -name "*.dart" ! -path "*.g.dart" ! -path "*/l10n/app_*.dart" | while read -r file; do
  # Check if the file already has the copyright string
  if ! grep -q "Copyright (C)" "\$file"; then
    echo "Adding license to \$file"
    # Create a temporary file with the header and original content
    echo "\$HEADER" > "\$file.tmp"
    cat "\$file" >> "\$file.tmp"
    mv "\$file.tmp" "\$file"
  fi
done

echo "License headers check completed."
```

2. Make it executable:
// turbo
```bash
chmod +x add_licenses.sh
```

3. Run the script:
// turbo
```bash
./add_licenses.sh
```

4. Clean up the script:
// turbo
```bash
rm add_licenses.sh
```
