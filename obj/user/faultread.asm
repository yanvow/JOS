
obj/user/faultread.debug:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
  cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  800039:	a1 00 00 00 00       	mov    0x0,%eax
  80003e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800042:	c7 04 24 a0 1f 80 00 	movl   $0x801fa0,(%esp)
  800049:	e8 06 01 00 00       	call   800154 <cprintf>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	56                   	push   %esi
  800054:	53                   	push   %ebx
  800055:	83 ec 10             	sub    $0x10,%esp
  800058:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005b:	8b 75 0c             	mov    0xc(%ebp),%esi
  // set thisenv to point at our Env structure in envs[].
  // LAB 3: Your code here.
  thisenv = envs + ENVX(sys_getenvid());
  80005e:	e8 f2 0a 00 00       	call   800b55 <sys_getenvid>
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800070:	a3 04 40 80 00       	mov    %eax,0x804004

  // save the name of the program so that panic() can use it
  if (argc > 0)
  800075:	85 db                	test   %ebx,%ebx
  800077:	7e 07                	jle    800080 <libmain+0x30>
    binaryname = argv[0];
  800079:	8b 06                	mov    (%esi),%eax
  80007b:	a3 00 30 80 00       	mov    %eax,0x803000

  // call user main routine
  umain(argc, argv);
  800080:	89 74 24 04          	mov    %esi,0x4(%esp)
  800084:	89 1c 24             	mov    %ebx,(%esp)
  800087:	e8 a7 ff ff ff       	call   800033 <umain>

  // exit gracefully
  exit();
  80008c:	e8 07 00 00 00       	call   800098 <exit>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	5b                   	pop    %ebx
  800095:	5e                   	pop    %esi
  800096:	5d                   	pop    %ebp
  800097:	c3                   	ret    

00800098 <exit>:
#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 18             	sub    $0x18,%esp
  close_all();
  80009e:	e8 32 0f 00 00       	call   800fd5 <close_all>
  sys_env_destroy(0);
  8000a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000aa:	e8 54 0a 00 00       	call   800b03 <sys_env_destroy>
}
  8000af:	c9                   	leave  
  8000b0:	c3                   	ret    

008000b1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b1:	55                   	push   %ebp
  8000b2:	89 e5                	mov    %esp,%ebp
  8000b4:	53                   	push   %ebx
  8000b5:	83 ec 14             	sub    $0x14,%esp
  8000b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  b->buf[b->idx++] = ch;
  8000bb:	8b 13                	mov    (%ebx),%edx
  8000bd:	8d 42 01             	lea    0x1(%edx),%eax
  8000c0:	89 03                	mov    %eax,(%ebx)
  8000c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
  if (b->idx == 256-1) {
  8000c9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ce:	75 19                	jne    8000e9 <putch+0x38>
    sys_cputs(b->buf, b->idx);
  8000d0:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000d7:	00 
  8000d8:	8d 43 08             	lea    0x8(%ebx),%eax
  8000db:	89 04 24             	mov    %eax,(%esp)
  8000de:	e8 e3 09 00 00       	call   800ac6 <sys_cputs>
    b->idx = 0;
  8000e3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  }
  b->cnt++;
  8000e9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000ed:	83 c4 14             	add    $0x14,%esp
  8000f0:	5b                   	pop    %ebx
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	81 ec 28 01 00 00    	sub    $0x128,%esp
  struct printbuf b;

  b.idx = 0;
  8000fc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800103:	00 00 00 
  b.cnt = 0;
  800106:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80010d:	00 00 00 
  vprintfmt((void*)putch, &b, fmt, ap);
  800110:	8b 45 0c             	mov    0xc(%ebp),%eax
  800113:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800117:	8b 45 08             	mov    0x8(%ebp),%eax
  80011a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80011e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800124:	89 44 24 04          	mov    %eax,0x4(%esp)
  800128:	c7 04 24 b1 00 80 00 	movl   $0x8000b1,(%esp)
  80012f:	e8 aa 01 00 00       	call   8002de <vprintfmt>
  sys_cputs(b.buf, b.idx);
  800134:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80013a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800144:	89 04 24             	mov    %eax,(%esp)
  800147:	e8 7a 09 00 00       	call   800ac6 <sys_cputs>

  return b.cnt;
}
  80014c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800152:	c9                   	leave  
  800153:	c3                   	ret    

00800154 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  80015a:	8d 45 0c             	lea    0xc(%ebp),%eax
  cnt = vcprintf(fmt, ap);
  80015d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800161:	8b 45 08             	mov    0x8(%ebp),%eax
  800164:	89 04 24             	mov    %eax,(%esp)
  800167:	e8 87 ff ff ff       	call   8000f3 <vcprintf>
  va_end(ap);

  return cnt;
}
  80016c:	c9                   	leave  
  80016d:	c3                   	ret    
  80016e:	66 90                	xchg   %ax,%ax

00800170 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
         unsigned long long num, unsigned base, int width, int padc)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 3c             	sub    $0x3c,%esp
  800179:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80017c:	89 d7                	mov    %edx,%edi
  80017e:	8b 45 08             	mov    0x8(%ebp),%eax
  800181:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800184:	8b 45 0c             	mov    0xc(%ebp),%eax
  800187:	89 c3                	mov    %eax,%ebx
  800189:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80018c:	8b 45 10             	mov    0x10(%ebp),%eax
  80018f:	8b 75 14             	mov    0x14(%ebp),%esi
  // first recursively print all preceding (more significant) digits
  if (num >= base)
  800192:	b9 00 00 00 00       	mov    $0x0,%ecx
  800197:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80019d:	39 d9                	cmp    %ebx,%ecx
  80019f:	72 05                	jb     8001a6 <printnum+0x36>
  8001a1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001a4:	77 69                	ja     80020f <printnum+0x9f>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8001a9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8001ad:	83 ee 01             	sub    $0x1,%esi
  8001b0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001bc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001c0:	89 c3                	mov    %eax,%ebx
  8001c2:	89 d6                	mov    %edx,%esi
  8001c4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001c7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8001ca:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001ce:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8001d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001d5:	89 04 24             	mov    %eax,(%esp)
  8001d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8001db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001df:	e8 2c 1b 00 00       	call   801d10 <__udivdi3>
  8001e4:	89 d9                	mov    %ebx,%ecx
  8001e6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8001ea:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001ee:	89 04 24             	mov    %eax,(%esp)
  8001f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001f5:	89 fa                	mov    %edi,%edx
  8001f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001fa:	e8 71 ff ff ff       	call   800170 <printnum>
  8001ff:	eb 1b                	jmp    80021c <printnum+0xac>
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
      putch(padc, putdat);
  800201:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800205:	8b 45 18             	mov    0x18(%ebp),%eax
  800208:	89 04 24             	mov    %eax,(%esp)
  80020b:	ff d3                	call   *%ebx
  80020d:	eb 03                	jmp    800212 <printnum+0xa2>
  80020f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  // first recursively print all preceding (more significant) digits
  if (num >= base)
    printnum(putch, putdat, num / base, base, width - 1, padc);
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
  800212:	83 ee 01             	sub    $0x1,%esi
  800215:	85 f6                	test   %esi,%esi
  800217:	7f e8                	jg     800201 <printnum+0x91>
  800219:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
      putch(padc, putdat);
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  80021c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800220:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800224:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800227:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80022a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800232:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800235:	89 04 24             	mov    %eax,(%esp)
  800238:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80023b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023f:	e8 fc 1b 00 00       	call   801e40 <__umoddi3>
  800244:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800248:	0f be 80 c8 1f 80 00 	movsbl 0x801fc8(%eax),%eax
  80024f:	89 04 24             	mov    %eax,(%esp)
  800252:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800255:	ff d0                	call   *%eax
}
  800257:	83 c4 3c             	add    $0x3c,%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  if (lflag >= 2)
  800262:	83 fa 01             	cmp    $0x1,%edx
  800265:	7e 0e                	jle    800275 <getuint+0x16>
    return va_arg(*ap, unsigned long long);
  800267:	8b 10                	mov    (%eax),%edx
  800269:	8d 4a 08             	lea    0x8(%edx),%ecx
  80026c:	89 08                	mov    %ecx,(%eax)
  80026e:	8b 02                	mov    (%edx),%eax
  800270:	8b 52 04             	mov    0x4(%edx),%edx
  800273:	eb 22                	jmp    800297 <getuint+0x38>
  else if (lflag)
  800275:	85 d2                	test   %edx,%edx
  800277:	74 10                	je     800289 <getuint+0x2a>
    return va_arg(*ap, unsigned long);
  800279:	8b 10                	mov    (%eax),%edx
  80027b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027e:	89 08                	mov    %ecx,(%eax)
  800280:	8b 02                	mov    (%edx),%eax
  800282:	ba 00 00 00 00       	mov    $0x0,%edx
  800287:	eb 0e                	jmp    800297 <getuint+0x38>
  else
    return va_arg(*ap, unsigned int);
  800289:	8b 10                	mov    (%eax),%edx
  80028b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028e:	89 08                	mov    %ecx,(%eax)
  800290:	8b 02                	mov    (%edx),%eax
  800292:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800297:	5d                   	pop    %ebp
  800298:	c3                   	ret    

00800299 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	8b 45 0c             	mov    0xc(%ebp),%eax
  b->cnt++;
  80029f:	83 40 08 01          	addl   $0x1,0x8(%eax)
  if (b->buf < b->ebuf)
  8002a3:	8b 10                	mov    (%eax),%edx
  8002a5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a8:	73 0a                	jae    8002b4 <sprintputch+0x1b>
    *b->buf++ = ch;
  8002aa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ad:	89 08                	mov    %ecx,(%eax)
  8002af:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b2:	88 02                	mov    %al,(%edx)
}
  8002b4:	5d                   	pop    %ebp
  8002b5:	c3                   	ret    

008002b6 <printfmt>:
  }
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
  8002b9:	83 ec 18             	sub    $0x18,%esp
  va_list ap;

  va_start(ap, fmt);
  8002bc:	8d 45 14             	lea    0x14(%ebp),%eax
  vprintfmt(putch, putdat, fmt, ap);
  8002bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d4:	89 04 24             	mov    %eax,(%esp)
  8002d7:	e8 02 00 00 00       	call   8002de <vprintfmt>
  va_end(ap);
}
  8002dc:	c9                   	leave  
  8002dd:	c3                   	ret    

008002de <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	57                   	push   %edi
  8002e2:	56                   	push   %esi
  8002e3:	53                   	push   %ebx
  8002e4:	83 ec 3c             	sub    $0x3c,%esp
  8002e7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002ed:	eb 14                	jmp    800303 <vprintfmt+0x25>
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
      if (ch == '\0')
  8002ef:	85 c0                	test   %eax,%eax
  8002f1:	0f 84 b3 03 00 00    	je     8006aa <vprintfmt+0x3cc>
        return;
      putch(ch, putdat);
  8002f7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002fb:	89 04 24             	mov    %eax,(%esp)
  8002fe:	ff 55 08             	call   *0x8(%ebp)
  unsigned long long num;
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
  800301:	89 f3                	mov    %esi,%ebx
  800303:	8d 73 01             	lea    0x1(%ebx),%esi
  800306:	0f b6 03             	movzbl (%ebx),%eax
  800309:	83 f8 25             	cmp    $0x25,%eax
  80030c:	75 e1                	jne    8002ef <vprintfmt+0x11>
  80030e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800312:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800319:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800320:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800327:	ba 00 00 00 00       	mov    $0x0,%edx
  80032c:	eb 1d                	jmp    80034b <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80032e:	89 de                	mov    %ebx,%esi

    // flag to pad on the right
    case '-':
      padc = '-';
  800330:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800334:	eb 15                	jmp    80034b <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  800336:	89 de                	mov    %ebx,%esi
      padc = '-';
      goto reswitch;

    // flag to pad with 0's instead of spaces
    case '0':
      padc = '0';
  800338:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80033c:	eb 0d                	jmp    80034b <vprintfmt+0x6d>
      altflag = 1;
      goto reswitch;

process_precision:
      if (width < 0)
        width = precision, precision = -1;
  80033e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800341:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800344:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80034b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80034e:	0f b6 0e             	movzbl (%esi),%ecx
  800351:	0f b6 c1             	movzbl %cl,%eax
  800354:	83 e9 23             	sub    $0x23,%ecx
  800357:	80 f9 55             	cmp    $0x55,%cl
  80035a:	0f 87 2a 03 00 00    	ja     80068a <vprintfmt+0x3ac>
  800360:	0f b6 c9             	movzbl %cl,%ecx
  800363:	ff 24 8d 00 21 80 00 	jmp    *0x802100(,%ecx,4)
  80036a:	89 de                	mov    %ebx,%esi
  80036c:	b9 00 00 00 00       	mov    $0x0,%ecx
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
        precision = precision * 10 + ch - '0';
  800371:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800374:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
        ch = *fmt;
  800378:	0f be 06             	movsbl (%esi),%eax
        if (ch < '0' || ch > '9')
  80037b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80037e:	83 fb 09             	cmp    $0x9,%ebx
  800381:	77 36                	ja     8003b9 <vprintfmt+0xdb>
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
  800383:	83 c6 01             	add    $0x1,%esi
        precision = precision * 10 + ch - '0';
        ch = *fmt;
        if (ch < '0' || ch > '9')
          break;
      }
  800386:	eb e9                	jmp    800371 <vprintfmt+0x93>
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
  800388:	8b 45 14             	mov    0x14(%ebp),%eax
  80038b:	8d 48 04             	lea    0x4(%eax),%ecx
  80038e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800391:	8b 00                	mov    (%eax),%eax
  800393:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  800396:	89 de                	mov    %ebx,%esi
      }
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
      goto process_precision;
  800398:	eb 22                	jmp    8003bc <vprintfmt+0xde>
  80039a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80039d:	85 c9                	test   %ecx,%ecx
  80039f:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a4:	0f 49 c1             	cmovns %ecx,%eax
  8003a7:	89 45 dc             	mov    %eax,-0x24(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8003aa:	89 de                	mov    %ebx,%esi
  8003ac:	eb 9d                	jmp    80034b <vprintfmt+0x6d>
  8003ae:	89 de                	mov    %ebx,%esi
      if (width < 0)
        width = 0;
      goto reswitch;

    case '#':
      altflag = 1;
  8003b0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
      goto reswitch;
  8003b7:	eb 92                	jmp    80034b <vprintfmt+0x6d>
  8003b9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

process_precision:
      if (width < 0)
  8003bc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8003c0:	79 89                	jns    80034b <vprintfmt+0x6d>
  8003c2:	e9 77 ff ff ff       	jmp    80033e <vprintfmt+0x60>
        width = precision, precision = -1;
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
  8003c7:	83 c2 01             	add    $0x1,%edx
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8003ca:	89 de                	mov    %ebx,%esi
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
      goto reswitch;
  8003cc:	e9 7a ff ff ff       	jmp    80034b <vprintfmt+0x6d>

    // character
    case 'c':
      putch(va_arg(ap, int), putdat);
  8003d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d4:	8d 50 04             	lea    0x4(%eax),%edx
  8003d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003da:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003de:	8b 00                	mov    (%eax),%eax
  8003e0:	89 04 24             	mov    %eax,(%esp)
  8003e3:	ff 55 08             	call   *0x8(%ebp)
      break;
  8003e6:	e9 18 ff ff ff       	jmp    800303 <vprintfmt+0x25>

    // error message
    case 'e':
      err = va_arg(ap, int);
  8003eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ee:	8d 50 04             	lea    0x4(%eax),%edx
  8003f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f4:	8b 00                	mov    (%eax),%eax
  8003f6:	99                   	cltd   
  8003f7:	31 d0                	xor    %edx,%eax
  8003f9:	29 d0                	sub    %edx,%eax
      if (err < 0)
        err = -err;
      if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003fb:	83 f8 0f             	cmp    $0xf,%eax
  8003fe:	7f 0b                	jg     80040b <vprintfmt+0x12d>
  800400:	8b 14 85 60 22 80 00 	mov    0x802260(,%eax,4),%edx
  800407:	85 d2                	test   %edx,%edx
  800409:	75 20                	jne    80042b <vprintfmt+0x14d>
        printfmt(putch, putdat, "error %d", err);
  80040b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80040f:	c7 44 24 08 e0 1f 80 	movl   $0x801fe0,0x8(%esp)
  800416:	00 
  800417:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80041b:	8b 45 08             	mov    0x8(%ebp),%eax
  80041e:	89 04 24             	mov    %eax,(%esp)
  800421:	e8 90 fe ff ff       	call   8002b6 <printfmt>
  800426:	e9 d8 fe ff ff       	jmp    800303 <vprintfmt+0x25>
      else
        printfmt(putch, putdat, "%s", p);
  80042b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80042f:	c7 44 24 08 e9 1f 80 	movl   $0x801fe9,0x8(%esp)
  800436:	00 
  800437:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80043b:	8b 45 08             	mov    0x8(%ebp),%eax
  80043e:	89 04 24             	mov    %eax,(%esp)
  800441:	e8 70 fe ff ff       	call   8002b6 <printfmt>
  800446:	e9 b8 fe ff ff       	jmp    800303 <vprintfmt+0x25>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80044b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80044e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800451:	89 45 d0             	mov    %eax,-0x30(%ebp)
        printfmt(putch, putdat, "%s", p);
      break;

    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
  800454:	8b 45 14             	mov    0x14(%ebp),%eax
  800457:	8d 50 04             	lea    0x4(%eax),%edx
  80045a:	89 55 14             	mov    %edx,0x14(%ebp)
  80045d:	8b 30                	mov    (%eax),%esi
        p = "(null)";
  80045f:	85 f6                	test   %esi,%esi
  800461:	b8 d9 1f 80 00       	mov    $0x801fd9,%eax
  800466:	0f 44 f0             	cmove  %eax,%esi
      if (width > 0 && padc != '-')
  800469:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80046d:	0f 84 97 00 00 00    	je     80050a <vprintfmt+0x22c>
  800473:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800477:	0f 8e 9b 00 00 00    	jle    800518 <vprintfmt+0x23a>
        for (width -= strnlen(p, precision); width > 0; width--)
  80047d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800481:	89 34 24             	mov    %esi,(%esp)
  800484:	e8 cf 02 00 00       	call   800758 <strnlen>
  800489:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80048c:	29 c2                	sub    %eax,%edx
  80048e:	89 55 d0             	mov    %edx,-0x30(%ebp)
          putch(padc, putdat);
  800491:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800495:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800498:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80049b:	8b 75 08             	mov    0x8(%ebp),%esi
  80049e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004a1:	89 d3                	mov    %edx,%ebx
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
  8004a3:	eb 0f                	jmp    8004b4 <vprintfmt+0x1d6>
          putch(padc, putdat);
  8004a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004ac:	89 04 24             	mov    %eax,(%esp)
  8004af:	ff d6                	call   *%esi
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
  8004b1:	83 eb 01             	sub    $0x1,%ebx
  8004b4:	85 db                	test   %ebx,%ebx
  8004b6:	7f ed                	jg     8004a5 <vprintfmt+0x1c7>
  8004b8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004bb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004be:	85 d2                	test   %edx,%edx
  8004c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c5:	0f 49 c2             	cmovns %edx,%eax
  8004c8:	29 c2                	sub    %eax,%edx
  8004ca:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8004cd:	89 d7                	mov    %edx,%edi
  8004cf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8004d2:	eb 50                	jmp    800524 <vprintfmt+0x246>
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
  8004d4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d8:	74 1e                	je     8004f8 <vprintfmt+0x21a>
  8004da:	0f be d2             	movsbl %dl,%edx
  8004dd:	83 ea 20             	sub    $0x20,%edx
  8004e0:	83 fa 5e             	cmp    $0x5e,%edx
  8004e3:	76 13                	jbe    8004f8 <vprintfmt+0x21a>
          putch('?', putdat);
  8004e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ec:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004f3:	ff 55 08             	call   *0x8(%ebp)
  8004f6:	eb 0d                	jmp    800505 <vprintfmt+0x227>
        else
          putch(ch, putdat);
  8004f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004fb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004ff:	89 04 24             	mov    %eax,(%esp)
  800502:	ff 55 08             	call   *0x8(%ebp)
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800505:	83 ef 01             	sub    $0x1,%edi
  800508:	eb 1a                	jmp    800524 <vprintfmt+0x246>
  80050a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80050d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800510:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800513:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800516:	eb 0c                	jmp    800524 <vprintfmt+0x246>
  800518:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80051b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80051e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800521:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800524:	83 c6 01             	add    $0x1,%esi
  800527:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80052b:	0f be c2             	movsbl %dl,%eax
  80052e:	85 c0                	test   %eax,%eax
  800530:	74 27                	je     800559 <vprintfmt+0x27b>
  800532:	85 db                	test   %ebx,%ebx
  800534:	78 9e                	js     8004d4 <vprintfmt+0x1f6>
  800536:	83 eb 01             	sub    $0x1,%ebx
  800539:	79 99                	jns    8004d4 <vprintfmt+0x1f6>
  80053b:	89 f8                	mov    %edi,%eax
  80053d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800540:	8b 75 08             	mov    0x8(%ebp),%esi
  800543:	89 c3                	mov    %eax,%ebx
  800545:	eb 1a                	jmp    800561 <vprintfmt+0x283>
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
        putch(' ', putdat);
  800547:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80054b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800552:	ff d6                	call   *%esi
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
  800554:	83 eb 01             	sub    $0x1,%ebx
  800557:	eb 08                	jmp    800561 <vprintfmt+0x283>
  800559:	89 fb                	mov    %edi,%ebx
  80055b:	8b 75 08             	mov    0x8(%ebp),%esi
  80055e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800561:	85 db                	test   %ebx,%ebx
  800563:	7f e2                	jg     800547 <vprintfmt+0x269>
  800565:	89 75 08             	mov    %esi,0x8(%ebp)
  800568:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80056b:	e9 93 fd ff ff       	jmp    800303 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  if (lflag >= 2)
  800570:	83 fa 01             	cmp    $0x1,%edx
  800573:	7e 16                	jle    80058b <vprintfmt+0x2ad>
    return va_arg(*ap, long long);
  800575:	8b 45 14             	mov    0x14(%ebp),%eax
  800578:	8d 50 08             	lea    0x8(%eax),%edx
  80057b:	89 55 14             	mov    %edx,0x14(%ebp)
  80057e:	8b 50 04             	mov    0x4(%eax),%edx
  800581:	8b 00                	mov    (%eax),%eax
  800583:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800586:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800589:	eb 32                	jmp    8005bd <vprintfmt+0x2df>
  else if (lflag)
  80058b:	85 d2                	test   %edx,%edx
  80058d:	74 18                	je     8005a7 <vprintfmt+0x2c9>
    return va_arg(*ap, long);
  80058f:	8b 45 14             	mov    0x14(%ebp),%eax
  800592:	8d 50 04             	lea    0x4(%eax),%edx
  800595:	89 55 14             	mov    %edx,0x14(%ebp)
  800598:	8b 30                	mov    (%eax),%esi
  80059a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80059d:	89 f0                	mov    %esi,%eax
  80059f:	c1 f8 1f             	sar    $0x1f,%eax
  8005a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005a5:	eb 16                	jmp    8005bd <vprintfmt+0x2df>
  else
    return va_arg(*ap, int);
  8005a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005aa:	8d 50 04             	lea    0x4(%eax),%edx
  8005ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b0:	8b 30                	mov    (%eax),%esi
  8005b2:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005b5:	89 f0                	mov    %esi,%eax
  8005b7:	c1 f8 1f             	sar    $0x1f,%eax
  8005ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        putch(' ', putdat);
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
  8005bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      if ((long long)num < 0) {
        putch('-', putdat);
        num = -(long long)num;
      }
      base = 10;
  8005c3:	b9 0a 00 00 00       	mov    $0xa,%ecx
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
      if ((long long)num < 0) {
  8005c8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005cc:	0f 89 80 00 00 00    	jns    800652 <vprintfmt+0x374>
        putch('-', putdat);
  8005d2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005d6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005dd:	ff 55 08             	call   *0x8(%ebp)
        num = -(long long)num;
  8005e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e6:	f7 d8                	neg    %eax
  8005e8:	83 d2 00             	adc    $0x0,%edx
  8005eb:	f7 da                	neg    %edx
      }
      base = 10;
  8005ed:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005f2:	eb 5e                	jmp    800652 <vprintfmt+0x374>
      goto number;

    // unsigned decimal
    case 'u':
      num = getuint(&ap, lflag);
  8005f4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f7:	e8 63 fc ff ff       	call   80025f <getuint>
      base = 10;
  8005fc:	b9 0a 00 00 00       	mov    $0xa,%ecx
      goto number;
  800601:	eb 4f                	jmp    800652 <vprintfmt+0x374>

    // (unsigned) octal
    case 'o':
      num = getuint(&ap, lflag);
  800603:	8d 45 14             	lea    0x14(%ebp),%eax
  800606:	e8 54 fc ff ff       	call   80025f <getuint>
      base = 8;
  80060b:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800610:	eb 40                	jmp    800652 <vprintfmt+0x374>

    // pointer
    case 'p':
      putch('0', putdat);
  800612:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800616:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80061d:	ff 55 08             	call   *0x8(%ebp)
      putch('x', putdat);
  800620:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800624:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80062b:	ff 55 08             	call   *0x8(%ebp)
      num = (unsigned long long)
            (uintptr_t)va_arg(ap, void *);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8d 50 04             	lea    0x4(%eax),%edx
  800634:	89 55 14             	mov    %edx,0x14(%ebp)

    // pointer
    case 'p':
      putch('0', putdat);
      putch('x', putdat);
      num = (unsigned long long)
  800637:	8b 00                	mov    (%eax),%eax
  800639:	ba 00 00 00 00       	mov    $0x0,%edx
            (uintptr_t)va_arg(ap, void *);
      base = 16;
  80063e:	b9 10 00 00 00       	mov    $0x10,%ecx
      goto number;
  800643:	eb 0d                	jmp    800652 <vprintfmt+0x374>

    // (unsigned) hexadecimal
    case 'x':
      num = getuint(&ap, lflag);
  800645:	8d 45 14             	lea    0x14(%ebp),%eax
  800648:	e8 12 fc ff ff       	call   80025f <getuint>
      base = 16;
  80064d:	b9 10 00 00 00       	mov    $0x10,%ecx
number:
      printnum(putch, putdat, num, base, width, padc);
  800652:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800656:	89 74 24 10          	mov    %esi,0x10(%esp)
  80065a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80065d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800661:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800665:	89 04 24             	mov    %eax,(%esp)
  800668:	89 54 24 04          	mov    %edx,0x4(%esp)
  80066c:	89 fa                	mov    %edi,%edx
  80066e:	8b 45 08             	mov    0x8(%ebp),%eax
  800671:	e8 fa fa ff ff       	call   800170 <printnum>
      break;
  800676:	e9 88 fc ff ff       	jmp    800303 <vprintfmt+0x25>

    // escaped '%' character
    case '%':
      putch(ch, putdat);
  80067b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80067f:	89 04 24             	mov    %eax,(%esp)
  800682:	ff 55 08             	call   *0x8(%ebp)
      break;
  800685:	e9 79 fc ff ff       	jmp    800303 <vprintfmt+0x25>

    // unrecognized escape sequence - just print it literally
    default:
      putch('%', putdat);
  80068a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80068e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800695:	ff 55 08             	call   *0x8(%ebp)
      for (fmt--; fmt[-1] != '%'; fmt--)
  800698:	89 f3                	mov    %esi,%ebx
  80069a:	eb 03                	jmp    80069f <vprintfmt+0x3c1>
  80069c:	83 eb 01             	sub    $0x1,%ebx
  80069f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8006a3:	75 f7                	jne    80069c <vprintfmt+0x3be>
  8006a5:	e9 59 fc ff ff       	jmp    800303 <vprintfmt+0x25>
        /* do nothing */;
      break;
    }
  }
}
  8006aa:	83 c4 3c             	add    $0x3c,%esp
  8006ad:	5b                   	pop    %ebx
  8006ae:	5e                   	pop    %esi
  8006af:	5f                   	pop    %edi
  8006b0:	5d                   	pop    %ebp
  8006b1:	c3                   	ret    

008006b2 <vsnprintf>:
    *b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b2:	55                   	push   %ebp
  8006b3:	89 e5                	mov    %esp,%ebp
  8006b5:	83 ec 28             	sub    $0x28,%esp
  8006b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  struct sprintbuf b = { buf, buf+n-1, 0 };
  8006be:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  if (buf == NULL || n < 1)
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	74 30                	je     800703 <vsnprintf+0x51>
  8006d3:	85 d2                	test   %edx,%edx
  8006d5:	7e 2c                	jle    800703 <vsnprintf+0x51>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006de:	8b 45 10             	mov    0x10(%ebp),%eax
  8006e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ec:	c7 04 24 99 02 80 00 	movl   $0x800299,(%esp)
  8006f3:	e8 e6 fb ff ff       	call   8002de <vprintfmt>

  // null terminate the buffer
  *b.buf = '\0';
  8006f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006fb:	c6 00 00             	movb   $0x0,(%eax)

  return b.cnt;
  8006fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800701:	eb 05                	jmp    800708 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  struct sprintbuf b = { buf, buf+n-1, 0 };

  if (buf == NULL || n < 1)
    return -E_INVAL;
  800703:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

  // null terminate the buffer
  *b.buf = '\0';

  return b.cnt;
}
  800708:	c9                   	leave  
  800709:	c3                   	ret    

0080070a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800710:	8d 45 14             	lea    0x14(%ebp),%eax
  rc = vsnprintf(buf, n, fmt, ap);
  800713:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800717:	8b 45 10             	mov    0x10(%ebp),%eax
  80071a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80071e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800721:	89 44 24 04          	mov    %eax,0x4(%esp)
  800725:	8b 45 08             	mov    0x8(%ebp),%eax
  800728:	89 04 24             	mov    %eax,(%esp)
  80072b:	e8 82 ff ff ff       	call   8006b2 <vsnprintf>
  va_end(ap);

  return rc;
}
  800730:	c9                   	leave  
  800731:	c3                   	ret    
  800732:	66 90                	xchg   %ax,%ax
  800734:	66 90                	xchg   %ax,%ax
  800736:	66 90                	xchg   %ax,%ax
  800738:	66 90                	xchg   %ax,%ax
  80073a:	66 90                	xchg   %ax,%ax
  80073c:	66 90                	xchg   %ax,%ax
  80073e:	66 90                	xchg   %ax,%ax

00800740 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for (n = 0; *s != '\0'; s++)
  800746:	b8 00 00 00 00       	mov    $0x0,%eax
  80074b:	eb 03                	jmp    800750 <strlen+0x10>
    n++;
  80074d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
  int n;

  for (n = 0; *s != '\0'; s++)
  800750:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800754:	75 f7                	jne    80074d <strlen+0xd>
    n++;
  return n;
}
  800756:	5d                   	pop    %ebp
  800757:	c3                   	ret    

00800758 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075e:	8b 55 0c             	mov    0xc(%ebp),%edx
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800761:	b8 00 00 00 00       	mov    $0x0,%eax
  800766:	eb 03                	jmp    80076b <strnlen+0x13>
    n++;
  800768:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076b:	39 d0                	cmp    %edx,%eax
  80076d:	74 06                	je     800775 <strnlen+0x1d>
  80076f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800773:	75 f3                	jne    800768 <strnlen+0x10>
    n++;
  return n;
}
  800775:	5d                   	pop    %ebp
  800776:	c3                   	ret    

00800777 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	53                   	push   %ebx
  80077b:	8b 45 08             	mov    0x8(%ebp),%eax
  80077e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800781:	89 c2                	mov    %eax,%edx
  800783:	83 c2 01             	add    $0x1,%edx
  800786:	83 c1 01             	add    $0x1,%ecx
  800789:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80078d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800790:	84 db                	test   %bl,%bl
  800792:	75 ef                	jne    800783 <strcpy+0xc>
    /* do nothing */;
  return ret;
}
  800794:	5b                   	pop    %ebx
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	53                   	push   %ebx
  80079b:	83 ec 08             	sub    $0x8,%esp
  80079e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int len = strlen(dst);
  8007a1:	89 1c 24             	mov    %ebx,(%esp)
  8007a4:	e8 97 ff ff ff       	call   800740 <strlen>

  strcpy(dst + len, src);
  8007a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007b0:	01 d8                	add    %ebx,%eax
  8007b2:	89 04 24             	mov    %eax,(%esp)
  8007b5:	e8 bd ff ff ff       	call   800777 <strcpy>
  return dst;
}
  8007ba:	89 d8                	mov    %ebx,%eax
  8007bc:	83 c4 08             	add    $0x8,%esp
  8007bf:	5b                   	pop    %ebx
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	56                   	push   %esi
  8007c6:	53                   	push   %ebx
  8007c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007cd:	89 f3                	mov    %esi,%ebx
  8007cf:	03 5d 10             	add    0x10(%ebp),%ebx
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  8007d2:	89 f2                	mov    %esi,%edx
  8007d4:	eb 0f                	jmp    8007e5 <strncpy+0x23>
    *dst++ = *src;
  8007d6:	83 c2 01             	add    $0x1,%edx
  8007d9:	0f b6 01             	movzbl (%ecx),%eax
  8007dc:	88 42 ff             	mov    %al,-0x1(%edx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  8007df:	80 39 01             	cmpb   $0x1,(%ecx)
  8007e2:	83 d9 ff             	sbb    $0xffffffff,%ecx
{
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  8007e5:	39 da                	cmp    %ebx,%edx
  8007e7:	75 ed                	jne    8007d6 <strncpy+0x14>
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  }
  return ret;
}
  8007e9:	89 f0                	mov    %esi,%eax
  8007eb:	5b                   	pop    %ebx
  8007ec:	5e                   	pop    %esi
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	56                   	push   %esi
  8007f3:	53                   	push   %ebx
  8007f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007fd:	89 f0                	mov    %esi,%eax
  8007ff:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800803:	85 c9                	test   %ecx,%ecx
  800805:	75 0b                	jne    800812 <strlcpy+0x23>
  800807:	eb 1d                	jmp    800826 <strlcpy+0x37>
    while (--size > 0 && *src != '\0')
      *dst++ = *src++;
  800809:	83 c0 01             	add    $0x1,%eax
  80080c:	83 c2 01             	add    $0x1,%edx
  80080f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
    while (--size > 0 && *src != '\0')
  800812:	39 d8                	cmp    %ebx,%eax
  800814:	74 0b                	je     800821 <strlcpy+0x32>
  800816:	0f b6 0a             	movzbl (%edx),%ecx
  800819:	84 c9                	test   %cl,%cl
  80081b:	75 ec                	jne    800809 <strlcpy+0x1a>
  80081d:	89 c2                	mov    %eax,%edx
  80081f:	eb 02                	jmp    800823 <strlcpy+0x34>
  800821:	89 c2                	mov    %eax,%edx
      *dst++ = *src++;
    *dst = '\0';
  800823:	c6 02 00             	movb   $0x0,(%edx)
  }
  return dst - dst_in;
  800826:	29 f0                	sub    %esi,%eax
}
  800828:	5b                   	pop    %ebx
  800829:	5e                   	pop    %esi
  80082a:	5d                   	pop    %ebp
  80082b:	c3                   	ret    

0080082c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800832:	8b 55 0c             	mov    0xc(%ebp),%edx
  while (*p && *p == *q)
  800835:	eb 06                	jmp    80083d <strcmp+0x11>
    p++, q++;
  800837:	83 c1 01             	add    $0x1,%ecx
  80083a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
  while (*p && *p == *q)
  80083d:	0f b6 01             	movzbl (%ecx),%eax
  800840:	84 c0                	test   %al,%al
  800842:	74 04                	je     800848 <strcmp+0x1c>
  800844:	3a 02                	cmp    (%edx),%al
  800846:	74 ef                	je     800837 <strcmp+0xb>
    p++, q++;
  return (int)((unsigned char)*p - (unsigned char)*q);
  800848:	0f b6 c0             	movzbl %al,%eax
  80084b:	0f b6 12             	movzbl (%edx),%edx
  80084e:	29 d0                	sub    %edx,%eax
}
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	53                   	push   %ebx
  800856:	8b 45 08             	mov    0x8(%ebp),%eax
  800859:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085c:	89 c3                	mov    %eax,%ebx
  80085e:	03 5d 10             	add    0x10(%ebp),%ebx
  while (n > 0 && *p && *p == *q)
  800861:	eb 06                	jmp    800869 <strncmp+0x17>
    n--, p++, q++;
  800863:	83 c0 01             	add    $0x1,%eax
  800866:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
  800869:	39 d8                	cmp    %ebx,%eax
  80086b:	74 15                	je     800882 <strncmp+0x30>
  80086d:	0f b6 08             	movzbl (%eax),%ecx
  800870:	84 c9                	test   %cl,%cl
  800872:	74 04                	je     800878 <strncmp+0x26>
  800874:	3a 0a                	cmp    (%edx),%cl
  800876:	74 eb                	je     800863 <strncmp+0x11>
    n--, p++, q++;
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800878:	0f b6 00             	movzbl (%eax),%eax
  80087b:	0f b6 12             	movzbl (%edx),%edx
  80087e:	29 d0                	sub    %edx,%eax
  800880:	eb 05                	jmp    800887 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
    n--, p++, q++;
  if (n == 0)
    return 0;
  800882:	b8 00 00 00 00       	mov    $0x0,%eax
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
}
  800887:	5b                   	pop    %ebx
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
  800894:	eb 07                	jmp    80089d <strchr+0x13>
    if (*s == c)
  800896:	38 ca                	cmp    %cl,%dl
  800898:	74 0f                	je     8008a9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  for (; *s; s++)
  80089a:	83 c0 01             	add    $0x1,%eax
  80089d:	0f b6 10             	movzbl (%eax),%edx
  8008a0:	84 d2                	test   %dl,%dl
  8008a2:	75 f2                	jne    800896 <strchr+0xc>
    if (*s == c)
      return (char*)s;
  return 0;
  8008a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
  8008b5:	eb 07                	jmp    8008be <strfind+0x13>
    if (*s == c)
  8008b7:	38 ca                	cmp    %cl,%dl
  8008b9:	74 0a                	je     8008c5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  for (; *s; s++)
  8008bb:	83 c0 01             	add    $0x1,%eax
  8008be:	0f b6 10             	movzbl (%eax),%edx
  8008c1:	84 d2                	test   %dl,%dl
  8008c3:	75 f2                	jne    8008b7 <strfind+0xc>
    if (*s == c)
      break;
  return (char*)s;
}
  8008c5:	5d                   	pop    %ebp
  8008c6:	c3                   	ret    

008008c7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	57                   	push   %edi
  8008cb:	56                   	push   %esi
  8008cc:	53                   	push   %ebx
  8008cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *p;

  if (n == 0)
  8008d3:	85 c9                	test   %ecx,%ecx
  8008d5:	74 36                	je     80090d <memset+0x46>
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
  8008d7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008dd:	75 28                	jne    800907 <memset+0x40>
  8008df:	f6 c1 03             	test   $0x3,%cl
  8008e2:	75 23                	jne    800907 <memset+0x40>
    c &= 0xFF;
  8008e4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
    c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e8:	89 d3                	mov    %edx,%ebx
  8008ea:	c1 e3 08             	shl    $0x8,%ebx
  8008ed:	89 d6                	mov    %edx,%esi
  8008ef:	c1 e6 18             	shl    $0x18,%esi
  8008f2:	89 d0                	mov    %edx,%eax
  8008f4:	c1 e0 10             	shl    $0x10,%eax
  8008f7:	09 f0                	or     %esi,%eax
  8008f9:	09 c2                	or     %eax,%edx
  8008fb:	89 d0                	mov    %edx,%eax
  8008fd:	09 d8                	or     %ebx,%eax
    asm volatile ("cld; rep stosl\n"
                  :: "D" (v), "a" (c), "c" (n/4)
  8008ff:	c1 e9 02             	shr    $0x2,%ecx
  if (n == 0)
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
    c &= 0xFF;
    c = (c<<24)|(c<<16)|(c<<8)|c;
    asm volatile ("cld; rep stosl\n"
  800902:	fc                   	cld    
  800903:	f3 ab                	rep stos %eax,%es:(%edi)
  800905:	eb 06                	jmp    80090d <memset+0x46>
                  :: "D" (v), "a" (c), "c" (n/4)
                  : "cc", "memory");
  } else
    asm volatile ("cld; rep stosb\n"
  800907:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090a:	fc                   	cld    
  80090b:	f3 aa                	rep stos %al,%es:(%edi)
                  :: "D" (v), "a" (c), "c" (n)
                  : "cc", "memory");
  return v;
}
  80090d:	89 f8                	mov    %edi,%eax
  80090f:	5b                   	pop    %ebx
  800910:	5e                   	pop    %esi
  800911:	5f                   	pop    %edi
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	57                   	push   %edi
  800918:	56                   	push   %esi
  800919:	8b 45 08             	mov    0x8(%ebp),%eax
  80091c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800922:	39 c6                	cmp    %eax,%esi
  800924:	73 35                	jae    80095b <memmove+0x47>
  800926:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800929:	39 d0                	cmp    %edx,%eax
  80092b:	73 2e                	jae    80095b <memmove+0x47>
    s += n;
    d += n;
  80092d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800930:	89 d6                	mov    %edx,%esi
  800932:	09 fe                	or     %edi,%esi
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800934:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80093a:	75 13                	jne    80094f <memmove+0x3b>
  80093c:	f6 c1 03             	test   $0x3,%cl
  80093f:	75 0e                	jne    80094f <memmove+0x3b>
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800941:	83 ef 04             	sub    $0x4,%edi
  800944:	8d 72 fc             	lea    -0x4(%edx),%esi
  800947:	c1 e9 02             	shr    $0x2,%ecx
  d = dst;
  if (s < d && s + n > d) {
    s += n;
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
  80094a:	fd                   	std    
  80094b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094d:	eb 09                	jmp    800958 <memmove+0x44>
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80094f:	83 ef 01             	sub    $0x1,%edi
  800952:	8d 72 ff             	lea    -0x1(%edx),%esi
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
  800955:	fd                   	std    
  800956:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  800958:	fc                   	cld    
  800959:	eb 1d                	jmp    800978 <memmove+0x64>
  80095b:	89 f2                	mov    %esi,%edx
  80095d:	09 c2                	or     %eax,%edx
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095f:	f6 c2 03             	test   $0x3,%dl
  800962:	75 0f                	jne    800973 <memmove+0x5f>
  800964:	f6 c1 03             	test   $0x3,%cl
  800967:	75 0a                	jne    800973 <memmove+0x5f>
      asm volatile ("cld; rep movsl\n"
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800969:	c1 e9 02             	shr    $0x2,%ecx
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("cld; rep movsl\n"
  80096c:	89 c7                	mov    %eax,%edi
  80096e:	fc                   	cld    
  80096f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800971:	eb 05                	jmp    800978 <memmove+0x64>
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("cld; rep movsb\n"
  800973:	89 c7                	mov    %eax,%edi
  800975:	fc                   	cld    
  800976:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d), "S" (s), "c" (n) : "cc", "memory");
  }
  return dst;
}
  800978:	5e                   	pop    %esi
  800979:	5f                   	pop    %edi
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
  800982:	8b 45 10             	mov    0x10(%ebp),%eax
  800985:	89 44 24 08          	mov    %eax,0x8(%esp)
  800989:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	89 04 24             	mov    %eax,(%esp)
  800996:	e8 79 ff ff ff       	call   800914 <memmove>
}
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    

0080099d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	56                   	push   %esi
  8009a1:	53                   	push   %ebx
  8009a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8009a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a8:	89 d6                	mov    %edx,%esi
  8009aa:	03 75 10             	add    0x10(%ebp),%esi
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
  8009ad:	eb 1a                	jmp    8009c9 <memcmp+0x2c>
    if (*s1 != *s2)
  8009af:	0f b6 02             	movzbl (%edx),%eax
  8009b2:	0f b6 19             	movzbl (%ecx),%ebx
  8009b5:	38 d8                	cmp    %bl,%al
  8009b7:	74 0a                	je     8009c3 <memcmp+0x26>
      return (int)*s1 - (int)*s2;
  8009b9:	0f b6 c0             	movzbl %al,%eax
  8009bc:	0f b6 db             	movzbl %bl,%ebx
  8009bf:	29 d8                	sub    %ebx,%eax
  8009c1:	eb 0f                	jmp    8009d2 <memcmp+0x35>
    s1++, s2++;
  8009c3:	83 c2 01             	add    $0x1,%edx
  8009c6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
  8009c9:	39 f2                	cmp    %esi,%edx
  8009cb:	75 e2                	jne    8009af <memcmp+0x12>
    if (*s1 != *s2)
      return (int)*s1 - (int)*s2;
    s1++, s2++;
  }

  return 0;
  8009cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d2:	5b                   	pop    %ebx
  8009d3:	5e                   	pop    %esi
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  const void *ends = (const char*)s + n;
  8009df:	89 c2                	mov    %eax,%edx
  8009e1:	03 55 10             	add    0x10(%ebp),%edx

  for (; s < ends; s++)
  8009e4:	eb 07                	jmp    8009ed <memfind+0x17>
    if (*(const unsigned char*)s == (unsigned char)c)
  8009e6:	38 08                	cmp    %cl,(%eax)
  8009e8:	74 07                	je     8009f1 <memfind+0x1b>
void *
memfind(const void *s, int c, size_t n)
{
  const void *ends = (const char*)s + n;

  for (; s < ends; s++)
  8009ea:	83 c0 01             	add    $0x1,%eax
  8009ed:	39 d0                	cmp    %edx,%eax
  8009ef:	72 f5                	jb     8009e6 <memfind+0x10>
    if (*(const unsigned char*)s == (unsigned char)c)
      break;
  return (void*)s;
}
  8009f1:	5d                   	pop    %ebp
  8009f2:	c3                   	ret    

008009f3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	57                   	push   %edi
  8009f7:	56                   	push   %esi
  8009f8:	53                   	push   %ebx
  8009f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8009fc:	8b 45 10             	mov    0x10(%ebp),%eax
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  8009ff:	eb 03                	jmp    800a04 <strtol+0x11>
    s++;
  800a01:	83 c2 01             	add    $0x1,%edx
{
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800a04:	0f b6 0a             	movzbl (%edx),%ecx
  800a07:	80 f9 09             	cmp    $0x9,%cl
  800a0a:	74 f5                	je     800a01 <strtol+0xe>
  800a0c:	80 f9 20             	cmp    $0x20,%cl
  800a0f:	74 f0                	je     800a01 <strtol+0xe>
    s++;

  // plus/minus sign
  if (*s == '+')
  800a11:	80 f9 2b             	cmp    $0x2b,%cl
  800a14:	75 0a                	jne    800a20 <strtol+0x2d>
    s++;
  800a16:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
  int neg = 0;
  800a19:	bf 00 00 00 00       	mov    $0x0,%edi
  800a1e:	eb 11                	jmp    800a31 <strtol+0x3e>
  800a20:	bf 00 00 00 00       	mov    $0x0,%edi
    s++;

  // plus/minus sign
  if (*s == '+')
    s++;
  else if (*s == '-')
  800a25:	80 f9 2d             	cmp    $0x2d,%cl
  800a28:	75 07                	jne    800a31 <strtol+0x3e>
    s++, neg = 1;
  800a2a:	8d 52 01             	lea    0x1(%edx),%edx
  800a2d:	66 bf 01 00          	mov    $0x1,%di

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a31:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800a36:	75 15                	jne    800a4d <strtol+0x5a>
  800a38:	80 3a 30             	cmpb   $0x30,(%edx)
  800a3b:	75 10                	jne    800a4d <strtol+0x5a>
  800a3d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a41:	75 0a                	jne    800a4d <strtol+0x5a>
    s += 2, base = 16;
  800a43:	83 c2 02             	add    $0x2,%edx
  800a46:	b8 10 00 00 00       	mov    $0x10,%eax
  800a4b:	eb 10                	jmp    800a5d <strtol+0x6a>
  else if (base == 0 && s[0] == '0')
  800a4d:	85 c0                	test   %eax,%eax
  800a4f:	75 0c                	jne    800a5d <strtol+0x6a>
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800a51:	b0 0a                	mov    $0xa,%al
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
  800a53:	80 3a 30             	cmpb   $0x30,(%edx)
  800a56:	75 05                	jne    800a5d <strtol+0x6a>
    s++, base = 8;
  800a58:	83 c2 01             	add    $0x1,%edx
  800a5b:	b0 08                	mov    $0x8,%al
  else if (base == 0)
    base = 10;
  800a5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a62:	89 45 10             	mov    %eax,0x10(%ebp)

  // digits
  while (1) {
    int dig;

    if (*s >= '0' && *s <= '9')
  800a65:	0f b6 0a             	movzbl (%edx),%ecx
  800a68:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800a6b:	89 f0                	mov    %esi,%eax
  800a6d:	3c 09                	cmp    $0x9,%al
  800a6f:	77 08                	ja     800a79 <strtol+0x86>
      dig = *s - '0';
  800a71:	0f be c9             	movsbl %cl,%ecx
  800a74:	83 e9 30             	sub    $0x30,%ecx
  800a77:	eb 20                	jmp    800a99 <strtol+0xa6>
    else if (*s >= 'a' && *s <= 'z')
  800a79:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800a7c:	89 f0                	mov    %esi,%eax
  800a7e:	3c 19                	cmp    $0x19,%al
  800a80:	77 08                	ja     800a8a <strtol+0x97>
      dig = *s - 'a' + 10;
  800a82:	0f be c9             	movsbl %cl,%ecx
  800a85:	83 e9 57             	sub    $0x57,%ecx
  800a88:	eb 0f                	jmp    800a99 <strtol+0xa6>
    else if (*s >= 'A' && *s <= 'Z')
  800a8a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800a8d:	89 f0                	mov    %esi,%eax
  800a8f:	3c 19                	cmp    $0x19,%al
  800a91:	77 16                	ja     800aa9 <strtol+0xb6>
      dig = *s - 'A' + 10;
  800a93:	0f be c9             	movsbl %cl,%ecx
  800a96:	83 e9 37             	sub    $0x37,%ecx
    else
      break;
    if (dig >= base)
  800a99:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800a9c:	7d 0f                	jge    800aad <strtol+0xba>
      break;
    s++, val = (val * base) + dig;
  800a9e:	83 c2 01             	add    $0x1,%edx
  800aa1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800aa5:	01 cb                	add    %ecx,%ebx
    // we don't properly detect overflow!
  }
  800aa7:	eb bc                	jmp    800a65 <strtol+0x72>
  800aa9:	89 d8                	mov    %ebx,%eax
  800aab:	eb 02                	jmp    800aaf <strtol+0xbc>
  800aad:	89 d8                	mov    %ebx,%eax

  if (endptr)
  800aaf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab3:	74 05                	je     800aba <strtol+0xc7>
    *endptr = (char*)s;
  800ab5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab8:	89 16                	mov    %edx,(%esi)
  return neg ? -val : val;
  800aba:	f7 d8                	neg    %eax
  800abc:	85 ff                	test   %edi,%edi
  800abe:	0f 44 c3             	cmove  %ebx,%eax
}
  800ac1:	5b                   	pop    %ebx
  800ac2:	5e                   	pop    %esi
  800ac3:	5f                   	pop    %edi
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    

00800ac6 <sys_cputs>:
  return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	57                   	push   %edi
  800aca:	56                   	push   %esi
  800acb:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800acc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad7:	89 c3                	mov    %eax,%ebx
  800ad9:	89 c7                	mov    %eax,%edi
  800adb:	89 c6                	mov    %eax,%esi
  800add:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
  syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800adf:	5b                   	pop    %ebx
  800ae0:	5e                   	pop    %esi
  800ae1:	5f                   	pop    %edi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	57                   	push   %edi
  800ae8:	56                   	push   %esi
  800ae9:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800aea:	ba 00 00 00 00       	mov    $0x0,%edx
  800aef:	b8 01 00 00 00       	mov    $0x1,%eax
  800af4:	89 d1                	mov    %edx,%ecx
  800af6:	89 d3                	mov    %edx,%ebx
  800af8:	89 d7                	mov    %edx,%edi
  800afa:	89 d6                	mov    %edx,%esi
  800afc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800afe:	5b                   	pop    %ebx
  800aff:	5e                   	pop    %esi
  800b00:	5f                   	pop    %edi
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	57                   	push   %edi
  800b07:	56                   	push   %esi
  800b08:	53                   	push   %ebx
  800b09:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800b0c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b11:	b8 03 00 00 00       	mov    $0x3,%eax
  800b16:	8b 55 08             	mov    0x8(%ebp),%edx
  800b19:	89 cb                	mov    %ecx,%ebx
  800b1b:	89 cf                	mov    %ecx,%edi
  800b1d:	89 ce                	mov    %ecx,%esi
  800b1f:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800b21:	85 c0                	test   %eax,%eax
  800b23:	7e 28                	jle    800b4d <sys_env_destroy+0x4a>
    panic("syscall %d returned %d (> 0)", num, ret);
  800b25:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b29:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b30:	00 
  800b31:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800b38:	00 
  800b39:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b40:	00 
  800b41:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800b48:	e8 09 10 00 00       	call   801b56 <_panic>

int
sys_env_destroy(envid_t envid)
{
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b4d:	83 c4 2c             	add    $0x2c,%esp
  800b50:	5b                   	pop    %ebx
  800b51:	5e                   	pop    %esi
  800b52:	5f                   	pop    %edi
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	57                   	push   %edi
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800b5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b60:	b8 02 00 00 00       	mov    $0x2,%eax
  800b65:	89 d1                	mov    %edx,%ecx
  800b67:	89 d3                	mov    %edx,%ebx
  800b69:	89 d7                	mov    %edx,%edi
  800b6b:	89 d6                	mov    %edx,%esi
  800b6d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5f                   	pop    %edi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <sys_yield>:

void
sys_yield(void)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	57                   	push   %edi
  800b78:	56                   	push   %esi
  800b79:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800b7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b84:	89 d1                	mov    %edx,%ecx
  800b86:	89 d3                	mov    %edx,%ebx
  800b88:	89 d7                	mov    %edx,%edi
  800b8a:	89 d6                	mov    %edx,%esi
  800b8c:	cd 30                	int    $0x30

void
sys_yield(void)
{
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b8e:	5b                   	pop    %ebx
  800b8f:	5e                   	pop    %esi
  800b90:	5f                   	pop    %edi
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    

00800b93 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	57                   	push   %edi
  800b97:	56                   	push   %esi
  800b98:	53                   	push   %ebx
  800b99:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800b9c:	be 00 00 00 00       	mov    $0x0,%esi
  800ba1:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800baf:	89 f7                	mov    %esi,%edi
  800bb1:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800bb3:	85 c0                	test   %eax,%eax
  800bb5:	7e 28                	jle    800bdf <sys_page_alloc+0x4c>
    panic("syscall %d returned %d (> 0)", num, ret);
  800bb7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bbb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bc2:	00 
  800bc3:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800bca:	00 
  800bcb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bd2:	00 
  800bd3:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800bda:	e8 77 0f 00 00       	call   801b56 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  return syscall(SYS_page_alloc, 1, envid, (uint32_t)va, perm, 0, 0);
}
  800bdf:	83 c4 2c             	add    $0x2c,%esp
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5f                   	pop    %edi
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    

00800be7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	57                   	push   %edi
  800beb:	56                   	push   %esi
  800bec:	53                   	push   %ebx
  800bed:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800bf0:	b8 05 00 00 00       	mov    $0x5,%eax
  800bf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bfe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c01:	8b 75 18             	mov    0x18(%ebp),%esi
  800c04:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800c06:	85 c0                	test   %eax,%eax
  800c08:	7e 28                	jle    800c32 <sys_page_map+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800c0a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c0e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c15:	00 
  800c16:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800c1d:	00 
  800c1e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c25:	00 
  800c26:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800c2d:	e8 24 0f 00 00       	call   801b56 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  return syscall(SYS_page_map, 1, srcenv, (uint32_t)srcva, dstenv, (uint32_t)dstva, perm);
}
  800c32:	83 c4 2c             	add    $0x2c,%esp
  800c35:	5b                   	pop    %ebx
  800c36:	5e                   	pop    %esi
  800c37:	5f                   	pop    %edi
  800c38:	5d                   	pop    %ebp
  800c39:	c3                   	ret    

00800c3a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	57                   	push   %edi
  800c3e:	56                   	push   %esi
  800c3f:	53                   	push   %ebx
  800c40:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800c43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c48:	b8 06 00 00 00       	mov    $0x6,%eax
  800c4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c50:	8b 55 08             	mov    0x8(%ebp),%edx
  800c53:	89 df                	mov    %ebx,%edi
  800c55:	89 de                	mov    %ebx,%esi
  800c57:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800c59:	85 c0                	test   %eax,%eax
  800c5b:	7e 28                	jle    800c85 <sys_page_unmap+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800c5d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c61:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c68:	00 
  800c69:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800c70:	00 
  800c71:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c78:	00 
  800c79:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800c80:	e8 d1 0e 00 00       	call   801b56 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
  return syscall(SYS_page_unmap, 1, envid, (uint32_t)va, 0, 0, 0);
}
  800c85:	83 c4 2c             	add    $0x2c,%esp
  800c88:	5b                   	pop    %ebx
  800c89:	5e                   	pop    %esi
  800c8a:	5f                   	pop    %edi
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    

00800c8d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	57                   	push   %edi
  800c91:	56                   	push   %esi
  800c92:	53                   	push   %ebx
  800c93:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800c96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9b:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca6:	89 df                	mov    %ebx,%edi
  800ca8:	89 de                	mov    %ebx,%esi
  800caa:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800cac:	85 c0                	test   %eax,%eax
  800cae:	7e 28                	jle    800cd8 <sys_env_set_status+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800cb0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cb4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800cbb:	00 
  800cbc:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800cc3:	00 
  800cc4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ccb:	00 
  800ccc:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800cd3:	e8 7e 0e 00 00       	call   801b56 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cd8:	83 c4 2c             	add    $0x2c,%esp
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	57                   	push   %edi
  800ce4:	56                   	push   %esi
  800ce5:	53                   	push   %ebx
  800ce6:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800ce9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cee:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf9:	89 df                	mov    %ebx,%edi
  800cfb:	89 de                	mov    %ebx,%esi
  800cfd:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800cff:	85 c0                	test   %eax,%eax
  800d01:	7e 28                	jle    800d2b <sys_env_set_trapframe+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800d03:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d07:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d0e:	00 
  800d0f:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800d16:	00 
  800d17:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d1e:	00 
  800d1f:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800d26:	e8 2b 0e 00 00       	call   801b56 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t)tf, 0, 0, 0);
}
  800d2b:	83 c4 2c             	add    $0x2c,%esp
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    

00800d33 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	57                   	push   %edi
  800d37:	56                   	push   %esi
  800d38:	53                   	push   %ebx
  800d39:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800d3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d41:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d49:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4c:	89 df                	mov    %ebx,%edi
  800d4e:	89 de                	mov    %ebx,%esi
  800d50:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800d52:	85 c0                	test   %eax,%eax
  800d54:	7e 28                	jle    800d7e <sys_env_set_pgfault_upcall+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800d56:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d5a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d61:	00 
  800d62:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800d69:	00 
  800d6a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d71:	00 
  800d72:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800d79:	e8 d8 0d 00 00       	call   801b56 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800d7e:	83 c4 2c             	add    $0x2c,%esp
  800d81:	5b                   	pop    %ebx
  800d82:	5e                   	pop    %esi
  800d83:	5f                   	pop    %edi
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    

00800d86 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	57                   	push   %edi
  800d8a:	56                   	push   %esi
  800d8b:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800d8c:	be 00 00 00 00       	mov    $0x0,%esi
  800d91:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d99:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t)srcva, perm, 0);
}
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	57                   	push   %edi
  800dad:	56                   	push   %esi
  800dae:	53                   	push   %ebx
  800daf:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800db2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbf:	89 cb                	mov    %ecx,%ebx
  800dc1:	89 cf                	mov    %ecx,%edi
  800dc3:	89 ce                	mov    %ecx,%esi
  800dc5:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800dc7:	85 c0                	test   %eax,%eax
  800dc9:	7e 28                	jle    800df3 <sys_ipc_recv+0x4a>
    panic("syscall %d returned %d (> 0)", num, ret);
  800dcb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dcf:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800dd6:	00 
  800dd7:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800dde:	00 
  800ddf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de6:	00 
  800de7:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800dee:	e8 63 0d 00 00       	call   801b56 <_panic>

int
sys_ipc_recv(void *dstva)
{
  return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800df3:	83 c4 2c             	add    $0x2c,%esp
  800df6:	5b                   	pop    %ebx
  800df7:	5e                   	pop    %esi
  800df8:	5f                   	pop    %edi
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    
  800dfb:	66 90                	xchg   %ax,%ax
  800dfd:	66 90                	xchg   %ax,%ax
  800dff:	90                   	nop

00800e00 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  800e03:	8b 45 08             	mov    0x8(%ebp),%eax
  800e06:	05 00 00 00 30       	add    $0x30000000,%eax
  800e0b:	c1 e8 0c             	shr    $0xc,%eax
}
  800e0e:	5d                   	pop    %ebp
  800e0f:	c3                   	ret    

00800e10 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  800e13:	8b 45 08             	mov    0x8(%ebp),%eax
  800e16:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
  return INDEX2DATA(fd2num(fd));
  800e1b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e20:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e25:	5d                   	pop    %ebp
  800e26:	c3                   	ret    

00800e27 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e27:	55                   	push   %ebp
  800e28:	89 e5                	mov    %esp,%ebp
  800e2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
  int i;
  struct Fd *fd;

  for (i = 0; i < MAXFD; i++) {
    fd = INDEX2FD(i);
    if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e32:	89 c2                	mov    %eax,%edx
  800e34:	c1 ea 16             	shr    $0x16,%edx
  800e37:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e3e:	f6 c2 01             	test   $0x1,%dl
  800e41:	74 11                	je     800e54 <fd_alloc+0x2d>
  800e43:	89 c2                	mov    %eax,%edx
  800e45:	c1 ea 0c             	shr    $0xc,%edx
  800e48:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e4f:	f6 c2 01             	test   $0x1,%dl
  800e52:	75 09                	jne    800e5d <fd_alloc+0x36>
      *fd_store = fd;
  800e54:	89 01                	mov    %eax,(%ecx)
      return 0;
  800e56:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5b:	eb 17                	jmp    800e74 <fd_alloc+0x4d>
  800e5d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
  int i;
  struct Fd *fd;

  for (i = 0; i < MAXFD; i++) {
  800e62:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e67:	75 c9                	jne    800e32 <fd_alloc+0xb>
    if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
      *fd_store = fd;
      return 0;
    }
  }
  *fd_store = 0;
  800e69:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
  return -E_MAX_OPEN;
  800e6f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e74:	5d                   	pop    %ebp
  800e75:	c3                   	ret    

00800e76 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e76:	55                   	push   %ebp
  800e77:	89 e5                	mov    %esp,%ebp
  800e79:	8b 45 08             	mov    0x8(%ebp),%eax
  struct Fd *fd;

  if (fdnum < 0 || fdnum >= MAXFD) {
  800e7c:	83 f8 1f             	cmp    $0x1f,%eax
  800e7f:	77 36                	ja     800eb7 <fd_lookup+0x41>
    if (debug)
      cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  fd = INDEX2FD(fdnum);
  800e81:	c1 e0 0c             	shl    $0xc,%eax
  800e84:	2d 00 00 00 30       	sub    $0x30000000,%eax
  if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e89:	89 c2                	mov    %eax,%edx
  800e8b:	c1 ea 16             	shr    $0x16,%edx
  800e8e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e95:	f6 c2 01             	test   $0x1,%dl
  800e98:	74 24                	je     800ebe <fd_lookup+0x48>
  800e9a:	89 c2                	mov    %eax,%edx
  800e9c:	c1 ea 0c             	shr    $0xc,%edx
  800e9f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ea6:	f6 c2 01             	test   $0x1,%dl
  800ea9:	74 1a                	je     800ec5 <fd_lookup+0x4f>
    if (debug)
      cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  *fd_store = fd;
  800eab:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eae:	89 02                	mov    %eax,(%edx)
  return 0;
  800eb0:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb5:	eb 13                	jmp    800eca <fd_lookup+0x54>
  struct Fd *fd;

  if (fdnum < 0 || fdnum >= MAXFD) {
    if (debug)
      cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  800eb7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ebc:	eb 0c                	jmp    800eca <fd_lookup+0x54>
  }
  fd = INDEX2FD(fdnum);
  if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
    if (debug)
      cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  800ebe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ec3:	eb 05                	jmp    800eca <fd_lookup+0x54>
  800ec5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  }
  *fd_store = fd;
  return 0;
}
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    

00800ecc <dev_lookup>:
  0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	83 ec 18             	sub    $0x18,%esp
  800ed2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed5:	ba 68 23 80 00       	mov    $0x802368,%edx
  int i;

  for (i = 0; devtab[i]; i++)
  800eda:	eb 13                	jmp    800eef <dev_lookup+0x23>
  800edc:	83 c2 04             	add    $0x4,%edx
    if (devtab[i]->dev_id == dev_id) {
  800edf:	39 08                	cmp    %ecx,(%eax)
  800ee1:	75 0c                	jne    800eef <dev_lookup+0x23>
      *dev = devtab[i];
  800ee3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee6:	89 01                	mov    %eax,(%ecx)
      return 0;
  800ee8:	b8 00 00 00 00       	mov    $0x0,%eax
  800eed:	eb 30                	jmp    800f1f <dev_lookup+0x53>
int
dev_lookup(int dev_id, struct Dev **dev)
{
  int i;

  for (i = 0; devtab[i]; i++)
  800eef:	8b 02                	mov    (%edx),%eax
  800ef1:	85 c0                	test   %eax,%eax
  800ef3:	75 e7                	jne    800edc <dev_lookup+0x10>
    if (devtab[i]->dev_id == dev_id) {
      *dev = devtab[i];
      return 0;
    }
  cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ef5:	a1 04 40 80 00       	mov    0x804004,%eax
  800efa:	8b 40 48             	mov    0x48(%eax),%eax
  800efd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f01:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f05:	c7 04 24 ec 22 80 00 	movl   $0x8022ec,(%esp)
  800f0c:	e8 43 f2 ff ff       	call   800154 <cprintf>
  *dev = 0;
  800f11:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f14:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  return -E_INVAL;
  800f1a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f1f:	c9                   	leave  
  800f20:	c3                   	ret    

00800f21 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
  800f24:	56                   	push   %esi
  800f25:	53                   	push   %ebx
  800f26:	83 ec 20             	sub    $0x20,%esp
  800f29:	8b 75 08             	mov    0x8(%ebp),%esi
  800f2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct Fd *fd2;
  struct Dev *dev;
  int r;

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f32:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  800f36:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f3c:	c1 e8 0c             	shr    $0xc,%eax
{
  struct Fd *fd2;
  struct Dev *dev;
  int r;

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f3f:	89 04 24             	mov    %eax,(%esp)
  800f42:	e8 2f ff ff ff       	call   800e76 <fd_lookup>
  800f47:	85 c0                	test   %eax,%eax
  800f49:	78 05                	js     800f50 <fd_close+0x2f>
      || fd != fd2)
  800f4b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f4e:	74 0c                	je     800f5c <fd_close+0x3b>
    return must_exist ? r : 0;
  800f50:	84 db                	test   %bl,%bl
  800f52:	ba 00 00 00 00       	mov    $0x0,%edx
  800f57:	0f 44 c2             	cmove  %edx,%eax
  800f5a:	eb 3f                	jmp    800f9b <fd_close+0x7a>
  if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f5c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f63:	8b 06                	mov    (%esi),%eax
  800f65:	89 04 24             	mov    %eax,(%esp)
  800f68:	e8 5f ff ff ff       	call   800ecc <dev_lookup>
  800f6d:	89 c3                	mov    %eax,%ebx
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	78 16                	js     800f89 <fd_close+0x68>
    if (dev->dev_close)
  800f73:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f76:	8b 40 10             	mov    0x10(%eax),%eax
      r = (*dev->dev_close)(fd);
    else
      r = 0;
  800f79:	bb 00 00 00 00       	mov    $0x0,%ebx

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
      || fd != fd2)
    return must_exist ? r : 0;
  if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
    if (dev->dev_close)
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	74 07                	je     800f89 <fd_close+0x68>
      r = (*dev->dev_close)(fd);
  800f82:	89 34 24             	mov    %esi,(%esp)
  800f85:	ff d0                	call   *%eax
  800f87:	89 c3                	mov    %eax,%ebx
    else
      r = 0;
  }
  // Make sure fd is unmapped.  Might be a no-op if
  // (*dev->dev_close)(fd) already unmapped it.
  (void)sys_page_unmap(0, fd);
  800f89:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f8d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f94:	e8 a1 fc ff ff       	call   800c3a <sys_page_unmap>
  return r;
  800f99:	89 d8                	mov    %ebx,%eax
}
  800f9b:	83 c4 20             	add    $0x20,%esp
  800f9e:	5b                   	pop    %ebx
  800f9f:	5e                   	pop    %esi
  800fa0:	5d                   	pop    %ebp
  800fa1:	c3                   	ret    

00800fa2 <close>:
  return -E_INVAL;
}

int
close(int fdnum)
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	83 ec 28             	sub    $0x28,%esp
  struct Fd *fd;
  int r;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fa8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fab:	89 44 24 04          	mov    %eax,0x4(%esp)
  800faf:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb2:	89 04 24             	mov    %eax,(%esp)
  800fb5:	e8 bc fe ff ff       	call   800e76 <fd_lookup>
  800fba:	89 c2                	mov    %eax,%edx
  800fbc:	85 d2                	test   %edx,%edx
  800fbe:	78 13                	js     800fd3 <close+0x31>
    return r;
  else
    return fd_close(fd, 1);
  800fc0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fc7:	00 
  800fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fcb:	89 04 24             	mov    %eax,(%esp)
  800fce:	e8 4e ff ff ff       	call   800f21 <fd_close>
}
  800fd3:	c9                   	leave  
  800fd4:	c3                   	ret    

00800fd5 <close_all>:

void
close_all(void)
{
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
  800fd8:	53                   	push   %ebx
  800fd9:	83 ec 14             	sub    $0x14,%esp
  int i;

  for (i = 0; i < MAXFD; i++)
  800fdc:	bb 00 00 00 00       	mov    $0x0,%ebx
    close(i);
  800fe1:	89 1c 24             	mov    %ebx,(%esp)
  800fe4:	e8 b9 ff ff ff       	call   800fa2 <close>
void
close_all(void)
{
  int i;

  for (i = 0; i < MAXFD; i++)
  800fe9:	83 c3 01             	add    $0x1,%ebx
  800fec:	83 fb 20             	cmp    $0x20,%ebx
  800fef:	75 f0                	jne    800fe1 <close_all+0xc>
    close(i);
}
  800ff1:	83 c4 14             	add    $0x14,%esp
  800ff4:	5b                   	pop    %ebx
  800ff5:	5d                   	pop    %ebp
  800ff6:	c3                   	ret    

00800ff7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	57                   	push   %edi
  800ffb:	56                   	push   %esi
  800ffc:	53                   	push   %ebx
  800ffd:	83 ec 3c             	sub    $0x3c,%esp
  int r;
  char *ova, *nva;
  pte_t pte;
  struct Fd *oldfd, *newfd;

  if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801000:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801003:	89 44 24 04          	mov    %eax,0x4(%esp)
  801007:	8b 45 08             	mov    0x8(%ebp),%eax
  80100a:	89 04 24             	mov    %eax,(%esp)
  80100d:	e8 64 fe ff ff       	call   800e76 <fd_lookup>
  801012:	89 c2                	mov    %eax,%edx
  801014:	85 d2                	test   %edx,%edx
  801016:	0f 88 e1 00 00 00    	js     8010fd <dup+0x106>
    return r;
  close(newfdnum);
  80101c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80101f:	89 04 24             	mov    %eax,(%esp)
  801022:	e8 7b ff ff ff       	call   800fa2 <close>

  newfd = INDEX2FD(newfdnum);
  801027:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80102a:	c1 e3 0c             	shl    $0xc,%ebx
  80102d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
  ova = fd2data(oldfd);
  801033:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801036:	89 04 24             	mov    %eax,(%esp)
  801039:	e8 d2 fd ff ff       	call   800e10 <fd2data>
  80103e:	89 c6                	mov    %eax,%esi
  nva = fd2data(newfd);
  801040:	89 1c 24             	mov    %ebx,(%esp)
  801043:	e8 c8 fd ff ff       	call   800e10 <fd2data>
  801048:	89 c7                	mov    %eax,%edi

  if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80104a:	89 f0                	mov    %esi,%eax
  80104c:	c1 e8 16             	shr    $0x16,%eax
  80104f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801056:	a8 01                	test   $0x1,%al
  801058:	74 43                	je     80109d <dup+0xa6>
  80105a:	89 f0                	mov    %esi,%eax
  80105c:	c1 e8 0c             	shr    $0xc,%eax
  80105f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801066:	f6 c2 01             	test   $0x1,%dl
  801069:	74 32                	je     80109d <dup+0xa6>
    if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80106b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801072:	25 07 0e 00 00       	and    $0xe07,%eax
  801077:	89 44 24 10          	mov    %eax,0x10(%esp)
  80107b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80107f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801086:	00 
  801087:	89 74 24 04          	mov    %esi,0x4(%esp)
  80108b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801092:	e8 50 fb ff ff       	call   800be7 <sys_page_map>
  801097:	89 c6                	mov    %eax,%esi
  801099:	85 c0                	test   %eax,%eax
  80109b:	78 3e                	js     8010db <dup+0xe4>
      goto err;
  if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80109d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010a0:	89 c2                	mov    %eax,%edx
  8010a2:	c1 ea 0c             	shr    $0xc,%edx
  8010a5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010ac:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8010b2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8010b6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010ba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010c1:	00 
  8010c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010cd:	e8 15 fb ff ff       	call   800be7 <sys_page_map>
  8010d2:	89 c6                	mov    %eax,%esi
    goto err;

  return newfdnum;
  8010d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  nva = fd2data(newfd);

  if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
    if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
      goto err;
  if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010d7:	85 f6                	test   %esi,%esi
  8010d9:	79 22                	jns    8010fd <dup+0x106>
    goto err;

  return newfdnum;

err:
  sys_page_unmap(0, newfd);
  8010db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010e6:	e8 4f fb ff ff       	call   800c3a <sys_page_unmap>
  sys_page_unmap(0, nva);
  8010eb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010f6:	e8 3f fb ff ff       	call   800c3a <sys_page_unmap>
  return r;
  8010fb:	89 f0                	mov    %esi,%eax
}
  8010fd:	83 c4 3c             	add    $0x3c,%esp
  801100:	5b                   	pop    %ebx
  801101:	5e                   	pop    %esi
  801102:	5f                   	pop    %edi
  801103:	5d                   	pop    %ebp
  801104:	c3                   	ret    

00801105 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801105:	55                   	push   %ebp
  801106:	89 e5                	mov    %esp,%ebp
  801108:	53                   	push   %ebx
  801109:	83 ec 24             	sub    $0x24,%esp
  80110c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  80110f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801112:	89 44 24 04          	mov    %eax,0x4(%esp)
  801116:	89 1c 24             	mov    %ebx,(%esp)
  801119:	e8 58 fd ff ff       	call   800e76 <fd_lookup>
  80111e:	89 c2                	mov    %eax,%edx
  801120:	85 d2                	test   %edx,%edx
  801122:	78 6d                	js     801191 <read+0x8c>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801124:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801127:	89 44 24 04          	mov    %eax,0x4(%esp)
  80112b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80112e:	8b 00                	mov    (%eax),%eax
  801130:	89 04 24             	mov    %eax,(%esp)
  801133:	e8 94 fd ff ff       	call   800ecc <dev_lookup>
  801138:	85 c0                	test   %eax,%eax
  80113a:	78 55                	js     801191 <read+0x8c>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80113c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80113f:	8b 50 08             	mov    0x8(%eax),%edx
  801142:	83 e2 03             	and    $0x3,%edx
  801145:	83 fa 01             	cmp    $0x1,%edx
  801148:	75 23                	jne    80116d <read+0x68>
    cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80114a:	a1 04 40 80 00       	mov    0x804004,%eax
  80114f:	8b 40 48             	mov    0x48(%eax),%eax
  801152:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801156:	89 44 24 04          	mov    %eax,0x4(%esp)
  80115a:	c7 04 24 2d 23 80 00 	movl   $0x80232d,(%esp)
  801161:	e8 ee ef ff ff       	call   800154 <cprintf>
    return -E_INVAL;
  801166:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80116b:	eb 24                	jmp    801191 <read+0x8c>
  }
  if (!dev->dev_read)
  80116d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801170:	8b 52 08             	mov    0x8(%edx),%edx
  801173:	85 d2                	test   %edx,%edx
  801175:	74 15                	je     80118c <read+0x87>
    return -E_NOT_SUPP;
  return (*dev->dev_read)(fd, buf, n);
  801177:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80117a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80117e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801181:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801185:	89 04 24             	mov    %eax,(%esp)
  801188:	ff d2                	call   *%edx
  80118a:	eb 05                	jmp    801191 <read+0x8c>
  if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
    cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  if (!dev->dev_read)
    return -E_NOT_SUPP;
  80118c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_read)(fd, buf, n);
}
  801191:	83 c4 24             	add    $0x24,%esp
  801194:	5b                   	pop    %ebx
  801195:	5d                   	pop    %ebp
  801196:	c3                   	ret    

00801197 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	57                   	push   %edi
  80119b:	56                   	push   %esi
  80119c:	53                   	push   %ebx
  80119d:	83 ec 1c             	sub    $0x1c,%esp
  8011a0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011a3:	8b 75 10             	mov    0x10(%ebp),%esi
  int m, tot;

  for (tot = 0; tot < n; tot += m) {
  8011a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ab:	eb 23                	jmp    8011d0 <readn+0x39>
    m = read(fdnum, (char*)buf + tot, n - tot);
  8011ad:	89 f0                	mov    %esi,%eax
  8011af:	29 d8                	sub    %ebx,%eax
  8011b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011b5:	89 d8                	mov    %ebx,%eax
  8011b7:	03 45 0c             	add    0xc(%ebp),%eax
  8011ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011be:	89 3c 24             	mov    %edi,(%esp)
  8011c1:	e8 3f ff ff ff       	call   801105 <read>
    if (m < 0)
  8011c6:	85 c0                	test   %eax,%eax
  8011c8:	78 10                	js     8011da <readn+0x43>
      return m;
    if (m == 0)
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	74 0a                	je     8011d8 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
  int m, tot;

  for (tot = 0; tot < n; tot += m) {
  8011ce:	01 c3                	add    %eax,%ebx
  8011d0:	39 f3                	cmp    %esi,%ebx
  8011d2:	72 d9                	jb     8011ad <readn+0x16>
  8011d4:	89 d8                	mov    %ebx,%eax
  8011d6:	eb 02                	jmp    8011da <readn+0x43>
  8011d8:	89 d8                	mov    %ebx,%eax
      return m;
    if (m == 0)
      break;
  }
  return tot;
}
  8011da:	83 c4 1c             	add    $0x1c,%esp
  8011dd:	5b                   	pop    %ebx
  8011de:	5e                   	pop    %esi
  8011df:	5f                   	pop    %edi
  8011e0:	5d                   	pop    %ebp
  8011e1:	c3                   	ret    

008011e2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
  8011e5:	53                   	push   %ebx
  8011e6:	83 ec 24             	sub    $0x24,%esp
  8011e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f3:	89 1c 24             	mov    %ebx,(%esp)
  8011f6:	e8 7b fc ff ff       	call   800e76 <fd_lookup>
  8011fb:	89 c2                	mov    %eax,%edx
  8011fd:	85 d2                	test   %edx,%edx
  8011ff:	78 68                	js     801269 <write+0x87>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801201:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801204:	89 44 24 04          	mov    %eax,0x4(%esp)
  801208:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120b:	8b 00                	mov    (%eax),%eax
  80120d:	89 04 24             	mov    %eax,(%esp)
  801210:	e8 b7 fc ff ff       	call   800ecc <dev_lookup>
  801215:	85 c0                	test   %eax,%eax
  801217:	78 50                	js     801269 <write+0x87>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801219:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801220:	75 23                	jne    801245 <write+0x63>
    cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801222:	a1 04 40 80 00       	mov    0x804004,%eax
  801227:	8b 40 48             	mov    0x48(%eax),%eax
  80122a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80122e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801232:	c7 04 24 49 23 80 00 	movl   $0x802349,(%esp)
  801239:	e8 16 ef ff ff       	call   800154 <cprintf>
    return -E_INVAL;
  80123e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801243:	eb 24                	jmp    801269 <write+0x87>
  }
  if (debug)
    cprintf("write %d %p %d via dev %s\n",
            fdnum, buf, n, dev->dev_name);
  if (!dev->dev_write)
  801245:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801248:	8b 52 0c             	mov    0xc(%edx),%edx
  80124b:	85 d2                	test   %edx,%edx
  80124d:	74 15                	je     801264 <write+0x82>
    return -E_NOT_SUPP;
  return (*dev->dev_write)(fd, buf, n);
  80124f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801252:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801256:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801259:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80125d:	89 04 24             	mov    %eax,(%esp)
  801260:	ff d2                	call   *%edx
  801262:	eb 05                	jmp    801269 <write+0x87>
  }
  if (debug)
    cprintf("write %d %p %d via dev %s\n",
            fdnum, buf, n, dev->dev_name);
  if (!dev->dev_write)
    return -E_NOT_SUPP;
  801264:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_write)(fd, buf, n);
}
  801269:	83 c4 24             	add    $0x24,%esp
  80126c:	5b                   	pop    %ebx
  80126d:	5d                   	pop    %ebp
  80126e:	c3                   	ret    

0080126f <seek>:

int
seek(int fdnum, off_t offset)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	83 ec 18             	sub    $0x18,%esp
  int r;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  801275:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801278:	89 44 24 04          	mov    %eax,0x4(%esp)
  80127c:	8b 45 08             	mov    0x8(%ebp),%eax
  80127f:	89 04 24             	mov    %eax,(%esp)
  801282:	e8 ef fb ff ff       	call   800e76 <fd_lookup>
  801287:	85 c0                	test   %eax,%eax
  801289:	78 0e                	js     801299 <seek+0x2a>
    return r;
  fd->fd_offset = offset;
  80128b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80128e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801291:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
  801294:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801299:	c9                   	leave  
  80129a:	c3                   	ret    

0080129b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80129b:	55                   	push   %ebp
  80129c:	89 e5                	mov    %esp,%ebp
  80129e:	53                   	push   %ebx
  80129f:	83 ec 24             	sub    $0x24,%esp
  8012a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ac:	89 1c 24             	mov    %ebx,(%esp)
  8012af:	e8 c2 fb ff ff       	call   800e76 <fd_lookup>
  8012b4:	89 c2                	mov    %eax,%edx
  8012b6:	85 d2                	test   %edx,%edx
  8012b8:	78 61                	js     80131b <ftruncate+0x80>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c4:	8b 00                	mov    (%eax),%eax
  8012c6:	89 04 24             	mov    %eax,(%esp)
  8012c9:	e8 fe fb ff ff       	call   800ecc <dev_lookup>
  8012ce:	85 c0                	test   %eax,%eax
  8012d0:	78 49                	js     80131b <ftruncate+0x80>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012d9:	75 23                	jne    8012fe <ftruncate+0x63>
    cprintf("[%08x] ftruncate %d -- bad mode\n",
            thisenv->env_id, fdnum);
  8012db:	a1 04 40 80 00       	mov    0x804004,%eax

  if ((r = fd_lookup(fdnum, &fd)) < 0
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
    cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012e0:	8b 40 48             	mov    0x48(%eax),%eax
  8012e3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012eb:	c7 04 24 0c 23 80 00 	movl   $0x80230c,(%esp)
  8012f2:	e8 5d ee ff ff       	call   800154 <cprintf>
            thisenv->env_id, fdnum);
    return -E_INVAL;
  8012f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012fc:	eb 1d                	jmp    80131b <ftruncate+0x80>
  }
  if (!dev->dev_trunc)
  8012fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801301:	8b 52 18             	mov    0x18(%edx),%edx
  801304:	85 d2                	test   %edx,%edx
  801306:	74 0e                	je     801316 <ftruncate+0x7b>
    return -E_NOT_SUPP;
  return (*dev->dev_trunc)(fd, newsize);
  801308:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80130b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80130f:	89 04 24             	mov    %eax,(%esp)
  801312:	ff d2                	call   *%edx
  801314:	eb 05                	jmp    80131b <ftruncate+0x80>
    cprintf("[%08x] ftruncate %d -- bad mode\n",
            thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  if (!dev->dev_trunc)
    return -E_NOT_SUPP;
  801316:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_trunc)(fd, newsize);
}
  80131b:	83 c4 24             	add    $0x24,%esp
  80131e:	5b                   	pop    %ebx
  80131f:	5d                   	pop    %ebp
  801320:	c3                   	ret    

00801321 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801321:	55                   	push   %ebp
  801322:	89 e5                	mov    %esp,%ebp
  801324:	53                   	push   %ebx
  801325:	83 ec 24             	sub    $0x24,%esp
  801328:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  80132b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80132e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801332:	8b 45 08             	mov    0x8(%ebp),%eax
  801335:	89 04 24             	mov    %eax,(%esp)
  801338:	e8 39 fb ff ff       	call   800e76 <fd_lookup>
  80133d:	89 c2                	mov    %eax,%edx
  80133f:	85 d2                	test   %edx,%edx
  801341:	78 52                	js     801395 <fstat+0x74>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801343:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801346:	89 44 24 04          	mov    %eax,0x4(%esp)
  80134a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134d:	8b 00                	mov    (%eax),%eax
  80134f:	89 04 24             	mov    %eax,(%esp)
  801352:	e8 75 fb ff ff       	call   800ecc <dev_lookup>
  801357:	85 c0                	test   %eax,%eax
  801359:	78 3a                	js     801395 <fstat+0x74>
    return r;
  if (!dev->dev_stat)
  80135b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801362:	74 2c                	je     801390 <fstat+0x6f>
    return -E_NOT_SUPP;
  stat->st_name[0] = 0;
  801364:	c6 03 00             	movb   $0x0,(%ebx)
  stat->st_size = 0;
  801367:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80136e:	00 00 00 
  stat->st_isdir = 0;
  801371:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801378:	00 00 00 
  stat->st_dev = dev;
  80137b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
  return (*dev->dev_stat)(fd, stat);
  801381:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801385:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801388:	89 14 24             	mov    %edx,(%esp)
  80138b:	ff 50 14             	call   *0x14(%eax)
  80138e:	eb 05                	jmp    801395 <fstat+0x74>

  if ((r = fd_lookup(fdnum, &fd)) < 0
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
    return r;
  if (!dev->dev_stat)
    return -E_NOT_SUPP;
  801390:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  stat->st_name[0] = 0;
  stat->st_size = 0;
  stat->st_isdir = 0;
  stat->st_dev = dev;
  return (*dev->dev_stat)(fd, stat);
}
  801395:	83 c4 24             	add    $0x24,%esp
  801398:	5b                   	pop    %ebx
  801399:	5d                   	pop    %ebp
  80139a:	c3                   	ret    

0080139b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80139b:	55                   	push   %ebp
  80139c:	89 e5                	mov    %esp,%ebp
  80139e:	56                   	push   %esi
  80139f:	53                   	push   %ebx
  8013a0:	83 ec 10             	sub    $0x10,%esp
  int fd, r;

  if ((fd = open(path, O_RDONLY)) < 0)
  8013a3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8013aa:	00 
  8013ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ae:	89 04 24             	mov    %eax,(%esp)
  8013b1:	e8 d2 01 00 00       	call   801588 <open>
  8013b6:	89 c3                	mov    %eax,%ebx
  8013b8:	85 db                	test   %ebx,%ebx
  8013ba:	78 1b                	js     8013d7 <stat+0x3c>
    return fd;
  r = fstat(fd, stat);
  8013bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c3:	89 1c 24             	mov    %ebx,(%esp)
  8013c6:	e8 56 ff ff ff       	call   801321 <fstat>
  8013cb:	89 c6                	mov    %eax,%esi
  close(fd);
  8013cd:	89 1c 24             	mov    %ebx,(%esp)
  8013d0:	e8 cd fb ff ff       	call   800fa2 <close>
  return r;
  8013d5:	89 f0                	mov    %esi,%eax
}
  8013d7:	83 c4 10             	add    $0x10,%esp
  8013da:	5b                   	pop    %ebx
  8013db:	5e                   	pop    %esi
  8013dc:	5d                   	pop    %ebp
  8013dd:	c3                   	ret    

008013de <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	56                   	push   %esi
  8013e2:	53                   	push   %ebx
  8013e3:	83 ec 10             	sub    $0x10,%esp
  8013e6:	89 c6                	mov    %eax,%esi
  8013e8:	89 d3                	mov    %edx,%ebx
  static envid_t fsenv;

  if (fsenv == 0)
  8013ea:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013f1:	75 11                	jne    801404 <fsipc+0x26>
    fsenv = ipc_find_env(ENV_TYPE_FS);
  8013f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8013fa:	e8 9e 08 00 00       	call   801c9d <ipc_find_env>
  8013ff:	a3 00 40 80 00       	mov    %eax,0x804000
  static_assert(sizeof(fsipcbuf) == PGSIZE);

  if (debug)
    cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t*)&fsipcbuf);

  ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801404:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80140b:	00 
  80140c:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801413:	00 
  801414:	89 74 24 04          	mov    %esi,0x4(%esp)
  801418:	a1 00 40 80 00       	mov    0x804000,%eax
  80141d:	89 04 24             	mov    %eax,(%esp)
  801420:	e8 0d 08 00 00       	call   801c32 <ipc_send>
  return ipc_recv(NULL, dstva, NULL);
  801425:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80142c:	00 
  80142d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801431:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801438:	e8 6f 07 00 00       	call   801bac <ipc_recv>
}
  80143d:	83 c4 10             	add    $0x10,%esp
  801440:	5b                   	pop    %ebx
  801441:	5e                   	pop    %esi
  801442:	5d                   	pop    %ebp
  801443:	c3                   	ret    

00801444 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801444:	55                   	push   %ebp
  801445:	89 e5                	mov    %esp,%ebp
  801447:	83 ec 08             	sub    $0x8,%esp
  fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80144a:	8b 45 08             	mov    0x8(%ebp),%eax
  80144d:	8b 40 0c             	mov    0xc(%eax),%eax
  801450:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.set_size.req_size = newsize;
  801455:	8b 45 0c             	mov    0xc(%ebp),%eax
  801458:	a3 04 50 80 00       	mov    %eax,0x805004
  return fsipc(FSREQ_SET_SIZE, NULL);
  80145d:	ba 00 00 00 00       	mov    $0x0,%edx
  801462:	b8 02 00 00 00       	mov    $0x2,%eax
  801467:	e8 72 ff ff ff       	call   8013de <fsipc>
}
  80146c:	c9                   	leave  
  80146d:	c3                   	ret    

0080146e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80146e:	55                   	push   %ebp
  80146f:	89 e5                	mov    %esp,%ebp
  801471:	83 ec 08             	sub    $0x8,%esp
  fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801474:	8b 45 08             	mov    0x8(%ebp),%eax
  801477:	8b 40 0c             	mov    0xc(%eax),%eax
  80147a:	a3 00 50 80 00       	mov    %eax,0x805000
  return fsipc(FSREQ_FLUSH, NULL);
  80147f:	ba 00 00 00 00       	mov    $0x0,%edx
  801484:	b8 06 00 00 00       	mov    $0x6,%eax
  801489:	e8 50 ff ff ff       	call   8013de <fsipc>
}
  80148e:	c9                   	leave  
  80148f:	c3                   	ret    

00801490 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
  801493:	53                   	push   %ebx
  801494:	83 ec 14             	sub    $0x14,%esp
  801497:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int r;

  fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80149a:	8b 45 08             	mov    0x8(%ebp),%eax
  80149d:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a0:	a3 00 50 80 00       	mov    %eax,0x805000
  if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8014af:	e8 2a ff ff ff       	call   8013de <fsipc>
  8014b4:	89 c2                	mov    %eax,%edx
  8014b6:	85 d2                	test   %edx,%edx
  8014b8:	78 2b                	js     8014e5 <devfile_stat+0x55>
    return r;
  strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014ba:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8014c1:	00 
  8014c2:	89 1c 24             	mov    %ebx,(%esp)
  8014c5:	e8 ad f2 ff ff       	call   800777 <strcpy>
  st->st_size = fsipcbuf.statRet.ret_size;
  8014ca:	a1 80 50 80 00       	mov    0x805080,%eax
  8014cf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014d5:	a1 84 50 80 00       	mov    0x805084,%eax
  8014da:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  return 0;
  8014e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014e5:	83 c4 14             	add    $0x14,%esp
  8014e8:	5b                   	pop    %ebx
  8014e9:	5d                   	pop    %ebp
  8014ea:	c3                   	ret    

008014eb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014eb:	55                   	push   %ebp
  8014ec:	89 e5                	mov    %esp,%ebp
  8014ee:	83 ec 18             	sub    $0x18,%esp
  8014f1:	8b 45 10             	mov    0x10(%ebp),%eax
  // remember that write is always allowed to write *fewer*
  // bytes than requested.
  // LAB 5: Your code here
    int r;

    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8014f7:	8b 52 0c             	mov    0xc(%edx),%edx
  8014fa:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  801500:	a3 04 50 80 00       	mov    %eax,0x805004

    size_t max_written = sizeof(fsipcbuf.write.req_buf);
    memmove(fsipcbuf.write.req_buf, buf, MIN(max_written, n));
  801505:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80150a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80150f:	0f 47 c2             	cmova  %edx,%eax
  801512:	89 44 24 08          	mov    %eax,0x8(%esp)
  801516:	8b 45 0c             	mov    0xc(%ebp),%eax
  801519:	89 44 24 04          	mov    %eax,0x4(%esp)
  80151d:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801524:	e8 eb f3 ff ff       	call   800914 <memmove>

    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801529:	ba 00 00 00 00       	mov    $0x0,%edx
  80152e:	b8 04 00 00 00       	mov    $0x4,%eax
  801533:	e8 a6 fe ff ff       	call   8013de <fsipc>
        return r;

    return r;
}
  801538:	c9                   	leave  
  801539:	c3                   	ret    

0080153a <devfile_read>:
// Returns:
//  The number of bytes successfully read.
//  < 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80153a:	55                   	push   %ebp
  80153b:	89 e5                	mov    %esp,%ebp
  80153d:	53                   	push   %ebx
  80153e:	83 ec 14             	sub    $0x14,%esp
  // filling fsipcbuf.read with the request arguments.  The
  // bytes read will be written back to fsipcbuf by the file
  // system server.
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801541:	8b 45 08             	mov    0x8(%ebp),%eax
  801544:	8b 40 0c             	mov    0xc(%eax),%eax
  801547:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  80154c:	8b 45 10             	mov    0x10(%ebp),%eax
  80154f:	a3 04 50 80 00       	mov    %eax,0x805004
  if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801554:	ba 00 00 00 00       	mov    $0x0,%edx
  801559:	b8 03 00 00 00       	mov    $0x3,%eax
  80155e:	e8 7b fe ff ff       	call   8013de <fsipc>
  801563:	89 c3                	mov    %eax,%ebx
  801565:	85 c0                	test   %eax,%eax
  801567:	78 17                	js     801580 <devfile_read+0x46>
    return r;

  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801569:	89 44 24 08          	mov    %eax,0x8(%esp)
  80156d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801574:	00 
  801575:	8b 45 0c             	mov    0xc(%ebp),%eax
  801578:	89 04 24             	mov    %eax,(%esp)
  80157b:	e8 94 f3 ff ff       	call   800914 <memmove>
  return r;
}
  801580:	89 d8                	mov    %ebx,%eax
  801582:	83 c4 14             	add    $0x14,%esp
  801585:	5b                   	pop    %ebx
  801586:	5d                   	pop    %ebp
  801587:	c3                   	ret    

00801588 <open>:
//  The file descriptor index on success
//  -E_BAD_PATH if the path is too long (>= MAXPATHLEN)
//  < 0 for other errors.
int
open(const char *path, int mode)
{
  801588:	55                   	push   %ebp
  801589:	89 e5                	mov    %esp,%ebp
  80158b:	53                   	push   %ebx
  80158c:	83 ec 24             	sub    $0x24,%esp
  80158f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  // file descriptor.

  int r;
  struct Fd *fd;

  if (strlen(path) >= MAXPATHLEN)
  801592:	89 1c 24             	mov    %ebx,(%esp)
  801595:	e8 a6 f1 ff ff       	call   800740 <strlen>
  80159a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80159f:	7f 60                	jg     801601 <open+0x79>
    return -E_BAD_PATH;

  if ((r = fd_alloc(&fd)) < 0)
  8015a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a4:	89 04 24             	mov    %eax,(%esp)
  8015a7:	e8 7b f8 ff ff       	call   800e27 <fd_alloc>
  8015ac:	89 c2                	mov    %eax,%edx
  8015ae:	85 d2                	test   %edx,%edx
  8015b0:	78 54                	js     801606 <open+0x7e>
    return r;

  strcpy(fsipcbuf.open.req_path, path);
  8015b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015b6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8015bd:	e8 b5 f1 ff ff       	call   800777 <strcpy>
  fsipcbuf.open.req_omode = mode;
  8015c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015c5:	a3 00 54 80 00       	mov    %eax,0x805400

  if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8015d2:	e8 07 fe ff ff       	call   8013de <fsipc>
  8015d7:	89 c3                	mov    %eax,%ebx
  8015d9:	85 c0                	test   %eax,%eax
  8015db:	79 17                	jns    8015f4 <open+0x6c>
    fd_close(fd, 0);
  8015dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015e4:	00 
  8015e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e8:	89 04 24             	mov    %eax,(%esp)
  8015eb:	e8 31 f9 ff ff       	call   800f21 <fd_close>
    return r;
  8015f0:	89 d8                	mov    %ebx,%eax
  8015f2:	eb 12                	jmp    801606 <open+0x7e>
  }

  return fd2num(fd);
  8015f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f7:	89 04 24             	mov    %eax,(%esp)
  8015fa:	e8 01 f8 ff ff       	call   800e00 <fd2num>
  8015ff:	eb 05                	jmp    801606 <open+0x7e>

  int r;
  struct Fd *fd;

  if (strlen(path) >= MAXPATHLEN)
    return -E_BAD_PATH;
  801601:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
    fd_close(fd, 0);
    return r;
  }

  return fd2num(fd);
}
  801606:	83 c4 24             	add    $0x24,%esp
  801609:	5b                   	pop    %ebx
  80160a:	5d                   	pop    %ebp
  80160b:	c3                   	ret    

0080160c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80160c:	55                   	push   %ebp
  80160d:	89 e5                	mov    %esp,%ebp
  80160f:	83 ec 08             	sub    $0x8,%esp
  // Ask the file server to update the disk
  // by writing any dirty blocks in the buffer cache.

  return fsipc(FSREQ_SYNC, NULL);
  801612:	ba 00 00 00 00       	mov    $0x0,%edx
  801617:	b8 08 00 00 00       	mov    $0x8,%eax
  80161c:	e8 bd fd ff ff       	call   8013de <fsipc>
}
  801621:	c9                   	leave  
  801622:	c3                   	ret    

00801623 <devpipe_stat>:
  return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801623:	55                   	push   %ebp
  801624:	89 e5                	mov    %esp,%ebp
  801626:	56                   	push   %esi
  801627:	53                   	push   %ebx
  801628:	83 ec 10             	sub    $0x10,%esp
  80162b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct Pipe *p = (struct Pipe*)fd2data(fd);
  80162e:	8b 45 08             	mov    0x8(%ebp),%eax
  801631:	89 04 24             	mov    %eax,(%esp)
  801634:	e8 d7 f7 ff ff       	call   800e10 <fd2data>
  801639:	89 c6                	mov    %eax,%esi

  strcpy(stat->st_name, "<pipe>");
  80163b:	c7 44 24 04 78 23 80 	movl   $0x802378,0x4(%esp)
  801642:	00 
  801643:	89 1c 24             	mov    %ebx,(%esp)
  801646:	e8 2c f1 ff ff       	call   800777 <strcpy>
  stat->st_size = p->p_wpos - p->p_rpos;
  80164b:	8b 46 04             	mov    0x4(%esi),%eax
  80164e:	2b 06                	sub    (%esi),%eax
  801650:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  stat->st_isdir = 0;
  801656:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80165d:	00 00 00 
  stat->st_dev = &devpipe;
  801660:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801667:	30 80 00 
  return 0;
}
  80166a:	b8 00 00 00 00       	mov    $0x0,%eax
  80166f:	83 c4 10             	add    $0x10,%esp
  801672:	5b                   	pop    %ebx
  801673:	5e                   	pop    %esi
  801674:	5d                   	pop    %ebp
  801675:	c3                   	ret    

00801676 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801676:	55                   	push   %ebp
  801677:	89 e5                	mov    %esp,%ebp
  801679:	53                   	push   %ebx
  80167a:	83 ec 14             	sub    $0x14,%esp
  80167d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  (void)sys_page_unmap(0, fd);
  801680:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801684:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80168b:	e8 aa f5 ff ff       	call   800c3a <sys_page_unmap>
  return sys_page_unmap(0, fd2data(fd));
  801690:	89 1c 24             	mov    %ebx,(%esp)
  801693:	e8 78 f7 ff ff       	call   800e10 <fd2data>
  801698:	89 44 24 04          	mov    %eax,0x4(%esp)
  80169c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016a3:	e8 92 f5 ff ff       	call   800c3a <sys_page_unmap>
}
  8016a8:	83 c4 14             	add    $0x14,%esp
  8016ab:	5b                   	pop    %ebx
  8016ac:	5d                   	pop    %ebp
  8016ad:	c3                   	ret    

008016ae <_pipeisclosed>:
  return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	57                   	push   %edi
  8016b2:	56                   	push   %esi
  8016b3:	53                   	push   %ebx
  8016b4:	83 ec 2c             	sub    $0x2c,%esp
  8016b7:	89 c6                	mov    %eax,%esi
  8016b9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  int n, nn, ret;

  while (1) {
    n = thisenv->env_runs;
  8016bc:	a1 04 40 80 00       	mov    0x804004,%eax
  8016c1:	8b 58 58             	mov    0x58(%eax),%ebx
    ret = pageref(fd) == pageref(p);
  8016c4:	89 34 24             	mov    %esi,(%esp)
  8016c7:	e8 09 06 00 00       	call   801cd5 <pageref>
  8016cc:	89 c7                	mov    %eax,%edi
  8016ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016d1:	89 04 24             	mov    %eax,(%esp)
  8016d4:	e8 fc 05 00 00       	call   801cd5 <pageref>
  8016d9:	39 c7                	cmp    %eax,%edi
  8016db:	0f 94 c2             	sete   %dl
  8016de:	0f b6 c2             	movzbl %dl,%eax
    nn = thisenv->env_runs;
  8016e1:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  8016e7:	8b 79 58             	mov    0x58(%ecx),%edi
    if (n == nn)
  8016ea:	39 fb                	cmp    %edi,%ebx
  8016ec:	74 21                	je     80170f <_pipeisclosed+0x61>
      return ret;
    if (n != nn && ret == 1)
  8016ee:	84 d2                	test   %dl,%dl
  8016f0:	74 ca                	je     8016bc <_pipeisclosed+0xe>
      cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016f2:	8b 51 58             	mov    0x58(%ecx),%edx
  8016f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016f9:	89 54 24 08          	mov    %edx,0x8(%esp)
  8016fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801701:	c7 04 24 7f 23 80 00 	movl   $0x80237f,(%esp)
  801708:	e8 47 ea ff ff       	call   800154 <cprintf>
  80170d:	eb ad                	jmp    8016bc <_pipeisclosed+0xe>
  }
}
  80170f:	83 c4 2c             	add    $0x2c,%esp
  801712:	5b                   	pop    %ebx
  801713:	5e                   	pop    %esi
  801714:	5f                   	pop    %edi
  801715:	5d                   	pop    %ebp
  801716:	c3                   	ret    

00801717 <devpipe_write>:
  return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	57                   	push   %edi
  80171b:	56                   	push   %esi
  80171c:	53                   	push   %ebx
  80171d:	83 ec 1c             	sub    $0x1c,%esp
  801720:	8b 75 08             	mov    0x8(%ebp),%esi
  const uint8_t *buf;
  size_t i;
  struct Pipe *p;

  p = (struct Pipe*)fd2data(fd);
  801723:	89 34 24             	mov    %esi,(%esp)
  801726:	e8 e5 f6 ff ff       	call   800e10 <fd2data>
  80172b:	89 c3                	mov    %eax,%ebx
  if (debug)
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  80172d:	bf 00 00 00 00       	mov    $0x0,%edi
  801732:	eb 45                	jmp    801779 <devpipe_write+0x62>
    while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
      // pipe is full
      // if all the readers are gone
      // (it's only writers like us now),
      // note eof
      if (_pipeisclosed(fd, p))
  801734:	89 da                	mov    %ebx,%edx
  801736:	89 f0                	mov    %esi,%eax
  801738:	e8 71 ff ff ff       	call   8016ae <_pipeisclosed>
  80173d:	85 c0                	test   %eax,%eax
  80173f:	75 41                	jne    801782 <devpipe_write+0x6b>
        return 0;
      // yield and see what happens
      if (debug)
        cprintf("devpipe_write yield\n");
      sys_yield();
  801741:	e8 2e f4 ff ff       	call   800b74 <sys_yield>
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
    while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801746:	8b 43 04             	mov    0x4(%ebx),%eax
  801749:	8b 0b                	mov    (%ebx),%ecx
  80174b:	8d 51 20             	lea    0x20(%ecx),%edx
  80174e:	39 d0                	cmp    %edx,%eax
  801750:	73 e2                	jae    801734 <devpipe_write+0x1d>
        cprintf("devpipe_write yield\n");
      sys_yield();
    }
    // there's room for a byte.  store it.
    // wait to increment wpos until the byte is stored!
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801752:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801755:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801759:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80175c:	99                   	cltd   
  80175d:	c1 ea 1b             	shr    $0x1b,%edx
  801760:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801763:	83 e1 1f             	and    $0x1f,%ecx
  801766:	29 d1                	sub    %edx,%ecx
  801768:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  80176c:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
    p->p_wpos++;
  801770:	83 c0 01             	add    $0x1,%eax
  801773:	89 43 04             	mov    %eax,0x4(%ebx)
  if (debug)
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  801776:	83 c7 01             	add    $0x1,%edi
  801779:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80177c:	75 c8                	jne    801746 <devpipe_write+0x2f>
    // wait to increment wpos until the byte is stored!
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
    p->p_wpos++;
  }

  return i;
  80177e:	89 f8                	mov    %edi,%eax
  801780:	eb 05                	jmp    801787 <devpipe_write+0x70>
      // pipe is full
      // if all the readers are gone
      // (it's only writers like us now),
      // note eof
      if (_pipeisclosed(fd, p))
        return 0;
  801782:	b8 00 00 00 00       	mov    $0x0,%eax
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
    p->p_wpos++;
  }

  return i;
}
  801787:	83 c4 1c             	add    $0x1c,%esp
  80178a:	5b                   	pop    %ebx
  80178b:	5e                   	pop    %esi
  80178c:	5f                   	pop    %edi
  80178d:	5d                   	pop    %ebp
  80178e:	c3                   	ret    

0080178f <devpipe_read>:
  return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80178f:	55                   	push   %ebp
  801790:	89 e5                	mov    %esp,%ebp
  801792:	57                   	push   %edi
  801793:	56                   	push   %esi
  801794:	53                   	push   %ebx
  801795:	83 ec 1c             	sub    $0x1c,%esp
  801798:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint8_t *buf;
  size_t i;
  struct Pipe *p;

  p = (struct Pipe*)fd2data(fd);
  80179b:	89 3c 24             	mov    %edi,(%esp)
  80179e:	e8 6d f6 ff ff       	call   800e10 <fd2data>
  8017a3:	89 c3                	mov    %eax,%ebx
  if (debug)
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  8017a5:	be 00 00 00 00       	mov    $0x0,%esi
  8017aa:	eb 3d                	jmp    8017e9 <devpipe_read+0x5a>
    while (p->p_rpos == p->p_wpos) {
      // pipe is empty
      // if we got any data, return it
      if (i > 0)
  8017ac:	85 f6                	test   %esi,%esi
  8017ae:	74 04                	je     8017b4 <devpipe_read+0x25>
        return i;
  8017b0:	89 f0                	mov    %esi,%eax
  8017b2:	eb 43                	jmp    8017f7 <devpipe_read+0x68>
      // if all the writers are gone, note eof
      if (_pipeisclosed(fd, p))
  8017b4:	89 da                	mov    %ebx,%edx
  8017b6:	89 f8                	mov    %edi,%eax
  8017b8:	e8 f1 fe ff ff       	call   8016ae <_pipeisclosed>
  8017bd:	85 c0                	test   %eax,%eax
  8017bf:	75 31                	jne    8017f2 <devpipe_read+0x63>
        return 0;
      // yield and see what happens
      if (debug)
        cprintf("devpipe_read yield\n");
      sys_yield();
  8017c1:	e8 ae f3 ff ff       	call   800b74 <sys_yield>
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
    while (p->p_rpos == p->p_wpos) {
  8017c6:	8b 03                	mov    (%ebx),%eax
  8017c8:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017cb:	74 df                	je     8017ac <devpipe_read+0x1d>
        cprintf("devpipe_read yield\n");
      sys_yield();
    }
    // there's a byte.  take it.
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017cd:	99                   	cltd   
  8017ce:	c1 ea 1b             	shr    $0x1b,%edx
  8017d1:	01 d0                	add    %edx,%eax
  8017d3:	83 e0 1f             	and    $0x1f,%eax
  8017d6:	29 d0                	sub    %edx,%eax
  8017d8:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8017dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017e0:	88 04 31             	mov    %al,(%ecx,%esi,1)
    p->p_rpos++;
  8017e3:	83 03 01             	addl   $0x1,(%ebx)
  if (debug)
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  8017e6:	83 c6 01             	add    $0x1,%esi
  8017e9:	3b 75 10             	cmp    0x10(%ebp),%esi
  8017ec:	75 d8                	jne    8017c6 <devpipe_read+0x37>
    // there's a byte.  take it.
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
    p->p_rpos++;
  }
  return i;
  8017ee:	89 f0                	mov    %esi,%eax
  8017f0:	eb 05                	jmp    8017f7 <devpipe_read+0x68>
      // if we got any data, return it
      if (i > 0)
        return i;
      // if all the writers are gone, note eof
      if (_pipeisclosed(fd, p))
        return 0;
  8017f2:	b8 00 00 00 00       	mov    $0x0,%eax
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
    p->p_rpos++;
  }
  return i;
}
  8017f7:	83 c4 1c             	add    $0x1c,%esp
  8017fa:	5b                   	pop    %ebx
  8017fb:	5e                   	pop    %esi
  8017fc:	5f                   	pop    %edi
  8017fd:	5d                   	pop    %ebp
  8017fe:	c3                   	ret    

008017ff <pipe>:
  uint8_t p_buf[PIPEBUFSIZ];    // data buffer
};

int
pipe(int pfd[2])
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	56                   	push   %esi
  801803:	53                   	push   %ebx
  801804:	83 ec 30             	sub    $0x30,%esp
  int r;
  struct Fd *fd0, *fd1;
  void *va;

  // allocate the file descriptor table entries
  if ((r = fd_alloc(&fd0)) < 0
  801807:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80180a:	89 04 24             	mov    %eax,(%esp)
  80180d:	e8 15 f6 ff ff       	call   800e27 <fd_alloc>
  801812:	89 c2                	mov    %eax,%edx
  801814:	85 d2                	test   %edx,%edx
  801816:	0f 88 4d 01 00 00    	js     801969 <pipe+0x16a>
      || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80181c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801823:	00 
  801824:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801827:	89 44 24 04          	mov    %eax,0x4(%esp)
  80182b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801832:	e8 5c f3 ff ff       	call   800b93 <sys_page_alloc>
  801837:	89 c2                	mov    %eax,%edx
  801839:	85 d2                	test   %edx,%edx
  80183b:	0f 88 28 01 00 00    	js     801969 <pipe+0x16a>
    goto err;

  if ((r = fd_alloc(&fd1)) < 0
  801841:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801844:	89 04 24             	mov    %eax,(%esp)
  801847:	e8 db f5 ff ff       	call   800e27 <fd_alloc>
  80184c:	89 c3                	mov    %eax,%ebx
  80184e:	85 c0                	test   %eax,%eax
  801850:	0f 88 fe 00 00 00    	js     801954 <pipe+0x155>
      || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801856:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80185d:	00 
  80185e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801861:	89 44 24 04          	mov    %eax,0x4(%esp)
  801865:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80186c:	e8 22 f3 ff ff       	call   800b93 <sys_page_alloc>
  801871:	89 c3                	mov    %eax,%ebx
  801873:	85 c0                	test   %eax,%eax
  801875:	0f 88 d9 00 00 00    	js     801954 <pipe+0x155>
    goto err1;

  // allocate the pipe structure as first data page in both
  va = fd2data(fd0);
  80187b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80187e:	89 04 24             	mov    %eax,(%esp)
  801881:	e8 8a f5 ff ff       	call   800e10 <fd2data>
  801886:	89 c6                	mov    %eax,%esi
  if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801888:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80188f:	00 
  801890:	89 44 24 04          	mov    %eax,0x4(%esp)
  801894:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80189b:	e8 f3 f2 ff ff       	call   800b93 <sys_page_alloc>
  8018a0:	89 c3                	mov    %eax,%ebx
  8018a2:	85 c0                	test   %eax,%eax
  8018a4:	0f 88 97 00 00 00    	js     801941 <pipe+0x142>
    goto err2;
  if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ad:	89 04 24             	mov    %eax,(%esp)
  8018b0:	e8 5b f5 ff ff       	call   800e10 <fd2data>
  8018b5:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8018bc:	00 
  8018bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018c1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018c8:	00 
  8018c9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018d4:	e8 0e f3 ff ff       	call   800be7 <sys_page_map>
  8018d9:	89 c3                	mov    %eax,%ebx
  8018db:	85 c0                	test   %eax,%eax
  8018dd:	78 52                	js     801931 <pipe+0x132>
    goto err3;

  // set up fd structures
  fd0->fd_dev_id = devpipe.dev_id;
  8018df:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e8:	89 10                	mov    %edx,(%eax)
  fd0->fd_omode = O_RDONLY;
  8018ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ed:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

  fd1->fd_dev_id = devpipe.dev_id;
  8018f4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018fd:	89 10                	mov    %edx,(%eax)
  fd1->fd_omode = O_WRONLY;
  8018ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801902:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

  if (debug)
    cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

  pfd[0] = fd2num(fd0);
  801909:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80190c:	89 04 24             	mov    %eax,(%esp)
  80190f:	e8 ec f4 ff ff       	call   800e00 <fd2num>
  801914:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801917:	89 01                	mov    %eax,(%ecx)
  pfd[1] = fd2num(fd1);
  801919:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80191c:	89 04 24             	mov    %eax,(%esp)
  80191f:	e8 dc f4 ff ff       	call   800e00 <fd2num>
  801924:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801927:	89 41 04             	mov    %eax,0x4(%ecx)
  return 0;
  80192a:	b8 00 00 00 00       	mov    $0x0,%eax
  80192f:	eb 38                	jmp    801969 <pipe+0x16a>

err3:
  sys_page_unmap(0, va);
  801931:	89 74 24 04          	mov    %esi,0x4(%esp)
  801935:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80193c:	e8 f9 f2 ff ff       	call   800c3a <sys_page_unmap>
err2:
  sys_page_unmap(0, fd1);
  801941:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801944:	89 44 24 04          	mov    %eax,0x4(%esp)
  801948:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80194f:	e8 e6 f2 ff ff       	call   800c3a <sys_page_unmap>
err1:
  sys_page_unmap(0, fd0);
  801954:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801957:	89 44 24 04          	mov    %eax,0x4(%esp)
  80195b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801962:	e8 d3 f2 ff ff       	call   800c3a <sys_page_unmap>
  801967:	89 d8                	mov    %ebx,%eax
err:
  return r;
}
  801969:	83 c4 30             	add    $0x30,%esp
  80196c:	5b                   	pop    %ebx
  80196d:	5e                   	pop    %esi
  80196e:	5d                   	pop    %ebp
  80196f:	c3                   	ret    

00801970 <pipeisclosed>:
  }
}

int
pipeisclosed(int fdnum)
{
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
  801973:	83 ec 28             	sub    $0x28,%esp
  struct Fd *fd;
  struct Pipe *p;
  int r;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  801976:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801979:	89 44 24 04          	mov    %eax,0x4(%esp)
  80197d:	8b 45 08             	mov    0x8(%ebp),%eax
  801980:	89 04 24             	mov    %eax,(%esp)
  801983:	e8 ee f4 ff ff       	call   800e76 <fd_lookup>
  801988:	89 c2                	mov    %eax,%edx
  80198a:	85 d2                	test   %edx,%edx
  80198c:	78 15                	js     8019a3 <pipeisclosed+0x33>
    return r;
  p = (struct Pipe*)fd2data(fd);
  80198e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801991:	89 04 24             	mov    %eax,(%esp)
  801994:	e8 77 f4 ff ff       	call   800e10 <fd2data>
  return _pipeisclosed(fd, p);
  801999:	89 c2                	mov    %eax,%edx
  80199b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80199e:	e8 0b fd ff ff       	call   8016ae <_pipeisclosed>
}
  8019a3:	c9                   	leave  
  8019a4:	c3                   	ret    
  8019a5:	66 90                	xchg   %ax,%ax
  8019a7:	66 90                	xchg   %ax,%ax
  8019a9:	66 90                	xchg   %ax,%ax
  8019ab:	66 90                	xchg   %ax,%ax
  8019ad:	66 90                	xchg   %ax,%ax
  8019af:	90                   	nop

008019b0 <devcons_close>:
  return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  USED(fd);

  return 0;
}
  8019b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b8:	5d                   	pop    %ebp
  8019b9:	c3                   	ret    

008019ba <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	83 ec 18             	sub    $0x18,%esp
  strcpy(stat->st_name, "<cons>");
  8019c0:	c7 44 24 04 97 23 80 	movl   $0x802397,0x4(%esp)
  8019c7:	00 
  8019c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019cb:	89 04 24             	mov    %eax,(%esp)
  8019ce:	e8 a4 ed ff ff       	call   800777 <strcpy>
  return 0;
}
  8019d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d8:	c9                   	leave  
  8019d9:	c3                   	ret    

008019da <devcons_write>:
  return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019da:	55                   	push   %ebp
  8019db:	89 e5                	mov    %esp,%ebp
  8019dd:	57                   	push   %edi
  8019de:	56                   	push   %esi
  8019df:	53                   	push   %ebx
  8019e0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  8019e6:	bb 00 00 00 00       	mov    $0x0,%ebx
    m = n - tot;
    if (m > sizeof(buf) - 1)
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
  8019eb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  8019f1:	eb 31                	jmp    801a24 <devcons_write+0x4a>
    m = n - tot;
  8019f3:	8b 75 10             	mov    0x10(%ebp),%esi
  8019f6:	29 de                	sub    %ebx,%esi
    if (m > sizeof(buf) - 1)
  8019f8:	83 fe 7f             	cmp    $0x7f,%esi
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
    m = n - tot;
  8019fb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801a00:	0f 47 f2             	cmova  %edx,%esi
    if (m > sizeof(buf) - 1)
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
  801a03:	89 74 24 08          	mov    %esi,0x8(%esp)
  801a07:	03 45 0c             	add    0xc(%ebp),%eax
  801a0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a0e:	89 3c 24             	mov    %edi,(%esp)
  801a11:	e8 fe ee ff ff       	call   800914 <memmove>
    sys_cputs(buf, m);
  801a16:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a1a:	89 3c 24             	mov    %edi,(%esp)
  801a1d:	e8 a4 f0 ff ff       	call   800ac6 <sys_cputs>
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  801a22:	01 f3                	add    %esi,%ebx
  801a24:	89 d8                	mov    %ebx,%eax
  801a26:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a29:	72 c8                	jb     8019f3 <devcons_write+0x19>
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
    sys_cputs(buf, m);
  }
  return tot;
}
  801a2b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801a31:	5b                   	pop    %ebx
  801a32:	5e                   	pop    %esi
  801a33:	5f                   	pop    %edi
  801a34:	5d                   	pop    %ebp
  801a35:	c3                   	ret    

00801a36 <devcons_read>:
  return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a36:	55                   	push   %ebp
  801a37:	89 e5                	mov    %esp,%ebp
  801a39:	83 ec 08             	sub    $0x8,%esp
  int c;

  if (n == 0)
    return 0;
  801a3c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  int c;

  if (n == 0)
  801a41:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a45:	75 07                	jne    801a4e <devcons_read+0x18>
  801a47:	eb 2a                	jmp    801a73 <devcons_read+0x3d>
    return 0;

  while ((c = sys_cgetc()) == 0)
    sys_yield();
  801a49:	e8 26 f1 ff ff       	call   800b74 <sys_yield>
  int c;

  if (n == 0)
    return 0;

  while ((c = sys_cgetc()) == 0)
  801a4e:	66 90                	xchg   %ax,%ax
  801a50:	e8 8f f0 ff ff       	call   800ae4 <sys_cgetc>
  801a55:	85 c0                	test   %eax,%eax
  801a57:	74 f0                	je     801a49 <devcons_read+0x13>
    sys_yield();
  if (c < 0)
  801a59:	85 c0                	test   %eax,%eax
  801a5b:	78 16                	js     801a73 <devcons_read+0x3d>
    return c;
  if (c == 0x04)        // ctl-d is eof
  801a5d:	83 f8 04             	cmp    $0x4,%eax
  801a60:	74 0c                	je     801a6e <devcons_read+0x38>
    return 0;
  *(char*)vbuf = c;
  801a62:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a65:	88 02                	mov    %al,(%edx)
  return 1;
  801a67:	b8 01 00 00 00       	mov    $0x1,%eax
  801a6c:	eb 05                	jmp    801a73 <devcons_read+0x3d>
  while ((c = sys_cgetc()) == 0)
    sys_yield();
  if (c < 0)
    return c;
  if (c == 0x04)        // ctl-d is eof
    return 0;
  801a6e:	b8 00 00 00 00       	mov    $0x0,%eax
  *(char*)vbuf = c;
  return 1;
}
  801a73:	c9                   	leave  
  801a74:	c3                   	ret    

00801a75 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a75:	55                   	push   %ebp
  801a76:	89 e5                	mov    %esp,%ebp
  801a78:	83 ec 28             	sub    $0x28,%esp
  char c = ch;
  801a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7e:	88 45 f7             	mov    %al,-0x9(%ebp)

  // Unlike standard Unix's putchar,
  // the cputchar function _always_ outputs to the system console.
  sys_cputs(&c, 1);
  801a81:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a88:	00 
  801a89:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a8c:	89 04 24             	mov    %eax,(%esp)
  801a8f:	e8 32 f0 ff ff       	call   800ac6 <sys_cputs>
}
  801a94:	c9                   	leave  
  801a95:	c3                   	ret    

00801a96 <getchar>:

int
getchar(void)
{
  801a96:	55                   	push   %ebp
  801a97:	89 e5                	mov    %esp,%ebp
  801a99:	83 ec 28             	sub    $0x28,%esp
  int r;

  // JOS does, however, support standard _input_ redirection,
  // allowing the user to redirect script files to the shell and such.
  // getchar() reads a character from file descriptor 0.
  r = read(0, &c, 1);
  801a9c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801aa3:	00 
  801aa4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801aa7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ab2:	e8 4e f6 ff ff       	call   801105 <read>
  if (r < 0)
  801ab7:	85 c0                	test   %eax,%eax
  801ab9:	78 0f                	js     801aca <getchar+0x34>
    return r;
  if (r < 1)
  801abb:	85 c0                	test   %eax,%eax
  801abd:	7e 06                	jle    801ac5 <getchar+0x2f>
    return -E_EOF;
  return c;
  801abf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ac3:	eb 05                	jmp    801aca <getchar+0x34>
  // getchar() reads a character from file descriptor 0.
  r = read(0, &c, 1);
  if (r < 0)
    return r;
  if (r < 1)
    return -E_EOF;
  801ac5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  /* int r;
  // sys_cgetc does not block, but getchar should.
  while ((r = sys_cgetc()) == 0)
    sys_yield();
  return r; */
}
  801aca:	c9                   	leave  
  801acb:	c3                   	ret    

00801acc <iscons>:
  .dev_stat   =     devcons_stat
};

int
iscons(int fdnum)
{
  801acc:	55                   	push   %ebp
  801acd:	89 e5                	mov    %esp,%ebp
  801acf:	83 ec 28             	sub    $0x28,%esp
  int r;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ad2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ad5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  801adc:	89 04 24             	mov    %eax,(%esp)
  801adf:	e8 92 f3 ff ff       	call   800e76 <fd_lookup>
  801ae4:	85 c0                	test   %eax,%eax
  801ae6:	78 11                	js     801af9 <iscons+0x2d>
    return r;
  return fd->fd_dev_id == devcons.dev_id;
  801ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aeb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801af1:	39 10                	cmp    %edx,(%eax)
  801af3:	0f 94 c0             	sete   %al
  801af6:	0f b6 c0             	movzbl %al,%eax
}
  801af9:	c9                   	leave  
  801afa:	c3                   	ret    

00801afb <opencons>:

int
opencons(void)
{
  801afb:	55                   	push   %ebp
  801afc:	89 e5                	mov    %esp,%ebp
  801afe:	83 ec 28             	sub    $0x28,%esp
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
  801b01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b04:	89 04 24             	mov    %eax,(%esp)
  801b07:	e8 1b f3 ff ff       	call   800e27 <fd_alloc>
    return r;
  801b0c:	89 c2                	mov    %eax,%edx
opencons(void)
{
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
  801b0e:	85 c0                	test   %eax,%eax
  801b10:	78 40                	js     801b52 <opencons+0x57>
    return r;
  if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b12:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b19:	00 
  801b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b28:	e8 66 f0 ff ff       	call   800b93 <sys_page_alloc>
    return r;
  801b2d:	89 c2                	mov    %eax,%edx
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
    return r;
  if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b2f:	85 c0                	test   %eax,%eax
  801b31:	78 1f                	js     801b52 <opencons+0x57>
    return r;
  fd->fd_dev_id = devcons.dev_id;
  801b33:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b3c:	89 10                	mov    %edx,(%eax)
  fd->fd_omode = O_RDWR;
  801b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b41:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
  return fd2num(fd);
  801b48:	89 04 24             	mov    %eax,(%esp)
  801b4b:	e8 b0 f2 ff ff       	call   800e00 <fd2num>
  801b50:	89 c2                	mov    %eax,%edx
}
  801b52:	89 d0                	mov    %edx,%eax
  801b54:	c9                   	leave  
  801b55:	c3                   	ret    

00801b56 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b56:	55                   	push   %ebp
  801b57:	89 e5                	mov    %esp,%ebp
  801b59:	56                   	push   %esi
  801b5a:	53                   	push   %ebx
  801b5b:	83 ec 20             	sub    $0x20,%esp
  va_list ap;

  va_start(ap, fmt);
  801b5e:	8d 5d 14             	lea    0x14(%ebp),%ebx

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  801b61:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801b67:	e8 e9 ef ff ff       	call   800b55 <sys_getenvid>
  801b6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b6f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b73:	8b 55 08             	mov    0x8(%ebp),%edx
  801b76:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801b7a:	89 74 24 08          	mov    %esi,0x8(%esp)
  801b7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b82:	c7 04 24 a4 23 80 00 	movl   $0x8023a4,(%esp)
  801b89:	e8 c6 e5 ff ff       	call   800154 <cprintf>
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  801b8e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b92:	8b 45 10             	mov    0x10(%ebp),%eax
  801b95:	89 04 24             	mov    %eax,(%esp)
  801b98:	e8 56 e5 ff ff       	call   8000f3 <vcprintf>
  cprintf("\n");
  801b9d:	c7 04 24 bc 1f 80 00 	movl   $0x801fbc,(%esp)
  801ba4:	e8 ab e5 ff ff       	call   800154 <cprintf>

  // Cause a breakpoint exception
  while (1)
    asm volatile ("int3");
  801ba9:	cc                   	int3   
  801baa:	eb fd                	jmp    801ba9 <_panic+0x53>

00801bac <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bac:	55                   	push   %ebp
  801bad:	89 e5                	mov    %esp,%ebp
  801baf:	56                   	push   %esi
  801bb0:	53                   	push   %ebx
  801bb1:	83 ec 10             	sub    $0x10,%esp
  801bb4:	8b 75 08             	mov    0x8(%ebp),%esi
  801bb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;
  801bbd:	85 c0                	test   %eax,%eax
  801bbf:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801bc4:	0f 44 c2             	cmove  %edx,%eax
  if ((r = sys_ipc_recv(pg)) < 0) {
  801bc7:	89 04 24             	mov    %eax,(%esp)
  801bca:	e8 da f1 ff ff       	call   800da9 <sys_ipc_recv>
  801bcf:	85 c0                	test   %eax,%eax
  801bd1:	79 34                	jns    801c07 <ipc_recv+0x5b>
    if (from_env_store)
  801bd3:	85 f6                	test   %esi,%esi
  801bd5:	74 06                	je     801bdd <ipc_recv+0x31>
      *from_env_store = 0;
  801bd7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (perm_store)
  801bdd:	85 db                	test   %ebx,%ebx
  801bdf:	74 06                	je     801be7 <ipc_recv+0x3b>
      *perm_store = 0;
  801be1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    panic("sys_ipc_recv: %e", r);
  801be7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801beb:	c7 44 24 08 c8 23 80 	movl   $0x8023c8,0x8(%esp)
  801bf2:	00 
  801bf3:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801bfa:	00 
  801bfb:	c7 04 24 d9 23 80 00 	movl   $0x8023d9,(%esp)
  801c02:	e8 4f ff ff ff       	call   801b56 <_panic>
  }

  if (from_env_store)
  801c07:	85 f6                	test   %esi,%esi
  801c09:	74 0a                	je     801c15 <ipc_recv+0x69>
    *from_env_store = thisenv->env_ipc_from;
  801c0b:	a1 04 40 80 00       	mov    0x804004,%eax
  801c10:	8b 40 74             	mov    0x74(%eax),%eax
  801c13:	89 06                	mov    %eax,(%esi)
  if (perm_store)
  801c15:	85 db                	test   %ebx,%ebx
  801c17:	74 0a                	je     801c23 <ipc_recv+0x77>
    *perm_store |= thisenv->env_ipc_perm;
  801c19:	a1 04 40 80 00       	mov    0x804004,%eax
  801c1e:	8b 40 78             	mov    0x78(%eax),%eax
  801c21:	09 03                	or     %eax,(%ebx)

  return thisenv->env_ipc_value;
  801c23:	a1 04 40 80 00       	mov    0x804004,%eax
  801c28:	8b 40 70             	mov    0x70(%eax),%eax

}
  801c2b:	83 c4 10             	add    $0x10,%esp
  801c2e:	5b                   	pop    %ebx
  801c2f:	5e                   	pop    %esi
  801c30:	5d                   	pop    %ebp
  801c31:	c3                   	ret    

00801c32 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c32:	55                   	push   %ebp
  801c33:	89 e5                	mov    %esp,%ebp
  801c35:	57                   	push   %edi
  801c36:	56                   	push   %esi
  801c37:	53                   	push   %ebx
  801c38:	83 ec 1c             	sub    $0x1c,%esp
  801c3b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c3e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c41:	8b 5d 10             	mov    0x10(%ebp),%ebx
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;
  801c44:	85 db                	test   %ebx,%ebx
  801c46:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801c4b:	0f 44 d8             	cmove  %eax,%ebx

  while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801c4e:	eb 2a                	jmp    801c7a <ipc_send+0x48>
    if (r != -E_IPC_NOT_RECV)
  801c50:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c53:	74 20                	je     801c75 <ipc_send+0x43>
      panic("ipc_send: %e", r);
  801c55:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c59:	c7 44 24 08 e3 23 80 	movl   $0x8023e3,0x8(%esp)
  801c60:	00 
  801c61:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801c68:	00 
  801c69:	c7 04 24 d9 23 80 00 	movl   $0x8023d9,(%esp)
  801c70:	e8 e1 fe ff ff       	call   801b56 <_panic>
    sys_yield();
  801c75:	e8 fa ee ff ff       	call   800b74 <sys_yield>
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;

  while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801c7a:	8b 45 14             	mov    0x14(%ebp),%eax
  801c7d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c81:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c85:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c89:	89 3c 24             	mov    %edi,(%esp)
  801c8c:	e8 f5 f0 ff ff       	call   800d86 <sys_ipc_try_send>
  801c91:	85 c0                	test   %eax,%eax
  801c93:	78 bb                	js     801c50 <ipc_send+0x1e>
    if (r != -E_IPC_NOT_RECV)
      panic("ipc_send: %e", r);
    sys_yield();
  }
}
  801c95:	83 c4 1c             	add    $0x1c,%esp
  801c98:	5b                   	pop    %ebx
  801c99:	5e                   	pop    %esi
  801c9a:	5f                   	pop    %edi
  801c9b:	5d                   	pop    %ebp
  801c9c:	c3                   	ret    

00801c9d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c9d:	55                   	push   %ebp
  801c9e:	89 e5                	mov    %esp,%ebp
  801ca0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int i;

  for (i = 0; i < NENV; i++)
  801ca3:	b8 00 00 00 00       	mov    $0x0,%eax
    if (envs[i].env_type == type)
  801ca8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801cab:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cb1:	8b 52 50             	mov    0x50(%edx),%edx
  801cb4:	39 ca                	cmp    %ecx,%edx
  801cb6:	75 0d                	jne    801cc5 <ipc_find_env+0x28>
      return envs[i].env_id;
  801cb8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801cbb:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801cc0:	8b 40 40             	mov    0x40(%eax),%eax
  801cc3:	eb 0e                	jmp    801cd3 <ipc_find_env+0x36>
envid_t
ipc_find_env(enum EnvType type)
{
  int i;

  for (i = 0; i < NENV; i++)
  801cc5:	83 c0 01             	add    $0x1,%eax
  801cc8:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ccd:	75 d9                	jne    801ca8 <ipc_find_env+0xb>
    if (envs[i].env_type == type)
      return envs[i].env_id;
  return 0;
  801ccf:	66 b8 00 00          	mov    $0x0,%ax
}
  801cd3:	5d                   	pop    %ebp
  801cd4:	c3                   	ret    

00801cd5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cd5:	55                   	push   %ebp
  801cd6:	89 e5                	mov    %esp,%ebp
  801cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  pte_t pte;

  if (!(uvpd[PDX(v)] & PTE_P))
  801cdb:	89 d0                	mov    %edx,%eax
  801cdd:	c1 e8 16             	shr    $0x16,%eax
  801ce0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
    return 0;
  801ce7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
  pte_t pte;

  if (!(uvpd[PDX(v)] & PTE_P))
  801cec:	f6 c1 01             	test   $0x1,%cl
  801cef:	74 1d                	je     801d0e <pageref+0x39>
    return 0;
  pte = uvpt[PGNUM(v)];
  801cf1:	c1 ea 0c             	shr    $0xc,%edx
  801cf4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  if (!(pte & PTE_P))
  801cfb:	f6 c2 01             	test   $0x1,%dl
  801cfe:	74 0e                	je     801d0e <pageref+0x39>
    return 0;
  return pages[PGNUM(pte)].pp_ref;
  801d00:	c1 ea 0c             	shr    $0xc,%edx
  801d03:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d0a:	ef 
  801d0b:	0f b7 c0             	movzwl %ax,%eax
}
  801d0e:	5d                   	pop    %ebp
  801d0f:	c3                   	ret    

00801d10 <__udivdi3>:
  801d10:	55                   	push   %ebp
  801d11:	57                   	push   %edi
  801d12:	56                   	push   %esi
  801d13:	83 ec 0c             	sub    $0xc,%esp
  801d16:	8b 44 24 28          	mov    0x28(%esp),%eax
  801d1a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801d1e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801d22:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801d26:	85 c0                	test   %eax,%eax
  801d28:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d2c:	89 ea                	mov    %ebp,%edx
  801d2e:	89 0c 24             	mov    %ecx,(%esp)
  801d31:	75 2d                	jne    801d60 <__udivdi3+0x50>
  801d33:	39 e9                	cmp    %ebp,%ecx
  801d35:	77 61                	ja     801d98 <__udivdi3+0x88>
  801d37:	85 c9                	test   %ecx,%ecx
  801d39:	89 ce                	mov    %ecx,%esi
  801d3b:	75 0b                	jne    801d48 <__udivdi3+0x38>
  801d3d:	b8 01 00 00 00       	mov    $0x1,%eax
  801d42:	31 d2                	xor    %edx,%edx
  801d44:	f7 f1                	div    %ecx
  801d46:	89 c6                	mov    %eax,%esi
  801d48:	31 d2                	xor    %edx,%edx
  801d4a:	89 e8                	mov    %ebp,%eax
  801d4c:	f7 f6                	div    %esi
  801d4e:	89 c5                	mov    %eax,%ebp
  801d50:	89 f8                	mov    %edi,%eax
  801d52:	f7 f6                	div    %esi
  801d54:	89 ea                	mov    %ebp,%edx
  801d56:	83 c4 0c             	add    $0xc,%esp
  801d59:	5e                   	pop    %esi
  801d5a:	5f                   	pop    %edi
  801d5b:	5d                   	pop    %ebp
  801d5c:	c3                   	ret    
  801d5d:	8d 76 00             	lea    0x0(%esi),%esi
  801d60:	39 e8                	cmp    %ebp,%eax
  801d62:	77 24                	ja     801d88 <__udivdi3+0x78>
  801d64:	0f bd e8             	bsr    %eax,%ebp
  801d67:	83 f5 1f             	xor    $0x1f,%ebp
  801d6a:	75 3c                	jne    801da8 <__udivdi3+0x98>
  801d6c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801d70:	39 34 24             	cmp    %esi,(%esp)
  801d73:	0f 86 9f 00 00 00    	jbe    801e18 <__udivdi3+0x108>
  801d79:	39 d0                	cmp    %edx,%eax
  801d7b:	0f 82 97 00 00 00    	jb     801e18 <__udivdi3+0x108>
  801d81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d88:	31 d2                	xor    %edx,%edx
  801d8a:	31 c0                	xor    %eax,%eax
  801d8c:	83 c4 0c             	add    $0xc,%esp
  801d8f:	5e                   	pop    %esi
  801d90:	5f                   	pop    %edi
  801d91:	5d                   	pop    %ebp
  801d92:	c3                   	ret    
  801d93:	90                   	nop
  801d94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d98:	89 f8                	mov    %edi,%eax
  801d9a:	f7 f1                	div    %ecx
  801d9c:	31 d2                	xor    %edx,%edx
  801d9e:	83 c4 0c             	add    $0xc,%esp
  801da1:	5e                   	pop    %esi
  801da2:	5f                   	pop    %edi
  801da3:	5d                   	pop    %ebp
  801da4:	c3                   	ret    
  801da5:	8d 76 00             	lea    0x0(%esi),%esi
  801da8:	89 e9                	mov    %ebp,%ecx
  801daa:	8b 3c 24             	mov    (%esp),%edi
  801dad:	d3 e0                	shl    %cl,%eax
  801daf:	89 c6                	mov    %eax,%esi
  801db1:	b8 20 00 00 00       	mov    $0x20,%eax
  801db6:	29 e8                	sub    %ebp,%eax
  801db8:	89 c1                	mov    %eax,%ecx
  801dba:	d3 ef                	shr    %cl,%edi
  801dbc:	89 e9                	mov    %ebp,%ecx
  801dbe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801dc2:	8b 3c 24             	mov    (%esp),%edi
  801dc5:	09 74 24 08          	or     %esi,0x8(%esp)
  801dc9:	89 d6                	mov    %edx,%esi
  801dcb:	d3 e7                	shl    %cl,%edi
  801dcd:	89 c1                	mov    %eax,%ecx
  801dcf:	89 3c 24             	mov    %edi,(%esp)
  801dd2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801dd6:	d3 ee                	shr    %cl,%esi
  801dd8:	89 e9                	mov    %ebp,%ecx
  801dda:	d3 e2                	shl    %cl,%edx
  801ddc:	89 c1                	mov    %eax,%ecx
  801dde:	d3 ef                	shr    %cl,%edi
  801de0:	09 d7                	or     %edx,%edi
  801de2:	89 f2                	mov    %esi,%edx
  801de4:	89 f8                	mov    %edi,%eax
  801de6:	f7 74 24 08          	divl   0x8(%esp)
  801dea:	89 d6                	mov    %edx,%esi
  801dec:	89 c7                	mov    %eax,%edi
  801dee:	f7 24 24             	mull   (%esp)
  801df1:	39 d6                	cmp    %edx,%esi
  801df3:	89 14 24             	mov    %edx,(%esp)
  801df6:	72 30                	jb     801e28 <__udivdi3+0x118>
  801df8:	8b 54 24 04          	mov    0x4(%esp),%edx
  801dfc:	89 e9                	mov    %ebp,%ecx
  801dfe:	d3 e2                	shl    %cl,%edx
  801e00:	39 c2                	cmp    %eax,%edx
  801e02:	73 05                	jae    801e09 <__udivdi3+0xf9>
  801e04:	3b 34 24             	cmp    (%esp),%esi
  801e07:	74 1f                	je     801e28 <__udivdi3+0x118>
  801e09:	89 f8                	mov    %edi,%eax
  801e0b:	31 d2                	xor    %edx,%edx
  801e0d:	e9 7a ff ff ff       	jmp    801d8c <__udivdi3+0x7c>
  801e12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e18:	31 d2                	xor    %edx,%edx
  801e1a:	b8 01 00 00 00       	mov    $0x1,%eax
  801e1f:	e9 68 ff ff ff       	jmp    801d8c <__udivdi3+0x7c>
  801e24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e28:	8d 47 ff             	lea    -0x1(%edi),%eax
  801e2b:	31 d2                	xor    %edx,%edx
  801e2d:	83 c4 0c             	add    $0xc,%esp
  801e30:	5e                   	pop    %esi
  801e31:	5f                   	pop    %edi
  801e32:	5d                   	pop    %ebp
  801e33:	c3                   	ret    
  801e34:	66 90                	xchg   %ax,%ax
  801e36:	66 90                	xchg   %ax,%ax
  801e38:	66 90                	xchg   %ax,%ax
  801e3a:	66 90                	xchg   %ax,%ax
  801e3c:	66 90                	xchg   %ax,%ax
  801e3e:	66 90                	xchg   %ax,%ax

00801e40 <__umoddi3>:
  801e40:	55                   	push   %ebp
  801e41:	57                   	push   %edi
  801e42:	56                   	push   %esi
  801e43:	83 ec 14             	sub    $0x14,%esp
  801e46:	8b 44 24 28          	mov    0x28(%esp),%eax
  801e4a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801e4e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801e52:	89 c7                	mov    %eax,%edi
  801e54:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e58:	8b 44 24 30          	mov    0x30(%esp),%eax
  801e5c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801e60:	89 34 24             	mov    %esi,(%esp)
  801e63:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e67:	85 c0                	test   %eax,%eax
  801e69:	89 c2                	mov    %eax,%edx
  801e6b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e6f:	75 17                	jne    801e88 <__umoddi3+0x48>
  801e71:	39 fe                	cmp    %edi,%esi
  801e73:	76 4b                	jbe    801ec0 <__umoddi3+0x80>
  801e75:	89 c8                	mov    %ecx,%eax
  801e77:	89 fa                	mov    %edi,%edx
  801e79:	f7 f6                	div    %esi
  801e7b:	89 d0                	mov    %edx,%eax
  801e7d:	31 d2                	xor    %edx,%edx
  801e7f:	83 c4 14             	add    $0x14,%esp
  801e82:	5e                   	pop    %esi
  801e83:	5f                   	pop    %edi
  801e84:	5d                   	pop    %ebp
  801e85:	c3                   	ret    
  801e86:	66 90                	xchg   %ax,%ax
  801e88:	39 f8                	cmp    %edi,%eax
  801e8a:	77 54                	ja     801ee0 <__umoddi3+0xa0>
  801e8c:	0f bd e8             	bsr    %eax,%ebp
  801e8f:	83 f5 1f             	xor    $0x1f,%ebp
  801e92:	75 5c                	jne    801ef0 <__umoddi3+0xb0>
  801e94:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801e98:	39 3c 24             	cmp    %edi,(%esp)
  801e9b:	0f 87 e7 00 00 00    	ja     801f88 <__umoddi3+0x148>
  801ea1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ea5:	29 f1                	sub    %esi,%ecx
  801ea7:	19 c7                	sbb    %eax,%edi
  801ea9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ead:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801eb1:	8b 44 24 08          	mov    0x8(%esp),%eax
  801eb5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801eb9:	83 c4 14             	add    $0x14,%esp
  801ebc:	5e                   	pop    %esi
  801ebd:	5f                   	pop    %edi
  801ebe:	5d                   	pop    %ebp
  801ebf:	c3                   	ret    
  801ec0:	85 f6                	test   %esi,%esi
  801ec2:	89 f5                	mov    %esi,%ebp
  801ec4:	75 0b                	jne    801ed1 <__umoddi3+0x91>
  801ec6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ecb:	31 d2                	xor    %edx,%edx
  801ecd:	f7 f6                	div    %esi
  801ecf:	89 c5                	mov    %eax,%ebp
  801ed1:	8b 44 24 04          	mov    0x4(%esp),%eax
  801ed5:	31 d2                	xor    %edx,%edx
  801ed7:	f7 f5                	div    %ebp
  801ed9:	89 c8                	mov    %ecx,%eax
  801edb:	f7 f5                	div    %ebp
  801edd:	eb 9c                	jmp    801e7b <__umoddi3+0x3b>
  801edf:	90                   	nop
  801ee0:	89 c8                	mov    %ecx,%eax
  801ee2:	89 fa                	mov    %edi,%edx
  801ee4:	83 c4 14             	add    $0x14,%esp
  801ee7:	5e                   	pop    %esi
  801ee8:	5f                   	pop    %edi
  801ee9:	5d                   	pop    %ebp
  801eea:	c3                   	ret    
  801eeb:	90                   	nop
  801eec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ef0:	8b 04 24             	mov    (%esp),%eax
  801ef3:	be 20 00 00 00       	mov    $0x20,%esi
  801ef8:	89 e9                	mov    %ebp,%ecx
  801efa:	29 ee                	sub    %ebp,%esi
  801efc:	d3 e2                	shl    %cl,%edx
  801efe:	89 f1                	mov    %esi,%ecx
  801f00:	d3 e8                	shr    %cl,%eax
  801f02:	89 e9                	mov    %ebp,%ecx
  801f04:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f08:	8b 04 24             	mov    (%esp),%eax
  801f0b:	09 54 24 04          	or     %edx,0x4(%esp)
  801f0f:	89 fa                	mov    %edi,%edx
  801f11:	d3 e0                	shl    %cl,%eax
  801f13:	89 f1                	mov    %esi,%ecx
  801f15:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f19:	8b 44 24 10          	mov    0x10(%esp),%eax
  801f1d:	d3 ea                	shr    %cl,%edx
  801f1f:	89 e9                	mov    %ebp,%ecx
  801f21:	d3 e7                	shl    %cl,%edi
  801f23:	89 f1                	mov    %esi,%ecx
  801f25:	d3 e8                	shr    %cl,%eax
  801f27:	89 e9                	mov    %ebp,%ecx
  801f29:	09 f8                	or     %edi,%eax
  801f2b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801f2f:	f7 74 24 04          	divl   0x4(%esp)
  801f33:	d3 e7                	shl    %cl,%edi
  801f35:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f39:	89 d7                	mov    %edx,%edi
  801f3b:	f7 64 24 08          	mull   0x8(%esp)
  801f3f:	39 d7                	cmp    %edx,%edi
  801f41:	89 c1                	mov    %eax,%ecx
  801f43:	89 14 24             	mov    %edx,(%esp)
  801f46:	72 2c                	jb     801f74 <__umoddi3+0x134>
  801f48:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801f4c:	72 22                	jb     801f70 <__umoddi3+0x130>
  801f4e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f52:	29 c8                	sub    %ecx,%eax
  801f54:	19 d7                	sbb    %edx,%edi
  801f56:	89 e9                	mov    %ebp,%ecx
  801f58:	89 fa                	mov    %edi,%edx
  801f5a:	d3 e8                	shr    %cl,%eax
  801f5c:	89 f1                	mov    %esi,%ecx
  801f5e:	d3 e2                	shl    %cl,%edx
  801f60:	89 e9                	mov    %ebp,%ecx
  801f62:	d3 ef                	shr    %cl,%edi
  801f64:	09 d0                	or     %edx,%eax
  801f66:	89 fa                	mov    %edi,%edx
  801f68:	83 c4 14             	add    $0x14,%esp
  801f6b:	5e                   	pop    %esi
  801f6c:	5f                   	pop    %edi
  801f6d:	5d                   	pop    %ebp
  801f6e:	c3                   	ret    
  801f6f:	90                   	nop
  801f70:	39 d7                	cmp    %edx,%edi
  801f72:	75 da                	jne    801f4e <__umoddi3+0x10e>
  801f74:	8b 14 24             	mov    (%esp),%edx
  801f77:	89 c1                	mov    %eax,%ecx
  801f79:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801f7d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801f81:	eb cb                	jmp    801f4e <__umoddi3+0x10e>
  801f83:	90                   	nop
  801f84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f88:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801f8c:	0f 82 0f ff ff ff    	jb     801ea1 <__umoddi3+0x61>
  801f92:	e9 1a ff ff ff       	jmp    801eb1 <__umoddi3+0x71>
