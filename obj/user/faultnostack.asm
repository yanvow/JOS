
obj/user/faultnostack.debug:     file format elf32-i386


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
  80002c:	e8 28 00 00 00       	call   800059 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
  sys_env_set_pgfault_upcall(0, (void*)_pgfault_upcall);
  800039:	c7 44 24 04 ef 03 80 	movl   $0x8003ef,0x4(%esp)
  800040:	00 
  800041:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800048:	e8 da 02 00 00       	call   800327 <sys_env_set_pgfault_upcall>
  *(int*)0 = 0;
  80004d:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800054:	00 00 00 
}
  800057:	c9                   	leave  
  800058:	c3                   	ret    

00800059 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800059:	55                   	push   %ebp
  80005a:	89 e5                	mov    %esp,%ebp
  80005c:	56                   	push   %esi
  80005d:	53                   	push   %ebx
  80005e:	83 ec 10             	sub    $0x10,%esp
  800061:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800064:	8b 75 0c             	mov    0xc(%ebp),%esi
  // set thisenv to point at our Env structure in envs[].
  // LAB 3: Your code here.
  thisenv = envs + ENVX(sys_getenvid());
  800067:	e8 dd 00 00 00       	call   800149 <sys_getenvid>
  80006c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800071:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800074:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800079:	a3 04 40 80 00       	mov    %eax,0x804004

  // save the name of the program so that panic() can use it
  if (argc > 0)
  80007e:	85 db                	test   %ebx,%ebx
  800080:	7e 07                	jle    800089 <libmain+0x30>
    binaryname = argv[0];
  800082:	8b 06                	mov    (%esi),%eax
  800084:	a3 00 30 80 00       	mov    %eax,0x803000

  // call user main routine
  umain(argc, argv);
  800089:	89 74 24 04          	mov    %esi,0x4(%esp)
  80008d:	89 1c 24             	mov    %ebx,(%esp)
  800090:	e8 9e ff ff ff       	call   800033 <umain>

  // exit gracefully
  exit();
  800095:	e8 07 00 00 00       	call   8000a1 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	5b                   	pop    %ebx
  80009e:	5e                   	pop    %esi
  80009f:	5d                   	pop    %ebp
  8000a0:	c3                   	ret    

008000a1 <exit>:
#include <inc/lib.h>

void
exit(void)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	83 ec 18             	sub    $0x18,%esp
  close_all();
  8000a7:	e8 49 05 00 00       	call   8005f5 <close_all>
  sys_env_destroy(0);
  8000ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b3:	e8 3f 00 00 00       	call   8000f7 <sys_env_destroy>
}
  8000b8:	c9                   	leave  
  8000b9:	c3                   	ret    

008000ba <sys_cputs>:
  return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ba:	55                   	push   %ebp
  8000bb:	89 e5                	mov    %esp,%ebp
  8000bd:	57                   	push   %edi
  8000be:	56                   	push   %esi
  8000bf:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8000c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cb:	89 c3                	mov    %eax,%ebx
  8000cd:	89 c7                	mov    %eax,%edi
  8000cf:	89 c6                	mov    %eax,%esi
  8000d1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
  syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d3:	5b                   	pop    %ebx
  8000d4:	5e                   	pop    %esi
  8000d5:	5f                   	pop    %edi
  8000d6:	5d                   	pop    %ebp
  8000d7:	c3                   	ret    

008000d8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	57                   	push   %edi
  8000dc:	56                   	push   %esi
  8000dd:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8000de:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e8:	89 d1                	mov    %edx,%ecx
  8000ea:	89 d3                	mov    %edx,%ebx
  8000ec:	89 d7                	mov    %edx,%edi
  8000ee:	89 d6                	mov    %edx,%esi
  8000f0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f2:	5b                   	pop    %ebx
  8000f3:	5e                   	pop    %esi
  8000f4:	5f                   	pop    %edi
  8000f5:	5d                   	pop    %ebp
  8000f6:	c3                   	ret    

008000f7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	57                   	push   %edi
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800100:	b9 00 00 00 00       	mov    $0x0,%ecx
  800105:	b8 03 00 00 00       	mov    $0x3,%eax
  80010a:	8b 55 08             	mov    0x8(%ebp),%edx
  80010d:	89 cb                	mov    %ecx,%ebx
  80010f:	89 cf                	mov    %ecx,%edi
  800111:	89 ce                	mov    %ecx,%esi
  800113:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800115:	85 c0                	test   %eax,%eax
  800117:	7e 28                	jle    800141 <sys_env_destroy+0x4a>
    panic("syscall %d returned %d (> 0)", num, ret);
  800119:	89 44 24 10          	mov    %eax,0x10(%esp)
  80011d:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800124:	00 
  800125:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  80012c:	00 
  80012d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800134:	00 
  800135:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  80013c:	e8 35 10 00 00       	call   801176 <_panic>

int
sys_env_destroy(envid_t envid)
{
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800141:	83 c4 2c             	add    $0x2c,%esp
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	57                   	push   %edi
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  80014f:	ba 00 00 00 00       	mov    $0x0,%edx
  800154:	b8 02 00 00 00       	mov    $0x2,%eax
  800159:	89 d1                	mov    %edx,%ecx
  80015b:	89 d3                	mov    %edx,%ebx
  80015d:	89 d7                	mov    %edx,%edi
  80015f:	89 d6                	mov    %edx,%esi
  800161:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5f                   	pop    %edi
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_yield>:

void
sys_yield(void)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  80016e:	ba 00 00 00 00       	mov    $0x0,%edx
  800173:	b8 0b 00 00 00       	mov    $0xb,%eax
  800178:	89 d1                	mov    %edx,%ecx
  80017a:	89 d3                	mov    %edx,%ebx
  80017c:	89 d7                	mov    %edx,%edi
  80017e:	89 d6                	mov    %edx,%esi
  800180:	cd 30                	int    $0x30

void
sys_yield(void)
{
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800182:	5b                   	pop    %ebx
  800183:	5e                   	pop    %esi
  800184:	5f                   	pop    %edi
  800185:	5d                   	pop    %ebp
  800186:	c3                   	ret    

00800187 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	57                   	push   %edi
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
  80018d:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800190:	be 00 00 00 00       	mov    $0x0,%esi
  800195:	b8 04 00 00 00       	mov    $0x4,%eax
  80019a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019d:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a3:	89 f7                	mov    %esi,%edi
  8001a5:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  8001a7:	85 c0                	test   %eax,%eax
  8001a9:	7e 28                	jle    8001d3 <sys_page_alloc+0x4c>
    panic("syscall %d returned %d (> 0)", num, ret);
  8001ab:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001af:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001b6:	00 
  8001b7:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  8001be:	00 
  8001bf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001c6:	00 
  8001c7:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  8001ce:	e8 a3 0f 00 00       	call   801176 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  return syscall(SYS_page_alloc, 1, envid, (uint32_t)va, perm, 0, 0);
}
  8001d3:	83 c4 2c             	add    $0x2c,%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	57                   	push   %edi
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8001e4:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f5:	8b 75 18             	mov    0x18(%ebp),%esi
  8001f8:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	7e 28                	jle    800226 <sys_page_map+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  8001fe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800202:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800209:	00 
  80020a:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  800211:	00 
  800212:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800219:	00 
  80021a:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  800221:	e8 50 0f 00 00       	call   801176 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  return syscall(SYS_page_map, 1, srcenv, (uint32_t)srcva, dstenv, (uint32_t)dstva, perm);
}
  800226:	83 c4 2c             	add    $0x2c,%esp
  800229:	5b                   	pop    %ebx
  80022a:	5e                   	pop    %esi
  80022b:	5f                   	pop    %edi
  80022c:	5d                   	pop    %ebp
  80022d:	c3                   	ret    

0080022e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
  800231:	57                   	push   %edi
  800232:	56                   	push   %esi
  800233:	53                   	push   %ebx
  800234:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800237:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023c:	b8 06 00 00 00       	mov    $0x6,%eax
  800241:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800244:	8b 55 08             	mov    0x8(%ebp),%edx
  800247:	89 df                	mov    %ebx,%edi
  800249:	89 de                	mov    %ebx,%esi
  80024b:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  80024d:	85 c0                	test   %eax,%eax
  80024f:	7e 28                	jle    800279 <sys_page_unmap+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800251:	89 44 24 10          	mov    %eax,0x10(%esp)
  800255:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80025c:	00 
  80025d:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  800264:	00 
  800265:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80026c:	00 
  80026d:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  800274:	e8 fd 0e 00 00       	call   801176 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
  return syscall(SYS_page_unmap, 1, envid, (uint32_t)va, 0, 0, 0);
}
  800279:	83 c4 2c             	add    $0x2c,%esp
  80027c:	5b                   	pop    %ebx
  80027d:	5e                   	pop    %esi
  80027e:	5f                   	pop    %edi
  80027f:	5d                   	pop    %ebp
  800280:	c3                   	ret    

00800281 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	57                   	push   %edi
  800285:	56                   	push   %esi
  800286:	53                   	push   %ebx
  800287:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  80028a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80028f:	b8 08 00 00 00       	mov    $0x8,%eax
  800294:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800297:	8b 55 08             	mov    0x8(%ebp),%edx
  80029a:	89 df                	mov    %ebx,%edi
  80029c:	89 de                	mov    %ebx,%esi
  80029e:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  8002a0:	85 c0                	test   %eax,%eax
  8002a2:	7e 28                	jle    8002cc <sys_env_set_status+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  8002a4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002a8:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002af:	00 
  8002b0:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  8002b7:	00 
  8002b8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002bf:	00 
  8002c0:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  8002c7:	e8 aa 0e 00 00       	call   801176 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002cc:	83 c4 2c             	add    $0x2c,%esp
  8002cf:	5b                   	pop    %ebx
  8002d0:	5e                   	pop    %esi
  8002d1:	5f                   	pop    %edi
  8002d2:	5d                   	pop    %ebp
  8002d3:	c3                   	ret    

008002d4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
  8002d7:	57                   	push   %edi
  8002d8:	56                   	push   %esi
  8002d9:	53                   	push   %ebx
  8002da:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8002dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e2:	b8 09 00 00 00       	mov    $0x9,%eax
  8002e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ed:	89 df                	mov    %ebx,%edi
  8002ef:	89 de                	mov    %ebx,%esi
  8002f1:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  8002f3:	85 c0                	test   %eax,%eax
  8002f5:	7e 28                	jle    80031f <sys_env_set_trapframe+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  8002f7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002fb:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800302:	00 
  800303:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  80030a:	00 
  80030b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800312:	00 
  800313:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  80031a:	e8 57 0e 00 00       	call   801176 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t)tf, 0, 0, 0);
}
  80031f:	83 c4 2c             	add    $0x2c,%esp
  800322:	5b                   	pop    %ebx
  800323:	5e                   	pop    %esi
  800324:	5f                   	pop    %edi
  800325:	5d                   	pop    %ebp
  800326:	c3                   	ret    

00800327 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800327:	55                   	push   %ebp
  800328:	89 e5                	mov    %esp,%ebp
  80032a:	57                   	push   %edi
  80032b:	56                   	push   %esi
  80032c:	53                   	push   %ebx
  80032d:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800330:	bb 00 00 00 00       	mov    $0x0,%ebx
  800335:	b8 0a 00 00 00       	mov    $0xa,%eax
  80033a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80033d:	8b 55 08             	mov    0x8(%ebp),%edx
  800340:	89 df                	mov    %ebx,%edi
  800342:	89 de                	mov    %ebx,%esi
  800344:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800346:	85 c0                	test   %eax,%eax
  800348:	7e 28                	jle    800372 <sys_env_set_pgfault_upcall+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  80034a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80034e:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800355:	00 
  800356:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  80035d:	00 
  80035e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800365:	00 
  800366:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  80036d:	e8 04 0e 00 00       	call   801176 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800372:	83 c4 2c             	add    $0x2c,%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	57                   	push   %edi
  80037e:	56                   	push   %esi
  80037f:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800380:	be 00 00 00 00       	mov    $0x0,%esi
  800385:	b8 0c 00 00 00       	mov    $0xc,%eax
  80038a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80038d:	8b 55 08             	mov    0x8(%ebp),%edx
  800390:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800393:	8b 7d 14             	mov    0x14(%ebp),%edi
  800396:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t)srcva, perm, 0);
}
  800398:	5b                   	pop    %ebx
  800399:	5e                   	pop    %esi
  80039a:	5f                   	pop    %edi
  80039b:	5d                   	pop    %ebp
  80039c:	c3                   	ret    

0080039d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80039d:	55                   	push   %ebp
  80039e:	89 e5                	mov    %esp,%ebp
  8003a0:	57                   	push   %edi
  8003a1:	56                   	push   %esi
  8003a2:	53                   	push   %ebx
  8003a3:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8003a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ab:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b3:	89 cb                	mov    %ecx,%ebx
  8003b5:	89 cf                	mov    %ecx,%edi
  8003b7:	89 ce                	mov    %ecx,%esi
  8003b9:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  8003bb:	85 c0                	test   %eax,%eax
  8003bd:	7e 28                	jle    8003e7 <sys_ipc_recv+0x4a>
    panic("syscall %d returned %d (> 0)", num, ret);
  8003bf:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003c3:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003ca:	00 
  8003cb:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  8003d2:	00 
  8003d3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003da:	00 
  8003db:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  8003e2:	e8 8f 0d 00 00       	call   801176 <_panic>

int
sys_ipc_recv(void *dstva)
{
  return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003e7:	83 c4 2c             	add    $0x2c,%esp
  8003ea:	5b                   	pop    %ebx
  8003eb:	5e                   	pop    %esi
  8003ec:	5f                   	pop    %edi
  8003ed:	5d                   	pop    %ebp
  8003ee:	c3                   	ret    

008003ef <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8003ef:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8003f0:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8003f5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8003f7:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
  subl $0x4, 0x30(%esp)
  8003fa:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
  movl 0x30(%esp), %eax
  8003ff:	8b 44 24 30          	mov    0x30(%esp),%eax
  movl 0x28(%esp), %ebx
  800403:	8b 5c 24 28          	mov    0x28(%esp),%ebx
  movl %ebx, (%eax)
  800407:	89 18                	mov    %ebx,(%eax)


	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
  addl $0x8, %esp
  800409:	83 c4 08             	add    $0x8,%esp
  popal
  80040c:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
  addl $0x4, %esp
  80040d:	83 c4 04             	add    $0x4,%esp
  popfl
  800410:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
  movl (%esp), %esp
  800411:	8b 24 24             	mov    (%esp),%esp

  // Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  ret
  800414:	c3                   	ret    
  800415:	66 90                	xchg   %ax,%ax
  800417:	66 90                	xchg   %ax,%ax
  800419:	66 90                	xchg   %ax,%ax
  80041b:	66 90                	xchg   %ax,%ax
  80041d:	66 90                	xchg   %ax,%ax
  80041f:	90                   	nop

00800420 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  800423:	8b 45 08             	mov    0x8(%ebp),%eax
  800426:	05 00 00 00 30       	add    $0x30000000,%eax
  80042b:	c1 e8 0c             	shr    $0xc,%eax
}
  80042e:	5d                   	pop    %ebp
  80042f:	c3                   	ret    

00800430 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800430:	55                   	push   %ebp
  800431:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  800433:	8b 45 08             	mov    0x8(%ebp),%eax
  800436:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
  return INDEX2DATA(fd2num(fd));
  80043b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800440:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800445:	5d                   	pop    %ebp
  800446:	c3                   	ret    

00800447 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800447:	55                   	push   %ebp
  800448:	89 e5                	mov    %esp,%ebp
  80044a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80044d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
  int i;
  struct Fd *fd;

  for (i = 0; i < MAXFD; i++) {
    fd = INDEX2FD(i);
    if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800452:	89 c2                	mov    %eax,%edx
  800454:	c1 ea 16             	shr    $0x16,%edx
  800457:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80045e:	f6 c2 01             	test   $0x1,%dl
  800461:	74 11                	je     800474 <fd_alloc+0x2d>
  800463:	89 c2                	mov    %eax,%edx
  800465:	c1 ea 0c             	shr    $0xc,%edx
  800468:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80046f:	f6 c2 01             	test   $0x1,%dl
  800472:	75 09                	jne    80047d <fd_alloc+0x36>
      *fd_store = fd;
  800474:	89 01                	mov    %eax,(%ecx)
      return 0;
  800476:	b8 00 00 00 00       	mov    $0x0,%eax
  80047b:	eb 17                	jmp    800494 <fd_alloc+0x4d>
  80047d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
  int i;
  struct Fd *fd;

  for (i = 0; i < MAXFD; i++) {
  800482:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800487:	75 c9                	jne    800452 <fd_alloc+0xb>
    if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
      *fd_store = fd;
      return 0;
    }
  }
  *fd_store = 0;
  800489:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
  return -E_MAX_OPEN;
  80048f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800494:	5d                   	pop    %ebp
  800495:	c3                   	ret    

00800496 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800496:	55                   	push   %ebp
  800497:	89 e5                	mov    %esp,%ebp
  800499:	8b 45 08             	mov    0x8(%ebp),%eax
  struct Fd *fd;

  if (fdnum < 0 || fdnum >= MAXFD) {
  80049c:	83 f8 1f             	cmp    $0x1f,%eax
  80049f:	77 36                	ja     8004d7 <fd_lookup+0x41>
    if (debug)
      cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  fd = INDEX2FD(fdnum);
  8004a1:	c1 e0 0c             	shl    $0xc,%eax
  8004a4:	2d 00 00 00 30       	sub    $0x30000000,%eax
  if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8004a9:	89 c2                	mov    %eax,%edx
  8004ab:	c1 ea 16             	shr    $0x16,%edx
  8004ae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8004b5:	f6 c2 01             	test   $0x1,%dl
  8004b8:	74 24                	je     8004de <fd_lookup+0x48>
  8004ba:	89 c2                	mov    %eax,%edx
  8004bc:	c1 ea 0c             	shr    $0xc,%edx
  8004bf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004c6:	f6 c2 01             	test   $0x1,%dl
  8004c9:	74 1a                	je     8004e5 <fd_lookup+0x4f>
    if (debug)
      cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  *fd_store = fd;
  8004cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ce:	89 02                	mov    %eax,(%edx)
  return 0;
  8004d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d5:	eb 13                	jmp    8004ea <fd_lookup+0x54>
  struct Fd *fd;

  if (fdnum < 0 || fdnum >= MAXFD) {
    if (debug)
      cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  8004d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004dc:	eb 0c                	jmp    8004ea <fd_lookup+0x54>
  }
  fd = INDEX2FD(fdnum);
  if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
    if (debug)
      cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  8004de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004e3:	eb 05                	jmp    8004ea <fd_lookup+0x54>
  8004e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  }
  *fd_store = fd;
  return 0;
}
  8004ea:	5d                   	pop    %ebp
  8004eb:	c3                   	ret    

008004ec <dev_lookup>:
  0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004ec:	55                   	push   %ebp
  8004ed:	89 e5                	mov    %esp,%ebp
  8004ef:	83 ec 18             	sub    $0x18,%esp
  8004f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004f5:	ba 34 21 80 00       	mov    $0x802134,%edx
  int i;

  for (i = 0; devtab[i]; i++)
  8004fa:	eb 13                	jmp    80050f <dev_lookup+0x23>
  8004fc:	83 c2 04             	add    $0x4,%edx
    if (devtab[i]->dev_id == dev_id) {
  8004ff:	39 08                	cmp    %ecx,(%eax)
  800501:	75 0c                	jne    80050f <dev_lookup+0x23>
      *dev = devtab[i];
  800503:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800506:	89 01                	mov    %eax,(%ecx)
      return 0;
  800508:	b8 00 00 00 00       	mov    $0x0,%eax
  80050d:	eb 30                	jmp    80053f <dev_lookup+0x53>
int
dev_lookup(int dev_id, struct Dev **dev)
{
  int i;

  for (i = 0; devtab[i]; i++)
  80050f:	8b 02                	mov    (%edx),%eax
  800511:	85 c0                	test   %eax,%eax
  800513:	75 e7                	jne    8004fc <dev_lookup+0x10>
    if (devtab[i]->dev_id == dev_id) {
      *dev = devtab[i];
      return 0;
    }
  cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800515:	a1 04 40 80 00       	mov    0x804004,%eax
  80051a:	8b 40 48             	mov    0x48(%eax),%eax
  80051d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800521:	89 44 24 04          	mov    %eax,0x4(%esp)
  800525:	c7 04 24 b8 20 80 00 	movl   $0x8020b8,(%esp)
  80052c:	e8 3e 0d 00 00       	call   80126f <cprintf>
  *dev = 0;
  800531:	8b 45 0c             	mov    0xc(%ebp),%eax
  800534:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  return -E_INVAL;
  80053a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80053f:	c9                   	leave  
  800540:	c3                   	ret    

00800541 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800541:	55                   	push   %ebp
  800542:	89 e5                	mov    %esp,%ebp
  800544:	56                   	push   %esi
  800545:	53                   	push   %ebx
  800546:	83 ec 20             	sub    $0x20,%esp
  800549:	8b 75 08             	mov    0x8(%ebp),%esi
  80054c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct Fd *fd2;
  struct Dev *dev;
  int r;

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80054f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800552:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  800556:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80055c:	c1 e8 0c             	shr    $0xc,%eax
{
  struct Fd *fd2;
  struct Dev *dev;
  int r;

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80055f:	89 04 24             	mov    %eax,(%esp)
  800562:	e8 2f ff ff ff       	call   800496 <fd_lookup>
  800567:	85 c0                	test   %eax,%eax
  800569:	78 05                	js     800570 <fd_close+0x2f>
      || fd != fd2)
  80056b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80056e:	74 0c                	je     80057c <fd_close+0x3b>
    return must_exist ? r : 0;
  800570:	84 db                	test   %bl,%bl
  800572:	ba 00 00 00 00       	mov    $0x0,%edx
  800577:	0f 44 c2             	cmove  %edx,%eax
  80057a:	eb 3f                	jmp    8005bb <fd_close+0x7a>
  if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80057c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80057f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800583:	8b 06                	mov    (%esi),%eax
  800585:	89 04 24             	mov    %eax,(%esp)
  800588:	e8 5f ff ff ff       	call   8004ec <dev_lookup>
  80058d:	89 c3                	mov    %eax,%ebx
  80058f:	85 c0                	test   %eax,%eax
  800591:	78 16                	js     8005a9 <fd_close+0x68>
    if (dev->dev_close)
  800593:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800596:	8b 40 10             	mov    0x10(%eax),%eax
      r = (*dev->dev_close)(fd);
    else
      r = 0;
  800599:	bb 00 00 00 00       	mov    $0x0,%ebx

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
      || fd != fd2)
    return must_exist ? r : 0;
  if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
    if (dev->dev_close)
  80059e:	85 c0                	test   %eax,%eax
  8005a0:	74 07                	je     8005a9 <fd_close+0x68>
      r = (*dev->dev_close)(fd);
  8005a2:	89 34 24             	mov    %esi,(%esp)
  8005a5:	ff d0                	call   *%eax
  8005a7:	89 c3                	mov    %eax,%ebx
    else
      r = 0;
  }
  // Make sure fd is unmapped.  Might be a no-op if
  // (*dev->dev_close)(fd) already unmapped it.
  (void)sys_page_unmap(0, fd);
  8005a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005b4:	e8 75 fc ff ff       	call   80022e <sys_page_unmap>
  return r;
  8005b9:	89 d8                	mov    %ebx,%eax
}
  8005bb:	83 c4 20             	add    $0x20,%esp
  8005be:	5b                   	pop    %ebx
  8005bf:	5e                   	pop    %esi
  8005c0:	5d                   	pop    %ebp
  8005c1:	c3                   	ret    

008005c2 <close>:
  return -E_INVAL;
}

int
close(int fdnum)
{
  8005c2:	55                   	push   %ebp
  8005c3:	89 e5                	mov    %esp,%ebp
  8005c5:	83 ec 28             	sub    $0x28,%esp
  struct Fd *fd;
  int r;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d2:	89 04 24             	mov    %eax,(%esp)
  8005d5:	e8 bc fe ff ff       	call   800496 <fd_lookup>
  8005da:	89 c2                	mov    %eax,%edx
  8005dc:	85 d2                	test   %edx,%edx
  8005de:	78 13                	js     8005f3 <close+0x31>
    return r;
  else
    return fd_close(fd, 1);
  8005e0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8005e7:	00 
  8005e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005eb:	89 04 24             	mov    %eax,(%esp)
  8005ee:	e8 4e ff ff ff       	call   800541 <fd_close>
}
  8005f3:	c9                   	leave  
  8005f4:	c3                   	ret    

008005f5 <close_all>:

void
close_all(void)
{
  8005f5:	55                   	push   %ebp
  8005f6:	89 e5                	mov    %esp,%ebp
  8005f8:	53                   	push   %ebx
  8005f9:	83 ec 14             	sub    $0x14,%esp
  int i;

  for (i = 0; i < MAXFD; i++)
  8005fc:	bb 00 00 00 00       	mov    $0x0,%ebx
    close(i);
  800601:	89 1c 24             	mov    %ebx,(%esp)
  800604:	e8 b9 ff ff ff       	call   8005c2 <close>
void
close_all(void)
{
  int i;

  for (i = 0; i < MAXFD; i++)
  800609:	83 c3 01             	add    $0x1,%ebx
  80060c:	83 fb 20             	cmp    $0x20,%ebx
  80060f:	75 f0                	jne    800601 <close_all+0xc>
    close(i);
}
  800611:	83 c4 14             	add    $0x14,%esp
  800614:	5b                   	pop    %ebx
  800615:	5d                   	pop    %ebp
  800616:	c3                   	ret    

00800617 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800617:	55                   	push   %ebp
  800618:	89 e5                	mov    %esp,%ebp
  80061a:	57                   	push   %edi
  80061b:	56                   	push   %esi
  80061c:	53                   	push   %ebx
  80061d:	83 ec 3c             	sub    $0x3c,%esp
  int r;
  char *ova, *nva;
  pte_t pte;
  struct Fd *oldfd, *newfd;

  if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800620:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800623:	89 44 24 04          	mov    %eax,0x4(%esp)
  800627:	8b 45 08             	mov    0x8(%ebp),%eax
  80062a:	89 04 24             	mov    %eax,(%esp)
  80062d:	e8 64 fe ff ff       	call   800496 <fd_lookup>
  800632:	89 c2                	mov    %eax,%edx
  800634:	85 d2                	test   %edx,%edx
  800636:	0f 88 e1 00 00 00    	js     80071d <dup+0x106>
    return r;
  close(newfdnum);
  80063c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80063f:	89 04 24             	mov    %eax,(%esp)
  800642:	e8 7b ff ff ff       	call   8005c2 <close>

  newfd = INDEX2FD(newfdnum);
  800647:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80064a:	c1 e3 0c             	shl    $0xc,%ebx
  80064d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
  ova = fd2data(oldfd);
  800653:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800656:	89 04 24             	mov    %eax,(%esp)
  800659:	e8 d2 fd ff ff       	call   800430 <fd2data>
  80065e:	89 c6                	mov    %eax,%esi
  nva = fd2data(newfd);
  800660:	89 1c 24             	mov    %ebx,(%esp)
  800663:	e8 c8 fd ff ff       	call   800430 <fd2data>
  800668:	89 c7                	mov    %eax,%edi

  if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80066a:	89 f0                	mov    %esi,%eax
  80066c:	c1 e8 16             	shr    $0x16,%eax
  80066f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800676:	a8 01                	test   $0x1,%al
  800678:	74 43                	je     8006bd <dup+0xa6>
  80067a:	89 f0                	mov    %esi,%eax
  80067c:	c1 e8 0c             	shr    $0xc,%eax
  80067f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800686:	f6 c2 01             	test   $0x1,%dl
  800689:	74 32                	je     8006bd <dup+0xa6>
    if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80068b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800692:	25 07 0e 00 00       	and    $0xe07,%eax
  800697:	89 44 24 10          	mov    %eax,0x10(%esp)
  80069b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80069f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006a6:	00 
  8006a7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006b2:	e8 24 fb ff ff       	call   8001db <sys_page_map>
  8006b7:	89 c6                	mov    %eax,%esi
  8006b9:	85 c0                	test   %eax,%eax
  8006bb:	78 3e                	js     8006fb <dup+0xe4>
      goto err;
  if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006c0:	89 c2                	mov    %eax,%edx
  8006c2:	c1 ea 0c             	shr    $0xc,%edx
  8006c5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006cc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8006d2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006d6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006da:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006e1:	00 
  8006e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006ed:	e8 e9 fa ff ff       	call   8001db <sys_page_map>
  8006f2:	89 c6                	mov    %eax,%esi
    goto err;

  return newfdnum;
  8006f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  nva = fd2data(newfd);

  if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
    if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
      goto err;
  if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006f7:	85 f6                	test   %esi,%esi
  8006f9:	79 22                	jns    80071d <dup+0x106>
    goto err;

  return newfdnum;

err:
  sys_page_unmap(0, newfd);
  8006fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800706:	e8 23 fb ff ff       	call   80022e <sys_page_unmap>
  sys_page_unmap(0, nva);
  80070b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80070f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800716:	e8 13 fb ff ff       	call   80022e <sys_page_unmap>
  return r;
  80071b:	89 f0                	mov    %esi,%eax
}
  80071d:	83 c4 3c             	add    $0x3c,%esp
  800720:	5b                   	pop    %ebx
  800721:	5e                   	pop    %esi
  800722:	5f                   	pop    %edi
  800723:	5d                   	pop    %ebp
  800724:	c3                   	ret    

00800725 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800725:	55                   	push   %ebp
  800726:	89 e5                	mov    %esp,%ebp
  800728:	53                   	push   %ebx
  800729:	83 ec 24             	sub    $0x24,%esp
  80072c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  80072f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800732:	89 44 24 04          	mov    %eax,0x4(%esp)
  800736:	89 1c 24             	mov    %ebx,(%esp)
  800739:	e8 58 fd ff ff       	call   800496 <fd_lookup>
  80073e:	89 c2                	mov    %eax,%edx
  800740:	85 d2                	test   %edx,%edx
  800742:	78 6d                	js     8007b1 <read+0x8c>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800744:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800747:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80074e:	8b 00                	mov    (%eax),%eax
  800750:	89 04 24             	mov    %eax,(%esp)
  800753:	e8 94 fd ff ff       	call   8004ec <dev_lookup>
  800758:	85 c0                	test   %eax,%eax
  80075a:	78 55                	js     8007b1 <read+0x8c>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80075c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80075f:	8b 50 08             	mov    0x8(%eax),%edx
  800762:	83 e2 03             	and    $0x3,%edx
  800765:	83 fa 01             	cmp    $0x1,%edx
  800768:	75 23                	jne    80078d <read+0x68>
    cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80076a:	a1 04 40 80 00       	mov    0x804004,%eax
  80076f:	8b 40 48             	mov    0x48(%eax),%eax
  800772:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800776:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077a:	c7 04 24 f9 20 80 00 	movl   $0x8020f9,(%esp)
  800781:	e8 e9 0a 00 00       	call   80126f <cprintf>
    return -E_INVAL;
  800786:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80078b:	eb 24                	jmp    8007b1 <read+0x8c>
  }
  if (!dev->dev_read)
  80078d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800790:	8b 52 08             	mov    0x8(%edx),%edx
  800793:	85 d2                	test   %edx,%edx
  800795:	74 15                	je     8007ac <read+0x87>
    return -E_NOT_SUPP;
  return (*dev->dev_read)(fd, buf, n);
  800797:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80079a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80079e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007a5:	89 04 24             	mov    %eax,(%esp)
  8007a8:	ff d2                	call   *%edx
  8007aa:	eb 05                	jmp    8007b1 <read+0x8c>
  if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
    cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  if (!dev->dev_read)
    return -E_NOT_SUPP;
  8007ac:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_read)(fd, buf, n);
}
  8007b1:	83 c4 24             	add    $0x24,%esp
  8007b4:	5b                   	pop    %ebx
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	57                   	push   %edi
  8007bb:	56                   	push   %esi
  8007bc:	53                   	push   %ebx
  8007bd:	83 ec 1c             	sub    $0x1c,%esp
  8007c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007c3:	8b 75 10             	mov    0x10(%ebp),%esi
  int m, tot;

  for (tot = 0; tot < n; tot += m) {
  8007c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007cb:	eb 23                	jmp    8007f0 <readn+0x39>
    m = read(fdnum, (char*)buf + tot, n - tot);
  8007cd:	89 f0                	mov    %esi,%eax
  8007cf:	29 d8                	sub    %ebx,%eax
  8007d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d5:	89 d8                	mov    %ebx,%eax
  8007d7:	03 45 0c             	add    0xc(%ebp),%eax
  8007da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007de:	89 3c 24             	mov    %edi,(%esp)
  8007e1:	e8 3f ff ff ff       	call   800725 <read>
    if (m < 0)
  8007e6:	85 c0                	test   %eax,%eax
  8007e8:	78 10                	js     8007fa <readn+0x43>
      return m;
    if (m == 0)
  8007ea:	85 c0                	test   %eax,%eax
  8007ec:	74 0a                	je     8007f8 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
  int m, tot;

  for (tot = 0; tot < n; tot += m) {
  8007ee:	01 c3                	add    %eax,%ebx
  8007f0:	39 f3                	cmp    %esi,%ebx
  8007f2:	72 d9                	jb     8007cd <readn+0x16>
  8007f4:	89 d8                	mov    %ebx,%eax
  8007f6:	eb 02                	jmp    8007fa <readn+0x43>
  8007f8:	89 d8                	mov    %ebx,%eax
      return m;
    if (m == 0)
      break;
  }
  return tot;
}
  8007fa:	83 c4 1c             	add    $0x1c,%esp
  8007fd:	5b                   	pop    %ebx
  8007fe:	5e                   	pop    %esi
  8007ff:	5f                   	pop    %edi
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	53                   	push   %ebx
  800806:	83 ec 24             	sub    $0x24,%esp
  800809:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  80080c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80080f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800813:	89 1c 24             	mov    %ebx,(%esp)
  800816:	e8 7b fc ff ff       	call   800496 <fd_lookup>
  80081b:	89 c2                	mov    %eax,%edx
  80081d:	85 d2                	test   %edx,%edx
  80081f:	78 68                	js     800889 <write+0x87>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800821:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800824:	89 44 24 04          	mov    %eax,0x4(%esp)
  800828:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80082b:	8b 00                	mov    (%eax),%eax
  80082d:	89 04 24             	mov    %eax,(%esp)
  800830:	e8 b7 fc ff ff       	call   8004ec <dev_lookup>
  800835:	85 c0                	test   %eax,%eax
  800837:	78 50                	js     800889 <write+0x87>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800839:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80083c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800840:	75 23                	jne    800865 <write+0x63>
    cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800842:	a1 04 40 80 00       	mov    0x804004,%eax
  800847:	8b 40 48             	mov    0x48(%eax),%eax
  80084a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80084e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800852:	c7 04 24 15 21 80 00 	movl   $0x802115,(%esp)
  800859:	e8 11 0a 00 00       	call   80126f <cprintf>
    return -E_INVAL;
  80085e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800863:	eb 24                	jmp    800889 <write+0x87>
  }
  if (debug)
    cprintf("write %d %p %d via dev %s\n",
            fdnum, buf, n, dev->dev_name);
  if (!dev->dev_write)
  800865:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800868:	8b 52 0c             	mov    0xc(%edx),%edx
  80086b:	85 d2                	test   %edx,%edx
  80086d:	74 15                	je     800884 <write+0x82>
    return -E_NOT_SUPP;
  return (*dev->dev_write)(fd, buf, n);
  80086f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800872:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800876:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800879:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80087d:	89 04 24             	mov    %eax,(%esp)
  800880:	ff d2                	call   *%edx
  800882:	eb 05                	jmp    800889 <write+0x87>
  }
  if (debug)
    cprintf("write %d %p %d via dev %s\n",
            fdnum, buf, n, dev->dev_name);
  if (!dev->dev_write)
    return -E_NOT_SUPP;
  800884:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_write)(fd, buf, n);
}
  800889:	83 c4 24             	add    $0x24,%esp
  80088c:	5b                   	pop    %ebx
  80088d:	5d                   	pop    %ebp
  80088e:	c3                   	ret    

0080088f <seek>:

int
seek(int fdnum, off_t offset)
{
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	83 ec 18             	sub    $0x18,%esp
  int r;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  800895:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800898:	89 44 24 04          	mov    %eax,0x4(%esp)
  80089c:	8b 45 08             	mov    0x8(%ebp),%eax
  80089f:	89 04 24             	mov    %eax,(%esp)
  8008a2:	e8 ef fb ff ff       	call   800496 <fd_lookup>
  8008a7:	85 c0                	test   %eax,%eax
  8008a9:	78 0e                	js     8008b9 <seek+0x2a>
    return r;
  fd->fd_offset = offset;
  8008ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b1:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
  8008b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b9:	c9                   	leave  
  8008ba:	c3                   	ret    

008008bb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	53                   	push   %ebx
  8008bf:	83 ec 24             	sub    $0x24,%esp
  8008c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  8008c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008cc:	89 1c 24             	mov    %ebx,(%esp)
  8008cf:	e8 c2 fb ff ff       	call   800496 <fd_lookup>
  8008d4:	89 c2                	mov    %eax,%edx
  8008d6:	85 d2                	test   %edx,%edx
  8008d8:	78 61                	js     80093b <ftruncate+0x80>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008e4:	8b 00                	mov    (%eax),%eax
  8008e6:	89 04 24             	mov    %eax,(%esp)
  8008e9:	e8 fe fb ff ff       	call   8004ec <dev_lookup>
  8008ee:	85 c0                	test   %eax,%eax
  8008f0:	78 49                	js     80093b <ftruncate+0x80>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008f5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008f9:	75 23                	jne    80091e <ftruncate+0x63>
    cprintf("[%08x] ftruncate %d -- bad mode\n",
            thisenv->env_id, fdnum);
  8008fb:	a1 04 40 80 00       	mov    0x804004,%eax

  if ((r = fd_lookup(fdnum, &fd)) < 0
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
    cprintf("[%08x] ftruncate %d -- bad mode\n",
  800900:	8b 40 48             	mov    0x48(%eax),%eax
  800903:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800907:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090b:	c7 04 24 d8 20 80 00 	movl   $0x8020d8,(%esp)
  800912:	e8 58 09 00 00       	call   80126f <cprintf>
            thisenv->env_id, fdnum);
    return -E_INVAL;
  800917:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80091c:	eb 1d                	jmp    80093b <ftruncate+0x80>
  }
  if (!dev->dev_trunc)
  80091e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800921:	8b 52 18             	mov    0x18(%edx),%edx
  800924:	85 d2                	test   %edx,%edx
  800926:	74 0e                	je     800936 <ftruncate+0x7b>
    return -E_NOT_SUPP;
  return (*dev->dev_trunc)(fd, newsize);
  800928:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80092f:	89 04 24             	mov    %eax,(%esp)
  800932:	ff d2                	call   *%edx
  800934:	eb 05                	jmp    80093b <ftruncate+0x80>
    cprintf("[%08x] ftruncate %d -- bad mode\n",
            thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  if (!dev->dev_trunc)
    return -E_NOT_SUPP;
  800936:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_trunc)(fd, newsize);
}
  80093b:	83 c4 24             	add    $0x24,%esp
  80093e:	5b                   	pop    %ebx
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	53                   	push   %ebx
  800945:	83 ec 24             	sub    $0x24,%esp
  800948:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  80094b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80094e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800952:	8b 45 08             	mov    0x8(%ebp),%eax
  800955:	89 04 24             	mov    %eax,(%esp)
  800958:	e8 39 fb ff ff       	call   800496 <fd_lookup>
  80095d:	89 c2                	mov    %eax,%edx
  80095f:	85 d2                	test   %edx,%edx
  800961:	78 52                	js     8009b5 <fstat+0x74>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800963:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800966:	89 44 24 04          	mov    %eax,0x4(%esp)
  80096a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80096d:	8b 00                	mov    (%eax),%eax
  80096f:	89 04 24             	mov    %eax,(%esp)
  800972:	e8 75 fb ff ff       	call   8004ec <dev_lookup>
  800977:	85 c0                	test   %eax,%eax
  800979:	78 3a                	js     8009b5 <fstat+0x74>
    return r;
  if (!dev->dev_stat)
  80097b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80097e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800982:	74 2c                	je     8009b0 <fstat+0x6f>
    return -E_NOT_SUPP;
  stat->st_name[0] = 0;
  800984:	c6 03 00             	movb   $0x0,(%ebx)
  stat->st_size = 0;
  800987:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80098e:	00 00 00 
  stat->st_isdir = 0;
  800991:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800998:	00 00 00 
  stat->st_dev = dev;
  80099b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
  return (*dev->dev_stat)(fd, stat);
  8009a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009a8:	89 14 24             	mov    %edx,(%esp)
  8009ab:	ff 50 14             	call   *0x14(%eax)
  8009ae:	eb 05                	jmp    8009b5 <fstat+0x74>

  if ((r = fd_lookup(fdnum, &fd)) < 0
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
    return r;
  if (!dev->dev_stat)
    return -E_NOT_SUPP;
  8009b0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  stat->st_name[0] = 0;
  stat->st_size = 0;
  stat->st_isdir = 0;
  stat->st_dev = dev;
  return (*dev->dev_stat)(fd, stat);
}
  8009b5:	83 c4 24             	add    $0x24,%esp
  8009b8:	5b                   	pop    %ebx
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	56                   	push   %esi
  8009bf:	53                   	push   %ebx
  8009c0:	83 ec 10             	sub    $0x10,%esp
  int fd, r;

  if ((fd = open(path, O_RDONLY)) < 0)
  8009c3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8009ca:	00 
  8009cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ce:	89 04 24             	mov    %eax,(%esp)
  8009d1:	e8 d2 01 00 00       	call   800ba8 <open>
  8009d6:	89 c3                	mov    %eax,%ebx
  8009d8:	85 db                	test   %ebx,%ebx
  8009da:	78 1b                	js     8009f7 <stat+0x3c>
    return fd;
  r = fstat(fd, stat);
  8009dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e3:	89 1c 24             	mov    %ebx,(%esp)
  8009e6:	e8 56 ff ff ff       	call   800941 <fstat>
  8009eb:	89 c6                	mov    %eax,%esi
  close(fd);
  8009ed:	89 1c 24             	mov    %ebx,(%esp)
  8009f0:	e8 cd fb ff ff       	call   8005c2 <close>
  return r;
  8009f5:	89 f0                	mov    %esi,%eax
}
  8009f7:	83 c4 10             	add    $0x10,%esp
  8009fa:	5b                   	pop    %ebx
  8009fb:	5e                   	pop    %esi
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	56                   	push   %esi
  800a02:	53                   	push   %ebx
  800a03:	83 ec 10             	sub    $0x10,%esp
  800a06:	89 c6                	mov    %eax,%esi
  800a08:	89 d3                	mov    %edx,%ebx
  static envid_t fsenv;

  if (fsenv == 0)
  800a0a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800a11:	75 11                	jne    800a24 <fsipc+0x26>
    fsenv = ipc_find_env(ENV_TYPE_FS);
  800a13:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a1a:	e8 41 13 00 00       	call   801d60 <ipc_find_env>
  800a1f:	a3 00 40 80 00       	mov    %eax,0x804000
  static_assert(sizeof(fsipcbuf) == PGSIZE);

  if (debug)
    cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t*)&fsipcbuf);

  ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a24:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a2b:	00 
  800a2c:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a33:	00 
  800a34:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a38:	a1 00 40 80 00       	mov    0x804000,%eax
  800a3d:	89 04 24             	mov    %eax,(%esp)
  800a40:	e8 b0 12 00 00       	call   801cf5 <ipc_send>
  return ipc_recv(NULL, dstva, NULL);
  800a45:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a4c:	00 
  800a4d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a58:	e8 12 12 00 00       	call   801c6f <ipc_recv>
}
  800a5d:	83 c4 10             	add    $0x10,%esp
  800a60:	5b                   	pop    %ebx
  800a61:	5e                   	pop    %esi
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    

00800a64 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	83 ec 08             	sub    $0x8,%esp
  fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a70:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.set_size.req_size = newsize;
  800a75:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a78:	a3 04 50 80 00       	mov    %eax,0x805004
  return fsipc(FSREQ_SET_SIZE, NULL);
  800a7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a82:	b8 02 00 00 00       	mov    $0x2,%eax
  800a87:	e8 72 ff ff ff       	call   8009fe <fsipc>
}
  800a8c:	c9                   	leave  
  800a8d:	c3                   	ret    

00800a8e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	83 ec 08             	sub    $0x8,%esp
  fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a94:	8b 45 08             	mov    0x8(%ebp),%eax
  800a97:	8b 40 0c             	mov    0xc(%eax),%eax
  800a9a:	a3 00 50 80 00       	mov    %eax,0x805000
  return fsipc(FSREQ_FLUSH, NULL);
  800a9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa4:	b8 06 00 00 00       	mov    $0x6,%eax
  800aa9:	e8 50 ff ff ff       	call   8009fe <fsipc>
}
  800aae:	c9                   	leave  
  800aaf:	c3                   	ret    

00800ab0 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	53                   	push   %ebx
  800ab4:	83 ec 14             	sub    $0x14,%esp
  800ab7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int r;

  fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800aba:	8b 45 08             	mov    0x8(%ebp),%eax
  800abd:	8b 40 0c             	mov    0xc(%eax),%eax
  800ac0:	a3 00 50 80 00       	mov    %eax,0x805000
  if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800ac5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aca:	b8 05 00 00 00       	mov    $0x5,%eax
  800acf:	e8 2a ff ff ff       	call   8009fe <fsipc>
  800ad4:	89 c2                	mov    %eax,%edx
  800ad6:	85 d2                	test   %edx,%edx
  800ad8:	78 2b                	js     800b05 <devfile_stat+0x55>
    return r;
  strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800ada:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800ae1:	00 
  800ae2:	89 1c 24             	mov    %ebx,(%esp)
  800ae5:	e8 ad 0d 00 00       	call   801897 <strcpy>
  st->st_size = fsipcbuf.statRet.ret_size;
  800aea:	a1 80 50 80 00       	mov    0x805080,%eax
  800aef:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800af5:	a1 84 50 80 00       	mov    0x805084,%eax
  800afa:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  return 0;
  800b00:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b05:	83 c4 14             	add    $0x14,%esp
  800b08:	5b                   	pop    %ebx
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	83 ec 18             	sub    $0x18,%esp
  800b11:	8b 45 10             	mov    0x10(%ebp),%eax
  // remember that write is always allowed to write *fewer*
  // bytes than requested.
  // LAB 5: Your code here
    int r;

    fsipcbuf.write.req_fileid = fd->fd_file.id;
  800b14:	8b 55 08             	mov    0x8(%ebp),%edx
  800b17:	8b 52 0c             	mov    0xc(%edx),%edx
  800b1a:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  800b20:	a3 04 50 80 00       	mov    %eax,0x805004

    size_t max_written = sizeof(fsipcbuf.write.req_buf);
    memmove(fsipcbuf.write.req_buf, buf, MIN(max_written, n));
  800b25:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800b2a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800b2f:	0f 47 c2             	cmova  %edx,%eax
  800b32:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b36:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b39:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b3d:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800b44:	e8 eb 0e 00 00       	call   801a34 <memmove>

    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800b49:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4e:	b8 04 00 00 00       	mov    $0x4,%eax
  800b53:	e8 a6 fe ff ff       	call   8009fe <fsipc>
        return r;

    return r;
}
  800b58:	c9                   	leave  
  800b59:	c3                   	ret    

00800b5a <devfile_read>:
// Returns:
//  The number of bytes successfully read.
//  < 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	53                   	push   %ebx
  800b5e:	83 ec 14             	sub    $0x14,%esp
  // filling fsipcbuf.read with the request arguments.  The
  // bytes read will be written back to fsipcbuf by the file
  // system server.
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b61:	8b 45 08             	mov    0x8(%ebp),%eax
  800b64:	8b 40 0c             	mov    0xc(%eax),%eax
  800b67:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  800b6c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b6f:	a3 04 50 80 00       	mov    %eax,0x805004
  if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b74:	ba 00 00 00 00       	mov    $0x0,%edx
  800b79:	b8 03 00 00 00       	mov    $0x3,%eax
  800b7e:	e8 7b fe ff ff       	call   8009fe <fsipc>
  800b83:	89 c3                	mov    %eax,%ebx
  800b85:	85 c0                	test   %eax,%eax
  800b87:	78 17                	js     800ba0 <devfile_read+0x46>
    return r;

  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b89:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b8d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800b94:	00 
  800b95:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b98:	89 04 24             	mov    %eax,(%esp)
  800b9b:	e8 94 0e 00 00       	call   801a34 <memmove>
  return r;
}
  800ba0:	89 d8                	mov    %ebx,%eax
  800ba2:	83 c4 14             	add    $0x14,%esp
  800ba5:	5b                   	pop    %ebx
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    

00800ba8 <open>:
//  The file descriptor index on success
//  -E_BAD_PATH if the path is too long (>= MAXPATHLEN)
//  < 0 for other errors.
int
open(const char *path, int mode)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	53                   	push   %ebx
  800bac:	83 ec 24             	sub    $0x24,%esp
  800baf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  // file descriptor.

  int r;
  struct Fd *fd;

  if (strlen(path) >= MAXPATHLEN)
  800bb2:	89 1c 24             	mov    %ebx,(%esp)
  800bb5:	e8 a6 0c 00 00       	call   801860 <strlen>
  800bba:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800bbf:	7f 60                	jg     800c21 <open+0x79>
    return -E_BAD_PATH;

  if ((r = fd_alloc(&fd)) < 0)
  800bc1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bc4:	89 04 24             	mov    %eax,(%esp)
  800bc7:	e8 7b f8 ff ff       	call   800447 <fd_alloc>
  800bcc:	89 c2                	mov    %eax,%edx
  800bce:	85 d2                	test   %edx,%edx
  800bd0:	78 54                	js     800c26 <open+0x7e>
    return r;

  strcpy(fsipcbuf.open.req_path, path);
  800bd2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bd6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800bdd:	e8 b5 0c 00 00       	call   801897 <strcpy>
  fsipcbuf.open.req_omode = mode;
  800be2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be5:	a3 00 54 80 00       	mov    %eax,0x805400

  if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800bea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bed:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf2:	e8 07 fe ff ff       	call   8009fe <fsipc>
  800bf7:	89 c3                	mov    %eax,%ebx
  800bf9:	85 c0                	test   %eax,%eax
  800bfb:	79 17                	jns    800c14 <open+0x6c>
    fd_close(fd, 0);
  800bfd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800c04:	00 
  800c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c08:	89 04 24             	mov    %eax,(%esp)
  800c0b:	e8 31 f9 ff ff       	call   800541 <fd_close>
    return r;
  800c10:	89 d8                	mov    %ebx,%eax
  800c12:	eb 12                	jmp    800c26 <open+0x7e>
  }

  return fd2num(fd);
  800c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c17:	89 04 24             	mov    %eax,(%esp)
  800c1a:	e8 01 f8 ff ff       	call   800420 <fd2num>
  800c1f:	eb 05                	jmp    800c26 <open+0x7e>

  int r;
  struct Fd *fd;

  if (strlen(path) >= MAXPATHLEN)
    return -E_BAD_PATH;
  800c21:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
    fd_close(fd, 0);
    return r;
  }

  return fd2num(fd);
}
  800c26:	83 c4 24             	add    $0x24,%esp
  800c29:	5b                   	pop    %ebx
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	83 ec 08             	sub    $0x8,%esp
  // Ask the file server to update the disk
  // by writing any dirty blocks in the buffer cache.

  return fsipc(FSREQ_SYNC, NULL);
  800c32:	ba 00 00 00 00       	mov    $0x0,%edx
  800c37:	b8 08 00 00 00       	mov    $0x8,%eax
  800c3c:	e8 bd fd ff ff       	call   8009fe <fsipc>
}
  800c41:	c9                   	leave  
  800c42:	c3                   	ret    

00800c43 <devpipe_stat>:
  return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	83 ec 10             	sub    $0x10,%esp
  800c4b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct Pipe *p = (struct Pipe*)fd2data(fd);
  800c4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c51:	89 04 24             	mov    %eax,(%esp)
  800c54:	e8 d7 f7 ff ff       	call   800430 <fd2data>
  800c59:	89 c6                	mov    %eax,%esi

  strcpy(stat->st_name, "<pipe>");
  800c5b:	c7 44 24 04 44 21 80 	movl   $0x802144,0x4(%esp)
  800c62:	00 
  800c63:	89 1c 24             	mov    %ebx,(%esp)
  800c66:	e8 2c 0c 00 00       	call   801897 <strcpy>
  stat->st_size = p->p_wpos - p->p_rpos;
  800c6b:	8b 46 04             	mov    0x4(%esi),%eax
  800c6e:	2b 06                	sub    (%esi),%eax
  800c70:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  stat->st_isdir = 0;
  800c76:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c7d:	00 00 00 
  stat->st_dev = &devpipe;
  800c80:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800c87:	30 80 00 
  return 0;
}
  800c8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c8f:	83 c4 10             	add    $0x10,%esp
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5d                   	pop    %ebp
  800c95:	c3                   	ret    

00800c96 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	53                   	push   %ebx
  800c9a:	83 ec 14             	sub    $0x14,%esp
  800c9d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  (void)sys_page_unmap(0, fd);
  800ca0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ca4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cab:	e8 7e f5 ff ff       	call   80022e <sys_page_unmap>
  return sys_page_unmap(0, fd2data(fd));
  800cb0:	89 1c 24             	mov    %ebx,(%esp)
  800cb3:	e8 78 f7 ff ff       	call   800430 <fd2data>
  800cb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cbc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cc3:	e8 66 f5 ff ff       	call   80022e <sys_page_unmap>
}
  800cc8:	83 c4 14             	add    $0x14,%esp
  800ccb:	5b                   	pop    %ebx
  800ccc:	5d                   	pop    %ebp
  800ccd:	c3                   	ret    

00800cce <_pipeisclosed>:
  return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
  800cd4:	83 ec 2c             	sub    $0x2c,%esp
  800cd7:	89 c6                	mov    %eax,%esi
  800cd9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  int n, nn, ret;

  while (1) {
    n = thisenv->env_runs;
  800cdc:	a1 04 40 80 00       	mov    0x804004,%eax
  800ce1:	8b 58 58             	mov    0x58(%eax),%ebx
    ret = pageref(fd) == pageref(p);
  800ce4:	89 34 24             	mov    %esi,(%esp)
  800ce7:	e8 ac 10 00 00       	call   801d98 <pageref>
  800cec:	89 c7                	mov    %eax,%edi
  800cee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cf1:	89 04 24             	mov    %eax,(%esp)
  800cf4:	e8 9f 10 00 00       	call   801d98 <pageref>
  800cf9:	39 c7                	cmp    %eax,%edi
  800cfb:	0f 94 c2             	sete   %dl
  800cfe:	0f b6 c2             	movzbl %dl,%eax
    nn = thisenv->env_runs;
  800d01:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  800d07:	8b 79 58             	mov    0x58(%ecx),%edi
    if (n == nn)
  800d0a:	39 fb                	cmp    %edi,%ebx
  800d0c:	74 21                	je     800d2f <_pipeisclosed+0x61>
      return ret;
    if (n != nn && ret == 1)
  800d0e:	84 d2                	test   %dl,%dl
  800d10:	74 ca                	je     800cdc <_pipeisclosed+0xe>
      cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800d12:	8b 51 58             	mov    0x58(%ecx),%edx
  800d15:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d19:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d1d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d21:	c7 04 24 4b 21 80 00 	movl   $0x80214b,(%esp)
  800d28:	e8 42 05 00 00       	call   80126f <cprintf>
  800d2d:	eb ad                	jmp    800cdc <_pipeisclosed+0xe>
  }
}
  800d2f:	83 c4 2c             	add    $0x2c,%esp
  800d32:	5b                   	pop    %ebx
  800d33:	5e                   	pop    %esi
  800d34:	5f                   	pop    %edi
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    

00800d37 <devpipe_write>:
  return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	57                   	push   %edi
  800d3b:	56                   	push   %esi
  800d3c:	53                   	push   %ebx
  800d3d:	83 ec 1c             	sub    $0x1c,%esp
  800d40:	8b 75 08             	mov    0x8(%ebp),%esi
  const uint8_t *buf;
  size_t i;
  struct Pipe *p;

  p = (struct Pipe*)fd2data(fd);
  800d43:	89 34 24             	mov    %esi,(%esp)
  800d46:	e8 e5 f6 ff ff       	call   800430 <fd2data>
  800d4b:	89 c3                	mov    %eax,%ebx
  if (debug)
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  800d4d:	bf 00 00 00 00       	mov    $0x0,%edi
  800d52:	eb 45                	jmp    800d99 <devpipe_write+0x62>
    while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
      // pipe is full
      // if all the readers are gone
      // (it's only writers like us now),
      // note eof
      if (_pipeisclosed(fd, p))
  800d54:	89 da                	mov    %ebx,%edx
  800d56:	89 f0                	mov    %esi,%eax
  800d58:	e8 71 ff ff ff       	call   800cce <_pipeisclosed>
  800d5d:	85 c0                	test   %eax,%eax
  800d5f:	75 41                	jne    800da2 <devpipe_write+0x6b>
        return 0;
      // yield and see what happens
      if (debug)
        cprintf("devpipe_write yield\n");
      sys_yield();
  800d61:	e8 02 f4 ff ff       	call   800168 <sys_yield>
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
    while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800d66:	8b 43 04             	mov    0x4(%ebx),%eax
  800d69:	8b 0b                	mov    (%ebx),%ecx
  800d6b:	8d 51 20             	lea    0x20(%ecx),%edx
  800d6e:	39 d0                	cmp    %edx,%eax
  800d70:	73 e2                	jae    800d54 <devpipe_write+0x1d>
        cprintf("devpipe_write yield\n");
      sys_yield();
    }
    // there's room for a byte.  store it.
    // wait to increment wpos until the byte is stored!
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800d72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d75:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800d79:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800d7c:	99                   	cltd   
  800d7d:	c1 ea 1b             	shr    $0x1b,%edx
  800d80:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  800d83:	83 e1 1f             	and    $0x1f,%ecx
  800d86:	29 d1                	sub    %edx,%ecx
  800d88:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  800d8c:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
    p->p_wpos++;
  800d90:	83 c0 01             	add    $0x1,%eax
  800d93:	89 43 04             	mov    %eax,0x4(%ebx)
  if (debug)
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  800d96:	83 c7 01             	add    $0x1,%edi
  800d99:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800d9c:	75 c8                	jne    800d66 <devpipe_write+0x2f>
    // wait to increment wpos until the byte is stored!
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
    p->p_wpos++;
  }

  return i;
  800d9e:	89 f8                	mov    %edi,%eax
  800da0:	eb 05                	jmp    800da7 <devpipe_write+0x70>
      // pipe is full
      // if all the readers are gone
      // (it's only writers like us now),
      // note eof
      if (_pipeisclosed(fd, p))
        return 0;
  800da2:	b8 00 00 00 00       	mov    $0x0,%eax
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
    p->p_wpos++;
  }

  return i;
}
  800da7:	83 c4 1c             	add    $0x1c,%esp
  800daa:	5b                   	pop    %ebx
  800dab:	5e                   	pop    %esi
  800dac:	5f                   	pop    %edi
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    

00800daf <devpipe_read>:
  return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	57                   	push   %edi
  800db3:	56                   	push   %esi
  800db4:	53                   	push   %ebx
  800db5:	83 ec 1c             	sub    $0x1c,%esp
  800db8:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint8_t *buf;
  size_t i;
  struct Pipe *p;

  p = (struct Pipe*)fd2data(fd);
  800dbb:	89 3c 24             	mov    %edi,(%esp)
  800dbe:	e8 6d f6 ff ff       	call   800430 <fd2data>
  800dc3:	89 c3                	mov    %eax,%ebx
  if (debug)
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  800dc5:	be 00 00 00 00       	mov    $0x0,%esi
  800dca:	eb 3d                	jmp    800e09 <devpipe_read+0x5a>
    while (p->p_rpos == p->p_wpos) {
      // pipe is empty
      // if we got any data, return it
      if (i > 0)
  800dcc:	85 f6                	test   %esi,%esi
  800dce:	74 04                	je     800dd4 <devpipe_read+0x25>
        return i;
  800dd0:	89 f0                	mov    %esi,%eax
  800dd2:	eb 43                	jmp    800e17 <devpipe_read+0x68>
      // if all the writers are gone, note eof
      if (_pipeisclosed(fd, p))
  800dd4:	89 da                	mov    %ebx,%edx
  800dd6:	89 f8                	mov    %edi,%eax
  800dd8:	e8 f1 fe ff ff       	call   800cce <_pipeisclosed>
  800ddd:	85 c0                	test   %eax,%eax
  800ddf:	75 31                	jne    800e12 <devpipe_read+0x63>
        return 0;
      // yield and see what happens
      if (debug)
        cprintf("devpipe_read yield\n");
      sys_yield();
  800de1:	e8 82 f3 ff ff       	call   800168 <sys_yield>
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
    while (p->p_rpos == p->p_wpos) {
  800de6:	8b 03                	mov    (%ebx),%eax
  800de8:	3b 43 04             	cmp    0x4(%ebx),%eax
  800deb:	74 df                	je     800dcc <devpipe_read+0x1d>
        cprintf("devpipe_read yield\n");
      sys_yield();
    }
    // there's a byte.  take it.
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800ded:	99                   	cltd   
  800dee:	c1 ea 1b             	shr    $0x1b,%edx
  800df1:	01 d0                	add    %edx,%eax
  800df3:	83 e0 1f             	and    $0x1f,%eax
  800df6:	29 d0                	sub    %edx,%eax
  800df8:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800dfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e00:	88 04 31             	mov    %al,(%ecx,%esi,1)
    p->p_rpos++;
  800e03:	83 03 01             	addl   $0x1,(%ebx)
  if (debug)
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  800e06:	83 c6 01             	add    $0x1,%esi
  800e09:	3b 75 10             	cmp    0x10(%ebp),%esi
  800e0c:	75 d8                	jne    800de6 <devpipe_read+0x37>
    // there's a byte.  take it.
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
    p->p_rpos++;
  }
  return i;
  800e0e:	89 f0                	mov    %esi,%eax
  800e10:	eb 05                	jmp    800e17 <devpipe_read+0x68>
      // if we got any data, return it
      if (i > 0)
        return i;
      // if all the writers are gone, note eof
      if (_pipeisclosed(fd, p))
        return 0;
  800e12:	b8 00 00 00 00       	mov    $0x0,%eax
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
    p->p_rpos++;
  }
  return i;
}
  800e17:	83 c4 1c             	add    $0x1c,%esp
  800e1a:	5b                   	pop    %ebx
  800e1b:	5e                   	pop    %esi
  800e1c:	5f                   	pop    %edi
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    

00800e1f <pipe>:
  uint8_t p_buf[PIPEBUFSIZ];    // data buffer
};

int
pipe(int pfd[2])
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	56                   	push   %esi
  800e23:	53                   	push   %ebx
  800e24:	83 ec 30             	sub    $0x30,%esp
  int r;
  struct Fd *fd0, *fd1;
  void *va;

  // allocate the file descriptor table entries
  if ((r = fd_alloc(&fd0)) < 0
  800e27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e2a:	89 04 24             	mov    %eax,(%esp)
  800e2d:	e8 15 f6 ff ff       	call   800447 <fd_alloc>
  800e32:	89 c2                	mov    %eax,%edx
  800e34:	85 d2                	test   %edx,%edx
  800e36:	0f 88 4d 01 00 00    	js     800f89 <pipe+0x16a>
      || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e3c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e43:	00 
  800e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e47:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e52:	e8 30 f3 ff ff       	call   800187 <sys_page_alloc>
  800e57:	89 c2                	mov    %eax,%edx
  800e59:	85 d2                	test   %edx,%edx
  800e5b:	0f 88 28 01 00 00    	js     800f89 <pipe+0x16a>
    goto err;

  if ((r = fd_alloc(&fd1)) < 0
  800e61:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e64:	89 04 24             	mov    %eax,(%esp)
  800e67:	e8 db f5 ff ff       	call   800447 <fd_alloc>
  800e6c:	89 c3                	mov    %eax,%ebx
  800e6e:	85 c0                	test   %eax,%eax
  800e70:	0f 88 fe 00 00 00    	js     800f74 <pipe+0x155>
      || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e76:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e7d:	00 
  800e7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e81:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e8c:	e8 f6 f2 ff ff       	call   800187 <sys_page_alloc>
  800e91:	89 c3                	mov    %eax,%ebx
  800e93:	85 c0                	test   %eax,%eax
  800e95:	0f 88 d9 00 00 00    	js     800f74 <pipe+0x155>
    goto err1;

  // allocate the pipe structure as first data page in both
  va = fd2data(fd0);
  800e9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e9e:	89 04 24             	mov    %eax,(%esp)
  800ea1:	e8 8a f5 ff ff       	call   800430 <fd2data>
  800ea6:	89 c6                	mov    %eax,%esi
  if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ea8:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800eaf:	00 
  800eb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eb4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ebb:	e8 c7 f2 ff ff       	call   800187 <sys_page_alloc>
  800ec0:	89 c3                	mov    %eax,%ebx
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	0f 88 97 00 00 00    	js     800f61 <pipe+0x142>
    goto err2;
  if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800eca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ecd:	89 04 24             	mov    %eax,(%esp)
  800ed0:	e8 5b f5 ff ff       	call   800430 <fd2data>
  800ed5:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  800edc:	00 
  800edd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ee1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ee8:	00 
  800ee9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ef4:	e8 e2 f2 ff ff       	call   8001db <sys_page_map>
  800ef9:	89 c3                	mov    %eax,%ebx
  800efb:	85 c0                	test   %eax,%eax
  800efd:	78 52                	js     800f51 <pipe+0x132>
    goto err3;

  // set up fd structures
  fd0->fd_dev_id = devpipe.dev_id;
  800eff:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800f05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f08:	89 10                	mov    %edx,(%eax)
  fd0->fd_omode = O_RDONLY;
  800f0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f0d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

  fd1->fd_dev_id = devpipe.dev_id;
  800f14:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800f1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f1d:	89 10                	mov    %edx,(%eax)
  fd1->fd_omode = O_WRONLY;
  800f1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f22:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

  if (debug)
    cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

  pfd[0] = fd2num(fd0);
  800f29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f2c:	89 04 24             	mov    %eax,(%esp)
  800f2f:	e8 ec f4 ff ff       	call   800420 <fd2num>
  800f34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f37:	89 01                	mov    %eax,(%ecx)
  pfd[1] = fd2num(fd1);
  800f39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f3c:	89 04 24             	mov    %eax,(%esp)
  800f3f:	e8 dc f4 ff ff       	call   800420 <fd2num>
  800f44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f47:	89 41 04             	mov    %eax,0x4(%ecx)
  return 0;
  800f4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4f:	eb 38                	jmp    800f89 <pipe+0x16a>

err3:
  sys_page_unmap(0, va);
  800f51:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f5c:	e8 cd f2 ff ff       	call   80022e <sys_page_unmap>
err2:
  sys_page_unmap(0, fd1);
  800f61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f64:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f68:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f6f:	e8 ba f2 ff ff       	call   80022e <sys_page_unmap>
err1:
  sys_page_unmap(0, fd0);
  800f74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f77:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f7b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f82:	e8 a7 f2 ff ff       	call   80022e <sys_page_unmap>
  800f87:	89 d8                	mov    %ebx,%eax
err:
  return r;
}
  800f89:	83 c4 30             	add    $0x30,%esp
  800f8c:	5b                   	pop    %ebx
  800f8d:	5e                   	pop    %esi
  800f8e:	5d                   	pop    %ebp
  800f8f:	c3                   	ret    

00800f90 <pipeisclosed>:
  }
}

int
pipeisclosed(int fdnum)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	83 ec 28             	sub    $0x28,%esp
  struct Fd *fd;
  struct Pipe *p;
  int r;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f96:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f99:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa0:	89 04 24             	mov    %eax,(%esp)
  800fa3:	e8 ee f4 ff ff       	call   800496 <fd_lookup>
  800fa8:	89 c2                	mov    %eax,%edx
  800faa:	85 d2                	test   %edx,%edx
  800fac:	78 15                	js     800fc3 <pipeisclosed+0x33>
    return r;
  p = (struct Pipe*)fd2data(fd);
  800fae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fb1:	89 04 24             	mov    %eax,(%esp)
  800fb4:	e8 77 f4 ff ff       	call   800430 <fd2data>
  return _pipeisclosed(fd, p);
  800fb9:	89 c2                	mov    %eax,%edx
  800fbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fbe:	e8 0b fd ff ff       	call   800cce <_pipeisclosed>
}
  800fc3:	c9                   	leave  
  800fc4:	c3                   	ret    
  800fc5:	66 90                	xchg   %ax,%ax
  800fc7:	66 90                	xchg   %ax,%ax
  800fc9:	66 90                	xchg   %ax,%ax
  800fcb:	66 90                	xchg   %ax,%ax
  800fcd:	66 90                	xchg   %ax,%ax
  800fcf:	90                   	nop

00800fd0 <devcons_close>:
  return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  USED(fd);

  return 0;
}
  800fd3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd8:	5d                   	pop    %ebp
  800fd9:	c3                   	ret    

00800fda <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800fda:	55                   	push   %ebp
  800fdb:	89 e5                	mov    %esp,%ebp
  800fdd:	83 ec 18             	sub    $0x18,%esp
  strcpy(stat->st_name, "<cons>");
  800fe0:	c7 44 24 04 63 21 80 	movl   $0x802163,0x4(%esp)
  800fe7:	00 
  800fe8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800feb:	89 04 24             	mov    %eax,(%esp)
  800fee:	e8 a4 08 00 00       	call   801897 <strcpy>
  return 0;
}
  800ff3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff8:	c9                   	leave  
  800ff9:	c3                   	ret    

00800ffa <devcons_write>:
  return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ffa:	55                   	push   %ebp
  800ffb:	89 e5                	mov    %esp,%ebp
  800ffd:	57                   	push   %edi
  800ffe:	56                   	push   %esi
  800fff:	53                   	push   %ebx
  801000:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  801006:	bb 00 00 00 00       	mov    $0x0,%ebx
    m = n - tot;
    if (m > sizeof(buf) - 1)
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
  80100b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  801011:	eb 31                	jmp    801044 <devcons_write+0x4a>
    m = n - tot;
  801013:	8b 75 10             	mov    0x10(%ebp),%esi
  801016:	29 de                	sub    %ebx,%esi
    if (m > sizeof(buf) - 1)
  801018:	83 fe 7f             	cmp    $0x7f,%esi
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
    m = n - tot;
  80101b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801020:	0f 47 f2             	cmova  %edx,%esi
    if (m > sizeof(buf) - 1)
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
  801023:	89 74 24 08          	mov    %esi,0x8(%esp)
  801027:	03 45 0c             	add    0xc(%ebp),%eax
  80102a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80102e:	89 3c 24             	mov    %edi,(%esp)
  801031:	e8 fe 09 00 00       	call   801a34 <memmove>
    sys_cputs(buf, m);
  801036:	89 74 24 04          	mov    %esi,0x4(%esp)
  80103a:	89 3c 24             	mov    %edi,(%esp)
  80103d:	e8 78 f0 ff ff       	call   8000ba <sys_cputs>
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  801042:	01 f3                	add    %esi,%ebx
  801044:	89 d8                	mov    %ebx,%eax
  801046:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801049:	72 c8                	jb     801013 <devcons_write+0x19>
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
    sys_cputs(buf, m);
  }
  return tot;
}
  80104b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801051:	5b                   	pop    %ebx
  801052:	5e                   	pop    %esi
  801053:	5f                   	pop    %edi
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    

00801056 <devcons_read>:
  return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	83 ec 08             	sub    $0x8,%esp
  int c;

  if (n == 0)
    return 0;
  80105c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  int c;

  if (n == 0)
  801061:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801065:	75 07                	jne    80106e <devcons_read+0x18>
  801067:	eb 2a                	jmp    801093 <devcons_read+0x3d>
    return 0;

  while ((c = sys_cgetc()) == 0)
    sys_yield();
  801069:	e8 fa f0 ff ff       	call   800168 <sys_yield>
  int c;

  if (n == 0)
    return 0;

  while ((c = sys_cgetc()) == 0)
  80106e:	66 90                	xchg   %ax,%ax
  801070:	e8 63 f0 ff ff       	call   8000d8 <sys_cgetc>
  801075:	85 c0                	test   %eax,%eax
  801077:	74 f0                	je     801069 <devcons_read+0x13>
    sys_yield();
  if (c < 0)
  801079:	85 c0                	test   %eax,%eax
  80107b:	78 16                	js     801093 <devcons_read+0x3d>
    return c;
  if (c == 0x04)        // ctl-d is eof
  80107d:	83 f8 04             	cmp    $0x4,%eax
  801080:	74 0c                	je     80108e <devcons_read+0x38>
    return 0;
  *(char*)vbuf = c;
  801082:	8b 55 0c             	mov    0xc(%ebp),%edx
  801085:	88 02                	mov    %al,(%edx)
  return 1;
  801087:	b8 01 00 00 00       	mov    $0x1,%eax
  80108c:	eb 05                	jmp    801093 <devcons_read+0x3d>
  while ((c = sys_cgetc()) == 0)
    sys_yield();
  if (c < 0)
    return c;
  if (c == 0x04)        // ctl-d is eof
    return 0;
  80108e:	b8 00 00 00 00       	mov    $0x0,%eax
  *(char*)vbuf = c;
  return 1;
}
  801093:	c9                   	leave  
  801094:	c3                   	ret    

00801095 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	83 ec 28             	sub    $0x28,%esp
  char c = ch;
  80109b:	8b 45 08             	mov    0x8(%ebp),%eax
  80109e:	88 45 f7             	mov    %al,-0x9(%ebp)

  // Unlike standard Unix's putchar,
  // the cputchar function _always_ outputs to the system console.
  sys_cputs(&c, 1);
  8010a1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010a8:	00 
  8010a9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010ac:	89 04 24             	mov    %eax,(%esp)
  8010af:	e8 06 f0 ff ff       	call   8000ba <sys_cputs>
}
  8010b4:	c9                   	leave  
  8010b5:	c3                   	ret    

008010b6 <getchar>:

int
getchar(void)
{
  8010b6:	55                   	push   %ebp
  8010b7:	89 e5                	mov    %esp,%ebp
  8010b9:	83 ec 28             	sub    $0x28,%esp
  int r;

  // JOS does, however, support standard _input_ redirection,
  // allowing the user to redirect script files to the shell and such.
  // getchar() reads a character from file descriptor 0.
  r = read(0, &c, 1);
  8010bc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8010c3:	00 
  8010c4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010d2:	e8 4e f6 ff ff       	call   800725 <read>
  if (r < 0)
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	78 0f                	js     8010ea <getchar+0x34>
    return r;
  if (r < 1)
  8010db:	85 c0                	test   %eax,%eax
  8010dd:	7e 06                	jle    8010e5 <getchar+0x2f>
    return -E_EOF;
  return c;
  8010df:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8010e3:	eb 05                	jmp    8010ea <getchar+0x34>
  // getchar() reads a character from file descriptor 0.
  r = read(0, &c, 1);
  if (r < 0)
    return r;
  if (r < 1)
    return -E_EOF;
  8010e5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  /* int r;
  // sys_cgetc does not block, but getchar should.
  while ((r = sys_cgetc()) == 0)
    sys_yield();
  return r; */
}
  8010ea:	c9                   	leave  
  8010eb:	c3                   	ret    

008010ec <iscons>:
  .dev_stat   =     devcons_stat
};

int
iscons(int fdnum)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	83 ec 28             	sub    $0x28,%esp
  int r;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fc:	89 04 24             	mov    %eax,(%esp)
  8010ff:	e8 92 f3 ff ff       	call   800496 <fd_lookup>
  801104:	85 c0                	test   %eax,%eax
  801106:	78 11                	js     801119 <iscons+0x2d>
    return r;
  return fd->fd_dev_id == devcons.dev_id;
  801108:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80110b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801111:	39 10                	cmp    %edx,(%eax)
  801113:	0f 94 c0             	sete   %al
  801116:	0f b6 c0             	movzbl %al,%eax
}
  801119:	c9                   	leave  
  80111a:	c3                   	ret    

0080111b <opencons>:

int
opencons(void)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	83 ec 28             	sub    $0x28,%esp
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
  801121:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801124:	89 04 24             	mov    %eax,(%esp)
  801127:	e8 1b f3 ff ff       	call   800447 <fd_alloc>
    return r;
  80112c:	89 c2                	mov    %eax,%edx
opencons(void)
{
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
  80112e:	85 c0                	test   %eax,%eax
  801130:	78 40                	js     801172 <opencons+0x57>
    return r;
  if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801132:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801139:	00 
  80113a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80113d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801141:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801148:	e8 3a f0 ff ff       	call   800187 <sys_page_alloc>
    return r;
  80114d:	89 c2                	mov    %eax,%edx
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
    return r;
  if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80114f:	85 c0                	test   %eax,%eax
  801151:	78 1f                	js     801172 <opencons+0x57>
    return r;
  fd->fd_dev_id = devcons.dev_id;
  801153:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801159:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115c:	89 10                	mov    %edx,(%eax)
  fd->fd_omode = O_RDWR;
  80115e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801161:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
  return fd2num(fd);
  801168:	89 04 24             	mov    %eax,(%esp)
  80116b:	e8 b0 f2 ff ff       	call   800420 <fd2num>
  801170:	89 c2                	mov    %eax,%edx
}
  801172:	89 d0                	mov    %edx,%eax
  801174:	c9                   	leave  
  801175:	c3                   	ret    

00801176 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801176:	55                   	push   %ebp
  801177:	89 e5                	mov    %esp,%ebp
  801179:	56                   	push   %esi
  80117a:	53                   	push   %ebx
  80117b:	83 ec 20             	sub    $0x20,%esp
  va_list ap;

  va_start(ap, fmt);
  80117e:	8d 5d 14             	lea    0x14(%ebp),%ebx

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  801181:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801187:	e8 bd ef ff ff       	call   800149 <sys_getenvid>
  80118c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80118f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801193:	8b 55 08             	mov    0x8(%ebp),%edx
  801196:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80119a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80119e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a2:	c7 04 24 70 21 80 00 	movl   $0x802170,(%esp)
  8011a9:	e8 c1 00 00 00       	call   80126f <cprintf>
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  8011ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8011b5:	89 04 24             	mov    %eax,(%esp)
  8011b8:	e8 51 00 00 00       	call   80120e <vcprintf>
  cprintf("\n");
  8011bd:	c7 04 24 5c 21 80 00 	movl   $0x80215c,(%esp)
  8011c4:	e8 a6 00 00 00       	call   80126f <cprintf>

  // Cause a breakpoint exception
  while (1)
    asm volatile ("int3");
  8011c9:	cc                   	int3   
  8011ca:	eb fd                	jmp    8011c9 <_panic+0x53>

008011cc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
  8011cf:	53                   	push   %ebx
  8011d0:	83 ec 14             	sub    $0x14,%esp
  8011d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  b->buf[b->idx++] = ch;
  8011d6:	8b 13                	mov    (%ebx),%edx
  8011d8:	8d 42 01             	lea    0x1(%edx),%eax
  8011db:	89 03                	mov    %eax,(%ebx)
  8011dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
  if (b->idx == 256-1) {
  8011e4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8011e9:	75 19                	jne    801204 <putch+0x38>
    sys_cputs(b->buf, b->idx);
  8011eb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8011f2:	00 
  8011f3:	8d 43 08             	lea    0x8(%ebx),%eax
  8011f6:	89 04 24             	mov    %eax,(%esp)
  8011f9:	e8 bc ee ff ff       	call   8000ba <sys_cputs>
    b->idx = 0;
  8011fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  }
  b->cnt++;
  801204:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801208:	83 c4 14             	add    $0x14,%esp
  80120b:	5b                   	pop    %ebx
  80120c:	5d                   	pop    %ebp
  80120d:	c3                   	ret    

0080120e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80120e:	55                   	push   %ebp
  80120f:	89 e5                	mov    %esp,%ebp
  801211:	81 ec 28 01 00 00    	sub    $0x128,%esp
  struct printbuf b;

  b.idx = 0;
  801217:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80121e:	00 00 00 
  b.cnt = 0;
  801221:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801228:	00 00 00 
  vprintfmt((void*)putch, &b, fmt, ap);
  80122b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80122e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801232:	8b 45 08             	mov    0x8(%ebp),%eax
  801235:	89 44 24 08          	mov    %eax,0x8(%esp)
  801239:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80123f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801243:	c7 04 24 cc 11 80 00 	movl   $0x8011cc,(%esp)
  80124a:	e8 af 01 00 00       	call   8013fe <vprintfmt>
  sys_cputs(b.buf, b.idx);
  80124f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801255:	89 44 24 04          	mov    %eax,0x4(%esp)
  801259:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80125f:	89 04 24             	mov    %eax,(%esp)
  801262:	e8 53 ee ff ff       	call   8000ba <sys_cputs>

  return b.cnt;
}
  801267:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80126d:	c9                   	leave  
  80126e:	c3                   	ret    

0080126f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  801275:	8d 45 0c             	lea    0xc(%ebp),%eax
  cnt = vcprintf(fmt, ap);
  801278:	89 44 24 04          	mov    %eax,0x4(%esp)
  80127c:	8b 45 08             	mov    0x8(%ebp),%eax
  80127f:	89 04 24             	mov    %eax,(%esp)
  801282:	e8 87 ff ff ff       	call   80120e <vcprintf>
  va_end(ap);

  return cnt;
}
  801287:	c9                   	leave  
  801288:	c3                   	ret    
  801289:	66 90                	xchg   %ax,%ax
  80128b:	66 90                	xchg   %ax,%ax
  80128d:	66 90                	xchg   %ax,%ax
  80128f:	90                   	nop

00801290 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
         unsigned long long num, unsigned base, int width, int padc)
{
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
  801293:	57                   	push   %edi
  801294:	56                   	push   %esi
  801295:	53                   	push   %ebx
  801296:	83 ec 3c             	sub    $0x3c,%esp
  801299:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80129c:	89 d7                	mov    %edx,%edi
  80129e:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012a7:	89 c3                	mov    %eax,%ebx
  8012a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8012ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8012af:	8b 75 14             	mov    0x14(%ebp),%esi
  // first recursively print all preceding (more significant) digits
  if (num >= base)
  8012b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8012ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8012bd:	39 d9                	cmp    %ebx,%ecx
  8012bf:	72 05                	jb     8012c6 <printnum+0x36>
  8012c1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8012c4:	77 69                	ja     80132f <printnum+0x9f>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8012c6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8012c9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8012cd:	83 ee 01             	sub    $0x1,%esi
  8012d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012d8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012dc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8012e0:	89 c3                	mov    %eax,%ebx
  8012e2:	89 d6                	mov    %edx,%esi
  8012e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8012e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8012ea:	89 54 24 08          	mov    %edx,0x8(%esp)
  8012ee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8012f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012f5:	89 04 24             	mov    %eax,(%esp)
  8012f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8012fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ff:	e8 dc 0a 00 00       	call   801de0 <__udivdi3>
  801304:	89 d9                	mov    %ebx,%ecx
  801306:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80130a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80130e:	89 04 24             	mov    %eax,(%esp)
  801311:	89 54 24 04          	mov    %edx,0x4(%esp)
  801315:	89 fa                	mov    %edi,%edx
  801317:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80131a:	e8 71 ff ff ff       	call   801290 <printnum>
  80131f:	eb 1b                	jmp    80133c <printnum+0xac>
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
      putch(padc, putdat);
  801321:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801325:	8b 45 18             	mov    0x18(%ebp),%eax
  801328:	89 04 24             	mov    %eax,(%esp)
  80132b:	ff d3                	call   *%ebx
  80132d:	eb 03                	jmp    801332 <printnum+0xa2>
  80132f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  // first recursively print all preceding (more significant) digits
  if (num >= base)
    printnum(putch, putdat, num / base, base, width - 1, padc);
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
  801332:	83 ee 01             	sub    $0x1,%esi
  801335:	85 f6                	test   %esi,%esi
  801337:	7f e8                	jg     801321 <printnum+0x91>
  801339:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
      putch(padc, putdat);
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  80133c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801340:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801344:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801347:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80134a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80134e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801352:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801355:	89 04 24             	mov    %eax,(%esp)
  801358:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80135b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80135f:	e8 ac 0b 00 00       	call   801f10 <__umoddi3>
  801364:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801368:	0f be 80 93 21 80 00 	movsbl 0x802193(%eax),%eax
  80136f:	89 04 24             	mov    %eax,(%esp)
  801372:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801375:	ff d0                	call   *%eax
}
  801377:	83 c4 3c             	add    $0x3c,%esp
  80137a:	5b                   	pop    %ebx
  80137b:	5e                   	pop    %esi
  80137c:	5f                   	pop    %edi
  80137d:	5d                   	pop    %ebp
  80137e:	c3                   	ret    

0080137f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
  if (lflag >= 2)
  801382:	83 fa 01             	cmp    $0x1,%edx
  801385:	7e 0e                	jle    801395 <getuint+0x16>
    return va_arg(*ap, unsigned long long);
  801387:	8b 10                	mov    (%eax),%edx
  801389:	8d 4a 08             	lea    0x8(%edx),%ecx
  80138c:	89 08                	mov    %ecx,(%eax)
  80138e:	8b 02                	mov    (%edx),%eax
  801390:	8b 52 04             	mov    0x4(%edx),%edx
  801393:	eb 22                	jmp    8013b7 <getuint+0x38>
  else if (lflag)
  801395:	85 d2                	test   %edx,%edx
  801397:	74 10                	je     8013a9 <getuint+0x2a>
    return va_arg(*ap, unsigned long);
  801399:	8b 10                	mov    (%eax),%edx
  80139b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80139e:	89 08                	mov    %ecx,(%eax)
  8013a0:	8b 02                	mov    (%edx),%eax
  8013a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a7:	eb 0e                	jmp    8013b7 <getuint+0x38>
  else
    return va_arg(*ap, unsigned int);
  8013a9:	8b 10                	mov    (%eax),%edx
  8013ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8013ae:	89 08                	mov    %ecx,(%eax)
  8013b0:	8b 02                	mov    (%edx),%eax
  8013b2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8013b7:	5d                   	pop    %ebp
  8013b8:	c3                   	ret    

008013b9 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8013b9:	55                   	push   %ebp
  8013ba:	89 e5                	mov    %esp,%ebp
  8013bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  b->cnt++;
  8013bf:	83 40 08 01          	addl   $0x1,0x8(%eax)
  if (b->buf < b->ebuf)
  8013c3:	8b 10                	mov    (%eax),%edx
  8013c5:	3b 50 04             	cmp    0x4(%eax),%edx
  8013c8:	73 0a                	jae    8013d4 <sprintputch+0x1b>
    *b->buf++ = ch;
  8013ca:	8d 4a 01             	lea    0x1(%edx),%ecx
  8013cd:	89 08                	mov    %ecx,(%eax)
  8013cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d2:	88 02                	mov    %al,(%edx)
}
  8013d4:	5d                   	pop    %ebp
  8013d5:	c3                   	ret    

008013d6 <printfmt>:
  }
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8013d6:	55                   	push   %ebp
  8013d7:	89 e5                	mov    %esp,%ebp
  8013d9:	83 ec 18             	sub    $0x18,%esp
  va_list ap;

  va_start(ap, fmt);
  8013dc:	8d 45 14             	lea    0x14(%ebp),%eax
  vprintfmt(putch, putdat, fmt, ap);
  8013df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8013e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f4:	89 04 24             	mov    %eax,(%esp)
  8013f7:	e8 02 00 00 00       	call   8013fe <vprintfmt>
  va_end(ap);
}
  8013fc:	c9                   	leave  
  8013fd:	c3                   	ret    

008013fe <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8013fe:	55                   	push   %ebp
  8013ff:	89 e5                	mov    %esp,%ebp
  801401:	57                   	push   %edi
  801402:	56                   	push   %esi
  801403:	53                   	push   %ebx
  801404:	83 ec 3c             	sub    $0x3c,%esp
  801407:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80140a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80140d:	eb 14                	jmp    801423 <vprintfmt+0x25>
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
      if (ch == '\0')
  80140f:	85 c0                	test   %eax,%eax
  801411:	0f 84 b3 03 00 00    	je     8017ca <vprintfmt+0x3cc>
        return;
      putch(ch, putdat);
  801417:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80141b:	89 04 24             	mov    %eax,(%esp)
  80141e:	ff 55 08             	call   *0x8(%ebp)
  unsigned long long num;
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
  801421:	89 f3                	mov    %esi,%ebx
  801423:	8d 73 01             	lea    0x1(%ebx),%esi
  801426:	0f b6 03             	movzbl (%ebx),%eax
  801429:	83 f8 25             	cmp    $0x25,%eax
  80142c:	75 e1                	jne    80140f <vprintfmt+0x11>
  80142e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  801432:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801439:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801440:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  801447:	ba 00 00 00 00       	mov    $0x0,%edx
  80144c:	eb 1d                	jmp    80146b <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80144e:	89 de                	mov    %ebx,%esi

    // flag to pad on the right
    case '-':
      padc = '-';
  801450:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  801454:	eb 15                	jmp    80146b <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  801456:	89 de                	mov    %ebx,%esi
      padc = '-';
      goto reswitch;

    // flag to pad with 0's instead of spaces
    case '0':
      padc = '0';
  801458:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80145c:	eb 0d                	jmp    80146b <vprintfmt+0x6d>
      altflag = 1;
      goto reswitch;

process_precision:
      if (width < 0)
        width = precision, precision = -1;
  80145e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801461:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801464:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80146b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80146e:	0f b6 0e             	movzbl (%esi),%ecx
  801471:	0f b6 c1             	movzbl %cl,%eax
  801474:	83 e9 23             	sub    $0x23,%ecx
  801477:	80 f9 55             	cmp    $0x55,%cl
  80147a:	0f 87 2a 03 00 00    	ja     8017aa <vprintfmt+0x3ac>
  801480:	0f b6 c9             	movzbl %cl,%ecx
  801483:	ff 24 8d e0 22 80 00 	jmp    *0x8022e0(,%ecx,4)
  80148a:	89 de                	mov    %ebx,%esi
  80148c:	b9 00 00 00 00       	mov    $0x0,%ecx
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
        precision = precision * 10 + ch - '0';
  801491:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  801494:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
        ch = *fmt;
  801498:	0f be 06             	movsbl (%esi),%eax
        if (ch < '0' || ch > '9')
  80149b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80149e:	83 fb 09             	cmp    $0x9,%ebx
  8014a1:	77 36                	ja     8014d9 <vprintfmt+0xdb>
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
  8014a3:	83 c6 01             	add    $0x1,%esi
        precision = precision * 10 + ch - '0';
        ch = *fmt;
        if (ch < '0' || ch > '9')
          break;
      }
  8014a6:	eb e9                	jmp    801491 <vprintfmt+0x93>
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
  8014a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ab:	8d 48 04             	lea    0x4(%eax),%ecx
  8014ae:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8014b1:	8b 00                	mov    (%eax),%eax
  8014b3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8014b6:	89 de                	mov    %ebx,%esi
      }
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
      goto process_precision;
  8014b8:	eb 22                	jmp    8014dc <vprintfmt+0xde>
  8014ba:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8014bd:	85 c9                	test   %ecx,%ecx
  8014bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c4:	0f 49 c1             	cmovns %ecx,%eax
  8014c7:	89 45 dc             	mov    %eax,-0x24(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8014ca:	89 de                	mov    %ebx,%esi
  8014cc:	eb 9d                	jmp    80146b <vprintfmt+0x6d>
  8014ce:	89 de                	mov    %ebx,%esi
      if (width < 0)
        width = 0;
      goto reswitch;

    case '#':
      altflag = 1;
  8014d0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
      goto reswitch;
  8014d7:	eb 92                	jmp    80146b <vprintfmt+0x6d>
  8014d9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

process_precision:
      if (width < 0)
  8014dc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8014e0:	79 89                	jns    80146b <vprintfmt+0x6d>
  8014e2:	e9 77 ff ff ff       	jmp    80145e <vprintfmt+0x60>
        width = precision, precision = -1;
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
  8014e7:	83 c2 01             	add    $0x1,%edx
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8014ea:	89 de                	mov    %ebx,%esi
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
      goto reswitch;
  8014ec:	e9 7a ff ff ff       	jmp    80146b <vprintfmt+0x6d>

    // character
    case 'c':
      putch(va_arg(ap, int), putdat);
  8014f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f4:	8d 50 04             	lea    0x4(%eax),%edx
  8014f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8014fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014fe:	8b 00                	mov    (%eax),%eax
  801500:	89 04 24             	mov    %eax,(%esp)
  801503:	ff 55 08             	call   *0x8(%ebp)
      break;
  801506:	e9 18 ff ff ff       	jmp    801423 <vprintfmt+0x25>

    // error message
    case 'e':
      err = va_arg(ap, int);
  80150b:	8b 45 14             	mov    0x14(%ebp),%eax
  80150e:	8d 50 04             	lea    0x4(%eax),%edx
  801511:	89 55 14             	mov    %edx,0x14(%ebp)
  801514:	8b 00                	mov    (%eax),%eax
  801516:	99                   	cltd   
  801517:	31 d0                	xor    %edx,%eax
  801519:	29 d0                	sub    %edx,%eax
      if (err < 0)
        err = -err;
      if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80151b:	83 f8 0f             	cmp    $0xf,%eax
  80151e:	7f 0b                	jg     80152b <vprintfmt+0x12d>
  801520:	8b 14 85 40 24 80 00 	mov    0x802440(,%eax,4),%edx
  801527:	85 d2                	test   %edx,%edx
  801529:	75 20                	jne    80154b <vprintfmt+0x14d>
        printfmt(putch, putdat, "error %d", err);
  80152b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80152f:	c7 44 24 08 ab 21 80 	movl   $0x8021ab,0x8(%esp)
  801536:	00 
  801537:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80153b:	8b 45 08             	mov    0x8(%ebp),%eax
  80153e:	89 04 24             	mov    %eax,(%esp)
  801541:	e8 90 fe ff ff       	call   8013d6 <printfmt>
  801546:	e9 d8 fe ff ff       	jmp    801423 <vprintfmt+0x25>
      else
        printfmt(putch, putdat, "%s", p);
  80154b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80154f:	c7 44 24 08 b4 21 80 	movl   $0x8021b4,0x8(%esp)
  801556:	00 
  801557:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80155b:	8b 45 08             	mov    0x8(%ebp),%eax
  80155e:	89 04 24             	mov    %eax,(%esp)
  801561:	e8 70 fe ff ff       	call   8013d6 <printfmt>
  801566:	e9 b8 fe ff ff       	jmp    801423 <vprintfmt+0x25>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80156b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80156e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801571:	89 45 d0             	mov    %eax,-0x30(%ebp)
        printfmt(putch, putdat, "%s", p);
      break;

    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
  801574:	8b 45 14             	mov    0x14(%ebp),%eax
  801577:	8d 50 04             	lea    0x4(%eax),%edx
  80157a:	89 55 14             	mov    %edx,0x14(%ebp)
  80157d:	8b 30                	mov    (%eax),%esi
        p = "(null)";
  80157f:	85 f6                	test   %esi,%esi
  801581:	b8 a4 21 80 00       	mov    $0x8021a4,%eax
  801586:	0f 44 f0             	cmove  %eax,%esi
      if (width > 0 && padc != '-')
  801589:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80158d:	0f 84 97 00 00 00    	je     80162a <vprintfmt+0x22c>
  801593:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  801597:	0f 8e 9b 00 00 00    	jle    801638 <vprintfmt+0x23a>
        for (width -= strnlen(p, precision); width > 0; width--)
  80159d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015a1:	89 34 24             	mov    %esi,(%esp)
  8015a4:	e8 cf 02 00 00       	call   801878 <strnlen>
  8015a9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8015ac:	29 c2                	sub    %eax,%edx
  8015ae:	89 55 d0             	mov    %edx,-0x30(%ebp)
          putch(padc, putdat);
  8015b1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8015b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8015b8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8015bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8015be:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8015c1:	89 d3                	mov    %edx,%ebx
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
  8015c3:	eb 0f                	jmp    8015d4 <vprintfmt+0x1d6>
          putch(padc, putdat);
  8015c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8015c9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8015cc:	89 04 24             	mov    %eax,(%esp)
  8015cf:	ff d6                	call   *%esi
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
  8015d1:	83 eb 01             	sub    $0x1,%ebx
  8015d4:	85 db                	test   %ebx,%ebx
  8015d6:	7f ed                	jg     8015c5 <vprintfmt+0x1c7>
  8015d8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8015db:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8015de:	85 d2                	test   %edx,%edx
  8015e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8015e5:	0f 49 c2             	cmovns %edx,%eax
  8015e8:	29 c2                	sub    %eax,%edx
  8015ea:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8015ed:	89 d7                	mov    %edx,%edi
  8015ef:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8015f2:	eb 50                	jmp    801644 <vprintfmt+0x246>
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
  8015f4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8015f8:	74 1e                	je     801618 <vprintfmt+0x21a>
  8015fa:	0f be d2             	movsbl %dl,%edx
  8015fd:	83 ea 20             	sub    $0x20,%edx
  801600:	83 fa 5e             	cmp    $0x5e,%edx
  801603:	76 13                	jbe    801618 <vprintfmt+0x21a>
          putch('?', putdat);
  801605:	8b 45 0c             	mov    0xc(%ebp),%eax
  801608:	89 44 24 04          	mov    %eax,0x4(%esp)
  80160c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801613:	ff 55 08             	call   *0x8(%ebp)
  801616:	eb 0d                	jmp    801625 <vprintfmt+0x227>
        else
          putch(ch, putdat);
  801618:	8b 55 0c             	mov    0xc(%ebp),%edx
  80161b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80161f:	89 04 24             	mov    %eax,(%esp)
  801622:	ff 55 08             	call   *0x8(%ebp)
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801625:	83 ef 01             	sub    $0x1,%edi
  801628:	eb 1a                	jmp    801644 <vprintfmt+0x246>
  80162a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80162d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801630:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801633:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801636:	eb 0c                	jmp    801644 <vprintfmt+0x246>
  801638:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80163b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80163e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801641:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801644:	83 c6 01             	add    $0x1,%esi
  801647:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80164b:	0f be c2             	movsbl %dl,%eax
  80164e:	85 c0                	test   %eax,%eax
  801650:	74 27                	je     801679 <vprintfmt+0x27b>
  801652:	85 db                	test   %ebx,%ebx
  801654:	78 9e                	js     8015f4 <vprintfmt+0x1f6>
  801656:	83 eb 01             	sub    $0x1,%ebx
  801659:	79 99                	jns    8015f4 <vprintfmt+0x1f6>
  80165b:	89 f8                	mov    %edi,%eax
  80165d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801660:	8b 75 08             	mov    0x8(%ebp),%esi
  801663:	89 c3                	mov    %eax,%ebx
  801665:	eb 1a                	jmp    801681 <vprintfmt+0x283>
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
        putch(' ', putdat);
  801667:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80166b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801672:	ff d6                	call   *%esi
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
  801674:	83 eb 01             	sub    $0x1,%ebx
  801677:	eb 08                	jmp    801681 <vprintfmt+0x283>
  801679:	89 fb                	mov    %edi,%ebx
  80167b:	8b 75 08             	mov    0x8(%ebp),%esi
  80167e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801681:	85 db                	test   %ebx,%ebx
  801683:	7f e2                	jg     801667 <vprintfmt+0x269>
  801685:	89 75 08             	mov    %esi,0x8(%ebp)
  801688:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80168b:	e9 93 fd ff ff       	jmp    801423 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  if (lflag >= 2)
  801690:	83 fa 01             	cmp    $0x1,%edx
  801693:	7e 16                	jle    8016ab <vprintfmt+0x2ad>
    return va_arg(*ap, long long);
  801695:	8b 45 14             	mov    0x14(%ebp),%eax
  801698:	8d 50 08             	lea    0x8(%eax),%edx
  80169b:	89 55 14             	mov    %edx,0x14(%ebp)
  80169e:	8b 50 04             	mov    0x4(%eax),%edx
  8016a1:	8b 00                	mov    (%eax),%eax
  8016a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016a6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8016a9:	eb 32                	jmp    8016dd <vprintfmt+0x2df>
  else if (lflag)
  8016ab:	85 d2                	test   %edx,%edx
  8016ad:	74 18                	je     8016c7 <vprintfmt+0x2c9>
    return va_arg(*ap, long);
  8016af:	8b 45 14             	mov    0x14(%ebp),%eax
  8016b2:	8d 50 04             	lea    0x4(%eax),%edx
  8016b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8016b8:	8b 30                	mov    (%eax),%esi
  8016ba:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8016bd:	89 f0                	mov    %esi,%eax
  8016bf:	c1 f8 1f             	sar    $0x1f,%eax
  8016c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016c5:	eb 16                	jmp    8016dd <vprintfmt+0x2df>
  else
    return va_arg(*ap, int);
  8016c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8016ca:	8d 50 04             	lea    0x4(%eax),%edx
  8016cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8016d0:	8b 30                	mov    (%eax),%esi
  8016d2:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8016d5:	89 f0                	mov    %esi,%eax
  8016d7:	c1 f8 1f             	sar    $0x1f,%eax
  8016da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        putch(' ', putdat);
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
  8016dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      if ((long long)num < 0) {
        putch('-', putdat);
        num = -(long long)num;
      }
      base = 10;
  8016e3:	b9 0a 00 00 00       	mov    $0xa,%ecx
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
      if ((long long)num < 0) {
  8016e8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8016ec:	0f 89 80 00 00 00    	jns    801772 <vprintfmt+0x374>
        putch('-', putdat);
  8016f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8016f6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8016fd:	ff 55 08             	call   *0x8(%ebp)
        num = -(long long)num;
  801700:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801703:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801706:	f7 d8                	neg    %eax
  801708:	83 d2 00             	adc    $0x0,%edx
  80170b:	f7 da                	neg    %edx
      }
      base = 10;
  80170d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801712:	eb 5e                	jmp    801772 <vprintfmt+0x374>
      goto number;

    // unsigned decimal
    case 'u':
      num = getuint(&ap, lflag);
  801714:	8d 45 14             	lea    0x14(%ebp),%eax
  801717:	e8 63 fc ff ff       	call   80137f <getuint>
      base = 10;
  80171c:	b9 0a 00 00 00       	mov    $0xa,%ecx
      goto number;
  801721:	eb 4f                	jmp    801772 <vprintfmt+0x374>

    // (unsigned) octal
    case 'o':
      num = getuint(&ap, lflag);
  801723:	8d 45 14             	lea    0x14(%ebp),%eax
  801726:	e8 54 fc ff ff       	call   80137f <getuint>
      base = 8;
  80172b:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  801730:	eb 40                	jmp    801772 <vprintfmt+0x374>

    // pointer
    case 'p':
      putch('0', putdat);
  801732:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801736:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80173d:	ff 55 08             	call   *0x8(%ebp)
      putch('x', putdat);
  801740:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801744:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80174b:	ff 55 08             	call   *0x8(%ebp)
      num = (unsigned long long)
            (uintptr_t)va_arg(ap, void *);
  80174e:	8b 45 14             	mov    0x14(%ebp),%eax
  801751:	8d 50 04             	lea    0x4(%eax),%edx
  801754:	89 55 14             	mov    %edx,0x14(%ebp)

    // pointer
    case 'p':
      putch('0', putdat);
      putch('x', putdat);
      num = (unsigned long long)
  801757:	8b 00                	mov    (%eax),%eax
  801759:	ba 00 00 00 00       	mov    $0x0,%edx
            (uintptr_t)va_arg(ap, void *);
      base = 16;
  80175e:	b9 10 00 00 00       	mov    $0x10,%ecx
      goto number;
  801763:	eb 0d                	jmp    801772 <vprintfmt+0x374>

    // (unsigned) hexadecimal
    case 'x':
      num = getuint(&ap, lflag);
  801765:	8d 45 14             	lea    0x14(%ebp),%eax
  801768:	e8 12 fc ff ff       	call   80137f <getuint>
      base = 16;
  80176d:	b9 10 00 00 00       	mov    $0x10,%ecx
number:
      printnum(putch, putdat, num, base, width, padc);
  801772:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  801776:	89 74 24 10          	mov    %esi,0x10(%esp)
  80177a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80177d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801781:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801785:	89 04 24             	mov    %eax,(%esp)
  801788:	89 54 24 04          	mov    %edx,0x4(%esp)
  80178c:	89 fa                	mov    %edi,%edx
  80178e:	8b 45 08             	mov    0x8(%ebp),%eax
  801791:	e8 fa fa ff ff       	call   801290 <printnum>
      break;
  801796:	e9 88 fc ff ff       	jmp    801423 <vprintfmt+0x25>

    // escaped '%' character
    case '%':
      putch(ch, putdat);
  80179b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80179f:	89 04 24             	mov    %eax,(%esp)
  8017a2:	ff 55 08             	call   *0x8(%ebp)
      break;
  8017a5:	e9 79 fc ff ff       	jmp    801423 <vprintfmt+0x25>

    // unrecognized escape sequence - just print it literally
    default:
      putch('%', putdat);
  8017aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8017ae:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8017b5:	ff 55 08             	call   *0x8(%ebp)
      for (fmt--; fmt[-1] != '%'; fmt--)
  8017b8:	89 f3                	mov    %esi,%ebx
  8017ba:	eb 03                	jmp    8017bf <vprintfmt+0x3c1>
  8017bc:	83 eb 01             	sub    $0x1,%ebx
  8017bf:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8017c3:	75 f7                	jne    8017bc <vprintfmt+0x3be>
  8017c5:	e9 59 fc ff ff       	jmp    801423 <vprintfmt+0x25>
        /* do nothing */;
      break;
    }
  }
}
  8017ca:	83 c4 3c             	add    $0x3c,%esp
  8017cd:	5b                   	pop    %ebx
  8017ce:	5e                   	pop    %esi
  8017cf:	5f                   	pop    %edi
  8017d0:	5d                   	pop    %ebp
  8017d1:	c3                   	ret    

008017d2 <vsnprintf>:
    *b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8017d2:	55                   	push   %ebp
  8017d3:	89 e5                	mov    %esp,%ebp
  8017d5:	83 ec 28             	sub    $0x28,%esp
  8017d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017db:	8b 55 0c             	mov    0xc(%ebp),%edx
  struct sprintbuf b = { buf, buf+n-1, 0 };
  8017de:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8017e1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8017e5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8017e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  if (buf == NULL || n < 1)
  8017ef:	85 c0                	test   %eax,%eax
  8017f1:	74 30                	je     801823 <vsnprintf+0x51>
  8017f3:	85 d2                	test   %edx,%edx
  8017f5:	7e 2c                	jle    801823 <vsnprintf+0x51>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void*)sprintputch, &b, fmt, ap);
  8017f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8017fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017fe:	8b 45 10             	mov    0x10(%ebp),%eax
  801801:	89 44 24 08          	mov    %eax,0x8(%esp)
  801805:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801808:	89 44 24 04          	mov    %eax,0x4(%esp)
  80180c:	c7 04 24 b9 13 80 00 	movl   $0x8013b9,(%esp)
  801813:	e8 e6 fb ff ff       	call   8013fe <vprintfmt>

  // null terminate the buffer
  *b.buf = '\0';
  801818:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80181b:	c6 00 00             	movb   $0x0,(%eax)

  return b.cnt;
  80181e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801821:	eb 05                	jmp    801828 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  struct sprintbuf b = { buf, buf+n-1, 0 };

  if (buf == NULL || n < 1)
    return -E_INVAL;
  801823:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

  // null terminate the buffer
  *b.buf = '\0';

  return b.cnt;
}
  801828:	c9                   	leave  
  801829:	c3                   	ret    

0080182a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80182a:	55                   	push   %ebp
  80182b:	89 e5                	mov    %esp,%ebp
  80182d:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int rc;

  va_start(ap, fmt);
  801830:	8d 45 14             	lea    0x14(%ebp),%eax
  rc = vsnprintf(buf, n, fmt, ap);
  801833:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801837:	8b 45 10             	mov    0x10(%ebp),%eax
  80183a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80183e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801841:	89 44 24 04          	mov    %eax,0x4(%esp)
  801845:	8b 45 08             	mov    0x8(%ebp),%eax
  801848:	89 04 24             	mov    %eax,(%esp)
  80184b:	e8 82 ff ff ff       	call   8017d2 <vsnprintf>
  va_end(ap);

  return rc;
}
  801850:	c9                   	leave  
  801851:	c3                   	ret    
  801852:	66 90                	xchg   %ax,%ax
  801854:	66 90                	xchg   %ax,%ax
  801856:	66 90                	xchg   %ax,%ax
  801858:	66 90                	xchg   %ax,%ax
  80185a:	66 90                	xchg   %ax,%ax
  80185c:	66 90                	xchg   %ax,%ax
  80185e:	66 90                	xchg   %ax,%ax

00801860 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801860:	55                   	push   %ebp
  801861:	89 e5                	mov    %esp,%ebp
  801863:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for (n = 0; *s != '\0'; s++)
  801866:	b8 00 00 00 00       	mov    $0x0,%eax
  80186b:	eb 03                	jmp    801870 <strlen+0x10>
    n++;
  80186d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
  int n;

  for (n = 0; *s != '\0'; s++)
  801870:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801874:	75 f7                	jne    80186d <strlen+0xd>
    n++;
  return n;
}
  801876:	5d                   	pop    %ebp
  801877:	c3                   	ret    

00801878 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80187e:	8b 55 0c             	mov    0xc(%ebp),%edx
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801881:	b8 00 00 00 00       	mov    $0x0,%eax
  801886:	eb 03                	jmp    80188b <strnlen+0x13>
    n++;
  801888:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80188b:	39 d0                	cmp    %edx,%eax
  80188d:	74 06                	je     801895 <strnlen+0x1d>
  80188f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801893:	75 f3                	jne    801888 <strnlen+0x10>
    n++;
  return n;
}
  801895:	5d                   	pop    %ebp
  801896:	c3                   	ret    

00801897 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801897:	55                   	push   %ebp
  801898:	89 e5                	mov    %esp,%ebp
  80189a:	53                   	push   %ebx
  80189b:	8b 45 08             	mov    0x8(%ebp),%eax
  80189e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  8018a1:	89 c2                	mov    %eax,%edx
  8018a3:	83 c2 01             	add    $0x1,%edx
  8018a6:	83 c1 01             	add    $0x1,%ecx
  8018a9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8018ad:	88 5a ff             	mov    %bl,-0x1(%edx)
  8018b0:	84 db                	test   %bl,%bl
  8018b2:	75 ef                	jne    8018a3 <strcpy+0xc>
    /* do nothing */;
  return ret;
}
  8018b4:	5b                   	pop    %ebx
  8018b5:	5d                   	pop    %ebp
  8018b6:	c3                   	ret    

008018b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8018b7:	55                   	push   %ebp
  8018b8:	89 e5                	mov    %esp,%ebp
  8018ba:	53                   	push   %ebx
  8018bb:	83 ec 08             	sub    $0x8,%esp
  8018be:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int len = strlen(dst);
  8018c1:	89 1c 24             	mov    %ebx,(%esp)
  8018c4:	e8 97 ff ff ff       	call   801860 <strlen>

  strcpy(dst + len, src);
  8018c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018cc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018d0:	01 d8                	add    %ebx,%eax
  8018d2:	89 04 24             	mov    %eax,(%esp)
  8018d5:	e8 bd ff ff ff       	call   801897 <strcpy>
  return dst;
}
  8018da:	89 d8                	mov    %ebx,%eax
  8018dc:	83 c4 08             	add    $0x8,%esp
  8018df:	5b                   	pop    %ebx
  8018e0:	5d                   	pop    %ebp
  8018e1:	c3                   	ret    

008018e2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  8018e2:	55                   	push   %ebp
  8018e3:	89 e5                	mov    %esp,%ebp
  8018e5:	56                   	push   %esi
  8018e6:	53                   	push   %ebx
  8018e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8018ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018ed:	89 f3                	mov    %esi,%ebx
  8018ef:	03 5d 10             	add    0x10(%ebp),%ebx
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  8018f2:	89 f2                	mov    %esi,%edx
  8018f4:	eb 0f                	jmp    801905 <strncpy+0x23>
    *dst++ = *src;
  8018f6:	83 c2 01             	add    $0x1,%edx
  8018f9:	0f b6 01             	movzbl (%ecx),%eax
  8018fc:	88 42 ff             	mov    %al,-0x1(%edx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  8018ff:	80 39 01             	cmpb   $0x1,(%ecx)
  801902:	83 d9 ff             	sbb    $0xffffffff,%ecx
{
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  801905:	39 da                	cmp    %ebx,%edx
  801907:	75 ed                	jne    8018f6 <strncpy+0x14>
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  }
  return ret;
}
  801909:	89 f0                	mov    %esi,%eax
  80190b:	5b                   	pop    %ebx
  80190c:	5e                   	pop    %esi
  80190d:	5d                   	pop    %ebp
  80190e:	c3                   	ret    

0080190f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80190f:	55                   	push   %ebp
  801910:	89 e5                	mov    %esp,%ebp
  801912:	56                   	push   %esi
  801913:	53                   	push   %ebx
  801914:	8b 75 08             	mov    0x8(%ebp),%esi
  801917:	8b 55 0c             	mov    0xc(%ebp),%edx
  80191a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80191d:	89 f0                	mov    %esi,%eax
  80191f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  801923:	85 c9                	test   %ecx,%ecx
  801925:	75 0b                	jne    801932 <strlcpy+0x23>
  801927:	eb 1d                	jmp    801946 <strlcpy+0x37>
    while (--size > 0 && *src != '\0')
      *dst++ = *src++;
  801929:	83 c0 01             	add    $0x1,%eax
  80192c:	83 c2 01             	add    $0x1,%edx
  80192f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
    while (--size > 0 && *src != '\0')
  801932:	39 d8                	cmp    %ebx,%eax
  801934:	74 0b                	je     801941 <strlcpy+0x32>
  801936:	0f b6 0a             	movzbl (%edx),%ecx
  801939:	84 c9                	test   %cl,%cl
  80193b:	75 ec                	jne    801929 <strlcpy+0x1a>
  80193d:	89 c2                	mov    %eax,%edx
  80193f:	eb 02                	jmp    801943 <strlcpy+0x34>
  801941:	89 c2                	mov    %eax,%edx
      *dst++ = *src++;
    *dst = '\0';
  801943:	c6 02 00             	movb   $0x0,(%edx)
  }
  return dst - dst_in;
  801946:	29 f0                	sub    %esi,%eax
}
  801948:	5b                   	pop    %ebx
  801949:	5e                   	pop    %esi
  80194a:	5d                   	pop    %ebp
  80194b:	c3                   	ret    

0080194c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80194c:	55                   	push   %ebp
  80194d:	89 e5                	mov    %esp,%ebp
  80194f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801952:	8b 55 0c             	mov    0xc(%ebp),%edx
  while (*p && *p == *q)
  801955:	eb 06                	jmp    80195d <strcmp+0x11>
    p++, q++;
  801957:	83 c1 01             	add    $0x1,%ecx
  80195a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
  while (*p && *p == *q)
  80195d:	0f b6 01             	movzbl (%ecx),%eax
  801960:	84 c0                	test   %al,%al
  801962:	74 04                	je     801968 <strcmp+0x1c>
  801964:	3a 02                	cmp    (%edx),%al
  801966:	74 ef                	je     801957 <strcmp+0xb>
    p++, q++;
  return (int)((unsigned char)*p - (unsigned char)*q);
  801968:	0f b6 c0             	movzbl %al,%eax
  80196b:	0f b6 12             	movzbl (%edx),%edx
  80196e:	29 d0                	sub    %edx,%eax
}
  801970:	5d                   	pop    %ebp
  801971:	c3                   	ret    

00801972 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801972:	55                   	push   %ebp
  801973:	89 e5                	mov    %esp,%ebp
  801975:	53                   	push   %ebx
  801976:	8b 45 08             	mov    0x8(%ebp),%eax
  801979:	8b 55 0c             	mov    0xc(%ebp),%edx
  80197c:	89 c3                	mov    %eax,%ebx
  80197e:	03 5d 10             	add    0x10(%ebp),%ebx
  while (n > 0 && *p && *p == *q)
  801981:	eb 06                	jmp    801989 <strncmp+0x17>
    n--, p++, q++;
  801983:	83 c0 01             	add    $0x1,%eax
  801986:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
  801989:	39 d8                	cmp    %ebx,%eax
  80198b:	74 15                	je     8019a2 <strncmp+0x30>
  80198d:	0f b6 08             	movzbl (%eax),%ecx
  801990:	84 c9                	test   %cl,%cl
  801992:	74 04                	je     801998 <strncmp+0x26>
  801994:	3a 0a                	cmp    (%edx),%cl
  801996:	74 eb                	je     801983 <strncmp+0x11>
    n--, p++, q++;
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  801998:	0f b6 00             	movzbl (%eax),%eax
  80199b:	0f b6 12             	movzbl (%edx),%edx
  80199e:	29 d0                	sub    %edx,%eax
  8019a0:	eb 05                	jmp    8019a7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
    n--, p++, q++;
  if (n == 0)
    return 0;
  8019a2:	b8 00 00 00 00       	mov    $0x0,%eax
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
}
  8019a7:	5b                   	pop    %ebx
  8019a8:	5d                   	pop    %ebp
  8019a9:	c3                   	ret    

008019aa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8019aa:	55                   	push   %ebp
  8019ab:	89 e5                	mov    %esp,%ebp
  8019ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
  8019b4:	eb 07                	jmp    8019bd <strchr+0x13>
    if (*s == c)
  8019b6:	38 ca                	cmp    %cl,%dl
  8019b8:	74 0f                	je     8019c9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  for (; *s; s++)
  8019ba:	83 c0 01             	add    $0x1,%eax
  8019bd:	0f b6 10             	movzbl (%eax),%edx
  8019c0:	84 d2                	test   %dl,%dl
  8019c2:	75 f2                	jne    8019b6 <strchr+0xc>
    if (*s == c)
      return (char*)s;
  return 0;
  8019c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019c9:	5d                   	pop    %ebp
  8019ca:	c3                   	ret    

008019cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8019cb:	55                   	push   %ebp
  8019cc:	89 e5                	mov    %esp,%ebp
  8019ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
  8019d5:	eb 07                	jmp    8019de <strfind+0x13>
    if (*s == c)
  8019d7:	38 ca                	cmp    %cl,%dl
  8019d9:	74 0a                	je     8019e5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  for (; *s; s++)
  8019db:	83 c0 01             	add    $0x1,%eax
  8019de:	0f b6 10             	movzbl (%eax),%edx
  8019e1:	84 d2                	test   %dl,%dl
  8019e3:	75 f2                	jne    8019d7 <strfind+0xc>
    if (*s == c)
      break;
  return (char*)s;
}
  8019e5:	5d                   	pop    %ebp
  8019e6:	c3                   	ret    

008019e7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8019e7:	55                   	push   %ebp
  8019e8:	89 e5                	mov    %esp,%ebp
  8019ea:	57                   	push   %edi
  8019eb:	56                   	push   %esi
  8019ec:	53                   	push   %ebx
  8019ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *p;

  if (n == 0)
  8019f3:	85 c9                	test   %ecx,%ecx
  8019f5:	74 36                	je     801a2d <memset+0x46>
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
  8019f7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8019fd:	75 28                	jne    801a27 <memset+0x40>
  8019ff:	f6 c1 03             	test   $0x3,%cl
  801a02:	75 23                	jne    801a27 <memset+0x40>
    c &= 0xFF;
  801a04:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
    c = (c<<24)|(c<<16)|(c<<8)|c;
  801a08:	89 d3                	mov    %edx,%ebx
  801a0a:	c1 e3 08             	shl    $0x8,%ebx
  801a0d:	89 d6                	mov    %edx,%esi
  801a0f:	c1 e6 18             	shl    $0x18,%esi
  801a12:	89 d0                	mov    %edx,%eax
  801a14:	c1 e0 10             	shl    $0x10,%eax
  801a17:	09 f0                	or     %esi,%eax
  801a19:	09 c2                	or     %eax,%edx
  801a1b:	89 d0                	mov    %edx,%eax
  801a1d:	09 d8                	or     %ebx,%eax
    asm volatile ("cld; rep stosl\n"
                  :: "D" (v), "a" (c), "c" (n/4)
  801a1f:	c1 e9 02             	shr    $0x2,%ecx
  if (n == 0)
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
    c &= 0xFF;
    c = (c<<24)|(c<<16)|(c<<8)|c;
    asm volatile ("cld; rep stosl\n"
  801a22:	fc                   	cld    
  801a23:	f3 ab                	rep stos %eax,%es:(%edi)
  801a25:	eb 06                	jmp    801a2d <memset+0x46>
                  :: "D" (v), "a" (c), "c" (n/4)
                  : "cc", "memory");
  } else
    asm volatile ("cld; rep stosb\n"
  801a27:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2a:	fc                   	cld    
  801a2b:	f3 aa                	rep stos %al,%es:(%edi)
                  :: "D" (v), "a" (c), "c" (n)
                  : "cc", "memory");
  return v;
}
  801a2d:	89 f8                	mov    %edi,%eax
  801a2f:	5b                   	pop    %ebx
  801a30:	5e                   	pop    %esi
  801a31:	5f                   	pop    %edi
  801a32:	5d                   	pop    %ebp
  801a33:	c3                   	ret    

00801a34 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801a34:	55                   	push   %ebp
  801a35:	89 e5                	mov    %esp,%ebp
  801a37:	57                   	push   %edi
  801a38:	56                   	push   %esi
  801a39:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  801a42:	39 c6                	cmp    %eax,%esi
  801a44:	73 35                	jae    801a7b <memmove+0x47>
  801a46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801a49:	39 d0                	cmp    %edx,%eax
  801a4b:	73 2e                	jae    801a7b <memmove+0x47>
    s += n;
    d += n;
  801a4d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801a50:	89 d6                	mov    %edx,%esi
  801a52:	09 fe                	or     %edi,%esi
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a54:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801a5a:	75 13                	jne    801a6f <memmove+0x3b>
  801a5c:	f6 c1 03             	test   $0x3,%cl
  801a5f:	75 0e                	jne    801a6f <memmove+0x3b>
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801a61:	83 ef 04             	sub    $0x4,%edi
  801a64:	8d 72 fc             	lea    -0x4(%edx),%esi
  801a67:	c1 e9 02             	shr    $0x2,%ecx
  d = dst;
  if (s < d && s + n > d) {
    s += n;
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
  801a6a:	fd                   	std    
  801a6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a6d:	eb 09                	jmp    801a78 <memmove+0x44>
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801a6f:	83 ef 01             	sub    $0x1,%edi
  801a72:	8d 72 ff             	lea    -0x1(%edx),%esi
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
  801a75:	fd                   	std    
  801a76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  801a78:	fc                   	cld    
  801a79:	eb 1d                	jmp    801a98 <memmove+0x64>
  801a7b:	89 f2                	mov    %esi,%edx
  801a7d:	09 c2                	or     %eax,%edx
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a7f:	f6 c2 03             	test   $0x3,%dl
  801a82:	75 0f                	jne    801a93 <memmove+0x5f>
  801a84:	f6 c1 03             	test   $0x3,%cl
  801a87:	75 0a                	jne    801a93 <memmove+0x5f>
      asm volatile ("cld; rep movsl\n"
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801a89:	c1 e9 02             	shr    $0x2,%ecx
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("cld; rep movsl\n"
  801a8c:	89 c7                	mov    %eax,%edi
  801a8e:	fc                   	cld    
  801a8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a91:	eb 05                	jmp    801a98 <memmove+0x64>
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("cld; rep movsb\n"
  801a93:	89 c7                	mov    %eax,%edi
  801a95:	fc                   	cld    
  801a96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d), "S" (s), "c" (n) : "cc", "memory");
  }
  return dst;
}
  801a98:	5e                   	pop    %esi
  801a99:	5f                   	pop    %edi
  801a9a:	5d                   	pop    %ebp
  801a9b:	c3                   	ret    

00801a9c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
  801aa2:	8b 45 10             	mov    0x10(%ebp),%eax
  801aa5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801aa9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aac:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab3:	89 04 24             	mov    %eax,(%esp)
  801ab6:	e8 79 ff ff ff       	call   801a34 <memmove>
}
  801abb:	c9                   	leave  
  801abc:	c3                   	ret    

00801abd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801abd:	55                   	push   %ebp
  801abe:	89 e5                	mov    %esp,%ebp
  801ac0:	56                   	push   %esi
  801ac1:	53                   	push   %ebx
  801ac2:	8b 55 08             	mov    0x8(%ebp),%edx
  801ac5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ac8:	89 d6                	mov    %edx,%esi
  801aca:	03 75 10             	add    0x10(%ebp),%esi
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
  801acd:	eb 1a                	jmp    801ae9 <memcmp+0x2c>
    if (*s1 != *s2)
  801acf:	0f b6 02             	movzbl (%edx),%eax
  801ad2:	0f b6 19             	movzbl (%ecx),%ebx
  801ad5:	38 d8                	cmp    %bl,%al
  801ad7:	74 0a                	je     801ae3 <memcmp+0x26>
      return (int)*s1 - (int)*s2;
  801ad9:	0f b6 c0             	movzbl %al,%eax
  801adc:	0f b6 db             	movzbl %bl,%ebx
  801adf:	29 d8                	sub    %ebx,%eax
  801ae1:	eb 0f                	jmp    801af2 <memcmp+0x35>
    s1++, s2++;
  801ae3:	83 c2 01             	add    $0x1,%edx
  801ae6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
  801ae9:	39 f2                	cmp    %esi,%edx
  801aeb:	75 e2                	jne    801acf <memcmp+0x12>
    if (*s1 != *s2)
      return (int)*s1 - (int)*s2;
    s1++, s2++;
  }

  return 0;
  801aed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801af2:	5b                   	pop    %ebx
  801af3:	5e                   	pop    %esi
  801af4:	5d                   	pop    %ebp
  801af5:	c3                   	ret    

00801af6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	8b 45 08             	mov    0x8(%ebp),%eax
  801afc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  const void *ends = (const char*)s + n;
  801aff:	89 c2                	mov    %eax,%edx
  801b01:	03 55 10             	add    0x10(%ebp),%edx

  for (; s < ends; s++)
  801b04:	eb 07                	jmp    801b0d <memfind+0x17>
    if (*(const unsigned char*)s == (unsigned char)c)
  801b06:	38 08                	cmp    %cl,(%eax)
  801b08:	74 07                	je     801b11 <memfind+0x1b>
void *
memfind(const void *s, int c, size_t n)
{
  const void *ends = (const char*)s + n;

  for (; s < ends; s++)
  801b0a:	83 c0 01             	add    $0x1,%eax
  801b0d:	39 d0                	cmp    %edx,%eax
  801b0f:	72 f5                	jb     801b06 <memfind+0x10>
    if (*(const unsigned char*)s == (unsigned char)c)
      break;
  return (void*)s;
}
  801b11:	5d                   	pop    %ebp
  801b12:	c3                   	ret    

00801b13 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	57                   	push   %edi
  801b17:	56                   	push   %esi
  801b18:	53                   	push   %ebx
  801b19:	8b 55 08             	mov    0x8(%ebp),%edx
  801b1c:	8b 45 10             	mov    0x10(%ebp),%eax
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  801b1f:	eb 03                	jmp    801b24 <strtol+0x11>
    s++;
  801b21:	83 c2 01             	add    $0x1,%edx
{
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  801b24:	0f b6 0a             	movzbl (%edx),%ecx
  801b27:	80 f9 09             	cmp    $0x9,%cl
  801b2a:	74 f5                	je     801b21 <strtol+0xe>
  801b2c:	80 f9 20             	cmp    $0x20,%cl
  801b2f:	74 f0                	je     801b21 <strtol+0xe>
    s++;

  // plus/minus sign
  if (*s == '+')
  801b31:	80 f9 2b             	cmp    $0x2b,%cl
  801b34:	75 0a                	jne    801b40 <strtol+0x2d>
    s++;
  801b36:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
  int neg = 0;
  801b39:	bf 00 00 00 00       	mov    $0x0,%edi
  801b3e:	eb 11                	jmp    801b51 <strtol+0x3e>
  801b40:	bf 00 00 00 00       	mov    $0x0,%edi
    s++;

  // plus/minus sign
  if (*s == '+')
    s++;
  else if (*s == '-')
  801b45:	80 f9 2d             	cmp    $0x2d,%cl
  801b48:	75 07                	jne    801b51 <strtol+0x3e>
    s++, neg = 1;
  801b4a:	8d 52 01             	lea    0x1(%edx),%edx
  801b4d:	66 bf 01 00          	mov    $0x1,%di

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801b51:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801b56:	75 15                	jne    801b6d <strtol+0x5a>
  801b58:	80 3a 30             	cmpb   $0x30,(%edx)
  801b5b:	75 10                	jne    801b6d <strtol+0x5a>
  801b5d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801b61:	75 0a                	jne    801b6d <strtol+0x5a>
    s += 2, base = 16;
  801b63:	83 c2 02             	add    $0x2,%edx
  801b66:	b8 10 00 00 00       	mov    $0x10,%eax
  801b6b:	eb 10                	jmp    801b7d <strtol+0x6a>
  else if (base == 0 && s[0] == '0')
  801b6d:	85 c0                	test   %eax,%eax
  801b6f:	75 0c                	jne    801b7d <strtol+0x6a>
    s++, base = 8;
  else if (base == 0)
    base = 10;
  801b71:	b0 0a                	mov    $0xa,%al
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
  801b73:	80 3a 30             	cmpb   $0x30,(%edx)
  801b76:	75 05                	jne    801b7d <strtol+0x6a>
    s++, base = 8;
  801b78:	83 c2 01             	add    $0x1,%edx
  801b7b:	b0 08                	mov    $0x8,%al
  else if (base == 0)
    base = 10;
  801b7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b82:	89 45 10             	mov    %eax,0x10(%ebp)

  // digits
  while (1) {
    int dig;

    if (*s >= '0' && *s <= '9')
  801b85:	0f b6 0a             	movzbl (%edx),%ecx
  801b88:	8d 71 d0             	lea    -0x30(%ecx),%esi
  801b8b:	89 f0                	mov    %esi,%eax
  801b8d:	3c 09                	cmp    $0x9,%al
  801b8f:	77 08                	ja     801b99 <strtol+0x86>
      dig = *s - '0';
  801b91:	0f be c9             	movsbl %cl,%ecx
  801b94:	83 e9 30             	sub    $0x30,%ecx
  801b97:	eb 20                	jmp    801bb9 <strtol+0xa6>
    else if (*s >= 'a' && *s <= 'z')
  801b99:	8d 71 9f             	lea    -0x61(%ecx),%esi
  801b9c:	89 f0                	mov    %esi,%eax
  801b9e:	3c 19                	cmp    $0x19,%al
  801ba0:	77 08                	ja     801baa <strtol+0x97>
      dig = *s - 'a' + 10;
  801ba2:	0f be c9             	movsbl %cl,%ecx
  801ba5:	83 e9 57             	sub    $0x57,%ecx
  801ba8:	eb 0f                	jmp    801bb9 <strtol+0xa6>
    else if (*s >= 'A' && *s <= 'Z')
  801baa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  801bad:	89 f0                	mov    %esi,%eax
  801baf:	3c 19                	cmp    $0x19,%al
  801bb1:	77 16                	ja     801bc9 <strtol+0xb6>
      dig = *s - 'A' + 10;
  801bb3:	0f be c9             	movsbl %cl,%ecx
  801bb6:	83 e9 37             	sub    $0x37,%ecx
    else
      break;
    if (dig >= base)
  801bb9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  801bbc:	7d 0f                	jge    801bcd <strtol+0xba>
      break;
    s++, val = (val * base) + dig;
  801bbe:	83 c2 01             	add    $0x1,%edx
  801bc1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801bc5:	01 cb                	add    %ecx,%ebx
    // we don't properly detect overflow!
  }
  801bc7:	eb bc                	jmp    801b85 <strtol+0x72>
  801bc9:	89 d8                	mov    %ebx,%eax
  801bcb:	eb 02                	jmp    801bcf <strtol+0xbc>
  801bcd:	89 d8                	mov    %ebx,%eax

  if (endptr)
  801bcf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801bd3:	74 05                	je     801bda <strtol+0xc7>
    *endptr = (char*)s;
  801bd5:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bd8:	89 16                	mov    %edx,(%esi)
  return neg ? -val : val;
  801bda:	f7 d8                	neg    %eax
  801bdc:	85 ff                	test   %edi,%edi
  801bde:	0f 44 c3             	cmove  %ebx,%eax
}
  801be1:	5b                   	pop    %ebx
  801be2:	5e                   	pop    %esi
  801be3:	5f                   	pop    %edi
  801be4:	5d                   	pop    %ebp
  801be5:	c3                   	ret    

00801be6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801be6:	55                   	push   %ebp
  801be7:	89 e5                	mov    %esp,%ebp
  801be9:	83 ec 18             	sub    $0x18,%esp
  int r;

  if (_pgfault_handler == 0) {
  801bec:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801bf3:	75 70                	jne    801c65 <set_pgfault_handler+0x7f>
    // First time through!
    // LAB 4: Your code here.
    if(sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_SYSCALL) < 0) {
  801bf5:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  801bfc:	00 
  801bfd:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801c04:	ee 
  801c05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c0c:	e8 76 e5 ff ff       	call   800187 <sys_page_alloc>
  801c11:	85 c0                	test   %eax,%eax
  801c13:	79 1c                	jns    801c31 <set_pgfault_handler+0x4b>
      panic("In set_pgfault_handler, sys_page_alloc error");
  801c15:	c7 44 24 08 a0 24 80 	movl   $0x8024a0,0x8(%esp)
  801c1c:	00 
  801c1d:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801c24:	00 
  801c25:	c7 04 24 0c 25 80 00 	movl   $0x80250c,(%esp)
  801c2c:	e8 45 f5 ff ff       	call   801176 <_panic>
    }
    if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  801c31:	c7 44 24 04 ef 03 80 	movl   $0x8003ef,0x4(%esp)
  801c38:	00 
  801c39:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c40:	e8 e2 e6 ff ff       	call   800327 <sys_env_set_pgfault_upcall>
  801c45:	85 c0                	test   %eax,%eax
  801c47:	79 1c                	jns    801c65 <set_pgfault_handler+0x7f>
      panic("In set_pgfault_handler, sys_env_set_pgfault_upcall error");
  801c49:	c7 44 24 08 d0 24 80 	movl   $0x8024d0,0x8(%esp)
  801c50:	00 
  801c51:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  801c58:	00 
  801c59:	c7 04 24 0c 25 80 00 	movl   $0x80250c,(%esp)
  801c60:	e8 11 f5 ff ff       	call   801176 <_panic>
    }
  }
  // Save handler pointer for assembly to call.
  _pgfault_handler = handler;
  801c65:	8b 45 08             	mov    0x8(%ebp),%eax
  801c68:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801c6d:	c9                   	leave  
  801c6e:	c3                   	ret    

00801c6f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c6f:	55                   	push   %ebp
  801c70:	89 e5                	mov    %esp,%ebp
  801c72:	56                   	push   %esi
  801c73:	53                   	push   %ebx
  801c74:	83 ec 10             	sub    $0x10,%esp
  801c77:	8b 75 08             	mov    0x8(%ebp),%esi
  801c7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;
  801c80:	85 c0                	test   %eax,%eax
  801c82:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801c87:	0f 44 c2             	cmove  %edx,%eax
  if ((r = sys_ipc_recv(pg)) < 0) {
  801c8a:	89 04 24             	mov    %eax,(%esp)
  801c8d:	e8 0b e7 ff ff       	call   80039d <sys_ipc_recv>
  801c92:	85 c0                	test   %eax,%eax
  801c94:	79 34                	jns    801cca <ipc_recv+0x5b>
    if (from_env_store)
  801c96:	85 f6                	test   %esi,%esi
  801c98:	74 06                	je     801ca0 <ipc_recv+0x31>
      *from_env_store = 0;
  801c9a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (perm_store)
  801ca0:	85 db                	test   %ebx,%ebx
  801ca2:	74 06                	je     801caa <ipc_recv+0x3b>
      *perm_store = 0;
  801ca4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    panic("sys_ipc_recv: %e", r);
  801caa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cae:	c7 44 24 08 1a 25 80 	movl   $0x80251a,0x8(%esp)
  801cb5:	00 
  801cb6:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801cbd:	00 
  801cbe:	c7 04 24 2b 25 80 00 	movl   $0x80252b,(%esp)
  801cc5:	e8 ac f4 ff ff       	call   801176 <_panic>
  }

  if (from_env_store)
  801cca:	85 f6                	test   %esi,%esi
  801ccc:	74 0a                	je     801cd8 <ipc_recv+0x69>
    *from_env_store = thisenv->env_ipc_from;
  801cce:	a1 04 40 80 00       	mov    0x804004,%eax
  801cd3:	8b 40 74             	mov    0x74(%eax),%eax
  801cd6:	89 06                	mov    %eax,(%esi)
  if (perm_store)
  801cd8:	85 db                	test   %ebx,%ebx
  801cda:	74 0a                	je     801ce6 <ipc_recv+0x77>
    *perm_store |= thisenv->env_ipc_perm;
  801cdc:	a1 04 40 80 00       	mov    0x804004,%eax
  801ce1:	8b 40 78             	mov    0x78(%eax),%eax
  801ce4:	09 03                	or     %eax,(%ebx)

  return thisenv->env_ipc_value;
  801ce6:	a1 04 40 80 00       	mov    0x804004,%eax
  801ceb:	8b 40 70             	mov    0x70(%eax),%eax

}
  801cee:	83 c4 10             	add    $0x10,%esp
  801cf1:	5b                   	pop    %ebx
  801cf2:	5e                   	pop    %esi
  801cf3:	5d                   	pop    %ebp
  801cf4:	c3                   	ret    

00801cf5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801cf5:	55                   	push   %ebp
  801cf6:	89 e5                	mov    %esp,%ebp
  801cf8:	57                   	push   %edi
  801cf9:	56                   	push   %esi
  801cfa:	53                   	push   %ebx
  801cfb:	83 ec 1c             	sub    $0x1c,%esp
  801cfe:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d01:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d04:	8b 5d 10             	mov    0x10(%ebp),%ebx
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;
  801d07:	85 db                	test   %ebx,%ebx
  801d09:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801d0e:	0f 44 d8             	cmove  %eax,%ebx

  while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801d11:	eb 2a                	jmp    801d3d <ipc_send+0x48>
    if (r != -E_IPC_NOT_RECV)
  801d13:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d16:	74 20                	je     801d38 <ipc_send+0x43>
      panic("ipc_send: %e", r);
  801d18:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d1c:	c7 44 24 08 35 25 80 	movl   $0x802535,0x8(%esp)
  801d23:	00 
  801d24:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801d2b:	00 
  801d2c:	c7 04 24 2b 25 80 00 	movl   $0x80252b,(%esp)
  801d33:	e8 3e f4 ff ff       	call   801176 <_panic>
    sys_yield();
  801d38:	e8 2b e4 ff ff       	call   800168 <sys_yield>
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;

  while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801d3d:	8b 45 14             	mov    0x14(%ebp),%eax
  801d40:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d44:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d48:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d4c:	89 3c 24             	mov    %edi,(%esp)
  801d4f:	e8 26 e6 ff ff       	call   80037a <sys_ipc_try_send>
  801d54:	85 c0                	test   %eax,%eax
  801d56:	78 bb                	js     801d13 <ipc_send+0x1e>
    if (r != -E_IPC_NOT_RECV)
      panic("ipc_send: %e", r);
    sys_yield();
  }
}
  801d58:	83 c4 1c             	add    $0x1c,%esp
  801d5b:	5b                   	pop    %ebx
  801d5c:	5e                   	pop    %esi
  801d5d:	5f                   	pop    %edi
  801d5e:	5d                   	pop    %ebp
  801d5f:	c3                   	ret    

00801d60 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d60:	55                   	push   %ebp
  801d61:	89 e5                	mov    %esp,%ebp
  801d63:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int i;

  for (i = 0; i < NENV; i++)
  801d66:	b8 00 00 00 00       	mov    $0x0,%eax
    if (envs[i].env_type == type)
  801d6b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d6e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d74:	8b 52 50             	mov    0x50(%edx),%edx
  801d77:	39 ca                	cmp    %ecx,%edx
  801d79:	75 0d                	jne    801d88 <ipc_find_env+0x28>
      return envs[i].env_id;
  801d7b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d7e:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801d83:	8b 40 40             	mov    0x40(%eax),%eax
  801d86:	eb 0e                	jmp    801d96 <ipc_find_env+0x36>
envid_t
ipc_find_env(enum EnvType type)
{
  int i;

  for (i = 0; i < NENV; i++)
  801d88:	83 c0 01             	add    $0x1,%eax
  801d8b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d90:	75 d9                	jne    801d6b <ipc_find_env+0xb>
    if (envs[i].env_type == type)
      return envs[i].env_id;
  return 0;
  801d92:	66 b8 00 00          	mov    $0x0,%ax
}
  801d96:	5d                   	pop    %ebp
  801d97:	c3                   	ret    

00801d98 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d98:	55                   	push   %ebp
  801d99:	89 e5                	mov    %esp,%ebp
  801d9b:	8b 55 08             	mov    0x8(%ebp),%edx
  pte_t pte;

  if (!(uvpd[PDX(v)] & PTE_P))
  801d9e:	89 d0                	mov    %edx,%eax
  801da0:	c1 e8 16             	shr    $0x16,%eax
  801da3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
    return 0;
  801daa:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
  pte_t pte;

  if (!(uvpd[PDX(v)] & PTE_P))
  801daf:	f6 c1 01             	test   $0x1,%cl
  801db2:	74 1d                	je     801dd1 <pageref+0x39>
    return 0;
  pte = uvpt[PGNUM(v)];
  801db4:	c1 ea 0c             	shr    $0xc,%edx
  801db7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  if (!(pte & PTE_P))
  801dbe:	f6 c2 01             	test   $0x1,%dl
  801dc1:	74 0e                	je     801dd1 <pageref+0x39>
    return 0;
  return pages[PGNUM(pte)].pp_ref;
  801dc3:	c1 ea 0c             	shr    $0xc,%edx
  801dc6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801dcd:	ef 
  801dce:	0f b7 c0             	movzwl %ax,%eax
}
  801dd1:	5d                   	pop    %ebp
  801dd2:	c3                   	ret    
  801dd3:	66 90                	xchg   %ax,%ax
  801dd5:	66 90                	xchg   %ax,%ax
  801dd7:	66 90                	xchg   %ax,%ax
  801dd9:	66 90                	xchg   %ax,%ax
  801ddb:	66 90                	xchg   %ax,%ax
  801ddd:	66 90                	xchg   %ax,%ax
  801ddf:	90                   	nop

00801de0 <__udivdi3>:
  801de0:	55                   	push   %ebp
  801de1:	57                   	push   %edi
  801de2:	56                   	push   %esi
  801de3:	83 ec 0c             	sub    $0xc,%esp
  801de6:	8b 44 24 28          	mov    0x28(%esp),%eax
  801dea:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801dee:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801df2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801df6:	85 c0                	test   %eax,%eax
  801df8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801dfc:	89 ea                	mov    %ebp,%edx
  801dfe:	89 0c 24             	mov    %ecx,(%esp)
  801e01:	75 2d                	jne    801e30 <__udivdi3+0x50>
  801e03:	39 e9                	cmp    %ebp,%ecx
  801e05:	77 61                	ja     801e68 <__udivdi3+0x88>
  801e07:	85 c9                	test   %ecx,%ecx
  801e09:	89 ce                	mov    %ecx,%esi
  801e0b:	75 0b                	jne    801e18 <__udivdi3+0x38>
  801e0d:	b8 01 00 00 00       	mov    $0x1,%eax
  801e12:	31 d2                	xor    %edx,%edx
  801e14:	f7 f1                	div    %ecx
  801e16:	89 c6                	mov    %eax,%esi
  801e18:	31 d2                	xor    %edx,%edx
  801e1a:	89 e8                	mov    %ebp,%eax
  801e1c:	f7 f6                	div    %esi
  801e1e:	89 c5                	mov    %eax,%ebp
  801e20:	89 f8                	mov    %edi,%eax
  801e22:	f7 f6                	div    %esi
  801e24:	89 ea                	mov    %ebp,%edx
  801e26:	83 c4 0c             	add    $0xc,%esp
  801e29:	5e                   	pop    %esi
  801e2a:	5f                   	pop    %edi
  801e2b:	5d                   	pop    %ebp
  801e2c:	c3                   	ret    
  801e2d:	8d 76 00             	lea    0x0(%esi),%esi
  801e30:	39 e8                	cmp    %ebp,%eax
  801e32:	77 24                	ja     801e58 <__udivdi3+0x78>
  801e34:	0f bd e8             	bsr    %eax,%ebp
  801e37:	83 f5 1f             	xor    $0x1f,%ebp
  801e3a:	75 3c                	jne    801e78 <__udivdi3+0x98>
  801e3c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801e40:	39 34 24             	cmp    %esi,(%esp)
  801e43:	0f 86 9f 00 00 00    	jbe    801ee8 <__udivdi3+0x108>
  801e49:	39 d0                	cmp    %edx,%eax
  801e4b:	0f 82 97 00 00 00    	jb     801ee8 <__udivdi3+0x108>
  801e51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e58:	31 d2                	xor    %edx,%edx
  801e5a:	31 c0                	xor    %eax,%eax
  801e5c:	83 c4 0c             	add    $0xc,%esp
  801e5f:	5e                   	pop    %esi
  801e60:	5f                   	pop    %edi
  801e61:	5d                   	pop    %ebp
  801e62:	c3                   	ret    
  801e63:	90                   	nop
  801e64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e68:	89 f8                	mov    %edi,%eax
  801e6a:	f7 f1                	div    %ecx
  801e6c:	31 d2                	xor    %edx,%edx
  801e6e:	83 c4 0c             	add    $0xc,%esp
  801e71:	5e                   	pop    %esi
  801e72:	5f                   	pop    %edi
  801e73:	5d                   	pop    %ebp
  801e74:	c3                   	ret    
  801e75:	8d 76 00             	lea    0x0(%esi),%esi
  801e78:	89 e9                	mov    %ebp,%ecx
  801e7a:	8b 3c 24             	mov    (%esp),%edi
  801e7d:	d3 e0                	shl    %cl,%eax
  801e7f:	89 c6                	mov    %eax,%esi
  801e81:	b8 20 00 00 00       	mov    $0x20,%eax
  801e86:	29 e8                	sub    %ebp,%eax
  801e88:	89 c1                	mov    %eax,%ecx
  801e8a:	d3 ef                	shr    %cl,%edi
  801e8c:	89 e9                	mov    %ebp,%ecx
  801e8e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801e92:	8b 3c 24             	mov    (%esp),%edi
  801e95:	09 74 24 08          	or     %esi,0x8(%esp)
  801e99:	89 d6                	mov    %edx,%esi
  801e9b:	d3 e7                	shl    %cl,%edi
  801e9d:	89 c1                	mov    %eax,%ecx
  801e9f:	89 3c 24             	mov    %edi,(%esp)
  801ea2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ea6:	d3 ee                	shr    %cl,%esi
  801ea8:	89 e9                	mov    %ebp,%ecx
  801eaa:	d3 e2                	shl    %cl,%edx
  801eac:	89 c1                	mov    %eax,%ecx
  801eae:	d3 ef                	shr    %cl,%edi
  801eb0:	09 d7                	or     %edx,%edi
  801eb2:	89 f2                	mov    %esi,%edx
  801eb4:	89 f8                	mov    %edi,%eax
  801eb6:	f7 74 24 08          	divl   0x8(%esp)
  801eba:	89 d6                	mov    %edx,%esi
  801ebc:	89 c7                	mov    %eax,%edi
  801ebe:	f7 24 24             	mull   (%esp)
  801ec1:	39 d6                	cmp    %edx,%esi
  801ec3:	89 14 24             	mov    %edx,(%esp)
  801ec6:	72 30                	jb     801ef8 <__udivdi3+0x118>
  801ec8:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ecc:	89 e9                	mov    %ebp,%ecx
  801ece:	d3 e2                	shl    %cl,%edx
  801ed0:	39 c2                	cmp    %eax,%edx
  801ed2:	73 05                	jae    801ed9 <__udivdi3+0xf9>
  801ed4:	3b 34 24             	cmp    (%esp),%esi
  801ed7:	74 1f                	je     801ef8 <__udivdi3+0x118>
  801ed9:	89 f8                	mov    %edi,%eax
  801edb:	31 d2                	xor    %edx,%edx
  801edd:	e9 7a ff ff ff       	jmp    801e5c <__udivdi3+0x7c>
  801ee2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ee8:	31 d2                	xor    %edx,%edx
  801eea:	b8 01 00 00 00       	mov    $0x1,%eax
  801eef:	e9 68 ff ff ff       	jmp    801e5c <__udivdi3+0x7c>
  801ef4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ef8:	8d 47 ff             	lea    -0x1(%edi),%eax
  801efb:	31 d2                	xor    %edx,%edx
  801efd:	83 c4 0c             	add    $0xc,%esp
  801f00:	5e                   	pop    %esi
  801f01:	5f                   	pop    %edi
  801f02:	5d                   	pop    %ebp
  801f03:	c3                   	ret    
  801f04:	66 90                	xchg   %ax,%ax
  801f06:	66 90                	xchg   %ax,%ax
  801f08:	66 90                	xchg   %ax,%ax
  801f0a:	66 90                	xchg   %ax,%ax
  801f0c:	66 90                	xchg   %ax,%ax
  801f0e:	66 90                	xchg   %ax,%ax

00801f10 <__umoddi3>:
  801f10:	55                   	push   %ebp
  801f11:	57                   	push   %edi
  801f12:	56                   	push   %esi
  801f13:	83 ec 14             	sub    $0x14,%esp
  801f16:	8b 44 24 28          	mov    0x28(%esp),%eax
  801f1a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801f1e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801f22:	89 c7                	mov    %eax,%edi
  801f24:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f28:	8b 44 24 30          	mov    0x30(%esp),%eax
  801f2c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801f30:	89 34 24             	mov    %esi,(%esp)
  801f33:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f37:	85 c0                	test   %eax,%eax
  801f39:	89 c2                	mov    %eax,%edx
  801f3b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f3f:	75 17                	jne    801f58 <__umoddi3+0x48>
  801f41:	39 fe                	cmp    %edi,%esi
  801f43:	76 4b                	jbe    801f90 <__umoddi3+0x80>
  801f45:	89 c8                	mov    %ecx,%eax
  801f47:	89 fa                	mov    %edi,%edx
  801f49:	f7 f6                	div    %esi
  801f4b:	89 d0                	mov    %edx,%eax
  801f4d:	31 d2                	xor    %edx,%edx
  801f4f:	83 c4 14             	add    $0x14,%esp
  801f52:	5e                   	pop    %esi
  801f53:	5f                   	pop    %edi
  801f54:	5d                   	pop    %ebp
  801f55:	c3                   	ret    
  801f56:	66 90                	xchg   %ax,%ax
  801f58:	39 f8                	cmp    %edi,%eax
  801f5a:	77 54                	ja     801fb0 <__umoddi3+0xa0>
  801f5c:	0f bd e8             	bsr    %eax,%ebp
  801f5f:	83 f5 1f             	xor    $0x1f,%ebp
  801f62:	75 5c                	jne    801fc0 <__umoddi3+0xb0>
  801f64:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801f68:	39 3c 24             	cmp    %edi,(%esp)
  801f6b:	0f 87 e7 00 00 00    	ja     802058 <__umoddi3+0x148>
  801f71:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801f75:	29 f1                	sub    %esi,%ecx
  801f77:	19 c7                	sbb    %eax,%edi
  801f79:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f7d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f81:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f85:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801f89:	83 c4 14             	add    $0x14,%esp
  801f8c:	5e                   	pop    %esi
  801f8d:	5f                   	pop    %edi
  801f8e:	5d                   	pop    %ebp
  801f8f:	c3                   	ret    
  801f90:	85 f6                	test   %esi,%esi
  801f92:	89 f5                	mov    %esi,%ebp
  801f94:	75 0b                	jne    801fa1 <__umoddi3+0x91>
  801f96:	b8 01 00 00 00       	mov    $0x1,%eax
  801f9b:	31 d2                	xor    %edx,%edx
  801f9d:	f7 f6                	div    %esi
  801f9f:	89 c5                	mov    %eax,%ebp
  801fa1:	8b 44 24 04          	mov    0x4(%esp),%eax
  801fa5:	31 d2                	xor    %edx,%edx
  801fa7:	f7 f5                	div    %ebp
  801fa9:	89 c8                	mov    %ecx,%eax
  801fab:	f7 f5                	div    %ebp
  801fad:	eb 9c                	jmp    801f4b <__umoddi3+0x3b>
  801faf:	90                   	nop
  801fb0:	89 c8                	mov    %ecx,%eax
  801fb2:	89 fa                	mov    %edi,%edx
  801fb4:	83 c4 14             	add    $0x14,%esp
  801fb7:	5e                   	pop    %esi
  801fb8:	5f                   	pop    %edi
  801fb9:	5d                   	pop    %ebp
  801fba:	c3                   	ret    
  801fbb:	90                   	nop
  801fbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fc0:	8b 04 24             	mov    (%esp),%eax
  801fc3:	be 20 00 00 00       	mov    $0x20,%esi
  801fc8:	89 e9                	mov    %ebp,%ecx
  801fca:	29 ee                	sub    %ebp,%esi
  801fcc:	d3 e2                	shl    %cl,%edx
  801fce:	89 f1                	mov    %esi,%ecx
  801fd0:	d3 e8                	shr    %cl,%eax
  801fd2:	89 e9                	mov    %ebp,%ecx
  801fd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd8:	8b 04 24             	mov    (%esp),%eax
  801fdb:	09 54 24 04          	or     %edx,0x4(%esp)
  801fdf:	89 fa                	mov    %edi,%edx
  801fe1:	d3 e0                	shl    %cl,%eax
  801fe3:	89 f1                	mov    %esi,%ecx
  801fe5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fe9:	8b 44 24 10          	mov    0x10(%esp),%eax
  801fed:	d3 ea                	shr    %cl,%edx
  801fef:	89 e9                	mov    %ebp,%ecx
  801ff1:	d3 e7                	shl    %cl,%edi
  801ff3:	89 f1                	mov    %esi,%ecx
  801ff5:	d3 e8                	shr    %cl,%eax
  801ff7:	89 e9                	mov    %ebp,%ecx
  801ff9:	09 f8                	or     %edi,%eax
  801ffb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801fff:	f7 74 24 04          	divl   0x4(%esp)
  802003:	d3 e7                	shl    %cl,%edi
  802005:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802009:	89 d7                	mov    %edx,%edi
  80200b:	f7 64 24 08          	mull   0x8(%esp)
  80200f:	39 d7                	cmp    %edx,%edi
  802011:	89 c1                	mov    %eax,%ecx
  802013:	89 14 24             	mov    %edx,(%esp)
  802016:	72 2c                	jb     802044 <__umoddi3+0x134>
  802018:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80201c:	72 22                	jb     802040 <__umoddi3+0x130>
  80201e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802022:	29 c8                	sub    %ecx,%eax
  802024:	19 d7                	sbb    %edx,%edi
  802026:	89 e9                	mov    %ebp,%ecx
  802028:	89 fa                	mov    %edi,%edx
  80202a:	d3 e8                	shr    %cl,%eax
  80202c:	89 f1                	mov    %esi,%ecx
  80202e:	d3 e2                	shl    %cl,%edx
  802030:	89 e9                	mov    %ebp,%ecx
  802032:	d3 ef                	shr    %cl,%edi
  802034:	09 d0                	or     %edx,%eax
  802036:	89 fa                	mov    %edi,%edx
  802038:	83 c4 14             	add    $0x14,%esp
  80203b:	5e                   	pop    %esi
  80203c:	5f                   	pop    %edi
  80203d:	5d                   	pop    %ebp
  80203e:	c3                   	ret    
  80203f:	90                   	nop
  802040:	39 d7                	cmp    %edx,%edi
  802042:	75 da                	jne    80201e <__umoddi3+0x10e>
  802044:	8b 14 24             	mov    (%esp),%edx
  802047:	89 c1                	mov    %eax,%ecx
  802049:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80204d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802051:	eb cb                	jmp    80201e <__umoddi3+0x10e>
  802053:	90                   	nop
  802054:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802058:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80205c:	0f 82 0f ff ff ff    	jb     801f71 <__umoddi3+0x61>
  802062:	e9 1a ff ff ff       	jmp    801f81 <__umoddi3+0x71>
