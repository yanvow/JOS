
obj/user/faultregs.debug:     file format elf32-i386


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
  80002c:	e8 64 05 00 00       	call   800595 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
           const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
  int mismatch = 0;

  cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	8b 45 08             	mov    0x8(%ebp),%eax
  800043:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800047:	89 54 24 08          	mov    %edx,0x8(%esp)
  80004b:	c7 44 24 04 d1 25 80 	movl   $0x8025d1,0x4(%esp)
  800052:	00 
  800053:	c7 04 24 a0 25 80 00 	movl   $0x8025a0,(%esp)
  80005a:	e8 90 06 00 00       	call   8006ef <cprintf>
      cprintf("MISMATCH\n");                          \
      mismatch = 1;                                   \
    }                                                       \
  } while (0)

  CHECK(edi, regs.reg_edi);
  80005f:	8b 03                	mov    (%ebx),%eax
  800061:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800065:	8b 06                	mov    (%esi),%eax
  800067:	89 44 24 08          	mov    %eax,0x8(%esp)
  80006b:	c7 44 24 04 b0 25 80 	movl   $0x8025b0,0x4(%esp)
  800072:	00 
  800073:	c7 04 24 b4 25 80 00 	movl   $0x8025b4,(%esp)
  80007a:	e8 70 06 00 00       	call   8006ef <cprintf>
  80007f:	8b 03                	mov    (%ebx),%eax
  800081:	39 06                	cmp    %eax,(%esi)
  800083:	75 13                	jne    800098 <check_regs+0x65>
  800085:	c7 04 24 c4 25 80 00 	movl   $0x8025c4,(%esp)
  80008c:	e8 5e 06 00 00       	call   8006ef <cprintf>

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
           const char *testname)
{
  int mismatch = 0;
  800091:	bf 00 00 00 00       	mov    $0x0,%edi
  800096:	eb 11                	jmp    8000a9 <check_regs+0x76>
      cprintf("MISMATCH\n");                          \
      mismatch = 1;                                   \
    }                                                       \
  } while (0)

  CHECK(edi, regs.reg_edi);
  800098:	c7 04 24 c8 25 80 00 	movl   $0x8025c8,(%esp)
  80009f:	e8 4b 06 00 00       	call   8006ef <cprintf>
  8000a4:	bf 01 00 00 00       	mov    $0x1,%edi
  CHECK(esi, regs.reg_esi);
  8000a9:	8b 43 04             	mov    0x4(%ebx),%eax
  8000ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b0:	8b 46 04             	mov    0x4(%esi),%eax
  8000b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b7:	c7 44 24 04 d2 25 80 	movl   $0x8025d2,0x4(%esp)
  8000be:	00 
  8000bf:	c7 04 24 b4 25 80 00 	movl   $0x8025b4,(%esp)
  8000c6:	e8 24 06 00 00       	call   8006ef <cprintf>
  8000cb:	8b 43 04             	mov    0x4(%ebx),%eax
  8000ce:	39 46 04             	cmp    %eax,0x4(%esi)
  8000d1:	75 0e                	jne    8000e1 <check_regs+0xae>
  8000d3:	c7 04 24 c4 25 80 00 	movl   $0x8025c4,(%esp)
  8000da:	e8 10 06 00 00       	call   8006ef <cprintf>
  8000df:	eb 11                	jmp    8000f2 <check_regs+0xbf>
  8000e1:	c7 04 24 c8 25 80 00 	movl   $0x8025c8,(%esp)
  8000e8:	e8 02 06 00 00       	call   8006ef <cprintf>
  8000ed:	bf 01 00 00 00       	mov    $0x1,%edi
  CHECK(ebp, regs.reg_ebp);
  8000f2:	8b 43 08             	mov    0x8(%ebx),%eax
  8000f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f9:	8b 46 08             	mov    0x8(%esi),%eax
  8000fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800100:	c7 44 24 04 d6 25 80 	movl   $0x8025d6,0x4(%esp)
  800107:	00 
  800108:	c7 04 24 b4 25 80 00 	movl   $0x8025b4,(%esp)
  80010f:	e8 db 05 00 00       	call   8006ef <cprintf>
  800114:	8b 43 08             	mov    0x8(%ebx),%eax
  800117:	39 46 08             	cmp    %eax,0x8(%esi)
  80011a:	75 0e                	jne    80012a <check_regs+0xf7>
  80011c:	c7 04 24 c4 25 80 00 	movl   $0x8025c4,(%esp)
  800123:	e8 c7 05 00 00       	call   8006ef <cprintf>
  800128:	eb 11                	jmp    80013b <check_regs+0x108>
  80012a:	c7 04 24 c8 25 80 00 	movl   $0x8025c8,(%esp)
  800131:	e8 b9 05 00 00       	call   8006ef <cprintf>
  800136:	bf 01 00 00 00       	mov    $0x1,%edi
  CHECK(ebx, regs.reg_ebx);
  80013b:	8b 43 10             	mov    0x10(%ebx),%eax
  80013e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800142:	8b 46 10             	mov    0x10(%esi),%eax
  800145:	89 44 24 08          	mov    %eax,0x8(%esp)
  800149:	c7 44 24 04 da 25 80 	movl   $0x8025da,0x4(%esp)
  800150:	00 
  800151:	c7 04 24 b4 25 80 00 	movl   $0x8025b4,(%esp)
  800158:	e8 92 05 00 00       	call   8006ef <cprintf>
  80015d:	8b 43 10             	mov    0x10(%ebx),%eax
  800160:	39 46 10             	cmp    %eax,0x10(%esi)
  800163:	75 0e                	jne    800173 <check_regs+0x140>
  800165:	c7 04 24 c4 25 80 00 	movl   $0x8025c4,(%esp)
  80016c:	e8 7e 05 00 00       	call   8006ef <cprintf>
  800171:	eb 11                	jmp    800184 <check_regs+0x151>
  800173:	c7 04 24 c8 25 80 00 	movl   $0x8025c8,(%esp)
  80017a:	e8 70 05 00 00       	call   8006ef <cprintf>
  80017f:	bf 01 00 00 00       	mov    $0x1,%edi
  CHECK(edx, regs.reg_edx);
  800184:	8b 43 14             	mov    0x14(%ebx),%eax
  800187:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018b:	8b 46 14             	mov    0x14(%esi),%eax
  80018e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800192:	c7 44 24 04 de 25 80 	movl   $0x8025de,0x4(%esp)
  800199:	00 
  80019a:	c7 04 24 b4 25 80 00 	movl   $0x8025b4,(%esp)
  8001a1:	e8 49 05 00 00       	call   8006ef <cprintf>
  8001a6:	8b 43 14             	mov    0x14(%ebx),%eax
  8001a9:	39 46 14             	cmp    %eax,0x14(%esi)
  8001ac:	75 0e                	jne    8001bc <check_regs+0x189>
  8001ae:	c7 04 24 c4 25 80 00 	movl   $0x8025c4,(%esp)
  8001b5:	e8 35 05 00 00       	call   8006ef <cprintf>
  8001ba:	eb 11                	jmp    8001cd <check_regs+0x19a>
  8001bc:	c7 04 24 c8 25 80 00 	movl   $0x8025c8,(%esp)
  8001c3:	e8 27 05 00 00       	call   8006ef <cprintf>
  8001c8:	bf 01 00 00 00       	mov    $0x1,%edi
  CHECK(ecx, regs.reg_ecx);
  8001cd:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d4:	8b 46 18             	mov    0x18(%esi),%eax
  8001d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001db:	c7 44 24 04 e2 25 80 	movl   $0x8025e2,0x4(%esp)
  8001e2:	00 
  8001e3:	c7 04 24 b4 25 80 00 	movl   $0x8025b4,(%esp)
  8001ea:	e8 00 05 00 00       	call   8006ef <cprintf>
  8001ef:	8b 43 18             	mov    0x18(%ebx),%eax
  8001f2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001f5:	75 0e                	jne    800205 <check_regs+0x1d2>
  8001f7:	c7 04 24 c4 25 80 00 	movl   $0x8025c4,(%esp)
  8001fe:	e8 ec 04 00 00       	call   8006ef <cprintf>
  800203:	eb 11                	jmp    800216 <check_regs+0x1e3>
  800205:	c7 04 24 c8 25 80 00 	movl   $0x8025c8,(%esp)
  80020c:	e8 de 04 00 00       	call   8006ef <cprintf>
  800211:	bf 01 00 00 00       	mov    $0x1,%edi
  CHECK(eax, regs.reg_eax);
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021d:	8b 46 1c             	mov    0x1c(%esi),%eax
  800220:	89 44 24 08          	mov    %eax,0x8(%esp)
  800224:	c7 44 24 04 e6 25 80 	movl   $0x8025e6,0x4(%esp)
  80022b:	00 
  80022c:	c7 04 24 b4 25 80 00 	movl   $0x8025b4,(%esp)
  800233:	e8 b7 04 00 00       	call   8006ef <cprintf>
  800238:	8b 43 1c             	mov    0x1c(%ebx),%eax
  80023b:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80023e:	75 0e                	jne    80024e <check_regs+0x21b>
  800240:	c7 04 24 c4 25 80 00 	movl   $0x8025c4,(%esp)
  800247:	e8 a3 04 00 00       	call   8006ef <cprintf>
  80024c:	eb 11                	jmp    80025f <check_regs+0x22c>
  80024e:	c7 04 24 c8 25 80 00 	movl   $0x8025c8,(%esp)
  800255:	e8 95 04 00 00       	call   8006ef <cprintf>
  80025a:	bf 01 00 00 00       	mov    $0x1,%edi
  CHECK(eip, eip);
  80025f:	8b 43 20             	mov    0x20(%ebx),%eax
  800262:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800266:	8b 46 20             	mov    0x20(%esi),%eax
  800269:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026d:	c7 44 24 04 ea 25 80 	movl   $0x8025ea,0x4(%esp)
  800274:	00 
  800275:	c7 04 24 b4 25 80 00 	movl   $0x8025b4,(%esp)
  80027c:	e8 6e 04 00 00       	call   8006ef <cprintf>
  800281:	8b 43 20             	mov    0x20(%ebx),%eax
  800284:	39 46 20             	cmp    %eax,0x20(%esi)
  800287:	75 0e                	jne    800297 <check_regs+0x264>
  800289:	c7 04 24 c4 25 80 00 	movl   $0x8025c4,(%esp)
  800290:	e8 5a 04 00 00       	call   8006ef <cprintf>
  800295:	eb 11                	jmp    8002a8 <check_regs+0x275>
  800297:	c7 04 24 c8 25 80 00 	movl   $0x8025c8,(%esp)
  80029e:	e8 4c 04 00 00       	call   8006ef <cprintf>
  8002a3:	bf 01 00 00 00       	mov    $0x1,%edi
  CHECK(eflags, eflags);
  8002a8:	8b 43 24             	mov    0x24(%ebx),%eax
  8002ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002af:	8b 46 24             	mov    0x24(%esi),%eax
  8002b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b6:	c7 44 24 04 ee 25 80 	movl   $0x8025ee,0x4(%esp)
  8002bd:	00 
  8002be:	c7 04 24 b4 25 80 00 	movl   $0x8025b4,(%esp)
  8002c5:	e8 25 04 00 00       	call   8006ef <cprintf>
  8002ca:	8b 43 24             	mov    0x24(%ebx),%eax
  8002cd:	39 46 24             	cmp    %eax,0x24(%esi)
  8002d0:	75 0e                	jne    8002e0 <check_regs+0x2ad>
  8002d2:	c7 04 24 c4 25 80 00 	movl   $0x8025c4,(%esp)
  8002d9:	e8 11 04 00 00       	call   8006ef <cprintf>
  8002de:	eb 11                	jmp    8002f1 <check_regs+0x2be>
  8002e0:	c7 04 24 c8 25 80 00 	movl   $0x8025c8,(%esp)
  8002e7:	e8 03 04 00 00       	call   8006ef <cprintf>
  8002ec:	bf 01 00 00 00       	mov    $0x1,%edi
  CHECK(esp, esp);
  8002f1:	8b 43 28             	mov    0x28(%ebx),%eax
  8002f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f8:	8b 46 28             	mov    0x28(%esi),%eax
  8002fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ff:	c7 44 24 04 f5 25 80 	movl   $0x8025f5,0x4(%esp)
  800306:	00 
  800307:	c7 04 24 b4 25 80 00 	movl   $0x8025b4,(%esp)
  80030e:	e8 dc 03 00 00       	call   8006ef <cprintf>
  800313:	8b 43 28             	mov    0x28(%ebx),%eax
  800316:	39 46 28             	cmp    %eax,0x28(%esi)
  800319:	75 25                	jne    800340 <check_regs+0x30d>
  80031b:	c7 04 24 c4 25 80 00 	movl   $0x8025c4,(%esp)
  800322:	e8 c8 03 00 00       	call   8006ef <cprintf>

#undef CHECK

  cprintf("Registers %s ", testname);
  800327:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032e:	c7 04 24 f9 25 80 00 	movl   $0x8025f9,(%esp)
  800335:	e8 b5 03 00 00       	call   8006ef <cprintf>
  if (!mismatch)
  80033a:	85 ff                	test   %edi,%edi
  80033c:	74 23                	je     800361 <check_regs+0x32e>
  80033e:	eb 2f                	jmp    80036f <check_regs+0x33c>
  CHECK(edx, regs.reg_edx);
  CHECK(ecx, regs.reg_ecx);
  CHECK(eax, regs.reg_eax);
  CHECK(eip, eip);
  CHECK(eflags, eflags);
  CHECK(esp, esp);
  800340:	c7 04 24 c8 25 80 00 	movl   $0x8025c8,(%esp)
  800347:	e8 a3 03 00 00       	call   8006ef <cprintf>

#undef CHECK

  cprintf("Registers %s ", testname);
  80034c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80034f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800353:	c7 04 24 f9 25 80 00 	movl   $0x8025f9,(%esp)
  80035a:	e8 90 03 00 00       	call   8006ef <cprintf>
  80035f:	eb 0e                	jmp    80036f <check_regs+0x33c>
  if (!mismatch)
    cprintf("OK\n");
  800361:	c7 04 24 c4 25 80 00 	movl   $0x8025c4,(%esp)
  800368:	e8 82 03 00 00       	call   8006ef <cprintf>
  80036d:	eb 0c                	jmp    80037b <check_regs+0x348>
  else
    cprintf("MISMATCH\n");
  80036f:	c7 04 24 c8 25 80 00 	movl   $0x8025c8,(%esp)
  800376:	e8 74 03 00 00       	call   8006ef <cprintf>
}
  80037b:	83 c4 1c             	add    $0x1c,%esp
  80037e:	5b                   	pop    %ebx
  80037f:	5e                   	pop    %esi
  800380:	5f                   	pop    %edi
  800381:	5d                   	pop    %ebp
  800382:	c3                   	ret    

00800383 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
  800386:	83 ec 28             	sub    $0x28,%esp
  800389:	8b 45 08             	mov    0x8(%ebp),%eax
  int r;

  if (utf->utf_fault_va != (uint32_t)UTEMP)
  80038c:	8b 10                	mov    (%eax),%edx
  80038e:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  800394:	74 27                	je     8003bd <pgfault+0x3a>
    panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  800396:	8b 40 28             	mov    0x28(%eax),%eax
  800399:	89 44 24 10          	mov    %eax,0x10(%esp)
  80039d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a1:	c7 44 24 08 60 26 80 	movl   $0x802660,0x8(%esp)
  8003a8:	00 
  8003a9:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  8003b0:	00 
  8003b1:	c7 04 24 07 26 80 00 	movl   $0x802607,(%esp)
  8003b8:	e8 39 02 00 00       	call   8005f6 <_panic>
          utf->utf_fault_va, utf->utf_eip);

  // Check registers in UTrapframe
  during.regs = utf->utf_regs;
  8003bd:	8b 50 08             	mov    0x8(%eax),%edx
  8003c0:	89 15 40 40 80 00    	mov    %edx,0x804040
  8003c6:	8b 50 0c             	mov    0xc(%eax),%edx
  8003c9:	89 15 44 40 80 00    	mov    %edx,0x804044
  8003cf:	8b 50 10             	mov    0x10(%eax),%edx
  8003d2:	89 15 48 40 80 00    	mov    %edx,0x804048
  8003d8:	8b 50 14             	mov    0x14(%eax),%edx
  8003db:	89 15 4c 40 80 00    	mov    %edx,0x80404c
  8003e1:	8b 50 18             	mov    0x18(%eax),%edx
  8003e4:	89 15 50 40 80 00    	mov    %edx,0x804050
  8003ea:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003ed:	89 15 54 40 80 00    	mov    %edx,0x804054
  8003f3:	8b 50 20             	mov    0x20(%eax),%edx
  8003f6:	89 15 58 40 80 00    	mov    %edx,0x804058
  8003fc:	8b 50 24             	mov    0x24(%eax),%edx
  8003ff:	89 15 5c 40 80 00    	mov    %edx,0x80405c
  during.eip = utf->utf_eip;
  800405:	8b 50 28             	mov    0x28(%eax),%edx
  800408:	89 15 60 40 80 00    	mov    %edx,0x804060
  during.eflags = utf->utf_eflags;
  80040e:	8b 50 2c             	mov    0x2c(%eax),%edx
  800411:	89 15 64 40 80 00    	mov    %edx,0x804064
  during.esp = utf->utf_esp;
  800417:	8b 40 30             	mov    0x30(%eax),%eax
  80041a:	a3 68 40 80 00       	mov    %eax,0x804068
  check_regs(&before, "before", &during, "during", "in UTrapframe");
  80041f:	c7 44 24 04 1f 26 80 	movl   $0x80261f,0x4(%esp)
  800426:	00 
  800427:	c7 04 24 2d 26 80 00 	movl   $0x80262d,(%esp)
  80042e:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800433:	ba 18 26 80 00       	mov    $0x802618,%edx
  800438:	b8 80 40 80 00       	mov    $0x804080,%eax
  80043d:	e8 f1 fb ff ff       	call   800033 <check_regs>

  // Map UTEMP so the write succeeds
  if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800442:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800449:	00 
  80044a:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  800451:	00 
  800452:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800459:	e8 d5 0c 00 00       	call   801133 <sys_page_alloc>
  80045e:	85 c0                	test   %eax,%eax
  800460:	79 20                	jns    800482 <pgfault+0xff>
    panic("sys_page_alloc: %e", r);
  800462:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800466:	c7 44 24 08 34 26 80 	movl   $0x802634,0x8(%esp)
  80046d:	00 
  80046e:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  800475:	00 
  800476:	c7 04 24 07 26 80 00 	movl   $0x802607,(%esp)
  80047d:	e8 74 01 00 00       	call   8005f6 <_panic>
}
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <umain>:

void
umain(int argc, char **argv)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	83 ec 18             	sub    $0x18,%esp
  set_pgfault_handler(pgfault);
  80048a:	c7 04 24 83 03 80 00 	movl   $0x800383,(%esp)
  800491:	e8 05 0f 00 00       	call   80139b <set_pgfault_handler>

  __asm __volatile(
  800496:	50                   	push   %eax
  800497:	9c                   	pushf  
  800498:	58                   	pop    %eax
  800499:	0d d5 08 00 00       	or     $0x8d5,%eax
  80049e:	50                   	push   %eax
  80049f:	9d                   	popf   
  8004a0:	a3 a4 40 80 00       	mov    %eax,0x8040a4
  8004a5:	8d 05 e0 04 80 00    	lea    0x8004e0,%eax
  8004ab:	a3 a0 40 80 00       	mov    %eax,0x8040a0
  8004b0:	58                   	pop    %eax
  8004b1:	89 3d 80 40 80 00    	mov    %edi,0x804080
  8004b7:	89 35 84 40 80 00    	mov    %esi,0x804084
  8004bd:	89 2d 88 40 80 00    	mov    %ebp,0x804088
  8004c3:	89 1d 90 40 80 00    	mov    %ebx,0x804090
  8004c9:	89 15 94 40 80 00    	mov    %edx,0x804094
  8004cf:	89 0d 98 40 80 00    	mov    %ecx,0x804098
  8004d5:	a3 9c 40 80 00       	mov    %eax,0x80409c
  8004da:	89 25 a8 40 80 00    	mov    %esp,0x8040a8
  8004e0:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004e7:	00 00 00 
  8004ea:	89 3d 00 40 80 00    	mov    %edi,0x804000
  8004f0:	89 35 04 40 80 00    	mov    %esi,0x804004
  8004f6:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  8004fc:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  800502:	89 15 14 40 80 00    	mov    %edx,0x804014
  800508:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  80050e:	a3 1c 40 80 00       	mov    %eax,0x80401c
  800513:	89 25 28 40 80 00    	mov    %esp,0x804028
  800519:	8b 3d 80 40 80 00    	mov    0x804080,%edi
  80051f:	8b 35 84 40 80 00    	mov    0x804084,%esi
  800525:	8b 2d 88 40 80 00    	mov    0x804088,%ebp
  80052b:	8b 1d 90 40 80 00    	mov    0x804090,%ebx
  800531:	8b 15 94 40 80 00    	mov    0x804094,%edx
  800537:	8b 0d 98 40 80 00    	mov    0x804098,%ecx
  80053d:	a1 9c 40 80 00       	mov    0x80409c,%eax
  800542:	8b 25 a8 40 80 00    	mov    0x8040a8,%esp
  800548:	50                   	push   %eax
  800549:	9c                   	pushf  
  80054a:	58                   	pop    %eax
  80054b:	a3 24 40 80 00       	mov    %eax,0x804024
  800550:	58                   	pop    %eax
    : : "m" (before), "m" (after) : "memory", "cc");

  // Check UTEMP to roughly determine that EIP was restored
  // correctly (of course, we probably wouldn't get this far if
  // it weren't)
  if (*(int*)UTEMP != 42)
  800551:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800558:	74 0c                	je     800566 <umain+0xe2>
    cprintf("EIP after page-fault MISMATCH\n");
  80055a:	c7 04 24 94 26 80 00 	movl   $0x802694,(%esp)
  800561:	e8 89 01 00 00       	call   8006ef <cprintf>
  after.eip = before.eip;
  800566:	a1 a0 40 80 00       	mov    0x8040a0,%eax
  80056b:	a3 20 40 80 00       	mov    %eax,0x804020

  check_regs(&before, "before", &after, "after", "after page-fault");
  800570:	c7 44 24 04 47 26 80 	movl   $0x802647,0x4(%esp)
  800577:	00 
  800578:	c7 04 24 58 26 80 00 	movl   $0x802658,(%esp)
  80057f:	b9 00 40 80 00       	mov    $0x804000,%ecx
  800584:	ba 18 26 80 00       	mov    $0x802618,%edx
  800589:	b8 80 40 80 00       	mov    $0x804080,%eax
  80058e:	e8 a0 fa ff ff       	call   800033 <check_regs>
}
  800593:	c9                   	leave  
  800594:	c3                   	ret    

00800595 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800595:	55                   	push   %ebp
  800596:	89 e5                	mov    %esp,%ebp
  800598:	56                   	push   %esi
  800599:	53                   	push   %ebx
  80059a:	83 ec 10             	sub    $0x10,%esp
  80059d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005a0:	8b 75 0c             	mov    0xc(%ebp),%esi
  // set thisenv to point at our Env structure in envs[].
  // LAB 3: Your code here.
  thisenv = envs + ENVX(sys_getenvid());
  8005a3:	e8 4d 0b 00 00       	call   8010f5 <sys_getenvid>
  8005a8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005ad:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005b0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005b5:	a3 b0 40 80 00       	mov    %eax,0x8040b0

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8005ba:	85 db                	test   %ebx,%ebx
  8005bc:	7e 07                	jle    8005c5 <libmain+0x30>
    binaryname = argv[0];
  8005be:	8b 06                	mov    (%esi),%eax
  8005c0:	a3 00 30 80 00       	mov    %eax,0x803000

  // call user main routine
  umain(argc, argv);
  8005c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005c9:	89 1c 24             	mov    %ebx,(%esp)
  8005cc:	e8 b3 fe ff ff       	call   800484 <umain>

  // exit gracefully
  exit();
  8005d1:	e8 07 00 00 00       	call   8005dd <exit>
}
  8005d6:	83 c4 10             	add    $0x10,%esp
  8005d9:	5b                   	pop    %ebx
  8005da:	5e                   	pop    %esi
  8005db:	5d                   	pop    %ebp
  8005dc:	c3                   	ret    

008005dd <exit>:
#include <inc/lib.h>

void
exit(void)
{
  8005dd:	55                   	push   %ebp
  8005de:	89 e5                	mov    %esp,%ebp
  8005e0:	83 ec 18             	sub    $0x18,%esp
  close_all();
  8005e3:	e8 3d 10 00 00       	call   801625 <close_all>
  sys_env_destroy(0);
  8005e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005ef:	e8 af 0a 00 00       	call   8010a3 <sys_env_destroy>
}
  8005f4:	c9                   	leave  
  8005f5:	c3                   	ret    

008005f6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005f6:	55                   	push   %ebp
  8005f7:	89 e5                	mov    %esp,%ebp
  8005f9:	56                   	push   %esi
  8005fa:	53                   	push   %ebx
  8005fb:	83 ec 20             	sub    $0x20,%esp
  va_list ap;

  va_start(ap, fmt);
  8005fe:	8d 5d 14             	lea    0x14(%ebp),%ebx

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  800601:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800607:	e8 e9 0a 00 00       	call   8010f5 <sys_getenvid>
  80060c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80060f:	89 54 24 10          	mov    %edx,0x10(%esp)
  800613:	8b 55 08             	mov    0x8(%ebp),%edx
  800616:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80061a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80061e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800622:	c7 04 24 c0 26 80 00 	movl   $0x8026c0,(%esp)
  800629:	e8 c1 00 00 00       	call   8006ef <cprintf>
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  80062e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800632:	8b 45 10             	mov    0x10(%ebp),%eax
  800635:	89 04 24             	mov    %eax,(%esp)
  800638:	e8 51 00 00 00       	call   80068e <vcprintf>
  cprintf("\n");
  80063d:	c7 04 24 d0 25 80 00 	movl   $0x8025d0,(%esp)
  800644:	e8 a6 00 00 00       	call   8006ef <cprintf>

  // Cause a breakpoint exception
  while (1)
    asm volatile ("int3");
  800649:	cc                   	int3   
  80064a:	eb fd                	jmp    800649 <_panic+0x53>

0080064c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80064c:	55                   	push   %ebp
  80064d:	89 e5                	mov    %esp,%ebp
  80064f:	53                   	push   %ebx
  800650:	83 ec 14             	sub    $0x14,%esp
  800653:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  b->buf[b->idx++] = ch;
  800656:	8b 13                	mov    (%ebx),%edx
  800658:	8d 42 01             	lea    0x1(%edx),%eax
  80065b:	89 03                	mov    %eax,(%ebx)
  80065d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800660:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
  if (b->idx == 256-1) {
  800664:	3d ff 00 00 00       	cmp    $0xff,%eax
  800669:	75 19                	jne    800684 <putch+0x38>
    sys_cputs(b->buf, b->idx);
  80066b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800672:	00 
  800673:	8d 43 08             	lea    0x8(%ebx),%eax
  800676:	89 04 24             	mov    %eax,(%esp)
  800679:	e8 e8 09 00 00       	call   801066 <sys_cputs>
    b->idx = 0;
  80067e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  }
  b->cnt++;
  800684:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800688:	83 c4 14             	add    $0x14,%esp
  80068b:	5b                   	pop    %ebx
  80068c:	5d                   	pop    %ebp
  80068d:	c3                   	ret    

0080068e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80068e:	55                   	push   %ebp
  80068f:	89 e5                	mov    %esp,%ebp
  800691:	81 ec 28 01 00 00    	sub    $0x128,%esp
  struct printbuf b;

  b.idx = 0;
  800697:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80069e:	00 00 00 
  b.cnt = 0;
  8006a1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006a8:	00 00 00 
  vprintfmt((void*)putch, &b, fmt, ap);
  8006ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006b9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c3:	c7 04 24 4c 06 80 00 	movl   $0x80064c,(%esp)
  8006ca:	e8 af 01 00 00       	call   80087e <vprintfmt>
  sys_cputs(b.buf, b.idx);
  8006cf:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8006d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006df:	89 04 24             	mov    %eax,(%esp)
  8006e2:	e8 7f 09 00 00       	call   801066 <sys_cputs>

  return b.cnt;
}
  8006e7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006ed:	c9                   	leave  
  8006ee:	c3                   	ret    

008006ef <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006ef:	55                   	push   %ebp
  8006f0:	89 e5                	mov    %esp,%ebp
  8006f2:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8006f5:	8d 45 0c             	lea    0xc(%ebp),%eax
  cnt = vcprintf(fmt, ap);
  8006f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ff:	89 04 24             	mov    %eax,(%esp)
  800702:	e8 87 ff ff ff       	call   80068e <vcprintf>
  va_end(ap);

  return cnt;
}
  800707:	c9                   	leave  
  800708:	c3                   	ret    
  800709:	66 90                	xchg   %ax,%ax
  80070b:	66 90                	xchg   %ax,%ax
  80070d:	66 90                	xchg   %ax,%ax
  80070f:	90                   	nop

00800710 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
         unsigned long long num, unsigned base, int width, int padc)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	57                   	push   %edi
  800714:	56                   	push   %esi
  800715:	53                   	push   %ebx
  800716:	83 ec 3c             	sub    $0x3c,%esp
  800719:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80071c:	89 d7                	mov    %edx,%edi
  80071e:	8b 45 08             	mov    0x8(%ebp),%eax
  800721:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800724:	8b 45 0c             	mov    0xc(%ebp),%eax
  800727:	89 c3                	mov    %eax,%ebx
  800729:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80072c:	8b 45 10             	mov    0x10(%ebp),%eax
  80072f:	8b 75 14             	mov    0x14(%ebp),%esi
  // first recursively print all preceding (more significant) digits
  if (num >= base)
  800732:	b9 00 00 00 00       	mov    $0x0,%ecx
  800737:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80073a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80073d:	39 d9                	cmp    %ebx,%ecx
  80073f:	72 05                	jb     800746 <printnum+0x36>
  800741:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800744:	77 69                	ja     8007af <printnum+0x9f>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  800746:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800749:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80074d:	83 ee 01             	sub    $0x1,%esi
  800750:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800754:	89 44 24 08          	mov    %eax,0x8(%esp)
  800758:	8b 44 24 08          	mov    0x8(%esp),%eax
  80075c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800760:	89 c3                	mov    %eax,%ebx
  800762:	89 d6                	mov    %edx,%esi
  800764:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800767:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80076a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80076e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800772:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800775:	89 04 24             	mov    %eax,(%esp)
  800778:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80077b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077f:	e8 8c 1b 00 00       	call   802310 <__udivdi3>
  800784:	89 d9                	mov    %ebx,%ecx
  800786:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80078a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80078e:	89 04 24             	mov    %eax,(%esp)
  800791:	89 54 24 04          	mov    %edx,0x4(%esp)
  800795:	89 fa                	mov    %edi,%edx
  800797:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80079a:	e8 71 ff ff ff       	call   800710 <printnum>
  80079f:	eb 1b                	jmp    8007bc <printnum+0xac>
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
      putch(padc, putdat);
  8007a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007a5:	8b 45 18             	mov    0x18(%ebp),%eax
  8007a8:	89 04 24             	mov    %eax,(%esp)
  8007ab:	ff d3                	call   *%ebx
  8007ad:	eb 03                	jmp    8007b2 <printnum+0xa2>
  8007af:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  // first recursively print all preceding (more significant) digits
  if (num >= base)
    printnum(putch, putdat, num / base, base, width - 1, padc);
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
  8007b2:	83 ee 01             	sub    $0x1,%esi
  8007b5:	85 f6                	test   %esi,%esi
  8007b7:	7f e8                	jg     8007a1 <printnum+0x91>
  8007b9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
      putch(padc, putdat);
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8007bc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007c0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8007c4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007c7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ce:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007d5:	89 04 24             	mov    %eax,(%esp)
  8007d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007df:	e8 5c 1c 00 00       	call   802440 <__umoddi3>
  8007e4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007e8:	0f be 80 e3 26 80 00 	movsbl 0x8026e3(%eax),%eax
  8007ef:	89 04 24             	mov    %eax,(%esp)
  8007f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007f5:	ff d0                	call   *%eax
}
  8007f7:	83 c4 3c             	add    $0x3c,%esp
  8007fa:	5b                   	pop    %ebx
  8007fb:	5e                   	pop    %esi
  8007fc:	5f                   	pop    %edi
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  if (lflag >= 2)
  800802:	83 fa 01             	cmp    $0x1,%edx
  800805:	7e 0e                	jle    800815 <getuint+0x16>
    return va_arg(*ap, unsigned long long);
  800807:	8b 10                	mov    (%eax),%edx
  800809:	8d 4a 08             	lea    0x8(%edx),%ecx
  80080c:	89 08                	mov    %ecx,(%eax)
  80080e:	8b 02                	mov    (%edx),%eax
  800810:	8b 52 04             	mov    0x4(%edx),%edx
  800813:	eb 22                	jmp    800837 <getuint+0x38>
  else if (lflag)
  800815:	85 d2                	test   %edx,%edx
  800817:	74 10                	je     800829 <getuint+0x2a>
    return va_arg(*ap, unsigned long);
  800819:	8b 10                	mov    (%eax),%edx
  80081b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80081e:	89 08                	mov    %ecx,(%eax)
  800820:	8b 02                	mov    (%edx),%eax
  800822:	ba 00 00 00 00       	mov    $0x0,%edx
  800827:	eb 0e                	jmp    800837 <getuint+0x38>
  else
    return va_arg(*ap, unsigned int);
  800829:	8b 10                	mov    (%eax),%edx
  80082b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80082e:	89 08                	mov    %ecx,(%eax)
  800830:	8b 02                	mov    (%edx),%eax
  800832:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800837:	5d                   	pop    %ebp
  800838:	c3                   	ret    

00800839 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	8b 45 0c             	mov    0xc(%ebp),%eax
  b->cnt++;
  80083f:	83 40 08 01          	addl   $0x1,0x8(%eax)
  if (b->buf < b->ebuf)
  800843:	8b 10                	mov    (%eax),%edx
  800845:	3b 50 04             	cmp    0x4(%eax),%edx
  800848:	73 0a                	jae    800854 <sprintputch+0x1b>
    *b->buf++ = ch;
  80084a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80084d:	89 08                	mov    %ecx,(%eax)
  80084f:	8b 45 08             	mov    0x8(%ebp),%eax
  800852:	88 02                	mov    %al,(%edx)
}
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <printfmt>:
  }
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	83 ec 18             	sub    $0x18,%esp
  va_list ap;

  va_start(ap, fmt);
  80085c:	8d 45 14             	lea    0x14(%ebp),%eax
  vprintfmt(putch, putdat, fmt, ap);
  80085f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800863:	8b 45 10             	mov    0x10(%ebp),%eax
  800866:	89 44 24 08          	mov    %eax,0x8(%esp)
  80086a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80086d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800871:	8b 45 08             	mov    0x8(%ebp),%eax
  800874:	89 04 24             	mov    %eax,(%esp)
  800877:	e8 02 00 00 00       	call   80087e <vprintfmt>
  va_end(ap);
}
  80087c:	c9                   	leave  
  80087d:	c3                   	ret    

0080087e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	57                   	push   %edi
  800882:	56                   	push   %esi
  800883:	53                   	push   %ebx
  800884:	83 ec 3c             	sub    $0x3c,%esp
  800887:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80088a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80088d:	eb 14                	jmp    8008a3 <vprintfmt+0x25>
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
      if (ch == '\0')
  80088f:	85 c0                	test   %eax,%eax
  800891:	0f 84 b3 03 00 00    	je     800c4a <vprintfmt+0x3cc>
        return;
      putch(ch, putdat);
  800897:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80089b:	89 04 24             	mov    %eax,(%esp)
  80089e:	ff 55 08             	call   *0x8(%ebp)
  unsigned long long num;
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
  8008a1:	89 f3                	mov    %esi,%ebx
  8008a3:	8d 73 01             	lea    0x1(%ebx),%esi
  8008a6:	0f b6 03             	movzbl (%ebx),%eax
  8008a9:	83 f8 25             	cmp    $0x25,%eax
  8008ac:	75 e1                	jne    80088f <vprintfmt+0x11>
  8008ae:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8008b2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8008b9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8008c0:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8008c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8008cc:	eb 1d                	jmp    8008eb <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8008ce:	89 de                	mov    %ebx,%esi

    // flag to pad on the right
    case '-':
      padc = '-';
  8008d0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8008d4:	eb 15                	jmp    8008eb <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8008d6:	89 de                	mov    %ebx,%esi
      padc = '-';
      goto reswitch;

    // flag to pad with 0's instead of spaces
    case '0':
      padc = '0';
  8008d8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8008dc:	eb 0d                	jmp    8008eb <vprintfmt+0x6d>
      altflag = 1;
      goto reswitch;

process_precision:
      if (width < 0)
        width = precision, precision = -1;
  8008de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8008e1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8008e4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8008eb:	8d 5e 01             	lea    0x1(%esi),%ebx
  8008ee:	0f b6 0e             	movzbl (%esi),%ecx
  8008f1:	0f b6 c1             	movzbl %cl,%eax
  8008f4:	83 e9 23             	sub    $0x23,%ecx
  8008f7:	80 f9 55             	cmp    $0x55,%cl
  8008fa:	0f 87 2a 03 00 00    	ja     800c2a <vprintfmt+0x3ac>
  800900:	0f b6 c9             	movzbl %cl,%ecx
  800903:	ff 24 8d 20 28 80 00 	jmp    *0x802820(,%ecx,4)
  80090a:	89 de                	mov    %ebx,%esi
  80090c:	b9 00 00 00 00       	mov    $0x0,%ecx
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
        precision = precision * 10 + ch - '0';
  800911:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800914:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
        ch = *fmt;
  800918:	0f be 06             	movsbl (%esi),%eax
        if (ch < '0' || ch > '9')
  80091b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80091e:	83 fb 09             	cmp    $0x9,%ebx
  800921:	77 36                	ja     800959 <vprintfmt+0xdb>
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
  800923:	83 c6 01             	add    $0x1,%esi
        precision = precision * 10 + ch - '0';
        ch = *fmt;
        if (ch < '0' || ch > '9')
          break;
      }
  800926:	eb e9                	jmp    800911 <vprintfmt+0x93>
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
  800928:	8b 45 14             	mov    0x14(%ebp),%eax
  80092b:	8d 48 04             	lea    0x4(%eax),%ecx
  80092e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800931:	8b 00                	mov    (%eax),%eax
  800933:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  800936:	89 de                	mov    %ebx,%esi
      }
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
      goto process_precision;
  800938:	eb 22                	jmp    80095c <vprintfmt+0xde>
  80093a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80093d:	85 c9                	test   %ecx,%ecx
  80093f:	b8 00 00 00 00       	mov    $0x0,%eax
  800944:	0f 49 c1             	cmovns %ecx,%eax
  800947:	89 45 dc             	mov    %eax,-0x24(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80094a:	89 de                	mov    %ebx,%esi
  80094c:	eb 9d                	jmp    8008eb <vprintfmt+0x6d>
  80094e:	89 de                	mov    %ebx,%esi
      if (width < 0)
        width = 0;
      goto reswitch;

    case '#':
      altflag = 1;
  800950:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
      goto reswitch;
  800957:	eb 92                	jmp    8008eb <vprintfmt+0x6d>
  800959:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

process_precision:
      if (width < 0)
  80095c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800960:	79 89                	jns    8008eb <vprintfmt+0x6d>
  800962:	e9 77 ff ff ff       	jmp    8008de <vprintfmt+0x60>
        width = precision, precision = -1;
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
  800967:	83 c2 01             	add    $0x1,%edx
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80096a:	89 de                	mov    %ebx,%esi
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
      goto reswitch;
  80096c:	e9 7a ff ff ff       	jmp    8008eb <vprintfmt+0x6d>

    // character
    case 'c':
      putch(va_arg(ap, int), putdat);
  800971:	8b 45 14             	mov    0x14(%ebp),%eax
  800974:	8d 50 04             	lea    0x4(%eax),%edx
  800977:	89 55 14             	mov    %edx,0x14(%ebp)
  80097a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80097e:	8b 00                	mov    (%eax),%eax
  800980:	89 04 24             	mov    %eax,(%esp)
  800983:	ff 55 08             	call   *0x8(%ebp)
      break;
  800986:	e9 18 ff ff ff       	jmp    8008a3 <vprintfmt+0x25>

    // error message
    case 'e':
      err = va_arg(ap, int);
  80098b:	8b 45 14             	mov    0x14(%ebp),%eax
  80098e:	8d 50 04             	lea    0x4(%eax),%edx
  800991:	89 55 14             	mov    %edx,0x14(%ebp)
  800994:	8b 00                	mov    (%eax),%eax
  800996:	99                   	cltd   
  800997:	31 d0                	xor    %edx,%eax
  800999:	29 d0                	sub    %edx,%eax
      if (err < 0)
        err = -err;
      if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80099b:	83 f8 0f             	cmp    $0xf,%eax
  80099e:	7f 0b                	jg     8009ab <vprintfmt+0x12d>
  8009a0:	8b 14 85 80 29 80 00 	mov    0x802980(,%eax,4),%edx
  8009a7:	85 d2                	test   %edx,%edx
  8009a9:	75 20                	jne    8009cb <vprintfmt+0x14d>
        printfmt(putch, putdat, "error %d", err);
  8009ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009af:	c7 44 24 08 fb 26 80 	movl   $0x8026fb,0x8(%esp)
  8009b6:	00 
  8009b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	89 04 24             	mov    %eax,(%esp)
  8009c1:	e8 90 fe ff ff       	call   800856 <printfmt>
  8009c6:	e9 d8 fe ff ff       	jmp    8008a3 <vprintfmt+0x25>
      else
        printfmt(putch, putdat, "%s", p);
  8009cb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009cf:	c7 44 24 08 04 27 80 	movl   $0x802704,0x8(%esp)
  8009d6:	00 
  8009d7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	89 04 24             	mov    %eax,(%esp)
  8009e1:	e8 70 fe ff ff       	call   800856 <printfmt>
  8009e6:	e9 b8 fe ff ff       	jmp    8008a3 <vprintfmt+0x25>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8009eb:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8009ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8009f1:	89 45 d0             	mov    %eax,-0x30(%ebp)
        printfmt(putch, putdat, "%s", p);
      break;

    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
  8009f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f7:	8d 50 04             	lea    0x4(%eax),%edx
  8009fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8009fd:	8b 30                	mov    (%eax),%esi
        p = "(null)";
  8009ff:	85 f6                	test   %esi,%esi
  800a01:	b8 f4 26 80 00       	mov    $0x8026f4,%eax
  800a06:	0f 44 f0             	cmove  %eax,%esi
      if (width > 0 && padc != '-')
  800a09:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800a0d:	0f 84 97 00 00 00    	je     800aaa <vprintfmt+0x22c>
  800a13:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800a17:	0f 8e 9b 00 00 00    	jle    800ab8 <vprintfmt+0x23a>
        for (width -= strnlen(p, precision); width > 0; width--)
  800a1d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a21:	89 34 24             	mov    %esi,(%esp)
  800a24:	e8 cf 02 00 00       	call   800cf8 <strnlen>
  800a29:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a2c:	29 c2                	sub    %eax,%edx
  800a2e:	89 55 d0             	mov    %edx,-0x30(%ebp)
          putch(padc, putdat);
  800a31:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800a35:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800a38:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800a3b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a3e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a41:	89 d3                	mov    %edx,%ebx
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
  800a43:	eb 0f                	jmp    800a54 <vprintfmt+0x1d6>
          putch(padc, putdat);
  800a45:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a49:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a4c:	89 04 24             	mov    %eax,(%esp)
  800a4f:	ff d6                	call   *%esi
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
  800a51:	83 eb 01             	sub    $0x1,%ebx
  800a54:	85 db                	test   %ebx,%ebx
  800a56:	7f ed                	jg     800a45 <vprintfmt+0x1c7>
  800a58:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800a5b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a5e:	85 d2                	test   %edx,%edx
  800a60:	b8 00 00 00 00       	mov    $0x0,%eax
  800a65:	0f 49 c2             	cmovns %edx,%eax
  800a68:	29 c2                	sub    %eax,%edx
  800a6a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800a6d:	89 d7                	mov    %edx,%edi
  800a6f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800a72:	eb 50                	jmp    800ac4 <vprintfmt+0x246>
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
  800a74:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a78:	74 1e                	je     800a98 <vprintfmt+0x21a>
  800a7a:	0f be d2             	movsbl %dl,%edx
  800a7d:	83 ea 20             	sub    $0x20,%edx
  800a80:	83 fa 5e             	cmp    $0x5e,%edx
  800a83:	76 13                	jbe    800a98 <vprintfmt+0x21a>
          putch('?', putdat);
  800a85:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a88:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a8c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a93:	ff 55 08             	call   *0x8(%ebp)
  800a96:	eb 0d                	jmp    800aa5 <vprintfmt+0x227>
        else
          putch(ch, putdat);
  800a98:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9b:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a9f:	89 04 24             	mov    %eax,(%esp)
  800aa2:	ff 55 08             	call   *0x8(%ebp)
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800aa5:	83 ef 01             	sub    $0x1,%edi
  800aa8:	eb 1a                	jmp    800ac4 <vprintfmt+0x246>
  800aaa:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800aad:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800ab0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ab3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800ab6:	eb 0c                	jmp    800ac4 <vprintfmt+0x246>
  800ab8:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800abb:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800abe:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ac1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800ac4:	83 c6 01             	add    $0x1,%esi
  800ac7:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800acb:	0f be c2             	movsbl %dl,%eax
  800ace:	85 c0                	test   %eax,%eax
  800ad0:	74 27                	je     800af9 <vprintfmt+0x27b>
  800ad2:	85 db                	test   %ebx,%ebx
  800ad4:	78 9e                	js     800a74 <vprintfmt+0x1f6>
  800ad6:	83 eb 01             	sub    $0x1,%ebx
  800ad9:	79 99                	jns    800a74 <vprintfmt+0x1f6>
  800adb:	89 f8                	mov    %edi,%eax
  800add:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ae0:	8b 75 08             	mov    0x8(%ebp),%esi
  800ae3:	89 c3                	mov    %eax,%ebx
  800ae5:	eb 1a                	jmp    800b01 <vprintfmt+0x283>
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
        putch(' ', putdat);
  800ae7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aeb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800af2:	ff d6                	call   *%esi
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
  800af4:	83 eb 01             	sub    $0x1,%ebx
  800af7:	eb 08                	jmp    800b01 <vprintfmt+0x283>
  800af9:	89 fb                	mov    %edi,%ebx
  800afb:	8b 75 08             	mov    0x8(%ebp),%esi
  800afe:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b01:	85 db                	test   %ebx,%ebx
  800b03:	7f e2                	jg     800ae7 <vprintfmt+0x269>
  800b05:	89 75 08             	mov    %esi,0x8(%ebp)
  800b08:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b0b:	e9 93 fd ff ff       	jmp    8008a3 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  if (lflag >= 2)
  800b10:	83 fa 01             	cmp    $0x1,%edx
  800b13:	7e 16                	jle    800b2b <vprintfmt+0x2ad>
    return va_arg(*ap, long long);
  800b15:	8b 45 14             	mov    0x14(%ebp),%eax
  800b18:	8d 50 08             	lea    0x8(%eax),%edx
  800b1b:	89 55 14             	mov    %edx,0x14(%ebp)
  800b1e:	8b 50 04             	mov    0x4(%eax),%edx
  800b21:	8b 00                	mov    (%eax),%eax
  800b23:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b26:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800b29:	eb 32                	jmp    800b5d <vprintfmt+0x2df>
  else if (lflag)
  800b2b:	85 d2                	test   %edx,%edx
  800b2d:	74 18                	je     800b47 <vprintfmt+0x2c9>
    return va_arg(*ap, long);
  800b2f:	8b 45 14             	mov    0x14(%ebp),%eax
  800b32:	8d 50 04             	lea    0x4(%eax),%edx
  800b35:	89 55 14             	mov    %edx,0x14(%ebp)
  800b38:	8b 30                	mov    (%eax),%esi
  800b3a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800b3d:	89 f0                	mov    %esi,%eax
  800b3f:	c1 f8 1f             	sar    $0x1f,%eax
  800b42:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b45:	eb 16                	jmp    800b5d <vprintfmt+0x2df>
  else
    return va_arg(*ap, int);
  800b47:	8b 45 14             	mov    0x14(%ebp),%eax
  800b4a:	8d 50 04             	lea    0x4(%eax),%edx
  800b4d:	89 55 14             	mov    %edx,0x14(%ebp)
  800b50:	8b 30                	mov    (%eax),%esi
  800b52:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800b55:	89 f0                	mov    %esi,%eax
  800b57:	c1 f8 1f             	sar    $0x1f,%eax
  800b5a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        putch(' ', putdat);
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
  800b5d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b60:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      if ((long long)num < 0) {
        putch('-', putdat);
        num = -(long long)num;
      }
      base = 10;
  800b63:	b9 0a 00 00 00       	mov    $0xa,%ecx
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
      if ((long long)num < 0) {
  800b68:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b6c:	0f 89 80 00 00 00    	jns    800bf2 <vprintfmt+0x374>
        putch('-', putdat);
  800b72:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b76:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800b7d:	ff 55 08             	call   *0x8(%ebp)
        num = -(long long)num;
  800b80:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b83:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b86:	f7 d8                	neg    %eax
  800b88:	83 d2 00             	adc    $0x0,%edx
  800b8b:	f7 da                	neg    %edx
      }
      base = 10;
  800b8d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b92:	eb 5e                	jmp    800bf2 <vprintfmt+0x374>
      goto number;

    // unsigned decimal
    case 'u':
      num = getuint(&ap, lflag);
  800b94:	8d 45 14             	lea    0x14(%ebp),%eax
  800b97:	e8 63 fc ff ff       	call   8007ff <getuint>
      base = 10;
  800b9c:	b9 0a 00 00 00       	mov    $0xa,%ecx
      goto number;
  800ba1:	eb 4f                	jmp    800bf2 <vprintfmt+0x374>

    // (unsigned) octal
    case 'o':
      num = getuint(&ap, lflag);
  800ba3:	8d 45 14             	lea    0x14(%ebp),%eax
  800ba6:	e8 54 fc ff ff       	call   8007ff <getuint>
      base = 8;
  800bab:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800bb0:	eb 40                	jmp    800bf2 <vprintfmt+0x374>

    // pointer
    case 'p':
      putch('0', putdat);
  800bb2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bb6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800bbd:	ff 55 08             	call   *0x8(%ebp)
      putch('x', putdat);
  800bc0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bc4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800bcb:	ff 55 08             	call   *0x8(%ebp)
      num = (unsigned long long)
            (uintptr_t)va_arg(ap, void *);
  800bce:	8b 45 14             	mov    0x14(%ebp),%eax
  800bd1:	8d 50 04             	lea    0x4(%eax),%edx
  800bd4:	89 55 14             	mov    %edx,0x14(%ebp)

    // pointer
    case 'p':
      putch('0', putdat);
      putch('x', putdat);
      num = (unsigned long long)
  800bd7:	8b 00                	mov    (%eax),%eax
  800bd9:	ba 00 00 00 00       	mov    $0x0,%edx
            (uintptr_t)va_arg(ap, void *);
      base = 16;
  800bde:	b9 10 00 00 00       	mov    $0x10,%ecx
      goto number;
  800be3:	eb 0d                	jmp    800bf2 <vprintfmt+0x374>

    // (unsigned) hexadecimal
    case 'x':
      num = getuint(&ap, lflag);
  800be5:	8d 45 14             	lea    0x14(%ebp),%eax
  800be8:	e8 12 fc ff ff       	call   8007ff <getuint>
      base = 16;
  800bed:	b9 10 00 00 00       	mov    $0x10,%ecx
number:
      printnum(putch, putdat, num, base, width, padc);
  800bf2:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800bf6:	89 74 24 10          	mov    %esi,0x10(%esp)
  800bfa:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800bfd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800c01:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c05:	89 04 24             	mov    %eax,(%esp)
  800c08:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c0c:	89 fa                	mov    %edi,%edx
  800c0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c11:	e8 fa fa ff ff       	call   800710 <printnum>
      break;
  800c16:	e9 88 fc ff ff       	jmp    8008a3 <vprintfmt+0x25>

    // escaped '%' character
    case '%':
      putch(ch, putdat);
  800c1b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c1f:	89 04 24             	mov    %eax,(%esp)
  800c22:	ff 55 08             	call   *0x8(%ebp)
      break;
  800c25:	e9 79 fc ff ff       	jmp    8008a3 <vprintfmt+0x25>

    // unrecognized escape sequence - just print it literally
    default:
      putch('%', putdat);
  800c2a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c2e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800c35:	ff 55 08             	call   *0x8(%ebp)
      for (fmt--; fmt[-1] != '%'; fmt--)
  800c38:	89 f3                	mov    %esi,%ebx
  800c3a:	eb 03                	jmp    800c3f <vprintfmt+0x3c1>
  800c3c:	83 eb 01             	sub    $0x1,%ebx
  800c3f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800c43:	75 f7                	jne    800c3c <vprintfmt+0x3be>
  800c45:	e9 59 fc ff ff       	jmp    8008a3 <vprintfmt+0x25>
        /* do nothing */;
      break;
    }
  }
}
  800c4a:	83 c4 3c             	add    $0x3c,%esp
  800c4d:	5b                   	pop    %ebx
  800c4e:	5e                   	pop    %esi
  800c4f:	5f                   	pop    %edi
  800c50:	5d                   	pop    %ebp
  800c51:	c3                   	ret    

00800c52 <vsnprintf>:
    *b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	83 ec 28             	sub    $0x28,%esp
  800c58:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  struct sprintbuf b = { buf, buf+n-1, 0 };
  800c5e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c61:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c65:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c68:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  if (buf == NULL || n < 1)
  800c6f:	85 c0                	test   %eax,%eax
  800c71:	74 30                	je     800ca3 <vsnprintf+0x51>
  800c73:	85 d2                	test   %edx,%edx
  800c75:	7e 2c                	jle    800ca3 <vsnprintf+0x51>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c77:	8b 45 14             	mov    0x14(%ebp),%eax
  800c7a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c7e:	8b 45 10             	mov    0x10(%ebp),%eax
  800c81:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c85:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c88:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c8c:	c7 04 24 39 08 80 00 	movl   $0x800839,(%esp)
  800c93:	e8 e6 fb ff ff       	call   80087e <vprintfmt>

  // null terminate the buffer
  *b.buf = '\0';
  800c98:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c9b:	c6 00 00             	movb   $0x0,(%eax)

  return b.cnt;
  800c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca1:	eb 05                	jmp    800ca8 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  struct sprintbuf b = { buf, buf+n-1, 0 };

  if (buf == NULL || n < 1)
    return -E_INVAL;
  800ca3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

  // null terminate the buffer
  *b.buf = '\0';

  return b.cnt;
}
  800ca8:	c9                   	leave  
  800ca9:	c3                   	ret    

00800caa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800cb0:	8d 45 14             	lea    0x14(%ebp),%eax
  rc = vsnprintf(buf, n, fmt, ap);
  800cb3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cb7:	8b 45 10             	mov    0x10(%ebp),%eax
  800cba:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc8:	89 04 24             	mov    %eax,(%esp)
  800ccb:	e8 82 ff ff ff       	call   800c52 <vsnprintf>
  va_end(ap);

  return rc;
}
  800cd0:	c9                   	leave  
  800cd1:	c3                   	ret    
  800cd2:	66 90                	xchg   %ax,%ax
  800cd4:	66 90                	xchg   %ax,%ax
  800cd6:	66 90                	xchg   %ax,%ax
  800cd8:	66 90                	xchg   %ax,%ax
  800cda:	66 90                	xchg   %ax,%ax
  800cdc:	66 90                	xchg   %ax,%ax
  800cde:	66 90                	xchg   %ax,%ax

00800ce0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for (n = 0; *s != '\0'; s++)
  800ce6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ceb:	eb 03                	jmp    800cf0 <strlen+0x10>
    n++;
  800ced:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
  int n;

  for (n = 0; *s != '\0'; s++)
  800cf0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800cf4:	75 f7                	jne    800ced <strlen+0xd>
    n++;
  return n;
}
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    

00800cf8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cfe:	8b 55 0c             	mov    0xc(%ebp),%edx
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d01:	b8 00 00 00 00       	mov    $0x0,%eax
  800d06:	eb 03                	jmp    800d0b <strnlen+0x13>
    n++;
  800d08:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d0b:	39 d0                	cmp    %edx,%eax
  800d0d:	74 06                	je     800d15 <strnlen+0x1d>
  800d0f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800d13:	75 f3                	jne    800d08 <strnlen+0x10>
    n++;
  return n;
}
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	53                   	push   %ebx
  800d1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800d21:	89 c2                	mov    %eax,%edx
  800d23:	83 c2 01             	add    $0x1,%edx
  800d26:	83 c1 01             	add    $0x1,%ecx
  800d29:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d2d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d30:	84 db                	test   %bl,%bl
  800d32:	75 ef                	jne    800d23 <strcpy+0xc>
    /* do nothing */;
  return ret;
}
  800d34:	5b                   	pop    %ebx
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    

00800d37 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	53                   	push   %ebx
  800d3b:	83 ec 08             	sub    $0x8,%esp
  800d3e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int len = strlen(dst);
  800d41:	89 1c 24             	mov    %ebx,(%esp)
  800d44:	e8 97 ff ff ff       	call   800ce0 <strlen>

  strcpy(dst + len, src);
  800d49:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d4c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d50:	01 d8                	add    %ebx,%eax
  800d52:	89 04 24             	mov    %eax,(%esp)
  800d55:	e8 bd ff ff ff       	call   800d17 <strcpy>
  return dst;
}
  800d5a:	89 d8                	mov    %ebx,%eax
  800d5c:	83 c4 08             	add    $0x8,%esp
  800d5f:	5b                   	pop    %ebx
  800d60:	5d                   	pop    %ebp
  800d61:	c3                   	ret    

00800d62 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	56                   	push   %esi
  800d66:	53                   	push   %ebx
  800d67:	8b 75 08             	mov    0x8(%ebp),%esi
  800d6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6d:	89 f3                	mov    %esi,%ebx
  800d6f:	03 5d 10             	add    0x10(%ebp),%ebx
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800d72:	89 f2                	mov    %esi,%edx
  800d74:	eb 0f                	jmp    800d85 <strncpy+0x23>
    *dst++ = *src;
  800d76:	83 c2 01             	add    $0x1,%edx
  800d79:	0f b6 01             	movzbl (%ecx),%eax
  800d7c:	88 42 ff             	mov    %al,-0x1(%edx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800d7f:	80 39 01             	cmpb   $0x1,(%ecx)
  800d82:	83 d9 ff             	sbb    $0xffffffff,%ecx
{
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800d85:	39 da                	cmp    %ebx,%edx
  800d87:	75 ed                	jne    800d76 <strncpy+0x14>
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  }
  return ret;
}
  800d89:	89 f0                	mov    %esi,%eax
  800d8b:	5b                   	pop    %ebx
  800d8c:	5e                   	pop    %esi
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    

00800d8f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
  800d94:	8b 75 08             	mov    0x8(%ebp),%esi
  800d97:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d9a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800d9d:	89 f0                	mov    %esi,%eax
  800d9f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800da3:	85 c9                	test   %ecx,%ecx
  800da5:	75 0b                	jne    800db2 <strlcpy+0x23>
  800da7:	eb 1d                	jmp    800dc6 <strlcpy+0x37>
    while (--size > 0 && *src != '\0')
      *dst++ = *src++;
  800da9:	83 c0 01             	add    $0x1,%eax
  800dac:	83 c2 01             	add    $0x1,%edx
  800daf:	88 48 ff             	mov    %cl,-0x1(%eax)
{
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
    while (--size > 0 && *src != '\0')
  800db2:	39 d8                	cmp    %ebx,%eax
  800db4:	74 0b                	je     800dc1 <strlcpy+0x32>
  800db6:	0f b6 0a             	movzbl (%edx),%ecx
  800db9:	84 c9                	test   %cl,%cl
  800dbb:	75 ec                	jne    800da9 <strlcpy+0x1a>
  800dbd:	89 c2                	mov    %eax,%edx
  800dbf:	eb 02                	jmp    800dc3 <strlcpy+0x34>
  800dc1:	89 c2                	mov    %eax,%edx
      *dst++ = *src++;
    *dst = '\0';
  800dc3:	c6 02 00             	movb   $0x0,(%edx)
  }
  return dst - dst_in;
  800dc6:	29 f0                	sub    %esi,%eax
}
  800dc8:	5b                   	pop    %ebx
  800dc9:	5e                   	pop    %esi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd2:	8b 55 0c             	mov    0xc(%ebp),%edx
  while (*p && *p == *q)
  800dd5:	eb 06                	jmp    800ddd <strcmp+0x11>
    p++, q++;
  800dd7:	83 c1 01             	add    $0x1,%ecx
  800dda:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
  while (*p && *p == *q)
  800ddd:	0f b6 01             	movzbl (%ecx),%eax
  800de0:	84 c0                	test   %al,%al
  800de2:	74 04                	je     800de8 <strcmp+0x1c>
  800de4:	3a 02                	cmp    (%edx),%al
  800de6:	74 ef                	je     800dd7 <strcmp+0xb>
    p++, q++;
  return (int)((unsigned char)*p - (unsigned char)*q);
  800de8:	0f b6 c0             	movzbl %al,%eax
  800deb:	0f b6 12             	movzbl (%edx),%edx
  800dee:	29 d0                	sub    %edx,%eax
}
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    

00800df2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	53                   	push   %ebx
  800df6:	8b 45 08             	mov    0x8(%ebp),%eax
  800df9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dfc:	89 c3                	mov    %eax,%ebx
  800dfe:	03 5d 10             	add    0x10(%ebp),%ebx
  while (n > 0 && *p && *p == *q)
  800e01:	eb 06                	jmp    800e09 <strncmp+0x17>
    n--, p++, q++;
  800e03:	83 c0 01             	add    $0x1,%eax
  800e06:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
  800e09:	39 d8                	cmp    %ebx,%eax
  800e0b:	74 15                	je     800e22 <strncmp+0x30>
  800e0d:	0f b6 08             	movzbl (%eax),%ecx
  800e10:	84 c9                	test   %cl,%cl
  800e12:	74 04                	je     800e18 <strncmp+0x26>
  800e14:	3a 0a                	cmp    (%edx),%cl
  800e16:	74 eb                	je     800e03 <strncmp+0x11>
    n--, p++, q++;
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800e18:	0f b6 00             	movzbl (%eax),%eax
  800e1b:	0f b6 12             	movzbl (%edx),%edx
  800e1e:	29 d0                	sub    %edx,%eax
  800e20:	eb 05                	jmp    800e27 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
    n--, p++, q++;
  if (n == 0)
    return 0;
  800e22:	b8 00 00 00 00       	mov    $0x0,%eax
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
}
  800e27:	5b                   	pop    %ebx
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e30:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
  800e34:	eb 07                	jmp    800e3d <strchr+0x13>
    if (*s == c)
  800e36:	38 ca                	cmp    %cl,%dl
  800e38:	74 0f                	je     800e49 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  for (; *s; s++)
  800e3a:	83 c0 01             	add    $0x1,%eax
  800e3d:	0f b6 10             	movzbl (%eax),%edx
  800e40:	84 d2                	test   %dl,%dl
  800e42:	75 f2                	jne    800e36 <strchr+0xc>
    if (*s == c)
      return (char*)s;
  return 0;
  800e44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e49:	5d                   	pop    %ebp
  800e4a:	c3                   	ret    

00800e4b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
  800e55:	eb 07                	jmp    800e5e <strfind+0x13>
    if (*s == c)
  800e57:	38 ca                	cmp    %cl,%dl
  800e59:	74 0a                	je     800e65 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  for (; *s; s++)
  800e5b:	83 c0 01             	add    $0x1,%eax
  800e5e:	0f b6 10             	movzbl (%eax),%edx
  800e61:	84 d2                	test   %dl,%dl
  800e63:	75 f2                	jne    800e57 <strfind+0xc>
    if (*s == c)
      break;
  return (char*)s;
}
  800e65:	5d                   	pop    %ebp
  800e66:	c3                   	ret    

00800e67 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	57                   	push   %edi
  800e6b:	56                   	push   %esi
  800e6c:	53                   	push   %ebx
  800e6d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e70:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *p;

  if (n == 0)
  800e73:	85 c9                	test   %ecx,%ecx
  800e75:	74 36                	je     800ead <memset+0x46>
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
  800e77:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e7d:	75 28                	jne    800ea7 <memset+0x40>
  800e7f:	f6 c1 03             	test   $0x3,%cl
  800e82:	75 23                	jne    800ea7 <memset+0x40>
    c &= 0xFF;
  800e84:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
    c = (c<<24)|(c<<16)|(c<<8)|c;
  800e88:	89 d3                	mov    %edx,%ebx
  800e8a:	c1 e3 08             	shl    $0x8,%ebx
  800e8d:	89 d6                	mov    %edx,%esi
  800e8f:	c1 e6 18             	shl    $0x18,%esi
  800e92:	89 d0                	mov    %edx,%eax
  800e94:	c1 e0 10             	shl    $0x10,%eax
  800e97:	09 f0                	or     %esi,%eax
  800e99:	09 c2                	or     %eax,%edx
  800e9b:	89 d0                	mov    %edx,%eax
  800e9d:	09 d8                	or     %ebx,%eax
    asm volatile ("cld; rep stosl\n"
                  :: "D" (v), "a" (c), "c" (n/4)
  800e9f:	c1 e9 02             	shr    $0x2,%ecx
  if (n == 0)
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
    c &= 0xFF;
    c = (c<<24)|(c<<16)|(c<<8)|c;
    asm volatile ("cld; rep stosl\n"
  800ea2:	fc                   	cld    
  800ea3:	f3 ab                	rep stos %eax,%es:(%edi)
  800ea5:	eb 06                	jmp    800ead <memset+0x46>
                  :: "D" (v), "a" (c), "c" (n/4)
                  : "cc", "memory");
  } else
    asm volatile ("cld; rep stosb\n"
  800ea7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eaa:	fc                   	cld    
  800eab:	f3 aa                	rep stos %al,%es:(%edi)
                  :: "D" (v), "a" (c), "c" (n)
                  : "cc", "memory");
  return v;
}
  800ead:	89 f8                	mov    %edi,%eax
  800eaf:	5b                   	pop    %ebx
  800eb0:	5e                   	pop    %esi
  800eb1:	5f                   	pop    %edi
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    

00800eb4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	57                   	push   %edi
  800eb8:	56                   	push   %esi
  800eb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ebf:	8b 4d 10             	mov    0x10(%ebp),%ecx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800ec2:	39 c6                	cmp    %eax,%esi
  800ec4:	73 35                	jae    800efb <memmove+0x47>
  800ec6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ec9:	39 d0                	cmp    %edx,%eax
  800ecb:	73 2e                	jae    800efb <memmove+0x47>
    s += n;
    d += n;
  800ecd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800ed0:	89 d6                	mov    %edx,%esi
  800ed2:	09 fe                	or     %edi,%esi
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ed4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800eda:	75 13                	jne    800eef <memmove+0x3b>
  800edc:	f6 c1 03             	test   $0x3,%cl
  800edf:	75 0e                	jne    800eef <memmove+0x3b>
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ee1:	83 ef 04             	sub    $0x4,%edi
  800ee4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ee7:	c1 e9 02             	shr    $0x2,%ecx
  d = dst;
  if (s < d && s + n > d) {
    s += n;
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
  800eea:	fd                   	std    
  800eeb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800eed:	eb 09                	jmp    800ef8 <memmove+0x44>
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800eef:	83 ef 01             	sub    $0x1,%edi
  800ef2:	8d 72 ff             	lea    -0x1(%edx),%esi
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
  800ef5:	fd                   	std    
  800ef6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  800ef8:	fc                   	cld    
  800ef9:	eb 1d                	jmp    800f18 <memmove+0x64>
  800efb:	89 f2                	mov    %esi,%edx
  800efd:	09 c2                	or     %eax,%edx
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eff:	f6 c2 03             	test   $0x3,%dl
  800f02:	75 0f                	jne    800f13 <memmove+0x5f>
  800f04:	f6 c1 03             	test   $0x3,%cl
  800f07:	75 0a                	jne    800f13 <memmove+0x5f>
      asm volatile ("cld; rep movsl\n"
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f09:	c1 e9 02             	shr    $0x2,%ecx
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("cld; rep movsl\n"
  800f0c:	89 c7                	mov    %eax,%edi
  800f0e:	fc                   	cld    
  800f0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f11:	eb 05                	jmp    800f18 <memmove+0x64>
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("cld; rep movsb\n"
  800f13:	89 c7                	mov    %eax,%edi
  800f15:	fc                   	cld    
  800f16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d), "S" (s), "c" (n) : "cc", "memory");
  }
  return dst;
}
  800f18:	5e                   	pop    %esi
  800f19:	5f                   	pop    %edi
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    

00800f1c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
  800f22:	8b 45 10             	mov    0x10(%ebp),%eax
  800f25:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f29:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f30:	8b 45 08             	mov    0x8(%ebp),%eax
  800f33:	89 04 24             	mov    %eax,(%esp)
  800f36:	e8 79 ff ff ff       	call   800eb4 <memmove>
}
  800f3b:	c9                   	leave  
  800f3c:	c3                   	ret    

00800f3d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	56                   	push   %esi
  800f41:	53                   	push   %ebx
  800f42:	8b 55 08             	mov    0x8(%ebp),%edx
  800f45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f48:	89 d6                	mov    %edx,%esi
  800f4a:	03 75 10             	add    0x10(%ebp),%esi
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
  800f4d:	eb 1a                	jmp    800f69 <memcmp+0x2c>
    if (*s1 != *s2)
  800f4f:	0f b6 02             	movzbl (%edx),%eax
  800f52:	0f b6 19             	movzbl (%ecx),%ebx
  800f55:	38 d8                	cmp    %bl,%al
  800f57:	74 0a                	je     800f63 <memcmp+0x26>
      return (int)*s1 - (int)*s2;
  800f59:	0f b6 c0             	movzbl %al,%eax
  800f5c:	0f b6 db             	movzbl %bl,%ebx
  800f5f:	29 d8                	sub    %ebx,%eax
  800f61:	eb 0f                	jmp    800f72 <memcmp+0x35>
    s1++, s2++;
  800f63:	83 c2 01             	add    $0x1,%edx
  800f66:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
  800f69:	39 f2                	cmp    %esi,%edx
  800f6b:	75 e2                	jne    800f4f <memcmp+0x12>
    if (*s1 != *s2)
      return (int)*s1 - (int)*s2;
    s1++, s2++;
  }

  return 0;
  800f6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f72:	5b                   	pop    %ebx
  800f73:	5e                   	pop    %esi
  800f74:	5d                   	pop    %ebp
  800f75:	c3                   	ret    

00800f76 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  const void *ends = (const char*)s + n;
  800f7f:	89 c2                	mov    %eax,%edx
  800f81:	03 55 10             	add    0x10(%ebp),%edx

  for (; s < ends; s++)
  800f84:	eb 07                	jmp    800f8d <memfind+0x17>
    if (*(const unsigned char*)s == (unsigned char)c)
  800f86:	38 08                	cmp    %cl,(%eax)
  800f88:	74 07                	je     800f91 <memfind+0x1b>
void *
memfind(const void *s, int c, size_t n)
{
  const void *ends = (const char*)s + n;

  for (; s < ends; s++)
  800f8a:	83 c0 01             	add    $0x1,%eax
  800f8d:	39 d0                	cmp    %edx,%eax
  800f8f:	72 f5                	jb     800f86 <memfind+0x10>
    if (*(const unsigned char*)s == (unsigned char)c)
      break;
  return (void*)s;
}
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    

00800f93 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	57                   	push   %edi
  800f97:	56                   	push   %esi
  800f98:	53                   	push   %ebx
  800f99:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9c:	8b 45 10             	mov    0x10(%ebp),%eax
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800f9f:	eb 03                	jmp    800fa4 <strtol+0x11>
    s++;
  800fa1:	83 c2 01             	add    $0x1,%edx
{
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800fa4:	0f b6 0a             	movzbl (%edx),%ecx
  800fa7:	80 f9 09             	cmp    $0x9,%cl
  800faa:	74 f5                	je     800fa1 <strtol+0xe>
  800fac:	80 f9 20             	cmp    $0x20,%cl
  800faf:	74 f0                	je     800fa1 <strtol+0xe>
    s++;

  // plus/minus sign
  if (*s == '+')
  800fb1:	80 f9 2b             	cmp    $0x2b,%cl
  800fb4:	75 0a                	jne    800fc0 <strtol+0x2d>
    s++;
  800fb6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
  int neg = 0;
  800fb9:	bf 00 00 00 00       	mov    $0x0,%edi
  800fbe:	eb 11                	jmp    800fd1 <strtol+0x3e>
  800fc0:	bf 00 00 00 00       	mov    $0x0,%edi
    s++;

  // plus/minus sign
  if (*s == '+')
    s++;
  else if (*s == '-')
  800fc5:	80 f9 2d             	cmp    $0x2d,%cl
  800fc8:	75 07                	jne    800fd1 <strtol+0x3e>
    s++, neg = 1;
  800fca:	8d 52 01             	lea    0x1(%edx),%edx
  800fcd:	66 bf 01 00          	mov    $0x1,%di

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fd1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800fd6:	75 15                	jne    800fed <strtol+0x5a>
  800fd8:	80 3a 30             	cmpb   $0x30,(%edx)
  800fdb:	75 10                	jne    800fed <strtol+0x5a>
  800fdd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800fe1:	75 0a                	jne    800fed <strtol+0x5a>
    s += 2, base = 16;
  800fe3:	83 c2 02             	add    $0x2,%edx
  800fe6:	b8 10 00 00 00       	mov    $0x10,%eax
  800feb:	eb 10                	jmp    800ffd <strtol+0x6a>
  else if (base == 0 && s[0] == '0')
  800fed:	85 c0                	test   %eax,%eax
  800fef:	75 0c                	jne    800ffd <strtol+0x6a>
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800ff1:	b0 0a                	mov    $0xa,%al
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
  800ff3:	80 3a 30             	cmpb   $0x30,(%edx)
  800ff6:	75 05                	jne    800ffd <strtol+0x6a>
    s++, base = 8;
  800ff8:	83 c2 01             	add    $0x1,%edx
  800ffb:	b0 08                	mov    $0x8,%al
  else if (base == 0)
    base = 10;
  800ffd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801002:	89 45 10             	mov    %eax,0x10(%ebp)

  // digits
  while (1) {
    int dig;

    if (*s >= '0' && *s <= '9')
  801005:	0f b6 0a             	movzbl (%edx),%ecx
  801008:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80100b:	89 f0                	mov    %esi,%eax
  80100d:	3c 09                	cmp    $0x9,%al
  80100f:	77 08                	ja     801019 <strtol+0x86>
      dig = *s - '0';
  801011:	0f be c9             	movsbl %cl,%ecx
  801014:	83 e9 30             	sub    $0x30,%ecx
  801017:	eb 20                	jmp    801039 <strtol+0xa6>
    else if (*s >= 'a' && *s <= 'z')
  801019:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80101c:	89 f0                	mov    %esi,%eax
  80101e:	3c 19                	cmp    $0x19,%al
  801020:	77 08                	ja     80102a <strtol+0x97>
      dig = *s - 'a' + 10;
  801022:	0f be c9             	movsbl %cl,%ecx
  801025:	83 e9 57             	sub    $0x57,%ecx
  801028:	eb 0f                	jmp    801039 <strtol+0xa6>
    else if (*s >= 'A' && *s <= 'Z')
  80102a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  80102d:	89 f0                	mov    %esi,%eax
  80102f:	3c 19                	cmp    $0x19,%al
  801031:	77 16                	ja     801049 <strtol+0xb6>
      dig = *s - 'A' + 10;
  801033:	0f be c9             	movsbl %cl,%ecx
  801036:	83 e9 37             	sub    $0x37,%ecx
    else
      break;
    if (dig >= base)
  801039:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80103c:	7d 0f                	jge    80104d <strtol+0xba>
      break;
    s++, val = (val * base) + dig;
  80103e:	83 c2 01             	add    $0x1,%edx
  801041:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801045:	01 cb                	add    %ecx,%ebx
    // we don't properly detect overflow!
  }
  801047:	eb bc                	jmp    801005 <strtol+0x72>
  801049:	89 d8                	mov    %ebx,%eax
  80104b:	eb 02                	jmp    80104f <strtol+0xbc>
  80104d:	89 d8                	mov    %ebx,%eax

  if (endptr)
  80104f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801053:	74 05                	je     80105a <strtol+0xc7>
    *endptr = (char*)s;
  801055:	8b 75 0c             	mov    0xc(%ebp),%esi
  801058:	89 16                	mov    %edx,(%esi)
  return neg ? -val : val;
  80105a:	f7 d8                	neg    %eax
  80105c:	85 ff                	test   %edi,%edi
  80105e:	0f 44 c3             	cmove  %ebx,%eax
}
  801061:	5b                   	pop    %ebx
  801062:	5e                   	pop    %esi
  801063:	5f                   	pop    %edi
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    

00801066 <sys_cputs>:
  return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	57                   	push   %edi
  80106a:	56                   	push   %esi
  80106b:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  80106c:	b8 00 00 00 00       	mov    $0x0,%eax
  801071:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801074:	8b 55 08             	mov    0x8(%ebp),%edx
  801077:	89 c3                	mov    %eax,%ebx
  801079:	89 c7                	mov    %eax,%edi
  80107b:	89 c6                	mov    %eax,%esi
  80107d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
  syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80107f:	5b                   	pop    %ebx
  801080:	5e                   	pop    %esi
  801081:	5f                   	pop    %edi
  801082:	5d                   	pop    %ebp
  801083:	c3                   	ret    

00801084 <sys_cgetc>:

int
sys_cgetc(void)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	57                   	push   %edi
  801088:	56                   	push   %esi
  801089:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  80108a:	ba 00 00 00 00       	mov    $0x0,%edx
  80108f:	b8 01 00 00 00       	mov    $0x1,%eax
  801094:	89 d1                	mov    %edx,%ecx
  801096:	89 d3                	mov    %edx,%ebx
  801098:	89 d7                	mov    %edx,%edi
  80109a:	89 d6                	mov    %edx,%esi
  80109c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80109e:	5b                   	pop    %ebx
  80109f:	5e                   	pop    %esi
  8010a0:	5f                   	pop    %edi
  8010a1:	5d                   	pop    %ebp
  8010a2:	c3                   	ret    

008010a3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	57                   	push   %edi
  8010a7:	56                   	push   %esi
  8010a8:	53                   	push   %ebx
  8010a9:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8010ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010b1:	b8 03 00 00 00       	mov    $0x3,%eax
  8010b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b9:	89 cb                	mov    %ecx,%ebx
  8010bb:	89 cf                	mov    %ecx,%edi
  8010bd:	89 ce                	mov    %ecx,%esi
  8010bf:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	7e 28                	jle    8010ed <sys_env_destroy+0x4a>
    panic("syscall %d returned %d (> 0)", num, ret);
  8010c5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010c9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8010d0:	00 
  8010d1:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  8010d8:	00 
  8010d9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010e0:	00 
  8010e1:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  8010e8:	e8 09 f5 ff ff       	call   8005f6 <_panic>

int
sys_env_destroy(envid_t envid)
{
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010ed:	83 c4 2c             	add    $0x2c,%esp
  8010f0:	5b                   	pop    %ebx
  8010f1:	5e                   	pop    %esi
  8010f2:	5f                   	pop    %edi
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    

008010f5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	57                   	push   %edi
  8010f9:	56                   	push   %esi
  8010fa:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8010fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801100:	b8 02 00 00 00       	mov    $0x2,%eax
  801105:	89 d1                	mov    %edx,%ecx
  801107:	89 d3                	mov    %edx,%ebx
  801109:	89 d7                	mov    %edx,%edi
  80110b:	89 d6                	mov    %edx,%esi
  80110d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80110f:	5b                   	pop    %ebx
  801110:	5e                   	pop    %esi
  801111:	5f                   	pop    %edi
  801112:	5d                   	pop    %ebp
  801113:	c3                   	ret    

00801114 <sys_yield>:

void
sys_yield(void)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	57                   	push   %edi
  801118:	56                   	push   %esi
  801119:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  80111a:	ba 00 00 00 00       	mov    $0x0,%edx
  80111f:	b8 0b 00 00 00       	mov    $0xb,%eax
  801124:	89 d1                	mov    %edx,%ecx
  801126:	89 d3                	mov    %edx,%ebx
  801128:	89 d7                	mov    %edx,%edi
  80112a:	89 d6                	mov    %edx,%esi
  80112c:	cd 30                	int    $0x30

void
sys_yield(void)
{
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80112e:	5b                   	pop    %ebx
  80112f:	5e                   	pop    %esi
  801130:	5f                   	pop    %edi
  801131:	5d                   	pop    %ebp
  801132:	c3                   	ret    

00801133 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801133:	55                   	push   %ebp
  801134:	89 e5                	mov    %esp,%ebp
  801136:	57                   	push   %edi
  801137:	56                   	push   %esi
  801138:	53                   	push   %ebx
  801139:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  80113c:	be 00 00 00 00       	mov    $0x0,%esi
  801141:	b8 04 00 00 00       	mov    $0x4,%eax
  801146:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801149:	8b 55 08             	mov    0x8(%ebp),%edx
  80114c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80114f:	89 f7                	mov    %esi,%edi
  801151:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  801153:	85 c0                	test   %eax,%eax
  801155:	7e 28                	jle    80117f <sys_page_alloc+0x4c>
    panic("syscall %d returned %d (> 0)", num, ret);
  801157:	89 44 24 10          	mov    %eax,0x10(%esp)
  80115b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801162:	00 
  801163:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  80116a:	00 
  80116b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801172:	00 
  801173:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  80117a:	e8 77 f4 ff ff       	call   8005f6 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  return syscall(SYS_page_alloc, 1, envid, (uint32_t)va, perm, 0, 0);
}
  80117f:	83 c4 2c             	add    $0x2c,%esp
  801182:	5b                   	pop    %ebx
  801183:	5e                   	pop    %esi
  801184:	5f                   	pop    %edi
  801185:	5d                   	pop    %ebp
  801186:	c3                   	ret    

00801187 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	57                   	push   %edi
  80118b:	56                   	push   %esi
  80118c:	53                   	push   %ebx
  80118d:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  801190:	b8 05 00 00 00       	mov    $0x5,%eax
  801195:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801198:	8b 55 08             	mov    0x8(%ebp),%edx
  80119b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80119e:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011a1:	8b 75 18             	mov    0x18(%ebp),%esi
  8011a4:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  8011a6:	85 c0                	test   %eax,%eax
  8011a8:	7e 28                	jle    8011d2 <sys_page_map+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  8011aa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011ae:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8011b5:	00 
  8011b6:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  8011bd:	00 
  8011be:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011c5:	00 
  8011c6:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  8011cd:	e8 24 f4 ff ff       	call   8005f6 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  return syscall(SYS_page_map, 1, srcenv, (uint32_t)srcva, dstenv, (uint32_t)dstva, perm);
}
  8011d2:	83 c4 2c             	add    $0x2c,%esp
  8011d5:	5b                   	pop    %ebx
  8011d6:	5e                   	pop    %esi
  8011d7:	5f                   	pop    %edi
  8011d8:	5d                   	pop    %ebp
  8011d9:	c3                   	ret    

008011da <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	57                   	push   %edi
  8011de:	56                   	push   %esi
  8011df:	53                   	push   %ebx
  8011e0:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8011e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e8:	b8 06 00 00 00       	mov    $0x6,%eax
  8011ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f3:	89 df                	mov    %ebx,%edi
  8011f5:	89 de                	mov    %ebx,%esi
  8011f7:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  8011f9:	85 c0                	test   %eax,%eax
  8011fb:	7e 28                	jle    801225 <sys_page_unmap+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  8011fd:	89 44 24 10          	mov    %eax,0x10(%esp)
  801201:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801208:	00 
  801209:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  801210:	00 
  801211:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801218:	00 
  801219:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  801220:	e8 d1 f3 ff ff       	call   8005f6 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
  return syscall(SYS_page_unmap, 1, envid, (uint32_t)va, 0, 0, 0);
}
  801225:	83 c4 2c             	add    $0x2c,%esp
  801228:	5b                   	pop    %ebx
  801229:	5e                   	pop    %esi
  80122a:	5f                   	pop    %edi
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    

0080122d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	57                   	push   %edi
  801231:	56                   	push   %esi
  801232:	53                   	push   %ebx
  801233:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  801236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80123b:	b8 08 00 00 00       	mov    $0x8,%eax
  801240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801243:	8b 55 08             	mov    0x8(%ebp),%edx
  801246:	89 df                	mov    %ebx,%edi
  801248:	89 de                	mov    %ebx,%esi
  80124a:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  80124c:	85 c0                	test   %eax,%eax
  80124e:	7e 28                	jle    801278 <sys_env_set_status+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  801250:	89 44 24 10          	mov    %eax,0x10(%esp)
  801254:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80125b:	00 
  80125c:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  801263:	00 
  801264:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80126b:	00 
  80126c:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  801273:	e8 7e f3 ff ff       	call   8005f6 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801278:	83 c4 2c             	add    $0x2c,%esp
  80127b:	5b                   	pop    %ebx
  80127c:	5e                   	pop    %esi
  80127d:	5f                   	pop    %edi
  80127e:	5d                   	pop    %ebp
  80127f:	c3                   	ret    

00801280 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
  801283:	57                   	push   %edi
  801284:	56                   	push   %esi
  801285:	53                   	push   %ebx
  801286:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  801289:	bb 00 00 00 00       	mov    $0x0,%ebx
  80128e:	b8 09 00 00 00       	mov    $0x9,%eax
  801293:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801296:	8b 55 08             	mov    0x8(%ebp),%edx
  801299:	89 df                	mov    %ebx,%edi
  80129b:	89 de                	mov    %ebx,%esi
  80129d:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  80129f:	85 c0                	test   %eax,%eax
  8012a1:	7e 28                	jle    8012cb <sys_env_set_trapframe+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  8012a3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012a7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8012ae:	00 
  8012af:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  8012b6:	00 
  8012b7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012be:	00 
  8012bf:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  8012c6:	e8 2b f3 ff ff       	call   8005f6 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t)tf, 0, 0, 0);
}
  8012cb:	83 c4 2c             	add    $0x2c,%esp
  8012ce:	5b                   	pop    %ebx
  8012cf:	5e                   	pop    %esi
  8012d0:	5f                   	pop    %edi
  8012d1:	5d                   	pop    %ebp
  8012d2:	c3                   	ret    

008012d3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012d3:	55                   	push   %ebp
  8012d4:	89 e5                	mov    %esp,%ebp
  8012d6:	57                   	push   %edi
  8012d7:	56                   	push   %esi
  8012d8:	53                   	push   %ebx
  8012d9:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8012dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012e1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8012e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ec:	89 df                	mov    %ebx,%edi
  8012ee:	89 de                	mov    %ebx,%esi
  8012f0:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  8012f2:	85 c0                	test   %eax,%eax
  8012f4:	7e 28                	jle    80131e <sys_env_set_pgfault_upcall+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  8012f6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012fa:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801301:	00 
  801302:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  801309:	00 
  80130a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801311:	00 
  801312:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  801319:	e8 d8 f2 ff ff       	call   8005f6 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80131e:	83 c4 2c             	add    $0x2c,%esp
  801321:	5b                   	pop    %ebx
  801322:	5e                   	pop    %esi
  801323:	5f                   	pop    %edi
  801324:	5d                   	pop    %ebp
  801325:	c3                   	ret    

00801326 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	57                   	push   %edi
  80132a:	56                   	push   %esi
  80132b:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  80132c:	be 00 00 00 00       	mov    $0x0,%esi
  801331:	b8 0c 00 00 00       	mov    $0xc,%eax
  801336:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801339:	8b 55 08             	mov    0x8(%ebp),%edx
  80133c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80133f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801342:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t)srcva, perm, 0);
}
  801344:	5b                   	pop    %ebx
  801345:	5e                   	pop    %esi
  801346:	5f                   	pop    %edi
  801347:	5d                   	pop    %ebp
  801348:	c3                   	ret    

00801349 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801349:	55                   	push   %ebp
  80134a:	89 e5                	mov    %esp,%ebp
  80134c:	57                   	push   %edi
  80134d:	56                   	push   %esi
  80134e:	53                   	push   %ebx
  80134f:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  801352:	b9 00 00 00 00       	mov    $0x0,%ecx
  801357:	b8 0d 00 00 00       	mov    $0xd,%eax
  80135c:	8b 55 08             	mov    0x8(%ebp),%edx
  80135f:	89 cb                	mov    %ecx,%ebx
  801361:	89 cf                	mov    %ecx,%edi
  801363:	89 ce                	mov    %ecx,%esi
  801365:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  801367:	85 c0                	test   %eax,%eax
  801369:	7e 28                	jle    801393 <sys_ipc_recv+0x4a>
    panic("syscall %d returned %d (> 0)", num, ret);
  80136b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80136f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801376:	00 
  801377:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  80137e:	00 
  80137f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801386:	00 
  801387:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  80138e:	e8 63 f2 ff ff       	call   8005f6 <_panic>

int
sys_ipc_recv(void *dstva)
{
  return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801393:	83 c4 2c             	add    $0x2c,%esp
  801396:	5b                   	pop    %ebx
  801397:	5e                   	pop    %esi
  801398:	5f                   	pop    %edi
  801399:	5d                   	pop    %ebp
  80139a:	c3                   	ret    

0080139b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80139b:	55                   	push   %ebp
  80139c:	89 e5                	mov    %esp,%ebp
  80139e:	83 ec 18             	sub    $0x18,%esp
  int r;

  if (_pgfault_handler == 0) {
  8013a1:	83 3d b4 40 80 00 00 	cmpl   $0x0,0x8040b4
  8013a8:	75 70                	jne    80141a <set_pgfault_handler+0x7f>
    // First time through!
    // LAB 4: Your code here.
    if(sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_SYSCALL) < 0) {
  8013aa:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  8013b1:	00 
  8013b2:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8013b9:	ee 
  8013ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013c1:	e8 6d fd ff ff       	call   801133 <sys_page_alloc>
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	79 1c                	jns    8013e6 <set_pgfault_handler+0x4b>
      panic("In set_pgfault_handler, sys_page_alloc error");
  8013ca:	c7 44 24 08 0c 2a 80 	movl   $0x802a0c,0x8(%esp)
  8013d1:	00 
  8013d2:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8013d9:	00 
  8013da:	c7 04 24 75 2a 80 00 	movl   $0x802a75,(%esp)
  8013e1:	e8 10 f2 ff ff       	call   8005f6 <_panic>
    }
    if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  8013e6:	c7 44 24 04 24 14 80 	movl   $0x801424,0x4(%esp)
  8013ed:	00 
  8013ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013f5:	e8 d9 fe ff ff       	call   8012d3 <sys_env_set_pgfault_upcall>
  8013fa:	85 c0                	test   %eax,%eax
  8013fc:	79 1c                	jns    80141a <set_pgfault_handler+0x7f>
      panic("In set_pgfault_handler, sys_env_set_pgfault_upcall error");
  8013fe:	c7 44 24 08 3c 2a 80 	movl   $0x802a3c,0x8(%esp)
  801405:	00 
  801406:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  80140d:	00 
  80140e:	c7 04 24 75 2a 80 00 	movl   $0x802a75,(%esp)
  801415:	e8 dc f1 ff ff       	call   8005f6 <_panic>
    }
  }
  // Save handler pointer for assembly to call.
  _pgfault_handler = handler;
  80141a:	8b 45 08             	mov    0x8(%ebp),%eax
  80141d:	a3 b4 40 80 00       	mov    %eax,0x8040b4
}
  801422:	c9                   	leave  
  801423:	c3                   	ret    

00801424 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801424:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801425:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	call *%eax
  80142a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80142c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
  subl $0x4, 0x30(%esp)
  80142f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
  movl 0x30(%esp), %eax
  801434:	8b 44 24 30          	mov    0x30(%esp),%eax
  movl 0x28(%esp), %ebx
  801438:	8b 5c 24 28          	mov    0x28(%esp),%ebx
  movl %ebx, (%eax)
  80143c:	89 18                	mov    %ebx,(%eax)


	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
  addl $0x8, %esp
  80143e:	83 c4 08             	add    $0x8,%esp
  popal
  801441:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
  addl $0x4, %esp
  801442:	83 c4 04             	add    $0x4,%esp
  popfl
  801445:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
  movl (%esp), %esp
  801446:	8b 24 24             	mov    (%esp),%esp

  // Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  ret
  801449:	c3                   	ret    
  80144a:	66 90                	xchg   %ax,%ax
  80144c:	66 90                	xchg   %ax,%ax
  80144e:	66 90                	xchg   %ax,%ax

00801450 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  801453:	8b 45 08             	mov    0x8(%ebp),%eax
  801456:	05 00 00 00 30       	add    $0x30000000,%eax
  80145b:	c1 e8 0c             	shr    $0xc,%eax
}
  80145e:	5d                   	pop    %ebp
  80145f:	c3                   	ret    

00801460 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  801463:	8b 45 08             	mov    0x8(%ebp),%eax
  801466:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
  return INDEX2DATA(fd2num(fd));
  80146b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801470:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801475:	5d                   	pop    %ebp
  801476:	c3                   	ret    

00801477 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801477:	55                   	push   %ebp
  801478:	89 e5                	mov    %esp,%ebp
  80147a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80147d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
  int i;
  struct Fd *fd;

  for (i = 0; i < MAXFD; i++) {
    fd = INDEX2FD(i);
    if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801482:	89 c2                	mov    %eax,%edx
  801484:	c1 ea 16             	shr    $0x16,%edx
  801487:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80148e:	f6 c2 01             	test   $0x1,%dl
  801491:	74 11                	je     8014a4 <fd_alloc+0x2d>
  801493:	89 c2                	mov    %eax,%edx
  801495:	c1 ea 0c             	shr    $0xc,%edx
  801498:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80149f:	f6 c2 01             	test   $0x1,%dl
  8014a2:	75 09                	jne    8014ad <fd_alloc+0x36>
      *fd_store = fd;
  8014a4:	89 01                	mov    %eax,(%ecx)
      return 0;
  8014a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ab:	eb 17                	jmp    8014c4 <fd_alloc+0x4d>
  8014ad:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
  int i;
  struct Fd *fd;

  for (i = 0; i < MAXFD; i++) {
  8014b2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014b7:	75 c9                	jne    801482 <fd_alloc+0xb>
    if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
      *fd_store = fd;
      return 0;
    }
  }
  *fd_store = 0;
  8014b9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
  return -E_MAX_OPEN;
  8014bf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014c4:	5d                   	pop    %ebp
  8014c5:	c3                   	ret    

008014c6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014c6:	55                   	push   %ebp
  8014c7:	89 e5                	mov    %esp,%ebp
  8014c9:	8b 45 08             	mov    0x8(%ebp),%eax
  struct Fd *fd;

  if (fdnum < 0 || fdnum >= MAXFD) {
  8014cc:	83 f8 1f             	cmp    $0x1f,%eax
  8014cf:	77 36                	ja     801507 <fd_lookup+0x41>
    if (debug)
      cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  fd = INDEX2FD(fdnum);
  8014d1:	c1 e0 0c             	shl    $0xc,%eax
  8014d4:	2d 00 00 00 30       	sub    $0x30000000,%eax
  if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014d9:	89 c2                	mov    %eax,%edx
  8014db:	c1 ea 16             	shr    $0x16,%edx
  8014de:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014e5:	f6 c2 01             	test   $0x1,%dl
  8014e8:	74 24                	je     80150e <fd_lookup+0x48>
  8014ea:	89 c2                	mov    %eax,%edx
  8014ec:	c1 ea 0c             	shr    $0xc,%edx
  8014ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014f6:	f6 c2 01             	test   $0x1,%dl
  8014f9:	74 1a                	je     801515 <fd_lookup+0x4f>
    if (debug)
      cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  *fd_store = fd;
  8014fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014fe:	89 02                	mov    %eax,(%edx)
  return 0;
  801500:	b8 00 00 00 00       	mov    $0x0,%eax
  801505:	eb 13                	jmp    80151a <fd_lookup+0x54>
  struct Fd *fd;

  if (fdnum < 0 || fdnum >= MAXFD) {
    if (debug)
      cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  801507:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80150c:	eb 0c                	jmp    80151a <fd_lookup+0x54>
  }
  fd = INDEX2FD(fdnum);
  if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
    if (debug)
      cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  80150e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801513:	eb 05                	jmp    80151a <fd_lookup+0x54>
  801515:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  }
  *fd_store = fd;
  return 0;
}
  80151a:	5d                   	pop    %ebp
  80151b:	c3                   	ret    

0080151c <dev_lookup>:
  0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80151c:	55                   	push   %ebp
  80151d:	89 e5                	mov    %esp,%ebp
  80151f:	83 ec 18             	sub    $0x18,%esp
  801522:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801525:	ba 04 2b 80 00       	mov    $0x802b04,%edx
  int i;

  for (i = 0; devtab[i]; i++)
  80152a:	eb 13                	jmp    80153f <dev_lookup+0x23>
  80152c:	83 c2 04             	add    $0x4,%edx
    if (devtab[i]->dev_id == dev_id) {
  80152f:	39 08                	cmp    %ecx,(%eax)
  801531:	75 0c                	jne    80153f <dev_lookup+0x23>
      *dev = devtab[i];
  801533:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801536:	89 01                	mov    %eax,(%ecx)
      return 0;
  801538:	b8 00 00 00 00       	mov    $0x0,%eax
  80153d:	eb 30                	jmp    80156f <dev_lookup+0x53>
int
dev_lookup(int dev_id, struct Dev **dev)
{
  int i;

  for (i = 0; devtab[i]; i++)
  80153f:	8b 02                	mov    (%edx),%eax
  801541:	85 c0                	test   %eax,%eax
  801543:	75 e7                	jne    80152c <dev_lookup+0x10>
    if (devtab[i]->dev_id == dev_id) {
      *dev = devtab[i];
      return 0;
    }
  cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801545:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80154a:	8b 40 48             	mov    0x48(%eax),%eax
  80154d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801551:	89 44 24 04          	mov    %eax,0x4(%esp)
  801555:	c7 04 24 84 2a 80 00 	movl   $0x802a84,(%esp)
  80155c:	e8 8e f1 ff ff       	call   8006ef <cprintf>
  *dev = 0;
  801561:	8b 45 0c             	mov    0xc(%ebp),%eax
  801564:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  return -E_INVAL;
  80156a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80156f:	c9                   	leave  
  801570:	c3                   	ret    

00801571 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801571:	55                   	push   %ebp
  801572:	89 e5                	mov    %esp,%ebp
  801574:	56                   	push   %esi
  801575:	53                   	push   %ebx
  801576:	83 ec 20             	sub    $0x20,%esp
  801579:	8b 75 08             	mov    0x8(%ebp),%esi
  80157c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct Fd *fd2;
  struct Dev *dev;
  int r;

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80157f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801582:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  801586:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80158c:	c1 e8 0c             	shr    $0xc,%eax
{
  struct Fd *fd2;
  struct Dev *dev;
  int r;

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80158f:	89 04 24             	mov    %eax,(%esp)
  801592:	e8 2f ff ff ff       	call   8014c6 <fd_lookup>
  801597:	85 c0                	test   %eax,%eax
  801599:	78 05                	js     8015a0 <fd_close+0x2f>
      || fd != fd2)
  80159b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80159e:	74 0c                	je     8015ac <fd_close+0x3b>
    return must_exist ? r : 0;
  8015a0:	84 db                	test   %bl,%bl
  8015a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a7:	0f 44 c2             	cmove  %edx,%eax
  8015aa:	eb 3f                	jmp    8015eb <fd_close+0x7a>
  if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b3:	8b 06                	mov    (%esi),%eax
  8015b5:	89 04 24             	mov    %eax,(%esp)
  8015b8:	e8 5f ff ff ff       	call   80151c <dev_lookup>
  8015bd:	89 c3                	mov    %eax,%ebx
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	78 16                	js     8015d9 <fd_close+0x68>
    if (dev->dev_close)
  8015c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c6:	8b 40 10             	mov    0x10(%eax),%eax
      r = (*dev->dev_close)(fd);
    else
      r = 0;
  8015c9:	bb 00 00 00 00       	mov    $0x0,%ebx

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
      || fd != fd2)
    return must_exist ? r : 0;
  if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
    if (dev->dev_close)
  8015ce:	85 c0                	test   %eax,%eax
  8015d0:	74 07                	je     8015d9 <fd_close+0x68>
      r = (*dev->dev_close)(fd);
  8015d2:	89 34 24             	mov    %esi,(%esp)
  8015d5:	ff d0                	call   *%eax
  8015d7:	89 c3                	mov    %eax,%ebx
    else
      r = 0;
  }
  // Make sure fd is unmapped.  Might be a no-op if
  // (*dev->dev_close)(fd) already unmapped it.
  (void)sys_page_unmap(0, fd);
  8015d9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015e4:	e8 f1 fb ff ff       	call   8011da <sys_page_unmap>
  return r;
  8015e9:	89 d8                	mov    %ebx,%eax
}
  8015eb:	83 c4 20             	add    $0x20,%esp
  8015ee:	5b                   	pop    %ebx
  8015ef:	5e                   	pop    %esi
  8015f0:	5d                   	pop    %ebp
  8015f1:	c3                   	ret    

008015f2 <close>:
  return -E_INVAL;
}

int
close(int fdnum)
{
  8015f2:	55                   	push   %ebp
  8015f3:	89 e5                	mov    %esp,%ebp
  8015f5:	83 ec 28             	sub    $0x28,%esp
  struct Fd *fd;
  int r;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801602:	89 04 24             	mov    %eax,(%esp)
  801605:	e8 bc fe ff ff       	call   8014c6 <fd_lookup>
  80160a:	89 c2                	mov    %eax,%edx
  80160c:	85 d2                	test   %edx,%edx
  80160e:	78 13                	js     801623 <close+0x31>
    return r;
  else
    return fd_close(fd, 1);
  801610:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801617:	00 
  801618:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80161b:	89 04 24             	mov    %eax,(%esp)
  80161e:	e8 4e ff ff ff       	call   801571 <fd_close>
}
  801623:	c9                   	leave  
  801624:	c3                   	ret    

00801625 <close_all>:

void
close_all(void)
{
  801625:	55                   	push   %ebp
  801626:	89 e5                	mov    %esp,%ebp
  801628:	53                   	push   %ebx
  801629:	83 ec 14             	sub    $0x14,%esp
  int i;

  for (i = 0; i < MAXFD; i++)
  80162c:	bb 00 00 00 00       	mov    $0x0,%ebx
    close(i);
  801631:	89 1c 24             	mov    %ebx,(%esp)
  801634:	e8 b9 ff ff ff       	call   8015f2 <close>
void
close_all(void)
{
  int i;

  for (i = 0; i < MAXFD; i++)
  801639:	83 c3 01             	add    $0x1,%ebx
  80163c:	83 fb 20             	cmp    $0x20,%ebx
  80163f:	75 f0                	jne    801631 <close_all+0xc>
    close(i);
}
  801641:	83 c4 14             	add    $0x14,%esp
  801644:	5b                   	pop    %ebx
  801645:	5d                   	pop    %ebp
  801646:	c3                   	ret    

00801647 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	57                   	push   %edi
  80164b:	56                   	push   %esi
  80164c:	53                   	push   %ebx
  80164d:	83 ec 3c             	sub    $0x3c,%esp
  int r;
  char *ova, *nva;
  pte_t pte;
  struct Fd *oldfd, *newfd;

  if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801650:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801653:	89 44 24 04          	mov    %eax,0x4(%esp)
  801657:	8b 45 08             	mov    0x8(%ebp),%eax
  80165a:	89 04 24             	mov    %eax,(%esp)
  80165d:	e8 64 fe ff ff       	call   8014c6 <fd_lookup>
  801662:	89 c2                	mov    %eax,%edx
  801664:	85 d2                	test   %edx,%edx
  801666:	0f 88 e1 00 00 00    	js     80174d <dup+0x106>
    return r;
  close(newfdnum);
  80166c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80166f:	89 04 24             	mov    %eax,(%esp)
  801672:	e8 7b ff ff ff       	call   8015f2 <close>

  newfd = INDEX2FD(newfdnum);
  801677:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80167a:	c1 e3 0c             	shl    $0xc,%ebx
  80167d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
  ova = fd2data(oldfd);
  801683:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801686:	89 04 24             	mov    %eax,(%esp)
  801689:	e8 d2 fd ff ff       	call   801460 <fd2data>
  80168e:	89 c6                	mov    %eax,%esi
  nva = fd2data(newfd);
  801690:	89 1c 24             	mov    %ebx,(%esp)
  801693:	e8 c8 fd ff ff       	call   801460 <fd2data>
  801698:	89 c7                	mov    %eax,%edi

  if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80169a:	89 f0                	mov    %esi,%eax
  80169c:	c1 e8 16             	shr    $0x16,%eax
  80169f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016a6:	a8 01                	test   $0x1,%al
  8016a8:	74 43                	je     8016ed <dup+0xa6>
  8016aa:	89 f0                	mov    %esi,%eax
  8016ac:	c1 e8 0c             	shr    $0xc,%eax
  8016af:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016b6:	f6 c2 01             	test   $0x1,%dl
  8016b9:	74 32                	je     8016ed <dup+0xa6>
    if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016bb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016c2:	25 07 0e 00 00       	and    $0xe07,%eax
  8016c7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8016cf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016d6:	00 
  8016d7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016e2:	e8 a0 fa ff ff       	call   801187 <sys_page_map>
  8016e7:	89 c6                	mov    %eax,%esi
  8016e9:	85 c0                	test   %eax,%eax
  8016eb:	78 3e                	js     80172b <dup+0xe4>
      goto err;
  if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016f0:	89 c2                	mov    %eax,%edx
  8016f2:	c1 ea 0c             	shr    $0xc,%edx
  8016f5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016fc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801702:	89 54 24 10          	mov    %edx,0x10(%esp)
  801706:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80170a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801711:	00 
  801712:	89 44 24 04          	mov    %eax,0x4(%esp)
  801716:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80171d:	e8 65 fa ff ff       	call   801187 <sys_page_map>
  801722:	89 c6                	mov    %eax,%esi
    goto err;

  return newfdnum;
  801724:	8b 45 0c             	mov    0xc(%ebp),%eax
  nva = fd2data(newfd);

  if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
    if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
      goto err;
  if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801727:	85 f6                	test   %esi,%esi
  801729:	79 22                	jns    80174d <dup+0x106>
    goto err;

  return newfdnum;

err:
  sys_page_unmap(0, newfd);
  80172b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80172f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801736:	e8 9f fa ff ff       	call   8011da <sys_page_unmap>
  sys_page_unmap(0, nva);
  80173b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80173f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801746:	e8 8f fa ff ff       	call   8011da <sys_page_unmap>
  return r;
  80174b:	89 f0                	mov    %esi,%eax
}
  80174d:	83 c4 3c             	add    $0x3c,%esp
  801750:	5b                   	pop    %ebx
  801751:	5e                   	pop    %esi
  801752:	5f                   	pop    %edi
  801753:	5d                   	pop    %ebp
  801754:	c3                   	ret    

00801755 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	53                   	push   %ebx
  801759:	83 ec 24             	sub    $0x24,%esp
  80175c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  80175f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801762:	89 44 24 04          	mov    %eax,0x4(%esp)
  801766:	89 1c 24             	mov    %ebx,(%esp)
  801769:	e8 58 fd ff ff       	call   8014c6 <fd_lookup>
  80176e:	89 c2                	mov    %eax,%edx
  801770:	85 d2                	test   %edx,%edx
  801772:	78 6d                	js     8017e1 <read+0x8c>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801774:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801777:	89 44 24 04          	mov    %eax,0x4(%esp)
  80177b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80177e:	8b 00                	mov    (%eax),%eax
  801780:	89 04 24             	mov    %eax,(%esp)
  801783:	e8 94 fd ff ff       	call   80151c <dev_lookup>
  801788:	85 c0                	test   %eax,%eax
  80178a:	78 55                	js     8017e1 <read+0x8c>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80178c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80178f:	8b 50 08             	mov    0x8(%eax),%edx
  801792:	83 e2 03             	and    $0x3,%edx
  801795:	83 fa 01             	cmp    $0x1,%edx
  801798:	75 23                	jne    8017bd <read+0x68>
    cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80179a:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80179f:	8b 40 48             	mov    0x48(%eax),%eax
  8017a2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017aa:	c7 04 24 c8 2a 80 00 	movl   $0x802ac8,(%esp)
  8017b1:	e8 39 ef ff ff       	call   8006ef <cprintf>
    return -E_INVAL;
  8017b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017bb:	eb 24                	jmp    8017e1 <read+0x8c>
  }
  if (!dev->dev_read)
  8017bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017c0:	8b 52 08             	mov    0x8(%edx),%edx
  8017c3:	85 d2                	test   %edx,%edx
  8017c5:	74 15                	je     8017dc <read+0x87>
    return -E_NOT_SUPP;
  return (*dev->dev_read)(fd, buf, n);
  8017c7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017ca:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017d1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017d5:	89 04 24             	mov    %eax,(%esp)
  8017d8:	ff d2                	call   *%edx
  8017da:	eb 05                	jmp    8017e1 <read+0x8c>
  if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
    cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  if (!dev->dev_read)
    return -E_NOT_SUPP;
  8017dc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_read)(fd, buf, n);
}
  8017e1:	83 c4 24             	add    $0x24,%esp
  8017e4:	5b                   	pop    %ebx
  8017e5:	5d                   	pop    %ebp
  8017e6:	c3                   	ret    

008017e7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	57                   	push   %edi
  8017eb:	56                   	push   %esi
  8017ec:	53                   	push   %ebx
  8017ed:	83 ec 1c             	sub    $0x1c,%esp
  8017f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017f3:	8b 75 10             	mov    0x10(%ebp),%esi
  int m, tot;

  for (tot = 0; tot < n; tot += m) {
  8017f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017fb:	eb 23                	jmp    801820 <readn+0x39>
    m = read(fdnum, (char*)buf + tot, n - tot);
  8017fd:	89 f0                	mov    %esi,%eax
  8017ff:	29 d8                	sub    %ebx,%eax
  801801:	89 44 24 08          	mov    %eax,0x8(%esp)
  801805:	89 d8                	mov    %ebx,%eax
  801807:	03 45 0c             	add    0xc(%ebp),%eax
  80180a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80180e:	89 3c 24             	mov    %edi,(%esp)
  801811:	e8 3f ff ff ff       	call   801755 <read>
    if (m < 0)
  801816:	85 c0                	test   %eax,%eax
  801818:	78 10                	js     80182a <readn+0x43>
      return m;
    if (m == 0)
  80181a:	85 c0                	test   %eax,%eax
  80181c:	74 0a                	je     801828 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
  int m, tot;

  for (tot = 0; tot < n; tot += m) {
  80181e:	01 c3                	add    %eax,%ebx
  801820:	39 f3                	cmp    %esi,%ebx
  801822:	72 d9                	jb     8017fd <readn+0x16>
  801824:	89 d8                	mov    %ebx,%eax
  801826:	eb 02                	jmp    80182a <readn+0x43>
  801828:	89 d8                	mov    %ebx,%eax
      return m;
    if (m == 0)
      break;
  }
  return tot;
}
  80182a:	83 c4 1c             	add    $0x1c,%esp
  80182d:	5b                   	pop    %ebx
  80182e:	5e                   	pop    %esi
  80182f:	5f                   	pop    %edi
  801830:	5d                   	pop    %ebp
  801831:	c3                   	ret    

00801832 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801832:	55                   	push   %ebp
  801833:	89 e5                	mov    %esp,%ebp
  801835:	53                   	push   %ebx
  801836:	83 ec 24             	sub    $0x24,%esp
  801839:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  80183c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80183f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801843:	89 1c 24             	mov    %ebx,(%esp)
  801846:	e8 7b fc ff ff       	call   8014c6 <fd_lookup>
  80184b:	89 c2                	mov    %eax,%edx
  80184d:	85 d2                	test   %edx,%edx
  80184f:	78 68                	js     8018b9 <write+0x87>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801851:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801854:	89 44 24 04          	mov    %eax,0x4(%esp)
  801858:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80185b:	8b 00                	mov    (%eax),%eax
  80185d:	89 04 24             	mov    %eax,(%esp)
  801860:	e8 b7 fc ff ff       	call   80151c <dev_lookup>
  801865:	85 c0                	test   %eax,%eax
  801867:	78 50                	js     8018b9 <write+0x87>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801869:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80186c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801870:	75 23                	jne    801895 <write+0x63>
    cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801872:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801877:	8b 40 48             	mov    0x48(%eax),%eax
  80187a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80187e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801882:	c7 04 24 e4 2a 80 00 	movl   $0x802ae4,(%esp)
  801889:	e8 61 ee ff ff       	call   8006ef <cprintf>
    return -E_INVAL;
  80188e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801893:	eb 24                	jmp    8018b9 <write+0x87>
  }
  if (debug)
    cprintf("write %d %p %d via dev %s\n",
            fdnum, buf, n, dev->dev_name);
  if (!dev->dev_write)
  801895:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801898:	8b 52 0c             	mov    0xc(%edx),%edx
  80189b:	85 d2                	test   %edx,%edx
  80189d:	74 15                	je     8018b4 <write+0x82>
    return -E_NOT_SUPP;
  return (*dev->dev_write)(fd, buf, n);
  80189f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018a2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018a9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018ad:	89 04 24             	mov    %eax,(%esp)
  8018b0:	ff d2                	call   *%edx
  8018b2:	eb 05                	jmp    8018b9 <write+0x87>
  }
  if (debug)
    cprintf("write %d %p %d via dev %s\n",
            fdnum, buf, n, dev->dev_name);
  if (!dev->dev_write)
    return -E_NOT_SUPP;
  8018b4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_write)(fd, buf, n);
}
  8018b9:	83 c4 24             	add    $0x24,%esp
  8018bc:	5b                   	pop    %ebx
  8018bd:	5d                   	pop    %ebp
  8018be:	c3                   	ret    

008018bf <seek>:

int
seek(int fdnum, off_t offset)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	83 ec 18             	sub    $0x18,%esp
  int r;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018c5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cf:	89 04 24             	mov    %eax,(%esp)
  8018d2:	e8 ef fb ff ff       	call   8014c6 <fd_lookup>
  8018d7:	85 c0                	test   %eax,%eax
  8018d9:	78 0e                	js     8018e9 <seek+0x2a>
    return r;
  fd->fd_offset = offset;
  8018db:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018e1:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
  8018e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018e9:	c9                   	leave  
  8018ea:	c3                   	ret    

008018eb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018eb:	55                   	push   %ebp
  8018ec:	89 e5                	mov    %esp,%ebp
  8018ee:	53                   	push   %ebx
  8018ef:	83 ec 24             	sub    $0x24,%esp
  8018f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  8018f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018fc:	89 1c 24             	mov    %ebx,(%esp)
  8018ff:	e8 c2 fb ff ff       	call   8014c6 <fd_lookup>
  801904:	89 c2                	mov    %eax,%edx
  801906:	85 d2                	test   %edx,%edx
  801908:	78 61                	js     80196b <ftruncate+0x80>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80190a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80190d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801911:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801914:	8b 00                	mov    (%eax),%eax
  801916:	89 04 24             	mov    %eax,(%esp)
  801919:	e8 fe fb ff ff       	call   80151c <dev_lookup>
  80191e:	85 c0                	test   %eax,%eax
  801920:	78 49                	js     80196b <ftruncate+0x80>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801922:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801925:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801929:	75 23                	jne    80194e <ftruncate+0x63>
    cprintf("[%08x] ftruncate %d -- bad mode\n",
            thisenv->env_id, fdnum);
  80192b:	a1 b0 40 80 00       	mov    0x8040b0,%eax

  if ((r = fd_lookup(fdnum, &fd)) < 0
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
    cprintf("[%08x] ftruncate %d -- bad mode\n",
  801930:	8b 40 48             	mov    0x48(%eax),%eax
  801933:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801937:	89 44 24 04          	mov    %eax,0x4(%esp)
  80193b:	c7 04 24 a4 2a 80 00 	movl   $0x802aa4,(%esp)
  801942:	e8 a8 ed ff ff       	call   8006ef <cprintf>
            thisenv->env_id, fdnum);
    return -E_INVAL;
  801947:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80194c:	eb 1d                	jmp    80196b <ftruncate+0x80>
  }
  if (!dev->dev_trunc)
  80194e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801951:	8b 52 18             	mov    0x18(%edx),%edx
  801954:	85 d2                	test   %edx,%edx
  801956:	74 0e                	je     801966 <ftruncate+0x7b>
    return -E_NOT_SUPP;
  return (*dev->dev_trunc)(fd, newsize);
  801958:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80195b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80195f:	89 04 24             	mov    %eax,(%esp)
  801962:	ff d2                	call   *%edx
  801964:	eb 05                	jmp    80196b <ftruncate+0x80>
    cprintf("[%08x] ftruncate %d -- bad mode\n",
            thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  if (!dev->dev_trunc)
    return -E_NOT_SUPP;
  801966:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_trunc)(fd, newsize);
}
  80196b:	83 c4 24             	add    $0x24,%esp
  80196e:	5b                   	pop    %ebx
  80196f:	5d                   	pop    %ebp
  801970:	c3                   	ret    

00801971 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801971:	55                   	push   %ebp
  801972:	89 e5                	mov    %esp,%ebp
  801974:	53                   	push   %ebx
  801975:	83 ec 24             	sub    $0x24,%esp
  801978:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  80197b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80197e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801982:	8b 45 08             	mov    0x8(%ebp),%eax
  801985:	89 04 24             	mov    %eax,(%esp)
  801988:	e8 39 fb ff ff       	call   8014c6 <fd_lookup>
  80198d:	89 c2                	mov    %eax,%edx
  80198f:	85 d2                	test   %edx,%edx
  801991:	78 52                	js     8019e5 <fstat+0x74>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801993:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801996:	89 44 24 04          	mov    %eax,0x4(%esp)
  80199a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80199d:	8b 00                	mov    (%eax),%eax
  80199f:	89 04 24             	mov    %eax,(%esp)
  8019a2:	e8 75 fb ff ff       	call   80151c <dev_lookup>
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	78 3a                	js     8019e5 <fstat+0x74>
    return r;
  if (!dev->dev_stat)
  8019ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ae:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019b2:	74 2c                	je     8019e0 <fstat+0x6f>
    return -E_NOT_SUPP;
  stat->st_name[0] = 0;
  8019b4:	c6 03 00             	movb   $0x0,(%ebx)
  stat->st_size = 0;
  8019b7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019be:	00 00 00 
  stat->st_isdir = 0;
  8019c1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019c8:	00 00 00 
  stat->st_dev = dev;
  8019cb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
  return (*dev->dev_stat)(fd, stat);
  8019d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019d5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8019d8:	89 14 24             	mov    %edx,(%esp)
  8019db:	ff 50 14             	call   *0x14(%eax)
  8019de:	eb 05                	jmp    8019e5 <fstat+0x74>

  if ((r = fd_lookup(fdnum, &fd)) < 0
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
    return r;
  if (!dev->dev_stat)
    return -E_NOT_SUPP;
  8019e0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  stat->st_name[0] = 0;
  stat->st_size = 0;
  stat->st_isdir = 0;
  stat->st_dev = dev;
  return (*dev->dev_stat)(fd, stat);
}
  8019e5:	83 c4 24             	add    $0x24,%esp
  8019e8:	5b                   	pop    %ebx
  8019e9:	5d                   	pop    %ebp
  8019ea:	c3                   	ret    

008019eb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019eb:	55                   	push   %ebp
  8019ec:	89 e5                	mov    %esp,%ebp
  8019ee:	56                   	push   %esi
  8019ef:	53                   	push   %ebx
  8019f0:	83 ec 10             	sub    $0x10,%esp
  int fd, r;

  if ((fd = open(path, O_RDONLY)) < 0)
  8019f3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019fa:	00 
  8019fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fe:	89 04 24             	mov    %eax,(%esp)
  801a01:	e8 d2 01 00 00       	call   801bd8 <open>
  801a06:	89 c3                	mov    %eax,%ebx
  801a08:	85 db                	test   %ebx,%ebx
  801a0a:	78 1b                	js     801a27 <stat+0x3c>
    return fd;
  r = fstat(fd, stat);
  801a0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a13:	89 1c 24             	mov    %ebx,(%esp)
  801a16:	e8 56 ff ff ff       	call   801971 <fstat>
  801a1b:	89 c6                	mov    %eax,%esi
  close(fd);
  801a1d:	89 1c 24             	mov    %ebx,(%esp)
  801a20:	e8 cd fb ff ff       	call   8015f2 <close>
  return r;
  801a25:	89 f0                	mov    %esi,%eax
}
  801a27:	83 c4 10             	add    $0x10,%esp
  801a2a:	5b                   	pop    %ebx
  801a2b:	5e                   	pop    %esi
  801a2c:	5d                   	pop    %ebp
  801a2d:	c3                   	ret    

00801a2e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a2e:	55                   	push   %ebp
  801a2f:	89 e5                	mov    %esp,%ebp
  801a31:	56                   	push   %esi
  801a32:	53                   	push   %ebx
  801a33:	83 ec 10             	sub    $0x10,%esp
  801a36:	89 c6                	mov    %eax,%esi
  801a38:	89 d3                	mov    %edx,%ebx
  static envid_t fsenv;

  if (fsenv == 0)
  801a3a:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  801a41:	75 11                	jne    801a54 <fsipc+0x26>
    fsenv = ipc_find_env(ENV_TYPE_FS);
  801a43:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801a4a:	e8 48 08 00 00       	call   802297 <ipc_find_env>
  801a4f:	a3 ac 40 80 00       	mov    %eax,0x8040ac
  static_assert(sizeof(fsipcbuf) == PGSIZE);

  if (debug)
    cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t*)&fsipcbuf);

  ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a54:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a5b:	00 
  801a5c:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801a63:	00 
  801a64:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a68:	a1 ac 40 80 00       	mov    0x8040ac,%eax
  801a6d:	89 04 24             	mov    %eax,(%esp)
  801a70:	e8 b7 07 00 00       	call   80222c <ipc_send>
  return ipc_recv(NULL, dstva, NULL);
  801a75:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a7c:	00 
  801a7d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a88:	e8 19 07 00 00       	call   8021a6 <ipc_recv>
}
  801a8d:	83 c4 10             	add    $0x10,%esp
  801a90:	5b                   	pop    %ebx
  801a91:	5e                   	pop    %esi
  801a92:	5d                   	pop    %ebp
  801a93:	c3                   	ret    

00801a94 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a94:	55                   	push   %ebp
  801a95:	89 e5                	mov    %esp,%ebp
  801a97:	83 ec 08             	sub    $0x8,%esp
  fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9d:	8b 40 0c             	mov    0xc(%eax),%eax
  801aa0:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.set_size.req_size = newsize;
  801aa5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa8:	a3 04 50 80 00       	mov    %eax,0x805004
  return fsipc(FSREQ_SET_SIZE, NULL);
  801aad:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab2:	b8 02 00 00 00       	mov    $0x2,%eax
  801ab7:	e8 72 ff ff ff       	call   801a2e <fsipc>
}
  801abc:	c9                   	leave  
  801abd:	c3                   	ret    

00801abe <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801abe:	55                   	push   %ebp
  801abf:	89 e5                	mov    %esp,%ebp
  801ac1:	83 ec 08             	sub    $0x8,%esp
  fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801ac4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac7:	8b 40 0c             	mov    0xc(%eax),%eax
  801aca:	a3 00 50 80 00       	mov    %eax,0x805000
  return fsipc(FSREQ_FLUSH, NULL);
  801acf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad4:	b8 06 00 00 00       	mov    $0x6,%eax
  801ad9:	e8 50 ff ff ff       	call   801a2e <fsipc>
}
  801ade:	c9                   	leave  
  801adf:	c3                   	ret    

00801ae0 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	53                   	push   %ebx
  801ae4:	83 ec 14             	sub    $0x14,%esp
  801ae7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int r;

  fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801aea:	8b 45 08             	mov    0x8(%ebp),%eax
  801aed:	8b 40 0c             	mov    0xc(%eax),%eax
  801af0:	a3 00 50 80 00       	mov    %eax,0x805000
  if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801af5:	ba 00 00 00 00       	mov    $0x0,%edx
  801afa:	b8 05 00 00 00       	mov    $0x5,%eax
  801aff:	e8 2a ff ff ff       	call   801a2e <fsipc>
  801b04:	89 c2                	mov    %eax,%edx
  801b06:	85 d2                	test   %edx,%edx
  801b08:	78 2b                	js     801b35 <devfile_stat+0x55>
    return r;
  strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b0a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b11:	00 
  801b12:	89 1c 24             	mov    %ebx,(%esp)
  801b15:	e8 fd f1 ff ff       	call   800d17 <strcpy>
  st->st_size = fsipcbuf.statRet.ret_size;
  801b1a:	a1 80 50 80 00       	mov    0x805080,%eax
  801b1f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b25:	a1 84 50 80 00       	mov    0x805084,%eax
  801b2a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  return 0;
  801b30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b35:	83 c4 14             	add    $0x14,%esp
  801b38:	5b                   	pop    %ebx
  801b39:	5d                   	pop    %ebp
  801b3a:	c3                   	ret    

00801b3b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b3b:	55                   	push   %ebp
  801b3c:	89 e5                	mov    %esp,%ebp
  801b3e:	83 ec 18             	sub    $0x18,%esp
  801b41:	8b 45 10             	mov    0x10(%ebp),%eax
  // remember that write is always allowed to write *fewer*
  // bytes than requested.
  // LAB 5: Your code here
    int r;

    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b44:	8b 55 08             	mov    0x8(%ebp),%edx
  801b47:	8b 52 0c             	mov    0xc(%edx),%edx
  801b4a:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  801b50:	a3 04 50 80 00       	mov    %eax,0x805004

    size_t max_written = sizeof(fsipcbuf.write.req_buf);
    memmove(fsipcbuf.write.req_buf, buf, MIN(max_written, n));
  801b55:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b5a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b5f:	0f 47 c2             	cmova  %edx,%eax
  801b62:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b66:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b69:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b6d:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801b74:	e8 3b f3 ff ff       	call   800eb4 <memmove>

    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801b79:	ba 00 00 00 00       	mov    $0x0,%edx
  801b7e:	b8 04 00 00 00       	mov    $0x4,%eax
  801b83:	e8 a6 fe ff ff       	call   801a2e <fsipc>
        return r;

    return r;
}
  801b88:	c9                   	leave  
  801b89:	c3                   	ret    

00801b8a <devfile_read>:
// Returns:
//  The number of bytes successfully read.
//  < 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b8a:	55                   	push   %ebp
  801b8b:	89 e5                	mov    %esp,%ebp
  801b8d:	53                   	push   %ebx
  801b8e:	83 ec 14             	sub    $0x14,%esp
  // filling fsipcbuf.read with the request arguments.  The
  // bytes read will be written back to fsipcbuf by the file
  // system server.
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b91:	8b 45 08             	mov    0x8(%ebp),%eax
  801b94:	8b 40 0c             	mov    0xc(%eax),%eax
  801b97:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  801b9c:	8b 45 10             	mov    0x10(%ebp),%eax
  801b9f:	a3 04 50 80 00       	mov    %eax,0x805004
  if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ba4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba9:	b8 03 00 00 00       	mov    $0x3,%eax
  801bae:	e8 7b fe ff ff       	call   801a2e <fsipc>
  801bb3:	89 c3                	mov    %eax,%ebx
  801bb5:	85 c0                	test   %eax,%eax
  801bb7:	78 17                	js     801bd0 <devfile_read+0x46>
    return r;

  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bb9:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bbd:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801bc4:	00 
  801bc5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bc8:	89 04 24             	mov    %eax,(%esp)
  801bcb:	e8 e4 f2 ff ff       	call   800eb4 <memmove>
  return r;
}
  801bd0:	89 d8                	mov    %ebx,%eax
  801bd2:	83 c4 14             	add    $0x14,%esp
  801bd5:	5b                   	pop    %ebx
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    

00801bd8 <open>:
//  The file descriptor index on success
//  -E_BAD_PATH if the path is too long (>= MAXPATHLEN)
//  < 0 for other errors.
int
open(const char *path, int mode)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
  801bdb:	53                   	push   %ebx
  801bdc:	83 ec 24             	sub    $0x24,%esp
  801bdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  // file descriptor.

  int r;
  struct Fd *fd;

  if (strlen(path) >= MAXPATHLEN)
  801be2:	89 1c 24             	mov    %ebx,(%esp)
  801be5:	e8 f6 f0 ff ff       	call   800ce0 <strlen>
  801bea:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bef:	7f 60                	jg     801c51 <open+0x79>
    return -E_BAD_PATH;

  if ((r = fd_alloc(&fd)) < 0)
  801bf1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf4:	89 04 24             	mov    %eax,(%esp)
  801bf7:	e8 7b f8 ff ff       	call   801477 <fd_alloc>
  801bfc:	89 c2                	mov    %eax,%edx
  801bfe:	85 d2                	test   %edx,%edx
  801c00:	78 54                	js     801c56 <open+0x7e>
    return r;

  strcpy(fsipcbuf.open.req_path, path);
  801c02:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c06:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801c0d:	e8 05 f1 ff ff       	call   800d17 <strcpy>
  fsipcbuf.open.req_omode = mode;
  801c12:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c15:	a3 00 54 80 00       	mov    %eax,0x805400

  if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c1d:	b8 01 00 00 00       	mov    $0x1,%eax
  801c22:	e8 07 fe ff ff       	call   801a2e <fsipc>
  801c27:	89 c3                	mov    %eax,%ebx
  801c29:	85 c0                	test   %eax,%eax
  801c2b:	79 17                	jns    801c44 <open+0x6c>
    fd_close(fd, 0);
  801c2d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c34:	00 
  801c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c38:	89 04 24             	mov    %eax,(%esp)
  801c3b:	e8 31 f9 ff ff       	call   801571 <fd_close>
    return r;
  801c40:	89 d8                	mov    %ebx,%eax
  801c42:	eb 12                	jmp    801c56 <open+0x7e>
  }

  return fd2num(fd);
  801c44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c47:	89 04 24             	mov    %eax,(%esp)
  801c4a:	e8 01 f8 ff ff       	call   801450 <fd2num>
  801c4f:	eb 05                	jmp    801c56 <open+0x7e>

  int r;
  struct Fd *fd;

  if (strlen(path) >= MAXPATHLEN)
    return -E_BAD_PATH;
  801c51:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
    fd_close(fd, 0);
    return r;
  }

  return fd2num(fd);
}
  801c56:	83 c4 24             	add    $0x24,%esp
  801c59:	5b                   	pop    %ebx
  801c5a:	5d                   	pop    %ebp
  801c5b:	c3                   	ret    

00801c5c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	83 ec 08             	sub    $0x8,%esp
  // Ask the file server to update the disk
  // by writing any dirty blocks in the buffer cache.

  return fsipc(FSREQ_SYNC, NULL);
  801c62:	ba 00 00 00 00       	mov    $0x0,%edx
  801c67:	b8 08 00 00 00       	mov    $0x8,%eax
  801c6c:	e8 bd fd ff ff       	call   801a2e <fsipc>
}
  801c71:	c9                   	leave  
  801c72:	c3                   	ret    

00801c73 <devpipe_stat>:
  return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c73:	55                   	push   %ebp
  801c74:	89 e5                	mov    %esp,%ebp
  801c76:	56                   	push   %esi
  801c77:	53                   	push   %ebx
  801c78:	83 ec 10             	sub    $0x10,%esp
  801c7b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct Pipe *p = (struct Pipe*)fd2data(fd);
  801c7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c81:	89 04 24             	mov    %eax,(%esp)
  801c84:	e8 d7 f7 ff ff       	call   801460 <fd2data>
  801c89:	89 c6                	mov    %eax,%esi

  strcpy(stat->st_name, "<pipe>");
  801c8b:	c7 44 24 04 14 2b 80 	movl   $0x802b14,0x4(%esp)
  801c92:	00 
  801c93:	89 1c 24             	mov    %ebx,(%esp)
  801c96:	e8 7c f0 ff ff       	call   800d17 <strcpy>
  stat->st_size = p->p_wpos - p->p_rpos;
  801c9b:	8b 46 04             	mov    0x4(%esi),%eax
  801c9e:	2b 06                	sub    (%esi),%eax
  801ca0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  stat->st_isdir = 0;
  801ca6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cad:	00 00 00 
  stat->st_dev = &devpipe;
  801cb0:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801cb7:	30 80 00 
  return 0;
}
  801cba:	b8 00 00 00 00       	mov    $0x0,%eax
  801cbf:	83 c4 10             	add    $0x10,%esp
  801cc2:	5b                   	pop    %ebx
  801cc3:	5e                   	pop    %esi
  801cc4:	5d                   	pop    %ebp
  801cc5:	c3                   	ret    

00801cc6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cc6:	55                   	push   %ebp
  801cc7:	89 e5                	mov    %esp,%ebp
  801cc9:	53                   	push   %ebx
  801cca:	83 ec 14             	sub    $0x14,%esp
  801ccd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  (void)sys_page_unmap(0, fd);
  801cd0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cd4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cdb:	e8 fa f4 ff ff       	call   8011da <sys_page_unmap>
  return sys_page_unmap(0, fd2data(fd));
  801ce0:	89 1c 24             	mov    %ebx,(%esp)
  801ce3:	e8 78 f7 ff ff       	call   801460 <fd2data>
  801ce8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cf3:	e8 e2 f4 ff ff       	call   8011da <sys_page_unmap>
}
  801cf8:	83 c4 14             	add    $0x14,%esp
  801cfb:	5b                   	pop    %ebx
  801cfc:	5d                   	pop    %ebp
  801cfd:	c3                   	ret    

00801cfe <_pipeisclosed>:
  return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cfe:	55                   	push   %ebp
  801cff:	89 e5                	mov    %esp,%ebp
  801d01:	57                   	push   %edi
  801d02:	56                   	push   %esi
  801d03:	53                   	push   %ebx
  801d04:	83 ec 2c             	sub    $0x2c,%esp
  801d07:	89 c6                	mov    %eax,%esi
  801d09:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  int n, nn, ret;

  while (1) {
    n = thisenv->env_runs;
  801d0c:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801d11:	8b 58 58             	mov    0x58(%eax),%ebx
    ret = pageref(fd) == pageref(p);
  801d14:	89 34 24             	mov    %esi,(%esp)
  801d17:	e8 b3 05 00 00       	call   8022cf <pageref>
  801d1c:	89 c7                	mov    %eax,%edi
  801d1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d21:	89 04 24             	mov    %eax,(%esp)
  801d24:	e8 a6 05 00 00       	call   8022cf <pageref>
  801d29:	39 c7                	cmp    %eax,%edi
  801d2b:	0f 94 c2             	sete   %dl
  801d2e:	0f b6 c2             	movzbl %dl,%eax
    nn = thisenv->env_runs;
  801d31:	8b 0d b0 40 80 00    	mov    0x8040b0,%ecx
  801d37:	8b 79 58             	mov    0x58(%ecx),%edi
    if (n == nn)
  801d3a:	39 fb                	cmp    %edi,%ebx
  801d3c:	74 21                	je     801d5f <_pipeisclosed+0x61>
      return ret;
    if (n != nn && ret == 1)
  801d3e:	84 d2                	test   %dl,%dl
  801d40:	74 ca                	je     801d0c <_pipeisclosed+0xe>
      cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d42:	8b 51 58             	mov    0x58(%ecx),%edx
  801d45:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d49:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d4d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d51:	c7 04 24 1b 2b 80 00 	movl   $0x802b1b,(%esp)
  801d58:	e8 92 e9 ff ff       	call   8006ef <cprintf>
  801d5d:	eb ad                	jmp    801d0c <_pipeisclosed+0xe>
  }
}
  801d5f:	83 c4 2c             	add    $0x2c,%esp
  801d62:	5b                   	pop    %ebx
  801d63:	5e                   	pop    %esi
  801d64:	5f                   	pop    %edi
  801d65:	5d                   	pop    %ebp
  801d66:	c3                   	ret    

00801d67 <devpipe_write>:
  return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d67:	55                   	push   %ebp
  801d68:	89 e5                	mov    %esp,%ebp
  801d6a:	57                   	push   %edi
  801d6b:	56                   	push   %esi
  801d6c:	53                   	push   %ebx
  801d6d:	83 ec 1c             	sub    $0x1c,%esp
  801d70:	8b 75 08             	mov    0x8(%ebp),%esi
  const uint8_t *buf;
  size_t i;
  struct Pipe *p;

  p = (struct Pipe*)fd2data(fd);
  801d73:	89 34 24             	mov    %esi,(%esp)
  801d76:	e8 e5 f6 ff ff       	call   801460 <fd2data>
  801d7b:	89 c3                	mov    %eax,%ebx
  if (debug)
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  801d7d:	bf 00 00 00 00       	mov    $0x0,%edi
  801d82:	eb 45                	jmp    801dc9 <devpipe_write+0x62>
    while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
      // pipe is full
      // if all the readers are gone
      // (it's only writers like us now),
      // note eof
      if (_pipeisclosed(fd, p))
  801d84:	89 da                	mov    %ebx,%edx
  801d86:	89 f0                	mov    %esi,%eax
  801d88:	e8 71 ff ff ff       	call   801cfe <_pipeisclosed>
  801d8d:	85 c0                	test   %eax,%eax
  801d8f:	75 41                	jne    801dd2 <devpipe_write+0x6b>
        return 0;
      // yield and see what happens
      if (debug)
        cprintf("devpipe_write yield\n");
      sys_yield();
  801d91:	e8 7e f3 ff ff       	call   801114 <sys_yield>
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
    while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d96:	8b 43 04             	mov    0x4(%ebx),%eax
  801d99:	8b 0b                	mov    (%ebx),%ecx
  801d9b:	8d 51 20             	lea    0x20(%ecx),%edx
  801d9e:	39 d0                	cmp    %edx,%eax
  801da0:	73 e2                	jae    801d84 <devpipe_write+0x1d>
        cprintf("devpipe_write yield\n");
      sys_yield();
    }
    // there's room for a byte.  store it.
    // wait to increment wpos until the byte is stored!
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801da2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801da5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801da9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801dac:	99                   	cltd   
  801dad:	c1 ea 1b             	shr    $0x1b,%edx
  801db0:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801db3:	83 e1 1f             	and    $0x1f,%ecx
  801db6:	29 d1                	sub    %edx,%ecx
  801db8:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801dbc:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
    p->p_wpos++;
  801dc0:	83 c0 01             	add    $0x1,%eax
  801dc3:	89 43 04             	mov    %eax,0x4(%ebx)
  if (debug)
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  801dc6:	83 c7 01             	add    $0x1,%edi
  801dc9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801dcc:	75 c8                	jne    801d96 <devpipe_write+0x2f>
    // wait to increment wpos until the byte is stored!
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
    p->p_wpos++;
  }

  return i;
  801dce:	89 f8                	mov    %edi,%eax
  801dd0:	eb 05                	jmp    801dd7 <devpipe_write+0x70>
      // pipe is full
      // if all the readers are gone
      // (it's only writers like us now),
      // note eof
      if (_pipeisclosed(fd, p))
        return 0;
  801dd2:	b8 00 00 00 00       	mov    $0x0,%eax
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
    p->p_wpos++;
  }

  return i;
}
  801dd7:	83 c4 1c             	add    $0x1c,%esp
  801dda:	5b                   	pop    %ebx
  801ddb:	5e                   	pop    %esi
  801ddc:	5f                   	pop    %edi
  801ddd:	5d                   	pop    %ebp
  801dde:	c3                   	ret    

00801ddf <devpipe_read>:
  return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ddf:	55                   	push   %ebp
  801de0:	89 e5                	mov    %esp,%ebp
  801de2:	57                   	push   %edi
  801de3:	56                   	push   %esi
  801de4:	53                   	push   %ebx
  801de5:	83 ec 1c             	sub    $0x1c,%esp
  801de8:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint8_t *buf;
  size_t i;
  struct Pipe *p;

  p = (struct Pipe*)fd2data(fd);
  801deb:	89 3c 24             	mov    %edi,(%esp)
  801dee:	e8 6d f6 ff ff       	call   801460 <fd2data>
  801df3:	89 c3                	mov    %eax,%ebx
  if (debug)
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  801df5:	be 00 00 00 00       	mov    $0x0,%esi
  801dfa:	eb 3d                	jmp    801e39 <devpipe_read+0x5a>
    while (p->p_rpos == p->p_wpos) {
      // pipe is empty
      // if we got any data, return it
      if (i > 0)
  801dfc:	85 f6                	test   %esi,%esi
  801dfe:	74 04                	je     801e04 <devpipe_read+0x25>
        return i;
  801e00:	89 f0                	mov    %esi,%eax
  801e02:	eb 43                	jmp    801e47 <devpipe_read+0x68>
      // if all the writers are gone, note eof
      if (_pipeisclosed(fd, p))
  801e04:	89 da                	mov    %ebx,%edx
  801e06:	89 f8                	mov    %edi,%eax
  801e08:	e8 f1 fe ff ff       	call   801cfe <_pipeisclosed>
  801e0d:	85 c0                	test   %eax,%eax
  801e0f:	75 31                	jne    801e42 <devpipe_read+0x63>
        return 0;
      // yield and see what happens
      if (debug)
        cprintf("devpipe_read yield\n");
      sys_yield();
  801e11:	e8 fe f2 ff ff       	call   801114 <sys_yield>
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
    while (p->p_rpos == p->p_wpos) {
  801e16:	8b 03                	mov    (%ebx),%eax
  801e18:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e1b:	74 df                	je     801dfc <devpipe_read+0x1d>
        cprintf("devpipe_read yield\n");
      sys_yield();
    }
    // there's a byte.  take it.
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e1d:	99                   	cltd   
  801e1e:	c1 ea 1b             	shr    $0x1b,%edx
  801e21:	01 d0                	add    %edx,%eax
  801e23:	83 e0 1f             	and    $0x1f,%eax
  801e26:	29 d0                	sub    %edx,%eax
  801e28:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801e2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e30:	88 04 31             	mov    %al,(%ecx,%esi,1)
    p->p_rpos++;
  801e33:	83 03 01             	addl   $0x1,(%ebx)
  if (debug)
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  801e36:	83 c6 01             	add    $0x1,%esi
  801e39:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e3c:	75 d8                	jne    801e16 <devpipe_read+0x37>
    // there's a byte.  take it.
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
    p->p_rpos++;
  }
  return i;
  801e3e:	89 f0                	mov    %esi,%eax
  801e40:	eb 05                	jmp    801e47 <devpipe_read+0x68>
      // if we got any data, return it
      if (i > 0)
        return i;
      // if all the writers are gone, note eof
      if (_pipeisclosed(fd, p))
        return 0;
  801e42:	b8 00 00 00 00       	mov    $0x0,%eax
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
    p->p_rpos++;
  }
  return i;
}
  801e47:	83 c4 1c             	add    $0x1c,%esp
  801e4a:	5b                   	pop    %ebx
  801e4b:	5e                   	pop    %esi
  801e4c:	5f                   	pop    %edi
  801e4d:	5d                   	pop    %ebp
  801e4e:	c3                   	ret    

00801e4f <pipe>:
  uint8_t p_buf[PIPEBUFSIZ];    // data buffer
};

int
pipe(int pfd[2])
{
  801e4f:	55                   	push   %ebp
  801e50:	89 e5                	mov    %esp,%ebp
  801e52:	56                   	push   %esi
  801e53:	53                   	push   %ebx
  801e54:	83 ec 30             	sub    $0x30,%esp
  int r;
  struct Fd *fd0, *fd1;
  void *va;

  // allocate the file descriptor table entries
  if ((r = fd_alloc(&fd0)) < 0
  801e57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e5a:	89 04 24             	mov    %eax,(%esp)
  801e5d:	e8 15 f6 ff ff       	call   801477 <fd_alloc>
  801e62:	89 c2                	mov    %eax,%edx
  801e64:	85 d2                	test   %edx,%edx
  801e66:	0f 88 4d 01 00 00    	js     801fb9 <pipe+0x16a>
      || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e6c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e73:	00 
  801e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e77:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e7b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e82:	e8 ac f2 ff ff       	call   801133 <sys_page_alloc>
  801e87:	89 c2                	mov    %eax,%edx
  801e89:	85 d2                	test   %edx,%edx
  801e8b:	0f 88 28 01 00 00    	js     801fb9 <pipe+0x16a>
    goto err;

  if ((r = fd_alloc(&fd1)) < 0
  801e91:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e94:	89 04 24             	mov    %eax,(%esp)
  801e97:	e8 db f5 ff ff       	call   801477 <fd_alloc>
  801e9c:	89 c3                	mov    %eax,%ebx
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	0f 88 fe 00 00 00    	js     801fa4 <pipe+0x155>
      || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ea6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ead:	00 
  801eae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801eb1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eb5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ebc:	e8 72 f2 ff ff       	call   801133 <sys_page_alloc>
  801ec1:	89 c3                	mov    %eax,%ebx
  801ec3:	85 c0                	test   %eax,%eax
  801ec5:	0f 88 d9 00 00 00    	js     801fa4 <pipe+0x155>
    goto err1;

  // allocate the pipe structure as first data page in both
  va = fd2data(fd0);
  801ecb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ece:	89 04 24             	mov    %eax,(%esp)
  801ed1:	e8 8a f5 ff ff       	call   801460 <fd2data>
  801ed6:	89 c6                	mov    %eax,%esi
  if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ed8:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801edf:	00 
  801ee0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ee4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eeb:	e8 43 f2 ff ff       	call   801133 <sys_page_alloc>
  801ef0:	89 c3                	mov    %eax,%ebx
  801ef2:	85 c0                	test   %eax,%eax
  801ef4:	0f 88 97 00 00 00    	js     801f91 <pipe+0x142>
    goto err2;
  if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801efa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801efd:	89 04 24             	mov    %eax,(%esp)
  801f00:	e8 5b f5 ff ff       	call   801460 <fd2data>
  801f05:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801f0c:	00 
  801f0d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f11:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f18:	00 
  801f19:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f24:	e8 5e f2 ff ff       	call   801187 <sys_page_map>
  801f29:	89 c3                	mov    %eax,%ebx
  801f2b:	85 c0                	test   %eax,%eax
  801f2d:	78 52                	js     801f81 <pipe+0x132>
    goto err3;

  // set up fd structures
  fd0->fd_dev_id = devpipe.dev_id;
  801f2f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f38:	89 10                	mov    %edx,(%eax)
  fd0->fd_omode = O_RDONLY;
  801f3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

  fd1->fd_dev_id = devpipe.dev_id;
  801f44:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f4d:	89 10                	mov    %edx,(%eax)
  fd1->fd_omode = O_WRONLY;
  801f4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f52:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

  if (debug)
    cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

  pfd[0] = fd2num(fd0);
  801f59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f5c:	89 04 24             	mov    %eax,(%esp)
  801f5f:	e8 ec f4 ff ff       	call   801450 <fd2num>
  801f64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f67:	89 01                	mov    %eax,(%ecx)
  pfd[1] = fd2num(fd1);
  801f69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f6c:	89 04 24             	mov    %eax,(%esp)
  801f6f:	e8 dc f4 ff ff       	call   801450 <fd2num>
  801f74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f77:	89 41 04             	mov    %eax,0x4(%ecx)
  return 0;
  801f7a:	b8 00 00 00 00       	mov    $0x0,%eax
  801f7f:	eb 38                	jmp    801fb9 <pipe+0x16a>

err3:
  sys_page_unmap(0, va);
  801f81:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f8c:	e8 49 f2 ff ff       	call   8011da <sys_page_unmap>
err2:
  sys_page_unmap(0, fd1);
  801f91:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f94:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f98:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f9f:	e8 36 f2 ff ff       	call   8011da <sys_page_unmap>
err1:
  sys_page_unmap(0, fd0);
  801fa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fb2:	e8 23 f2 ff ff       	call   8011da <sys_page_unmap>
  801fb7:	89 d8                	mov    %ebx,%eax
err:
  return r;
}
  801fb9:	83 c4 30             	add    $0x30,%esp
  801fbc:	5b                   	pop    %ebx
  801fbd:	5e                   	pop    %esi
  801fbe:	5d                   	pop    %ebp
  801fbf:	c3                   	ret    

00801fc0 <pipeisclosed>:
  }
}

int
pipeisclosed(int fdnum)
{
  801fc0:	55                   	push   %ebp
  801fc1:	89 e5                	mov    %esp,%ebp
  801fc3:	83 ec 28             	sub    $0x28,%esp
  struct Fd *fd;
  struct Pipe *p;
  int r;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fc6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fc9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fcd:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd0:	89 04 24             	mov    %eax,(%esp)
  801fd3:	e8 ee f4 ff ff       	call   8014c6 <fd_lookup>
  801fd8:	89 c2                	mov    %eax,%edx
  801fda:	85 d2                	test   %edx,%edx
  801fdc:	78 15                	js     801ff3 <pipeisclosed+0x33>
    return r;
  p = (struct Pipe*)fd2data(fd);
  801fde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe1:	89 04 24             	mov    %eax,(%esp)
  801fe4:	e8 77 f4 ff ff       	call   801460 <fd2data>
  return _pipeisclosed(fd, p);
  801fe9:	89 c2                	mov    %eax,%edx
  801feb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fee:	e8 0b fd ff ff       	call   801cfe <_pipeisclosed>
}
  801ff3:	c9                   	leave  
  801ff4:	c3                   	ret    
  801ff5:	66 90                	xchg   %ax,%ax
  801ff7:	66 90                	xchg   %ax,%ax
  801ff9:	66 90                	xchg   %ax,%ax
  801ffb:	66 90                	xchg   %ax,%ax
  801ffd:	66 90                	xchg   %ax,%ax
  801fff:	90                   	nop

00802000 <devcons_close>:
  return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802000:	55                   	push   %ebp
  802001:	89 e5                	mov    %esp,%ebp
  USED(fd);

  return 0;
}
  802003:	b8 00 00 00 00       	mov    $0x0,%eax
  802008:	5d                   	pop    %ebp
  802009:	c3                   	ret    

0080200a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80200a:	55                   	push   %ebp
  80200b:	89 e5                	mov    %esp,%ebp
  80200d:	83 ec 18             	sub    $0x18,%esp
  strcpy(stat->st_name, "<cons>");
  802010:	c7 44 24 04 33 2b 80 	movl   $0x802b33,0x4(%esp)
  802017:	00 
  802018:	8b 45 0c             	mov    0xc(%ebp),%eax
  80201b:	89 04 24             	mov    %eax,(%esp)
  80201e:	e8 f4 ec ff ff       	call   800d17 <strcpy>
  return 0;
}
  802023:	b8 00 00 00 00       	mov    $0x0,%eax
  802028:	c9                   	leave  
  802029:	c3                   	ret    

0080202a <devcons_write>:
  return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80202a:	55                   	push   %ebp
  80202b:	89 e5                	mov    %esp,%ebp
  80202d:	57                   	push   %edi
  80202e:	56                   	push   %esi
  80202f:	53                   	push   %ebx
  802030:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  802036:	bb 00 00 00 00       	mov    $0x0,%ebx
    m = n - tot;
    if (m > sizeof(buf) - 1)
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
  80203b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  802041:	eb 31                	jmp    802074 <devcons_write+0x4a>
    m = n - tot;
  802043:	8b 75 10             	mov    0x10(%ebp),%esi
  802046:	29 de                	sub    %ebx,%esi
    if (m > sizeof(buf) - 1)
  802048:	83 fe 7f             	cmp    $0x7f,%esi
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
    m = n - tot;
  80204b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802050:	0f 47 f2             	cmova  %edx,%esi
    if (m > sizeof(buf) - 1)
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
  802053:	89 74 24 08          	mov    %esi,0x8(%esp)
  802057:	03 45 0c             	add    0xc(%ebp),%eax
  80205a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80205e:	89 3c 24             	mov    %edi,(%esp)
  802061:	e8 4e ee ff ff       	call   800eb4 <memmove>
    sys_cputs(buf, m);
  802066:	89 74 24 04          	mov    %esi,0x4(%esp)
  80206a:	89 3c 24             	mov    %edi,(%esp)
  80206d:	e8 f4 ef ff ff       	call   801066 <sys_cputs>
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  802072:	01 f3                	add    %esi,%ebx
  802074:	89 d8                	mov    %ebx,%eax
  802076:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802079:	72 c8                	jb     802043 <devcons_write+0x19>
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
    sys_cputs(buf, m);
  }
  return tot;
}
  80207b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802081:	5b                   	pop    %ebx
  802082:	5e                   	pop    %esi
  802083:	5f                   	pop    %edi
  802084:	5d                   	pop    %ebp
  802085:	c3                   	ret    

00802086 <devcons_read>:
  return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802086:	55                   	push   %ebp
  802087:	89 e5                	mov    %esp,%ebp
  802089:	83 ec 08             	sub    $0x8,%esp
  int c;

  if (n == 0)
    return 0;
  80208c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  int c;

  if (n == 0)
  802091:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802095:	75 07                	jne    80209e <devcons_read+0x18>
  802097:	eb 2a                	jmp    8020c3 <devcons_read+0x3d>
    return 0;

  while ((c = sys_cgetc()) == 0)
    sys_yield();
  802099:	e8 76 f0 ff ff       	call   801114 <sys_yield>
  int c;

  if (n == 0)
    return 0;

  while ((c = sys_cgetc()) == 0)
  80209e:	66 90                	xchg   %ax,%ax
  8020a0:	e8 df ef ff ff       	call   801084 <sys_cgetc>
  8020a5:	85 c0                	test   %eax,%eax
  8020a7:	74 f0                	je     802099 <devcons_read+0x13>
    sys_yield();
  if (c < 0)
  8020a9:	85 c0                	test   %eax,%eax
  8020ab:	78 16                	js     8020c3 <devcons_read+0x3d>
    return c;
  if (c == 0x04)        // ctl-d is eof
  8020ad:	83 f8 04             	cmp    $0x4,%eax
  8020b0:	74 0c                	je     8020be <devcons_read+0x38>
    return 0;
  *(char*)vbuf = c;
  8020b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020b5:	88 02                	mov    %al,(%edx)
  return 1;
  8020b7:	b8 01 00 00 00       	mov    $0x1,%eax
  8020bc:	eb 05                	jmp    8020c3 <devcons_read+0x3d>
  while ((c = sys_cgetc()) == 0)
    sys_yield();
  if (c < 0)
    return c;
  if (c == 0x04)        // ctl-d is eof
    return 0;
  8020be:	b8 00 00 00 00       	mov    $0x0,%eax
  *(char*)vbuf = c;
  return 1;
}
  8020c3:	c9                   	leave  
  8020c4:	c3                   	ret    

008020c5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020c5:	55                   	push   %ebp
  8020c6:	89 e5                	mov    %esp,%ebp
  8020c8:	83 ec 28             	sub    $0x28,%esp
  char c = ch;
  8020cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ce:	88 45 f7             	mov    %al,-0x9(%ebp)

  // Unlike standard Unix's putchar,
  // the cputchar function _always_ outputs to the system console.
  sys_cputs(&c, 1);
  8020d1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8020d8:	00 
  8020d9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020dc:	89 04 24             	mov    %eax,(%esp)
  8020df:	e8 82 ef ff ff       	call   801066 <sys_cputs>
}
  8020e4:	c9                   	leave  
  8020e5:	c3                   	ret    

008020e6 <getchar>:

int
getchar(void)
{
  8020e6:	55                   	push   %ebp
  8020e7:	89 e5                	mov    %esp,%ebp
  8020e9:	83 ec 28             	sub    $0x28,%esp
  int r;

  // JOS does, however, support standard _input_ redirection,
  // allowing the user to redirect script files to the shell and such.
  // getchar() reads a character from file descriptor 0.
  r = read(0, &c, 1);
  8020ec:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8020f3:	00 
  8020f4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802102:	e8 4e f6 ff ff       	call   801755 <read>
  if (r < 0)
  802107:	85 c0                	test   %eax,%eax
  802109:	78 0f                	js     80211a <getchar+0x34>
    return r;
  if (r < 1)
  80210b:	85 c0                	test   %eax,%eax
  80210d:	7e 06                	jle    802115 <getchar+0x2f>
    return -E_EOF;
  return c;
  80210f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802113:	eb 05                	jmp    80211a <getchar+0x34>
  // getchar() reads a character from file descriptor 0.
  r = read(0, &c, 1);
  if (r < 0)
    return r;
  if (r < 1)
    return -E_EOF;
  802115:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  /* int r;
  // sys_cgetc does not block, but getchar should.
  while ((r = sys_cgetc()) == 0)
    sys_yield();
  return r; */
}
  80211a:	c9                   	leave  
  80211b:	c3                   	ret    

0080211c <iscons>:
  .dev_stat   =     devcons_stat
};

int
iscons(int fdnum)
{
  80211c:	55                   	push   %ebp
  80211d:	89 e5                	mov    %esp,%ebp
  80211f:	83 ec 28             	sub    $0x28,%esp
  int r;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  802122:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802125:	89 44 24 04          	mov    %eax,0x4(%esp)
  802129:	8b 45 08             	mov    0x8(%ebp),%eax
  80212c:	89 04 24             	mov    %eax,(%esp)
  80212f:	e8 92 f3 ff ff       	call   8014c6 <fd_lookup>
  802134:	85 c0                	test   %eax,%eax
  802136:	78 11                	js     802149 <iscons+0x2d>
    return r;
  return fd->fd_dev_id == devcons.dev_id;
  802138:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802141:	39 10                	cmp    %edx,(%eax)
  802143:	0f 94 c0             	sete   %al
  802146:	0f b6 c0             	movzbl %al,%eax
}
  802149:	c9                   	leave  
  80214a:	c3                   	ret    

0080214b <opencons>:

int
opencons(void)
{
  80214b:	55                   	push   %ebp
  80214c:	89 e5                	mov    %esp,%ebp
  80214e:	83 ec 28             	sub    $0x28,%esp
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
  802151:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802154:	89 04 24             	mov    %eax,(%esp)
  802157:	e8 1b f3 ff ff       	call   801477 <fd_alloc>
    return r;
  80215c:	89 c2                	mov    %eax,%edx
opencons(void)
{
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
  80215e:	85 c0                	test   %eax,%eax
  802160:	78 40                	js     8021a2 <opencons+0x57>
    return r;
  if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802162:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802169:	00 
  80216a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80216d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802171:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802178:	e8 b6 ef ff ff       	call   801133 <sys_page_alloc>
    return r;
  80217d:	89 c2                	mov    %eax,%edx
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
    return r;
  if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80217f:	85 c0                	test   %eax,%eax
  802181:	78 1f                	js     8021a2 <opencons+0x57>
    return r;
  fd->fd_dev_id = devcons.dev_id;
  802183:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802189:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80218c:	89 10                	mov    %edx,(%eax)
  fd->fd_omode = O_RDWR;
  80218e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802191:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
  return fd2num(fd);
  802198:	89 04 24             	mov    %eax,(%esp)
  80219b:	e8 b0 f2 ff ff       	call   801450 <fd2num>
  8021a0:	89 c2                	mov    %eax,%edx
}
  8021a2:	89 d0                	mov    %edx,%eax
  8021a4:	c9                   	leave  
  8021a5:	c3                   	ret    

008021a6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021a6:	55                   	push   %ebp
  8021a7:	89 e5                	mov    %esp,%ebp
  8021a9:	56                   	push   %esi
  8021aa:	53                   	push   %ebx
  8021ab:	83 ec 10             	sub    $0x10,%esp
  8021ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8021b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;
  8021b7:	85 c0                	test   %eax,%eax
  8021b9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8021be:	0f 44 c2             	cmove  %edx,%eax
  if ((r = sys_ipc_recv(pg)) < 0) {
  8021c1:	89 04 24             	mov    %eax,(%esp)
  8021c4:	e8 80 f1 ff ff       	call   801349 <sys_ipc_recv>
  8021c9:	85 c0                	test   %eax,%eax
  8021cb:	79 34                	jns    802201 <ipc_recv+0x5b>
    if (from_env_store)
  8021cd:	85 f6                	test   %esi,%esi
  8021cf:	74 06                	je     8021d7 <ipc_recv+0x31>
      *from_env_store = 0;
  8021d1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (perm_store)
  8021d7:	85 db                	test   %ebx,%ebx
  8021d9:	74 06                	je     8021e1 <ipc_recv+0x3b>
      *perm_store = 0;
  8021db:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    panic("sys_ipc_recv: %e", r);
  8021e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021e5:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  8021ec:	00 
  8021ed:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8021f4:	00 
  8021f5:	c7 04 24 50 2b 80 00 	movl   $0x802b50,(%esp)
  8021fc:	e8 f5 e3 ff ff       	call   8005f6 <_panic>
  }

  if (from_env_store)
  802201:	85 f6                	test   %esi,%esi
  802203:	74 0a                	je     80220f <ipc_recv+0x69>
    *from_env_store = thisenv->env_ipc_from;
  802205:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80220a:	8b 40 74             	mov    0x74(%eax),%eax
  80220d:	89 06                	mov    %eax,(%esi)
  if (perm_store)
  80220f:	85 db                	test   %ebx,%ebx
  802211:	74 0a                	je     80221d <ipc_recv+0x77>
    *perm_store |= thisenv->env_ipc_perm;
  802213:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802218:	8b 40 78             	mov    0x78(%eax),%eax
  80221b:	09 03                	or     %eax,(%ebx)

  return thisenv->env_ipc_value;
  80221d:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802222:	8b 40 70             	mov    0x70(%eax),%eax

}
  802225:	83 c4 10             	add    $0x10,%esp
  802228:	5b                   	pop    %ebx
  802229:	5e                   	pop    %esi
  80222a:	5d                   	pop    %ebp
  80222b:	c3                   	ret    

0080222c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80222c:	55                   	push   %ebp
  80222d:	89 e5                	mov    %esp,%ebp
  80222f:	57                   	push   %edi
  802230:	56                   	push   %esi
  802231:	53                   	push   %ebx
  802232:	83 ec 1c             	sub    $0x1c,%esp
  802235:	8b 7d 08             	mov    0x8(%ebp),%edi
  802238:	8b 75 0c             	mov    0xc(%ebp),%esi
  80223b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;
  80223e:	85 db                	test   %ebx,%ebx
  802240:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802245:	0f 44 d8             	cmove  %eax,%ebx

  while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802248:	eb 2a                	jmp    802274 <ipc_send+0x48>
    if (r != -E_IPC_NOT_RECV)
  80224a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80224d:	74 20                	je     80226f <ipc_send+0x43>
      panic("ipc_send: %e", r);
  80224f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802253:	c7 44 24 08 5a 2b 80 	movl   $0x802b5a,0x8(%esp)
  80225a:	00 
  80225b:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  802262:	00 
  802263:	c7 04 24 50 2b 80 00 	movl   $0x802b50,(%esp)
  80226a:	e8 87 e3 ff ff       	call   8005f6 <_panic>
    sys_yield();
  80226f:	e8 a0 ee ff ff       	call   801114 <sys_yield>
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;

  while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802274:	8b 45 14             	mov    0x14(%ebp),%eax
  802277:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80227b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80227f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802283:	89 3c 24             	mov    %edi,(%esp)
  802286:	e8 9b f0 ff ff       	call   801326 <sys_ipc_try_send>
  80228b:	85 c0                	test   %eax,%eax
  80228d:	78 bb                	js     80224a <ipc_send+0x1e>
    if (r != -E_IPC_NOT_RECV)
      panic("ipc_send: %e", r);
    sys_yield();
  }
}
  80228f:	83 c4 1c             	add    $0x1c,%esp
  802292:	5b                   	pop    %ebx
  802293:	5e                   	pop    %esi
  802294:	5f                   	pop    %edi
  802295:	5d                   	pop    %ebp
  802296:	c3                   	ret    

00802297 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802297:	55                   	push   %ebp
  802298:	89 e5                	mov    %esp,%ebp
  80229a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int i;

  for (i = 0; i < NENV; i++)
  80229d:	b8 00 00 00 00       	mov    $0x0,%eax
    if (envs[i].env_type == type)
  8022a2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8022a5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022ab:	8b 52 50             	mov    0x50(%edx),%edx
  8022ae:	39 ca                	cmp    %ecx,%edx
  8022b0:	75 0d                	jne    8022bf <ipc_find_env+0x28>
      return envs[i].env_id;
  8022b2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8022b5:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8022ba:	8b 40 40             	mov    0x40(%eax),%eax
  8022bd:	eb 0e                	jmp    8022cd <ipc_find_env+0x36>
envid_t
ipc_find_env(enum EnvType type)
{
  int i;

  for (i = 0; i < NENV; i++)
  8022bf:	83 c0 01             	add    $0x1,%eax
  8022c2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022c7:	75 d9                	jne    8022a2 <ipc_find_env+0xb>
    if (envs[i].env_type == type)
      return envs[i].env_id;
  return 0;
  8022c9:	66 b8 00 00          	mov    $0x0,%ax
}
  8022cd:	5d                   	pop    %ebp
  8022ce:	c3                   	ret    

008022cf <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022cf:	55                   	push   %ebp
  8022d0:	89 e5                	mov    %esp,%ebp
  8022d2:	8b 55 08             	mov    0x8(%ebp),%edx
  pte_t pte;

  if (!(uvpd[PDX(v)] & PTE_P))
  8022d5:	89 d0                	mov    %edx,%eax
  8022d7:	c1 e8 16             	shr    $0x16,%eax
  8022da:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
    return 0;
  8022e1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
  pte_t pte;

  if (!(uvpd[PDX(v)] & PTE_P))
  8022e6:	f6 c1 01             	test   $0x1,%cl
  8022e9:	74 1d                	je     802308 <pageref+0x39>
    return 0;
  pte = uvpt[PGNUM(v)];
  8022eb:	c1 ea 0c             	shr    $0xc,%edx
  8022ee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  if (!(pte & PTE_P))
  8022f5:	f6 c2 01             	test   $0x1,%dl
  8022f8:	74 0e                	je     802308 <pageref+0x39>
    return 0;
  return pages[PGNUM(pte)].pp_ref;
  8022fa:	c1 ea 0c             	shr    $0xc,%edx
  8022fd:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802304:	ef 
  802305:	0f b7 c0             	movzwl %ax,%eax
}
  802308:	5d                   	pop    %ebp
  802309:	c3                   	ret    
  80230a:	66 90                	xchg   %ax,%ax
  80230c:	66 90                	xchg   %ax,%ax
  80230e:	66 90                	xchg   %ax,%ax

00802310 <__udivdi3>:
  802310:	55                   	push   %ebp
  802311:	57                   	push   %edi
  802312:	56                   	push   %esi
  802313:	83 ec 0c             	sub    $0xc,%esp
  802316:	8b 44 24 28          	mov    0x28(%esp),%eax
  80231a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80231e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802322:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802326:	85 c0                	test   %eax,%eax
  802328:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80232c:	89 ea                	mov    %ebp,%edx
  80232e:	89 0c 24             	mov    %ecx,(%esp)
  802331:	75 2d                	jne    802360 <__udivdi3+0x50>
  802333:	39 e9                	cmp    %ebp,%ecx
  802335:	77 61                	ja     802398 <__udivdi3+0x88>
  802337:	85 c9                	test   %ecx,%ecx
  802339:	89 ce                	mov    %ecx,%esi
  80233b:	75 0b                	jne    802348 <__udivdi3+0x38>
  80233d:	b8 01 00 00 00       	mov    $0x1,%eax
  802342:	31 d2                	xor    %edx,%edx
  802344:	f7 f1                	div    %ecx
  802346:	89 c6                	mov    %eax,%esi
  802348:	31 d2                	xor    %edx,%edx
  80234a:	89 e8                	mov    %ebp,%eax
  80234c:	f7 f6                	div    %esi
  80234e:	89 c5                	mov    %eax,%ebp
  802350:	89 f8                	mov    %edi,%eax
  802352:	f7 f6                	div    %esi
  802354:	89 ea                	mov    %ebp,%edx
  802356:	83 c4 0c             	add    $0xc,%esp
  802359:	5e                   	pop    %esi
  80235a:	5f                   	pop    %edi
  80235b:	5d                   	pop    %ebp
  80235c:	c3                   	ret    
  80235d:	8d 76 00             	lea    0x0(%esi),%esi
  802360:	39 e8                	cmp    %ebp,%eax
  802362:	77 24                	ja     802388 <__udivdi3+0x78>
  802364:	0f bd e8             	bsr    %eax,%ebp
  802367:	83 f5 1f             	xor    $0x1f,%ebp
  80236a:	75 3c                	jne    8023a8 <__udivdi3+0x98>
  80236c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802370:	39 34 24             	cmp    %esi,(%esp)
  802373:	0f 86 9f 00 00 00    	jbe    802418 <__udivdi3+0x108>
  802379:	39 d0                	cmp    %edx,%eax
  80237b:	0f 82 97 00 00 00    	jb     802418 <__udivdi3+0x108>
  802381:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802388:	31 d2                	xor    %edx,%edx
  80238a:	31 c0                	xor    %eax,%eax
  80238c:	83 c4 0c             	add    $0xc,%esp
  80238f:	5e                   	pop    %esi
  802390:	5f                   	pop    %edi
  802391:	5d                   	pop    %ebp
  802392:	c3                   	ret    
  802393:	90                   	nop
  802394:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802398:	89 f8                	mov    %edi,%eax
  80239a:	f7 f1                	div    %ecx
  80239c:	31 d2                	xor    %edx,%edx
  80239e:	83 c4 0c             	add    $0xc,%esp
  8023a1:	5e                   	pop    %esi
  8023a2:	5f                   	pop    %edi
  8023a3:	5d                   	pop    %ebp
  8023a4:	c3                   	ret    
  8023a5:	8d 76 00             	lea    0x0(%esi),%esi
  8023a8:	89 e9                	mov    %ebp,%ecx
  8023aa:	8b 3c 24             	mov    (%esp),%edi
  8023ad:	d3 e0                	shl    %cl,%eax
  8023af:	89 c6                	mov    %eax,%esi
  8023b1:	b8 20 00 00 00       	mov    $0x20,%eax
  8023b6:	29 e8                	sub    %ebp,%eax
  8023b8:	89 c1                	mov    %eax,%ecx
  8023ba:	d3 ef                	shr    %cl,%edi
  8023bc:	89 e9                	mov    %ebp,%ecx
  8023be:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8023c2:	8b 3c 24             	mov    (%esp),%edi
  8023c5:	09 74 24 08          	or     %esi,0x8(%esp)
  8023c9:	89 d6                	mov    %edx,%esi
  8023cb:	d3 e7                	shl    %cl,%edi
  8023cd:	89 c1                	mov    %eax,%ecx
  8023cf:	89 3c 24             	mov    %edi,(%esp)
  8023d2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8023d6:	d3 ee                	shr    %cl,%esi
  8023d8:	89 e9                	mov    %ebp,%ecx
  8023da:	d3 e2                	shl    %cl,%edx
  8023dc:	89 c1                	mov    %eax,%ecx
  8023de:	d3 ef                	shr    %cl,%edi
  8023e0:	09 d7                	or     %edx,%edi
  8023e2:	89 f2                	mov    %esi,%edx
  8023e4:	89 f8                	mov    %edi,%eax
  8023e6:	f7 74 24 08          	divl   0x8(%esp)
  8023ea:	89 d6                	mov    %edx,%esi
  8023ec:	89 c7                	mov    %eax,%edi
  8023ee:	f7 24 24             	mull   (%esp)
  8023f1:	39 d6                	cmp    %edx,%esi
  8023f3:	89 14 24             	mov    %edx,(%esp)
  8023f6:	72 30                	jb     802428 <__udivdi3+0x118>
  8023f8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023fc:	89 e9                	mov    %ebp,%ecx
  8023fe:	d3 e2                	shl    %cl,%edx
  802400:	39 c2                	cmp    %eax,%edx
  802402:	73 05                	jae    802409 <__udivdi3+0xf9>
  802404:	3b 34 24             	cmp    (%esp),%esi
  802407:	74 1f                	je     802428 <__udivdi3+0x118>
  802409:	89 f8                	mov    %edi,%eax
  80240b:	31 d2                	xor    %edx,%edx
  80240d:	e9 7a ff ff ff       	jmp    80238c <__udivdi3+0x7c>
  802412:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802418:	31 d2                	xor    %edx,%edx
  80241a:	b8 01 00 00 00       	mov    $0x1,%eax
  80241f:	e9 68 ff ff ff       	jmp    80238c <__udivdi3+0x7c>
  802424:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802428:	8d 47 ff             	lea    -0x1(%edi),%eax
  80242b:	31 d2                	xor    %edx,%edx
  80242d:	83 c4 0c             	add    $0xc,%esp
  802430:	5e                   	pop    %esi
  802431:	5f                   	pop    %edi
  802432:	5d                   	pop    %ebp
  802433:	c3                   	ret    
  802434:	66 90                	xchg   %ax,%ax
  802436:	66 90                	xchg   %ax,%ax
  802438:	66 90                	xchg   %ax,%ax
  80243a:	66 90                	xchg   %ax,%ax
  80243c:	66 90                	xchg   %ax,%ax
  80243e:	66 90                	xchg   %ax,%ax

00802440 <__umoddi3>:
  802440:	55                   	push   %ebp
  802441:	57                   	push   %edi
  802442:	56                   	push   %esi
  802443:	83 ec 14             	sub    $0x14,%esp
  802446:	8b 44 24 28          	mov    0x28(%esp),%eax
  80244a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80244e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802452:	89 c7                	mov    %eax,%edi
  802454:	89 44 24 04          	mov    %eax,0x4(%esp)
  802458:	8b 44 24 30          	mov    0x30(%esp),%eax
  80245c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802460:	89 34 24             	mov    %esi,(%esp)
  802463:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802467:	85 c0                	test   %eax,%eax
  802469:	89 c2                	mov    %eax,%edx
  80246b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80246f:	75 17                	jne    802488 <__umoddi3+0x48>
  802471:	39 fe                	cmp    %edi,%esi
  802473:	76 4b                	jbe    8024c0 <__umoddi3+0x80>
  802475:	89 c8                	mov    %ecx,%eax
  802477:	89 fa                	mov    %edi,%edx
  802479:	f7 f6                	div    %esi
  80247b:	89 d0                	mov    %edx,%eax
  80247d:	31 d2                	xor    %edx,%edx
  80247f:	83 c4 14             	add    $0x14,%esp
  802482:	5e                   	pop    %esi
  802483:	5f                   	pop    %edi
  802484:	5d                   	pop    %ebp
  802485:	c3                   	ret    
  802486:	66 90                	xchg   %ax,%ax
  802488:	39 f8                	cmp    %edi,%eax
  80248a:	77 54                	ja     8024e0 <__umoddi3+0xa0>
  80248c:	0f bd e8             	bsr    %eax,%ebp
  80248f:	83 f5 1f             	xor    $0x1f,%ebp
  802492:	75 5c                	jne    8024f0 <__umoddi3+0xb0>
  802494:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802498:	39 3c 24             	cmp    %edi,(%esp)
  80249b:	0f 87 e7 00 00 00    	ja     802588 <__umoddi3+0x148>
  8024a1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8024a5:	29 f1                	sub    %esi,%ecx
  8024a7:	19 c7                	sbb    %eax,%edi
  8024a9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024ad:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024b1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024b5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8024b9:	83 c4 14             	add    $0x14,%esp
  8024bc:	5e                   	pop    %esi
  8024bd:	5f                   	pop    %edi
  8024be:	5d                   	pop    %ebp
  8024bf:	c3                   	ret    
  8024c0:	85 f6                	test   %esi,%esi
  8024c2:	89 f5                	mov    %esi,%ebp
  8024c4:	75 0b                	jne    8024d1 <__umoddi3+0x91>
  8024c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024cb:	31 d2                	xor    %edx,%edx
  8024cd:	f7 f6                	div    %esi
  8024cf:	89 c5                	mov    %eax,%ebp
  8024d1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8024d5:	31 d2                	xor    %edx,%edx
  8024d7:	f7 f5                	div    %ebp
  8024d9:	89 c8                	mov    %ecx,%eax
  8024db:	f7 f5                	div    %ebp
  8024dd:	eb 9c                	jmp    80247b <__umoddi3+0x3b>
  8024df:	90                   	nop
  8024e0:	89 c8                	mov    %ecx,%eax
  8024e2:	89 fa                	mov    %edi,%edx
  8024e4:	83 c4 14             	add    $0x14,%esp
  8024e7:	5e                   	pop    %esi
  8024e8:	5f                   	pop    %edi
  8024e9:	5d                   	pop    %ebp
  8024ea:	c3                   	ret    
  8024eb:	90                   	nop
  8024ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024f0:	8b 04 24             	mov    (%esp),%eax
  8024f3:	be 20 00 00 00       	mov    $0x20,%esi
  8024f8:	89 e9                	mov    %ebp,%ecx
  8024fa:	29 ee                	sub    %ebp,%esi
  8024fc:	d3 e2                	shl    %cl,%edx
  8024fe:	89 f1                	mov    %esi,%ecx
  802500:	d3 e8                	shr    %cl,%eax
  802502:	89 e9                	mov    %ebp,%ecx
  802504:	89 44 24 04          	mov    %eax,0x4(%esp)
  802508:	8b 04 24             	mov    (%esp),%eax
  80250b:	09 54 24 04          	or     %edx,0x4(%esp)
  80250f:	89 fa                	mov    %edi,%edx
  802511:	d3 e0                	shl    %cl,%eax
  802513:	89 f1                	mov    %esi,%ecx
  802515:	89 44 24 08          	mov    %eax,0x8(%esp)
  802519:	8b 44 24 10          	mov    0x10(%esp),%eax
  80251d:	d3 ea                	shr    %cl,%edx
  80251f:	89 e9                	mov    %ebp,%ecx
  802521:	d3 e7                	shl    %cl,%edi
  802523:	89 f1                	mov    %esi,%ecx
  802525:	d3 e8                	shr    %cl,%eax
  802527:	89 e9                	mov    %ebp,%ecx
  802529:	09 f8                	or     %edi,%eax
  80252b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80252f:	f7 74 24 04          	divl   0x4(%esp)
  802533:	d3 e7                	shl    %cl,%edi
  802535:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802539:	89 d7                	mov    %edx,%edi
  80253b:	f7 64 24 08          	mull   0x8(%esp)
  80253f:	39 d7                	cmp    %edx,%edi
  802541:	89 c1                	mov    %eax,%ecx
  802543:	89 14 24             	mov    %edx,(%esp)
  802546:	72 2c                	jb     802574 <__umoddi3+0x134>
  802548:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80254c:	72 22                	jb     802570 <__umoddi3+0x130>
  80254e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802552:	29 c8                	sub    %ecx,%eax
  802554:	19 d7                	sbb    %edx,%edi
  802556:	89 e9                	mov    %ebp,%ecx
  802558:	89 fa                	mov    %edi,%edx
  80255a:	d3 e8                	shr    %cl,%eax
  80255c:	89 f1                	mov    %esi,%ecx
  80255e:	d3 e2                	shl    %cl,%edx
  802560:	89 e9                	mov    %ebp,%ecx
  802562:	d3 ef                	shr    %cl,%edi
  802564:	09 d0                	or     %edx,%eax
  802566:	89 fa                	mov    %edi,%edx
  802568:	83 c4 14             	add    $0x14,%esp
  80256b:	5e                   	pop    %esi
  80256c:	5f                   	pop    %edi
  80256d:	5d                   	pop    %ebp
  80256e:	c3                   	ret    
  80256f:	90                   	nop
  802570:	39 d7                	cmp    %edx,%edi
  802572:	75 da                	jne    80254e <__umoddi3+0x10e>
  802574:	8b 14 24             	mov    (%esp),%edx
  802577:	89 c1                	mov    %eax,%ecx
  802579:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80257d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802581:	eb cb                	jmp    80254e <__umoddi3+0x10e>
  802583:	90                   	nop
  802584:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802588:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80258c:	0f 82 0f ff ff ff    	jb     8024a1 <__umoddi3+0x61>
  802592:	e9 1a ff ff ff       	jmp    8024b1 <__umoddi3+0x71>
