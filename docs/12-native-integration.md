# Native Integration

Am Lang provides powerful native integration capabilities, allowing seamless interoperability with C libraries and system APIs. This document covers how to use native classes, functions, and integrate with existing C codebases.

## Overview

Am Lang's native integration features include:
- **Native Classes**: Direct mapping to C structures and functions
- **Primitive Types**: Zero-overhead mapping to C types
- **Native Functions**: Direct calls to C functions
- **C Library Integration**: Easy binding to existing C libraries
- **Platform-Specific Code**: Conditional compilation for different platforms

## Native Classes

### Basic Native Class Declaration

```amlang
native class FileHandle {
    // Native fields map to C struct members
    private var fd: Int
    
    // Native functions map to C functions
    native fun open(filename: String, mode: String): Bool
    native fun read(buffer: String, size: Int): Int
    native fun write(data: String): Int
    native fun close()
}
```

This generates C code similar to:
```c
typedef struct {
    int fd;
} FileHandle_t;

bool FileHandle_open(FileHandle_t* self, const char* filename, const char* mode);
int FileHandle_read(FileHandle_t* self, char* buffer, int size);
int FileHandle_write(FileHandle_t* self, const char* data);
void FileHandle_close(FileHandle_t* self);
```

### Native Class with Initialization

```amlang
native class Socket {
    private var sockfd: Int = -1
    private var connected: Bool = false
    
    native fun connect(address: String, port: Int): Bool
    native fun send(data: String): Int
    native fun receive(buffer: String, maxSize: Int): Int
    native fun disconnect()
    
    fun isConnected(): Bool {
        return this.connected
    }
}
```

### Implementation in C

The native functions must be implemented in C:

```c
// socket_impl.c
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <string.h>

bool Socket_connect(Socket_t* self, const char* address, int port) {
    self->sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (self->sockfd < 0) {
        return false;
    }
    
    struct sockaddr_in server_addr;
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(port);
    inet_pton(AF_INET, address, &server_addr.sin_addr);
    
    if (connect(self->sockfd, (struct sockaddr*)&server_addr, sizeof(server_addr)) < 0) {
        close(self->sockfd);
        self->sockfd = -1;
        return false;
    }
    
    self->connected = true;
    return true;
}

int Socket_send(Socket_t* self, const char* data) {
    if (!self->connected) {
        return -1;
    }
    return send(self->sockfd, data, strlen(data), 0);
}

int Socket_receive(Socket_t* self, char* buffer, int maxSize) {
    if (!self->connected) {
        return -1;
    }
    return recv(self->sockfd, buffer, maxSize - 1, 0);
}

void Socket_disconnect(Socket_t* self) {
    if (self->sockfd >= 0) {
        close(self->sockfd);
        self->sockfd = -1;
    }
    self->connected = false;
}
```

## Primitive Native Types

### Built-in Primitive Types

Am Lang provides primitive types that map directly to C types:

```amlang
primitive native class Int {
    // Maps to C 'int'
    override native fun toString(): String
    native fun abs(): Int
}

primitive native class Long {
    // Maps to C 'long long'
    override native fun toString(): String
}

primitive native class Double {
    // Maps to C 'double'
    override native fun toString(): String
    native fun sqrt(): Double
    native fun sin(): Double
    native fun cos(): Double
}

primitive native class Pointer {
    // Maps to C 'void*'
    native fun isNull(): Bool
    native fun deref(): Object
}
```

### Custom Primitive Types

You can define custom primitive types for specific use cases:

```amlang
primitive native class FileDescriptor {
    // Maps to C 'int' but with type safety
    native fun isValid(): Bool
    native fun close()
}

primitive native class MemoryAddress {
    // Maps to C 'uintptr_t'
    native fun offset(bytes: Int): MemoryAddress
    native fun readByte(): Int
    native fun writeByte(value: Int)
}
```

## System API Integration

### File System Operations

```amlang
namespace System.IO {
    native class File {
        private var handle: FileDescriptor
        private var filename: String
        
        static native fun exists(filename: String): Bool
        static native fun delete(filename: String): Bool
        static native fun createDirectory(path: String): Bool
        
        native fun open(filename: String, mode: String): Bool
        native fun read(buffer: String, size: Int): Int
        native fun write(data: String): Int
        native fun seek(position: Long, origin: Int): Bool
        native fun tell(): Long
        native fun close()
        
        fun readAll(): String {
            if (!this.open(this.filename, "r")) {
                return null
            }
            
            var content = ""
            var buffer = new String[1024]
            var bytesRead: Int
            
            while ((bytesRead = this.read(buffer, 1024)) > 0) {
                content += buffer.substring(0, bytesRead)
            }
            
            this.close()
            return content
        }
    }
}
```

### Memory Management

```amlang
namespace System.Memory {
    native class Memory {
        static native fun allocate(size: Int): Pointer
        static native fun reallocate(ptr: Pointer, newSize: Int): Pointer
        static native fun free(ptr: Pointer)
        static native fun copy(dest: Pointer, src: Pointer, size: Int)
        static native fun set(ptr: Pointer, value: Int, size: Int)
        
        static fun allocateZeroed(size: Int): Pointer {
            var ptr = Memory.allocate(size)
            Memory.set(ptr, 0, size)
            return ptr
        }
    }
    
    native class Buffer(private var capacity: Int) {
        private var data: Pointer = Memory.allocateZeroed(capacity)
        private var size: Int = 0
        
        native fun get(index: Int): Int
        native fun set(index: Int, value: Int)
        
        fun resize(newCapacity: Int): Bool {
            if (newCapacity <= this.capacity) {
                return true
            }
            
            var newData = Memory.reallocate(this.data, newCapacity)
            if (newData.isNull()) {
                return false
            }
            
            this.data = newData
            this.capacity = newCapacity
            return true
        }
        
        fun destroy() {
            Memory.free(this.data)
            this.data = null
            this.size = 0
            this.capacity = 0
        }
    }
}
```

## Platform-Specific Integration

### Windows API Example

```amlang
namespace Windows {
    // Windows-specific types
    primitive native class HANDLE {
        native fun isValid(): Bool
        native fun close(): Bool
    }
    
    primitive native class DWORD {
        // Maps to Windows DWORD (unsigned 32-bit)
    }
    
    native class WindowsFile {
        private var handle: HANDLE
        
        native fun createFile(filename: String, access: DWORD, share: DWORD): Bool
        native fun readFile(buffer: String, size: DWORD): DWORD
        native fun writeFile(data: String): DWORD
        native fun getFileSize(): DWORD
        native fun closeHandle()
    }
    
    native class Registry {
        static native fun openKey(hive: DWORD, subKey: String): HANDLE
        static native fun queryValue(key: HANDLE, valueName: String): String
        static native fun setValue(key: HANDLE, valueName: String, value: String): Bool
        static native fun closeKey(key: HANDLE)
    }
}
```

### POSIX API Example

```amlang
namespace Posix {
    native class Process {
        private var pid: Int
        
        static native fun fork(): Int
        static native fun exec(program: String, args: String[]): Int
        static native fun wait(pid: Int): Int
        static native fun kill(pid: Int, signal: Int): Bool
        static native fun getpid(): Int
        static native fun getppid(): Int
        
        fun spawn(program: String, args: String[]): Bool {
            this.pid = Process.fork()
            
            if (this.pid == 0) {
                // Child process
                Process.exec(program, args)
                return false  // exec failed
            } else if (this.pid > 0) {
                // Parent process
                return true
            } else {
                // Fork failed
                return false
            }
        }
        
        fun waitForCompletion(): Int {
            if (this.pid > 0) {
                return Process.wait(this.pid)
            }
            return -1
        }
    }
    
    native class Signal {
        static native fun signal(signum: Int, handler: Pointer)
        static native fun raise(signum: Int): Int
        static native fun alarm(seconds: Int): Int
        
        // Signal constants
        static const var SIGINT: Int = 2
        static const var SIGTERM: Int = 15
        static const var SIGUSR1: Int = 10
    }
}
```

### Amiga System Integration

```amlang
namespace Amiga {
    native class Intuition {
        static native fun openLibrary(): Bool
        static native fun closeLibrary()
        
        static native fun openScreen(width: Int, height: Int, depth: Int): Screen
        static native fun closeScreen(screen: Screen)
    }
    
    native class Screen {
        private var screenPtr: Pointer
        
        native fun getWidth(): Int
        native fun getHeight(): Int
        native fun getDepth(): Int
        native fun setPixel(x: Int, y: Int, color: Int)
        native fun getPixel(x: Int, y: Int): Int
        native fun clear(color: Int)
    }
    
    native class Graphics {
        static native fun openLibrary(): Bool
        static native fun closeLibrary()
        
        static native fun drawLine(screen: Screen, x1: Int, y1: Int, x2: Int, y2: Int, color: Int)
        static native fun drawRect(screen: Screen, x: Int, y: Int, width: Int, height: Int, color: Int)
        static native fun fillRect(screen: Screen, x: Int, y: Int, width: Int, height: Int, color: Int)
    }
    
    class AmigaApp {
        private var screen: Screen
        
        fun initialize(): Bool {
            if (!Intuition.openLibrary()) {
                "Failed to open Intuition library".println()
                return false
            }
            
            if (!Graphics.openLibrary()) {
                "Failed to open Graphics library".println()
                Intuition.closeLibrary()
                return false
            }
            
            this.screen = Intuition.openScreen(320, 256, 8)
            if (this.screen == null) {
                "Failed to open screen".println()
                Graphics.closeLibrary()
                Intuition.closeLibrary()
                return false
            }
            
            return true
        }
        
        fun drawDemo() {
            if (this.screen != null) {
                this.screen.clear(0)
                Graphics.drawRect(this.screen, 10, 10, 100, 50, 1)
                Graphics.fillRect(this.screen, 150, 100, 80, 60, 2)
                Graphics.drawLine(this.screen, 0, 0, 319, 255, 3)
            }
        }
        
        fun cleanup() {
            if (this.screen != null) {
                Intuition.closeScreen(this.screen)
                this.screen = null
            }
            Graphics.closeLibrary()
            Intuition.closeLibrary()
        }
    }
}
```

## Build Configuration for Native Integration

### Linking Native Libraries

Configure your `package.yml` to link with native libraries:

```yaml
name: "native-integration-example"
version: "1.0.0"

build-targets:
  native:
    type: "native"
    compiler: "gcc"
    flags: ["-O2", "-Wall"]
    libraries: ["sqlite3", "m", "pthread"]  # Link with SQLite, math, and pthread
    include-dirs: ["/usr/include", "/usr/local/include"]
    library-dirs: ["/usr/lib", "/usr/local/lib"]
    
  windows:
    type: "cross"
    compiler: "x86_64-w64-mingw32-gcc"
    flags: ["-O2", "-static"]
    libraries: ["sqlite3", "ws2_32"]  # Windows-specific libraries
    
  amiga:
    type: "cross"
    compiler: "m68k-amigaos-gcc"
    flags: ["-O2", "-m68000"]
    libraries: []  # Amiga uses different linking approach
```

### Custom Native Code

Include custom C implementation files:

```yaml
# package.yml
native-sources:
  - "native/socket_impl.c"
  - "native/file_impl.c"
  - "native/memory_impl.c"

include-dirs:
  - "native/include"
```

Directory structure:
```
project/
├── package.yml
├── src/
│   └── main.as
└── native/
    ├── include/
    │   └── socket_impl.h
    ├── socket_impl.c
    ├── file_impl.c
    └── memory_impl.c
```

## Best Practices

### 1. Type Safety
```amlang
// Good - use specific native types
native class FileDescriptor {
    native fun read(buffer: String, size: Int): Int
}

// Poor - using generic types
native class File {
    native fun read(handle: Int, buffer: String, size: Int): Int
}
```

### 2. Error Handling
```amlang
native class SafeFile {
    native fun open(filename: String): Bool
    native fun getLastError(): String
    
    fun openWithErrorHandling(filename: String): Bool {
        if (!this.open(filename)) {
            "Failed to open ${filename}: ${this.getLastError()}".println()
            return false
        }
        return true
    }
}
```

### 3. Resource Management
```amlang
class ResourceManager {
    private var resources: List<NativeResource>
    
    fun addResource(resource: NativeResource) {
        this.resources.add(resource)
    }
    
    fun cleanup() {
        for (resource in this.resources) {
            resource.release()
        }
        this.resources.clear()
    }
}
```

### 4. Platform Abstraction
```amlang
interface FileSystem {
    fun exists(path: String): Bool
    fun delete(path: String): Bool
    fun createDirectory(path: String): Bool
}

class WindowsFileSystem : FileSystem {
    // Windows-specific implementation
}

class PosixFileSystem : FileSystem {
    // POSIX-specific implementation
}
```

## Next Steps

- Learn about [Build Targets](./17-build-targets.md) for cross-platform compilation
- Explore [Project Structure](./15-project-structure.md) for organizing native code
- Check out [Examples](./19-examples.md) for more native integration patterns