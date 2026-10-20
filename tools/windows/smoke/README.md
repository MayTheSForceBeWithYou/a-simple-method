# Windows Port Smoke Test

This directory contains a minimal smoke test to verify the Windows MASM toolchain.

## Files

- `hello.asm` — Simple program that writes to console and exits with code 42

## Building Locally

From the **x64 Native Tools Command Prompt for VS 2022** (or later):

```batch
cd tools\windows\smoke
ml64 /c /nologo hello.asm
link /nologo /OUT:hello.exe /ENTRY:main /SUBSYSTEM:CONSOLE hello.obj kernel32.lib
```

## Running

```batch
.\hello.exe
echo %ERRORLEVEL%
```

**Expected output:**
```
Hello from Windows x64!
```

**Expected exit code:** 42

## CI

This smoke test runs automatically in GitHub Actions on every push to `windows-port` or PRs into `windows-port`. See `.github/workflows/windows.yml`.
