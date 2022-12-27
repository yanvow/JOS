
obj/user/faultwrite.debug:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  *(unsigned*)0 = 0;
  800036:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	83 ec 10             	sub    $0x10,%esp
  80004a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004d:	8b 75 0c             	mov    0xc(%ebp),%esi
  // set thisenv to point at our Env structure in envs[].
  // LAB 3: Your code here.
  thisenv = envs + ENVX(sys_getenvid());
  800050:	e8 dd 00 00 00       	call   800132 <sys_getenvid>
  800055:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800062:	a3 04 40 80 00       	mov    %eax,0x804004

  // save the name of the program so that panic() can use it
  if (argc > 0)
  800067:	85 db                	test   %ebx,%ebx
  800069:	7e 07                	jle    800072 <libmain+0x30>
    binaryname = argv[0];
  80006b:	8b 06                	mov    (%esi),%eax
  80006d:	a3 00 30 80 00       	mov    %eax,0x803000

  // call user main routine
  umain(argc, argv);
  800072:	89 74 24 04          	mov    %esi,0x4(%esp)
  800076:	89 1c 24             	mov    %ebx,(%esp)
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

  // exit gracefully
  exit();
  80007e:	e8 07 00 00 00       	call   80008a <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	5b                   	pop    %ebx
  800087:	5e                   	pop    %esi
  800088:	5d                   	pop    %ebp
  800089:	c3                   	ret    

0080008a <exit>:
#include <inc/lib.h>

void
exit(void)
{
  80008a:	55                   	push   %ebp
  80008b:	89 e5                	mov    %esp,%ebp
  80008d:	83 ec 18             	sub    $0x18,%esp
  close_all();
  800090:	e8 20 05 00 00       	call   8005b5 <close_all>
  sys_env_destroy(0);
  800095:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80009c:	e8 3f 00 00 00       	call   8000e0 <sys_env_destroy>
}
  8000a1:	c9                   	leave  
  8000a2:	c3                   	ret    

008000a3 <sys_cputs>:
  return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a3:	55                   	push   %ebp
  8000a4:	89 e5                	mov    %esp,%ebp
  8000a6:	57                   	push   %edi
  8000a7:	56                   	push   %esi
  8000a8:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8000a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b4:	89 c3                	mov    %eax,%ebx
  8000b6:	89 c7                	mov    %eax,%edi
  8000b8:	89 c6                	mov    %eax,%esi
  8000ba:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
  syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bc:	5b                   	pop    %ebx
  8000bd:	5e                   	pop    %esi
  8000be:	5f                   	pop    %edi
  8000bf:	5d                   	pop    %ebp
  8000c0:	c3                   	ret    

008000c1 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	57                   	push   %edi
  8000c5:	56                   	push   %esi
  8000c6:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8000c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d1:	89 d1                	mov    %edx,%ecx
  8000d3:	89 d3                	mov    %edx,%ebx
  8000d5:	89 d7                	mov    %edx,%edi
  8000d7:	89 d6                	mov    %edx,%esi
  8000d9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000db:	5b                   	pop    %ebx
  8000dc:	5e                   	pop    %esi
  8000dd:	5f                   	pop    %edi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	57                   	push   %edi
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
  8000e6:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8000e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ee:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f6:	89 cb                	mov    %ecx,%ebx
  8000f8:	89 cf                	mov    %ecx,%edi
  8000fa:	89 ce                	mov    %ecx,%esi
  8000fc:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  8000fe:	85 c0                	test   %eax,%eax
  800100:	7e 28                	jle    80012a <sys_env_destroy+0x4a>
    panic("syscall %d returned %d (> 0)", num, ret);
  800102:	89 44 24 10          	mov    %eax,0x10(%esp)
  800106:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80010d:	00 
  80010e:	c7 44 24 08 aa 1f 80 	movl   $0x801faa,0x8(%esp)
  800115:	00 
  800116:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80011d:	00 
  80011e:	c7 04 24 c7 1f 80 00 	movl   $0x801fc7,(%esp)
  800125:	e8 0c 10 00 00       	call   801136 <_panic>

int
sys_env_destroy(envid_t envid)
{
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012a:	83 c4 2c             	add    $0x2c,%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	57                   	push   %edi
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800138:	ba 00 00 00 00       	mov    $0x0,%edx
  80013d:	b8 02 00 00 00       	mov    $0x2,%eax
  800142:	89 d1                	mov    %edx,%ecx
  800144:	89 d3                	mov    %edx,%ebx
  800146:	89 d7                	mov    %edx,%edi
  800148:	89 d6                	mov    %edx,%esi
  80014a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014c:	5b                   	pop    %ebx
  80014d:	5e                   	pop    %esi
  80014e:	5f                   	pop    %edi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <sys_yield>:

void
sys_yield(void)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	57                   	push   %edi
  800155:	56                   	push   %esi
  800156:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800157:	ba 00 00 00 00       	mov    $0x0,%edx
  80015c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800161:	89 d1                	mov    %edx,%ecx
  800163:	89 d3                	mov    %edx,%ebx
  800165:	89 d7                	mov    %edx,%edi
  800167:	89 d6                	mov    %edx,%esi
  800169:	cd 30                	int    $0x30

void
sys_yield(void)
{
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016b:	5b                   	pop    %ebx
  80016c:	5e                   	pop    %esi
  80016d:	5f                   	pop    %edi
  80016e:	5d                   	pop    %ebp
  80016f:	c3                   	ret    

00800170 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800179:	be 00 00 00 00       	mov    $0x0,%esi
  80017e:	b8 04 00 00 00       	mov    $0x4,%eax
  800183:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800186:	8b 55 08             	mov    0x8(%ebp),%edx
  800189:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018c:	89 f7                	mov    %esi,%edi
  80018e:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800190:	85 c0                	test   %eax,%eax
  800192:	7e 28                	jle    8001bc <sys_page_alloc+0x4c>
    panic("syscall %d returned %d (> 0)", num, ret);
  800194:	89 44 24 10          	mov    %eax,0x10(%esp)
  800198:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80019f:	00 
  8001a0:	c7 44 24 08 aa 1f 80 	movl   $0x801faa,0x8(%esp)
  8001a7:	00 
  8001a8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001af:	00 
  8001b0:	c7 04 24 c7 1f 80 00 	movl   $0x801fc7,(%esp)
  8001b7:	e8 7a 0f 00 00       	call   801136 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  return syscall(SYS_page_alloc, 1, envid, (uint32_t)va, perm, 0, 0);
}
  8001bc:	83 c4 2c             	add    $0x2c,%esp
  8001bf:	5b                   	pop    %ebx
  8001c0:	5e                   	pop    %esi
  8001c1:	5f                   	pop    %edi
  8001c2:	5d                   	pop    %ebp
  8001c3:	c3                   	ret    

008001c4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8001cd:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001db:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001de:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e1:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  8001e3:	85 c0                	test   %eax,%eax
  8001e5:	7e 28                	jle    80020f <sys_page_map+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  8001e7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001eb:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001f2:	00 
  8001f3:	c7 44 24 08 aa 1f 80 	movl   $0x801faa,0x8(%esp)
  8001fa:	00 
  8001fb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800202:	00 
  800203:	c7 04 24 c7 1f 80 00 	movl   $0x801fc7,(%esp)
  80020a:	e8 27 0f 00 00       	call   801136 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  return syscall(SYS_page_map, 1, srcenv, (uint32_t)srcva, dstenv, (uint32_t)dstva, perm);
}
  80020f:	83 c4 2c             	add    $0x2c,%esp
  800212:	5b                   	pop    %ebx
  800213:	5e                   	pop    %esi
  800214:	5f                   	pop    %edi
  800215:	5d                   	pop    %ebp
  800216:	c3                   	ret    

00800217 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	57                   	push   %edi
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
  80021d:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800220:	bb 00 00 00 00       	mov    $0x0,%ebx
  800225:	b8 06 00 00 00       	mov    $0x6,%eax
  80022a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022d:	8b 55 08             	mov    0x8(%ebp),%edx
  800230:	89 df                	mov    %ebx,%edi
  800232:	89 de                	mov    %ebx,%esi
  800234:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800236:	85 c0                	test   %eax,%eax
  800238:	7e 28                	jle    800262 <sys_page_unmap+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  80023a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80023e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800245:	00 
  800246:	c7 44 24 08 aa 1f 80 	movl   $0x801faa,0x8(%esp)
  80024d:	00 
  80024e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800255:	00 
  800256:	c7 04 24 c7 1f 80 00 	movl   $0x801fc7,(%esp)
  80025d:	e8 d4 0e 00 00       	call   801136 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
  return syscall(SYS_page_unmap, 1, envid, (uint32_t)va, 0, 0, 0);
}
  800262:	83 c4 2c             	add    $0x2c,%esp
  800265:	5b                   	pop    %ebx
  800266:	5e                   	pop    %esi
  800267:	5f                   	pop    %edi
  800268:	5d                   	pop    %ebp
  800269:	c3                   	ret    

0080026a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80026a:	55                   	push   %ebp
  80026b:	89 e5                	mov    %esp,%ebp
  80026d:	57                   	push   %edi
  80026e:	56                   	push   %esi
  80026f:	53                   	push   %ebx
  800270:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800273:	bb 00 00 00 00       	mov    $0x0,%ebx
  800278:	b8 08 00 00 00       	mov    $0x8,%eax
  80027d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800280:	8b 55 08             	mov    0x8(%ebp),%edx
  800283:	89 df                	mov    %ebx,%edi
  800285:	89 de                	mov    %ebx,%esi
  800287:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800289:	85 c0                	test   %eax,%eax
  80028b:	7e 28                	jle    8002b5 <sys_env_set_status+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  80028d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800291:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800298:	00 
  800299:	c7 44 24 08 aa 1f 80 	movl   $0x801faa,0x8(%esp)
  8002a0:	00 
  8002a1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002a8:	00 
  8002a9:	c7 04 24 c7 1f 80 00 	movl   $0x801fc7,(%esp)
  8002b0:	e8 81 0e 00 00       	call   801136 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002b5:	83 c4 2c             	add    $0x2c,%esp
  8002b8:	5b                   	pop    %ebx
  8002b9:	5e                   	pop    %esi
  8002ba:	5f                   	pop    %edi
  8002bb:	5d                   	pop    %ebp
  8002bc:	c3                   	ret    

008002bd <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	57                   	push   %edi
  8002c1:	56                   	push   %esi
  8002c2:	53                   	push   %ebx
  8002c3:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8002c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002cb:	b8 09 00 00 00       	mov    $0x9,%eax
  8002d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d6:	89 df                	mov    %ebx,%edi
  8002d8:	89 de                	mov    %ebx,%esi
  8002da:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	7e 28                	jle    800308 <sys_env_set_trapframe+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  8002e0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002e4:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002eb:	00 
  8002ec:	c7 44 24 08 aa 1f 80 	movl   $0x801faa,0x8(%esp)
  8002f3:	00 
  8002f4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002fb:	00 
  8002fc:	c7 04 24 c7 1f 80 00 	movl   $0x801fc7,(%esp)
  800303:	e8 2e 0e 00 00       	call   801136 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t)tf, 0, 0, 0);
}
  800308:	83 c4 2c             	add    $0x2c,%esp
  80030b:	5b                   	pop    %ebx
  80030c:	5e                   	pop    %esi
  80030d:	5f                   	pop    %edi
  80030e:	5d                   	pop    %ebp
  80030f:	c3                   	ret    

00800310 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	57                   	push   %edi
  800314:	56                   	push   %esi
  800315:	53                   	push   %ebx
  800316:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800319:	bb 00 00 00 00       	mov    $0x0,%ebx
  80031e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800323:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800326:	8b 55 08             	mov    0x8(%ebp),%edx
  800329:	89 df                	mov    %ebx,%edi
  80032b:	89 de                	mov    %ebx,%esi
  80032d:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  80032f:	85 c0                	test   %eax,%eax
  800331:	7e 28                	jle    80035b <sys_env_set_pgfault_upcall+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800333:	89 44 24 10          	mov    %eax,0x10(%esp)
  800337:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80033e:	00 
  80033f:	c7 44 24 08 aa 1f 80 	movl   $0x801faa,0x8(%esp)
  800346:	00 
  800347:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80034e:	00 
  80034f:	c7 04 24 c7 1f 80 00 	movl   $0x801fc7,(%esp)
  800356:	e8 db 0d 00 00       	call   801136 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  80035b:	83 c4 2c             	add    $0x2c,%esp
  80035e:	5b                   	pop    %ebx
  80035f:	5e                   	pop    %esi
  800360:	5f                   	pop    %edi
  800361:	5d                   	pop    %ebp
  800362:	c3                   	ret    

00800363 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800363:	55                   	push   %ebp
  800364:	89 e5                	mov    %esp,%ebp
  800366:	57                   	push   %edi
  800367:	56                   	push   %esi
  800368:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800369:	be 00 00 00 00       	mov    $0x0,%esi
  80036e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800373:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800376:	8b 55 08             	mov    0x8(%ebp),%edx
  800379:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80037c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80037f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t)srcva, perm, 0);
}
  800381:	5b                   	pop    %ebx
  800382:	5e                   	pop    %esi
  800383:	5f                   	pop    %edi
  800384:	5d                   	pop    %ebp
  800385:	c3                   	ret    

00800386 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
  800389:	57                   	push   %edi
  80038a:	56                   	push   %esi
  80038b:	53                   	push   %ebx
  80038c:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  80038f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800394:	b8 0d 00 00 00       	mov    $0xd,%eax
  800399:	8b 55 08             	mov    0x8(%ebp),%edx
  80039c:	89 cb                	mov    %ecx,%ebx
  80039e:	89 cf                	mov    %ecx,%edi
  8003a0:	89 ce                	mov    %ecx,%esi
  8003a2:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  8003a4:	85 c0                	test   %eax,%eax
  8003a6:	7e 28                	jle    8003d0 <sys_ipc_recv+0x4a>
    panic("syscall %d returned %d (> 0)", num, ret);
  8003a8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003ac:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003b3:	00 
  8003b4:	c7 44 24 08 aa 1f 80 	movl   $0x801faa,0x8(%esp)
  8003bb:	00 
  8003bc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003c3:	00 
  8003c4:	c7 04 24 c7 1f 80 00 	movl   $0x801fc7,(%esp)
  8003cb:	e8 66 0d 00 00       	call   801136 <_panic>

int
sys_ipc_recv(void *dstva)
{
  return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003d0:	83 c4 2c             	add    $0x2c,%esp
  8003d3:	5b                   	pop    %ebx
  8003d4:	5e                   	pop    %esi
  8003d5:	5f                   	pop    %edi
  8003d6:	5d                   	pop    %ebp
  8003d7:	c3                   	ret    
  8003d8:	66 90                	xchg   %ax,%ax
  8003da:	66 90                	xchg   %ax,%ax
  8003dc:	66 90                	xchg   %ax,%ax
  8003de:	66 90                	xchg   %ax,%ax

008003e0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  8003e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e6:	05 00 00 00 30       	add    $0x30000000,%eax
  8003eb:	c1 e8 0c             	shr    $0xc,%eax
}
  8003ee:	5d                   	pop    %ebp
  8003ef:	c3                   	ret    

008003f0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  8003f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f6:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
  return INDEX2DATA(fd2num(fd));
  8003fb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800400:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800405:	5d                   	pop    %ebp
  800406:	c3                   	ret    

00800407 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800407:	55                   	push   %ebp
  800408:	89 e5                	mov    %esp,%ebp
  80040a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80040d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
  int i;
  struct Fd *fd;

  for (i = 0; i < MAXFD; i++) {
    fd = INDEX2FD(i);
    if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800412:	89 c2                	mov    %eax,%edx
  800414:	c1 ea 16             	shr    $0x16,%edx
  800417:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80041e:	f6 c2 01             	test   $0x1,%dl
  800421:	74 11                	je     800434 <fd_alloc+0x2d>
  800423:	89 c2                	mov    %eax,%edx
  800425:	c1 ea 0c             	shr    $0xc,%edx
  800428:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80042f:	f6 c2 01             	test   $0x1,%dl
  800432:	75 09                	jne    80043d <fd_alloc+0x36>
      *fd_store = fd;
  800434:	89 01                	mov    %eax,(%ecx)
      return 0;
  800436:	b8 00 00 00 00       	mov    $0x0,%eax
  80043b:	eb 17                	jmp    800454 <fd_alloc+0x4d>
  80043d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
  int i;
  struct Fd *fd;

  for (i = 0; i < MAXFD; i++) {
  800442:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800447:	75 c9                	jne    800412 <fd_alloc+0xb>
    if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
      *fd_store = fd;
      return 0;
    }
  }
  *fd_store = 0;
  800449:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
  return -E_MAX_OPEN;
  80044f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800454:	5d                   	pop    %ebp
  800455:	c3                   	ret    

00800456 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800456:	55                   	push   %ebp
  800457:	89 e5                	mov    %esp,%ebp
  800459:	8b 45 08             	mov    0x8(%ebp),%eax
  struct Fd *fd;

  if (fdnum < 0 || fdnum >= MAXFD) {
  80045c:	83 f8 1f             	cmp    $0x1f,%eax
  80045f:	77 36                	ja     800497 <fd_lookup+0x41>
    if (debug)
      cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  fd = INDEX2FD(fdnum);
  800461:	c1 e0 0c             	shl    $0xc,%eax
  800464:	2d 00 00 00 30       	sub    $0x30000000,%eax
  if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800469:	89 c2                	mov    %eax,%edx
  80046b:	c1 ea 16             	shr    $0x16,%edx
  80046e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800475:	f6 c2 01             	test   $0x1,%dl
  800478:	74 24                	je     80049e <fd_lookup+0x48>
  80047a:	89 c2                	mov    %eax,%edx
  80047c:	c1 ea 0c             	shr    $0xc,%edx
  80047f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800486:	f6 c2 01             	test   $0x1,%dl
  800489:	74 1a                	je     8004a5 <fd_lookup+0x4f>
    if (debug)
      cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  *fd_store = fd;
  80048b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80048e:	89 02                	mov    %eax,(%edx)
  return 0;
  800490:	b8 00 00 00 00       	mov    $0x0,%eax
  800495:	eb 13                	jmp    8004aa <fd_lookup+0x54>
  struct Fd *fd;

  if (fdnum < 0 || fdnum >= MAXFD) {
    if (debug)
      cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  800497:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80049c:	eb 0c                	jmp    8004aa <fd_lookup+0x54>
  }
  fd = INDEX2FD(fdnum);
  if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
    if (debug)
      cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  80049e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004a3:	eb 05                	jmp    8004aa <fd_lookup+0x54>
  8004a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  }
  *fd_store = fd;
  return 0;
}
  8004aa:	5d                   	pop    %ebp
  8004ab:	c3                   	ret    

008004ac <dev_lookup>:
  0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004ac:	55                   	push   %ebp
  8004ad:	89 e5                	mov    %esp,%ebp
  8004af:	83 ec 18             	sub    $0x18,%esp
  8004b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004b5:	ba 54 20 80 00       	mov    $0x802054,%edx
  int i;

  for (i = 0; devtab[i]; i++)
  8004ba:	eb 13                	jmp    8004cf <dev_lookup+0x23>
  8004bc:	83 c2 04             	add    $0x4,%edx
    if (devtab[i]->dev_id == dev_id) {
  8004bf:	39 08                	cmp    %ecx,(%eax)
  8004c1:	75 0c                	jne    8004cf <dev_lookup+0x23>
      *dev = devtab[i];
  8004c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004c6:	89 01                	mov    %eax,(%ecx)
      return 0;
  8004c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cd:	eb 30                	jmp    8004ff <dev_lookup+0x53>
int
dev_lookup(int dev_id, struct Dev **dev)
{
  int i;

  for (i = 0; devtab[i]; i++)
  8004cf:	8b 02                	mov    (%edx),%eax
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	75 e7                	jne    8004bc <dev_lookup+0x10>
    if (devtab[i]->dev_id == dev_id) {
      *dev = devtab[i];
      return 0;
    }
  cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004d5:	a1 04 40 80 00       	mov    0x804004,%eax
  8004da:	8b 40 48             	mov    0x48(%eax),%eax
  8004dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8004e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004e5:	c7 04 24 d8 1f 80 00 	movl   $0x801fd8,(%esp)
  8004ec:	e8 3e 0d 00 00       	call   80122f <cprintf>
  *dev = 0;
  8004f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  return -E_INVAL;
  8004fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004ff:	c9                   	leave  
  800500:	c3                   	ret    

00800501 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800501:	55                   	push   %ebp
  800502:	89 e5                	mov    %esp,%ebp
  800504:	56                   	push   %esi
  800505:	53                   	push   %ebx
  800506:	83 ec 20             	sub    $0x20,%esp
  800509:	8b 75 08             	mov    0x8(%ebp),%esi
  80050c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct Fd *fd2;
  struct Dev *dev;
  int r;

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80050f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800512:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  800516:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80051c:	c1 e8 0c             	shr    $0xc,%eax
{
  struct Fd *fd2;
  struct Dev *dev;
  int r;

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80051f:	89 04 24             	mov    %eax,(%esp)
  800522:	e8 2f ff ff ff       	call   800456 <fd_lookup>
  800527:	85 c0                	test   %eax,%eax
  800529:	78 05                	js     800530 <fd_close+0x2f>
      || fd != fd2)
  80052b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80052e:	74 0c                	je     80053c <fd_close+0x3b>
    return must_exist ? r : 0;
  800530:	84 db                	test   %bl,%bl
  800532:	ba 00 00 00 00       	mov    $0x0,%edx
  800537:	0f 44 c2             	cmove  %edx,%eax
  80053a:	eb 3f                	jmp    80057b <fd_close+0x7a>
  if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80053c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80053f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800543:	8b 06                	mov    (%esi),%eax
  800545:	89 04 24             	mov    %eax,(%esp)
  800548:	e8 5f ff ff ff       	call   8004ac <dev_lookup>
  80054d:	89 c3                	mov    %eax,%ebx
  80054f:	85 c0                	test   %eax,%eax
  800551:	78 16                	js     800569 <fd_close+0x68>
    if (dev->dev_close)
  800553:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800556:	8b 40 10             	mov    0x10(%eax),%eax
      r = (*dev->dev_close)(fd);
    else
      r = 0;
  800559:	bb 00 00 00 00       	mov    $0x0,%ebx

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
      || fd != fd2)
    return must_exist ? r : 0;
  if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
    if (dev->dev_close)
  80055e:	85 c0                	test   %eax,%eax
  800560:	74 07                	je     800569 <fd_close+0x68>
      r = (*dev->dev_close)(fd);
  800562:	89 34 24             	mov    %esi,(%esp)
  800565:	ff d0                	call   *%eax
  800567:	89 c3                	mov    %eax,%ebx
    else
      r = 0;
  }
  // Make sure fd is unmapped.  Might be a no-op if
  // (*dev->dev_close)(fd) already unmapped it.
  (void)sys_page_unmap(0, fd);
  800569:	89 74 24 04          	mov    %esi,0x4(%esp)
  80056d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800574:	e8 9e fc ff ff       	call   800217 <sys_page_unmap>
  return r;
  800579:	89 d8                	mov    %ebx,%eax
}
  80057b:	83 c4 20             	add    $0x20,%esp
  80057e:	5b                   	pop    %ebx
  80057f:	5e                   	pop    %esi
  800580:	5d                   	pop    %ebp
  800581:	c3                   	ret    

00800582 <close>:
  return -E_INVAL;
}

int
close(int fdnum)
{
  800582:	55                   	push   %ebp
  800583:	89 e5                	mov    %esp,%ebp
  800585:	83 ec 28             	sub    $0x28,%esp
  struct Fd *fd;
  int r;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  800588:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80058b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80058f:	8b 45 08             	mov    0x8(%ebp),%eax
  800592:	89 04 24             	mov    %eax,(%esp)
  800595:	e8 bc fe ff ff       	call   800456 <fd_lookup>
  80059a:	89 c2                	mov    %eax,%edx
  80059c:	85 d2                	test   %edx,%edx
  80059e:	78 13                	js     8005b3 <close+0x31>
    return r;
  else
    return fd_close(fd, 1);
  8005a0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8005a7:	00 
  8005a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005ab:	89 04 24             	mov    %eax,(%esp)
  8005ae:	e8 4e ff ff ff       	call   800501 <fd_close>
}
  8005b3:	c9                   	leave  
  8005b4:	c3                   	ret    

008005b5 <close_all>:

void
close_all(void)
{
  8005b5:	55                   	push   %ebp
  8005b6:	89 e5                	mov    %esp,%ebp
  8005b8:	53                   	push   %ebx
  8005b9:	83 ec 14             	sub    $0x14,%esp
  int i;

  for (i = 0; i < MAXFD; i++)
  8005bc:	bb 00 00 00 00       	mov    $0x0,%ebx
    close(i);
  8005c1:	89 1c 24             	mov    %ebx,(%esp)
  8005c4:	e8 b9 ff ff ff       	call   800582 <close>
void
close_all(void)
{
  int i;

  for (i = 0; i < MAXFD; i++)
  8005c9:	83 c3 01             	add    $0x1,%ebx
  8005cc:	83 fb 20             	cmp    $0x20,%ebx
  8005cf:	75 f0                	jne    8005c1 <close_all+0xc>
    close(i);
}
  8005d1:	83 c4 14             	add    $0x14,%esp
  8005d4:	5b                   	pop    %ebx
  8005d5:	5d                   	pop    %ebp
  8005d6:	c3                   	ret    

008005d7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005d7:	55                   	push   %ebp
  8005d8:	89 e5                	mov    %esp,%ebp
  8005da:	57                   	push   %edi
  8005db:	56                   	push   %esi
  8005dc:	53                   	push   %ebx
  8005dd:	83 ec 3c             	sub    $0x3c,%esp
  int r;
  char *ova, *nva;
  pte_t pte;
  struct Fd *oldfd, *newfd;

  if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005e0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ea:	89 04 24             	mov    %eax,(%esp)
  8005ed:	e8 64 fe ff ff       	call   800456 <fd_lookup>
  8005f2:	89 c2                	mov    %eax,%edx
  8005f4:	85 d2                	test   %edx,%edx
  8005f6:	0f 88 e1 00 00 00    	js     8006dd <dup+0x106>
    return r;
  close(newfdnum);
  8005fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ff:	89 04 24             	mov    %eax,(%esp)
  800602:	e8 7b ff ff ff       	call   800582 <close>

  newfd = INDEX2FD(newfdnum);
  800607:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80060a:	c1 e3 0c             	shl    $0xc,%ebx
  80060d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
  ova = fd2data(oldfd);
  800613:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800616:	89 04 24             	mov    %eax,(%esp)
  800619:	e8 d2 fd ff ff       	call   8003f0 <fd2data>
  80061e:	89 c6                	mov    %eax,%esi
  nva = fd2data(newfd);
  800620:	89 1c 24             	mov    %ebx,(%esp)
  800623:	e8 c8 fd ff ff       	call   8003f0 <fd2data>
  800628:	89 c7                	mov    %eax,%edi

  if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80062a:	89 f0                	mov    %esi,%eax
  80062c:	c1 e8 16             	shr    $0x16,%eax
  80062f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800636:	a8 01                	test   $0x1,%al
  800638:	74 43                	je     80067d <dup+0xa6>
  80063a:	89 f0                	mov    %esi,%eax
  80063c:	c1 e8 0c             	shr    $0xc,%eax
  80063f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800646:	f6 c2 01             	test   $0x1,%dl
  800649:	74 32                	je     80067d <dup+0xa6>
    if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80064b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800652:	25 07 0e 00 00       	and    $0xe07,%eax
  800657:	89 44 24 10          	mov    %eax,0x10(%esp)
  80065b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80065f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800666:	00 
  800667:	89 74 24 04          	mov    %esi,0x4(%esp)
  80066b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800672:	e8 4d fb ff ff       	call   8001c4 <sys_page_map>
  800677:	89 c6                	mov    %eax,%esi
  800679:	85 c0                	test   %eax,%eax
  80067b:	78 3e                	js     8006bb <dup+0xe4>
      goto err;
  if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80067d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800680:	89 c2                	mov    %eax,%edx
  800682:	c1 ea 0c             	shr    $0xc,%edx
  800685:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80068c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800692:	89 54 24 10          	mov    %edx,0x10(%esp)
  800696:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80069a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006a1:	00 
  8006a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006ad:	e8 12 fb ff ff       	call   8001c4 <sys_page_map>
  8006b2:	89 c6                	mov    %eax,%esi
    goto err;

  return newfdnum;
  8006b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  nva = fd2data(newfd);

  if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
    if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
      goto err;
  if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006b7:	85 f6                	test   %esi,%esi
  8006b9:	79 22                	jns    8006dd <dup+0x106>
    goto err;

  return newfdnum;

err:
  sys_page_unmap(0, newfd);
  8006bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006c6:	e8 4c fb ff ff       	call   800217 <sys_page_unmap>
  sys_page_unmap(0, nva);
  8006cb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006d6:	e8 3c fb ff ff       	call   800217 <sys_page_unmap>
  return r;
  8006db:	89 f0                	mov    %esi,%eax
}
  8006dd:	83 c4 3c             	add    $0x3c,%esp
  8006e0:	5b                   	pop    %ebx
  8006e1:	5e                   	pop    %esi
  8006e2:	5f                   	pop    %edi
  8006e3:	5d                   	pop    %ebp
  8006e4:	c3                   	ret    

008006e5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006e5:	55                   	push   %ebp
  8006e6:	89 e5                	mov    %esp,%ebp
  8006e8:	53                   	push   %ebx
  8006e9:	83 ec 24             	sub    $0x24,%esp
  8006ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  8006ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f6:	89 1c 24             	mov    %ebx,(%esp)
  8006f9:	e8 58 fd ff ff       	call   800456 <fd_lookup>
  8006fe:	89 c2                	mov    %eax,%edx
  800700:	85 d2                	test   %edx,%edx
  800702:	78 6d                	js     800771 <read+0x8c>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800704:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800707:	89 44 24 04          	mov    %eax,0x4(%esp)
  80070b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80070e:	8b 00                	mov    (%eax),%eax
  800710:	89 04 24             	mov    %eax,(%esp)
  800713:	e8 94 fd ff ff       	call   8004ac <dev_lookup>
  800718:	85 c0                	test   %eax,%eax
  80071a:	78 55                	js     800771 <read+0x8c>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80071c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80071f:	8b 50 08             	mov    0x8(%eax),%edx
  800722:	83 e2 03             	and    $0x3,%edx
  800725:	83 fa 01             	cmp    $0x1,%edx
  800728:	75 23                	jne    80074d <read+0x68>
    cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80072a:	a1 04 40 80 00       	mov    0x804004,%eax
  80072f:	8b 40 48             	mov    0x48(%eax),%eax
  800732:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800736:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073a:	c7 04 24 19 20 80 00 	movl   $0x802019,(%esp)
  800741:	e8 e9 0a 00 00       	call   80122f <cprintf>
    return -E_INVAL;
  800746:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80074b:	eb 24                	jmp    800771 <read+0x8c>
  }
  if (!dev->dev_read)
  80074d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800750:	8b 52 08             	mov    0x8(%edx),%edx
  800753:	85 d2                	test   %edx,%edx
  800755:	74 15                	je     80076c <read+0x87>
    return -E_NOT_SUPP;
  return (*dev->dev_read)(fd, buf, n);
  800757:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80075a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80075e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800761:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800765:	89 04 24             	mov    %eax,(%esp)
  800768:	ff d2                	call   *%edx
  80076a:	eb 05                	jmp    800771 <read+0x8c>
  if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
    cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  if (!dev->dev_read)
    return -E_NOT_SUPP;
  80076c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_read)(fd, buf, n);
}
  800771:	83 c4 24             	add    $0x24,%esp
  800774:	5b                   	pop    %ebx
  800775:	5d                   	pop    %ebp
  800776:	c3                   	ret    

00800777 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	57                   	push   %edi
  80077b:	56                   	push   %esi
  80077c:	53                   	push   %ebx
  80077d:	83 ec 1c             	sub    $0x1c,%esp
  800780:	8b 7d 08             	mov    0x8(%ebp),%edi
  800783:	8b 75 10             	mov    0x10(%ebp),%esi
  int m, tot;

  for (tot = 0; tot < n; tot += m) {
  800786:	bb 00 00 00 00       	mov    $0x0,%ebx
  80078b:	eb 23                	jmp    8007b0 <readn+0x39>
    m = read(fdnum, (char*)buf + tot, n - tot);
  80078d:	89 f0                	mov    %esi,%eax
  80078f:	29 d8                	sub    %ebx,%eax
  800791:	89 44 24 08          	mov    %eax,0x8(%esp)
  800795:	89 d8                	mov    %ebx,%eax
  800797:	03 45 0c             	add    0xc(%ebp),%eax
  80079a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80079e:	89 3c 24             	mov    %edi,(%esp)
  8007a1:	e8 3f ff ff ff       	call   8006e5 <read>
    if (m < 0)
  8007a6:	85 c0                	test   %eax,%eax
  8007a8:	78 10                	js     8007ba <readn+0x43>
      return m;
    if (m == 0)
  8007aa:	85 c0                	test   %eax,%eax
  8007ac:	74 0a                	je     8007b8 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
  int m, tot;

  for (tot = 0; tot < n; tot += m) {
  8007ae:	01 c3                	add    %eax,%ebx
  8007b0:	39 f3                	cmp    %esi,%ebx
  8007b2:	72 d9                	jb     80078d <readn+0x16>
  8007b4:	89 d8                	mov    %ebx,%eax
  8007b6:	eb 02                	jmp    8007ba <readn+0x43>
  8007b8:	89 d8                	mov    %ebx,%eax
      return m;
    if (m == 0)
      break;
  }
  return tot;
}
  8007ba:	83 c4 1c             	add    $0x1c,%esp
  8007bd:	5b                   	pop    %ebx
  8007be:	5e                   	pop    %esi
  8007bf:	5f                   	pop    %edi
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	53                   	push   %ebx
  8007c6:	83 ec 24             	sub    $0x24,%esp
  8007c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  8007cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d3:	89 1c 24             	mov    %ebx,(%esp)
  8007d6:	e8 7b fc ff ff       	call   800456 <fd_lookup>
  8007db:	89 c2                	mov    %eax,%edx
  8007dd:	85 d2                	test   %edx,%edx
  8007df:	78 68                	js     800849 <write+0x87>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007eb:	8b 00                	mov    (%eax),%eax
  8007ed:	89 04 24             	mov    %eax,(%esp)
  8007f0:	e8 b7 fc ff ff       	call   8004ac <dev_lookup>
  8007f5:	85 c0                	test   %eax,%eax
  8007f7:	78 50                	js     800849 <write+0x87>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800800:	75 23                	jne    800825 <write+0x63>
    cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800802:	a1 04 40 80 00       	mov    0x804004,%eax
  800807:	8b 40 48             	mov    0x48(%eax),%eax
  80080a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80080e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800812:	c7 04 24 35 20 80 00 	movl   $0x802035,(%esp)
  800819:	e8 11 0a 00 00       	call   80122f <cprintf>
    return -E_INVAL;
  80081e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800823:	eb 24                	jmp    800849 <write+0x87>
  }
  if (debug)
    cprintf("write %d %p %d via dev %s\n",
            fdnum, buf, n, dev->dev_name);
  if (!dev->dev_write)
  800825:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800828:	8b 52 0c             	mov    0xc(%edx),%edx
  80082b:	85 d2                	test   %edx,%edx
  80082d:	74 15                	je     800844 <write+0x82>
    return -E_NOT_SUPP;
  return (*dev->dev_write)(fd, buf, n);
  80082f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800832:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800836:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800839:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80083d:	89 04 24             	mov    %eax,(%esp)
  800840:	ff d2                	call   *%edx
  800842:	eb 05                	jmp    800849 <write+0x87>
  }
  if (debug)
    cprintf("write %d %p %d via dev %s\n",
            fdnum, buf, n, dev->dev_name);
  if (!dev->dev_write)
    return -E_NOT_SUPP;
  800844:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_write)(fd, buf, n);
}
  800849:	83 c4 24             	add    $0x24,%esp
  80084c:	5b                   	pop    %ebx
  80084d:	5d                   	pop    %ebp
  80084e:	c3                   	ret    

0080084f <seek>:

int
seek(int fdnum, off_t offset)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	83 ec 18             	sub    $0x18,%esp
  int r;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  800855:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800858:	89 44 24 04          	mov    %eax,0x4(%esp)
  80085c:	8b 45 08             	mov    0x8(%ebp),%eax
  80085f:	89 04 24             	mov    %eax,(%esp)
  800862:	e8 ef fb ff ff       	call   800456 <fd_lookup>
  800867:	85 c0                	test   %eax,%eax
  800869:	78 0e                	js     800879 <seek+0x2a>
    return r;
  fd->fd_offset = offset;
  80086b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80086e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800871:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
  800874:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800879:	c9                   	leave  
  80087a:	c3                   	ret    

0080087b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	83 ec 24             	sub    $0x24,%esp
  800882:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  800885:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800888:	89 44 24 04          	mov    %eax,0x4(%esp)
  80088c:	89 1c 24             	mov    %ebx,(%esp)
  80088f:	e8 c2 fb ff ff       	call   800456 <fd_lookup>
  800894:	89 c2                	mov    %eax,%edx
  800896:	85 d2                	test   %edx,%edx
  800898:	78 61                	js     8008fb <ftruncate+0x80>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80089a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80089d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008a4:	8b 00                	mov    (%eax),%eax
  8008a6:	89 04 24             	mov    %eax,(%esp)
  8008a9:	e8 fe fb ff ff       	call   8004ac <dev_lookup>
  8008ae:	85 c0                	test   %eax,%eax
  8008b0:	78 49                	js     8008fb <ftruncate+0x80>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008b5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008b9:	75 23                	jne    8008de <ftruncate+0x63>
    cprintf("[%08x] ftruncate %d -- bad mode\n",
            thisenv->env_id, fdnum);
  8008bb:	a1 04 40 80 00       	mov    0x804004,%eax

  if ((r = fd_lookup(fdnum, &fd)) < 0
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
    cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008c0:	8b 40 48             	mov    0x48(%eax),%eax
  8008c3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008cb:	c7 04 24 f8 1f 80 00 	movl   $0x801ff8,(%esp)
  8008d2:	e8 58 09 00 00       	call   80122f <cprintf>
            thisenv->env_id, fdnum);
    return -E_INVAL;
  8008d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008dc:	eb 1d                	jmp    8008fb <ftruncate+0x80>
  }
  if (!dev->dev_trunc)
  8008de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008e1:	8b 52 18             	mov    0x18(%edx),%edx
  8008e4:	85 d2                	test   %edx,%edx
  8008e6:	74 0e                	je     8008f6 <ftruncate+0x7b>
    return -E_NOT_SUPP;
  return (*dev->dev_trunc)(fd, newsize);
  8008e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008eb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008ef:	89 04 24             	mov    %eax,(%esp)
  8008f2:	ff d2                	call   *%edx
  8008f4:	eb 05                	jmp    8008fb <ftruncate+0x80>
    cprintf("[%08x] ftruncate %d -- bad mode\n",
            thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  if (!dev->dev_trunc)
    return -E_NOT_SUPP;
  8008f6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_trunc)(fd, newsize);
}
  8008fb:	83 c4 24             	add    $0x24,%esp
  8008fe:	5b                   	pop    %ebx
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    

00800901 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	53                   	push   %ebx
  800905:	83 ec 24             	sub    $0x24,%esp
  800908:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  80090b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80090e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800912:	8b 45 08             	mov    0x8(%ebp),%eax
  800915:	89 04 24             	mov    %eax,(%esp)
  800918:	e8 39 fb ff ff       	call   800456 <fd_lookup>
  80091d:	89 c2                	mov    %eax,%edx
  80091f:	85 d2                	test   %edx,%edx
  800921:	78 52                	js     800975 <fstat+0x74>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800923:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800926:	89 44 24 04          	mov    %eax,0x4(%esp)
  80092a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80092d:	8b 00                	mov    (%eax),%eax
  80092f:	89 04 24             	mov    %eax,(%esp)
  800932:	e8 75 fb ff ff       	call   8004ac <dev_lookup>
  800937:	85 c0                	test   %eax,%eax
  800939:	78 3a                	js     800975 <fstat+0x74>
    return r;
  if (!dev->dev_stat)
  80093b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80093e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800942:	74 2c                	je     800970 <fstat+0x6f>
    return -E_NOT_SUPP;
  stat->st_name[0] = 0;
  800944:	c6 03 00             	movb   $0x0,(%ebx)
  stat->st_size = 0;
  800947:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80094e:	00 00 00 
  stat->st_isdir = 0;
  800951:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800958:	00 00 00 
  stat->st_dev = dev;
  80095b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
  return (*dev->dev_stat)(fd, stat);
  800961:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800965:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800968:	89 14 24             	mov    %edx,(%esp)
  80096b:	ff 50 14             	call   *0x14(%eax)
  80096e:	eb 05                	jmp    800975 <fstat+0x74>

  if ((r = fd_lookup(fdnum, &fd)) < 0
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
    return r;
  if (!dev->dev_stat)
    return -E_NOT_SUPP;
  800970:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  stat->st_name[0] = 0;
  stat->st_size = 0;
  stat->st_isdir = 0;
  stat->st_dev = dev;
  return (*dev->dev_stat)(fd, stat);
}
  800975:	83 c4 24             	add    $0x24,%esp
  800978:	5b                   	pop    %ebx
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	56                   	push   %esi
  80097f:	53                   	push   %ebx
  800980:	83 ec 10             	sub    $0x10,%esp
  int fd, r;

  if ((fd = open(path, O_RDONLY)) < 0)
  800983:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80098a:	00 
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	89 04 24             	mov    %eax,(%esp)
  800991:	e8 d2 01 00 00       	call   800b68 <open>
  800996:	89 c3                	mov    %eax,%ebx
  800998:	85 db                	test   %ebx,%ebx
  80099a:	78 1b                	js     8009b7 <stat+0x3c>
    return fd;
  r = fstat(fd, stat);
  80099c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a3:	89 1c 24             	mov    %ebx,(%esp)
  8009a6:	e8 56 ff ff ff       	call   800901 <fstat>
  8009ab:	89 c6                	mov    %eax,%esi
  close(fd);
  8009ad:	89 1c 24             	mov    %ebx,(%esp)
  8009b0:	e8 cd fb ff ff       	call   800582 <close>
  return r;
  8009b5:	89 f0                	mov    %esi,%eax
}
  8009b7:	83 c4 10             	add    $0x10,%esp
  8009ba:	5b                   	pop    %ebx
  8009bb:	5e                   	pop    %esi
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	56                   	push   %esi
  8009c2:	53                   	push   %ebx
  8009c3:	83 ec 10             	sub    $0x10,%esp
  8009c6:	89 c6                	mov    %eax,%esi
  8009c8:	89 d3                	mov    %edx,%ebx
  static envid_t fsenv;

  if (fsenv == 0)
  8009ca:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009d1:	75 11                	jne    8009e4 <fsipc+0x26>
    fsenv = ipc_find_env(ENV_TYPE_FS);
  8009d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8009da:	e8 b8 12 00 00       	call   801c97 <ipc_find_env>
  8009df:	a3 00 40 80 00       	mov    %eax,0x804000
  static_assert(sizeof(fsipcbuf) == PGSIZE);

  if (debug)
    cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t*)&fsipcbuf);

  ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009e4:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8009eb:	00 
  8009ec:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8009f3:	00 
  8009f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009f8:	a1 00 40 80 00       	mov    0x804000,%eax
  8009fd:	89 04 24             	mov    %eax,(%esp)
  800a00:	e8 27 12 00 00       	call   801c2c <ipc_send>
  return ipc_recv(NULL, dstva, NULL);
  800a05:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a0c:	00 
  800a0d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a11:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a18:	e8 89 11 00 00       	call   801ba6 <ipc_recv>
}
  800a1d:	83 c4 10             	add    $0x10,%esp
  800a20:	5b                   	pop    %ebx
  800a21:	5e                   	pop    %esi
  800a22:	5d                   	pop    %ebp
  800a23:	c3                   	ret    

00800a24 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	83 ec 08             	sub    $0x8,%esp
  fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a30:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.set_size.req_size = newsize;
  800a35:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a38:	a3 04 50 80 00       	mov    %eax,0x805004
  return fsipc(FSREQ_SET_SIZE, NULL);
  800a3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a42:	b8 02 00 00 00       	mov    $0x2,%eax
  800a47:	e8 72 ff ff ff       	call   8009be <fsipc>
}
  800a4c:	c9                   	leave  
  800a4d:	c3                   	ret    

00800a4e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	83 ec 08             	sub    $0x8,%esp
  fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a54:	8b 45 08             	mov    0x8(%ebp),%eax
  800a57:	8b 40 0c             	mov    0xc(%eax),%eax
  800a5a:	a3 00 50 80 00       	mov    %eax,0x805000
  return fsipc(FSREQ_FLUSH, NULL);
  800a5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a64:	b8 06 00 00 00       	mov    $0x6,%eax
  800a69:	e8 50 ff ff ff       	call   8009be <fsipc>
}
  800a6e:	c9                   	leave  
  800a6f:	c3                   	ret    

00800a70 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	53                   	push   %ebx
  800a74:	83 ec 14             	sub    $0x14,%esp
  800a77:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int r;

  fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a80:	a3 00 50 80 00       	mov    %eax,0x805000
  if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a85:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8a:	b8 05 00 00 00       	mov    $0x5,%eax
  800a8f:	e8 2a ff ff ff       	call   8009be <fsipc>
  800a94:	89 c2                	mov    %eax,%edx
  800a96:	85 d2                	test   %edx,%edx
  800a98:	78 2b                	js     800ac5 <devfile_stat+0x55>
    return r;
  strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a9a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800aa1:	00 
  800aa2:	89 1c 24             	mov    %ebx,(%esp)
  800aa5:	e8 ad 0d 00 00       	call   801857 <strcpy>
  st->st_size = fsipcbuf.statRet.ret_size;
  800aaa:	a1 80 50 80 00       	mov    0x805080,%eax
  800aaf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800ab5:	a1 84 50 80 00       	mov    0x805084,%eax
  800aba:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  return 0;
  800ac0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac5:	83 c4 14             	add    $0x14,%esp
  800ac8:	5b                   	pop    %ebx
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	83 ec 18             	sub    $0x18,%esp
  800ad1:	8b 45 10             	mov    0x10(%ebp),%eax
  // remember that write is always allowed to write *fewer*
  // bytes than requested.
  // LAB 5: Your code here
    int r;

    fsipcbuf.write.req_fileid = fd->fd_file.id;
  800ad4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad7:	8b 52 0c             	mov    0xc(%edx),%edx
  800ada:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  800ae0:	a3 04 50 80 00       	mov    %eax,0x805004

    size_t max_written = sizeof(fsipcbuf.write.req_buf);
    memmove(fsipcbuf.write.req_buf, buf, MIN(max_written, n));
  800ae5:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800aea:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800aef:	0f 47 c2             	cmova  %edx,%eax
  800af2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800af6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800afd:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800b04:	e8 eb 0e 00 00       	call   8019f4 <memmove>

    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800b09:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0e:	b8 04 00 00 00       	mov    $0x4,%eax
  800b13:	e8 a6 fe ff ff       	call   8009be <fsipc>
        return r;

    return r;
}
  800b18:	c9                   	leave  
  800b19:	c3                   	ret    

00800b1a <devfile_read>:
// Returns:
//  The number of bytes successfully read.
//  < 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	53                   	push   %ebx
  800b1e:	83 ec 14             	sub    $0x14,%esp
  // filling fsipcbuf.read with the request arguments.  The
  // bytes read will be written back to fsipcbuf by the file
  // system server.
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b21:	8b 45 08             	mov    0x8(%ebp),%eax
  800b24:	8b 40 0c             	mov    0xc(%eax),%eax
  800b27:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  800b2c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b2f:	a3 04 50 80 00       	mov    %eax,0x805004
  if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b34:	ba 00 00 00 00       	mov    $0x0,%edx
  800b39:	b8 03 00 00 00       	mov    $0x3,%eax
  800b3e:	e8 7b fe ff ff       	call   8009be <fsipc>
  800b43:	89 c3                	mov    %eax,%ebx
  800b45:	85 c0                	test   %eax,%eax
  800b47:	78 17                	js     800b60 <devfile_read+0x46>
    return r;

  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b49:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b4d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800b54:	00 
  800b55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b58:	89 04 24             	mov    %eax,(%esp)
  800b5b:	e8 94 0e 00 00       	call   8019f4 <memmove>
  return r;
}
  800b60:	89 d8                	mov    %ebx,%eax
  800b62:	83 c4 14             	add    $0x14,%esp
  800b65:	5b                   	pop    %ebx
  800b66:	5d                   	pop    %ebp
  800b67:	c3                   	ret    

00800b68 <open>:
//  The file descriptor index on success
//  -E_BAD_PATH if the path is too long (>= MAXPATHLEN)
//  < 0 for other errors.
int
open(const char *path, int mode)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	53                   	push   %ebx
  800b6c:	83 ec 24             	sub    $0x24,%esp
  800b6f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  // file descriptor.

  int r;
  struct Fd *fd;

  if (strlen(path) >= MAXPATHLEN)
  800b72:	89 1c 24             	mov    %ebx,(%esp)
  800b75:	e8 a6 0c 00 00       	call   801820 <strlen>
  800b7a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b7f:	7f 60                	jg     800be1 <open+0x79>
    return -E_BAD_PATH;

  if ((r = fd_alloc(&fd)) < 0)
  800b81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b84:	89 04 24             	mov    %eax,(%esp)
  800b87:	e8 7b f8 ff ff       	call   800407 <fd_alloc>
  800b8c:	89 c2                	mov    %eax,%edx
  800b8e:	85 d2                	test   %edx,%edx
  800b90:	78 54                	js     800be6 <open+0x7e>
    return r;

  strcpy(fsipcbuf.open.req_path, path);
  800b92:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b96:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800b9d:	e8 b5 0c 00 00       	call   801857 <strcpy>
  fsipcbuf.open.req_omode = mode;
  800ba2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba5:	a3 00 54 80 00       	mov    %eax,0x805400

  if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800baa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bad:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb2:	e8 07 fe ff ff       	call   8009be <fsipc>
  800bb7:	89 c3                	mov    %eax,%ebx
  800bb9:	85 c0                	test   %eax,%eax
  800bbb:	79 17                	jns    800bd4 <open+0x6c>
    fd_close(fd, 0);
  800bbd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800bc4:	00 
  800bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bc8:	89 04 24             	mov    %eax,(%esp)
  800bcb:	e8 31 f9 ff ff       	call   800501 <fd_close>
    return r;
  800bd0:	89 d8                	mov    %ebx,%eax
  800bd2:	eb 12                	jmp    800be6 <open+0x7e>
  }

  return fd2num(fd);
  800bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bd7:	89 04 24             	mov    %eax,(%esp)
  800bda:	e8 01 f8 ff ff       	call   8003e0 <fd2num>
  800bdf:	eb 05                	jmp    800be6 <open+0x7e>

  int r;
  struct Fd *fd;

  if (strlen(path) >= MAXPATHLEN)
    return -E_BAD_PATH;
  800be1:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
    fd_close(fd, 0);
    return r;
  }

  return fd2num(fd);
}
  800be6:	83 c4 24             	add    $0x24,%esp
  800be9:	5b                   	pop    %ebx
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	83 ec 08             	sub    $0x8,%esp
  // Ask the file server to update the disk
  // by writing any dirty blocks in the buffer cache.

  return fsipc(FSREQ_SYNC, NULL);
  800bf2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf7:	b8 08 00 00 00       	mov    $0x8,%eax
  800bfc:	e8 bd fd ff ff       	call   8009be <fsipc>
}
  800c01:	c9                   	leave  
  800c02:	c3                   	ret    

00800c03 <devpipe_stat>:
  return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
  800c08:	83 ec 10             	sub    $0x10,%esp
  800c0b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct Pipe *p = (struct Pipe*)fd2data(fd);
  800c0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c11:	89 04 24             	mov    %eax,(%esp)
  800c14:	e8 d7 f7 ff ff       	call   8003f0 <fd2data>
  800c19:	89 c6                	mov    %eax,%esi

  strcpy(stat->st_name, "<pipe>");
  800c1b:	c7 44 24 04 64 20 80 	movl   $0x802064,0x4(%esp)
  800c22:	00 
  800c23:	89 1c 24             	mov    %ebx,(%esp)
  800c26:	e8 2c 0c 00 00       	call   801857 <strcpy>
  stat->st_size = p->p_wpos - p->p_rpos;
  800c2b:	8b 46 04             	mov    0x4(%esi),%eax
  800c2e:	2b 06                	sub    (%esi),%eax
  800c30:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  stat->st_isdir = 0;
  800c36:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c3d:	00 00 00 
  stat->st_dev = &devpipe;
  800c40:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800c47:	30 80 00 
  return 0;
}
  800c4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4f:	83 c4 10             	add    $0x10,%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	53                   	push   %ebx
  800c5a:	83 ec 14             	sub    $0x14,%esp
  800c5d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  (void)sys_page_unmap(0, fd);
  800c60:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c64:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c6b:	e8 a7 f5 ff ff       	call   800217 <sys_page_unmap>
  return sys_page_unmap(0, fd2data(fd));
  800c70:	89 1c 24             	mov    %ebx,(%esp)
  800c73:	e8 78 f7 ff ff       	call   8003f0 <fd2data>
  800c78:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c7c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c83:	e8 8f f5 ff ff       	call   800217 <sys_page_unmap>
}
  800c88:	83 c4 14             	add    $0x14,%esp
  800c8b:	5b                   	pop    %ebx
  800c8c:	5d                   	pop    %ebp
  800c8d:	c3                   	ret    

00800c8e <_pipeisclosed>:
  return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
  800c94:	83 ec 2c             	sub    $0x2c,%esp
  800c97:	89 c6                	mov    %eax,%esi
  800c99:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  int n, nn, ret;

  while (1) {
    n = thisenv->env_runs;
  800c9c:	a1 04 40 80 00       	mov    0x804004,%eax
  800ca1:	8b 58 58             	mov    0x58(%eax),%ebx
    ret = pageref(fd) == pageref(p);
  800ca4:	89 34 24             	mov    %esi,(%esp)
  800ca7:	e8 23 10 00 00       	call   801ccf <pageref>
  800cac:	89 c7                	mov    %eax,%edi
  800cae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cb1:	89 04 24             	mov    %eax,(%esp)
  800cb4:	e8 16 10 00 00       	call   801ccf <pageref>
  800cb9:	39 c7                	cmp    %eax,%edi
  800cbb:	0f 94 c2             	sete   %dl
  800cbe:	0f b6 c2             	movzbl %dl,%eax
    nn = thisenv->env_runs;
  800cc1:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  800cc7:	8b 79 58             	mov    0x58(%ecx),%edi
    if (n == nn)
  800cca:	39 fb                	cmp    %edi,%ebx
  800ccc:	74 21                	je     800cef <_pipeisclosed+0x61>
      return ret;
    if (n != nn && ret == 1)
  800cce:	84 d2                	test   %dl,%dl
  800cd0:	74 ca                	je     800c9c <_pipeisclosed+0xe>
      cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800cd2:	8b 51 58             	mov    0x58(%ecx),%edx
  800cd5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cd9:	89 54 24 08          	mov    %edx,0x8(%esp)
  800cdd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ce1:	c7 04 24 6b 20 80 00 	movl   $0x80206b,(%esp)
  800ce8:	e8 42 05 00 00       	call   80122f <cprintf>
  800ced:	eb ad                	jmp    800c9c <_pipeisclosed+0xe>
  }
}
  800cef:	83 c4 2c             	add    $0x2c,%esp
  800cf2:	5b                   	pop    %ebx
  800cf3:	5e                   	pop    %esi
  800cf4:	5f                   	pop    %edi
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    

00800cf7 <devpipe_write>:
  return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	57                   	push   %edi
  800cfb:	56                   	push   %esi
  800cfc:	53                   	push   %ebx
  800cfd:	83 ec 1c             	sub    $0x1c,%esp
  800d00:	8b 75 08             	mov    0x8(%ebp),%esi
  const uint8_t *buf;
  size_t i;
  struct Pipe *p;

  p = (struct Pipe*)fd2data(fd);
  800d03:	89 34 24             	mov    %esi,(%esp)
  800d06:	e8 e5 f6 ff ff       	call   8003f0 <fd2data>
  800d0b:	89 c3                	mov    %eax,%ebx
  if (debug)
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  800d0d:	bf 00 00 00 00       	mov    $0x0,%edi
  800d12:	eb 45                	jmp    800d59 <devpipe_write+0x62>
    while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
      // pipe is full
      // if all the readers are gone
      // (it's only writers like us now),
      // note eof
      if (_pipeisclosed(fd, p))
  800d14:	89 da                	mov    %ebx,%edx
  800d16:	89 f0                	mov    %esi,%eax
  800d18:	e8 71 ff ff ff       	call   800c8e <_pipeisclosed>
  800d1d:	85 c0                	test   %eax,%eax
  800d1f:	75 41                	jne    800d62 <devpipe_write+0x6b>
        return 0;
      // yield and see what happens
      if (debug)
        cprintf("devpipe_write yield\n");
      sys_yield();
  800d21:	e8 2b f4 ff ff       	call   800151 <sys_yield>
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
    while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800d26:	8b 43 04             	mov    0x4(%ebx),%eax
  800d29:	8b 0b                	mov    (%ebx),%ecx
  800d2b:	8d 51 20             	lea    0x20(%ecx),%edx
  800d2e:	39 d0                	cmp    %edx,%eax
  800d30:	73 e2                	jae    800d14 <devpipe_write+0x1d>
        cprintf("devpipe_write yield\n");
      sys_yield();
    }
    // there's room for a byte.  store it.
    // wait to increment wpos until the byte is stored!
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800d32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d35:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800d39:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800d3c:	99                   	cltd   
  800d3d:	c1 ea 1b             	shr    $0x1b,%edx
  800d40:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  800d43:	83 e1 1f             	and    $0x1f,%ecx
  800d46:	29 d1                	sub    %edx,%ecx
  800d48:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  800d4c:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
    p->p_wpos++;
  800d50:	83 c0 01             	add    $0x1,%eax
  800d53:	89 43 04             	mov    %eax,0x4(%ebx)
  if (debug)
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  800d56:	83 c7 01             	add    $0x1,%edi
  800d59:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800d5c:	75 c8                	jne    800d26 <devpipe_write+0x2f>
    // wait to increment wpos until the byte is stored!
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
    p->p_wpos++;
  }

  return i;
  800d5e:	89 f8                	mov    %edi,%eax
  800d60:	eb 05                	jmp    800d67 <devpipe_write+0x70>
      // pipe is full
      // if all the readers are gone
      // (it's only writers like us now),
      // note eof
      if (_pipeisclosed(fd, p))
        return 0;
  800d62:	b8 00 00 00 00       	mov    $0x0,%eax
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
    p->p_wpos++;
  }

  return i;
}
  800d67:	83 c4 1c             	add    $0x1c,%esp
  800d6a:	5b                   	pop    %ebx
  800d6b:	5e                   	pop    %esi
  800d6c:	5f                   	pop    %edi
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    

00800d6f <devpipe_read>:
  return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	57                   	push   %edi
  800d73:	56                   	push   %esi
  800d74:	53                   	push   %ebx
  800d75:	83 ec 1c             	sub    $0x1c,%esp
  800d78:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint8_t *buf;
  size_t i;
  struct Pipe *p;

  p = (struct Pipe*)fd2data(fd);
  800d7b:	89 3c 24             	mov    %edi,(%esp)
  800d7e:	e8 6d f6 ff ff       	call   8003f0 <fd2data>
  800d83:	89 c3                	mov    %eax,%ebx
  if (debug)
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  800d85:	be 00 00 00 00       	mov    $0x0,%esi
  800d8a:	eb 3d                	jmp    800dc9 <devpipe_read+0x5a>
    while (p->p_rpos == p->p_wpos) {
      // pipe is empty
      // if we got any data, return it
      if (i > 0)
  800d8c:	85 f6                	test   %esi,%esi
  800d8e:	74 04                	je     800d94 <devpipe_read+0x25>
        return i;
  800d90:	89 f0                	mov    %esi,%eax
  800d92:	eb 43                	jmp    800dd7 <devpipe_read+0x68>
      // if all the writers are gone, note eof
      if (_pipeisclosed(fd, p))
  800d94:	89 da                	mov    %ebx,%edx
  800d96:	89 f8                	mov    %edi,%eax
  800d98:	e8 f1 fe ff ff       	call   800c8e <_pipeisclosed>
  800d9d:	85 c0                	test   %eax,%eax
  800d9f:	75 31                	jne    800dd2 <devpipe_read+0x63>
        return 0;
      // yield and see what happens
      if (debug)
        cprintf("devpipe_read yield\n");
      sys_yield();
  800da1:	e8 ab f3 ff ff       	call   800151 <sys_yield>
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
    while (p->p_rpos == p->p_wpos) {
  800da6:	8b 03                	mov    (%ebx),%eax
  800da8:	3b 43 04             	cmp    0x4(%ebx),%eax
  800dab:	74 df                	je     800d8c <devpipe_read+0x1d>
        cprintf("devpipe_read yield\n");
      sys_yield();
    }
    // there's a byte.  take it.
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800dad:	99                   	cltd   
  800dae:	c1 ea 1b             	shr    $0x1b,%edx
  800db1:	01 d0                	add    %edx,%eax
  800db3:	83 e0 1f             	and    $0x1f,%eax
  800db6:	29 d0                	sub    %edx,%eax
  800db8:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800dbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc0:	88 04 31             	mov    %al,(%ecx,%esi,1)
    p->p_rpos++;
  800dc3:	83 03 01             	addl   $0x1,(%ebx)
  if (debug)
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  800dc6:	83 c6 01             	add    $0x1,%esi
  800dc9:	3b 75 10             	cmp    0x10(%ebp),%esi
  800dcc:	75 d8                	jne    800da6 <devpipe_read+0x37>
    // there's a byte.  take it.
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
    p->p_rpos++;
  }
  return i;
  800dce:	89 f0                	mov    %esi,%eax
  800dd0:	eb 05                	jmp    800dd7 <devpipe_read+0x68>
      // if we got any data, return it
      if (i > 0)
        return i;
      // if all the writers are gone, note eof
      if (_pipeisclosed(fd, p))
        return 0;
  800dd2:	b8 00 00 00 00       	mov    $0x0,%eax
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
    p->p_rpos++;
  }
  return i;
}
  800dd7:	83 c4 1c             	add    $0x1c,%esp
  800dda:	5b                   	pop    %ebx
  800ddb:	5e                   	pop    %esi
  800ddc:	5f                   	pop    %edi
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    

00800ddf <pipe>:
  uint8_t p_buf[PIPEBUFSIZ];    // data buffer
};

int
pipe(int pfd[2])
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	56                   	push   %esi
  800de3:	53                   	push   %ebx
  800de4:	83 ec 30             	sub    $0x30,%esp
  int r;
  struct Fd *fd0, *fd1;
  void *va;

  // allocate the file descriptor table entries
  if ((r = fd_alloc(&fd0)) < 0
  800de7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800dea:	89 04 24             	mov    %eax,(%esp)
  800ded:	e8 15 f6 ff ff       	call   800407 <fd_alloc>
  800df2:	89 c2                	mov    %eax,%edx
  800df4:	85 d2                	test   %edx,%edx
  800df6:	0f 88 4d 01 00 00    	js     800f49 <pipe+0x16a>
      || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dfc:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e03:	00 
  800e04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e07:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e12:	e8 59 f3 ff ff       	call   800170 <sys_page_alloc>
  800e17:	89 c2                	mov    %eax,%edx
  800e19:	85 d2                	test   %edx,%edx
  800e1b:	0f 88 28 01 00 00    	js     800f49 <pipe+0x16a>
    goto err;

  if ((r = fd_alloc(&fd1)) < 0
  800e21:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e24:	89 04 24             	mov    %eax,(%esp)
  800e27:	e8 db f5 ff ff       	call   800407 <fd_alloc>
  800e2c:	89 c3                	mov    %eax,%ebx
  800e2e:	85 c0                	test   %eax,%eax
  800e30:	0f 88 fe 00 00 00    	js     800f34 <pipe+0x155>
      || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e36:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e3d:	00 
  800e3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e41:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e45:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e4c:	e8 1f f3 ff ff       	call   800170 <sys_page_alloc>
  800e51:	89 c3                	mov    %eax,%ebx
  800e53:	85 c0                	test   %eax,%eax
  800e55:	0f 88 d9 00 00 00    	js     800f34 <pipe+0x155>
    goto err1;

  // allocate the pipe structure as first data page in both
  va = fd2data(fd0);
  800e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e5e:	89 04 24             	mov    %eax,(%esp)
  800e61:	e8 8a f5 ff ff       	call   8003f0 <fd2data>
  800e66:	89 c6                	mov    %eax,%esi
  if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e68:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e6f:	00 
  800e70:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e7b:	e8 f0 f2 ff ff       	call   800170 <sys_page_alloc>
  800e80:	89 c3                	mov    %eax,%ebx
  800e82:	85 c0                	test   %eax,%eax
  800e84:	0f 88 97 00 00 00    	js     800f21 <pipe+0x142>
    goto err2;
  if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e8d:	89 04 24             	mov    %eax,(%esp)
  800e90:	e8 5b f5 ff ff       	call   8003f0 <fd2data>
  800e95:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  800e9c:	00 
  800e9d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ea1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ea8:	00 
  800ea9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ead:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800eb4:	e8 0b f3 ff ff       	call   8001c4 <sys_page_map>
  800eb9:	89 c3                	mov    %eax,%ebx
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	78 52                	js     800f11 <pipe+0x132>
    goto err3;

  // set up fd structures
  fd0->fd_dev_id = devpipe.dev_id;
  800ebf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ec5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ec8:	89 10                	mov    %edx,(%eax)
  fd0->fd_omode = O_RDONLY;
  800eca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ecd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

  fd1->fd_dev_id = devpipe.dev_id;
  800ed4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800eda:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800edd:	89 10                	mov    %edx,(%eax)
  fd1->fd_omode = O_WRONLY;
  800edf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ee2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

  if (debug)
    cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

  pfd[0] = fd2num(fd0);
  800ee9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eec:	89 04 24             	mov    %eax,(%esp)
  800eef:	e8 ec f4 ff ff       	call   8003e0 <fd2num>
  800ef4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef7:	89 01                	mov    %eax,(%ecx)
  pfd[1] = fd2num(fd1);
  800ef9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800efc:	89 04 24             	mov    %eax,(%esp)
  800eff:	e8 dc f4 ff ff       	call   8003e0 <fd2num>
  800f04:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f07:	89 41 04             	mov    %eax,0x4(%ecx)
  return 0;
  800f0a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0f:	eb 38                	jmp    800f49 <pipe+0x16a>

err3:
  sys_page_unmap(0, va);
  800f11:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f15:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f1c:	e8 f6 f2 ff ff       	call   800217 <sys_page_unmap>
err2:
  sys_page_unmap(0, fd1);
  800f21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f24:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f28:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f2f:	e8 e3 f2 ff ff       	call   800217 <sys_page_unmap>
err1:
  sys_page_unmap(0, fd0);
  800f34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f37:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f3b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f42:	e8 d0 f2 ff ff       	call   800217 <sys_page_unmap>
  800f47:	89 d8                	mov    %ebx,%eax
err:
  return r;
}
  800f49:	83 c4 30             	add    $0x30,%esp
  800f4c:	5b                   	pop    %ebx
  800f4d:	5e                   	pop    %esi
  800f4e:	5d                   	pop    %ebp
  800f4f:	c3                   	ret    

00800f50 <pipeisclosed>:
  }
}

int
pipeisclosed(int fdnum)
{
  800f50:	55                   	push   %ebp
  800f51:	89 e5                	mov    %esp,%ebp
  800f53:	83 ec 28             	sub    $0x28,%esp
  struct Fd *fd;
  struct Pipe *p;
  int r;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f56:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f59:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f60:	89 04 24             	mov    %eax,(%esp)
  800f63:	e8 ee f4 ff ff       	call   800456 <fd_lookup>
  800f68:	89 c2                	mov    %eax,%edx
  800f6a:	85 d2                	test   %edx,%edx
  800f6c:	78 15                	js     800f83 <pipeisclosed+0x33>
    return r;
  p = (struct Pipe*)fd2data(fd);
  800f6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f71:	89 04 24             	mov    %eax,(%esp)
  800f74:	e8 77 f4 ff ff       	call   8003f0 <fd2data>
  return _pipeisclosed(fd, p);
  800f79:	89 c2                	mov    %eax,%edx
  800f7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f7e:	e8 0b fd ff ff       	call   800c8e <_pipeisclosed>
}
  800f83:	c9                   	leave  
  800f84:	c3                   	ret    
  800f85:	66 90                	xchg   %ax,%ax
  800f87:	66 90                	xchg   %ax,%ax
  800f89:	66 90                	xchg   %ax,%ax
  800f8b:	66 90                	xchg   %ax,%ax
  800f8d:	66 90                	xchg   %ax,%ax
  800f8f:	90                   	nop

00800f90 <devcons_close>:
  return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  USED(fd);

  return 0;
}
  800f93:	b8 00 00 00 00       	mov    $0x0,%eax
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    

00800f9a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	83 ec 18             	sub    $0x18,%esp
  strcpy(stat->st_name, "<cons>");
  800fa0:	c7 44 24 04 83 20 80 	movl   $0x802083,0x4(%esp)
  800fa7:	00 
  800fa8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fab:	89 04 24             	mov    %eax,(%esp)
  800fae:	e8 a4 08 00 00       	call   801857 <strcpy>
  return 0;
}
  800fb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb8:	c9                   	leave  
  800fb9:	c3                   	ret    

00800fba <devcons_write>:
  return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	57                   	push   %edi
  800fbe:	56                   	push   %esi
  800fbf:	53                   	push   %ebx
  800fc0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  800fc6:	bb 00 00 00 00       	mov    $0x0,%ebx
    m = n - tot;
    if (m > sizeof(buf) - 1)
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
  800fcb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  800fd1:	eb 31                	jmp    801004 <devcons_write+0x4a>
    m = n - tot;
  800fd3:	8b 75 10             	mov    0x10(%ebp),%esi
  800fd6:	29 de                	sub    %ebx,%esi
    if (m > sizeof(buf) - 1)
  800fd8:	83 fe 7f             	cmp    $0x7f,%esi
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
    m = n - tot;
  800fdb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800fe0:	0f 47 f2             	cmova  %edx,%esi
    if (m > sizeof(buf) - 1)
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
  800fe3:	89 74 24 08          	mov    %esi,0x8(%esp)
  800fe7:	03 45 0c             	add    0xc(%ebp),%eax
  800fea:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fee:	89 3c 24             	mov    %edi,(%esp)
  800ff1:	e8 fe 09 00 00       	call   8019f4 <memmove>
    sys_cputs(buf, m);
  800ff6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ffa:	89 3c 24             	mov    %edi,(%esp)
  800ffd:	e8 a1 f0 ff ff       	call   8000a3 <sys_cputs>
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  801002:	01 f3                	add    %esi,%ebx
  801004:	89 d8                	mov    %ebx,%eax
  801006:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801009:	72 c8                	jb     800fd3 <devcons_write+0x19>
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
    sys_cputs(buf, m);
  }
  return tot;
}
  80100b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801011:	5b                   	pop    %ebx
  801012:	5e                   	pop    %esi
  801013:	5f                   	pop    %edi
  801014:	5d                   	pop    %ebp
  801015:	c3                   	ret    

00801016 <devcons_read>:
  return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801016:	55                   	push   %ebp
  801017:	89 e5                	mov    %esp,%ebp
  801019:	83 ec 08             	sub    $0x8,%esp
  int c;

  if (n == 0)
    return 0;
  80101c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  int c;

  if (n == 0)
  801021:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801025:	75 07                	jne    80102e <devcons_read+0x18>
  801027:	eb 2a                	jmp    801053 <devcons_read+0x3d>
    return 0;

  while ((c = sys_cgetc()) == 0)
    sys_yield();
  801029:	e8 23 f1 ff ff       	call   800151 <sys_yield>
  int c;

  if (n == 0)
    return 0;

  while ((c = sys_cgetc()) == 0)
  80102e:	66 90                	xchg   %ax,%ax
  801030:	e8 8c f0 ff ff       	call   8000c1 <sys_cgetc>
  801035:	85 c0                	test   %eax,%eax
  801037:	74 f0                	je     801029 <devcons_read+0x13>
    sys_yield();
  if (c < 0)
  801039:	85 c0                	test   %eax,%eax
  80103b:	78 16                	js     801053 <devcons_read+0x3d>
    return c;
  if (c == 0x04)        // ctl-d is eof
  80103d:	83 f8 04             	cmp    $0x4,%eax
  801040:	74 0c                	je     80104e <devcons_read+0x38>
    return 0;
  *(char*)vbuf = c;
  801042:	8b 55 0c             	mov    0xc(%ebp),%edx
  801045:	88 02                	mov    %al,(%edx)
  return 1;
  801047:	b8 01 00 00 00       	mov    $0x1,%eax
  80104c:	eb 05                	jmp    801053 <devcons_read+0x3d>
  while ((c = sys_cgetc()) == 0)
    sys_yield();
  if (c < 0)
    return c;
  if (c == 0x04)        // ctl-d is eof
    return 0;
  80104e:	b8 00 00 00 00       	mov    $0x0,%eax
  *(char*)vbuf = c;
  return 1;
}
  801053:	c9                   	leave  
  801054:	c3                   	ret    

00801055 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801055:	55                   	push   %ebp
  801056:	89 e5                	mov    %esp,%ebp
  801058:	83 ec 28             	sub    $0x28,%esp
  char c = ch;
  80105b:	8b 45 08             	mov    0x8(%ebp),%eax
  80105e:	88 45 f7             	mov    %al,-0x9(%ebp)

  // Unlike standard Unix's putchar,
  // the cputchar function _always_ outputs to the system console.
  sys_cputs(&c, 1);
  801061:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801068:	00 
  801069:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80106c:	89 04 24             	mov    %eax,(%esp)
  80106f:	e8 2f f0 ff ff       	call   8000a3 <sys_cputs>
}
  801074:	c9                   	leave  
  801075:	c3                   	ret    

00801076 <getchar>:

int
getchar(void)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	83 ec 28             	sub    $0x28,%esp
  int r;

  // JOS does, however, support standard _input_ redirection,
  // allowing the user to redirect script files to the shell and such.
  // getchar() reads a character from file descriptor 0.
  r = read(0, &c, 1);
  80107c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801083:	00 
  801084:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801087:	89 44 24 04          	mov    %eax,0x4(%esp)
  80108b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801092:	e8 4e f6 ff ff       	call   8006e5 <read>
  if (r < 0)
  801097:	85 c0                	test   %eax,%eax
  801099:	78 0f                	js     8010aa <getchar+0x34>
    return r;
  if (r < 1)
  80109b:	85 c0                	test   %eax,%eax
  80109d:	7e 06                	jle    8010a5 <getchar+0x2f>
    return -E_EOF;
  return c;
  80109f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8010a3:	eb 05                	jmp    8010aa <getchar+0x34>
  // getchar() reads a character from file descriptor 0.
  r = read(0, &c, 1);
  if (r < 0)
    return r;
  if (r < 1)
    return -E_EOF;
  8010a5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  /* int r;
  // sys_cgetc does not block, but getchar should.
  while ((r = sys_cgetc()) == 0)
    sys_yield();
  return r; */
}
  8010aa:	c9                   	leave  
  8010ab:	c3                   	ret    

008010ac <iscons>:
  .dev_stat   =     devcons_stat
};

int
iscons(int fdnum)
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
  8010af:	83 ec 28             	sub    $0x28,%esp
  int r;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010bc:	89 04 24             	mov    %eax,(%esp)
  8010bf:	e8 92 f3 ff ff       	call   800456 <fd_lookup>
  8010c4:	85 c0                	test   %eax,%eax
  8010c6:	78 11                	js     8010d9 <iscons+0x2d>
    return r;
  return fd->fd_dev_id == devcons.dev_id;
  8010c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010cb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8010d1:	39 10                	cmp    %edx,(%eax)
  8010d3:	0f 94 c0             	sete   %al
  8010d6:	0f b6 c0             	movzbl %al,%eax
}
  8010d9:	c9                   	leave  
  8010da:	c3                   	ret    

008010db <opencons>:

int
opencons(void)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	83 ec 28             	sub    $0x28,%esp
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
  8010e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e4:	89 04 24             	mov    %eax,(%esp)
  8010e7:	e8 1b f3 ff ff       	call   800407 <fd_alloc>
    return r;
  8010ec:	89 c2                	mov    %eax,%edx
opencons(void)
{
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
  8010ee:	85 c0                	test   %eax,%eax
  8010f0:	78 40                	js     801132 <opencons+0x57>
    return r;
  if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8010f2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8010f9:	00 
  8010fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801101:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801108:	e8 63 f0 ff ff       	call   800170 <sys_page_alloc>
    return r;
  80110d:	89 c2                	mov    %eax,%edx
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
    return r;
  if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80110f:	85 c0                	test   %eax,%eax
  801111:	78 1f                	js     801132 <opencons+0x57>
    return r;
  fd->fd_dev_id = devcons.dev_id;
  801113:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801119:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80111c:	89 10                	mov    %edx,(%eax)
  fd->fd_omode = O_RDWR;
  80111e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801121:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
  return fd2num(fd);
  801128:	89 04 24             	mov    %eax,(%esp)
  80112b:	e8 b0 f2 ff ff       	call   8003e0 <fd2num>
  801130:	89 c2                	mov    %eax,%edx
}
  801132:	89 d0                	mov    %edx,%eax
  801134:	c9                   	leave  
  801135:	c3                   	ret    

00801136 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	56                   	push   %esi
  80113a:	53                   	push   %ebx
  80113b:	83 ec 20             	sub    $0x20,%esp
  va_list ap;

  va_start(ap, fmt);
  80113e:	8d 5d 14             	lea    0x14(%ebp),%ebx

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  801141:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801147:	e8 e6 ef ff ff       	call   800132 <sys_getenvid>
  80114c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80114f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801153:	8b 55 08             	mov    0x8(%ebp),%edx
  801156:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80115a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80115e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801162:	c7 04 24 90 20 80 00 	movl   $0x802090,(%esp)
  801169:	e8 c1 00 00 00       	call   80122f <cprintf>
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  80116e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801172:	8b 45 10             	mov    0x10(%ebp),%eax
  801175:	89 04 24             	mov    %eax,(%esp)
  801178:	e8 51 00 00 00       	call   8011ce <vcprintf>
  cprintf("\n");
  80117d:	c7 04 24 7c 20 80 00 	movl   $0x80207c,(%esp)
  801184:	e8 a6 00 00 00       	call   80122f <cprintf>

  // Cause a breakpoint exception
  while (1)
    asm volatile ("int3");
  801189:	cc                   	int3   
  80118a:	eb fd                	jmp    801189 <_panic+0x53>

0080118c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80118c:	55                   	push   %ebp
  80118d:	89 e5                	mov    %esp,%ebp
  80118f:	53                   	push   %ebx
  801190:	83 ec 14             	sub    $0x14,%esp
  801193:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  b->buf[b->idx++] = ch;
  801196:	8b 13                	mov    (%ebx),%edx
  801198:	8d 42 01             	lea    0x1(%edx),%eax
  80119b:	89 03                	mov    %eax,(%ebx)
  80119d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
  if (b->idx == 256-1) {
  8011a4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8011a9:	75 19                	jne    8011c4 <putch+0x38>
    sys_cputs(b->buf, b->idx);
  8011ab:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8011b2:	00 
  8011b3:	8d 43 08             	lea    0x8(%ebx),%eax
  8011b6:	89 04 24             	mov    %eax,(%esp)
  8011b9:	e8 e5 ee ff ff       	call   8000a3 <sys_cputs>
    b->idx = 0;
  8011be:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  }
  b->cnt++;
  8011c4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8011c8:	83 c4 14             	add    $0x14,%esp
  8011cb:	5b                   	pop    %ebx
  8011cc:	5d                   	pop    %ebp
  8011cd:	c3                   	ret    

008011ce <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
  8011d1:	81 ec 28 01 00 00    	sub    $0x128,%esp
  struct printbuf b;

  b.idx = 0;
  8011d7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8011de:	00 00 00 
  b.cnt = 0;
  8011e1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8011e8:	00 00 00 
  vprintfmt((void*)putch, &b, fmt, ap);
  8011eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011f9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8011ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801203:	c7 04 24 8c 11 80 00 	movl   $0x80118c,(%esp)
  80120a:	e8 af 01 00 00       	call   8013be <vprintfmt>
  sys_cputs(b.buf, b.idx);
  80120f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801215:	89 44 24 04          	mov    %eax,0x4(%esp)
  801219:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80121f:	89 04 24             	mov    %eax,(%esp)
  801222:	e8 7c ee ff ff       	call   8000a3 <sys_cputs>

  return b.cnt;
}
  801227:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80122d:	c9                   	leave  
  80122e:	c3                   	ret    

0080122f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80122f:	55                   	push   %ebp
  801230:	89 e5                	mov    %esp,%ebp
  801232:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  801235:	8d 45 0c             	lea    0xc(%ebp),%eax
  cnt = vcprintf(fmt, ap);
  801238:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123c:	8b 45 08             	mov    0x8(%ebp),%eax
  80123f:	89 04 24             	mov    %eax,(%esp)
  801242:	e8 87 ff ff ff       	call   8011ce <vcprintf>
  va_end(ap);

  return cnt;
}
  801247:	c9                   	leave  
  801248:	c3                   	ret    
  801249:	66 90                	xchg   %ax,%ax
  80124b:	66 90                	xchg   %ax,%ax
  80124d:	66 90                	xchg   %ax,%ax
  80124f:	90                   	nop

00801250 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
         unsigned long long num, unsigned base, int width, int padc)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	57                   	push   %edi
  801254:	56                   	push   %esi
  801255:	53                   	push   %ebx
  801256:	83 ec 3c             	sub    $0x3c,%esp
  801259:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80125c:	89 d7                	mov    %edx,%edi
  80125e:	8b 45 08             	mov    0x8(%ebp),%eax
  801261:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801264:	8b 45 0c             	mov    0xc(%ebp),%eax
  801267:	89 c3                	mov    %eax,%ebx
  801269:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80126c:	8b 45 10             	mov    0x10(%ebp),%eax
  80126f:	8b 75 14             	mov    0x14(%ebp),%esi
  // first recursively print all preceding (more significant) digits
  if (num >= base)
  801272:	b9 00 00 00 00       	mov    $0x0,%ecx
  801277:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80127a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80127d:	39 d9                	cmp    %ebx,%ecx
  80127f:	72 05                	jb     801286 <printnum+0x36>
  801281:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  801284:	77 69                	ja     8012ef <printnum+0x9f>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  801286:	8b 4d 18             	mov    0x18(%ebp),%ecx
  801289:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80128d:	83 ee 01             	sub    $0x1,%esi
  801290:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801294:	89 44 24 08          	mov    %eax,0x8(%esp)
  801298:	8b 44 24 08          	mov    0x8(%esp),%eax
  80129c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8012a0:	89 c3                	mov    %eax,%ebx
  8012a2:	89 d6                	mov    %edx,%esi
  8012a4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8012a7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8012aa:	89 54 24 08          	mov    %edx,0x8(%esp)
  8012ae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8012b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012b5:	89 04 24             	mov    %eax,(%esp)
  8012b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8012bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012bf:	e8 4c 0a 00 00       	call   801d10 <__udivdi3>
  8012c4:	89 d9                	mov    %ebx,%ecx
  8012c6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012ca:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012ce:	89 04 24             	mov    %eax,(%esp)
  8012d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012d5:	89 fa                	mov    %edi,%edx
  8012d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012da:	e8 71 ff ff ff       	call   801250 <printnum>
  8012df:	eb 1b                	jmp    8012fc <printnum+0xac>
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
      putch(padc, putdat);
  8012e1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012e5:	8b 45 18             	mov    0x18(%ebp),%eax
  8012e8:	89 04 24             	mov    %eax,(%esp)
  8012eb:	ff d3                	call   *%ebx
  8012ed:	eb 03                	jmp    8012f2 <printnum+0xa2>
  8012ef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  // first recursively print all preceding (more significant) digits
  if (num >= base)
    printnum(putch, putdat, num / base, base, width - 1, padc);
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
  8012f2:	83 ee 01             	sub    $0x1,%esi
  8012f5:	85 f6                	test   %esi,%esi
  8012f7:	7f e8                	jg     8012e1 <printnum+0x91>
  8012f9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
      putch(padc, putdat);
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8012fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801300:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801304:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801307:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80130a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80130e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801312:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801315:	89 04 24             	mov    %eax,(%esp)
  801318:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80131b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131f:	e8 1c 0b 00 00       	call   801e40 <__umoddi3>
  801324:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801328:	0f be 80 b3 20 80 00 	movsbl 0x8020b3(%eax),%eax
  80132f:	89 04 24             	mov    %eax,(%esp)
  801332:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801335:	ff d0                	call   *%eax
}
  801337:	83 c4 3c             	add    $0x3c,%esp
  80133a:	5b                   	pop    %ebx
  80133b:	5e                   	pop    %esi
  80133c:	5f                   	pop    %edi
  80133d:	5d                   	pop    %ebp
  80133e:	c3                   	ret    

0080133f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80133f:	55                   	push   %ebp
  801340:	89 e5                	mov    %esp,%ebp
  if (lflag >= 2)
  801342:	83 fa 01             	cmp    $0x1,%edx
  801345:	7e 0e                	jle    801355 <getuint+0x16>
    return va_arg(*ap, unsigned long long);
  801347:	8b 10                	mov    (%eax),%edx
  801349:	8d 4a 08             	lea    0x8(%edx),%ecx
  80134c:	89 08                	mov    %ecx,(%eax)
  80134e:	8b 02                	mov    (%edx),%eax
  801350:	8b 52 04             	mov    0x4(%edx),%edx
  801353:	eb 22                	jmp    801377 <getuint+0x38>
  else if (lflag)
  801355:	85 d2                	test   %edx,%edx
  801357:	74 10                	je     801369 <getuint+0x2a>
    return va_arg(*ap, unsigned long);
  801359:	8b 10                	mov    (%eax),%edx
  80135b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80135e:	89 08                	mov    %ecx,(%eax)
  801360:	8b 02                	mov    (%edx),%eax
  801362:	ba 00 00 00 00       	mov    $0x0,%edx
  801367:	eb 0e                	jmp    801377 <getuint+0x38>
  else
    return va_arg(*ap, unsigned int);
  801369:	8b 10                	mov    (%eax),%edx
  80136b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80136e:	89 08                	mov    %ecx,(%eax)
  801370:	8b 02                	mov    (%edx),%eax
  801372:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801377:	5d                   	pop    %ebp
  801378:	c3                   	ret    

00801379 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801379:	55                   	push   %ebp
  80137a:	89 e5                	mov    %esp,%ebp
  80137c:	8b 45 0c             	mov    0xc(%ebp),%eax
  b->cnt++;
  80137f:	83 40 08 01          	addl   $0x1,0x8(%eax)
  if (b->buf < b->ebuf)
  801383:	8b 10                	mov    (%eax),%edx
  801385:	3b 50 04             	cmp    0x4(%eax),%edx
  801388:	73 0a                	jae    801394 <sprintputch+0x1b>
    *b->buf++ = ch;
  80138a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80138d:	89 08                	mov    %ecx,(%eax)
  80138f:	8b 45 08             	mov    0x8(%ebp),%eax
  801392:	88 02                	mov    %al,(%edx)
}
  801394:	5d                   	pop    %ebp
  801395:	c3                   	ret    

00801396 <printfmt>:
  }
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801396:	55                   	push   %ebp
  801397:	89 e5                	mov    %esp,%ebp
  801399:	83 ec 18             	sub    $0x18,%esp
  va_list ap;

  va_start(ap, fmt);
  80139c:	8d 45 14             	lea    0x14(%ebp),%eax
  vprintfmt(putch, putdat, fmt, ap);
  80139f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8013a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b4:	89 04 24             	mov    %eax,(%esp)
  8013b7:	e8 02 00 00 00       	call   8013be <vprintfmt>
  va_end(ap);
}
  8013bc:	c9                   	leave  
  8013bd:	c3                   	ret    

008013be <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8013be:	55                   	push   %ebp
  8013bf:	89 e5                	mov    %esp,%ebp
  8013c1:	57                   	push   %edi
  8013c2:	56                   	push   %esi
  8013c3:	53                   	push   %ebx
  8013c4:	83 ec 3c             	sub    $0x3c,%esp
  8013c7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8013ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013cd:	eb 14                	jmp    8013e3 <vprintfmt+0x25>
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
      if (ch == '\0')
  8013cf:	85 c0                	test   %eax,%eax
  8013d1:	0f 84 b3 03 00 00    	je     80178a <vprintfmt+0x3cc>
        return;
      putch(ch, putdat);
  8013d7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013db:	89 04 24             	mov    %eax,(%esp)
  8013de:	ff 55 08             	call   *0x8(%ebp)
  unsigned long long num;
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
  8013e1:	89 f3                	mov    %esi,%ebx
  8013e3:	8d 73 01             	lea    0x1(%ebx),%esi
  8013e6:	0f b6 03             	movzbl (%ebx),%eax
  8013e9:	83 f8 25             	cmp    $0x25,%eax
  8013ec:	75 e1                	jne    8013cf <vprintfmt+0x11>
  8013ee:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8013f2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8013f9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801400:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  801407:	ba 00 00 00 00       	mov    $0x0,%edx
  80140c:	eb 1d                	jmp    80142b <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80140e:	89 de                	mov    %ebx,%esi

    // flag to pad on the right
    case '-':
      padc = '-';
  801410:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  801414:	eb 15                	jmp    80142b <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  801416:	89 de                	mov    %ebx,%esi
      padc = '-';
      goto reswitch;

    // flag to pad with 0's instead of spaces
    case '0':
      padc = '0';
  801418:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80141c:	eb 0d                	jmp    80142b <vprintfmt+0x6d>
      altflag = 1;
      goto reswitch;

process_precision:
      if (width < 0)
        width = precision, precision = -1;
  80141e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801421:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801424:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80142b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80142e:	0f b6 0e             	movzbl (%esi),%ecx
  801431:	0f b6 c1             	movzbl %cl,%eax
  801434:	83 e9 23             	sub    $0x23,%ecx
  801437:	80 f9 55             	cmp    $0x55,%cl
  80143a:	0f 87 2a 03 00 00    	ja     80176a <vprintfmt+0x3ac>
  801440:	0f b6 c9             	movzbl %cl,%ecx
  801443:	ff 24 8d 00 22 80 00 	jmp    *0x802200(,%ecx,4)
  80144a:	89 de                	mov    %ebx,%esi
  80144c:	b9 00 00 00 00       	mov    $0x0,%ecx
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
        precision = precision * 10 + ch - '0';
  801451:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  801454:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
        ch = *fmt;
  801458:	0f be 06             	movsbl (%esi),%eax
        if (ch < '0' || ch > '9')
  80145b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80145e:	83 fb 09             	cmp    $0x9,%ebx
  801461:	77 36                	ja     801499 <vprintfmt+0xdb>
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
  801463:	83 c6 01             	add    $0x1,%esi
        precision = precision * 10 + ch - '0';
        ch = *fmt;
        if (ch < '0' || ch > '9')
          break;
      }
  801466:	eb e9                	jmp    801451 <vprintfmt+0x93>
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
  801468:	8b 45 14             	mov    0x14(%ebp),%eax
  80146b:	8d 48 04             	lea    0x4(%eax),%ecx
  80146e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801471:	8b 00                	mov    (%eax),%eax
  801473:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  801476:	89 de                	mov    %ebx,%esi
      }
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
      goto process_precision;
  801478:	eb 22                	jmp    80149c <vprintfmt+0xde>
  80147a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80147d:	85 c9                	test   %ecx,%ecx
  80147f:	b8 00 00 00 00       	mov    $0x0,%eax
  801484:	0f 49 c1             	cmovns %ecx,%eax
  801487:	89 45 dc             	mov    %eax,-0x24(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80148a:	89 de                	mov    %ebx,%esi
  80148c:	eb 9d                	jmp    80142b <vprintfmt+0x6d>
  80148e:	89 de                	mov    %ebx,%esi
      if (width < 0)
        width = 0;
      goto reswitch;

    case '#':
      altflag = 1;
  801490:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
      goto reswitch;
  801497:	eb 92                	jmp    80142b <vprintfmt+0x6d>
  801499:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

process_precision:
      if (width < 0)
  80149c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8014a0:	79 89                	jns    80142b <vprintfmt+0x6d>
  8014a2:	e9 77 ff ff ff       	jmp    80141e <vprintfmt+0x60>
        width = precision, precision = -1;
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
  8014a7:	83 c2 01             	add    $0x1,%edx
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8014aa:	89 de                	mov    %ebx,%esi
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
      goto reswitch;
  8014ac:	e9 7a ff ff ff       	jmp    80142b <vprintfmt+0x6d>

    // character
    case 'c':
      putch(va_arg(ap, int), putdat);
  8014b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b4:	8d 50 04             	lea    0x4(%eax),%edx
  8014b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8014ba:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014be:	8b 00                	mov    (%eax),%eax
  8014c0:	89 04 24             	mov    %eax,(%esp)
  8014c3:	ff 55 08             	call   *0x8(%ebp)
      break;
  8014c6:	e9 18 ff ff ff       	jmp    8013e3 <vprintfmt+0x25>

    // error message
    case 'e':
      err = va_arg(ap, int);
  8014cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ce:	8d 50 04             	lea    0x4(%eax),%edx
  8014d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8014d4:	8b 00                	mov    (%eax),%eax
  8014d6:	99                   	cltd   
  8014d7:	31 d0                	xor    %edx,%eax
  8014d9:	29 d0                	sub    %edx,%eax
      if (err < 0)
        err = -err;
      if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8014db:	83 f8 0f             	cmp    $0xf,%eax
  8014de:	7f 0b                	jg     8014eb <vprintfmt+0x12d>
  8014e0:	8b 14 85 60 23 80 00 	mov    0x802360(,%eax,4),%edx
  8014e7:	85 d2                	test   %edx,%edx
  8014e9:	75 20                	jne    80150b <vprintfmt+0x14d>
        printfmt(putch, putdat, "error %d", err);
  8014eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014ef:	c7 44 24 08 cb 20 80 	movl   $0x8020cb,0x8(%esp)
  8014f6:	00 
  8014f7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fe:	89 04 24             	mov    %eax,(%esp)
  801501:	e8 90 fe ff ff       	call   801396 <printfmt>
  801506:	e9 d8 fe ff ff       	jmp    8013e3 <vprintfmt+0x25>
      else
        printfmt(putch, putdat, "%s", p);
  80150b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80150f:	c7 44 24 08 d4 20 80 	movl   $0x8020d4,0x8(%esp)
  801516:	00 
  801517:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80151b:	8b 45 08             	mov    0x8(%ebp),%eax
  80151e:	89 04 24             	mov    %eax,(%esp)
  801521:	e8 70 fe ff ff       	call   801396 <printfmt>
  801526:	e9 b8 fe ff ff       	jmp    8013e3 <vprintfmt+0x25>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80152b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80152e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801531:	89 45 d0             	mov    %eax,-0x30(%ebp)
        printfmt(putch, putdat, "%s", p);
      break;

    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
  801534:	8b 45 14             	mov    0x14(%ebp),%eax
  801537:	8d 50 04             	lea    0x4(%eax),%edx
  80153a:	89 55 14             	mov    %edx,0x14(%ebp)
  80153d:	8b 30                	mov    (%eax),%esi
        p = "(null)";
  80153f:	85 f6                	test   %esi,%esi
  801541:	b8 c4 20 80 00       	mov    $0x8020c4,%eax
  801546:	0f 44 f0             	cmove  %eax,%esi
      if (width > 0 && padc != '-')
  801549:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80154d:	0f 84 97 00 00 00    	je     8015ea <vprintfmt+0x22c>
  801553:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  801557:	0f 8e 9b 00 00 00    	jle    8015f8 <vprintfmt+0x23a>
        for (width -= strnlen(p, precision); width > 0; width--)
  80155d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801561:	89 34 24             	mov    %esi,(%esp)
  801564:	e8 cf 02 00 00       	call   801838 <strnlen>
  801569:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80156c:	29 c2                	sub    %eax,%edx
  80156e:	89 55 d0             	mov    %edx,-0x30(%ebp)
          putch(padc, putdat);
  801571:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801575:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801578:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80157b:	8b 75 08             	mov    0x8(%ebp),%esi
  80157e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801581:	89 d3                	mov    %edx,%ebx
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
  801583:	eb 0f                	jmp    801594 <vprintfmt+0x1d6>
          putch(padc, putdat);
  801585:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801589:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80158c:	89 04 24             	mov    %eax,(%esp)
  80158f:	ff d6                	call   *%esi
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
  801591:	83 eb 01             	sub    $0x1,%ebx
  801594:	85 db                	test   %ebx,%ebx
  801596:	7f ed                	jg     801585 <vprintfmt+0x1c7>
  801598:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80159b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80159e:	85 d2                	test   %edx,%edx
  8015a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8015a5:	0f 49 c2             	cmovns %edx,%eax
  8015a8:	29 c2                	sub    %eax,%edx
  8015aa:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8015ad:	89 d7                	mov    %edx,%edi
  8015af:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8015b2:	eb 50                	jmp    801604 <vprintfmt+0x246>
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
  8015b4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8015b8:	74 1e                	je     8015d8 <vprintfmt+0x21a>
  8015ba:	0f be d2             	movsbl %dl,%edx
  8015bd:	83 ea 20             	sub    $0x20,%edx
  8015c0:	83 fa 5e             	cmp    $0x5e,%edx
  8015c3:	76 13                	jbe    8015d8 <vprintfmt+0x21a>
          putch('?', putdat);
  8015c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015cc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8015d3:	ff 55 08             	call   *0x8(%ebp)
  8015d6:	eb 0d                	jmp    8015e5 <vprintfmt+0x227>
        else
          putch(ch, putdat);
  8015d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015db:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015df:	89 04 24             	mov    %eax,(%esp)
  8015e2:	ff 55 08             	call   *0x8(%ebp)
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8015e5:	83 ef 01             	sub    $0x1,%edi
  8015e8:	eb 1a                	jmp    801604 <vprintfmt+0x246>
  8015ea:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8015ed:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8015f0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8015f3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8015f6:	eb 0c                	jmp    801604 <vprintfmt+0x246>
  8015f8:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8015fb:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8015fe:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801601:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801604:	83 c6 01             	add    $0x1,%esi
  801607:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80160b:	0f be c2             	movsbl %dl,%eax
  80160e:	85 c0                	test   %eax,%eax
  801610:	74 27                	je     801639 <vprintfmt+0x27b>
  801612:	85 db                	test   %ebx,%ebx
  801614:	78 9e                	js     8015b4 <vprintfmt+0x1f6>
  801616:	83 eb 01             	sub    $0x1,%ebx
  801619:	79 99                	jns    8015b4 <vprintfmt+0x1f6>
  80161b:	89 f8                	mov    %edi,%eax
  80161d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801620:	8b 75 08             	mov    0x8(%ebp),%esi
  801623:	89 c3                	mov    %eax,%ebx
  801625:	eb 1a                	jmp    801641 <vprintfmt+0x283>
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
        putch(' ', putdat);
  801627:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80162b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801632:	ff d6                	call   *%esi
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
  801634:	83 eb 01             	sub    $0x1,%ebx
  801637:	eb 08                	jmp    801641 <vprintfmt+0x283>
  801639:	89 fb                	mov    %edi,%ebx
  80163b:	8b 75 08             	mov    0x8(%ebp),%esi
  80163e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801641:	85 db                	test   %ebx,%ebx
  801643:	7f e2                	jg     801627 <vprintfmt+0x269>
  801645:	89 75 08             	mov    %esi,0x8(%ebp)
  801648:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80164b:	e9 93 fd ff ff       	jmp    8013e3 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  if (lflag >= 2)
  801650:	83 fa 01             	cmp    $0x1,%edx
  801653:	7e 16                	jle    80166b <vprintfmt+0x2ad>
    return va_arg(*ap, long long);
  801655:	8b 45 14             	mov    0x14(%ebp),%eax
  801658:	8d 50 08             	lea    0x8(%eax),%edx
  80165b:	89 55 14             	mov    %edx,0x14(%ebp)
  80165e:	8b 50 04             	mov    0x4(%eax),%edx
  801661:	8b 00                	mov    (%eax),%eax
  801663:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801666:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801669:	eb 32                	jmp    80169d <vprintfmt+0x2df>
  else if (lflag)
  80166b:	85 d2                	test   %edx,%edx
  80166d:	74 18                	je     801687 <vprintfmt+0x2c9>
    return va_arg(*ap, long);
  80166f:	8b 45 14             	mov    0x14(%ebp),%eax
  801672:	8d 50 04             	lea    0x4(%eax),%edx
  801675:	89 55 14             	mov    %edx,0x14(%ebp)
  801678:	8b 30                	mov    (%eax),%esi
  80167a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80167d:	89 f0                	mov    %esi,%eax
  80167f:	c1 f8 1f             	sar    $0x1f,%eax
  801682:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801685:	eb 16                	jmp    80169d <vprintfmt+0x2df>
  else
    return va_arg(*ap, int);
  801687:	8b 45 14             	mov    0x14(%ebp),%eax
  80168a:	8d 50 04             	lea    0x4(%eax),%edx
  80168d:	89 55 14             	mov    %edx,0x14(%ebp)
  801690:	8b 30                	mov    (%eax),%esi
  801692:	89 75 e0             	mov    %esi,-0x20(%ebp)
  801695:	89 f0                	mov    %esi,%eax
  801697:	c1 f8 1f             	sar    $0x1f,%eax
  80169a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        putch(' ', putdat);
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
  80169d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      if ((long long)num < 0) {
        putch('-', putdat);
        num = -(long long)num;
      }
      base = 10;
  8016a3:	b9 0a 00 00 00       	mov    $0xa,%ecx
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
      if ((long long)num < 0) {
  8016a8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8016ac:	0f 89 80 00 00 00    	jns    801732 <vprintfmt+0x374>
        putch('-', putdat);
  8016b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8016b6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8016bd:	ff 55 08             	call   *0x8(%ebp)
        num = -(long long)num;
  8016c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016c3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016c6:	f7 d8                	neg    %eax
  8016c8:	83 d2 00             	adc    $0x0,%edx
  8016cb:	f7 da                	neg    %edx
      }
      base = 10;
  8016cd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8016d2:	eb 5e                	jmp    801732 <vprintfmt+0x374>
      goto number;

    // unsigned decimal
    case 'u':
      num = getuint(&ap, lflag);
  8016d4:	8d 45 14             	lea    0x14(%ebp),%eax
  8016d7:	e8 63 fc ff ff       	call   80133f <getuint>
      base = 10;
  8016dc:	b9 0a 00 00 00       	mov    $0xa,%ecx
      goto number;
  8016e1:	eb 4f                	jmp    801732 <vprintfmt+0x374>

    // (unsigned) octal
    case 'o':
      num = getuint(&ap, lflag);
  8016e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8016e6:	e8 54 fc ff ff       	call   80133f <getuint>
      base = 8;
  8016eb:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  8016f0:	eb 40                	jmp    801732 <vprintfmt+0x374>

    // pointer
    case 'p':
      putch('0', putdat);
  8016f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8016f6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8016fd:	ff 55 08             	call   *0x8(%ebp)
      putch('x', putdat);
  801700:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801704:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80170b:	ff 55 08             	call   *0x8(%ebp)
      num = (unsigned long long)
            (uintptr_t)va_arg(ap, void *);
  80170e:	8b 45 14             	mov    0x14(%ebp),%eax
  801711:	8d 50 04             	lea    0x4(%eax),%edx
  801714:	89 55 14             	mov    %edx,0x14(%ebp)

    // pointer
    case 'p':
      putch('0', putdat);
      putch('x', putdat);
      num = (unsigned long long)
  801717:	8b 00                	mov    (%eax),%eax
  801719:	ba 00 00 00 00       	mov    $0x0,%edx
            (uintptr_t)va_arg(ap, void *);
      base = 16;
  80171e:	b9 10 00 00 00       	mov    $0x10,%ecx
      goto number;
  801723:	eb 0d                	jmp    801732 <vprintfmt+0x374>

    // (unsigned) hexadecimal
    case 'x':
      num = getuint(&ap, lflag);
  801725:	8d 45 14             	lea    0x14(%ebp),%eax
  801728:	e8 12 fc ff ff       	call   80133f <getuint>
      base = 16;
  80172d:	b9 10 00 00 00       	mov    $0x10,%ecx
number:
      printnum(putch, putdat, num, base, width, padc);
  801732:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  801736:	89 74 24 10          	mov    %esi,0x10(%esp)
  80173a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80173d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801741:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801745:	89 04 24             	mov    %eax,(%esp)
  801748:	89 54 24 04          	mov    %edx,0x4(%esp)
  80174c:	89 fa                	mov    %edi,%edx
  80174e:	8b 45 08             	mov    0x8(%ebp),%eax
  801751:	e8 fa fa ff ff       	call   801250 <printnum>
      break;
  801756:	e9 88 fc ff ff       	jmp    8013e3 <vprintfmt+0x25>

    // escaped '%' character
    case '%':
      putch(ch, putdat);
  80175b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80175f:	89 04 24             	mov    %eax,(%esp)
  801762:	ff 55 08             	call   *0x8(%ebp)
      break;
  801765:	e9 79 fc ff ff       	jmp    8013e3 <vprintfmt+0x25>

    // unrecognized escape sequence - just print it literally
    default:
      putch('%', putdat);
  80176a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80176e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801775:	ff 55 08             	call   *0x8(%ebp)
      for (fmt--; fmt[-1] != '%'; fmt--)
  801778:	89 f3                	mov    %esi,%ebx
  80177a:	eb 03                	jmp    80177f <vprintfmt+0x3c1>
  80177c:	83 eb 01             	sub    $0x1,%ebx
  80177f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  801783:	75 f7                	jne    80177c <vprintfmt+0x3be>
  801785:	e9 59 fc ff ff       	jmp    8013e3 <vprintfmt+0x25>
        /* do nothing */;
      break;
    }
  }
}
  80178a:	83 c4 3c             	add    $0x3c,%esp
  80178d:	5b                   	pop    %ebx
  80178e:	5e                   	pop    %esi
  80178f:	5f                   	pop    %edi
  801790:	5d                   	pop    %ebp
  801791:	c3                   	ret    

00801792 <vsnprintf>:
    *b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801792:	55                   	push   %ebp
  801793:	89 e5                	mov    %esp,%ebp
  801795:	83 ec 28             	sub    $0x28,%esp
  801798:	8b 45 08             	mov    0x8(%ebp),%eax
  80179b:	8b 55 0c             	mov    0xc(%ebp),%edx
  struct sprintbuf b = { buf, buf+n-1, 0 };
  80179e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8017a1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8017a5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8017a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  if (buf == NULL || n < 1)
  8017af:	85 c0                	test   %eax,%eax
  8017b1:	74 30                	je     8017e3 <vsnprintf+0x51>
  8017b3:	85 d2                	test   %edx,%edx
  8017b5:	7e 2c                	jle    8017e3 <vsnprintf+0x51>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void*)sprintputch, &b, fmt, ap);
  8017b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8017ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017be:	8b 45 10             	mov    0x10(%ebp),%eax
  8017c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017c5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8017c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017cc:	c7 04 24 79 13 80 00 	movl   $0x801379,(%esp)
  8017d3:	e8 e6 fb ff ff       	call   8013be <vprintfmt>

  // null terminate the buffer
  *b.buf = '\0';
  8017d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8017db:	c6 00 00             	movb   $0x0,(%eax)

  return b.cnt;
  8017de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e1:	eb 05                	jmp    8017e8 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  struct sprintbuf b = { buf, buf+n-1, 0 };

  if (buf == NULL || n < 1)
    return -E_INVAL;
  8017e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

  // null terminate the buffer
  *b.buf = '\0';

  return b.cnt;
}
  8017e8:	c9                   	leave  
  8017e9:	c3                   	ret    

008017ea <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8017ea:	55                   	push   %ebp
  8017eb:	89 e5                	mov    %esp,%ebp
  8017ed:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int rc;

  va_start(ap, fmt);
  8017f0:	8d 45 14             	lea    0x14(%ebp),%eax
  rc = vsnprintf(buf, n, fmt, ap);
  8017f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8017fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801801:	89 44 24 04          	mov    %eax,0x4(%esp)
  801805:	8b 45 08             	mov    0x8(%ebp),%eax
  801808:	89 04 24             	mov    %eax,(%esp)
  80180b:	e8 82 ff ff ff       	call   801792 <vsnprintf>
  va_end(ap);

  return rc;
}
  801810:	c9                   	leave  
  801811:	c3                   	ret    
  801812:	66 90                	xchg   %ax,%ax
  801814:	66 90                	xchg   %ax,%ax
  801816:	66 90                	xchg   %ax,%ax
  801818:	66 90                	xchg   %ax,%ax
  80181a:	66 90                	xchg   %ax,%ax
  80181c:	66 90                	xchg   %ax,%ax
  80181e:	66 90                	xchg   %ax,%ax

00801820 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for (n = 0; *s != '\0'; s++)
  801826:	b8 00 00 00 00       	mov    $0x0,%eax
  80182b:	eb 03                	jmp    801830 <strlen+0x10>
    n++;
  80182d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
  int n;

  for (n = 0; *s != '\0'; s++)
  801830:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801834:	75 f7                	jne    80182d <strlen+0xd>
    n++;
  return n;
}
  801836:	5d                   	pop    %ebp
  801837:	c3                   	ret    

00801838 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801838:	55                   	push   %ebp
  801839:	89 e5                	mov    %esp,%ebp
  80183b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80183e:	8b 55 0c             	mov    0xc(%ebp),%edx
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801841:	b8 00 00 00 00       	mov    $0x0,%eax
  801846:	eb 03                	jmp    80184b <strnlen+0x13>
    n++;
  801848:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80184b:	39 d0                	cmp    %edx,%eax
  80184d:	74 06                	je     801855 <strnlen+0x1d>
  80184f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801853:	75 f3                	jne    801848 <strnlen+0x10>
    n++;
  return n;
}
  801855:	5d                   	pop    %ebp
  801856:	c3                   	ret    

00801857 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	53                   	push   %ebx
  80185b:	8b 45 08             	mov    0x8(%ebp),%eax
  80185e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  801861:	89 c2                	mov    %eax,%edx
  801863:	83 c2 01             	add    $0x1,%edx
  801866:	83 c1 01             	add    $0x1,%ecx
  801869:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80186d:	88 5a ff             	mov    %bl,-0x1(%edx)
  801870:	84 db                	test   %bl,%bl
  801872:	75 ef                	jne    801863 <strcpy+0xc>
    /* do nothing */;
  return ret;
}
  801874:	5b                   	pop    %ebx
  801875:	5d                   	pop    %ebp
  801876:	c3                   	ret    

00801877 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801877:	55                   	push   %ebp
  801878:	89 e5                	mov    %esp,%ebp
  80187a:	53                   	push   %ebx
  80187b:	83 ec 08             	sub    $0x8,%esp
  80187e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int len = strlen(dst);
  801881:	89 1c 24             	mov    %ebx,(%esp)
  801884:	e8 97 ff ff ff       	call   801820 <strlen>

  strcpy(dst + len, src);
  801889:	8b 55 0c             	mov    0xc(%ebp),%edx
  80188c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801890:	01 d8                	add    %ebx,%eax
  801892:	89 04 24             	mov    %eax,(%esp)
  801895:	e8 bd ff ff ff       	call   801857 <strcpy>
  return dst;
}
  80189a:	89 d8                	mov    %ebx,%eax
  80189c:	83 c4 08             	add    $0x8,%esp
  80189f:	5b                   	pop    %ebx
  8018a0:	5d                   	pop    %ebp
  8018a1:	c3                   	ret    

008018a2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  8018a2:	55                   	push   %ebp
  8018a3:	89 e5                	mov    %esp,%ebp
  8018a5:	56                   	push   %esi
  8018a6:	53                   	push   %ebx
  8018a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8018aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018ad:	89 f3                	mov    %esi,%ebx
  8018af:	03 5d 10             	add    0x10(%ebp),%ebx
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  8018b2:	89 f2                	mov    %esi,%edx
  8018b4:	eb 0f                	jmp    8018c5 <strncpy+0x23>
    *dst++ = *src;
  8018b6:	83 c2 01             	add    $0x1,%edx
  8018b9:	0f b6 01             	movzbl (%ecx),%eax
  8018bc:	88 42 ff             	mov    %al,-0x1(%edx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  8018bf:	80 39 01             	cmpb   $0x1,(%ecx)
  8018c2:	83 d9 ff             	sbb    $0xffffffff,%ecx
{
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  8018c5:	39 da                	cmp    %ebx,%edx
  8018c7:	75 ed                	jne    8018b6 <strncpy+0x14>
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  }
  return ret;
}
  8018c9:	89 f0                	mov    %esi,%eax
  8018cb:	5b                   	pop    %ebx
  8018cc:	5e                   	pop    %esi
  8018cd:	5d                   	pop    %ebp
  8018ce:	c3                   	ret    

008018cf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	56                   	push   %esi
  8018d3:	53                   	push   %ebx
  8018d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8018d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018da:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018dd:	89 f0                	mov    %esi,%eax
  8018df:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  8018e3:	85 c9                	test   %ecx,%ecx
  8018e5:	75 0b                	jne    8018f2 <strlcpy+0x23>
  8018e7:	eb 1d                	jmp    801906 <strlcpy+0x37>
    while (--size > 0 && *src != '\0')
      *dst++ = *src++;
  8018e9:	83 c0 01             	add    $0x1,%eax
  8018ec:	83 c2 01             	add    $0x1,%edx
  8018ef:	88 48 ff             	mov    %cl,-0x1(%eax)
{
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
    while (--size > 0 && *src != '\0')
  8018f2:	39 d8                	cmp    %ebx,%eax
  8018f4:	74 0b                	je     801901 <strlcpy+0x32>
  8018f6:	0f b6 0a             	movzbl (%edx),%ecx
  8018f9:	84 c9                	test   %cl,%cl
  8018fb:	75 ec                	jne    8018e9 <strlcpy+0x1a>
  8018fd:	89 c2                	mov    %eax,%edx
  8018ff:	eb 02                	jmp    801903 <strlcpy+0x34>
  801901:	89 c2                	mov    %eax,%edx
      *dst++ = *src++;
    *dst = '\0';
  801903:	c6 02 00             	movb   $0x0,(%edx)
  }
  return dst - dst_in;
  801906:	29 f0                	sub    %esi,%eax
}
  801908:	5b                   	pop    %ebx
  801909:	5e                   	pop    %esi
  80190a:	5d                   	pop    %ebp
  80190b:	c3                   	ret    

0080190c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80190c:	55                   	push   %ebp
  80190d:	89 e5                	mov    %esp,%ebp
  80190f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801912:	8b 55 0c             	mov    0xc(%ebp),%edx
  while (*p && *p == *q)
  801915:	eb 06                	jmp    80191d <strcmp+0x11>
    p++, q++;
  801917:	83 c1 01             	add    $0x1,%ecx
  80191a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
  while (*p && *p == *q)
  80191d:	0f b6 01             	movzbl (%ecx),%eax
  801920:	84 c0                	test   %al,%al
  801922:	74 04                	je     801928 <strcmp+0x1c>
  801924:	3a 02                	cmp    (%edx),%al
  801926:	74 ef                	je     801917 <strcmp+0xb>
    p++, q++;
  return (int)((unsigned char)*p - (unsigned char)*q);
  801928:	0f b6 c0             	movzbl %al,%eax
  80192b:	0f b6 12             	movzbl (%edx),%edx
  80192e:	29 d0                	sub    %edx,%eax
}
  801930:	5d                   	pop    %ebp
  801931:	c3                   	ret    

00801932 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801932:	55                   	push   %ebp
  801933:	89 e5                	mov    %esp,%ebp
  801935:	53                   	push   %ebx
  801936:	8b 45 08             	mov    0x8(%ebp),%eax
  801939:	8b 55 0c             	mov    0xc(%ebp),%edx
  80193c:	89 c3                	mov    %eax,%ebx
  80193e:	03 5d 10             	add    0x10(%ebp),%ebx
  while (n > 0 && *p && *p == *q)
  801941:	eb 06                	jmp    801949 <strncmp+0x17>
    n--, p++, q++;
  801943:	83 c0 01             	add    $0x1,%eax
  801946:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
  801949:	39 d8                	cmp    %ebx,%eax
  80194b:	74 15                	je     801962 <strncmp+0x30>
  80194d:	0f b6 08             	movzbl (%eax),%ecx
  801950:	84 c9                	test   %cl,%cl
  801952:	74 04                	je     801958 <strncmp+0x26>
  801954:	3a 0a                	cmp    (%edx),%cl
  801956:	74 eb                	je     801943 <strncmp+0x11>
    n--, p++, q++;
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  801958:	0f b6 00             	movzbl (%eax),%eax
  80195b:	0f b6 12             	movzbl (%edx),%edx
  80195e:	29 d0                	sub    %edx,%eax
  801960:	eb 05                	jmp    801967 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
    n--, p++, q++;
  if (n == 0)
    return 0;
  801962:	b8 00 00 00 00       	mov    $0x0,%eax
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
}
  801967:	5b                   	pop    %ebx
  801968:	5d                   	pop    %ebp
  801969:	c3                   	ret    

0080196a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80196a:	55                   	push   %ebp
  80196b:	89 e5                	mov    %esp,%ebp
  80196d:	8b 45 08             	mov    0x8(%ebp),%eax
  801970:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
  801974:	eb 07                	jmp    80197d <strchr+0x13>
    if (*s == c)
  801976:	38 ca                	cmp    %cl,%dl
  801978:	74 0f                	je     801989 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  for (; *s; s++)
  80197a:	83 c0 01             	add    $0x1,%eax
  80197d:	0f b6 10             	movzbl (%eax),%edx
  801980:	84 d2                	test   %dl,%dl
  801982:	75 f2                	jne    801976 <strchr+0xc>
    if (*s == c)
      return (char*)s;
  return 0;
  801984:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801989:	5d                   	pop    %ebp
  80198a:	c3                   	ret    

0080198b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80198b:	55                   	push   %ebp
  80198c:	89 e5                	mov    %esp,%ebp
  80198e:	8b 45 08             	mov    0x8(%ebp),%eax
  801991:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
  801995:	eb 07                	jmp    80199e <strfind+0x13>
    if (*s == c)
  801997:	38 ca                	cmp    %cl,%dl
  801999:	74 0a                	je     8019a5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  for (; *s; s++)
  80199b:	83 c0 01             	add    $0x1,%eax
  80199e:	0f b6 10             	movzbl (%eax),%edx
  8019a1:	84 d2                	test   %dl,%dl
  8019a3:	75 f2                	jne    801997 <strfind+0xc>
    if (*s == c)
      break;
  return (char*)s;
}
  8019a5:	5d                   	pop    %ebp
  8019a6:	c3                   	ret    

008019a7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8019a7:	55                   	push   %ebp
  8019a8:	89 e5                	mov    %esp,%ebp
  8019aa:	57                   	push   %edi
  8019ab:	56                   	push   %esi
  8019ac:	53                   	push   %ebx
  8019ad:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019b0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *p;

  if (n == 0)
  8019b3:	85 c9                	test   %ecx,%ecx
  8019b5:	74 36                	je     8019ed <memset+0x46>
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
  8019b7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8019bd:	75 28                	jne    8019e7 <memset+0x40>
  8019bf:	f6 c1 03             	test   $0x3,%cl
  8019c2:	75 23                	jne    8019e7 <memset+0x40>
    c &= 0xFF;
  8019c4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
    c = (c<<24)|(c<<16)|(c<<8)|c;
  8019c8:	89 d3                	mov    %edx,%ebx
  8019ca:	c1 e3 08             	shl    $0x8,%ebx
  8019cd:	89 d6                	mov    %edx,%esi
  8019cf:	c1 e6 18             	shl    $0x18,%esi
  8019d2:	89 d0                	mov    %edx,%eax
  8019d4:	c1 e0 10             	shl    $0x10,%eax
  8019d7:	09 f0                	or     %esi,%eax
  8019d9:	09 c2                	or     %eax,%edx
  8019db:	89 d0                	mov    %edx,%eax
  8019dd:	09 d8                	or     %ebx,%eax
    asm volatile ("cld; rep stosl\n"
                  :: "D" (v), "a" (c), "c" (n/4)
  8019df:	c1 e9 02             	shr    $0x2,%ecx
  if (n == 0)
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
    c &= 0xFF;
    c = (c<<24)|(c<<16)|(c<<8)|c;
    asm volatile ("cld; rep stosl\n"
  8019e2:	fc                   	cld    
  8019e3:	f3 ab                	rep stos %eax,%es:(%edi)
  8019e5:	eb 06                	jmp    8019ed <memset+0x46>
                  :: "D" (v), "a" (c), "c" (n/4)
                  : "cc", "memory");
  } else
    asm volatile ("cld; rep stosb\n"
  8019e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ea:	fc                   	cld    
  8019eb:	f3 aa                	rep stos %al,%es:(%edi)
                  :: "D" (v), "a" (c), "c" (n)
                  : "cc", "memory");
  return v;
}
  8019ed:	89 f8                	mov    %edi,%eax
  8019ef:	5b                   	pop    %ebx
  8019f0:	5e                   	pop    %esi
  8019f1:	5f                   	pop    %edi
  8019f2:	5d                   	pop    %ebp
  8019f3:	c3                   	ret    

008019f4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8019f4:	55                   	push   %ebp
  8019f5:	89 e5                	mov    %esp,%ebp
  8019f7:	57                   	push   %edi
  8019f8:	56                   	push   %esi
  8019f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  801a02:	39 c6                	cmp    %eax,%esi
  801a04:	73 35                	jae    801a3b <memmove+0x47>
  801a06:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801a09:	39 d0                	cmp    %edx,%eax
  801a0b:	73 2e                	jae    801a3b <memmove+0x47>
    s += n;
    d += n;
  801a0d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801a10:	89 d6                	mov    %edx,%esi
  801a12:	09 fe                	or     %edi,%esi
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a14:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801a1a:	75 13                	jne    801a2f <memmove+0x3b>
  801a1c:	f6 c1 03             	test   $0x3,%cl
  801a1f:	75 0e                	jne    801a2f <memmove+0x3b>
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801a21:	83 ef 04             	sub    $0x4,%edi
  801a24:	8d 72 fc             	lea    -0x4(%edx),%esi
  801a27:	c1 e9 02             	shr    $0x2,%ecx
  d = dst;
  if (s < d && s + n > d) {
    s += n;
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
  801a2a:	fd                   	std    
  801a2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a2d:	eb 09                	jmp    801a38 <memmove+0x44>
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801a2f:	83 ef 01             	sub    $0x1,%edi
  801a32:	8d 72 ff             	lea    -0x1(%edx),%esi
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
  801a35:	fd                   	std    
  801a36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  801a38:	fc                   	cld    
  801a39:	eb 1d                	jmp    801a58 <memmove+0x64>
  801a3b:	89 f2                	mov    %esi,%edx
  801a3d:	09 c2                	or     %eax,%edx
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a3f:	f6 c2 03             	test   $0x3,%dl
  801a42:	75 0f                	jne    801a53 <memmove+0x5f>
  801a44:	f6 c1 03             	test   $0x3,%cl
  801a47:	75 0a                	jne    801a53 <memmove+0x5f>
      asm volatile ("cld; rep movsl\n"
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801a49:	c1 e9 02             	shr    $0x2,%ecx
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("cld; rep movsl\n"
  801a4c:	89 c7                	mov    %eax,%edi
  801a4e:	fc                   	cld    
  801a4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a51:	eb 05                	jmp    801a58 <memmove+0x64>
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("cld; rep movsb\n"
  801a53:	89 c7                	mov    %eax,%edi
  801a55:	fc                   	cld    
  801a56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d), "S" (s), "c" (n) : "cc", "memory");
  }
  return dst;
}
  801a58:	5e                   	pop    %esi
  801a59:	5f                   	pop    %edi
  801a5a:	5d                   	pop    %ebp
  801a5b:	c3                   	ret    

00801a5c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801a5c:	55                   	push   %ebp
  801a5d:	89 e5                	mov    %esp,%ebp
  801a5f:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
  801a62:	8b 45 10             	mov    0x10(%ebp),%eax
  801a65:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a69:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a70:	8b 45 08             	mov    0x8(%ebp),%eax
  801a73:	89 04 24             	mov    %eax,(%esp)
  801a76:	e8 79 ff ff ff       	call   8019f4 <memmove>
}
  801a7b:	c9                   	leave  
  801a7c:	c3                   	ret    

00801a7d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801a7d:	55                   	push   %ebp
  801a7e:	89 e5                	mov    %esp,%ebp
  801a80:	56                   	push   %esi
  801a81:	53                   	push   %ebx
  801a82:	8b 55 08             	mov    0x8(%ebp),%edx
  801a85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a88:	89 d6                	mov    %edx,%esi
  801a8a:	03 75 10             	add    0x10(%ebp),%esi
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
  801a8d:	eb 1a                	jmp    801aa9 <memcmp+0x2c>
    if (*s1 != *s2)
  801a8f:	0f b6 02             	movzbl (%edx),%eax
  801a92:	0f b6 19             	movzbl (%ecx),%ebx
  801a95:	38 d8                	cmp    %bl,%al
  801a97:	74 0a                	je     801aa3 <memcmp+0x26>
      return (int)*s1 - (int)*s2;
  801a99:	0f b6 c0             	movzbl %al,%eax
  801a9c:	0f b6 db             	movzbl %bl,%ebx
  801a9f:	29 d8                	sub    %ebx,%eax
  801aa1:	eb 0f                	jmp    801ab2 <memcmp+0x35>
    s1++, s2++;
  801aa3:	83 c2 01             	add    $0x1,%edx
  801aa6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
  801aa9:	39 f2                	cmp    %esi,%edx
  801aab:	75 e2                	jne    801a8f <memcmp+0x12>
    if (*s1 != *s2)
      return (int)*s1 - (int)*s2;
    s1++, s2++;
  }

  return 0;
  801aad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ab2:	5b                   	pop    %ebx
  801ab3:	5e                   	pop    %esi
  801ab4:	5d                   	pop    %ebp
  801ab5:	c3                   	ret    

00801ab6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801ab6:	55                   	push   %ebp
  801ab7:	89 e5                	mov    %esp,%ebp
  801ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  801abc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  const void *ends = (const char*)s + n;
  801abf:	89 c2                	mov    %eax,%edx
  801ac1:	03 55 10             	add    0x10(%ebp),%edx

  for (; s < ends; s++)
  801ac4:	eb 07                	jmp    801acd <memfind+0x17>
    if (*(const unsigned char*)s == (unsigned char)c)
  801ac6:	38 08                	cmp    %cl,(%eax)
  801ac8:	74 07                	je     801ad1 <memfind+0x1b>
void *
memfind(const void *s, int c, size_t n)
{
  const void *ends = (const char*)s + n;

  for (; s < ends; s++)
  801aca:	83 c0 01             	add    $0x1,%eax
  801acd:	39 d0                	cmp    %edx,%eax
  801acf:	72 f5                	jb     801ac6 <memfind+0x10>
    if (*(const unsigned char*)s == (unsigned char)c)
      break;
  return (void*)s;
}
  801ad1:	5d                   	pop    %ebp
  801ad2:	c3                   	ret    

00801ad3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801ad3:	55                   	push   %ebp
  801ad4:	89 e5                	mov    %esp,%ebp
  801ad6:	57                   	push   %edi
  801ad7:	56                   	push   %esi
  801ad8:	53                   	push   %ebx
  801ad9:	8b 55 08             	mov    0x8(%ebp),%edx
  801adc:	8b 45 10             	mov    0x10(%ebp),%eax
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  801adf:	eb 03                	jmp    801ae4 <strtol+0x11>
    s++;
  801ae1:	83 c2 01             	add    $0x1,%edx
{
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  801ae4:	0f b6 0a             	movzbl (%edx),%ecx
  801ae7:	80 f9 09             	cmp    $0x9,%cl
  801aea:	74 f5                	je     801ae1 <strtol+0xe>
  801aec:	80 f9 20             	cmp    $0x20,%cl
  801aef:	74 f0                	je     801ae1 <strtol+0xe>
    s++;

  // plus/minus sign
  if (*s == '+')
  801af1:	80 f9 2b             	cmp    $0x2b,%cl
  801af4:	75 0a                	jne    801b00 <strtol+0x2d>
    s++;
  801af6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
  int neg = 0;
  801af9:	bf 00 00 00 00       	mov    $0x0,%edi
  801afe:	eb 11                	jmp    801b11 <strtol+0x3e>
  801b00:	bf 00 00 00 00       	mov    $0x0,%edi
    s++;

  // plus/minus sign
  if (*s == '+')
    s++;
  else if (*s == '-')
  801b05:	80 f9 2d             	cmp    $0x2d,%cl
  801b08:	75 07                	jne    801b11 <strtol+0x3e>
    s++, neg = 1;
  801b0a:	8d 52 01             	lea    0x1(%edx),%edx
  801b0d:	66 bf 01 00          	mov    $0x1,%di

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801b11:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801b16:	75 15                	jne    801b2d <strtol+0x5a>
  801b18:	80 3a 30             	cmpb   $0x30,(%edx)
  801b1b:	75 10                	jne    801b2d <strtol+0x5a>
  801b1d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801b21:	75 0a                	jne    801b2d <strtol+0x5a>
    s += 2, base = 16;
  801b23:	83 c2 02             	add    $0x2,%edx
  801b26:	b8 10 00 00 00       	mov    $0x10,%eax
  801b2b:	eb 10                	jmp    801b3d <strtol+0x6a>
  else if (base == 0 && s[0] == '0')
  801b2d:	85 c0                	test   %eax,%eax
  801b2f:	75 0c                	jne    801b3d <strtol+0x6a>
    s++, base = 8;
  else if (base == 0)
    base = 10;
  801b31:	b0 0a                	mov    $0xa,%al
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
  801b33:	80 3a 30             	cmpb   $0x30,(%edx)
  801b36:	75 05                	jne    801b3d <strtol+0x6a>
    s++, base = 8;
  801b38:	83 c2 01             	add    $0x1,%edx
  801b3b:	b0 08                	mov    $0x8,%al
  else if (base == 0)
    base = 10;
  801b3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b42:	89 45 10             	mov    %eax,0x10(%ebp)

  // digits
  while (1) {
    int dig;

    if (*s >= '0' && *s <= '9')
  801b45:	0f b6 0a             	movzbl (%edx),%ecx
  801b48:	8d 71 d0             	lea    -0x30(%ecx),%esi
  801b4b:	89 f0                	mov    %esi,%eax
  801b4d:	3c 09                	cmp    $0x9,%al
  801b4f:	77 08                	ja     801b59 <strtol+0x86>
      dig = *s - '0';
  801b51:	0f be c9             	movsbl %cl,%ecx
  801b54:	83 e9 30             	sub    $0x30,%ecx
  801b57:	eb 20                	jmp    801b79 <strtol+0xa6>
    else if (*s >= 'a' && *s <= 'z')
  801b59:	8d 71 9f             	lea    -0x61(%ecx),%esi
  801b5c:	89 f0                	mov    %esi,%eax
  801b5e:	3c 19                	cmp    $0x19,%al
  801b60:	77 08                	ja     801b6a <strtol+0x97>
      dig = *s - 'a' + 10;
  801b62:	0f be c9             	movsbl %cl,%ecx
  801b65:	83 e9 57             	sub    $0x57,%ecx
  801b68:	eb 0f                	jmp    801b79 <strtol+0xa6>
    else if (*s >= 'A' && *s <= 'Z')
  801b6a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  801b6d:	89 f0                	mov    %esi,%eax
  801b6f:	3c 19                	cmp    $0x19,%al
  801b71:	77 16                	ja     801b89 <strtol+0xb6>
      dig = *s - 'A' + 10;
  801b73:	0f be c9             	movsbl %cl,%ecx
  801b76:	83 e9 37             	sub    $0x37,%ecx
    else
      break;
    if (dig >= base)
  801b79:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  801b7c:	7d 0f                	jge    801b8d <strtol+0xba>
      break;
    s++, val = (val * base) + dig;
  801b7e:	83 c2 01             	add    $0x1,%edx
  801b81:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801b85:	01 cb                	add    %ecx,%ebx
    // we don't properly detect overflow!
  }
  801b87:	eb bc                	jmp    801b45 <strtol+0x72>
  801b89:	89 d8                	mov    %ebx,%eax
  801b8b:	eb 02                	jmp    801b8f <strtol+0xbc>
  801b8d:	89 d8                	mov    %ebx,%eax

  if (endptr)
  801b8f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b93:	74 05                	je     801b9a <strtol+0xc7>
    *endptr = (char*)s;
  801b95:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b98:	89 16                	mov    %edx,(%esi)
  return neg ? -val : val;
  801b9a:	f7 d8                	neg    %eax
  801b9c:	85 ff                	test   %edi,%edi
  801b9e:	0f 44 c3             	cmove  %ebx,%eax
}
  801ba1:	5b                   	pop    %ebx
  801ba2:	5e                   	pop    %esi
  801ba3:	5f                   	pop    %edi
  801ba4:	5d                   	pop    %ebp
  801ba5:	c3                   	ret    

00801ba6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ba6:	55                   	push   %ebp
  801ba7:	89 e5                	mov    %esp,%ebp
  801ba9:	56                   	push   %esi
  801baa:	53                   	push   %ebx
  801bab:	83 ec 10             	sub    $0x10,%esp
  801bae:	8b 75 08             	mov    0x8(%ebp),%esi
  801bb1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;
  801bb7:	85 c0                	test   %eax,%eax
  801bb9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801bbe:	0f 44 c2             	cmove  %edx,%eax
  if ((r = sys_ipc_recv(pg)) < 0) {
  801bc1:	89 04 24             	mov    %eax,(%esp)
  801bc4:	e8 bd e7 ff ff       	call   800386 <sys_ipc_recv>
  801bc9:	85 c0                	test   %eax,%eax
  801bcb:	79 34                	jns    801c01 <ipc_recv+0x5b>
    if (from_env_store)
  801bcd:	85 f6                	test   %esi,%esi
  801bcf:	74 06                	je     801bd7 <ipc_recv+0x31>
      *from_env_store = 0;
  801bd1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (perm_store)
  801bd7:	85 db                	test   %ebx,%ebx
  801bd9:	74 06                	je     801be1 <ipc_recv+0x3b>
      *perm_store = 0;
  801bdb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    panic("sys_ipc_recv: %e", r);
  801be1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801be5:	c7 44 24 08 c0 23 80 	movl   $0x8023c0,0x8(%esp)
  801bec:	00 
  801bed:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801bf4:	00 
  801bf5:	c7 04 24 d1 23 80 00 	movl   $0x8023d1,(%esp)
  801bfc:	e8 35 f5 ff ff       	call   801136 <_panic>
  }

  if (from_env_store)
  801c01:	85 f6                	test   %esi,%esi
  801c03:	74 0a                	je     801c0f <ipc_recv+0x69>
    *from_env_store = thisenv->env_ipc_from;
  801c05:	a1 04 40 80 00       	mov    0x804004,%eax
  801c0a:	8b 40 74             	mov    0x74(%eax),%eax
  801c0d:	89 06                	mov    %eax,(%esi)
  if (perm_store)
  801c0f:	85 db                	test   %ebx,%ebx
  801c11:	74 0a                	je     801c1d <ipc_recv+0x77>
    *perm_store |= thisenv->env_ipc_perm;
  801c13:	a1 04 40 80 00       	mov    0x804004,%eax
  801c18:	8b 40 78             	mov    0x78(%eax),%eax
  801c1b:	09 03                	or     %eax,(%ebx)

  return thisenv->env_ipc_value;
  801c1d:	a1 04 40 80 00       	mov    0x804004,%eax
  801c22:	8b 40 70             	mov    0x70(%eax),%eax

}
  801c25:	83 c4 10             	add    $0x10,%esp
  801c28:	5b                   	pop    %ebx
  801c29:	5e                   	pop    %esi
  801c2a:	5d                   	pop    %ebp
  801c2b:	c3                   	ret    

00801c2c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c2c:	55                   	push   %ebp
  801c2d:	89 e5                	mov    %esp,%ebp
  801c2f:	57                   	push   %edi
  801c30:	56                   	push   %esi
  801c31:	53                   	push   %ebx
  801c32:	83 ec 1c             	sub    $0x1c,%esp
  801c35:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c38:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;
  801c3e:	85 db                	test   %ebx,%ebx
  801c40:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801c45:	0f 44 d8             	cmove  %eax,%ebx

  while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801c48:	eb 2a                	jmp    801c74 <ipc_send+0x48>
    if (r != -E_IPC_NOT_RECV)
  801c4a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c4d:	74 20                	je     801c6f <ipc_send+0x43>
      panic("ipc_send: %e", r);
  801c4f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c53:	c7 44 24 08 db 23 80 	movl   $0x8023db,0x8(%esp)
  801c5a:	00 
  801c5b:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801c62:	00 
  801c63:	c7 04 24 d1 23 80 00 	movl   $0x8023d1,(%esp)
  801c6a:	e8 c7 f4 ff ff       	call   801136 <_panic>
    sys_yield();
  801c6f:	e8 dd e4 ff ff       	call   800151 <sys_yield>
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;

  while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801c74:	8b 45 14             	mov    0x14(%ebp),%eax
  801c77:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c7b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c7f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c83:	89 3c 24             	mov    %edi,(%esp)
  801c86:	e8 d8 e6 ff ff       	call   800363 <sys_ipc_try_send>
  801c8b:	85 c0                	test   %eax,%eax
  801c8d:	78 bb                	js     801c4a <ipc_send+0x1e>
    if (r != -E_IPC_NOT_RECV)
      panic("ipc_send: %e", r);
    sys_yield();
  }
}
  801c8f:	83 c4 1c             	add    $0x1c,%esp
  801c92:	5b                   	pop    %ebx
  801c93:	5e                   	pop    %esi
  801c94:	5f                   	pop    %edi
  801c95:	5d                   	pop    %ebp
  801c96:	c3                   	ret    

00801c97 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c97:	55                   	push   %ebp
  801c98:	89 e5                	mov    %esp,%ebp
  801c9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int i;

  for (i = 0; i < NENV; i++)
  801c9d:	b8 00 00 00 00       	mov    $0x0,%eax
    if (envs[i].env_type == type)
  801ca2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ca5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cab:	8b 52 50             	mov    0x50(%edx),%edx
  801cae:	39 ca                	cmp    %ecx,%edx
  801cb0:	75 0d                	jne    801cbf <ipc_find_env+0x28>
      return envs[i].env_id;
  801cb2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801cb5:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801cba:	8b 40 40             	mov    0x40(%eax),%eax
  801cbd:	eb 0e                	jmp    801ccd <ipc_find_env+0x36>
envid_t
ipc_find_env(enum EnvType type)
{
  int i;

  for (i = 0; i < NENV; i++)
  801cbf:	83 c0 01             	add    $0x1,%eax
  801cc2:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cc7:	75 d9                	jne    801ca2 <ipc_find_env+0xb>
    if (envs[i].env_type == type)
      return envs[i].env_id;
  return 0;
  801cc9:	66 b8 00 00          	mov    $0x0,%ax
}
  801ccd:	5d                   	pop    %ebp
  801cce:	c3                   	ret    

00801ccf <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ccf:	55                   	push   %ebp
  801cd0:	89 e5                	mov    %esp,%ebp
  801cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  pte_t pte;

  if (!(uvpd[PDX(v)] & PTE_P))
  801cd5:	89 d0                	mov    %edx,%eax
  801cd7:	c1 e8 16             	shr    $0x16,%eax
  801cda:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
    return 0;
  801ce1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
  pte_t pte;

  if (!(uvpd[PDX(v)] & PTE_P))
  801ce6:	f6 c1 01             	test   $0x1,%cl
  801ce9:	74 1d                	je     801d08 <pageref+0x39>
    return 0;
  pte = uvpt[PGNUM(v)];
  801ceb:	c1 ea 0c             	shr    $0xc,%edx
  801cee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  if (!(pte & PTE_P))
  801cf5:	f6 c2 01             	test   $0x1,%dl
  801cf8:	74 0e                	je     801d08 <pageref+0x39>
    return 0;
  return pages[PGNUM(pte)].pp_ref;
  801cfa:	c1 ea 0c             	shr    $0xc,%edx
  801cfd:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d04:	ef 
  801d05:	0f b7 c0             	movzwl %ax,%eax
}
  801d08:	5d                   	pop    %ebp
  801d09:	c3                   	ret    
  801d0a:	66 90                	xchg   %ax,%ax
  801d0c:	66 90                	xchg   %ax,%ax
  801d0e:	66 90                	xchg   %ax,%ax

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
