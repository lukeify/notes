# Rust

## Ownership

[Ownership](https://doc.rust-lang.org/book/ch04-01-what-is-ownership.html) involves managing accessing, cleaning up, and tracking data stored in the heap.
Rules of ownership:

* Each value has an owner.
* Only one owner allowed simultaneously.
* Owner goes out of scope = value is dropped.

```rust
{
    let s = String::from("hello."); // s is valid from this point forward
}
```

At the end of the scope, denoted by the braces, `s` is no longer valid and is deallocated from the heap, as Rust internally calls [`drop`](https://doc.rust-lang.org/std/ops/trait.Drop.html#tymethod.drop).
This can also be seen with heap-allocated variables being duplicated (only one owner allowed).

```rust
let s1 = String::from("hello.");
let s2 = s1;
```

In this scenario s1 and s2 both are values that contain a pointer to the _same address in memory_ for the heap-stored data.

When `s2` is assigned, `s1` becomes invalid because if both were to go out of scope simultaneously, they will both be freed from memory simultaneously—despite pointing to only one location in memory.
This is known as a _double free error_ and rust prevents this.

Thus, Rust nearly always _shallow copies_ data, also known in Rust terms as a "move". The underlying data on the heap is not touched, only the pointer and metadata to it.
To perform what would be called a _deep copy_ in Rust, the `clone` method exists:

```rust
let s1 = String::from("hello");
let s2 = s1.clone();
```

Both `s1` and `s2` are valid at the end of this code example.

## `Copy` trait

## Strings

**`String`** is a dynamic vector of bytes (`Vec<u8>`) and is heap-allocated, growable, UTF-8 encoded, and not [null-terminated](https://en.wikipedia.org/wiki/Null-terminated_string).
It is an _owned type_ (as it owns the underlying bytes representing the string) and is frankly the easiest to understand data type here.
It consists of a pointer to the string on the heap, its length, and its capacity.
It can be [defined](https://doc.rust-lang.org/src/alloc/string.rs.html#365-367) at a high level as:

```rust
pub struct String {
    vec: Vec<u8>
}
```

(With an addition that the bytes of the `vec` are guaranteed to be valid UTF-8).

**`&str`** is a _string slice_, also known as a "view into a string".
It consists of a pointer to the string, and the string length, offering a view into a string.
It is called a _borrowed type_, because it doesn't own the underlying data, and are immutable (and is therefore not growable).

```rust
let my_string: String = String::from("Hello!":);
let my_string_slice: &str = &my_string;
```

The pointer can point to _either_ data on the heap, data in the compiled binary (in the case of string literals), or on the stack.

The string slice is made up of two parts:

* The `str` type. This cannot be used directly because its size is not known at compile time.
* The reference operator (`&`). We use this to get a pointer to the bytes of the string and its length.

A **string literal** is a `&str` that is stored within the compiled binary itself:

```rust
let my_string_literal = "Hello, world!"; // Type is `&str`, which is syntactic sugar for `&'static str`.
```

When declared like this, they are hardcoded into the final executable as they are known at compile-time.
String literals have a "static lifetime", which is to say their lifetime persists for the duration of the program execution.

* [Summary comparison from StackOverflow](https://stackoverflow.com/a/24159933)
* [All Rust string types explained (Let's Get Rusty)](https://www.youtube.com/watch?v=CpvzeyzgQdw)

## Pointers

Types:

* "Reference"

## `Box`

`Box` data types are pointers that store data in the heap.

## `dyn` keyword

If instead of returning a known concrete object, a function returns a `trait`; then the size of the object cannot be known at compile-time; as even though each concrete implementation will adhere to the trait, the object size will differ.

Thus, the return type is said to be "dynamic", and the `dyn` keyword is needed to prefix the trait name in the return type
([before Edition 2021 though, this keyword could be omitted](https://doc.rust-lang.org/reference/types/trait-object.html)).
Additionally, this will be wrapped in a `Box` to heap-allocate it.
Thus, the return type is actually a pointer reference to memory on the heap.

```rust
fn get_random_traitable() -> Box<dyn MyTrait> {
    // ...
}
```

[Rust by example](https://doc.rust-lang.org/rust-by-example/trait/dyn.html) reference.

## `pub(crate)` for struct members

## Attributes

### `derive(Debug)`

## "Dynamic dispatch"

## Apostrophes (related to types)

## Lifetimes
