# PoisonOS Roadmap

PoisonOS is an operating-system layer written entirely in Elixir. It runs on the
BEAM VM; a minimal boot layer (for example Nerves) can host it later. Everything
above that layer is Elixir.

Tasks are worked top to bottom, one per day. Add new `- [ ]` lines at any time.
Pure data-structure modules come first because they are the easiest to get right;
process-based modules follow.

- [x] Scheduler (`PoisonOS.Scheduler`): a pure round-robin scheduler struct with new, enqueue, next, tick and remove
- [x] Memory manager (`PoisonOS.Memory`): a pure page-allocator simulation with new, alloc, free and stats
- [x] Virtual filesystem (`PoisonOS.FS`): an in-memory tree with mkdir, write, read, ls and rm as a pure data structure
- [x] Shell parser (`PoisonOS.Shell.Parser`): split a command line into a command and a list of args on spaces; text inside double quotes counts as one argument (no escapes, no single quotes). Use String.graphemes/1, not character literals
- [x] IPC (`PoisonOS.IPC`): message-passing mailboxes with send, receive and broadcast
- [x] Application supervisor (`PoisonOS.Application`): a supervision tree starting the core services, wired in mix.exs
- [ ] Boot sequence (`PoisonOS.Boot`): ordered startup of services with logging
- [ ] Shell built-ins (`PoisonOS.Shell`): `exec(command, args, fs)` returns `{:ok, output_string, new_fs}` or `{:error, reason_string, fs}`. Supports echo (output is the args joined by one space), mkdir (output is an empty string), ls (output is the entry names joined by newlines) and cat (output is the file content), using the public functions of `PoisonOS.FS`. An unknown command returns `{:error, "unknown command", fs}`
- [ ] Process table (`PoisonOS.ProcessTable`): use Agent; `start_link(opts)` accepts a `:name`. `register(table, name, pid, state)` returns `:ok` or `{:error, :exists}`; `lookup(table, name)` returns `{:ok, %{pid: pid, state: state}}` or `:error`; `update_state(table, name, state)` returns `:ok` or `:error`; `unregister(table, name)` returns `:ok`; `all(table)` returns a map of name to record
- [ ] Syscall layer (`PoisonOS.Syscall`): a GenServer exposing the process table, memory and filesystem through one API
