# Project Structure

This document explains how to organize Am Lang projects and understand the directory structure and configuration files.

## Project Directory Layout

A typical Am Lang project follows this structure:

```
my-project/
├── package.yml          # Project configuration file
├── src/                 # Source code directory
│   ├── main.as         # Main program file
│   ├── models/         # Model classes (optional)
│   │   ├── User.as
│   │   └── Product.as
│   └── utils/          # Utility classes (optional)
│       └── StringUtils.as
├── builds/             # Generated build artifacts (auto-created)
│   ├── native/         # Native build output
│   │   ├── main        # Compiled executable
│   │   └── generated.c # Generated C code
│   ├── debug/          # Debug build output
│   └── release/        # Release build output
├── dependencies/       # External dependencies (if any)
└── docs/              # Project documentation (optional)
    └── README.md
```

## Package Configuration (`package.yml`)

The `package.yml` file is the heart of every Am Lang project. It defines project metadata, dependencies, and build configuration.

### Basic Package Configuration

```yaml
name: "my-project"
version: "1.0.0"
description: "A sample Am Lang project"
author: "Your Name"
license: "MIT"

# Build targets define how the project should be compiled
build-targets:
  native:
    type: "native"
    compiler: "gcc"
    flags: ["-O2", "-std=c99"]
    
  debug:
    type: "native"
    compiler: "gcc"
    flags: ["-g", "-O0", "-DDEBUG"]
    
  release:
    type: "native"
    compiler: "gcc"
    flags: ["-O3", "-DNDEBUG", "-fomit-frame-pointer"]

dependencies: []
```

### Advanced Package Configuration

```yaml
name: "advanced-project"
version: "2.1.0"
description: "An advanced Am Lang project with multiple targets"
author: "Development Team"
license: "Apache-2.0"
homepage: "https://github.com/user/advanced-project"

# Source directories (optional, defaults to "src")
source-dirs:
  - "src"
  - "lib"

# Include directories for native compilation
include-dirs:
  - "include"
  - "/usr/local/include"

# Library directories
library-dirs:
  - "libs"
  - "/usr/local/lib"

# Build targets
build-targets:
  native:
    type: "native"
    compiler: "gcc"
    flags: ["-O2", "-Wall", "-Wextra"]
    libraries: ["m", "pthread"]  # Link with math and pthread libraries
    
  debug:
    type: "native"
    compiler: "gcc"
    flags: ["-g", "-O0", "-DDEBUG", "-fsanitize=address"]
    libraries: ["m", "pthread"]
    
  release:
    type: "native"
    compiler: "gcc"
    flags: ["-O3", "-DNDEBUG", "-flto"]
    libraries: ["m", "pthread"]
    
  amiga:
    type: "cross"
    compiler: "m68k-amigaos-gcc"
    flags: ["-O2", "-fomit-frame-pointer", "-m68000"]
    target-arch: "m68k"
    target-os: "amigaos"
    
  windows:
    type: "cross"
    compiler: "x86_64-w64-mingw32-gcc"
    flags: ["-O2", "-static"]
    target-arch: "x86_64"
    target-os: "windows"

# Dependencies (if the project used external libraries)
dependencies:
  - name: "json-parser"
    version: "1.0.0"
    source: "git"
    url: "https://github.com/example/json-parser"
  
  - name: "math-utils"
    version: "2.3.1"
    source: "local"
    path: "../shared-libs/math-utils"

# Build scripts (optional)
scripts:
  pre-build: "scripts/pre-build.sh"
  post-build: "scripts/post-build.sh"
  test: "scripts/run-tests.sh"
```

## Source Organization

### Single File Projects

For simple projects, a single source file is sufficient:

```
simple-project/
├── package.yml
└── src/
    └── main.as
```

### Multi-File Projects

Larger projects should organize code into logical modules:

```
large-project/
├── package.yml
└── src/
    ├── main.as              # Entry point
    ├── core/                # Core functionality
    │   ├── Application.as
    │   ├── Config.as
    │   └── Logger.as
    ├── models/              # Data models
    │   ├── User.as
    │   ├── Product.as
    │   └── Order.as
    ├── services/            # Business logic
    │   ├── UserService.as
    │   ├── ProductService.as
    │   └── OrderService.as
    ├── utils/               # Utility classes
    │   ├── StringUtils.as
    │   ├── DateUtils.as
    │   └── MathUtils.as
    └── native/              # Native code interfaces
        ├── FileSystem.as
        └── Network.as
```

### Namespace Organization

Organize code using namespaces that reflect the directory structure:

```amlang
// src/models/User.as
namespace MyProject.Models {
    class User {
        // Implementation
    }
}

// src/services/UserService.as
namespace MyProject.Services {
    import MyProject.Models.User
    
    class UserService {
        // Implementation
    }
}

// src/main.as
namespace MyProject {
    import MyProject.Services.UserService
    
    class Main {
        static fun main() {
            // Implementation
        }
    }
}
```

## Build Artifacts

### Build Directory Structure

The compiler automatically creates build directories:

```
builds/
├── native/
│   ├── main              # Compiled executable
│   ├── generated.c       # Generated C source
│   ├── generated.h       # Generated C headers
│   ├── Makefile         # Generated Makefile
│   └── obj/             # Object files
│       ├── main.o
│       └── utils.o
├── debug/
│   ├── main_debug
│   ├── generated.c
│   └── obj/
└── release/
    ├── main_release
    ├── generated.c
    └── obj/
```

### Generated C Code

The compiler generates C code that can be inspected:

```c
// Example generated.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Am Lang runtime
typedef struct {
    int ref_count;
    void (*destructor)(void*);
} am_object_header_t;

// Generated class structures
typedef struct {
    am_object_header_t header;
    char* name;
    int age;
} Person_t;

// Generated functions
Person_t* Person_new(const char* name, int age) {
    Person_t* self = malloc(sizeof(Person_t));
    self->header.ref_count = 1;
    self->name = strdup(name);
    self->age = age;
    return self;
}

void Person_greet(Person_t* self) {
    printf("Hello, I'm %s and I'm %d years old\n", self->name, self->age);
}

int main() {
    Person_t* person = Person_new("Alice", 25);
    Person_greet(person);
    return 0;
}
```

## Dependency Management

### Local Dependencies

For local dependencies (other Am Lang projects):

```yaml
dependencies:
  - name: "shared-utils"
    version: "1.0.0"
    source: "local"
    path: "../shared-utils"
```

Directory structure:
```
workspace/
├── my-project/
│   ├── package.yml       # References shared-utils
│   └── src/
└── shared-utils/
    ├── package.yml       # Shared utility library
    └── src/
```

### Git Dependencies

For dependencies hosted in Git repositories:

```yaml
dependencies:
  - name: "json-parser"
    version: "v1.2.0"
    source: "git"
    url: "https://github.com/example/amlang-json"
    branch: "main"          # Optional, defaults to main
```

### Dependency Resolution

Dependencies are resolved in this order:
1. Local cache (`dependencies/` directory)
2. Local file system (for local dependencies)
3. Git repositories (for git dependencies)
4. Package registries (future feature)

## Build Scripts

### Pre/Post Build Scripts

Add custom build steps using scripts:

```yaml
scripts:
  pre-build: "scripts/generate-version.sh"
  post-build: "scripts/copy-assets.sh"
  test: "scripts/run-tests.sh"
  clean: "scripts/clean-extra.sh"
```

Example script (`scripts/generate-version.sh`):
```bash
#!/bin/bash
# Generate version information
echo "Generating version file..."
echo "const var BUILD_VERSION = \"$(git describe --tags)\"" > src/Version.as
echo "const var BUILD_DATE = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" >> src/Version.as
```

### Testing Scripts

Example test script (`scripts/run-tests.sh`):
```bash
#!/bin/bash
# Run project tests

echo "Building test version..."
java -jar amlc.jar build . -bt debug

echo "Running tests..."
./builds/debug/main --test

echo "Tests completed."
```

## Cross-Platform Projects

### Platform-Specific Code

Organize platform-specific code:

```
cross-platform-project/
├── package.yml
├── src/
│   ├── main.as
│   ├── common/           # Platform-independent code
│   │   └── Utils.as
│   ├── linux/           # Linux-specific code
│   │   └── FileSystem.as
│   ├── windows/         # Windows-specific code
│   │   └── FileSystem.as
│   └── amiga/           # Amiga-specific code
│       └── FileSystem.as
```

### Conditional Compilation

Use build targets for conditional compilation:

```yaml
build-targets:
  linux:
    type: "native"
    compiler: "gcc"
    flags: ["-DTARGET_LINUX"]
    
  windows:
    type: "cross"
    compiler: "x86_64-w64-mingw32-gcc"
    flags: ["-DTARGET_WINDOWS"]
    
  amiga:
    type: "cross"
    compiler: "m68k-amigaos-gcc"
    flags: ["-DTARGET_AMIGA"]
```

## Development Workflow

### Typical Development Cycle

1. **Project Setup**:
   ```bash
   mkdir my-project
   cd my-project
   # Create package.yml and src/ directory
   ```

2. **Development**:
   ```bash
   # Build and test frequently
   java -jar amlc.jar build . -bt debug
   java -jar amlc.jar run . -bt debug
   ```

3. **Testing**:
   ```bash
   # Run tests
   java -jar amlc.jar build . -bt debug
   ./scripts/run-tests.sh
   ```

4. **Release**:
   ```bash
   # Create optimized release build
   java -jar amlc.jar clean . -bt release
   java -jar amlc.jar build . -bt release
   ```

### IDE Integration

For IDE integration, create configuration files:

**.vscode/tasks.json** (VS Code):
```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Am Lang Build",
            "type": "shell",
            "command": "java",
            "args": ["-jar", "amlc.jar", "build", ".", "-bt", "debug"],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        },
        {
            "label": "Am Lang Run",
            "type": "shell",
            "command": "java",
            "args": ["-jar", "amlc.jar", "run", ".", "-bt", "debug"],
            "group": "test",
            "dependsOn": "Am Lang Build"
        }
    ]
}
```

## Project Templates

### Console Application Template

```yaml
# package.yml
name: "console-app"
version: "1.0.0"
description: "A console application"

build-targets:
  native:
    type: "native"
    compiler: "gcc"
    flags: ["-O2"]

dependencies: []
```

```amlang
// src/main.as
namespace ConsoleApp {
    class Main {
        static fun main() {
            "Welcome to Console App!".println()
            
            var args = System.getArgs()
            if (args.length > 0) {
                "Arguments provided: ${args.length}".println()
                for (i in 0 to args.length - 1) {
                    "  Arg ${i}: ${args[i]}".println()
                }
            }
        }
    }
}
```

### Library Template

```yaml
# package.yml
name: "utility-library"
version: "1.0.0"
description: "A reusable utility library"

build-targets:
  native:
    type: "library"
    compiler: "gcc"
    flags: ["-O2", "-fPIC"]

dependencies: []
```

```amlang
// src/StringUtils.as
namespace Utils {
    class StringUtils {
        static fun isEmpty(str: String): Bool {
            return str == null || str.length() == 0
        }
        
        static fun reverse(str: String): String {
            // Implementation
            return str
        }
        
        static fun contains(haystack: String, needle: String): Bool {
            // Implementation
            return false
        }
    }
}
```

## Best Practices

### 1. Project Organization
- Use meaningful directory names
- Group related functionality together
- Separate platform-specific code
- Keep build artifacts out of version control

### 2. Configuration Management
- Use descriptive build target names
- Document custom build flags
- Version your dependencies
- Use scripts for complex build steps

### 3. Dependency Management
- Pin dependency versions for reproducible builds
- Prefer local dependencies for development
- Document external dependencies
- Test with minimal dependencies

### 4. Build Management
- Use separate debug and release builds
- Enable maximum warnings in debug builds
- Optimize for size or speed in release builds
- Test all build targets regularly

### 5. Documentation
- Document project structure in README
- Explain build requirements
- Provide setup instructions
- Document any special configuration

## Troubleshooting

### Common Issues

1. **Build Target Not Found**:
   ```
   Error: Build target 'myTarget' not found
   ```
   Solution: Check `package.yml` for typos in build target names.

2. **Source Files Not Found**:
   ```
   Error: No source files found in 'src/'
   ```
   Solution: Ensure source files have `.as` extension and are in the correct directory.

3. **Dependency Resolution Failed**:
   ```
   Error: Could not resolve dependency 'utils'
   ```
   Solution: Check dependency paths and versions in `package.yml`.

4. **Compiler Not Found**:
   ```
   Error: gcc: command not found
   ```
   Solution: Install the required compiler for your build target.

## Next Steps

- Learn about [Build Targets](./17-build-targets.md)
- Explore [Compiler Usage](./16-compiler-usage.md)
- Check out [Examples](./19-examples.md)