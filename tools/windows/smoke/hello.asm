; Smoke test for Windows MASM toolchain
; Prints "Hello from Windows x64!" to stdout and exits with code 42
;
; Build:
;   ml64 /c /nologo hello.asm
;   link /nologo /OUT:hello.exe /ENTRY:main /SUBSYSTEM:CONSOLE hello.obj kernel32.lib
;
; Run:
;   .\hello.exe
;   echo $LASTEXITCODE
;
; Expected output: "Hello from Windows x64!"
; Expected exit code: 42

EXTERN GetStdHandle:PROC
EXTERN WriteConsoleA:PROC
EXTERN ExitProcess:PROC

.data
msg BYTE "Hello from Windows x64!", 13, 10, 0
msg_len EQU $ - msg - 1

.data?
written DWORD ?

.code
main PROC
    sub rsp, 40
    
    mov rcx, -11
    call GetStdHandle
    mov rbx, rax
    
    mov rcx, rbx
    lea rdx, msg
    mov r8d, msg_len
    lea r9, written
    mov QWORD PTR [rsp+32], 0
    call WriteConsoleA
    
    mov rcx, 42
    call ExitProcess
main ENDP
END
