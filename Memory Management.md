# Memory Management

[Stack vs. Heap quick comparison](https://stackoverflow.com/questions/79923)

## Stack

-   LIFO (Last in, first out) approach, with `push` and `pop` paradigm of addition and removal.
-   All stored data has fixed sizes that are always known.
-   Pushing to stack is faster than allocation to heap—no process is needed to locate where data could be placed.
-   Popping from the stack is faster than accessing from the heap because no lookup process is needed.
-   Integrated tightly into code.
    When a function is called, values passed to the function, and local variables are pushed onto the stack.
    When the function is complete, this data is popped off.

## Heap

Significantly less structured way of storing data. Anything with unknown or changeable size must be stored on the heap.

High level approach to putting data on the heap:

-   Request an amount of space.
-   Memory allocator will find an empty spot that's big enough for your request.
    -   Marked as being used.
-   Pointer to address of memory is returned.
    -   (This pointer can then be stored in the stack).
-   Data with unknown size at compile time, or that may change is stored on the heap.

https://www.metservice.com/publicData/rainRadar/image/Otago/120K/2024-01-03T12:36:00+13:00
https://www.metservice.com/publicData/rainRadar/image/Otago/120K/2024-01-03T13:07:00+13:00
