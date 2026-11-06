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
- [ ] Shell parser (`PoisonOS.Shell.Parser`): parse a command line into a command and args, handling quoted arguments
- [ ] Shell built-ins (`PoisonOS.Shell`): dispatch echo, ls, cat and mkdir against the virtual filesystem
- [ ] Process table (`PoisonOS.ProcessTable`): an Agent-backed registry of process records (pid, name, state) with register, lookup, update_state and unregister
- [ ] IPC (`PoisonOS.IPC`): message-passing mailboxes with send, receive and broadcast
- [ ] Syscall layer (`PoisonOS.Syscall`): a GenServer exposing the process table, memory and filesystem through one API
- [ ] Application supervisor (`PoisonOS.Application`): a supervision tree starting the core services, wired in mix.exs
- [ ] Boot sequence (`PoisonOS.Boot`): ordered startup of services with logging
