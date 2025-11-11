# 3D Engine in Assembly: From Zero to Wireframe

This is a long-term, challenging project. This plan assumes you are starting with **zero** knowledge of Assembly. The goal is to create a simple, software-based **wireframe** 3D renderer (think a rotating cube) written entirely in Assembly.

**Prerequisites:**
* **Patience:** This is the most important one.
* **Strong Math:** You need to be comfortable with algebra and trigonometry. We will learn the 3D-specific math (vectors, matrices) as we go.
* **An OS:** We'll target 64-bit Linux (it's generally easier for low-level programming) using NASM as the assembler.

---

## Phase 1: Assembly Fundamentals (Weeks 1-8)
**Goal:** Learn to write, assemble, link, and debug basic Assembly programs. This phase has nothing to do with graphics, only core concepts.

* **Week 1: Setup & "Hello, World!"**
    * **Goal:** Get your tools running.
    * **Tasks:**
        * Install an x86-64 assembler (NASM is recommended) and a linker (like `ld`).
        * Install a debugger (GDB).
        * Learn what registers are (e.g., `RAX`, `RBX`, `RCX`, `RDI`, `RSI`).
        * Learn how to write a "Hello, World!" program using Linux `sys_write` and `sys_exit` system calls.
        * Learn the commands to assemble (`nasm`) and link (`ld`).

* **Week 2: Memory & Data**
    * **Goal:** Understand how your program uses memory.
    * **Tasks:**
        * Learn the `.data`, `.bss`, and `.text` sections.
        * Define variables of different sizes (bytes `db`, words `dw`, dwords `dd`, qwords `dq`).
        * Learn memory addressing modes: `[RAX]`, `[RAX + 8]`, `[RBP - 16]`.
        * Practice moving data between registers and memory.

* **Week 3: Basic Arithmetic**
    * **Goal:** Perform simple math operations.
    * **Tasks:**
        * Learn `ADD`, `SUB`, `INC` (increment), `DEC` (decrement).
        * Write a program that adds two numbers from memory and prints the result (this is harder than it sounds, as you must convert the number to a string to print it).
        * Learn `MUL` (multiply) and `DIV` (divide).

* **Week 4: Control Flow (Jumps)**
    * **Goal:** Create loops and `if` statements.
    * **Tasks:**
        * Learn `CMP` (compare), `JMP` (unconditional jump).
        * Learn conditional jumps: `JE` (jump if equal), `JNE` (not equal), `JG` (greater), `JL` (less), etc.
        * Write a "fizzbuzz" program in Assembly.
        * Write a loop that prints the numbers 1 to 10.

* **Week 5: The Stack**
    * **Goal:** Understand the most critical data structure in Assembly.
    * **Tasks:**
        * Learn `PUSH` and `POP`.
        * Understand how the stack grows (downwards) and how the stack pointer (`RSP`) works.
        * Practice saving and restoring register values using the stack.

* **Week 6: Functions**
    * **Goal:** Write reusable code.
    * **Tasks:**
        * Learn `CALL` and `RET`.
        * Understand the "C" calling convention (how to pass arguments in registers `RDI`, `RSI`, `RDX`... and get a return value in `RAX`).

* **Week 7: Writing a Simple Library**
    * **Goal:** Combine your knowledge to make useful tools.
    * **Tasks:**
        * Write a function `print_string` that takes a pointer to a null-terminated string and prints it.
        * Write a function `print_uint` that takes an unsigned 64-bit integer, converts it to a string, and prints it. This is a challenging but essential function.

* **Week 8: Debugging**
    * **Goal:** Master your debugger.
    * **Tasks:**
        * Spend this week entirely in GDB.
        * Learn to set breakpoints (`b main`), step through code (`s`, `n`), inspect registers (`info reg`), and examine memory (`x/64b $RSP`).
        * You cannot proceed without being comfortable in a debugger.

---

## Phase 2: Graphics Fundamentals (Weeks 9-16)
**Goal:** Open a window and draw a pixel on the screen. This is a *massive* hurdle. We will use the simple Linux Framebuffer (`/dev/fb0`) to avoid the complexity of X11 or Wayland.

* **Week 9: Linux Framebuffer Basics**
    * **Goal:** Understand how to "open" the screen.
    * **Tasks:**
        * Learn to use the `sys_open` syscall to get a file handle for `/dev/fb0`.
        * **Note:** You will likely need `sudo` to run your program.
        * Learn about `ioctl` syscalls to get screen info (width, height, color depth).

* **Week 10: Memory Mapping (mmap)**
    * **Goal:** Get a direct pointer to the screen's memory.
    * **Tasks:**
        * Learn to use the `sys_mmap` syscall to map the framebuffer's memory into your program's address space.
        * You will now have a pointer (e.g., in `RAX`) to the start of the pixel data on your screen.

* **Week 11: Drawing a Pixel**
    * **Goal:** Change the color of a single pixel.
    * **Tasks:**
        * Understand the pixel format (e.g., 32-bit: 8 bits for Alpha, 8 for Red, 8 for Green, 8 for Blue).
        * Write the Assembly to calculate a pixel's offset: `offset = (y * screen_width + x) * 4`.
        * Write a `draw_pixel(x, y, color)` function in Assembly.
        * Test it by drawing a single red pixel in the middle of the screen.

* **Week 12: Drawing a Line (Bresenham's Algorithm)**
    * **Goal:** Implement a line-drawing algorithm.
    * **Tasks:**
        * Research Bresenham's line algorithm. It uses only integer math, making it perfect for Assembly.
        * Implement `draw_line(x1, y1, x2, y2, color)` in Assembly, using your `draw_pixel` function.
        * Test by drawing lines across the screen.

* **Week 13: Drawing a Wireframe Triangle**
    * **Goal:** Combine lines to make a shape.
    * **Tasks:**
        * Write a `draw_triangle(x1, y1, x2, y2, x3, y3, color)` function.
        * This function simply calls `draw_line` three times.

* **Week 14-16: Refactor & Double Buffering**
    * **Goal:** Create an off-screen buffer for smooth animation (to prevent flickering).
    * **Tasks:**
        * Use `sys_mmap` again, but this time to allocate a *private* block of memory the same size as the screen. This is your "back buffer".
        * All your drawing functions (`draw_pixel`, `draw_line`) should now draw to this *back buffer*.
        * Create a `swap_buffers` function that does a high-speed memory copy (`REP MOVSQ`) from your back buffer to the real framebuffer.
        * Create a `clear_screen` function that fills your back buffer with black (or 0).

---

## Phase 3: 3D Math & Data Structures (Weeks 17-24)
**Goal:** Implement the core 3D math routines. This is all math, no drawing yet.

* **Week 17: Fixed-Point Math**
    * **Goal:** Implement fast math without a Floating Point Unit (FPU).
    * **Tasks:**
        * Learn the concept of fixed-point numbers (e.g., use 64-bit integers, where the top 32 bits are the integer part and the bottom 32 are the fractional part).
        * Write functions: `fixed_add`, `fixed_sub`, `fixed_mul`, `fixed_div`.
        * This is a traditional way to do fast 3D math in Assembly. (Alternatively, you could learn to use the FPU/SSE registers, but this is a *much* steeper learning curve).

* **Week 18: Vector & Model Data**
    * **Goal:** Define 3D data structures.
    * **Tasks:**
        * Define a `vec3d` structure (e.g., three 64-bit fixed-point numbers for x, y, z).
        * Define a `triangle` structure (e.g., three indices into a vertex list).
        * Create a global model in your `.data` section: a vertex list and a triangle (edge) list for a **cube**.

* **Week 19: Vector Math**
    * **Goal:** Implement 3D vector operations.
    * **Tasks:**
        * Write functions for: `vector_add`, `vector_sub`, `vector_dot_product`, `vector_cross_product`.
        * These will be heavily used.

* **Week 20: 4x4 Matrices**
    * **Goal:** Define matrix structures and a multiplication function.
    * **Tasks:**
        * Define a 4x4 matrix structure (an array of 16 fixed-point numbers).
        * Write the *most important function of your engine*: `matrix_multiply(mat_a, mat_b, mat_out)`. This will be a big, heavily-optimized function with many loops.

* **Week 21: Transformation Matrices**
    * **Goal:** Create matrices that can move, rotate, and scale objects.
    * **Tasks:**
        * Write functions to create identity, translation, scaling, and rotation matrices (e.g., `matrix_make_rotation_z(angle)`).
        * You'll need `sin` and `cos` functions. Start by using a pre-computed lookup table for speed.

* **Week 22: The Projection Matrix**
    * **Goal:** Create the matrix that converts 3D to 2D.
    * **Tasks:**
        * Research and implement `matrix_make_perspective`. This is the "camera lens" of your engine. It takes field-of-view, aspect ratio, and near/far clip planes as inputs.

* **Week 23-24: Testing the Math**
    * **Goal:** Verify all your math functions work.
    * **Tasks:**
        * Write Assembly test programs that:
            * Multiply a vector by a translation matrix and print the result.
            * Multiply two matrices and print the result.
        * Use your `print_uint` (or a new `print_fixed`) function to debug. **Do not skip this!** Bugs in the math code are impossible to find once you start drawing.

---

## Phase 4: Building the Engine (Weeks 25-32+)
**Goal:** Combine the math and graphics to draw a 3D object.

* **Week 25: The Render Pipeline (Concept)**
    * **Goal:** Whiteboard the flow of data.
    * **Tasks:**
        * Understand the steps:
            1.  Start with cube model (vertices).
            2.  Create transformation matrices (translation, rotation).
            3.  Combine matrices (e.g., `transform = rotation_x * rotation_y`).
            4.  Loop through every vertex in the cube:
                * Transform vertex with `transform` matrix.
                * Project vertex with `projection` matrix.
            5.  Loop through every triangle (edge) in the cube:
                * Get the 3 projected (2D) vertices.
                * Call `draw_triangle` on them.

* **Week 26: Vertex Transformation**
    * **Goal:** Write the "vertex shader" part of the pipeline.
    * **Tasks:**
        * Write a function `transform_vertex(vertex_in, matrix, vertex_out)`. This function multiplies a `vec3d` by a 4x4 matrix.
        * Write the main loop that iterates all vertices in your cube model and stores the results in a new "transformed_vertices" list.

* **Week 27: Projection & 2D Conversion**
    * **Goal:** Convert the 3D transformed vertices into 2D screen coordinates.
    * **Tasks:**
        * Run all transformed vertices through the `projection` matrix.
        * Perform "perspective divide" (divide x and y by z).
        * "Screen transform": Scale and offset the -1.0 to +1.0 coordinates to your screen size (e.g., 0 to 1920).
        * Store these final 2D coordinates.

* **Week 28: Putting It All Together**
    * **Goal:** See a cube on the screen.
    * **Tasks:**
        * Write the main render loop:
            1.  `clear_screen()`
            2.  Build your transform matrices.
            3.  Loop 1: Transform & project all vertices.
            4.  Loop 2: Get the 2D screen coords for each triangle's vertices and call `draw_triangle()`.
            5.  `swap_buffers()`
            6.  `JMP` back to step 1.

* **Week 29-32+: Animation & Optimization**
    * **Goal:** Make the cube rotate.
    * **Tasks:**
        * Create a global `angle` variable.
        * In your main loop, `INC angle` every frame.
        * Use this `angle` variable to rebuild your rotation matrix (`matrix_make_rotation_y(angle)`) every frame.
    * **Optimization:**
        * Go back to your math functions (`matrix_multiply`, `transform_vertex`).
        * Unroll loops, keep values in registers, and try to make them as fast as humanly possible. This is where Assembly shines.
        * Start learning SIMD instructions (SSE/AVX) to perform 4 math operations at once. This is the next level.