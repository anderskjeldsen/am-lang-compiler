# Threading and Concurrency

Am Lang provides built-in support for threading and concurrent programming through native threading classes and suspend functions for asynchronous operations.

## Threading Overview

Am Lang's threading model is based on:
- **Native Thread class**: Direct mapping to system threads
- **Runnable interface**: For defining thread execution logic
- **Suspend functions**: For asynchronous programming
- **Thread-safe primitives**: Built-in synchronization support

## The Thread Class

### Native Thread Class

The `Thread` class is a native class that wraps system thread functionality:

```amlang
native class Thread(var runnable: Runnable) {
    var name: String
    
    native fun start()
    native fun join()
    
    native static fun getCurrent(): Thread
    native static fun sleep(milliseconds: Long)
}
```

### Creating and Starting Threads

```amlang
class WorkerTask : Runnable {
    override fun run() {
        "Worker thread started".println()
        Thread.sleep(1000)
        "Worker thread completed".println()
    }
}

class Main {
    static fun main() {
        var task = new WorkerTask()
        var thread = new Thread(task)
        thread.name = "Worker Thread"
        
        thread.start()  // Start thread execution
        thread.join()   // Wait for completion
        
        "Main thread finished".println()
    }
}
```

## The Runnable Interface

### Implementing Runnable

The `Runnable` interface defines the contract for thread execution:

```amlang
interface Runnable {
    fun run()
}
```

### Example Implementation

```amlang
class CountdownTask : Runnable {
    private var count: Int
    
    // Note: AmLang Runnable initialization patterns may differ
    fun initializeTask(count: Int) {
        this.count = count
    }
    
    override fun run() {
        for (i in count to 1) {
            "${i}...".println()
            Thread.sleep(1000)
        }
        "Countdown complete!".println()
    }
}

// Usage
var countdown = new CountdownTask(5)
var thread = new Thread(countdown)
thread.start()
```

## Thread Management

### Thread Lifecycle

1. **Created**: Thread object created but not started
2. **Running**: Thread is executing
3. **Sleeping**: Thread is paused
4. **Joined**: Main thread waits for completion
5. **Terminated**: Thread execution completed

```amlang
class ThreadLifecycleDemo {
    static fun main() {
        var task = new SimpleTask()
        var thread = new Thread(task)
        
        "Thread created".println()
        
        thread.start()
        "Thread started".println()
        
        thread.join()
        "Thread completed".println()
    }
}

class SimpleTask : Runnable {
    override fun run() {
        "Task running on thread: ${Thread.getCurrent().name}".println()
        Thread.sleep(2000)
        "Task completed".println()
    }
}
```

### Thread Naming

```amlang
class NamedThreadDemo {
    static fun main() {
        var threads = new Thread[3]
        
        for (i in 0 to 2) {
            var task = new NumberPrinter(i)
            threads[i] = new Thread(task)
            threads[i].name = "Thread-${i}"
            threads[i].start()
        }
        
        // Wait for all threads
        for (i in 0 to 2) {
            threads[i].join()
        }
    }
}

class NumberPrinter : Runnable {
    private var number: Int
    
    // Note: AmLang Runnable initialization patterns may differ
    fun initializePrinter(number: Int) {
        this.number = number
    }
    
    override fun run() {
        var currentThread = Thread.getCurrent()
        "Thread ${currentThread.name} printing: ${number}".println()
    }
}
```

## Suspend Functions

### Suspend Function Declaration

Use the `suspend` keyword to declare asynchronous functions:

```amlang
class AsyncService {
    suspend fun downloadFile(url: String): String {
        "Starting download from ${url}".println()
        Thread.sleep(2000)  // Simulate download time
        return "Downloaded content from ${url}"
    }
    
    suspend fun processData(data: String): String {
        "Processing data: ${data}".println()
        Thread.sleep(1000)  // Simulate processing time
        return "Processed: ${data}"
    }
}
```

### Calling Suspend Functions

```amlang
class AsyncDemo {
    static fun main() {
        var service = new AsyncService()
        
        // Note: Actual async/await syntax may vary
        var content = service.downloadFile("https://example.com/data.txt")
        var result = service.processData(content)
        
        result.println()
    }
}
```

## Concurrent Programming Patterns

### Producer-Consumer Pattern

```amlang
class Buffer<T>(private var maxSize: Int) {
    private var items: T[] = new T[maxSize]
    private var count: Int = 0
    
    fun put(item: T): Bool {
        if (count < maxSize) {
            items[count] = item
            count++
            return true
        }
        return false
    }
    
    fun take(): T? {
        if (count > 0) {
            count--
            return items[count]
        }
        return null
    }
    
    fun isEmpty(): Bool {
        return count == 0
    }
    
    fun isFull(): Bool {
        return count >= maxSize
    }
}

class Producer : Runnable {
    private var buffer: Buffer<String>
    private var itemCount: Int
    
    // Note: AmLang Runnable initialization patterns may differ
    fun initializeProducer(buffer: Buffer<String>, itemCount: Int) {
        this.buffer = buffer
        this.itemCount = itemCount
    }
    
    override fun run() {
        for (i in 1 to itemCount) {
            var item = "Item-${i}"
            while (!buffer.put(item)) {
                Thread.sleep(100)  // Wait if buffer full
            }
            "Produced: ${item}".println()
            Thread.sleep(500)
        }
    }
}

class Consumer : Runnable {
    private var buffer: Buffer<String>
    private var name: String
    
    constructor(buffer: Buffer<String>, name: String) {
        this.buffer = buffer
        this.name = name
    }
    
    override fun run() {
        while (true) {
            var item = buffer.take()
            if (item != null) {
                "${name} consumed: ${item}".println()
                Thread.sleep(1000)
            } else {
                Thread.sleep(200)  // Wait if buffer empty
            }
        }
    }
}
```

### Worker Pool Pattern

```amlang
class Task(private var id: Int, private var data: String) {
    
    fun getId(): Int {
        return this.id
    }
    
    fun getData(): String {
        return this.data
    }
    
    fun execute() {
        "Executing task ${id}: ${data}".println()
        Thread.sleep(2000)  // Simulate work
        "Task ${id} completed".println()
    }
}

class Worker : Runnable {
    private var taskQueue: Queue<Task>
    private var workerId: Int
    
    constructor(taskQueue: Queue<Task>, workerId: Int) {
        this.taskQueue = taskQueue
        this.workerId = workerId
    }
    
    override fun run() {
        "Worker ${workerId} started".println()
        
        while (true) {
            var task = taskQueue.dequeue()
            if (task != null) {
                "Worker ${workerId} processing task ${task.getId()}".println()
                task.execute()
            } else {
                Thread.sleep(100)  // Wait for tasks
            }
        }
    }
}

class ThreadPool {
    private var workers: Thread[]
    private var taskQueue: Queue<Task>
    
    constructor(workerCount: Int) {
        this.workers = new Thread[workerCount]
        this.taskQueue = new Queue<Task>()
        
        for (i in 0 to workerCount - 1) {
            var worker = new Worker(taskQueue, i)
            workers[i] = new Thread(worker)
            workers[i].name = "Worker-${i}"
            workers[i].start()
        }
    }
    
    fun submit(task: Task) {
        taskQueue.enqueue(task)
    }
    
    fun shutdown() {
        for (worker in workers) {
            // Implementation would need thread interruption
        }
    }
}
```

## Thread Safety

### Shared State Protection

```amlang
class Counter {
    private var count: Int = 0
    
    // Note: Actual synchronization mechanisms may vary
    synchronized fun increment() {
        count++
    }
    
    synchronized fun decrement() {
        count--
    }
    
    synchronized fun getValue(): Int {
        return count
    }
}

class CounterTask : Runnable {
    private var counter: Counter
    private var iterations: Int
    private var increment: Bool
    
    constructor(counter: Counter, iterations: Int, increment: Bool) {
        this.counter = counter
        this.iterations = iterations
        this.increment = increment
    }
    
    override fun run() {
        for (i in 1 to iterations) {
            if (increment) {
                counter.increment()
            } else {
                counter.decrement()
            }
        }
    }
}
```

### Thread-Safe Collections

```amlang
class ThreadSafeList<T> {
    private var items: T[]
    private var size: Int = 0
    private var capacity: Int
    
    constructor(capacity: Int) {
        this.capacity = capacity
        this.items = new T[capacity]
    }
    
    synchronized fun add(item: T): Bool {
        if (size < capacity) {
            items[size] = item
            size++
            return true
        }
        return false
    }
    
    synchronized fun get(index: Int): T? {
        if (index >= 0 && index < size) {
            return items[index]
        }
        return null
    }
    
    synchronized fun getSize(): Int {
        return size
    }
}
```

## Async/Await Pattern

### Async Operations

```amlang
class AsyncDownloader {
    suspend fun downloadAsync(url: String): DownloadResult {
        "Starting async download: ${url}".println()
        
        // Simulate async operation
        Thread.sleep(3000)
        
        return new DownloadResult(url, "Downloaded content")
    }
    
    suspend fun downloadMultipleAsync(urls: String[]): DownloadResult[] {
        var results = new DownloadResult[urls.length]
        var threads = new Thread[urls.length]
        
        // Start all downloads concurrently
        for (i in 0 to urls.length - 1) {
            var task = new DownloadTask(urls[i], results, i)
            threads[i] = new Thread(task)
            threads[i].start()
        }
        
        // Wait for all to complete
        for (thread in threads) {
            thread.join()
        }
        
        return results
    }
}

class DownloadTask : Runnable {
    private var url: String
    private var results: DownloadResult[]
    private var index: Int
    
    constructor(url: String, results: DownloadResult[], index: Int) {
        this.url = url
        this.results = results
        this.index = index
    }
    
    override fun run() {
        var downloader = new AsyncDownloader()
        results[index] = downloader.downloadAsync(url)
    }
}

class DownloadResult(var url: String, var content: String) {
}
```

## Complete Threading Example

```amlang
namespace ThreadingExample {
    class Main {
        static fun main() {
            "=== Threading Demo ===".println()
            
            // Simple thread example
            simpleThreadDemo()
            
            // Producer-consumer example
            producerConsumerDemo()
            
            // Async example
            asyncDemo()
        }
        
        static fun simpleThreadDemo() {
            "--- Simple Thread Demo ---".println()
            
            var task1 = new PrintTask("Hello", 3)
            var task2 = new PrintTask("World", 3)
            
            var thread1 = new Thread(task1)
            var thread2 = new Thread(task2)
            
            thread1.name = "Hello Thread"
            thread2.name = "World Thread"
            
            thread1.start()
            thread2.start()
            
            thread1.join()
            thread2.join()
            
            "Simple demo completed".println()
        }
        
        static fun producerConsumerDemo() {
            "--- Producer-Consumer Demo ---".println()
            
            var buffer = new Buffer<String>(5)
            
            var producer = new Producer(buffer, 10)
            var consumer1 = new Consumer(buffer, "Consumer-1")
            var consumer2 = new Consumer(buffer, "Consumer-2")
            
            var producerThread = new Thread(producer)
            var consumerThread1 = new Thread(consumer1)
            var consumerThread2 = new Thread(consumer2)
            
            producerThread.start()
            consumerThread1.start()
            consumerThread2.start()
            
            producerThread.join()
            
            // Let consumers run for a bit then stop demo
            Thread.sleep(5000)
            "Producer-consumer demo completed".println()
        }
        
        static fun asyncDemo() {
            "--- Async Demo ---".println()
            
            var downloader = new AsyncDownloader()
            var urls = new String[] {
                "https://example.com/file1.txt",
                "https://example.com/file2.txt",
                "https://example.com/file3.txt"
            }
            
            var results = downloader.downloadMultipleAsync(urls)
            
            for (result in results) {
                "Downloaded: ${result.url}".println()
            }
            
            "Async demo completed".println()
        }
    }
    
    class PrintTask : Runnable {
        private var message: String
        private var count: Int
        
        constructor(message: String, count: Int) {
            this.message = message
            this.count = count
        }
        
        override fun run() {
            for (i in 1 to count) {
                "${message} ${i}".println()
                Thread.sleep(1000)
            }
        }
    }
}
```

## Best Practices

### 1. Always Join Threads
```amlang
// Good
var thread = new Thread(task)
thread.start()
thread.join()  // Wait for completion

// Poor - may cause premature program termination
var thread = new Thread(task)
thread.start()
// No join() - main thread may exit before worker completes
```

### 2. Handle Thread Exceptions
```amlang
class SafeTask : Runnable {
    override fun run() {
        try {
            // Potentially risky operations
            performWork()
        } catch (e: Exception) {
            "Thread error: ${e.message}".println()
        }
    }
    
    private fun performWork() {
        // Implementation
    }
}
```

### 3. Use Meaningful Thread Names
```amlang
var downloadThread = new Thread(downloadTask)
downloadThread.name = "File-Downloader"

var processingThread = new Thread(processingTask)
processingThread.name = "Data-Processor"
```

### 4. Avoid Shared Mutable State
```amlang
// Good - immutable data sharing
class ImmutableData {
    const var value: String
    
    constructor(value: String) {
        this.value = value
    }
}

// Better - use message passing instead of shared state
class MessagePassingExample {
    // Implementation with queues/channels
}
```

## Next Steps

- Learn about [Native Integration](./12-native-integration.md)
- Explore [Project Structure](./15-project-structure.md)
- Understand [Build Targets](./17-build-targets.md)