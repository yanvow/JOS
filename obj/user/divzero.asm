
obj/user/divzero.debug:     file format elf32-i386


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
  80002c:	e8 31 00 00 00       	call   800062 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
  zero = 0;
  800039:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800040:	00 00 00 
  cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	89 44 24 04          	mov    %eax,0x4(%esp)
  800054:	c7 04 24 c0 1f 80 00 	movl   $0x801fc0,(%esp)
  80005b:	e8 06 01 00 00       	call   800166 <cprintf>
}
  800060:	c9                   	leave  
  800061:	c3                   	ret    

00800062 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800062:	55                   	push   %ebp
  800063:	89 e5                	mov    %esp,%ebp
  800065:	56                   	push   %esi
  800066:	53                   	push   %ebx
  800067:	83 ec 10             	sub    $0x10,%esp
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
  // set thisenv to point at our Env structure in envs[].
  // LAB 3: Your code here.
  thisenv = envs + ENVX(sys_getenvid());
  800070:	e8 f0 0a 00 00       	call   800b65 <sys_getenvid>
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 08 40 80 00       	mov    %eax,0x804008

  // save the name of the program so that panic() can use it
  if (argc > 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	7e 07                	jle    800092 <libmain+0x30>
    binaryname = argv[0];
  80008b:	8b 06                	mov    (%esi),%eax
  80008d:	a3 00 30 80 00       	mov    %eax,0x803000

  // call user main routine
  umain(argc, argv);
  800092:	89 74 24 04          	mov    %esi,0x4(%esp)
  800096:	89 1c 24             	mov    %ebx,(%esp)
  800099:	e8 95 ff ff ff       	call   800033 <umain>

  // exit gracefully
  exit();
  80009e:	e8 07 00 00 00       	call   8000aa <exit>
}
  8000a3:	83 c4 10             	add    $0x10,%esp
  8000a6:	5b                   	pop    %ebx
  8000a7:	5e                   	pop    %esi
  8000a8:	5d                   	pop    %ebp
  8000a9:	c3                   	ret    

008000aa <exit>:
#include <inc/lib.h>

void
exit(void)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	83 ec 18             	sub    $0x18,%esp
  close_all();
  8000b0:	e8 30 0f 00 00       	call   800fe5 <close_all>
  sys_env_destroy(0);
  8000b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000bc:	e8 52 0a 00 00       	call   800b13 <sys_env_destroy>
}
  8000c1:	c9                   	leave  
  8000c2:	c3                   	ret    

008000c3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	53                   	push   %ebx
  8000c7:	83 ec 14             	sub    $0x14,%esp
  8000ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  b->buf[b->idx++] = ch;
  8000cd:	8b 13                	mov    (%ebx),%edx
  8000cf:	8d 42 01             	lea    0x1(%edx),%eax
  8000d2:	89 03                	mov    %eax,(%ebx)
  8000d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
  if (b->idx == 256-1) {
  8000db:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e0:	75 19                	jne    8000fb <putch+0x38>
    sys_cputs(b->buf, b->idx);
  8000e2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000e9:	00 
  8000ea:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ed:	89 04 24             	mov    %eax,(%esp)
  8000f0:	e8 e1 09 00 00       	call   800ad6 <sys_cputs>
    b->idx = 0;
  8000f5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  }
  b->cnt++;
  8000fb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000ff:	83 c4 14             	add    $0x14,%esp
  800102:	5b                   	pop    %ebx
  800103:	5d                   	pop    %ebp
  800104:	c3                   	ret    

00800105 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800105:	55                   	push   %ebp
  800106:	89 e5                	mov    %esp,%ebp
  800108:	81 ec 28 01 00 00    	sub    $0x128,%esp
  struct printbuf b;

  b.idx = 0;
  80010e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800115:	00 00 00 
  b.cnt = 0;
  800118:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011f:	00 00 00 
  vprintfmt((void*)putch, &b, fmt, ap);
  800122:	8b 45 0c             	mov    0xc(%ebp),%eax
  800125:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800129:	8b 45 08             	mov    0x8(%ebp),%eax
  80012c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800130:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800136:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013a:	c7 04 24 c3 00 80 00 	movl   $0x8000c3,(%esp)
  800141:	e8 a8 01 00 00       	call   8002ee <vprintfmt>
  sys_cputs(b.buf, b.idx);
  800146:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80014c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800150:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800156:	89 04 24             	mov    %eax,(%esp)
  800159:	e8 78 09 00 00       	call   800ad6 <sys_cputs>

  return b.cnt;
}
  80015e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800164:	c9                   	leave  
  800165:	c3                   	ret    

00800166 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  80016c:	8d 45 0c             	lea    0xc(%ebp),%eax
  cnt = vcprintf(fmt, ap);
  80016f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800173:	8b 45 08             	mov    0x8(%ebp),%eax
  800176:	89 04 24             	mov    %eax,(%esp)
  800179:	e8 87 ff ff ff       	call   800105 <vcprintf>
  va_end(ap);

  return cnt;
}
  80017e:	c9                   	leave  
  80017f:	c3                   	ret    

00800180 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
         unsigned long long num, unsigned base, int width, int padc)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	57                   	push   %edi
  800184:	56                   	push   %esi
  800185:	53                   	push   %ebx
  800186:	83 ec 3c             	sub    $0x3c,%esp
  800189:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80018c:	89 d7                	mov    %edx,%edi
  80018e:	8b 45 08             	mov    0x8(%ebp),%eax
  800191:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800194:	8b 45 0c             	mov    0xc(%ebp),%eax
  800197:	89 c3                	mov    %eax,%ebx
  800199:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80019c:	8b 45 10             	mov    0x10(%ebp),%eax
  80019f:	8b 75 14             	mov    0x14(%ebp),%esi
  // first recursively print all preceding (more significant) digits
  if (num >= base)
  8001a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001ad:	39 d9                	cmp    %ebx,%ecx
  8001af:	72 05                	jb     8001b6 <printnum+0x36>
  8001b1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001b4:	77 69                	ja     80021f <printnum+0x9f>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8001b9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8001bd:	83 ee 01             	sub    $0x1,%esi
  8001c0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001cc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001d0:	89 c3                	mov    %eax,%ebx
  8001d2:	89 d6                	mov    %edx,%esi
  8001d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8001da:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8001e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001e5:	89 04 24             	mov    %eax,(%esp)
  8001e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8001eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ef:	e8 2c 1b 00 00       	call   801d20 <__udivdi3>
  8001f4:	89 d9                	mov    %ebx,%ecx
  8001f6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8001fa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001fe:	89 04 24             	mov    %eax,(%esp)
  800201:	89 54 24 04          	mov    %edx,0x4(%esp)
  800205:	89 fa                	mov    %edi,%edx
  800207:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80020a:	e8 71 ff ff ff       	call   800180 <printnum>
  80020f:	eb 1b                	jmp    80022c <printnum+0xac>
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
      putch(padc, putdat);
  800211:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800215:	8b 45 18             	mov    0x18(%ebp),%eax
  800218:	89 04 24             	mov    %eax,(%esp)
  80021b:	ff d3                	call   *%ebx
  80021d:	eb 03                	jmp    800222 <printnum+0xa2>
  80021f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  // first recursively print all preceding (more significant) digits
  if (num >= base)
    printnum(putch, putdat, num / base, base, width - 1, padc);
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
  800222:	83 ee 01             	sub    $0x1,%esi
  800225:	85 f6                	test   %esi,%esi
  800227:	7f e8                	jg     800211 <printnum+0x91>
  800229:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
      putch(padc, putdat);
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  80022c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800230:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800234:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800237:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80023a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80023e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800242:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800245:	89 04 24             	mov    %eax,(%esp)
  800248:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80024b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024f:	e8 fc 1b 00 00       	call   801e50 <__umoddi3>
  800254:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800258:	0f be 80 d8 1f 80 00 	movsbl 0x801fd8(%eax),%eax
  80025f:	89 04 24             	mov    %eax,(%esp)
  800262:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800265:	ff d0                	call   *%eax
}
  800267:	83 c4 3c             	add    $0x3c,%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  if (lflag >= 2)
  800272:	83 fa 01             	cmp    $0x1,%edx
  800275:	7e 0e                	jle    800285 <getuint+0x16>
    return va_arg(*ap, unsigned long long);
  800277:	8b 10                	mov    (%eax),%edx
  800279:	8d 4a 08             	lea    0x8(%edx),%ecx
  80027c:	89 08                	mov    %ecx,(%eax)
  80027e:	8b 02                	mov    (%edx),%eax
  800280:	8b 52 04             	mov    0x4(%edx),%edx
  800283:	eb 22                	jmp    8002a7 <getuint+0x38>
  else if (lflag)
  800285:	85 d2                	test   %edx,%edx
  800287:	74 10                	je     800299 <getuint+0x2a>
    return va_arg(*ap, unsigned long);
  800289:	8b 10                	mov    (%eax),%edx
  80028b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028e:	89 08                	mov    %ecx,(%eax)
  800290:	8b 02                	mov    (%edx),%eax
  800292:	ba 00 00 00 00       	mov    $0x0,%edx
  800297:	eb 0e                	jmp    8002a7 <getuint+0x38>
  else
    return va_arg(*ap, unsigned int);
  800299:	8b 10                	mov    (%eax),%edx
  80029b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029e:	89 08                	mov    %ecx,(%eax)
  8002a0:	8b 02                	mov    (%edx),%eax
  8002a2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  b->cnt++;
  8002af:	83 40 08 01          	addl   $0x1,0x8(%eax)
  if (b->buf < b->ebuf)
  8002b3:	8b 10                	mov    (%eax),%edx
  8002b5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b8:	73 0a                	jae    8002c4 <sprintputch+0x1b>
    *b->buf++ = ch;
  8002ba:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002bd:	89 08                	mov    %ecx,(%eax)
  8002bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c2:	88 02                	mov    %al,(%edx)
}
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <printfmt>:
  }
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	83 ec 18             	sub    $0x18,%esp
  va_list ap;

  va_start(ap, fmt);
  8002cc:	8d 45 14             	lea    0x14(%ebp),%eax
  vprintfmt(putch, putdat, fmt, ap);
  8002cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e4:	89 04 24             	mov    %eax,(%esp)
  8002e7:	e8 02 00 00 00       	call   8002ee <vprintfmt>
  va_end(ap);
}
  8002ec:	c9                   	leave  
  8002ed:	c3                   	ret    

008002ee <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	57                   	push   %edi
  8002f2:	56                   	push   %esi
  8002f3:	53                   	push   %ebx
  8002f4:	83 ec 3c             	sub    $0x3c,%esp
  8002f7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fd:	eb 14                	jmp    800313 <vprintfmt+0x25>
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
      if (ch == '\0')
  8002ff:	85 c0                	test   %eax,%eax
  800301:	0f 84 b3 03 00 00    	je     8006ba <vprintfmt+0x3cc>
        return;
      putch(ch, putdat);
  800307:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80030b:	89 04 24             	mov    %eax,(%esp)
  80030e:	ff 55 08             	call   *0x8(%ebp)
  unsigned long long num;
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
  800311:	89 f3                	mov    %esi,%ebx
  800313:	8d 73 01             	lea    0x1(%ebx),%esi
  800316:	0f b6 03             	movzbl (%ebx),%eax
  800319:	83 f8 25             	cmp    $0x25,%eax
  80031c:	75 e1                	jne    8002ff <vprintfmt+0x11>
  80031e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800322:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800329:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800330:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800337:	ba 00 00 00 00       	mov    $0x0,%edx
  80033c:	eb 1d                	jmp    80035b <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80033e:	89 de                	mov    %ebx,%esi

    // flag to pad on the right
    case '-':
      padc = '-';
  800340:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800344:	eb 15                	jmp    80035b <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  800346:	89 de                	mov    %ebx,%esi
      padc = '-';
      goto reswitch;

    // flag to pad with 0's instead of spaces
    case '0':
      padc = '0';
  800348:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80034c:	eb 0d                	jmp    80035b <vprintfmt+0x6d>
      altflag = 1;
      goto reswitch;

process_precision:
      if (width < 0)
        width = precision, precision = -1;
  80034e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800351:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800354:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80035b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80035e:	0f b6 0e             	movzbl (%esi),%ecx
  800361:	0f b6 c1             	movzbl %cl,%eax
  800364:	83 e9 23             	sub    $0x23,%ecx
  800367:	80 f9 55             	cmp    $0x55,%cl
  80036a:	0f 87 2a 03 00 00    	ja     80069a <vprintfmt+0x3ac>
  800370:	0f b6 c9             	movzbl %cl,%ecx
  800373:	ff 24 8d 20 21 80 00 	jmp    *0x802120(,%ecx,4)
  80037a:	89 de                	mov    %ebx,%esi
  80037c:	b9 00 00 00 00       	mov    $0x0,%ecx
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
        precision = precision * 10 + ch - '0';
  800381:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800384:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
        ch = *fmt;
  800388:	0f be 06             	movsbl (%esi),%eax
        if (ch < '0' || ch > '9')
  80038b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80038e:	83 fb 09             	cmp    $0x9,%ebx
  800391:	77 36                	ja     8003c9 <vprintfmt+0xdb>
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
  800393:	83 c6 01             	add    $0x1,%esi
        precision = precision * 10 + ch - '0';
        ch = *fmt;
        if (ch < '0' || ch > '9')
          break;
      }
  800396:	eb e9                	jmp    800381 <vprintfmt+0x93>
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
  800398:	8b 45 14             	mov    0x14(%ebp),%eax
  80039b:	8d 48 04             	lea    0x4(%eax),%ecx
  80039e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003a1:	8b 00                	mov    (%eax),%eax
  8003a3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8003a6:	89 de                	mov    %ebx,%esi
      }
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
      goto process_precision;
  8003a8:	eb 22                	jmp    8003cc <vprintfmt+0xde>
  8003aa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8003ad:	85 c9                	test   %ecx,%ecx
  8003af:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b4:	0f 49 c1             	cmovns %ecx,%eax
  8003b7:	89 45 dc             	mov    %eax,-0x24(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8003ba:	89 de                	mov    %ebx,%esi
  8003bc:	eb 9d                	jmp    80035b <vprintfmt+0x6d>
  8003be:	89 de                	mov    %ebx,%esi
      if (width < 0)
        width = 0;
      goto reswitch;

    case '#':
      altflag = 1;
  8003c0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
      goto reswitch;
  8003c7:	eb 92                	jmp    80035b <vprintfmt+0x6d>
  8003c9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

process_precision:
      if (width < 0)
  8003cc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8003d0:	79 89                	jns    80035b <vprintfmt+0x6d>
  8003d2:	e9 77 ff ff ff       	jmp    80034e <vprintfmt+0x60>
        width = precision, precision = -1;
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
  8003d7:	83 c2 01             	add    $0x1,%edx
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8003da:	89 de                	mov    %ebx,%esi
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
      goto reswitch;
  8003dc:	e9 7a ff ff ff       	jmp    80035b <vprintfmt+0x6d>

    // character
    case 'c':
      putch(va_arg(ap, int), putdat);
  8003e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e4:	8d 50 04             	lea    0x4(%eax),%edx
  8003e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ea:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003ee:	8b 00                	mov    (%eax),%eax
  8003f0:	89 04 24             	mov    %eax,(%esp)
  8003f3:	ff 55 08             	call   *0x8(%ebp)
      break;
  8003f6:	e9 18 ff ff ff       	jmp    800313 <vprintfmt+0x25>

    // error message
    case 'e':
      err = va_arg(ap, int);
  8003fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fe:	8d 50 04             	lea    0x4(%eax),%edx
  800401:	89 55 14             	mov    %edx,0x14(%ebp)
  800404:	8b 00                	mov    (%eax),%eax
  800406:	99                   	cltd   
  800407:	31 d0                	xor    %edx,%eax
  800409:	29 d0                	sub    %edx,%eax
      if (err < 0)
        err = -err;
      if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80040b:	83 f8 0f             	cmp    $0xf,%eax
  80040e:	7f 0b                	jg     80041b <vprintfmt+0x12d>
  800410:	8b 14 85 80 22 80 00 	mov    0x802280(,%eax,4),%edx
  800417:	85 d2                	test   %edx,%edx
  800419:	75 20                	jne    80043b <vprintfmt+0x14d>
        printfmt(putch, putdat, "error %d", err);
  80041b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80041f:	c7 44 24 08 f0 1f 80 	movl   $0x801ff0,0x8(%esp)
  800426:	00 
  800427:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80042b:	8b 45 08             	mov    0x8(%ebp),%eax
  80042e:	89 04 24             	mov    %eax,(%esp)
  800431:	e8 90 fe ff ff       	call   8002c6 <printfmt>
  800436:	e9 d8 fe ff ff       	jmp    800313 <vprintfmt+0x25>
      else
        printfmt(putch, putdat, "%s", p);
  80043b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80043f:	c7 44 24 08 f9 1f 80 	movl   $0x801ff9,0x8(%esp)
  800446:	00 
  800447:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80044b:	8b 45 08             	mov    0x8(%ebp),%eax
  80044e:	89 04 24             	mov    %eax,(%esp)
  800451:	e8 70 fe ff ff       	call   8002c6 <printfmt>
  800456:	e9 b8 fe ff ff       	jmp    800313 <vprintfmt+0x25>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80045b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80045e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800461:	89 45 d0             	mov    %eax,-0x30(%ebp)
        printfmt(putch, putdat, "%s", p);
      break;

    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
  800464:	8b 45 14             	mov    0x14(%ebp),%eax
  800467:	8d 50 04             	lea    0x4(%eax),%edx
  80046a:	89 55 14             	mov    %edx,0x14(%ebp)
  80046d:	8b 30                	mov    (%eax),%esi
        p = "(null)";
  80046f:	85 f6                	test   %esi,%esi
  800471:	b8 e9 1f 80 00       	mov    $0x801fe9,%eax
  800476:	0f 44 f0             	cmove  %eax,%esi
      if (width > 0 && padc != '-')
  800479:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80047d:	0f 84 97 00 00 00    	je     80051a <vprintfmt+0x22c>
  800483:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800487:	0f 8e 9b 00 00 00    	jle    800528 <vprintfmt+0x23a>
        for (width -= strnlen(p, precision); width > 0; width--)
  80048d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800491:	89 34 24             	mov    %esi,(%esp)
  800494:	e8 cf 02 00 00       	call   800768 <strnlen>
  800499:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80049c:	29 c2                	sub    %eax,%edx
  80049e:	89 55 d0             	mov    %edx,-0x30(%ebp)
          putch(padc, putdat);
  8004a1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004a5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004a8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8004ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ae:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004b1:	89 d3                	mov    %edx,%ebx
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
  8004b3:	eb 0f                	jmp    8004c4 <vprintfmt+0x1d6>
          putch(padc, putdat);
  8004b5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004b9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004bc:	89 04 24             	mov    %eax,(%esp)
  8004bf:	ff d6                	call   *%esi
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
  8004c1:	83 eb 01             	sub    $0x1,%ebx
  8004c4:	85 db                	test   %ebx,%ebx
  8004c6:	7f ed                	jg     8004b5 <vprintfmt+0x1c7>
  8004c8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004cb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004ce:	85 d2                	test   %edx,%edx
  8004d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d5:	0f 49 c2             	cmovns %edx,%eax
  8004d8:	29 c2                	sub    %eax,%edx
  8004da:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8004dd:	89 d7                	mov    %edx,%edi
  8004df:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8004e2:	eb 50                	jmp    800534 <vprintfmt+0x246>
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
  8004e4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e8:	74 1e                	je     800508 <vprintfmt+0x21a>
  8004ea:	0f be d2             	movsbl %dl,%edx
  8004ed:	83 ea 20             	sub    $0x20,%edx
  8004f0:	83 fa 5e             	cmp    $0x5e,%edx
  8004f3:	76 13                	jbe    800508 <vprintfmt+0x21a>
          putch('?', putdat);
  8004f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004fc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800503:	ff 55 08             	call   *0x8(%ebp)
  800506:	eb 0d                	jmp    800515 <vprintfmt+0x227>
        else
          putch(ch, putdat);
  800508:	8b 55 0c             	mov    0xc(%ebp),%edx
  80050b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80050f:	89 04 24             	mov    %eax,(%esp)
  800512:	ff 55 08             	call   *0x8(%ebp)
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800515:	83 ef 01             	sub    $0x1,%edi
  800518:	eb 1a                	jmp    800534 <vprintfmt+0x246>
  80051a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80051d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800520:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800523:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800526:	eb 0c                	jmp    800534 <vprintfmt+0x246>
  800528:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80052b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80052e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800531:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800534:	83 c6 01             	add    $0x1,%esi
  800537:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80053b:	0f be c2             	movsbl %dl,%eax
  80053e:	85 c0                	test   %eax,%eax
  800540:	74 27                	je     800569 <vprintfmt+0x27b>
  800542:	85 db                	test   %ebx,%ebx
  800544:	78 9e                	js     8004e4 <vprintfmt+0x1f6>
  800546:	83 eb 01             	sub    $0x1,%ebx
  800549:	79 99                	jns    8004e4 <vprintfmt+0x1f6>
  80054b:	89 f8                	mov    %edi,%eax
  80054d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800550:	8b 75 08             	mov    0x8(%ebp),%esi
  800553:	89 c3                	mov    %eax,%ebx
  800555:	eb 1a                	jmp    800571 <vprintfmt+0x283>
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
        putch(' ', putdat);
  800557:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80055b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800562:	ff d6                	call   *%esi
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
  800564:	83 eb 01             	sub    $0x1,%ebx
  800567:	eb 08                	jmp    800571 <vprintfmt+0x283>
  800569:	89 fb                	mov    %edi,%ebx
  80056b:	8b 75 08             	mov    0x8(%ebp),%esi
  80056e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800571:	85 db                	test   %ebx,%ebx
  800573:	7f e2                	jg     800557 <vprintfmt+0x269>
  800575:	89 75 08             	mov    %esi,0x8(%ebp)
  800578:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80057b:	e9 93 fd ff ff       	jmp    800313 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  if (lflag >= 2)
  800580:	83 fa 01             	cmp    $0x1,%edx
  800583:	7e 16                	jle    80059b <vprintfmt+0x2ad>
    return va_arg(*ap, long long);
  800585:	8b 45 14             	mov    0x14(%ebp),%eax
  800588:	8d 50 08             	lea    0x8(%eax),%edx
  80058b:	89 55 14             	mov    %edx,0x14(%ebp)
  80058e:	8b 50 04             	mov    0x4(%eax),%edx
  800591:	8b 00                	mov    (%eax),%eax
  800593:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800596:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800599:	eb 32                	jmp    8005cd <vprintfmt+0x2df>
  else if (lflag)
  80059b:	85 d2                	test   %edx,%edx
  80059d:	74 18                	je     8005b7 <vprintfmt+0x2c9>
    return va_arg(*ap, long);
  80059f:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a2:	8d 50 04             	lea    0x4(%eax),%edx
  8005a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a8:	8b 30                	mov    (%eax),%esi
  8005aa:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005ad:	89 f0                	mov    %esi,%eax
  8005af:	c1 f8 1f             	sar    $0x1f,%eax
  8005b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005b5:	eb 16                	jmp    8005cd <vprintfmt+0x2df>
  else
    return va_arg(*ap, int);
  8005b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ba:	8d 50 04             	lea    0x4(%eax),%edx
  8005bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c0:	8b 30                	mov    (%eax),%esi
  8005c2:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005c5:	89 f0                	mov    %esi,%eax
  8005c7:	c1 f8 1f             	sar    $0x1f,%eax
  8005ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        putch(' ', putdat);
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
  8005cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      if ((long long)num < 0) {
        putch('-', putdat);
        num = -(long long)num;
      }
      base = 10;
  8005d3:	b9 0a 00 00 00       	mov    $0xa,%ecx
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
      if ((long long)num < 0) {
  8005d8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005dc:	0f 89 80 00 00 00    	jns    800662 <vprintfmt+0x374>
        putch('-', putdat);
  8005e2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005ed:	ff 55 08             	call   *0x8(%ebp)
        num = -(long long)num;
  8005f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005f3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f6:	f7 d8                	neg    %eax
  8005f8:	83 d2 00             	adc    $0x0,%edx
  8005fb:	f7 da                	neg    %edx
      }
      base = 10;
  8005fd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800602:	eb 5e                	jmp    800662 <vprintfmt+0x374>
      goto number;

    // unsigned decimal
    case 'u':
      num = getuint(&ap, lflag);
  800604:	8d 45 14             	lea    0x14(%ebp),%eax
  800607:	e8 63 fc ff ff       	call   80026f <getuint>
      base = 10;
  80060c:	b9 0a 00 00 00       	mov    $0xa,%ecx
      goto number;
  800611:	eb 4f                	jmp    800662 <vprintfmt+0x374>

    // (unsigned) octal
    case 'o':
      num = getuint(&ap, lflag);
  800613:	8d 45 14             	lea    0x14(%ebp),%eax
  800616:	e8 54 fc ff ff       	call   80026f <getuint>
      base = 8;
  80061b:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800620:	eb 40                	jmp    800662 <vprintfmt+0x374>

    // pointer
    case 'p':
      putch('0', putdat);
  800622:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800626:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80062d:	ff 55 08             	call   *0x8(%ebp)
      putch('x', putdat);
  800630:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800634:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80063b:	ff 55 08             	call   *0x8(%ebp)
      num = (unsigned long long)
            (uintptr_t)va_arg(ap, void *);
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8d 50 04             	lea    0x4(%eax),%edx
  800644:	89 55 14             	mov    %edx,0x14(%ebp)

    // pointer
    case 'p':
      putch('0', putdat);
      putch('x', putdat);
      num = (unsigned long long)
  800647:	8b 00                	mov    (%eax),%eax
  800649:	ba 00 00 00 00       	mov    $0x0,%edx
            (uintptr_t)va_arg(ap, void *);
      base = 16;
  80064e:	b9 10 00 00 00       	mov    $0x10,%ecx
      goto number;
  800653:	eb 0d                	jmp    800662 <vprintfmt+0x374>

    // (unsigned) hexadecimal
    case 'x':
      num = getuint(&ap, lflag);
  800655:	8d 45 14             	lea    0x14(%ebp),%eax
  800658:	e8 12 fc ff ff       	call   80026f <getuint>
      base = 16;
  80065d:	b9 10 00 00 00       	mov    $0x10,%ecx
number:
      printnum(putch, putdat, num, base, width, padc);
  800662:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800666:	89 74 24 10          	mov    %esi,0x10(%esp)
  80066a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80066d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800671:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800675:	89 04 24             	mov    %eax,(%esp)
  800678:	89 54 24 04          	mov    %edx,0x4(%esp)
  80067c:	89 fa                	mov    %edi,%edx
  80067e:	8b 45 08             	mov    0x8(%ebp),%eax
  800681:	e8 fa fa ff ff       	call   800180 <printnum>
      break;
  800686:	e9 88 fc ff ff       	jmp    800313 <vprintfmt+0x25>

    // escaped '%' character
    case '%':
      putch(ch, putdat);
  80068b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80068f:	89 04 24             	mov    %eax,(%esp)
  800692:	ff 55 08             	call   *0x8(%ebp)
      break;
  800695:	e9 79 fc ff ff       	jmp    800313 <vprintfmt+0x25>

    // unrecognized escape sequence - just print it literally
    default:
      putch('%', putdat);
  80069a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80069e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006a5:	ff 55 08             	call   *0x8(%ebp)
      for (fmt--; fmt[-1] != '%'; fmt--)
  8006a8:	89 f3                	mov    %esi,%ebx
  8006aa:	eb 03                	jmp    8006af <vprintfmt+0x3c1>
  8006ac:	83 eb 01             	sub    $0x1,%ebx
  8006af:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8006b3:	75 f7                	jne    8006ac <vprintfmt+0x3be>
  8006b5:	e9 59 fc ff ff       	jmp    800313 <vprintfmt+0x25>
        /* do nothing */;
      break;
    }
  }
}
  8006ba:	83 c4 3c             	add    $0x3c,%esp
  8006bd:	5b                   	pop    %ebx
  8006be:	5e                   	pop    %esi
  8006bf:	5f                   	pop    %edi
  8006c0:	5d                   	pop    %ebp
  8006c1:	c3                   	ret    

008006c2 <vsnprintf>:
    *b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006c2:	55                   	push   %ebp
  8006c3:	89 e5                	mov    %esp,%ebp
  8006c5:	83 ec 28             	sub    $0x28,%esp
  8006c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  struct sprintbuf b = { buf, buf+n-1, 0 };
  8006ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006d1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  if (buf == NULL || n < 1)
  8006df:	85 c0                	test   %eax,%eax
  8006e1:	74 30                	je     800713 <vsnprintf+0x51>
  8006e3:	85 d2                	test   %edx,%edx
  8006e5:	7e 2c                	jle    800713 <vsnprintf+0x51>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006fc:	c7 04 24 a9 02 80 00 	movl   $0x8002a9,(%esp)
  800703:	e8 e6 fb ff ff       	call   8002ee <vprintfmt>

  // null terminate the buffer
  *b.buf = '\0';
  800708:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80070b:	c6 00 00             	movb   $0x0,(%eax)

  return b.cnt;
  80070e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800711:	eb 05                	jmp    800718 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  struct sprintbuf b = { buf, buf+n-1, 0 };

  if (buf == NULL || n < 1)
    return -E_INVAL;
  800713:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

  // null terminate the buffer
  *b.buf = '\0';

  return b.cnt;
}
  800718:	c9                   	leave  
  800719:	c3                   	ret    

0080071a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80071a:	55                   	push   %ebp
  80071b:	89 e5                	mov    %esp,%ebp
  80071d:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800720:	8d 45 14             	lea    0x14(%ebp),%eax
  rc = vsnprintf(buf, n, fmt, ap);
  800723:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800727:	8b 45 10             	mov    0x10(%ebp),%eax
  80072a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80072e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800731:	89 44 24 04          	mov    %eax,0x4(%esp)
  800735:	8b 45 08             	mov    0x8(%ebp),%eax
  800738:	89 04 24             	mov    %eax,(%esp)
  80073b:	e8 82 ff ff ff       	call   8006c2 <vsnprintf>
  va_end(ap);

  return rc;
}
  800740:	c9                   	leave  
  800741:	c3                   	ret    
  800742:	66 90                	xchg   %ax,%ax
  800744:	66 90                	xchg   %ax,%ax
  800746:	66 90                	xchg   %ax,%ax
  800748:	66 90                	xchg   %ax,%ax
  80074a:	66 90                	xchg   %ax,%ax
  80074c:	66 90                	xchg   %ax,%ax
  80074e:	66 90                	xchg   %ax,%ax

00800750 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for (n = 0; *s != '\0'; s++)
  800756:	b8 00 00 00 00       	mov    $0x0,%eax
  80075b:	eb 03                	jmp    800760 <strlen+0x10>
    n++;
  80075d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
  int n;

  for (n = 0; *s != '\0'; s++)
  800760:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800764:	75 f7                	jne    80075d <strlen+0xd>
    n++;
  return n;
}
  800766:	5d                   	pop    %ebp
  800767:	c3                   	ret    

00800768 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80076e:	8b 55 0c             	mov    0xc(%ebp),%edx
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800771:	b8 00 00 00 00       	mov    $0x0,%eax
  800776:	eb 03                	jmp    80077b <strnlen+0x13>
    n++;
  800778:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077b:	39 d0                	cmp    %edx,%eax
  80077d:	74 06                	je     800785 <strnlen+0x1d>
  80077f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800783:	75 f3                	jne    800778 <strnlen+0x10>
    n++;
  return n;
}
  800785:	5d                   	pop    %ebp
  800786:	c3                   	ret    

00800787 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	53                   	push   %ebx
  80078b:	8b 45 08             	mov    0x8(%ebp),%eax
  80078e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800791:	89 c2                	mov    %eax,%edx
  800793:	83 c2 01             	add    $0x1,%edx
  800796:	83 c1 01             	add    $0x1,%ecx
  800799:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80079d:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007a0:	84 db                	test   %bl,%bl
  8007a2:	75 ef                	jne    800793 <strcpy+0xc>
    /* do nothing */;
  return ret;
}
  8007a4:	5b                   	pop    %ebx
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	53                   	push   %ebx
  8007ab:	83 ec 08             	sub    $0x8,%esp
  8007ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int len = strlen(dst);
  8007b1:	89 1c 24             	mov    %ebx,(%esp)
  8007b4:	e8 97 ff ff ff       	call   800750 <strlen>

  strcpy(dst + len, src);
  8007b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007bc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007c0:	01 d8                	add    %ebx,%eax
  8007c2:	89 04 24             	mov    %eax,(%esp)
  8007c5:	e8 bd ff ff ff       	call   800787 <strcpy>
  return dst;
}
  8007ca:	89 d8                	mov    %ebx,%eax
  8007cc:	83 c4 08             	add    $0x8,%esp
  8007cf:	5b                   	pop    %ebx
  8007d0:	5d                   	pop    %ebp
  8007d1:	c3                   	ret    

008007d2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	56                   	push   %esi
  8007d6:	53                   	push   %ebx
  8007d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007dd:	89 f3                	mov    %esi,%ebx
  8007df:	03 5d 10             	add    0x10(%ebp),%ebx
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  8007e2:	89 f2                	mov    %esi,%edx
  8007e4:	eb 0f                	jmp    8007f5 <strncpy+0x23>
    *dst++ = *src;
  8007e6:	83 c2 01             	add    $0x1,%edx
  8007e9:	0f b6 01             	movzbl (%ecx),%eax
  8007ec:	88 42 ff             	mov    %al,-0x1(%edx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  8007ef:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f2:	83 d9 ff             	sbb    $0xffffffff,%ecx
{
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  8007f5:	39 da                	cmp    %ebx,%edx
  8007f7:	75 ed                	jne    8007e6 <strncpy+0x14>
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  }
  return ret;
}
  8007f9:	89 f0                	mov    %esi,%eax
  8007fb:	5b                   	pop    %ebx
  8007fc:	5e                   	pop    %esi
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	56                   	push   %esi
  800803:	53                   	push   %ebx
  800804:	8b 75 08             	mov    0x8(%ebp),%esi
  800807:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80080d:	89 f0                	mov    %esi,%eax
  80080f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800813:	85 c9                	test   %ecx,%ecx
  800815:	75 0b                	jne    800822 <strlcpy+0x23>
  800817:	eb 1d                	jmp    800836 <strlcpy+0x37>
    while (--size > 0 && *src != '\0')
      *dst++ = *src++;
  800819:	83 c0 01             	add    $0x1,%eax
  80081c:	83 c2 01             	add    $0x1,%edx
  80081f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
    while (--size > 0 && *src != '\0')
  800822:	39 d8                	cmp    %ebx,%eax
  800824:	74 0b                	je     800831 <strlcpy+0x32>
  800826:	0f b6 0a             	movzbl (%edx),%ecx
  800829:	84 c9                	test   %cl,%cl
  80082b:	75 ec                	jne    800819 <strlcpy+0x1a>
  80082d:	89 c2                	mov    %eax,%edx
  80082f:	eb 02                	jmp    800833 <strlcpy+0x34>
  800831:	89 c2                	mov    %eax,%edx
      *dst++ = *src++;
    *dst = '\0';
  800833:	c6 02 00             	movb   $0x0,(%edx)
  }
  return dst - dst_in;
  800836:	29 f0                	sub    %esi,%eax
}
  800838:	5b                   	pop    %ebx
  800839:	5e                   	pop    %esi
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800842:	8b 55 0c             	mov    0xc(%ebp),%edx
  while (*p && *p == *q)
  800845:	eb 06                	jmp    80084d <strcmp+0x11>
    p++, q++;
  800847:	83 c1 01             	add    $0x1,%ecx
  80084a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
  while (*p && *p == *q)
  80084d:	0f b6 01             	movzbl (%ecx),%eax
  800850:	84 c0                	test   %al,%al
  800852:	74 04                	je     800858 <strcmp+0x1c>
  800854:	3a 02                	cmp    (%edx),%al
  800856:	74 ef                	je     800847 <strcmp+0xb>
    p++, q++;
  return (int)((unsigned char)*p - (unsigned char)*q);
  800858:	0f b6 c0             	movzbl %al,%eax
  80085b:	0f b6 12             	movzbl (%edx),%edx
  80085e:	29 d0                	sub    %edx,%eax
}
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	53                   	push   %ebx
  800866:	8b 45 08             	mov    0x8(%ebp),%eax
  800869:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086c:	89 c3                	mov    %eax,%ebx
  80086e:	03 5d 10             	add    0x10(%ebp),%ebx
  while (n > 0 && *p && *p == *q)
  800871:	eb 06                	jmp    800879 <strncmp+0x17>
    n--, p++, q++;
  800873:	83 c0 01             	add    $0x1,%eax
  800876:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
  800879:	39 d8                	cmp    %ebx,%eax
  80087b:	74 15                	je     800892 <strncmp+0x30>
  80087d:	0f b6 08             	movzbl (%eax),%ecx
  800880:	84 c9                	test   %cl,%cl
  800882:	74 04                	je     800888 <strncmp+0x26>
  800884:	3a 0a                	cmp    (%edx),%cl
  800886:	74 eb                	je     800873 <strncmp+0x11>
    n--, p++, q++;
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800888:	0f b6 00             	movzbl (%eax),%eax
  80088b:	0f b6 12             	movzbl (%edx),%edx
  80088e:	29 d0                	sub    %edx,%eax
  800890:	eb 05                	jmp    800897 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
    n--, p++, q++;
  if (n == 0)
    return 0;
  800892:	b8 00 00 00 00       	mov    $0x0,%eax
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
}
  800897:	5b                   	pop    %ebx
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
  8008a4:	eb 07                	jmp    8008ad <strchr+0x13>
    if (*s == c)
  8008a6:	38 ca                	cmp    %cl,%dl
  8008a8:	74 0f                	je     8008b9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  for (; *s; s++)
  8008aa:	83 c0 01             	add    $0x1,%eax
  8008ad:	0f b6 10             	movzbl (%eax),%edx
  8008b0:	84 d2                	test   %dl,%dl
  8008b2:	75 f2                	jne    8008a6 <strchr+0xc>
    if (*s == c)
      return (char*)s;
  return 0;
  8008b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
  8008c5:	eb 07                	jmp    8008ce <strfind+0x13>
    if (*s == c)
  8008c7:	38 ca                	cmp    %cl,%dl
  8008c9:	74 0a                	je     8008d5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  for (; *s; s++)
  8008cb:	83 c0 01             	add    $0x1,%eax
  8008ce:	0f b6 10             	movzbl (%eax),%edx
  8008d1:	84 d2                	test   %dl,%dl
  8008d3:	75 f2                	jne    8008c7 <strfind+0xc>
    if (*s == c)
      break;
  return (char*)s;
}
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	57                   	push   %edi
  8008db:	56                   	push   %esi
  8008dc:	53                   	push   %ebx
  8008dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *p;

  if (n == 0)
  8008e3:	85 c9                	test   %ecx,%ecx
  8008e5:	74 36                	je     80091d <memset+0x46>
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
  8008e7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ed:	75 28                	jne    800917 <memset+0x40>
  8008ef:	f6 c1 03             	test   $0x3,%cl
  8008f2:	75 23                	jne    800917 <memset+0x40>
    c &= 0xFF;
  8008f4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
    c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f8:	89 d3                	mov    %edx,%ebx
  8008fa:	c1 e3 08             	shl    $0x8,%ebx
  8008fd:	89 d6                	mov    %edx,%esi
  8008ff:	c1 e6 18             	shl    $0x18,%esi
  800902:	89 d0                	mov    %edx,%eax
  800904:	c1 e0 10             	shl    $0x10,%eax
  800907:	09 f0                	or     %esi,%eax
  800909:	09 c2                	or     %eax,%edx
  80090b:	89 d0                	mov    %edx,%eax
  80090d:	09 d8                	or     %ebx,%eax
    asm volatile ("cld; rep stosl\n"
                  :: "D" (v), "a" (c), "c" (n/4)
  80090f:	c1 e9 02             	shr    $0x2,%ecx
  if (n == 0)
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
    c &= 0xFF;
    c = (c<<24)|(c<<16)|(c<<8)|c;
    asm volatile ("cld; rep stosl\n"
  800912:	fc                   	cld    
  800913:	f3 ab                	rep stos %eax,%es:(%edi)
  800915:	eb 06                	jmp    80091d <memset+0x46>
                  :: "D" (v), "a" (c), "c" (n/4)
                  : "cc", "memory");
  } else
    asm volatile ("cld; rep stosb\n"
  800917:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091a:	fc                   	cld    
  80091b:	f3 aa                	rep stos %al,%es:(%edi)
                  :: "D" (v), "a" (c), "c" (n)
                  : "cc", "memory");
  return v;
}
  80091d:	89 f8                	mov    %edi,%eax
  80091f:	5b                   	pop    %ebx
  800920:	5e                   	pop    %esi
  800921:	5f                   	pop    %edi
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	57                   	push   %edi
  800928:	56                   	push   %esi
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800932:	39 c6                	cmp    %eax,%esi
  800934:	73 35                	jae    80096b <memmove+0x47>
  800936:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800939:	39 d0                	cmp    %edx,%eax
  80093b:	73 2e                	jae    80096b <memmove+0x47>
    s += n;
    d += n;
  80093d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800940:	89 d6                	mov    %edx,%esi
  800942:	09 fe                	or     %edi,%esi
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800944:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094a:	75 13                	jne    80095f <memmove+0x3b>
  80094c:	f6 c1 03             	test   $0x3,%cl
  80094f:	75 0e                	jne    80095f <memmove+0x3b>
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800951:	83 ef 04             	sub    $0x4,%edi
  800954:	8d 72 fc             	lea    -0x4(%edx),%esi
  800957:	c1 e9 02             	shr    $0x2,%ecx
  d = dst;
  if (s < d && s + n > d) {
    s += n;
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
  80095a:	fd                   	std    
  80095b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095d:	eb 09                	jmp    800968 <memmove+0x44>
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80095f:	83 ef 01             	sub    $0x1,%edi
  800962:	8d 72 ff             	lea    -0x1(%edx),%esi
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
  800965:	fd                   	std    
  800966:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  800968:	fc                   	cld    
  800969:	eb 1d                	jmp    800988 <memmove+0x64>
  80096b:	89 f2                	mov    %esi,%edx
  80096d:	09 c2                	or     %eax,%edx
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096f:	f6 c2 03             	test   $0x3,%dl
  800972:	75 0f                	jne    800983 <memmove+0x5f>
  800974:	f6 c1 03             	test   $0x3,%cl
  800977:	75 0a                	jne    800983 <memmove+0x5f>
      asm volatile ("cld; rep movsl\n"
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800979:	c1 e9 02             	shr    $0x2,%ecx
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("cld; rep movsl\n"
  80097c:	89 c7                	mov    %eax,%edi
  80097e:	fc                   	cld    
  80097f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800981:	eb 05                	jmp    800988 <memmove+0x64>
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("cld; rep movsb\n"
  800983:	89 c7                	mov    %eax,%edi
  800985:	fc                   	cld    
  800986:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d), "S" (s), "c" (n) : "cc", "memory");
  }
  return dst;
}
  800988:	5e                   	pop    %esi
  800989:	5f                   	pop    %edi
  80098a:	5d                   	pop    %ebp
  80098b:	c3                   	ret    

0080098c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
  800992:	8b 45 10             	mov    0x10(%ebp),%eax
  800995:	89 44 24 08          	mov    %eax,0x8(%esp)
  800999:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a3:	89 04 24             	mov    %eax,(%esp)
  8009a6:	e8 79 ff ff ff       	call   800924 <memmove>
}
  8009ab:	c9                   	leave  
  8009ac:	c3                   	ret    

008009ad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	56                   	push   %esi
  8009b1:	53                   	push   %ebx
  8009b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8009b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b8:	89 d6                	mov    %edx,%esi
  8009ba:	03 75 10             	add    0x10(%ebp),%esi
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
  8009bd:	eb 1a                	jmp    8009d9 <memcmp+0x2c>
    if (*s1 != *s2)
  8009bf:	0f b6 02             	movzbl (%edx),%eax
  8009c2:	0f b6 19             	movzbl (%ecx),%ebx
  8009c5:	38 d8                	cmp    %bl,%al
  8009c7:	74 0a                	je     8009d3 <memcmp+0x26>
      return (int)*s1 - (int)*s2;
  8009c9:	0f b6 c0             	movzbl %al,%eax
  8009cc:	0f b6 db             	movzbl %bl,%ebx
  8009cf:	29 d8                	sub    %ebx,%eax
  8009d1:	eb 0f                	jmp    8009e2 <memcmp+0x35>
    s1++, s2++;
  8009d3:	83 c2 01             	add    $0x1,%edx
  8009d6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
  8009d9:	39 f2                	cmp    %esi,%edx
  8009db:	75 e2                	jne    8009bf <memcmp+0x12>
    if (*s1 != *s2)
      return (int)*s1 - (int)*s2;
    s1++, s2++;
  }

  return 0;
  8009dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e2:	5b                   	pop    %ebx
  8009e3:	5e                   	pop    %esi
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  const void *ends = (const char*)s + n;
  8009ef:	89 c2                	mov    %eax,%edx
  8009f1:	03 55 10             	add    0x10(%ebp),%edx

  for (; s < ends; s++)
  8009f4:	eb 07                	jmp    8009fd <memfind+0x17>
    if (*(const unsigned char*)s == (unsigned char)c)
  8009f6:	38 08                	cmp    %cl,(%eax)
  8009f8:	74 07                	je     800a01 <memfind+0x1b>
void *
memfind(const void *s, int c, size_t n)
{
  const void *ends = (const char*)s + n;

  for (; s < ends; s++)
  8009fa:	83 c0 01             	add    $0x1,%eax
  8009fd:	39 d0                	cmp    %edx,%eax
  8009ff:	72 f5                	jb     8009f6 <memfind+0x10>
    if (*(const unsigned char*)s == (unsigned char)c)
      break;
  return (void*)s;
}
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	57                   	push   %edi
  800a07:	56                   	push   %esi
  800a08:	53                   	push   %ebx
  800a09:	8b 55 08             	mov    0x8(%ebp),%edx
  800a0c:	8b 45 10             	mov    0x10(%ebp),%eax
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800a0f:	eb 03                	jmp    800a14 <strtol+0x11>
    s++;
  800a11:	83 c2 01             	add    $0x1,%edx
{
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800a14:	0f b6 0a             	movzbl (%edx),%ecx
  800a17:	80 f9 09             	cmp    $0x9,%cl
  800a1a:	74 f5                	je     800a11 <strtol+0xe>
  800a1c:	80 f9 20             	cmp    $0x20,%cl
  800a1f:	74 f0                	je     800a11 <strtol+0xe>
    s++;

  // plus/minus sign
  if (*s == '+')
  800a21:	80 f9 2b             	cmp    $0x2b,%cl
  800a24:	75 0a                	jne    800a30 <strtol+0x2d>
    s++;
  800a26:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
  int neg = 0;
  800a29:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2e:	eb 11                	jmp    800a41 <strtol+0x3e>
  800a30:	bf 00 00 00 00       	mov    $0x0,%edi
    s++;

  // plus/minus sign
  if (*s == '+')
    s++;
  else if (*s == '-')
  800a35:	80 f9 2d             	cmp    $0x2d,%cl
  800a38:	75 07                	jne    800a41 <strtol+0x3e>
    s++, neg = 1;
  800a3a:	8d 52 01             	lea    0x1(%edx),%edx
  800a3d:	66 bf 01 00          	mov    $0x1,%di

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a41:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800a46:	75 15                	jne    800a5d <strtol+0x5a>
  800a48:	80 3a 30             	cmpb   $0x30,(%edx)
  800a4b:	75 10                	jne    800a5d <strtol+0x5a>
  800a4d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a51:	75 0a                	jne    800a5d <strtol+0x5a>
    s += 2, base = 16;
  800a53:	83 c2 02             	add    $0x2,%edx
  800a56:	b8 10 00 00 00       	mov    $0x10,%eax
  800a5b:	eb 10                	jmp    800a6d <strtol+0x6a>
  else if (base == 0 && s[0] == '0')
  800a5d:	85 c0                	test   %eax,%eax
  800a5f:	75 0c                	jne    800a6d <strtol+0x6a>
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800a61:	b0 0a                	mov    $0xa,%al
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
  800a63:	80 3a 30             	cmpb   $0x30,(%edx)
  800a66:	75 05                	jne    800a6d <strtol+0x6a>
    s++, base = 8;
  800a68:	83 c2 01             	add    $0x1,%edx
  800a6b:	b0 08                	mov    $0x8,%al
  else if (base == 0)
    base = 10;
  800a6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a72:	89 45 10             	mov    %eax,0x10(%ebp)

  // digits
  while (1) {
    int dig;

    if (*s >= '0' && *s <= '9')
  800a75:	0f b6 0a             	movzbl (%edx),%ecx
  800a78:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800a7b:	89 f0                	mov    %esi,%eax
  800a7d:	3c 09                	cmp    $0x9,%al
  800a7f:	77 08                	ja     800a89 <strtol+0x86>
      dig = *s - '0';
  800a81:	0f be c9             	movsbl %cl,%ecx
  800a84:	83 e9 30             	sub    $0x30,%ecx
  800a87:	eb 20                	jmp    800aa9 <strtol+0xa6>
    else if (*s >= 'a' && *s <= 'z')
  800a89:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800a8c:	89 f0                	mov    %esi,%eax
  800a8e:	3c 19                	cmp    $0x19,%al
  800a90:	77 08                	ja     800a9a <strtol+0x97>
      dig = *s - 'a' + 10;
  800a92:	0f be c9             	movsbl %cl,%ecx
  800a95:	83 e9 57             	sub    $0x57,%ecx
  800a98:	eb 0f                	jmp    800aa9 <strtol+0xa6>
    else if (*s >= 'A' && *s <= 'Z')
  800a9a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800a9d:	89 f0                	mov    %esi,%eax
  800a9f:	3c 19                	cmp    $0x19,%al
  800aa1:	77 16                	ja     800ab9 <strtol+0xb6>
      dig = *s - 'A' + 10;
  800aa3:	0f be c9             	movsbl %cl,%ecx
  800aa6:	83 e9 37             	sub    $0x37,%ecx
    else
      break;
    if (dig >= base)
  800aa9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800aac:	7d 0f                	jge    800abd <strtol+0xba>
      break;
    s++, val = (val * base) + dig;
  800aae:	83 c2 01             	add    $0x1,%edx
  800ab1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800ab5:	01 cb                	add    %ecx,%ebx
    // we don't properly detect overflow!
  }
  800ab7:	eb bc                	jmp    800a75 <strtol+0x72>
  800ab9:	89 d8                	mov    %ebx,%eax
  800abb:	eb 02                	jmp    800abf <strtol+0xbc>
  800abd:	89 d8                	mov    %ebx,%eax

  if (endptr)
  800abf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac3:	74 05                	je     800aca <strtol+0xc7>
    *endptr = (char*)s;
  800ac5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac8:	89 16                	mov    %edx,(%esi)
  return neg ? -val : val;
  800aca:	f7 d8                	neg    %eax
  800acc:	85 ff                	test   %edi,%edi
  800ace:	0f 44 c3             	cmove  %ebx,%eax
}
  800ad1:	5b                   	pop    %ebx
  800ad2:	5e                   	pop    %esi
  800ad3:	5f                   	pop    %edi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <sys_cputs>:
  return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	57                   	push   %edi
  800ada:	56                   	push   %esi
  800adb:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800adc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae7:	89 c3                	mov    %eax,%ebx
  800ae9:	89 c7                	mov    %eax,%edi
  800aeb:	89 c6                	mov    %eax,%esi
  800aed:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
  syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aef:	5b                   	pop    %ebx
  800af0:	5e                   	pop    %esi
  800af1:	5f                   	pop    %edi
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    

00800af4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	57                   	push   %edi
  800af8:	56                   	push   %esi
  800af9:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800afa:	ba 00 00 00 00       	mov    $0x0,%edx
  800aff:	b8 01 00 00 00       	mov    $0x1,%eax
  800b04:	89 d1                	mov    %edx,%ecx
  800b06:	89 d3                	mov    %edx,%ebx
  800b08:	89 d7                	mov    %edx,%edi
  800b0a:	89 d6                	mov    %edx,%esi
  800b0c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b0e:	5b                   	pop    %ebx
  800b0f:	5e                   	pop    %esi
  800b10:	5f                   	pop    %edi
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    

00800b13 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	57                   	push   %edi
  800b17:	56                   	push   %esi
  800b18:	53                   	push   %ebx
  800b19:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800b1c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b21:	b8 03 00 00 00       	mov    $0x3,%eax
  800b26:	8b 55 08             	mov    0x8(%ebp),%edx
  800b29:	89 cb                	mov    %ecx,%ebx
  800b2b:	89 cf                	mov    %ecx,%edi
  800b2d:	89 ce                	mov    %ecx,%esi
  800b2f:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800b31:	85 c0                	test   %eax,%eax
  800b33:	7e 28                	jle    800b5d <sys_env_destroy+0x4a>
    panic("syscall %d returned %d (> 0)", num, ret);
  800b35:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b39:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b40:	00 
  800b41:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800b48:	00 
  800b49:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b50:	00 
  800b51:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800b58:	e8 09 10 00 00       	call   801b66 <_panic>

int
sys_env_destroy(envid_t envid)
{
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b5d:	83 c4 2c             	add    $0x2c,%esp
  800b60:	5b                   	pop    %ebx
  800b61:	5e                   	pop    %esi
  800b62:	5f                   	pop    %edi
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	57                   	push   %edi
  800b69:	56                   	push   %esi
  800b6a:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800b6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b70:	b8 02 00 00 00       	mov    $0x2,%eax
  800b75:	89 d1                	mov    %edx,%ecx
  800b77:	89 d3                	mov    %edx,%ebx
  800b79:	89 d7                	mov    %edx,%edi
  800b7b:	89 d6                	mov    %edx,%esi
  800b7d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b7f:	5b                   	pop    %ebx
  800b80:	5e                   	pop    %esi
  800b81:	5f                   	pop    %edi
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    

00800b84 <sys_yield>:

void
sys_yield(void)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	57                   	push   %edi
  800b88:	56                   	push   %esi
  800b89:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800b8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b94:	89 d1                	mov    %edx,%ecx
  800b96:	89 d3                	mov    %edx,%ebx
  800b98:	89 d7                	mov    %edx,%edi
  800b9a:	89 d6                	mov    %edx,%esi
  800b9c:	cd 30                	int    $0x30

void
sys_yield(void)
{
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    

00800ba3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	57                   	push   %edi
  800ba7:	56                   	push   %esi
  800ba8:	53                   	push   %ebx
  800ba9:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800bac:	be 00 00 00 00       	mov    $0x0,%esi
  800bb1:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bbf:	89 f7                	mov    %esi,%edi
  800bc1:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800bc3:	85 c0                	test   %eax,%eax
  800bc5:	7e 28                	jle    800bef <sys_page_alloc+0x4c>
    panic("syscall %d returned %d (> 0)", num, ret);
  800bc7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bcb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bd2:	00 
  800bd3:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800bda:	00 
  800bdb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800be2:	00 
  800be3:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800bea:	e8 77 0f 00 00       	call   801b66 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  return syscall(SYS_page_alloc, 1, envid, (uint32_t)va, perm, 0, 0);
}
  800bef:	83 c4 2c             	add    $0x2c,%esp
  800bf2:	5b                   	pop    %ebx
  800bf3:	5e                   	pop    %esi
  800bf4:	5f                   	pop    %edi
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    

00800bf7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	57                   	push   %edi
  800bfb:	56                   	push   %esi
  800bfc:	53                   	push   %ebx
  800bfd:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800c00:	b8 05 00 00 00       	mov    $0x5,%eax
  800c05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c08:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c11:	8b 75 18             	mov    0x18(%ebp),%esi
  800c14:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800c16:	85 c0                	test   %eax,%eax
  800c18:	7e 28                	jle    800c42 <sys_page_map+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800c1a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c1e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c25:	00 
  800c26:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800c2d:	00 
  800c2e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c35:	00 
  800c36:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800c3d:	e8 24 0f 00 00       	call   801b66 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  return syscall(SYS_page_map, 1, srcenv, (uint32_t)srcva, dstenv, (uint32_t)dstva, perm);
}
  800c42:	83 c4 2c             	add    $0x2c,%esp
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
  800c50:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800c53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c58:	b8 06 00 00 00       	mov    $0x6,%eax
  800c5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c60:	8b 55 08             	mov    0x8(%ebp),%edx
  800c63:	89 df                	mov    %ebx,%edi
  800c65:	89 de                	mov    %ebx,%esi
  800c67:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800c69:	85 c0                	test   %eax,%eax
  800c6b:	7e 28                	jle    800c95 <sys_page_unmap+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800c6d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c71:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c78:	00 
  800c79:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800c80:	00 
  800c81:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c88:	00 
  800c89:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800c90:	e8 d1 0e 00 00       	call   801b66 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
  return syscall(SYS_page_unmap, 1, envid, (uint32_t)va, 0, 0, 0);
}
  800c95:	83 c4 2c             	add    $0x2c,%esp
  800c98:	5b                   	pop    %ebx
  800c99:	5e                   	pop    %esi
  800c9a:	5f                   	pop    %edi
  800c9b:	5d                   	pop    %ebp
  800c9c:	c3                   	ret    

00800c9d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	57                   	push   %edi
  800ca1:	56                   	push   %esi
  800ca2:	53                   	push   %ebx
  800ca3:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800ca6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cab:	b8 08 00 00 00       	mov    $0x8,%eax
  800cb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb6:	89 df                	mov    %ebx,%edi
  800cb8:	89 de                	mov    %ebx,%esi
  800cba:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800cbc:	85 c0                	test   %eax,%eax
  800cbe:	7e 28                	jle    800ce8 <sys_env_set_status+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800cc0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ccb:	00 
  800ccc:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800cd3:	00 
  800cd4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cdb:	00 
  800cdc:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800ce3:	e8 7e 0e 00 00       	call   801b66 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ce8:	83 c4 2c             	add    $0x2c,%esp
  800ceb:	5b                   	pop    %ebx
  800cec:	5e                   	pop    %esi
  800ced:	5f                   	pop    %edi
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	57                   	push   %edi
  800cf4:	56                   	push   %esi
  800cf5:	53                   	push   %ebx
  800cf6:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800cf9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfe:	b8 09 00 00 00       	mov    $0x9,%eax
  800d03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d06:	8b 55 08             	mov    0x8(%ebp),%edx
  800d09:	89 df                	mov    %ebx,%edi
  800d0b:	89 de                	mov    %ebx,%esi
  800d0d:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800d0f:	85 c0                	test   %eax,%eax
  800d11:	7e 28                	jle    800d3b <sys_env_set_trapframe+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800d13:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d17:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d1e:	00 
  800d1f:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800d26:	00 
  800d27:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d2e:	00 
  800d2f:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800d36:	e8 2b 0e 00 00       	call   801b66 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t)tf, 0, 0, 0);
}
  800d3b:	83 c4 2c             	add    $0x2c,%esp
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	57                   	push   %edi
  800d47:	56                   	push   %esi
  800d48:	53                   	push   %ebx
  800d49:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800d4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d51:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d59:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5c:	89 df                	mov    %ebx,%edi
  800d5e:	89 de                	mov    %ebx,%esi
  800d60:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800d62:	85 c0                	test   %eax,%eax
  800d64:	7e 28                	jle    800d8e <sys_env_set_pgfault_upcall+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800d66:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d6a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d71:	00 
  800d72:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800d79:	00 
  800d7a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d81:	00 
  800d82:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800d89:	e8 d8 0d 00 00       	call   801b66 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800d8e:	83 c4 2c             	add    $0x2c,%esp
  800d91:	5b                   	pop    %ebx
  800d92:	5e                   	pop    %esi
  800d93:	5f                   	pop    %edi
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	57                   	push   %edi
  800d9a:	56                   	push   %esi
  800d9b:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800d9c:	be 00 00 00 00       	mov    $0x0,%esi
  800da1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800daf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t)srcva, perm, 0);
}
  800db4:	5b                   	pop    %ebx
  800db5:	5e                   	pop    %esi
  800db6:	5f                   	pop    %edi
  800db7:	5d                   	pop    %ebp
  800db8:	c3                   	ret    

00800db9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800db9:	55                   	push   %ebp
  800dba:	89 e5                	mov    %esp,%ebp
  800dbc:	57                   	push   %edi
  800dbd:	56                   	push   %esi
  800dbe:	53                   	push   %ebx
  800dbf:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800dc2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dcc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcf:	89 cb                	mov    %ecx,%ebx
  800dd1:	89 cf                	mov    %ecx,%edi
  800dd3:	89 ce                	mov    %ecx,%esi
  800dd5:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800dd7:	85 c0                	test   %eax,%eax
  800dd9:	7e 28                	jle    800e03 <sys_ipc_recv+0x4a>
    panic("syscall %d returned %d (> 0)", num, ret);
  800ddb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ddf:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800de6:	00 
  800de7:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800dee:	00 
  800def:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df6:	00 
  800df7:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800dfe:	e8 63 0d 00 00       	call   801b66 <_panic>

int
sys_ipc_recv(void *dstva)
{
  return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e03:	83 c4 2c             	add    $0x2c,%esp
  800e06:	5b                   	pop    %ebx
  800e07:	5e                   	pop    %esi
  800e08:	5f                   	pop    %edi
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    
  800e0b:	66 90                	xchg   %ax,%ax
  800e0d:	66 90                	xchg   %ax,%ax
  800e0f:	90                   	nop

00800e10 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  800e13:	8b 45 08             	mov    0x8(%ebp),%eax
  800e16:	05 00 00 00 30       	add    $0x30000000,%eax
  800e1b:	c1 e8 0c             	shr    $0xc,%eax
}
  800e1e:	5d                   	pop    %ebp
  800e1f:	c3                   	ret    

00800e20 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  800e23:	8b 45 08             	mov    0x8(%ebp),%eax
  800e26:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
  return INDEX2DATA(fd2num(fd));
  800e2b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e30:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e35:	5d                   	pop    %ebp
  800e36:	c3                   	ret    

00800e37 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
  800e3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
  int i;
  struct Fd *fd;

  for (i = 0; i < MAXFD; i++) {
    fd = INDEX2FD(i);
    if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e42:	89 c2                	mov    %eax,%edx
  800e44:	c1 ea 16             	shr    $0x16,%edx
  800e47:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e4e:	f6 c2 01             	test   $0x1,%dl
  800e51:	74 11                	je     800e64 <fd_alloc+0x2d>
  800e53:	89 c2                	mov    %eax,%edx
  800e55:	c1 ea 0c             	shr    $0xc,%edx
  800e58:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e5f:	f6 c2 01             	test   $0x1,%dl
  800e62:	75 09                	jne    800e6d <fd_alloc+0x36>
      *fd_store = fd;
  800e64:	89 01                	mov    %eax,(%ecx)
      return 0;
  800e66:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6b:	eb 17                	jmp    800e84 <fd_alloc+0x4d>
  800e6d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
  int i;
  struct Fd *fd;

  for (i = 0; i < MAXFD; i++) {
  800e72:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e77:	75 c9                	jne    800e42 <fd_alloc+0xb>
    if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
      *fd_store = fd;
      return 0;
    }
  }
  *fd_store = 0;
  800e79:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
  return -E_MAX_OPEN;
  800e7f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    

00800e86 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	8b 45 08             	mov    0x8(%ebp),%eax
  struct Fd *fd;

  if (fdnum < 0 || fdnum >= MAXFD) {
  800e8c:	83 f8 1f             	cmp    $0x1f,%eax
  800e8f:	77 36                	ja     800ec7 <fd_lookup+0x41>
    if (debug)
      cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  fd = INDEX2FD(fdnum);
  800e91:	c1 e0 0c             	shl    $0xc,%eax
  800e94:	2d 00 00 00 30       	sub    $0x30000000,%eax
  if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e99:	89 c2                	mov    %eax,%edx
  800e9b:	c1 ea 16             	shr    $0x16,%edx
  800e9e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ea5:	f6 c2 01             	test   $0x1,%dl
  800ea8:	74 24                	je     800ece <fd_lookup+0x48>
  800eaa:	89 c2                	mov    %eax,%edx
  800eac:	c1 ea 0c             	shr    $0xc,%edx
  800eaf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eb6:	f6 c2 01             	test   $0x1,%dl
  800eb9:	74 1a                	je     800ed5 <fd_lookup+0x4f>
    if (debug)
      cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  *fd_store = fd;
  800ebb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ebe:	89 02                	mov    %eax,(%edx)
  return 0;
  800ec0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec5:	eb 13                	jmp    800eda <fd_lookup+0x54>
  struct Fd *fd;

  if (fdnum < 0 || fdnum >= MAXFD) {
    if (debug)
      cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  800ec7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ecc:	eb 0c                	jmp    800eda <fd_lookup+0x54>
  }
  fd = INDEX2FD(fdnum);
  if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
    if (debug)
      cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  800ece:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ed3:	eb 05                	jmp    800eda <fd_lookup+0x54>
  800ed5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  }
  *fd_store = fd;
  return 0;
}
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <dev_lookup>:
  0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	83 ec 18             	sub    $0x18,%esp
  800ee2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee5:	ba 88 23 80 00       	mov    $0x802388,%edx
  int i;

  for (i = 0; devtab[i]; i++)
  800eea:	eb 13                	jmp    800eff <dev_lookup+0x23>
  800eec:	83 c2 04             	add    $0x4,%edx
    if (devtab[i]->dev_id == dev_id) {
  800eef:	39 08                	cmp    %ecx,(%eax)
  800ef1:	75 0c                	jne    800eff <dev_lookup+0x23>
      *dev = devtab[i];
  800ef3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef6:	89 01                	mov    %eax,(%ecx)
      return 0;
  800ef8:	b8 00 00 00 00       	mov    $0x0,%eax
  800efd:	eb 30                	jmp    800f2f <dev_lookup+0x53>
int
dev_lookup(int dev_id, struct Dev **dev)
{
  int i;

  for (i = 0; devtab[i]; i++)
  800eff:	8b 02                	mov    (%edx),%eax
  800f01:	85 c0                	test   %eax,%eax
  800f03:	75 e7                	jne    800eec <dev_lookup+0x10>
    if (devtab[i]->dev_id == dev_id) {
      *dev = devtab[i];
      return 0;
    }
  cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f05:	a1 08 40 80 00       	mov    0x804008,%eax
  800f0a:	8b 40 48             	mov    0x48(%eax),%eax
  800f0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f11:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f15:	c7 04 24 0c 23 80 00 	movl   $0x80230c,(%esp)
  800f1c:	e8 45 f2 ff ff       	call   800166 <cprintf>
  *dev = 0;
  800f21:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f24:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  return -E_INVAL;
  800f2a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f2f:	c9                   	leave  
  800f30:	c3                   	ret    

00800f31 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	56                   	push   %esi
  800f35:	53                   	push   %ebx
  800f36:	83 ec 20             	sub    $0x20,%esp
  800f39:	8b 75 08             	mov    0x8(%ebp),%esi
  800f3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct Fd *fd2;
  struct Dev *dev;
  int r;

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f42:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  800f46:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f4c:	c1 e8 0c             	shr    $0xc,%eax
{
  struct Fd *fd2;
  struct Dev *dev;
  int r;

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f4f:	89 04 24             	mov    %eax,(%esp)
  800f52:	e8 2f ff ff ff       	call   800e86 <fd_lookup>
  800f57:	85 c0                	test   %eax,%eax
  800f59:	78 05                	js     800f60 <fd_close+0x2f>
      || fd != fd2)
  800f5b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f5e:	74 0c                	je     800f6c <fd_close+0x3b>
    return must_exist ? r : 0;
  800f60:	84 db                	test   %bl,%bl
  800f62:	ba 00 00 00 00       	mov    $0x0,%edx
  800f67:	0f 44 c2             	cmove  %edx,%eax
  800f6a:	eb 3f                	jmp    800fab <fd_close+0x7a>
  if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f6c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f73:	8b 06                	mov    (%esi),%eax
  800f75:	89 04 24             	mov    %eax,(%esp)
  800f78:	e8 5f ff ff ff       	call   800edc <dev_lookup>
  800f7d:	89 c3                	mov    %eax,%ebx
  800f7f:	85 c0                	test   %eax,%eax
  800f81:	78 16                	js     800f99 <fd_close+0x68>
    if (dev->dev_close)
  800f83:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f86:	8b 40 10             	mov    0x10(%eax),%eax
      r = (*dev->dev_close)(fd);
    else
      r = 0;
  800f89:	bb 00 00 00 00       	mov    $0x0,%ebx

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
      || fd != fd2)
    return must_exist ? r : 0;
  if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
    if (dev->dev_close)
  800f8e:	85 c0                	test   %eax,%eax
  800f90:	74 07                	je     800f99 <fd_close+0x68>
      r = (*dev->dev_close)(fd);
  800f92:	89 34 24             	mov    %esi,(%esp)
  800f95:	ff d0                	call   *%eax
  800f97:	89 c3                	mov    %eax,%ebx
    else
      r = 0;
  }
  // Make sure fd is unmapped.  Might be a no-op if
  // (*dev->dev_close)(fd) already unmapped it.
  (void)sys_page_unmap(0, fd);
  800f99:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fa4:	e8 a1 fc ff ff       	call   800c4a <sys_page_unmap>
  return r;
  800fa9:	89 d8                	mov    %ebx,%eax
}
  800fab:	83 c4 20             	add    $0x20,%esp
  800fae:	5b                   	pop    %ebx
  800faf:	5e                   	pop    %esi
  800fb0:	5d                   	pop    %ebp
  800fb1:	c3                   	ret    

00800fb2 <close>:
  return -E_INVAL;
}

int
close(int fdnum)
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	83 ec 28             	sub    $0x28,%esp
  struct Fd *fd;
  int r;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fbb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc2:	89 04 24             	mov    %eax,(%esp)
  800fc5:	e8 bc fe ff ff       	call   800e86 <fd_lookup>
  800fca:	89 c2                	mov    %eax,%edx
  800fcc:	85 d2                	test   %edx,%edx
  800fce:	78 13                	js     800fe3 <close+0x31>
    return r;
  else
    return fd_close(fd, 1);
  800fd0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fd7:	00 
  800fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fdb:	89 04 24             	mov    %eax,(%esp)
  800fde:	e8 4e ff ff ff       	call   800f31 <fd_close>
}
  800fe3:	c9                   	leave  
  800fe4:	c3                   	ret    

00800fe5 <close_all>:

void
close_all(void)
{
  800fe5:	55                   	push   %ebp
  800fe6:	89 e5                	mov    %esp,%ebp
  800fe8:	53                   	push   %ebx
  800fe9:	83 ec 14             	sub    $0x14,%esp
  int i;

  for (i = 0; i < MAXFD; i++)
  800fec:	bb 00 00 00 00       	mov    $0x0,%ebx
    close(i);
  800ff1:	89 1c 24             	mov    %ebx,(%esp)
  800ff4:	e8 b9 ff ff ff       	call   800fb2 <close>
void
close_all(void)
{
  int i;

  for (i = 0; i < MAXFD; i++)
  800ff9:	83 c3 01             	add    $0x1,%ebx
  800ffc:	83 fb 20             	cmp    $0x20,%ebx
  800fff:	75 f0                	jne    800ff1 <close_all+0xc>
    close(i);
}
  801001:	83 c4 14             	add    $0x14,%esp
  801004:	5b                   	pop    %ebx
  801005:	5d                   	pop    %ebp
  801006:	c3                   	ret    

00801007 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	57                   	push   %edi
  80100b:	56                   	push   %esi
  80100c:	53                   	push   %ebx
  80100d:	83 ec 3c             	sub    $0x3c,%esp
  int r;
  char *ova, *nva;
  pte_t pte;
  struct Fd *oldfd, *newfd;

  if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801010:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801013:	89 44 24 04          	mov    %eax,0x4(%esp)
  801017:	8b 45 08             	mov    0x8(%ebp),%eax
  80101a:	89 04 24             	mov    %eax,(%esp)
  80101d:	e8 64 fe ff ff       	call   800e86 <fd_lookup>
  801022:	89 c2                	mov    %eax,%edx
  801024:	85 d2                	test   %edx,%edx
  801026:	0f 88 e1 00 00 00    	js     80110d <dup+0x106>
    return r;
  close(newfdnum);
  80102c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80102f:	89 04 24             	mov    %eax,(%esp)
  801032:	e8 7b ff ff ff       	call   800fb2 <close>

  newfd = INDEX2FD(newfdnum);
  801037:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80103a:	c1 e3 0c             	shl    $0xc,%ebx
  80103d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
  ova = fd2data(oldfd);
  801043:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801046:	89 04 24             	mov    %eax,(%esp)
  801049:	e8 d2 fd ff ff       	call   800e20 <fd2data>
  80104e:	89 c6                	mov    %eax,%esi
  nva = fd2data(newfd);
  801050:	89 1c 24             	mov    %ebx,(%esp)
  801053:	e8 c8 fd ff ff       	call   800e20 <fd2data>
  801058:	89 c7                	mov    %eax,%edi

  if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80105a:	89 f0                	mov    %esi,%eax
  80105c:	c1 e8 16             	shr    $0x16,%eax
  80105f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801066:	a8 01                	test   $0x1,%al
  801068:	74 43                	je     8010ad <dup+0xa6>
  80106a:	89 f0                	mov    %esi,%eax
  80106c:	c1 e8 0c             	shr    $0xc,%eax
  80106f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801076:	f6 c2 01             	test   $0x1,%dl
  801079:	74 32                	je     8010ad <dup+0xa6>
    if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80107b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801082:	25 07 0e 00 00       	and    $0xe07,%eax
  801087:	89 44 24 10          	mov    %eax,0x10(%esp)
  80108b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80108f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801096:	00 
  801097:	89 74 24 04          	mov    %esi,0x4(%esp)
  80109b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010a2:	e8 50 fb ff ff       	call   800bf7 <sys_page_map>
  8010a7:	89 c6                	mov    %eax,%esi
  8010a9:	85 c0                	test   %eax,%eax
  8010ab:	78 3e                	js     8010eb <dup+0xe4>
      goto err;
  if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010b0:	89 c2                	mov    %eax,%edx
  8010b2:	c1 ea 0c             	shr    $0xc,%edx
  8010b5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010bc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8010c2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8010c6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010ca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010d1:	00 
  8010d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010dd:	e8 15 fb ff ff       	call   800bf7 <sys_page_map>
  8010e2:	89 c6                	mov    %eax,%esi
    goto err;

  return newfdnum;
  8010e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  nva = fd2data(newfd);

  if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
    if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
      goto err;
  if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010e7:	85 f6                	test   %esi,%esi
  8010e9:	79 22                	jns    80110d <dup+0x106>
    goto err;

  return newfdnum;

err:
  sys_page_unmap(0, newfd);
  8010eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010f6:	e8 4f fb ff ff       	call   800c4a <sys_page_unmap>
  sys_page_unmap(0, nva);
  8010fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801106:	e8 3f fb ff ff       	call   800c4a <sys_page_unmap>
  return r;
  80110b:	89 f0                	mov    %esi,%eax
}
  80110d:	83 c4 3c             	add    $0x3c,%esp
  801110:	5b                   	pop    %ebx
  801111:	5e                   	pop    %esi
  801112:	5f                   	pop    %edi
  801113:	5d                   	pop    %ebp
  801114:	c3                   	ret    

00801115 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801115:	55                   	push   %ebp
  801116:	89 e5                	mov    %esp,%ebp
  801118:	53                   	push   %ebx
  801119:	83 ec 24             	sub    $0x24,%esp
  80111c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  80111f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801122:	89 44 24 04          	mov    %eax,0x4(%esp)
  801126:	89 1c 24             	mov    %ebx,(%esp)
  801129:	e8 58 fd ff ff       	call   800e86 <fd_lookup>
  80112e:	89 c2                	mov    %eax,%edx
  801130:	85 d2                	test   %edx,%edx
  801132:	78 6d                	js     8011a1 <read+0x8c>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801134:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801137:	89 44 24 04          	mov    %eax,0x4(%esp)
  80113b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80113e:	8b 00                	mov    (%eax),%eax
  801140:	89 04 24             	mov    %eax,(%esp)
  801143:	e8 94 fd ff ff       	call   800edc <dev_lookup>
  801148:	85 c0                	test   %eax,%eax
  80114a:	78 55                	js     8011a1 <read+0x8c>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80114c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80114f:	8b 50 08             	mov    0x8(%eax),%edx
  801152:	83 e2 03             	and    $0x3,%edx
  801155:	83 fa 01             	cmp    $0x1,%edx
  801158:	75 23                	jne    80117d <read+0x68>
    cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80115a:	a1 08 40 80 00       	mov    0x804008,%eax
  80115f:	8b 40 48             	mov    0x48(%eax),%eax
  801162:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801166:	89 44 24 04          	mov    %eax,0x4(%esp)
  80116a:	c7 04 24 4d 23 80 00 	movl   $0x80234d,(%esp)
  801171:	e8 f0 ef ff ff       	call   800166 <cprintf>
    return -E_INVAL;
  801176:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80117b:	eb 24                	jmp    8011a1 <read+0x8c>
  }
  if (!dev->dev_read)
  80117d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801180:	8b 52 08             	mov    0x8(%edx),%edx
  801183:	85 d2                	test   %edx,%edx
  801185:	74 15                	je     80119c <read+0x87>
    return -E_NOT_SUPP;
  return (*dev->dev_read)(fd, buf, n);
  801187:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80118a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80118e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801191:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801195:	89 04 24             	mov    %eax,(%esp)
  801198:	ff d2                	call   *%edx
  80119a:	eb 05                	jmp    8011a1 <read+0x8c>
  if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
    cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  if (!dev->dev_read)
    return -E_NOT_SUPP;
  80119c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_read)(fd, buf, n);
}
  8011a1:	83 c4 24             	add    $0x24,%esp
  8011a4:	5b                   	pop    %ebx
  8011a5:	5d                   	pop    %ebp
  8011a6:	c3                   	ret    

008011a7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011a7:	55                   	push   %ebp
  8011a8:	89 e5                	mov    %esp,%ebp
  8011aa:	57                   	push   %edi
  8011ab:	56                   	push   %esi
  8011ac:	53                   	push   %ebx
  8011ad:	83 ec 1c             	sub    $0x1c,%esp
  8011b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011b3:	8b 75 10             	mov    0x10(%ebp),%esi
  int m, tot;

  for (tot = 0; tot < n; tot += m) {
  8011b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011bb:	eb 23                	jmp    8011e0 <readn+0x39>
    m = read(fdnum, (char*)buf + tot, n - tot);
  8011bd:	89 f0                	mov    %esi,%eax
  8011bf:	29 d8                	sub    %ebx,%eax
  8011c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011c5:	89 d8                	mov    %ebx,%eax
  8011c7:	03 45 0c             	add    0xc(%ebp),%eax
  8011ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ce:	89 3c 24             	mov    %edi,(%esp)
  8011d1:	e8 3f ff ff ff       	call   801115 <read>
    if (m < 0)
  8011d6:	85 c0                	test   %eax,%eax
  8011d8:	78 10                	js     8011ea <readn+0x43>
      return m;
    if (m == 0)
  8011da:	85 c0                	test   %eax,%eax
  8011dc:	74 0a                	je     8011e8 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
  int m, tot;

  for (tot = 0; tot < n; tot += m) {
  8011de:	01 c3                	add    %eax,%ebx
  8011e0:	39 f3                	cmp    %esi,%ebx
  8011e2:	72 d9                	jb     8011bd <readn+0x16>
  8011e4:	89 d8                	mov    %ebx,%eax
  8011e6:	eb 02                	jmp    8011ea <readn+0x43>
  8011e8:	89 d8                	mov    %ebx,%eax
      return m;
    if (m == 0)
      break;
  }
  return tot;
}
  8011ea:	83 c4 1c             	add    $0x1c,%esp
  8011ed:	5b                   	pop    %ebx
  8011ee:	5e                   	pop    %esi
  8011ef:	5f                   	pop    %edi
  8011f0:	5d                   	pop    %ebp
  8011f1:	c3                   	ret    

008011f2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
  8011f5:	53                   	push   %ebx
  8011f6:	83 ec 24             	sub    $0x24,%esp
  8011f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  8011fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801203:	89 1c 24             	mov    %ebx,(%esp)
  801206:	e8 7b fc ff ff       	call   800e86 <fd_lookup>
  80120b:	89 c2                	mov    %eax,%edx
  80120d:	85 d2                	test   %edx,%edx
  80120f:	78 68                	js     801279 <write+0x87>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801211:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801214:	89 44 24 04          	mov    %eax,0x4(%esp)
  801218:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121b:	8b 00                	mov    (%eax),%eax
  80121d:	89 04 24             	mov    %eax,(%esp)
  801220:	e8 b7 fc ff ff       	call   800edc <dev_lookup>
  801225:	85 c0                	test   %eax,%eax
  801227:	78 50                	js     801279 <write+0x87>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801229:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801230:	75 23                	jne    801255 <write+0x63>
    cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801232:	a1 08 40 80 00       	mov    0x804008,%eax
  801237:	8b 40 48             	mov    0x48(%eax),%eax
  80123a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80123e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801242:	c7 04 24 69 23 80 00 	movl   $0x802369,(%esp)
  801249:	e8 18 ef ff ff       	call   800166 <cprintf>
    return -E_INVAL;
  80124e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801253:	eb 24                	jmp    801279 <write+0x87>
  }
  if (debug)
    cprintf("write %d %p %d via dev %s\n",
            fdnum, buf, n, dev->dev_name);
  if (!dev->dev_write)
  801255:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801258:	8b 52 0c             	mov    0xc(%edx),%edx
  80125b:	85 d2                	test   %edx,%edx
  80125d:	74 15                	je     801274 <write+0x82>
    return -E_NOT_SUPP;
  return (*dev->dev_write)(fd, buf, n);
  80125f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801262:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801266:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801269:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80126d:	89 04 24             	mov    %eax,(%esp)
  801270:	ff d2                	call   *%edx
  801272:	eb 05                	jmp    801279 <write+0x87>
  }
  if (debug)
    cprintf("write %d %p %d via dev %s\n",
            fdnum, buf, n, dev->dev_name);
  if (!dev->dev_write)
    return -E_NOT_SUPP;
  801274:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_write)(fd, buf, n);
}
  801279:	83 c4 24             	add    $0x24,%esp
  80127c:	5b                   	pop    %ebx
  80127d:	5d                   	pop    %ebp
  80127e:	c3                   	ret    

0080127f <seek>:

int
seek(int fdnum, off_t offset)
{
  80127f:	55                   	push   %ebp
  801280:	89 e5                	mov    %esp,%ebp
  801282:	83 ec 18             	sub    $0x18,%esp
  int r;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  801285:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801288:	89 44 24 04          	mov    %eax,0x4(%esp)
  80128c:	8b 45 08             	mov    0x8(%ebp),%eax
  80128f:	89 04 24             	mov    %eax,(%esp)
  801292:	e8 ef fb ff ff       	call   800e86 <fd_lookup>
  801297:	85 c0                	test   %eax,%eax
  801299:	78 0e                	js     8012a9 <seek+0x2a>
    return r;
  fd->fd_offset = offset;
  80129b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80129e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012a1:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
  8012a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012a9:	c9                   	leave  
  8012aa:	c3                   	ret    

008012ab <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012ab:	55                   	push   %ebp
  8012ac:	89 e5                	mov    %esp,%ebp
  8012ae:	53                   	push   %ebx
  8012af:	83 ec 24             	sub    $0x24,%esp
  8012b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  8012b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012bc:	89 1c 24             	mov    %ebx,(%esp)
  8012bf:	e8 c2 fb ff ff       	call   800e86 <fd_lookup>
  8012c4:	89 c2                	mov    %eax,%edx
  8012c6:	85 d2                	test   %edx,%edx
  8012c8:	78 61                	js     80132b <ftruncate+0x80>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d4:	8b 00                	mov    (%eax),%eax
  8012d6:	89 04 24             	mov    %eax,(%esp)
  8012d9:	e8 fe fb ff ff       	call   800edc <dev_lookup>
  8012de:	85 c0                	test   %eax,%eax
  8012e0:	78 49                	js     80132b <ftruncate+0x80>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012e9:	75 23                	jne    80130e <ftruncate+0x63>
    cprintf("[%08x] ftruncate %d -- bad mode\n",
            thisenv->env_id, fdnum);
  8012eb:	a1 08 40 80 00       	mov    0x804008,%eax

  if ((r = fd_lookup(fdnum, &fd)) < 0
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
    cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012f0:	8b 40 48             	mov    0x48(%eax),%eax
  8012f3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012fb:	c7 04 24 2c 23 80 00 	movl   $0x80232c,(%esp)
  801302:	e8 5f ee ff ff       	call   800166 <cprintf>
            thisenv->env_id, fdnum);
    return -E_INVAL;
  801307:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80130c:	eb 1d                	jmp    80132b <ftruncate+0x80>
  }
  if (!dev->dev_trunc)
  80130e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801311:	8b 52 18             	mov    0x18(%edx),%edx
  801314:	85 d2                	test   %edx,%edx
  801316:	74 0e                	je     801326 <ftruncate+0x7b>
    return -E_NOT_SUPP;
  return (*dev->dev_trunc)(fd, newsize);
  801318:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80131b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80131f:	89 04 24             	mov    %eax,(%esp)
  801322:	ff d2                	call   *%edx
  801324:	eb 05                	jmp    80132b <ftruncate+0x80>
    cprintf("[%08x] ftruncate %d -- bad mode\n",
            thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  if (!dev->dev_trunc)
    return -E_NOT_SUPP;
  801326:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_trunc)(fd, newsize);
}
  80132b:	83 c4 24             	add    $0x24,%esp
  80132e:	5b                   	pop    %ebx
  80132f:	5d                   	pop    %ebp
  801330:	c3                   	ret    

00801331 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801331:	55                   	push   %ebp
  801332:	89 e5                	mov    %esp,%ebp
  801334:	53                   	push   %ebx
  801335:	83 ec 24             	sub    $0x24,%esp
  801338:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  80133b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801342:	8b 45 08             	mov    0x8(%ebp),%eax
  801345:	89 04 24             	mov    %eax,(%esp)
  801348:	e8 39 fb ff ff       	call   800e86 <fd_lookup>
  80134d:	89 c2                	mov    %eax,%edx
  80134f:	85 d2                	test   %edx,%edx
  801351:	78 52                	js     8013a5 <fstat+0x74>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801353:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801356:	89 44 24 04          	mov    %eax,0x4(%esp)
  80135a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135d:	8b 00                	mov    (%eax),%eax
  80135f:	89 04 24             	mov    %eax,(%esp)
  801362:	e8 75 fb ff ff       	call   800edc <dev_lookup>
  801367:	85 c0                	test   %eax,%eax
  801369:	78 3a                	js     8013a5 <fstat+0x74>
    return r;
  if (!dev->dev_stat)
  80136b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80136e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801372:	74 2c                	je     8013a0 <fstat+0x6f>
    return -E_NOT_SUPP;
  stat->st_name[0] = 0;
  801374:	c6 03 00             	movb   $0x0,(%ebx)
  stat->st_size = 0;
  801377:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80137e:	00 00 00 
  stat->st_isdir = 0;
  801381:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801388:	00 00 00 
  stat->st_dev = dev;
  80138b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
  return (*dev->dev_stat)(fd, stat);
  801391:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801395:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801398:	89 14 24             	mov    %edx,(%esp)
  80139b:	ff 50 14             	call   *0x14(%eax)
  80139e:	eb 05                	jmp    8013a5 <fstat+0x74>

  if ((r = fd_lookup(fdnum, &fd)) < 0
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
    return r;
  if (!dev->dev_stat)
    return -E_NOT_SUPP;
  8013a0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  stat->st_name[0] = 0;
  stat->st_size = 0;
  stat->st_isdir = 0;
  stat->st_dev = dev;
  return (*dev->dev_stat)(fd, stat);
}
  8013a5:	83 c4 24             	add    $0x24,%esp
  8013a8:	5b                   	pop    %ebx
  8013a9:	5d                   	pop    %ebp
  8013aa:	c3                   	ret    

008013ab <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013ab:	55                   	push   %ebp
  8013ac:	89 e5                	mov    %esp,%ebp
  8013ae:	56                   	push   %esi
  8013af:	53                   	push   %ebx
  8013b0:	83 ec 10             	sub    $0x10,%esp
  int fd, r;

  if ((fd = open(path, O_RDONLY)) < 0)
  8013b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8013ba:	00 
  8013bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8013be:	89 04 24             	mov    %eax,(%esp)
  8013c1:	e8 d2 01 00 00       	call   801598 <open>
  8013c6:	89 c3                	mov    %eax,%ebx
  8013c8:	85 db                	test   %ebx,%ebx
  8013ca:	78 1b                	js     8013e7 <stat+0x3c>
    return fd;
  r = fstat(fd, stat);
  8013cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d3:	89 1c 24             	mov    %ebx,(%esp)
  8013d6:	e8 56 ff ff ff       	call   801331 <fstat>
  8013db:	89 c6                	mov    %eax,%esi
  close(fd);
  8013dd:	89 1c 24             	mov    %ebx,(%esp)
  8013e0:	e8 cd fb ff ff       	call   800fb2 <close>
  return r;
  8013e5:	89 f0                	mov    %esi,%eax
}
  8013e7:	83 c4 10             	add    $0x10,%esp
  8013ea:	5b                   	pop    %ebx
  8013eb:	5e                   	pop    %esi
  8013ec:	5d                   	pop    %ebp
  8013ed:	c3                   	ret    

008013ee <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013ee:	55                   	push   %ebp
  8013ef:	89 e5                	mov    %esp,%ebp
  8013f1:	56                   	push   %esi
  8013f2:	53                   	push   %ebx
  8013f3:	83 ec 10             	sub    $0x10,%esp
  8013f6:	89 c6                	mov    %eax,%esi
  8013f8:	89 d3                	mov    %edx,%ebx
  static envid_t fsenv;

  if (fsenv == 0)
  8013fa:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801401:	75 11                	jne    801414 <fsipc+0x26>
    fsenv = ipc_find_env(ENV_TYPE_FS);
  801403:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80140a:	e8 9e 08 00 00       	call   801cad <ipc_find_env>
  80140f:	a3 00 40 80 00       	mov    %eax,0x804000
  static_assert(sizeof(fsipcbuf) == PGSIZE);

  if (debug)
    cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t*)&fsipcbuf);

  ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801414:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80141b:	00 
  80141c:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801423:	00 
  801424:	89 74 24 04          	mov    %esi,0x4(%esp)
  801428:	a1 00 40 80 00       	mov    0x804000,%eax
  80142d:	89 04 24             	mov    %eax,(%esp)
  801430:	e8 0d 08 00 00       	call   801c42 <ipc_send>
  return ipc_recv(NULL, dstva, NULL);
  801435:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80143c:	00 
  80143d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801441:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801448:	e8 6f 07 00 00       	call   801bbc <ipc_recv>
}
  80144d:	83 c4 10             	add    $0x10,%esp
  801450:	5b                   	pop    %ebx
  801451:	5e                   	pop    %esi
  801452:	5d                   	pop    %ebp
  801453:	c3                   	ret    

00801454 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801454:	55                   	push   %ebp
  801455:	89 e5                	mov    %esp,%ebp
  801457:	83 ec 08             	sub    $0x8,%esp
  fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80145a:	8b 45 08             	mov    0x8(%ebp),%eax
  80145d:	8b 40 0c             	mov    0xc(%eax),%eax
  801460:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.set_size.req_size = newsize;
  801465:	8b 45 0c             	mov    0xc(%ebp),%eax
  801468:	a3 04 50 80 00       	mov    %eax,0x805004
  return fsipc(FSREQ_SET_SIZE, NULL);
  80146d:	ba 00 00 00 00       	mov    $0x0,%edx
  801472:	b8 02 00 00 00       	mov    $0x2,%eax
  801477:	e8 72 ff ff ff       	call   8013ee <fsipc>
}
  80147c:	c9                   	leave  
  80147d:	c3                   	ret    

0080147e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80147e:	55                   	push   %ebp
  80147f:	89 e5                	mov    %esp,%ebp
  801481:	83 ec 08             	sub    $0x8,%esp
  fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801484:	8b 45 08             	mov    0x8(%ebp),%eax
  801487:	8b 40 0c             	mov    0xc(%eax),%eax
  80148a:	a3 00 50 80 00       	mov    %eax,0x805000
  return fsipc(FSREQ_FLUSH, NULL);
  80148f:	ba 00 00 00 00       	mov    $0x0,%edx
  801494:	b8 06 00 00 00       	mov    $0x6,%eax
  801499:	e8 50 ff ff ff       	call   8013ee <fsipc>
}
  80149e:	c9                   	leave  
  80149f:	c3                   	ret    

008014a0 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014a0:	55                   	push   %ebp
  8014a1:	89 e5                	mov    %esp,%ebp
  8014a3:	53                   	push   %ebx
  8014a4:	83 ec 14             	sub    $0x14,%esp
  8014a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int r;

  fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b0:	a3 00 50 80 00       	mov    %eax,0x805000
  if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ba:	b8 05 00 00 00       	mov    $0x5,%eax
  8014bf:	e8 2a ff ff ff       	call   8013ee <fsipc>
  8014c4:	89 c2                	mov    %eax,%edx
  8014c6:	85 d2                	test   %edx,%edx
  8014c8:	78 2b                	js     8014f5 <devfile_stat+0x55>
    return r;
  strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014ca:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8014d1:	00 
  8014d2:	89 1c 24             	mov    %ebx,(%esp)
  8014d5:	e8 ad f2 ff ff       	call   800787 <strcpy>
  st->st_size = fsipcbuf.statRet.ret_size;
  8014da:	a1 80 50 80 00       	mov    0x805080,%eax
  8014df:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014e5:	a1 84 50 80 00       	mov    0x805084,%eax
  8014ea:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  return 0;
  8014f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014f5:	83 c4 14             	add    $0x14,%esp
  8014f8:	5b                   	pop    %ebx
  8014f9:	5d                   	pop    %ebp
  8014fa:	c3                   	ret    

008014fb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014fb:	55                   	push   %ebp
  8014fc:	89 e5                	mov    %esp,%ebp
  8014fe:	83 ec 18             	sub    $0x18,%esp
  801501:	8b 45 10             	mov    0x10(%ebp),%eax
  // remember that write is always allowed to write *fewer*
  // bytes than requested.
  // LAB 5: Your code here
    int r;

    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801504:	8b 55 08             	mov    0x8(%ebp),%edx
  801507:	8b 52 0c             	mov    0xc(%edx),%edx
  80150a:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  801510:	a3 04 50 80 00       	mov    %eax,0x805004

    size_t max_written = sizeof(fsipcbuf.write.req_buf);
    memmove(fsipcbuf.write.req_buf, buf, MIN(max_written, n));
  801515:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80151a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80151f:	0f 47 c2             	cmova  %edx,%eax
  801522:	89 44 24 08          	mov    %eax,0x8(%esp)
  801526:	8b 45 0c             	mov    0xc(%ebp),%eax
  801529:	89 44 24 04          	mov    %eax,0x4(%esp)
  80152d:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801534:	e8 eb f3 ff ff       	call   800924 <memmove>

    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801539:	ba 00 00 00 00       	mov    $0x0,%edx
  80153e:	b8 04 00 00 00       	mov    $0x4,%eax
  801543:	e8 a6 fe ff ff       	call   8013ee <fsipc>
        return r;

    return r;
}
  801548:	c9                   	leave  
  801549:	c3                   	ret    

0080154a <devfile_read>:
// Returns:
//  The number of bytes successfully read.
//  < 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	53                   	push   %ebx
  80154e:	83 ec 14             	sub    $0x14,%esp
  // filling fsipcbuf.read with the request arguments.  The
  // bytes read will be written back to fsipcbuf by the file
  // system server.
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801551:	8b 45 08             	mov    0x8(%ebp),%eax
  801554:	8b 40 0c             	mov    0xc(%eax),%eax
  801557:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  80155c:	8b 45 10             	mov    0x10(%ebp),%eax
  80155f:	a3 04 50 80 00       	mov    %eax,0x805004
  if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801564:	ba 00 00 00 00       	mov    $0x0,%edx
  801569:	b8 03 00 00 00       	mov    $0x3,%eax
  80156e:	e8 7b fe ff ff       	call   8013ee <fsipc>
  801573:	89 c3                	mov    %eax,%ebx
  801575:	85 c0                	test   %eax,%eax
  801577:	78 17                	js     801590 <devfile_read+0x46>
    return r;

  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801579:	89 44 24 08          	mov    %eax,0x8(%esp)
  80157d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801584:	00 
  801585:	8b 45 0c             	mov    0xc(%ebp),%eax
  801588:	89 04 24             	mov    %eax,(%esp)
  80158b:	e8 94 f3 ff ff       	call   800924 <memmove>
  return r;
}
  801590:	89 d8                	mov    %ebx,%eax
  801592:	83 c4 14             	add    $0x14,%esp
  801595:	5b                   	pop    %ebx
  801596:	5d                   	pop    %ebp
  801597:	c3                   	ret    

00801598 <open>:
//  The file descriptor index on success
//  -E_BAD_PATH if the path is too long (>= MAXPATHLEN)
//  < 0 for other errors.
int
open(const char *path, int mode)
{
  801598:	55                   	push   %ebp
  801599:	89 e5                	mov    %esp,%ebp
  80159b:	53                   	push   %ebx
  80159c:	83 ec 24             	sub    $0x24,%esp
  80159f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  // file descriptor.

  int r;
  struct Fd *fd;

  if (strlen(path) >= MAXPATHLEN)
  8015a2:	89 1c 24             	mov    %ebx,(%esp)
  8015a5:	e8 a6 f1 ff ff       	call   800750 <strlen>
  8015aa:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015af:	7f 60                	jg     801611 <open+0x79>
    return -E_BAD_PATH;

  if ((r = fd_alloc(&fd)) < 0)
  8015b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b4:	89 04 24             	mov    %eax,(%esp)
  8015b7:	e8 7b f8 ff ff       	call   800e37 <fd_alloc>
  8015bc:	89 c2                	mov    %eax,%edx
  8015be:	85 d2                	test   %edx,%edx
  8015c0:	78 54                	js     801616 <open+0x7e>
    return r;

  strcpy(fsipcbuf.open.req_path, path);
  8015c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015c6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8015cd:	e8 b5 f1 ff ff       	call   800787 <strcpy>
  fsipcbuf.open.req_omode = mode;
  8015d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015d5:	a3 00 54 80 00       	mov    %eax,0x805400

  if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015da:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8015e2:	e8 07 fe ff ff       	call   8013ee <fsipc>
  8015e7:	89 c3                	mov    %eax,%ebx
  8015e9:	85 c0                	test   %eax,%eax
  8015eb:	79 17                	jns    801604 <open+0x6c>
    fd_close(fd, 0);
  8015ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015f4:	00 
  8015f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f8:	89 04 24             	mov    %eax,(%esp)
  8015fb:	e8 31 f9 ff ff       	call   800f31 <fd_close>
    return r;
  801600:	89 d8                	mov    %ebx,%eax
  801602:	eb 12                	jmp    801616 <open+0x7e>
  }

  return fd2num(fd);
  801604:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801607:	89 04 24             	mov    %eax,(%esp)
  80160a:	e8 01 f8 ff ff       	call   800e10 <fd2num>
  80160f:	eb 05                	jmp    801616 <open+0x7e>

  int r;
  struct Fd *fd;

  if (strlen(path) >= MAXPATHLEN)
    return -E_BAD_PATH;
  801611:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
    fd_close(fd, 0);
    return r;
  }

  return fd2num(fd);
}
  801616:	83 c4 24             	add    $0x24,%esp
  801619:	5b                   	pop    %ebx
  80161a:	5d                   	pop    %ebp
  80161b:	c3                   	ret    

0080161c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	83 ec 08             	sub    $0x8,%esp
  // Ask the file server to update the disk
  // by writing any dirty blocks in the buffer cache.

  return fsipc(FSREQ_SYNC, NULL);
  801622:	ba 00 00 00 00       	mov    $0x0,%edx
  801627:	b8 08 00 00 00       	mov    $0x8,%eax
  80162c:	e8 bd fd ff ff       	call   8013ee <fsipc>
}
  801631:	c9                   	leave  
  801632:	c3                   	ret    

00801633 <devpipe_stat>:
  return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801633:	55                   	push   %ebp
  801634:	89 e5                	mov    %esp,%ebp
  801636:	56                   	push   %esi
  801637:	53                   	push   %ebx
  801638:	83 ec 10             	sub    $0x10,%esp
  80163b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct Pipe *p = (struct Pipe*)fd2data(fd);
  80163e:	8b 45 08             	mov    0x8(%ebp),%eax
  801641:	89 04 24             	mov    %eax,(%esp)
  801644:	e8 d7 f7 ff ff       	call   800e20 <fd2data>
  801649:	89 c6                	mov    %eax,%esi

  strcpy(stat->st_name, "<pipe>");
  80164b:	c7 44 24 04 98 23 80 	movl   $0x802398,0x4(%esp)
  801652:	00 
  801653:	89 1c 24             	mov    %ebx,(%esp)
  801656:	e8 2c f1 ff ff       	call   800787 <strcpy>
  stat->st_size = p->p_wpos - p->p_rpos;
  80165b:	8b 46 04             	mov    0x4(%esi),%eax
  80165e:	2b 06                	sub    (%esi),%eax
  801660:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  stat->st_isdir = 0;
  801666:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80166d:	00 00 00 
  stat->st_dev = &devpipe;
  801670:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801677:	30 80 00 
  return 0;
}
  80167a:	b8 00 00 00 00       	mov    $0x0,%eax
  80167f:	83 c4 10             	add    $0x10,%esp
  801682:	5b                   	pop    %ebx
  801683:	5e                   	pop    %esi
  801684:	5d                   	pop    %ebp
  801685:	c3                   	ret    

00801686 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801686:	55                   	push   %ebp
  801687:	89 e5                	mov    %esp,%ebp
  801689:	53                   	push   %ebx
  80168a:	83 ec 14             	sub    $0x14,%esp
  80168d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  (void)sys_page_unmap(0, fd);
  801690:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801694:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80169b:	e8 aa f5 ff ff       	call   800c4a <sys_page_unmap>
  return sys_page_unmap(0, fd2data(fd));
  8016a0:	89 1c 24             	mov    %ebx,(%esp)
  8016a3:	e8 78 f7 ff ff       	call   800e20 <fd2data>
  8016a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016b3:	e8 92 f5 ff ff       	call   800c4a <sys_page_unmap>
}
  8016b8:	83 c4 14             	add    $0x14,%esp
  8016bb:	5b                   	pop    %ebx
  8016bc:	5d                   	pop    %ebp
  8016bd:	c3                   	ret    

008016be <_pipeisclosed>:
  return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016be:	55                   	push   %ebp
  8016bf:	89 e5                	mov    %esp,%ebp
  8016c1:	57                   	push   %edi
  8016c2:	56                   	push   %esi
  8016c3:	53                   	push   %ebx
  8016c4:	83 ec 2c             	sub    $0x2c,%esp
  8016c7:	89 c6                	mov    %eax,%esi
  8016c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  int n, nn, ret;

  while (1) {
    n = thisenv->env_runs;
  8016cc:	a1 08 40 80 00       	mov    0x804008,%eax
  8016d1:	8b 58 58             	mov    0x58(%eax),%ebx
    ret = pageref(fd) == pageref(p);
  8016d4:	89 34 24             	mov    %esi,(%esp)
  8016d7:	e8 09 06 00 00       	call   801ce5 <pageref>
  8016dc:	89 c7                	mov    %eax,%edi
  8016de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016e1:	89 04 24             	mov    %eax,(%esp)
  8016e4:	e8 fc 05 00 00       	call   801ce5 <pageref>
  8016e9:	39 c7                	cmp    %eax,%edi
  8016eb:	0f 94 c2             	sete   %dl
  8016ee:	0f b6 c2             	movzbl %dl,%eax
    nn = thisenv->env_runs;
  8016f1:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  8016f7:	8b 79 58             	mov    0x58(%ecx),%edi
    if (n == nn)
  8016fa:	39 fb                	cmp    %edi,%ebx
  8016fc:	74 21                	je     80171f <_pipeisclosed+0x61>
      return ret;
    if (n != nn && ret == 1)
  8016fe:	84 d2                	test   %dl,%dl
  801700:	74 ca                	je     8016cc <_pipeisclosed+0xe>
      cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801702:	8b 51 58             	mov    0x58(%ecx),%edx
  801705:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801709:	89 54 24 08          	mov    %edx,0x8(%esp)
  80170d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801711:	c7 04 24 9f 23 80 00 	movl   $0x80239f,(%esp)
  801718:	e8 49 ea ff ff       	call   800166 <cprintf>
  80171d:	eb ad                	jmp    8016cc <_pipeisclosed+0xe>
  }
}
  80171f:	83 c4 2c             	add    $0x2c,%esp
  801722:	5b                   	pop    %ebx
  801723:	5e                   	pop    %esi
  801724:	5f                   	pop    %edi
  801725:	5d                   	pop    %ebp
  801726:	c3                   	ret    

00801727 <devpipe_write>:
  return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801727:	55                   	push   %ebp
  801728:	89 e5                	mov    %esp,%ebp
  80172a:	57                   	push   %edi
  80172b:	56                   	push   %esi
  80172c:	53                   	push   %ebx
  80172d:	83 ec 1c             	sub    $0x1c,%esp
  801730:	8b 75 08             	mov    0x8(%ebp),%esi
  const uint8_t *buf;
  size_t i;
  struct Pipe *p;

  p = (struct Pipe*)fd2data(fd);
  801733:	89 34 24             	mov    %esi,(%esp)
  801736:	e8 e5 f6 ff ff       	call   800e20 <fd2data>
  80173b:	89 c3                	mov    %eax,%ebx
  if (debug)
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  80173d:	bf 00 00 00 00       	mov    $0x0,%edi
  801742:	eb 45                	jmp    801789 <devpipe_write+0x62>
    while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
      // pipe is full
      // if all the readers are gone
      // (it's only writers like us now),
      // note eof
      if (_pipeisclosed(fd, p))
  801744:	89 da                	mov    %ebx,%edx
  801746:	89 f0                	mov    %esi,%eax
  801748:	e8 71 ff ff ff       	call   8016be <_pipeisclosed>
  80174d:	85 c0                	test   %eax,%eax
  80174f:	75 41                	jne    801792 <devpipe_write+0x6b>
        return 0;
      // yield and see what happens
      if (debug)
        cprintf("devpipe_write yield\n");
      sys_yield();
  801751:	e8 2e f4 ff ff       	call   800b84 <sys_yield>
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
    while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801756:	8b 43 04             	mov    0x4(%ebx),%eax
  801759:	8b 0b                	mov    (%ebx),%ecx
  80175b:	8d 51 20             	lea    0x20(%ecx),%edx
  80175e:	39 d0                	cmp    %edx,%eax
  801760:	73 e2                	jae    801744 <devpipe_write+0x1d>
        cprintf("devpipe_write yield\n");
      sys_yield();
    }
    // there's room for a byte.  store it.
    // wait to increment wpos until the byte is stored!
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801762:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801765:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801769:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80176c:	99                   	cltd   
  80176d:	c1 ea 1b             	shr    $0x1b,%edx
  801770:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801773:	83 e1 1f             	and    $0x1f,%ecx
  801776:	29 d1                	sub    %edx,%ecx
  801778:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  80177c:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
    p->p_wpos++;
  801780:	83 c0 01             	add    $0x1,%eax
  801783:	89 43 04             	mov    %eax,0x4(%ebx)
  if (debug)
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  801786:	83 c7 01             	add    $0x1,%edi
  801789:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80178c:	75 c8                	jne    801756 <devpipe_write+0x2f>
    // wait to increment wpos until the byte is stored!
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
    p->p_wpos++;
  }

  return i;
  80178e:	89 f8                	mov    %edi,%eax
  801790:	eb 05                	jmp    801797 <devpipe_write+0x70>
      // pipe is full
      // if all the readers are gone
      // (it's only writers like us now),
      // note eof
      if (_pipeisclosed(fd, p))
        return 0;
  801792:	b8 00 00 00 00       	mov    $0x0,%eax
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
    p->p_wpos++;
  }

  return i;
}
  801797:	83 c4 1c             	add    $0x1c,%esp
  80179a:	5b                   	pop    %ebx
  80179b:	5e                   	pop    %esi
  80179c:	5f                   	pop    %edi
  80179d:	5d                   	pop    %ebp
  80179e:	c3                   	ret    

0080179f <devpipe_read>:
  return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80179f:	55                   	push   %ebp
  8017a0:	89 e5                	mov    %esp,%ebp
  8017a2:	57                   	push   %edi
  8017a3:	56                   	push   %esi
  8017a4:	53                   	push   %ebx
  8017a5:	83 ec 1c             	sub    $0x1c,%esp
  8017a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint8_t *buf;
  size_t i;
  struct Pipe *p;

  p = (struct Pipe*)fd2data(fd);
  8017ab:	89 3c 24             	mov    %edi,(%esp)
  8017ae:	e8 6d f6 ff ff       	call   800e20 <fd2data>
  8017b3:	89 c3                	mov    %eax,%ebx
  if (debug)
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  8017b5:	be 00 00 00 00       	mov    $0x0,%esi
  8017ba:	eb 3d                	jmp    8017f9 <devpipe_read+0x5a>
    while (p->p_rpos == p->p_wpos) {
      // pipe is empty
      // if we got any data, return it
      if (i > 0)
  8017bc:	85 f6                	test   %esi,%esi
  8017be:	74 04                	je     8017c4 <devpipe_read+0x25>
        return i;
  8017c0:	89 f0                	mov    %esi,%eax
  8017c2:	eb 43                	jmp    801807 <devpipe_read+0x68>
      // if all the writers are gone, note eof
      if (_pipeisclosed(fd, p))
  8017c4:	89 da                	mov    %ebx,%edx
  8017c6:	89 f8                	mov    %edi,%eax
  8017c8:	e8 f1 fe ff ff       	call   8016be <_pipeisclosed>
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	75 31                	jne    801802 <devpipe_read+0x63>
        return 0;
      // yield and see what happens
      if (debug)
        cprintf("devpipe_read yield\n");
      sys_yield();
  8017d1:	e8 ae f3 ff ff       	call   800b84 <sys_yield>
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
    while (p->p_rpos == p->p_wpos) {
  8017d6:	8b 03                	mov    (%ebx),%eax
  8017d8:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017db:	74 df                	je     8017bc <devpipe_read+0x1d>
        cprintf("devpipe_read yield\n");
      sys_yield();
    }
    // there's a byte.  take it.
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017dd:	99                   	cltd   
  8017de:	c1 ea 1b             	shr    $0x1b,%edx
  8017e1:	01 d0                	add    %edx,%eax
  8017e3:	83 e0 1f             	and    $0x1f,%eax
  8017e6:	29 d0                	sub    %edx,%eax
  8017e8:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8017ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017f0:	88 04 31             	mov    %al,(%ecx,%esi,1)
    p->p_rpos++;
  8017f3:	83 03 01             	addl   $0x1,(%ebx)
  if (debug)
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  8017f6:	83 c6 01             	add    $0x1,%esi
  8017f9:	3b 75 10             	cmp    0x10(%ebp),%esi
  8017fc:	75 d8                	jne    8017d6 <devpipe_read+0x37>
    // there's a byte.  take it.
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
    p->p_rpos++;
  }
  return i;
  8017fe:	89 f0                	mov    %esi,%eax
  801800:	eb 05                	jmp    801807 <devpipe_read+0x68>
      // if we got any data, return it
      if (i > 0)
        return i;
      // if all the writers are gone, note eof
      if (_pipeisclosed(fd, p))
        return 0;
  801802:	b8 00 00 00 00       	mov    $0x0,%eax
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
    p->p_rpos++;
  }
  return i;
}
  801807:	83 c4 1c             	add    $0x1c,%esp
  80180a:	5b                   	pop    %ebx
  80180b:	5e                   	pop    %esi
  80180c:	5f                   	pop    %edi
  80180d:	5d                   	pop    %ebp
  80180e:	c3                   	ret    

0080180f <pipe>:
  uint8_t p_buf[PIPEBUFSIZ];    // data buffer
};

int
pipe(int pfd[2])
{
  80180f:	55                   	push   %ebp
  801810:	89 e5                	mov    %esp,%ebp
  801812:	56                   	push   %esi
  801813:	53                   	push   %ebx
  801814:	83 ec 30             	sub    $0x30,%esp
  int r;
  struct Fd *fd0, *fd1;
  void *va;

  // allocate the file descriptor table entries
  if ((r = fd_alloc(&fd0)) < 0
  801817:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181a:	89 04 24             	mov    %eax,(%esp)
  80181d:	e8 15 f6 ff ff       	call   800e37 <fd_alloc>
  801822:	89 c2                	mov    %eax,%edx
  801824:	85 d2                	test   %edx,%edx
  801826:	0f 88 4d 01 00 00    	js     801979 <pipe+0x16a>
      || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80182c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801833:	00 
  801834:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801837:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801842:	e8 5c f3 ff ff       	call   800ba3 <sys_page_alloc>
  801847:	89 c2                	mov    %eax,%edx
  801849:	85 d2                	test   %edx,%edx
  80184b:	0f 88 28 01 00 00    	js     801979 <pipe+0x16a>
    goto err;

  if ((r = fd_alloc(&fd1)) < 0
  801851:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801854:	89 04 24             	mov    %eax,(%esp)
  801857:	e8 db f5 ff ff       	call   800e37 <fd_alloc>
  80185c:	89 c3                	mov    %eax,%ebx
  80185e:	85 c0                	test   %eax,%eax
  801860:	0f 88 fe 00 00 00    	js     801964 <pipe+0x155>
      || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801866:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80186d:	00 
  80186e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801871:	89 44 24 04          	mov    %eax,0x4(%esp)
  801875:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80187c:	e8 22 f3 ff ff       	call   800ba3 <sys_page_alloc>
  801881:	89 c3                	mov    %eax,%ebx
  801883:	85 c0                	test   %eax,%eax
  801885:	0f 88 d9 00 00 00    	js     801964 <pipe+0x155>
    goto err1;

  // allocate the pipe structure as first data page in both
  va = fd2data(fd0);
  80188b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80188e:	89 04 24             	mov    %eax,(%esp)
  801891:	e8 8a f5 ff ff       	call   800e20 <fd2data>
  801896:	89 c6                	mov    %eax,%esi
  if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801898:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80189f:	00 
  8018a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018ab:	e8 f3 f2 ff ff       	call   800ba3 <sys_page_alloc>
  8018b0:	89 c3                	mov    %eax,%ebx
  8018b2:	85 c0                	test   %eax,%eax
  8018b4:	0f 88 97 00 00 00    	js     801951 <pipe+0x142>
    goto err2;
  if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018bd:	89 04 24             	mov    %eax,(%esp)
  8018c0:	e8 5b f5 ff ff       	call   800e20 <fd2data>
  8018c5:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8018cc:	00 
  8018cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018d1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018d8:	00 
  8018d9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018e4:	e8 0e f3 ff ff       	call   800bf7 <sys_page_map>
  8018e9:	89 c3                	mov    %eax,%ebx
  8018eb:	85 c0                	test   %eax,%eax
  8018ed:	78 52                	js     801941 <pipe+0x132>
    goto err3;

  // set up fd structures
  fd0->fd_dev_id = devpipe.dev_id;
  8018ef:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f8:	89 10                	mov    %edx,(%eax)
  fd0->fd_omode = O_RDONLY;
  8018fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018fd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

  fd1->fd_dev_id = devpipe.dev_id;
  801904:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80190a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80190d:	89 10                	mov    %edx,(%eax)
  fd1->fd_omode = O_WRONLY;
  80190f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801912:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

  if (debug)
    cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

  pfd[0] = fd2num(fd0);
  801919:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80191c:	89 04 24             	mov    %eax,(%esp)
  80191f:	e8 ec f4 ff ff       	call   800e10 <fd2num>
  801924:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801927:	89 01                	mov    %eax,(%ecx)
  pfd[1] = fd2num(fd1);
  801929:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80192c:	89 04 24             	mov    %eax,(%esp)
  80192f:	e8 dc f4 ff ff       	call   800e10 <fd2num>
  801934:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801937:	89 41 04             	mov    %eax,0x4(%ecx)
  return 0;
  80193a:	b8 00 00 00 00       	mov    $0x0,%eax
  80193f:	eb 38                	jmp    801979 <pipe+0x16a>

err3:
  sys_page_unmap(0, va);
  801941:	89 74 24 04          	mov    %esi,0x4(%esp)
  801945:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80194c:	e8 f9 f2 ff ff       	call   800c4a <sys_page_unmap>
err2:
  sys_page_unmap(0, fd1);
  801951:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801954:	89 44 24 04          	mov    %eax,0x4(%esp)
  801958:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80195f:	e8 e6 f2 ff ff       	call   800c4a <sys_page_unmap>
err1:
  sys_page_unmap(0, fd0);
  801964:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801967:	89 44 24 04          	mov    %eax,0x4(%esp)
  80196b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801972:	e8 d3 f2 ff ff       	call   800c4a <sys_page_unmap>
  801977:	89 d8                	mov    %ebx,%eax
err:
  return r;
}
  801979:	83 c4 30             	add    $0x30,%esp
  80197c:	5b                   	pop    %ebx
  80197d:	5e                   	pop    %esi
  80197e:	5d                   	pop    %ebp
  80197f:	c3                   	ret    

00801980 <pipeisclosed>:
  }
}

int
pipeisclosed(int fdnum)
{
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
  801983:	83 ec 28             	sub    $0x28,%esp
  struct Fd *fd;
  struct Pipe *p;
  int r;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  801986:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801989:	89 44 24 04          	mov    %eax,0x4(%esp)
  80198d:	8b 45 08             	mov    0x8(%ebp),%eax
  801990:	89 04 24             	mov    %eax,(%esp)
  801993:	e8 ee f4 ff ff       	call   800e86 <fd_lookup>
  801998:	89 c2                	mov    %eax,%edx
  80199a:	85 d2                	test   %edx,%edx
  80199c:	78 15                	js     8019b3 <pipeisclosed+0x33>
    return r;
  p = (struct Pipe*)fd2data(fd);
  80199e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a1:	89 04 24             	mov    %eax,(%esp)
  8019a4:	e8 77 f4 ff ff       	call   800e20 <fd2data>
  return _pipeisclosed(fd, p);
  8019a9:	89 c2                	mov    %eax,%edx
  8019ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ae:	e8 0b fd ff ff       	call   8016be <_pipeisclosed>
}
  8019b3:	c9                   	leave  
  8019b4:	c3                   	ret    
  8019b5:	66 90                	xchg   %ax,%ax
  8019b7:	66 90                	xchg   %ax,%ax
  8019b9:	66 90                	xchg   %ax,%ax
  8019bb:	66 90                	xchg   %ax,%ax
  8019bd:	66 90                	xchg   %ax,%ax
  8019bf:	90                   	nop

008019c0 <devcons_close>:
  return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  USED(fd);

  return 0;
}
  8019c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c8:	5d                   	pop    %ebp
  8019c9:	c3                   	ret    

008019ca <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019ca:	55                   	push   %ebp
  8019cb:	89 e5                	mov    %esp,%ebp
  8019cd:	83 ec 18             	sub    $0x18,%esp
  strcpy(stat->st_name, "<cons>");
  8019d0:	c7 44 24 04 b7 23 80 	movl   $0x8023b7,0x4(%esp)
  8019d7:	00 
  8019d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019db:	89 04 24             	mov    %eax,(%esp)
  8019de:	e8 a4 ed ff ff       	call   800787 <strcpy>
  return 0;
}
  8019e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e8:	c9                   	leave  
  8019e9:	c3                   	ret    

008019ea <devcons_write>:
  return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019ea:	55                   	push   %ebp
  8019eb:	89 e5                	mov    %esp,%ebp
  8019ed:	57                   	push   %edi
  8019ee:	56                   	push   %esi
  8019ef:	53                   	push   %ebx
  8019f0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  8019f6:	bb 00 00 00 00       	mov    $0x0,%ebx
    m = n - tot;
    if (m > sizeof(buf) - 1)
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
  8019fb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  801a01:	eb 31                	jmp    801a34 <devcons_write+0x4a>
    m = n - tot;
  801a03:	8b 75 10             	mov    0x10(%ebp),%esi
  801a06:	29 de                	sub    %ebx,%esi
    if (m > sizeof(buf) - 1)
  801a08:	83 fe 7f             	cmp    $0x7f,%esi
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
    m = n - tot;
  801a0b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801a10:	0f 47 f2             	cmova  %edx,%esi
    if (m > sizeof(buf) - 1)
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
  801a13:	89 74 24 08          	mov    %esi,0x8(%esp)
  801a17:	03 45 0c             	add    0xc(%ebp),%eax
  801a1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a1e:	89 3c 24             	mov    %edi,(%esp)
  801a21:	e8 fe ee ff ff       	call   800924 <memmove>
    sys_cputs(buf, m);
  801a26:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a2a:	89 3c 24             	mov    %edi,(%esp)
  801a2d:	e8 a4 f0 ff ff       	call   800ad6 <sys_cputs>
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  801a32:	01 f3                	add    %esi,%ebx
  801a34:	89 d8                	mov    %ebx,%eax
  801a36:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a39:	72 c8                	jb     801a03 <devcons_write+0x19>
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
    sys_cputs(buf, m);
  }
  return tot;
}
  801a3b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801a41:	5b                   	pop    %ebx
  801a42:	5e                   	pop    %esi
  801a43:	5f                   	pop    %edi
  801a44:	5d                   	pop    %ebp
  801a45:	c3                   	ret    

00801a46 <devcons_read>:
  return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a46:	55                   	push   %ebp
  801a47:	89 e5                	mov    %esp,%ebp
  801a49:	83 ec 08             	sub    $0x8,%esp
  int c;

  if (n == 0)
    return 0;
  801a4c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  int c;

  if (n == 0)
  801a51:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a55:	75 07                	jne    801a5e <devcons_read+0x18>
  801a57:	eb 2a                	jmp    801a83 <devcons_read+0x3d>
    return 0;

  while ((c = sys_cgetc()) == 0)
    sys_yield();
  801a59:	e8 26 f1 ff ff       	call   800b84 <sys_yield>
  int c;

  if (n == 0)
    return 0;

  while ((c = sys_cgetc()) == 0)
  801a5e:	66 90                	xchg   %ax,%ax
  801a60:	e8 8f f0 ff ff       	call   800af4 <sys_cgetc>
  801a65:	85 c0                	test   %eax,%eax
  801a67:	74 f0                	je     801a59 <devcons_read+0x13>
    sys_yield();
  if (c < 0)
  801a69:	85 c0                	test   %eax,%eax
  801a6b:	78 16                	js     801a83 <devcons_read+0x3d>
    return c;
  if (c == 0x04)        // ctl-d is eof
  801a6d:	83 f8 04             	cmp    $0x4,%eax
  801a70:	74 0c                	je     801a7e <devcons_read+0x38>
    return 0;
  *(char*)vbuf = c;
  801a72:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a75:	88 02                	mov    %al,(%edx)
  return 1;
  801a77:	b8 01 00 00 00       	mov    $0x1,%eax
  801a7c:	eb 05                	jmp    801a83 <devcons_read+0x3d>
  while ((c = sys_cgetc()) == 0)
    sys_yield();
  if (c < 0)
    return c;
  if (c == 0x04)        // ctl-d is eof
    return 0;
  801a7e:	b8 00 00 00 00       	mov    $0x0,%eax
  *(char*)vbuf = c;
  return 1;
}
  801a83:	c9                   	leave  
  801a84:	c3                   	ret    

00801a85 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a85:	55                   	push   %ebp
  801a86:	89 e5                	mov    %esp,%ebp
  801a88:	83 ec 28             	sub    $0x28,%esp
  char c = ch;
  801a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8e:	88 45 f7             	mov    %al,-0x9(%ebp)

  // Unlike standard Unix's putchar,
  // the cputchar function _always_ outputs to the system console.
  sys_cputs(&c, 1);
  801a91:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a98:	00 
  801a99:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a9c:	89 04 24             	mov    %eax,(%esp)
  801a9f:	e8 32 f0 ff ff       	call   800ad6 <sys_cputs>
}
  801aa4:	c9                   	leave  
  801aa5:	c3                   	ret    

00801aa6 <getchar>:

int
getchar(void)
{
  801aa6:	55                   	push   %ebp
  801aa7:	89 e5                	mov    %esp,%ebp
  801aa9:	83 ec 28             	sub    $0x28,%esp
  int r;

  // JOS does, however, support standard _input_ redirection,
  // allowing the user to redirect script files to the shell and such.
  // getchar() reads a character from file descriptor 0.
  r = read(0, &c, 1);
  801aac:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801ab3:	00 
  801ab4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801abb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ac2:	e8 4e f6 ff ff       	call   801115 <read>
  if (r < 0)
  801ac7:	85 c0                	test   %eax,%eax
  801ac9:	78 0f                	js     801ada <getchar+0x34>
    return r;
  if (r < 1)
  801acb:	85 c0                	test   %eax,%eax
  801acd:	7e 06                	jle    801ad5 <getchar+0x2f>
    return -E_EOF;
  return c;
  801acf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ad3:	eb 05                	jmp    801ada <getchar+0x34>
  // getchar() reads a character from file descriptor 0.
  r = read(0, &c, 1);
  if (r < 0)
    return r;
  if (r < 1)
    return -E_EOF;
  801ad5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  /* int r;
  // sys_cgetc does not block, but getchar should.
  while ((r = sys_cgetc()) == 0)
    sys_yield();
  return r; */
}
  801ada:	c9                   	leave  
  801adb:	c3                   	ret    

00801adc <iscons>:
  .dev_stat   =     devcons_stat
};

int
iscons(int fdnum)
{
  801adc:	55                   	push   %ebp
  801add:	89 e5                	mov    %esp,%ebp
  801adf:	83 ec 28             	sub    $0x28,%esp
  int r;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ae2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ae5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  801aec:	89 04 24             	mov    %eax,(%esp)
  801aef:	e8 92 f3 ff ff       	call   800e86 <fd_lookup>
  801af4:	85 c0                	test   %eax,%eax
  801af6:	78 11                	js     801b09 <iscons+0x2d>
    return r;
  return fd->fd_dev_id == devcons.dev_id;
  801af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801afb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b01:	39 10                	cmp    %edx,(%eax)
  801b03:	0f 94 c0             	sete   %al
  801b06:	0f b6 c0             	movzbl %al,%eax
}
  801b09:	c9                   	leave  
  801b0a:	c3                   	ret    

00801b0b <opencons>:

int
opencons(void)
{
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	83 ec 28             	sub    $0x28,%esp
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
  801b11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b14:	89 04 24             	mov    %eax,(%esp)
  801b17:	e8 1b f3 ff ff       	call   800e37 <fd_alloc>
    return r;
  801b1c:	89 c2                	mov    %eax,%edx
opencons(void)
{
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
  801b1e:	85 c0                	test   %eax,%eax
  801b20:	78 40                	js     801b62 <opencons+0x57>
    return r;
  if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b22:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b29:	00 
  801b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b38:	e8 66 f0 ff ff       	call   800ba3 <sys_page_alloc>
    return r;
  801b3d:	89 c2                	mov    %eax,%edx
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
    return r;
  if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b3f:	85 c0                	test   %eax,%eax
  801b41:	78 1f                	js     801b62 <opencons+0x57>
    return r;
  fd->fd_dev_id = devcons.dev_id;
  801b43:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b4c:	89 10                	mov    %edx,(%eax)
  fd->fd_omode = O_RDWR;
  801b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b51:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
  return fd2num(fd);
  801b58:	89 04 24             	mov    %eax,(%esp)
  801b5b:	e8 b0 f2 ff ff       	call   800e10 <fd2num>
  801b60:	89 c2                	mov    %eax,%edx
}
  801b62:	89 d0                	mov    %edx,%eax
  801b64:	c9                   	leave  
  801b65:	c3                   	ret    

00801b66 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b66:	55                   	push   %ebp
  801b67:	89 e5                	mov    %esp,%ebp
  801b69:	56                   	push   %esi
  801b6a:	53                   	push   %ebx
  801b6b:	83 ec 20             	sub    $0x20,%esp
  va_list ap;

  va_start(ap, fmt);
  801b6e:	8d 5d 14             	lea    0x14(%ebp),%ebx

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  801b71:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801b77:	e8 e9 ef ff ff       	call   800b65 <sys_getenvid>
  801b7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b7f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b83:	8b 55 08             	mov    0x8(%ebp),%edx
  801b86:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801b8a:	89 74 24 08          	mov    %esi,0x8(%esp)
  801b8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b92:	c7 04 24 c4 23 80 00 	movl   $0x8023c4,(%esp)
  801b99:	e8 c8 e5 ff ff       	call   800166 <cprintf>
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  801b9e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ba2:	8b 45 10             	mov    0x10(%ebp),%eax
  801ba5:	89 04 24             	mov    %eax,(%esp)
  801ba8:	e8 58 e5 ff ff       	call   800105 <vcprintf>
  cprintf("\n");
  801bad:	c7 04 24 cc 1f 80 00 	movl   $0x801fcc,(%esp)
  801bb4:	e8 ad e5 ff ff       	call   800166 <cprintf>

  // Cause a breakpoint exception
  while (1)
    asm volatile ("int3");
  801bb9:	cc                   	int3   
  801bba:	eb fd                	jmp    801bb9 <_panic+0x53>

00801bbc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bbc:	55                   	push   %ebp
  801bbd:	89 e5                	mov    %esp,%ebp
  801bbf:	56                   	push   %esi
  801bc0:	53                   	push   %ebx
  801bc1:	83 ec 10             	sub    $0x10,%esp
  801bc4:	8b 75 08             	mov    0x8(%ebp),%esi
  801bc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;
  801bcd:	85 c0                	test   %eax,%eax
  801bcf:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801bd4:	0f 44 c2             	cmove  %edx,%eax
  if ((r = sys_ipc_recv(pg)) < 0) {
  801bd7:	89 04 24             	mov    %eax,(%esp)
  801bda:	e8 da f1 ff ff       	call   800db9 <sys_ipc_recv>
  801bdf:	85 c0                	test   %eax,%eax
  801be1:	79 34                	jns    801c17 <ipc_recv+0x5b>
    if (from_env_store)
  801be3:	85 f6                	test   %esi,%esi
  801be5:	74 06                	je     801bed <ipc_recv+0x31>
      *from_env_store = 0;
  801be7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (perm_store)
  801bed:	85 db                	test   %ebx,%ebx
  801bef:	74 06                	je     801bf7 <ipc_recv+0x3b>
      *perm_store = 0;
  801bf1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    panic("sys_ipc_recv: %e", r);
  801bf7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bfb:	c7 44 24 08 e8 23 80 	movl   $0x8023e8,0x8(%esp)
  801c02:	00 
  801c03:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801c0a:	00 
  801c0b:	c7 04 24 f9 23 80 00 	movl   $0x8023f9,(%esp)
  801c12:	e8 4f ff ff ff       	call   801b66 <_panic>
  }

  if (from_env_store)
  801c17:	85 f6                	test   %esi,%esi
  801c19:	74 0a                	je     801c25 <ipc_recv+0x69>
    *from_env_store = thisenv->env_ipc_from;
  801c1b:	a1 08 40 80 00       	mov    0x804008,%eax
  801c20:	8b 40 74             	mov    0x74(%eax),%eax
  801c23:	89 06                	mov    %eax,(%esi)
  if (perm_store)
  801c25:	85 db                	test   %ebx,%ebx
  801c27:	74 0a                	je     801c33 <ipc_recv+0x77>
    *perm_store |= thisenv->env_ipc_perm;
  801c29:	a1 08 40 80 00       	mov    0x804008,%eax
  801c2e:	8b 40 78             	mov    0x78(%eax),%eax
  801c31:	09 03                	or     %eax,(%ebx)

  return thisenv->env_ipc_value;
  801c33:	a1 08 40 80 00       	mov    0x804008,%eax
  801c38:	8b 40 70             	mov    0x70(%eax),%eax

}
  801c3b:	83 c4 10             	add    $0x10,%esp
  801c3e:	5b                   	pop    %ebx
  801c3f:	5e                   	pop    %esi
  801c40:	5d                   	pop    %ebp
  801c41:	c3                   	ret    

00801c42 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
  801c45:	57                   	push   %edi
  801c46:	56                   	push   %esi
  801c47:	53                   	push   %ebx
  801c48:	83 ec 1c             	sub    $0x1c,%esp
  801c4b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c4e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;
  801c54:	85 db                	test   %ebx,%ebx
  801c56:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801c5b:	0f 44 d8             	cmove  %eax,%ebx

  while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801c5e:	eb 2a                	jmp    801c8a <ipc_send+0x48>
    if (r != -E_IPC_NOT_RECV)
  801c60:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c63:	74 20                	je     801c85 <ipc_send+0x43>
      panic("ipc_send: %e", r);
  801c65:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c69:	c7 44 24 08 03 24 80 	movl   $0x802403,0x8(%esp)
  801c70:	00 
  801c71:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801c78:	00 
  801c79:	c7 04 24 f9 23 80 00 	movl   $0x8023f9,(%esp)
  801c80:	e8 e1 fe ff ff       	call   801b66 <_panic>
    sys_yield();
  801c85:	e8 fa ee ff ff       	call   800b84 <sys_yield>
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;

  while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801c8a:	8b 45 14             	mov    0x14(%ebp),%eax
  801c8d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c91:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c95:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c99:	89 3c 24             	mov    %edi,(%esp)
  801c9c:	e8 f5 f0 ff ff       	call   800d96 <sys_ipc_try_send>
  801ca1:	85 c0                	test   %eax,%eax
  801ca3:	78 bb                	js     801c60 <ipc_send+0x1e>
    if (r != -E_IPC_NOT_RECV)
      panic("ipc_send: %e", r);
    sys_yield();
  }
}
  801ca5:	83 c4 1c             	add    $0x1c,%esp
  801ca8:	5b                   	pop    %ebx
  801ca9:	5e                   	pop    %esi
  801caa:	5f                   	pop    %edi
  801cab:	5d                   	pop    %ebp
  801cac:	c3                   	ret    

00801cad <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cad:	55                   	push   %ebp
  801cae:	89 e5                	mov    %esp,%ebp
  801cb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int i;

  for (i = 0; i < NENV; i++)
  801cb3:	b8 00 00 00 00       	mov    $0x0,%eax
    if (envs[i].env_type == type)
  801cb8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801cbb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cc1:	8b 52 50             	mov    0x50(%edx),%edx
  801cc4:	39 ca                	cmp    %ecx,%edx
  801cc6:	75 0d                	jne    801cd5 <ipc_find_env+0x28>
      return envs[i].env_id;
  801cc8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ccb:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801cd0:	8b 40 40             	mov    0x40(%eax),%eax
  801cd3:	eb 0e                	jmp    801ce3 <ipc_find_env+0x36>
envid_t
ipc_find_env(enum EnvType type)
{
  int i;

  for (i = 0; i < NENV; i++)
  801cd5:	83 c0 01             	add    $0x1,%eax
  801cd8:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cdd:	75 d9                	jne    801cb8 <ipc_find_env+0xb>
    if (envs[i].env_type == type)
      return envs[i].env_id;
  return 0;
  801cdf:	66 b8 00 00          	mov    $0x0,%ax
}
  801ce3:	5d                   	pop    %ebp
  801ce4:	c3                   	ret    

00801ce5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ce5:	55                   	push   %ebp
  801ce6:	89 e5                	mov    %esp,%ebp
  801ce8:	8b 55 08             	mov    0x8(%ebp),%edx
  pte_t pte;

  if (!(uvpd[PDX(v)] & PTE_P))
  801ceb:	89 d0                	mov    %edx,%eax
  801ced:	c1 e8 16             	shr    $0x16,%eax
  801cf0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
    return 0;
  801cf7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
  pte_t pte;

  if (!(uvpd[PDX(v)] & PTE_P))
  801cfc:	f6 c1 01             	test   $0x1,%cl
  801cff:	74 1d                	je     801d1e <pageref+0x39>
    return 0;
  pte = uvpt[PGNUM(v)];
  801d01:	c1 ea 0c             	shr    $0xc,%edx
  801d04:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  if (!(pte & PTE_P))
  801d0b:	f6 c2 01             	test   $0x1,%dl
  801d0e:	74 0e                	je     801d1e <pageref+0x39>
    return 0;
  return pages[PGNUM(pte)].pp_ref;
  801d10:	c1 ea 0c             	shr    $0xc,%edx
  801d13:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d1a:	ef 
  801d1b:	0f b7 c0             	movzwl %ax,%eax
}
  801d1e:	5d                   	pop    %ebp
  801d1f:	c3                   	ret    

00801d20 <__udivdi3>:
  801d20:	55                   	push   %ebp
  801d21:	57                   	push   %edi
  801d22:	56                   	push   %esi
  801d23:	83 ec 0c             	sub    $0xc,%esp
  801d26:	8b 44 24 28          	mov    0x28(%esp),%eax
  801d2a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801d2e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801d32:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801d36:	85 c0                	test   %eax,%eax
  801d38:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d3c:	89 ea                	mov    %ebp,%edx
  801d3e:	89 0c 24             	mov    %ecx,(%esp)
  801d41:	75 2d                	jne    801d70 <__udivdi3+0x50>
  801d43:	39 e9                	cmp    %ebp,%ecx
  801d45:	77 61                	ja     801da8 <__udivdi3+0x88>
  801d47:	85 c9                	test   %ecx,%ecx
  801d49:	89 ce                	mov    %ecx,%esi
  801d4b:	75 0b                	jne    801d58 <__udivdi3+0x38>
  801d4d:	b8 01 00 00 00       	mov    $0x1,%eax
  801d52:	31 d2                	xor    %edx,%edx
  801d54:	f7 f1                	div    %ecx
  801d56:	89 c6                	mov    %eax,%esi
  801d58:	31 d2                	xor    %edx,%edx
  801d5a:	89 e8                	mov    %ebp,%eax
  801d5c:	f7 f6                	div    %esi
  801d5e:	89 c5                	mov    %eax,%ebp
  801d60:	89 f8                	mov    %edi,%eax
  801d62:	f7 f6                	div    %esi
  801d64:	89 ea                	mov    %ebp,%edx
  801d66:	83 c4 0c             	add    $0xc,%esp
  801d69:	5e                   	pop    %esi
  801d6a:	5f                   	pop    %edi
  801d6b:	5d                   	pop    %ebp
  801d6c:	c3                   	ret    
  801d6d:	8d 76 00             	lea    0x0(%esi),%esi
  801d70:	39 e8                	cmp    %ebp,%eax
  801d72:	77 24                	ja     801d98 <__udivdi3+0x78>
  801d74:	0f bd e8             	bsr    %eax,%ebp
  801d77:	83 f5 1f             	xor    $0x1f,%ebp
  801d7a:	75 3c                	jne    801db8 <__udivdi3+0x98>
  801d7c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801d80:	39 34 24             	cmp    %esi,(%esp)
  801d83:	0f 86 9f 00 00 00    	jbe    801e28 <__udivdi3+0x108>
  801d89:	39 d0                	cmp    %edx,%eax
  801d8b:	0f 82 97 00 00 00    	jb     801e28 <__udivdi3+0x108>
  801d91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d98:	31 d2                	xor    %edx,%edx
  801d9a:	31 c0                	xor    %eax,%eax
  801d9c:	83 c4 0c             	add    $0xc,%esp
  801d9f:	5e                   	pop    %esi
  801da0:	5f                   	pop    %edi
  801da1:	5d                   	pop    %ebp
  801da2:	c3                   	ret    
  801da3:	90                   	nop
  801da4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801da8:	89 f8                	mov    %edi,%eax
  801daa:	f7 f1                	div    %ecx
  801dac:	31 d2                	xor    %edx,%edx
  801dae:	83 c4 0c             	add    $0xc,%esp
  801db1:	5e                   	pop    %esi
  801db2:	5f                   	pop    %edi
  801db3:	5d                   	pop    %ebp
  801db4:	c3                   	ret    
  801db5:	8d 76 00             	lea    0x0(%esi),%esi
  801db8:	89 e9                	mov    %ebp,%ecx
  801dba:	8b 3c 24             	mov    (%esp),%edi
  801dbd:	d3 e0                	shl    %cl,%eax
  801dbf:	89 c6                	mov    %eax,%esi
  801dc1:	b8 20 00 00 00       	mov    $0x20,%eax
  801dc6:	29 e8                	sub    %ebp,%eax
  801dc8:	89 c1                	mov    %eax,%ecx
  801dca:	d3 ef                	shr    %cl,%edi
  801dcc:	89 e9                	mov    %ebp,%ecx
  801dce:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801dd2:	8b 3c 24             	mov    (%esp),%edi
  801dd5:	09 74 24 08          	or     %esi,0x8(%esp)
  801dd9:	89 d6                	mov    %edx,%esi
  801ddb:	d3 e7                	shl    %cl,%edi
  801ddd:	89 c1                	mov    %eax,%ecx
  801ddf:	89 3c 24             	mov    %edi,(%esp)
  801de2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801de6:	d3 ee                	shr    %cl,%esi
  801de8:	89 e9                	mov    %ebp,%ecx
  801dea:	d3 e2                	shl    %cl,%edx
  801dec:	89 c1                	mov    %eax,%ecx
  801dee:	d3 ef                	shr    %cl,%edi
  801df0:	09 d7                	or     %edx,%edi
  801df2:	89 f2                	mov    %esi,%edx
  801df4:	89 f8                	mov    %edi,%eax
  801df6:	f7 74 24 08          	divl   0x8(%esp)
  801dfa:	89 d6                	mov    %edx,%esi
  801dfc:	89 c7                	mov    %eax,%edi
  801dfe:	f7 24 24             	mull   (%esp)
  801e01:	39 d6                	cmp    %edx,%esi
  801e03:	89 14 24             	mov    %edx,(%esp)
  801e06:	72 30                	jb     801e38 <__udivdi3+0x118>
  801e08:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e0c:	89 e9                	mov    %ebp,%ecx
  801e0e:	d3 e2                	shl    %cl,%edx
  801e10:	39 c2                	cmp    %eax,%edx
  801e12:	73 05                	jae    801e19 <__udivdi3+0xf9>
  801e14:	3b 34 24             	cmp    (%esp),%esi
  801e17:	74 1f                	je     801e38 <__udivdi3+0x118>
  801e19:	89 f8                	mov    %edi,%eax
  801e1b:	31 d2                	xor    %edx,%edx
  801e1d:	e9 7a ff ff ff       	jmp    801d9c <__udivdi3+0x7c>
  801e22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e28:	31 d2                	xor    %edx,%edx
  801e2a:	b8 01 00 00 00       	mov    $0x1,%eax
  801e2f:	e9 68 ff ff ff       	jmp    801d9c <__udivdi3+0x7c>
  801e34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e38:	8d 47 ff             	lea    -0x1(%edi),%eax
  801e3b:	31 d2                	xor    %edx,%edx
  801e3d:	83 c4 0c             	add    $0xc,%esp
  801e40:	5e                   	pop    %esi
  801e41:	5f                   	pop    %edi
  801e42:	5d                   	pop    %ebp
  801e43:	c3                   	ret    
  801e44:	66 90                	xchg   %ax,%ax
  801e46:	66 90                	xchg   %ax,%ax
  801e48:	66 90                	xchg   %ax,%ax
  801e4a:	66 90                	xchg   %ax,%ax
  801e4c:	66 90                	xchg   %ax,%ax
  801e4e:	66 90                	xchg   %ax,%ax

00801e50 <__umoddi3>:
  801e50:	55                   	push   %ebp
  801e51:	57                   	push   %edi
  801e52:	56                   	push   %esi
  801e53:	83 ec 14             	sub    $0x14,%esp
  801e56:	8b 44 24 28          	mov    0x28(%esp),%eax
  801e5a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801e5e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801e62:	89 c7                	mov    %eax,%edi
  801e64:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e68:	8b 44 24 30          	mov    0x30(%esp),%eax
  801e6c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801e70:	89 34 24             	mov    %esi,(%esp)
  801e73:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e77:	85 c0                	test   %eax,%eax
  801e79:	89 c2                	mov    %eax,%edx
  801e7b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e7f:	75 17                	jne    801e98 <__umoddi3+0x48>
  801e81:	39 fe                	cmp    %edi,%esi
  801e83:	76 4b                	jbe    801ed0 <__umoddi3+0x80>
  801e85:	89 c8                	mov    %ecx,%eax
  801e87:	89 fa                	mov    %edi,%edx
  801e89:	f7 f6                	div    %esi
  801e8b:	89 d0                	mov    %edx,%eax
  801e8d:	31 d2                	xor    %edx,%edx
  801e8f:	83 c4 14             	add    $0x14,%esp
  801e92:	5e                   	pop    %esi
  801e93:	5f                   	pop    %edi
  801e94:	5d                   	pop    %ebp
  801e95:	c3                   	ret    
  801e96:	66 90                	xchg   %ax,%ax
  801e98:	39 f8                	cmp    %edi,%eax
  801e9a:	77 54                	ja     801ef0 <__umoddi3+0xa0>
  801e9c:	0f bd e8             	bsr    %eax,%ebp
  801e9f:	83 f5 1f             	xor    $0x1f,%ebp
  801ea2:	75 5c                	jne    801f00 <__umoddi3+0xb0>
  801ea4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801ea8:	39 3c 24             	cmp    %edi,(%esp)
  801eab:	0f 87 e7 00 00 00    	ja     801f98 <__umoddi3+0x148>
  801eb1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801eb5:	29 f1                	sub    %esi,%ecx
  801eb7:	19 c7                	sbb    %eax,%edi
  801eb9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ebd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ec1:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ec5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801ec9:	83 c4 14             	add    $0x14,%esp
  801ecc:	5e                   	pop    %esi
  801ecd:	5f                   	pop    %edi
  801ece:	5d                   	pop    %ebp
  801ecf:	c3                   	ret    
  801ed0:	85 f6                	test   %esi,%esi
  801ed2:	89 f5                	mov    %esi,%ebp
  801ed4:	75 0b                	jne    801ee1 <__umoddi3+0x91>
  801ed6:	b8 01 00 00 00       	mov    $0x1,%eax
  801edb:	31 d2                	xor    %edx,%edx
  801edd:	f7 f6                	div    %esi
  801edf:	89 c5                	mov    %eax,%ebp
  801ee1:	8b 44 24 04          	mov    0x4(%esp),%eax
  801ee5:	31 d2                	xor    %edx,%edx
  801ee7:	f7 f5                	div    %ebp
  801ee9:	89 c8                	mov    %ecx,%eax
  801eeb:	f7 f5                	div    %ebp
  801eed:	eb 9c                	jmp    801e8b <__umoddi3+0x3b>
  801eef:	90                   	nop
  801ef0:	89 c8                	mov    %ecx,%eax
  801ef2:	89 fa                	mov    %edi,%edx
  801ef4:	83 c4 14             	add    $0x14,%esp
  801ef7:	5e                   	pop    %esi
  801ef8:	5f                   	pop    %edi
  801ef9:	5d                   	pop    %ebp
  801efa:	c3                   	ret    
  801efb:	90                   	nop
  801efc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f00:	8b 04 24             	mov    (%esp),%eax
  801f03:	be 20 00 00 00       	mov    $0x20,%esi
  801f08:	89 e9                	mov    %ebp,%ecx
  801f0a:	29 ee                	sub    %ebp,%esi
  801f0c:	d3 e2                	shl    %cl,%edx
  801f0e:	89 f1                	mov    %esi,%ecx
  801f10:	d3 e8                	shr    %cl,%eax
  801f12:	89 e9                	mov    %ebp,%ecx
  801f14:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f18:	8b 04 24             	mov    (%esp),%eax
  801f1b:	09 54 24 04          	or     %edx,0x4(%esp)
  801f1f:	89 fa                	mov    %edi,%edx
  801f21:	d3 e0                	shl    %cl,%eax
  801f23:	89 f1                	mov    %esi,%ecx
  801f25:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f29:	8b 44 24 10          	mov    0x10(%esp),%eax
  801f2d:	d3 ea                	shr    %cl,%edx
  801f2f:	89 e9                	mov    %ebp,%ecx
  801f31:	d3 e7                	shl    %cl,%edi
  801f33:	89 f1                	mov    %esi,%ecx
  801f35:	d3 e8                	shr    %cl,%eax
  801f37:	89 e9                	mov    %ebp,%ecx
  801f39:	09 f8                	or     %edi,%eax
  801f3b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801f3f:	f7 74 24 04          	divl   0x4(%esp)
  801f43:	d3 e7                	shl    %cl,%edi
  801f45:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f49:	89 d7                	mov    %edx,%edi
  801f4b:	f7 64 24 08          	mull   0x8(%esp)
  801f4f:	39 d7                	cmp    %edx,%edi
  801f51:	89 c1                	mov    %eax,%ecx
  801f53:	89 14 24             	mov    %edx,(%esp)
  801f56:	72 2c                	jb     801f84 <__umoddi3+0x134>
  801f58:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801f5c:	72 22                	jb     801f80 <__umoddi3+0x130>
  801f5e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f62:	29 c8                	sub    %ecx,%eax
  801f64:	19 d7                	sbb    %edx,%edi
  801f66:	89 e9                	mov    %ebp,%ecx
  801f68:	89 fa                	mov    %edi,%edx
  801f6a:	d3 e8                	shr    %cl,%eax
  801f6c:	89 f1                	mov    %esi,%ecx
  801f6e:	d3 e2                	shl    %cl,%edx
  801f70:	89 e9                	mov    %ebp,%ecx
  801f72:	d3 ef                	shr    %cl,%edi
  801f74:	09 d0                	or     %edx,%eax
  801f76:	89 fa                	mov    %edi,%edx
  801f78:	83 c4 14             	add    $0x14,%esp
  801f7b:	5e                   	pop    %esi
  801f7c:	5f                   	pop    %edi
  801f7d:	5d                   	pop    %ebp
  801f7e:	c3                   	ret    
  801f7f:	90                   	nop
  801f80:	39 d7                	cmp    %edx,%edi
  801f82:	75 da                	jne    801f5e <__umoddi3+0x10e>
  801f84:	8b 14 24             	mov    (%esp),%edx
  801f87:	89 c1                	mov    %eax,%ecx
  801f89:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801f8d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801f91:	eb cb                	jmp    801f5e <__umoddi3+0x10e>
  801f93:	90                   	nop
  801f94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f98:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801f9c:	0f 82 0f ff ff ff    	jb     801eb1 <__umoddi3+0x61>
  801fa2:	e9 1a ff ff ff       	jmp    801ec1 <__umoddi3+0x71>
