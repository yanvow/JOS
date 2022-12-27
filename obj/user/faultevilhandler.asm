
obj/user/faultevilhandler.debug:     file format elf32-i386


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
  80002c:	e8 44 00 00 00       	call   800075 <libmain>
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
  sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800040:	00 
  800041:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800048:	ee 
  800049:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800050:	e8 4e 01 00 00       	call   8001a3 <sys_page_alloc>
  sys_env_set_pgfault_upcall(0, (void*)0xF0100020);
  800055:	c7 44 24 04 20 00 10 	movl   $0xf0100020,0x4(%esp)
  80005c:	f0 
  80005d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800064:	e8 da 02 00 00       	call   800343 <sys_env_set_pgfault_upcall>
  *(int*)0 = 0;
  800069:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800070:	00 00 00 
}
  800073:	c9                   	leave  
  800074:	c3                   	ret    

00800075 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800075:	55                   	push   %ebp
  800076:	89 e5                	mov    %esp,%ebp
  800078:	56                   	push   %esi
  800079:	53                   	push   %ebx
  80007a:	83 ec 10             	sub    $0x10,%esp
  80007d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800080:	8b 75 0c             	mov    0xc(%ebp),%esi
  // set thisenv to point at our Env structure in envs[].
  // LAB 3: Your code here.
  thisenv = envs + ENVX(sys_getenvid());
  800083:	e8 dd 00 00 00       	call   800165 <sys_getenvid>
  800088:	25 ff 03 00 00       	and    $0x3ff,%eax
  80008d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800090:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800095:	a3 04 40 80 00       	mov    %eax,0x804004

  // save the name of the program so that panic() can use it
  if (argc > 0)
  80009a:	85 db                	test   %ebx,%ebx
  80009c:	7e 07                	jle    8000a5 <libmain+0x30>
    binaryname = argv[0];
  80009e:	8b 06                	mov    (%esi),%eax
  8000a0:	a3 00 30 80 00       	mov    %eax,0x803000

  // call user main routine
  umain(argc, argv);
  8000a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000a9:	89 1c 24             	mov    %ebx,(%esp)
  8000ac:	e8 82 ff ff ff       	call   800033 <umain>

  // exit gracefully
  exit();
  8000b1:	e8 07 00 00 00       	call   8000bd <exit>
}
  8000b6:	83 c4 10             	add    $0x10,%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5d                   	pop    %ebp
  8000bc:	c3                   	ret    

008000bd <exit>:
#include <inc/lib.h>

void
exit(void)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	83 ec 18             	sub    $0x18,%esp
  close_all();
  8000c3:	e8 1d 05 00 00       	call   8005e5 <close_all>
  sys_env_destroy(0);
  8000c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000cf:	e8 3f 00 00 00       	call   800113 <sys_env_destroy>
}
  8000d4:	c9                   	leave  
  8000d5:	c3                   	ret    

008000d6 <sys_cputs>:
  return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8000dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e7:	89 c3                	mov    %eax,%ebx
  8000e9:	89 c7                	mov    %eax,%edi
  8000eb:	89 c6                	mov    %eax,%esi
  8000ed:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
  syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ef:	5b                   	pop    %ebx
  8000f0:	5e                   	pop    %esi
  8000f1:	5f                   	pop    %edi
  8000f2:	5d                   	pop    %ebp
  8000f3:	c3                   	ret    

008000f4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	57                   	push   %edi
  8000f8:	56                   	push   %esi
  8000f9:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8000fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ff:	b8 01 00 00 00       	mov    $0x1,%eax
  800104:	89 d1                	mov    %edx,%ecx
  800106:	89 d3                	mov    %edx,%ebx
  800108:	89 d7                	mov    %edx,%edi
  80010a:	89 d6                	mov    %edx,%esi
  80010c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5f                   	pop    %edi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	57                   	push   %edi
  800117:	56                   	push   %esi
  800118:	53                   	push   %ebx
  800119:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  80011c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800121:	b8 03 00 00 00       	mov    $0x3,%eax
  800126:	8b 55 08             	mov    0x8(%ebp),%edx
  800129:	89 cb                	mov    %ecx,%ebx
  80012b:	89 cf                	mov    %ecx,%edi
  80012d:	89 ce                	mov    %ecx,%esi
  80012f:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800131:	85 c0                	test   %eax,%eax
  800133:	7e 28                	jle    80015d <sys_env_destroy+0x4a>
    panic("syscall %d returned %d (> 0)", num, ret);
  800135:	89 44 24 10          	mov    %eax,0x10(%esp)
  800139:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800140:	00 
  800141:	c7 44 24 08 ea 1f 80 	movl   $0x801fea,0x8(%esp)
  800148:	00 
  800149:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800150:	00 
  800151:	c7 04 24 07 20 80 00 	movl   $0x802007,(%esp)
  800158:	e8 09 10 00 00       	call   801166 <_panic>

int
sys_env_destroy(envid_t envid)
{
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80015d:	83 c4 2c             	add    $0x2c,%esp
  800160:	5b                   	pop    %ebx
  800161:	5e                   	pop    %esi
  800162:	5f                   	pop    %edi
  800163:	5d                   	pop    %ebp
  800164:	c3                   	ret    

00800165 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	57                   	push   %edi
  800169:	56                   	push   %esi
  80016a:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  80016b:	ba 00 00 00 00       	mov    $0x0,%edx
  800170:	b8 02 00 00 00       	mov    $0x2,%eax
  800175:	89 d1                	mov    %edx,%ecx
  800177:	89 d3                	mov    %edx,%ebx
  800179:	89 d7                	mov    %edx,%edi
  80017b:	89 d6                	mov    %edx,%esi
  80017d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80017f:	5b                   	pop    %ebx
  800180:	5e                   	pop    %esi
  800181:	5f                   	pop    %edi
  800182:	5d                   	pop    %ebp
  800183:	c3                   	ret    

00800184 <sys_yield>:

void
sys_yield(void)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	57                   	push   %edi
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  80018a:	ba 00 00 00 00       	mov    $0x0,%edx
  80018f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800194:	89 d1                	mov    %edx,%ecx
  800196:	89 d3                	mov    %edx,%ebx
  800198:	89 d7                	mov    %edx,%edi
  80019a:	89 d6                	mov    %edx,%esi
  80019c:	cd 30                	int    $0x30

void
sys_yield(void)
{
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80019e:	5b                   	pop    %ebx
  80019f:	5e                   	pop    %esi
  8001a0:	5f                   	pop    %edi
  8001a1:	5d                   	pop    %ebp
  8001a2:	c3                   	ret    

008001a3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	57                   	push   %edi
  8001a7:	56                   	push   %esi
  8001a8:	53                   	push   %ebx
  8001a9:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8001ac:	be 00 00 00 00       	mov    $0x0,%esi
  8001b1:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bf:	89 f7                	mov    %esi,%edi
  8001c1:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  8001c3:	85 c0                	test   %eax,%eax
  8001c5:	7e 28                	jle    8001ef <sys_page_alloc+0x4c>
    panic("syscall %d returned %d (> 0)", num, ret);
  8001c7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001cb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001d2:	00 
  8001d3:	c7 44 24 08 ea 1f 80 	movl   $0x801fea,0x8(%esp)
  8001da:	00 
  8001db:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001e2:	00 
  8001e3:	c7 04 24 07 20 80 00 	movl   $0x802007,(%esp)
  8001ea:	e8 77 0f 00 00       	call   801166 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  return syscall(SYS_page_alloc, 1, envid, (uint32_t)va, perm, 0, 0);
}
  8001ef:	83 c4 2c             	add    $0x2c,%esp
  8001f2:	5b                   	pop    %ebx
  8001f3:	5e                   	pop    %esi
  8001f4:	5f                   	pop    %edi
  8001f5:	5d                   	pop    %ebp
  8001f6:	c3                   	ret    

008001f7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	57                   	push   %edi
  8001fb:	56                   	push   %esi
  8001fc:	53                   	push   %ebx
  8001fd:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800200:	b8 05 00 00 00       	mov    $0x5,%eax
  800205:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800208:	8b 55 08             	mov    0x8(%ebp),%edx
  80020b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80020e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800211:	8b 75 18             	mov    0x18(%ebp),%esi
  800214:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800216:	85 c0                	test   %eax,%eax
  800218:	7e 28                	jle    800242 <sys_page_map+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  80021a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80021e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800225:	00 
  800226:	c7 44 24 08 ea 1f 80 	movl   $0x801fea,0x8(%esp)
  80022d:	00 
  80022e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800235:	00 
  800236:	c7 04 24 07 20 80 00 	movl   $0x802007,(%esp)
  80023d:	e8 24 0f 00 00       	call   801166 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  return syscall(SYS_page_map, 1, srcenv, (uint32_t)srcva, dstenv, (uint32_t)dstva, perm);
}
  800242:	83 c4 2c             	add    $0x2c,%esp
  800245:	5b                   	pop    %ebx
  800246:	5e                   	pop    %esi
  800247:	5f                   	pop    %edi
  800248:	5d                   	pop    %ebp
  800249:	c3                   	ret    

0080024a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80024a:	55                   	push   %ebp
  80024b:	89 e5                	mov    %esp,%ebp
  80024d:	57                   	push   %edi
  80024e:	56                   	push   %esi
  80024f:	53                   	push   %ebx
  800250:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800253:	bb 00 00 00 00       	mov    $0x0,%ebx
  800258:	b8 06 00 00 00       	mov    $0x6,%eax
  80025d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800260:	8b 55 08             	mov    0x8(%ebp),%edx
  800263:	89 df                	mov    %ebx,%edi
  800265:	89 de                	mov    %ebx,%esi
  800267:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800269:	85 c0                	test   %eax,%eax
  80026b:	7e 28                	jle    800295 <sys_page_unmap+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  80026d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800271:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800278:	00 
  800279:	c7 44 24 08 ea 1f 80 	movl   $0x801fea,0x8(%esp)
  800280:	00 
  800281:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800288:	00 
  800289:	c7 04 24 07 20 80 00 	movl   $0x802007,(%esp)
  800290:	e8 d1 0e 00 00       	call   801166 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
  return syscall(SYS_page_unmap, 1, envid, (uint32_t)va, 0, 0, 0);
}
  800295:	83 c4 2c             	add    $0x2c,%esp
  800298:	5b                   	pop    %ebx
  800299:	5e                   	pop    %esi
  80029a:	5f                   	pop    %edi
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    

0080029d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	57                   	push   %edi
  8002a1:	56                   	push   %esi
  8002a2:	53                   	push   %ebx
  8002a3:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8002a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ab:	b8 08 00 00 00       	mov    $0x8,%eax
  8002b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b6:	89 df                	mov    %ebx,%edi
  8002b8:	89 de                	mov    %ebx,%esi
  8002ba:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  8002bc:	85 c0                	test   %eax,%eax
  8002be:	7e 28                	jle    8002e8 <sys_env_set_status+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  8002c0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002c4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002cb:	00 
  8002cc:	c7 44 24 08 ea 1f 80 	movl   $0x801fea,0x8(%esp)
  8002d3:	00 
  8002d4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002db:	00 
  8002dc:	c7 04 24 07 20 80 00 	movl   $0x802007,(%esp)
  8002e3:	e8 7e 0e 00 00       	call   801166 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002e8:	83 c4 2c             	add    $0x2c,%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
  8002f6:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8002f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002fe:	b8 09 00 00 00       	mov    $0x9,%eax
  800303:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800306:	8b 55 08             	mov    0x8(%ebp),%edx
  800309:	89 df                	mov    %ebx,%edi
  80030b:	89 de                	mov    %ebx,%esi
  80030d:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  80030f:	85 c0                	test   %eax,%eax
  800311:	7e 28                	jle    80033b <sys_env_set_trapframe+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800313:	89 44 24 10          	mov    %eax,0x10(%esp)
  800317:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80031e:	00 
  80031f:	c7 44 24 08 ea 1f 80 	movl   $0x801fea,0x8(%esp)
  800326:	00 
  800327:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80032e:	00 
  80032f:	c7 04 24 07 20 80 00 	movl   $0x802007,(%esp)
  800336:	e8 2b 0e 00 00       	call   801166 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t)tf, 0, 0, 0);
}
  80033b:	83 c4 2c             	add    $0x2c,%esp
  80033e:	5b                   	pop    %ebx
  80033f:	5e                   	pop    %esi
  800340:	5f                   	pop    %edi
  800341:	5d                   	pop    %ebp
  800342:	c3                   	ret    

00800343 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800343:	55                   	push   %ebp
  800344:	89 e5                	mov    %esp,%ebp
  800346:	57                   	push   %edi
  800347:	56                   	push   %esi
  800348:	53                   	push   %ebx
  800349:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  80034c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800351:	b8 0a 00 00 00       	mov    $0xa,%eax
  800356:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800359:	8b 55 08             	mov    0x8(%ebp),%edx
  80035c:	89 df                	mov    %ebx,%edi
  80035e:	89 de                	mov    %ebx,%esi
  800360:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800362:	85 c0                	test   %eax,%eax
  800364:	7e 28                	jle    80038e <sys_env_set_pgfault_upcall+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800366:	89 44 24 10          	mov    %eax,0x10(%esp)
  80036a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800371:	00 
  800372:	c7 44 24 08 ea 1f 80 	movl   $0x801fea,0x8(%esp)
  800379:	00 
  80037a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800381:	00 
  800382:	c7 04 24 07 20 80 00 	movl   $0x802007,(%esp)
  800389:	e8 d8 0d 00 00       	call   801166 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80038e:	83 c4 2c             	add    $0x2c,%esp
  800391:	5b                   	pop    %ebx
  800392:	5e                   	pop    %esi
  800393:	5f                   	pop    %edi
  800394:	5d                   	pop    %ebp
  800395:	c3                   	ret    

00800396 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800396:	55                   	push   %ebp
  800397:	89 e5                	mov    %esp,%ebp
  800399:	57                   	push   %edi
  80039a:	56                   	push   %esi
  80039b:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  80039c:	be 00 00 00 00       	mov    $0x0,%esi
  8003a1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003b2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t)srcva, perm, 0);
}
  8003b4:	5b                   	pop    %ebx
  8003b5:	5e                   	pop    %esi
  8003b6:	5f                   	pop    %edi
  8003b7:	5d                   	pop    %ebp
  8003b8:	c3                   	ret    

008003b9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003b9:	55                   	push   %ebp
  8003ba:	89 e5                	mov    %esp,%ebp
  8003bc:	57                   	push   %edi
  8003bd:	56                   	push   %esi
  8003be:	53                   	push   %ebx
  8003bf:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8003c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c7:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8003cf:	89 cb                	mov    %ecx,%ebx
  8003d1:	89 cf                	mov    %ecx,%edi
  8003d3:	89 ce                	mov    %ecx,%esi
  8003d5:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  8003d7:	85 c0                	test   %eax,%eax
  8003d9:	7e 28                	jle    800403 <sys_ipc_recv+0x4a>
    panic("syscall %d returned %d (> 0)", num, ret);
  8003db:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003df:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003e6:	00 
  8003e7:	c7 44 24 08 ea 1f 80 	movl   $0x801fea,0x8(%esp)
  8003ee:	00 
  8003ef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003f6:	00 
  8003f7:	c7 04 24 07 20 80 00 	movl   $0x802007,(%esp)
  8003fe:	e8 63 0d 00 00       	call   801166 <_panic>

int
sys_ipc_recv(void *dstva)
{
  return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800403:	83 c4 2c             	add    $0x2c,%esp
  800406:	5b                   	pop    %ebx
  800407:	5e                   	pop    %esi
  800408:	5f                   	pop    %edi
  800409:	5d                   	pop    %ebp
  80040a:	c3                   	ret    
  80040b:	66 90                	xchg   %ax,%ax
  80040d:	66 90                	xchg   %ax,%ax
  80040f:	90                   	nop

00800410 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800410:	55                   	push   %ebp
  800411:	89 e5                	mov    %esp,%ebp
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  800413:	8b 45 08             	mov    0x8(%ebp),%eax
  800416:	05 00 00 00 30       	add    $0x30000000,%eax
  80041b:	c1 e8 0c             	shr    $0xc,%eax
}
  80041e:	5d                   	pop    %ebp
  80041f:	c3                   	ret    

00800420 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  800423:	8b 45 08             	mov    0x8(%ebp),%eax
  800426:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
  return INDEX2DATA(fd2num(fd));
  80042b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800430:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800435:	5d                   	pop    %ebp
  800436:	c3                   	ret    

00800437 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800437:	55                   	push   %ebp
  800438:	89 e5                	mov    %esp,%ebp
  80043a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80043d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
  int i;
  struct Fd *fd;

  for (i = 0; i < MAXFD; i++) {
    fd = INDEX2FD(i);
    if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800442:	89 c2                	mov    %eax,%edx
  800444:	c1 ea 16             	shr    $0x16,%edx
  800447:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80044e:	f6 c2 01             	test   $0x1,%dl
  800451:	74 11                	je     800464 <fd_alloc+0x2d>
  800453:	89 c2                	mov    %eax,%edx
  800455:	c1 ea 0c             	shr    $0xc,%edx
  800458:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80045f:	f6 c2 01             	test   $0x1,%dl
  800462:	75 09                	jne    80046d <fd_alloc+0x36>
      *fd_store = fd;
  800464:	89 01                	mov    %eax,(%ecx)
      return 0;
  800466:	b8 00 00 00 00       	mov    $0x0,%eax
  80046b:	eb 17                	jmp    800484 <fd_alloc+0x4d>
  80046d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
  int i;
  struct Fd *fd;

  for (i = 0; i < MAXFD; i++) {
  800472:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800477:	75 c9                	jne    800442 <fd_alloc+0xb>
    if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
      *fd_store = fd;
      return 0;
    }
  }
  *fd_store = 0;
  800479:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
  return -E_MAX_OPEN;
  80047f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800484:	5d                   	pop    %ebp
  800485:	c3                   	ret    

00800486 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800486:	55                   	push   %ebp
  800487:	89 e5                	mov    %esp,%ebp
  800489:	8b 45 08             	mov    0x8(%ebp),%eax
  struct Fd *fd;

  if (fdnum < 0 || fdnum >= MAXFD) {
  80048c:	83 f8 1f             	cmp    $0x1f,%eax
  80048f:	77 36                	ja     8004c7 <fd_lookup+0x41>
    if (debug)
      cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  fd = INDEX2FD(fdnum);
  800491:	c1 e0 0c             	shl    $0xc,%eax
  800494:	2d 00 00 00 30       	sub    $0x30000000,%eax
  if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800499:	89 c2                	mov    %eax,%edx
  80049b:	c1 ea 16             	shr    $0x16,%edx
  80049e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8004a5:	f6 c2 01             	test   $0x1,%dl
  8004a8:	74 24                	je     8004ce <fd_lookup+0x48>
  8004aa:	89 c2                	mov    %eax,%edx
  8004ac:	c1 ea 0c             	shr    $0xc,%edx
  8004af:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004b6:	f6 c2 01             	test   $0x1,%dl
  8004b9:	74 1a                	je     8004d5 <fd_lookup+0x4f>
    if (debug)
      cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  *fd_store = fd;
  8004bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004be:	89 02                	mov    %eax,(%edx)
  return 0;
  8004c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c5:	eb 13                	jmp    8004da <fd_lookup+0x54>
  struct Fd *fd;

  if (fdnum < 0 || fdnum >= MAXFD) {
    if (debug)
      cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  8004c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004cc:	eb 0c                	jmp    8004da <fd_lookup+0x54>
  }
  fd = INDEX2FD(fdnum);
  if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
    if (debug)
      cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  8004ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004d3:	eb 05                	jmp    8004da <fd_lookup+0x54>
  8004d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  }
  *fd_store = fd;
  return 0;
}
  8004da:	5d                   	pop    %ebp
  8004db:	c3                   	ret    

008004dc <dev_lookup>:
  0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004dc:	55                   	push   %ebp
  8004dd:	89 e5                	mov    %esp,%ebp
  8004df:	83 ec 18             	sub    $0x18,%esp
  8004e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004e5:	ba 94 20 80 00       	mov    $0x802094,%edx
  int i;

  for (i = 0; devtab[i]; i++)
  8004ea:	eb 13                	jmp    8004ff <dev_lookup+0x23>
  8004ec:	83 c2 04             	add    $0x4,%edx
    if (devtab[i]->dev_id == dev_id) {
  8004ef:	39 08                	cmp    %ecx,(%eax)
  8004f1:	75 0c                	jne    8004ff <dev_lookup+0x23>
      *dev = devtab[i];
  8004f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004f6:	89 01                	mov    %eax,(%ecx)
      return 0;
  8004f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fd:	eb 30                	jmp    80052f <dev_lookup+0x53>
int
dev_lookup(int dev_id, struct Dev **dev)
{
  int i;

  for (i = 0; devtab[i]; i++)
  8004ff:	8b 02                	mov    (%edx),%eax
  800501:	85 c0                	test   %eax,%eax
  800503:	75 e7                	jne    8004ec <dev_lookup+0x10>
    if (devtab[i]->dev_id == dev_id) {
      *dev = devtab[i];
      return 0;
    }
  cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800505:	a1 04 40 80 00       	mov    0x804004,%eax
  80050a:	8b 40 48             	mov    0x48(%eax),%eax
  80050d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800511:	89 44 24 04          	mov    %eax,0x4(%esp)
  800515:	c7 04 24 18 20 80 00 	movl   $0x802018,(%esp)
  80051c:	e8 3e 0d 00 00       	call   80125f <cprintf>
  *dev = 0;
  800521:	8b 45 0c             	mov    0xc(%ebp),%eax
  800524:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  return -E_INVAL;
  80052a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80052f:	c9                   	leave  
  800530:	c3                   	ret    

00800531 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800531:	55                   	push   %ebp
  800532:	89 e5                	mov    %esp,%ebp
  800534:	56                   	push   %esi
  800535:	53                   	push   %ebx
  800536:	83 ec 20             	sub    $0x20,%esp
  800539:	8b 75 08             	mov    0x8(%ebp),%esi
  80053c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct Fd *fd2;
  struct Dev *dev;
  int r;

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80053f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800542:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  800546:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80054c:	c1 e8 0c             	shr    $0xc,%eax
{
  struct Fd *fd2;
  struct Dev *dev;
  int r;

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80054f:	89 04 24             	mov    %eax,(%esp)
  800552:	e8 2f ff ff ff       	call   800486 <fd_lookup>
  800557:	85 c0                	test   %eax,%eax
  800559:	78 05                	js     800560 <fd_close+0x2f>
      || fd != fd2)
  80055b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80055e:	74 0c                	je     80056c <fd_close+0x3b>
    return must_exist ? r : 0;
  800560:	84 db                	test   %bl,%bl
  800562:	ba 00 00 00 00       	mov    $0x0,%edx
  800567:	0f 44 c2             	cmove  %edx,%eax
  80056a:	eb 3f                	jmp    8005ab <fd_close+0x7a>
  if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80056c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80056f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800573:	8b 06                	mov    (%esi),%eax
  800575:	89 04 24             	mov    %eax,(%esp)
  800578:	e8 5f ff ff ff       	call   8004dc <dev_lookup>
  80057d:	89 c3                	mov    %eax,%ebx
  80057f:	85 c0                	test   %eax,%eax
  800581:	78 16                	js     800599 <fd_close+0x68>
    if (dev->dev_close)
  800583:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800586:	8b 40 10             	mov    0x10(%eax),%eax
      r = (*dev->dev_close)(fd);
    else
      r = 0;
  800589:	bb 00 00 00 00       	mov    $0x0,%ebx

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
      || fd != fd2)
    return must_exist ? r : 0;
  if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
    if (dev->dev_close)
  80058e:	85 c0                	test   %eax,%eax
  800590:	74 07                	je     800599 <fd_close+0x68>
      r = (*dev->dev_close)(fd);
  800592:	89 34 24             	mov    %esi,(%esp)
  800595:	ff d0                	call   *%eax
  800597:	89 c3                	mov    %eax,%ebx
    else
      r = 0;
  }
  // Make sure fd is unmapped.  Might be a no-op if
  // (*dev->dev_close)(fd) already unmapped it.
  (void)sys_page_unmap(0, fd);
  800599:	89 74 24 04          	mov    %esi,0x4(%esp)
  80059d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005a4:	e8 a1 fc ff ff       	call   80024a <sys_page_unmap>
  return r;
  8005a9:	89 d8                	mov    %ebx,%eax
}
  8005ab:	83 c4 20             	add    $0x20,%esp
  8005ae:	5b                   	pop    %ebx
  8005af:	5e                   	pop    %esi
  8005b0:	5d                   	pop    %ebp
  8005b1:	c3                   	ret    

008005b2 <close>:
  return -E_INVAL;
}

int
close(int fdnum)
{
  8005b2:	55                   	push   %ebp
  8005b3:	89 e5                	mov    %esp,%ebp
  8005b5:	83 ec 28             	sub    $0x28,%esp
  struct Fd *fd;
  int r;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c2:	89 04 24             	mov    %eax,(%esp)
  8005c5:	e8 bc fe ff ff       	call   800486 <fd_lookup>
  8005ca:	89 c2                	mov    %eax,%edx
  8005cc:	85 d2                	test   %edx,%edx
  8005ce:	78 13                	js     8005e3 <close+0x31>
    return r;
  else
    return fd_close(fd, 1);
  8005d0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8005d7:	00 
  8005d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005db:	89 04 24             	mov    %eax,(%esp)
  8005de:	e8 4e ff ff ff       	call   800531 <fd_close>
}
  8005e3:	c9                   	leave  
  8005e4:	c3                   	ret    

008005e5 <close_all>:

void
close_all(void)
{
  8005e5:	55                   	push   %ebp
  8005e6:	89 e5                	mov    %esp,%ebp
  8005e8:	53                   	push   %ebx
  8005e9:	83 ec 14             	sub    $0x14,%esp
  int i;

  for (i = 0; i < MAXFD; i++)
  8005ec:	bb 00 00 00 00       	mov    $0x0,%ebx
    close(i);
  8005f1:	89 1c 24             	mov    %ebx,(%esp)
  8005f4:	e8 b9 ff ff ff       	call   8005b2 <close>
void
close_all(void)
{
  int i;

  for (i = 0; i < MAXFD; i++)
  8005f9:	83 c3 01             	add    $0x1,%ebx
  8005fc:	83 fb 20             	cmp    $0x20,%ebx
  8005ff:	75 f0                	jne    8005f1 <close_all+0xc>
    close(i);
}
  800601:	83 c4 14             	add    $0x14,%esp
  800604:	5b                   	pop    %ebx
  800605:	5d                   	pop    %ebp
  800606:	c3                   	ret    

00800607 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800607:	55                   	push   %ebp
  800608:	89 e5                	mov    %esp,%ebp
  80060a:	57                   	push   %edi
  80060b:	56                   	push   %esi
  80060c:	53                   	push   %ebx
  80060d:	83 ec 3c             	sub    $0x3c,%esp
  int r;
  char *ova, *nva;
  pte_t pte;
  struct Fd *oldfd, *newfd;

  if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800610:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800613:	89 44 24 04          	mov    %eax,0x4(%esp)
  800617:	8b 45 08             	mov    0x8(%ebp),%eax
  80061a:	89 04 24             	mov    %eax,(%esp)
  80061d:	e8 64 fe ff ff       	call   800486 <fd_lookup>
  800622:	89 c2                	mov    %eax,%edx
  800624:	85 d2                	test   %edx,%edx
  800626:	0f 88 e1 00 00 00    	js     80070d <dup+0x106>
    return r;
  close(newfdnum);
  80062c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80062f:	89 04 24             	mov    %eax,(%esp)
  800632:	e8 7b ff ff ff       	call   8005b2 <close>

  newfd = INDEX2FD(newfdnum);
  800637:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80063a:	c1 e3 0c             	shl    $0xc,%ebx
  80063d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
  ova = fd2data(oldfd);
  800643:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800646:	89 04 24             	mov    %eax,(%esp)
  800649:	e8 d2 fd ff ff       	call   800420 <fd2data>
  80064e:	89 c6                	mov    %eax,%esi
  nva = fd2data(newfd);
  800650:	89 1c 24             	mov    %ebx,(%esp)
  800653:	e8 c8 fd ff ff       	call   800420 <fd2data>
  800658:	89 c7                	mov    %eax,%edi

  if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80065a:	89 f0                	mov    %esi,%eax
  80065c:	c1 e8 16             	shr    $0x16,%eax
  80065f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800666:	a8 01                	test   $0x1,%al
  800668:	74 43                	je     8006ad <dup+0xa6>
  80066a:	89 f0                	mov    %esi,%eax
  80066c:	c1 e8 0c             	shr    $0xc,%eax
  80066f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800676:	f6 c2 01             	test   $0x1,%dl
  800679:	74 32                	je     8006ad <dup+0xa6>
    if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80067b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800682:	25 07 0e 00 00       	and    $0xe07,%eax
  800687:	89 44 24 10          	mov    %eax,0x10(%esp)
  80068b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80068f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800696:	00 
  800697:	89 74 24 04          	mov    %esi,0x4(%esp)
  80069b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006a2:	e8 50 fb ff ff       	call   8001f7 <sys_page_map>
  8006a7:	89 c6                	mov    %eax,%esi
  8006a9:	85 c0                	test   %eax,%eax
  8006ab:	78 3e                	js     8006eb <dup+0xe4>
      goto err;
  if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006b0:	89 c2                	mov    %eax,%edx
  8006b2:	c1 ea 0c             	shr    $0xc,%edx
  8006b5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006bc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8006c2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006c6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006ca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006d1:	00 
  8006d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006dd:	e8 15 fb ff ff       	call   8001f7 <sys_page_map>
  8006e2:	89 c6                	mov    %eax,%esi
    goto err;

  return newfdnum;
  8006e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  nva = fd2data(newfd);

  if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
    if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
      goto err;
  if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006e7:	85 f6                	test   %esi,%esi
  8006e9:	79 22                	jns    80070d <dup+0x106>
    goto err;

  return newfdnum;

err:
  sys_page_unmap(0, newfd);
  8006eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006f6:	e8 4f fb ff ff       	call   80024a <sys_page_unmap>
  sys_page_unmap(0, nva);
  8006fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800706:	e8 3f fb ff ff       	call   80024a <sys_page_unmap>
  return r;
  80070b:	89 f0                	mov    %esi,%eax
}
  80070d:	83 c4 3c             	add    $0x3c,%esp
  800710:	5b                   	pop    %ebx
  800711:	5e                   	pop    %esi
  800712:	5f                   	pop    %edi
  800713:	5d                   	pop    %ebp
  800714:	c3                   	ret    

00800715 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800715:	55                   	push   %ebp
  800716:	89 e5                	mov    %esp,%ebp
  800718:	53                   	push   %ebx
  800719:	83 ec 24             	sub    $0x24,%esp
  80071c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  80071f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800722:	89 44 24 04          	mov    %eax,0x4(%esp)
  800726:	89 1c 24             	mov    %ebx,(%esp)
  800729:	e8 58 fd ff ff       	call   800486 <fd_lookup>
  80072e:	89 c2                	mov    %eax,%edx
  800730:	85 d2                	test   %edx,%edx
  800732:	78 6d                	js     8007a1 <read+0x8c>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800734:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800737:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80073e:	8b 00                	mov    (%eax),%eax
  800740:	89 04 24             	mov    %eax,(%esp)
  800743:	e8 94 fd ff ff       	call   8004dc <dev_lookup>
  800748:	85 c0                	test   %eax,%eax
  80074a:	78 55                	js     8007a1 <read+0x8c>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80074c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80074f:	8b 50 08             	mov    0x8(%eax),%edx
  800752:	83 e2 03             	and    $0x3,%edx
  800755:	83 fa 01             	cmp    $0x1,%edx
  800758:	75 23                	jne    80077d <read+0x68>
    cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80075a:	a1 04 40 80 00       	mov    0x804004,%eax
  80075f:	8b 40 48             	mov    0x48(%eax),%eax
  800762:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800766:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076a:	c7 04 24 59 20 80 00 	movl   $0x802059,(%esp)
  800771:	e8 e9 0a 00 00       	call   80125f <cprintf>
    return -E_INVAL;
  800776:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80077b:	eb 24                	jmp    8007a1 <read+0x8c>
  }
  if (!dev->dev_read)
  80077d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800780:	8b 52 08             	mov    0x8(%edx),%edx
  800783:	85 d2                	test   %edx,%edx
  800785:	74 15                	je     80079c <read+0x87>
    return -E_NOT_SUPP;
  return (*dev->dev_read)(fd, buf, n);
  800787:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80078a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80078e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800791:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800795:	89 04 24             	mov    %eax,(%esp)
  800798:	ff d2                	call   *%edx
  80079a:	eb 05                	jmp    8007a1 <read+0x8c>
  if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
    cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  if (!dev->dev_read)
    return -E_NOT_SUPP;
  80079c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_read)(fd, buf, n);
}
  8007a1:	83 c4 24             	add    $0x24,%esp
  8007a4:	5b                   	pop    %ebx
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	57                   	push   %edi
  8007ab:	56                   	push   %esi
  8007ac:	53                   	push   %ebx
  8007ad:	83 ec 1c             	sub    $0x1c,%esp
  8007b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007b3:	8b 75 10             	mov    0x10(%ebp),%esi
  int m, tot;

  for (tot = 0; tot < n; tot += m) {
  8007b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007bb:	eb 23                	jmp    8007e0 <readn+0x39>
    m = read(fdnum, (char*)buf + tot, n - tot);
  8007bd:	89 f0                	mov    %esi,%eax
  8007bf:	29 d8                	sub    %ebx,%eax
  8007c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c5:	89 d8                	mov    %ebx,%eax
  8007c7:	03 45 0c             	add    0xc(%ebp),%eax
  8007ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ce:	89 3c 24             	mov    %edi,(%esp)
  8007d1:	e8 3f ff ff ff       	call   800715 <read>
    if (m < 0)
  8007d6:	85 c0                	test   %eax,%eax
  8007d8:	78 10                	js     8007ea <readn+0x43>
      return m;
    if (m == 0)
  8007da:	85 c0                	test   %eax,%eax
  8007dc:	74 0a                	je     8007e8 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
  int m, tot;

  for (tot = 0; tot < n; tot += m) {
  8007de:	01 c3                	add    %eax,%ebx
  8007e0:	39 f3                	cmp    %esi,%ebx
  8007e2:	72 d9                	jb     8007bd <readn+0x16>
  8007e4:	89 d8                	mov    %ebx,%eax
  8007e6:	eb 02                	jmp    8007ea <readn+0x43>
  8007e8:	89 d8                	mov    %ebx,%eax
      return m;
    if (m == 0)
      break;
  }
  return tot;
}
  8007ea:	83 c4 1c             	add    $0x1c,%esp
  8007ed:	5b                   	pop    %ebx
  8007ee:	5e                   	pop    %esi
  8007ef:	5f                   	pop    %edi
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	53                   	push   %ebx
  8007f6:	83 ec 24             	sub    $0x24,%esp
  8007f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  8007fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800803:	89 1c 24             	mov    %ebx,(%esp)
  800806:	e8 7b fc ff ff       	call   800486 <fd_lookup>
  80080b:	89 c2                	mov    %eax,%edx
  80080d:	85 d2                	test   %edx,%edx
  80080f:	78 68                	js     800879 <write+0x87>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800811:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800814:	89 44 24 04          	mov    %eax,0x4(%esp)
  800818:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80081b:	8b 00                	mov    (%eax),%eax
  80081d:	89 04 24             	mov    %eax,(%esp)
  800820:	e8 b7 fc ff ff       	call   8004dc <dev_lookup>
  800825:	85 c0                	test   %eax,%eax
  800827:	78 50                	js     800879 <write+0x87>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800829:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80082c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800830:	75 23                	jne    800855 <write+0x63>
    cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800832:	a1 04 40 80 00       	mov    0x804004,%eax
  800837:	8b 40 48             	mov    0x48(%eax),%eax
  80083a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80083e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800842:	c7 04 24 75 20 80 00 	movl   $0x802075,(%esp)
  800849:	e8 11 0a 00 00       	call   80125f <cprintf>
    return -E_INVAL;
  80084e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800853:	eb 24                	jmp    800879 <write+0x87>
  }
  if (debug)
    cprintf("write %d %p %d via dev %s\n",
            fdnum, buf, n, dev->dev_name);
  if (!dev->dev_write)
  800855:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800858:	8b 52 0c             	mov    0xc(%edx),%edx
  80085b:	85 d2                	test   %edx,%edx
  80085d:	74 15                	je     800874 <write+0x82>
    return -E_NOT_SUPP;
  return (*dev->dev_write)(fd, buf, n);
  80085f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800862:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800866:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800869:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80086d:	89 04 24             	mov    %eax,(%esp)
  800870:	ff d2                	call   *%edx
  800872:	eb 05                	jmp    800879 <write+0x87>
  }
  if (debug)
    cprintf("write %d %p %d via dev %s\n",
            fdnum, buf, n, dev->dev_name);
  if (!dev->dev_write)
    return -E_NOT_SUPP;
  800874:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_write)(fd, buf, n);
}
  800879:	83 c4 24             	add    $0x24,%esp
  80087c:	5b                   	pop    %ebx
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <seek>:

int
seek(int fdnum, off_t offset)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	83 ec 18             	sub    $0x18,%esp
  int r;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  800885:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800888:	89 44 24 04          	mov    %eax,0x4(%esp)
  80088c:	8b 45 08             	mov    0x8(%ebp),%eax
  80088f:	89 04 24             	mov    %eax,(%esp)
  800892:	e8 ef fb ff ff       	call   800486 <fd_lookup>
  800897:	85 c0                	test   %eax,%eax
  800899:	78 0e                	js     8008a9 <seek+0x2a>
    return r;
  fd->fd_offset = offset;
  80089b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80089e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a1:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
  8008a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a9:	c9                   	leave  
  8008aa:	c3                   	ret    

008008ab <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	53                   	push   %ebx
  8008af:	83 ec 24             	sub    $0x24,%esp
  8008b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  8008b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008bc:	89 1c 24             	mov    %ebx,(%esp)
  8008bf:	e8 c2 fb ff ff       	call   800486 <fd_lookup>
  8008c4:	89 c2                	mov    %eax,%edx
  8008c6:	85 d2                	test   %edx,%edx
  8008c8:	78 61                	js     80092b <ftruncate+0x80>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008d4:	8b 00                	mov    (%eax),%eax
  8008d6:	89 04 24             	mov    %eax,(%esp)
  8008d9:	e8 fe fb ff ff       	call   8004dc <dev_lookup>
  8008de:	85 c0                	test   %eax,%eax
  8008e0:	78 49                	js     80092b <ftruncate+0x80>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008e5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008e9:	75 23                	jne    80090e <ftruncate+0x63>
    cprintf("[%08x] ftruncate %d -- bad mode\n",
            thisenv->env_id, fdnum);
  8008eb:	a1 04 40 80 00       	mov    0x804004,%eax

  if ((r = fd_lookup(fdnum, &fd)) < 0
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
    cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008f0:	8b 40 48             	mov    0x48(%eax),%eax
  8008f3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008fb:	c7 04 24 38 20 80 00 	movl   $0x802038,(%esp)
  800902:	e8 58 09 00 00       	call   80125f <cprintf>
            thisenv->env_id, fdnum);
    return -E_INVAL;
  800907:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80090c:	eb 1d                	jmp    80092b <ftruncate+0x80>
  }
  if (!dev->dev_trunc)
  80090e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800911:	8b 52 18             	mov    0x18(%edx),%edx
  800914:	85 d2                	test   %edx,%edx
  800916:	74 0e                	je     800926 <ftruncate+0x7b>
    return -E_NOT_SUPP;
  return (*dev->dev_trunc)(fd, newsize);
  800918:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80091f:	89 04 24             	mov    %eax,(%esp)
  800922:	ff d2                	call   *%edx
  800924:	eb 05                	jmp    80092b <ftruncate+0x80>
    cprintf("[%08x] ftruncate %d -- bad mode\n",
            thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  if (!dev->dev_trunc)
    return -E_NOT_SUPP;
  800926:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_trunc)(fd, newsize);
}
  80092b:	83 c4 24             	add    $0x24,%esp
  80092e:	5b                   	pop    %ebx
  80092f:	5d                   	pop    %ebp
  800930:	c3                   	ret    

00800931 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	53                   	push   %ebx
  800935:	83 ec 24             	sub    $0x24,%esp
  800938:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  80093b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80093e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	89 04 24             	mov    %eax,(%esp)
  800948:	e8 39 fb ff ff       	call   800486 <fd_lookup>
  80094d:	89 c2                	mov    %eax,%edx
  80094f:	85 d2                	test   %edx,%edx
  800951:	78 52                	js     8009a5 <fstat+0x74>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800953:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800956:	89 44 24 04          	mov    %eax,0x4(%esp)
  80095a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80095d:	8b 00                	mov    (%eax),%eax
  80095f:	89 04 24             	mov    %eax,(%esp)
  800962:	e8 75 fb ff ff       	call   8004dc <dev_lookup>
  800967:	85 c0                	test   %eax,%eax
  800969:	78 3a                	js     8009a5 <fstat+0x74>
    return r;
  if (!dev->dev_stat)
  80096b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80096e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800972:	74 2c                	je     8009a0 <fstat+0x6f>
    return -E_NOT_SUPP;
  stat->st_name[0] = 0;
  800974:	c6 03 00             	movb   $0x0,(%ebx)
  stat->st_size = 0;
  800977:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80097e:	00 00 00 
  stat->st_isdir = 0;
  800981:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800988:	00 00 00 
  stat->st_dev = dev;
  80098b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
  return (*dev->dev_stat)(fd, stat);
  800991:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800995:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800998:	89 14 24             	mov    %edx,(%esp)
  80099b:	ff 50 14             	call   *0x14(%eax)
  80099e:	eb 05                	jmp    8009a5 <fstat+0x74>

  if ((r = fd_lookup(fdnum, &fd)) < 0
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
    return r;
  if (!dev->dev_stat)
    return -E_NOT_SUPP;
  8009a0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  stat->st_name[0] = 0;
  stat->st_size = 0;
  stat->st_isdir = 0;
  stat->st_dev = dev;
  return (*dev->dev_stat)(fd, stat);
}
  8009a5:	83 c4 24             	add    $0x24,%esp
  8009a8:	5b                   	pop    %ebx
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	56                   	push   %esi
  8009af:	53                   	push   %ebx
  8009b0:	83 ec 10             	sub    $0x10,%esp
  int fd, r;

  if ((fd = open(path, O_RDONLY)) < 0)
  8009b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8009ba:	00 
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	89 04 24             	mov    %eax,(%esp)
  8009c1:	e8 d2 01 00 00       	call   800b98 <open>
  8009c6:	89 c3                	mov    %eax,%ebx
  8009c8:	85 db                	test   %ebx,%ebx
  8009ca:	78 1b                	js     8009e7 <stat+0x3c>
    return fd;
  r = fstat(fd, stat);
  8009cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d3:	89 1c 24             	mov    %ebx,(%esp)
  8009d6:	e8 56 ff ff ff       	call   800931 <fstat>
  8009db:	89 c6                	mov    %eax,%esi
  close(fd);
  8009dd:	89 1c 24             	mov    %ebx,(%esp)
  8009e0:	e8 cd fb ff ff       	call   8005b2 <close>
  return r;
  8009e5:	89 f0                	mov    %esi,%eax
}
  8009e7:	83 c4 10             	add    $0x10,%esp
  8009ea:	5b                   	pop    %ebx
  8009eb:	5e                   	pop    %esi
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	56                   	push   %esi
  8009f2:	53                   	push   %ebx
  8009f3:	83 ec 10             	sub    $0x10,%esp
  8009f6:	89 c6                	mov    %eax,%esi
  8009f8:	89 d3                	mov    %edx,%ebx
  static envid_t fsenv;

  if (fsenv == 0)
  8009fa:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800a01:	75 11                	jne    800a14 <fsipc+0x26>
    fsenv = ipc_find_env(ENV_TYPE_FS);
  800a03:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a0a:	e8 b8 12 00 00       	call   801cc7 <ipc_find_env>
  800a0f:	a3 00 40 80 00       	mov    %eax,0x804000
  static_assert(sizeof(fsipcbuf) == PGSIZE);

  if (debug)
    cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t*)&fsipcbuf);

  ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a14:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a1b:	00 
  800a1c:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a23:	00 
  800a24:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a28:	a1 00 40 80 00       	mov    0x804000,%eax
  800a2d:	89 04 24             	mov    %eax,(%esp)
  800a30:	e8 27 12 00 00       	call   801c5c <ipc_send>
  return ipc_recv(NULL, dstva, NULL);
  800a35:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a3c:	00 
  800a3d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a48:	e8 89 11 00 00       	call   801bd6 <ipc_recv>
}
  800a4d:	83 c4 10             	add    $0x10,%esp
  800a50:	5b                   	pop    %ebx
  800a51:	5e                   	pop    %esi
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	83 ec 08             	sub    $0x8,%esp
  fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a60:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.set_size.req_size = newsize;
  800a65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a68:	a3 04 50 80 00       	mov    %eax,0x805004
  return fsipc(FSREQ_SET_SIZE, NULL);
  800a6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a72:	b8 02 00 00 00       	mov    $0x2,%eax
  800a77:	e8 72 ff ff ff       	call   8009ee <fsipc>
}
  800a7c:	c9                   	leave  
  800a7d:	c3                   	ret    

00800a7e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	83 ec 08             	sub    $0x8,%esp
  fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a84:	8b 45 08             	mov    0x8(%ebp),%eax
  800a87:	8b 40 0c             	mov    0xc(%eax),%eax
  800a8a:	a3 00 50 80 00       	mov    %eax,0x805000
  return fsipc(FSREQ_FLUSH, NULL);
  800a8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a94:	b8 06 00 00 00       	mov    $0x6,%eax
  800a99:	e8 50 ff ff ff       	call   8009ee <fsipc>
}
  800a9e:	c9                   	leave  
  800a9f:	c3                   	ret    

00800aa0 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	53                   	push   %ebx
  800aa4:	83 ec 14             	sub    $0x14,%esp
  800aa7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int r;

  fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800aaa:	8b 45 08             	mov    0x8(%ebp),%eax
  800aad:	8b 40 0c             	mov    0xc(%eax),%eax
  800ab0:	a3 00 50 80 00       	mov    %eax,0x805000
  if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800ab5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aba:	b8 05 00 00 00       	mov    $0x5,%eax
  800abf:	e8 2a ff ff ff       	call   8009ee <fsipc>
  800ac4:	89 c2                	mov    %eax,%edx
  800ac6:	85 d2                	test   %edx,%edx
  800ac8:	78 2b                	js     800af5 <devfile_stat+0x55>
    return r;
  strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800aca:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800ad1:	00 
  800ad2:	89 1c 24             	mov    %ebx,(%esp)
  800ad5:	e8 ad 0d 00 00       	call   801887 <strcpy>
  st->st_size = fsipcbuf.statRet.ret_size;
  800ada:	a1 80 50 80 00       	mov    0x805080,%eax
  800adf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800ae5:	a1 84 50 80 00       	mov    0x805084,%eax
  800aea:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  return 0;
  800af0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af5:	83 c4 14             	add    $0x14,%esp
  800af8:	5b                   	pop    %ebx
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	83 ec 18             	sub    $0x18,%esp
  800b01:	8b 45 10             	mov    0x10(%ebp),%eax
  // remember that write is always allowed to write *fewer*
  // bytes than requested.
  // LAB 5: Your code here
    int r;

    fsipcbuf.write.req_fileid = fd->fd_file.id;
  800b04:	8b 55 08             	mov    0x8(%ebp),%edx
  800b07:	8b 52 0c             	mov    0xc(%edx),%edx
  800b0a:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  800b10:	a3 04 50 80 00       	mov    %eax,0x805004

    size_t max_written = sizeof(fsipcbuf.write.req_buf);
    memmove(fsipcbuf.write.req_buf, buf, MIN(max_written, n));
  800b15:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800b1a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800b1f:	0f 47 c2             	cmova  %edx,%eax
  800b22:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b26:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b29:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b2d:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800b34:	e8 eb 0e 00 00       	call   801a24 <memmove>

    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800b39:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3e:	b8 04 00 00 00       	mov    $0x4,%eax
  800b43:	e8 a6 fe ff ff       	call   8009ee <fsipc>
        return r;

    return r;
}
  800b48:	c9                   	leave  
  800b49:	c3                   	ret    

00800b4a <devfile_read>:
// Returns:
//  The number of bytes successfully read.
//  < 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	53                   	push   %ebx
  800b4e:	83 ec 14             	sub    $0x14,%esp
  // filling fsipcbuf.read with the request arguments.  The
  // bytes read will be written back to fsipcbuf by the file
  // system server.
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b51:	8b 45 08             	mov    0x8(%ebp),%eax
  800b54:	8b 40 0c             	mov    0xc(%eax),%eax
  800b57:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  800b5c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b5f:	a3 04 50 80 00       	mov    %eax,0x805004
  if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b64:	ba 00 00 00 00       	mov    $0x0,%edx
  800b69:	b8 03 00 00 00       	mov    $0x3,%eax
  800b6e:	e8 7b fe ff ff       	call   8009ee <fsipc>
  800b73:	89 c3                	mov    %eax,%ebx
  800b75:	85 c0                	test   %eax,%eax
  800b77:	78 17                	js     800b90 <devfile_read+0x46>
    return r;

  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b79:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b7d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800b84:	00 
  800b85:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b88:	89 04 24             	mov    %eax,(%esp)
  800b8b:	e8 94 0e 00 00       	call   801a24 <memmove>
  return r;
}
  800b90:	89 d8                	mov    %ebx,%eax
  800b92:	83 c4 14             	add    $0x14,%esp
  800b95:	5b                   	pop    %ebx
  800b96:	5d                   	pop    %ebp
  800b97:	c3                   	ret    

00800b98 <open>:
//  The file descriptor index on success
//  -E_BAD_PATH if the path is too long (>= MAXPATHLEN)
//  < 0 for other errors.
int
open(const char *path, int mode)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	53                   	push   %ebx
  800b9c:	83 ec 24             	sub    $0x24,%esp
  800b9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  // file descriptor.

  int r;
  struct Fd *fd;

  if (strlen(path) >= MAXPATHLEN)
  800ba2:	89 1c 24             	mov    %ebx,(%esp)
  800ba5:	e8 a6 0c 00 00       	call   801850 <strlen>
  800baa:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800baf:	7f 60                	jg     800c11 <open+0x79>
    return -E_BAD_PATH;

  if ((r = fd_alloc(&fd)) < 0)
  800bb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bb4:	89 04 24             	mov    %eax,(%esp)
  800bb7:	e8 7b f8 ff ff       	call   800437 <fd_alloc>
  800bbc:	89 c2                	mov    %eax,%edx
  800bbe:	85 d2                	test   %edx,%edx
  800bc0:	78 54                	js     800c16 <open+0x7e>
    return r;

  strcpy(fsipcbuf.open.req_path, path);
  800bc2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bc6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800bcd:	e8 b5 0c 00 00       	call   801887 <strcpy>
  fsipcbuf.open.req_omode = mode;
  800bd2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd5:	a3 00 54 80 00       	mov    %eax,0x805400

  if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800bda:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bdd:	b8 01 00 00 00       	mov    $0x1,%eax
  800be2:	e8 07 fe ff ff       	call   8009ee <fsipc>
  800be7:	89 c3                	mov    %eax,%ebx
  800be9:	85 c0                	test   %eax,%eax
  800beb:	79 17                	jns    800c04 <open+0x6c>
    fd_close(fd, 0);
  800bed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800bf4:	00 
  800bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bf8:	89 04 24             	mov    %eax,(%esp)
  800bfb:	e8 31 f9 ff ff       	call   800531 <fd_close>
    return r;
  800c00:	89 d8                	mov    %ebx,%eax
  800c02:	eb 12                	jmp    800c16 <open+0x7e>
  }

  return fd2num(fd);
  800c04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c07:	89 04 24             	mov    %eax,(%esp)
  800c0a:	e8 01 f8 ff ff       	call   800410 <fd2num>
  800c0f:	eb 05                	jmp    800c16 <open+0x7e>

  int r;
  struct Fd *fd;

  if (strlen(path) >= MAXPATHLEN)
    return -E_BAD_PATH;
  800c11:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
    fd_close(fd, 0);
    return r;
  }

  return fd2num(fd);
}
  800c16:	83 c4 24             	add    $0x24,%esp
  800c19:	5b                   	pop    %ebx
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	83 ec 08             	sub    $0x8,%esp
  // Ask the file server to update the disk
  // by writing any dirty blocks in the buffer cache.

  return fsipc(FSREQ_SYNC, NULL);
  800c22:	ba 00 00 00 00       	mov    $0x0,%edx
  800c27:	b8 08 00 00 00       	mov    $0x8,%eax
  800c2c:	e8 bd fd ff ff       	call   8009ee <fsipc>
}
  800c31:	c9                   	leave  
  800c32:	c3                   	ret    

00800c33 <devpipe_stat>:
  return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	56                   	push   %esi
  800c37:	53                   	push   %ebx
  800c38:	83 ec 10             	sub    $0x10,%esp
  800c3b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct Pipe *p = (struct Pipe*)fd2data(fd);
  800c3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c41:	89 04 24             	mov    %eax,(%esp)
  800c44:	e8 d7 f7 ff ff       	call   800420 <fd2data>
  800c49:	89 c6                	mov    %eax,%esi

  strcpy(stat->st_name, "<pipe>");
  800c4b:	c7 44 24 04 a4 20 80 	movl   $0x8020a4,0x4(%esp)
  800c52:	00 
  800c53:	89 1c 24             	mov    %ebx,(%esp)
  800c56:	e8 2c 0c 00 00       	call   801887 <strcpy>
  stat->st_size = p->p_wpos - p->p_rpos;
  800c5b:	8b 46 04             	mov    0x4(%esi),%eax
  800c5e:	2b 06                	sub    (%esi),%eax
  800c60:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  stat->st_isdir = 0;
  800c66:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c6d:	00 00 00 
  stat->st_dev = &devpipe;
  800c70:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800c77:	30 80 00 
  return 0;
}
  800c7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c7f:	83 c4 10             	add    $0x10,%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	53                   	push   %ebx
  800c8a:	83 ec 14             	sub    $0x14,%esp
  800c8d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  (void)sys_page_unmap(0, fd);
  800c90:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c94:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c9b:	e8 aa f5 ff ff       	call   80024a <sys_page_unmap>
  return sys_page_unmap(0, fd2data(fd));
  800ca0:	89 1c 24             	mov    %ebx,(%esp)
  800ca3:	e8 78 f7 ff ff       	call   800420 <fd2data>
  800ca8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cb3:	e8 92 f5 ff ff       	call   80024a <sys_page_unmap>
}
  800cb8:	83 c4 14             	add    $0x14,%esp
  800cbb:	5b                   	pop    %ebx
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    

00800cbe <_pipeisclosed>:
  return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	57                   	push   %edi
  800cc2:	56                   	push   %esi
  800cc3:	53                   	push   %ebx
  800cc4:	83 ec 2c             	sub    $0x2c,%esp
  800cc7:	89 c6                	mov    %eax,%esi
  800cc9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  int n, nn, ret;

  while (1) {
    n = thisenv->env_runs;
  800ccc:	a1 04 40 80 00       	mov    0x804004,%eax
  800cd1:	8b 58 58             	mov    0x58(%eax),%ebx
    ret = pageref(fd) == pageref(p);
  800cd4:	89 34 24             	mov    %esi,(%esp)
  800cd7:	e8 23 10 00 00       	call   801cff <pageref>
  800cdc:	89 c7                	mov    %eax,%edi
  800cde:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ce1:	89 04 24             	mov    %eax,(%esp)
  800ce4:	e8 16 10 00 00       	call   801cff <pageref>
  800ce9:	39 c7                	cmp    %eax,%edi
  800ceb:	0f 94 c2             	sete   %dl
  800cee:	0f b6 c2             	movzbl %dl,%eax
    nn = thisenv->env_runs;
  800cf1:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  800cf7:	8b 79 58             	mov    0x58(%ecx),%edi
    if (n == nn)
  800cfa:	39 fb                	cmp    %edi,%ebx
  800cfc:	74 21                	je     800d1f <_pipeisclosed+0x61>
      return ret;
    if (n != nn && ret == 1)
  800cfe:	84 d2                	test   %dl,%dl
  800d00:	74 ca                	je     800ccc <_pipeisclosed+0xe>
      cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800d02:	8b 51 58             	mov    0x58(%ecx),%edx
  800d05:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d09:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d0d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d11:	c7 04 24 ab 20 80 00 	movl   $0x8020ab,(%esp)
  800d18:	e8 42 05 00 00       	call   80125f <cprintf>
  800d1d:	eb ad                	jmp    800ccc <_pipeisclosed+0xe>
  }
}
  800d1f:	83 c4 2c             	add    $0x2c,%esp
  800d22:	5b                   	pop    %ebx
  800d23:	5e                   	pop    %esi
  800d24:	5f                   	pop    %edi
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <devpipe_write>:
  return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	57                   	push   %edi
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
  800d2d:	83 ec 1c             	sub    $0x1c,%esp
  800d30:	8b 75 08             	mov    0x8(%ebp),%esi
  const uint8_t *buf;
  size_t i;
  struct Pipe *p;

  p = (struct Pipe*)fd2data(fd);
  800d33:	89 34 24             	mov    %esi,(%esp)
  800d36:	e8 e5 f6 ff ff       	call   800420 <fd2data>
  800d3b:	89 c3                	mov    %eax,%ebx
  if (debug)
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  800d3d:	bf 00 00 00 00       	mov    $0x0,%edi
  800d42:	eb 45                	jmp    800d89 <devpipe_write+0x62>
    while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
      // pipe is full
      // if all the readers are gone
      // (it's only writers like us now),
      // note eof
      if (_pipeisclosed(fd, p))
  800d44:	89 da                	mov    %ebx,%edx
  800d46:	89 f0                	mov    %esi,%eax
  800d48:	e8 71 ff ff ff       	call   800cbe <_pipeisclosed>
  800d4d:	85 c0                	test   %eax,%eax
  800d4f:	75 41                	jne    800d92 <devpipe_write+0x6b>
        return 0;
      // yield and see what happens
      if (debug)
        cprintf("devpipe_write yield\n");
      sys_yield();
  800d51:	e8 2e f4 ff ff       	call   800184 <sys_yield>
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
    while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800d56:	8b 43 04             	mov    0x4(%ebx),%eax
  800d59:	8b 0b                	mov    (%ebx),%ecx
  800d5b:	8d 51 20             	lea    0x20(%ecx),%edx
  800d5e:	39 d0                	cmp    %edx,%eax
  800d60:	73 e2                	jae    800d44 <devpipe_write+0x1d>
        cprintf("devpipe_write yield\n");
      sys_yield();
    }
    // there's room for a byte.  store it.
    // wait to increment wpos until the byte is stored!
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800d62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d65:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800d69:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800d6c:	99                   	cltd   
  800d6d:	c1 ea 1b             	shr    $0x1b,%edx
  800d70:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  800d73:	83 e1 1f             	and    $0x1f,%ecx
  800d76:	29 d1                	sub    %edx,%ecx
  800d78:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  800d7c:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
    p->p_wpos++;
  800d80:	83 c0 01             	add    $0x1,%eax
  800d83:	89 43 04             	mov    %eax,0x4(%ebx)
  if (debug)
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  800d86:	83 c7 01             	add    $0x1,%edi
  800d89:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800d8c:	75 c8                	jne    800d56 <devpipe_write+0x2f>
    // wait to increment wpos until the byte is stored!
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
    p->p_wpos++;
  }

  return i;
  800d8e:	89 f8                	mov    %edi,%eax
  800d90:	eb 05                	jmp    800d97 <devpipe_write+0x70>
      // pipe is full
      // if all the readers are gone
      // (it's only writers like us now),
      // note eof
      if (_pipeisclosed(fd, p))
        return 0;
  800d92:	b8 00 00 00 00       	mov    $0x0,%eax
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
    p->p_wpos++;
  }

  return i;
}
  800d97:	83 c4 1c             	add    $0x1c,%esp
  800d9a:	5b                   	pop    %ebx
  800d9b:	5e                   	pop    %esi
  800d9c:	5f                   	pop    %edi
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <devpipe_read>:
  return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	57                   	push   %edi
  800da3:	56                   	push   %esi
  800da4:	53                   	push   %ebx
  800da5:	83 ec 1c             	sub    $0x1c,%esp
  800da8:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint8_t *buf;
  size_t i;
  struct Pipe *p;

  p = (struct Pipe*)fd2data(fd);
  800dab:	89 3c 24             	mov    %edi,(%esp)
  800dae:	e8 6d f6 ff ff       	call   800420 <fd2data>
  800db3:	89 c3                	mov    %eax,%ebx
  if (debug)
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  800db5:	be 00 00 00 00       	mov    $0x0,%esi
  800dba:	eb 3d                	jmp    800df9 <devpipe_read+0x5a>
    while (p->p_rpos == p->p_wpos) {
      // pipe is empty
      // if we got any data, return it
      if (i > 0)
  800dbc:	85 f6                	test   %esi,%esi
  800dbe:	74 04                	je     800dc4 <devpipe_read+0x25>
        return i;
  800dc0:	89 f0                	mov    %esi,%eax
  800dc2:	eb 43                	jmp    800e07 <devpipe_read+0x68>
      // if all the writers are gone, note eof
      if (_pipeisclosed(fd, p))
  800dc4:	89 da                	mov    %ebx,%edx
  800dc6:	89 f8                	mov    %edi,%eax
  800dc8:	e8 f1 fe ff ff       	call   800cbe <_pipeisclosed>
  800dcd:	85 c0                	test   %eax,%eax
  800dcf:	75 31                	jne    800e02 <devpipe_read+0x63>
        return 0;
      // yield and see what happens
      if (debug)
        cprintf("devpipe_read yield\n");
      sys_yield();
  800dd1:	e8 ae f3 ff ff       	call   800184 <sys_yield>
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
    while (p->p_rpos == p->p_wpos) {
  800dd6:	8b 03                	mov    (%ebx),%eax
  800dd8:	3b 43 04             	cmp    0x4(%ebx),%eax
  800ddb:	74 df                	je     800dbc <devpipe_read+0x1d>
        cprintf("devpipe_read yield\n");
      sys_yield();
    }
    // there's a byte.  take it.
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800ddd:	99                   	cltd   
  800dde:	c1 ea 1b             	shr    $0x1b,%edx
  800de1:	01 d0                	add    %edx,%eax
  800de3:	83 e0 1f             	and    $0x1f,%eax
  800de6:	29 d0                	sub    %edx,%eax
  800de8:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800ded:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df0:	88 04 31             	mov    %al,(%ecx,%esi,1)
    p->p_rpos++;
  800df3:	83 03 01             	addl   $0x1,(%ebx)
  if (debug)
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  800df6:	83 c6 01             	add    $0x1,%esi
  800df9:	3b 75 10             	cmp    0x10(%ebp),%esi
  800dfc:	75 d8                	jne    800dd6 <devpipe_read+0x37>
    // there's a byte.  take it.
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
    p->p_rpos++;
  }
  return i;
  800dfe:	89 f0                	mov    %esi,%eax
  800e00:	eb 05                	jmp    800e07 <devpipe_read+0x68>
      // if we got any data, return it
      if (i > 0)
        return i;
      // if all the writers are gone, note eof
      if (_pipeisclosed(fd, p))
        return 0;
  800e02:	b8 00 00 00 00       	mov    $0x0,%eax
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
    p->p_rpos++;
  }
  return i;
}
  800e07:	83 c4 1c             	add    $0x1c,%esp
  800e0a:	5b                   	pop    %ebx
  800e0b:	5e                   	pop    %esi
  800e0c:	5f                   	pop    %edi
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <pipe>:
  uint8_t p_buf[PIPEBUFSIZ];    // data buffer
};

int
pipe(int pfd[2])
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
  800e14:	83 ec 30             	sub    $0x30,%esp
  int r;
  struct Fd *fd0, *fd1;
  void *va;

  // allocate the file descriptor table entries
  if ((r = fd_alloc(&fd0)) < 0
  800e17:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e1a:	89 04 24             	mov    %eax,(%esp)
  800e1d:	e8 15 f6 ff ff       	call   800437 <fd_alloc>
  800e22:	89 c2                	mov    %eax,%edx
  800e24:	85 d2                	test   %edx,%edx
  800e26:	0f 88 4d 01 00 00    	js     800f79 <pipe+0x16a>
      || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e2c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e33:	00 
  800e34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e37:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e3b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e42:	e8 5c f3 ff ff       	call   8001a3 <sys_page_alloc>
  800e47:	89 c2                	mov    %eax,%edx
  800e49:	85 d2                	test   %edx,%edx
  800e4b:	0f 88 28 01 00 00    	js     800f79 <pipe+0x16a>
    goto err;

  if ((r = fd_alloc(&fd1)) < 0
  800e51:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e54:	89 04 24             	mov    %eax,(%esp)
  800e57:	e8 db f5 ff ff       	call   800437 <fd_alloc>
  800e5c:	89 c3                	mov    %eax,%ebx
  800e5e:	85 c0                	test   %eax,%eax
  800e60:	0f 88 fe 00 00 00    	js     800f64 <pipe+0x155>
      || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e66:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e6d:	00 
  800e6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e71:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e75:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e7c:	e8 22 f3 ff ff       	call   8001a3 <sys_page_alloc>
  800e81:	89 c3                	mov    %eax,%ebx
  800e83:	85 c0                	test   %eax,%eax
  800e85:	0f 88 d9 00 00 00    	js     800f64 <pipe+0x155>
    goto err1;

  // allocate the pipe structure as first data page in both
  va = fd2data(fd0);
  800e8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e8e:	89 04 24             	mov    %eax,(%esp)
  800e91:	e8 8a f5 ff ff       	call   800420 <fd2data>
  800e96:	89 c6                	mov    %eax,%esi
  if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e98:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e9f:	00 
  800ea0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ea4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800eab:	e8 f3 f2 ff ff       	call   8001a3 <sys_page_alloc>
  800eb0:	89 c3                	mov    %eax,%ebx
  800eb2:	85 c0                	test   %eax,%eax
  800eb4:	0f 88 97 00 00 00    	js     800f51 <pipe+0x142>
    goto err2;
  if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800eba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ebd:	89 04 24             	mov    %eax,(%esp)
  800ec0:	e8 5b f5 ff ff       	call   800420 <fd2data>
  800ec5:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  800ecc:	00 
  800ecd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ed1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ed8:	00 
  800ed9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800edd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ee4:	e8 0e f3 ff ff       	call   8001f7 <sys_page_map>
  800ee9:	89 c3                	mov    %eax,%ebx
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	78 52                	js     800f41 <pipe+0x132>
    goto err3;

  // set up fd structures
  fd0->fd_dev_id = devpipe.dev_id;
  800eef:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ef8:	89 10                	mov    %edx,(%eax)
  fd0->fd_omode = O_RDONLY;
  800efa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800efd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

  fd1->fd_dev_id = devpipe.dev_id;
  800f04:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800f0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f0d:	89 10                	mov    %edx,(%eax)
  fd1->fd_omode = O_WRONLY;
  800f0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f12:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

  if (debug)
    cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

  pfd[0] = fd2num(fd0);
  800f19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f1c:	89 04 24             	mov    %eax,(%esp)
  800f1f:	e8 ec f4 ff ff       	call   800410 <fd2num>
  800f24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f27:	89 01                	mov    %eax,(%ecx)
  pfd[1] = fd2num(fd1);
  800f29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f2c:	89 04 24             	mov    %eax,(%esp)
  800f2f:	e8 dc f4 ff ff       	call   800410 <fd2num>
  800f34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f37:	89 41 04             	mov    %eax,0x4(%ecx)
  return 0;
  800f3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3f:	eb 38                	jmp    800f79 <pipe+0x16a>

err3:
  sys_page_unmap(0, va);
  800f41:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f45:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f4c:	e8 f9 f2 ff ff       	call   80024a <sys_page_unmap>
err2:
  sys_page_unmap(0, fd1);
  800f51:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f54:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f58:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f5f:	e8 e6 f2 ff ff       	call   80024a <sys_page_unmap>
err1:
  sys_page_unmap(0, fd0);
  800f64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f67:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f6b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f72:	e8 d3 f2 ff ff       	call   80024a <sys_page_unmap>
  800f77:	89 d8                	mov    %ebx,%eax
err:
  return r;
}
  800f79:	83 c4 30             	add    $0x30,%esp
  800f7c:	5b                   	pop    %ebx
  800f7d:	5e                   	pop    %esi
  800f7e:	5d                   	pop    %ebp
  800f7f:	c3                   	ret    

00800f80 <pipeisclosed>:
  }
}

int
pipeisclosed(int fdnum)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	83 ec 28             	sub    $0x28,%esp
  struct Fd *fd;
  struct Pipe *p;
  int r;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f89:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f90:	89 04 24             	mov    %eax,(%esp)
  800f93:	e8 ee f4 ff ff       	call   800486 <fd_lookup>
  800f98:	89 c2                	mov    %eax,%edx
  800f9a:	85 d2                	test   %edx,%edx
  800f9c:	78 15                	js     800fb3 <pipeisclosed+0x33>
    return r;
  p = (struct Pipe*)fd2data(fd);
  800f9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fa1:	89 04 24             	mov    %eax,(%esp)
  800fa4:	e8 77 f4 ff ff       	call   800420 <fd2data>
  return _pipeisclosed(fd, p);
  800fa9:	89 c2                	mov    %eax,%edx
  800fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fae:	e8 0b fd ff ff       	call   800cbe <_pipeisclosed>
}
  800fb3:	c9                   	leave  
  800fb4:	c3                   	ret    
  800fb5:	66 90                	xchg   %ax,%ax
  800fb7:	66 90                	xchg   %ax,%ax
  800fb9:	66 90                	xchg   %ax,%ax
  800fbb:	66 90                	xchg   %ax,%ax
  800fbd:	66 90                	xchg   %ax,%ax
  800fbf:	90                   	nop

00800fc0 <devcons_close>:
  return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  USED(fd);

  return 0;
}
  800fc3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	83 ec 18             	sub    $0x18,%esp
  strcpy(stat->st_name, "<cons>");
  800fd0:	c7 44 24 04 c3 20 80 	movl   $0x8020c3,0x4(%esp)
  800fd7:	00 
  800fd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fdb:	89 04 24             	mov    %eax,(%esp)
  800fde:	e8 a4 08 00 00       	call   801887 <strcpy>
  return 0;
}
  800fe3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe8:	c9                   	leave  
  800fe9:	c3                   	ret    

00800fea <devcons_write>:
  return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800fea:	55                   	push   %ebp
  800feb:	89 e5                	mov    %esp,%ebp
  800fed:	57                   	push   %edi
  800fee:	56                   	push   %esi
  800fef:	53                   	push   %ebx
  800ff0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  800ff6:	bb 00 00 00 00       	mov    $0x0,%ebx
    m = n - tot;
    if (m > sizeof(buf) - 1)
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
  800ffb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  801001:	eb 31                	jmp    801034 <devcons_write+0x4a>
    m = n - tot;
  801003:	8b 75 10             	mov    0x10(%ebp),%esi
  801006:	29 de                	sub    %ebx,%esi
    if (m > sizeof(buf) - 1)
  801008:	83 fe 7f             	cmp    $0x7f,%esi
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
    m = n - tot;
  80100b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801010:	0f 47 f2             	cmova  %edx,%esi
    if (m > sizeof(buf) - 1)
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
  801013:	89 74 24 08          	mov    %esi,0x8(%esp)
  801017:	03 45 0c             	add    0xc(%ebp),%eax
  80101a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80101e:	89 3c 24             	mov    %edi,(%esp)
  801021:	e8 fe 09 00 00       	call   801a24 <memmove>
    sys_cputs(buf, m);
  801026:	89 74 24 04          	mov    %esi,0x4(%esp)
  80102a:	89 3c 24             	mov    %edi,(%esp)
  80102d:	e8 a4 f0 ff ff       	call   8000d6 <sys_cputs>
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  801032:	01 f3                	add    %esi,%ebx
  801034:	89 d8                	mov    %ebx,%eax
  801036:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801039:	72 c8                	jb     801003 <devcons_write+0x19>
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
    sys_cputs(buf, m);
  }
  return tot;
}
  80103b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801041:	5b                   	pop    %ebx
  801042:	5e                   	pop    %esi
  801043:	5f                   	pop    %edi
  801044:	5d                   	pop    %ebp
  801045:	c3                   	ret    

00801046 <devcons_read>:
  return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801046:	55                   	push   %ebp
  801047:	89 e5                	mov    %esp,%ebp
  801049:	83 ec 08             	sub    $0x8,%esp
  int c;

  if (n == 0)
    return 0;
  80104c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  int c;

  if (n == 0)
  801051:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801055:	75 07                	jne    80105e <devcons_read+0x18>
  801057:	eb 2a                	jmp    801083 <devcons_read+0x3d>
    return 0;

  while ((c = sys_cgetc()) == 0)
    sys_yield();
  801059:	e8 26 f1 ff ff       	call   800184 <sys_yield>
  int c;

  if (n == 0)
    return 0;

  while ((c = sys_cgetc()) == 0)
  80105e:	66 90                	xchg   %ax,%ax
  801060:	e8 8f f0 ff ff       	call   8000f4 <sys_cgetc>
  801065:	85 c0                	test   %eax,%eax
  801067:	74 f0                	je     801059 <devcons_read+0x13>
    sys_yield();
  if (c < 0)
  801069:	85 c0                	test   %eax,%eax
  80106b:	78 16                	js     801083 <devcons_read+0x3d>
    return c;
  if (c == 0x04)        // ctl-d is eof
  80106d:	83 f8 04             	cmp    $0x4,%eax
  801070:	74 0c                	je     80107e <devcons_read+0x38>
    return 0;
  *(char*)vbuf = c;
  801072:	8b 55 0c             	mov    0xc(%ebp),%edx
  801075:	88 02                	mov    %al,(%edx)
  return 1;
  801077:	b8 01 00 00 00       	mov    $0x1,%eax
  80107c:	eb 05                	jmp    801083 <devcons_read+0x3d>
  while ((c = sys_cgetc()) == 0)
    sys_yield();
  if (c < 0)
    return c;
  if (c == 0x04)        // ctl-d is eof
    return 0;
  80107e:	b8 00 00 00 00       	mov    $0x0,%eax
  *(char*)vbuf = c;
  return 1;
}
  801083:	c9                   	leave  
  801084:	c3                   	ret    

00801085 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
  801088:	83 ec 28             	sub    $0x28,%esp
  char c = ch;
  80108b:	8b 45 08             	mov    0x8(%ebp),%eax
  80108e:	88 45 f7             	mov    %al,-0x9(%ebp)

  // Unlike standard Unix's putchar,
  // the cputchar function _always_ outputs to the system console.
  sys_cputs(&c, 1);
  801091:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801098:	00 
  801099:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80109c:	89 04 24             	mov    %eax,(%esp)
  80109f:	e8 32 f0 ff ff       	call   8000d6 <sys_cputs>
}
  8010a4:	c9                   	leave  
  8010a5:	c3                   	ret    

008010a6 <getchar>:

int
getchar(void)
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	83 ec 28             	sub    $0x28,%esp
  int r;

  // JOS does, however, support standard _input_ redirection,
  // allowing the user to redirect script files to the shell and such.
  // getchar() reads a character from file descriptor 0.
  r = read(0, &c, 1);
  8010ac:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8010b3:	00 
  8010b4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010c2:	e8 4e f6 ff ff       	call   800715 <read>
  if (r < 0)
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	78 0f                	js     8010da <getchar+0x34>
    return r;
  if (r < 1)
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	7e 06                	jle    8010d5 <getchar+0x2f>
    return -E_EOF;
  return c;
  8010cf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8010d3:	eb 05                	jmp    8010da <getchar+0x34>
  // getchar() reads a character from file descriptor 0.
  r = read(0, &c, 1);
  if (r < 0)
    return r;
  if (r < 1)
    return -E_EOF;
  8010d5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  /* int r;
  // sys_cgetc does not block, but getchar should.
  while ((r = sys_cgetc()) == 0)
    sys_yield();
  return r; */
}
  8010da:	c9                   	leave  
  8010db:	c3                   	ret    

008010dc <iscons>:
  .dev_stat   =     devcons_stat
};

int
iscons(int fdnum)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	83 ec 28             	sub    $0x28,%esp
  int r;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ec:	89 04 24             	mov    %eax,(%esp)
  8010ef:	e8 92 f3 ff ff       	call   800486 <fd_lookup>
  8010f4:	85 c0                	test   %eax,%eax
  8010f6:	78 11                	js     801109 <iscons+0x2d>
    return r;
  return fd->fd_dev_id == devcons.dev_id;
  8010f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010fb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801101:	39 10                	cmp    %edx,(%eax)
  801103:	0f 94 c0             	sete   %al
  801106:	0f b6 c0             	movzbl %al,%eax
}
  801109:	c9                   	leave  
  80110a:	c3                   	ret    

0080110b <opencons>:

int
opencons(void)
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	83 ec 28             	sub    $0x28,%esp
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
  801111:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801114:	89 04 24             	mov    %eax,(%esp)
  801117:	e8 1b f3 ff ff       	call   800437 <fd_alloc>
    return r;
  80111c:	89 c2                	mov    %eax,%edx
opencons(void)
{
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
  80111e:	85 c0                	test   %eax,%eax
  801120:	78 40                	js     801162 <opencons+0x57>
    return r;
  if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801122:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801129:	00 
  80112a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80112d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801131:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801138:	e8 66 f0 ff ff       	call   8001a3 <sys_page_alloc>
    return r;
  80113d:	89 c2                	mov    %eax,%edx
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
    return r;
  if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80113f:	85 c0                	test   %eax,%eax
  801141:	78 1f                	js     801162 <opencons+0x57>
    return r;
  fd->fd_dev_id = devcons.dev_id;
  801143:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801149:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80114c:	89 10                	mov    %edx,(%eax)
  fd->fd_omode = O_RDWR;
  80114e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801151:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
  return fd2num(fd);
  801158:	89 04 24             	mov    %eax,(%esp)
  80115b:	e8 b0 f2 ff ff       	call   800410 <fd2num>
  801160:	89 c2                	mov    %eax,%edx
}
  801162:	89 d0                	mov    %edx,%eax
  801164:	c9                   	leave  
  801165:	c3                   	ret    

00801166 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	56                   	push   %esi
  80116a:	53                   	push   %ebx
  80116b:	83 ec 20             	sub    $0x20,%esp
  va_list ap;

  va_start(ap, fmt);
  80116e:	8d 5d 14             	lea    0x14(%ebp),%ebx

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  801171:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801177:	e8 e9 ef ff ff       	call   800165 <sys_getenvid>
  80117c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80117f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801183:	8b 55 08             	mov    0x8(%ebp),%edx
  801186:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80118a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80118e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801192:	c7 04 24 d0 20 80 00 	movl   $0x8020d0,(%esp)
  801199:	e8 c1 00 00 00       	call   80125f <cprintf>
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  80119e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8011a5:	89 04 24             	mov    %eax,(%esp)
  8011a8:	e8 51 00 00 00       	call   8011fe <vcprintf>
  cprintf("\n");
  8011ad:	c7 04 24 bc 20 80 00 	movl   $0x8020bc,(%esp)
  8011b4:	e8 a6 00 00 00       	call   80125f <cprintf>

  // Cause a breakpoint exception
  while (1)
    asm volatile ("int3");
  8011b9:	cc                   	int3   
  8011ba:	eb fd                	jmp    8011b9 <_panic+0x53>

008011bc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8011bc:	55                   	push   %ebp
  8011bd:	89 e5                	mov    %esp,%ebp
  8011bf:	53                   	push   %ebx
  8011c0:	83 ec 14             	sub    $0x14,%esp
  8011c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  b->buf[b->idx++] = ch;
  8011c6:	8b 13                	mov    (%ebx),%edx
  8011c8:	8d 42 01             	lea    0x1(%edx),%eax
  8011cb:	89 03                	mov    %eax,(%ebx)
  8011cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
  if (b->idx == 256-1) {
  8011d4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8011d9:	75 19                	jne    8011f4 <putch+0x38>
    sys_cputs(b->buf, b->idx);
  8011db:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8011e2:	00 
  8011e3:	8d 43 08             	lea    0x8(%ebx),%eax
  8011e6:	89 04 24             	mov    %eax,(%esp)
  8011e9:	e8 e8 ee ff ff       	call   8000d6 <sys_cputs>
    b->idx = 0;
  8011ee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  }
  b->cnt++;
  8011f4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8011f8:	83 c4 14             	add    $0x14,%esp
  8011fb:	5b                   	pop    %ebx
  8011fc:	5d                   	pop    %ebp
  8011fd:	c3                   	ret    

008011fe <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
  801201:	81 ec 28 01 00 00    	sub    $0x128,%esp
  struct printbuf b;

  b.idx = 0;
  801207:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80120e:	00 00 00 
  b.cnt = 0;
  801211:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801218:	00 00 00 
  vprintfmt((void*)putch, &b, fmt, ap);
  80121b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80121e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801222:	8b 45 08             	mov    0x8(%ebp),%eax
  801225:	89 44 24 08          	mov    %eax,0x8(%esp)
  801229:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80122f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801233:	c7 04 24 bc 11 80 00 	movl   $0x8011bc,(%esp)
  80123a:	e8 af 01 00 00       	call   8013ee <vprintfmt>
  sys_cputs(b.buf, b.idx);
  80123f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801245:	89 44 24 04          	mov    %eax,0x4(%esp)
  801249:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80124f:	89 04 24             	mov    %eax,(%esp)
  801252:	e8 7f ee ff ff       	call   8000d6 <sys_cputs>

  return b.cnt;
}
  801257:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80125d:	c9                   	leave  
  80125e:	c3                   	ret    

0080125f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  801265:	8d 45 0c             	lea    0xc(%ebp),%eax
  cnt = vcprintf(fmt, ap);
  801268:	89 44 24 04          	mov    %eax,0x4(%esp)
  80126c:	8b 45 08             	mov    0x8(%ebp),%eax
  80126f:	89 04 24             	mov    %eax,(%esp)
  801272:	e8 87 ff ff ff       	call   8011fe <vcprintf>
  va_end(ap);

  return cnt;
}
  801277:	c9                   	leave  
  801278:	c3                   	ret    
  801279:	66 90                	xchg   %ax,%ax
  80127b:	66 90                	xchg   %ax,%ax
  80127d:	66 90                	xchg   %ax,%ax
  80127f:	90                   	nop

00801280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
         unsigned long long num, unsigned base, int width, int padc)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
  801283:	57                   	push   %edi
  801284:	56                   	push   %esi
  801285:	53                   	push   %ebx
  801286:	83 ec 3c             	sub    $0x3c,%esp
  801289:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80128c:	89 d7                	mov    %edx,%edi
  80128e:	8b 45 08             	mov    0x8(%ebp),%eax
  801291:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801294:	8b 45 0c             	mov    0xc(%ebp),%eax
  801297:	89 c3                	mov    %eax,%ebx
  801299:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80129c:	8b 45 10             	mov    0x10(%ebp),%eax
  80129f:	8b 75 14             	mov    0x14(%ebp),%esi
  // first recursively print all preceding (more significant) digits
  if (num >= base)
  8012a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8012aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8012ad:	39 d9                	cmp    %ebx,%ecx
  8012af:	72 05                	jb     8012b6 <printnum+0x36>
  8012b1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8012b4:	77 69                	ja     80131f <printnum+0x9f>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8012b6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8012b9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8012bd:	83 ee 01             	sub    $0x1,%esi
  8012c0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012c8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012cc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8012d0:	89 c3                	mov    %eax,%ebx
  8012d2:	89 d6                	mov    %edx,%esi
  8012d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8012d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8012da:	89 54 24 08          	mov    %edx,0x8(%esp)
  8012de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8012e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012e5:	89 04 24             	mov    %eax,(%esp)
  8012e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8012eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ef:	e8 4c 0a 00 00       	call   801d40 <__udivdi3>
  8012f4:	89 d9                	mov    %ebx,%ecx
  8012f6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012fa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012fe:	89 04 24             	mov    %eax,(%esp)
  801301:	89 54 24 04          	mov    %edx,0x4(%esp)
  801305:	89 fa                	mov    %edi,%edx
  801307:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80130a:	e8 71 ff ff ff       	call   801280 <printnum>
  80130f:	eb 1b                	jmp    80132c <printnum+0xac>
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
      putch(padc, putdat);
  801311:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801315:	8b 45 18             	mov    0x18(%ebp),%eax
  801318:	89 04 24             	mov    %eax,(%esp)
  80131b:	ff d3                	call   *%ebx
  80131d:	eb 03                	jmp    801322 <printnum+0xa2>
  80131f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  // first recursively print all preceding (more significant) digits
  if (num >= base)
    printnum(putch, putdat, num / base, base, width - 1, padc);
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
  801322:	83 ee 01             	sub    $0x1,%esi
  801325:	85 f6                	test   %esi,%esi
  801327:	7f e8                	jg     801311 <printnum+0x91>
  801329:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
      putch(padc, putdat);
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  80132c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801330:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801334:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801337:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80133a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80133e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801342:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801345:	89 04 24             	mov    %eax,(%esp)
  801348:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80134b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80134f:	e8 1c 0b 00 00       	call   801e70 <__umoddi3>
  801354:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801358:	0f be 80 f3 20 80 00 	movsbl 0x8020f3(%eax),%eax
  80135f:	89 04 24             	mov    %eax,(%esp)
  801362:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801365:	ff d0                	call   *%eax
}
  801367:	83 c4 3c             	add    $0x3c,%esp
  80136a:	5b                   	pop    %ebx
  80136b:	5e                   	pop    %esi
  80136c:	5f                   	pop    %edi
  80136d:	5d                   	pop    %ebp
  80136e:	c3                   	ret    

0080136f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80136f:	55                   	push   %ebp
  801370:	89 e5                	mov    %esp,%ebp
  if (lflag >= 2)
  801372:	83 fa 01             	cmp    $0x1,%edx
  801375:	7e 0e                	jle    801385 <getuint+0x16>
    return va_arg(*ap, unsigned long long);
  801377:	8b 10                	mov    (%eax),%edx
  801379:	8d 4a 08             	lea    0x8(%edx),%ecx
  80137c:	89 08                	mov    %ecx,(%eax)
  80137e:	8b 02                	mov    (%edx),%eax
  801380:	8b 52 04             	mov    0x4(%edx),%edx
  801383:	eb 22                	jmp    8013a7 <getuint+0x38>
  else if (lflag)
  801385:	85 d2                	test   %edx,%edx
  801387:	74 10                	je     801399 <getuint+0x2a>
    return va_arg(*ap, unsigned long);
  801389:	8b 10                	mov    (%eax),%edx
  80138b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80138e:	89 08                	mov    %ecx,(%eax)
  801390:	8b 02                	mov    (%edx),%eax
  801392:	ba 00 00 00 00       	mov    $0x0,%edx
  801397:	eb 0e                	jmp    8013a7 <getuint+0x38>
  else
    return va_arg(*ap, unsigned int);
  801399:	8b 10                	mov    (%eax),%edx
  80139b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80139e:	89 08                	mov    %ecx,(%eax)
  8013a0:	8b 02                	mov    (%edx),%eax
  8013a2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8013a7:	5d                   	pop    %ebp
  8013a8:	c3                   	ret    

008013a9 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8013a9:	55                   	push   %ebp
  8013aa:	89 e5                	mov    %esp,%ebp
  8013ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  b->cnt++;
  8013af:	83 40 08 01          	addl   $0x1,0x8(%eax)
  if (b->buf < b->ebuf)
  8013b3:	8b 10                	mov    (%eax),%edx
  8013b5:	3b 50 04             	cmp    0x4(%eax),%edx
  8013b8:	73 0a                	jae    8013c4 <sprintputch+0x1b>
    *b->buf++ = ch;
  8013ba:	8d 4a 01             	lea    0x1(%edx),%ecx
  8013bd:	89 08                	mov    %ecx,(%eax)
  8013bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c2:	88 02                	mov    %al,(%edx)
}
  8013c4:	5d                   	pop    %ebp
  8013c5:	c3                   	ret    

008013c6 <printfmt>:
  }
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8013c6:	55                   	push   %ebp
  8013c7:	89 e5                	mov    %esp,%ebp
  8013c9:	83 ec 18             	sub    $0x18,%esp
  va_list ap;

  va_start(ap, fmt);
  8013cc:	8d 45 14             	lea    0x14(%ebp),%eax
  vprintfmt(putch, putdat, fmt, ap);
  8013cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8013d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e4:	89 04 24             	mov    %eax,(%esp)
  8013e7:	e8 02 00 00 00       	call   8013ee <vprintfmt>
  va_end(ap);
}
  8013ec:	c9                   	leave  
  8013ed:	c3                   	ret    

008013ee <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8013ee:	55                   	push   %ebp
  8013ef:	89 e5                	mov    %esp,%ebp
  8013f1:	57                   	push   %edi
  8013f2:	56                   	push   %esi
  8013f3:	53                   	push   %ebx
  8013f4:	83 ec 3c             	sub    $0x3c,%esp
  8013f7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8013fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013fd:	eb 14                	jmp    801413 <vprintfmt+0x25>
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
      if (ch == '\0')
  8013ff:	85 c0                	test   %eax,%eax
  801401:	0f 84 b3 03 00 00    	je     8017ba <vprintfmt+0x3cc>
        return;
      putch(ch, putdat);
  801407:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80140b:	89 04 24             	mov    %eax,(%esp)
  80140e:	ff 55 08             	call   *0x8(%ebp)
  unsigned long long num;
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
  801411:	89 f3                	mov    %esi,%ebx
  801413:	8d 73 01             	lea    0x1(%ebx),%esi
  801416:	0f b6 03             	movzbl (%ebx),%eax
  801419:	83 f8 25             	cmp    $0x25,%eax
  80141c:	75 e1                	jne    8013ff <vprintfmt+0x11>
  80141e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  801422:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801429:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801430:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  801437:	ba 00 00 00 00       	mov    $0x0,%edx
  80143c:	eb 1d                	jmp    80145b <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80143e:	89 de                	mov    %ebx,%esi

    // flag to pad on the right
    case '-':
      padc = '-';
  801440:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  801444:	eb 15                	jmp    80145b <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  801446:	89 de                	mov    %ebx,%esi
      padc = '-';
      goto reswitch;

    // flag to pad with 0's instead of spaces
    case '0':
      padc = '0';
  801448:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80144c:	eb 0d                	jmp    80145b <vprintfmt+0x6d>
      altflag = 1;
      goto reswitch;

process_precision:
      if (width < 0)
        width = precision, precision = -1;
  80144e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801451:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801454:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80145b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80145e:	0f b6 0e             	movzbl (%esi),%ecx
  801461:	0f b6 c1             	movzbl %cl,%eax
  801464:	83 e9 23             	sub    $0x23,%ecx
  801467:	80 f9 55             	cmp    $0x55,%cl
  80146a:	0f 87 2a 03 00 00    	ja     80179a <vprintfmt+0x3ac>
  801470:	0f b6 c9             	movzbl %cl,%ecx
  801473:	ff 24 8d 40 22 80 00 	jmp    *0x802240(,%ecx,4)
  80147a:	89 de                	mov    %ebx,%esi
  80147c:	b9 00 00 00 00       	mov    $0x0,%ecx
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
        precision = precision * 10 + ch - '0';
  801481:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  801484:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
        ch = *fmt;
  801488:	0f be 06             	movsbl (%esi),%eax
        if (ch < '0' || ch > '9')
  80148b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80148e:	83 fb 09             	cmp    $0x9,%ebx
  801491:	77 36                	ja     8014c9 <vprintfmt+0xdb>
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
  801493:	83 c6 01             	add    $0x1,%esi
        precision = precision * 10 + ch - '0';
        ch = *fmt;
        if (ch < '0' || ch > '9')
          break;
      }
  801496:	eb e9                	jmp    801481 <vprintfmt+0x93>
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
  801498:	8b 45 14             	mov    0x14(%ebp),%eax
  80149b:	8d 48 04             	lea    0x4(%eax),%ecx
  80149e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8014a1:	8b 00                	mov    (%eax),%eax
  8014a3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8014a6:	89 de                	mov    %ebx,%esi
      }
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
      goto process_precision;
  8014a8:	eb 22                	jmp    8014cc <vprintfmt+0xde>
  8014aa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8014ad:	85 c9                	test   %ecx,%ecx
  8014af:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b4:	0f 49 c1             	cmovns %ecx,%eax
  8014b7:	89 45 dc             	mov    %eax,-0x24(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8014ba:	89 de                	mov    %ebx,%esi
  8014bc:	eb 9d                	jmp    80145b <vprintfmt+0x6d>
  8014be:	89 de                	mov    %ebx,%esi
      if (width < 0)
        width = 0;
      goto reswitch;

    case '#':
      altflag = 1;
  8014c0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
      goto reswitch;
  8014c7:	eb 92                	jmp    80145b <vprintfmt+0x6d>
  8014c9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

process_precision:
      if (width < 0)
  8014cc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8014d0:	79 89                	jns    80145b <vprintfmt+0x6d>
  8014d2:	e9 77 ff ff ff       	jmp    80144e <vprintfmt+0x60>
        width = precision, precision = -1;
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
  8014d7:	83 c2 01             	add    $0x1,%edx
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8014da:	89 de                	mov    %ebx,%esi
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
      goto reswitch;
  8014dc:	e9 7a ff ff ff       	jmp    80145b <vprintfmt+0x6d>

    // character
    case 'c':
      putch(va_arg(ap, int), putdat);
  8014e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e4:	8d 50 04             	lea    0x4(%eax),%edx
  8014e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8014ea:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014ee:	8b 00                	mov    (%eax),%eax
  8014f0:	89 04 24             	mov    %eax,(%esp)
  8014f3:	ff 55 08             	call   *0x8(%ebp)
      break;
  8014f6:	e9 18 ff ff ff       	jmp    801413 <vprintfmt+0x25>

    // error message
    case 'e':
      err = va_arg(ap, int);
  8014fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8014fe:	8d 50 04             	lea    0x4(%eax),%edx
  801501:	89 55 14             	mov    %edx,0x14(%ebp)
  801504:	8b 00                	mov    (%eax),%eax
  801506:	99                   	cltd   
  801507:	31 d0                	xor    %edx,%eax
  801509:	29 d0                	sub    %edx,%eax
      if (err < 0)
        err = -err;
      if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80150b:	83 f8 0f             	cmp    $0xf,%eax
  80150e:	7f 0b                	jg     80151b <vprintfmt+0x12d>
  801510:	8b 14 85 a0 23 80 00 	mov    0x8023a0(,%eax,4),%edx
  801517:	85 d2                	test   %edx,%edx
  801519:	75 20                	jne    80153b <vprintfmt+0x14d>
        printfmt(putch, putdat, "error %d", err);
  80151b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80151f:	c7 44 24 08 0b 21 80 	movl   $0x80210b,0x8(%esp)
  801526:	00 
  801527:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80152b:	8b 45 08             	mov    0x8(%ebp),%eax
  80152e:	89 04 24             	mov    %eax,(%esp)
  801531:	e8 90 fe ff ff       	call   8013c6 <printfmt>
  801536:	e9 d8 fe ff ff       	jmp    801413 <vprintfmt+0x25>
      else
        printfmt(putch, putdat, "%s", p);
  80153b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80153f:	c7 44 24 08 14 21 80 	movl   $0x802114,0x8(%esp)
  801546:	00 
  801547:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80154b:	8b 45 08             	mov    0x8(%ebp),%eax
  80154e:	89 04 24             	mov    %eax,(%esp)
  801551:	e8 70 fe ff ff       	call   8013c6 <printfmt>
  801556:	e9 b8 fe ff ff       	jmp    801413 <vprintfmt+0x25>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80155b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80155e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801561:	89 45 d0             	mov    %eax,-0x30(%ebp)
        printfmt(putch, putdat, "%s", p);
      break;

    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
  801564:	8b 45 14             	mov    0x14(%ebp),%eax
  801567:	8d 50 04             	lea    0x4(%eax),%edx
  80156a:	89 55 14             	mov    %edx,0x14(%ebp)
  80156d:	8b 30                	mov    (%eax),%esi
        p = "(null)";
  80156f:	85 f6                	test   %esi,%esi
  801571:	b8 04 21 80 00       	mov    $0x802104,%eax
  801576:	0f 44 f0             	cmove  %eax,%esi
      if (width > 0 && padc != '-')
  801579:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80157d:	0f 84 97 00 00 00    	je     80161a <vprintfmt+0x22c>
  801583:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  801587:	0f 8e 9b 00 00 00    	jle    801628 <vprintfmt+0x23a>
        for (width -= strnlen(p, precision); width > 0; width--)
  80158d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801591:	89 34 24             	mov    %esi,(%esp)
  801594:	e8 cf 02 00 00       	call   801868 <strnlen>
  801599:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80159c:	29 c2                	sub    %eax,%edx
  80159e:	89 55 d0             	mov    %edx,-0x30(%ebp)
          putch(padc, putdat);
  8015a1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8015a5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8015a8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8015ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8015ae:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8015b1:	89 d3                	mov    %edx,%ebx
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
  8015b3:	eb 0f                	jmp    8015c4 <vprintfmt+0x1d6>
          putch(padc, putdat);
  8015b5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8015b9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8015bc:	89 04 24             	mov    %eax,(%esp)
  8015bf:	ff d6                	call   *%esi
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
  8015c1:	83 eb 01             	sub    $0x1,%ebx
  8015c4:	85 db                	test   %ebx,%ebx
  8015c6:	7f ed                	jg     8015b5 <vprintfmt+0x1c7>
  8015c8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8015cb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8015ce:	85 d2                	test   %edx,%edx
  8015d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8015d5:	0f 49 c2             	cmovns %edx,%eax
  8015d8:	29 c2                	sub    %eax,%edx
  8015da:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8015dd:	89 d7                	mov    %edx,%edi
  8015df:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8015e2:	eb 50                	jmp    801634 <vprintfmt+0x246>
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
  8015e4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8015e8:	74 1e                	je     801608 <vprintfmt+0x21a>
  8015ea:	0f be d2             	movsbl %dl,%edx
  8015ed:	83 ea 20             	sub    $0x20,%edx
  8015f0:	83 fa 5e             	cmp    $0x5e,%edx
  8015f3:	76 13                	jbe    801608 <vprintfmt+0x21a>
          putch('?', putdat);
  8015f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015fc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801603:	ff 55 08             	call   *0x8(%ebp)
  801606:	eb 0d                	jmp    801615 <vprintfmt+0x227>
        else
          putch(ch, putdat);
  801608:	8b 55 0c             	mov    0xc(%ebp),%edx
  80160b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80160f:	89 04 24             	mov    %eax,(%esp)
  801612:	ff 55 08             	call   *0x8(%ebp)
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801615:	83 ef 01             	sub    $0x1,%edi
  801618:	eb 1a                	jmp    801634 <vprintfmt+0x246>
  80161a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80161d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801620:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801623:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801626:	eb 0c                	jmp    801634 <vprintfmt+0x246>
  801628:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80162b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80162e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801631:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801634:	83 c6 01             	add    $0x1,%esi
  801637:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80163b:	0f be c2             	movsbl %dl,%eax
  80163e:	85 c0                	test   %eax,%eax
  801640:	74 27                	je     801669 <vprintfmt+0x27b>
  801642:	85 db                	test   %ebx,%ebx
  801644:	78 9e                	js     8015e4 <vprintfmt+0x1f6>
  801646:	83 eb 01             	sub    $0x1,%ebx
  801649:	79 99                	jns    8015e4 <vprintfmt+0x1f6>
  80164b:	89 f8                	mov    %edi,%eax
  80164d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801650:	8b 75 08             	mov    0x8(%ebp),%esi
  801653:	89 c3                	mov    %eax,%ebx
  801655:	eb 1a                	jmp    801671 <vprintfmt+0x283>
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
        putch(' ', putdat);
  801657:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80165b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801662:	ff d6                	call   *%esi
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
  801664:	83 eb 01             	sub    $0x1,%ebx
  801667:	eb 08                	jmp    801671 <vprintfmt+0x283>
  801669:	89 fb                	mov    %edi,%ebx
  80166b:	8b 75 08             	mov    0x8(%ebp),%esi
  80166e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801671:	85 db                	test   %ebx,%ebx
  801673:	7f e2                	jg     801657 <vprintfmt+0x269>
  801675:	89 75 08             	mov    %esi,0x8(%ebp)
  801678:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80167b:	e9 93 fd ff ff       	jmp    801413 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  if (lflag >= 2)
  801680:	83 fa 01             	cmp    $0x1,%edx
  801683:	7e 16                	jle    80169b <vprintfmt+0x2ad>
    return va_arg(*ap, long long);
  801685:	8b 45 14             	mov    0x14(%ebp),%eax
  801688:	8d 50 08             	lea    0x8(%eax),%edx
  80168b:	89 55 14             	mov    %edx,0x14(%ebp)
  80168e:	8b 50 04             	mov    0x4(%eax),%edx
  801691:	8b 00                	mov    (%eax),%eax
  801693:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801696:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801699:	eb 32                	jmp    8016cd <vprintfmt+0x2df>
  else if (lflag)
  80169b:	85 d2                	test   %edx,%edx
  80169d:	74 18                	je     8016b7 <vprintfmt+0x2c9>
    return va_arg(*ap, long);
  80169f:	8b 45 14             	mov    0x14(%ebp),%eax
  8016a2:	8d 50 04             	lea    0x4(%eax),%edx
  8016a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8016a8:	8b 30                	mov    (%eax),%esi
  8016aa:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8016ad:	89 f0                	mov    %esi,%eax
  8016af:	c1 f8 1f             	sar    $0x1f,%eax
  8016b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016b5:	eb 16                	jmp    8016cd <vprintfmt+0x2df>
  else
    return va_arg(*ap, int);
  8016b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8016ba:	8d 50 04             	lea    0x4(%eax),%edx
  8016bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8016c0:	8b 30                	mov    (%eax),%esi
  8016c2:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8016c5:	89 f0                	mov    %esi,%eax
  8016c7:	c1 f8 1f             	sar    $0x1f,%eax
  8016ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        putch(' ', putdat);
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
  8016cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      if ((long long)num < 0) {
        putch('-', putdat);
        num = -(long long)num;
      }
      base = 10;
  8016d3:	b9 0a 00 00 00       	mov    $0xa,%ecx
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
      if ((long long)num < 0) {
  8016d8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8016dc:	0f 89 80 00 00 00    	jns    801762 <vprintfmt+0x374>
        putch('-', putdat);
  8016e2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8016e6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8016ed:	ff 55 08             	call   *0x8(%ebp)
        num = -(long long)num;
  8016f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016f3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016f6:	f7 d8                	neg    %eax
  8016f8:	83 d2 00             	adc    $0x0,%edx
  8016fb:	f7 da                	neg    %edx
      }
      base = 10;
  8016fd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801702:	eb 5e                	jmp    801762 <vprintfmt+0x374>
      goto number;

    // unsigned decimal
    case 'u':
      num = getuint(&ap, lflag);
  801704:	8d 45 14             	lea    0x14(%ebp),%eax
  801707:	e8 63 fc ff ff       	call   80136f <getuint>
      base = 10;
  80170c:	b9 0a 00 00 00       	mov    $0xa,%ecx
      goto number;
  801711:	eb 4f                	jmp    801762 <vprintfmt+0x374>

    // (unsigned) octal
    case 'o':
      num = getuint(&ap, lflag);
  801713:	8d 45 14             	lea    0x14(%ebp),%eax
  801716:	e8 54 fc ff ff       	call   80136f <getuint>
      base = 8;
  80171b:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  801720:	eb 40                	jmp    801762 <vprintfmt+0x374>

    // pointer
    case 'p':
      putch('0', putdat);
  801722:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801726:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80172d:	ff 55 08             	call   *0x8(%ebp)
      putch('x', putdat);
  801730:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801734:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80173b:	ff 55 08             	call   *0x8(%ebp)
      num = (unsigned long long)
            (uintptr_t)va_arg(ap, void *);
  80173e:	8b 45 14             	mov    0x14(%ebp),%eax
  801741:	8d 50 04             	lea    0x4(%eax),%edx
  801744:	89 55 14             	mov    %edx,0x14(%ebp)

    // pointer
    case 'p':
      putch('0', putdat);
      putch('x', putdat);
      num = (unsigned long long)
  801747:	8b 00                	mov    (%eax),%eax
  801749:	ba 00 00 00 00       	mov    $0x0,%edx
            (uintptr_t)va_arg(ap, void *);
      base = 16;
  80174e:	b9 10 00 00 00       	mov    $0x10,%ecx
      goto number;
  801753:	eb 0d                	jmp    801762 <vprintfmt+0x374>

    // (unsigned) hexadecimal
    case 'x':
      num = getuint(&ap, lflag);
  801755:	8d 45 14             	lea    0x14(%ebp),%eax
  801758:	e8 12 fc ff ff       	call   80136f <getuint>
      base = 16;
  80175d:	b9 10 00 00 00       	mov    $0x10,%ecx
number:
      printnum(putch, putdat, num, base, width, padc);
  801762:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  801766:	89 74 24 10          	mov    %esi,0x10(%esp)
  80176a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80176d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801771:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801775:	89 04 24             	mov    %eax,(%esp)
  801778:	89 54 24 04          	mov    %edx,0x4(%esp)
  80177c:	89 fa                	mov    %edi,%edx
  80177e:	8b 45 08             	mov    0x8(%ebp),%eax
  801781:	e8 fa fa ff ff       	call   801280 <printnum>
      break;
  801786:	e9 88 fc ff ff       	jmp    801413 <vprintfmt+0x25>

    // escaped '%' character
    case '%':
      putch(ch, putdat);
  80178b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80178f:	89 04 24             	mov    %eax,(%esp)
  801792:	ff 55 08             	call   *0x8(%ebp)
      break;
  801795:	e9 79 fc ff ff       	jmp    801413 <vprintfmt+0x25>

    // unrecognized escape sequence - just print it literally
    default:
      putch('%', putdat);
  80179a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80179e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8017a5:	ff 55 08             	call   *0x8(%ebp)
      for (fmt--; fmt[-1] != '%'; fmt--)
  8017a8:	89 f3                	mov    %esi,%ebx
  8017aa:	eb 03                	jmp    8017af <vprintfmt+0x3c1>
  8017ac:	83 eb 01             	sub    $0x1,%ebx
  8017af:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8017b3:	75 f7                	jne    8017ac <vprintfmt+0x3be>
  8017b5:	e9 59 fc ff ff       	jmp    801413 <vprintfmt+0x25>
        /* do nothing */;
      break;
    }
  }
}
  8017ba:	83 c4 3c             	add    $0x3c,%esp
  8017bd:	5b                   	pop    %ebx
  8017be:	5e                   	pop    %esi
  8017bf:	5f                   	pop    %edi
  8017c0:	5d                   	pop    %ebp
  8017c1:	c3                   	ret    

008017c2 <vsnprintf>:
    *b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8017c2:	55                   	push   %ebp
  8017c3:	89 e5                	mov    %esp,%ebp
  8017c5:	83 ec 28             	sub    $0x28,%esp
  8017c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  struct sprintbuf b = { buf, buf+n-1, 0 };
  8017ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8017d1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8017d5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8017d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  if (buf == NULL || n < 1)
  8017df:	85 c0                	test   %eax,%eax
  8017e1:	74 30                	je     801813 <vsnprintf+0x51>
  8017e3:	85 d2                	test   %edx,%edx
  8017e5:	7e 2c                	jle    801813 <vsnprintf+0x51>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void*)sprintputch, &b, fmt, ap);
  8017e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8017ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8017f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017f5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8017f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017fc:	c7 04 24 a9 13 80 00 	movl   $0x8013a9,(%esp)
  801803:	e8 e6 fb ff ff       	call   8013ee <vprintfmt>

  // null terminate the buffer
  *b.buf = '\0';
  801808:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80180b:	c6 00 00             	movb   $0x0,(%eax)

  return b.cnt;
  80180e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801811:	eb 05                	jmp    801818 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  struct sprintbuf b = { buf, buf+n-1, 0 };

  if (buf == NULL || n < 1)
    return -E_INVAL;
  801813:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

  // null terminate the buffer
  *b.buf = '\0';

  return b.cnt;
}
  801818:	c9                   	leave  
  801819:	c3                   	ret    

0080181a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int rc;

  va_start(ap, fmt);
  801820:	8d 45 14             	lea    0x14(%ebp),%eax
  rc = vsnprintf(buf, n, fmt, ap);
  801823:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801827:	8b 45 10             	mov    0x10(%ebp),%eax
  80182a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80182e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801831:	89 44 24 04          	mov    %eax,0x4(%esp)
  801835:	8b 45 08             	mov    0x8(%ebp),%eax
  801838:	89 04 24             	mov    %eax,(%esp)
  80183b:	e8 82 ff ff ff       	call   8017c2 <vsnprintf>
  va_end(ap);

  return rc;
}
  801840:	c9                   	leave  
  801841:	c3                   	ret    
  801842:	66 90                	xchg   %ax,%ax
  801844:	66 90                	xchg   %ax,%ax
  801846:	66 90                	xchg   %ax,%ax
  801848:	66 90                	xchg   %ax,%ax
  80184a:	66 90                	xchg   %ax,%ax
  80184c:	66 90                	xchg   %ax,%ax
  80184e:	66 90                	xchg   %ax,%ax

00801850 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for (n = 0; *s != '\0'; s++)
  801856:	b8 00 00 00 00       	mov    $0x0,%eax
  80185b:	eb 03                	jmp    801860 <strlen+0x10>
    n++;
  80185d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
  int n;

  for (n = 0; *s != '\0'; s++)
  801860:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801864:	75 f7                	jne    80185d <strlen+0xd>
    n++;
  return n;
}
  801866:	5d                   	pop    %ebp
  801867:	c3                   	ret    

00801868 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80186e:	8b 55 0c             	mov    0xc(%ebp),%edx
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801871:	b8 00 00 00 00       	mov    $0x0,%eax
  801876:	eb 03                	jmp    80187b <strnlen+0x13>
    n++;
  801878:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80187b:	39 d0                	cmp    %edx,%eax
  80187d:	74 06                	je     801885 <strnlen+0x1d>
  80187f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801883:	75 f3                	jne    801878 <strnlen+0x10>
    n++;
  return n;
}
  801885:	5d                   	pop    %ebp
  801886:	c3                   	ret    

00801887 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801887:	55                   	push   %ebp
  801888:	89 e5                	mov    %esp,%ebp
  80188a:	53                   	push   %ebx
  80188b:	8b 45 08             	mov    0x8(%ebp),%eax
  80188e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  801891:	89 c2                	mov    %eax,%edx
  801893:	83 c2 01             	add    $0x1,%edx
  801896:	83 c1 01             	add    $0x1,%ecx
  801899:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80189d:	88 5a ff             	mov    %bl,-0x1(%edx)
  8018a0:	84 db                	test   %bl,%bl
  8018a2:	75 ef                	jne    801893 <strcpy+0xc>
    /* do nothing */;
  return ret;
}
  8018a4:	5b                   	pop    %ebx
  8018a5:	5d                   	pop    %ebp
  8018a6:	c3                   	ret    

008018a7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	53                   	push   %ebx
  8018ab:	83 ec 08             	sub    $0x8,%esp
  8018ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int len = strlen(dst);
  8018b1:	89 1c 24             	mov    %ebx,(%esp)
  8018b4:	e8 97 ff ff ff       	call   801850 <strlen>

  strcpy(dst + len, src);
  8018b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018bc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018c0:	01 d8                	add    %ebx,%eax
  8018c2:	89 04 24             	mov    %eax,(%esp)
  8018c5:	e8 bd ff ff ff       	call   801887 <strcpy>
  return dst;
}
  8018ca:	89 d8                	mov    %ebx,%eax
  8018cc:	83 c4 08             	add    $0x8,%esp
  8018cf:	5b                   	pop    %ebx
  8018d0:	5d                   	pop    %ebp
  8018d1:	c3                   	ret    

008018d2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  8018d2:	55                   	push   %ebp
  8018d3:	89 e5                	mov    %esp,%ebp
  8018d5:	56                   	push   %esi
  8018d6:	53                   	push   %ebx
  8018d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8018da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018dd:	89 f3                	mov    %esi,%ebx
  8018df:	03 5d 10             	add    0x10(%ebp),%ebx
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  8018e2:	89 f2                	mov    %esi,%edx
  8018e4:	eb 0f                	jmp    8018f5 <strncpy+0x23>
    *dst++ = *src;
  8018e6:	83 c2 01             	add    $0x1,%edx
  8018e9:	0f b6 01             	movzbl (%ecx),%eax
  8018ec:	88 42 ff             	mov    %al,-0x1(%edx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  8018ef:	80 39 01             	cmpb   $0x1,(%ecx)
  8018f2:	83 d9 ff             	sbb    $0xffffffff,%ecx
{
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  8018f5:	39 da                	cmp    %ebx,%edx
  8018f7:	75 ed                	jne    8018e6 <strncpy+0x14>
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  }
  return ret;
}
  8018f9:	89 f0                	mov    %esi,%eax
  8018fb:	5b                   	pop    %ebx
  8018fc:	5e                   	pop    %esi
  8018fd:	5d                   	pop    %ebp
  8018fe:	c3                   	ret    

008018ff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	56                   	push   %esi
  801903:	53                   	push   %ebx
  801904:	8b 75 08             	mov    0x8(%ebp),%esi
  801907:	8b 55 0c             	mov    0xc(%ebp),%edx
  80190a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80190d:	89 f0                	mov    %esi,%eax
  80190f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  801913:	85 c9                	test   %ecx,%ecx
  801915:	75 0b                	jne    801922 <strlcpy+0x23>
  801917:	eb 1d                	jmp    801936 <strlcpy+0x37>
    while (--size > 0 && *src != '\0')
      *dst++ = *src++;
  801919:	83 c0 01             	add    $0x1,%eax
  80191c:	83 c2 01             	add    $0x1,%edx
  80191f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
    while (--size > 0 && *src != '\0')
  801922:	39 d8                	cmp    %ebx,%eax
  801924:	74 0b                	je     801931 <strlcpy+0x32>
  801926:	0f b6 0a             	movzbl (%edx),%ecx
  801929:	84 c9                	test   %cl,%cl
  80192b:	75 ec                	jne    801919 <strlcpy+0x1a>
  80192d:	89 c2                	mov    %eax,%edx
  80192f:	eb 02                	jmp    801933 <strlcpy+0x34>
  801931:	89 c2                	mov    %eax,%edx
      *dst++ = *src++;
    *dst = '\0';
  801933:	c6 02 00             	movb   $0x0,(%edx)
  }
  return dst - dst_in;
  801936:	29 f0                	sub    %esi,%eax
}
  801938:	5b                   	pop    %ebx
  801939:	5e                   	pop    %esi
  80193a:	5d                   	pop    %ebp
  80193b:	c3                   	ret    

0080193c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80193c:	55                   	push   %ebp
  80193d:	89 e5                	mov    %esp,%ebp
  80193f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801942:	8b 55 0c             	mov    0xc(%ebp),%edx
  while (*p && *p == *q)
  801945:	eb 06                	jmp    80194d <strcmp+0x11>
    p++, q++;
  801947:	83 c1 01             	add    $0x1,%ecx
  80194a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
  while (*p && *p == *q)
  80194d:	0f b6 01             	movzbl (%ecx),%eax
  801950:	84 c0                	test   %al,%al
  801952:	74 04                	je     801958 <strcmp+0x1c>
  801954:	3a 02                	cmp    (%edx),%al
  801956:	74 ef                	je     801947 <strcmp+0xb>
    p++, q++;
  return (int)((unsigned char)*p - (unsigned char)*q);
  801958:	0f b6 c0             	movzbl %al,%eax
  80195b:	0f b6 12             	movzbl (%edx),%edx
  80195e:	29 d0                	sub    %edx,%eax
}
  801960:	5d                   	pop    %ebp
  801961:	c3                   	ret    

00801962 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	53                   	push   %ebx
  801966:	8b 45 08             	mov    0x8(%ebp),%eax
  801969:	8b 55 0c             	mov    0xc(%ebp),%edx
  80196c:	89 c3                	mov    %eax,%ebx
  80196e:	03 5d 10             	add    0x10(%ebp),%ebx
  while (n > 0 && *p && *p == *q)
  801971:	eb 06                	jmp    801979 <strncmp+0x17>
    n--, p++, q++;
  801973:	83 c0 01             	add    $0x1,%eax
  801976:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
  801979:	39 d8                	cmp    %ebx,%eax
  80197b:	74 15                	je     801992 <strncmp+0x30>
  80197d:	0f b6 08             	movzbl (%eax),%ecx
  801980:	84 c9                	test   %cl,%cl
  801982:	74 04                	je     801988 <strncmp+0x26>
  801984:	3a 0a                	cmp    (%edx),%cl
  801986:	74 eb                	je     801973 <strncmp+0x11>
    n--, p++, q++;
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  801988:	0f b6 00             	movzbl (%eax),%eax
  80198b:	0f b6 12             	movzbl (%edx),%edx
  80198e:	29 d0                	sub    %edx,%eax
  801990:	eb 05                	jmp    801997 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
    n--, p++, q++;
  if (n == 0)
    return 0;
  801992:	b8 00 00 00 00       	mov    $0x0,%eax
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
}
  801997:	5b                   	pop    %ebx
  801998:	5d                   	pop    %ebp
  801999:	c3                   	ret    

0080199a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80199a:	55                   	push   %ebp
  80199b:	89 e5                	mov    %esp,%ebp
  80199d:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
  8019a4:	eb 07                	jmp    8019ad <strchr+0x13>
    if (*s == c)
  8019a6:	38 ca                	cmp    %cl,%dl
  8019a8:	74 0f                	je     8019b9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  for (; *s; s++)
  8019aa:	83 c0 01             	add    $0x1,%eax
  8019ad:	0f b6 10             	movzbl (%eax),%edx
  8019b0:	84 d2                	test   %dl,%dl
  8019b2:	75 f2                	jne    8019a6 <strchr+0xc>
    if (*s == c)
      return (char*)s;
  return 0;
  8019b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019b9:	5d                   	pop    %ebp
  8019ba:	c3                   	ret    

008019bb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
  8019c5:	eb 07                	jmp    8019ce <strfind+0x13>
    if (*s == c)
  8019c7:	38 ca                	cmp    %cl,%dl
  8019c9:	74 0a                	je     8019d5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  for (; *s; s++)
  8019cb:	83 c0 01             	add    $0x1,%eax
  8019ce:	0f b6 10             	movzbl (%eax),%edx
  8019d1:	84 d2                	test   %dl,%dl
  8019d3:	75 f2                	jne    8019c7 <strfind+0xc>
    if (*s == c)
      break;
  return (char*)s;
}
  8019d5:	5d                   	pop    %ebp
  8019d6:	c3                   	ret    

008019d7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8019d7:	55                   	push   %ebp
  8019d8:	89 e5                	mov    %esp,%ebp
  8019da:	57                   	push   %edi
  8019db:	56                   	push   %esi
  8019dc:	53                   	push   %ebx
  8019dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *p;

  if (n == 0)
  8019e3:	85 c9                	test   %ecx,%ecx
  8019e5:	74 36                	je     801a1d <memset+0x46>
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
  8019e7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8019ed:	75 28                	jne    801a17 <memset+0x40>
  8019ef:	f6 c1 03             	test   $0x3,%cl
  8019f2:	75 23                	jne    801a17 <memset+0x40>
    c &= 0xFF;
  8019f4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
    c = (c<<24)|(c<<16)|(c<<8)|c;
  8019f8:	89 d3                	mov    %edx,%ebx
  8019fa:	c1 e3 08             	shl    $0x8,%ebx
  8019fd:	89 d6                	mov    %edx,%esi
  8019ff:	c1 e6 18             	shl    $0x18,%esi
  801a02:	89 d0                	mov    %edx,%eax
  801a04:	c1 e0 10             	shl    $0x10,%eax
  801a07:	09 f0                	or     %esi,%eax
  801a09:	09 c2                	or     %eax,%edx
  801a0b:	89 d0                	mov    %edx,%eax
  801a0d:	09 d8                	or     %ebx,%eax
    asm volatile ("cld; rep stosl\n"
                  :: "D" (v), "a" (c), "c" (n/4)
  801a0f:	c1 e9 02             	shr    $0x2,%ecx
  if (n == 0)
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
    c &= 0xFF;
    c = (c<<24)|(c<<16)|(c<<8)|c;
    asm volatile ("cld; rep stosl\n"
  801a12:	fc                   	cld    
  801a13:	f3 ab                	rep stos %eax,%es:(%edi)
  801a15:	eb 06                	jmp    801a1d <memset+0x46>
                  :: "D" (v), "a" (c), "c" (n/4)
                  : "cc", "memory");
  } else
    asm volatile ("cld; rep stosb\n"
  801a17:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1a:	fc                   	cld    
  801a1b:	f3 aa                	rep stos %al,%es:(%edi)
                  :: "D" (v), "a" (c), "c" (n)
                  : "cc", "memory");
  return v;
}
  801a1d:	89 f8                	mov    %edi,%eax
  801a1f:	5b                   	pop    %ebx
  801a20:	5e                   	pop    %esi
  801a21:	5f                   	pop    %edi
  801a22:	5d                   	pop    %ebp
  801a23:	c3                   	ret    

00801a24 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801a24:	55                   	push   %ebp
  801a25:	89 e5                	mov    %esp,%ebp
  801a27:	57                   	push   %edi
  801a28:	56                   	push   %esi
  801a29:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  801a32:	39 c6                	cmp    %eax,%esi
  801a34:	73 35                	jae    801a6b <memmove+0x47>
  801a36:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801a39:	39 d0                	cmp    %edx,%eax
  801a3b:	73 2e                	jae    801a6b <memmove+0x47>
    s += n;
    d += n;
  801a3d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801a40:	89 d6                	mov    %edx,%esi
  801a42:	09 fe                	or     %edi,%esi
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a44:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801a4a:	75 13                	jne    801a5f <memmove+0x3b>
  801a4c:	f6 c1 03             	test   $0x3,%cl
  801a4f:	75 0e                	jne    801a5f <memmove+0x3b>
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801a51:	83 ef 04             	sub    $0x4,%edi
  801a54:	8d 72 fc             	lea    -0x4(%edx),%esi
  801a57:	c1 e9 02             	shr    $0x2,%ecx
  d = dst;
  if (s < d && s + n > d) {
    s += n;
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
  801a5a:	fd                   	std    
  801a5b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a5d:	eb 09                	jmp    801a68 <memmove+0x44>
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801a5f:	83 ef 01             	sub    $0x1,%edi
  801a62:	8d 72 ff             	lea    -0x1(%edx),%esi
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
  801a65:	fd                   	std    
  801a66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  801a68:	fc                   	cld    
  801a69:	eb 1d                	jmp    801a88 <memmove+0x64>
  801a6b:	89 f2                	mov    %esi,%edx
  801a6d:	09 c2                	or     %eax,%edx
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a6f:	f6 c2 03             	test   $0x3,%dl
  801a72:	75 0f                	jne    801a83 <memmove+0x5f>
  801a74:	f6 c1 03             	test   $0x3,%cl
  801a77:	75 0a                	jne    801a83 <memmove+0x5f>
      asm volatile ("cld; rep movsl\n"
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801a79:	c1 e9 02             	shr    $0x2,%ecx
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("cld; rep movsl\n"
  801a7c:	89 c7                	mov    %eax,%edi
  801a7e:	fc                   	cld    
  801a7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a81:	eb 05                	jmp    801a88 <memmove+0x64>
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("cld; rep movsb\n"
  801a83:	89 c7                	mov    %eax,%edi
  801a85:	fc                   	cld    
  801a86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d), "S" (s), "c" (n) : "cc", "memory");
  }
  return dst;
}
  801a88:	5e                   	pop    %esi
  801a89:	5f                   	pop    %edi
  801a8a:	5d                   	pop    %ebp
  801a8b:	c3                   	ret    

00801a8c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
  801a92:	8b 45 10             	mov    0x10(%ebp),%eax
  801a95:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a99:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa3:	89 04 24             	mov    %eax,(%esp)
  801aa6:	e8 79 ff ff ff       	call   801a24 <memmove>
}
  801aab:	c9                   	leave  
  801aac:	c3                   	ret    

00801aad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801aad:	55                   	push   %ebp
  801aae:	89 e5                	mov    %esp,%ebp
  801ab0:	56                   	push   %esi
  801ab1:	53                   	push   %ebx
  801ab2:	8b 55 08             	mov    0x8(%ebp),%edx
  801ab5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ab8:	89 d6                	mov    %edx,%esi
  801aba:	03 75 10             	add    0x10(%ebp),%esi
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
  801abd:	eb 1a                	jmp    801ad9 <memcmp+0x2c>
    if (*s1 != *s2)
  801abf:	0f b6 02             	movzbl (%edx),%eax
  801ac2:	0f b6 19             	movzbl (%ecx),%ebx
  801ac5:	38 d8                	cmp    %bl,%al
  801ac7:	74 0a                	je     801ad3 <memcmp+0x26>
      return (int)*s1 - (int)*s2;
  801ac9:	0f b6 c0             	movzbl %al,%eax
  801acc:	0f b6 db             	movzbl %bl,%ebx
  801acf:	29 d8                	sub    %ebx,%eax
  801ad1:	eb 0f                	jmp    801ae2 <memcmp+0x35>
    s1++, s2++;
  801ad3:	83 c2 01             	add    $0x1,%edx
  801ad6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
  801ad9:	39 f2                	cmp    %esi,%edx
  801adb:	75 e2                	jne    801abf <memcmp+0x12>
    if (*s1 != *s2)
      return (int)*s1 - (int)*s2;
    s1++, s2++;
  }

  return 0;
  801add:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ae2:	5b                   	pop    %ebx
  801ae3:	5e                   	pop    %esi
  801ae4:	5d                   	pop    %ebp
  801ae5:	c3                   	ret    

00801ae6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801ae6:	55                   	push   %ebp
  801ae7:	89 e5                	mov    %esp,%ebp
  801ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  801aec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  const void *ends = (const char*)s + n;
  801aef:	89 c2                	mov    %eax,%edx
  801af1:	03 55 10             	add    0x10(%ebp),%edx

  for (; s < ends; s++)
  801af4:	eb 07                	jmp    801afd <memfind+0x17>
    if (*(const unsigned char*)s == (unsigned char)c)
  801af6:	38 08                	cmp    %cl,(%eax)
  801af8:	74 07                	je     801b01 <memfind+0x1b>
void *
memfind(const void *s, int c, size_t n)
{
  const void *ends = (const char*)s + n;

  for (; s < ends; s++)
  801afa:	83 c0 01             	add    $0x1,%eax
  801afd:	39 d0                	cmp    %edx,%eax
  801aff:	72 f5                	jb     801af6 <memfind+0x10>
    if (*(const unsigned char*)s == (unsigned char)c)
      break;
  return (void*)s;
}
  801b01:	5d                   	pop    %ebp
  801b02:	c3                   	ret    

00801b03 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801b03:	55                   	push   %ebp
  801b04:	89 e5                	mov    %esp,%ebp
  801b06:	57                   	push   %edi
  801b07:	56                   	push   %esi
  801b08:	53                   	push   %ebx
  801b09:	8b 55 08             	mov    0x8(%ebp),%edx
  801b0c:	8b 45 10             	mov    0x10(%ebp),%eax
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  801b0f:	eb 03                	jmp    801b14 <strtol+0x11>
    s++;
  801b11:	83 c2 01             	add    $0x1,%edx
{
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  801b14:	0f b6 0a             	movzbl (%edx),%ecx
  801b17:	80 f9 09             	cmp    $0x9,%cl
  801b1a:	74 f5                	je     801b11 <strtol+0xe>
  801b1c:	80 f9 20             	cmp    $0x20,%cl
  801b1f:	74 f0                	je     801b11 <strtol+0xe>
    s++;

  // plus/minus sign
  if (*s == '+')
  801b21:	80 f9 2b             	cmp    $0x2b,%cl
  801b24:	75 0a                	jne    801b30 <strtol+0x2d>
    s++;
  801b26:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
  int neg = 0;
  801b29:	bf 00 00 00 00       	mov    $0x0,%edi
  801b2e:	eb 11                	jmp    801b41 <strtol+0x3e>
  801b30:	bf 00 00 00 00       	mov    $0x0,%edi
    s++;

  // plus/minus sign
  if (*s == '+')
    s++;
  else if (*s == '-')
  801b35:	80 f9 2d             	cmp    $0x2d,%cl
  801b38:	75 07                	jne    801b41 <strtol+0x3e>
    s++, neg = 1;
  801b3a:	8d 52 01             	lea    0x1(%edx),%edx
  801b3d:	66 bf 01 00          	mov    $0x1,%di

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801b41:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801b46:	75 15                	jne    801b5d <strtol+0x5a>
  801b48:	80 3a 30             	cmpb   $0x30,(%edx)
  801b4b:	75 10                	jne    801b5d <strtol+0x5a>
  801b4d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801b51:	75 0a                	jne    801b5d <strtol+0x5a>
    s += 2, base = 16;
  801b53:	83 c2 02             	add    $0x2,%edx
  801b56:	b8 10 00 00 00       	mov    $0x10,%eax
  801b5b:	eb 10                	jmp    801b6d <strtol+0x6a>
  else if (base == 0 && s[0] == '0')
  801b5d:	85 c0                	test   %eax,%eax
  801b5f:	75 0c                	jne    801b6d <strtol+0x6a>
    s++, base = 8;
  else if (base == 0)
    base = 10;
  801b61:	b0 0a                	mov    $0xa,%al
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
  801b63:	80 3a 30             	cmpb   $0x30,(%edx)
  801b66:	75 05                	jne    801b6d <strtol+0x6a>
    s++, base = 8;
  801b68:	83 c2 01             	add    $0x1,%edx
  801b6b:	b0 08                	mov    $0x8,%al
  else if (base == 0)
    base = 10;
  801b6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b72:	89 45 10             	mov    %eax,0x10(%ebp)

  // digits
  while (1) {
    int dig;

    if (*s >= '0' && *s <= '9')
  801b75:	0f b6 0a             	movzbl (%edx),%ecx
  801b78:	8d 71 d0             	lea    -0x30(%ecx),%esi
  801b7b:	89 f0                	mov    %esi,%eax
  801b7d:	3c 09                	cmp    $0x9,%al
  801b7f:	77 08                	ja     801b89 <strtol+0x86>
      dig = *s - '0';
  801b81:	0f be c9             	movsbl %cl,%ecx
  801b84:	83 e9 30             	sub    $0x30,%ecx
  801b87:	eb 20                	jmp    801ba9 <strtol+0xa6>
    else if (*s >= 'a' && *s <= 'z')
  801b89:	8d 71 9f             	lea    -0x61(%ecx),%esi
  801b8c:	89 f0                	mov    %esi,%eax
  801b8e:	3c 19                	cmp    $0x19,%al
  801b90:	77 08                	ja     801b9a <strtol+0x97>
      dig = *s - 'a' + 10;
  801b92:	0f be c9             	movsbl %cl,%ecx
  801b95:	83 e9 57             	sub    $0x57,%ecx
  801b98:	eb 0f                	jmp    801ba9 <strtol+0xa6>
    else if (*s >= 'A' && *s <= 'Z')
  801b9a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  801b9d:	89 f0                	mov    %esi,%eax
  801b9f:	3c 19                	cmp    $0x19,%al
  801ba1:	77 16                	ja     801bb9 <strtol+0xb6>
      dig = *s - 'A' + 10;
  801ba3:	0f be c9             	movsbl %cl,%ecx
  801ba6:	83 e9 37             	sub    $0x37,%ecx
    else
      break;
    if (dig >= base)
  801ba9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  801bac:	7d 0f                	jge    801bbd <strtol+0xba>
      break;
    s++, val = (val * base) + dig;
  801bae:	83 c2 01             	add    $0x1,%edx
  801bb1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801bb5:	01 cb                	add    %ecx,%ebx
    // we don't properly detect overflow!
  }
  801bb7:	eb bc                	jmp    801b75 <strtol+0x72>
  801bb9:	89 d8                	mov    %ebx,%eax
  801bbb:	eb 02                	jmp    801bbf <strtol+0xbc>
  801bbd:	89 d8                	mov    %ebx,%eax

  if (endptr)
  801bbf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801bc3:	74 05                	je     801bca <strtol+0xc7>
    *endptr = (char*)s;
  801bc5:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bc8:	89 16                	mov    %edx,(%esi)
  return neg ? -val : val;
  801bca:	f7 d8                	neg    %eax
  801bcc:	85 ff                	test   %edi,%edi
  801bce:	0f 44 c3             	cmove  %ebx,%eax
}
  801bd1:	5b                   	pop    %ebx
  801bd2:	5e                   	pop    %esi
  801bd3:	5f                   	pop    %edi
  801bd4:	5d                   	pop    %ebp
  801bd5:	c3                   	ret    

00801bd6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bd6:	55                   	push   %ebp
  801bd7:	89 e5                	mov    %esp,%ebp
  801bd9:	56                   	push   %esi
  801bda:	53                   	push   %ebx
  801bdb:	83 ec 10             	sub    $0x10,%esp
  801bde:	8b 75 08             	mov    0x8(%ebp),%esi
  801be1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;
  801be7:	85 c0                	test   %eax,%eax
  801be9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801bee:	0f 44 c2             	cmove  %edx,%eax
  if ((r = sys_ipc_recv(pg)) < 0) {
  801bf1:	89 04 24             	mov    %eax,(%esp)
  801bf4:	e8 c0 e7 ff ff       	call   8003b9 <sys_ipc_recv>
  801bf9:	85 c0                	test   %eax,%eax
  801bfb:	79 34                	jns    801c31 <ipc_recv+0x5b>
    if (from_env_store)
  801bfd:	85 f6                	test   %esi,%esi
  801bff:	74 06                	je     801c07 <ipc_recv+0x31>
      *from_env_store = 0;
  801c01:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (perm_store)
  801c07:	85 db                	test   %ebx,%ebx
  801c09:	74 06                	je     801c11 <ipc_recv+0x3b>
      *perm_store = 0;
  801c0b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    panic("sys_ipc_recv: %e", r);
  801c11:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c15:	c7 44 24 08 00 24 80 	movl   $0x802400,0x8(%esp)
  801c1c:	00 
  801c1d:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801c24:	00 
  801c25:	c7 04 24 11 24 80 00 	movl   $0x802411,(%esp)
  801c2c:	e8 35 f5 ff ff       	call   801166 <_panic>
  }

  if (from_env_store)
  801c31:	85 f6                	test   %esi,%esi
  801c33:	74 0a                	je     801c3f <ipc_recv+0x69>
    *from_env_store = thisenv->env_ipc_from;
  801c35:	a1 04 40 80 00       	mov    0x804004,%eax
  801c3a:	8b 40 74             	mov    0x74(%eax),%eax
  801c3d:	89 06                	mov    %eax,(%esi)
  if (perm_store)
  801c3f:	85 db                	test   %ebx,%ebx
  801c41:	74 0a                	je     801c4d <ipc_recv+0x77>
    *perm_store |= thisenv->env_ipc_perm;
  801c43:	a1 04 40 80 00       	mov    0x804004,%eax
  801c48:	8b 40 78             	mov    0x78(%eax),%eax
  801c4b:	09 03                	or     %eax,(%ebx)

  return thisenv->env_ipc_value;
  801c4d:	a1 04 40 80 00       	mov    0x804004,%eax
  801c52:	8b 40 70             	mov    0x70(%eax),%eax

}
  801c55:	83 c4 10             	add    $0x10,%esp
  801c58:	5b                   	pop    %ebx
  801c59:	5e                   	pop    %esi
  801c5a:	5d                   	pop    %ebp
  801c5b:	c3                   	ret    

00801c5c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	57                   	push   %edi
  801c60:	56                   	push   %esi
  801c61:	53                   	push   %ebx
  801c62:	83 ec 1c             	sub    $0x1c,%esp
  801c65:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c68:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;
  801c6e:	85 db                	test   %ebx,%ebx
  801c70:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801c75:	0f 44 d8             	cmove  %eax,%ebx

  while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801c78:	eb 2a                	jmp    801ca4 <ipc_send+0x48>
    if (r != -E_IPC_NOT_RECV)
  801c7a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c7d:	74 20                	je     801c9f <ipc_send+0x43>
      panic("ipc_send: %e", r);
  801c7f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c83:	c7 44 24 08 1b 24 80 	movl   $0x80241b,0x8(%esp)
  801c8a:	00 
  801c8b:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801c92:	00 
  801c93:	c7 04 24 11 24 80 00 	movl   $0x802411,(%esp)
  801c9a:	e8 c7 f4 ff ff       	call   801166 <_panic>
    sys_yield();
  801c9f:	e8 e0 e4 ff ff       	call   800184 <sys_yield>
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;

  while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801ca4:	8b 45 14             	mov    0x14(%ebp),%eax
  801ca7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cab:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801caf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cb3:	89 3c 24             	mov    %edi,(%esp)
  801cb6:	e8 db e6 ff ff       	call   800396 <sys_ipc_try_send>
  801cbb:	85 c0                	test   %eax,%eax
  801cbd:	78 bb                	js     801c7a <ipc_send+0x1e>
    if (r != -E_IPC_NOT_RECV)
      panic("ipc_send: %e", r);
    sys_yield();
  }
}
  801cbf:	83 c4 1c             	add    $0x1c,%esp
  801cc2:	5b                   	pop    %ebx
  801cc3:	5e                   	pop    %esi
  801cc4:	5f                   	pop    %edi
  801cc5:	5d                   	pop    %ebp
  801cc6:	c3                   	ret    

00801cc7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cc7:	55                   	push   %ebp
  801cc8:	89 e5                	mov    %esp,%ebp
  801cca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int i;

  for (i = 0; i < NENV; i++)
  801ccd:	b8 00 00 00 00       	mov    $0x0,%eax
    if (envs[i].env_type == type)
  801cd2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801cd5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cdb:	8b 52 50             	mov    0x50(%edx),%edx
  801cde:	39 ca                	cmp    %ecx,%edx
  801ce0:	75 0d                	jne    801cef <ipc_find_env+0x28>
      return envs[i].env_id;
  801ce2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ce5:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801cea:	8b 40 40             	mov    0x40(%eax),%eax
  801ced:	eb 0e                	jmp    801cfd <ipc_find_env+0x36>
envid_t
ipc_find_env(enum EnvType type)
{
  int i;

  for (i = 0; i < NENV; i++)
  801cef:	83 c0 01             	add    $0x1,%eax
  801cf2:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cf7:	75 d9                	jne    801cd2 <ipc_find_env+0xb>
    if (envs[i].env_type == type)
      return envs[i].env_id;
  return 0;
  801cf9:	66 b8 00 00          	mov    $0x0,%ax
}
  801cfd:	5d                   	pop    %ebp
  801cfe:	c3                   	ret    

00801cff <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cff:	55                   	push   %ebp
  801d00:	89 e5                	mov    %esp,%ebp
  801d02:	8b 55 08             	mov    0x8(%ebp),%edx
  pte_t pte;

  if (!(uvpd[PDX(v)] & PTE_P))
  801d05:	89 d0                	mov    %edx,%eax
  801d07:	c1 e8 16             	shr    $0x16,%eax
  801d0a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
    return 0;
  801d11:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
  pte_t pte;

  if (!(uvpd[PDX(v)] & PTE_P))
  801d16:	f6 c1 01             	test   $0x1,%cl
  801d19:	74 1d                	je     801d38 <pageref+0x39>
    return 0;
  pte = uvpt[PGNUM(v)];
  801d1b:	c1 ea 0c             	shr    $0xc,%edx
  801d1e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  if (!(pte & PTE_P))
  801d25:	f6 c2 01             	test   $0x1,%dl
  801d28:	74 0e                	je     801d38 <pageref+0x39>
    return 0;
  return pages[PGNUM(pte)].pp_ref;
  801d2a:	c1 ea 0c             	shr    $0xc,%edx
  801d2d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d34:	ef 
  801d35:	0f b7 c0             	movzwl %ax,%eax
}
  801d38:	5d                   	pop    %ebp
  801d39:	c3                   	ret    
  801d3a:	66 90                	xchg   %ax,%ax
  801d3c:	66 90                	xchg   %ax,%ax
  801d3e:	66 90                	xchg   %ax,%ax

00801d40 <__udivdi3>:
  801d40:	55                   	push   %ebp
  801d41:	57                   	push   %edi
  801d42:	56                   	push   %esi
  801d43:	83 ec 0c             	sub    $0xc,%esp
  801d46:	8b 44 24 28          	mov    0x28(%esp),%eax
  801d4a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801d4e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801d52:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801d56:	85 c0                	test   %eax,%eax
  801d58:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d5c:	89 ea                	mov    %ebp,%edx
  801d5e:	89 0c 24             	mov    %ecx,(%esp)
  801d61:	75 2d                	jne    801d90 <__udivdi3+0x50>
  801d63:	39 e9                	cmp    %ebp,%ecx
  801d65:	77 61                	ja     801dc8 <__udivdi3+0x88>
  801d67:	85 c9                	test   %ecx,%ecx
  801d69:	89 ce                	mov    %ecx,%esi
  801d6b:	75 0b                	jne    801d78 <__udivdi3+0x38>
  801d6d:	b8 01 00 00 00       	mov    $0x1,%eax
  801d72:	31 d2                	xor    %edx,%edx
  801d74:	f7 f1                	div    %ecx
  801d76:	89 c6                	mov    %eax,%esi
  801d78:	31 d2                	xor    %edx,%edx
  801d7a:	89 e8                	mov    %ebp,%eax
  801d7c:	f7 f6                	div    %esi
  801d7e:	89 c5                	mov    %eax,%ebp
  801d80:	89 f8                	mov    %edi,%eax
  801d82:	f7 f6                	div    %esi
  801d84:	89 ea                	mov    %ebp,%edx
  801d86:	83 c4 0c             	add    $0xc,%esp
  801d89:	5e                   	pop    %esi
  801d8a:	5f                   	pop    %edi
  801d8b:	5d                   	pop    %ebp
  801d8c:	c3                   	ret    
  801d8d:	8d 76 00             	lea    0x0(%esi),%esi
  801d90:	39 e8                	cmp    %ebp,%eax
  801d92:	77 24                	ja     801db8 <__udivdi3+0x78>
  801d94:	0f bd e8             	bsr    %eax,%ebp
  801d97:	83 f5 1f             	xor    $0x1f,%ebp
  801d9a:	75 3c                	jne    801dd8 <__udivdi3+0x98>
  801d9c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801da0:	39 34 24             	cmp    %esi,(%esp)
  801da3:	0f 86 9f 00 00 00    	jbe    801e48 <__udivdi3+0x108>
  801da9:	39 d0                	cmp    %edx,%eax
  801dab:	0f 82 97 00 00 00    	jb     801e48 <__udivdi3+0x108>
  801db1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801db8:	31 d2                	xor    %edx,%edx
  801dba:	31 c0                	xor    %eax,%eax
  801dbc:	83 c4 0c             	add    $0xc,%esp
  801dbf:	5e                   	pop    %esi
  801dc0:	5f                   	pop    %edi
  801dc1:	5d                   	pop    %ebp
  801dc2:	c3                   	ret    
  801dc3:	90                   	nop
  801dc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dc8:	89 f8                	mov    %edi,%eax
  801dca:	f7 f1                	div    %ecx
  801dcc:	31 d2                	xor    %edx,%edx
  801dce:	83 c4 0c             	add    $0xc,%esp
  801dd1:	5e                   	pop    %esi
  801dd2:	5f                   	pop    %edi
  801dd3:	5d                   	pop    %ebp
  801dd4:	c3                   	ret    
  801dd5:	8d 76 00             	lea    0x0(%esi),%esi
  801dd8:	89 e9                	mov    %ebp,%ecx
  801dda:	8b 3c 24             	mov    (%esp),%edi
  801ddd:	d3 e0                	shl    %cl,%eax
  801ddf:	89 c6                	mov    %eax,%esi
  801de1:	b8 20 00 00 00       	mov    $0x20,%eax
  801de6:	29 e8                	sub    %ebp,%eax
  801de8:	89 c1                	mov    %eax,%ecx
  801dea:	d3 ef                	shr    %cl,%edi
  801dec:	89 e9                	mov    %ebp,%ecx
  801dee:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801df2:	8b 3c 24             	mov    (%esp),%edi
  801df5:	09 74 24 08          	or     %esi,0x8(%esp)
  801df9:	89 d6                	mov    %edx,%esi
  801dfb:	d3 e7                	shl    %cl,%edi
  801dfd:	89 c1                	mov    %eax,%ecx
  801dff:	89 3c 24             	mov    %edi,(%esp)
  801e02:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801e06:	d3 ee                	shr    %cl,%esi
  801e08:	89 e9                	mov    %ebp,%ecx
  801e0a:	d3 e2                	shl    %cl,%edx
  801e0c:	89 c1                	mov    %eax,%ecx
  801e0e:	d3 ef                	shr    %cl,%edi
  801e10:	09 d7                	or     %edx,%edi
  801e12:	89 f2                	mov    %esi,%edx
  801e14:	89 f8                	mov    %edi,%eax
  801e16:	f7 74 24 08          	divl   0x8(%esp)
  801e1a:	89 d6                	mov    %edx,%esi
  801e1c:	89 c7                	mov    %eax,%edi
  801e1e:	f7 24 24             	mull   (%esp)
  801e21:	39 d6                	cmp    %edx,%esi
  801e23:	89 14 24             	mov    %edx,(%esp)
  801e26:	72 30                	jb     801e58 <__udivdi3+0x118>
  801e28:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e2c:	89 e9                	mov    %ebp,%ecx
  801e2e:	d3 e2                	shl    %cl,%edx
  801e30:	39 c2                	cmp    %eax,%edx
  801e32:	73 05                	jae    801e39 <__udivdi3+0xf9>
  801e34:	3b 34 24             	cmp    (%esp),%esi
  801e37:	74 1f                	je     801e58 <__udivdi3+0x118>
  801e39:	89 f8                	mov    %edi,%eax
  801e3b:	31 d2                	xor    %edx,%edx
  801e3d:	e9 7a ff ff ff       	jmp    801dbc <__udivdi3+0x7c>
  801e42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e48:	31 d2                	xor    %edx,%edx
  801e4a:	b8 01 00 00 00       	mov    $0x1,%eax
  801e4f:	e9 68 ff ff ff       	jmp    801dbc <__udivdi3+0x7c>
  801e54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e58:	8d 47 ff             	lea    -0x1(%edi),%eax
  801e5b:	31 d2                	xor    %edx,%edx
  801e5d:	83 c4 0c             	add    $0xc,%esp
  801e60:	5e                   	pop    %esi
  801e61:	5f                   	pop    %edi
  801e62:	5d                   	pop    %ebp
  801e63:	c3                   	ret    
  801e64:	66 90                	xchg   %ax,%ax
  801e66:	66 90                	xchg   %ax,%ax
  801e68:	66 90                	xchg   %ax,%ax
  801e6a:	66 90                	xchg   %ax,%ax
  801e6c:	66 90                	xchg   %ax,%ax
  801e6e:	66 90                	xchg   %ax,%ax

00801e70 <__umoddi3>:
  801e70:	55                   	push   %ebp
  801e71:	57                   	push   %edi
  801e72:	56                   	push   %esi
  801e73:	83 ec 14             	sub    $0x14,%esp
  801e76:	8b 44 24 28          	mov    0x28(%esp),%eax
  801e7a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801e7e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801e82:	89 c7                	mov    %eax,%edi
  801e84:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e88:	8b 44 24 30          	mov    0x30(%esp),%eax
  801e8c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801e90:	89 34 24             	mov    %esi,(%esp)
  801e93:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e97:	85 c0                	test   %eax,%eax
  801e99:	89 c2                	mov    %eax,%edx
  801e9b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e9f:	75 17                	jne    801eb8 <__umoddi3+0x48>
  801ea1:	39 fe                	cmp    %edi,%esi
  801ea3:	76 4b                	jbe    801ef0 <__umoddi3+0x80>
  801ea5:	89 c8                	mov    %ecx,%eax
  801ea7:	89 fa                	mov    %edi,%edx
  801ea9:	f7 f6                	div    %esi
  801eab:	89 d0                	mov    %edx,%eax
  801ead:	31 d2                	xor    %edx,%edx
  801eaf:	83 c4 14             	add    $0x14,%esp
  801eb2:	5e                   	pop    %esi
  801eb3:	5f                   	pop    %edi
  801eb4:	5d                   	pop    %ebp
  801eb5:	c3                   	ret    
  801eb6:	66 90                	xchg   %ax,%ax
  801eb8:	39 f8                	cmp    %edi,%eax
  801eba:	77 54                	ja     801f10 <__umoddi3+0xa0>
  801ebc:	0f bd e8             	bsr    %eax,%ebp
  801ebf:	83 f5 1f             	xor    $0x1f,%ebp
  801ec2:	75 5c                	jne    801f20 <__umoddi3+0xb0>
  801ec4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801ec8:	39 3c 24             	cmp    %edi,(%esp)
  801ecb:	0f 87 e7 00 00 00    	ja     801fb8 <__umoddi3+0x148>
  801ed1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ed5:	29 f1                	sub    %esi,%ecx
  801ed7:	19 c7                	sbb    %eax,%edi
  801ed9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801edd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ee1:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ee5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801ee9:	83 c4 14             	add    $0x14,%esp
  801eec:	5e                   	pop    %esi
  801eed:	5f                   	pop    %edi
  801eee:	5d                   	pop    %ebp
  801eef:	c3                   	ret    
  801ef0:	85 f6                	test   %esi,%esi
  801ef2:	89 f5                	mov    %esi,%ebp
  801ef4:	75 0b                	jne    801f01 <__umoddi3+0x91>
  801ef6:	b8 01 00 00 00       	mov    $0x1,%eax
  801efb:	31 d2                	xor    %edx,%edx
  801efd:	f7 f6                	div    %esi
  801eff:	89 c5                	mov    %eax,%ebp
  801f01:	8b 44 24 04          	mov    0x4(%esp),%eax
  801f05:	31 d2                	xor    %edx,%edx
  801f07:	f7 f5                	div    %ebp
  801f09:	89 c8                	mov    %ecx,%eax
  801f0b:	f7 f5                	div    %ebp
  801f0d:	eb 9c                	jmp    801eab <__umoddi3+0x3b>
  801f0f:	90                   	nop
  801f10:	89 c8                	mov    %ecx,%eax
  801f12:	89 fa                	mov    %edi,%edx
  801f14:	83 c4 14             	add    $0x14,%esp
  801f17:	5e                   	pop    %esi
  801f18:	5f                   	pop    %edi
  801f19:	5d                   	pop    %ebp
  801f1a:	c3                   	ret    
  801f1b:	90                   	nop
  801f1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f20:	8b 04 24             	mov    (%esp),%eax
  801f23:	be 20 00 00 00       	mov    $0x20,%esi
  801f28:	89 e9                	mov    %ebp,%ecx
  801f2a:	29 ee                	sub    %ebp,%esi
  801f2c:	d3 e2                	shl    %cl,%edx
  801f2e:	89 f1                	mov    %esi,%ecx
  801f30:	d3 e8                	shr    %cl,%eax
  801f32:	89 e9                	mov    %ebp,%ecx
  801f34:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f38:	8b 04 24             	mov    (%esp),%eax
  801f3b:	09 54 24 04          	or     %edx,0x4(%esp)
  801f3f:	89 fa                	mov    %edi,%edx
  801f41:	d3 e0                	shl    %cl,%eax
  801f43:	89 f1                	mov    %esi,%ecx
  801f45:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f49:	8b 44 24 10          	mov    0x10(%esp),%eax
  801f4d:	d3 ea                	shr    %cl,%edx
  801f4f:	89 e9                	mov    %ebp,%ecx
  801f51:	d3 e7                	shl    %cl,%edi
  801f53:	89 f1                	mov    %esi,%ecx
  801f55:	d3 e8                	shr    %cl,%eax
  801f57:	89 e9                	mov    %ebp,%ecx
  801f59:	09 f8                	or     %edi,%eax
  801f5b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801f5f:	f7 74 24 04          	divl   0x4(%esp)
  801f63:	d3 e7                	shl    %cl,%edi
  801f65:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f69:	89 d7                	mov    %edx,%edi
  801f6b:	f7 64 24 08          	mull   0x8(%esp)
  801f6f:	39 d7                	cmp    %edx,%edi
  801f71:	89 c1                	mov    %eax,%ecx
  801f73:	89 14 24             	mov    %edx,(%esp)
  801f76:	72 2c                	jb     801fa4 <__umoddi3+0x134>
  801f78:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801f7c:	72 22                	jb     801fa0 <__umoddi3+0x130>
  801f7e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f82:	29 c8                	sub    %ecx,%eax
  801f84:	19 d7                	sbb    %edx,%edi
  801f86:	89 e9                	mov    %ebp,%ecx
  801f88:	89 fa                	mov    %edi,%edx
  801f8a:	d3 e8                	shr    %cl,%eax
  801f8c:	89 f1                	mov    %esi,%ecx
  801f8e:	d3 e2                	shl    %cl,%edx
  801f90:	89 e9                	mov    %ebp,%ecx
  801f92:	d3 ef                	shr    %cl,%edi
  801f94:	09 d0                	or     %edx,%eax
  801f96:	89 fa                	mov    %edi,%edx
  801f98:	83 c4 14             	add    $0x14,%esp
  801f9b:	5e                   	pop    %esi
  801f9c:	5f                   	pop    %edi
  801f9d:	5d                   	pop    %ebp
  801f9e:	c3                   	ret    
  801f9f:	90                   	nop
  801fa0:	39 d7                	cmp    %edx,%edi
  801fa2:	75 da                	jne    801f7e <__umoddi3+0x10e>
  801fa4:	8b 14 24             	mov    (%esp),%edx
  801fa7:	89 c1                	mov    %eax,%ecx
  801fa9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801fad:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801fb1:	eb cb                	jmp    801f7e <__umoddi3+0x10e>
  801fb3:	90                   	nop
  801fb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fb8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801fbc:	0f 82 0f ff ff ff    	jb     801ed1 <__umoddi3+0x61>
  801fc2:	e9 1a ff ff ff       	jmp    801ee1 <__umoddi3+0x71>
