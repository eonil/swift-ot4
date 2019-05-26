

Performance Considerations
---------------------------------
All input/output collections must be *persistent data structure*
with very fast CoW guaranteed.
Here're required worst case performances.
Required performance is`<= O(logn)`.

- CoW: `O(log n)`
- Lookup: `O(log n)`

For the flat collections, you can easily archive this 
performance by employing tree based data structure.

For hierarchical collections, there're well-know two kind of
approaches. (1) table-based or (2) pointer-based.
Both employ flat collections internally just in different 
distribution and balancing patterm. Final performance
difference is insignificant.

Here're worst case performance list.
Table-based keeps bi-directional links.
Table-based keeps per-node index → ID array with lookup of `O(log(max degree))`.
Table-based keeps per-node key → ID table with lookup of `O(log(max degree))`.   
Pointer-based provides ID or key at each node.
Pointer-based keeps per-node index → subnode array with lookup of `O(log(max degree))`.
Pointer-based provides per-node key → subnode table with lookup of `O(log(max degree))`.

- Table-based CoW: `O(log n)`
- Table-based lookup by ID: `O(log n)`
- Table-based lookup by index-path: `O(log n * depth)`
- Table-based lookup by key-path: `O(log(max degree) * depth)`
- Table-based resolve ID from index-path: `O(log n * log(max degree) * depth)`
- Table-based resolve ID from key-path: `O(log n * log(max degree) * depth)`
- Table-based resolve index-path from ID: `O(log n * max degree * depth)`
- Table-based resolve index-path from key-path: `O(log n * max degree * depth)`
- Table-based resolve key-path from ID: `O(log n * depth)`
- Table-based resolve key-path from index-path: `O(depth * log n)`
- Pointer-based CoW: `O(log n)`
- Pointer-based lookup by ID: `O(n)`
- Pointer-based lookup by index-path: `O(log(max degree) * depth)`
- Pointer-based lookup by key-path: `O(log(max degree) * depth)`
- Pointer-based resolve ID from index-path: `O(log(max degree) * depth)`
- Pointer-based resolve ID from key-path: `O(log(max degree) * depth)`
- Pointer-based resolve index-path from ID: `O(n)`
- Pointer-based resolve index-path from key-path: `O(max degree * depth)`
- Pointer-based resolve key-path from ID: `O(n)`
- Pointer-based resolve key-path from index-path: `O(log(max degree) * depth)`

`O(log n) <= O(depth)`. Usually `depth` is larger than `log n` as
`log n` in B-Tree can be very small. For example, B-Tree with 32 items block
provides `O(4)` lookup time for 32,768 items. And this number is regular and 
constant as internal B-Trees are well-blaanced.

Simplify by regarding small `n` to `1`.
- `O(log n) -> O(1)`
- `O(log(max degree)) -> O(1)`.

- Table-based CoW: `O(1)`
- Table-based lookup by ID: `O(1)`
- Table-based lookup by index-path: `O(depth)`
- Table-based lookup by key-path: `O(depth)`
- Table-based resolve ID from index-path: `O(depth)`
- Table-based resolve ID from key-path: `O(depth)`
- Table-based resolve index-path from ID: `O(max degree * depth)`
- Table-based resolve index-path from key-path: `O(max degree * depth)`
- Table-based resolve key-path from ID: `O(depth)`
- Table-based resolve key-path from index-path: `O(depth)`
- Pointer-based CoW: `O(1)`
- Pointer-based lookup by ID: `O(n)`
- Pointer-based lookup by index-path: `O(depth)`
- Pointer-based lookup by key-path: `O(depth)`
- Pointer-based resolve ID from index-path: `O(depth)`
- Pointer-based resolve ID from key-path: `O(depth)`
- Pointer-based resolve index-path from ID: `O(n)`
- Pointer-based resolve index-path from key-path: `O(max degree * depth)`
- Pointer-based resolve key-path from ID: `O(n)`
- Pointer-based resolve key-path from index-path: `O(depth)`

Sort by time complexity.

- Both CoW: `O(1)`
- Table-based lookup by ID: `O(1)`

- Both lookup by key-path: `O(depth)`
- Both lookup by index-path: `O(depth)`
- Both resolve ID from index-path: `O(depth)`
- Both resolve ID from key-path: `O(depth)`
- Table-based resolve key-path from ID: `O(depth)`
- Both resolve key-path from index-path: `O(depth)`

- Table-based resolve index-path from ID: `O(max degree * depth)`
- Both resolve index-path from key-path: `O(max degree * depth)`

- Pointer-based lookup by ID: `O(n)`
- Pointer-based resolve index-path from ID: `O(n)`
- Pointer-based resolve key-path from ID: `O(n)`

Therefore, 
- Lookup by ID is unacceptable.
- ID/key-path → path resolution is unacceptable.
- Every operations are `<= O(depth)` in table-based except ID → index-path resolution.
- Everything will be based on index-paths.



Best Practices
-----------------
- Prefer table-based hierarchical collection for larger collections with unique ID.
- Index-path (or with unique timestamp) can be used as unique key for read-only or append-only collections.
In this case, key → path resolution becomes `O(1)`.
- You need to define dedicated unique key for randomly mutable collections.  





Reality
-----------
In real worl, performance is controlled by cache hit rate at most.
Therefore pointer-based approach is not recommended because
as it uses explicit pointers, it's hard to hide or abstract out such
pointers. With table based approach, you always use some
kind of flat wrapper to manage data structure sound, and the wrapper
works as an abstraction layer. We can optimize further behind the 
abstraction layer. Also as we have single flat container, it's easier
to collect data together. With pointer based approach, there's no
clear root, though you can configure trees more flexible, but worse
for performance.
