
obj/user/fairness.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 91 00 00 00       	call   8000c2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 20             	sub    $0x20,%esp
  envid_t who, id;

  id = sys_getenvid();
  80003b:	e8 85 0b 00 00       	call   800bc5 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

  if (thisenv == &envs[1]) {
  800042:	81 3d 04 40 80 00 7c 	cmpl   $0xeec0007c,0x804004
  800049:	00 c0 ee 
  80004c:	75 34                	jne    800082 <umain+0x4f>
    while (1) {
      ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800058:	00 
  800059:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800060:	00 
  800061:	89 34 24             	mov    %esi,(%esp)
  800064:	e8 02 0e 00 00       	call   800e6b <ipc_recv>
      cprintf("%x recv from %x\n", id, who);
  800069:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80006c:	89 54 24 08          	mov    %edx,0x8(%esp)
  800070:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800074:	c7 04 24 20 20 80 00 	movl   $0x802020,(%esp)
  80007b:	e8 46 01 00 00       	call   8001c6 <cprintf>
  800080:	eb cf                	jmp    800051 <umain+0x1e>
    }
  } else {
    cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800082:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800087:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008f:	c7 04 24 31 20 80 00 	movl   $0x802031,(%esp)
  800096:	e8 2b 01 00 00       	call   8001c6 <cprintf>
    while (1)
      ipc_send(envs[1].env_id, 0, 0, 0);
  80009b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  8000a0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000a7:	00 
  8000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000af:	00 
  8000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b7:	00 
  8000b8:	89 04 24             	mov    %eax,(%esp)
  8000bb:	e8 31 0e 00 00       	call   800ef1 <ipc_send>
  8000c0:	eb d9                	jmp    80009b <umain+0x68>

008000c2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	56                   	push   %esi
  8000c6:	53                   	push   %ebx
  8000c7:	83 ec 10             	sub    $0x10,%esp
  8000ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000cd:	8b 75 0c             	mov    0xc(%ebp),%esi
  // set thisenv to point at our Env structure in envs[].
  // LAB 3: Your code here.
  thisenv = envs + ENVX(sys_getenvid());
  8000d0:	e8 f0 0a 00 00       	call   800bc5 <sys_getenvid>
  8000d5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000da:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000dd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e2:	a3 04 40 80 00       	mov    %eax,0x804004

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000e7:	85 db                	test   %ebx,%ebx
  8000e9:	7e 07                	jle    8000f2 <libmain+0x30>
    binaryname = argv[0];
  8000eb:	8b 06                	mov    (%esi),%eax
  8000ed:	a3 00 30 80 00       	mov    %eax,0x803000

  // call user main routine
  umain(argc, argv);
  8000f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000f6:	89 1c 24             	mov    %ebx,(%esp)
  8000f9:	e8 35 ff ff ff       	call   800033 <umain>

  // exit gracefully
  exit();
  8000fe:	e8 07 00 00 00       	call   80010a <exit>
}
  800103:	83 c4 10             	add    $0x10,%esp
  800106:	5b                   	pop    %ebx
  800107:	5e                   	pop    %esi
  800108:	5d                   	pop    %ebp
  800109:	c3                   	ret    

0080010a <exit>:
#include <inc/lib.h>

void
exit(void)
{
  80010a:	55                   	push   %ebp
  80010b:	89 e5                	mov    %esp,%ebp
  80010d:	83 ec 18             	sub    $0x18,%esp
  close_all();
  800110:	e8 60 10 00 00       	call   801175 <close_all>
  sys_env_destroy(0);
  800115:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80011c:	e8 52 0a 00 00       	call   800b73 <sys_env_destroy>
}
  800121:	c9                   	leave  
  800122:	c3                   	ret    

00800123 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800123:	55                   	push   %ebp
  800124:	89 e5                	mov    %esp,%ebp
  800126:	53                   	push   %ebx
  800127:	83 ec 14             	sub    $0x14,%esp
  80012a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  b->buf[b->idx++] = ch;
  80012d:	8b 13                	mov    (%ebx),%edx
  80012f:	8d 42 01             	lea    0x1(%edx),%eax
  800132:	89 03                	mov    %eax,(%ebx)
  800134:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800137:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
  if (b->idx == 256-1) {
  80013b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800140:	75 19                	jne    80015b <putch+0x38>
    sys_cputs(b->buf, b->idx);
  800142:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800149:	00 
  80014a:	8d 43 08             	lea    0x8(%ebx),%eax
  80014d:	89 04 24             	mov    %eax,(%esp)
  800150:	e8 e1 09 00 00       	call   800b36 <sys_cputs>
    b->idx = 0;
  800155:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  }
  b->cnt++;
  80015b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015f:	83 c4 14             	add    $0x14,%esp
  800162:	5b                   	pop    %ebx
  800163:	5d                   	pop    %ebp
  800164:	c3                   	ret    

00800165 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	81 ec 28 01 00 00    	sub    $0x128,%esp
  struct printbuf b;

  b.idx = 0;
  80016e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800175:	00 00 00 
  b.cnt = 0;
  800178:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017f:	00 00 00 
  vprintfmt((void*)putch, &b, fmt, ap);
  800182:	8b 45 0c             	mov    0xc(%ebp),%eax
  800185:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800189:	8b 45 08             	mov    0x8(%ebp),%eax
  80018c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800190:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800196:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019a:	c7 04 24 23 01 80 00 	movl   $0x800123,(%esp)
  8001a1:	e8 a8 01 00 00       	call   80034e <vprintfmt>
  sys_cputs(b.buf, b.idx);
  8001a6:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b6:	89 04 24             	mov    %eax,(%esp)
  8001b9:	e8 78 09 00 00       	call   800b36 <sys_cputs>

  return b.cnt;
}
  8001be:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c4:	c9                   	leave  
  8001c5:	c3                   	ret    

008001c6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8001cc:	8d 45 0c             	lea    0xc(%ebp),%eax
  cnt = vcprintf(fmt, ap);
  8001cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d6:	89 04 24             	mov    %eax,(%esp)
  8001d9:	e8 87 ff ff ff       	call   800165 <vcprintf>
  va_end(ap);

  return cnt;
}
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
         unsigned long long num, unsigned base, int width, int padc)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
  8001e6:	83 ec 3c             	sub    $0x3c,%esp
  8001e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001ec:	89 d7                	mov    %edx,%edi
  8001ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f7:	89 c3                	mov    %eax,%ebx
  8001f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ff:	8b 75 14             	mov    0x14(%ebp),%esi
  // first recursively print all preceding (more significant) digits
  if (num >= base)
  800202:	b9 00 00 00 00       	mov    $0x0,%ecx
  800207:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80020a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80020d:	39 d9                	cmp    %ebx,%ecx
  80020f:	72 05                	jb     800216 <printnum+0x36>
  800211:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800214:	77 69                	ja     80027f <printnum+0x9f>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  800216:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800219:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80021d:	83 ee 01             	sub    $0x1,%esi
  800220:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800224:	89 44 24 08          	mov    %eax,0x8(%esp)
  800228:	8b 44 24 08          	mov    0x8(%esp),%eax
  80022c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800230:	89 c3                	mov    %eax,%ebx
  800232:	89 d6                	mov    %edx,%esi
  800234:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800237:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80023a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80023e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800242:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800245:	89 04 24             	mov    %eax,(%esp)
  800248:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80024b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024f:	e8 3c 1b 00 00       	call   801d90 <__udivdi3>
  800254:	89 d9                	mov    %ebx,%ecx
  800256:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80025a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80025e:	89 04 24             	mov    %eax,(%esp)
  800261:	89 54 24 04          	mov    %edx,0x4(%esp)
  800265:	89 fa                	mov    %edi,%edx
  800267:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80026a:	e8 71 ff ff ff       	call   8001e0 <printnum>
  80026f:	eb 1b                	jmp    80028c <printnum+0xac>
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
      putch(padc, putdat);
  800271:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800275:	8b 45 18             	mov    0x18(%ebp),%eax
  800278:	89 04 24             	mov    %eax,(%esp)
  80027b:	ff d3                	call   *%ebx
  80027d:	eb 03                	jmp    800282 <printnum+0xa2>
  80027f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  // first recursively print all preceding (more significant) digits
  if (num >= base)
    printnum(putch, putdat, num / base, base, width - 1, padc);
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
  800282:	83 ee 01             	sub    $0x1,%esi
  800285:	85 f6                	test   %esi,%esi
  800287:	7f e8                	jg     800271 <printnum+0x91>
  800289:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
      putch(padc, putdat);
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  80028c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800290:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800294:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800297:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80029a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80029e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002a5:	89 04 24             	mov    %eax,(%esp)
  8002a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002af:	e8 0c 1c 00 00       	call   801ec0 <__umoddi3>
  8002b4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b8:	0f be 80 52 20 80 00 	movsbl 0x802052(%eax),%eax
  8002bf:	89 04 24             	mov    %eax,(%esp)
  8002c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002c5:	ff d0                	call   *%eax
}
  8002c7:	83 c4 3c             	add    $0x3c,%esp
  8002ca:	5b                   	pop    %ebx
  8002cb:	5e                   	pop    %esi
  8002cc:	5f                   	pop    %edi
  8002cd:	5d                   	pop    %ebp
  8002ce:	c3                   	ret    

008002cf <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
  if (lflag >= 2)
  8002d2:	83 fa 01             	cmp    $0x1,%edx
  8002d5:	7e 0e                	jle    8002e5 <getuint+0x16>
    return va_arg(*ap, unsigned long long);
  8002d7:	8b 10                	mov    (%eax),%edx
  8002d9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002dc:	89 08                	mov    %ecx,(%eax)
  8002de:	8b 02                	mov    (%edx),%eax
  8002e0:	8b 52 04             	mov    0x4(%edx),%edx
  8002e3:	eb 22                	jmp    800307 <getuint+0x38>
  else if (lflag)
  8002e5:	85 d2                	test   %edx,%edx
  8002e7:	74 10                	je     8002f9 <getuint+0x2a>
    return va_arg(*ap, unsigned long);
  8002e9:	8b 10                	mov    (%eax),%edx
  8002eb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ee:	89 08                	mov    %ecx,(%eax)
  8002f0:	8b 02                	mov    (%edx),%eax
  8002f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f7:	eb 0e                	jmp    800307 <getuint+0x38>
  else
    return va_arg(*ap, unsigned int);
  8002f9:	8b 10                	mov    (%eax),%edx
  8002fb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fe:	89 08                	mov    %ecx,(%eax)
  800300:	8b 02                	mov    (%edx),%eax
  800302:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800307:	5d                   	pop    %ebp
  800308:	c3                   	ret    

00800309 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800309:	55                   	push   %ebp
  80030a:	89 e5                	mov    %esp,%ebp
  80030c:	8b 45 0c             	mov    0xc(%ebp),%eax
  b->cnt++;
  80030f:	83 40 08 01          	addl   $0x1,0x8(%eax)
  if (b->buf < b->ebuf)
  800313:	8b 10                	mov    (%eax),%edx
  800315:	3b 50 04             	cmp    0x4(%eax),%edx
  800318:	73 0a                	jae    800324 <sprintputch+0x1b>
    *b->buf++ = ch;
  80031a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80031d:	89 08                	mov    %ecx,(%eax)
  80031f:	8b 45 08             	mov    0x8(%ebp),%eax
  800322:	88 02                	mov    %al,(%edx)
}
  800324:	5d                   	pop    %ebp
  800325:	c3                   	ret    

00800326 <printfmt>:
  }
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
  800329:	83 ec 18             	sub    $0x18,%esp
  va_list ap;

  va_start(ap, fmt);
  80032c:	8d 45 14             	lea    0x14(%ebp),%eax
  vprintfmt(putch, putdat, fmt, ap);
  80032f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800333:	8b 45 10             	mov    0x10(%ebp),%eax
  800336:	89 44 24 08          	mov    %eax,0x8(%esp)
  80033a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80033d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800341:	8b 45 08             	mov    0x8(%ebp),%eax
  800344:	89 04 24             	mov    %eax,(%esp)
  800347:	e8 02 00 00 00       	call   80034e <vprintfmt>
  va_end(ap);
}
  80034c:	c9                   	leave  
  80034d:	c3                   	ret    

0080034e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
  800351:	57                   	push   %edi
  800352:	56                   	push   %esi
  800353:	53                   	push   %ebx
  800354:	83 ec 3c             	sub    $0x3c,%esp
  800357:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80035a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80035d:	eb 14                	jmp    800373 <vprintfmt+0x25>
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
      if (ch == '\0')
  80035f:	85 c0                	test   %eax,%eax
  800361:	0f 84 b3 03 00 00    	je     80071a <vprintfmt+0x3cc>
        return;
      putch(ch, putdat);
  800367:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80036b:	89 04 24             	mov    %eax,(%esp)
  80036e:	ff 55 08             	call   *0x8(%ebp)
  unsigned long long num;
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
  800371:	89 f3                	mov    %esi,%ebx
  800373:	8d 73 01             	lea    0x1(%ebx),%esi
  800376:	0f b6 03             	movzbl (%ebx),%eax
  800379:	83 f8 25             	cmp    $0x25,%eax
  80037c:	75 e1                	jne    80035f <vprintfmt+0x11>
  80037e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800382:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800389:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800390:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800397:	ba 00 00 00 00       	mov    $0x0,%edx
  80039c:	eb 1d                	jmp    8003bb <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80039e:	89 de                	mov    %ebx,%esi

    // flag to pad on the right
    case '-':
      padc = '-';
  8003a0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003a4:	eb 15                	jmp    8003bb <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8003a6:	89 de                	mov    %ebx,%esi
      padc = '-';
      goto reswitch;

    // flag to pad with 0's instead of spaces
    case '0':
      padc = '0';
  8003a8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003ac:	eb 0d                	jmp    8003bb <vprintfmt+0x6d>
      altflag = 1;
      goto reswitch;

process_precision:
      if (width < 0)
        width = precision, precision = -1;
  8003ae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003b4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8003bb:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003be:	0f b6 0e             	movzbl (%esi),%ecx
  8003c1:	0f b6 c1             	movzbl %cl,%eax
  8003c4:	83 e9 23             	sub    $0x23,%ecx
  8003c7:	80 f9 55             	cmp    $0x55,%cl
  8003ca:	0f 87 2a 03 00 00    	ja     8006fa <vprintfmt+0x3ac>
  8003d0:	0f b6 c9             	movzbl %cl,%ecx
  8003d3:	ff 24 8d a0 21 80 00 	jmp    *0x8021a0(,%ecx,4)
  8003da:	89 de                	mov    %ebx,%esi
  8003dc:	b9 00 00 00 00       	mov    $0x0,%ecx
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
        precision = precision * 10 + ch - '0';
  8003e1:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003e4:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
        ch = *fmt;
  8003e8:	0f be 06             	movsbl (%esi),%eax
        if (ch < '0' || ch > '9')
  8003eb:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003ee:	83 fb 09             	cmp    $0x9,%ebx
  8003f1:	77 36                	ja     800429 <vprintfmt+0xdb>
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
  8003f3:	83 c6 01             	add    $0x1,%esi
        precision = precision * 10 + ch - '0';
        ch = *fmt;
        if (ch < '0' || ch > '9')
          break;
      }
  8003f6:	eb e9                	jmp    8003e1 <vprintfmt+0x93>
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
  8003f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fb:	8d 48 04             	lea    0x4(%eax),%ecx
  8003fe:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800401:	8b 00                	mov    (%eax),%eax
  800403:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  800406:	89 de                	mov    %ebx,%esi
      }
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
      goto process_precision;
  800408:	eb 22                	jmp    80042c <vprintfmt+0xde>
  80040a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80040d:	85 c9                	test   %ecx,%ecx
  80040f:	b8 00 00 00 00       	mov    $0x0,%eax
  800414:	0f 49 c1             	cmovns %ecx,%eax
  800417:	89 45 dc             	mov    %eax,-0x24(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80041a:	89 de                	mov    %ebx,%esi
  80041c:	eb 9d                	jmp    8003bb <vprintfmt+0x6d>
  80041e:	89 de                	mov    %ebx,%esi
      if (width < 0)
        width = 0;
      goto reswitch;

    case '#':
      altflag = 1;
  800420:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
      goto reswitch;
  800427:	eb 92                	jmp    8003bb <vprintfmt+0x6d>
  800429:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

process_precision:
      if (width < 0)
  80042c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800430:	79 89                	jns    8003bb <vprintfmt+0x6d>
  800432:	e9 77 ff ff ff       	jmp    8003ae <vprintfmt+0x60>
        width = precision, precision = -1;
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
  800437:	83 c2 01             	add    $0x1,%edx
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80043a:	89 de                	mov    %ebx,%esi
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
      goto reswitch;
  80043c:	e9 7a ff ff ff       	jmp    8003bb <vprintfmt+0x6d>

    // character
    case 'c':
      putch(va_arg(ap, int), putdat);
  800441:	8b 45 14             	mov    0x14(%ebp),%eax
  800444:	8d 50 04             	lea    0x4(%eax),%edx
  800447:	89 55 14             	mov    %edx,0x14(%ebp)
  80044a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80044e:	8b 00                	mov    (%eax),%eax
  800450:	89 04 24             	mov    %eax,(%esp)
  800453:	ff 55 08             	call   *0x8(%ebp)
      break;
  800456:	e9 18 ff ff ff       	jmp    800373 <vprintfmt+0x25>

    // error message
    case 'e':
      err = va_arg(ap, int);
  80045b:	8b 45 14             	mov    0x14(%ebp),%eax
  80045e:	8d 50 04             	lea    0x4(%eax),%edx
  800461:	89 55 14             	mov    %edx,0x14(%ebp)
  800464:	8b 00                	mov    (%eax),%eax
  800466:	99                   	cltd   
  800467:	31 d0                	xor    %edx,%eax
  800469:	29 d0                	sub    %edx,%eax
      if (err < 0)
        err = -err;
      if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80046b:	83 f8 0f             	cmp    $0xf,%eax
  80046e:	7f 0b                	jg     80047b <vprintfmt+0x12d>
  800470:	8b 14 85 00 23 80 00 	mov    0x802300(,%eax,4),%edx
  800477:	85 d2                	test   %edx,%edx
  800479:	75 20                	jne    80049b <vprintfmt+0x14d>
        printfmt(putch, putdat, "error %d", err);
  80047b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80047f:	c7 44 24 08 6a 20 80 	movl   $0x80206a,0x8(%esp)
  800486:	00 
  800487:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80048b:	8b 45 08             	mov    0x8(%ebp),%eax
  80048e:	89 04 24             	mov    %eax,(%esp)
  800491:	e8 90 fe ff ff       	call   800326 <printfmt>
  800496:	e9 d8 fe ff ff       	jmp    800373 <vprintfmt+0x25>
      else
        printfmt(putch, putdat, "%s", p);
  80049b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80049f:	c7 44 24 08 73 20 80 	movl   $0x802073,0x8(%esp)
  8004a6:	00 
  8004a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ae:	89 04 24             	mov    %eax,(%esp)
  8004b1:	e8 70 fe ff ff       	call   800326 <printfmt>
  8004b6:	e9 b8 fe ff ff       	jmp    800373 <vprintfmt+0x25>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8004bb:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004be:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004c1:	89 45 d0             	mov    %eax,-0x30(%ebp)
        printfmt(putch, putdat, "%s", p);
      break;

    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
  8004c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c7:	8d 50 04             	lea    0x4(%eax),%edx
  8004ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cd:	8b 30                	mov    (%eax),%esi
        p = "(null)";
  8004cf:	85 f6                	test   %esi,%esi
  8004d1:	b8 63 20 80 00       	mov    $0x802063,%eax
  8004d6:	0f 44 f0             	cmove  %eax,%esi
      if (width > 0 && padc != '-')
  8004d9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004dd:	0f 84 97 00 00 00    	je     80057a <vprintfmt+0x22c>
  8004e3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8004e7:	0f 8e 9b 00 00 00    	jle    800588 <vprintfmt+0x23a>
        for (width -= strnlen(p, precision); width > 0; width--)
  8004ed:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004f1:	89 34 24             	mov    %esi,(%esp)
  8004f4:	e8 cf 02 00 00       	call   8007c8 <strnlen>
  8004f9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004fc:	29 c2                	sub    %eax,%edx
  8004fe:	89 55 d0             	mov    %edx,-0x30(%ebp)
          putch(padc, putdat);
  800501:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800505:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800508:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80050b:	8b 75 08             	mov    0x8(%ebp),%esi
  80050e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800511:	89 d3                	mov    %edx,%ebx
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
  800513:	eb 0f                	jmp    800524 <vprintfmt+0x1d6>
          putch(padc, putdat);
  800515:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800519:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80051c:	89 04 24             	mov    %eax,(%esp)
  80051f:	ff d6                	call   *%esi
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
  800521:	83 eb 01             	sub    $0x1,%ebx
  800524:	85 db                	test   %ebx,%ebx
  800526:	7f ed                	jg     800515 <vprintfmt+0x1c7>
  800528:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80052b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80052e:	85 d2                	test   %edx,%edx
  800530:	b8 00 00 00 00       	mov    $0x0,%eax
  800535:	0f 49 c2             	cmovns %edx,%eax
  800538:	29 c2                	sub    %eax,%edx
  80053a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80053d:	89 d7                	mov    %edx,%edi
  80053f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800542:	eb 50                	jmp    800594 <vprintfmt+0x246>
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
  800544:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800548:	74 1e                	je     800568 <vprintfmt+0x21a>
  80054a:	0f be d2             	movsbl %dl,%edx
  80054d:	83 ea 20             	sub    $0x20,%edx
  800550:	83 fa 5e             	cmp    $0x5e,%edx
  800553:	76 13                	jbe    800568 <vprintfmt+0x21a>
          putch('?', putdat);
  800555:	8b 45 0c             	mov    0xc(%ebp),%eax
  800558:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800563:	ff 55 08             	call   *0x8(%ebp)
  800566:	eb 0d                	jmp    800575 <vprintfmt+0x227>
        else
          putch(ch, putdat);
  800568:	8b 55 0c             	mov    0xc(%ebp),%edx
  80056b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80056f:	89 04 24             	mov    %eax,(%esp)
  800572:	ff 55 08             	call   *0x8(%ebp)
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800575:	83 ef 01             	sub    $0x1,%edi
  800578:	eb 1a                	jmp    800594 <vprintfmt+0x246>
  80057a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80057d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800580:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800583:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800586:	eb 0c                	jmp    800594 <vprintfmt+0x246>
  800588:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80058b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80058e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800591:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800594:	83 c6 01             	add    $0x1,%esi
  800597:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80059b:	0f be c2             	movsbl %dl,%eax
  80059e:	85 c0                	test   %eax,%eax
  8005a0:	74 27                	je     8005c9 <vprintfmt+0x27b>
  8005a2:	85 db                	test   %ebx,%ebx
  8005a4:	78 9e                	js     800544 <vprintfmt+0x1f6>
  8005a6:	83 eb 01             	sub    $0x1,%ebx
  8005a9:	79 99                	jns    800544 <vprintfmt+0x1f6>
  8005ab:	89 f8                	mov    %edi,%eax
  8005ad:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b3:	89 c3                	mov    %eax,%ebx
  8005b5:	eb 1a                	jmp    8005d1 <vprintfmt+0x283>
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
        putch(' ', putdat);
  8005b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005bb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005c2:	ff d6                	call   *%esi
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
  8005c4:	83 eb 01             	sub    $0x1,%ebx
  8005c7:	eb 08                	jmp    8005d1 <vprintfmt+0x283>
  8005c9:	89 fb                	mov    %edi,%ebx
  8005cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ce:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005d1:	85 db                	test   %ebx,%ebx
  8005d3:	7f e2                	jg     8005b7 <vprintfmt+0x269>
  8005d5:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005db:	e9 93 fd ff ff       	jmp    800373 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  if (lflag >= 2)
  8005e0:	83 fa 01             	cmp    $0x1,%edx
  8005e3:	7e 16                	jle    8005fb <vprintfmt+0x2ad>
    return va_arg(*ap, long long);
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8d 50 08             	lea    0x8(%eax),%edx
  8005eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ee:	8b 50 04             	mov    0x4(%eax),%edx
  8005f1:	8b 00                	mov    (%eax),%eax
  8005f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005f6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005f9:	eb 32                	jmp    80062d <vprintfmt+0x2df>
  else if (lflag)
  8005fb:	85 d2                	test   %edx,%edx
  8005fd:	74 18                	je     800617 <vprintfmt+0x2c9>
    return va_arg(*ap, long);
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	8d 50 04             	lea    0x4(%eax),%edx
  800605:	89 55 14             	mov    %edx,0x14(%ebp)
  800608:	8b 30                	mov    (%eax),%esi
  80060a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80060d:	89 f0                	mov    %esi,%eax
  80060f:	c1 f8 1f             	sar    $0x1f,%eax
  800612:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800615:	eb 16                	jmp    80062d <vprintfmt+0x2df>
  else
    return va_arg(*ap, int);
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8d 50 04             	lea    0x4(%eax),%edx
  80061d:	89 55 14             	mov    %edx,0x14(%ebp)
  800620:	8b 30                	mov    (%eax),%esi
  800622:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800625:	89 f0                	mov    %esi,%eax
  800627:	c1 f8 1f             	sar    $0x1f,%eax
  80062a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        putch(' ', putdat);
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
  80062d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800630:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      if ((long long)num < 0) {
        putch('-', putdat);
        num = -(long long)num;
      }
      base = 10;
  800633:	b9 0a 00 00 00       	mov    $0xa,%ecx
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
      if ((long long)num < 0) {
  800638:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80063c:	0f 89 80 00 00 00    	jns    8006c2 <vprintfmt+0x374>
        putch('-', putdat);
  800642:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800646:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80064d:	ff 55 08             	call   *0x8(%ebp)
        num = -(long long)num;
  800650:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800653:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800656:	f7 d8                	neg    %eax
  800658:	83 d2 00             	adc    $0x0,%edx
  80065b:	f7 da                	neg    %edx
      }
      base = 10;
  80065d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800662:	eb 5e                	jmp    8006c2 <vprintfmt+0x374>
      goto number;

    // unsigned decimal
    case 'u':
      num = getuint(&ap, lflag);
  800664:	8d 45 14             	lea    0x14(%ebp),%eax
  800667:	e8 63 fc ff ff       	call   8002cf <getuint>
      base = 10;
  80066c:	b9 0a 00 00 00       	mov    $0xa,%ecx
      goto number;
  800671:	eb 4f                	jmp    8006c2 <vprintfmt+0x374>

    // (unsigned) octal
    case 'o':
      num = getuint(&ap, lflag);
  800673:	8d 45 14             	lea    0x14(%ebp),%eax
  800676:	e8 54 fc ff ff       	call   8002cf <getuint>
      base = 8;
  80067b:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800680:	eb 40                	jmp    8006c2 <vprintfmt+0x374>

    // pointer
    case 'p':
      putch('0', putdat);
  800682:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800686:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80068d:	ff 55 08             	call   *0x8(%ebp)
      putch('x', putdat);
  800690:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800694:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80069b:	ff 55 08             	call   *0x8(%ebp)
      num = (unsigned long long)
            (uintptr_t)va_arg(ap, void *);
  80069e:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a1:	8d 50 04             	lea    0x4(%eax),%edx
  8006a4:	89 55 14             	mov    %edx,0x14(%ebp)

    // pointer
    case 'p':
      putch('0', putdat);
      putch('x', putdat);
      num = (unsigned long long)
  8006a7:	8b 00                	mov    (%eax),%eax
  8006a9:	ba 00 00 00 00       	mov    $0x0,%edx
            (uintptr_t)va_arg(ap, void *);
      base = 16;
  8006ae:	b9 10 00 00 00       	mov    $0x10,%ecx
      goto number;
  8006b3:	eb 0d                	jmp    8006c2 <vprintfmt+0x374>

    // (unsigned) hexadecimal
    case 'x':
      num = getuint(&ap, lflag);
  8006b5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b8:	e8 12 fc ff ff       	call   8002cf <getuint>
      base = 16;
  8006bd:	b9 10 00 00 00       	mov    $0x10,%ecx
number:
      printnum(putch, putdat, num, base, width, padc);
  8006c2:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8006c6:	89 74 24 10          	mov    %esi,0x10(%esp)
  8006ca:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006cd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006d1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006d5:	89 04 24             	mov    %eax,(%esp)
  8006d8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006dc:	89 fa                	mov    %edi,%edx
  8006de:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e1:	e8 fa fa ff ff       	call   8001e0 <printnum>
      break;
  8006e6:	e9 88 fc ff ff       	jmp    800373 <vprintfmt+0x25>

    // escaped '%' character
    case '%':
      putch(ch, putdat);
  8006eb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ef:	89 04 24             	mov    %eax,(%esp)
  8006f2:	ff 55 08             	call   *0x8(%ebp)
      break;
  8006f5:	e9 79 fc ff ff       	jmp    800373 <vprintfmt+0x25>

    // unrecognized escape sequence - just print it literally
    default:
      putch('%', putdat);
  8006fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006fe:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800705:	ff 55 08             	call   *0x8(%ebp)
      for (fmt--; fmt[-1] != '%'; fmt--)
  800708:	89 f3                	mov    %esi,%ebx
  80070a:	eb 03                	jmp    80070f <vprintfmt+0x3c1>
  80070c:	83 eb 01             	sub    $0x1,%ebx
  80070f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800713:	75 f7                	jne    80070c <vprintfmt+0x3be>
  800715:	e9 59 fc ff ff       	jmp    800373 <vprintfmt+0x25>
        /* do nothing */;
      break;
    }
  }
}
  80071a:	83 c4 3c             	add    $0x3c,%esp
  80071d:	5b                   	pop    %ebx
  80071e:	5e                   	pop    %esi
  80071f:	5f                   	pop    %edi
  800720:	5d                   	pop    %ebp
  800721:	c3                   	ret    

00800722 <vsnprintf>:
    *b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	83 ec 28             	sub    $0x28,%esp
  800728:	8b 45 08             	mov    0x8(%ebp),%eax
  80072b:	8b 55 0c             	mov    0xc(%ebp),%edx
  struct sprintbuf b = { buf, buf+n-1, 0 };
  80072e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800731:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800735:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800738:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  if (buf == NULL || n < 1)
  80073f:	85 c0                	test   %eax,%eax
  800741:	74 30                	je     800773 <vsnprintf+0x51>
  800743:	85 d2                	test   %edx,%edx
  800745:	7e 2c                	jle    800773 <vsnprintf+0x51>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void*)sprintputch, &b, fmt, ap);
  800747:	8b 45 14             	mov    0x14(%ebp),%eax
  80074a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80074e:	8b 45 10             	mov    0x10(%ebp),%eax
  800751:	89 44 24 08          	mov    %eax,0x8(%esp)
  800755:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800758:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075c:	c7 04 24 09 03 80 00 	movl   $0x800309,(%esp)
  800763:	e8 e6 fb ff ff       	call   80034e <vprintfmt>

  // null terminate the buffer
  *b.buf = '\0';
  800768:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80076b:	c6 00 00             	movb   $0x0,(%eax)

  return b.cnt;
  80076e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800771:	eb 05                	jmp    800778 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  struct sprintbuf b = { buf, buf+n-1, 0 };

  if (buf == NULL || n < 1)
    return -E_INVAL;
  800773:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

  // null terminate the buffer
  *b.buf = '\0';

  return b.cnt;
}
  800778:	c9                   	leave  
  800779:	c3                   	ret    

0080077a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800780:	8d 45 14             	lea    0x14(%ebp),%eax
  rc = vsnprintf(buf, n, fmt, ap);
  800783:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800787:	8b 45 10             	mov    0x10(%ebp),%eax
  80078a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80078e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800791:	89 44 24 04          	mov    %eax,0x4(%esp)
  800795:	8b 45 08             	mov    0x8(%ebp),%eax
  800798:	89 04 24             	mov    %eax,(%esp)
  80079b:	e8 82 ff ff ff       	call   800722 <vsnprintf>
  va_end(ap);

  return rc;
}
  8007a0:	c9                   	leave  
  8007a1:	c3                   	ret    
  8007a2:	66 90                	xchg   %ax,%ax
  8007a4:	66 90                	xchg   %ax,%ax
  8007a6:	66 90                	xchg   %ax,%ax
  8007a8:	66 90                	xchg   %ax,%ax
  8007aa:	66 90                	xchg   %ax,%ax
  8007ac:	66 90                	xchg   %ax,%ax
  8007ae:	66 90                	xchg   %ax,%ax

008007b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for (n = 0; *s != '\0'; s++)
  8007b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bb:	eb 03                	jmp    8007c0 <strlen+0x10>
    n++;
  8007bd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
  int n;

  for (n = 0; *s != '\0'; s++)
  8007c0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c4:	75 f7                	jne    8007bd <strlen+0xd>
    n++;
  return n;
}
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d6:	eb 03                	jmp    8007db <strnlen+0x13>
    n++;
  8007d8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007db:	39 d0                	cmp    %edx,%eax
  8007dd:	74 06                	je     8007e5 <strnlen+0x1d>
  8007df:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007e3:	75 f3                	jne    8007d8 <strnlen+0x10>
    n++;
  return n;
}
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	53                   	push   %ebx
  8007eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  8007f1:	89 c2                	mov    %eax,%edx
  8007f3:	83 c2 01             	add    $0x1,%edx
  8007f6:	83 c1 01             	add    $0x1,%ecx
  8007f9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007fd:	88 5a ff             	mov    %bl,-0x1(%edx)
  800800:	84 db                	test   %bl,%bl
  800802:	75 ef                	jne    8007f3 <strcpy+0xc>
    /* do nothing */;
  return ret;
}
  800804:	5b                   	pop    %ebx
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	53                   	push   %ebx
  80080b:	83 ec 08             	sub    $0x8,%esp
  80080e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int len = strlen(dst);
  800811:	89 1c 24             	mov    %ebx,(%esp)
  800814:	e8 97 ff ff ff       	call   8007b0 <strlen>

  strcpy(dst + len, src);
  800819:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800820:	01 d8                	add    %ebx,%eax
  800822:	89 04 24             	mov    %eax,(%esp)
  800825:	e8 bd ff ff ff       	call   8007e7 <strcpy>
  return dst;
}
  80082a:	89 d8                	mov    %ebx,%eax
  80082c:	83 c4 08             	add    $0x8,%esp
  80082f:	5b                   	pop    %ebx
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	56                   	push   %esi
  800836:	53                   	push   %ebx
  800837:	8b 75 08             	mov    0x8(%ebp),%esi
  80083a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083d:	89 f3                	mov    %esi,%ebx
  80083f:	03 5d 10             	add    0x10(%ebp),%ebx
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800842:	89 f2                	mov    %esi,%edx
  800844:	eb 0f                	jmp    800855 <strncpy+0x23>
    *dst++ = *src;
  800846:	83 c2 01             	add    $0x1,%edx
  800849:	0f b6 01             	movzbl (%ecx),%eax
  80084c:	88 42 ff             	mov    %al,-0x1(%edx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  80084f:	80 39 01             	cmpb   $0x1,(%ecx)
  800852:	83 d9 ff             	sbb    $0xffffffff,%ecx
{
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800855:	39 da                	cmp    %ebx,%edx
  800857:	75 ed                	jne    800846 <strncpy+0x14>
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  }
  return ret;
}
  800859:	89 f0                	mov    %esi,%eax
  80085b:	5b                   	pop    %ebx
  80085c:	5e                   	pop    %esi
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	56                   	push   %esi
  800863:	53                   	push   %ebx
  800864:	8b 75 08             	mov    0x8(%ebp),%esi
  800867:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80086d:	89 f0                	mov    %esi,%eax
  80086f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800873:	85 c9                	test   %ecx,%ecx
  800875:	75 0b                	jne    800882 <strlcpy+0x23>
  800877:	eb 1d                	jmp    800896 <strlcpy+0x37>
    while (--size > 0 && *src != '\0')
      *dst++ = *src++;
  800879:	83 c0 01             	add    $0x1,%eax
  80087c:	83 c2 01             	add    $0x1,%edx
  80087f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
    while (--size > 0 && *src != '\0')
  800882:	39 d8                	cmp    %ebx,%eax
  800884:	74 0b                	je     800891 <strlcpy+0x32>
  800886:	0f b6 0a             	movzbl (%edx),%ecx
  800889:	84 c9                	test   %cl,%cl
  80088b:	75 ec                	jne    800879 <strlcpy+0x1a>
  80088d:	89 c2                	mov    %eax,%edx
  80088f:	eb 02                	jmp    800893 <strlcpy+0x34>
  800891:	89 c2                	mov    %eax,%edx
      *dst++ = *src++;
    *dst = '\0';
  800893:	c6 02 00             	movb   $0x0,(%edx)
  }
  return dst - dst_in;
  800896:	29 f0                	sub    %esi,%eax
}
  800898:	5b                   	pop    %ebx
  800899:	5e                   	pop    %esi
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  while (*p && *p == *q)
  8008a5:	eb 06                	jmp    8008ad <strcmp+0x11>
    p++, q++;
  8008a7:	83 c1 01             	add    $0x1,%ecx
  8008aa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
  while (*p && *p == *q)
  8008ad:	0f b6 01             	movzbl (%ecx),%eax
  8008b0:	84 c0                	test   %al,%al
  8008b2:	74 04                	je     8008b8 <strcmp+0x1c>
  8008b4:	3a 02                	cmp    (%edx),%al
  8008b6:	74 ef                	je     8008a7 <strcmp+0xb>
    p++, q++;
  return (int)((unsigned char)*p - (unsigned char)*q);
  8008b8:	0f b6 c0             	movzbl %al,%eax
  8008bb:	0f b6 12             	movzbl (%edx),%edx
  8008be:	29 d0                	sub    %edx,%eax
}
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	53                   	push   %ebx
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cc:	89 c3                	mov    %eax,%ebx
  8008ce:	03 5d 10             	add    0x10(%ebp),%ebx
  while (n > 0 && *p && *p == *q)
  8008d1:	eb 06                	jmp    8008d9 <strncmp+0x17>
    n--, p++, q++;
  8008d3:	83 c0 01             	add    $0x1,%eax
  8008d6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
  8008d9:	39 d8                	cmp    %ebx,%eax
  8008db:	74 15                	je     8008f2 <strncmp+0x30>
  8008dd:	0f b6 08             	movzbl (%eax),%ecx
  8008e0:	84 c9                	test   %cl,%cl
  8008e2:	74 04                	je     8008e8 <strncmp+0x26>
  8008e4:	3a 0a                	cmp    (%edx),%cl
  8008e6:	74 eb                	je     8008d3 <strncmp+0x11>
    n--, p++, q++;
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  8008e8:	0f b6 00             	movzbl (%eax),%eax
  8008eb:	0f b6 12             	movzbl (%edx),%edx
  8008ee:	29 d0                	sub    %edx,%eax
  8008f0:	eb 05                	jmp    8008f7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
    n--, p++, q++;
  if (n == 0)
    return 0;
  8008f2:	b8 00 00 00 00       	mov    $0x0,%eax
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
}
  8008f7:	5b                   	pop    %ebx
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
  800904:	eb 07                	jmp    80090d <strchr+0x13>
    if (*s == c)
  800906:	38 ca                	cmp    %cl,%dl
  800908:	74 0f                	je     800919 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  for (; *s; s++)
  80090a:	83 c0 01             	add    $0x1,%eax
  80090d:	0f b6 10             	movzbl (%eax),%edx
  800910:	84 d2                	test   %dl,%dl
  800912:	75 f2                	jne    800906 <strchr+0xc>
    if (*s == c)
      return (char*)s;
  return 0;
  800914:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
  800925:	eb 07                	jmp    80092e <strfind+0x13>
    if (*s == c)
  800927:	38 ca                	cmp    %cl,%dl
  800929:	74 0a                	je     800935 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  for (; *s; s++)
  80092b:	83 c0 01             	add    $0x1,%eax
  80092e:	0f b6 10             	movzbl (%eax),%edx
  800931:	84 d2                	test   %dl,%dl
  800933:	75 f2                	jne    800927 <strfind+0xc>
    if (*s == c)
      break;
  return (char*)s;
}
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	57                   	push   %edi
  80093b:	56                   	push   %esi
  80093c:	53                   	push   %ebx
  80093d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800940:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *p;

  if (n == 0)
  800943:	85 c9                	test   %ecx,%ecx
  800945:	74 36                	je     80097d <memset+0x46>
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
  800947:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094d:	75 28                	jne    800977 <memset+0x40>
  80094f:	f6 c1 03             	test   $0x3,%cl
  800952:	75 23                	jne    800977 <memset+0x40>
    c &= 0xFF;
  800954:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
    c = (c<<24)|(c<<16)|(c<<8)|c;
  800958:	89 d3                	mov    %edx,%ebx
  80095a:	c1 e3 08             	shl    $0x8,%ebx
  80095d:	89 d6                	mov    %edx,%esi
  80095f:	c1 e6 18             	shl    $0x18,%esi
  800962:	89 d0                	mov    %edx,%eax
  800964:	c1 e0 10             	shl    $0x10,%eax
  800967:	09 f0                	or     %esi,%eax
  800969:	09 c2                	or     %eax,%edx
  80096b:	89 d0                	mov    %edx,%eax
  80096d:	09 d8                	or     %ebx,%eax
    asm volatile ("cld; rep stosl\n"
                  :: "D" (v), "a" (c), "c" (n/4)
  80096f:	c1 e9 02             	shr    $0x2,%ecx
  if (n == 0)
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
    c &= 0xFF;
    c = (c<<24)|(c<<16)|(c<<8)|c;
    asm volatile ("cld; rep stosl\n"
  800972:	fc                   	cld    
  800973:	f3 ab                	rep stos %eax,%es:(%edi)
  800975:	eb 06                	jmp    80097d <memset+0x46>
                  :: "D" (v), "a" (c), "c" (n/4)
                  : "cc", "memory");
  } else
    asm volatile ("cld; rep stosb\n"
  800977:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097a:	fc                   	cld    
  80097b:	f3 aa                	rep stos %al,%es:(%edi)
                  :: "D" (v), "a" (c), "c" (n)
                  : "cc", "memory");
  return v;
}
  80097d:	89 f8                	mov    %edi,%eax
  80097f:	5b                   	pop    %ebx
  800980:	5e                   	pop    %esi
  800981:	5f                   	pop    %edi
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	57                   	push   %edi
  800988:	56                   	push   %esi
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800992:	39 c6                	cmp    %eax,%esi
  800994:	73 35                	jae    8009cb <memmove+0x47>
  800996:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800999:	39 d0                	cmp    %edx,%eax
  80099b:	73 2e                	jae    8009cb <memmove+0x47>
    s += n;
    d += n;
  80099d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009a0:	89 d6                	mov    %edx,%esi
  8009a2:	09 fe                	or     %edi,%esi
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009aa:	75 13                	jne    8009bf <memmove+0x3b>
  8009ac:	f6 c1 03             	test   $0x3,%cl
  8009af:	75 0e                	jne    8009bf <memmove+0x3b>
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b1:	83 ef 04             	sub    $0x4,%edi
  8009b4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b7:	c1 e9 02             	shr    $0x2,%ecx
  d = dst;
  if (s < d && s + n > d) {
    s += n;
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
  8009ba:	fd                   	std    
  8009bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bd:	eb 09                	jmp    8009c8 <memmove+0x44>
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009bf:	83 ef 01             	sub    $0x1,%edi
  8009c2:	8d 72 ff             	lea    -0x1(%edx),%esi
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
  8009c5:	fd                   	std    
  8009c6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  8009c8:	fc                   	cld    
  8009c9:	eb 1d                	jmp    8009e8 <memmove+0x64>
  8009cb:	89 f2                	mov    %esi,%edx
  8009cd:	09 c2                	or     %eax,%edx
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cf:	f6 c2 03             	test   $0x3,%dl
  8009d2:	75 0f                	jne    8009e3 <memmove+0x5f>
  8009d4:	f6 c1 03             	test   $0x3,%cl
  8009d7:	75 0a                	jne    8009e3 <memmove+0x5f>
      asm volatile ("cld; rep movsl\n"
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009d9:	c1 e9 02             	shr    $0x2,%ecx
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("cld; rep movsl\n"
  8009dc:	89 c7                	mov    %eax,%edi
  8009de:	fc                   	cld    
  8009df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e1:	eb 05                	jmp    8009e8 <memmove+0x64>
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("cld; rep movsb\n"
  8009e3:	89 c7                	mov    %eax,%edi
  8009e5:	fc                   	cld    
  8009e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d), "S" (s), "c" (n) : "cc", "memory");
  }
  return dst;
}
  8009e8:	5e                   	pop    %esi
  8009e9:	5f                   	pop    %edi
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
  8009f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
  800a03:	89 04 24             	mov    %eax,(%esp)
  800a06:	e8 79 ff ff ff       	call   800984 <memmove>
}
  800a0b:	c9                   	leave  
  800a0c:	c3                   	ret    

00800a0d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	56                   	push   %esi
  800a11:	53                   	push   %ebx
  800a12:	8b 55 08             	mov    0x8(%ebp),%edx
  800a15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a18:	89 d6                	mov    %edx,%esi
  800a1a:	03 75 10             	add    0x10(%ebp),%esi
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
  800a1d:	eb 1a                	jmp    800a39 <memcmp+0x2c>
    if (*s1 != *s2)
  800a1f:	0f b6 02             	movzbl (%edx),%eax
  800a22:	0f b6 19             	movzbl (%ecx),%ebx
  800a25:	38 d8                	cmp    %bl,%al
  800a27:	74 0a                	je     800a33 <memcmp+0x26>
      return (int)*s1 - (int)*s2;
  800a29:	0f b6 c0             	movzbl %al,%eax
  800a2c:	0f b6 db             	movzbl %bl,%ebx
  800a2f:	29 d8                	sub    %ebx,%eax
  800a31:	eb 0f                	jmp    800a42 <memcmp+0x35>
    s1++, s2++;
  800a33:	83 c2 01             	add    $0x1,%edx
  800a36:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
  800a39:	39 f2                	cmp    %esi,%edx
  800a3b:	75 e2                	jne    800a1f <memcmp+0x12>
    if (*s1 != *s2)
      return (int)*s1 - (int)*s2;
    s1++, s2++;
  }

  return 0;
  800a3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  const void *ends = (const char*)s + n;
  800a4f:	89 c2                	mov    %eax,%edx
  800a51:	03 55 10             	add    0x10(%ebp),%edx

  for (; s < ends; s++)
  800a54:	eb 07                	jmp    800a5d <memfind+0x17>
    if (*(const unsigned char*)s == (unsigned char)c)
  800a56:	38 08                	cmp    %cl,(%eax)
  800a58:	74 07                	je     800a61 <memfind+0x1b>
void *
memfind(const void *s, int c, size_t n)
{
  const void *ends = (const char*)s + n;

  for (; s < ends; s++)
  800a5a:	83 c0 01             	add    $0x1,%eax
  800a5d:	39 d0                	cmp    %edx,%eax
  800a5f:	72 f5                	jb     800a56 <memfind+0x10>
    if (*(const unsigned char*)s == (unsigned char)c)
      break;
  return (void*)s;
}
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	57                   	push   %edi
  800a67:	56                   	push   %esi
  800a68:	53                   	push   %ebx
  800a69:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6c:	8b 45 10             	mov    0x10(%ebp),%eax
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800a6f:	eb 03                	jmp    800a74 <strtol+0x11>
    s++;
  800a71:	83 c2 01             	add    $0x1,%edx
{
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800a74:	0f b6 0a             	movzbl (%edx),%ecx
  800a77:	80 f9 09             	cmp    $0x9,%cl
  800a7a:	74 f5                	je     800a71 <strtol+0xe>
  800a7c:	80 f9 20             	cmp    $0x20,%cl
  800a7f:	74 f0                	je     800a71 <strtol+0xe>
    s++;

  // plus/minus sign
  if (*s == '+')
  800a81:	80 f9 2b             	cmp    $0x2b,%cl
  800a84:	75 0a                	jne    800a90 <strtol+0x2d>
    s++;
  800a86:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
  int neg = 0;
  800a89:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8e:	eb 11                	jmp    800aa1 <strtol+0x3e>
  800a90:	bf 00 00 00 00       	mov    $0x0,%edi
    s++;

  // plus/minus sign
  if (*s == '+')
    s++;
  else if (*s == '-')
  800a95:	80 f9 2d             	cmp    $0x2d,%cl
  800a98:	75 07                	jne    800aa1 <strtol+0x3e>
    s++, neg = 1;
  800a9a:	8d 52 01             	lea    0x1(%edx),%edx
  800a9d:	66 bf 01 00          	mov    $0x1,%di

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800aa6:	75 15                	jne    800abd <strtol+0x5a>
  800aa8:	80 3a 30             	cmpb   $0x30,(%edx)
  800aab:	75 10                	jne    800abd <strtol+0x5a>
  800aad:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ab1:	75 0a                	jne    800abd <strtol+0x5a>
    s += 2, base = 16;
  800ab3:	83 c2 02             	add    $0x2,%edx
  800ab6:	b8 10 00 00 00       	mov    $0x10,%eax
  800abb:	eb 10                	jmp    800acd <strtol+0x6a>
  else if (base == 0 && s[0] == '0')
  800abd:	85 c0                	test   %eax,%eax
  800abf:	75 0c                	jne    800acd <strtol+0x6a>
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800ac1:	b0 0a                	mov    $0xa,%al
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
  800ac3:	80 3a 30             	cmpb   $0x30,(%edx)
  800ac6:	75 05                	jne    800acd <strtol+0x6a>
    s++, base = 8;
  800ac8:	83 c2 01             	add    $0x1,%edx
  800acb:	b0 08                	mov    $0x8,%al
  else if (base == 0)
    base = 10;
  800acd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ad2:	89 45 10             	mov    %eax,0x10(%ebp)

  // digits
  while (1) {
    int dig;

    if (*s >= '0' && *s <= '9')
  800ad5:	0f b6 0a             	movzbl (%edx),%ecx
  800ad8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800adb:	89 f0                	mov    %esi,%eax
  800add:	3c 09                	cmp    $0x9,%al
  800adf:	77 08                	ja     800ae9 <strtol+0x86>
      dig = *s - '0';
  800ae1:	0f be c9             	movsbl %cl,%ecx
  800ae4:	83 e9 30             	sub    $0x30,%ecx
  800ae7:	eb 20                	jmp    800b09 <strtol+0xa6>
    else if (*s >= 'a' && *s <= 'z')
  800ae9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800aec:	89 f0                	mov    %esi,%eax
  800aee:	3c 19                	cmp    $0x19,%al
  800af0:	77 08                	ja     800afa <strtol+0x97>
      dig = *s - 'a' + 10;
  800af2:	0f be c9             	movsbl %cl,%ecx
  800af5:	83 e9 57             	sub    $0x57,%ecx
  800af8:	eb 0f                	jmp    800b09 <strtol+0xa6>
    else if (*s >= 'A' && *s <= 'Z')
  800afa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800afd:	89 f0                	mov    %esi,%eax
  800aff:	3c 19                	cmp    $0x19,%al
  800b01:	77 16                	ja     800b19 <strtol+0xb6>
      dig = *s - 'A' + 10;
  800b03:	0f be c9             	movsbl %cl,%ecx
  800b06:	83 e9 37             	sub    $0x37,%ecx
    else
      break;
    if (dig >= base)
  800b09:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b0c:	7d 0f                	jge    800b1d <strtol+0xba>
      break;
    s++, val = (val * base) + dig;
  800b0e:	83 c2 01             	add    $0x1,%edx
  800b11:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800b15:	01 cb                	add    %ecx,%ebx
    // we don't properly detect overflow!
  }
  800b17:	eb bc                	jmp    800ad5 <strtol+0x72>
  800b19:	89 d8                	mov    %ebx,%eax
  800b1b:	eb 02                	jmp    800b1f <strtol+0xbc>
  800b1d:	89 d8                	mov    %ebx,%eax

  if (endptr)
  800b1f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b23:	74 05                	je     800b2a <strtol+0xc7>
    *endptr = (char*)s;
  800b25:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b28:	89 16                	mov    %edx,(%esi)
  return neg ? -val : val;
  800b2a:	f7 d8                	neg    %eax
  800b2c:	85 ff                	test   %edi,%edi
  800b2e:	0f 44 c3             	cmove  %ebx,%eax
}
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5f                   	pop    %edi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    

00800b36 <sys_cputs>:
  return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	57                   	push   %edi
  800b3a:	56                   	push   %esi
  800b3b:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800b3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b44:	8b 55 08             	mov    0x8(%ebp),%edx
  800b47:	89 c3                	mov    %eax,%ebx
  800b49:	89 c7                	mov    %eax,%edi
  800b4b:	89 c6                	mov    %eax,%esi
  800b4d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
  syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b4f:	5b                   	pop    %ebx
  800b50:	5e                   	pop    %esi
  800b51:	5f                   	pop    %edi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	57                   	push   %edi
  800b58:	56                   	push   %esi
  800b59:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800b5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b64:	89 d1                	mov    %edx,%ecx
  800b66:	89 d3                	mov    %edx,%ebx
  800b68:	89 d7                	mov    %edx,%edi
  800b6a:	89 d6                	mov    %edx,%esi
  800b6c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b6e:	5b                   	pop    %ebx
  800b6f:	5e                   	pop    %esi
  800b70:	5f                   	pop    %edi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	57                   	push   %edi
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
  800b79:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800b7c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b81:	b8 03 00 00 00       	mov    $0x3,%eax
  800b86:	8b 55 08             	mov    0x8(%ebp),%edx
  800b89:	89 cb                	mov    %ecx,%ebx
  800b8b:	89 cf                	mov    %ecx,%edi
  800b8d:	89 ce                	mov    %ecx,%esi
  800b8f:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800b91:	85 c0                	test   %eax,%eax
  800b93:	7e 28                	jle    800bbd <sys_env_destroy+0x4a>
    panic("syscall %d returned %d (> 0)", num, ret);
  800b95:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b99:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ba0:	00 
  800ba1:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  800ba8:	00 
  800ba9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bb0:	00 
  800bb1:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800bb8:	e8 39 11 00 00       	call   801cf6 <_panic>

int
sys_env_destroy(envid_t envid)
{
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bbd:	83 c4 2c             	add    $0x2c,%esp
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	57                   	push   %edi
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800bcb:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd0:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd5:	89 d1                	mov    %edx,%ecx
  800bd7:	89 d3                	mov    %edx,%ebx
  800bd9:	89 d7                	mov    %edx,%edi
  800bdb:	89 d6                	mov    %edx,%esi
  800bdd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <sys_yield>:

void
sys_yield(void)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	57                   	push   %edi
  800be8:	56                   	push   %esi
  800be9:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800bea:	ba 00 00 00 00       	mov    $0x0,%edx
  800bef:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bf4:	89 d1                	mov    %edx,%ecx
  800bf6:	89 d3                	mov    %edx,%ebx
  800bf8:	89 d7                	mov    %edx,%edi
  800bfa:	89 d6                	mov    %edx,%esi
  800bfc:	cd 30                	int    $0x30

void
sys_yield(void)
{
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800c0c:	be 00 00 00 00       	mov    $0x0,%esi
  800c11:	b8 04 00 00 00       	mov    $0x4,%eax
  800c16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1f:	89 f7                	mov    %esi,%edi
  800c21:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800c23:	85 c0                	test   %eax,%eax
  800c25:	7e 28                	jle    800c4f <sys_page_alloc+0x4c>
    panic("syscall %d returned %d (> 0)", num, ret);
  800c27:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c2b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c32:	00 
  800c33:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  800c3a:	00 
  800c3b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c42:	00 
  800c43:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800c4a:	e8 a7 10 00 00       	call   801cf6 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  return syscall(SYS_page_alloc, 1, envid, (uint32_t)va, perm, 0, 0);
}
  800c4f:	83 c4 2c             	add    $0x2c,%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800c60:	b8 05 00 00 00       	mov    $0x5,%eax
  800c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c71:	8b 75 18             	mov    0x18(%ebp),%esi
  800c74:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800c76:	85 c0                	test   %eax,%eax
  800c78:	7e 28                	jle    800ca2 <sys_page_map+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800c7a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c7e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c85:	00 
  800c86:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  800c8d:	00 
  800c8e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c95:	00 
  800c96:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800c9d:	e8 54 10 00 00       	call   801cf6 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  return syscall(SYS_page_map, 1, srcenv, (uint32_t)srcva, dstenv, (uint32_t)dstva, perm);
}
  800ca2:	83 c4 2c             	add    $0x2c,%esp
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	57                   	push   %edi
  800cae:	56                   	push   %esi
  800caf:	53                   	push   %ebx
  800cb0:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800cb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb8:	b8 06 00 00 00       	mov    $0x6,%eax
  800cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc3:	89 df                	mov    %ebx,%edi
  800cc5:	89 de                	mov    %ebx,%esi
  800cc7:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	7e 28                	jle    800cf5 <sys_page_unmap+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800ccd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cd8:	00 
  800cd9:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  800ce0:	00 
  800ce1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce8:	00 
  800ce9:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800cf0:	e8 01 10 00 00       	call   801cf6 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
  return syscall(SYS_page_unmap, 1, envid, (uint32_t)va, 0, 0, 0);
}
  800cf5:	83 c4 2c             	add    $0x2c,%esp
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5f                   	pop    %edi
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    

00800cfd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	57                   	push   %edi
  800d01:	56                   	push   %esi
  800d02:	53                   	push   %ebx
  800d03:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800d06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d13:	8b 55 08             	mov    0x8(%ebp),%edx
  800d16:	89 df                	mov    %ebx,%edi
  800d18:	89 de                	mov    %ebx,%esi
  800d1a:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	7e 28                	jle    800d48 <sys_env_set_status+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800d20:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d24:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d2b:	00 
  800d2c:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  800d33:	00 
  800d34:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3b:	00 
  800d3c:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800d43:	e8 ae 0f 00 00       	call   801cf6 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d48:	83 c4 2c             	add    $0x2c,%esp
  800d4b:	5b                   	pop    %ebx
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
  800d56:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800d59:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5e:	b8 09 00 00 00       	mov    $0x9,%eax
  800d63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d66:	8b 55 08             	mov    0x8(%ebp),%edx
  800d69:	89 df                	mov    %ebx,%edi
  800d6b:	89 de                	mov    %ebx,%esi
  800d6d:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800d6f:	85 c0                	test   %eax,%eax
  800d71:	7e 28                	jle    800d9b <sys_env_set_trapframe+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800d73:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d77:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d7e:	00 
  800d7f:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  800d86:	00 
  800d87:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8e:	00 
  800d8f:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800d96:	e8 5b 0f 00 00       	call   801cf6 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t)tf, 0, 0, 0);
}
  800d9b:	83 c4 2c             	add    $0x2c,%esp
  800d9e:	5b                   	pop    %ebx
  800d9f:	5e                   	pop    %esi
  800da0:	5f                   	pop    %edi
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    

00800da3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	57                   	push   %edi
  800da7:	56                   	push   %esi
  800da8:	53                   	push   %ebx
  800da9:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800dac:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800db6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbc:	89 df                	mov    %ebx,%edi
  800dbe:	89 de                	mov    %ebx,%esi
  800dc0:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	7e 28                	jle    800dee <sys_env_set_pgfault_upcall+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800dc6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dca:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800dd1:	00 
  800dd2:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  800dd9:	00 
  800dda:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de1:	00 
  800de2:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800de9:	e8 08 0f 00 00       	call   801cf6 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800dee:	83 c4 2c             	add    $0x2c,%esp
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	5f                   	pop    %edi
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	57                   	push   %edi
  800dfa:	56                   	push   %esi
  800dfb:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800dfc:	be 00 00 00 00       	mov    $0x0,%esi
  800e01:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e09:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e0f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e12:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t)srcva, perm, 0);
}
  800e14:	5b                   	pop    %ebx
  800e15:	5e                   	pop    %esi
  800e16:	5f                   	pop    %edi
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    

00800e19 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	57                   	push   %edi
  800e1d:	56                   	push   %esi
  800e1e:	53                   	push   %ebx
  800e1f:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800e22:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e27:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2f:	89 cb                	mov    %ecx,%ebx
  800e31:	89 cf                	mov    %ecx,%edi
  800e33:	89 ce                	mov    %ecx,%esi
  800e35:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800e37:	85 c0                	test   %eax,%eax
  800e39:	7e 28                	jle    800e63 <sys_ipc_recv+0x4a>
    panic("syscall %d returned %d (> 0)", num, ret);
  800e3b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e46:	00 
  800e47:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  800e4e:	00 
  800e4f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e56:	00 
  800e57:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800e5e:	e8 93 0e 00 00       	call   801cf6 <_panic>

int
sys_ipc_recv(void *dstva)
{
  return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e63:	83 c4 2c             	add    $0x2c,%esp
  800e66:	5b                   	pop    %ebx
  800e67:	5e                   	pop    %esi
  800e68:	5f                   	pop    %edi
  800e69:	5d                   	pop    %ebp
  800e6a:	c3                   	ret    

00800e6b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	56                   	push   %esi
  800e6f:	53                   	push   %ebx
  800e70:	83 ec 10             	sub    $0x10,%esp
  800e73:	8b 75 08             	mov    0x8(%ebp),%esi
  800e76:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e79:	8b 5d 10             	mov    0x10(%ebp),%ebx
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;
  800e7c:	85 c0                	test   %eax,%eax
  800e7e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800e83:	0f 44 c2             	cmove  %edx,%eax
  if ((r = sys_ipc_recv(pg)) < 0) {
  800e86:	89 04 24             	mov    %eax,(%esp)
  800e89:	e8 8b ff ff ff       	call   800e19 <sys_ipc_recv>
  800e8e:	85 c0                	test   %eax,%eax
  800e90:	79 34                	jns    800ec6 <ipc_recv+0x5b>
    if (from_env_store)
  800e92:	85 f6                	test   %esi,%esi
  800e94:	74 06                	je     800e9c <ipc_recv+0x31>
      *from_env_store = 0;
  800e96:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (perm_store)
  800e9c:	85 db                	test   %ebx,%ebx
  800e9e:	74 06                	je     800ea6 <ipc_recv+0x3b>
      *perm_store = 0;
  800ea0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    panic("sys_ipc_recv: %e", r);
  800ea6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800eaa:	c7 44 24 08 8a 23 80 	movl   $0x80238a,0x8(%esp)
  800eb1:	00 
  800eb2:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800eb9:	00 
  800eba:	c7 04 24 9b 23 80 00 	movl   $0x80239b,(%esp)
  800ec1:	e8 30 0e 00 00       	call   801cf6 <_panic>
  }

  if (from_env_store)
  800ec6:	85 f6                	test   %esi,%esi
  800ec8:	74 0a                	je     800ed4 <ipc_recv+0x69>
    *from_env_store = thisenv->env_ipc_from;
  800eca:	a1 04 40 80 00       	mov    0x804004,%eax
  800ecf:	8b 40 74             	mov    0x74(%eax),%eax
  800ed2:	89 06                	mov    %eax,(%esi)
  if (perm_store)
  800ed4:	85 db                	test   %ebx,%ebx
  800ed6:	74 0a                	je     800ee2 <ipc_recv+0x77>
    *perm_store |= thisenv->env_ipc_perm;
  800ed8:	a1 04 40 80 00       	mov    0x804004,%eax
  800edd:	8b 40 78             	mov    0x78(%eax),%eax
  800ee0:	09 03                	or     %eax,(%ebx)

  return thisenv->env_ipc_value;
  800ee2:	a1 04 40 80 00       	mov    0x804004,%eax
  800ee7:	8b 40 70             	mov    0x70(%eax),%eax

}
  800eea:	83 c4 10             	add    $0x10,%esp
  800eed:	5b                   	pop    %ebx
  800eee:	5e                   	pop    %esi
  800eef:	5d                   	pop    %ebp
  800ef0:	c3                   	ret    

00800ef1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	57                   	push   %edi
  800ef5:	56                   	push   %esi
  800ef6:	53                   	push   %ebx
  800ef7:	83 ec 1c             	sub    $0x1c,%esp
  800efa:	8b 7d 08             	mov    0x8(%ebp),%edi
  800efd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f00:	8b 5d 10             	mov    0x10(%ebp),%ebx
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;
  800f03:	85 db                	test   %ebx,%ebx
  800f05:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  800f0a:	0f 44 d8             	cmove  %eax,%ebx

  while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  800f0d:	eb 2a                	jmp    800f39 <ipc_send+0x48>
    if (r != -E_IPC_NOT_RECV)
  800f0f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800f12:	74 20                	je     800f34 <ipc_send+0x43>
      panic("ipc_send: %e", r);
  800f14:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f18:	c7 44 24 08 a5 23 80 	movl   $0x8023a5,0x8(%esp)
  800f1f:	00 
  800f20:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  800f27:	00 
  800f28:	c7 04 24 9b 23 80 00 	movl   $0x80239b,(%esp)
  800f2f:	e8 c2 0d 00 00       	call   801cf6 <_panic>
    sys_yield();
  800f34:	e8 ab fc ff ff       	call   800be4 <sys_yield>
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;

  while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  800f39:	8b 45 14             	mov    0x14(%ebp),%eax
  800f3c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f40:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f44:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f48:	89 3c 24             	mov    %edi,(%esp)
  800f4b:	e8 a6 fe ff ff       	call   800df6 <sys_ipc_try_send>
  800f50:	85 c0                	test   %eax,%eax
  800f52:	78 bb                	js     800f0f <ipc_send+0x1e>
    if (r != -E_IPC_NOT_RECV)
      panic("ipc_send: %e", r);
    sys_yield();
  }
}
  800f54:	83 c4 1c             	add    $0x1c,%esp
  800f57:	5b                   	pop    %ebx
  800f58:	5e                   	pop    %esi
  800f59:	5f                   	pop    %edi
  800f5a:	5d                   	pop    %ebp
  800f5b:	c3                   	ret    

00800f5c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800f5c:	55                   	push   %ebp
  800f5d:	89 e5                	mov    %esp,%ebp
  800f5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int i;

  for (i = 0; i < NENV; i++)
  800f62:	b8 00 00 00 00       	mov    $0x0,%eax
    if (envs[i].env_type == type)
  800f67:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800f6a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800f70:	8b 52 50             	mov    0x50(%edx),%edx
  800f73:	39 ca                	cmp    %ecx,%edx
  800f75:	75 0d                	jne    800f84 <ipc_find_env+0x28>
      return envs[i].env_id;
  800f77:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f7a:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  800f7f:	8b 40 40             	mov    0x40(%eax),%eax
  800f82:	eb 0e                	jmp    800f92 <ipc_find_env+0x36>
envid_t
ipc_find_env(enum EnvType type)
{
  int i;

  for (i = 0; i < NENV; i++)
  800f84:	83 c0 01             	add    $0x1,%eax
  800f87:	3d 00 04 00 00       	cmp    $0x400,%eax
  800f8c:	75 d9                	jne    800f67 <ipc_find_env+0xb>
    if (envs[i].env_type == type)
      return envs[i].env_id;
  return 0;
  800f8e:	66 b8 00 00          	mov    $0x0,%ax
}
  800f92:	5d                   	pop    %ebp
  800f93:	c3                   	ret    
  800f94:	66 90                	xchg   %ax,%ax
  800f96:	66 90                	xchg   %ax,%ax
  800f98:	66 90                	xchg   %ax,%ax
  800f9a:	66 90                	xchg   %ax,%ax
  800f9c:	66 90                	xchg   %ax,%ax
  800f9e:	66 90                	xchg   %ax,%ax

00800fa0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  800fa3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa6:	05 00 00 00 30       	add    $0x30000000,%eax
  800fab:	c1 e8 0c             	shr    $0xc,%eax
}
  800fae:	5d                   	pop    %ebp
  800faf:	c3                   	ret    

00800fb0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  800fb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb6:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
  return INDEX2DATA(fd2num(fd));
  800fbb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800fc0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800fc5:	5d                   	pop    %ebp
  800fc6:	c3                   	ret    

00800fc7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800fc7:	55                   	push   %ebp
  800fc8:	89 e5                	mov    %esp,%ebp
  800fca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fcd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
  int i;
  struct Fd *fd;

  for (i = 0; i < MAXFD; i++) {
    fd = INDEX2FD(i);
    if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800fd2:	89 c2                	mov    %eax,%edx
  800fd4:	c1 ea 16             	shr    $0x16,%edx
  800fd7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fde:	f6 c2 01             	test   $0x1,%dl
  800fe1:	74 11                	je     800ff4 <fd_alloc+0x2d>
  800fe3:	89 c2                	mov    %eax,%edx
  800fe5:	c1 ea 0c             	shr    $0xc,%edx
  800fe8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fef:	f6 c2 01             	test   $0x1,%dl
  800ff2:	75 09                	jne    800ffd <fd_alloc+0x36>
      *fd_store = fd;
  800ff4:	89 01                	mov    %eax,(%ecx)
      return 0;
  800ff6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ffb:	eb 17                	jmp    801014 <fd_alloc+0x4d>
  800ffd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
  int i;
  struct Fd *fd;

  for (i = 0; i < MAXFD; i++) {
  801002:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801007:	75 c9                	jne    800fd2 <fd_alloc+0xb>
    if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
      *fd_store = fd;
      return 0;
    }
  }
  *fd_store = 0;
  801009:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
  return -E_MAX_OPEN;
  80100f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801014:	5d                   	pop    %ebp
  801015:	c3                   	ret    

00801016 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801016:	55                   	push   %ebp
  801017:	89 e5                	mov    %esp,%ebp
  801019:	8b 45 08             	mov    0x8(%ebp),%eax
  struct Fd *fd;

  if (fdnum < 0 || fdnum >= MAXFD) {
  80101c:	83 f8 1f             	cmp    $0x1f,%eax
  80101f:	77 36                	ja     801057 <fd_lookup+0x41>
    if (debug)
      cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  fd = INDEX2FD(fdnum);
  801021:	c1 e0 0c             	shl    $0xc,%eax
  801024:	2d 00 00 00 30       	sub    $0x30000000,%eax
  if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801029:	89 c2                	mov    %eax,%edx
  80102b:	c1 ea 16             	shr    $0x16,%edx
  80102e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801035:	f6 c2 01             	test   $0x1,%dl
  801038:	74 24                	je     80105e <fd_lookup+0x48>
  80103a:	89 c2                	mov    %eax,%edx
  80103c:	c1 ea 0c             	shr    $0xc,%edx
  80103f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801046:	f6 c2 01             	test   $0x1,%dl
  801049:	74 1a                	je     801065 <fd_lookup+0x4f>
    if (debug)
      cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  *fd_store = fd;
  80104b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80104e:	89 02                	mov    %eax,(%edx)
  return 0;
  801050:	b8 00 00 00 00       	mov    $0x0,%eax
  801055:	eb 13                	jmp    80106a <fd_lookup+0x54>
  struct Fd *fd;

  if (fdnum < 0 || fdnum >= MAXFD) {
    if (debug)
      cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  801057:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80105c:	eb 0c                	jmp    80106a <fd_lookup+0x54>
  }
  fd = INDEX2FD(fdnum);
  if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
    if (debug)
      cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  80105e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801063:	eb 05                	jmp    80106a <fd_lookup+0x54>
  801065:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  }
  *fd_store = fd;
  return 0;
}
  80106a:	5d                   	pop    %ebp
  80106b:	c3                   	ret    

0080106c <dev_lookup>:
  0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
  80106f:	83 ec 18             	sub    $0x18,%esp
  801072:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801075:	ba 30 24 80 00       	mov    $0x802430,%edx
  int i;

  for (i = 0; devtab[i]; i++)
  80107a:	eb 13                	jmp    80108f <dev_lookup+0x23>
  80107c:	83 c2 04             	add    $0x4,%edx
    if (devtab[i]->dev_id == dev_id) {
  80107f:	39 08                	cmp    %ecx,(%eax)
  801081:	75 0c                	jne    80108f <dev_lookup+0x23>
      *dev = devtab[i];
  801083:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801086:	89 01                	mov    %eax,(%ecx)
      return 0;
  801088:	b8 00 00 00 00       	mov    $0x0,%eax
  80108d:	eb 30                	jmp    8010bf <dev_lookup+0x53>
int
dev_lookup(int dev_id, struct Dev **dev)
{
  int i;

  for (i = 0; devtab[i]; i++)
  80108f:	8b 02                	mov    (%edx),%eax
  801091:	85 c0                	test   %eax,%eax
  801093:	75 e7                	jne    80107c <dev_lookup+0x10>
    if (devtab[i]->dev_id == dev_id) {
      *dev = devtab[i];
      return 0;
    }
  cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801095:	a1 04 40 80 00       	mov    0x804004,%eax
  80109a:	8b 40 48             	mov    0x48(%eax),%eax
  80109d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010a5:	c7 04 24 b4 23 80 00 	movl   $0x8023b4,(%esp)
  8010ac:	e8 15 f1 ff ff       	call   8001c6 <cprintf>
  *dev = 0;
  8010b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010b4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  return -E_INVAL;
  8010ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010bf:	c9                   	leave  
  8010c0:	c3                   	ret    

008010c1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8010c1:	55                   	push   %ebp
  8010c2:	89 e5                	mov    %esp,%ebp
  8010c4:	56                   	push   %esi
  8010c5:	53                   	push   %ebx
  8010c6:	83 ec 20             	sub    $0x20,%esp
  8010c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8010cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct Fd *fd2;
  struct Dev *dev;
  int r;

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010d2:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  8010d6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8010dc:	c1 e8 0c             	shr    $0xc,%eax
{
  struct Fd *fd2;
  struct Dev *dev;
  int r;

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010df:	89 04 24             	mov    %eax,(%esp)
  8010e2:	e8 2f ff ff ff       	call   801016 <fd_lookup>
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	78 05                	js     8010f0 <fd_close+0x2f>
      || fd != fd2)
  8010eb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8010ee:	74 0c                	je     8010fc <fd_close+0x3b>
    return must_exist ? r : 0;
  8010f0:	84 db                	test   %bl,%bl
  8010f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8010f7:	0f 44 c2             	cmove  %edx,%eax
  8010fa:	eb 3f                	jmp    80113b <fd_close+0x7a>
  if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801103:	8b 06                	mov    (%esi),%eax
  801105:	89 04 24             	mov    %eax,(%esp)
  801108:	e8 5f ff ff ff       	call   80106c <dev_lookup>
  80110d:	89 c3                	mov    %eax,%ebx
  80110f:	85 c0                	test   %eax,%eax
  801111:	78 16                	js     801129 <fd_close+0x68>
    if (dev->dev_close)
  801113:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801116:	8b 40 10             	mov    0x10(%eax),%eax
      r = (*dev->dev_close)(fd);
    else
      r = 0;
  801119:	bb 00 00 00 00       	mov    $0x0,%ebx

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
      || fd != fd2)
    return must_exist ? r : 0;
  if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
    if (dev->dev_close)
  80111e:	85 c0                	test   %eax,%eax
  801120:	74 07                	je     801129 <fd_close+0x68>
      r = (*dev->dev_close)(fd);
  801122:	89 34 24             	mov    %esi,(%esp)
  801125:	ff d0                	call   *%eax
  801127:	89 c3                	mov    %eax,%ebx
    else
      r = 0;
  }
  // Make sure fd is unmapped.  Might be a no-op if
  // (*dev->dev_close)(fd) already unmapped it.
  (void)sys_page_unmap(0, fd);
  801129:	89 74 24 04          	mov    %esi,0x4(%esp)
  80112d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801134:	e8 71 fb ff ff       	call   800caa <sys_page_unmap>
  return r;
  801139:	89 d8                	mov    %ebx,%eax
}
  80113b:	83 c4 20             	add    $0x20,%esp
  80113e:	5b                   	pop    %ebx
  80113f:	5e                   	pop    %esi
  801140:	5d                   	pop    %ebp
  801141:	c3                   	ret    

00801142 <close>:
  return -E_INVAL;
}

int
close(int fdnum)
{
  801142:	55                   	push   %ebp
  801143:	89 e5                	mov    %esp,%ebp
  801145:	83 ec 28             	sub    $0x28,%esp
  struct Fd *fd;
  int r;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  801148:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80114b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80114f:	8b 45 08             	mov    0x8(%ebp),%eax
  801152:	89 04 24             	mov    %eax,(%esp)
  801155:	e8 bc fe ff ff       	call   801016 <fd_lookup>
  80115a:	89 c2                	mov    %eax,%edx
  80115c:	85 d2                	test   %edx,%edx
  80115e:	78 13                	js     801173 <close+0x31>
    return r;
  else
    return fd_close(fd, 1);
  801160:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801167:	00 
  801168:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80116b:	89 04 24             	mov    %eax,(%esp)
  80116e:	e8 4e ff ff ff       	call   8010c1 <fd_close>
}
  801173:	c9                   	leave  
  801174:	c3                   	ret    

00801175 <close_all>:

void
close_all(void)
{
  801175:	55                   	push   %ebp
  801176:	89 e5                	mov    %esp,%ebp
  801178:	53                   	push   %ebx
  801179:	83 ec 14             	sub    $0x14,%esp
  int i;

  for (i = 0; i < MAXFD; i++)
  80117c:	bb 00 00 00 00       	mov    $0x0,%ebx
    close(i);
  801181:	89 1c 24             	mov    %ebx,(%esp)
  801184:	e8 b9 ff ff ff       	call   801142 <close>
void
close_all(void)
{
  int i;

  for (i = 0; i < MAXFD; i++)
  801189:	83 c3 01             	add    $0x1,%ebx
  80118c:	83 fb 20             	cmp    $0x20,%ebx
  80118f:	75 f0                	jne    801181 <close_all+0xc>
    close(i);
}
  801191:	83 c4 14             	add    $0x14,%esp
  801194:	5b                   	pop    %ebx
  801195:	5d                   	pop    %ebp
  801196:	c3                   	ret    

00801197 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	57                   	push   %edi
  80119b:	56                   	push   %esi
  80119c:	53                   	push   %ebx
  80119d:	83 ec 3c             	sub    $0x3c,%esp
  int r;
  char *ova, *nva;
  pte_t pte;
  struct Fd *oldfd, *newfd;

  if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011a0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011aa:	89 04 24             	mov    %eax,(%esp)
  8011ad:	e8 64 fe ff ff       	call   801016 <fd_lookup>
  8011b2:	89 c2                	mov    %eax,%edx
  8011b4:	85 d2                	test   %edx,%edx
  8011b6:	0f 88 e1 00 00 00    	js     80129d <dup+0x106>
    return r;
  close(newfdnum);
  8011bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011bf:	89 04 24             	mov    %eax,(%esp)
  8011c2:	e8 7b ff ff ff       	call   801142 <close>

  newfd = INDEX2FD(newfdnum);
  8011c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011ca:	c1 e3 0c             	shl    $0xc,%ebx
  8011cd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
  ova = fd2data(oldfd);
  8011d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011d6:	89 04 24             	mov    %eax,(%esp)
  8011d9:	e8 d2 fd ff ff       	call   800fb0 <fd2data>
  8011de:	89 c6                	mov    %eax,%esi
  nva = fd2data(newfd);
  8011e0:	89 1c 24             	mov    %ebx,(%esp)
  8011e3:	e8 c8 fd ff ff       	call   800fb0 <fd2data>
  8011e8:	89 c7                	mov    %eax,%edi

  if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8011ea:	89 f0                	mov    %esi,%eax
  8011ec:	c1 e8 16             	shr    $0x16,%eax
  8011ef:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011f6:	a8 01                	test   $0x1,%al
  8011f8:	74 43                	je     80123d <dup+0xa6>
  8011fa:	89 f0                	mov    %esi,%eax
  8011fc:	c1 e8 0c             	shr    $0xc,%eax
  8011ff:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801206:	f6 c2 01             	test   $0x1,%dl
  801209:	74 32                	je     80123d <dup+0xa6>
    if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80120b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801212:	25 07 0e 00 00       	and    $0xe07,%eax
  801217:	89 44 24 10          	mov    %eax,0x10(%esp)
  80121b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80121f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801226:	00 
  801227:	89 74 24 04          	mov    %esi,0x4(%esp)
  80122b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801232:	e8 20 fa ff ff       	call   800c57 <sys_page_map>
  801237:	89 c6                	mov    %eax,%esi
  801239:	85 c0                	test   %eax,%eax
  80123b:	78 3e                	js     80127b <dup+0xe4>
      goto err;
  if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80123d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801240:	89 c2                	mov    %eax,%edx
  801242:	c1 ea 0c             	shr    $0xc,%edx
  801245:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80124c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801252:	89 54 24 10          	mov    %edx,0x10(%esp)
  801256:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80125a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801261:	00 
  801262:	89 44 24 04          	mov    %eax,0x4(%esp)
  801266:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80126d:	e8 e5 f9 ff ff       	call   800c57 <sys_page_map>
  801272:	89 c6                	mov    %eax,%esi
    goto err;

  return newfdnum;
  801274:	8b 45 0c             	mov    0xc(%ebp),%eax
  nva = fd2data(newfd);

  if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
    if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
      goto err;
  if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801277:	85 f6                	test   %esi,%esi
  801279:	79 22                	jns    80129d <dup+0x106>
    goto err;

  return newfdnum;

err:
  sys_page_unmap(0, newfd);
  80127b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80127f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801286:	e8 1f fa ff ff       	call   800caa <sys_page_unmap>
  sys_page_unmap(0, nva);
  80128b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80128f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801296:	e8 0f fa ff ff       	call   800caa <sys_page_unmap>
  return r;
  80129b:	89 f0                	mov    %esi,%eax
}
  80129d:	83 c4 3c             	add    $0x3c,%esp
  8012a0:	5b                   	pop    %ebx
  8012a1:	5e                   	pop    %esi
  8012a2:	5f                   	pop    %edi
  8012a3:	5d                   	pop    %ebp
  8012a4:	c3                   	ret    

008012a5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012a5:	55                   	push   %ebp
  8012a6:	89 e5                	mov    %esp,%ebp
  8012a8:	53                   	push   %ebx
  8012a9:	83 ec 24             	sub    $0x24,%esp
  8012ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  8012af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b6:	89 1c 24             	mov    %ebx,(%esp)
  8012b9:	e8 58 fd ff ff       	call   801016 <fd_lookup>
  8012be:	89 c2                	mov    %eax,%edx
  8012c0:	85 d2                	test   %edx,%edx
  8012c2:	78 6d                	js     801331 <read+0x8c>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ce:	8b 00                	mov    (%eax),%eax
  8012d0:	89 04 24             	mov    %eax,(%esp)
  8012d3:	e8 94 fd ff ff       	call   80106c <dev_lookup>
  8012d8:	85 c0                	test   %eax,%eax
  8012da:	78 55                	js     801331 <read+0x8c>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8012dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012df:	8b 50 08             	mov    0x8(%eax),%edx
  8012e2:	83 e2 03             	and    $0x3,%edx
  8012e5:	83 fa 01             	cmp    $0x1,%edx
  8012e8:	75 23                	jne    80130d <read+0x68>
    cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8012ea:	a1 04 40 80 00       	mov    0x804004,%eax
  8012ef:	8b 40 48             	mov    0x48(%eax),%eax
  8012f2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012fa:	c7 04 24 f5 23 80 00 	movl   $0x8023f5,(%esp)
  801301:	e8 c0 ee ff ff       	call   8001c6 <cprintf>
    return -E_INVAL;
  801306:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80130b:	eb 24                	jmp    801331 <read+0x8c>
  }
  if (!dev->dev_read)
  80130d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801310:	8b 52 08             	mov    0x8(%edx),%edx
  801313:	85 d2                	test   %edx,%edx
  801315:	74 15                	je     80132c <read+0x87>
    return -E_NOT_SUPP;
  return (*dev->dev_read)(fd, buf, n);
  801317:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80131a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80131e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801321:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801325:	89 04 24             	mov    %eax,(%esp)
  801328:	ff d2                	call   *%edx
  80132a:	eb 05                	jmp    801331 <read+0x8c>
  if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
    cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  if (!dev->dev_read)
    return -E_NOT_SUPP;
  80132c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_read)(fd, buf, n);
}
  801331:	83 c4 24             	add    $0x24,%esp
  801334:	5b                   	pop    %ebx
  801335:	5d                   	pop    %ebp
  801336:	c3                   	ret    

00801337 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801337:	55                   	push   %ebp
  801338:	89 e5                	mov    %esp,%ebp
  80133a:	57                   	push   %edi
  80133b:	56                   	push   %esi
  80133c:	53                   	push   %ebx
  80133d:	83 ec 1c             	sub    $0x1c,%esp
  801340:	8b 7d 08             	mov    0x8(%ebp),%edi
  801343:	8b 75 10             	mov    0x10(%ebp),%esi
  int m, tot;

  for (tot = 0; tot < n; tot += m) {
  801346:	bb 00 00 00 00       	mov    $0x0,%ebx
  80134b:	eb 23                	jmp    801370 <readn+0x39>
    m = read(fdnum, (char*)buf + tot, n - tot);
  80134d:	89 f0                	mov    %esi,%eax
  80134f:	29 d8                	sub    %ebx,%eax
  801351:	89 44 24 08          	mov    %eax,0x8(%esp)
  801355:	89 d8                	mov    %ebx,%eax
  801357:	03 45 0c             	add    0xc(%ebp),%eax
  80135a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80135e:	89 3c 24             	mov    %edi,(%esp)
  801361:	e8 3f ff ff ff       	call   8012a5 <read>
    if (m < 0)
  801366:	85 c0                	test   %eax,%eax
  801368:	78 10                	js     80137a <readn+0x43>
      return m;
    if (m == 0)
  80136a:	85 c0                	test   %eax,%eax
  80136c:	74 0a                	je     801378 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
  int m, tot;

  for (tot = 0; tot < n; tot += m) {
  80136e:	01 c3                	add    %eax,%ebx
  801370:	39 f3                	cmp    %esi,%ebx
  801372:	72 d9                	jb     80134d <readn+0x16>
  801374:	89 d8                	mov    %ebx,%eax
  801376:	eb 02                	jmp    80137a <readn+0x43>
  801378:	89 d8                	mov    %ebx,%eax
      return m;
    if (m == 0)
      break;
  }
  return tot;
}
  80137a:	83 c4 1c             	add    $0x1c,%esp
  80137d:	5b                   	pop    %ebx
  80137e:	5e                   	pop    %esi
  80137f:	5f                   	pop    %edi
  801380:	5d                   	pop    %ebp
  801381:	c3                   	ret    

00801382 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801382:	55                   	push   %ebp
  801383:	89 e5                	mov    %esp,%ebp
  801385:	53                   	push   %ebx
  801386:	83 ec 24             	sub    $0x24,%esp
  801389:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  80138c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801393:	89 1c 24             	mov    %ebx,(%esp)
  801396:	e8 7b fc ff ff       	call   801016 <fd_lookup>
  80139b:	89 c2                	mov    %eax,%edx
  80139d:	85 d2                	test   %edx,%edx
  80139f:	78 68                	js     801409 <write+0x87>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ab:	8b 00                	mov    (%eax),%eax
  8013ad:	89 04 24             	mov    %eax,(%esp)
  8013b0:	e8 b7 fc ff ff       	call   80106c <dev_lookup>
  8013b5:	85 c0                	test   %eax,%eax
  8013b7:	78 50                	js     801409 <write+0x87>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013bc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013c0:	75 23                	jne    8013e5 <write+0x63>
    cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013c2:	a1 04 40 80 00       	mov    0x804004,%eax
  8013c7:	8b 40 48             	mov    0x48(%eax),%eax
  8013ca:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d2:	c7 04 24 11 24 80 00 	movl   $0x802411,(%esp)
  8013d9:	e8 e8 ed ff ff       	call   8001c6 <cprintf>
    return -E_INVAL;
  8013de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013e3:	eb 24                	jmp    801409 <write+0x87>
  }
  if (debug)
    cprintf("write %d %p %d via dev %s\n",
            fdnum, buf, n, dev->dev_name);
  if (!dev->dev_write)
  8013e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013e8:	8b 52 0c             	mov    0xc(%edx),%edx
  8013eb:	85 d2                	test   %edx,%edx
  8013ed:	74 15                	je     801404 <write+0x82>
    return -E_NOT_SUPP;
  return (*dev->dev_write)(fd, buf, n);
  8013ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8013f2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013f9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013fd:	89 04 24             	mov    %eax,(%esp)
  801400:	ff d2                	call   *%edx
  801402:	eb 05                	jmp    801409 <write+0x87>
  }
  if (debug)
    cprintf("write %d %p %d via dev %s\n",
            fdnum, buf, n, dev->dev_name);
  if (!dev->dev_write)
    return -E_NOT_SUPP;
  801404:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_write)(fd, buf, n);
}
  801409:	83 c4 24             	add    $0x24,%esp
  80140c:	5b                   	pop    %ebx
  80140d:	5d                   	pop    %ebp
  80140e:	c3                   	ret    

0080140f <seek>:

int
seek(int fdnum, off_t offset)
{
  80140f:	55                   	push   %ebp
  801410:	89 e5                	mov    %esp,%ebp
  801412:	83 ec 18             	sub    $0x18,%esp
  int r;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  801415:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801418:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141c:	8b 45 08             	mov    0x8(%ebp),%eax
  80141f:	89 04 24             	mov    %eax,(%esp)
  801422:	e8 ef fb ff ff       	call   801016 <fd_lookup>
  801427:	85 c0                	test   %eax,%eax
  801429:	78 0e                	js     801439 <seek+0x2a>
    return r;
  fd->fd_offset = offset;
  80142b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80142e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801431:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
  801434:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801439:	c9                   	leave  
  80143a:	c3                   	ret    

0080143b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80143b:	55                   	push   %ebp
  80143c:	89 e5                	mov    %esp,%ebp
  80143e:	53                   	push   %ebx
  80143f:	83 ec 24             	sub    $0x24,%esp
  801442:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  801445:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801448:	89 44 24 04          	mov    %eax,0x4(%esp)
  80144c:	89 1c 24             	mov    %ebx,(%esp)
  80144f:	e8 c2 fb ff ff       	call   801016 <fd_lookup>
  801454:	89 c2                	mov    %eax,%edx
  801456:	85 d2                	test   %edx,%edx
  801458:	78 61                	js     8014bb <ftruncate+0x80>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80145a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80145d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801461:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801464:	8b 00                	mov    (%eax),%eax
  801466:	89 04 24             	mov    %eax,(%esp)
  801469:	e8 fe fb ff ff       	call   80106c <dev_lookup>
  80146e:	85 c0                	test   %eax,%eax
  801470:	78 49                	js     8014bb <ftruncate+0x80>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801472:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801475:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801479:	75 23                	jne    80149e <ftruncate+0x63>
    cprintf("[%08x] ftruncate %d -- bad mode\n",
            thisenv->env_id, fdnum);
  80147b:	a1 04 40 80 00       	mov    0x804004,%eax

  if ((r = fd_lookup(fdnum, &fd)) < 0
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
    cprintf("[%08x] ftruncate %d -- bad mode\n",
  801480:	8b 40 48             	mov    0x48(%eax),%eax
  801483:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801487:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148b:	c7 04 24 d4 23 80 00 	movl   $0x8023d4,(%esp)
  801492:	e8 2f ed ff ff       	call   8001c6 <cprintf>
            thisenv->env_id, fdnum);
    return -E_INVAL;
  801497:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80149c:	eb 1d                	jmp    8014bb <ftruncate+0x80>
  }
  if (!dev->dev_trunc)
  80149e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014a1:	8b 52 18             	mov    0x18(%edx),%edx
  8014a4:	85 d2                	test   %edx,%edx
  8014a6:	74 0e                	je     8014b6 <ftruncate+0x7b>
    return -E_NOT_SUPP;
  return (*dev->dev_trunc)(fd, newsize);
  8014a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014ab:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014af:	89 04 24             	mov    %eax,(%esp)
  8014b2:	ff d2                	call   *%edx
  8014b4:	eb 05                	jmp    8014bb <ftruncate+0x80>
    cprintf("[%08x] ftruncate %d -- bad mode\n",
            thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  if (!dev->dev_trunc)
    return -E_NOT_SUPP;
  8014b6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_trunc)(fd, newsize);
}
  8014bb:	83 c4 24             	add    $0x24,%esp
  8014be:	5b                   	pop    %ebx
  8014bf:	5d                   	pop    %ebp
  8014c0:	c3                   	ret    

008014c1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014c1:	55                   	push   %ebp
  8014c2:	89 e5                	mov    %esp,%ebp
  8014c4:	53                   	push   %ebx
  8014c5:	83 ec 24             	sub    $0x24,%esp
  8014c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  8014cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d5:	89 04 24             	mov    %eax,(%esp)
  8014d8:	e8 39 fb ff ff       	call   801016 <fd_lookup>
  8014dd:	89 c2                	mov    %eax,%edx
  8014df:	85 d2                	test   %edx,%edx
  8014e1:	78 52                	js     801535 <fstat+0x74>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ed:	8b 00                	mov    (%eax),%eax
  8014ef:	89 04 24             	mov    %eax,(%esp)
  8014f2:	e8 75 fb ff ff       	call   80106c <dev_lookup>
  8014f7:	85 c0                	test   %eax,%eax
  8014f9:	78 3a                	js     801535 <fstat+0x74>
    return r;
  if (!dev->dev_stat)
  8014fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014fe:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801502:	74 2c                	je     801530 <fstat+0x6f>
    return -E_NOT_SUPP;
  stat->st_name[0] = 0;
  801504:	c6 03 00             	movb   $0x0,(%ebx)
  stat->st_size = 0;
  801507:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80150e:	00 00 00 
  stat->st_isdir = 0;
  801511:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801518:	00 00 00 
  stat->st_dev = dev;
  80151b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
  return (*dev->dev_stat)(fd, stat);
  801521:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801525:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801528:	89 14 24             	mov    %edx,(%esp)
  80152b:	ff 50 14             	call   *0x14(%eax)
  80152e:	eb 05                	jmp    801535 <fstat+0x74>

  if ((r = fd_lookup(fdnum, &fd)) < 0
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
    return r;
  if (!dev->dev_stat)
    return -E_NOT_SUPP;
  801530:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  stat->st_name[0] = 0;
  stat->st_size = 0;
  stat->st_isdir = 0;
  stat->st_dev = dev;
  return (*dev->dev_stat)(fd, stat);
}
  801535:	83 c4 24             	add    $0x24,%esp
  801538:	5b                   	pop    %ebx
  801539:	5d                   	pop    %ebp
  80153a:	c3                   	ret    

0080153b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80153b:	55                   	push   %ebp
  80153c:	89 e5                	mov    %esp,%ebp
  80153e:	56                   	push   %esi
  80153f:	53                   	push   %ebx
  801540:	83 ec 10             	sub    $0x10,%esp
  int fd, r;

  if ((fd = open(path, O_RDONLY)) < 0)
  801543:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80154a:	00 
  80154b:	8b 45 08             	mov    0x8(%ebp),%eax
  80154e:	89 04 24             	mov    %eax,(%esp)
  801551:	e8 d2 01 00 00       	call   801728 <open>
  801556:	89 c3                	mov    %eax,%ebx
  801558:	85 db                	test   %ebx,%ebx
  80155a:	78 1b                	js     801577 <stat+0x3c>
    return fd;
  r = fstat(fd, stat);
  80155c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80155f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801563:	89 1c 24             	mov    %ebx,(%esp)
  801566:	e8 56 ff ff ff       	call   8014c1 <fstat>
  80156b:	89 c6                	mov    %eax,%esi
  close(fd);
  80156d:	89 1c 24             	mov    %ebx,(%esp)
  801570:	e8 cd fb ff ff       	call   801142 <close>
  return r;
  801575:	89 f0                	mov    %esi,%eax
}
  801577:	83 c4 10             	add    $0x10,%esp
  80157a:	5b                   	pop    %ebx
  80157b:	5e                   	pop    %esi
  80157c:	5d                   	pop    %ebp
  80157d:	c3                   	ret    

0080157e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80157e:	55                   	push   %ebp
  80157f:	89 e5                	mov    %esp,%ebp
  801581:	56                   	push   %esi
  801582:	53                   	push   %ebx
  801583:	83 ec 10             	sub    $0x10,%esp
  801586:	89 c6                	mov    %eax,%esi
  801588:	89 d3                	mov    %edx,%ebx
  static envid_t fsenv;

  if (fsenv == 0)
  80158a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801591:	75 11                	jne    8015a4 <fsipc+0x26>
    fsenv = ipc_find_env(ENV_TYPE_FS);
  801593:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80159a:	e8 bd f9 ff ff       	call   800f5c <ipc_find_env>
  80159f:	a3 00 40 80 00       	mov    %eax,0x804000
  static_assert(sizeof(fsipcbuf) == PGSIZE);

  if (debug)
    cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t*)&fsipcbuf);

  ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015a4:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8015ab:	00 
  8015ac:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8015b3:	00 
  8015b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015b8:	a1 00 40 80 00       	mov    0x804000,%eax
  8015bd:	89 04 24             	mov    %eax,(%esp)
  8015c0:	e8 2c f9 ff ff       	call   800ef1 <ipc_send>
  return ipc_recv(NULL, dstva, NULL);
  8015c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015cc:	00 
  8015cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015d8:	e8 8e f8 ff ff       	call   800e6b <ipc_recv>
}
  8015dd:	83 c4 10             	add    $0x10,%esp
  8015e0:	5b                   	pop    %ebx
  8015e1:	5e                   	pop    %esi
  8015e2:	5d                   	pop    %ebp
  8015e3:	c3                   	ret    

008015e4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8015e4:	55                   	push   %ebp
  8015e5:	89 e5                	mov    %esp,%ebp
  8015e7:	83 ec 08             	sub    $0x8,%esp
  fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8015ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8015f0:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.set_size.req_size = newsize;
  8015f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015f8:	a3 04 50 80 00       	mov    %eax,0x805004
  return fsipc(FSREQ_SET_SIZE, NULL);
  8015fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801602:	b8 02 00 00 00       	mov    $0x2,%eax
  801607:	e8 72 ff ff ff       	call   80157e <fsipc>
}
  80160c:	c9                   	leave  
  80160d:	c3                   	ret    

0080160e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80160e:	55                   	push   %ebp
  80160f:	89 e5                	mov    %esp,%ebp
  801611:	83 ec 08             	sub    $0x8,%esp
  fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801614:	8b 45 08             	mov    0x8(%ebp),%eax
  801617:	8b 40 0c             	mov    0xc(%eax),%eax
  80161a:	a3 00 50 80 00       	mov    %eax,0x805000
  return fsipc(FSREQ_FLUSH, NULL);
  80161f:	ba 00 00 00 00       	mov    $0x0,%edx
  801624:	b8 06 00 00 00       	mov    $0x6,%eax
  801629:	e8 50 ff ff ff       	call   80157e <fsipc>
}
  80162e:	c9                   	leave  
  80162f:	c3                   	ret    

00801630 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	53                   	push   %ebx
  801634:	83 ec 14             	sub    $0x14,%esp
  801637:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int r;

  fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80163a:	8b 45 08             	mov    0x8(%ebp),%eax
  80163d:	8b 40 0c             	mov    0xc(%eax),%eax
  801640:	a3 00 50 80 00       	mov    %eax,0x805000
  if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801645:	ba 00 00 00 00       	mov    $0x0,%edx
  80164a:	b8 05 00 00 00       	mov    $0x5,%eax
  80164f:	e8 2a ff ff ff       	call   80157e <fsipc>
  801654:	89 c2                	mov    %eax,%edx
  801656:	85 d2                	test   %edx,%edx
  801658:	78 2b                	js     801685 <devfile_stat+0x55>
    return r;
  strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80165a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801661:	00 
  801662:	89 1c 24             	mov    %ebx,(%esp)
  801665:	e8 7d f1 ff ff       	call   8007e7 <strcpy>
  st->st_size = fsipcbuf.statRet.ret_size;
  80166a:	a1 80 50 80 00       	mov    0x805080,%eax
  80166f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801675:	a1 84 50 80 00       	mov    0x805084,%eax
  80167a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  return 0;
  801680:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801685:	83 c4 14             	add    $0x14,%esp
  801688:	5b                   	pop    %ebx
  801689:	5d                   	pop    %ebp
  80168a:	c3                   	ret    

0080168b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	83 ec 18             	sub    $0x18,%esp
  801691:	8b 45 10             	mov    0x10(%ebp),%eax
  // remember that write is always allowed to write *fewer*
  // bytes than requested.
  // LAB 5: Your code here
    int r;

    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801694:	8b 55 08             	mov    0x8(%ebp),%edx
  801697:	8b 52 0c             	mov    0xc(%edx),%edx
  80169a:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  8016a0:	a3 04 50 80 00       	mov    %eax,0x805004

    size_t max_written = sizeof(fsipcbuf.write.req_buf);
    memmove(fsipcbuf.write.req_buf, buf, MIN(max_written, n));
  8016a5:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8016aa:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8016af:	0f 47 c2             	cmova  %edx,%eax
  8016b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016bd:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8016c4:	e8 bb f2 ff ff       	call   800984 <memmove>

    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8016c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ce:	b8 04 00 00 00       	mov    $0x4,%eax
  8016d3:	e8 a6 fe ff ff       	call   80157e <fsipc>
        return r;

    return r;
}
  8016d8:	c9                   	leave  
  8016d9:	c3                   	ret    

008016da <devfile_read>:
// Returns:
//  The number of bytes successfully read.
//  < 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016da:	55                   	push   %ebp
  8016db:	89 e5                	mov    %esp,%ebp
  8016dd:	53                   	push   %ebx
  8016de:	83 ec 14             	sub    $0x14,%esp
  // filling fsipcbuf.read with the request arguments.  The
  // bytes read will be written back to fsipcbuf by the file
  // system server.
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e7:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  8016ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8016ef:	a3 04 50 80 00       	mov    %eax,0x805004
  if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f9:	b8 03 00 00 00       	mov    $0x3,%eax
  8016fe:	e8 7b fe ff ff       	call   80157e <fsipc>
  801703:	89 c3                	mov    %eax,%ebx
  801705:	85 c0                	test   %eax,%eax
  801707:	78 17                	js     801720 <devfile_read+0x46>
    return r;

  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801709:	89 44 24 08          	mov    %eax,0x8(%esp)
  80170d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801714:	00 
  801715:	8b 45 0c             	mov    0xc(%ebp),%eax
  801718:	89 04 24             	mov    %eax,(%esp)
  80171b:	e8 64 f2 ff ff       	call   800984 <memmove>
  return r;
}
  801720:	89 d8                	mov    %ebx,%eax
  801722:	83 c4 14             	add    $0x14,%esp
  801725:	5b                   	pop    %ebx
  801726:	5d                   	pop    %ebp
  801727:	c3                   	ret    

00801728 <open>:
//  The file descriptor index on success
//  -E_BAD_PATH if the path is too long (>= MAXPATHLEN)
//  < 0 for other errors.
int
open(const char *path, int mode)
{
  801728:	55                   	push   %ebp
  801729:	89 e5                	mov    %esp,%ebp
  80172b:	53                   	push   %ebx
  80172c:	83 ec 24             	sub    $0x24,%esp
  80172f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  // file descriptor.

  int r;
  struct Fd *fd;

  if (strlen(path) >= MAXPATHLEN)
  801732:	89 1c 24             	mov    %ebx,(%esp)
  801735:	e8 76 f0 ff ff       	call   8007b0 <strlen>
  80173a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80173f:	7f 60                	jg     8017a1 <open+0x79>
    return -E_BAD_PATH;

  if ((r = fd_alloc(&fd)) < 0)
  801741:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801744:	89 04 24             	mov    %eax,(%esp)
  801747:	e8 7b f8 ff ff       	call   800fc7 <fd_alloc>
  80174c:	89 c2                	mov    %eax,%edx
  80174e:	85 d2                	test   %edx,%edx
  801750:	78 54                	js     8017a6 <open+0x7e>
    return r;

  strcpy(fsipcbuf.open.req_path, path);
  801752:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801756:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80175d:	e8 85 f0 ff ff       	call   8007e7 <strcpy>
  fsipcbuf.open.req_omode = mode;
  801762:	8b 45 0c             	mov    0xc(%ebp),%eax
  801765:	a3 00 54 80 00       	mov    %eax,0x805400

  if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80176a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80176d:	b8 01 00 00 00       	mov    $0x1,%eax
  801772:	e8 07 fe ff ff       	call   80157e <fsipc>
  801777:	89 c3                	mov    %eax,%ebx
  801779:	85 c0                	test   %eax,%eax
  80177b:	79 17                	jns    801794 <open+0x6c>
    fd_close(fd, 0);
  80177d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801784:	00 
  801785:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801788:	89 04 24             	mov    %eax,(%esp)
  80178b:	e8 31 f9 ff ff       	call   8010c1 <fd_close>
    return r;
  801790:	89 d8                	mov    %ebx,%eax
  801792:	eb 12                	jmp    8017a6 <open+0x7e>
  }

  return fd2num(fd);
  801794:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801797:	89 04 24             	mov    %eax,(%esp)
  80179a:	e8 01 f8 ff ff       	call   800fa0 <fd2num>
  80179f:	eb 05                	jmp    8017a6 <open+0x7e>

  int r;
  struct Fd *fd;

  if (strlen(path) >= MAXPATHLEN)
    return -E_BAD_PATH;
  8017a1:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
    fd_close(fd, 0);
    return r;
  }

  return fd2num(fd);
}
  8017a6:	83 c4 24             	add    $0x24,%esp
  8017a9:	5b                   	pop    %ebx
  8017aa:	5d                   	pop    %ebp
  8017ab:	c3                   	ret    

008017ac <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017ac:	55                   	push   %ebp
  8017ad:	89 e5                	mov    %esp,%ebp
  8017af:	83 ec 08             	sub    $0x8,%esp
  // Ask the file server to update the disk
  // by writing any dirty blocks in the buffer cache.

  return fsipc(FSREQ_SYNC, NULL);
  8017b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b7:	b8 08 00 00 00       	mov    $0x8,%eax
  8017bc:	e8 bd fd ff ff       	call   80157e <fsipc>
}
  8017c1:	c9                   	leave  
  8017c2:	c3                   	ret    

008017c3 <devpipe_stat>:
  return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8017c3:	55                   	push   %ebp
  8017c4:	89 e5                	mov    %esp,%ebp
  8017c6:	56                   	push   %esi
  8017c7:	53                   	push   %ebx
  8017c8:	83 ec 10             	sub    $0x10,%esp
  8017cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct Pipe *p = (struct Pipe*)fd2data(fd);
  8017ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d1:	89 04 24             	mov    %eax,(%esp)
  8017d4:	e8 d7 f7 ff ff       	call   800fb0 <fd2data>
  8017d9:	89 c6                	mov    %eax,%esi

  strcpy(stat->st_name, "<pipe>");
  8017db:	c7 44 24 04 40 24 80 	movl   $0x802440,0x4(%esp)
  8017e2:	00 
  8017e3:	89 1c 24             	mov    %ebx,(%esp)
  8017e6:	e8 fc ef ff ff       	call   8007e7 <strcpy>
  stat->st_size = p->p_wpos - p->p_rpos;
  8017eb:	8b 46 04             	mov    0x4(%esi),%eax
  8017ee:	2b 06                	sub    (%esi),%eax
  8017f0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  stat->st_isdir = 0;
  8017f6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017fd:	00 00 00 
  stat->st_dev = &devpipe;
  801800:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801807:	30 80 00 
  return 0;
}
  80180a:	b8 00 00 00 00       	mov    $0x0,%eax
  80180f:	83 c4 10             	add    $0x10,%esp
  801812:	5b                   	pop    %ebx
  801813:	5e                   	pop    %esi
  801814:	5d                   	pop    %ebp
  801815:	c3                   	ret    

00801816 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801816:	55                   	push   %ebp
  801817:	89 e5                	mov    %esp,%ebp
  801819:	53                   	push   %ebx
  80181a:	83 ec 14             	sub    $0x14,%esp
  80181d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  (void)sys_page_unmap(0, fd);
  801820:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801824:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80182b:	e8 7a f4 ff ff       	call   800caa <sys_page_unmap>
  return sys_page_unmap(0, fd2data(fd));
  801830:	89 1c 24             	mov    %ebx,(%esp)
  801833:	e8 78 f7 ff ff       	call   800fb0 <fd2data>
  801838:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801843:	e8 62 f4 ff ff       	call   800caa <sys_page_unmap>
}
  801848:	83 c4 14             	add    $0x14,%esp
  80184b:	5b                   	pop    %ebx
  80184c:	5d                   	pop    %ebp
  80184d:	c3                   	ret    

0080184e <_pipeisclosed>:
  return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	57                   	push   %edi
  801852:	56                   	push   %esi
  801853:	53                   	push   %ebx
  801854:	83 ec 2c             	sub    $0x2c,%esp
  801857:	89 c6                	mov    %eax,%esi
  801859:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  int n, nn, ret;

  while (1) {
    n = thisenv->env_runs;
  80185c:	a1 04 40 80 00       	mov    0x804004,%eax
  801861:	8b 58 58             	mov    0x58(%eax),%ebx
    ret = pageref(fd) == pageref(p);
  801864:	89 34 24             	mov    %esi,(%esp)
  801867:	e8 e0 04 00 00       	call   801d4c <pageref>
  80186c:	89 c7                	mov    %eax,%edi
  80186e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801871:	89 04 24             	mov    %eax,(%esp)
  801874:	e8 d3 04 00 00       	call   801d4c <pageref>
  801879:	39 c7                	cmp    %eax,%edi
  80187b:	0f 94 c2             	sete   %dl
  80187e:	0f b6 c2             	movzbl %dl,%eax
    nn = thisenv->env_runs;
  801881:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801887:	8b 79 58             	mov    0x58(%ecx),%edi
    if (n == nn)
  80188a:	39 fb                	cmp    %edi,%ebx
  80188c:	74 21                	je     8018af <_pipeisclosed+0x61>
      return ret;
    if (n != nn && ret == 1)
  80188e:	84 d2                	test   %dl,%dl
  801890:	74 ca                	je     80185c <_pipeisclosed+0xe>
      cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801892:	8b 51 58             	mov    0x58(%ecx),%edx
  801895:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801899:	89 54 24 08          	mov    %edx,0x8(%esp)
  80189d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018a1:	c7 04 24 47 24 80 00 	movl   $0x802447,(%esp)
  8018a8:	e8 19 e9 ff ff       	call   8001c6 <cprintf>
  8018ad:	eb ad                	jmp    80185c <_pipeisclosed+0xe>
  }
}
  8018af:	83 c4 2c             	add    $0x2c,%esp
  8018b2:	5b                   	pop    %ebx
  8018b3:	5e                   	pop    %esi
  8018b4:	5f                   	pop    %edi
  8018b5:	5d                   	pop    %ebp
  8018b6:	c3                   	ret    

008018b7 <devpipe_write>:
  return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018b7:	55                   	push   %ebp
  8018b8:	89 e5                	mov    %esp,%ebp
  8018ba:	57                   	push   %edi
  8018bb:	56                   	push   %esi
  8018bc:	53                   	push   %ebx
  8018bd:	83 ec 1c             	sub    $0x1c,%esp
  8018c0:	8b 75 08             	mov    0x8(%ebp),%esi
  const uint8_t *buf;
  size_t i;
  struct Pipe *p;

  p = (struct Pipe*)fd2data(fd);
  8018c3:	89 34 24             	mov    %esi,(%esp)
  8018c6:	e8 e5 f6 ff ff       	call   800fb0 <fd2data>
  8018cb:	89 c3                	mov    %eax,%ebx
  if (debug)
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  8018cd:	bf 00 00 00 00       	mov    $0x0,%edi
  8018d2:	eb 45                	jmp    801919 <devpipe_write+0x62>
    while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
      // pipe is full
      // if all the readers are gone
      // (it's only writers like us now),
      // note eof
      if (_pipeisclosed(fd, p))
  8018d4:	89 da                	mov    %ebx,%edx
  8018d6:	89 f0                	mov    %esi,%eax
  8018d8:	e8 71 ff ff ff       	call   80184e <_pipeisclosed>
  8018dd:	85 c0                	test   %eax,%eax
  8018df:	75 41                	jne    801922 <devpipe_write+0x6b>
        return 0;
      // yield and see what happens
      if (debug)
        cprintf("devpipe_write yield\n");
      sys_yield();
  8018e1:	e8 fe f2 ff ff       	call   800be4 <sys_yield>
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
    while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8018e6:	8b 43 04             	mov    0x4(%ebx),%eax
  8018e9:	8b 0b                	mov    (%ebx),%ecx
  8018eb:	8d 51 20             	lea    0x20(%ecx),%edx
  8018ee:	39 d0                	cmp    %edx,%eax
  8018f0:	73 e2                	jae    8018d4 <devpipe_write+0x1d>
        cprintf("devpipe_write yield\n");
      sys_yield();
    }
    // there's room for a byte.  store it.
    // wait to increment wpos until the byte is stored!
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8018f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018f5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8018f9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8018fc:	99                   	cltd   
  8018fd:	c1 ea 1b             	shr    $0x1b,%edx
  801900:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801903:	83 e1 1f             	and    $0x1f,%ecx
  801906:	29 d1                	sub    %edx,%ecx
  801908:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  80190c:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
    p->p_wpos++;
  801910:	83 c0 01             	add    $0x1,%eax
  801913:	89 43 04             	mov    %eax,0x4(%ebx)
  if (debug)
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  801916:	83 c7 01             	add    $0x1,%edi
  801919:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80191c:	75 c8                	jne    8018e6 <devpipe_write+0x2f>
    // wait to increment wpos until the byte is stored!
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
    p->p_wpos++;
  }

  return i;
  80191e:	89 f8                	mov    %edi,%eax
  801920:	eb 05                	jmp    801927 <devpipe_write+0x70>
      // pipe is full
      // if all the readers are gone
      // (it's only writers like us now),
      // note eof
      if (_pipeisclosed(fd, p))
        return 0;
  801922:	b8 00 00 00 00       	mov    $0x0,%eax
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
    p->p_wpos++;
  }

  return i;
}
  801927:	83 c4 1c             	add    $0x1c,%esp
  80192a:	5b                   	pop    %ebx
  80192b:	5e                   	pop    %esi
  80192c:	5f                   	pop    %edi
  80192d:	5d                   	pop    %ebp
  80192e:	c3                   	ret    

0080192f <devpipe_read>:
  return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80192f:	55                   	push   %ebp
  801930:	89 e5                	mov    %esp,%ebp
  801932:	57                   	push   %edi
  801933:	56                   	push   %esi
  801934:	53                   	push   %ebx
  801935:	83 ec 1c             	sub    $0x1c,%esp
  801938:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint8_t *buf;
  size_t i;
  struct Pipe *p;

  p = (struct Pipe*)fd2data(fd);
  80193b:	89 3c 24             	mov    %edi,(%esp)
  80193e:	e8 6d f6 ff ff       	call   800fb0 <fd2data>
  801943:	89 c3                	mov    %eax,%ebx
  if (debug)
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  801945:	be 00 00 00 00       	mov    $0x0,%esi
  80194a:	eb 3d                	jmp    801989 <devpipe_read+0x5a>
    while (p->p_rpos == p->p_wpos) {
      // pipe is empty
      // if we got any data, return it
      if (i > 0)
  80194c:	85 f6                	test   %esi,%esi
  80194e:	74 04                	je     801954 <devpipe_read+0x25>
        return i;
  801950:	89 f0                	mov    %esi,%eax
  801952:	eb 43                	jmp    801997 <devpipe_read+0x68>
      // if all the writers are gone, note eof
      if (_pipeisclosed(fd, p))
  801954:	89 da                	mov    %ebx,%edx
  801956:	89 f8                	mov    %edi,%eax
  801958:	e8 f1 fe ff ff       	call   80184e <_pipeisclosed>
  80195d:	85 c0                	test   %eax,%eax
  80195f:	75 31                	jne    801992 <devpipe_read+0x63>
        return 0;
      // yield and see what happens
      if (debug)
        cprintf("devpipe_read yield\n");
      sys_yield();
  801961:	e8 7e f2 ff ff       	call   800be4 <sys_yield>
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
    while (p->p_rpos == p->p_wpos) {
  801966:	8b 03                	mov    (%ebx),%eax
  801968:	3b 43 04             	cmp    0x4(%ebx),%eax
  80196b:	74 df                	je     80194c <devpipe_read+0x1d>
        cprintf("devpipe_read yield\n");
      sys_yield();
    }
    // there's a byte.  take it.
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80196d:	99                   	cltd   
  80196e:	c1 ea 1b             	shr    $0x1b,%edx
  801971:	01 d0                	add    %edx,%eax
  801973:	83 e0 1f             	and    $0x1f,%eax
  801976:	29 d0                	sub    %edx,%eax
  801978:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80197d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801980:	88 04 31             	mov    %al,(%ecx,%esi,1)
    p->p_rpos++;
  801983:	83 03 01             	addl   $0x1,(%ebx)
  if (debug)
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  801986:	83 c6 01             	add    $0x1,%esi
  801989:	3b 75 10             	cmp    0x10(%ebp),%esi
  80198c:	75 d8                	jne    801966 <devpipe_read+0x37>
    // there's a byte.  take it.
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
    p->p_rpos++;
  }
  return i;
  80198e:	89 f0                	mov    %esi,%eax
  801990:	eb 05                	jmp    801997 <devpipe_read+0x68>
      // if we got any data, return it
      if (i > 0)
        return i;
      // if all the writers are gone, note eof
      if (_pipeisclosed(fd, p))
        return 0;
  801992:	b8 00 00 00 00       	mov    $0x0,%eax
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
    p->p_rpos++;
  }
  return i;
}
  801997:	83 c4 1c             	add    $0x1c,%esp
  80199a:	5b                   	pop    %ebx
  80199b:	5e                   	pop    %esi
  80199c:	5f                   	pop    %edi
  80199d:	5d                   	pop    %ebp
  80199e:	c3                   	ret    

0080199f <pipe>:
  uint8_t p_buf[PIPEBUFSIZ];    // data buffer
};

int
pipe(int pfd[2])
{
  80199f:	55                   	push   %ebp
  8019a0:	89 e5                	mov    %esp,%ebp
  8019a2:	56                   	push   %esi
  8019a3:	53                   	push   %ebx
  8019a4:	83 ec 30             	sub    $0x30,%esp
  int r;
  struct Fd *fd0, *fd1;
  void *va;

  // allocate the file descriptor table entries
  if ((r = fd_alloc(&fd0)) < 0
  8019a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019aa:	89 04 24             	mov    %eax,(%esp)
  8019ad:	e8 15 f6 ff ff       	call   800fc7 <fd_alloc>
  8019b2:	89 c2                	mov    %eax,%edx
  8019b4:	85 d2                	test   %edx,%edx
  8019b6:	0f 88 4d 01 00 00    	js     801b09 <pipe+0x16a>
      || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019bc:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8019c3:	00 
  8019c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019d2:	e8 2c f2 ff ff       	call   800c03 <sys_page_alloc>
  8019d7:	89 c2                	mov    %eax,%edx
  8019d9:	85 d2                	test   %edx,%edx
  8019db:	0f 88 28 01 00 00    	js     801b09 <pipe+0x16a>
    goto err;

  if ((r = fd_alloc(&fd1)) < 0
  8019e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019e4:	89 04 24             	mov    %eax,(%esp)
  8019e7:	e8 db f5 ff ff       	call   800fc7 <fd_alloc>
  8019ec:	89 c3                	mov    %eax,%ebx
  8019ee:	85 c0                	test   %eax,%eax
  8019f0:	0f 88 fe 00 00 00    	js     801af4 <pipe+0x155>
      || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019f6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8019fd:	00 
  8019fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a01:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a0c:	e8 f2 f1 ff ff       	call   800c03 <sys_page_alloc>
  801a11:	89 c3                	mov    %eax,%ebx
  801a13:	85 c0                	test   %eax,%eax
  801a15:	0f 88 d9 00 00 00    	js     801af4 <pipe+0x155>
    goto err1;

  // allocate the pipe structure as first data page in both
  va = fd2data(fd0);
  801a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a1e:	89 04 24             	mov    %eax,(%esp)
  801a21:	e8 8a f5 ff ff       	call   800fb0 <fd2data>
  801a26:	89 c6                	mov    %eax,%esi
  if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a28:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a2f:	00 
  801a30:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a34:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a3b:	e8 c3 f1 ff ff       	call   800c03 <sys_page_alloc>
  801a40:	89 c3                	mov    %eax,%ebx
  801a42:	85 c0                	test   %eax,%eax
  801a44:	0f 88 97 00 00 00    	js     801ae1 <pipe+0x142>
    goto err2;
  if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a4d:	89 04 24             	mov    %eax,(%esp)
  801a50:	e8 5b f5 ff ff       	call   800fb0 <fd2data>
  801a55:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801a5c:	00 
  801a5d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a61:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a68:	00 
  801a69:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a6d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a74:	e8 de f1 ff ff       	call   800c57 <sys_page_map>
  801a79:	89 c3                	mov    %eax,%ebx
  801a7b:	85 c0                	test   %eax,%eax
  801a7d:	78 52                	js     801ad1 <pipe+0x132>
    goto err3;

  // set up fd structures
  fd0->fd_dev_id = devpipe.dev_id;
  801a7f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a88:	89 10                	mov    %edx,(%eax)
  fd0->fd_omode = O_RDONLY;
  801a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a8d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

  fd1->fd_dev_id = devpipe.dev_id;
  801a94:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a9d:	89 10                	mov    %edx,(%eax)
  fd1->fd_omode = O_WRONLY;
  801a9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aa2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

  if (debug)
    cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

  pfd[0] = fd2num(fd0);
  801aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aac:	89 04 24             	mov    %eax,(%esp)
  801aaf:	e8 ec f4 ff ff       	call   800fa0 <fd2num>
  801ab4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ab7:	89 01                	mov    %eax,(%ecx)
  pfd[1] = fd2num(fd1);
  801ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801abc:	89 04 24             	mov    %eax,(%esp)
  801abf:	e8 dc f4 ff ff       	call   800fa0 <fd2num>
  801ac4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ac7:	89 41 04             	mov    %eax,0x4(%ecx)
  return 0;
  801aca:	b8 00 00 00 00       	mov    $0x0,%eax
  801acf:	eb 38                	jmp    801b09 <pipe+0x16a>

err3:
  sys_page_unmap(0, va);
  801ad1:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ad5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801adc:	e8 c9 f1 ff ff       	call   800caa <sys_page_unmap>
err2:
  sys_page_unmap(0, fd1);
  801ae1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ae4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aef:	e8 b6 f1 ff ff       	call   800caa <sys_page_unmap>
err1:
  sys_page_unmap(0, fd0);
  801af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801afb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b02:	e8 a3 f1 ff ff       	call   800caa <sys_page_unmap>
  801b07:	89 d8                	mov    %ebx,%eax
err:
  return r;
}
  801b09:	83 c4 30             	add    $0x30,%esp
  801b0c:	5b                   	pop    %ebx
  801b0d:	5e                   	pop    %esi
  801b0e:	5d                   	pop    %ebp
  801b0f:	c3                   	ret    

00801b10 <pipeisclosed>:
  }
}

int
pipeisclosed(int fdnum)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	83 ec 28             	sub    $0x28,%esp
  struct Fd *fd;
  struct Pipe *p;
  int r;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b16:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b19:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b20:	89 04 24             	mov    %eax,(%esp)
  801b23:	e8 ee f4 ff ff       	call   801016 <fd_lookup>
  801b28:	89 c2                	mov    %eax,%edx
  801b2a:	85 d2                	test   %edx,%edx
  801b2c:	78 15                	js     801b43 <pipeisclosed+0x33>
    return r;
  p = (struct Pipe*)fd2data(fd);
  801b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b31:	89 04 24             	mov    %eax,(%esp)
  801b34:	e8 77 f4 ff ff       	call   800fb0 <fd2data>
  return _pipeisclosed(fd, p);
  801b39:	89 c2                	mov    %eax,%edx
  801b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b3e:	e8 0b fd ff ff       	call   80184e <_pipeisclosed>
}
  801b43:	c9                   	leave  
  801b44:	c3                   	ret    
  801b45:	66 90                	xchg   %ax,%ax
  801b47:	66 90                	xchg   %ax,%ax
  801b49:	66 90                	xchg   %ax,%ax
  801b4b:	66 90                	xchg   %ax,%ax
  801b4d:	66 90                	xchg   %ax,%ax
  801b4f:	90                   	nop

00801b50 <devcons_close>:
  return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  USED(fd);

  return 0;
}
  801b53:	b8 00 00 00 00       	mov    $0x0,%eax
  801b58:	5d                   	pop    %ebp
  801b59:	c3                   	ret    

00801b5a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b5a:	55                   	push   %ebp
  801b5b:	89 e5                	mov    %esp,%ebp
  801b5d:	83 ec 18             	sub    $0x18,%esp
  strcpy(stat->st_name, "<cons>");
  801b60:	c7 44 24 04 5f 24 80 	movl   $0x80245f,0x4(%esp)
  801b67:	00 
  801b68:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b6b:	89 04 24             	mov    %eax,(%esp)
  801b6e:	e8 74 ec ff ff       	call   8007e7 <strcpy>
  return 0;
}
  801b73:	b8 00 00 00 00       	mov    $0x0,%eax
  801b78:	c9                   	leave  
  801b79:	c3                   	ret    

00801b7a <devcons_write>:
  return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	57                   	push   %edi
  801b7e:	56                   	push   %esi
  801b7f:	53                   	push   %ebx
  801b80:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  801b86:	bb 00 00 00 00       	mov    $0x0,%ebx
    m = n - tot;
    if (m > sizeof(buf) - 1)
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
  801b8b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  801b91:	eb 31                	jmp    801bc4 <devcons_write+0x4a>
    m = n - tot;
  801b93:	8b 75 10             	mov    0x10(%ebp),%esi
  801b96:	29 de                	sub    %ebx,%esi
    if (m > sizeof(buf) - 1)
  801b98:	83 fe 7f             	cmp    $0x7f,%esi
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
    m = n - tot;
  801b9b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ba0:	0f 47 f2             	cmova  %edx,%esi
    if (m > sizeof(buf) - 1)
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
  801ba3:	89 74 24 08          	mov    %esi,0x8(%esp)
  801ba7:	03 45 0c             	add    0xc(%ebp),%eax
  801baa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bae:	89 3c 24             	mov    %edi,(%esp)
  801bb1:	e8 ce ed ff ff       	call   800984 <memmove>
    sys_cputs(buf, m);
  801bb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bba:	89 3c 24             	mov    %edi,(%esp)
  801bbd:	e8 74 ef ff ff       	call   800b36 <sys_cputs>
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  801bc2:	01 f3                	add    %esi,%ebx
  801bc4:	89 d8                	mov    %ebx,%eax
  801bc6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bc9:	72 c8                	jb     801b93 <devcons_write+0x19>
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
    sys_cputs(buf, m);
  }
  return tot;
}
  801bcb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801bd1:	5b                   	pop    %ebx
  801bd2:	5e                   	pop    %esi
  801bd3:	5f                   	pop    %edi
  801bd4:	5d                   	pop    %ebp
  801bd5:	c3                   	ret    

00801bd6 <devcons_read>:
  return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bd6:	55                   	push   %ebp
  801bd7:	89 e5                	mov    %esp,%ebp
  801bd9:	83 ec 08             	sub    $0x8,%esp
  int c;

  if (n == 0)
    return 0;
  801bdc:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  int c;

  if (n == 0)
  801be1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801be5:	75 07                	jne    801bee <devcons_read+0x18>
  801be7:	eb 2a                	jmp    801c13 <devcons_read+0x3d>
    return 0;

  while ((c = sys_cgetc()) == 0)
    sys_yield();
  801be9:	e8 f6 ef ff ff       	call   800be4 <sys_yield>
  int c;

  if (n == 0)
    return 0;

  while ((c = sys_cgetc()) == 0)
  801bee:	66 90                	xchg   %ax,%ax
  801bf0:	e8 5f ef ff ff       	call   800b54 <sys_cgetc>
  801bf5:	85 c0                	test   %eax,%eax
  801bf7:	74 f0                	je     801be9 <devcons_read+0x13>
    sys_yield();
  if (c < 0)
  801bf9:	85 c0                	test   %eax,%eax
  801bfb:	78 16                	js     801c13 <devcons_read+0x3d>
    return c;
  if (c == 0x04)        // ctl-d is eof
  801bfd:	83 f8 04             	cmp    $0x4,%eax
  801c00:	74 0c                	je     801c0e <devcons_read+0x38>
    return 0;
  *(char*)vbuf = c;
  801c02:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c05:	88 02                	mov    %al,(%edx)
  return 1;
  801c07:	b8 01 00 00 00       	mov    $0x1,%eax
  801c0c:	eb 05                	jmp    801c13 <devcons_read+0x3d>
  while ((c = sys_cgetc()) == 0)
    sys_yield();
  if (c < 0)
    return c;
  if (c == 0x04)        // ctl-d is eof
    return 0;
  801c0e:	b8 00 00 00 00       	mov    $0x0,%eax
  *(char*)vbuf = c;
  return 1;
}
  801c13:	c9                   	leave  
  801c14:	c3                   	ret    

00801c15 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c15:	55                   	push   %ebp
  801c16:	89 e5                	mov    %esp,%ebp
  801c18:	83 ec 28             	sub    $0x28,%esp
  char c = ch;
  801c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1e:	88 45 f7             	mov    %al,-0x9(%ebp)

  // Unlike standard Unix's putchar,
  // the cputchar function _always_ outputs to the system console.
  sys_cputs(&c, 1);
  801c21:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801c28:	00 
  801c29:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c2c:	89 04 24             	mov    %eax,(%esp)
  801c2f:	e8 02 ef ff ff       	call   800b36 <sys_cputs>
}
  801c34:	c9                   	leave  
  801c35:	c3                   	ret    

00801c36 <getchar>:

int
getchar(void)
{
  801c36:	55                   	push   %ebp
  801c37:	89 e5                	mov    %esp,%ebp
  801c39:	83 ec 28             	sub    $0x28,%esp
  int r;

  // JOS does, however, support standard _input_ redirection,
  // allowing the user to redirect script files to the shell and such.
  // getchar() reads a character from file descriptor 0.
  r = read(0, &c, 1);
  801c3c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801c43:	00 
  801c44:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c52:	e8 4e f6 ff ff       	call   8012a5 <read>
  if (r < 0)
  801c57:	85 c0                	test   %eax,%eax
  801c59:	78 0f                	js     801c6a <getchar+0x34>
    return r;
  if (r < 1)
  801c5b:	85 c0                	test   %eax,%eax
  801c5d:	7e 06                	jle    801c65 <getchar+0x2f>
    return -E_EOF;
  return c;
  801c5f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c63:	eb 05                	jmp    801c6a <getchar+0x34>
  // getchar() reads a character from file descriptor 0.
  r = read(0, &c, 1);
  if (r < 0)
    return r;
  if (r < 1)
    return -E_EOF;
  801c65:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  /* int r;
  // sys_cgetc does not block, but getchar should.
  while ((r = sys_cgetc()) == 0)
    sys_yield();
  return r; */
}
  801c6a:	c9                   	leave  
  801c6b:	c3                   	ret    

00801c6c <iscons>:
  .dev_stat   =     devcons_stat
};

int
iscons(int fdnum)
{
  801c6c:	55                   	push   %ebp
  801c6d:	89 e5                	mov    %esp,%ebp
  801c6f:	83 ec 28             	sub    $0x28,%esp
  int r;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c75:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c79:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7c:	89 04 24             	mov    %eax,(%esp)
  801c7f:	e8 92 f3 ff ff       	call   801016 <fd_lookup>
  801c84:	85 c0                	test   %eax,%eax
  801c86:	78 11                	js     801c99 <iscons+0x2d>
    return r;
  return fd->fd_dev_id == devcons.dev_id;
  801c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c8b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c91:	39 10                	cmp    %edx,(%eax)
  801c93:	0f 94 c0             	sete   %al
  801c96:	0f b6 c0             	movzbl %al,%eax
}
  801c99:	c9                   	leave  
  801c9a:	c3                   	ret    

00801c9b <opencons>:

int
opencons(void)
{
  801c9b:	55                   	push   %ebp
  801c9c:	89 e5                	mov    %esp,%ebp
  801c9e:	83 ec 28             	sub    $0x28,%esp
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
  801ca1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ca4:	89 04 24             	mov    %eax,(%esp)
  801ca7:	e8 1b f3 ff ff       	call   800fc7 <fd_alloc>
    return r;
  801cac:	89 c2                	mov    %eax,%edx
opencons(void)
{
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
  801cae:	85 c0                	test   %eax,%eax
  801cb0:	78 40                	js     801cf2 <opencons+0x57>
    return r;
  if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cb2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801cb9:	00 
  801cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cbd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cc8:	e8 36 ef ff ff       	call   800c03 <sys_page_alloc>
    return r;
  801ccd:	89 c2                	mov    %eax,%edx
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
    return r;
  if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ccf:	85 c0                	test   %eax,%eax
  801cd1:	78 1f                	js     801cf2 <opencons+0x57>
    return r;
  fd->fd_dev_id = devcons.dev_id;
  801cd3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cdc:	89 10                	mov    %edx,(%eax)
  fd->fd_omode = O_RDWR;
  801cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
  return fd2num(fd);
  801ce8:	89 04 24             	mov    %eax,(%esp)
  801ceb:	e8 b0 f2 ff ff       	call   800fa0 <fd2num>
  801cf0:	89 c2                	mov    %eax,%edx
}
  801cf2:	89 d0                	mov    %edx,%eax
  801cf4:	c9                   	leave  
  801cf5:	c3                   	ret    

00801cf6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801cf6:	55                   	push   %ebp
  801cf7:	89 e5                	mov    %esp,%ebp
  801cf9:	56                   	push   %esi
  801cfa:	53                   	push   %ebx
  801cfb:	83 ec 20             	sub    $0x20,%esp
  va_list ap;

  va_start(ap, fmt);
  801cfe:	8d 5d 14             	lea    0x14(%ebp),%ebx

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  801d01:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d07:	e8 b9 ee ff ff       	call   800bc5 <sys_getenvid>
  801d0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d0f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801d13:	8b 55 08             	mov    0x8(%ebp),%edx
  801d16:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d1a:	89 74 24 08          	mov    %esi,0x8(%esp)
  801d1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d22:	c7 04 24 6c 24 80 00 	movl   $0x80246c,(%esp)
  801d29:	e8 98 e4 ff ff       	call   8001c6 <cprintf>
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  801d2e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d32:	8b 45 10             	mov    0x10(%ebp),%eax
  801d35:	89 04 24             	mov    %eax,(%esp)
  801d38:	e8 28 e4 ff ff       	call   800165 <vcprintf>
  cprintf("\n");
  801d3d:	c7 04 24 58 24 80 00 	movl   $0x802458,(%esp)
  801d44:	e8 7d e4 ff ff       	call   8001c6 <cprintf>

  // Cause a breakpoint exception
  while (1)
    asm volatile ("int3");
  801d49:	cc                   	int3   
  801d4a:	eb fd                	jmp    801d49 <_panic+0x53>

00801d4c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d4c:	55                   	push   %ebp
  801d4d:	89 e5                	mov    %esp,%ebp
  801d4f:	8b 55 08             	mov    0x8(%ebp),%edx
  pte_t pte;

  if (!(uvpd[PDX(v)] & PTE_P))
  801d52:	89 d0                	mov    %edx,%eax
  801d54:	c1 e8 16             	shr    $0x16,%eax
  801d57:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
    return 0;
  801d5e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
  pte_t pte;

  if (!(uvpd[PDX(v)] & PTE_P))
  801d63:	f6 c1 01             	test   $0x1,%cl
  801d66:	74 1d                	je     801d85 <pageref+0x39>
    return 0;
  pte = uvpt[PGNUM(v)];
  801d68:	c1 ea 0c             	shr    $0xc,%edx
  801d6b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  if (!(pte & PTE_P))
  801d72:	f6 c2 01             	test   $0x1,%dl
  801d75:	74 0e                	je     801d85 <pageref+0x39>
    return 0;
  return pages[PGNUM(pte)].pp_ref;
  801d77:	c1 ea 0c             	shr    $0xc,%edx
  801d7a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d81:	ef 
  801d82:	0f b7 c0             	movzwl %ax,%eax
}
  801d85:	5d                   	pop    %ebp
  801d86:	c3                   	ret    
  801d87:	66 90                	xchg   %ax,%ax
  801d89:	66 90                	xchg   %ax,%ax
  801d8b:	66 90                	xchg   %ax,%ax
  801d8d:	66 90                	xchg   %ax,%ax
  801d8f:	90                   	nop

00801d90 <__udivdi3>:
  801d90:	55                   	push   %ebp
  801d91:	57                   	push   %edi
  801d92:	56                   	push   %esi
  801d93:	83 ec 0c             	sub    $0xc,%esp
  801d96:	8b 44 24 28          	mov    0x28(%esp),%eax
  801d9a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801d9e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801da2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801da6:	85 c0                	test   %eax,%eax
  801da8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801dac:	89 ea                	mov    %ebp,%edx
  801dae:	89 0c 24             	mov    %ecx,(%esp)
  801db1:	75 2d                	jne    801de0 <__udivdi3+0x50>
  801db3:	39 e9                	cmp    %ebp,%ecx
  801db5:	77 61                	ja     801e18 <__udivdi3+0x88>
  801db7:	85 c9                	test   %ecx,%ecx
  801db9:	89 ce                	mov    %ecx,%esi
  801dbb:	75 0b                	jne    801dc8 <__udivdi3+0x38>
  801dbd:	b8 01 00 00 00       	mov    $0x1,%eax
  801dc2:	31 d2                	xor    %edx,%edx
  801dc4:	f7 f1                	div    %ecx
  801dc6:	89 c6                	mov    %eax,%esi
  801dc8:	31 d2                	xor    %edx,%edx
  801dca:	89 e8                	mov    %ebp,%eax
  801dcc:	f7 f6                	div    %esi
  801dce:	89 c5                	mov    %eax,%ebp
  801dd0:	89 f8                	mov    %edi,%eax
  801dd2:	f7 f6                	div    %esi
  801dd4:	89 ea                	mov    %ebp,%edx
  801dd6:	83 c4 0c             	add    $0xc,%esp
  801dd9:	5e                   	pop    %esi
  801dda:	5f                   	pop    %edi
  801ddb:	5d                   	pop    %ebp
  801ddc:	c3                   	ret    
  801ddd:	8d 76 00             	lea    0x0(%esi),%esi
  801de0:	39 e8                	cmp    %ebp,%eax
  801de2:	77 24                	ja     801e08 <__udivdi3+0x78>
  801de4:	0f bd e8             	bsr    %eax,%ebp
  801de7:	83 f5 1f             	xor    $0x1f,%ebp
  801dea:	75 3c                	jne    801e28 <__udivdi3+0x98>
  801dec:	8b 74 24 04          	mov    0x4(%esp),%esi
  801df0:	39 34 24             	cmp    %esi,(%esp)
  801df3:	0f 86 9f 00 00 00    	jbe    801e98 <__udivdi3+0x108>
  801df9:	39 d0                	cmp    %edx,%eax
  801dfb:	0f 82 97 00 00 00    	jb     801e98 <__udivdi3+0x108>
  801e01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e08:	31 d2                	xor    %edx,%edx
  801e0a:	31 c0                	xor    %eax,%eax
  801e0c:	83 c4 0c             	add    $0xc,%esp
  801e0f:	5e                   	pop    %esi
  801e10:	5f                   	pop    %edi
  801e11:	5d                   	pop    %ebp
  801e12:	c3                   	ret    
  801e13:	90                   	nop
  801e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e18:	89 f8                	mov    %edi,%eax
  801e1a:	f7 f1                	div    %ecx
  801e1c:	31 d2                	xor    %edx,%edx
  801e1e:	83 c4 0c             	add    $0xc,%esp
  801e21:	5e                   	pop    %esi
  801e22:	5f                   	pop    %edi
  801e23:	5d                   	pop    %ebp
  801e24:	c3                   	ret    
  801e25:	8d 76 00             	lea    0x0(%esi),%esi
  801e28:	89 e9                	mov    %ebp,%ecx
  801e2a:	8b 3c 24             	mov    (%esp),%edi
  801e2d:	d3 e0                	shl    %cl,%eax
  801e2f:	89 c6                	mov    %eax,%esi
  801e31:	b8 20 00 00 00       	mov    $0x20,%eax
  801e36:	29 e8                	sub    %ebp,%eax
  801e38:	89 c1                	mov    %eax,%ecx
  801e3a:	d3 ef                	shr    %cl,%edi
  801e3c:	89 e9                	mov    %ebp,%ecx
  801e3e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801e42:	8b 3c 24             	mov    (%esp),%edi
  801e45:	09 74 24 08          	or     %esi,0x8(%esp)
  801e49:	89 d6                	mov    %edx,%esi
  801e4b:	d3 e7                	shl    %cl,%edi
  801e4d:	89 c1                	mov    %eax,%ecx
  801e4f:	89 3c 24             	mov    %edi,(%esp)
  801e52:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801e56:	d3 ee                	shr    %cl,%esi
  801e58:	89 e9                	mov    %ebp,%ecx
  801e5a:	d3 e2                	shl    %cl,%edx
  801e5c:	89 c1                	mov    %eax,%ecx
  801e5e:	d3 ef                	shr    %cl,%edi
  801e60:	09 d7                	or     %edx,%edi
  801e62:	89 f2                	mov    %esi,%edx
  801e64:	89 f8                	mov    %edi,%eax
  801e66:	f7 74 24 08          	divl   0x8(%esp)
  801e6a:	89 d6                	mov    %edx,%esi
  801e6c:	89 c7                	mov    %eax,%edi
  801e6e:	f7 24 24             	mull   (%esp)
  801e71:	39 d6                	cmp    %edx,%esi
  801e73:	89 14 24             	mov    %edx,(%esp)
  801e76:	72 30                	jb     801ea8 <__udivdi3+0x118>
  801e78:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e7c:	89 e9                	mov    %ebp,%ecx
  801e7e:	d3 e2                	shl    %cl,%edx
  801e80:	39 c2                	cmp    %eax,%edx
  801e82:	73 05                	jae    801e89 <__udivdi3+0xf9>
  801e84:	3b 34 24             	cmp    (%esp),%esi
  801e87:	74 1f                	je     801ea8 <__udivdi3+0x118>
  801e89:	89 f8                	mov    %edi,%eax
  801e8b:	31 d2                	xor    %edx,%edx
  801e8d:	e9 7a ff ff ff       	jmp    801e0c <__udivdi3+0x7c>
  801e92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e98:	31 d2                	xor    %edx,%edx
  801e9a:	b8 01 00 00 00       	mov    $0x1,%eax
  801e9f:	e9 68 ff ff ff       	jmp    801e0c <__udivdi3+0x7c>
  801ea4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ea8:	8d 47 ff             	lea    -0x1(%edi),%eax
  801eab:	31 d2                	xor    %edx,%edx
  801ead:	83 c4 0c             	add    $0xc,%esp
  801eb0:	5e                   	pop    %esi
  801eb1:	5f                   	pop    %edi
  801eb2:	5d                   	pop    %ebp
  801eb3:	c3                   	ret    
  801eb4:	66 90                	xchg   %ax,%ax
  801eb6:	66 90                	xchg   %ax,%ax
  801eb8:	66 90                	xchg   %ax,%ax
  801eba:	66 90                	xchg   %ax,%ax
  801ebc:	66 90                	xchg   %ax,%ax
  801ebe:	66 90                	xchg   %ax,%ax

00801ec0 <__umoddi3>:
  801ec0:	55                   	push   %ebp
  801ec1:	57                   	push   %edi
  801ec2:	56                   	push   %esi
  801ec3:	83 ec 14             	sub    $0x14,%esp
  801ec6:	8b 44 24 28          	mov    0x28(%esp),%eax
  801eca:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801ece:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801ed2:	89 c7                	mov    %eax,%edi
  801ed4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed8:	8b 44 24 30          	mov    0x30(%esp),%eax
  801edc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801ee0:	89 34 24             	mov    %esi,(%esp)
  801ee3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ee7:	85 c0                	test   %eax,%eax
  801ee9:	89 c2                	mov    %eax,%edx
  801eeb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801eef:	75 17                	jne    801f08 <__umoddi3+0x48>
  801ef1:	39 fe                	cmp    %edi,%esi
  801ef3:	76 4b                	jbe    801f40 <__umoddi3+0x80>
  801ef5:	89 c8                	mov    %ecx,%eax
  801ef7:	89 fa                	mov    %edi,%edx
  801ef9:	f7 f6                	div    %esi
  801efb:	89 d0                	mov    %edx,%eax
  801efd:	31 d2                	xor    %edx,%edx
  801eff:	83 c4 14             	add    $0x14,%esp
  801f02:	5e                   	pop    %esi
  801f03:	5f                   	pop    %edi
  801f04:	5d                   	pop    %ebp
  801f05:	c3                   	ret    
  801f06:	66 90                	xchg   %ax,%ax
  801f08:	39 f8                	cmp    %edi,%eax
  801f0a:	77 54                	ja     801f60 <__umoddi3+0xa0>
  801f0c:	0f bd e8             	bsr    %eax,%ebp
  801f0f:	83 f5 1f             	xor    $0x1f,%ebp
  801f12:	75 5c                	jne    801f70 <__umoddi3+0xb0>
  801f14:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801f18:	39 3c 24             	cmp    %edi,(%esp)
  801f1b:	0f 87 e7 00 00 00    	ja     802008 <__umoddi3+0x148>
  801f21:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801f25:	29 f1                	sub    %esi,%ecx
  801f27:	19 c7                	sbb    %eax,%edi
  801f29:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f2d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f31:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f35:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801f39:	83 c4 14             	add    $0x14,%esp
  801f3c:	5e                   	pop    %esi
  801f3d:	5f                   	pop    %edi
  801f3e:	5d                   	pop    %ebp
  801f3f:	c3                   	ret    
  801f40:	85 f6                	test   %esi,%esi
  801f42:	89 f5                	mov    %esi,%ebp
  801f44:	75 0b                	jne    801f51 <__umoddi3+0x91>
  801f46:	b8 01 00 00 00       	mov    $0x1,%eax
  801f4b:	31 d2                	xor    %edx,%edx
  801f4d:	f7 f6                	div    %esi
  801f4f:	89 c5                	mov    %eax,%ebp
  801f51:	8b 44 24 04          	mov    0x4(%esp),%eax
  801f55:	31 d2                	xor    %edx,%edx
  801f57:	f7 f5                	div    %ebp
  801f59:	89 c8                	mov    %ecx,%eax
  801f5b:	f7 f5                	div    %ebp
  801f5d:	eb 9c                	jmp    801efb <__umoddi3+0x3b>
  801f5f:	90                   	nop
  801f60:	89 c8                	mov    %ecx,%eax
  801f62:	89 fa                	mov    %edi,%edx
  801f64:	83 c4 14             	add    $0x14,%esp
  801f67:	5e                   	pop    %esi
  801f68:	5f                   	pop    %edi
  801f69:	5d                   	pop    %ebp
  801f6a:	c3                   	ret    
  801f6b:	90                   	nop
  801f6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f70:	8b 04 24             	mov    (%esp),%eax
  801f73:	be 20 00 00 00       	mov    $0x20,%esi
  801f78:	89 e9                	mov    %ebp,%ecx
  801f7a:	29 ee                	sub    %ebp,%esi
  801f7c:	d3 e2                	shl    %cl,%edx
  801f7e:	89 f1                	mov    %esi,%ecx
  801f80:	d3 e8                	shr    %cl,%eax
  801f82:	89 e9                	mov    %ebp,%ecx
  801f84:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f88:	8b 04 24             	mov    (%esp),%eax
  801f8b:	09 54 24 04          	or     %edx,0x4(%esp)
  801f8f:	89 fa                	mov    %edi,%edx
  801f91:	d3 e0                	shl    %cl,%eax
  801f93:	89 f1                	mov    %esi,%ecx
  801f95:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f99:	8b 44 24 10          	mov    0x10(%esp),%eax
  801f9d:	d3 ea                	shr    %cl,%edx
  801f9f:	89 e9                	mov    %ebp,%ecx
  801fa1:	d3 e7                	shl    %cl,%edi
  801fa3:	89 f1                	mov    %esi,%ecx
  801fa5:	d3 e8                	shr    %cl,%eax
  801fa7:	89 e9                	mov    %ebp,%ecx
  801fa9:	09 f8                	or     %edi,%eax
  801fab:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801faf:	f7 74 24 04          	divl   0x4(%esp)
  801fb3:	d3 e7                	shl    %cl,%edi
  801fb5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801fb9:	89 d7                	mov    %edx,%edi
  801fbb:	f7 64 24 08          	mull   0x8(%esp)
  801fbf:	39 d7                	cmp    %edx,%edi
  801fc1:	89 c1                	mov    %eax,%ecx
  801fc3:	89 14 24             	mov    %edx,(%esp)
  801fc6:	72 2c                	jb     801ff4 <__umoddi3+0x134>
  801fc8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801fcc:	72 22                	jb     801ff0 <__umoddi3+0x130>
  801fce:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801fd2:	29 c8                	sub    %ecx,%eax
  801fd4:	19 d7                	sbb    %edx,%edi
  801fd6:	89 e9                	mov    %ebp,%ecx
  801fd8:	89 fa                	mov    %edi,%edx
  801fda:	d3 e8                	shr    %cl,%eax
  801fdc:	89 f1                	mov    %esi,%ecx
  801fde:	d3 e2                	shl    %cl,%edx
  801fe0:	89 e9                	mov    %ebp,%ecx
  801fe2:	d3 ef                	shr    %cl,%edi
  801fe4:	09 d0                	or     %edx,%eax
  801fe6:	89 fa                	mov    %edi,%edx
  801fe8:	83 c4 14             	add    $0x14,%esp
  801feb:	5e                   	pop    %esi
  801fec:	5f                   	pop    %edi
  801fed:	5d                   	pop    %ebp
  801fee:	c3                   	ret    
  801fef:	90                   	nop
  801ff0:	39 d7                	cmp    %edx,%edi
  801ff2:	75 da                	jne    801fce <__umoddi3+0x10e>
  801ff4:	8b 14 24             	mov    (%esp),%edx
  801ff7:	89 c1                	mov    %eax,%ecx
  801ff9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801ffd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802001:	eb cb                	jmp    801fce <__umoddi3+0x10e>
  802003:	90                   	nop
  802004:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802008:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80200c:	0f 82 0f ff ff ff    	jb     801f21 <__umoddi3+0x61>
  802012:	e9 1a ff ff ff       	jmp    801f31 <__umoddi3+0x71>
