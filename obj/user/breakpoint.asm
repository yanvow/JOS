
obj/user/breakpoint.debug:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  asm volatile ("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	83 ec 10             	sub    $0x10,%esp
  800041:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800044:	8b 75 0c             	mov    0xc(%ebp),%esi
  // set thisenv to point at our Env structure in envs[].
  // LAB 3: Your code here.
  thisenv = envs + ENVX(sys_getenvid());
  800047:	e8 dd 00 00 00       	call   800129 <sys_getenvid>
  80004c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800051:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800054:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800059:	a3 04 40 80 00       	mov    %eax,0x804004

  // save the name of the program so that panic() can use it
  if (argc > 0)
  80005e:	85 db                	test   %ebx,%ebx
  800060:	7e 07                	jle    800069 <libmain+0x30>
    binaryname = argv[0];
  800062:	8b 06                	mov    (%esi),%eax
  800064:	a3 00 30 80 00       	mov    %eax,0x803000

  // call user main routine
  umain(argc, argv);
  800069:	89 74 24 04          	mov    %esi,0x4(%esp)
  80006d:	89 1c 24             	mov    %ebx,(%esp)
  800070:	e8 be ff ff ff       	call   800033 <umain>

  // exit gracefully
  exit();
  800075:	e8 07 00 00 00       	call   800081 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	5b                   	pop    %ebx
  80007e:	5e                   	pop    %esi
  80007f:	5d                   	pop    %ebp
  800080:	c3                   	ret    

00800081 <exit>:
#include <inc/lib.h>

void
exit(void)
{
  800081:	55                   	push   %ebp
  800082:	89 e5                	mov    %esp,%ebp
  800084:	83 ec 18             	sub    $0x18,%esp
  close_all();
  800087:	e8 19 05 00 00       	call   8005a5 <close_all>
  sys_env_destroy(0);
  80008c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800093:	e8 3f 00 00 00       	call   8000d7 <sys_env_destroy>
}
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <sys_cputs>:
  return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	57                   	push   %edi
  80009e:	56                   	push   %esi
  80009f:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8000a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ab:	89 c3                	mov    %eax,%ebx
  8000ad:	89 c7                	mov    %eax,%edi
  8000af:	89 c6                	mov    %eax,%esi
  8000b1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
  syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5f                   	pop    %edi
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8000be:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c8:	89 d1                	mov    %edx,%ecx
  8000ca:	89 d3                	mov    %edx,%ebx
  8000cc:	89 d7                	mov    %edx,%edi
  8000ce:	89 d6                	mov    %edx,%esi
  8000d0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	57                   	push   %edi
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
  8000dd:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8000e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ed:	89 cb                	mov    %ecx,%ebx
  8000ef:	89 cf                	mov    %ecx,%edi
  8000f1:	89 ce                	mov    %ecx,%esi
  8000f3:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  8000f5:	85 c0                	test   %eax,%eax
  8000f7:	7e 28                	jle    800121 <sys_env_destroy+0x4a>
    panic("syscall %d returned %d (> 0)", num, ret);
  8000f9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000fd:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800104:	00 
  800105:	c7 44 24 08 aa 1f 80 	movl   $0x801faa,0x8(%esp)
  80010c:	00 
  80010d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800114:	00 
  800115:	c7 04 24 c7 1f 80 00 	movl   $0x801fc7,(%esp)
  80011c:	e8 05 10 00 00       	call   801126 <_panic>

int
sys_env_destroy(envid_t envid)
{
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800121:	83 c4 2c             	add    $0x2c,%esp
  800124:	5b                   	pop    %ebx
  800125:	5e                   	pop    %esi
  800126:	5f                   	pop    %edi
  800127:	5d                   	pop    %ebp
  800128:	c3                   	ret    

00800129 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	57                   	push   %edi
  80012d:	56                   	push   %esi
  80012e:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  80012f:	ba 00 00 00 00       	mov    $0x0,%edx
  800134:	b8 02 00 00 00       	mov    $0x2,%eax
  800139:	89 d1                	mov    %edx,%ecx
  80013b:	89 d3                	mov    %edx,%ebx
  80013d:	89 d7                	mov    %edx,%edi
  80013f:	89 d6                	mov    %edx,%esi
  800141:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800143:	5b                   	pop    %ebx
  800144:	5e                   	pop    %esi
  800145:	5f                   	pop    %edi
  800146:	5d                   	pop    %ebp
  800147:	c3                   	ret    

00800148 <sys_yield>:

void
sys_yield(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	57                   	push   %edi
  80014c:	56                   	push   %esi
  80014d:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  80014e:	ba 00 00 00 00       	mov    $0x0,%edx
  800153:	b8 0b 00 00 00       	mov    $0xb,%eax
  800158:	89 d1                	mov    %edx,%ecx
  80015a:	89 d3                	mov    %edx,%ebx
  80015c:	89 d7                	mov    %edx,%edi
  80015e:	89 d6                	mov    %edx,%esi
  800160:	cd 30                	int    $0x30

void
sys_yield(void)
{
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800162:	5b                   	pop    %ebx
  800163:	5e                   	pop    %esi
  800164:	5f                   	pop    %edi
  800165:	5d                   	pop    %ebp
  800166:	c3                   	ret    

00800167 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	57                   	push   %edi
  80016b:	56                   	push   %esi
  80016c:	53                   	push   %ebx
  80016d:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800170:	be 00 00 00 00       	mov    $0x0,%esi
  800175:	b8 04 00 00 00       	mov    $0x4,%eax
  80017a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017d:	8b 55 08             	mov    0x8(%ebp),%edx
  800180:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800183:	89 f7                	mov    %esi,%edi
  800185:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800187:	85 c0                	test   %eax,%eax
  800189:	7e 28                	jle    8001b3 <sys_page_alloc+0x4c>
    panic("syscall %d returned %d (> 0)", num, ret);
  80018b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80018f:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800196:	00 
  800197:	c7 44 24 08 aa 1f 80 	movl   $0x801faa,0x8(%esp)
  80019e:	00 
  80019f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001a6:	00 
  8001a7:	c7 04 24 c7 1f 80 00 	movl   $0x801fc7,(%esp)
  8001ae:	e8 73 0f 00 00       	call   801126 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  return syscall(SYS_page_alloc, 1, envid, (uint32_t)va, perm, 0, 0);
}
  8001b3:	83 c4 2c             	add    $0x2c,%esp
  8001b6:	5b                   	pop    %ebx
  8001b7:	5e                   	pop    %esi
  8001b8:	5f                   	pop    %edi
  8001b9:	5d                   	pop    %ebp
  8001ba:	c3                   	ret    

008001bb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	57                   	push   %edi
  8001bf:	56                   	push   %esi
  8001c0:	53                   	push   %ebx
  8001c1:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8001c4:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d5:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d8:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  8001da:	85 c0                	test   %eax,%eax
  8001dc:	7e 28                	jle    800206 <sys_page_map+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  8001de:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001e2:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001e9:	00 
  8001ea:	c7 44 24 08 aa 1f 80 	movl   $0x801faa,0x8(%esp)
  8001f1:	00 
  8001f2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001f9:	00 
  8001fa:	c7 04 24 c7 1f 80 00 	movl   $0x801fc7,(%esp)
  800201:	e8 20 0f 00 00       	call   801126 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  return syscall(SYS_page_map, 1, srcenv, (uint32_t)srcva, dstenv, (uint32_t)dstva, perm);
}
  800206:	83 c4 2c             	add    $0x2c,%esp
  800209:	5b                   	pop    %ebx
  80020a:	5e                   	pop    %esi
  80020b:	5f                   	pop    %edi
  80020c:	5d                   	pop    %ebp
  80020d:	c3                   	ret    

0080020e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80020e:	55                   	push   %ebp
  80020f:	89 e5                	mov    %esp,%ebp
  800211:	57                   	push   %edi
  800212:	56                   	push   %esi
  800213:	53                   	push   %ebx
  800214:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800217:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021c:	b8 06 00 00 00       	mov    $0x6,%eax
  800221:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800224:	8b 55 08             	mov    0x8(%ebp),%edx
  800227:	89 df                	mov    %ebx,%edi
  800229:	89 de                	mov    %ebx,%esi
  80022b:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  80022d:	85 c0                	test   %eax,%eax
  80022f:	7e 28                	jle    800259 <sys_page_unmap+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800231:	89 44 24 10          	mov    %eax,0x10(%esp)
  800235:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80023c:	00 
  80023d:	c7 44 24 08 aa 1f 80 	movl   $0x801faa,0x8(%esp)
  800244:	00 
  800245:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80024c:	00 
  80024d:	c7 04 24 c7 1f 80 00 	movl   $0x801fc7,(%esp)
  800254:	e8 cd 0e 00 00       	call   801126 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
  return syscall(SYS_page_unmap, 1, envid, (uint32_t)va, 0, 0, 0);
}
  800259:	83 c4 2c             	add    $0x2c,%esp
  80025c:	5b                   	pop    %ebx
  80025d:	5e                   	pop    %esi
  80025e:	5f                   	pop    %edi
  80025f:	5d                   	pop    %ebp
  800260:	c3                   	ret    

00800261 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800261:	55                   	push   %ebp
  800262:	89 e5                	mov    %esp,%ebp
  800264:	57                   	push   %edi
  800265:	56                   	push   %esi
  800266:	53                   	push   %ebx
  800267:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  80026a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026f:	b8 08 00 00 00       	mov    $0x8,%eax
  800274:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800277:	8b 55 08             	mov    0x8(%ebp),%edx
  80027a:	89 df                	mov    %ebx,%edi
  80027c:	89 de                	mov    %ebx,%esi
  80027e:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800280:	85 c0                	test   %eax,%eax
  800282:	7e 28                	jle    8002ac <sys_env_set_status+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  800284:	89 44 24 10          	mov    %eax,0x10(%esp)
  800288:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80028f:	00 
  800290:	c7 44 24 08 aa 1f 80 	movl   $0x801faa,0x8(%esp)
  800297:	00 
  800298:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80029f:	00 
  8002a0:	c7 04 24 c7 1f 80 00 	movl   $0x801fc7,(%esp)
  8002a7:	e8 7a 0e 00 00       	call   801126 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002ac:	83 c4 2c             	add    $0x2c,%esp
  8002af:	5b                   	pop    %ebx
  8002b0:	5e                   	pop    %esi
  8002b1:	5f                   	pop    %edi
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    

008002b4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	57                   	push   %edi
  8002b8:	56                   	push   %esi
  8002b9:	53                   	push   %ebx
  8002ba:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8002bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c2:	b8 09 00 00 00       	mov    $0x9,%eax
  8002c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cd:	89 df                	mov    %ebx,%edi
  8002cf:	89 de                	mov    %ebx,%esi
  8002d1:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  8002d3:	85 c0                	test   %eax,%eax
  8002d5:	7e 28                	jle    8002ff <sys_env_set_trapframe+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  8002d7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002db:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002e2:	00 
  8002e3:	c7 44 24 08 aa 1f 80 	movl   $0x801faa,0x8(%esp)
  8002ea:	00 
  8002eb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002f2:	00 
  8002f3:	c7 04 24 c7 1f 80 00 	movl   $0x801fc7,(%esp)
  8002fa:	e8 27 0e 00 00       	call   801126 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t)tf, 0, 0, 0);
}
  8002ff:	83 c4 2c             	add    $0x2c,%esp
  800302:	5b                   	pop    %ebx
  800303:	5e                   	pop    %esi
  800304:	5f                   	pop    %edi
  800305:	5d                   	pop    %ebp
  800306:	c3                   	ret    

00800307 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800307:	55                   	push   %ebp
  800308:	89 e5                	mov    %esp,%ebp
  80030a:	57                   	push   %edi
  80030b:	56                   	push   %esi
  80030c:	53                   	push   %ebx
  80030d:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800310:	bb 00 00 00 00       	mov    $0x0,%ebx
  800315:	b8 0a 00 00 00       	mov    $0xa,%eax
  80031a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80031d:	8b 55 08             	mov    0x8(%ebp),%edx
  800320:	89 df                	mov    %ebx,%edi
  800322:	89 de                	mov    %ebx,%esi
  800324:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  800326:	85 c0                	test   %eax,%eax
  800328:	7e 28                	jle    800352 <sys_env_set_pgfault_upcall+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  80032a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80032e:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800335:	00 
  800336:	c7 44 24 08 aa 1f 80 	movl   $0x801faa,0x8(%esp)
  80033d:	00 
  80033e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800345:	00 
  800346:	c7 04 24 c7 1f 80 00 	movl   $0x801fc7,(%esp)
  80034d:	e8 d4 0d 00 00       	call   801126 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  800352:	83 c4 2c             	add    $0x2c,%esp
  800355:	5b                   	pop    %ebx
  800356:	5e                   	pop    %esi
  800357:	5f                   	pop    %edi
  800358:	5d                   	pop    %ebp
  800359:	c3                   	ret    

0080035a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80035a:	55                   	push   %ebp
  80035b:	89 e5                	mov    %esp,%ebp
  80035d:	57                   	push   %edi
  80035e:	56                   	push   %esi
  80035f:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800360:	be 00 00 00 00       	mov    $0x0,%esi
  800365:	b8 0c 00 00 00       	mov    $0xc,%eax
  80036a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80036d:	8b 55 08             	mov    0x8(%ebp),%edx
  800370:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800373:	8b 7d 14             	mov    0x14(%ebp),%edi
  800376:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t)srcva, perm, 0);
}
  800378:	5b                   	pop    %ebx
  800379:	5e                   	pop    %esi
  80037a:	5f                   	pop    %edi
  80037b:	5d                   	pop    %ebp
  80037c:	c3                   	ret    

0080037d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80037d:	55                   	push   %ebp
  80037e:	89 e5                	mov    %esp,%ebp
  800380:	57                   	push   %edi
  800381:	56                   	push   %esi
  800382:	53                   	push   %ebx
  800383:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  800386:	b9 00 00 00 00       	mov    $0x0,%ecx
  80038b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800390:	8b 55 08             	mov    0x8(%ebp),%edx
  800393:	89 cb                	mov    %ecx,%ebx
  800395:	89 cf                	mov    %ecx,%edi
  800397:	89 ce                	mov    %ecx,%esi
  800399:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  80039b:	85 c0                	test   %eax,%eax
  80039d:	7e 28                	jle    8003c7 <sys_ipc_recv+0x4a>
    panic("syscall %d returned %d (> 0)", num, ret);
  80039f:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003a3:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003aa:	00 
  8003ab:	c7 44 24 08 aa 1f 80 	movl   $0x801faa,0x8(%esp)
  8003b2:	00 
  8003b3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003ba:	00 
  8003bb:	c7 04 24 c7 1f 80 00 	movl   $0x801fc7,(%esp)
  8003c2:	e8 5f 0d 00 00       	call   801126 <_panic>

int
sys_ipc_recv(void *dstva)
{
  return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003c7:	83 c4 2c             	add    $0x2c,%esp
  8003ca:	5b                   	pop    %ebx
  8003cb:	5e                   	pop    %esi
  8003cc:	5f                   	pop    %edi
  8003cd:	5d                   	pop    %ebp
  8003ce:	c3                   	ret    
  8003cf:	90                   	nop

008003d0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  8003d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d6:	05 00 00 00 30       	add    $0x30000000,%eax
  8003db:	c1 e8 0c             	shr    $0xc,%eax
}
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  8003e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e6:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
  return INDEX2DATA(fd2num(fd));
  8003eb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003f0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003f5:	5d                   	pop    %ebp
  8003f6:	c3                   	ret    

008003f7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003f7:	55                   	push   %ebp
  8003f8:	89 e5                	mov    %esp,%ebp
  8003fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003fd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
  int i;
  struct Fd *fd;

  for (i = 0; i < MAXFD; i++) {
    fd = INDEX2FD(i);
    if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800402:	89 c2                	mov    %eax,%edx
  800404:	c1 ea 16             	shr    $0x16,%edx
  800407:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80040e:	f6 c2 01             	test   $0x1,%dl
  800411:	74 11                	je     800424 <fd_alloc+0x2d>
  800413:	89 c2                	mov    %eax,%edx
  800415:	c1 ea 0c             	shr    $0xc,%edx
  800418:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80041f:	f6 c2 01             	test   $0x1,%dl
  800422:	75 09                	jne    80042d <fd_alloc+0x36>
      *fd_store = fd;
  800424:	89 01                	mov    %eax,(%ecx)
      return 0;
  800426:	b8 00 00 00 00       	mov    $0x0,%eax
  80042b:	eb 17                	jmp    800444 <fd_alloc+0x4d>
  80042d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
  int i;
  struct Fd *fd;

  for (i = 0; i < MAXFD; i++) {
  800432:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800437:	75 c9                	jne    800402 <fd_alloc+0xb>
    if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
      *fd_store = fd;
      return 0;
    }
  }
  *fd_store = 0;
  800439:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
  return -E_MAX_OPEN;
  80043f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800444:	5d                   	pop    %ebp
  800445:	c3                   	ret    

00800446 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	8b 45 08             	mov    0x8(%ebp),%eax
  struct Fd *fd;

  if (fdnum < 0 || fdnum >= MAXFD) {
  80044c:	83 f8 1f             	cmp    $0x1f,%eax
  80044f:	77 36                	ja     800487 <fd_lookup+0x41>
    if (debug)
      cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  fd = INDEX2FD(fdnum);
  800451:	c1 e0 0c             	shl    $0xc,%eax
  800454:	2d 00 00 00 30       	sub    $0x30000000,%eax
  if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800459:	89 c2                	mov    %eax,%edx
  80045b:	c1 ea 16             	shr    $0x16,%edx
  80045e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800465:	f6 c2 01             	test   $0x1,%dl
  800468:	74 24                	je     80048e <fd_lookup+0x48>
  80046a:	89 c2                	mov    %eax,%edx
  80046c:	c1 ea 0c             	shr    $0xc,%edx
  80046f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800476:	f6 c2 01             	test   $0x1,%dl
  800479:	74 1a                	je     800495 <fd_lookup+0x4f>
    if (debug)
      cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  *fd_store = fd;
  80047b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80047e:	89 02                	mov    %eax,(%edx)
  return 0;
  800480:	b8 00 00 00 00       	mov    $0x0,%eax
  800485:	eb 13                	jmp    80049a <fd_lookup+0x54>
  struct Fd *fd;

  if (fdnum < 0 || fdnum >= MAXFD) {
    if (debug)
      cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  800487:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80048c:	eb 0c                	jmp    80049a <fd_lookup+0x54>
  }
  fd = INDEX2FD(fdnum);
  if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
    if (debug)
      cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  80048e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800493:	eb 05                	jmp    80049a <fd_lookup+0x54>
  800495:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  }
  *fd_store = fd;
  return 0;
}
  80049a:	5d                   	pop    %ebp
  80049b:	c3                   	ret    

0080049c <dev_lookup>:
  0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80049c:	55                   	push   %ebp
  80049d:	89 e5                	mov    %esp,%ebp
  80049f:	83 ec 18             	sub    $0x18,%esp
  8004a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004a5:	ba 54 20 80 00       	mov    $0x802054,%edx
  int i;

  for (i = 0; devtab[i]; i++)
  8004aa:	eb 13                	jmp    8004bf <dev_lookup+0x23>
  8004ac:	83 c2 04             	add    $0x4,%edx
    if (devtab[i]->dev_id == dev_id) {
  8004af:	39 08                	cmp    %ecx,(%eax)
  8004b1:	75 0c                	jne    8004bf <dev_lookup+0x23>
      *dev = devtab[i];
  8004b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004b6:	89 01                	mov    %eax,(%ecx)
      return 0;
  8004b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bd:	eb 30                	jmp    8004ef <dev_lookup+0x53>
int
dev_lookup(int dev_id, struct Dev **dev)
{
  int i;

  for (i = 0; devtab[i]; i++)
  8004bf:	8b 02                	mov    (%edx),%eax
  8004c1:	85 c0                	test   %eax,%eax
  8004c3:	75 e7                	jne    8004ac <dev_lookup+0x10>
    if (devtab[i]->dev_id == dev_id) {
      *dev = devtab[i];
      return 0;
    }
  cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004c5:	a1 04 40 80 00       	mov    0x804004,%eax
  8004ca:	8b 40 48             	mov    0x48(%eax),%eax
  8004cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8004d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d5:	c7 04 24 d8 1f 80 00 	movl   $0x801fd8,(%esp)
  8004dc:	e8 3e 0d 00 00       	call   80121f <cprintf>
  *dev = 0;
  8004e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  return -E_INVAL;
  8004ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004ef:	c9                   	leave  
  8004f0:	c3                   	ret    

008004f1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004f1:	55                   	push   %ebp
  8004f2:	89 e5                	mov    %esp,%ebp
  8004f4:	56                   	push   %esi
  8004f5:	53                   	push   %ebx
  8004f6:	83 ec 20             	sub    $0x20,%esp
  8004f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct Fd *fd2;
  struct Dev *dev;
  int r;

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800502:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  800506:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80050c:	c1 e8 0c             	shr    $0xc,%eax
{
  struct Fd *fd2;
  struct Dev *dev;
  int r;

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80050f:	89 04 24             	mov    %eax,(%esp)
  800512:	e8 2f ff ff ff       	call   800446 <fd_lookup>
  800517:	85 c0                	test   %eax,%eax
  800519:	78 05                	js     800520 <fd_close+0x2f>
      || fd != fd2)
  80051b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80051e:	74 0c                	je     80052c <fd_close+0x3b>
    return must_exist ? r : 0;
  800520:	84 db                	test   %bl,%bl
  800522:	ba 00 00 00 00       	mov    $0x0,%edx
  800527:	0f 44 c2             	cmove  %edx,%eax
  80052a:	eb 3f                	jmp    80056b <fd_close+0x7a>
  if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80052c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80052f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800533:	8b 06                	mov    (%esi),%eax
  800535:	89 04 24             	mov    %eax,(%esp)
  800538:	e8 5f ff ff ff       	call   80049c <dev_lookup>
  80053d:	89 c3                	mov    %eax,%ebx
  80053f:	85 c0                	test   %eax,%eax
  800541:	78 16                	js     800559 <fd_close+0x68>
    if (dev->dev_close)
  800543:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800546:	8b 40 10             	mov    0x10(%eax),%eax
      r = (*dev->dev_close)(fd);
    else
      r = 0;
  800549:	bb 00 00 00 00       	mov    $0x0,%ebx

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
      || fd != fd2)
    return must_exist ? r : 0;
  if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
    if (dev->dev_close)
  80054e:	85 c0                	test   %eax,%eax
  800550:	74 07                	je     800559 <fd_close+0x68>
      r = (*dev->dev_close)(fd);
  800552:	89 34 24             	mov    %esi,(%esp)
  800555:	ff d0                	call   *%eax
  800557:	89 c3                	mov    %eax,%ebx
    else
      r = 0;
  }
  // Make sure fd is unmapped.  Might be a no-op if
  // (*dev->dev_close)(fd) already unmapped it.
  (void)sys_page_unmap(0, fd);
  800559:	89 74 24 04          	mov    %esi,0x4(%esp)
  80055d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800564:	e8 a5 fc ff ff       	call   80020e <sys_page_unmap>
  return r;
  800569:	89 d8                	mov    %ebx,%eax
}
  80056b:	83 c4 20             	add    $0x20,%esp
  80056e:	5b                   	pop    %ebx
  80056f:	5e                   	pop    %esi
  800570:	5d                   	pop    %ebp
  800571:	c3                   	ret    

00800572 <close>:
  return -E_INVAL;
}

int
close(int fdnum)
{
  800572:	55                   	push   %ebp
  800573:	89 e5                	mov    %esp,%ebp
  800575:	83 ec 28             	sub    $0x28,%esp
  struct Fd *fd;
  int r;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  800578:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80057b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80057f:	8b 45 08             	mov    0x8(%ebp),%eax
  800582:	89 04 24             	mov    %eax,(%esp)
  800585:	e8 bc fe ff ff       	call   800446 <fd_lookup>
  80058a:	89 c2                	mov    %eax,%edx
  80058c:	85 d2                	test   %edx,%edx
  80058e:	78 13                	js     8005a3 <close+0x31>
    return r;
  else
    return fd_close(fd, 1);
  800590:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800597:	00 
  800598:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80059b:	89 04 24             	mov    %eax,(%esp)
  80059e:	e8 4e ff ff ff       	call   8004f1 <fd_close>
}
  8005a3:	c9                   	leave  
  8005a4:	c3                   	ret    

008005a5 <close_all>:

void
close_all(void)
{
  8005a5:	55                   	push   %ebp
  8005a6:	89 e5                	mov    %esp,%ebp
  8005a8:	53                   	push   %ebx
  8005a9:	83 ec 14             	sub    $0x14,%esp
  int i;

  for (i = 0; i < MAXFD; i++)
  8005ac:	bb 00 00 00 00       	mov    $0x0,%ebx
    close(i);
  8005b1:	89 1c 24             	mov    %ebx,(%esp)
  8005b4:	e8 b9 ff ff ff       	call   800572 <close>
void
close_all(void)
{
  int i;

  for (i = 0; i < MAXFD; i++)
  8005b9:	83 c3 01             	add    $0x1,%ebx
  8005bc:	83 fb 20             	cmp    $0x20,%ebx
  8005bf:	75 f0                	jne    8005b1 <close_all+0xc>
    close(i);
}
  8005c1:	83 c4 14             	add    $0x14,%esp
  8005c4:	5b                   	pop    %ebx
  8005c5:	5d                   	pop    %ebp
  8005c6:	c3                   	ret    

008005c7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005c7:	55                   	push   %ebp
  8005c8:	89 e5                	mov    %esp,%ebp
  8005ca:	57                   	push   %edi
  8005cb:	56                   	push   %esi
  8005cc:	53                   	push   %ebx
  8005cd:	83 ec 3c             	sub    $0x3c,%esp
  int r;
  char *ova, *nva;
  pte_t pte;
  struct Fd *oldfd, *newfd;

  if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005d0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005da:	89 04 24             	mov    %eax,(%esp)
  8005dd:	e8 64 fe ff ff       	call   800446 <fd_lookup>
  8005e2:	89 c2                	mov    %eax,%edx
  8005e4:	85 d2                	test   %edx,%edx
  8005e6:	0f 88 e1 00 00 00    	js     8006cd <dup+0x106>
    return r;
  close(newfdnum);
  8005ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ef:	89 04 24             	mov    %eax,(%esp)
  8005f2:	e8 7b ff ff ff       	call   800572 <close>

  newfd = INDEX2FD(newfdnum);
  8005f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005fa:	c1 e3 0c             	shl    $0xc,%ebx
  8005fd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
  ova = fd2data(oldfd);
  800603:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800606:	89 04 24             	mov    %eax,(%esp)
  800609:	e8 d2 fd ff ff       	call   8003e0 <fd2data>
  80060e:	89 c6                	mov    %eax,%esi
  nva = fd2data(newfd);
  800610:	89 1c 24             	mov    %ebx,(%esp)
  800613:	e8 c8 fd ff ff       	call   8003e0 <fd2data>
  800618:	89 c7                	mov    %eax,%edi

  if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80061a:	89 f0                	mov    %esi,%eax
  80061c:	c1 e8 16             	shr    $0x16,%eax
  80061f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800626:	a8 01                	test   $0x1,%al
  800628:	74 43                	je     80066d <dup+0xa6>
  80062a:	89 f0                	mov    %esi,%eax
  80062c:	c1 e8 0c             	shr    $0xc,%eax
  80062f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800636:	f6 c2 01             	test   $0x1,%dl
  800639:	74 32                	je     80066d <dup+0xa6>
    if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80063b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800642:	25 07 0e 00 00       	and    $0xe07,%eax
  800647:	89 44 24 10          	mov    %eax,0x10(%esp)
  80064b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80064f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800656:	00 
  800657:	89 74 24 04          	mov    %esi,0x4(%esp)
  80065b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800662:	e8 54 fb ff ff       	call   8001bb <sys_page_map>
  800667:	89 c6                	mov    %eax,%esi
  800669:	85 c0                	test   %eax,%eax
  80066b:	78 3e                	js     8006ab <dup+0xe4>
      goto err;
  if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80066d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800670:	89 c2                	mov    %eax,%edx
  800672:	c1 ea 0c             	shr    $0xc,%edx
  800675:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80067c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800682:	89 54 24 10          	mov    %edx,0x10(%esp)
  800686:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80068a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800691:	00 
  800692:	89 44 24 04          	mov    %eax,0x4(%esp)
  800696:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80069d:	e8 19 fb ff ff       	call   8001bb <sys_page_map>
  8006a2:	89 c6                	mov    %eax,%esi
    goto err;

  return newfdnum;
  8006a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  nva = fd2data(newfd);

  if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
    if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
      goto err;
  if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006a7:	85 f6                	test   %esi,%esi
  8006a9:	79 22                	jns    8006cd <dup+0x106>
    goto err;

  return newfdnum;

err:
  sys_page_unmap(0, newfd);
  8006ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006b6:	e8 53 fb ff ff       	call   80020e <sys_page_unmap>
  sys_page_unmap(0, nva);
  8006bb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006c6:	e8 43 fb ff ff       	call   80020e <sys_page_unmap>
  return r;
  8006cb:	89 f0                	mov    %esi,%eax
}
  8006cd:	83 c4 3c             	add    $0x3c,%esp
  8006d0:	5b                   	pop    %ebx
  8006d1:	5e                   	pop    %esi
  8006d2:	5f                   	pop    %edi
  8006d3:	5d                   	pop    %ebp
  8006d4:	c3                   	ret    

008006d5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006d5:	55                   	push   %ebp
  8006d6:	89 e5                	mov    %esp,%ebp
  8006d8:	53                   	push   %ebx
  8006d9:	83 ec 24             	sub    $0x24,%esp
  8006dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  8006df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e6:	89 1c 24             	mov    %ebx,(%esp)
  8006e9:	e8 58 fd ff ff       	call   800446 <fd_lookup>
  8006ee:	89 c2                	mov    %eax,%edx
  8006f0:	85 d2                	test   %edx,%edx
  8006f2:	78 6d                	js     800761 <read+0x8c>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006fe:	8b 00                	mov    (%eax),%eax
  800700:	89 04 24             	mov    %eax,(%esp)
  800703:	e8 94 fd ff ff       	call   80049c <dev_lookup>
  800708:	85 c0                	test   %eax,%eax
  80070a:	78 55                	js     800761 <read+0x8c>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80070c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80070f:	8b 50 08             	mov    0x8(%eax),%edx
  800712:	83 e2 03             	and    $0x3,%edx
  800715:	83 fa 01             	cmp    $0x1,%edx
  800718:	75 23                	jne    80073d <read+0x68>
    cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80071a:	a1 04 40 80 00       	mov    0x804004,%eax
  80071f:	8b 40 48             	mov    0x48(%eax),%eax
  800722:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800726:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072a:	c7 04 24 19 20 80 00 	movl   $0x802019,(%esp)
  800731:	e8 e9 0a 00 00       	call   80121f <cprintf>
    return -E_INVAL;
  800736:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80073b:	eb 24                	jmp    800761 <read+0x8c>
  }
  if (!dev->dev_read)
  80073d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800740:	8b 52 08             	mov    0x8(%edx),%edx
  800743:	85 d2                	test   %edx,%edx
  800745:	74 15                	je     80075c <read+0x87>
    return -E_NOT_SUPP;
  return (*dev->dev_read)(fd, buf, n);
  800747:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80074a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80074e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800751:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800755:	89 04 24             	mov    %eax,(%esp)
  800758:	ff d2                	call   *%edx
  80075a:	eb 05                	jmp    800761 <read+0x8c>
  if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
    cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  if (!dev->dev_read)
    return -E_NOT_SUPP;
  80075c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_read)(fd, buf, n);
}
  800761:	83 c4 24             	add    $0x24,%esp
  800764:	5b                   	pop    %ebx
  800765:	5d                   	pop    %ebp
  800766:	c3                   	ret    

00800767 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	57                   	push   %edi
  80076b:	56                   	push   %esi
  80076c:	53                   	push   %ebx
  80076d:	83 ec 1c             	sub    $0x1c,%esp
  800770:	8b 7d 08             	mov    0x8(%ebp),%edi
  800773:	8b 75 10             	mov    0x10(%ebp),%esi
  int m, tot;

  for (tot = 0; tot < n; tot += m) {
  800776:	bb 00 00 00 00       	mov    $0x0,%ebx
  80077b:	eb 23                	jmp    8007a0 <readn+0x39>
    m = read(fdnum, (char*)buf + tot, n - tot);
  80077d:	89 f0                	mov    %esi,%eax
  80077f:	29 d8                	sub    %ebx,%eax
  800781:	89 44 24 08          	mov    %eax,0x8(%esp)
  800785:	89 d8                	mov    %ebx,%eax
  800787:	03 45 0c             	add    0xc(%ebp),%eax
  80078a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078e:	89 3c 24             	mov    %edi,(%esp)
  800791:	e8 3f ff ff ff       	call   8006d5 <read>
    if (m < 0)
  800796:	85 c0                	test   %eax,%eax
  800798:	78 10                	js     8007aa <readn+0x43>
      return m;
    if (m == 0)
  80079a:	85 c0                	test   %eax,%eax
  80079c:	74 0a                	je     8007a8 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
  int m, tot;

  for (tot = 0; tot < n; tot += m) {
  80079e:	01 c3                	add    %eax,%ebx
  8007a0:	39 f3                	cmp    %esi,%ebx
  8007a2:	72 d9                	jb     80077d <readn+0x16>
  8007a4:	89 d8                	mov    %ebx,%eax
  8007a6:	eb 02                	jmp    8007aa <readn+0x43>
  8007a8:	89 d8                	mov    %ebx,%eax
      return m;
    if (m == 0)
      break;
  }
  return tot;
}
  8007aa:	83 c4 1c             	add    $0x1c,%esp
  8007ad:	5b                   	pop    %ebx
  8007ae:	5e                   	pop    %esi
  8007af:	5f                   	pop    %edi
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	53                   	push   %ebx
  8007b6:	83 ec 24             	sub    $0x24,%esp
  8007b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  8007bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c3:	89 1c 24             	mov    %ebx,(%esp)
  8007c6:	e8 7b fc ff ff       	call   800446 <fd_lookup>
  8007cb:	89 c2                	mov    %eax,%edx
  8007cd:	85 d2                	test   %edx,%edx
  8007cf:	78 68                	js     800839 <write+0x87>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007db:	8b 00                	mov    (%eax),%eax
  8007dd:	89 04 24             	mov    %eax,(%esp)
  8007e0:	e8 b7 fc ff ff       	call   80049c <dev_lookup>
  8007e5:	85 c0                	test   %eax,%eax
  8007e7:	78 50                	js     800839 <write+0x87>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ec:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f0:	75 23                	jne    800815 <write+0x63>
    cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007f2:	a1 04 40 80 00       	mov    0x804004,%eax
  8007f7:	8b 40 48             	mov    0x48(%eax),%eax
  8007fa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800802:	c7 04 24 35 20 80 00 	movl   $0x802035,(%esp)
  800809:	e8 11 0a 00 00       	call   80121f <cprintf>
    return -E_INVAL;
  80080e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800813:	eb 24                	jmp    800839 <write+0x87>
  }
  if (debug)
    cprintf("write %d %p %d via dev %s\n",
            fdnum, buf, n, dev->dev_name);
  if (!dev->dev_write)
  800815:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800818:	8b 52 0c             	mov    0xc(%edx),%edx
  80081b:	85 d2                	test   %edx,%edx
  80081d:	74 15                	je     800834 <write+0x82>
    return -E_NOT_SUPP;
  return (*dev->dev_write)(fd, buf, n);
  80081f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800822:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800826:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800829:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80082d:	89 04 24             	mov    %eax,(%esp)
  800830:	ff d2                	call   *%edx
  800832:	eb 05                	jmp    800839 <write+0x87>
  }
  if (debug)
    cprintf("write %d %p %d via dev %s\n",
            fdnum, buf, n, dev->dev_name);
  if (!dev->dev_write)
    return -E_NOT_SUPP;
  800834:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_write)(fd, buf, n);
}
  800839:	83 c4 24             	add    $0x24,%esp
  80083c:	5b                   	pop    %ebx
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <seek>:

int
seek(int fdnum, off_t offset)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	83 ec 18             	sub    $0x18,%esp
  int r;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  800845:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800848:	89 44 24 04          	mov    %eax,0x4(%esp)
  80084c:	8b 45 08             	mov    0x8(%ebp),%eax
  80084f:	89 04 24             	mov    %eax,(%esp)
  800852:	e8 ef fb ff ff       	call   800446 <fd_lookup>
  800857:	85 c0                	test   %eax,%eax
  800859:	78 0e                	js     800869 <seek+0x2a>
    return r;
  fd->fd_offset = offset;
  80085b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80085e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800861:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
  800864:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800869:	c9                   	leave  
  80086a:	c3                   	ret    

0080086b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	53                   	push   %ebx
  80086f:	83 ec 24             	sub    $0x24,%esp
  800872:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  800875:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800878:	89 44 24 04          	mov    %eax,0x4(%esp)
  80087c:	89 1c 24             	mov    %ebx,(%esp)
  80087f:	e8 c2 fb ff ff       	call   800446 <fd_lookup>
  800884:	89 c2                	mov    %eax,%edx
  800886:	85 d2                	test   %edx,%edx
  800888:	78 61                	js     8008eb <ftruncate+0x80>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80088a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80088d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800891:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800894:	8b 00                	mov    (%eax),%eax
  800896:	89 04 24             	mov    %eax,(%esp)
  800899:	e8 fe fb ff ff       	call   80049c <dev_lookup>
  80089e:	85 c0                	test   %eax,%eax
  8008a0:	78 49                	js     8008eb <ftruncate+0x80>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008a5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008a9:	75 23                	jne    8008ce <ftruncate+0x63>
    cprintf("[%08x] ftruncate %d -- bad mode\n",
            thisenv->env_id, fdnum);
  8008ab:	a1 04 40 80 00       	mov    0x804004,%eax

  if ((r = fd_lookup(fdnum, &fd)) < 0
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
    cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008b0:	8b 40 48             	mov    0x48(%eax),%eax
  8008b3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008bb:	c7 04 24 f8 1f 80 00 	movl   $0x801ff8,(%esp)
  8008c2:	e8 58 09 00 00       	call   80121f <cprintf>
            thisenv->env_id, fdnum);
    return -E_INVAL;
  8008c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008cc:	eb 1d                	jmp    8008eb <ftruncate+0x80>
  }
  if (!dev->dev_trunc)
  8008ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008d1:	8b 52 18             	mov    0x18(%edx),%edx
  8008d4:	85 d2                	test   %edx,%edx
  8008d6:	74 0e                	je     8008e6 <ftruncate+0x7b>
    return -E_NOT_SUPP;
  return (*dev->dev_trunc)(fd, newsize);
  8008d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008db:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008df:	89 04 24             	mov    %eax,(%esp)
  8008e2:	ff d2                	call   *%edx
  8008e4:	eb 05                	jmp    8008eb <ftruncate+0x80>
    cprintf("[%08x] ftruncate %d -- bad mode\n",
            thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  if (!dev->dev_trunc)
    return -E_NOT_SUPP;
  8008e6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_trunc)(fd, newsize);
}
  8008eb:	83 c4 24             	add    $0x24,%esp
  8008ee:	5b                   	pop    %ebx
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	53                   	push   %ebx
  8008f5:	83 ec 24             	sub    $0x24,%esp
  8008f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  8008fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800902:	8b 45 08             	mov    0x8(%ebp),%eax
  800905:	89 04 24             	mov    %eax,(%esp)
  800908:	e8 39 fb ff ff       	call   800446 <fd_lookup>
  80090d:	89 c2                	mov    %eax,%edx
  80090f:	85 d2                	test   %edx,%edx
  800911:	78 52                	js     800965 <fstat+0x74>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800913:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800916:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80091d:	8b 00                	mov    (%eax),%eax
  80091f:	89 04 24             	mov    %eax,(%esp)
  800922:	e8 75 fb ff ff       	call   80049c <dev_lookup>
  800927:	85 c0                	test   %eax,%eax
  800929:	78 3a                	js     800965 <fstat+0x74>
    return r;
  if (!dev->dev_stat)
  80092b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80092e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800932:	74 2c                	je     800960 <fstat+0x6f>
    return -E_NOT_SUPP;
  stat->st_name[0] = 0;
  800934:	c6 03 00             	movb   $0x0,(%ebx)
  stat->st_size = 0;
  800937:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80093e:	00 00 00 
  stat->st_isdir = 0;
  800941:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800948:	00 00 00 
  stat->st_dev = dev;
  80094b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
  return (*dev->dev_stat)(fd, stat);
  800951:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800955:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800958:	89 14 24             	mov    %edx,(%esp)
  80095b:	ff 50 14             	call   *0x14(%eax)
  80095e:	eb 05                	jmp    800965 <fstat+0x74>

  if ((r = fd_lookup(fdnum, &fd)) < 0
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
    return r;
  if (!dev->dev_stat)
    return -E_NOT_SUPP;
  800960:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  stat->st_name[0] = 0;
  stat->st_size = 0;
  stat->st_isdir = 0;
  stat->st_dev = dev;
  return (*dev->dev_stat)(fd, stat);
}
  800965:	83 c4 24             	add    $0x24,%esp
  800968:	5b                   	pop    %ebx
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	56                   	push   %esi
  80096f:	53                   	push   %ebx
  800970:	83 ec 10             	sub    $0x10,%esp
  int fd, r;

  if ((fd = open(path, O_RDONLY)) < 0)
  800973:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80097a:	00 
  80097b:	8b 45 08             	mov    0x8(%ebp),%eax
  80097e:	89 04 24             	mov    %eax,(%esp)
  800981:	e8 d2 01 00 00       	call   800b58 <open>
  800986:	89 c3                	mov    %eax,%ebx
  800988:	85 db                	test   %ebx,%ebx
  80098a:	78 1b                	js     8009a7 <stat+0x3c>
    return fd;
  r = fstat(fd, stat);
  80098c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800993:	89 1c 24             	mov    %ebx,(%esp)
  800996:	e8 56 ff ff ff       	call   8008f1 <fstat>
  80099b:	89 c6                	mov    %eax,%esi
  close(fd);
  80099d:	89 1c 24             	mov    %ebx,(%esp)
  8009a0:	e8 cd fb ff ff       	call   800572 <close>
  return r;
  8009a5:	89 f0                	mov    %esi,%eax
}
  8009a7:	83 c4 10             	add    $0x10,%esp
  8009aa:	5b                   	pop    %ebx
  8009ab:	5e                   	pop    %esi
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	56                   	push   %esi
  8009b2:	53                   	push   %ebx
  8009b3:	83 ec 10             	sub    $0x10,%esp
  8009b6:	89 c6                	mov    %eax,%esi
  8009b8:	89 d3                	mov    %edx,%ebx
  static envid_t fsenv;

  if (fsenv == 0)
  8009ba:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009c1:	75 11                	jne    8009d4 <fsipc+0x26>
    fsenv = ipc_find_env(ENV_TYPE_FS);
  8009c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8009ca:	e8 b8 12 00 00       	call   801c87 <ipc_find_env>
  8009cf:	a3 00 40 80 00       	mov    %eax,0x804000
  static_assert(sizeof(fsipcbuf) == PGSIZE);

  if (debug)
    cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t*)&fsipcbuf);

  ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009d4:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8009db:	00 
  8009dc:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8009e3:	00 
  8009e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009e8:	a1 00 40 80 00       	mov    0x804000,%eax
  8009ed:	89 04 24             	mov    %eax,(%esp)
  8009f0:	e8 27 12 00 00       	call   801c1c <ipc_send>
  return ipc_recv(NULL, dstva, NULL);
  8009f5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8009fc:	00 
  8009fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a01:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a08:	e8 89 11 00 00       	call   801b96 <ipc_recv>
}
  800a0d:	83 c4 10             	add    $0x10,%esp
  800a10:	5b                   	pop    %ebx
  800a11:	5e                   	pop    %esi
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	83 ec 08             	sub    $0x8,%esp
  fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a20:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.set_size.req_size = newsize;
  800a25:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a28:	a3 04 50 80 00       	mov    %eax,0x805004
  return fsipc(FSREQ_SET_SIZE, NULL);
  800a2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a32:	b8 02 00 00 00       	mov    $0x2,%eax
  800a37:	e8 72 ff ff ff       	call   8009ae <fsipc>
}
  800a3c:	c9                   	leave  
  800a3d:	c3                   	ret    

00800a3e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	83 ec 08             	sub    $0x8,%esp
  fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	8b 40 0c             	mov    0xc(%eax),%eax
  800a4a:	a3 00 50 80 00       	mov    %eax,0x805000
  return fsipc(FSREQ_FLUSH, NULL);
  800a4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a54:	b8 06 00 00 00       	mov    $0x6,%eax
  800a59:	e8 50 ff ff ff       	call   8009ae <fsipc>
}
  800a5e:	c9                   	leave  
  800a5f:	c3                   	ret    

00800a60 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	53                   	push   %ebx
  800a64:	83 ec 14             	sub    $0x14,%esp
  800a67:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int r;

  fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a70:	a3 00 50 80 00       	mov    %eax,0x805000
  if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a75:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7a:	b8 05 00 00 00       	mov    $0x5,%eax
  800a7f:	e8 2a ff ff ff       	call   8009ae <fsipc>
  800a84:	89 c2                	mov    %eax,%edx
  800a86:	85 d2                	test   %edx,%edx
  800a88:	78 2b                	js     800ab5 <devfile_stat+0x55>
    return r;
  strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a8a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800a91:	00 
  800a92:	89 1c 24             	mov    %ebx,(%esp)
  800a95:	e8 ad 0d 00 00       	call   801847 <strcpy>
  st->st_size = fsipcbuf.statRet.ret_size;
  800a9a:	a1 80 50 80 00       	mov    0x805080,%eax
  800a9f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800aa5:	a1 84 50 80 00       	mov    0x805084,%eax
  800aaa:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  return 0;
  800ab0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab5:	83 c4 14             	add    $0x14,%esp
  800ab8:	5b                   	pop    %ebx
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	83 ec 18             	sub    $0x18,%esp
  800ac1:	8b 45 10             	mov    0x10(%ebp),%eax
  // remember that write is always allowed to write *fewer*
  // bytes than requested.
  // LAB 5: Your code here
    int r;

    fsipcbuf.write.req_fileid = fd->fd_file.id;
  800ac4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac7:	8b 52 0c             	mov    0xc(%edx),%edx
  800aca:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  800ad0:	a3 04 50 80 00       	mov    %eax,0x805004

    size_t max_written = sizeof(fsipcbuf.write.req_buf);
    memmove(fsipcbuf.write.req_buf, buf, MIN(max_written, n));
  800ad5:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800ada:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800adf:	0f 47 c2             	cmova  %edx,%eax
  800ae2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ae6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aed:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800af4:	e8 eb 0e 00 00       	call   8019e4 <memmove>

    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800af9:	ba 00 00 00 00       	mov    $0x0,%edx
  800afe:	b8 04 00 00 00       	mov    $0x4,%eax
  800b03:	e8 a6 fe ff ff       	call   8009ae <fsipc>
        return r;

    return r;
}
  800b08:	c9                   	leave  
  800b09:	c3                   	ret    

00800b0a <devfile_read>:
// Returns:
//  The number of bytes successfully read.
//  < 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	53                   	push   %ebx
  800b0e:	83 ec 14             	sub    $0x14,%esp
  // filling fsipcbuf.read with the request arguments.  The
  // bytes read will be written back to fsipcbuf by the file
  // system server.
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b11:	8b 45 08             	mov    0x8(%ebp),%eax
  800b14:	8b 40 0c             	mov    0xc(%eax),%eax
  800b17:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  800b1c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b1f:	a3 04 50 80 00       	mov    %eax,0x805004
  if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b24:	ba 00 00 00 00       	mov    $0x0,%edx
  800b29:	b8 03 00 00 00       	mov    $0x3,%eax
  800b2e:	e8 7b fe ff ff       	call   8009ae <fsipc>
  800b33:	89 c3                	mov    %eax,%ebx
  800b35:	85 c0                	test   %eax,%eax
  800b37:	78 17                	js     800b50 <devfile_read+0x46>
    return r;

  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b39:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b3d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800b44:	00 
  800b45:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b48:	89 04 24             	mov    %eax,(%esp)
  800b4b:	e8 94 0e 00 00       	call   8019e4 <memmove>
  return r;
}
  800b50:	89 d8                	mov    %ebx,%eax
  800b52:	83 c4 14             	add    $0x14,%esp
  800b55:	5b                   	pop    %ebx
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <open>:
//  The file descriptor index on success
//  -E_BAD_PATH if the path is too long (>= MAXPATHLEN)
//  < 0 for other errors.
int
open(const char *path, int mode)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	53                   	push   %ebx
  800b5c:	83 ec 24             	sub    $0x24,%esp
  800b5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  // file descriptor.

  int r;
  struct Fd *fd;

  if (strlen(path) >= MAXPATHLEN)
  800b62:	89 1c 24             	mov    %ebx,(%esp)
  800b65:	e8 a6 0c 00 00       	call   801810 <strlen>
  800b6a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b6f:	7f 60                	jg     800bd1 <open+0x79>
    return -E_BAD_PATH;

  if ((r = fd_alloc(&fd)) < 0)
  800b71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b74:	89 04 24             	mov    %eax,(%esp)
  800b77:	e8 7b f8 ff ff       	call   8003f7 <fd_alloc>
  800b7c:	89 c2                	mov    %eax,%edx
  800b7e:	85 d2                	test   %edx,%edx
  800b80:	78 54                	js     800bd6 <open+0x7e>
    return r;

  strcpy(fsipcbuf.open.req_path, path);
  800b82:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b86:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800b8d:	e8 b5 0c 00 00       	call   801847 <strcpy>
  fsipcbuf.open.req_omode = mode;
  800b92:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b95:	a3 00 54 80 00       	mov    %eax,0x805400

  if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b9a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b9d:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba2:	e8 07 fe ff ff       	call   8009ae <fsipc>
  800ba7:	89 c3                	mov    %eax,%ebx
  800ba9:	85 c0                	test   %eax,%eax
  800bab:	79 17                	jns    800bc4 <open+0x6c>
    fd_close(fd, 0);
  800bad:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800bb4:	00 
  800bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bb8:	89 04 24             	mov    %eax,(%esp)
  800bbb:	e8 31 f9 ff ff       	call   8004f1 <fd_close>
    return r;
  800bc0:	89 d8                	mov    %ebx,%eax
  800bc2:	eb 12                	jmp    800bd6 <open+0x7e>
  }

  return fd2num(fd);
  800bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bc7:	89 04 24             	mov    %eax,(%esp)
  800bca:	e8 01 f8 ff ff       	call   8003d0 <fd2num>
  800bcf:	eb 05                	jmp    800bd6 <open+0x7e>

  int r;
  struct Fd *fd;

  if (strlen(path) >= MAXPATHLEN)
    return -E_BAD_PATH;
  800bd1:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
    fd_close(fd, 0);
    return r;
  }

  return fd2num(fd);
}
  800bd6:	83 c4 24             	add    $0x24,%esp
  800bd9:	5b                   	pop    %ebx
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	83 ec 08             	sub    $0x8,%esp
  // Ask the file server to update the disk
  // by writing any dirty blocks in the buffer cache.

  return fsipc(FSREQ_SYNC, NULL);
  800be2:	ba 00 00 00 00       	mov    $0x0,%edx
  800be7:	b8 08 00 00 00       	mov    $0x8,%eax
  800bec:	e8 bd fd ff ff       	call   8009ae <fsipc>
}
  800bf1:	c9                   	leave  
  800bf2:	c3                   	ret    

00800bf3 <devpipe_stat>:
  return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
  800bf8:	83 ec 10             	sub    $0x10,%esp
  800bfb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct Pipe *p = (struct Pipe*)fd2data(fd);
  800bfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800c01:	89 04 24             	mov    %eax,(%esp)
  800c04:	e8 d7 f7 ff ff       	call   8003e0 <fd2data>
  800c09:	89 c6                	mov    %eax,%esi

  strcpy(stat->st_name, "<pipe>");
  800c0b:	c7 44 24 04 64 20 80 	movl   $0x802064,0x4(%esp)
  800c12:	00 
  800c13:	89 1c 24             	mov    %ebx,(%esp)
  800c16:	e8 2c 0c 00 00       	call   801847 <strcpy>
  stat->st_size = p->p_wpos - p->p_rpos;
  800c1b:	8b 46 04             	mov    0x4(%esi),%eax
  800c1e:	2b 06                	sub    (%esi),%eax
  800c20:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  stat->st_isdir = 0;
  800c26:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c2d:	00 00 00 
  stat->st_dev = &devpipe;
  800c30:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800c37:	30 80 00 
  return 0;
}
  800c3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3f:	83 c4 10             	add    $0x10,%esp
  800c42:	5b                   	pop    %ebx
  800c43:	5e                   	pop    %esi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	53                   	push   %ebx
  800c4a:	83 ec 14             	sub    $0x14,%esp
  800c4d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  (void)sys_page_unmap(0, fd);
  800c50:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c54:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c5b:	e8 ae f5 ff ff       	call   80020e <sys_page_unmap>
  return sys_page_unmap(0, fd2data(fd));
  800c60:	89 1c 24             	mov    %ebx,(%esp)
  800c63:	e8 78 f7 ff ff       	call   8003e0 <fd2data>
  800c68:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c6c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c73:	e8 96 f5 ff ff       	call   80020e <sys_page_unmap>
}
  800c78:	83 c4 14             	add    $0x14,%esp
  800c7b:	5b                   	pop    %ebx
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    

00800c7e <_pipeisclosed>:
  return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	57                   	push   %edi
  800c82:	56                   	push   %esi
  800c83:	53                   	push   %ebx
  800c84:	83 ec 2c             	sub    $0x2c,%esp
  800c87:	89 c6                	mov    %eax,%esi
  800c89:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  int n, nn, ret;

  while (1) {
    n = thisenv->env_runs;
  800c8c:	a1 04 40 80 00       	mov    0x804004,%eax
  800c91:	8b 58 58             	mov    0x58(%eax),%ebx
    ret = pageref(fd) == pageref(p);
  800c94:	89 34 24             	mov    %esi,(%esp)
  800c97:	e8 23 10 00 00       	call   801cbf <pageref>
  800c9c:	89 c7                	mov    %eax,%edi
  800c9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ca1:	89 04 24             	mov    %eax,(%esp)
  800ca4:	e8 16 10 00 00       	call   801cbf <pageref>
  800ca9:	39 c7                	cmp    %eax,%edi
  800cab:	0f 94 c2             	sete   %dl
  800cae:	0f b6 c2             	movzbl %dl,%eax
    nn = thisenv->env_runs;
  800cb1:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  800cb7:	8b 79 58             	mov    0x58(%ecx),%edi
    if (n == nn)
  800cba:	39 fb                	cmp    %edi,%ebx
  800cbc:	74 21                	je     800cdf <_pipeisclosed+0x61>
      return ret;
    if (n != nn && ret == 1)
  800cbe:	84 d2                	test   %dl,%dl
  800cc0:	74 ca                	je     800c8c <_pipeisclosed+0xe>
      cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800cc2:	8b 51 58             	mov    0x58(%ecx),%edx
  800cc5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cc9:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ccd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cd1:	c7 04 24 6b 20 80 00 	movl   $0x80206b,(%esp)
  800cd8:	e8 42 05 00 00       	call   80121f <cprintf>
  800cdd:	eb ad                	jmp    800c8c <_pipeisclosed+0xe>
  }
}
  800cdf:	83 c4 2c             	add    $0x2c,%esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <devpipe_write>:
  return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	83 ec 1c             	sub    $0x1c,%esp
  800cf0:	8b 75 08             	mov    0x8(%ebp),%esi
  const uint8_t *buf;
  size_t i;
  struct Pipe *p;

  p = (struct Pipe*)fd2data(fd);
  800cf3:	89 34 24             	mov    %esi,(%esp)
  800cf6:	e8 e5 f6 ff ff       	call   8003e0 <fd2data>
  800cfb:	89 c3                	mov    %eax,%ebx
  if (debug)
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  800cfd:	bf 00 00 00 00       	mov    $0x0,%edi
  800d02:	eb 45                	jmp    800d49 <devpipe_write+0x62>
    while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
      // pipe is full
      // if all the readers are gone
      // (it's only writers like us now),
      // note eof
      if (_pipeisclosed(fd, p))
  800d04:	89 da                	mov    %ebx,%edx
  800d06:	89 f0                	mov    %esi,%eax
  800d08:	e8 71 ff ff ff       	call   800c7e <_pipeisclosed>
  800d0d:	85 c0                	test   %eax,%eax
  800d0f:	75 41                	jne    800d52 <devpipe_write+0x6b>
        return 0;
      // yield and see what happens
      if (debug)
        cprintf("devpipe_write yield\n");
      sys_yield();
  800d11:	e8 32 f4 ff ff       	call   800148 <sys_yield>
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
    while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800d16:	8b 43 04             	mov    0x4(%ebx),%eax
  800d19:	8b 0b                	mov    (%ebx),%ecx
  800d1b:	8d 51 20             	lea    0x20(%ecx),%edx
  800d1e:	39 d0                	cmp    %edx,%eax
  800d20:	73 e2                	jae    800d04 <devpipe_write+0x1d>
        cprintf("devpipe_write yield\n");
      sys_yield();
    }
    // there's room for a byte.  store it.
    // wait to increment wpos until the byte is stored!
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800d22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d25:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800d29:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800d2c:	99                   	cltd   
  800d2d:	c1 ea 1b             	shr    $0x1b,%edx
  800d30:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  800d33:	83 e1 1f             	and    $0x1f,%ecx
  800d36:	29 d1                	sub    %edx,%ecx
  800d38:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  800d3c:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
    p->p_wpos++;
  800d40:	83 c0 01             	add    $0x1,%eax
  800d43:	89 43 04             	mov    %eax,0x4(%ebx)
  if (debug)
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  800d46:	83 c7 01             	add    $0x1,%edi
  800d49:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800d4c:	75 c8                	jne    800d16 <devpipe_write+0x2f>
    // wait to increment wpos until the byte is stored!
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
    p->p_wpos++;
  }

  return i;
  800d4e:	89 f8                	mov    %edi,%eax
  800d50:	eb 05                	jmp    800d57 <devpipe_write+0x70>
      // pipe is full
      // if all the readers are gone
      // (it's only writers like us now),
      // note eof
      if (_pipeisclosed(fd, p))
        return 0;
  800d52:	b8 00 00 00 00       	mov    $0x0,%eax
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
    p->p_wpos++;
  }

  return i;
}
  800d57:	83 c4 1c             	add    $0x1c,%esp
  800d5a:	5b                   	pop    %ebx
  800d5b:	5e                   	pop    %esi
  800d5c:	5f                   	pop    %edi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <devpipe_read>:
  return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	57                   	push   %edi
  800d63:	56                   	push   %esi
  800d64:	53                   	push   %ebx
  800d65:	83 ec 1c             	sub    $0x1c,%esp
  800d68:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint8_t *buf;
  size_t i;
  struct Pipe *p;

  p = (struct Pipe*)fd2data(fd);
  800d6b:	89 3c 24             	mov    %edi,(%esp)
  800d6e:	e8 6d f6 ff ff       	call   8003e0 <fd2data>
  800d73:	89 c3                	mov    %eax,%ebx
  if (debug)
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  800d75:	be 00 00 00 00       	mov    $0x0,%esi
  800d7a:	eb 3d                	jmp    800db9 <devpipe_read+0x5a>
    while (p->p_rpos == p->p_wpos) {
      // pipe is empty
      // if we got any data, return it
      if (i > 0)
  800d7c:	85 f6                	test   %esi,%esi
  800d7e:	74 04                	je     800d84 <devpipe_read+0x25>
        return i;
  800d80:	89 f0                	mov    %esi,%eax
  800d82:	eb 43                	jmp    800dc7 <devpipe_read+0x68>
      // if all the writers are gone, note eof
      if (_pipeisclosed(fd, p))
  800d84:	89 da                	mov    %ebx,%edx
  800d86:	89 f8                	mov    %edi,%eax
  800d88:	e8 f1 fe ff ff       	call   800c7e <_pipeisclosed>
  800d8d:	85 c0                	test   %eax,%eax
  800d8f:	75 31                	jne    800dc2 <devpipe_read+0x63>
        return 0;
      // yield and see what happens
      if (debug)
        cprintf("devpipe_read yield\n");
      sys_yield();
  800d91:	e8 b2 f3 ff ff       	call   800148 <sys_yield>
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
    while (p->p_rpos == p->p_wpos) {
  800d96:	8b 03                	mov    (%ebx),%eax
  800d98:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d9b:	74 df                	je     800d7c <devpipe_read+0x1d>
        cprintf("devpipe_read yield\n");
      sys_yield();
    }
    // there's a byte.  take it.
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d9d:	99                   	cltd   
  800d9e:	c1 ea 1b             	shr    $0x1b,%edx
  800da1:	01 d0                	add    %edx,%eax
  800da3:	83 e0 1f             	and    $0x1f,%eax
  800da6:	29 d0                	sub    %edx,%eax
  800da8:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800dad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db0:	88 04 31             	mov    %al,(%ecx,%esi,1)
    p->p_rpos++;
  800db3:	83 03 01             	addl   $0x1,(%ebx)
  if (debug)
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  800db6:	83 c6 01             	add    $0x1,%esi
  800db9:	3b 75 10             	cmp    0x10(%ebp),%esi
  800dbc:	75 d8                	jne    800d96 <devpipe_read+0x37>
    // there's a byte.  take it.
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
    p->p_rpos++;
  }
  return i;
  800dbe:	89 f0                	mov    %esi,%eax
  800dc0:	eb 05                	jmp    800dc7 <devpipe_read+0x68>
      // if we got any data, return it
      if (i > 0)
        return i;
      // if all the writers are gone, note eof
      if (_pipeisclosed(fd, p))
        return 0;
  800dc2:	b8 00 00 00 00       	mov    $0x0,%eax
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
    p->p_rpos++;
  }
  return i;
}
  800dc7:	83 c4 1c             	add    $0x1c,%esp
  800dca:	5b                   	pop    %ebx
  800dcb:	5e                   	pop    %esi
  800dcc:	5f                   	pop    %edi
  800dcd:	5d                   	pop    %ebp
  800dce:	c3                   	ret    

00800dcf <pipe>:
  uint8_t p_buf[PIPEBUFSIZ];    // data buffer
};

int
pipe(int pfd[2])
{
  800dcf:	55                   	push   %ebp
  800dd0:	89 e5                	mov    %esp,%ebp
  800dd2:	56                   	push   %esi
  800dd3:	53                   	push   %ebx
  800dd4:	83 ec 30             	sub    $0x30,%esp
  int r;
  struct Fd *fd0, *fd1;
  void *va;

  // allocate the file descriptor table entries
  if ((r = fd_alloc(&fd0)) < 0
  800dd7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800dda:	89 04 24             	mov    %eax,(%esp)
  800ddd:	e8 15 f6 ff ff       	call   8003f7 <fd_alloc>
  800de2:	89 c2                	mov    %eax,%edx
  800de4:	85 d2                	test   %edx,%edx
  800de6:	0f 88 4d 01 00 00    	js     800f39 <pipe+0x16a>
      || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dec:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800df3:	00 
  800df4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800df7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dfb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e02:	e8 60 f3 ff ff       	call   800167 <sys_page_alloc>
  800e07:	89 c2                	mov    %eax,%edx
  800e09:	85 d2                	test   %edx,%edx
  800e0b:	0f 88 28 01 00 00    	js     800f39 <pipe+0x16a>
    goto err;

  if ((r = fd_alloc(&fd1)) < 0
  800e11:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e14:	89 04 24             	mov    %eax,(%esp)
  800e17:	e8 db f5 ff ff       	call   8003f7 <fd_alloc>
  800e1c:	89 c3                	mov    %eax,%ebx
  800e1e:	85 c0                	test   %eax,%eax
  800e20:	0f 88 fe 00 00 00    	js     800f24 <pipe+0x155>
      || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e26:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e2d:	00 
  800e2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e31:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e3c:	e8 26 f3 ff ff       	call   800167 <sys_page_alloc>
  800e41:	89 c3                	mov    %eax,%ebx
  800e43:	85 c0                	test   %eax,%eax
  800e45:	0f 88 d9 00 00 00    	js     800f24 <pipe+0x155>
    goto err1;

  // allocate the pipe structure as first data page in both
  va = fd2data(fd0);
  800e4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e4e:	89 04 24             	mov    %eax,(%esp)
  800e51:	e8 8a f5 ff ff       	call   8003e0 <fd2data>
  800e56:	89 c6                	mov    %eax,%esi
  if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e58:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e5f:	00 
  800e60:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e64:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e6b:	e8 f7 f2 ff ff       	call   800167 <sys_page_alloc>
  800e70:	89 c3                	mov    %eax,%ebx
  800e72:	85 c0                	test   %eax,%eax
  800e74:	0f 88 97 00 00 00    	js     800f11 <pipe+0x142>
    goto err2;
  if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e7d:	89 04 24             	mov    %eax,(%esp)
  800e80:	e8 5b f5 ff ff       	call   8003e0 <fd2data>
  800e85:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  800e8c:	00 
  800e8d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e91:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e98:	00 
  800e99:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ea4:	e8 12 f3 ff ff       	call   8001bb <sys_page_map>
  800ea9:	89 c3                	mov    %eax,%ebx
  800eab:	85 c0                	test   %eax,%eax
  800ead:	78 52                	js     800f01 <pipe+0x132>
    goto err3;

  // set up fd structures
  fd0->fd_dev_id = devpipe.dev_id;
  800eaf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eb8:	89 10                	mov    %edx,(%eax)
  fd0->fd_omode = O_RDONLY;
  800eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ebd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

  fd1->fd_dev_id = devpipe.dev_id;
  800ec4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800eca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ecd:	89 10                	mov    %edx,(%eax)
  fd1->fd_omode = O_WRONLY;
  800ecf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ed2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

  if (debug)
    cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

  pfd[0] = fd2num(fd0);
  800ed9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800edc:	89 04 24             	mov    %eax,(%esp)
  800edf:	e8 ec f4 ff ff       	call   8003d0 <fd2num>
  800ee4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee7:	89 01                	mov    %eax,(%ecx)
  pfd[1] = fd2num(fd1);
  800ee9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eec:	89 04 24             	mov    %eax,(%esp)
  800eef:	e8 dc f4 ff ff       	call   8003d0 <fd2num>
  800ef4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef7:	89 41 04             	mov    %eax,0x4(%ecx)
  return 0;
  800efa:	b8 00 00 00 00       	mov    $0x0,%eax
  800eff:	eb 38                	jmp    800f39 <pipe+0x16a>

err3:
  sys_page_unmap(0, va);
  800f01:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f0c:	e8 fd f2 ff ff       	call   80020e <sys_page_unmap>
err2:
  sys_page_unmap(0, fd1);
  800f11:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f14:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f18:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f1f:	e8 ea f2 ff ff       	call   80020e <sys_page_unmap>
err1:
  sys_page_unmap(0, fd0);
  800f24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f27:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f2b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f32:	e8 d7 f2 ff ff       	call   80020e <sys_page_unmap>
  800f37:	89 d8                	mov    %ebx,%eax
err:
  return r;
}
  800f39:	83 c4 30             	add    $0x30,%esp
  800f3c:	5b                   	pop    %ebx
  800f3d:	5e                   	pop    %esi
  800f3e:	5d                   	pop    %ebp
  800f3f:	c3                   	ret    

00800f40 <pipeisclosed>:
  }
}

int
pipeisclosed(int fdnum)
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	83 ec 28             	sub    $0x28,%esp
  struct Fd *fd;
  struct Pipe *p;
  int r;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f46:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f49:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f50:	89 04 24             	mov    %eax,(%esp)
  800f53:	e8 ee f4 ff ff       	call   800446 <fd_lookup>
  800f58:	89 c2                	mov    %eax,%edx
  800f5a:	85 d2                	test   %edx,%edx
  800f5c:	78 15                	js     800f73 <pipeisclosed+0x33>
    return r;
  p = (struct Pipe*)fd2data(fd);
  800f5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f61:	89 04 24             	mov    %eax,(%esp)
  800f64:	e8 77 f4 ff ff       	call   8003e0 <fd2data>
  return _pipeisclosed(fd, p);
  800f69:	89 c2                	mov    %eax,%edx
  800f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f6e:	e8 0b fd ff ff       	call   800c7e <_pipeisclosed>
}
  800f73:	c9                   	leave  
  800f74:	c3                   	ret    
  800f75:	66 90                	xchg   %ax,%ax
  800f77:	66 90                	xchg   %ax,%ax
  800f79:	66 90                	xchg   %ax,%ax
  800f7b:	66 90                	xchg   %ax,%ax
  800f7d:	66 90                	xchg   %ax,%ax
  800f7f:	90                   	nop

00800f80 <devcons_close>:
  return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  USED(fd);

  return 0;
}
  800f83:	b8 00 00 00 00       	mov    $0x0,%eax
  800f88:	5d                   	pop    %ebp
  800f89:	c3                   	ret    

00800f8a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f8a:	55                   	push   %ebp
  800f8b:	89 e5                	mov    %esp,%ebp
  800f8d:	83 ec 18             	sub    $0x18,%esp
  strcpy(stat->st_name, "<cons>");
  800f90:	c7 44 24 04 83 20 80 	movl   $0x802083,0x4(%esp)
  800f97:	00 
  800f98:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f9b:	89 04 24             	mov    %eax,(%esp)
  800f9e:	e8 a4 08 00 00       	call   801847 <strcpy>
  return 0;
}
  800fa3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa8:	c9                   	leave  
  800fa9:	c3                   	ret    

00800faa <devcons_write>:
  return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	57                   	push   %edi
  800fae:	56                   	push   %esi
  800faf:	53                   	push   %ebx
  800fb0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  800fb6:	bb 00 00 00 00       	mov    $0x0,%ebx
    m = n - tot;
    if (m > sizeof(buf) - 1)
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
  800fbb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  800fc1:	eb 31                	jmp    800ff4 <devcons_write+0x4a>
    m = n - tot;
  800fc3:	8b 75 10             	mov    0x10(%ebp),%esi
  800fc6:	29 de                	sub    %ebx,%esi
    if (m > sizeof(buf) - 1)
  800fc8:	83 fe 7f             	cmp    $0x7f,%esi
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
    m = n - tot;
  800fcb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800fd0:	0f 47 f2             	cmova  %edx,%esi
    if (m > sizeof(buf) - 1)
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
  800fd3:	89 74 24 08          	mov    %esi,0x8(%esp)
  800fd7:	03 45 0c             	add    0xc(%ebp),%eax
  800fda:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fde:	89 3c 24             	mov    %edi,(%esp)
  800fe1:	e8 fe 09 00 00       	call   8019e4 <memmove>
    sys_cputs(buf, m);
  800fe6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fea:	89 3c 24             	mov    %edi,(%esp)
  800fed:	e8 a8 f0 ff ff       	call   80009a <sys_cputs>
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  800ff2:	01 f3                	add    %esi,%ebx
  800ff4:	89 d8                	mov    %ebx,%eax
  800ff6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800ff9:	72 c8                	jb     800fc3 <devcons_write+0x19>
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
    sys_cputs(buf, m);
  }
  return tot;
}
  800ffb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801001:	5b                   	pop    %ebx
  801002:	5e                   	pop    %esi
  801003:	5f                   	pop    %edi
  801004:	5d                   	pop    %ebp
  801005:	c3                   	ret    

00801006 <devcons_read>:
  return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801006:	55                   	push   %ebp
  801007:	89 e5                	mov    %esp,%ebp
  801009:	83 ec 08             	sub    $0x8,%esp
  int c;

  if (n == 0)
    return 0;
  80100c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  int c;

  if (n == 0)
  801011:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801015:	75 07                	jne    80101e <devcons_read+0x18>
  801017:	eb 2a                	jmp    801043 <devcons_read+0x3d>
    return 0;

  while ((c = sys_cgetc()) == 0)
    sys_yield();
  801019:	e8 2a f1 ff ff       	call   800148 <sys_yield>
  int c;

  if (n == 0)
    return 0;

  while ((c = sys_cgetc()) == 0)
  80101e:	66 90                	xchg   %ax,%ax
  801020:	e8 93 f0 ff ff       	call   8000b8 <sys_cgetc>
  801025:	85 c0                	test   %eax,%eax
  801027:	74 f0                	je     801019 <devcons_read+0x13>
    sys_yield();
  if (c < 0)
  801029:	85 c0                	test   %eax,%eax
  80102b:	78 16                	js     801043 <devcons_read+0x3d>
    return c;
  if (c == 0x04)        // ctl-d is eof
  80102d:	83 f8 04             	cmp    $0x4,%eax
  801030:	74 0c                	je     80103e <devcons_read+0x38>
    return 0;
  *(char*)vbuf = c;
  801032:	8b 55 0c             	mov    0xc(%ebp),%edx
  801035:	88 02                	mov    %al,(%edx)
  return 1;
  801037:	b8 01 00 00 00       	mov    $0x1,%eax
  80103c:	eb 05                	jmp    801043 <devcons_read+0x3d>
  while ((c = sys_cgetc()) == 0)
    sys_yield();
  if (c < 0)
    return c;
  if (c == 0x04)        // ctl-d is eof
    return 0;
  80103e:	b8 00 00 00 00       	mov    $0x0,%eax
  *(char*)vbuf = c;
  return 1;
}
  801043:	c9                   	leave  
  801044:	c3                   	ret    

00801045 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801045:	55                   	push   %ebp
  801046:	89 e5                	mov    %esp,%ebp
  801048:	83 ec 28             	sub    $0x28,%esp
  char c = ch;
  80104b:	8b 45 08             	mov    0x8(%ebp),%eax
  80104e:	88 45 f7             	mov    %al,-0x9(%ebp)

  // Unlike standard Unix's putchar,
  // the cputchar function _always_ outputs to the system console.
  sys_cputs(&c, 1);
  801051:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801058:	00 
  801059:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80105c:	89 04 24             	mov    %eax,(%esp)
  80105f:	e8 36 f0 ff ff       	call   80009a <sys_cputs>
}
  801064:	c9                   	leave  
  801065:	c3                   	ret    

00801066 <getchar>:

int
getchar(void)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	83 ec 28             	sub    $0x28,%esp
  int r;

  // JOS does, however, support standard _input_ redirection,
  // allowing the user to redirect script files to the shell and such.
  // getchar() reads a character from file descriptor 0.
  r = read(0, &c, 1);
  80106c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801073:	00 
  801074:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801077:	89 44 24 04          	mov    %eax,0x4(%esp)
  80107b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801082:	e8 4e f6 ff ff       	call   8006d5 <read>
  if (r < 0)
  801087:	85 c0                	test   %eax,%eax
  801089:	78 0f                	js     80109a <getchar+0x34>
    return r;
  if (r < 1)
  80108b:	85 c0                	test   %eax,%eax
  80108d:	7e 06                	jle    801095 <getchar+0x2f>
    return -E_EOF;
  return c;
  80108f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801093:	eb 05                	jmp    80109a <getchar+0x34>
  // getchar() reads a character from file descriptor 0.
  r = read(0, &c, 1);
  if (r < 0)
    return r;
  if (r < 1)
    return -E_EOF;
  801095:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  /* int r;
  // sys_cgetc does not block, but getchar should.
  while ((r = sys_cgetc()) == 0)
    sys_yield();
  return r; */
}
  80109a:	c9                   	leave  
  80109b:	c3                   	ret    

0080109c <iscons>:
  .dev_stat   =     devcons_stat
};

int
iscons(int fdnum)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	83 ec 28             	sub    $0x28,%esp
  int r;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ac:	89 04 24             	mov    %eax,(%esp)
  8010af:	e8 92 f3 ff ff       	call   800446 <fd_lookup>
  8010b4:	85 c0                	test   %eax,%eax
  8010b6:	78 11                	js     8010c9 <iscons+0x2d>
    return r;
  return fd->fd_dev_id == devcons.dev_id;
  8010b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010bb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8010c1:	39 10                	cmp    %edx,(%eax)
  8010c3:	0f 94 c0             	sete   %al
  8010c6:	0f b6 c0             	movzbl %al,%eax
}
  8010c9:	c9                   	leave  
  8010ca:	c3                   	ret    

008010cb <opencons>:

int
opencons(void)
{
  8010cb:	55                   	push   %ebp
  8010cc:	89 e5                	mov    %esp,%ebp
  8010ce:	83 ec 28             	sub    $0x28,%esp
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
  8010d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010d4:	89 04 24             	mov    %eax,(%esp)
  8010d7:	e8 1b f3 ff ff       	call   8003f7 <fd_alloc>
    return r;
  8010dc:	89 c2                	mov    %eax,%edx
opencons(void)
{
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	78 40                	js     801122 <opencons+0x57>
    return r;
  if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8010e2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8010e9:	00 
  8010ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010f8:	e8 6a f0 ff ff       	call   800167 <sys_page_alloc>
    return r;
  8010fd:	89 c2                	mov    %eax,%edx
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
    return r;
  if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8010ff:	85 c0                	test   %eax,%eax
  801101:	78 1f                	js     801122 <opencons+0x57>
    return r;
  fd->fd_dev_id = devcons.dev_id;
  801103:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801109:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80110c:	89 10                	mov    %edx,(%eax)
  fd->fd_omode = O_RDWR;
  80110e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801111:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
  return fd2num(fd);
  801118:	89 04 24             	mov    %eax,(%esp)
  80111b:	e8 b0 f2 ff ff       	call   8003d0 <fd2num>
  801120:	89 c2                	mov    %eax,%edx
}
  801122:	89 d0                	mov    %edx,%eax
  801124:	c9                   	leave  
  801125:	c3                   	ret    

00801126 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801126:	55                   	push   %ebp
  801127:	89 e5                	mov    %esp,%ebp
  801129:	56                   	push   %esi
  80112a:	53                   	push   %ebx
  80112b:	83 ec 20             	sub    $0x20,%esp
  va_list ap;

  va_start(ap, fmt);
  80112e:	8d 5d 14             	lea    0x14(%ebp),%ebx

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  801131:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801137:	e8 ed ef ff ff       	call   800129 <sys_getenvid>
  80113c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80113f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801143:	8b 55 08             	mov    0x8(%ebp),%edx
  801146:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80114a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80114e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801152:	c7 04 24 90 20 80 00 	movl   $0x802090,(%esp)
  801159:	e8 c1 00 00 00       	call   80121f <cprintf>
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  80115e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801162:	8b 45 10             	mov    0x10(%ebp),%eax
  801165:	89 04 24             	mov    %eax,(%esp)
  801168:	e8 51 00 00 00       	call   8011be <vcprintf>
  cprintf("\n");
  80116d:	c7 04 24 7c 20 80 00 	movl   $0x80207c,(%esp)
  801174:	e8 a6 00 00 00       	call   80121f <cprintf>

  // Cause a breakpoint exception
  while (1)
    asm volatile ("int3");
  801179:	cc                   	int3   
  80117a:	eb fd                	jmp    801179 <_panic+0x53>

0080117c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80117c:	55                   	push   %ebp
  80117d:	89 e5                	mov    %esp,%ebp
  80117f:	53                   	push   %ebx
  801180:	83 ec 14             	sub    $0x14,%esp
  801183:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  b->buf[b->idx++] = ch;
  801186:	8b 13                	mov    (%ebx),%edx
  801188:	8d 42 01             	lea    0x1(%edx),%eax
  80118b:	89 03                	mov    %eax,(%ebx)
  80118d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801190:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
  if (b->idx == 256-1) {
  801194:	3d ff 00 00 00       	cmp    $0xff,%eax
  801199:	75 19                	jne    8011b4 <putch+0x38>
    sys_cputs(b->buf, b->idx);
  80119b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8011a2:	00 
  8011a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8011a6:	89 04 24             	mov    %eax,(%esp)
  8011a9:	e8 ec ee ff ff       	call   80009a <sys_cputs>
    b->idx = 0;
  8011ae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  }
  b->cnt++;
  8011b4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8011b8:	83 c4 14             	add    $0x14,%esp
  8011bb:	5b                   	pop    %ebx
  8011bc:	5d                   	pop    %ebp
  8011bd:	c3                   	ret    

008011be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
  8011c1:	81 ec 28 01 00 00    	sub    $0x128,%esp
  struct printbuf b;

  b.idx = 0;
  8011c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8011ce:	00 00 00 
  b.cnt = 0;
  8011d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8011d8:	00 00 00 
  vprintfmt((void*)putch, &b, fmt, ap);
  8011db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011e9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8011ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f3:	c7 04 24 7c 11 80 00 	movl   $0x80117c,(%esp)
  8011fa:	e8 af 01 00 00       	call   8013ae <vprintfmt>
  sys_cputs(b.buf, b.idx);
  8011ff:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801205:	89 44 24 04          	mov    %eax,0x4(%esp)
  801209:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80120f:	89 04 24             	mov    %eax,(%esp)
  801212:	e8 83 ee ff ff       	call   80009a <sys_cputs>

  return b.cnt;
}
  801217:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80121d:	c9                   	leave  
  80121e:	c3                   	ret    

0080121f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  801225:	8d 45 0c             	lea    0xc(%ebp),%eax
  cnt = vcprintf(fmt, ap);
  801228:	89 44 24 04          	mov    %eax,0x4(%esp)
  80122c:	8b 45 08             	mov    0x8(%ebp),%eax
  80122f:	89 04 24             	mov    %eax,(%esp)
  801232:	e8 87 ff ff ff       	call   8011be <vcprintf>
  va_end(ap);

  return cnt;
}
  801237:	c9                   	leave  
  801238:	c3                   	ret    
  801239:	66 90                	xchg   %ax,%ax
  80123b:	66 90                	xchg   %ax,%ax
  80123d:	66 90                	xchg   %ax,%ax
  80123f:	90                   	nop

00801240 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
         unsigned long long num, unsigned base, int width, int padc)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	57                   	push   %edi
  801244:	56                   	push   %esi
  801245:	53                   	push   %ebx
  801246:	83 ec 3c             	sub    $0x3c,%esp
  801249:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80124c:	89 d7                	mov    %edx,%edi
  80124e:	8b 45 08             	mov    0x8(%ebp),%eax
  801251:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801254:	8b 45 0c             	mov    0xc(%ebp),%eax
  801257:	89 c3                	mov    %eax,%ebx
  801259:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80125c:	8b 45 10             	mov    0x10(%ebp),%eax
  80125f:	8b 75 14             	mov    0x14(%ebp),%esi
  // first recursively print all preceding (more significant) digits
  if (num >= base)
  801262:	b9 00 00 00 00       	mov    $0x0,%ecx
  801267:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80126a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80126d:	39 d9                	cmp    %ebx,%ecx
  80126f:	72 05                	jb     801276 <printnum+0x36>
  801271:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  801274:	77 69                	ja     8012df <printnum+0x9f>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  801276:	8b 4d 18             	mov    0x18(%ebp),%ecx
  801279:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80127d:	83 ee 01             	sub    $0x1,%esi
  801280:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801284:	89 44 24 08          	mov    %eax,0x8(%esp)
  801288:	8b 44 24 08          	mov    0x8(%esp),%eax
  80128c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801290:	89 c3                	mov    %eax,%ebx
  801292:	89 d6                	mov    %edx,%esi
  801294:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801297:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80129a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80129e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8012a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012a5:	89 04 24             	mov    %eax,(%esp)
  8012a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8012ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012af:	e8 4c 0a 00 00       	call   801d00 <__udivdi3>
  8012b4:	89 d9                	mov    %ebx,%ecx
  8012b6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012ba:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012be:	89 04 24             	mov    %eax,(%esp)
  8012c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012c5:	89 fa                	mov    %edi,%edx
  8012c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012ca:	e8 71 ff ff ff       	call   801240 <printnum>
  8012cf:	eb 1b                	jmp    8012ec <printnum+0xac>
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
      putch(padc, putdat);
  8012d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012d5:	8b 45 18             	mov    0x18(%ebp),%eax
  8012d8:	89 04 24             	mov    %eax,(%esp)
  8012db:	ff d3                	call   *%ebx
  8012dd:	eb 03                	jmp    8012e2 <printnum+0xa2>
  8012df:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  // first recursively print all preceding (more significant) digits
  if (num >= base)
    printnum(putch, putdat, num / base, base, width - 1, padc);
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
  8012e2:	83 ee 01             	sub    $0x1,%esi
  8012e5:	85 f6                	test   %esi,%esi
  8012e7:	7f e8                	jg     8012d1 <printnum+0x91>
  8012e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
      putch(padc, putdat);
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8012ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012f0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8012f7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8012fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012fe:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801302:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801305:	89 04 24             	mov    %eax,(%esp)
  801308:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80130b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130f:	e8 1c 0b 00 00       	call   801e30 <__umoddi3>
  801314:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801318:	0f be 80 b3 20 80 00 	movsbl 0x8020b3(%eax),%eax
  80131f:	89 04 24             	mov    %eax,(%esp)
  801322:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801325:	ff d0                	call   *%eax
}
  801327:	83 c4 3c             	add    $0x3c,%esp
  80132a:	5b                   	pop    %ebx
  80132b:	5e                   	pop    %esi
  80132c:	5f                   	pop    %edi
  80132d:	5d                   	pop    %ebp
  80132e:	c3                   	ret    

0080132f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80132f:	55                   	push   %ebp
  801330:	89 e5                	mov    %esp,%ebp
  if (lflag >= 2)
  801332:	83 fa 01             	cmp    $0x1,%edx
  801335:	7e 0e                	jle    801345 <getuint+0x16>
    return va_arg(*ap, unsigned long long);
  801337:	8b 10                	mov    (%eax),%edx
  801339:	8d 4a 08             	lea    0x8(%edx),%ecx
  80133c:	89 08                	mov    %ecx,(%eax)
  80133e:	8b 02                	mov    (%edx),%eax
  801340:	8b 52 04             	mov    0x4(%edx),%edx
  801343:	eb 22                	jmp    801367 <getuint+0x38>
  else if (lflag)
  801345:	85 d2                	test   %edx,%edx
  801347:	74 10                	je     801359 <getuint+0x2a>
    return va_arg(*ap, unsigned long);
  801349:	8b 10                	mov    (%eax),%edx
  80134b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80134e:	89 08                	mov    %ecx,(%eax)
  801350:	8b 02                	mov    (%edx),%eax
  801352:	ba 00 00 00 00       	mov    $0x0,%edx
  801357:	eb 0e                	jmp    801367 <getuint+0x38>
  else
    return va_arg(*ap, unsigned int);
  801359:	8b 10                	mov    (%eax),%edx
  80135b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80135e:	89 08                	mov    %ecx,(%eax)
  801360:	8b 02                	mov    (%edx),%eax
  801362:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801367:	5d                   	pop    %ebp
  801368:	c3                   	ret    

00801369 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801369:	55                   	push   %ebp
  80136a:	89 e5                	mov    %esp,%ebp
  80136c:	8b 45 0c             	mov    0xc(%ebp),%eax
  b->cnt++;
  80136f:	83 40 08 01          	addl   $0x1,0x8(%eax)
  if (b->buf < b->ebuf)
  801373:	8b 10                	mov    (%eax),%edx
  801375:	3b 50 04             	cmp    0x4(%eax),%edx
  801378:	73 0a                	jae    801384 <sprintputch+0x1b>
    *b->buf++ = ch;
  80137a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80137d:	89 08                	mov    %ecx,(%eax)
  80137f:	8b 45 08             	mov    0x8(%ebp),%eax
  801382:	88 02                	mov    %al,(%edx)
}
  801384:	5d                   	pop    %ebp
  801385:	c3                   	ret    

00801386 <printfmt>:
  }
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
  801389:	83 ec 18             	sub    $0x18,%esp
  va_list ap;

  va_start(ap, fmt);
  80138c:	8d 45 14             	lea    0x14(%ebp),%eax
  vprintfmt(putch, putdat, fmt, ap);
  80138f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801393:	8b 45 10             	mov    0x10(%ebp),%eax
  801396:	89 44 24 08          	mov    %eax,0x8(%esp)
  80139a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80139d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a4:	89 04 24             	mov    %eax,(%esp)
  8013a7:	e8 02 00 00 00       	call   8013ae <vprintfmt>
  va_end(ap);
}
  8013ac:	c9                   	leave  
  8013ad:	c3                   	ret    

008013ae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8013ae:	55                   	push   %ebp
  8013af:	89 e5                	mov    %esp,%ebp
  8013b1:	57                   	push   %edi
  8013b2:	56                   	push   %esi
  8013b3:	53                   	push   %ebx
  8013b4:	83 ec 3c             	sub    $0x3c,%esp
  8013b7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8013ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013bd:	eb 14                	jmp    8013d3 <vprintfmt+0x25>
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
      if (ch == '\0')
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	0f 84 b3 03 00 00    	je     80177a <vprintfmt+0x3cc>
        return;
      putch(ch, putdat);
  8013c7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013cb:	89 04 24             	mov    %eax,(%esp)
  8013ce:	ff 55 08             	call   *0x8(%ebp)
  unsigned long long num;
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
  8013d1:	89 f3                	mov    %esi,%ebx
  8013d3:	8d 73 01             	lea    0x1(%ebx),%esi
  8013d6:	0f b6 03             	movzbl (%ebx),%eax
  8013d9:	83 f8 25             	cmp    $0x25,%eax
  8013dc:	75 e1                	jne    8013bf <vprintfmt+0x11>
  8013de:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8013e2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8013e9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8013f0:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8013f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8013fc:	eb 1d                	jmp    80141b <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  8013fe:	89 de                	mov    %ebx,%esi

    // flag to pad on the right
    case '-':
      padc = '-';
  801400:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  801404:	eb 15                	jmp    80141b <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  801406:	89 de                	mov    %ebx,%esi
      padc = '-';
      goto reswitch;

    // flag to pad with 0's instead of spaces
    case '0':
      padc = '0';
  801408:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80140c:	eb 0d                	jmp    80141b <vprintfmt+0x6d>
      altflag = 1;
      goto reswitch;

process_precision:
      if (width < 0)
        width = precision, precision = -1;
  80140e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801411:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801414:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80141b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80141e:	0f b6 0e             	movzbl (%esi),%ecx
  801421:	0f b6 c1             	movzbl %cl,%eax
  801424:	83 e9 23             	sub    $0x23,%ecx
  801427:	80 f9 55             	cmp    $0x55,%cl
  80142a:	0f 87 2a 03 00 00    	ja     80175a <vprintfmt+0x3ac>
  801430:	0f b6 c9             	movzbl %cl,%ecx
  801433:	ff 24 8d 00 22 80 00 	jmp    *0x802200(,%ecx,4)
  80143a:	89 de                	mov    %ebx,%esi
  80143c:	b9 00 00 00 00       	mov    $0x0,%ecx
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
        precision = precision * 10 + ch - '0';
  801441:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  801444:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
        ch = *fmt;
  801448:	0f be 06             	movsbl (%esi),%eax
        if (ch < '0' || ch > '9')
  80144b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80144e:	83 fb 09             	cmp    $0x9,%ebx
  801451:	77 36                	ja     801489 <vprintfmt+0xdb>
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
  801453:	83 c6 01             	add    $0x1,%esi
        precision = precision * 10 + ch - '0';
        ch = *fmt;
        if (ch < '0' || ch > '9')
          break;
      }
  801456:	eb e9                	jmp    801441 <vprintfmt+0x93>
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
  801458:	8b 45 14             	mov    0x14(%ebp),%eax
  80145b:	8d 48 04             	lea    0x4(%eax),%ecx
  80145e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801461:	8b 00                	mov    (%eax),%eax
  801463:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  801466:	89 de                	mov    %ebx,%esi
      }
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
      goto process_precision;
  801468:	eb 22                	jmp    80148c <vprintfmt+0xde>
  80146a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80146d:	85 c9                	test   %ecx,%ecx
  80146f:	b8 00 00 00 00       	mov    $0x0,%eax
  801474:	0f 49 c1             	cmovns %ecx,%eax
  801477:	89 45 dc             	mov    %eax,-0x24(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80147a:	89 de                	mov    %ebx,%esi
  80147c:	eb 9d                	jmp    80141b <vprintfmt+0x6d>
  80147e:	89 de                	mov    %ebx,%esi
      if (width < 0)
        width = 0;
      goto reswitch;

    case '#':
      altflag = 1;
  801480:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
      goto reswitch;
  801487:	eb 92                	jmp    80141b <vprintfmt+0x6d>
  801489:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

process_precision:
      if (width < 0)
  80148c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801490:	79 89                	jns    80141b <vprintfmt+0x6d>
  801492:	e9 77 ff ff ff       	jmp    80140e <vprintfmt+0x60>
        width = precision, precision = -1;
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
  801497:	83 c2 01             	add    $0x1,%edx
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80149a:	89 de                	mov    %ebx,%esi
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
      goto reswitch;
  80149c:	e9 7a ff ff ff       	jmp    80141b <vprintfmt+0x6d>

    // character
    case 'c':
      putch(va_arg(ap, int), putdat);
  8014a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a4:	8d 50 04             	lea    0x4(%eax),%edx
  8014a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8014aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014ae:	8b 00                	mov    (%eax),%eax
  8014b0:	89 04 24             	mov    %eax,(%esp)
  8014b3:	ff 55 08             	call   *0x8(%ebp)
      break;
  8014b6:	e9 18 ff ff ff       	jmp    8013d3 <vprintfmt+0x25>

    // error message
    case 'e':
      err = va_arg(ap, int);
  8014bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8014be:	8d 50 04             	lea    0x4(%eax),%edx
  8014c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8014c4:	8b 00                	mov    (%eax),%eax
  8014c6:	99                   	cltd   
  8014c7:	31 d0                	xor    %edx,%eax
  8014c9:	29 d0                	sub    %edx,%eax
      if (err < 0)
        err = -err;
      if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8014cb:	83 f8 0f             	cmp    $0xf,%eax
  8014ce:	7f 0b                	jg     8014db <vprintfmt+0x12d>
  8014d0:	8b 14 85 60 23 80 00 	mov    0x802360(,%eax,4),%edx
  8014d7:	85 d2                	test   %edx,%edx
  8014d9:	75 20                	jne    8014fb <vprintfmt+0x14d>
        printfmt(putch, putdat, "error %d", err);
  8014db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014df:	c7 44 24 08 cb 20 80 	movl   $0x8020cb,0x8(%esp)
  8014e6:	00 
  8014e7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ee:	89 04 24             	mov    %eax,(%esp)
  8014f1:	e8 90 fe ff ff       	call   801386 <printfmt>
  8014f6:	e9 d8 fe ff ff       	jmp    8013d3 <vprintfmt+0x25>
      else
        printfmt(putch, putdat, "%s", p);
  8014fb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8014ff:	c7 44 24 08 d4 20 80 	movl   $0x8020d4,0x8(%esp)
  801506:	00 
  801507:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80150b:	8b 45 08             	mov    0x8(%ebp),%eax
  80150e:	89 04 24             	mov    %eax,(%esp)
  801511:	e8 70 fe ff ff       	call   801386 <printfmt>
  801516:	e9 b8 fe ff ff       	jmp    8013d3 <vprintfmt+0x25>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80151b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80151e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801521:	89 45 d0             	mov    %eax,-0x30(%ebp)
        printfmt(putch, putdat, "%s", p);
      break;

    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
  801524:	8b 45 14             	mov    0x14(%ebp),%eax
  801527:	8d 50 04             	lea    0x4(%eax),%edx
  80152a:	89 55 14             	mov    %edx,0x14(%ebp)
  80152d:	8b 30                	mov    (%eax),%esi
        p = "(null)";
  80152f:	85 f6                	test   %esi,%esi
  801531:	b8 c4 20 80 00       	mov    $0x8020c4,%eax
  801536:	0f 44 f0             	cmove  %eax,%esi
      if (width > 0 && padc != '-')
  801539:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80153d:	0f 84 97 00 00 00    	je     8015da <vprintfmt+0x22c>
  801543:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  801547:	0f 8e 9b 00 00 00    	jle    8015e8 <vprintfmt+0x23a>
        for (width -= strnlen(p, precision); width > 0; width--)
  80154d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801551:	89 34 24             	mov    %esi,(%esp)
  801554:	e8 cf 02 00 00       	call   801828 <strnlen>
  801559:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80155c:	29 c2                	sub    %eax,%edx
  80155e:	89 55 d0             	mov    %edx,-0x30(%ebp)
          putch(padc, putdat);
  801561:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801565:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801568:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80156b:	8b 75 08             	mov    0x8(%ebp),%esi
  80156e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801571:	89 d3                	mov    %edx,%ebx
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
  801573:	eb 0f                	jmp    801584 <vprintfmt+0x1d6>
          putch(padc, putdat);
  801575:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801579:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80157c:	89 04 24             	mov    %eax,(%esp)
  80157f:	ff d6                	call   *%esi
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
  801581:	83 eb 01             	sub    $0x1,%ebx
  801584:	85 db                	test   %ebx,%ebx
  801586:	7f ed                	jg     801575 <vprintfmt+0x1c7>
  801588:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80158b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80158e:	85 d2                	test   %edx,%edx
  801590:	b8 00 00 00 00       	mov    $0x0,%eax
  801595:	0f 49 c2             	cmovns %edx,%eax
  801598:	29 c2                	sub    %eax,%edx
  80159a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80159d:	89 d7                	mov    %edx,%edi
  80159f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8015a2:	eb 50                	jmp    8015f4 <vprintfmt+0x246>
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
  8015a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8015a8:	74 1e                	je     8015c8 <vprintfmt+0x21a>
  8015aa:	0f be d2             	movsbl %dl,%edx
  8015ad:	83 ea 20             	sub    $0x20,%edx
  8015b0:	83 fa 5e             	cmp    $0x5e,%edx
  8015b3:	76 13                	jbe    8015c8 <vprintfmt+0x21a>
          putch('?', putdat);
  8015b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015bc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8015c3:	ff 55 08             	call   *0x8(%ebp)
  8015c6:	eb 0d                	jmp    8015d5 <vprintfmt+0x227>
        else
          putch(ch, putdat);
  8015c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015cb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015cf:	89 04 24             	mov    %eax,(%esp)
  8015d2:	ff 55 08             	call   *0x8(%ebp)
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8015d5:	83 ef 01             	sub    $0x1,%edi
  8015d8:	eb 1a                	jmp    8015f4 <vprintfmt+0x246>
  8015da:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8015dd:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8015e0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8015e3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8015e6:	eb 0c                	jmp    8015f4 <vprintfmt+0x246>
  8015e8:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8015eb:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8015ee:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8015f1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8015f4:	83 c6 01             	add    $0x1,%esi
  8015f7:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  8015fb:	0f be c2             	movsbl %dl,%eax
  8015fe:	85 c0                	test   %eax,%eax
  801600:	74 27                	je     801629 <vprintfmt+0x27b>
  801602:	85 db                	test   %ebx,%ebx
  801604:	78 9e                	js     8015a4 <vprintfmt+0x1f6>
  801606:	83 eb 01             	sub    $0x1,%ebx
  801609:	79 99                	jns    8015a4 <vprintfmt+0x1f6>
  80160b:	89 f8                	mov    %edi,%eax
  80160d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801610:	8b 75 08             	mov    0x8(%ebp),%esi
  801613:	89 c3                	mov    %eax,%ebx
  801615:	eb 1a                	jmp    801631 <vprintfmt+0x283>
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
        putch(' ', putdat);
  801617:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80161b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801622:	ff d6                	call   *%esi
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
  801624:	83 eb 01             	sub    $0x1,%ebx
  801627:	eb 08                	jmp    801631 <vprintfmt+0x283>
  801629:	89 fb                	mov    %edi,%ebx
  80162b:	8b 75 08             	mov    0x8(%ebp),%esi
  80162e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801631:	85 db                	test   %ebx,%ebx
  801633:	7f e2                	jg     801617 <vprintfmt+0x269>
  801635:	89 75 08             	mov    %esi,0x8(%ebp)
  801638:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80163b:	e9 93 fd ff ff       	jmp    8013d3 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  if (lflag >= 2)
  801640:	83 fa 01             	cmp    $0x1,%edx
  801643:	7e 16                	jle    80165b <vprintfmt+0x2ad>
    return va_arg(*ap, long long);
  801645:	8b 45 14             	mov    0x14(%ebp),%eax
  801648:	8d 50 08             	lea    0x8(%eax),%edx
  80164b:	89 55 14             	mov    %edx,0x14(%ebp)
  80164e:	8b 50 04             	mov    0x4(%eax),%edx
  801651:	8b 00                	mov    (%eax),%eax
  801653:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801656:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801659:	eb 32                	jmp    80168d <vprintfmt+0x2df>
  else if (lflag)
  80165b:	85 d2                	test   %edx,%edx
  80165d:	74 18                	je     801677 <vprintfmt+0x2c9>
    return va_arg(*ap, long);
  80165f:	8b 45 14             	mov    0x14(%ebp),%eax
  801662:	8d 50 04             	lea    0x4(%eax),%edx
  801665:	89 55 14             	mov    %edx,0x14(%ebp)
  801668:	8b 30                	mov    (%eax),%esi
  80166a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80166d:	89 f0                	mov    %esi,%eax
  80166f:	c1 f8 1f             	sar    $0x1f,%eax
  801672:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801675:	eb 16                	jmp    80168d <vprintfmt+0x2df>
  else
    return va_arg(*ap, int);
  801677:	8b 45 14             	mov    0x14(%ebp),%eax
  80167a:	8d 50 04             	lea    0x4(%eax),%edx
  80167d:	89 55 14             	mov    %edx,0x14(%ebp)
  801680:	8b 30                	mov    (%eax),%esi
  801682:	89 75 e0             	mov    %esi,-0x20(%ebp)
  801685:	89 f0                	mov    %esi,%eax
  801687:	c1 f8 1f             	sar    $0x1f,%eax
  80168a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        putch(' ', putdat);
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
  80168d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801690:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      if ((long long)num < 0) {
        putch('-', putdat);
        num = -(long long)num;
      }
      base = 10;
  801693:	b9 0a 00 00 00       	mov    $0xa,%ecx
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
      if ((long long)num < 0) {
  801698:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80169c:	0f 89 80 00 00 00    	jns    801722 <vprintfmt+0x374>
        putch('-', putdat);
  8016a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8016a6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8016ad:	ff 55 08             	call   *0x8(%ebp)
        num = -(long long)num;
  8016b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016b3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016b6:	f7 d8                	neg    %eax
  8016b8:	83 d2 00             	adc    $0x0,%edx
  8016bb:	f7 da                	neg    %edx
      }
      base = 10;
  8016bd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8016c2:	eb 5e                	jmp    801722 <vprintfmt+0x374>
      goto number;

    // unsigned decimal
    case 'u':
      num = getuint(&ap, lflag);
  8016c4:	8d 45 14             	lea    0x14(%ebp),%eax
  8016c7:	e8 63 fc ff ff       	call   80132f <getuint>
      base = 10;
  8016cc:	b9 0a 00 00 00       	mov    $0xa,%ecx
      goto number;
  8016d1:	eb 4f                	jmp    801722 <vprintfmt+0x374>

    // (unsigned) octal
    case 'o':
      num = getuint(&ap, lflag);
  8016d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8016d6:	e8 54 fc ff ff       	call   80132f <getuint>
      base = 8;
  8016db:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  8016e0:	eb 40                	jmp    801722 <vprintfmt+0x374>

    // pointer
    case 'p':
      putch('0', putdat);
  8016e2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8016e6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8016ed:	ff 55 08             	call   *0x8(%ebp)
      putch('x', putdat);
  8016f0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8016f4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8016fb:	ff 55 08             	call   *0x8(%ebp)
      num = (unsigned long long)
            (uintptr_t)va_arg(ap, void *);
  8016fe:	8b 45 14             	mov    0x14(%ebp),%eax
  801701:	8d 50 04             	lea    0x4(%eax),%edx
  801704:	89 55 14             	mov    %edx,0x14(%ebp)

    // pointer
    case 'p':
      putch('0', putdat);
      putch('x', putdat);
      num = (unsigned long long)
  801707:	8b 00                	mov    (%eax),%eax
  801709:	ba 00 00 00 00       	mov    $0x0,%edx
            (uintptr_t)va_arg(ap, void *);
      base = 16;
  80170e:	b9 10 00 00 00       	mov    $0x10,%ecx
      goto number;
  801713:	eb 0d                	jmp    801722 <vprintfmt+0x374>

    // (unsigned) hexadecimal
    case 'x':
      num = getuint(&ap, lflag);
  801715:	8d 45 14             	lea    0x14(%ebp),%eax
  801718:	e8 12 fc ff ff       	call   80132f <getuint>
      base = 16;
  80171d:	b9 10 00 00 00       	mov    $0x10,%ecx
number:
      printnum(putch, putdat, num, base, width, padc);
  801722:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  801726:	89 74 24 10          	mov    %esi,0x10(%esp)
  80172a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80172d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801731:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801735:	89 04 24             	mov    %eax,(%esp)
  801738:	89 54 24 04          	mov    %edx,0x4(%esp)
  80173c:	89 fa                	mov    %edi,%edx
  80173e:	8b 45 08             	mov    0x8(%ebp),%eax
  801741:	e8 fa fa ff ff       	call   801240 <printnum>
      break;
  801746:	e9 88 fc ff ff       	jmp    8013d3 <vprintfmt+0x25>

    // escaped '%' character
    case '%':
      putch(ch, putdat);
  80174b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80174f:	89 04 24             	mov    %eax,(%esp)
  801752:	ff 55 08             	call   *0x8(%ebp)
      break;
  801755:	e9 79 fc ff ff       	jmp    8013d3 <vprintfmt+0x25>

    // unrecognized escape sequence - just print it literally
    default:
      putch('%', putdat);
  80175a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80175e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801765:	ff 55 08             	call   *0x8(%ebp)
      for (fmt--; fmt[-1] != '%'; fmt--)
  801768:	89 f3                	mov    %esi,%ebx
  80176a:	eb 03                	jmp    80176f <vprintfmt+0x3c1>
  80176c:	83 eb 01             	sub    $0x1,%ebx
  80176f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  801773:	75 f7                	jne    80176c <vprintfmt+0x3be>
  801775:	e9 59 fc ff ff       	jmp    8013d3 <vprintfmt+0x25>
        /* do nothing */;
      break;
    }
  }
}
  80177a:	83 c4 3c             	add    $0x3c,%esp
  80177d:	5b                   	pop    %ebx
  80177e:	5e                   	pop    %esi
  80177f:	5f                   	pop    %edi
  801780:	5d                   	pop    %ebp
  801781:	c3                   	ret    

00801782 <vsnprintf>:
    *b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801782:	55                   	push   %ebp
  801783:	89 e5                	mov    %esp,%ebp
  801785:	83 ec 28             	sub    $0x28,%esp
  801788:	8b 45 08             	mov    0x8(%ebp),%eax
  80178b:	8b 55 0c             	mov    0xc(%ebp),%edx
  struct sprintbuf b = { buf, buf+n-1, 0 };
  80178e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801791:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801795:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801798:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  if (buf == NULL || n < 1)
  80179f:	85 c0                	test   %eax,%eax
  8017a1:	74 30                	je     8017d3 <vsnprintf+0x51>
  8017a3:	85 d2                	test   %edx,%edx
  8017a5:	7e 2c                	jle    8017d3 <vsnprintf+0x51>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void*)sprintputch, &b, fmt, ap);
  8017a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8017aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8017b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017b5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8017b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017bc:	c7 04 24 69 13 80 00 	movl   $0x801369,(%esp)
  8017c3:	e8 e6 fb ff ff       	call   8013ae <vprintfmt>

  // null terminate the buffer
  *b.buf = '\0';
  8017c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8017cb:	c6 00 00             	movb   $0x0,(%eax)

  return b.cnt;
  8017ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d1:	eb 05                	jmp    8017d8 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  struct sprintbuf b = { buf, buf+n-1, 0 };

  if (buf == NULL || n < 1)
    return -E_INVAL;
  8017d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

  // null terminate the buffer
  *b.buf = '\0';

  return b.cnt;
}
  8017d8:	c9                   	leave  
  8017d9:	c3                   	ret    

008017da <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8017da:	55                   	push   %ebp
  8017db:	89 e5                	mov    %esp,%ebp
  8017dd:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int rc;

  va_start(ap, fmt);
  8017e0:	8d 45 14             	lea    0x14(%ebp),%eax
  rc = vsnprintf(buf, n, fmt, ap);
  8017e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017e7:	8b 45 10             	mov    0x10(%ebp),%eax
  8017ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f8:	89 04 24             	mov    %eax,(%esp)
  8017fb:	e8 82 ff ff ff       	call   801782 <vsnprintf>
  va_end(ap);

  return rc;
}
  801800:	c9                   	leave  
  801801:	c3                   	ret    
  801802:	66 90                	xchg   %ax,%ax
  801804:	66 90                	xchg   %ax,%ax
  801806:	66 90                	xchg   %ax,%ax
  801808:	66 90                	xchg   %ax,%ax
  80180a:	66 90                	xchg   %ax,%ax
  80180c:	66 90                	xchg   %ax,%ax
  80180e:	66 90                	xchg   %ax,%ax

00801810 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for (n = 0; *s != '\0'; s++)
  801816:	b8 00 00 00 00       	mov    $0x0,%eax
  80181b:	eb 03                	jmp    801820 <strlen+0x10>
    n++;
  80181d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
  int n;

  for (n = 0; *s != '\0'; s++)
  801820:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801824:	75 f7                	jne    80181d <strlen+0xd>
    n++;
  return n;
}
  801826:	5d                   	pop    %ebp
  801827:	c3                   	ret    

00801828 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801828:	55                   	push   %ebp
  801829:	89 e5                	mov    %esp,%ebp
  80182b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80182e:	8b 55 0c             	mov    0xc(%ebp),%edx
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801831:	b8 00 00 00 00       	mov    $0x0,%eax
  801836:	eb 03                	jmp    80183b <strnlen+0x13>
    n++;
  801838:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80183b:	39 d0                	cmp    %edx,%eax
  80183d:	74 06                	je     801845 <strnlen+0x1d>
  80183f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801843:	75 f3                	jne    801838 <strnlen+0x10>
    n++;
  return n;
}
  801845:	5d                   	pop    %ebp
  801846:	c3                   	ret    

00801847 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
  80184a:	53                   	push   %ebx
  80184b:	8b 45 08             	mov    0x8(%ebp),%eax
  80184e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  801851:	89 c2                	mov    %eax,%edx
  801853:	83 c2 01             	add    $0x1,%edx
  801856:	83 c1 01             	add    $0x1,%ecx
  801859:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80185d:	88 5a ff             	mov    %bl,-0x1(%edx)
  801860:	84 db                	test   %bl,%bl
  801862:	75 ef                	jne    801853 <strcpy+0xc>
    /* do nothing */;
  return ret;
}
  801864:	5b                   	pop    %ebx
  801865:	5d                   	pop    %ebp
  801866:	c3                   	ret    

00801867 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	53                   	push   %ebx
  80186b:	83 ec 08             	sub    $0x8,%esp
  80186e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int len = strlen(dst);
  801871:	89 1c 24             	mov    %ebx,(%esp)
  801874:	e8 97 ff ff ff       	call   801810 <strlen>

  strcpy(dst + len, src);
  801879:	8b 55 0c             	mov    0xc(%ebp),%edx
  80187c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801880:	01 d8                	add    %ebx,%eax
  801882:	89 04 24             	mov    %eax,(%esp)
  801885:	e8 bd ff ff ff       	call   801847 <strcpy>
  return dst;
}
  80188a:	89 d8                	mov    %ebx,%eax
  80188c:	83 c4 08             	add    $0x8,%esp
  80188f:	5b                   	pop    %ebx
  801890:	5d                   	pop    %ebp
  801891:	c3                   	ret    

00801892 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  801892:	55                   	push   %ebp
  801893:	89 e5                	mov    %esp,%ebp
  801895:	56                   	push   %esi
  801896:	53                   	push   %ebx
  801897:	8b 75 08             	mov    0x8(%ebp),%esi
  80189a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80189d:	89 f3                	mov    %esi,%ebx
  80189f:	03 5d 10             	add    0x10(%ebp),%ebx
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  8018a2:	89 f2                	mov    %esi,%edx
  8018a4:	eb 0f                	jmp    8018b5 <strncpy+0x23>
    *dst++ = *src;
  8018a6:	83 c2 01             	add    $0x1,%edx
  8018a9:	0f b6 01             	movzbl (%ecx),%eax
  8018ac:	88 42 ff             	mov    %al,-0x1(%edx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  8018af:	80 39 01             	cmpb   $0x1,(%ecx)
  8018b2:	83 d9 ff             	sbb    $0xffffffff,%ecx
{
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  8018b5:	39 da                	cmp    %ebx,%edx
  8018b7:	75 ed                	jne    8018a6 <strncpy+0x14>
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  }
  return ret;
}
  8018b9:	89 f0                	mov    %esi,%eax
  8018bb:	5b                   	pop    %ebx
  8018bc:	5e                   	pop    %esi
  8018bd:	5d                   	pop    %ebp
  8018be:	c3                   	ret    

008018bf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	56                   	push   %esi
  8018c3:	53                   	push   %ebx
  8018c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8018c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018cd:	89 f0                	mov    %esi,%eax
  8018cf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  8018d3:	85 c9                	test   %ecx,%ecx
  8018d5:	75 0b                	jne    8018e2 <strlcpy+0x23>
  8018d7:	eb 1d                	jmp    8018f6 <strlcpy+0x37>
    while (--size > 0 && *src != '\0')
      *dst++ = *src++;
  8018d9:	83 c0 01             	add    $0x1,%eax
  8018dc:	83 c2 01             	add    $0x1,%edx
  8018df:	88 48 ff             	mov    %cl,-0x1(%eax)
{
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
    while (--size > 0 && *src != '\0')
  8018e2:	39 d8                	cmp    %ebx,%eax
  8018e4:	74 0b                	je     8018f1 <strlcpy+0x32>
  8018e6:	0f b6 0a             	movzbl (%edx),%ecx
  8018e9:	84 c9                	test   %cl,%cl
  8018eb:	75 ec                	jne    8018d9 <strlcpy+0x1a>
  8018ed:	89 c2                	mov    %eax,%edx
  8018ef:	eb 02                	jmp    8018f3 <strlcpy+0x34>
  8018f1:	89 c2                	mov    %eax,%edx
      *dst++ = *src++;
    *dst = '\0';
  8018f3:	c6 02 00             	movb   $0x0,(%edx)
  }
  return dst - dst_in;
  8018f6:	29 f0                	sub    %esi,%eax
}
  8018f8:	5b                   	pop    %ebx
  8018f9:	5e                   	pop    %esi
  8018fa:	5d                   	pop    %ebp
  8018fb:	c3                   	ret    

008018fc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8018fc:	55                   	push   %ebp
  8018fd:	89 e5                	mov    %esp,%ebp
  8018ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801902:	8b 55 0c             	mov    0xc(%ebp),%edx
  while (*p && *p == *q)
  801905:	eb 06                	jmp    80190d <strcmp+0x11>
    p++, q++;
  801907:	83 c1 01             	add    $0x1,%ecx
  80190a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
  while (*p && *p == *q)
  80190d:	0f b6 01             	movzbl (%ecx),%eax
  801910:	84 c0                	test   %al,%al
  801912:	74 04                	je     801918 <strcmp+0x1c>
  801914:	3a 02                	cmp    (%edx),%al
  801916:	74 ef                	je     801907 <strcmp+0xb>
    p++, q++;
  return (int)((unsigned char)*p - (unsigned char)*q);
  801918:	0f b6 c0             	movzbl %al,%eax
  80191b:	0f b6 12             	movzbl (%edx),%edx
  80191e:	29 d0                	sub    %edx,%eax
}
  801920:	5d                   	pop    %ebp
  801921:	c3                   	ret    

00801922 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801922:	55                   	push   %ebp
  801923:	89 e5                	mov    %esp,%ebp
  801925:	53                   	push   %ebx
  801926:	8b 45 08             	mov    0x8(%ebp),%eax
  801929:	8b 55 0c             	mov    0xc(%ebp),%edx
  80192c:	89 c3                	mov    %eax,%ebx
  80192e:	03 5d 10             	add    0x10(%ebp),%ebx
  while (n > 0 && *p && *p == *q)
  801931:	eb 06                	jmp    801939 <strncmp+0x17>
    n--, p++, q++;
  801933:	83 c0 01             	add    $0x1,%eax
  801936:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
  801939:	39 d8                	cmp    %ebx,%eax
  80193b:	74 15                	je     801952 <strncmp+0x30>
  80193d:	0f b6 08             	movzbl (%eax),%ecx
  801940:	84 c9                	test   %cl,%cl
  801942:	74 04                	je     801948 <strncmp+0x26>
  801944:	3a 0a                	cmp    (%edx),%cl
  801946:	74 eb                	je     801933 <strncmp+0x11>
    n--, p++, q++;
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  801948:	0f b6 00             	movzbl (%eax),%eax
  80194b:	0f b6 12             	movzbl (%edx),%edx
  80194e:	29 d0                	sub    %edx,%eax
  801950:	eb 05                	jmp    801957 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
    n--, p++, q++;
  if (n == 0)
    return 0;
  801952:	b8 00 00 00 00       	mov    $0x0,%eax
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
}
  801957:	5b                   	pop    %ebx
  801958:	5d                   	pop    %ebp
  801959:	c3                   	ret    

0080195a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80195a:	55                   	push   %ebp
  80195b:	89 e5                	mov    %esp,%ebp
  80195d:	8b 45 08             	mov    0x8(%ebp),%eax
  801960:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
  801964:	eb 07                	jmp    80196d <strchr+0x13>
    if (*s == c)
  801966:	38 ca                	cmp    %cl,%dl
  801968:	74 0f                	je     801979 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  for (; *s; s++)
  80196a:	83 c0 01             	add    $0x1,%eax
  80196d:	0f b6 10             	movzbl (%eax),%edx
  801970:	84 d2                	test   %dl,%dl
  801972:	75 f2                	jne    801966 <strchr+0xc>
    if (*s == c)
      return (char*)s;
  return 0;
  801974:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801979:	5d                   	pop    %ebp
  80197a:	c3                   	ret    

0080197b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80197b:	55                   	push   %ebp
  80197c:	89 e5                	mov    %esp,%ebp
  80197e:	8b 45 08             	mov    0x8(%ebp),%eax
  801981:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
  801985:	eb 07                	jmp    80198e <strfind+0x13>
    if (*s == c)
  801987:	38 ca                	cmp    %cl,%dl
  801989:	74 0a                	je     801995 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  for (; *s; s++)
  80198b:	83 c0 01             	add    $0x1,%eax
  80198e:	0f b6 10             	movzbl (%eax),%edx
  801991:	84 d2                	test   %dl,%dl
  801993:	75 f2                	jne    801987 <strfind+0xc>
    if (*s == c)
      break;
  return (char*)s;
}
  801995:	5d                   	pop    %ebp
  801996:	c3                   	ret    

00801997 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801997:	55                   	push   %ebp
  801998:	89 e5                	mov    %esp,%ebp
  80199a:	57                   	push   %edi
  80199b:	56                   	push   %esi
  80199c:	53                   	push   %ebx
  80199d:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *p;

  if (n == 0)
  8019a3:	85 c9                	test   %ecx,%ecx
  8019a5:	74 36                	je     8019dd <memset+0x46>
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
  8019a7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8019ad:	75 28                	jne    8019d7 <memset+0x40>
  8019af:	f6 c1 03             	test   $0x3,%cl
  8019b2:	75 23                	jne    8019d7 <memset+0x40>
    c &= 0xFF;
  8019b4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
    c = (c<<24)|(c<<16)|(c<<8)|c;
  8019b8:	89 d3                	mov    %edx,%ebx
  8019ba:	c1 e3 08             	shl    $0x8,%ebx
  8019bd:	89 d6                	mov    %edx,%esi
  8019bf:	c1 e6 18             	shl    $0x18,%esi
  8019c2:	89 d0                	mov    %edx,%eax
  8019c4:	c1 e0 10             	shl    $0x10,%eax
  8019c7:	09 f0                	or     %esi,%eax
  8019c9:	09 c2                	or     %eax,%edx
  8019cb:	89 d0                	mov    %edx,%eax
  8019cd:	09 d8                	or     %ebx,%eax
    asm volatile ("cld; rep stosl\n"
                  :: "D" (v), "a" (c), "c" (n/4)
  8019cf:	c1 e9 02             	shr    $0x2,%ecx
  if (n == 0)
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
    c &= 0xFF;
    c = (c<<24)|(c<<16)|(c<<8)|c;
    asm volatile ("cld; rep stosl\n"
  8019d2:	fc                   	cld    
  8019d3:	f3 ab                	rep stos %eax,%es:(%edi)
  8019d5:	eb 06                	jmp    8019dd <memset+0x46>
                  :: "D" (v), "a" (c), "c" (n/4)
                  : "cc", "memory");
  } else
    asm volatile ("cld; rep stosb\n"
  8019d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019da:	fc                   	cld    
  8019db:	f3 aa                	rep stos %al,%es:(%edi)
                  :: "D" (v), "a" (c), "c" (n)
                  : "cc", "memory");
  return v;
}
  8019dd:	89 f8                	mov    %edi,%eax
  8019df:	5b                   	pop    %ebx
  8019e0:	5e                   	pop    %esi
  8019e1:	5f                   	pop    %edi
  8019e2:	5d                   	pop    %ebp
  8019e3:	c3                   	ret    

008019e4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8019e4:	55                   	push   %ebp
  8019e5:	89 e5                	mov    %esp,%ebp
  8019e7:	57                   	push   %edi
  8019e8:	56                   	push   %esi
  8019e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ec:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  8019f2:	39 c6                	cmp    %eax,%esi
  8019f4:	73 35                	jae    801a2b <memmove+0x47>
  8019f6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8019f9:	39 d0                	cmp    %edx,%eax
  8019fb:	73 2e                	jae    801a2b <memmove+0x47>
    s += n;
    d += n;
  8019fd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801a00:	89 d6                	mov    %edx,%esi
  801a02:	09 fe                	or     %edi,%esi
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a04:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801a0a:	75 13                	jne    801a1f <memmove+0x3b>
  801a0c:	f6 c1 03             	test   $0x3,%cl
  801a0f:	75 0e                	jne    801a1f <memmove+0x3b>
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801a11:	83 ef 04             	sub    $0x4,%edi
  801a14:	8d 72 fc             	lea    -0x4(%edx),%esi
  801a17:	c1 e9 02             	shr    $0x2,%ecx
  d = dst;
  if (s < d && s + n > d) {
    s += n;
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
  801a1a:	fd                   	std    
  801a1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a1d:	eb 09                	jmp    801a28 <memmove+0x44>
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801a1f:	83 ef 01             	sub    $0x1,%edi
  801a22:	8d 72 ff             	lea    -0x1(%edx),%esi
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
  801a25:	fd                   	std    
  801a26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  801a28:	fc                   	cld    
  801a29:	eb 1d                	jmp    801a48 <memmove+0x64>
  801a2b:	89 f2                	mov    %esi,%edx
  801a2d:	09 c2                	or     %eax,%edx
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a2f:	f6 c2 03             	test   $0x3,%dl
  801a32:	75 0f                	jne    801a43 <memmove+0x5f>
  801a34:	f6 c1 03             	test   $0x3,%cl
  801a37:	75 0a                	jne    801a43 <memmove+0x5f>
      asm volatile ("cld; rep movsl\n"
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801a39:	c1 e9 02             	shr    $0x2,%ecx
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("cld; rep movsl\n"
  801a3c:	89 c7                	mov    %eax,%edi
  801a3e:	fc                   	cld    
  801a3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a41:	eb 05                	jmp    801a48 <memmove+0x64>
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("cld; rep movsb\n"
  801a43:	89 c7                	mov    %eax,%edi
  801a45:	fc                   	cld    
  801a46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d), "S" (s), "c" (n) : "cc", "memory");
  }
  return dst;
}
  801a48:	5e                   	pop    %esi
  801a49:	5f                   	pop    %edi
  801a4a:	5d                   	pop    %ebp
  801a4b:	c3                   	ret    

00801a4c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801a4c:	55                   	push   %ebp
  801a4d:	89 e5                	mov    %esp,%ebp
  801a4f:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
  801a52:	8b 45 10             	mov    0x10(%ebp),%eax
  801a55:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a59:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a60:	8b 45 08             	mov    0x8(%ebp),%eax
  801a63:	89 04 24             	mov    %eax,(%esp)
  801a66:	e8 79 ff ff ff       	call   8019e4 <memmove>
}
  801a6b:	c9                   	leave  
  801a6c:	c3                   	ret    

00801a6d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	56                   	push   %esi
  801a71:	53                   	push   %ebx
  801a72:	8b 55 08             	mov    0x8(%ebp),%edx
  801a75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a78:	89 d6                	mov    %edx,%esi
  801a7a:	03 75 10             	add    0x10(%ebp),%esi
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
  801a7d:	eb 1a                	jmp    801a99 <memcmp+0x2c>
    if (*s1 != *s2)
  801a7f:	0f b6 02             	movzbl (%edx),%eax
  801a82:	0f b6 19             	movzbl (%ecx),%ebx
  801a85:	38 d8                	cmp    %bl,%al
  801a87:	74 0a                	je     801a93 <memcmp+0x26>
      return (int)*s1 - (int)*s2;
  801a89:	0f b6 c0             	movzbl %al,%eax
  801a8c:	0f b6 db             	movzbl %bl,%ebx
  801a8f:	29 d8                	sub    %ebx,%eax
  801a91:	eb 0f                	jmp    801aa2 <memcmp+0x35>
    s1++, s2++;
  801a93:	83 c2 01             	add    $0x1,%edx
  801a96:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
  801a99:	39 f2                	cmp    %esi,%edx
  801a9b:	75 e2                	jne    801a7f <memcmp+0x12>
    if (*s1 != *s2)
      return (int)*s1 - (int)*s2;
    s1++, s2++;
  }

  return 0;
  801a9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aa2:	5b                   	pop    %ebx
  801aa3:	5e                   	pop    %esi
  801aa4:	5d                   	pop    %ebp
  801aa5:	c3                   	ret    

00801aa6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801aa6:	55                   	push   %ebp
  801aa7:	89 e5                	mov    %esp,%ebp
  801aa9:	8b 45 08             	mov    0x8(%ebp),%eax
  801aac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  const void *ends = (const char*)s + n;
  801aaf:	89 c2                	mov    %eax,%edx
  801ab1:	03 55 10             	add    0x10(%ebp),%edx

  for (; s < ends; s++)
  801ab4:	eb 07                	jmp    801abd <memfind+0x17>
    if (*(const unsigned char*)s == (unsigned char)c)
  801ab6:	38 08                	cmp    %cl,(%eax)
  801ab8:	74 07                	je     801ac1 <memfind+0x1b>
void *
memfind(const void *s, int c, size_t n)
{
  const void *ends = (const char*)s + n;

  for (; s < ends; s++)
  801aba:	83 c0 01             	add    $0x1,%eax
  801abd:	39 d0                	cmp    %edx,%eax
  801abf:	72 f5                	jb     801ab6 <memfind+0x10>
    if (*(const unsigned char*)s == (unsigned char)c)
      break;
  return (void*)s;
}
  801ac1:	5d                   	pop    %ebp
  801ac2:	c3                   	ret    

00801ac3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801ac3:	55                   	push   %ebp
  801ac4:	89 e5                	mov    %esp,%ebp
  801ac6:	57                   	push   %edi
  801ac7:	56                   	push   %esi
  801ac8:	53                   	push   %ebx
  801ac9:	8b 55 08             	mov    0x8(%ebp),%edx
  801acc:	8b 45 10             	mov    0x10(%ebp),%eax
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  801acf:	eb 03                	jmp    801ad4 <strtol+0x11>
    s++;
  801ad1:	83 c2 01             	add    $0x1,%edx
{
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  801ad4:	0f b6 0a             	movzbl (%edx),%ecx
  801ad7:	80 f9 09             	cmp    $0x9,%cl
  801ada:	74 f5                	je     801ad1 <strtol+0xe>
  801adc:	80 f9 20             	cmp    $0x20,%cl
  801adf:	74 f0                	je     801ad1 <strtol+0xe>
    s++;

  // plus/minus sign
  if (*s == '+')
  801ae1:	80 f9 2b             	cmp    $0x2b,%cl
  801ae4:	75 0a                	jne    801af0 <strtol+0x2d>
    s++;
  801ae6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
  int neg = 0;
  801ae9:	bf 00 00 00 00       	mov    $0x0,%edi
  801aee:	eb 11                	jmp    801b01 <strtol+0x3e>
  801af0:	bf 00 00 00 00       	mov    $0x0,%edi
    s++;

  // plus/minus sign
  if (*s == '+')
    s++;
  else if (*s == '-')
  801af5:	80 f9 2d             	cmp    $0x2d,%cl
  801af8:	75 07                	jne    801b01 <strtol+0x3e>
    s++, neg = 1;
  801afa:	8d 52 01             	lea    0x1(%edx),%edx
  801afd:	66 bf 01 00          	mov    $0x1,%di

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801b01:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801b06:	75 15                	jne    801b1d <strtol+0x5a>
  801b08:	80 3a 30             	cmpb   $0x30,(%edx)
  801b0b:	75 10                	jne    801b1d <strtol+0x5a>
  801b0d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801b11:	75 0a                	jne    801b1d <strtol+0x5a>
    s += 2, base = 16;
  801b13:	83 c2 02             	add    $0x2,%edx
  801b16:	b8 10 00 00 00       	mov    $0x10,%eax
  801b1b:	eb 10                	jmp    801b2d <strtol+0x6a>
  else if (base == 0 && s[0] == '0')
  801b1d:	85 c0                	test   %eax,%eax
  801b1f:	75 0c                	jne    801b2d <strtol+0x6a>
    s++, base = 8;
  else if (base == 0)
    base = 10;
  801b21:	b0 0a                	mov    $0xa,%al
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
  801b23:	80 3a 30             	cmpb   $0x30,(%edx)
  801b26:	75 05                	jne    801b2d <strtol+0x6a>
    s++, base = 8;
  801b28:	83 c2 01             	add    $0x1,%edx
  801b2b:	b0 08                	mov    $0x8,%al
  else if (base == 0)
    base = 10;
  801b2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b32:	89 45 10             	mov    %eax,0x10(%ebp)

  // digits
  while (1) {
    int dig;

    if (*s >= '0' && *s <= '9')
  801b35:	0f b6 0a             	movzbl (%edx),%ecx
  801b38:	8d 71 d0             	lea    -0x30(%ecx),%esi
  801b3b:	89 f0                	mov    %esi,%eax
  801b3d:	3c 09                	cmp    $0x9,%al
  801b3f:	77 08                	ja     801b49 <strtol+0x86>
      dig = *s - '0';
  801b41:	0f be c9             	movsbl %cl,%ecx
  801b44:	83 e9 30             	sub    $0x30,%ecx
  801b47:	eb 20                	jmp    801b69 <strtol+0xa6>
    else if (*s >= 'a' && *s <= 'z')
  801b49:	8d 71 9f             	lea    -0x61(%ecx),%esi
  801b4c:	89 f0                	mov    %esi,%eax
  801b4e:	3c 19                	cmp    $0x19,%al
  801b50:	77 08                	ja     801b5a <strtol+0x97>
      dig = *s - 'a' + 10;
  801b52:	0f be c9             	movsbl %cl,%ecx
  801b55:	83 e9 57             	sub    $0x57,%ecx
  801b58:	eb 0f                	jmp    801b69 <strtol+0xa6>
    else if (*s >= 'A' && *s <= 'Z')
  801b5a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  801b5d:	89 f0                	mov    %esi,%eax
  801b5f:	3c 19                	cmp    $0x19,%al
  801b61:	77 16                	ja     801b79 <strtol+0xb6>
      dig = *s - 'A' + 10;
  801b63:	0f be c9             	movsbl %cl,%ecx
  801b66:	83 e9 37             	sub    $0x37,%ecx
    else
      break;
    if (dig >= base)
  801b69:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  801b6c:	7d 0f                	jge    801b7d <strtol+0xba>
      break;
    s++, val = (val * base) + dig;
  801b6e:	83 c2 01             	add    $0x1,%edx
  801b71:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801b75:	01 cb                	add    %ecx,%ebx
    // we don't properly detect overflow!
  }
  801b77:	eb bc                	jmp    801b35 <strtol+0x72>
  801b79:	89 d8                	mov    %ebx,%eax
  801b7b:	eb 02                	jmp    801b7f <strtol+0xbc>
  801b7d:	89 d8                	mov    %ebx,%eax

  if (endptr)
  801b7f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b83:	74 05                	je     801b8a <strtol+0xc7>
    *endptr = (char*)s;
  801b85:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b88:	89 16                	mov    %edx,(%esi)
  return neg ? -val : val;
  801b8a:	f7 d8                	neg    %eax
  801b8c:	85 ff                	test   %edi,%edi
  801b8e:	0f 44 c3             	cmove  %ebx,%eax
}
  801b91:	5b                   	pop    %ebx
  801b92:	5e                   	pop    %esi
  801b93:	5f                   	pop    %edi
  801b94:	5d                   	pop    %ebp
  801b95:	c3                   	ret    

00801b96 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	56                   	push   %esi
  801b9a:	53                   	push   %ebx
  801b9b:	83 ec 10             	sub    $0x10,%esp
  801b9e:	8b 75 08             	mov    0x8(%ebp),%esi
  801ba1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;
  801ba7:	85 c0                	test   %eax,%eax
  801ba9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801bae:	0f 44 c2             	cmove  %edx,%eax
  if ((r = sys_ipc_recv(pg)) < 0) {
  801bb1:	89 04 24             	mov    %eax,(%esp)
  801bb4:	e8 c4 e7 ff ff       	call   80037d <sys_ipc_recv>
  801bb9:	85 c0                	test   %eax,%eax
  801bbb:	79 34                	jns    801bf1 <ipc_recv+0x5b>
    if (from_env_store)
  801bbd:	85 f6                	test   %esi,%esi
  801bbf:	74 06                	je     801bc7 <ipc_recv+0x31>
      *from_env_store = 0;
  801bc1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (perm_store)
  801bc7:	85 db                	test   %ebx,%ebx
  801bc9:	74 06                	je     801bd1 <ipc_recv+0x3b>
      *perm_store = 0;
  801bcb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    panic("sys_ipc_recv: %e", r);
  801bd1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bd5:	c7 44 24 08 c0 23 80 	movl   $0x8023c0,0x8(%esp)
  801bdc:	00 
  801bdd:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801be4:	00 
  801be5:	c7 04 24 d1 23 80 00 	movl   $0x8023d1,(%esp)
  801bec:	e8 35 f5 ff ff       	call   801126 <_panic>
  }

  if (from_env_store)
  801bf1:	85 f6                	test   %esi,%esi
  801bf3:	74 0a                	je     801bff <ipc_recv+0x69>
    *from_env_store = thisenv->env_ipc_from;
  801bf5:	a1 04 40 80 00       	mov    0x804004,%eax
  801bfa:	8b 40 74             	mov    0x74(%eax),%eax
  801bfd:	89 06                	mov    %eax,(%esi)
  if (perm_store)
  801bff:	85 db                	test   %ebx,%ebx
  801c01:	74 0a                	je     801c0d <ipc_recv+0x77>
    *perm_store |= thisenv->env_ipc_perm;
  801c03:	a1 04 40 80 00       	mov    0x804004,%eax
  801c08:	8b 40 78             	mov    0x78(%eax),%eax
  801c0b:	09 03                	or     %eax,(%ebx)

  return thisenv->env_ipc_value;
  801c0d:	a1 04 40 80 00       	mov    0x804004,%eax
  801c12:	8b 40 70             	mov    0x70(%eax),%eax

}
  801c15:	83 c4 10             	add    $0x10,%esp
  801c18:	5b                   	pop    %ebx
  801c19:	5e                   	pop    %esi
  801c1a:	5d                   	pop    %ebp
  801c1b:	c3                   	ret    

00801c1c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c1c:	55                   	push   %ebp
  801c1d:	89 e5                	mov    %esp,%ebp
  801c1f:	57                   	push   %edi
  801c20:	56                   	push   %esi
  801c21:	53                   	push   %ebx
  801c22:	83 ec 1c             	sub    $0x1c,%esp
  801c25:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c28:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;
  801c2e:	85 db                	test   %ebx,%ebx
  801c30:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801c35:	0f 44 d8             	cmove  %eax,%ebx

  while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801c38:	eb 2a                	jmp    801c64 <ipc_send+0x48>
    if (r != -E_IPC_NOT_RECV)
  801c3a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c3d:	74 20                	je     801c5f <ipc_send+0x43>
      panic("ipc_send: %e", r);
  801c3f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c43:	c7 44 24 08 db 23 80 	movl   $0x8023db,0x8(%esp)
  801c4a:	00 
  801c4b:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801c52:	00 
  801c53:	c7 04 24 d1 23 80 00 	movl   $0x8023d1,(%esp)
  801c5a:	e8 c7 f4 ff ff       	call   801126 <_panic>
    sys_yield();
  801c5f:	e8 e4 e4 ff ff       	call   800148 <sys_yield>
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;

  while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801c64:	8b 45 14             	mov    0x14(%ebp),%eax
  801c67:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c6b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c6f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c73:	89 3c 24             	mov    %edi,(%esp)
  801c76:	e8 df e6 ff ff       	call   80035a <sys_ipc_try_send>
  801c7b:	85 c0                	test   %eax,%eax
  801c7d:	78 bb                	js     801c3a <ipc_send+0x1e>
    if (r != -E_IPC_NOT_RECV)
      panic("ipc_send: %e", r);
    sys_yield();
  }
}
  801c7f:	83 c4 1c             	add    $0x1c,%esp
  801c82:	5b                   	pop    %ebx
  801c83:	5e                   	pop    %esi
  801c84:	5f                   	pop    %edi
  801c85:	5d                   	pop    %ebp
  801c86:	c3                   	ret    

00801c87 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c87:	55                   	push   %ebp
  801c88:	89 e5                	mov    %esp,%ebp
  801c8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int i;

  for (i = 0; i < NENV; i++)
  801c8d:	b8 00 00 00 00       	mov    $0x0,%eax
    if (envs[i].env_type == type)
  801c92:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c95:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c9b:	8b 52 50             	mov    0x50(%edx),%edx
  801c9e:	39 ca                	cmp    %ecx,%edx
  801ca0:	75 0d                	jne    801caf <ipc_find_env+0x28>
      return envs[i].env_id;
  801ca2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ca5:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801caa:	8b 40 40             	mov    0x40(%eax),%eax
  801cad:	eb 0e                	jmp    801cbd <ipc_find_env+0x36>
envid_t
ipc_find_env(enum EnvType type)
{
  int i;

  for (i = 0; i < NENV; i++)
  801caf:	83 c0 01             	add    $0x1,%eax
  801cb2:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cb7:	75 d9                	jne    801c92 <ipc_find_env+0xb>
    if (envs[i].env_type == type)
      return envs[i].env_id;
  return 0;
  801cb9:	66 b8 00 00          	mov    $0x0,%ax
}
  801cbd:	5d                   	pop    %ebp
  801cbe:	c3                   	ret    

00801cbf <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cbf:	55                   	push   %ebp
  801cc0:	89 e5                	mov    %esp,%ebp
  801cc2:	8b 55 08             	mov    0x8(%ebp),%edx
  pte_t pte;

  if (!(uvpd[PDX(v)] & PTE_P))
  801cc5:	89 d0                	mov    %edx,%eax
  801cc7:	c1 e8 16             	shr    $0x16,%eax
  801cca:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
    return 0;
  801cd1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
  pte_t pte;

  if (!(uvpd[PDX(v)] & PTE_P))
  801cd6:	f6 c1 01             	test   $0x1,%cl
  801cd9:	74 1d                	je     801cf8 <pageref+0x39>
    return 0;
  pte = uvpt[PGNUM(v)];
  801cdb:	c1 ea 0c             	shr    $0xc,%edx
  801cde:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  if (!(pte & PTE_P))
  801ce5:	f6 c2 01             	test   $0x1,%dl
  801ce8:	74 0e                	je     801cf8 <pageref+0x39>
    return 0;
  return pages[PGNUM(pte)].pp_ref;
  801cea:	c1 ea 0c             	shr    $0xc,%edx
  801ced:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801cf4:	ef 
  801cf5:	0f b7 c0             	movzwl %ax,%eax
}
  801cf8:	5d                   	pop    %ebp
  801cf9:	c3                   	ret    
  801cfa:	66 90                	xchg   %ax,%ax
  801cfc:	66 90                	xchg   %ax,%ax
  801cfe:	66 90                	xchg   %ax,%ax

00801d00 <__udivdi3>:
  801d00:	55                   	push   %ebp
  801d01:	57                   	push   %edi
  801d02:	56                   	push   %esi
  801d03:	83 ec 0c             	sub    $0xc,%esp
  801d06:	8b 44 24 28          	mov    0x28(%esp),%eax
  801d0a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801d0e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801d12:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801d16:	85 c0                	test   %eax,%eax
  801d18:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d1c:	89 ea                	mov    %ebp,%edx
  801d1e:	89 0c 24             	mov    %ecx,(%esp)
  801d21:	75 2d                	jne    801d50 <__udivdi3+0x50>
  801d23:	39 e9                	cmp    %ebp,%ecx
  801d25:	77 61                	ja     801d88 <__udivdi3+0x88>
  801d27:	85 c9                	test   %ecx,%ecx
  801d29:	89 ce                	mov    %ecx,%esi
  801d2b:	75 0b                	jne    801d38 <__udivdi3+0x38>
  801d2d:	b8 01 00 00 00       	mov    $0x1,%eax
  801d32:	31 d2                	xor    %edx,%edx
  801d34:	f7 f1                	div    %ecx
  801d36:	89 c6                	mov    %eax,%esi
  801d38:	31 d2                	xor    %edx,%edx
  801d3a:	89 e8                	mov    %ebp,%eax
  801d3c:	f7 f6                	div    %esi
  801d3e:	89 c5                	mov    %eax,%ebp
  801d40:	89 f8                	mov    %edi,%eax
  801d42:	f7 f6                	div    %esi
  801d44:	89 ea                	mov    %ebp,%edx
  801d46:	83 c4 0c             	add    $0xc,%esp
  801d49:	5e                   	pop    %esi
  801d4a:	5f                   	pop    %edi
  801d4b:	5d                   	pop    %ebp
  801d4c:	c3                   	ret    
  801d4d:	8d 76 00             	lea    0x0(%esi),%esi
  801d50:	39 e8                	cmp    %ebp,%eax
  801d52:	77 24                	ja     801d78 <__udivdi3+0x78>
  801d54:	0f bd e8             	bsr    %eax,%ebp
  801d57:	83 f5 1f             	xor    $0x1f,%ebp
  801d5a:	75 3c                	jne    801d98 <__udivdi3+0x98>
  801d5c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801d60:	39 34 24             	cmp    %esi,(%esp)
  801d63:	0f 86 9f 00 00 00    	jbe    801e08 <__udivdi3+0x108>
  801d69:	39 d0                	cmp    %edx,%eax
  801d6b:	0f 82 97 00 00 00    	jb     801e08 <__udivdi3+0x108>
  801d71:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d78:	31 d2                	xor    %edx,%edx
  801d7a:	31 c0                	xor    %eax,%eax
  801d7c:	83 c4 0c             	add    $0xc,%esp
  801d7f:	5e                   	pop    %esi
  801d80:	5f                   	pop    %edi
  801d81:	5d                   	pop    %ebp
  801d82:	c3                   	ret    
  801d83:	90                   	nop
  801d84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d88:	89 f8                	mov    %edi,%eax
  801d8a:	f7 f1                	div    %ecx
  801d8c:	31 d2                	xor    %edx,%edx
  801d8e:	83 c4 0c             	add    $0xc,%esp
  801d91:	5e                   	pop    %esi
  801d92:	5f                   	pop    %edi
  801d93:	5d                   	pop    %ebp
  801d94:	c3                   	ret    
  801d95:	8d 76 00             	lea    0x0(%esi),%esi
  801d98:	89 e9                	mov    %ebp,%ecx
  801d9a:	8b 3c 24             	mov    (%esp),%edi
  801d9d:	d3 e0                	shl    %cl,%eax
  801d9f:	89 c6                	mov    %eax,%esi
  801da1:	b8 20 00 00 00       	mov    $0x20,%eax
  801da6:	29 e8                	sub    %ebp,%eax
  801da8:	89 c1                	mov    %eax,%ecx
  801daa:	d3 ef                	shr    %cl,%edi
  801dac:	89 e9                	mov    %ebp,%ecx
  801dae:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801db2:	8b 3c 24             	mov    (%esp),%edi
  801db5:	09 74 24 08          	or     %esi,0x8(%esp)
  801db9:	89 d6                	mov    %edx,%esi
  801dbb:	d3 e7                	shl    %cl,%edi
  801dbd:	89 c1                	mov    %eax,%ecx
  801dbf:	89 3c 24             	mov    %edi,(%esp)
  801dc2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801dc6:	d3 ee                	shr    %cl,%esi
  801dc8:	89 e9                	mov    %ebp,%ecx
  801dca:	d3 e2                	shl    %cl,%edx
  801dcc:	89 c1                	mov    %eax,%ecx
  801dce:	d3 ef                	shr    %cl,%edi
  801dd0:	09 d7                	or     %edx,%edi
  801dd2:	89 f2                	mov    %esi,%edx
  801dd4:	89 f8                	mov    %edi,%eax
  801dd6:	f7 74 24 08          	divl   0x8(%esp)
  801dda:	89 d6                	mov    %edx,%esi
  801ddc:	89 c7                	mov    %eax,%edi
  801dde:	f7 24 24             	mull   (%esp)
  801de1:	39 d6                	cmp    %edx,%esi
  801de3:	89 14 24             	mov    %edx,(%esp)
  801de6:	72 30                	jb     801e18 <__udivdi3+0x118>
  801de8:	8b 54 24 04          	mov    0x4(%esp),%edx
  801dec:	89 e9                	mov    %ebp,%ecx
  801dee:	d3 e2                	shl    %cl,%edx
  801df0:	39 c2                	cmp    %eax,%edx
  801df2:	73 05                	jae    801df9 <__udivdi3+0xf9>
  801df4:	3b 34 24             	cmp    (%esp),%esi
  801df7:	74 1f                	je     801e18 <__udivdi3+0x118>
  801df9:	89 f8                	mov    %edi,%eax
  801dfb:	31 d2                	xor    %edx,%edx
  801dfd:	e9 7a ff ff ff       	jmp    801d7c <__udivdi3+0x7c>
  801e02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e08:	31 d2                	xor    %edx,%edx
  801e0a:	b8 01 00 00 00       	mov    $0x1,%eax
  801e0f:	e9 68 ff ff ff       	jmp    801d7c <__udivdi3+0x7c>
  801e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e18:	8d 47 ff             	lea    -0x1(%edi),%eax
  801e1b:	31 d2                	xor    %edx,%edx
  801e1d:	83 c4 0c             	add    $0xc,%esp
  801e20:	5e                   	pop    %esi
  801e21:	5f                   	pop    %edi
  801e22:	5d                   	pop    %ebp
  801e23:	c3                   	ret    
  801e24:	66 90                	xchg   %ax,%ax
  801e26:	66 90                	xchg   %ax,%ax
  801e28:	66 90                	xchg   %ax,%ax
  801e2a:	66 90                	xchg   %ax,%ax
  801e2c:	66 90                	xchg   %ax,%ax
  801e2e:	66 90                	xchg   %ax,%ax

00801e30 <__umoddi3>:
  801e30:	55                   	push   %ebp
  801e31:	57                   	push   %edi
  801e32:	56                   	push   %esi
  801e33:	83 ec 14             	sub    $0x14,%esp
  801e36:	8b 44 24 28          	mov    0x28(%esp),%eax
  801e3a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801e3e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801e42:	89 c7                	mov    %eax,%edi
  801e44:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e48:	8b 44 24 30          	mov    0x30(%esp),%eax
  801e4c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801e50:	89 34 24             	mov    %esi,(%esp)
  801e53:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e57:	85 c0                	test   %eax,%eax
  801e59:	89 c2                	mov    %eax,%edx
  801e5b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e5f:	75 17                	jne    801e78 <__umoddi3+0x48>
  801e61:	39 fe                	cmp    %edi,%esi
  801e63:	76 4b                	jbe    801eb0 <__umoddi3+0x80>
  801e65:	89 c8                	mov    %ecx,%eax
  801e67:	89 fa                	mov    %edi,%edx
  801e69:	f7 f6                	div    %esi
  801e6b:	89 d0                	mov    %edx,%eax
  801e6d:	31 d2                	xor    %edx,%edx
  801e6f:	83 c4 14             	add    $0x14,%esp
  801e72:	5e                   	pop    %esi
  801e73:	5f                   	pop    %edi
  801e74:	5d                   	pop    %ebp
  801e75:	c3                   	ret    
  801e76:	66 90                	xchg   %ax,%ax
  801e78:	39 f8                	cmp    %edi,%eax
  801e7a:	77 54                	ja     801ed0 <__umoddi3+0xa0>
  801e7c:	0f bd e8             	bsr    %eax,%ebp
  801e7f:	83 f5 1f             	xor    $0x1f,%ebp
  801e82:	75 5c                	jne    801ee0 <__umoddi3+0xb0>
  801e84:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801e88:	39 3c 24             	cmp    %edi,(%esp)
  801e8b:	0f 87 e7 00 00 00    	ja     801f78 <__umoddi3+0x148>
  801e91:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801e95:	29 f1                	sub    %esi,%ecx
  801e97:	19 c7                	sbb    %eax,%edi
  801e99:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e9d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ea1:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ea5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801ea9:	83 c4 14             	add    $0x14,%esp
  801eac:	5e                   	pop    %esi
  801ead:	5f                   	pop    %edi
  801eae:	5d                   	pop    %ebp
  801eaf:	c3                   	ret    
  801eb0:	85 f6                	test   %esi,%esi
  801eb2:	89 f5                	mov    %esi,%ebp
  801eb4:	75 0b                	jne    801ec1 <__umoddi3+0x91>
  801eb6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ebb:	31 d2                	xor    %edx,%edx
  801ebd:	f7 f6                	div    %esi
  801ebf:	89 c5                	mov    %eax,%ebp
  801ec1:	8b 44 24 04          	mov    0x4(%esp),%eax
  801ec5:	31 d2                	xor    %edx,%edx
  801ec7:	f7 f5                	div    %ebp
  801ec9:	89 c8                	mov    %ecx,%eax
  801ecb:	f7 f5                	div    %ebp
  801ecd:	eb 9c                	jmp    801e6b <__umoddi3+0x3b>
  801ecf:	90                   	nop
  801ed0:	89 c8                	mov    %ecx,%eax
  801ed2:	89 fa                	mov    %edi,%edx
  801ed4:	83 c4 14             	add    $0x14,%esp
  801ed7:	5e                   	pop    %esi
  801ed8:	5f                   	pop    %edi
  801ed9:	5d                   	pop    %ebp
  801eda:	c3                   	ret    
  801edb:	90                   	nop
  801edc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ee0:	8b 04 24             	mov    (%esp),%eax
  801ee3:	be 20 00 00 00       	mov    $0x20,%esi
  801ee8:	89 e9                	mov    %ebp,%ecx
  801eea:	29 ee                	sub    %ebp,%esi
  801eec:	d3 e2                	shl    %cl,%edx
  801eee:	89 f1                	mov    %esi,%ecx
  801ef0:	d3 e8                	shr    %cl,%eax
  801ef2:	89 e9                	mov    %ebp,%ecx
  801ef4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ef8:	8b 04 24             	mov    (%esp),%eax
  801efb:	09 54 24 04          	or     %edx,0x4(%esp)
  801eff:	89 fa                	mov    %edi,%edx
  801f01:	d3 e0                	shl    %cl,%eax
  801f03:	89 f1                	mov    %esi,%ecx
  801f05:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f09:	8b 44 24 10          	mov    0x10(%esp),%eax
  801f0d:	d3 ea                	shr    %cl,%edx
  801f0f:	89 e9                	mov    %ebp,%ecx
  801f11:	d3 e7                	shl    %cl,%edi
  801f13:	89 f1                	mov    %esi,%ecx
  801f15:	d3 e8                	shr    %cl,%eax
  801f17:	89 e9                	mov    %ebp,%ecx
  801f19:	09 f8                	or     %edi,%eax
  801f1b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801f1f:	f7 74 24 04          	divl   0x4(%esp)
  801f23:	d3 e7                	shl    %cl,%edi
  801f25:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f29:	89 d7                	mov    %edx,%edi
  801f2b:	f7 64 24 08          	mull   0x8(%esp)
  801f2f:	39 d7                	cmp    %edx,%edi
  801f31:	89 c1                	mov    %eax,%ecx
  801f33:	89 14 24             	mov    %edx,(%esp)
  801f36:	72 2c                	jb     801f64 <__umoddi3+0x134>
  801f38:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801f3c:	72 22                	jb     801f60 <__umoddi3+0x130>
  801f3e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f42:	29 c8                	sub    %ecx,%eax
  801f44:	19 d7                	sbb    %edx,%edi
  801f46:	89 e9                	mov    %ebp,%ecx
  801f48:	89 fa                	mov    %edi,%edx
  801f4a:	d3 e8                	shr    %cl,%eax
  801f4c:	89 f1                	mov    %esi,%ecx
  801f4e:	d3 e2                	shl    %cl,%edx
  801f50:	89 e9                	mov    %ebp,%ecx
  801f52:	d3 ef                	shr    %cl,%edi
  801f54:	09 d0                	or     %edx,%eax
  801f56:	89 fa                	mov    %edi,%edx
  801f58:	83 c4 14             	add    $0x14,%esp
  801f5b:	5e                   	pop    %esi
  801f5c:	5f                   	pop    %edi
  801f5d:	5d                   	pop    %ebp
  801f5e:	c3                   	ret    
  801f5f:	90                   	nop
  801f60:	39 d7                	cmp    %edx,%edi
  801f62:	75 da                	jne    801f3e <__umoddi3+0x10e>
  801f64:	8b 14 24             	mov    (%esp),%edx
  801f67:	89 c1                	mov    %eax,%ecx
  801f69:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801f6d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801f71:	eb cb                	jmp    801f3e <__umoddi3+0x10e>
  801f73:	90                   	nop
  801f74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f78:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801f7c:	0f 82 0f ff ff ff    	jb     801e91 <__umoddi3+0x61>
  801f82:	e9 1a ff ff ff       	jmp    801ea1 <__umoddi3+0x71>
