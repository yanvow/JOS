
obj/user/dumbfork.debug:     file format elf32-i386


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
  80002c:	e8 1d 02 00 00       	call   80024e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <duppage>:
  }
}

void
duppage(envid_t dstenv, void *addr)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 20             	sub    $0x20,%esp
  800048:	8b 75 08             	mov    0x8(%ebp),%esi
  80004b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int r;

  // This is NOT what you should do in your fork.
  if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80004e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800055:	00 
  800056:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80005a:	89 34 24             	mov    %esi,(%esp)
  80005d:	e8 91 0d 00 00       	call   800df3 <sys_page_alloc>
  800062:	85 c0                	test   %eax,%eax
  800064:	79 20                	jns    800086 <duppage+0x46>
    panic("sys_page_alloc: %e", r);
  800066:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80006a:	c7 44 24 08 c0 21 80 	movl   $0x8021c0,0x8(%esp)
  800071:	00 
  800072:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800079:	00 
  80007a:	c7 04 24 d3 21 80 00 	movl   $0x8021d3,(%esp)
  800081:	e8 29 02 00 00       	call   8002af <_panic>
  if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800086:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80008d:	00 
  80008e:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800095:	00 
  800096:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80009d:	00 
  80009e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a2:	89 34 24             	mov    %esi,(%esp)
  8000a5:	e8 9d 0d 00 00       	call   800e47 <sys_page_map>
  8000aa:	85 c0                	test   %eax,%eax
  8000ac:	79 20                	jns    8000ce <duppage+0x8e>
    panic("sys_page_map: %e", r);
  8000ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b2:	c7 44 24 08 e3 21 80 	movl   $0x8021e3,0x8(%esp)
  8000b9:	00 
  8000ba:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000c1:	00 
  8000c2:	c7 04 24 d3 21 80 00 	movl   $0x8021d3,(%esp)
  8000c9:	e8 e1 01 00 00       	call   8002af <_panic>
  memmove(UTEMP, addr, PGSIZE);
  8000ce:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000d5:	00 
  8000d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000da:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000e1:	e8 8e 0a 00 00       	call   800b74 <memmove>
  if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000e6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000ed:	00 
  8000ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f5:	e8 a0 0d 00 00       	call   800e9a <sys_page_unmap>
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	79 20                	jns    80011e <duppage+0xde>
    panic("sys_page_unmap: %e", r);
  8000fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800102:	c7 44 24 08 f4 21 80 	movl   $0x8021f4,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 d3 21 80 00 	movl   $0x8021d3,(%esp)
  800119:	e8 91 01 00 00       	call   8002af <_panic>
}
  80011e:	83 c4 20             	add    $0x20,%esp
  800121:	5b                   	pop    %ebx
  800122:	5e                   	pop    %esi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <dumbfork>:

envid_t
dumbfork(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	83 ec 20             	sub    $0x20,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
  envid_t ret;
  __asm __volatile("int %2"
  80012d:	b8 07 00 00 00       	mov    $0x7,%eax
  800132:	cd 30                	int    $0x30
  800134:	89 c6                	mov    %eax,%esi
  // The kernel will initialize it with a copy of our register state,
  // so that the child will appear to have called sys_exofork() too -
  // except that in the child, this "fake" call to sys_exofork()
  // will return 0 instead of the envid of the child.
  envid = sys_exofork();
  if (envid < 0)
  800136:	85 c0                	test   %eax,%eax
  800138:	79 20                	jns    80015a <dumbfork+0x35>
    panic("sys_exofork: %e", envid);
  80013a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80013e:	c7 44 24 08 07 22 80 	movl   $0x802207,0x8(%esp)
  800145:	00 
  800146:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  80014d:	00 
  80014e:	c7 04 24 d3 21 80 00 	movl   $0x8021d3,(%esp)
  800155:	e8 55 01 00 00       	call   8002af <_panic>
  80015a:	89 c3                	mov    %eax,%ebx
  if (envid == 0) {
  80015c:	85 c0                	test   %eax,%eax
  80015e:	75 1e                	jne    80017e <dumbfork+0x59>
    // We're the child.
    // The copied value of the global variable 'thisenv'
    // is no longer valid (it refers to the parent!).
    // Fix it and return 0.
    thisenv = &envs[ENVX(sys_getenvid())];
  800160:	e8 50 0c 00 00       	call   800db5 <sys_getenvid>
  800165:	25 ff 03 00 00       	and    $0x3ff,%eax
  80016a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80016d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800172:	a3 04 40 80 00       	mov    %eax,0x804004
    return 0;
  800177:	b8 00 00 00 00       	mov    $0x0,%eax
  80017c:	eb 71                	jmp    8001ef <dumbfork+0xca>
  }

  // We're the parent.
  // Eagerly copy our entire address space into the child.
  // This is NOT what you should do in your fork implementation.
  for (addr = (uint8_t*)UTEXT; addr < end; addr += PGSIZE)
  80017e:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800185:	eb 13                	jmp    80019a <dumbfork+0x75>
    duppage(envid, addr);
  800187:	89 54 24 04          	mov    %edx,0x4(%esp)
  80018b:	89 1c 24             	mov    %ebx,(%esp)
  80018e:	e8 ad fe ff ff       	call   800040 <duppage>
  }

  // We're the parent.
  // Eagerly copy our entire address space into the child.
  // This is NOT what you should do in your fork implementation.
  for (addr = (uint8_t*)UTEXT; addr < end; addr += PGSIZE)
  800193:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  80019a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80019d:	81 fa 00 60 80 00    	cmp    $0x806000,%edx
  8001a3:	72 e2                	jb     800187 <dumbfork+0x62>
    duppage(envid, addr);

  // Also copy the stack we are currently running on.
  duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  8001a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001a8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8001ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b1:	89 34 24             	mov    %esi,(%esp)
  8001b4:	e8 87 fe ff ff       	call   800040 <duppage>

  // Start the child environment running
  if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001b9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8001c0:	00 
  8001c1:	89 34 24             	mov    %esi,(%esp)
  8001c4:	e8 24 0d 00 00       	call   800eed <sys_env_set_status>
  8001c9:	85 c0                	test   %eax,%eax
  8001cb:	79 20                	jns    8001ed <dumbfork+0xc8>
    panic("sys_env_set_status: %e", r);
  8001cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d1:	c7 44 24 08 17 22 80 	movl   $0x802217,0x8(%esp)
  8001d8:	00 
  8001d9:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8001e0:	00 
  8001e1:	c7 04 24 d3 21 80 00 	movl   $0x8021d3,(%esp)
  8001e8:	e8 c2 00 00 00       	call   8002af <_panic>

  return envid;
  8001ed:	89 f0                	mov    %esi,%eax
}
  8001ef:	83 c4 20             	add    $0x20,%esp
  8001f2:	5b                   	pop    %ebx
  8001f3:	5e                   	pop    %esi
  8001f4:	5d                   	pop    %ebp
  8001f5:	c3                   	ret    

008001f6 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
  8001fb:	83 ec 10             	sub    $0x10,%esp
  envid_t who;
  int i;

  // fork a child process
  who = dumbfork();
  8001fe:	e8 22 ff ff ff       	call   800125 <dumbfork>
  800203:	89 c6                	mov    %eax,%esi

  // print a message and yield to the other a few times
  for (i = 0; i < (who ? 10 : 20); i++) {
  800205:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020a:	eb 28                	jmp    800234 <umain+0x3e>
    cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  80020c:	b8 35 22 80 00       	mov    $0x802235,%eax
  800211:	eb 05                	jmp    800218 <umain+0x22>
  800213:	b8 2e 22 80 00       	mov    $0x80222e,%eax
  800218:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800220:	c7 04 24 3b 22 80 00 	movl   $0x80223b,(%esp)
  800227:	e8 7c 01 00 00       	call   8003a8 <cprintf>
    sys_yield();
  80022c:	e8 a3 0b 00 00       	call   800dd4 <sys_yield>

  // fork a child process
  who = dumbfork();

  // print a message and yield to the other a few times
  for (i = 0; i < (who ? 10 : 20); i++) {
  800231:	83 c3 01             	add    $0x1,%ebx
  800234:	85 f6                	test   %esi,%esi
  800236:	75 0a                	jne    800242 <umain+0x4c>
  800238:	83 fb 13             	cmp    $0x13,%ebx
  80023b:	7e cf                	jle    80020c <umain+0x16>
  80023d:	8d 76 00             	lea    0x0(%esi),%esi
  800240:	eb 05                	jmp    800247 <umain+0x51>
  800242:	83 fb 09             	cmp    $0x9,%ebx
  800245:	7e cc                	jle    800213 <umain+0x1d>
    cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
    sys_yield();
  }
}
  800247:	83 c4 10             	add    $0x10,%esp
  80024a:	5b                   	pop    %ebx
  80024b:	5e                   	pop    %esi
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	56                   	push   %esi
  800252:	53                   	push   %ebx
  800253:	83 ec 10             	sub    $0x10,%esp
  800256:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800259:	8b 75 0c             	mov    0xc(%ebp),%esi
  // set thisenv to point at our Env structure in envs[].
  // LAB 3: Your code here.
  thisenv = envs + ENVX(sys_getenvid());
  80025c:	e8 54 0b 00 00       	call   800db5 <sys_getenvid>
  800261:	25 ff 03 00 00       	and    $0x3ff,%eax
  800266:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800269:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80026e:	a3 04 40 80 00       	mov    %eax,0x804004

  // save the name of the program so that panic() can use it
  if (argc > 0)
  800273:	85 db                	test   %ebx,%ebx
  800275:	7e 07                	jle    80027e <libmain+0x30>
    binaryname = argv[0];
  800277:	8b 06                	mov    (%esi),%eax
  800279:	a3 00 30 80 00       	mov    %eax,0x803000

  // call user main routine
  umain(argc, argv);
  80027e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800282:	89 1c 24             	mov    %ebx,(%esp)
  800285:	e8 6c ff ff ff       	call   8001f6 <umain>

  // exit gracefully
  exit();
  80028a:	e8 07 00 00 00       	call   800296 <exit>
}
  80028f:	83 c4 10             	add    $0x10,%esp
  800292:	5b                   	pop    %ebx
  800293:	5e                   	pop    %esi
  800294:	5d                   	pop    %ebp
  800295:	c3                   	ret    

00800296 <exit>:
#include <inc/lib.h>

void
exit(void)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	83 ec 18             	sub    $0x18,%esp
  close_all();
  80029c:	e8 94 0f 00 00       	call   801235 <close_all>
  sys_env_destroy(0);
  8002a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002a8:	e8 b6 0a 00 00       	call   800d63 <sys_env_destroy>
}
  8002ad:	c9                   	leave  
  8002ae:	c3                   	ret    

008002af <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 20             	sub    $0x20,%esp
  va_list ap;

  va_start(ap, fmt);
  8002b7:	8d 5d 14             	lea    0x14(%ebp),%ebx

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  8002ba:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002c0:	e8 f0 0a 00 00       	call   800db5 <sys_getenvid>
  8002c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002d3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8002d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002db:	c7 04 24 58 22 80 00 	movl   $0x802258,(%esp)
  8002e2:	e8 c1 00 00 00       	call   8003a8 <cprintf>
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  8002e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002eb:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ee:	89 04 24             	mov    %eax,(%esp)
  8002f1:	e8 51 00 00 00       	call   800347 <vcprintf>
  cprintf("\n");
  8002f6:	c7 04 24 4b 22 80 00 	movl   $0x80224b,(%esp)
  8002fd:	e8 a6 00 00 00       	call   8003a8 <cprintf>

  // Cause a breakpoint exception
  while (1)
    asm volatile ("int3");
  800302:	cc                   	int3   
  800303:	eb fd                	jmp    800302 <_panic+0x53>

00800305 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	53                   	push   %ebx
  800309:	83 ec 14             	sub    $0x14,%esp
  80030c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  b->buf[b->idx++] = ch;
  80030f:	8b 13                	mov    (%ebx),%edx
  800311:	8d 42 01             	lea    0x1(%edx),%eax
  800314:	89 03                	mov    %eax,(%ebx)
  800316:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800319:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
  if (b->idx == 256-1) {
  80031d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800322:	75 19                	jne    80033d <putch+0x38>
    sys_cputs(b->buf, b->idx);
  800324:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80032b:	00 
  80032c:	8d 43 08             	lea    0x8(%ebx),%eax
  80032f:	89 04 24             	mov    %eax,(%esp)
  800332:	e8 ef 09 00 00       	call   800d26 <sys_cputs>
    b->idx = 0;
  800337:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  }
  b->cnt++;
  80033d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800341:	83 c4 14             	add    $0x14,%esp
  800344:	5b                   	pop    %ebx
  800345:	5d                   	pop    %ebp
  800346:	c3                   	ret    

00800347 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	81 ec 28 01 00 00    	sub    $0x128,%esp
  struct printbuf b;

  b.idx = 0;
  800350:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800357:	00 00 00 
  b.cnt = 0;
  80035a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800361:	00 00 00 
  vprintfmt((void*)putch, &b, fmt, ap);
  800364:	8b 45 0c             	mov    0xc(%ebp),%eax
  800367:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80036b:	8b 45 08             	mov    0x8(%ebp),%eax
  80036e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800372:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800378:	89 44 24 04          	mov    %eax,0x4(%esp)
  80037c:	c7 04 24 05 03 80 00 	movl   $0x800305,(%esp)
  800383:	e8 b6 01 00 00       	call   80053e <vprintfmt>
  sys_cputs(b.buf, b.idx);
  800388:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80038e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800392:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800398:	89 04 24             	mov    %eax,(%esp)
  80039b:	e8 86 09 00 00       	call   800d26 <sys_cputs>

  return b.cnt;
}
  8003a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003a6:	c9                   	leave  
  8003a7:	c3                   	ret    

008003a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003a8:	55                   	push   %ebp
  8003a9:	89 e5                	mov    %esp,%ebp
  8003ab:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8003ae:	8d 45 0c             	lea    0xc(%ebp),%eax
  cnt = vcprintf(fmt, ap);
  8003b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b8:	89 04 24             	mov    %eax,(%esp)
  8003bb:	e8 87 ff ff ff       	call   800347 <vcprintf>
  va_end(ap);

  return cnt;
}
  8003c0:	c9                   	leave  
  8003c1:	c3                   	ret    
  8003c2:	66 90                	xchg   %ax,%ax
  8003c4:	66 90                	xchg   %ax,%ax
  8003c6:	66 90                	xchg   %ax,%ax
  8003c8:	66 90                	xchg   %ax,%ax
  8003ca:	66 90                	xchg   %ax,%ax
  8003cc:	66 90                	xchg   %ax,%ax
  8003ce:	66 90                	xchg   %ax,%ax

008003d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
         unsigned long long num, unsigned base, int width, int padc)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	57                   	push   %edi
  8003d4:	56                   	push   %esi
  8003d5:	53                   	push   %ebx
  8003d6:	83 ec 3c             	sub    $0x3c,%esp
  8003d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003dc:	89 d7                	mov    %edx,%edi
  8003de:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003e7:	89 c3                	mov    %eax,%ebx
  8003e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ef:	8b 75 14             	mov    0x14(%ebp),%esi
  // first recursively print all preceding (more significant) digits
  if (num >= base)
  8003f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003fd:	39 d9                	cmp    %ebx,%ecx
  8003ff:	72 05                	jb     800406 <printnum+0x36>
  800401:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800404:	77 69                	ja     80046f <printnum+0x9f>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  800406:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800409:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80040d:	83 ee 01             	sub    $0x1,%esi
  800410:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800414:	89 44 24 08          	mov    %eax,0x8(%esp)
  800418:	8b 44 24 08          	mov    0x8(%esp),%eax
  80041c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800420:	89 c3                	mov    %eax,%ebx
  800422:	89 d6                	mov    %edx,%esi
  800424:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800427:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80042a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80042e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800432:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800435:	89 04 24             	mov    %eax,(%esp)
  800438:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80043b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80043f:	e8 dc 1a 00 00       	call   801f20 <__udivdi3>
  800444:	89 d9                	mov    %ebx,%ecx
  800446:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80044a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80044e:	89 04 24             	mov    %eax,(%esp)
  800451:	89 54 24 04          	mov    %edx,0x4(%esp)
  800455:	89 fa                	mov    %edi,%edx
  800457:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80045a:	e8 71 ff ff ff       	call   8003d0 <printnum>
  80045f:	eb 1b                	jmp    80047c <printnum+0xac>
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
      putch(padc, putdat);
  800461:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800465:	8b 45 18             	mov    0x18(%ebp),%eax
  800468:	89 04 24             	mov    %eax,(%esp)
  80046b:	ff d3                	call   *%ebx
  80046d:	eb 03                	jmp    800472 <printnum+0xa2>
  80046f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  // first recursively print all preceding (more significant) digits
  if (num >= base)
    printnum(putch, putdat, num / base, base, width - 1, padc);
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
  800472:	83 ee 01             	sub    $0x1,%esi
  800475:	85 f6                	test   %esi,%esi
  800477:	7f e8                	jg     800461 <printnum+0x91>
  800479:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
      putch(padc, putdat);
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  80047c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800480:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800484:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800487:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80048a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80048e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800492:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800495:	89 04 24             	mov    %eax,(%esp)
  800498:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80049b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049f:	e8 ac 1b 00 00       	call   802050 <__umoddi3>
  8004a4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004a8:	0f be 80 7b 22 80 00 	movsbl 0x80227b(%eax),%eax
  8004af:	89 04 24             	mov    %eax,(%esp)
  8004b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004b5:	ff d0                	call   *%eax
}
  8004b7:	83 c4 3c             	add    $0x3c,%esp
  8004ba:	5b                   	pop    %ebx
  8004bb:	5e                   	pop    %esi
  8004bc:	5f                   	pop    %edi
  8004bd:	5d                   	pop    %ebp
  8004be:	c3                   	ret    

008004bf <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004bf:	55                   	push   %ebp
  8004c0:	89 e5                	mov    %esp,%ebp
  if (lflag >= 2)
  8004c2:	83 fa 01             	cmp    $0x1,%edx
  8004c5:	7e 0e                	jle    8004d5 <getuint+0x16>
    return va_arg(*ap, unsigned long long);
  8004c7:	8b 10                	mov    (%eax),%edx
  8004c9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004cc:	89 08                	mov    %ecx,(%eax)
  8004ce:	8b 02                	mov    (%edx),%eax
  8004d0:	8b 52 04             	mov    0x4(%edx),%edx
  8004d3:	eb 22                	jmp    8004f7 <getuint+0x38>
  else if (lflag)
  8004d5:	85 d2                	test   %edx,%edx
  8004d7:	74 10                	je     8004e9 <getuint+0x2a>
    return va_arg(*ap, unsigned long);
  8004d9:	8b 10                	mov    (%eax),%edx
  8004db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004de:	89 08                	mov    %ecx,(%eax)
  8004e0:	8b 02                	mov    (%edx),%eax
  8004e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e7:	eb 0e                	jmp    8004f7 <getuint+0x38>
  else
    return va_arg(*ap, unsigned int);
  8004e9:	8b 10                	mov    (%eax),%edx
  8004eb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ee:	89 08                	mov    %ecx,(%eax)
  8004f0:	8b 02                	mov    (%edx),%eax
  8004f2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004f7:	5d                   	pop    %ebp
  8004f8:	c3                   	ret    

008004f9 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004f9:	55                   	push   %ebp
  8004fa:	89 e5                	mov    %esp,%ebp
  8004fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  b->cnt++;
  8004ff:	83 40 08 01          	addl   $0x1,0x8(%eax)
  if (b->buf < b->ebuf)
  800503:	8b 10                	mov    (%eax),%edx
  800505:	3b 50 04             	cmp    0x4(%eax),%edx
  800508:	73 0a                	jae    800514 <sprintputch+0x1b>
    *b->buf++ = ch;
  80050a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80050d:	89 08                	mov    %ecx,(%eax)
  80050f:	8b 45 08             	mov    0x8(%ebp),%eax
  800512:	88 02                	mov    %al,(%edx)
}
  800514:	5d                   	pop    %ebp
  800515:	c3                   	ret    

00800516 <printfmt>:
  }
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
  800519:	83 ec 18             	sub    $0x18,%esp
  va_list ap;

  va_start(ap, fmt);
  80051c:	8d 45 14             	lea    0x14(%ebp),%eax
  vprintfmt(putch, putdat, fmt, ap);
  80051f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800523:	8b 45 10             	mov    0x10(%ebp),%eax
  800526:	89 44 24 08          	mov    %eax,0x8(%esp)
  80052a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80052d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800531:	8b 45 08             	mov    0x8(%ebp),%eax
  800534:	89 04 24             	mov    %eax,(%esp)
  800537:	e8 02 00 00 00       	call   80053e <vprintfmt>
  va_end(ap);
}
  80053c:	c9                   	leave  
  80053d:	c3                   	ret    

0080053e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80053e:	55                   	push   %ebp
  80053f:	89 e5                	mov    %esp,%ebp
  800541:	57                   	push   %edi
  800542:	56                   	push   %esi
  800543:	53                   	push   %ebx
  800544:	83 ec 3c             	sub    $0x3c,%esp
  800547:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80054a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80054d:	eb 14                	jmp    800563 <vprintfmt+0x25>
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
      if (ch == '\0')
  80054f:	85 c0                	test   %eax,%eax
  800551:	0f 84 b3 03 00 00    	je     80090a <vprintfmt+0x3cc>
        return;
      putch(ch, putdat);
  800557:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80055b:	89 04 24             	mov    %eax,(%esp)
  80055e:	ff 55 08             	call   *0x8(%ebp)
  unsigned long long num;
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
  800561:	89 f3                	mov    %esi,%ebx
  800563:	8d 73 01             	lea    0x1(%ebx),%esi
  800566:	0f b6 03             	movzbl (%ebx),%eax
  800569:	83 f8 25             	cmp    $0x25,%eax
  80056c:	75 e1                	jne    80054f <vprintfmt+0x11>
  80056e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800572:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800579:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800580:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800587:	ba 00 00 00 00       	mov    $0x0,%edx
  80058c:	eb 1d                	jmp    8005ab <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80058e:	89 de                	mov    %ebx,%esi

    // flag to pad on the right
    case '-':
      padc = '-';
  800590:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800594:	eb 15                	jmp    8005ab <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  800596:	89 de                	mov    %ebx,%esi
      padc = '-';
      goto reswitch;

    // flag to pad with 0's instead of spaces
    case '0':
      padc = '0';
  800598:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80059c:	eb 0d                	jmp    8005ab <vprintfmt+0x6d>
      altflag = 1;
      goto reswitch;

process_precision:
      if (width < 0)
        width = precision, precision = -1;
  80059e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005a1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005a4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8005ab:	8d 5e 01             	lea    0x1(%esi),%ebx
  8005ae:	0f b6 0e             	movzbl (%esi),%ecx
  8005b1:	0f b6 c1             	movzbl %cl,%eax
  8005b4:	83 e9 23             	sub    $0x23,%ecx
  8005b7:	80 f9 55             	cmp    $0x55,%cl
  8005ba:	0f 87 2a 03 00 00    	ja     8008ea <vprintfmt+0x3ac>
  8005c0:	0f b6 c9             	movzbl %cl,%ecx
  8005c3:	ff 24 8d c0 23 80 00 	jmp    *0x8023c0(,%ecx,4)
  8005ca:	89 de                	mov    %ebx,%esi
  8005cc:	b9 00 00 00 00       	mov    $0x0,%ecx
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
        precision = precision * 10 + ch - '0';
  8005d1:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8005d4:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
        ch = *fmt;
  8005d8:	0f be 06             	movsbl (%esi),%eax
        if (ch < '0' || ch > '9')
  8005db:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8005de:	83 fb 09             	cmp    $0x9,%ebx
  8005e1:	77 36                	ja     800619 <vprintfmt+0xdb>
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
  8005e3:	83 c6 01             	add    $0x1,%esi
        precision = precision * 10 + ch - '0';
        ch = *fmt;
        if (ch < '0' || ch > '9')
          break;
      }
  8005e6:	eb e9                	jmp    8005d1 <vprintfmt+0x93>
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8d 48 04             	lea    0x4(%eax),%ecx
  8005ee:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005f1:	8b 00                	mov    (%eax),%eax
  8005f3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8005f6:	89 de                	mov    %ebx,%esi
      }
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
      goto process_precision;
  8005f8:	eb 22                	jmp    80061c <vprintfmt+0xde>
  8005fa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005fd:	85 c9                	test   %ecx,%ecx
  8005ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800604:	0f 49 c1             	cmovns %ecx,%eax
  800607:	89 45 dc             	mov    %eax,-0x24(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80060a:	89 de                	mov    %ebx,%esi
  80060c:	eb 9d                	jmp    8005ab <vprintfmt+0x6d>
  80060e:	89 de                	mov    %ebx,%esi
      if (width < 0)
        width = 0;
      goto reswitch;

    case '#':
      altflag = 1;
  800610:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
      goto reswitch;
  800617:	eb 92                	jmp    8005ab <vprintfmt+0x6d>
  800619:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

process_precision:
      if (width < 0)
  80061c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800620:	79 89                	jns    8005ab <vprintfmt+0x6d>
  800622:	e9 77 ff ff ff       	jmp    80059e <vprintfmt+0x60>
        width = precision, precision = -1;
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
  800627:	83 c2 01             	add    $0x1,%edx
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80062a:	89 de                	mov    %ebx,%esi
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
      goto reswitch;
  80062c:	e9 7a ff ff ff       	jmp    8005ab <vprintfmt+0x6d>

    // character
    case 'c':
      putch(va_arg(ap, int), putdat);
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8d 50 04             	lea    0x4(%eax),%edx
  800637:	89 55 14             	mov    %edx,0x14(%ebp)
  80063a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80063e:	8b 00                	mov    (%eax),%eax
  800640:	89 04 24             	mov    %eax,(%esp)
  800643:	ff 55 08             	call   *0x8(%ebp)
      break;
  800646:	e9 18 ff ff ff       	jmp    800563 <vprintfmt+0x25>

    // error message
    case 'e':
      err = va_arg(ap, int);
  80064b:	8b 45 14             	mov    0x14(%ebp),%eax
  80064e:	8d 50 04             	lea    0x4(%eax),%edx
  800651:	89 55 14             	mov    %edx,0x14(%ebp)
  800654:	8b 00                	mov    (%eax),%eax
  800656:	99                   	cltd   
  800657:	31 d0                	xor    %edx,%eax
  800659:	29 d0                	sub    %edx,%eax
      if (err < 0)
        err = -err;
      if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80065b:	83 f8 0f             	cmp    $0xf,%eax
  80065e:	7f 0b                	jg     80066b <vprintfmt+0x12d>
  800660:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  800667:	85 d2                	test   %edx,%edx
  800669:	75 20                	jne    80068b <vprintfmt+0x14d>
        printfmt(putch, putdat, "error %d", err);
  80066b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80066f:	c7 44 24 08 93 22 80 	movl   $0x802293,0x8(%esp)
  800676:	00 
  800677:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80067b:	8b 45 08             	mov    0x8(%ebp),%eax
  80067e:	89 04 24             	mov    %eax,(%esp)
  800681:	e8 90 fe ff ff       	call   800516 <printfmt>
  800686:	e9 d8 fe ff ff       	jmp    800563 <vprintfmt+0x25>
      else
        printfmt(putch, putdat, "%s", p);
  80068b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80068f:	c7 44 24 08 9c 22 80 	movl   $0x80229c,0x8(%esp)
  800696:	00 
  800697:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80069b:	8b 45 08             	mov    0x8(%ebp),%eax
  80069e:	89 04 24             	mov    %eax,(%esp)
  8006a1:	e8 70 fe ff ff       	call   800516 <printfmt>
  8006a6:	e9 b8 fe ff ff       	jmp    800563 <vprintfmt+0x25>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8006ab:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8006ae:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006b1:	89 45 d0             	mov    %eax,-0x30(%ebp)
        printfmt(putch, putdat, "%s", p);
      break;

    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8d 50 04             	lea    0x4(%eax),%edx
  8006ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bd:	8b 30                	mov    (%eax),%esi
        p = "(null)";
  8006bf:	85 f6                	test   %esi,%esi
  8006c1:	b8 8c 22 80 00       	mov    $0x80228c,%eax
  8006c6:	0f 44 f0             	cmove  %eax,%esi
      if (width > 0 && padc != '-')
  8006c9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8006cd:	0f 84 97 00 00 00    	je     80076a <vprintfmt+0x22c>
  8006d3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8006d7:	0f 8e 9b 00 00 00    	jle    800778 <vprintfmt+0x23a>
        for (width -= strnlen(p, precision); width > 0; width--)
  8006dd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006e1:	89 34 24             	mov    %esi,(%esp)
  8006e4:	e8 cf 02 00 00       	call   8009b8 <strnlen>
  8006e9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006ec:	29 c2                	sub    %eax,%edx
  8006ee:	89 55 d0             	mov    %edx,-0x30(%ebp)
          putch(padc, putdat);
  8006f1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8006f5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006f8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8006fe:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800701:	89 d3                	mov    %edx,%ebx
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
  800703:	eb 0f                	jmp    800714 <vprintfmt+0x1d6>
          putch(padc, putdat);
  800705:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800709:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80070c:	89 04 24             	mov    %eax,(%esp)
  80070f:	ff d6                	call   *%esi
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
  800711:	83 eb 01             	sub    $0x1,%ebx
  800714:	85 db                	test   %ebx,%ebx
  800716:	7f ed                	jg     800705 <vprintfmt+0x1c7>
  800718:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80071b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80071e:	85 d2                	test   %edx,%edx
  800720:	b8 00 00 00 00       	mov    $0x0,%eax
  800725:	0f 49 c2             	cmovns %edx,%eax
  800728:	29 c2                	sub    %eax,%edx
  80072a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80072d:	89 d7                	mov    %edx,%edi
  80072f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800732:	eb 50                	jmp    800784 <vprintfmt+0x246>
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
  800734:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800738:	74 1e                	je     800758 <vprintfmt+0x21a>
  80073a:	0f be d2             	movsbl %dl,%edx
  80073d:	83 ea 20             	sub    $0x20,%edx
  800740:	83 fa 5e             	cmp    $0x5e,%edx
  800743:	76 13                	jbe    800758 <vprintfmt+0x21a>
          putch('?', putdat);
  800745:	8b 45 0c             	mov    0xc(%ebp),%eax
  800748:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800753:	ff 55 08             	call   *0x8(%ebp)
  800756:	eb 0d                	jmp    800765 <vprintfmt+0x227>
        else
          putch(ch, putdat);
  800758:	8b 55 0c             	mov    0xc(%ebp),%edx
  80075b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80075f:	89 04 24             	mov    %eax,(%esp)
  800762:	ff 55 08             	call   *0x8(%ebp)
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800765:	83 ef 01             	sub    $0x1,%edi
  800768:	eb 1a                	jmp    800784 <vprintfmt+0x246>
  80076a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80076d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800770:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800773:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800776:	eb 0c                	jmp    800784 <vprintfmt+0x246>
  800778:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80077b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80077e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800781:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800784:	83 c6 01             	add    $0x1,%esi
  800787:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80078b:	0f be c2             	movsbl %dl,%eax
  80078e:	85 c0                	test   %eax,%eax
  800790:	74 27                	je     8007b9 <vprintfmt+0x27b>
  800792:	85 db                	test   %ebx,%ebx
  800794:	78 9e                	js     800734 <vprintfmt+0x1f6>
  800796:	83 eb 01             	sub    $0x1,%ebx
  800799:	79 99                	jns    800734 <vprintfmt+0x1f6>
  80079b:	89 f8                	mov    %edi,%eax
  80079d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8007a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a3:	89 c3                	mov    %eax,%ebx
  8007a5:	eb 1a                	jmp    8007c1 <vprintfmt+0x283>
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
        putch(' ', putdat);
  8007a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ab:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007b2:	ff d6                	call   *%esi
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
  8007b4:	83 eb 01             	sub    $0x1,%ebx
  8007b7:	eb 08                	jmp    8007c1 <vprintfmt+0x283>
  8007b9:	89 fb                	mov    %edi,%ebx
  8007bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007be:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8007c1:	85 db                	test   %ebx,%ebx
  8007c3:	7f e2                	jg     8007a7 <vprintfmt+0x269>
  8007c5:	89 75 08             	mov    %esi,0x8(%ebp)
  8007c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8007cb:	e9 93 fd ff ff       	jmp    800563 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  if (lflag >= 2)
  8007d0:	83 fa 01             	cmp    $0x1,%edx
  8007d3:	7e 16                	jle    8007eb <vprintfmt+0x2ad>
    return va_arg(*ap, long long);
  8007d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d8:	8d 50 08             	lea    0x8(%eax),%edx
  8007db:	89 55 14             	mov    %edx,0x14(%ebp)
  8007de:	8b 50 04             	mov    0x4(%eax),%edx
  8007e1:	8b 00                	mov    (%eax),%eax
  8007e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007e6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007e9:	eb 32                	jmp    80081d <vprintfmt+0x2df>
  else if (lflag)
  8007eb:	85 d2                	test   %edx,%edx
  8007ed:	74 18                	je     800807 <vprintfmt+0x2c9>
    return va_arg(*ap, long);
  8007ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f2:	8d 50 04             	lea    0x4(%eax),%edx
  8007f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f8:	8b 30                	mov    (%eax),%esi
  8007fa:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8007fd:	89 f0                	mov    %esi,%eax
  8007ff:	c1 f8 1f             	sar    $0x1f,%eax
  800802:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800805:	eb 16                	jmp    80081d <vprintfmt+0x2df>
  else
    return va_arg(*ap, int);
  800807:	8b 45 14             	mov    0x14(%ebp),%eax
  80080a:	8d 50 04             	lea    0x4(%eax),%edx
  80080d:	89 55 14             	mov    %edx,0x14(%ebp)
  800810:	8b 30                	mov    (%eax),%esi
  800812:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800815:	89 f0                	mov    %esi,%eax
  800817:	c1 f8 1f             	sar    $0x1f,%eax
  80081a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        putch(' ', putdat);
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
  80081d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800820:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      if ((long long)num < 0) {
        putch('-', putdat);
        num = -(long long)num;
      }
      base = 10;
  800823:	b9 0a 00 00 00       	mov    $0xa,%ecx
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
      if ((long long)num < 0) {
  800828:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80082c:	0f 89 80 00 00 00    	jns    8008b2 <vprintfmt+0x374>
        putch('-', putdat);
  800832:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800836:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80083d:	ff 55 08             	call   *0x8(%ebp)
        num = -(long long)num;
  800840:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800843:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800846:	f7 d8                	neg    %eax
  800848:	83 d2 00             	adc    $0x0,%edx
  80084b:	f7 da                	neg    %edx
      }
      base = 10;
  80084d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800852:	eb 5e                	jmp    8008b2 <vprintfmt+0x374>
      goto number;

    // unsigned decimal
    case 'u':
      num = getuint(&ap, lflag);
  800854:	8d 45 14             	lea    0x14(%ebp),%eax
  800857:	e8 63 fc ff ff       	call   8004bf <getuint>
      base = 10;
  80085c:	b9 0a 00 00 00       	mov    $0xa,%ecx
      goto number;
  800861:	eb 4f                	jmp    8008b2 <vprintfmt+0x374>

    // (unsigned) octal
    case 'o':
      num = getuint(&ap, lflag);
  800863:	8d 45 14             	lea    0x14(%ebp),%eax
  800866:	e8 54 fc ff ff       	call   8004bf <getuint>
      base = 8;
  80086b:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800870:	eb 40                	jmp    8008b2 <vprintfmt+0x374>

    // pointer
    case 'p':
      putch('0', putdat);
  800872:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800876:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80087d:	ff 55 08             	call   *0x8(%ebp)
      putch('x', putdat);
  800880:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800884:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80088b:	ff 55 08             	call   *0x8(%ebp)
      num = (unsigned long long)
            (uintptr_t)va_arg(ap, void *);
  80088e:	8b 45 14             	mov    0x14(%ebp),%eax
  800891:	8d 50 04             	lea    0x4(%eax),%edx
  800894:	89 55 14             	mov    %edx,0x14(%ebp)

    // pointer
    case 'p':
      putch('0', putdat);
      putch('x', putdat);
      num = (unsigned long long)
  800897:	8b 00                	mov    (%eax),%eax
  800899:	ba 00 00 00 00       	mov    $0x0,%edx
            (uintptr_t)va_arg(ap, void *);
      base = 16;
  80089e:	b9 10 00 00 00       	mov    $0x10,%ecx
      goto number;
  8008a3:	eb 0d                	jmp    8008b2 <vprintfmt+0x374>

    // (unsigned) hexadecimal
    case 'x':
      num = getuint(&ap, lflag);
  8008a5:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a8:	e8 12 fc ff ff       	call   8004bf <getuint>
      base = 16;
  8008ad:	b9 10 00 00 00       	mov    $0x10,%ecx
number:
      printnum(putch, putdat, num, base, width, padc);
  8008b2:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8008b6:	89 74 24 10          	mov    %esi,0x10(%esp)
  8008ba:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8008bd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8008c1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008c5:	89 04 24             	mov    %eax,(%esp)
  8008c8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008cc:	89 fa                	mov    %edi,%edx
  8008ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d1:	e8 fa fa ff ff       	call   8003d0 <printnum>
      break;
  8008d6:	e9 88 fc ff ff       	jmp    800563 <vprintfmt+0x25>

    // escaped '%' character
    case '%':
      putch(ch, putdat);
  8008db:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008df:	89 04 24             	mov    %eax,(%esp)
  8008e2:	ff 55 08             	call   *0x8(%ebp)
      break;
  8008e5:	e9 79 fc ff ff       	jmp    800563 <vprintfmt+0x25>

    // unrecognized escape sequence - just print it literally
    default:
      putch('%', putdat);
  8008ea:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008ee:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008f5:	ff 55 08             	call   *0x8(%ebp)
      for (fmt--; fmt[-1] != '%'; fmt--)
  8008f8:	89 f3                	mov    %esi,%ebx
  8008fa:	eb 03                	jmp    8008ff <vprintfmt+0x3c1>
  8008fc:	83 eb 01             	sub    $0x1,%ebx
  8008ff:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800903:	75 f7                	jne    8008fc <vprintfmt+0x3be>
  800905:	e9 59 fc ff ff       	jmp    800563 <vprintfmt+0x25>
        /* do nothing */;
      break;
    }
  }
}
  80090a:	83 c4 3c             	add    $0x3c,%esp
  80090d:	5b                   	pop    %ebx
  80090e:	5e                   	pop    %esi
  80090f:	5f                   	pop    %edi
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <vsnprintf>:
    *b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	83 ec 28             	sub    $0x28,%esp
  800918:	8b 45 08             	mov    0x8(%ebp),%eax
  80091b:	8b 55 0c             	mov    0xc(%ebp),%edx
  struct sprintbuf b = { buf, buf+n-1, 0 };
  80091e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800921:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800925:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800928:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  if (buf == NULL || n < 1)
  80092f:	85 c0                	test   %eax,%eax
  800931:	74 30                	je     800963 <vsnprintf+0x51>
  800933:	85 d2                	test   %edx,%edx
  800935:	7e 2c                	jle    800963 <vsnprintf+0x51>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void*)sprintputch, &b, fmt, ap);
  800937:	8b 45 14             	mov    0x14(%ebp),%eax
  80093a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80093e:	8b 45 10             	mov    0x10(%ebp),%eax
  800941:	89 44 24 08          	mov    %eax,0x8(%esp)
  800945:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800948:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094c:	c7 04 24 f9 04 80 00 	movl   $0x8004f9,(%esp)
  800953:	e8 e6 fb ff ff       	call   80053e <vprintfmt>

  // null terminate the buffer
  *b.buf = '\0';
  800958:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80095b:	c6 00 00             	movb   $0x0,(%eax)

  return b.cnt;
  80095e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800961:	eb 05                	jmp    800968 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  struct sprintbuf b = { buf, buf+n-1, 0 };

  if (buf == NULL || n < 1)
    return -E_INVAL;
  800963:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

  // null terminate the buffer
  *b.buf = '\0';

  return b.cnt;
}
  800968:	c9                   	leave  
  800969:	c3                   	ret    

0080096a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800970:	8d 45 14             	lea    0x14(%ebp),%eax
  rc = vsnprintf(buf, n, fmt, ap);
  800973:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800977:	8b 45 10             	mov    0x10(%ebp),%eax
  80097a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80097e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800981:	89 44 24 04          	mov    %eax,0x4(%esp)
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	89 04 24             	mov    %eax,(%esp)
  80098b:	e8 82 ff ff ff       	call   800912 <vsnprintf>
  va_end(ap);

  return rc;
}
  800990:	c9                   	leave  
  800991:	c3                   	ret    
  800992:	66 90                	xchg   %ax,%ax
  800994:	66 90                	xchg   %ax,%ax
  800996:	66 90                	xchg   %ax,%ax
  800998:	66 90                	xchg   %ax,%ax
  80099a:	66 90                	xchg   %ax,%ax
  80099c:	66 90                	xchg   %ax,%ax
  80099e:	66 90                	xchg   %ax,%ax

008009a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for (n = 0; *s != '\0'; s++)
  8009a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ab:	eb 03                	jmp    8009b0 <strlen+0x10>
    n++;
  8009ad:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
  int n;

  for (n = 0; *s != '\0'; s++)
  8009b0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009b4:	75 f7                	jne    8009ad <strlen+0xd>
    n++;
  return n;
}
  8009b6:	5d                   	pop    %ebp
  8009b7:	c3                   	ret    

008009b8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009be:	8b 55 0c             	mov    0xc(%ebp),%edx
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c6:	eb 03                	jmp    8009cb <strnlen+0x13>
    n++;
  8009c8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009cb:	39 d0                	cmp    %edx,%eax
  8009cd:	74 06                	je     8009d5 <strnlen+0x1d>
  8009cf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009d3:	75 f3                	jne    8009c8 <strnlen+0x10>
    n++;
  return n;
}
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	53                   	push   %ebx
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  8009e1:	89 c2                	mov    %eax,%edx
  8009e3:	83 c2 01             	add    $0x1,%edx
  8009e6:	83 c1 01             	add    $0x1,%ecx
  8009e9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009ed:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009f0:	84 db                	test   %bl,%bl
  8009f2:	75 ef                	jne    8009e3 <strcpy+0xc>
    /* do nothing */;
  return ret;
}
  8009f4:	5b                   	pop    %ebx
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	53                   	push   %ebx
  8009fb:	83 ec 08             	sub    $0x8,%esp
  8009fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int len = strlen(dst);
  800a01:	89 1c 24             	mov    %ebx,(%esp)
  800a04:	e8 97 ff ff ff       	call   8009a0 <strlen>

  strcpy(dst + len, src);
  800a09:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a10:	01 d8                	add    %ebx,%eax
  800a12:	89 04 24             	mov    %eax,(%esp)
  800a15:	e8 bd ff ff ff       	call   8009d7 <strcpy>
  return dst;
}
  800a1a:	89 d8                	mov    %ebx,%eax
  800a1c:	83 c4 08             	add    $0x8,%esp
  800a1f:	5b                   	pop    %ebx
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	56                   	push   %esi
  800a26:	53                   	push   %ebx
  800a27:	8b 75 08             	mov    0x8(%ebp),%esi
  800a2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2d:	89 f3                	mov    %esi,%ebx
  800a2f:	03 5d 10             	add    0x10(%ebp),%ebx
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800a32:	89 f2                	mov    %esi,%edx
  800a34:	eb 0f                	jmp    800a45 <strncpy+0x23>
    *dst++ = *src;
  800a36:	83 c2 01             	add    $0x1,%edx
  800a39:	0f b6 01             	movzbl (%ecx),%eax
  800a3c:	88 42 ff             	mov    %al,-0x1(%edx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800a3f:	80 39 01             	cmpb   $0x1,(%ecx)
  800a42:	83 d9 ff             	sbb    $0xffffffff,%ecx
{
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800a45:	39 da                	cmp    %ebx,%edx
  800a47:	75 ed                	jne    800a36 <strncpy+0x14>
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  }
  return ret;
}
  800a49:	89 f0                	mov    %esi,%eax
  800a4b:	5b                   	pop    %ebx
  800a4c:	5e                   	pop    %esi
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    

00800a4f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	56                   	push   %esi
  800a53:	53                   	push   %ebx
  800a54:	8b 75 08             	mov    0x8(%ebp),%esi
  800a57:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a5d:	89 f0                	mov    %esi,%eax
  800a5f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800a63:	85 c9                	test   %ecx,%ecx
  800a65:	75 0b                	jne    800a72 <strlcpy+0x23>
  800a67:	eb 1d                	jmp    800a86 <strlcpy+0x37>
    while (--size > 0 && *src != '\0')
      *dst++ = *src++;
  800a69:	83 c0 01             	add    $0x1,%eax
  800a6c:	83 c2 01             	add    $0x1,%edx
  800a6f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
    while (--size > 0 && *src != '\0')
  800a72:	39 d8                	cmp    %ebx,%eax
  800a74:	74 0b                	je     800a81 <strlcpy+0x32>
  800a76:	0f b6 0a             	movzbl (%edx),%ecx
  800a79:	84 c9                	test   %cl,%cl
  800a7b:	75 ec                	jne    800a69 <strlcpy+0x1a>
  800a7d:	89 c2                	mov    %eax,%edx
  800a7f:	eb 02                	jmp    800a83 <strlcpy+0x34>
  800a81:	89 c2                	mov    %eax,%edx
      *dst++ = *src++;
    *dst = '\0';
  800a83:	c6 02 00             	movb   $0x0,(%edx)
  }
  return dst - dst_in;
  800a86:	29 f0                	sub    %esi,%eax
}
  800a88:	5b                   	pop    %ebx
  800a89:	5e                   	pop    %esi
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a92:	8b 55 0c             	mov    0xc(%ebp),%edx
  while (*p && *p == *q)
  800a95:	eb 06                	jmp    800a9d <strcmp+0x11>
    p++, q++;
  800a97:	83 c1 01             	add    $0x1,%ecx
  800a9a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
  while (*p && *p == *q)
  800a9d:	0f b6 01             	movzbl (%ecx),%eax
  800aa0:	84 c0                	test   %al,%al
  800aa2:	74 04                	je     800aa8 <strcmp+0x1c>
  800aa4:	3a 02                	cmp    (%edx),%al
  800aa6:	74 ef                	je     800a97 <strcmp+0xb>
    p++, q++;
  return (int)((unsigned char)*p - (unsigned char)*q);
  800aa8:	0f b6 c0             	movzbl %al,%eax
  800aab:	0f b6 12             	movzbl (%edx),%edx
  800aae:	29 d0                	sub    %edx,%eax
}
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	53                   	push   %ebx
  800ab6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800abc:	89 c3                	mov    %eax,%ebx
  800abe:	03 5d 10             	add    0x10(%ebp),%ebx
  while (n > 0 && *p && *p == *q)
  800ac1:	eb 06                	jmp    800ac9 <strncmp+0x17>
    n--, p++, q++;
  800ac3:	83 c0 01             	add    $0x1,%eax
  800ac6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
  800ac9:	39 d8                	cmp    %ebx,%eax
  800acb:	74 15                	je     800ae2 <strncmp+0x30>
  800acd:	0f b6 08             	movzbl (%eax),%ecx
  800ad0:	84 c9                	test   %cl,%cl
  800ad2:	74 04                	je     800ad8 <strncmp+0x26>
  800ad4:	3a 0a                	cmp    (%edx),%cl
  800ad6:	74 eb                	je     800ac3 <strncmp+0x11>
    n--, p++, q++;
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800ad8:	0f b6 00             	movzbl (%eax),%eax
  800adb:	0f b6 12             	movzbl (%edx),%edx
  800ade:	29 d0                	sub    %edx,%eax
  800ae0:	eb 05                	jmp    800ae7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
    n--, p++, q++;
  if (n == 0)
    return 0;
  800ae2:	b8 00 00 00 00       	mov    $0x0,%eax
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
}
  800ae7:	5b                   	pop    %ebx
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	8b 45 08             	mov    0x8(%ebp),%eax
  800af0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
  800af4:	eb 07                	jmp    800afd <strchr+0x13>
    if (*s == c)
  800af6:	38 ca                	cmp    %cl,%dl
  800af8:	74 0f                	je     800b09 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  for (; *s; s++)
  800afa:	83 c0 01             	add    $0x1,%eax
  800afd:	0f b6 10             	movzbl (%eax),%edx
  800b00:	84 d2                	test   %dl,%dl
  800b02:	75 f2                	jne    800af6 <strchr+0xc>
    if (*s == c)
      return (char*)s;
  return 0;
  800b04:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
  800b15:	eb 07                	jmp    800b1e <strfind+0x13>
    if (*s == c)
  800b17:	38 ca                	cmp    %cl,%dl
  800b19:	74 0a                	je     800b25 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  for (; *s; s++)
  800b1b:	83 c0 01             	add    $0x1,%eax
  800b1e:	0f b6 10             	movzbl (%eax),%edx
  800b21:	84 d2                	test   %dl,%dl
  800b23:	75 f2                	jne    800b17 <strfind+0xc>
    if (*s == c)
      break;
  return (char*)s;
}
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	57                   	push   %edi
  800b2b:	56                   	push   %esi
  800b2c:	53                   	push   %ebx
  800b2d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b30:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *p;

  if (n == 0)
  800b33:	85 c9                	test   %ecx,%ecx
  800b35:	74 36                	je     800b6d <memset+0x46>
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
  800b37:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b3d:	75 28                	jne    800b67 <memset+0x40>
  800b3f:	f6 c1 03             	test   $0x3,%cl
  800b42:	75 23                	jne    800b67 <memset+0x40>
    c &= 0xFF;
  800b44:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
    c = (c<<24)|(c<<16)|(c<<8)|c;
  800b48:	89 d3                	mov    %edx,%ebx
  800b4a:	c1 e3 08             	shl    $0x8,%ebx
  800b4d:	89 d6                	mov    %edx,%esi
  800b4f:	c1 e6 18             	shl    $0x18,%esi
  800b52:	89 d0                	mov    %edx,%eax
  800b54:	c1 e0 10             	shl    $0x10,%eax
  800b57:	09 f0                	or     %esi,%eax
  800b59:	09 c2                	or     %eax,%edx
  800b5b:	89 d0                	mov    %edx,%eax
  800b5d:	09 d8                	or     %ebx,%eax
    asm volatile ("cld; rep stosl\n"
                  :: "D" (v), "a" (c), "c" (n/4)
  800b5f:	c1 e9 02             	shr    $0x2,%ecx
  if (n == 0)
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
    c &= 0xFF;
    c = (c<<24)|(c<<16)|(c<<8)|c;
    asm volatile ("cld; rep stosl\n"
  800b62:	fc                   	cld    
  800b63:	f3 ab                	rep stos %eax,%es:(%edi)
  800b65:	eb 06                	jmp    800b6d <memset+0x46>
                  :: "D" (v), "a" (c), "c" (n/4)
                  : "cc", "memory");
  } else
    asm volatile ("cld; rep stosb\n"
  800b67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6a:	fc                   	cld    
  800b6b:	f3 aa                	rep stos %al,%es:(%edi)
                  :: "D" (v), "a" (c), "c" (n)
                  : "cc", "memory");
  return v;
}
  800b6d:	89 f8                	mov    %edi,%eax
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5f                   	pop    %edi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	57                   	push   %edi
  800b78:	56                   	push   %esi
  800b79:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800b82:	39 c6                	cmp    %eax,%esi
  800b84:	73 35                	jae    800bbb <memmove+0x47>
  800b86:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b89:	39 d0                	cmp    %edx,%eax
  800b8b:	73 2e                	jae    800bbb <memmove+0x47>
    s += n;
    d += n;
  800b8d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b90:	89 d6                	mov    %edx,%esi
  800b92:	09 fe                	or     %edi,%esi
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b94:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b9a:	75 13                	jne    800baf <memmove+0x3b>
  800b9c:	f6 c1 03             	test   $0x3,%cl
  800b9f:	75 0e                	jne    800baf <memmove+0x3b>
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ba1:	83 ef 04             	sub    $0x4,%edi
  800ba4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ba7:	c1 e9 02             	shr    $0x2,%ecx
  d = dst;
  if (s < d && s + n > d) {
    s += n;
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
  800baa:	fd                   	std    
  800bab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bad:	eb 09                	jmp    800bb8 <memmove+0x44>
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800baf:	83 ef 01             	sub    $0x1,%edi
  800bb2:	8d 72 ff             	lea    -0x1(%edx),%esi
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
  800bb5:	fd                   	std    
  800bb6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  800bb8:	fc                   	cld    
  800bb9:	eb 1d                	jmp    800bd8 <memmove+0x64>
  800bbb:	89 f2                	mov    %esi,%edx
  800bbd:	09 c2                	or     %eax,%edx
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bbf:	f6 c2 03             	test   $0x3,%dl
  800bc2:	75 0f                	jne    800bd3 <memmove+0x5f>
  800bc4:	f6 c1 03             	test   $0x3,%cl
  800bc7:	75 0a                	jne    800bd3 <memmove+0x5f>
      asm volatile ("cld; rep movsl\n"
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bc9:	c1 e9 02             	shr    $0x2,%ecx
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("cld; rep movsl\n"
  800bcc:	89 c7                	mov    %eax,%edi
  800bce:	fc                   	cld    
  800bcf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bd1:	eb 05                	jmp    800bd8 <memmove+0x64>
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("cld; rep movsb\n"
  800bd3:	89 c7                	mov    %eax,%edi
  800bd5:	fc                   	cld    
  800bd6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d), "S" (s), "c" (n) : "cc", "memory");
  }
  return dst;
}
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
  800be2:	8b 45 10             	mov    0x10(%ebp),%eax
  800be5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800be9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bec:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf3:	89 04 24             	mov    %eax,(%esp)
  800bf6:	e8 79 ff ff ff       	call   800b74 <memmove>
}
  800bfb:	c9                   	leave  
  800bfc:	c3                   	ret    

00800bfd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
  800c02:	8b 55 08             	mov    0x8(%ebp),%edx
  800c05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c08:	89 d6                	mov    %edx,%esi
  800c0a:	03 75 10             	add    0x10(%ebp),%esi
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
  800c0d:	eb 1a                	jmp    800c29 <memcmp+0x2c>
    if (*s1 != *s2)
  800c0f:	0f b6 02             	movzbl (%edx),%eax
  800c12:	0f b6 19             	movzbl (%ecx),%ebx
  800c15:	38 d8                	cmp    %bl,%al
  800c17:	74 0a                	je     800c23 <memcmp+0x26>
      return (int)*s1 - (int)*s2;
  800c19:	0f b6 c0             	movzbl %al,%eax
  800c1c:	0f b6 db             	movzbl %bl,%ebx
  800c1f:	29 d8                	sub    %ebx,%eax
  800c21:	eb 0f                	jmp    800c32 <memcmp+0x35>
    s1++, s2++;
  800c23:	83 c2 01             	add    $0x1,%edx
  800c26:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
  800c29:	39 f2                	cmp    %esi,%edx
  800c2b:	75 e2                	jne    800c0f <memcmp+0x12>
    if (*s1 != *s2)
      return (int)*s1 - (int)*s2;
    s1++, s2++;
  }

  return 0;
  800c2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c32:	5b                   	pop    %ebx
  800c33:	5e                   	pop    %esi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  const void *ends = (const char*)s + n;
  800c3f:	89 c2                	mov    %eax,%edx
  800c41:	03 55 10             	add    0x10(%ebp),%edx

  for (; s < ends; s++)
  800c44:	eb 07                	jmp    800c4d <memfind+0x17>
    if (*(const unsigned char*)s == (unsigned char)c)
  800c46:	38 08                	cmp    %cl,(%eax)
  800c48:	74 07                	je     800c51 <memfind+0x1b>
void *
memfind(const void *s, int c, size_t n)
{
  const void *ends = (const char*)s + n;

  for (; s < ends; s++)
  800c4a:	83 c0 01             	add    $0x1,%eax
  800c4d:	39 d0                	cmp    %edx,%eax
  800c4f:	72 f5                	jb     800c46 <memfind+0x10>
    if (*(const unsigned char*)s == (unsigned char)c)
      break;
  return (void*)s;
}
  800c51:	5d                   	pop    %ebp
  800c52:	c3                   	ret    

00800c53 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	57                   	push   %edi
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
  800c59:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5c:	8b 45 10             	mov    0x10(%ebp),%eax
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800c5f:	eb 03                	jmp    800c64 <strtol+0x11>
    s++;
  800c61:	83 c2 01             	add    $0x1,%edx
{
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800c64:	0f b6 0a             	movzbl (%edx),%ecx
  800c67:	80 f9 09             	cmp    $0x9,%cl
  800c6a:	74 f5                	je     800c61 <strtol+0xe>
  800c6c:	80 f9 20             	cmp    $0x20,%cl
  800c6f:	74 f0                	je     800c61 <strtol+0xe>
    s++;

  // plus/minus sign
  if (*s == '+')
  800c71:	80 f9 2b             	cmp    $0x2b,%cl
  800c74:	75 0a                	jne    800c80 <strtol+0x2d>
    s++;
  800c76:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
  int neg = 0;
  800c79:	bf 00 00 00 00       	mov    $0x0,%edi
  800c7e:	eb 11                	jmp    800c91 <strtol+0x3e>
  800c80:	bf 00 00 00 00       	mov    $0x0,%edi
    s++;

  // plus/minus sign
  if (*s == '+')
    s++;
  else if (*s == '-')
  800c85:	80 f9 2d             	cmp    $0x2d,%cl
  800c88:	75 07                	jne    800c91 <strtol+0x3e>
    s++, neg = 1;
  800c8a:	8d 52 01             	lea    0x1(%edx),%edx
  800c8d:	66 bf 01 00          	mov    $0x1,%di

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c91:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800c96:	75 15                	jne    800cad <strtol+0x5a>
  800c98:	80 3a 30             	cmpb   $0x30,(%edx)
  800c9b:	75 10                	jne    800cad <strtol+0x5a>
  800c9d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ca1:	75 0a                	jne    800cad <strtol+0x5a>
    s += 2, base = 16;
  800ca3:	83 c2 02             	add    $0x2,%edx
  800ca6:	b8 10 00 00 00       	mov    $0x10,%eax
  800cab:	eb 10                	jmp    800cbd <strtol+0x6a>
  else if (base == 0 && s[0] == '0')
  800cad:	85 c0                	test   %eax,%eax
  800caf:	75 0c                	jne    800cbd <strtol+0x6a>
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800cb1:	b0 0a                	mov    $0xa,%al
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
  800cb3:	80 3a 30             	cmpb   $0x30,(%edx)
  800cb6:	75 05                	jne    800cbd <strtol+0x6a>
    s++, base = 8;
  800cb8:	83 c2 01             	add    $0x1,%edx
  800cbb:	b0 08                	mov    $0x8,%al
  else if (base == 0)
    base = 10;
  800cbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc2:	89 45 10             	mov    %eax,0x10(%ebp)

  // digits
  while (1) {
    int dig;

    if (*s >= '0' && *s <= '9')
  800cc5:	0f b6 0a             	movzbl (%edx),%ecx
  800cc8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800ccb:	89 f0                	mov    %esi,%eax
  800ccd:	3c 09                	cmp    $0x9,%al
  800ccf:	77 08                	ja     800cd9 <strtol+0x86>
      dig = *s - '0';
  800cd1:	0f be c9             	movsbl %cl,%ecx
  800cd4:	83 e9 30             	sub    $0x30,%ecx
  800cd7:	eb 20                	jmp    800cf9 <strtol+0xa6>
    else if (*s >= 'a' && *s <= 'z')
  800cd9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800cdc:	89 f0                	mov    %esi,%eax
  800cde:	3c 19                	cmp    $0x19,%al
  800ce0:	77 08                	ja     800cea <strtol+0x97>
      dig = *s - 'a' + 10;
  800ce2:	0f be c9             	movsbl %cl,%ecx
  800ce5:	83 e9 57             	sub    $0x57,%ecx
  800ce8:	eb 0f                	jmp    800cf9 <strtol+0xa6>
    else if (*s >= 'A' && *s <= 'Z')
  800cea:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800ced:	89 f0                	mov    %esi,%eax
  800cef:	3c 19                	cmp    $0x19,%al
  800cf1:	77 16                	ja     800d09 <strtol+0xb6>
      dig = *s - 'A' + 10;
  800cf3:	0f be c9             	movsbl %cl,%ecx
  800cf6:	83 e9 37             	sub    $0x37,%ecx
    else
      break;
    if (dig >= base)
  800cf9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800cfc:	7d 0f                	jge    800d0d <strtol+0xba>
      break;
    s++, val = (val * base) + dig;
  800cfe:	83 c2 01             	add    $0x1,%edx
  800d01:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800d05:	01 cb                	add    %ecx,%ebx
    // we don't properly detect overflow!
  }
  800d07:	eb bc                	jmp    800cc5 <strtol+0x72>
  800d09:	89 d8                	mov    %ebx,%eax
  800d0b:	eb 02                	jmp    800d0f <strtol+0xbc>
  800d0d:	89 d8                	mov    %ebx,%eax

  if (endptr)
  800d0f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d13:	74 05                	je     800d1a <strtol+0xc7>
    *endptr = (char*)s;
  800d15:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d18:	89 16                	mov    %edx,(%esi)
  return neg ? -val : val;
  800d1a:	f7 d8                	neg    %eax
  800d1c:	85 ff                	test   %edi,%edi
  800d1e:	0f 44 c3             	cmove  %ebx,%eax
}
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <sys_cputs>:
  return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800d2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d34:	8b 55 08             	mov    0x8(%ebp),%edx
  800d37:	89 c3                	mov    %eax,%ebx
  800d39:	89 c7                	mov    %eax,%edi
  800d3b:	89 c6                	mov    %eax,%esi
  800d3d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
  syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d3f:	5b                   	pop    %ebx
  800d40:	5e                   	pop    %esi
  800d41:	5f                   	pop    %edi
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    

00800d44 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	57                   	push   %edi
  800d48:	56                   	push   %esi
  800d49:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800d4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d4f:	b8 01 00 00 00       	mov    $0x1,%eax
  800d54:	89 d1                	mov    %edx,%ecx
  800d56:	89 d3                	mov    %edx,%ebx
  800d58:	89 d7                	mov    %edx,%edi
  800d5a:	89 d6                	mov    %edx,%esi
  800d5c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	57                   	push   %edi
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
  800d69:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800d6c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d71:	b8 03 00 00 00       	mov    $0x3,%eax
  800d76:	8b 55 08             	mov    0x8(%ebp),%edx
  800d79:	89 cb                	mov    %ecx,%ebx
  800d7b:	89 cf                	mov    %ecx,%edi
  800d7d:	89 ce                	mov    %ecx,%esi
  800d7f:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800d81:	85 c0                	test   %eax,%eax
  800d83:	7e 28                	jle    800dad <sys_env_destroy+0x4a>
    panic("syscall %d returned %d (> 0)", num, ret);
  800d85:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d89:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d90:	00 
  800d91:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  800d98:	00 
  800d99:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da0:	00 
  800da1:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800da8:	e8 02 f5 ff ff       	call   8002af <_panic>

int
sys_env_destroy(envid_t envid)
{
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dad:	83 c4 2c             	add    $0x2c,%esp
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    

00800db5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	57                   	push   %edi
  800db9:	56                   	push   %esi
  800dba:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800dbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc0:	b8 02 00 00 00       	mov    $0x2,%eax
  800dc5:	89 d1                	mov    %edx,%ecx
  800dc7:	89 d3                	mov    %edx,%ebx
  800dc9:	89 d7                	mov    %edx,%edi
  800dcb:	89 d6                	mov    %edx,%esi
  800dcd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800dcf:	5b                   	pop    %ebx
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <sys_yield>:

void
sys_yield(void)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	57                   	push   %edi
  800dd8:	56                   	push   %esi
  800dd9:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800dda:	ba 00 00 00 00       	mov    $0x0,%edx
  800ddf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800de4:	89 d1                	mov    %edx,%ecx
  800de6:	89 d3                	mov    %edx,%ebx
  800de8:	89 d7                	mov    %edx,%edi
  800dea:	89 d6                	mov    %edx,%esi
  800dec:	cd 30                	int    $0x30

void
sys_yield(void)
{
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dee:	5b                   	pop    %ebx
  800def:	5e                   	pop    %esi
  800df0:	5f                   	pop    %edi
  800df1:	5d                   	pop    %ebp
  800df2:	c3                   	ret    

00800df3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	57                   	push   %edi
  800df7:	56                   	push   %esi
  800df8:	53                   	push   %ebx
  800df9:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800dfc:	be 00 00 00 00       	mov    $0x0,%esi
  800e01:	b8 04 00 00 00       	mov    $0x4,%eax
  800e06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e09:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e0f:	89 f7                	mov    %esi,%edi
  800e11:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800e13:	85 c0                	test   %eax,%eax
  800e15:	7e 28                	jle    800e3f <sys_page_alloc+0x4c>
    panic("syscall %d returned %d (> 0)", num, ret);
  800e17:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e22:	00 
  800e23:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  800e2a:	00 
  800e2b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e32:	00 
  800e33:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800e3a:	e8 70 f4 ff ff       	call   8002af <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  return syscall(SYS_page_alloc, 1, envid, (uint32_t)va, perm, 0, 0);
}
  800e3f:	83 c4 2c             	add    $0x2c,%esp
  800e42:	5b                   	pop    %ebx
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	57                   	push   %edi
  800e4b:	56                   	push   %esi
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800e50:	b8 05 00 00 00       	mov    $0x5,%eax
  800e55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e58:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e5e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e61:	8b 75 18             	mov    0x18(%ebp),%esi
  800e64:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800e66:	85 c0                	test   %eax,%eax
  800e68:	7e 28                	jle    800e92 <sys_page_map+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800e6a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e6e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e75:	00 
  800e76:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  800e7d:	00 
  800e7e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e85:	00 
  800e86:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800e8d:	e8 1d f4 ff ff       	call   8002af <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  return syscall(SYS_page_map, 1, srcenv, (uint32_t)srcva, dstenv, (uint32_t)dstva, perm);
}
  800e92:	83 c4 2c             	add    $0x2c,%esp
  800e95:	5b                   	pop    %ebx
  800e96:	5e                   	pop    %esi
  800e97:	5f                   	pop    %edi
  800e98:	5d                   	pop    %ebp
  800e99:	c3                   	ret    

00800e9a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	57                   	push   %edi
  800e9e:	56                   	push   %esi
  800e9f:	53                   	push   %ebx
  800ea0:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800ea3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea8:	b8 06 00 00 00       	mov    $0x6,%eax
  800ead:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb3:	89 df                	mov    %ebx,%edi
  800eb5:	89 de                	mov    %ebx,%esi
  800eb7:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800eb9:	85 c0                	test   %eax,%eax
  800ebb:	7e 28                	jle    800ee5 <sys_page_unmap+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800ebd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ec8:	00 
  800ec9:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  800ed0:	00 
  800ed1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed8:	00 
  800ed9:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800ee0:	e8 ca f3 ff ff       	call   8002af <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
  return syscall(SYS_page_unmap, 1, envid, (uint32_t)va, 0, 0, 0);
}
  800ee5:	83 c4 2c             	add    $0x2c,%esp
  800ee8:	5b                   	pop    %ebx
  800ee9:	5e                   	pop    %esi
  800eea:	5f                   	pop    %edi
  800eeb:	5d                   	pop    %ebp
  800eec:	c3                   	ret    

00800eed <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800eed:	55                   	push   %ebp
  800eee:	89 e5                	mov    %esp,%ebp
  800ef0:	57                   	push   %edi
  800ef1:	56                   	push   %esi
  800ef2:	53                   	push   %ebx
  800ef3:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800ef6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efb:	b8 08 00 00 00       	mov    $0x8,%eax
  800f00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f03:	8b 55 08             	mov    0x8(%ebp),%edx
  800f06:	89 df                	mov    %ebx,%edi
  800f08:	89 de                	mov    %ebx,%esi
  800f0a:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800f0c:	85 c0                	test   %eax,%eax
  800f0e:	7e 28                	jle    800f38 <sys_env_set_status+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800f10:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f14:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f1b:	00 
  800f1c:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  800f23:	00 
  800f24:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f2b:	00 
  800f2c:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800f33:	e8 77 f3 ff ff       	call   8002af <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f38:	83 c4 2c             	add    $0x2c,%esp
  800f3b:	5b                   	pop    %ebx
  800f3c:	5e                   	pop    %esi
  800f3d:	5f                   	pop    %edi
  800f3e:	5d                   	pop    %ebp
  800f3f:	c3                   	ret    

00800f40 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	57                   	push   %edi
  800f44:	56                   	push   %esi
  800f45:	53                   	push   %ebx
  800f46:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800f49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f4e:	b8 09 00 00 00       	mov    $0x9,%eax
  800f53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f56:	8b 55 08             	mov    0x8(%ebp),%edx
  800f59:	89 df                	mov    %ebx,%edi
  800f5b:	89 de                	mov    %ebx,%esi
  800f5d:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	7e 28                	jle    800f8b <sys_env_set_trapframe+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800f63:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f67:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f6e:	00 
  800f6f:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  800f76:	00 
  800f77:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f7e:	00 
  800f7f:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800f86:	e8 24 f3 ff ff       	call   8002af <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t)tf, 0, 0, 0);
}
  800f8b:	83 c4 2c             	add    $0x2c,%esp
  800f8e:	5b                   	pop    %ebx
  800f8f:	5e                   	pop    %esi
  800f90:	5f                   	pop    %edi
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    

00800f93 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	57                   	push   %edi
  800f97:	56                   	push   %esi
  800f98:	53                   	push   %ebx
  800f99:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800f9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fa1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fa6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fac:	89 df                	mov    %ebx,%edi
  800fae:	89 de                	mov    %ebx,%esi
  800fb0:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	7e 28                	jle    800fde <sys_env_set_pgfault_upcall+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800fb6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fba:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800fc1:	00 
  800fc2:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  800fc9:	00 
  800fca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fd1:	00 
  800fd2:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800fd9:	e8 d1 f2 ff ff       	call   8002af <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800fde:	83 c4 2c             	add    $0x2c,%esp
  800fe1:	5b                   	pop    %ebx
  800fe2:	5e                   	pop    %esi
  800fe3:	5f                   	pop    %edi
  800fe4:	5d                   	pop    %ebp
  800fe5:	c3                   	ret    

00800fe6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fe6:	55                   	push   %ebp
  800fe7:	89 e5                	mov    %esp,%ebp
  800fe9:	57                   	push   %edi
  800fea:	56                   	push   %esi
  800feb:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800fec:	be 00 00 00 00       	mov    $0x0,%esi
  800ff1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ff6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fff:	8b 7d 14             	mov    0x14(%ebp),%edi
  801002:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t)srcva, perm, 0);
}
  801004:	5b                   	pop    %ebx
  801005:	5e                   	pop    %esi
  801006:	5f                   	pop    %edi
  801007:	5d                   	pop    %ebp
  801008:	c3                   	ret    

00801009 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801009:	55                   	push   %ebp
  80100a:	89 e5                	mov    %esp,%ebp
  80100c:	57                   	push   %edi
  80100d:	56                   	push   %esi
  80100e:	53                   	push   %ebx
  80100f:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  801012:	b9 00 00 00 00       	mov    $0x0,%ecx
  801017:	b8 0d 00 00 00       	mov    $0xd,%eax
  80101c:	8b 55 08             	mov    0x8(%ebp),%edx
  80101f:	89 cb                	mov    %ecx,%ebx
  801021:	89 cf                	mov    %ecx,%edi
  801023:	89 ce                	mov    %ecx,%esi
  801025:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  801027:	85 c0                	test   %eax,%eax
  801029:	7e 28                	jle    801053 <sys_ipc_recv+0x4a>
    panic("syscall %d returned %d (> 0)", num, ret);
  80102b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80102f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801036:	00 
  801037:	c7 44 24 08 7f 25 80 	movl   $0x80257f,0x8(%esp)
  80103e:	00 
  80103f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801046:	00 
  801047:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  80104e:	e8 5c f2 ff ff       	call   8002af <_panic>

int
sys_ipc_recv(void *dstva)
{
  return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801053:	83 c4 2c             	add    $0x2c,%esp
  801056:	5b                   	pop    %ebx
  801057:	5e                   	pop    %esi
  801058:	5f                   	pop    %edi
  801059:	5d                   	pop    %ebp
  80105a:	c3                   	ret    
  80105b:	66 90                	xchg   %ax,%ax
  80105d:	66 90                	xchg   %ax,%ax
  80105f:	90                   	nop

00801060 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  801063:	8b 45 08             	mov    0x8(%ebp),%eax
  801066:	05 00 00 00 30       	add    $0x30000000,%eax
  80106b:	c1 e8 0c             	shr    $0xc,%eax
}
  80106e:	5d                   	pop    %ebp
  80106f:	c3                   	ret    

00801070 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  801073:	8b 45 08             	mov    0x8(%ebp),%eax
  801076:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
  return INDEX2DATA(fd2num(fd));
  80107b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801080:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801085:	5d                   	pop    %ebp
  801086:	c3                   	ret    

00801087 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
  80108a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80108d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
  int i;
  struct Fd *fd;

  for (i = 0; i < MAXFD; i++) {
    fd = INDEX2FD(i);
    if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801092:	89 c2                	mov    %eax,%edx
  801094:	c1 ea 16             	shr    $0x16,%edx
  801097:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80109e:	f6 c2 01             	test   $0x1,%dl
  8010a1:	74 11                	je     8010b4 <fd_alloc+0x2d>
  8010a3:	89 c2                	mov    %eax,%edx
  8010a5:	c1 ea 0c             	shr    $0xc,%edx
  8010a8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010af:	f6 c2 01             	test   $0x1,%dl
  8010b2:	75 09                	jne    8010bd <fd_alloc+0x36>
      *fd_store = fd;
  8010b4:	89 01                	mov    %eax,(%ecx)
      return 0;
  8010b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8010bb:	eb 17                	jmp    8010d4 <fd_alloc+0x4d>
  8010bd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
  int i;
  struct Fd *fd;

  for (i = 0; i < MAXFD; i++) {
  8010c2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010c7:	75 c9                	jne    801092 <fd_alloc+0xb>
    if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
      *fd_store = fd;
      return 0;
    }
  }
  *fd_store = 0;
  8010c9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
  return -E_MAX_OPEN;
  8010cf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010d4:	5d                   	pop    %ebp
  8010d5:	c3                   	ret    

008010d6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010d6:	55                   	push   %ebp
  8010d7:	89 e5                	mov    %esp,%ebp
  8010d9:	8b 45 08             	mov    0x8(%ebp),%eax
  struct Fd *fd;

  if (fdnum < 0 || fdnum >= MAXFD) {
  8010dc:	83 f8 1f             	cmp    $0x1f,%eax
  8010df:	77 36                	ja     801117 <fd_lookup+0x41>
    if (debug)
      cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  fd = INDEX2FD(fdnum);
  8010e1:	c1 e0 0c             	shl    $0xc,%eax
  8010e4:	2d 00 00 00 30       	sub    $0x30000000,%eax
  if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010e9:	89 c2                	mov    %eax,%edx
  8010eb:	c1 ea 16             	shr    $0x16,%edx
  8010ee:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010f5:	f6 c2 01             	test   $0x1,%dl
  8010f8:	74 24                	je     80111e <fd_lookup+0x48>
  8010fa:	89 c2                	mov    %eax,%edx
  8010fc:	c1 ea 0c             	shr    $0xc,%edx
  8010ff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801106:	f6 c2 01             	test   $0x1,%dl
  801109:	74 1a                	je     801125 <fd_lookup+0x4f>
    if (debug)
      cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  *fd_store = fd;
  80110b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80110e:	89 02                	mov    %eax,(%edx)
  return 0;
  801110:	b8 00 00 00 00       	mov    $0x0,%eax
  801115:	eb 13                	jmp    80112a <fd_lookup+0x54>
  struct Fd *fd;

  if (fdnum < 0 || fdnum >= MAXFD) {
    if (debug)
      cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  801117:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80111c:	eb 0c                	jmp    80112a <fd_lookup+0x54>
  }
  fd = INDEX2FD(fdnum);
  if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
    if (debug)
      cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  80111e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801123:	eb 05                	jmp    80112a <fd_lookup+0x54>
  801125:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  }
  *fd_store = fd;
  return 0;
}
  80112a:	5d                   	pop    %ebp
  80112b:	c3                   	ret    

0080112c <dev_lookup>:
  0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
  80112f:	83 ec 18             	sub    $0x18,%esp
  801132:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801135:	ba 2c 26 80 00       	mov    $0x80262c,%edx
  int i;

  for (i = 0; devtab[i]; i++)
  80113a:	eb 13                	jmp    80114f <dev_lookup+0x23>
  80113c:	83 c2 04             	add    $0x4,%edx
    if (devtab[i]->dev_id == dev_id) {
  80113f:	39 08                	cmp    %ecx,(%eax)
  801141:	75 0c                	jne    80114f <dev_lookup+0x23>
      *dev = devtab[i];
  801143:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801146:	89 01                	mov    %eax,(%ecx)
      return 0;
  801148:	b8 00 00 00 00       	mov    $0x0,%eax
  80114d:	eb 30                	jmp    80117f <dev_lookup+0x53>
int
dev_lookup(int dev_id, struct Dev **dev)
{
  int i;

  for (i = 0; devtab[i]; i++)
  80114f:	8b 02                	mov    (%edx),%eax
  801151:	85 c0                	test   %eax,%eax
  801153:	75 e7                	jne    80113c <dev_lookup+0x10>
    if (devtab[i]->dev_id == dev_id) {
      *dev = devtab[i];
      return 0;
    }
  cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801155:	a1 04 40 80 00       	mov    0x804004,%eax
  80115a:	8b 40 48             	mov    0x48(%eax),%eax
  80115d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801161:	89 44 24 04          	mov    %eax,0x4(%esp)
  801165:	c7 04 24 ac 25 80 00 	movl   $0x8025ac,(%esp)
  80116c:	e8 37 f2 ff ff       	call   8003a8 <cprintf>
  *dev = 0;
  801171:	8b 45 0c             	mov    0xc(%ebp),%eax
  801174:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  return -E_INVAL;
  80117a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80117f:	c9                   	leave  
  801180:	c3                   	ret    

00801181 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801181:	55                   	push   %ebp
  801182:	89 e5                	mov    %esp,%ebp
  801184:	56                   	push   %esi
  801185:	53                   	push   %ebx
  801186:	83 ec 20             	sub    $0x20,%esp
  801189:	8b 75 08             	mov    0x8(%ebp),%esi
  80118c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct Fd *fd2;
  struct Dev *dev;
  int r;

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80118f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801192:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  801196:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80119c:	c1 e8 0c             	shr    $0xc,%eax
{
  struct Fd *fd2;
  struct Dev *dev;
  int r;

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80119f:	89 04 24             	mov    %eax,(%esp)
  8011a2:	e8 2f ff ff ff       	call   8010d6 <fd_lookup>
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	78 05                	js     8011b0 <fd_close+0x2f>
      || fd != fd2)
  8011ab:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011ae:	74 0c                	je     8011bc <fd_close+0x3b>
    return must_exist ? r : 0;
  8011b0:	84 db                	test   %bl,%bl
  8011b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8011b7:	0f 44 c2             	cmove  %edx,%eax
  8011ba:	eb 3f                	jmp    8011fb <fd_close+0x7a>
  if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c3:	8b 06                	mov    (%esi),%eax
  8011c5:	89 04 24             	mov    %eax,(%esp)
  8011c8:	e8 5f ff ff ff       	call   80112c <dev_lookup>
  8011cd:	89 c3                	mov    %eax,%ebx
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	78 16                	js     8011e9 <fd_close+0x68>
    if (dev->dev_close)
  8011d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d6:	8b 40 10             	mov    0x10(%eax),%eax
      r = (*dev->dev_close)(fd);
    else
      r = 0;
  8011d9:	bb 00 00 00 00       	mov    $0x0,%ebx

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
      || fd != fd2)
    return must_exist ? r : 0;
  if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
    if (dev->dev_close)
  8011de:	85 c0                	test   %eax,%eax
  8011e0:	74 07                	je     8011e9 <fd_close+0x68>
      r = (*dev->dev_close)(fd);
  8011e2:	89 34 24             	mov    %esi,(%esp)
  8011e5:	ff d0                	call   *%eax
  8011e7:	89 c3                	mov    %eax,%ebx
    else
      r = 0;
  }
  // Make sure fd is unmapped.  Might be a no-op if
  // (*dev->dev_close)(fd) already unmapped it.
  (void)sys_page_unmap(0, fd);
  8011e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011f4:	e8 a1 fc ff ff       	call   800e9a <sys_page_unmap>
  return r;
  8011f9:	89 d8                	mov    %ebx,%eax
}
  8011fb:	83 c4 20             	add    $0x20,%esp
  8011fe:	5b                   	pop    %ebx
  8011ff:	5e                   	pop    %esi
  801200:	5d                   	pop    %ebp
  801201:	c3                   	ret    

00801202 <close>:
  return -E_INVAL;
}

int
close(int fdnum)
{
  801202:	55                   	push   %ebp
  801203:	89 e5                	mov    %esp,%ebp
  801205:	83 ec 28             	sub    $0x28,%esp
  struct Fd *fd;
  int r;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  801208:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80120b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80120f:	8b 45 08             	mov    0x8(%ebp),%eax
  801212:	89 04 24             	mov    %eax,(%esp)
  801215:	e8 bc fe ff ff       	call   8010d6 <fd_lookup>
  80121a:	89 c2                	mov    %eax,%edx
  80121c:	85 d2                	test   %edx,%edx
  80121e:	78 13                	js     801233 <close+0x31>
    return r;
  else
    return fd_close(fd, 1);
  801220:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801227:	00 
  801228:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80122b:	89 04 24             	mov    %eax,(%esp)
  80122e:	e8 4e ff ff ff       	call   801181 <fd_close>
}
  801233:	c9                   	leave  
  801234:	c3                   	ret    

00801235 <close_all>:

void
close_all(void)
{
  801235:	55                   	push   %ebp
  801236:	89 e5                	mov    %esp,%ebp
  801238:	53                   	push   %ebx
  801239:	83 ec 14             	sub    $0x14,%esp
  int i;

  for (i = 0; i < MAXFD; i++)
  80123c:	bb 00 00 00 00       	mov    $0x0,%ebx
    close(i);
  801241:	89 1c 24             	mov    %ebx,(%esp)
  801244:	e8 b9 ff ff ff       	call   801202 <close>
void
close_all(void)
{
  int i;

  for (i = 0; i < MAXFD; i++)
  801249:	83 c3 01             	add    $0x1,%ebx
  80124c:	83 fb 20             	cmp    $0x20,%ebx
  80124f:	75 f0                	jne    801241 <close_all+0xc>
    close(i);
}
  801251:	83 c4 14             	add    $0x14,%esp
  801254:	5b                   	pop    %ebx
  801255:	5d                   	pop    %ebp
  801256:	c3                   	ret    

00801257 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801257:	55                   	push   %ebp
  801258:	89 e5                	mov    %esp,%ebp
  80125a:	57                   	push   %edi
  80125b:	56                   	push   %esi
  80125c:	53                   	push   %ebx
  80125d:	83 ec 3c             	sub    $0x3c,%esp
  int r;
  char *ova, *nva;
  pte_t pte;
  struct Fd *oldfd, *newfd;

  if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801260:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801263:	89 44 24 04          	mov    %eax,0x4(%esp)
  801267:	8b 45 08             	mov    0x8(%ebp),%eax
  80126a:	89 04 24             	mov    %eax,(%esp)
  80126d:	e8 64 fe ff ff       	call   8010d6 <fd_lookup>
  801272:	89 c2                	mov    %eax,%edx
  801274:	85 d2                	test   %edx,%edx
  801276:	0f 88 e1 00 00 00    	js     80135d <dup+0x106>
    return r;
  close(newfdnum);
  80127c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80127f:	89 04 24             	mov    %eax,(%esp)
  801282:	e8 7b ff ff ff       	call   801202 <close>

  newfd = INDEX2FD(newfdnum);
  801287:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80128a:	c1 e3 0c             	shl    $0xc,%ebx
  80128d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
  ova = fd2data(oldfd);
  801293:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801296:	89 04 24             	mov    %eax,(%esp)
  801299:	e8 d2 fd ff ff       	call   801070 <fd2data>
  80129e:	89 c6                	mov    %eax,%esi
  nva = fd2data(newfd);
  8012a0:	89 1c 24             	mov    %ebx,(%esp)
  8012a3:	e8 c8 fd ff ff       	call   801070 <fd2data>
  8012a8:	89 c7                	mov    %eax,%edi

  if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012aa:	89 f0                	mov    %esi,%eax
  8012ac:	c1 e8 16             	shr    $0x16,%eax
  8012af:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012b6:	a8 01                	test   $0x1,%al
  8012b8:	74 43                	je     8012fd <dup+0xa6>
  8012ba:	89 f0                	mov    %esi,%eax
  8012bc:	c1 e8 0c             	shr    $0xc,%eax
  8012bf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012c6:	f6 c2 01             	test   $0x1,%dl
  8012c9:	74 32                	je     8012fd <dup+0xa6>
    if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012d2:	25 07 0e 00 00       	and    $0xe07,%eax
  8012d7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012df:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012e6:	00 
  8012e7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012f2:	e8 50 fb ff ff       	call   800e47 <sys_page_map>
  8012f7:	89 c6                	mov    %eax,%esi
  8012f9:	85 c0                	test   %eax,%eax
  8012fb:	78 3e                	js     80133b <dup+0xe4>
      goto err;
  if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801300:	89 c2                	mov    %eax,%edx
  801302:	c1 ea 0c             	shr    $0xc,%edx
  801305:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80130c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801312:	89 54 24 10          	mov    %edx,0x10(%esp)
  801316:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80131a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801321:	00 
  801322:	89 44 24 04          	mov    %eax,0x4(%esp)
  801326:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80132d:	e8 15 fb ff ff       	call   800e47 <sys_page_map>
  801332:	89 c6                	mov    %eax,%esi
    goto err;

  return newfdnum;
  801334:	8b 45 0c             	mov    0xc(%ebp),%eax
  nva = fd2data(newfd);

  if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
    if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
      goto err;
  if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801337:	85 f6                	test   %esi,%esi
  801339:	79 22                	jns    80135d <dup+0x106>
    goto err;

  return newfdnum;

err:
  sys_page_unmap(0, newfd);
  80133b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80133f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801346:	e8 4f fb ff ff       	call   800e9a <sys_page_unmap>
  sys_page_unmap(0, nva);
  80134b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80134f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801356:	e8 3f fb ff ff       	call   800e9a <sys_page_unmap>
  return r;
  80135b:	89 f0                	mov    %esi,%eax
}
  80135d:	83 c4 3c             	add    $0x3c,%esp
  801360:	5b                   	pop    %ebx
  801361:	5e                   	pop    %esi
  801362:	5f                   	pop    %edi
  801363:	5d                   	pop    %ebp
  801364:	c3                   	ret    

00801365 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801365:	55                   	push   %ebp
  801366:	89 e5                	mov    %esp,%ebp
  801368:	53                   	push   %ebx
  801369:	83 ec 24             	sub    $0x24,%esp
  80136c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  80136f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801372:	89 44 24 04          	mov    %eax,0x4(%esp)
  801376:	89 1c 24             	mov    %ebx,(%esp)
  801379:	e8 58 fd ff ff       	call   8010d6 <fd_lookup>
  80137e:	89 c2                	mov    %eax,%edx
  801380:	85 d2                	test   %edx,%edx
  801382:	78 6d                	js     8013f1 <read+0x8c>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801384:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801387:	89 44 24 04          	mov    %eax,0x4(%esp)
  80138b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138e:	8b 00                	mov    (%eax),%eax
  801390:	89 04 24             	mov    %eax,(%esp)
  801393:	e8 94 fd ff ff       	call   80112c <dev_lookup>
  801398:	85 c0                	test   %eax,%eax
  80139a:	78 55                	js     8013f1 <read+0x8c>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80139c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139f:	8b 50 08             	mov    0x8(%eax),%edx
  8013a2:	83 e2 03             	and    $0x3,%edx
  8013a5:	83 fa 01             	cmp    $0x1,%edx
  8013a8:	75 23                	jne    8013cd <read+0x68>
    cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013aa:	a1 04 40 80 00       	mov    0x804004,%eax
  8013af:	8b 40 48             	mov    0x48(%eax),%eax
  8013b2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ba:	c7 04 24 f0 25 80 00 	movl   $0x8025f0,(%esp)
  8013c1:	e8 e2 ef ff ff       	call   8003a8 <cprintf>
    return -E_INVAL;
  8013c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013cb:	eb 24                	jmp    8013f1 <read+0x8c>
  }
  if (!dev->dev_read)
  8013cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013d0:	8b 52 08             	mov    0x8(%edx),%edx
  8013d3:	85 d2                	test   %edx,%edx
  8013d5:	74 15                	je     8013ec <read+0x87>
    return -E_NOT_SUPP;
  return (*dev->dev_read)(fd, buf, n);
  8013d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8013da:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013e1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013e5:	89 04 24             	mov    %eax,(%esp)
  8013e8:	ff d2                	call   *%edx
  8013ea:	eb 05                	jmp    8013f1 <read+0x8c>
  if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
    cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  if (!dev->dev_read)
    return -E_NOT_SUPP;
  8013ec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_read)(fd, buf, n);
}
  8013f1:	83 c4 24             	add    $0x24,%esp
  8013f4:	5b                   	pop    %ebx
  8013f5:	5d                   	pop    %ebp
  8013f6:	c3                   	ret    

008013f7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013f7:	55                   	push   %ebp
  8013f8:	89 e5                	mov    %esp,%ebp
  8013fa:	57                   	push   %edi
  8013fb:	56                   	push   %esi
  8013fc:	53                   	push   %ebx
  8013fd:	83 ec 1c             	sub    $0x1c,%esp
  801400:	8b 7d 08             	mov    0x8(%ebp),%edi
  801403:	8b 75 10             	mov    0x10(%ebp),%esi
  int m, tot;

  for (tot = 0; tot < n; tot += m) {
  801406:	bb 00 00 00 00       	mov    $0x0,%ebx
  80140b:	eb 23                	jmp    801430 <readn+0x39>
    m = read(fdnum, (char*)buf + tot, n - tot);
  80140d:	89 f0                	mov    %esi,%eax
  80140f:	29 d8                	sub    %ebx,%eax
  801411:	89 44 24 08          	mov    %eax,0x8(%esp)
  801415:	89 d8                	mov    %ebx,%eax
  801417:	03 45 0c             	add    0xc(%ebp),%eax
  80141a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141e:	89 3c 24             	mov    %edi,(%esp)
  801421:	e8 3f ff ff ff       	call   801365 <read>
    if (m < 0)
  801426:	85 c0                	test   %eax,%eax
  801428:	78 10                	js     80143a <readn+0x43>
      return m;
    if (m == 0)
  80142a:	85 c0                	test   %eax,%eax
  80142c:	74 0a                	je     801438 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
  int m, tot;

  for (tot = 0; tot < n; tot += m) {
  80142e:	01 c3                	add    %eax,%ebx
  801430:	39 f3                	cmp    %esi,%ebx
  801432:	72 d9                	jb     80140d <readn+0x16>
  801434:	89 d8                	mov    %ebx,%eax
  801436:	eb 02                	jmp    80143a <readn+0x43>
  801438:	89 d8                	mov    %ebx,%eax
      return m;
    if (m == 0)
      break;
  }
  return tot;
}
  80143a:	83 c4 1c             	add    $0x1c,%esp
  80143d:	5b                   	pop    %ebx
  80143e:	5e                   	pop    %esi
  80143f:	5f                   	pop    %edi
  801440:	5d                   	pop    %ebp
  801441:	c3                   	ret    

00801442 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801442:	55                   	push   %ebp
  801443:	89 e5                	mov    %esp,%ebp
  801445:	53                   	push   %ebx
  801446:	83 ec 24             	sub    $0x24,%esp
  801449:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  80144c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80144f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801453:	89 1c 24             	mov    %ebx,(%esp)
  801456:	e8 7b fc ff ff       	call   8010d6 <fd_lookup>
  80145b:	89 c2                	mov    %eax,%edx
  80145d:	85 d2                	test   %edx,%edx
  80145f:	78 68                	js     8014c9 <write+0x87>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801461:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801464:	89 44 24 04          	mov    %eax,0x4(%esp)
  801468:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146b:	8b 00                	mov    (%eax),%eax
  80146d:	89 04 24             	mov    %eax,(%esp)
  801470:	e8 b7 fc ff ff       	call   80112c <dev_lookup>
  801475:	85 c0                	test   %eax,%eax
  801477:	78 50                	js     8014c9 <write+0x87>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801479:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801480:	75 23                	jne    8014a5 <write+0x63>
    cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801482:	a1 04 40 80 00       	mov    0x804004,%eax
  801487:	8b 40 48             	mov    0x48(%eax),%eax
  80148a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80148e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801492:	c7 04 24 0c 26 80 00 	movl   $0x80260c,(%esp)
  801499:	e8 0a ef ff ff       	call   8003a8 <cprintf>
    return -E_INVAL;
  80149e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014a3:	eb 24                	jmp    8014c9 <write+0x87>
  }
  if (debug)
    cprintf("write %d %p %d via dev %s\n",
            fdnum, buf, n, dev->dev_name);
  if (!dev->dev_write)
  8014a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014a8:	8b 52 0c             	mov    0xc(%edx),%edx
  8014ab:	85 d2                	test   %edx,%edx
  8014ad:	74 15                	je     8014c4 <write+0x82>
    return -E_NOT_SUPP;
  return (*dev->dev_write)(fd, buf, n);
  8014af:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014b2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014b9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014bd:	89 04 24             	mov    %eax,(%esp)
  8014c0:	ff d2                	call   *%edx
  8014c2:	eb 05                	jmp    8014c9 <write+0x87>
  }
  if (debug)
    cprintf("write %d %p %d via dev %s\n",
            fdnum, buf, n, dev->dev_name);
  if (!dev->dev_write)
    return -E_NOT_SUPP;
  8014c4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_write)(fd, buf, n);
}
  8014c9:	83 c4 24             	add    $0x24,%esp
  8014cc:	5b                   	pop    %ebx
  8014cd:	5d                   	pop    %ebp
  8014ce:	c3                   	ret    

008014cf <seek>:

int
seek(int fdnum, off_t offset)
{
  8014cf:	55                   	push   %ebp
  8014d0:	89 e5                	mov    %esp,%ebp
  8014d2:	83 ec 18             	sub    $0x18,%esp
  int r;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014d5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8014df:	89 04 24             	mov    %eax,(%esp)
  8014e2:	e8 ef fb ff ff       	call   8010d6 <fd_lookup>
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	78 0e                	js     8014f9 <seek+0x2a>
    return r;
  fd->fd_offset = offset;
  8014eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014f1:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
  8014f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014f9:	c9                   	leave  
  8014fa:	c3                   	ret    

008014fb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014fb:	55                   	push   %ebp
  8014fc:	89 e5                	mov    %esp,%ebp
  8014fe:	53                   	push   %ebx
  8014ff:	83 ec 24             	sub    $0x24,%esp
  801502:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  801505:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801508:	89 44 24 04          	mov    %eax,0x4(%esp)
  80150c:	89 1c 24             	mov    %ebx,(%esp)
  80150f:	e8 c2 fb ff ff       	call   8010d6 <fd_lookup>
  801514:	89 c2                	mov    %eax,%edx
  801516:	85 d2                	test   %edx,%edx
  801518:	78 61                	js     80157b <ftruncate+0x80>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801521:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801524:	8b 00                	mov    (%eax),%eax
  801526:	89 04 24             	mov    %eax,(%esp)
  801529:	e8 fe fb ff ff       	call   80112c <dev_lookup>
  80152e:	85 c0                	test   %eax,%eax
  801530:	78 49                	js     80157b <ftruncate+0x80>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801532:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801535:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801539:	75 23                	jne    80155e <ftruncate+0x63>
    cprintf("[%08x] ftruncate %d -- bad mode\n",
            thisenv->env_id, fdnum);
  80153b:	a1 04 40 80 00       	mov    0x804004,%eax

  if ((r = fd_lookup(fdnum, &fd)) < 0
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
    cprintf("[%08x] ftruncate %d -- bad mode\n",
  801540:	8b 40 48             	mov    0x48(%eax),%eax
  801543:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801547:	89 44 24 04          	mov    %eax,0x4(%esp)
  80154b:	c7 04 24 cc 25 80 00 	movl   $0x8025cc,(%esp)
  801552:	e8 51 ee ff ff       	call   8003a8 <cprintf>
            thisenv->env_id, fdnum);
    return -E_INVAL;
  801557:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80155c:	eb 1d                	jmp    80157b <ftruncate+0x80>
  }
  if (!dev->dev_trunc)
  80155e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801561:	8b 52 18             	mov    0x18(%edx),%edx
  801564:	85 d2                	test   %edx,%edx
  801566:	74 0e                	je     801576 <ftruncate+0x7b>
    return -E_NOT_SUPP;
  return (*dev->dev_trunc)(fd, newsize);
  801568:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80156b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80156f:	89 04 24             	mov    %eax,(%esp)
  801572:	ff d2                	call   *%edx
  801574:	eb 05                	jmp    80157b <ftruncate+0x80>
    cprintf("[%08x] ftruncate %d -- bad mode\n",
            thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  if (!dev->dev_trunc)
    return -E_NOT_SUPP;
  801576:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_trunc)(fd, newsize);
}
  80157b:	83 c4 24             	add    $0x24,%esp
  80157e:	5b                   	pop    %ebx
  80157f:	5d                   	pop    %ebp
  801580:	c3                   	ret    

00801581 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801581:	55                   	push   %ebp
  801582:	89 e5                	mov    %esp,%ebp
  801584:	53                   	push   %ebx
  801585:	83 ec 24             	sub    $0x24,%esp
  801588:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  80158b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80158e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801592:	8b 45 08             	mov    0x8(%ebp),%eax
  801595:	89 04 24             	mov    %eax,(%esp)
  801598:	e8 39 fb ff ff       	call   8010d6 <fd_lookup>
  80159d:	89 c2                	mov    %eax,%edx
  80159f:	85 d2                	test   %edx,%edx
  8015a1:	78 52                	js     8015f5 <fstat+0x74>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ad:	8b 00                	mov    (%eax),%eax
  8015af:	89 04 24             	mov    %eax,(%esp)
  8015b2:	e8 75 fb ff ff       	call   80112c <dev_lookup>
  8015b7:	85 c0                	test   %eax,%eax
  8015b9:	78 3a                	js     8015f5 <fstat+0x74>
    return r;
  if (!dev->dev_stat)
  8015bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015be:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015c2:	74 2c                	je     8015f0 <fstat+0x6f>
    return -E_NOT_SUPP;
  stat->st_name[0] = 0;
  8015c4:	c6 03 00             	movb   $0x0,(%ebx)
  stat->st_size = 0;
  8015c7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015ce:	00 00 00 
  stat->st_isdir = 0;
  8015d1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015d8:	00 00 00 
  stat->st_dev = dev;
  8015db:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
  return (*dev->dev_stat)(fd, stat);
  8015e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015e5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015e8:	89 14 24             	mov    %edx,(%esp)
  8015eb:	ff 50 14             	call   *0x14(%eax)
  8015ee:	eb 05                	jmp    8015f5 <fstat+0x74>

  if ((r = fd_lookup(fdnum, &fd)) < 0
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
    return r;
  if (!dev->dev_stat)
    return -E_NOT_SUPP;
  8015f0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  stat->st_name[0] = 0;
  stat->st_size = 0;
  stat->st_isdir = 0;
  stat->st_dev = dev;
  return (*dev->dev_stat)(fd, stat);
}
  8015f5:	83 c4 24             	add    $0x24,%esp
  8015f8:	5b                   	pop    %ebx
  8015f9:	5d                   	pop    %ebp
  8015fa:	c3                   	ret    

008015fb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015fb:	55                   	push   %ebp
  8015fc:	89 e5                	mov    %esp,%ebp
  8015fe:	56                   	push   %esi
  8015ff:	53                   	push   %ebx
  801600:	83 ec 10             	sub    $0x10,%esp
  int fd, r;

  if ((fd = open(path, O_RDONLY)) < 0)
  801603:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80160a:	00 
  80160b:	8b 45 08             	mov    0x8(%ebp),%eax
  80160e:	89 04 24             	mov    %eax,(%esp)
  801611:	e8 d2 01 00 00       	call   8017e8 <open>
  801616:	89 c3                	mov    %eax,%ebx
  801618:	85 db                	test   %ebx,%ebx
  80161a:	78 1b                	js     801637 <stat+0x3c>
    return fd;
  r = fstat(fd, stat);
  80161c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80161f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801623:	89 1c 24             	mov    %ebx,(%esp)
  801626:	e8 56 ff ff ff       	call   801581 <fstat>
  80162b:	89 c6                	mov    %eax,%esi
  close(fd);
  80162d:	89 1c 24             	mov    %ebx,(%esp)
  801630:	e8 cd fb ff ff       	call   801202 <close>
  return r;
  801635:	89 f0                	mov    %esi,%eax
}
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	5b                   	pop    %ebx
  80163b:	5e                   	pop    %esi
  80163c:	5d                   	pop    %ebp
  80163d:	c3                   	ret    

0080163e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	56                   	push   %esi
  801642:	53                   	push   %ebx
  801643:	83 ec 10             	sub    $0x10,%esp
  801646:	89 c6                	mov    %eax,%esi
  801648:	89 d3                	mov    %edx,%ebx
  static envid_t fsenv;

  if (fsenv == 0)
  80164a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801651:	75 11                	jne    801664 <fsipc+0x26>
    fsenv = ipc_find_env(ENV_TYPE_FS);
  801653:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80165a:	e8 48 08 00 00       	call   801ea7 <ipc_find_env>
  80165f:	a3 00 40 80 00       	mov    %eax,0x804000
  static_assert(sizeof(fsipcbuf) == PGSIZE);

  if (debug)
    cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t*)&fsipcbuf);

  ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801664:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80166b:	00 
  80166c:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801673:	00 
  801674:	89 74 24 04          	mov    %esi,0x4(%esp)
  801678:	a1 00 40 80 00       	mov    0x804000,%eax
  80167d:	89 04 24             	mov    %eax,(%esp)
  801680:	e8 b7 07 00 00       	call   801e3c <ipc_send>
  return ipc_recv(NULL, dstva, NULL);
  801685:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80168c:	00 
  80168d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801691:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801698:	e8 19 07 00 00       	call   801db6 <ipc_recv>
}
  80169d:	83 c4 10             	add    $0x10,%esp
  8016a0:	5b                   	pop    %ebx
  8016a1:	5e                   	pop    %esi
  8016a2:	5d                   	pop    %ebp
  8016a3:	c3                   	ret    

008016a4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016a4:	55                   	push   %ebp
  8016a5:	89 e5                	mov    %esp,%ebp
  8016a7:	83 ec 08             	sub    $0x8,%esp
  fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b0:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.set_size.req_size = newsize;
  8016b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016b8:	a3 04 50 80 00       	mov    %eax,0x805004
  return fsipc(FSREQ_SET_SIZE, NULL);
  8016bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c2:	b8 02 00 00 00       	mov    $0x2,%eax
  8016c7:	e8 72 ff ff ff       	call   80163e <fsipc>
}
  8016cc:	c9                   	leave  
  8016cd:	c3                   	ret    

008016ce <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016ce:	55                   	push   %ebp
  8016cf:	89 e5                	mov    %esp,%ebp
  8016d1:	83 ec 08             	sub    $0x8,%esp
  fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8016da:	a3 00 50 80 00       	mov    %eax,0x805000
  return fsipc(FSREQ_FLUSH, NULL);
  8016df:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e4:	b8 06 00 00 00       	mov    $0x6,%eax
  8016e9:	e8 50 ff ff ff       	call   80163e <fsipc>
}
  8016ee:	c9                   	leave  
  8016ef:	c3                   	ret    

008016f0 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	53                   	push   %ebx
  8016f4:	83 ec 14             	sub    $0x14,%esp
  8016f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int r;

  fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801700:	a3 00 50 80 00       	mov    %eax,0x805000
  if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801705:	ba 00 00 00 00       	mov    $0x0,%edx
  80170a:	b8 05 00 00 00       	mov    $0x5,%eax
  80170f:	e8 2a ff ff ff       	call   80163e <fsipc>
  801714:	89 c2                	mov    %eax,%edx
  801716:	85 d2                	test   %edx,%edx
  801718:	78 2b                	js     801745 <devfile_stat+0x55>
    return r;
  strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80171a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801721:	00 
  801722:	89 1c 24             	mov    %ebx,(%esp)
  801725:	e8 ad f2 ff ff       	call   8009d7 <strcpy>
  st->st_size = fsipcbuf.statRet.ret_size;
  80172a:	a1 80 50 80 00       	mov    0x805080,%eax
  80172f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801735:	a1 84 50 80 00       	mov    0x805084,%eax
  80173a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  return 0;
  801740:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801745:	83 c4 14             	add    $0x14,%esp
  801748:	5b                   	pop    %ebx
  801749:	5d                   	pop    %ebp
  80174a:	c3                   	ret    

0080174b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80174b:	55                   	push   %ebp
  80174c:	89 e5                	mov    %esp,%ebp
  80174e:	83 ec 18             	sub    $0x18,%esp
  801751:	8b 45 10             	mov    0x10(%ebp),%eax
  // remember that write is always allowed to write *fewer*
  // bytes than requested.
  // LAB 5: Your code here
    int r;

    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801754:	8b 55 08             	mov    0x8(%ebp),%edx
  801757:	8b 52 0c             	mov    0xc(%edx),%edx
  80175a:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  801760:	a3 04 50 80 00       	mov    %eax,0x805004

    size_t max_written = sizeof(fsipcbuf.write.req_buf);
    memmove(fsipcbuf.write.req_buf, buf, MIN(max_written, n));
  801765:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80176a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80176f:	0f 47 c2             	cmova  %edx,%eax
  801772:	89 44 24 08          	mov    %eax,0x8(%esp)
  801776:	8b 45 0c             	mov    0xc(%ebp),%eax
  801779:	89 44 24 04          	mov    %eax,0x4(%esp)
  80177d:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801784:	e8 eb f3 ff ff       	call   800b74 <memmove>

    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801789:	ba 00 00 00 00       	mov    $0x0,%edx
  80178e:	b8 04 00 00 00       	mov    $0x4,%eax
  801793:	e8 a6 fe ff ff       	call   80163e <fsipc>
        return r;

    return r;
}
  801798:	c9                   	leave  
  801799:	c3                   	ret    

0080179a <devfile_read>:
// Returns:
//  The number of bytes successfully read.
//  < 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80179a:	55                   	push   %ebp
  80179b:	89 e5                	mov    %esp,%ebp
  80179d:	53                   	push   %ebx
  80179e:	83 ec 14             	sub    $0x14,%esp
  // filling fsipcbuf.read with the request arguments.  The
  // bytes read will be written back to fsipcbuf by the file
  // system server.
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a4:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a7:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  8017ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8017af:	a3 04 50 80 00       	mov    %eax,0x805004
  if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b9:	b8 03 00 00 00       	mov    $0x3,%eax
  8017be:	e8 7b fe ff ff       	call   80163e <fsipc>
  8017c3:	89 c3                	mov    %eax,%ebx
  8017c5:	85 c0                	test   %eax,%eax
  8017c7:	78 17                	js     8017e0 <devfile_read+0x46>
    return r;

  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017cd:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8017d4:	00 
  8017d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017d8:	89 04 24             	mov    %eax,(%esp)
  8017db:	e8 94 f3 ff ff       	call   800b74 <memmove>
  return r;
}
  8017e0:	89 d8                	mov    %ebx,%eax
  8017e2:	83 c4 14             	add    $0x14,%esp
  8017e5:	5b                   	pop    %ebx
  8017e6:	5d                   	pop    %ebp
  8017e7:	c3                   	ret    

008017e8 <open>:
//  The file descriptor index on success
//  -E_BAD_PATH if the path is too long (>= MAXPATHLEN)
//  < 0 for other errors.
int
open(const char *path, int mode)
{
  8017e8:	55                   	push   %ebp
  8017e9:	89 e5                	mov    %esp,%ebp
  8017eb:	53                   	push   %ebx
  8017ec:	83 ec 24             	sub    $0x24,%esp
  8017ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
  // file descriptor.

  int r;
  struct Fd *fd;

  if (strlen(path) >= MAXPATHLEN)
  8017f2:	89 1c 24             	mov    %ebx,(%esp)
  8017f5:	e8 a6 f1 ff ff       	call   8009a0 <strlen>
  8017fa:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017ff:	7f 60                	jg     801861 <open+0x79>
    return -E_BAD_PATH;

  if ((r = fd_alloc(&fd)) < 0)
  801801:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801804:	89 04 24             	mov    %eax,(%esp)
  801807:	e8 7b f8 ff ff       	call   801087 <fd_alloc>
  80180c:	89 c2                	mov    %eax,%edx
  80180e:	85 d2                	test   %edx,%edx
  801810:	78 54                	js     801866 <open+0x7e>
    return r;

  strcpy(fsipcbuf.open.req_path, path);
  801812:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801816:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80181d:	e8 b5 f1 ff ff       	call   8009d7 <strcpy>
  fsipcbuf.open.req_omode = mode;
  801822:	8b 45 0c             	mov    0xc(%ebp),%eax
  801825:	a3 00 54 80 00       	mov    %eax,0x805400

  if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80182a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80182d:	b8 01 00 00 00       	mov    $0x1,%eax
  801832:	e8 07 fe ff ff       	call   80163e <fsipc>
  801837:	89 c3                	mov    %eax,%ebx
  801839:	85 c0                	test   %eax,%eax
  80183b:	79 17                	jns    801854 <open+0x6c>
    fd_close(fd, 0);
  80183d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801844:	00 
  801845:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801848:	89 04 24             	mov    %eax,(%esp)
  80184b:	e8 31 f9 ff ff       	call   801181 <fd_close>
    return r;
  801850:	89 d8                	mov    %ebx,%eax
  801852:	eb 12                	jmp    801866 <open+0x7e>
  }

  return fd2num(fd);
  801854:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801857:	89 04 24             	mov    %eax,(%esp)
  80185a:	e8 01 f8 ff ff       	call   801060 <fd2num>
  80185f:	eb 05                	jmp    801866 <open+0x7e>

  int r;
  struct Fd *fd;

  if (strlen(path) >= MAXPATHLEN)
    return -E_BAD_PATH;
  801861:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
    fd_close(fd, 0);
    return r;
  }

  return fd2num(fd);
}
  801866:	83 c4 24             	add    $0x24,%esp
  801869:	5b                   	pop    %ebx
  80186a:	5d                   	pop    %ebp
  80186b:	c3                   	ret    

0080186c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80186c:	55                   	push   %ebp
  80186d:	89 e5                	mov    %esp,%ebp
  80186f:	83 ec 08             	sub    $0x8,%esp
  // Ask the file server to update the disk
  // by writing any dirty blocks in the buffer cache.

  return fsipc(FSREQ_SYNC, NULL);
  801872:	ba 00 00 00 00       	mov    $0x0,%edx
  801877:	b8 08 00 00 00       	mov    $0x8,%eax
  80187c:	e8 bd fd ff ff       	call   80163e <fsipc>
}
  801881:	c9                   	leave  
  801882:	c3                   	ret    

00801883 <devpipe_stat>:
  return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801883:	55                   	push   %ebp
  801884:	89 e5                	mov    %esp,%ebp
  801886:	56                   	push   %esi
  801887:	53                   	push   %ebx
  801888:	83 ec 10             	sub    $0x10,%esp
  80188b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct Pipe *p = (struct Pipe*)fd2data(fd);
  80188e:	8b 45 08             	mov    0x8(%ebp),%eax
  801891:	89 04 24             	mov    %eax,(%esp)
  801894:	e8 d7 f7 ff ff       	call   801070 <fd2data>
  801899:	89 c6                	mov    %eax,%esi

  strcpy(stat->st_name, "<pipe>");
  80189b:	c7 44 24 04 3c 26 80 	movl   $0x80263c,0x4(%esp)
  8018a2:	00 
  8018a3:	89 1c 24             	mov    %ebx,(%esp)
  8018a6:	e8 2c f1 ff ff       	call   8009d7 <strcpy>
  stat->st_size = p->p_wpos - p->p_rpos;
  8018ab:	8b 46 04             	mov    0x4(%esi),%eax
  8018ae:	2b 06                	sub    (%esi),%eax
  8018b0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  stat->st_isdir = 0;
  8018b6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018bd:	00 00 00 
  stat->st_dev = &devpipe;
  8018c0:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018c7:	30 80 00 
  return 0;
}
  8018ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8018cf:	83 c4 10             	add    $0x10,%esp
  8018d2:	5b                   	pop    %ebx
  8018d3:	5e                   	pop    %esi
  8018d4:	5d                   	pop    %ebp
  8018d5:	c3                   	ret    

008018d6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018d6:	55                   	push   %ebp
  8018d7:	89 e5                	mov    %esp,%ebp
  8018d9:	53                   	push   %ebx
  8018da:	83 ec 14             	sub    $0x14,%esp
  8018dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  (void)sys_page_unmap(0, fd);
  8018e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018eb:	e8 aa f5 ff ff       	call   800e9a <sys_page_unmap>
  return sys_page_unmap(0, fd2data(fd));
  8018f0:	89 1c 24             	mov    %ebx,(%esp)
  8018f3:	e8 78 f7 ff ff       	call   801070 <fd2data>
  8018f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801903:	e8 92 f5 ff ff       	call   800e9a <sys_page_unmap>
}
  801908:	83 c4 14             	add    $0x14,%esp
  80190b:	5b                   	pop    %ebx
  80190c:	5d                   	pop    %ebp
  80190d:	c3                   	ret    

0080190e <_pipeisclosed>:
  return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	57                   	push   %edi
  801912:	56                   	push   %esi
  801913:	53                   	push   %ebx
  801914:	83 ec 2c             	sub    $0x2c,%esp
  801917:	89 c6                	mov    %eax,%esi
  801919:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  int n, nn, ret;

  while (1) {
    n = thisenv->env_runs;
  80191c:	a1 04 40 80 00       	mov    0x804004,%eax
  801921:	8b 58 58             	mov    0x58(%eax),%ebx
    ret = pageref(fd) == pageref(p);
  801924:	89 34 24             	mov    %esi,(%esp)
  801927:	e8 b3 05 00 00       	call   801edf <pageref>
  80192c:	89 c7                	mov    %eax,%edi
  80192e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801931:	89 04 24             	mov    %eax,(%esp)
  801934:	e8 a6 05 00 00       	call   801edf <pageref>
  801939:	39 c7                	cmp    %eax,%edi
  80193b:	0f 94 c2             	sete   %dl
  80193e:	0f b6 c2             	movzbl %dl,%eax
    nn = thisenv->env_runs;
  801941:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801947:	8b 79 58             	mov    0x58(%ecx),%edi
    if (n == nn)
  80194a:	39 fb                	cmp    %edi,%ebx
  80194c:	74 21                	je     80196f <_pipeisclosed+0x61>
      return ret;
    if (n != nn && ret == 1)
  80194e:	84 d2                	test   %dl,%dl
  801950:	74 ca                	je     80191c <_pipeisclosed+0xe>
      cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801952:	8b 51 58             	mov    0x58(%ecx),%edx
  801955:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801959:	89 54 24 08          	mov    %edx,0x8(%esp)
  80195d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801961:	c7 04 24 43 26 80 00 	movl   $0x802643,(%esp)
  801968:	e8 3b ea ff ff       	call   8003a8 <cprintf>
  80196d:	eb ad                	jmp    80191c <_pipeisclosed+0xe>
  }
}
  80196f:	83 c4 2c             	add    $0x2c,%esp
  801972:	5b                   	pop    %ebx
  801973:	5e                   	pop    %esi
  801974:	5f                   	pop    %edi
  801975:	5d                   	pop    %ebp
  801976:	c3                   	ret    

00801977 <devpipe_write>:
  return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801977:	55                   	push   %ebp
  801978:	89 e5                	mov    %esp,%ebp
  80197a:	57                   	push   %edi
  80197b:	56                   	push   %esi
  80197c:	53                   	push   %ebx
  80197d:	83 ec 1c             	sub    $0x1c,%esp
  801980:	8b 75 08             	mov    0x8(%ebp),%esi
  const uint8_t *buf;
  size_t i;
  struct Pipe *p;

  p = (struct Pipe*)fd2data(fd);
  801983:	89 34 24             	mov    %esi,(%esp)
  801986:	e8 e5 f6 ff ff       	call   801070 <fd2data>
  80198b:	89 c3                	mov    %eax,%ebx
  if (debug)
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  80198d:	bf 00 00 00 00       	mov    $0x0,%edi
  801992:	eb 45                	jmp    8019d9 <devpipe_write+0x62>
    while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
      // pipe is full
      // if all the readers are gone
      // (it's only writers like us now),
      // note eof
      if (_pipeisclosed(fd, p))
  801994:	89 da                	mov    %ebx,%edx
  801996:	89 f0                	mov    %esi,%eax
  801998:	e8 71 ff ff ff       	call   80190e <_pipeisclosed>
  80199d:	85 c0                	test   %eax,%eax
  80199f:	75 41                	jne    8019e2 <devpipe_write+0x6b>
        return 0;
      // yield and see what happens
      if (debug)
        cprintf("devpipe_write yield\n");
      sys_yield();
  8019a1:	e8 2e f4 ff ff       	call   800dd4 <sys_yield>
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
    while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019a6:	8b 43 04             	mov    0x4(%ebx),%eax
  8019a9:	8b 0b                	mov    (%ebx),%ecx
  8019ab:	8d 51 20             	lea    0x20(%ecx),%edx
  8019ae:	39 d0                	cmp    %edx,%eax
  8019b0:	73 e2                	jae    801994 <devpipe_write+0x1d>
        cprintf("devpipe_write yield\n");
      sys_yield();
    }
    // there's room for a byte.  store it.
    // wait to increment wpos until the byte is stored!
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019b5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019b9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019bc:	99                   	cltd   
  8019bd:	c1 ea 1b             	shr    $0x1b,%edx
  8019c0:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8019c3:	83 e1 1f             	and    $0x1f,%ecx
  8019c6:	29 d1                	sub    %edx,%ecx
  8019c8:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8019cc:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
    p->p_wpos++;
  8019d0:	83 c0 01             	add    $0x1,%eax
  8019d3:	89 43 04             	mov    %eax,0x4(%ebx)
  if (debug)
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  8019d6:	83 c7 01             	add    $0x1,%edi
  8019d9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019dc:	75 c8                	jne    8019a6 <devpipe_write+0x2f>
    // wait to increment wpos until the byte is stored!
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
    p->p_wpos++;
  }

  return i;
  8019de:	89 f8                	mov    %edi,%eax
  8019e0:	eb 05                	jmp    8019e7 <devpipe_write+0x70>
      // pipe is full
      // if all the readers are gone
      // (it's only writers like us now),
      // note eof
      if (_pipeisclosed(fd, p))
        return 0;
  8019e2:	b8 00 00 00 00       	mov    $0x0,%eax
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
    p->p_wpos++;
  }

  return i;
}
  8019e7:	83 c4 1c             	add    $0x1c,%esp
  8019ea:	5b                   	pop    %ebx
  8019eb:	5e                   	pop    %esi
  8019ec:	5f                   	pop    %edi
  8019ed:	5d                   	pop    %ebp
  8019ee:	c3                   	ret    

008019ef <devpipe_read>:
  return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019ef:	55                   	push   %ebp
  8019f0:	89 e5                	mov    %esp,%ebp
  8019f2:	57                   	push   %edi
  8019f3:	56                   	push   %esi
  8019f4:	53                   	push   %ebx
  8019f5:	83 ec 1c             	sub    $0x1c,%esp
  8019f8:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint8_t *buf;
  size_t i;
  struct Pipe *p;

  p = (struct Pipe*)fd2data(fd);
  8019fb:	89 3c 24             	mov    %edi,(%esp)
  8019fe:	e8 6d f6 ff ff       	call   801070 <fd2data>
  801a03:	89 c3                	mov    %eax,%ebx
  if (debug)
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  801a05:	be 00 00 00 00       	mov    $0x0,%esi
  801a0a:	eb 3d                	jmp    801a49 <devpipe_read+0x5a>
    while (p->p_rpos == p->p_wpos) {
      // pipe is empty
      // if we got any data, return it
      if (i > 0)
  801a0c:	85 f6                	test   %esi,%esi
  801a0e:	74 04                	je     801a14 <devpipe_read+0x25>
        return i;
  801a10:	89 f0                	mov    %esi,%eax
  801a12:	eb 43                	jmp    801a57 <devpipe_read+0x68>
      // if all the writers are gone, note eof
      if (_pipeisclosed(fd, p))
  801a14:	89 da                	mov    %ebx,%edx
  801a16:	89 f8                	mov    %edi,%eax
  801a18:	e8 f1 fe ff ff       	call   80190e <_pipeisclosed>
  801a1d:	85 c0                	test   %eax,%eax
  801a1f:	75 31                	jne    801a52 <devpipe_read+0x63>
        return 0;
      // yield and see what happens
      if (debug)
        cprintf("devpipe_read yield\n");
      sys_yield();
  801a21:	e8 ae f3 ff ff       	call   800dd4 <sys_yield>
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
    while (p->p_rpos == p->p_wpos) {
  801a26:	8b 03                	mov    (%ebx),%eax
  801a28:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a2b:	74 df                	je     801a0c <devpipe_read+0x1d>
        cprintf("devpipe_read yield\n");
      sys_yield();
    }
    // there's a byte.  take it.
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a2d:	99                   	cltd   
  801a2e:	c1 ea 1b             	shr    $0x1b,%edx
  801a31:	01 d0                	add    %edx,%eax
  801a33:	83 e0 1f             	and    $0x1f,%eax
  801a36:	29 d0                	sub    %edx,%eax
  801a38:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801a3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a40:	88 04 31             	mov    %al,(%ecx,%esi,1)
    p->p_rpos++;
  801a43:	83 03 01             	addl   $0x1,(%ebx)
  if (debug)
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  801a46:	83 c6 01             	add    $0x1,%esi
  801a49:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a4c:	75 d8                	jne    801a26 <devpipe_read+0x37>
    // there's a byte.  take it.
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
    p->p_rpos++;
  }
  return i;
  801a4e:	89 f0                	mov    %esi,%eax
  801a50:	eb 05                	jmp    801a57 <devpipe_read+0x68>
      // if we got any data, return it
      if (i > 0)
        return i;
      // if all the writers are gone, note eof
      if (_pipeisclosed(fd, p))
        return 0;
  801a52:	b8 00 00 00 00       	mov    $0x0,%eax
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
    p->p_rpos++;
  }
  return i;
}
  801a57:	83 c4 1c             	add    $0x1c,%esp
  801a5a:	5b                   	pop    %ebx
  801a5b:	5e                   	pop    %esi
  801a5c:	5f                   	pop    %edi
  801a5d:	5d                   	pop    %ebp
  801a5e:	c3                   	ret    

00801a5f <pipe>:
  uint8_t p_buf[PIPEBUFSIZ];    // data buffer
};

int
pipe(int pfd[2])
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	56                   	push   %esi
  801a63:	53                   	push   %ebx
  801a64:	83 ec 30             	sub    $0x30,%esp
  int r;
  struct Fd *fd0, *fd1;
  void *va;

  // allocate the file descriptor table entries
  if ((r = fd_alloc(&fd0)) < 0
  801a67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a6a:	89 04 24             	mov    %eax,(%esp)
  801a6d:	e8 15 f6 ff ff       	call   801087 <fd_alloc>
  801a72:	89 c2                	mov    %eax,%edx
  801a74:	85 d2                	test   %edx,%edx
  801a76:	0f 88 4d 01 00 00    	js     801bc9 <pipe+0x16a>
      || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a7c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a83:	00 
  801a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a87:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a92:	e8 5c f3 ff ff       	call   800df3 <sys_page_alloc>
  801a97:	89 c2                	mov    %eax,%edx
  801a99:	85 d2                	test   %edx,%edx
  801a9b:	0f 88 28 01 00 00    	js     801bc9 <pipe+0x16a>
    goto err;

  if ((r = fd_alloc(&fd1)) < 0
  801aa1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801aa4:	89 04 24             	mov    %eax,(%esp)
  801aa7:	e8 db f5 ff ff       	call   801087 <fd_alloc>
  801aac:	89 c3                	mov    %eax,%ebx
  801aae:	85 c0                	test   %eax,%eax
  801ab0:	0f 88 fe 00 00 00    	js     801bb4 <pipe+0x155>
      || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ab6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801abd:	00 
  801abe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ac1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801acc:	e8 22 f3 ff ff       	call   800df3 <sys_page_alloc>
  801ad1:	89 c3                	mov    %eax,%ebx
  801ad3:	85 c0                	test   %eax,%eax
  801ad5:	0f 88 d9 00 00 00    	js     801bb4 <pipe+0x155>
    goto err1;

  // allocate the pipe structure as first data page in both
  va = fd2data(fd0);
  801adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ade:	89 04 24             	mov    %eax,(%esp)
  801ae1:	e8 8a f5 ff ff       	call   801070 <fd2data>
  801ae6:	89 c6                	mov    %eax,%esi
  if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ae8:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801aef:	00 
  801af0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801afb:	e8 f3 f2 ff ff       	call   800df3 <sys_page_alloc>
  801b00:	89 c3                	mov    %eax,%ebx
  801b02:	85 c0                	test   %eax,%eax
  801b04:	0f 88 97 00 00 00    	js     801ba1 <pipe+0x142>
    goto err2;
  if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b0d:	89 04 24             	mov    %eax,(%esp)
  801b10:	e8 5b f5 ff ff       	call   801070 <fd2data>
  801b15:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801b1c:	00 
  801b1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b21:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b28:	00 
  801b29:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b2d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b34:	e8 0e f3 ff ff       	call   800e47 <sys_page_map>
  801b39:	89 c3                	mov    %eax,%ebx
  801b3b:	85 c0                	test   %eax,%eax
  801b3d:	78 52                	js     801b91 <pipe+0x132>
    goto err3;

  // set up fd structures
  fd0->fd_dev_id = devpipe.dev_id;
  801b3f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b48:	89 10                	mov    %edx,(%eax)
  fd0->fd_omode = O_RDONLY;
  801b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b4d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

  fd1->fd_dev_id = devpipe.dev_id;
  801b54:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b5d:	89 10                	mov    %edx,(%eax)
  fd1->fd_omode = O_WRONLY;
  801b5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b62:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

  if (debug)
    cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

  pfd[0] = fd2num(fd0);
  801b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6c:	89 04 24             	mov    %eax,(%esp)
  801b6f:	e8 ec f4 ff ff       	call   801060 <fd2num>
  801b74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b77:	89 01                	mov    %eax,(%ecx)
  pfd[1] = fd2num(fd1);
  801b79:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b7c:	89 04 24             	mov    %eax,(%esp)
  801b7f:	e8 dc f4 ff ff       	call   801060 <fd2num>
  801b84:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b87:	89 41 04             	mov    %eax,0x4(%ecx)
  return 0;
  801b8a:	b8 00 00 00 00       	mov    $0x0,%eax
  801b8f:	eb 38                	jmp    801bc9 <pipe+0x16a>

err3:
  sys_page_unmap(0, va);
  801b91:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b95:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b9c:	e8 f9 f2 ff ff       	call   800e9a <sys_page_unmap>
err2:
  sys_page_unmap(0, fd1);
  801ba1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ba4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801baf:	e8 e6 f2 ff ff       	call   800e9a <sys_page_unmap>
err1:
  sys_page_unmap(0, fd0);
  801bb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bbb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bc2:	e8 d3 f2 ff ff       	call   800e9a <sys_page_unmap>
  801bc7:	89 d8                	mov    %ebx,%eax
err:
  return r;
}
  801bc9:	83 c4 30             	add    $0x30,%esp
  801bcc:	5b                   	pop    %ebx
  801bcd:	5e                   	pop    %esi
  801bce:	5d                   	pop    %ebp
  801bcf:	c3                   	ret    

00801bd0 <pipeisclosed>:
  }
}

int
pipeisclosed(int fdnum)
{
  801bd0:	55                   	push   %ebp
  801bd1:	89 e5                	mov    %esp,%ebp
  801bd3:	83 ec 28             	sub    $0x28,%esp
  struct Fd *fd;
  struct Pipe *p;
  int r;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bd6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bdd:	8b 45 08             	mov    0x8(%ebp),%eax
  801be0:	89 04 24             	mov    %eax,(%esp)
  801be3:	e8 ee f4 ff ff       	call   8010d6 <fd_lookup>
  801be8:	89 c2                	mov    %eax,%edx
  801bea:	85 d2                	test   %edx,%edx
  801bec:	78 15                	js     801c03 <pipeisclosed+0x33>
    return r;
  p = (struct Pipe*)fd2data(fd);
  801bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf1:	89 04 24             	mov    %eax,(%esp)
  801bf4:	e8 77 f4 ff ff       	call   801070 <fd2data>
  return _pipeisclosed(fd, p);
  801bf9:	89 c2                	mov    %eax,%edx
  801bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfe:	e8 0b fd ff ff       	call   80190e <_pipeisclosed>
}
  801c03:	c9                   	leave  
  801c04:	c3                   	ret    
  801c05:	66 90                	xchg   %ax,%ax
  801c07:	66 90                	xchg   %ax,%ax
  801c09:	66 90                	xchg   %ax,%ax
  801c0b:	66 90                	xchg   %ax,%ax
  801c0d:	66 90                	xchg   %ax,%ax
  801c0f:	90                   	nop

00801c10 <devcons_close>:
  return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c10:	55                   	push   %ebp
  801c11:	89 e5                	mov    %esp,%ebp
  USED(fd);

  return 0;
}
  801c13:	b8 00 00 00 00       	mov    $0x0,%eax
  801c18:	5d                   	pop    %ebp
  801c19:	c3                   	ret    

00801c1a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c1a:	55                   	push   %ebp
  801c1b:	89 e5                	mov    %esp,%ebp
  801c1d:	83 ec 18             	sub    $0x18,%esp
  strcpy(stat->st_name, "<cons>");
  801c20:	c7 44 24 04 5b 26 80 	movl   $0x80265b,0x4(%esp)
  801c27:	00 
  801c28:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c2b:	89 04 24             	mov    %eax,(%esp)
  801c2e:	e8 a4 ed ff ff       	call   8009d7 <strcpy>
  return 0;
}
  801c33:	b8 00 00 00 00       	mov    $0x0,%eax
  801c38:	c9                   	leave  
  801c39:	c3                   	ret    

00801c3a <devcons_write>:
  return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c3a:	55                   	push   %ebp
  801c3b:	89 e5                	mov    %esp,%ebp
  801c3d:	57                   	push   %edi
  801c3e:	56                   	push   %esi
  801c3f:	53                   	push   %ebx
  801c40:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  801c46:	bb 00 00 00 00       	mov    $0x0,%ebx
    m = n - tot;
    if (m > sizeof(buf) - 1)
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
  801c4b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  801c51:	eb 31                	jmp    801c84 <devcons_write+0x4a>
    m = n - tot;
  801c53:	8b 75 10             	mov    0x10(%ebp),%esi
  801c56:	29 de                	sub    %ebx,%esi
    if (m > sizeof(buf) - 1)
  801c58:	83 fe 7f             	cmp    $0x7f,%esi
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
    m = n - tot;
  801c5b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c60:	0f 47 f2             	cmova  %edx,%esi
    if (m > sizeof(buf) - 1)
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
  801c63:	89 74 24 08          	mov    %esi,0x8(%esp)
  801c67:	03 45 0c             	add    0xc(%ebp),%eax
  801c6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c6e:	89 3c 24             	mov    %edi,(%esp)
  801c71:	e8 fe ee ff ff       	call   800b74 <memmove>
    sys_cputs(buf, m);
  801c76:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c7a:	89 3c 24             	mov    %edi,(%esp)
  801c7d:	e8 a4 f0 ff ff       	call   800d26 <sys_cputs>
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  801c82:	01 f3                	add    %esi,%ebx
  801c84:	89 d8                	mov    %ebx,%eax
  801c86:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c89:	72 c8                	jb     801c53 <devcons_write+0x19>
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
    sys_cputs(buf, m);
  }
  return tot;
}
  801c8b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801c91:	5b                   	pop    %ebx
  801c92:	5e                   	pop    %esi
  801c93:	5f                   	pop    %edi
  801c94:	5d                   	pop    %ebp
  801c95:	c3                   	ret    

00801c96 <devcons_read>:
  return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c96:	55                   	push   %ebp
  801c97:	89 e5                	mov    %esp,%ebp
  801c99:	83 ec 08             	sub    $0x8,%esp
  int c;

  if (n == 0)
    return 0;
  801c9c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  int c;

  if (n == 0)
  801ca1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ca5:	75 07                	jne    801cae <devcons_read+0x18>
  801ca7:	eb 2a                	jmp    801cd3 <devcons_read+0x3d>
    return 0;

  while ((c = sys_cgetc()) == 0)
    sys_yield();
  801ca9:	e8 26 f1 ff ff       	call   800dd4 <sys_yield>
  int c;

  if (n == 0)
    return 0;

  while ((c = sys_cgetc()) == 0)
  801cae:	66 90                	xchg   %ax,%ax
  801cb0:	e8 8f f0 ff ff       	call   800d44 <sys_cgetc>
  801cb5:	85 c0                	test   %eax,%eax
  801cb7:	74 f0                	je     801ca9 <devcons_read+0x13>
    sys_yield();
  if (c < 0)
  801cb9:	85 c0                	test   %eax,%eax
  801cbb:	78 16                	js     801cd3 <devcons_read+0x3d>
    return c;
  if (c == 0x04)        // ctl-d is eof
  801cbd:	83 f8 04             	cmp    $0x4,%eax
  801cc0:	74 0c                	je     801cce <devcons_read+0x38>
    return 0;
  *(char*)vbuf = c;
  801cc2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cc5:	88 02                	mov    %al,(%edx)
  return 1;
  801cc7:	b8 01 00 00 00       	mov    $0x1,%eax
  801ccc:	eb 05                	jmp    801cd3 <devcons_read+0x3d>
  while ((c = sys_cgetc()) == 0)
    sys_yield();
  if (c < 0)
    return c;
  if (c == 0x04)        // ctl-d is eof
    return 0;
  801cce:	b8 00 00 00 00       	mov    $0x0,%eax
  *(char*)vbuf = c;
  return 1;
}
  801cd3:	c9                   	leave  
  801cd4:	c3                   	ret    

00801cd5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cd5:	55                   	push   %ebp
  801cd6:	89 e5                	mov    %esp,%ebp
  801cd8:	83 ec 28             	sub    $0x28,%esp
  char c = ch;
  801cdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cde:	88 45 f7             	mov    %al,-0x9(%ebp)

  // Unlike standard Unix's putchar,
  // the cputchar function _always_ outputs to the system console.
  sys_cputs(&c, 1);
  801ce1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ce8:	00 
  801ce9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cec:	89 04 24             	mov    %eax,(%esp)
  801cef:	e8 32 f0 ff ff       	call   800d26 <sys_cputs>
}
  801cf4:	c9                   	leave  
  801cf5:	c3                   	ret    

00801cf6 <getchar>:

int
getchar(void)
{
  801cf6:	55                   	push   %ebp
  801cf7:	89 e5                	mov    %esp,%ebp
  801cf9:	83 ec 28             	sub    $0x28,%esp
  int r;

  // JOS does, however, support standard _input_ redirection,
  // allowing the user to redirect script files to the shell and such.
  // getchar() reads a character from file descriptor 0.
  r = read(0, &c, 1);
  801cfc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801d03:	00 
  801d04:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d07:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d12:	e8 4e f6 ff ff       	call   801365 <read>
  if (r < 0)
  801d17:	85 c0                	test   %eax,%eax
  801d19:	78 0f                	js     801d2a <getchar+0x34>
    return r;
  if (r < 1)
  801d1b:	85 c0                	test   %eax,%eax
  801d1d:	7e 06                	jle    801d25 <getchar+0x2f>
    return -E_EOF;
  return c;
  801d1f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d23:	eb 05                	jmp    801d2a <getchar+0x34>
  // getchar() reads a character from file descriptor 0.
  r = read(0, &c, 1);
  if (r < 0)
    return r;
  if (r < 1)
    return -E_EOF;
  801d25:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  /* int r;
  // sys_cgetc does not block, but getchar should.
  while ((r = sys_cgetc()) == 0)
    sys_yield();
  return r; */
}
  801d2a:	c9                   	leave  
  801d2b:	c3                   	ret    

00801d2c <iscons>:
  .dev_stat   =     devcons_stat
};

int
iscons(int fdnum)
{
  801d2c:	55                   	push   %ebp
  801d2d:	89 e5                	mov    %esp,%ebp
  801d2f:	83 ec 28             	sub    $0x28,%esp
  int r;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d32:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d35:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d39:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3c:	89 04 24             	mov    %eax,(%esp)
  801d3f:	e8 92 f3 ff ff       	call   8010d6 <fd_lookup>
  801d44:	85 c0                	test   %eax,%eax
  801d46:	78 11                	js     801d59 <iscons+0x2d>
    return r;
  return fd->fd_dev_id == devcons.dev_id;
  801d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d51:	39 10                	cmp    %edx,(%eax)
  801d53:	0f 94 c0             	sete   %al
  801d56:	0f b6 c0             	movzbl %al,%eax
}
  801d59:	c9                   	leave  
  801d5a:	c3                   	ret    

00801d5b <opencons>:

int
opencons(void)
{
  801d5b:	55                   	push   %ebp
  801d5c:	89 e5                	mov    %esp,%ebp
  801d5e:	83 ec 28             	sub    $0x28,%esp
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
  801d61:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d64:	89 04 24             	mov    %eax,(%esp)
  801d67:	e8 1b f3 ff ff       	call   801087 <fd_alloc>
    return r;
  801d6c:	89 c2                	mov    %eax,%edx
opencons(void)
{
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
  801d6e:	85 c0                	test   %eax,%eax
  801d70:	78 40                	js     801db2 <opencons+0x57>
    return r;
  if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d72:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d79:	00 
  801d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d88:	e8 66 f0 ff ff       	call   800df3 <sys_page_alloc>
    return r;
  801d8d:	89 c2                	mov    %eax,%edx
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
    return r;
  if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d8f:	85 c0                	test   %eax,%eax
  801d91:	78 1f                	js     801db2 <opencons+0x57>
    return r;
  fd->fd_dev_id = devcons.dev_id;
  801d93:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9c:	89 10                	mov    %edx,(%eax)
  fd->fd_omode = O_RDWR;
  801d9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
  return fd2num(fd);
  801da8:	89 04 24             	mov    %eax,(%esp)
  801dab:	e8 b0 f2 ff ff       	call   801060 <fd2num>
  801db0:	89 c2                	mov    %eax,%edx
}
  801db2:	89 d0                	mov    %edx,%eax
  801db4:	c9                   	leave  
  801db5:	c3                   	ret    

00801db6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801db6:	55                   	push   %ebp
  801db7:	89 e5                	mov    %esp,%ebp
  801db9:	56                   	push   %esi
  801dba:	53                   	push   %ebx
  801dbb:	83 ec 10             	sub    $0x10,%esp
  801dbe:	8b 75 08             	mov    0x8(%ebp),%esi
  801dc1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;
  801dc7:	85 c0                	test   %eax,%eax
  801dc9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801dce:	0f 44 c2             	cmove  %edx,%eax
  if ((r = sys_ipc_recv(pg)) < 0) {
  801dd1:	89 04 24             	mov    %eax,(%esp)
  801dd4:	e8 30 f2 ff ff       	call   801009 <sys_ipc_recv>
  801dd9:	85 c0                	test   %eax,%eax
  801ddb:	79 34                	jns    801e11 <ipc_recv+0x5b>
    if (from_env_store)
  801ddd:	85 f6                	test   %esi,%esi
  801ddf:	74 06                	je     801de7 <ipc_recv+0x31>
      *from_env_store = 0;
  801de1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (perm_store)
  801de7:	85 db                	test   %ebx,%ebx
  801de9:	74 06                	je     801df1 <ipc_recv+0x3b>
      *perm_store = 0;
  801deb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    panic("sys_ipc_recv: %e", r);
  801df1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801df5:	c7 44 24 08 67 26 80 	movl   $0x802667,0x8(%esp)
  801dfc:	00 
  801dfd:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801e04:	00 
  801e05:	c7 04 24 78 26 80 00 	movl   $0x802678,(%esp)
  801e0c:	e8 9e e4 ff ff       	call   8002af <_panic>
  }

  if (from_env_store)
  801e11:	85 f6                	test   %esi,%esi
  801e13:	74 0a                	je     801e1f <ipc_recv+0x69>
    *from_env_store = thisenv->env_ipc_from;
  801e15:	a1 04 40 80 00       	mov    0x804004,%eax
  801e1a:	8b 40 74             	mov    0x74(%eax),%eax
  801e1d:	89 06                	mov    %eax,(%esi)
  if (perm_store)
  801e1f:	85 db                	test   %ebx,%ebx
  801e21:	74 0a                	je     801e2d <ipc_recv+0x77>
    *perm_store |= thisenv->env_ipc_perm;
  801e23:	a1 04 40 80 00       	mov    0x804004,%eax
  801e28:	8b 40 78             	mov    0x78(%eax),%eax
  801e2b:	09 03                	or     %eax,(%ebx)

  return thisenv->env_ipc_value;
  801e2d:	a1 04 40 80 00       	mov    0x804004,%eax
  801e32:	8b 40 70             	mov    0x70(%eax),%eax

}
  801e35:	83 c4 10             	add    $0x10,%esp
  801e38:	5b                   	pop    %ebx
  801e39:	5e                   	pop    %esi
  801e3a:	5d                   	pop    %ebp
  801e3b:	c3                   	ret    

00801e3c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e3c:	55                   	push   %ebp
  801e3d:	89 e5                	mov    %esp,%ebp
  801e3f:	57                   	push   %edi
  801e40:	56                   	push   %esi
  801e41:	53                   	push   %ebx
  801e42:	83 ec 1c             	sub    $0x1c,%esp
  801e45:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e48:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;
  801e4e:	85 db                	test   %ebx,%ebx
  801e50:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e55:	0f 44 d8             	cmove  %eax,%ebx

  while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801e58:	eb 2a                	jmp    801e84 <ipc_send+0x48>
    if (r != -E_IPC_NOT_RECV)
  801e5a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e5d:	74 20                	je     801e7f <ipc_send+0x43>
      panic("ipc_send: %e", r);
  801e5f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e63:	c7 44 24 08 82 26 80 	movl   $0x802682,0x8(%esp)
  801e6a:	00 
  801e6b:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801e72:	00 
  801e73:	c7 04 24 78 26 80 00 	movl   $0x802678,(%esp)
  801e7a:	e8 30 e4 ff ff       	call   8002af <_panic>
    sys_yield();
  801e7f:	e8 50 ef ff ff       	call   800dd4 <sys_yield>
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;

  while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801e84:	8b 45 14             	mov    0x14(%ebp),%eax
  801e87:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e8b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e8f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e93:	89 3c 24             	mov    %edi,(%esp)
  801e96:	e8 4b f1 ff ff       	call   800fe6 <sys_ipc_try_send>
  801e9b:	85 c0                	test   %eax,%eax
  801e9d:	78 bb                	js     801e5a <ipc_send+0x1e>
    if (r != -E_IPC_NOT_RECV)
      panic("ipc_send: %e", r);
    sys_yield();
  }
}
  801e9f:	83 c4 1c             	add    $0x1c,%esp
  801ea2:	5b                   	pop    %ebx
  801ea3:	5e                   	pop    %esi
  801ea4:	5f                   	pop    %edi
  801ea5:	5d                   	pop    %ebp
  801ea6:	c3                   	ret    

00801ea7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ea7:	55                   	push   %ebp
  801ea8:	89 e5                	mov    %esp,%ebp
  801eaa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int i;

  for (i = 0; i < NENV; i++)
  801ead:	b8 00 00 00 00       	mov    $0x0,%eax
    if (envs[i].env_type == type)
  801eb2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801eb5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ebb:	8b 52 50             	mov    0x50(%edx),%edx
  801ebe:	39 ca                	cmp    %ecx,%edx
  801ec0:	75 0d                	jne    801ecf <ipc_find_env+0x28>
      return envs[i].env_id;
  801ec2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ec5:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801eca:	8b 40 40             	mov    0x40(%eax),%eax
  801ecd:	eb 0e                	jmp    801edd <ipc_find_env+0x36>
envid_t
ipc_find_env(enum EnvType type)
{
  int i;

  for (i = 0; i < NENV; i++)
  801ecf:	83 c0 01             	add    $0x1,%eax
  801ed2:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ed7:	75 d9                	jne    801eb2 <ipc_find_env+0xb>
    if (envs[i].env_type == type)
      return envs[i].env_id;
  return 0;
  801ed9:	66 b8 00 00          	mov    $0x0,%ax
}
  801edd:	5d                   	pop    %ebp
  801ede:	c3                   	ret    

00801edf <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801edf:	55                   	push   %ebp
  801ee0:	89 e5                	mov    %esp,%ebp
  801ee2:	8b 55 08             	mov    0x8(%ebp),%edx
  pte_t pte;

  if (!(uvpd[PDX(v)] & PTE_P))
  801ee5:	89 d0                	mov    %edx,%eax
  801ee7:	c1 e8 16             	shr    $0x16,%eax
  801eea:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
    return 0;
  801ef1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
  pte_t pte;

  if (!(uvpd[PDX(v)] & PTE_P))
  801ef6:	f6 c1 01             	test   $0x1,%cl
  801ef9:	74 1d                	je     801f18 <pageref+0x39>
    return 0;
  pte = uvpt[PGNUM(v)];
  801efb:	c1 ea 0c             	shr    $0xc,%edx
  801efe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  if (!(pte & PTE_P))
  801f05:	f6 c2 01             	test   $0x1,%dl
  801f08:	74 0e                	je     801f18 <pageref+0x39>
    return 0;
  return pages[PGNUM(pte)].pp_ref;
  801f0a:	c1 ea 0c             	shr    $0xc,%edx
  801f0d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f14:	ef 
  801f15:	0f b7 c0             	movzwl %ax,%eax
}
  801f18:	5d                   	pop    %ebp
  801f19:	c3                   	ret    
  801f1a:	66 90                	xchg   %ax,%ax
  801f1c:	66 90                	xchg   %ax,%ax
  801f1e:	66 90                	xchg   %ax,%ax

00801f20 <__udivdi3>:
  801f20:	55                   	push   %ebp
  801f21:	57                   	push   %edi
  801f22:	56                   	push   %esi
  801f23:	83 ec 0c             	sub    $0xc,%esp
  801f26:	8b 44 24 28          	mov    0x28(%esp),%eax
  801f2a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801f2e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801f32:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801f36:	85 c0                	test   %eax,%eax
  801f38:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f3c:	89 ea                	mov    %ebp,%edx
  801f3e:	89 0c 24             	mov    %ecx,(%esp)
  801f41:	75 2d                	jne    801f70 <__udivdi3+0x50>
  801f43:	39 e9                	cmp    %ebp,%ecx
  801f45:	77 61                	ja     801fa8 <__udivdi3+0x88>
  801f47:	85 c9                	test   %ecx,%ecx
  801f49:	89 ce                	mov    %ecx,%esi
  801f4b:	75 0b                	jne    801f58 <__udivdi3+0x38>
  801f4d:	b8 01 00 00 00       	mov    $0x1,%eax
  801f52:	31 d2                	xor    %edx,%edx
  801f54:	f7 f1                	div    %ecx
  801f56:	89 c6                	mov    %eax,%esi
  801f58:	31 d2                	xor    %edx,%edx
  801f5a:	89 e8                	mov    %ebp,%eax
  801f5c:	f7 f6                	div    %esi
  801f5e:	89 c5                	mov    %eax,%ebp
  801f60:	89 f8                	mov    %edi,%eax
  801f62:	f7 f6                	div    %esi
  801f64:	89 ea                	mov    %ebp,%edx
  801f66:	83 c4 0c             	add    $0xc,%esp
  801f69:	5e                   	pop    %esi
  801f6a:	5f                   	pop    %edi
  801f6b:	5d                   	pop    %ebp
  801f6c:	c3                   	ret    
  801f6d:	8d 76 00             	lea    0x0(%esi),%esi
  801f70:	39 e8                	cmp    %ebp,%eax
  801f72:	77 24                	ja     801f98 <__udivdi3+0x78>
  801f74:	0f bd e8             	bsr    %eax,%ebp
  801f77:	83 f5 1f             	xor    $0x1f,%ebp
  801f7a:	75 3c                	jne    801fb8 <__udivdi3+0x98>
  801f7c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801f80:	39 34 24             	cmp    %esi,(%esp)
  801f83:	0f 86 9f 00 00 00    	jbe    802028 <__udivdi3+0x108>
  801f89:	39 d0                	cmp    %edx,%eax
  801f8b:	0f 82 97 00 00 00    	jb     802028 <__udivdi3+0x108>
  801f91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f98:	31 d2                	xor    %edx,%edx
  801f9a:	31 c0                	xor    %eax,%eax
  801f9c:	83 c4 0c             	add    $0xc,%esp
  801f9f:	5e                   	pop    %esi
  801fa0:	5f                   	pop    %edi
  801fa1:	5d                   	pop    %ebp
  801fa2:	c3                   	ret    
  801fa3:	90                   	nop
  801fa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fa8:	89 f8                	mov    %edi,%eax
  801faa:	f7 f1                	div    %ecx
  801fac:	31 d2                	xor    %edx,%edx
  801fae:	83 c4 0c             	add    $0xc,%esp
  801fb1:	5e                   	pop    %esi
  801fb2:	5f                   	pop    %edi
  801fb3:	5d                   	pop    %ebp
  801fb4:	c3                   	ret    
  801fb5:	8d 76 00             	lea    0x0(%esi),%esi
  801fb8:	89 e9                	mov    %ebp,%ecx
  801fba:	8b 3c 24             	mov    (%esp),%edi
  801fbd:	d3 e0                	shl    %cl,%eax
  801fbf:	89 c6                	mov    %eax,%esi
  801fc1:	b8 20 00 00 00       	mov    $0x20,%eax
  801fc6:	29 e8                	sub    %ebp,%eax
  801fc8:	89 c1                	mov    %eax,%ecx
  801fca:	d3 ef                	shr    %cl,%edi
  801fcc:	89 e9                	mov    %ebp,%ecx
  801fce:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801fd2:	8b 3c 24             	mov    (%esp),%edi
  801fd5:	09 74 24 08          	or     %esi,0x8(%esp)
  801fd9:	89 d6                	mov    %edx,%esi
  801fdb:	d3 e7                	shl    %cl,%edi
  801fdd:	89 c1                	mov    %eax,%ecx
  801fdf:	89 3c 24             	mov    %edi,(%esp)
  801fe2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801fe6:	d3 ee                	shr    %cl,%esi
  801fe8:	89 e9                	mov    %ebp,%ecx
  801fea:	d3 e2                	shl    %cl,%edx
  801fec:	89 c1                	mov    %eax,%ecx
  801fee:	d3 ef                	shr    %cl,%edi
  801ff0:	09 d7                	or     %edx,%edi
  801ff2:	89 f2                	mov    %esi,%edx
  801ff4:	89 f8                	mov    %edi,%eax
  801ff6:	f7 74 24 08          	divl   0x8(%esp)
  801ffa:	89 d6                	mov    %edx,%esi
  801ffc:	89 c7                	mov    %eax,%edi
  801ffe:	f7 24 24             	mull   (%esp)
  802001:	39 d6                	cmp    %edx,%esi
  802003:	89 14 24             	mov    %edx,(%esp)
  802006:	72 30                	jb     802038 <__udivdi3+0x118>
  802008:	8b 54 24 04          	mov    0x4(%esp),%edx
  80200c:	89 e9                	mov    %ebp,%ecx
  80200e:	d3 e2                	shl    %cl,%edx
  802010:	39 c2                	cmp    %eax,%edx
  802012:	73 05                	jae    802019 <__udivdi3+0xf9>
  802014:	3b 34 24             	cmp    (%esp),%esi
  802017:	74 1f                	je     802038 <__udivdi3+0x118>
  802019:	89 f8                	mov    %edi,%eax
  80201b:	31 d2                	xor    %edx,%edx
  80201d:	e9 7a ff ff ff       	jmp    801f9c <__udivdi3+0x7c>
  802022:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802028:	31 d2                	xor    %edx,%edx
  80202a:	b8 01 00 00 00       	mov    $0x1,%eax
  80202f:	e9 68 ff ff ff       	jmp    801f9c <__udivdi3+0x7c>
  802034:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802038:	8d 47 ff             	lea    -0x1(%edi),%eax
  80203b:	31 d2                	xor    %edx,%edx
  80203d:	83 c4 0c             	add    $0xc,%esp
  802040:	5e                   	pop    %esi
  802041:	5f                   	pop    %edi
  802042:	5d                   	pop    %ebp
  802043:	c3                   	ret    
  802044:	66 90                	xchg   %ax,%ax
  802046:	66 90                	xchg   %ax,%ax
  802048:	66 90                	xchg   %ax,%ax
  80204a:	66 90                	xchg   %ax,%ax
  80204c:	66 90                	xchg   %ax,%ax
  80204e:	66 90                	xchg   %ax,%ax

00802050 <__umoddi3>:
  802050:	55                   	push   %ebp
  802051:	57                   	push   %edi
  802052:	56                   	push   %esi
  802053:	83 ec 14             	sub    $0x14,%esp
  802056:	8b 44 24 28          	mov    0x28(%esp),%eax
  80205a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80205e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802062:	89 c7                	mov    %eax,%edi
  802064:	89 44 24 04          	mov    %eax,0x4(%esp)
  802068:	8b 44 24 30          	mov    0x30(%esp),%eax
  80206c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802070:	89 34 24             	mov    %esi,(%esp)
  802073:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802077:	85 c0                	test   %eax,%eax
  802079:	89 c2                	mov    %eax,%edx
  80207b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80207f:	75 17                	jne    802098 <__umoddi3+0x48>
  802081:	39 fe                	cmp    %edi,%esi
  802083:	76 4b                	jbe    8020d0 <__umoddi3+0x80>
  802085:	89 c8                	mov    %ecx,%eax
  802087:	89 fa                	mov    %edi,%edx
  802089:	f7 f6                	div    %esi
  80208b:	89 d0                	mov    %edx,%eax
  80208d:	31 d2                	xor    %edx,%edx
  80208f:	83 c4 14             	add    $0x14,%esp
  802092:	5e                   	pop    %esi
  802093:	5f                   	pop    %edi
  802094:	5d                   	pop    %ebp
  802095:	c3                   	ret    
  802096:	66 90                	xchg   %ax,%ax
  802098:	39 f8                	cmp    %edi,%eax
  80209a:	77 54                	ja     8020f0 <__umoddi3+0xa0>
  80209c:	0f bd e8             	bsr    %eax,%ebp
  80209f:	83 f5 1f             	xor    $0x1f,%ebp
  8020a2:	75 5c                	jne    802100 <__umoddi3+0xb0>
  8020a4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8020a8:	39 3c 24             	cmp    %edi,(%esp)
  8020ab:	0f 87 e7 00 00 00    	ja     802198 <__umoddi3+0x148>
  8020b1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8020b5:	29 f1                	sub    %esi,%ecx
  8020b7:	19 c7                	sbb    %eax,%edi
  8020b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020bd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8020c1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020c5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8020c9:	83 c4 14             	add    $0x14,%esp
  8020cc:	5e                   	pop    %esi
  8020cd:	5f                   	pop    %edi
  8020ce:	5d                   	pop    %ebp
  8020cf:	c3                   	ret    
  8020d0:	85 f6                	test   %esi,%esi
  8020d2:	89 f5                	mov    %esi,%ebp
  8020d4:	75 0b                	jne    8020e1 <__umoddi3+0x91>
  8020d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020db:	31 d2                	xor    %edx,%edx
  8020dd:	f7 f6                	div    %esi
  8020df:	89 c5                	mov    %eax,%ebp
  8020e1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8020e5:	31 d2                	xor    %edx,%edx
  8020e7:	f7 f5                	div    %ebp
  8020e9:	89 c8                	mov    %ecx,%eax
  8020eb:	f7 f5                	div    %ebp
  8020ed:	eb 9c                	jmp    80208b <__umoddi3+0x3b>
  8020ef:	90                   	nop
  8020f0:	89 c8                	mov    %ecx,%eax
  8020f2:	89 fa                	mov    %edi,%edx
  8020f4:	83 c4 14             	add    $0x14,%esp
  8020f7:	5e                   	pop    %esi
  8020f8:	5f                   	pop    %edi
  8020f9:	5d                   	pop    %ebp
  8020fa:	c3                   	ret    
  8020fb:	90                   	nop
  8020fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802100:	8b 04 24             	mov    (%esp),%eax
  802103:	be 20 00 00 00       	mov    $0x20,%esi
  802108:	89 e9                	mov    %ebp,%ecx
  80210a:	29 ee                	sub    %ebp,%esi
  80210c:	d3 e2                	shl    %cl,%edx
  80210e:	89 f1                	mov    %esi,%ecx
  802110:	d3 e8                	shr    %cl,%eax
  802112:	89 e9                	mov    %ebp,%ecx
  802114:	89 44 24 04          	mov    %eax,0x4(%esp)
  802118:	8b 04 24             	mov    (%esp),%eax
  80211b:	09 54 24 04          	or     %edx,0x4(%esp)
  80211f:	89 fa                	mov    %edi,%edx
  802121:	d3 e0                	shl    %cl,%eax
  802123:	89 f1                	mov    %esi,%ecx
  802125:	89 44 24 08          	mov    %eax,0x8(%esp)
  802129:	8b 44 24 10          	mov    0x10(%esp),%eax
  80212d:	d3 ea                	shr    %cl,%edx
  80212f:	89 e9                	mov    %ebp,%ecx
  802131:	d3 e7                	shl    %cl,%edi
  802133:	89 f1                	mov    %esi,%ecx
  802135:	d3 e8                	shr    %cl,%eax
  802137:	89 e9                	mov    %ebp,%ecx
  802139:	09 f8                	or     %edi,%eax
  80213b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80213f:	f7 74 24 04          	divl   0x4(%esp)
  802143:	d3 e7                	shl    %cl,%edi
  802145:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802149:	89 d7                	mov    %edx,%edi
  80214b:	f7 64 24 08          	mull   0x8(%esp)
  80214f:	39 d7                	cmp    %edx,%edi
  802151:	89 c1                	mov    %eax,%ecx
  802153:	89 14 24             	mov    %edx,(%esp)
  802156:	72 2c                	jb     802184 <__umoddi3+0x134>
  802158:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80215c:	72 22                	jb     802180 <__umoddi3+0x130>
  80215e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802162:	29 c8                	sub    %ecx,%eax
  802164:	19 d7                	sbb    %edx,%edi
  802166:	89 e9                	mov    %ebp,%ecx
  802168:	89 fa                	mov    %edi,%edx
  80216a:	d3 e8                	shr    %cl,%eax
  80216c:	89 f1                	mov    %esi,%ecx
  80216e:	d3 e2                	shl    %cl,%edx
  802170:	89 e9                	mov    %ebp,%ecx
  802172:	d3 ef                	shr    %cl,%edi
  802174:	09 d0                	or     %edx,%eax
  802176:	89 fa                	mov    %edi,%edx
  802178:	83 c4 14             	add    $0x14,%esp
  80217b:	5e                   	pop    %esi
  80217c:	5f                   	pop    %edi
  80217d:	5d                   	pop    %ebp
  80217e:	c3                   	ret    
  80217f:	90                   	nop
  802180:	39 d7                	cmp    %edx,%edi
  802182:	75 da                	jne    80215e <__umoddi3+0x10e>
  802184:	8b 14 24             	mov    (%esp),%edx
  802187:	89 c1                	mov    %eax,%ecx
  802189:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80218d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802191:	eb cb                	jmp    80215e <__umoddi3+0x10e>
  802193:	90                   	nop
  802194:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802198:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80219c:	0f 82 0f ff ff ff    	jb     8020b1 <__umoddi3+0x61>
  8021a2:	e9 1a ff ff ff       	jmp    8020c1 <__umoddi3+0x71>
