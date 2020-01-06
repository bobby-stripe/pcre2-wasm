# TurboFan compiler issue/bug demo

This repo is branch of [stephen-riley/pcre](https://github.com/stephen-riley/pcre/tree/master) that exposes an issue in the TurboFan compiler.

Short version: after compiling [PCRE2](https://pcre.org/) to WebAssembly using emscripten, when TurboFan optimizes the `pcre2_match()` function, it takes 6-7 seconds to complete with `-O3`, and 80-90 seconds with `-O0` on a 2.3GHz Core i9.  

The most obvious effect is if you were to run a quick node.js script that used this library, you would see your code execute right away (thanks to the first pass of wasm compilation by the Liftoff stage of v8), but then the node process would just hang out until TurboFan completed its work--and _then_ the node process would end.

"The juice ain't worth the squeeze", as it were.  

Interesting note: _all_ WebAssembly functions are processed by TurboFan immediately after Liftoff (what the V8 teams calls _eager tier-up), instead of what's done for Javascript: profiling execution with the interpreter from Ignition's first pass.  You'll see the difference if you execute the repro command below with `--wasm-interpret-all` since TurboFan is bypassed altogether.

## Repro

After cloning the repo:

```bash
npm install && npm run build

node --trace-turbo dist/libpcre2.js
```

(**Note:** as of this commit, `pcre2_match()` ends up being function #11 in the `.wast` file, so you can filter for it with `--trace-turbo-filter="wasm-function#11"`, but YMMV).

## Desired behavior

It would be nice for TurboFan to look at the WebAssembly for `pcre2_match()` and throw its hands up (much like you'll do when you look at the `.wast` file for it 😆).  At the very least, I'd like an option to mark this function as not-to-be-optimized by TurboFan.  Not sure what the right answer is here. 🤔

## Reading

* TurboFan page: https://v8.dev/docs/turbofan
* Liftoff page (which discusses the tiering up of the different compilation passes): https://v8.dev/blog/liftoff
* A fun dive into TurbFan: https://doar-e.github.io/blog/2019/01/28/introduction-to-turbofan/

---

## Old README

### Usage

Internally this module uses the [PCRE2](https://pcre.org/) library, running
in a WebAssembly instance. This has a side effect of requiring you do
a few unusual things when using this module:

#### Initialization

Before calling any constructors or methods, you must first asynchronously initialize the module by calling `init`.

```javascript
import PCRE from '@desertnet/pcre'

async function main () {
  await PCRE.init()
  // make other PCRE calls...
}

main()
```

#### Memory Management

When you create a new `PCRE` instance, you are allocating memory within the
WebAssembly instance. Currently, there are no hooks in JavaScript that
let us automatically free this memory when the `PCRE` instance is garbage
collected by the JavaScript runtime. This means that in order to prevent
memory leaks, you must call `.destroy()` on a `PCRE` instance when it
is no longer needed.

### API

```javascript
import PCRE from '@desertnet/pcre'
```

#### PCRE.init()

Initializes the module, returning a Promise that is resolved once
initialization is complete. You must call this at least once and await the
returned Promise before calling any other `PCRE` methods or constructors.

#### PCRE.version()

Returns a string with the PCRE2 version information.

#### new PCRE(pattern, flags)

Creates a new PCRE instance, using `pcre2_compile()` to compile `pattern`,
using `flags` as the compile options. You must call `.destroy()` on the
returned instance when it is no longer needed to prevent memory leakage.

- `pattern`: A string containing a Perl compatible regular expression.
  Tip: use `String.raw` to avoid needing to escape backslashes.
- `flags`: An optional string with each character representing an option.
  Supported flags are `i`, `m`, `s`, and `x`. See
  [perlre](http://perldoc.perl.org/perlre.html) for details.

```javascript
const pattern = String.raw`\b hello \s* world \b`
const re = new PCRE(pattern, 'ix')

// ...

re.destroy()
```

In the event of a compilation error in the pattern or an unsupported flag,
an `Error` will be thrown with an error message from PCRE2. Additionally, it
will have an `offset` property indicating the character offset in `pattern`
where the error was encountered.

```javascript
let re

try {
  re = new PCRE(String.raw`a)b`)
}
catch (err) {
  console.error(`Compilation failed: ${err.message} at ${err.offset}.`)
  // Prints: Compilation failed: unmatched closing parenthesis at 1.
}
```

### re.destroy()

Releases the memory allocated in the WebAssembly instance. You must call this
method manually once you no longer have a need for the instance, or else
your program will leak memory.

### Contributing

Prerequisites for development include Docker, make and curl.

### Credits

This is a fork of [desertnet/pcre](https://github.com/desertnet/pcre), which provided
the emscripten framework and initial API exposure of PCRE2.  Many thanks!
