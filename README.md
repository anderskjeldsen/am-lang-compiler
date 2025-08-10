# am-lang-compiler

# What is am-lang

"AmLang" is a new programming language mainly targetted at niche platforms like AmigaOS (or MorphOS). Read more about it below.

# Am Lang Features
AmLang is inspired by other programming languages like Kotlin, Java, C#, TypeScript, Swift etc. 

- ARC (automatic reference counting) and GC (garbage collection) combined. 
- classes
- interfaces
- namespaces
- suspendable functions
- lambda expressions
- native c support
- exceptions (try,catch,throw) 
- generics
- and a lot more. 

There are still some major features missing, like for example for-loops. I have to use while loops until I prioritize for-loops 🙂 Currently it compiles only on Mac/Linux/Windows (using Docker), but one of the ultimate goals is to re-write the compiler in its own language. The compiler doesn't generate any machine code on its own, it writes C-code and lets GCC make the machine code. Performance-wise it's not as efficient as C (obviously?), but one can easily let c/asm do the heavy lifting and use this for orchestration. 

# Requirements
- Java 20+
- Docker
- Windows, MacOS, Linux
- A Docker image based on Bebbo's amiga-gcc (see docker/amiga-gcc).

# Quick start (for AmigaOS3):

Set up your Docker image for Amiga GCC (using the Docker files in docker/amiga-gcc):
```bash
docker build -f Dockerfile-libpng -t amiga-gcc
```

A simple way to get started is in the works. Until then:

Create the following files:

src/Startup.aml

```java
namespace Am.Examples {    

    class Startup {
        import Am.Lang
        import Am.Lang.Diagnostics

        static fun main() {
            "Hello World".println()
        }
    }
}
```

package.yml
    
```yaml
name: AmigaOS3Example
version: 1.0
description: "Example for AmigaOS3"
dependencies:
  - id: am-lang-core
    realm: github
    type: git-repo
    tag: latest
    url: https://github.com/anderskjeldsen/am-lang-core.git
platforms:
  - id: libc
    abstract: true
  - id: amigaos
    extends: libc
    gccCommand: m68k-amigaos-gcc
    asmCommand: vasmm68k_mot
    gccAdditionalLibraries:
    additionalHeaders:
    additionalAsmSources:
    additionalCSources:
    additionalIncludePaths:
    gccAdditionalOptions:
       - -noixemul     
    gccLibraryPaths:

buildTargets:
  - id: amigaos_docker
    platform: amigaos
    dockerBuild:
      image: amiga-gcc
      buildPath: /host

```

Then run the compiler in the project folder:

```bash
java -jar amlc.jar build .
```

# Code example

The following code fills up a HashSet2 (will be renamed to HashSet) and times it.

```java
namespace Am.Examples {    

    class CoreStartup {
        import Am.Lang
        import Am.Lang.Diagnostics
        import Am.IO
        import Am.IO.Networking
        import Am.Collections

        static fun main() {
            var set = new HashSet2<Int>()
            var startDate = Date.now()
            var i = 1
            var max = 1000000
            ("Adding " + max.toString() + " key-value pairs to a HashSet on an emulated 020").println()
            while(i <= max) {                
                set.add(i)
                i++
            }

            var endDate = Date.now()

            ("Time: " + (endDate.getValue() - startDate.getValue()).toString() + "ms").println()

            var testVal = 4
            var iset = set as Set<Int>
            var hasValue = iset.has(testVal)

            if (hasValue) {
                "found".println()
            } else {
                "not found".println()
            }
        }
    }
}
```

# Try AmLang for yourself

We've made a web-based playground (IDE) that you can try here: https://www.kelson.no/tools/amlangide
