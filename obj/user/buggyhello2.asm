
obj/user/buggyhello2.debug:     file format elf32-i386


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

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
  sys_cputs(hello, 1024*1024);
  800039:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800040:	00 
  800041:	a1 00 30 80 00       	mov    0x803000,%eax
  800046:	89 04 24             	mov    %eax,(%esp)
  800049:	e8 63 00 00 00       	call   8000b1 <sys_cputs>
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
  80005e:	e8 dd 00 00 00       	call   800140 <sys_getenvid>
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
  80007b:	a3 04 30 80 00       	mov    %eax,0x803004

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
  80009e:	e8 22 05 00 00       	call   8005c5 <close_all>
  sys_env_destroy(0);
  8000a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000aa:	e8 3f 00 00 00       	call   8000ee <sys_env_destroy>
}
  8000af:	c9                   	leave  
  8000b0:	c3                   	ret    

008000b1 <sys_cputs>:
  return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b1:	55                   	push   %ebp
  8000b2:	89 e5                	mov    %esp,%ebp
  8000b4:	57                   	push   %edi
  8000b5:	56                   	push   %esi
  8000b6:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8000b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c2:	89 c3                	mov    %eax,%ebx
  8000c4:	89 c7                	mov    %eax,%edi
  8000c6:	89 c6                	mov    %eax,%esi
  8000c8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
  syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ca:	5b                   	pop    %ebx
  8000cb:	5e                   	pop    %esi
  8000cc:	5f                   	pop    %edi
  8000cd:	5d                   	pop    %ebp
  8000ce:	c3                   	ret    

008000cf <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	57                   	push   %edi
  8000d3:	56                   	push   %esi
  8000d4:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8000d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8000da:	b8 01 00 00 00       	mov    $0x1,%eax
  8000df:	89 d1                	mov    %edx,%ecx
  8000e1:	89 d3                	mov    %edx,%ebx
  8000e3:	89 d7                	mov    %edx,%edi
  8000e5:	89 d6                	mov    %edx,%esi
  8000e7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5f                   	pop    %edi
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    

008000ee <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	57                   	push   %edi
  8000f2:	56                   	push   %esi
  8000f3:	53                   	push   %ebx
  8000f4:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8000f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fc:	b8 03 00 00 00       	mov    $0x3,%eax
  800101:	8b 55 08             	mov    0x8(%ebp),%edx
  800104:	89 cb                	mov    %ecx,%ebx
  800106:	89 cf                	mov    %ecx,%edi
  800108:	89 ce                	mov    %ecx,%esi
  80010a:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  80010c:	85 c0                	test   %eax,%eax
  80010e:	7e 28                	jle    800138 <sys_env_destroy+0x4a>
    panic("syscall %d returned %d (> 0)", num, ret);
  800110:	89 44 24 10          	mov    %eax,0x10(%esp)
  800114:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80011b:	00 
  80011c:	c7 44 24 08 d8 1f 80 	movl   $0x801fd8,0x8(%esp)
  800123:	00 
  800124:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80012b:	00 
  80012c:	c7 04 24 f5 1f 80 00 	movl   $0x801ff5,(%esp)
  800133:	e8 0e 10 00 00       	call   801146 <_panic>

int
sys_env_destroy(envid_t envid)
{
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800138:	83 c4 2c             	add    $0x2c,%esp
  80013b:	5b                   	pop    %ebx
  80013c:	5e                   	pop    %esi
  80013d:	5f                   	pop    %edi
  80013e:	5d                   	pop    %ebp
  80013f:	c3                   	ret    

00800140 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	57                   	push   %edi
  800144:	56                   	push   %esi
  800145:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800146:	ba 00 00 00 00       	mov    $0x0,%edx
  80014b:	b8 02 00 00 00       	mov    $0x2,%eax
  800150:	89 d1                	mov    %edx,%ecx
  800152:	89 d3                	mov    %edx,%ebx
  800154:	89 d7                	mov    %edx,%edi
  800156:	89 d6                	mov    %edx,%esi
  800158:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015a:	5b                   	pop    %ebx
  80015b:	5e                   	pop    %esi
  80015c:	5f                   	pop    %edi
  80015d:	5d                   	pop    %ebp
  80015e:	c3                   	ret    

0080015f <sys_yield>:

void
sys_yield(void)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	57                   	push   %edi
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800165:	ba 00 00 00 00       	mov    $0x0,%edx
  80016a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80016f:	89 d1                	mov    %edx,%ecx
  800171:	89 d3                	mov    %edx,%ebx
  800173:	89 d7                	mov    %edx,%edi
  800175:	89 d6                	mov    %edx,%esi
  800177:	cd 30                	int    $0x30

void
sys_yield(void)
{
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800179:	5b                   	pop    %ebx
  80017a:	5e                   	pop    %esi
  80017b:	5f                   	pop    %edi
  80017c:	5d                   	pop    %ebp
  80017d:	c3                   	ret    

0080017e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80017e:	55                   	push   %ebp
  80017f:	89 e5                	mov    %esp,%ebp
  800181:	57                   	push   %edi
  800182:	56                   	push   %esi
  800183:	53                   	push   %ebx
  800184:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800187:	be 00 00 00 00       	mov    $0x0,%esi
  80018c:	b8 04 00 00 00       	mov    $0x4,%eax
  800191:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800194:	8b 55 08             	mov    0x8(%ebp),%edx
  800197:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019a:	89 f7                	mov    %esi,%edi
  80019c:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	7e 28                	jle    8001ca <sys_page_alloc+0x4c>
    panic("syscall %d returned %d (> 0)", num, ret);
  8001a2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001a6:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001ad:	00 
  8001ae:	c7 44 24 08 d8 1f 80 	movl   $0x801fd8,0x8(%esp)
  8001b5:	00 
  8001b6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001bd:	00 
  8001be:	c7 04 24 f5 1f 80 00 	movl   $0x801ff5,(%esp)
  8001c5:	e8 7c 0f 00 00       	call   801146 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  return syscall(SYS_page_alloc, 1, envid, (uint32_t)va, perm, 0, 0);
}
  8001ca:	83 c4 2c             	add    $0x2c,%esp
  8001cd:	5b                   	pop    %ebx
  8001ce:	5e                   	pop    %esi
  8001cf:	5f                   	pop    %edi
  8001d0:	5d                   	pop    %ebp
  8001d1:	c3                   	ret    

008001d2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	57                   	push   %edi
  8001d6:	56                   	push   %esi
  8001d7:	53                   	push   %ebx
  8001d8:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8001db:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e9:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ec:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ef:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  8001f1:	85 c0                	test   %eax,%eax
  8001f3:	7e 28                	jle    80021d <sys_page_map+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  8001f5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001f9:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800200:	00 
  800201:	c7 44 24 08 d8 1f 80 	movl   $0x801fd8,0x8(%esp)
  800208:	00 
  800209:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800210:	00 
  800211:	c7 04 24 f5 1f 80 00 	movl   $0x801ff5,(%esp)
  800218:	e8 29 0f 00 00       	call   801146 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  return syscall(SYS_page_map, 1, srcenv, (uint32_t)srcva, dstenv, (uint32_t)dstva, perm);
}
  80021d:	83 c4 2c             	add    $0x2c,%esp
  800220:	5b                   	pop    %ebx
  800221:	5e                   	pop    %esi
  800222:	5f                   	pop    %edi
  800223:	5d                   	pop    %ebp
  800224:	c3                   	ret    

00800225 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  80022e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800233:	b8 06 00 00 00       	mov    $0x6,%eax
  800238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	89 df                	mov    %ebx,%edi
  800240:	89 de                	mov    %ebx,%esi
  800242:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800244:	85 c0                	test   %eax,%eax
  800246:	7e 28                	jle    800270 <sys_page_unmap+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800248:	89 44 24 10          	mov    %eax,0x10(%esp)
  80024c:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800253:	00 
  800254:	c7 44 24 08 d8 1f 80 	movl   $0x801fd8,0x8(%esp)
  80025b:	00 
  80025c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800263:	00 
  800264:	c7 04 24 f5 1f 80 00 	movl   $0x801ff5,(%esp)
  80026b:	e8 d6 0e 00 00       	call   801146 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
  return syscall(SYS_page_unmap, 1, envid, (uint32_t)va, 0, 0, 0);
}
  800270:	83 c4 2c             	add    $0x2c,%esp
  800273:	5b                   	pop    %ebx
  800274:	5e                   	pop    %esi
  800275:	5f                   	pop    %edi
  800276:	5d                   	pop    %ebp
  800277:	c3                   	ret    

00800278 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	57                   	push   %edi
  80027c:	56                   	push   %esi
  80027d:	53                   	push   %ebx
  80027e:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800281:	bb 00 00 00 00       	mov    $0x0,%ebx
  800286:	b8 08 00 00 00       	mov    $0x8,%eax
  80028b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028e:	8b 55 08             	mov    0x8(%ebp),%edx
  800291:	89 df                	mov    %ebx,%edi
  800293:	89 de                	mov    %ebx,%esi
  800295:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800297:	85 c0                	test   %eax,%eax
  800299:	7e 28                	jle    8002c3 <sys_env_set_status+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  80029b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80029f:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002a6:	00 
  8002a7:	c7 44 24 08 d8 1f 80 	movl   $0x801fd8,0x8(%esp)
  8002ae:	00 
  8002af:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b6:	00 
  8002b7:	c7 04 24 f5 1f 80 00 	movl   $0x801ff5,(%esp)
  8002be:	e8 83 0e 00 00       	call   801146 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002c3:	83 c4 2c             	add    $0x2c,%esp
  8002c6:	5b                   	pop    %ebx
  8002c7:	5e                   	pop    %esi
  8002c8:	5f                   	pop    %edi
  8002c9:	5d                   	pop    %ebp
  8002ca:	c3                   	ret    

008002cb <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	57                   	push   %edi
  8002cf:	56                   	push   %esi
  8002d0:	53                   	push   %ebx
  8002d1:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8002d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d9:	b8 09 00 00 00       	mov    $0x9,%eax
  8002de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e4:	89 df                	mov    %ebx,%edi
  8002e6:	89 de                	mov    %ebx,%esi
  8002e8:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  8002ea:	85 c0                	test   %eax,%eax
  8002ec:	7e 28                	jle    800316 <sys_env_set_trapframe+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  8002ee:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002f2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002f9:	00 
  8002fa:	c7 44 24 08 d8 1f 80 	movl   $0x801fd8,0x8(%esp)
  800301:	00 
  800302:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800309:	00 
  80030a:	c7 04 24 f5 1f 80 00 	movl   $0x801ff5,(%esp)
  800311:	e8 30 0e 00 00       	call   801146 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t)tf, 0, 0, 0);
}
  800316:	83 c4 2c             	add    $0x2c,%esp
  800319:	5b                   	pop    %ebx
  80031a:	5e                   	pop    %esi
  80031b:	5f                   	pop    %edi
  80031c:	5d                   	pop    %ebp
  80031d:	c3                   	ret    

0080031e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80031e:	55                   	push   %ebp
  80031f:	89 e5                	mov    %esp,%ebp
  800321:	57                   	push   %edi
  800322:	56                   	push   %esi
  800323:	53                   	push   %ebx
  800324:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800327:	bb 00 00 00 00       	mov    $0x0,%ebx
  80032c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800331:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800334:	8b 55 08             	mov    0x8(%ebp),%edx
  800337:	89 df                	mov    %ebx,%edi
  800339:	89 de                	mov    %ebx,%esi
  80033b:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  80033d:	85 c0                	test   %eax,%eax
  80033f:	7e 28                	jle    800369 <sys_env_set_pgfault_upcall+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800341:	89 44 24 10          	mov    %eax,0x10(%esp)
  800345:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80034c:	00 
  80034d:	c7 44 24 08 d8 1f 80 	movl   $0x801fd8,0x8(%esp)
  800354:	00 
  800355:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80035c:	00 
  80035d:	c7 04 24 f5 1f 80 00 	movl   $0x801ff5,(%esp)
  800364:	e8 dd 0d 00 00       	call   801146 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800369:	83 c4 2c             	add    $0x2c,%esp
  80036c:	5b                   	pop    %ebx
  80036d:	5e                   	pop    %esi
  80036e:	5f                   	pop    %edi
  80036f:	5d                   	pop    %ebp
  800370:	c3                   	ret    

00800371 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	57                   	push   %edi
  800375:	56                   	push   %esi
  800376:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800377:	be 00 00 00 00       	mov    $0x0,%esi
  80037c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800381:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800384:	8b 55 08             	mov    0x8(%ebp),%edx
  800387:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80038a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80038d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t)srcva, perm, 0);
}
  80038f:	5b                   	pop    %ebx
  800390:	5e                   	pop    %esi
  800391:	5f                   	pop    %edi
  800392:	5d                   	pop    %ebp
  800393:	c3                   	ret    

00800394 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	57                   	push   %edi
  800398:	56                   	push   %esi
  800399:	53                   	push   %ebx
  80039a:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  80039d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a2:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8003aa:	89 cb                	mov    %ecx,%ebx
  8003ac:	89 cf                	mov    %ecx,%edi
  8003ae:	89 ce                	mov    %ecx,%esi
  8003b0:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  8003b2:	85 c0                	test   %eax,%eax
  8003b4:	7e 28                	jle    8003de <sys_ipc_recv+0x4a>
    panic("syscall %d returned %d (> 0)", num, ret);
  8003b6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003ba:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003c1:	00 
  8003c2:	c7 44 24 08 d8 1f 80 	movl   $0x801fd8,0x8(%esp)
  8003c9:	00 
  8003ca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003d1:	00 
  8003d2:	c7 04 24 f5 1f 80 00 	movl   $0x801ff5,(%esp)
  8003d9:	e8 68 0d 00 00       	call   801146 <_panic>

int
sys_ipc_recv(void *dstva)
{
  return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003de:	83 c4 2c             	add    $0x2c,%esp
  8003e1:	5b                   	pop    %ebx
  8003e2:	5e                   	pop    %esi
  8003e3:	5f                   	pop    %edi
  8003e4:	5d                   	pop    %ebp
  8003e5:	c3                   	ret    
  8003e6:	66 90                	xchg   %ax,%ax
  8003e8:	66 90                	xchg   %ax,%ax
  8003ea:	66 90                	xchg   %ax,%ax
  8003ec:	66 90                	xchg   %ax,%ax
  8003ee:	66 90                	xchg   %ax,%ax

008003f0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  8003f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8003fb:	c1 e8 0c             	shr    $0xc,%eax
}
  8003fe:	5d                   	pop    %ebp
  8003ff:	c3                   	ret    

00800400 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800400:	55                   	push   %ebp
  800401:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  800403:	8b 45 08             	mov    0x8(%ebp),%eax
  800406:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
  return INDEX2DATA(fd2num(fd));
  80040b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800410:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800415:	5d                   	pop    %ebp
  800416:	c3                   	ret    

00800417 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
  80041a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
  int i;
  struct Fd *fd;

  for (i = 0; i < MAXFD; i++) {
    fd = INDEX2FD(i);
    if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800422:	89 c2                	mov    %eax,%edx
  800424:	c1 ea 16             	shr    $0x16,%edx
  800427:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80042e:	f6 c2 01             	test   $0x1,%dl
  800431:	74 11                	je     800444 <fd_alloc+0x2d>
  800433:	89 c2                	mov    %eax,%edx
  800435:	c1 ea 0c             	shr    $0xc,%edx
  800438:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80043f:	f6 c2 01             	test   $0x1,%dl
  800442:	75 09                	jne    80044d <fd_alloc+0x36>
      *fd_store = fd;
  800444:	89 01                	mov    %eax,(%ecx)
      return 0;
  800446:	b8 00 00 00 00       	mov    $0x0,%eax
  80044b:	eb 17                	jmp    800464 <fd_alloc+0x4d>
  80044d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
  int i;
  struct Fd *fd;

  for (i = 0; i < MAXFD; i++) {
  800452:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800457:	75 c9                	jne    800422 <fd_alloc+0xb>
    if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
      *fd_store = fd;
      return 0;
    }
  }
  *fd_store = 0;
  800459:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
  return -E_MAX_OPEN;
  80045f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800464:	5d                   	pop    %ebp
  800465:	c3                   	ret    

00800466 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800466:	55                   	push   %ebp
  800467:	89 e5                	mov    %esp,%ebp
  800469:	8b 45 08             	mov    0x8(%ebp),%eax
  struct Fd *fd;

  if (fdnum < 0 || fdnum >= MAXFD) {
  80046c:	83 f8 1f             	cmp    $0x1f,%eax
  80046f:	77 36                	ja     8004a7 <fd_lookup+0x41>
    if (debug)
      cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  fd = INDEX2FD(fdnum);
  800471:	c1 e0 0c             	shl    $0xc,%eax
  800474:	2d 00 00 00 30       	sub    $0x30000000,%eax
  if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800479:	89 c2                	mov    %eax,%edx
  80047b:	c1 ea 16             	shr    $0x16,%edx
  80047e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800485:	f6 c2 01             	test   $0x1,%dl
  800488:	74 24                	je     8004ae <fd_lookup+0x48>
  80048a:	89 c2                	mov    %eax,%edx
  80048c:	c1 ea 0c             	shr    $0xc,%edx
  80048f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800496:	f6 c2 01             	test   $0x1,%dl
  800499:	74 1a                	je     8004b5 <fd_lookup+0x4f>
    if (debug)
      cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  *fd_store = fd;
  80049b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80049e:	89 02                	mov    %eax,(%edx)
  return 0;
  8004a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a5:	eb 13                	jmp    8004ba <fd_lookup+0x54>
  struct Fd *fd;

  if (fdnum < 0 || fdnum >= MAXFD) {
    if (debug)
      cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  8004a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004ac:	eb 0c                	jmp    8004ba <fd_lookup+0x54>
  }
  fd = INDEX2FD(fdnum);
  if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
    if (debug)
      cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  8004ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004b3:	eb 05                	jmp    8004ba <fd_lookup+0x54>
  8004b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  }
  *fd_store = fd;
  return 0;
}
  8004ba:	5d                   	pop    %ebp
  8004bb:	c3                   	ret    

008004bc <dev_lookup>:
  0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004bc:	55                   	push   %ebp
  8004bd:	89 e5                	mov    %esp,%ebp
  8004bf:	83 ec 18             	sub    $0x18,%esp
  8004c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004c5:	ba 80 20 80 00       	mov    $0x802080,%edx
  int i;

  for (i = 0; devtab[i]; i++)
  8004ca:	eb 13                	jmp    8004df <dev_lookup+0x23>
  8004cc:	83 c2 04             	add    $0x4,%edx
    if (devtab[i]->dev_id == dev_id) {
  8004cf:	39 08                	cmp    %ecx,(%eax)
  8004d1:	75 0c                	jne    8004df <dev_lookup+0x23>
      *dev = devtab[i];
  8004d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004d6:	89 01                	mov    %eax,(%ecx)
      return 0;
  8004d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004dd:	eb 30                	jmp    80050f <dev_lookup+0x53>
int
dev_lookup(int dev_id, struct Dev **dev)
{
  int i;

  for (i = 0; devtab[i]; i++)
  8004df:	8b 02                	mov    (%edx),%eax
  8004e1:	85 c0                	test   %eax,%eax
  8004e3:	75 e7                	jne    8004cc <dev_lookup+0x10>
    if (devtab[i]->dev_id == dev_id) {
      *dev = devtab[i];
      return 0;
    }
  cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004e5:	a1 04 40 80 00       	mov    0x804004,%eax
  8004ea:	8b 40 48             	mov    0x48(%eax),%eax
  8004ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8004f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f5:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  8004fc:	e8 3e 0d 00 00       	call   80123f <cprintf>
  *dev = 0;
  800501:	8b 45 0c             	mov    0xc(%ebp),%eax
  800504:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  return -E_INVAL;
  80050a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80050f:	c9                   	leave  
  800510:	c3                   	ret    

00800511 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800511:	55                   	push   %ebp
  800512:	89 e5                	mov    %esp,%ebp
  800514:	56                   	push   %esi
  800515:	53                   	push   %ebx
  800516:	83 ec 20             	sub    $0x20,%esp
  800519:	8b 75 08             	mov    0x8(%ebp),%esi
  80051c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct Fd *fd2;
  struct Dev *dev;
  int r;

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80051f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800522:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  800526:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80052c:	c1 e8 0c             	shr    $0xc,%eax
{
  struct Fd *fd2;
  struct Dev *dev;
  int r;

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80052f:	89 04 24             	mov    %eax,(%esp)
  800532:	e8 2f ff ff ff       	call   800466 <fd_lookup>
  800537:	85 c0                	test   %eax,%eax
  800539:	78 05                	js     800540 <fd_close+0x2f>
      || fd != fd2)
  80053b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80053e:	74 0c                	je     80054c <fd_close+0x3b>
    return must_exist ? r : 0;
  800540:	84 db                	test   %bl,%bl
  800542:	ba 00 00 00 00       	mov    $0x0,%edx
  800547:	0f 44 c2             	cmove  %edx,%eax
  80054a:	eb 3f                	jmp    80058b <fd_close+0x7a>
  if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80054c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80054f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800553:	8b 06                	mov    (%esi),%eax
  800555:	89 04 24             	mov    %eax,(%esp)
  800558:	e8 5f ff ff ff       	call   8004bc <dev_lookup>
  80055d:	89 c3                	mov    %eax,%ebx
  80055f:	85 c0                	test   %eax,%eax
  800561:	78 16                	js     800579 <fd_close+0x68>
    if (dev->dev_close)
  800563:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800566:	8b 40 10             	mov    0x10(%eax),%eax
      r = (*dev->dev_close)(fd);
    else
      r = 0;
  800569:	bb 00 00 00 00       	mov    $0x0,%ebx

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
      || fd != fd2)
    return must_exist ? r : 0;
  if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
    if (dev->dev_close)
  80056e:	85 c0                	test   %eax,%eax
  800570:	74 07                	je     800579 <fd_close+0x68>
      r = (*dev->dev_close)(fd);
  800572:	89 34 24             	mov    %esi,(%esp)
  800575:	ff d0                	call   *%eax
  800577:	89 c3                	mov    %eax,%ebx
    else
      r = 0;
  }
  // Make sure fd is unmapped.  Might be a no-op if
  // (*dev->dev_close)(fd) already unmapped it.
  (void)sys_page_unmap(0, fd);
  800579:	89 74 24 04          	mov    %esi,0x4(%esp)
  80057d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800584:	e8 9c fc ff ff       	call   800225 <sys_page_unmap>
  return r;
  800589:	89 d8                	mov    %ebx,%eax
}
  80058b:	83 c4 20             	add    $0x20,%esp
  80058e:	5b                   	pop    %ebx
  80058f:	5e                   	pop    %esi
  800590:	5d                   	pop    %ebp
  800591:	c3                   	ret    

00800592 <close>:
  return -E_INVAL;
}

int
close(int fdnum)
{
  800592:	55                   	push   %ebp
  800593:	89 e5                	mov    %esp,%ebp
  800595:	83 ec 28             	sub    $0x28,%esp
  struct Fd *fd;
  int r;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  800598:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80059b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059f:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a2:	89 04 24             	mov    %eax,(%esp)
  8005a5:	e8 bc fe ff ff       	call   800466 <fd_lookup>
  8005aa:	89 c2                	mov    %eax,%edx
  8005ac:	85 d2                	test   %edx,%edx
  8005ae:	78 13                	js     8005c3 <close+0x31>
    return r;
  else
    return fd_close(fd, 1);
  8005b0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8005b7:	00 
  8005b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005bb:	89 04 24             	mov    %eax,(%esp)
  8005be:	e8 4e ff ff ff       	call   800511 <fd_close>
}
  8005c3:	c9                   	leave  
  8005c4:	c3                   	ret    

008005c5 <close_all>:

void
close_all(void)
{
  8005c5:	55                   	push   %ebp
  8005c6:	89 e5                	mov    %esp,%ebp
  8005c8:	53                   	push   %ebx
  8005c9:	83 ec 14             	sub    $0x14,%esp
  int i;

  for (i = 0; i < MAXFD; i++)
  8005cc:	bb 00 00 00 00       	mov    $0x0,%ebx
    close(i);
  8005d1:	89 1c 24             	mov    %ebx,(%esp)
  8005d4:	e8 b9 ff ff ff       	call   800592 <close>
void
close_all(void)
{
  int i;

  for (i = 0; i < MAXFD; i++)
  8005d9:	83 c3 01             	add    $0x1,%ebx
  8005dc:	83 fb 20             	cmp    $0x20,%ebx
  8005df:	75 f0                	jne    8005d1 <close_all+0xc>
    close(i);
}
  8005e1:	83 c4 14             	add    $0x14,%esp
  8005e4:	5b                   	pop    %ebx
  8005e5:	5d                   	pop    %ebp
  8005e6:	c3                   	ret    

008005e7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005e7:	55                   	push   %ebp
  8005e8:	89 e5                	mov    %esp,%ebp
  8005ea:	57                   	push   %edi
  8005eb:	56                   	push   %esi
  8005ec:	53                   	push   %ebx
  8005ed:	83 ec 3c             	sub    $0x3c,%esp
  int r;
  char *ova, *nva;
  pte_t pte;
  struct Fd *oldfd, *newfd;

  if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005fa:	89 04 24             	mov    %eax,(%esp)
  8005fd:	e8 64 fe ff ff       	call   800466 <fd_lookup>
  800602:	89 c2                	mov    %eax,%edx
  800604:	85 d2                	test   %edx,%edx
  800606:	0f 88 e1 00 00 00    	js     8006ed <dup+0x106>
    return r;
  close(newfdnum);
  80060c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80060f:	89 04 24             	mov    %eax,(%esp)
  800612:	e8 7b ff ff ff       	call   800592 <close>

  newfd = INDEX2FD(newfdnum);
  800617:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061a:	c1 e3 0c             	shl    $0xc,%ebx
  80061d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
  ova = fd2data(oldfd);
  800623:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800626:	89 04 24             	mov    %eax,(%esp)
  800629:	e8 d2 fd ff ff       	call   800400 <fd2data>
  80062e:	89 c6                	mov    %eax,%esi
  nva = fd2data(newfd);
  800630:	89 1c 24             	mov    %ebx,(%esp)
  800633:	e8 c8 fd ff ff       	call   800400 <fd2data>
  800638:	89 c7                	mov    %eax,%edi

  if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80063a:	89 f0                	mov    %esi,%eax
  80063c:	c1 e8 16             	shr    $0x16,%eax
  80063f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800646:	a8 01                	test   $0x1,%al
  800648:	74 43                	je     80068d <dup+0xa6>
  80064a:	89 f0                	mov    %esi,%eax
  80064c:	c1 e8 0c             	shr    $0xc,%eax
  80064f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800656:	f6 c2 01             	test   $0x1,%dl
  800659:	74 32                	je     80068d <dup+0xa6>
    if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80065b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800662:	25 07 0e 00 00       	and    $0xe07,%eax
  800667:	89 44 24 10          	mov    %eax,0x10(%esp)
  80066b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80066f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800676:	00 
  800677:	89 74 24 04          	mov    %esi,0x4(%esp)
  80067b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800682:	e8 4b fb ff ff       	call   8001d2 <sys_page_map>
  800687:	89 c6                	mov    %eax,%esi
  800689:	85 c0                	test   %eax,%eax
  80068b:	78 3e                	js     8006cb <dup+0xe4>
      goto err;
  if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80068d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800690:	89 c2                	mov    %eax,%edx
  800692:	c1 ea 0c             	shr    $0xc,%edx
  800695:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80069c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8006a2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006a6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006aa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006b1:	00 
  8006b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006bd:	e8 10 fb ff ff       	call   8001d2 <sys_page_map>
  8006c2:	89 c6                	mov    %eax,%esi
    goto err;

  return newfdnum;
  8006c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  nva = fd2data(newfd);

  if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
    if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
      goto err;
  if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006c7:	85 f6                	test   %esi,%esi
  8006c9:	79 22                	jns    8006ed <dup+0x106>
    goto err;

  return newfdnum;

err:
  sys_page_unmap(0, newfd);
  8006cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006d6:	e8 4a fb ff ff       	call   800225 <sys_page_unmap>
  sys_page_unmap(0, nva);
  8006db:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006e6:	e8 3a fb ff ff       	call   800225 <sys_page_unmap>
  return r;
  8006eb:	89 f0                	mov    %esi,%eax
}
  8006ed:	83 c4 3c             	add    $0x3c,%esp
  8006f0:	5b                   	pop    %ebx
  8006f1:	5e                   	pop    %esi
  8006f2:	5f                   	pop    %edi
  8006f3:	5d                   	pop    %ebp
  8006f4:	c3                   	ret    

008006f5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	53                   	push   %ebx
  8006f9:	83 ec 24             	sub    $0x24,%esp
  8006fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  8006ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800702:	89 44 24 04          	mov    %eax,0x4(%esp)
  800706:	89 1c 24             	mov    %ebx,(%esp)
  800709:	e8 58 fd ff ff       	call   800466 <fd_lookup>
  80070e:	89 c2                	mov    %eax,%edx
  800710:	85 d2                	test   %edx,%edx
  800712:	78 6d                	js     800781 <read+0x8c>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800714:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800717:	89 44 24 04          	mov    %eax,0x4(%esp)
  80071b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80071e:	8b 00                	mov    (%eax),%eax
  800720:	89 04 24             	mov    %eax,(%esp)
  800723:	e8 94 fd ff ff       	call   8004bc <dev_lookup>
  800728:	85 c0                	test   %eax,%eax
  80072a:	78 55                	js     800781 <read+0x8c>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80072c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80072f:	8b 50 08             	mov    0x8(%eax),%edx
  800732:	83 e2 03             	and    $0x3,%edx
  800735:	83 fa 01             	cmp    $0x1,%edx
  800738:	75 23                	jne    80075d <read+0x68>
    cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80073a:	a1 04 40 80 00       	mov    0x804004,%eax
  80073f:	8b 40 48             	mov    0x48(%eax),%eax
  800742:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800746:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074a:	c7 04 24 45 20 80 00 	movl   $0x802045,(%esp)
  800751:	e8 e9 0a 00 00       	call   80123f <cprintf>
    return -E_INVAL;
  800756:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80075b:	eb 24                	jmp    800781 <read+0x8c>
  }
  if (!dev->dev_read)
  80075d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800760:	8b 52 08             	mov    0x8(%edx),%edx
  800763:	85 d2                	test   %edx,%edx
  800765:	74 15                	je     80077c <read+0x87>
    return -E_NOT_SUPP;
  return (*dev->dev_read)(fd, buf, n);
  800767:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80076a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80076e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800771:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800775:	89 04 24             	mov    %eax,(%esp)
  800778:	ff d2                	call   *%edx
  80077a:	eb 05                	jmp    800781 <read+0x8c>
  if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
    cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  if (!dev->dev_read)
    return -E_NOT_SUPP;
  80077c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_read)(fd, buf, n);
}
  800781:	83 c4 24             	add    $0x24,%esp
  800784:	5b                   	pop    %ebx
  800785:	5d                   	pop    %ebp
  800786:	c3                   	ret    

00800787 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	57                   	push   %edi
  80078b:	56                   	push   %esi
  80078c:	53                   	push   %ebx
  80078d:	83 ec 1c             	sub    $0x1c,%esp
  800790:	8b 7d 08             	mov    0x8(%ebp),%edi
  800793:	8b 75 10             	mov    0x10(%ebp),%esi
  int m, tot;

  for (tot = 0; tot < n; tot += m) {
  800796:	bb 00 00 00 00       	mov    $0x0,%ebx
  80079b:	eb 23                	jmp    8007c0 <readn+0x39>
    m = read(fdnum, (char*)buf + tot, n - tot);
  80079d:	89 f0                	mov    %esi,%eax
  80079f:	29 d8                	sub    %ebx,%eax
  8007a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a5:	89 d8                	mov    %ebx,%eax
  8007a7:	03 45 0c             	add    0xc(%ebp),%eax
  8007aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ae:	89 3c 24             	mov    %edi,(%esp)
  8007b1:	e8 3f ff ff ff       	call   8006f5 <read>
    if (m < 0)
  8007b6:	85 c0                	test   %eax,%eax
  8007b8:	78 10                	js     8007ca <readn+0x43>
      return m;
    if (m == 0)
  8007ba:	85 c0                	test   %eax,%eax
  8007bc:	74 0a                	je     8007c8 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
  int m, tot;

  for (tot = 0; tot < n; tot += m) {
  8007be:	01 c3                	add    %eax,%ebx
  8007c0:	39 f3                	cmp    %esi,%ebx
  8007c2:	72 d9                	jb     80079d <readn+0x16>
  8007c4:	89 d8                	mov    %ebx,%eax
  8007c6:	eb 02                	jmp    8007ca <readn+0x43>
  8007c8:	89 d8                	mov    %ebx,%eax
      return m;
    if (m == 0)
      break;
  }
  return tot;
}
  8007ca:	83 c4 1c             	add    $0x1c,%esp
  8007cd:	5b                   	pop    %ebx
  8007ce:	5e                   	pop    %esi
  8007cf:	5f                   	pop    %edi
  8007d0:	5d                   	pop    %ebp
  8007d1:	c3                   	ret    

008007d2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	53                   	push   %ebx
  8007d6:	83 ec 24             	sub    $0x24,%esp
  8007d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  8007dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e3:	89 1c 24             	mov    %ebx,(%esp)
  8007e6:	e8 7b fc ff ff       	call   800466 <fd_lookup>
  8007eb:	89 c2                	mov    %eax,%edx
  8007ed:	85 d2                	test   %edx,%edx
  8007ef:	78 68                	js     800859 <write+0x87>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fb:	8b 00                	mov    (%eax),%eax
  8007fd:	89 04 24             	mov    %eax,(%esp)
  800800:	e8 b7 fc ff ff       	call   8004bc <dev_lookup>
  800805:	85 c0                	test   %eax,%eax
  800807:	78 50                	js     800859 <write+0x87>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800809:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80080c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800810:	75 23                	jne    800835 <write+0x63>
    cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800812:	a1 04 40 80 00       	mov    0x804004,%eax
  800817:	8b 40 48             	mov    0x48(%eax),%eax
  80081a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80081e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800822:	c7 04 24 61 20 80 00 	movl   $0x802061,(%esp)
  800829:	e8 11 0a 00 00       	call   80123f <cprintf>
    return -E_INVAL;
  80082e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800833:	eb 24                	jmp    800859 <write+0x87>
  }
  if (debug)
    cprintf("write %d %p %d via dev %s\n",
            fdnum, buf, n, dev->dev_name);
  if (!dev->dev_write)
  800835:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800838:	8b 52 0c             	mov    0xc(%edx),%edx
  80083b:	85 d2                	test   %edx,%edx
  80083d:	74 15                	je     800854 <write+0x82>
    return -E_NOT_SUPP;
  return (*dev->dev_write)(fd, buf, n);
  80083f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800842:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800846:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800849:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80084d:	89 04 24             	mov    %eax,(%esp)
  800850:	ff d2                	call   *%edx
  800852:	eb 05                	jmp    800859 <write+0x87>
  }
  if (debug)
    cprintf("write %d %p %d via dev %s\n",
            fdnum, buf, n, dev->dev_name);
  if (!dev->dev_write)
    return -E_NOT_SUPP;
  800854:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_write)(fd, buf, n);
}
  800859:	83 c4 24             	add    $0x24,%esp
  80085c:	5b                   	pop    %ebx
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <seek>:

int
seek(int fdnum, off_t offset)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	83 ec 18             	sub    $0x18,%esp
  int r;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  800865:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800868:	89 44 24 04          	mov    %eax,0x4(%esp)
  80086c:	8b 45 08             	mov    0x8(%ebp),%eax
  80086f:	89 04 24             	mov    %eax,(%esp)
  800872:	e8 ef fb ff ff       	call   800466 <fd_lookup>
  800877:	85 c0                	test   %eax,%eax
  800879:	78 0e                	js     800889 <seek+0x2a>
    return r;
  fd->fd_offset = offset;
  80087b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80087e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800881:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
  800884:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800889:	c9                   	leave  
  80088a:	c3                   	ret    

0080088b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	53                   	push   %ebx
  80088f:	83 ec 24             	sub    $0x24,%esp
  800892:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  800895:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800898:	89 44 24 04          	mov    %eax,0x4(%esp)
  80089c:	89 1c 24             	mov    %ebx,(%esp)
  80089f:	e8 c2 fb ff ff       	call   800466 <fd_lookup>
  8008a4:	89 c2                	mov    %eax,%edx
  8008a6:	85 d2                	test   %edx,%edx
  8008a8:	78 61                	js     80090b <ftruncate+0x80>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008b4:	8b 00                	mov    (%eax),%eax
  8008b6:	89 04 24             	mov    %eax,(%esp)
  8008b9:	e8 fe fb ff ff       	call   8004bc <dev_lookup>
  8008be:	85 c0                	test   %eax,%eax
  8008c0:	78 49                	js     80090b <ftruncate+0x80>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008c5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008c9:	75 23                	jne    8008ee <ftruncate+0x63>
    cprintf("[%08x] ftruncate %d -- bad mode\n",
            thisenv->env_id, fdnum);
  8008cb:	a1 04 40 80 00       	mov    0x804004,%eax

  if ((r = fd_lookup(fdnum, &fd)) < 0
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
    cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008d0:	8b 40 48             	mov    0x48(%eax),%eax
  8008d3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008db:	c7 04 24 24 20 80 00 	movl   $0x802024,(%esp)
  8008e2:	e8 58 09 00 00       	call   80123f <cprintf>
            thisenv->env_id, fdnum);
    return -E_INVAL;
  8008e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008ec:	eb 1d                	jmp    80090b <ftruncate+0x80>
  }
  if (!dev->dev_trunc)
  8008ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008f1:	8b 52 18             	mov    0x18(%edx),%edx
  8008f4:	85 d2                	test   %edx,%edx
  8008f6:	74 0e                	je     800906 <ftruncate+0x7b>
    return -E_NOT_SUPP;
  return (*dev->dev_trunc)(fd, newsize);
  8008f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008fb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008ff:	89 04 24             	mov    %eax,(%esp)
  800902:	ff d2                	call   *%edx
  800904:	eb 05                	jmp    80090b <ftruncate+0x80>
    cprintf("[%08x] ftruncate %d -- bad mode\n",
            thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  if (!dev->dev_trunc)
    return -E_NOT_SUPP;
  800906:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_trunc)(fd, newsize);
}
  80090b:	83 c4 24             	add    $0x24,%esp
  80090e:	5b                   	pop    %ebx
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	53                   	push   %ebx
  800915:	83 ec 24             	sub    $0x24,%esp
  800918:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  80091b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80091e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800922:	8b 45 08             	mov    0x8(%ebp),%eax
  800925:	89 04 24             	mov    %eax,(%esp)
  800928:	e8 39 fb ff ff       	call   800466 <fd_lookup>
  80092d:	89 c2                	mov    %eax,%edx
  80092f:	85 d2                	test   %edx,%edx
  800931:	78 52                	js     800985 <fstat+0x74>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800933:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800936:	89 44 24 04          	mov    %eax,0x4(%esp)
  80093a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80093d:	8b 00                	mov    (%eax),%eax
  80093f:	89 04 24             	mov    %eax,(%esp)
  800942:	e8 75 fb ff ff       	call   8004bc <dev_lookup>
  800947:	85 c0                	test   %eax,%eax
  800949:	78 3a                	js     800985 <fstat+0x74>
    return r;
  if (!dev->dev_stat)
  80094b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800952:	74 2c                	je     800980 <fstat+0x6f>
    return -E_NOT_SUPP;
  stat->st_name[0] = 0;
  800954:	c6 03 00             	movb   $0x0,(%ebx)
  stat->st_size = 0;
  800957:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80095e:	00 00 00 
  stat->st_isdir = 0;
  800961:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800968:	00 00 00 
  stat->st_dev = dev;
  80096b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
  return (*dev->dev_stat)(fd, stat);
  800971:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800975:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800978:	89 14 24             	mov    %edx,(%esp)
  80097b:	ff 50 14             	call   *0x14(%eax)
  80097e:	eb 05                	jmp    800985 <fstat+0x74>

  if ((r = fd_lookup(fdnum, &fd)) < 0
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
    return r;
  if (!dev->dev_stat)
    return -E_NOT_SUPP;
  800980:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  stat->st_name[0] = 0;
  stat->st_size = 0;
  stat->st_isdir = 0;
  stat->st_dev = dev;
  return (*dev->dev_stat)(fd, stat);
}
  800985:	83 c4 24             	add    $0x24,%esp
  800988:	5b                   	pop    %ebx
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	56                   	push   %esi
  80098f:	53                   	push   %ebx
  800990:	83 ec 10             	sub    $0x10,%esp
  int fd, r;

  if ((fd = open(path, O_RDONLY)) < 0)
  800993:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80099a:	00 
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	89 04 24             	mov    %eax,(%esp)
  8009a1:	e8 d2 01 00 00       	call   800b78 <open>
  8009a6:	89 c3                	mov    %eax,%ebx
  8009a8:	85 db                	test   %ebx,%ebx
  8009aa:	78 1b                	js     8009c7 <stat+0x3c>
    return fd;
  r = fstat(fd, stat);
  8009ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b3:	89 1c 24             	mov    %ebx,(%esp)
  8009b6:	e8 56 ff ff ff       	call   800911 <fstat>
  8009bb:	89 c6                	mov    %eax,%esi
  close(fd);
  8009bd:	89 1c 24             	mov    %ebx,(%esp)
  8009c0:	e8 cd fb ff ff       	call   800592 <close>
  return r;
  8009c5:	89 f0                	mov    %esi,%eax
}
  8009c7:	83 c4 10             	add    $0x10,%esp
  8009ca:	5b                   	pop    %ebx
  8009cb:	5e                   	pop    %esi
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	56                   	push   %esi
  8009d2:	53                   	push   %ebx
  8009d3:	83 ec 10             	sub    $0x10,%esp
  8009d6:	89 c6                	mov    %eax,%esi
  8009d8:	89 d3                	mov    %edx,%ebx
  static envid_t fsenv;

  if (fsenv == 0)
  8009da:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009e1:	75 11                	jne    8009f4 <fsipc+0x26>
    fsenv = ipc_find_env(ENV_TYPE_FS);
  8009e3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8009ea:	e8 b8 12 00 00       	call   801ca7 <ipc_find_env>
  8009ef:	a3 00 40 80 00       	mov    %eax,0x804000
  static_assert(sizeof(fsipcbuf) == PGSIZE);

  if (debug)
    cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t*)&fsipcbuf);

  ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009f4:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8009fb:	00 
  8009fc:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a03:	00 
  800a04:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a08:	a1 00 40 80 00       	mov    0x804000,%eax
  800a0d:	89 04 24             	mov    %eax,(%esp)
  800a10:	e8 27 12 00 00       	call   801c3c <ipc_send>
  return ipc_recv(NULL, dstva, NULL);
  800a15:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a1c:	00 
  800a1d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a28:	e8 89 11 00 00       	call   801bb6 <ipc_recv>
}
  800a2d:	83 c4 10             	add    $0x10,%esp
  800a30:	5b                   	pop    %ebx
  800a31:	5e                   	pop    %esi
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	83 ec 08             	sub    $0x8,%esp
  fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a40:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.set_size.req_size = newsize;
  800a45:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a48:	a3 04 50 80 00       	mov    %eax,0x805004
  return fsipc(FSREQ_SET_SIZE, NULL);
  800a4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a52:	b8 02 00 00 00       	mov    $0x2,%eax
  800a57:	e8 72 ff ff ff       	call   8009ce <fsipc>
}
  800a5c:	c9                   	leave  
  800a5d:	c3                   	ret    

00800a5e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	83 ec 08             	sub    $0x8,%esp
  fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a64:	8b 45 08             	mov    0x8(%ebp),%eax
  800a67:	8b 40 0c             	mov    0xc(%eax),%eax
  800a6a:	a3 00 50 80 00       	mov    %eax,0x805000
  return fsipc(FSREQ_FLUSH, NULL);
  800a6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a74:	b8 06 00 00 00       	mov    $0x6,%eax
  800a79:	e8 50 ff ff ff       	call   8009ce <fsipc>
}
  800a7e:	c9                   	leave  
  800a7f:	c3                   	ret    

00800a80 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	53                   	push   %ebx
  800a84:	83 ec 14             	sub    $0x14,%esp
  800a87:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int r;

  fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a90:	a3 00 50 80 00       	mov    %eax,0x805000
  if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a95:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9a:	b8 05 00 00 00       	mov    $0x5,%eax
  800a9f:	e8 2a ff ff ff       	call   8009ce <fsipc>
  800aa4:	89 c2                	mov    %eax,%edx
  800aa6:	85 d2                	test   %edx,%edx
  800aa8:	78 2b                	js     800ad5 <devfile_stat+0x55>
    return r;
  strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800aaa:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800ab1:	00 
  800ab2:	89 1c 24             	mov    %ebx,(%esp)
  800ab5:	e8 ad 0d 00 00       	call   801867 <strcpy>
  st->st_size = fsipcbuf.statRet.ret_size;
  800aba:	a1 80 50 80 00       	mov    0x805080,%eax
  800abf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800ac5:	a1 84 50 80 00       	mov    0x805084,%eax
  800aca:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  return 0;
  800ad0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad5:	83 c4 14             	add    $0x14,%esp
  800ad8:	5b                   	pop    %ebx
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	83 ec 18             	sub    $0x18,%esp
  800ae1:	8b 45 10             	mov    0x10(%ebp),%eax
  // remember that write is always allowed to write *fewer*
  // bytes than requested.
  // LAB 5: Your code here
    int r;

    fsipcbuf.write.req_fileid = fd->fd_file.id;
  800ae4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae7:	8b 52 0c             	mov    0xc(%edx),%edx
  800aea:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  800af0:	a3 04 50 80 00       	mov    %eax,0x805004

    size_t max_written = sizeof(fsipcbuf.write.req_buf);
    memmove(fsipcbuf.write.req_buf, buf, MIN(max_written, n));
  800af5:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800afa:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800aff:	0f 47 c2             	cmova  %edx,%eax
  800b02:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b06:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b09:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b0d:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800b14:	e8 eb 0e 00 00       	call   801a04 <memmove>

    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800b19:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1e:	b8 04 00 00 00       	mov    $0x4,%eax
  800b23:	e8 a6 fe ff ff       	call   8009ce <fsipc>
        return r;

    return r;
}
  800b28:	c9                   	leave  
  800b29:	c3                   	ret    

00800b2a <devfile_read>:
// Returns:
//  The number of bytes successfully read.
//  < 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	53                   	push   %ebx
  800b2e:	83 ec 14             	sub    $0x14,%esp
  // filling fsipcbuf.read with the request arguments.  The
  // bytes read will be written back to fsipcbuf by the file
  // system server.
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b31:	8b 45 08             	mov    0x8(%ebp),%eax
  800b34:	8b 40 0c             	mov    0xc(%eax),%eax
  800b37:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  800b3c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b3f:	a3 04 50 80 00       	mov    %eax,0x805004
  if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b44:	ba 00 00 00 00       	mov    $0x0,%edx
  800b49:	b8 03 00 00 00       	mov    $0x3,%eax
  800b4e:	e8 7b fe ff ff       	call   8009ce <fsipc>
  800b53:	89 c3                	mov    %eax,%ebx
  800b55:	85 c0                	test   %eax,%eax
  800b57:	78 17                	js     800b70 <devfile_read+0x46>
    return r;

  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b59:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b5d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800b64:	00 
  800b65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b68:	89 04 24             	mov    %eax,(%esp)
  800b6b:	e8 94 0e 00 00       	call   801a04 <memmove>
  return r;
}
  800b70:	89 d8                	mov    %ebx,%eax
  800b72:	83 c4 14             	add    $0x14,%esp
  800b75:	5b                   	pop    %ebx
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    

00800b78 <open>:
//  The file descriptor index on success
//  -E_BAD_PATH if the path is too long (>= MAXPATHLEN)
//  < 0 for other errors.
int
open(const char *path, int mode)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	53                   	push   %ebx
  800b7c:	83 ec 24             	sub    $0x24,%esp
  800b7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  // file descriptor.

  int r;
  struct Fd *fd;

  if (strlen(path) >= MAXPATHLEN)
  800b82:	89 1c 24             	mov    %ebx,(%esp)
  800b85:	e8 a6 0c 00 00       	call   801830 <strlen>
  800b8a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b8f:	7f 60                	jg     800bf1 <open+0x79>
    return -E_BAD_PATH;

  if ((r = fd_alloc(&fd)) < 0)
  800b91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b94:	89 04 24             	mov    %eax,(%esp)
  800b97:	e8 7b f8 ff ff       	call   800417 <fd_alloc>
  800b9c:	89 c2                	mov    %eax,%edx
  800b9e:	85 d2                	test   %edx,%edx
  800ba0:	78 54                	js     800bf6 <open+0x7e>
    return r;

  strcpy(fsipcbuf.open.req_path, path);
  800ba2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ba6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800bad:	e8 b5 0c 00 00       	call   801867 <strcpy>
  fsipcbuf.open.req_omode = mode;
  800bb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb5:	a3 00 54 80 00       	mov    %eax,0x805400

  if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800bba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bbd:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc2:	e8 07 fe ff ff       	call   8009ce <fsipc>
  800bc7:	89 c3                	mov    %eax,%ebx
  800bc9:	85 c0                	test   %eax,%eax
  800bcb:	79 17                	jns    800be4 <open+0x6c>
    fd_close(fd, 0);
  800bcd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800bd4:	00 
  800bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bd8:	89 04 24             	mov    %eax,(%esp)
  800bdb:	e8 31 f9 ff ff       	call   800511 <fd_close>
    return r;
  800be0:	89 d8                	mov    %ebx,%eax
  800be2:	eb 12                	jmp    800bf6 <open+0x7e>
  }

  return fd2num(fd);
  800be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800be7:	89 04 24             	mov    %eax,(%esp)
  800bea:	e8 01 f8 ff ff       	call   8003f0 <fd2num>
  800bef:	eb 05                	jmp    800bf6 <open+0x7e>

  int r;
  struct Fd *fd;

  if (strlen(path) >= MAXPATHLEN)
    return -E_BAD_PATH;
  800bf1:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
    fd_close(fd, 0);
    return r;
  }

  return fd2num(fd);
}
  800bf6:	83 c4 24             	add    $0x24,%esp
  800bf9:	5b                   	pop    %ebx
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	83 ec 08             	sub    $0x8,%esp
  // Ask the file server to update the disk
  // by writing any dirty blocks in the buffer cache.

  return fsipc(FSREQ_SYNC, NULL);
  800c02:	ba 00 00 00 00       	mov    $0x0,%edx
  800c07:	b8 08 00 00 00       	mov    $0x8,%eax
  800c0c:	e8 bd fd ff ff       	call   8009ce <fsipc>
}
  800c11:	c9                   	leave  
  800c12:	c3                   	ret    

00800c13 <devpipe_stat>:
  return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
  800c18:	83 ec 10             	sub    $0x10,%esp
  800c1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct Pipe *p = (struct Pipe*)fd2data(fd);
  800c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c21:	89 04 24             	mov    %eax,(%esp)
  800c24:	e8 d7 f7 ff ff       	call   800400 <fd2data>
  800c29:	89 c6                	mov    %eax,%esi

  strcpy(stat->st_name, "<pipe>");
  800c2b:	c7 44 24 04 90 20 80 	movl   $0x802090,0x4(%esp)
  800c32:	00 
  800c33:	89 1c 24             	mov    %ebx,(%esp)
  800c36:	e8 2c 0c 00 00       	call   801867 <strcpy>
  stat->st_size = p->p_wpos - p->p_rpos;
  800c3b:	8b 46 04             	mov    0x4(%esi),%eax
  800c3e:	2b 06                	sub    (%esi),%eax
  800c40:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  stat->st_isdir = 0;
  800c46:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c4d:	00 00 00 
  stat->st_dev = &devpipe;
  800c50:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  800c57:	30 80 00 
  return 0;
}
  800c5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c5f:	83 c4 10             	add    $0x10,%esp
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    

00800c66 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	53                   	push   %ebx
  800c6a:	83 ec 14             	sub    $0x14,%esp
  800c6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  (void)sys_page_unmap(0, fd);
  800c70:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c7b:	e8 a5 f5 ff ff       	call   800225 <sys_page_unmap>
  return sys_page_unmap(0, fd2data(fd));
  800c80:	89 1c 24             	mov    %ebx,(%esp)
  800c83:	e8 78 f7 ff ff       	call   800400 <fd2data>
  800c88:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c8c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c93:	e8 8d f5 ff ff       	call   800225 <sys_page_unmap>
}
  800c98:	83 c4 14             	add    $0x14,%esp
  800c9b:	5b                   	pop    %ebx
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    

00800c9e <_pipeisclosed>:
  return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
  800ca4:	83 ec 2c             	sub    $0x2c,%esp
  800ca7:	89 c6                	mov    %eax,%esi
  800ca9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  int n, nn, ret;

  while (1) {
    n = thisenv->env_runs;
  800cac:	a1 04 40 80 00       	mov    0x804004,%eax
  800cb1:	8b 58 58             	mov    0x58(%eax),%ebx
    ret = pageref(fd) == pageref(p);
  800cb4:	89 34 24             	mov    %esi,(%esp)
  800cb7:	e8 23 10 00 00       	call   801cdf <pageref>
  800cbc:	89 c7                	mov    %eax,%edi
  800cbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cc1:	89 04 24             	mov    %eax,(%esp)
  800cc4:	e8 16 10 00 00       	call   801cdf <pageref>
  800cc9:	39 c7                	cmp    %eax,%edi
  800ccb:	0f 94 c2             	sete   %dl
  800cce:	0f b6 c2             	movzbl %dl,%eax
    nn = thisenv->env_runs;
  800cd1:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  800cd7:	8b 79 58             	mov    0x58(%ecx),%edi
    if (n == nn)
  800cda:	39 fb                	cmp    %edi,%ebx
  800cdc:	74 21                	je     800cff <_pipeisclosed+0x61>
      return ret;
    if (n != nn && ret == 1)
  800cde:	84 d2                	test   %dl,%dl
  800ce0:	74 ca                	je     800cac <_pipeisclosed+0xe>
      cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800ce2:	8b 51 58             	mov    0x58(%ecx),%edx
  800ce5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ce9:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ced:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cf1:	c7 04 24 97 20 80 00 	movl   $0x802097,(%esp)
  800cf8:	e8 42 05 00 00       	call   80123f <cprintf>
  800cfd:	eb ad                	jmp    800cac <_pipeisclosed+0xe>
  }
}
  800cff:	83 c4 2c             	add    $0x2c,%esp
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <devpipe_write>:
  return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
  800d0d:	83 ec 1c             	sub    $0x1c,%esp
  800d10:	8b 75 08             	mov    0x8(%ebp),%esi
  const uint8_t *buf;
  size_t i;
  struct Pipe *p;

  p = (struct Pipe*)fd2data(fd);
  800d13:	89 34 24             	mov    %esi,(%esp)
  800d16:	e8 e5 f6 ff ff       	call   800400 <fd2data>
  800d1b:	89 c3                	mov    %eax,%ebx
  if (debug)
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  800d1d:	bf 00 00 00 00       	mov    $0x0,%edi
  800d22:	eb 45                	jmp    800d69 <devpipe_write+0x62>
    while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
      // pipe is full
      // if all the readers are gone
      // (it's only writers like us now),
      // note eof
      if (_pipeisclosed(fd, p))
  800d24:	89 da                	mov    %ebx,%edx
  800d26:	89 f0                	mov    %esi,%eax
  800d28:	e8 71 ff ff ff       	call   800c9e <_pipeisclosed>
  800d2d:	85 c0                	test   %eax,%eax
  800d2f:	75 41                	jne    800d72 <devpipe_write+0x6b>
        return 0;
      // yield and see what happens
      if (debug)
        cprintf("devpipe_write yield\n");
      sys_yield();
  800d31:	e8 29 f4 ff ff       	call   80015f <sys_yield>
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
    while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800d36:	8b 43 04             	mov    0x4(%ebx),%eax
  800d39:	8b 0b                	mov    (%ebx),%ecx
  800d3b:	8d 51 20             	lea    0x20(%ecx),%edx
  800d3e:	39 d0                	cmp    %edx,%eax
  800d40:	73 e2                	jae    800d24 <devpipe_write+0x1d>
        cprintf("devpipe_write yield\n");
      sys_yield();
    }
    // there's room for a byte.  store it.
    // wait to increment wpos until the byte is stored!
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800d42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d45:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800d49:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800d4c:	99                   	cltd   
  800d4d:	c1 ea 1b             	shr    $0x1b,%edx
  800d50:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  800d53:	83 e1 1f             	and    $0x1f,%ecx
  800d56:	29 d1                	sub    %edx,%ecx
  800d58:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  800d5c:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
    p->p_wpos++;
  800d60:	83 c0 01             	add    $0x1,%eax
  800d63:	89 43 04             	mov    %eax,0x4(%ebx)
  if (debug)
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  800d66:	83 c7 01             	add    $0x1,%edi
  800d69:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800d6c:	75 c8                	jne    800d36 <devpipe_write+0x2f>
    // wait to increment wpos until the byte is stored!
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
    p->p_wpos++;
  }

  return i;
  800d6e:	89 f8                	mov    %edi,%eax
  800d70:	eb 05                	jmp    800d77 <devpipe_write+0x70>
      // pipe is full
      // if all the readers are gone
      // (it's only writers like us now),
      // note eof
      if (_pipeisclosed(fd, p))
        return 0;
  800d72:	b8 00 00 00 00       	mov    $0x0,%eax
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
    p->p_wpos++;
  }

  return i;
}
  800d77:	83 c4 1c             	add    $0x1c,%esp
  800d7a:	5b                   	pop    %ebx
  800d7b:	5e                   	pop    %esi
  800d7c:	5f                   	pop    %edi
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    

00800d7f <devpipe_read>:
  return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	57                   	push   %edi
  800d83:	56                   	push   %esi
  800d84:	53                   	push   %ebx
  800d85:	83 ec 1c             	sub    $0x1c,%esp
  800d88:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint8_t *buf;
  size_t i;
  struct Pipe *p;

  p = (struct Pipe*)fd2data(fd);
  800d8b:	89 3c 24             	mov    %edi,(%esp)
  800d8e:	e8 6d f6 ff ff       	call   800400 <fd2data>
  800d93:	89 c3                	mov    %eax,%ebx
  if (debug)
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  800d95:	be 00 00 00 00       	mov    $0x0,%esi
  800d9a:	eb 3d                	jmp    800dd9 <devpipe_read+0x5a>
    while (p->p_rpos == p->p_wpos) {
      // pipe is empty
      // if we got any data, return it
      if (i > 0)
  800d9c:	85 f6                	test   %esi,%esi
  800d9e:	74 04                	je     800da4 <devpipe_read+0x25>
        return i;
  800da0:	89 f0                	mov    %esi,%eax
  800da2:	eb 43                	jmp    800de7 <devpipe_read+0x68>
      // if all the writers are gone, note eof
      if (_pipeisclosed(fd, p))
  800da4:	89 da                	mov    %ebx,%edx
  800da6:	89 f8                	mov    %edi,%eax
  800da8:	e8 f1 fe ff ff       	call   800c9e <_pipeisclosed>
  800dad:	85 c0                	test   %eax,%eax
  800daf:	75 31                	jne    800de2 <devpipe_read+0x63>
        return 0;
      // yield and see what happens
      if (debug)
        cprintf("devpipe_read yield\n");
      sys_yield();
  800db1:	e8 a9 f3 ff ff       	call   80015f <sys_yield>
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
    while (p->p_rpos == p->p_wpos) {
  800db6:	8b 03                	mov    (%ebx),%eax
  800db8:	3b 43 04             	cmp    0x4(%ebx),%eax
  800dbb:	74 df                	je     800d9c <devpipe_read+0x1d>
        cprintf("devpipe_read yield\n");
      sys_yield();
    }
    // there's a byte.  take it.
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800dbd:	99                   	cltd   
  800dbe:	c1 ea 1b             	shr    $0x1b,%edx
  800dc1:	01 d0                	add    %edx,%eax
  800dc3:	83 e0 1f             	and    $0x1f,%eax
  800dc6:	29 d0                	sub    %edx,%eax
  800dc8:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800dcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd0:	88 04 31             	mov    %al,(%ecx,%esi,1)
    p->p_rpos++;
  800dd3:	83 03 01             	addl   $0x1,(%ebx)
  if (debug)
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  800dd6:	83 c6 01             	add    $0x1,%esi
  800dd9:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ddc:	75 d8                	jne    800db6 <devpipe_read+0x37>
    // there's a byte.  take it.
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
    p->p_rpos++;
  }
  return i;
  800dde:	89 f0                	mov    %esi,%eax
  800de0:	eb 05                	jmp    800de7 <devpipe_read+0x68>
      // if we got any data, return it
      if (i > 0)
        return i;
      // if all the writers are gone, note eof
      if (_pipeisclosed(fd, p))
        return 0;
  800de2:	b8 00 00 00 00       	mov    $0x0,%eax
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
    p->p_rpos++;
  }
  return i;
}
  800de7:	83 c4 1c             	add    $0x1c,%esp
  800dea:	5b                   	pop    %ebx
  800deb:	5e                   	pop    %esi
  800dec:	5f                   	pop    %edi
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    

00800def <pipe>:
  uint8_t p_buf[PIPEBUFSIZ];    // data buffer
};

int
pipe(int pfd[2])
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	56                   	push   %esi
  800df3:	53                   	push   %ebx
  800df4:	83 ec 30             	sub    $0x30,%esp
  int r;
  struct Fd *fd0, *fd1;
  void *va;

  // allocate the file descriptor table entries
  if ((r = fd_alloc(&fd0)) < 0
  800df7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800dfa:	89 04 24             	mov    %eax,(%esp)
  800dfd:	e8 15 f6 ff ff       	call   800417 <fd_alloc>
  800e02:	89 c2                	mov    %eax,%edx
  800e04:	85 d2                	test   %edx,%edx
  800e06:	0f 88 4d 01 00 00    	js     800f59 <pipe+0x16a>
      || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e0c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e13:	00 
  800e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e17:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e1b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e22:	e8 57 f3 ff ff       	call   80017e <sys_page_alloc>
  800e27:	89 c2                	mov    %eax,%edx
  800e29:	85 d2                	test   %edx,%edx
  800e2b:	0f 88 28 01 00 00    	js     800f59 <pipe+0x16a>
    goto err;

  if ((r = fd_alloc(&fd1)) < 0
  800e31:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e34:	89 04 24             	mov    %eax,(%esp)
  800e37:	e8 db f5 ff ff       	call   800417 <fd_alloc>
  800e3c:	89 c3                	mov    %eax,%ebx
  800e3e:	85 c0                	test   %eax,%eax
  800e40:	0f 88 fe 00 00 00    	js     800f44 <pipe+0x155>
      || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e46:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e4d:	00 
  800e4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e51:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e5c:	e8 1d f3 ff ff       	call   80017e <sys_page_alloc>
  800e61:	89 c3                	mov    %eax,%ebx
  800e63:	85 c0                	test   %eax,%eax
  800e65:	0f 88 d9 00 00 00    	js     800f44 <pipe+0x155>
    goto err1;

  // allocate the pipe structure as first data page in both
  va = fd2data(fd0);
  800e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e6e:	89 04 24             	mov    %eax,(%esp)
  800e71:	e8 8a f5 ff ff       	call   800400 <fd2data>
  800e76:	89 c6                	mov    %eax,%esi
  if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e78:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e7f:	00 
  800e80:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e84:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e8b:	e8 ee f2 ff ff       	call   80017e <sys_page_alloc>
  800e90:	89 c3                	mov    %eax,%ebx
  800e92:	85 c0                	test   %eax,%eax
  800e94:	0f 88 97 00 00 00    	js     800f31 <pipe+0x142>
    goto err2;
  if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e9d:	89 04 24             	mov    %eax,(%esp)
  800ea0:	e8 5b f5 ff ff       	call   800400 <fd2data>
  800ea5:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  800eac:	00 
  800ead:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800eb1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800eb8:	00 
  800eb9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ebd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ec4:	e8 09 f3 ff ff       	call   8001d2 <sys_page_map>
  800ec9:	89 c3                	mov    %eax,%ebx
  800ecb:	85 c0                	test   %eax,%eax
  800ecd:	78 52                	js     800f21 <pipe+0x132>
    goto err3;

  // set up fd structures
  fd0->fd_dev_id = devpipe.dev_id;
  800ecf:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800ed5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ed8:	89 10                	mov    %edx,(%eax)
  fd0->fd_omode = O_RDONLY;
  800eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800edd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

  fd1->fd_dev_id = devpipe.dev_id;
  800ee4:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800eea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eed:	89 10                	mov    %edx,(%eax)
  fd1->fd_omode = O_WRONLY;
  800eef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ef2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

  if (debug)
    cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

  pfd[0] = fd2num(fd0);
  800ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800efc:	89 04 24             	mov    %eax,(%esp)
  800eff:	e8 ec f4 ff ff       	call   8003f0 <fd2num>
  800f04:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f07:	89 01                	mov    %eax,(%ecx)
  pfd[1] = fd2num(fd1);
  800f09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f0c:	89 04 24             	mov    %eax,(%esp)
  800f0f:	e8 dc f4 ff ff       	call   8003f0 <fd2num>
  800f14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f17:	89 41 04             	mov    %eax,0x4(%ecx)
  return 0;
  800f1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1f:	eb 38                	jmp    800f59 <pipe+0x16a>

err3:
  sys_page_unmap(0, va);
  800f21:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f25:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f2c:	e8 f4 f2 ff ff       	call   800225 <sys_page_unmap>
err2:
  sys_page_unmap(0, fd1);
  800f31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f34:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f38:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f3f:	e8 e1 f2 ff ff       	call   800225 <sys_page_unmap>
err1:
  sys_page_unmap(0, fd0);
  800f44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f47:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f52:	e8 ce f2 ff ff       	call   800225 <sys_page_unmap>
  800f57:	89 d8                	mov    %ebx,%eax
err:
  return r;
}
  800f59:	83 c4 30             	add    $0x30,%esp
  800f5c:	5b                   	pop    %ebx
  800f5d:	5e                   	pop    %esi
  800f5e:	5d                   	pop    %ebp
  800f5f:	c3                   	ret    

00800f60 <pipeisclosed>:
  }
}

int
pipeisclosed(int fdnum)
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	83 ec 28             	sub    $0x28,%esp
  struct Fd *fd;
  struct Pipe *p;
  int r;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f66:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f69:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f70:	89 04 24             	mov    %eax,(%esp)
  800f73:	e8 ee f4 ff ff       	call   800466 <fd_lookup>
  800f78:	89 c2                	mov    %eax,%edx
  800f7a:	85 d2                	test   %edx,%edx
  800f7c:	78 15                	js     800f93 <pipeisclosed+0x33>
    return r;
  p = (struct Pipe*)fd2data(fd);
  800f7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f81:	89 04 24             	mov    %eax,(%esp)
  800f84:	e8 77 f4 ff ff       	call   800400 <fd2data>
  return _pipeisclosed(fd, p);
  800f89:	89 c2                	mov    %eax,%edx
  800f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f8e:	e8 0b fd ff ff       	call   800c9e <_pipeisclosed>
}
  800f93:	c9                   	leave  
  800f94:	c3                   	ret    
  800f95:	66 90                	xchg   %ax,%ax
  800f97:	66 90                	xchg   %ax,%ax
  800f99:	66 90                	xchg   %ax,%ax
  800f9b:	66 90                	xchg   %ax,%ax
  800f9d:	66 90                	xchg   %ax,%ax
  800f9f:	90                   	nop

00800fa0 <devcons_close>:
  return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  USED(fd);

  return 0;
}
  800fa3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa8:	5d                   	pop    %ebp
  800fa9:	c3                   	ret    

00800faa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	83 ec 18             	sub    $0x18,%esp
  strcpy(stat->st_name, "<cons>");
  800fb0:	c7 44 24 04 af 20 80 	movl   $0x8020af,0x4(%esp)
  800fb7:	00 
  800fb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fbb:	89 04 24             	mov    %eax,(%esp)
  800fbe:	e8 a4 08 00 00       	call   801867 <strcpy>
  return 0;
}
  800fc3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc8:	c9                   	leave  
  800fc9:	c3                   	ret    

00800fca <devcons_write>:
  return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	57                   	push   %edi
  800fce:	56                   	push   %esi
  800fcf:	53                   	push   %ebx
  800fd0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  800fd6:	bb 00 00 00 00       	mov    $0x0,%ebx
    m = n - tot;
    if (m > sizeof(buf) - 1)
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
  800fdb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  800fe1:	eb 31                	jmp    801014 <devcons_write+0x4a>
    m = n - tot;
  800fe3:	8b 75 10             	mov    0x10(%ebp),%esi
  800fe6:	29 de                	sub    %ebx,%esi
    if (m > sizeof(buf) - 1)
  800fe8:	83 fe 7f             	cmp    $0x7f,%esi
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
    m = n - tot;
  800feb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800ff0:	0f 47 f2             	cmova  %edx,%esi
    if (m > sizeof(buf) - 1)
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
  800ff3:	89 74 24 08          	mov    %esi,0x8(%esp)
  800ff7:	03 45 0c             	add    0xc(%ebp),%eax
  800ffa:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ffe:	89 3c 24             	mov    %edi,(%esp)
  801001:	e8 fe 09 00 00       	call   801a04 <memmove>
    sys_cputs(buf, m);
  801006:	89 74 24 04          	mov    %esi,0x4(%esp)
  80100a:	89 3c 24             	mov    %edi,(%esp)
  80100d:	e8 9f f0 ff ff       	call   8000b1 <sys_cputs>
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  801012:	01 f3                	add    %esi,%ebx
  801014:	89 d8                	mov    %ebx,%eax
  801016:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801019:	72 c8                	jb     800fe3 <devcons_write+0x19>
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
    sys_cputs(buf, m);
  }
  return tot;
}
  80101b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801021:	5b                   	pop    %ebx
  801022:	5e                   	pop    %esi
  801023:	5f                   	pop    %edi
  801024:	5d                   	pop    %ebp
  801025:	c3                   	ret    

00801026 <devcons_read>:
  return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	83 ec 08             	sub    $0x8,%esp
  int c;

  if (n == 0)
    return 0;
  80102c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  int c;

  if (n == 0)
  801031:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801035:	75 07                	jne    80103e <devcons_read+0x18>
  801037:	eb 2a                	jmp    801063 <devcons_read+0x3d>
    return 0;

  while ((c = sys_cgetc()) == 0)
    sys_yield();
  801039:	e8 21 f1 ff ff       	call   80015f <sys_yield>
  int c;

  if (n == 0)
    return 0;

  while ((c = sys_cgetc()) == 0)
  80103e:	66 90                	xchg   %ax,%ax
  801040:	e8 8a f0 ff ff       	call   8000cf <sys_cgetc>
  801045:	85 c0                	test   %eax,%eax
  801047:	74 f0                	je     801039 <devcons_read+0x13>
    sys_yield();
  if (c < 0)
  801049:	85 c0                	test   %eax,%eax
  80104b:	78 16                	js     801063 <devcons_read+0x3d>
    return c;
  if (c == 0x04)        // ctl-d is eof
  80104d:	83 f8 04             	cmp    $0x4,%eax
  801050:	74 0c                	je     80105e <devcons_read+0x38>
    return 0;
  *(char*)vbuf = c;
  801052:	8b 55 0c             	mov    0xc(%ebp),%edx
  801055:	88 02                	mov    %al,(%edx)
  return 1;
  801057:	b8 01 00 00 00       	mov    $0x1,%eax
  80105c:	eb 05                	jmp    801063 <devcons_read+0x3d>
  while ((c = sys_cgetc()) == 0)
    sys_yield();
  if (c < 0)
    return c;
  if (c == 0x04)        // ctl-d is eof
    return 0;
  80105e:	b8 00 00 00 00       	mov    $0x0,%eax
  *(char*)vbuf = c;
  return 1;
}
  801063:	c9                   	leave  
  801064:	c3                   	ret    

00801065 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801065:	55                   	push   %ebp
  801066:	89 e5                	mov    %esp,%ebp
  801068:	83 ec 28             	sub    $0x28,%esp
  char c = ch;
  80106b:	8b 45 08             	mov    0x8(%ebp),%eax
  80106e:	88 45 f7             	mov    %al,-0x9(%ebp)

  // Unlike standard Unix's putchar,
  // the cputchar function _always_ outputs to the system console.
  sys_cputs(&c, 1);
  801071:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801078:	00 
  801079:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80107c:	89 04 24             	mov    %eax,(%esp)
  80107f:	e8 2d f0 ff ff       	call   8000b1 <sys_cputs>
}
  801084:	c9                   	leave  
  801085:	c3                   	ret    

00801086 <getchar>:

int
getchar(void)
{
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
  801089:	83 ec 28             	sub    $0x28,%esp
  int r;

  // JOS does, however, support standard _input_ redirection,
  // allowing the user to redirect script files to the shell and such.
  // getchar() reads a character from file descriptor 0.
  r = read(0, &c, 1);
  80108c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801093:	00 
  801094:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801097:	89 44 24 04          	mov    %eax,0x4(%esp)
  80109b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010a2:	e8 4e f6 ff ff       	call   8006f5 <read>
  if (r < 0)
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	78 0f                	js     8010ba <getchar+0x34>
    return r;
  if (r < 1)
  8010ab:	85 c0                	test   %eax,%eax
  8010ad:	7e 06                	jle    8010b5 <getchar+0x2f>
    return -E_EOF;
  return c;
  8010af:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8010b3:	eb 05                	jmp    8010ba <getchar+0x34>
  // getchar() reads a character from file descriptor 0.
  r = read(0, &c, 1);
  if (r < 0)
    return r;
  if (r < 1)
    return -E_EOF;
  8010b5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  /* int r;
  // sys_cgetc does not block, but getchar should.
  while ((r = sys_cgetc()) == 0)
    sys_yield();
  return r; */
}
  8010ba:	c9                   	leave  
  8010bb:	c3                   	ret    

008010bc <iscons>:
  .dev_stat   =     devcons_stat
};

int
iscons(int fdnum)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	83 ec 28             	sub    $0x28,%esp
  int r;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cc:	89 04 24             	mov    %eax,(%esp)
  8010cf:	e8 92 f3 ff ff       	call   800466 <fd_lookup>
  8010d4:	85 c0                	test   %eax,%eax
  8010d6:	78 11                	js     8010e9 <iscons+0x2d>
    return r;
  return fd->fd_dev_id == devcons.dev_id;
  8010d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010db:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8010e1:	39 10                	cmp    %edx,(%eax)
  8010e3:	0f 94 c0             	sete   %al
  8010e6:	0f b6 c0             	movzbl %al,%eax
}
  8010e9:	c9                   	leave  
  8010ea:	c3                   	ret    

008010eb <opencons>:

int
opencons(void)
{
  8010eb:	55                   	push   %ebp
  8010ec:	89 e5                	mov    %esp,%ebp
  8010ee:	83 ec 28             	sub    $0x28,%esp
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
  8010f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f4:	89 04 24             	mov    %eax,(%esp)
  8010f7:	e8 1b f3 ff ff       	call   800417 <fd_alloc>
    return r;
  8010fc:	89 c2                	mov    %eax,%edx
opencons(void)
{
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
  8010fe:	85 c0                	test   %eax,%eax
  801100:	78 40                	js     801142 <opencons+0x57>
    return r;
  if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801102:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801109:	00 
  80110a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80110d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801111:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801118:	e8 61 f0 ff ff       	call   80017e <sys_page_alloc>
    return r;
  80111d:	89 c2                	mov    %eax,%edx
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
    return r;
  if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80111f:	85 c0                	test   %eax,%eax
  801121:	78 1f                	js     801142 <opencons+0x57>
    return r;
  fd->fd_dev_id = devcons.dev_id;
  801123:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801129:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80112c:	89 10                	mov    %edx,(%eax)
  fd->fd_omode = O_RDWR;
  80112e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801131:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
  return fd2num(fd);
  801138:	89 04 24             	mov    %eax,(%esp)
  80113b:	e8 b0 f2 ff ff       	call   8003f0 <fd2num>
  801140:	89 c2                	mov    %eax,%edx
}
  801142:	89 d0                	mov    %edx,%eax
  801144:	c9                   	leave  
  801145:	c3                   	ret    

00801146 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
  801149:	56                   	push   %esi
  80114a:	53                   	push   %ebx
  80114b:	83 ec 20             	sub    $0x20,%esp
  va_list ap;

  va_start(ap, fmt);
  80114e:	8d 5d 14             	lea    0x14(%ebp),%ebx

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  801151:	8b 35 04 30 80 00    	mov    0x803004,%esi
  801157:	e8 e4 ef ff ff       	call   800140 <sys_getenvid>
  80115c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80115f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801163:	8b 55 08             	mov    0x8(%ebp),%edx
  801166:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80116a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80116e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801172:	c7 04 24 bc 20 80 00 	movl   $0x8020bc,(%esp)
  801179:	e8 c1 00 00 00       	call   80123f <cprintf>
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  80117e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801182:	8b 45 10             	mov    0x10(%ebp),%eax
  801185:	89 04 24             	mov    %eax,(%esp)
  801188:	e8 51 00 00 00       	call   8011de <vcprintf>
  cprintf("\n");
  80118d:	c7 04 24 a8 20 80 00 	movl   $0x8020a8,(%esp)
  801194:	e8 a6 00 00 00       	call   80123f <cprintf>

  // Cause a breakpoint exception
  while (1)
    asm volatile ("int3");
  801199:	cc                   	int3   
  80119a:	eb fd                	jmp    801199 <_panic+0x53>

0080119c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
  80119f:	53                   	push   %ebx
  8011a0:	83 ec 14             	sub    $0x14,%esp
  8011a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  b->buf[b->idx++] = ch;
  8011a6:	8b 13                	mov    (%ebx),%edx
  8011a8:	8d 42 01             	lea    0x1(%edx),%eax
  8011ab:	89 03                	mov    %eax,(%ebx)
  8011ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011b0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
  if (b->idx == 256-1) {
  8011b4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8011b9:	75 19                	jne    8011d4 <putch+0x38>
    sys_cputs(b->buf, b->idx);
  8011bb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8011c2:	00 
  8011c3:	8d 43 08             	lea    0x8(%ebx),%eax
  8011c6:	89 04 24             	mov    %eax,(%esp)
  8011c9:	e8 e3 ee ff ff       	call   8000b1 <sys_cputs>
    b->idx = 0;
  8011ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  }
  b->cnt++;
  8011d4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8011d8:	83 c4 14             	add    $0x14,%esp
  8011db:	5b                   	pop    %ebx
  8011dc:	5d                   	pop    %ebp
  8011dd:	c3                   	ret    

008011de <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8011de:	55                   	push   %ebp
  8011df:	89 e5                	mov    %esp,%ebp
  8011e1:	81 ec 28 01 00 00    	sub    $0x128,%esp
  struct printbuf b;

  b.idx = 0;
  8011e7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8011ee:	00 00 00 
  b.cnt = 0;
  8011f1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8011f8:	00 00 00 
  vprintfmt((void*)putch, &b, fmt, ap);
  8011fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801202:	8b 45 08             	mov    0x8(%ebp),%eax
  801205:	89 44 24 08          	mov    %eax,0x8(%esp)
  801209:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80120f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801213:	c7 04 24 9c 11 80 00 	movl   $0x80119c,(%esp)
  80121a:	e8 af 01 00 00       	call   8013ce <vprintfmt>
  sys_cputs(b.buf, b.idx);
  80121f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801225:	89 44 24 04          	mov    %eax,0x4(%esp)
  801229:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80122f:	89 04 24             	mov    %eax,(%esp)
  801232:	e8 7a ee ff ff       	call   8000b1 <sys_cputs>

  return b.cnt;
}
  801237:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80123d:	c9                   	leave  
  80123e:	c3                   	ret    

0080123f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80123f:	55                   	push   %ebp
  801240:	89 e5                	mov    %esp,%ebp
  801242:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  801245:	8d 45 0c             	lea    0xc(%ebp),%eax
  cnt = vcprintf(fmt, ap);
  801248:	89 44 24 04          	mov    %eax,0x4(%esp)
  80124c:	8b 45 08             	mov    0x8(%ebp),%eax
  80124f:	89 04 24             	mov    %eax,(%esp)
  801252:	e8 87 ff ff ff       	call   8011de <vcprintf>
  va_end(ap);

  return cnt;
}
  801257:	c9                   	leave  
  801258:	c3                   	ret    
  801259:	66 90                	xchg   %ax,%ax
  80125b:	66 90                	xchg   %ax,%ax
  80125d:	66 90                	xchg   %ax,%ax
  80125f:	90                   	nop

00801260 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
         unsigned long long num, unsigned base, int width, int padc)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	57                   	push   %edi
  801264:	56                   	push   %esi
  801265:	53                   	push   %ebx
  801266:	83 ec 3c             	sub    $0x3c,%esp
  801269:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80126c:	89 d7                	mov    %edx,%edi
  80126e:	8b 45 08             	mov    0x8(%ebp),%eax
  801271:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801274:	8b 45 0c             	mov    0xc(%ebp),%eax
  801277:	89 c3                	mov    %eax,%ebx
  801279:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80127c:	8b 45 10             	mov    0x10(%ebp),%eax
  80127f:	8b 75 14             	mov    0x14(%ebp),%esi
  // first recursively print all preceding (more significant) digits
  if (num >= base)
  801282:	b9 00 00 00 00       	mov    $0x0,%ecx
  801287:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80128a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80128d:	39 d9                	cmp    %ebx,%ecx
  80128f:	72 05                	jb     801296 <printnum+0x36>
  801291:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  801294:	77 69                	ja     8012ff <printnum+0x9f>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  801296:	8b 4d 18             	mov    0x18(%ebp),%ecx
  801299:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80129d:	83 ee 01             	sub    $0x1,%esi
  8012a0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012a8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012ac:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8012b0:	89 c3                	mov    %eax,%ebx
  8012b2:	89 d6                	mov    %edx,%esi
  8012b4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8012b7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8012ba:	89 54 24 08          	mov    %edx,0x8(%esp)
  8012be:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8012c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012c5:	89 04 24             	mov    %eax,(%esp)
  8012c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8012cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012cf:	e8 4c 0a 00 00       	call   801d20 <__udivdi3>
  8012d4:	89 d9                	mov    %ebx,%ecx
  8012d6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012da:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012de:	89 04 24             	mov    %eax,(%esp)
  8012e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012e5:	89 fa                	mov    %edi,%edx
  8012e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012ea:	e8 71 ff ff ff       	call   801260 <printnum>
  8012ef:	eb 1b                	jmp    80130c <printnum+0xac>
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
      putch(padc, putdat);
  8012f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012f5:	8b 45 18             	mov    0x18(%ebp),%eax
  8012f8:	89 04 24             	mov    %eax,(%esp)
  8012fb:	ff d3                	call   *%ebx
  8012fd:	eb 03                	jmp    801302 <printnum+0xa2>
  8012ff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  // first recursively print all preceding (more significant) digits
  if (num >= base)
    printnum(putch, putdat, num / base, base, width - 1, padc);
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
  801302:	83 ee 01             	sub    $0x1,%esi
  801305:	85 f6                	test   %esi,%esi
  801307:	7f e8                	jg     8012f1 <printnum+0x91>
  801309:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
      putch(padc, putdat);
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  80130c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801310:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801314:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801317:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80131a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80131e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801322:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801325:	89 04 24             	mov    %eax,(%esp)
  801328:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80132b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80132f:	e8 1c 0b 00 00       	call   801e50 <__umoddi3>
  801334:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801338:	0f be 80 df 20 80 00 	movsbl 0x8020df(%eax),%eax
  80133f:	89 04 24             	mov    %eax,(%esp)
  801342:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801345:	ff d0                	call   *%eax
}
  801347:	83 c4 3c             	add    $0x3c,%esp
  80134a:	5b                   	pop    %ebx
  80134b:	5e                   	pop    %esi
  80134c:	5f                   	pop    %edi
  80134d:	5d                   	pop    %ebp
  80134e:	c3                   	ret    

0080134f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80134f:	55                   	push   %ebp
  801350:	89 e5                	mov    %esp,%ebp
  if (lflag >= 2)
  801352:	83 fa 01             	cmp    $0x1,%edx
  801355:	7e 0e                	jle    801365 <getuint+0x16>
    return va_arg(*ap, unsigned long long);
  801357:	8b 10                	mov    (%eax),%edx
  801359:	8d 4a 08             	lea    0x8(%edx),%ecx
  80135c:	89 08                	mov    %ecx,(%eax)
  80135e:	8b 02                	mov    (%edx),%eax
  801360:	8b 52 04             	mov    0x4(%edx),%edx
  801363:	eb 22                	jmp    801387 <getuint+0x38>
  else if (lflag)
  801365:	85 d2                	test   %edx,%edx
  801367:	74 10                	je     801379 <getuint+0x2a>
    return va_arg(*ap, unsigned long);
  801369:	8b 10                	mov    (%eax),%edx
  80136b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80136e:	89 08                	mov    %ecx,(%eax)
  801370:	8b 02                	mov    (%edx),%eax
  801372:	ba 00 00 00 00       	mov    $0x0,%edx
  801377:	eb 0e                	jmp    801387 <getuint+0x38>
  else
    return va_arg(*ap, unsigned int);
  801379:	8b 10                	mov    (%eax),%edx
  80137b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80137e:	89 08                	mov    %ecx,(%eax)
  801380:	8b 02                	mov    (%edx),%eax
  801382:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801387:	5d                   	pop    %ebp
  801388:	c3                   	ret    

00801389 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801389:	55                   	push   %ebp
  80138a:	89 e5                	mov    %esp,%ebp
  80138c:	8b 45 0c             	mov    0xc(%ebp),%eax
  b->cnt++;
  80138f:	83 40 08 01          	addl   $0x1,0x8(%eax)
  if (b->buf < b->ebuf)
  801393:	8b 10                	mov    (%eax),%edx
  801395:	3b 50 04             	cmp    0x4(%eax),%edx
  801398:	73 0a                	jae    8013a4 <sprintputch+0x1b>
    *b->buf++ = ch;
  80139a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80139d:	89 08                	mov    %ecx,(%eax)
  80139f:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a2:	88 02                	mov    %al,(%edx)
}
  8013a4:	5d                   	pop    %ebp
  8013a5:	c3                   	ret    

008013a6 <printfmt>:
  }
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8013a6:	55                   	push   %ebp
  8013a7:	89 e5                	mov    %esp,%ebp
  8013a9:	83 ec 18             	sub    $0x18,%esp
  va_list ap;

  va_start(ap, fmt);
  8013ac:	8d 45 14             	lea    0x14(%ebp),%eax
  vprintfmt(putch, putdat, fmt, ap);
  8013af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8013b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c4:	89 04 24             	mov    %eax,(%esp)
  8013c7:	e8 02 00 00 00       	call   8013ce <vprintfmt>
  va_end(ap);
}
  8013cc:	c9                   	leave  
  8013cd:	c3                   	ret    

008013ce <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
  8013d1:	57                   	push   %edi
  8013d2:	56                   	push   %esi
  8013d3:	53                   	push   %ebx
  8013d4:	83 ec 3c             	sub    $0x3c,%esp
  8013d7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8013da:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013dd:	eb 14                	jmp    8013f3 <vprintfmt+0x25>
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
      if (ch == '\0')
  8013df:	85 c0                	test   %eax,%eax
  8013e1:	0f 84 b3 03 00 00    	je     80179a <vprintfmt+0x3cc>
        return;
      putch(ch, putdat);
  8013e7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013eb:	89 04 24             	mov    %eax,(%esp)
  8013ee:	ff 55 08             	call   *0x8(%ebp)
  unsigned long long num;
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
  8013f1:	89 f3                	mov    %esi,%ebx
  8013f3:	8d 73 01             	lea    0x1(%ebx),%esi
  8013f6:	0f b6 03             	movzbl (%ebx),%eax
  8013f9:	83 f8 25             	cmp    $0x25,%eax
  8013fc:	75 e1                	jne    8013df <vprintfmt+0x11>
  8013fe:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  801402:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801409:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801410:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  801417:	ba 00 00 00 00       	mov    $0x0,%edx
  80141c:	eb 1d                	jmp    80143b <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80141e:	89 de                	mov    %ebx,%esi

    // flag to pad on the right
    case '-':
      padc = '-';
  801420:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  801424:	eb 15                	jmp    80143b <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  801426:	89 de                	mov    %ebx,%esi
      padc = '-';
      goto reswitch;

    // flag to pad with 0's instead of spaces
    case '0':
      padc = '0';
  801428:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80142c:	eb 0d                	jmp    80143b <vprintfmt+0x6d>
      altflag = 1;
      goto reswitch;

process_precision:
      if (width < 0)
        width = precision, precision = -1;
  80142e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801431:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801434:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80143b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80143e:	0f b6 0e             	movzbl (%esi),%ecx
  801441:	0f b6 c1             	movzbl %cl,%eax
  801444:	83 e9 23             	sub    $0x23,%ecx
  801447:	80 f9 55             	cmp    $0x55,%cl
  80144a:	0f 87 2a 03 00 00    	ja     80177a <vprintfmt+0x3ac>
  801450:	0f b6 c9             	movzbl %cl,%ecx
  801453:	ff 24 8d 20 22 80 00 	jmp    *0x802220(,%ecx,4)
  80145a:	89 de                	mov    %ebx,%esi
  80145c:	b9 00 00 00 00       	mov    $0x0,%ecx
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
        precision = precision * 10 + ch - '0';
  801461:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  801464:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
        ch = *fmt;
  801468:	0f be 06             	movsbl (%esi),%eax
        if (ch < '0' || ch > '9')
  80146b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80146e:	83 fb 09             	cmp    $0x9,%ebx
  801471:	77 36                	ja     8014a9 <vprintfmt+0xdb>
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
  801473:	83 c6 01             	add    $0x1,%esi
        precision = precision * 10 + ch - '0';
        ch = *fmt;
        if (ch < '0' || ch > '9')
          break;
      }
  801476:	eb e9                	jmp    801461 <vprintfmt+0x93>
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
  801478:	8b 45 14             	mov    0x14(%ebp),%eax
  80147b:	8d 48 04             	lea    0x4(%eax),%ecx
  80147e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801481:	8b 00                	mov    (%eax),%eax
  801483:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  801486:	89 de                	mov    %ebx,%esi
      }
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
      goto process_precision;
  801488:	eb 22                	jmp    8014ac <vprintfmt+0xde>
  80148a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80148d:	85 c9                	test   %ecx,%ecx
  80148f:	b8 00 00 00 00       	mov    $0x0,%eax
  801494:	0f 49 c1             	cmovns %ecx,%eax
  801497:	89 45 dc             	mov    %eax,-0x24(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80149a:	89 de                	mov    %ebx,%esi
  80149c:	eb 9d                	jmp    80143b <vprintfmt+0x6d>
  80149e:	89 de                	mov    %ebx,%esi
      if (width < 0)
        width = 0;
      goto reswitch;

    case '#':
      altflag = 1;
  8014a0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
      goto reswitch;
  8014a7:	eb 92                	jmp    80143b <vprintfmt+0x6d>
  8014a9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

process_precision:
      if (width < 0)
  8014ac:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8014b0:	79 89                	jns    80143b <vprintfmt+0x6d>
  8014b2:	e9 77 ff ff ff       	jmp    80142e <vprintfmt+0x60>
        width = precision, precision = -1;
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
  8014b7:	83 c2 01             	add    $0x1,%edx
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8014ba:	89 de                	mov    %ebx,%esi
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
      goto reswitch;
  8014bc:	e9 7a ff ff ff       	jmp    80143b <vprintfmt+0x6d>

    // character
    case 'c':
      putch(va_arg(ap, int), putdat);
  8014c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c4:	8d 50 04             	lea    0x4(%eax),%edx
  8014c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8014ca:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014ce:	8b 00                	mov    (%eax),%eax
  8014d0:	89 04 24             	mov    %eax,(%esp)
  8014d3:	ff 55 08             	call   *0x8(%ebp)
      break;
  8014d6:	e9 18 ff ff ff       	jmp    8013f3 <vprintfmt+0x25>

    // error message
    case 'e':
      err = va_arg(ap, int);
  8014db:	8b 45 14             	mov    0x14(%ebp),%eax
  8014de:	8d 50 04             	lea    0x4(%eax),%edx
  8014e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8014e4:	8b 00                	mov    (%eax),%eax
  8014e6:	99                   	cltd   
  8014e7:	31 d0                	xor    %edx,%eax
  8014e9:	29 d0                	sub    %edx,%eax
      if (err < 0)
        err = -err;
      if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8014eb:	83 f8 0f             	cmp    $0xf,%eax
  8014ee:	7f 0b                	jg     8014fb <vprintfmt+0x12d>
  8014f0:	8b 14 85 80 23 80 00 	mov    0x802380(,%eax,4),%edx
  8014f7:	85 d2                	test   %edx,%edx
  8014f9:	75 20                	jne    80151b <vprintfmt+0x14d>
        printfmt(putch, putdat, "error %d", err);
  8014fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014ff:	c7 44 24 08 f7 20 80 	movl   $0x8020f7,0x8(%esp)
  801506:	00 
  801507:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80150b:	8b 45 08             	mov    0x8(%ebp),%eax
  80150e:	89 04 24             	mov    %eax,(%esp)
  801511:	e8 90 fe ff ff       	call   8013a6 <printfmt>
  801516:	e9 d8 fe ff ff       	jmp    8013f3 <vprintfmt+0x25>
      else
        printfmt(putch, putdat, "%s", p);
  80151b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80151f:	c7 44 24 08 00 21 80 	movl   $0x802100,0x8(%esp)
  801526:	00 
  801527:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80152b:	8b 45 08             	mov    0x8(%ebp),%eax
  80152e:	89 04 24             	mov    %eax,(%esp)
  801531:	e8 70 fe ff ff       	call   8013a6 <printfmt>
  801536:	e9 b8 fe ff ff       	jmp    8013f3 <vprintfmt+0x25>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80153b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80153e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801541:	89 45 d0             	mov    %eax,-0x30(%ebp)
        printfmt(putch, putdat, "%s", p);
      break;

    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
  801544:	8b 45 14             	mov    0x14(%ebp),%eax
  801547:	8d 50 04             	lea    0x4(%eax),%edx
  80154a:	89 55 14             	mov    %edx,0x14(%ebp)
  80154d:	8b 30                	mov    (%eax),%esi
        p = "(null)";
  80154f:	85 f6                	test   %esi,%esi
  801551:	b8 f0 20 80 00       	mov    $0x8020f0,%eax
  801556:	0f 44 f0             	cmove  %eax,%esi
      if (width > 0 && padc != '-')
  801559:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80155d:	0f 84 97 00 00 00    	je     8015fa <vprintfmt+0x22c>
  801563:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  801567:	0f 8e 9b 00 00 00    	jle    801608 <vprintfmt+0x23a>
        for (width -= strnlen(p, precision); width > 0; width--)
  80156d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801571:	89 34 24             	mov    %esi,(%esp)
  801574:	e8 cf 02 00 00       	call   801848 <strnlen>
  801579:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80157c:	29 c2                	sub    %eax,%edx
  80157e:	89 55 d0             	mov    %edx,-0x30(%ebp)
          putch(padc, putdat);
  801581:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801585:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801588:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80158b:	8b 75 08             	mov    0x8(%ebp),%esi
  80158e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801591:	89 d3                	mov    %edx,%ebx
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
  801593:	eb 0f                	jmp    8015a4 <vprintfmt+0x1d6>
          putch(padc, putdat);
  801595:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801599:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80159c:	89 04 24             	mov    %eax,(%esp)
  80159f:	ff d6                	call   *%esi
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
  8015a1:	83 eb 01             	sub    $0x1,%ebx
  8015a4:	85 db                	test   %ebx,%ebx
  8015a6:	7f ed                	jg     801595 <vprintfmt+0x1c7>
  8015a8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8015ab:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8015ae:	85 d2                	test   %edx,%edx
  8015b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8015b5:	0f 49 c2             	cmovns %edx,%eax
  8015b8:	29 c2                	sub    %eax,%edx
  8015ba:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8015bd:	89 d7                	mov    %edx,%edi
  8015bf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8015c2:	eb 50                	jmp    801614 <vprintfmt+0x246>
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
  8015c4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8015c8:	74 1e                	je     8015e8 <vprintfmt+0x21a>
  8015ca:	0f be d2             	movsbl %dl,%edx
  8015cd:	83 ea 20             	sub    $0x20,%edx
  8015d0:	83 fa 5e             	cmp    $0x5e,%edx
  8015d3:	76 13                	jbe    8015e8 <vprintfmt+0x21a>
          putch('?', putdat);
  8015d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015dc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8015e3:	ff 55 08             	call   *0x8(%ebp)
  8015e6:	eb 0d                	jmp    8015f5 <vprintfmt+0x227>
        else
          putch(ch, putdat);
  8015e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015eb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015ef:	89 04 24             	mov    %eax,(%esp)
  8015f2:	ff 55 08             	call   *0x8(%ebp)
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8015f5:	83 ef 01             	sub    $0x1,%edi
  8015f8:	eb 1a                	jmp    801614 <vprintfmt+0x246>
  8015fa:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8015fd:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801600:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801603:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801606:	eb 0c                	jmp    801614 <vprintfmt+0x246>
  801608:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80160b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80160e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801611:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801614:	83 c6 01             	add    $0x1,%esi
  801617:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80161b:	0f be c2             	movsbl %dl,%eax
  80161e:	85 c0                	test   %eax,%eax
  801620:	74 27                	je     801649 <vprintfmt+0x27b>
  801622:	85 db                	test   %ebx,%ebx
  801624:	78 9e                	js     8015c4 <vprintfmt+0x1f6>
  801626:	83 eb 01             	sub    $0x1,%ebx
  801629:	79 99                	jns    8015c4 <vprintfmt+0x1f6>
  80162b:	89 f8                	mov    %edi,%eax
  80162d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801630:	8b 75 08             	mov    0x8(%ebp),%esi
  801633:	89 c3                	mov    %eax,%ebx
  801635:	eb 1a                	jmp    801651 <vprintfmt+0x283>
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
        putch(' ', putdat);
  801637:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80163b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801642:	ff d6                	call   *%esi
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
  801644:	83 eb 01             	sub    $0x1,%ebx
  801647:	eb 08                	jmp    801651 <vprintfmt+0x283>
  801649:	89 fb                	mov    %edi,%ebx
  80164b:	8b 75 08             	mov    0x8(%ebp),%esi
  80164e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801651:	85 db                	test   %ebx,%ebx
  801653:	7f e2                	jg     801637 <vprintfmt+0x269>
  801655:	89 75 08             	mov    %esi,0x8(%ebp)
  801658:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80165b:	e9 93 fd ff ff       	jmp    8013f3 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  if (lflag >= 2)
  801660:	83 fa 01             	cmp    $0x1,%edx
  801663:	7e 16                	jle    80167b <vprintfmt+0x2ad>
    return va_arg(*ap, long long);
  801665:	8b 45 14             	mov    0x14(%ebp),%eax
  801668:	8d 50 08             	lea    0x8(%eax),%edx
  80166b:	89 55 14             	mov    %edx,0x14(%ebp)
  80166e:	8b 50 04             	mov    0x4(%eax),%edx
  801671:	8b 00                	mov    (%eax),%eax
  801673:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801676:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801679:	eb 32                	jmp    8016ad <vprintfmt+0x2df>
  else if (lflag)
  80167b:	85 d2                	test   %edx,%edx
  80167d:	74 18                	je     801697 <vprintfmt+0x2c9>
    return va_arg(*ap, long);
  80167f:	8b 45 14             	mov    0x14(%ebp),%eax
  801682:	8d 50 04             	lea    0x4(%eax),%edx
  801685:	89 55 14             	mov    %edx,0x14(%ebp)
  801688:	8b 30                	mov    (%eax),%esi
  80168a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80168d:	89 f0                	mov    %esi,%eax
  80168f:	c1 f8 1f             	sar    $0x1f,%eax
  801692:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801695:	eb 16                	jmp    8016ad <vprintfmt+0x2df>
  else
    return va_arg(*ap, int);
  801697:	8b 45 14             	mov    0x14(%ebp),%eax
  80169a:	8d 50 04             	lea    0x4(%eax),%edx
  80169d:	89 55 14             	mov    %edx,0x14(%ebp)
  8016a0:	8b 30                	mov    (%eax),%esi
  8016a2:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8016a5:	89 f0                	mov    %esi,%eax
  8016a7:	c1 f8 1f             	sar    $0x1f,%eax
  8016aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        putch(' ', putdat);
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
  8016ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      if ((long long)num < 0) {
        putch('-', putdat);
        num = -(long long)num;
      }
      base = 10;
  8016b3:	b9 0a 00 00 00       	mov    $0xa,%ecx
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
      if ((long long)num < 0) {
  8016b8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8016bc:	0f 89 80 00 00 00    	jns    801742 <vprintfmt+0x374>
        putch('-', putdat);
  8016c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8016c6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8016cd:	ff 55 08             	call   *0x8(%ebp)
        num = -(long long)num;
  8016d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016d3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016d6:	f7 d8                	neg    %eax
  8016d8:	83 d2 00             	adc    $0x0,%edx
  8016db:	f7 da                	neg    %edx
      }
      base = 10;
  8016dd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8016e2:	eb 5e                	jmp    801742 <vprintfmt+0x374>
      goto number;

    // unsigned decimal
    case 'u':
      num = getuint(&ap, lflag);
  8016e4:	8d 45 14             	lea    0x14(%ebp),%eax
  8016e7:	e8 63 fc ff ff       	call   80134f <getuint>
      base = 10;
  8016ec:	b9 0a 00 00 00       	mov    $0xa,%ecx
      goto number;
  8016f1:	eb 4f                	jmp    801742 <vprintfmt+0x374>

    // (unsigned) octal
    case 'o':
      num = getuint(&ap, lflag);
  8016f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8016f6:	e8 54 fc ff ff       	call   80134f <getuint>
      base = 8;
  8016fb:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  801700:	eb 40                	jmp    801742 <vprintfmt+0x374>

    // pointer
    case 'p':
      putch('0', putdat);
  801702:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801706:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80170d:	ff 55 08             	call   *0x8(%ebp)
      putch('x', putdat);
  801710:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801714:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80171b:	ff 55 08             	call   *0x8(%ebp)
      num = (unsigned long long)
            (uintptr_t)va_arg(ap, void *);
  80171e:	8b 45 14             	mov    0x14(%ebp),%eax
  801721:	8d 50 04             	lea    0x4(%eax),%edx
  801724:	89 55 14             	mov    %edx,0x14(%ebp)

    // pointer
    case 'p':
      putch('0', putdat);
      putch('x', putdat);
      num = (unsigned long long)
  801727:	8b 00                	mov    (%eax),%eax
  801729:	ba 00 00 00 00       	mov    $0x0,%edx
            (uintptr_t)va_arg(ap, void *);
      base = 16;
  80172e:	b9 10 00 00 00       	mov    $0x10,%ecx
      goto number;
  801733:	eb 0d                	jmp    801742 <vprintfmt+0x374>

    // (unsigned) hexadecimal
    case 'x':
      num = getuint(&ap, lflag);
  801735:	8d 45 14             	lea    0x14(%ebp),%eax
  801738:	e8 12 fc ff ff       	call   80134f <getuint>
      base = 16;
  80173d:	b9 10 00 00 00       	mov    $0x10,%ecx
number:
      printnum(putch, putdat, num, base, width, padc);
  801742:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  801746:	89 74 24 10          	mov    %esi,0x10(%esp)
  80174a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80174d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801751:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801755:	89 04 24             	mov    %eax,(%esp)
  801758:	89 54 24 04          	mov    %edx,0x4(%esp)
  80175c:	89 fa                	mov    %edi,%edx
  80175e:	8b 45 08             	mov    0x8(%ebp),%eax
  801761:	e8 fa fa ff ff       	call   801260 <printnum>
      break;
  801766:	e9 88 fc ff ff       	jmp    8013f3 <vprintfmt+0x25>

    // escaped '%' character
    case '%':
      putch(ch, putdat);
  80176b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80176f:	89 04 24             	mov    %eax,(%esp)
  801772:	ff 55 08             	call   *0x8(%ebp)
      break;
  801775:	e9 79 fc ff ff       	jmp    8013f3 <vprintfmt+0x25>

    // unrecognized escape sequence - just print it literally
    default:
      putch('%', putdat);
  80177a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80177e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801785:	ff 55 08             	call   *0x8(%ebp)
      for (fmt--; fmt[-1] != '%'; fmt--)
  801788:	89 f3                	mov    %esi,%ebx
  80178a:	eb 03                	jmp    80178f <vprintfmt+0x3c1>
  80178c:	83 eb 01             	sub    $0x1,%ebx
  80178f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  801793:	75 f7                	jne    80178c <vprintfmt+0x3be>
  801795:	e9 59 fc ff ff       	jmp    8013f3 <vprintfmt+0x25>
        /* do nothing */;
      break;
    }
  }
}
  80179a:	83 c4 3c             	add    $0x3c,%esp
  80179d:	5b                   	pop    %ebx
  80179e:	5e                   	pop    %esi
  80179f:	5f                   	pop    %edi
  8017a0:	5d                   	pop    %ebp
  8017a1:	c3                   	ret    

008017a2 <vsnprintf>:
    *b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8017a2:	55                   	push   %ebp
  8017a3:	89 e5                	mov    %esp,%ebp
  8017a5:	83 ec 28             	sub    $0x28,%esp
  8017a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  struct sprintbuf b = { buf, buf+n-1, 0 };
  8017ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8017b1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8017b5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8017b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  if (buf == NULL || n < 1)
  8017bf:	85 c0                	test   %eax,%eax
  8017c1:	74 30                	je     8017f3 <vsnprintf+0x51>
  8017c3:	85 d2                	test   %edx,%edx
  8017c5:	7e 2c                	jle    8017f3 <vsnprintf+0x51>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void*)sprintputch, &b, fmt, ap);
  8017c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8017ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8017d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017d5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8017d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017dc:	c7 04 24 89 13 80 00 	movl   $0x801389,(%esp)
  8017e3:	e8 e6 fb ff ff       	call   8013ce <vprintfmt>

  // null terminate the buffer
  *b.buf = '\0';
  8017e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8017eb:	c6 00 00             	movb   $0x0,(%eax)

  return b.cnt;
  8017ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f1:	eb 05                	jmp    8017f8 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  struct sprintbuf b = { buf, buf+n-1, 0 };

  if (buf == NULL || n < 1)
    return -E_INVAL;
  8017f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

  // null terminate the buffer
  *b.buf = '\0';

  return b.cnt;
}
  8017f8:	c9                   	leave  
  8017f9:	c3                   	ret    

008017fa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8017fa:	55                   	push   %ebp
  8017fb:	89 e5                	mov    %esp,%ebp
  8017fd:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int rc;

  va_start(ap, fmt);
  801800:	8d 45 14             	lea    0x14(%ebp),%eax
  rc = vsnprintf(buf, n, fmt, ap);
  801803:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801807:	8b 45 10             	mov    0x10(%ebp),%eax
  80180a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80180e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801811:	89 44 24 04          	mov    %eax,0x4(%esp)
  801815:	8b 45 08             	mov    0x8(%ebp),%eax
  801818:	89 04 24             	mov    %eax,(%esp)
  80181b:	e8 82 ff ff ff       	call   8017a2 <vsnprintf>
  va_end(ap);

  return rc;
}
  801820:	c9                   	leave  
  801821:	c3                   	ret    
  801822:	66 90                	xchg   %ax,%ax
  801824:	66 90                	xchg   %ax,%ax
  801826:	66 90                	xchg   %ax,%ax
  801828:	66 90                	xchg   %ax,%ax
  80182a:	66 90                	xchg   %ax,%ax
  80182c:	66 90                	xchg   %ax,%ax
  80182e:	66 90                	xchg   %ax,%ax

00801830 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for (n = 0; *s != '\0'; s++)
  801836:	b8 00 00 00 00       	mov    $0x0,%eax
  80183b:	eb 03                	jmp    801840 <strlen+0x10>
    n++;
  80183d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
  int n;

  for (n = 0; *s != '\0'; s++)
  801840:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801844:	75 f7                	jne    80183d <strlen+0xd>
    n++;
  return n;
}
  801846:	5d                   	pop    %ebp
  801847:	c3                   	ret    

00801848 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80184e:	8b 55 0c             	mov    0xc(%ebp),%edx
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801851:	b8 00 00 00 00       	mov    $0x0,%eax
  801856:	eb 03                	jmp    80185b <strnlen+0x13>
    n++;
  801858:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80185b:	39 d0                	cmp    %edx,%eax
  80185d:	74 06                	je     801865 <strnlen+0x1d>
  80185f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801863:	75 f3                	jne    801858 <strnlen+0x10>
    n++;
  return n;
}
  801865:	5d                   	pop    %ebp
  801866:	c3                   	ret    

00801867 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	53                   	push   %ebx
  80186b:	8b 45 08             	mov    0x8(%ebp),%eax
  80186e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  801871:	89 c2                	mov    %eax,%edx
  801873:	83 c2 01             	add    $0x1,%edx
  801876:	83 c1 01             	add    $0x1,%ecx
  801879:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80187d:	88 5a ff             	mov    %bl,-0x1(%edx)
  801880:	84 db                	test   %bl,%bl
  801882:	75 ef                	jne    801873 <strcpy+0xc>
    /* do nothing */;
  return ret;
}
  801884:	5b                   	pop    %ebx
  801885:	5d                   	pop    %ebp
  801886:	c3                   	ret    

00801887 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801887:	55                   	push   %ebp
  801888:	89 e5                	mov    %esp,%ebp
  80188a:	53                   	push   %ebx
  80188b:	83 ec 08             	sub    $0x8,%esp
  80188e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int len = strlen(dst);
  801891:	89 1c 24             	mov    %ebx,(%esp)
  801894:	e8 97 ff ff ff       	call   801830 <strlen>

  strcpy(dst + len, src);
  801899:	8b 55 0c             	mov    0xc(%ebp),%edx
  80189c:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018a0:	01 d8                	add    %ebx,%eax
  8018a2:	89 04 24             	mov    %eax,(%esp)
  8018a5:	e8 bd ff ff ff       	call   801867 <strcpy>
  return dst;
}
  8018aa:	89 d8                	mov    %ebx,%eax
  8018ac:	83 c4 08             	add    $0x8,%esp
  8018af:	5b                   	pop    %ebx
  8018b0:	5d                   	pop    %ebp
  8018b1:	c3                   	ret    

008018b2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
  8018b5:	56                   	push   %esi
  8018b6:	53                   	push   %ebx
  8018b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8018ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018bd:	89 f3                	mov    %esi,%ebx
  8018bf:	03 5d 10             	add    0x10(%ebp),%ebx
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  8018c2:	89 f2                	mov    %esi,%edx
  8018c4:	eb 0f                	jmp    8018d5 <strncpy+0x23>
    *dst++ = *src;
  8018c6:	83 c2 01             	add    $0x1,%edx
  8018c9:	0f b6 01             	movzbl (%ecx),%eax
  8018cc:	88 42 ff             	mov    %al,-0x1(%edx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  8018cf:	80 39 01             	cmpb   $0x1,(%ecx)
  8018d2:	83 d9 ff             	sbb    $0xffffffff,%ecx
{
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  8018d5:	39 da                	cmp    %ebx,%edx
  8018d7:	75 ed                	jne    8018c6 <strncpy+0x14>
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  }
  return ret;
}
  8018d9:	89 f0                	mov    %esi,%eax
  8018db:	5b                   	pop    %ebx
  8018dc:	5e                   	pop    %esi
  8018dd:	5d                   	pop    %ebp
  8018de:	c3                   	ret    

008018df <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8018df:	55                   	push   %ebp
  8018e0:	89 e5                	mov    %esp,%ebp
  8018e2:	56                   	push   %esi
  8018e3:	53                   	push   %ebx
  8018e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8018e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018ed:	89 f0                	mov    %esi,%eax
  8018ef:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  8018f3:	85 c9                	test   %ecx,%ecx
  8018f5:	75 0b                	jne    801902 <strlcpy+0x23>
  8018f7:	eb 1d                	jmp    801916 <strlcpy+0x37>
    while (--size > 0 && *src != '\0')
      *dst++ = *src++;
  8018f9:	83 c0 01             	add    $0x1,%eax
  8018fc:	83 c2 01             	add    $0x1,%edx
  8018ff:	88 48 ff             	mov    %cl,-0x1(%eax)
{
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
    while (--size > 0 && *src != '\0')
  801902:	39 d8                	cmp    %ebx,%eax
  801904:	74 0b                	je     801911 <strlcpy+0x32>
  801906:	0f b6 0a             	movzbl (%edx),%ecx
  801909:	84 c9                	test   %cl,%cl
  80190b:	75 ec                	jne    8018f9 <strlcpy+0x1a>
  80190d:	89 c2                	mov    %eax,%edx
  80190f:	eb 02                	jmp    801913 <strlcpy+0x34>
  801911:	89 c2                	mov    %eax,%edx
      *dst++ = *src++;
    *dst = '\0';
  801913:	c6 02 00             	movb   $0x0,(%edx)
  }
  return dst - dst_in;
  801916:	29 f0                	sub    %esi,%eax
}
  801918:	5b                   	pop    %ebx
  801919:	5e                   	pop    %esi
  80191a:	5d                   	pop    %ebp
  80191b:	c3                   	ret    

0080191c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801922:	8b 55 0c             	mov    0xc(%ebp),%edx
  while (*p && *p == *q)
  801925:	eb 06                	jmp    80192d <strcmp+0x11>
    p++, q++;
  801927:	83 c1 01             	add    $0x1,%ecx
  80192a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
  while (*p && *p == *q)
  80192d:	0f b6 01             	movzbl (%ecx),%eax
  801930:	84 c0                	test   %al,%al
  801932:	74 04                	je     801938 <strcmp+0x1c>
  801934:	3a 02                	cmp    (%edx),%al
  801936:	74 ef                	je     801927 <strcmp+0xb>
    p++, q++;
  return (int)((unsigned char)*p - (unsigned char)*q);
  801938:	0f b6 c0             	movzbl %al,%eax
  80193b:	0f b6 12             	movzbl (%edx),%edx
  80193e:	29 d0                	sub    %edx,%eax
}
  801940:	5d                   	pop    %ebp
  801941:	c3                   	ret    

00801942 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801942:	55                   	push   %ebp
  801943:	89 e5                	mov    %esp,%ebp
  801945:	53                   	push   %ebx
  801946:	8b 45 08             	mov    0x8(%ebp),%eax
  801949:	8b 55 0c             	mov    0xc(%ebp),%edx
  80194c:	89 c3                	mov    %eax,%ebx
  80194e:	03 5d 10             	add    0x10(%ebp),%ebx
  while (n > 0 && *p && *p == *q)
  801951:	eb 06                	jmp    801959 <strncmp+0x17>
    n--, p++, q++;
  801953:	83 c0 01             	add    $0x1,%eax
  801956:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
  801959:	39 d8                	cmp    %ebx,%eax
  80195b:	74 15                	je     801972 <strncmp+0x30>
  80195d:	0f b6 08             	movzbl (%eax),%ecx
  801960:	84 c9                	test   %cl,%cl
  801962:	74 04                	je     801968 <strncmp+0x26>
  801964:	3a 0a                	cmp    (%edx),%cl
  801966:	74 eb                	je     801953 <strncmp+0x11>
    n--, p++, q++;
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  801968:	0f b6 00             	movzbl (%eax),%eax
  80196b:	0f b6 12             	movzbl (%edx),%edx
  80196e:	29 d0                	sub    %edx,%eax
  801970:	eb 05                	jmp    801977 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
    n--, p++, q++;
  if (n == 0)
    return 0;
  801972:	b8 00 00 00 00       	mov    $0x0,%eax
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
}
  801977:	5b                   	pop    %ebx
  801978:	5d                   	pop    %ebp
  801979:	c3                   	ret    

0080197a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80197a:	55                   	push   %ebp
  80197b:	89 e5                	mov    %esp,%ebp
  80197d:	8b 45 08             	mov    0x8(%ebp),%eax
  801980:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
  801984:	eb 07                	jmp    80198d <strchr+0x13>
    if (*s == c)
  801986:	38 ca                	cmp    %cl,%dl
  801988:	74 0f                	je     801999 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  for (; *s; s++)
  80198a:	83 c0 01             	add    $0x1,%eax
  80198d:	0f b6 10             	movzbl (%eax),%edx
  801990:	84 d2                	test   %dl,%dl
  801992:	75 f2                	jne    801986 <strchr+0xc>
    if (*s == c)
      return (char*)s;
  return 0;
  801994:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801999:	5d                   	pop    %ebp
  80199a:	c3                   	ret    

0080199b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80199b:	55                   	push   %ebp
  80199c:	89 e5                	mov    %esp,%ebp
  80199e:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
  8019a5:	eb 07                	jmp    8019ae <strfind+0x13>
    if (*s == c)
  8019a7:	38 ca                	cmp    %cl,%dl
  8019a9:	74 0a                	je     8019b5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  for (; *s; s++)
  8019ab:	83 c0 01             	add    $0x1,%eax
  8019ae:	0f b6 10             	movzbl (%eax),%edx
  8019b1:	84 d2                	test   %dl,%dl
  8019b3:	75 f2                	jne    8019a7 <strfind+0xc>
    if (*s == c)
      break;
  return (char*)s;
}
  8019b5:	5d                   	pop    %ebp
  8019b6:	c3                   	ret    

008019b7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8019b7:	55                   	push   %ebp
  8019b8:	89 e5                	mov    %esp,%ebp
  8019ba:	57                   	push   %edi
  8019bb:	56                   	push   %esi
  8019bc:	53                   	push   %ebx
  8019bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *p;

  if (n == 0)
  8019c3:	85 c9                	test   %ecx,%ecx
  8019c5:	74 36                	je     8019fd <memset+0x46>
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
  8019c7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8019cd:	75 28                	jne    8019f7 <memset+0x40>
  8019cf:	f6 c1 03             	test   $0x3,%cl
  8019d2:	75 23                	jne    8019f7 <memset+0x40>
    c &= 0xFF;
  8019d4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
    c = (c<<24)|(c<<16)|(c<<8)|c;
  8019d8:	89 d3                	mov    %edx,%ebx
  8019da:	c1 e3 08             	shl    $0x8,%ebx
  8019dd:	89 d6                	mov    %edx,%esi
  8019df:	c1 e6 18             	shl    $0x18,%esi
  8019e2:	89 d0                	mov    %edx,%eax
  8019e4:	c1 e0 10             	shl    $0x10,%eax
  8019e7:	09 f0                	or     %esi,%eax
  8019e9:	09 c2                	or     %eax,%edx
  8019eb:	89 d0                	mov    %edx,%eax
  8019ed:	09 d8                	or     %ebx,%eax
    asm volatile ("cld; rep stosl\n"
                  :: "D" (v), "a" (c), "c" (n/4)
  8019ef:	c1 e9 02             	shr    $0x2,%ecx
  if (n == 0)
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
    c &= 0xFF;
    c = (c<<24)|(c<<16)|(c<<8)|c;
    asm volatile ("cld; rep stosl\n"
  8019f2:	fc                   	cld    
  8019f3:	f3 ab                	rep stos %eax,%es:(%edi)
  8019f5:	eb 06                	jmp    8019fd <memset+0x46>
                  :: "D" (v), "a" (c), "c" (n/4)
                  : "cc", "memory");
  } else
    asm volatile ("cld; rep stosb\n"
  8019f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019fa:	fc                   	cld    
  8019fb:	f3 aa                	rep stos %al,%es:(%edi)
                  :: "D" (v), "a" (c), "c" (n)
                  : "cc", "memory");
  return v;
}
  8019fd:	89 f8                	mov    %edi,%eax
  8019ff:	5b                   	pop    %ebx
  801a00:	5e                   	pop    %esi
  801a01:	5f                   	pop    %edi
  801a02:	5d                   	pop    %ebp
  801a03:	c3                   	ret    

00801a04 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801a04:	55                   	push   %ebp
  801a05:	89 e5                	mov    %esp,%ebp
  801a07:	57                   	push   %edi
  801a08:	56                   	push   %esi
  801a09:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  801a12:	39 c6                	cmp    %eax,%esi
  801a14:	73 35                	jae    801a4b <memmove+0x47>
  801a16:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801a19:	39 d0                	cmp    %edx,%eax
  801a1b:	73 2e                	jae    801a4b <memmove+0x47>
    s += n;
    d += n;
  801a1d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801a20:	89 d6                	mov    %edx,%esi
  801a22:	09 fe                	or     %edi,%esi
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a24:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801a2a:	75 13                	jne    801a3f <memmove+0x3b>
  801a2c:	f6 c1 03             	test   $0x3,%cl
  801a2f:	75 0e                	jne    801a3f <memmove+0x3b>
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801a31:	83 ef 04             	sub    $0x4,%edi
  801a34:	8d 72 fc             	lea    -0x4(%edx),%esi
  801a37:	c1 e9 02             	shr    $0x2,%ecx
  d = dst;
  if (s < d && s + n > d) {
    s += n;
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
  801a3a:	fd                   	std    
  801a3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a3d:	eb 09                	jmp    801a48 <memmove+0x44>
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801a3f:	83 ef 01             	sub    $0x1,%edi
  801a42:	8d 72 ff             	lea    -0x1(%edx),%esi
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
  801a45:	fd                   	std    
  801a46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  801a48:	fc                   	cld    
  801a49:	eb 1d                	jmp    801a68 <memmove+0x64>
  801a4b:	89 f2                	mov    %esi,%edx
  801a4d:	09 c2                	or     %eax,%edx
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a4f:	f6 c2 03             	test   $0x3,%dl
  801a52:	75 0f                	jne    801a63 <memmove+0x5f>
  801a54:	f6 c1 03             	test   $0x3,%cl
  801a57:	75 0a                	jne    801a63 <memmove+0x5f>
      asm volatile ("cld; rep movsl\n"
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801a59:	c1 e9 02             	shr    $0x2,%ecx
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("cld; rep movsl\n"
  801a5c:	89 c7                	mov    %eax,%edi
  801a5e:	fc                   	cld    
  801a5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a61:	eb 05                	jmp    801a68 <memmove+0x64>
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("cld; rep movsb\n"
  801a63:	89 c7                	mov    %eax,%edi
  801a65:	fc                   	cld    
  801a66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d), "S" (s), "c" (n) : "cc", "memory");
  }
  return dst;
}
  801a68:	5e                   	pop    %esi
  801a69:	5f                   	pop    %edi
  801a6a:	5d                   	pop    %ebp
  801a6b:	c3                   	ret    

00801a6c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
  801a72:	8b 45 10             	mov    0x10(%ebp),%eax
  801a75:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a79:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a80:	8b 45 08             	mov    0x8(%ebp),%eax
  801a83:	89 04 24             	mov    %eax,(%esp)
  801a86:	e8 79 ff ff ff       	call   801a04 <memmove>
}
  801a8b:	c9                   	leave  
  801a8c:	c3                   	ret    

00801a8d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801a8d:	55                   	push   %ebp
  801a8e:	89 e5                	mov    %esp,%ebp
  801a90:	56                   	push   %esi
  801a91:	53                   	push   %ebx
  801a92:	8b 55 08             	mov    0x8(%ebp),%edx
  801a95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a98:	89 d6                	mov    %edx,%esi
  801a9a:	03 75 10             	add    0x10(%ebp),%esi
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
  801a9d:	eb 1a                	jmp    801ab9 <memcmp+0x2c>
    if (*s1 != *s2)
  801a9f:	0f b6 02             	movzbl (%edx),%eax
  801aa2:	0f b6 19             	movzbl (%ecx),%ebx
  801aa5:	38 d8                	cmp    %bl,%al
  801aa7:	74 0a                	je     801ab3 <memcmp+0x26>
      return (int)*s1 - (int)*s2;
  801aa9:	0f b6 c0             	movzbl %al,%eax
  801aac:	0f b6 db             	movzbl %bl,%ebx
  801aaf:	29 d8                	sub    %ebx,%eax
  801ab1:	eb 0f                	jmp    801ac2 <memcmp+0x35>
    s1++, s2++;
  801ab3:	83 c2 01             	add    $0x1,%edx
  801ab6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
  801ab9:	39 f2                	cmp    %esi,%edx
  801abb:	75 e2                	jne    801a9f <memcmp+0x12>
    if (*s1 != *s2)
      return (int)*s1 - (int)*s2;
    s1++, s2++;
  }

  return 0;
  801abd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ac2:	5b                   	pop    %ebx
  801ac3:	5e                   	pop    %esi
  801ac4:	5d                   	pop    %ebp
  801ac5:	c3                   	ret    

00801ac6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  801acc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  const void *ends = (const char*)s + n;
  801acf:	89 c2                	mov    %eax,%edx
  801ad1:	03 55 10             	add    0x10(%ebp),%edx

  for (; s < ends; s++)
  801ad4:	eb 07                	jmp    801add <memfind+0x17>
    if (*(const unsigned char*)s == (unsigned char)c)
  801ad6:	38 08                	cmp    %cl,(%eax)
  801ad8:	74 07                	je     801ae1 <memfind+0x1b>
void *
memfind(const void *s, int c, size_t n)
{
  const void *ends = (const char*)s + n;

  for (; s < ends; s++)
  801ada:	83 c0 01             	add    $0x1,%eax
  801add:	39 d0                	cmp    %edx,%eax
  801adf:	72 f5                	jb     801ad6 <memfind+0x10>
    if (*(const unsigned char*)s == (unsigned char)c)
      break;
  return (void*)s;
}
  801ae1:	5d                   	pop    %ebp
  801ae2:	c3                   	ret    

00801ae3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801ae3:	55                   	push   %ebp
  801ae4:	89 e5                	mov    %esp,%ebp
  801ae6:	57                   	push   %edi
  801ae7:	56                   	push   %esi
  801ae8:	53                   	push   %ebx
  801ae9:	8b 55 08             	mov    0x8(%ebp),%edx
  801aec:	8b 45 10             	mov    0x10(%ebp),%eax
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  801aef:	eb 03                	jmp    801af4 <strtol+0x11>
    s++;
  801af1:	83 c2 01             	add    $0x1,%edx
{
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  801af4:	0f b6 0a             	movzbl (%edx),%ecx
  801af7:	80 f9 09             	cmp    $0x9,%cl
  801afa:	74 f5                	je     801af1 <strtol+0xe>
  801afc:	80 f9 20             	cmp    $0x20,%cl
  801aff:	74 f0                	je     801af1 <strtol+0xe>
    s++;

  // plus/minus sign
  if (*s == '+')
  801b01:	80 f9 2b             	cmp    $0x2b,%cl
  801b04:	75 0a                	jne    801b10 <strtol+0x2d>
    s++;
  801b06:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
  int neg = 0;
  801b09:	bf 00 00 00 00       	mov    $0x0,%edi
  801b0e:	eb 11                	jmp    801b21 <strtol+0x3e>
  801b10:	bf 00 00 00 00       	mov    $0x0,%edi
    s++;

  // plus/minus sign
  if (*s == '+')
    s++;
  else if (*s == '-')
  801b15:	80 f9 2d             	cmp    $0x2d,%cl
  801b18:	75 07                	jne    801b21 <strtol+0x3e>
    s++, neg = 1;
  801b1a:	8d 52 01             	lea    0x1(%edx),%edx
  801b1d:	66 bf 01 00          	mov    $0x1,%di

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801b21:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801b26:	75 15                	jne    801b3d <strtol+0x5a>
  801b28:	80 3a 30             	cmpb   $0x30,(%edx)
  801b2b:	75 10                	jne    801b3d <strtol+0x5a>
  801b2d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801b31:	75 0a                	jne    801b3d <strtol+0x5a>
    s += 2, base = 16;
  801b33:	83 c2 02             	add    $0x2,%edx
  801b36:	b8 10 00 00 00       	mov    $0x10,%eax
  801b3b:	eb 10                	jmp    801b4d <strtol+0x6a>
  else if (base == 0 && s[0] == '0')
  801b3d:	85 c0                	test   %eax,%eax
  801b3f:	75 0c                	jne    801b4d <strtol+0x6a>
    s++, base = 8;
  else if (base == 0)
    base = 10;
  801b41:	b0 0a                	mov    $0xa,%al
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
  801b43:	80 3a 30             	cmpb   $0x30,(%edx)
  801b46:	75 05                	jne    801b4d <strtol+0x6a>
    s++, base = 8;
  801b48:	83 c2 01             	add    $0x1,%edx
  801b4b:	b0 08                	mov    $0x8,%al
  else if (base == 0)
    base = 10;
  801b4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b52:	89 45 10             	mov    %eax,0x10(%ebp)

  // digits
  while (1) {
    int dig;

    if (*s >= '0' && *s <= '9')
  801b55:	0f b6 0a             	movzbl (%edx),%ecx
  801b58:	8d 71 d0             	lea    -0x30(%ecx),%esi
  801b5b:	89 f0                	mov    %esi,%eax
  801b5d:	3c 09                	cmp    $0x9,%al
  801b5f:	77 08                	ja     801b69 <strtol+0x86>
      dig = *s - '0';
  801b61:	0f be c9             	movsbl %cl,%ecx
  801b64:	83 e9 30             	sub    $0x30,%ecx
  801b67:	eb 20                	jmp    801b89 <strtol+0xa6>
    else if (*s >= 'a' && *s <= 'z')
  801b69:	8d 71 9f             	lea    -0x61(%ecx),%esi
  801b6c:	89 f0                	mov    %esi,%eax
  801b6e:	3c 19                	cmp    $0x19,%al
  801b70:	77 08                	ja     801b7a <strtol+0x97>
      dig = *s - 'a' + 10;
  801b72:	0f be c9             	movsbl %cl,%ecx
  801b75:	83 e9 57             	sub    $0x57,%ecx
  801b78:	eb 0f                	jmp    801b89 <strtol+0xa6>
    else if (*s >= 'A' && *s <= 'Z')
  801b7a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  801b7d:	89 f0                	mov    %esi,%eax
  801b7f:	3c 19                	cmp    $0x19,%al
  801b81:	77 16                	ja     801b99 <strtol+0xb6>
      dig = *s - 'A' + 10;
  801b83:	0f be c9             	movsbl %cl,%ecx
  801b86:	83 e9 37             	sub    $0x37,%ecx
    else
      break;
    if (dig >= base)
  801b89:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  801b8c:	7d 0f                	jge    801b9d <strtol+0xba>
      break;
    s++, val = (val * base) + dig;
  801b8e:	83 c2 01             	add    $0x1,%edx
  801b91:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801b95:	01 cb                	add    %ecx,%ebx
    // we don't properly detect overflow!
  }
  801b97:	eb bc                	jmp    801b55 <strtol+0x72>
  801b99:	89 d8                	mov    %ebx,%eax
  801b9b:	eb 02                	jmp    801b9f <strtol+0xbc>
  801b9d:	89 d8                	mov    %ebx,%eax

  if (endptr)
  801b9f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ba3:	74 05                	je     801baa <strtol+0xc7>
    *endptr = (char*)s;
  801ba5:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ba8:	89 16                	mov    %edx,(%esi)
  return neg ? -val : val;
  801baa:	f7 d8                	neg    %eax
  801bac:	85 ff                	test   %edi,%edi
  801bae:	0f 44 c3             	cmove  %ebx,%eax
}
  801bb1:	5b                   	pop    %ebx
  801bb2:	5e                   	pop    %esi
  801bb3:	5f                   	pop    %edi
  801bb4:	5d                   	pop    %ebp
  801bb5:	c3                   	ret    

00801bb6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bb6:	55                   	push   %ebp
  801bb7:	89 e5                	mov    %esp,%ebp
  801bb9:	56                   	push   %esi
  801bba:	53                   	push   %ebx
  801bbb:	83 ec 10             	sub    $0x10,%esp
  801bbe:	8b 75 08             	mov    0x8(%ebp),%esi
  801bc1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bc4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;
  801bc7:	85 c0                	test   %eax,%eax
  801bc9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801bce:	0f 44 c2             	cmove  %edx,%eax
  if ((r = sys_ipc_recv(pg)) < 0) {
  801bd1:	89 04 24             	mov    %eax,(%esp)
  801bd4:	e8 bb e7 ff ff       	call   800394 <sys_ipc_recv>
  801bd9:	85 c0                	test   %eax,%eax
  801bdb:	79 34                	jns    801c11 <ipc_recv+0x5b>
    if (from_env_store)
  801bdd:	85 f6                	test   %esi,%esi
  801bdf:	74 06                	je     801be7 <ipc_recv+0x31>
      *from_env_store = 0;
  801be1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (perm_store)
  801be7:	85 db                	test   %ebx,%ebx
  801be9:	74 06                	je     801bf1 <ipc_recv+0x3b>
      *perm_store = 0;
  801beb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    panic("sys_ipc_recv: %e", r);
  801bf1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bf5:	c7 44 24 08 e0 23 80 	movl   $0x8023e0,0x8(%esp)
  801bfc:	00 
  801bfd:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801c04:	00 
  801c05:	c7 04 24 f1 23 80 00 	movl   $0x8023f1,(%esp)
  801c0c:	e8 35 f5 ff ff       	call   801146 <_panic>
  }

  if (from_env_store)
  801c11:	85 f6                	test   %esi,%esi
  801c13:	74 0a                	je     801c1f <ipc_recv+0x69>
    *from_env_store = thisenv->env_ipc_from;
  801c15:	a1 04 40 80 00       	mov    0x804004,%eax
  801c1a:	8b 40 74             	mov    0x74(%eax),%eax
  801c1d:	89 06                	mov    %eax,(%esi)
  if (perm_store)
  801c1f:	85 db                	test   %ebx,%ebx
  801c21:	74 0a                	je     801c2d <ipc_recv+0x77>
    *perm_store |= thisenv->env_ipc_perm;
  801c23:	a1 04 40 80 00       	mov    0x804004,%eax
  801c28:	8b 40 78             	mov    0x78(%eax),%eax
  801c2b:	09 03                	or     %eax,(%ebx)

  return thisenv->env_ipc_value;
  801c2d:	a1 04 40 80 00       	mov    0x804004,%eax
  801c32:	8b 40 70             	mov    0x70(%eax),%eax

}
  801c35:	83 c4 10             	add    $0x10,%esp
  801c38:	5b                   	pop    %ebx
  801c39:	5e                   	pop    %esi
  801c3a:	5d                   	pop    %ebp
  801c3b:	c3                   	ret    

00801c3c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c3c:	55                   	push   %ebp
  801c3d:	89 e5                	mov    %esp,%ebp
  801c3f:	57                   	push   %edi
  801c40:	56                   	push   %esi
  801c41:	53                   	push   %ebx
  801c42:	83 ec 1c             	sub    $0x1c,%esp
  801c45:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c48:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;
  801c4e:	85 db                	test   %ebx,%ebx
  801c50:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801c55:	0f 44 d8             	cmove  %eax,%ebx

  while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801c58:	eb 2a                	jmp    801c84 <ipc_send+0x48>
    if (r != -E_IPC_NOT_RECV)
  801c5a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c5d:	74 20                	je     801c7f <ipc_send+0x43>
      panic("ipc_send: %e", r);
  801c5f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c63:	c7 44 24 08 fb 23 80 	movl   $0x8023fb,0x8(%esp)
  801c6a:	00 
  801c6b:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801c72:	00 
  801c73:	c7 04 24 f1 23 80 00 	movl   $0x8023f1,(%esp)
  801c7a:	e8 c7 f4 ff ff       	call   801146 <_panic>
    sys_yield();
  801c7f:	e8 db e4 ff ff       	call   80015f <sys_yield>
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;

  while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801c84:	8b 45 14             	mov    0x14(%ebp),%eax
  801c87:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c8b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c8f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c93:	89 3c 24             	mov    %edi,(%esp)
  801c96:	e8 d6 e6 ff ff       	call   800371 <sys_ipc_try_send>
  801c9b:	85 c0                	test   %eax,%eax
  801c9d:	78 bb                	js     801c5a <ipc_send+0x1e>
    if (r != -E_IPC_NOT_RECV)
      panic("ipc_send: %e", r);
    sys_yield();
  }
}
  801c9f:	83 c4 1c             	add    $0x1c,%esp
  801ca2:	5b                   	pop    %ebx
  801ca3:	5e                   	pop    %esi
  801ca4:	5f                   	pop    %edi
  801ca5:	5d                   	pop    %ebp
  801ca6:	c3                   	ret    

00801ca7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ca7:	55                   	push   %ebp
  801ca8:	89 e5                	mov    %esp,%ebp
  801caa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int i;

  for (i = 0; i < NENV; i++)
  801cad:	b8 00 00 00 00       	mov    $0x0,%eax
    if (envs[i].env_type == type)
  801cb2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801cb5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cbb:	8b 52 50             	mov    0x50(%edx),%edx
  801cbe:	39 ca                	cmp    %ecx,%edx
  801cc0:	75 0d                	jne    801ccf <ipc_find_env+0x28>
      return envs[i].env_id;
  801cc2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801cc5:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801cca:	8b 40 40             	mov    0x40(%eax),%eax
  801ccd:	eb 0e                	jmp    801cdd <ipc_find_env+0x36>
envid_t
ipc_find_env(enum EnvType type)
{
  int i;

  for (i = 0; i < NENV; i++)
  801ccf:	83 c0 01             	add    $0x1,%eax
  801cd2:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cd7:	75 d9                	jne    801cb2 <ipc_find_env+0xb>
    if (envs[i].env_type == type)
      return envs[i].env_id;
  return 0;
  801cd9:	66 b8 00 00          	mov    $0x0,%ax
}
  801cdd:	5d                   	pop    %ebp
  801cde:	c3                   	ret    

00801cdf <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cdf:	55                   	push   %ebp
  801ce0:	89 e5                	mov    %esp,%ebp
  801ce2:	8b 55 08             	mov    0x8(%ebp),%edx
  pte_t pte;

  if (!(uvpd[PDX(v)] & PTE_P))
  801ce5:	89 d0                	mov    %edx,%eax
  801ce7:	c1 e8 16             	shr    $0x16,%eax
  801cea:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
    return 0;
  801cf1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
  pte_t pte;

  if (!(uvpd[PDX(v)] & PTE_P))
  801cf6:	f6 c1 01             	test   $0x1,%cl
  801cf9:	74 1d                	je     801d18 <pageref+0x39>
    return 0;
  pte = uvpt[PGNUM(v)];
  801cfb:	c1 ea 0c             	shr    $0xc,%edx
  801cfe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  if (!(pte & PTE_P))
  801d05:	f6 c2 01             	test   $0x1,%dl
  801d08:	74 0e                	je     801d18 <pageref+0x39>
    return 0;
  return pages[PGNUM(pte)].pp_ref;
  801d0a:	c1 ea 0c             	shr    $0xc,%edx
  801d0d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d14:	ef 
  801d15:	0f b7 c0             	movzwl %ax,%eax
}
  801d18:	5d                   	pop    %ebp
  801d19:	c3                   	ret    
  801d1a:	66 90                	xchg   %ax,%ax
  801d1c:	66 90                	xchg   %ax,%ax
  801d1e:	66 90                	xchg   %ax,%ax

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
