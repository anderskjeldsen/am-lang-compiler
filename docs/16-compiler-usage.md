# Compiler Usage

This document provides comprehensive information about using the Am Lang compiler (`amlc`) from the command line.

## Compiler Overview

The Am Lang compiler (`amlc`) is built in Kotlin and runs on the Java Virtual Machine. It translates Am Lang source code (`.as` files) into C code, which is then compiled to native machine code using a C compiler like GCC.

## Basic Usage

### Running the Compiler

```bash
java -jar amlc-0.6.0.jar <command> <path> [options]
```

### Alternative Method (if shaded JAR has issues)

```bash
java -cp "target/classes:target/dependency/*" no.kelson.asharpcompiler.Main <command> <path> [options]
```

## Commands

### `build` - Compile Project

Compiles an Am Lang project to the specified build target:

```bash
java -jar amlc-0.6.0.jar build /path/to/project -bt native
```

**What it does:**
1. Parses all `.as` files in the project
2. Performs semantic analysis and type checking
3. Generates optimized C code
4. Compiles C code to native executable using GCC
5. Places output in the `builds/<target>/` directory

### `run` - Compile and Execute

Compiles the project and immediately executes the resulting program:

```bash
java -jar amlc-0.6.0.jar run /path/to/project -bt native
```

**What it does:**
1. Performs the same steps as `build`
2. Executes the compiled program
3. Displays the program output

### `clean` - Clean Build Artifacts

Removes generated build files and artifacts:

```bash
java -jar amlc-0.6.0.jar clean /path/to/project -bt native
```

**What it does:**
1. Removes the `builds/<target>/` directory
2. Cleans up temporary files
3. Removes generated C code

## Command-Line Options

### Build Target (`-bt`)

Specifies which build target to use:

```bash
-bt native     # Default native target
-bt amiga      # Cross-compile for Amiga (requires Docker)
-bt debug      # Debug build with symbols
-bt release    # Optimized release build
```

Build targets are defined in the project's `package.yml` file.

### Force Load Dependencies (`-fld`)

Forces reloading of all dependencies:

```bash
java -jar amlc-0.6.0.jar build myproject -bt native -fld
```

Useful when:
- Dependencies have been updated
- Previous build had dependency issues
- Working with local dependencies

### Logging Options

#### Runtime Logging (`-rl`)

Enables runtime logging during compilation:

```bash
java -jar amlc-0.6.0.jar build myproject -bt native -rl
```

#### Conditional Logging (`-cl`)

Enables conditional logging for debugging specific scenarios:

```bash
java -jar amlc-0.6.0.jar build myproject -bt native -cl
```

#### Log Level (`-ll`)

Sets the logging verbosity level (0-5):

```bash
java -jar amlc-0.6.0.jar build myproject -bt native -ll 5
```

Log levels:
- `0` - Silent (errors only)
- `1` - Minimal output
- `2` - Basic information
- `3` - Detailed information
- `4` - Debug information
- `5` - Verbose debug output

### Debug Options

#### Render Debug Comments (`-rdc`)

Includes debug comments in the generated C code:

```bash
java -jar amlc-0.6.0.jar build myproject -bt native -rdc
```

Generated C code will include comments showing:
- Original Am Lang source line numbers
- Variable mappings
- Function call information
- Type conversion details

### Performance Options

#### Core Count (`-cores`)

Sets the number of CPU cores to use for parallel compilation:

```bash
java -jar amlc-0.6.0.jar build myproject -bt native -cores=8
```

Default is 4 cores. Useful for:
- Large projects with many source files
- Systems with many CPU cores
- Optimizing build times

## Usage Examples

### Basic Development Workflow

```bash
# Create and build a simple project
java -jar amlc-0.6.0.jar build myproject -bt native

# Run with debug logging
java -jar amlc-0.6.0.jar run myproject -bt native -ll 3

# Clean and rebuild
java -jar amlc-0.6.0.jar clean myproject -bt native
java -jar amlc-0.6.0.jar build myproject -bt native
```

### Debug Build

```bash
# Build with debug symbols and comments
java -jar amlc-0.6.0.jar build myproject -bt debug -rdc -ll 4
```

### Release Build

```bash
# Optimized release build
java -jar amlc-0.6.0.jar build myproject -bt release -cores=8
```

### Cross-Compilation

```bash
# Cross-compile for Amiga
java -jar amlc-0.6.0.jar build myproject -bt amiga -fld
```

### Troubleshooting Build

```bash
# Maximum logging for troubleshooting
java -jar amlc-0.6.0.jar build myproject -bt native -ll 5 -rl -cl -rdc
```

## Compiler Output

### Successful Build

```
Compiling project: myproject
Target: native
Loading dependencies...
Parsing source files...
  - main.as
  - utils.as
Semantic analysis...
Code generation...
Compiling C code...
Build completed successfully.
Output: builds/native/myproject
```

### Build with Warnings

```
Compiling project: myproject
Target: native
Parsing source files...
  - main.as
Warning: Variable 'unused' declared but never used (main.as:15)
Code generation...
Build completed with warnings.
```

### Build Error

```
Compiling project: myproject
Target: native
Parsing source files...
  - main.as
Error: Undefined variable 'undefinedVar' (main.as:20:5)
Build failed.
```

## Environment Variables

### `AMLC_HOME`

Sets the Am Lang compiler home directory:

```bash
export AMLC_HOME=/opt/amlang
java -jar $AMLC_HOME/amlc-0.6.0.jar build myproject
```

### `AMLC_BUILD_DIR`

Override default build output directory:

```bash
export AMLC_BUILD_DIR=/tmp/builds
java -jar amlc-0.6.0.jar build myproject -bt native
```

### `AMLC_LOG_FILE`

Redirect compiler logs to a file:

```bash
export AMLC_LOG_FILE=/var/log/amlc.log
java -jar amlc-0.6.0.jar build myproject -bt native -ll 5
```

## Integration with Build Systems

### Makefile Integration

```makefile
AMLC = java -jar amlc-0.6.0.jar
PROJECT = myproject
TARGET = native

.PHONY: build run clean

build:
	$(AMLC) build $(PROJECT) -bt $(TARGET)

run: build
	$(AMLC) run $(PROJECT) -bt $(TARGET)

clean:
	$(AMLC) clean $(PROJECT) -bt $(TARGET)

debug:
	$(AMLC) build $(PROJECT) -bt debug -rdc -ll 4

release:
	$(AMLC) build $(PROJECT) -bt release -cores=8
```

### Shell Script Integration

```bash
#!/bin/bash
# build-amlang.sh

AMLC="java -jar amlc-0.6.0.jar"
PROJECT_DIR="$1"
BUILD_TARGET="${2:-native}"

if [ -z "$PROJECT_DIR" ]; then
    echo "Usage: $0 <project-dir> [build-target]"
    exit 1
fi

echo "Building Am Lang project: $PROJECT_DIR"
echo "Target: $BUILD_TARGET"

$AMLC build "$PROJECT_DIR" -bt "$BUILD_TARGET" -ll 3

if [ $? -eq 0 ]; then
    echo "Build successful!"
    echo "Running project..."
    $AMLC run "$PROJECT_DIR" -bt "$BUILD_TARGET"
else
    echo "Build failed!"
    exit 1
fi
```

### Batch File (Windows)

```batch
@echo off
REM build-amlang.bat

set AMLC=java -jar amlc-0.6.0.jar
set PROJECT_DIR=%1
set BUILD_TARGET=%2

if "%PROJECT_DIR%"=="" (
    echo Usage: %0 ^<project-dir^> [build-target]
    exit /b 1
)

if "%BUILD_TARGET%"=="" set BUILD_TARGET=native

echo Building Am Lang project: %PROJECT_DIR%
echo Target: %BUILD_TARGET%

%AMLC% build "%PROJECT_DIR%" -bt %BUILD_TARGET% -ll 3

if %errorlevel% equ 0 (
    echo Build successful!
    echo Running project...
    %AMLC% run "%PROJECT_DIR%" -bt %BUILD_TARGET%
) else (
    echo Build failed!
    exit /b 1
)
```

## Performance Considerations

### Large Projects

For large projects with many source files:

```bash
# Use maximum cores and reduced logging
java -jar amlc-0.6.0.jar build largeproject -bt native -cores=16 -ll 1
```

### Memory Usage

For projects with high memory requirements:

```bash
# Increase Java heap size
java -Xmx4g -jar amlc-0.6.0.jar build myproject -bt native
```

### Incremental Builds

The compiler automatically detects changed files for incremental builds:

```bash
# Only recompiles changed files
java -jar amlc-0.6.0.jar build myproject -bt native
```

Force full rebuild:

```bash
# Clean first, then build
java -jar amlc-0.6.0.jar clean myproject -bt native
java -jar amlc-0.6.0.jar build myproject -bt native
```

## Error Handling and Debugging

### Common Error Messages

#### "Project not found"
```
Error: Project directory '/path/to/project' not found
```
**Solution**: Check the project path and ensure `package.yml` exists.

#### "Build target not found"
```
Error: Build target 'unknown' not defined in package.yml
```
**Solution**: Check available build targets in `package.yml`.

#### "Compilation failed"
```
Error: GCC compilation failed
```
**Solution**: Check GCC is installed and accessible. Use `-ll 5` for detailed error information.

### Debug Workflow

1. **Enable maximum logging**:
   ```bash
   java -jar amlc-0.6.0.jar build myproject -bt native -ll 5 -rl -cl
   ```

2. **Check generated C code**:
   ```bash
   java -jar amlc-0.6.0.jar build myproject -bt native -rdc
   cat builds/native/generated.c
   ```

3. **Verify project structure**:
   ```bash
   ls -la myproject/
   cat myproject/package.yml
   ```

4. **Test with simple project**:
   Create a minimal project to isolate issues.

## Best Practices

### 1. Use Appropriate Log Levels
```bash
# Development
java -jar amlc-0.6.0.jar build myproject -bt native -ll 3

# Production
java -jar amlc-0.6.0.jar build myproject -bt release -ll 1
```

### 2. Optimize Build Performance
```bash
# Use multiple cores
java -jar amlc-0.6.0.jar build myproject -bt native -cores=$(nproc)
```

### 3. Separate Debug and Release Builds
```bash
# Debug build
java -jar amlc-0.6.0.jar build myproject -bt debug -rdc

# Release build
java -jar amlc-0.6.0.jar build myproject -bt release
```

### 4. Version Control Integration
```gitignore
# .gitignore
builds/
target/
*.log
```

## Next Steps

- Learn about [Project Structure](./15-project-structure.md)
- Explore [Build Targets](./17-build-targets.md)
- Check out [Examples](./19-examples.md)