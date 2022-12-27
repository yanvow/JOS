
obj/user/cat.debug:     file format elf32-i386


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
  80002c:	e8 34 01 00 00       	call   800165 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 20             	sub    $0x20,%esp
  80003b:	8b 75 08             	mov    0x8(%ebp),%esi
  long n;
  int r;

  while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80003e:	eb 43                	jmp    800083 <cat+0x50>
    if ((r = write(1, buf, n)) != n)
  800040:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800044:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  80004b:	00 
  80004c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800053:	e8 fa 12 00 00       	call   801352 <write>
  800058:	39 d8                	cmp    %ebx,%eax
  80005a:	74 27                	je     800083 <cat+0x50>
      panic("write error copying %s: %e", s, r);
  80005c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800060:	8b 45 0c             	mov    0xc(%ebp),%eax
  800063:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800067:	c7 44 24 08 00 22 80 	movl   $0x802200,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  800076:	00 
  800077:	c7 04 24 1b 22 80 00 	movl   $0x80221b,(%esp)
  80007e:	e8 43 01 00 00       	call   8001c6 <_panic>
cat(int f, char *s)
{
  long n;
  int r;

  while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  800083:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
  80008a:	00 
  80008b:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  800092:	00 
  800093:	89 34 24             	mov    %esi,(%esp)
  800096:	e8 da 11 00 00       	call   801275 <read>
  80009b:	89 c3                	mov    %eax,%ebx
  80009d:	85 c0                	test   %eax,%eax
  80009f:	7f 9f                	jg     800040 <cat+0xd>
    if ((r = write(1, buf, n)) != n)
      panic("write error copying %s: %e", s, r);
  if (n < 0)
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	79 27                	jns    8000cc <cat+0x99>
    panic("error reading %s: %e", s, n);
  8000a5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b0:	c7 44 24 08 26 22 80 	movl   $0x802226,0x8(%esp)
  8000b7:	00 
  8000b8:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000bf:	00 
  8000c0:	c7 04 24 1b 22 80 00 	movl   $0x80221b,(%esp)
  8000c7:	e8 fa 00 00 00       	call   8001c6 <_panic>
}
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	5b                   	pop    %ebx
  8000d0:	5e                   	pop    %esi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <umain>:

void
umain(int argc, char **argv)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	57                   	push   %edi
  8000d7:	56                   	push   %esi
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 1c             	sub    $0x1c,%esp
  8000dc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int f, i;

  binaryname = "cat";
  8000df:	c7 05 00 30 80 00 3b 	movl   $0x80223b,0x803000
  8000e6:	22 80 00 
  if (argc == 1)
  8000e9:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ed:	74 07                	je     8000f6 <umain+0x23>
  8000ef:	bb 01 00 00 00       	mov    $0x1,%ebx
  8000f4:	eb 62                	jmp    800158 <umain+0x85>
    cat(0, "<stdin>");
  8000f6:	c7 44 24 04 3f 22 80 	movl   $0x80223f,0x4(%esp)
  8000fd:	00 
  8000fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800105:	e8 29 ff ff ff       	call   800033 <cat>
  80010a:	eb 51                	jmp    80015d <umain+0x8a>
  else
    for (i = 1; i < argc; i++) {
      f = open(argv[i], O_RDONLY);
  80010c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800113:	00 
  800114:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  800117:	89 04 24             	mov    %eax,(%esp)
  80011a:	e8 d9 15 00 00       	call   8016f8 <open>
  80011f:	89 c6                	mov    %eax,%esi
      if (f < 0)
  800121:	85 c0                	test   %eax,%eax
  800123:	79 19                	jns    80013e <umain+0x6b>
        printf("can't open %s: %e\n", argv[i], f);
  800125:	89 44 24 08          	mov    %eax,0x8(%esp)
  800129:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80012c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800130:	c7 04 24 47 22 80 00 	movl   $0x802247,(%esp)
  800137:	e8 6c 17 00 00       	call   8018a8 <printf>
  80013c:	eb 17                	jmp    800155 <umain+0x82>
      else {
        cat(f, argv[i]);
  80013e:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  800141:	89 44 24 04          	mov    %eax,0x4(%esp)
  800145:	89 34 24             	mov    %esi,(%esp)
  800148:	e8 e6 fe ff ff       	call   800033 <cat>
        close(f);
  80014d:	89 34 24             	mov    %esi,(%esp)
  800150:	e8 bd 0f 00 00       	call   801112 <close>

  binaryname = "cat";
  if (argc == 1)
    cat(0, "<stdin>");
  else
    for (i = 1; i < argc; i++) {
  800155:	83 c3 01             	add    $0x1,%ebx
  800158:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  80015b:	7c af                	jl     80010c <umain+0x39>
      else {
        cat(f, argv[i]);
        close(f);
      }
    }
}
  80015d:	83 c4 1c             	add    $0x1c,%esp
  800160:	5b                   	pop    %ebx
  800161:	5e                   	pop    %esi
  800162:	5f                   	pop    %edi
  800163:	5d                   	pop    %ebp
  800164:	c3                   	ret    

00800165 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	56                   	push   %esi
  800169:	53                   	push   %ebx
  80016a:	83 ec 10             	sub    $0x10,%esp
  80016d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800170:	8b 75 0c             	mov    0xc(%ebp),%esi
  // set thisenv to point at our Env structure in envs[].
  // LAB 3: Your code here.
  thisenv = envs + ENVX(sys_getenvid());
  800173:	e8 4d 0b 00 00       	call   800cc5 <sys_getenvid>
  800178:	25 ff 03 00 00       	and    $0x3ff,%eax
  80017d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800180:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800185:	a3 20 60 80 00       	mov    %eax,0x806020

  // save the name of the program so that panic() can use it
  if (argc > 0)
  80018a:	85 db                	test   %ebx,%ebx
  80018c:	7e 07                	jle    800195 <libmain+0x30>
    binaryname = argv[0];
  80018e:	8b 06                	mov    (%esi),%eax
  800190:	a3 00 30 80 00       	mov    %eax,0x803000

  // call user main routine
  umain(argc, argv);
  800195:	89 74 24 04          	mov    %esi,0x4(%esp)
  800199:	89 1c 24             	mov    %ebx,(%esp)
  80019c:	e8 32 ff ff ff       	call   8000d3 <umain>

  // exit gracefully
  exit();
  8001a1:	e8 07 00 00 00       	call   8001ad <exit>
}
  8001a6:	83 c4 10             	add    $0x10,%esp
  8001a9:	5b                   	pop    %ebx
  8001aa:	5e                   	pop    %esi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    

008001ad <exit>:
#include <inc/lib.h>

void
exit(void)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	83 ec 18             	sub    $0x18,%esp
  close_all();
  8001b3:	e8 8d 0f 00 00       	call   801145 <close_all>
  sys_env_destroy(0);
  8001b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001bf:	e8 af 0a 00 00       	call   800c73 <sys_env_destroy>
}
  8001c4:	c9                   	leave  
  8001c5:	c3                   	ret    

008001c6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	83 ec 20             	sub    $0x20,%esp
  va_list ap;

  va_start(ap, fmt);
  8001ce:	8d 5d 14             	lea    0x14(%ebp),%ebx

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  8001d1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001d7:	e8 e9 0a 00 00       	call   800cc5 <sys_getenvid>
  8001dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001df:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001ea:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f2:	c7 04 24 64 22 80 00 	movl   $0x802264,(%esp)
  8001f9:	e8 c1 00 00 00       	call   8002bf <cprintf>
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  8001fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800202:	8b 45 10             	mov    0x10(%ebp),%eax
  800205:	89 04 24             	mov    %eax,(%esp)
  800208:	e8 51 00 00 00       	call   80025e <vcprintf>
  cprintf("\n");
  80020d:	c7 04 24 54 26 80 00 	movl   $0x802654,(%esp)
  800214:	e8 a6 00 00 00       	call   8002bf <cprintf>

  // Cause a breakpoint exception
  while (1)
    asm volatile ("int3");
  800219:	cc                   	int3   
  80021a:	eb fd                	jmp    800219 <_panic+0x53>

0080021c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	53                   	push   %ebx
  800220:	83 ec 14             	sub    $0x14,%esp
  800223:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  b->buf[b->idx++] = ch;
  800226:	8b 13                	mov    (%ebx),%edx
  800228:	8d 42 01             	lea    0x1(%edx),%eax
  80022b:	89 03                	mov    %eax,(%ebx)
  80022d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800230:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
  if (b->idx == 256-1) {
  800234:	3d ff 00 00 00       	cmp    $0xff,%eax
  800239:	75 19                	jne    800254 <putch+0x38>
    sys_cputs(b->buf, b->idx);
  80023b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800242:	00 
  800243:	8d 43 08             	lea    0x8(%ebx),%eax
  800246:	89 04 24             	mov    %eax,(%esp)
  800249:	e8 e8 09 00 00       	call   800c36 <sys_cputs>
    b->idx = 0;
  80024e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  }
  b->cnt++;
  800254:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800258:	83 c4 14             	add    $0x14,%esp
  80025b:	5b                   	pop    %ebx
  80025c:	5d                   	pop    %ebp
  80025d:	c3                   	ret    

0080025e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	81 ec 28 01 00 00    	sub    $0x128,%esp
  struct printbuf b;

  b.idx = 0;
  800267:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80026e:	00 00 00 
  b.cnt = 0;
  800271:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800278:	00 00 00 
  vprintfmt((void*)putch, &b, fmt, ap);
  80027b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80027e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800282:	8b 45 08             	mov    0x8(%ebp),%eax
  800285:	89 44 24 08          	mov    %eax,0x8(%esp)
  800289:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80028f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800293:	c7 04 24 1c 02 80 00 	movl   $0x80021c,(%esp)
  80029a:	e8 af 01 00 00       	call   80044e <vprintfmt>
  sys_cputs(b.buf, b.idx);
  80029f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002af:	89 04 24             	mov    %eax,(%esp)
  8002b2:	e8 7f 09 00 00       	call   800c36 <sys_cputs>

  return b.cnt;
}
  8002b7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002bd:	c9                   	leave  
  8002be:	c3                   	ret    

008002bf <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002bf:	55                   	push   %ebp
  8002c0:	89 e5                	mov    %esp,%ebp
  8002c2:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8002c5:	8d 45 0c             	lea    0xc(%ebp),%eax
  cnt = vcprintf(fmt, ap);
  8002c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cf:	89 04 24             	mov    %eax,(%esp)
  8002d2:	e8 87 ff ff ff       	call   80025e <vcprintf>
  va_end(ap);

  return cnt;
}
  8002d7:	c9                   	leave  
  8002d8:	c3                   	ret    
  8002d9:	66 90                	xchg   %ax,%ax
  8002db:	66 90                	xchg   %ax,%ax
  8002dd:	66 90                	xchg   %ax,%ax
  8002df:	90                   	nop

008002e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
         unsigned long long num, unsigned base, int width, int padc)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	53                   	push   %ebx
  8002e6:	83 ec 3c             	sub    $0x3c,%esp
  8002e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ec:	89 d7                	mov    %edx,%edi
  8002ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002f7:	89 c3                	mov    %eax,%ebx
  8002f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ff:	8b 75 14             	mov    0x14(%ebp),%esi
  // first recursively print all preceding (more significant) digits
  if (num >= base)
  800302:	b9 00 00 00 00       	mov    $0x0,%ecx
  800307:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80030a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80030d:	39 d9                	cmp    %ebx,%ecx
  80030f:	72 05                	jb     800316 <printnum+0x36>
  800311:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800314:	77 69                	ja     80037f <printnum+0x9f>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  800316:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800319:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80031d:	83 ee 01             	sub    $0x1,%esi
  800320:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800324:	89 44 24 08          	mov    %eax,0x8(%esp)
  800328:	8b 44 24 08          	mov    0x8(%esp),%eax
  80032c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800330:	89 c3                	mov    %eax,%ebx
  800332:	89 d6                	mov    %edx,%esi
  800334:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800337:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80033a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80033e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800342:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800345:	89 04 24             	mov    %eax,(%esp)
  800348:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80034b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034f:	e8 0c 1c 00 00       	call   801f60 <__udivdi3>
  800354:	89 d9                	mov    %ebx,%ecx
  800356:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80035a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80035e:	89 04 24             	mov    %eax,(%esp)
  800361:	89 54 24 04          	mov    %edx,0x4(%esp)
  800365:	89 fa                	mov    %edi,%edx
  800367:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80036a:	e8 71 ff ff ff       	call   8002e0 <printnum>
  80036f:	eb 1b                	jmp    80038c <printnum+0xac>
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
      putch(padc, putdat);
  800371:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800375:	8b 45 18             	mov    0x18(%ebp),%eax
  800378:	89 04 24             	mov    %eax,(%esp)
  80037b:	ff d3                	call   *%ebx
  80037d:	eb 03                	jmp    800382 <printnum+0xa2>
  80037f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  // first recursively print all preceding (more significant) digits
  if (num >= base)
    printnum(putch, putdat, num / base, base, width - 1, padc);
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
  800382:	83 ee 01             	sub    $0x1,%esi
  800385:	85 f6                	test   %esi,%esi
  800387:	7f e8                	jg     800371 <printnum+0x91>
  800389:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
      putch(padc, putdat);
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  80038c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800390:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800394:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800397:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80039a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a5:	89 04 24             	mov    %eax,(%esp)
  8003a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003af:	e8 dc 1c 00 00       	call   802090 <__umoddi3>
  8003b4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003b8:	0f be 80 87 22 80 00 	movsbl 0x802287(%eax),%eax
  8003bf:	89 04 24             	mov    %eax,(%esp)
  8003c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003c5:	ff d0                	call   *%eax
}
  8003c7:	83 c4 3c             	add    $0x3c,%esp
  8003ca:	5b                   	pop    %ebx
  8003cb:	5e                   	pop    %esi
  8003cc:	5f                   	pop    %edi
  8003cd:	5d                   	pop    %ebp
  8003ce:	c3                   	ret    

008003cf <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
  if (lflag >= 2)
  8003d2:	83 fa 01             	cmp    $0x1,%edx
  8003d5:	7e 0e                	jle    8003e5 <getuint+0x16>
    return va_arg(*ap, unsigned long long);
  8003d7:	8b 10                	mov    (%eax),%edx
  8003d9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003dc:	89 08                	mov    %ecx,(%eax)
  8003de:	8b 02                	mov    (%edx),%eax
  8003e0:	8b 52 04             	mov    0x4(%edx),%edx
  8003e3:	eb 22                	jmp    800407 <getuint+0x38>
  else if (lflag)
  8003e5:	85 d2                	test   %edx,%edx
  8003e7:	74 10                	je     8003f9 <getuint+0x2a>
    return va_arg(*ap, unsigned long);
  8003e9:	8b 10                	mov    (%eax),%edx
  8003eb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ee:	89 08                	mov    %ecx,(%eax)
  8003f0:	8b 02                	mov    (%edx),%eax
  8003f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f7:	eb 0e                	jmp    800407 <getuint+0x38>
  else
    return va_arg(*ap, unsigned int);
  8003f9:	8b 10                	mov    (%eax),%edx
  8003fb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003fe:	89 08                	mov    %ecx,(%eax)
  800400:	8b 02                	mov    (%edx),%eax
  800402:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800407:	5d                   	pop    %ebp
  800408:	c3                   	ret    

00800409 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800409:	55                   	push   %ebp
  80040a:	89 e5                	mov    %esp,%ebp
  80040c:	8b 45 0c             	mov    0xc(%ebp),%eax
  b->cnt++;
  80040f:	83 40 08 01          	addl   $0x1,0x8(%eax)
  if (b->buf < b->ebuf)
  800413:	8b 10                	mov    (%eax),%edx
  800415:	3b 50 04             	cmp    0x4(%eax),%edx
  800418:	73 0a                	jae    800424 <sprintputch+0x1b>
    *b->buf++ = ch;
  80041a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80041d:	89 08                	mov    %ecx,(%eax)
  80041f:	8b 45 08             	mov    0x8(%ebp),%eax
  800422:	88 02                	mov    %al,(%edx)
}
  800424:	5d                   	pop    %ebp
  800425:	c3                   	ret    

00800426 <printfmt>:
  }
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800426:	55                   	push   %ebp
  800427:	89 e5                	mov    %esp,%ebp
  800429:	83 ec 18             	sub    $0x18,%esp
  va_list ap;

  va_start(ap, fmt);
  80042c:	8d 45 14             	lea    0x14(%ebp),%eax
  vprintfmt(putch, putdat, fmt, ap);
  80042f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800433:	8b 45 10             	mov    0x10(%ebp),%eax
  800436:	89 44 24 08          	mov    %eax,0x8(%esp)
  80043a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80043d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800441:	8b 45 08             	mov    0x8(%ebp),%eax
  800444:	89 04 24             	mov    %eax,(%esp)
  800447:	e8 02 00 00 00       	call   80044e <vprintfmt>
  va_end(ap);
}
  80044c:	c9                   	leave  
  80044d:	c3                   	ret    

0080044e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80044e:	55                   	push   %ebp
  80044f:	89 e5                	mov    %esp,%ebp
  800451:	57                   	push   %edi
  800452:	56                   	push   %esi
  800453:	53                   	push   %ebx
  800454:	83 ec 3c             	sub    $0x3c,%esp
  800457:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80045a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80045d:	eb 14                	jmp    800473 <vprintfmt+0x25>
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
      if (ch == '\0')
  80045f:	85 c0                	test   %eax,%eax
  800461:	0f 84 b3 03 00 00    	je     80081a <vprintfmt+0x3cc>
        return;
      putch(ch, putdat);
  800467:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80046b:	89 04 24             	mov    %eax,(%esp)
  80046e:	ff 55 08             	call   *0x8(%ebp)
  unsigned long long num;
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
  800471:	89 f3                	mov    %esi,%ebx
  800473:	8d 73 01             	lea    0x1(%ebx),%esi
  800476:	0f b6 03             	movzbl (%ebx),%eax
  800479:	83 f8 25             	cmp    $0x25,%eax
  80047c:	75 e1                	jne    80045f <vprintfmt+0x11>
  80047e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800482:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800489:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800490:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800497:	ba 00 00 00 00       	mov    $0x0,%edx
  80049c:	eb 1d                	jmp    8004bb <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80049e:	89 de                	mov    %ebx,%esi

    // flag to pad on the right
    case '-':
      padc = '-';
  8004a0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004a4:	eb 15                	jmp    8004bb <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8004a6:	89 de                	mov    %ebx,%esi
      padc = '-';
      goto reswitch;

    // flag to pad with 0's instead of spaces
    case '0':
      padc = '0';
  8004a8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004ac:	eb 0d                	jmp    8004bb <vprintfmt+0x6d>
      altflag = 1;
      goto reswitch;

process_precision:
      if (width < 0)
        width = precision, precision = -1;
  8004ae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004b4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8004bb:	8d 5e 01             	lea    0x1(%esi),%ebx
  8004be:	0f b6 0e             	movzbl (%esi),%ecx
  8004c1:	0f b6 c1             	movzbl %cl,%eax
  8004c4:	83 e9 23             	sub    $0x23,%ecx
  8004c7:	80 f9 55             	cmp    $0x55,%cl
  8004ca:	0f 87 2a 03 00 00    	ja     8007fa <vprintfmt+0x3ac>
  8004d0:	0f b6 c9             	movzbl %cl,%ecx
  8004d3:	ff 24 8d c0 23 80 00 	jmp    *0x8023c0(,%ecx,4)
  8004da:	89 de                	mov    %ebx,%esi
  8004dc:	b9 00 00 00 00       	mov    $0x0,%ecx
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
        precision = precision * 10 + ch - '0';
  8004e1:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004e4:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
        ch = *fmt;
  8004e8:	0f be 06             	movsbl (%esi),%eax
        if (ch < '0' || ch > '9')
  8004eb:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8004ee:	83 fb 09             	cmp    $0x9,%ebx
  8004f1:	77 36                	ja     800529 <vprintfmt+0xdb>
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
  8004f3:	83 c6 01             	add    $0x1,%esi
        precision = precision * 10 + ch - '0';
        ch = *fmt;
        if (ch < '0' || ch > '9')
          break;
      }
  8004f6:	eb e9                	jmp    8004e1 <vprintfmt+0x93>
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
  8004f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fb:	8d 48 04             	lea    0x4(%eax),%ecx
  8004fe:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800501:	8b 00                	mov    (%eax),%eax
  800503:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  800506:	89 de                	mov    %ebx,%esi
      }
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
      goto process_precision;
  800508:	eb 22                	jmp    80052c <vprintfmt+0xde>
  80050a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80050d:	85 c9                	test   %ecx,%ecx
  80050f:	b8 00 00 00 00       	mov    $0x0,%eax
  800514:	0f 49 c1             	cmovns %ecx,%eax
  800517:	89 45 dc             	mov    %eax,-0x24(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80051a:	89 de                	mov    %ebx,%esi
  80051c:	eb 9d                	jmp    8004bb <vprintfmt+0x6d>
  80051e:	89 de                	mov    %ebx,%esi
      if (width < 0)
        width = 0;
      goto reswitch;

    case '#':
      altflag = 1;
  800520:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
      goto reswitch;
  800527:	eb 92                	jmp    8004bb <vprintfmt+0x6d>
  800529:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

process_precision:
      if (width < 0)
  80052c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800530:	79 89                	jns    8004bb <vprintfmt+0x6d>
  800532:	e9 77 ff ff ff       	jmp    8004ae <vprintfmt+0x60>
        width = precision, precision = -1;
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
  800537:	83 c2 01             	add    $0x1,%edx
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80053a:	89 de                	mov    %ebx,%esi
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
      goto reswitch;
  80053c:	e9 7a ff ff ff       	jmp    8004bb <vprintfmt+0x6d>

    // character
    case 'c':
      putch(va_arg(ap, int), putdat);
  800541:	8b 45 14             	mov    0x14(%ebp),%eax
  800544:	8d 50 04             	lea    0x4(%eax),%edx
  800547:	89 55 14             	mov    %edx,0x14(%ebp)
  80054a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80054e:	8b 00                	mov    (%eax),%eax
  800550:	89 04 24             	mov    %eax,(%esp)
  800553:	ff 55 08             	call   *0x8(%ebp)
      break;
  800556:	e9 18 ff ff ff       	jmp    800473 <vprintfmt+0x25>

    // error message
    case 'e':
      err = va_arg(ap, int);
  80055b:	8b 45 14             	mov    0x14(%ebp),%eax
  80055e:	8d 50 04             	lea    0x4(%eax),%edx
  800561:	89 55 14             	mov    %edx,0x14(%ebp)
  800564:	8b 00                	mov    (%eax),%eax
  800566:	99                   	cltd   
  800567:	31 d0                	xor    %edx,%eax
  800569:	29 d0                	sub    %edx,%eax
      if (err < 0)
        err = -err;
      if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80056b:	83 f8 0f             	cmp    $0xf,%eax
  80056e:	7f 0b                	jg     80057b <vprintfmt+0x12d>
  800570:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  800577:	85 d2                	test   %edx,%edx
  800579:	75 20                	jne    80059b <vprintfmt+0x14d>
        printfmt(putch, putdat, "error %d", err);
  80057b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80057f:	c7 44 24 08 9f 22 80 	movl   $0x80229f,0x8(%esp)
  800586:	00 
  800587:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80058b:	8b 45 08             	mov    0x8(%ebp),%eax
  80058e:	89 04 24             	mov    %eax,(%esp)
  800591:	e8 90 fe ff ff       	call   800426 <printfmt>
  800596:	e9 d8 fe ff ff       	jmp    800473 <vprintfmt+0x25>
      else
        printfmt(putch, putdat, "%s", p);
  80059b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80059f:	c7 44 24 08 a8 22 80 	movl   $0x8022a8,0x8(%esp)
  8005a6:	00 
  8005a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ae:	89 04 24             	mov    %eax,(%esp)
  8005b1:	e8 70 fe ff ff       	call   800426 <printfmt>
  8005b6:	e9 b8 fe ff ff       	jmp    800473 <vprintfmt+0x25>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8005bb:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8005be:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005c1:	89 45 d0             	mov    %eax,-0x30(%ebp)
        printfmt(putch, putdat, "%s", p);
      break;

    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
  8005c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cd:	8b 30                	mov    (%eax),%esi
        p = "(null)";
  8005cf:	85 f6                	test   %esi,%esi
  8005d1:	b8 98 22 80 00       	mov    $0x802298,%eax
  8005d6:	0f 44 f0             	cmove  %eax,%esi
      if (width > 0 && padc != '-')
  8005d9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005dd:	0f 84 97 00 00 00    	je     80067a <vprintfmt+0x22c>
  8005e3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005e7:	0f 8e 9b 00 00 00    	jle    800688 <vprintfmt+0x23a>
        for (width -= strnlen(p, precision); width > 0; width--)
  8005ed:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005f1:	89 34 24             	mov    %esi,(%esp)
  8005f4:	e8 cf 02 00 00       	call   8008c8 <strnlen>
  8005f9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005fc:	29 c2                	sub    %eax,%edx
  8005fe:	89 55 d0             	mov    %edx,-0x30(%ebp)
          putch(padc, putdat);
  800601:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800605:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800608:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80060b:	8b 75 08             	mov    0x8(%ebp),%esi
  80060e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800611:	89 d3                	mov    %edx,%ebx
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
  800613:	eb 0f                	jmp    800624 <vprintfmt+0x1d6>
          putch(padc, putdat);
  800615:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800619:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80061c:	89 04 24             	mov    %eax,(%esp)
  80061f:	ff d6                	call   *%esi
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
  800621:	83 eb 01             	sub    $0x1,%ebx
  800624:	85 db                	test   %ebx,%ebx
  800626:	7f ed                	jg     800615 <vprintfmt+0x1c7>
  800628:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80062b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80062e:	85 d2                	test   %edx,%edx
  800630:	b8 00 00 00 00       	mov    $0x0,%eax
  800635:	0f 49 c2             	cmovns %edx,%eax
  800638:	29 c2                	sub    %eax,%edx
  80063a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80063d:	89 d7                	mov    %edx,%edi
  80063f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800642:	eb 50                	jmp    800694 <vprintfmt+0x246>
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
  800644:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800648:	74 1e                	je     800668 <vprintfmt+0x21a>
  80064a:	0f be d2             	movsbl %dl,%edx
  80064d:	83 ea 20             	sub    $0x20,%edx
  800650:	83 fa 5e             	cmp    $0x5e,%edx
  800653:	76 13                	jbe    800668 <vprintfmt+0x21a>
          putch('?', putdat);
  800655:	8b 45 0c             	mov    0xc(%ebp),%eax
  800658:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800663:	ff 55 08             	call   *0x8(%ebp)
  800666:	eb 0d                	jmp    800675 <vprintfmt+0x227>
        else
          putch(ch, putdat);
  800668:	8b 55 0c             	mov    0xc(%ebp),%edx
  80066b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80066f:	89 04 24             	mov    %eax,(%esp)
  800672:	ff 55 08             	call   *0x8(%ebp)
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800675:	83 ef 01             	sub    $0x1,%edi
  800678:	eb 1a                	jmp    800694 <vprintfmt+0x246>
  80067a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80067d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800680:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800683:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800686:	eb 0c                	jmp    800694 <vprintfmt+0x246>
  800688:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80068b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80068e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800691:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800694:	83 c6 01             	add    $0x1,%esi
  800697:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80069b:	0f be c2             	movsbl %dl,%eax
  80069e:	85 c0                	test   %eax,%eax
  8006a0:	74 27                	je     8006c9 <vprintfmt+0x27b>
  8006a2:	85 db                	test   %ebx,%ebx
  8006a4:	78 9e                	js     800644 <vprintfmt+0x1f6>
  8006a6:	83 eb 01             	sub    $0x1,%ebx
  8006a9:	79 99                	jns    800644 <vprintfmt+0x1f6>
  8006ab:	89 f8                	mov    %edi,%eax
  8006ad:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8006b3:	89 c3                	mov    %eax,%ebx
  8006b5:	eb 1a                	jmp    8006d1 <vprintfmt+0x283>
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
        putch(' ', putdat);
  8006b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006bb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006c2:	ff d6                	call   *%esi
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
  8006c4:	83 eb 01             	sub    $0x1,%ebx
  8006c7:	eb 08                	jmp    8006d1 <vprintfmt+0x283>
  8006c9:	89 fb                	mov    %edi,%ebx
  8006cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ce:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006d1:	85 db                	test   %ebx,%ebx
  8006d3:	7f e2                	jg     8006b7 <vprintfmt+0x269>
  8006d5:	89 75 08             	mov    %esi,0x8(%ebp)
  8006d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006db:	e9 93 fd ff ff       	jmp    800473 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  if (lflag >= 2)
  8006e0:	83 fa 01             	cmp    $0x1,%edx
  8006e3:	7e 16                	jle    8006fb <vprintfmt+0x2ad>
    return va_arg(*ap, long long);
  8006e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e8:	8d 50 08             	lea    0x8(%eax),%edx
  8006eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ee:	8b 50 04             	mov    0x4(%eax),%edx
  8006f1:	8b 00                	mov    (%eax),%eax
  8006f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006f6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006f9:	eb 32                	jmp    80072d <vprintfmt+0x2df>
  else if (lflag)
  8006fb:	85 d2                	test   %edx,%edx
  8006fd:	74 18                	je     800717 <vprintfmt+0x2c9>
    return va_arg(*ap, long);
  8006ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800702:	8d 50 04             	lea    0x4(%eax),%edx
  800705:	89 55 14             	mov    %edx,0x14(%ebp)
  800708:	8b 30                	mov    (%eax),%esi
  80070a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80070d:	89 f0                	mov    %esi,%eax
  80070f:	c1 f8 1f             	sar    $0x1f,%eax
  800712:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800715:	eb 16                	jmp    80072d <vprintfmt+0x2df>
  else
    return va_arg(*ap, int);
  800717:	8b 45 14             	mov    0x14(%ebp),%eax
  80071a:	8d 50 04             	lea    0x4(%eax),%edx
  80071d:	89 55 14             	mov    %edx,0x14(%ebp)
  800720:	8b 30                	mov    (%eax),%esi
  800722:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800725:	89 f0                	mov    %esi,%eax
  800727:	c1 f8 1f             	sar    $0x1f,%eax
  80072a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        putch(' ', putdat);
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
  80072d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800730:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      if ((long long)num < 0) {
        putch('-', putdat);
        num = -(long long)num;
      }
      base = 10;
  800733:	b9 0a 00 00 00       	mov    $0xa,%ecx
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
      if ((long long)num < 0) {
  800738:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80073c:	0f 89 80 00 00 00    	jns    8007c2 <vprintfmt+0x374>
        putch('-', putdat);
  800742:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800746:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80074d:	ff 55 08             	call   *0x8(%ebp)
        num = -(long long)num;
  800750:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800753:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800756:	f7 d8                	neg    %eax
  800758:	83 d2 00             	adc    $0x0,%edx
  80075b:	f7 da                	neg    %edx
      }
      base = 10;
  80075d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800762:	eb 5e                	jmp    8007c2 <vprintfmt+0x374>
      goto number;

    // unsigned decimal
    case 'u':
      num = getuint(&ap, lflag);
  800764:	8d 45 14             	lea    0x14(%ebp),%eax
  800767:	e8 63 fc ff ff       	call   8003cf <getuint>
      base = 10;
  80076c:	b9 0a 00 00 00       	mov    $0xa,%ecx
      goto number;
  800771:	eb 4f                	jmp    8007c2 <vprintfmt+0x374>

    // (unsigned) octal
    case 'o':
      num = getuint(&ap, lflag);
  800773:	8d 45 14             	lea    0x14(%ebp),%eax
  800776:	e8 54 fc ff ff       	call   8003cf <getuint>
      base = 8;
  80077b:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800780:	eb 40                	jmp    8007c2 <vprintfmt+0x374>

    // pointer
    case 'p':
      putch('0', putdat);
  800782:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800786:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80078d:	ff 55 08             	call   *0x8(%ebp)
      putch('x', putdat);
  800790:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800794:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80079b:	ff 55 08             	call   *0x8(%ebp)
      num = (unsigned long long)
            (uintptr_t)va_arg(ap, void *);
  80079e:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a1:	8d 50 04             	lea    0x4(%eax),%edx
  8007a4:	89 55 14             	mov    %edx,0x14(%ebp)

    // pointer
    case 'p':
      putch('0', putdat);
      putch('x', putdat);
      num = (unsigned long long)
  8007a7:	8b 00                	mov    (%eax),%eax
  8007a9:	ba 00 00 00 00       	mov    $0x0,%edx
            (uintptr_t)va_arg(ap, void *);
      base = 16;
  8007ae:	b9 10 00 00 00       	mov    $0x10,%ecx
      goto number;
  8007b3:	eb 0d                	jmp    8007c2 <vprintfmt+0x374>

    // (unsigned) hexadecimal
    case 'x':
      num = getuint(&ap, lflag);
  8007b5:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b8:	e8 12 fc ff ff       	call   8003cf <getuint>
      base = 16;
  8007bd:	b9 10 00 00 00       	mov    $0x10,%ecx
number:
      printnum(putch, putdat, num, base, width, padc);
  8007c2:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8007c6:	89 74 24 10          	mov    %esi,0x10(%esp)
  8007ca:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8007cd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8007d1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007d5:	89 04 24             	mov    %eax,(%esp)
  8007d8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007dc:	89 fa                	mov    %edi,%edx
  8007de:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e1:	e8 fa fa ff ff       	call   8002e0 <printnum>
      break;
  8007e6:	e9 88 fc ff ff       	jmp    800473 <vprintfmt+0x25>

    // escaped '%' character
    case '%':
      putch(ch, putdat);
  8007eb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ef:	89 04 24             	mov    %eax,(%esp)
  8007f2:	ff 55 08             	call   *0x8(%ebp)
      break;
  8007f5:	e9 79 fc ff ff       	jmp    800473 <vprintfmt+0x25>

    // unrecognized escape sequence - just print it literally
    default:
      putch('%', putdat);
  8007fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007fe:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800805:	ff 55 08             	call   *0x8(%ebp)
      for (fmt--; fmt[-1] != '%'; fmt--)
  800808:	89 f3                	mov    %esi,%ebx
  80080a:	eb 03                	jmp    80080f <vprintfmt+0x3c1>
  80080c:	83 eb 01             	sub    $0x1,%ebx
  80080f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800813:	75 f7                	jne    80080c <vprintfmt+0x3be>
  800815:	e9 59 fc ff ff       	jmp    800473 <vprintfmt+0x25>
        /* do nothing */;
      break;
    }
  }
}
  80081a:	83 c4 3c             	add    $0x3c,%esp
  80081d:	5b                   	pop    %ebx
  80081e:	5e                   	pop    %esi
  80081f:	5f                   	pop    %edi
  800820:	5d                   	pop    %ebp
  800821:	c3                   	ret    

00800822 <vsnprintf>:
    *b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	83 ec 28             	sub    $0x28,%esp
  800828:	8b 45 08             	mov    0x8(%ebp),%eax
  80082b:	8b 55 0c             	mov    0xc(%ebp),%edx
  struct sprintbuf b = { buf, buf+n-1, 0 };
  80082e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800831:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800835:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800838:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  if (buf == NULL || n < 1)
  80083f:	85 c0                	test   %eax,%eax
  800841:	74 30                	je     800873 <vsnprintf+0x51>
  800843:	85 d2                	test   %edx,%edx
  800845:	7e 2c                	jle    800873 <vsnprintf+0x51>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void*)sprintputch, &b, fmt, ap);
  800847:	8b 45 14             	mov    0x14(%ebp),%eax
  80084a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80084e:	8b 45 10             	mov    0x10(%ebp),%eax
  800851:	89 44 24 08          	mov    %eax,0x8(%esp)
  800855:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800858:	89 44 24 04          	mov    %eax,0x4(%esp)
  80085c:	c7 04 24 09 04 80 00 	movl   $0x800409,(%esp)
  800863:	e8 e6 fb ff ff       	call   80044e <vprintfmt>

  // null terminate the buffer
  *b.buf = '\0';
  800868:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80086b:	c6 00 00             	movb   $0x0,(%eax)

  return b.cnt;
  80086e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800871:	eb 05                	jmp    800878 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  struct sprintbuf b = { buf, buf+n-1, 0 };

  if (buf == NULL || n < 1)
    return -E_INVAL;
  800873:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

  // null terminate the buffer
  *b.buf = '\0';

  return b.cnt;
}
  800878:	c9                   	leave  
  800879:	c3                   	ret    

0080087a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800880:	8d 45 14             	lea    0x14(%ebp),%eax
  rc = vsnprintf(buf, n, fmt, ap);
  800883:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800887:	8b 45 10             	mov    0x10(%ebp),%eax
  80088a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80088e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800891:	89 44 24 04          	mov    %eax,0x4(%esp)
  800895:	8b 45 08             	mov    0x8(%ebp),%eax
  800898:	89 04 24             	mov    %eax,(%esp)
  80089b:	e8 82 ff ff ff       	call   800822 <vsnprintf>
  va_end(ap);

  return rc;
}
  8008a0:	c9                   	leave  
  8008a1:	c3                   	ret    
  8008a2:	66 90                	xchg   %ax,%ax
  8008a4:	66 90                	xchg   %ax,%ax
  8008a6:	66 90                	xchg   %ax,%ax
  8008a8:	66 90                	xchg   %ax,%ax
  8008aa:	66 90                	xchg   %ax,%ax
  8008ac:	66 90                	xchg   %ax,%ax
  8008ae:	66 90                	xchg   %ax,%ax

008008b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for (n = 0; *s != '\0'; s++)
  8008b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bb:	eb 03                	jmp    8008c0 <strlen+0x10>
    n++;
  8008bd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
  int n;

  for (n = 0; *s != '\0'; s++)
  8008c0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008c4:	75 f7                	jne    8008bd <strlen+0xd>
    n++;
  return n;
}
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    

008008c8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d6:	eb 03                	jmp    8008db <strnlen+0x13>
    n++;
  8008d8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008db:	39 d0                	cmp    %edx,%eax
  8008dd:	74 06                	je     8008e5 <strnlen+0x1d>
  8008df:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008e3:	75 f3                	jne    8008d8 <strnlen+0x10>
    n++;
  return n;
}
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	53                   	push   %ebx
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  8008f1:	89 c2                	mov    %eax,%edx
  8008f3:	83 c2 01             	add    $0x1,%edx
  8008f6:	83 c1 01             	add    $0x1,%ecx
  8008f9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008fd:	88 5a ff             	mov    %bl,-0x1(%edx)
  800900:	84 db                	test   %bl,%bl
  800902:	75 ef                	jne    8008f3 <strcpy+0xc>
    /* do nothing */;
  return ret;
}
  800904:	5b                   	pop    %ebx
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	53                   	push   %ebx
  80090b:	83 ec 08             	sub    $0x8,%esp
  80090e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int len = strlen(dst);
  800911:	89 1c 24             	mov    %ebx,(%esp)
  800914:	e8 97 ff ff ff       	call   8008b0 <strlen>

  strcpy(dst + len, src);
  800919:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800920:	01 d8                	add    %ebx,%eax
  800922:	89 04 24             	mov    %eax,(%esp)
  800925:	e8 bd ff ff ff       	call   8008e7 <strcpy>
  return dst;
}
  80092a:	89 d8                	mov    %ebx,%eax
  80092c:	83 c4 08             	add    $0x8,%esp
  80092f:	5b                   	pop    %ebx
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	56                   	push   %esi
  800936:	53                   	push   %ebx
  800937:	8b 75 08             	mov    0x8(%ebp),%esi
  80093a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093d:	89 f3                	mov    %esi,%ebx
  80093f:	03 5d 10             	add    0x10(%ebp),%ebx
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800942:	89 f2                	mov    %esi,%edx
  800944:	eb 0f                	jmp    800955 <strncpy+0x23>
    *dst++ = *src;
  800946:	83 c2 01             	add    $0x1,%edx
  800949:	0f b6 01             	movzbl (%ecx),%eax
  80094c:	88 42 ff             	mov    %al,-0x1(%edx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  80094f:	80 39 01             	cmpb   $0x1,(%ecx)
  800952:	83 d9 ff             	sbb    $0xffffffff,%ecx
{
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800955:	39 da                	cmp    %ebx,%edx
  800957:	75 ed                	jne    800946 <strncpy+0x14>
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  }
  return ret;
}
  800959:	89 f0                	mov    %esi,%eax
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	56                   	push   %esi
  800963:	53                   	push   %ebx
  800964:	8b 75 08             	mov    0x8(%ebp),%esi
  800967:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80096d:	89 f0                	mov    %esi,%eax
  80096f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800973:	85 c9                	test   %ecx,%ecx
  800975:	75 0b                	jne    800982 <strlcpy+0x23>
  800977:	eb 1d                	jmp    800996 <strlcpy+0x37>
    while (--size > 0 && *src != '\0')
      *dst++ = *src++;
  800979:	83 c0 01             	add    $0x1,%eax
  80097c:	83 c2 01             	add    $0x1,%edx
  80097f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
    while (--size > 0 && *src != '\0')
  800982:	39 d8                	cmp    %ebx,%eax
  800984:	74 0b                	je     800991 <strlcpy+0x32>
  800986:	0f b6 0a             	movzbl (%edx),%ecx
  800989:	84 c9                	test   %cl,%cl
  80098b:	75 ec                	jne    800979 <strlcpy+0x1a>
  80098d:	89 c2                	mov    %eax,%edx
  80098f:	eb 02                	jmp    800993 <strlcpy+0x34>
  800991:	89 c2                	mov    %eax,%edx
      *dst++ = *src++;
    *dst = '\0';
  800993:	c6 02 00             	movb   $0x0,(%edx)
  }
  return dst - dst_in;
  800996:	29 f0                	sub    %esi,%eax
}
  800998:	5b                   	pop    %ebx
  800999:	5e                   	pop    %esi
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  while (*p && *p == *q)
  8009a5:	eb 06                	jmp    8009ad <strcmp+0x11>
    p++, q++;
  8009a7:	83 c1 01             	add    $0x1,%ecx
  8009aa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
  while (*p && *p == *q)
  8009ad:	0f b6 01             	movzbl (%ecx),%eax
  8009b0:	84 c0                	test   %al,%al
  8009b2:	74 04                	je     8009b8 <strcmp+0x1c>
  8009b4:	3a 02                	cmp    (%edx),%al
  8009b6:	74 ef                	je     8009a7 <strcmp+0xb>
    p++, q++;
  return (int)((unsigned char)*p - (unsigned char)*q);
  8009b8:	0f b6 c0             	movzbl %al,%eax
  8009bb:	0f b6 12             	movzbl (%edx),%edx
  8009be:	29 d0                	sub    %edx,%eax
}
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	53                   	push   %ebx
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cc:	89 c3                	mov    %eax,%ebx
  8009ce:	03 5d 10             	add    0x10(%ebp),%ebx
  while (n > 0 && *p && *p == *q)
  8009d1:	eb 06                	jmp    8009d9 <strncmp+0x17>
    n--, p++, q++;
  8009d3:	83 c0 01             	add    $0x1,%eax
  8009d6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
  8009d9:	39 d8                	cmp    %ebx,%eax
  8009db:	74 15                	je     8009f2 <strncmp+0x30>
  8009dd:	0f b6 08             	movzbl (%eax),%ecx
  8009e0:	84 c9                	test   %cl,%cl
  8009e2:	74 04                	je     8009e8 <strncmp+0x26>
  8009e4:	3a 0a                	cmp    (%edx),%cl
  8009e6:	74 eb                	je     8009d3 <strncmp+0x11>
    n--, p++, q++;
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  8009e8:	0f b6 00             	movzbl (%eax),%eax
  8009eb:	0f b6 12             	movzbl (%edx),%edx
  8009ee:	29 d0                	sub    %edx,%eax
  8009f0:	eb 05                	jmp    8009f7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
    n--, p++, q++;
  if (n == 0)
    return 0;
  8009f2:	b8 00 00 00 00       	mov    $0x0,%eax
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
}
  8009f7:	5b                   	pop    %ebx
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800a00:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
  800a04:	eb 07                	jmp    800a0d <strchr+0x13>
    if (*s == c)
  800a06:	38 ca                	cmp    %cl,%dl
  800a08:	74 0f                	je     800a19 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  for (; *s; s++)
  800a0a:	83 c0 01             	add    $0x1,%eax
  800a0d:	0f b6 10             	movzbl (%eax),%edx
  800a10:	84 d2                	test   %dl,%dl
  800a12:	75 f2                	jne    800a06 <strchr+0xc>
    if (*s == c)
      return (char*)s;
  return 0;
  800a14:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    

00800a1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
  800a25:	eb 07                	jmp    800a2e <strfind+0x13>
    if (*s == c)
  800a27:	38 ca                	cmp    %cl,%dl
  800a29:	74 0a                	je     800a35 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  for (; *s; s++)
  800a2b:	83 c0 01             	add    $0x1,%eax
  800a2e:	0f b6 10             	movzbl (%eax),%edx
  800a31:	84 d2                	test   %dl,%dl
  800a33:	75 f2                	jne    800a27 <strfind+0xc>
    if (*s == c)
      break;
  return (char*)s;
}
  800a35:	5d                   	pop    %ebp
  800a36:	c3                   	ret    

00800a37 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	57                   	push   %edi
  800a3b:	56                   	push   %esi
  800a3c:	53                   	push   %ebx
  800a3d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a40:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *p;

  if (n == 0)
  800a43:	85 c9                	test   %ecx,%ecx
  800a45:	74 36                	je     800a7d <memset+0x46>
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
  800a47:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a4d:	75 28                	jne    800a77 <memset+0x40>
  800a4f:	f6 c1 03             	test   $0x3,%cl
  800a52:	75 23                	jne    800a77 <memset+0x40>
    c &= 0xFF;
  800a54:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
    c = (c<<24)|(c<<16)|(c<<8)|c;
  800a58:	89 d3                	mov    %edx,%ebx
  800a5a:	c1 e3 08             	shl    $0x8,%ebx
  800a5d:	89 d6                	mov    %edx,%esi
  800a5f:	c1 e6 18             	shl    $0x18,%esi
  800a62:	89 d0                	mov    %edx,%eax
  800a64:	c1 e0 10             	shl    $0x10,%eax
  800a67:	09 f0                	or     %esi,%eax
  800a69:	09 c2                	or     %eax,%edx
  800a6b:	89 d0                	mov    %edx,%eax
  800a6d:	09 d8                	or     %ebx,%eax
    asm volatile ("cld; rep stosl\n"
                  :: "D" (v), "a" (c), "c" (n/4)
  800a6f:	c1 e9 02             	shr    $0x2,%ecx
  if (n == 0)
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
    c &= 0xFF;
    c = (c<<24)|(c<<16)|(c<<8)|c;
    asm volatile ("cld; rep stosl\n"
  800a72:	fc                   	cld    
  800a73:	f3 ab                	rep stos %eax,%es:(%edi)
  800a75:	eb 06                	jmp    800a7d <memset+0x46>
                  :: "D" (v), "a" (c), "c" (n/4)
                  : "cc", "memory");
  } else
    asm volatile ("cld; rep stosb\n"
  800a77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7a:	fc                   	cld    
  800a7b:	f3 aa                	rep stos %al,%es:(%edi)
                  :: "D" (v), "a" (c), "c" (n)
                  : "cc", "memory");
  return v;
}
  800a7d:	89 f8                	mov    %edi,%eax
  800a7f:	5b                   	pop    %ebx
  800a80:	5e                   	pop    %esi
  800a81:	5f                   	pop    %edi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	57                   	push   %edi
  800a88:	56                   	push   %esi
  800a89:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800a92:	39 c6                	cmp    %eax,%esi
  800a94:	73 35                	jae    800acb <memmove+0x47>
  800a96:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a99:	39 d0                	cmp    %edx,%eax
  800a9b:	73 2e                	jae    800acb <memmove+0x47>
    s += n;
    d += n;
  800a9d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800aa0:	89 d6                	mov    %edx,%esi
  800aa2:	09 fe                	or     %edi,%esi
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aaa:	75 13                	jne    800abf <memmove+0x3b>
  800aac:	f6 c1 03             	test   $0x3,%cl
  800aaf:	75 0e                	jne    800abf <memmove+0x3b>
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ab1:	83 ef 04             	sub    $0x4,%edi
  800ab4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ab7:	c1 e9 02             	shr    $0x2,%ecx
  d = dst;
  if (s < d && s + n > d) {
    s += n;
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
  800aba:	fd                   	std    
  800abb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800abd:	eb 09                	jmp    800ac8 <memmove+0x44>
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800abf:	83 ef 01             	sub    $0x1,%edi
  800ac2:	8d 72 ff             	lea    -0x1(%edx),%esi
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
  800ac5:	fd                   	std    
  800ac6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  800ac8:	fc                   	cld    
  800ac9:	eb 1d                	jmp    800ae8 <memmove+0x64>
  800acb:	89 f2                	mov    %esi,%edx
  800acd:	09 c2                	or     %eax,%edx
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800acf:	f6 c2 03             	test   $0x3,%dl
  800ad2:	75 0f                	jne    800ae3 <memmove+0x5f>
  800ad4:	f6 c1 03             	test   $0x3,%cl
  800ad7:	75 0a                	jne    800ae3 <memmove+0x5f>
      asm volatile ("cld; rep movsl\n"
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ad9:	c1 e9 02             	shr    $0x2,%ecx
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("cld; rep movsl\n"
  800adc:	89 c7                	mov    %eax,%edi
  800ade:	fc                   	cld    
  800adf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae1:	eb 05                	jmp    800ae8 <memmove+0x64>
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("cld; rep movsb\n"
  800ae3:	89 c7                	mov    %eax,%edi
  800ae5:	fc                   	cld    
  800ae6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d), "S" (s), "c" (n) : "cc", "memory");
  }
  return dst;
}
  800ae8:	5e                   	pop    %esi
  800ae9:	5f                   	pop    %edi
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    

00800aec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
  800af2:	8b 45 10             	mov    0x10(%ebp),%eax
  800af5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800af9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b00:	8b 45 08             	mov    0x8(%ebp),%eax
  800b03:	89 04 24             	mov    %eax,(%esp)
  800b06:	e8 79 ff ff ff       	call   800a84 <memmove>
}
  800b0b:	c9                   	leave  
  800b0c:	c3                   	ret    

00800b0d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
  800b12:	8b 55 08             	mov    0x8(%ebp),%edx
  800b15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b18:	89 d6                	mov    %edx,%esi
  800b1a:	03 75 10             	add    0x10(%ebp),%esi
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
  800b1d:	eb 1a                	jmp    800b39 <memcmp+0x2c>
    if (*s1 != *s2)
  800b1f:	0f b6 02             	movzbl (%edx),%eax
  800b22:	0f b6 19             	movzbl (%ecx),%ebx
  800b25:	38 d8                	cmp    %bl,%al
  800b27:	74 0a                	je     800b33 <memcmp+0x26>
      return (int)*s1 - (int)*s2;
  800b29:	0f b6 c0             	movzbl %al,%eax
  800b2c:	0f b6 db             	movzbl %bl,%ebx
  800b2f:	29 d8                	sub    %ebx,%eax
  800b31:	eb 0f                	jmp    800b42 <memcmp+0x35>
    s1++, s2++;
  800b33:	83 c2 01             	add    $0x1,%edx
  800b36:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
  800b39:	39 f2                	cmp    %esi,%edx
  800b3b:	75 e2                	jne    800b1f <memcmp+0x12>
    if (*s1 != *s2)
      return (int)*s1 - (int)*s2;
    s1++, s2++;
  }

  return 0;
  800b3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  const void *ends = (const char*)s + n;
  800b4f:	89 c2                	mov    %eax,%edx
  800b51:	03 55 10             	add    0x10(%ebp),%edx

  for (; s < ends; s++)
  800b54:	eb 07                	jmp    800b5d <memfind+0x17>
    if (*(const unsigned char*)s == (unsigned char)c)
  800b56:	38 08                	cmp    %cl,(%eax)
  800b58:	74 07                	je     800b61 <memfind+0x1b>
void *
memfind(const void *s, int c, size_t n)
{
  const void *ends = (const char*)s + n;

  for (; s < ends; s++)
  800b5a:	83 c0 01             	add    $0x1,%eax
  800b5d:	39 d0                	cmp    %edx,%eax
  800b5f:	72 f5                	jb     800b56 <memfind+0x10>
    if (*(const unsigned char*)s == (unsigned char)c)
      break;
  return (void*)s;
}
  800b61:	5d                   	pop    %ebp
  800b62:	c3                   	ret    

00800b63 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	57                   	push   %edi
  800b67:	56                   	push   %esi
  800b68:	53                   	push   %ebx
  800b69:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6c:	8b 45 10             	mov    0x10(%ebp),%eax
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800b6f:	eb 03                	jmp    800b74 <strtol+0x11>
    s++;
  800b71:	83 c2 01             	add    $0x1,%edx
{
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800b74:	0f b6 0a             	movzbl (%edx),%ecx
  800b77:	80 f9 09             	cmp    $0x9,%cl
  800b7a:	74 f5                	je     800b71 <strtol+0xe>
  800b7c:	80 f9 20             	cmp    $0x20,%cl
  800b7f:	74 f0                	je     800b71 <strtol+0xe>
    s++;

  // plus/minus sign
  if (*s == '+')
  800b81:	80 f9 2b             	cmp    $0x2b,%cl
  800b84:	75 0a                	jne    800b90 <strtol+0x2d>
    s++;
  800b86:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
  int neg = 0;
  800b89:	bf 00 00 00 00       	mov    $0x0,%edi
  800b8e:	eb 11                	jmp    800ba1 <strtol+0x3e>
  800b90:	bf 00 00 00 00       	mov    $0x0,%edi
    s++;

  // plus/minus sign
  if (*s == '+')
    s++;
  else if (*s == '-')
  800b95:	80 f9 2d             	cmp    $0x2d,%cl
  800b98:	75 07                	jne    800ba1 <strtol+0x3e>
    s++, neg = 1;
  800b9a:	8d 52 01             	lea    0x1(%edx),%edx
  800b9d:	66 bf 01 00          	mov    $0x1,%di

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800ba6:	75 15                	jne    800bbd <strtol+0x5a>
  800ba8:	80 3a 30             	cmpb   $0x30,(%edx)
  800bab:	75 10                	jne    800bbd <strtol+0x5a>
  800bad:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bb1:	75 0a                	jne    800bbd <strtol+0x5a>
    s += 2, base = 16;
  800bb3:	83 c2 02             	add    $0x2,%edx
  800bb6:	b8 10 00 00 00       	mov    $0x10,%eax
  800bbb:	eb 10                	jmp    800bcd <strtol+0x6a>
  else if (base == 0 && s[0] == '0')
  800bbd:	85 c0                	test   %eax,%eax
  800bbf:	75 0c                	jne    800bcd <strtol+0x6a>
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800bc1:	b0 0a                	mov    $0xa,%al
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
  800bc3:	80 3a 30             	cmpb   $0x30,(%edx)
  800bc6:	75 05                	jne    800bcd <strtol+0x6a>
    s++, base = 8;
  800bc8:	83 c2 01             	add    $0x1,%edx
  800bcb:	b0 08                	mov    $0x8,%al
  else if (base == 0)
    base = 10;
  800bcd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd2:	89 45 10             	mov    %eax,0x10(%ebp)

  // digits
  while (1) {
    int dig;

    if (*s >= '0' && *s <= '9')
  800bd5:	0f b6 0a             	movzbl (%edx),%ecx
  800bd8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800bdb:	89 f0                	mov    %esi,%eax
  800bdd:	3c 09                	cmp    $0x9,%al
  800bdf:	77 08                	ja     800be9 <strtol+0x86>
      dig = *s - '0';
  800be1:	0f be c9             	movsbl %cl,%ecx
  800be4:	83 e9 30             	sub    $0x30,%ecx
  800be7:	eb 20                	jmp    800c09 <strtol+0xa6>
    else if (*s >= 'a' && *s <= 'z')
  800be9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800bec:	89 f0                	mov    %esi,%eax
  800bee:	3c 19                	cmp    $0x19,%al
  800bf0:	77 08                	ja     800bfa <strtol+0x97>
      dig = *s - 'a' + 10;
  800bf2:	0f be c9             	movsbl %cl,%ecx
  800bf5:	83 e9 57             	sub    $0x57,%ecx
  800bf8:	eb 0f                	jmp    800c09 <strtol+0xa6>
    else if (*s >= 'A' && *s <= 'Z')
  800bfa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800bfd:	89 f0                	mov    %esi,%eax
  800bff:	3c 19                	cmp    $0x19,%al
  800c01:	77 16                	ja     800c19 <strtol+0xb6>
      dig = *s - 'A' + 10;
  800c03:	0f be c9             	movsbl %cl,%ecx
  800c06:	83 e9 37             	sub    $0x37,%ecx
    else
      break;
    if (dig >= base)
  800c09:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800c0c:	7d 0f                	jge    800c1d <strtol+0xba>
      break;
    s++, val = (val * base) + dig;
  800c0e:	83 c2 01             	add    $0x1,%edx
  800c11:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800c15:	01 cb                	add    %ecx,%ebx
    // we don't properly detect overflow!
  }
  800c17:	eb bc                	jmp    800bd5 <strtol+0x72>
  800c19:	89 d8                	mov    %ebx,%eax
  800c1b:	eb 02                	jmp    800c1f <strtol+0xbc>
  800c1d:	89 d8                	mov    %ebx,%eax

  if (endptr)
  800c1f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c23:	74 05                	je     800c2a <strtol+0xc7>
    *endptr = (char*)s;
  800c25:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c28:	89 16                	mov    %edx,(%esi)
  return neg ? -val : val;
  800c2a:	f7 d8                	neg    %eax
  800c2c:	85 ff                	test   %edi,%edi
  800c2e:	0f 44 c3             	cmove  %ebx,%eax
}
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <sys_cputs>:
  return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800c3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c44:	8b 55 08             	mov    0x8(%ebp),%edx
  800c47:	89 c3                	mov    %eax,%ebx
  800c49:	89 c7                	mov    %eax,%edi
  800c4b:	89 c6                	mov    %eax,%esi
  800c4d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
  syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c4f:	5b                   	pop    %ebx
  800c50:	5e                   	pop    %esi
  800c51:	5f                   	pop    %edi
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    

00800c54 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	57                   	push   %edi
  800c58:	56                   	push   %esi
  800c59:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800c5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c64:	89 d1                	mov    %edx,%ecx
  800c66:	89 d3                	mov    %edx,%ebx
  800c68:	89 d7                	mov    %edx,%edi
  800c6a:	89 d6                	mov    %edx,%esi
  800c6c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c6e:	5b                   	pop    %ebx
  800c6f:	5e                   	pop    %esi
  800c70:	5f                   	pop    %edi
  800c71:	5d                   	pop    %ebp
  800c72:	c3                   	ret    

00800c73 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	57                   	push   %edi
  800c77:	56                   	push   %esi
  800c78:	53                   	push   %ebx
  800c79:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800c7c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c81:	b8 03 00 00 00       	mov    $0x3,%eax
  800c86:	8b 55 08             	mov    0x8(%ebp),%edx
  800c89:	89 cb                	mov    %ecx,%ebx
  800c8b:	89 cf                	mov    %ecx,%edi
  800c8d:	89 ce                	mov    %ecx,%esi
  800c8f:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800c91:	85 c0                	test   %eax,%eax
  800c93:	7e 28                	jle    800cbd <sys_env_destroy+0x4a>
    panic("syscall %d returned %d (> 0)", num, ret);
  800c95:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c99:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ca0:	00 
  800ca1:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  800ca8:	00 
  800ca9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cb0:	00 
  800cb1:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800cb8:	e8 09 f5 ff ff       	call   8001c6 <_panic>

int
sys_env_destroy(envid_t envid)
{
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cbd:	83 c4 2c             	add    $0x2c,%esp
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800ccb:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd0:	b8 02 00 00 00       	mov    $0x2,%eax
  800cd5:	89 d1                	mov    %edx,%ecx
  800cd7:	89 d3                	mov    %edx,%ebx
  800cd9:	89 d7                	mov    %edx,%edi
  800cdb:	89 d6                	mov    %edx,%esi
  800cdd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <sys_yield>:

void
sys_yield(void)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800cea:	ba 00 00 00 00       	mov    $0x0,%edx
  800cef:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cf4:	89 d1                	mov    %edx,%ecx
  800cf6:	89 d3                	mov    %edx,%ebx
  800cf8:	89 d7                	mov    %edx,%edi
  800cfa:	89 d6                	mov    %edx,%esi
  800cfc:	cd 30                	int    $0x30

void
sys_yield(void)
{
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
  800d09:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800d0c:	be 00 00 00 00       	mov    $0x0,%esi
  800d11:	b8 04 00 00 00       	mov    $0x4,%eax
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1f:	89 f7                	mov    %esi,%edi
  800d21:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800d23:	85 c0                	test   %eax,%eax
  800d25:	7e 28                	jle    800d4f <sys_page_alloc+0x4c>
    panic("syscall %d returned %d (> 0)", num, ret);
  800d27:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d32:	00 
  800d33:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  800d3a:	00 
  800d3b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d42:	00 
  800d43:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800d4a:	e8 77 f4 ff ff       	call   8001c6 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  return syscall(SYS_page_alloc, 1, envid, (uint32_t)va, perm, 0, 0);
}
  800d4f:	83 c4 2c             	add    $0x2c,%esp
  800d52:	5b                   	pop    %ebx
  800d53:	5e                   	pop    %esi
  800d54:	5f                   	pop    %edi
  800d55:	5d                   	pop    %ebp
  800d56:	c3                   	ret    

00800d57 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	57                   	push   %edi
  800d5b:	56                   	push   %esi
  800d5c:	53                   	push   %ebx
  800d5d:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800d60:	b8 05 00 00 00       	mov    $0x5,%eax
  800d65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d68:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d6e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d71:	8b 75 18             	mov    0x18(%ebp),%esi
  800d74:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800d76:	85 c0                	test   %eax,%eax
  800d78:	7e 28                	jle    800da2 <sys_page_map+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800d7a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d7e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d85:	00 
  800d86:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  800d8d:	00 
  800d8e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d95:	00 
  800d96:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800d9d:	e8 24 f4 ff ff       	call   8001c6 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  return syscall(SYS_page_map, 1, srcenv, (uint32_t)srcva, dstenv, (uint32_t)dstva, perm);
}
  800da2:	83 c4 2c             	add    $0x2c,%esp
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	57                   	push   %edi
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
  800db0:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800db3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db8:	b8 06 00 00 00       	mov    $0x6,%eax
  800dbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc3:	89 df                	mov    %ebx,%edi
  800dc5:	89 de                	mov    %ebx,%esi
  800dc7:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800dc9:	85 c0                	test   %eax,%eax
  800dcb:	7e 28                	jle    800df5 <sys_page_unmap+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800dcd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800dd8:	00 
  800dd9:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  800de0:	00 
  800de1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de8:	00 
  800de9:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800df0:	e8 d1 f3 ff ff       	call   8001c6 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
  return syscall(SYS_page_unmap, 1, envid, (uint32_t)va, 0, 0, 0);
}
  800df5:	83 c4 2c             	add    $0x2c,%esp
  800df8:	5b                   	pop    %ebx
  800df9:	5e                   	pop    %esi
  800dfa:	5f                   	pop    %edi
  800dfb:	5d                   	pop    %ebp
  800dfc:	c3                   	ret    

00800dfd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	57                   	push   %edi
  800e01:	56                   	push   %esi
  800e02:	53                   	push   %ebx
  800e03:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800e06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e13:	8b 55 08             	mov    0x8(%ebp),%edx
  800e16:	89 df                	mov    %ebx,%edi
  800e18:	89 de                	mov    %ebx,%esi
  800e1a:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800e1c:	85 c0                	test   %eax,%eax
  800e1e:	7e 28                	jle    800e48 <sys_env_set_status+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800e20:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e24:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e2b:	00 
  800e2c:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  800e33:	00 
  800e34:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e3b:	00 
  800e3c:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800e43:	e8 7e f3 ff ff       	call   8001c6 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e48:	83 c4 2c             	add    $0x2c,%esp
  800e4b:	5b                   	pop    %ebx
  800e4c:	5e                   	pop    %esi
  800e4d:	5f                   	pop    %edi
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    

00800e50 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	57                   	push   %edi
  800e54:	56                   	push   %esi
  800e55:	53                   	push   %ebx
  800e56:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800e59:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5e:	b8 09 00 00 00       	mov    $0x9,%eax
  800e63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e66:	8b 55 08             	mov    0x8(%ebp),%edx
  800e69:	89 df                	mov    %ebx,%edi
  800e6b:	89 de                	mov    %ebx,%esi
  800e6d:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	7e 28                	jle    800e9b <sys_env_set_trapframe+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800e73:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e77:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e7e:	00 
  800e7f:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  800e86:	00 
  800e87:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e8e:	00 
  800e8f:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800e96:	e8 2b f3 ff ff       	call   8001c6 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t)tf, 0, 0, 0);
}
  800e9b:	83 c4 2c             	add    $0x2c,%esp
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5f                   	pop    %edi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	57                   	push   %edi
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
  800ea9:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800eac:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebc:	89 df                	mov    %ebx,%edi
  800ebe:	89 de                	mov    %ebx,%esi
  800ec0:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	7e 28                	jle    800eee <sys_env_set_pgfault_upcall+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800ec6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eca:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ed1:	00 
  800ed2:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  800ed9:	00 
  800eda:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee1:	00 
  800ee2:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800ee9:	e8 d8 f2 ff ff       	call   8001c6 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800eee:	83 c4 2c             	add    $0x2c,%esp
  800ef1:	5b                   	pop    %ebx
  800ef2:	5e                   	pop    %esi
  800ef3:	5f                   	pop    %edi
  800ef4:	5d                   	pop    %ebp
  800ef5:	c3                   	ret    

00800ef6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
  800ef9:	57                   	push   %edi
  800efa:	56                   	push   %esi
  800efb:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800efc:	be 00 00 00 00       	mov    $0x0,%esi
  800f01:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f09:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f0f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f12:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t)srcva, perm, 0);
}
  800f14:	5b                   	pop    %ebx
  800f15:	5e                   	pop    %esi
  800f16:	5f                   	pop    %edi
  800f17:	5d                   	pop    %ebp
  800f18:	c3                   	ret    

00800f19 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f19:	55                   	push   %ebp
  800f1a:	89 e5                	mov    %esp,%ebp
  800f1c:	57                   	push   %edi
  800f1d:	56                   	push   %esi
  800f1e:	53                   	push   %ebx
  800f1f:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800f22:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f27:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2f:	89 cb                	mov    %ecx,%ebx
  800f31:	89 cf                	mov    %ecx,%edi
  800f33:	89 ce                	mov    %ecx,%esi
  800f35:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800f37:	85 c0                	test   %eax,%eax
  800f39:	7e 28                	jle    800f63 <sys_ipc_recv+0x4a>
    panic("syscall %d returned %d (> 0)", num, ret);
  800f3b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f3f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f46:	00 
  800f47:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  800f4e:	00 
  800f4f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f56:	00 
  800f57:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800f5e:	e8 63 f2 ff ff       	call   8001c6 <_panic>

int
sys_ipc_recv(void *dstva)
{
  return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f63:	83 c4 2c             	add    $0x2c,%esp
  800f66:	5b                   	pop    %ebx
  800f67:	5e                   	pop    %esi
  800f68:	5f                   	pop    %edi
  800f69:	5d                   	pop    %ebp
  800f6a:	c3                   	ret    
  800f6b:	66 90                	xchg   %ax,%ax
  800f6d:	66 90                	xchg   %ax,%ax
  800f6f:	90                   	nop

00800f70 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  800f73:	8b 45 08             	mov    0x8(%ebp),%eax
  800f76:	05 00 00 00 30       	add    $0x30000000,%eax
  800f7b:	c1 e8 0c             	shr    $0xc,%eax
}
  800f7e:	5d                   	pop    %ebp
  800f7f:	c3                   	ret    

00800f80 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  800f83:	8b 45 08             	mov    0x8(%ebp),%eax
  800f86:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
  return INDEX2DATA(fd2num(fd));
  800f8b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f90:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f95:	5d                   	pop    %ebp
  800f96:	c3                   	ret    

00800f97 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f97:	55                   	push   %ebp
  800f98:	89 e5                	mov    %esp,%ebp
  800f9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f9d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
  int i;
  struct Fd *fd;

  for (i = 0; i < MAXFD; i++) {
    fd = INDEX2FD(i);
    if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800fa2:	89 c2                	mov    %eax,%edx
  800fa4:	c1 ea 16             	shr    $0x16,%edx
  800fa7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fae:	f6 c2 01             	test   $0x1,%dl
  800fb1:	74 11                	je     800fc4 <fd_alloc+0x2d>
  800fb3:	89 c2                	mov    %eax,%edx
  800fb5:	c1 ea 0c             	shr    $0xc,%edx
  800fb8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fbf:	f6 c2 01             	test   $0x1,%dl
  800fc2:	75 09                	jne    800fcd <fd_alloc+0x36>
      *fd_store = fd;
  800fc4:	89 01                	mov    %eax,(%ecx)
      return 0;
  800fc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcb:	eb 17                	jmp    800fe4 <fd_alloc+0x4d>
  800fcd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
  int i;
  struct Fd *fd;

  for (i = 0; i < MAXFD; i++) {
  800fd2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800fd7:	75 c9                	jne    800fa2 <fd_alloc+0xb>
    if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
      *fd_store = fd;
      return 0;
    }
  }
  *fd_store = 0;
  800fd9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
  return -E_MAX_OPEN;
  800fdf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800fe4:	5d                   	pop    %ebp
  800fe5:	c3                   	ret    

00800fe6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fe6:	55                   	push   %ebp
  800fe7:	89 e5                	mov    %esp,%ebp
  800fe9:	8b 45 08             	mov    0x8(%ebp),%eax
  struct Fd *fd;

  if (fdnum < 0 || fdnum >= MAXFD) {
  800fec:	83 f8 1f             	cmp    $0x1f,%eax
  800fef:	77 36                	ja     801027 <fd_lookup+0x41>
    if (debug)
      cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  fd = INDEX2FD(fdnum);
  800ff1:	c1 e0 0c             	shl    $0xc,%eax
  800ff4:	2d 00 00 00 30       	sub    $0x30000000,%eax
  if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ff9:	89 c2                	mov    %eax,%edx
  800ffb:	c1 ea 16             	shr    $0x16,%edx
  800ffe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801005:	f6 c2 01             	test   $0x1,%dl
  801008:	74 24                	je     80102e <fd_lookup+0x48>
  80100a:	89 c2                	mov    %eax,%edx
  80100c:	c1 ea 0c             	shr    $0xc,%edx
  80100f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801016:	f6 c2 01             	test   $0x1,%dl
  801019:	74 1a                	je     801035 <fd_lookup+0x4f>
    if (debug)
      cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  *fd_store = fd;
  80101b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80101e:	89 02                	mov    %eax,(%edx)
  return 0;
  801020:	b8 00 00 00 00       	mov    $0x0,%eax
  801025:	eb 13                	jmp    80103a <fd_lookup+0x54>
  struct Fd *fd;

  if (fdnum < 0 || fdnum >= MAXFD) {
    if (debug)
      cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  801027:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80102c:	eb 0c                	jmp    80103a <fd_lookup+0x54>
  }
  fd = INDEX2FD(fdnum);
  if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
    if (debug)
      cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  80102e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801033:	eb 05                	jmp    80103a <fd_lookup+0x54>
  801035:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  }
  *fd_store = fd;
  return 0;
}
  80103a:	5d                   	pop    %ebp
  80103b:	c3                   	ret    

0080103c <dev_lookup>:
  0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80103c:	55                   	push   %ebp
  80103d:	89 e5                	mov    %esp,%ebp
  80103f:	83 ec 18             	sub    $0x18,%esp
  801042:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801045:	ba 2c 26 80 00       	mov    $0x80262c,%edx
  int i;

  for (i = 0; devtab[i]; i++)
  80104a:	eb 13                	jmp    80105f <dev_lookup+0x23>
  80104c:	83 c2 04             	add    $0x4,%edx
    if (devtab[i]->dev_id == dev_id) {
  80104f:	39 08                	cmp    %ecx,(%eax)
  801051:	75 0c                	jne    80105f <dev_lookup+0x23>
      *dev = devtab[i];
  801053:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801056:	89 01                	mov    %eax,(%ecx)
      return 0;
  801058:	b8 00 00 00 00       	mov    $0x0,%eax
  80105d:	eb 30                	jmp    80108f <dev_lookup+0x53>
int
dev_lookup(int dev_id, struct Dev **dev)
{
  int i;

  for (i = 0; devtab[i]; i++)
  80105f:	8b 02                	mov    (%edx),%eax
  801061:	85 c0                	test   %eax,%eax
  801063:	75 e7                	jne    80104c <dev_lookup+0x10>
    if (devtab[i]->dev_id == dev_id) {
      *dev = devtab[i];
      return 0;
    }
  cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801065:	a1 20 60 80 00       	mov    0x806020,%eax
  80106a:	8b 40 48             	mov    0x48(%eax),%eax
  80106d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801071:	89 44 24 04          	mov    %eax,0x4(%esp)
  801075:	c7 04 24 ac 25 80 00 	movl   $0x8025ac,(%esp)
  80107c:	e8 3e f2 ff ff       	call   8002bf <cprintf>
  *dev = 0;
  801081:	8b 45 0c             	mov    0xc(%ebp),%eax
  801084:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  return -E_INVAL;
  80108a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80108f:	c9                   	leave  
  801090:	c3                   	ret    

00801091 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	56                   	push   %esi
  801095:	53                   	push   %ebx
  801096:	83 ec 20             	sub    $0x20,%esp
  801099:	8b 75 08             	mov    0x8(%ebp),%esi
  80109c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct Fd *fd2;
  struct Dev *dev;
  int r;

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80109f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010a2:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  8010a6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8010ac:	c1 e8 0c             	shr    $0xc,%eax
{
  struct Fd *fd2;
  struct Dev *dev;
  int r;

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010af:	89 04 24             	mov    %eax,(%esp)
  8010b2:	e8 2f ff ff ff       	call   800fe6 <fd_lookup>
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	78 05                	js     8010c0 <fd_close+0x2f>
      || fd != fd2)
  8010bb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8010be:	74 0c                	je     8010cc <fd_close+0x3b>
    return must_exist ? r : 0;
  8010c0:	84 db                	test   %bl,%bl
  8010c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8010c7:	0f 44 c2             	cmove  %edx,%eax
  8010ca:	eb 3f                	jmp    80110b <fd_close+0x7a>
  if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d3:	8b 06                	mov    (%esi),%eax
  8010d5:	89 04 24             	mov    %eax,(%esp)
  8010d8:	e8 5f ff ff ff       	call   80103c <dev_lookup>
  8010dd:	89 c3                	mov    %eax,%ebx
  8010df:	85 c0                	test   %eax,%eax
  8010e1:	78 16                	js     8010f9 <fd_close+0x68>
    if (dev->dev_close)
  8010e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010e6:	8b 40 10             	mov    0x10(%eax),%eax
      r = (*dev->dev_close)(fd);
    else
      r = 0;
  8010e9:	bb 00 00 00 00       	mov    $0x0,%ebx

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
      || fd != fd2)
    return must_exist ? r : 0;
  if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
    if (dev->dev_close)
  8010ee:	85 c0                	test   %eax,%eax
  8010f0:	74 07                	je     8010f9 <fd_close+0x68>
      r = (*dev->dev_close)(fd);
  8010f2:	89 34 24             	mov    %esi,(%esp)
  8010f5:	ff d0                	call   *%eax
  8010f7:	89 c3                	mov    %eax,%ebx
    else
      r = 0;
  }
  // Make sure fd is unmapped.  Might be a no-op if
  // (*dev->dev_close)(fd) already unmapped it.
  (void)sys_page_unmap(0, fd);
  8010f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801104:	e8 a1 fc ff ff       	call   800daa <sys_page_unmap>
  return r;
  801109:	89 d8                	mov    %ebx,%eax
}
  80110b:	83 c4 20             	add    $0x20,%esp
  80110e:	5b                   	pop    %ebx
  80110f:	5e                   	pop    %esi
  801110:	5d                   	pop    %ebp
  801111:	c3                   	ret    

00801112 <close>:
  return -E_INVAL;
}

int
close(int fdnum)
{
  801112:	55                   	push   %ebp
  801113:	89 e5                	mov    %esp,%ebp
  801115:	83 ec 28             	sub    $0x28,%esp
  struct Fd *fd;
  int r;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  801118:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80111b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80111f:	8b 45 08             	mov    0x8(%ebp),%eax
  801122:	89 04 24             	mov    %eax,(%esp)
  801125:	e8 bc fe ff ff       	call   800fe6 <fd_lookup>
  80112a:	89 c2                	mov    %eax,%edx
  80112c:	85 d2                	test   %edx,%edx
  80112e:	78 13                	js     801143 <close+0x31>
    return r;
  else
    return fd_close(fd, 1);
  801130:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801137:	00 
  801138:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80113b:	89 04 24             	mov    %eax,(%esp)
  80113e:	e8 4e ff ff ff       	call   801091 <fd_close>
}
  801143:	c9                   	leave  
  801144:	c3                   	ret    

00801145 <close_all>:

void
close_all(void)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	53                   	push   %ebx
  801149:	83 ec 14             	sub    $0x14,%esp
  int i;

  for (i = 0; i < MAXFD; i++)
  80114c:	bb 00 00 00 00       	mov    $0x0,%ebx
    close(i);
  801151:	89 1c 24             	mov    %ebx,(%esp)
  801154:	e8 b9 ff ff ff       	call   801112 <close>
void
close_all(void)
{
  int i;

  for (i = 0; i < MAXFD; i++)
  801159:	83 c3 01             	add    $0x1,%ebx
  80115c:	83 fb 20             	cmp    $0x20,%ebx
  80115f:	75 f0                	jne    801151 <close_all+0xc>
    close(i);
}
  801161:	83 c4 14             	add    $0x14,%esp
  801164:	5b                   	pop    %ebx
  801165:	5d                   	pop    %ebp
  801166:	c3                   	ret    

00801167 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
  80116a:	57                   	push   %edi
  80116b:	56                   	push   %esi
  80116c:	53                   	push   %ebx
  80116d:	83 ec 3c             	sub    $0x3c,%esp
  int r;
  char *ova, *nva;
  pte_t pte;
  struct Fd *oldfd, *newfd;

  if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801170:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801173:	89 44 24 04          	mov    %eax,0x4(%esp)
  801177:	8b 45 08             	mov    0x8(%ebp),%eax
  80117a:	89 04 24             	mov    %eax,(%esp)
  80117d:	e8 64 fe ff ff       	call   800fe6 <fd_lookup>
  801182:	89 c2                	mov    %eax,%edx
  801184:	85 d2                	test   %edx,%edx
  801186:	0f 88 e1 00 00 00    	js     80126d <dup+0x106>
    return r;
  close(newfdnum);
  80118c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80118f:	89 04 24             	mov    %eax,(%esp)
  801192:	e8 7b ff ff ff       	call   801112 <close>

  newfd = INDEX2FD(newfdnum);
  801197:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80119a:	c1 e3 0c             	shl    $0xc,%ebx
  80119d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
  ova = fd2data(oldfd);
  8011a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011a6:	89 04 24             	mov    %eax,(%esp)
  8011a9:	e8 d2 fd ff ff       	call   800f80 <fd2data>
  8011ae:	89 c6                	mov    %eax,%esi
  nva = fd2data(newfd);
  8011b0:	89 1c 24             	mov    %ebx,(%esp)
  8011b3:	e8 c8 fd ff ff       	call   800f80 <fd2data>
  8011b8:	89 c7                	mov    %eax,%edi

  if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8011ba:	89 f0                	mov    %esi,%eax
  8011bc:	c1 e8 16             	shr    $0x16,%eax
  8011bf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011c6:	a8 01                	test   $0x1,%al
  8011c8:	74 43                	je     80120d <dup+0xa6>
  8011ca:	89 f0                	mov    %esi,%eax
  8011cc:	c1 e8 0c             	shr    $0xc,%eax
  8011cf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011d6:	f6 c2 01             	test   $0x1,%dl
  8011d9:	74 32                	je     80120d <dup+0xa6>
    if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011db:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011e2:	25 07 0e 00 00       	and    $0xe07,%eax
  8011e7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011f6:	00 
  8011f7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801202:	e8 50 fb ff ff       	call   800d57 <sys_page_map>
  801207:	89 c6                	mov    %eax,%esi
  801209:	85 c0                	test   %eax,%eax
  80120b:	78 3e                	js     80124b <dup+0xe4>
      goto err;
  if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80120d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801210:	89 c2                	mov    %eax,%edx
  801212:	c1 ea 0c             	shr    $0xc,%edx
  801215:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80121c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801222:	89 54 24 10          	mov    %edx,0x10(%esp)
  801226:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80122a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801231:	00 
  801232:	89 44 24 04          	mov    %eax,0x4(%esp)
  801236:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80123d:	e8 15 fb ff ff       	call   800d57 <sys_page_map>
  801242:	89 c6                	mov    %eax,%esi
    goto err;

  return newfdnum;
  801244:	8b 45 0c             	mov    0xc(%ebp),%eax
  nva = fd2data(newfd);

  if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
    if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
      goto err;
  if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801247:	85 f6                	test   %esi,%esi
  801249:	79 22                	jns    80126d <dup+0x106>
    goto err;

  return newfdnum;

err:
  sys_page_unmap(0, newfd);
  80124b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80124f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801256:	e8 4f fb ff ff       	call   800daa <sys_page_unmap>
  sys_page_unmap(0, nva);
  80125b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80125f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801266:	e8 3f fb ff ff       	call   800daa <sys_page_unmap>
  return r;
  80126b:	89 f0                	mov    %esi,%eax
}
  80126d:	83 c4 3c             	add    $0x3c,%esp
  801270:	5b                   	pop    %ebx
  801271:	5e                   	pop    %esi
  801272:	5f                   	pop    %edi
  801273:	5d                   	pop    %ebp
  801274:	c3                   	ret    

00801275 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801275:	55                   	push   %ebp
  801276:	89 e5                	mov    %esp,%ebp
  801278:	53                   	push   %ebx
  801279:	83 ec 24             	sub    $0x24,%esp
  80127c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  80127f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801282:	89 44 24 04          	mov    %eax,0x4(%esp)
  801286:	89 1c 24             	mov    %ebx,(%esp)
  801289:	e8 58 fd ff ff       	call   800fe6 <fd_lookup>
  80128e:	89 c2                	mov    %eax,%edx
  801290:	85 d2                	test   %edx,%edx
  801292:	78 6d                	js     801301 <read+0x8c>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801294:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801297:	89 44 24 04          	mov    %eax,0x4(%esp)
  80129b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129e:	8b 00                	mov    (%eax),%eax
  8012a0:	89 04 24             	mov    %eax,(%esp)
  8012a3:	e8 94 fd ff ff       	call   80103c <dev_lookup>
  8012a8:	85 c0                	test   %eax,%eax
  8012aa:	78 55                	js     801301 <read+0x8c>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8012ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012af:	8b 50 08             	mov    0x8(%eax),%edx
  8012b2:	83 e2 03             	and    $0x3,%edx
  8012b5:	83 fa 01             	cmp    $0x1,%edx
  8012b8:	75 23                	jne    8012dd <read+0x68>
    cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8012ba:	a1 20 60 80 00       	mov    0x806020,%eax
  8012bf:	8b 40 48             	mov    0x48(%eax),%eax
  8012c2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ca:	c7 04 24 f0 25 80 00 	movl   $0x8025f0,(%esp)
  8012d1:	e8 e9 ef ff ff       	call   8002bf <cprintf>
    return -E_INVAL;
  8012d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012db:	eb 24                	jmp    801301 <read+0x8c>
  }
  if (!dev->dev_read)
  8012dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012e0:	8b 52 08             	mov    0x8(%edx),%edx
  8012e3:	85 d2                	test   %edx,%edx
  8012e5:	74 15                	je     8012fc <read+0x87>
    return -E_NOT_SUPP;
  return (*dev->dev_read)(fd, buf, n);
  8012e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012ea:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012f5:	89 04 24             	mov    %eax,(%esp)
  8012f8:	ff d2                	call   *%edx
  8012fa:	eb 05                	jmp    801301 <read+0x8c>
  if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
    cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  if (!dev->dev_read)
    return -E_NOT_SUPP;
  8012fc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_read)(fd, buf, n);
}
  801301:	83 c4 24             	add    $0x24,%esp
  801304:	5b                   	pop    %ebx
  801305:	5d                   	pop    %ebp
  801306:	c3                   	ret    

00801307 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801307:	55                   	push   %ebp
  801308:	89 e5                	mov    %esp,%ebp
  80130a:	57                   	push   %edi
  80130b:	56                   	push   %esi
  80130c:	53                   	push   %ebx
  80130d:	83 ec 1c             	sub    $0x1c,%esp
  801310:	8b 7d 08             	mov    0x8(%ebp),%edi
  801313:	8b 75 10             	mov    0x10(%ebp),%esi
  int m, tot;

  for (tot = 0; tot < n; tot += m) {
  801316:	bb 00 00 00 00       	mov    $0x0,%ebx
  80131b:	eb 23                	jmp    801340 <readn+0x39>
    m = read(fdnum, (char*)buf + tot, n - tot);
  80131d:	89 f0                	mov    %esi,%eax
  80131f:	29 d8                	sub    %ebx,%eax
  801321:	89 44 24 08          	mov    %eax,0x8(%esp)
  801325:	89 d8                	mov    %ebx,%eax
  801327:	03 45 0c             	add    0xc(%ebp),%eax
  80132a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80132e:	89 3c 24             	mov    %edi,(%esp)
  801331:	e8 3f ff ff ff       	call   801275 <read>
    if (m < 0)
  801336:	85 c0                	test   %eax,%eax
  801338:	78 10                	js     80134a <readn+0x43>
      return m;
    if (m == 0)
  80133a:	85 c0                	test   %eax,%eax
  80133c:	74 0a                	je     801348 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
  int m, tot;

  for (tot = 0; tot < n; tot += m) {
  80133e:	01 c3                	add    %eax,%ebx
  801340:	39 f3                	cmp    %esi,%ebx
  801342:	72 d9                	jb     80131d <readn+0x16>
  801344:	89 d8                	mov    %ebx,%eax
  801346:	eb 02                	jmp    80134a <readn+0x43>
  801348:	89 d8                	mov    %ebx,%eax
      return m;
    if (m == 0)
      break;
  }
  return tot;
}
  80134a:	83 c4 1c             	add    $0x1c,%esp
  80134d:	5b                   	pop    %ebx
  80134e:	5e                   	pop    %esi
  80134f:	5f                   	pop    %edi
  801350:	5d                   	pop    %ebp
  801351:	c3                   	ret    

00801352 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801352:	55                   	push   %ebp
  801353:	89 e5                	mov    %esp,%ebp
  801355:	53                   	push   %ebx
  801356:	83 ec 24             	sub    $0x24,%esp
  801359:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  80135c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80135f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801363:	89 1c 24             	mov    %ebx,(%esp)
  801366:	e8 7b fc ff ff       	call   800fe6 <fd_lookup>
  80136b:	89 c2                	mov    %eax,%edx
  80136d:	85 d2                	test   %edx,%edx
  80136f:	78 68                	js     8013d9 <write+0x87>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801371:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801374:	89 44 24 04          	mov    %eax,0x4(%esp)
  801378:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137b:	8b 00                	mov    (%eax),%eax
  80137d:	89 04 24             	mov    %eax,(%esp)
  801380:	e8 b7 fc ff ff       	call   80103c <dev_lookup>
  801385:	85 c0                	test   %eax,%eax
  801387:	78 50                	js     8013d9 <write+0x87>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801389:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801390:	75 23                	jne    8013b5 <write+0x63>
    cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801392:	a1 20 60 80 00       	mov    0x806020,%eax
  801397:	8b 40 48             	mov    0x48(%eax),%eax
  80139a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80139e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a2:	c7 04 24 0c 26 80 00 	movl   $0x80260c,(%esp)
  8013a9:	e8 11 ef ff ff       	call   8002bf <cprintf>
    return -E_INVAL;
  8013ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013b3:	eb 24                	jmp    8013d9 <write+0x87>
  }
  if (debug)
    cprintf("write %d %p %d via dev %s\n",
            fdnum, buf, n, dev->dev_name);
  if (!dev->dev_write)
  8013b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013b8:	8b 52 0c             	mov    0xc(%edx),%edx
  8013bb:	85 d2                	test   %edx,%edx
  8013bd:	74 15                	je     8013d4 <write+0x82>
    return -E_NOT_SUPP;
  return (*dev->dev_write)(fd, buf, n);
  8013bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8013c2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013c9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013cd:	89 04 24             	mov    %eax,(%esp)
  8013d0:	ff d2                	call   *%edx
  8013d2:	eb 05                	jmp    8013d9 <write+0x87>
  }
  if (debug)
    cprintf("write %d %p %d via dev %s\n",
            fdnum, buf, n, dev->dev_name);
  if (!dev->dev_write)
    return -E_NOT_SUPP;
  8013d4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_write)(fd, buf, n);
}
  8013d9:	83 c4 24             	add    $0x24,%esp
  8013dc:	5b                   	pop    %ebx
  8013dd:	5d                   	pop    %ebp
  8013de:	c3                   	ret    

008013df <seek>:

int
seek(int fdnum, off_t offset)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
  8013e2:	83 ec 18             	sub    $0x18,%esp
  int r;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013e5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ef:	89 04 24             	mov    %eax,(%esp)
  8013f2:	e8 ef fb ff ff       	call   800fe6 <fd_lookup>
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	78 0e                	js     801409 <seek+0x2a>
    return r;
  fd->fd_offset = offset;
  8013fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801401:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
  801404:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801409:	c9                   	leave  
  80140a:	c3                   	ret    

0080140b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80140b:	55                   	push   %ebp
  80140c:	89 e5                	mov    %esp,%ebp
  80140e:	53                   	push   %ebx
  80140f:	83 ec 24             	sub    $0x24,%esp
  801412:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  801415:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801418:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141c:	89 1c 24             	mov    %ebx,(%esp)
  80141f:	e8 c2 fb ff ff       	call   800fe6 <fd_lookup>
  801424:	89 c2                	mov    %eax,%edx
  801426:	85 d2                	test   %edx,%edx
  801428:	78 61                	js     80148b <ftruncate+0x80>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801431:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801434:	8b 00                	mov    (%eax),%eax
  801436:	89 04 24             	mov    %eax,(%esp)
  801439:	e8 fe fb ff ff       	call   80103c <dev_lookup>
  80143e:	85 c0                	test   %eax,%eax
  801440:	78 49                	js     80148b <ftruncate+0x80>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801442:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801445:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801449:	75 23                	jne    80146e <ftruncate+0x63>
    cprintf("[%08x] ftruncate %d -- bad mode\n",
            thisenv->env_id, fdnum);
  80144b:	a1 20 60 80 00       	mov    0x806020,%eax

  if ((r = fd_lookup(fdnum, &fd)) < 0
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
    cprintf("[%08x] ftruncate %d -- bad mode\n",
  801450:	8b 40 48             	mov    0x48(%eax),%eax
  801453:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801457:	89 44 24 04          	mov    %eax,0x4(%esp)
  80145b:	c7 04 24 cc 25 80 00 	movl   $0x8025cc,(%esp)
  801462:	e8 58 ee ff ff       	call   8002bf <cprintf>
            thisenv->env_id, fdnum);
    return -E_INVAL;
  801467:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80146c:	eb 1d                	jmp    80148b <ftruncate+0x80>
  }
  if (!dev->dev_trunc)
  80146e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801471:	8b 52 18             	mov    0x18(%edx),%edx
  801474:	85 d2                	test   %edx,%edx
  801476:	74 0e                	je     801486 <ftruncate+0x7b>
    return -E_NOT_SUPP;
  return (*dev->dev_trunc)(fd, newsize);
  801478:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80147b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80147f:	89 04 24             	mov    %eax,(%esp)
  801482:	ff d2                	call   *%edx
  801484:	eb 05                	jmp    80148b <ftruncate+0x80>
    cprintf("[%08x] ftruncate %d -- bad mode\n",
            thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  if (!dev->dev_trunc)
    return -E_NOT_SUPP;
  801486:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_trunc)(fd, newsize);
}
  80148b:	83 c4 24             	add    $0x24,%esp
  80148e:	5b                   	pop    %ebx
  80148f:	5d                   	pop    %ebp
  801490:	c3                   	ret    

00801491 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801491:	55                   	push   %ebp
  801492:	89 e5                	mov    %esp,%ebp
  801494:	53                   	push   %ebx
  801495:	83 ec 24             	sub    $0x24,%esp
  801498:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  80149b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80149e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a5:	89 04 24             	mov    %eax,(%esp)
  8014a8:	e8 39 fb ff ff       	call   800fe6 <fd_lookup>
  8014ad:	89 c2                	mov    %eax,%edx
  8014af:	85 d2                	test   %edx,%edx
  8014b1:	78 52                	js     801505 <fstat+0x74>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014bd:	8b 00                	mov    (%eax),%eax
  8014bf:	89 04 24             	mov    %eax,(%esp)
  8014c2:	e8 75 fb ff ff       	call   80103c <dev_lookup>
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	78 3a                	js     801505 <fstat+0x74>
    return r;
  if (!dev->dev_stat)
  8014cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ce:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014d2:	74 2c                	je     801500 <fstat+0x6f>
    return -E_NOT_SUPP;
  stat->st_name[0] = 0;
  8014d4:	c6 03 00             	movb   $0x0,(%ebx)
  stat->st_size = 0;
  8014d7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014de:	00 00 00 
  stat->st_isdir = 0;
  8014e1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014e8:	00 00 00 
  stat->st_dev = dev;
  8014eb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
  return (*dev->dev_stat)(fd, stat);
  8014f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014f5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014f8:	89 14 24             	mov    %edx,(%esp)
  8014fb:	ff 50 14             	call   *0x14(%eax)
  8014fe:	eb 05                	jmp    801505 <fstat+0x74>

  if ((r = fd_lookup(fdnum, &fd)) < 0
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
    return r;
  if (!dev->dev_stat)
    return -E_NOT_SUPP;
  801500:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  stat->st_name[0] = 0;
  stat->st_size = 0;
  stat->st_isdir = 0;
  stat->st_dev = dev;
  return (*dev->dev_stat)(fd, stat);
}
  801505:	83 c4 24             	add    $0x24,%esp
  801508:	5b                   	pop    %ebx
  801509:	5d                   	pop    %ebp
  80150a:	c3                   	ret    

0080150b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80150b:	55                   	push   %ebp
  80150c:	89 e5                	mov    %esp,%ebp
  80150e:	56                   	push   %esi
  80150f:	53                   	push   %ebx
  801510:	83 ec 10             	sub    $0x10,%esp
  int fd, r;

  if ((fd = open(path, O_RDONLY)) < 0)
  801513:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80151a:	00 
  80151b:	8b 45 08             	mov    0x8(%ebp),%eax
  80151e:	89 04 24             	mov    %eax,(%esp)
  801521:	e8 d2 01 00 00       	call   8016f8 <open>
  801526:	89 c3                	mov    %eax,%ebx
  801528:	85 db                	test   %ebx,%ebx
  80152a:	78 1b                	js     801547 <stat+0x3c>
    return fd;
  r = fstat(fd, stat);
  80152c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80152f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801533:	89 1c 24             	mov    %ebx,(%esp)
  801536:	e8 56 ff ff ff       	call   801491 <fstat>
  80153b:	89 c6                	mov    %eax,%esi
  close(fd);
  80153d:	89 1c 24             	mov    %ebx,(%esp)
  801540:	e8 cd fb ff ff       	call   801112 <close>
  return r;
  801545:	89 f0                	mov    %esi,%eax
}
  801547:	83 c4 10             	add    $0x10,%esp
  80154a:	5b                   	pop    %ebx
  80154b:	5e                   	pop    %esi
  80154c:	5d                   	pop    %ebp
  80154d:	c3                   	ret    

0080154e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80154e:	55                   	push   %ebp
  80154f:	89 e5                	mov    %esp,%ebp
  801551:	56                   	push   %esi
  801552:	53                   	push   %ebx
  801553:	83 ec 10             	sub    $0x10,%esp
  801556:	89 c6                	mov    %eax,%esi
  801558:	89 d3                	mov    %edx,%ebx
  static envid_t fsenv;

  if (fsenv == 0)
  80155a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801561:	75 11                	jne    801574 <fsipc+0x26>
    fsenv = ipc_find_env(ENV_TYPE_FS);
  801563:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80156a:	e8 78 09 00 00       	call   801ee7 <ipc_find_env>
  80156f:	a3 00 40 80 00       	mov    %eax,0x804000
  static_assert(sizeof(fsipcbuf) == PGSIZE);

  if (debug)
    cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t*)&fsipcbuf);

  ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801574:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80157b:	00 
  80157c:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801583:	00 
  801584:	89 74 24 04          	mov    %esi,0x4(%esp)
  801588:	a1 00 40 80 00       	mov    0x804000,%eax
  80158d:	89 04 24             	mov    %eax,(%esp)
  801590:	e8 e7 08 00 00       	call   801e7c <ipc_send>
  return ipc_recv(NULL, dstva, NULL);
  801595:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80159c:	00 
  80159d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015a8:	e8 49 08 00 00       	call   801df6 <ipc_recv>
}
  8015ad:	83 c4 10             	add    $0x10,%esp
  8015b0:	5b                   	pop    %ebx
  8015b1:	5e                   	pop    %esi
  8015b2:	5d                   	pop    %ebp
  8015b3:	c3                   	ret    

008015b4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8015b4:	55                   	push   %ebp
  8015b5:	89 e5                	mov    %esp,%ebp
  8015b7:	83 ec 08             	sub    $0x8,%esp
  fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8015ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8015bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8015c0:	a3 00 70 80 00       	mov    %eax,0x807000
  fsipcbuf.set_size.req_size = newsize;
  8015c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015c8:	a3 04 70 80 00       	mov    %eax,0x807004
  return fsipc(FSREQ_SET_SIZE, NULL);
  8015cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d2:	b8 02 00 00 00       	mov    $0x2,%eax
  8015d7:	e8 72 ff ff ff       	call   80154e <fsipc>
}
  8015dc:	c9                   	leave  
  8015dd:	c3                   	ret    

008015de <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8015de:	55                   	push   %ebp
  8015df:	89 e5                	mov    %esp,%ebp
  8015e1:	83 ec 08             	sub    $0x8,%esp
  fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8015ea:	a3 00 70 80 00       	mov    %eax,0x807000
  return fsipc(FSREQ_FLUSH, NULL);
  8015ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f4:	b8 06 00 00 00       	mov    $0x6,%eax
  8015f9:	e8 50 ff ff ff       	call   80154e <fsipc>
}
  8015fe:	c9                   	leave  
  8015ff:	c3                   	ret    

00801600 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	53                   	push   %ebx
  801604:	83 ec 14             	sub    $0x14,%esp
  801607:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int r;

  fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80160a:	8b 45 08             	mov    0x8(%ebp),%eax
  80160d:	8b 40 0c             	mov    0xc(%eax),%eax
  801610:	a3 00 70 80 00       	mov    %eax,0x807000
  if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801615:	ba 00 00 00 00       	mov    $0x0,%edx
  80161a:	b8 05 00 00 00       	mov    $0x5,%eax
  80161f:	e8 2a ff ff ff       	call   80154e <fsipc>
  801624:	89 c2                	mov    %eax,%edx
  801626:	85 d2                	test   %edx,%edx
  801628:	78 2b                	js     801655 <devfile_stat+0x55>
    return r;
  strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80162a:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  801631:	00 
  801632:	89 1c 24             	mov    %ebx,(%esp)
  801635:	e8 ad f2 ff ff       	call   8008e7 <strcpy>
  st->st_size = fsipcbuf.statRet.ret_size;
  80163a:	a1 80 70 80 00       	mov    0x807080,%eax
  80163f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801645:	a1 84 70 80 00       	mov    0x807084,%eax
  80164a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  return 0;
  801650:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801655:	83 c4 14             	add    $0x14,%esp
  801658:	5b                   	pop    %ebx
  801659:	5d                   	pop    %ebp
  80165a:	c3                   	ret    

0080165b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80165b:	55                   	push   %ebp
  80165c:	89 e5                	mov    %esp,%ebp
  80165e:	83 ec 18             	sub    $0x18,%esp
  801661:	8b 45 10             	mov    0x10(%ebp),%eax
  // remember that write is always allowed to write *fewer*
  // bytes than requested.
  // LAB 5: Your code here
    int r;

    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801664:	8b 55 08             	mov    0x8(%ebp),%edx
  801667:	8b 52 0c             	mov    0xc(%edx),%edx
  80166a:	89 15 00 70 80 00    	mov    %edx,0x807000
    fsipcbuf.write.req_n = n;
  801670:	a3 04 70 80 00       	mov    %eax,0x807004

    size_t max_written = sizeof(fsipcbuf.write.req_buf);
    memmove(fsipcbuf.write.req_buf, buf, MIN(max_written, n));
  801675:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80167a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80167f:	0f 47 c2             	cmova  %edx,%eax
  801682:	89 44 24 08          	mov    %eax,0x8(%esp)
  801686:	8b 45 0c             	mov    0xc(%ebp),%eax
  801689:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168d:	c7 04 24 08 70 80 00 	movl   $0x807008,(%esp)
  801694:	e8 eb f3 ff ff       	call   800a84 <memmove>

    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801699:	ba 00 00 00 00       	mov    $0x0,%edx
  80169e:	b8 04 00 00 00       	mov    $0x4,%eax
  8016a3:	e8 a6 fe ff ff       	call   80154e <fsipc>
        return r;

    return r;
}
  8016a8:	c9                   	leave  
  8016a9:	c3                   	ret    

008016aa <devfile_read>:
// Returns:
//  The number of bytes successfully read.
//  < 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016aa:	55                   	push   %ebp
  8016ab:	89 e5                	mov    %esp,%ebp
  8016ad:	53                   	push   %ebx
  8016ae:	83 ec 14             	sub    $0x14,%esp
  // filling fsipcbuf.read with the request arguments.  The
  // bytes read will be written back to fsipcbuf by the file
  // system server.
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b7:	a3 00 70 80 00       	mov    %eax,0x807000
  fsipcbuf.read.req_n = n;
  8016bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8016bf:	a3 04 70 80 00       	mov    %eax,0x807004
  if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c9:	b8 03 00 00 00       	mov    $0x3,%eax
  8016ce:	e8 7b fe ff ff       	call   80154e <fsipc>
  8016d3:	89 c3                	mov    %eax,%ebx
  8016d5:	85 c0                	test   %eax,%eax
  8016d7:	78 17                	js     8016f0 <devfile_read+0x46>
    return r;

  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8016d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016dd:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8016e4:	00 
  8016e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e8:	89 04 24             	mov    %eax,(%esp)
  8016eb:	e8 94 f3 ff ff       	call   800a84 <memmove>
  return r;
}
  8016f0:	89 d8                	mov    %ebx,%eax
  8016f2:	83 c4 14             	add    $0x14,%esp
  8016f5:	5b                   	pop    %ebx
  8016f6:	5d                   	pop    %ebp
  8016f7:	c3                   	ret    

008016f8 <open>:
//  The file descriptor index on success
//  -E_BAD_PATH if the path is too long (>= MAXPATHLEN)
//  < 0 for other errors.
int
open(const char *path, int mode)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	53                   	push   %ebx
  8016fc:	83 ec 24             	sub    $0x24,%esp
  8016ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
  // file descriptor.

  int r;
  struct Fd *fd;

  if (strlen(path) >= MAXPATHLEN)
  801702:	89 1c 24             	mov    %ebx,(%esp)
  801705:	e8 a6 f1 ff ff       	call   8008b0 <strlen>
  80170a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80170f:	7f 60                	jg     801771 <open+0x79>
    return -E_BAD_PATH;

  if ((r = fd_alloc(&fd)) < 0)
  801711:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801714:	89 04 24             	mov    %eax,(%esp)
  801717:	e8 7b f8 ff ff       	call   800f97 <fd_alloc>
  80171c:	89 c2                	mov    %eax,%edx
  80171e:	85 d2                	test   %edx,%edx
  801720:	78 54                	js     801776 <open+0x7e>
    return r;

  strcpy(fsipcbuf.open.req_path, path);
  801722:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801726:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  80172d:	e8 b5 f1 ff ff       	call   8008e7 <strcpy>
  fsipcbuf.open.req_omode = mode;
  801732:	8b 45 0c             	mov    0xc(%ebp),%eax
  801735:	a3 00 74 80 00       	mov    %eax,0x807400

  if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80173a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80173d:	b8 01 00 00 00       	mov    $0x1,%eax
  801742:	e8 07 fe ff ff       	call   80154e <fsipc>
  801747:	89 c3                	mov    %eax,%ebx
  801749:	85 c0                	test   %eax,%eax
  80174b:	79 17                	jns    801764 <open+0x6c>
    fd_close(fd, 0);
  80174d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801754:	00 
  801755:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801758:	89 04 24             	mov    %eax,(%esp)
  80175b:	e8 31 f9 ff ff       	call   801091 <fd_close>
    return r;
  801760:	89 d8                	mov    %ebx,%eax
  801762:	eb 12                	jmp    801776 <open+0x7e>
  }

  return fd2num(fd);
  801764:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801767:	89 04 24             	mov    %eax,(%esp)
  80176a:	e8 01 f8 ff ff       	call   800f70 <fd2num>
  80176f:	eb 05                	jmp    801776 <open+0x7e>

  int r;
  struct Fd *fd;

  if (strlen(path) >= MAXPATHLEN)
    return -E_BAD_PATH;
  801771:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
    fd_close(fd, 0);
    return r;
  }

  return fd2num(fd);
}
  801776:	83 c4 24             	add    $0x24,%esp
  801779:	5b                   	pop    %ebx
  80177a:	5d                   	pop    %ebp
  80177b:	c3                   	ret    

0080177c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80177c:	55                   	push   %ebp
  80177d:	89 e5                	mov    %esp,%ebp
  80177f:	83 ec 08             	sub    $0x8,%esp
  // Ask the file server to update the disk
  // by writing any dirty blocks in the buffer cache.

  return fsipc(FSREQ_SYNC, NULL);
  801782:	ba 00 00 00 00       	mov    $0x0,%edx
  801787:	b8 08 00 00 00       	mov    $0x8,%eax
  80178c:	e8 bd fd ff ff       	call   80154e <fsipc>
}
  801791:	c9                   	leave  
  801792:	c3                   	ret    

00801793 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	53                   	push   %ebx
  801797:	83 ec 14             	sub    $0x14,%esp
  80179a:	89 c3                	mov    %eax,%ebx
  if (b->error > 0) {
  80179c:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8017a0:	7e 31                	jle    8017d3 <writebuf+0x40>
    ssize_t result = write(b->fd, b->buf, b->idx);
  8017a2:	8b 40 04             	mov    0x4(%eax),%eax
  8017a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017a9:	8d 43 10             	lea    0x10(%ebx),%eax
  8017ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b0:	8b 03                	mov    (%ebx),%eax
  8017b2:	89 04 24             	mov    %eax,(%esp)
  8017b5:	e8 98 fb ff ff       	call   801352 <write>
    if (result > 0)
  8017ba:	85 c0                	test   %eax,%eax
  8017bc:	7e 03                	jle    8017c1 <writebuf+0x2e>
      b->result += result;
  8017be:	01 43 08             	add    %eax,0x8(%ebx)
    if (result != b->idx)             // error, or wrote less than supplied
  8017c1:	39 43 04             	cmp    %eax,0x4(%ebx)
  8017c4:	74 0d                	je     8017d3 <writebuf+0x40>
      b->error = (result < 0 ? result : 0);
  8017c6:	85 c0                	test   %eax,%eax
  8017c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017cd:	0f 4f c2             	cmovg  %edx,%eax
  8017d0:	89 43 0c             	mov    %eax,0xc(%ebx)
  }
}
  8017d3:	83 c4 14             	add    $0x14,%esp
  8017d6:	5b                   	pop    %ebx
  8017d7:	5d                   	pop    %ebp
  8017d8:	c3                   	ret    

008017d9 <putch>:

static void
putch(int ch, void *thunk)
{
  8017d9:	55                   	push   %ebp
  8017da:	89 e5                	mov    %esp,%ebp
  8017dc:	53                   	push   %ebx
  8017dd:	83 ec 04             	sub    $0x4,%esp
  8017e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct printbuf *b = (struct printbuf *)thunk;

  b->buf[b->idx++] = ch;
  8017e3:	8b 53 04             	mov    0x4(%ebx),%edx
  8017e6:	8d 42 01             	lea    0x1(%edx),%eax
  8017e9:	89 43 04             	mov    %eax,0x4(%ebx)
  8017ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017ef:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
  if (b->idx == 256) {
  8017f3:	3d 00 01 00 00       	cmp    $0x100,%eax
  8017f8:	75 0e                	jne    801808 <putch+0x2f>
    writebuf(b);
  8017fa:	89 d8                	mov    %ebx,%eax
  8017fc:	e8 92 ff ff ff       	call   801793 <writebuf>
    b->idx = 0;
  801801:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  }
}
  801808:	83 c4 04             	add    $0x4,%esp
  80180b:	5b                   	pop    %ebx
  80180c:	5d                   	pop    %ebp
  80180d:	c3                   	ret    

0080180e <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80180e:	55                   	push   %ebp
  80180f:	89 e5                	mov    %esp,%ebp
  801811:	81 ec 28 01 00 00    	sub    $0x128,%esp
  struct printbuf b;

  b.fd = fd;
  801817:	8b 45 08             	mov    0x8(%ebp),%eax
  80181a:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
  b.idx = 0;
  801820:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801827:	00 00 00 
  b.result = 0;
  80182a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801831:	00 00 00 
  b.error = 1;
  801834:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80183b:	00 00 00 
  vprintfmt(putch, &b, fmt, ap);
  80183e:	8b 45 10             	mov    0x10(%ebp),%eax
  801841:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801845:	8b 45 0c             	mov    0xc(%ebp),%eax
  801848:	89 44 24 08          	mov    %eax,0x8(%esp)
  80184c:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801852:	89 44 24 04          	mov    %eax,0x4(%esp)
  801856:	c7 04 24 d9 17 80 00 	movl   $0x8017d9,(%esp)
  80185d:	e8 ec eb ff ff       	call   80044e <vprintfmt>
  if (b.idx > 0)
  801862:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801869:	7e 0b                	jle    801876 <vfprintf+0x68>
    writebuf(&b);
  80186b:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801871:	e8 1d ff ff ff       	call   801793 <writebuf>

  return b.result ? b.result : b.error;
  801876:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80187c:	85 c0                	test   %eax,%eax
  80187e:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801885:	c9                   	leave  
  801886:	c3                   	ret    

00801887 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801887:	55                   	push   %ebp
  801888:	89 e5                	mov    %esp,%ebp
  80188a:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  80188d:	8d 45 10             	lea    0x10(%ebp),%eax
  cnt = vfprintf(fd, fmt, ap);
  801890:	89 44 24 08          	mov    %eax,0x8(%esp)
  801894:	8b 45 0c             	mov    0xc(%ebp),%eax
  801897:	89 44 24 04          	mov    %eax,0x4(%esp)
  80189b:	8b 45 08             	mov    0x8(%ebp),%eax
  80189e:	89 04 24             	mov    %eax,(%esp)
  8018a1:	e8 68 ff ff ff       	call   80180e <vfprintf>
  va_end(ap);

  return cnt;
}
  8018a6:	c9                   	leave  
  8018a7:	c3                   	ret    

008018a8 <printf>:

int
printf(const char *fmt, ...)
{
  8018a8:	55                   	push   %ebp
  8018a9:	89 e5                	mov    %esp,%ebp
  8018ab:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8018ae:	8d 45 0c             	lea    0xc(%ebp),%eax
  cnt = vfprintf(1, fmt, ap);
  8018b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018bc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8018c3:	e8 46 ff ff ff       	call   80180e <vfprintf>
  va_end(ap);

  return cnt;
}
  8018c8:	c9                   	leave  
  8018c9:	c3                   	ret    

008018ca <devpipe_stat>:
  return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	56                   	push   %esi
  8018ce:	53                   	push   %ebx
  8018cf:	83 ec 10             	sub    $0x10,%esp
  8018d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct Pipe *p = (struct Pipe*)fd2data(fd);
  8018d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d8:	89 04 24             	mov    %eax,(%esp)
  8018db:	e8 a0 f6 ff ff       	call   800f80 <fd2data>
  8018e0:	89 c6                	mov    %eax,%esi

  strcpy(stat->st_name, "<pipe>");
  8018e2:	c7 44 24 04 3c 26 80 	movl   $0x80263c,0x4(%esp)
  8018e9:	00 
  8018ea:	89 1c 24             	mov    %ebx,(%esp)
  8018ed:	e8 f5 ef ff ff       	call   8008e7 <strcpy>
  stat->st_size = p->p_wpos - p->p_rpos;
  8018f2:	8b 46 04             	mov    0x4(%esi),%eax
  8018f5:	2b 06                	sub    (%esi),%eax
  8018f7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  stat->st_isdir = 0;
  8018fd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801904:	00 00 00 
  stat->st_dev = &devpipe;
  801907:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80190e:	30 80 00 
  return 0;
}
  801911:	b8 00 00 00 00       	mov    $0x0,%eax
  801916:	83 c4 10             	add    $0x10,%esp
  801919:	5b                   	pop    %ebx
  80191a:	5e                   	pop    %esi
  80191b:	5d                   	pop    %ebp
  80191c:	c3                   	ret    

0080191d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80191d:	55                   	push   %ebp
  80191e:	89 e5                	mov    %esp,%ebp
  801920:	53                   	push   %ebx
  801921:	83 ec 14             	sub    $0x14,%esp
  801924:	8b 5d 08             	mov    0x8(%ebp),%ebx
  (void)sys_page_unmap(0, fd);
  801927:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80192b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801932:	e8 73 f4 ff ff       	call   800daa <sys_page_unmap>
  return sys_page_unmap(0, fd2data(fd));
  801937:	89 1c 24             	mov    %ebx,(%esp)
  80193a:	e8 41 f6 ff ff       	call   800f80 <fd2data>
  80193f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801943:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80194a:	e8 5b f4 ff ff       	call   800daa <sys_page_unmap>
}
  80194f:	83 c4 14             	add    $0x14,%esp
  801952:	5b                   	pop    %ebx
  801953:	5d                   	pop    %ebp
  801954:	c3                   	ret    

00801955 <_pipeisclosed>:
  return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	57                   	push   %edi
  801959:	56                   	push   %esi
  80195a:	53                   	push   %ebx
  80195b:	83 ec 2c             	sub    $0x2c,%esp
  80195e:	89 c6                	mov    %eax,%esi
  801960:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  int n, nn, ret;

  while (1) {
    n = thisenv->env_runs;
  801963:	a1 20 60 80 00       	mov    0x806020,%eax
  801968:	8b 58 58             	mov    0x58(%eax),%ebx
    ret = pageref(fd) == pageref(p);
  80196b:	89 34 24             	mov    %esi,(%esp)
  80196e:	e8 ac 05 00 00       	call   801f1f <pageref>
  801973:	89 c7                	mov    %eax,%edi
  801975:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801978:	89 04 24             	mov    %eax,(%esp)
  80197b:	e8 9f 05 00 00       	call   801f1f <pageref>
  801980:	39 c7                	cmp    %eax,%edi
  801982:	0f 94 c2             	sete   %dl
  801985:	0f b6 c2             	movzbl %dl,%eax
    nn = thisenv->env_runs;
  801988:	8b 0d 20 60 80 00    	mov    0x806020,%ecx
  80198e:	8b 79 58             	mov    0x58(%ecx),%edi
    if (n == nn)
  801991:	39 fb                	cmp    %edi,%ebx
  801993:	74 21                	je     8019b6 <_pipeisclosed+0x61>
      return ret;
    if (n != nn && ret == 1)
  801995:	84 d2                	test   %dl,%dl
  801997:	74 ca                	je     801963 <_pipeisclosed+0xe>
      cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801999:	8b 51 58             	mov    0x58(%ecx),%edx
  80199c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019a0:	89 54 24 08          	mov    %edx,0x8(%esp)
  8019a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019a8:	c7 04 24 43 26 80 00 	movl   $0x802643,(%esp)
  8019af:	e8 0b e9 ff ff       	call   8002bf <cprintf>
  8019b4:	eb ad                	jmp    801963 <_pipeisclosed+0xe>
  }
}
  8019b6:	83 c4 2c             	add    $0x2c,%esp
  8019b9:	5b                   	pop    %ebx
  8019ba:	5e                   	pop    %esi
  8019bb:	5f                   	pop    %edi
  8019bc:	5d                   	pop    %ebp
  8019bd:	c3                   	ret    

008019be <devpipe_write>:
  return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019be:	55                   	push   %ebp
  8019bf:	89 e5                	mov    %esp,%ebp
  8019c1:	57                   	push   %edi
  8019c2:	56                   	push   %esi
  8019c3:	53                   	push   %ebx
  8019c4:	83 ec 1c             	sub    $0x1c,%esp
  8019c7:	8b 75 08             	mov    0x8(%ebp),%esi
  const uint8_t *buf;
  size_t i;
  struct Pipe *p;

  p = (struct Pipe*)fd2data(fd);
  8019ca:	89 34 24             	mov    %esi,(%esp)
  8019cd:	e8 ae f5 ff ff       	call   800f80 <fd2data>
  8019d2:	89 c3                	mov    %eax,%ebx
  if (debug)
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  8019d4:	bf 00 00 00 00       	mov    $0x0,%edi
  8019d9:	eb 45                	jmp    801a20 <devpipe_write+0x62>
    while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
      // pipe is full
      // if all the readers are gone
      // (it's only writers like us now),
      // note eof
      if (_pipeisclosed(fd, p))
  8019db:	89 da                	mov    %ebx,%edx
  8019dd:	89 f0                	mov    %esi,%eax
  8019df:	e8 71 ff ff ff       	call   801955 <_pipeisclosed>
  8019e4:	85 c0                	test   %eax,%eax
  8019e6:	75 41                	jne    801a29 <devpipe_write+0x6b>
        return 0;
      // yield and see what happens
      if (debug)
        cprintf("devpipe_write yield\n");
      sys_yield();
  8019e8:	e8 f7 f2 ff ff       	call   800ce4 <sys_yield>
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
    while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019ed:	8b 43 04             	mov    0x4(%ebx),%eax
  8019f0:	8b 0b                	mov    (%ebx),%ecx
  8019f2:	8d 51 20             	lea    0x20(%ecx),%edx
  8019f5:	39 d0                	cmp    %edx,%eax
  8019f7:	73 e2                	jae    8019db <devpipe_write+0x1d>
        cprintf("devpipe_write yield\n");
      sys_yield();
    }
    // there's room for a byte.  store it.
    // wait to increment wpos until the byte is stored!
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019fc:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a00:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a03:	99                   	cltd   
  801a04:	c1 ea 1b             	shr    $0x1b,%edx
  801a07:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801a0a:	83 e1 1f             	and    $0x1f,%ecx
  801a0d:	29 d1                	sub    %edx,%ecx
  801a0f:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801a13:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
    p->p_wpos++;
  801a17:	83 c0 01             	add    $0x1,%eax
  801a1a:	89 43 04             	mov    %eax,0x4(%ebx)
  if (debug)
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  801a1d:	83 c7 01             	add    $0x1,%edi
  801a20:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a23:	75 c8                	jne    8019ed <devpipe_write+0x2f>
    // wait to increment wpos until the byte is stored!
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
    p->p_wpos++;
  }

  return i;
  801a25:	89 f8                	mov    %edi,%eax
  801a27:	eb 05                	jmp    801a2e <devpipe_write+0x70>
      // pipe is full
      // if all the readers are gone
      // (it's only writers like us now),
      // note eof
      if (_pipeisclosed(fd, p))
        return 0;
  801a29:	b8 00 00 00 00       	mov    $0x0,%eax
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
    p->p_wpos++;
  }

  return i;
}
  801a2e:	83 c4 1c             	add    $0x1c,%esp
  801a31:	5b                   	pop    %ebx
  801a32:	5e                   	pop    %esi
  801a33:	5f                   	pop    %edi
  801a34:	5d                   	pop    %ebp
  801a35:	c3                   	ret    

00801a36 <devpipe_read>:
  return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a36:	55                   	push   %ebp
  801a37:	89 e5                	mov    %esp,%ebp
  801a39:	57                   	push   %edi
  801a3a:	56                   	push   %esi
  801a3b:	53                   	push   %ebx
  801a3c:	83 ec 1c             	sub    $0x1c,%esp
  801a3f:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint8_t *buf;
  size_t i;
  struct Pipe *p;

  p = (struct Pipe*)fd2data(fd);
  801a42:	89 3c 24             	mov    %edi,(%esp)
  801a45:	e8 36 f5 ff ff       	call   800f80 <fd2data>
  801a4a:	89 c3                	mov    %eax,%ebx
  if (debug)
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  801a4c:	be 00 00 00 00       	mov    $0x0,%esi
  801a51:	eb 3d                	jmp    801a90 <devpipe_read+0x5a>
    while (p->p_rpos == p->p_wpos) {
      // pipe is empty
      // if we got any data, return it
      if (i > 0)
  801a53:	85 f6                	test   %esi,%esi
  801a55:	74 04                	je     801a5b <devpipe_read+0x25>
        return i;
  801a57:	89 f0                	mov    %esi,%eax
  801a59:	eb 43                	jmp    801a9e <devpipe_read+0x68>
      // if all the writers are gone, note eof
      if (_pipeisclosed(fd, p))
  801a5b:	89 da                	mov    %ebx,%edx
  801a5d:	89 f8                	mov    %edi,%eax
  801a5f:	e8 f1 fe ff ff       	call   801955 <_pipeisclosed>
  801a64:	85 c0                	test   %eax,%eax
  801a66:	75 31                	jne    801a99 <devpipe_read+0x63>
        return 0;
      // yield and see what happens
      if (debug)
        cprintf("devpipe_read yield\n");
      sys_yield();
  801a68:	e8 77 f2 ff ff       	call   800ce4 <sys_yield>
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
    while (p->p_rpos == p->p_wpos) {
  801a6d:	8b 03                	mov    (%ebx),%eax
  801a6f:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a72:	74 df                	je     801a53 <devpipe_read+0x1d>
        cprintf("devpipe_read yield\n");
      sys_yield();
    }
    // there's a byte.  take it.
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a74:	99                   	cltd   
  801a75:	c1 ea 1b             	shr    $0x1b,%edx
  801a78:	01 d0                	add    %edx,%eax
  801a7a:	83 e0 1f             	and    $0x1f,%eax
  801a7d:	29 d0                	sub    %edx,%eax
  801a7f:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801a84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a87:	88 04 31             	mov    %al,(%ecx,%esi,1)
    p->p_rpos++;
  801a8a:	83 03 01             	addl   $0x1,(%ebx)
  if (debug)
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  801a8d:	83 c6 01             	add    $0x1,%esi
  801a90:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a93:	75 d8                	jne    801a6d <devpipe_read+0x37>
    // there's a byte.  take it.
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
    p->p_rpos++;
  }
  return i;
  801a95:	89 f0                	mov    %esi,%eax
  801a97:	eb 05                	jmp    801a9e <devpipe_read+0x68>
      // if we got any data, return it
      if (i > 0)
        return i;
      // if all the writers are gone, note eof
      if (_pipeisclosed(fd, p))
        return 0;
  801a99:	b8 00 00 00 00       	mov    $0x0,%eax
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
    p->p_rpos++;
  }
  return i;
}
  801a9e:	83 c4 1c             	add    $0x1c,%esp
  801aa1:	5b                   	pop    %ebx
  801aa2:	5e                   	pop    %esi
  801aa3:	5f                   	pop    %edi
  801aa4:	5d                   	pop    %ebp
  801aa5:	c3                   	ret    

00801aa6 <pipe>:
  uint8_t p_buf[PIPEBUFSIZ];    // data buffer
};

int
pipe(int pfd[2])
{
  801aa6:	55                   	push   %ebp
  801aa7:	89 e5                	mov    %esp,%ebp
  801aa9:	56                   	push   %esi
  801aaa:	53                   	push   %ebx
  801aab:	83 ec 30             	sub    $0x30,%esp
  int r;
  struct Fd *fd0, *fd1;
  void *va;

  // allocate the file descriptor table entries
  if ((r = fd_alloc(&fd0)) < 0
  801aae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab1:	89 04 24             	mov    %eax,(%esp)
  801ab4:	e8 de f4 ff ff       	call   800f97 <fd_alloc>
  801ab9:	89 c2                	mov    %eax,%edx
  801abb:	85 d2                	test   %edx,%edx
  801abd:	0f 88 4d 01 00 00    	js     801c10 <pipe+0x16a>
      || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ac3:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801aca:	00 
  801acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ace:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ad9:	e8 25 f2 ff ff       	call   800d03 <sys_page_alloc>
  801ade:	89 c2                	mov    %eax,%edx
  801ae0:	85 d2                	test   %edx,%edx
  801ae2:	0f 88 28 01 00 00    	js     801c10 <pipe+0x16a>
    goto err;

  if ((r = fd_alloc(&fd1)) < 0
  801ae8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801aeb:	89 04 24             	mov    %eax,(%esp)
  801aee:	e8 a4 f4 ff ff       	call   800f97 <fd_alloc>
  801af3:	89 c3                	mov    %eax,%ebx
  801af5:	85 c0                	test   %eax,%eax
  801af7:	0f 88 fe 00 00 00    	js     801bfb <pipe+0x155>
      || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801afd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b04:	00 
  801b05:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b08:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b0c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b13:	e8 eb f1 ff ff       	call   800d03 <sys_page_alloc>
  801b18:	89 c3                	mov    %eax,%ebx
  801b1a:	85 c0                	test   %eax,%eax
  801b1c:	0f 88 d9 00 00 00    	js     801bfb <pipe+0x155>
    goto err1;

  // allocate the pipe structure as first data page in both
  va = fd2data(fd0);
  801b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b25:	89 04 24             	mov    %eax,(%esp)
  801b28:	e8 53 f4 ff ff       	call   800f80 <fd2data>
  801b2d:	89 c6                	mov    %eax,%esi
  if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b2f:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b36:	00 
  801b37:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b3b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b42:	e8 bc f1 ff ff       	call   800d03 <sys_page_alloc>
  801b47:	89 c3                	mov    %eax,%ebx
  801b49:	85 c0                	test   %eax,%eax
  801b4b:	0f 88 97 00 00 00    	js     801be8 <pipe+0x142>
    goto err2;
  if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b51:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b54:	89 04 24             	mov    %eax,(%esp)
  801b57:	e8 24 f4 ff ff       	call   800f80 <fd2data>
  801b5c:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801b63:	00 
  801b64:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b68:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b6f:	00 
  801b70:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b7b:	e8 d7 f1 ff ff       	call   800d57 <sys_page_map>
  801b80:	89 c3                	mov    %eax,%ebx
  801b82:	85 c0                	test   %eax,%eax
  801b84:	78 52                	js     801bd8 <pipe+0x132>
    goto err3;

  // set up fd structures
  fd0->fd_dev_id = devpipe.dev_id;
  801b86:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b8f:	89 10                	mov    %edx,(%eax)
  fd0->fd_omode = O_RDONLY;
  801b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b94:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

  fd1->fd_dev_id = devpipe.dev_id;
  801b9b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ba1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ba4:	89 10                	mov    %edx,(%eax)
  fd1->fd_omode = O_WRONLY;
  801ba6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ba9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

  if (debug)
    cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

  pfd[0] = fd2num(fd0);
  801bb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb3:	89 04 24             	mov    %eax,(%esp)
  801bb6:	e8 b5 f3 ff ff       	call   800f70 <fd2num>
  801bbb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bbe:	89 01                	mov    %eax,(%ecx)
  pfd[1] = fd2num(fd1);
  801bc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bc3:	89 04 24             	mov    %eax,(%esp)
  801bc6:	e8 a5 f3 ff ff       	call   800f70 <fd2num>
  801bcb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bce:	89 41 04             	mov    %eax,0x4(%ecx)
  return 0;
  801bd1:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd6:	eb 38                	jmp    801c10 <pipe+0x16a>

err3:
  sys_page_unmap(0, va);
  801bd8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bdc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801be3:	e8 c2 f1 ff ff       	call   800daa <sys_page_unmap>
err2:
  sys_page_unmap(0, fd1);
  801be8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801beb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bf6:	e8 af f1 ff ff       	call   800daa <sys_page_unmap>
err1:
  sys_page_unmap(0, fd0);
  801bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c02:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c09:	e8 9c f1 ff ff       	call   800daa <sys_page_unmap>
  801c0e:	89 d8                	mov    %ebx,%eax
err:
  return r;
}
  801c10:	83 c4 30             	add    $0x30,%esp
  801c13:	5b                   	pop    %ebx
  801c14:	5e                   	pop    %esi
  801c15:	5d                   	pop    %ebp
  801c16:	c3                   	ret    

00801c17 <pipeisclosed>:
  }
}

int
pipeisclosed(int fdnum)
{
  801c17:	55                   	push   %ebp
  801c18:	89 e5                	mov    %esp,%ebp
  801c1a:	83 ec 28             	sub    $0x28,%esp
  struct Fd *fd;
  struct Pipe *p;
  int r;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c20:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c24:	8b 45 08             	mov    0x8(%ebp),%eax
  801c27:	89 04 24             	mov    %eax,(%esp)
  801c2a:	e8 b7 f3 ff ff       	call   800fe6 <fd_lookup>
  801c2f:	89 c2                	mov    %eax,%edx
  801c31:	85 d2                	test   %edx,%edx
  801c33:	78 15                	js     801c4a <pipeisclosed+0x33>
    return r;
  p = (struct Pipe*)fd2data(fd);
  801c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c38:	89 04 24             	mov    %eax,(%esp)
  801c3b:	e8 40 f3 ff ff       	call   800f80 <fd2data>
  return _pipeisclosed(fd, p);
  801c40:	89 c2                	mov    %eax,%edx
  801c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c45:	e8 0b fd ff ff       	call   801955 <_pipeisclosed>
}
  801c4a:	c9                   	leave  
  801c4b:	c3                   	ret    
  801c4c:	66 90                	xchg   %ax,%ax
  801c4e:	66 90                	xchg   %ax,%ax

00801c50 <devcons_close>:
  return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
  USED(fd);

  return 0;
}
  801c53:	b8 00 00 00 00       	mov    $0x0,%eax
  801c58:	5d                   	pop    %ebp
  801c59:	c3                   	ret    

00801c5a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c5a:	55                   	push   %ebp
  801c5b:	89 e5                	mov    %esp,%ebp
  801c5d:	83 ec 18             	sub    $0x18,%esp
  strcpy(stat->st_name, "<cons>");
  801c60:	c7 44 24 04 5b 26 80 	movl   $0x80265b,0x4(%esp)
  801c67:	00 
  801c68:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c6b:	89 04 24             	mov    %eax,(%esp)
  801c6e:	e8 74 ec ff ff       	call   8008e7 <strcpy>
  return 0;
}
  801c73:	b8 00 00 00 00       	mov    $0x0,%eax
  801c78:	c9                   	leave  
  801c79:	c3                   	ret    

00801c7a <devcons_write>:
  return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c7a:	55                   	push   %ebp
  801c7b:	89 e5                	mov    %esp,%ebp
  801c7d:	57                   	push   %edi
  801c7e:	56                   	push   %esi
  801c7f:	53                   	push   %ebx
  801c80:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  801c86:	bb 00 00 00 00       	mov    $0x0,%ebx
    m = n - tot;
    if (m > sizeof(buf) - 1)
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
  801c8b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  801c91:	eb 31                	jmp    801cc4 <devcons_write+0x4a>
    m = n - tot;
  801c93:	8b 75 10             	mov    0x10(%ebp),%esi
  801c96:	29 de                	sub    %ebx,%esi
    if (m > sizeof(buf) - 1)
  801c98:	83 fe 7f             	cmp    $0x7f,%esi
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
    m = n - tot;
  801c9b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ca0:	0f 47 f2             	cmova  %edx,%esi
    if (m > sizeof(buf) - 1)
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
  801ca3:	89 74 24 08          	mov    %esi,0x8(%esp)
  801ca7:	03 45 0c             	add    0xc(%ebp),%eax
  801caa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cae:	89 3c 24             	mov    %edi,(%esp)
  801cb1:	e8 ce ed ff ff       	call   800a84 <memmove>
    sys_cputs(buf, m);
  801cb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cba:	89 3c 24             	mov    %edi,(%esp)
  801cbd:	e8 74 ef ff ff       	call   800c36 <sys_cputs>
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  801cc2:	01 f3                	add    %esi,%ebx
  801cc4:	89 d8                	mov    %ebx,%eax
  801cc6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cc9:	72 c8                	jb     801c93 <devcons_write+0x19>
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
    sys_cputs(buf, m);
  }
  return tot;
}
  801ccb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801cd1:	5b                   	pop    %ebx
  801cd2:	5e                   	pop    %esi
  801cd3:	5f                   	pop    %edi
  801cd4:	5d                   	pop    %ebp
  801cd5:	c3                   	ret    

00801cd6 <devcons_read>:
  return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cd6:	55                   	push   %ebp
  801cd7:	89 e5                	mov    %esp,%ebp
  801cd9:	83 ec 08             	sub    $0x8,%esp
  int c;

  if (n == 0)
    return 0;
  801cdc:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  int c;

  if (n == 0)
  801ce1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ce5:	75 07                	jne    801cee <devcons_read+0x18>
  801ce7:	eb 2a                	jmp    801d13 <devcons_read+0x3d>
    return 0;

  while ((c = sys_cgetc()) == 0)
    sys_yield();
  801ce9:	e8 f6 ef ff ff       	call   800ce4 <sys_yield>
  int c;

  if (n == 0)
    return 0;

  while ((c = sys_cgetc()) == 0)
  801cee:	66 90                	xchg   %ax,%ax
  801cf0:	e8 5f ef ff ff       	call   800c54 <sys_cgetc>
  801cf5:	85 c0                	test   %eax,%eax
  801cf7:	74 f0                	je     801ce9 <devcons_read+0x13>
    sys_yield();
  if (c < 0)
  801cf9:	85 c0                	test   %eax,%eax
  801cfb:	78 16                	js     801d13 <devcons_read+0x3d>
    return c;
  if (c == 0x04)        // ctl-d is eof
  801cfd:	83 f8 04             	cmp    $0x4,%eax
  801d00:	74 0c                	je     801d0e <devcons_read+0x38>
    return 0;
  *(char*)vbuf = c;
  801d02:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d05:	88 02                	mov    %al,(%edx)
  return 1;
  801d07:	b8 01 00 00 00       	mov    $0x1,%eax
  801d0c:	eb 05                	jmp    801d13 <devcons_read+0x3d>
  while ((c = sys_cgetc()) == 0)
    sys_yield();
  if (c < 0)
    return c;
  if (c == 0x04)        // ctl-d is eof
    return 0;
  801d0e:	b8 00 00 00 00       	mov    $0x0,%eax
  *(char*)vbuf = c;
  return 1;
}
  801d13:	c9                   	leave  
  801d14:	c3                   	ret    

00801d15 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d15:	55                   	push   %ebp
  801d16:	89 e5                	mov    %esp,%ebp
  801d18:	83 ec 28             	sub    $0x28,%esp
  char c = ch;
  801d1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1e:	88 45 f7             	mov    %al,-0x9(%ebp)

  // Unlike standard Unix's putchar,
  // the cputchar function _always_ outputs to the system console.
  sys_cputs(&c, 1);
  801d21:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801d28:	00 
  801d29:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d2c:	89 04 24             	mov    %eax,(%esp)
  801d2f:	e8 02 ef ff ff       	call   800c36 <sys_cputs>
}
  801d34:	c9                   	leave  
  801d35:	c3                   	ret    

00801d36 <getchar>:

int
getchar(void)
{
  801d36:	55                   	push   %ebp
  801d37:	89 e5                	mov    %esp,%ebp
  801d39:	83 ec 28             	sub    $0x28,%esp
  int r;

  // JOS does, however, support standard _input_ redirection,
  // allowing the user to redirect script files to the shell and such.
  // getchar() reads a character from file descriptor 0.
  r = read(0, &c, 1);
  801d3c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801d43:	00 
  801d44:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d52:	e8 1e f5 ff ff       	call   801275 <read>
  if (r < 0)
  801d57:	85 c0                	test   %eax,%eax
  801d59:	78 0f                	js     801d6a <getchar+0x34>
    return r;
  if (r < 1)
  801d5b:	85 c0                	test   %eax,%eax
  801d5d:	7e 06                	jle    801d65 <getchar+0x2f>
    return -E_EOF;
  return c;
  801d5f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d63:	eb 05                	jmp    801d6a <getchar+0x34>
  // getchar() reads a character from file descriptor 0.
  r = read(0, &c, 1);
  if (r < 0)
    return r;
  if (r < 1)
    return -E_EOF;
  801d65:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  /* int r;
  // sys_cgetc does not block, but getchar should.
  while ((r = sys_cgetc()) == 0)
    sys_yield();
  return r; */
}
  801d6a:	c9                   	leave  
  801d6b:	c3                   	ret    

00801d6c <iscons>:
  .dev_stat   =     devcons_stat
};

int
iscons(int fdnum)
{
  801d6c:	55                   	push   %ebp
  801d6d:	89 e5                	mov    %esp,%ebp
  801d6f:	83 ec 28             	sub    $0x28,%esp
  int r;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d75:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d79:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7c:	89 04 24             	mov    %eax,(%esp)
  801d7f:	e8 62 f2 ff ff       	call   800fe6 <fd_lookup>
  801d84:	85 c0                	test   %eax,%eax
  801d86:	78 11                	js     801d99 <iscons+0x2d>
    return r;
  return fd->fd_dev_id == devcons.dev_id;
  801d88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d8b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d91:	39 10                	cmp    %edx,(%eax)
  801d93:	0f 94 c0             	sete   %al
  801d96:	0f b6 c0             	movzbl %al,%eax
}
  801d99:	c9                   	leave  
  801d9a:	c3                   	ret    

00801d9b <opencons>:

int
opencons(void)
{
  801d9b:	55                   	push   %ebp
  801d9c:	89 e5                	mov    %esp,%ebp
  801d9e:	83 ec 28             	sub    $0x28,%esp
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
  801da1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da4:	89 04 24             	mov    %eax,(%esp)
  801da7:	e8 eb f1 ff ff       	call   800f97 <fd_alloc>
    return r;
  801dac:	89 c2                	mov    %eax,%edx
opencons(void)
{
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
  801dae:	85 c0                	test   %eax,%eax
  801db0:	78 40                	js     801df2 <opencons+0x57>
    return r;
  if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801db2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801db9:	00 
  801dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dbd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dc1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dc8:	e8 36 ef ff ff       	call   800d03 <sys_page_alloc>
    return r;
  801dcd:	89 c2                	mov    %eax,%edx
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
    return r;
  if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dcf:	85 c0                	test   %eax,%eax
  801dd1:	78 1f                	js     801df2 <opencons+0x57>
    return r;
  fd->fd_dev_id = devcons.dev_id;
  801dd3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ddc:	89 10                	mov    %edx,(%eax)
  fd->fd_omode = O_RDWR;
  801dde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
  return fd2num(fd);
  801de8:	89 04 24             	mov    %eax,(%esp)
  801deb:	e8 80 f1 ff ff       	call   800f70 <fd2num>
  801df0:	89 c2                	mov    %eax,%edx
}
  801df2:	89 d0                	mov    %edx,%eax
  801df4:	c9                   	leave  
  801df5:	c3                   	ret    

00801df6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801df6:	55                   	push   %ebp
  801df7:	89 e5                	mov    %esp,%ebp
  801df9:	56                   	push   %esi
  801dfa:	53                   	push   %ebx
  801dfb:	83 ec 10             	sub    $0x10,%esp
  801dfe:	8b 75 08             	mov    0x8(%ebp),%esi
  801e01:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e04:	8b 5d 10             	mov    0x10(%ebp),%ebx
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;
  801e07:	85 c0                	test   %eax,%eax
  801e09:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801e0e:	0f 44 c2             	cmove  %edx,%eax
  if ((r = sys_ipc_recv(pg)) < 0) {
  801e11:	89 04 24             	mov    %eax,(%esp)
  801e14:	e8 00 f1 ff ff       	call   800f19 <sys_ipc_recv>
  801e19:	85 c0                	test   %eax,%eax
  801e1b:	79 34                	jns    801e51 <ipc_recv+0x5b>
    if (from_env_store)
  801e1d:	85 f6                	test   %esi,%esi
  801e1f:	74 06                	je     801e27 <ipc_recv+0x31>
      *from_env_store = 0;
  801e21:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (perm_store)
  801e27:	85 db                	test   %ebx,%ebx
  801e29:	74 06                	je     801e31 <ipc_recv+0x3b>
      *perm_store = 0;
  801e2b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    panic("sys_ipc_recv: %e", r);
  801e31:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e35:	c7 44 24 08 67 26 80 	movl   $0x802667,0x8(%esp)
  801e3c:	00 
  801e3d:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801e44:	00 
  801e45:	c7 04 24 78 26 80 00 	movl   $0x802678,(%esp)
  801e4c:	e8 75 e3 ff ff       	call   8001c6 <_panic>
  }

  if (from_env_store)
  801e51:	85 f6                	test   %esi,%esi
  801e53:	74 0a                	je     801e5f <ipc_recv+0x69>
    *from_env_store = thisenv->env_ipc_from;
  801e55:	a1 20 60 80 00       	mov    0x806020,%eax
  801e5a:	8b 40 74             	mov    0x74(%eax),%eax
  801e5d:	89 06                	mov    %eax,(%esi)
  if (perm_store)
  801e5f:	85 db                	test   %ebx,%ebx
  801e61:	74 0a                	je     801e6d <ipc_recv+0x77>
    *perm_store |= thisenv->env_ipc_perm;
  801e63:	a1 20 60 80 00       	mov    0x806020,%eax
  801e68:	8b 40 78             	mov    0x78(%eax),%eax
  801e6b:	09 03                	or     %eax,(%ebx)

  return thisenv->env_ipc_value;
  801e6d:	a1 20 60 80 00       	mov    0x806020,%eax
  801e72:	8b 40 70             	mov    0x70(%eax),%eax

}
  801e75:	83 c4 10             	add    $0x10,%esp
  801e78:	5b                   	pop    %ebx
  801e79:	5e                   	pop    %esi
  801e7a:	5d                   	pop    %ebp
  801e7b:	c3                   	ret    

00801e7c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	57                   	push   %edi
  801e80:	56                   	push   %esi
  801e81:	53                   	push   %ebx
  801e82:	83 ec 1c             	sub    $0x1c,%esp
  801e85:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e88:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;
  801e8e:	85 db                	test   %ebx,%ebx
  801e90:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e95:	0f 44 d8             	cmove  %eax,%ebx

  while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801e98:	eb 2a                	jmp    801ec4 <ipc_send+0x48>
    if (r != -E_IPC_NOT_RECV)
  801e9a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e9d:	74 20                	je     801ebf <ipc_send+0x43>
      panic("ipc_send: %e", r);
  801e9f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ea3:	c7 44 24 08 82 26 80 	movl   $0x802682,0x8(%esp)
  801eaa:	00 
  801eab:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801eb2:	00 
  801eb3:	c7 04 24 78 26 80 00 	movl   $0x802678,(%esp)
  801eba:	e8 07 e3 ff ff       	call   8001c6 <_panic>
    sys_yield();
  801ebf:	e8 20 ee ff ff       	call   800ce4 <sys_yield>
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;

  while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801ec4:	8b 45 14             	mov    0x14(%ebp),%eax
  801ec7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ecb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ecf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ed3:	89 3c 24             	mov    %edi,(%esp)
  801ed6:	e8 1b f0 ff ff       	call   800ef6 <sys_ipc_try_send>
  801edb:	85 c0                	test   %eax,%eax
  801edd:	78 bb                	js     801e9a <ipc_send+0x1e>
    if (r != -E_IPC_NOT_RECV)
      panic("ipc_send: %e", r);
    sys_yield();
  }
}
  801edf:	83 c4 1c             	add    $0x1c,%esp
  801ee2:	5b                   	pop    %ebx
  801ee3:	5e                   	pop    %esi
  801ee4:	5f                   	pop    %edi
  801ee5:	5d                   	pop    %ebp
  801ee6:	c3                   	ret    

00801ee7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ee7:	55                   	push   %ebp
  801ee8:	89 e5                	mov    %esp,%ebp
  801eea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int i;

  for (i = 0; i < NENV; i++)
  801eed:	b8 00 00 00 00       	mov    $0x0,%eax
    if (envs[i].env_type == type)
  801ef2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ef5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801efb:	8b 52 50             	mov    0x50(%edx),%edx
  801efe:	39 ca                	cmp    %ecx,%edx
  801f00:	75 0d                	jne    801f0f <ipc_find_env+0x28>
      return envs[i].env_id;
  801f02:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f05:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801f0a:	8b 40 40             	mov    0x40(%eax),%eax
  801f0d:	eb 0e                	jmp    801f1d <ipc_find_env+0x36>
envid_t
ipc_find_env(enum EnvType type)
{
  int i;

  for (i = 0; i < NENV; i++)
  801f0f:	83 c0 01             	add    $0x1,%eax
  801f12:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f17:	75 d9                	jne    801ef2 <ipc_find_env+0xb>
    if (envs[i].env_type == type)
      return envs[i].env_id;
  return 0;
  801f19:	66 b8 00 00          	mov    $0x0,%ax
}
  801f1d:	5d                   	pop    %ebp
  801f1e:	c3                   	ret    

00801f1f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f1f:	55                   	push   %ebp
  801f20:	89 e5                	mov    %esp,%ebp
  801f22:	8b 55 08             	mov    0x8(%ebp),%edx
  pte_t pte;

  if (!(uvpd[PDX(v)] & PTE_P))
  801f25:	89 d0                	mov    %edx,%eax
  801f27:	c1 e8 16             	shr    $0x16,%eax
  801f2a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
    return 0;
  801f31:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
  pte_t pte;

  if (!(uvpd[PDX(v)] & PTE_P))
  801f36:	f6 c1 01             	test   $0x1,%cl
  801f39:	74 1d                	je     801f58 <pageref+0x39>
    return 0;
  pte = uvpt[PGNUM(v)];
  801f3b:	c1 ea 0c             	shr    $0xc,%edx
  801f3e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  if (!(pte & PTE_P))
  801f45:	f6 c2 01             	test   $0x1,%dl
  801f48:	74 0e                	je     801f58 <pageref+0x39>
    return 0;
  return pages[PGNUM(pte)].pp_ref;
  801f4a:	c1 ea 0c             	shr    $0xc,%edx
  801f4d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f54:	ef 
  801f55:	0f b7 c0             	movzwl %ax,%eax
}
  801f58:	5d                   	pop    %ebp
  801f59:	c3                   	ret    
  801f5a:	66 90                	xchg   %ax,%ax
  801f5c:	66 90                	xchg   %ax,%ax
  801f5e:	66 90                	xchg   %ax,%ax

00801f60 <__udivdi3>:
  801f60:	55                   	push   %ebp
  801f61:	57                   	push   %edi
  801f62:	56                   	push   %esi
  801f63:	83 ec 0c             	sub    $0xc,%esp
  801f66:	8b 44 24 28          	mov    0x28(%esp),%eax
  801f6a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801f6e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801f72:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801f76:	85 c0                	test   %eax,%eax
  801f78:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f7c:	89 ea                	mov    %ebp,%edx
  801f7e:	89 0c 24             	mov    %ecx,(%esp)
  801f81:	75 2d                	jne    801fb0 <__udivdi3+0x50>
  801f83:	39 e9                	cmp    %ebp,%ecx
  801f85:	77 61                	ja     801fe8 <__udivdi3+0x88>
  801f87:	85 c9                	test   %ecx,%ecx
  801f89:	89 ce                	mov    %ecx,%esi
  801f8b:	75 0b                	jne    801f98 <__udivdi3+0x38>
  801f8d:	b8 01 00 00 00       	mov    $0x1,%eax
  801f92:	31 d2                	xor    %edx,%edx
  801f94:	f7 f1                	div    %ecx
  801f96:	89 c6                	mov    %eax,%esi
  801f98:	31 d2                	xor    %edx,%edx
  801f9a:	89 e8                	mov    %ebp,%eax
  801f9c:	f7 f6                	div    %esi
  801f9e:	89 c5                	mov    %eax,%ebp
  801fa0:	89 f8                	mov    %edi,%eax
  801fa2:	f7 f6                	div    %esi
  801fa4:	89 ea                	mov    %ebp,%edx
  801fa6:	83 c4 0c             	add    $0xc,%esp
  801fa9:	5e                   	pop    %esi
  801faa:	5f                   	pop    %edi
  801fab:	5d                   	pop    %ebp
  801fac:	c3                   	ret    
  801fad:	8d 76 00             	lea    0x0(%esi),%esi
  801fb0:	39 e8                	cmp    %ebp,%eax
  801fb2:	77 24                	ja     801fd8 <__udivdi3+0x78>
  801fb4:	0f bd e8             	bsr    %eax,%ebp
  801fb7:	83 f5 1f             	xor    $0x1f,%ebp
  801fba:	75 3c                	jne    801ff8 <__udivdi3+0x98>
  801fbc:	8b 74 24 04          	mov    0x4(%esp),%esi
  801fc0:	39 34 24             	cmp    %esi,(%esp)
  801fc3:	0f 86 9f 00 00 00    	jbe    802068 <__udivdi3+0x108>
  801fc9:	39 d0                	cmp    %edx,%eax
  801fcb:	0f 82 97 00 00 00    	jb     802068 <__udivdi3+0x108>
  801fd1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fd8:	31 d2                	xor    %edx,%edx
  801fda:	31 c0                	xor    %eax,%eax
  801fdc:	83 c4 0c             	add    $0xc,%esp
  801fdf:	5e                   	pop    %esi
  801fe0:	5f                   	pop    %edi
  801fe1:	5d                   	pop    %ebp
  801fe2:	c3                   	ret    
  801fe3:	90                   	nop
  801fe4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fe8:	89 f8                	mov    %edi,%eax
  801fea:	f7 f1                	div    %ecx
  801fec:	31 d2                	xor    %edx,%edx
  801fee:	83 c4 0c             	add    $0xc,%esp
  801ff1:	5e                   	pop    %esi
  801ff2:	5f                   	pop    %edi
  801ff3:	5d                   	pop    %ebp
  801ff4:	c3                   	ret    
  801ff5:	8d 76 00             	lea    0x0(%esi),%esi
  801ff8:	89 e9                	mov    %ebp,%ecx
  801ffa:	8b 3c 24             	mov    (%esp),%edi
  801ffd:	d3 e0                	shl    %cl,%eax
  801fff:	89 c6                	mov    %eax,%esi
  802001:	b8 20 00 00 00       	mov    $0x20,%eax
  802006:	29 e8                	sub    %ebp,%eax
  802008:	89 c1                	mov    %eax,%ecx
  80200a:	d3 ef                	shr    %cl,%edi
  80200c:	89 e9                	mov    %ebp,%ecx
  80200e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802012:	8b 3c 24             	mov    (%esp),%edi
  802015:	09 74 24 08          	or     %esi,0x8(%esp)
  802019:	89 d6                	mov    %edx,%esi
  80201b:	d3 e7                	shl    %cl,%edi
  80201d:	89 c1                	mov    %eax,%ecx
  80201f:	89 3c 24             	mov    %edi,(%esp)
  802022:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802026:	d3 ee                	shr    %cl,%esi
  802028:	89 e9                	mov    %ebp,%ecx
  80202a:	d3 e2                	shl    %cl,%edx
  80202c:	89 c1                	mov    %eax,%ecx
  80202e:	d3 ef                	shr    %cl,%edi
  802030:	09 d7                	or     %edx,%edi
  802032:	89 f2                	mov    %esi,%edx
  802034:	89 f8                	mov    %edi,%eax
  802036:	f7 74 24 08          	divl   0x8(%esp)
  80203a:	89 d6                	mov    %edx,%esi
  80203c:	89 c7                	mov    %eax,%edi
  80203e:	f7 24 24             	mull   (%esp)
  802041:	39 d6                	cmp    %edx,%esi
  802043:	89 14 24             	mov    %edx,(%esp)
  802046:	72 30                	jb     802078 <__udivdi3+0x118>
  802048:	8b 54 24 04          	mov    0x4(%esp),%edx
  80204c:	89 e9                	mov    %ebp,%ecx
  80204e:	d3 e2                	shl    %cl,%edx
  802050:	39 c2                	cmp    %eax,%edx
  802052:	73 05                	jae    802059 <__udivdi3+0xf9>
  802054:	3b 34 24             	cmp    (%esp),%esi
  802057:	74 1f                	je     802078 <__udivdi3+0x118>
  802059:	89 f8                	mov    %edi,%eax
  80205b:	31 d2                	xor    %edx,%edx
  80205d:	e9 7a ff ff ff       	jmp    801fdc <__udivdi3+0x7c>
  802062:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802068:	31 d2                	xor    %edx,%edx
  80206a:	b8 01 00 00 00       	mov    $0x1,%eax
  80206f:	e9 68 ff ff ff       	jmp    801fdc <__udivdi3+0x7c>
  802074:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802078:	8d 47 ff             	lea    -0x1(%edi),%eax
  80207b:	31 d2                	xor    %edx,%edx
  80207d:	83 c4 0c             	add    $0xc,%esp
  802080:	5e                   	pop    %esi
  802081:	5f                   	pop    %edi
  802082:	5d                   	pop    %ebp
  802083:	c3                   	ret    
  802084:	66 90                	xchg   %ax,%ax
  802086:	66 90                	xchg   %ax,%ax
  802088:	66 90                	xchg   %ax,%ax
  80208a:	66 90                	xchg   %ax,%ax
  80208c:	66 90                	xchg   %ax,%ax
  80208e:	66 90                	xchg   %ax,%ax

00802090 <__umoddi3>:
  802090:	55                   	push   %ebp
  802091:	57                   	push   %edi
  802092:	56                   	push   %esi
  802093:	83 ec 14             	sub    $0x14,%esp
  802096:	8b 44 24 28          	mov    0x28(%esp),%eax
  80209a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80209e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8020a2:	89 c7                	mov    %eax,%edi
  8020a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020a8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8020ac:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8020b0:	89 34 24             	mov    %esi,(%esp)
  8020b3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020b7:	85 c0                	test   %eax,%eax
  8020b9:	89 c2                	mov    %eax,%edx
  8020bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8020bf:	75 17                	jne    8020d8 <__umoddi3+0x48>
  8020c1:	39 fe                	cmp    %edi,%esi
  8020c3:	76 4b                	jbe    802110 <__umoddi3+0x80>
  8020c5:	89 c8                	mov    %ecx,%eax
  8020c7:	89 fa                	mov    %edi,%edx
  8020c9:	f7 f6                	div    %esi
  8020cb:	89 d0                	mov    %edx,%eax
  8020cd:	31 d2                	xor    %edx,%edx
  8020cf:	83 c4 14             	add    $0x14,%esp
  8020d2:	5e                   	pop    %esi
  8020d3:	5f                   	pop    %edi
  8020d4:	5d                   	pop    %ebp
  8020d5:	c3                   	ret    
  8020d6:	66 90                	xchg   %ax,%ax
  8020d8:	39 f8                	cmp    %edi,%eax
  8020da:	77 54                	ja     802130 <__umoddi3+0xa0>
  8020dc:	0f bd e8             	bsr    %eax,%ebp
  8020df:	83 f5 1f             	xor    $0x1f,%ebp
  8020e2:	75 5c                	jne    802140 <__umoddi3+0xb0>
  8020e4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8020e8:	39 3c 24             	cmp    %edi,(%esp)
  8020eb:	0f 87 e7 00 00 00    	ja     8021d8 <__umoddi3+0x148>
  8020f1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8020f5:	29 f1                	sub    %esi,%ecx
  8020f7:	19 c7                	sbb    %eax,%edi
  8020f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020fd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802101:	8b 44 24 08          	mov    0x8(%esp),%eax
  802105:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802109:	83 c4 14             	add    $0x14,%esp
  80210c:	5e                   	pop    %esi
  80210d:	5f                   	pop    %edi
  80210e:	5d                   	pop    %ebp
  80210f:	c3                   	ret    
  802110:	85 f6                	test   %esi,%esi
  802112:	89 f5                	mov    %esi,%ebp
  802114:	75 0b                	jne    802121 <__umoddi3+0x91>
  802116:	b8 01 00 00 00       	mov    $0x1,%eax
  80211b:	31 d2                	xor    %edx,%edx
  80211d:	f7 f6                	div    %esi
  80211f:	89 c5                	mov    %eax,%ebp
  802121:	8b 44 24 04          	mov    0x4(%esp),%eax
  802125:	31 d2                	xor    %edx,%edx
  802127:	f7 f5                	div    %ebp
  802129:	89 c8                	mov    %ecx,%eax
  80212b:	f7 f5                	div    %ebp
  80212d:	eb 9c                	jmp    8020cb <__umoddi3+0x3b>
  80212f:	90                   	nop
  802130:	89 c8                	mov    %ecx,%eax
  802132:	89 fa                	mov    %edi,%edx
  802134:	83 c4 14             	add    $0x14,%esp
  802137:	5e                   	pop    %esi
  802138:	5f                   	pop    %edi
  802139:	5d                   	pop    %ebp
  80213a:	c3                   	ret    
  80213b:	90                   	nop
  80213c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802140:	8b 04 24             	mov    (%esp),%eax
  802143:	be 20 00 00 00       	mov    $0x20,%esi
  802148:	89 e9                	mov    %ebp,%ecx
  80214a:	29 ee                	sub    %ebp,%esi
  80214c:	d3 e2                	shl    %cl,%edx
  80214e:	89 f1                	mov    %esi,%ecx
  802150:	d3 e8                	shr    %cl,%eax
  802152:	89 e9                	mov    %ebp,%ecx
  802154:	89 44 24 04          	mov    %eax,0x4(%esp)
  802158:	8b 04 24             	mov    (%esp),%eax
  80215b:	09 54 24 04          	or     %edx,0x4(%esp)
  80215f:	89 fa                	mov    %edi,%edx
  802161:	d3 e0                	shl    %cl,%eax
  802163:	89 f1                	mov    %esi,%ecx
  802165:	89 44 24 08          	mov    %eax,0x8(%esp)
  802169:	8b 44 24 10          	mov    0x10(%esp),%eax
  80216d:	d3 ea                	shr    %cl,%edx
  80216f:	89 e9                	mov    %ebp,%ecx
  802171:	d3 e7                	shl    %cl,%edi
  802173:	89 f1                	mov    %esi,%ecx
  802175:	d3 e8                	shr    %cl,%eax
  802177:	89 e9                	mov    %ebp,%ecx
  802179:	09 f8                	or     %edi,%eax
  80217b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80217f:	f7 74 24 04          	divl   0x4(%esp)
  802183:	d3 e7                	shl    %cl,%edi
  802185:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802189:	89 d7                	mov    %edx,%edi
  80218b:	f7 64 24 08          	mull   0x8(%esp)
  80218f:	39 d7                	cmp    %edx,%edi
  802191:	89 c1                	mov    %eax,%ecx
  802193:	89 14 24             	mov    %edx,(%esp)
  802196:	72 2c                	jb     8021c4 <__umoddi3+0x134>
  802198:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80219c:	72 22                	jb     8021c0 <__umoddi3+0x130>
  80219e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8021a2:	29 c8                	sub    %ecx,%eax
  8021a4:	19 d7                	sbb    %edx,%edi
  8021a6:	89 e9                	mov    %ebp,%ecx
  8021a8:	89 fa                	mov    %edi,%edx
  8021aa:	d3 e8                	shr    %cl,%eax
  8021ac:	89 f1                	mov    %esi,%ecx
  8021ae:	d3 e2                	shl    %cl,%edx
  8021b0:	89 e9                	mov    %ebp,%ecx
  8021b2:	d3 ef                	shr    %cl,%edi
  8021b4:	09 d0                	or     %edx,%eax
  8021b6:	89 fa                	mov    %edi,%edx
  8021b8:	83 c4 14             	add    $0x14,%esp
  8021bb:	5e                   	pop    %esi
  8021bc:	5f                   	pop    %edi
  8021bd:	5d                   	pop    %ebp
  8021be:	c3                   	ret    
  8021bf:	90                   	nop
  8021c0:	39 d7                	cmp    %edx,%edi
  8021c2:	75 da                	jne    80219e <__umoddi3+0x10e>
  8021c4:	8b 14 24             	mov    (%esp),%edx
  8021c7:	89 c1                	mov    %eax,%ecx
  8021c9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8021cd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8021d1:	eb cb                	jmp    80219e <__umoddi3+0x10e>
  8021d3:	90                   	nop
  8021d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8021dc:	0f 82 0f ff ff ff    	jb     8020f1 <__umoddi3+0x61>
  8021e2:	e9 1a ff ff ff       	jmp    802101 <__umoddi3+0x71>
