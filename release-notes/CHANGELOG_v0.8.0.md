# AmLang Compiler v0.8.0 - Release Documentation

**Release Date:** December 26, 2025  
**Minor Release:** Expression System Refactor, Enhanced Loop Syntax, Function Pointer Improvements, and Package Management Enhancements

## 🎉 Major New Features

### 1. **Enhanced `each` Loop Syntax** 🔄

**Complete support for intuitive iteration syntax with backward compatibility:**

#### Core Implementation:
- **`in` keyword**: Added to Keywords.kt for new syntax support
- **Dual syntax parser**: ControlFlowExpressionParser handles both old and new forms
- **Backward compatibility**: Existing `each(collection, item)` syntax fully preserved
- **Automatic detection**: Parser intelligently determines syntax form

#### Syntax Examples:
```amlang
// New intuitive syntax - recommended
each(item in list) {
    item.process()
    "Processing: ${item}".println()
}

// Traditional syntax - still fully supported
each(list, element) {
    element.process()
    "Processing: ${element}".println()
}

```

### 2. **Function Pointer Property Improvements** 🎯

**Enhanced function pointer handling for class member properties with direct invocation support:**

#### Core Implementation:
- **Direct Invocation Fix**: Resolved C syntax errors for `this.functionPtr()` calls
- **Property Access Enhancement**: Improved PropertyRenderer for function pointer properties
- **Memory Management**: Better reference counting for function pointer properties
- **Type Safety**: Enhanced validation of function pointer assignments and calls

#### Syntax Examples:
```amlang
class EventManager {
    private var onEvent: (message: String) => void
    private var validator: (input: String) => Bool
    
    fun setupCallbacks() {
        // Function pointer assignment
        this.onEvent = (message: String) => {
            "Event: ${message}".println()
        }
        
        this.validator = (input: String) => {
            return input.length() > 0
        }
        
        // Direct invocation - now works reliably
        this.onEvent("System started")
        
        if (this.validator("test")) {
            "Validation passed".println()
        }
        
        // Indirect invocation - always worked
        var callback = this.onEvent
        callback("Indirect call")
    }
}
```

### **Expression System Refactor** ⚡

### **Package Management System** 📦

**Enhanced dependency resolution and feature-based package loading:**

#### New Features:
- **Feature Requirements**: `featureRequired` field for conditional dependencies
- **Dependency Validation**: Improved validation of package dependencies
- **Include Path Management**: Better handling of native file include paths

#### Configuration Examples:
```yaml
# package.yml
id: my-graphics-app
version: 1.2.0
availableFeatures:
  - opengl
  - vulkan
  - directx

dependencies:
  - id: graphics-core
    version: 2.1.0
    # Always included
    
  - id: opengl-renderer
    version: 1.5.0
    featureRequired: opengl  # Only when opengl feature is available
    
  - id: vulkan-renderer
    version: 1.8.0
    featureRequired: vulkan  # Only when vulkan feature is available
    
  - id: directx-renderer
    version: 1.3.0
    featureRequired: directx # Only when directx feature is available

```
