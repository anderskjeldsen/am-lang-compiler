# AmLang v0.7.0 Release Notes

**Release Date:** November 2025

## New Features

### 1. Feature Requirements (#require/#requireNot directives)

Conditional compilation based on package features.

**Syntax:**
```amlang
namespace Graphics {
    #require opengl
    class Renderer {
        fun initialize() {
            OpenGL.initContext()
        }
    }
    
    #require directx
    class Renderer {
        fun initialize() {
            DirectX.createDevice()
        }
    }
    
    #requireNot basicMode
    class AdvancedRenderer {
        fun renderWithShaders() {
            // Advanced rendering when not in basic mode
        }
    }
}

namespace Audio {
    class AudioEngine {
        #require simdExtensions
        fun processAudioSIMD(buffer: AudioBuffer) {
            SIMD.processAudio(buffer)
        }
        
        #requireNot simdExtensions
        fun processAudioCPU(buffer: AudioBuffer) {
            CPU.processAudio(buffer)
        }
    }
}
```

**Configuration:**
Library declares available features:
```yaml
# graphics-lib/package.yml
id: graphics-lib
availableFeatures: [opengl, directx]
```

Application selects features to use:
```yaml
# my-app/package.yml
dependencies:
  - id: graphics-lib
    features: [opengl]
```

Classes/functions with unmet feature requirements are excluded from compilation.

### 2. Float and Double Support

Native floating-point number types with scientific notation.

**Basic literals:**
```amlang
var f: Float = 3.14F
var d: Double = 2.718281828
```

**Scientific notation:**
```amlang
var small: Float = 1.23e-4F     // 0.000123
var large: Double = 6.02e23     // 6.02 × 10²³
var negative: Double = 9.81e-2  // 0.0981
```

**Type conversions:**
```amlang
var sum: Double = f.toDouble() + d
var product: Float = f * 2.0F
```

### 3. Code Linting (amlc lint)

Code style and quality checking.

**Command:**
```bash
amlc lint
```

**Configuration (amlint.yaml):**
```yaml
namingConventions:
  enforceClassNameCase: "PascalCase"
  enforceFunctionNameCase: "camelCase"
  enforceVariableNameCase: "camelCase"

codeStyle:
  maxLineLength: 120
  maxFunctionLength: 50
  maxParameterCount: 5

bestPractices:
  requireDocumentationForPublicMethods: true
  forbidUnusedVariables: true
```

**Output:**
```
⚠️  Warning: Function name 'Calculate_Sum' should use camelCase
⚠️  Warning: Class 'myClass' should use PascalCase
✓ No errors found
```

### 4. Documentation Generation (amlc docs)

API documentation from code comments.

**JavaDoc-style comments:**
```amlang
/**
 * Calculates compound interest.
 * @param principal Initial amount
 * @param rate Annual interest rate
 * @return Final amount
 */
fun compoundInterest(principal: Double, rate: Double): Double {
    return principal * (1.0 + rate)
}
```

**Commands:**
```bash
amlc docs                    # JSON + Markdown
amlc docs -docformat json    # JSON only
amlc docs -docformat md      # Markdown only
amlc docs -docout api/       # Custom output directory
```

**Output structure:**
```
docs/
├── index.md
├── namespaces/
│   └── MyLib/
│       └── Calculator.md
├── classes/index.md
└── api-documentation.json
```

## Examples

### Feature Requirements
```amlang
namespace AudioEngine {
    #require pulseaudio
    class AudioEngine {
        fun playSound(clip: AudioClip) {
            PulseAudio.play(clip)
        }
    }
    
    #require wasapi  
    class AudioEngine {
        fun playSound(clip: AudioClip) {
            WASAPI.render(clip)
        }
    }
}
```

### Float/Double Usage
```amlang
namespace Physics {
    class Particle {
        private var mass: Double = 9.109e-31  // kg
        private var velocity: Float = 0.0F    // m/s
        
        fun kineticEnergy(): Double {
            var v = velocity.toDouble()
            return 0.5 * mass * v * v
        }
    }
}
```

## Installation

Download from [GitHub Releases](https://github.com/anderskjeldsen/am-lang-compiler/releases/latest).

## Compatibility

All v0.6.4 code continues to work unchanged. New features are optional.