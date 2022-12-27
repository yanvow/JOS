
obj/user/echo.debug:     file format elf32-i386


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

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
  int i, nflag;

  nflag = 0;
  800042:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800049:	83 ff 01             	cmp    $0x1,%edi
  80004c:	7e 2b                	jle    800079 <umain+0x46>
  80004e:	c7 44 24 04 60 20 80 	movl   $0x802060,0x4(%esp)
  800055:	00 
  800056:	8b 46 04             	mov    0x4(%esi),%eax
  800059:	89 04 24             	mov    %eax,(%esp)
  80005c:	e8 eb 01 00 00       	call   80024c <strcmp>
void
umain(int argc, char **argv)
{
  int i, nflag;

  nflag = 0;
  800061:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800068:	85 c0                	test   %eax,%eax
  80006a:	75 0d                	jne    800079 <umain+0x46>
    nflag = 1;
    argc--;
  80006c:	83 ef 01             	sub    $0x1,%edi
    argv++;
  80006f:	83 c6 04             	add    $0x4,%esi
{
  int i, nflag;

  nflag = 0;
  if (argc > 1 && strcmp(argv[1], "-n") == 0) {
    nflag = 1;
  800072:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
    argc--;
    argv++;
  }
  for (i = 1; i < argc; i++) {
  800079:	bb 01 00 00 00       	mov    $0x1,%ebx
  80007e:	eb 46                	jmp    8000c6 <umain+0x93>
    if (i > 1)
  800080:	83 fb 01             	cmp    $0x1,%ebx
  800083:	7e 1c                	jle    8000a1 <umain+0x6e>
      write(1, " ", 1);
  800085:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 63 20 80 	movl   $0x802063,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80009c:	e8 61 0b 00 00       	call   800c02 <write>
    write(1, argv[i], strlen(argv[i]));
  8000a1:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8000a4:	89 04 24             	mov    %eax,(%esp)
  8000a7:	e8 b4 00 00 00       	call   800160 <strlen>
  8000ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b0:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8000b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000be:	e8 3f 0b 00 00       	call   800c02 <write>
  if (argc > 1 && strcmp(argv[1], "-n") == 0) {
    nflag = 1;
    argc--;
    argv++;
  }
  for (i = 1; i < argc; i++) {
  8000c3:	83 c3 01             	add    $0x1,%ebx
  8000c6:	39 df                	cmp    %ebx,%edi
  8000c8:	7f b6                	jg     800080 <umain+0x4d>
    if (i > 1)
      write(1, " ", 1);
    write(1, argv[i], strlen(argv[i]));
  }
  if (!nflag)
  8000ca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000ce:	75 1c                	jne    8000ec <umain+0xb9>
    write(1, "\n", 1);
  8000d0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8000d7:	00 
  8000d8:	c7 44 24 04 40 21 80 	movl   $0x802140,0x4(%esp)
  8000df:	00 
  8000e0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000e7:	e8 16 0b 00 00       	call   800c02 <write>
}
  8000ec:	83 c4 1c             	add    $0x1c,%esp
  8000ef:	5b                   	pop    %ebx
  8000f0:	5e                   	pop    %esi
  8000f1:	5f                   	pop    %edi
  8000f2:	5d                   	pop    %ebp
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
  800102:	e8 6e 04 00 00       	call   800575 <sys_getenvid>
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
  80012b:	e8 03 ff ff ff       	call   800033 <umain>

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
  800142:	e8 ae 08 00 00       	call   8009f5 <close_all>
  sys_env_destroy(0);
  800147:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80014e:	e8 d0 03 00 00       	call   800523 <sys_env_destroy>
}
  800153:	c9                   	leave  
  800154:	c3                   	ret    
  800155:	66 90                	xchg   %ax,%ax
  800157:	66 90                	xchg   %ax,%ax
  800159:	66 90                	xchg   %ax,%ax
  80015b:	66 90                	xchg   %ax,%ax
  80015d:	66 90                	xchg   %ax,%ax
  80015f:	90                   	nop

00800160 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for (n = 0; *s != '\0'; s++)
  800166:	b8 00 00 00 00       	mov    $0x0,%eax
  80016b:	eb 03                	jmp    800170 <strlen+0x10>
    n++;
  80016d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
  int n;

  for (n = 0; *s != '\0'; s++)
  800170:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800174:	75 f7                	jne    80016d <strlen+0xd>
    n++;
  return n;
}
  800176:	5d                   	pop    %ebp
  800177:	c3                   	ret    

00800178 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80017e:	8b 55 0c             	mov    0xc(%ebp),%edx
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800181:	b8 00 00 00 00       	mov    $0x0,%eax
  800186:	eb 03                	jmp    80018b <strnlen+0x13>
    n++;
  800188:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80018b:	39 d0                	cmp    %edx,%eax
  80018d:	74 06                	je     800195 <strnlen+0x1d>
  80018f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800193:	75 f3                	jne    800188 <strnlen+0x10>
    n++;
  return n;
}
  800195:	5d                   	pop    %ebp
  800196:	c3                   	ret    

00800197 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	53                   	push   %ebx
  80019b:	8b 45 08             	mov    0x8(%ebp),%eax
  80019e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  8001a1:	89 c2                	mov    %eax,%edx
  8001a3:	83 c2 01             	add    $0x1,%edx
  8001a6:	83 c1 01             	add    $0x1,%ecx
  8001a9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8001ad:	88 5a ff             	mov    %bl,-0x1(%edx)
  8001b0:	84 db                	test   %bl,%bl
  8001b2:	75 ef                	jne    8001a3 <strcpy+0xc>
    /* do nothing */;
  return ret;
}
  8001b4:	5b                   	pop    %ebx
  8001b5:	5d                   	pop    %ebp
  8001b6:	c3                   	ret    

008001b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	53                   	push   %ebx
  8001bb:	83 ec 08             	sub    $0x8,%esp
  8001be:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int len = strlen(dst);
  8001c1:	89 1c 24             	mov    %ebx,(%esp)
  8001c4:	e8 97 ff ff ff       	call   800160 <strlen>

  strcpy(dst + len, src);
  8001c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001d0:	01 d8                	add    %ebx,%eax
  8001d2:	89 04 24             	mov    %eax,(%esp)
  8001d5:	e8 bd ff ff ff       	call   800197 <strcpy>
  return dst;
}
  8001da:	89 d8                	mov    %ebx,%eax
  8001dc:	83 c4 08             	add    $0x8,%esp
  8001df:	5b                   	pop    %ebx
  8001e0:	5d                   	pop    %ebp
  8001e1:	c3                   	ret    

008001e2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  8001e2:	55                   	push   %ebp
  8001e3:	89 e5                	mov    %esp,%ebp
  8001e5:	56                   	push   %esi
  8001e6:	53                   	push   %ebx
  8001e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8001ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ed:	89 f3                	mov    %esi,%ebx
  8001ef:	03 5d 10             	add    0x10(%ebp),%ebx
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  8001f2:	89 f2                	mov    %esi,%edx
  8001f4:	eb 0f                	jmp    800205 <strncpy+0x23>
    *dst++ = *src;
  8001f6:	83 c2 01             	add    $0x1,%edx
  8001f9:	0f b6 01             	movzbl (%ecx),%eax
  8001fc:	88 42 ff             	mov    %al,-0x1(%edx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  8001ff:	80 39 01             	cmpb   $0x1,(%ecx)
  800202:	83 d9 ff             	sbb    $0xffffffff,%ecx
{
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800205:	39 da                	cmp    %ebx,%edx
  800207:	75 ed                	jne    8001f6 <strncpy+0x14>
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  }
  return ret;
}
  800209:	89 f0                	mov    %esi,%eax
  80020b:	5b                   	pop    %ebx
  80020c:	5e                   	pop    %esi
  80020d:	5d                   	pop    %ebp
  80020e:	c3                   	ret    

0080020f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	56                   	push   %esi
  800213:	53                   	push   %ebx
  800214:	8b 75 08             	mov    0x8(%ebp),%esi
  800217:	8b 55 0c             	mov    0xc(%ebp),%edx
  80021a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80021d:	89 f0                	mov    %esi,%eax
  80021f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800223:	85 c9                	test   %ecx,%ecx
  800225:	75 0b                	jne    800232 <strlcpy+0x23>
  800227:	eb 1d                	jmp    800246 <strlcpy+0x37>
    while (--size > 0 && *src != '\0')
      *dst++ = *src++;
  800229:	83 c0 01             	add    $0x1,%eax
  80022c:	83 c2 01             	add    $0x1,%edx
  80022f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
    while (--size > 0 && *src != '\0')
  800232:	39 d8                	cmp    %ebx,%eax
  800234:	74 0b                	je     800241 <strlcpy+0x32>
  800236:	0f b6 0a             	movzbl (%edx),%ecx
  800239:	84 c9                	test   %cl,%cl
  80023b:	75 ec                	jne    800229 <strlcpy+0x1a>
  80023d:	89 c2                	mov    %eax,%edx
  80023f:	eb 02                	jmp    800243 <strlcpy+0x34>
  800241:	89 c2                	mov    %eax,%edx
      *dst++ = *src++;
    *dst = '\0';
  800243:	c6 02 00             	movb   $0x0,(%edx)
  }
  return dst - dst_in;
  800246:	29 f0                	sub    %esi,%eax
}
  800248:	5b                   	pop    %ebx
  800249:	5e                   	pop    %esi
  80024a:	5d                   	pop    %ebp
  80024b:	c3                   	ret    

0080024c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800252:	8b 55 0c             	mov    0xc(%ebp),%edx
  while (*p && *p == *q)
  800255:	eb 06                	jmp    80025d <strcmp+0x11>
    p++, q++;
  800257:	83 c1 01             	add    $0x1,%ecx
  80025a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
  while (*p && *p == *q)
  80025d:	0f b6 01             	movzbl (%ecx),%eax
  800260:	84 c0                	test   %al,%al
  800262:	74 04                	je     800268 <strcmp+0x1c>
  800264:	3a 02                	cmp    (%edx),%al
  800266:	74 ef                	je     800257 <strcmp+0xb>
    p++, q++;
  return (int)((unsigned char)*p - (unsigned char)*q);
  800268:	0f b6 c0             	movzbl %al,%eax
  80026b:	0f b6 12             	movzbl (%edx),%edx
  80026e:	29 d0                	sub    %edx,%eax
}
  800270:	5d                   	pop    %ebp
  800271:	c3                   	ret    

00800272 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	53                   	push   %ebx
  800276:	8b 45 08             	mov    0x8(%ebp),%eax
  800279:	8b 55 0c             	mov    0xc(%ebp),%edx
  80027c:	89 c3                	mov    %eax,%ebx
  80027e:	03 5d 10             	add    0x10(%ebp),%ebx
  while (n > 0 && *p && *p == *q)
  800281:	eb 06                	jmp    800289 <strncmp+0x17>
    n--, p++, q++;
  800283:	83 c0 01             	add    $0x1,%eax
  800286:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
  800289:	39 d8                	cmp    %ebx,%eax
  80028b:	74 15                	je     8002a2 <strncmp+0x30>
  80028d:	0f b6 08             	movzbl (%eax),%ecx
  800290:	84 c9                	test   %cl,%cl
  800292:	74 04                	je     800298 <strncmp+0x26>
  800294:	3a 0a                	cmp    (%edx),%cl
  800296:	74 eb                	je     800283 <strncmp+0x11>
    n--, p++, q++;
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800298:	0f b6 00             	movzbl (%eax),%eax
  80029b:	0f b6 12             	movzbl (%edx),%edx
  80029e:	29 d0                	sub    %edx,%eax
  8002a0:	eb 05                	jmp    8002a7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
    n--, p++, q++;
  if (n == 0)
    return 0;
  8002a2:	b8 00 00 00 00       	mov    $0x0,%eax
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
}
  8002a7:	5b                   	pop    %ebx
  8002a8:	5d                   	pop    %ebp
  8002a9:	c3                   	ret    

008002aa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
  8002b4:	eb 07                	jmp    8002bd <strchr+0x13>
    if (*s == c)
  8002b6:	38 ca                	cmp    %cl,%dl
  8002b8:	74 0f                	je     8002c9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  for (; *s; s++)
  8002ba:	83 c0 01             	add    $0x1,%eax
  8002bd:	0f b6 10             	movzbl (%eax),%edx
  8002c0:	84 d2                	test   %dl,%dl
  8002c2:	75 f2                	jne    8002b6 <strchr+0xc>
    if (*s == c)
      return (char*)s;
  return 0;
  8002c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8002c9:	5d                   	pop    %ebp
  8002ca:	c3                   	ret    

008002cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
  8002d5:	eb 07                	jmp    8002de <strfind+0x13>
    if (*s == c)
  8002d7:	38 ca                	cmp    %cl,%dl
  8002d9:	74 0a                	je     8002e5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  for (; *s; s++)
  8002db:	83 c0 01             	add    $0x1,%eax
  8002de:	0f b6 10             	movzbl (%eax),%edx
  8002e1:	84 d2                	test   %dl,%dl
  8002e3:	75 f2                	jne    8002d7 <strfind+0xc>
    if (*s == c)
      break;
  return (char*)s;
}
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
  8002ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *p;

  if (n == 0)
  8002f3:	85 c9                	test   %ecx,%ecx
  8002f5:	74 36                	je     80032d <memset+0x46>
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
  8002f7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8002fd:	75 28                	jne    800327 <memset+0x40>
  8002ff:	f6 c1 03             	test   $0x3,%cl
  800302:	75 23                	jne    800327 <memset+0x40>
    c &= 0xFF;
  800304:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
    c = (c<<24)|(c<<16)|(c<<8)|c;
  800308:	89 d3                	mov    %edx,%ebx
  80030a:	c1 e3 08             	shl    $0x8,%ebx
  80030d:	89 d6                	mov    %edx,%esi
  80030f:	c1 e6 18             	shl    $0x18,%esi
  800312:	89 d0                	mov    %edx,%eax
  800314:	c1 e0 10             	shl    $0x10,%eax
  800317:	09 f0                	or     %esi,%eax
  800319:	09 c2                	or     %eax,%edx
  80031b:	89 d0                	mov    %edx,%eax
  80031d:	09 d8                	or     %ebx,%eax
    asm volatile ("cld; rep stosl\n"
                  :: "D" (v), "a" (c), "c" (n/4)
  80031f:	c1 e9 02             	shr    $0x2,%ecx
  if (n == 0)
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
    c &= 0xFF;
    c = (c<<24)|(c<<16)|(c<<8)|c;
    asm volatile ("cld; rep stosl\n"
  800322:	fc                   	cld    
  800323:	f3 ab                	rep stos %eax,%es:(%edi)
  800325:	eb 06                	jmp    80032d <memset+0x46>
                  :: "D" (v), "a" (c), "c" (n/4)
                  : "cc", "memory");
  } else
    asm volatile ("cld; rep stosb\n"
  800327:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032a:	fc                   	cld    
  80032b:	f3 aa                	rep stos %al,%es:(%edi)
                  :: "D" (v), "a" (c), "c" (n)
                  : "cc", "memory");
  return v;
}
  80032d:	89 f8                	mov    %edi,%eax
  80032f:	5b                   	pop    %ebx
  800330:	5e                   	pop    %esi
  800331:	5f                   	pop    %edi
  800332:	5d                   	pop    %ebp
  800333:	c3                   	ret    

00800334 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800334:	55                   	push   %ebp
  800335:	89 e5                	mov    %esp,%ebp
  800337:	57                   	push   %edi
  800338:	56                   	push   %esi
  800339:	8b 45 08             	mov    0x8(%ebp),%eax
  80033c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80033f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800342:	39 c6                	cmp    %eax,%esi
  800344:	73 35                	jae    80037b <memmove+0x47>
  800346:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800349:	39 d0                	cmp    %edx,%eax
  80034b:	73 2e                	jae    80037b <memmove+0x47>
    s += n;
    d += n;
  80034d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800350:	89 d6                	mov    %edx,%esi
  800352:	09 fe                	or     %edi,%esi
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800354:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80035a:	75 13                	jne    80036f <memmove+0x3b>
  80035c:	f6 c1 03             	test   $0x3,%cl
  80035f:	75 0e                	jne    80036f <memmove+0x3b>
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800361:	83 ef 04             	sub    $0x4,%edi
  800364:	8d 72 fc             	lea    -0x4(%edx),%esi
  800367:	c1 e9 02             	shr    $0x2,%ecx
  d = dst;
  if (s < d && s + n > d) {
    s += n;
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
  80036a:	fd                   	std    
  80036b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80036d:	eb 09                	jmp    800378 <memmove+0x44>
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80036f:	83 ef 01             	sub    $0x1,%edi
  800372:	8d 72 ff             	lea    -0x1(%edx),%esi
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
  800375:	fd                   	std    
  800376:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  800378:	fc                   	cld    
  800379:	eb 1d                	jmp    800398 <memmove+0x64>
  80037b:	89 f2                	mov    %esi,%edx
  80037d:	09 c2                	or     %eax,%edx
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80037f:	f6 c2 03             	test   $0x3,%dl
  800382:	75 0f                	jne    800393 <memmove+0x5f>
  800384:	f6 c1 03             	test   $0x3,%cl
  800387:	75 0a                	jne    800393 <memmove+0x5f>
      asm volatile ("cld; rep movsl\n"
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800389:	c1 e9 02             	shr    $0x2,%ecx
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("cld; rep movsl\n"
  80038c:	89 c7                	mov    %eax,%edi
  80038e:	fc                   	cld    
  80038f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800391:	eb 05                	jmp    800398 <memmove+0x64>
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("cld; rep movsb\n"
  800393:	89 c7                	mov    %eax,%edi
  800395:	fc                   	cld    
  800396:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d), "S" (s), "c" (n) : "cc", "memory");
  }
  return dst;
}
  800398:	5e                   	pop    %esi
  800399:	5f                   	pop    %edi
  80039a:	5d                   	pop    %ebp
  80039b:	c3                   	ret    

0080039c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80039c:	55                   	push   %ebp
  80039d:	89 e5                	mov    %esp,%ebp
  80039f:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
  8003a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8003a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b3:	89 04 24             	mov    %eax,(%esp)
  8003b6:	e8 79 ff ff ff       	call   800334 <memmove>
}
  8003bb:	c9                   	leave  
  8003bc:	c3                   	ret    

008003bd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	56                   	push   %esi
  8003c1:	53                   	push   %ebx
  8003c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003c8:	89 d6                	mov    %edx,%esi
  8003ca:	03 75 10             	add    0x10(%ebp),%esi
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
  8003cd:	eb 1a                	jmp    8003e9 <memcmp+0x2c>
    if (*s1 != *s2)
  8003cf:	0f b6 02             	movzbl (%edx),%eax
  8003d2:	0f b6 19             	movzbl (%ecx),%ebx
  8003d5:	38 d8                	cmp    %bl,%al
  8003d7:	74 0a                	je     8003e3 <memcmp+0x26>
      return (int)*s1 - (int)*s2;
  8003d9:	0f b6 c0             	movzbl %al,%eax
  8003dc:	0f b6 db             	movzbl %bl,%ebx
  8003df:	29 d8                	sub    %ebx,%eax
  8003e1:	eb 0f                	jmp    8003f2 <memcmp+0x35>
    s1++, s2++;
  8003e3:	83 c2 01             	add    $0x1,%edx
  8003e6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
  8003e9:	39 f2                	cmp    %esi,%edx
  8003eb:	75 e2                	jne    8003cf <memcmp+0x12>
    if (*s1 != *s2)
      return (int)*s1 - (int)*s2;
    s1++, s2++;
  }

  return 0;
  8003ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003f2:	5b                   	pop    %ebx
  8003f3:	5e                   	pop    %esi
  8003f4:	5d                   	pop    %ebp
  8003f5:	c3                   	ret    

008003f6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8003f6:	55                   	push   %ebp
  8003f7:	89 e5                	mov    %esp,%ebp
  8003f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  const void *ends = (const char*)s + n;
  8003ff:	89 c2                	mov    %eax,%edx
  800401:	03 55 10             	add    0x10(%ebp),%edx

  for (; s < ends; s++)
  800404:	eb 07                	jmp    80040d <memfind+0x17>
    if (*(const unsigned char*)s == (unsigned char)c)
  800406:	38 08                	cmp    %cl,(%eax)
  800408:	74 07                	je     800411 <memfind+0x1b>
void *
memfind(const void *s, int c, size_t n)
{
  const void *ends = (const char*)s + n;

  for (; s < ends; s++)
  80040a:	83 c0 01             	add    $0x1,%eax
  80040d:	39 d0                	cmp    %edx,%eax
  80040f:	72 f5                	jb     800406 <memfind+0x10>
    if (*(const unsigned char*)s == (unsigned char)c)
      break;
  return (void*)s;
}
  800411:	5d                   	pop    %ebp
  800412:	c3                   	ret    

00800413 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	57                   	push   %edi
  800417:	56                   	push   %esi
  800418:	53                   	push   %ebx
  800419:	8b 55 08             	mov    0x8(%ebp),%edx
  80041c:	8b 45 10             	mov    0x10(%ebp),%eax
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  80041f:	eb 03                	jmp    800424 <strtol+0x11>
    s++;
  800421:	83 c2 01             	add    $0x1,%edx
{
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800424:	0f b6 0a             	movzbl (%edx),%ecx
  800427:	80 f9 09             	cmp    $0x9,%cl
  80042a:	74 f5                	je     800421 <strtol+0xe>
  80042c:	80 f9 20             	cmp    $0x20,%cl
  80042f:	74 f0                	je     800421 <strtol+0xe>
    s++;

  // plus/minus sign
  if (*s == '+')
  800431:	80 f9 2b             	cmp    $0x2b,%cl
  800434:	75 0a                	jne    800440 <strtol+0x2d>
    s++;
  800436:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
  int neg = 0;
  800439:	bf 00 00 00 00       	mov    $0x0,%edi
  80043e:	eb 11                	jmp    800451 <strtol+0x3e>
  800440:	bf 00 00 00 00       	mov    $0x0,%edi
    s++;

  // plus/minus sign
  if (*s == '+')
    s++;
  else if (*s == '-')
  800445:	80 f9 2d             	cmp    $0x2d,%cl
  800448:	75 07                	jne    800451 <strtol+0x3e>
    s++, neg = 1;
  80044a:	8d 52 01             	lea    0x1(%edx),%edx
  80044d:	66 bf 01 00          	mov    $0x1,%di

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800451:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800456:	75 15                	jne    80046d <strtol+0x5a>
  800458:	80 3a 30             	cmpb   $0x30,(%edx)
  80045b:	75 10                	jne    80046d <strtol+0x5a>
  80045d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800461:	75 0a                	jne    80046d <strtol+0x5a>
    s += 2, base = 16;
  800463:	83 c2 02             	add    $0x2,%edx
  800466:	b8 10 00 00 00       	mov    $0x10,%eax
  80046b:	eb 10                	jmp    80047d <strtol+0x6a>
  else if (base == 0 && s[0] == '0')
  80046d:	85 c0                	test   %eax,%eax
  80046f:	75 0c                	jne    80047d <strtol+0x6a>
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800471:	b0 0a                	mov    $0xa,%al
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
  800473:	80 3a 30             	cmpb   $0x30,(%edx)
  800476:	75 05                	jne    80047d <strtol+0x6a>
    s++, base = 8;
  800478:	83 c2 01             	add    $0x1,%edx
  80047b:	b0 08                	mov    $0x8,%al
  else if (base == 0)
    base = 10;
  80047d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800482:	89 45 10             	mov    %eax,0x10(%ebp)

  // digits
  while (1) {
    int dig;

    if (*s >= '0' && *s <= '9')
  800485:	0f b6 0a             	movzbl (%edx),%ecx
  800488:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80048b:	89 f0                	mov    %esi,%eax
  80048d:	3c 09                	cmp    $0x9,%al
  80048f:	77 08                	ja     800499 <strtol+0x86>
      dig = *s - '0';
  800491:	0f be c9             	movsbl %cl,%ecx
  800494:	83 e9 30             	sub    $0x30,%ecx
  800497:	eb 20                	jmp    8004b9 <strtol+0xa6>
    else if (*s >= 'a' && *s <= 'z')
  800499:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80049c:	89 f0                	mov    %esi,%eax
  80049e:	3c 19                	cmp    $0x19,%al
  8004a0:	77 08                	ja     8004aa <strtol+0x97>
      dig = *s - 'a' + 10;
  8004a2:	0f be c9             	movsbl %cl,%ecx
  8004a5:	83 e9 57             	sub    $0x57,%ecx
  8004a8:	eb 0f                	jmp    8004b9 <strtol+0xa6>
    else if (*s >= 'A' && *s <= 'Z')
  8004aa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  8004ad:	89 f0                	mov    %esi,%eax
  8004af:	3c 19                	cmp    $0x19,%al
  8004b1:	77 16                	ja     8004c9 <strtol+0xb6>
      dig = *s - 'A' + 10;
  8004b3:	0f be c9             	movsbl %cl,%ecx
  8004b6:	83 e9 37             	sub    $0x37,%ecx
    else
      break;
    if (dig >= base)
  8004b9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  8004bc:	7d 0f                	jge    8004cd <strtol+0xba>
      break;
    s++, val = (val * base) + dig;
  8004be:	83 c2 01             	add    $0x1,%edx
  8004c1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  8004c5:	01 cb                	add    %ecx,%ebx
    // we don't properly detect overflow!
  }
  8004c7:	eb bc                	jmp    800485 <strtol+0x72>
  8004c9:	89 d8                	mov    %ebx,%eax
  8004cb:	eb 02                	jmp    8004cf <strtol+0xbc>
  8004cd:	89 d8                	mov    %ebx,%eax

  if (endptr)
  8004cf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8004d3:	74 05                	je     8004da <strtol+0xc7>
    *endptr = (char*)s;
  8004d5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004d8:	89 16                	mov    %edx,(%esi)
  return neg ? -val : val;
  8004da:	f7 d8                	neg    %eax
  8004dc:	85 ff                	test   %edi,%edi
  8004de:	0f 44 c3             	cmove  %ebx,%eax
}
  8004e1:	5b                   	pop    %ebx
  8004e2:	5e                   	pop    %esi
  8004e3:	5f                   	pop    %edi
  8004e4:	5d                   	pop    %ebp
  8004e5:	c3                   	ret    

008004e6 <sys_cputs>:
  return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8004e6:	55                   	push   %ebp
  8004e7:	89 e5                	mov    %esp,%ebp
  8004e9:	57                   	push   %edi
  8004ea:	56                   	push   %esi
  8004eb:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8004ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8004f7:	89 c3                	mov    %eax,%ebx
  8004f9:	89 c7                	mov    %eax,%edi
  8004fb:	89 c6                	mov    %eax,%esi
  8004fd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
  syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8004ff:	5b                   	pop    %ebx
  800500:	5e                   	pop    %esi
  800501:	5f                   	pop    %edi
  800502:	5d                   	pop    %ebp
  800503:	c3                   	ret    

00800504 <sys_cgetc>:

int
sys_cgetc(void)
{
  800504:	55                   	push   %ebp
  800505:	89 e5                	mov    %esp,%ebp
  800507:	57                   	push   %edi
  800508:	56                   	push   %esi
  800509:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  80050a:	ba 00 00 00 00       	mov    $0x0,%edx
  80050f:	b8 01 00 00 00       	mov    $0x1,%eax
  800514:	89 d1                	mov    %edx,%ecx
  800516:	89 d3                	mov    %edx,%ebx
  800518:	89 d7                	mov    %edx,%edi
  80051a:	89 d6                	mov    %edx,%esi
  80051c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80051e:	5b                   	pop    %ebx
  80051f:	5e                   	pop    %esi
  800520:	5f                   	pop    %edi
  800521:	5d                   	pop    %ebp
  800522:	c3                   	ret    

00800523 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800523:	55                   	push   %ebp
  800524:	89 e5                	mov    %esp,%ebp
  800526:	57                   	push   %edi
  800527:	56                   	push   %esi
  800528:	53                   	push   %ebx
  800529:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  80052c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800531:	b8 03 00 00 00       	mov    $0x3,%eax
  800536:	8b 55 08             	mov    0x8(%ebp),%edx
  800539:	89 cb                	mov    %ecx,%ebx
  80053b:	89 cf                	mov    %ecx,%edi
  80053d:	89 ce                	mov    %ecx,%esi
  80053f:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800541:	85 c0                	test   %eax,%eax
  800543:	7e 28                	jle    80056d <sys_env_destroy+0x4a>
    panic("syscall %d returned %d (> 0)", num, ret);
  800545:	89 44 24 10          	mov    %eax,0x10(%esp)
  800549:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800550:	00 
  800551:	c7 44 24 08 6f 20 80 	movl   $0x80206f,0x8(%esp)
  800558:	00 
  800559:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800560:	00 
  800561:	c7 04 24 8c 20 80 00 	movl   $0x80208c,(%esp)
  800568:	e8 09 10 00 00       	call   801576 <_panic>

int
sys_env_destroy(envid_t envid)
{
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80056d:	83 c4 2c             	add    $0x2c,%esp
  800570:	5b                   	pop    %ebx
  800571:	5e                   	pop    %esi
  800572:	5f                   	pop    %edi
  800573:	5d                   	pop    %ebp
  800574:	c3                   	ret    

00800575 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800575:	55                   	push   %ebp
  800576:	89 e5                	mov    %esp,%ebp
  800578:	57                   	push   %edi
  800579:	56                   	push   %esi
  80057a:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  80057b:	ba 00 00 00 00       	mov    $0x0,%edx
  800580:	b8 02 00 00 00       	mov    $0x2,%eax
  800585:	89 d1                	mov    %edx,%ecx
  800587:	89 d3                	mov    %edx,%ebx
  800589:	89 d7                	mov    %edx,%edi
  80058b:	89 d6                	mov    %edx,%esi
  80058d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80058f:	5b                   	pop    %ebx
  800590:	5e                   	pop    %esi
  800591:	5f                   	pop    %edi
  800592:	5d                   	pop    %ebp
  800593:	c3                   	ret    

00800594 <sys_yield>:

void
sys_yield(void)
{
  800594:	55                   	push   %ebp
  800595:	89 e5                	mov    %esp,%ebp
  800597:	57                   	push   %edi
  800598:	56                   	push   %esi
  800599:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  80059a:	ba 00 00 00 00       	mov    $0x0,%edx
  80059f:	b8 0b 00 00 00       	mov    $0xb,%eax
  8005a4:	89 d1                	mov    %edx,%ecx
  8005a6:	89 d3                	mov    %edx,%ebx
  8005a8:	89 d7                	mov    %edx,%edi
  8005aa:	89 d6                	mov    %edx,%esi
  8005ac:	cd 30                	int    $0x30

void
sys_yield(void)
{
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8005ae:	5b                   	pop    %ebx
  8005af:	5e                   	pop    %esi
  8005b0:	5f                   	pop    %edi
  8005b1:	5d                   	pop    %ebp
  8005b2:	c3                   	ret    

008005b3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8005b3:	55                   	push   %ebp
  8005b4:	89 e5                	mov    %esp,%ebp
  8005b6:	57                   	push   %edi
  8005b7:	56                   	push   %esi
  8005b8:	53                   	push   %ebx
  8005b9:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8005bc:	be 00 00 00 00       	mov    $0x0,%esi
  8005c1:	b8 04 00 00 00       	mov    $0x4,%eax
  8005c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8005cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005cf:	89 f7                	mov    %esi,%edi
  8005d1:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  8005d3:	85 c0                	test   %eax,%eax
  8005d5:	7e 28                	jle    8005ff <sys_page_alloc+0x4c>
    panic("syscall %d returned %d (> 0)", num, ret);
  8005d7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005db:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8005e2:	00 
  8005e3:	c7 44 24 08 6f 20 80 	movl   $0x80206f,0x8(%esp)
  8005ea:	00 
  8005eb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8005f2:	00 
  8005f3:	c7 04 24 8c 20 80 00 	movl   $0x80208c,(%esp)
  8005fa:	e8 77 0f 00 00       	call   801576 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  return syscall(SYS_page_alloc, 1, envid, (uint32_t)va, perm, 0, 0);
}
  8005ff:	83 c4 2c             	add    $0x2c,%esp
  800602:	5b                   	pop    %ebx
  800603:	5e                   	pop    %esi
  800604:	5f                   	pop    %edi
  800605:	5d                   	pop    %ebp
  800606:	c3                   	ret    

00800607 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800607:	55                   	push   %ebp
  800608:	89 e5                	mov    %esp,%ebp
  80060a:	57                   	push   %edi
  80060b:	56                   	push   %esi
  80060c:	53                   	push   %ebx
  80060d:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800610:	b8 05 00 00 00       	mov    $0x5,%eax
  800615:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800618:	8b 55 08             	mov    0x8(%ebp),%edx
  80061b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80061e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800621:	8b 75 18             	mov    0x18(%ebp),%esi
  800624:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800626:	85 c0                	test   %eax,%eax
  800628:	7e 28                	jle    800652 <sys_page_map+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  80062a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80062e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800635:	00 
  800636:	c7 44 24 08 6f 20 80 	movl   $0x80206f,0x8(%esp)
  80063d:	00 
  80063e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800645:	00 
  800646:	c7 04 24 8c 20 80 00 	movl   $0x80208c,(%esp)
  80064d:	e8 24 0f 00 00       	call   801576 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  return syscall(SYS_page_map, 1, srcenv, (uint32_t)srcva, dstenv, (uint32_t)dstva, perm);
}
  800652:	83 c4 2c             	add    $0x2c,%esp
  800655:	5b                   	pop    %ebx
  800656:	5e                   	pop    %esi
  800657:	5f                   	pop    %edi
  800658:	5d                   	pop    %ebp
  800659:	c3                   	ret    

0080065a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80065a:	55                   	push   %ebp
  80065b:	89 e5                	mov    %esp,%ebp
  80065d:	57                   	push   %edi
  80065e:	56                   	push   %esi
  80065f:	53                   	push   %ebx
  800660:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800663:	bb 00 00 00 00       	mov    $0x0,%ebx
  800668:	b8 06 00 00 00       	mov    $0x6,%eax
  80066d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800670:	8b 55 08             	mov    0x8(%ebp),%edx
  800673:	89 df                	mov    %ebx,%edi
  800675:	89 de                	mov    %ebx,%esi
  800677:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800679:	85 c0                	test   %eax,%eax
  80067b:	7e 28                	jle    8006a5 <sys_page_unmap+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  80067d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800681:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800688:	00 
  800689:	c7 44 24 08 6f 20 80 	movl   $0x80206f,0x8(%esp)
  800690:	00 
  800691:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800698:	00 
  800699:	c7 04 24 8c 20 80 00 	movl   $0x80208c,(%esp)
  8006a0:	e8 d1 0e 00 00       	call   801576 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
  return syscall(SYS_page_unmap, 1, envid, (uint32_t)va, 0, 0, 0);
}
  8006a5:	83 c4 2c             	add    $0x2c,%esp
  8006a8:	5b                   	pop    %ebx
  8006a9:	5e                   	pop    %esi
  8006aa:	5f                   	pop    %edi
  8006ab:	5d                   	pop    %ebp
  8006ac:	c3                   	ret    

008006ad <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8006ad:	55                   	push   %ebp
  8006ae:	89 e5                	mov    %esp,%ebp
  8006b0:	57                   	push   %edi
  8006b1:	56                   	push   %esi
  8006b2:	53                   	push   %ebx
  8006b3:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8006b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006bb:	b8 08 00 00 00       	mov    $0x8,%eax
  8006c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8006c6:	89 df                	mov    %ebx,%edi
  8006c8:	89 de                	mov    %ebx,%esi
  8006ca:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  8006cc:	85 c0                	test   %eax,%eax
  8006ce:	7e 28                	jle    8006f8 <sys_env_set_status+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  8006d0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006d4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8006db:	00 
  8006dc:	c7 44 24 08 6f 20 80 	movl   $0x80206f,0x8(%esp)
  8006e3:	00 
  8006e4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8006eb:	00 
  8006ec:	c7 04 24 8c 20 80 00 	movl   $0x80208c,(%esp)
  8006f3:	e8 7e 0e 00 00       	call   801576 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8006f8:	83 c4 2c             	add    $0x2c,%esp
  8006fb:	5b                   	pop    %ebx
  8006fc:	5e                   	pop    %esi
  8006fd:	5f                   	pop    %edi
  8006fe:	5d                   	pop    %ebp
  8006ff:	c3                   	ret    

00800700 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	57                   	push   %edi
  800704:	56                   	push   %esi
  800705:	53                   	push   %ebx
  800706:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800709:	bb 00 00 00 00       	mov    $0x0,%ebx
  80070e:	b8 09 00 00 00       	mov    $0x9,%eax
  800713:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800716:	8b 55 08             	mov    0x8(%ebp),%edx
  800719:	89 df                	mov    %ebx,%edi
  80071b:	89 de                	mov    %ebx,%esi
  80071d:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  80071f:	85 c0                	test   %eax,%eax
  800721:	7e 28                	jle    80074b <sys_env_set_trapframe+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800723:	89 44 24 10          	mov    %eax,0x10(%esp)
  800727:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80072e:	00 
  80072f:	c7 44 24 08 6f 20 80 	movl   $0x80206f,0x8(%esp)
  800736:	00 
  800737:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80073e:	00 
  80073f:	c7 04 24 8c 20 80 00 	movl   $0x80208c,(%esp)
  800746:	e8 2b 0e 00 00       	call   801576 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t)tf, 0, 0, 0);
}
  80074b:	83 c4 2c             	add    $0x2c,%esp
  80074e:	5b                   	pop    %ebx
  80074f:	5e                   	pop    %esi
  800750:	5f                   	pop    %edi
  800751:	5d                   	pop    %ebp
  800752:	c3                   	ret    

00800753 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	57                   	push   %edi
  800757:	56                   	push   %esi
  800758:	53                   	push   %ebx
  800759:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  80075c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800761:	b8 0a 00 00 00       	mov    $0xa,%eax
  800766:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800769:	8b 55 08             	mov    0x8(%ebp),%edx
  80076c:	89 df                	mov    %ebx,%edi
  80076e:	89 de                	mov    %ebx,%esi
  800770:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800772:	85 c0                	test   %eax,%eax
  800774:	7e 28                	jle    80079e <sys_env_set_pgfault_upcall+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800776:	89 44 24 10          	mov    %eax,0x10(%esp)
  80077a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800781:	00 
  800782:	c7 44 24 08 6f 20 80 	movl   $0x80206f,0x8(%esp)
  800789:	00 
  80078a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800791:	00 
  800792:	c7 04 24 8c 20 80 00 	movl   $0x80208c,(%esp)
  800799:	e8 d8 0d 00 00       	call   801576 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80079e:	83 c4 2c             	add    $0x2c,%esp
  8007a1:	5b                   	pop    %ebx
  8007a2:	5e                   	pop    %esi
  8007a3:	5f                   	pop    %edi
  8007a4:	5d                   	pop    %ebp
  8007a5:	c3                   	ret    

008007a6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	57                   	push   %edi
  8007aa:	56                   	push   %esi
  8007ab:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8007ac:	be 00 00 00 00       	mov    $0x0,%esi
  8007b1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8007b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8007bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8007bf:	8b 7d 14             	mov    0x14(%ebp),%edi
  8007c2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t)srcva, perm, 0);
}
  8007c4:	5b                   	pop    %ebx
  8007c5:	5e                   	pop    %esi
  8007c6:	5f                   	pop    %edi
  8007c7:	5d                   	pop    %ebp
  8007c8:	c3                   	ret    

008007c9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	57                   	push   %edi
  8007cd:	56                   	push   %esi
  8007ce:	53                   	push   %ebx
  8007cf:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8007d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d7:	b8 0d 00 00 00       	mov    $0xd,%eax
  8007dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8007df:	89 cb                	mov    %ecx,%ebx
  8007e1:	89 cf                	mov    %ecx,%edi
  8007e3:	89 ce                	mov    %ecx,%esi
  8007e5:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  8007e7:	85 c0                	test   %eax,%eax
  8007e9:	7e 28                	jle    800813 <sys_ipc_recv+0x4a>
    panic("syscall %d returned %d (> 0)", num, ret);
  8007eb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007ef:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8007f6:	00 
  8007f7:	c7 44 24 08 6f 20 80 	movl   $0x80206f,0x8(%esp)
  8007fe:	00 
  8007ff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800806:	00 
  800807:	c7 04 24 8c 20 80 00 	movl   $0x80208c,(%esp)
  80080e:	e8 63 0d 00 00       	call   801576 <_panic>

int
sys_ipc_recv(void *dstva)
{
  return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800813:	83 c4 2c             	add    $0x2c,%esp
  800816:	5b                   	pop    %ebx
  800817:	5e                   	pop    %esi
  800818:	5f                   	pop    %edi
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    
  80081b:	66 90                	xchg   %ax,%ax
  80081d:	66 90                	xchg   %ax,%ax
  80081f:	90                   	nop

00800820 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  800823:	8b 45 08             	mov    0x8(%ebp),%eax
  800826:	05 00 00 00 30       	add    $0x30000000,%eax
  80082b:	c1 e8 0c             	shr    $0xc,%eax
}
  80082e:	5d                   	pop    %ebp
  80082f:	c3                   	ret    

00800830 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  800833:	8b 45 08             	mov    0x8(%ebp),%eax
  800836:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
  return INDEX2DATA(fd2num(fd));
  80083b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800840:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
  int i;
  struct Fd *fd;

  for (i = 0; i < MAXFD; i++) {
    fd = INDEX2FD(i);
    if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800852:	89 c2                	mov    %eax,%edx
  800854:	c1 ea 16             	shr    $0x16,%edx
  800857:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80085e:	f6 c2 01             	test   $0x1,%dl
  800861:	74 11                	je     800874 <fd_alloc+0x2d>
  800863:	89 c2                	mov    %eax,%edx
  800865:	c1 ea 0c             	shr    $0xc,%edx
  800868:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80086f:	f6 c2 01             	test   $0x1,%dl
  800872:	75 09                	jne    80087d <fd_alloc+0x36>
      *fd_store = fd;
  800874:	89 01                	mov    %eax,(%ecx)
      return 0;
  800876:	b8 00 00 00 00       	mov    $0x0,%eax
  80087b:	eb 17                	jmp    800894 <fd_alloc+0x4d>
  80087d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
  int i;
  struct Fd *fd;

  for (i = 0; i < MAXFD; i++) {
  800882:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800887:	75 c9                	jne    800852 <fd_alloc+0xb>
    if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
      *fd_store = fd;
      return 0;
    }
  }
  *fd_store = 0;
  800889:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
  return -E_MAX_OPEN;
  80088f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	8b 45 08             	mov    0x8(%ebp),%eax
  struct Fd *fd;

  if (fdnum < 0 || fdnum >= MAXFD) {
  80089c:	83 f8 1f             	cmp    $0x1f,%eax
  80089f:	77 36                	ja     8008d7 <fd_lookup+0x41>
    if (debug)
      cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  fd = INDEX2FD(fdnum);
  8008a1:	c1 e0 0c             	shl    $0xc,%eax
  8008a4:	2d 00 00 00 30       	sub    $0x30000000,%eax
  if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8008a9:	89 c2                	mov    %eax,%edx
  8008ab:	c1 ea 16             	shr    $0x16,%edx
  8008ae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8008b5:	f6 c2 01             	test   $0x1,%dl
  8008b8:	74 24                	je     8008de <fd_lookup+0x48>
  8008ba:	89 c2                	mov    %eax,%edx
  8008bc:	c1 ea 0c             	shr    $0xc,%edx
  8008bf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8008c6:	f6 c2 01             	test   $0x1,%dl
  8008c9:	74 1a                	je     8008e5 <fd_lookup+0x4f>
    if (debug)
      cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  *fd_store = fd;
  8008cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ce:	89 02                	mov    %eax,(%edx)
  return 0;
  8008d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d5:	eb 13                	jmp    8008ea <fd_lookup+0x54>
  struct Fd *fd;

  if (fdnum < 0 || fdnum >= MAXFD) {
    if (debug)
      cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  8008d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008dc:	eb 0c                	jmp    8008ea <fd_lookup+0x54>
  }
  fd = INDEX2FD(fdnum);
  if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
    if (debug)
      cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  8008de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008e3:	eb 05                	jmp    8008ea <fd_lookup+0x54>
  8008e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  }
  *fd_store = fd;
  return 0;
}
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    

008008ec <dev_lookup>:
  0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	83 ec 18             	sub    $0x18,%esp
  8008f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f5:	ba 18 21 80 00       	mov    $0x802118,%edx
  int i;

  for (i = 0; devtab[i]; i++)
  8008fa:	eb 13                	jmp    80090f <dev_lookup+0x23>
  8008fc:	83 c2 04             	add    $0x4,%edx
    if (devtab[i]->dev_id == dev_id) {
  8008ff:	39 08                	cmp    %ecx,(%eax)
  800901:	75 0c                	jne    80090f <dev_lookup+0x23>
      *dev = devtab[i];
  800903:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800906:	89 01                	mov    %eax,(%ecx)
      return 0;
  800908:	b8 00 00 00 00       	mov    $0x0,%eax
  80090d:	eb 30                	jmp    80093f <dev_lookup+0x53>
int
dev_lookup(int dev_id, struct Dev **dev)
{
  int i;

  for (i = 0; devtab[i]; i++)
  80090f:	8b 02                	mov    (%edx),%eax
  800911:	85 c0                	test   %eax,%eax
  800913:	75 e7                	jne    8008fc <dev_lookup+0x10>
    if (devtab[i]->dev_id == dev_id) {
      *dev = devtab[i];
      return 0;
    }
  cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800915:	a1 04 40 80 00       	mov    0x804004,%eax
  80091a:	8b 40 48             	mov    0x48(%eax),%eax
  80091d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800921:	89 44 24 04          	mov    %eax,0x4(%esp)
  800925:	c7 04 24 9c 20 80 00 	movl   $0x80209c,(%esp)
  80092c:	e8 3e 0d 00 00       	call   80166f <cprintf>
  *dev = 0;
  800931:	8b 45 0c             	mov    0xc(%ebp),%eax
  800934:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  return -E_INVAL;
  80093a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80093f:	c9                   	leave  
  800940:	c3                   	ret    

00800941 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	56                   	push   %esi
  800945:	53                   	push   %ebx
  800946:	83 ec 20             	sub    $0x20,%esp
  800949:	8b 75 08             	mov    0x8(%ebp),%esi
  80094c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct Fd *fd2;
  struct Dev *dev;
  int r;

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80094f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800952:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  800956:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80095c:	c1 e8 0c             	shr    $0xc,%eax
{
  struct Fd *fd2;
  struct Dev *dev;
  int r;

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80095f:	89 04 24             	mov    %eax,(%esp)
  800962:	e8 2f ff ff ff       	call   800896 <fd_lookup>
  800967:	85 c0                	test   %eax,%eax
  800969:	78 05                	js     800970 <fd_close+0x2f>
      || fd != fd2)
  80096b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80096e:	74 0c                	je     80097c <fd_close+0x3b>
    return must_exist ? r : 0;
  800970:	84 db                	test   %bl,%bl
  800972:	ba 00 00 00 00       	mov    $0x0,%edx
  800977:	0f 44 c2             	cmove  %edx,%eax
  80097a:	eb 3f                	jmp    8009bb <fd_close+0x7a>
  if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80097c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80097f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800983:	8b 06                	mov    (%esi),%eax
  800985:	89 04 24             	mov    %eax,(%esp)
  800988:	e8 5f ff ff ff       	call   8008ec <dev_lookup>
  80098d:	89 c3                	mov    %eax,%ebx
  80098f:	85 c0                	test   %eax,%eax
  800991:	78 16                	js     8009a9 <fd_close+0x68>
    if (dev->dev_close)
  800993:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800996:	8b 40 10             	mov    0x10(%eax),%eax
      r = (*dev->dev_close)(fd);
    else
      r = 0;
  800999:	bb 00 00 00 00       	mov    $0x0,%ebx

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
      || fd != fd2)
    return must_exist ? r : 0;
  if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
    if (dev->dev_close)
  80099e:	85 c0                	test   %eax,%eax
  8009a0:	74 07                	je     8009a9 <fd_close+0x68>
      r = (*dev->dev_close)(fd);
  8009a2:	89 34 24             	mov    %esi,(%esp)
  8009a5:	ff d0                	call   *%eax
  8009a7:	89 c3                	mov    %eax,%ebx
    else
      r = 0;
  }
  // Make sure fd is unmapped.  Might be a no-op if
  // (*dev->dev_close)(fd) already unmapped it.
  (void)sys_page_unmap(0, fd);
  8009a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8009b4:	e8 a1 fc ff ff       	call   80065a <sys_page_unmap>
  return r;
  8009b9:	89 d8                	mov    %ebx,%eax
}
  8009bb:	83 c4 20             	add    $0x20,%esp
  8009be:	5b                   	pop    %ebx
  8009bf:	5e                   	pop    %esi
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <close>:
  return -E_INVAL;
}

int
close(int fdnum)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	83 ec 28             	sub    $0x28,%esp
  struct Fd *fd;
  int r;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  8009c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d2:	89 04 24             	mov    %eax,(%esp)
  8009d5:	e8 bc fe ff ff       	call   800896 <fd_lookup>
  8009da:	89 c2                	mov    %eax,%edx
  8009dc:	85 d2                	test   %edx,%edx
  8009de:	78 13                	js     8009f3 <close+0x31>
    return r;
  else
    return fd_close(fd, 1);
  8009e0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8009e7:	00 
  8009e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009eb:	89 04 24             	mov    %eax,(%esp)
  8009ee:	e8 4e ff ff ff       	call   800941 <fd_close>
}
  8009f3:	c9                   	leave  
  8009f4:	c3                   	ret    

008009f5 <close_all>:

void
close_all(void)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	53                   	push   %ebx
  8009f9:	83 ec 14             	sub    $0x14,%esp
  int i;

  for (i = 0; i < MAXFD; i++)
  8009fc:	bb 00 00 00 00       	mov    $0x0,%ebx
    close(i);
  800a01:	89 1c 24             	mov    %ebx,(%esp)
  800a04:	e8 b9 ff ff ff       	call   8009c2 <close>
void
close_all(void)
{
  int i;

  for (i = 0; i < MAXFD; i++)
  800a09:	83 c3 01             	add    $0x1,%ebx
  800a0c:	83 fb 20             	cmp    $0x20,%ebx
  800a0f:	75 f0                	jne    800a01 <close_all+0xc>
    close(i);
}
  800a11:	83 c4 14             	add    $0x14,%esp
  800a14:	5b                   	pop    %ebx
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	57                   	push   %edi
  800a1b:	56                   	push   %esi
  800a1c:	53                   	push   %ebx
  800a1d:	83 ec 3c             	sub    $0x3c,%esp
  int r;
  char *ova, *nva;
  pte_t pte;
  struct Fd *oldfd, *newfd;

  if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800a20:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800a23:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a27:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2a:	89 04 24             	mov    %eax,(%esp)
  800a2d:	e8 64 fe ff ff       	call   800896 <fd_lookup>
  800a32:	89 c2                	mov    %eax,%edx
  800a34:	85 d2                	test   %edx,%edx
  800a36:	0f 88 e1 00 00 00    	js     800b1d <dup+0x106>
    return r;
  close(newfdnum);
  800a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3f:	89 04 24             	mov    %eax,(%esp)
  800a42:	e8 7b ff ff ff       	call   8009c2 <close>

  newfd = INDEX2FD(newfdnum);
  800a47:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a4a:	c1 e3 0c             	shl    $0xc,%ebx
  800a4d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
  ova = fd2data(oldfd);
  800a53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a56:	89 04 24             	mov    %eax,(%esp)
  800a59:	e8 d2 fd ff ff       	call   800830 <fd2data>
  800a5e:	89 c6                	mov    %eax,%esi
  nva = fd2data(newfd);
  800a60:	89 1c 24             	mov    %ebx,(%esp)
  800a63:	e8 c8 fd ff ff       	call   800830 <fd2data>
  800a68:	89 c7                	mov    %eax,%edi

  if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800a6a:	89 f0                	mov    %esi,%eax
  800a6c:	c1 e8 16             	shr    $0x16,%eax
  800a6f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800a76:	a8 01                	test   $0x1,%al
  800a78:	74 43                	je     800abd <dup+0xa6>
  800a7a:	89 f0                	mov    %esi,%eax
  800a7c:	c1 e8 0c             	shr    $0xc,%eax
  800a7f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800a86:	f6 c2 01             	test   $0x1,%dl
  800a89:	74 32                	je     800abd <dup+0xa6>
    if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800a8b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a92:	25 07 0e 00 00       	and    $0xe07,%eax
  800a97:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a9b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800a9f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800aa6:	00 
  800aa7:	89 74 24 04          	mov    %esi,0x4(%esp)
  800aab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ab2:	e8 50 fb ff ff       	call   800607 <sys_page_map>
  800ab7:	89 c6                	mov    %eax,%esi
  800ab9:	85 c0                	test   %eax,%eax
  800abb:	78 3e                	js     800afb <dup+0xe4>
      goto err;
  if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800abd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ac0:	89 c2                	mov    %eax,%edx
  800ac2:	c1 ea 0c             	shr    $0xc,%edx
  800ac5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800acc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800ad2:	89 54 24 10          	mov    %edx,0x10(%esp)
  800ad6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ada:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ae1:	00 
  800ae2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800aed:	e8 15 fb ff ff       	call   800607 <sys_page_map>
  800af2:	89 c6                	mov    %eax,%esi
    goto err;

  return newfdnum;
  800af4:	8b 45 0c             	mov    0xc(%ebp),%eax
  nva = fd2data(newfd);

  if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
    if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
      goto err;
  if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800af7:	85 f6                	test   %esi,%esi
  800af9:	79 22                	jns    800b1d <dup+0x106>
    goto err;

  return newfdnum;

err:
  sys_page_unmap(0, newfd);
  800afb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800aff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b06:	e8 4f fb ff ff       	call   80065a <sys_page_unmap>
  sys_page_unmap(0, nva);
  800b0b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b16:	e8 3f fb ff ff       	call   80065a <sys_page_unmap>
  return r;
  800b1b:	89 f0                	mov    %esi,%eax
}
  800b1d:	83 c4 3c             	add    $0x3c,%esp
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5f                   	pop    %edi
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	53                   	push   %ebx
  800b29:	83 ec 24             	sub    $0x24,%esp
  800b2c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  800b2f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b32:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b36:	89 1c 24             	mov    %ebx,(%esp)
  800b39:	e8 58 fd ff ff       	call   800896 <fd_lookup>
  800b3e:	89 c2                	mov    %eax,%edx
  800b40:	85 d2                	test   %edx,%edx
  800b42:	78 6d                	js     800bb1 <read+0x8c>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b47:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b4e:	8b 00                	mov    (%eax),%eax
  800b50:	89 04 24             	mov    %eax,(%esp)
  800b53:	e8 94 fd ff ff       	call   8008ec <dev_lookup>
  800b58:	85 c0                	test   %eax,%eax
  800b5a:	78 55                	js     800bb1 <read+0x8c>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800b5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b5f:	8b 50 08             	mov    0x8(%eax),%edx
  800b62:	83 e2 03             	and    $0x3,%edx
  800b65:	83 fa 01             	cmp    $0x1,%edx
  800b68:	75 23                	jne    800b8d <read+0x68>
    cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800b6a:	a1 04 40 80 00       	mov    0x804004,%eax
  800b6f:	8b 40 48             	mov    0x48(%eax),%eax
  800b72:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b76:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b7a:	c7 04 24 dd 20 80 00 	movl   $0x8020dd,(%esp)
  800b81:	e8 e9 0a 00 00       	call   80166f <cprintf>
    return -E_INVAL;
  800b86:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b8b:	eb 24                	jmp    800bb1 <read+0x8c>
  }
  if (!dev->dev_read)
  800b8d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b90:	8b 52 08             	mov    0x8(%edx),%edx
  800b93:	85 d2                	test   %edx,%edx
  800b95:	74 15                	je     800bac <read+0x87>
    return -E_NOT_SUPP;
  return (*dev->dev_read)(fd, buf, n);
  800b97:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b9a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800b9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ba5:	89 04 24             	mov    %eax,(%esp)
  800ba8:	ff d2                	call   *%edx
  800baa:	eb 05                	jmp    800bb1 <read+0x8c>
  if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
    cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  if (!dev->dev_read)
    return -E_NOT_SUPP;
  800bac:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_read)(fd, buf, n);
}
  800bb1:	83 c4 24             	add    $0x24,%esp
  800bb4:	5b                   	pop    %ebx
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	57                   	push   %edi
  800bbb:	56                   	push   %esi
  800bbc:	53                   	push   %ebx
  800bbd:	83 ec 1c             	sub    $0x1c,%esp
  800bc0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bc3:	8b 75 10             	mov    0x10(%ebp),%esi
  int m, tot;

  for (tot = 0; tot < n; tot += m) {
  800bc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bcb:	eb 23                	jmp    800bf0 <readn+0x39>
    m = read(fdnum, (char*)buf + tot, n - tot);
  800bcd:	89 f0                	mov    %esi,%eax
  800bcf:	29 d8                	sub    %ebx,%eax
  800bd1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bd5:	89 d8                	mov    %ebx,%eax
  800bd7:	03 45 0c             	add    0xc(%ebp),%eax
  800bda:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bde:	89 3c 24             	mov    %edi,(%esp)
  800be1:	e8 3f ff ff ff       	call   800b25 <read>
    if (m < 0)
  800be6:	85 c0                	test   %eax,%eax
  800be8:	78 10                	js     800bfa <readn+0x43>
      return m;
    if (m == 0)
  800bea:	85 c0                	test   %eax,%eax
  800bec:	74 0a                	je     800bf8 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
  int m, tot;

  for (tot = 0; tot < n; tot += m) {
  800bee:	01 c3                	add    %eax,%ebx
  800bf0:	39 f3                	cmp    %esi,%ebx
  800bf2:	72 d9                	jb     800bcd <readn+0x16>
  800bf4:	89 d8                	mov    %ebx,%eax
  800bf6:	eb 02                	jmp    800bfa <readn+0x43>
  800bf8:	89 d8                	mov    %ebx,%eax
      return m;
    if (m == 0)
      break;
  }
  return tot;
}
  800bfa:	83 c4 1c             	add    $0x1c,%esp
  800bfd:	5b                   	pop    %ebx
  800bfe:	5e                   	pop    %esi
  800bff:	5f                   	pop    %edi
  800c00:	5d                   	pop    %ebp
  800c01:	c3                   	ret    

00800c02 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	53                   	push   %ebx
  800c06:	83 ec 24             	sub    $0x24,%esp
  800c09:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  800c0c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c13:	89 1c 24             	mov    %ebx,(%esp)
  800c16:	e8 7b fc ff ff       	call   800896 <fd_lookup>
  800c1b:	89 c2                	mov    %eax,%edx
  800c1d:	85 d2                	test   %edx,%edx
  800c1f:	78 68                	js     800c89 <write+0x87>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c24:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c28:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c2b:	8b 00                	mov    (%eax),%eax
  800c2d:	89 04 24             	mov    %eax,(%esp)
  800c30:	e8 b7 fc ff ff       	call   8008ec <dev_lookup>
  800c35:	85 c0                	test   %eax,%eax
  800c37:	78 50                	js     800c89 <write+0x87>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800c39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c3c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800c40:	75 23                	jne    800c65 <write+0x63>
    cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800c42:	a1 04 40 80 00       	mov    0x804004,%eax
  800c47:	8b 40 48             	mov    0x48(%eax),%eax
  800c4a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800c4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c52:	c7 04 24 f9 20 80 00 	movl   $0x8020f9,(%esp)
  800c59:	e8 11 0a 00 00       	call   80166f <cprintf>
    return -E_INVAL;
  800c5e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c63:	eb 24                	jmp    800c89 <write+0x87>
  }
  if (debug)
    cprintf("write %d %p %d via dev %s\n",
            fdnum, buf, n, dev->dev_name);
  if (!dev->dev_write)
  800c65:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c68:	8b 52 0c             	mov    0xc(%edx),%edx
  800c6b:	85 d2                	test   %edx,%edx
  800c6d:	74 15                	je     800c84 <write+0x82>
    return -E_NOT_SUPP;
  return (*dev->dev_write)(fd, buf, n);
  800c6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c72:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c79:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c7d:	89 04 24             	mov    %eax,(%esp)
  800c80:	ff d2                	call   *%edx
  800c82:	eb 05                	jmp    800c89 <write+0x87>
  }
  if (debug)
    cprintf("write %d %p %d via dev %s\n",
            fdnum, buf, n, dev->dev_name);
  if (!dev->dev_write)
    return -E_NOT_SUPP;
  800c84:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_write)(fd, buf, n);
}
  800c89:	83 c4 24             	add    $0x24,%esp
  800c8c:	5b                   	pop    %ebx
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <seek>:

int
seek(int fdnum, off_t offset)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	83 ec 18             	sub    $0x18,%esp
  int r;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  800c95:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800c98:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9f:	89 04 24             	mov    %eax,(%esp)
  800ca2:	e8 ef fb ff ff       	call   800896 <fd_lookup>
  800ca7:	85 c0                	test   %eax,%eax
  800ca9:	78 0e                	js     800cb9 <seek+0x2a>
    return r;
  fd->fd_offset = offset;
  800cab:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cae:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cb1:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
  800cb4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cb9:	c9                   	leave  
  800cba:	c3                   	ret    

00800cbb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	53                   	push   %ebx
  800cbf:	83 ec 24             	sub    $0x24,%esp
  800cc2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  800cc5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800cc8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ccc:	89 1c 24             	mov    %ebx,(%esp)
  800ccf:	e8 c2 fb ff ff       	call   800896 <fd_lookup>
  800cd4:	89 c2                	mov    %eax,%edx
  800cd6:	85 d2                	test   %edx,%edx
  800cd8:	78 61                	js     800d3b <ftruncate+0x80>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cdd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ce1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ce4:	8b 00                	mov    (%eax),%eax
  800ce6:	89 04 24             	mov    %eax,(%esp)
  800ce9:	e8 fe fb ff ff       	call   8008ec <dev_lookup>
  800cee:	85 c0                	test   %eax,%eax
  800cf0:	78 49                	js     800d3b <ftruncate+0x80>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800cf2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cf5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800cf9:	75 23                	jne    800d1e <ftruncate+0x63>
    cprintf("[%08x] ftruncate %d -- bad mode\n",
            thisenv->env_id, fdnum);
  800cfb:	a1 04 40 80 00       	mov    0x804004,%eax

  if ((r = fd_lookup(fdnum, &fd)) < 0
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
    cprintf("[%08x] ftruncate %d -- bad mode\n",
  800d00:	8b 40 48             	mov    0x48(%eax),%eax
  800d03:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d07:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d0b:	c7 04 24 bc 20 80 00 	movl   $0x8020bc,(%esp)
  800d12:	e8 58 09 00 00       	call   80166f <cprintf>
            thisenv->env_id, fdnum);
    return -E_INVAL;
  800d17:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d1c:	eb 1d                	jmp    800d3b <ftruncate+0x80>
  }
  if (!dev->dev_trunc)
  800d1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d21:	8b 52 18             	mov    0x18(%edx),%edx
  800d24:	85 d2                	test   %edx,%edx
  800d26:	74 0e                	je     800d36 <ftruncate+0x7b>
    return -E_NOT_SUPP;
  return (*dev->dev_trunc)(fd, newsize);
  800d28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d2f:	89 04 24             	mov    %eax,(%esp)
  800d32:	ff d2                	call   *%edx
  800d34:	eb 05                	jmp    800d3b <ftruncate+0x80>
    cprintf("[%08x] ftruncate %d -- bad mode\n",
            thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  if (!dev->dev_trunc)
    return -E_NOT_SUPP;
  800d36:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_trunc)(fd, newsize);
}
  800d3b:	83 c4 24             	add    $0x24,%esp
  800d3e:	5b                   	pop    %ebx
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	53                   	push   %ebx
  800d45:	83 ec 24             	sub    $0x24,%esp
  800d48:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  800d4b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d52:	8b 45 08             	mov    0x8(%ebp),%eax
  800d55:	89 04 24             	mov    %eax,(%esp)
  800d58:	e8 39 fb ff ff       	call   800896 <fd_lookup>
  800d5d:	89 c2                	mov    %eax,%edx
  800d5f:	85 d2                	test   %edx,%edx
  800d61:	78 52                	js     800db5 <fstat+0x74>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d63:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d66:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d6d:	8b 00                	mov    (%eax),%eax
  800d6f:	89 04 24             	mov    %eax,(%esp)
  800d72:	e8 75 fb ff ff       	call   8008ec <dev_lookup>
  800d77:	85 c0                	test   %eax,%eax
  800d79:	78 3a                	js     800db5 <fstat+0x74>
    return r;
  if (!dev->dev_stat)
  800d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d7e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800d82:	74 2c                	je     800db0 <fstat+0x6f>
    return -E_NOT_SUPP;
  stat->st_name[0] = 0;
  800d84:	c6 03 00             	movb   $0x0,(%ebx)
  stat->st_size = 0;
  800d87:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800d8e:	00 00 00 
  stat->st_isdir = 0;
  800d91:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800d98:	00 00 00 
  stat->st_dev = dev;
  800d9b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
  return (*dev->dev_stat)(fd, stat);
  800da1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800da5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800da8:	89 14 24             	mov    %edx,(%esp)
  800dab:	ff 50 14             	call   *0x14(%eax)
  800dae:	eb 05                	jmp    800db5 <fstat+0x74>

  if ((r = fd_lookup(fdnum, &fd)) < 0
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
    return r;
  if (!dev->dev_stat)
    return -E_NOT_SUPP;
  800db0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  stat->st_name[0] = 0;
  stat->st_size = 0;
  stat->st_isdir = 0;
  stat->st_dev = dev;
  return (*dev->dev_stat)(fd, stat);
}
  800db5:	83 c4 24             	add    $0x24,%esp
  800db8:	5b                   	pop    %ebx
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	56                   	push   %esi
  800dbf:	53                   	push   %ebx
  800dc0:	83 ec 10             	sub    $0x10,%esp
  int fd, r;

  if ((fd = open(path, O_RDONLY)) < 0)
  800dc3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800dca:	00 
  800dcb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dce:	89 04 24             	mov    %eax,(%esp)
  800dd1:	e8 d2 01 00 00       	call   800fa8 <open>
  800dd6:	89 c3                	mov    %eax,%ebx
  800dd8:	85 db                	test   %ebx,%ebx
  800dda:	78 1b                	js     800df7 <stat+0x3c>
    return fd;
  r = fstat(fd, stat);
  800ddc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ddf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800de3:	89 1c 24             	mov    %ebx,(%esp)
  800de6:	e8 56 ff ff ff       	call   800d41 <fstat>
  800deb:	89 c6                	mov    %eax,%esi
  close(fd);
  800ded:	89 1c 24             	mov    %ebx,(%esp)
  800df0:	e8 cd fb ff ff       	call   8009c2 <close>
  return r;
  800df5:	89 f0                	mov    %esi,%eax
}
  800df7:	83 c4 10             	add    $0x10,%esp
  800dfa:	5b                   	pop    %ebx
  800dfb:	5e                   	pop    %esi
  800dfc:	5d                   	pop    %ebp
  800dfd:	c3                   	ret    

00800dfe <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800dfe:	55                   	push   %ebp
  800dff:	89 e5                	mov    %esp,%ebp
  800e01:	56                   	push   %esi
  800e02:	53                   	push   %ebx
  800e03:	83 ec 10             	sub    $0x10,%esp
  800e06:	89 c6                	mov    %eax,%esi
  800e08:	89 d3                	mov    %edx,%ebx
  static envid_t fsenv;

  if (fsenv == 0)
  800e0a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800e11:	75 11                	jne    800e24 <fsipc+0x26>
    fsenv = ipc_find_env(ENV_TYPE_FS);
  800e13:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800e1a:	e8 24 0f 00 00       	call   801d43 <ipc_find_env>
  800e1f:	a3 00 40 80 00       	mov    %eax,0x804000
  static_assert(sizeof(fsipcbuf) == PGSIZE);

  if (debug)
    cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t*)&fsipcbuf);

  ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800e24:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800e2b:	00 
  800e2c:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800e33:	00 
  800e34:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e38:	a1 00 40 80 00       	mov    0x804000,%eax
  800e3d:	89 04 24             	mov    %eax,(%esp)
  800e40:	e8 93 0e 00 00       	call   801cd8 <ipc_send>
  return ipc_recv(NULL, dstva, NULL);
  800e45:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e4c:	00 
  800e4d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e58:	e8 f5 0d 00 00       	call   801c52 <ipc_recv>
}
  800e5d:	83 c4 10             	add    $0x10,%esp
  800e60:	5b                   	pop    %ebx
  800e61:	5e                   	pop    %esi
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    

00800e64 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	83 ec 08             	sub    $0x8,%esp
  fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800e6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6d:	8b 40 0c             	mov    0xc(%eax),%eax
  800e70:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.set_size.req_size = newsize;
  800e75:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e78:	a3 04 50 80 00       	mov    %eax,0x805004
  return fsipc(FSREQ_SET_SIZE, NULL);
  800e7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e82:	b8 02 00 00 00       	mov    $0x2,%eax
  800e87:	e8 72 ff ff ff       	call   800dfe <fsipc>
}
  800e8c:	c9                   	leave  
  800e8d:	c3                   	ret    

00800e8e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	83 ec 08             	sub    $0x8,%esp
  fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800e94:	8b 45 08             	mov    0x8(%ebp),%eax
  800e97:	8b 40 0c             	mov    0xc(%eax),%eax
  800e9a:	a3 00 50 80 00       	mov    %eax,0x805000
  return fsipc(FSREQ_FLUSH, NULL);
  800e9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea4:	b8 06 00 00 00       	mov    $0x6,%eax
  800ea9:	e8 50 ff ff ff       	call   800dfe <fsipc>
}
  800eae:	c9                   	leave  
  800eaf:	c3                   	ret    

00800eb0 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
  800eb3:	53                   	push   %ebx
  800eb4:	83 ec 14             	sub    $0x14,%esp
  800eb7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int r;

  fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800eba:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebd:	8b 40 0c             	mov    0xc(%eax),%eax
  800ec0:	a3 00 50 80 00       	mov    %eax,0x805000
  if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800ec5:	ba 00 00 00 00       	mov    $0x0,%edx
  800eca:	b8 05 00 00 00       	mov    $0x5,%eax
  800ecf:	e8 2a ff ff ff       	call   800dfe <fsipc>
  800ed4:	89 c2                	mov    %eax,%edx
  800ed6:	85 d2                	test   %edx,%edx
  800ed8:	78 2b                	js     800f05 <devfile_stat+0x55>
    return r;
  strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800eda:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800ee1:	00 
  800ee2:	89 1c 24             	mov    %ebx,(%esp)
  800ee5:	e8 ad f2 ff ff       	call   800197 <strcpy>
  st->st_size = fsipcbuf.statRet.ret_size;
  800eea:	a1 80 50 80 00       	mov    0x805080,%eax
  800eef:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800ef5:	a1 84 50 80 00       	mov    0x805084,%eax
  800efa:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  return 0;
  800f00:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f05:	83 c4 14             	add    $0x14,%esp
  800f08:	5b                   	pop    %ebx
  800f09:	5d                   	pop    %ebp
  800f0a:	c3                   	ret    

00800f0b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	83 ec 18             	sub    $0x18,%esp
  800f11:	8b 45 10             	mov    0x10(%ebp),%eax
  // remember that write is always allowed to write *fewer*
  // bytes than requested.
  // LAB 5: Your code here
    int r;

    fsipcbuf.write.req_fileid = fd->fd_file.id;
  800f14:	8b 55 08             	mov    0x8(%ebp),%edx
  800f17:	8b 52 0c             	mov    0xc(%edx),%edx
  800f1a:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  800f20:	a3 04 50 80 00       	mov    %eax,0x805004

    size_t max_written = sizeof(fsipcbuf.write.req_buf);
    memmove(fsipcbuf.write.req_buf, buf, MIN(max_written, n));
  800f25:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800f2a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800f2f:	0f 47 c2             	cmova  %edx,%eax
  800f32:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f36:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f39:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f3d:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800f44:	e8 eb f3 ff ff       	call   800334 <memmove>

    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800f49:	ba 00 00 00 00       	mov    $0x0,%edx
  800f4e:	b8 04 00 00 00       	mov    $0x4,%eax
  800f53:	e8 a6 fe ff ff       	call   800dfe <fsipc>
        return r;

    return r;
}
  800f58:	c9                   	leave  
  800f59:	c3                   	ret    

00800f5a <devfile_read>:
// Returns:
//  The number of bytes successfully read.
//  < 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800f5a:	55                   	push   %ebp
  800f5b:	89 e5                	mov    %esp,%ebp
  800f5d:	53                   	push   %ebx
  800f5e:	83 ec 14             	sub    $0x14,%esp
  // filling fsipcbuf.read with the request arguments.  The
  // bytes read will be written back to fsipcbuf by the file
  // system server.
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  800f61:	8b 45 08             	mov    0x8(%ebp),%eax
  800f64:	8b 40 0c             	mov    0xc(%eax),%eax
  800f67:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  800f6c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f6f:	a3 04 50 80 00       	mov    %eax,0x805004
  if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800f74:	ba 00 00 00 00       	mov    $0x0,%edx
  800f79:	b8 03 00 00 00       	mov    $0x3,%eax
  800f7e:	e8 7b fe ff ff       	call   800dfe <fsipc>
  800f83:	89 c3                	mov    %eax,%ebx
  800f85:	85 c0                	test   %eax,%eax
  800f87:	78 17                	js     800fa0 <devfile_read+0x46>
    return r;

  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800f89:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f8d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800f94:	00 
  800f95:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f98:	89 04 24             	mov    %eax,(%esp)
  800f9b:	e8 94 f3 ff ff       	call   800334 <memmove>
  return r;
}
  800fa0:	89 d8                	mov    %ebx,%eax
  800fa2:	83 c4 14             	add    $0x14,%esp
  800fa5:	5b                   	pop    %ebx
  800fa6:	5d                   	pop    %ebp
  800fa7:	c3                   	ret    

00800fa8 <open>:
//  The file descriptor index on success
//  -E_BAD_PATH if the path is too long (>= MAXPATHLEN)
//  < 0 for other errors.
int
open(const char *path, int mode)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	53                   	push   %ebx
  800fac:	83 ec 24             	sub    $0x24,%esp
  800faf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  // file descriptor.

  int r;
  struct Fd *fd;

  if (strlen(path) >= MAXPATHLEN)
  800fb2:	89 1c 24             	mov    %ebx,(%esp)
  800fb5:	e8 a6 f1 ff ff       	call   800160 <strlen>
  800fba:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800fbf:	7f 60                	jg     801021 <open+0x79>
    return -E_BAD_PATH;

  if ((r = fd_alloc(&fd)) < 0)
  800fc1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc4:	89 04 24             	mov    %eax,(%esp)
  800fc7:	e8 7b f8 ff ff       	call   800847 <fd_alloc>
  800fcc:	89 c2                	mov    %eax,%edx
  800fce:	85 d2                	test   %edx,%edx
  800fd0:	78 54                	js     801026 <open+0x7e>
    return r;

  strcpy(fsipcbuf.open.req_path, path);
  800fd2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fd6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800fdd:	e8 b5 f1 ff ff       	call   800197 <strcpy>
  fsipcbuf.open.req_omode = mode;
  800fe2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe5:	a3 00 54 80 00       	mov    %eax,0x805400

  if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800fea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800fed:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff2:	e8 07 fe ff ff       	call   800dfe <fsipc>
  800ff7:	89 c3                	mov    %eax,%ebx
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	79 17                	jns    801014 <open+0x6c>
    fd_close(fd, 0);
  800ffd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801004:	00 
  801005:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801008:	89 04 24             	mov    %eax,(%esp)
  80100b:	e8 31 f9 ff ff       	call   800941 <fd_close>
    return r;
  801010:	89 d8                	mov    %ebx,%eax
  801012:	eb 12                	jmp    801026 <open+0x7e>
  }

  return fd2num(fd);
  801014:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801017:	89 04 24             	mov    %eax,(%esp)
  80101a:	e8 01 f8 ff ff       	call   800820 <fd2num>
  80101f:	eb 05                	jmp    801026 <open+0x7e>

  int r;
  struct Fd *fd;

  if (strlen(path) >= MAXPATHLEN)
    return -E_BAD_PATH;
  801021:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
    fd_close(fd, 0);
    return r;
  }

  return fd2num(fd);
}
  801026:	83 c4 24             	add    $0x24,%esp
  801029:	5b                   	pop    %ebx
  80102a:	5d                   	pop    %ebp
  80102b:	c3                   	ret    

0080102c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	83 ec 08             	sub    $0x8,%esp
  // Ask the file server to update the disk
  // by writing any dirty blocks in the buffer cache.

  return fsipc(FSREQ_SYNC, NULL);
  801032:	ba 00 00 00 00       	mov    $0x0,%edx
  801037:	b8 08 00 00 00       	mov    $0x8,%eax
  80103c:	e8 bd fd ff ff       	call   800dfe <fsipc>
}
  801041:	c9                   	leave  
  801042:	c3                   	ret    

00801043 <devpipe_stat>:
  return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	56                   	push   %esi
  801047:	53                   	push   %ebx
  801048:	83 ec 10             	sub    $0x10,%esp
  80104b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct Pipe *p = (struct Pipe*)fd2data(fd);
  80104e:	8b 45 08             	mov    0x8(%ebp),%eax
  801051:	89 04 24             	mov    %eax,(%esp)
  801054:	e8 d7 f7 ff ff       	call   800830 <fd2data>
  801059:	89 c6                	mov    %eax,%esi

  strcpy(stat->st_name, "<pipe>");
  80105b:	c7 44 24 04 28 21 80 	movl   $0x802128,0x4(%esp)
  801062:	00 
  801063:	89 1c 24             	mov    %ebx,(%esp)
  801066:	e8 2c f1 ff ff       	call   800197 <strcpy>
  stat->st_size = p->p_wpos - p->p_rpos;
  80106b:	8b 46 04             	mov    0x4(%esi),%eax
  80106e:	2b 06                	sub    (%esi),%eax
  801070:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  stat->st_isdir = 0;
  801076:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80107d:	00 00 00 
  stat->st_dev = &devpipe;
  801080:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801087:	30 80 00 
  return 0;
}
  80108a:	b8 00 00 00 00       	mov    $0x0,%eax
  80108f:	83 c4 10             	add    $0x10,%esp
  801092:	5b                   	pop    %ebx
  801093:	5e                   	pop    %esi
  801094:	5d                   	pop    %ebp
  801095:	c3                   	ret    

00801096 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801096:	55                   	push   %ebp
  801097:	89 e5                	mov    %esp,%ebp
  801099:	53                   	push   %ebx
  80109a:	83 ec 14             	sub    $0x14,%esp
  80109d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  (void)sys_page_unmap(0, fd);
  8010a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010ab:	e8 aa f5 ff ff       	call   80065a <sys_page_unmap>
  return sys_page_unmap(0, fd2data(fd));
  8010b0:	89 1c 24             	mov    %ebx,(%esp)
  8010b3:	e8 78 f7 ff ff       	call   800830 <fd2data>
  8010b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010c3:	e8 92 f5 ff ff       	call   80065a <sys_page_unmap>
}
  8010c8:	83 c4 14             	add    $0x14,%esp
  8010cb:	5b                   	pop    %ebx
  8010cc:	5d                   	pop    %ebp
  8010cd:	c3                   	ret    

008010ce <_pipeisclosed>:
  return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8010ce:	55                   	push   %ebp
  8010cf:	89 e5                	mov    %esp,%ebp
  8010d1:	57                   	push   %edi
  8010d2:	56                   	push   %esi
  8010d3:	53                   	push   %ebx
  8010d4:	83 ec 2c             	sub    $0x2c,%esp
  8010d7:	89 c6                	mov    %eax,%esi
  8010d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  int n, nn, ret;

  while (1) {
    n = thisenv->env_runs;
  8010dc:	a1 04 40 80 00       	mov    0x804004,%eax
  8010e1:	8b 58 58             	mov    0x58(%eax),%ebx
    ret = pageref(fd) == pageref(p);
  8010e4:	89 34 24             	mov    %esi,(%esp)
  8010e7:	e8 8f 0c 00 00       	call   801d7b <pageref>
  8010ec:	89 c7                	mov    %eax,%edi
  8010ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010f1:	89 04 24             	mov    %eax,(%esp)
  8010f4:	e8 82 0c 00 00       	call   801d7b <pageref>
  8010f9:	39 c7                	cmp    %eax,%edi
  8010fb:	0f 94 c2             	sete   %dl
  8010fe:	0f b6 c2             	movzbl %dl,%eax
    nn = thisenv->env_runs;
  801101:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801107:	8b 79 58             	mov    0x58(%ecx),%edi
    if (n == nn)
  80110a:	39 fb                	cmp    %edi,%ebx
  80110c:	74 21                	je     80112f <_pipeisclosed+0x61>
      return ret;
    if (n != nn && ret == 1)
  80110e:	84 d2                	test   %dl,%dl
  801110:	74 ca                	je     8010dc <_pipeisclosed+0xe>
      cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801112:	8b 51 58             	mov    0x58(%ecx),%edx
  801115:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801119:	89 54 24 08          	mov    %edx,0x8(%esp)
  80111d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801121:	c7 04 24 2f 21 80 00 	movl   $0x80212f,(%esp)
  801128:	e8 42 05 00 00       	call   80166f <cprintf>
  80112d:	eb ad                	jmp    8010dc <_pipeisclosed+0xe>
  }
}
  80112f:	83 c4 2c             	add    $0x2c,%esp
  801132:	5b                   	pop    %ebx
  801133:	5e                   	pop    %esi
  801134:	5f                   	pop    %edi
  801135:	5d                   	pop    %ebp
  801136:	c3                   	ret    

00801137 <devpipe_write>:
  return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	57                   	push   %edi
  80113b:	56                   	push   %esi
  80113c:	53                   	push   %ebx
  80113d:	83 ec 1c             	sub    $0x1c,%esp
  801140:	8b 75 08             	mov    0x8(%ebp),%esi
  const uint8_t *buf;
  size_t i;
  struct Pipe *p;

  p = (struct Pipe*)fd2data(fd);
  801143:	89 34 24             	mov    %esi,(%esp)
  801146:	e8 e5 f6 ff ff       	call   800830 <fd2data>
  80114b:	89 c3                	mov    %eax,%ebx
  if (debug)
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  80114d:	bf 00 00 00 00       	mov    $0x0,%edi
  801152:	eb 45                	jmp    801199 <devpipe_write+0x62>
    while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
      // pipe is full
      // if all the readers are gone
      // (it's only writers like us now),
      // note eof
      if (_pipeisclosed(fd, p))
  801154:	89 da                	mov    %ebx,%edx
  801156:	89 f0                	mov    %esi,%eax
  801158:	e8 71 ff ff ff       	call   8010ce <_pipeisclosed>
  80115d:	85 c0                	test   %eax,%eax
  80115f:	75 41                	jne    8011a2 <devpipe_write+0x6b>
        return 0;
      // yield and see what happens
      if (debug)
        cprintf("devpipe_write yield\n");
      sys_yield();
  801161:	e8 2e f4 ff ff       	call   800594 <sys_yield>
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
    while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801166:	8b 43 04             	mov    0x4(%ebx),%eax
  801169:	8b 0b                	mov    (%ebx),%ecx
  80116b:	8d 51 20             	lea    0x20(%ecx),%edx
  80116e:	39 d0                	cmp    %edx,%eax
  801170:	73 e2                	jae    801154 <devpipe_write+0x1d>
        cprintf("devpipe_write yield\n");
      sys_yield();
    }
    // there's room for a byte.  store it.
    // wait to increment wpos until the byte is stored!
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801172:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801175:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801179:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80117c:	99                   	cltd   
  80117d:	c1 ea 1b             	shr    $0x1b,%edx
  801180:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801183:	83 e1 1f             	and    $0x1f,%ecx
  801186:	29 d1                	sub    %edx,%ecx
  801188:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  80118c:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
    p->p_wpos++;
  801190:	83 c0 01             	add    $0x1,%eax
  801193:	89 43 04             	mov    %eax,0x4(%ebx)
  if (debug)
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  801196:	83 c7 01             	add    $0x1,%edi
  801199:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80119c:	75 c8                	jne    801166 <devpipe_write+0x2f>
    // wait to increment wpos until the byte is stored!
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
    p->p_wpos++;
  }

  return i;
  80119e:	89 f8                	mov    %edi,%eax
  8011a0:	eb 05                	jmp    8011a7 <devpipe_write+0x70>
      // pipe is full
      // if all the readers are gone
      // (it's only writers like us now),
      // note eof
      if (_pipeisclosed(fd, p))
        return 0;
  8011a2:	b8 00 00 00 00       	mov    $0x0,%eax
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
    p->p_wpos++;
  }

  return i;
}
  8011a7:	83 c4 1c             	add    $0x1c,%esp
  8011aa:	5b                   	pop    %ebx
  8011ab:	5e                   	pop    %esi
  8011ac:	5f                   	pop    %edi
  8011ad:	5d                   	pop    %ebp
  8011ae:	c3                   	ret    

008011af <devpipe_read>:
  return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	57                   	push   %edi
  8011b3:	56                   	push   %esi
  8011b4:	53                   	push   %ebx
  8011b5:	83 ec 1c             	sub    $0x1c,%esp
  8011b8:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint8_t *buf;
  size_t i;
  struct Pipe *p;

  p = (struct Pipe*)fd2data(fd);
  8011bb:	89 3c 24             	mov    %edi,(%esp)
  8011be:	e8 6d f6 ff ff       	call   800830 <fd2data>
  8011c3:	89 c3                	mov    %eax,%ebx
  if (debug)
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  8011c5:	be 00 00 00 00       	mov    $0x0,%esi
  8011ca:	eb 3d                	jmp    801209 <devpipe_read+0x5a>
    while (p->p_rpos == p->p_wpos) {
      // pipe is empty
      // if we got any data, return it
      if (i > 0)
  8011cc:	85 f6                	test   %esi,%esi
  8011ce:	74 04                	je     8011d4 <devpipe_read+0x25>
        return i;
  8011d0:	89 f0                	mov    %esi,%eax
  8011d2:	eb 43                	jmp    801217 <devpipe_read+0x68>
      // if all the writers are gone, note eof
      if (_pipeisclosed(fd, p))
  8011d4:	89 da                	mov    %ebx,%edx
  8011d6:	89 f8                	mov    %edi,%eax
  8011d8:	e8 f1 fe ff ff       	call   8010ce <_pipeisclosed>
  8011dd:	85 c0                	test   %eax,%eax
  8011df:	75 31                	jne    801212 <devpipe_read+0x63>
        return 0;
      // yield and see what happens
      if (debug)
        cprintf("devpipe_read yield\n");
      sys_yield();
  8011e1:	e8 ae f3 ff ff       	call   800594 <sys_yield>
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
    while (p->p_rpos == p->p_wpos) {
  8011e6:	8b 03                	mov    (%ebx),%eax
  8011e8:	3b 43 04             	cmp    0x4(%ebx),%eax
  8011eb:	74 df                	je     8011cc <devpipe_read+0x1d>
        cprintf("devpipe_read yield\n");
      sys_yield();
    }
    // there's a byte.  take it.
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011ed:	99                   	cltd   
  8011ee:	c1 ea 1b             	shr    $0x1b,%edx
  8011f1:	01 d0                	add    %edx,%eax
  8011f3:	83 e0 1f             	and    $0x1f,%eax
  8011f6:	29 d0                	sub    %edx,%eax
  8011f8:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8011fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801200:	88 04 31             	mov    %al,(%ecx,%esi,1)
    p->p_rpos++;
  801203:	83 03 01             	addl   $0x1,(%ebx)
  if (debug)
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  801206:	83 c6 01             	add    $0x1,%esi
  801209:	3b 75 10             	cmp    0x10(%ebp),%esi
  80120c:	75 d8                	jne    8011e6 <devpipe_read+0x37>
    // there's a byte.  take it.
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
    p->p_rpos++;
  }
  return i;
  80120e:	89 f0                	mov    %esi,%eax
  801210:	eb 05                	jmp    801217 <devpipe_read+0x68>
      // if we got any data, return it
      if (i > 0)
        return i;
      // if all the writers are gone, note eof
      if (_pipeisclosed(fd, p))
        return 0;
  801212:	b8 00 00 00 00       	mov    $0x0,%eax
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
    p->p_rpos++;
  }
  return i;
}
  801217:	83 c4 1c             	add    $0x1c,%esp
  80121a:	5b                   	pop    %ebx
  80121b:	5e                   	pop    %esi
  80121c:	5f                   	pop    %edi
  80121d:	5d                   	pop    %ebp
  80121e:	c3                   	ret    

0080121f <pipe>:
  uint8_t p_buf[PIPEBUFSIZ];    // data buffer
};

int
pipe(int pfd[2])
{
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	56                   	push   %esi
  801223:	53                   	push   %ebx
  801224:	83 ec 30             	sub    $0x30,%esp
  int r;
  struct Fd *fd0, *fd1;
  void *va;

  // allocate the file descriptor table entries
  if ((r = fd_alloc(&fd0)) < 0
  801227:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122a:	89 04 24             	mov    %eax,(%esp)
  80122d:	e8 15 f6 ff ff       	call   800847 <fd_alloc>
  801232:	89 c2                	mov    %eax,%edx
  801234:	85 d2                	test   %edx,%edx
  801236:	0f 88 4d 01 00 00    	js     801389 <pipe+0x16a>
      || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80123c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801243:	00 
  801244:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801247:	89 44 24 04          	mov    %eax,0x4(%esp)
  80124b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801252:	e8 5c f3 ff ff       	call   8005b3 <sys_page_alloc>
  801257:	89 c2                	mov    %eax,%edx
  801259:	85 d2                	test   %edx,%edx
  80125b:	0f 88 28 01 00 00    	js     801389 <pipe+0x16a>
    goto err;

  if ((r = fd_alloc(&fd1)) < 0
  801261:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801264:	89 04 24             	mov    %eax,(%esp)
  801267:	e8 db f5 ff ff       	call   800847 <fd_alloc>
  80126c:	89 c3                	mov    %eax,%ebx
  80126e:	85 c0                	test   %eax,%eax
  801270:	0f 88 fe 00 00 00    	js     801374 <pipe+0x155>
      || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801276:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80127d:	00 
  80127e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801281:	89 44 24 04          	mov    %eax,0x4(%esp)
  801285:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80128c:	e8 22 f3 ff ff       	call   8005b3 <sys_page_alloc>
  801291:	89 c3                	mov    %eax,%ebx
  801293:	85 c0                	test   %eax,%eax
  801295:	0f 88 d9 00 00 00    	js     801374 <pipe+0x155>
    goto err1;

  // allocate the pipe structure as first data page in both
  va = fd2data(fd0);
  80129b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80129e:	89 04 24             	mov    %eax,(%esp)
  8012a1:	e8 8a f5 ff ff       	call   800830 <fd2data>
  8012a6:	89 c6                	mov    %eax,%esi
  if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012a8:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8012af:	00 
  8012b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012bb:	e8 f3 f2 ff ff       	call   8005b3 <sys_page_alloc>
  8012c0:	89 c3                	mov    %eax,%ebx
  8012c2:	85 c0                	test   %eax,%eax
  8012c4:	0f 88 97 00 00 00    	js     801361 <pipe+0x142>
    goto err2;
  if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012cd:	89 04 24             	mov    %eax,(%esp)
  8012d0:	e8 5b f5 ff ff       	call   800830 <fd2data>
  8012d5:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8012dc:	00 
  8012dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012e1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012e8:	00 
  8012e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012f4:	e8 0e f3 ff ff       	call   800607 <sys_page_map>
  8012f9:	89 c3                	mov    %eax,%ebx
  8012fb:	85 c0                	test   %eax,%eax
  8012fd:	78 52                	js     801351 <pipe+0x132>
    goto err3;

  // set up fd structures
  fd0->fd_dev_id = devpipe.dev_id;
  8012ff:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801305:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801308:	89 10                	mov    %edx,(%eax)
  fd0->fd_omode = O_RDONLY;
  80130a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80130d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

  fd1->fd_dev_id = devpipe.dev_id;
  801314:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80131a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131d:	89 10                	mov    %edx,(%eax)
  fd1->fd_omode = O_WRONLY;
  80131f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801322:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

  if (debug)
    cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

  pfd[0] = fd2num(fd0);
  801329:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80132c:	89 04 24             	mov    %eax,(%esp)
  80132f:	e8 ec f4 ff ff       	call   800820 <fd2num>
  801334:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801337:	89 01                	mov    %eax,(%ecx)
  pfd[1] = fd2num(fd1);
  801339:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133c:	89 04 24             	mov    %eax,(%esp)
  80133f:	e8 dc f4 ff ff       	call   800820 <fd2num>
  801344:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801347:	89 41 04             	mov    %eax,0x4(%ecx)
  return 0;
  80134a:	b8 00 00 00 00       	mov    $0x0,%eax
  80134f:	eb 38                	jmp    801389 <pipe+0x16a>

err3:
  sys_page_unmap(0, va);
  801351:	89 74 24 04          	mov    %esi,0x4(%esp)
  801355:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80135c:	e8 f9 f2 ff ff       	call   80065a <sys_page_unmap>
err2:
  sys_page_unmap(0, fd1);
  801361:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801364:	89 44 24 04          	mov    %eax,0x4(%esp)
  801368:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80136f:	e8 e6 f2 ff ff       	call   80065a <sys_page_unmap>
err1:
  sys_page_unmap(0, fd0);
  801374:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801377:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801382:	e8 d3 f2 ff ff       	call   80065a <sys_page_unmap>
  801387:	89 d8                	mov    %ebx,%eax
err:
  return r;
}
  801389:	83 c4 30             	add    $0x30,%esp
  80138c:	5b                   	pop    %ebx
  80138d:	5e                   	pop    %esi
  80138e:	5d                   	pop    %ebp
  80138f:	c3                   	ret    

00801390 <pipeisclosed>:
  }
}

int
pipeisclosed(int fdnum)
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
  801393:	83 ec 28             	sub    $0x28,%esp
  struct Fd *fd;
  struct Pipe *p;
  int r;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  801396:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801399:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139d:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a0:	89 04 24             	mov    %eax,(%esp)
  8013a3:	e8 ee f4 ff ff       	call   800896 <fd_lookup>
  8013a8:	89 c2                	mov    %eax,%edx
  8013aa:	85 d2                	test   %edx,%edx
  8013ac:	78 15                	js     8013c3 <pipeisclosed+0x33>
    return r;
  p = (struct Pipe*)fd2data(fd);
  8013ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b1:	89 04 24             	mov    %eax,(%esp)
  8013b4:	e8 77 f4 ff ff       	call   800830 <fd2data>
  return _pipeisclosed(fd, p);
  8013b9:	89 c2                	mov    %eax,%edx
  8013bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013be:	e8 0b fd ff ff       	call   8010ce <_pipeisclosed>
}
  8013c3:	c9                   	leave  
  8013c4:	c3                   	ret    
  8013c5:	66 90                	xchg   %ax,%ax
  8013c7:	66 90                	xchg   %ax,%ax
  8013c9:	66 90                	xchg   %ax,%ax
  8013cb:	66 90                	xchg   %ax,%ax
  8013cd:	66 90                	xchg   %ax,%ax
  8013cf:	90                   	nop

008013d0 <devcons_close>:
  return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
  USED(fd);

  return 0;
}
  8013d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d8:	5d                   	pop    %ebp
  8013d9:	c3                   	ret    

008013da <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8013da:	55                   	push   %ebp
  8013db:	89 e5                	mov    %esp,%ebp
  8013dd:	83 ec 18             	sub    $0x18,%esp
  strcpy(stat->st_name, "<cons>");
  8013e0:	c7 44 24 04 47 21 80 	movl   $0x802147,0x4(%esp)
  8013e7:	00 
  8013e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013eb:	89 04 24             	mov    %eax,(%esp)
  8013ee:	e8 a4 ed ff ff       	call   800197 <strcpy>
  return 0;
}
  8013f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f8:	c9                   	leave  
  8013f9:	c3                   	ret    

008013fa <devcons_write>:
  return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8013fa:	55                   	push   %ebp
  8013fb:	89 e5                	mov    %esp,%ebp
  8013fd:	57                   	push   %edi
  8013fe:	56                   	push   %esi
  8013ff:	53                   	push   %ebx
  801400:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  801406:	bb 00 00 00 00       	mov    $0x0,%ebx
    m = n - tot;
    if (m > sizeof(buf) - 1)
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
  80140b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  801411:	eb 31                	jmp    801444 <devcons_write+0x4a>
    m = n - tot;
  801413:	8b 75 10             	mov    0x10(%ebp),%esi
  801416:	29 de                	sub    %ebx,%esi
    if (m > sizeof(buf) - 1)
  801418:	83 fe 7f             	cmp    $0x7f,%esi
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
    m = n - tot;
  80141b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801420:	0f 47 f2             	cmova  %edx,%esi
    if (m > sizeof(buf) - 1)
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
  801423:	89 74 24 08          	mov    %esi,0x8(%esp)
  801427:	03 45 0c             	add    0xc(%ebp),%eax
  80142a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80142e:	89 3c 24             	mov    %edi,(%esp)
  801431:	e8 fe ee ff ff       	call   800334 <memmove>
    sys_cputs(buf, m);
  801436:	89 74 24 04          	mov    %esi,0x4(%esp)
  80143a:	89 3c 24             	mov    %edi,(%esp)
  80143d:	e8 a4 f0 ff ff       	call   8004e6 <sys_cputs>
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  801442:	01 f3                	add    %esi,%ebx
  801444:	89 d8                	mov    %ebx,%eax
  801446:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801449:	72 c8                	jb     801413 <devcons_write+0x19>
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
    sys_cputs(buf, m);
  }
  return tot;
}
  80144b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801451:	5b                   	pop    %ebx
  801452:	5e                   	pop    %esi
  801453:	5f                   	pop    %edi
  801454:	5d                   	pop    %ebp
  801455:	c3                   	ret    

00801456 <devcons_read>:
  return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801456:	55                   	push   %ebp
  801457:	89 e5                	mov    %esp,%ebp
  801459:	83 ec 08             	sub    $0x8,%esp
  int c;

  if (n == 0)
    return 0;
  80145c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  int c;

  if (n == 0)
  801461:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801465:	75 07                	jne    80146e <devcons_read+0x18>
  801467:	eb 2a                	jmp    801493 <devcons_read+0x3d>
    return 0;

  while ((c = sys_cgetc()) == 0)
    sys_yield();
  801469:	e8 26 f1 ff ff       	call   800594 <sys_yield>
  int c;

  if (n == 0)
    return 0;

  while ((c = sys_cgetc()) == 0)
  80146e:	66 90                	xchg   %ax,%ax
  801470:	e8 8f f0 ff ff       	call   800504 <sys_cgetc>
  801475:	85 c0                	test   %eax,%eax
  801477:	74 f0                	je     801469 <devcons_read+0x13>
    sys_yield();
  if (c < 0)
  801479:	85 c0                	test   %eax,%eax
  80147b:	78 16                	js     801493 <devcons_read+0x3d>
    return c;
  if (c == 0x04)        // ctl-d is eof
  80147d:	83 f8 04             	cmp    $0x4,%eax
  801480:	74 0c                	je     80148e <devcons_read+0x38>
    return 0;
  *(char*)vbuf = c;
  801482:	8b 55 0c             	mov    0xc(%ebp),%edx
  801485:	88 02                	mov    %al,(%edx)
  return 1;
  801487:	b8 01 00 00 00       	mov    $0x1,%eax
  80148c:	eb 05                	jmp    801493 <devcons_read+0x3d>
  while ((c = sys_cgetc()) == 0)
    sys_yield();
  if (c < 0)
    return c;
  if (c == 0x04)        // ctl-d is eof
    return 0;
  80148e:	b8 00 00 00 00       	mov    $0x0,%eax
  *(char*)vbuf = c;
  return 1;
}
  801493:	c9                   	leave  
  801494:	c3                   	ret    

00801495 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801495:	55                   	push   %ebp
  801496:	89 e5                	mov    %esp,%ebp
  801498:	83 ec 28             	sub    $0x28,%esp
  char c = ch;
  80149b:	8b 45 08             	mov    0x8(%ebp),%eax
  80149e:	88 45 f7             	mov    %al,-0x9(%ebp)

  // Unlike standard Unix's putchar,
  // the cputchar function _always_ outputs to the system console.
  sys_cputs(&c, 1);
  8014a1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8014a8:	00 
  8014a9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014ac:	89 04 24             	mov    %eax,(%esp)
  8014af:	e8 32 f0 ff ff       	call   8004e6 <sys_cputs>
}
  8014b4:	c9                   	leave  
  8014b5:	c3                   	ret    

008014b6 <getchar>:

int
getchar(void)
{
  8014b6:	55                   	push   %ebp
  8014b7:	89 e5                	mov    %esp,%ebp
  8014b9:	83 ec 28             	sub    $0x28,%esp
  int r;

  // JOS does, however, support standard _input_ redirection,
  // allowing the user to redirect script files to the shell and such.
  // getchar() reads a character from file descriptor 0.
  r = read(0, &c, 1);
  8014bc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8014c3:	00 
  8014c4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014d2:	e8 4e f6 ff ff       	call   800b25 <read>
  if (r < 0)
  8014d7:	85 c0                	test   %eax,%eax
  8014d9:	78 0f                	js     8014ea <getchar+0x34>
    return r;
  if (r < 1)
  8014db:	85 c0                	test   %eax,%eax
  8014dd:	7e 06                	jle    8014e5 <getchar+0x2f>
    return -E_EOF;
  return c;
  8014df:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8014e3:	eb 05                	jmp    8014ea <getchar+0x34>
  // getchar() reads a character from file descriptor 0.
  r = read(0, &c, 1);
  if (r < 0)
    return r;
  if (r < 1)
    return -E_EOF;
  8014e5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  /* int r;
  // sys_cgetc does not block, but getchar should.
  while ((r = sys_cgetc()) == 0)
    sys_yield();
  return r; */
}
  8014ea:	c9                   	leave  
  8014eb:	c3                   	ret    

008014ec <iscons>:
  .dev_stat   =     devcons_stat
};

int
iscons(int fdnum)
{
  8014ec:	55                   	push   %ebp
  8014ed:	89 e5                	mov    %esp,%ebp
  8014ef:	83 ec 28             	sub    $0x28,%esp
  int r;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fc:	89 04 24             	mov    %eax,(%esp)
  8014ff:	e8 92 f3 ff ff       	call   800896 <fd_lookup>
  801504:	85 c0                	test   %eax,%eax
  801506:	78 11                	js     801519 <iscons+0x2d>
    return r;
  return fd->fd_dev_id == devcons.dev_id;
  801508:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80150b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801511:	39 10                	cmp    %edx,(%eax)
  801513:	0f 94 c0             	sete   %al
  801516:	0f b6 c0             	movzbl %al,%eax
}
  801519:	c9                   	leave  
  80151a:	c3                   	ret    

0080151b <opencons>:

int
opencons(void)
{
  80151b:	55                   	push   %ebp
  80151c:	89 e5                	mov    %esp,%ebp
  80151e:	83 ec 28             	sub    $0x28,%esp
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
  801521:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801524:	89 04 24             	mov    %eax,(%esp)
  801527:	e8 1b f3 ff ff       	call   800847 <fd_alloc>
    return r;
  80152c:	89 c2                	mov    %eax,%edx
opencons(void)
{
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
  80152e:	85 c0                	test   %eax,%eax
  801530:	78 40                	js     801572 <opencons+0x57>
    return r;
  if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801532:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801539:	00 
  80153a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80153d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801541:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801548:	e8 66 f0 ff ff       	call   8005b3 <sys_page_alloc>
    return r;
  80154d:	89 c2                	mov    %eax,%edx
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
    return r;
  if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80154f:	85 c0                	test   %eax,%eax
  801551:	78 1f                	js     801572 <opencons+0x57>
    return r;
  fd->fd_dev_id = devcons.dev_id;
  801553:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801559:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80155c:	89 10                	mov    %edx,(%eax)
  fd->fd_omode = O_RDWR;
  80155e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801561:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
  return fd2num(fd);
  801568:	89 04 24             	mov    %eax,(%esp)
  80156b:	e8 b0 f2 ff ff       	call   800820 <fd2num>
  801570:	89 c2                	mov    %eax,%edx
}
  801572:	89 d0                	mov    %edx,%eax
  801574:	c9                   	leave  
  801575:	c3                   	ret    

00801576 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801576:	55                   	push   %ebp
  801577:	89 e5                	mov    %esp,%ebp
  801579:	56                   	push   %esi
  80157a:	53                   	push   %ebx
  80157b:	83 ec 20             	sub    $0x20,%esp
  va_list ap;

  va_start(ap, fmt);
  80157e:	8d 5d 14             	lea    0x14(%ebp),%ebx

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  801581:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801587:	e8 e9 ef ff ff       	call   800575 <sys_getenvid>
  80158c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80158f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801593:	8b 55 08             	mov    0x8(%ebp),%edx
  801596:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80159a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80159e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a2:	c7 04 24 54 21 80 00 	movl   $0x802154,(%esp)
  8015a9:	e8 c1 00 00 00       	call   80166f <cprintf>
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  8015ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8015b5:	89 04 24             	mov    %eax,(%esp)
  8015b8:	e8 51 00 00 00       	call   80160e <vcprintf>
  cprintf("\n");
  8015bd:	c7 04 24 40 21 80 00 	movl   $0x802140,(%esp)
  8015c4:	e8 a6 00 00 00       	call   80166f <cprintf>

  // Cause a breakpoint exception
  while (1)
    asm volatile ("int3");
  8015c9:	cc                   	int3   
  8015ca:	eb fd                	jmp    8015c9 <_panic+0x53>

008015cc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	53                   	push   %ebx
  8015d0:	83 ec 14             	sub    $0x14,%esp
  8015d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  b->buf[b->idx++] = ch;
  8015d6:	8b 13                	mov    (%ebx),%edx
  8015d8:	8d 42 01             	lea    0x1(%edx),%eax
  8015db:	89 03                	mov    %eax,(%ebx)
  8015dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015e0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
  if (b->idx == 256-1) {
  8015e4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8015e9:	75 19                	jne    801604 <putch+0x38>
    sys_cputs(b->buf, b->idx);
  8015eb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8015f2:	00 
  8015f3:	8d 43 08             	lea    0x8(%ebx),%eax
  8015f6:	89 04 24             	mov    %eax,(%esp)
  8015f9:	e8 e8 ee ff ff       	call   8004e6 <sys_cputs>
    b->idx = 0;
  8015fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  }
  b->cnt++;
  801604:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801608:	83 c4 14             	add    $0x14,%esp
  80160b:	5b                   	pop    %ebx
  80160c:	5d                   	pop    %ebp
  80160d:	c3                   	ret    

0080160e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80160e:	55                   	push   %ebp
  80160f:	89 e5                	mov    %esp,%ebp
  801611:	81 ec 28 01 00 00    	sub    $0x128,%esp
  struct printbuf b;

  b.idx = 0;
  801617:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80161e:	00 00 00 
  b.cnt = 0;
  801621:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801628:	00 00 00 
  vprintfmt((void*)putch, &b, fmt, ap);
  80162b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80162e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801632:	8b 45 08             	mov    0x8(%ebp),%eax
  801635:	89 44 24 08          	mov    %eax,0x8(%esp)
  801639:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80163f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801643:	c7 04 24 cc 15 80 00 	movl   $0x8015cc,(%esp)
  80164a:	e8 af 01 00 00       	call   8017fe <vprintfmt>
  sys_cputs(b.buf, b.idx);
  80164f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801655:	89 44 24 04          	mov    %eax,0x4(%esp)
  801659:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80165f:	89 04 24             	mov    %eax,(%esp)
  801662:	e8 7f ee ff ff       	call   8004e6 <sys_cputs>

  return b.cnt;
}
  801667:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80166d:	c9                   	leave  
  80166e:	c3                   	ret    

0080166f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80166f:	55                   	push   %ebp
  801670:	89 e5                	mov    %esp,%ebp
  801672:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  801675:	8d 45 0c             	lea    0xc(%ebp),%eax
  cnt = vcprintf(fmt, ap);
  801678:	89 44 24 04          	mov    %eax,0x4(%esp)
  80167c:	8b 45 08             	mov    0x8(%ebp),%eax
  80167f:	89 04 24             	mov    %eax,(%esp)
  801682:	e8 87 ff ff ff       	call   80160e <vcprintf>
  va_end(ap);

  return cnt;
}
  801687:	c9                   	leave  
  801688:	c3                   	ret    
  801689:	66 90                	xchg   %ax,%ax
  80168b:	66 90                	xchg   %ax,%ax
  80168d:	66 90                	xchg   %ax,%ax
  80168f:	90                   	nop

00801690 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
         unsigned long long num, unsigned base, int width, int padc)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	57                   	push   %edi
  801694:	56                   	push   %esi
  801695:	53                   	push   %ebx
  801696:	83 ec 3c             	sub    $0x3c,%esp
  801699:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80169c:	89 d7                	mov    %edx,%edi
  80169e:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016a7:	89 c3                	mov    %eax,%ebx
  8016a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8016ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8016af:	8b 75 14             	mov    0x14(%ebp),%esi
  // first recursively print all preceding (more significant) digits
  if (num >= base)
  8016b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8016ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8016bd:	39 d9                	cmp    %ebx,%ecx
  8016bf:	72 05                	jb     8016c6 <printnum+0x36>
  8016c1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8016c4:	77 69                	ja     80172f <printnum+0x9f>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8016c6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8016c9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8016cd:	83 ee 01             	sub    $0x1,%esi
  8016d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8016d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016d8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8016dc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8016e0:	89 c3                	mov    %eax,%ebx
  8016e2:	89 d6                	mov    %edx,%esi
  8016e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8016e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8016ea:	89 54 24 08          	mov    %edx,0x8(%esp)
  8016ee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8016f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016f5:	89 04 24             	mov    %eax,(%esp)
  8016f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ff:	e8 bc 06 00 00       	call   801dc0 <__udivdi3>
  801704:	89 d9                	mov    %ebx,%ecx
  801706:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80170a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80170e:	89 04 24             	mov    %eax,(%esp)
  801711:	89 54 24 04          	mov    %edx,0x4(%esp)
  801715:	89 fa                	mov    %edi,%edx
  801717:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80171a:	e8 71 ff ff ff       	call   801690 <printnum>
  80171f:	eb 1b                	jmp    80173c <printnum+0xac>
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
      putch(padc, putdat);
  801721:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801725:	8b 45 18             	mov    0x18(%ebp),%eax
  801728:	89 04 24             	mov    %eax,(%esp)
  80172b:	ff d3                	call   *%ebx
  80172d:	eb 03                	jmp    801732 <printnum+0xa2>
  80172f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  // first recursively print all preceding (more significant) digits
  if (num >= base)
    printnum(putch, putdat, num / base, base, width - 1, padc);
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
  801732:	83 ee 01             	sub    $0x1,%esi
  801735:	85 f6                	test   %esi,%esi
  801737:	7f e8                	jg     801721 <printnum+0x91>
  801739:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
      putch(padc, putdat);
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  80173c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801740:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801744:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801747:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80174a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80174e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801752:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801755:	89 04 24             	mov    %eax,(%esp)
  801758:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80175b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80175f:	e8 8c 07 00 00       	call   801ef0 <__umoddi3>
  801764:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801768:	0f be 80 77 21 80 00 	movsbl 0x802177(%eax),%eax
  80176f:	89 04 24             	mov    %eax,(%esp)
  801772:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801775:	ff d0                	call   *%eax
}
  801777:	83 c4 3c             	add    $0x3c,%esp
  80177a:	5b                   	pop    %ebx
  80177b:	5e                   	pop    %esi
  80177c:	5f                   	pop    %edi
  80177d:	5d                   	pop    %ebp
  80177e:	c3                   	ret    

0080177f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80177f:	55                   	push   %ebp
  801780:	89 e5                	mov    %esp,%ebp
  if (lflag >= 2)
  801782:	83 fa 01             	cmp    $0x1,%edx
  801785:	7e 0e                	jle    801795 <getuint+0x16>
    return va_arg(*ap, unsigned long long);
  801787:	8b 10                	mov    (%eax),%edx
  801789:	8d 4a 08             	lea    0x8(%edx),%ecx
  80178c:	89 08                	mov    %ecx,(%eax)
  80178e:	8b 02                	mov    (%edx),%eax
  801790:	8b 52 04             	mov    0x4(%edx),%edx
  801793:	eb 22                	jmp    8017b7 <getuint+0x38>
  else if (lflag)
  801795:	85 d2                	test   %edx,%edx
  801797:	74 10                	je     8017a9 <getuint+0x2a>
    return va_arg(*ap, unsigned long);
  801799:	8b 10                	mov    (%eax),%edx
  80179b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80179e:	89 08                	mov    %ecx,(%eax)
  8017a0:	8b 02                	mov    (%edx),%eax
  8017a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a7:	eb 0e                	jmp    8017b7 <getuint+0x38>
  else
    return va_arg(*ap, unsigned int);
  8017a9:	8b 10                	mov    (%eax),%edx
  8017ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8017ae:	89 08                	mov    %ecx,(%eax)
  8017b0:	8b 02                	mov    (%edx),%eax
  8017b2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8017b7:	5d                   	pop    %ebp
  8017b8:	c3                   	ret    

008017b9 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8017b9:	55                   	push   %ebp
  8017ba:	89 e5                	mov    %esp,%ebp
  8017bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  b->cnt++;
  8017bf:	83 40 08 01          	addl   $0x1,0x8(%eax)
  if (b->buf < b->ebuf)
  8017c3:	8b 10                	mov    (%eax),%edx
  8017c5:	3b 50 04             	cmp    0x4(%eax),%edx
  8017c8:	73 0a                	jae    8017d4 <sprintputch+0x1b>
    *b->buf++ = ch;
  8017ca:	8d 4a 01             	lea    0x1(%edx),%ecx
  8017cd:	89 08                	mov    %ecx,(%eax)
  8017cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d2:	88 02                	mov    %al,(%edx)
}
  8017d4:	5d                   	pop    %ebp
  8017d5:	c3                   	ret    

008017d6 <printfmt>:
  }
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	83 ec 18             	sub    $0x18,%esp
  va_list ap;

  va_start(ap, fmt);
  8017dc:	8d 45 14             	lea    0x14(%ebp),%eax
  vprintfmt(putch, putdat, fmt, ap);
  8017df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8017e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f4:	89 04 24             	mov    %eax,(%esp)
  8017f7:	e8 02 00 00 00       	call   8017fe <vprintfmt>
  va_end(ap);
}
  8017fc:	c9                   	leave  
  8017fd:	c3                   	ret    

008017fe <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8017fe:	55                   	push   %ebp
  8017ff:	89 e5                	mov    %esp,%ebp
  801801:	57                   	push   %edi
  801802:	56                   	push   %esi
  801803:	53                   	push   %ebx
  801804:	83 ec 3c             	sub    $0x3c,%esp
  801807:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80180a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80180d:	eb 14                	jmp    801823 <vprintfmt+0x25>
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
      if (ch == '\0')
  80180f:	85 c0                	test   %eax,%eax
  801811:	0f 84 b3 03 00 00    	je     801bca <vprintfmt+0x3cc>
        return;
      putch(ch, putdat);
  801817:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80181b:	89 04 24             	mov    %eax,(%esp)
  80181e:	ff 55 08             	call   *0x8(%ebp)
  unsigned long long num;
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
  801821:	89 f3                	mov    %esi,%ebx
  801823:	8d 73 01             	lea    0x1(%ebx),%esi
  801826:	0f b6 03             	movzbl (%ebx),%eax
  801829:	83 f8 25             	cmp    $0x25,%eax
  80182c:	75 e1                	jne    80180f <vprintfmt+0x11>
  80182e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  801832:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801839:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801840:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  801847:	ba 00 00 00 00       	mov    $0x0,%edx
  80184c:	eb 1d                	jmp    80186b <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80184e:	89 de                	mov    %ebx,%esi

    // flag to pad on the right
    case '-':
      padc = '-';
  801850:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  801854:	eb 15                	jmp    80186b <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  801856:	89 de                	mov    %ebx,%esi
      padc = '-';
      goto reswitch;

    // flag to pad with 0's instead of spaces
    case '0':
      padc = '0';
  801858:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80185c:	eb 0d                	jmp    80186b <vprintfmt+0x6d>
      altflag = 1;
      goto reswitch;

process_precision:
      if (width < 0)
        width = precision, precision = -1;
  80185e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801861:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801864:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80186b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80186e:	0f b6 0e             	movzbl (%esi),%ecx
  801871:	0f b6 c1             	movzbl %cl,%eax
  801874:	83 e9 23             	sub    $0x23,%ecx
  801877:	80 f9 55             	cmp    $0x55,%cl
  80187a:	0f 87 2a 03 00 00    	ja     801baa <vprintfmt+0x3ac>
  801880:	0f b6 c9             	movzbl %cl,%ecx
  801883:	ff 24 8d c0 22 80 00 	jmp    *0x8022c0(,%ecx,4)
  80188a:	89 de                	mov    %ebx,%esi
  80188c:	b9 00 00 00 00       	mov    $0x0,%ecx
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
        precision = precision * 10 + ch - '0';
  801891:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  801894:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
        ch = *fmt;
  801898:	0f be 06             	movsbl (%esi),%eax
        if (ch < '0' || ch > '9')
  80189b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80189e:	83 fb 09             	cmp    $0x9,%ebx
  8018a1:	77 36                	ja     8018d9 <vprintfmt+0xdb>
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
  8018a3:	83 c6 01             	add    $0x1,%esi
        precision = precision * 10 + ch - '0';
        ch = *fmt;
        if (ch < '0' || ch > '9')
          break;
      }
  8018a6:	eb e9                	jmp    801891 <vprintfmt+0x93>
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
  8018a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8018ab:	8d 48 04             	lea    0x4(%eax),%ecx
  8018ae:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8018b1:	8b 00                	mov    (%eax),%eax
  8018b3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8018b6:	89 de                	mov    %ebx,%esi
      }
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
      goto process_precision;
  8018b8:	eb 22                	jmp    8018dc <vprintfmt+0xde>
  8018ba:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8018bd:	85 c9                	test   %ecx,%ecx
  8018bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c4:	0f 49 c1             	cmovns %ecx,%eax
  8018c7:	89 45 dc             	mov    %eax,-0x24(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8018ca:	89 de                	mov    %ebx,%esi
  8018cc:	eb 9d                	jmp    80186b <vprintfmt+0x6d>
  8018ce:	89 de                	mov    %ebx,%esi
      if (width < 0)
        width = 0;
      goto reswitch;

    case '#':
      altflag = 1;
  8018d0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
      goto reswitch;
  8018d7:	eb 92                	jmp    80186b <vprintfmt+0x6d>
  8018d9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

process_precision:
      if (width < 0)
  8018dc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8018e0:	79 89                	jns    80186b <vprintfmt+0x6d>
  8018e2:	e9 77 ff ff ff       	jmp    80185e <vprintfmt+0x60>
        width = precision, precision = -1;
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
  8018e7:	83 c2 01             	add    $0x1,%edx
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8018ea:	89 de                	mov    %ebx,%esi
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
      goto reswitch;
  8018ec:	e9 7a ff ff ff       	jmp    80186b <vprintfmt+0x6d>

    // character
    case 'c':
      putch(va_arg(ap, int), putdat);
  8018f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8018f4:	8d 50 04             	lea    0x4(%eax),%edx
  8018f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8018fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8018fe:	8b 00                	mov    (%eax),%eax
  801900:	89 04 24             	mov    %eax,(%esp)
  801903:	ff 55 08             	call   *0x8(%ebp)
      break;
  801906:	e9 18 ff ff ff       	jmp    801823 <vprintfmt+0x25>

    // error message
    case 'e':
      err = va_arg(ap, int);
  80190b:	8b 45 14             	mov    0x14(%ebp),%eax
  80190e:	8d 50 04             	lea    0x4(%eax),%edx
  801911:	89 55 14             	mov    %edx,0x14(%ebp)
  801914:	8b 00                	mov    (%eax),%eax
  801916:	99                   	cltd   
  801917:	31 d0                	xor    %edx,%eax
  801919:	29 d0                	sub    %edx,%eax
      if (err < 0)
        err = -err;
      if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80191b:	83 f8 0f             	cmp    $0xf,%eax
  80191e:	7f 0b                	jg     80192b <vprintfmt+0x12d>
  801920:	8b 14 85 20 24 80 00 	mov    0x802420(,%eax,4),%edx
  801927:	85 d2                	test   %edx,%edx
  801929:	75 20                	jne    80194b <vprintfmt+0x14d>
        printfmt(putch, putdat, "error %d", err);
  80192b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80192f:	c7 44 24 08 8f 21 80 	movl   $0x80218f,0x8(%esp)
  801936:	00 
  801937:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80193b:	8b 45 08             	mov    0x8(%ebp),%eax
  80193e:	89 04 24             	mov    %eax,(%esp)
  801941:	e8 90 fe ff ff       	call   8017d6 <printfmt>
  801946:	e9 d8 fe ff ff       	jmp    801823 <vprintfmt+0x25>
      else
        printfmt(putch, putdat, "%s", p);
  80194b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80194f:	c7 44 24 08 98 21 80 	movl   $0x802198,0x8(%esp)
  801956:	00 
  801957:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80195b:	8b 45 08             	mov    0x8(%ebp),%eax
  80195e:	89 04 24             	mov    %eax,(%esp)
  801961:	e8 70 fe ff ff       	call   8017d6 <printfmt>
  801966:	e9 b8 fe ff ff       	jmp    801823 <vprintfmt+0x25>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80196b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80196e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801971:	89 45 d0             	mov    %eax,-0x30(%ebp)
        printfmt(putch, putdat, "%s", p);
      break;

    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
  801974:	8b 45 14             	mov    0x14(%ebp),%eax
  801977:	8d 50 04             	lea    0x4(%eax),%edx
  80197a:	89 55 14             	mov    %edx,0x14(%ebp)
  80197d:	8b 30                	mov    (%eax),%esi
        p = "(null)";
  80197f:	85 f6                	test   %esi,%esi
  801981:	b8 88 21 80 00       	mov    $0x802188,%eax
  801986:	0f 44 f0             	cmove  %eax,%esi
      if (width > 0 && padc != '-')
  801989:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80198d:	0f 84 97 00 00 00    	je     801a2a <vprintfmt+0x22c>
  801993:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  801997:	0f 8e 9b 00 00 00    	jle    801a38 <vprintfmt+0x23a>
        for (width -= strnlen(p, precision); width > 0; width--)
  80199d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019a1:	89 34 24             	mov    %esi,(%esp)
  8019a4:	e8 cf e7 ff ff       	call   800178 <strnlen>
  8019a9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8019ac:	29 c2                	sub    %eax,%edx
  8019ae:	89 55 d0             	mov    %edx,-0x30(%ebp)
          putch(padc, putdat);
  8019b1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8019b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8019b8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8019bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8019be:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8019c1:	89 d3                	mov    %edx,%ebx
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
  8019c3:	eb 0f                	jmp    8019d4 <vprintfmt+0x1d6>
          putch(padc, putdat);
  8019c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8019c9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8019cc:	89 04 24             	mov    %eax,(%esp)
  8019cf:	ff d6                	call   *%esi
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
  8019d1:	83 eb 01             	sub    $0x1,%ebx
  8019d4:	85 db                	test   %ebx,%ebx
  8019d6:	7f ed                	jg     8019c5 <vprintfmt+0x1c7>
  8019d8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8019db:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8019de:	85 d2                	test   %edx,%edx
  8019e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e5:	0f 49 c2             	cmovns %edx,%eax
  8019e8:	29 c2                	sub    %eax,%edx
  8019ea:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8019ed:	89 d7                	mov    %edx,%edi
  8019ef:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8019f2:	eb 50                	jmp    801a44 <vprintfmt+0x246>
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
  8019f4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8019f8:	74 1e                	je     801a18 <vprintfmt+0x21a>
  8019fa:	0f be d2             	movsbl %dl,%edx
  8019fd:	83 ea 20             	sub    $0x20,%edx
  801a00:	83 fa 5e             	cmp    $0x5e,%edx
  801a03:	76 13                	jbe    801a18 <vprintfmt+0x21a>
          putch('?', putdat);
  801a05:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a08:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a0c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801a13:	ff 55 08             	call   *0x8(%ebp)
  801a16:	eb 0d                	jmp    801a25 <vprintfmt+0x227>
        else
          putch(ch, putdat);
  801a18:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a1b:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a1f:	89 04 24             	mov    %eax,(%esp)
  801a22:	ff 55 08             	call   *0x8(%ebp)
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a25:	83 ef 01             	sub    $0x1,%edi
  801a28:	eb 1a                	jmp    801a44 <vprintfmt+0x246>
  801a2a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  801a2d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801a30:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801a33:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801a36:	eb 0c                	jmp    801a44 <vprintfmt+0x246>
  801a38:	89 7d 0c             	mov    %edi,0xc(%ebp)
  801a3b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801a3e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801a41:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801a44:	83 c6 01             	add    $0x1,%esi
  801a47:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  801a4b:	0f be c2             	movsbl %dl,%eax
  801a4e:	85 c0                	test   %eax,%eax
  801a50:	74 27                	je     801a79 <vprintfmt+0x27b>
  801a52:	85 db                	test   %ebx,%ebx
  801a54:	78 9e                	js     8019f4 <vprintfmt+0x1f6>
  801a56:	83 eb 01             	sub    $0x1,%ebx
  801a59:	79 99                	jns    8019f4 <vprintfmt+0x1f6>
  801a5b:	89 f8                	mov    %edi,%eax
  801a5d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a60:	8b 75 08             	mov    0x8(%ebp),%esi
  801a63:	89 c3                	mov    %eax,%ebx
  801a65:	eb 1a                	jmp    801a81 <vprintfmt+0x283>
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
        putch(' ', putdat);
  801a67:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a6b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801a72:	ff d6                	call   *%esi
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
  801a74:	83 eb 01             	sub    $0x1,%ebx
  801a77:	eb 08                	jmp    801a81 <vprintfmt+0x283>
  801a79:	89 fb                	mov    %edi,%ebx
  801a7b:	8b 75 08             	mov    0x8(%ebp),%esi
  801a7e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a81:	85 db                	test   %ebx,%ebx
  801a83:	7f e2                	jg     801a67 <vprintfmt+0x269>
  801a85:	89 75 08             	mov    %esi,0x8(%ebp)
  801a88:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a8b:	e9 93 fd ff ff       	jmp    801823 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  if (lflag >= 2)
  801a90:	83 fa 01             	cmp    $0x1,%edx
  801a93:	7e 16                	jle    801aab <vprintfmt+0x2ad>
    return va_arg(*ap, long long);
  801a95:	8b 45 14             	mov    0x14(%ebp),%eax
  801a98:	8d 50 08             	lea    0x8(%eax),%edx
  801a9b:	89 55 14             	mov    %edx,0x14(%ebp)
  801a9e:	8b 50 04             	mov    0x4(%eax),%edx
  801aa1:	8b 00                	mov    (%eax),%eax
  801aa3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801aa6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801aa9:	eb 32                	jmp    801add <vprintfmt+0x2df>
  else if (lflag)
  801aab:	85 d2                	test   %edx,%edx
  801aad:	74 18                	je     801ac7 <vprintfmt+0x2c9>
    return va_arg(*ap, long);
  801aaf:	8b 45 14             	mov    0x14(%ebp),%eax
  801ab2:	8d 50 04             	lea    0x4(%eax),%edx
  801ab5:	89 55 14             	mov    %edx,0x14(%ebp)
  801ab8:	8b 30                	mov    (%eax),%esi
  801aba:	89 75 e0             	mov    %esi,-0x20(%ebp)
  801abd:	89 f0                	mov    %esi,%eax
  801abf:	c1 f8 1f             	sar    $0x1f,%eax
  801ac2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ac5:	eb 16                	jmp    801add <vprintfmt+0x2df>
  else
    return va_arg(*ap, int);
  801ac7:	8b 45 14             	mov    0x14(%ebp),%eax
  801aca:	8d 50 04             	lea    0x4(%eax),%edx
  801acd:	89 55 14             	mov    %edx,0x14(%ebp)
  801ad0:	8b 30                	mov    (%eax),%esi
  801ad2:	89 75 e0             	mov    %esi,-0x20(%ebp)
  801ad5:	89 f0                	mov    %esi,%eax
  801ad7:	c1 f8 1f             	sar    $0x1f,%eax
  801ada:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        putch(' ', putdat);
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
  801add:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ae0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      if ((long long)num < 0) {
        putch('-', putdat);
        num = -(long long)num;
      }
      base = 10;
  801ae3:	b9 0a 00 00 00       	mov    $0xa,%ecx
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
      if ((long long)num < 0) {
  801ae8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801aec:	0f 89 80 00 00 00    	jns    801b72 <vprintfmt+0x374>
        putch('-', putdat);
  801af2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801af6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801afd:	ff 55 08             	call   *0x8(%ebp)
        num = -(long long)num;
  801b00:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b03:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801b06:	f7 d8                	neg    %eax
  801b08:	83 d2 00             	adc    $0x0,%edx
  801b0b:	f7 da                	neg    %edx
      }
      base = 10;
  801b0d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801b12:	eb 5e                	jmp    801b72 <vprintfmt+0x374>
      goto number;

    // unsigned decimal
    case 'u':
      num = getuint(&ap, lflag);
  801b14:	8d 45 14             	lea    0x14(%ebp),%eax
  801b17:	e8 63 fc ff ff       	call   80177f <getuint>
      base = 10;
  801b1c:	b9 0a 00 00 00       	mov    $0xa,%ecx
      goto number;
  801b21:	eb 4f                	jmp    801b72 <vprintfmt+0x374>

    // (unsigned) octal
    case 'o':
      num = getuint(&ap, lflag);
  801b23:	8d 45 14             	lea    0x14(%ebp),%eax
  801b26:	e8 54 fc ff ff       	call   80177f <getuint>
      base = 8;
  801b2b:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  801b30:	eb 40                	jmp    801b72 <vprintfmt+0x374>

    // pointer
    case 'p':
      putch('0', putdat);
  801b32:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b36:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801b3d:	ff 55 08             	call   *0x8(%ebp)
      putch('x', putdat);
  801b40:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b44:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801b4b:	ff 55 08             	call   *0x8(%ebp)
      num = (unsigned long long)
            (uintptr_t)va_arg(ap, void *);
  801b4e:	8b 45 14             	mov    0x14(%ebp),%eax
  801b51:	8d 50 04             	lea    0x4(%eax),%edx
  801b54:	89 55 14             	mov    %edx,0x14(%ebp)

    // pointer
    case 'p':
      putch('0', putdat);
      putch('x', putdat);
      num = (unsigned long long)
  801b57:	8b 00                	mov    (%eax),%eax
  801b59:	ba 00 00 00 00       	mov    $0x0,%edx
            (uintptr_t)va_arg(ap, void *);
      base = 16;
  801b5e:	b9 10 00 00 00       	mov    $0x10,%ecx
      goto number;
  801b63:	eb 0d                	jmp    801b72 <vprintfmt+0x374>

    // (unsigned) hexadecimal
    case 'x':
      num = getuint(&ap, lflag);
  801b65:	8d 45 14             	lea    0x14(%ebp),%eax
  801b68:	e8 12 fc ff ff       	call   80177f <getuint>
      base = 16;
  801b6d:	b9 10 00 00 00       	mov    $0x10,%ecx
number:
      printnum(putch, putdat, num, base, width, padc);
  801b72:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  801b76:	89 74 24 10          	mov    %esi,0x10(%esp)
  801b7a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  801b7d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801b81:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b85:	89 04 24             	mov    %eax,(%esp)
  801b88:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b8c:	89 fa                	mov    %edi,%edx
  801b8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b91:	e8 fa fa ff ff       	call   801690 <printnum>
      break;
  801b96:	e9 88 fc ff ff       	jmp    801823 <vprintfmt+0x25>

    // escaped '%' character
    case '%':
      putch(ch, putdat);
  801b9b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b9f:	89 04 24             	mov    %eax,(%esp)
  801ba2:	ff 55 08             	call   *0x8(%ebp)
      break;
  801ba5:	e9 79 fc ff ff       	jmp    801823 <vprintfmt+0x25>

    // unrecognized escape sequence - just print it literally
    default:
      putch('%', putdat);
  801baa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801bae:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801bb5:	ff 55 08             	call   *0x8(%ebp)
      for (fmt--; fmt[-1] != '%'; fmt--)
  801bb8:	89 f3                	mov    %esi,%ebx
  801bba:	eb 03                	jmp    801bbf <vprintfmt+0x3c1>
  801bbc:	83 eb 01             	sub    $0x1,%ebx
  801bbf:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  801bc3:	75 f7                	jne    801bbc <vprintfmt+0x3be>
  801bc5:	e9 59 fc ff ff       	jmp    801823 <vprintfmt+0x25>
        /* do nothing */;
      break;
    }
  }
}
  801bca:	83 c4 3c             	add    $0x3c,%esp
  801bcd:	5b                   	pop    %ebx
  801bce:	5e                   	pop    %esi
  801bcf:	5f                   	pop    %edi
  801bd0:	5d                   	pop    %ebp
  801bd1:	c3                   	ret    

00801bd2 <vsnprintf>:
    *b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801bd2:	55                   	push   %ebp
  801bd3:	89 e5                	mov    %esp,%ebp
  801bd5:	83 ec 28             	sub    $0x28,%esp
  801bd8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bdb:	8b 55 0c             	mov    0xc(%ebp),%edx
  struct sprintbuf b = { buf, buf+n-1, 0 };
  801bde:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801be1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801be5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801be8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  if (buf == NULL || n < 1)
  801bef:	85 c0                	test   %eax,%eax
  801bf1:	74 30                	je     801c23 <vsnprintf+0x51>
  801bf3:	85 d2                	test   %edx,%edx
  801bf5:	7e 2c                	jle    801c23 <vsnprintf+0x51>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void*)sprintputch, &b, fmt, ap);
  801bf7:	8b 45 14             	mov    0x14(%ebp),%eax
  801bfa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bfe:	8b 45 10             	mov    0x10(%ebp),%eax
  801c01:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c05:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801c08:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c0c:	c7 04 24 b9 17 80 00 	movl   $0x8017b9,(%esp)
  801c13:	e8 e6 fb ff ff       	call   8017fe <vprintfmt>

  // null terminate the buffer
  *b.buf = '\0';
  801c18:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801c1b:	c6 00 00             	movb   $0x0,(%eax)

  return b.cnt;
  801c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c21:	eb 05                	jmp    801c28 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  struct sprintbuf b = { buf, buf+n-1, 0 };

  if (buf == NULL || n < 1)
    return -E_INVAL;
  801c23:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

  // null terminate the buffer
  *b.buf = '\0';

  return b.cnt;
}
  801c28:	c9                   	leave  
  801c29:	c3                   	ret    

00801c2a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801c2a:	55                   	push   %ebp
  801c2b:	89 e5                	mov    %esp,%ebp
  801c2d:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int rc;

  va_start(ap, fmt);
  801c30:	8d 45 14             	lea    0x14(%ebp),%eax
  rc = vsnprintf(buf, n, fmt, ap);
  801c33:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c37:	8b 45 10             	mov    0x10(%ebp),%eax
  801c3a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c41:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c45:	8b 45 08             	mov    0x8(%ebp),%eax
  801c48:	89 04 24             	mov    %eax,(%esp)
  801c4b:	e8 82 ff ff ff       	call   801bd2 <vsnprintf>
  va_end(ap);

  return rc;
}
  801c50:	c9                   	leave  
  801c51:	c3                   	ret    

00801c52 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c52:	55                   	push   %ebp
  801c53:	89 e5                	mov    %esp,%ebp
  801c55:	56                   	push   %esi
  801c56:	53                   	push   %ebx
  801c57:	83 ec 10             	sub    $0x10,%esp
  801c5a:	8b 75 08             	mov    0x8(%ebp),%esi
  801c5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c60:	8b 5d 10             	mov    0x10(%ebp),%ebx
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;
  801c63:	85 c0                	test   %eax,%eax
  801c65:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801c6a:	0f 44 c2             	cmove  %edx,%eax
  if ((r = sys_ipc_recv(pg)) < 0) {
  801c6d:	89 04 24             	mov    %eax,(%esp)
  801c70:	e8 54 eb ff ff       	call   8007c9 <sys_ipc_recv>
  801c75:	85 c0                	test   %eax,%eax
  801c77:	79 34                	jns    801cad <ipc_recv+0x5b>
    if (from_env_store)
  801c79:	85 f6                	test   %esi,%esi
  801c7b:	74 06                	je     801c83 <ipc_recv+0x31>
      *from_env_store = 0;
  801c7d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (perm_store)
  801c83:	85 db                	test   %ebx,%ebx
  801c85:	74 06                	je     801c8d <ipc_recv+0x3b>
      *perm_store = 0;
  801c87:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    panic("sys_ipc_recv: %e", r);
  801c8d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c91:	c7 44 24 08 80 24 80 	movl   $0x802480,0x8(%esp)
  801c98:	00 
  801c99:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801ca0:	00 
  801ca1:	c7 04 24 91 24 80 00 	movl   $0x802491,(%esp)
  801ca8:	e8 c9 f8 ff ff       	call   801576 <_panic>
  }

  if (from_env_store)
  801cad:	85 f6                	test   %esi,%esi
  801caf:	74 0a                	je     801cbb <ipc_recv+0x69>
    *from_env_store = thisenv->env_ipc_from;
  801cb1:	a1 04 40 80 00       	mov    0x804004,%eax
  801cb6:	8b 40 74             	mov    0x74(%eax),%eax
  801cb9:	89 06                	mov    %eax,(%esi)
  if (perm_store)
  801cbb:	85 db                	test   %ebx,%ebx
  801cbd:	74 0a                	je     801cc9 <ipc_recv+0x77>
    *perm_store |= thisenv->env_ipc_perm;
  801cbf:	a1 04 40 80 00       	mov    0x804004,%eax
  801cc4:	8b 40 78             	mov    0x78(%eax),%eax
  801cc7:	09 03                	or     %eax,(%ebx)

  return thisenv->env_ipc_value;
  801cc9:	a1 04 40 80 00       	mov    0x804004,%eax
  801cce:	8b 40 70             	mov    0x70(%eax),%eax

}
  801cd1:	83 c4 10             	add    $0x10,%esp
  801cd4:	5b                   	pop    %ebx
  801cd5:	5e                   	pop    %esi
  801cd6:	5d                   	pop    %ebp
  801cd7:	c3                   	ret    

00801cd8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801cd8:	55                   	push   %ebp
  801cd9:	89 e5                	mov    %esp,%ebp
  801cdb:	57                   	push   %edi
  801cdc:	56                   	push   %esi
  801cdd:	53                   	push   %ebx
  801cde:	83 ec 1c             	sub    $0x1c,%esp
  801ce1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ce4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ce7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;
  801cea:	85 db                	test   %ebx,%ebx
  801cec:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801cf1:	0f 44 d8             	cmove  %eax,%ebx

  while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801cf4:	eb 2a                	jmp    801d20 <ipc_send+0x48>
    if (r != -E_IPC_NOT_RECV)
  801cf6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801cf9:	74 20                	je     801d1b <ipc_send+0x43>
      panic("ipc_send: %e", r);
  801cfb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cff:	c7 44 24 08 9b 24 80 	movl   $0x80249b,0x8(%esp)
  801d06:	00 
  801d07:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801d0e:	00 
  801d0f:	c7 04 24 91 24 80 00 	movl   $0x802491,(%esp)
  801d16:	e8 5b f8 ff ff       	call   801576 <_panic>
    sys_yield();
  801d1b:	e8 74 e8 ff ff       	call   800594 <sys_yield>
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;

  while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801d20:	8b 45 14             	mov    0x14(%ebp),%eax
  801d23:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d27:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d2b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d2f:	89 3c 24             	mov    %edi,(%esp)
  801d32:	e8 6f ea ff ff       	call   8007a6 <sys_ipc_try_send>
  801d37:	85 c0                	test   %eax,%eax
  801d39:	78 bb                	js     801cf6 <ipc_send+0x1e>
    if (r != -E_IPC_NOT_RECV)
      panic("ipc_send: %e", r);
    sys_yield();
  }
}
  801d3b:	83 c4 1c             	add    $0x1c,%esp
  801d3e:	5b                   	pop    %ebx
  801d3f:	5e                   	pop    %esi
  801d40:	5f                   	pop    %edi
  801d41:	5d                   	pop    %ebp
  801d42:	c3                   	ret    

00801d43 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d43:	55                   	push   %ebp
  801d44:	89 e5                	mov    %esp,%ebp
  801d46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int i;

  for (i = 0; i < NENV; i++)
  801d49:	b8 00 00 00 00       	mov    $0x0,%eax
    if (envs[i].env_type == type)
  801d4e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d51:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d57:	8b 52 50             	mov    0x50(%edx),%edx
  801d5a:	39 ca                	cmp    %ecx,%edx
  801d5c:	75 0d                	jne    801d6b <ipc_find_env+0x28>
      return envs[i].env_id;
  801d5e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d61:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801d66:	8b 40 40             	mov    0x40(%eax),%eax
  801d69:	eb 0e                	jmp    801d79 <ipc_find_env+0x36>
envid_t
ipc_find_env(enum EnvType type)
{
  int i;

  for (i = 0; i < NENV; i++)
  801d6b:	83 c0 01             	add    $0x1,%eax
  801d6e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d73:	75 d9                	jne    801d4e <ipc_find_env+0xb>
    if (envs[i].env_type == type)
      return envs[i].env_id;
  return 0;
  801d75:	66 b8 00 00          	mov    $0x0,%ax
}
  801d79:	5d                   	pop    %ebp
  801d7a:	c3                   	ret    

00801d7b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d7b:	55                   	push   %ebp
  801d7c:	89 e5                	mov    %esp,%ebp
  801d7e:	8b 55 08             	mov    0x8(%ebp),%edx
  pte_t pte;

  if (!(uvpd[PDX(v)] & PTE_P))
  801d81:	89 d0                	mov    %edx,%eax
  801d83:	c1 e8 16             	shr    $0x16,%eax
  801d86:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
    return 0;
  801d8d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
  pte_t pte;

  if (!(uvpd[PDX(v)] & PTE_P))
  801d92:	f6 c1 01             	test   $0x1,%cl
  801d95:	74 1d                	je     801db4 <pageref+0x39>
    return 0;
  pte = uvpt[PGNUM(v)];
  801d97:	c1 ea 0c             	shr    $0xc,%edx
  801d9a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  if (!(pte & PTE_P))
  801da1:	f6 c2 01             	test   $0x1,%dl
  801da4:	74 0e                	je     801db4 <pageref+0x39>
    return 0;
  return pages[PGNUM(pte)].pp_ref;
  801da6:	c1 ea 0c             	shr    $0xc,%edx
  801da9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801db0:	ef 
  801db1:	0f b7 c0             	movzwl %ax,%eax
}
  801db4:	5d                   	pop    %ebp
  801db5:	c3                   	ret    
  801db6:	66 90                	xchg   %ax,%ax
  801db8:	66 90                	xchg   %ax,%ax
  801dba:	66 90                	xchg   %ax,%ax
  801dbc:	66 90                	xchg   %ax,%ax
  801dbe:	66 90                	xchg   %ax,%ax

00801dc0 <__udivdi3>:
  801dc0:	55                   	push   %ebp
  801dc1:	57                   	push   %edi
  801dc2:	56                   	push   %esi
  801dc3:	83 ec 0c             	sub    $0xc,%esp
  801dc6:	8b 44 24 28          	mov    0x28(%esp),%eax
  801dca:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801dce:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801dd2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801dd6:	85 c0                	test   %eax,%eax
  801dd8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801ddc:	89 ea                	mov    %ebp,%edx
  801dde:	89 0c 24             	mov    %ecx,(%esp)
  801de1:	75 2d                	jne    801e10 <__udivdi3+0x50>
  801de3:	39 e9                	cmp    %ebp,%ecx
  801de5:	77 61                	ja     801e48 <__udivdi3+0x88>
  801de7:	85 c9                	test   %ecx,%ecx
  801de9:	89 ce                	mov    %ecx,%esi
  801deb:	75 0b                	jne    801df8 <__udivdi3+0x38>
  801ded:	b8 01 00 00 00       	mov    $0x1,%eax
  801df2:	31 d2                	xor    %edx,%edx
  801df4:	f7 f1                	div    %ecx
  801df6:	89 c6                	mov    %eax,%esi
  801df8:	31 d2                	xor    %edx,%edx
  801dfa:	89 e8                	mov    %ebp,%eax
  801dfc:	f7 f6                	div    %esi
  801dfe:	89 c5                	mov    %eax,%ebp
  801e00:	89 f8                	mov    %edi,%eax
  801e02:	f7 f6                	div    %esi
  801e04:	89 ea                	mov    %ebp,%edx
  801e06:	83 c4 0c             	add    $0xc,%esp
  801e09:	5e                   	pop    %esi
  801e0a:	5f                   	pop    %edi
  801e0b:	5d                   	pop    %ebp
  801e0c:	c3                   	ret    
  801e0d:	8d 76 00             	lea    0x0(%esi),%esi
  801e10:	39 e8                	cmp    %ebp,%eax
  801e12:	77 24                	ja     801e38 <__udivdi3+0x78>
  801e14:	0f bd e8             	bsr    %eax,%ebp
  801e17:	83 f5 1f             	xor    $0x1f,%ebp
  801e1a:	75 3c                	jne    801e58 <__udivdi3+0x98>
  801e1c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801e20:	39 34 24             	cmp    %esi,(%esp)
  801e23:	0f 86 9f 00 00 00    	jbe    801ec8 <__udivdi3+0x108>
  801e29:	39 d0                	cmp    %edx,%eax
  801e2b:	0f 82 97 00 00 00    	jb     801ec8 <__udivdi3+0x108>
  801e31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e38:	31 d2                	xor    %edx,%edx
  801e3a:	31 c0                	xor    %eax,%eax
  801e3c:	83 c4 0c             	add    $0xc,%esp
  801e3f:	5e                   	pop    %esi
  801e40:	5f                   	pop    %edi
  801e41:	5d                   	pop    %ebp
  801e42:	c3                   	ret    
  801e43:	90                   	nop
  801e44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e48:	89 f8                	mov    %edi,%eax
  801e4a:	f7 f1                	div    %ecx
  801e4c:	31 d2                	xor    %edx,%edx
  801e4e:	83 c4 0c             	add    $0xc,%esp
  801e51:	5e                   	pop    %esi
  801e52:	5f                   	pop    %edi
  801e53:	5d                   	pop    %ebp
  801e54:	c3                   	ret    
  801e55:	8d 76 00             	lea    0x0(%esi),%esi
  801e58:	89 e9                	mov    %ebp,%ecx
  801e5a:	8b 3c 24             	mov    (%esp),%edi
  801e5d:	d3 e0                	shl    %cl,%eax
  801e5f:	89 c6                	mov    %eax,%esi
  801e61:	b8 20 00 00 00       	mov    $0x20,%eax
  801e66:	29 e8                	sub    %ebp,%eax
  801e68:	89 c1                	mov    %eax,%ecx
  801e6a:	d3 ef                	shr    %cl,%edi
  801e6c:	89 e9                	mov    %ebp,%ecx
  801e6e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801e72:	8b 3c 24             	mov    (%esp),%edi
  801e75:	09 74 24 08          	or     %esi,0x8(%esp)
  801e79:	89 d6                	mov    %edx,%esi
  801e7b:	d3 e7                	shl    %cl,%edi
  801e7d:	89 c1                	mov    %eax,%ecx
  801e7f:	89 3c 24             	mov    %edi,(%esp)
  801e82:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801e86:	d3 ee                	shr    %cl,%esi
  801e88:	89 e9                	mov    %ebp,%ecx
  801e8a:	d3 e2                	shl    %cl,%edx
  801e8c:	89 c1                	mov    %eax,%ecx
  801e8e:	d3 ef                	shr    %cl,%edi
  801e90:	09 d7                	or     %edx,%edi
  801e92:	89 f2                	mov    %esi,%edx
  801e94:	89 f8                	mov    %edi,%eax
  801e96:	f7 74 24 08          	divl   0x8(%esp)
  801e9a:	89 d6                	mov    %edx,%esi
  801e9c:	89 c7                	mov    %eax,%edi
  801e9e:	f7 24 24             	mull   (%esp)
  801ea1:	39 d6                	cmp    %edx,%esi
  801ea3:	89 14 24             	mov    %edx,(%esp)
  801ea6:	72 30                	jb     801ed8 <__udivdi3+0x118>
  801ea8:	8b 54 24 04          	mov    0x4(%esp),%edx
  801eac:	89 e9                	mov    %ebp,%ecx
  801eae:	d3 e2                	shl    %cl,%edx
  801eb0:	39 c2                	cmp    %eax,%edx
  801eb2:	73 05                	jae    801eb9 <__udivdi3+0xf9>
  801eb4:	3b 34 24             	cmp    (%esp),%esi
  801eb7:	74 1f                	je     801ed8 <__udivdi3+0x118>
  801eb9:	89 f8                	mov    %edi,%eax
  801ebb:	31 d2                	xor    %edx,%edx
  801ebd:	e9 7a ff ff ff       	jmp    801e3c <__udivdi3+0x7c>
  801ec2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ec8:	31 d2                	xor    %edx,%edx
  801eca:	b8 01 00 00 00       	mov    $0x1,%eax
  801ecf:	e9 68 ff ff ff       	jmp    801e3c <__udivdi3+0x7c>
  801ed4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ed8:	8d 47 ff             	lea    -0x1(%edi),%eax
  801edb:	31 d2                	xor    %edx,%edx
  801edd:	83 c4 0c             	add    $0xc,%esp
  801ee0:	5e                   	pop    %esi
  801ee1:	5f                   	pop    %edi
  801ee2:	5d                   	pop    %ebp
  801ee3:	c3                   	ret    
  801ee4:	66 90                	xchg   %ax,%ax
  801ee6:	66 90                	xchg   %ax,%ax
  801ee8:	66 90                	xchg   %ax,%ax
  801eea:	66 90                	xchg   %ax,%ax
  801eec:	66 90                	xchg   %ax,%ax
  801eee:	66 90                	xchg   %ax,%ax

00801ef0 <__umoddi3>:
  801ef0:	55                   	push   %ebp
  801ef1:	57                   	push   %edi
  801ef2:	56                   	push   %esi
  801ef3:	83 ec 14             	sub    $0x14,%esp
  801ef6:	8b 44 24 28          	mov    0x28(%esp),%eax
  801efa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801efe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801f02:	89 c7                	mov    %eax,%edi
  801f04:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f08:	8b 44 24 30          	mov    0x30(%esp),%eax
  801f0c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801f10:	89 34 24             	mov    %esi,(%esp)
  801f13:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f17:	85 c0                	test   %eax,%eax
  801f19:	89 c2                	mov    %eax,%edx
  801f1b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f1f:	75 17                	jne    801f38 <__umoddi3+0x48>
  801f21:	39 fe                	cmp    %edi,%esi
  801f23:	76 4b                	jbe    801f70 <__umoddi3+0x80>
  801f25:	89 c8                	mov    %ecx,%eax
  801f27:	89 fa                	mov    %edi,%edx
  801f29:	f7 f6                	div    %esi
  801f2b:	89 d0                	mov    %edx,%eax
  801f2d:	31 d2                	xor    %edx,%edx
  801f2f:	83 c4 14             	add    $0x14,%esp
  801f32:	5e                   	pop    %esi
  801f33:	5f                   	pop    %edi
  801f34:	5d                   	pop    %ebp
  801f35:	c3                   	ret    
  801f36:	66 90                	xchg   %ax,%ax
  801f38:	39 f8                	cmp    %edi,%eax
  801f3a:	77 54                	ja     801f90 <__umoddi3+0xa0>
  801f3c:	0f bd e8             	bsr    %eax,%ebp
  801f3f:	83 f5 1f             	xor    $0x1f,%ebp
  801f42:	75 5c                	jne    801fa0 <__umoddi3+0xb0>
  801f44:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801f48:	39 3c 24             	cmp    %edi,(%esp)
  801f4b:	0f 87 e7 00 00 00    	ja     802038 <__umoddi3+0x148>
  801f51:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801f55:	29 f1                	sub    %esi,%ecx
  801f57:	19 c7                	sbb    %eax,%edi
  801f59:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f5d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f61:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f65:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801f69:	83 c4 14             	add    $0x14,%esp
  801f6c:	5e                   	pop    %esi
  801f6d:	5f                   	pop    %edi
  801f6e:	5d                   	pop    %ebp
  801f6f:	c3                   	ret    
  801f70:	85 f6                	test   %esi,%esi
  801f72:	89 f5                	mov    %esi,%ebp
  801f74:	75 0b                	jne    801f81 <__umoddi3+0x91>
  801f76:	b8 01 00 00 00       	mov    $0x1,%eax
  801f7b:	31 d2                	xor    %edx,%edx
  801f7d:	f7 f6                	div    %esi
  801f7f:	89 c5                	mov    %eax,%ebp
  801f81:	8b 44 24 04          	mov    0x4(%esp),%eax
  801f85:	31 d2                	xor    %edx,%edx
  801f87:	f7 f5                	div    %ebp
  801f89:	89 c8                	mov    %ecx,%eax
  801f8b:	f7 f5                	div    %ebp
  801f8d:	eb 9c                	jmp    801f2b <__umoddi3+0x3b>
  801f8f:	90                   	nop
  801f90:	89 c8                	mov    %ecx,%eax
  801f92:	89 fa                	mov    %edi,%edx
  801f94:	83 c4 14             	add    $0x14,%esp
  801f97:	5e                   	pop    %esi
  801f98:	5f                   	pop    %edi
  801f99:	5d                   	pop    %ebp
  801f9a:	c3                   	ret    
  801f9b:	90                   	nop
  801f9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fa0:	8b 04 24             	mov    (%esp),%eax
  801fa3:	be 20 00 00 00       	mov    $0x20,%esi
  801fa8:	89 e9                	mov    %ebp,%ecx
  801faa:	29 ee                	sub    %ebp,%esi
  801fac:	d3 e2                	shl    %cl,%edx
  801fae:	89 f1                	mov    %esi,%ecx
  801fb0:	d3 e8                	shr    %cl,%eax
  801fb2:	89 e9                	mov    %ebp,%ecx
  801fb4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fb8:	8b 04 24             	mov    (%esp),%eax
  801fbb:	09 54 24 04          	or     %edx,0x4(%esp)
  801fbf:	89 fa                	mov    %edi,%edx
  801fc1:	d3 e0                	shl    %cl,%eax
  801fc3:	89 f1                	mov    %esi,%ecx
  801fc5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fc9:	8b 44 24 10          	mov    0x10(%esp),%eax
  801fcd:	d3 ea                	shr    %cl,%edx
  801fcf:	89 e9                	mov    %ebp,%ecx
  801fd1:	d3 e7                	shl    %cl,%edi
  801fd3:	89 f1                	mov    %esi,%ecx
  801fd5:	d3 e8                	shr    %cl,%eax
  801fd7:	89 e9                	mov    %ebp,%ecx
  801fd9:	09 f8                	or     %edi,%eax
  801fdb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801fdf:	f7 74 24 04          	divl   0x4(%esp)
  801fe3:	d3 e7                	shl    %cl,%edi
  801fe5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801fe9:	89 d7                	mov    %edx,%edi
  801feb:	f7 64 24 08          	mull   0x8(%esp)
  801fef:	39 d7                	cmp    %edx,%edi
  801ff1:	89 c1                	mov    %eax,%ecx
  801ff3:	89 14 24             	mov    %edx,(%esp)
  801ff6:	72 2c                	jb     802024 <__umoddi3+0x134>
  801ff8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801ffc:	72 22                	jb     802020 <__umoddi3+0x130>
  801ffe:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802002:	29 c8                	sub    %ecx,%eax
  802004:	19 d7                	sbb    %edx,%edi
  802006:	89 e9                	mov    %ebp,%ecx
  802008:	89 fa                	mov    %edi,%edx
  80200a:	d3 e8                	shr    %cl,%eax
  80200c:	89 f1                	mov    %esi,%ecx
  80200e:	d3 e2                	shl    %cl,%edx
  802010:	89 e9                	mov    %ebp,%ecx
  802012:	d3 ef                	shr    %cl,%edi
  802014:	09 d0                	or     %edx,%eax
  802016:	89 fa                	mov    %edi,%edx
  802018:	83 c4 14             	add    $0x14,%esp
  80201b:	5e                   	pop    %esi
  80201c:	5f                   	pop    %edi
  80201d:	5d                   	pop    %ebp
  80201e:	c3                   	ret    
  80201f:	90                   	nop
  802020:	39 d7                	cmp    %edx,%edi
  802022:	75 da                	jne    801ffe <__umoddi3+0x10e>
  802024:	8b 14 24             	mov    (%esp),%edx
  802027:	89 c1                	mov    %eax,%ecx
  802029:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80202d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802031:	eb cb                	jmp    801ffe <__umoddi3+0x10e>
  802033:	90                   	nop
  802034:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802038:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80203c:	0f 82 0f ff ff ff    	jb     801f51 <__umoddi3+0x61>
  802042:	e9 1a ff ff ff       	jmp    801f61 <__umoddi3+0x71>
