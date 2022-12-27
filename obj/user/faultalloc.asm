
obj/user/faultalloc.debug:     file format elf32-i386


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
  80002c:	e8 c3 00 00 00       	call   8000f4 <libmain>
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
  80004a:	e8 ff 01 00 00       	call   80024e <cprintf>
  if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800056:	00 
  800057:	89 d8                	mov    %ebx,%eax
  800059:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800062:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800069:	e8 25 0c 00 00       	call   800c93 <sys_page_alloc>
  80006e:	85 c0                	test   %eax,%eax
  800070:	79 24                	jns    800096 <handler+0x63>
                          PTE_P|PTE_U|PTE_W)) < 0)
    panic("allocating at %x in page fault handler: %e", addr, r);
  800072:	89 44 24 10          	mov    %eax,0x10(%esp)
  800076:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007a:	c7 44 24 08 20 21 80 	movl   $0x802120,0x8(%esp)
  800081:	00 
  800082:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  800089:	00 
  80008a:	c7 04 24 0a 21 80 00 	movl   $0x80210a,(%esp)
  800091:	e8 bf 00 00 00       	call   800155 <_panic>
  snprintf((char*)addr, 100, "this string was faulted in at %x", addr);
  800096:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009a:	c7 44 24 08 4c 21 80 	movl   $0x80214c,0x8(%esp)
  8000a1:	00 
  8000a2:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000a9:	00 
  8000aa:	89 1c 24             	mov    %ebx,(%esp)
  8000ad:	e8 58 07 00 00       	call   80080a <snprintf>
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
  8000c5:	e8 31 0e 00 00       	call   800efb <set_pgfault_handler>
  cprintf("%s\n", (char*)0xDeadBeef);
  8000ca:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  8000d1:	de 
  8000d2:	c7 04 24 1c 21 80 00 	movl   $0x80211c,(%esp)
  8000d9:	e8 70 01 00 00       	call   80024e <cprintf>
  cprintf("%s\n", (char*)0xCafeBffe);
  8000de:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  8000e5:	ca 
  8000e6:	c7 04 24 1c 21 80 00 	movl   $0x80211c,(%esp)
  8000ed:	e8 5c 01 00 00       	call   80024e <cprintf>
}
  8000f2:	c9                   	leave  
  8000f3:	c3                   	ret    

008000f4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	83 ec 10             	sub    $0x10,%esp
  8000fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ff:	8b 75 0c             	mov    0xc(%ebp),%esi
  // set thisenv to point at our Env structure in envs[].
  // LAB 3: Your code here.
  thisenv = envs + ENVX(sys_getenvid());
  800102:	e8 4e 0b 00 00       	call   800c55 <sys_getenvid>
  800107:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800114:	a3 04 40 80 00       	mov    %eax,0x804004

  // save the name of the program so that panic() can use it
  if (argc > 0)
  800119:	85 db                	test   %ebx,%ebx
  80011b:	7e 07                	jle    800124 <libmain+0x30>
    binaryname = argv[0];
  80011d:	8b 06                	mov    (%esi),%eax
  80011f:	a3 00 30 80 00       	mov    %eax,0x803000

  // call user main routine
  umain(argc, argv);
  800124:	89 74 24 04          	mov    %esi,0x4(%esp)
  800128:	89 1c 24             	mov    %ebx,(%esp)
  80012b:	e8 88 ff ff ff       	call   8000b8 <umain>

  // exit gracefully
  exit();
  800130:	e8 07 00 00 00       	call   80013c <exit>
}
  800135:	83 c4 10             	add    $0x10,%esp
  800138:	5b                   	pop    %ebx
  800139:	5e                   	pop    %esi
  80013a:	5d                   	pop    %ebp
  80013b:	c3                   	ret    

0080013c <exit>:
#include <inc/lib.h>

void
exit(void)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	83 ec 18             	sub    $0x18,%esp
  close_all();
  800142:	e8 3e 10 00 00       	call   801185 <close_all>
  sys_env_destroy(0);
  800147:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80014e:	e8 b0 0a 00 00       	call   800c03 <sys_env_destroy>
}
  800153:	c9                   	leave  
  800154:	c3                   	ret    

00800155 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	56                   	push   %esi
  800159:	53                   	push   %ebx
  80015a:	83 ec 20             	sub    $0x20,%esp
  va_list ap;

  va_start(ap, fmt);
  80015d:	8d 5d 14             	lea    0x14(%ebp),%ebx

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  800160:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800166:	e8 ea 0a 00 00       	call   800c55 <sys_getenvid>
  80016b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80016e:	89 54 24 10          	mov    %edx,0x10(%esp)
  800172:	8b 55 08             	mov    0x8(%ebp),%edx
  800175:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800179:	89 74 24 08          	mov    %esi,0x8(%esp)
  80017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800181:	c7 04 24 78 21 80 00 	movl   $0x802178,(%esp)
  800188:	e8 c1 00 00 00       	call   80024e <cprintf>
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  80018d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800191:	8b 45 10             	mov    0x10(%ebp),%eax
  800194:	89 04 24             	mov    %eax,(%esp)
  800197:	e8 51 00 00 00       	call   8001ed <vcprintf>
  cprintf("\n");
  80019c:	c7 04 24 ec 25 80 00 	movl   $0x8025ec,(%esp)
  8001a3:	e8 a6 00 00 00       	call   80024e <cprintf>

  // Cause a breakpoint exception
  while (1)
    asm volatile ("int3");
  8001a8:	cc                   	int3   
  8001a9:	eb fd                	jmp    8001a8 <_panic+0x53>

008001ab <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 14             	sub    $0x14,%esp
  8001b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  b->buf[b->idx++] = ch;
  8001b5:	8b 13                	mov    (%ebx),%edx
  8001b7:	8d 42 01             	lea    0x1(%edx),%eax
  8001ba:	89 03                	mov    %eax,(%ebx)
  8001bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001bf:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
  if (b->idx == 256-1) {
  8001c3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c8:	75 19                	jne    8001e3 <putch+0x38>
    sys_cputs(b->buf, b->idx);
  8001ca:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001d1:	00 
  8001d2:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d5:	89 04 24             	mov    %eax,(%esp)
  8001d8:	e8 e9 09 00 00       	call   800bc6 <sys_cputs>
    b->idx = 0;
  8001dd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  }
  b->cnt++;
  8001e3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e7:	83 c4 14             	add    $0x14,%esp
  8001ea:	5b                   	pop    %ebx
  8001eb:	5d                   	pop    %ebp
  8001ec:	c3                   	ret    

008001ed <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	81 ec 28 01 00 00    	sub    $0x128,%esp
  struct printbuf b;

  b.idx = 0;
  8001f6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001fd:	00 00 00 
  b.cnt = 0;
  800200:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800207:	00 00 00 
  vprintfmt((void*)putch, &b, fmt, ap);
  80020a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800211:	8b 45 08             	mov    0x8(%ebp),%eax
  800214:	89 44 24 08          	mov    %eax,0x8(%esp)
  800218:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80021e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800222:	c7 04 24 ab 01 80 00 	movl   $0x8001ab,(%esp)
  800229:	e8 b0 01 00 00       	call   8003de <vprintfmt>
  sys_cputs(b.buf, b.idx);
  80022e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800234:	89 44 24 04          	mov    %eax,0x4(%esp)
  800238:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80023e:	89 04 24             	mov    %eax,(%esp)
  800241:	e8 80 09 00 00       	call   800bc6 <sys_cputs>

  return b.cnt;
}
  800246:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024c:	c9                   	leave  
  80024d:	c3                   	ret    

0080024e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800254:	8d 45 0c             	lea    0xc(%ebp),%eax
  cnt = vcprintf(fmt, ap);
  800257:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025b:	8b 45 08             	mov    0x8(%ebp),%eax
  80025e:	89 04 24             	mov    %eax,(%esp)
  800261:	e8 87 ff ff ff       	call   8001ed <vcprintf>
  va_end(ap);

  return cnt;
}
  800266:	c9                   	leave  
  800267:	c3                   	ret    
  800268:	66 90                	xchg   %ax,%ax
  80026a:	66 90                	xchg   %ax,%ax
  80026c:	66 90                	xchg   %ax,%ax
  80026e:	66 90                	xchg   %ax,%ax

00800270 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
         unsigned long long num, unsigned base, int width, int padc)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 3c             	sub    $0x3c,%esp
  800279:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80027c:	89 d7                	mov    %edx,%edi
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800284:	8b 45 0c             	mov    0xc(%ebp),%eax
  800287:	89 c3                	mov    %eax,%ebx
  800289:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80028c:	8b 45 10             	mov    0x10(%ebp),%eax
  80028f:	8b 75 14             	mov    0x14(%ebp),%esi
  // first recursively print all preceding (more significant) digits
  if (num >= base)
  800292:	b9 00 00 00 00       	mov    $0x0,%ecx
  800297:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80029a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80029d:	39 d9                	cmp    %ebx,%ecx
  80029f:	72 05                	jb     8002a6 <printnum+0x36>
  8002a1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002a4:	77 69                	ja     80030f <printnum+0x9f>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002a9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002ad:	83 ee 01             	sub    $0x1,%esi
  8002b0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002bc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002c0:	89 c3                	mov    %eax,%ebx
  8002c2:	89 d6                	mov    %edx,%esi
  8002c4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002c7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002ca:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002ce:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d5:	89 04 24             	mov    %eax,(%esp)
  8002d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002df:	e8 8c 1b 00 00       	call   801e70 <__udivdi3>
  8002e4:	89 d9                	mov    %ebx,%ecx
  8002e6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002ea:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ee:	89 04 24             	mov    %eax,(%esp)
  8002f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f5:	89 fa                	mov    %edi,%edx
  8002f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002fa:	e8 71 ff ff ff       	call   800270 <printnum>
  8002ff:	eb 1b                	jmp    80031c <printnum+0xac>
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
      putch(padc, putdat);
  800301:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800305:	8b 45 18             	mov    0x18(%ebp),%eax
  800308:	89 04 24             	mov    %eax,(%esp)
  80030b:	ff d3                	call   *%ebx
  80030d:	eb 03                	jmp    800312 <printnum+0xa2>
  80030f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  // first recursively print all preceding (more significant) digits
  if (num >= base)
    printnum(putch, putdat, num / base, base, width - 1, padc);
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
  800312:	83 ee 01             	sub    $0x1,%esi
  800315:	85 f6                	test   %esi,%esi
  800317:	7f e8                	jg     800301 <printnum+0x91>
  800319:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
      putch(padc, putdat);
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  80031c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800320:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800324:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800327:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80032a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80032e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800332:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800335:	89 04 24             	mov    %eax,(%esp)
  800338:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80033b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033f:	e8 5c 1c 00 00       	call   801fa0 <__umoddi3>
  800344:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800348:	0f be 80 9b 21 80 00 	movsbl 0x80219b(%eax),%eax
  80034f:	89 04 24             	mov    %eax,(%esp)
  800352:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800355:	ff d0                	call   *%eax
}
  800357:	83 c4 3c             	add    $0x3c,%esp
  80035a:	5b                   	pop    %ebx
  80035b:	5e                   	pop    %esi
  80035c:	5f                   	pop    %edi
  80035d:	5d                   	pop    %ebp
  80035e:	c3                   	ret    

0080035f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
  if (lflag >= 2)
  800362:	83 fa 01             	cmp    $0x1,%edx
  800365:	7e 0e                	jle    800375 <getuint+0x16>
    return va_arg(*ap, unsigned long long);
  800367:	8b 10                	mov    (%eax),%edx
  800369:	8d 4a 08             	lea    0x8(%edx),%ecx
  80036c:	89 08                	mov    %ecx,(%eax)
  80036e:	8b 02                	mov    (%edx),%eax
  800370:	8b 52 04             	mov    0x4(%edx),%edx
  800373:	eb 22                	jmp    800397 <getuint+0x38>
  else if (lflag)
  800375:	85 d2                	test   %edx,%edx
  800377:	74 10                	je     800389 <getuint+0x2a>
    return va_arg(*ap, unsigned long);
  800379:	8b 10                	mov    (%eax),%edx
  80037b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037e:	89 08                	mov    %ecx,(%eax)
  800380:	8b 02                	mov    (%edx),%eax
  800382:	ba 00 00 00 00       	mov    $0x0,%edx
  800387:	eb 0e                	jmp    800397 <getuint+0x38>
  else
    return va_arg(*ap, unsigned int);
  800389:	8b 10                	mov    (%eax),%edx
  80038b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80038e:	89 08                	mov    %ecx,(%eax)
  800390:	8b 02                	mov    (%edx),%eax
  800392:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800397:	5d                   	pop    %ebp
  800398:	c3                   	ret    

00800399 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	8b 45 0c             	mov    0xc(%ebp),%eax
  b->cnt++;
  80039f:	83 40 08 01          	addl   $0x1,0x8(%eax)
  if (b->buf < b->ebuf)
  8003a3:	8b 10                	mov    (%eax),%edx
  8003a5:	3b 50 04             	cmp    0x4(%eax),%edx
  8003a8:	73 0a                	jae    8003b4 <sprintputch+0x1b>
    *b->buf++ = ch;
  8003aa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003ad:	89 08                	mov    %ecx,(%eax)
  8003af:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b2:	88 02                	mov    %al,(%edx)
}
  8003b4:	5d                   	pop    %ebp
  8003b5:	c3                   	ret    

008003b6 <printfmt>:
  }
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003b6:	55                   	push   %ebp
  8003b7:	89 e5                	mov    %esp,%ebp
  8003b9:	83 ec 18             	sub    $0x18,%esp
  va_list ap;

  va_start(ap, fmt);
  8003bc:	8d 45 14             	lea    0x14(%ebp),%eax
  vprintfmt(putch, putdat, fmt, ap);
  8003bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d4:	89 04 24             	mov    %eax,(%esp)
  8003d7:	e8 02 00 00 00       	call   8003de <vprintfmt>
  va_end(ap);
}
  8003dc:	c9                   	leave  
  8003dd:	c3                   	ret    

008003de <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003de:	55                   	push   %ebp
  8003df:	89 e5                	mov    %esp,%ebp
  8003e1:	57                   	push   %edi
  8003e2:	56                   	push   %esi
  8003e3:	53                   	push   %ebx
  8003e4:	83 ec 3c             	sub    $0x3c,%esp
  8003e7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003ed:	eb 14                	jmp    800403 <vprintfmt+0x25>
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
      if (ch == '\0')
  8003ef:	85 c0                	test   %eax,%eax
  8003f1:	0f 84 b3 03 00 00    	je     8007aa <vprintfmt+0x3cc>
        return;
      putch(ch, putdat);
  8003f7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003fb:	89 04 24             	mov    %eax,(%esp)
  8003fe:	ff 55 08             	call   *0x8(%ebp)
  unsigned long long num;
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
  800401:	89 f3                	mov    %esi,%ebx
  800403:	8d 73 01             	lea    0x1(%ebx),%esi
  800406:	0f b6 03             	movzbl (%ebx),%eax
  800409:	83 f8 25             	cmp    $0x25,%eax
  80040c:	75 e1                	jne    8003ef <vprintfmt+0x11>
  80040e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800412:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800419:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800420:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800427:	ba 00 00 00 00       	mov    $0x0,%edx
  80042c:	eb 1d                	jmp    80044b <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80042e:	89 de                	mov    %ebx,%esi

    // flag to pad on the right
    case '-':
      padc = '-';
  800430:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800434:	eb 15                	jmp    80044b <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  800436:	89 de                	mov    %ebx,%esi
      padc = '-';
      goto reswitch;

    // flag to pad with 0's instead of spaces
    case '0':
      padc = '0';
  800438:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80043c:	eb 0d                	jmp    80044b <vprintfmt+0x6d>
      altflag = 1;
      goto reswitch;

process_precision:
      if (width < 0)
        width = precision, precision = -1;
  80043e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800441:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800444:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80044b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80044e:	0f b6 0e             	movzbl (%esi),%ecx
  800451:	0f b6 c1             	movzbl %cl,%eax
  800454:	83 e9 23             	sub    $0x23,%ecx
  800457:	80 f9 55             	cmp    $0x55,%cl
  80045a:	0f 87 2a 03 00 00    	ja     80078a <vprintfmt+0x3ac>
  800460:	0f b6 c9             	movzbl %cl,%ecx
  800463:	ff 24 8d e0 22 80 00 	jmp    *0x8022e0(,%ecx,4)
  80046a:	89 de                	mov    %ebx,%esi
  80046c:	b9 00 00 00 00       	mov    $0x0,%ecx
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
        precision = precision * 10 + ch - '0';
  800471:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800474:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
        ch = *fmt;
  800478:	0f be 06             	movsbl (%esi),%eax
        if (ch < '0' || ch > '9')
  80047b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80047e:	83 fb 09             	cmp    $0x9,%ebx
  800481:	77 36                	ja     8004b9 <vprintfmt+0xdb>
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
  800483:	83 c6 01             	add    $0x1,%esi
        precision = precision * 10 + ch - '0';
        ch = *fmt;
        if (ch < '0' || ch > '9')
          break;
      }
  800486:	eb e9                	jmp    800471 <vprintfmt+0x93>
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
  800488:	8b 45 14             	mov    0x14(%ebp),%eax
  80048b:	8d 48 04             	lea    0x4(%eax),%ecx
  80048e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800491:	8b 00                	mov    (%eax),%eax
  800493:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  800496:	89 de                	mov    %ebx,%esi
      }
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
      goto process_precision;
  800498:	eb 22                	jmp    8004bc <vprintfmt+0xde>
  80049a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80049d:	85 c9                	test   %ecx,%ecx
  80049f:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a4:	0f 49 c1             	cmovns %ecx,%eax
  8004a7:	89 45 dc             	mov    %eax,-0x24(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8004aa:	89 de                	mov    %ebx,%esi
  8004ac:	eb 9d                	jmp    80044b <vprintfmt+0x6d>
  8004ae:	89 de                	mov    %ebx,%esi
      if (width < 0)
        width = 0;
      goto reswitch;

    case '#':
      altflag = 1;
  8004b0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
      goto reswitch;
  8004b7:	eb 92                	jmp    80044b <vprintfmt+0x6d>
  8004b9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

process_precision:
      if (width < 0)
  8004bc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004c0:	79 89                	jns    80044b <vprintfmt+0x6d>
  8004c2:	e9 77 ff ff ff       	jmp    80043e <vprintfmt+0x60>
        width = precision, precision = -1;
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
  8004c7:	83 c2 01             	add    $0x1,%edx
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8004ca:	89 de                	mov    %ebx,%esi
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
      goto reswitch;
  8004cc:	e9 7a ff ff ff       	jmp    80044b <vprintfmt+0x6d>

    // character
    case 'c':
      putch(va_arg(ap, int), putdat);
  8004d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d4:	8d 50 04             	lea    0x4(%eax),%edx
  8004d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004da:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004de:	8b 00                	mov    (%eax),%eax
  8004e0:	89 04 24             	mov    %eax,(%esp)
  8004e3:	ff 55 08             	call   *0x8(%ebp)
      break;
  8004e6:	e9 18 ff ff ff       	jmp    800403 <vprintfmt+0x25>

    // error message
    case 'e':
      err = va_arg(ap, int);
  8004eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ee:	8d 50 04             	lea    0x4(%eax),%edx
  8004f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f4:	8b 00                	mov    (%eax),%eax
  8004f6:	99                   	cltd   
  8004f7:	31 d0                	xor    %edx,%eax
  8004f9:	29 d0                	sub    %edx,%eax
      if (err < 0)
        err = -err;
      if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004fb:	83 f8 0f             	cmp    $0xf,%eax
  8004fe:	7f 0b                	jg     80050b <vprintfmt+0x12d>
  800500:	8b 14 85 40 24 80 00 	mov    0x802440(,%eax,4),%edx
  800507:	85 d2                	test   %edx,%edx
  800509:	75 20                	jne    80052b <vprintfmt+0x14d>
        printfmt(putch, putdat, "error %d", err);
  80050b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80050f:	c7 44 24 08 b3 21 80 	movl   $0x8021b3,0x8(%esp)
  800516:	00 
  800517:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80051b:	8b 45 08             	mov    0x8(%ebp),%eax
  80051e:	89 04 24             	mov    %eax,(%esp)
  800521:	e8 90 fe ff ff       	call   8003b6 <printfmt>
  800526:	e9 d8 fe ff ff       	jmp    800403 <vprintfmt+0x25>
      else
        printfmt(putch, putdat, "%s", p);
  80052b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80052f:	c7 44 24 08 bc 21 80 	movl   $0x8021bc,0x8(%esp)
  800536:	00 
  800537:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80053b:	8b 45 08             	mov    0x8(%ebp),%eax
  80053e:	89 04 24             	mov    %eax,(%esp)
  800541:	e8 70 fe ff ff       	call   8003b6 <printfmt>
  800546:	e9 b8 fe ff ff       	jmp    800403 <vprintfmt+0x25>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80054b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80054e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800551:	89 45 d0             	mov    %eax,-0x30(%ebp)
        printfmt(putch, putdat, "%s", p);
      break;

    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8d 50 04             	lea    0x4(%eax),%edx
  80055a:	89 55 14             	mov    %edx,0x14(%ebp)
  80055d:	8b 30                	mov    (%eax),%esi
        p = "(null)";
  80055f:	85 f6                	test   %esi,%esi
  800561:	b8 ac 21 80 00       	mov    $0x8021ac,%eax
  800566:	0f 44 f0             	cmove  %eax,%esi
      if (width > 0 && padc != '-')
  800569:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80056d:	0f 84 97 00 00 00    	je     80060a <vprintfmt+0x22c>
  800573:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800577:	0f 8e 9b 00 00 00    	jle    800618 <vprintfmt+0x23a>
        for (width -= strnlen(p, precision); width > 0; width--)
  80057d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800581:	89 34 24             	mov    %esi,(%esp)
  800584:	e8 cf 02 00 00       	call   800858 <strnlen>
  800589:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80058c:	29 c2                	sub    %eax,%edx
  80058e:	89 55 d0             	mov    %edx,-0x30(%ebp)
          putch(padc, putdat);
  800591:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800595:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800598:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80059b:	8b 75 08             	mov    0x8(%ebp),%esi
  80059e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005a1:	89 d3                	mov    %edx,%ebx
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
  8005a3:	eb 0f                	jmp    8005b4 <vprintfmt+0x1d6>
          putch(padc, putdat);
  8005a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005ac:	89 04 24             	mov    %eax,(%esp)
  8005af:	ff d6                	call   *%esi
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
  8005b1:	83 eb 01             	sub    $0x1,%ebx
  8005b4:	85 db                	test   %ebx,%ebx
  8005b6:	7f ed                	jg     8005a5 <vprintfmt+0x1c7>
  8005b8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005bb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005be:	85 d2                	test   %edx,%edx
  8005c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c5:	0f 49 c2             	cmovns %edx,%eax
  8005c8:	29 c2                	sub    %eax,%edx
  8005ca:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005cd:	89 d7                	mov    %edx,%edi
  8005cf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005d2:	eb 50                	jmp    800624 <vprintfmt+0x246>
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
  8005d4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d8:	74 1e                	je     8005f8 <vprintfmt+0x21a>
  8005da:	0f be d2             	movsbl %dl,%edx
  8005dd:	83 ea 20             	sub    $0x20,%edx
  8005e0:	83 fa 5e             	cmp    $0x5e,%edx
  8005e3:	76 13                	jbe    8005f8 <vprintfmt+0x21a>
          putch('?', putdat);
  8005e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ec:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005f3:	ff 55 08             	call   *0x8(%ebp)
  8005f6:	eb 0d                	jmp    800605 <vprintfmt+0x227>
        else
          putch(ch, putdat);
  8005f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005fb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005ff:	89 04 24             	mov    %eax,(%esp)
  800602:	ff 55 08             	call   *0x8(%ebp)
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800605:	83 ef 01             	sub    $0x1,%edi
  800608:	eb 1a                	jmp    800624 <vprintfmt+0x246>
  80060a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80060d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800610:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800613:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800616:	eb 0c                	jmp    800624 <vprintfmt+0x246>
  800618:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80061b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80061e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800621:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800624:	83 c6 01             	add    $0x1,%esi
  800627:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80062b:	0f be c2             	movsbl %dl,%eax
  80062e:	85 c0                	test   %eax,%eax
  800630:	74 27                	je     800659 <vprintfmt+0x27b>
  800632:	85 db                	test   %ebx,%ebx
  800634:	78 9e                	js     8005d4 <vprintfmt+0x1f6>
  800636:	83 eb 01             	sub    $0x1,%ebx
  800639:	79 99                	jns    8005d4 <vprintfmt+0x1f6>
  80063b:	89 f8                	mov    %edi,%eax
  80063d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800640:	8b 75 08             	mov    0x8(%ebp),%esi
  800643:	89 c3                	mov    %eax,%ebx
  800645:	eb 1a                	jmp    800661 <vprintfmt+0x283>
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
        putch(' ', putdat);
  800647:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80064b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800652:	ff d6                	call   *%esi
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
  800654:	83 eb 01             	sub    $0x1,%ebx
  800657:	eb 08                	jmp    800661 <vprintfmt+0x283>
  800659:	89 fb                	mov    %edi,%ebx
  80065b:	8b 75 08             	mov    0x8(%ebp),%esi
  80065e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800661:	85 db                	test   %ebx,%ebx
  800663:	7f e2                	jg     800647 <vprintfmt+0x269>
  800665:	89 75 08             	mov    %esi,0x8(%ebp)
  800668:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80066b:	e9 93 fd ff ff       	jmp    800403 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  if (lflag >= 2)
  800670:	83 fa 01             	cmp    $0x1,%edx
  800673:	7e 16                	jle    80068b <vprintfmt+0x2ad>
    return va_arg(*ap, long long);
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	8d 50 08             	lea    0x8(%eax),%edx
  80067b:	89 55 14             	mov    %edx,0x14(%ebp)
  80067e:	8b 50 04             	mov    0x4(%eax),%edx
  800681:	8b 00                	mov    (%eax),%eax
  800683:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800686:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800689:	eb 32                	jmp    8006bd <vprintfmt+0x2df>
  else if (lflag)
  80068b:	85 d2                	test   %edx,%edx
  80068d:	74 18                	je     8006a7 <vprintfmt+0x2c9>
    return va_arg(*ap, long);
  80068f:	8b 45 14             	mov    0x14(%ebp),%eax
  800692:	8d 50 04             	lea    0x4(%eax),%edx
  800695:	89 55 14             	mov    %edx,0x14(%ebp)
  800698:	8b 30                	mov    (%eax),%esi
  80069a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80069d:	89 f0                	mov    %esi,%eax
  80069f:	c1 f8 1f             	sar    $0x1f,%eax
  8006a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006a5:	eb 16                	jmp    8006bd <vprintfmt+0x2df>
  else
    return va_arg(*ap, int);
  8006a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006aa:	8d 50 04             	lea    0x4(%eax),%edx
  8006ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b0:	8b 30                	mov    (%eax),%esi
  8006b2:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006b5:	89 f0                	mov    %esi,%eax
  8006b7:	c1 f8 1f             	sar    $0x1f,%eax
  8006ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        putch(' ', putdat);
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
  8006bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      if ((long long)num < 0) {
        putch('-', putdat);
        num = -(long long)num;
      }
      base = 10;
  8006c3:	b9 0a 00 00 00       	mov    $0xa,%ecx
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
      if ((long long)num < 0) {
  8006c8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006cc:	0f 89 80 00 00 00    	jns    800752 <vprintfmt+0x374>
        putch('-', putdat);
  8006d2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006d6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006dd:	ff 55 08             	call   *0x8(%ebp)
        num = -(long long)num;
  8006e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006e6:	f7 d8                	neg    %eax
  8006e8:	83 d2 00             	adc    $0x0,%edx
  8006eb:	f7 da                	neg    %edx
      }
      base = 10;
  8006ed:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006f2:	eb 5e                	jmp    800752 <vprintfmt+0x374>
      goto number;

    // unsigned decimal
    case 'u':
      num = getuint(&ap, lflag);
  8006f4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f7:	e8 63 fc ff ff       	call   80035f <getuint>
      base = 10;
  8006fc:	b9 0a 00 00 00       	mov    $0xa,%ecx
      goto number;
  800701:	eb 4f                	jmp    800752 <vprintfmt+0x374>

    // (unsigned) octal
    case 'o':
      num = getuint(&ap, lflag);
  800703:	8d 45 14             	lea    0x14(%ebp),%eax
  800706:	e8 54 fc ff ff       	call   80035f <getuint>
      base = 8;
  80070b:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800710:	eb 40                	jmp    800752 <vprintfmt+0x374>

    // pointer
    case 'p':
      putch('0', putdat);
  800712:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800716:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80071d:	ff 55 08             	call   *0x8(%ebp)
      putch('x', putdat);
  800720:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800724:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80072b:	ff 55 08             	call   *0x8(%ebp)
      num = (unsigned long long)
            (uintptr_t)va_arg(ap, void *);
  80072e:	8b 45 14             	mov    0x14(%ebp),%eax
  800731:	8d 50 04             	lea    0x4(%eax),%edx
  800734:	89 55 14             	mov    %edx,0x14(%ebp)

    // pointer
    case 'p':
      putch('0', putdat);
      putch('x', putdat);
      num = (unsigned long long)
  800737:	8b 00                	mov    (%eax),%eax
  800739:	ba 00 00 00 00       	mov    $0x0,%edx
            (uintptr_t)va_arg(ap, void *);
      base = 16;
  80073e:	b9 10 00 00 00       	mov    $0x10,%ecx
      goto number;
  800743:	eb 0d                	jmp    800752 <vprintfmt+0x374>

    // (unsigned) hexadecimal
    case 'x':
      num = getuint(&ap, lflag);
  800745:	8d 45 14             	lea    0x14(%ebp),%eax
  800748:	e8 12 fc ff ff       	call   80035f <getuint>
      base = 16;
  80074d:	b9 10 00 00 00       	mov    $0x10,%ecx
number:
      printnum(putch, putdat, num, base, width, padc);
  800752:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800756:	89 74 24 10          	mov    %esi,0x10(%esp)
  80075a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80075d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800761:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800765:	89 04 24             	mov    %eax,(%esp)
  800768:	89 54 24 04          	mov    %edx,0x4(%esp)
  80076c:	89 fa                	mov    %edi,%edx
  80076e:	8b 45 08             	mov    0x8(%ebp),%eax
  800771:	e8 fa fa ff ff       	call   800270 <printnum>
      break;
  800776:	e9 88 fc ff ff       	jmp    800403 <vprintfmt+0x25>

    // escaped '%' character
    case '%':
      putch(ch, putdat);
  80077b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80077f:	89 04 24             	mov    %eax,(%esp)
  800782:	ff 55 08             	call   *0x8(%ebp)
      break;
  800785:	e9 79 fc ff ff       	jmp    800403 <vprintfmt+0x25>

    // unrecognized escape sequence - just print it literally
    default:
      putch('%', putdat);
  80078a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80078e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800795:	ff 55 08             	call   *0x8(%ebp)
      for (fmt--; fmt[-1] != '%'; fmt--)
  800798:	89 f3                	mov    %esi,%ebx
  80079a:	eb 03                	jmp    80079f <vprintfmt+0x3c1>
  80079c:	83 eb 01             	sub    $0x1,%ebx
  80079f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8007a3:	75 f7                	jne    80079c <vprintfmt+0x3be>
  8007a5:	e9 59 fc ff ff       	jmp    800403 <vprintfmt+0x25>
        /* do nothing */;
      break;
    }
  }
}
  8007aa:	83 c4 3c             	add    $0x3c,%esp
  8007ad:	5b                   	pop    %ebx
  8007ae:	5e                   	pop    %esi
  8007af:	5f                   	pop    %edi
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <vsnprintf>:
    *b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	83 ec 28             	sub    $0x28,%esp
  8007b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  struct sprintbuf b = { buf, buf+n-1, 0 };
  8007be:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  if (buf == NULL || n < 1)
  8007cf:	85 c0                	test   %eax,%eax
  8007d1:	74 30                	je     800803 <vsnprintf+0x51>
  8007d3:	85 d2                	test   %edx,%edx
  8007d5:	7e 2c                	jle    800803 <vsnprintf+0x51>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007de:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ec:	c7 04 24 99 03 80 00 	movl   $0x800399,(%esp)
  8007f3:	e8 e6 fb ff ff       	call   8003de <vprintfmt>

  // null terminate the buffer
  *b.buf = '\0';
  8007f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007fb:	c6 00 00             	movb   $0x0,(%eax)

  return b.cnt;
  8007fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800801:	eb 05                	jmp    800808 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  struct sprintbuf b = { buf, buf+n-1, 0 };

  if (buf == NULL || n < 1)
    return -E_INVAL;
  800803:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

  // null terminate the buffer
  *b.buf = '\0';

  return b.cnt;
}
  800808:	c9                   	leave  
  800809:	c3                   	ret    

0080080a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800810:	8d 45 14             	lea    0x14(%ebp),%eax
  rc = vsnprintf(buf, n, fmt, ap);
  800813:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800817:	8b 45 10             	mov    0x10(%ebp),%eax
  80081a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800821:	89 44 24 04          	mov    %eax,0x4(%esp)
  800825:	8b 45 08             	mov    0x8(%ebp),%eax
  800828:	89 04 24             	mov    %eax,(%esp)
  80082b:	e8 82 ff ff ff       	call   8007b2 <vsnprintf>
  va_end(ap);

  return rc;
}
  800830:	c9                   	leave  
  800831:	c3                   	ret    
  800832:	66 90                	xchg   %ax,%ax
  800834:	66 90                	xchg   %ax,%ax
  800836:	66 90                	xchg   %ax,%ax
  800838:	66 90                	xchg   %ax,%ax
  80083a:	66 90                	xchg   %ax,%ax
  80083c:	66 90                	xchg   %ax,%ax
  80083e:	66 90                	xchg   %ax,%ax

00800840 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for (n = 0; *s != '\0'; s++)
  800846:	b8 00 00 00 00       	mov    $0x0,%eax
  80084b:	eb 03                	jmp    800850 <strlen+0x10>
    n++;
  80084d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
  int n;

  for (n = 0; *s != '\0'; s++)
  800850:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800854:	75 f7                	jne    80084d <strlen+0xd>
    n++;
  return n;
}
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085e:	8b 55 0c             	mov    0xc(%ebp),%edx
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800861:	b8 00 00 00 00       	mov    $0x0,%eax
  800866:	eb 03                	jmp    80086b <strnlen+0x13>
    n++;
  800868:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80086b:	39 d0                	cmp    %edx,%eax
  80086d:	74 06                	je     800875 <strnlen+0x1d>
  80086f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800873:	75 f3                	jne    800868 <strnlen+0x10>
    n++;
  return n;
}
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	53                   	push   %ebx
  80087b:	8b 45 08             	mov    0x8(%ebp),%eax
  80087e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800881:	89 c2                	mov    %eax,%edx
  800883:	83 c2 01             	add    $0x1,%edx
  800886:	83 c1 01             	add    $0x1,%ecx
  800889:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80088d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800890:	84 db                	test   %bl,%bl
  800892:	75 ef                	jne    800883 <strcpy+0xc>
    /* do nothing */;
  return ret;
}
  800894:	5b                   	pop    %ebx
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	53                   	push   %ebx
  80089b:	83 ec 08             	sub    $0x8,%esp
  80089e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int len = strlen(dst);
  8008a1:	89 1c 24             	mov    %ebx,(%esp)
  8008a4:	e8 97 ff ff ff       	call   800840 <strlen>

  strcpy(dst + len, src);
  8008a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008b0:	01 d8                	add    %ebx,%eax
  8008b2:	89 04 24             	mov    %eax,(%esp)
  8008b5:	e8 bd ff ff ff       	call   800877 <strcpy>
  return dst;
}
  8008ba:	89 d8                	mov    %ebx,%eax
  8008bc:	83 c4 08             	add    $0x8,%esp
  8008bf:	5b                   	pop    %ebx
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	56                   	push   %esi
  8008c6:	53                   	push   %ebx
  8008c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008cd:	89 f3                	mov    %esi,%ebx
  8008cf:	03 5d 10             	add    0x10(%ebp),%ebx
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  8008d2:	89 f2                	mov    %esi,%edx
  8008d4:	eb 0f                	jmp    8008e5 <strncpy+0x23>
    *dst++ = *src;
  8008d6:	83 c2 01             	add    $0x1,%edx
  8008d9:	0f b6 01             	movzbl (%ecx),%eax
  8008dc:	88 42 ff             	mov    %al,-0x1(%edx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  8008df:	80 39 01             	cmpb   $0x1,(%ecx)
  8008e2:	83 d9 ff             	sbb    $0xffffffff,%ecx
{
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  8008e5:	39 da                	cmp    %ebx,%edx
  8008e7:	75 ed                	jne    8008d6 <strncpy+0x14>
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  }
  return ret;
}
  8008e9:	89 f0                	mov    %esi,%eax
  8008eb:	5b                   	pop    %ebx
  8008ec:	5e                   	pop    %esi
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    

008008ef <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	56                   	push   %esi
  8008f3:	53                   	push   %ebx
  8008f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008fd:	89 f0                	mov    %esi,%eax
  8008ff:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800903:	85 c9                	test   %ecx,%ecx
  800905:	75 0b                	jne    800912 <strlcpy+0x23>
  800907:	eb 1d                	jmp    800926 <strlcpy+0x37>
    while (--size > 0 && *src != '\0')
      *dst++ = *src++;
  800909:	83 c0 01             	add    $0x1,%eax
  80090c:	83 c2 01             	add    $0x1,%edx
  80090f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
    while (--size > 0 && *src != '\0')
  800912:	39 d8                	cmp    %ebx,%eax
  800914:	74 0b                	je     800921 <strlcpy+0x32>
  800916:	0f b6 0a             	movzbl (%edx),%ecx
  800919:	84 c9                	test   %cl,%cl
  80091b:	75 ec                	jne    800909 <strlcpy+0x1a>
  80091d:	89 c2                	mov    %eax,%edx
  80091f:	eb 02                	jmp    800923 <strlcpy+0x34>
  800921:	89 c2                	mov    %eax,%edx
      *dst++ = *src++;
    *dst = '\0';
  800923:	c6 02 00             	movb   $0x0,(%edx)
  }
  return dst - dst_in;
  800926:	29 f0                	sub    %esi,%eax
}
  800928:	5b                   	pop    %ebx
  800929:	5e                   	pop    %esi
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800932:	8b 55 0c             	mov    0xc(%ebp),%edx
  while (*p && *p == *q)
  800935:	eb 06                	jmp    80093d <strcmp+0x11>
    p++, q++;
  800937:	83 c1 01             	add    $0x1,%ecx
  80093a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
  while (*p && *p == *q)
  80093d:	0f b6 01             	movzbl (%ecx),%eax
  800940:	84 c0                	test   %al,%al
  800942:	74 04                	je     800948 <strcmp+0x1c>
  800944:	3a 02                	cmp    (%edx),%al
  800946:	74 ef                	je     800937 <strcmp+0xb>
    p++, q++;
  return (int)((unsigned char)*p - (unsigned char)*q);
  800948:	0f b6 c0             	movzbl %al,%eax
  80094b:	0f b6 12             	movzbl (%edx),%edx
  80094e:	29 d0                	sub    %edx,%eax
}
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    

00800952 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	53                   	push   %ebx
  800956:	8b 45 08             	mov    0x8(%ebp),%eax
  800959:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095c:	89 c3                	mov    %eax,%ebx
  80095e:	03 5d 10             	add    0x10(%ebp),%ebx
  while (n > 0 && *p && *p == *q)
  800961:	eb 06                	jmp    800969 <strncmp+0x17>
    n--, p++, q++;
  800963:	83 c0 01             	add    $0x1,%eax
  800966:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
  800969:	39 d8                	cmp    %ebx,%eax
  80096b:	74 15                	je     800982 <strncmp+0x30>
  80096d:	0f b6 08             	movzbl (%eax),%ecx
  800970:	84 c9                	test   %cl,%cl
  800972:	74 04                	je     800978 <strncmp+0x26>
  800974:	3a 0a                	cmp    (%edx),%cl
  800976:	74 eb                	je     800963 <strncmp+0x11>
    n--, p++, q++;
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800978:	0f b6 00             	movzbl (%eax),%eax
  80097b:	0f b6 12             	movzbl (%edx),%edx
  80097e:	29 d0                	sub    %edx,%eax
  800980:	eb 05                	jmp    800987 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
    n--, p++, q++;
  if (n == 0)
    return 0;
  800982:	b8 00 00 00 00       	mov    $0x0,%eax
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
}
  800987:	5b                   	pop    %ebx
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
  800994:	eb 07                	jmp    80099d <strchr+0x13>
    if (*s == c)
  800996:	38 ca                	cmp    %cl,%dl
  800998:	74 0f                	je     8009a9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  for (; *s; s++)
  80099a:	83 c0 01             	add    $0x1,%eax
  80099d:	0f b6 10             	movzbl (%eax),%edx
  8009a0:	84 d2                	test   %dl,%dl
  8009a2:	75 f2                	jne    800996 <strchr+0xc>
    if (*s == c)
      return (char*)s;
  return 0;
  8009a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
  8009b5:	eb 07                	jmp    8009be <strfind+0x13>
    if (*s == c)
  8009b7:	38 ca                	cmp    %cl,%dl
  8009b9:	74 0a                	je     8009c5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  for (; *s; s++)
  8009bb:	83 c0 01             	add    $0x1,%eax
  8009be:	0f b6 10             	movzbl (%eax),%edx
  8009c1:	84 d2                	test   %dl,%dl
  8009c3:	75 f2                	jne    8009b7 <strfind+0xc>
    if (*s == c)
      break;
  return (char*)s;
}
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	57                   	push   %edi
  8009cb:	56                   	push   %esi
  8009cc:	53                   	push   %ebx
  8009cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *p;

  if (n == 0)
  8009d3:	85 c9                	test   %ecx,%ecx
  8009d5:	74 36                	je     800a0d <memset+0x46>
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
  8009d7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009dd:	75 28                	jne    800a07 <memset+0x40>
  8009df:	f6 c1 03             	test   $0x3,%cl
  8009e2:	75 23                	jne    800a07 <memset+0x40>
    c &= 0xFF;
  8009e4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
    c = (c<<24)|(c<<16)|(c<<8)|c;
  8009e8:	89 d3                	mov    %edx,%ebx
  8009ea:	c1 e3 08             	shl    $0x8,%ebx
  8009ed:	89 d6                	mov    %edx,%esi
  8009ef:	c1 e6 18             	shl    $0x18,%esi
  8009f2:	89 d0                	mov    %edx,%eax
  8009f4:	c1 e0 10             	shl    $0x10,%eax
  8009f7:	09 f0                	or     %esi,%eax
  8009f9:	09 c2                	or     %eax,%edx
  8009fb:	89 d0                	mov    %edx,%eax
  8009fd:	09 d8                	or     %ebx,%eax
    asm volatile ("cld; rep stosl\n"
                  :: "D" (v), "a" (c), "c" (n/4)
  8009ff:	c1 e9 02             	shr    $0x2,%ecx
  if (n == 0)
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
    c &= 0xFF;
    c = (c<<24)|(c<<16)|(c<<8)|c;
    asm volatile ("cld; rep stosl\n"
  800a02:	fc                   	cld    
  800a03:	f3 ab                	rep stos %eax,%es:(%edi)
  800a05:	eb 06                	jmp    800a0d <memset+0x46>
                  :: "D" (v), "a" (c), "c" (n/4)
                  : "cc", "memory");
  } else
    asm volatile ("cld; rep stosb\n"
  800a07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0a:	fc                   	cld    
  800a0b:	f3 aa                	rep stos %al,%es:(%edi)
                  :: "D" (v), "a" (c), "c" (n)
                  : "cc", "memory");
  return v;
}
  800a0d:	89 f8                	mov    %edi,%eax
  800a0f:	5b                   	pop    %ebx
  800a10:	5e                   	pop    %esi
  800a11:	5f                   	pop    %edi
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	57                   	push   %edi
  800a18:	56                   	push   %esi
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800a22:	39 c6                	cmp    %eax,%esi
  800a24:	73 35                	jae    800a5b <memmove+0x47>
  800a26:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a29:	39 d0                	cmp    %edx,%eax
  800a2b:	73 2e                	jae    800a5b <memmove+0x47>
    s += n;
    d += n;
  800a2d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a30:	89 d6                	mov    %edx,%esi
  800a32:	09 fe                	or     %edi,%esi
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a34:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a3a:	75 13                	jne    800a4f <memmove+0x3b>
  800a3c:	f6 c1 03             	test   $0x3,%cl
  800a3f:	75 0e                	jne    800a4f <memmove+0x3b>
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a41:	83 ef 04             	sub    $0x4,%edi
  800a44:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a47:	c1 e9 02             	shr    $0x2,%ecx
  d = dst;
  if (s < d && s + n > d) {
    s += n;
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
  800a4a:	fd                   	std    
  800a4b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a4d:	eb 09                	jmp    800a58 <memmove+0x44>
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a4f:	83 ef 01             	sub    $0x1,%edi
  800a52:	8d 72 ff             	lea    -0x1(%edx),%esi
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
  800a55:	fd                   	std    
  800a56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  800a58:	fc                   	cld    
  800a59:	eb 1d                	jmp    800a78 <memmove+0x64>
  800a5b:	89 f2                	mov    %esi,%edx
  800a5d:	09 c2                	or     %eax,%edx
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5f:	f6 c2 03             	test   $0x3,%dl
  800a62:	75 0f                	jne    800a73 <memmove+0x5f>
  800a64:	f6 c1 03             	test   $0x3,%cl
  800a67:	75 0a                	jne    800a73 <memmove+0x5f>
      asm volatile ("cld; rep movsl\n"
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a69:	c1 e9 02             	shr    $0x2,%ecx
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("cld; rep movsl\n"
  800a6c:	89 c7                	mov    %eax,%edi
  800a6e:	fc                   	cld    
  800a6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a71:	eb 05                	jmp    800a78 <memmove+0x64>
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("cld; rep movsb\n"
  800a73:	89 c7                	mov    %eax,%edi
  800a75:	fc                   	cld    
  800a76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d), "S" (s), "c" (n) : "cc", "memory");
  }
  return dst;
}
  800a78:	5e                   	pop    %esi
  800a79:	5f                   	pop    %edi
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
  800a82:	8b 45 10             	mov    0x10(%ebp),%eax
  800a85:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a89:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a90:	8b 45 08             	mov    0x8(%ebp),%eax
  800a93:	89 04 24             	mov    %eax,(%esp)
  800a96:	e8 79 ff ff ff       	call   800a14 <memmove>
}
  800a9b:	c9                   	leave  
  800a9c:	c3                   	ret    

00800a9d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	56                   	push   %esi
  800aa1:	53                   	push   %ebx
  800aa2:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa8:	89 d6                	mov    %edx,%esi
  800aaa:	03 75 10             	add    0x10(%ebp),%esi
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
  800aad:	eb 1a                	jmp    800ac9 <memcmp+0x2c>
    if (*s1 != *s2)
  800aaf:	0f b6 02             	movzbl (%edx),%eax
  800ab2:	0f b6 19             	movzbl (%ecx),%ebx
  800ab5:	38 d8                	cmp    %bl,%al
  800ab7:	74 0a                	je     800ac3 <memcmp+0x26>
      return (int)*s1 - (int)*s2;
  800ab9:	0f b6 c0             	movzbl %al,%eax
  800abc:	0f b6 db             	movzbl %bl,%ebx
  800abf:	29 d8                	sub    %ebx,%eax
  800ac1:	eb 0f                	jmp    800ad2 <memcmp+0x35>
    s1++, s2++;
  800ac3:	83 c2 01             	add    $0x1,%edx
  800ac6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
  800ac9:	39 f2                	cmp    %esi,%edx
  800acb:	75 e2                	jne    800aaf <memcmp+0x12>
    if (*s1 != *s2)
      return (int)*s1 - (int)*s2;
    s1++, s2++;
  }

  return 0;
  800acd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  800adc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  const void *ends = (const char*)s + n;
  800adf:	89 c2                	mov    %eax,%edx
  800ae1:	03 55 10             	add    0x10(%ebp),%edx

  for (; s < ends; s++)
  800ae4:	eb 07                	jmp    800aed <memfind+0x17>
    if (*(const unsigned char*)s == (unsigned char)c)
  800ae6:	38 08                	cmp    %cl,(%eax)
  800ae8:	74 07                	je     800af1 <memfind+0x1b>
void *
memfind(const void *s, int c, size_t n)
{
  const void *ends = (const char*)s + n;

  for (; s < ends; s++)
  800aea:	83 c0 01             	add    $0x1,%eax
  800aed:	39 d0                	cmp    %edx,%eax
  800aef:	72 f5                	jb     800ae6 <memfind+0x10>
    if (*(const unsigned char*)s == (unsigned char)c)
      break;
  return (void*)s;
}
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
  800af9:	8b 55 08             	mov    0x8(%ebp),%edx
  800afc:	8b 45 10             	mov    0x10(%ebp),%eax
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800aff:	eb 03                	jmp    800b04 <strtol+0x11>
    s++;
  800b01:	83 c2 01             	add    $0x1,%edx
{
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800b04:	0f b6 0a             	movzbl (%edx),%ecx
  800b07:	80 f9 09             	cmp    $0x9,%cl
  800b0a:	74 f5                	je     800b01 <strtol+0xe>
  800b0c:	80 f9 20             	cmp    $0x20,%cl
  800b0f:	74 f0                	je     800b01 <strtol+0xe>
    s++;

  // plus/minus sign
  if (*s == '+')
  800b11:	80 f9 2b             	cmp    $0x2b,%cl
  800b14:	75 0a                	jne    800b20 <strtol+0x2d>
    s++;
  800b16:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
  int neg = 0;
  800b19:	bf 00 00 00 00       	mov    $0x0,%edi
  800b1e:	eb 11                	jmp    800b31 <strtol+0x3e>
  800b20:	bf 00 00 00 00       	mov    $0x0,%edi
    s++;

  // plus/minus sign
  if (*s == '+')
    s++;
  else if (*s == '-')
  800b25:	80 f9 2d             	cmp    $0x2d,%cl
  800b28:	75 07                	jne    800b31 <strtol+0x3e>
    s++, neg = 1;
  800b2a:	8d 52 01             	lea    0x1(%edx),%edx
  800b2d:	66 bf 01 00          	mov    $0x1,%di

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b31:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b36:	75 15                	jne    800b4d <strtol+0x5a>
  800b38:	80 3a 30             	cmpb   $0x30,(%edx)
  800b3b:	75 10                	jne    800b4d <strtol+0x5a>
  800b3d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b41:	75 0a                	jne    800b4d <strtol+0x5a>
    s += 2, base = 16;
  800b43:	83 c2 02             	add    $0x2,%edx
  800b46:	b8 10 00 00 00       	mov    $0x10,%eax
  800b4b:	eb 10                	jmp    800b5d <strtol+0x6a>
  else if (base == 0 && s[0] == '0')
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	75 0c                	jne    800b5d <strtol+0x6a>
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800b51:	b0 0a                	mov    $0xa,%al
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
  800b53:	80 3a 30             	cmpb   $0x30,(%edx)
  800b56:	75 05                	jne    800b5d <strtol+0x6a>
    s++, base = 8;
  800b58:	83 c2 01             	add    $0x1,%edx
  800b5b:	b0 08                	mov    $0x8,%al
  else if (base == 0)
    base = 10;
  800b5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b62:	89 45 10             	mov    %eax,0x10(%ebp)

  // digits
  while (1) {
    int dig;

    if (*s >= '0' && *s <= '9')
  800b65:	0f b6 0a             	movzbl (%edx),%ecx
  800b68:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b6b:	89 f0                	mov    %esi,%eax
  800b6d:	3c 09                	cmp    $0x9,%al
  800b6f:	77 08                	ja     800b79 <strtol+0x86>
      dig = *s - '0';
  800b71:	0f be c9             	movsbl %cl,%ecx
  800b74:	83 e9 30             	sub    $0x30,%ecx
  800b77:	eb 20                	jmp    800b99 <strtol+0xa6>
    else if (*s >= 'a' && *s <= 'z')
  800b79:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b7c:	89 f0                	mov    %esi,%eax
  800b7e:	3c 19                	cmp    $0x19,%al
  800b80:	77 08                	ja     800b8a <strtol+0x97>
      dig = *s - 'a' + 10;
  800b82:	0f be c9             	movsbl %cl,%ecx
  800b85:	83 e9 57             	sub    $0x57,%ecx
  800b88:	eb 0f                	jmp    800b99 <strtol+0xa6>
    else if (*s >= 'A' && *s <= 'Z')
  800b8a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b8d:	89 f0                	mov    %esi,%eax
  800b8f:	3c 19                	cmp    $0x19,%al
  800b91:	77 16                	ja     800ba9 <strtol+0xb6>
      dig = *s - 'A' + 10;
  800b93:	0f be c9             	movsbl %cl,%ecx
  800b96:	83 e9 37             	sub    $0x37,%ecx
    else
      break;
    if (dig >= base)
  800b99:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b9c:	7d 0f                	jge    800bad <strtol+0xba>
      break;
    s++, val = (val * base) + dig;
  800b9e:	83 c2 01             	add    $0x1,%edx
  800ba1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800ba5:	01 cb                	add    %ecx,%ebx
    // we don't properly detect overflow!
  }
  800ba7:	eb bc                	jmp    800b65 <strtol+0x72>
  800ba9:	89 d8                	mov    %ebx,%eax
  800bab:	eb 02                	jmp    800baf <strtol+0xbc>
  800bad:	89 d8                	mov    %ebx,%eax

  if (endptr)
  800baf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bb3:	74 05                	je     800bba <strtol+0xc7>
    *endptr = (char*)s;
  800bb5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb8:	89 16                	mov    %edx,(%esi)
  return neg ? -val : val;
  800bba:	f7 d8                	neg    %eax
  800bbc:	85 ff                	test   %edi,%edi
  800bbe:	0f 44 c3             	cmove  %ebx,%eax
}
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <sys_cputs>:
  return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800bcc:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd7:	89 c3                	mov    %eax,%ebx
  800bd9:	89 c7                	mov    %eax,%edi
  800bdb:	89 c6                	mov    %eax,%esi
  800bdd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
  syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <sys_cgetc>:

int
sys_cgetc(void)
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
  800bef:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf4:	89 d1                	mov    %edx,%ecx
  800bf6:	89 d3                	mov    %edx,%ebx
  800bf8:	89 d7                	mov    %edx,%edi
  800bfa:	89 d6                	mov    %edx,%esi
  800bfc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800c0c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c11:	b8 03 00 00 00       	mov    $0x3,%eax
  800c16:	8b 55 08             	mov    0x8(%ebp),%edx
  800c19:	89 cb                	mov    %ecx,%ebx
  800c1b:	89 cf                	mov    %ecx,%edi
  800c1d:	89 ce                	mov    %ecx,%esi
  800c1f:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800c21:	85 c0                	test   %eax,%eax
  800c23:	7e 28                	jle    800c4d <sys_env_destroy+0x4a>
    panic("syscall %d returned %d (> 0)", num, ret);
  800c25:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c29:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c30:	00 
  800c31:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800c38:	00 
  800c39:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c40:	00 
  800c41:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800c48:	e8 08 f5 ff ff       	call   800155 <_panic>

int
sys_env_destroy(envid_t envid)
{
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c4d:	83 c4 2c             	add    $0x2c,%esp
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800c5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c60:	b8 02 00 00 00       	mov    $0x2,%eax
  800c65:	89 d1                	mov    %edx,%ecx
  800c67:	89 d3                	mov    %edx,%ebx
  800c69:	89 d7                	mov    %edx,%edi
  800c6b:	89 d6                	mov    %edx,%esi
  800c6d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <sys_yield>:

void
sys_yield(void)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800c7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c84:	89 d1                	mov    %edx,%ecx
  800c86:	89 d3                	mov    %edx,%ebx
  800c88:	89 d7                	mov    %edx,%edi
  800c8a:	89 d6                	mov    %edx,%esi
  800c8c:	cd 30                	int    $0x30

void
sys_yield(void)
{
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800c9c:	be 00 00 00 00       	mov    $0x0,%esi
  800ca1:	b8 04 00 00 00       	mov    $0x4,%eax
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800caf:	89 f7                	mov    %esi,%edi
  800cb1:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	7e 28                	jle    800cdf <sys_page_alloc+0x4c>
    panic("syscall %d returned %d (> 0)", num, ret);
  800cb7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cbb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cc2:	00 
  800cc3:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800cca:	00 
  800ccb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd2:	00 
  800cd3:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800cda:	e8 76 f4 ff ff       	call   800155 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  return syscall(SYS_page_alloc, 1, envid, (uint32_t)va, perm, 0, 0);
}
  800cdf:	83 c4 2c             	add    $0x2c,%esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800cf0:	b8 05 00 00 00       	mov    $0x5,%eax
  800cf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d01:	8b 75 18             	mov    0x18(%ebp),%esi
  800d04:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800d06:	85 c0                	test   %eax,%eax
  800d08:	7e 28                	jle    800d32 <sys_page_map+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800d0a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d0e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d15:	00 
  800d16:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800d1d:	00 
  800d1e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d25:	00 
  800d26:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800d2d:	e8 23 f4 ff ff       	call   800155 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  return syscall(SYS_page_map, 1, srcenv, (uint32_t)srcva, dstenv, (uint32_t)dstva, perm);
}
  800d32:	83 c4 2c             	add    $0x2c,%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	57                   	push   %edi
  800d3e:	56                   	push   %esi
  800d3f:	53                   	push   %ebx
  800d40:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800d43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d48:	b8 06 00 00 00       	mov    $0x6,%eax
  800d4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d50:	8b 55 08             	mov    0x8(%ebp),%edx
  800d53:	89 df                	mov    %ebx,%edi
  800d55:	89 de                	mov    %ebx,%esi
  800d57:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	7e 28                	jle    800d85 <sys_page_unmap+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800d5d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d61:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d68:	00 
  800d69:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800d70:	00 
  800d71:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d78:	00 
  800d79:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800d80:	e8 d0 f3 ff ff       	call   800155 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
  return syscall(SYS_page_unmap, 1, envid, (uint32_t)va, 0, 0, 0);
}
  800d85:	83 c4 2c             	add    $0x2c,%esp
  800d88:	5b                   	pop    %ebx
  800d89:	5e                   	pop    %esi
  800d8a:	5f                   	pop    %edi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	57                   	push   %edi
  800d91:	56                   	push   %esi
  800d92:	53                   	push   %ebx
  800d93:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800d96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9b:	b8 08 00 00 00       	mov    $0x8,%eax
  800da0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da3:	8b 55 08             	mov    0x8(%ebp),%edx
  800da6:	89 df                	mov    %ebx,%edi
  800da8:	89 de                	mov    %ebx,%esi
  800daa:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800dac:	85 c0                	test   %eax,%eax
  800dae:	7e 28                	jle    800dd8 <sys_env_set_status+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800db0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800dbb:	00 
  800dbc:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800dc3:	00 
  800dc4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dcb:	00 
  800dcc:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800dd3:	e8 7d f3 ff ff       	call   800155 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dd8:	83 c4 2c             	add    $0x2c,%esp
  800ddb:	5b                   	pop    %ebx
  800ddc:	5e                   	pop    %esi
  800ddd:	5f                   	pop    %edi
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	57                   	push   %edi
  800de4:	56                   	push   %esi
  800de5:	53                   	push   %ebx
  800de6:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800de9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dee:	b8 09 00 00 00       	mov    $0x9,%eax
  800df3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df6:	8b 55 08             	mov    0x8(%ebp),%edx
  800df9:	89 df                	mov    %ebx,%edi
  800dfb:	89 de                	mov    %ebx,%esi
  800dfd:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800dff:	85 c0                	test   %eax,%eax
  800e01:	7e 28                	jle    800e2b <sys_env_set_trapframe+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800e03:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e07:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e0e:	00 
  800e0f:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800e16:	00 
  800e17:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e1e:	00 
  800e1f:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800e26:	e8 2a f3 ff ff       	call   800155 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t)tf, 0, 0, 0);
}
  800e2b:	83 c4 2c             	add    $0x2c,%esp
  800e2e:	5b                   	pop    %ebx
  800e2f:	5e                   	pop    %esi
  800e30:	5f                   	pop    %edi
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    

00800e33 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	57                   	push   %edi
  800e37:	56                   	push   %esi
  800e38:	53                   	push   %ebx
  800e39:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800e3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e41:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e49:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4c:	89 df                	mov    %ebx,%edi
  800e4e:	89 de                	mov    %ebx,%esi
  800e50:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800e52:	85 c0                	test   %eax,%eax
  800e54:	7e 28                	jle    800e7e <sys_env_set_pgfault_upcall+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800e56:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e5a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e61:	00 
  800e62:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800e69:	00 
  800e6a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e71:	00 
  800e72:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800e79:	e8 d7 f2 ff ff       	call   800155 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800e7e:	83 c4 2c             	add    $0x2c,%esp
  800e81:	5b                   	pop    %ebx
  800e82:	5e                   	pop    %esi
  800e83:	5f                   	pop    %edi
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    

00800e86 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	57                   	push   %edi
  800e8a:	56                   	push   %esi
  800e8b:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800e8c:	be 00 00 00 00       	mov    $0x0,%esi
  800e91:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e99:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e9f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ea2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t)srcva, perm, 0);
}
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	57                   	push   %edi
  800ead:	56                   	push   %esi
  800eae:	53                   	push   %ebx
  800eaf:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800eb2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ebc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebf:	89 cb                	mov    %ecx,%ebx
  800ec1:	89 cf                	mov    %ecx,%edi
  800ec3:	89 ce                	mov    %ecx,%esi
  800ec5:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800ec7:	85 c0                	test   %eax,%eax
  800ec9:	7e 28                	jle    800ef3 <sys_ipc_recv+0x4a>
    panic("syscall %d returned %d (> 0)", num, ret);
  800ecb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ecf:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ed6:	00 
  800ed7:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800ede:	00 
  800edf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee6:	00 
  800ee7:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800eee:	e8 62 f2 ff ff       	call   800155 <_panic>

int
sys_ipc_recv(void *dstva)
{
  return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ef3:	83 c4 2c             	add    $0x2c,%esp
  800ef6:	5b                   	pop    %ebx
  800ef7:	5e                   	pop    %esi
  800ef8:	5f                   	pop    %edi
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	83 ec 18             	sub    $0x18,%esp
  int r;

  if (_pgfault_handler == 0) {
  800f01:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800f08:	75 70                	jne    800f7a <set_pgfault_handler+0x7f>
    // First time through!
    // LAB 4: Your code here.
    if(sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_SYSCALL) < 0) {
  800f0a:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  800f11:	00 
  800f12:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800f19:	ee 
  800f1a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f21:	e8 6d fd ff ff       	call   800c93 <sys_page_alloc>
  800f26:	85 c0                	test   %eax,%eax
  800f28:	79 1c                	jns    800f46 <set_pgfault_handler+0x4b>
      panic("In set_pgfault_handler, sys_page_alloc error");
  800f2a:	c7 44 24 08 cc 24 80 	movl   $0x8024cc,0x8(%esp)
  800f31:	00 
  800f32:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800f39:	00 
  800f3a:	c7 04 24 35 25 80 00 	movl   $0x802535,(%esp)
  800f41:	e8 0f f2 ff ff       	call   800155 <_panic>
    }
    if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  800f46:	c7 44 24 04 84 0f 80 	movl   $0x800f84,0x4(%esp)
  800f4d:	00 
  800f4e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f55:	e8 d9 fe ff ff       	call   800e33 <sys_env_set_pgfault_upcall>
  800f5a:	85 c0                	test   %eax,%eax
  800f5c:	79 1c                	jns    800f7a <set_pgfault_handler+0x7f>
      panic("In set_pgfault_handler, sys_env_set_pgfault_upcall error");
  800f5e:	c7 44 24 08 fc 24 80 	movl   $0x8024fc,0x8(%esp)
  800f65:	00 
  800f66:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800f6d:	00 
  800f6e:	c7 04 24 35 25 80 00 	movl   $0x802535,(%esp)
  800f75:	e8 db f1 ff ff       	call   800155 <_panic>
    }
  }
  // Save handler pointer for assembly to call.
  _pgfault_handler = handler;
  800f7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7d:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800f82:	c9                   	leave  
  800f83:	c3                   	ret    

00800f84 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800f84:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800f85:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800f8a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800f8c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
  subl $0x4, 0x30(%esp)
  800f8f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
  movl 0x30(%esp), %eax
  800f94:	8b 44 24 30          	mov    0x30(%esp),%eax
  movl 0x28(%esp), %ebx
  800f98:	8b 5c 24 28          	mov    0x28(%esp),%ebx
  movl %ebx, (%eax)
  800f9c:	89 18                	mov    %ebx,(%eax)


	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
  addl $0x8, %esp
  800f9e:	83 c4 08             	add    $0x8,%esp
  popal
  800fa1:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
  addl $0x4, %esp
  800fa2:	83 c4 04             	add    $0x4,%esp
  popfl
  800fa5:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
  movl (%esp), %esp
  800fa6:	8b 24 24             	mov    (%esp),%esp

  // Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  ret
  800fa9:	c3                   	ret    
  800faa:	66 90                	xchg   %ax,%ax
  800fac:	66 90                	xchg   %ax,%ax
  800fae:	66 90                	xchg   %ax,%ax

00800fb0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  800fb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb6:	05 00 00 00 30       	add    $0x30000000,%eax
  800fbb:	c1 e8 0c             	shr    $0xc,%eax
}
  800fbe:	5d                   	pop    %ebp
  800fbf:	c3                   	ret    

00800fc0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  800fc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc6:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
  return INDEX2DATA(fd2num(fd));
  800fcb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800fd0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800fd5:	5d                   	pop    %ebp
  800fd6:	c3                   	ret    

00800fd7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fdd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
  int i;
  struct Fd *fd;

  for (i = 0; i < MAXFD; i++) {
    fd = INDEX2FD(i);
    if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800fe2:	89 c2                	mov    %eax,%edx
  800fe4:	c1 ea 16             	shr    $0x16,%edx
  800fe7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fee:	f6 c2 01             	test   $0x1,%dl
  800ff1:	74 11                	je     801004 <fd_alloc+0x2d>
  800ff3:	89 c2                	mov    %eax,%edx
  800ff5:	c1 ea 0c             	shr    $0xc,%edx
  800ff8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fff:	f6 c2 01             	test   $0x1,%dl
  801002:	75 09                	jne    80100d <fd_alloc+0x36>
      *fd_store = fd;
  801004:	89 01                	mov    %eax,(%ecx)
      return 0;
  801006:	b8 00 00 00 00       	mov    $0x0,%eax
  80100b:	eb 17                	jmp    801024 <fd_alloc+0x4d>
  80100d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
  int i;
  struct Fd *fd;

  for (i = 0; i < MAXFD; i++) {
  801012:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801017:	75 c9                	jne    800fe2 <fd_alloc+0xb>
    if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
      *fd_store = fd;
      return 0;
    }
  }
  *fd_store = 0;
  801019:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
  return -E_MAX_OPEN;
  80101f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801024:	5d                   	pop    %ebp
  801025:	c3                   	ret    

00801026 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	8b 45 08             	mov    0x8(%ebp),%eax
  struct Fd *fd;

  if (fdnum < 0 || fdnum >= MAXFD) {
  80102c:	83 f8 1f             	cmp    $0x1f,%eax
  80102f:	77 36                	ja     801067 <fd_lookup+0x41>
    if (debug)
      cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  fd = INDEX2FD(fdnum);
  801031:	c1 e0 0c             	shl    $0xc,%eax
  801034:	2d 00 00 00 30       	sub    $0x30000000,%eax
  if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801039:	89 c2                	mov    %eax,%edx
  80103b:	c1 ea 16             	shr    $0x16,%edx
  80103e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801045:	f6 c2 01             	test   $0x1,%dl
  801048:	74 24                	je     80106e <fd_lookup+0x48>
  80104a:	89 c2                	mov    %eax,%edx
  80104c:	c1 ea 0c             	shr    $0xc,%edx
  80104f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801056:	f6 c2 01             	test   $0x1,%dl
  801059:	74 1a                	je     801075 <fd_lookup+0x4f>
    if (debug)
      cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  *fd_store = fd;
  80105b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80105e:	89 02                	mov    %eax,(%edx)
  return 0;
  801060:	b8 00 00 00 00       	mov    $0x0,%eax
  801065:	eb 13                	jmp    80107a <fd_lookup+0x54>
  struct Fd *fd;

  if (fdnum < 0 || fdnum >= MAXFD) {
    if (debug)
      cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  801067:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80106c:	eb 0c                	jmp    80107a <fd_lookup+0x54>
  }
  fd = INDEX2FD(fdnum);
  if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
    if (debug)
      cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  80106e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801073:	eb 05                	jmp    80107a <fd_lookup+0x54>
  801075:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  }
  *fd_store = fd;
  return 0;
}
  80107a:	5d                   	pop    %ebp
  80107b:	c3                   	ret    

0080107c <dev_lookup>:
  0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80107c:	55                   	push   %ebp
  80107d:	89 e5                	mov    %esp,%ebp
  80107f:	83 ec 18             	sub    $0x18,%esp
  801082:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801085:	ba c4 25 80 00       	mov    $0x8025c4,%edx
  int i;

  for (i = 0; devtab[i]; i++)
  80108a:	eb 13                	jmp    80109f <dev_lookup+0x23>
  80108c:	83 c2 04             	add    $0x4,%edx
    if (devtab[i]->dev_id == dev_id) {
  80108f:	39 08                	cmp    %ecx,(%eax)
  801091:	75 0c                	jne    80109f <dev_lookup+0x23>
      *dev = devtab[i];
  801093:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801096:	89 01                	mov    %eax,(%ecx)
      return 0;
  801098:	b8 00 00 00 00       	mov    $0x0,%eax
  80109d:	eb 30                	jmp    8010cf <dev_lookup+0x53>
int
dev_lookup(int dev_id, struct Dev **dev)
{
  int i;

  for (i = 0; devtab[i]; i++)
  80109f:	8b 02                	mov    (%edx),%eax
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	75 e7                	jne    80108c <dev_lookup+0x10>
    if (devtab[i]->dev_id == dev_id) {
      *dev = devtab[i];
      return 0;
    }
  cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8010a5:	a1 04 40 80 00       	mov    0x804004,%eax
  8010aa:	8b 40 48             	mov    0x48(%eax),%eax
  8010ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b5:	c7 04 24 44 25 80 00 	movl   $0x802544,(%esp)
  8010bc:	e8 8d f1 ff ff       	call   80024e <cprintf>
  *dev = 0;
  8010c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010c4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  return -E_INVAL;
  8010ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010cf:	c9                   	leave  
  8010d0:	c3                   	ret    

008010d1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
  8010d4:	56                   	push   %esi
  8010d5:	53                   	push   %ebx
  8010d6:	83 ec 20             	sub    $0x20,%esp
  8010d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8010dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct Fd *fd2;
  struct Dev *dev;
  int r;

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e2:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  8010e6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8010ec:	c1 e8 0c             	shr    $0xc,%eax
{
  struct Fd *fd2;
  struct Dev *dev;
  int r;

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010ef:	89 04 24             	mov    %eax,(%esp)
  8010f2:	e8 2f ff ff ff       	call   801026 <fd_lookup>
  8010f7:	85 c0                	test   %eax,%eax
  8010f9:	78 05                	js     801100 <fd_close+0x2f>
      || fd != fd2)
  8010fb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8010fe:	74 0c                	je     80110c <fd_close+0x3b>
    return must_exist ? r : 0;
  801100:	84 db                	test   %bl,%bl
  801102:	ba 00 00 00 00       	mov    $0x0,%edx
  801107:	0f 44 c2             	cmove  %edx,%eax
  80110a:	eb 3f                	jmp    80114b <fd_close+0x7a>
  if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80110c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80110f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801113:	8b 06                	mov    (%esi),%eax
  801115:	89 04 24             	mov    %eax,(%esp)
  801118:	e8 5f ff ff ff       	call   80107c <dev_lookup>
  80111d:	89 c3                	mov    %eax,%ebx
  80111f:	85 c0                	test   %eax,%eax
  801121:	78 16                	js     801139 <fd_close+0x68>
    if (dev->dev_close)
  801123:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801126:	8b 40 10             	mov    0x10(%eax),%eax
      r = (*dev->dev_close)(fd);
    else
      r = 0;
  801129:	bb 00 00 00 00       	mov    $0x0,%ebx

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
      || fd != fd2)
    return must_exist ? r : 0;
  if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
    if (dev->dev_close)
  80112e:	85 c0                	test   %eax,%eax
  801130:	74 07                	je     801139 <fd_close+0x68>
      r = (*dev->dev_close)(fd);
  801132:	89 34 24             	mov    %esi,(%esp)
  801135:	ff d0                	call   *%eax
  801137:	89 c3                	mov    %eax,%ebx
    else
      r = 0;
  }
  // Make sure fd is unmapped.  Might be a no-op if
  // (*dev->dev_close)(fd) already unmapped it.
  (void)sys_page_unmap(0, fd);
  801139:	89 74 24 04          	mov    %esi,0x4(%esp)
  80113d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801144:	e8 f1 fb ff ff       	call   800d3a <sys_page_unmap>
  return r;
  801149:	89 d8                	mov    %ebx,%eax
}
  80114b:	83 c4 20             	add    $0x20,%esp
  80114e:	5b                   	pop    %ebx
  80114f:	5e                   	pop    %esi
  801150:	5d                   	pop    %ebp
  801151:	c3                   	ret    

00801152 <close>:
  return -E_INVAL;
}

int
close(int fdnum)
{
  801152:	55                   	push   %ebp
  801153:	89 e5                	mov    %esp,%ebp
  801155:	83 ec 28             	sub    $0x28,%esp
  struct Fd *fd;
  int r;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  801158:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80115b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80115f:	8b 45 08             	mov    0x8(%ebp),%eax
  801162:	89 04 24             	mov    %eax,(%esp)
  801165:	e8 bc fe ff ff       	call   801026 <fd_lookup>
  80116a:	89 c2                	mov    %eax,%edx
  80116c:	85 d2                	test   %edx,%edx
  80116e:	78 13                	js     801183 <close+0x31>
    return r;
  else
    return fd_close(fd, 1);
  801170:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801177:	00 
  801178:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80117b:	89 04 24             	mov    %eax,(%esp)
  80117e:	e8 4e ff ff ff       	call   8010d1 <fd_close>
}
  801183:	c9                   	leave  
  801184:	c3                   	ret    

00801185 <close_all>:

void
close_all(void)
{
  801185:	55                   	push   %ebp
  801186:	89 e5                	mov    %esp,%ebp
  801188:	53                   	push   %ebx
  801189:	83 ec 14             	sub    $0x14,%esp
  int i;

  for (i = 0; i < MAXFD; i++)
  80118c:	bb 00 00 00 00       	mov    $0x0,%ebx
    close(i);
  801191:	89 1c 24             	mov    %ebx,(%esp)
  801194:	e8 b9 ff ff ff       	call   801152 <close>
void
close_all(void)
{
  int i;

  for (i = 0; i < MAXFD; i++)
  801199:	83 c3 01             	add    $0x1,%ebx
  80119c:	83 fb 20             	cmp    $0x20,%ebx
  80119f:	75 f0                	jne    801191 <close_all+0xc>
    close(i);
}
  8011a1:	83 c4 14             	add    $0x14,%esp
  8011a4:	5b                   	pop    %ebx
  8011a5:	5d                   	pop    %ebp
  8011a6:	c3                   	ret    

008011a7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011a7:	55                   	push   %ebp
  8011a8:	89 e5                	mov    %esp,%ebp
  8011aa:	57                   	push   %edi
  8011ab:	56                   	push   %esi
  8011ac:	53                   	push   %ebx
  8011ad:	83 ec 3c             	sub    $0x3c,%esp
  int r;
  char *ova, *nva;
  pte_t pte;
  struct Fd *oldfd, *newfd;

  if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011b0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ba:	89 04 24             	mov    %eax,(%esp)
  8011bd:	e8 64 fe ff ff       	call   801026 <fd_lookup>
  8011c2:	89 c2                	mov    %eax,%edx
  8011c4:	85 d2                	test   %edx,%edx
  8011c6:	0f 88 e1 00 00 00    	js     8012ad <dup+0x106>
    return r;
  close(newfdnum);
  8011cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011cf:	89 04 24             	mov    %eax,(%esp)
  8011d2:	e8 7b ff ff ff       	call   801152 <close>

  newfd = INDEX2FD(newfdnum);
  8011d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011da:	c1 e3 0c             	shl    $0xc,%ebx
  8011dd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
  ova = fd2data(oldfd);
  8011e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011e6:	89 04 24             	mov    %eax,(%esp)
  8011e9:	e8 d2 fd ff ff       	call   800fc0 <fd2data>
  8011ee:	89 c6                	mov    %eax,%esi
  nva = fd2data(newfd);
  8011f0:	89 1c 24             	mov    %ebx,(%esp)
  8011f3:	e8 c8 fd ff ff       	call   800fc0 <fd2data>
  8011f8:	89 c7                	mov    %eax,%edi

  if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8011fa:	89 f0                	mov    %esi,%eax
  8011fc:	c1 e8 16             	shr    $0x16,%eax
  8011ff:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801206:	a8 01                	test   $0x1,%al
  801208:	74 43                	je     80124d <dup+0xa6>
  80120a:	89 f0                	mov    %esi,%eax
  80120c:	c1 e8 0c             	shr    $0xc,%eax
  80120f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801216:	f6 c2 01             	test   $0x1,%dl
  801219:	74 32                	je     80124d <dup+0xa6>
    if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80121b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801222:	25 07 0e 00 00       	and    $0xe07,%eax
  801227:	89 44 24 10          	mov    %eax,0x10(%esp)
  80122b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80122f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801236:	00 
  801237:	89 74 24 04          	mov    %esi,0x4(%esp)
  80123b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801242:	e8 a0 fa ff ff       	call   800ce7 <sys_page_map>
  801247:	89 c6                	mov    %eax,%esi
  801249:	85 c0                	test   %eax,%eax
  80124b:	78 3e                	js     80128b <dup+0xe4>
      goto err;
  if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80124d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801250:	89 c2                	mov    %eax,%edx
  801252:	c1 ea 0c             	shr    $0xc,%edx
  801255:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80125c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801262:	89 54 24 10          	mov    %edx,0x10(%esp)
  801266:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80126a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801271:	00 
  801272:	89 44 24 04          	mov    %eax,0x4(%esp)
  801276:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80127d:	e8 65 fa ff ff       	call   800ce7 <sys_page_map>
  801282:	89 c6                	mov    %eax,%esi
    goto err;

  return newfdnum;
  801284:	8b 45 0c             	mov    0xc(%ebp),%eax
  nva = fd2data(newfd);

  if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
    if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
      goto err;
  if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801287:	85 f6                	test   %esi,%esi
  801289:	79 22                	jns    8012ad <dup+0x106>
    goto err;

  return newfdnum;

err:
  sys_page_unmap(0, newfd);
  80128b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80128f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801296:	e8 9f fa ff ff       	call   800d3a <sys_page_unmap>
  sys_page_unmap(0, nva);
  80129b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80129f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012a6:	e8 8f fa ff ff       	call   800d3a <sys_page_unmap>
  return r;
  8012ab:	89 f0                	mov    %esi,%eax
}
  8012ad:	83 c4 3c             	add    $0x3c,%esp
  8012b0:	5b                   	pop    %ebx
  8012b1:	5e                   	pop    %esi
  8012b2:	5f                   	pop    %edi
  8012b3:	5d                   	pop    %ebp
  8012b4:	c3                   	ret    

008012b5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	53                   	push   %ebx
  8012b9:	83 ec 24             	sub    $0x24,%esp
  8012bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  8012bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c6:	89 1c 24             	mov    %ebx,(%esp)
  8012c9:	e8 58 fd ff ff       	call   801026 <fd_lookup>
  8012ce:	89 c2                	mov    %eax,%edx
  8012d0:	85 d2                	test   %edx,%edx
  8012d2:	78 6d                	js     801341 <read+0x8c>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012de:	8b 00                	mov    (%eax),%eax
  8012e0:	89 04 24             	mov    %eax,(%esp)
  8012e3:	e8 94 fd ff ff       	call   80107c <dev_lookup>
  8012e8:	85 c0                	test   %eax,%eax
  8012ea:	78 55                	js     801341 <read+0x8c>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8012ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ef:	8b 50 08             	mov    0x8(%eax),%edx
  8012f2:	83 e2 03             	and    $0x3,%edx
  8012f5:	83 fa 01             	cmp    $0x1,%edx
  8012f8:	75 23                	jne    80131d <read+0x68>
    cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8012fa:	a1 04 40 80 00       	mov    0x804004,%eax
  8012ff:	8b 40 48             	mov    0x48(%eax),%eax
  801302:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801306:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130a:	c7 04 24 88 25 80 00 	movl   $0x802588,(%esp)
  801311:	e8 38 ef ff ff       	call   80024e <cprintf>
    return -E_INVAL;
  801316:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80131b:	eb 24                	jmp    801341 <read+0x8c>
  }
  if (!dev->dev_read)
  80131d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801320:	8b 52 08             	mov    0x8(%edx),%edx
  801323:	85 d2                	test   %edx,%edx
  801325:	74 15                	je     80133c <read+0x87>
    return -E_NOT_SUPP;
  return (*dev->dev_read)(fd, buf, n);
  801327:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80132a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80132e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801331:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801335:	89 04 24             	mov    %eax,(%esp)
  801338:	ff d2                	call   *%edx
  80133a:	eb 05                	jmp    801341 <read+0x8c>
  if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
    cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  if (!dev->dev_read)
    return -E_NOT_SUPP;
  80133c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_read)(fd, buf, n);
}
  801341:	83 c4 24             	add    $0x24,%esp
  801344:	5b                   	pop    %ebx
  801345:	5d                   	pop    %ebp
  801346:	c3                   	ret    

00801347 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801347:	55                   	push   %ebp
  801348:	89 e5                	mov    %esp,%ebp
  80134a:	57                   	push   %edi
  80134b:	56                   	push   %esi
  80134c:	53                   	push   %ebx
  80134d:	83 ec 1c             	sub    $0x1c,%esp
  801350:	8b 7d 08             	mov    0x8(%ebp),%edi
  801353:	8b 75 10             	mov    0x10(%ebp),%esi
  int m, tot;

  for (tot = 0; tot < n; tot += m) {
  801356:	bb 00 00 00 00       	mov    $0x0,%ebx
  80135b:	eb 23                	jmp    801380 <readn+0x39>
    m = read(fdnum, (char*)buf + tot, n - tot);
  80135d:	89 f0                	mov    %esi,%eax
  80135f:	29 d8                	sub    %ebx,%eax
  801361:	89 44 24 08          	mov    %eax,0x8(%esp)
  801365:	89 d8                	mov    %ebx,%eax
  801367:	03 45 0c             	add    0xc(%ebp),%eax
  80136a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136e:	89 3c 24             	mov    %edi,(%esp)
  801371:	e8 3f ff ff ff       	call   8012b5 <read>
    if (m < 0)
  801376:	85 c0                	test   %eax,%eax
  801378:	78 10                	js     80138a <readn+0x43>
      return m;
    if (m == 0)
  80137a:	85 c0                	test   %eax,%eax
  80137c:	74 0a                	je     801388 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
  int m, tot;

  for (tot = 0; tot < n; tot += m) {
  80137e:	01 c3                	add    %eax,%ebx
  801380:	39 f3                	cmp    %esi,%ebx
  801382:	72 d9                	jb     80135d <readn+0x16>
  801384:	89 d8                	mov    %ebx,%eax
  801386:	eb 02                	jmp    80138a <readn+0x43>
  801388:	89 d8                	mov    %ebx,%eax
      return m;
    if (m == 0)
      break;
  }
  return tot;
}
  80138a:	83 c4 1c             	add    $0x1c,%esp
  80138d:	5b                   	pop    %ebx
  80138e:	5e                   	pop    %esi
  80138f:	5f                   	pop    %edi
  801390:	5d                   	pop    %ebp
  801391:	c3                   	ret    

00801392 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
  801395:	53                   	push   %ebx
  801396:	83 ec 24             	sub    $0x24,%esp
  801399:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  80139c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80139f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a3:	89 1c 24             	mov    %ebx,(%esp)
  8013a6:	e8 7b fc ff ff       	call   801026 <fd_lookup>
  8013ab:	89 c2                	mov    %eax,%edx
  8013ad:	85 d2                	test   %edx,%edx
  8013af:	78 68                	js     801419 <write+0x87>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013bb:	8b 00                	mov    (%eax),%eax
  8013bd:	89 04 24             	mov    %eax,(%esp)
  8013c0:	e8 b7 fc ff ff       	call   80107c <dev_lookup>
  8013c5:	85 c0                	test   %eax,%eax
  8013c7:	78 50                	js     801419 <write+0x87>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013cc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013d0:	75 23                	jne    8013f5 <write+0x63>
    cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013d2:	a1 04 40 80 00       	mov    0x804004,%eax
  8013d7:	8b 40 48             	mov    0x48(%eax),%eax
  8013da:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e2:	c7 04 24 a4 25 80 00 	movl   $0x8025a4,(%esp)
  8013e9:	e8 60 ee ff ff       	call   80024e <cprintf>
    return -E_INVAL;
  8013ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013f3:	eb 24                	jmp    801419 <write+0x87>
  }
  if (debug)
    cprintf("write %d %p %d via dev %s\n",
            fdnum, buf, n, dev->dev_name);
  if (!dev->dev_write)
  8013f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013f8:	8b 52 0c             	mov    0xc(%edx),%edx
  8013fb:	85 d2                	test   %edx,%edx
  8013fd:	74 15                	je     801414 <write+0x82>
    return -E_NOT_SUPP;
  return (*dev->dev_write)(fd, buf, n);
  8013ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801402:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801406:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801409:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80140d:	89 04 24             	mov    %eax,(%esp)
  801410:	ff d2                	call   *%edx
  801412:	eb 05                	jmp    801419 <write+0x87>
  }
  if (debug)
    cprintf("write %d %p %d via dev %s\n",
            fdnum, buf, n, dev->dev_name);
  if (!dev->dev_write)
    return -E_NOT_SUPP;
  801414:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_write)(fd, buf, n);
}
  801419:	83 c4 24             	add    $0x24,%esp
  80141c:	5b                   	pop    %ebx
  80141d:	5d                   	pop    %ebp
  80141e:	c3                   	ret    

0080141f <seek>:

int
seek(int fdnum, off_t offset)
{
  80141f:	55                   	push   %ebp
  801420:	89 e5                	mov    %esp,%ebp
  801422:	83 ec 18             	sub    $0x18,%esp
  int r;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  801425:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801428:	89 44 24 04          	mov    %eax,0x4(%esp)
  80142c:	8b 45 08             	mov    0x8(%ebp),%eax
  80142f:	89 04 24             	mov    %eax,(%esp)
  801432:	e8 ef fb ff ff       	call   801026 <fd_lookup>
  801437:	85 c0                	test   %eax,%eax
  801439:	78 0e                	js     801449 <seek+0x2a>
    return r;
  fd->fd_offset = offset;
  80143b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80143e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801441:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
  801444:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801449:	c9                   	leave  
  80144a:	c3                   	ret    

0080144b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80144b:	55                   	push   %ebp
  80144c:	89 e5                	mov    %esp,%ebp
  80144e:	53                   	push   %ebx
  80144f:	83 ec 24             	sub    $0x24,%esp
  801452:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  801455:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801458:	89 44 24 04          	mov    %eax,0x4(%esp)
  80145c:	89 1c 24             	mov    %ebx,(%esp)
  80145f:	e8 c2 fb ff ff       	call   801026 <fd_lookup>
  801464:	89 c2                	mov    %eax,%edx
  801466:	85 d2                	test   %edx,%edx
  801468:	78 61                	js     8014cb <ftruncate+0x80>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80146a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80146d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801471:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801474:	8b 00                	mov    (%eax),%eax
  801476:	89 04 24             	mov    %eax,(%esp)
  801479:	e8 fe fb ff ff       	call   80107c <dev_lookup>
  80147e:	85 c0                	test   %eax,%eax
  801480:	78 49                	js     8014cb <ftruncate+0x80>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801482:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801485:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801489:	75 23                	jne    8014ae <ftruncate+0x63>
    cprintf("[%08x] ftruncate %d -- bad mode\n",
            thisenv->env_id, fdnum);
  80148b:	a1 04 40 80 00       	mov    0x804004,%eax

  if ((r = fd_lookup(fdnum, &fd)) < 0
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
    cprintf("[%08x] ftruncate %d -- bad mode\n",
  801490:	8b 40 48             	mov    0x48(%eax),%eax
  801493:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801497:	89 44 24 04          	mov    %eax,0x4(%esp)
  80149b:	c7 04 24 64 25 80 00 	movl   $0x802564,(%esp)
  8014a2:	e8 a7 ed ff ff       	call   80024e <cprintf>
            thisenv->env_id, fdnum);
    return -E_INVAL;
  8014a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014ac:	eb 1d                	jmp    8014cb <ftruncate+0x80>
  }
  if (!dev->dev_trunc)
  8014ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014b1:	8b 52 18             	mov    0x18(%edx),%edx
  8014b4:	85 d2                	test   %edx,%edx
  8014b6:	74 0e                	je     8014c6 <ftruncate+0x7b>
    return -E_NOT_SUPP;
  return (*dev->dev_trunc)(fd, newsize);
  8014b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014bb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014bf:	89 04 24             	mov    %eax,(%esp)
  8014c2:	ff d2                	call   *%edx
  8014c4:	eb 05                	jmp    8014cb <ftruncate+0x80>
    cprintf("[%08x] ftruncate %d -- bad mode\n",
            thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  if (!dev->dev_trunc)
    return -E_NOT_SUPP;
  8014c6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_trunc)(fd, newsize);
}
  8014cb:	83 c4 24             	add    $0x24,%esp
  8014ce:	5b                   	pop    %ebx
  8014cf:	5d                   	pop    %ebp
  8014d0:	c3                   	ret    

008014d1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014d1:	55                   	push   %ebp
  8014d2:	89 e5                	mov    %esp,%ebp
  8014d4:	53                   	push   %ebx
  8014d5:	83 ec 24             	sub    $0x24,%esp
  8014d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  8014db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e5:	89 04 24             	mov    %eax,(%esp)
  8014e8:	e8 39 fb ff ff       	call   801026 <fd_lookup>
  8014ed:	89 c2                	mov    %eax,%edx
  8014ef:	85 d2                	test   %edx,%edx
  8014f1:	78 52                	js     801545 <fstat+0x74>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014fd:	8b 00                	mov    (%eax),%eax
  8014ff:	89 04 24             	mov    %eax,(%esp)
  801502:	e8 75 fb ff ff       	call   80107c <dev_lookup>
  801507:	85 c0                	test   %eax,%eax
  801509:	78 3a                	js     801545 <fstat+0x74>
    return r;
  if (!dev->dev_stat)
  80150b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80150e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801512:	74 2c                	je     801540 <fstat+0x6f>
    return -E_NOT_SUPP;
  stat->st_name[0] = 0;
  801514:	c6 03 00             	movb   $0x0,(%ebx)
  stat->st_size = 0;
  801517:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80151e:	00 00 00 
  stat->st_isdir = 0;
  801521:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801528:	00 00 00 
  stat->st_dev = dev;
  80152b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
  return (*dev->dev_stat)(fd, stat);
  801531:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801535:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801538:	89 14 24             	mov    %edx,(%esp)
  80153b:	ff 50 14             	call   *0x14(%eax)
  80153e:	eb 05                	jmp    801545 <fstat+0x74>

  if ((r = fd_lookup(fdnum, &fd)) < 0
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
    return r;
  if (!dev->dev_stat)
    return -E_NOT_SUPP;
  801540:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  stat->st_name[0] = 0;
  stat->st_size = 0;
  stat->st_isdir = 0;
  stat->st_dev = dev;
  return (*dev->dev_stat)(fd, stat);
}
  801545:	83 c4 24             	add    $0x24,%esp
  801548:	5b                   	pop    %ebx
  801549:	5d                   	pop    %ebp
  80154a:	c3                   	ret    

0080154b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80154b:	55                   	push   %ebp
  80154c:	89 e5                	mov    %esp,%ebp
  80154e:	56                   	push   %esi
  80154f:	53                   	push   %ebx
  801550:	83 ec 10             	sub    $0x10,%esp
  int fd, r;

  if ((fd = open(path, O_RDONLY)) < 0)
  801553:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80155a:	00 
  80155b:	8b 45 08             	mov    0x8(%ebp),%eax
  80155e:	89 04 24             	mov    %eax,(%esp)
  801561:	e8 d2 01 00 00       	call   801738 <open>
  801566:	89 c3                	mov    %eax,%ebx
  801568:	85 db                	test   %ebx,%ebx
  80156a:	78 1b                	js     801587 <stat+0x3c>
    return fd;
  r = fstat(fd, stat);
  80156c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80156f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801573:	89 1c 24             	mov    %ebx,(%esp)
  801576:	e8 56 ff ff ff       	call   8014d1 <fstat>
  80157b:	89 c6                	mov    %eax,%esi
  close(fd);
  80157d:	89 1c 24             	mov    %ebx,(%esp)
  801580:	e8 cd fb ff ff       	call   801152 <close>
  return r;
  801585:	89 f0                	mov    %esi,%eax
}
  801587:	83 c4 10             	add    $0x10,%esp
  80158a:	5b                   	pop    %ebx
  80158b:	5e                   	pop    %esi
  80158c:	5d                   	pop    %ebp
  80158d:	c3                   	ret    

0080158e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
  801591:	56                   	push   %esi
  801592:	53                   	push   %ebx
  801593:	83 ec 10             	sub    $0x10,%esp
  801596:	89 c6                	mov    %eax,%esi
  801598:	89 d3                	mov    %edx,%ebx
  static envid_t fsenv;

  if (fsenv == 0)
  80159a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015a1:	75 11                	jne    8015b4 <fsipc+0x26>
    fsenv = ipc_find_env(ENV_TYPE_FS);
  8015a3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8015aa:	e8 48 08 00 00       	call   801df7 <ipc_find_env>
  8015af:	a3 00 40 80 00       	mov    %eax,0x804000
  static_assert(sizeof(fsipcbuf) == PGSIZE);

  if (debug)
    cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t*)&fsipcbuf);

  ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015b4:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8015bb:	00 
  8015bc:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8015c3:	00 
  8015c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015c8:	a1 00 40 80 00       	mov    0x804000,%eax
  8015cd:	89 04 24             	mov    %eax,(%esp)
  8015d0:	e8 b7 07 00 00       	call   801d8c <ipc_send>
  return ipc_recv(NULL, dstva, NULL);
  8015d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015dc:	00 
  8015dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015e8:	e8 19 07 00 00       	call   801d06 <ipc_recv>
}
  8015ed:	83 c4 10             	add    $0x10,%esp
  8015f0:	5b                   	pop    %ebx
  8015f1:	5e                   	pop    %esi
  8015f2:	5d                   	pop    %ebp
  8015f3:	c3                   	ret    

008015f4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8015f4:	55                   	push   %ebp
  8015f5:	89 e5                	mov    %esp,%ebp
  8015f7:	83 ec 08             	sub    $0x8,%esp
  fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8015fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801600:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.set_size.req_size = newsize;
  801605:	8b 45 0c             	mov    0xc(%ebp),%eax
  801608:	a3 04 50 80 00       	mov    %eax,0x805004
  return fsipc(FSREQ_SET_SIZE, NULL);
  80160d:	ba 00 00 00 00       	mov    $0x0,%edx
  801612:	b8 02 00 00 00       	mov    $0x2,%eax
  801617:	e8 72 ff ff ff       	call   80158e <fsipc>
}
  80161c:	c9                   	leave  
  80161d:	c3                   	ret    

0080161e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80161e:	55                   	push   %ebp
  80161f:	89 e5                	mov    %esp,%ebp
  801621:	83 ec 08             	sub    $0x8,%esp
  fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801624:	8b 45 08             	mov    0x8(%ebp),%eax
  801627:	8b 40 0c             	mov    0xc(%eax),%eax
  80162a:	a3 00 50 80 00       	mov    %eax,0x805000
  return fsipc(FSREQ_FLUSH, NULL);
  80162f:	ba 00 00 00 00       	mov    $0x0,%edx
  801634:	b8 06 00 00 00       	mov    $0x6,%eax
  801639:	e8 50 ff ff ff       	call   80158e <fsipc>
}
  80163e:	c9                   	leave  
  80163f:	c3                   	ret    

00801640 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801640:	55                   	push   %ebp
  801641:	89 e5                	mov    %esp,%ebp
  801643:	53                   	push   %ebx
  801644:	83 ec 14             	sub    $0x14,%esp
  801647:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int r;

  fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80164a:	8b 45 08             	mov    0x8(%ebp),%eax
  80164d:	8b 40 0c             	mov    0xc(%eax),%eax
  801650:	a3 00 50 80 00       	mov    %eax,0x805000
  if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801655:	ba 00 00 00 00       	mov    $0x0,%edx
  80165a:	b8 05 00 00 00       	mov    $0x5,%eax
  80165f:	e8 2a ff ff ff       	call   80158e <fsipc>
  801664:	89 c2                	mov    %eax,%edx
  801666:	85 d2                	test   %edx,%edx
  801668:	78 2b                	js     801695 <devfile_stat+0x55>
    return r;
  strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80166a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801671:	00 
  801672:	89 1c 24             	mov    %ebx,(%esp)
  801675:	e8 fd f1 ff ff       	call   800877 <strcpy>
  st->st_size = fsipcbuf.statRet.ret_size;
  80167a:	a1 80 50 80 00       	mov    0x805080,%eax
  80167f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801685:	a1 84 50 80 00       	mov    0x805084,%eax
  80168a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  return 0;
  801690:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801695:	83 c4 14             	add    $0x14,%esp
  801698:	5b                   	pop    %ebx
  801699:	5d                   	pop    %ebp
  80169a:	c3                   	ret    

0080169b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	83 ec 18             	sub    $0x18,%esp
  8016a1:	8b 45 10             	mov    0x10(%ebp),%eax
  // remember that write is always allowed to write *fewer*
  // bytes than requested.
  // LAB 5: Your code here
    int r;

    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8016a7:	8b 52 0c             	mov    0xc(%edx),%edx
  8016aa:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  8016b0:	a3 04 50 80 00       	mov    %eax,0x805004

    size_t max_written = sizeof(fsipcbuf.write.req_buf);
    memmove(fsipcbuf.write.req_buf, buf, MIN(max_written, n));
  8016b5:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8016ba:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8016bf:	0f 47 c2             	cmova  %edx,%eax
  8016c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016cd:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8016d4:	e8 3b f3 ff ff       	call   800a14 <memmove>

    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8016d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016de:	b8 04 00 00 00       	mov    $0x4,%eax
  8016e3:	e8 a6 fe ff ff       	call   80158e <fsipc>
        return r;

    return r;
}
  8016e8:	c9                   	leave  
  8016e9:	c3                   	ret    

008016ea <devfile_read>:
// Returns:
//  The number of bytes successfully read.
//  < 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	53                   	push   %ebx
  8016ee:	83 ec 14             	sub    $0x14,%esp
  // filling fsipcbuf.read with the request arguments.  The
  // bytes read will be written back to fsipcbuf by the file
  // system server.
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f4:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f7:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  8016fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8016ff:	a3 04 50 80 00       	mov    %eax,0x805004
  if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801704:	ba 00 00 00 00       	mov    $0x0,%edx
  801709:	b8 03 00 00 00       	mov    $0x3,%eax
  80170e:	e8 7b fe ff ff       	call   80158e <fsipc>
  801713:	89 c3                	mov    %eax,%ebx
  801715:	85 c0                	test   %eax,%eax
  801717:	78 17                	js     801730 <devfile_read+0x46>
    return r;

  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801719:	89 44 24 08          	mov    %eax,0x8(%esp)
  80171d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801724:	00 
  801725:	8b 45 0c             	mov    0xc(%ebp),%eax
  801728:	89 04 24             	mov    %eax,(%esp)
  80172b:	e8 e4 f2 ff ff       	call   800a14 <memmove>
  return r;
}
  801730:	89 d8                	mov    %ebx,%eax
  801732:	83 c4 14             	add    $0x14,%esp
  801735:	5b                   	pop    %ebx
  801736:	5d                   	pop    %ebp
  801737:	c3                   	ret    

00801738 <open>:
//  The file descriptor index on success
//  -E_BAD_PATH if the path is too long (>= MAXPATHLEN)
//  < 0 for other errors.
int
open(const char *path, int mode)
{
  801738:	55                   	push   %ebp
  801739:	89 e5                	mov    %esp,%ebp
  80173b:	53                   	push   %ebx
  80173c:	83 ec 24             	sub    $0x24,%esp
  80173f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  // file descriptor.

  int r;
  struct Fd *fd;

  if (strlen(path) >= MAXPATHLEN)
  801742:	89 1c 24             	mov    %ebx,(%esp)
  801745:	e8 f6 f0 ff ff       	call   800840 <strlen>
  80174a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80174f:	7f 60                	jg     8017b1 <open+0x79>
    return -E_BAD_PATH;

  if ((r = fd_alloc(&fd)) < 0)
  801751:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801754:	89 04 24             	mov    %eax,(%esp)
  801757:	e8 7b f8 ff ff       	call   800fd7 <fd_alloc>
  80175c:	89 c2                	mov    %eax,%edx
  80175e:	85 d2                	test   %edx,%edx
  801760:	78 54                	js     8017b6 <open+0x7e>
    return r;

  strcpy(fsipcbuf.open.req_path, path);
  801762:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801766:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80176d:	e8 05 f1 ff ff       	call   800877 <strcpy>
  fsipcbuf.open.req_omode = mode;
  801772:	8b 45 0c             	mov    0xc(%ebp),%eax
  801775:	a3 00 54 80 00       	mov    %eax,0x805400

  if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80177a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80177d:	b8 01 00 00 00       	mov    $0x1,%eax
  801782:	e8 07 fe ff ff       	call   80158e <fsipc>
  801787:	89 c3                	mov    %eax,%ebx
  801789:	85 c0                	test   %eax,%eax
  80178b:	79 17                	jns    8017a4 <open+0x6c>
    fd_close(fd, 0);
  80178d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801794:	00 
  801795:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801798:	89 04 24             	mov    %eax,(%esp)
  80179b:	e8 31 f9 ff ff       	call   8010d1 <fd_close>
    return r;
  8017a0:	89 d8                	mov    %ebx,%eax
  8017a2:	eb 12                	jmp    8017b6 <open+0x7e>
  }

  return fd2num(fd);
  8017a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a7:	89 04 24             	mov    %eax,(%esp)
  8017aa:	e8 01 f8 ff ff       	call   800fb0 <fd2num>
  8017af:	eb 05                	jmp    8017b6 <open+0x7e>

  int r;
  struct Fd *fd;

  if (strlen(path) >= MAXPATHLEN)
    return -E_BAD_PATH;
  8017b1:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
    fd_close(fd, 0);
    return r;
  }

  return fd2num(fd);
}
  8017b6:	83 c4 24             	add    $0x24,%esp
  8017b9:	5b                   	pop    %ebx
  8017ba:	5d                   	pop    %ebp
  8017bb:	c3                   	ret    

008017bc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017bc:	55                   	push   %ebp
  8017bd:	89 e5                	mov    %esp,%ebp
  8017bf:	83 ec 08             	sub    $0x8,%esp
  // Ask the file server to update the disk
  // by writing any dirty blocks in the buffer cache.

  return fsipc(FSREQ_SYNC, NULL);
  8017c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c7:	b8 08 00 00 00       	mov    $0x8,%eax
  8017cc:	e8 bd fd ff ff       	call   80158e <fsipc>
}
  8017d1:	c9                   	leave  
  8017d2:	c3                   	ret    

008017d3 <devpipe_stat>:
  return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8017d3:	55                   	push   %ebp
  8017d4:	89 e5                	mov    %esp,%ebp
  8017d6:	56                   	push   %esi
  8017d7:	53                   	push   %ebx
  8017d8:	83 ec 10             	sub    $0x10,%esp
  8017db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct Pipe *p = (struct Pipe*)fd2data(fd);
  8017de:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e1:	89 04 24             	mov    %eax,(%esp)
  8017e4:	e8 d7 f7 ff ff       	call   800fc0 <fd2data>
  8017e9:	89 c6                	mov    %eax,%esi

  strcpy(stat->st_name, "<pipe>");
  8017eb:	c7 44 24 04 d4 25 80 	movl   $0x8025d4,0x4(%esp)
  8017f2:	00 
  8017f3:	89 1c 24             	mov    %ebx,(%esp)
  8017f6:	e8 7c f0 ff ff       	call   800877 <strcpy>
  stat->st_size = p->p_wpos - p->p_rpos;
  8017fb:	8b 46 04             	mov    0x4(%esi),%eax
  8017fe:	2b 06                	sub    (%esi),%eax
  801800:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  stat->st_isdir = 0;
  801806:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80180d:	00 00 00 
  stat->st_dev = &devpipe;
  801810:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801817:	30 80 00 
  return 0;
}
  80181a:	b8 00 00 00 00       	mov    $0x0,%eax
  80181f:	83 c4 10             	add    $0x10,%esp
  801822:	5b                   	pop    %ebx
  801823:	5e                   	pop    %esi
  801824:	5d                   	pop    %ebp
  801825:	c3                   	ret    

00801826 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801826:	55                   	push   %ebp
  801827:	89 e5                	mov    %esp,%ebp
  801829:	53                   	push   %ebx
  80182a:	83 ec 14             	sub    $0x14,%esp
  80182d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  (void)sys_page_unmap(0, fd);
  801830:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801834:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80183b:	e8 fa f4 ff ff       	call   800d3a <sys_page_unmap>
  return sys_page_unmap(0, fd2data(fd));
  801840:	89 1c 24             	mov    %ebx,(%esp)
  801843:	e8 78 f7 ff ff       	call   800fc0 <fd2data>
  801848:	89 44 24 04          	mov    %eax,0x4(%esp)
  80184c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801853:	e8 e2 f4 ff ff       	call   800d3a <sys_page_unmap>
}
  801858:	83 c4 14             	add    $0x14,%esp
  80185b:	5b                   	pop    %ebx
  80185c:	5d                   	pop    %ebp
  80185d:	c3                   	ret    

0080185e <_pipeisclosed>:
  return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	57                   	push   %edi
  801862:	56                   	push   %esi
  801863:	53                   	push   %ebx
  801864:	83 ec 2c             	sub    $0x2c,%esp
  801867:	89 c6                	mov    %eax,%esi
  801869:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  int n, nn, ret;

  while (1) {
    n = thisenv->env_runs;
  80186c:	a1 04 40 80 00       	mov    0x804004,%eax
  801871:	8b 58 58             	mov    0x58(%eax),%ebx
    ret = pageref(fd) == pageref(p);
  801874:	89 34 24             	mov    %esi,(%esp)
  801877:	e8 b3 05 00 00       	call   801e2f <pageref>
  80187c:	89 c7                	mov    %eax,%edi
  80187e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801881:	89 04 24             	mov    %eax,(%esp)
  801884:	e8 a6 05 00 00       	call   801e2f <pageref>
  801889:	39 c7                	cmp    %eax,%edi
  80188b:	0f 94 c2             	sete   %dl
  80188e:	0f b6 c2             	movzbl %dl,%eax
    nn = thisenv->env_runs;
  801891:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801897:	8b 79 58             	mov    0x58(%ecx),%edi
    if (n == nn)
  80189a:	39 fb                	cmp    %edi,%ebx
  80189c:	74 21                	je     8018bf <_pipeisclosed+0x61>
      return ret;
    if (n != nn && ret == 1)
  80189e:	84 d2                	test   %dl,%dl
  8018a0:	74 ca                	je     80186c <_pipeisclosed+0xe>
      cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018a2:	8b 51 58             	mov    0x58(%ecx),%edx
  8018a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018a9:	89 54 24 08          	mov    %edx,0x8(%esp)
  8018ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018b1:	c7 04 24 db 25 80 00 	movl   $0x8025db,(%esp)
  8018b8:	e8 91 e9 ff ff       	call   80024e <cprintf>
  8018bd:	eb ad                	jmp    80186c <_pipeisclosed+0xe>
  }
}
  8018bf:	83 c4 2c             	add    $0x2c,%esp
  8018c2:	5b                   	pop    %ebx
  8018c3:	5e                   	pop    %esi
  8018c4:	5f                   	pop    %edi
  8018c5:	5d                   	pop    %ebp
  8018c6:	c3                   	ret    

008018c7 <devpipe_write>:
  return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018c7:	55                   	push   %ebp
  8018c8:	89 e5                	mov    %esp,%ebp
  8018ca:	57                   	push   %edi
  8018cb:	56                   	push   %esi
  8018cc:	53                   	push   %ebx
  8018cd:	83 ec 1c             	sub    $0x1c,%esp
  8018d0:	8b 75 08             	mov    0x8(%ebp),%esi
  const uint8_t *buf;
  size_t i;
  struct Pipe *p;

  p = (struct Pipe*)fd2data(fd);
  8018d3:	89 34 24             	mov    %esi,(%esp)
  8018d6:	e8 e5 f6 ff ff       	call   800fc0 <fd2data>
  8018db:	89 c3                	mov    %eax,%ebx
  if (debug)
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  8018dd:	bf 00 00 00 00       	mov    $0x0,%edi
  8018e2:	eb 45                	jmp    801929 <devpipe_write+0x62>
    while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
      // pipe is full
      // if all the readers are gone
      // (it's only writers like us now),
      // note eof
      if (_pipeisclosed(fd, p))
  8018e4:	89 da                	mov    %ebx,%edx
  8018e6:	89 f0                	mov    %esi,%eax
  8018e8:	e8 71 ff ff ff       	call   80185e <_pipeisclosed>
  8018ed:	85 c0                	test   %eax,%eax
  8018ef:	75 41                	jne    801932 <devpipe_write+0x6b>
        return 0;
      // yield and see what happens
      if (debug)
        cprintf("devpipe_write yield\n");
      sys_yield();
  8018f1:	e8 7e f3 ff ff       	call   800c74 <sys_yield>
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
    while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8018f6:	8b 43 04             	mov    0x4(%ebx),%eax
  8018f9:	8b 0b                	mov    (%ebx),%ecx
  8018fb:	8d 51 20             	lea    0x20(%ecx),%edx
  8018fe:	39 d0                	cmp    %edx,%eax
  801900:	73 e2                	jae    8018e4 <devpipe_write+0x1d>
        cprintf("devpipe_write yield\n");
      sys_yield();
    }
    // there's room for a byte.  store it.
    // wait to increment wpos until the byte is stored!
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801902:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801905:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801909:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80190c:	99                   	cltd   
  80190d:	c1 ea 1b             	shr    $0x1b,%edx
  801910:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801913:	83 e1 1f             	and    $0x1f,%ecx
  801916:	29 d1                	sub    %edx,%ecx
  801918:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  80191c:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
    p->p_wpos++;
  801920:	83 c0 01             	add    $0x1,%eax
  801923:	89 43 04             	mov    %eax,0x4(%ebx)
  if (debug)
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  801926:	83 c7 01             	add    $0x1,%edi
  801929:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80192c:	75 c8                	jne    8018f6 <devpipe_write+0x2f>
    // wait to increment wpos until the byte is stored!
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
    p->p_wpos++;
  }

  return i;
  80192e:	89 f8                	mov    %edi,%eax
  801930:	eb 05                	jmp    801937 <devpipe_write+0x70>
      // pipe is full
      // if all the readers are gone
      // (it's only writers like us now),
      // note eof
      if (_pipeisclosed(fd, p))
        return 0;
  801932:	b8 00 00 00 00       	mov    $0x0,%eax
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
    p->p_wpos++;
  }

  return i;
}
  801937:	83 c4 1c             	add    $0x1c,%esp
  80193a:	5b                   	pop    %ebx
  80193b:	5e                   	pop    %esi
  80193c:	5f                   	pop    %edi
  80193d:	5d                   	pop    %ebp
  80193e:	c3                   	ret    

0080193f <devpipe_read>:
  return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80193f:	55                   	push   %ebp
  801940:	89 e5                	mov    %esp,%ebp
  801942:	57                   	push   %edi
  801943:	56                   	push   %esi
  801944:	53                   	push   %ebx
  801945:	83 ec 1c             	sub    $0x1c,%esp
  801948:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint8_t *buf;
  size_t i;
  struct Pipe *p;

  p = (struct Pipe*)fd2data(fd);
  80194b:	89 3c 24             	mov    %edi,(%esp)
  80194e:	e8 6d f6 ff ff       	call   800fc0 <fd2data>
  801953:	89 c3                	mov    %eax,%ebx
  if (debug)
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  801955:	be 00 00 00 00       	mov    $0x0,%esi
  80195a:	eb 3d                	jmp    801999 <devpipe_read+0x5a>
    while (p->p_rpos == p->p_wpos) {
      // pipe is empty
      // if we got any data, return it
      if (i > 0)
  80195c:	85 f6                	test   %esi,%esi
  80195e:	74 04                	je     801964 <devpipe_read+0x25>
        return i;
  801960:	89 f0                	mov    %esi,%eax
  801962:	eb 43                	jmp    8019a7 <devpipe_read+0x68>
      // if all the writers are gone, note eof
      if (_pipeisclosed(fd, p))
  801964:	89 da                	mov    %ebx,%edx
  801966:	89 f8                	mov    %edi,%eax
  801968:	e8 f1 fe ff ff       	call   80185e <_pipeisclosed>
  80196d:	85 c0                	test   %eax,%eax
  80196f:	75 31                	jne    8019a2 <devpipe_read+0x63>
        return 0;
      // yield and see what happens
      if (debug)
        cprintf("devpipe_read yield\n");
      sys_yield();
  801971:	e8 fe f2 ff ff       	call   800c74 <sys_yield>
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
    while (p->p_rpos == p->p_wpos) {
  801976:	8b 03                	mov    (%ebx),%eax
  801978:	3b 43 04             	cmp    0x4(%ebx),%eax
  80197b:	74 df                	je     80195c <devpipe_read+0x1d>
        cprintf("devpipe_read yield\n");
      sys_yield();
    }
    // there's a byte.  take it.
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80197d:	99                   	cltd   
  80197e:	c1 ea 1b             	shr    $0x1b,%edx
  801981:	01 d0                	add    %edx,%eax
  801983:	83 e0 1f             	and    $0x1f,%eax
  801986:	29 d0                	sub    %edx,%eax
  801988:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80198d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801990:	88 04 31             	mov    %al,(%ecx,%esi,1)
    p->p_rpos++;
  801993:	83 03 01             	addl   $0x1,(%ebx)
  if (debug)
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  801996:	83 c6 01             	add    $0x1,%esi
  801999:	3b 75 10             	cmp    0x10(%ebp),%esi
  80199c:	75 d8                	jne    801976 <devpipe_read+0x37>
    // there's a byte.  take it.
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
    p->p_rpos++;
  }
  return i;
  80199e:	89 f0                	mov    %esi,%eax
  8019a0:	eb 05                	jmp    8019a7 <devpipe_read+0x68>
      // if we got any data, return it
      if (i > 0)
        return i;
      // if all the writers are gone, note eof
      if (_pipeisclosed(fd, p))
        return 0;
  8019a2:	b8 00 00 00 00       	mov    $0x0,%eax
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
    p->p_rpos++;
  }
  return i;
}
  8019a7:	83 c4 1c             	add    $0x1c,%esp
  8019aa:	5b                   	pop    %ebx
  8019ab:	5e                   	pop    %esi
  8019ac:	5f                   	pop    %edi
  8019ad:	5d                   	pop    %ebp
  8019ae:	c3                   	ret    

008019af <pipe>:
  uint8_t p_buf[PIPEBUFSIZ];    // data buffer
};

int
pipe(int pfd[2])
{
  8019af:	55                   	push   %ebp
  8019b0:	89 e5                	mov    %esp,%ebp
  8019b2:	56                   	push   %esi
  8019b3:	53                   	push   %ebx
  8019b4:	83 ec 30             	sub    $0x30,%esp
  int r;
  struct Fd *fd0, *fd1;
  void *va;

  // allocate the file descriptor table entries
  if ((r = fd_alloc(&fd0)) < 0
  8019b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ba:	89 04 24             	mov    %eax,(%esp)
  8019bd:	e8 15 f6 ff ff       	call   800fd7 <fd_alloc>
  8019c2:	89 c2                	mov    %eax,%edx
  8019c4:	85 d2                	test   %edx,%edx
  8019c6:	0f 88 4d 01 00 00    	js     801b19 <pipe+0x16a>
      || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019cc:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8019d3:	00 
  8019d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019e2:	e8 ac f2 ff ff       	call   800c93 <sys_page_alloc>
  8019e7:	89 c2                	mov    %eax,%edx
  8019e9:	85 d2                	test   %edx,%edx
  8019eb:	0f 88 28 01 00 00    	js     801b19 <pipe+0x16a>
    goto err;

  if ((r = fd_alloc(&fd1)) < 0
  8019f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019f4:	89 04 24             	mov    %eax,(%esp)
  8019f7:	e8 db f5 ff ff       	call   800fd7 <fd_alloc>
  8019fc:	89 c3                	mov    %eax,%ebx
  8019fe:	85 c0                	test   %eax,%eax
  801a00:	0f 88 fe 00 00 00    	js     801b04 <pipe+0x155>
      || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a06:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a0d:	00 
  801a0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a11:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a15:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a1c:	e8 72 f2 ff ff       	call   800c93 <sys_page_alloc>
  801a21:	89 c3                	mov    %eax,%ebx
  801a23:	85 c0                	test   %eax,%eax
  801a25:	0f 88 d9 00 00 00    	js     801b04 <pipe+0x155>
    goto err1;

  // allocate the pipe structure as first data page in both
  va = fd2data(fd0);
  801a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a2e:	89 04 24             	mov    %eax,(%esp)
  801a31:	e8 8a f5 ff ff       	call   800fc0 <fd2data>
  801a36:	89 c6                	mov    %eax,%esi
  if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a38:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a3f:	00 
  801a40:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a44:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a4b:	e8 43 f2 ff ff       	call   800c93 <sys_page_alloc>
  801a50:	89 c3                	mov    %eax,%ebx
  801a52:	85 c0                	test   %eax,%eax
  801a54:	0f 88 97 00 00 00    	js     801af1 <pipe+0x142>
    goto err2;
  if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a5d:	89 04 24             	mov    %eax,(%esp)
  801a60:	e8 5b f5 ff ff       	call   800fc0 <fd2data>
  801a65:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801a6c:	00 
  801a6d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a71:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a78:	00 
  801a79:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a7d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a84:	e8 5e f2 ff ff       	call   800ce7 <sys_page_map>
  801a89:	89 c3                	mov    %eax,%ebx
  801a8b:	85 c0                	test   %eax,%eax
  801a8d:	78 52                	js     801ae1 <pipe+0x132>
    goto err3;

  // set up fd structures
  fd0->fd_dev_id = devpipe.dev_id;
  801a8f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a98:	89 10                	mov    %edx,(%eax)
  fd0->fd_omode = O_RDONLY;
  801a9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a9d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

  fd1->fd_dev_id = devpipe.dev_id;
  801aa4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801aaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aad:	89 10                	mov    %edx,(%eax)
  fd1->fd_omode = O_WRONLY;
  801aaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ab2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

  if (debug)
    cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

  pfd[0] = fd2num(fd0);
  801ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801abc:	89 04 24             	mov    %eax,(%esp)
  801abf:	e8 ec f4 ff ff       	call   800fb0 <fd2num>
  801ac4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ac7:	89 01                	mov    %eax,(%ecx)
  pfd[1] = fd2num(fd1);
  801ac9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801acc:	89 04 24             	mov    %eax,(%esp)
  801acf:	e8 dc f4 ff ff       	call   800fb0 <fd2num>
  801ad4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ad7:	89 41 04             	mov    %eax,0x4(%ecx)
  return 0;
  801ada:	b8 00 00 00 00       	mov    $0x0,%eax
  801adf:	eb 38                	jmp    801b19 <pipe+0x16a>

err3:
  sys_page_unmap(0, va);
  801ae1:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ae5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aec:	e8 49 f2 ff ff       	call   800d3a <sys_page_unmap>
err2:
  sys_page_unmap(0, fd1);
  801af1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801af4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aff:	e8 36 f2 ff ff       	call   800d3a <sys_page_unmap>
err1:
  sys_page_unmap(0, fd0);
  801b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b07:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b12:	e8 23 f2 ff ff       	call   800d3a <sys_page_unmap>
  801b17:	89 d8                	mov    %ebx,%eax
err:
  return r;
}
  801b19:	83 c4 30             	add    $0x30,%esp
  801b1c:	5b                   	pop    %ebx
  801b1d:	5e                   	pop    %esi
  801b1e:	5d                   	pop    %ebp
  801b1f:	c3                   	ret    

00801b20 <pipeisclosed>:
  }
}

int
pipeisclosed(int fdnum)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	83 ec 28             	sub    $0x28,%esp
  struct Fd *fd;
  struct Pipe *p;
  int r;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b26:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b29:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b30:	89 04 24             	mov    %eax,(%esp)
  801b33:	e8 ee f4 ff ff       	call   801026 <fd_lookup>
  801b38:	89 c2                	mov    %eax,%edx
  801b3a:	85 d2                	test   %edx,%edx
  801b3c:	78 15                	js     801b53 <pipeisclosed+0x33>
    return r;
  p = (struct Pipe*)fd2data(fd);
  801b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b41:	89 04 24             	mov    %eax,(%esp)
  801b44:	e8 77 f4 ff ff       	call   800fc0 <fd2data>
  return _pipeisclosed(fd, p);
  801b49:	89 c2                	mov    %eax,%edx
  801b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b4e:	e8 0b fd ff ff       	call   80185e <_pipeisclosed>
}
  801b53:	c9                   	leave  
  801b54:	c3                   	ret    
  801b55:	66 90                	xchg   %ax,%ax
  801b57:	66 90                	xchg   %ax,%ax
  801b59:	66 90                	xchg   %ax,%ax
  801b5b:	66 90                	xchg   %ax,%ax
  801b5d:	66 90                	xchg   %ax,%ax
  801b5f:	90                   	nop

00801b60 <devcons_close>:
  return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  USED(fd);

  return 0;
}
  801b63:	b8 00 00 00 00       	mov    $0x0,%eax
  801b68:	5d                   	pop    %ebp
  801b69:	c3                   	ret    

00801b6a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b6a:	55                   	push   %ebp
  801b6b:	89 e5                	mov    %esp,%ebp
  801b6d:	83 ec 18             	sub    $0x18,%esp
  strcpy(stat->st_name, "<cons>");
  801b70:	c7 44 24 04 f3 25 80 	movl   $0x8025f3,0x4(%esp)
  801b77:	00 
  801b78:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b7b:	89 04 24             	mov    %eax,(%esp)
  801b7e:	e8 f4 ec ff ff       	call   800877 <strcpy>
  return 0;
}
  801b83:	b8 00 00 00 00       	mov    $0x0,%eax
  801b88:	c9                   	leave  
  801b89:	c3                   	ret    

00801b8a <devcons_write>:
  return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b8a:	55                   	push   %ebp
  801b8b:	89 e5                	mov    %esp,%ebp
  801b8d:	57                   	push   %edi
  801b8e:	56                   	push   %esi
  801b8f:	53                   	push   %ebx
  801b90:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  801b96:	bb 00 00 00 00       	mov    $0x0,%ebx
    m = n - tot;
    if (m > sizeof(buf) - 1)
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
  801b9b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  801ba1:	eb 31                	jmp    801bd4 <devcons_write+0x4a>
    m = n - tot;
  801ba3:	8b 75 10             	mov    0x10(%ebp),%esi
  801ba6:	29 de                	sub    %ebx,%esi
    if (m > sizeof(buf) - 1)
  801ba8:	83 fe 7f             	cmp    $0x7f,%esi
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
    m = n - tot;
  801bab:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801bb0:	0f 47 f2             	cmova  %edx,%esi
    if (m > sizeof(buf) - 1)
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
  801bb3:	89 74 24 08          	mov    %esi,0x8(%esp)
  801bb7:	03 45 0c             	add    0xc(%ebp),%eax
  801bba:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bbe:	89 3c 24             	mov    %edi,(%esp)
  801bc1:	e8 4e ee ff ff       	call   800a14 <memmove>
    sys_cputs(buf, m);
  801bc6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bca:	89 3c 24             	mov    %edi,(%esp)
  801bcd:	e8 f4 ef ff ff       	call   800bc6 <sys_cputs>
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  801bd2:	01 f3                	add    %esi,%ebx
  801bd4:	89 d8                	mov    %ebx,%eax
  801bd6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bd9:	72 c8                	jb     801ba3 <devcons_write+0x19>
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
    sys_cputs(buf, m);
  }
  return tot;
}
  801bdb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801be1:	5b                   	pop    %ebx
  801be2:	5e                   	pop    %esi
  801be3:	5f                   	pop    %edi
  801be4:	5d                   	pop    %ebp
  801be5:	c3                   	ret    

00801be6 <devcons_read>:
  return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801be6:	55                   	push   %ebp
  801be7:	89 e5                	mov    %esp,%ebp
  801be9:	83 ec 08             	sub    $0x8,%esp
  int c;

  if (n == 0)
    return 0;
  801bec:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  int c;

  if (n == 0)
  801bf1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bf5:	75 07                	jne    801bfe <devcons_read+0x18>
  801bf7:	eb 2a                	jmp    801c23 <devcons_read+0x3d>
    return 0;

  while ((c = sys_cgetc()) == 0)
    sys_yield();
  801bf9:	e8 76 f0 ff ff       	call   800c74 <sys_yield>
  int c;

  if (n == 0)
    return 0;

  while ((c = sys_cgetc()) == 0)
  801bfe:	66 90                	xchg   %ax,%ax
  801c00:	e8 df ef ff ff       	call   800be4 <sys_cgetc>
  801c05:	85 c0                	test   %eax,%eax
  801c07:	74 f0                	je     801bf9 <devcons_read+0x13>
    sys_yield();
  if (c < 0)
  801c09:	85 c0                	test   %eax,%eax
  801c0b:	78 16                	js     801c23 <devcons_read+0x3d>
    return c;
  if (c == 0x04)        // ctl-d is eof
  801c0d:	83 f8 04             	cmp    $0x4,%eax
  801c10:	74 0c                	je     801c1e <devcons_read+0x38>
    return 0;
  *(char*)vbuf = c;
  801c12:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c15:	88 02                	mov    %al,(%edx)
  return 1;
  801c17:	b8 01 00 00 00       	mov    $0x1,%eax
  801c1c:	eb 05                	jmp    801c23 <devcons_read+0x3d>
  while ((c = sys_cgetc()) == 0)
    sys_yield();
  if (c < 0)
    return c;
  if (c == 0x04)        // ctl-d is eof
    return 0;
  801c1e:	b8 00 00 00 00       	mov    $0x0,%eax
  *(char*)vbuf = c;
  return 1;
}
  801c23:	c9                   	leave  
  801c24:	c3                   	ret    

00801c25 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c25:	55                   	push   %ebp
  801c26:	89 e5                	mov    %esp,%ebp
  801c28:	83 ec 28             	sub    $0x28,%esp
  char c = ch;
  801c2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2e:	88 45 f7             	mov    %al,-0x9(%ebp)

  // Unlike standard Unix's putchar,
  // the cputchar function _always_ outputs to the system console.
  sys_cputs(&c, 1);
  801c31:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801c38:	00 
  801c39:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c3c:	89 04 24             	mov    %eax,(%esp)
  801c3f:	e8 82 ef ff ff       	call   800bc6 <sys_cputs>
}
  801c44:	c9                   	leave  
  801c45:	c3                   	ret    

00801c46 <getchar>:

int
getchar(void)
{
  801c46:	55                   	push   %ebp
  801c47:	89 e5                	mov    %esp,%ebp
  801c49:	83 ec 28             	sub    $0x28,%esp
  int r;

  // JOS does, however, support standard _input_ redirection,
  // allowing the user to redirect script files to the shell and such.
  // getchar() reads a character from file descriptor 0.
  r = read(0, &c, 1);
  801c4c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801c53:	00 
  801c54:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c57:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c5b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c62:	e8 4e f6 ff ff       	call   8012b5 <read>
  if (r < 0)
  801c67:	85 c0                	test   %eax,%eax
  801c69:	78 0f                	js     801c7a <getchar+0x34>
    return r;
  if (r < 1)
  801c6b:	85 c0                	test   %eax,%eax
  801c6d:	7e 06                	jle    801c75 <getchar+0x2f>
    return -E_EOF;
  return c;
  801c6f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c73:	eb 05                	jmp    801c7a <getchar+0x34>
  // getchar() reads a character from file descriptor 0.
  r = read(0, &c, 1);
  if (r < 0)
    return r;
  if (r < 1)
    return -E_EOF;
  801c75:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  /* int r;
  // sys_cgetc does not block, but getchar should.
  while ((r = sys_cgetc()) == 0)
    sys_yield();
  return r; */
}
  801c7a:	c9                   	leave  
  801c7b:	c3                   	ret    

00801c7c <iscons>:
  .dev_stat   =     devcons_stat
};

int
iscons(int fdnum)
{
  801c7c:	55                   	push   %ebp
  801c7d:	89 e5                	mov    %esp,%ebp
  801c7f:	83 ec 28             	sub    $0x28,%esp
  int r;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c82:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c85:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c89:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8c:	89 04 24             	mov    %eax,(%esp)
  801c8f:	e8 92 f3 ff ff       	call   801026 <fd_lookup>
  801c94:	85 c0                	test   %eax,%eax
  801c96:	78 11                	js     801ca9 <iscons+0x2d>
    return r;
  return fd->fd_dev_id == devcons.dev_id;
  801c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ca1:	39 10                	cmp    %edx,(%eax)
  801ca3:	0f 94 c0             	sete   %al
  801ca6:	0f b6 c0             	movzbl %al,%eax
}
  801ca9:	c9                   	leave  
  801caa:	c3                   	ret    

00801cab <opencons>:

int
opencons(void)
{
  801cab:	55                   	push   %ebp
  801cac:	89 e5                	mov    %esp,%ebp
  801cae:	83 ec 28             	sub    $0x28,%esp
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
  801cb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cb4:	89 04 24             	mov    %eax,(%esp)
  801cb7:	e8 1b f3 ff ff       	call   800fd7 <fd_alloc>
    return r;
  801cbc:	89 c2                	mov    %eax,%edx
opencons(void)
{
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
  801cbe:	85 c0                	test   %eax,%eax
  801cc0:	78 40                	js     801d02 <opencons+0x57>
    return r;
  if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cc2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801cc9:	00 
  801cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ccd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cd8:	e8 b6 ef ff ff       	call   800c93 <sys_page_alloc>
    return r;
  801cdd:	89 c2                	mov    %eax,%edx
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
    return r;
  if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cdf:	85 c0                	test   %eax,%eax
  801ce1:	78 1f                	js     801d02 <opencons+0x57>
    return r;
  fd->fd_dev_id = devcons.dev_id;
  801ce3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cec:	89 10                	mov    %edx,(%eax)
  fd->fd_omode = O_RDWR;
  801cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
  return fd2num(fd);
  801cf8:	89 04 24             	mov    %eax,(%esp)
  801cfb:	e8 b0 f2 ff ff       	call   800fb0 <fd2num>
  801d00:	89 c2                	mov    %eax,%edx
}
  801d02:	89 d0                	mov    %edx,%eax
  801d04:	c9                   	leave  
  801d05:	c3                   	ret    

00801d06 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d06:	55                   	push   %ebp
  801d07:	89 e5                	mov    %esp,%ebp
  801d09:	56                   	push   %esi
  801d0a:	53                   	push   %ebx
  801d0b:	83 ec 10             	sub    $0x10,%esp
  801d0e:	8b 75 08             	mov    0x8(%ebp),%esi
  801d11:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;
  801d17:	85 c0                	test   %eax,%eax
  801d19:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801d1e:	0f 44 c2             	cmove  %edx,%eax
  if ((r = sys_ipc_recv(pg)) < 0) {
  801d21:	89 04 24             	mov    %eax,(%esp)
  801d24:	e8 80 f1 ff ff       	call   800ea9 <sys_ipc_recv>
  801d29:	85 c0                	test   %eax,%eax
  801d2b:	79 34                	jns    801d61 <ipc_recv+0x5b>
    if (from_env_store)
  801d2d:	85 f6                	test   %esi,%esi
  801d2f:	74 06                	je     801d37 <ipc_recv+0x31>
      *from_env_store = 0;
  801d31:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (perm_store)
  801d37:	85 db                	test   %ebx,%ebx
  801d39:	74 06                	je     801d41 <ipc_recv+0x3b>
      *perm_store = 0;
  801d3b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    panic("sys_ipc_recv: %e", r);
  801d41:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d45:	c7 44 24 08 ff 25 80 	movl   $0x8025ff,0x8(%esp)
  801d4c:	00 
  801d4d:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801d54:	00 
  801d55:	c7 04 24 10 26 80 00 	movl   $0x802610,(%esp)
  801d5c:	e8 f4 e3 ff ff       	call   800155 <_panic>
  }

  if (from_env_store)
  801d61:	85 f6                	test   %esi,%esi
  801d63:	74 0a                	je     801d6f <ipc_recv+0x69>
    *from_env_store = thisenv->env_ipc_from;
  801d65:	a1 04 40 80 00       	mov    0x804004,%eax
  801d6a:	8b 40 74             	mov    0x74(%eax),%eax
  801d6d:	89 06                	mov    %eax,(%esi)
  if (perm_store)
  801d6f:	85 db                	test   %ebx,%ebx
  801d71:	74 0a                	je     801d7d <ipc_recv+0x77>
    *perm_store |= thisenv->env_ipc_perm;
  801d73:	a1 04 40 80 00       	mov    0x804004,%eax
  801d78:	8b 40 78             	mov    0x78(%eax),%eax
  801d7b:	09 03                	or     %eax,(%ebx)

  return thisenv->env_ipc_value;
  801d7d:	a1 04 40 80 00       	mov    0x804004,%eax
  801d82:	8b 40 70             	mov    0x70(%eax),%eax

}
  801d85:	83 c4 10             	add    $0x10,%esp
  801d88:	5b                   	pop    %ebx
  801d89:	5e                   	pop    %esi
  801d8a:	5d                   	pop    %ebp
  801d8b:	c3                   	ret    

00801d8c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	57                   	push   %edi
  801d90:	56                   	push   %esi
  801d91:	53                   	push   %ebx
  801d92:	83 ec 1c             	sub    $0x1c,%esp
  801d95:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d98:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;
  801d9e:	85 db                	test   %ebx,%ebx
  801da0:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801da5:	0f 44 d8             	cmove  %eax,%ebx

  while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801da8:	eb 2a                	jmp    801dd4 <ipc_send+0x48>
    if (r != -E_IPC_NOT_RECV)
  801daa:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801dad:	74 20                	je     801dcf <ipc_send+0x43>
      panic("ipc_send: %e", r);
  801daf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801db3:	c7 44 24 08 1a 26 80 	movl   $0x80261a,0x8(%esp)
  801dba:	00 
  801dbb:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801dc2:	00 
  801dc3:	c7 04 24 10 26 80 00 	movl   $0x802610,(%esp)
  801dca:	e8 86 e3 ff ff       	call   800155 <_panic>
    sys_yield();
  801dcf:	e8 a0 ee ff ff       	call   800c74 <sys_yield>
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;

  while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801dd4:	8b 45 14             	mov    0x14(%ebp),%eax
  801dd7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ddb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ddf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801de3:	89 3c 24             	mov    %edi,(%esp)
  801de6:	e8 9b f0 ff ff       	call   800e86 <sys_ipc_try_send>
  801deb:	85 c0                	test   %eax,%eax
  801ded:	78 bb                	js     801daa <ipc_send+0x1e>
    if (r != -E_IPC_NOT_RECV)
      panic("ipc_send: %e", r);
    sys_yield();
  }
}
  801def:	83 c4 1c             	add    $0x1c,%esp
  801df2:	5b                   	pop    %ebx
  801df3:	5e                   	pop    %esi
  801df4:	5f                   	pop    %edi
  801df5:	5d                   	pop    %ebp
  801df6:	c3                   	ret    

00801df7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801df7:	55                   	push   %ebp
  801df8:	89 e5                	mov    %esp,%ebp
  801dfa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int i;

  for (i = 0; i < NENV; i++)
  801dfd:	b8 00 00 00 00       	mov    $0x0,%eax
    if (envs[i].env_type == type)
  801e02:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801e05:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e0b:	8b 52 50             	mov    0x50(%edx),%edx
  801e0e:	39 ca                	cmp    %ecx,%edx
  801e10:	75 0d                	jne    801e1f <ipc_find_env+0x28>
      return envs[i].env_id;
  801e12:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e15:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801e1a:	8b 40 40             	mov    0x40(%eax),%eax
  801e1d:	eb 0e                	jmp    801e2d <ipc_find_env+0x36>
envid_t
ipc_find_env(enum EnvType type)
{
  int i;

  for (i = 0; i < NENV; i++)
  801e1f:	83 c0 01             	add    $0x1,%eax
  801e22:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e27:	75 d9                	jne    801e02 <ipc_find_env+0xb>
    if (envs[i].env_type == type)
      return envs[i].env_id;
  return 0;
  801e29:	66 b8 00 00          	mov    $0x0,%ax
}
  801e2d:	5d                   	pop    %ebp
  801e2e:	c3                   	ret    

00801e2f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e2f:	55                   	push   %ebp
  801e30:	89 e5                	mov    %esp,%ebp
  801e32:	8b 55 08             	mov    0x8(%ebp),%edx
  pte_t pte;

  if (!(uvpd[PDX(v)] & PTE_P))
  801e35:	89 d0                	mov    %edx,%eax
  801e37:	c1 e8 16             	shr    $0x16,%eax
  801e3a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
    return 0;
  801e41:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
  pte_t pte;

  if (!(uvpd[PDX(v)] & PTE_P))
  801e46:	f6 c1 01             	test   $0x1,%cl
  801e49:	74 1d                	je     801e68 <pageref+0x39>
    return 0;
  pte = uvpt[PGNUM(v)];
  801e4b:	c1 ea 0c             	shr    $0xc,%edx
  801e4e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  if (!(pte & PTE_P))
  801e55:	f6 c2 01             	test   $0x1,%dl
  801e58:	74 0e                	je     801e68 <pageref+0x39>
    return 0;
  return pages[PGNUM(pte)].pp_ref;
  801e5a:	c1 ea 0c             	shr    $0xc,%edx
  801e5d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e64:	ef 
  801e65:	0f b7 c0             	movzwl %ax,%eax
}
  801e68:	5d                   	pop    %ebp
  801e69:	c3                   	ret    
  801e6a:	66 90                	xchg   %ax,%ax
  801e6c:	66 90                	xchg   %ax,%ax
  801e6e:	66 90                	xchg   %ax,%ax

00801e70 <__udivdi3>:
  801e70:	55                   	push   %ebp
  801e71:	57                   	push   %edi
  801e72:	56                   	push   %esi
  801e73:	83 ec 0c             	sub    $0xc,%esp
  801e76:	8b 44 24 28          	mov    0x28(%esp),%eax
  801e7a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801e7e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801e82:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801e86:	85 c0                	test   %eax,%eax
  801e88:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e8c:	89 ea                	mov    %ebp,%edx
  801e8e:	89 0c 24             	mov    %ecx,(%esp)
  801e91:	75 2d                	jne    801ec0 <__udivdi3+0x50>
  801e93:	39 e9                	cmp    %ebp,%ecx
  801e95:	77 61                	ja     801ef8 <__udivdi3+0x88>
  801e97:	85 c9                	test   %ecx,%ecx
  801e99:	89 ce                	mov    %ecx,%esi
  801e9b:	75 0b                	jne    801ea8 <__udivdi3+0x38>
  801e9d:	b8 01 00 00 00       	mov    $0x1,%eax
  801ea2:	31 d2                	xor    %edx,%edx
  801ea4:	f7 f1                	div    %ecx
  801ea6:	89 c6                	mov    %eax,%esi
  801ea8:	31 d2                	xor    %edx,%edx
  801eaa:	89 e8                	mov    %ebp,%eax
  801eac:	f7 f6                	div    %esi
  801eae:	89 c5                	mov    %eax,%ebp
  801eb0:	89 f8                	mov    %edi,%eax
  801eb2:	f7 f6                	div    %esi
  801eb4:	89 ea                	mov    %ebp,%edx
  801eb6:	83 c4 0c             	add    $0xc,%esp
  801eb9:	5e                   	pop    %esi
  801eba:	5f                   	pop    %edi
  801ebb:	5d                   	pop    %ebp
  801ebc:	c3                   	ret    
  801ebd:	8d 76 00             	lea    0x0(%esi),%esi
  801ec0:	39 e8                	cmp    %ebp,%eax
  801ec2:	77 24                	ja     801ee8 <__udivdi3+0x78>
  801ec4:	0f bd e8             	bsr    %eax,%ebp
  801ec7:	83 f5 1f             	xor    $0x1f,%ebp
  801eca:	75 3c                	jne    801f08 <__udivdi3+0x98>
  801ecc:	8b 74 24 04          	mov    0x4(%esp),%esi
  801ed0:	39 34 24             	cmp    %esi,(%esp)
  801ed3:	0f 86 9f 00 00 00    	jbe    801f78 <__udivdi3+0x108>
  801ed9:	39 d0                	cmp    %edx,%eax
  801edb:	0f 82 97 00 00 00    	jb     801f78 <__udivdi3+0x108>
  801ee1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ee8:	31 d2                	xor    %edx,%edx
  801eea:	31 c0                	xor    %eax,%eax
  801eec:	83 c4 0c             	add    $0xc,%esp
  801eef:	5e                   	pop    %esi
  801ef0:	5f                   	pop    %edi
  801ef1:	5d                   	pop    %ebp
  801ef2:	c3                   	ret    
  801ef3:	90                   	nop
  801ef4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ef8:	89 f8                	mov    %edi,%eax
  801efa:	f7 f1                	div    %ecx
  801efc:	31 d2                	xor    %edx,%edx
  801efe:	83 c4 0c             	add    $0xc,%esp
  801f01:	5e                   	pop    %esi
  801f02:	5f                   	pop    %edi
  801f03:	5d                   	pop    %ebp
  801f04:	c3                   	ret    
  801f05:	8d 76 00             	lea    0x0(%esi),%esi
  801f08:	89 e9                	mov    %ebp,%ecx
  801f0a:	8b 3c 24             	mov    (%esp),%edi
  801f0d:	d3 e0                	shl    %cl,%eax
  801f0f:	89 c6                	mov    %eax,%esi
  801f11:	b8 20 00 00 00       	mov    $0x20,%eax
  801f16:	29 e8                	sub    %ebp,%eax
  801f18:	89 c1                	mov    %eax,%ecx
  801f1a:	d3 ef                	shr    %cl,%edi
  801f1c:	89 e9                	mov    %ebp,%ecx
  801f1e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801f22:	8b 3c 24             	mov    (%esp),%edi
  801f25:	09 74 24 08          	or     %esi,0x8(%esp)
  801f29:	89 d6                	mov    %edx,%esi
  801f2b:	d3 e7                	shl    %cl,%edi
  801f2d:	89 c1                	mov    %eax,%ecx
  801f2f:	89 3c 24             	mov    %edi,(%esp)
  801f32:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801f36:	d3 ee                	shr    %cl,%esi
  801f38:	89 e9                	mov    %ebp,%ecx
  801f3a:	d3 e2                	shl    %cl,%edx
  801f3c:	89 c1                	mov    %eax,%ecx
  801f3e:	d3 ef                	shr    %cl,%edi
  801f40:	09 d7                	or     %edx,%edi
  801f42:	89 f2                	mov    %esi,%edx
  801f44:	89 f8                	mov    %edi,%eax
  801f46:	f7 74 24 08          	divl   0x8(%esp)
  801f4a:	89 d6                	mov    %edx,%esi
  801f4c:	89 c7                	mov    %eax,%edi
  801f4e:	f7 24 24             	mull   (%esp)
  801f51:	39 d6                	cmp    %edx,%esi
  801f53:	89 14 24             	mov    %edx,(%esp)
  801f56:	72 30                	jb     801f88 <__udivdi3+0x118>
  801f58:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f5c:	89 e9                	mov    %ebp,%ecx
  801f5e:	d3 e2                	shl    %cl,%edx
  801f60:	39 c2                	cmp    %eax,%edx
  801f62:	73 05                	jae    801f69 <__udivdi3+0xf9>
  801f64:	3b 34 24             	cmp    (%esp),%esi
  801f67:	74 1f                	je     801f88 <__udivdi3+0x118>
  801f69:	89 f8                	mov    %edi,%eax
  801f6b:	31 d2                	xor    %edx,%edx
  801f6d:	e9 7a ff ff ff       	jmp    801eec <__udivdi3+0x7c>
  801f72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f78:	31 d2                	xor    %edx,%edx
  801f7a:	b8 01 00 00 00       	mov    $0x1,%eax
  801f7f:	e9 68 ff ff ff       	jmp    801eec <__udivdi3+0x7c>
  801f84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f88:	8d 47 ff             	lea    -0x1(%edi),%eax
  801f8b:	31 d2                	xor    %edx,%edx
  801f8d:	83 c4 0c             	add    $0xc,%esp
  801f90:	5e                   	pop    %esi
  801f91:	5f                   	pop    %edi
  801f92:	5d                   	pop    %ebp
  801f93:	c3                   	ret    
  801f94:	66 90                	xchg   %ax,%ax
  801f96:	66 90                	xchg   %ax,%ax
  801f98:	66 90                	xchg   %ax,%ax
  801f9a:	66 90                	xchg   %ax,%ax
  801f9c:	66 90                	xchg   %ax,%ax
  801f9e:	66 90                	xchg   %ax,%ax

00801fa0 <__umoddi3>:
  801fa0:	55                   	push   %ebp
  801fa1:	57                   	push   %edi
  801fa2:	56                   	push   %esi
  801fa3:	83 ec 14             	sub    $0x14,%esp
  801fa6:	8b 44 24 28          	mov    0x28(%esp),%eax
  801faa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801fae:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801fb2:	89 c7                	mov    %eax,%edi
  801fb4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fb8:	8b 44 24 30          	mov    0x30(%esp),%eax
  801fbc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801fc0:	89 34 24             	mov    %esi,(%esp)
  801fc3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fc7:	85 c0                	test   %eax,%eax
  801fc9:	89 c2                	mov    %eax,%edx
  801fcb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801fcf:	75 17                	jne    801fe8 <__umoddi3+0x48>
  801fd1:	39 fe                	cmp    %edi,%esi
  801fd3:	76 4b                	jbe    802020 <__umoddi3+0x80>
  801fd5:	89 c8                	mov    %ecx,%eax
  801fd7:	89 fa                	mov    %edi,%edx
  801fd9:	f7 f6                	div    %esi
  801fdb:	89 d0                	mov    %edx,%eax
  801fdd:	31 d2                	xor    %edx,%edx
  801fdf:	83 c4 14             	add    $0x14,%esp
  801fe2:	5e                   	pop    %esi
  801fe3:	5f                   	pop    %edi
  801fe4:	5d                   	pop    %ebp
  801fe5:	c3                   	ret    
  801fe6:	66 90                	xchg   %ax,%ax
  801fe8:	39 f8                	cmp    %edi,%eax
  801fea:	77 54                	ja     802040 <__umoddi3+0xa0>
  801fec:	0f bd e8             	bsr    %eax,%ebp
  801fef:	83 f5 1f             	xor    $0x1f,%ebp
  801ff2:	75 5c                	jne    802050 <__umoddi3+0xb0>
  801ff4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801ff8:	39 3c 24             	cmp    %edi,(%esp)
  801ffb:	0f 87 e7 00 00 00    	ja     8020e8 <__umoddi3+0x148>
  802001:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802005:	29 f1                	sub    %esi,%ecx
  802007:	19 c7                	sbb    %eax,%edi
  802009:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80200d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802011:	8b 44 24 08          	mov    0x8(%esp),%eax
  802015:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802019:	83 c4 14             	add    $0x14,%esp
  80201c:	5e                   	pop    %esi
  80201d:	5f                   	pop    %edi
  80201e:	5d                   	pop    %ebp
  80201f:	c3                   	ret    
  802020:	85 f6                	test   %esi,%esi
  802022:	89 f5                	mov    %esi,%ebp
  802024:	75 0b                	jne    802031 <__umoddi3+0x91>
  802026:	b8 01 00 00 00       	mov    $0x1,%eax
  80202b:	31 d2                	xor    %edx,%edx
  80202d:	f7 f6                	div    %esi
  80202f:	89 c5                	mov    %eax,%ebp
  802031:	8b 44 24 04          	mov    0x4(%esp),%eax
  802035:	31 d2                	xor    %edx,%edx
  802037:	f7 f5                	div    %ebp
  802039:	89 c8                	mov    %ecx,%eax
  80203b:	f7 f5                	div    %ebp
  80203d:	eb 9c                	jmp    801fdb <__umoddi3+0x3b>
  80203f:	90                   	nop
  802040:	89 c8                	mov    %ecx,%eax
  802042:	89 fa                	mov    %edi,%edx
  802044:	83 c4 14             	add    $0x14,%esp
  802047:	5e                   	pop    %esi
  802048:	5f                   	pop    %edi
  802049:	5d                   	pop    %ebp
  80204a:	c3                   	ret    
  80204b:	90                   	nop
  80204c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802050:	8b 04 24             	mov    (%esp),%eax
  802053:	be 20 00 00 00       	mov    $0x20,%esi
  802058:	89 e9                	mov    %ebp,%ecx
  80205a:	29 ee                	sub    %ebp,%esi
  80205c:	d3 e2                	shl    %cl,%edx
  80205e:	89 f1                	mov    %esi,%ecx
  802060:	d3 e8                	shr    %cl,%eax
  802062:	89 e9                	mov    %ebp,%ecx
  802064:	89 44 24 04          	mov    %eax,0x4(%esp)
  802068:	8b 04 24             	mov    (%esp),%eax
  80206b:	09 54 24 04          	or     %edx,0x4(%esp)
  80206f:	89 fa                	mov    %edi,%edx
  802071:	d3 e0                	shl    %cl,%eax
  802073:	89 f1                	mov    %esi,%ecx
  802075:	89 44 24 08          	mov    %eax,0x8(%esp)
  802079:	8b 44 24 10          	mov    0x10(%esp),%eax
  80207d:	d3 ea                	shr    %cl,%edx
  80207f:	89 e9                	mov    %ebp,%ecx
  802081:	d3 e7                	shl    %cl,%edi
  802083:	89 f1                	mov    %esi,%ecx
  802085:	d3 e8                	shr    %cl,%eax
  802087:	89 e9                	mov    %ebp,%ecx
  802089:	09 f8                	or     %edi,%eax
  80208b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80208f:	f7 74 24 04          	divl   0x4(%esp)
  802093:	d3 e7                	shl    %cl,%edi
  802095:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802099:	89 d7                	mov    %edx,%edi
  80209b:	f7 64 24 08          	mull   0x8(%esp)
  80209f:	39 d7                	cmp    %edx,%edi
  8020a1:	89 c1                	mov    %eax,%ecx
  8020a3:	89 14 24             	mov    %edx,(%esp)
  8020a6:	72 2c                	jb     8020d4 <__umoddi3+0x134>
  8020a8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8020ac:	72 22                	jb     8020d0 <__umoddi3+0x130>
  8020ae:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8020b2:	29 c8                	sub    %ecx,%eax
  8020b4:	19 d7                	sbb    %edx,%edi
  8020b6:	89 e9                	mov    %ebp,%ecx
  8020b8:	89 fa                	mov    %edi,%edx
  8020ba:	d3 e8                	shr    %cl,%eax
  8020bc:	89 f1                	mov    %esi,%ecx
  8020be:	d3 e2                	shl    %cl,%edx
  8020c0:	89 e9                	mov    %ebp,%ecx
  8020c2:	d3 ef                	shr    %cl,%edi
  8020c4:	09 d0                	or     %edx,%eax
  8020c6:	89 fa                	mov    %edi,%edx
  8020c8:	83 c4 14             	add    $0x14,%esp
  8020cb:	5e                   	pop    %esi
  8020cc:	5f                   	pop    %edi
  8020cd:	5d                   	pop    %ebp
  8020ce:	c3                   	ret    
  8020cf:	90                   	nop
  8020d0:	39 d7                	cmp    %edx,%edi
  8020d2:	75 da                	jne    8020ae <__umoddi3+0x10e>
  8020d4:	8b 14 24             	mov    (%esp),%edx
  8020d7:	89 c1                	mov    %eax,%ecx
  8020d9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8020dd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8020e1:	eb cb                	jmp    8020ae <__umoddi3+0x10e>
  8020e3:	90                   	nop
  8020e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020e8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8020ec:	0f 82 0f ff ff ff    	jb     802001 <__umoddi3+0x61>
  8020f2:	e9 1a ff ff ff       	jmp    802011 <__umoddi3+0x71>
