
obj/fs/fs:     file format elf32-i386


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
  80002c:	e8 19 1c 00 00       	call   801c4a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	89 c1                	mov    %eax,%ecx

static __inline uint8_t
inb(int port)
{
  uint8_t data;
  __asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800039:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003e:	ec                   	in     (%dx),%al
  80003f:	89 c3                	mov    %eax,%ebx
  int r;

  while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800041:	83 e0 c0             	and    $0xffffffc0,%eax
  800044:	3c 40                	cmp    $0x40,%al
  800046:	75 f6                	jne    80003e <ide_wait_ready+0xb>
    /* do nothing */;

  if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
    return -1;
  return 0;
  800048:	b8 00 00 00 00       	mov    $0x0,%eax
  int r;

  while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
    /* do nothing */;

  if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004d:	84 c9                	test   %cl,%cl
  80004f:	74 0b                	je     80005c <ide_wait_ready+0x29>
  800051:	f6 c3 21             	test   $0x21,%bl
  800054:	0f 95 c0             	setne  %al
  800057:	0f b6 c0             	movzbl %al,%eax
  80005a:	f7 d8                	neg    %eax
    return -1;
  return 0;
}
  80005c:	5b                   	pop    %ebx
  80005d:	5d                   	pop    %ebp
  80005e:	c3                   	ret    

0080005f <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	53                   	push   %ebx
  800063:	83 ec 14             	sub    $0x14,%esp
  int r, x;

  // wait for Device 0 to be ready
  ide_wait_ready(0);
  800066:	b8 00 00 00 00       	mov    $0x0,%eax
  80006b:	e8 c3 ff ff ff       	call   800033 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
  __asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800070:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800075:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80007a:	ee                   	out    %al,(%dx)

  // switch to Device 1
  outb(0x1F6, 0xE0 | (1<<4));

  // check for Device 1 to be ready for a while
  for (x = 0;
  80007b:	b9 00 00 00 00       	mov    $0x0,%ecx

static __inline uint8_t
inb(int port)
{
  uint8_t data;
  __asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800080:	b2 f7                	mov    $0xf7,%dl
  800082:	eb 0b                	jmp    80008f <ide_probe_disk1+0x30>
       x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
       x++)
  800084:	83 c1 01             	add    $0x1,%ecx

  // switch to Device 1
  outb(0x1F6, 0xE0 | (1<<4));

  // check for Device 1 to be ready for a while
  for (x = 0;
  800087:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  80008d:	74 05                	je     800094 <ide_probe_disk1+0x35>
  80008f:	ec                   	in     (%dx),%al
       x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800090:	a8 a1                	test   $0xa1,%al
  800092:	75 f0                	jne    800084 <ide_probe_disk1+0x25>
}

static __inline void
outb(int port, uint8_t data)
{
  __asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800094:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800099:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  80009e:	ee                   	out    %al,(%dx)
    /* do nothing */;

  // switch back to Device 0
  outb(0x1F6, 0xE0 | (0<<4));

  cprintf("Device 1 presence: %d\n", (x < 1000));
  80009f:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000a5:	0f 9e c3             	setle  %bl
  8000a8:	0f b6 c3             	movzbl %bl,%eax
  8000ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000af:	c7 04 24 60 3c 80 00 	movl   $0x803c60,(%esp)
  8000b6:	e8 e9 1c 00 00       	call   801da4 <cprintf>
  return x < 1000;
}
  8000bb:	89 d8                	mov    %ebx,%eax
  8000bd:	83 c4 14             	add    $0x14,%esp
  8000c0:	5b                   	pop    %ebx
  8000c1:	5d                   	pop    %ebp
  8000c2:	c3                   	ret    

008000c3 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	83 ec 18             	sub    $0x18,%esp
  8000c9:	8b 45 08             	mov    0x8(%ebp),%eax
  if (d != 0 && d != 1)
  8000cc:	83 f8 01             	cmp    $0x1,%eax
  8000cf:	76 1c                	jbe    8000ed <ide_set_disk+0x2a>
    panic("bad disk number");
  8000d1:	c7 44 24 08 77 3c 80 	movl   $0x803c77,0x8(%esp)
  8000d8:	00 
  8000d9:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8000e0:	00 
  8000e1:	c7 04 24 87 3c 80 00 	movl   $0x803c87,(%esp)
  8000e8:	e8 be 1b 00 00       	call   801cab <_panic>
  diskno = d;
  8000ed:	a3 00 50 80 00       	mov    %eax,0x805000
}
  8000f2:	c9                   	leave  
  8000f3:	c3                   	ret    

008000f4 <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	57                   	push   %edi
  8000f8:	56                   	push   %esi
  8000f9:	53                   	push   %ebx
  8000fa:	83 ec 1c             	sub    $0x1c,%esp
  8000fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800100:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800103:	8b 75 10             	mov    0x10(%ebp),%esi
  int r;

  assert(nsecs <= 256);
  800106:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  80010c:	76 24                	jbe    800132 <ide_read+0x3e>
  80010e:	c7 44 24 0c 90 3c 80 	movl   $0x803c90,0xc(%esp)
  800115:	00 
  800116:	c7 44 24 08 9d 3c 80 	movl   $0x803c9d,0x8(%esp)
  80011d:	00 
  80011e:	c7 44 24 04 44 00 00 	movl   $0x44,0x4(%esp)
  800125:	00 
  800126:	c7 04 24 87 3c 80 00 	movl   $0x803c87,(%esp)
  80012d:	e8 79 1b 00 00       	call   801cab <_panic>

  ide_wait_ready(0);
  800132:	b8 00 00 00 00       	mov    $0x0,%eax
  800137:	e8 f7 fe ff ff       	call   800033 <ide_wait_ready>
  80013c:	ba f2 01 00 00       	mov    $0x1f2,%edx
  800141:	89 f0                	mov    %esi,%eax
  800143:	ee                   	out    %al,(%dx)
  800144:	b2 f3                	mov    $0xf3,%dl
  800146:	89 f8                	mov    %edi,%eax
  800148:	ee                   	out    %al,(%dx)
  800149:	89 f8                	mov    %edi,%eax
  80014b:	0f b6 c4             	movzbl %ah,%eax
  80014e:	b2 f4                	mov    $0xf4,%dl
  800150:	ee                   	out    %al,(%dx)

  outb(0x1F2, nsecs);
  outb(0x1F3, secno & 0xFF);
  outb(0x1F4, (secno >> 8) & 0xFF);
  outb(0x1F5, (secno >> 16) & 0xFF);
  800151:	89 f8                	mov    %edi,%eax
  800153:	c1 e8 10             	shr    $0x10,%eax
  800156:	b2 f5                	mov    $0xf5,%dl
  800158:	ee                   	out    %al,(%dx)
  outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  800159:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800160:	83 e0 01             	and    $0x1,%eax
  800163:	c1 e0 04             	shl    $0x4,%eax
  800166:	83 c8 e0             	or     $0xffffffe0,%eax
  800169:	c1 ef 18             	shr    $0x18,%edi
  80016c:	83 e7 0f             	and    $0xf,%edi
  80016f:	09 f8                	or     %edi,%eax
  800171:	b2 f6                	mov    $0xf6,%dl
  800173:	ee                   	out    %al,(%dx)
  800174:	b2 f7                	mov    $0xf7,%dl
  800176:	b8 20 00 00 00       	mov    $0x20,%eax
  80017b:	ee                   	out    %al,(%dx)
  80017c:	c1 e6 09             	shl    $0x9,%esi
  80017f:	01 de                	add    %ebx,%esi
  800181:	eb 23                	jmp    8001a6 <ide_read+0xb2>
  outb(0x1F7, 0x20);            // CMD 0x20 means read sector

  for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
    if ((r = ide_wait_ready(1)) < 0)
  800183:	b8 01 00 00 00       	mov    $0x1,%eax
  800188:	e8 a6 fe ff ff       	call   800033 <ide_wait_ready>
  80018d:	85 c0                	test   %eax,%eax
  80018f:	78 1e                	js     8001af <ide_read+0xbb>
}

static __inline void
insl(int port, void *addr, int cnt)
{
  __asm __volatile("cld\n\trepne\n\tinsl"                 :
  800191:	89 df                	mov    %ebx,%edi
  800193:	b9 80 00 00 00       	mov    $0x80,%ecx
  800198:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80019d:	fc                   	cld    
  80019e:	f2 6d                	repnz insl (%dx),%es:(%edi)
  outb(0x1F4, (secno >> 8) & 0xFF);
  outb(0x1F5, (secno >> 16) & 0xFF);
  outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  outb(0x1F7, 0x20);            // CMD 0x20 means read sector

  for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  8001a0:	81 c3 00 02 00 00    	add    $0x200,%ebx
  8001a6:	39 f3                	cmp    %esi,%ebx
  8001a8:	75 d9                	jne    800183 <ide_read+0x8f>
    if ((r = ide_wait_ready(1)) < 0)
      return r;
    insl(0x1F0, dst, SECTSIZE/4);
  }

  return 0;
  8001aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001af:	83 c4 1c             	add    $0x1c,%esp
  8001b2:	5b                   	pop    %ebx
  8001b3:	5e                   	pop    %esi
  8001b4:	5f                   	pop    %edi
  8001b5:	5d                   	pop    %ebp
  8001b6:	c3                   	ret    

008001b7 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	57                   	push   %edi
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	83 ec 1c             	sub    $0x1c,%esp
  8001c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001c6:	8b 7d 10             	mov    0x10(%ebp),%edi
  int r;

  assert(nsecs <= 256);
  8001c9:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001cf:	76 24                	jbe    8001f5 <ide_write+0x3e>
  8001d1:	c7 44 24 0c 90 3c 80 	movl   $0x803c90,0xc(%esp)
  8001d8:	00 
  8001d9:	c7 44 24 08 9d 3c 80 	movl   $0x803c9d,0x8(%esp)
  8001e0:	00 
  8001e1:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8001e8:	00 
  8001e9:	c7 04 24 87 3c 80 00 	movl   $0x803c87,(%esp)
  8001f0:	e8 b6 1a 00 00       	call   801cab <_panic>

  ide_wait_ready(0);
  8001f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8001fa:	e8 34 fe ff ff       	call   800033 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
  __asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001ff:	ba f2 01 00 00       	mov    $0x1f2,%edx
  800204:	89 f8                	mov    %edi,%eax
  800206:	ee                   	out    %al,(%dx)
  800207:	b2 f3                	mov    $0xf3,%dl
  800209:	89 f0                	mov    %esi,%eax
  80020b:	ee                   	out    %al,(%dx)
  80020c:	89 f0                	mov    %esi,%eax
  80020e:	0f b6 c4             	movzbl %ah,%eax
  800211:	b2 f4                	mov    $0xf4,%dl
  800213:	ee                   	out    %al,(%dx)

  outb(0x1F2, nsecs);
  outb(0x1F3, secno & 0xFF);
  outb(0x1F4, (secno >> 8) & 0xFF);
  outb(0x1F5, (secno >> 16) & 0xFF);
  800214:	89 f0                	mov    %esi,%eax
  800216:	c1 e8 10             	shr    $0x10,%eax
  800219:	b2 f5                	mov    $0xf5,%dl
  80021b:	ee                   	out    %al,(%dx)
  outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  80021c:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800223:	83 e0 01             	and    $0x1,%eax
  800226:	c1 e0 04             	shl    $0x4,%eax
  800229:	83 c8 e0             	or     $0xffffffe0,%eax
  80022c:	c1 ee 18             	shr    $0x18,%esi
  80022f:	83 e6 0f             	and    $0xf,%esi
  800232:	09 f0                	or     %esi,%eax
  800234:	b2 f6                	mov    $0xf6,%dl
  800236:	ee                   	out    %al,(%dx)
  800237:	b2 f7                	mov    $0xf7,%dl
  800239:	b8 30 00 00 00       	mov    $0x30,%eax
  80023e:	ee                   	out    %al,(%dx)
  80023f:	c1 e7 09             	shl    $0x9,%edi
  800242:	01 df                	add    %ebx,%edi
  800244:	eb 23                	jmp    800269 <ide_write+0xb2>
  outb(0x1F7, 0x30);            // CMD 0x30 means write sector

  for (; nsecs > 0; nsecs--, src += SECTSIZE) {
    if ((r = ide_wait_ready(1)) < 0)
  800246:	b8 01 00 00 00       	mov    $0x1,%eax
  80024b:	e8 e3 fd ff ff       	call   800033 <ide_wait_ready>
  800250:	85 c0                	test   %eax,%eax
  800252:	78 1e                	js     800272 <ide_write+0xbb>
}

static __inline void
outsl(int port, const void *addr, int cnt)
{
  __asm __volatile("cld\n\trepne\n\toutsl"                :
  800254:	89 de                	mov    %ebx,%esi
  800256:	b9 80 00 00 00       	mov    $0x80,%ecx
  80025b:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800260:	fc                   	cld    
  800261:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
  outb(0x1F4, (secno >> 8) & 0xFF);
  outb(0x1F5, (secno >> 16) & 0xFF);
  outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  outb(0x1F7, 0x30);            // CMD 0x30 means write sector

  for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  800263:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800269:	39 fb                	cmp    %edi,%ebx
  80026b:	75 d9                	jne    800246 <ide_write+0x8f>
    if ((r = ide_wait_ready(1)) < 0)
      return r;
    outsl(0x1F0, src, SECTSIZE/4);
  }

  return 0;
  80026d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800272:	83 c4 1c             	add    $0x1c,%esp
  800275:	5b                   	pop    %ebx
  800276:	5e                   	pop    %esi
  800277:	5f                   	pop    %edi
  800278:	5d                   	pop    %ebp
  800279:	c3                   	ret    

0080027a <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	57                   	push   %edi
  80027e:	56                   	push   %esi
  80027f:	53                   	push   %ebx
  800280:	83 ec 2c             	sub    $0x2c,%esp
  800283:	8b 55 08             	mov    0x8(%ebp),%edx
  void *addr = (void*)utf->utf_fault_va;
  800286:	8b 32                	mov    (%edx),%esi
  uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  800288:	8d 86 00 00 00 f0    	lea    -0x10000000(%esi),%eax
  80028e:	89 c7                	mov    %eax,%edi
  800290:	c1 ef 0c             	shr    $0xc,%edi
  int r;

  // Check that the fault was within the block cache region
  if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800293:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800298:	76 2e                	jbe    8002c8 <bc_pgfault+0x4e>
    panic("page fault in FS: eip %08x, va %08x, err %04x",
  80029a:	8b 42 04             	mov    0x4(%edx),%eax
  80029d:	89 44 24 14          	mov    %eax,0x14(%esp)
  8002a1:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002a5:	8b 42 28             	mov    0x28(%edx),%eax
  8002a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ac:	c7 44 24 08 b4 3c 80 	movl   $0x803cb4,0x8(%esp)
  8002b3:	00 
  8002b4:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  8002bb:	00 
  8002bc:	c7 04 24 70 3d 80 00 	movl   $0x803d70,(%esp)
  8002c3:	e8 e3 19 00 00       	call   801cab <_panic>
          utf->utf_eip, addr, utf->utf_err);

  // Sanity check the block number.
  if (super && blockno >= super->s_nblocks)
  8002c8:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	74 25                	je     8002f6 <bc_pgfault+0x7c>
  8002d1:	3b 78 04             	cmp    0x4(%eax),%edi
  8002d4:	72 20                	jb     8002f6 <bc_pgfault+0x7c>
    panic("reading non-existent block %08x\n", blockno);
  8002d6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8002da:	c7 44 24 08 e4 3c 80 	movl   $0x803ce4,0x8(%esp)
  8002e1:	00 
  8002e2:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8002e9:	00 
  8002ea:	c7 04 24 70 3d 80 00 	movl   $0x803d70,(%esp)
  8002f1:	e8 b5 19 00 00       	call   801cab <_panic>
  // of the block from the disk into that page.
  // Hint: first round addr to page boundary. fs/ide.c has code to read
  // the disk.
  //
  // LAB 5: you code here:
    if ((r = sys_page_alloc(thisenv->env_id, ROUNDDOWN(addr, PGSIZE), PTE_W | PTE_U)) < 0)
  8002f6:	89 f3                	mov    %esi,%ebx
  8002f8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  8002fe:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  800303:	8b 40 48             	mov    0x48(%eax),%eax
  800306:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  80030d:	00 
  80030e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800312:	89 04 24             	mov    %eax,(%esp)
  800315:	e8 c9 24 00 00       	call   8027e3 <sys_page_alloc>
  80031a:	85 c0                	test   %eax,%eax
  80031c:	79 20                	jns    80033e <bc_pgfault+0xc4>
        panic("sys_page_alloc: %e", r);
  80031e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800322:	c7 44 24 08 78 3d 80 	movl   $0x803d78,0x8(%esp)
  800329:	00 
  80032a:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  800331:	00 
  800332:	c7 04 24 70 3d 80 00 	movl   $0x803d70,(%esp)
  800339:	e8 6d 19 00 00       	call   801cab <_panic>

    if ((r = ide_read(BLKSECTS * blockno, ROUNDDOWN(addr, PGSIZE), BLKSECTS)) < 0 )
  80033e:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  800345:	00 
  800346:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80034a:	8d 04 fd 00 00 00 00 	lea    0x0(,%edi,8),%eax
  800351:	89 04 24             	mov    %eax,(%esp)
  800354:	e8 9b fd ff ff       	call   8000f4 <ide_read>
  800359:	85 c0                	test   %eax,%eax
  80035b:	79 1c                	jns    800379 <bc_pgfault+0xff>
        panic("ide_read failed");
  80035d:	c7 44 24 08 8b 3d 80 	movl   $0x803d8b,0x8(%esp)
  800364:	00 
  800365:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  80036c:	00 
  80036d:	c7 04 24 70 3d 80 00 	movl   $0x803d70,(%esp)
  800374:	e8 32 19 00 00       	call   801cab <_panic>

    if ((r = sys_page_map(0, ROUNDDOWN(addr, PGSIZE), 0, ROUNDDOWN(addr, PGSIZE), uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  800379:	c1 ee 0c             	shr    $0xc,%esi
  80037c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800383:	25 07 0e 00 00       	and    $0xe07,%eax
  800388:	89 44 24 10          	mov    %eax,0x10(%esp)
  80038c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800390:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800397:	00 
  800398:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80039c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8003a3:	e8 8f 24 00 00       	call   802837 <sys_page_map>
  8003a8:	85 c0                	test   %eax,%eax
  8003aa:	79 20                	jns    8003cc <bc_pgfault+0x152>
        panic("in bc_pgfault, sys_page_map: %e", r);
  8003ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003b0:	c7 44 24 08 08 3d 80 	movl   $0x803d08,0x8(%esp)
  8003b7:	00 
  8003b8:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8003bf:	00 
  8003c0:	c7 04 24 70 3d 80 00 	movl   $0x803d70,(%esp)
  8003c7:	e8 df 18 00 00       	call   801cab <_panic>

    if (bitmap && block_is_free(blockno))
  8003cc:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  8003d3:	74 2c                	je     800401 <bc_pgfault+0x187>
  8003d5:	89 3c 24             	mov    %edi,(%esp)
  8003d8:	e8 35 04 00 00       	call   800812 <block_is_free>
  8003dd:	84 c0                	test   %al,%al
  8003df:	74 20                	je     800401 <bc_pgfault+0x187>
        panic("reading free block %08x\n", blockno);
  8003e1:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8003e5:	c7 44 24 08 9b 3d 80 	movl   $0x803d9b,0x8(%esp)
  8003ec:	00 
  8003ed:	c7 44 24 04 3d 00 00 	movl   $0x3d,0x4(%esp)
  8003f4:	00 
  8003f5:	c7 04 24 70 3d 80 00 	movl   $0x803d70,(%esp)
  8003fc:	e8 aa 18 00 00       	call   801cab <_panic>
}
  800401:	83 c4 2c             	add    $0x2c,%esp
  800404:	5b                   	pop    %ebx
  800405:	5e                   	pop    %esi
  800406:	5f                   	pop    %edi
  800407:	5d                   	pop    %ebp
  800408:	c3                   	ret    

00800409 <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  800409:	55                   	push   %ebp
  80040a:	89 e5                	mov    %esp,%ebp
  80040c:	83 ec 18             	sub    $0x18,%esp
  80040f:	8b 45 08             	mov    0x8(%ebp),%eax
  if (blockno == 0 || (super && blockno >= super->s_nblocks))
  800412:	85 c0                	test   %eax,%eax
  800414:	74 0f                	je     800425 <diskaddr+0x1c>
  800416:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  80041c:	85 d2                	test   %edx,%edx
  80041e:	74 25                	je     800445 <diskaddr+0x3c>
  800420:	3b 42 04             	cmp    0x4(%edx),%eax
  800423:	72 20                	jb     800445 <diskaddr+0x3c>
    panic("bad block number %08x in diskaddr", blockno);
  800425:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800429:	c7 44 24 08 28 3d 80 	movl   $0x803d28,0x8(%esp)
  800430:	00 
  800431:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  800438:	00 
  800439:	c7 04 24 70 3d 80 00 	movl   $0x803d70,(%esp)
  800440:	e8 66 18 00 00       	call   801cab <_panic>
  return (char*)(DISKMAP + blockno * BLKSIZE);
  800445:	05 00 00 01 00       	add    $0x10000,%eax
  80044a:	c1 e0 0c             	shl    $0xc,%eax
}
  80044d:	c9                   	leave  
  80044e:	c3                   	ret    

0080044f <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  80044f:	55                   	push   %ebp
  800450:	89 e5                	mov    %esp,%ebp
  800452:	8b 55 08             	mov    0x8(%ebp),%edx
  return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  800455:	89 d0                	mov    %edx,%eax
  800457:	c1 e8 16             	shr    $0x16,%eax
  80045a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  800461:	b8 00 00 00 00       	mov    $0x0,%eax
  800466:	f6 c1 01             	test   $0x1,%cl
  800469:	74 0d                	je     800478 <va_is_mapped+0x29>
  80046b:	c1 ea 0c             	shr    $0xc,%edx
  80046e:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800475:	83 e0 01             	and    $0x1,%eax
  800478:	83 e0 01             	and    $0x1,%eax
}
  80047b:	5d                   	pop    %ebp
  80047c:	c3                   	ret    

0080047d <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  80047d:	55                   	push   %ebp
  80047e:	89 e5                	mov    %esp,%ebp
  return (uvpt[PGNUM(va)] & PTE_D) != 0;
  800480:	8b 45 08             	mov    0x8(%ebp),%eax
  800483:	c1 e8 0c             	shr    $0xc,%eax
  800486:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80048d:	c1 e8 06             	shr    $0x6,%eax
  800490:	83 e0 01             	and    $0x1,%eax
}
  800493:	5d                   	pop    %ebp
  800494:	c3                   	ret    

00800495 <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  800495:	55                   	push   %ebp
  800496:	89 e5                	mov    %esp,%ebp
  800498:	56                   	push   %esi
  800499:	53                   	push   %ebx
  80049a:	83 ec 20             	sub    $0x20,%esp
  80049d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

  if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  8004a0:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  8004a6:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  8004ab:	76 20                	jbe    8004cd <flush_block+0x38>
    panic("flush_block of bad va %08x", addr);
  8004ad:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004b1:	c7 44 24 08 b4 3d 80 	movl   $0x803db4,0x8(%esp)
  8004b8:	00 
  8004b9:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  8004c0:	00 
  8004c1:	c7 04 24 70 3d 80 00 	movl   $0x803d70,(%esp)
  8004c8:	e8 de 17 00 00       	call   801cab <_panic>

  // LAB 5: Your code here.
    int r;

    if (!va_is_mapped(addr) || !va_is_dirty(addr))
  8004cd:	89 1c 24             	mov    %ebx,(%esp)
  8004d0:	e8 7a ff ff ff       	call   80044f <va_is_mapped>
  8004d5:	84 c0                	test   %al,%al
  8004d7:	0f 84 da 00 00 00    	je     8005b7 <flush_block+0x122>
  8004dd:	89 1c 24             	mov    %ebx,(%esp)
  8004e0:	e8 98 ff ff ff       	call   80047d <va_is_dirty>
  8004e5:	84 c0                	test   %al,%al
  8004e7:	0f 84 ca 00 00 00    	je     8005b7 <flush_block+0x122>
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  8004ed:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  8004f3:	c1 e8 0c             	shr    $0xc,%eax
    int r;

    if (!va_is_mapped(addr) || !va_is_dirty(addr))
        return;

    if (super && blockno >= super->s_nblocks)
  8004f6:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8004fc:	85 d2                	test   %edx,%edx
  8004fe:	74 25                	je     800525 <flush_block+0x90>
  800500:	3b 42 04             	cmp    0x4(%edx),%eax
  800503:	72 20                	jb     800525 <flush_block+0x90>
        panic("bad block number %08x in diskaddr", blockno);
  800505:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800509:	c7 44 24 08 28 3d 80 	movl   $0x803d28,0x8(%esp)
  800510:	00 
  800511:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  800518:	00 
  800519:	c7 04 24 70 3d 80 00 	movl   $0x803d70,(%esp)
  800520:	e8 86 17 00 00       	call   801cab <_panic>

    if ((r = ide_write(BLKSECTS * blockno, ROUNDDOWN(addr, PGSIZE), BLKSECTS) < 0))
  800525:	89 de                	mov    %ebx,%esi
  800527:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  80052d:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  800534:	00 
  800535:	89 74 24 04          	mov    %esi,0x4(%esp)
  800539:	c1 e0 03             	shl    $0x3,%eax
  80053c:	89 04 24             	mov    %eax,(%esp)
  80053f:	e8 73 fc ff ff       	call   8001b7 <ide_write>
  800544:	85 c0                	test   %eax,%eax
  800546:	79 1c                	jns    800564 <flush_block+0xcf>
        panic("ide_write failed");
  800548:	c7 44 24 08 cf 3d 80 	movl   $0x803dcf,0x8(%esp)
  80054f:	00 
  800550:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  800557:	00 
  800558:	c7 04 24 70 3d 80 00 	movl   $0x803d70,(%esp)
  80055f:	e8 47 17 00 00       	call   801cab <_panic>

    if ((r = sys_page_map(0, ROUNDDOWN(addr, PGSIZE), 0, ROUNDDOWN(addr, PGSIZE), uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  800564:	c1 eb 0c             	shr    $0xc,%ebx
  800567:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80056e:	25 07 0e 00 00       	and    $0xe07,%eax
  800573:	89 44 24 10          	mov    %eax,0x10(%esp)
  800577:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80057b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800582:	00 
  800583:	89 74 24 04          	mov    %esi,0x4(%esp)
  800587:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80058e:	e8 a4 22 00 00       	call   802837 <sys_page_map>
  800593:	85 c0                	test   %eax,%eax
  800595:	79 20                	jns    8005b7 <flush_block+0x122>
        panic ("sys_page_map error: %x", r);
  800597:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80059b:	c7 44 24 08 e0 3d 80 	movl   $0x803de0,0x8(%esp)
  8005a2:	00 
  8005a3:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  8005aa:	00 
  8005ab:	c7 04 24 70 3d 80 00 	movl   $0x803d70,(%esp)
  8005b2:	e8 f4 16 00 00       	call   801cab <_panic>

}
  8005b7:	83 c4 20             	add    $0x20,%esp
  8005ba:	5b                   	pop    %ebx
  8005bb:	5e                   	pop    %esi
  8005bc:	5d                   	pop    %ebp
  8005bd:	c3                   	ret    

008005be <bc_init>:
  cprintf("block cache is good\n");
}

void
bc_init(void)
{
  8005be:	55                   	push   %ebp
  8005bf:	89 e5                	mov    %esp,%ebp
  8005c1:	81 ec 28 02 00 00    	sub    $0x228,%esp
  struct Super super;

  set_pgfault_handler(bc_pgfault);
  8005c7:	c7 04 24 7a 02 80 00 	movl   $0x80027a,(%esp)
  8005ce:	e8 78 24 00 00       	call   802a4b <set_pgfault_handler>
check_bc(void)
{
  struct Super backup;

  // back up super block
  memmove(&backup, diskaddr(1), sizeof backup);
  8005d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005da:	e8 2a fe ff ff       	call   800409 <diskaddr>
  8005df:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  8005e6:	00 
  8005e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005eb:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8005f1:	89 04 24             	mov    %eax,(%esp)
  8005f4:	e8 6b 1f 00 00       	call   802564 <memmove>

  // smash it
  strcpy(diskaddr(1), "OOPS!\n");
  8005f9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800600:	e8 04 fe ff ff       	call   800409 <diskaddr>
  800605:	c7 44 24 04 f7 3d 80 	movl   $0x803df7,0x4(%esp)
  80060c:	00 
  80060d:	89 04 24             	mov    %eax,(%esp)
  800610:	e8 b2 1d 00 00       	call   8023c7 <strcpy>
  flush_block(diskaddr(1));
  800615:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80061c:	e8 e8 fd ff ff       	call   800409 <diskaddr>
  800621:	89 04 24             	mov    %eax,(%esp)
  800624:	e8 6c fe ff ff       	call   800495 <flush_block>
  assert(va_is_mapped(diskaddr(1)));
  800629:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800630:	e8 d4 fd ff ff       	call   800409 <diskaddr>
  800635:	89 04 24             	mov    %eax,(%esp)
  800638:	e8 12 fe ff ff       	call   80044f <va_is_mapped>
  80063d:	84 c0                	test   %al,%al
  80063f:	75 24                	jne    800665 <bc_init+0xa7>
  800641:	c7 44 24 0c 19 3e 80 	movl   $0x803e19,0xc(%esp)
  800648:	00 
  800649:	c7 44 24 08 9d 3c 80 	movl   $0x803c9d,0x8(%esp)
  800650:	00 
  800651:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  800658:	00 
  800659:	c7 04 24 70 3d 80 00 	movl   $0x803d70,(%esp)
  800660:	e8 46 16 00 00       	call   801cab <_panic>
  assert(!va_is_dirty(diskaddr(1)));
  800665:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80066c:	e8 98 fd ff ff       	call   800409 <diskaddr>
  800671:	89 04 24             	mov    %eax,(%esp)
  800674:	e8 04 fe ff ff       	call   80047d <va_is_dirty>
  800679:	84 c0                	test   %al,%al
  80067b:	74 24                	je     8006a1 <bc_init+0xe3>
  80067d:	c7 44 24 0c fe 3d 80 	movl   $0x803dfe,0xc(%esp)
  800684:	00 
  800685:	c7 44 24 08 9d 3c 80 	movl   $0x803c9d,0x8(%esp)
  80068c:	00 
  80068d:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  800694:	00 
  800695:	c7 04 24 70 3d 80 00 	movl   $0x803d70,(%esp)
  80069c:	e8 0a 16 00 00       	call   801cab <_panic>

  // clear it out
  sys_page_unmap(0, diskaddr(1));
  8006a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006a8:	e8 5c fd ff ff       	call   800409 <diskaddr>
  8006ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006b8:	e8 cd 21 00 00       	call   80288a <sys_page_unmap>
  assert(!va_is_mapped(diskaddr(1)));
  8006bd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006c4:	e8 40 fd ff ff       	call   800409 <diskaddr>
  8006c9:	89 04 24             	mov    %eax,(%esp)
  8006cc:	e8 7e fd ff ff       	call   80044f <va_is_mapped>
  8006d1:	84 c0                	test   %al,%al
  8006d3:	74 24                	je     8006f9 <bc_init+0x13b>
  8006d5:	c7 44 24 0c 18 3e 80 	movl   $0x803e18,0xc(%esp)
  8006dc:	00 
  8006dd:	c7 44 24 08 9d 3c 80 	movl   $0x803c9d,0x8(%esp)
  8006e4:	00 
  8006e5:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
  8006ec:	00 
  8006ed:	c7 04 24 70 3d 80 00 	movl   $0x803d70,(%esp)
  8006f4:	e8 b2 15 00 00       	call   801cab <_panic>

  // read it back in
  assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8006f9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800700:	e8 04 fd ff ff       	call   800409 <diskaddr>
  800705:	c7 44 24 04 f7 3d 80 	movl   $0x803df7,0x4(%esp)
  80070c:	00 
  80070d:	89 04 24             	mov    %eax,(%esp)
  800710:	e8 67 1d 00 00       	call   80247c <strcmp>
  800715:	85 c0                	test   %eax,%eax
  800717:	74 24                	je     80073d <bc_init+0x17f>
  800719:	c7 44 24 0c 4c 3d 80 	movl   $0x803d4c,0xc(%esp)
  800720:	00 
  800721:	c7 44 24 08 9d 3c 80 	movl   $0x803c9d,0x8(%esp)
  800728:	00 
  800729:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
  800730:	00 
  800731:	c7 04 24 70 3d 80 00 	movl   $0x803d70,(%esp)
  800738:	e8 6e 15 00 00       	call   801cab <_panic>

  // fix it
  memmove(diskaddr(1), &backup, sizeof backup);
  80073d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800744:	e8 c0 fc ff ff       	call   800409 <diskaddr>
  800749:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  800750:	00 
  800751:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  800757:	89 54 24 04          	mov    %edx,0x4(%esp)
  80075b:	89 04 24             	mov    %eax,(%esp)
  80075e:	e8 01 1e 00 00       	call   802564 <memmove>
  flush_block(diskaddr(1));
  800763:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80076a:	e8 9a fc ff ff       	call   800409 <diskaddr>
  80076f:	89 04 24             	mov    %eax,(%esp)
  800772:	e8 1e fd ff ff       	call   800495 <flush_block>

  cprintf("block cache is good\n");
  800777:	c7 04 24 33 3e 80 00 	movl   $0x803e33,(%esp)
  80077e:	e8 21 16 00 00       	call   801da4 <cprintf>

  set_pgfault_handler(bc_pgfault);
  check_bc();

  // cache the super block by reading it once
  memmove(&super, diskaddr(1), sizeof super);
  800783:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80078a:	e8 7a fc ff ff       	call   800409 <diskaddr>
  80078f:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  800796:	00 
  800797:	89 44 24 04          	mov    %eax,0x4(%esp)
  80079b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8007a1:	89 04 24             	mov    %eax,(%esp)
  8007a4:	e8 bb 1d 00 00       	call   802564 <memmove>
}
  8007a9:	c9                   	leave  
  8007aa:	c3                   	ret    
  8007ab:	66 90                	xchg   %ax,%ax
  8007ad:	66 90                	xchg   %ax,%ax
  8007af:	90                   	nop

008007b0 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	83 ec 18             	sub    $0x18,%esp
  if (super->s_magic != FS_MAGIC)
  8007b6:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8007bb:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  8007c1:	74 1c                	je     8007df <check_super+0x2f>
    panic("bad file system magic number");
  8007c3:	c7 44 24 08 48 3e 80 	movl   $0x803e48,0x8(%esp)
  8007ca:	00 
  8007cb:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8007d2:	00 
  8007d3:	c7 04 24 65 3e 80 00 	movl   $0x803e65,(%esp)
  8007da:	e8 cc 14 00 00       	call   801cab <_panic>

  if (super->s_nblocks > DISKSIZE/BLKSIZE)
  8007df:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8007e6:	76 1c                	jbe    800804 <check_super+0x54>
    panic("file system is too large");
  8007e8:	c7 44 24 08 6d 3e 80 	movl   $0x803e6d,0x8(%esp)
  8007ef:	00 
  8007f0:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  8007f7:	00 
  8007f8:	c7 04 24 65 3e 80 00 	movl   $0x803e65,(%esp)
  8007ff:	e8 a7 14 00 00       	call   801cab <_panic>

  cprintf("superblock is good\n");
  800804:	c7 04 24 86 3e 80 00 	movl   $0x803e86,(%esp)
  80080b:	e8 94 15 00 00       	call   801da4 <cprintf>
}
  800810:	c9                   	leave  
  800811:	c3                   	ret    

00800812 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if (super == 0 || blockno >= super->s_nblocks)
  800818:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  80081e:	85 d2                	test   %edx,%edx
  800820:	74 22                	je     800844 <block_is_free+0x32>
    return 0;
  800822:	b8 00 00 00 00       	mov    $0x0,%eax
// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  if (super == 0 || blockno >= super->s_nblocks)
  800827:	39 4a 04             	cmp    %ecx,0x4(%edx)
  80082a:	76 1d                	jbe    800849 <block_is_free+0x37>
    return 0;
  if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  80082c:	b8 01 00 00 00       	mov    $0x1,%eax
  800831:	d3 e0                	shl    %cl,%eax
  800833:	c1 e9 05             	shr    $0x5,%ecx
  800836:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  80083c:	85 04 8a             	test   %eax,(%edx,%ecx,4)
    return 1;
  80083f:	0f 95 c0             	setne  %al
  800842:	eb 05                	jmp    800849 <block_is_free+0x37>
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  if (super == 0 || blockno >= super->s_nblocks)
    return 0;
  800844:	b8 00 00 00 00       	mov    $0x0,%eax
  if (bitmap[blockno / 32] & (1 << (blockno % 32)))
    return 1;
  return 0;
}
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	53                   	push   %ebx
  80084f:	83 ec 14             	sub    $0x14,%esp
  800852:	8b 4d 08             	mov    0x8(%ebp),%ecx
  // Blockno zero is the null pointer of block numbers.
  if (blockno == 0)
  800855:	85 c9                	test   %ecx,%ecx
  800857:	75 1c                	jne    800875 <free_block+0x2a>
    panic("attempt to free zero block");
  800859:	c7 44 24 08 9a 3e 80 	movl   $0x803e9a,0x8(%esp)
  800860:	00 
  800861:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800868:	00 
  800869:	c7 04 24 65 3e 80 00 	movl   $0x803e65,(%esp)
  800870:	e8 36 14 00 00       	call   801cab <_panic>
  bitmap[blockno/32] |= 1<<(blockno%32);
  800875:	89 ca                	mov    %ecx,%edx
  800877:	c1 ea 05             	shr    $0x5,%edx
  80087a:	a1 04 a0 80 00       	mov    0x80a004,%eax
  80087f:	bb 01 00 00 00       	mov    $0x1,%ebx
  800884:	d3 e3                	shl    %cl,%ebx
  800886:	09 1c 90             	or     %ebx,(%eax,%edx,4)
}
  800889:	83 c4 14             	add    $0x14,%esp
  80088c:	5b                   	pop    %ebx
  80088d:	5d                   	pop    %ebp
  80088e:	c3                   	ret    

0080088f <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	56                   	push   %esi
  800893:	53                   	push   %ebx
  800894:	83 ec 10             	sub    $0x10,%esp
  // contains the in-use bits for BLKBITSIZE blocks.  There are
  // super->s_nblocks blocks in the disk altogether.

  // LAB 5: Your code here.
  uint32_t blockno = 0;
  for (blockno = 0; blockno != super->s_nblocks * BLKBITSIZE; blockno++) {
  800897:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80089c:	8b 70 04             	mov    0x4(%eax),%esi
  80089f:	c1 e6 0f             	shl    $0xf,%esi
  8008a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8008a7:	eb 5b                	jmp    800904 <alloc_block+0x75>
    if (block_is_free(blockno)) {
  8008a9:	89 1c 24             	mov    %ebx,(%esp)
  8008ac:	e8 61 ff ff ff       	call   800812 <block_is_free>
  8008b1:	84 c0                	test   %al,%al
  8008b3:	74 4c                	je     800901 <alloc_block+0x72>
      if (blockno == 0)
  8008b5:	85 db                	test   %ebx,%ebx
  8008b7:	75 1c                	jne    8008d5 <alloc_block+0x46>
        panic("in alloc_block, unfree_block: attempt to free zero block");
  8008b9:	c7 44 24 08 38 3f 80 	movl   $0x803f38,0x8(%esp)
  8008c0:	00 
  8008c1:	c7 44 24 04 45 00 00 	movl   $0x45,0x4(%esp)
  8008c8:	00 
  8008c9:	c7 04 24 65 3e 80 00 	movl   $0x803e65,(%esp)
  8008d0:	e8 d6 13 00 00       	call   801cab <_panic>

      bitmap[blockno/32] &= ~(1<<(blockno%32));
  8008d5:	89 da                	mov    %ebx,%edx
  8008d7:	c1 ea 05             	shr    $0x5,%edx
  8008da:	a1 04 a0 80 00       	mov    0x80a004,%eax
  8008df:	be 01 00 00 00       	mov    $0x1,%esi
  8008e4:	89 d9                	mov    %ebx,%ecx
  8008e6:	d3 e6                	shl    %cl,%esi
  8008e8:	f7 d6                	not    %esi
  8008ea:	21 34 90             	and    %esi,(%eax,%edx,4)
      flush_block(diskaddr(blockno));
  8008ed:	89 1c 24             	mov    %ebx,(%esp)
  8008f0:	e8 14 fb ff ff       	call   800409 <diskaddr>
  8008f5:	89 04 24             	mov    %eax,(%esp)
  8008f8:	e8 98 fb ff ff       	call   800495 <flush_block>
      return blockno;
  8008fd:	89 d8                	mov    %ebx,%eax
  8008ff:	eb 0c                	jmp    80090d <alloc_block+0x7e>
  // contains the in-use bits for BLKBITSIZE blocks.  There are
  // super->s_nblocks blocks in the disk altogether.

  // LAB 5: Your code here.
  uint32_t blockno = 0;
  for (blockno = 0; blockno != super->s_nblocks * BLKBITSIZE; blockno++) {
  800901:	83 c3 01             	add    $0x1,%ebx
  800904:	39 f3                	cmp    %esi,%ebx
  800906:	75 a1                	jne    8008a9 <alloc_block+0x1a>
      flush_block(diskaddr(blockno));
      return blockno;
    }
  }

	return -E_NO_DISK;
  800908:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
}
  80090d:	83 c4 10             	add    $0x10,%esp
  800910:	5b                   	pop    %ebx
  800911:	5e                   	pop    %esi
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	57                   	push   %edi
  800918:	56                   	push   %esi
  800919:	53                   	push   %ebx
  80091a:	83 ec 1c             	sub    $0x1c,%esp
  80091d:	89 c6                	mov    %eax,%esi
  80091f:	89 d3                	mov    %edx,%ebx
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  // LAB 5: Your code here.
    if (filebno >= NDIRECT + NINDIRECT)
  800924:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  80092a:	77 6e                	ja     80099a <file_block_walk+0x86>
  80092c:	89 cf                	mov    %ecx,%edi
        return -E_INVAL;

    if (filebno < NDIRECT) {
  80092e:	83 fa 09             	cmp    $0x9,%edx
  800931:	77 10                	ja     800943 <file_block_walk+0x2f>
        *ppdiskbno = &f->f_direct[filebno];
  800933:	8d 84 96 88 00 00 00 	lea    0x88(%esi,%edx,4),%eax
  80093a:	89 01                	mov    %eax,(%ecx)
        return 0;
  80093c:	b8 00 00 00 00       	mov    $0x0,%eax
  800941:	eb 6a                	jmp    8009ad <file_block_walk+0x99>
    }

    if (f->f_indirect == 0 && !alloc) {
  800943:	83 be b0 00 00 00 00 	cmpl   $0x0,0xb0(%esi)
  80094a:	75 33                	jne    80097f <file_block_walk+0x6b>
  80094c:	84 c0                	test   %al,%al
  80094e:	74 51                	je     8009a1 <file_block_walk+0x8d>
        return -E_NOT_FOUND;
    } else if (f->f_indirect == 0 && alloc) {
        int blockno = alloc_block();
  800950:	e8 3a ff ff ff       	call   80088f <alloc_block>
        if (blockno < 0) {
  800955:	85 c0                	test   %eax,%eax
  800957:	78 4f                	js     8009a8 <file_block_walk+0x94>
            return -E_NO_DISK;
        }
        f->f_indirect = blockno;
  800959:	89 86 b0 00 00 00    	mov    %eax,0xb0(%esi)
        memset(diskaddr(f->f_indirect), 0, BLKSIZE);
  80095f:	89 04 24             	mov    %eax,(%esp)
  800962:	e8 a2 fa ff ff       	call   800409 <diskaddr>
  800967:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80096e:	00 
  80096f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800976:	00 
  800977:	89 04 24             	mov    %eax,(%esp)
  80097a:	e8 98 1b 00 00       	call   802517 <memset>
    }

    uint32_t *blk = (uint32_t *) diskaddr(f->f_indirect);
  80097f:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800985:	89 04 24             	mov    %eax,(%esp)
  800988:	e8 7c fa ff ff       	call   800409 <diskaddr>
    *ppdiskbno = &blk[filebno - NDIRECT];
  80098d:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  800991:	89 07                	mov    %eax,(%edi)
    return 0;
  800993:	b8 00 00 00 00       	mov    $0x0,%eax
  800998:	eb 13                	jmp    8009ad <file_block_walk+0x99>
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  // LAB 5: Your code here.
    if (filebno >= NDIRECT + NINDIRECT)
        return -E_INVAL;
  80099a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80099f:	eb 0c                	jmp    8009ad <file_block_walk+0x99>
        *ppdiskbno = &f->f_direct[filebno];
        return 0;
    }

    if (f->f_indirect == 0 && !alloc) {
        return -E_NOT_FOUND;
  8009a1:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  8009a6:	eb 05                	jmp    8009ad <file_block_walk+0x99>
    } else if (f->f_indirect == 0 && alloc) {
        int blockno = alloc_block();
        if (blockno < 0) {
            return -E_NO_DISK;
  8009a8:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
    }

    uint32_t *blk = (uint32_t *) diskaddr(f->f_indirect);
    *ppdiskbno = &blk[filebno - NDIRECT];
    return 0;
}
  8009ad:	83 c4 1c             	add    $0x1c,%esp
  8009b0:	5b                   	pop    %ebx
  8009b1:	5e                   	pop    %esi
  8009b2:	5f                   	pop    %edi
  8009b3:	5d                   	pop    %ebp
  8009b4:	c3                   	ret    

008009b5 <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	56                   	push   %esi
  8009b9:	53                   	push   %ebx
  8009ba:	83 ec 10             	sub    $0x10,%esp
  uint32_t i;

  // Make sure all bitmap blocks are marked in-use
  for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  8009bd:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8009c2:	8b 70 04             	mov    0x4(%eax),%esi
  8009c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8009ca:	eb 36                	jmp    800a02 <check_bitmap+0x4d>
  8009cc:	8d 43 02             	lea    0x2(%ebx),%eax
    assert(!block_is_free(2+i));
  8009cf:	89 04 24             	mov    %eax,(%esp)
  8009d2:	e8 3b fe ff ff       	call   800812 <block_is_free>
  8009d7:	84 c0                	test   %al,%al
  8009d9:	74 24                	je     8009ff <check_bitmap+0x4a>
  8009db:	c7 44 24 0c b5 3e 80 	movl   $0x803eb5,0xc(%esp)
  8009e2:	00 
  8009e3:	c7 44 24 08 9d 3c 80 	movl   $0x803c9d,0x8(%esp)
  8009ea:	00 
  8009eb:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  8009f2:	00 
  8009f3:	c7 04 24 65 3e 80 00 	movl   $0x803e65,(%esp)
  8009fa:	e8 ac 12 00 00       	call   801cab <_panic>
check_bitmap(void)
{
  uint32_t i;

  // Make sure all bitmap blocks are marked in-use
  for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  8009ff:	83 c3 01             	add    $0x1,%ebx
  800a02:	89 d8                	mov    %ebx,%eax
  800a04:	c1 e0 0f             	shl    $0xf,%eax
  800a07:	39 c6                	cmp    %eax,%esi
  800a09:	77 c1                	ja     8009cc <check_bitmap+0x17>
    assert(!block_is_free(2+i));

  // Make sure the reserved and root blocks are marked in-use.
  assert(!block_is_free(0));
  800a0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a12:	e8 fb fd ff ff       	call   800812 <block_is_free>
  800a17:	84 c0                	test   %al,%al
  800a19:	74 24                	je     800a3f <check_bitmap+0x8a>
  800a1b:	c7 44 24 0c c9 3e 80 	movl   $0x803ec9,0xc(%esp)
  800a22:	00 
  800a23:	c7 44 24 08 9d 3c 80 	movl   $0x803c9d,0x8(%esp)
  800a2a:	00 
  800a2b:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
  800a32:	00 
  800a33:	c7 04 24 65 3e 80 00 	movl   $0x803e65,(%esp)
  800a3a:	e8 6c 12 00 00       	call   801cab <_panic>
  assert(!block_is_free(1));
  800a3f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a46:	e8 c7 fd ff ff       	call   800812 <block_is_free>
  800a4b:	84 c0                	test   %al,%al
  800a4d:	74 24                	je     800a73 <check_bitmap+0xbe>
  800a4f:	c7 44 24 0c db 3e 80 	movl   $0x803edb,0xc(%esp)
  800a56:	00 
  800a57:	c7 44 24 08 9d 3c 80 	movl   $0x803c9d,0x8(%esp)
  800a5e:	00 
  800a5f:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  800a66:	00 
  800a67:	c7 04 24 65 3e 80 00 	movl   $0x803e65,(%esp)
  800a6e:	e8 38 12 00 00       	call   801cab <_panic>

  cprintf("bitmap is good\n");
  800a73:	c7 04 24 ed 3e 80 00 	movl   $0x803eed,(%esp)
  800a7a:	e8 25 13 00 00       	call   801da4 <cprintf>
}
  800a7f:	83 c4 10             	add    $0x10,%esp
  800a82:	5b                   	pop    %ebx
  800a83:	5e                   	pop    %esi
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	83 ec 18             	sub    $0x18,%esp
  static_assert(sizeof(struct File) == 256);

  // Find a JOS disk.  Use the second IDE disk (number 1) if availabl
  if (ide_probe_disk1())
  800a8c:	e8 ce f5 ff ff       	call   80005f <ide_probe_disk1>
  800a91:	84 c0                	test   %al,%al
  800a93:	74 0e                	je     800aa3 <fs_init+0x1d>
    ide_set_disk(1);
  800a95:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a9c:	e8 22 f6 ff ff       	call   8000c3 <ide_set_disk>
  800aa1:	eb 0c                	jmp    800aaf <fs_init+0x29>
  else
    ide_set_disk(0);
  800aa3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800aaa:	e8 14 f6 ff ff       	call   8000c3 <ide_set_disk>
  bc_init();
  800aaf:	e8 0a fb ff ff       	call   8005be <bc_init>

  // Set "super" to point to the super block.
  super = diskaddr(1);
  800ab4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800abb:	e8 49 f9 ff ff       	call   800409 <diskaddr>
  800ac0:	a3 08 a0 80 00       	mov    %eax,0x80a008
  check_super();
  800ac5:	e8 e6 fc ff ff       	call   8007b0 <check_super>

  // Set "bitmap" to the beginning of the first bitmap block.
  bitmap = diskaddr(2);
  800aca:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800ad1:	e8 33 f9 ff ff       	call   800409 <diskaddr>
  800ad6:	a3 04 a0 80 00       	mov    %eax,0x80a004
  check_bitmap();
  800adb:	e8 d5 fe ff ff       	call   8009b5 <check_bitmap>

}
  800ae0:	c9                   	leave  
  800ae1:	c3                   	ret    

00800ae2 <file_get_block>:
//  -E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	53                   	push   %ebx
  800ae6:	83 ec 24             	sub    $0x24,%esp
  // LAB 5: Your code here.
  uint32_t *ppdiskbno;
  int r;

  if ((r = file_block_walk(f, filebno, &ppdiskbno, 1)) < 0)
  800ae9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800af0:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800af3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af6:	8b 45 08             	mov    0x8(%ebp),%eax
  800af9:	e8 16 fe ff ff       	call   800914 <file_block_walk>
  800afe:	85 c0                	test   %eax,%eax
  800b00:	78 30                	js     800b32 <file_get_block+0x50>
    return r;
  
  if (!*ppdiskbno)
  800b02:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b05:	8b 13                	mov    (%ebx),%edx
  800b07:	85 d2                	test   %edx,%edx
  800b09:	75 15                	jne    800b20 <file_get_block+0x3e>
    *ppdiskbno = alloc_block();
  800b0b:	e8 7f fd ff ff       	call   80088f <alloc_block>
  800b10:	89 03                	mov    %eax,(%ebx)

  if (!*ppdiskbno)
  800b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b15:	8b 10                	mov    (%eax),%edx
    return -E_NO_DISK;
  800b17:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
    return r;
  
  if (!*ppdiskbno)
    *ppdiskbno = alloc_block();

  if (!*ppdiskbno)
  800b1c:	85 d2                	test   %edx,%edx
  800b1e:	74 12                	je     800b32 <file_get_block+0x50>
    return -E_NO_DISK;

  *blk = (char *) diskaddr(*ppdiskbno);
  800b20:	89 14 24             	mov    %edx,(%esp)
  800b23:	e8 e1 f8 ff ff       	call   800409 <diskaddr>
  800b28:	8b 55 10             	mov    0x10(%ebp),%edx
  800b2b:	89 02                	mov    %eax,(%edx)
  return 0;
  800b2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b32:	83 c4 24             	add    $0x24,%esp
  800b35:	5b                   	pop    %ebx
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	53                   	push   %ebx
  800b3e:	81 ec cc 00 00 00    	sub    $0xcc,%esp
  800b44:	89 95 44 ff ff ff    	mov    %edx,-0xbc(%ebp)
  800b4a:	89 8d 40 ff ff ff    	mov    %ecx,-0xc0(%ebp)
  800b50:	eb 03                	jmp    800b55 <walk_path+0x1d>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
  while (*p == '/')
    p++;
  800b52:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
  while (*p == '/')
  800b55:	80 38 2f             	cmpb   $0x2f,(%eax)
  800b58:	74 f8                	je     800b52 <walk_path+0x1a>
  int r;

  // if (*path != '/')
  //  return -E_BAD_PATH;
  path = skip_slash(path);
  f = &super->s_root;
  800b5a:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
  800b60:	83 c1 08             	add    $0x8,%ecx
  800b63:	89 8d 50 ff ff ff    	mov    %ecx,-0xb0(%ebp)
  dir = 0;
  name[0] = 0;
  800b69:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

  if (pdir)
  800b70:	8b 8d 44 ff ff ff    	mov    -0xbc(%ebp),%ecx
  800b76:	85 c9                	test   %ecx,%ecx
  800b78:	74 06                	je     800b80 <walk_path+0x48>
    *pdir = 0;
  800b7a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
  *pf = 0;
  800b80:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
  800b86:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

  // if (*path != '/')
  //  return -E_BAD_PATH;
  path = skip_slash(path);
  f = &super->s_root;
  dir = 0;
  800b8c:	ba 00 00 00 00       	mov    $0x0,%edx
  name[0] = 0;

  if (pdir)
    *pdir = 0;
  *pf = 0;
  while (*path != '\0') {
  800b91:	e9 71 01 00 00       	jmp    800d07 <walk_path+0x1cf>
    dir = f;
    p = path;
    while (*path != '/' && *path != '\0')
      path++;
  800b96:	83 c7 01             	add    $0x1,%edi
    *pdir = 0;
  *pf = 0;
  while (*path != '\0') {
    dir = f;
    p = path;
    while (*path != '/' && *path != '\0')
  800b99:	0f b6 17             	movzbl (%edi),%edx
  800b9c:	84 d2                	test   %dl,%dl
  800b9e:	74 05                	je     800ba5 <walk_path+0x6d>
  800ba0:	80 fa 2f             	cmp    $0x2f,%dl
  800ba3:	75 f1                	jne    800b96 <walk_path+0x5e>
      path++;
    if (path - p >= MAXNAMELEN)
  800ba5:	89 fb                	mov    %edi,%ebx
  800ba7:	29 c3                	sub    %eax,%ebx
  800ba9:	83 fb 7f             	cmp    $0x7f,%ebx
  800bac:	0f 8f 82 01 00 00    	jg     800d34 <walk_path+0x1fc>
      return -E_BAD_PATH;
    memmove(name, p, path - p);
  800bb2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800bb6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bba:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800bc0:	89 04 24             	mov    %eax,(%esp)
  800bc3:	e8 9c 19 00 00       	call   802564 <memmove>
    name[path - p] = '\0';
  800bc8:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800bcf:	00 
  800bd0:	eb 03                	jmp    800bd5 <walk_path+0x9d>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
  while (*p == '/')
    p++;
  800bd2:	83 c7 01             	add    $0x1,%edi

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
  while (*p == '/')
  800bd5:	80 3f 2f             	cmpb   $0x2f,(%edi)
  800bd8:	74 f8                	je     800bd2 <walk_path+0x9a>
      return -E_BAD_PATH;
    memmove(name, p, path - p);
    name[path - p] = '\0';
    path = skip_slash(path);

    if (dir->f_type != FTYPE_DIR)
  800bda:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800be0:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800be7:	0f 85 4e 01 00 00    	jne    800d3b <walk_path+0x203>
  struct File *f;

  // Search dir for name.
  // We maintain the invariant that the size of a directory-file
  // is always a multiple of the file system's block size.
  assert((dir->f_size % BLKSIZE) == 0);
  800bed:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800bf3:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800bf8:	74 24                	je     800c1e <walk_path+0xe6>
  800bfa:	c7 44 24 0c fd 3e 80 	movl   $0x803efd,0xc(%esp)
  800c01:	00 
  800c02:	c7 44 24 08 9d 3c 80 	movl   $0x803c9d,0x8(%esp)
  800c09:	00 
  800c0a:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
  800c11:	00 
  800c12:	c7 04 24 65 3e 80 00 	movl   $0x803e65,(%esp)
  800c19:	e8 8d 10 00 00       	call   801cab <_panic>
  nblock = dir->f_size / BLKSIZE;
  800c1e:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800c24:	85 c0                	test   %eax,%eax
  800c26:	0f 48 c2             	cmovs  %edx,%eax
  800c29:	c1 f8 0c             	sar    $0xc,%eax
  800c2c:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
  for (i = 0; i < nblock; i++) {
  800c32:	c7 85 54 ff ff ff 00 	movl   $0x0,-0xac(%ebp)
  800c39:	00 00 00 
  800c3c:	89 bd 48 ff ff ff    	mov    %edi,-0xb8(%ebp)
  800c42:	eb 61                	jmp    800ca5 <walk_path+0x16d>
    if ((r = file_get_block(dir, i, &blk)) < 0)
  800c44:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800c4a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c4e:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800c54:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c58:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800c5e:	89 04 24             	mov    %eax,(%esp)
  800c61:	e8 7c fe ff ff       	call   800ae2 <file_get_block>
  800c66:	85 c0                	test   %eax,%eax
  800c68:	0f 88 ea 00 00 00    	js     800d58 <walk_path+0x220>
  800c6e:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
      return r;
    f = (struct File*)blk;
  800c74:	be 10 00 00 00       	mov    $0x10,%esi
    for (j = 0; j < BLKFILES; j++)
      if (strcmp(f[j].f_name, name) == 0) {
  800c79:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800c7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c83:	89 1c 24             	mov    %ebx,(%esp)
  800c86:	e8 f1 17 00 00       	call   80247c <strcmp>
  800c8b:	85 c0                	test   %eax,%eax
  800c8d:	0f 84 af 00 00 00    	je     800d42 <walk_path+0x20a>
  800c93:	81 c3 00 01 00 00    	add    $0x100,%ebx
  nblock = dir->f_size / BLKSIZE;
  for (i = 0; i < nblock; i++) {
    if ((r = file_get_block(dir, i, &blk)) < 0)
      return r;
    f = (struct File*)blk;
    for (j = 0; j < BLKFILES; j++)
  800c99:	83 ee 01             	sub    $0x1,%esi
  800c9c:	75 db                	jne    800c79 <walk_path+0x141>
  // Search dir for name.
  // We maintain the invariant that the size of a directory-file
  // is always a multiple of the file system's block size.
  assert((dir->f_size % BLKSIZE) == 0);
  nblock = dir->f_size / BLKSIZE;
  for (i = 0; i < nblock; i++) {
  800c9e:	83 85 54 ff ff ff 01 	addl   $0x1,-0xac(%ebp)
  800ca5:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800cab:	39 85 4c ff ff ff    	cmp    %eax,-0xb4(%ebp)
  800cb1:	75 91                	jne    800c44 <walk_path+0x10c>
  800cb3:	8b bd 48 ff ff ff    	mov    -0xb8(%ebp),%edi
          *pdir = dir;
        if (lastelem)
          strcpy(lastelem, name);
        *pf = 0;
      }
      return r;
  800cb9:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

    if (dir->f_type != FTYPE_DIR)
      return -E_NOT_FOUND;

    if ((r = dir_lookup(dir, name, &f)) < 0) {
      if (r == -E_NOT_FOUND && *path == '\0') {
  800cbe:	80 3f 00             	cmpb   $0x0,(%edi)
  800cc1:	0f 85 a0 00 00 00    	jne    800d67 <walk_path+0x22f>
        if (pdir)
  800cc7:	8b 85 44 ff ff ff    	mov    -0xbc(%ebp),%eax
  800ccd:	85 c0                	test   %eax,%eax
  800ccf:	74 08                	je     800cd9 <walk_path+0x1a1>
          *pdir = dir;
  800cd1:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800cd7:	89 08                	mov    %ecx,(%eax)
        if (lastelem)
  800cd9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800cdd:	74 15                	je     800cf4 <walk_path+0x1bc>
          strcpy(lastelem, name);
  800cdf:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800ce5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ce9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cec:	89 04 24             	mov    %eax,(%esp)
  800cef:	e8 d3 16 00 00       	call   8023c7 <strcpy>
        *pf = 0;
  800cf4:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800cfa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      }
      return r;
  800d00:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800d05:	eb 60                	jmp    800d67 <walk_path+0x22f>
  name[0] = 0;

  if (pdir)
    *pdir = 0;
  *pf = 0;
  while (*path != '\0') {
  800d07:	80 38 00             	cmpb   $0x0,(%eax)
  800d0a:	74 07                	je     800d13 <walk_path+0x1db>
  800d0c:	89 c7                	mov    %eax,%edi
  800d0e:	e9 86 fe ff ff       	jmp    800b99 <walk_path+0x61>
      }
      return r;
    }
  }

  if (pdir)
  800d13:	8b 85 44 ff ff ff    	mov    -0xbc(%ebp),%eax
  800d19:	85 c0                	test   %eax,%eax
  800d1b:	74 02                	je     800d1f <walk_path+0x1e7>
    *pdir = dir;
  800d1d:	89 10                	mov    %edx,(%eax)
  *pf = f;
  800d1f:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800d25:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800d2b:	89 08                	mov    %ecx,(%eax)
  return 0;
  800d2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d32:	eb 33                	jmp    800d67 <walk_path+0x22f>
    dir = f;
    p = path;
    while (*path != '/' && *path != '\0')
      path++;
    if (path - p >= MAXNAMELEN)
      return -E_BAD_PATH;
  800d34:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800d39:	eb 2c                	jmp    800d67 <walk_path+0x22f>
    memmove(name, p, path - p);
    name[path - p] = '\0';
    path = skip_slash(path);

    if (dir->f_type != FTYPE_DIR)
      return -E_NOT_FOUND;
  800d3b:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800d40:	eb 25                	jmp    800d67 <walk_path+0x22f>
  800d42:	8b bd 48 ff ff ff    	mov    -0xb8(%ebp),%edi
  800d48:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
  for (i = 0; i < nblock; i++) {
    if ((r = file_get_block(dir, i, &blk)) < 0)
      return r;
    f = (struct File*)blk;
    for (j = 0; j < BLKFILES; j++)
      if (strcmp(f[j].f_name, name) == 0) {
  800d4e:	89 9d 50 ff ff ff    	mov    %ebx,-0xb0(%ebp)
  800d54:	89 f8                	mov    %edi,%eax
  800d56:	eb af                	jmp    800d07 <walk_path+0x1cf>
  800d58:	8b bd 48 ff ff ff    	mov    -0xb8(%ebp),%edi

    if (dir->f_type != FTYPE_DIR)
      return -E_NOT_FOUND;

    if ((r = dir_lookup(dir, name, &f)) < 0) {
      if (r == -E_NOT_FOUND && *path == '\0') {
  800d5e:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800d61:	0f 84 52 ff ff ff    	je     800cb9 <walk_path+0x181>

  if (pdir)
    *pdir = dir;
  *pf = f;
  return 0;
}
  800d67:	81 c4 cc 00 00 00    	add    $0xcc,%esp
  800d6d:	5b                   	pop    %ebx
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	83 ec 18             	sub    $0x18,%esp
  return walk_path(path, 0, pf, 0);
  800d78:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d82:	ba 00 00 00 00       	mov    $0x0,%edx
  800d87:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8a:	e8 a9 fd ff ff       	call   800b38 <walk_path>
}
  800d8f:	c9                   	leave  
  800d90:	c3                   	ret    

00800d91 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	57                   	push   %edi
  800d95:	56                   	push   %esi
  800d96:	53                   	push   %ebx
  800d97:	83 ec 3c             	sub    $0x3c,%esp
  800d9a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d9d:	8b 55 14             	mov    0x14(%ebp),%edx
  int r, bn;
  off_t pos;
  char *blk;

  if (offset >= f->f_size)
  800da0:	8b 45 08             	mov    0x8(%ebp),%eax
  800da3:	8b 88 80 00 00 00    	mov    0x80(%eax),%ecx
    return 0;
  800da9:	b8 00 00 00 00       	mov    $0x0,%eax
{
  int r, bn;
  off_t pos;
  char *blk;

  if (offset >= f->f_size)
  800dae:	39 d1                	cmp    %edx,%ecx
  800db0:	0f 8e 83 00 00 00    	jle    800e39 <file_read+0xa8>
    return 0;

  count = MIN(count, f->f_size - offset);
  800db6:	29 d1                	sub    %edx,%ecx
  800db8:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800dbb:	0f 47 4d 10          	cmova  0x10(%ebp),%ecx
  800dbf:	89 4d d0             	mov    %ecx,-0x30(%ebp)

  for (pos = offset; pos < offset + count; ) {
  800dc2:	89 d3                	mov    %edx,%ebx
  800dc4:	01 ca                	add    %ecx,%edx
  800dc6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800dc9:	eb 64                	jmp    800e2f <file_read+0x9e>
    if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800dcb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800dce:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dd2:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  800dd8:	85 db                	test   %ebx,%ebx
  800dda:	0f 49 c3             	cmovns %ebx,%eax
  800ddd:	c1 f8 0c             	sar    $0xc,%eax
  800de0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800de4:	8b 45 08             	mov    0x8(%ebp),%eax
  800de7:	89 04 24             	mov    %eax,(%esp)
  800dea:	e8 f3 fc ff ff       	call   800ae2 <file_get_block>
  800def:	85 c0                	test   %eax,%eax
  800df1:	78 46                	js     800e39 <file_read+0xa8>
      return r;
    bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800df3:	89 da                	mov    %ebx,%edx
  800df5:	c1 fa 1f             	sar    $0x1f,%edx
  800df8:	c1 ea 14             	shr    $0x14,%edx
  800dfb:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  800dfe:	25 ff 0f 00 00       	and    $0xfff,%eax
  800e03:	29 d0                	sub    %edx,%eax
  800e05:	b9 00 10 00 00       	mov    $0x1000,%ecx
  800e0a:	29 c1                	sub    %eax,%ecx
  800e0c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800e0f:	29 f2                	sub    %esi,%edx
  800e11:	39 d1                	cmp    %edx,%ecx
  800e13:	89 d6                	mov    %edx,%esi
  800e15:	0f 46 f1             	cmovbe %ecx,%esi
    memmove(buf, blk + pos % BLKSIZE, bn);
  800e18:	89 74 24 08          	mov    %esi,0x8(%esp)
  800e1c:	03 45 e4             	add    -0x1c(%ebp),%eax
  800e1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e23:	89 3c 24             	mov    %edi,(%esp)
  800e26:	e8 39 17 00 00       	call   802564 <memmove>
    pos += bn;
  800e2b:	01 f3                	add    %esi,%ebx
    buf += bn;
  800e2d:	01 f7                	add    %esi,%edi
  if (offset >= f->f_size)
    return 0;

  count = MIN(count, f->f_size - offset);

  for (pos = offset; pos < offset + count; ) {
  800e2f:	89 de                	mov    %ebx,%esi
  800e31:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
  800e34:	72 95                	jb     800dcb <file_read+0x3a>
    memmove(buf, blk + pos % BLKSIZE, bn);
    pos += bn;
    buf += bn;
  }

  return count;
  800e36:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  800e39:	83 c4 3c             	add    $0x3c,%esp
  800e3c:	5b                   	pop    %ebx
  800e3d:	5e                   	pop    %esi
  800e3e:	5f                   	pop    %edi
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    

00800e41 <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	57                   	push   %edi
  800e45:	56                   	push   %esi
  800e46:	53                   	push   %ebx
  800e47:	83 ec 2c             	sub    $0x2c,%esp
  800e4a:	8b 75 08             	mov    0x8(%ebp),%esi
  if (f->f_size > newsize)
  800e4d:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800e53:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800e56:	0f 8e 9a 00 00 00    	jle    800ef6 <file_set_size+0xb5>
file_truncate_blocks(struct File *f, off_t newsize)
{
  int r;
  uint32_t bno, old_nblocks, new_nblocks;

  old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800e5c:	8d b8 fe 1f 00 00    	lea    0x1ffe(%eax),%edi
  800e62:	05 ff 0f 00 00       	add    $0xfff,%eax
  800e67:	0f 49 f8             	cmovns %eax,%edi
  800e6a:	c1 ff 0c             	sar    $0xc,%edi
  new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800e6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e70:	8d 90 fe 1f 00 00    	lea    0x1ffe(%eax),%edx
  800e76:	05 ff 0f 00 00       	add    $0xfff,%eax
  800e7b:	0f 48 c2             	cmovs  %edx,%eax
  800e7e:	c1 f8 0c             	sar    $0xc,%eax
  800e81:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  for (bno = new_nblocks; bno < old_nblocks; bno++)
  800e84:	89 c3                	mov    %eax,%ebx
  800e86:	eb 34                	jmp    800ebc <file_set_size+0x7b>
file_free_block(struct File *f, uint32_t filebno)
{
  int r;
  uint32_t *ptr;

  if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800e88:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e8f:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800e92:	89 da                	mov    %ebx,%edx
  800e94:	89 f0                	mov    %esi,%eax
  800e96:	e8 79 fa ff ff       	call   800914 <file_block_walk>
  800e9b:	85 c0                	test   %eax,%eax
  800e9d:	78 45                	js     800ee4 <file_set_size+0xa3>
    return r;
  if (*ptr) {
  800e9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ea2:	8b 00                	mov    (%eax),%eax
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	74 11                	je     800eb9 <file_set_size+0x78>
    free_block(*ptr);
  800ea8:	89 04 24             	mov    %eax,(%esp)
  800eab:	e8 9b f9 ff ff       	call   80084b <free_block>
    *ptr = 0;
  800eb0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800eb3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  int r;
  uint32_t bno, old_nblocks, new_nblocks;

  old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  for (bno = new_nblocks; bno < old_nblocks; bno++)
  800eb9:	83 c3 01             	add    $0x1,%ebx
  800ebc:	39 df                	cmp    %ebx,%edi
  800ebe:	77 c8                	ja     800e88 <file_set_size+0x47>
    if ((r = file_free_block(f, bno)) < 0)
      cprintf("warning: file_free_block: %e", r);

  if (new_nblocks <= NDIRECT && f->f_indirect) {
  800ec0:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800ec4:	77 30                	ja     800ef6 <file_set_size+0xb5>
  800ec6:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800ecc:	85 c0                	test   %eax,%eax
  800ece:	74 26                	je     800ef6 <file_set_size+0xb5>
    free_block(f->f_indirect);
  800ed0:	89 04 24             	mov    %eax,(%esp)
  800ed3:	e8 73 f9 ff ff       	call   80084b <free_block>
    f->f_indirect = 0;
  800ed8:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800edf:	00 00 00 
  800ee2:	eb 12                	jmp    800ef6 <file_set_size+0xb5>

  old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  for (bno = new_nblocks; bno < old_nblocks; bno++)
    if ((r = file_free_block(f, bno)) < 0)
      cprintf("warning: file_free_block: %e", r);
  800ee4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ee8:	c7 04 24 1a 3f 80 00 	movl   $0x803f1a,(%esp)
  800eef:	e8 b0 0e 00 00       	call   801da4 <cprintf>
  800ef4:	eb c3                	jmp    800eb9 <file_set_size+0x78>
int
file_set_size(struct File *f, off_t newsize)
{
  if (f->f_size > newsize)
    file_truncate_blocks(f, newsize);
  f->f_size = newsize;
  800ef6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef9:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
  flush_block(f);
  800eff:	89 34 24             	mov    %esi,(%esp)
  800f02:	e8 8e f5 ff ff       	call   800495 <flush_block>
  return 0;
}
  800f07:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0c:	83 c4 2c             	add    $0x2c,%esp
  800f0f:	5b                   	pop    %ebx
  800f10:	5e                   	pop    %esi
  800f11:	5f                   	pop    %edi
  800f12:	5d                   	pop    %ebp
  800f13:	c3                   	ret    

00800f14 <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
  800f17:	57                   	push   %edi
  800f18:	56                   	push   %esi
  800f19:	53                   	push   %ebx
  800f1a:	83 ec 2c             	sub    $0x2c,%esp
  800f1d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f20:	8b 5d 14             	mov    0x14(%ebp),%ebx
  int r, bn;
  off_t pos;
  char *blk;

  // Extend file if necessary
  if (offset + count > f->f_size)
  800f23:	89 d8                	mov    %ebx,%eax
  800f25:	03 45 10             	add    0x10(%ebp),%eax
  800f28:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800f2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f2e:	3b 81 80 00 00 00    	cmp    0x80(%ecx),%eax
  800f34:	76 7c                	jbe    800fb2 <file_write+0x9e>
    if ((r = file_set_size(f, offset + count)) < 0)
  800f36:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800f39:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f40:	89 04 24             	mov    %eax,(%esp)
  800f43:	e8 f9 fe ff ff       	call   800e41 <file_set_size>
  800f48:	85 c0                	test   %eax,%eax
  800f4a:	79 66                	jns    800fb2 <file_write+0x9e>
  800f4c:	eb 6e                	jmp    800fbc <file_write+0xa8>
      return r;

  for (pos = offset; pos < offset + count; ) {
    if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800f4e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f51:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f55:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  800f5b:	85 db                	test   %ebx,%ebx
  800f5d:	0f 49 c3             	cmovns %ebx,%eax
  800f60:	c1 f8 0c             	sar    $0xc,%eax
  800f63:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f67:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6a:	89 04 24             	mov    %eax,(%esp)
  800f6d:	e8 70 fb ff ff       	call   800ae2 <file_get_block>
  800f72:	85 c0                	test   %eax,%eax
  800f74:	78 46                	js     800fbc <file_write+0xa8>
      return r;
    bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800f76:	89 da                	mov    %ebx,%edx
  800f78:	c1 fa 1f             	sar    $0x1f,%edx
  800f7b:	c1 ea 14             	shr    $0x14,%edx
  800f7e:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  800f81:	25 ff 0f 00 00       	and    $0xfff,%eax
  800f86:	29 d0                	sub    %edx,%eax
  800f88:	b9 00 10 00 00       	mov    $0x1000,%ecx
  800f8d:	29 c1                	sub    %eax,%ecx
  800f8f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800f92:	29 f2                	sub    %esi,%edx
  800f94:	39 d1                	cmp    %edx,%ecx
  800f96:	89 d6                	mov    %edx,%esi
  800f98:	0f 46 f1             	cmovbe %ecx,%esi
    memmove(blk + pos % BLKSIZE, buf, bn);
  800f9b:	89 74 24 08          	mov    %esi,0x8(%esp)
  800f9f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fa3:	03 45 e4             	add    -0x1c(%ebp),%eax
  800fa6:	89 04 24             	mov    %eax,(%esp)
  800fa9:	e8 b6 15 00 00       	call   802564 <memmove>
    pos += bn;
  800fae:	01 f3                	add    %esi,%ebx
    buf += bn;
  800fb0:	01 f7                	add    %esi,%edi
  // Extend file if necessary
  if (offset + count > f->f_size)
    if ((r = file_set_size(f, offset + count)) < 0)
      return r;

  for (pos = offset; pos < offset + count; ) {
  800fb2:	89 de                	mov    %ebx,%esi
  800fb4:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
  800fb7:	77 95                	ja     800f4e <file_write+0x3a>
    memmove(blk + pos % BLKSIZE, buf, bn);
    pos += bn;
    buf += bn;
  }

  return count;
  800fb9:	8b 45 10             	mov    0x10(%ebp),%eax
}
  800fbc:	83 c4 2c             	add    $0x2c,%esp
  800fbf:	5b                   	pop    %ebx
  800fc0:	5e                   	pop    %esi
  800fc1:	5f                   	pop    %edi
  800fc2:	5d                   	pop    %ebp
  800fc3:	c3                   	ret    

00800fc4 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	56                   	push   %esi
  800fc8:	53                   	push   %ebx
  800fc9:	83 ec 20             	sub    $0x20,%esp
  800fcc:	8b 75 08             	mov    0x8(%ebp),%esi
  int i;
  uint32_t *pdiskbno;

  for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800fcf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd4:	eb 37                	jmp    80100d <file_flush+0x49>
    if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800fd6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fdd:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800fe0:	89 da                	mov    %ebx,%edx
  800fe2:	89 f0                	mov    %esi,%eax
  800fe4:	e8 2b f9 ff ff       	call   800914 <file_block_walk>
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	78 1d                	js     80100a <file_flush+0x46>
        pdiskbno == NULL || *pdiskbno == 0)
  800fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
{
  int i;
  uint32_t *pdiskbno;

  for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
    if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800ff0:	85 c0                	test   %eax,%eax
  800ff2:	74 16                	je     80100a <file_flush+0x46>
        pdiskbno == NULL || *pdiskbno == 0)
  800ff4:	8b 00                	mov    (%eax),%eax
  800ff6:	85 c0                	test   %eax,%eax
  800ff8:	74 10                	je     80100a <file_flush+0x46>
      continue;
    flush_block(diskaddr(*pdiskbno));
  800ffa:	89 04 24             	mov    %eax,(%esp)
  800ffd:	e8 07 f4 ff ff       	call   800409 <diskaddr>
  801002:	89 04 24             	mov    %eax,(%esp)
  801005:	e8 8b f4 ff ff       	call   800495 <flush_block>
file_flush(struct File *f)
{
  int i;
  uint32_t *pdiskbno;

  for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  80100a:	83 c3 01             	add    $0x1,%ebx
  80100d:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  801013:	8d 8a ff 0f 00 00    	lea    0xfff(%edx),%ecx
  801019:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  80101f:	85 c9                	test   %ecx,%ecx
  801021:	0f 49 c1             	cmovns %ecx,%eax
  801024:	c1 f8 0c             	sar    $0xc,%eax
  801027:	39 c3                	cmp    %eax,%ebx
  801029:	7c ab                	jl     800fd6 <file_flush+0x12>
    if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
        pdiskbno == NULL || *pdiskbno == 0)
      continue;
    flush_block(diskaddr(*pdiskbno));
  }
  flush_block(f);
  80102b:	89 34 24             	mov    %esi,(%esp)
  80102e:	e8 62 f4 ff ff       	call   800495 <flush_block>
  if (f->f_indirect)
  801033:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  801039:	85 c0                	test   %eax,%eax
  80103b:	74 10                	je     80104d <file_flush+0x89>
    flush_block(diskaddr(f->f_indirect));
  80103d:	89 04 24             	mov    %eax,(%esp)
  801040:	e8 c4 f3 ff ff       	call   800409 <diskaddr>
  801045:	89 04 24             	mov    %eax,(%esp)
  801048:	e8 48 f4 ff ff       	call   800495 <flush_block>
}
  80104d:	83 c4 20             	add    $0x20,%esp
  801050:	5b                   	pop    %ebx
  801051:	5e                   	pop    %esi
  801052:	5d                   	pop    %ebp
  801053:	c3                   	ret    

00801054 <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	57                   	push   %edi
  801058:	56                   	push   %esi
  801059:	53                   	push   %ebx
  80105a:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  char name[MAXNAMELEN];
  int r;
  struct File *dir, *f;

  if ((r = walk_path(path, &dir, &f, name)) == 0)
  801060:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  801066:	89 04 24             	mov    %eax,(%esp)
  801069:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  80106f:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  801075:	8b 45 08             	mov    0x8(%ebp),%eax
  801078:	e8 bb fa ff ff       	call   800b38 <walk_path>
  80107d:	89 c2                	mov    %eax,%edx
  80107f:	85 c0                	test   %eax,%eax
  801081:	0f 84 e0 00 00 00    	je     801167 <file_create+0x113>
    return -E_FILE_EXISTS;
  if (r != -E_NOT_FOUND || dir == 0)
  801087:	83 fa f5             	cmp    $0xfffffff5,%edx
  80108a:	0f 85 1b 01 00 00    	jne    8011ab <file_create+0x157>
  801090:	8b b5 64 ff ff ff    	mov    -0x9c(%ebp),%esi
  801096:	85 f6                	test   %esi,%esi
  801098:	0f 84 d0 00 00 00    	je     80116e <file_create+0x11a>
  int r;
  uint32_t nblock, i, j;
  char *blk;
  struct File *f;

  assert((dir->f_size % BLKSIZE) == 0);
  80109e:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  8010a4:	a9 ff 0f 00 00       	test   $0xfff,%eax
  8010a9:	74 24                	je     8010cf <file_create+0x7b>
  8010ab:	c7 44 24 0c fd 3e 80 	movl   $0x803efd,0xc(%esp)
  8010b2:	00 
  8010b3:	c7 44 24 08 9d 3c 80 	movl   $0x803c9d,0x8(%esp)
  8010ba:	00 
  8010bb:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  8010c2:	00 
  8010c3:	c7 04 24 65 3e 80 00 	movl   $0x803e65,(%esp)
  8010ca:	e8 dc 0b 00 00       	call   801cab <_panic>
  nblock = dir->f_size / BLKSIZE;
  8010cf:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	0f 48 c2             	cmovs  %edx,%eax
  8010da:	c1 f8 0c             	sar    $0xc,%eax
  8010dd:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
  for (i = 0; i < nblock; i++) {
  8010e3:	bb 00 00 00 00       	mov    $0x0,%ebx
    if ((r = file_get_block(dir, i, &blk)) < 0)
  8010e8:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  8010ee:	eb 3d                	jmp    80112d <file_create+0xd9>
  8010f0:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010f8:	89 34 24             	mov    %esi,(%esp)
  8010fb:	e8 e2 f9 ff ff       	call   800ae2 <file_get_block>
  801100:	85 c0                	test   %eax,%eax
  801102:	0f 88 a3 00 00 00    	js     8011ab <file_create+0x157>
  801108:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
      return r;
    f = (struct File*)blk;
  80110e:	ba 10 00 00 00       	mov    $0x10,%edx
    for (j = 0; j < BLKFILES; j++)
      if (f[j].f_name[0] == '\0') {
  801113:	80 38 00             	cmpb   $0x0,(%eax)
  801116:	75 08                	jne    801120 <file_create+0xcc>
        *file = &f[j];
  801118:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  80111e:	eb 55                	jmp    801175 <file_create+0x121>
  801120:	05 00 01 00 00       	add    $0x100,%eax
  nblock = dir->f_size / BLKSIZE;
  for (i = 0; i < nblock; i++) {
    if ((r = file_get_block(dir, i, &blk)) < 0)
      return r;
    f = (struct File*)blk;
    for (j = 0; j < BLKFILES; j++)
  801125:	83 ea 01             	sub    $0x1,%edx
  801128:	75 e9                	jne    801113 <file_create+0xbf>
  char *blk;
  struct File *f;

  assert((dir->f_size % BLKSIZE) == 0);
  nblock = dir->f_size / BLKSIZE;
  for (i = 0; i < nblock; i++) {
  80112a:	83 c3 01             	add    $0x1,%ebx
  80112d:	39 9d 54 ff ff ff    	cmp    %ebx,-0xac(%ebp)
  801133:	75 bb                	jne    8010f0 <file_create+0x9c>
      if (f[j].f_name[0] == '\0') {
        *file = &f[j];
        return 0;
      }
  }
  dir->f_size += BLKSIZE;
  801135:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  80113c:	10 00 00 
  if ((r = file_get_block(dir, i, &blk)) < 0)
  80113f:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  801145:	89 44 24 08          	mov    %eax,0x8(%esp)
  801149:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80114d:	89 34 24             	mov    %esi,(%esp)
  801150:	e8 8d f9 ff ff       	call   800ae2 <file_get_block>
  801155:	85 c0                	test   %eax,%eax
  801157:	78 52                	js     8011ab <file_create+0x157>
    return r;
  f = (struct File*)blk;
  *file = &f[0];
  801159:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  80115f:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  801165:	eb 0e                	jmp    801175 <file_create+0x121>
  char name[MAXNAMELEN];
  int r;
  struct File *dir, *f;

  if ((r = walk_path(path, &dir, &f, name)) == 0)
    return -E_FILE_EXISTS;
  801167:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  80116c:	eb 3d                	jmp    8011ab <file_create+0x157>
  if (r != -E_NOT_FOUND || dir == 0)
    return r;
  80116e:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  801173:	eb 36                	jmp    8011ab <file_create+0x157>
  if ((r = dir_alloc_file(dir, &f)) < 0)
    return r;

  strcpy(f->f_name, name);
  801175:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  80117b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80117f:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  801185:	89 04 24             	mov    %eax,(%esp)
  801188:	e8 3a 12 00 00       	call   8023c7 <strcpy>
  *pf = f;
  80118d:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  801193:	8b 45 0c             	mov    0xc(%ebp),%eax
  801196:	89 10                	mov    %edx,(%eax)
  file_flush(dir);
  801198:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  80119e:	89 04 24             	mov    %eax,(%esp)
  8011a1:	e8 1e fe ff ff       	call   800fc4 <file_flush>
  return 0;
  8011a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011ab:	81 c4 bc 00 00 00    	add    $0xbc,%esp
  8011b1:	5b                   	pop    %ebx
  8011b2:	5e                   	pop    %esi
  8011b3:	5f                   	pop    %edi
  8011b4:	5d                   	pop    %ebp
  8011b5:	c3                   	ret    

008011b6 <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  8011b6:	55                   	push   %ebp
  8011b7:	89 e5                	mov    %esp,%ebp
  8011b9:	53                   	push   %ebx
  8011ba:	83 ec 14             	sub    $0x14,%esp
  int i;

  for (i = 1; i < super->s_nblocks; i++)
  8011bd:	bb 01 00 00 00       	mov    $0x1,%ebx
  8011c2:	eb 13                	jmp    8011d7 <fs_sync+0x21>
    flush_block(diskaddr(i));
  8011c4:	89 1c 24             	mov    %ebx,(%esp)
  8011c7:	e8 3d f2 ff ff       	call   800409 <diskaddr>
  8011cc:	89 04 24             	mov    %eax,(%esp)
  8011cf:	e8 c1 f2 ff ff       	call   800495 <flush_block>
void
fs_sync(void)
{
  int i;

  for (i = 1; i < super->s_nblocks; i++)
  8011d4:	83 c3 01             	add    $0x1,%ebx
  8011d7:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8011dc:	3b 58 04             	cmp    0x4(%eax),%ebx
  8011df:	72 e3                	jb     8011c4 <fs_sync+0xe>
    flush_block(diskaddr(i));
}
  8011e1:	83 c4 14             	add    $0x14,%esp
  8011e4:	5b                   	pop    %ebx
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    
  8011e7:	66 90                	xchg   %ax,%ax
  8011e9:	66 90                	xchg   %ax,%ax
  8011eb:	66 90                	xchg   %ax,%ax
  8011ed:	66 90                	xchg   %ax,%ax
  8011ef:	90                   	nop

008011f0 <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	83 ec 08             	sub    $0x8,%esp
  fs_sync();
  8011f6:	e8 bb ff ff ff       	call   8011b6 <fs_sync>
  return 0;
}
  8011fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801200:	c9                   	leave  
  801201:	c3                   	ret    

00801202 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  801202:	55                   	push   %ebp
  801203:	89 e5                	mov    %esp,%ebp
  801205:	ba 60 50 80 00       	mov    $0x805060,%edx
  int i;
  uintptr_t va = FILEVA;
  80120a:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx

  for (i = 0; i < MAXOPEN; i++) {
  80120f:	b8 00 00 00 00       	mov    $0x0,%eax
    opentab[i].o_fileid = i;
  801214:	89 02                	mov    %eax,(%edx)
    opentab[i].o_fd = (struct Fd*)va;
  801216:	89 4a 0c             	mov    %ecx,0xc(%edx)
    va += PGSIZE;
  801219:	81 c1 00 10 00 00    	add    $0x1000,%ecx
serve_init(void)
{
  int i;
  uintptr_t va = FILEVA;

  for (i = 0; i < MAXOPEN; i++) {
  80121f:	83 c0 01             	add    $0x1,%eax
  801222:	83 c2 10             	add    $0x10,%edx
  801225:	3d 00 04 00 00       	cmp    $0x400,%eax
  80122a:	75 e8                	jne    801214 <serve_init+0x12>
    opentab[i].o_fileid = i;
    opentab[i].o_fd = (struct Fd*)va;
    va += PGSIZE;
  }
}
  80122c:	5d                   	pop    %ebp
  80122d:	c3                   	ret    

0080122e <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
  801231:	56                   	push   %esi
  801232:	53                   	push   %ebx
  801233:	83 ec 10             	sub    $0x10,%esp
  801236:	8b 75 08             	mov    0x8(%ebp),%esi
  int i, r;

  // Find an available open-file table entry
  for (i = 0; i < MAXOPEN; i++) {
  801239:	bb 00 00 00 00       	mov    $0x0,%ebx
  80123e:	89 d8                	mov    %ebx,%eax
  801240:	c1 e0 04             	shl    $0x4,%eax
    switch (pageref(opentab[i].o_fd)) {
  801243:	8b 80 6c 50 80 00    	mov    0x80506c(%eax),%eax
  801249:	89 04 24             	mov    %eax,(%esp)
  80124c:	e8 02 22 00 00       	call   803453 <pageref>
  801251:	85 c0                	test   %eax,%eax
  801253:	74 0d                	je     801262 <openfile_alloc+0x34>
  801255:	83 f8 01             	cmp    $0x1,%eax
  801258:	74 31                	je     80128b <openfile_alloc+0x5d>
  80125a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801260:	eb 62                	jmp    8012c4 <openfile_alloc+0x96>
    case 0:
      if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  801262:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801269:	00 
  80126a:	89 d8                	mov    %ebx,%eax
  80126c:	c1 e0 04             	shl    $0x4,%eax
  80126f:	8b 80 6c 50 80 00    	mov    0x80506c(%eax),%eax
  801275:	89 44 24 04          	mov    %eax,0x4(%esp)
  801279:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801280:	e8 5e 15 00 00       	call   8027e3 <sys_page_alloc>
  801285:	89 c2                	mov    %eax,%edx
  801287:	85 d2                	test   %edx,%edx
  801289:	78 4d                	js     8012d8 <openfile_alloc+0xaa>
        return r;
    /* fall through */
    case 1:
      opentab[i].o_fileid += MAXOPEN;
  80128b:	c1 e3 04             	shl    $0x4,%ebx
  80128e:	8d 83 60 50 80 00    	lea    0x805060(%ebx),%eax
  801294:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  80129b:	04 00 00 
      *o = &opentab[i];
  80129e:	89 06                	mov    %eax,(%esi)
      memset(opentab[i].o_fd, 0, PGSIZE);
  8012a0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8012a7:	00 
  8012a8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8012af:	00 
  8012b0:	8b 83 6c 50 80 00    	mov    0x80506c(%ebx),%eax
  8012b6:	89 04 24             	mov    %eax,(%esp)
  8012b9:	e8 59 12 00 00       	call   802517 <memset>
      return (*o)->o_fileid;
  8012be:	8b 06                	mov    (%esi),%eax
  8012c0:	8b 00                	mov    (%eax),%eax
  8012c2:	eb 14                	jmp    8012d8 <openfile_alloc+0xaa>
openfile_alloc(struct OpenFile **o)
{
  int i, r;

  // Find an available open-file table entry
  for (i = 0; i < MAXOPEN; i++) {
  8012c4:	83 c3 01             	add    $0x1,%ebx
  8012c7:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  8012cd:	0f 85 6b ff ff ff    	jne    80123e <openfile_alloc+0x10>
      *o = &opentab[i];
      memset(opentab[i].o_fd, 0, PGSIZE);
      return (*o)->o_fileid;
    }
  }
  return -E_MAX_OPEN;
  8012d3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012d8:	83 c4 10             	add    $0x10,%esp
  8012db:	5b                   	pop    %ebx
  8012dc:	5e                   	pop    %esi
  8012dd:	5d                   	pop    %ebp
  8012de:	c3                   	ret    

008012df <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  8012df:	55                   	push   %ebp
  8012e0:	89 e5                	mov    %esp,%ebp
  8012e2:	57                   	push   %edi
  8012e3:	56                   	push   %esi
  8012e4:	53                   	push   %ebx
  8012e5:	83 ec 1c             	sub    $0x1c,%esp
  8012e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct OpenFile *o;

  o = &opentab[fileid % MAXOPEN];
  8012eb:	89 de                	mov    %ebx,%esi
  8012ed:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8012f3:	c1 e6 04             	shl    $0x4,%esi
  8012f6:	8d be 60 50 80 00    	lea    0x805060(%esi),%edi
  if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  8012fc:	8b 86 6c 50 80 00    	mov    0x80506c(%esi),%eax
  801302:	89 04 24             	mov    %eax,(%esp)
  801305:	e8 49 21 00 00       	call   803453 <pageref>
  80130a:	83 f8 01             	cmp    $0x1,%eax
  80130d:	7e 14                	jle    801323 <openfile_lookup+0x44>
  80130f:	39 9e 60 50 80 00    	cmp    %ebx,0x805060(%esi)
  801315:	75 13                	jne    80132a <openfile_lookup+0x4b>
    return -E_INVAL;
  *po = o;
  801317:	8b 45 10             	mov    0x10(%ebp),%eax
  80131a:	89 38                	mov    %edi,(%eax)
  return 0;
  80131c:	b8 00 00 00 00       	mov    $0x0,%eax
  801321:	eb 0c                	jmp    80132f <openfile_lookup+0x50>
{
  struct OpenFile *o;

  o = &opentab[fileid % MAXOPEN];
  if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
    return -E_INVAL;
  801323:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801328:	eb 05                	jmp    80132f <openfile_lookup+0x50>
  80132a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  *po = o;
  return 0;
}
  80132f:	83 c4 1c             	add    $0x1c,%esp
  801332:	5b                   	pop    %ebx
  801333:	5e                   	pop    %esi
  801334:	5f                   	pop    %edi
  801335:	5d                   	pop    %ebp
  801336:	c3                   	ret    

00801337 <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  801337:	55                   	push   %ebp
  801338:	89 e5                	mov    %esp,%ebp
  80133a:	53                   	push   %ebx
  80133b:	83 ec 24             	sub    $0x24,%esp
  80133e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  // Every file system IPC call has the same general structure.
  // Here's how it goes.

  // First, use openfile_lookup to find the relevant open file.
  // On failure, return the error code to the client with ipc_send.
  if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801341:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801344:	89 44 24 08          	mov    %eax,0x8(%esp)
  801348:	8b 03                	mov    (%ebx),%eax
  80134a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80134e:	8b 45 08             	mov    0x8(%ebp),%eax
  801351:	89 04 24             	mov    %eax,(%esp)
  801354:	e8 86 ff ff ff       	call   8012df <openfile_lookup>
  801359:	89 c2                	mov    %eax,%edx
  80135b:	85 d2                	test   %edx,%edx
  80135d:	78 15                	js     801374 <serve_set_size+0x3d>
    return r;

  // Second, call the relevant file system function (from fs/fs.c).
  // On failure, return the error code to the client.
  return file_set_size(o->o_file, req->req_size);
  80135f:	8b 43 04             	mov    0x4(%ebx),%eax
  801362:	89 44 24 04          	mov    %eax,0x4(%esp)
  801366:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801369:	8b 40 04             	mov    0x4(%eax),%eax
  80136c:	89 04 24             	mov    %eax,(%esp)
  80136f:	e8 cd fa ff ff       	call   800e41 <file_set_size>
}
  801374:	83 c4 24             	add    $0x24,%esp
  801377:	5b                   	pop    %ebx
  801378:	5d                   	pop    %ebp
  801379:	c3                   	ret    

0080137a <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  80137a:	55                   	push   %ebp
  80137b:	89 e5                	mov    %esp,%ebp
  80137d:	56                   	push   %esi
  80137e:	53                   	push   %ebx
  80137f:	83 ec 20             	sub    $0x20,%esp
  801382:	8b 5d 0c             	mov    0xc(%ebp),%ebx

  // Lab 5: Your code here:
  int r;
  struct OpenFile *o;

  if ((r = openfile_lookup(envid, ipc->read.req_fileid, &o)) < 0)
  801385:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801388:	89 44 24 08          	mov    %eax,0x8(%esp)
  80138c:	8b 03                	mov    (%ebx),%eax
  80138e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801392:	8b 45 08             	mov    0x8(%ebp),%eax
  801395:	89 04 24             	mov    %eax,(%esp)
  801398:	e8 42 ff ff ff       	call   8012df <openfile_lookup>
    return r;
  80139d:	89 c2                	mov    %eax,%edx

  // Lab 5: Your code here:
  int r;
  struct OpenFile *o;

  if ((r = openfile_lookup(envid, ipc->read.req_fileid, &o)) < 0)
  80139f:	85 c0                	test   %eax,%eax
  8013a1:	78 35                	js     8013d8 <serve_read+0x5e>
    return r;

  struct File *f = o->o_file;
  8013a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  struct Fd *fd = o->o_fd;
  8013a6:	8b 70 0c             	mov    0xc(%eax),%esi

  size_t count = req->req_n < PGSIZE ? req->req_n : PGSIZE;

  if ((count = file_read(f, ret->ret_buf, count, fd->fd_offset)) < 0)
  8013a9:	8b 56 04             	mov    0x4(%esi),%edx
  8013ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
    return r;

  struct File *f = o->o_file;
  struct Fd *fd = o->o_fd;

  size_t count = req->req_n < PGSIZE ? req->req_n : PGSIZE;
  8013b0:	81 7b 04 00 10 00 00 	cmpl   $0x1000,0x4(%ebx)
  8013b7:	ba 00 10 00 00       	mov    $0x1000,%edx
  8013bc:	0f 46 53 04          	cmovbe 0x4(%ebx),%edx

  if ((count = file_read(f, ret->ret_buf, count, fd->fd_offset)) < 0)
  8013c0:	89 54 24 08          	mov    %edx,0x8(%esp)
  8013c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013c8:	8b 40 04             	mov    0x4(%eax),%eax
  8013cb:	89 04 24             	mov    %eax,(%esp)
  8013ce:	e8 be f9 ff ff       	call   800d91 <file_read>
  8013d3:	89 c2                	mov    %eax,%edx
    return count;

  fd->fd_offset += count;
  8013d5:	01 46 04             	add    %eax,0x4(%esi)

  return count;
}
  8013d8:	89 d0                	mov    %edx,%eax
  8013da:	83 c4 20             	add    $0x20,%esp
  8013dd:	5b                   	pop    %ebx
  8013de:	5e                   	pop    %esi
  8013df:	5d                   	pop    %ebp
  8013e0:	c3                   	ret    

008013e1 <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  8013e1:	55                   	push   %ebp
  8013e2:	89 e5                	mov    %esp,%ebp
  8013e4:	56                   	push   %esi
  8013e5:	53                   	push   %ebx
  8013e6:	83 ec 20             	sub    $0x20,%esp
  8013e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

  // LAB 5: Your code here.
  int r;
  struct OpenFile *o;
  if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8013ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013f3:	8b 03                	mov    (%ebx),%eax
  8013f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fc:	89 04 24             	mov    %eax,(%esp)
  8013ff:	e8 db fe ff ff       	call   8012df <openfile_lookup>
  801404:	85 c0                	test   %eax,%eax
  801406:	78 49                	js     801451 <serve_write+0x70>
    return r;

  struct File *f = o->o_file;
  801408:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80140b:	8b 42 04             	mov    0x4(%edx),%eax
  struct Fd *fd = o->o_fd;
  80140e:	8b 72 0c             	mov    0xc(%edx),%esi

  size_t count = req->req_n < PGSIZE ? req->req_n : PGSIZE;
  801411:	81 7b 04 00 10 00 00 	cmpl   $0x1000,0x4(%ebx)
  801418:	ba 00 10 00 00       	mov    $0x1000,%edx
  80141d:	0f 46 53 04          	cmovbe 0x4(%ebx),%edx

  if (fd->fd_offset + count > f->f_size)
  801421:	89 d1                	mov    %edx,%ecx
  801423:	03 4e 04             	add    0x4(%esi),%ecx
  801426:	3b 88 80 00 00 00    	cmp    0x80(%eax),%ecx
  80142c:	76 06                	jbe    801434 <serve_write+0x53>
    f->f_size = fd->fd_offset + count;
  80142e:	89 88 80 00 00 00    	mov    %ecx,0x80(%eax)

  if ((count = file_write(f, req->req_buf, count, fd->fd_offset)) < 0)
  801434:	8b 4e 04             	mov    0x4(%esi),%ecx
  801437:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80143b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80143f:	83 c3 08             	add    $0x8,%ebx
  801442:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801446:	89 04 24             	mov    %eax,(%esp)
  801449:	e8 c6 fa ff ff       	call   800f14 <file_write>
    return count;

  fd->fd_offset += count;
  80144e:	01 46 04             	add    %eax,0x4(%esi)

  return count;
}
  801451:	83 c4 20             	add    $0x20,%esp
  801454:	5b                   	pop    %ebx
  801455:	5e                   	pop    %esi
  801456:	5d                   	pop    %ebp
  801457:	c3                   	ret    

00801458 <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  801458:	55                   	push   %ebp
  801459:	89 e5                	mov    %esp,%ebp
  80145b:	53                   	push   %ebx
  80145c:	83 ec 24             	sub    $0x24,%esp
  80145f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int r;

  if (debug)
    cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

  if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801462:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801465:	89 44 24 08          	mov    %eax,0x8(%esp)
  801469:	8b 03                	mov    (%ebx),%eax
  80146b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80146f:	8b 45 08             	mov    0x8(%ebp),%eax
  801472:	89 04 24             	mov    %eax,(%esp)
  801475:	e8 65 fe ff ff       	call   8012df <openfile_lookup>
  80147a:	89 c2                	mov    %eax,%edx
  80147c:	85 d2                	test   %edx,%edx
  80147e:	78 3f                	js     8014bf <serve_stat+0x67>
    return r;

  strcpy(ret->ret_name, o->o_file->f_name);
  801480:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801483:	8b 40 04             	mov    0x4(%eax),%eax
  801486:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148a:	89 1c 24             	mov    %ebx,(%esp)
  80148d:	e8 35 0f 00 00       	call   8023c7 <strcpy>
  ret->ret_size = o->o_file->f_size;
  801492:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801495:	8b 50 04             	mov    0x4(%eax),%edx
  801498:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  80149e:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
  ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  8014a4:	8b 40 04             	mov    0x4(%eax),%eax
  8014a7:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  8014ae:	0f 94 c0             	sete   %al
  8014b1:	0f b6 c0             	movzbl %al,%eax
  8014b4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  return 0;
  8014ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014bf:	83 c4 24             	add    $0x24,%esp
  8014c2:	5b                   	pop    %ebx
  8014c3:	5d                   	pop    %ebp
  8014c4:	c3                   	ret    

008014c5 <serve_flush>:

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  8014c5:	55                   	push   %ebp
  8014c6:	89 e5                	mov    %esp,%ebp
  8014c8:	83 ec 28             	sub    $0x28,%esp
  int r;

  if (debug)
    cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

  if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8014cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014d5:	8b 00                	mov    (%eax),%eax
  8014d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014db:	8b 45 08             	mov    0x8(%ebp),%eax
  8014de:	89 04 24             	mov    %eax,(%esp)
  8014e1:	e8 f9 fd ff ff       	call   8012df <openfile_lookup>
  8014e6:	89 c2                	mov    %eax,%edx
  8014e8:	85 d2                	test   %edx,%edx
  8014ea:	78 13                	js     8014ff <serve_flush+0x3a>
    return r;
  file_flush(o->o_file);
  8014ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ef:	8b 40 04             	mov    0x4(%eax),%eax
  8014f2:	89 04 24             	mov    %eax,(%esp)
  8014f5:	e8 ca fa ff ff       	call   800fc4 <file_flush>
  return 0;
  8014fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ff:	c9                   	leave  
  801500:	c3                   	ret    

00801501 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
           void **pg_store, int *perm_store)
{
  801501:	55                   	push   %ebp
  801502:	89 e5                	mov    %esp,%ebp
  801504:	53                   	push   %ebx
  801505:	81 ec 24 04 00 00    	sub    $0x424,%esp
  80150b:	8b 5d 0c             	mov    0xc(%ebp),%ebx

  if (debug)
    cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

  // Copy in the path, making sure it's null-terminated
  memmove(path, req->req_path, MAXPATHLEN);
  80150e:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
  801515:	00 
  801516:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80151a:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801520:	89 04 24             	mov    %eax,(%esp)
  801523:	e8 3c 10 00 00       	call   802564 <memmove>
  path[MAXPATHLEN-1] = 0;
  801528:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

  // Find an open file ID
  if ((r = openfile_alloc(&o)) < 0) {
  80152c:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  801532:	89 04 24             	mov    %eax,(%esp)
  801535:	e8 f4 fc ff ff       	call   80122e <openfile_alloc>
  80153a:	85 c0                	test   %eax,%eax
  80153c:	0f 88 f2 00 00 00    	js     801634 <serve_open+0x133>
    return r;
  }
  fileid = r;

  // Open the file
  if (req->req_omode & O_CREAT) {
  801542:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  801549:	74 34                	je     80157f <serve_open+0x7e>
    if ((r = file_create(path, &f)) < 0) {
  80154b:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801551:	89 44 24 04          	mov    %eax,0x4(%esp)
  801555:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80155b:	89 04 24             	mov    %eax,(%esp)
  80155e:	e8 f1 fa ff ff       	call   801054 <file_create>
  801563:	89 c2                	mov    %eax,%edx
  801565:	85 c0                	test   %eax,%eax
  801567:	79 36                	jns    80159f <serve_open+0x9e>
      if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  801569:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  801570:	0f 85 be 00 00 00    	jne    801634 <serve_open+0x133>
  801576:	83 fa f3             	cmp    $0xfffffff3,%edx
  801579:	0f 85 b5 00 00 00    	jne    801634 <serve_open+0x133>
        cprintf("file_create failed: %e", r);
      return r;
    }
  } else {
try_open:
    if ((r = file_open(path, &f)) < 0) {
  80157f:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801585:	89 44 24 04          	mov    %eax,0x4(%esp)
  801589:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80158f:	89 04 24             	mov    %eax,(%esp)
  801592:	e8 db f7 ff ff       	call   800d72 <file_open>
  801597:	85 c0                	test   %eax,%eax
  801599:	0f 88 95 00 00 00    	js     801634 <serve_open+0x133>
      return r;
    }
  }

  // Truncate
  if (req->req_omode & O_TRUNC) {
  80159f:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  8015a6:	74 1a                	je     8015c2 <serve_open+0xc1>
    if ((r = file_set_size(f, 0)) < 0) {
  8015a8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015af:	00 
  8015b0:	8b 85 f4 fb ff ff    	mov    -0x40c(%ebp),%eax
  8015b6:	89 04 24             	mov    %eax,(%esp)
  8015b9:	e8 83 f8 ff ff       	call   800e41 <file_set_size>
  8015be:	85 c0                	test   %eax,%eax
  8015c0:	78 72                	js     801634 <serve_open+0x133>
      if (debug)
        cprintf("file_set_size failed: %e", r);
      return r;
    }
  }
  if ((r = file_open(path, &f)) < 0) {
  8015c2:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8015c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015cc:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8015d2:	89 04 24             	mov    %eax,(%esp)
  8015d5:	e8 98 f7 ff ff       	call   800d72 <file_open>
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	78 56                	js     801634 <serve_open+0x133>
      cprintf("file_open failed: %e", r);
    return r;
  }

  // Save the file pointer
  o->o_file = f;
  8015de:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8015e4:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  8015ea:	89 50 04             	mov    %edx,0x4(%eax)

  // Fill out the Fd structure
  o->o_fd->fd_file.id = o->o_fileid;
  8015ed:	8b 50 0c             	mov    0xc(%eax),%edx
  8015f0:	8b 08                	mov    (%eax),%ecx
  8015f2:	89 4a 0c             	mov    %ecx,0xc(%edx)
  o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  8015f5:	8b 50 0c             	mov    0xc(%eax),%edx
  8015f8:	8b 8b 00 04 00 00    	mov    0x400(%ebx),%ecx
  8015fe:	83 e1 03             	and    $0x3,%ecx
  801601:	89 4a 08             	mov    %ecx,0x8(%edx)
  o->o_fd->fd_dev_id = devfile.dev_id;
  801604:	8b 40 0c             	mov    0xc(%eax),%eax
  801607:	8b 15 64 90 80 00    	mov    0x809064,%edx
  80160d:	89 10                	mov    %edx,(%eax)
  o->o_mode = req->req_omode;
  80160f:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801615:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  80161b:	89 50 08             	mov    %edx,0x8(%eax)
  if (debug)
    cprintf("sending success, page %08x\n", (uintptr_t)o->o_fd);

  // Share the FD page with the caller by setting *pg_store,
  // store its permission in *perm_store
  *pg_store = o->o_fd;
  80161e:	8b 50 0c             	mov    0xc(%eax),%edx
  801621:	8b 45 10             	mov    0x10(%ebp),%eax
  801624:	89 10                	mov    %edx,(%eax)
  *perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  801626:	8b 45 14             	mov    0x14(%ebp),%eax
  801629:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

  return 0;
  80162f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801634:	81 c4 24 04 00 00    	add    $0x424,%esp
  80163a:	5b                   	pop    %ebx
  80163b:	5d                   	pop    %ebp
  80163c:	c3                   	ret    

0080163d <serve>:
};
#define NHANDLERS (sizeof(handlers)/sizeof(handlers[0]))

void
serve(void)
{
  80163d:	55                   	push   %ebp
  80163e:	89 e5                	mov    %esp,%ebp
  801640:	56                   	push   %esi
  801641:	53                   	push   %ebx
  801642:	83 ec 20             	sub    $0x20,%esp
  int perm, r;
  void *pg;

  while (1) {
    perm = 0;
    req = ipc_recv((int32_t*)&whom, fsreq, &perm);
  801645:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  801648:	8d 75 f4             	lea    -0xc(%ebp),%esi
  uint32_t req, whom;
  int perm, r;
  void *pg;

  while (1) {
    perm = 0;
  80164b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    req = ipc_recv((int32_t*)&whom, fsreq, &perm);
  801652:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801656:	a1 44 50 80 00       	mov    0x805044,%eax
  80165b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165f:	89 34 24             	mov    %esi,(%esp)
  801662:	e8 93 14 00 00       	call   802afa <ipc_recv>
    if (debug)
      cprintf("fs req %d from %08x [page %08x: %s]\n",
              req, whom, uvpt[PGNUM(fsreq)], fsreq);

    // All requests must contain an argument page
    if (!(perm & PTE_P)) {
  801667:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  80166b:	75 15                	jne    801682 <serve+0x45>
      cprintf("Invalid request from %08x: no argument page\n",
  80166d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801670:	89 44 24 04          	mov    %eax,0x4(%esp)
  801674:	c7 04 24 74 3f 80 00 	movl   $0x803f74,(%esp)
  80167b:	e8 24 07 00 00       	call   801da4 <cprintf>
              whom);
      continue;                   // just leave it hanging...
  801680:	eb c9                	jmp    80164b <serve+0xe>
    }

    pg = NULL;
  801682:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    if (req == FSREQ_OPEN)
  801689:	83 f8 01             	cmp    $0x1,%eax
  80168c:	75 21                	jne    8016af <serve+0x72>
      r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  80168e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801692:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801695:	89 44 24 08          	mov    %eax,0x8(%esp)
  801699:	a1 44 50 80 00       	mov    0x805044,%eax
  80169e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a5:	89 04 24             	mov    %eax,(%esp)
  8016a8:	e8 54 fe ff ff       	call   801501 <serve_open>
  8016ad:	eb 3f                	jmp    8016ee <serve+0xb1>
    else if (req < NHANDLERS && handlers[req])
  8016af:	83 f8 08             	cmp    $0x8,%eax
  8016b2:	77 1e                	ja     8016d2 <serve+0x95>
  8016b4:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  8016bb:	85 d2                	test   %edx,%edx
  8016bd:	74 13                	je     8016d2 <serve+0x95>
      r = handlers[req](whom, fsreq);
  8016bf:	a1 44 50 80 00       	mov    0x805044,%eax
  8016c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016cb:	89 04 24             	mov    %eax,(%esp)
  8016ce:	ff d2                	call   *%edx
  8016d0:	eb 1c                	jmp    8016ee <serve+0xb1>
    else {
      cprintf("Invalid request code %d from %08x\n", req, whom);
  8016d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016d5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8016d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016dd:	c7 04 24 a4 3f 80 00 	movl   $0x803fa4,(%esp)
  8016e4:	e8 bb 06 00 00       	call   801da4 <cprintf>
      r = -E_INVAL;
  8016e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
    }
    ipc_send(whom, r, pg, perm);
  8016ee:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016f1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8016f5:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8016f8:	89 54 24 08          	mov    %edx,0x8(%esp)
  8016fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801700:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801703:	89 04 24             	mov    %eax,(%esp)
  801706:	e8 75 14 00 00       	call   802b80 <ipc_send>
    sys_page_unmap(0, fsreq);
  80170b:	a1 44 50 80 00       	mov    0x805044,%eax
  801710:	89 44 24 04          	mov    %eax,0x4(%esp)
  801714:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80171b:	e8 6a 11 00 00       	call   80288a <sys_page_unmap>
  801720:	e9 26 ff ff ff       	jmp    80164b <serve+0xe>

00801725 <umain>:
  }
}

void
umain(int argc, char **argv)
{
  801725:	55                   	push   %ebp
  801726:	89 e5                	mov    %esp,%ebp
  801728:	83 ec 18             	sub    $0x18,%esp
  static_assert(sizeof(struct File) == 256);
  binaryname = "fs";
  80172b:	c7 05 60 90 80 00 c7 	movl   $0x803fc7,0x809060
  801732:	3f 80 00 
  cprintf("FS is running\n");
  801735:	c7 04 24 ca 3f 80 00 	movl   $0x803fca,(%esp)
  80173c:	e8 63 06 00 00       	call   801da4 <cprintf>
}

static __inline void
outw(int port, uint16_t data)
{
  __asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
  801741:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  801746:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  80174b:	66 ef                	out    %ax,(%dx)

  // Check that we are able to do I/O
  outw(0x8A00, 0x8A00);
  cprintf("FS can do I/O\n");
  80174d:	c7 04 24 d9 3f 80 00 	movl   $0x803fd9,(%esp)
  801754:	e8 4b 06 00 00       	call   801da4 <cprintf>

  serve_init();
  801759:	e8 a4 fa ff ff       	call   801202 <serve_init>
  fs_init();
  80175e:	e8 23 f3 ff ff       	call   800a86 <fs_init>
  fs_test();
  801763:	e8 05 00 00 00       	call   80176d <fs_test>
  serve();
  801768:	e8 d0 fe ff ff       	call   80163d <serve>

0080176d <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  80176d:	55                   	push   %ebp
  80176e:	89 e5                	mov    %esp,%ebp
  801770:	53                   	push   %ebx
  801771:	83 ec 24             	sub    $0x24,%esp
  int r;
  char *blk;
  uint32_t *bits;

  // back up bitmap
  if ((r = sys_page_alloc(0, (void*)PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  801774:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80177b:	00 
  80177c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  801783:	00 
  801784:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80178b:	e8 53 10 00 00       	call   8027e3 <sys_page_alloc>
  801790:	85 c0                	test   %eax,%eax
  801792:	79 20                	jns    8017b4 <fs_test+0x47>
    panic("sys_page_alloc: %e", r);
  801794:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801798:	c7 44 24 08 78 3d 80 	movl   $0x803d78,0x8(%esp)
  80179f:	00 
  8017a0:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  8017a7:	00 
  8017a8:	c7 04 24 e8 3f 80 00 	movl   $0x803fe8,(%esp)
  8017af:	e8 f7 04 00 00       	call   801cab <_panic>
  bits = (uint32_t*)PGSIZE;
  memmove(bits, bitmap, PGSIZE);
  8017b4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8017bb:	00 
  8017bc:	a1 04 a0 80 00       	mov    0x80a004,%eax
  8017c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c5:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  8017cc:	e8 93 0d 00 00       	call   802564 <memmove>
  // allocate block
  if ((r = alloc_block()) < 0)
  8017d1:	e8 b9 f0 ff ff       	call   80088f <alloc_block>
  8017d6:	85 c0                	test   %eax,%eax
  8017d8:	79 20                	jns    8017fa <fs_test+0x8d>
    panic("alloc_block: %e", r);
  8017da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017de:	c7 44 24 08 f2 3f 80 	movl   $0x803ff2,0x8(%esp)
  8017e5:	00 
  8017e6:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  8017ed:	00 
  8017ee:	c7 04 24 e8 3f 80 00 	movl   $0x803fe8,(%esp)
  8017f5:	e8 b1 04 00 00       	call   801cab <_panic>
  // check that block was free
  assert(bits[r/32] & (1 << (r%32)));
  8017fa:	8d 58 1f             	lea    0x1f(%eax),%ebx
  8017fd:	85 c0                	test   %eax,%eax
  8017ff:	0f 49 d8             	cmovns %eax,%ebx
  801802:	c1 fb 05             	sar    $0x5,%ebx
  801805:	99                   	cltd   
  801806:	c1 ea 1b             	shr    $0x1b,%edx
  801809:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  80180c:	83 e1 1f             	and    $0x1f,%ecx
  80180f:	29 d1                	sub    %edx,%ecx
  801811:	ba 01 00 00 00       	mov    $0x1,%edx
  801816:	d3 e2                	shl    %cl,%edx
  801818:	85 14 9d 00 10 00 00 	test   %edx,0x1000(,%ebx,4)
  80181f:	75 24                	jne    801845 <fs_test+0xd8>
  801821:	c7 44 24 0c 02 40 80 	movl   $0x804002,0xc(%esp)
  801828:	00 
  801829:	c7 44 24 08 9d 3c 80 	movl   $0x803c9d,0x8(%esp)
  801830:	00 
  801831:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  801838:	00 
  801839:	c7 04 24 e8 3f 80 00 	movl   $0x803fe8,(%esp)
  801840:	e8 66 04 00 00       	call   801cab <_panic>
  // and is not free any more
  assert(!(bitmap[r/32] & (1 << (r%32))));
  801845:	a1 04 a0 80 00       	mov    0x80a004,%eax
  80184a:	85 14 98             	test   %edx,(%eax,%ebx,4)
  80184d:	74 24                	je     801873 <fs_test+0x106>
  80184f:	c7 44 24 0c 7c 41 80 	movl   $0x80417c,0xc(%esp)
  801856:	00 
  801857:	c7 44 24 08 9d 3c 80 	movl   $0x803c9d,0x8(%esp)
  80185e:	00 
  80185f:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
  801866:	00 
  801867:	c7 04 24 e8 3f 80 00 	movl   $0x803fe8,(%esp)
  80186e:	e8 38 04 00 00       	call   801cab <_panic>
  cprintf("alloc_block is good\n");
  801873:	c7 04 24 1d 40 80 00 	movl   $0x80401d,(%esp)
  80187a:	e8 25 05 00 00       	call   801da4 <cprintf>

  if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  80187f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801882:	89 44 24 04          	mov    %eax,0x4(%esp)
  801886:	c7 04 24 32 40 80 00 	movl   $0x804032,(%esp)
  80188d:	e8 e0 f4 ff ff       	call   800d72 <file_open>
  801892:	85 c0                	test   %eax,%eax
  801894:	79 25                	jns    8018bb <fs_test+0x14e>
  801896:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801899:	74 40                	je     8018db <fs_test+0x16e>
    panic("file_open /not-found: %e", r);
  80189b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80189f:	c7 44 24 08 3d 40 80 	movl   $0x80403d,0x8(%esp)
  8018a6:	00 
  8018a7:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  8018ae:	00 
  8018af:	c7 04 24 e8 3f 80 00 	movl   $0x803fe8,(%esp)
  8018b6:	e8 f0 03 00 00       	call   801cab <_panic>
  else if (r == 0)
  8018bb:	85 c0                	test   %eax,%eax
  8018bd:	75 1c                	jne    8018db <fs_test+0x16e>
    panic("file_open /not-found succeeded!");
  8018bf:	c7 44 24 08 9c 41 80 	movl   $0x80419c,0x8(%esp)
  8018c6:	00 
  8018c7:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8018ce:	00 
  8018cf:	c7 04 24 e8 3f 80 00 	movl   $0x803fe8,(%esp)
  8018d6:	e8 d0 03 00 00       	call   801cab <_panic>
  if ((r = file_open("/newmotd", &f)) < 0)
  8018db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e2:	c7 04 24 56 40 80 00 	movl   $0x804056,(%esp)
  8018e9:	e8 84 f4 ff ff       	call   800d72 <file_open>
  8018ee:	85 c0                	test   %eax,%eax
  8018f0:	79 20                	jns    801912 <fs_test+0x1a5>
    panic("file_open /newmotd: %e", r);
  8018f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018f6:	c7 44 24 08 5f 40 80 	movl   $0x80405f,0x8(%esp)
  8018fd:	00 
  8018fe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801905:	00 
  801906:	c7 04 24 e8 3f 80 00 	movl   $0x803fe8,(%esp)
  80190d:	e8 99 03 00 00       	call   801cab <_panic>
  cprintf("file_open is good\n");
  801912:	c7 04 24 76 40 80 00 	movl   $0x804076,(%esp)
  801919:	e8 86 04 00 00       	call   801da4 <cprintf>

  if ((r = file_get_block(f, 0, &blk)) < 0)
  80191e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801921:	89 44 24 08          	mov    %eax,0x8(%esp)
  801925:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80192c:	00 
  80192d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801930:	89 04 24             	mov    %eax,(%esp)
  801933:	e8 aa f1 ff ff       	call   800ae2 <file_get_block>
  801938:	85 c0                	test   %eax,%eax
  80193a:	79 20                	jns    80195c <fs_test+0x1ef>
    panic("file_get_block: %e", r);
  80193c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801940:	c7 44 24 08 89 40 80 	movl   $0x804089,0x8(%esp)
  801947:	00 
  801948:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80194f:	00 
  801950:	c7 04 24 e8 3f 80 00 	movl   $0x803fe8,(%esp)
  801957:	e8 4f 03 00 00       	call   801cab <_panic>
  if (strcmp(blk, msg) != 0)
  80195c:	c7 44 24 04 bc 41 80 	movl   $0x8041bc,0x4(%esp)
  801963:	00 
  801964:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801967:	89 04 24             	mov    %eax,(%esp)
  80196a:	e8 0d 0b 00 00       	call   80247c <strcmp>
  80196f:	85 c0                	test   %eax,%eax
  801971:	74 1c                	je     80198f <fs_test+0x222>
    panic("file_get_block returned wrong data");
  801973:	c7 44 24 08 e4 41 80 	movl   $0x8041e4,0x8(%esp)
  80197a:	00 
  80197b:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  801982:	00 
  801983:	c7 04 24 e8 3f 80 00 	movl   $0x803fe8,(%esp)
  80198a:	e8 1c 03 00 00       	call   801cab <_panic>
  cprintf("file_get_block is good\n");
  80198f:	c7 04 24 9c 40 80 00 	movl   $0x80409c,(%esp)
  801996:	e8 09 04 00 00       	call   801da4 <cprintf>

  *(volatile char*)blk = *(volatile char*)blk;
  80199b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80199e:	0f b6 10             	movzbl (%eax),%edx
  8019a1:	88 10                	mov    %dl,(%eax)
  assert((uvpt[PGNUM(blk)] & PTE_D));
  8019a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019a6:	c1 e8 0c             	shr    $0xc,%eax
  8019a9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019b0:	a8 40                	test   $0x40,%al
  8019b2:	75 24                	jne    8019d8 <fs_test+0x26b>
  8019b4:	c7 44 24 0c b5 40 80 	movl   $0x8040b5,0xc(%esp)
  8019bb:	00 
  8019bc:	c7 44 24 08 9d 3c 80 	movl   $0x803c9d,0x8(%esp)
  8019c3:	00 
  8019c4:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8019cb:	00 
  8019cc:	c7 04 24 e8 3f 80 00 	movl   $0x803fe8,(%esp)
  8019d3:	e8 d3 02 00 00       	call   801cab <_panic>
  file_flush(f);
  8019d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019db:	89 04 24             	mov    %eax,(%esp)
  8019de:	e8 e1 f5 ff ff       	call   800fc4 <file_flush>
  assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8019e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019e6:	c1 e8 0c             	shr    $0xc,%eax
  8019e9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019f0:	a8 40                	test   $0x40,%al
  8019f2:	74 24                	je     801a18 <fs_test+0x2ab>
  8019f4:	c7 44 24 0c b4 40 80 	movl   $0x8040b4,0xc(%esp)
  8019fb:	00 
  8019fc:	c7 44 24 08 9d 3c 80 	movl   $0x803c9d,0x8(%esp)
  801a03:	00 
  801a04:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  801a0b:	00 
  801a0c:	c7 04 24 e8 3f 80 00 	movl   $0x803fe8,(%esp)
  801a13:	e8 93 02 00 00       	call   801cab <_panic>
  cprintf("file_flush is good\n");
  801a18:	c7 04 24 d0 40 80 00 	movl   $0x8040d0,(%esp)
  801a1f:	e8 80 03 00 00       	call   801da4 <cprintf>

  if ((r = file_set_size(f, 0)) < 0)
  801a24:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a2b:	00 
  801a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a2f:	89 04 24             	mov    %eax,(%esp)
  801a32:	e8 0a f4 ff ff       	call   800e41 <file_set_size>
  801a37:	85 c0                	test   %eax,%eax
  801a39:	79 20                	jns    801a5b <fs_test+0x2ee>
    panic("file_set_size: %e", r);
  801a3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a3f:	c7 44 24 08 e4 40 80 	movl   $0x8040e4,0x8(%esp)
  801a46:	00 
  801a47:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  801a4e:	00 
  801a4f:	c7 04 24 e8 3f 80 00 	movl   $0x803fe8,(%esp)
  801a56:	e8 50 02 00 00       	call   801cab <_panic>
  assert(f->f_direct[0] == 0);
  801a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a5e:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  801a65:	74 24                	je     801a8b <fs_test+0x31e>
  801a67:	c7 44 24 0c f6 40 80 	movl   $0x8040f6,0xc(%esp)
  801a6e:	00 
  801a6f:	c7 44 24 08 9d 3c 80 	movl   $0x803c9d,0x8(%esp)
  801a76:	00 
  801a77:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  801a7e:	00 
  801a7f:	c7 04 24 e8 3f 80 00 	movl   $0x803fe8,(%esp)
  801a86:	e8 20 02 00 00       	call   801cab <_panic>
  assert(!(uvpt[PGNUM(f)] & PTE_D));
  801a8b:	c1 e8 0c             	shr    $0xc,%eax
  801a8e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a95:	a8 40                	test   $0x40,%al
  801a97:	74 24                	je     801abd <fs_test+0x350>
  801a99:	c7 44 24 0c 0a 41 80 	movl   $0x80410a,0xc(%esp)
  801aa0:	00 
  801aa1:	c7 44 24 08 9d 3c 80 	movl   $0x803c9d,0x8(%esp)
  801aa8:	00 
  801aa9:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  801ab0:	00 
  801ab1:	c7 04 24 e8 3f 80 00 	movl   $0x803fe8,(%esp)
  801ab8:	e8 ee 01 00 00       	call   801cab <_panic>
  cprintf("file_truncate is good\n");
  801abd:	c7 04 24 24 41 80 00 	movl   $0x804124,(%esp)
  801ac4:	e8 db 02 00 00       	call   801da4 <cprintf>

  if ((r = file_set_size(f, strlen(msg))) < 0)
  801ac9:	c7 04 24 bc 41 80 00 	movl   $0x8041bc,(%esp)
  801ad0:	e8 bb 08 00 00       	call   802390 <strlen>
  801ad5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801adc:	89 04 24             	mov    %eax,(%esp)
  801adf:	e8 5d f3 ff ff       	call   800e41 <file_set_size>
  801ae4:	85 c0                	test   %eax,%eax
  801ae6:	79 20                	jns    801b08 <fs_test+0x39b>
    panic("file_set_size 2: %e", r);
  801ae8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801aec:	c7 44 24 08 3b 41 80 	movl   $0x80413b,0x8(%esp)
  801af3:	00 
  801af4:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  801afb:	00 
  801afc:	c7 04 24 e8 3f 80 00 	movl   $0x803fe8,(%esp)
  801b03:	e8 a3 01 00 00       	call   801cab <_panic>
  assert(!(uvpt[PGNUM(f)] & PTE_D));
  801b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b0b:	89 c2                	mov    %eax,%edx
  801b0d:	c1 ea 0c             	shr    $0xc,%edx
  801b10:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801b17:	f6 c2 40             	test   $0x40,%dl
  801b1a:	74 24                	je     801b40 <fs_test+0x3d3>
  801b1c:	c7 44 24 0c 0a 41 80 	movl   $0x80410a,0xc(%esp)
  801b23:	00 
  801b24:	c7 44 24 08 9d 3c 80 	movl   $0x803c9d,0x8(%esp)
  801b2b:	00 
  801b2c:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  801b33:	00 
  801b34:	c7 04 24 e8 3f 80 00 	movl   $0x803fe8,(%esp)
  801b3b:	e8 6b 01 00 00       	call   801cab <_panic>
  if ((r = file_get_block(f, 0, &blk)) < 0)
  801b40:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801b43:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b47:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b4e:	00 
  801b4f:	89 04 24             	mov    %eax,(%esp)
  801b52:	e8 8b ef ff ff       	call   800ae2 <file_get_block>
  801b57:	85 c0                	test   %eax,%eax
  801b59:	79 20                	jns    801b7b <fs_test+0x40e>
    panic("file_get_block 2: %e", r);
  801b5b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b5f:	c7 44 24 08 4f 41 80 	movl   $0x80414f,0x8(%esp)
  801b66:	00 
  801b67:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  801b6e:	00 
  801b6f:	c7 04 24 e8 3f 80 00 	movl   $0x803fe8,(%esp)
  801b76:	e8 30 01 00 00       	call   801cab <_panic>
  strcpy(blk, msg);
  801b7b:	c7 44 24 04 bc 41 80 	movl   $0x8041bc,0x4(%esp)
  801b82:	00 
  801b83:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b86:	89 04 24             	mov    %eax,(%esp)
  801b89:	e8 39 08 00 00       	call   8023c7 <strcpy>
  assert((uvpt[PGNUM(blk)] & PTE_D));
  801b8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b91:	c1 e8 0c             	shr    $0xc,%eax
  801b94:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b9b:	a8 40                	test   $0x40,%al
  801b9d:	75 24                	jne    801bc3 <fs_test+0x456>
  801b9f:	c7 44 24 0c b5 40 80 	movl   $0x8040b5,0xc(%esp)
  801ba6:	00 
  801ba7:	c7 44 24 08 9d 3c 80 	movl   $0x803c9d,0x8(%esp)
  801bae:	00 
  801baf:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801bb6:	00 
  801bb7:	c7 04 24 e8 3f 80 00 	movl   $0x803fe8,(%esp)
  801bbe:	e8 e8 00 00 00       	call   801cab <_panic>
  file_flush(f);
  801bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc6:	89 04 24             	mov    %eax,(%esp)
  801bc9:	e8 f6 f3 ff ff       	call   800fc4 <file_flush>
  assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801bce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bd1:	c1 e8 0c             	shr    $0xc,%eax
  801bd4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801bdb:	a8 40                	test   $0x40,%al
  801bdd:	74 24                	je     801c03 <fs_test+0x496>
  801bdf:	c7 44 24 0c b4 40 80 	movl   $0x8040b4,0xc(%esp)
  801be6:	00 
  801be7:	c7 44 24 08 9d 3c 80 	movl   $0x803c9d,0x8(%esp)
  801bee:	00 
  801bef:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801bf6:	00 
  801bf7:	c7 04 24 e8 3f 80 00 	movl   $0x803fe8,(%esp)
  801bfe:	e8 a8 00 00 00       	call   801cab <_panic>
  assert(!(uvpt[PGNUM(f)] & PTE_D));
  801c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c06:	c1 e8 0c             	shr    $0xc,%eax
  801c09:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801c10:	a8 40                	test   $0x40,%al
  801c12:	74 24                	je     801c38 <fs_test+0x4cb>
  801c14:	c7 44 24 0c 0a 41 80 	movl   $0x80410a,0xc(%esp)
  801c1b:	00 
  801c1c:	c7 44 24 08 9d 3c 80 	movl   $0x803c9d,0x8(%esp)
  801c23:	00 
  801c24:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801c2b:	00 
  801c2c:	c7 04 24 e8 3f 80 00 	movl   $0x803fe8,(%esp)
  801c33:	e8 73 00 00 00       	call   801cab <_panic>
  cprintf("file rewrite is good\n");
  801c38:	c7 04 24 64 41 80 00 	movl   $0x804164,(%esp)
  801c3f:	e8 60 01 00 00       	call   801da4 <cprintf>
}
  801c44:	83 c4 24             	add    $0x24,%esp
  801c47:	5b                   	pop    %ebx
  801c48:	5d                   	pop    %ebp
  801c49:	c3                   	ret    

00801c4a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801c4a:	55                   	push   %ebp
  801c4b:	89 e5                	mov    %esp,%ebp
  801c4d:	56                   	push   %esi
  801c4e:	53                   	push   %ebx
  801c4f:	83 ec 10             	sub    $0x10,%esp
  801c52:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801c55:	8b 75 0c             	mov    0xc(%ebp),%esi
  // set thisenv to point at our Env structure in envs[].
  // LAB 3: Your code here.
  thisenv = envs + ENVX(sys_getenvid());
  801c58:	e8 48 0b 00 00       	call   8027a5 <sys_getenvid>
  801c5d:	25 ff 03 00 00       	and    $0x3ff,%eax
  801c62:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c65:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c6a:	a3 0c a0 80 00       	mov    %eax,0x80a00c

  // save the name of the program so that panic() can use it
  if (argc > 0)
  801c6f:	85 db                	test   %ebx,%ebx
  801c71:	7e 07                	jle    801c7a <libmain+0x30>
    binaryname = argv[0];
  801c73:	8b 06                	mov    (%esi),%eax
  801c75:	a3 60 90 80 00       	mov    %eax,0x809060

  // call user main routine
  umain(argc, argv);
  801c7a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c7e:	89 1c 24             	mov    %ebx,(%esp)
  801c81:	e8 9f fa ff ff       	call   801725 <umain>

  // exit gracefully
  exit();
  801c86:	e8 07 00 00 00       	call   801c92 <exit>
}
  801c8b:	83 c4 10             	add    $0x10,%esp
  801c8e:	5b                   	pop    %ebx
  801c8f:	5e                   	pop    %esi
  801c90:	5d                   	pop    %ebp
  801c91:	c3                   	ret    

00801c92 <exit>:
#include <inc/lib.h>

void
exit(void)
{
  801c92:	55                   	push   %ebp
  801c93:	89 e5                	mov    %esp,%ebp
  801c95:	83 ec 18             	sub    $0x18,%esp
  close_all();
  801c98:	e8 68 11 00 00       	call   802e05 <close_all>
  sys_env_destroy(0);
  801c9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ca4:	e8 aa 0a 00 00       	call   802753 <sys_env_destroy>
}
  801ca9:	c9                   	leave  
  801caa:	c3                   	ret    

00801cab <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801cab:	55                   	push   %ebp
  801cac:	89 e5                	mov    %esp,%ebp
  801cae:	56                   	push   %esi
  801caf:	53                   	push   %ebx
  801cb0:	83 ec 20             	sub    $0x20,%esp
  va_list ap;

  va_start(ap, fmt);
  801cb3:	8d 5d 14             	lea    0x14(%ebp),%ebx

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  801cb6:	8b 35 60 90 80 00    	mov    0x809060,%esi
  801cbc:	e8 e4 0a 00 00       	call   8027a5 <sys_getenvid>
  801cc1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cc4:	89 54 24 10          	mov    %edx,0x10(%esp)
  801cc8:	8b 55 08             	mov    0x8(%ebp),%edx
  801ccb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801ccf:	89 74 24 08          	mov    %esi,0x8(%esp)
  801cd3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cd7:	c7 04 24 14 42 80 00 	movl   $0x804214,(%esp)
  801cde:	e8 c1 00 00 00       	call   801da4 <cprintf>
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  801ce3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ce7:	8b 45 10             	mov    0x10(%ebp),%eax
  801cea:	89 04 24             	mov    %eax,(%esp)
  801ced:	e8 51 00 00 00       	call   801d43 <vcprintf>
  cprintf("\n");
  801cf2:	c7 04 24 fc 3d 80 00 	movl   $0x803dfc,(%esp)
  801cf9:	e8 a6 00 00 00       	call   801da4 <cprintf>

  // Cause a breakpoint exception
  while (1)
    asm volatile ("int3");
  801cfe:	cc                   	int3   
  801cff:	eb fd                	jmp    801cfe <_panic+0x53>

00801d01 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801d01:	55                   	push   %ebp
  801d02:	89 e5                	mov    %esp,%ebp
  801d04:	53                   	push   %ebx
  801d05:	83 ec 14             	sub    $0x14,%esp
  801d08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  b->buf[b->idx++] = ch;
  801d0b:	8b 13                	mov    (%ebx),%edx
  801d0d:	8d 42 01             	lea    0x1(%edx),%eax
  801d10:	89 03                	mov    %eax,(%ebx)
  801d12:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d15:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
  if (b->idx == 256-1) {
  801d19:	3d ff 00 00 00       	cmp    $0xff,%eax
  801d1e:	75 19                	jne    801d39 <putch+0x38>
    sys_cputs(b->buf, b->idx);
  801d20:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801d27:	00 
  801d28:	8d 43 08             	lea    0x8(%ebx),%eax
  801d2b:	89 04 24             	mov    %eax,(%esp)
  801d2e:	e8 e3 09 00 00       	call   802716 <sys_cputs>
    b->idx = 0;
  801d33:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  }
  b->cnt++;
  801d39:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801d3d:	83 c4 14             	add    $0x14,%esp
  801d40:	5b                   	pop    %ebx
  801d41:	5d                   	pop    %ebp
  801d42:	c3                   	ret    

00801d43 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801d43:	55                   	push   %ebp
  801d44:	89 e5                	mov    %esp,%ebp
  801d46:	81 ec 28 01 00 00    	sub    $0x128,%esp
  struct printbuf b;

  b.idx = 0;
  801d4c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801d53:	00 00 00 
  b.cnt = 0;
  801d56:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801d5d:	00 00 00 
  vprintfmt((void*)putch, &b, fmt, ap);
  801d60:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d63:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d67:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d6e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801d74:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d78:	c7 04 24 01 1d 80 00 	movl   $0x801d01,(%esp)
  801d7f:	e8 aa 01 00 00       	call   801f2e <vprintfmt>
  sys_cputs(b.buf, b.idx);
  801d84:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801d8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d8e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801d94:	89 04 24             	mov    %eax,(%esp)
  801d97:	e8 7a 09 00 00       	call   802716 <sys_cputs>

  return b.cnt;
}
  801d9c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801da2:	c9                   	leave  
  801da3:	c3                   	ret    

00801da4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  801daa:	8d 45 0c             	lea    0xc(%ebp),%eax
  cnt = vcprintf(fmt, ap);
  801dad:	89 44 24 04          	mov    %eax,0x4(%esp)
  801db1:	8b 45 08             	mov    0x8(%ebp),%eax
  801db4:	89 04 24             	mov    %eax,(%esp)
  801db7:	e8 87 ff ff ff       	call   801d43 <vcprintf>
  va_end(ap);

  return cnt;
}
  801dbc:	c9                   	leave  
  801dbd:	c3                   	ret    
  801dbe:	66 90                	xchg   %ax,%ax

00801dc0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
         unsigned long long num, unsigned base, int width, int padc)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	57                   	push   %edi
  801dc4:	56                   	push   %esi
  801dc5:	53                   	push   %ebx
  801dc6:	83 ec 3c             	sub    $0x3c,%esp
  801dc9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801dcc:	89 d7                	mov    %edx,%edi
  801dce:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801dd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd7:	89 c3                	mov    %eax,%ebx
  801dd9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801ddc:	8b 45 10             	mov    0x10(%ebp),%eax
  801ddf:	8b 75 14             	mov    0x14(%ebp),%esi
  // first recursively print all preceding (more significant) digits
  if (num >= base)
  801de2:	b9 00 00 00 00       	mov    $0x0,%ecx
  801de7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801dea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801ded:	39 d9                	cmp    %ebx,%ecx
  801def:	72 05                	jb     801df6 <printnum+0x36>
  801df1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  801df4:	77 69                	ja     801e5f <printnum+0x9f>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  801df6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  801df9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801dfd:	83 ee 01             	sub    $0x1,%esi
  801e00:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801e04:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e08:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e0c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e10:	89 c3                	mov    %eax,%ebx
  801e12:	89 d6                	mov    %edx,%esi
  801e14:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801e17:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801e1a:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e1e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e22:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e25:	89 04 24             	mov    %eax,(%esp)
  801e28:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801e2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e2f:	e8 8c 1b 00 00       	call   8039c0 <__udivdi3>
  801e34:	89 d9                	mov    %ebx,%ecx
  801e36:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e3a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801e3e:	89 04 24             	mov    %eax,(%esp)
  801e41:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e45:	89 fa                	mov    %edi,%edx
  801e47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e4a:	e8 71 ff ff ff       	call   801dc0 <printnum>
  801e4f:	eb 1b                	jmp    801e6c <printnum+0xac>
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
      putch(padc, putdat);
  801e51:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e55:	8b 45 18             	mov    0x18(%ebp),%eax
  801e58:	89 04 24             	mov    %eax,(%esp)
  801e5b:	ff d3                	call   *%ebx
  801e5d:	eb 03                	jmp    801e62 <printnum+0xa2>
  801e5f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  // first recursively print all preceding (more significant) digits
  if (num >= base)
    printnum(putch, putdat, num / base, base, width - 1, padc);
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
  801e62:	83 ee 01             	sub    $0x1,%esi
  801e65:	85 f6                	test   %esi,%esi
  801e67:	7f e8                	jg     801e51 <printnum+0x91>
  801e69:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
      putch(padc, putdat);
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  801e6c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e70:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801e74:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801e77:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801e7a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e7e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801e82:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e85:	89 04 24             	mov    %eax,(%esp)
  801e88:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801e8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e8f:	e8 5c 1c 00 00       	call   803af0 <__umoddi3>
  801e94:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e98:	0f be 80 37 42 80 00 	movsbl 0x804237(%eax),%eax
  801e9f:	89 04 24             	mov    %eax,(%esp)
  801ea2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ea5:	ff d0                	call   *%eax
}
  801ea7:	83 c4 3c             	add    $0x3c,%esp
  801eaa:	5b                   	pop    %ebx
  801eab:	5e                   	pop    %esi
  801eac:	5f                   	pop    %edi
  801ead:	5d                   	pop    %ebp
  801eae:	c3                   	ret    

00801eaf <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801eaf:	55                   	push   %ebp
  801eb0:	89 e5                	mov    %esp,%ebp
  if (lflag >= 2)
  801eb2:	83 fa 01             	cmp    $0x1,%edx
  801eb5:	7e 0e                	jle    801ec5 <getuint+0x16>
    return va_arg(*ap, unsigned long long);
  801eb7:	8b 10                	mov    (%eax),%edx
  801eb9:	8d 4a 08             	lea    0x8(%edx),%ecx
  801ebc:	89 08                	mov    %ecx,(%eax)
  801ebe:	8b 02                	mov    (%edx),%eax
  801ec0:	8b 52 04             	mov    0x4(%edx),%edx
  801ec3:	eb 22                	jmp    801ee7 <getuint+0x38>
  else if (lflag)
  801ec5:	85 d2                	test   %edx,%edx
  801ec7:	74 10                	je     801ed9 <getuint+0x2a>
    return va_arg(*ap, unsigned long);
  801ec9:	8b 10                	mov    (%eax),%edx
  801ecb:	8d 4a 04             	lea    0x4(%edx),%ecx
  801ece:	89 08                	mov    %ecx,(%eax)
  801ed0:	8b 02                	mov    (%edx),%eax
  801ed2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ed7:	eb 0e                	jmp    801ee7 <getuint+0x38>
  else
    return va_arg(*ap, unsigned int);
  801ed9:	8b 10                	mov    (%eax),%edx
  801edb:	8d 4a 04             	lea    0x4(%edx),%ecx
  801ede:	89 08                	mov    %ecx,(%eax)
  801ee0:	8b 02                	mov    (%edx),%eax
  801ee2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801ee7:	5d                   	pop    %ebp
  801ee8:	c3                   	ret    

00801ee9 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801ee9:	55                   	push   %ebp
  801eea:	89 e5                	mov    %esp,%ebp
  801eec:	8b 45 0c             	mov    0xc(%ebp),%eax
  b->cnt++;
  801eef:	83 40 08 01          	addl   $0x1,0x8(%eax)
  if (b->buf < b->ebuf)
  801ef3:	8b 10                	mov    (%eax),%edx
  801ef5:	3b 50 04             	cmp    0x4(%eax),%edx
  801ef8:	73 0a                	jae    801f04 <sprintputch+0x1b>
    *b->buf++ = ch;
  801efa:	8d 4a 01             	lea    0x1(%edx),%ecx
  801efd:	89 08                	mov    %ecx,(%eax)
  801eff:	8b 45 08             	mov    0x8(%ebp),%eax
  801f02:	88 02                	mov    %al,(%edx)
}
  801f04:	5d                   	pop    %ebp
  801f05:	c3                   	ret    

00801f06 <printfmt>:
  }
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801f06:	55                   	push   %ebp
  801f07:	89 e5                	mov    %esp,%ebp
  801f09:	83 ec 18             	sub    $0x18,%esp
  va_list ap;

  va_start(ap, fmt);
  801f0c:	8d 45 14             	lea    0x14(%ebp),%eax
  vprintfmt(putch, putdat, fmt, ap);
  801f0f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f13:	8b 45 10             	mov    0x10(%ebp),%eax
  801f16:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f21:	8b 45 08             	mov    0x8(%ebp),%eax
  801f24:	89 04 24             	mov    %eax,(%esp)
  801f27:	e8 02 00 00 00       	call   801f2e <vprintfmt>
  va_end(ap);
}
  801f2c:	c9                   	leave  
  801f2d:	c3                   	ret    

00801f2e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801f2e:	55                   	push   %ebp
  801f2f:	89 e5                	mov    %esp,%ebp
  801f31:	57                   	push   %edi
  801f32:	56                   	push   %esi
  801f33:	53                   	push   %ebx
  801f34:	83 ec 3c             	sub    $0x3c,%esp
  801f37:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f3d:	eb 14                	jmp    801f53 <vprintfmt+0x25>
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
      if (ch == '\0')
  801f3f:	85 c0                	test   %eax,%eax
  801f41:	0f 84 b3 03 00 00    	je     8022fa <vprintfmt+0x3cc>
        return;
      putch(ch, putdat);
  801f47:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f4b:	89 04 24             	mov    %eax,(%esp)
  801f4e:	ff 55 08             	call   *0x8(%ebp)
  unsigned long long num;
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
  801f51:	89 f3                	mov    %esi,%ebx
  801f53:	8d 73 01             	lea    0x1(%ebx),%esi
  801f56:	0f b6 03             	movzbl (%ebx),%eax
  801f59:	83 f8 25             	cmp    $0x25,%eax
  801f5c:	75 e1                	jne    801f3f <vprintfmt+0x11>
  801f5e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  801f62:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801f69:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801f70:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  801f77:	ba 00 00 00 00       	mov    $0x0,%edx
  801f7c:	eb 1d                	jmp    801f9b <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  801f7e:	89 de                	mov    %ebx,%esi

    // flag to pad on the right
    case '-':
      padc = '-';
  801f80:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  801f84:	eb 15                	jmp    801f9b <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  801f86:	89 de                	mov    %ebx,%esi
      padc = '-';
      goto reswitch;

    // flag to pad with 0's instead of spaces
    case '0':
      padc = '0';
  801f88:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  801f8c:	eb 0d                	jmp    801f9b <vprintfmt+0x6d>
      altflag = 1;
      goto reswitch;

process_precision:
      if (width < 0)
        width = precision, precision = -1;
  801f8e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801f91:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801f94:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  801f9b:	8d 5e 01             	lea    0x1(%esi),%ebx
  801f9e:	0f b6 0e             	movzbl (%esi),%ecx
  801fa1:	0f b6 c1             	movzbl %cl,%eax
  801fa4:	83 e9 23             	sub    $0x23,%ecx
  801fa7:	80 f9 55             	cmp    $0x55,%cl
  801faa:	0f 87 2a 03 00 00    	ja     8022da <vprintfmt+0x3ac>
  801fb0:	0f b6 c9             	movzbl %cl,%ecx
  801fb3:	ff 24 8d 80 43 80 00 	jmp    *0x804380(,%ecx,4)
  801fba:	89 de                	mov    %ebx,%esi
  801fbc:	b9 00 00 00 00       	mov    $0x0,%ecx
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
        precision = precision * 10 + ch - '0';
  801fc1:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  801fc4:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
        ch = *fmt;
  801fc8:	0f be 06             	movsbl (%esi),%eax
        if (ch < '0' || ch > '9')
  801fcb:	8d 58 d0             	lea    -0x30(%eax),%ebx
  801fce:	83 fb 09             	cmp    $0x9,%ebx
  801fd1:	77 36                	ja     802009 <vprintfmt+0xdb>
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
  801fd3:	83 c6 01             	add    $0x1,%esi
        precision = precision * 10 + ch - '0';
        ch = *fmt;
        if (ch < '0' || ch > '9')
          break;
      }
  801fd6:	eb e9                	jmp    801fc1 <vprintfmt+0x93>
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
  801fd8:	8b 45 14             	mov    0x14(%ebp),%eax
  801fdb:	8d 48 04             	lea    0x4(%eax),%ecx
  801fde:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801fe1:	8b 00                	mov    (%eax),%eax
  801fe3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  801fe6:	89 de                	mov    %ebx,%esi
      }
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
      goto process_precision;
  801fe8:	eb 22                	jmp    80200c <vprintfmt+0xde>
  801fea:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801fed:	85 c9                	test   %ecx,%ecx
  801fef:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff4:	0f 49 c1             	cmovns %ecx,%eax
  801ff7:	89 45 dc             	mov    %eax,-0x24(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  801ffa:	89 de                	mov    %ebx,%esi
  801ffc:	eb 9d                	jmp    801f9b <vprintfmt+0x6d>
  801ffe:	89 de                	mov    %ebx,%esi
      if (width < 0)
        width = 0;
      goto reswitch;

    case '#':
      altflag = 1;
  802000:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
      goto reswitch;
  802007:	eb 92                	jmp    801f9b <vprintfmt+0x6d>
  802009:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

process_precision:
      if (width < 0)
  80200c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  802010:	79 89                	jns    801f9b <vprintfmt+0x6d>
  802012:	e9 77 ff ff ff       	jmp    801f8e <vprintfmt+0x60>
        width = precision, precision = -1;
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
  802017:	83 c2 01             	add    $0x1,%edx
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80201a:	89 de                	mov    %ebx,%esi
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
      goto reswitch;
  80201c:	e9 7a ff ff ff       	jmp    801f9b <vprintfmt+0x6d>

    // character
    case 'c':
      putch(va_arg(ap, int), putdat);
  802021:	8b 45 14             	mov    0x14(%ebp),%eax
  802024:	8d 50 04             	lea    0x4(%eax),%edx
  802027:	89 55 14             	mov    %edx,0x14(%ebp)
  80202a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80202e:	8b 00                	mov    (%eax),%eax
  802030:	89 04 24             	mov    %eax,(%esp)
  802033:	ff 55 08             	call   *0x8(%ebp)
      break;
  802036:	e9 18 ff ff ff       	jmp    801f53 <vprintfmt+0x25>

    // error message
    case 'e':
      err = va_arg(ap, int);
  80203b:	8b 45 14             	mov    0x14(%ebp),%eax
  80203e:	8d 50 04             	lea    0x4(%eax),%edx
  802041:	89 55 14             	mov    %edx,0x14(%ebp)
  802044:	8b 00                	mov    (%eax),%eax
  802046:	99                   	cltd   
  802047:	31 d0                	xor    %edx,%eax
  802049:	29 d0                	sub    %edx,%eax
      if (err < 0)
        err = -err;
      if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80204b:	83 f8 0f             	cmp    $0xf,%eax
  80204e:	7f 0b                	jg     80205b <vprintfmt+0x12d>
  802050:	8b 14 85 e0 44 80 00 	mov    0x8044e0(,%eax,4),%edx
  802057:	85 d2                	test   %edx,%edx
  802059:	75 20                	jne    80207b <vprintfmt+0x14d>
        printfmt(putch, putdat, "error %d", err);
  80205b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80205f:	c7 44 24 08 4f 42 80 	movl   $0x80424f,0x8(%esp)
  802066:	00 
  802067:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80206b:	8b 45 08             	mov    0x8(%ebp),%eax
  80206e:	89 04 24             	mov    %eax,(%esp)
  802071:	e8 90 fe ff ff       	call   801f06 <printfmt>
  802076:	e9 d8 fe ff ff       	jmp    801f53 <vprintfmt+0x25>
      else
        printfmt(putch, putdat, "%s", p);
  80207b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80207f:	c7 44 24 08 af 3c 80 	movl   $0x803caf,0x8(%esp)
  802086:	00 
  802087:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80208b:	8b 45 08             	mov    0x8(%ebp),%eax
  80208e:	89 04 24             	mov    %eax,(%esp)
  802091:	e8 70 fe ff ff       	call   801f06 <printfmt>
  802096:	e9 b8 fe ff ff       	jmp    801f53 <vprintfmt+0x25>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
  80209b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80209e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8020a1:	89 45 d0             	mov    %eax,-0x30(%ebp)
        printfmt(putch, putdat, "%s", p);
      break;

    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
  8020a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8020a7:	8d 50 04             	lea    0x4(%eax),%edx
  8020aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8020ad:	8b 30                	mov    (%eax),%esi
        p = "(null)";
  8020af:	85 f6                	test   %esi,%esi
  8020b1:	b8 48 42 80 00       	mov    $0x804248,%eax
  8020b6:	0f 44 f0             	cmove  %eax,%esi
      if (width > 0 && padc != '-')
  8020b9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8020bd:	0f 84 97 00 00 00    	je     80215a <vprintfmt+0x22c>
  8020c3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8020c7:	0f 8e 9b 00 00 00    	jle    802168 <vprintfmt+0x23a>
        for (width -= strnlen(p, precision); width > 0; width--)
  8020cd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8020d1:	89 34 24             	mov    %esi,(%esp)
  8020d4:	e8 cf 02 00 00       	call   8023a8 <strnlen>
  8020d9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8020dc:	29 c2                	sub    %eax,%edx
  8020de:	89 55 d0             	mov    %edx,-0x30(%ebp)
          putch(padc, putdat);
  8020e1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8020e5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8020e8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8020eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8020ee:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8020f1:	89 d3                	mov    %edx,%ebx
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
  8020f3:	eb 0f                	jmp    802104 <vprintfmt+0x1d6>
          putch(padc, putdat);
  8020f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8020f9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8020fc:	89 04 24             	mov    %eax,(%esp)
  8020ff:	ff d6                	call   *%esi
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
  802101:	83 eb 01             	sub    $0x1,%ebx
  802104:	85 db                	test   %ebx,%ebx
  802106:	7f ed                	jg     8020f5 <vprintfmt+0x1c7>
  802108:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80210b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80210e:	85 d2                	test   %edx,%edx
  802110:	b8 00 00 00 00       	mov    $0x0,%eax
  802115:	0f 49 c2             	cmovns %edx,%eax
  802118:	29 c2                	sub    %eax,%edx
  80211a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80211d:	89 d7                	mov    %edx,%edi
  80211f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  802122:	eb 50                	jmp    802174 <vprintfmt+0x246>
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
  802124:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  802128:	74 1e                	je     802148 <vprintfmt+0x21a>
  80212a:	0f be d2             	movsbl %dl,%edx
  80212d:	83 ea 20             	sub    $0x20,%edx
  802130:	83 fa 5e             	cmp    $0x5e,%edx
  802133:	76 13                	jbe    802148 <vprintfmt+0x21a>
          putch('?', putdat);
  802135:	8b 45 0c             	mov    0xc(%ebp),%eax
  802138:	89 44 24 04          	mov    %eax,0x4(%esp)
  80213c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  802143:	ff 55 08             	call   *0x8(%ebp)
  802146:	eb 0d                	jmp    802155 <vprintfmt+0x227>
        else
          putch(ch, putdat);
  802148:	8b 55 0c             	mov    0xc(%ebp),%edx
  80214b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80214f:	89 04 24             	mov    %eax,(%esp)
  802152:	ff 55 08             	call   *0x8(%ebp)
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  802155:	83 ef 01             	sub    $0x1,%edi
  802158:	eb 1a                	jmp    802174 <vprintfmt+0x246>
  80215a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80215d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  802160:	89 5d 10             	mov    %ebx,0x10(%ebp)
  802163:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  802166:	eb 0c                	jmp    802174 <vprintfmt+0x246>
  802168:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80216b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80216e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  802171:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  802174:	83 c6 01             	add    $0x1,%esi
  802177:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80217b:	0f be c2             	movsbl %dl,%eax
  80217e:	85 c0                	test   %eax,%eax
  802180:	74 27                	je     8021a9 <vprintfmt+0x27b>
  802182:	85 db                	test   %ebx,%ebx
  802184:	78 9e                	js     802124 <vprintfmt+0x1f6>
  802186:	83 eb 01             	sub    $0x1,%ebx
  802189:	79 99                	jns    802124 <vprintfmt+0x1f6>
  80218b:	89 f8                	mov    %edi,%eax
  80218d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802190:	8b 75 08             	mov    0x8(%ebp),%esi
  802193:	89 c3                	mov    %eax,%ebx
  802195:	eb 1a                	jmp    8021b1 <vprintfmt+0x283>
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
        putch(' ', putdat);
  802197:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80219b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8021a2:	ff d6                	call   *%esi
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
  8021a4:	83 eb 01             	sub    $0x1,%ebx
  8021a7:	eb 08                	jmp    8021b1 <vprintfmt+0x283>
  8021a9:	89 fb                	mov    %edi,%ebx
  8021ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8021ae:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8021b1:	85 db                	test   %ebx,%ebx
  8021b3:	7f e2                	jg     802197 <vprintfmt+0x269>
  8021b5:	89 75 08             	mov    %esi,0x8(%ebp)
  8021b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021bb:	e9 93 fd ff ff       	jmp    801f53 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  if (lflag >= 2)
  8021c0:	83 fa 01             	cmp    $0x1,%edx
  8021c3:	7e 16                	jle    8021db <vprintfmt+0x2ad>
    return va_arg(*ap, long long);
  8021c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8021c8:	8d 50 08             	lea    0x8(%eax),%edx
  8021cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8021ce:	8b 50 04             	mov    0x4(%eax),%edx
  8021d1:	8b 00                	mov    (%eax),%eax
  8021d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8021d6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8021d9:	eb 32                	jmp    80220d <vprintfmt+0x2df>
  else if (lflag)
  8021db:	85 d2                	test   %edx,%edx
  8021dd:	74 18                	je     8021f7 <vprintfmt+0x2c9>
    return va_arg(*ap, long);
  8021df:	8b 45 14             	mov    0x14(%ebp),%eax
  8021e2:	8d 50 04             	lea    0x4(%eax),%edx
  8021e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8021e8:	8b 30                	mov    (%eax),%esi
  8021ea:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8021ed:	89 f0                	mov    %esi,%eax
  8021ef:	c1 f8 1f             	sar    $0x1f,%eax
  8021f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8021f5:	eb 16                	jmp    80220d <vprintfmt+0x2df>
  else
    return va_arg(*ap, int);
  8021f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8021fa:	8d 50 04             	lea    0x4(%eax),%edx
  8021fd:	89 55 14             	mov    %edx,0x14(%ebp)
  802200:	8b 30                	mov    (%eax),%esi
  802202:	89 75 e0             	mov    %esi,-0x20(%ebp)
  802205:	89 f0                	mov    %esi,%eax
  802207:	c1 f8 1f             	sar    $0x1f,%eax
  80220a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        putch(' ', putdat);
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
  80220d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802210:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      if ((long long)num < 0) {
        putch('-', putdat);
        num = -(long long)num;
      }
      base = 10;
  802213:	b9 0a 00 00 00       	mov    $0xa,%ecx
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
      if ((long long)num < 0) {
  802218:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80221c:	0f 89 80 00 00 00    	jns    8022a2 <vprintfmt+0x374>
        putch('-', putdat);
  802222:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802226:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80222d:	ff 55 08             	call   *0x8(%ebp)
        num = -(long long)num;
  802230:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802233:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802236:	f7 d8                	neg    %eax
  802238:	83 d2 00             	adc    $0x0,%edx
  80223b:	f7 da                	neg    %edx
      }
      base = 10;
  80223d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  802242:	eb 5e                	jmp    8022a2 <vprintfmt+0x374>
      goto number;

    // unsigned decimal
    case 'u':
      num = getuint(&ap, lflag);
  802244:	8d 45 14             	lea    0x14(%ebp),%eax
  802247:	e8 63 fc ff ff       	call   801eaf <getuint>
      base = 10;
  80224c:	b9 0a 00 00 00       	mov    $0xa,%ecx
      goto number;
  802251:	eb 4f                	jmp    8022a2 <vprintfmt+0x374>

    // (unsigned) octal
    case 'o':
      num = getuint(&ap, lflag);
  802253:	8d 45 14             	lea    0x14(%ebp),%eax
  802256:	e8 54 fc ff ff       	call   801eaf <getuint>
      base = 8;
  80225b:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  802260:	eb 40                	jmp    8022a2 <vprintfmt+0x374>

    // pointer
    case 'p':
      putch('0', putdat);
  802262:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802266:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80226d:	ff 55 08             	call   *0x8(%ebp)
      putch('x', putdat);
  802270:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802274:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80227b:	ff 55 08             	call   *0x8(%ebp)
      num = (unsigned long long)
            (uintptr_t)va_arg(ap, void *);
  80227e:	8b 45 14             	mov    0x14(%ebp),%eax
  802281:	8d 50 04             	lea    0x4(%eax),%edx
  802284:	89 55 14             	mov    %edx,0x14(%ebp)

    // pointer
    case 'p':
      putch('0', putdat);
      putch('x', putdat);
      num = (unsigned long long)
  802287:	8b 00                	mov    (%eax),%eax
  802289:	ba 00 00 00 00       	mov    $0x0,%edx
            (uintptr_t)va_arg(ap, void *);
      base = 16;
  80228e:	b9 10 00 00 00       	mov    $0x10,%ecx
      goto number;
  802293:	eb 0d                	jmp    8022a2 <vprintfmt+0x374>

    // (unsigned) hexadecimal
    case 'x':
      num = getuint(&ap, lflag);
  802295:	8d 45 14             	lea    0x14(%ebp),%eax
  802298:	e8 12 fc ff ff       	call   801eaf <getuint>
      base = 16;
  80229d:	b9 10 00 00 00       	mov    $0x10,%ecx
number:
      printnum(putch, putdat, num, base, width, padc);
  8022a2:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8022a6:	89 74 24 10          	mov    %esi,0x10(%esp)
  8022aa:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8022ad:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8022b1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022b5:	89 04 24             	mov    %eax,(%esp)
  8022b8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022bc:	89 fa                	mov    %edi,%edx
  8022be:	8b 45 08             	mov    0x8(%ebp),%eax
  8022c1:	e8 fa fa ff ff       	call   801dc0 <printnum>
      break;
  8022c6:	e9 88 fc ff ff       	jmp    801f53 <vprintfmt+0x25>

    // escaped '%' character
    case '%':
      putch(ch, putdat);
  8022cb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8022cf:	89 04 24             	mov    %eax,(%esp)
  8022d2:	ff 55 08             	call   *0x8(%ebp)
      break;
  8022d5:	e9 79 fc ff ff       	jmp    801f53 <vprintfmt+0x25>

    // unrecognized escape sequence - just print it literally
    default:
      putch('%', putdat);
  8022da:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8022de:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8022e5:	ff 55 08             	call   *0x8(%ebp)
      for (fmt--; fmt[-1] != '%'; fmt--)
  8022e8:	89 f3                	mov    %esi,%ebx
  8022ea:	eb 03                	jmp    8022ef <vprintfmt+0x3c1>
  8022ec:	83 eb 01             	sub    $0x1,%ebx
  8022ef:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8022f3:	75 f7                	jne    8022ec <vprintfmt+0x3be>
  8022f5:	e9 59 fc ff ff       	jmp    801f53 <vprintfmt+0x25>
        /* do nothing */;
      break;
    }
  }
}
  8022fa:	83 c4 3c             	add    $0x3c,%esp
  8022fd:	5b                   	pop    %ebx
  8022fe:	5e                   	pop    %esi
  8022ff:	5f                   	pop    %edi
  802300:	5d                   	pop    %ebp
  802301:	c3                   	ret    

00802302 <vsnprintf>:
    *b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  802302:	55                   	push   %ebp
  802303:	89 e5                	mov    %esp,%ebp
  802305:	83 ec 28             	sub    $0x28,%esp
  802308:	8b 45 08             	mov    0x8(%ebp),%eax
  80230b:	8b 55 0c             	mov    0xc(%ebp),%edx
  struct sprintbuf b = { buf, buf+n-1, 0 };
  80230e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802311:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  802315:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  802318:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  if (buf == NULL || n < 1)
  80231f:	85 c0                	test   %eax,%eax
  802321:	74 30                	je     802353 <vsnprintf+0x51>
  802323:	85 d2                	test   %edx,%edx
  802325:	7e 2c                	jle    802353 <vsnprintf+0x51>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void*)sprintputch, &b, fmt, ap);
  802327:	8b 45 14             	mov    0x14(%ebp),%eax
  80232a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80232e:	8b 45 10             	mov    0x10(%ebp),%eax
  802331:	89 44 24 08          	mov    %eax,0x8(%esp)
  802335:	8d 45 ec             	lea    -0x14(%ebp),%eax
  802338:	89 44 24 04          	mov    %eax,0x4(%esp)
  80233c:	c7 04 24 e9 1e 80 00 	movl   $0x801ee9,(%esp)
  802343:	e8 e6 fb ff ff       	call   801f2e <vprintfmt>

  // null terminate the buffer
  *b.buf = '\0';
  802348:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80234b:	c6 00 00             	movb   $0x0,(%eax)

  return b.cnt;
  80234e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802351:	eb 05                	jmp    802358 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  struct sprintbuf b = { buf, buf+n-1, 0 };

  if (buf == NULL || n < 1)
    return -E_INVAL;
  802353:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

  // null terminate the buffer
  *b.buf = '\0';

  return b.cnt;
}
  802358:	c9                   	leave  
  802359:	c3                   	ret    

0080235a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80235a:	55                   	push   %ebp
  80235b:	89 e5                	mov    %esp,%ebp
  80235d:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int rc;

  va_start(ap, fmt);
  802360:	8d 45 14             	lea    0x14(%ebp),%eax
  rc = vsnprintf(buf, n, fmt, ap);
  802363:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802367:	8b 45 10             	mov    0x10(%ebp),%eax
  80236a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80236e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802371:	89 44 24 04          	mov    %eax,0x4(%esp)
  802375:	8b 45 08             	mov    0x8(%ebp),%eax
  802378:	89 04 24             	mov    %eax,(%esp)
  80237b:	e8 82 ff ff ff       	call   802302 <vsnprintf>
  va_end(ap);

  return rc;
}
  802380:	c9                   	leave  
  802381:	c3                   	ret    
  802382:	66 90                	xchg   %ax,%ax
  802384:	66 90                	xchg   %ax,%ax
  802386:	66 90                	xchg   %ax,%ax
  802388:	66 90                	xchg   %ax,%ax
  80238a:	66 90                	xchg   %ax,%ax
  80238c:	66 90                	xchg   %ax,%ax
  80238e:	66 90                	xchg   %ax,%ax

00802390 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  802390:	55                   	push   %ebp
  802391:	89 e5                	mov    %esp,%ebp
  802393:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for (n = 0; *s != '\0'; s++)
  802396:	b8 00 00 00 00       	mov    $0x0,%eax
  80239b:	eb 03                	jmp    8023a0 <strlen+0x10>
    n++;
  80239d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
  int n;

  for (n = 0; *s != '\0'; s++)
  8023a0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8023a4:	75 f7                	jne    80239d <strlen+0xd>
    n++;
  return n;
}
  8023a6:	5d                   	pop    %ebp
  8023a7:	c3                   	ret    

008023a8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8023a8:	55                   	push   %ebp
  8023a9:	89 e5                	mov    %esp,%ebp
  8023ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8023b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8023b6:	eb 03                	jmp    8023bb <strnlen+0x13>
    n++;
  8023b8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8023bb:	39 d0                	cmp    %edx,%eax
  8023bd:	74 06                	je     8023c5 <strnlen+0x1d>
  8023bf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8023c3:	75 f3                	jne    8023b8 <strnlen+0x10>
    n++;
  return n;
}
  8023c5:	5d                   	pop    %ebp
  8023c6:	c3                   	ret    

008023c7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8023c7:	55                   	push   %ebp
  8023c8:	89 e5                	mov    %esp,%ebp
  8023ca:	53                   	push   %ebx
  8023cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  8023d1:	89 c2                	mov    %eax,%edx
  8023d3:	83 c2 01             	add    $0x1,%edx
  8023d6:	83 c1 01             	add    $0x1,%ecx
  8023d9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8023dd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8023e0:	84 db                	test   %bl,%bl
  8023e2:	75 ef                	jne    8023d3 <strcpy+0xc>
    /* do nothing */;
  return ret;
}
  8023e4:	5b                   	pop    %ebx
  8023e5:	5d                   	pop    %ebp
  8023e6:	c3                   	ret    

008023e7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8023e7:	55                   	push   %ebp
  8023e8:	89 e5                	mov    %esp,%ebp
  8023ea:	53                   	push   %ebx
  8023eb:	83 ec 08             	sub    $0x8,%esp
  8023ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int len = strlen(dst);
  8023f1:	89 1c 24             	mov    %ebx,(%esp)
  8023f4:	e8 97 ff ff ff       	call   802390 <strlen>

  strcpy(dst + len, src);
  8023f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023fc:	89 54 24 04          	mov    %edx,0x4(%esp)
  802400:	01 d8                	add    %ebx,%eax
  802402:	89 04 24             	mov    %eax,(%esp)
  802405:	e8 bd ff ff ff       	call   8023c7 <strcpy>
  return dst;
}
  80240a:	89 d8                	mov    %ebx,%eax
  80240c:	83 c4 08             	add    $0x8,%esp
  80240f:	5b                   	pop    %ebx
  802410:	5d                   	pop    %ebp
  802411:	c3                   	ret    

00802412 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  802412:	55                   	push   %ebp
  802413:	89 e5                	mov    %esp,%ebp
  802415:	56                   	push   %esi
  802416:	53                   	push   %ebx
  802417:	8b 75 08             	mov    0x8(%ebp),%esi
  80241a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80241d:	89 f3                	mov    %esi,%ebx
  80241f:	03 5d 10             	add    0x10(%ebp),%ebx
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  802422:	89 f2                	mov    %esi,%edx
  802424:	eb 0f                	jmp    802435 <strncpy+0x23>
    *dst++ = *src;
  802426:	83 c2 01             	add    $0x1,%edx
  802429:	0f b6 01             	movzbl (%ecx),%eax
  80242c:	88 42 ff             	mov    %al,-0x1(%edx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  80242f:	80 39 01             	cmpb   $0x1,(%ecx)
  802432:	83 d9 ff             	sbb    $0xffffffff,%ecx
{
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  802435:	39 da                	cmp    %ebx,%edx
  802437:	75 ed                	jne    802426 <strncpy+0x14>
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  }
  return ret;
}
  802439:	89 f0                	mov    %esi,%eax
  80243b:	5b                   	pop    %ebx
  80243c:	5e                   	pop    %esi
  80243d:	5d                   	pop    %ebp
  80243e:	c3                   	ret    

0080243f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80243f:	55                   	push   %ebp
  802440:	89 e5                	mov    %esp,%ebp
  802442:	56                   	push   %esi
  802443:	53                   	push   %ebx
  802444:	8b 75 08             	mov    0x8(%ebp),%esi
  802447:	8b 55 0c             	mov    0xc(%ebp),%edx
  80244a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80244d:	89 f0                	mov    %esi,%eax
  80244f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  802453:	85 c9                	test   %ecx,%ecx
  802455:	75 0b                	jne    802462 <strlcpy+0x23>
  802457:	eb 1d                	jmp    802476 <strlcpy+0x37>
    while (--size > 0 && *src != '\0')
      *dst++ = *src++;
  802459:	83 c0 01             	add    $0x1,%eax
  80245c:	83 c2 01             	add    $0x1,%edx
  80245f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
    while (--size > 0 && *src != '\0')
  802462:	39 d8                	cmp    %ebx,%eax
  802464:	74 0b                	je     802471 <strlcpy+0x32>
  802466:	0f b6 0a             	movzbl (%edx),%ecx
  802469:	84 c9                	test   %cl,%cl
  80246b:	75 ec                	jne    802459 <strlcpy+0x1a>
  80246d:	89 c2                	mov    %eax,%edx
  80246f:	eb 02                	jmp    802473 <strlcpy+0x34>
  802471:	89 c2                	mov    %eax,%edx
      *dst++ = *src++;
    *dst = '\0';
  802473:	c6 02 00             	movb   $0x0,(%edx)
  }
  return dst - dst_in;
  802476:	29 f0                	sub    %esi,%eax
}
  802478:	5b                   	pop    %ebx
  802479:	5e                   	pop    %esi
  80247a:	5d                   	pop    %ebp
  80247b:	c3                   	ret    

0080247c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80247c:	55                   	push   %ebp
  80247d:	89 e5                	mov    %esp,%ebp
  80247f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802482:	8b 55 0c             	mov    0xc(%ebp),%edx
  while (*p && *p == *q)
  802485:	eb 06                	jmp    80248d <strcmp+0x11>
    p++, q++;
  802487:	83 c1 01             	add    $0x1,%ecx
  80248a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
  while (*p && *p == *q)
  80248d:	0f b6 01             	movzbl (%ecx),%eax
  802490:	84 c0                	test   %al,%al
  802492:	74 04                	je     802498 <strcmp+0x1c>
  802494:	3a 02                	cmp    (%edx),%al
  802496:	74 ef                	je     802487 <strcmp+0xb>
    p++, q++;
  return (int)((unsigned char)*p - (unsigned char)*q);
  802498:	0f b6 c0             	movzbl %al,%eax
  80249b:	0f b6 12             	movzbl (%edx),%edx
  80249e:	29 d0                	sub    %edx,%eax
}
  8024a0:	5d                   	pop    %ebp
  8024a1:	c3                   	ret    

008024a2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8024a2:	55                   	push   %ebp
  8024a3:	89 e5                	mov    %esp,%ebp
  8024a5:	53                   	push   %ebx
  8024a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8024a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024ac:	89 c3                	mov    %eax,%ebx
  8024ae:	03 5d 10             	add    0x10(%ebp),%ebx
  while (n > 0 && *p && *p == *q)
  8024b1:	eb 06                	jmp    8024b9 <strncmp+0x17>
    n--, p++, q++;
  8024b3:	83 c0 01             	add    $0x1,%eax
  8024b6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
  8024b9:	39 d8                	cmp    %ebx,%eax
  8024bb:	74 15                	je     8024d2 <strncmp+0x30>
  8024bd:	0f b6 08             	movzbl (%eax),%ecx
  8024c0:	84 c9                	test   %cl,%cl
  8024c2:	74 04                	je     8024c8 <strncmp+0x26>
  8024c4:	3a 0a                	cmp    (%edx),%cl
  8024c6:	74 eb                	je     8024b3 <strncmp+0x11>
    n--, p++, q++;
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  8024c8:	0f b6 00             	movzbl (%eax),%eax
  8024cb:	0f b6 12             	movzbl (%edx),%edx
  8024ce:	29 d0                	sub    %edx,%eax
  8024d0:	eb 05                	jmp    8024d7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
    n--, p++, q++;
  if (n == 0)
    return 0;
  8024d2:	b8 00 00 00 00       	mov    $0x0,%eax
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
}
  8024d7:	5b                   	pop    %ebx
  8024d8:	5d                   	pop    %ebp
  8024d9:	c3                   	ret    

008024da <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8024da:	55                   	push   %ebp
  8024db:	89 e5                	mov    %esp,%ebp
  8024dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8024e0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
  8024e4:	eb 07                	jmp    8024ed <strchr+0x13>
    if (*s == c)
  8024e6:	38 ca                	cmp    %cl,%dl
  8024e8:	74 0f                	je     8024f9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  for (; *s; s++)
  8024ea:	83 c0 01             	add    $0x1,%eax
  8024ed:	0f b6 10             	movzbl (%eax),%edx
  8024f0:	84 d2                	test   %dl,%dl
  8024f2:	75 f2                	jne    8024e6 <strchr+0xc>
    if (*s == c)
      return (char*)s;
  return 0;
  8024f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8024f9:	5d                   	pop    %ebp
  8024fa:	c3                   	ret    

008024fb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8024fb:	55                   	push   %ebp
  8024fc:	89 e5                	mov    %esp,%ebp
  8024fe:	8b 45 08             	mov    0x8(%ebp),%eax
  802501:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
  802505:	eb 07                	jmp    80250e <strfind+0x13>
    if (*s == c)
  802507:	38 ca                	cmp    %cl,%dl
  802509:	74 0a                	je     802515 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  for (; *s; s++)
  80250b:	83 c0 01             	add    $0x1,%eax
  80250e:	0f b6 10             	movzbl (%eax),%edx
  802511:	84 d2                	test   %dl,%dl
  802513:	75 f2                	jne    802507 <strfind+0xc>
    if (*s == c)
      break;
  return (char*)s;
}
  802515:	5d                   	pop    %ebp
  802516:	c3                   	ret    

00802517 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  802517:	55                   	push   %ebp
  802518:	89 e5                	mov    %esp,%ebp
  80251a:	57                   	push   %edi
  80251b:	56                   	push   %esi
  80251c:	53                   	push   %ebx
  80251d:	8b 7d 08             	mov    0x8(%ebp),%edi
  802520:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *p;

  if (n == 0)
  802523:	85 c9                	test   %ecx,%ecx
  802525:	74 36                	je     80255d <memset+0x46>
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
  802527:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80252d:	75 28                	jne    802557 <memset+0x40>
  80252f:	f6 c1 03             	test   $0x3,%cl
  802532:	75 23                	jne    802557 <memset+0x40>
    c &= 0xFF;
  802534:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
    c = (c<<24)|(c<<16)|(c<<8)|c;
  802538:	89 d3                	mov    %edx,%ebx
  80253a:	c1 e3 08             	shl    $0x8,%ebx
  80253d:	89 d6                	mov    %edx,%esi
  80253f:	c1 e6 18             	shl    $0x18,%esi
  802542:	89 d0                	mov    %edx,%eax
  802544:	c1 e0 10             	shl    $0x10,%eax
  802547:	09 f0                	or     %esi,%eax
  802549:	09 c2                	or     %eax,%edx
  80254b:	89 d0                	mov    %edx,%eax
  80254d:	09 d8                	or     %ebx,%eax
    asm volatile ("cld; rep stosl\n"
                  :: "D" (v), "a" (c), "c" (n/4)
  80254f:	c1 e9 02             	shr    $0x2,%ecx
  if (n == 0)
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
    c &= 0xFF;
    c = (c<<24)|(c<<16)|(c<<8)|c;
    asm volatile ("cld; rep stosl\n"
  802552:	fc                   	cld    
  802553:	f3 ab                	rep stos %eax,%es:(%edi)
  802555:	eb 06                	jmp    80255d <memset+0x46>
                  :: "D" (v), "a" (c), "c" (n/4)
                  : "cc", "memory");
  } else
    asm volatile ("cld; rep stosb\n"
  802557:	8b 45 0c             	mov    0xc(%ebp),%eax
  80255a:	fc                   	cld    
  80255b:	f3 aa                	rep stos %al,%es:(%edi)
                  :: "D" (v), "a" (c), "c" (n)
                  : "cc", "memory");
  return v;
}
  80255d:	89 f8                	mov    %edi,%eax
  80255f:	5b                   	pop    %ebx
  802560:	5e                   	pop    %esi
  802561:	5f                   	pop    %edi
  802562:	5d                   	pop    %ebp
  802563:	c3                   	ret    

00802564 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802564:	55                   	push   %ebp
  802565:	89 e5                	mov    %esp,%ebp
  802567:	57                   	push   %edi
  802568:	56                   	push   %esi
  802569:	8b 45 08             	mov    0x8(%ebp),%eax
  80256c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80256f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  802572:	39 c6                	cmp    %eax,%esi
  802574:	73 35                	jae    8025ab <memmove+0x47>
  802576:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802579:	39 d0                	cmp    %edx,%eax
  80257b:	73 2e                	jae    8025ab <memmove+0x47>
    s += n;
    d += n;
  80257d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  802580:	89 d6                	mov    %edx,%esi
  802582:	09 fe                	or     %edi,%esi
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802584:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80258a:	75 13                	jne    80259f <memmove+0x3b>
  80258c:	f6 c1 03             	test   $0x3,%cl
  80258f:	75 0e                	jne    80259f <memmove+0x3b>
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  802591:	83 ef 04             	sub    $0x4,%edi
  802594:	8d 72 fc             	lea    -0x4(%edx),%esi
  802597:	c1 e9 02             	shr    $0x2,%ecx
  d = dst;
  if (s < d && s + n > d) {
    s += n;
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
  80259a:	fd                   	std    
  80259b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80259d:	eb 09                	jmp    8025a8 <memmove+0x44>
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80259f:	83 ef 01             	sub    $0x1,%edi
  8025a2:	8d 72 ff             	lea    -0x1(%edx),%esi
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
  8025a5:	fd                   	std    
  8025a6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  8025a8:	fc                   	cld    
  8025a9:	eb 1d                	jmp    8025c8 <memmove+0x64>
  8025ab:	89 f2                	mov    %esi,%edx
  8025ad:	09 c2                	or     %eax,%edx
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8025af:	f6 c2 03             	test   $0x3,%dl
  8025b2:	75 0f                	jne    8025c3 <memmove+0x5f>
  8025b4:	f6 c1 03             	test   $0x3,%cl
  8025b7:	75 0a                	jne    8025c3 <memmove+0x5f>
      asm volatile ("cld; rep movsl\n"
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8025b9:	c1 e9 02             	shr    $0x2,%ecx
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("cld; rep movsl\n"
  8025bc:	89 c7                	mov    %eax,%edi
  8025be:	fc                   	cld    
  8025bf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8025c1:	eb 05                	jmp    8025c8 <memmove+0x64>
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("cld; rep movsb\n"
  8025c3:	89 c7                	mov    %eax,%edi
  8025c5:	fc                   	cld    
  8025c6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d), "S" (s), "c" (n) : "cc", "memory");
  }
  return dst;
}
  8025c8:	5e                   	pop    %esi
  8025c9:	5f                   	pop    %edi
  8025ca:	5d                   	pop    %ebp
  8025cb:	c3                   	ret    

008025cc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8025cc:	55                   	push   %ebp
  8025cd:	89 e5                	mov    %esp,%ebp
  8025cf:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
  8025d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8025d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8025d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8025e3:	89 04 24             	mov    %eax,(%esp)
  8025e6:	e8 79 ff ff ff       	call   802564 <memmove>
}
  8025eb:	c9                   	leave  
  8025ec:	c3                   	ret    

008025ed <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8025ed:	55                   	push   %ebp
  8025ee:	89 e5                	mov    %esp,%ebp
  8025f0:	56                   	push   %esi
  8025f1:	53                   	push   %ebx
  8025f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8025f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025f8:	89 d6                	mov    %edx,%esi
  8025fa:	03 75 10             	add    0x10(%ebp),%esi
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
  8025fd:	eb 1a                	jmp    802619 <memcmp+0x2c>
    if (*s1 != *s2)
  8025ff:	0f b6 02             	movzbl (%edx),%eax
  802602:	0f b6 19             	movzbl (%ecx),%ebx
  802605:	38 d8                	cmp    %bl,%al
  802607:	74 0a                	je     802613 <memcmp+0x26>
      return (int)*s1 - (int)*s2;
  802609:	0f b6 c0             	movzbl %al,%eax
  80260c:	0f b6 db             	movzbl %bl,%ebx
  80260f:	29 d8                	sub    %ebx,%eax
  802611:	eb 0f                	jmp    802622 <memcmp+0x35>
    s1++, s2++;
  802613:	83 c2 01             	add    $0x1,%edx
  802616:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
  802619:	39 f2                	cmp    %esi,%edx
  80261b:	75 e2                	jne    8025ff <memcmp+0x12>
    if (*s1 != *s2)
      return (int)*s1 - (int)*s2;
    s1++, s2++;
  }

  return 0;
  80261d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802622:	5b                   	pop    %ebx
  802623:	5e                   	pop    %esi
  802624:	5d                   	pop    %ebp
  802625:	c3                   	ret    

00802626 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  802626:	55                   	push   %ebp
  802627:	89 e5                	mov    %esp,%ebp
  802629:	8b 45 08             	mov    0x8(%ebp),%eax
  80262c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  const void *ends = (const char*)s + n;
  80262f:	89 c2                	mov    %eax,%edx
  802631:	03 55 10             	add    0x10(%ebp),%edx

  for (; s < ends; s++)
  802634:	eb 07                	jmp    80263d <memfind+0x17>
    if (*(const unsigned char*)s == (unsigned char)c)
  802636:	38 08                	cmp    %cl,(%eax)
  802638:	74 07                	je     802641 <memfind+0x1b>
void *
memfind(const void *s, int c, size_t n)
{
  const void *ends = (const char*)s + n;

  for (; s < ends; s++)
  80263a:	83 c0 01             	add    $0x1,%eax
  80263d:	39 d0                	cmp    %edx,%eax
  80263f:	72 f5                	jb     802636 <memfind+0x10>
    if (*(const unsigned char*)s == (unsigned char)c)
      break;
  return (void*)s;
}
  802641:	5d                   	pop    %ebp
  802642:	c3                   	ret    

00802643 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  802643:	55                   	push   %ebp
  802644:	89 e5                	mov    %esp,%ebp
  802646:	57                   	push   %edi
  802647:	56                   	push   %esi
  802648:	53                   	push   %ebx
  802649:	8b 55 08             	mov    0x8(%ebp),%edx
  80264c:	8b 45 10             	mov    0x10(%ebp),%eax
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  80264f:	eb 03                	jmp    802654 <strtol+0x11>
    s++;
  802651:	83 c2 01             	add    $0x1,%edx
{
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  802654:	0f b6 0a             	movzbl (%edx),%ecx
  802657:	80 f9 09             	cmp    $0x9,%cl
  80265a:	74 f5                	je     802651 <strtol+0xe>
  80265c:	80 f9 20             	cmp    $0x20,%cl
  80265f:	74 f0                	je     802651 <strtol+0xe>
    s++;

  // plus/minus sign
  if (*s == '+')
  802661:	80 f9 2b             	cmp    $0x2b,%cl
  802664:	75 0a                	jne    802670 <strtol+0x2d>
    s++;
  802666:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
  int neg = 0;
  802669:	bf 00 00 00 00       	mov    $0x0,%edi
  80266e:	eb 11                	jmp    802681 <strtol+0x3e>
  802670:	bf 00 00 00 00       	mov    $0x0,%edi
    s++;

  // plus/minus sign
  if (*s == '+')
    s++;
  else if (*s == '-')
  802675:	80 f9 2d             	cmp    $0x2d,%cl
  802678:	75 07                	jne    802681 <strtol+0x3e>
    s++, neg = 1;
  80267a:	8d 52 01             	lea    0x1(%edx),%edx
  80267d:	66 bf 01 00          	mov    $0x1,%di

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802681:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  802686:	75 15                	jne    80269d <strtol+0x5a>
  802688:	80 3a 30             	cmpb   $0x30,(%edx)
  80268b:	75 10                	jne    80269d <strtol+0x5a>
  80268d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  802691:	75 0a                	jne    80269d <strtol+0x5a>
    s += 2, base = 16;
  802693:	83 c2 02             	add    $0x2,%edx
  802696:	b8 10 00 00 00       	mov    $0x10,%eax
  80269b:	eb 10                	jmp    8026ad <strtol+0x6a>
  else if (base == 0 && s[0] == '0')
  80269d:	85 c0                	test   %eax,%eax
  80269f:	75 0c                	jne    8026ad <strtol+0x6a>
    s++, base = 8;
  else if (base == 0)
    base = 10;
  8026a1:	b0 0a                	mov    $0xa,%al
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
  8026a3:	80 3a 30             	cmpb   $0x30,(%edx)
  8026a6:	75 05                	jne    8026ad <strtol+0x6a>
    s++, base = 8;
  8026a8:	83 c2 01             	add    $0x1,%edx
  8026ab:	b0 08                	mov    $0x8,%al
  else if (base == 0)
    base = 10;
  8026ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8026b2:	89 45 10             	mov    %eax,0x10(%ebp)

  // digits
  while (1) {
    int dig;

    if (*s >= '0' && *s <= '9')
  8026b5:	0f b6 0a             	movzbl (%edx),%ecx
  8026b8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  8026bb:	89 f0                	mov    %esi,%eax
  8026bd:	3c 09                	cmp    $0x9,%al
  8026bf:	77 08                	ja     8026c9 <strtol+0x86>
      dig = *s - '0';
  8026c1:	0f be c9             	movsbl %cl,%ecx
  8026c4:	83 e9 30             	sub    $0x30,%ecx
  8026c7:	eb 20                	jmp    8026e9 <strtol+0xa6>
    else if (*s >= 'a' && *s <= 'z')
  8026c9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  8026cc:	89 f0                	mov    %esi,%eax
  8026ce:	3c 19                	cmp    $0x19,%al
  8026d0:	77 08                	ja     8026da <strtol+0x97>
      dig = *s - 'a' + 10;
  8026d2:	0f be c9             	movsbl %cl,%ecx
  8026d5:	83 e9 57             	sub    $0x57,%ecx
  8026d8:	eb 0f                	jmp    8026e9 <strtol+0xa6>
    else if (*s >= 'A' && *s <= 'Z')
  8026da:	8d 71 bf             	lea    -0x41(%ecx),%esi
  8026dd:	89 f0                	mov    %esi,%eax
  8026df:	3c 19                	cmp    $0x19,%al
  8026e1:	77 16                	ja     8026f9 <strtol+0xb6>
      dig = *s - 'A' + 10;
  8026e3:	0f be c9             	movsbl %cl,%ecx
  8026e6:	83 e9 37             	sub    $0x37,%ecx
    else
      break;
    if (dig >= base)
  8026e9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  8026ec:	7d 0f                	jge    8026fd <strtol+0xba>
      break;
    s++, val = (val * base) + dig;
  8026ee:	83 c2 01             	add    $0x1,%edx
  8026f1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  8026f5:	01 cb                	add    %ecx,%ebx
    // we don't properly detect overflow!
  }
  8026f7:	eb bc                	jmp    8026b5 <strtol+0x72>
  8026f9:	89 d8                	mov    %ebx,%eax
  8026fb:	eb 02                	jmp    8026ff <strtol+0xbc>
  8026fd:	89 d8                	mov    %ebx,%eax

  if (endptr)
  8026ff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802703:	74 05                	je     80270a <strtol+0xc7>
    *endptr = (char*)s;
  802705:	8b 75 0c             	mov    0xc(%ebp),%esi
  802708:	89 16                	mov    %edx,(%esi)
  return neg ? -val : val;
  80270a:	f7 d8                	neg    %eax
  80270c:	85 ff                	test   %edi,%edi
  80270e:	0f 44 c3             	cmove  %ebx,%eax
}
  802711:	5b                   	pop    %ebx
  802712:	5e                   	pop    %esi
  802713:	5f                   	pop    %edi
  802714:	5d                   	pop    %ebp
  802715:	c3                   	ret    

00802716 <sys_cputs>:
  return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  802716:	55                   	push   %ebp
  802717:	89 e5                	mov    %esp,%ebp
  802719:	57                   	push   %edi
  80271a:	56                   	push   %esi
  80271b:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  80271c:	b8 00 00 00 00       	mov    $0x0,%eax
  802721:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802724:	8b 55 08             	mov    0x8(%ebp),%edx
  802727:	89 c3                	mov    %eax,%ebx
  802729:	89 c7                	mov    %eax,%edi
  80272b:	89 c6                	mov    %eax,%esi
  80272d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
  syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80272f:	5b                   	pop    %ebx
  802730:	5e                   	pop    %esi
  802731:	5f                   	pop    %edi
  802732:	5d                   	pop    %ebp
  802733:	c3                   	ret    

00802734 <sys_cgetc>:

int
sys_cgetc(void)
{
  802734:	55                   	push   %ebp
  802735:	89 e5                	mov    %esp,%ebp
  802737:	57                   	push   %edi
  802738:	56                   	push   %esi
  802739:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  80273a:	ba 00 00 00 00       	mov    $0x0,%edx
  80273f:	b8 01 00 00 00       	mov    $0x1,%eax
  802744:	89 d1                	mov    %edx,%ecx
  802746:	89 d3                	mov    %edx,%ebx
  802748:	89 d7                	mov    %edx,%edi
  80274a:	89 d6                	mov    %edx,%esi
  80274c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80274e:	5b                   	pop    %ebx
  80274f:	5e                   	pop    %esi
  802750:	5f                   	pop    %edi
  802751:	5d                   	pop    %ebp
  802752:	c3                   	ret    

00802753 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  802753:	55                   	push   %ebp
  802754:	89 e5                	mov    %esp,%ebp
  802756:	57                   	push   %edi
  802757:	56                   	push   %esi
  802758:	53                   	push   %ebx
  802759:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  80275c:	b9 00 00 00 00       	mov    $0x0,%ecx
  802761:	b8 03 00 00 00       	mov    $0x3,%eax
  802766:	8b 55 08             	mov    0x8(%ebp),%edx
  802769:	89 cb                	mov    %ecx,%ebx
  80276b:	89 cf                	mov    %ecx,%edi
  80276d:	89 ce                	mov    %ecx,%esi
  80276f:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  802771:	85 c0                	test   %eax,%eax
  802773:	7e 28                	jle    80279d <sys_env_destroy+0x4a>
    panic("syscall %d returned %d (> 0)", num, ret);
  802775:	89 44 24 10          	mov    %eax,0x10(%esp)
  802779:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  802780:	00 
  802781:	c7 44 24 08 3f 45 80 	movl   $0x80453f,0x8(%esp)
  802788:	00 
  802789:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802790:	00 
  802791:	c7 04 24 5c 45 80 00 	movl   $0x80455c,(%esp)
  802798:	e8 0e f5 ff ff       	call   801cab <_panic>

int
sys_env_destroy(envid_t envid)
{
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80279d:	83 c4 2c             	add    $0x2c,%esp
  8027a0:	5b                   	pop    %ebx
  8027a1:	5e                   	pop    %esi
  8027a2:	5f                   	pop    %edi
  8027a3:	5d                   	pop    %ebp
  8027a4:	c3                   	ret    

008027a5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8027a5:	55                   	push   %ebp
  8027a6:	89 e5                	mov    %esp,%ebp
  8027a8:	57                   	push   %edi
  8027a9:	56                   	push   %esi
  8027aa:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8027ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8027b0:	b8 02 00 00 00       	mov    $0x2,%eax
  8027b5:	89 d1                	mov    %edx,%ecx
  8027b7:	89 d3                	mov    %edx,%ebx
  8027b9:	89 d7                	mov    %edx,%edi
  8027bb:	89 d6                	mov    %edx,%esi
  8027bd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8027bf:	5b                   	pop    %ebx
  8027c0:	5e                   	pop    %esi
  8027c1:	5f                   	pop    %edi
  8027c2:	5d                   	pop    %ebp
  8027c3:	c3                   	ret    

008027c4 <sys_yield>:

void
sys_yield(void)
{
  8027c4:	55                   	push   %ebp
  8027c5:	89 e5                	mov    %esp,%ebp
  8027c7:	57                   	push   %edi
  8027c8:	56                   	push   %esi
  8027c9:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8027ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8027cf:	b8 0b 00 00 00       	mov    $0xb,%eax
  8027d4:	89 d1                	mov    %edx,%ecx
  8027d6:	89 d3                	mov    %edx,%ebx
  8027d8:	89 d7                	mov    %edx,%edi
  8027da:	89 d6                	mov    %edx,%esi
  8027dc:	cd 30                	int    $0x30

void
sys_yield(void)
{
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8027de:	5b                   	pop    %ebx
  8027df:	5e                   	pop    %esi
  8027e0:	5f                   	pop    %edi
  8027e1:	5d                   	pop    %ebp
  8027e2:	c3                   	ret    

008027e3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8027e3:	55                   	push   %ebp
  8027e4:	89 e5                	mov    %esp,%ebp
  8027e6:	57                   	push   %edi
  8027e7:	56                   	push   %esi
  8027e8:	53                   	push   %ebx
  8027e9:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8027ec:	be 00 00 00 00       	mov    $0x0,%esi
  8027f1:	b8 04 00 00 00       	mov    $0x4,%eax
  8027f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8027f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8027fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8027ff:	89 f7                	mov    %esi,%edi
  802801:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  802803:	85 c0                	test   %eax,%eax
  802805:	7e 28                	jle    80282f <sys_page_alloc+0x4c>
    panic("syscall %d returned %d (> 0)", num, ret);
  802807:	89 44 24 10          	mov    %eax,0x10(%esp)
  80280b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  802812:	00 
  802813:	c7 44 24 08 3f 45 80 	movl   $0x80453f,0x8(%esp)
  80281a:	00 
  80281b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802822:	00 
  802823:	c7 04 24 5c 45 80 00 	movl   $0x80455c,(%esp)
  80282a:	e8 7c f4 ff ff       	call   801cab <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  return syscall(SYS_page_alloc, 1, envid, (uint32_t)va, perm, 0, 0);
}
  80282f:	83 c4 2c             	add    $0x2c,%esp
  802832:	5b                   	pop    %ebx
  802833:	5e                   	pop    %esi
  802834:	5f                   	pop    %edi
  802835:	5d                   	pop    %ebp
  802836:	c3                   	ret    

00802837 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  802837:	55                   	push   %ebp
  802838:	89 e5                	mov    %esp,%ebp
  80283a:	57                   	push   %edi
  80283b:	56                   	push   %esi
  80283c:	53                   	push   %ebx
  80283d:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  802840:	b8 05 00 00 00       	mov    $0x5,%eax
  802845:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802848:	8b 55 08             	mov    0x8(%ebp),%edx
  80284b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80284e:	8b 7d 14             	mov    0x14(%ebp),%edi
  802851:	8b 75 18             	mov    0x18(%ebp),%esi
  802854:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  802856:	85 c0                	test   %eax,%eax
  802858:	7e 28                	jle    802882 <sys_page_map+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  80285a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80285e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  802865:	00 
  802866:	c7 44 24 08 3f 45 80 	movl   $0x80453f,0x8(%esp)
  80286d:	00 
  80286e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802875:	00 
  802876:	c7 04 24 5c 45 80 00 	movl   $0x80455c,(%esp)
  80287d:	e8 29 f4 ff ff       	call   801cab <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  return syscall(SYS_page_map, 1, srcenv, (uint32_t)srcva, dstenv, (uint32_t)dstva, perm);
}
  802882:	83 c4 2c             	add    $0x2c,%esp
  802885:	5b                   	pop    %ebx
  802886:	5e                   	pop    %esi
  802887:	5f                   	pop    %edi
  802888:	5d                   	pop    %ebp
  802889:	c3                   	ret    

0080288a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80288a:	55                   	push   %ebp
  80288b:	89 e5                	mov    %esp,%ebp
  80288d:	57                   	push   %edi
  80288e:	56                   	push   %esi
  80288f:	53                   	push   %ebx
  802890:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  802893:	bb 00 00 00 00       	mov    $0x0,%ebx
  802898:	b8 06 00 00 00       	mov    $0x6,%eax
  80289d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8028a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8028a3:	89 df                	mov    %ebx,%edi
  8028a5:	89 de                	mov    %ebx,%esi
  8028a7:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  8028a9:	85 c0                	test   %eax,%eax
  8028ab:	7e 28                	jle    8028d5 <sys_page_unmap+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  8028ad:	89 44 24 10          	mov    %eax,0x10(%esp)
  8028b1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8028b8:	00 
  8028b9:	c7 44 24 08 3f 45 80 	movl   $0x80453f,0x8(%esp)
  8028c0:	00 
  8028c1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8028c8:	00 
  8028c9:	c7 04 24 5c 45 80 00 	movl   $0x80455c,(%esp)
  8028d0:	e8 d6 f3 ff ff       	call   801cab <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
  return syscall(SYS_page_unmap, 1, envid, (uint32_t)va, 0, 0, 0);
}
  8028d5:	83 c4 2c             	add    $0x2c,%esp
  8028d8:	5b                   	pop    %ebx
  8028d9:	5e                   	pop    %esi
  8028da:	5f                   	pop    %edi
  8028db:	5d                   	pop    %ebp
  8028dc:	c3                   	ret    

008028dd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8028dd:	55                   	push   %ebp
  8028de:	89 e5                	mov    %esp,%ebp
  8028e0:	57                   	push   %edi
  8028e1:	56                   	push   %esi
  8028e2:	53                   	push   %ebx
  8028e3:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8028e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8028eb:	b8 08 00 00 00       	mov    $0x8,%eax
  8028f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8028f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8028f6:	89 df                	mov    %ebx,%edi
  8028f8:	89 de                	mov    %ebx,%esi
  8028fa:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  8028fc:	85 c0                	test   %eax,%eax
  8028fe:	7e 28                	jle    802928 <sys_env_set_status+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  802900:	89 44 24 10          	mov    %eax,0x10(%esp)
  802904:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80290b:	00 
  80290c:	c7 44 24 08 3f 45 80 	movl   $0x80453f,0x8(%esp)
  802913:	00 
  802914:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80291b:	00 
  80291c:	c7 04 24 5c 45 80 00 	movl   $0x80455c,(%esp)
  802923:	e8 83 f3 ff ff       	call   801cab <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  802928:	83 c4 2c             	add    $0x2c,%esp
  80292b:	5b                   	pop    %ebx
  80292c:	5e                   	pop    %esi
  80292d:	5f                   	pop    %edi
  80292e:	5d                   	pop    %ebp
  80292f:	c3                   	ret    

00802930 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  802930:	55                   	push   %ebp
  802931:	89 e5                	mov    %esp,%ebp
  802933:	57                   	push   %edi
  802934:	56                   	push   %esi
  802935:	53                   	push   %ebx
  802936:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  802939:	bb 00 00 00 00       	mov    $0x0,%ebx
  80293e:	b8 09 00 00 00       	mov    $0x9,%eax
  802943:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802946:	8b 55 08             	mov    0x8(%ebp),%edx
  802949:	89 df                	mov    %ebx,%edi
  80294b:	89 de                	mov    %ebx,%esi
  80294d:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  80294f:	85 c0                	test   %eax,%eax
  802951:	7e 28                	jle    80297b <sys_env_set_trapframe+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  802953:	89 44 24 10          	mov    %eax,0x10(%esp)
  802957:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80295e:	00 
  80295f:	c7 44 24 08 3f 45 80 	movl   $0x80453f,0x8(%esp)
  802966:	00 
  802967:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80296e:	00 
  80296f:	c7 04 24 5c 45 80 00 	movl   $0x80455c,(%esp)
  802976:	e8 30 f3 ff ff       	call   801cab <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t)tf, 0, 0, 0);
}
  80297b:	83 c4 2c             	add    $0x2c,%esp
  80297e:	5b                   	pop    %ebx
  80297f:	5e                   	pop    %esi
  802980:	5f                   	pop    %edi
  802981:	5d                   	pop    %ebp
  802982:	c3                   	ret    

00802983 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  802983:	55                   	push   %ebp
  802984:	89 e5                	mov    %esp,%ebp
  802986:	57                   	push   %edi
  802987:	56                   	push   %esi
  802988:	53                   	push   %ebx
  802989:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  80298c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802991:	b8 0a 00 00 00       	mov    $0xa,%eax
  802996:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802999:	8b 55 08             	mov    0x8(%ebp),%edx
  80299c:	89 df                	mov    %ebx,%edi
  80299e:	89 de                	mov    %ebx,%esi
  8029a0:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  8029a2:	85 c0                	test   %eax,%eax
  8029a4:	7e 28                	jle    8029ce <sys_env_set_pgfault_upcall+0x4b>
    panic("syscall %d returned %d (> 0)", num, ret);
  8029a6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8029aa:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8029b1:	00 
  8029b2:	c7 44 24 08 3f 45 80 	movl   $0x80453f,0x8(%esp)
  8029b9:	00 
  8029ba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8029c1:	00 
  8029c2:	c7 04 24 5c 45 80 00 	movl   $0x80455c,(%esp)
  8029c9:	e8 dd f2 ff ff       	call   801cab <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t)upcall, 0, 0, 0);
}
  8029ce:	83 c4 2c             	add    $0x2c,%esp
  8029d1:	5b                   	pop    %ebx
  8029d2:	5e                   	pop    %esi
  8029d3:	5f                   	pop    %edi
  8029d4:	5d                   	pop    %ebp
  8029d5:	c3                   	ret    

008029d6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8029d6:	55                   	push   %ebp
  8029d7:	89 e5                	mov    %esp,%ebp
  8029d9:	57                   	push   %edi
  8029da:	56                   	push   %esi
  8029db:	53                   	push   %ebx
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  8029dc:	be 00 00 00 00       	mov    $0x0,%esi
  8029e1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8029e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8029e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8029ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8029ef:	8b 7d 14             	mov    0x14(%ebp),%edi
  8029f2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t)srcva, perm, 0);
}
  8029f4:	5b                   	pop    %ebx
  8029f5:	5e                   	pop    %esi
  8029f6:	5f                   	pop    %edi
  8029f7:	5d                   	pop    %ebp
  8029f8:	c3                   	ret    

008029f9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8029f9:	55                   	push   %ebp
  8029fa:	89 e5                	mov    %esp,%ebp
  8029fc:	57                   	push   %edi
  8029fd:	56                   	push   %esi
  8029fe:	53                   	push   %ebx
  8029ff:	83 ec 2c             	sub    $0x2c,%esp
  //
  // The last clause tells the assembler that this can
  // potentially change the condition codes and arbitrary
  // memory locations.

  asm volatile ("int %1\n"
  802a02:	b9 00 00 00 00       	mov    $0x0,%ecx
  802a07:	b8 0d 00 00 00       	mov    $0xd,%eax
  802a0c:	8b 55 08             	mov    0x8(%ebp),%edx
  802a0f:	89 cb                	mov    %ecx,%ebx
  802a11:	89 cf                	mov    %ecx,%edi
  802a13:	89 ce                	mov    %ecx,%esi
  802a15:	cd 30                	int    $0x30
                "b" (a3),
                "D" (a4),
                "S" (a5)
                : "cc", "memory");

  if (check && ret > 0)
  802a17:	85 c0                	test   %eax,%eax
  802a19:	7e 28                	jle    802a43 <sys_ipc_recv+0x4a>
    panic("syscall %d returned %d (> 0)", num, ret);
  802a1b:	89 44 24 10          	mov    %eax,0x10(%esp)
  802a1f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  802a26:	00 
  802a27:	c7 44 24 08 3f 45 80 	movl   $0x80453f,0x8(%esp)
  802a2e:	00 
  802a2f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802a36:	00 
  802a37:	c7 04 24 5c 45 80 00 	movl   $0x80455c,(%esp)
  802a3e:	e8 68 f2 ff ff       	call   801cab <_panic>

int
sys_ipc_recv(void *dstva)
{
  return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  802a43:	83 c4 2c             	add    $0x2c,%esp
  802a46:	5b                   	pop    %ebx
  802a47:	5e                   	pop    %esi
  802a48:	5f                   	pop    %edi
  802a49:	5d                   	pop    %ebp
  802a4a:	c3                   	ret    

00802a4b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802a4b:	55                   	push   %ebp
  802a4c:	89 e5                	mov    %esp,%ebp
  802a4e:	83 ec 18             	sub    $0x18,%esp
  int r;

  if (_pgfault_handler == 0) {
  802a51:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  802a58:	75 70                	jne    802aca <set_pgfault_handler+0x7f>
    // First time through!
    // LAB 4: Your code here.
    if(sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_SYSCALL) < 0) {
  802a5a:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  802a61:	00 
  802a62:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802a69:	ee 
  802a6a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a71:	e8 6d fd ff ff       	call   8027e3 <sys_page_alloc>
  802a76:	85 c0                	test   %eax,%eax
  802a78:	79 1c                	jns    802a96 <set_pgfault_handler+0x4b>
      panic("In set_pgfault_handler, sys_page_alloc error");
  802a7a:	c7 44 24 08 6c 45 80 	movl   $0x80456c,0x8(%esp)
  802a81:	00 
  802a82:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  802a89:	00 
  802a8a:	c7 04 24 d5 45 80 00 	movl   $0x8045d5,(%esp)
  802a91:	e8 15 f2 ff ff       	call   801cab <_panic>
    }
    if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  802a96:	c7 44 24 04 d4 2a 80 	movl   $0x802ad4,0x4(%esp)
  802a9d:	00 
  802a9e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802aa5:	e8 d9 fe ff ff       	call   802983 <sys_env_set_pgfault_upcall>
  802aaa:	85 c0                	test   %eax,%eax
  802aac:	79 1c                	jns    802aca <set_pgfault_handler+0x7f>
      panic("In set_pgfault_handler, sys_env_set_pgfault_upcall error");
  802aae:	c7 44 24 08 9c 45 80 	movl   $0x80459c,0x8(%esp)
  802ab5:	00 
  802ab6:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  802abd:	00 
  802abe:	c7 04 24 d5 45 80 00 	movl   $0x8045d5,(%esp)
  802ac5:	e8 e1 f1 ff ff       	call   801cab <_panic>
    }
  }
  // Save handler pointer for assembly to call.
  _pgfault_handler = handler;
  802aca:	8b 45 08             	mov    0x8(%ebp),%eax
  802acd:	a3 10 a0 80 00       	mov    %eax,0x80a010
}
  802ad2:	c9                   	leave  
  802ad3:	c3                   	ret    

00802ad4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802ad4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802ad5:	a1 10 a0 80 00       	mov    0x80a010,%eax
	call *%eax
  802ada:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802adc:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
  subl $0x4, 0x30(%esp)
  802adf:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
  movl 0x30(%esp), %eax
  802ae4:	8b 44 24 30          	mov    0x30(%esp),%eax
  movl 0x28(%esp), %ebx
  802ae8:	8b 5c 24 28          	mov    0x28(%esp),%ebx
  movl %ebx, (%eax)
  802aec:	89 18                	mov    %ebx,(%eax)


	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
  addl $0x8, %esp
  802aee:	83 c4 08             	add    $0x8,%esp
  popal
  802af1:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
  addl $0x4, %esp
  802af2:	83 c4 04             	add    $0x4,%esp
  popfl
  802af5:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
  movl (%esp), %esp
  802af6:	8b 24 24             	mov    (%esp),%esp

  // Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  ret
  802af9:	c3                   	ret    

00802afa <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802afa:	55                   	push   %ebp
  802afb:	89 e5                	mov    %esp,%ebp
  802afd:	56                   	push   %esi
  802afe:	53                   	push   %ebx
  802aff:	83 ec 10             	sub    $0x10,%esp
  802b02:	8b 75 08             	mov    0x8(%ebp),%esi
  802b05:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b08:	8b 5d 10             	mov    0x10(%ebp),%ebx
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;
  802b0b:	85 c0                	test   %eax,%eax
  802b0d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802b12:	0f 44 c2             	cmove  %edx,%eax
  if ((r = sys_ipc_recv(pg)) < 0) {
  802b15:	89 04 24             	mov    %eax,(%esp)
  802b18:	e8 dc fe ff ff       	call   8029f9 <sys_ipc_recv>
  802b1d:	85 c0                	test   %eax,%eax
  802b1f:	79 34                	jns    802b55 <ipc_recv+0x5b>
    if (from_env_store)
  802b21:	85 f6                	test   %esi,%esi
  802b23:	74 06                	je     802b2b <ipc_recv+0x31>
      *from_env_store = 0;
  802b25:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (perm_store)
  802b2b:	85 db                	test   %ebx,%ebx
  802b2d:	74 06                	je     802b35 <ipc_recv+0x3b>
      *perm_store = 0;
  802b2f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    panic("sys_ipc_recv: %e", r);
  802b35:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802b39:	c7 44 24 08 e3 45 80 	movl   $0x8045e3,0x8(%esp)
  802b40:	00 
  802b41:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  802b48:	00 
  802b49:	c7 04 24 f4 45 80 00 	movl   $0x8045f4,(%esp)
  802b50:	e8 56 f1 ff ff       	call   801cab <_panic>
  }

  if (from_env_store)
  802b55:	85 f6                	test   %esi,%esi
  802b57:	74 0a                	je     802b63 <ipc_recv+0x69>
    *from_env_store = thisenv->env_ipc_from;
  802b59:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802b5e:	8b 40 74             	mov    0x74(%eax),%eax
  802b61:	89 06                	mov    %eax,(%esi)
  if (perm_store)
  802b63:	85 db                	test   %ebx,%ebx
  802b65:	74 0a                	je     802b71 <ipc_recv+0x77>
    *perm_store |= thisenv->env_ipc_perm;
  802b67:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802b6c:	8b 40 78             	mov    0x78(%eax),%eax
  802b6f:	09 03                	or     %eax,(%ebx)

  return thisenv->env_ipc_value;
  802b71:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802b76:	8b 40 70             	mov    0x70(%eax),%eax

}
  802b79:	83 c4 10             	add    $0x10,%esp
  802b7c:	5b                   	pop    %ebx
  802b7d:	5e                   	pop    %esi
  802b7e:	5d                   	pop    %ebp
  802b7f:	c3                   	ret    

00802b80 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802b80:	55                   	push   %ebp
  802b81:	89 e5                	mov    %esp,%ebp
  802b83:	57                   	push   %edi
  802b84:	56                   	push   %esi
  802b85:	53                   	push   %ebx
  802b86:	83 ec 1c             	sub    $0x1c,%esp
  802b89:	8b 7d 08             	mov    0x8(%ebp),%edi
  802b8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  802b8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;
  802b92:	85 db                	test   %ebx,%ebx
  802b94:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802b99:	0f 44 d8             	cmove  %eax,%ebx

  while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802b9c:	eb 2a                	jmp    802bc8 <ipc_send+0x48>
    if (r != -E_IPC_NOT_RECV)
  802b9e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802ba1:	74 20                	je     802bc3 <ipc_send+0x43>
      panic("ipc_send: %e", r);
  802ba3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802ba7:	c7 44 24 08 fe 45 80 	movl   $0x8045fe,0x8(%esp)
  802bae:	00 
  802baf:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  802bb6:	00 
  802bb7:	c7 04 24 f4 45 80 00 	movl   $0x8045f4,(%esp)
  802bbe:	e8 e8 f0 ff ff       	call   801cab <_panic>
    sys_yield();
  802bc3:	e8 fc fb ff ff       	call   8027c4 <sys_yield>
  // LAB 4: Your code here.
  int r;

  pg = pg ? pg : (void*)UTOP;

  while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802bc8:	8b 45 14             	mov    0x14(%ebp),%eax
  802bcb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802bcf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802bd3:	89 74 24 04          	mov    %esi,0x4(%esp)
  802bd7:	89 3c 24             	mov    %edi,(%esp)
  802bda:	e8 f7 fd ff ff       	call   8029d6 <sys_ipc_try_send>
  802bdf:	85 c0                	test   %eax,%eax
  802be1:	78 bb                	js     802b9e <ipc_send+0x1e>
    if (r != -E_IPC_NOT_RECV)
      panic("ipc_send: %e", r);
    sys_yield();
  }
}
  802be3:	83 c4 1c             	add    $0x1c,%esp
  802be6:	5b                   	pop    %ebx
  802be7:	5e                   	pop    %esi
  802be8:	5f                   	pop    %edi
  802be9:	5d                   	pop    %ebp
  802bea:	c3                   	ret    

00802beb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802beb:	55                   	push   %ebp
  802bec:	89 e5                	mov    %esp,%ebp
  802bee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int i;

  for (i = 0; i < NENV; i++)
  802bf1:	b8 00 00 00 00       	mov    $0x0,%eax
    if (envs[i].env_type == type)
  802bf6:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802bf9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802bff:	8b 52 50             	mov    0x50(%edx),%edx
  802c02:	39 ca                	cmp    %ecx,%edx
  802c04:	75 0d                	jne    802c13 <ipc_find_env+0x28>
      return envs[i].env_id;
  802c06:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802c09:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802c0e:	8b 40 40             	mov    0x40(%eax),%eax
  802c11:	eb 0e                	jmp    802c21 <ipc_find_env+0x36>
envid_t
ipc_find_env(enum EnvType type)
{
  int i;

  for (i = 0; i < NENV; i++)
  802c13:	83 c0 01             	add    $0x1,%eax
  802c16:	3d 00 04 00 00       	cmp    $0x400,%eax
  802c1b:	75 d9                	jne    802bf6 <ipc_find_env+0xb>
    if (envs[i].env_type == type)
      return envs[i].env_id;
  return 0;
  802c1d:	66 b8 00 00          	mov    $0x0,%ax
}
  802c21:	5d                   	pop    %ebp
  802c22:	c3                   	ret    
  802c23:	66 90                	xchg   %ax,%ax
  802c25:	66 90                	xchg   %ax,%ax
  802c27:	66 90                	xchg   %ax,%ax
  802c29:	66 90                	xchg   %ax,%ax
  802c2b:	66 90                	xchg   %ax,%ax
  802c2d:	66 90                	xchg   %ax,%ax
  802c2f:	90                   	nop

00802c30 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802c30:	55                   	push   %ebp
  802c31:	89 e5                	mov    %esp,%ebp
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  802c33:	8b 45 08             	mov    0x8(%ebp),%eax
  802c36:	05 00 00 00 30       	add    $0x30000000,%eax
  802c3b:	c1 e8 0c             	shr    $0xc,%eax
}
  802c3e:	5d                   	pop    %ebp
  802c3f:	c3                   	ret    

00802c40 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802c40:	55                   	push   %ebp
  802c41:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  802c43:	8b 45 08             	mov    0x8(%ebp),%eax
  802c46:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
  return INDEX2DATA(fd2num(fd));
  802c4b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  802c50:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  802c55:	5d                   	pop    %ebp
  802c56:	c3                   	ret    

00802c57 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802c57:	55                   	push   %ebp
  802c58:	89 e5                	mov    %esp,%ebp
  802c5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802c5d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
  int i;
  struct Fd *fd;

  for (i = 0; i < MAXFD; i++) {
    fd = INDEX2FD(i);
    if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  802c62:	89 c2                	mov    %eax,%edx
  802c64:	c1 ea 16             	shr    $0x16,%edx
  802c67:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802c6e:	f6 c2 01             	test   $0x1,%dl
  802c71:	74 11                	je     802c84 <fd_alloc+0x2d>
  802c73:	89 c2                	mov    %eax,%edx
  802c75:	c1 ea 0c             	shr    $0xc,%edx
  802c78:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802c7f:	f6 c2 01             	test   $0x1,%dl
  802c82:	75 09                	jne    802c8d <fd_alloc+0x36>
      *fd_store = fd;
  802c84:	89 01                	mov    %eax,(%ecx)
      return 0;
  802c86:	b8 00 00 00 00       	mov    $0x0,%eax
  802c8b:	eb 17                	jmp    802ca4 <fd_alloc+0x4d>
  802c8d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
  int i;
  struct Fd *fd;

  for (i = 0; i < MAXFD; i++) {
  802c92:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802c97:	75 c9                	jne    802c62 <fd_alloc+0xb>
    if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
      *fd_store = fd;
      return 0;
    }
  }
  *fd_store = 0;
  802c99:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
  return -E_MAX_OPEN;
  802c9f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  802ca4:	5d                   	pop    %ebp
  802ca5:	c3                   	ret    

00802ca6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802ca6:	55                   	push   %ebp
  802ca7:	89 e5                	mov    %esp,%ebp
  802ca9:	8b 45 08             	mov    0x8(%ebp),%eax
  struct Fd *fd;

  if (fdnum < 0 || fdnum >= MAXFD) {
  802cac:	83 f8 1f             	cmp    $0x1f,%eax
  802caf:	77 36                	ja     802ce7 <fd_lookup+0x41>
    if (debug)
      cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  fd = INDEX2FD(fdnum);
  802cb1:	c1 e0 0c             	shl    $0xc,%eax
  802cb4:	2d 00 00 00 30       	sub    $0x30000000,%eax
  if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802cb9:	89 c2                	mov    %eax,%edx
  802cbb:	c1 ea 16             	shr    $0x16,%edx
  802cbe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802cc5:	f6 c2 01             	test   $0x1,%dl
  802cc8:	74 24                	je     802cee <fd_lookup+0x48>
  802cca:	89 c2                	mov    %eax,%edx
  802ccc:	c1 ea 0c             	shr    $0xc,%edx
  802ccf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802cd6:	f6 c2 01             	test   $0x1,%dl
  802cd9:	74 1a                	je     802cf5 <fd_lookup+0x4f>
    if (debug)
      cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  *fd_store = fd;
  802cdb:	8b 55 0c             	mov    0xc(%ebp),%edx
  802cde:	89 02                	mov    %eax,(%edx)
  return 0;
  802ce0:	b8 00 00 00 00       	mov    $0x0,%eax
  802ce5:	eb 13                	jmp    802cfa <fd_lookup+0x54>
  struct Fd *fd;

  if (fdnum < 0 || fdnum >= MAXFD) {
    if (debug)
      cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  802ce7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802cec:	eb 0c                	jmp    802cfa <fd_lookup+0x54>
  }
  fd = INDEX2FD(fdnum);
  if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
    if (debug)
      cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  802cee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802cf3:	eb 05                	jmp    802cfa <fd_lookup+0x54>
  802cf5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  }
  *fd_store = fd;
  return 0;
}
  802cfa:	5d                   	pop    %ebp
  802cfb:	c3                   	ret    

00802cfc <dev_lookup>:
  0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802cfc:	55                   	push   %ebp
  802cfd:	89 e5                	mov    %esp,%ebp
  802cff:	83 ec 18             	sub    $0x18,%esp
  802d02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802d05:	ba 8c 46 80 00       	mov    $0x80468c,%edx
  int i;

  for (i = 0; devtab[i]; i++)
  802d0a:	eb 13                	jmp    802d1f <dev_lookup+0x23>
  802d0c:	83 c2 04             	add    $0x4,%edx
    if (devtab[i]->dev_id == dev_id) {
  802d0f:	39 08                	cmp    %ecx,(%eax)
  802d11:	75 0c                	jne    802d1f <dev_lookup+0x23>
      *dev = devtab[i];
  802d13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802d16:	89 01                	mov    %eax,(%ecx)
      return 0;
  802d18:	b8 00 00 00 00       	mov    $0x0,%eax
  802d1d:	eb 30                	jmp    802d4f <dev_lookup+0x53>
int
dev_lookup(int dev_id, struct Dev **dev)
{
  int i;

  for (i = 0; devtab[i]; i++)
  802d1f:	8b 02                	mov    (%edx),%eax
  802d21:	85 c0                	test   %eax,%eax
  802d23:	75 e7                	jne    802d0c <dev_lookup+0x10>
    if (devtab[i]->dev_id == dev_id) {
      *dev = devtab[i];
      return 0;
    }
  cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802d25:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802d2a:	8b 40 48             	mov    0x48(%eax),%eax
  802d2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802d31:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d35:	c7 04 24 0c 46 80 00 	movl   $0x80460c,(%esp)
  802d3c:	e8 63 f0 ff ff       	call   801da4 <cprintf>
  *dev = 0;
  802d41:	8b 45 0c             	mov    0xc(%ebp),%eax
  802d44:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  return -E_INVAL;
  802d4a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802d4f:	c9                   	leave  
  802d50:	c3                   	ret    

00802d51 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  802d51:	55                   	push   %ebp
  802d52:	89 e5                	mov    %esp,%ebp
  802d54:	56                   	push   %esi
  802d55:	53                   	push   %ebx
  802d56:	83 ec 20             	sub    $0x20,%esp
  802d59:	8b 75 08             	mov    0x8(%ebp),%esi
  802d5c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct Fd *fd2;
  struct Dev *dev;
  int r;

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802d5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d62:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  return ((uintptr_t)fd - FDTABLE) / PGSIZE;
  802d66:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  802d6c:	c1 e8 0c             	shr    $0xc,%eax
{
  struct Fd *fd2;
  struct Dev *dev;
  int r;

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802d6f:	89 04 24             	mov    %eax,(%esp)
  802d72:	e8 2f ff ff ff       	call   802ca6 <fd_lookup>
  802d77:	85 c0                	test   %eax,%eax
  802d79:	78 05                	js     802d80 <fd_close+0x2f>
      || fd != fd2)
  802d7b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802d7e:	74 0c                	je     802d8c <fd_close+0x3b>
    return must_exist ? r : 0;
  802d80:	84 db                	test   %bl,%bl
  802d82:	ba 00 00 00 00       	mov    $0x0,%edx
  802d87:	0f 44 c2             	cmove  %edx,%eax
  802d8a:	eb 3f                	jmp    802dcb <fd_close+0x7a>
  if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802d8c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d93:	8b 06                	mov    (%esi),%eax
  802d95:	89 04 24             	mov    %eax,(%esp)
  802d98:	e8 5f ff ff ff       	call   802cfc <dev_lookup>
  802d9d:	89 c3                	mov    %eax,%ebx
  802d9f:	85 c0                	test   %eax,%eax
  802da1:	78 16                	js     802db9 <fd_close+0x68>
    if (dev->dev_close)
  802da3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802da6:	8b 40 10             	mov    0x10(%eax),%eax
      r = (*dev->dev_close)(fd);
    else
      r = 0;
  802da9:	bb 00 00 00 00       	mov    $0x0,%ebx

  if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
      || fd != fd2)
    return must_exist ? r : 0;
  if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
    if (dev->dev_close)
  802dae:	85 c0                	test   %eax,%eax
  802db0:	74 07                	je     802db9 <fd_close+0x68>
      r = (*dev->dev_close)(fd);
  802db2:	89 34 24             	mov    %esi,(%esp)
  802db5:	ff d0                	call   *%eax
  802db7:	89 c3                	mov    %eax,%ebx
    else
      r = 0;
  }
  // Make sure fd is unmapped.  Might be a no-op if
  // (*dev->dev_close)(fd) already unmapped it.
  (void)sys_page_unmap(0, fd);
  802db9:	89 74 24 04          	mov    %esi,0x4(%esp)
  802dbd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802dc4:	e8 c1 fa ff ff       	call   80288a <sys_page_unmap>
  return r;
  802dc9:	89 d8                	mov    %ebx,%eax
}
  802dcb:	83 c4 20             	add    $0x20,%esp
  802dce:	5b                   	pop    %ebx
  802dcf:	5e                   	pop    %esi
  802dd0:	5d                   	pop    %ebp
  802dd1:	c3                   	ret    

00802dd2 <close>:
  return -E_INVAL;
}

int
close(int fdnum)
{
  802dd2:	55                   	push   %ebp
  802dd3:	89 e5                	mov    %esp,%ebp
  802dd5:	83 ec 28             	sub    $0x28,%esp
  struct Fd *fd;
  int r;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  802dd8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ddb:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ddf:	8b 45 08             	mov    0x8(%ebp),%eax
  802de2:	89 04 24             	mov    %eax,(%esp)
  802de5:	e8 bc fe ff ff       	call   802ca6 <fd_lookup>
  802dea:	89 c2                	mov    %eax,%edx
  802dec:	85 d2                	test   %edx,%edx
  802dee:	78 13                	js     802e03 <close+0x31>
    return r;
  else
    return fd_close(fd, 1);
  802df0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802df7:	00 
  802df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802dfb:	89 04 24             	mov    %eax,(%esp)
  802dfe:	e8 4e ff ff ff       	call   802d51 <fd_close>
}
  802e03:	c9                   	leave  
  802e04:	c3                   	ret    

00802e05 <close_all>:

void
close_all(void)
{
  802e05:	55                   	push   %ebp
  802e06:	89 e5                	mov    %esp,%ebp
  802e08:	53                   	push   %ebx
  802e09:	83 ec 14             	sub    $0x14,%esp
  int i;

  for (i = 0; i < MAXFD; i++)
  802e0c:	bb 00 00 00 00       	mov    $0x0,%ebx
    close(i);
  802e11:	89 1c 24             	mov    %ebx,(%esp)
  802e14:	e8 b9 ff ff ff       	call   802dd2 <close>
void
close_all(void)
{
  int i;

  for (i = 0; i < MAXFD; i++)
  802e19:	83 c3 01             	add    $0x1,%ebx
  802e1c:	83 fb 20             	cmp    $0x20,%ebx
  802e1f:	75 f0                	jne    802e11 <close_all+0xc>
    close(i);
}
  802e21:	83 c4 14             	add    $0x14,%esp
  802e24:	5b                   	pop    %ebx
  802e25:	5d                   	pop    %ebp
  802e26:	c3                   	ret    

00802e27 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802e27:	55                   	push   %ebp
  802e28:	89 e5                	mov    %esp,%ebp
  802e2a:	57                   	push   %edi
  802e2b:	56                   	push   %esi
  802e2c:	53                   	push   %ebx
  802e2d:	83 ec 3c             	sub    $0x3c,%esp
  int r;
  char *ova, *nva;
  pte_t pte;
  struct Fd *oldfd, *newfd;

  if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802e30:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802e33:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e37:	8b 45 08             	mov    0x8(%ebp),%eax
  802e3a:	89 04 24             	mov    %eax,(%esp)
  802e3d:	e8 64 fe ff ff       	call   802ca6 <fd_lookup>
  802e42:	89 c2                	mov    %eax,%edx
  802e44:	85 d2                	test   %edx,%edx
  802e46:	0f 88 e1 00 00 00    	js     802f2d <dup+0x106>
    return r;
  close(newfdnum);
  802e4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e4f:	89 04 24             	mov    %eax,(%esp)
  802e52:	e8 7b ff ff ff       	call   802dd2 <close>

  newfd = INDEX2FD(newfdnum);
  802e57:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802e5a:	c1 e3 0c             	shl    $0xc,%ebx
  802e5d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
  ova = fd2data(oldfd);
  802e63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802e66:	89 04 24             	mov    %eax,(%esp)
  802e69:	e8 d2 fd ff ff       	call   802c40 <fd2data>
  802e6e:	89 c6                	mov    %eax,%esi
  nva = fd2data(newfd);
  802e70:	89 1c 24             	mov    %ebx,(%esp)
  802e73:	e8 c8 fd ff ff       	call   802c40 <fd2data>
  802e78:	89 c7                	mov    %eax,%edi

  if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802e7a:	89 f0                	mov    %esi,%eax
  802e7c:	c1 e8 16             	shr    $0x16,%eax
  802e7f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802e86:	a8 01                	test   $0x1,%al
  802e88:	74 43                	je     802ecd <dup+0xa6>
  802e8a:	89 f0                	mov    %esi,%eax
  802e8c:	c1 e8 0c             	shr    $0xc,%eax
  802e8f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802e96:	f6 c2 01             	test   $0x1,%dl
  802e99:	74 32                	je     802ecd <dup+0xa6>
    if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802e9b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802ea2:	25 07 0e 00 00       	and    $0xe07,%eax
  802ea7:	89 44 24 10          	mov    %eax,0x10(%esp)
  802eab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802eaf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802eb6:	00 
  802eb7:	89 74 24 04          	mov    %esi,0x4(%esp)
  802ebb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ec2:	e8 70 f9 ff ff       	call   802837 <sys_page_map>
  802ec7:	89 c6                	mov    %eax,%esi
  802ec9:	85 c0                	test   %eax,%eax
  802ecb:	78 3e                	js     802f0b <dup+0xe4>
      goto err;
  if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802ecd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802ed0:	89 c2                	mov    %eax,%edx
  802ed2:	c1 ea 0c             	shr    $0xc,%edx
  802ed5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802edc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  802ee2:	89 54 24 10          	mov    %edx,0x10(%esp)
  802ee6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802eea:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802ef1:	00 
  802ef2:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ef6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802efd:	e8 35 f9 ff ff       	call   802837 <sys_page_map>
  802f02:	89 c6                	mov    %eax,%esi
    goto err;

  return newfdnum;
  802f04:	8b 45 0c             	mov    0xc(%ebp),%eax
  nva = fd2data(newfd);

  if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
    if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
      goto err;
  if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802f07:	85 f6                	test   %esi,%esi
  802f09:	79 22                	jns    802f2d <dup+0x106>
    goto err;

  return newfdnum;

err:
  sys_page_unmap(0, newfd);
  802f0b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802f0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f16:	e8 6f f9 ff ff       	call   80288a <sys_page_unmap>
  sys_page_unmap(0, nva);
  802f1b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802f1f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f26:	e8 5f f9 ff ff       	call   80288a <sys_page_unmap>
  return r;
  802f2b:	89 f0                	mov    %esi,%eax
}
  802f2d:	83 c4 3c             	add    $0x3c,%esp
  802f30:	5b                   	pop    %ebx
  802f31:	5e                   	pop    %esi
  802f32:	5f                   	pop    %edi
  802f33:	5d                   	pop    %ebp
  802f34:	c3                   	ret    

00802f35 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802f35:	55                   	push   %ebp
  802f36:	89 e5                	mov    %esp,%ebp
  802f38:	53                   	push   %ebx
  802f39:	83 ec 24             	sub    $0x24,%esp
  802f3c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  802f3f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802f42:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f46:	89 1c 24             	mov    %ebx,(%esp)
  802f49:	e8 58 fd ff ff       	call   802ca6 <fd_lookup>
  802f4e:	89 c2                	mov    %eax,%edx
  802f50:	85 d2                	test   %edx,%edx
  802f52:	78 6d                	js     802fc1 <read+0x8c>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802f54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802f57:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f5e:	8b 00                	mov    (%eax),%eax
  802f60:	89 04 24             	mov    %eax,(%esp)
  802f63:	e8 94 fd ff ff       	call   802cfc <dev_lookup>
  802f68:	85 c0                	test   %eax,%eax
  802f6a:	78 55                	js     802fc1 <read+0x8c>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802f6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f6f:	8b 50 08             	mov    0x8(%eax),%edx
  802f72:	83 e2 03             	and    $0x3,%edx
  802f75:	83 fa 01             	cmp    $0x1,%edx
  802f78:	75 23                	jne    802f9d <read+0x68>
    cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802f7a:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802f7f:	8b 40 48             	mov    0x48(%eax),%eax
  802f82:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802f86:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f8a:	c7 04 24 50 46 80 00 	movl   $0x804650,(%esp)
  802f91:	e8 0e ee ff ff       	call   801da4 <cprintf>
    return -E_INVAL;
  802f96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802f9b:	eb 24                	jmp    802fc1 <read+0x8c>
  }
  if (!dev->dev_read)
  802f9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802fa0:	8b 52 08             	mov    0x8(%edx),%edx
  802fa3:	85 d2                	test   %edx,%edx
  802fa5:	74 15                	je     802fbc <read+0x87>
    return -E_NOT_SUPP;
  return (*dev->dev_read)(fd, buf, n);
  802fa7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  802faa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802fae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802fb1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802fb5:	89 04 24             	mov    %eax,(%esp)
  802fb8:	ff d2                	call   *%edx
  802fba:	eb 05                	jmp    802fc1 <read+0x8c>
  if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
    cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  if (!dev->dev_read)
    return -E_NOT_SUPP;
  802fbc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_read)(fd, buf, n);
}
  802fc1:	83 c4 24             	add    $0x24,%esp
  802fc4:	5b                   	pop    %ebx
  802fc5:	5d                   	pop    %ebp
  802fc6:	c3                   	ret    

00802fc7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802fc7:	55                   	push   %ebp
  802fc8:	89 e5                	mov    %esp,%ebp
  802fca:	57                   	push   %edi
  802fcb:	56                   	push   %esi
  802fcc:	53                   	push   %ebx
  802fcd:	83 ec 1c             	sub    $0x1c,%esp
  802fd0:	8b 7d 08             	mov    0x8(%ebp),%edi
  802fd3:	8b 75 10             	mov    0x10(%ebp),%esi
  int m, tot;

  for (tot = 0; tot < n; tot += m) {
  802fd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  802fdb:	eb 23                	jmp    803000 <readn+0x39>
    m = read(fdnum, (char*)buf + tot, n - tot);
  802fdd:	89 f0                	mov    %esi,%eax
  802fdf:	29 d8                	sub    %ebx,%eax
  802fe1:	89 44 24 08          	mov    %eax,0x8(%esp)
  802fe5:	89 d8                	mov    %ebx,%eax
  802fe7:	03 45 0c             	add    0xc(%ebp),%eax
  802fea:	89 44 24 04          	mov    %eax,0x4(%esp)
  802fee:	89 3c 24             	mov    %edi,(%esp)
  802ff1:	e8 3f ff ff ff       	call   802f35 <read>
    if (m < 0)
  802ff6:	85 c0                	test   %eax,%eax
  802ff8:	78 10                	js     80300a <readn+0x43>
      return m;
    if (m == 0)
  802ffa:	85 c0                	test   %eax,%eax
  802ffc:	74 0a                	je     803008 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
  int m, tot;

  for (tot = 0; tot < n; tot += m) {
  802ffe:	01 c3                	add    %eax,%ebx
  803000:	39 f3                	cmp    %esi,%ebx
  803002:	72 d9                	jb     802fdd <readn+0x16>
  803004:	89 d8                	mov    %ebx,%eax
  803006:	eb 02                	jmp    80300a <readn+0x43>
  803008:	89 d8                	mov    %ebx,%eax
      return m;
    if (m == 0)
      break;
  }
  return tot;
}
  80300a:	83 c4 1c             	add    $0x1c,%esp
  80300d:	5b                   	pop    %ebx
  80300e:	5e                   	pop    %esi
  80300f:	5f                   	pop    %edi
  803010:	5d                   	pop    %ebp
  803011:	c3                   	ret    

00803012 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  803012:	55                   	push   %ebp
  803013:	89 e5                	mov    %esp,%ebp
  803015:	53                   	push   %ebx
  803016:	83 ec 24             	sub    $0x24,%esp
  803019:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  80301c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80301f:	89 44 24 04          	mov    %eax,0x4(%esp)
  803023:	89 1c 24             	mov    %ebx,(%esp)
  803026:	e8 7b fc ff ff       	call   802ca6 <fd_lookup>
  80302b:	89 c2                	mov    %eax,%edx
  80302d:	85 d2                	test   %edx,%edx
  80302f:	78 68                	js     803099 <write+0x87>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  803031:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803034:	89 44 24 04          	mov    %eax,0x4(%esp)
  803038:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80303b:	8b 00                	mov    (%eax),%eax
  80303d:	89 04 24             	mov    %eax,(%esp)
  803040:	e8 b7 fc ff ff       	call   802cfc <dev_lookup>
  803045:	85 c0                	test   %eax,%eax
  803047:	78 50                	js     803099 <write+0x87>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  803049:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80304c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  803050:	75 23                	jne    803075 <write+0x63>
    cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  803052:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  803057:	8b 40 48             	mov    0x48(%eax),%eax
  80305a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80305e:	89 44 24 04          	mov    %eax,0x4(%esp)
  803062:	c7 04 24 6c 46 80 00 	movl   $0x80466c,(%esp)
  803069:	e8 36 ed ff ff       	call   801da4 <cprintf>
    return -E_INVAL;
  80306e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  803073:	eb 24                	jmp    803099 <write+0x87>
  }
  if (debug)
    cprintf("write %d %p %d via dev %s\n",
            fdnum, buf, n, dev->dev_name);
  if (!dev->dev_write)
  803075:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803078:	8b 52 0c             	mov    0xc(%edx),%edx
  80307b:	85 d2                	test   %edx,%edx
  80307d:	74 15                	je     803094 <write+0x82>
    return -E_NOT_SUPP;
  return (*dev->dev_write)(fd, buf, n);
  80307f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  803082:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803086:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803089:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80308d:	89 04 24             	mov    %eax,(%esp)
  803090:	ff d2                	call   *%edx
  803092:	eb 05                	jmp    803099 <write+0x87>
  }
  if (debug)
    cprintf("write %d %p %d via dev %s\n",
            fdnum, buf, n, dev->dev_name);
  if (!dev->dev_write)
    return -E_NOT_SUPP;
  803094:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_write)(fd, buf, n);
}
  803099:	83 c4 24             	add    $0x24,%esp
  80309c:	5b                   	pop    %ebx
  80309d:	5d                   	pop    %ebp
  80309e:	c3                   	ret    

0080309f <seek>:

int
seek(int fdnum, off_t offset)
{
  80309f:	55                   	push   %ebp
  8030a0:	89 e5                	mov    %esp,%ebp
  8030a2:	83 ec 18             	sub    $0x18,%esp
  int r;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  8030a5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8030a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8030af:	89 04 24             	mov    %eax,(%esp)
  8030b2:	e8 ef fb ff ff       	call   802ca6 <fd_lookup>
  8030b7:	85 c0                	test   %eax,%eax
  8030b9:	78 0e                	js     8030c9 <seek+0x2a>
    return r;
  fd->fd_offset = offset;
  8030bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8030be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8030c1:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
  8030c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8030c9:	c9                   	leave  
  8030ca:	c3                   	ret    

008030cb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8030cb:	55                   	push   %ebp
  8030cc:	89 e5                	mov    %esp,%ebp
  8030ce:	53                   	push   %ebx
  8030cf:	83 ec 24             	sub    $0x24,%esp
  8030d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  8030d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8030d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030dc:	89 1c 24             	mov    %ebx,(%esp)
  8030df:	e8 c2 fb ff ff       	call   802ca6 <fd_lookup>
  8030e4:	89 c2                	mov    %eax,%edx
  8030e6:	85 d2                	test   %edx,%edx
  8030e8:	78 61                	js     80314b <ftruncate+0x80>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8030ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8030ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8030f4:	8b 00                	mov    (%eax),%eax
  8030f6:	89 04 24             	mov    %eax,(%esp)
  8030f9:	e8 fe fb ff ff       	call   802cfc <dev_lookup>
  8030fe:	85 c0                	test   %eax,%eax
  803100:	78 49                	js     80314b <ftruncate+0x80>
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  803102:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803105:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  803109:	75 23                	jne    80312e <ftruncate+0x63>
    cprintf("[%08x] ftruncate %d -- bad mode\n",
            thisenv->env_id, fdnum);
  80310b:	a1 0c a0 80 00       	mov    0x80a00c,%eax

  if ((r = fd_lookup(fdnum, &fd)) < 0
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
    return r;
  if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
    cprintf("[%08x] ftruncate %d -- bad mode\n",
  803110:	8b 40 48             	mov    0x48(%eax),%eax
  803113:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803117:	89 44 24 04          	mov    %eax,0x4(%esp)
  80311b:	c7 04 24 2c 46 80 00 	movl   $0x80462c,(%esp)
  803122:	e8 7d ec ff ff       	call   801da4 <cprintf>
            thisenv->env_id, fdnum);
    return -E_INVAL;
  803127:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80312c:	eb 1d                	jmp    80314b <ftruncate+0x80>
  }
  if (!dev->dev_trunc)
  80312e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803131:	8b 52 18             	mov    0x18(%edx),%edx
  803134:	85 d2                	test   %edx,%edx
  803136:	74 0e                	je     803146 <ftruncate+0x7b>
    return -E_NOT_SUPP;
  return (*dev->dev_trunc)(fd, newsize);
  803138:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80313b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80313f:	89 04 24             	mov    %eax,(%esp)
  803142:	ff d2                	call   *%edx
  803144:	eb 05                	jmp    80314b <ftruncate+0x80>
    cprintf("[%08x] ftruncate %d -- bad mode\n",
            thisenv->env_id, fdnum);
    return -E_INVAL;
  }
  if (!dev->dev_trunc)
    return -E_NOT_SUPP;
  803146:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  return (*dev->dev_trunc)(fd, newsize);
}
  80314b:	83 c4 24             	add    $0x24,%esp
  80314e:	5b                   	pop    %ebx
  80314f:	5d                   	pop    %ebp
  803150:	c3                   	ret    

00803151 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  803151:	55                   	push   %ebp
  803152:	89 e5                	mov    %esp,%ebp
  803154:	53                   	push   %ebx
  803155:	83 ec 24             	sub    $0x24,%esp
  803158:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int r;
  struct Dev *dev;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0
  80315b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80315e:	89 44 24 04          	mov    %eax,0x4(%esp)
  803162:	8b 45 08             	mov    0x8(%ebp),%eax
  803165:	89 04 24             	mov    %eax,(%esp)
  803168:	e8 39 fb ff ff       	call   802ca6 <fd_lookup>
  80316d:	89 c2                	mov    %eax,%edx
  80316f:	85 d2                	test   %edx,%edx
  803171:	78 52                	js     8031c5 <fstat+0x74>
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  803173:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803176:	89 44 24 04          	mov    %eax,0x4(%esp)
  80317a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80317d:	8b 00                	mov    (%eax),%eax
  80317f:	89 04 24             	mov    %eax,(%esp)
  803182:	e8 75 fb ff ff       	call   802cfc <dev_lookup>
  803187:	85 c0                	test   %eax,%eax
  803189:	78 3a                	js     8031c5 <fstat+0x74>
    return r;
  if (!dev->dev_stat)
  80318b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80318e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  803192:	74 2c                	je     8031c0 <fstat+0x6f>
    return -E_NOT_SUPP;
  stat->st_name[0] = 0;
  803194:	c6 03 00             	movb   $0x0,(%ebx)
  stat->st_size = 0;
  803197:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80319e:	00 00 00 
  stat->st_isdir = 0;
  8031a1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8031a8:	00 00 00 
  stat->st_dev = dev;
  8031ab:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
  return (*dev->dev_stat)(fd, stat);
  8031b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8031b5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8031b8:	89 14 24             	mov    %edx,(%esp)
  8031bb:	ff 50 14             	call   *0x14(%eax)
  8031be:	eb 05                	jmp    8031c5 <fstat+0x74>

  if ((r = fd_lookup(fdnum, &fd)) < 0
      || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
    return r;
  if (!dev->dev_stat)
    return -E_NOT_SUPP;
  8031c0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  stat->st_name[0] = 0;
  stat->st_size = 0;
  stat->st_isdir = 0;
  stat->st_dev = dev;
  return (*dev->dev_stat)(fd, stat);
}
  8031c5:	83 c4 24             	add    $0x24,%esp
  8031c8:	5b                   	pop    %ebx
  8031c9:	5d                   	pop    %ebp
  8031ca:	c3                   	ret    

008031cb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8031cb:	55                   	push   %ebp
  8031cc:	89 e5                	mov    %esp,%ebp
  8031ce:	56                   	push   %esi
  8031cf:	53                   	push   %ebx
  8031d0:	83 ec 10             	sub    $0x10,%esp
  int fd, r;

  if ((fd = open(path, O_RDONLY)) < 0)
  8031d3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8031da:	00 
  8031db:	8b 45 08             	mov    0x8(%ebp),%eax
  8031de:	89 04 24             	mov    %eax,(%esp)
  8031e1:	e8 d2 01 00 00       	call   8033b8 <open>
  8031e6:	89 c3                	mov    %eax,%ebx
  8031e8:	85 db                	test   %ebx,%ebx
  8031ea:	78 1b                	js     803207 <stat+0x3c>
    return fd;
  r = fstat(fd, stat);
  8031ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8031ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031f3:	89 1c 24             	mov    %ebx,(%esp)
  8031f6:	e8 56 ff ff ff       	call   803151 <fstat>
  8031fb:	89 c6                	mov    %eax,%esi
  close(fd);
  8031fd:	89 1c 24             	mov    %ebx,(%esp)
  803200:	e8 cd fb ff ff       	call   802dd2 <close>
  return r;
  803205:	89 f0                	mov    %esi,%eax
}
  803207:	83 c4 10             	add    $0x10,%esp
  80320a:	5b                   	pop    %ebx
  80320b:	5e                   	pop    %esi
  80320c:	5d                   	pop    %ebp
  80320d:	c3                   	ret    

0080320e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80320e:	55                   	push   %ebp
  80320f:	89 e5                	mov    %esp,%ebp
  803211:	56                   	push   %esi
  803212:	53                   	push   %ebx
  803213:	83 ec 10             	sub    $0x10,%esp
  803216:	89 c6                	mov    %eax,%esi
  803218:	89 d3                	mov    %edx,%ebx
  static envid_t fsenv;

  if (fsenv == 0)
  80321a:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  803221:	75 11                	jne    803234 <fsipc+0x26>
    fsenv = ipc_find_env(ENV_TYPE_FS);
  803223:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80322a:	e8 bc f9 ff ff       	call   802beb <ipc_find_env>
  80322f:	a3 00 a0 80 00       	mov    %eax,0x80a000
  static_assert(sizeof(fsipcbuf) == PGSIZE);

  if (debug)
    cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t*)&fsipcbuf);

  ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  803234:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80323b:	00 
  80323c:	c7 44 24 08 00 b0 80 	movl   $0x80b000,0x8(%esp)
  803243:	00 
  803244:	89 74 24 04          	mov    %esi,0x4(%esp)
  803248:	a1 00 a0 80 00       	mov    0x80a000,%eax
  80324d:	89 04 24             	mov    %eax,(%esp)
  803250:	e8 2b f9 ff ff       	call   802b80 <ipc_send>
  return ipc_recv(NULL, dstva, NULL);
  803255:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80325c:	00 
  80325d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803261:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803268:	e8 8d f8 ff ff       	call   802afa <ipc_recv>
}
  80326d:	83 c4 10             	add    $0x10,%esp
  803270:	5b                   	pop    %ebx
  803271:	5e                   	pop    %esi
  803272:	5d                   	pop    %ebp
  803273:	c3                   	ret    

00803274 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  803274:	55                   	push   %ebp
  803275:	89 e5                	mov    %esp,%ebp
  803277:	83 ec 08             	sub    $0x8,%esp
  fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80327a:	8b 45 08             	mov    0x8(%ebp),%eax
  80327d:	8b 40 0c             	mov    0xc(%eax),%eax
  803280:	a3 00 b0 80 00       	mov    %eax,0x80b000
  fsipcbuf.set_size.req_size = newsize;
  803285:	8b 45 0c             	mov    0xc(%ebp),%eax
  803288:	a3 04 b0 80 00       	mov    %eax,0x80b004
  return fsipc(FSREQ_SET_SIZE, NULL);
  80328d:	ba 00 00 00 00       	mov    $0x0,%edx
  803292:	b8 02 00 00 00       	mov    $0x2,%eax
  803297:	e8 72 ff ff ff       	call   80320e <fsipc>
}
  80329c:	c9                   	leave  
  80329d:	c3                   	ret    

0080329e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80329e:	55                   	push   %ebp
  80329f:	89 e5                	mov    %esp,%ebp
  8032a1:	83 ec 08             	sub    $0x8,%esp
  fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8032a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8032a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8032aa:	a3 00 b0 80 00       	mov    %eax,0x80b000
  return fsipc(FSREQ_FLUSH, NULL);
  8032af:	ba 00 00 00 00       	mov    $0x0,%edx
  8032b4:	b8 06 00 00 00       	mov    $0x6,%eax
  8032b9:	e8 50 ff ff ff       	call   80320e <fsipc>
}
  8032be:	c9                   	leave  
  8032bf:	c3                   	ret    

008032c0 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8032c0:	55                   	push   %ebp
  8032c1:	89 e5                	mov    %esp,%ebp
  8032c3:	53                   	push   %ebx
  8032c4:	83 ec 14             	sub    $0x14,%esp
  8032c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  int r;

  fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8032ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8032cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8032d0:	a3 00 b0 80 00       	mov    %eax,0x80b000
  if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8032d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8032da:	b8 05 00 00 00       	mov    $0x5,%eax
  8032df:	e8 2a ff ff ff       	call   80320e <fsipc>
  8032e4:	89 c2                	mov    %eax,%edx
  8032e6:	85 d2                	test   %edx,%edx
  8032e8:	78 2b                	js     803315 <devfile_stat+0x55>
    return r;
  strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8032ea:	c7 44 24 04 00 b0 80 	movl   $0x80b000,0x4(%esp)
  8032f1:	00 
  8032f2:	89 1c 24             	mov    %ebx,(%esp)
  8032f5:	e8 cd f0 ff ff       	call   8023c7 <strcpy>
  st->st_size = fsipcbuf.statRet.ret_size;
  8032fa:	a1 80 b0 80 00       	mov    0x80b080,%eax
  8032ff:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  st->st_isdir = fsipcbuf.statRet.ret_isdir;
  803305:	a1 84 b0 80 00       	mov    0x80b084,%eax
  80330a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  return 0;
  803310:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803315:	83 c4 14             	add    $0x14,%esp
  803318:	5b                   	pop    %ebx
  803319:	5d                   	pop    %ebp
  80331a:	c3                   	ret    

0080331b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80331b:	55                   	push   %ebp
  80331c:	89 e5                	mov    %esp,%ebp
  80331e:	83 ec 18             	sub    $0x18,%esp
  803321:	8b 45 10             	mov    0x10(%ebp),%eax
  // remember that write is always allowed to write *fewer*
  // bytes than requested.
  // LAB 5: Your code here
    int r;

    fsipcbuf.write.req_fileid = fd->fd_file.id;
  803324:	8b 55 08             	mov    0x8(%ebp),%edx
  803327:	8b 52 0c             	mov    0xc(%edx),%edx
  80332a:	89 15 00 b0 80 00    	mov    %edx,0x80b000
    fsipcbuf.write.req_n = n;
  803330:	a3 04 b0 80 00       	mov    %eax,0x80b004

    size_t max_written = sizeof(fsipcbuf.write.req_buf);
    memmove(fsipcbuf.write.req_buf, buf, MIN(max_written, n));
  803335:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80333a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80333f:	0f 47 c2             	cmova  %edx,%eax
  803342:	89 44 24 08          	mov    %eax,0x8(%esp)
  803346:	8b 45 0c             	mov    0xc(%ebp),%eax
  803349:	89 44 24 04          	mov    %eax,0x4(%esp)
  80334d:	c7 04 24 08 b0 80 00 	movl   $0x80b008,(%esp)
  803354:	e8 0b f2 ff ff       	call   802564 <memmove>

    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  803359:	ba 00 00 00 00       	mov    $0x0,%edx
  80335e:	b8 04 00 00 00       	mov    $0x4,%eax
  803363:	e8 a6 fe ff ff       	call   80320e <fsipc>
        return r;

    return r;
}
  803368:	c9                   	leave  
  803369:	c3                   	ret    

0080336a <devfile_read>:
// Returns:
//  The number of bytes successfully read.
//  < 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80336a:	55                   	push   %ebp
  80336b:	89 e5                	mov    %esp,%ebp
  80336d:	53                   	push   %ebx
  80336e:	83 ec 14             	sub    $0x14,%esp
  // filling fsipcbuf.read with the request arguments.  The
  // bytes read will be written back to fsipcbuf by the file
  // system server.
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  803371:	8b 45 08             	mov    0x8(%ebp),%eax
  803374:	8b 40 0c             	mov    0xc(%eax),%eax
  803377:	a3 00 b0 80 00       	mov    %eax,0x80b000
  fsipcbuf.read.req_n = n;
  80337c:	8b 45 10             	mov    0x10(%ebp),%eax
  80337f:	a3 04 b0 80 00       	mov    %eax,0x80b004
  if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  803384:	ba 00 00 00 00       	mov    $0x0,%edx
  803389:	b8 03 00 00 00       	mov    $0x3,%eax
  80338e:	e8 7b fe ff ff       	call   80320e <fsipc>
  803393:	89 c3                	mov    %eax,%ebx
  803395:	85 c0                	test   %eax,%eax
  803397:	78 17                	js     8033b0 <devfile_read+0x46>
    return r;

  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  803399:	89 44 24 08          	mov    %eax,0x8(%esp)
  80339d:	c7 44 24 04 00 b0 80 	movl   $0x80b000,0x4(%esp)
  8033a4:	00 
  8033a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8033a8:	89 04 24             	mov    %eax,(%esp)
  8033ab:	e8 b4 f1 ff ff       	call   802564 <memmove>
  return r;
}
  8033b0:	89 d8                	mov    %ebx,%eax
  8033b2:	83 c4 14             	add    $0x14,%esp
  8033b5:	5b                   	pop    %ebx
  8033b6:	5d                   	pop    %ebp
  8033b7:	c3                   	ret    

008033b8 <open>:
//  The file descriptor index on success
//  -E_BAD_PATH if the path is too long (>= MAXPATHLEN)
//  < 0 for other errors.
int
open(const char *path, int mode)
{
  8033b8:	55                   	push   %ebp
  8033b9:	89 e5                	mov    %esp,%ebp
  8033bb:	53                   	push   %ebx
  8033bc:	83 ec 24             	sub    $0x24,%esp
  8033bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  // file descriptor.

  int r;
  struct Fd *fd;

  if (strlen(path) >= MAXPATHLEN)
  8033c2:	89 1c 24             	mov    %ebx,(%esp)
  8033c5:	e8 c6 ef ff ff       	call   802390 <strlen>
  8033ca:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8033cf:	7f 60                	jg     803431 <open+0x79>
    return -E_BAD_PATH;

  if ((r = fd_alloc(&fd)) < 0)
  8033d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8033d4:	89 04 24             	mov    %eax,(%esp)
  8033d7:	e8 7b f8 ff ff       	call   802c57 <fd_alloc>
  8033dc:	89 c2                	mov    %eax,%edx
  8033de:	85 d2                	test   %edx,%edx
  8033e0:	78 54                	js     803436 <open+0x7e>
    return r;

  strcpy(fsipcbuf.open.req_path, path);
  8033e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8033e6:	c7 04 24 00 b0 80 00 	movl   $0x80b000,(%esp)
  8033ed:	e8 d5 ef ff ff       	call   8023c7 <strcpy>
  fsipcbuf.open.req_omode = mode;
  8033f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8033f5:	a3 00 b4 80 00       	mov    %eax,0x80b400

  if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8033fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8033fd:	b8 01 00 00 00       	mov    $0x1,%eax
  803402:	e8 07 fe ff ff       	call   80320e <fsipc>
  803407:	89 c3                	mov    %eax,%ebx
  803409:	85 c0                	test   %eax,%eax
  80340b:	79 17                	jns    803424 <open+0x6c>
    fd_close(fd, 0);
  80340d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  803414:	00 
  803415:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803418:	89 04 24             	mov    %eax,(%esp)
  80341b:	e8 31 f9 ff ff       	call   802d51 <fd_close>
    return r;
  803420:	89 d8                	mov    %ebx,%eax
  803422:	eb 12                	jmp    803436 <open+0x7e>
  }

  return fd2num(fd);
  803424:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803427:	89 04 24             	mov    %eax,(%esp)
  80342a:	e8 01 f8 ff ff       	call   802c30 <fd2num>
  80342f:	eb 05                	jmp    803436 <open+0x7e>

  int r;
  struct Fd *fd;

  if (strlen(path) >= MAXPATHLEN)
    return -E_BAD_PATH;
  803431:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
    fd_close(fd, 0);
    return r;
  }

  return fd2num(fd);
}
  803436:	83 c4 24             	add    $0x24,%esp
  803439:	5b                   	pop    %ebx
  80343a:	5d                   	pop    %ebp
  80343b:	c3                   	ret    

0080343c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80343c:	55                   	push   %ebp
  80343d:	89 e5                	mov    %esp,%ebp
  80343f:	83 ec 08             	sub    $0x8,%esp
  // Ask the file server to update the disk
  // by writing any dirty blocks in the buffer cache.

  return fsipc(FSREQ_SYNC, NULL);
  803442:	ba 00 00 00 00       	mov    $0x0,%edx
  803447:	b8 08 00 00 00       	mov    $0x8,%eax
  80344c:	e8 bd fd ff ff       	call   80320e <fsipc>
}
  803451:	c9                   	leave  
  803452:	c3                   	ret    

00803453 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803453:	55                   	push   %ebp
  803454:	89 e5                	mov    %esp,%ebp
  803456:	8b 55 08             	mov    0x8(%ebp),%edx
  pte_t pte;

  if (!(uvpd[PDX(v)] & PTE_P))
  803459:	89 d0                	mov    %edx,%eax
  80345b:	c1 e8 16             	shr    $0x16,%eax
  80345e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
    return 0;
  803465:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
  pte_t pte;

  if (!(uvpd[PDX(v)] & PTE_P))
  80346a:	f6 c1 01             	test   $0x1,%cl
  80346d:	74 1d                	je     80348c <pageref+0x39>
    return 0;
  pte = uvpt[PGNUM(v)];
  80346f:	c1 ea 0c             	shr    $0xc,%edx
  803472:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  if (!(pte & PTE_P))
  803479:	f6 c2 01             	test   $0x1,%dl
  80347c:	74 0e                	je     80348c <pageref+0x39>
    return 0;
  return pages[PGNUM(pte)].pp_ref;
  80347e:	c1 ea 0c             	shr    $0xc,%edx
  803481:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  803488:	ef 
  803489:	0f b7 c0             	movzwl %ax,%eax
}
  80348c:	5d                   	pop    %ebp
  80348d:	c3                   	ret    

0080348e <devpipe_stat>:
  return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80348e:	55                   	push   %ebp
  80348f:	89 e5                	mov    %esp,%ebp
  803491:	56                   	push   %esi
  803492:	53                   	push   %ebx
  803493:	83 ec 10             	sub    $0x10,%esp
  803496:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct Pipe *p = (struct Pipe*)fd2data(fd);
  803499:	8b 45 08             	mov    0x8(%ebp),%eax
  80349c:	89 04 24             	mov    %eax,(%esp)
  80349f:	e8 9c f7 ff ff       	call   802c40 <fd2data>
  8034a4:	89 c6                	mov    %eax,%esi

  strcpy(stat->st_name, "<pipe>");
  8034a6:	c7 44 24 04 9c 46 80 	movl   $0x80469c,0x4(%esp)
  8034ad:	00 
  8034ae:	89 1c 24             	mov    %ebx,(%esp)
  8034b1:	e8 11 ef ff ff       	call   8023c7 <strcpy>
  stat->st_size = p->p_wpos - p->p_rpos;
  8034b6:	8b 46 04             	mov    0x4(%esi),%eax
  8034b9:	2b 06                	sub    (%esi),%eax
  8034bb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  stat->st_isdir = 0;
  8034c1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8034c8:	00 00 00 
  stat->st_dev = &devpipe;
  8034cb:	c7 83 88 00 00 00 80 	movl   $0x809080,0x88(%ebx)
  8034d2:	90 80 00 
  return 0;
}
  8034d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8034da:	83 c4 10             	add    $0x10,%esp
  8034dd:	5b                   	pop    %ebx
  8034de:	5e                   	pop    %esi
  8034df:	5d                   	pop    %ebp
  8034e0:	c3                   	ret    

008034e1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8034e1:	55                   	push   %ebp
  8034e2:	89 e5                	mov    %esp,%ebp
  8034e4:	53                   	push   %ebx
  8034e5:	83 ec 14             	sub    $0x14,%esp
  8034e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  (void)sys_page_unmap(0, fd);
  8034eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8034ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8034f6:	e8 8f f3 ff ff       	call   80288a <sys_page_unmap>
  return sys_page_unmap(0, fd2data(fd));
  8034fb:	89 1c 24             	mov    %ebx,(%esp)
  8034fe:	e8 3d f7 ff ff       	call   802c40 <fd2data>
  803503:	89 44 24 04          	mov    %eax,0x4(%esp)
  803507:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80350e:	e8 77 f3 ff ff       	call   80288a <sys_page_unmap>
}
  803513:	83 c4 14             	add    $0x14,%esp
  803516:	5b                   	pop    %ebx
  803517:	5d                   	pop    %ebp
  803518:	c3                   	ret    

00803519 <_pipeisclosed>:
  return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  803519:	55                   	push   %ebp
  80351a:	89 e5                	mov    %esp,%ebp
  80351c:	57                   	push   %edi
  80351d:	56                   	push   %esi
  80351e:	53                   	push   %ebx
  80351f:	83 ec 2c             	sub    $0x2c,%esp
  803522:	89 c6                	mov    %eax,%esi
  803524:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  int n, nn, ret;

  while (1) {
    n = thisenv->env_runs;
  803527:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80352c:	8b 58 58             	mov    0x58(%eax),%ebx
    ret = pageref(fd) == pageref(p);
  80352f:	89 34 24             	mov    %esi,(%esp)
  803532:	e8 1c ff ff ff       	call   803453 <pageref>
  803537:	89 c7                	mov    %eax,%edi
  803539:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80353c:	89 04 24             	mov    %eax,(%esp)
  80353f:	e8 0f ff ff ff       	call   803453 <pageref>
  803544:	39 c7                	cmp    %eax,%edi
  803546:	0f 94 c2             	sete   %dl
  803549:	0f b6 c2             	movzbl %dl,%eax
    nn = thisenv->env_runs;
  80354c:	8b 0d 0c a0 80 00    	mov    0x80a00c,%ecx
  803552:	8b 79 58             	mov    0x58(%ecx),%edi
    if (n == nn)
  803555:	39 fb                	cmp    %edi,%ebx
  803557:	74 21                	je     80357a <_pipeisclosed+0x61>
      return ret;
    if (n != nn && ret == 1)
  803559:	84 d2                	test   %dl,%dl
  80355b:	74 ca                	je     803527 <_pipeisclosed+0xe>
      cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80355d:	8b 51 58             	mov    0x58(%ecx),%edx
  803560:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803564:	89 54 24 08          	mov    %edx,0x8(%esp)
  803568:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80356c:	c7 04 24 a3 46 80 00 	movl   $0x8046a3,(%esp)
  803573:	e8 2c e8 ff ff       	call   801da4 <cprintf>
  803578:	eb ad                	jmp    803527 <_pipeisclosed+0xe>
  }
}
  80357a:	83 c4 2c             	add    $0x2c,%esp
  80357d:	5b                   	pop    %ebx
  80357e:	5e                   	pop    %esi
  80357f:	5f                   	pop    %edi
  803580:	5d                   	pop    %ebp
  803581:	c3                   	ret    

00803582 <devpipe_write>:
  return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803582:	55                   	push   %ebp
  803583:	89 e5                	mov    %esp,%ebp
  803585:	57                   	push   %edi
  803586:	56                   	push   %esi
  803587:	53                   	push   %ebx
  803588:	83 ec 1c             	sub    $0x1c,%esp
  80358b:	8b 75 08             	mov    0x8(%ebp),%esi
  const uint8_t *buf;
  size_t i;
  struct Pipe *p;

  p = (struct Pipe*)fd2data(fd);
  80358e:	89 34 24             	mov    %esi,(%esp)
  803591:	e8 aa f6 ff ff       	call   802c40 <fd2data>
  803596:	89 c3                	mov    %eax,%ebx
  if (debug)
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  803598:	bf 00 00 00 00       	mov    $0x0,%edi
  80359d:	eb 45                	jmp    8035e4 <devpipe_write+0x62>
    while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
      // pipe is full
      // if all the readers are gone
      // (it's only writers like us now),
      // note eof
      if (_pipeisclosed(fd, p))
  80359f:	89 da                	mov    %ebx,%edx
  8035a1:	89 f0                	mov    %esi,%eax
  8035a3:	e8 71 ff ff ff       	call   803519 <_pipeisclosed>
  8035a8:	85 c0                	test   %eax,%eax
  8035aa:	75 41                	jne    8035ed <devpipe_write+0x6b>
        return 0;
      // yield and see what happens
      if (debug)
        cprintf("devpipe_write yield\n");
      sys_yield();
  8035ac:	e8 13 f2 ff ff       	call   8027c4 <sys_yield>
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
    while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8035b1:	8b 43 04             	mov    0x4(%ebx),%eax
  8035b4:	8b 0b                	mov    (%ebx),%ecx
  8035b6:	8d 51 20             	lea    0x20(%ecx),%edx
  8035b9:	39 d0                	cmp    %edx,%eax
  8035bb:	73 e2                	jae    80359f <devpipe_write+0x1d>
        cprintf("devpipe_write yield\n");
      sys_yield();
    }
    // there's room for a byte.  store it.
    // wait to increment wpos until the byte is stored!
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8035bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8035c0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8035c4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8035c7:	99                   	cltd   
  8035c8:	c1 ea 1b             	shr    $0x1b,%edx
  8035cb:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8035ce:	83 e1 1f             	and    $0x1f,%ecx
  8035d1:	29 d1                	sub    %edx,%ecx
  8035d3:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8035d7:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
    p->p_wpos++;
  8035db:	83 c0 01             	add    $0x1,%eax
  8035de:	89 43 04             	mov    %eax,0x4(%ebx)
  if (debug)
    cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  8035e1:	83 c7 01             	add    $0x1,%edi
  8035e4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8035e7:	75 c8                	jne    8035b1 <devpipe_write+0x2f>
    // wait to increment wpos until the byte is stored!
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
    p->p_wpos++;
  }

  return i;
  8035e9:	89 f8                	mov    %edi,%eax
  8035eb:	eb 05                	jmp    8035f2 <devpipe_write+0x70>
      // pipe is full
      // if all the readers are gone
      // (it's only writers like us now),
      // note eof
      if (_pipeisclosed(fd, p))
        return 0;
  8035ed:	b8 00 00 00 00       	mov    $0x0,%eax
    p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
    p->p_wpos++;
  }

  return i;
}
  8035f2:	83 c4 1c             	add    $0x1c,%esp
  8035f5:	5b                   	pop    %ebx
  8035f6:	5e                   	pop    %esi
  8035f7:	5f                   	pop    %edi
  8035f8:	5d                   	pop    %ebp
  8035f9:	c3                   	ret    

008035fa <devpipe_read>:
  return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8035fa:	55                   	push   %ebp
  8035fb:	89 e5                	mov    %esp,%ebp
  8035fd:	57                   	push   %edi
  8035fe:	56                   	push   %esi
  8035ff:	53                   	push   %ebx
  803600:	83 ec 1c             	sub    $0x1c,%esp
  803603:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint8_t *buf;
  size_t i;
  struct Pipe *p;

  p = (struct Pipe*)fd2data(fd);
  803606:	89 3c 24             	mov    %edi,(%esp)
  803609:	e8 32 f6 ff ff       	call   802c40 <fd2data>
  80360e:	89 c3                	mov    %eax,%ebx
  if (debug)
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  803610:	be 00 00 00 00       	mov    $0x0,%esi
  803615:	eb 3d                	jmp    803654 <devpipe_read+0x5a>
    while (p->p_rpos == p->p_wpos) {
      // pipe is empty
      // if we got any data, return it
      if (i > 0)
  803617:	85 f6                	test   %esi,%esi
  803619:	74 04                	je     80361f <devpipe_read+0x25>
        return i;
  80361b:	89 f0                	mov    %esi,%eax
  80361d:	eb 43                	jmp    803662 <devpipe_read+0x68>
      // if all the writers are gone, note eof
      if (_pipeisclosed(fd, p))
  80361f:	89 da                	mov    %ebx,%edx
  803621:	89 f8                	mov    %edi,%eax
  803623:	e8 f1 fe ff ff       	call   803519 <_pipeisclosed>
  803628:	85 c0                	test   %eax,%eax
  80362a:	75 31                	jne    80365d <devpipe_read+0x63>
        return 0;
      // yield and see what happens
      if (debug)
        cprintf("devpipe_read yield\n");
      sys_yield();
  80362c:	e8 93 f1 ff ff       	call   8027c4 <sys_yield>
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
    while (p->p_rpos == p->p_wpos) {
  803631:	8b 03                	mov    (%ebx),%eax
  803633:	3b 43 04             	cmp    0x4(%ebx),%eax
  803636:	74 df                	je     803617 <devpipe_read+0x1d>
        cprintf("devpipe_read yield\n");
      sys_yield();
    }
    // there's a byte.  take it.
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803638:	99                   	cltd   
  803639:	c1 ea 1b             	shr    $0x1b,%edx
  80363c:	01 d0                	add    %edx,%eax
  80363e:	83 e0 1f             	and    $0x1f,%eax
  803641:	29 d0                	sub    %edx,%eax
  803643:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  803648:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80364b:	88 04 31             	mov    %al,(%ecx,%esi,1)
    p->p_rpos++;
  80364e:	83 03 01             	addl   $0x1,(%ebx)
  if (debug)
    cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
            thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

  buf = vbuf;
  for (i = 0; i < n; i++) {
  803651:	83 c6 01             	add    $0x1,%esi
  803654:	3b 75 10             	cmp    0x10(%ebp),%esi
  803657:	75 d8                	jne    803631 <devpipe_read+0x37>
    // there's a byte.  take it.
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
    p->p_rpos++;
  }
  return i;
  803659:	89 f0                	mov    %esi,%eax
  80365b:	eb 05                	jmp    803662 <devpipe_read+0x68>
      // if we got any data, return it
      if (i > 0)
        return i;
      // if all the writers are gone, note eof
      if (_pipeisclosed(fd, p))
        return 0;
  80365d:	b8 00 00 00 00       	mov    $0x0,%eax
    // wait to increment rpos until the byte is taken!
    buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
    p->p_rpos++;
  }
  return i;
}
  803662:	83 c4 1c             	add    $0x1c,%esp
  803665:	5b                   	pop    %ebx
  803666:	5e                   	pop    %esi
  803667:	5f                   	pop    %edi
  803668:	5d                   	pop    %ebp
  803669:	c3                   	ret    

0080366a <pipe>:
  uint8_t p_buf[PIPEBUFSIZ];    // data buffer
};

int
pipe(int pfd[2])
{
  80366a:	55                   	push   %ebp
  80366b:	89 e5                	mov    %esp,%ebp
  80366d:	56                   	push   %esi
  80366e:	53                   	push   %ebx
  80366f:	83 ec 30             	sub    $0x30,%esp
  int r;
  struct Fd *fd0, *fd1;
  void *va;

  // allocate the file descriptor table entries
  if ((r = fd_alloc(&fd0)) < 0
  803672:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803675:	89 04 24             	mov    %eax,(%esp)
  803678:	e8 da f5 ff ff       	call   802c57 <fd_alloc>
  80367d:	89 c2                	mov    %eax,%edx
  80367f:	85 d2                	test   %edx,%edx
  803681:	0f 88 4d 01 00 00    	js     8037d4 <pipe+0x16a>
      || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803687:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80368e:	00 
  80368f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803692:	89 44 24 04          	mov    %eax,0x4(%esp)
  803696:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80369d:	e8 41 f1 ff ff       	call   8027e3 <sys_page_alloc>
  8036a2:	89 c2                	mov    %eax,%edx
  8036a4:	85 d2                	test   %edx,%edx
  8036a6:	0f 88 28 01 00 00    	js     8037d4 <pipe+0x16a>
    goto err;

  if ((r = fd_alloc(&fd1)) < 0
  8036ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8036af:	89 04 24             	mov    %eax,(%esp)
  8036b2:	e8 a0 f5 ff ff       	call   802c57 <fd_alloc>
  8036b7:	89 c3                	mov    %eax,%ebx
  8036b9:	85 c0                	test   %eax,%eax
  8036bb:	0f 88 fe 00 00 00    	js     8037bf <pipe+0x155>
      || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8036c1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8036c8:	00 
  8036c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8036cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8036d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8036d7:	e8 07 f1 ff ff       	call   8027e3 <sys_page_alloc>
  8036dc:	89 c3                	mov    %eax,%ebx
  8036de:	85 c0                	test   %eax,%eax
  8036e0:	0f 88 d9 00 00 00    	js     8037bf <pipe+0x155>
    goto err1;

  // allocate the pipe structure as first data page in both
  va = fd2data(fd0);
  8036e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8036e9:	89 04 24             	mov    %eax,(%esp)
  8036ec:	e8 4f f5 ff ff       	call   802c40 <fd2data>
  8036f1:	89 c6                	mov    %eax,%esi
  if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8036f3:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8036fa:	00 
  8036fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8036ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803706:	e8 d8 f0 ff ff       	call   8027e3 <sys_page_alloc>
  80370b:	89 c3                	mov    %eax,%ebx
  80370d:	85 c0                	test   %eax,%eax
  80370f:	0f 88 97 00 00 00    	js     8037ac <pipe+0x142>
    goto err2;
  if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803715:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803718:	89 04 24             	mov    %eax,(%esp)
  80371b:	e8 20 f5 ff ff       	call   802c40 <fd2data>
  803720:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  803727:	00 
  803728:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80372c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  803733:	00 
  803734:	89 74 24 04          	mov    %esi,0x4(%esp)
  803738:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80373f:	e8 f3 f0 ff ff       	call   802837 <sys_page_map>
  803744:	89 c3                	mov    %eax,%ebx
  803746:	85 c0                	test   %eax,%eax
  803748:	78 52                	js     80379c <pipe+0x132>
    goto err3;

  // set up fd structures
  fd0->fd_dev_id = devpipe.dev_id;
  80374a:	8b 15 80 90 80 00    	mov    0x809080,%edx
  803750:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803753:	89 10                	mov    %edx,(%eax)
  fd0->fd_omode = O_RDONLY;
  803755:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803758:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

  fd1->fd_dev_id = devpipe.dev_id;
  80375f:	8b 15 80 90 80 00    	mov    0x809080,%edx
  803765:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803768:	89 10                	mov    %edx,(%eax)
  fd1->fd_omode = O_WRONLY;
  80376a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80376d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

  if (debug)
    cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

  pfd[0] = fd2num(fd0);
  803774:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803777:	89 04 24             	mov    %eax,(%esp)
  80377a:	e8 b1 f4 ff ff       	call   802c30 <fd2num>
  80377f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803782:	89 01                	mov    %eax,(%ecx)
  pfd[1] = fd2num(fd1);
  803784:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803787:	89 04 24             	mov    %eax,(%esp)
  80378a:	e8 a1 f4 ff ff       	call   802c30 <fd2num>
  80378f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803792:	89 41 04             	mov    %eax,0x4(%ecx)
  return 0;
  803795:	b8 00 00 00 00       	mov    $0x0,%eax
  80379a:	eb 38                	jmp    8037d4 <pipe+0x16a>

err3:
  sys_page_unmap(0, va);
  80379c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8037a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8037a7:	e8 de f0 ff ff       	call   80288a <sys_page_unmap>
err2:
  sys_page_unmap(0, fd1);
  8037ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8037af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8037b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8037ba:	e8 cb f0 ff ff       	call   80288a <sys_page_unmap>
err1:
  sys_page_unmap(0, fd0);
  8037bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8037c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8037c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8037cd:	e8 b8 f0 ff ff       	call   80288a <sys_page_unmap>
  8037d2:	89 d8                	mov    %ebx,%eax
err:
  return r;
}
  8037d4:	83 c4 30             	add    $0x30,%esp
  8037d7:	5b                   	pop    %ebx
  8037d8:	5e                   	pop    %esi
  8037d9:	5d                   	pop    %ebp
  8037da:	c3                   	ret    

008037db <pipeisclosed>:
  }
}

int
pipeisclosed(int fdnum)
{
  8037db:	55                   	push   %ebp
  8037dc:	89 e5                	mov    %esp,%ebp
  8037de:	83 ec 28             	sub    $0x28,%esp
  struct Fd *fd;
  struct Pipe *p;
  int r;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  8037e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8037e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8037e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8037eb:	89 04 24             	mov    %eax,(%esp)
  8037ee:	e8 b3 f4 ff ff       	call   802ca6 <fd_lookup>
  8037f3:	89 c2                	mov    %eax,%edx
  8037f5:	85 d2                	test   %edx,%edx
  8037f7:	78 15                	js     80380e <pipeisclosed+0x33>
    return r;
  p = (struct Pipe*)fd2data(fd);
  8037f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8037fc:	89 04 24             	mov    %eax,(%esp)
  8037ff:	e8 3c f4 ff ff       	call   802c40 <fd2data>
  return _pipeisclosed(fd, p);
  803804:	89 c2                	mov    %eax,%edx
  803806:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803809:	e8 0b fd ff ff       	call   803519 <_pipeisclosed>
}
  80380e:	c9                   	leave  
  80380f:	c3                   	ret    

00803810 <devcons_close>:
  return tot;
}

static int
devcons_close(struct Fd *fd)
{
  803810:	55                   	push   %ebp
  803811:	89 e5                	mov    %esp,%ebp
  USED(fd);

  return 0;
}
  803813:	b8 00 00 00 00       	mov    $0x0,%eax
  803818:	5d                   	pop    %ebp
  803819:	c3                   	ret    

0080381a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80381a:	55                   	push   %ebp
  80381b:	89 e5                	mov    %esp,%ebp
  80381d:	83 ec 18             	sub    $0x18,%esp
  strcpy(stat->st_name, "<cons>");
  803820:	c7 44 24 04 bb 46 80 	movl   $0x8046bb,0x4(%esp)
  803827:	00 
  803828:	8b 45 0c             	mov    0xc(%ebp),%eax
  80382b:	89 04 24             	mov    %eax,(%esp)
  80382e:	e8 94 eb ff ff       	call   8023c7 <strcpy>
  return 0;
}
  803833:	b8 00 00 00 00       	mov    $0x0,%eax
  803838:	c9                   	leave  
  803839:	c3                   	ret    

0080383a <devcons_write>:
  return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80383a:	55                   	push   %ebp
  80383b:	89 e5                	mov    %esp,%ebp
  80383d:	57                   	push   %edi
  80383e:	56                   	push   %esi
  80383f:	53                   	push   %ebx
  803840:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  803846:	bb 00 00 00 00       	mov    $0x0,%ebx
    m = n - tot;
    if (m > sizeof(buf) - 1)
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
  80384b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  803851:	eb 31                	jmp    803884 <devcons_write+0x4a>
    m = n - tot;
  803853:	8b 75 10             	mov    0x10(%ebp),%esi
  803856:	29 de                	sub    %ebx,%esi
    if (m > sizeof(buf) - 1)
  803858:	83 fe 7f             	cmp    $0x7f,%esi
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
    m = n - tot;
  80385b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  803860:	0f 47 f2             	cmova  %edx,%esi
    if (m > sizeof(buf) - 1)
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
  803863:	89 74 24 08          	mov    %esi,0x8(%esp)
  803867:	03 45 0c             	add    0xc(%ebp),%eax
  80386a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80386e:	89 3c 24             	mov    %edi,(%esp)
  803871:	e8 ee ec ff ff       	call   802564 <memmove>
    sys_cputs(buf, m);
  803876:	89 74 24 04          	mov    %esi,0x4(%esp)
  80387a:	89 3c 24             	mov    %edi,(%esp)
  80387d:	e8 94 ee ff ff       	call   802716 <sys_cputs>
  int tot, m;
  char buf[128];

  // mistake: have to nul-terminate arg to sys_cputs,
  // so we have to copy vbuf into buf in chunks and nul-terminate.
  for (tot = 0; tot < n; tot += m) {
  803882:	01 f3                	add    %esi,%ebx
  803884:	89 d8                	mov    %ebx,%eax
  803886:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  803889:	72 c8                	jb     803853 <devcons_write+0x19>
      m = sizeof(buf) - 1;
    memmove(buf, (char*)vbuf + tot, m);
    sys_cputs(buf, m);
  }
  return tot;
}
  80388b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  803891:	5b                   	pop    %ebx
  803892:	5e                   	pop    %esi
  803893:	5f                   	pop    %edi
  803894:	5d                   	pop    %ebp
  803895:	c3                   	ret    

00803896 <devcons_read>:
  return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  803896:	55                   	push   %ebp
  803897:	89 e5                	mov    %esp,%ebp
  803899:	83 ec 08             	sub    $0x8,%esp
  int c;

  if (n == 0)
    return 0;
  80389c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  int c;

  if (n == 0)
  8038a1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8038a5:	75 07                	jne    8038ae <devcons_read+0x18>
  8038a7:	eb 2a                	jmp    8038d3 <devcons_read+0x3d>
    return 0;

  while ((c = sys_cgetc()) == 0)
    sys_yield();
  8038a9:	e8 16 ef ff ff       	call   8027c4 <sys_yield>
  int c;

  if (n == 0)
    return 0;

  while ((c = sys_cgetc()) == 0)
  8038ae:	66 90                	xchg   %ax,%ax
  8038b0:	e8 7f ee ff ff       	call   802734 <sys_cgetc>
  8038b5:	85 c0                	test   %eax,%eax
  8038b7:	74 f0                	je     8038a9 <devcons_read+0x13>
    sys_yield();
  if (c < 0)
  8038b9:	85 c0                	test   %eax,%eax
  8038bb:	78 16                	js     8038d3 <devcons_read+0x3d>
    return c;
  if (c == 0x04)        // ctl-d is eof
  8038bd:	83 f8 04             	cmp    $0x4,%eax
  8038c0:	74 0c                	je     8038ce <devcons_read+0x38>
    return 0;
  *(char*)vbuf = c;
  8038c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8038c5:	88 02                	mov    %al,(%edx)
  return 1;
  8038c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8038cc:	eb 05                	jmp    8038d3 <devcons_read+0x3d>
  while ((c = sys_cgetc()) == 0)
    sys_yield();
  if (c < 0)
    return c;
  if (c == 0x04)        // ctl-d is eof
    return 0;
  8038ce:	b8 00 00 00 00       	mov    $0x0,%eax
  *(char*)vbuf = c;
  return 1;
}
  8038d3:	c9                   	leave  
  8038d4:	c3                   	ret    

008038d5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8038d5:	55                   	push   %ebp
  8038d6:	89 e5                	mov    %esp,%ebp
  8038d8:	83 ec 28             	sub    $0x28,%esp
  char c = ch;
  8038db:	8b 45 08             	mov    0x8(%ebp),%eax
  8038de:	88 45 f7             	mov    %al,-0x9(%ebp)

  // Unlike standard Unix's putchar,
  // the cputchar function _always_ outputs to the system console.
  sys_cputs(&c, 1);
  8038e1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8038e8:	00 
  8038e9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8038ec:	89 04 24             	mov    %eax,(%esp)
  8038ef:	e8 22 ee ff ff       	call   802716 <sys_cputs>
}
  8038f4:	c9                   	leave  
  8038f5:	c3                   	ret    

008038f6 <getchar>:

int
getchar(void)
{
  8038f6:	55                   	push   %ebp
  8038f7:	89 e5                	mov    %esp,%ebp
  8038f9:	83 ec 28             	sub    $0x28,%esp
  int r;

  // JOS does, however, support standard _input_ redirection,
  // allowing the user to redirect script files to the shell and such.
  // getchar() reads a character from file descriptor 0.
  r = read(0, &c, 1);
  8038fc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  803903:	00 
  803904:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803907:	89 44 24 04          	mov    %eax,0x4(%esp)
  80390b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803912:	e8 1e f6 ff ff       	call   802f35 <read>
  if (r < 0)
  803917:	85 c0                	test   %eax,%eax
  803919:	78 0f                	js     80392a <getchar+0x34>
    return r;
  if (r < 1)
  80391b:	85 c0                	test   %eax,%eax
  80391d:	7e 06                	jle    803925 <getchar+0x2f>
    return -E_EOF;
  return c;
  80391f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  803923:	eb 05                	jmp    80392a <getchar+0x34>
  // getchar() reads a character from file descriptor 0.
  r = read(0, &c, 1);
  if (r < 0)
    return r;
  if (r < 1)
    return -E_EOF;
  803925:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  /* int r;
  // sys_cgetc does not block, but getchar should.
  while ((r = sys_cgetc()) == 0)
    sys_yield();
  return r; */
}
  80392a:	c9                   	leave  
  80392b:	c3                   	ret    

0080392c <iscons>:
  .dev_stat   =     devcons_stat
};

int
iscons(int fdnum)
{
  80392c:	55                   	push   %ebp
  80392d:	89 e5                	mov    %esp,%ebp
  80392f:	83 ec 28             	sub    $0x28,%esp
  int r;
  struct Fd *fd;

  if ((r = fd_lookup(fdnum, &fd)) < 0)
  803932:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803935:	89 44 24 04          	mov    %eax,0x4(%esp)
  803939:	8b 45 08             	mov    0x8(%ebp),%eax
  80393c:	89 04 24             	mov    %eax,(%esp)
  80393f:	e8 62 f3 ff ff       	call   802ca6 <fd_lookup>
  803944:	85 c0                	test   %eax,%eax
  803946:	78 11                	js     803959 <iscons+0x2d>
    return r;
  return fd->fd_dev_id == devcons.dev_id;
  803948:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80394b:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803951:	39 10                	cmp    %edx,(%eax)
  803953:	0f 94 c0             	sete   %al
  803956:	0f b6 c0             	movzbl %al,%eax
}
  803959:	c9                   	leave  
  80395a:	c3                   	ret    

0080395b <opencons>:

int
opencons(void)
{
  80395b:	55                   	push   %ebp
  80395c:	89 e5                	mov    %esp,%ebp
  80395e:	83 ec 28             	sub    $0x28,%esp
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
  803961:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803964:	89 04 24             	mov    %eax,(%esp)
  803967:	e8 eb f2 ff ff       	call   802c57 <fd_alloc>
    return r;
  80396c:	89 c2                	mov    %eax,%edx
opencons(void)
{
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
  80396e:	85 c0                	test   %eax,%eax
  803970:	78 40                	js     8039b2 <opencons+0x57>
    return r;
  if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803972:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803979:	00 
  80397a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80397d:	89 44 24 04          	mov    %eax,0x4(%esp)
  803981:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803988:	e8 56 ee ff ff       	call   8027e3 <sys_page_alloc>
    return r;
  80398d:	89 c2                	mov    %eax,%edx
  int r;
  struct Fd* fd;

  if ((r = fd_alloc(&fd)) < 0)
    return r;
  if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80398f:	85 c0                	test   %eax,%eax
  803991:	78 1f                	js     8039b2 <opencons+0x57>
    return r;
  fd->fd_dev_id = devcons.dev_id;
  803993:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803999:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80399c:	89 10                	mov    %edx,(%eax)
  fd->fd_omode = O_RDWR;
  80399e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8039a1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
  return fd2num(fd);
  8039a8:	89 04 24             	mov    %eax,(%esp)
  8039ab:	e8 80 f2 ff ff       	call   802c30 <fd2num>
  8039b0:	89 c2                	mov    %eax,%edx
}
  8039b2:	89 d0                	mov    %edx,%eax
  8039b4:	c9                   	leave  
  8039b5:	c3                   	ret    
  8039b6:	66 90                	xchg   %ax,%ax
  8039b8:	66 90                	xchg   %ax,%ax
  8039ba:	66 90                	xchg   %ax,%ax
  8039bc:	66 90                	xchg   %ax,%ax
  8039be:	66 90                	xchg   %ax,%ax

008039c0 <__udivdi3>:
  8039c0:	55                   	push   %ebp
  8039c1:	57                   	push   %edi
  8039c2:	56                   	push   %esi
  8039c3:	83 ec 0c             	sub    $0xc,%esp
  8039c6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8039ca:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8039ce:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8039d2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8039d6:	85 c0                	test   %eax,%eax
  8039d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8039dc:	89 ea                	mov    %ebp,%edx
  8039de:	89 0c 24             	mov    %ecx,(%esp)
  8039e1:	75 2d                	jne    803a10 <__udivdi3+0x50>
  8039e3:	39 e9                	cmp    %ebp,%ecx
  8039e5:	77 61                	ja     803a48 <__udivdi3+0x88>
  8039e7:	85 c9                	test   %ecx,%ecx
  8039e9:	89 ce                	mov    %ecx,%esi
  8039eb:	75 0b                	jne    8039f8 <__udivdi3+0x38>
  8039ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8039f2:	31 d2                	xor    %edx,%edx
  8039f4:	f7 f1                	div    %ecx
  8039f6:	89 c6                	mov    %eax,%esi
  8039f8:	31 d2                	xor    %edx,%edx
  8039fa:	89 e8                	mov    %ebp,%eax
  8039fc:	f7 f6                	div    %esi
  8039fe:	89 c5                	mov    %eax,%ebp
  803a00:	89 f8                	mov    %edi,%eax
  803a02:	f7 f6                	div    %esi
  803a04:	89 ea                	mov    %ebp,%edx
  803a06:	83 c4 0c             	add    $0xc,%esp
  803a09:	5e                   	pop    %esi
  803a0a:	5f                   	pop    %edi
  803a0b:	5d                   	pop    %ebp
  803a0c:	c3                   	ret    
  803a0d:	8d 76 00             	lea    0x0(%esi),%esi
  803a10:	39 e8                	cmp    %ebp,%eax
  803a12:	77 24                	ja     803a38 <__udivdi3+0x78>
  803a14:	0f bd e8             	bsr    %eax,%ebp
  803a17:	83 f5 1f             	xor    $0x1f,%ebp
  803a1a:	75 3c                	jne    803a58 <__udivdi3+0x98>
  803a1c:	8b 74 24 04          	mov    0x4(%esp),%esi
  803a20:	39 34 24             	cmp    %esi,(%esp)
  803a23:	0f 86 9f 00 00 00    	jbe    803ac8 <__udivdi3+0x108>
  803a29:	39 d0                	cmp    %edx,%eax
  803a2b:	0f 82 97 00 00 00    	jb     803ac8 <__udivdi3+0x108>
  803a31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803a38:	31 d2                	xor    %edx,%edx
  803a3a:	31 c0                	xor    %eax,%eax
  803a3c:	83 c4 0c             	add    $0xc,%esp
  803a3f:	5e                   	pop    %esi
  803a40:	5f                   	pop    %edi
  803a41:	5d                   	pop    %ebp
  803a42:	c3                   	ret    
  803a43:	90                   	nop
  803a44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803a48:	89 f8                	mov    %edi,%eax
  803a4a:	f7 f1                	div    %ecx
  803a4c:	31 d2                	xor    %edx,%edx
  803a4e:	83 c4 0c             	add    $0xc,%esp
  803a51:	5e                   	pop    %esi
  803a52:	5f                   	pop    %edi
  803a53:	5d                   	pop    %ebp
  803a54:	c3                   	ret    
  803a55:	8d 76 00             	lea    0x0(%esi),%esi
  803a58:	89 e9                	mov    %ebp,%ecx
  803a5a:	8b 3c 24             	mov    (%esp),%edi
  803a5d:	d3 e0                	shl    %cl,%eax
  803a5f:	89 c6                	mov    %eax,%esi
  803a61:	b8 20 00 00 00       	mov    $0x20,%eax
  803a66:	29 e8                	sub    %ebp,%eax
  803a68:	89 c1                	mov    %eax,%ecx
  803a6a:	d3 ef                	shr    %cl,%edi
  803a6c:	89 e9                	mov    %ebp,%ecx
  803a6e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  803a72:	8b 3c 24             	mov    (%esp),%edi
  803a75:	09 74 24 08          	or     %esi,0x8(%esp)
  803a79:	89 d6                	mov    %edx,%esi
  803a7b:	d3 e7                	shl    %cl,%edi
  803a7d:	89 c1                	mov    %eax,%ecx
  803a7f:	89 3c 24             	mov    %edi,(%esp)
  803a82:	8b 7c 24 04          	mov    0x4(%esp),%edi
  803a86:	d3 ee                	shr    %cl,%esi
  803a88:	89 e9                	mov    %ebp,%ecx
  803a8a:	d3 e2                	shl    %cl,%edx
  803a8c:	89 c1                	mov    %eax,%ecx
  803a8e:	d3 ef                	shr    %cl,%edi
  803a90:	09 d7                	or     %edx,%edi
  803a92:	89 f2                	mov    %esi,%edx
  803a94:	89 f8                	mov    %edi,%eax
  803a96:	f7 74 24 08          	divl   0x8(%esp)
  803a9a:	89 d6                	mov    %edx,%esi
  803a9c:	89 c7                	mov    %eax,%edi
  803a9e:	f7 24 24             	mull   (%esp)
  803aa1:	39 d6                	cmp    %edx,%esi
  803aa3:	89 14 24             	mov    %edx,(%esp)
  803aa6:	72 30                	jb     803ad8 <__udivdi3+0x118>
  803aa8:	8b 54 24 04          	mov    0x4(%esp),%edx
  803aac:	89 e9                	mov    %ebp,%ecx
  803aae:	d3 e2                	shl    %cl,%edx
  803ab0:	39 c2                	cmp    %eax,%edx
  803ab2:	73 05                	jae    803ab9 <__udivdi3+0xf9>
  803ab4:	3b 34 24             	cmp    (%esp),%esi
  803ab7:	74 1f                	je     803ad8 <__udivdi3+0x118>
  803ab9:	89 f8                	mov    %edi,%eax
  803abb:	31 d2                	xor    %edx,%edx
  803abd:	e9 7a ff ff ff       	jmp    803a3c <__udivdi3+0x7c>
  803ac2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803ac8:	31 d2                	xor    %edx,%edx
  803aca:	b8 01 00 00 00       	mov    $0x1,%eax
  803acf:	e9 68 ff ff ff       	jmp    803a3c <__udivdi3+0x7c>
  803ad4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803ad8:	8d 47 ff             	lea    -0x1(%edi),%eax
  803adb:	31 d2                	xor    %edx,%edx
  803add:	83 c4 0c             	add    $0xc,%esp
  803ae0:	5e                   	pop    %esi
  803ae1:	5f                   	pop    %edi
  803ae2:	5d                   	pop    %ebp
  803ae3:	c3                   	ret    
  803ae4:	66 90                	xchg   %ax,%ax
  803ae6:	66 90                	xchg   %ax,%ax
  803ae8:	66 90                	xchg   %ax,%ax
  803aea:	66 90                	xchg   %ax,%ax
  803aec:	66 90                	xchg   %ax,%ax
  803aee:	66 90                	xchg   %ax,%ax

00803af0 <__umoddi3>:
  803af0:	55                   	push   %ebp
  803af1:	57                   	push   %edi
  803af2:	56                   	push   %esi
  803af3:	83 ec 14             	sub    $0x14,%esp
  803af6:	8b 44 24 28          	mov    0x28(%esp),%eax
  803afa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  803afe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  803b02:	89 c7                	mov    %eax,%edi
  803b04:	89 44 24 04          	mov    %eax,0x4(%esp)
  803b08:	8b 44 24 30          	mov    0x30(%esp),%eax
  803b0c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  803b10:	89 34 24             	mov    %esi,(%esp)
  803b13:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803b17:	85 c0                	test   %eax,%eax
  803b19:	89 c2                	mov    %eax,%edx
  803b1b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  803b1f:	75 17                	jne    803b38 <__umoddi3+0x48>
  803b21:	39 fe                	cmp    %edi,%esi
  803b23:	76 4b                	jbe    803b70 <__umoddi3+0x80>
  803b25:	89 c8                	mov    %ecx,%eax
  803b27:	89 fa                	mov    %edi,%edx
  803b29:	f7 f6                	div    %esi
  803b2b:	89 d0                	mov    %edx,%eax
  803b2d:	31 d2                	xor    %edx,%edx
  803b2f:	83 c4 14             	add    $0x14,%esp
  803b32:	5e                   	pop    %esi
  803b33:	5f                   	pop    %edi
  803b34:	5d                   	pop    %ebp
  803b35:	c3                   	ret    
  803b36:	66 90                	xchg   %ax,%ax
  803b38:	39 f8                	cmp    %edi,%eax
  803b3a:	77 54                	ja     803b90 <__umoddi3+0xa0>
  803b3c:	0f bd e8             	bsr    %eax,%ebp
  803b3f:	83 f5 1f             	xor    $0x1f,%ebp
  803b42:	75 5c                	jne    803ba0 <__umoddi3+0xb0>
  803b44:	8b 7c 24 08          	mov    0x8(%esp),%edi
  803b48:	39 3c 24             	cmp    %edi,(%esp)
  803b4b:	0f 87 e7 00 00 00    	ja     803c38 <__umoddi3+0x148>
  803b51:	8b 7c 24 04          	mov    0x4(%esp),%edi
  803b55:	29 f1                	sub    %esi,%ecx
  803b57:	19 c7                	sbb    %eax,%edi
  803b59:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803b5d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  803b61:	8b 44 24 08          	mov    0x8(%esp),%eax
  803b65:	8b 54 24 0c          	mov    0xc(%esp),%edx
  803b69:	83 c4 14             	add    $0x14,%esp
  803b6c:	5e                   	pop    %esi
  803b6d:	5f                   	pop    %edi
  803b6e:	5d                   	pop    %ebp
  803b6f:	c3                   	ret    
  803b70:	85 f6                	test   %esi,%esi
  803b72:	89 f5                	mov    %esi,%ebp
  803b74:	75 0b                	jne    803b81 <__umoddi3+0x91>
  803b76:	b8 01 00 00 00       	mov    $0x1,%eax
  803b7b:	31 d2                	xor    %edx,%edx
  803b7d:	f7 f6                	div    %esi
  803b7f:	89 c5                	mov    %eax,%ebp
  803b81:	8b 44 24 04          	mov    0x4(%esp),%eax
  803b85:	31 d2                	xor    %edx,%edx
  803b87:	f7 f5                	div    %ebp
  803b89:	89 c8                	mov    %ecx,%eax
  803b8b:	f7 f5                	div    %ebp
  803b8d:	eb 9c                	jmp    803b2b <__umoddi3+0x3b>
  803b8f:	90                   	nop
  803b90:	89 c8                	mov    %ecx,%eax
  803b92:	89 fa                	mov    %edi,%edx
  803b94:	83 c4 14             	add    $0x14,%esp
  803b97:	5e                   	pop    %esi
  803b98:	5f                   	pop    %edi
  803b99:	5d                   	pop    %ebp
  803b9a:	c3                   	ret    
  803b9b:	90                   	nop
  803b9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803ba0:	8b 04 24             	mov    (%esp),%eax
  803ba3:	be 20 00 00 00       	mov    $0x20,%esi
  803ba8:	89 e9                	mov    %ebp,%ecx
  803baa:	29 ee                	sub    %ebp,%esi
  803bac:	d3 e2                	shl    %cl,%edx
  803bae:	89 f1                	mov    %esi,%ecx
  803bb0:	d3 e8                	shr    %cl,%eax
  803bb2:	89 e9                	mov    %ebp,%ecx
  803bb4:	89 44 24 04          	mov    %eax,0x4(%esp)
  803bb8:	8b 04 24             	mov    (%esp),%eax
  803bbb:	09 54 24 04          	or     %edx,0x4(%esp)
  803bbf:	89 fa                	mov    %edi,%edx
  803bc1:	d3 e0                	shl    %cl,%eax
  803bc3:	89 f1                	mov    %esi,%ecx
  803bc5:	89 44 24 08          	mov    %eax,0x8(%esp)
  803bc9:	8b 44 24 10          	mov    0x10(%esp),%eax
  803bcd:	d3 ea                	shr    %cl,%edx
  803bcf:	89 e9                	mov    %ebp,%ecx
  803bd1:	d3 e7                	shl    %cl,%edi
  803bd3:	89 f1                	mov    %esi,%ecx
  803bd5:	d3 e8                	shr    %cl,%eax
  803bd7:	89 e9                	mov    %ebp,%ecx
  803bd9:	09 f8                	or     %edi,%eax
  803bdb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  803bdf:	f7 74 24 04          	divl   0x4(%esp)
  803be3:	d3 e7                	shl    %cl,%edi
  803be5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  803be9:	89 d7                	mov    %edx,%edi
  803beb:	f7 64 24 08          	mull   0x8(%esp)
  803bef:	39 d7                	cmp    %edx,%edi
  803bf1:	89 c1                	mov    %eax,%ecx
  803bf3:	89 14 24             	mov    %edx,(%esp)
  803bf6:	72 2c                	jb     803c24 <__umoddi3+0x134>
  803bf8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  803bfc:	72 22                	jb     803c20 <__umoddi3+0x130>
  803bfe:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803c02:	29 c8                	sub    %ecx,%eax
  803c04:	19 d7                	sbb    %edx,%edi
  803c06:	89 e9                	mov    %ebp,%ecx
  803c08:	89 fa                	mov    %edi,%edx
  803c0a:	d3 e8                	shr    %cl,%eax
  803c0c:	89 f1                	mov    %esi,%ecx
  803c0e:	d3 e2                	shl    %cl,%edx
  803c10:	89 e9                	mov    %ebp,%ecx
  803c12:	d3 ef                	shr    %cl,%edi
  803c14:	09 d0                	or     %edx,%eax
  803c16:	89 fa                	mov    %edi,%edx
  803c18:	83 c4 14             	add    $0x14,%esp
  803c1b:	5e                   	pop    %esi
  803c1c:	5f                   	pop    %edi
  803c1d:	5d                   	pop    %ebp
  803c1e:	c3                   	ret    
  803c1f:	90                   	nop
  803c20:	39 d7                	cmp    %edx,%edi
  803c22:	75 da                	jne    803bfe <__umoddi3+0x10e>
  803c24:	8b 14 24             	mov    (%esp),%edx
  803c27:	89 c1                	mov    %eax,%ecx
  803c29:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  803c2d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  803c31:	eb cb                	jmp    803bfe <__umoddi3+0x10e>
  803c33:	90                   	nop
  803c34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803c38:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  803c3c:	0f 82 0f ff ff ff    	jb     803b51 <__umoddi3+0x61>
  803c42:	e9 1a ff ff ff       	jmp    803b61 <__umoddi3+0x71>
