# zemac
## Features

- Run compile commands from within Neovim
- Parse errors from multiple compilers (GCC, Go, Rust, TypeScript, Python, Lua)
- Jump to error locations with `next_error` / `prev_error`
- Command history navigation
- Editable command line in compile buffer
- Kill running compilations

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "zepzeper/zemac",
    config = function()
        require("zemac").setup()
    end,
}

```

## Usage

### Commands

| Command | Description |
|---------|-------------|
| `:Compile [cmd]` | Run a compile command (prompts if no cmd given) |
| `:Recompile` | Rerun the last compile command |
| `:NextError` | Jump to next error |
| `:PrevError` | Jump to previous error |
| `:CompileKill` | Kill running compilation |
| `:CompileToggle` | Toggle compile buffer visibility |

### Default Keymaps

**Global:**

| Key | Action |
|-----|--------|
| `<C-z>c` | Open compile prompt |
| `<C-z>r` | Recompile |
| `<C-z>t` | Toggle compile buffer |

**In compile buffer:**

| Key | Action |
|-----|--------|
| `<C-z>q` | Close compile buffer |
| `<C-z>r` | Recompile |
| `<C-z>h` | Run edited command from header |
| `<C-z>k` | Kill compilation |
| `<C-z>p` | Previous command in history (on line 1) |
| `<C-z>n` | Next command in history (on line 1) |
| `<C-z>k` | Next error in history |
| `<C-z>j` | Previous error in history |

## Configuration

```lua
require("zemac").setup({
    -- Default compile command
    compile_command = "make -k",

    -- Save all buffers before compiling
    save_before_compile = true,

    -- Window configuration
    win = {
        position = "bottom",  -- "bottom", "top", "left", "right"
        size = 15,            -- Height for bottom/top, width for left/right
    },

    -- Global keymaps (set to false to disable)
    keymaps = {
        compile = "<C-z>c",
        recompile = "<C-z>r",
        toggle = "<C-z>t",
        next_error = "<C-z>n",
        prev_error = "<C-z>p",
    },

    -- Buffer-local keymaps (set to false to disable)
    buffer_keymaps = {
        quit = "<C-z>q",
        recompile = "<C-z>r",
        run_header = "<C-z>h",
        kill = "<C-z>k",
        goto_error = "<CR>",
        history_prev = "<C-z>n",
        history_next = "<C-z>p",
    },
})
```

## Supported Error Formats

| Compiler | Example |
|----------|---------|
| GCC/Clang | `file.c:10:5: error: message` |
| Go | `./file.go:10:5: message` |
| Rust | `--> file.rs:10:5` |
| TypeScript | `file.ts(10,5): error TS1234: message` |
| Python | `File "file.py", line 10` |
| Lua | `luac: file.lua:10: message` |

## License

MIT

