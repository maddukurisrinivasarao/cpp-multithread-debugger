# C++/Qt Multithread Debugging Starter

This repository contains starter files for capturing Windows CDB thread stacks from a C++/Qt application running in batch mode, plus three VS Code custom agents to help interpret the results.

It does **not** include the application source, executable, batch input, or build configuration. Add or use these files alongside the application repository, and replace the example breakpoint with a real symbol from your application.

## Repository Contents

- [`run.bat`](run.bat): launches the application under CDB and saves the debugger transcript to `debug.log` in this directory.
- [`capture.dbg`](capture.dbg): configures symbols and captures every thread's stack when the configured worker breakpoint is hit.
- [`.github/agents/multithread-debug.agent.md`](.github/agents/multithread-debug.agent.md): runs and reports a batch-mode debug capture.
- [`.github/agents/multithread-analysis.agent.md`](.github/agents/multithread-analysis.agent.md): maps captured stacks to source code, threads, and data structures.
- [`.github/agents/multithread-response.agent.md`](.github/agents/multithread-response.agent.md): answers developer questions and suggests evidence-based changes.

## Prerequisites

- Windows.
- CDB from Microsoft's Debugging Tools for Windows, available as `cdb.exe` on `PATH`.
- The application executable and the matching PDB files for the executable and relevant libraries. Build with debug symbols and do not strip or mismatch the PDBs.
- The batch-mode arguments or input files required by the application.
- VS Code with custom agents enabled to use the `.github/agents` workflow.

## Configure the Breakpoint

Edit [`capture.dbg`](capture.dbg) and replace the example module and function:

```text
bu MyApp!Namespace::Worker::run ".echo --- Worker::run ---; .time; ~* kb; g"
```

Use the executable's module name (usually without `.exe`) and a function symbol present in the matching PDB. For example, change `MyApp` and `Namespace::Worker::run` to your module and worker entry point. You can add more breakpoint commands for task dispatch or completion points. Each command prints all thread stacks and continues execution.

If the breakpoint does not resolve or hit, verify the module and symbol names against the PDB and confirm that the batch run reaches that function. CDB's `x` command can search loaded symbols, for example `x MyApp!*Worker*`.

## Run a Batch Capture

From a Windows Command Prompt or PowerShell, run:

```bat
run.bat "C:\path\to\MyApp.exe" --batch-mode "C:\path\to\input.dat"
```

Pass the application's executable first, followed by its normal command-line arguments. The script checks that CDB is on `PATH`, launches CDB with [`capture.dbg`](capture.dbg), and writes the CDB transcript to `debug.log`. Check the script's exit code and the log to confirm whether the breakpoint was hit and stacks were captured.

The log is written beside `run.bat`; CDB's `-logo` option creates or replaces the transcript for a run. Preserve or rename a log before the next run if you need to keep it.

## Use the VS Code Agents

Open this folder as a VS Code workspace, then select **Multithread Debug** in the agent picker and provide:

- The executable path and batch arguments/input.
- The worker symbol configured in `capture.dbg`.
- The developer question you want answered.

After a successful capture, use the **Analyze Captured Run** handoff to send the report and `debug.log` to **Multithread Analysis**. Then use **Answer Developer Question** to send the analysis and original question to **Multithread Response**. These handoffs are suggestions and require confirmation; they do not automatically submit. The analysis and response agents are read-only and will cite source locations when source is available.

The Debug agent must run on Windows with CDB and access to the application binary. From macOS or another unsupported environment, you can still read the agent definitions and analyze an existing `debug.log`, but you cannot run `run.bat` or capture Windows stacks there.

## Interpreting the Capture

Each all-thread stack is a snapshot taken when its breakpoint is hit. It does not, on its own, establish event order, prove a race or deadlock, or show the complete workflow. Use multiple meaningful breakpoints and application logging or tracing when ordering matters. Treat unresolved symbols and missing PDBs as limitations, not evidence that a thread has no useful work.

## Troubleshooting

- **`cdb.exe` not found:** install Debugging Tools for Windows or add the directory containing `cdb.exe` to `PATH`.
- **No useful function names:** use matching PDBs and confirm symbols are loaded.
- **Breakpoint not hit:** check the module/function name, mode selection, and whether the batch input exercises that path.
- **No `debug.log`:** run `run.bat` from a Windows environment and check that CDB starts and can write to this directory.
- **Agents not visible:** open the repository root as a VS Code workspace and check the agent picker/customization diagnostics for `.github/agents` loading issues.