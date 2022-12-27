
obj/user/faultallocbad.debug:     file format elf32-i386


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
  80002c:	e8 af 00 00 00       	call   8000e0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 24             	sub    $0x24,%esp
  int r;
  void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

  cprintf("fault %x\n", addr);
  80003f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800043:	c7 04 24 00 21 80 00 	movl   $0x802100,(%esp)
  80004a:	e8 eb 01 00 00       	call   80023a <cprintf>
  if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800056:	00 
  800057:	89 d8                	mov    %ebx,%eax
  800059:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800062:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800069:	e8 15 0c 00 00       	call   800c83 <sys_page_alloc>
  80006e:	85 c0                	test   %eax,%eax
  800070:	79 24                	jns    800096 <handler+0x63>
                          PTE_P|PTE_U|PTE_W)) < 0)
    panic("allocating at %x in page fault handler: %e", addr, r);
  800072:	89 44 24 10          	mov    %eax,0x10(%esp)
  800076:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007a:	c7 44 24 08 20 21 80 	movl   $0x802120,0x8(%esp)
  800081:	00 
  800082:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800089:	00 
  80008a:	c7 04 24 0a 21 80 00 	movl   $0x80210a,(%esp)
  800091:	e8 ab 00 00 00       	call   800141 <_panic>
  snprintf((char*)addr, 100, "this string was faulted in at %x", addr);
  800096:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009a:	c7 44 24 08 4c 21 80 	movl   $0x80214c,0x8(%esp)
  8000a1:	00 
  8000a2:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000a9:	00 
  8000aa:	89 1c 24             	mov    %ebx,(%esp)
  8000ad:	e8 48 07 00 00       	call   8007fa <snprintf>
}
  8000b2:	83 c4 24             	add    $0x24,%esp
  8000b5:	5b                   	pop    %ebx
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <umain>:

void
umain(int argc, char **argv)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 18             	sub    $0x18,%esp
  set_pgfault_handler(handler);
  8000be:	c7 04 24 33 00 80 00 	movl   $0x800033,(%esp)
  8000c5:	e8 21 0e 00 00       	call   800eeb <set_pgfault_handler>
  sys_cputs((char*)0xDEADBEEF, 4);
  8000ca:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000d1:	00 
  8000d2:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  8000d9:	e8 d8 0a 00 00       	call   800bb6 <sys_cputs>
}
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 10             	sub    $0x10,%esp
  8000e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000eb:	8b 75 0c             	mov    0xc(%ebp),%esi
  // set thisenv to point at our Env structure in envs[].
  // LAB 3: Your code here.
  thisenv = envs + ENVX(sys_getenvid());
  8000ee:	e8 52 0b 00 00       	call   800c45 <sys_getenvid>
  8000f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000fb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800100:	a3 04 40 80 00       	mov    %eax,0x804004

  // save the name of the program so that panic() can use it
  if (argc > 0)
  800105:	85 db                	test   %ebx,%ebx
  800107:	7e 07                	jle    800110 <libmain+0x30>
    binaryname = argv[0];
  800109:	8b 06                	mov    (%esi),%eax
  80010b:	a3 00 30 80 00       	mov    %eax,0x803000

  // call user main routine
  umain(argc, argv);
  800110:	89 74 24 04          	mov    %esi,0x4(%esp)
  800114:	89 1c 24             	mov    %ebx,(%esp)
  800117:	e8 9c ff ff ff       	call   8000b8 <umain>

  // exit gracefully
  exit();
  80011c:	e8 07 00 00 00       	call   800128 <exit>
}
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	5b                   	pop    %ebx
  800125:	5e                   	pop    %esi
  800126:	5d                   	pop    %ebp
  800127:	c3                   	ret    

00800128 <exit>:
#include <inc/lib.h>

void
exit(void)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	83 ec 18             	sub    $0x18,%esp
  close_all();
  80012e:	e8 42 10 00 00       	call   801175 <close_all>
  sys_env_destroy(0);
  800133:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80013a:	e8 b4 0a 00 00       	call   800bf3 <sys_env_destroy>
}
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	56                   	push   %esi
  800145:	53                   	push   %ebx
  800146:	83 ec 20             	sub    $0x20,%esp
  va_list ap;

  va_start(ap, fmt);
  800149:	8d 5d 14             	lea    0x14(%ebp),%ebx

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  80014c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800152:	e8 ee 0a 00 00       	call   800c45 <sys_getenvid>
  800157:	8b 55 0c             	mov    0xc(%ebp),%edx
  80015a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80015e:	8b 55 08             	mov    0x8(%ebp),%edx
  800161:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800165:	89 74 24 08          	mov    %esi,0x8(%esp)
  800169:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016d:	c7 04 24 78 21 80 00 	movl   $0x802178,(%esp)
  800174:	e8 c1 00 00 00       	call   80023a <cprintf>
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  800179:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80017d:	8b 45 10             	mov    0x10(%ebp),%eax
  800180:	89 04 24             	mov    %eax,(%esp)
  800183:	e8 51 00 00 00       	call   8001d9 <vcprintf>
  cprintf("\n");
  800188:	c7 04 24 ec 25 80 00 	movl   $0x8025ec,(%esp)
  80018f:	e8 a6 00 00 00       	call   80023a <cprintf>

  // Cause a breakpoint exception
  while (1)
    asm volatile ("int3");
  800194:	cc                   	int3   
  800195:	eb fd                	jmp    800194 <_panic+0x53>

00800197 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	53                   	push   %ebx
  80019b:	83 ec 14             	sub    $0x14,%esp
  80019e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  b->buf[b->idx++] = ch;
  8001a1:	8b 13                	mov    (%ebx),%edx
  8001a3:	8d 42 01             	lea    0x1(%edx),%eax
  8001a6:	89 03                	mov    %eax,(%ebx)
  8001a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ab:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
  if (b->idx == 256-1) {
  8001af:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b4:	75 19                	jne    8001cf <putch+0x38>
    sys_cputs(b->buf, b->idx);
  8001b6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001bd:	00 
  8001be:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c1:	89 04 24             	mov    %eax,(%esp)
  8001c4:	e8 ed 09 00 00       	call   800bb6 <sys_cputs>
    b->idx = 0;
  8001c9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  }
  b->cnt++;
  8001cf:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d3:	83 c4 14             	add    $0x14,%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5d                   	pop    %ebp
  8001d8:	c3                   	ret    

008001d9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	81 ec 28 01 00 00    	sub    $0x128,%esp
  struct printbuf b;

  b.idx = 0;
  8001e2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e9:	00 00 00 
  b.cnt = 0;
  8001ec:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f3:	00 00 00 
  vprintfmt((void*)putch, &b, fmt, ap);
  8001f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800200:	89 44 24 08          	mov    %eax,0x8(%esp)
  800204:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020e:	c7 04 24 97 01 80 00 	movl   $0x800197,(%esp)
  800215:	e8 b4 01 00 00       	call   8003ce <vprintfmt>
  sys_cputs(b.buf, b.idx);
  80021a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800220:	89 44 24 04          	mov    %eax,0x4(%esp)
  800224:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80022a:	89 04 24             	mov    %eax,(%esp)
  80022d:	e8 84 09 00 00       	call   800bb6 <sys_cputs>

  return b.cnt;
}
  800232:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800240:	8d 45 0c             	lea    0xc(%ebp),%eax
  cnt = vcprintf(fmt, ap);
  800243:	89 44 24 04          	mov    %eax,0x4(%esp)
  800247:	8b 45 08             	mov    0x8(%ebp),%eax
  80024a:	89 04 24             	mov    %eax,(%esp)
  80024d:	e8 87 ff ff ff       	call   8001d9 <vcprintf>
  va_end(ap);

  return cnt;
}
  800252:	c9                   	leave  
  800253:	c3                   	ret    
  800254:	66 90                	xchg   %ax,%ax
  800256:	66 90                	xchg   %ax,%ax
  800258:	66 90                	xchg   %ax,%ax
  80025a:	66 90                	xchg   %ax,%ax
  80025c:	66 90                	xchg   %ax,%ax
  80025e:	66 90                	xchg   %ax,%ax

00800260 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
         unsigned long long num, unsigned base, int width, int padc)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	57                   	push   %edi
  800264:	56                   	push   %esi
  800265:	53                   	push   %ebx
  800266:	83 ec 3c             	sub    $0x3c,%esp
  800269:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80026c:	89 d7                	mov    %edx,%edi
  80026e:	8b 45 08             	mov    0x8(%ebp),%eax
  800271:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800274:	8b 45 0c             	mov    0xc(%ebp),%eax
  800277:	89 c3                	mov    %eax,%ebx
  800279:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80027c:	8b 45 10             	mov    0x10(%ebp),%eax
  80027f:	8b 75 14             	mov    0x14(%ebp),%esi
  // first recursively print all preceding (more significant) digits
  if (num >= base)
  800282:	b9 00 00 00 00       	mov    $0x0,%ecx
  800287:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80028a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80028d:	39 d9                	cmp    %ebx,%ecx
  80028f:	72 05                	jb     800296 <printnum+0x36>
  800291:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800294:	77 69                	ja     8002ff <printnum+0x9f>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  800296:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800299:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80029d:	83 ee 01             	sub    $0x1,%esi
  8002a0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002ac:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002b0:	89 c3                	mov    %eax,%ebx
  8002b2:	89 d6                	mov    %edx,%esi
  8002b4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002b7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002ba:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002be:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c5:	89 04 24             	mov    %eax,(%esp)
  8002c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cf:	e8 8c 1b 00 00       	call   801e60 <__udivdi3>
  8002d4:	89 d9                	mov    %ebx,%ecx
  8002d6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002da:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002de:	89 04 24             	mov    %eax,(%esp)
  8002e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002e5:	89 fa                	mov    %edi,%edx
  8002e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ea:	e8 71 ff ff ff       	call   800260 <printnum>
  8002ef:	eb 1b                	jmp    80030c <printnum+0xac>
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
      putch(padc, putdat);
  8002f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f5:	8b 45 18             	mov    0x18(%ebp),%eax
  8002f8:	89 04 24             	mov    %eax,(%esp)
  8002fb:	ff d3                	call   *%ebx
  8002fd:	eb 03                	jmp    800302 <printnum+0xa2>
  8002ff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  // first recursively print all preceding (more significant) digits
  if (num >= base)
    printnum(putch, putdat, num / base, base, width - 1, padc);
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
  800302:	83 ee 01             	sub    $0x1,%esi
  800305:	85 f6                	test   %esi,%esi
  800307:	7f e8                	jg     8002f1 <printnum+0x91>
  800309:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
      putch(padc, putdat);
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  80030c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800310:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800314:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800317:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80031a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80031e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800322:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800325:	89 04 24             	mov    %eax,(%esp)
  800328:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80032b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032f:	e8 5c 1c 00 00       	call   801f90 <__umoddi3>
  800334:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800338:	0f be 80 9b 21 80 00 	movsbl 0x80219b(%eax),%eax
  80033f:	89 04 24             	mov    %eax,(%esp)
  800342:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800345:	ff d0                	call   *%eax
}
  800347:	83 c4 3c             	add    $0x3c,%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  if (lflag >= 2)
  800352:	83 fa 01             	cmp    $0x1,%edx
  800355:	7e 0e                	jle    800365 <getuint+0x16>
    return va_arg(*ap, unsigned long long);
  800357:	8b 10                	mov    (%eax),%edx
  800359:	8d 4a 08             	lea    0x8(%edx),%ecx
  80035c:	89 08                	mov    %ecx,(%eax)
  80035e:	8b 02                	mov    (%edx),%eax
  800360:	8b 52 04             	mov    0x4(%edx),%edx
  800363:	eb 22                	jmp    800387 <getuint+0x38>
  else if (lflag)
  800365:	85 d2                	test   %edx,%edx
  800367:	74 10                	je     800379 <getuint+0x2a>
    return va_arg(*ap, unsigned long);
  800369:	8b 10                	mov    (%eax),%edx
  80036b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036e:	89 08                	mov    %ecx,(%eax)
  800370:	8b 02                	mov    (%edx),%eax
  800372:	ba 00 00 00 00       	mov    $0x0,%edx
  800377:	eb 0e                	jmp    800387 <getuint+0x38>
  else
    return va_arg(*ap, unsigned int);
  800379:	8b 10                	mov    (%eax),%edx
  80037b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037e:	89 08                	mov    %ecx,(%eax)
  800380:	8b 02                	mov    (%edx),%eax
  800382:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800387:	5d                   	pop    %ebp
  800388:	c3                   	ret    

00800389 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	8b 45 0c             	mov    0xc(%ebp),%eax
  b->cnt++;
  80038f:	83 40 08 01          	addl   $0x1,0x8(%eax)
  if (b->buf < b->ebuf)
  800393:	8b 10                	mov    (%eax),%edx
  800395:	3b 50 04             	cmp    0x4(%eax),%edx
  800398:	73 0a                	jae    8003a4 <sprintputch+0x1b>
    *b->buf++ = ch;
  80039a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80039d:	89 08                	mov    %ecx,(%eax)
  80039f:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a2:	88 02                	mov    %al,(%edx)
}
  8003a4:	5d                   	pop    %ebp
  8003a5:	c3                   	ret    

008003a6 <printfmt>:
  }
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
  8003a9:	83 ec 18             	sub    $0x18,%esp
  va_list ap;

  va_start(ap, fmt);
  8003ac:	8d 45 14             	lea    0x14(%ebp),%eax
  vprintfmt(putch, putdat, fmt, ap);
  8003af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c4:	89 04 24             	mov    %eax,(%esp)
  8003c7:	e8 02 00 00 00       	call   8003ce <vprintfmt>
  va_end(ap);
}
  8003cc:	c9                   	leave  
  8003cd:	c3                   	ret    

008003ce <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ce:	55                   	push   %ebp
  8003cf:	89 e5                	mov    %esp,%ebp
  8003d1:	57                   	push   %edi
  8003d2:	56                   	push   %esi
  8003d3:	53                   	push   %ebx
  8003d4:	83 ec 3c             	sub    $0x3c,%esp
  8003d7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003da:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003dd:	eb 14                	jmp    8003f3 <vprintfmt+0x25>
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
      if (ch == '\0')
  8003df:	85 c0                	test   %eax,%eax
  8003e1:	0f 84 b3 03 00 00    	je     80079a <vprintfmt+0x3cc>
        return;
      putch(ch, putdat);
  8003e7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003eb:	89 04 24             	mov    %eax,(%esp)
  8003ee:	ff 55 08             	call   *0x8(%ebp)
  unsigned long long num;
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
  8003f1:	89 f3                	mov    %esi,%ebx
  8003f3:	8d 73 01             	lea    0x1(%ebx),%esi
  8003f6:	0f b6 03             	movzbl (%ebx),%eax
  8003f9:	83 f8 25             	cmp    $0x25,%eax
  8003fc:	75 e1                	jne    8003df <vprintfmt+0x11>
  8003fe:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800402:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800409:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800410:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800417:	ba 00 00 00 00       	mov    $0x0,%edx
  80041c:	eb 1d                	jmp    80043b <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80041e:	89 de                	mov    %ebx,%esi

    // flag to pad on the right
    case '-':
      padc = '-';
  800420:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800424:	eb 15                	jmp    80043b <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  800426:	89 de                	mov    %ebx,%esi
      padc = '-';
      goto reswitch;

    // flag to pad with 0's instead of spaces
    case '0':
      padc = '0';
  800428:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80042c:	eb 0d                	jmp    80043b <vprintfmt+0x6d>
      altflag = 1;
      goto reswitch;

process_precision:
      if (width < 0)
        width = precision, precision = -1;
  80042e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800431:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800434:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80043b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80043e:	0f b6 0e             	movzbl (%esi),%ecx
  800441:	0f b6 c1             	movzbl %cl,%eax
  800444:	83 e9 23             	sub    $0x23,%ecx
  800447:	80 f9 55             	cmp    $0x55,%cl
  80044a:	0f 87 2a 03 00 00    	ja     80077a <vprintfmt+0x3ac>
  800450:	0f b6 c9             	movzbl %cl,%ecx
  800453:	ff 24 8d e0 22 80 00 	jmp    *0x8022e0(,%ecx,4)
  80045a:	89 de                	mov    %ebx,%esi
  80045c:	b9 00 00 00 00       	mov    $0x0,%ecx
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
        precision = precision * 10 + ch - '0';
  800461:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800464:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
        ch = *fmt;
  800468:	0f be 06             	movsbl (%esi),%eax
        if (ch < '0' || ch > '9')
  80046b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80046e:	83 fb 09             	cmp    $0x9,%ebx
  800471:	77 36                	ja     8004a9 <vprintfmt+0xdb>
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
  800473:	83 c6 01             	add    $0x1,%esi
        precision = precision * 10 + ch - '0';
        ch = *fmt;
        if (ch < '0' || ch > '9')
          break;
      }
  800476:	eb e9                	jmp    800461 <vprintfmt+0x93>
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
  800478:	8b 45 14             	mov    0x14(%ebp),%eax
  80047b:	8d 48 04             	lea    0x4(%eax),%ecx
  80047e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800481:	8b 00                	mov    (%eax),%eax
  800483:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  800486:	89 de                	mov    %ebx,%esi
      }
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
      goto process_precision;
  800488:	eb 22                	jmp    8004ac <vprintfmt+0xde>
  80048a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80048d:	85 c9                	test   %ecx,%ecx
  80048f:	b8 00 00 00 00       	mov    $0x0,%eax
  800494:	0f 49 c1             	cmovns %ecx,%eax
  800497:	89 45 dc             	mov    %eax,-0x24(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80049a:	89 de                	mov    %ebx,%esi
  80049c:	eb 9d                	jmp    80043b <vprintfmt+0x6d>
  80049e:	89 de                	mov    %ebx,%esi
      if (width < 0)
        width = 0;
      goto reswitch;

    case '#':
      altflag = 1;
  8004a0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
      goto reswitch;
  8004a7:	eb 92                	jmp    80043b <vprintfmt+0x6d>
  8004a9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

process_precision:
      if (width < 0)
  8004ac:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004b0:	79 89                	jns    80043b <vprintfmt+0x6d>
  8004b2:	e9 77 ff ff ff       	jmp    80042e <vprintfmt+0x60>
        width = precision, precision = -1;
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
  8004b7:	83 c2 01             	add    $0x1,%edx
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8004ba:	89 de                	mov    %ebx,%esi
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
      goto reswitch;
  8004bc:	e9 7a ff ff ff       	jmp    80043b <vprintfmt+0x6d>

    // character
    case 'c':
      putch(va_arg(ap, int), putdat);
  8004c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c4:	8d 50 04             	lea    0x4(%eax),%edx
  8004c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ca:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004ce:	8b 00                	mov    (%eax),%eax
  8004d0:	89 04 24             	mov    %eax,(%esp)
  8004d3:	ff 55 08             	call   *0x8(%ebp)
      break;
  8004d6:	e9 18 ff ff ff       	jmp    8003f3 <vprintfmt+0x25>

    // error message
    case 'e':
      err = va_arg(ap, int);
  8004db:	8b 45 14             	mov    0x14(%ebp),%eax
  8004de:	8d 50 04             	lea    0x4(%eax),%edx
  8004e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e4:	8b 00                	mov    (%eax),%eax
  8004e6:	99                   	cltd   
  8004e7:	31 d0                	xor    %edx,%eax
  8004e9:	29 d0                	sub    %edx,%eax
      if (err < 0)
        err = -err;
      if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004eb:	83 f8 0f             	cmp    $0xf,%eax
  8004ee:	7f 0b                	jg     8004fb <vprintfmt+0x12d>
  8004f0:	8b 14 85 40 24 80 00 	mov    0x802440(,%eax,4),%edx
  8004f7:	85 d2                	test   %edx,%edx
  8004f9:	75 20                	jne    80051b <vprintfmt+0x14d>
        printfmt(putch, putdat, "error %d", err);
  8004fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004ff:	c7 44 24 08 b3 21 80 	movl   $0x8021b3,0x8(%esp)
  800506:	00 
  800507:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80050b:	8b 45 08             	mov    0x8(%ebp),%eax
  80050e:	89 04 24             	mov    %eax,(%esp)
  800511:	e8 90 fe ff ff       	call   8003a6 <printfmt>
  800516:	e9 d8 fe ff ff       	jmp    8003f3 <vprintfmt+0x25>
      else
        printfmt(putch, putdat, "%s", p);
  80051b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80051f:	c7 44 24 08 bc 21 80 	movl   $0x8021bc,0x8(%esp)
  800526:	00 
  800527:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80052b:	8b 45 08             	mov    0x8(%ebp),%eax
  80052e:	89 04 24             	mov    %eax,(%esp)
  800531:	e8 70 fe ff ff       	call   8003a6 <printfmt>
  800536:	e9 b8 fe ff ff       	jmp    8003f3 <vprintfmt+0x25>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80053b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80053e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800541:	89 45 d0             	mov    %eax,-0x30(%ebp)
        printfmt(putch, putdat, "%s", p);
      break;

    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
  800544:	8b 45 14             	mov    0x14(%ebp),%eax
  800547:	8d 50 04             	lea    0x4(%eax),%edx
  80054a:	89 55 14             	mov    %edx,0x14(%ebp)
  80054d:	8b 30                	mov    (%eax),%esi
        p = "(null)";
  80054f:	85 f6                	test   %esi,%esi
  800551:	b8 ac 21 80 00       	mov    $0x8021ac,%eax
  800556:	0f 44 f0             	cmove  %eax,%esi
      if (width > 0 && padc != '-')
  800559:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80055d:	0f 84 97 00 00 00    	je     8005fa <vprintfmt+0x22c>
  800563:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800567:	0f 8e 9b 00 00 00    	jle    800608 <vprintfmt+0x23a>
        for (width -= strnlen(p, precision); width > 0; width--)
  80056d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800571:	89 34 24             	mov    %esi,(%esp)
  800574:	e8 cf 02 00 00       	call   800848 <strnlen>
  800579:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80057c:	29 c2                	sub    %eax,%edx
  80057e:	89 55 d0             	mov    %edx,-0x30(%ebp)
          putch(padc, putdat);
  800581:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800585:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800588:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80058b:	8b 75 08             	mov    0x8(%ebp),%esi
  80058e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800591:	89 d3                	mov    %edx,%ebx
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
  800593:	eb 0f                	jmp    8005a4 <vprintfmt+0x1d6>
          putch(padc, putdat);
  800595:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800599:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80059c:	89 04 24             	mov    %eax,(%esp)
  80059f:	ff d6                	call   *%esi
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
  8005a1:	83 eb 01             	sub    $0x1,%ebx
  8005a4:	85 db                	test   %ebx,%ebx
  8005a6:	7f ed                	jg     800595 <vprintfmt+0x1c7>
  8005a8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005ab:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005ae:	85 d2                	test   %edx,%edx
  8005b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b5:	0f 49 c2             	cmovns %edx,%eax
  8005b8:	29 c2                	sub    %eax,%edx
  8005ba:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005bd:	89 d7                	mov    %edx,%edi
  8005bf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005c2:	eb 50                	jmp    800614 <vprintfmt+0x246>
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
  8005c4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005c8:	74 1e                	je     8005e8 <vprintfmt+0x21a>
  8005ca:	0f be d2             	movsbl %dl,%edx
  8005cd:	83 ea 20             	sub    $0x20,%edx
  8005d0:	83 fa 5e             	cmp    $0x5e,%edx
  8005d3:	76 13                	jbe    8005e8 <vprintfmt+0x21a>
          putch('?', putdat);
  8005d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005dc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005e3:	ff 55 08             	call   *0x8(%ebp)
  8005e6:	eb 0d                	jmp    8005f5 <vprintfmt+0x227>
        else
          putch(ch, putdat);
  8005e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005eb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005ef:	89 04 24             	mov    %eax,(%esp)
  8005f2:	ff 55 08             	call   *0x8(%ebp)
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f5:	83 ef 01             	sub    $0x1,%edi
  8005f8:	eb 1a                	jmp    800614 <vprintfmt+0x246>
  8005fa:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005fd:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800600:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800603:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800606:	eb 0c                	jmp    800614 <vprintfmt+0x246>
  800608:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80060b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80060e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800611:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800614:	83 c6 01             	add    $0x1,%esi
  800617:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80061b:	0f be c2             	movsbl %dl,%eax
  80061e:	85 c0                	test   %eax,%eax
  800620:	74 27                	je     800649 <vprintfmt+0x27b>
  800622:	85 db                	test   %ebx,%ebx
  800624:	78 9e                	js     8005c4 <vprintfmt+0x1f6>
  800626:	83 eb 01             	sub    $0x1,%ebx
  800629:	79 99                	jns    8005c4 <vprintfmt+0x1f6>
  80062b:	89 f8                	mov    %edi,%eax
  80062d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800630:	8b 75 08             	mov    0x8(%ebp),%esi
  800633:	89 c3                	mov    %eax,%ebx
  800635:	eb 1a                	jmp    800651 <vprintfmt+0x283>
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
        putch(' ', putdat);
  800637:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80063b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800642:	ff d6                	call   *%esi
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
  800644:	83 eb 01             	sub    $0x1,%ebx
  800647:	eb 08                	jmp    800651 <vprintfmt+0x283>
  800649:	89 fb                	mov    %edi,%ebx
  80064b:	8b 75 08             	mov    0x8(%ebp),%esi
  80064e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800651:	85 db                	test   %ebx,%ebx
  800653:	7f e2                	jg     800637 <vprintfmt+0x269>
  800655:	89 75 08             	mov    %esi,0x8(%ebp)
  800658:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80065b:	e9 93 fd ff ff       	jmp    8003f3 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  if (lflag >= 2)
  800660:	83 fa 01             	cmp    $0x1,%edx
  800663:	7e 16                	jle    80067b <vprintfmt+0x2ad>
    return va_arg(*ap, long long);
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8d 50 08             	lea    0x8(%eax),%edx
  80066b:	89 55 14             	mov    %edx,0x14(%ebp)
  80066e:	8b 50 04             	mov    0x4(%eax),%edx
  800671:	8b 00                	mov    (%eax),%eax
  800673:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800676:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800679:	eb 32                	jmp    8006ad <vprintfmt+0x2df>
  else if (lflag)
  80067b:	85 d2                	test   %edx,%edx
  80067d:	74 18                	je     800697 <vprintfmt+0x2c9>
    return va_arg(*ap, long);
  80067f:	8b 45 14             	mov    0x14(%ebp),%eax
  800682:	8d 50 04             	lea    0x4(%eax),%edx
  800685:	89 55 14             	mov    %edx,0x14(%ebp)
  800688:	8b 30                	mov    (%eax),%esi
  80068a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80068d:	89 f0                	mov    %esi,%eax
  80068f:	c1 f8 1f             	sar    $0x1f,%eax
  800692:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800695:	eb 16                	jmp    8006ad <vprintfmt+0x2df>
  else
    return va_arg(*ap, int);
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8d 50 04             	lea    0x4(%eax),%edx
  80069d:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a0:	8b 30                	mov    (%eax),%esi
  8006a2:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006a5:	89 f0                	mov    %esi,%eax
  8006a7:	c1 f8 1f             	sar    $0x1f,%eax
  8006aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        putch(' ', putdat);
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
  8006ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      if ((long long)num < 0) {
        putch('-', putdat);
        num = -(long long)num;
      }
      base = 10;
  8006b3:	b9 0a 00 00 00       	mov    $0xa,%ecx
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
      if ((long long)num < 0) {
  8006b8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006bc:	0f 89 80 00 00 00    	jns    800742 <vprintfmt+0x374>
        putch('-', putdat);
  8006c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006c6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006cd:	ff 55 08             	call   *0x8(%ebp)
        num = -(long long)num;
  8006d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006d3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006d6:	f7 d8                	neg    %eax
  8006d8:	83 d2 00             	adc    $0x0,%edx
  8006db:	f7 da                	neg    %edx
      }
      base = 10;
  8006dd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006e2:	eb 5e                	jmp    800742 <vprintfmt+0x374>
      goto number;

    // unsigned decimal
    case 'u':
      num = getuint(&ap, lflag);
  8006e4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e7:	e8 63 fc ff ff       	call   80034f <getuint>
      base = 10;
  8006ec:	b9 0a 00 00 00       	mov    $0xa,%ecx
      goto number;
  8006f1:	eb 4f                	jmp    800742 <vprintfmt+0x374>

    // (unsigned) octal
    case 'o':
      num = getuint(&ap, lflag);
  8006f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f6:	e8 54 fc ff ff       	call   80034f <getuint>
      base = 8;
  8006fb:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800700:	eb 40                	jmp    800742 <vprintfmt+0x374>

    // pointer
    case 'p':
      putch('0', putdat);
  800702:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800706:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80070d:	ff 55 08             	call   *0x8(%ebp)
      putch('x', putdat);
  800710:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800714:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80071b:	ff 55 08             	call   *0x8(%ebp)
      num = (unsigned long long)
            (uintptr_t)va_arg(ap, void *);
  80071e:	8b 45 14             	mov    0x14(%ebp),%eax
  800721:	8d 50 04             	lea    0x4(%eax),%edx
  800724:	89 55 14             	mov    %edx,0x14(%ebp)

    // pointer
    case 'p':
      putch('0', putdat);
      putch('x', putdat);
      num = (unsigned long long)
  800727:	8b 00                	mov    (%eax),%eax
  800729:	ba 00 00 00 00       	mov    $0x0,%edx
            (uintptr_t)va_arg(ap, void *);
      base = 16;
  80072e:	b9 10 00 00 00       	mov    $0x10,%ecx
      goto number;
  800733:	eb 0d                	jmp    800742 <vprintfmt+0x374>

    // (unsigned) hexadecimal
    case 'x':
      num = getuint(&ap, lflag);
  800735:	8d 45 14             	lea    0x14(%ebp),%eax
  800738:	e8 12 fc ff ff       	call   80034f <getuint>
      base = 16;
  80073d:	b9 10 00 00 00       	mov    $0x10,%ecx
number:
      printnum(putch, putdat, num, base, width, padc);
  800742:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800746:	89 74 24 10          	mov    %esi,0x10(%esp)
  80074a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80074d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800751:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800755:	89 04 24             	mov    %eax,(%esp)
  800758:	89 54 24 04          	mov    %edx,0x4(%esp)
  80075c:	89 fa                	mov    %edi,%edx
  80075e:	8b 45 08             	mov    0x8(%ebp),%eax
  800761:	e8 fa fa ff ff       	call   800260 <printnum>
      break;
  800766:	e9 88 fc ff ff       	jmp    8003f3 <vprintfmt+0x25>

    // escaped '%' character
    case '%':
      putch(ch, putdat);
  80076b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80076f:	89 04 24             	mov    %eax,(%esp)
  800772:	ff 55 08             	call   *0x8(%ebp)
      break;
  800775:	e9 79 fc ff ff       	jmp    8003f3 <vprintfmt+0x25>

    // unrecognized escape sequence - just print it literally
    default:
      putch('%', putdat);
  80077a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80077e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800785:	ff 55 08             	call   *0x8(%ebp)
      for (fmt--; fmt[-1] != '%'; fmt--)
  800788:	89 f3                	mov    %esi,%ebx
  80078a:	eb 03                	jmp    80078f <vprintfmt+0x3c1>
  80078c:	83 eb 01             	sub    $0x1,%ebx
  80078f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800793:	75 f7                	jne    80078c <vprintfmt+0x3be>
  800795:	e9 59 fc ff ff       	jmp    8003f3 <vprintfmt+0x25>
        /* do nothing */;
      break;
    }
  }
}
  80079a:	83 c4 3c             	add    $0x3c,%esp
  80079d:	5b                   	pop    %ebx
  80079e:	5e                   	pop    %esi
  80079f:	5f                   	pop    %edi
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <vsnprintf>:
    *b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	83 ec 28             	sub    $0x28,%esp
  8007a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  struct sprintbuf b = { buf, buf+n-1, 0 };
  8007ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  if (buf == NULL || n < 1)
  8007bf:	85 c0                	test   %eax,%eax
  8007c1:	74 30                	je     8007f3 <vsnprintf+0x51>
  8007c3:	85 d2                	test   %edx,%edx
  8007c5:	7e 2c                	jle    8007f3 <vsnprintf+0x51>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007dc:	c7 04 24 89 03 80 00 	movl   $0x800389,(%esp)
  8007e3:	e8 e6 fb ff ff       	call   8003ce <vprintfmt>

  // null terminate the buffer
  *b.buf = '\0';
  8007e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007eb:	c6 00 00             	movb   $0x0,(%eax)

  return b.cnt;
  8007ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f1:	eb 05                	jmp    8007f8 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  struct sprintbuf b = { buf, buf+n-1, 0 };

  if (buf == NULL || n < 1)
    return -E_INVAL;
  8007f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

  // null terminate the buffer
  *b.buf = '\0';

  return b.cnt;
}
  8007f8:	c9                   	leave  
  8007f9:	c3                   	ret    

008007fa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800800:	8d 45 14             	lea    0x14(%ebp),%eax
  rc = vsnprintf(buf, n, fmt, ap);
  800803:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800807:	8b 45 10             	mov    0x10(%ebp),%eax
  80080a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80080e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800811:	89 44 24 04          	mov    %eax,0x4(%esp)
  800815:	8b 45 08             	mov    0x8(%ebp),%eax
  800818:	89 04 24             	mov    %eax,(%esp)
  80081b:	e8 82 ff ff ff       	call   8007a2 <vsnprintf>
  va_end(ap);

  return rc;
}
  800820:	c9                   	leave  
  800821:	c3                   	ret    
  800822:	66 90                	xchg   %ax,%ax
  800824:	66 90                	xchg   %ax,%ax
  800826:	66 90                	xchg   %ax,%ax
  800828:	66 90                	xchg   %ax,%ax
  80082a:	66 90                	xchg   %ax,%ax
  80082c:	66 90                	xchg   %ax,%ax
  80082e:	66 90                	xchg   %ax,%ax

00800830 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for (n = 0; *s != '\0'; s++)
  800836:	b8 00 00 00 00       	mov    $0x0,%eax
  80083b:	eb 03                	jmp    800840 <strlen+0x10>
    n++;
  80083d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
  int n;

  for (n = 0; *s != '\0'; s++)
  800840:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800844:	75 f7                	jne    80083d <strlen+0xd>
    n++;
  return n;
}
  800846:	5d                   	pop    %ebp
  800847:	c3                   	ret    

00800848 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084e:	8b 55 0c             	mov    0xc(%ebp),%edx
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800851:	b8 00 00 00 00       	mov    $0x0,%eax
  800856:	eb 03                	jmp    80085b <strnlen+0x13>
    n++;
  800858:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085b:	39 d0                	cmp    %edx,%eax
  80085d:	74 06                	je     800865 <strnlen+0x1d>
  80085f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800863:	75 f3                	jne    800858 <strnlen+0x10>
    n++;
  return n;
}
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	53                   	push   %ebx
  80086b:	8b 45 08             	mov    0x8(%ebp),%eax
  80086e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800871:	89 c2                	mov    %eax,%edx
  800873:	83 c2 01             	add    $0x1,%edx
  800876:	83 c1 01             	add    $0x1,%ecx
  800879:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80087d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800880:	84 db                	test   %bl,%bl
  800882:	75 ef                	jne    800873 <strcpy+0xc>
    /* do nothing */;
  return ret;
}
  800884:	5b                   	pop    %ebx
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	53                   	push   %ebx
  80088b:	83 ec 08             	sub    $0x8,%esp
  80088e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int len = strlen(dst);
  800891:	89 1c 24             	mov    %ebx,(%esp)
  800894:	e8 97 ff ff ff       	call   800830 <strlen>

  strcpy(dst + len, src);
  800899:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089c:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008a0:	01 d8                	add    %ebx,%eax
  8008a2:	89 04 24             	mov    %eax,(%esp)
  8008a5:	e8 bd ff ff ff       	call   800867 <strcpy>
  return dst;
}
  8008aa:	89 d8                	mov    %ebx,%eax
  8008ac:	83 c4 08             	add    $0x8,%esp
  8008af:	5b                   	pop    %ebx
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	56                   	push   %esi
  8008b6:	53                   	push   %ebx
  8008b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008bd:	89 f3                	mov    %esi,%ebx
  8008bf:	03 5d 10             	add    0x10(%ebp),%ebx
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  8008c2:	89 f2                	mov    %esi,%edx
  8008c4:	eb 0f                	jmp    8008d5 <strncpy+0x23>
    *dst++ = *src;
  8008c6:	83 c2 01             	add    $0x1,%edx
  8008c9:	0f b6 01             	movzbl (%ecx),%eax
  8008cc:	88 42 ff             	mov    %al,-0x1(%edx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  8008cf:	80 39 01             	cmpb   $0x1,(%ecx)
  8008d2:	83 d9 ff             	sbb    $0xffffffff,%ecx
{
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  8008d5:	39 da                	cmp    %ebx,%edx
  8008d7:	75 ed                	jne    8008c6 <strncpy+0x14>
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  }
  return ret;
}
  8008d9:	89 f0                	mov    %esi,%eax
  8008db:	5b                   	pop    %ebx
  8008dc:	5e                   	pop    %esi
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	56                   	push   %esi
  8008e3:	53                   	push   %ebx
  8008e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008ed:	89 f0                	mov    %esi,%eax
  8008ef:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  8008f3:	85 c9                	test   %ecx,%ecx
  8008f5:	75 0b                	jne    800902 <strlcpy+0x23>
  8008f7:	eb 1d                	jmp    800916 <strlcpy+0x37>
    while (--size > 0 && *src != '\0')
      *dst++ = *src++;
  8008f9:	83 c0 01             	add    $0x1,%eax
  8008fc:	83 c2 01             	add    $0x1,%edx
  8008ff:	88 48 ff             	mov    %cl,-0x1(%eax)
{
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
    while (--size > 0 && *src != '\0')
  800902:	39 d8                	cmp    %ebx,%eax
  800904:	74 0b                	je     800911 <strlcpy+0x32>
  800906:	0f b6 0a             	movzbl (%edx),%ecx
  800909:	84 c9                	test   %cl,%cl
  80090b:	75 ec                	jne    8008f9 <strlcpy+0x1a>
  80090d:	89 c2                	mov    %eax,%edx
  80090f:	eb 02                	jmp    800913 <strlcpy+0x34>
  800911:	89 c2                	mov    %eax,%edx
      *dst++ = *src++;
    *dst = '\0';
  800913:	c6 02 00             	movb   $0x0,(%edx)
  }
  return dst - dst_in;
  800916:	29 f0                	sub    %esi,%eax
}
  800918:	5b                   	pop    %ebx
  800919:	5e                   	pop    %esi
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800922:	8b 55 0c             	mov    0xc(%ebp),%edx
  while (*p && *p == *q)
  800925:	eb 06                	jmp    80092d <strcmp+0x11>
    p++, q++;
  800927:	83 c1 01             	add    $0x1,%ecx
  80092a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
  while (*p && *p == *q)
  80092d:	0f b6 01             	movzbl (%ecx),%eax
  800930:	84 c0                	test   %al,%al
  800932:	74 04                	je     800938 <strcmp+0x1c>
  800934:	3a 02                	cmp    (%edx),%al
  800936:	74 ef                	je     800927 <strcmp+0xb>
    p++, q++;
  return (int)((unsigned char)*p - (unsigned char)*q);
  800938:	0f b6 c0             	movzbl %al,%eax
  80093b:	0f b6 12             	movzbl (%edx),%edx
  80093e:	29 d0                	sub    %edx,%eax
}
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	53                   	push   %ebx
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094c:	89 c3                	mov    %eax,%ebx
  80094e:	03 5d 10             	add    0x10(%ebp),%ebx
  while (n > 0 && *p && *p == *q)
  800951:	eb 06                	jmp    800959 <strncmp+0x17>
    n--, p++, q++;
  800953:	83 c0 01             	add    $0x1,%eax
  800956:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
  800959:	39 d8                	cmp    %ebx,%eax
  80095b:	74 15                	je     800972 <strncmp+0x30>
  80095d:	0f b6 08             	movzbl (%eax),%ecx
  800960:	84 c9                	test   %cl,%cl
  800962:	74 04                	je     800968 <strncmp+0x26>
  800964:	3a 0a                	cmp    (%edx),%cl
  800966:	74 eb                	je     800953 <strncmp+0x11>
    n--, p++, q++;
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800968:	0f b6 00             	movzbl (%eax),%eax
  80096b:	0f b6 12             	movzbl (%edx),%edx
  80096e:	29 d0                	sub    %edx,%eax
  800970:	eb 05                	jmp    800977 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
    n--, p++, q++;
  if (n == 0)
    return 0;
  800972:	b8 00 00 00 00       	mov    $0x0,%eax
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
}
  800977:	5b                   	pop    %ebx
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	8b 45 08             	mov    0x8(%ebp),%eax
  800980:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
  800984:	eb 07                	jmp    80098d <strchr+0x13>
    if (*s == c)
  800986:	38 ca                	cmp    %cl,%dl
  800988:	74 0f                	je     800999 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  for (; *s; s++)
  80098a:	83 c0 01             	add    $0x1,%eax
  80098d:	0f b6 10             	movzbl (%eax),%edx
  800990:	84 d2                	test   %dl,%dl
  800992:	75 f2                	jne    800986 <strchr+0xc>
    if (*s == c)
      return (char*)s;
  return 0;
  800994:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
  8009a5:	eb 07                	jmp    8009ae <strfind+0x13>
    if (*s == c)
  8009a7:	38 ca                	cmp    %cl,%dl
  8009a9:	74 0a                	je     8009b5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  for (; *s; s++)
  8009ab:	83 c0 01             	add    $0x1,%eax
  8009ae:	0f b6 10             	movzbl (%eax),%edx
  8009b1:	84 d2                	test   %dl,%dl
  8009b3:	75 f2                	jne    8009a7 <strfind+0xc>
    if (*s == c)
      break;
  return (char*)s;
}
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	57                   	push   %edi
  8009bb:	56                   	push   %esi
  8009bc:	53                   	push   %ebx
  8009bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *p;

  if (n == 0)
  8009c3:	85 c9                	test   %ecx,%ecx
  8009c5:	74 36                	je     8009fd <memset+0x46>
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
  8009c7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009cd:	75 28                	jne    8009f7 <memset+0x40>
  8009cf:	f6 c1 03             	test   $0x3,%cl
  8009d2:	75 23                	jne    8009f7 <memset+0x40>
    c &= 0xFF;
  8009d4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
    c = (c<<24)|(c<<16)|(c<<8)|c;
  8009d8:	89 d3                	mov    %edx,%ebx
  8009da:	c1 e3 08             	shl    $0x8,%ebx
  8009dd:	89 d6                	mov    %edx,%esi
  8009df:	c1 e6 18             	shl    $0x18,%esi
  8009e2:	89 d0                	mov    %edx,%eax
  8009e4:	c1 e0 10             	shl    $0x10,%eax
  8009e7:	09 f0                	or     %esi,%eax
  8009e9:	09 c2                	or     %eax,%edx
  8009eb:	89 d0                	mov    %edx,%eax
  8009ed:	09 d8                	or     %ebx,%eax
    asm volatile ("cld; rep stosl\n"
                  :: "D" (v), "a" (c), "c" (n/4)
  8009ef:	c1 e9 02             	shr    $0x2,%ecx
  if (n == 0)
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
    c &= 0xFF;
    c = (c<<24)|(c<<16)|(c<<8)|c;
    asm volatile ("cld; rep stosl\n"
  8009f2:	fc                   	cld    
  8009f3:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f5:	eb 06                	jmp    8009fd <memset+0x46>
                  :: "D" (v), "a" (c), "c" (n/4)
                  : "cc", "memory");
  } else
    asm volatile ("cld; rep stosb\n"
  8009f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fa:	fc                   	cld    
  8009fb:	f3 aa                	rep stos %al,%es:(%edi)
                  :: "D" (v), "a" (c), "c" (n)
                  : "cc", "memory");
  return v;
}
  8009fd:	89 f8                	mov    %edi,%eax
  8009ff:	5b                   	pop    %ebx
  800a00:	5e                   	pop    %esi
  800a01:	5f                   	pop    %edi
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    

00800a04 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	57                   	push   %edi
  800a08:	56                   	push   %esi
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800a12:	39 c6                	cmp    %eax,%esi
  800a14:	73 35                	jae    800a4b <memmove+0x47>
  800a16:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a19:	39 d0                	cmp    %edx,%eax
  800a1b:	73 2e                	jae    800a4b <memmove+0x47>
    s += n;
    d += n;
  800a1d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a20:	89 d6                	mov    %edx,%esi
  800a22:	09 fe                	or     %edi,%esi
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a24:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a2a:	75 13                	jne    800a3f <memmove+0x3b>
  800a2c:	f6 c1 03             	test   $0x3,%cl
  800a2f:	75 0e                	jne    800a3f <memmove+0x3b>
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a31:	83 ef 04             	sub    $0x4,%edi
  800a34:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a37:	c1 e9 02             	shr    $0x2,%ecx
  d = dst;
  if (s < d && s + n > d) {
    s += n;
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
  800a3a:	fd                   	std    
  800a3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a3d:	eb 09                	jmp    800a48 <memmove+0x44>
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a3f:	83 ef 01             	sub    $0x1,%edi
  800a42:	8d 72 ff             	lea    -0x1(%edx),%esi
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
  800a45:	fd                   	std    
  800a46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  800a48:	fc                   	cld    
  800a49:	eb 1d                	jmp    800a68 <memmove+0x64>
  800a4b:	89 f2                	mov    %esi,%edx
  800a4d:	09 c2                	or     %eax,%edx
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4f:	f6 c2 03             	test   $0x3,%dl
  800a52:	75 0f                	jne    800a63 <memmove+0x5f>
  800a54:	f6 c1 03             	test   $0x3,%cl
  800a57:	75 0a                	jne    800a63 <memmove+0x5f>
      asm volatile ("cld; rep movsl\n"
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a59:	c1 e9 02             	shr    $0x2,%ecx
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("cld; rep movsl\n"
  800a5c:	89 c7                	mov    %eax,%edi
  800a5e:	fc                   	cld    
  800a5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a61:	eb 05                	jmp    800a68 <memmove+0x64>
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("cld; rep movsb\n"
  800a63:	89 c7                	mov    %eax,%edi
  800a65:	fc                   	cld    
  800a66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d), "S" (s), "c" (n) : "cc", "memory");
  }
  return dst;
}
  800a68:	5e                   	pop    %esi
  800a69:	5f                   	pop    %edi
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
  800a72:	8b 45 10             	mov    0x10(%ebp),%eax
  800a75:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	89 04 24             	mov    %eax,(%esp)
  800a86:	e8 79 ff ff ff       	call   800a04 <memmove>
}
  800a8b:	c9                   	leave  
  800a8c:	c3                   	ret    

00800a8d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	56                   	push   %esi
  800a91:	53                   	push   %ebx
  800a92:	8b 55 08             	mov    0x8(%ebp),%edx
  800a95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a98:	89 d6                	mov    %edx,%esi
  800a9a:	03 75 10             	add    0x10(%ebp),%esi
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
  800a9d:	eb 1a                	jmp    800ab9 <memcmp+0x2c>
    if (*s1 != *s2)
  800a9f:	0f b6 02             	movzbl (%edx),%eax
  800aa2:	0f b6 19             	movzbl (%ecx),%ebx
  800aa5:	38 d8                	cmp    %bl,%al
  800aa7:	74 0a                	je     800ab3 <memcmp+0x26>
      return (int)*s1 - (int)*s2;
  800aa9:	0f b6 c0             	movzbl %al,%eax
  800aac:	0f b6 db             	movzbl %bl,%ebx
  800aaf:	29 d8                	sub    %ebx,%eax
  800ab1:	eb 0f                	jmp    800ac2 <memcmp+0x35>
    s1++, s2++;
  800ab3:	83 c2 01             	add    $0x1,%edx
  800ab6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
  800ab9:	39 f2                	cmp    %esi,%edx
  800abb:	75 e2                	jne    800a9f <memcmp+0x12>
    if (*s1 != *s2)
      return (int)*s1 - (int)*s2;
    s1++, s2++;
  }

  return 0;
  800abd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    

00800ac6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  800acc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  const void *ends = (const char*)s + n;
  800acf:	89 c2                	mov    %eax,%edx
  800ad1:	03 55 10             	add    0x10(%ebp),%edx

  for (; s < ends; s++)
  800ad4:	eb 07                	jmp    800add <memfind+0x17>
    if (*(const unsigned char*)s == (unsigned char)c)
  800ad6:	38 08                	cmp    %cl,(%eax)
  800ad8:	74 07                	je     800ae1 <memfind+0x1b>
void *
memfind(const void *s, int c, size_t n)
{
  const void *ends = (const char*)s + n;

  for (; s < ends; s++)
  800ada:	83 c0 01             	add    $0x1,%eax
  800add:	39 d0                	cmp    %edx,%eax
  800adf:	72 f5                	jb     800ad6 <memfind+0x10>
    if (*(const unsigned char*)s == (unsigned char)c)
      break;
  return (void*)s;
}
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	57                   	push   %edi
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
  800ae9:	8b 55 08             	mov    0x8(%ebp),%edx
  800aec:	8b 45 10             	mov    0x10(%ebp),%eax
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800aef:	eb 03                	jmp    800af4 <strtol+0x11>
    s++;
  800af1:	83 c2 01             	add    $0x1,%edx
{
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800af4:	0f b6 0a             	movzbl (%edx),%ecx
  800af7:	80 f9 09             	cmp    $0x9,%cl
  800afa:	74 f5                	je     800af1 <strtol+0xe>
  800afc:	80 f9 20             	cmp    $0x20,%cl
  800aff:	74 f0                	je     800af1 <strtol+0xe>
    s++;

  // plus/minus sign
  if (*s == '+')
  800b01:	80 f9 2b             	cmp    $0x2b,%cl
  800b04:	75 0a                	jne    800b10 <strtol+0x2d>
    s++;
  800b06:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
  int neg = 0;
  800b09:	bf 00 00 00 00       	mov    $0x0,%edi
  800b0e:	eb 11                	jmp    800b21 <strtol+0x3e>
  800b10:	bf 00 00 00 00       	mov    $0x0,%edi
    s++;

  // plus/minus sign
  if (*s == '+')
    s++;
  else if (*s == '-')
  800b15:	80 f9 2d             	cmp    $0x2d,%cl
  800b18:	75 07                	jne    800b21 <strtol+0x3e>
    s++, neg = 1;
  800b1a:	8d 52 01             	lea    0x1(%edx),%edx
  800b1d:	66 bf 01 00          	mov    $0x1,%di

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b21:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b26:	75 15                	jne    800b3d <strtol+0x5a>
  800b28:	80 3a 30             	cmpb   $0x30,(%edx)
  800b2b:	75 10                	jne    800b3d <strtol+0x5a>
  800b2d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b31:	75 0a                	jne    800b3d <strtol+0x5a>
    s += 2, base = 16;
  800b33:	83 c2 02             	add    $0x2,%edx
  800b36:	b8 10 00 00 00       	mov    $0x10,%eax
  800b3b:	eb 10                	jmp    800b4d <strtol+0x6a>
  else if (base == 0 && s[0] == '0')
  800b3d:	85 c0                	test   %eax,%eax
  800b3f:	75 0c                	jne    800b4d <strtol+0x6a>
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800b41:	b0 0a                	mov    $0xa,%al
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
  800b43:	80 3a 30             	cmpb   $0x30,(%edx)
  800b46:	75 05                	jne    800b4d <strtol+0x6a>
    s++, base = 8;
  800b48:	83 c2 01             	add    $0x1,%edx
  800b4b:	b0 08                	mov    $0x8,%al
  else if (base == 0)
    base = 10;
  800b4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b52:	89 45 10             	mov    %eax,0x10(%ebp)

  // digits
  while (1) {
    int dig;

    if (*s >= '0' && *s <= '9')
  800b55:	0f b6 0a             	movzbl (%edx),%ecx
  800b58:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b5b:	89 f0                	mov    %esi,%eax
  800b5d:	3c 09                	cmp    $0x9,%al
  800b5f:	77 08                	ja     800b69 <strtol+0x86>
      dig = *s - '0';
  800b61:	0f be c9             	movsbl %cl,%ecx
  800b64:	83 e9 30             	sub    $0x30,%ecx
  800b67:	eb 20                	jmp    800b89 <strtol+0xa6>
    else if (*s >= 'a' && *s <= 'z')
  800b69:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b6c:	89 f0                	mov    %esi,%eax
  800b6e:	3c 19                	cmp    $0x19,%al
  800b70:	77 08                	ja     800b7a <strtol+0x97>
      dig = *s - 'a' + 10;
  800b72:	0f be c9             	movsbl %cl,%ecx
  800b75:	83 e9 57             	sub    $0x57,%ecx
  800b78:	eb 0f                	jmp    800b89 <strtol+0xa6>
    else if (*s >= 'A' && *s <= 'Z')
  800b7a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b7d:	89 f0                	mov    %esi,%eax
  800b7f:	3c 19                	cmp    $0x19,%al
  800b81:	77 16                	ja     800b99 <strtol+0xb6>
      dig = *s - 'A' + 10;
  800b83:	0f be c9             	movsbl %cl,%ecx
  800b86:	83 e9 37             	sub    $0x37,%ecx
    else
      break;
    if (dig >= base)
  800b89:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b8c:	7d 0f                	jge    800b9d <strtol+0xba>
      break;
    s++, val = (val * base) + dig;
  800b8e:	83 c2 01             	add    $0x1,%edx
  800b91:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800b95:	01 cb                	add    %ecx,%ebx
    // we don't properly detect overflow!
  }
  800b97:	eb bc                	jmp    800b55 <strtol+0x72>
  800b99:	89 d8                	mov    %ebx,%eax
  800b9b:	eb 02                	jmp    800b9f <strtol+0xbc>
  800b9d:	89 d8                	mov    %ebx,%eax

  if (endptr)
  800b9f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba3:	74 05                	je     800baa <strtol+0xc7>
    *endptr = (char*)s;
  800ba5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba8:	89 16                	mov    %edx,(%esi)
  return neg ? -val : val;
  800baa:	f7 d8                	neg    %eax
  800bac:	85 ff                	test   %edi,%edi
  800bae:	0f 44 c3             	cmove  %ebx,%eax
}
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <sys_cputs>:
  return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	57                   	push   %edi
  800bba:	56                   	push   %esi
  800bbb:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800bbc:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc7:	89 c3                	mov    %eax,%ebx
  800bc9:	89 c7                	mov    %eax,%edi
  800bcb:	89 c6                	mov    %eax,%esi
  800bcd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
  syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	57                   	push   %edi
  800bd8:	56                   	push   %esi
  800bd9:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800bda:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdf:	b8 01 00 00 00       	mov    $0x1,%eax
  800be4:	89 d1                	mov    %edx,%ecx
  800be6:	89 d3                	mov    %edx,%ebx
  800be8:	89 d7                	mov    %edx,%edi
  800bea:	89 d6                	mov    %edx,%esi
  800bec:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bee:	5b                   	pop    %ebx
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	57                   	push   %edi
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
  800bf9:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800bfc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c01:	b8 03 00 00 00       	mov    $0x3,%eax
  800c06:	8b 55 08             	mov    0x8(%ebp),%edx
  800c09:	89 cb                	mov    %ecx,%ebx
  800c0b:	89 cf                	mov    %ecx,%edi
  800c0d:	89 ce                	mov    %ecx,%esi
  800c0f:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800c11:	85 c0                	test   %eax,%eax
  800c13:	7e 28                	jle    800c3d <sys_env_destroy+0x4a>
    panic("syscall %d returned %d (> 0)", num, ret);
  800c15:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c19:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c20:	00 
  800c21:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800c28:	00 
  800c29:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c30:	00 
  800c31:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800c38:	e8 04 f5 ff ff       	call   800141 <_panic>

int
sys_env_destroy(envid_t envid)
{
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c3d:	83 c4 2c             	add    $0x2c,%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800c4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c50:	b8 02 00 00 00       	mov    $0x2,%eax
  800c55:	89 d1                	mov    %edx,%ecx
  800c57:	89 d3                	mov    %edx,%ebx
  800c59:	89 d7                	mov    %edx,%edi
  800c5b:	89 d6                	mov    %edx,%esi
  800c5d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <sys_yield>:

void
sys_yield(void)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800c6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c74:	89 d1                	mov    %edx,%ecx
  800c76:	89 d3                	mov    %edx,%ebx
  800c78:	89 d7                	mov    %edx,%edi
  800c7a:	89 d6                	mov    %edx,%esi
  800c7c:	cd 30                	int    $0x30

void
sys_yield(void)
{
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
  800c89:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800c8c:	be 00 00 00 00       	mov    $0x0,%esi
  800c91:	b8 04 00 00 00       	mov    $0x4,%eax
  800c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c99:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9f:	89 f7                	mov    %esi,%edi
  800ca1:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	7e 28                	jle    800ccf <sys_page_alloc+0x4c>
    panic("syscall %d returned %d (> 0)", num, ret);
  800ca7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cab:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cb2:	00 
  800cb3:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800cba:	00 
  800cbb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc2:	00 
  800cc3:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800cca:	e8 72 f4 ff ff       	call   800141 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  return syscall(SYS_page_alloc, 1, envid, (uint32_t)va, perm, 0, 0);
}
  800ccf:	83 c4 2c             	add    $0x2c,%esp
  800cd2:	5b                   	pop    %ebx
  800cd3:	5e                   	pop    %esi
  800cd4:	5f                   	pop    %edi
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    

00800cd7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	57                   	push   %edi
  800cdb:	56                   	push   %esi
  800cdc:	53                   	push   %ebx
  800cdd:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800ce0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ce5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ceb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cee:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf1:	8b 75 18             	mov    0x18(%ebp),%esi
  800cf4:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	7e 28                	jle    800d22 <sys_page_map+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800cfa:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cfe:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d05:	00 
  800d06:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800d0d:	00 
  800d0e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d15:	00 
  800d16:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800d1d:	e8 1f f4 ff ff       	call   800141 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  return syscall(SYS_page_map, 1, srcenv, (uint32_t)srcva, dstenv, (uint32_t)dstva, perm);
}
  800d22:	83 c4 2c             	add    $0x2c,%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
  800d30:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800d33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d38:	b8 06 00 00 00       	mov    $0x6,%eax
  800d3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d40:	8b 55 08             	mov    0x8(%ebp),%edx
  800d43:	89 df                	mov    %ebx,%edi
  800d45:	89 de                	mov    %ebx,%esi
  800d47:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	7e 28                	jle    800d75 <sys_page_unmap+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800d4d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d51:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d58:	00 
  800d59:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800d60:	00 
  800d61:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d68:	00 
  800d69:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800d70:	e8 cc f3 ff ff       	call   800141 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
  return syscall(SYS_page_unmap, 1, envid, (uint32_t)va, 0, 0, 0);
}
  800d75:	83 c4 2c             	add    $0x2c,%esp
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	57                   	push   %edi
  800d81:	56                   	push   %esi
  800d82:	53                   	push   %ebx
  800d83:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800d86:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d93:	8b 55 08             	mov    0x8(%ebp),%edx
  800d96:	89 df                	mov    %ebx,%edi
  800d98:	89 de                	mov    %ebx,%esi
  800d9a:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800d9c:	85 c0                	test   %eax,%eax
  800d9e:	7e 28                	jle    800dc8 <sys_env_set_status+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800da0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800dab:	00 
  800dac:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800db3:	00 
  800db4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dbb:	00 
  800dbc:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800dc3:	e8 79 f3 ff ff       	call   800141 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dc8:	83 c4 2c             	add    $0x2c,%esp
  800dcb:	5b                   	pop    %ebx
  800dcc:	5e                   	pop    %esi
  800dcd:	5f                   	pop    %edi
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	57                   	push   %edi
  800dd4:	56                   	push   %esi
  800dd5:	53                   	push   %ebx
  800dd6:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800dd9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dde:	b8 09 00 00 00       	mov    $0x9,%eax
  800de3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de6:	8b 55 08             	mov    0x8(%ebp),%edx
  800de9:	89 df                	mov    %ebx,%edi
  800deb:	89 de                	mov    %ebx,%esi
  800ded:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800def:	85 c0                	test   %eax,%eax
  800df1:	7e 28                	jle    800e1b <sys_env_set_trapframe+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800df3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dfe:	00 
  800dff:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800e06:	00 
  800e07:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e0e:	00 
  800e0f:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800e16:	e8 26 f3 ff ff       	call   800141 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t)tf, 0, 0, 0);
}
  800e1b:	83 c4 2c             	add    $0x2c,%esp
  800e1e:	5b                   	pop    %ebx
  800e1f:	5e                   	pop    %esi
  800e20:	5f                   	pop    %edi
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	57                   	push   %edi
  800e27:	56                   	push   %esi
  800e28:	53                   	push   %ebx
  800e29:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800e2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e31:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e39:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3c:	89 df                	mov    %ebx,%edi
  800e3e:	89 de                	mov    %ebx,%esi
  800e40:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800e42:	85 c0                	test   %eax,%eax
  800e44:	7e 28                	jle    800e6e <sys_env_set_pgfault_upcall+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800e46:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e51:	00 
  800e52:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800e59:	00 
  800e5a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e61:	00 
  800e62:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800e69:	e8 d3 f2 ff ff       	call   800141 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800e6e:	83 c4 2c             	add    $0x2c,%esp
  800e71:	5b                   	pop    %ebx
  800e72:	5e                   	pop    %esi
  800e73:	5f                   	pop    %edi
  800e74:	5d                   	pop    %ebp
  800e75:	c3                   	ret    

00800e76 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e76:	55                   	push   %ebp
  800e77:	89 e5                	mov    %esp,%ebp
  800e79:	57                   	push   %edi
  800e7a:	56                   	push   %esi
  800e7b:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800e7c:	be 00 00 00 00       	mov    $0x0,%esi
  800e81:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e89:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e8f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e92:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t)srcva, perm, 0);
}
  800e94:	5b                   	pop    %ebx
  800e95:	5e                   	pop    %esi
  800e96:	5f                   	pop    %edi
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    

00800e99 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	57                   	push   %edi
  800e9d:	56                   	push   %esi
  800e9e:	53                   	push   %ebx
  800e9f:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800ea2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ea7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eac:	8b 55 08             	mov    0x8(%ebp),%edx
  800eaf:	89 cb                	mov    %ecx,%ebx
  800eb1:	89 cf                	mov    %ecx,%edi
  800eb3:	89 ce                	mov    %ecx,%esi
  800eb5:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	7e 28                	jle    800ee3 <sys_ipc_recv+0x4a>
    panic("syscall %d returned %d (> 0)", num, ret);
  800ebb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ebf:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ec6:	00 
  800ec7:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800ece:	00 
  800ecf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed6:	00 
  800ed7:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800ede:	e8 5e f2 ff ff       	call   800141 <_panic>

int
sys_ipc_recv(void *dstva)
{
  return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ee3:	83 c4 2c             	add    $0x2c,%esp
  800ee6:	5b                   	pop    %ebx
  800ee7:	5e                   	pop    %esi
  800ee8:	5f                   	pop    %edi
  800ee9:	5d                   	pop    %ebp
  800eea:	c3                   	ret    

00800eeb <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	83 ec 18             	sub    $0x18,%esp
  int r;

  if (_pgfault_handler == 0) {
  800ef1:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800ef8:	75 70                	jne    800f6a <set_pgfault_handler+0x7f>
    // First time through!
    // LAB 4: Your code here.
    if(sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_SYSCALL) < 0) {
  800efa:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  800f01:	00 
  800f02:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800f09:	ee 
  800f0a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f11:	e8 6d fd ff ff       	call   800c83 <sys_page_alloc>
  800f16:	85 c0                	test   %eax,%eax
  800f18:	79 1c                	jns    800f36 <set_pgfault_handler+0x4b>
      panic("In set_pgfault_handler, sys_page_alloc error");
  800f1a:	c7 44 24 08 cc 24 80 	movl   $0x8024cc,0x8(%esp)
  800f21:	00 
  800f22:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800f29:	00 
  800f2a:	c7 04 24 35 25 80 00 	movl   $0x802535,(%esp)
  800f31:	e8 0b f2 ff ff       	call   800141 <_panic>
    }
    if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  800f36:	c7 44 24 04 74 0f 80 	movl   $0x800f74,0x4(%esp)
  800f3d:	00 
  800f3e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f45:	e8 d9 fe ff ff       	call   800e23 <sys_env_set_pgfault_upcall>
  800f4a:	85 c0                	test   %eax,%eax
  800f4c:	79 1c                	jns    800f6a <set_pgfault_handler+0x7f>
      panic("In set_pgfault_handler, sys_env_set_pgfault_upcall error");
  800f4e:	c7 44 24 08 fc 24 80 	movl   $0x8024fc,0x8(%esp)
  800f55:	00 
  800f56:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800f5d:	00 
  800f5e:	c7 04 24 35 25 80 00 	movl   $0x802535,(%esp)
  800f65:	e8 d7 f1 ff ff       	call   800141 <_panic>
    }
  }
  // Save handler pointer for assembly to call.
  _pgfault_handler = handler;
  800f6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6d:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800f72:	c9                   	leave  
  800f73:	c3                   	ret    

00800f74 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800f74:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800f75:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800f7a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800f7c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
  subl $0x4, 0x30(%esp)
  800f7f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
  movl 0x30(%esp), %eax
  800f84:	8b 44 24 30          	mov    0x30(%esp),%eax
  movl 0x28(%esp), %ebx
  800f88:	8b 5c 24 28          	mov    0x28(%esp),%ebx
  movl %ebx, (%eax)
  800f8c:	89 18                	mov    %ebx,(%eax)


	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
  addl $0x8, %esp
  800f8e:	83 c4 08             	add    $0x8,%esp
  popal
  800f91:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
  addl $0x4, %esp
  800f92:	83 c4 04             	add    $0x4,%esp
  popfl
  800f95:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
  movl (%esp), %esp
  800f96:	8b 24 24             	mov    (%esp),%esp

  // Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  ret
  800f99:	c3                   	ret    
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
  801075:	ba c4 25 80 00       	mov    $0x8025c4,%edx
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
  8010a5:	c7 04 24 44 25 80 00 	movl   $0x802544,(%esp)
  8010ac:	e8 89 f1 ff ff       	call   80023a <cprintf>
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
  801134:	e8 f1 fb ff ff       	call   800d2a <sys_page_unmap>
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
  801232:	e8 a0 fa ff ff       	call   800cd7 <sys_page_map>
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
  80126d:	e8 65 fa ff ff       	call   800cd7 <sys_page_map>
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
  801286:	e8 9f fa ff ff       	call   800d2a <sys_page_unmap>
  sys_page_unmap(0, nva);
  80128b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80128f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801296:	e8 8f fa ff ff       	call   800d2a <sys_page_unmap>
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
  8012fa:	c7 04 24 88 25 80 00 	movl   $0x802588,(%esp)
  801301:	e8 34 ef ff ff       	call   80023a <cprintf>
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
  8013d2:	c7 04 24 a4 25 80 00 	movl   $0x8025a4,(%esp)
  8013d9:	e8 5c ee ff ff       	call   80023a <cprintf>
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
  80148b:	c7 04 24 64 25 80 00 	movl   $0x802564,(%esp)
  801492:	e8 a3 ed ff ff       	call   80023a <cprintf>
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
  80159a:	e8 48 08 00 00       	call   801de7 <ipc_find_env>
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
  8015c0:	e8 b7 07 00 00       	call   801d7c <ipc_send>
  return ipc_recv(NULL, dstva, NULL);
  8015c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015cc:	00 
  8015cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015d8:	e8 19 07 00 00       	call   801cf6 <ipc_recv>
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
  801665:	e8 fd f1 ff ff       	call   800867 <strcpy>
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
  8016c4:	e8 3b f3 ff ff       	call   800a04 <memmove>

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
  80171b:	e8 e4 f2 ff ff       	call   800a04 <memmove>
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
  801735:	e8 f6 f0 ff ff       	call   800830 <strlen>
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
  80175d:	e8 05 f1 ff ff       	call   800867 <strcpy>
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
  8017db:	c7 44 24 04 d4 25 80 	movl   $0x8025d4,0x4(%esp)
  8017e2:	00 
  8017e3:	89 1c 24             	mov    %ebx,(%esp)
  8017e6:	e8 7c f0 ff ff       	call   800867 <strcpy>
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
  80182b:	e8 fa f4 ff ff       	call   800d2a <sys_page_unmap>
  return sys_page_unmap(0, fd2data(fd));
  801830:	89 1c 24             	mov    %ebx,(%esp)
  801833:	e8 78 f7 ff ff       	call   800fb0 <fd2data>
  801838:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801843:	e8 e2 f4 ff ff       	call   800d2a <sys_page_unmap>
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
  801867:	e8 b3 05 00 00       	call   801e1f <pageref>
  80186c:	89 c7                	mov    %eax,%edi
  80186e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801871:	89 04 24             	mov    %eax,(%esp)
  801874:	e8 a6 05 00 00       	call   801e1f <pageref>
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
  8018a1:	c7 04 24 db 25 80 00 	movl   $0x8025db,(%esp)
  8018a8:	e8 8d e9 ff ff       	call   80023a <cprintf>
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
  8018e1:	e8 7e f3 ff ff       	call   800c64 <sys_yield>
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
  801961:	e8 fe f2 ff ff       	call   800c64 <sys_yield>
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
  8019d2:	e8 ac f2 ff ff       	call   800c83 <sys_page_alloc>
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
  801a0c:	e8 72 f2 ff ff       	call   800c83 <sys_page_alloc>
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
  801a3b:	e8 43 f2 ff ff       	call   800c83 <sys_page_alloc>
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
  801a74:	e8 5e f2 ff ff       	call   800cd7 <sys_page_map>
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
  801adc:	e8 49 f2 ff ff       	call   800d2a <sys_page_unmap>
err2:
  sys_page_unmap(0, fd1);
  801ae1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ae4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aef:	e8 36 f2 ff ff       	call   800d2a <sys_page_unmap>
err1:
  sys_page_unmap(0, fd0);
  801af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801afb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b02:	e8 23 f2 ff ff       	call   800d2a <sys_page_unmap>
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
  801b60:	c7 44 24 04 f3 25 80 	movl   $0x8025f3,0x4(%esp)
  801b67:	00 
  801b68:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b6b:	89 04 24             	mov    %eax,(%esp)
  801b6e:	e8 f4 ec ff ff       	call   800867 <strcpy>
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
  801bb1:	e8 4e ee ff ff       	call   800a04 <memmove>
    sys_cputs(buf, m);
  801bb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bba:	89 3c 24             	mov    %edi,(%esp)
  801bbd:	e8 f4 ef ff ff       	call   800bb6 <sys_cputs>
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
  801be9:	e8 76 f0 ff ff       	call   800c64 <sys_yield>
  int c;

  if (n == 0)
    return 0;

  while ((c = sys_cgetc()) == 0)
  801bee:	66 90                	xchg   %ax,%ax
  801bf0:	e8 df ef ff ff       	call   800bd4 <sys_cgetc>
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
  801c2f:	e8 82 ef ff ff       	call   800bb6 <sys_cputs>
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
  801cc8:	e8 b6 ef ff ff       	call   800c83 <sys_page_alloc>
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

00801cf6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801cf6:	55                   	push   %ebp
  801cf7:	89 e5                	mov    %esp,%ebp
  801cf9:	56                   	push   %esi
  801cfa:	53                   	push   %ebx
  801cfb:	83 ec 10             	sub    $0x10,%esp
  801cfe:	8b 75 08             	mov    0x8(%ebp),%esi
  801d01:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d04:	8b 5d 10             	mov    0x10(%ebp),%ebx
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;
  801d07:	85 c0                	test   %eax,%eax
  801d09:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801d0e:	0f 44 c2             	cmove  %edx,%eax
  if ((r = sys_ipc_recv(pg)) < 0) {
  801d11:	89 04 24             	mov    %eax,(%esp)
  801d14:	e8 80 f1 ff ff       	call   800e99 <sys_ipc_recv>
  801d19:	85 c0                	test   %eax,%eax
  801d1b:	79 34                	jns    801d51 <ipc_recv+0x5b>
    if (from_env_store)
  801d1d:	85 f6                	test   %esi,%esi
  801d1f:	74 06                	je     801d27 <ipc_recv+0x31>
      *from_env_store = 0;
  801d21:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (perm_store)
  801d27:	85 db                	test   %ebx,%ebx
  801d29:	74 06                	je     801d31 <ipc_recv+0x3b>
      *perm_store = 0;
  801d2b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    panic("sys_ipc_recv: %e", r);
  801d31:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d35:	c7 44 24 08 ff 25 80 	movl   $0x8025ff,0x8(%esp)
  801d3c:	00 
  801d3d:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801d44:	00 
  801d45:	c7 04 24 10 26 80 00 	movl   $0x802610,(%esp)
  801d4c:	e8 f0 e3 ff ff       	call   800141 <_panic>
  }

  if (from_env_store)
  801d51:	85 f6                	test   %esi,%esi
  801d53:	74 0a                	je     801d5f <ipc_recv+0x69>
    *from_env_store = thisenv->env_ipc_from;
  801d55:	a1 04 40 80 00       	mov    0x804004,%eax
  801d5a:	8b 40 74             	mov    0x74(%eax),%eax
  801d5d:	89 06                	mov    %eax,(%esi)
  if (perm_store)
  801d5f:	85 db                	test   %ebx,%ebx
  801d61:	74 0a                	je     801d6d <ipc_recv+0x77>
    *perm_store |= thisenv->env_ipc_perm;
  801d63:	a1 04 40 80 00       	mov    0x804004,%eax
  801d68:	8b 40 78             	mov    0x78(%eax),%eax
  801d6b:	09 03                	or     %eax,(%ebx)

  return thisenv->env_ipc_value;
  801d6d:	a1 04 40 80 00       	mov    0x804004,%eax
  801d72:	8b 40 70             	mov    0x70(%eax),%eax

}
  801d75:	83 c4 10             	add    $0x10,%esp
  801d78:	5b                   	pop    %ebx
  801d79:	5e                   	pop    %esi
  801d7a:	5d                   	pop    %ebp
  801d7b:	c3                   	ret    

00801d7c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d7c:	55                   	push   %ebp
  801d7d:	89 e5                	mov    %esp,%ebp
  801d7f:	57                   	push   %edi
  801d80:	56                   	push   %esi
  801d81:	53                   	push   %ebx
  801d82:	83 ec 1c             	sub    $0x1c,%esp
  801d85:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d88:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;
  801d8e:	85 db                	test   %ebx,%ebx
  801d90:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801d95:	0f 44 d8             	cmove  %eax,%ebx

  while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801d98:	eb 2a                	jmp    801dc4 <ipc_send+0x48>
    if (r != -E_IPC_NOT_RECV)
  801d9a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d9d:	74 20                	je     801dbf <ipc_send+0x43>
      panic("ipc_send: %e", r);
  801d9f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801da3:	c7 44 24 08 1a 26 80 	movl   $0x80261a,0x8(%esp)
  801daa:	00 
  801dab:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801db2:	00 
  801db3:	c7 04 24 10 26 80 00 	movl   $0x802610,(%esp)
  801dba:	e8 82 e3 ff ff       	call   800141 <_panic>
    sys_yield();
  801dbf:	e8 a0 ee ff ff       	call   800c64 <sys_yield>
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;

  while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801dc4:	8b 45 14             	mov    0x14(%ebp),%eax
  801dc7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dcb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dcf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dd3:	89 3c 24             	mov    %edi,(%esp)
  801dd6:	e8 9b f0 ff ff       	call   800e76 <sys_ipc_try_send>
  801ddb:	85 c0                	test   %eax,%eax
  801ddd:	78 bb                	js     801d9a <ipc_send+0x1e>
    if (r != -E_IPC_NOT_RECV)
      panic("ipc_send: %e", r);
    sys_yield();
  }
}
  801ddf:	83 c4 1c             	add    $0x1c,%esp
  801de2:	5b                   	pop    %ebx
  801de3:	5e                   	pop    %esi
  801de4:	5f                   	pop    %edi
  801de5:	5d                   	pop    %ebp
  801de6:	c3                   	ret    

00801de7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801de7:	55                   	push   %ebp
  801de8:	89 e5                	mov    %esp,%ebp
  801dea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int i;

  for (i = 0; i < NENV; i++)
  801ded:	b8 00 00 00 00       	mov    $0x0,%eax
    if (envs[i].env_type == type)
  801df2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801df5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801dfb:	8b 52 50             	mov    0x50(%edx),%edx
  801dfe:	39 ca                	cmp    %ecx,%edx
  801e00:	75 0d                	jne    801e0f <ipc_find_env+0x28>
      return envs[i].env_id;
  801e02:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e05:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801e0a:	8b 40 40             	mov    0x40(%eax),%eax
  801e0d:	eb 0e                	jmp    801e1d <ipc_find_env+0x36>
envid_t
ipc_find_env(enum EnvType type)
{
  int i;

  for (i = 0; i < NENV; i++)
  801e0f:	83 c0 01             	add    $0x1,%eax
  801e12:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e17:	75 d9                	jne    801df2 <ipc_find_env+0xb>
    if (envs[i].env_type == type)
      return envs[i].env_id;
  return 0;
  801e19:	66 b8 00 00          	mov    $0x0,%ax
}
  801e1d:	5d                   	pop    %ebp
  801e1e:	c3                   	ret    

00801e1f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e1f:	55                   	push   %ebp
  801e20:	89 e5                	mov    %esp,%ebp
  801e22:	8b 55 08             	mov    0x8(%ebp),%edx
  pte_t pte;

  if (!(uvpd[PDX(v)] & PTE_P))
  801e25:	89 d0                	mov    %edx,%eax
  801e27:	c1 e8 16             	shr    $0x16,%eax
  801e2a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
    return 0;
  801e31:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
  pte_t pte;

  if (!(uvpd[PDX(v)] & PTE_P))
  801e36:	f6 c1 01             	test   $0x1,%cl
  801e39:	74 1d                	je     801e58 <pageref+0x39>
    return 0;
  pte = uvpt[PGNUM(v)];
  801e3b:	c1 ea 0c             	shr    $0xc,%edx
  801e3e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  if (!(pte & PTE_P))
  801e45:	f6 c2 01             	test   $0x1,%dl
  801e48:	74 0e                	je     801e58 <pageref+0x39>
    return 0;
  return pages[PGNUM(pte)].pp_ref;
  801e4a:	c1 ea 0c             	shr    $0xc,%edx
  801e4d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e54:	ef 
  801e55:	0f b7 c0             	movzwl %ax,%eax
}
  801e58:	5d                   	pop    %ebp
  801e59:	c3                   	ret    
  801e5a:	66 90                	xchg   %ax,%ax
  801e5c:	66 90                	xchg   %ax,%ax
  801e5e:	66 90                	xchg   %ax,%ax

00801e60 <__udivdi3>:
  801e60:	55                   	push   %ebp
  801e61:	57                   	push   %edi
  801e62:	56                   	push   %esi
  801e63:	83 ec 0c             	sub    $0xc,%esp
  801e66:	8b 44 24 28          	mov    0x28(%esp),%eax
  801e6a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801e6e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801e72:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801e76:	85 c0                	test   %eax,%eax
  801e78:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e7c:	89 ea                	mov    %ebp,%edx
  801e7e:	89 0c 24             	mov    %ecx,(%esp)
  801e81:	75 2d                	jne    801eb0 <__udivdi3+0x50>
  801e83:	39 e9                	cmp    %ebp,%ecx
  801e85:	77 61                	ja     801ee8 <__udivdi3+0x88>
  801e87:	85 c9                	test   %ecx,%ecx
  801e89:	89 ce                	mov    %ecx,%esi
  801e8b:	75 0b                	jne    801e98 <__udivdi3+0x38>
  801e8d:	b8 01 00 00 00       	mov    $0x1,%eax
  801e92:	31 d2                	xor    %edx,%edx
  801e94:	f7 f1                	div    %ecx
  801e96:	89 c6                	mov    %eax,%esi
  801e98:	31 d2                	xor    %edx,%edx
  801e9a:	89 e8                	mov    %ebp,%eax
  801e9c:	f7 f6                	div    %esi
  801e9e:	89 c5                	mov    %eax,%ebp
  801ea0:	89 f8                	mov    %edi,%eax
  801ea2:	f7 f6                	div    %esi
  801ea4:	89 ea                	mov    %ebp,%edx
  801ea6:	83 c4 0c             	add    $0xc,%esp
  801ea9:	5e                   	pop    %esi
  801eaa:	5f                   	pop    %edi
  801eab:	5d                   	pop    %ebp
  801eac:	c3                   	ret    
  801ead:	8d 76 00             	lea    0x0(%esi),%esi
  801eb0:	39 e8                	cmp    %ebp,%eax
  801eb2:	77 24                	ja     801ed8 <__udivdi3+0x78>
  801eb4:	0f bd e8             	bsr    %eax,%ebp
  801eb7:	83 f5 1f             	xor    $0x1f,%ebp
  801eba:	75 3c                	jne    801ef8 <__udivdi3+0x98>
  801ebc:	8b 74 24 04          	mov    0x4(%esp),%esi
  801ec0:	39 34 24             	cmp    %esi,(%esp)
  801ec3:	0f 86 9f 00 00 00    	jbe    801f68 <__udivdi3+0x108>
  801ec9:	39 d0                	cmp    %edx,%eax
  801ecb:	0f 82 97 00 00 00    	jb     801f68 <__udivdi3+0x108>
  801ed1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ed8:	31 d2                	xor    %edx,%edx
  801eda:	31 c0                	xor    %eax,%eax
  801edc:	83 c4 0c             	add    $0xc,%esp
  801edf:	5e                   	pop    %esi
  801ee0:	5f                   	pop    %edi
  801ee1:	5d                   	pop    %ebp
  801ee2:	c3                   	ret    
  801ee3:	90                   	nop
  801ee4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ee8:	89 f8                	mov    %edi,%eax
  801eea:	f7 f1                	div    %ecx
  801eec:	31 d2                	xor    %edx,%edx
  801eee:	83 c4 0c             	add    $0xc,%esp
  801ef1:	5e                   	pop    %esi
  801ef2:	5f                   	pop    %edi
  801ef3:	5d                   	pop    %ebp
  801ef4:	c3                   	ret    
  801ef5:	8d 76 00             	lea    0x0(%esi),%esi
  801ef8:	89 e9                	mov    %ebp,%ecx
  801efa:	8b 3c 24             	mov    (%esp),%edi
  801efd:	d3 e0                	shl    %cl,%eax
  801eff:	89 c6                	mov    %eax,%esi
  801f01:	b8 20 00 00 00       	mov    $0x20,%eax
  801f06:	29 e8                	sub    %ebp,%eax
  801f08:	89 c1                	mov    %eax,%ecx
  801f0a:	d3 ef                	shr    %cl,%edi
  801f0c:	89 e9                	mov    %ebp,%ecx
  801f0e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801f12:	8b 3c 24             	mov    (%esp),%edi
  801f15:	09 74 24 08          	or     %esi,0x8(%esp)
  801f19:	89 d6                	mov    %edx,%esi
  801f1b:	d3 e7                	shl    %cl,%edi
  801f1d:	89 c1                	mov    %eax,%ecx
  801f1f:	89 3c 24             	mov    %edi,(%esp)
  801f22:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801f26:	d3 ee                	shr    %cl,%esi
  801f28:	89 e9                	mov    %ebp,%ecx
  801f2a:	d3 e2                	shl    %cl,%edx
  801f2c:	89 c1                	mov    %eax,%ecx
  801f2e:	d3 ef                	shr    %cl,%edi
  801f30:	09 d7                	or     %edx,%edi
  801f32:	89 f2                	mov    %esi,%edx
  801f34:	89 f8                	mov    %edi,%eax
  801f36:	f7 74 24 08          	divl   0x8(%esp)
  801f3a:	89 d6                	mov    %edx,%esi
  801f3c:	89 c7                	mov    %eax,%edi
  801f3e:	f7 24 24             	mull   (%esp)
  801f41:	39 d6                	cmp    %edx,%esi
  801f43:	89 14 24             	mov    %edx,(%esp)
  801f46:	72 30                	jb     801f78 <__udivdi3+0x118>
  801f48:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f4c:	89 e9                	mov    %ebp,%ecx
  801f4e:	d3 e2                	shl    %cl,%edx
  801f50:	39 c2                	cmp    %eax,%edx
  801f52:	73 05                	jae    801f59 <__udivdi3+0xf9>
  801f54:	3b 34 24             	cmp    (%esp),%esi
  801f57:	74 1f                	je     801f78 <__udivdi3+0x118>
  801f59:	89 f8                	mov    %edi,%eax
  801f5b:	31 d2                	xor    %edx,%edx
  801f5d:	e9 7a ff ff ff       	jmp    801edc <__udivdi3+0x7c>
  801f62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f68:	31 d2                	xor    %edx,%edx
  801f6a:	b8 01 00 00 00       	mov    $0x1,%eax
  801f6f:	e9 68 ff ff ff       	jmp    801edc <__udivdi3+0x7c>
  801f74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f78:	8d 47 ff             	lea    -0x1(%edi),%eax
  801f7b:	31 d2                	xor    %edx,%edx
  801f7d:	83 c4 0c             	add    $0xc,%esp
  801f80:	5e                   	pop    %esi
  801f81:	5f                   	pop    %edi
  801f82:	5d                   	pop    %ebp
  801f83:	c3                   	ret    
  801f84:	66 90                	xchg   %ax,%ax
  801f86:	66 90                	xchg   %ax,%ax
  801f88:	66 90                	xchg   %ax,%ax
  801f8a:	66 90                	xchg   %ax,%ax
  801f8c:	66 90                	xchg   %ax,%ax
  801f8e:	66 90                	xchg   %ax,%ax

00801f90 <__umoddi3>:
  801f90:	55                   	push   %ebp
  801f91:	57                   	push   %edi
  801f92:	56                   	push   %esi
  801f93:	83 ec 14             	sub    $0x14,%esp
  801f96:	8b 44 24 28          	mov    0x28(%esp),%eax
  801f9a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801f9e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801fa2:	89 c7                	mov    %eax,%edi
  801fa4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fa8:	8b 44 24 30          	mov    0x30(%esp),%eax
  801fac:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801fb0:	89 34 24             	mov    %esi,(%esp)
  801fb3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fb7:	85 c0                	test   %eax,%eax
  801fb9:	89 c2                	mov    %eax,%edx
  801fbb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801fbf:	75 17                	jne    801fd8 <__umoddi3+0x48>
  801fc1:	39 fe                	cmp    %edi,%esi
  801fc3:	76 4b                	jbe    802010 <__umoddi3+0x80>
  801fc5:	89 c8                	mov    %ecx,%eax
  801fc7:	89 fa                	mov    %edi,%edx
  801fc9:	f7 f6                	div    %esi
  801fcb:	89 d0                	mov    %edx,%eax
  801fcd:	31 d2                	xor    %edx,%edx
  801fcf:	83 c4 14             	add    $0x14,%esp
  801fd2:	5e                   	pop    %esi
  801fd3:	5f                   	pop    %edi
  801fd4:	5d                   	pop    %ebp
  801fd5:	c3                   	ret    
  801fd6:	66 90                	xchg   %ax,%ax
  801fd8:	39 f8                	cmp    %edi,%eax
  801fda:	77 54                	ja     802030 <__umoddi3+0xa0>
  801fdc:	0f bd e8             	bsr    %eax,%ebp
  801fdf:	83 f5 1f             	xor    $0x1f,%ebp
  801fe2:	75 5c                	jne    802040 <__umoddi3+0xb0>
  801fe4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801fe8:	39 3c 24             	cmp    %edi,(%esp)
  801feb:	0f 87 e7 00 00 00    	ja     8020d8 <__umoddi3+0x148>
  801ff1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ff5:	29 f1                	sub    %esi,%ecx
  801ff7:	19 c7                	sbb    %eax,%edi
  801ff9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ffd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802001:	8b 44 24 08          	mov    0x8(%esp),%eax
  802005:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802009:	83 c4 14             	add    $0x14,%esp
  80200c:	5e                   	pop    %esi
  80200d:	5f                   	pop    %edi
  80200e:	5d                   	pop    %ebp
  80200f:	c3                   	ret    
  802010:	85 f6                	test   %esi,%esi
  802012:	89 f5                	mov    %esi,%ebp
  802014:	75 0b                	jne    802021 <__umoddi3+0x91>
  802016:	b8 01 00 00 00       	mov    $0x1,%eax
  80201b:	31 d2                	xor    %edx,%edx
  80201d:	f7 f6                	div    %esi
  80201f:	89 c5                	mov    %eax,%ebp
  802021:	8b 44 24 04          	mov    0x4(%esp),%eax
  802025:	31 d2                	xor    %edx,%edx
  802027:	f7 f5                	div    %ebp
  802029:	89 c8                	mov    %ecx,%eax
  80202b:	f7 f5                	div    %ebp
  80202d:	eb 9c                	jmp    801fcb <__umoddi3+0x3b>
  80202f:	90                   	nop
  802030:	89 c8                	mov    %ecx,%eax
  802032:	89 fa                	mov    %edi,%edx
  802034:	83 c4 14             	add    $0x14,%esp
  802037:	5e                   	pop    %esi
  802038:	5f                   	pop    %edi
  802039:	5d                   	pop    %ebp
  80203a:	c3                   	ret    
  80203b:	90                   	nop
  80203c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802040:	8b 04 24             	mov    (%esp),%eax
  802043:	be 20 00 00 00       	mov    $0x20,%esi
  802048:	89 e9                	mov    %ebp,%ecx
  80204a:	29 ee                	sub    %ebp,%esi
  80204c:	d3 e2                	shl    %cl,%edx
  80204e:	89 f1                	mov    %esi,%ecx
  802050:	d3 e8                	shr    %cl,%eax
  802052:	89 e9                	mov    %ebp,%ecx
  802054:	89 44 24 04          	mov    %eax,0x4(%esp)
  802058:	8b 04 24             	mov    (%esp),%eax
  80205b:	09 54 24 04          	or     %edx,0x4(%esp)
  80205f:	89 fa                	mov    %edi,%edx
  802061:	d3 e0                	shl    %cl,%eax
  802063:	89 f1                	mov    %esi,%ecx
  802065:	89 44 24 08          	mov    %eax,0x8(%esp)
  802069:	8b 44 24 10          	mov    0x10(%esp),%eax
  80206d:	d3 ea                	shr    %cl,%edx
  80206f:	89 e9                	mov    %ebp,%ecx
  802071:	d3 e7                	shl    %cl,%edi
  802073:	89 f1                	mov    %esi,%ecx
  802075:	d3 e8                	shr    %cl,%eax
  802077:	89 e9                	mov    %ebp,%ecx
  802079:	09 f8                	or     %edi,%eax
  80207b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80207f:	f7 74 24 04          	divl   0x4(%esp)
  802083:	d3 e7                	shl    %cl,%edi
  802085:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802089:	89 d7                	mov    %edx,%edi
  80208b:	f7 64 24 08          	mull   0x8(%esp)
  80208f:	39 d7                	cmp    %edx,%edi
  802091:	89 c1                	mov    %eax,%ecx
  802093:	89 14 24             	mov    %edx,(%esp)
  802096:	72 2c                	jb     8020c4 <__umoddi3+0x134>
  802098:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80209c:	72 22                	jb     8020c0 <__umoddi3+0x130>
  80209e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8020a2:	29 c8                	sub    %ecx,%eax
  8020a4:	19 d7                	sbb    %edx,%edi
  8020a6:	89 e9                	mov    %ebp,%ecx
  8020a8:	89 fa                	mov    %edi,%edx
  8020aa:	d3 e8                	shr    %cl,%eax
  8020ac:	89 f1                	mov    %esi,%ecx
  8020ae:	d3 e2                	shl    %cl,%edx
  8020b0:	89 e9                	mov    %ebp,%ecx
  8020b2:	d3 ef                	shr    %cl,%edi
  8020b4:	09 d0                	or     %edx,%eax
  8020b6:	89 fa                	mov    %edi,%edx
  8020b8:	83 c4 14             	add    $0x14,%esp
  8020bb:	5e                   	pop    %esi
  8020bc:	5f                   	pop    %edi
  8020bd:	5d                   	pop    %ebp
  8020be:	c3                   	ret    
  8020bf:	90                   	nop
  8020c0:	39 d7                	cmp    %edx,%edi
  8020c2:	75 da                	jne    80209e <__umoddi3+0x10e>
  8020c4:	8b 14 24             	mov    (%esp),%edx
  8020c7:	89 c1                	mov    %eax,%ecx
  8020c9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8020cd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8020d1:	eb cb                	jmp    80209e <__umoddi3+0x10e>
  8020d3:	90                   	nop
  8020d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020d8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8020dc:	0f 82 0f ff ff ff    	jb     801ff1 <__umoddi3+0x61>
  8020e2:	e9 1a ff ff ff       	jmp    802001 <__umoddi3+0x71>
