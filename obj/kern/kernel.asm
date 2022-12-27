
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 f0 11 f0       	mov    $0xf011f000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 6a 00 00 00       	call   f01000a8 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	83 ec 10             	sub    $0x10,%esp
f0100048:	8b 75 10             	mov    0x10(%ebp),%esi
  va_list ap;

  if (panicstr)
f010004b:	83 3d 80 ce 20 f0 00 	cmpl   $0x0,0xf020ce80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
    goto dead;
  panicstr = fmt;
f0100054:	89 35 80 ce 20 f0    	mov    %esi,0xf020ce80

  // Be extra sure that the machine is in as reasonable state
  __asm __volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

  va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
  cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 35 68 00 00       	call   f0106899 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 80 6f 10 f0 	movl   $0xf0106f80,(%esp)
f010007d:	e8 ee 3e 00 00       	call   f0103f70 <cprintf>
  vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 af 3e 00 00       	call   f0103f3d <vcprintf>
  cprintf("\n");
f010008e:	c7 04 24 5d 78 10 f0 	movl   $0xf010785d,(%esp)
f0100095:	e8 d6 3e 00 00       	call   f0103f70 <cprintf>
  va_end(ap);

dead:
  /* break into the kernel monitor */
  while (1)
    monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 3e 09 00 00       	call   f01009e4 <monitor>
f01000a6:	eb f2                	jmp    f010009a <_panic+0x5a>

f01000a8 <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f01000a8:	55                   	push   %ebp
f01000a9:	89 e5                	mov    %esp,%ebp
f01000ab:	53                   	push   %ebx
f01000ac:	83 ec 14             	sub    $0x14,%esp
  extern char edata[], end[];

  // Before doing anything else, complete the ELF loading process.
  // Clear the uninitialized global data (BSS) section of our program.
  // This ensures that all static/global variables start out zero.
  memset(edata, 0, end - edata);
f01000af:	b8 08 e0 24 f0       	mov    $0xf024e008,%eax
f01000b4:	2d a9 b0 20 f0       	sub    $0xf020b0a9,%eax
f01000b9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000c4:	00 
f01000c5:	c7 04 24 a9 b0 20 f0 	movl   $0xf020b0a9,(%esp)
f01000cc:	e8 76 61 00 00       	call   f0106247 <memset>

  // Initialize the console.
  // Can't call cprintf until after we do this!
  cons_init();
f01000d1:	e8 b9 05 00 00       	call   f010068f <cons_init>

  cprintf("6828 decimal is %o octal!\n", 6828);
f01000d6:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000dd:	00 
f01000de:	c7 04 24 ec 6f 10 f0 	movl   $0xf0106fec,(%esp)
f01000e5:	e8 86 3e 00 00       	call   f0103f70 <cprintf>

  // Lab 2 memory management initialization functions
  mem_init();
f01000ea:	e8 26 14 00 00       	call   f0101515 <mem_init>

  // Lab 3 user environment initialization functions
  env_init();
f01000ef:	e8 72 36 00 00       	call   f0103766 <env_init>
  trap_init();
f01000f4:	e8 8f 3f 00 00       	call   f0104088 <trap_init>

  // Lab 4 multiprocessor initialization functions
  mp_init();
f01000f9:	e8 8c 64 00 00       	call   f010658a <mp_init>
  lapic_init();
f01000fe:	66 90                	xchg   %ax,%ax
f0100100:	e8 af 67 00 00       	call   f01068b4 <lapic_init>

  // Lab 4 multitasking initialization functions
  pic_init();
f0100105:	e8 96 3d 00 00       	call   f0103ea0 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010010a:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100111:	e8 01 6a 00 00       	call   f0106b17 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100116:	83 3d 88 ce 20 f0 07 	cmpl   $0x7,0xf020ce88
f010011d:	77 24                	ja     f0100143 <i386_init+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010011f:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f0100126:	00 
f0100127:	c7 44 24 08 a4 6f 10 	movl   $0xf0106fa4,0x8(%esp)
f010012e:	f0 
f010012f:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0100136:	00 
f0100137:	c7 04 24 07 70 10 f0 	movl   $0xf0107007,(%esp)
f010013e:	e8 fd fe ff ff       	call   f0100040 <_panic>
  void *code;
  struct CpuInfo *c;

  // Write entry code to unused memory at MPENTRY_PADDR
  code = KADDR(MPENTRY_PADDR);
  memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100143:	b8 c2 64 10 f0       	mov    $0xf01064c2,%eax
f0100148:	2d 48 64 10 f0       	sub    $0xf0106448,%eax
f010014d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100151:	c7 44 24 04 48 64 10 	movl   $0xf0106448,0x4(%esp)
f0100158:	f0 
f0100159:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f0100160:	e8 2f 61 00 00       	call   f0106294 <memmove>

  // Boot each AP one at a time
  for (c = cpus; c < cpus + ncpu; c++) {
f0100165:	bb 20 d0 20 f0       	mov    $0xf020d020,%ebx
f010016a:	eb 4d                	jmp    f01001b9 <i386_init+0x111>
    if (c == cpus + cpunum())              // We've started already.
f010016c:	e8 28 67 00 00       	call   f0106899 <cpunum>
f0100171:	6b c0 74             	imul   $0x74,%eax,%eax
f0100174:	05 20 d0 20 f0       	add    $0xf020d020,%eax
f0100179:	39 c3                	cmp    %eax,%ebx
f010017b:	74 39                	je     f01001b6 <i386_init+0x10e>
f010017d:	89 d8                	mov    %ebx,%eax
f010017f:	2d 20 d0 20 f0       	sub    $0xf020d020,%eax
      continue;

    // Tell mpentry.S what stack to use
    mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100184:	c1 f8 02             	sar    $0x2,%eax
f0100187:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010018d:	c1 e0 0f             	shl    $0xf,%eax
f0100190:	8d 80 00 60 21 f0    	lea    -0xfdea000(%eax),%eax
f0100196:	a3 84 ce 20 f0       	mov    %eax,0xf020ce84
    // Start the CPU at mpentry_start
    lapic_startap(c->cpu_id, PADDR(code));
f010019b:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f01001a2:	00 
f01001a3:	0f b6 03             	movzbl (%ebx),%eax
f01001a6:	89 04 24             	mov    %eax,(%esp)
f01001a9:	e8 56 68 00 00       	call   f0106a04 <lapic_startap>
    // Wait for the CPU to finish some basic setup in mp_main()
    while (c->cpu_status != CPU_STARTED)
f01001ae:	8b 43 04             	mov    0x4(%ebx),%eax
f01001b1:	83 f8 01             	cmp    $0x1,%eax
f01001b4:	75 f8                	jne    f01001ae <i386_init+0x106>
  // Write entry code to unused memory at MPENTRY_PADDR
  code = KADDR(MPENTRY_PADDR);
  memmove(code, mpentry_start, mpentry_end - mpentry_start);

  // Boot each AP one at a time
  for (c = cpus; c < cpus + ncpu; c++) {
f01001b6:	83 c3 74             	add    $0x74,%ebx
f01001b9:	6b 05 c4 d3 20 f0 74 	imul   $0x74,0xf020d3c4,%eax
f01001c0:	05 20 d0 20 f0       	add    $0xf020d020,%eax
f01001c5:	39 c3                	cmp    %eax,%ebx
f01001c7:	72 a3                	jb     f010016c <i386_init+0xc4>

  // Starting non-boot CPUs
  boot_aps();

  // Start fs.
  ENV_CREATE(fs_fs, ENV_TYPE_FS);
f01001c9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01001d0:	00 
f01001d1:	c7 04 24 2e 8e 1c f0 	movl   $0xf01c8e2e,(%esp)
f01001d8:	e8 65 37 00 00       	call   f0103942 <env_create>
#if defined(TEST)
  // Don't touch -- used by grading script!
  ENV_CREATE(TEST, ENV_TYPE_USER);
#else
  // Touch all you want.
  ENV_CREATE(user_icode, ENV_TYPE_USER);
f01001dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01001e4:	00 
f01001e5:	c7 04 24 61 3f 1c f0 	movl   $0xf01c3f61,(%esp)
f01001ec:	e8 51 37 00 00       	call   f0103942 <env_create>
#endif  // TEST*

  // Should not be necessary - drains keyboard because interrupt has given up.
  kbd_intr();
f01001f1:	e8 3d 04 00 00       	call   f0100633 <kbd_intr>

  // Schedule and run the first user environment!
  sched_yield();
f01001f6:	e8 d3 4c 00 00       	call   f0104ece <sched_yield>

f01001fb <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001fb:	55                   	push   %ebp
f01001fc:	89 e5                	mov    %esp,%ebp
f01001fe:	83 ec 18             	sub    $0x18,%esp
  // We are in high EIP now, safe to switch to kern_pgdir
  lcr3(PADDR(kern_pgdir));
f0100201:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100206:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010020b:	77 20                	ja     f010022d <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010020d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100211:	c7 44 24 08 c8 6f 10 	movl   $0xf0106fc8,0x8(%esp)
f0100218:	f0 
f0100219:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
f0100220:	00 
f0100221:	c7 04 24 07 70 10 f0 	movl   $0xf0107007,(%esp)
f0100228:	e8 13 fe ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010022d:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
  __asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100232:	0f 22 d8             	mov    %eax,%cr3
  cprintf("SMP: CPU %d starting\n", cpunum());
f0100235:	e8 5f 66 00 00       	call   f0106899 <cpunum>
f010023a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010023e:	c7 04 24 13 70 10 f0 	movl   $0xf0107013,(%esp)
f0100245:	e8 26 3d 00 00       	call   f0103f70 <cprintf>

  lapic_init();
f010024a:	e8 65 66 00 00       	call   f01068b4 <lapic_init>
  env_init_percpu();
f010024f:	e8 e8 34 00 00       	call   f010373c <env_init_percpu>
  trap_init_percpu();
f0100254:	e8 37 3d 00 00       	call   f0103f90 <trap_init_percpu>
  xchg(&thiscpu->cpu_status, CPU_STARTED);       // tell boot_aps() we're up
f0100259:	e8 3b 66 00 00       	call   f0106899 <cpunum>
f010025e:	6b d0 74             	imul   $0x74,%eax,%edx
f0100261:	81 c2 20 d0 20 f0    	add    $0xf020d020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
  uint32_t result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile ("lock; xchgl %0, %1" :
f0100267:	b8 01 00 00 00       	mov    $0x1,%eax
f010026c:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100270:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100277:	e8 9b 68 00 00       	call   f0106b17 <spin_lock>
  // to start running processes on this CPU.  But make sure that
  // only one CPU can enter the scheduler at a time!
  //
  // Your code here:
  lock_kernel();
  sched_yield();
f010027c:	e8 4d 4c 00 00       	call   f0104ece <sched_yield>

f0100281 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt, ...)
{
f0100281:	55                   	push   %ebp
f0100282:	89 e5                	mov    %esp,%ebp
f0100284:	53                   	push   %ebx
f0100285:	83 ec 14             	sub    $0x14,%esp
  va_list ap;

  va_start(ap, fmt);
f0100288:	8d 5d 14             	lea    0x14(%ebp),%ebx
  cprintf("kernel warning at %s:%d: ", file, line);
f010028b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010028e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100292:	8b 45 08             	mov    0x8(%ebp),%eax
f0100295:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100299:	c7 04 24 29 70 10 f0 	movl   $0xf0107029,(%esp)
f01002a0:	e8 cb 3c 00 00       	call   f0103f70 <cprintf>
  vcprintf(fmt, ap);
f01002a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01002a9:	8b 45 10             	mov    0x10(%ebp),%eax
f01002ac:	89 04 24             	mov    %eax,(%esp)
f01002af:	e8 89 3c 00 00       	call   f0103f3d <vcprintf>
  cprintf("\n");
f01002b4:	c7 04 24 5d 78 10 f0 	movl   $0xf010785d,(%esp)
f01002bb:	e8 b0 3c 00 00       	call   f0103f70 <cprintf>
  va_end(ap);
}
f01002c0:	83 c4 14             	add    $0x14,%esp
f01002c3:	5b                   	pop    %ebx
f01002c4:	5d                   	pop    %ebp
f01002c5:	c3                   	ret    
f01002c6:	66 90                	xchg   %ax,%ax
f01002c8:	66 90                	xchg   %ax,%ax
f01002ca:	66 90                	xchg   %ax,%ax
f01002cc:	66 90                	xchg   %ax,%ax
f01002ce:	66 90                	xchg   %ax,%ax

f01002d0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002d0:	55                   	push   %ebp
f01002d1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
  uint8_t data;
  __asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002d3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002d8:	ec                   	in     (%dx),%al
  if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002d9:	a8 01                	test   $0x1,%al
f01002db:	74 08                	je     f01002e5 <serial_proc_data+0x15>
f01002dd:	b2 f8                	mov    $0xf8,%dl
f01002df:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+COM_RX);
f01002e0:	0f b6 c0             	movzbl %al,%eax
f01002e3:	eb 05                	jmp    f01002ea <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
  if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
    return -1;
f01002e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return inb(COM1+COM_RX);
}
f01002ea:	5d                   	pop    %ebp
f01002eb:	c3                   	ret    

f01002ec <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002ec:	55                   	push   %ebp
f01002ed:	89 e5                	mov    %esp,%ebp
f01002ef:	53                   	push   %ebx
f01002f0:	83 ec 04             	sub    $0x4,%esp
f01002f3:	89 c3                	mov    %eax,%ebx
  int c;

  while ((c = (*proc)()) != -1) {
f01002f5:	eb 2a                	jmp    f0100321 <cons_intr+0x35>
    if (c == 0)
f01002f7:	85 d2                	test   %edx,%edx
f01002f9:	74 26                	je     f0100321 <cons_intr+0x35>
      continue;
    cons.buf[cons.wpos++] = c;
f01002fb:	a1 24 c2 20 f0       	mov    0xf020c224,%eax
f0100300:	8d 48 01             	lea    0x1(%eax),%ecx
f0100303:	89 0d 24 c2 20 f0    	mov    %ecx,0xf020c224
f0100309:	88 90 20 c0 20 f0    	mov    %dl,-0xfdf3fe0(%eax)
    if (cons.wpos == CONSBUFSIZE)
f010030f:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100315:	75 0a                	jne    f0100321 <cons_intr+0x35>
      cons.wpos = 0;
f0100317:	c7 05 24 c2 20 f0 00 	movl   $0x0,0xf020c224
f010031e:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
  int c;

  while ((c = (*proc)()) != -1) {
f0100321:	ff d3                	call   *%ebx
f0100323:	89 c2                	mov    %eax,%edx
f0100325:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100328:	75 cd                	jne    f01002f7 <cons_intr+0xb>
      continue;
    cons.buf[cons.wpos++] = c;
    if (cons.wpos == CONSBUFSIZE)
      cons.wpos = 0;
  }
}
f010032a:	83 c4 04             	add    $0x4,%esp
f010032d:	5b                   	pop    %ebx
f010032e:	5d                   	pop    %ebp
f010032f:	c3                   	ret    

f0100330 <kbd_proc_data>:
f0100330:	ba 64 00 00 00       	mov    $0x64,%edx
f0100335:	ec                   	in     (%dx),%al
{
  int c;
  uint8_t data;
  static uint32_t shift;

  if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100336:	a8 01                	test   $0x1,%al
f0100338:	0f 84 ef 00 00 00    	je     f010042d <kbd_proc_data+0xfd>
f010033e:	b2 60                	mov    $0x60,%dl
f0100340:	ec                   	in     (%dx),%al
f0100341:	89 c2                	mov    %eax,%edx
    return -1;

  data = inb(KBDATAP);

  if (data == 0xE0) {
f0100343:	3c e0                	cmp    $0xe0,%al
f0100345:	75 0d                	jne    f0100354 <kbd_proc_data+0x24>
    // E0 escape character
    shift |= E0ESC;
f0100347:	83 0d 00 c0 20 f0 40 	orl    $0x40,0xf020c000
    return 0;
f010034e:	b8 00 00 00 00       	mov    $0x0,%eax
    cprintf("Rebooting!\n");
    outb(0x92, 0x3);             // courtesy of Chris Frost
  }

  return c;
}
f0100353:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100354:	55                   	push   %ebp
f0100355:	89 e5                	mov    %esp,%ebp
f0100357:	53                   	push   %ebx
f0100358:	83 ec 14             	sub    $0x14,%esp

  if (data == 0xE0) {
    // E0 escape character
    shift |= E0ESC;
    return 0;
  } else if (data & 0x80) {
f010035b:	84 c0                	test   %al,%al
f010035d:	79 37                	jns    f0100396 <kbd_proc_data+0x66>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
f010035f:	8b 0d 00 c0 20 f0    	mov    0xf020c000,%ecx
f0100365:	89 cb                	mov    %ecx,%ebx
f0100367:	83 e3 40             	and    $0x40,%ebx
f010036a:	83 e0 7f             	and    $0x7f,%eax
f010036d:	85 db                	test   %ebx,%ebx
f010036f:	0f 44 d0             	cmove  %eax,%edx
    shift &= ~(shiftcode[data] | E0ESC);
f0100372:	0f b6 d2             	movzbl %dl,%edx
f0100375:	0f b6 82 a0 71 10 f0 	movzbl -0xfef8e60(%edx),%eax
f010037c:	83 c8 40             	or     $0x40,%eax
f010037f:	0f b6 c0             	movzbl %al,%eax
f0100382:	f7 d0                	not    %eax
f0100384:	21 c1                	and    %eax,%ecx
f0100386:	89 0d 00 c0 20 f0    	mov    %ecx,0xf020c000
    return 0;
f010038c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100391:	e9 9d 00 00 00       	jmp    f0100433 <kbd_proc_data+0x103>
  } else if (shift & E0ESC) {
f0100396:	8b 0d 00 c0 20 f0    	mov    0xf020c000,%ecx
f010039c:	f6 c1 40             	test   $0x40,%cl
f010039f:	74 0e                	je     f01003af <kbd_proc_data+0x7f>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
f01003a1:	83 c8 80             	or     $0xffffff80,%eax
f01003a4:	89 c2                	mov    %eax,%edx
    shift &= ~E0ESC;
f01003a6:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003a9:	89 0d 00 c0 20 f0    	mov    %ecx,0xf020c000
  }

  shift |= shiftcode[data];
f01003af:	0f b6 d2             	movzbl %dl,%edx
f01003b2:	0f b6 82 a0 71 10 f0 	movzbl -0xfef8e60(%edx),%eax
f01003b9:	0b 05 00 c0 20 f0    	or     0xf020c000,%eax
  shift ^= togglecode[data];
f01003bf:	0f b6 8a a0 70 10 f0 	movzbl -0xfef8f60(%edx),%ecx
f01003c6:	31 c8                	xor    %ecx,%eax
f01003c8:	a3 00 c0 20 f0       	mov    %eax,0xf020c000

  c = charcode[shift & (CTL | SHIFT)][data];
f01003cd:	89 c1                	mov    %eax,%ecx
f01003cf:	83 e1 03             	and    $0x3,%ecx
f01003d2:	8b 0c 8d 80 70 10 f0 	mov    -0xfef8f80(,%ecx,4),%ecx
f01003d9:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01003dd:	0f b6 da             	movzbl %dl,%ebx
  if (shift & CAPSLOCK) {
f01003e0:	a8 08                	test   $0x8,%al
f01003e2:	74 1b                	je     f01003ff <kbd_proc_data+0xcf>
    if ('a' <= c && c <= 'z')
f01003e4:	89 da                	mov    %ebx,%edx
f01003e6:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01003e9:	83 f9 19             	cmp    $0x19,%ecx
f01003ec:	77 05                	ja     f01003f3 <kbd_proc_data+0xc3>
      c += 'A' - 'a';
f01003ee:	83 eb 20             	sub    $0x20,%ebx
f01003f1:	eb 0c                	jmp    f01003ff <kbd_proc_data+0xcf>
    else if ('A' <= c && c <= 'Z')
f01003f3:	83 ea 41             	sub    $0x41,%edx
      c += 'a' - 'A';
f01003f6:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003f9:	83 fa 19             	cmp    $0x19,%edx
f01003fc:	0f 46 d9             	cmovbe %ecx,%ebx
  }

  // Process special keys
  // Ctrl-Alt-Del: reboot
  if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003ff:	f7 d0                	not    %eax
f0100401:	89 c2                	mov    %eax,%edx
    cprintf("Rebooting!\n");
    outb(0x92, 0x3);             // courtesy of Chris Frost
  }

  return c;
f0100403:	89 d8                	mov    %ebx,%eax
      c += 'a' - 'A';
  }

  // Process special keys
  // Ctrl-Alt-Del: reboot
  if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100405:	f6 c2 06             	test   $0x6,%dl
f0100408:	75 29                	jne    f0100433 <kbd_proc_data+0x103>
f010040a:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100410:	75 21                	jne    f0100433 <kbd_proc_data+0x103>
    cprintf("Rebooting!\n");
f0100412:	c7 04 24 43 70 10 f0 	movl   $0xf0107043,(%esp)
f0100419:	e8 52 3b 00 00       	call   f0103f70 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
  __asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010041e:	ba 92 00 00 00       	mov    $0x92,%edx
f0100423:	b8 03 00 00 00       	mov    $0x3,%eax
f0100428:	ee                   	out    %al,(%dx)
    outb(0x92, 0x3);             // courtesy of Chris Frost
  }

  return c;
f0100429:	89 d8                	mov    %ebx,%eax
f010042b:	eb 06                	jmp    f0100433 <kbd_proc_data+0x103>
  int c;
  uint8_t data;
  static uint32_t shift;

  if ((inb(KBSTATP) & KBS_DIB) == 0)
    return -1;
f010042d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100432:	c3                   	ret    
    cprintf("Rebooting!\n");
    outb(0x92, 0x3);             // courtesy of Chris Frost
  }

  return c;
}
f0100433:	83 c4 14             	add    $0x14,%esp
f0100436:	5b                   	pop    %ebx
f0100437:	5d                   	pop    %ebp
f0100438:	c3                   	ret    

f0100439 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100439:	55                   	push   %ebp
f010043a:	89 e5                	mov    %esp,%ebp
f010043c:	57                   	push   %edi
f010043d:	56                   	push   %esi
f010043e:	53                   	push   %ebx
f010043f:	83 ec 1c             	sub    $0x1c,%esp
f0100442:	89 c7                	mov    %eax,%edi
f0100444:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
  uint8_t data;
  __asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100449:	be fd 03 00 00       	mov    $0x3fd,%esi
f010044e:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100453:	eb 06                	jmp    f010045b <cons_putc+0x22>
f0100455:	89 ca                	mov    %ecx,%edx
f0100457:	ec                   	in     (%dx),%al
f0100458:	ec                   	in     (%dx),%al
f0100459:	ec                   	in     (%dx),%al
f010045a:	ec                   	in     (%dx),%al
f010045b:	89 f2                	mov    %esi,%edx
f010045d:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
  int i;

  for (i = 0;
f010045e:	a8 20                	test   $0x20,%al
f0100460:	75 05                	jne    f0100467 <cons_putc+0x2e>
       !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100462:	83 eb 01             	sub    $0x1,%ebx
f0100465:	75 ee                	jne    f0100455 <cons_putc+0x1c>
       i++)
    delay();

  outb(COM1 + COM_TX, c);
f0100467:	89 f8                	mov    %edi,%eax
f0100469:	0f b6 c0             	movzbl %al,%eax
f010046c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
  __asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010046f:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100474:	ee                   	out    %al,(%dx)
f0100475:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
  uint8_t data;
  __asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010047a:	be 79 03 00 00       	mov    $0x379,%esi
f010047f:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100484:	eb 06                	jmp    f010048c <cons_putc+0x53>
f0100486:	89 ca                	mov    %ecx,%edx
f0100488:	ec                   	in     (%dx),%al
f0100489:	ec                   	in     (%dx),%al
f010048a:	ec                   	in     (%dx),%al
f010048b:	ec                   	in     (%dx),%al
f010048c:	89 f2                	mov    %esi,%edx
f010048e:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
  int i;

  for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010048f:	84 c0                	test   %al,%al
f0100491:	78 05                	js     f0100498 <cons_putc+0x5f>
f0100493:	83 eb 01             	sub    $0x1,%ebx
f0100496:	75 ee                	jne    f0100486 <cons_putc+0x4d>
}

static __inline void
outb(int port, uint8_t data)
{
  __asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100498:	ba 78 03 00 00       	mov    $0x378,%edx
f010049d:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f01004a1:	ee                   	out    %al,(%dx)
f01004a2:	b2 7a                	mov    $0x7a,%dl
f01004a4:	b8 0d 00 00 00       	mov    $0xd,%eax
f01004a9:	ee                   	out    %al,(%dx)
f01004aa:	b8 08 00 00 00       	mov    $0x8,%eax
f01004af:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
  // if no attribute given, then use black on white
  if (!(c & ~0xFF))
f01004b0:	89 fa                	mov    %edi,%edx
f01004b2:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
    c |= 0x0700;
f01004b8:	89 f8                	mov    %edi,%eax
f01004ba:	80 cc 07             	or     $0x7,%ah
f01004bd:	85 d2                	test   %edx,%edx
f01004bf:	0f 44 f8             	cmove  %eax,%edi

  switch (c & 0xff) {
f01004c2:	89 f8                	mov    %edi,%eax
f01004c4:	0f b6 c0             	movzbl %al,%eax
f01004c7:	83 f8 09             	cmp    $0x9,%eax
f01004ca:	74 76                	je     f0100542 <cons_putc+0x109>
f01004cc:	83 f8 09             	cmp    $0x9,%eax
f01004cf:	7f 0a                	jg     f01004db <cons_putc+0xa2>
f01004d1:	83 f8 08             	cmp    $0x8,%eax
f01004d4:	74 16                	je     f01004ec <cons_putc+0xb3>
f01004d6:	e9 9b 00 00 00       	jmp    f0100576 <cons_putc+0x13d>
f01004db:	83 f8 0a             	cmp    $0xa,%eax
f01004de:	66 90                	xchg   %ax,%ax
f01004e0:	74 3a                	je     f010051c <cons_putc+0xe3>
f01004e2:	83 f8 0d             	cmp    $0xd,%eax
f01004e5:	74 3d                	je     f0100524 <cons_putc+0xeb>
f01004e7:	e9 8a 00 00 00       	jmp    f0100576 <cons_putc+0x13d>
  case '\b':
    if (crt_pos > 0) {
f01004ec:	0f b7 05 28 c2 20 f0 	movzwl 0xf020c228,%eax
f01004f3:	66 85 c0             	test   %ax,%ax
f01004f6:	0f 84 e5 00 00 00    	je     f01005e1 <cons_putc+0x1a8>
      crt_pos--;
f01004fc:	83 e8 01             	sub    $0x1,%eax
f01004ff:	66 a3 28 c2 20 f0    	mov    %ax,0xf020c228
      crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100505:	0f b7 c0             	movzwl %ax,%eax
f0100508:	66 81 e7 00 ff       	and    $0xff00,%di
f010050d:	83 cf 20             	or     $0x20,%edi
f0100510:	8b 15 2c c2 20 f0    	mov    0xf020c22c,%edx
f0100516:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010051a:	eb 78                	jmp    f0100594 <cons_putc+0x15b>
    }
    break;
  case '\n':
    crt_pos += CRT_COLS;
f010051c:	66 83 05 28 c2 20 f0 	addw   $0x50,0xf020c228
f0100523:	50 
  /* fallthru */
  case '\r':
    crt_pos -= (crt_pos % CRT_COLS);
f0100524:	0f b7 05 28 c2 20 f0 	movzwl 0xf020c228,%eax
f010052b:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100531:	c1 e8 16             	shr    $0x16,%eax
f0100534:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100537:	c1 e0 04             	shl    $0x4,%eax
f010053a:	66 a3 28 c2 20 f0    	mov    %ax,0xf020c228
f0100540:	eb 52                	jmp    f0100594 <cons_putc+0x15b>
    break;
  case '\t':
    cons_putc(' ');
f0100542:	b8 20 00 00 00       	mov    $0x20,%eax
f0100547:	e8 ed fe ff ff       	call   f0100439 <cons_putc>
    cons_putc(' ');
f010054c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100551:	e8 e3 fe ff ff       	call   f0100439 <cons_putc>
    cons_putc(' ');
f0100556:	b8 20 00 00 00       	mov    $0x20,%eax
f010055b:	e8 d9 fe ff ff       	call   f0100439 <cons_putc>
    cons_putc(' ');
f0100560:	b8 20 00 00 00       	mov    $0x20,%eax
f0100565:	e8 cf fe ff ff       	call   f0100439 <cons_putc>
    cons_putc(' ');
f010056a:	b8 20 00 00 00       	mov    $0x20,%eax
f010056f:	e8 c5 fe ff ff       	call   f0100439 <cons_putc>
f0100574:	eb 1e                	jmp    f0100594 <cons_putc+0x15b>
    break;
  default:
    crt_buf[crt_pos++] = c;                     /* write the character */
f0100576:	0f b7 05 28 c2 20 f0 	movzwl 0xf020c228,%eax
f010057d:	8d 50 01             	lea    0x1(%eax),%edx
f0100580:	66 89 15 28 c2 20 f0 	mov    %dx,0xf020c228
f0100587:	0f b7 c0             	movzwl %ax,%eax
f010058a:	8b 15 2c c2 20 f0    	mov    0xf020c22c,%edx
f0100590:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
    break;
  }

  // What is the purpose of this?
  if (crt_pos >= CRT_SIZE) {
f0100594:	66 81 3d 28 c2 20 f0 	cmpw   $0x7cf,0xf020c228
f010059b:	cf 07 
f010059d:	76 42                	jbe    f01005e1 <cons_putc+0x1a8>
    int i;

    memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010059f:	a1 2c c2 20 f0       	mov    0xf020c22c,%eax
f01005a4:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01005ab:	00 
f01005ac:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005b2:	89 54 24 04          	mov    %edx,0x4(%esp)
f01005b6:	89 04 24             	mov    %eax,(%esp)
f01005b9:	e8 d6 5c 00 00       	call   f0106294 <memmove>
    for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
      crt_buf[i] = 0x0700 | ' ';
f01005be:	8b 15 2c c2 20 f0    	mov    0xf020c22c,%edx
  // What is the purpose of this?
  if (crt_pos >= CRT_SIZE) {
    int i;

    memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
    for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005c4:	b8 80 07 00 00       	mov    $0x780,%eax
      crt_buf[i] = 0x0700 | ' ';
f01005c9:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
  // What is the purpose of this?
  if (crt_pos >= CRT_SIZE) {
    int i;

    memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
    for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005cf:	83 c0 01             	add    $0x1,%eax
f01005d2:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01005d7:	75 f0                	jne    f01005c9 <cons_putc+0x190>
      crt_buf[i] = 0x0700 | ' ';
    crt_pos -= CRT_COLS;
f01005d9:	66 83 2d 28 c2 20 f0 	subw   $0x50,0xf020c228
f01005e0:	50 
  }

  /* move that little blinky thing */
  outb(addr_6845, 14);
f01005e1:	8b 0d 30 c2 20 f0    	mov    0xf020c230,%ecx
f01005e7:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005ec:	89 ca                	mov    %ecx,%edx
f01005ee:	ee                   	out    %al,(%dx)
  outb(addr_6845 + 1, crt_pos >> 8);
f01005ef:	0f b7 1d 28 c2 20 f0 	movzwl 0xf020c228,%ebx
f01005f6:	8d 71 01             	lea    0x1(%ecx),%esi
f01005f9:	89 d8                	mov    %ebx,%eax
f01005fb:	66 c1 e8 08          	shr    $0x8,%ax
f01005ff:	89 f2                	mov    %esi,%edx
f0100601:	ee                   	out    %al,(%dx)
f0100602:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100607:	89 ca                	mov    %ecx,%edx
f0100609:	ee                   	out    %al,(%dx)
f010060a:	89 d8                	mov    %ebx,%eax
f010060c:	89 f2                	mov    %esi,%edx
f010060e:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
  serial_putc(c);
  lpt_putc(c);
  cga_putc(c);
}
f010060f:	83 c4 1c             	add    $0x1c,%esp
f0100612:	5b                   	pop    %ebx
f0100613:	5e                   	pop    %esi
f0100614:	5f                   	pop    %edi
f0100615:	5d                   	pop    %ebp
f0100616:	c3                   	ret    

f0100617 <serial_intr>:
}

void
serial_intr(void)
{
  if (serial_exists)
f0100617:	80 3d 34 c2 20 f0 00 	cmpb   $0x0,0xf020c234
f010061e:	74 11                	je     f0100631 <serial_intr+0x1a>
  return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100620:	55                   	push   %ebp
f0100621:	89 e5                	mov    %esp,%ebp
f0100623:	83 ec 08             	sub    $0x8,%esp
  if (serial_exists)
    cons_intr(serial_proc_data);
f0100626:	b8 d0 02 10 f0       	mov    $0xf01002d0,%eax
f010062b:	e8 bc fc ff ff       	call   f01002ec <cons_intr>
}
f0100630:	c9                   	leave  
f0100631:	f3 c3                	repz ret 

f0100633 <kbd_intr>:
  return c;
}

void
kbd_intr(void)
{
f0100633:	55                   	push   %ebp
f0100634:	89 e5                	mov    %esp,%ebp
f0100636:	83 ec 08             	sub    $0x8,%esp
  cons_intr(kbd_proc_data);
f0100639:	b8 30 03 10 f0       	mov    $0xf0100330,%eax
f010063e:	e8 a9 fc ff ff       	call   f01002ec <cons_intr>
}
f0100643:	c9                   	leave  
f0100644:	c3                   	ret    

f0100645 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100645:	55                   	push   %ebp
f0100646:	89 e5                	mov    %esp,%ebp
f0100648:	83 ec 08             	sub    $0x8,%esp
  int c;

  // poll for any pending input characters,
  // so that this function works even when interrupts are disabled
  // (e.g., when called from the kernel monitor).
  serial_intr();
f010064b:	e8 c7 ff ff ff       	call   f0100617 <serial_intr>
  kbd_intr();
f0100650:	e8 de ff ff ff       	call   f0100633 <kbd_intr>

  // grab the next character from the input buffer.
  if (cons.rpos != cons.wpos) {
f0100655:	a1 20 c2 20 f0       	mov    0xf020c220,%eax
f010065a:	3b 05 24 c2 20 f0    	cmp    0xf020c224,%eax
f0100660:	74 26                	je     f0100688 <cons_getc+0x43>
    c = cons.buf[cons.rpos++];
f0100662:	8d 50 01             	lea    0x1(%eax),%edx
f0100665:	89 15 20 c2 20 f0    	mov    %edx,0xf020c220
f010066b:	0f b6 88 20 c0 20 f0 	movzbl -0xfdf3fe0(%eax),%ecx
    if (cons.rpos == CONSBUFSIZE)
      cons.rpos = 0;
    return c;
f0100672:	89 c8                	mov    %ecx,%eax
  kbd_intr();

  // grab the next character from the input buffer.
  if (cons.rpos != cons.wpos) {
    c = cons.buf[cons.rpos++];
    if (cons.rpos == CONSBUFSIZE)
f0100674:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010067a:	75 11                	jne    f010068d <cons_getc+0x48>
      cons.rpos = 0;
f010067c:	c7 05 20 c2 20 f0 00 	movl   $0x0,0xf020c220
f0100683:	00 00 00 
f0100686:	eb 05                	jmp    f010068d <cons_getc+0x48>
    return c;
  }
  return 0;
f0100688:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010068d:	c9                   	leave  
f010068e:	c3                   	ret    

f010068f <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010068f:	55                   	push   %ebp
f0100690:	89 e5                	mov    %esp,%ebp
f0100692:	57                   	push   %edi
f0100693:	56                   	push   %esi
f0100694:	53                   	push   %ebx
f0100695:	83 ec 1c             	sub    $0x1c,%esp
  volatile uint16_t *cp;
  uint16_t was;
  unsigned pos;

  cp = (uint16_t*)(KERNBASE + CGA_BUF);
  was = *cp;
f0100698:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
  *cp = (uint16_t)0xA55A;
f010069f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01006a6:	5a a5 
  if (*cp != 0xA55A) {
f01006a8:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01006af:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006b3:	74 11                	je     f01006c6 <cons_init+0x37>
    cp = (uint16_t*)(KERNBASE + MONO_BUF);
    addr_6845 = MONO_BASE;
f01006b5:	c7 05 30 c2 20 f0 b4 	movl   $0x3b4,0xf020c230
f01006bc:	03 00 00 

  cp = (uint16_t*)(KERNBASE + CGA_BUF);
  was = *cp;
  *cp = (uint16_t)0xA55A;
  if (*cp != 0xA55A) {
    cp = (uint16_t*)(KERNBASE + MONO_BUF);
f01006bf:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f01006c4:	eb 16                	jmp    f01006dc <cons_init+0x4d>
    addr_6845 = MONO_BASE;
  } else {
    *cp = was;
f01006c6:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
    addr_6845 = CGA_BASE;
f01006cd:	c7 05 30 c2 20 f0 d4 	movl   $0x3d4,0xf020c230
f01006d4:	03 00 00 
{
  volatile uint16_t *cp;
  uint16_t was;
  unsigned pos;

  cp = (uint16_t*)(KERNBASE + CGA_BUF);
f01006d7:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
    *cp = was;
    addr_6845 = CGA_BASE;
  }

  /* Extract cursor location */
  outb(addr_6845, 14);
f01006dc:	8b 0d 30 c2 20 f0    	mov    0xf020c230,%ecx
f01006e2:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006e7:	89 ca                	mov    %ecx,%edx
f01006e9:	ee                   	out    %al,(%dx)
  pos = inb(addr_6845 + 1) << 8;
f01006ea:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
  uint8_t data;
  __asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ed:	89 da                	mov    %ebx,%edx
f01006ef:	ec                   	in     (%dx),%al
f01006f0:	0f b6 f0             	movzbl %al,%esi
f01006f3:	c1 e6 08             	shl    $0x8,%esi
}

static __inline void
outb(int port, uint8_t data)
{
  __asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006f6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006fb:	89 ca                	mov    %ecx,%edx
f01006fd:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
  uint8_t data;
  __asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006fe:	89 da                	mov    %ebx,%edx
f0100700:	ec                   	in     (%dx),%al
  outb(addr_6845, 15);
  pos |= inb(addr_6845 + 1);

  crt_buf = (uint16_t*)cp;
f0100701:	89 3d 2c c2 20 f0    	mov    %edi,0xf020c22c

  /* Extract cursor location */
  outb(addr_6845, 14);
  pos = inb(addr_6845 + 1) << 8;
  outb(addr_6845, 15);
  pos |= inb(addr_6845 + 1);
f0100707:	0f b6 d8             	movzbl %al,%ebx
f010070a:	09 de                	or     %ebx,%esi

  crt_buf = (uint16_t*)cp;
  crt_pos = pos;
f010070c:	66 89 35 28 c2 20 f0 	mov    %si,0xf020c228

static void
kbd_init(void)
{
  // Drain the kbd buffer so that QEMU generates interrupts.
  kbd_intr();
f0100713:	e8 1b ff ff ff       	call   f0100633 <kbd_intr>
  irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100718:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f010071f:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100724:	89 04 24             	mov    %eax,(%esp)
f0100727:	e8 05 37 00 00       	call   f0103e31 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
  __asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010072c:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100731:	b8 00 00 00 00       	mov    $0x0,%eax
f0100736:	89 f2                	mov    %esi,%edx
f0100738:	ee                   	out    %al,(%dx)
f0100739:	b2 fb                	mov    $0xfb,%dl
f010073b:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100740:	ee                   	out    %al,(%dx)
f0100741:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100746:	b8 0c 00 00 00       	mov    $0xc,%eax
f010074b:	89 da                	mov    %ebx,%edx
f010074d:	ee                   	out    %al,(%dx)
f010074e:	b2 f9                	mov    $0xf9,%dl
f0100750:	b8 00 00 00 00       	mov    $0x0,%eax
f0100755:	ee                   	out    %al,(%dx)
f0100756:	b2 fb                	mov    $0xfb,%dl
f0100758:	b8 03 00 00 00       	mov    $0x3,%eax
f010075d:	ee                   	out    %al,(%dx)
f010075e:	b2 fc                	mov    $0xfc,%dl
f0100760:	b8 00 00 00 00       	mov    $0x0,%eax
f0100765:	ee                   	out    %al,(%dx)
f0100766:	b2 f9                	mov    $0xf9,%dl
f0100768:	b8 01 00 00 00       	mov    $0x1,%eax
f010076d:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
  uint8_t data;
  __asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010076e:	b2 fd                	mov    $0xfd,%dl
f0100770:	ec                   	in     (%dx),%al
  // Enable rcv interrupts
  outb(COM1+COM_IER, COM_IER_RDI);

  // Clear any preexisting overrun indications and interrupts
  // Serial port doesn't exist if COM_LSR returns 0xFF
  serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100771:	3c ff                	cmp    $0xff,%al
f0100773:	0f 95 c1             	setne  %cl
f0100776:	88 0d 34 c2 20 f0    	mov    %cl,0xf020c234
f010077c:	89 f2                	mov    %esi,%edx
f010077e:	ec                   	in     (%dx),%al
f010077f:	89 da                	mov    %ebx,%edx
f0100781:	ec                   	in     (%dx),%al
  (void)inb(COM1+COM_IIR);
  (void)inb(COM1+COM_RX);

  // Enable serial interrupts
  if (serial_exists)
f0100782:	84 c9                	test   %cl,%cl
f0100784:	74 1d                	je     f01007a3 <cons_init+0x114>
    irq_setmask_8259A(irq_mask_8259A & ~(1<<4));
f0100786:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f010078d:	25 ef ff 00 00       	and    $0xffef,%eax
f0100792:	89 04 24             	mov    %eax,(%esp)
f0100795:	e8 97 36 00 00       	call   f0103e31 <irq_setmask_8259A>
{
  cga_init();
  kbd_init();
  serial_init();

  if (!serial_exists)
f010079a:	80 3d 34 c2 20 f0 00 	cmpb   $0x0,0xf020c234
f01007a1:	75 0c                	jne    f01007af <cons_init+0x120>
    cprintf("Serial port does not exist!\n");
f01007a3:	c7 04 24 4f 70 10 f0 	movl   $0xf010704f,(%esp)
f01007aa:	e8 c1 37 00 00       	call   f0103f70 <cprintf>
}
f01007af:	83 c4 1c             	add    $0x1c,%esp
f01007b2:	5b                   	pop    %ebx
f01007b3:	5e                   	pop    %esi
f01007b4:	5f                   	pop    %edi
f01007b5:	5d                   	pop    %ebp
f01007b6:	c3                   	ret    

f01007b7 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007b7:	55                   	push   %ebp
f01007b8:	89 e5                	mov    %esp,%ebp
f01007ba:	83 ec 08             	sub    $0x8,%esp
  cons_putc(c);
f01007bd:	8b 45 08             	mov    0x8(%ebp),%eax
f01007c0:	e8 74 fc ff ff       	call   f0100439 <cons_putc>
}
f01007c5:	c9                   	leave  
f01007c6:	c3                   	ret    

f01007c7 <getchar>:

int
getchar(void)
{
f01007c7:	55                   	push   %ebp
f01007c8:	89 e5                	mov    %esp,%ebp
f01007ca:	83 ec 08             	sub    $0x8,%esp
  int c;

  while ((c = cons_getc()) == 0)
f01007cd:	e8 73 fe ff ff       	call   f0100645 <cons_getc>
f01007d2:	85 c0                	test   %eax,%eax
f01007d4:	74 f7                	je     f01007cd <getchar+0x6>
    /* do nothing */;
  return c;
}
f01007d6:	c9                   	leave  
f01007d7:	c3                   	ret    

f01007d8 <iscons>:

int
iscons(int fdnum)
{
f01007d8:	55                   	push   %ebp
f01007d9:	89 e5                	mov    %esp,%ebp
  // used by readline
  return 1;
}
f01007db:	b8 01 00 00 00       	mov    $0x1,%eax
f01007e0:	5d                   	pop    %ebp
f01007e1:	c3                   	ret    
f01007e2:	66 90                	xchg   %ax,%ax
f01007e4:	66 90                	xchg   %ax,%ax
f01007e6:	66 90                	xchg   %ax,%ax
f01007e8:	66 90                	xchg   %ax,%ax
f01007ea:	66 90                	xchg   %ax,%ax
f01007ec:	66 90                	xchg   %ax,%ax
f01007ee:	66 90                	xchg   %ax,%ax

f01007f0 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007f0:	55                   	push   %ebp
f01007f1:	89 e5                	mov    %esp,%ebp
f01007f3:	83 ec 18             	sub    $0x18,%esp
  int i;

  for (i = 0; i < NCOMMANDS; i++)
    cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007f6:	c7 44 24 08 a0 72 10 	movl   $0xf01072a0,0x8(%esp)
f01007fd:	f0 
f01007fe:	c7 44 24 04 be 72 10 	movl   $0xf01072be,0x4(%esp)
f0100805:	f0 
f0100806:	c7 04 24 c3 72 10 f0 	movl   $0xf01072c3,(%esp)
f010080d:	e8 5e 37 00 00       	call   f0103f70 <cprintf>
f0100812:	c7 44 24 08 74 73 10 	movl   $0xf0107374,0x8(%esp)
f0100819:	f0 
f010081a:	c7 44 24 04 cc 72 10 	movl   $0xf01072cc,0x4(%esp)
f0100821:	f0 
f0100822:	c7 04 24 c3 72 10 f0 	movl   $0xf01072c3,(%esp)
f0100829:	e8 42 37 00 00       	call   f0103f70 <cprintf>
f010082e:	c7 44 24 08 9c 73 10 	movl   $0xf010739c,0x8(%esp)
f0100835:	f0 
f0100836:	c7 44 24 04 d6 72 10 	movl   $0xf01072d6,0x4(%esp)
f010083d:	f0 
f010083e:	c7 04 24 c3 72 10 f0 	movl   $0xf01072c3,(%esp)
f0100845:	e8 26 37 00 00       	call   f0103f70 <cprintf>
  return 0;
}
f010084a:	b8 00 00 00 00       	mov    $0x0,%eax
f010084f:	c9                   	leave  
f0100850:	c3                   	ret    

f0100851 <mon_infokern>:

int
mon_infokern(int argc, char **argv, struct Trapframe *tf)
{
f0100851:	55                   	push   %ebp
f0100852:	89 e5                	mov    %esp,%ebp
f0100854:	83 ec 18             	sub    $0x18,%esp
  extern char _start[], entry[], etext[], edata[], end[];

  cprintf("Special kernel symbols:\n");
f0100857:	c7 04 24 e0 72 10 f0 	movl   $0xf01072e0,(%esp)
f010085e:	e8 0d 37 00 00       	call   f0103f70 <cprintf>
  cprintf("  _start                  %08x (phys)\n", _start);
f0100863:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010086a:	00 
f010086b:	c7 04 24 c0 73 10 f0 	movl   $0xf01073c0,(%esp)
f0100872:	e8 f9 36 00 00       	call   f0103f70 <cprintf>
  cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100877:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010087e:	00 
f010087f:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100886:	f0 
f0100887:	c7 04 24 e8 73 10 f0 	movl   $0xf01073e8,(%esp)
f010088e:	e8 dd 36 00 00       	call   f0103f70 <cprintf>
  cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100893:	c7 44 24 08 67 6f 10 	movl   $0x106f67,0x8(%esp)
f010089a:	00 
f010089b:	c7 44 24 04 67 6f 10 	movl   $0xf0106f67,0x4(%esp)
f01008a2:	f0 
f01008a3:	c7 04 24 0c 74 10 f0 	movl   $0xf010740c,(%esp)
f01008aa:	e8 c1 36 00 00       	call   f0103f70 <cprintf>
  cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01008af:	c7 44 24 08 a9 b0 20 	movl   $0x20b0a9,0x8(%esp)
f01008b6:	00 
f01008b7:	c7 44 24 04 a9 b0 20 	movl   $0xf020b0a9,0x4(%esp)
f01008be:	f0 
f01008bf:	c7 04 24 30 74 10 f0 	movl   $0xf0107430,(%esp)
f01008c6:	e8 a5 36 00 00       	call   f0103f70 <cprintf>
  cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01008cb:	c7 44 24 08 08 e0 24 	movl   $0x24e008,0x8(%esp)
f01008d2:	00 
f01008d3:	c7 44 24 04 08 e0 24 	movl   $0xf024e008,0x4(%esp)
f01008da:	f0 
f01008db:	c7 04 24 54 74 10 f0 	movl   $0xf0107454,(%esp)
f01008e2:	e8 89 36 00 00       	call   f0103f70 <cprintf>
  cprintf("Kernel executable memory footprint: %dKB\n",
          ROUNDUP(end - entry, 1024) / 1024);
f01008e7:	b8 07 e4 24 f0       	mov    $0xf024e407,%eax
f01008ec:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01008f1:	25 00 fc ff ff       	and    $0xfffffc00,%eax
  cprintf("  _start                  %08x (phys)\n", _start);
  cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
  cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
  cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
  cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
  cprintf("Kernel executable memory footprint: %dKB\n",
f01008f6:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01008fc:	85 c0                	test   %eax,%eax
f01008fe:	0f 48 c2             	cmovs  %edx,%eax
f0100901:	c1 f8 0a             	sar    $0xa,%eax
f0100904:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100908:	c7 04 24 78 74 10 f0 	movl   $0xf0107478,(%esp)
f010090f:	e8 5c 36 00 00       	call   f0103f70 <cprintf>
          ROUNDUP(end - entry, 1024) / 1024);
  return 0;
}
f0100914:	b8 00 00 00 00       	mov    $0x0,%eax
f0100919:	c9                   	leave  
f010091a:	c3                   	ret    

f010091b <mon_backtrace>:


int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010091b:	55                   	push   %ebp
f010091c:	89 e5                	mov    %esp,%ebp
f010091e:	57                   	push   %edi
f010091f:	56                   	push   %esi
f0100920:	53                   	push   %ebx
f0100921:	83 ec 4c             	sub    $0x4c,%esp
  cprintf("Stack backtrace:\n");
f0100924:	c7 04 24 f9 72 10 f0 	movl   $0xf01072f9,(%esp)
f010092b:	e8 40 36 00 00       	call   f0103f70 <cprintf>
  
  struct Eipdebuginfo info;
  uint32_t *ebp = (uint32_t *) read_ebp();
f0100930:	89 eb                	mov    %ebp,%ebx
  while (ebp > 0) {
    uint32_t esp = read_esp();
    uint32_t eip = ebp[1];
    cprintf("  ebp %08x eip %08x ", (uint32_t) ebp, eip);
    cprintf("args %08x %08x %08x %08x %08x\n", ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);
    if (debuginfo_eip(eip, &info) == 0){
f0100932:	8d 7d d0             	lea    -0x30(%ebp),%edi
{
  cprintf("Stack backtrace:\n");
  
  struct Eipdebuginfo info;
  uint32_t *ebp = (uint32_t *) read_ebp();
  while (ebp > 0) {
f0100935:	e9 95 00 00 00       	jmp    f01009cf <mon_backtrace+0xb4>

static __inline uint32_t
read_esp(void)
{
  uint32_t esp;
  __asm __volatile("movl %%esp,%0" : "=r" (esp));
f010093a:	89 e0                	mov    %esp,%eax
    uint32_t esp = read_esp();
    uint32_t eip = ebp[1];
f010093c:	8b 73 04             	mov    0x4(%ebx),%esi
    cprintf("  ebp %08x eip %08x ", (uint32_t) ebp, eip);
f010093f:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100943:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100947:	c7 04 24 0b 73 10 f0 	movl   $0xf010730b,(%esp)
f010094e:	e8 1d 36 00 00       	call   f0103f70 <cprintf>
    cprintf("args %08x %08x %08x %08x %08x\n", ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);
f0100953:	8b 43 18             	mov    0x18(%ebx),%eax
f0100956:	89 44 24 14          	mov    %eax,0x14(%esp)
f010095a:	8b 43 14             	mov    0x14(%ebx),%eax
f010095d:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100961:	8b 43 10             	mov    0x10(%ebx),%eax
f0100964:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100968:	8b 43 0c             	mov    0xc(%ebx),%eax
f010096b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010096f:	8b 43 08             	mov    0x8(%ebx),%eax
f0100972:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100976:	c7 04 24 a4 74 10 f0 	movl   $0xf01074a4,(%esp)
f010097d:	e8 ee 35 00 00       	call   f0103f70 <cprintf>
    if (debuginfo_eip(eip, &info) == 0){
f0100982:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100986:	89 34 24             	mov    %esi,(%esp)
f0100989:	e8 74 4d 00 00       	call   f0105702 <debuginfo_eip>
f010098e:	85 c0                	test   %eax,%eax
f0100990:	75 3b                	jne    f01009cd <mon_backtrace+0xb2>
      cprintf("         %s:%u: %.*s+", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name);
f0100992:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100995:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100999:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010099c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01009a0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01009a3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009a7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01009aa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009ae:	c7 04 24 20 73 10 f0 	movl   $0xf0107320,(%esp)
f01009b5:	e8 b6 35 00 00       	call   f0103f70 <cprintf>
      cprintf("%d\n", eip - info.eip_fn_addr);
f01009ba:	2b 75 e0             	sub    -0x20(%ebp),%esi
f01009bd:	89 74 24 04          	mov    %esi,0x4(%esp)
f01009c1:	c7 04 24 32 83 10 f0 	movl   $0xf0108332,(%esp)
f01009c8:	e8 a3 35 00 00       	call   f0103f70 <cprintf>
    }
    ebp = (uint32_t *) ebp[0];
f01009cd:	8b 1b                	mov    (%ebx),%ebx
{
  cprintf("Stack backtrace:\n");
  
  struct Eipdebuginfo info;
  uint32_t *ebp = (uint32_t *) read_ebp();
  while (ebp > 0) {
f01009cf:	85 db                	test   %ebx,%ebx
f01009d1:	0f 85 63 ff ff ff    	jne    f010093a <mon_backtrace+0x1f>
      cprintf("%d\n", eip - info.eip_fn_addr);
    }
    ebp = (uint32_t *) ebp[0];
  }
  return 0;
}
f01009d7:	b8 00 00 00 00       	mov    $0x0,%eax
f01009dc:	83 c4 4c             	add    $0x4c,%esp
f01009df:	5b                   	pop    %ebx
f01009e0:	5e                   	pop    %esi
f01009e1:	5f                   	pop    %edi
f01009e2:	5d                   	pop    %ebp
f01009e3:	c3                   	ret    

f01009e4 <monitor>:
  return 0;
}

void
monitor(struct Trapframe *tf)
{
f01009e4:	55                   	push   %ebp
f01009e5:	89 e5                	mov    %esp,%ebp
f01009e7:	57                   	push   %edi
f01009e8:	56                   	push   %esi
f01009e9:	53                   	push   %ebx
f01009ea:	83 ec 5c             	sub    $0x5c,%esp
  char *buf;

  cprintf("Welcome to the JOS kernel monitor!\n");
f01009ed:	c7 04 24 c4 74 10 f0 	movl   $0xf01074c4,(%esp)
f01009f4:	e8 77 35 00 00       	call   f0103f70 <cprintf>
  cprintf("Type 'help' for a list of commands.\n");
f01009f9:	c7 04 24 e8 74 10 f0 	movl   $0xf01074e8,(%esp)
f0100a00:	e8 6b 35 00 00       	call   f0103f70 <cprintf>

  if (tf != NULL)
f0100a05:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100a09:	74 0b                	je     f0100a16 <monitor+0x32>
    print_trapframe(tf);
f0100a0b:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a0e:	89 04 24             	mov    %eax,(%esp)
f0100a11:	e8 32 3d 00 00       	call   f0104748 <print_trapframe>

  while (1) {
    buf = readline("K> ");
f0100a16:	c7 04 24 36 73 10 f0 	movl   $0xf0107336,(%esp)
f0100a1d:	e8 be 55 00 00       	call   f0105fe0 <readline>
f0100a22:	89 c3                	mov    %eax,%ebx
    if (buf != NULL)
f0100a24:	85 c0                	test   %eax,%eax
f0100a26:	74 ee                	je     f0100a16 <monitor+0x32>
  char *argv[MAXARGS];
  int i;

  // Parse the command buffer into whitespace-separated arguments
  argc = 0;
  argv[argc] = 0;
f0100a28:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
  int argc;
  char *argv[MAXARGS];
  int i;

  // Parse the command buffer into whitespace-separated arguments
  argc = 0;
f0100a2f:	be 00 00 00 00       	mov    $0x0,%esi
f0100a34:	eb 0a                	jmp    f0100a40 <monitor+0x5c>
  argv[argc] = 0;
  while (1) {
    // gobble whitespace
    while (*buf && strchr(WHITESPACE, *buf))
      *buf++ = 0;
f0100a36:	c6 03 00             	movb   $0x0,(%ebx)
f0100a39:	89 f7                	mov    %esi,%edi
f0100a3b:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100a3e:	89 fe                	mov    %edi,%esi
  // Parse the command buffer into whitespace-separated arguments
  argc = 0;
  argv[argc] = 0;
  while (1) {
    // gobble whitespace
    while (*buf && strchr(WHITESPACE, *buf))
f0100a40:	0f b6 03             	movzbl (%ebx),%eax
f0100a43:	84 c0                	test   %al,%al
f0100a45:	74 63                	je     f0100aaa <monitor+0xc6>
f0100a47:	0f be c0             	movsbl %al,%eax
f0100a4a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a4e:	c7 04 24 3a 73 10 f0 	movl   $0xf010733a,(%esp)
f0100a55:	e8 b0 57 00 00       	call   f010620a <strchr>
f0100a5a:	85 c0                	test   %eax,%eax
f0100a5c:	75 d8                	jne    f0100a36 <monitor+0x52>
      *buf++ = 0;
    if (*buf == 0)
f0100a5e:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a61:	74 47                	je     f0100aaa <monitor+0xc6>
      break;

    // save and scan past next arg
    if (argc == MAXARGS-1) {
f0100a63:	83 fe 0f             	cmp    $0xf,%esi
f0100a66:	75 16                	jne    f0100a7e <monitor+0x9a>
      cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a68:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100a6f:	00 
f0100a70:	c7 04 24 3f 73 10 f0 	movl   $0xf010733f,(%esp)
f0100a77:	e8 f4 34 00 00       	call   f0103f70 <cprintf>
f0100a7c:	eb 98                	jmp    f0100a16 <monitor+0x32>
      return 0;
    }
    argv[argc++] = buf;
f0100a7e:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a81:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100a85:	eb 03                	jmp    f0100a8a <monitor+0xa6>
    while (*buf && !strchr(WHITESPACE, *buf))
      buf++;
f0100a87:	83 c3 01             	add    $0x1,%ebx
    if (argc == MAXARGS-1) {
      cprintf("Too many arguments (max %d)\n", MAXARGS);
      return 0;
    }
    argv[argc++] = buf;
    while (*buf && !strchr(WHITESPACE, *buf))
f0100a8a:	0f b6 03             	movzbl (%ebx),%eax
f0100a8d:	84 c0                	test   %al,%al
f0100a8f:	74 ad                	je     f0100a3e <monitor+0x5a>
f0100a91:	0f be c0             	movsbl %al,%eax
f0100a94:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a98:	c7 04 24 3a 73 10 f0 	movl   $0xf010733a,(%esp)
f0100a9f:	e8 66 57 00 00       	call   f010620a <strchr>
f0100aa4:	85 c0                	test   %eax,%eax
f0100aa6:	74 df                	je     f0100a87 <monitor+0xa3>
f0100aa8:	eb 94                	jmp    f0100a3e <monitor+0x5a>
      buf++;
  }
  argv[argc] = 0;
f0100aaa:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100ab1:	00 

  // Lookup and invoke the command
  if (argc == 0)
f0100ab2:	85 f6                	test   %esi,%esi
f0100ab4:	0f 84 5c ff ff ff    	je     f0100a16 <monitor+0x32>
f0100aba:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100abf:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
    return 0;
  for (i = 0; i < NCOMMANDS; i++)
    if (strcmp(argv[0], commands[i].name) == 0)
f0100ac2:	8b 04 85 20 75 10 f0 	mov    -0xfef8ae0(,%eax,4),%eax
f0100ac9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100acd:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100ad0:	89 04 24             	mov    %eax,(%esp)
f0100ad3:	e8 d4 56 00 00       	call   f01061ac <strcmp>
f0100ad8:	85 c0                	test   %eax,%eax
f0100ada:	75 24                	jne    f0100b00 <monitor+0x11c>
      return commands[i].func(argc, argv, tf);
f0100adc:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100adf:	8b 55 08             	mov    0x8(%ebp),%edx
f0100ae2:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100ae6:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100ae9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100aed:	89 34 24             	mov    %esi,(%esp)
f0100af0:	ff 14 85 28 75 10 f0 	call   *-0xfef8ad8(,%eax,4)
    print_trapframe(tf);

  while (1) {
    buf = readline("K> ");
    if (buf != NULL)
      if (runcmd(buf, tf) < 0)
f0100af7:	85 c0                	test   %eax,%eax
f0100af9:	78 25                	js     f0100b20 <monitor+0x13c>
f0100afb:	e9 16 ff ff ff       	jmp    f0100a16 <monitor+0x32>
  argv[argc] = 0;

  // Lookup and invoke the command
  if (argc == 0)
    return 0;
  for (i = 0; i < NCOMMANDS; i++)
f0100b00:	83 c3 01             	add    $0x1,%ebx
f0100b03:	83 fb 03             	cmp    $0x3,%ebx
f0100b06:	75 b7                	jne    f0100abf <monitor+0xdb>
    if (strcmp(argv[0], commands[i].name) == 0)
      return commands[i].func(argc, argv, tf);
  cprintf("Unknown command '%s'\n", argv[0]);
f0100b08:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100b0b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b0f:	c7 04 24 5c 73 10 f0 	movl   $0xf010735c,(%esp)
f0100b16:	e8 55 34 00 00       	call   f0103f70 <cprintf>
f0100b1b:	e9 f6 fe ff ff       	jmp    f0100a16 <monitor+0x32>
    buf = readline("K> ");
    if (buf != NULL)
      if (runcmd(buf, tf) < 0)
        break;
  }
}
f0100b20:	83 c4 5c             	add    $0x5c,%esp
f0100b23:	5b                   	pop    %ebx
f0100b24:	5e                   	pop    %esi
f0100b25:	5f                   	pop    %edi
f0100b26:	5d                   	pop    %ebp
f0100b27:	c3                   	ret    
f0100b28:	66 90                	xchg   %ax,%ax
f0100b2a:	66 90                	xchg   %ax,%ax
f0100b2c:	66 90                	xchg   %ax,%ax
f0100b2e:	66 90                	xchg   %ax,%ax

f0100b30 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100b30:	89 c2                	mov    %eax,%edx
  // Initialize nextfree if this is the first time.
  // 'end' is a magic symbol automatically generated by the linker,
  // which points to the end of the kernel's bss segment:
  // the first virtual address that the linker did *not* assign
  // to any kernel code or global variables.
  if (!nextfree) {
f0100b32:	83 3d 38 c2 20 f0 00 	cmpl   $0x0,0xf020c238
f0100b39:	75 0f                	jne    f0100b4a <boot_alloc+0x1a>
    extern char end[];
    nextfree = ROUNDUP((char*)end, PGSIZE);
f0100b3b:	b8 07 f0 24 f0       	mov    $0xf024f007,%eax
f0100b40:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b45:	a3 38 c2 20 f0       	mov    %eax,0xf020c238
  // Allocate a chunk large enough to hold 'n' bytes, then update
  // nextfree.  Make sure nextfree is kept aligned
  // to a multiple of PGSIZE.
  //
  // LAB 2: Your code here.
  result = nextfree;
f0100b4a:	a1 38 c2 20 f0       	mov    0xf020c238,%eax
  if (n > 0) {
f0100b4f:	85 d2                	test   %edx,%edx
f0100b51:	74 48                	je     f0100b9b <boot_alloc+0x6b>
    nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100b53:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0100b5a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b60:	89 15 38 c2 20 f0    	mov    %edx,0xf020c238
    if ((uint32_t) nextfree >= npages * PGSIZE + KERNBASE) {
f0100b66:	8b 0d 88 ce 20 f0    	mov    0xf020ce88,%ecx
f0100b6c:	81 c1 00 00 0f 00    	add    $0xf0000,%ecx
f0100b72:	c1 e1 0c             	shl    $0xc,%ecx
f0100b75:	39 ca                	cmp    %ecx,%edx
f0100b77:	72 22                	jb     f0100b9b <boot_alloc+0x6b>
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100b79:	55                   	push   %ebp
f0100b7a:	89 e5                	mov    %esp,%ebp
f0100b7c:	83 ec 18             	sub    $0x18,%esp
  // LAB 2: Your code here.
  result = nextfree;
  if (n > 0) {
    nextfree = ROUNDUP(nextfree + n, PGSIZE);
    if ((uint32_t) nextfree >= npages * PGSIZE + KERNBASE) {
      panic("boot_alloc: out of memory\n");
f0100b7f:	c7 44 24 08 44 75 10 	movl   $0xf0107544,0x8(%esp)
f0100b86:	f0 
f0100b87:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
f0100b8e:	00 
f0100b8f:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0100b96:	e8 a5 f4 ff ff       	call   f0100040 <_panic>
    }
  }
  return result;
}
f0100b9b:	f3 c3                	repz ret 

f0100b9d <page2kva>:
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b9d:	2b 05 90 ce 20 f0    	sub    0xf020ce90,%eax
f0100ba3:	c1 f8 03             	sar    $0x3,%eax
f0100ba6:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ba9:	89 c2                	mov    %eax,%edx
f0100bab:	c1 ea 0c             	shr    $0xc,%edx
f0100bae:	3b 15 88 ce 20 f0    	cmp    0xf020ce88,%edx
f0100bb4:	72 26                	jb     f0100bdc <page2kva+0x3f>
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f0100bb6:	55                   	push   %ebp
f0100bb7:	89 e5                	mov    %esp,%ebp
f0100bb9:	83 ec 18             	sub    $0x18,%esp

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bbc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100bc0:	c7 44 24 08 a4 6f 10 	movl   $0xf0106fa4,0x8(%esp)
f0100bc7:	f0 
f0100bc8:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100bcf:	00 
f0100bd0:	c7 04 24 6b 75 10 f0 	movl   $0xf010756b,(%esp)
f0100bd7:	e8 64 f4 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100bdc:	2d 00 00 00 10       	sub    $0x10000000,%eax

static inline void*
page2kva(struct PageInfo *pp)
{
	return KADDR(page2pa(pp));
}
f0100be1:	c3                   	ret    

f0100be2 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
  pte_t *p;

  pgdir = &pgdir[PDX(va)];
f0100be2:	89 d1                	mov    %edx,%ecx
f0100be4:	c1 e9 16             	shr    $0x16,%ecx
  if (!(*pgdir & PTE_P))
f0100be7:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100bea:	a8 01                	test   $0x1,%al
f0100bec:	74 5d                	je     f0100c4b <check_va2pa+0x69>
    return ~0;
  p = (pte_t*)KADDR(PTE_ADDR(*pgdir));
f0100bee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bf3:	89 c1                	mov    %eax,%ecx
f0100bf5:	c1 e9 0c             	shr    $0xc,%ecx
f0100bf8:	3b 0d 88 ce 20 f0    	cmp    0xf020ce88,%ecx
f0100bfe:	72 26                	jb     f0100c26 <check_va2pa+0x44>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100c00:	55                   	push   %ebp
f0100c01:	89 e5                	mov    %esp,%ebp
f0100c03:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c06:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c0a:	c7 44 24 08 a4 6f 10 	movl   $0xf0106fa4,0x8(%esp)
f0100c11:	f0 
f0100c12:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f0100c19:	00 
f0100c1a:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0100c21:	e8 1a f4 ff ff       	call   f0100040 <_panic>

  pgdir = &pgdir[PDX(va)];
  if (!(*pgdir & PTE_P))
    return ~0;
  p = (pte_t*)KADDR(PTE_ADDR(*pgdir));
  if (!(p[PTX(va)] & PTE_P))
f0100c26:	c1 ea 0c             	shr    $0xc,%edx
f0100c29:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100c2f:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100c36:	89 c2                	mov    %eax,%edx
f0100c38:	83 e2 01             	and    $0x1,%edx
    return ~0;
  return PTE_ADDR(p[PTX(va)]);
f0100c3b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c40:	85 d2                	test   %edx,%edx
f0100c42:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100c47:	0f 44 c2             	cmove  %edx,%eax
f0100c4a:	c3                   	ret    
{
  pte_t *p;

  pgdir = &pgdir[PDX(va)];
  if (!(*pgdir & PTE_P))
    return ~0;
f0100c4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  p = (pte_t*)KADDR(PTE_ADDR(*pgdir));
  if (!(p[PTX(va)] & PTE_P))
    return ~0;
  return PTE_ADDR(p[PTX(va)]);
}
f0100c50:	c3                   	ret    

f0100c51 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100c51:	55                   	push   %ebp
f0100c52:	89 e5                	mov    %esp,%ebp
f0100c54:	57                   	push   %edi
f0100c55:	56                   	push   %esi
f0100c56:	53                   	push   %ebx
f0100c57:	83 ec 4c             	sub    $0x4c,%esp
  struct PageInfo *pp;
  unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c5a:	84 c0                	test   %al,%al
f0100c5c:	0f 85 31 03 00 00    	jne    f0100f93 <check_page_free_list+0x342>
f0100c62:	e9 3e 03 00 00       	jmp    f0100fa5 <check_page_free_list+0x354>
  int nfree_basemem = 0, nfree_extmem = 0;
  char *first_free_page;

  if (!page_free_list)
    panic("'page_free_list' is a null pointer!");
f0100c67:	c7 44 24 08 90 78 10 	movl   $0xf0107890,0x8(%esp)
f0100c6e:	f0 
f0100c6f:	c7 44 24 04 bc 02 00 	movl   $0x2bc,0x4(%esp)
f0100c76:	00 
f0100c77:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0100c7e:	e8 bd f3 ff ff       	call   f0100040 <_panic>

  if (only_low_memory) {
    // Move pages with lower addresses first in the free
    // list, since entry_pgdir does not map all pages.
    struct PageInfo *pp1, *pp2;
    struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100c83:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100c86:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100c89:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c8c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c8f:	89 c2                	mov    %eax,%edx
f0100c91:	2b 15 90 ce 20 f0    	sub    0xf020ce90,%edx
    for (pp = page_free_list; pp; pp = pp->pp_link) {
      int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100c97:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100c9d:	0f 95 c2             	setne  %dl
f0100ca0:	0f b6 d2             	movzbl %dl,%edx
      *tp[pagetype] = pp;
f0100ca3:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100ca7:	89 01                	mov    %eax,(%ecx)
      tp[pagetype] = &pp->pp_link;
f0100ca9:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
  if (only_low_memory) {
    // Move pages with lower addresses first in the free
    // list, since entry_pgdir does not map all pages.
    struct PageInfo *pp1, *pp2;
    struct PageInfo **tp[2] = { &pp1, &pp2 };
    for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cad:	8b 00                	mov    (%eax),%eax
f0100caf:	85 c0                	test   %eax,%eax
f0100cb1:	75 dc                	jne    f0100c8f <check_page_free_list+0x3e>
      int pagetype = PDX(page2pa(pp)) >= pdx_limit;
      *tp[pagetype] = pp;
      tp[pagetype] = &pp->pp_link;
    }
    *tp[1] = 0;
f0100cb3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100cb6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    *tp[0] = pp2;
f0100cbc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cbf:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100cc2:	89 10                	mov    %edx,(%eax)
    page_free_list = pp1;
f0100cc4:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100cc7:	a3 40 c2 20 f0       	mov    %eax,0xf020c240
//
static void
check_page_free_list(bool only_low_memory)
{
  struct PageInfo *pp;
  unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ccc:	be 01 00 00 00       	mov    $0x1,%esi
    page_free_list = pp1;
  }

  // if there's a page that shouldn't be on the free list,
  // try to make sure it eventually causes trouble.
  for (pp = page_free_list; pp; pp = pp->pp_link)
f0100cd1:	8b 1d 40 c2 20 f0    	mov    0xf020c240,%ebx
f0100cd7:	eb 63                	jmp    f0100d3c <check_page_free_list+0xeb>
f0100cd9:	89 d8                	mov    %ebx,%eax
f0100cdb:	2b 05 90 ce 20 f0    	sub    0xf020ce90,%eax
f0100ce1:	c1 f8 03             	sar    $0x3,%eax
f0100ce4:	c1 e0 0c             	shl    $0xc,%eax
    if (PDX(page2pa(pp)) < pdx_limit)
f0100ce7:	89 c2                	mov    %eax,%edx
f0100ce9:	c1 ea 16             	shr    $0x16,%edx
f0100cec:	39 f2                	cmp    %esi,%edx
f0100cee:	73 4a                	jae    f0100d3a <check_page_free_list+0xe9>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100cf0:	89 c2                	mov    %eax,%edx
f0100cf2:	c1 ea 0c             	shr    $0xc,%edx
f0100cf5:	3b 15 88 ce 20 f0    	cmp    0xf020ce88,%edx
f0100cfb:	72 20                	jb     f0100d1d <check_page_free_list+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cfd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d01:	c7 44 24 08 a4 6f 10 	movl   $0xf0106fa4,0x8(%esp)
f0100d08:	f0 
f0100d09:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100d10:	00 
f0100d11:	c7 04 24 6b 75 10 f0 	movl   $0xf010756b,(%esp)
f0100d18:	e8 23 f3 ff ff       	call   f0100040 <_panic>
      memset(page2kva(pp), 0x97, 128);
f0100d1d:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100d24:	00 
f0100d25:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100d2c:	00 
	return (void *)(pa + KERNBASE);
f0100d2d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d32:	89 04 24             	mov    %eax,(%esp)
f0100d35:	e8 0d 55 00 00       	call   f0106247 <memset>
    page_free_list = pp1;
  }

  // if there's a page that shouldn't be on the free list,
  // try to make sure it eventually causes trouble.
  for (pp = page_free_list; pp; pp = pp->pp_link)
f0100d3a:	8b 1b                	mov    (%ebx),%ebx
f0100d3c:	85 db                	test   %ebx,%ebx
f0100d3e:	75 99                	jne    f0100cd9 <check_page_free_list+0x88>
    if (PDX(page2pa(pp)) < pdx_limit)
      memset(page2kva(pp), 0x97, 128);

  first_free_page = (char*)boot_alloc(0);
f0100d40:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d45:	e8 e6 fd ff ff       	call   f0100b30 <boot_alloc>
f0100d4a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d4d:	8b 15 40 c2 20 f0    	mov    0xf020c240,%edx
    // check that we didn't corrupt the free list itself
    assert(pp >= pages);
f0100d53:	8b 0d 90 ce 20 f0    	mov    0xf020ce90,%ecx
    assert(pp < pages + npages);
f0100d59:	a1 88 ce 20 f0       	mov    0xf020ce88,%eax
f0100d5e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100d61:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100d64:	89 45 d0             	mov    %eax,-0x30(%ebp)
    assert(((char*)pp - (char*)pages) % sizeof(*pp) == 0);
f0100d67:	89 4d cc             	mov    %ecx,-0x34(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
  struct PageInfo *pp;
  unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
  int nfree_basemem = 0, nfree_extmem = 0;
f0100d6a:	bf 00 00 00 00       	mov    $0x0,%edi
f0100d6f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  for (pp = page_free_list; pp; pp = pp->pp_link)
    if (PDX(page2pa(pp)) < pdx_limit)
      memset(page2kva(pp), 0x97, 128);

  first_free_page = (char*)boot_alloc(0);
  for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d72:	e9 c4 01 00 00       	jmp    f0100f3b <check_page_free_list+0x2ea>
    // check that we didn't corrupt the free list itself
    assert(pp >= pages);
f0100d77:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100d7a:	73 24                	jae    f0100da0 <check_page_free_list+0x14f>
f0100d7c:	c7 44 24 0c 79 75 10 	movl   $0xf0107579,0xc(%esp)
f0100d83:	f0 
f0100d84:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0100d8b:	f0 
f0100d8c:	c7 44 24 04 d6 02 00 	movl   $0x2d6,0x4(%esp)
f0100d93:	00 
f0100d94:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0100d9b:	e8 a0 f2 ff ff       	call   f0100040 <_panic>
    assert(pp < pages + npages);
f0100da0:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100da3:	72 24                	jb     f0100dc9 <check_page_free_list+0x178>
f0100da5:	c7 44 24 0c 9a 75 10 	movl   $0xf010759a,0xc(%esp)
f0100dac:	f0 
f0100dad:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0100db4:	f0 
f0100db5:	c7 44 24 04 d7 02 00 	movl   $0x2d7,0x4(%esp)
f0100dbc:	00 
f0100dbd:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0100dc4:	e8 77 f2 ff ff       	call   f0100040 <_panic>
    assert(((char*)pp - (char*)pages) % sizeof(*pp) == 0);
f0100dc9:	89 d0                	mov    %edx,%eax
f0100dcb:	2b 45 cc             	sub    -0x34(%ebp),%eax
f0100dce:	a8 07                	test   $0x7,%al
f0100dd0:	74 24                	je     f0100df6 <check_page_free_list+0x1a5>
f0100dd2:	c7 44 24 0c b4 78 10 	movl   $0xf01078b4,0xc(%esp)
f0100dd9:	f0 
f0100dda:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0100de1:	f0 
f0100de2:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
f0100de9:	00 
f0100dea:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0100df1:	e8 4a f2 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100df6:	c1 f8 03             	sar    $0x3,%eax
f0100df9:	c1 e0 0c             	shl    $0xc,%eax

    // check a few pages that shouldn't be on the free list
    assert(page2pa(pp) != 0);
f0100dfc:	85 c0                	test   %eax,%eax
f0100dfe:	75 24                	jne    f0100e24 <check_page_free_list+0x1d3>
f0100e00:	c7 44 24 0c ae 75 10 	movl   $0xf01075ae,0xc(%esp)
f0100e07:	f0 
f0100e08:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0100e0f:	f0 
f0100e10:	c7 44 24 04 db 02 00 	movl   $0x2db,0x4(%esp)
f0100e17:	00 
f0100e18:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0100e1f:	e8 1c f2 ff ff       	call   f0100040 <_panic>
    assert(page2pa(pp) != IOPHYSMEM);
f0100e24:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100e29:	75 24                	jne    f0100e4f <check_page_free_list+0x1fe>
f0100e2b:	c7 44 24 0c bf 75 10 	movl   $0xf01075bf,0xc(%esp)
f0100e32:	f0 
f0100e33:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0100e3a:	f0 
f0100e3b:	c7 44 24 04 dc 02 00 	movl   $0x2dc,0x4(%esp)
f0100e42:	00 
f0100e43:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0100e4a:	e8 f1 f1 ff ff       	call   f0100040 <_panic>
    assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100e4f:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100e54:	75 24                	jne    f0100e7a <check_page_free_list+0x229>
f0100e56:	c7 44 24 0c e4 78 10 	movl   $0xf01078e4,0xc(%esp)
f0100e5d:	f0 
f0100e5e:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0100e65:	f0 
f0100e66:	c7 44 24 04 dd 02 00 	movl   $0x2dd,0x4(%esp)
f0100e6d:	00 
f0100e6e:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0100e75:	e8 c6 f1 ff ff       	call   f0100040 <_panic>
    assert(page2pa(pp) != EXTPHYSMEM);
f0100e7a:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100e7f:	75 24                	jne    f0100ea5 <check_page_free_list+0x254>
f0100e81:	c7 44 24 0c d8 75 10 	movl   $0xf01075d8,0xc(%esp)
f0100e88:	f0 
f0100e89:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0100e90:	f0 
f0100e91:	c7 44 24 04 de 02 00 	movl   $0x2de,0x4(%esp)
f0100e98:	00 
f0100e99:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0100ea0:	e8 9b f1 ff ff       	call   f0100040 <_panic>
    assert(page2pa(pp) < EXTPHYSMEM || (char*)page2kva(pp) >= first_free_page);
f0100ea5:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100eaa:	0f 86 1c 01 00 00    	jbe    f0100fcc <check_page_free_list+0x37b>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100eb0:	89 c1                	mov    %eax,%ecx
f0100eb2:	c1 e9 0c             	shr    $0xc,%ecx
f0100eb5:	39 4d c4             	cmp    %ecx,-0x3c(%ebp)
f0100eb8:	77 20                	ja     f0100eda <check_page_free_list+0x289>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100eba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ebe:	c7 44 24 08 a4 6f 10 	movl   $0xf0106fa4,0x8(%esp)
f0100ec5:	f0 
f0100ec6:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100ecd:	00 
f0100ece:	c7 04 24 6b 75 10 f0 	movl   $0xf010756b,(%esp)
f0100ed5:	e8 66 f1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100eda:	8d 88 00 00 00 f0    	lea    -0x10000000(%eax),%ecx
f0100ee0:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100ee3:	0f 86 d3 00 00 00    	jbe    f0100fbc <check_page_free_list+0x36b>
f0100ee9:	c7 44 24 0c 08 79 10 	movl   $0xf0107908,0xc(%esp)
f0100ef0:	f0 
f0100ef1:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0100ef8:	f0 
f0100ef9:	c7 44 24 04 df 02 00 	movl   $0x2df,0x4(%esp)
f0100f00:	00 
f0100f01:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0100f08:	e8 33 f1 ff ff       	call   f0100040 <_panic>
    // (new test for lab 4)
    assert(page2pa(pp) != MPENTRY_PADDR);
f0100f0d:	c7 44 24 0c f2 75 10 	movl   $0xf01075f2,0xc(%esp)
f0100f14:	f0 
f0100f15:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0100f1c:	f0 
f0100f1d:	c7 44 24 04 e1 02 00 	movl   $0x2e1,0x4(%esp)
f0100f24:	00 
f0100f25:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0100f2c:	e8 0f f1 ff ff       	call   f0100040 <_panic>

    if (page2pa(pp) < EXTPHYSMEM)
      ++nfree_basemem;
f0100f31:	83 c3 01             	add    $0x1,%ebx
f0100f34:	eb 03                	jmp    f0100f39 <check_page_free_list+0x2e8>
    else
      ++nfree_extmem;
f0100f36:	83 c7 01             	add    $0x1,%edi
  for (pp = page_free_list; pp; pp = pp->pp_link)
    if (PDX(page2pa(pp)) < pdx_limit)
      memset(page2kva(pp), 0x97, 128);

  first_free_page = (char*)boot_alloc(0);
  for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f39:	8b 12                	mov    (%edx),%edx
f0100f3b:	85 d2                	test   %edx,%edx
f0100f3d:	0f 85 34 fe ff ff    	jne    f0100d77 <check_page_free_list+0x126>
      ++nfree_basemem;
    else
      ++nfree_extmem;
  }

  assert(nfree_basemem > 0);
f0100f43:	85 db                	test   %ebx,%ebx
f0100f45:	7f 24                	jg     f0100f6b <check_page_free_list+0x31a>
f0100f47:	c7 44 24 0c 0f 76 10 	movl   $0xf010760f,0xc(%esp)
f0100f4e:	f0 
f0100f4f:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0100f56:	f0 
f0100f57:	c7 44 24 04 e9 02 00 	movl   $0x2e9,0x4(%esp)
f0100f5e:	00 
f0100f5f:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0100f66:	e8 d5 f0 ff ff       	call   f0100040 <_panic>
  assert(nfree_extmem > 0);
f0100f6b:	85 ff                	test   %edi,%edi
f0100f6d:	7f 6d                	jg     f0100fdc <check_page_free_list+0x38b>
f0100f6f:	c7 44 24 0c 21 76 10 	movl   $0xf0107621,0xc(%esp)
f0100f76:	f0 
f0100f77:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0100f7e:	f0 
f0100f7f:	c7 44 24 04 ea 02 00 	movl   $0x2ea,0x4(%esp)
f0100f86:	00 
f0100f87:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0100f8e:	e8 ad f0 ff ff       	call   f0100040 <_panic>
  struct PageInfo *pp;
  unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
  int nfree_basemem = 0, nfree_extmem = 0;
  char *first_free_page;

  if (!page_free_list)
f0100f93:	a1 40 c2 20 f0       	mov    0xf020c240,%eax
f0100f98:	85 c0                	test   %eax,%eax
f0100f9a:	0f 85 e3 fc ff ff    	jne    f0100c83 <check_page_free_list+0x32>
f0100fa0:	e9 c2 fc ff ff       	jmp    f0100c67 <check_page_free_list+0x16>
f0100fa5:	83 3d 40 c2 20 f0 00 	cmpl   $0x0,0xf020c240
f0100fac:	0f 84 b5 fc ff ff    	je     f0100c67 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
  struct PageInfo *pp;
  unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100fb2:	be 00 04 00 00       	mov    $0x400,%esi
f0100fb7:	e9 15 fd ff ff       	jmp    f0100cd1 <check_page_free_list+0x80>
    assert(page2pa(pp) != IOPHYSMEM);
    assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
    assert(page2pa(pp) != EXTPHYSMEM);
    assert(page2pa(pp) < EXTPHYSMEM || (char*)page2kva(pp) >= first_free_page);
    // (new test for lab 4)
    assert(page2pa(pp) != MPENTRY_PADDR);
f0100fbc:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100fc1:	0f 85 6f ff ff ff    	jne    f0100f36 <check_page_free_list+0x2e5>
f0100fc7:	e9 41 ff ff ff       	jmp    f0100f0d <check_page_free_list+0x2bc>
f0100fcc:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100fd1:	0f 85 5a ff ff ff    	jne    f0100f31 <check_page_free_list+0x2e0>
f0100fd7:	e9 31 ff ff ff       	jmp    f0100f0d <check_page_free_list+0x2bc>
      ++nfree_extmem;
  }

  assert(nfree_basemem > 0);
  assert(nfree_extmem > 0);
}
f0100fdc:	83 c4 4c             	add    $0x4c,%esp
f0100fdf:	5b                   	pop    %ebx
f0100fe0:	5e                   	pop    %esi
f0100fe1:	5f                   	pop    %edi
f0100fe2:	5d                   	pop    %ebp
f0100fe3:	c3                   	ret    

f0100fe4 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100fe4:	55                   	push   %ebp
f0100fe5:	89 e5                	mov    %esp,%ebp
f0100fe7:	56                   	push   %esi
f0100fe8:	53                   	push   %ebx
f0100fe9:	83 ec 10             	sub    $0x10,%esp
  // Change the code to reflect this.
  // NB: DO NOT actually touch the physical memory corresponding to
  // free pages!

  // Mark physical page 0 as in use
  pages[0].pp_ref = 1;
f0100fec:	a1 90 ce 20 f0       	mov    0xf020ce90,%eax
f0100ff1:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
  pages[0].pp_link = NULL;
f0100ff7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint32_t first_free_page_after_kernel = PADDR(boot_alloc(0));
f0100ffd:	b8 00 00 00 00       	mov    $0x0,%eax
f0101002:	e8 29 fb ff ff       	call   f0100b30 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101007:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010100c:	77 20                	ja     f010102e <page_init+0x4a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010100e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101012:	c7 44 24 08 c8 6f 10 	movl   $0xf0106fc8,0x8(%esp)
f0101019:	f0 
f010101a:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
f0101021:	00 
f0101022:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101029:	e8 12 f0 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010102e:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
  size_t i;
  for (i = 1; i < npages; i++) {
    //[IOPHYSMEM, EXTPHYSMEM) and Kernel
    if (i >= PGNUM(IOPHYSMEM) && i < PGNUM(first_free_page_after_kernel)) {
f0101034:	c1 ee 0c             	shr    $0xc,%esi
f0101037:	8b 1d 40 c2 20 f0    	mov    0xf020c240,%ebx
  pages[0].pp_ref = 1;
  pages[0].pp_link = NULL;

  uint32_t first_free_page_after_kernel = PADDR(boot_alloc(0));
  size_t i;
  for (i = 1; i < npages; i++) {
f010103d:	ba 01 00 00 00       	mov    $0x1,%edx
f0101042:	eb 5d                	jmp    f01010a1 <page_init+0xbd>
    //[IOPHYSMEM, EXTPHYSMEM) and Kernel
    if (i >= PGNUM(IOPHYSMEM) && i < PGNUM(first_free_page_after_kernel)) {
f0101044:	81 fa 9f 00 00 00    	cmp    $0x9f,%edx
f010104a:	76 1a                	jbe    f0101066 <page_init+0x82>
f010104c:	39 f2                	cmp    %esi,%edx
f010104e:	73 16                	jae    f0101066 <page_init+0x82>
      pages[i].pp_ref = 1;
f0101050:	a1 90 ce 20 f0       	mov    0xf020ce90,%eax
f0101055:	8d 0c d0             	lea    (%eax,%edx,8),%ecx
f0101058:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
      pages[i].pp_link = NULL;
f010105e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
f0101064:	eb 38                	jmp    f010109e <page_init+0xba>
    }
    else {
      if(i == PGNUM(MPENTRY_PADDR)) {
f0101066:	83 fa 07             	cmp    $0x7,%edx
f0101069:	75 14                	jne    f010107f <page_init+0x9b>
        pages[i].pp_ref = 1;
f010106b:	a1 90 ce 20 f0       	mov    0xf020ce90,%eax
f0101070:	66 c7 40 3c 01 00    	movw   $0x1,0x3c(%eax)
        pages[i].pp_link = NULL;
f0101076:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
f010107d:	eb 1f                	jmp    f010109e <page_init+0xba>
f010107f:	8d 0c d5 00 00 00 00 	lea    0x0(,%edx,8),%ecx
      }else{
        pages[i].pp_ref = 0;
f0101086:	89 c8                	mov    %ecx,%eax
f0101088:	03 05 90 ce 20 f0    	add    0xf020ce90,%eax
f010108e:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
        pages[i].pp_link = page_free_list;
f0101094:	89 18                	mov    %ebx,(%eax)
        page_free_list = &pages[i];
f0101096:	89 cb                	mov    %ecx,%ebx
f0101098:	03 1d 90 ce 20 f0    	add    0xf020ce90,%ebx
  pages[0].pp_ref = 1;
  pages[0].pp_link = NULL;

  uint32_t first_free_page_after_kernel = PADDR(boot_alloc(0));
  size_t i;
  for (i = 1; i < npages; i++) {
f010109e:	83 c2 01             	add    $0x1,%edx
f01010a1:	3b 15 88 ce 20 f0    	cmp    0xf020ce88,%edx
f01010a7:	72 9b                	jb     f0101044 <page_init+0x60>
f01010a9:	89 1d 40 c2 20 f0    	mov    %ebx,0xf020c240
        pages[i].pp_link = page_free_list;
        page_free_list = &pages[i];
      }
    }
  }
}
f01010af:	83 c4 10             	add    $0x10,%esp
f01010b2:	5b                   	pop    %ebx
f01010b3:	5e                   	pop    %esi
f01010b4:	5d                   	pop    %ebp
f01010b5:	c3                   	ret    

f01010b6 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f01010b6:	55                   	push   %ebp
f01010b7:	89 e5                	mov    %esp,%ebp
f01010b9:	53                   	push   %ebx
f01010ba:	83 ec 14             	sub    $0x14,%esp
  struct PageInfo *result = page_free_list;
f01010bd:	8b 1d 40 c2 20 f0    	mov    0xf020c240,%ebx
  if (!result) {
f01010c3:	85 db                	test   %ebx,%ebx
f01010c5:	0f 84 8b 00 00 00    	je     f0101156 <page_alloc+0xa0>
    return NULL;
  }
  page_free_list = result->pp_link;
f01010cb:	8b 03                	mov    (%ebx),%eax
f01010cd:	a3 40 c2 20 f0       	mov    %eax,0xf020c240
  result->pp_link = NULL;
f01010d2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if (alloc_flags && ALLOC_ZERO) {
    if(!memset(page2kva(result), '\0', PGSIZE)){
      panic("memset failed");
    }
  }
  return result;
f01010d8:	89 d8                	mov    %ebx,%eax
  if (!result) {
    return NULL;
  }
  page_free_list = result->pp_link;
  result->pp_link = NULL;
  if (alloc_flags && ALLOC_ZERO) {
f01010da:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01010de:	74 7f                	je     f010115f <page_alloc+0xa9>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010e0:	2b 05 90 ce 20 f0    	sub    0xf020ce90,%eax
f01010e6:	c1 f8 03             	sar    $0x3,%eax
f01010e9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010ec:	89 c2                	mov    %eax,%edx
f01010ee:	c1 ea 0c             	shr    $0xc,%edx
f01010f1:	3b 15 88 ce 20 f0    	cmp    0xf020ce88,%edx
f01010f7:	72 20                	jb     f0101119 <page_alloc+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01010fd:	c7 44 24 08 a4 6f 10 	movl   $0xf0106fa4,0x8(%esp)
f0101104:	f0 
f0101105:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010110c:	00 
f010110d:	c7 04 24 6b 75 10 f0 	movl   $0xf010756b,(%esp)
f0101114:	e8 27 ef ff ff       	call   f0100040 <_panic>
    if(!memset(page2kva(result), '\0', PGSIZE)){
f0101119:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101120:	00 
f0101121:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101128:	00 
	return (void *)(pa + KERNBASE);
f0101129:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010112e:	89 04 24             	mov    %eax,(%esp)
f0101131:	e8 11 51 00 00       	call   f0106247 <memset>
f0101136:	85 c0                	test   %eax,%eax
f0101138:	75 23                	jne    f010115d <page_alloc+0xa7>
      panic("memset failed");
f010113a:	c7 44 24 08 32 76 10 	movl   $0xf0107632,0x8(%esp)
f0101141:	f0 
f0101142:	c7 44 24 04 6f 01 00 	movl   $0x16f,0x4(%esp)
f0101149:	00 
f010114a:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101151:	e8 ea ee ff ff       	call   f0100040 <_panic>
struct PageInfo *
page_alloc(int alloc_flags)
{
  struct PageInfo *result = page_free_list;
  if (!result) {
    return NULL;
f0101156:	b8 00 00 00 00       	mov    $0x0,%eax
f010115b:	eb 02                	jmp    f010115f <page_alloc+0xa9>
  if (alloc_flags && ALLOC_ZERO) {
    if(!memset(page2kva(result), '\0', PGSIZE)){
      panic("memset failed");
    }
  }
  return result;
f010115d:	89 d8                	mov    %ebx,%eax
}
f010115f:	83 c4 14             	add    $0x14,%esp
f0101162:	5b                   	pop    %ebx
f0101163:	5d                   	pop    %ebp
f0101164:	c3                   	ret    

f0101165 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101165:	55                   	push   %ebp
f0101166:	89 e5                	mov    %esp,%ebp
f0101168:	83 ec 18             	sub    $0x18,%esp
f010116b:	8b 45 08             	mov    0x8(%ebp),%eax
  // Fill this function in
  // Hint: You may want to panic if pp->pp_ref is nonzero or
  // pp->pp_link is not NULL.
  if (pp->pp_ref != 0 || pp->pp_link != NULL){
f010116e:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101173:	75 05                	jne    f010117a <page_free+0x15>
f0101175:	83 38 00             	cmpl   $0x0,(%eax)
f0101178:	74 1c                	je     f0101196 <page_free+0x31>
    panic("pp_ref is not 0 or pp_link is not NULL");
f010117a:	c7 44 24 08 4c 79 10 	movl   $0xf010794c,0x8(%esp)
f0101181:	f0 
f0101182:	c7 44 24 04 80 01 00 	movl   $0x180,0x4(%esp)
f0101189:	00 
f010118a:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101191:	e8 aa ee ff ff       	call   f0100040 <_panic>
  }
  pp->pp_link = page_free_list;
f0101196:	8b 15 40 c2 20 f0    	mov    0xf020c240,%edx
f010119c:	89 10                	mov    %edx,(%eax)
  page_free_list = pp;
f010119e:	a3 40 c2 20 f0       	mov    %eax,0xf020c240
}
f01011a3:	c9                   	leave  
f01011a4:	c3                   	ret    

f01011a5 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f01011a5:	55                   	push   %ebp
f01011a6:	89 e5                	mov    %esp,%ebp
f01011a8:	83 ec 18             	sub    $0x18,%esp
f01011ab:	8b 45 08             	mov    0x8(%ebp),%eax
  if (--pp->pp_ref == 0)
f01011ae:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f01011b2:	8d 51 ff             	lea    -0x1(%ecx),%edx
f01011b5:	66 89 50 04          	mov    %dx,0x4(%eax)
f01011b9:	66 85 d2             	test   %dx,%dx
f01011bc:	75 08                	jne    f01011c6 <page_decref+0x21>
    page_free(pp);
f01011be:	89 04 24             	mov    %eax,(%esp)
f01011c1:	e8 9f ff ff ff       	call   f0101165 <page_free>
}
f01011c6:	c9                   	leave  
f01011c7:	c3                   	ret    

f01011c8 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{ 
f01011c8:	55                   	push   %ebp
f01011c9:	89 e5                	mov    %esp,%ebp
f01011cb:	56                   	push   %esi
f01011cc:	53                   	push   %ebx
f01011cd:	83 ec 10             	sub    $0x10,%esp
f01011d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  pte_t* page_table_addr = &pgdir[PDX(va)];
f01011d3:	89 de                	mov    %ebx,%esi
f01011d5:	c1 ee 16             	shr    $0x16,%esi
f01011d8:	c1 e6 02             	shl    $0x2,%esi
f01011db:	03 75 08             	add    0x8(%ebp),%esi

  if(*page_table_addr & PTE_P) { //check if the page table exists
f01011de:	8b 06                	mov    (%esi),%eax
f01011e0:	a8 01                	test   $0x1,%al
f01011e2:	74 44                	je     f0101228 <pgdir_walk+0x60>
    return (pte_t *)KADDR(PTE_ADDR(*page_table_addr)) + PTX(va);
f01011e4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011e9:	89 c2                	mov    %eax,%edx
f01011eb:	c1 ea 0c             	shr    $0xc,%edx
f01011ee:	3b 15 88 ce 20 f0    	cmp    0xf020ce88,%edx
f01011f4:	72 20                	jb     f0101216 <pgdir_walk+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011fa:	c7 44 24 08 a4 6f 10 	movl   $0xf0106fa4,0x8(%esp)
f0101201:	f0 
f0101202:	c7 44 24 04 ad 01 00 	movl   $0x1ad,0x4(%esp)
f0101209:	00 
f010120a:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101211:	e8 2a ee ff ff       	call   f0100040 <_panic>
f0101216:	c1 eb 0a             	shr    $0xa,%ebx
f0101219:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f010121f:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f0101226:	eb 7e                	jmp    f01012a6 <pgdir_walk+0xde>
  }
  if (create == false) {
f0101228:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010122c:	74 6c                	je     f010129a <pgdir_walk+0xd2>
    return NULL;
  }
  struct PageInfo *page = page_alloc(ALLOC_ZERO);
f010122e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101235:	e8 7c fe ff ff       	call   f01010b6 <page_alloc>
  if (page == NULL) {
f010123a:	85 c0                	test   %eax,%eax
f010123c:	74 63                	je     f01012a1 <pgdir_walk+0xd9>
    //failed alloc
    return NULL;
  }
  page->pp_ref++;
f010123e:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101243:	2b 05 90 ce 20 f0    	sub    0xf020ce90,%eax
f0101249:	c1 f8 03             	sar    $0x3,%eax
f010124c:	c1 e0 0c             	shl    $0xc,%eax
  
  *page_table_addr = page2pa(page) | PTE_P | PTE_U | PTE_W;
f010124f:	89 c2                	mov    %eax,%edx
f0101251:	83 ca 07             	or     $0x7,%edx
f0101254:	89 16                	mov    %edx,(%esi)

  return (pte_t *)KADDR(PTE_ADDR(*page_table_addr)) + PTX(va);
f0101256:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010125b:	89 c2                	mov    %eax,%edx
f010125d:	c1 ea 0c             	shr    $0xc,%edx
f0101260:	3b 15 88 ce 20 f0    	cmp    0xf020ce88,%edx
f0101266:	72 20                	jb     f0101288 <pgdir_walk+0xc0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101268:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010126c:	c7 44 24 08 a4 6f 10 	movl   $0xf0106fa4,0x8(%esp)
f0101273:	f0 
f0101274:	c7 44 24 04 bb 01 00 	movl   $0x1bb,0x4(%esp)
f010127b:	00 
f010127c:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101283:	e8 b8 ed ff ff       	call   f0100040 <_panic>
f0101288:	c1 eb 0a             	shr    $0xa,%ebx
f010128b:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0101291:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f0101298:	eb 0c                	jmp    f01012a6 <pgdir_walk+0xde>

  if(*page_table_addr & PTE_P) { //check if the page table exists
    return (pte_t *)KADDR(PTE_ADDR(*page_table_addr)) + PTX(va);
  }
  if (create == false) {
    return NULL;
f010129a:	b8 00 00 00 00       	mov    $0x0,%eax
f010129f:	eb 05                	jmp    f01012a6 <pgdir_walk+0xde>
  }
  struct PageInfo *page = page_alloc(ALLOC_ZERO);
  if (page == NULL) {
    //failed alloc
    return NULL;
f01012a1:	b8 00 00 00 00       	mov    $0x0,%eax
  page->pp_ref++;
  
  *page_table_addr = page2pa(page) | PTE_P | PTE_U | PTE_W;

  return (pte_t *)KADDR(PTE_ADDR(*page_table_addr)) + PTX(va);
}
f01012a6:	83 c4 10             	add    $0x10,%esp
f01012a9:	5b                   	pop    %ebx
f01012aa:	5e                   	pop    %esi
f01012ab:	5d                   	pop    %ebp
f01012ac:	c3                   	ret    

f01012ad <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01012ad:	55                   	push   %ebp
f01012ae:	89 e5                	mov    %esp,%ebp
f01012b0:	57                   	push   %edi
f01012b1:	56                   	push   %esi
f01012b2:	53                   	push   %ebx
f01012b3:	83 ec 2c             	sub    $0x2c,%esp
f01012b6:	89 c7                	mov    %eax,%edi
f01012b8:	89 d6                	mov    %edx,%esi
f01012ba:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	// Fill this function in
	uintptr_t *p;
  size_t i;
	for (i = 0; i < size; i += PGSIZE) {
f01012bd:	bb 00 00 00 00       	mov    $0x0,%ebx
		p = pgdir_walk(pgdir, (void *)(va + i), 1);
		if (p == NULL) {
			panic("Mapping failed\n");
		} else {
			*p = (pa + i) | perm | PTE_P;
f01012c2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012c5:	83 c8 01             	or     $0x1,%eax
f01012c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	uintptr_t *p;
  size_t i;
	for (i = 0; i < size; i += PGSIZE) {
f01012cb:	eb 47                	jmp    f0101314 <boot_map_region+0x67>
		p = pgdir_walk(pgdir, (void *)(va + i), 1);
f01012cd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01012d4:	00 
f01012d5:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f01012d8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01012dc:	89 3c 24             	mov    %edi,(%esp)
f01012df:	e8 e4 fe ff ff       	call   f01011c8 <pgdir_walk>
		if (p == NULL) {
f01012e4:	85 c0                	test   %eax,%eax
f01012e6:	75 1c                	jne    f0101304 <boot_map_region+0x57>
			panic("Mapping failed\n");
f01012e8:	c7 44 24 08 40 76 10 	movl   $0xf0107640,0x8(%esp)
f01012ef:	f0 
f01012f0:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
f01012f7:	00 
f01012f8:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f01012ff:	e8 3c ed ff ff       	call   f0100040 <_panic>
f0101304:	89 da                	mov    %ebx,%edx
f0101306:	03 55 08             	add    0x8(%ebp),%edx
		} else {
			*p = (pa + i) | perm | PTE_P;
f0101309:	0b 55 e0             	or     -0x20(%ebp),%edx
f010130c:	89 10                	mov    %edx,(%eax)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	uintptr_t *p;
  size_t i;
	for (i = 0; i < size; i += PGSIZE) {
f010130e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101314:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0101317:	72 b4                	jb     f01012cd <boot_map_region+0x20>
			panic("Mapping failed\n");
		} else {
			*p = (pa + i) | perm | PTE_P;
		}
	}
}
f0101319:	83 c4 2c             	add    $0x2c,%esp
f010131c:	5b                   	pop    %ebx
f010131d:	5e                   	pop    %esi
f010131e:	5f                   	pop    %edi
f010131f:	5d                   	pop    %ebp
f0101320:	c3                   	ret    

f0101321 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101321:	55                   	push   %ebp
f0101322:	89 e5                	mov    %esp,%ebp
f0101324:	53                   	push   %ebx
f0101325:	83 ec 14             	sub    $0x14,%esp
f0101328:	8b 5d 10             	mov    0x10(%ebp),%ebx
  pte_t *pte = pgdir_walk(pgdir, va, 0);
f010132b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101332:	00 
f0101333:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101336:	89 44 24 04          	mov    %eax,0x4(%esp)
f010133a:	8b 45 08             	mov    0x8(%ebp),%eax
f010133d:	89 04 24             	mov    %eax,(%esp)
f0101340:	e8 83 fe ff ff       	call   f01011c8 <pgdir_walk>
  
  if (!pte || !(*pte & PTE_P)) { //Check if page table and entry exist
f0101345:	85 c0                	test   %eax,%eax
f0101347:	74 3f                	je     f0101388 <page_lookup+0x67>
f0101349:	f6 00 01             	testb  $0x1,(%eax)
f010134c:	74 41                	je     f010138f <page_lookup+0x6e>
    return NULL;
  }

  if (pte_store) {
f010134e:	85 db                	test   %ebx,%ebx
f0101350:	74 02                	je     f0101354 <page_lookup+0x33>
    *pte_store = pte;
f0101352:	89 03                	mov    %eax,(%ebx)
  }

  return pa2page(PTE_ADDR(*pte));
f0101354:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101356:	c1 e8 0c             	shr    $0xc,%eax
f0101359:	3b 05 88 ce 20 f0    	cmp    0xf020ce88,%eax
f010135f:	72 1c                	jb     f010137d <page_lookup+0x5c>
		panic("pa2page called with invalid pa");
f0101361:	c7 44 24 08 74 79 10 	movl   $0xf0107974,0x8(%esp)
f0101368:	f0 
f0101369:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0101370:	00 
f0101371:	c7 04 24 6b 75 10 f0 	movl   $0xf010756b,(%esp)
f0101378:	e8 c3 ec ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f010137d:	8b 15 90 ce 20 f0    	mov    0xf020ce90,%edx
f0101383:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0101386:	eb 0c                	jmp    f0101394 <page_lookup+0x73>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
  pte_t *pte = pgdir_walk(pgdir, va, 0);
  
  if (!pte || !(*pte & PTE_P)) { //Check if page table and entry exist
    return NULL;
f0101388:	b8 00 00 00 00       	mov    $0x0,%eax
f010138d:	eb 05                	jmp    f0101394 <page_lookup+0x73>
f010138f:	b8 00 00 00 00       	mov    $0x0,%eax
  if (pte_store) {
    *pte_store = pte;
  }

  return pa2page(PTE_ADDR(*pte));
}
f0101394:	83 c4 14             	add    $0x14,%esp
f0101397:	5b                   	pop    %ebx
f0101398:	5d                   	pop    %ebp
f0101399:	c3                   	ret    

f010139a <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010139a:	55                   	push   %ebp
f010139b:	89 e5                	mov    %esp,%ebp
f010139d:	83 ec 08             	sub    $0x8,%esp
  // Flush the entry only if we're modifying the current address space.
  if (!curenv || curenv->env_pgdir == pgdir)
f01013a0:	e8 f4 54 00 00       	call   f0106899 <cpunum>
f01013a5:	6b c0 74             	imul   $0x74,%eax,%eax
f01013a8:	83 b8 28 d0 20 f0 00 	cmpl   $0x0,-0xfdf2fd8(%eax)
f01013af:	74 16                	je     f01013c7 <tlb_invalidate+0x2d>
f01013b1:	e8 e3 54 00 00       	call   f0106899 <cpunum>
f01013b6:	6b c0 74             	imul   $0x74,%eax,%eax
f01013b9:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f01013bf:	8b 55 08             	mov    0x8(%ebp),%edx
f01013c2:	39 50 60             	cmp    %edx,0x60(%eax)
f01013c5:	75 06                	jne    f01013cd <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
  __asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01013c7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01013ca:	0f 01 38             	invlpg (%eax)
    invlpg(va);
}
f01013cd:	c9                   	leave  
f01013ce:	c3                   	ret    

f01013cf <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
//  tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01013cf:	55                   	push   %ebp
f01013d0:	89 e5                	mov    %esp,%ebp
f01013d2:	56                   	push   %esi
f01013d3:	53                   	push   %ebx
f01013d4:	83 ec 20             	sub    $0x20,%esp
f01013d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01013da:	8b 75 0c             	mov    0xc(%ebp),%esi
  pte_t *pte;
  struct PageInfo *pp = page_lookup(pgdir, va, &pte);
f01013dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01013e0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01013e4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01013e8:	89 1c 24             	mov    %ebx,(%esp)
f01013eb:	e8 31 ff ff ff       	call   f0101321 <page_lookup>
  if (!pp) {
f01013f0:	85 c0                	test   %eax,%eax
f01013f2:	74 1d                	je     f0101411 <page_remove+0x42>
    return;
  }
  page_decref(pp);
f01013f4:	89 04 24             	mov    %eax,(%esp)
f01013f7:	e8 a9 fd ff ff       	call   f01011a5 <page_decref>
  *pte = 0;
f01013fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01013ff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  tlb_invalidate(pgdir, va);
f0101405:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101409:	89 1c 24             	mov    %ebx,(%esp)
f010140c:	e8 89 ff ff ff       	call   f010139a <tlb_invalidate>
}
f0101411:	83 c4 20             	add    $0x20,%esp
f0101414:	5b                   	pop    %ebx
f0101415:	5e                   	pop    %esi
f0101416:	5d                   	pop    %ebp
f0101417:	c3                   	ret    

f0101418 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101418:	55                   	push   %ebp
f0101419:	89 e5                	mov    %esp,%ebp
f010141b:	57                   	push   %edi
f010141c:	56                   	push   %esi
f010141d:	53                   	push   %ebx
f010141e:	83 ec 1c             	sub    $0x1c,%esp
f0101421:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101424:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte = pgdir_walk(pgdir, va, true);
f0101427:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010142e:	00 
f010142f:	8b 45 10             	mov    0x10(%ebp),%eax
f0101432:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101436:	89 1c 24             	mov    %ebx,(%esp)
f0101439:	e8 8a fd ff ff       	call   f01011c8 <pgdir_walk>
f010143e:	89 c6                	mov    %eax,%esi

  if (!pte) {
f0101440:	85 c0                	test   %eax,%eax
f0101442:	74 51                	je     f0101495 <page_insert+0x7d>
    return -E_NO_MEM;
  }

  pp->pp_ref++; //increment reference (cannot fail from no mem from here)
f0101444:	66 83 47 04 01       	addw   $0x1,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101449:	2b 3d 90 ce 20 f0    	sub    0xf020ce90,%edi
f010144f:	c1 ff 03             	sar    $0x3,%edi
f0101452:	c1 e7 0c             	shl    $0xc,%edi

  physaddr_t pa = page2pa(pp);

  if (*pte & PTE_P) { //check if there was a page
f0101455:	f6 00 01             	testb  $0x1,(%eax)
f0101458:	74 1e                	je     f0101478 <page_insert+0x60>
    page_remove(pgdir, va);
f010145a:	8b 45 10             	mov    0x10(%ebp),%eax
f010145d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101461:	89 1c 24             	mov    %ebx,(%esp)
f0101464:	e8 66 ff ff ff       	call   f01013cf <page_remove>
    tlb_invalidate(pgdir, va);
f0101469:	8b 45 10             	mov    0x10(%ebp),%eax
f010146c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101470:	89 1c 24             	mov    %ebx,(%esp)
f0101473:	e8 22 ff ff ff       	call   f010139a <tlb_invalidate>
  }
  
  *pte = pa | perm | PTE_P;
f0101478:	8b 45 14             	mov    0x14(%ebp),%eax
f010147b:	83 c8 01             	or     $0x1,%eax
f010147e:	09 c7                	or     %eax,%edi
f0101480:	89 3e                	mov    %edi,(%esi)
  pgdir[PDX(va)] |= perm;
f0101482:	8b 45 10             	mov    0x10(%ebp),%eax
f0101485:	c1 e8 16             	shr    $0x16,%eax
f0101488:	8b 55 14             	mov    0x14(%ebp),%edx
f010148b:	09 14 83             	or     %edx,(%ebx,%eax,4)

  return 0;
f010148e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101493:	eb 05                	jmp    f010149a <page_insert+0x82>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
  pte_t *pte = pgdir_walk(pgdir, va, true);

  if (!pte) {
    return -E_NO_MEM;
f0101495:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  
  *pte = pa | perm | PTE_P;
  pgdir[PDX(va)] |= perm;

  return 0;
}
f010149a:	83 c4 1c             	add    $0x1c,%esp
f010149d:	5b                   	pop    %ebx
f010149e:	5e                   	pop    %esi
f010149f:	5f                   	pop    %edi
f01014a0:	5d                   	pop    %ebp
f01014a1:	c3                   	ret    

f01014a2 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01014a2:	55                   	push   %ebp
f01014a3:	89 e5                	mov    %esp,%ebp
f01014a5:	53                   	push   %ebx
f01014a6:	83 ec 14             	sub    $0x14,%esp
  // okay to simply panic if this happens).
  //
  // Hint: The staff solution uses boot_map_region.
  //
  // Your code here:
  if (base + ROUNDUP(size, PGSIZE) > MMIOLIM) {
f01014a9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014ac:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f01014b2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f01014b8:	8b 15 00 13 12 f0    	mov    0xf0121300,%edx
f01014be:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f01014c1:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f01014c6:	76 20                	jbe    f01014e8 <mmio_map_region+0x46>
	  panic("Allocation exceeds MMIOLIM: %x", base + ROUNDUP(size, PGSIZE));
f01014c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01014cc:	c7 44 24 08 94 79 10 	movl   $0xf0107994,0x8(%esp)
f01014d3:	f0 
f01014d4:	c7 44 24 04 6e 02 00 	movl   $0x26e,0x4(%esp)
f01014db:	00 
f01014dc:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f01014e3:	e8 58 eb ff ff       	call   f0100040 <_panic>
	}
  boot_map_region(kern_pgdir, base, ROUNDUP(size, PGSIZE), pa, PTE_PCD | PTE_PWT | PTE_W);
f01014e8:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f01014ef:	00 
f01014f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01014f3:	89 04 24             	mov    %eax,(%esp)
f01014f6:	89 d9                	mov    %ebx,%ecx
f01014f8:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f01014fd:	e8 ab fd ff ff       	call   f01012ad <boot_map_region>
  base += ROUNDUP(size, PGSIZE);
f0101502:	a1 00 13 12 f0       	mov    0xf0121300,%eax
f0101507:	01 c3                	add    %eax,%ebx
f0101509:	89 1d 00 13 12 f0    	mov    %ebx,0xf0121300
  return (void *) base - ROUNDUP(size, PGSIZE);
}
f010150f:	83 c4 14             	add    $0x14,%esp
f0101512:	5b                   	pop    %ebx
f0101513:	5d                   	pop    %ebp
f0101514:	c3                   	ret    

f0101515 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101515:	55                   	push   %ebp
f0101516:	89 e5                	mov    %esp,%ebp
f0101518:	57                   	push   %edi
f0101519:	56                   	push   %esi
f010151a:	53                   	push   %ebx
f010151b:	83 ec 4c             	sub    $0x4c,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
  return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010151e:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f0101525:	e8 dd 28 00 00       	call   f0103e07 <mc146818_read>
f010152a:	89 c3                	mov    %eax,%ebx
f010152c:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0101533:	e8 cf 28 00 00       	call   f0103e07 <mc146818_read>
f0101538:	c1 e0 08             	shl    $0x8,%eax
f010153b:	09 c3                	or     %eax,%ebx
{
  size_t npages_extmem;

  // Use CMOS calls to measure available base & extended memory.
  // (CMOS calls return results in kilobytes.)
  npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f010153d:	89 d8                	mov    %ebx,%eax
f010153f:	c1 e0 0a             	shl    $0xa,%eax
f0101542:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101548:	85 c0                	test   %eax,%eax
f010154a:	0f 48 c2             	cmovs  %edx,%eax
f010154d:	c1 f8 0c             	sar    $0xc,%eax
f0101550:	a3 44 c2 20 f0       	mov    %eax,0xf020c244
// --------------------------------------------------------------

static int
nvram_read(int r)
{
  return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101555:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f010155c:	e8 a6 28 00 00       	call   f0103e07 <mc146818_read>
f0101561:	89 c3                	mov    %eax,%ebx
f0101563:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f010156a:	e8 98 28 00 00       	call   f0103e07 <mc146818_read>
f010156f:	c1 e0 08             	shl    $0x8,%eax
f0101572:	09 c3                	or     %eax,%ebx
  size_t npages_extmem;

  // Use CMOS calls to measure available base & extended memory.
  // (CMOS calls return results in kilobytes.)
  npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
  npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101574:	89 d8                	mov    %ebx,%eax
f0101576:	c1 e0 0a             	shl    $0xa,%eax
f0101579:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010157f:	85 c0                	test   %eax,%eax
f0101581:	0f 48 c2             	cmovs  %edx,%eax
f0101584:	c1 f8 0c             	sar    $0xc,%eax

  // Calculate the number of physical pages available in both base
  // and extended memory.
  if (npages_extmem)
f0101587:	85 c0                	test   %eax,%eax
f0101589:	74 0e                	je     f0101599 <mem_init+0x84>
    npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f010158b:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101591:	89 15 88 ce 20 f0    	mov    %edx,0xf020ce88
f0101597:	eb 0c                	jmp    f01015a5 <mem_init+0x90>
  else
    npages = npages_basemem;
f0101599:	8b 15 44 c2 20 f0    	mov    0xf020c244,%edx
f010159f:	89 15 88 ce 20 f0    	mov    %edx,0xf020ce88

  cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
          npages * PGSIZE / 1024,
          npages_basemem * PGSIZE / 1024,
          npages_extmem * PGSIZE / 1024);
f01015a5:	c1 e0 0c             	shl    $0xc,%eax
  if (npages_extmem)
    npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
  else
    npages = npages_basemem;

  cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01015a8:	c1 e8 0a             	shr    $0xa,%eax
f01015ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
          npages * PGSIZE / 1024,
          npages_basemem * PGSIZE / 1024,
f01015af:	a1 44 c2 20 f0       	mov    0xf020c244,%eax
f01015b4:	c1 e0 0c             	shl    $0xc,%eax
  if (npages_extmem)
    npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
  else
    npages = npages_basemem;

  cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01015b7:	c1 e8 0a             	shr    $0xa,%eax
f01015ba:	89 44 24 08          	mov    %eax,0x8(%esp)
          npages * PGSIZE / 1024,
f01015be:	a1 88 ce 20 f0       	mov    0xf020ce88,%eax
f01015c3:	c1 e0 0c             	shl    $0xc,%eax
  if (npages_extmem)
    npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
  else
    npages = npages_basemem;

  cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01015c6:	c1 e8 0a             	shr    $0xa,%eax
f01015c9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015cd:	c7 04 24 b4 79 10 f0 	movl   $0xf01079b4,(%esp)
f01015d4:	e8 97 29 00 00       	call   f0103f70 <cprintf>
  // Remove this line when you're ready to test this function.
  //panic("mem_init: This function is not finished\n");

  //////////////////////////////////////////////////////////////////////
  // create initial page directory.
  kern_pgdir = (pde_t*)boot_alloc(PGSIZE);
f01015d9:	b8 00 10 00 00       	mov    $0x1000,%eax
f01015de:	e8 4d f5 ff ff       	call   f0100b30 <boot_alloc>
f01015e3:	a3 8c ce 20 f0       	mov    %eax,0xf020ce8c
  memset(kern_pgdir, 0, PGSIZE);
f01015e8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01015ef:	00 
f01015f0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01015f7:	00 
f01015f8:	89 04 24             	mov    %eax,(%esp)
f01015fb:	e8 47 4c 00 00       	call   f0106247 <memset>
  // a virtual page table at virtual address UVPT.
  // (For now, you don't have understand the greater purpose of the
  // following line.)

  // Permissions: kernel R, user R
  kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101600:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101605:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010160a:	77 20                	ja     f010162c <mem_init+0x117>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010160c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101610:	c7 44 24 08 c8 6f 10 	movl   $0xf0106fc8,0x8(%esp)
f0101617:	f0 
f0101618:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
f010161f:	00 
f0101620:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101627:	e8 14 ea ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010162c:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101632:	83 ca 05             	or     $0x5,%edx
f0101635:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
  // The kernel uses this array to keep track of physical pages: for
  // each physical page, there is a corresponding struct PageInfo in this
  // array.  'npages' is the number of physical pages in memory.  Use memset
  // to initialize all fields of each struct PageInfo to 0.
  // Your code goes here:
  pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f010163b:	a1 88 ce 20 f0       	mov    0xf020ce88,%eax
f0101640:	c1 e0 03             	shl    $0x3,%eax
f0101643:	e8 e8 f4 ff ff       	call   f0100b30 <boot_alloc>
f0101648:	a3 90 ce 20 f0       	mov    %eax,0xf020ce90
  memset(pages, 0, npages * sizeof(struct PageInfo));
f010164d:	8b 0d 88 ce 20 f0    	mov    0xf020ce88,%ecx
f0101653:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f010165a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010165e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101665:	00 
f0101666:	89 04 24             	mov    %eax,(%esp)
f0101669:	e8 d9 4b 00 00       	call   f0106247 <memset>

  //////////////////////////////////////////////////////////////////////
  // Make 'envs' point to an array of size 'NENV' of 'struct Env'.
  // LAB 3: Your code here.
  envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
f010166e:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101673:	e8 b8 f4 ff ff       	call   f0100b30 <boot_alloc>
f0101678:	a3 48 c2 20 f0       	mov    %eax,0xf020c248
  memset(envs, 0, NENV * sizeof(struct Env));
f010167d:	c7 44 24 08 00 f0 01 	movl   $0x1f000,0x8(%esp)
f0101684:	00 
f0101685:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010168c:	00 
f010168d:	89 04 24             	mov    %eax,(%esp)
f0101690:	e8 b2 4b 00 00       	call   f0106247 <memset>
  // Now that we've allocated the initial kernel data structures, we set
  // up the list of free physical pages. Once we've done so, all further
  // memory management will go through the page_* functions. In
  // particular, we can now map memory using boot_map_region
  // or page_insert
  page_init();
f0101695:	e8 4a f9 ff ff       	call   f0100fe4 <page_init>

  check_page_free_list(1);
f010169a:	b8 01 00 00 00       	mov    $0x1,%eax
f010169f:	e8 ad f5 ff ff       	call   f0100c51 <check_page_free_list>
  int nfree;
  struct PageInfo *fl;
  char *c;
  int i;

  if (!pages)
f01016a4:	83 3d 90 ce 20 f0 00 	cmpl   $0x0,0xf020ce90
f01016ab:	75 1c                	jne    f01016c9 <mem_init+0x1b4>
    panic("'pages' is a null pointer!");
f01016ad:	c7 44 24 08 50 76 10 	movl   $0xf0107650,0x8(%esp)
f01016b4:	f0 
f01016b5:	c7 44 24 04 fb 02 00 	movl   $0x2fb,0x4(%esp)
f01016bc:	00 
f01016bd:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f01016c4:	e8 77 e9 ff ff       	call   f0100040 <_panic>

  // check number of free pages
  for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01016c9:	a1 40 c2 20 f0       	mov    0xf020c240,%eax
f01016ce:	bb 00 00 00 00       	mov    $0x0,%ebx
f01016d3:	eb 05                	jmp    f01016da <mem_init+0x1c5>
    ++nfree;
f01016d5:	83 c3 01             	add    $0x1,%ebx

  if (!pages)
    panic("'pages' is a null pointer!");

  // check number of free pages
  for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01016d8:	8b 00                	mov    (%eax),%eax
f01016da:	85 c0                	test   %eax,%eax
f01016dc:	75 f7                	jne    f01016d5 <mem_init+0x1c0>
    ++nfree;

  // should be able to allocate three pages
  pp0 = pp1 = pp2 = 0;
  assert((pp0 = page_alloc(0)));
f01016de:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016e5:	e8 cc f9 ff ff       	call   f01010b6 <page_alloc>
f01016ea:	89 c7                	mov    %eax,%edi
f01016ec:	85 c0                	test   %eax,%eax
f01016ee:	75 24                	jne    f0101714 <mem_init+0x1ff>
f01016f0:	c7 44 24 0c 6b 76 10 	movl   $0xf010766b,0xc(%esp)
f01016f7:	f0 
f01016f8:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f01016ff:	f0 
f0101700:	c7 44 24 04 03 03 00 	movl   $0x303,0x4(%esp)
f0101707:	00 
f0101708:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f010170f:	e8 2c e9 ff ff       	call   f0100040 <_panic>
  assert((pp1 = page_alloc(0)));
f0101714:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010171b:	e8 96 f9 ff ff       	call   f01010b6 <page_alloc>
f0101720:	89 c6                	mov    %eax,%esi
f0101722:	85 c0                	test   %eax,%eax
f0101724:	75 24                	jne    f010174a <mem_init+0x235>
f0101726:	c7 44 24 0c 81 76 10 	movl   $0xf0107681,0xc(%esp)
f010172d:	f0 
f010172e:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0101735:	f0 
f0101736:	c7 44 24 04 04 03 00 	movl   $0x304,0x4(%esp)
f010173d:	00 
f010173e:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101745:	e8 f6 e8 ff ff       	call   f0100040 <_panic>
  assert((pp2 = page_alloc(0)));
f010174a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101751:	e8 60 f9 ff ff       	call   f01010b6 <page_alloc>
f0101756:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101759:	85 c0                	test   %eax,%eax
f010175b:	75 24                	jne    f0101781 <mem_init+0x26c>
f010175d:	c7 44 24 0c 97 76 10 	movl   $0xf0107697,0xc(%esp)
f0101764:	f0 
f0101765:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f010176c:	f0 
f010176d:	c7 44 24 04 05 03 00 	movl   $0x305,0x4(%esp)
f0101774:	00 
f0101775:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f010177c:	e8 bf e8 ff ff       	call   f0100040 <_panic>

  assert(pp0);
  assert(pp1 && pp1 != pp0);
f0101781:	39 f7                	cmp    %esi,%edi
f0101783:	75 24                	jne    f01017a9 <mem_init+0x294>
f0101785:	c7 44 24 0c ad 76 10 	movl   $0xf01076ad,0xc(%esp)
f010178c:	f0 
f010178d:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0101794:	f0 
f0101795:	c7 44 24 04 08 03 00 	movl   $0x308,0x4(%esp)
f010179c:	00 
f010179d:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f01017a4:	e8 97 e8 ff ff       	call   f0100040 <_panic>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017a9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017ac:	39 c6                	cmp    %eax,%esi
f01017ae:	74 04                	je     f01017b4 <mem_init+0x29f>
f01017b0:	39 c7                	cmp    %eax,%edi
f01017b2:	75 24                	jne    f01017d8 <mem_init+0x2c3>
f01017b4:	c7 44 24 0c f0 79 10 	movl   $0xf01079f0,0xc(%esp)
f01017bb:	f0 
f01017bc:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f01017c3:	f0 
f01017c4:	c7 44 24 04 09 03 00 	movl   $0x309,0x4(%esp)
f01017cb:	00 
f01017cc:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f01017d3:	e8 68 e8 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01017d8:	8b 15 90 ce 20 f0    	mov    0xf020ce90,%edx
  assert(page2pa(pp0) < npages*PGSIZE);
f01017de:	a1 88 ce 20 f0       	mov    0xf020ce88,%eax
f01017e3:	c1 e0 0c             	shl    $0xc,%eax
f01017e6:	89 f9                	mov    %edi,%ecx
f01017e8:	29 d1                	sub    %edx,%ecx
f01017ea:	c1 f9 03             	sar    $0x3,%ecx
f01017ed:	c1 e1 0c             	shl    $0xc,%ecx
f01017f0:	39 c1                	cmp    %eax,%ecx
f01017f2:	72 24                	jb     f0101818 <mem_init+0x303>
f01017f4:	c7 44 24 0c bf 76 10 	movl   $0xf01076bf,0xc(%esp)
f01017fb:	f0 
f01017fc:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0101803:	f0 
f0101804:	c7 44 24 04 0a 03 00 	movl   $0x30a,0x4(%esp)
f010180b:	00 
f010180c:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101813:	e8 28 e8 ff ff       	call   f0100040 <_panic>
f0101818:	89 f1                	mov    %esi,%ecx
f010181a:	29 d1                	sub    %edx,%ecx
f010181c:	c1 f9 03             	sar    $0x3,%ecx
f010181f:	c1 e1 0c             	shl    $0xc,%ecx
  assert(page2pa(pp1) < npages*PGSIZE);
f0101822:	39 c8                	cmp    %ecx,%eax
f0101824:	77 24                	ja     f010184a <mem_init+0x335>
f0101826:	c7 44 24 0c dc 76 10 	movl   $0xf01076dc,0xc(%esp)
f010182d:	f0 
f010182e:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0101835:	f0 
f0101836:	c7 44 24 04 0b 03 00 	movl   $0x30b,0x4(%esp)
f010183d:	00 
f010183e:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101845:	e8 f6 e7 ff ff       	call   f0100040 <_panic>
f010184a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010184d:	29 d1                	sub    %edx,%ecx
f010184f:	89 ca                	mov    %ecx,%edx
f0101851:	c1 fa 03             	sar    $0x3,%edx
f0101854:	c1 e2 0c             	shl    $0xc,%edx
  assert(page2pa(pp2) < npages*PGSIZE);
f0101857:	39 d0                	cmp    %edx,%eax
f0101859:	77 24                	ja     f010187f <mem_init+0x36a>
f010185b:	c7 44 24 0c f9 76 10 	movl   $0xf01076f9,0xc(%esp)
f0101862:	f0 
f0101863:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f010186a:	f0 
f010186b:	c7 44 24 04 0c 03 00 	movl   $0x30c,0x4(%esp)
f0101872:	00 
f0101873:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f010187a:	e8 c1 e7 ff ff       	call   f0100040 <_panic>

  // temporarily steal the rest of the free pages
  fl = page_free_list;
f010187f:	a1 40 c2 20 f0       	mov    0xf020c240,%eax
f0101884:	89 45 d0             	mov    %eax,-0x30(%ebp)
  page_free_list = 0;
f0101887:	c7 05 40 c2 20 f0 00 	movl   $0x0,0xf020c240
f010188e:	00 00 00 

  // should be no free memory
  assert(!page_alloc(0));
f0101891:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101898:	e8 19 f8 ff ff       	call   f01010b6 <page_alloc>
f010189d:	85 c0                	test   %eax,%eax
f010189f:	74 24                	je     f01018c5 <mem_init+0x3b0>
f01018a1:	c7 44 24 0c 16 77 10 	movl   $0xf0107716,0xc(%esp)
f01018a8:	f0 
f01018a9:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f01018b0:	f0 
f01018b1:	c7 44 24 04 13 03 00 	movl   $0x313,0x4(%esp)
f01018b8:	00 
f01018b9:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f01018c0:	e8 7b e7 ff ff       	call   f0100040 <_panic>

  // free and re-allocate?
  page_free(pp0);
f01018c5:	89 3c 24             	mov    %edi,(%esp)
f01018c8:	e8 98 f8 ff ff       	call   f0101165 <page_free>
  page_free(pp1);
f01018cd:	89 34 24             	mov    %esi,(%esp)
f01018d0:	e8 90 f8 ff ff       	call   f0101165 <page_free>
  page_free(pp2);
f01018d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01018d8:	89 04 24             	mov    %eax,(%esp)
f01018db:	e8 85 f8 ff ff       	call   f0101165 <page_free>
  pp0 = pp1 = pp2 = 0;
  assert((pp0 = page_alloc(0)));
f01018e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018e7:	e8 ca f7 ff ff       	call   f01010b6 <page_alloc>
f01018ec:	89 c6                	mov    %eax,%esi
f01018ee:	85 c0                	test   %eax,%eax
f01018f0:	75 24                	jne    f0101916 <mem_init+0x401>
f01018f2:	c7 44 24 0c 6b 76 10 	movl   $0xf010766b,0xc(%esp)
f01018f9:	f0 
f01018fa:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0101901:	f0 
f0101902:	c7 44 24 04 1a 03 00 	movl   $0x31a,0x4(%esp)
f0101909:	00 
f010190a:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101911:	e8 2a e7 ff ff       	call   f0100040 <_panic>
  assert((pp1 = page_alloc(0)));
f0101916:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010191d:	e8 94 f7 ff ff       	call   f01010b6 <page_alloc>
f0101922:	89 c7                	mov    %eax,%edi
f0101924:	85 c0                	test   %eax,%eax
f0101926:	75 24                	jne    f010194c <mem_init+0x437>
f0101928:	c7 44 24 0c 81 76 10 	movl   $0xf0107681,0xc(%esp)
f010192f:	f0 
f0101930:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0101937:	f0 
f0101938:	c7 44 24 04 1b 03 00 	movl   $0x31b,0x4(%esp)
f010193f:	00 
f0101940:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101947:	e8 f4 e6 ff ff       	call   f0100040 <_panic>
  assert((pp2 = page_alloc(0)));
f010194c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101953:	e8 5e f7 ff ff       	call   f01010b6 <page_alloc>
f0101958:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010195b:	85 c0                	test   %eax,%eax
f010195d:	75 24                	jne    f0101983 <mem_init+0x46e>
f010195f:	c7 44 24 0c 97 76 10 	movl   $0xf0107697,0xc(%esp)
f0101966:	f0 
f0101967:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f010196e:	f0 
f010196f:	c7 44 24 04 1c 03 00 	movl   $0x31c,0x4(%esp)
f0101976:	00 
f0101977:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f010197e:	e8 bd e6 ff ff       	call   f0100040 <_panic>
  assert(pp0);
  assert(pp1 && pp1 != pp0);
f0101983:	39 fe                	cmp    %edi,%esi
f0101985:	75 24                	jne    f01019ab <mem_init+0x496>
f0101987:	c7 44 24 0c ad 76 10 	movl   $0xf01076ad,0xc(%esp)
f010198e:	f0 
f010198f:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0101996:	f0 
f0101997:	c7 44 24 04 1e 03 00 	movl   $0x31e,0x4(%esp)
f010199e:	00 
f010199f:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f01019a6:	e8 95 e6 ff ff       	call   f0100040 <_panic>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01019ab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019ae:	39 c7                	cmp    %eax,%edi
f01019b0:	74 04                	je     f01019b6 <mem_init+0x4a1>
f01019b2:	39 c6                	cmp    %eax,%esi
f01019b4:	75 24                	jne    f01019da <mem_init+0x4c5>
f01019b6:	c7 44 24 0c f0 79 10 	movl   $0xf01079f0,0xc(%esp)
f01019bd:	f0 
f01019be:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f01019c5:	f0 
f01019c6:	c7 44 24 04 1f 03 00 	movl   $0x31f,0x4(%esp)
f01019cd:	00 
f01019ce:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f01019d5:	e8 66 e6 ff ff       	call   f0100040 <_panic>
  assert(!page_alloc(0));
f01019da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019e1:	e8 d0 f6 ff ff       	call   f01010b6 <page_alloc>
f01019e6:	85 c0                	test   %eax,%eax
f01019e8:	74 24                	je     f0101a0e <mem_init+0x4f9>
f01019ea:	c7 44 24 0c 16 77 10 	movl   $0xf0107716,0xc(%esp)
f01019f1:	f0 
f01019f2:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f01019f9:	f0 
f01019fa:	c7 44 24 04 20 03 00 	movl   $0x320,0x4(%esp)
f0101a01:	00 
f0101a02:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101a09:	e8 32 e6 ff ff       	call   f0100040 <_panic>
f0101a0e:	89 f0                	mov    %esi,%eax
f0101a10:	2b 05 90 ce 20 f0    	sub    0xf020ce90,%eax
f0101a16:	c1 f8 03             	sar    $0x3,%eax
f0101a19:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a1c:	89 c2                	mov    %eax,%edx
f0101a1e:	c1 ea 0c             	shr    $0xc,%edx
f0101a21:	3b 15 88 ce 20 f0    	cmp    0xf020ce88,%edx
f0101a27:	72 20                	jb     f0101a49 <mem_init+0x534>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a29:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101a2d:	c7 44 24 08 a4 6f 10 	movl   $0xf0106fa4,0x8(%esp)
f0101a34:	f0 
f0101a35:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101a3c:	00 
f0101a3d:	c7 04 24 6b 75 10 f0 	movl   $0xf010756b,(%esp)
f0101a44:	e8 f7 e5 ff ff       	call   f0100040 <_panic>

  // test flags
  memset(page2kva(pp0), 1, PGSIZE);
f0101a49:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101a50:	00 
f0101a51:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101a58:	00 
	return (void *)(pa + KERNBASE);
f0101a59:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101a5e:	89 04 24             	mov    %eax,(%esp)
f0101a61:	e8 e1 47 00 00       	call   f0106247 <memset>
  page_free(pp0);
f0101a66:	89 34 24             	mov    %esi,(%esp)
f0101a69:	e8 f7 f6 ff ff       	call   f0101165 <page_free>
  assert((pp = page_alloc(ALLOC_ZERO)));
f0101a6e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101a75:	e8 3c f6 ff ff       	call   f01010b6 <page_alloc>
f0101a7a:	85 c0                	test   %eax,%eax
f0101a7c:	75 24                	jne    f0101aa2 <mem_init+0x58d>
f0101a7e:	c7 44 24 0c 25 77 10 	movl   $0xf0107725,0xc(%esp)
f0101a85:	f0 
f0101a86:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0101a8d:	f0 
f0101a8e:	c7 44 24 04 25 03 00 	movl   $0x325,0x4(%esp)
f0101a95:	00 
f0101a96:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101a9d:	e8 9e e5 ff ff       	call   f0100040 <_panic>
  assert(pp && pp0 == pp);
f0101aa2:	39 c6                	cmp    %eax,%esi
f0101aa4:	74 24                	je     f0101aca <mem_init+0x5b5>
f0101aa6:	c7 44 24 0c 43 77 10 	movl   $0xf0107743,0xc(%esp)
f0101aad:	f0 
f0101aae:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0101ab5:	f0 
f0101ab6:	c7 44 24 04 26 03 00 	movl   $0x326,0x4(%esp)
f0101abd:	00 
f0101abe:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101ac5:	e8 76 e5 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101aca:	89 f0                	mov    %esi,%eax
f0101acc:	2b 05 90 ce 20 f0    	sub    0xf020ce90,%eax
f0101ad2:	c1 f8 03             	sar    $0x3,%eax
f0101ad5:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101ad8:	89 c2                	mov    %eax,%edx
f0101ada:	c1 ea 0c             	shr    $0xc,%edx
f0101add:	3b 15 88 ce 20 f0    	cmp    0xf020ce88,%edx
f0101ae3:	72 20                	jb     f0101b05 <mem_init+0x5f0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ae5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101ae9:	c7 44 24 08 a4 6f 10 	movl   $0xf0106fa4,0x8(%esp)
f0101af0:	f0 
f0101af1:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101af8:	00 
f0101af9:	c7 04 24 6b 75 10 f0 	movl   $0xf010756b,(%esp)
f0101b00:	e8 3b e5 ff ff       	call   f0100040 <_panic>
f0101b05:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101b0b:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
  c = page2kva(pp);
  for (i = 0; i < PGSIZE; i++)
    assert(c[i] == 0);
f0101b11:	80 38 00             	cmpb   $0x0,(%eax)
f0101b14:	74 24                	je     f0101b3a <mem_init+0x625>
f0101b16:	c7 44 24 0c 53 77 10 	movl   $0xf0107753,0xc(%esp)
f0101b1d:	f0 
f0101b1e:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0101b25:	f0 
f0101b26:	c7 44 24 04 29 03 00 	movl   $0x329,0x4(%esp)
f0101b2d:	00 
f0101b2e:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101b35:	e8 06 e5 ff ff       	call   f0100040 <_panic>
f0101b3a:	83 c0 01             	add    $0x1,%eax
  memset(page2kva(pp0), 1, PGSIZE);
  page_free(pp0);
  assert((pp = page_alloc(ALLOC_ZERO)));
  assert(pp && pp0 == pp);
  c = page2kva(pp);
  for (i = 0; i < PGSIZE; i++)
f0101b3d:	39 d0                	cmp    %edx,%eax
f0101b3f:	75 d0                	jne    f0101b11 <mem_init+0x5fc>
    assert(c[i] == 0);

  // give free list back
  page_free_list = fl;
f0101b41:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b44:	a3 40 c2 20 f0       	mov    %eax,0xf020c240

  // free the pages we took
  page_free(pp0);
f0101b49:	89 34 24             	mov    %esi,(%esp)
f0101b4c:	e8 14 f6 ff ff       	call   f0101165 <page_free>
  page_free(pp1);
f0101b51:	89 3c 24             	mov    %edi,(%esp)
f0101b54:	e8 0c f6 ff ff       	call   f0101165 <page_free>
  page_free(pp2);
f0101b59:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b5c:	89 04 24             	mov    %eax,(%esp)
f0101b5f:	e8 01 f6 ff ff       	call   f0101165 <page_free>

  // number of free pages should be the same
  for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b64:	a1 40 c2 20 f0       	mov    0xf020c240,%eax
f0101b69:	eb 05                	jmp    f0101b70 <mem_init+0x65b>
    --nfree;
f0101b6b:	83 eb 01             	sub    $0x1,%ebx
  page_free(pp0);
  page_free(pp1);
  page_free(pp2);

  // number of free pages should be the same
  for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b6e:	8b 00                	mov    (%eax),%eax
f0101b70:	85 c0                	test   %eax,%eax
f0101b72:	75 f7                	jne    f0101b6b <mem_init+0x656>
    --nfree;
  assert(nfree == 0);
f0101b74:	85 db                	test   %ebx,%ebx
f0101b76:	74 24                	je     f0101b9c <mem_init+0x687>
f0101b78:	c7 44 24 0c 5d 77 10 	movl   $0xf010775d,0xc(%esp)
f0101b7f:	f0 
f0101b80:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0101b87:	f0 
f0101b88:	c7 44 24 04 36 03 00 	movl   $0x336,0x4(%esp)
f0101b8f:	00 
f0101b90:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101b97:	e8 a4 e4 ff ff       	call   f0100040 <_panic>

  cprintf("check_page_alloc() succeeded!\n");
f0101b9c:	c7 04 24 10 7a 10 f0 	movl   $0xf0107a10,(%esp)
f0101ba3:	e8 c8 23 00 00       	call   f0103f70 <cprintf>
  int i;
  extern pde_t entry_pgdir[];

  // should be able to allocate three pages
  pp0 = pp1 = pp2 = 0;
  assert((pp0 = page_alloc(0)));
f0101ba8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101baf:	e8 02 f5 ff ff       	call   f01010b6 <page_alloc>
f0101bb4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101bb7:	85 c0                	test   %eax,%eax
f0101bb9:	75 24                	jne    f0101bdf <mem_init+0x6ca>
f0101bbb:	c7 44 24 0c 6b 76 10 	movl   $0xf010766b,0xc(%esp)
f0101bc2:	f0 
f0101bc3:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0101bca:	f0 
f0101bcb:	c7 44 24 04 9d 03 00 	movl   $0x39d,0x4(%esp)
f0101bd2:	00 
f0101bd3:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101bda:	e8 61 e4 ff ff       	call   f0100040 <_panic>
  assert((pp1 = page_alloc(0)));
f0101bdf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101be6:	e8 cb f4 ff ff       	call   f01010b6 <page_alloc>
f0101beb:	89 c3                	mov    %eax,%ebx
f0101bed:	85 c0                	test   %eax,%eax
f0101bef:	75 24                	jne    f0101c15 <mem_init+0x700>
f0101bf1:	c7 44 24 0c 81 76 10 	movl   $0xf0107681,0xc(%esp)
f0101bf8:	f0 
f0101bf9:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0101c00:	f0 
f0101c01:	c7 44 24 04 9e 03 00 	movl   $0x39e,0x4(%esp)
f0101c08:	00 
f0101c09:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101c10:	e8 2b e4 ff ff       	call   f0100040 <_panic>
  assert((pp2 = page_alloc(0)));
f0101c15:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c1c:	e8 95 f4 ff ff       	call   f01010b6 <page_alloc>
f0101c21:	89 c6                	mov    %eax,%esi
f0101c23:	85 c0                	test   %eax,%eax
f0101c25:	75 24                	jne    f0101c4b <mem_init+0x736>
f0101c27:	c7 44 24 0c 97 76 10 	movl   $0xf0107697,0xc(%esp)
f0101c2e:	f0 
f0101c2f:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0101c36:	f0 
f0101c37:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f0101c3e:	00 
f0101c3f:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101c46:	e8 f5 e3 ff ff       	call   f0100040 <_panic>

  assert(pp0);
  assert(pp1 && pp1 != pp0);
f0101c4b:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101c4e:	75 24                	jne    f0101c74 <mem_init+0x75f>
f0101c50:	c7 44 24 0c ad 76 10 	movl   $0xf01076ad,0xc(%esp)
f0101c57:	f0 
f0101c58:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0101c5f:	f0 
f0101c60:	c7 44 24 04 a2 03 00 	movl   $0x3a2,0x4(%esp)
f0101c67:	00 
f0101c68:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101c6f:	e8 cc e3 ff ff       	call   f0100040 <_panic>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c74:	39 c3                	cmp    %eax,%ebx
f0101c76:	74 05                	je     f0101c7d <mem_init+0x768>
f0101c78:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101c7b:	75 24                	jne    f0101ca1 <mem_init+0x78c>
f0101c7d:	c7 44 24 0c f0 79 10 	movl   $0xf01079f0,0xc(%esp)
f0101c84:	f0 
f0101c85:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0101c8c:	f0 
f0101c8d:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f0101c94:	00 
f0101c95:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101c9c:	e8 9f e3 ff ff       	call   f0100040 <_panic>

  // temporarily steal the rest of the free pages
  fl = page_free_list;
f0101ca1:	a1 40 c2 20 f0       	mov    0xf020c240,%eax
f0101ca6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  page_free_list = 0;
f0101ca9:	c7 05 40 c2 20 f0 00 	movl   $0x0,0xf020c240
f0101cb0:	00 00 00 

  // should be no free memory
  assert(!page_alloc(0));
f0101cb3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101cba:	e8 f7 f3 ff ff       	call   f01010b6 <page_alloc>
f0101cbf:	85 c0                	test   %eax,%eax
f0101cc1:	74 24                	je     f0101ce7 <mem_init+0x7d2>
f0101cc3:	c7 44 24 0c 16 77 10 	movl   $0xf0107716,0xc(%esp)
f0101cca:	f0 
f0101ccb:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0101cd2:	f0 
f0101cd3:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f0101cda:	00 
f0101cdb:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101ce2:	e8 59 e3 ff ff       	call   f0100040 <_panic>

  // there is no page allocated at address 0
  assert(page_lookup(kern_pgdir, (void*)0x0, &ptep) == NULL);
f0101ce7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101cea:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101cee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101cf5:	00 
f0101cf6:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0101cfb:	89 04 24             	mov    %eax,(%esp)
f0101cfe:	e8 1e f6 ff ff       	call   f0101321 <page_lookup>
f0101d03:	85 c0                	test   %eax,%eax
f0101d05:	74 24                	je     f0101d2b <mem_init+0x816>
f0101d07:	c7 44 24 0c 30 7a 10 	movl   $0xf0107a30,0xc(%esp)
f0101d0e:	f0 
f0101d0f:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0101d16:	f0 
f0101d17:	c7 44 24 04 ad 03 00 	movl   $0x3ad,0x4(%esp)
f0101d1e:	00 
f0101d1f:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101d26:	e8 15 e3 ff ff       	call   f0100040 <_panic>

  // there is no free memory, so we can't allocate a page table
  assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101d2b:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d32:	00 
f0101d33:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101d3a:	00 
f0101d3b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101d3f:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0101d44:	89 04 24             	mov    %eax,(%esp)
f0101d47:	e8 cc f6 ff ff       	call   f0101418 <page_insert>
f0101d4c:	85 c0                	test   %eax,%eax
f0101d4e:	78 24                	js     f0101d74 <mem_init+0x85f>
f0101d50:	c7 44 24 0c 64 7a 10 	movl   $0xf0107a64,0xc(%esp)
f0101d57:	f0 
f0101d58:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0101d5f:	f0 
f0101d60:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f0101d67:	00 
f0101d68:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101d6f:	e8 cc e2 ff ff       	call   f0100040 <_panic>

  // free pp0 and try again: pp0 should be used for page table
  page_free(pp0);
f0101d74:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d77:	89 04 24             	mov    %eax,(%esp)
f0101d7a:	e8 e6 f3 ff ff       	call   f0101165 <page_free>
  assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101d7f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d86:	00 
f0101d87:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101d8e:	00 
f0101d8f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101d93:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0101d98:	89 04 24             	mov    %eax,(%esp)
f0101d9b:	e8 78 f6 ff ff       	call   f0101418 <page_insert>
f0101da0:	85 c0                	test   %eax,%eax
f0101da2:	74 24                	je     f0101dc8 <mem_init+0x8b3>
f0101da4:	c7 44 24 0c 94 7a 10 	movl   $0xf0107a94,0xc(%esp)
f0101dab:	f0 
f0101dac:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0101db3:	f0 
f0101db4:	c7 44 24 04 b4 03 00 	movl   $0x3b4,0x4(%esp)
f0101dbb:	00 
f0101dbc:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101dc3:	e8 78 e2 ff ff       	call   f0100040 <_panic>
  assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101dc8:	8b 3d 8c ce 20 f0    	mov    0xf020ce8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101dce:	a1 90 ce 20 f0       	mov    0xf020ce90,%eax
f0101dd3:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101dd6:	8b 17                	mov    (%edi),%edx
f0101dd8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101dde:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101de1:	29 c1                	sub    %eax,%ecx
f0101de3:	89 c8                	mov    %ecx,%eax
f0101de5:	c1 f8 03             	sar    $0x3,%eax
f0101de8:	c1 e0 0c             	shl    $0xc,%eax
f0101deb:	39 c2                	cmp    %eax,%edx
f0101ded:	74 24                	je     f0101e13 <mem_init+0x8fe>
f0101def:	c7 44 24 0c c4 7a 10 	movl   $0xf0107ac4,0xc(%esp)
f0101df6:	f0 
f0101df7:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0101dfe:	f0 
f0101dff:	c7 44 24 04 b5 03 00 	movl   $0x3b5,0x4(%esp)
f0101e06:	00 
f0101e07:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101e0e:	e8 2d e2 ff ff       	call   f0100040 <_panic>
  assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101e13:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e18:	89 f8                	mov    %edi,%eax
f0101e1a:	e8 c3 ed ff ff       	call   f0100be2 <check_va2pa>
f0101e1f:	89 da                	mov    %ebx,%edx
f0101e21:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101e24:	c1 fa 03             	sar    $0x3,%edx
f0101e27:	c1 e2 0c             	shl    $0xc,%edx
f0101e2a:	39 d0                	cmp    %edx,%eax
f0101e2c:	74 24                	je     f0101e52 <mem_init+0x93d>
f0101e2e:	c7 44 24 0c ec 7a 10 	movl   $0xf0107aec,0xc(%esp)
f0101e35:	f0 
f0101e36:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0101e3d:	f0 
f0101e3e:	c7 44 24 04 b6 03 00 	movl   $0x3b6,0x4(%esp)
f0101e45:	00 
f0101e46:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101e4d:	e8 ee e1 ff ff       	call   f0100040 <_panic>
  assert(pp1->pp_ref == 1);
f0101e52:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e57:	74 24                	je     f0101e7d <mem_init+0x968>
f0101e59:	c7 44 24 0c 68 77 10 	movl   $0xf0107768,0xc(%esp)
f0101e60:	f0 
f0101e61:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0101e68:	f0 
f0101e69:	c7 44 24 04 b7 03 00 	movl   $0x3b7,0x4(%esp)
f0101e70:	00 
f0101e71:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101e78:	e8 c3 e1 ff ff       	call   f0100040 <_panic>
  assert(pp0->pp_ref == 1);
f0101e7d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e80:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101e85:	74 24                	je     f0101eab <mem_init+0x996>
f0101e87:	c7 44 24 0c 79 77 10 	movl   $0xf0107779,0xc(%esp)
f0101e8e:	f0 
f0101e8f:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0101e96:	f0 
f0101e97:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0101e9e:	00 
f0101e9f:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101ea6:	e8 95 e1 ff ff       	call   f0100040 <_panic>

  // should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
  assert(page_insert(kern_pgdir, pp2, (void*)PGSIZE, PTE_W) == 0);
f0101eab:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101eb2:	00 
f0101eb3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101eba:	00 
f0101ebb:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101ebf:	89 3c 24             	mov    %edi,(%esp)
f0101ec2:	e8 51 f5 ff ff       	call   f0101418 <page_insert>
f0101ec7:	85 c0                	test   %eax,%eax
f0101ec9:	74 24                	je     f0101eef <mem_init+0x9da>
f0101ecb:	c7 44 24 0c 1c 7b 10 	movl   $0xf0107b1c,0xc(%esp)
f0101ed2:	f0 
f0101ed3:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0101eda:	f0 
f0101edb:	c7 44 24 04 bb 03 00 	movl   $0x3bb,0x4(%esp)
f0101ee2:	00 
f0101ee3:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101eea:	e8 51 e1 ff ff       	call   f0100040 <_panic>
  assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101eef:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ef4:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0101ef9:	e8 e4 ec ff ff       	call   f0100be2 <check_va2pa>
f0101efe:	89 f2                	mov    %esi,%edx
f0101f00:	2b 15 90 ce 20 f0    	sub    0xf020ce90,%edx
f0101f06:	c1 fa 03             	sar    $0x3,%edx
f0101f09:	c1 e2 0c             	shl    $0xc,%edx
f0101f0c:	39 d0                	cmp    %edx,%eax
f0101f0e:	74 24                	je     f0101f34 <mem_init+0xa1f>
f0101f10:	c7 44 24 0c 54 7b 10 	movl   $0xf0107b54,0xc(%esp)
f0101f17:	f0 
f0101f18:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0101f1f:	f0 
f0101f20:	c7 44 24 04 bc 03 00 	movl   $0x3bc,0x4(%esp)
f0101f27:	00 
f0101f28:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101f2f:	e8 0c e1 ff ff       	call   f0100040 <_panic>
  assert(pp2->pp_ref == 1);
f0101f34:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f39:	74 24                	je     f0101f5f <mem_init+0xa4a>
f0101f3b:	c7 44 24 0c 8a 77 10 	movl   $0xf010778a,0xc(%esp)
f0101f42:	f0 
f0101f43:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0101f4a:	f0 
f0101f4b:	c7 44 24 04 bd 03 00 	movl   $0x3bd,0x4(%esp)
f0101f52:	00 
f0101f53:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101f5a:	e8 e1 e0 ff ff       	call   f0100040 <_panic>

  // should be no free memory
  assert(!page_alloc(0));
f0101f5f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f66:	e8 4b f1 ff ff       	call   f01010b6 <page_alloc>
f0101f6b:	85 c0                	test   %eax,%eax
f0101f6d:	74 24                	je     f0101f93 <mem_init+0xa7e>
f0101f6f:	c7 44 24 0c 16 77 10 	movl   $0xf0107716,0xc(%esp)
f0101f76:	f0 
f0101f77:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0101f7e:	f0 
f0101f7f:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0101f86:	00 
f0101f87:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101f8e:	e8 ad e0 ff ff       	call   f0100040 <_panic>

  // should be able to map pp2 at PGSIZE because it's already there
  assert(page_insert(kern_pgdir, pp2, (void*)PGSIZE, PTE_W) == 0);
f0101f93:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f9a:	00 
f0101f9b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101fa2:	00 
f0101fa3:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101fa7:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0101fac:	89 04 24             	mov    %eax,(%esp)
f0101faf:	e8 64 f4 ff ff       	call   f0101418 <page_insert>
f0101fb4:	85 c0                	test   %eax,%eax
f0101fb6:	74 24                	je     f0101fdc <mem_init+0xac7>
f0101fb8:	c7 44 24 0c 1c 7b 10 	movl   $0xf0107b1c,0xc(%esp)
f0101fbf:	f0 
f0101fc0:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0101fc7:	f0 
f0101fc8:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f0101fcf:	00 
f0101fd0:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0101fd7:	e8 64 e0 ff ff       	call   f0100040 <_panic>
  assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101fdc:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fe1:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0101fe6:	e8 f7 eb ff ff       	call   f0100be2 <check_va2pa>
f0101feb:	89 f2                	mov    %esi,%edx
f0101fed:	2b 15 90 ce 20 f0    	sub    0xf020ce90,%edx
f0101ff3:	c1 fa 03             	sar    $0x3,%edx
f0101ff6:	c1 e2 0c             	shl    $0xc,%edx
f0101ff9:	39 d0                	cmp    %edx,%eax
f0101ffb:	74 24                	je     f0102021 <mem_init+0xb0c>
f0101ffd:	c7 44 24 0c 54 7b 10 	movl   $0xf0107b54,0xc(%esp)
f0102004:	f0 
f0102005:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f010200c:	f0 
f010200d:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f0102014:	00 
f0102015:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f010201c:	e8 1f e0 ff ff       	call   f0100040 <_panic>
  assert(pp2->pp_ref == 1);
f0102021:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102026:	74 24                	je     f010204c <mem_init+0xb37>
f0102028:	c7 44 24 0c 8a 77 10 	movl   $0xf010778a,0xc(%esp)
f010202f:	f0 
f0102030:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0102037:	f0 
f0102038:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f010203f:	00 
f0102040:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102047:	e8 f4 df ff ff       	call   f0100040 <_panic>

  // pp2 should NOT be on the free list
  // could happen in ref counts are handled sloppily in page_insert
  assert(!page_alloc(0));
f010204c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102053:	e8 5e f0 ff ff       	call   f01010b6 <page_alloc>
f0102058:	85 c0                	test   %eax,%eax
f010205a:	74 24                	je     f0102080 <mem_init+0xb6b>
f010205c:	c7 44 24 0c 16 77 10 	movl   $0xf0107716,0xc(%esp)
f0102063:	f0 
f0102064:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f010206b:	f0 
f010206c:	c7 44 24 04 c9 03 00 	movl   $0x3c9,0x4(%esp)
f0102073:	00 
f0102074:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f010207b:	e8 c0 df ff ff       	call   f0100040 <_panic>

  // check that pgdir_walk returns a pointer to the pte
  ptep = (pte_t*)KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0102080:	8b 15 8c ce 20 f0    	mov    0xf020ce8c,%edx
f0102086:	8b 02                	mov    (%edx),%eax
f0102088:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010208d:	89 c1                	mov    %eax,%ecx
f010208f:	c1 e9 0c             	shr    $0xc,%ecx
f0102092:	3b 0d 88 ce 20 f0    	cmp    0xf020ce88,%ecx
f0102098:	72 20                	jb     f01020ba <mem_init+0xba5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010209a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010209e:	c7 44 24 08 a4 6f 10 	movl   $0xf0106fa4,0x8(%esp)
f01020a5:	f0 
f01020a6:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f01020ad:	00 
f01020ae:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f01020b5:	e8 86 df ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01020ba:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01020bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01020c2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01020c9:	00 
f01020ca:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01020d1:	00 
f01020d2:	89 14 24             	mov    %edx,(%esp)
f01020d5:	e8 ee f0 ff ff       	call   f01011c8 <pgdir_walk>
f01020da:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01020dd:	8d 51 04             	lea    0x4(%ecx),%edx
f01020e0:	39 d0                	cmp    %edx,%eax
f01020e2:	74 24                	je     f0102108 <mem_init+0xbf3>
f01020e4:	c7 44 24 0c 84 7b 10 	movl   $0xf0107b84,0xc(%esp)
f01020eb:	f0 
f01020ec:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f01020f3:	f0 
f01020f4:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f01020fb:	00 
f01020fc:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102103:	e8 38 df ff ff       	call   f0100040 <_panic>

  // should be able to change permissions too.
  assert(page_insert(kern_pgdir, pp2, (void*)PGSIZE, PTE_W|PTE_U) == 0);
f0102108:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010210f:	00 
f0102110:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102117:	00 
f0102118:	89 74 24 04          	mov    %esi,0x4(%esp)
f010211c:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0102121:	89 04 24             	mov    %eax,(%esp)
f0102124:	e8 ef f2 ff ff       	call   f0101418 <page_insert>
f0102129:	85 c0                	test   %eax,%eax
f010212b:	74 24                	je     f0102151 <mem_init+0xc3c>
f010212d:	c7 44 24 0c c4 7b 10 	movl   $0xf0107bc4,0xc(%esp)
f0102134:	f0 
f0102135:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f010213c:	f0 
f010213d:	c7 44 24 04 d0 03 00 	movl   $0x3d0,0x4(%esp)
f0102144:	00 
f0102145:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f010214c:	e8 ef de ff ff       	call   f0100040 <_panic>
  assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102151:	8b 3d 8c ce 20 f0    	mov    0xf020ce8c,%edi
f0102157:	ba 00 10 00 00       	mov    $0x1000,%edx
f010215c:	89 f8                	mov    %edi,%eax
f010215e:	e8 7f ea ff ff       	call   f0100be2 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102163:	89 f2                	mov    %esi,%edx
f0102165:	2b 15 90 ce 20 f0    	sub    0xf020ce90,%edx
f010216b:	c1 fa 03             	sar    $0x3,%edx
f010216e:	c1 e2 0c             	shl    $0xc,%edx
f0102171:	39 d0                	cmp    %edx,%eax
f0102173:	74 24                	je     f0102199 <mem_init+0xc84>
f0102175:	c7 44 24 0c 54 7b 10 	movl   $0xf0107b54,0xc(%esp)
f010217c:	f0 
f010217d:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0102184:	f0 
f0102185:	c7 44 24 04 d1 03 00 	movl   $0x3d1,0x4(%esp)
f010218c:	00 
f010218d:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102194:	e8 a7 de ff ff       	call   f0100040 <_panic>
  assert(pp2->pp_ref == 1);
f0102199:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010219e:	74 24                	je     f01021c4 <mem_init+0xcaf>
f01021a0:	c7 44 24 0c 8a 77 10 	movl   $0xf010778a,0xc(%esp)
f01021a7:	f0 
f01021a8:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f01021af:	f0 
f01021b0:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f01021b7:	00 
f01021b8:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f01021bf:	e8 7c de ff ff       	call   f0100040 <_panic>
  assert(*pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) & PTE_U);
f01021c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01021cb:	00 
f01021cc:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01021d3:	00 
f01021d4:	89 3c 24             	mov    %edi,(%esp)
f01021d7:	e8 ec ef ff ff       	call   f01011c8 <pgdir_walk>
f01021dc:	f6 00 04             	testb  $0x4,(%eax)
f01021df:	75 24                	jne    f0102205 <mem_init+0xcf0>
f01021e1:	c7 44 24 0c 04 7c 10 	movl   $0xf0107c04,0xc(%esp)
f01021e8:	f0 
f01021e9:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f01021f0:	f0 
f01021f1:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f01021f8:	00 
f01021f9:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102200:	e8 3b de ff ff       	call   f0100040 <_panic>
  assert(kern_pgdir[0] & PTE_U);
f0102205:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f010220a:	f6 00 04             	testb  $0x4,(%eax)
f010220d:	75 24                	jne    f0102233 <mem_init+0xd1e>
f010220f:	c7 44 24 0c 9b 77 10 	movl   $0xf010779b,0xc(%esp)
f0102216:	f0 
f0102217:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f010221e:	f0 
f010221f:	c7 44 24 04 d4 03 00 	movl   $0x3d4,0x4(%esp)
f0102226:	00 
f0102227:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f010222e:	e8 0d de ff ff       	call   f0100040 <_panic>

  // should be able to remap with fewer permissions
  assert(page_insert(kern_pgdir, pp2, (void*)PGSIZE, PTE_W) == 0);
f0102233:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010223a:	00 
f010223b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102242:	00 
f0102243:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102247:	89 04 24             	mov    %eax,(%esp)
f010224a:	e8 c9 f1 ff ff       	call   f0101418 <page_insert>
f010224f:	85 c0                	test   %eax,%eax
f0102251:	74 24                	je     f0102277 <mem_init+0xd62>
f0102253:	c7 44 24 0c 1c 7b 10 	movl   $0xf0107b1c,0xc(%esp)
f010225a:	f0 
f010225b:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0102262:	f0 
f0102263:	c7 44 24 04 d7 03 00 	movl   $0x3d7,0x4(%esp)
f010226a:	00 
f010226b:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102272:	e8 c9 dd ff ff       	call   f0100040 <_panic>
  assert(*pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) & PTE_W);
f0102277:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010227e:	00 
f010227f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102286:	00 
f0102287:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f010228c:	89 04 24             	mov    %eax,(%esp)
f010228f:	e8 34 ef ff ff       	call   f01011c8 <pgdir_walk>
f0102294:	f6 00 02             	testb  $0x2,(%eax)
f0102297:	75 24                	jne    f01022bd <mem_init+0xda8>
f0102299:	c7 44 24 0c 38 7c 10 	movl   $0xf0107c38,0xc(%esp)
f01022a0:	f0 
f01022a1:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f01022a8:	f0 
f01022a9:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f01022b0:	00 
f01022b1:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f01022b8:	e8 83 dd ff ff       	call   f0100040 <_panic>
  assert(!(*pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) & PTE_U));
f01022bd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01022c4:	00 
f01022c5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01022cc:	00 
f01022cd:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f01022d2:	89 04 24             	mov    %eax,(%esp)
f01022d5:	e8 ee ee ff ff       	call   f01011c8 <pgdir_walk>
f01022da:	f6 00 04             	testb  $0x4,(%eax)
f01022dd:	74 24                	je     f0102303 <mem_init+0xdee>
f01022df:	c7 44 24 0c 6c 7c 10 	movl   $0xf0107c6c,0xc(%esp)
f01022e6:	f0 
f01022e7:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f01022ee:	f0 
f01022ef:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f01022f6:	00 
f01022f7:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f01022fe:	e8 3d dd ff ff       	call   f0100040 <_panic>

  // should not be able to map at PTSIZE because need free page for page table
  assert(page_insert(kern_pgdir, pp0, (void*)PTSIZE, PTE_W) < 0);
f0102303:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010230a:	00 
f010230b:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0102312:	00 
f0102313:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102316:	89 44 24 04          	mov    %eax,0x4(%esp)
f010231a:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f010231f:	89 04 24             	mov    %eax,(%esp)
f0102322:	e8 f1 f0 ff ff       	call   f0101418 <page_insert>
f0102327:	85 c0                	test   %eax,%eax
f0102329:	78 24                	js     f010234f <mem_init+0xe3a>
f010232b:	c7 44 24 0c a4 7c 10 	movl   $0xf0107ca4,0xc(%esp)
f0102332:	f0 
f0102333:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f010233a:	f0 
f010233b:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f0102342:	00 
f0102343:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f010234a:	e8 f1 dc ff ff       	call   f0100040 <_panic>

  // insert pp1 at PGSIZE (replacing pp2)
  assert(page_insert(kern_pgdir, pp1, (void*)PGSIZE, PTE_W) == 0);
f010234f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102356:	00 
f0102357:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010235e:	00 
f010235f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102363:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0102368:	89 04 24             	mov    %eax,(%esp)
f010236b:	e8 a8 f0 ff ff       	call   f0101418 <page_insert>
f0102370:	85 c0                	test   %eax,%eax
f0102372:	74 24                	je     f0102398 <mem_init+0xe83>
f0102374:	c7 44 24 0c dc 7c 10 	movl   $0xf0107cdc,0xc(%esp)
f010237b:	f0 
f010237c:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0102383:	f0 
f0102384:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f010238b:	00 
f010238c:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102393:	e8 a8 dc ff ff       	call   f0100040 <_panic>
  assert(!(*pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) & PTE_U));
f0102398:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010239f:	00 
f01023a0:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01023a7:	00 
f01023a8:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f01023ad:	89 04 24             	mov    %eax,(%esp)
f01023b0:	e8 13 ee ff ff       	call   f01011c8 <pgdir_walk>
f01023b5:	f6 00 04             	testb  $0x4,(%eax)
f01023b8:	74 24                	je     f01023de <mem_init+0xec9>
f01023ba:	c7 44 24 0c 6c 7c 10 	movl   $0xf0107c6c,0xc(%esp)
f01023c1:	f0 
f01023c2:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f01023c9:	f0 
f01023ca:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f01023d1:	00 
f01023d2:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f01023d9:	e8 62 dc ff ff       	call   f0100040 <_panic>

  // should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
  assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01023de:	8b 3d 8c ce 20 f0    	mov    0xf020ce8c,%edi
f01023e4:	ba 00 00 00 00       	mov    $0x0,%edx
f01023e9:	89 f8                	mov    %edi,%eax
f01023eb:	e8 f2 e7 ff ff       	call   f0100be2 <check_va2pa>
f01023f0:	89 c1                	mov    %eax,%ecx
f01023f2:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01023f5:	89 d8                	mov    %ebx,%eax
f01023f7:	2b 05 90 ce 20 f0    	sub    0xf020ce90,%eax
f01023fd:	c1 f8 03             	sar    $0x3,%eax
f0102400:	c1 e0 0c             	shl    $0xc,%eax
f0102403:	39 c1                	cmp    %eax,%ecx
f0102405:	74 24                	je     f010242b <mem_init+0xf16>
f0102407:	c7 44 24 0c 14 7d 10 	movl   $0xf0107d14,0xc(%esp)
f010240e:	f0 
f010240f:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0102416:	f0 
f0102417:	c7 44 24 04 e3 03 00 	movl   $0x3e3,0x4(%esp)
f010241e:	00 
f010241f:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102426:	e8 15 dc ff ff       	call   f0100040 <_panic>
  assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010242b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102430:	89 f8                	mov    %edi,%eax
f0102432:	e8 ab e7 ff ff       	call   f0100be2 <check_va2pa>
f0102437:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f010243a:	74 24                	je     f0102460 <mem_init+0xf4b>
f010243c:	c7 44 24 0c 40 7d 10 	movl   $0xf0107d40,0xc(%esp)
f0102443:	f0 
f0102444:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f010244b:	f0 
f010244c:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f0102453:	00 
f0102454:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f010245b:	e8 e0 db ff ff       	call   f0100040 <_panic>
  // ... and ref counts should reflect this
  assert(pp1->pp_ref == 2);
f0102460:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0102465:	74 24                	je     f010248b <mem_init+0xf76>
f0102467:	c7 44 24 0c b1 77 10 	movl   $0xf01077b1,0xc(%esp)
f010246e:	f0 
f010246f:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0102476:	f0 
f0102477:	c7 44 24 04 e6 03 00 	movl   $0x3e6,0x4(%esp)
f010247e:	00 
f010247f:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102486:	e8 b5 db ff ff       	call   f0100040 <_panic>
  assert(pp2->pp_ref == 0);
f010248b:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102490:	74 24                	je     f01024b6 <mem_init+0xfa1>
f0102492:	c7 44 24 0c c2 77 10 	movl   $0xf01077c2,0xc(%esp)
f0102499:	f0 
f010249a:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f01024a1:	f0 
f01024a2:	c7 44 24 04 e7 03 00 	movl   $0x3e7,0x4(%esp)
f01024a9:	00 
f01024aa:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f01024b1:	e8 8a db ff ff       	call   f0100040 <_panic>

  // pp2 should be returned by page_alloc
  assert((pp = page_alloc(0)) && pp == pp2);
f01024b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01024bd:	e8 f4 eb ff ff       	call   f01010b6 <page_alloc>
f01024c2:	85 c0                	test   %eax,%eax
f01024c4:	74 04                	je     f01024ca <mem_init+0xfb5>
f01024c6:	39 c6                	cmp    %eax,%esi
f01024c8:	74 24                	je     f01024ee <mem_init+0xfd9>
f01024ca:	c7 44 24 0c 70 7d 10 	movl   $0xf0107d70,0xc(%esp)
f01024d1:	f0 
f01024d2:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f01024d9:	f0 
f01024da:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f01024e1:	00 
f01024e2:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f01024e9:	e8 52 db ff ff       	call   f0100040 <_panic>

  // unmapping pp1 at 0 should keep pp1 at PGSIZE
  page_remove(kern_pgdir, 0x0);
f01024ee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01024f5:	00 
f01024f6:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f01024fb:	89 04 24             	mov    %eax,(%esp)
f01024fe:	e8 cc ee ff ff       	call   f01013cf <page_remove>
  assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102503:	8b 3d 8c ce 20 f0    	mov    0xf020ce8c,%edi
f0102509:	ba 00 00 00 00       	mov    $0x0,%edx
f010250e:	89 f8                	mov    %edi,%eax
f0102510:	e8 cd e6 ff ff       	call   f0100be2 <check_va2pa>
f0102515:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102518:	74 24                	je     f010253e <mem_init+0x1029>
f010251a:	c7 44 24 0c 94 7d 10 	movl   $0xf0107d94,0xc(%esp)
f0102521:	f0 
f0102522:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0102529:	f0 
f010252a:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f0102531:	00 
f0102532:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102539:	e8 02 db ff ff       	call   f0100040 <_panic>
  assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010253e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102543:	89 f8                	mov    %edi,%eax
f0102545:	e8 98 e6 ff ff       	call   f0100be2 <check_va2pa>
f010254a:	89 da                	mov    %ebx,%edx
f010254c:	2b 15 90 ce 20 f0    	sub    0xf020ce90,%edx
f0102552:	c1 fa 03             	sar    $0x3,%edx
f0102555:	c1 e2 0c             	shl    $0xc,%edx
f0102558:	39 d0                	cmp    %edx,%eax
f010255a:	74 24                	je     f0102580 <mem_init+0x106b>
f010255c:	c7 44 24 0c 40 7d 10 	movl   $0xf0107d40,0xc(%esp)
f0102563:	f0 
f0102564:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f010256b:	f0 
f010256c:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f0102573:	00 
f0102574:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f010257b:	e8 c0 da ff ff       	call   f0100040 <_panic>
  assert(pp1->pp_ref == 1);
f0102580:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102585:	74 24                	je     f01025ab <mem_init+0x1096>
f0102587:	c7 44 24 0c 68 77 10 	movl   $0xf0107768,0xc(%esp)
f010258e:	f0 
f010258f:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0102596:	f0 
f0102597:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f010259e:	00 
f010259f:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f01025a6:	e8 95 da ff ff       	call   f0100040 <_panic>
  assert(pp2->pp_ref == 0);
f01025ab:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01025b0:	74 24                	je     f01025d6 <mem_init+0x10c1>
f01025b2:	c7 44 24 0c c2 77 10 	movl   $0xf01077c2,0xc(%esp)
f01025b9:	f0 
f01025ba:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f01025c1:	f0 
f01025c2:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f01025c9:	00 
f01025ca:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f01025d1:	e8 6a da ff ff       	call   f0100040 <_panic>

  // test re-inserting pp1 at PGSIZE
  assert(page_insert(kern_pgdir, pp1, (void*)PGSIZE, 0) == 0);
f01025d6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01025dd:	00 
f01025de:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01025e5:	00 
f01025e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01025ea:	89 3c 24             	mov    %edi,(%esp)
f01025ed:	e8 26 ee ff ff       	call   f0101418 <page_insert>
f01025f2:	85 c0                	test   %eax,%eax
f01025f4:	74 24                	je     f010261a <mem_init+0x1105>
f01025f6:	c7 44 24 0c b8 7d 10 	movl   $0xf0107db8,0xc(%esp)
f01025fd:	f0 
f01025fe:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0102605:	f0 
f0102606:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f010260d:	00 
f010260e:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102615:	e8 26 da ff ff       	call   f0100040 <_panic>
  assert(pp1->pp_ref);
f010261a:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010261f:	75 24                	jne    f0102645 <mem_init+0x1130>
f0102621:	c7 44 24 0c d3 77 10 	movl   $0xf01077d3,0xc(%esp)
f0102628:	f0 
f0102629:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0102630:	f0 
f0102631:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f0102638:	00 
f0102639:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102640:	e8 fb d9 ff ff       	call   f0100040 <_panic>
  assert(pp1->pp_link == NULL);
f0102645:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102648:	74 24                	je     f010266e <mem_init+0x1159>
f010264a:	c7 44 24 0c df 77 10 	movl   $0xf01077df,0xc(%esp)
f0102651:	f0 
f0102652:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0102659:	f0 
f010265a:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f0102661:	00 
f0102662:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102669:	e8 d2 d9 ff ff       	call   f0100040 <_panic>

  // unmapping pp1 at PGSIZE should free it
  page_remove(kern_pgdir, (void*)PGSIZE);
f010266e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102675:	00 
f0102676:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f010267b:	89 04 24             	mov    %eax,(%esp)
f010267e:	e8 4c ed ff ff       	call   f01013cf <page_remove>
  assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102683:	8b 3d 8c ce 20 f0    	mov    0xf020ce8c,%edi
f0102689:	ba 00 00 00 00       	mov    $0x0,%edx
f010268e:	89 f8                	mov    %edi,%eax
f0102690:	e8 4d e5 ff ff       	call   f0100be2 <check_va2pa>
f0102695:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102698:	74 24                	je     f01026be <mem_init+0x11a9>
f010269a:	c7 44 24 0c 94 7d 10 	movl   $0xf0107d94,0xc(%esp)
f01026a1:	f0 
f01026a2:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f01026a9:	f0 
f01026aa:	c7 44 24 04 fa 03 00 	movl   $0x3fa,0x4(%esp)
f01026b1:	00 
f01026b2:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f01026b9:	e8 82 d9 ff ff       	call   f0100040 <_panic>
  assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01026be:	ba 00 10 00 00       	mov    $0x1000,%edx
f01026c3:	89 f8                	mov    %edi,%eax
f01026c5:	e8 18 e5 ff ff       	call   f0100be2 <check_va2pa>
f01026ca:	83 f8 ff             	cmp    $0xffffffff,%eax
f01026cd:	74 24                	je     f01026f3 <mem_init+0x11de>
f01026cf:	c7 44 24 0c ec 7d 10 	movl   $0xf0107dec,0xc(%esp)
f01026d6:	f0 
f01026d7:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f01026de:	f0 
f01026df:	c7 44 24 04 fb 03 00 	movl   $0x3fb,0x4(%esp)
f01026e6:	00 
f01026e7:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f01026ee:	e8 4d d9 ff ff       	call   f0100040 <_panic>
  assert(pp1->pp_ref == 0);
f01026f3:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01026f8:	74 24                	je     f010271e <mem_init+0x1209>
f01026fa:	c7 44 24 0c f4 77 10 	movl   $0xf01077f4,0xc(%esp)
f0102701:	f0 
f0102702:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0102709:	f0 
f010270a:	c7 44 24 04 fc 03 00 	movl   $0x3fc,0x4(%esp)
f0102711:	00 
f0102712:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102719:	e8 22 d9 ff ff       	call   f0100040 <_panic>
  assert(pp2->pp_ref == 0);
f010271e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102723:	74 24                	je     f0102749 <mem_init+0x1234>
f0102725:	c7 44 24 0c c2 77 10 	movl   $0xf01077c2,0xc(%esp)
f010272c:	f0 
f010272d:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0102734:	f0 
f0102735:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f010273c:	00 
f010273d:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102744:	e8 f7 d8 ff ff       	call   f0100040 <_panic>

  // so it should be returned by page_alloc
  assert((pp = page_alloc(0)) && pp == pp1);
f0102749:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102750:	e8 61 e9 ff ff       	call   f01010b6 <page_alloc>
f0102755:	85 c0                	test   %eax,%eax
f0102757:	74 04                	je     f010275d <mem_init+0x1248>
f0102759:	39 c3                	cmp    %eax,%ebx
f010275b:	74 24                	je     f0102781 <mem_init+0x126c>
f010275d:	c7 44 24 0c 14 7e 10 	movl   $0xf0107e14,0xc(%esp)
f0102764:	f0 
f0102765:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f010276c:	f0 
f010276d:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f0102774:	00 
f0102775:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f010277c:	e8 bf d8 ff ff       	call   f0100040 <_panic>

  // should be no free memory
  assert(!page_alloc(0));
f0102781:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102788:	e8 29 e9 ff ff       	call   f01010b6 <page_alloc>
f010278d:	85 c0                	test   %eax,%eax
f010278f:	74 24                	je     f01027b5 <mem_init+0x12a0>
f0102791:	c7 44 24 0c 16 77 10 	movl   $0xf0107716,0xc(%esp)
f0102798:	f0 
f0102799:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f01027a0:	f0 
f01027a1:	c7 44 24 04 03 04 00 	movl   $0x403,0x4(%esp)
f01027a8:	00 
f01027a9:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f01027b0:	e8 8b d8 ff ff       	call   f0100040 <_panic>

  // forcibly take pp0 back
  assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01027b5:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f01027ba:	8b 08                	mov    (%eax),%ecx
f01027bc:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01027c2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01027c5:	2b 15 90 ce 20 f0    	sub    0xf020ce90,%edx
f01027cb:	c1 fa 03             	sar    $0x3,%edx
f01027ce:	c1 e2 0c             	shl    $0xc,%edx
f01027d1:	39 d1                	cmp    %edx,%ecx
f01027d3:	74 24                	je     f01027f9 <mem_init+0x12e4>
f01027d5:	c7 44 24 0c c4 7a 10 	movl   $0xf0107ac4,0xc(%esp)
f01027dc:	f0 
f01027dd:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f01027e4:	f0 
f01027e5:	c7 44 24 04 06 04 00 	movl   $0x406,0x4(%esp)
f01027ec:	00 
f01027ed:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f01027f4:	e8 47 d8 ff ff       	call   f0100040 <_panic>
  kern_pgdir[0] = 0;
f01027f9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  assert(pp0->pp_ref == 1);
f01027ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102802:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102807:	74 24                	je     f010282d <mem_init+0x1318>
f0102809:	c7 44 24 0c 79 77 10 	movl   $0xf0107779,0xc(%esp)
f0102810:	f0 
f0102811:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0102818:	f0 
f0102819:	c7 44 24 04 08 04 00 	movl   $0x408,0x4(%esp)
f0102820:	00 
f0102821:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102828:	e8 13 d8 ff ff       	call   f0100040 <_panic>
  pp0->pp_ref = 0;
f010282d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102830:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

  // check pointer arithmetic in pgdir_walk
  page_free(pp0);
f0102836:	89 04 24             	mov    %eax,(%esp)
f0102839:	e8 27 e9 ff ff       	call   f0101165 <page_free>
  va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
  ptep = pgdir_walk(kern_pgdir, va, 1);
f010283e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102845:	00 
f0102846:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f010284d:	00 
f010284e:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0102853:	89 04 24             	mov    %eax,(%esp)
f0102856:	e8 6d e9 ff ff       	call   f01011c8 <pgdir_walk>
f010285b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010285e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  ptep1 = (pte_t*)KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102861:	8b 15 8c ce 20 f0    	mov    0xf020ce8c,%edx
f0102867:	8b 7a 04             	mov    0x4(%edx),%edi
f010286a:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102870:	8b 0d 88 ce 20 f0    	mov    0xf020ce88,%ecx
f0102876:	89 f8                	mov    %edi,%eax
f0102878:	c1 e8 0c             	shr    $0xc,%eax
f010287b:	39 c8                	cmp    %ecx,%eax
f010287d:	72 20                	jb     f010289f <mem_init+0x138a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010287f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0102883:	c7 44 24 08 a4 6f 10 	movl   $0xf0106fa4,0x8(%esp)
f010288a:	f0 
f010288b:	c7 44 24 04 0f 04 00 	movl   $0x40f,0x4(%esp)
f0102892:	00 
f0102893:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f010289a:	e8 a1 d7 ff ff       	call   f0100040 <_panic>
  assert(ptep == ptep1 + PTX(va));
f010289f:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f01028a5:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f01028a8:	74 24                	je     f01028ce <mem_init+0x13b9>
f01028aa:	c7 44 24 0c 05 78 10 	movl   $0xf0107805,0xc(%esp)
f01028b1:	f0 
f01028b2:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f01028b9:	f0 
f01028ba:	c7 44 24 04 10 04 00 	movl   $0x410,0x4(%esp)
f01028c1:	00 
f01028c2:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f01028c9:	e8 72 d7 ff ff       	call   f0100040 <_panic>
  kern_pgdir[PDX(va)] = 0;
f01028ce:	c7 42 04 00 00 00 00 	movl   $0x0,0x4(%edx)
  pp0->pp_ref = 0;
f01028d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01028d8:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01028de:	2b 05 90 ce 20 f0    	sub    0xf020ce90,%eax
f01028e4:	c1 f8 03             	sar    $0x3,%eax
f01028e7:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01028ea:	89 c2                	mov    %eax,%edx
f01028ec:	c1 ea 0c             	shr    $0xc,%edx
f01028ef:	39 d1                	cmp    %edx,%ecx
f01028f1:	77 20                	ja     f0102913 <mem_init+0x13fe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01028f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01028f7:	c7 44 24 08 a4 6f 10 	movl   $0xf0106fa4,0x8(%esp)
f01028fe:	f0 
f01028ff:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102906:	00 
f0102907:	c7 04 24 6b 75 10 f0 	movl   $0xf010756b,(%esp)
f010290e:	e8 2d d7 ff ff       	call   f0100040 <_panic>

  // check that new page tables get cleared
  memset(page2kva(pp0), 0xFF, PGSIZE);
f0102913:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010291a:	00 
f010291b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102922:	00 
	return (void *)(pa + KERNBASE);
f0102923:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102928:	89 04 24             	mov    %eax,(%esp)
f010292b:	e8 17 39 00 00       	call   f0106247 <memset>
  page_free(pp0);
f0102930:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102933:	89 3c 24             	mov    %edi,(%esp)
f0102936:	e8 2a e8 ff ff       	call   f0101165 <page_free>
  pgdir_walk(kern_pgdir, 0x0, 1);
f010293b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102942:	00 
f0102943:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010294a:	00 
f010294b:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0102950:	89 04 24             	mov    %eax,(%esp)
f0102953:	e8 70 e8 ff ff       	call   f01011c8 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102958:	89 fa                	mov    %edi,%edx
f010295a:	2b 15 90 ce 20 f0    	sub    0xf020ce90,%edx
f0102960:	c1 fa 03             	sar    $0x3,%edx
f0102963:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102966:	89 d0                	mov    %edx,%eax
f0102968:	c1 e8 0c             	shr    $0xc,%eax
f010296b:	3b 05 88 ce 20 f0    	cmp    0xf020ce88,%eax
f0102971:	72 20                	jb     f0102993 <mem_init+0x147e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102973:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102977:	c7 44 24 08 a4 6f 10 	movl   $0xf0106fa4,0x8(%esp)
f010297e:	f0 
f010297f:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102986:	00 
f0102987:	c7 04 24 6b 75 10 f0 	movl   $0xf010756b,(%esp)
f010298e:	e8 ad d6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102993:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
  ptep = (pte_t*)page2kva(pp0);
f0102999:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010299c:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
  for (i = 0; i < NPTENTRIES; i++)
    assert((ptep[i] & PTE_P) == 0);
f01029a2:	f6 00 01             	testb  $0x1,(%eax)
f01029a5:	74 24                	je     f01029cb <mem_init+0x14b6>
f01029a7:	c7 44 24 0c 1d 78 10 	movl   $0xf010781d,0xc(%esp)
f01029ae:	f0 
f01029af:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f01029b6:	f0 
f01029b7:	c7 44 24 04 1a 04 00 	movl   $0x41a,0x4(%esp)
f01029be:	00 
f01029bf:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f01029c6:	e8 75 d6 ff ff       	call   f0100040 <_panic>
f01029cb:	83 c0 04             	add    $0x4,%eax
  // check that new page tables get cleared
  memset(page2kva(pp0), 0xFF, PGSIZE);
  page_free(pp0);
  pgdir_walk(kern_pgdir, 0x0, 1);
  ptep = (pte_t*)page2kva(pp0);
  for (i = 0; i < NPTENTRIES; i++)
f01029ce:	39 d0                	cmp    %edx,%eax
f01029d0:	75 d0                	jne    f01029a2 <mem_init+0x148d>
    assert((ptep[i] & PTE_P) == 0);
  kern_pgdir[0] = 0;
f01029d2:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f01029d7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  pp0->pp_ref = 0;
f01029dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01029e0:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

  // give free list back
  page_free_list = fl;
f01029e6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01029e9:	89 0d 40 c2 20 f0    	mov    %ecx,0xf020c240

  // free the pages we took
  page_free(pp0);
f01029ef:	89 04 24             	mov    %eax,(%esp)
f01029f2:	e8 6e e7 ff ff       	call   f0101165 <page_free>
  page_free(pp1);
f01029f7:	89 1c 24             	mov    %ebx,(%esp)
f01029fa:	e8 66 e7 ff ff       	call   f0101165 <page_free>
  page_free(pp2);
f01029ff:	89 34 24             	mov    %esi,(%esp)
f0102a02:	e8 5e e7 ff ff       	call   f0101165 <page_free>

  // test mmio_map_region
  mm1 = (uintptr_t)mmio_map_region(0, 4097);
f0102a07:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0102a0e:	00 
f0102a0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a16:	e8 87 ea ff ff       	call   f01014a2 <mmio_map_region>
f0102a1b:	89 c3                	mov    %eax,%ebx
  mm2 = (uintptr_t)mmio_map_region(0, 4096);
f0102a1d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102a24:	00 
f0102a25:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a2c:	e8 71 ea ff ff       	call   f01014a2 <mmio_map_region>
f0102a31:	89 c6                	mov    %eax,%esi
  // check that they're in the right region
  assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102a33:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102a39:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102a3e:	77 08                	ja     f0102a48 <mem_init+0x1533>
f0102a40:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102a46:	77 24                	ja     f0102a6c <mem_init+0x1557>
f0102a48:	c7 44 24 0c 38 7e 10 	movl   $0xf0107e38,0xc(%esp)
f0102a4f:	f0 
f0102a50:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0102a57:	f0 
f0102a58:	c7 44 24 04 2a 04 00 	movl   $0x42a,0x4(%esp)
f0102a5f:	00 
f0102a60:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102a67:	e8 d4 d5 ff ff       	call   f0100040 <_panic>
  assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102a6c:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102a72:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102a78:	77 08                	ja     f0102a82 <mem_init+0x156d>
f0102a7a:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102a80:	77 24                	ja     f0102aa6 <mem_init+0x1591>
f0102a82:	c7 44 24 0c 60 7e 10 	movl   $0xf0107e60,0xc(%esp)
f0102a89:	f0 
f0102a8a:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0102a91:	f0 
f0102a92:	c7 44 24 04 2b 04 00 	movl   $0x42b,0x4(%esp)
f0102a99:	00 
f0102a9a:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102aa1:	e8 9a d5 ff ff       	call   f0100040 <_panic>
f0102aa6:	89 da                	mov    %ebx,%edx
f0102aa8:	09 f2                	or     %esi,%edx
  // check that they're page-aligned
  assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102aaa:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102ab0:	74 24                	je     f0102ad6 <mem_init+0x15c1>
f0102ab2:	c7 44 24 0c 88 7e 10 	movl   $0xf0107e88,0xc(%esp)
f0102ab9:	f0 
f0102aba:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0102ac1:	f0 
f0102ac2:	c7 44 24 04 2d 04 00 	movl   $0x42d,0x4(%esp)
f0102ac9:	00 
f0102aca:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102ad1:	e8 6a d5 ff ff       	call   f0100040 <_panic>
  // check that they don't overlap
  assert(mm1 + 8096 <= mm2);
f0102ad6:	39 c6                	cmp    %eax,%esi
f0102ad8:	73 24                	jae    f0102afe <mem_init+0x15e9>
f0102ada:	c7 44 24 0c 34 78 10 	movl   $0xf0107834,0xc(%esp)
f0102ae1:	f0 
f0102ae2:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0102ae9:	f0 
f0102aea:	c7 44 24 04 2f 04 00 	movl   $0x42f,0x4(%esp)
f0102af1:	00 
f0102af2:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102af9:	e8 42 d5 ff ff       	call   f0100040 <_panic>
  // check page mappings
  assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102afe:	8b 3d 8c ce 20 f0    	mov    0xf020ce8c,%edi
f0102b04:	89 da                	mov    %ebx,%edx
f0102b06:	89 f8                	mov    %edi,%eax
f0102b08:	e8 d5 e0 ff ff       	call   f0100be2 <check_va2pa>
f0102b0d:	85 c0                	test   %eax,%eax
f0102b0f:	74 24                	je     f0102b35 <mem_init+0x1620>
f0102b11:	c7 44 24 0c b0 7e 10 	movl   $0xf0107eb0,0xc(%esp)
f0102b18:	f0 
f0102b19:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0102b20:	f0 
f0102b21:	c7 44 24 04 31 04 00 	movl   $0x431,0x4(%esp)
f0102b28:	00 
f0102b29:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102b30:	e8 0b d5 ff ff       	call   f0100040 <_panic>
  assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102b35:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102b3b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102b3e:	89 c2                	mov    %eax,%edx
f0102b40:	89 f8                	mov    %edi,%eax
f0102b42:	e8 9b e0 ff ff       	call   f0100be2 <check_va2pa>
f0102b47:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102b4c:	74 24                	je     f0102b72 <mem_init+0x165d>
f0102b4e:	c7 44 24 0c d4 7e 10 	movl   $0xf0107ed4,0xc(%esp)
f0102b55:	f0 
f0102b56:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0102b5d:	f0 
f0102b5e:	c7 44 24 04 32 04 00 	movl   $0x432,0x4(%esp)
f0102b65:	00 
f0102b66:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102b6d:	e8 ce d4 ff ff       	call   f0100040 <_panic>
  assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102b72:	89 f2                	mov    %esi,%edx
f0102b74:	89 f8                	mov    %edi,%eax
f0102b76:	e8 67 e0 ff ff       	call   f0100be2 <check_va2pa>
f0102b7b:	85 c0                	test   %eax,%eax
f0102b7d:	74 24                	je     f0102ba3 <mem_init+0x168e>
f0102b7f:	c7 44 24 0c 04 7f 10 	movl   $0xf0107f04,0xc(%esp)
f0102b86:	f0 
f0102b87:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0102b8e:	f0 
f0102b8f:	c7 44 24 04 33 04 00 	movl   $0x433,0x4(%esp)
f0102b96:	00 
f0102b97:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102b9e:	e8 9d d4 ff ff       	call   f0100040 <_panic>
  assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102ba3:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102ba9:	89 f8                	mov    %edi,%eax
f0102bab:	e8 32 e0 ff ff       	call   f0100be2 <check_va2pa>
f0102bb0:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102bb3:	74 24                	je     f0102bd9 <mem_init+0x16c4>
f0102bb5:	c7 44 24 0c 28 7f 10 	movl   $0xf0107f28,0xc(%esp)
f0102bbc:	f0 
f0102bbd:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0102bc4:	f0 
f0102bc5:	c7 44 24 04 34 04 00 	movl   $0x434,0x4(%esp)
f0102bcc:	00 
f0102bcd:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102bd4:	e8 67 d4 ff ff       	call   f0100040 <_panic>
  // check permissions
  assert(*pgdir_walk(kern_pgdir, (void*)mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102bd9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102be0:	00 
f0102be1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102be5:	89 3c 24             	mov    %edi,(%esp)
f0102be8:	e8 db e5 ff ff       	call   f01011c8 <pgdir_walk>
f0102bed:	f6 00 1a             	testb  $0x1a,(%eax)
f0102bf0:	75 24                	jne    f0102c16 <mem_init+0x1701>
f0102bf2:	c7 44 24 0c 54 7f 10 	movl   $0xf0107f54,0xc(%esp)
f0102bf9:	f0 
f0102bfa:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0102c01:	f0 
f0102c02:	c7 44 24 04 36 04 00 	movl   $0x436,0x4(%esp)
f0102c09:	00 
f0102c0a:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102c11:	e8 2a d4 ff ff       	call   f0100040 <_panic>
  assert(!(*pgdir_walk(kern_pgdir, (void*)mm1, 0) & PTE_U));
f0102c16:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102c1d:	00 
f0102c1e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102c22:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0102c27:	89 04 24             	mov    %eax,(%esp)
f0102c2a:	e8 99 e5 ff ff       	call   f01011c8 <pgdir_walk>
f0102c2f:	f6 00 04             	testb  $0x4,(%eax)
f0102c32:	74 24                	je     f0102c58 <mem_init+0x1743>
f0102c34:	c7 44 24 0c 98 7f 10 	movl   $0xf0107f98,0xc(%esp)
f0102c3b:	f0 
f0102c3c:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0102c43:	f0 
f0102c44:	c7 44 24 04 37 04 00 	movl   $0x437,0x4(%esp)
f0102c4b:	00 
f0102c4c:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102c53:	e8 e8 d3 ff ff       	call   f0100040 <_panic>
  // clear the mappings
  *pgdir_walk(kern_pgdir, (void*)mm1, 0) = 0;
f0102c58:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102c5f:	00 
f0102c60:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102c64:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0102c69:	89 04 24             	mov    %eax,(%esp)
f0102c6c:	e8 57 e5 ff ff       	call   f01011c8 <pgdir_walk>
f0102c71:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *pgdir_walk(kern_pgdir, (void*)mm1 + PGSIZE, 0) = 0;
f0102c77:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102c7e:	00 
f0102c7f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c82:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102c86:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0102c8b:	89 04 24             	mov    %eax,(%esp)
f0102c8e:	e8 35 e5 ff ff       	call   f01011c8 <pgdir_walk>
f0102c93:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *pgdir_walk(kern_pgdir, (void*)mm2, 0) = 0;
f0102c99:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102ca0:	00 
f0102ca1:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102ca5:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0102caa:	89 04 24             	mov    %eax,(%esp)
f0102cad:	e8 16 e5 ff ff       	call   f01011c8 <pgdir_walk>
f0102cb2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  cprintf("check_page() succeeded!\n");
f0102cb8:	c7 04 24 46 78 10 f0 	movl   $0xf0107846,(%esp)
f0102cbf:	e8 ac 12 00 00       	call   f0103f70 <cprintf>
  // Permissions:
  //    - the new image at UPAGES -- kernel R, user R
  //      (ie. perm = PTE_U | PTE_P)
  //    - pages itself -- kernel RW, user NONE
  // Your code goes here:
  boot_map_region(kern_pgdir, UPAGES, npages * sizeof(struct PageInfo), PADDR(pages), PTE_U | PTE_P);
f0102cc4:	a1 90 ce 20 f0       	mov    0xf020ce90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102cc9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102cce:	77 20                	ja     f0102cf0 <mem_init+0x17db>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cd0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102cd4:	c7 44 24 08 c8 6f 10 	movl   $0xf0106fc8,0x8(%esp)
f0102cdb:	f0 
f0102cdc:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
f0102ce3:	00 
f0102ce4:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102ceb:	e8 50 d3 ff ff       	call   f0100040 <_panic>
f0102cf0:	8b 0d 88 ce 20 f0    	mov    0xf020ce88,%ecx
f0102cf6:	c1 e1 03             	shl    $0x3,%ecx
f0102cf9:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102d00:	00 
	return (physaddr_t)kva - KERNBASE;
f0102d01:	05 00 00 00 10       	add    $0x10000000,%eax
f0102d06:	89 04 24             	mov    %eax,(%esp)
f0102d09:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102d0e:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0102d13:	e8 95 e5 ff ff       	call   f01012ad <boot_map_region>
  // (ie. perm = PTE_U | PTE_P).
  // Permissions:
  //    - the new image at UENVS  -- kernel R, user R
  //    - envs itself -- kernel RW, user NONE
  // LAB 3: Your code here.
  boot_map_region(kern_pgdir, UENVS, NENV * sizeof(struct Env), PADDR(envs), PTE_U | PTE_P);
f0102d18:	a1 48 c2 20 f0       	mov    0xf020c248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d1d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d22:	77 20                	ja     f0102d44 <mem_init+0x182f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d24:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d28:	c7 44 24 08 c8 6f 10 	movl   $0xf0106fc8,0x8(%esp)
f0102d2f:	f0 
f0102d30:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
f0102d37:	00 
f0102d38:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102d3f:	e8 fc d2 ff ff       	call   f0100040 <_panic>
f0102d44:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102d4b:	00 
	return (physaddr_t)kva - KERNBASE;
f0102d4c:	05 00 00 00 10       	add    $0x10000000,%eax
f0102d51:	89 04 24             	mov    %eax,(%esp)
f0102d54:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102d59:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102d5e:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0102d63:	e8 45 e5 ff ff       	call   f01012ad <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d68:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f0102d6d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d72:	77 20                	ja     f0102d94 <mem_init+0x187f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d74:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d78:	c7 44 24 08 c8 6f 10 	movl   $0xf0106fc8,0x8(%esp)
f0102d7f:	f0 
f0102d80:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
f0102d87:	00 
f0102d88:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102d8f:	e8 ac d2 ff ff       	call   f0100040 <_panic>
  //     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
  //       the kernel overflows its stack, it will fault rather than
  //       overwrite memory.  Known as a "guard page".
  //     Permissions: kernel RW, user NONE
  // Your code goes here:
  boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102d94:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102d9b:	00 
f0102d9c:	c7 04 24 00 70 11 00 	movl   $0x117000,(%esp)
f0102da3:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102da8:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102dad:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0102db2:	e8 f6 e4 ff ff       	call   f01012ad <boot_map_region>
  //      the PA range [0, 2^32 - KERNBASE)
  // We might not have 2^32 - KERNBASE bytes of physical memory, but
  // we just set up the mapping anyway.
  // Permissions: kernel RW, user NONE
  // Your code goes here:
  boot_map_region(kern_pgdir, KERNBASE, 0xFFFFFFFF - KERNBASE + 1, 0, PTE_W);
f0102db7:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102dbe:	00 
f0102dbf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102dc6:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102dcb:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102dd0:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0102dd5:	e8 d3 e4 ff ff       	call   f01012ad <boot_map_region>
f0102dda:	bf 00 e0 24 f0       	mov    $0xf024e000,%edi
f0102ddf:	bb 00 e0 20 f0       	mov    $0xf020e000,%ebx
f0102de4:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102de9:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102def:	77 20                	ja     f0102e11 <mem_init+0x18fc>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102df1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102df5:	c7 44 24 08 c8 6f 10 	movl   $0xf0106fc8,0x8(%esp)
f0102dfc:	f0 
f0102dfd:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
f0102e04:	00 
f0102e05:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102e0c:	e8 2f d2 ff ff       	call   f0100040 <_panic>
  //
  // LAB 4: Your code here:
  int i;
  for (i = 0; i < NCPU; i++) {
    uintptr_t kstacktop = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
    boot_map_region(kern_pgdir,
f0102e11:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102e18:	00 
f0102e19:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102e1f:	89 04 24             	mov    %eax,(%esp)
f0102e22:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102e27:	89 f2                	mov    %esi,%edx
f0102e29:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0102e2e:	e8 7a e4 ff ff       	call   f01012ad <boot_map_region>
f0102e33:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102e39:	81 ee 00 00 01 00    	sub    $0x10000,%esi
  //             Known as a "guard page".
  //     Permissions: kernel RW, user NONE
  //
  // LAB 4: Your code here:
  int i;
  for (i = 0; i < NCPU; i++) {
f0102e3f:	39 fb                	cmp    %edi,%ebx
f0102e41:	75 a6                	jne    f0102de9 <mem_init+0x18d4>
check_kern_pgdir(void)
{
  uint32_t i, n;
  pde_t *pgdir;

  pgdir = kern_pgdir;
f0102e43:	8b 3d 8c ce 20 f0    	mov    0xf020ce8c,%edi

  // check pages array
  n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102e49:	a1 88 ce 20 f0       	mov    0xf020ce88,%eax
f0102e4e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102e51:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102e58:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102e5d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for (i = 0; i < n; i += PGSIZE)
    assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102e60:	8b 35 90 ce 20 f0    	mov    0xf020ce90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e66:	89 75 cc             	mov    %esi,-0x34(%ebp)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0102e69:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0102e6f:	89 45 c8             	mov    %eax,-0x38(%ebp)

  pgdir = kern_pgdir;

  // check pages array
  n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
  for (i = 0; i < n; i += PGSIZE)
f0102e72:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102e77:	eb 6a                	jmp    f0102ee3 <mem_init+0x19ce>
f0102e79:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
    assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102e7f:	89 f8                	mov    %edi,%eax
f0102e81:	e8 5c dd ff ff       	call   f0100be2 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e86:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102e8d:	77 20                	ja     f0102eaf <mem_init+0x199a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e8f:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102e93:	c7 44 24 08 c8 6f 10 	movl   $0xf0106fc8,0x8(%esp)
f0102e9a:	f0 
f0102e9b:	c7 44 24 04 4e 03 00 	movl   $0x34e,0x4(%esp)
f0102ea2:	00 
f0102ea3:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102eaa:	e8 91 d1 ff ff       	call   f0100040 <_panic>
f0102eaf:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102eb2:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0102eb5:	39 d0                	cmp    %edx,%eax
f0102eb7:	74 24                	je     f0102edd <mem_init+0x19c8>
f0102eb9:	c7 44 24 0c cc 7f 10 	movl   $0xf0107fcc,0xc(%esp)
f0102ec0:	f0 
f0102ec1:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0102ec8:	f0 
f0102ec9:	c7 44 24 04 4e 03 00 	movl   $0x34e,0x4(%esp)
f0102ed0:	00 
f0102ed1:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102ed8:	e8 63 d1 ff ff       	call   f0100040 <_panic>

  pgdir = kern_pgdir;

  // check pages array
  n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
  for (i = 0; i < n; i += PGSIZE)
f0102edd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102ee3:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0102ee6:	77 91                	ja     f0102e79 <mem_init+0x1964>
    assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

  // check envs array (new test for lab 3)
  n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
  for (i = 0; i < n; i += PGSIZE)
    assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102ee8:	8b 1d 48 c2 20 f0    	mov    0xf020c248,%ebx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102eee:	89 de                	mov    %ebx,%esi
f0102ef0:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102ef5:	89 f8                	mov    %edi,%eax
f0102ef7:	e8 e6 dc ff ff       	call   f0100be2 <check_va2pa>
f0102efc:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102f02:	77 20                	ja     f0102f24 <mem_init+0x1a0f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f04:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102f08:	c7 44 24 08 c8 6f 10 	movl   $0xf0106fc8,0x8(%esp)
f0102f0f:	f0 
f0102f10:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f0102f17:	00 
f0102f18:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102f1f:	e8 1c d1 ff ff       	call   f0100040 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f24:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102f29:	81 c6 00 00 40 21    	add    $0x21400000,%esi
f0102f2f:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102f32:	39 d0                	cmp    %edx,%eax
f0102f34:	74 24                	je     f0102f5a <mem_init+0x1a45>
f0102f36:	c7 44 24 0c 00 80 10 	movl   $0xf0108000,0xc(%esp)
f0102f3d:	f0 
f0102f3e:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0102f45:	f0 
f0102f46:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f0102f4d:	00 
f0102f4e:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102f55:	e8 e6 d0 ff ff       	call   f0100040 <_panic>
f0102f5a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  for (i = 0; i < n; i += PGSIZE)
    assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

  // check envs array (new test for lab 3)
  n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
  for (i = 0; i < n; i += PGSIZE)
f0102f60:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102f66:	0f 85 a9 05 00 00    	jne    f0103515 <mem_init+0x2000>
    assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

  // check phys mem
  for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102f6c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102f6f:	c1 e6 0c             	shl    $0xc,%esi
f0102f72:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102f77:	eb 3b                	jmp    f0102fb4 <mem_init+0x1a9f>
f0102f79:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
    assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102f7f:	89 f8                	mov    %edi,%eax
f0102f81:	e8 5c dc ff ff       	call   f0100be2 <check_va2pa>
f0102f86:	39 c3                	cmp    %eax,%ebx
f0102f88:	74 24                	je     f0102fae <mem_init+0x1a99>
f0102f8a:	c7 44 24 0c 34 80 10 	movl   $0xf0108034,0xc(%esp)
f0102f91:	f0 
f0102f92:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0102f99:	f0 
f0102f9a:	c7 44 24 04 57 03 00 	movl   $0x357,0x4(%esp)
f0102fa1:	00 
f0102fa2:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0102fa9:	e8 92 d0 ff ff       	call   f0100040 <_panic>
  n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
  for (i = 0; i < n; i += PGSIZE)
    assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

  // check phys mem
  for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102fae:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102fb4:	39 f3                	cmp    %esi,%ebx
f0102fb6:	72 c1                	jb     f0102f79 <mem_init+0x1a64>
f0102fb8:	c7 45 d0 00 e0 20 f0 	movl   $0xf020e000,-0x30(%ebp)
f0102fbf:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0102fc6:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102fcb:	b8 00 e0 20 f0       	mov    $0xf020e000,%eax
f0102fd0:	05 00 80 00 20       	add    $0x20008000,%eax
f0102fd5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102fd8:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f0102fde:	89 45 cc             	mov    %eax,-0x34(%ebp)
  // check kernel stack
  // (updated in lab 4 to check per-CPU kernel stacks)
  for (n = 0; n < NCPU; n++) {
    uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
    for (i = 0; i < KSTKSIZE; i += PGSIZE)
      assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102fe1:	89 f2                	mov    %esi,%edx
f0102fe3:	89 f8                	mov    %edi,%eax
f0102fe5:	e8 f8 db ff ff       	call   f0100be2 <check_va2pa>
f0102fea:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102fed:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f0102ff3:	77 20                	ja     f0103015 <mem_init+0x1b00>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ff5:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102ff9:	c7 44 24 08 c8 6f 10 	movl   $0xf0106fc8,0x8(%esp)
f0103000:	f0 
f0103001:	c7 44 24 04 5f 03 00 	movl   $0x35f,0x4(%esp)
f0103008:	00 
f0103009:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0103010:	e8 2b d0 ff ff       	call   f0100040 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103015:	89 f3                	mov    %esi,%ebx
f0103017:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f010301a:	03 4d d4             	add    -0x2c(%ebp),%ecx
f010301d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0103020:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0103023:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0103026:	39 c2                	cmp    %eax,%edx
f0103028:	74 24                	je     f010304e <mem_init+0x1b39>
f010302a:	c7 44 24 0c 5c 80 10 	movl   $0xf010805c,0xc(%esp)
f0103031:	f0 
f0103032:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0103039:	f0 
f010303a:	c7 44 24 04 5f 03 00 	movl   $0x35f,0x4(%esp)
f0103041:	00 
f0103042:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0103049:	e8 f2 cf ff ff       	call   f0100040 <_panic>
f010304e:	81 c3 00 10 00 00    	add    $0x1000,%ebx

  // check kernel stack
  // (updated in lab 4 to check per-CPU kernel stacks)
  for (n = 0; n < NCPU; n++) {
    uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
    for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0103054:	3b 5d cc             	cmp    -0x34(%ebp),%ebx
f0103057:	0f 85 a9 04 00 00    	jne    f0103506 <mem_init+0x1ff1>
f010305d:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
      assert(check_va2pa(pgdir, base + KSTKGAP + i)
             == PADDR(percpu_kstacks[n]) + i);
    for (i = 0; i < KSTKGAP; i += PGSIZE)
      assert(check_va2pa(pgdir, base + i) == ~0);
f0103063:	89 da                	mov    %ebx,%edx
f0103065:	89 f8                	mov    %edi,%eax
f0103067:	e8 76 db ff ff       	call   f0100be2 <check_va2pa>
f010306c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010306f:	74 24                	je     f0103095 <mem_init+0x1b80>
f0103071:	c7 44 24 0c a4 80 10 	movl   $0xf01080a4,0xc(%esp)
f0103078:	f0 
f0103079:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0103080:	f0 
f0103081:	c7 44 24 04 61 03 00 	movl   $0x361,0x4(%esp)
f0103088:	00 
f0103089:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0103090:	e8 ab cf ff ff       	call   f0100040 <_panic>
f0103095:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  for (n = 0; n < NCPU; n++) {
    uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
    for (i = 0; i < KSTKSIZE; i += PGSIZE)
      assert(check_va2pa(pgdir, base + KSTKGAP + i)
             == PADDR(percpu_kstacks[n]) + i);
    for (i = 0; i < KSTKGAP; i += PGSIZE)
f010309b:	39 de                	cmp    %ebx,%esi
f010309d:	75 c4                	jne    f0103063 <mem_init+0x1b4e>
f010309f:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f01030a5:	81 45 d4 00 80 01 00 	addl   $0x18000,-0x2c(%ebp)
f01030ac:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
  for (i = 0; i < npages * PGSIZE; i += PGSIZE)
    assert(check_va2pa(pgdir, KERNBASE + i) == i);

  // check kernel stack
  // (updated in lab 4 to check per-CPU kernel stacks)
  for (n = 0; n < NCPU; n++) {
f01030b3:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f01030b9:	0f 85 19 ff ff ff    	jne    f0102fd8 <mem_init+0x1ac3>
f01030bf:	b8 00 00 00 00       	mov    $0x0,%eax
f01030c4:	e9 c2 00 00 00       	jmp    f010318b <mem_init+0x1c76>
      assert(check_va2pa(pgdir, base + i) == ~0);
  }

  // check PDE permissions
  for (i = 0; i < NPDENTRIES; i++) {
    switch (i) {
f01030c9:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f01030cf:	83 fa 04             	cmp    $0x4,%edx
f01030d2:	77 2e                	ja     f0103102 <mem_init+0x1bed>
    case PDX(UVPT):
    case PDX(KSTACKTOP-1):
    case PDX(UPAGES):
    case PDX(UENVS):
    case PDX(MMIOBASE):
      assert(pgdir[i] & PTE_P);
f01030d4:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f01030d8:	0f 85 aa 00 00 00    	jne    f0103188 <mem_init+0x1c73>
f01030de:	c7 44 24 0c 5f 78 10 	movl   $0xf010785f,0xc(%esp)
f01030e5:	f0 
f01030e6:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f01030ed:	f0 
f01030ee:	c7 44 24 04 6c 03 00 	movl   $0x36c,0x4(%esp)
f01030f5:	00 
f01030f6:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f01030fd:	e8 3e cf ff ff       	call   f0100040 <_panic>
      break;
    default:
      if (i >= PDX(KERNBASE)) {
f0103102:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0103107:	76 55                	jbe    f010315e <mem_init+0x1c49>
        assert(pgdir[i] & PTE_P);
f0103109:	8b 14 87             	mov    (%edi,%eax,4),%edx
f010310c:	f6 c2 01             	test   $0x1,%dl
f010310f:	75 24                	jne    f0103135 <mem_init+0x1c20>
f0103111:	c7 44 24 0c 5f 78 10 	movl   $0xf010785f,0xc(%esp)
f0103118:	f0 
f0103119:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0103120:	f0 
f0103121:	c7 44 24 04 70 03 00 	movl   $0x370,0x4(%esp)
f0103128:	00 
f0103129:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0103130:	e8 0b cf ff ff       	call   f0100040 <_panic>
        assert(pgdir[i] & PTE_W);
f0103135:	f6 c2 02             	test   $0x2,%dl
f0103138:	75 4e                	jne    f0103188 <mem_init+0x1c73>
f010313a:	c7 44 24 0c 70 78 10 	movl   $0xf0107870,0xc(%esp)
f0103141:	f0 
f0103142:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0103149:	f0 
f010314a:	c7 44 24 04 71 03 00 	movl   $0x371,0x4(%esp)
f0103151:	00 
f0103152:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0103159:	e8 e2 ce ff ff       	call   f0100040 <_panic>
      } else
        assert(pgdir[i] == 0);
f010315e:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0103162:	74 24                	je     f0103188 <mem_init+0x1c73>
f0103164:	c7 44 24 0c 81 78 10 	movl   $0xf0107881,0xc(%esp)
f010316b:	f0 
f010316c:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0103173:	f0 
f0103174:	c7 44 24 04 73 03 00 	movl   $0x373,0x4(%esp)
f010317b:	00 
f010317c:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0103183:	e8 b8 ce ff ff       	call   f0100040 <_panic>
    for (i = 0; i < KSTKGAP; i += PGSIZE)
      assert(check_va2pa(pgdir, base + i) == ~0);
  }

  // check PDE permissions
  for (i = 0; i < NPDENTRIES; i++) {
f0103188:	83 c0 01             	add    $0x1,%eax
f010318b:	3d 00 04 00 00       	cmp    $0x400,%eax
f0103190:	0f 85 33 ff ff ff    	jne    f01030c9 <mem_init+0x1bb4>
      } else
        assert(pgdir[i] == 0);
      break;
    }
  }
  cprintf("check_kern_pgdir() succeeded!\n");
f0103196:	c7 04 24 c8 80 10 f0 	movl   $0xf01080c8,(%esp)
f010319d:	e8 ce 0d 00 00       	call   f0103f70 <cprintf>
  // somewhere between KERNBASE and KERNBASE+4MB right now, which is
  // mapped the same way by both page tables.
  //
  // If the machine reboots at this point, you've probably set up your
  // kern_pgdir wrong.
  lcr3(PADDR(kern_pgdir));
f01031a2:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f01031a7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031ac:	77 20                	ja     f01031ce <mem_init+0x1cb9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01031b2:	c7 44 24 08 c8 6f 10 	movl   $0xf0106fc8,0x8(%esp)
f01031b9:	f0 
f01031ba:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
f01031c1:	00 
f01031c2:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f01031c9:	e8 72 ce ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01031ce:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
  __asm __volatile("movl %0,%%cr3" : : "r" (val));
f01031d3:	0f 22 d8             	mov    %eax,%cr3

  check_page_free_list(0);
f01031d6:	b8 00 00 00 00       	mov    $0x0,%eax
f01031db:	e8 71 da ff ff       	call   f0100c51 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
  uint32_t val;
  __asm __volatile("movl %%cr0,%0" : "=r" (val));
f01031e0:	0f 20 c0             	mov    %cr0,%eax

  // entry.S set the really important flags in cr0 (including enabling
  // paging).  Here we configure the rest of the flags that we care about.
  cr0 = rcr0();
  cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
  cr0 &= ~(CR0_TS|CR0_EM);
f01031e3:	83 e0 f3             	and    $0xfffffff3,%eax
f01031e6:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
  __asm __volatile("movl %0,%%cr0" : : "r" (val));
f01031eb:	0f 22 c0             	mov    %eax,%cr0
  uintptr_t va;
  int i;

  // check that we can read and write installed pages
  pp1 = pp2 = 0;
  assert((pp0 = page_alloc(0)));
f01031ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01031f5:	e8 bc de ff ff       	call   f01010b6 <page_alloc>
f01031fa:	89 c3                	mov    %eax,%ebx
f01031fc:	85 c0                	test   %eax,%eax
f01031fe:	75 24                	jne    f0103224 <mem_init+0x1d0f>
f0103200:	c7 44 24 0c 6b 76 10 	movl   $0xf010766b,0xc(%esp)
f0103207:	f0 
f0103208:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f010320f:	f0 
f0103210:	c7 44 24 04 4c 04 00 	movl   $0x44c,0x4(%esp)
f0103217:	00 
f0103218:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f010321f:	e8 1c ce ff ff       	call   f0100040 <_panic>
  assert((pp1 = page_alloc(0)));
f0103224:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010322b:	e8 86 de ff ff       	call   f01010b6 <page_alloc>
f0103230:	89 c7                	mov    %eax,%edi
f0103232:	85 c0                	test   %eax,%eax
f0103234:	75 24                	jne    f010325a <mem_init+0x1d45>
f0103236:	c7 44 24 0c 81 76 10 	movl   $0xf0107681,0xc(%esp)
f010323d:	f0 
f010323e:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0103245:	f0 
f0103246:	c7 44 24 04 4d 04 00 	movl   $0x44d,0x4(%esp)
f010324d:	00 
f010324e:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0103255:	e8 e6 cd ff ff       	call   f0100040 <_panic>
  assert((pp2 = page_alloc(0)));
f010325a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103261:	e8 50 de ff ff       	call   f01010b6 <page_alloc>
f0103266:	89 c6                	mov    %eax,%esi
f0103268:	85 c0                	test   %eax,%eax
f010326a:	75 24                	jne    f0103290 <mem_init+0x1d7b>
f010326c:	c7 44 24 0c 97 76 10 	movl   $0xf0107697,0xc(%esp)
f0103273:	f0 
f0103274:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f010327b:	f0 
f010327c:	c7 44 24 04 4e 04 00 	movl   $0x44e,0x4(%esp)
f0103283:	00 
f0103284:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f010328b:	e8 b0 cd ff ff       	call   f0100040 <_panic>
  page_free(pp0);
f0103290:	89 1c 24             	mov    %ebx,(%esp)
f0103293:	e8 cd de ff ff       	call   f0101165 <page_free>
  memset(page2kva(pp1), 1, PGSIZE);
f0103298:	89 f8                	mov    %edi,%eax
f010329a:	e8 fe d8 ff ff       	call   f0100b9d <page2kva>
f010329f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01032a6:	00 
f01032a7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01032ae:	00 
f01032af:	89 04 24             	mov    %eax,(%esp)
f01032b2:	e8 90 2f 00 00       	call   f0106247 <memset>
  memset(page2kva(pp2), 2, PGSIZE);
f01032b7:	89 f0                	mov    %esi,%eax
f01032b9:	e8 df d8 ff ff       	call   f0100b9d <page2kva>
f01032be:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01032c5:	00 
f01032c6:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01032cd:	00 
f01032ce:	89 04 24             	mov    %eax,(%esp)
f01032d1:	e8 71 2f 00 00       	call   f0106247 <memset>
  page_insert(kern_pgdir, pp1, (void*)PGSIZE, PTE_W);
f01032d6:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01032dd:	00 
f01032de:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01032e5:	00 
f01032e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01032ea:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f01032ef:	89 04 24             	mov    %eax,(%esp)
f01032f2:	e8 21 e1 ff ff       	call   f0101418 <page_insert>
  assert(pp1->pp_ref == 1);
f01032f7:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01032fc:	74 24                	je     f0103322 <mem_init+0x1e0d>
f01032fe:	c7 44 24 0c 68 77 10 	movl   $0xf0107768,0xc(%esp)
f0103305:	f0 
f0103306:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f010330d:	f0 
f010330e:	c7 44 24 04 53 04 00 	movl   $0x453,0x4(%esp)
f0103315:	00 
f0103316:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f010331d:	e8 1e cd ff ff       	call   f0100040 <_panic>
  assert(*(uint32_t*)PGSIZE == 0x01010101U);
f0103322:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103329:	01 01 01 
f010332c:	74 24                	je     f0103352 <mem_init+0x1e3d>
f010332e:	c7 44 24 0c e8 80 10 	movl   $0xf01080e8,0xc(%esp)
f0103335:	f0 
f0103336:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f010333d:	f0 
f010333e:	c7 44 24 04 54 04 00 	movl   $0x454,0x4(%esp)
f0103345:	00 
f0103346:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f010334d:	e8 ee cc ff ff       	call   f0100040 <_panic>
  page_insert(kern_pgdir, pp2, (void*)PGSIZE, PTE_W);
f0103352:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103359:	00 
f010335a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103361:	00 
f0103362:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103366:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f010336b:	89 04 24             	mov    %eax,(%esp)
f010336e:	e8 a5 e0 ff ff       	call   f0101418 <page_insert>
  assert(*(uint32_t*)PGSIZE == 0x02020202U);
f0103373:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f010337a:	02 02 02 
f010337d:	74 24                	je     f01033a3 <mem_init+0x1e8e>
f010337f:	c7 44 24 0c 0c 81 10 	movl   $0xf010810c,0xc(%esp)
f0103386:	f0 
f0103387:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f010338e:	f0 
f010338f:	c7 44 24 04 56 04 00 	movl   $0x456,0x4(%esp)
f0103396:	00 
f0103397:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f010339e:	e8 9d cc ff ff       	call   f0100040 <_panic>
  assert(pp2->pp_ref == 1);
f01033a3:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01033a8:	74 24                	je     f01033ce <mem_init+0x1eb9>
f01033aa:	c7 44 24 0c 8a 77 10 	movl   $0xf010778a,0xc(%esp)
f01033b1:	f0 
f01033b2:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f01033b9:	f0 
f01033ba:	c7 44 24 04 57 04 00 	movl   $0x457,0x4(%esp)
f01033c1:	00 
f01033c2:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f01033c9:	e8 72 cc ff ff       	call   f0100040 <_panic>
  assert(pp1->pp_ref == 0);
f01033ce:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01033d3:	74 24                	je     f01033f9 <mem_init+0x1ee4>
f01033d5:	c7 44 24 0c f4 77 10 	movl   $0xf01077f4,0xc(%esp)
f01033dc:	f0 
f01033dd:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f01033e4:	f0 
f01033e5:	c7 44 24 04 58 04 00 	movl   $0x458,0x4(%esp)
f01033ec:	00 
f01033ed:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f01033f4:	e8 47 cc ff ff       	call   f0100040 <_panic>
  *(uint32_t*)PGSIZE = 0x03030303U;
f01033f9:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103400:	03 03 03 
  assert(*(uint32_t*)page2kva(pp2) == 0x03030303U);
f0103403:	89 f0                	mov    %esi,%eax
f0103405:	e8 93 d7 ff ff       	call   f0100b9d <page2kva>
f010340a:	81 38 03 03 03 03    	cmpl   $0x3030303,(%eax)
f0103410:	74 24                	je     f0103436 <mem_init+0x1f21>
f0103412:	c7 44 24 0c 30 81 10 	movl   $0xf0108130,0xc(%esp)
f0103419:	f0 
f010341a:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0103421:	f0 
f0103422:	c7 44 24 04 5a 04 00 	movl   $0x45a,0x4(%esp)
f0103429:	00 
f010342a:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0103431:	e8 0a cc ff ff       	call   f0100040 <_panic>
  page_remove(kern_pgdir, (void*)PGSIZE);
f0103436:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010343d:	00 
f010343e:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0103443:	89 04 24             	mov    %eax,(%esp)
f0103446:	e8 84 df ff ff       	call   f01013cf <page_remove>
  assert(pp2->pp_ref == 0);
f010344b:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0103450:	74 24                	je     f0103476 <mem_init+0x1f61>
f0103452:	c7 44 24 0c c2 77 10 	movl   $0xf01077c2,0xc(%esp)
f0103459:	f0 
f010345a:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0103461:	f0 
f0103462:	c7 44 24 04 5c 04 00 	movl   $0x45c,0x4(%esp)
f0103469:	00 
f010346a:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f0103471:	e8 ca cb ff ff       	call   f0100040 <_panic>

  // forcibly take pp0 back
  assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103476:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f010347b:	8b 08                	mov    (%eax),%ecx
f010347d:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103483:	89 da                	mov    %ebx,%edx
f0103485:	2b 15 90 ce 20 f0    	sub    0xf020ce90,%edx
f010348b:	c1 fa 03             	sar    $0x3,%edx
f010348e:	c1 e2 0c             	shl    $0xc,%edx
f0103491:	39 d1                	cmp    %edx,%ecx
f0103493:	74 24                	je     f01034b9 <mem_init+0x1fa4>
f0103495:	c7 44 24 0c c4 7a 10 	movl   $0xf0107ac4,0xc(%esp)
f010349c:	f0 
f010349d:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f01034a4:	f0 
f01034a5:	c7 44 24 04 5f 04 00 	movl   $0x45f,0x4(%esp)
f01034ac:	00 
f01034ad:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f01034b4:	e8 87 cb ff ff       	call   f0100040 <_panic>
  kern_pgdir[0] = 0;
f01034b9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  assert(pp0->pp_ref == 1);
f01034bf:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01034c4:	74 24                	je     f01034ea <mem_init+0x1fd5>
f01034c6:	c7 44 24 0c 79 77 10 	movl   $0xf0107779,0xc(%esp)
f01034cd:	f0 
f01034ce:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f01034d5:	f0 
f01034d6:	c7 44 24 04 61 04 00 	movl   $0x461,0x4(%esp)
f01034dd:	00 
f01034de:	c7 04 24 5f 75 10 f0 	movl   $0xf010755f,(%esp)
f01034e5:	e8 56 cb ff ff       	call   f0100040 <_panic>
  pp0->pp_ref = 0;
f01034ea:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

  // free the pages we took
  page_free(pp0);
f01034f0:	89 1c 24             	mov    %ebx,(%esp)
f01034f3:	e8 6d dc ff ff       	call   f0101165 <page_free>

  cprintf("check_page_installed_pgdir() succeeded!\n");
f01034f8:	c7 04 24 5c 81 10 f0 	movl   $0xf010815c,(%esp)
f01034ff:	e8 6c 0a 00 00       	call   f0103f70 <cprintf>
f0103504:	eb 1f                	jmp    f0103525 <mem_init+0x2010>
  // check kernel stack
  // (updated in lab 4 to check per-CPU kernel stacks)
  for (n = 0; n < NCPU; n++) {
    uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
    for (i = 0; i < KSTKSIZE; i += PGSIZE)
      assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103506:	89 da                	mov    %ebx,%edx
f0103508:	89 f8                	mov    %edi,%eax
f010350a:	e8 d3 d6 ff ff       	call   f0100be2 <check_va2pa>
f010350f:	90                   	nop
f0103510:	e9 0b fb ff ff       	jmp    f0103020 <mem_init+0x1b0b>
    assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

  // check envs array (new test for lab 3)
  n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
  for (i = 0; i < n; i += PGSIZE)
    assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0103515:	89 da                	mov    %ebx,%edx
f0103517:	89 f8                	mov    %edi,%eax
f0103519:	e8 c4 d6 ff ff       	call   f0100be2 <check_va2pa>
f010351e:	66 90                	xchg   %ax,%ax
f0103520:	e9 0a fa ff ff       	jmp    f0102f2f <mem_init+0x1a1a>
  cr0 &= ~(CR0_TS|CR0_EM);
  lcr0(cr0);

  // Some more checks, only possible after kern_pgdir is installed.
  check_page_installed_pgdir();
}
f0103525:	83 c4 4c             	add    $0x4c,%esp
f0103528:	5b                   	pop    %ebx
f0103529:	5e                   	pop    %esi
f010352a:	5f                   	pop    %edi
f010352b:	5d                   	pop    %ebp
f010352c:	c3                   	ret    

f010352d <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f010352d:	55                   	push   %ebp
f010352e:	89 e5                	mov    %esp,%ebp
f0103530:	57                   	push   %edi
f0103531:	56                   	push   %esi
f0103532:	53                   	push   %ebx
f0103533:	83 ec 2c             	sub    $0x2c,%esp
f0103536:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103539:	8b 45 0c             	mov    0xc(%ebp),%eax
  // LAB 3: Your code here.
  char* addr = (char*)va;
  char *c;
	for (c = addr; c < addr + len; c = ROUNDDOWN(c + PGSIZE, PGSIZE)) {
f010353c:	89 c3                	mov    %eax,%ebx
f010353e:	03 45 10             	add    0x10(%ebp),%eax
f0103541:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		pte_t *pte = NULL;
		struct PageInfo *p = page_lookup(env->env_pgdir, (void*)c, &pte);
f0103544:	8d 75 e4             	lea    -0x1c(%ebp),%esi
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
  // LAB 3: Your code here.
  char* addr = (char*)va;
  char *c;
	for (c = addr; c < addr + len; c = ROUNDDOWN(c + PGSIZE, PGSIZE)) {
f0103547:	eb 49                	jmp    f0103592 <user_mem_check+0x65>
		pte_t *pte = NULL;
f0103549:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		struct PageInfo *p = page_lookup(env->env_pgdir, (void*)c, &pte);
f0103550:	89 74 24 08          	mov    %esi,0x8(%esp)
f0103554:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103558:	8b 47 60             	mov    0x60(%edi),%eax
f010355b:	89 04 24             	mov    %eax,(%esp)
f010355e:	e8 be dd ff ff       	call   f0101321 <page_lookup>
		if (!p || !(*pte & perm) || (uintptr_t)c >= ULIM) {
f0103563:	85 c0                	test   %eax,%eax
f0103565:	74 12                	je     f0103579 <user_mem_check+0x4c>
f0103567:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010356a:	8b 00                	mov    (%eax),%eax
f010356c:	85 45 14             	test   %eax,0x14(%ebp)
f010356f:	74 08                	je     f0103579 <user_mem_check+0x4c>
f0103571:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0103577:	76 0d                	jbe    f0103586 <user_mem_check+0x59>
			user_mem_check_addr = (uintptr_t)c;
f0103579:	89 1d 3c c2 20 f0    	mov    %ebx,0xf020c23c
			return -E_FAULT;
f010357f:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103584:	eb 16                	jmp    f010359c <user_mem_check+0x6f>
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
  // LAB 3: Your code here.
  char* addr = (char*)va;
  char *c;
	for (c = addr; c < addr + len; c = ROUNDDOWN(c + PGSIZE, PGSIZE)) {
f0103586:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010358c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0103592:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0103595:	72 b2                	jb     f0103549 <user_mem_check+0x1c>
		if (!p || !(*pte & perm) || (uintptr_t)c >= ULIM) {
			user_mem_check_addr = (uintptr_t)c;
			return -E_FAULT;
		}
	}
	return 0;
f0103597:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010359c:	83 c4 2c             	add    $0x2c,%esp
f010359f:	5b                   	pop    %ebx
f01035a0:	5e                   	pop    %esi
f01035a1:	5f                   	pop    %edi
f01035a2:	5d                   	pop    %ebp
f01035a3:	c3                   	ret    

f01035a4 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f01035a4:	55                   	push   %ebp
f01035a5:	89 e5                	mov    %esp,%ebp
f01035a7:	53                   	push   %ebx
f01035a8:	83 ec 14             	sub    $0x14,%esp
f01035ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01035ae:	8b 45 14             	mov    0x14(%ebp),%eax
f01035b1:	83 c8 04             	or     $0x4,%eax
f01035b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01035b8:	8b 45 10             	mov    0x10(%ebp),%eax
f01035bb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01035bf:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035c2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035c6:	89 1c 24             	mov    %ebx,(%esp)
f01035c9:	e8 5f ff ff ff       	call   f010352d <user_mem_check>
f01035ce:	85 c0                	test   %eax,%eax
f01035d0:	79 24                	jns    f01035f6 <user_mem_assert+0x52>
    cprintf("[%08x] user_mem_check assertion failure for "
f01035d2:	a1 3c c2 20 f0       	mov    0xf020c23c,%eax
f01035d7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01035db:	8b 43 48             	mov    0x48(%ebx),%eax
f01035de:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035e2:	c7 04 24 88 81 10 f0 	movl   $0xf0108188,(%esp)
f01035e9:	e8 82 09 00 00       	call   f0103f70 <cprintf>
            "va %08x\n", env->env_id, user_mem_check_addr);
    env_destroy(env);                   // may not return
f01035ee:	89 1c 24             	mov    %ebx,(%esp)
f01035f1:	e8 a1 06 00 00       	call   f0103c97 <env_destroy>
  }
}
f01035f6:	83 c4 14             	add    $0x14,%esp
f01035f9:	5b                   	pop    %ebx
f01035fa:	5d                   	pop    %ebp
f01035fb:	c3                   	ret    
f01035fc:	66 90                	xchg   %ax,%ax
f01035fe:	66 90                	xchg   %ax,%ax

f0103600 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103600:	55                   	push   %ebp
f0103601:	89 e5                	mov    %esp,%ebp
f0103603:	57                   	push   %edi
f0103604:	56                   	push   %esi
f0103605:	53                   	push   %ebx
f0103606:	83 ec 1c             	sub    $0x1c,%esp
f0103609:	89 c7                	mov    %eax,%edi
  // LAB 3: Your code here.
  // (But only if you need it for load_icode.)
  //
  void* end_va = va + len;
  va = ROUNDDOWN(va, PGSIZE);
f010360b:	89 d3                	mov    %edx,%ebx
f010360d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  end_va = ROUNDUP(end_va, PGSIZE);
f0103613:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f010361a:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  struct PageInfo * pg;
  void* i;
  int r;
  for (i = va; i < end_va; i += PGSIZE) {
f0103620:	eb 71                	jmp    f0103693 <region_alloc+0x93>
    if ((pg = page_alloc(ALLOC_ZERO)) == NULL) {
f0103622:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103629:	e8 88 da ff ff       	call   f01010b6 <page_alloc>
f010362e:	85 c0                	test   %eax,%eax
f0103630:	75 1c                	jne    f010364e <region_alloc+0x4e>
      panic("Failed allocation (no more memory)");
f0103632:	c7 44 24 08 c0 81 10 	movl   $0xf01081c0,0x8(%esp)
f0103639:	f0 
f010363a:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
f0103641:	00 
f0103642:	c7 04 24 e3 81 10 f0 	movl   $0xf01081e3,(%esp)
f0103649:	e8 f2 c9 ff ff       	call   f0100040 <_panic>
    }
    if ((r = page_insert(e->env_pgdir, pg, i, PTE_U | PTE_W)) != 0) {
f010364e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0103655:	00 
f0103656:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010365a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010365e:	8b 47 60             	mov    0x60(%edi),%eax
f0103661:	89 04 24             	mov    %eax,(%esp)
f0103664:	e8 af dd ff ff       	call   f0101418 <page_insert>
f0103669:	85 c0                	test   %eax,%eax
f010366b:	74 20                	je     f010368d <region_alloc+0x8d>
      panic("region_alloc: %e", r);
f010366d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103671:	c7 44 24 08 ee 81 10 	movl   $0xf01081ee,0x8(%esp)
f0103678:	f0 
f0103679:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
f0103680:	00 
f0103681:	c7 04 24 e3 81 10 f0 	movl   $0xf01081e3,(%esp)
f0103688:	e8 b3 c9 ff ff       	call   f0100040 <_panic>
  va = ROUNDDOWN(va, PGSIZE);
  end_va = ROUNDUP(end_va, PGSIZE);
  struct PageInfo * pg;
  void* i;
  int r;
  for (i = va; i < end_va; i += PGSIZE) {
f010368d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103693:	39 f3                	cmp    %esi,%ebx
f0103695:	72 8b                	jb     f0103622 <region_alloc+0x22>
  }
  // Hint: It is easier to use region_alloc if the caller can pass
  //   'va' and 'len' values that are not page-aligned.
  //   You should round va down, and round (va + len) up.
  //   (Watch out for corner-cases!)
}
f0103697:	83 c4 1c             	add    $0x1c,%esp
f010369a:	5b                   	pop    %ebx
f010369b:	5e                   	pop    %esi
f010369c:	5f                   	pop    %edi
f010369d:	5d                   	pop    %ebp
f010369e:	c3                   	ret    

f010369f <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f010369f:	55                   	push   %ebp
f01036a0:	89 e5                	mov    %esp,%ebp
f01036a2:	56                   	push   %esi
f01036a3:	53                   	push   %ebx
f01036a4:	8b 45 08             	mov    0x8(%ebp),%eax
f01036a7:	8b 55 10             	mov    0x10(%ebp),%edx
  struct Env *e;

  // If envid is zero, return the current environment.
  if (envid == 0) {
f01036aa:	85 c0                	test   %eax,%eax
f01036ac:	75 1a                	jne    f01036c8 <envid2env+0x29>
    *env_store = curenv;
f01036ae:	e8 e6 31 00 00       	call   f0106899 <cpunum>
f01036b3:	6b c0 74             	imul   $0x74,%eax,%eax
f01036b6:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f01036bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01036bf:	89 01                	mov    %eax,(%ecx)
    return 0;
f01036c1:	b8 00 00 00 00       	mov    $0x0,%eax
f01036c6:	eb 70                	jmp    f0103738 <envid2env+0x99>
  // Look up the Env structure via the index part of the envid,
  // then check the env_id field in that struct Env
  // to ensure that the envid is not stale
  // (i.e., does not refer to a _previous_ environment
  // that used the same slot in the envs[] array).
  e = &envs[ENVX(envid)];
f01036c8:	89 c3                	mov    %eax,%ebx
f01036ca:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f01036d0:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f01036d3:	03 1d 48 c2 20 f0    	add    0xf020c248,%ebx
  if (e->env_status == ENV_FREE || e->env_id != envid) {
f01036d9:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f01036dd:	74 05                	je     f01036e4 <envid2env+0x45>
f01036df:	39 43 48             	cmp    %eax,0x48(%ebx)
f01036e2:	74 10                	je     f01036f4 <envid2env+0x55>
    *env_store = NULL;
f01036e4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036e7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    return -E_BAD_ENV;
f01036ed:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01036f2:	eb 44                	jmp    f0103738 <envid2env+0x99>
  // Check that the calling environment has legitimate permission
  // to manipulate the specified environment.
  // If checkperm is set, the specified environment
  // must be either the current environment
  // or an immediate child of the current environment.
  if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01036f4:	84 d2                	test   %dl,%dl
f01036f6:	74 36                	je     f010372e <envid2env+0x8f>
f01036f8:	e8 9c 31 00 00       	call   f0106899 <cpunum>
f01036fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0103700:	39 98 28 d0 20 f0    	cmp    %ebx,-0xfdf2fd8(%eax)
f0103706:	74 26                	je     f010372e <envid2env+0x8f>
f0103708:	8b 73 4c             	mov    0x4c(%ebx),%esi
f010370b:	e8 89 31 00 00       	call   f0106899 <cpunum>
f0103710:	6b c0 74             	imul   $0x74,%eax,%eax
f0103713:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0103719:	3b 70 48             	cmp    0x48(%eax),%esi
f010371c:	74 10                	je     f010372e <envid2env+0x8f>
    *env_store = NULL;
f010371e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103721:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    return -E_BAD_ENV;
f0103727:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010372c:	eb 0a                	jmp    f0103738 <envid2env+0x99>
  }

  *env_store = e;
f010372e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103731:	89 18                	mov    %ebx,(%eax)
  return 0;
f0103733:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103738:	5b                   	pop    %ebx
f0103739:	5e                   	pop    %esi
f010373a:	5d                   	pop    %ebp
f010373b:	c3                   	ret    

f010373c <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f010373c:	55                   	push   %ebp
f010373d:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
  __asm __volatile("lgdt (%0)" : : "r" (p));
f010373f:	b8 20 13 12 f0       	mov    $0xf0121320,%eax
f0103744:	0f 01 10             	lgdtl  (%eax)
  lgdt(&gdt_pd);
  // The kernel never uses GS or FS, so we leave those set to
  // the user data segment.
  asm volatile ("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0103747:	b8 23 00 00 00       	mov    $0x23,%eax
f010374c:	8e e8                	mov    %eax,%gs
  asm volatile ("movw %%ax,%%fs" :: "a" (GD_UD|3));
f010374e:	8e e0                	mov    %eax,%fs
  // The kernel does use ES, DS, and SS.  We'll change between
  // the kernel and user data segments as needed.
  asm volatile ("movw %%ax,%%es" :: "a" (GD_KD));
f0103750:	b0 10                	mov    $0x10,%al
f0103752:	8e c0                	mov    %eax,%es
  asm volatile ("movw %%ax,%%ds" :: "a" (GD_KD));
f0103754:	8e d8                	mov    %eax,%ds
  asm volatile ("movw %%ax,%%ss" :: "a" (GD_KD));
f0103756:	8e d0                	mov    %eax,%ss
  // Load the kernel text segment into CS.
  asm volatile ("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103758:	ea 5f 37 10 f0 08 00 	ljmp   $0x8,$0xf010375f
}

static __inline void
lldt(uint16_t sel)
{
  __asm __volatile("lldt %0" : : "r" (sel));
f010375f:	b0 00                	mov    $0x0,%al
f0103761:	0f 00 d0             	lldt   %ax
  // For good measure, clear the local descriptor table (LDT),
  // since we don't use it.
  lldt(0);
}
f0103764:	5d                   	pop    %ebp
f0103765:	c3                   	ret    

f0103766 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103766:	55                   	push   %ebp
f0103767:	89 e5                	mov    %esp,%ebp
f0103769:	53                   	push   %ebx
  // LAB 3: Your code here.
  int i;
  for (i = 0; i < NENV; ++i) {
    envs[i].env_id = 0;
    envs[i].env_status = ENV_FREE;
    envs[i].env_link = (i == NENV - 1) ? env_free_list : &envs[i + 1];
f010376a:	8b 1d 4c c2 20 f0    	mov    0xf020c24c,%ebx
f0103770:	a1 48 c2 20 f0       	mov    0xf020c248,%eax
f0103775:	83 c0 7c             	add    $0x7c,%eax
env_init(void)
{
  // Set up envs array
  // LAB 3: Your code here.
  int i;
  for (i = 0; i < NENV; ++i) {
f0103778:	ba 00 00 00 00       	mov    $0x0,%edx
    envs[i].env_id = 0;
f010377d:	c7 40 cc 00 00 00 00 	movl   $0x0,-0x34(%eax)
    envs[i].env_status = ENV_FREE;
f0103784:	c7 40 d8 00 00 00 00 	movl   $0x0,-0x28(%eax)
    envs[i].env_link = (i == NENV - 1) ? env_free_list : &envs[i + 1];
f010378b:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
f0103791:	74 22                	je     f01037b5 <env_init+0x4f>
f0103793:	89 40 c8             	mov    %eax,-0x38(%eax)
env_init(void)
{
  // Set up envs array
  // LAB 3: Your code here.
  int i;
  for (i = 0; i < NENV; ++i) {
f0103796:	83 c2 01             	add    $0x1,%edx
f0103799:	83 c0 7c             	add    $0x7c,%eax
f010379c:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f01037a2:	75 d9                	jne    f010377d <env_init+0x17>
    envs[i].env_id = 0;
    envs[i].env_status = ENV_FREE;
    envs[i].env_link = (i == NENV - 1) ? env_free_list : &envs[i + 1];
  }
  env_free_list = envs;
f01037a4:	a1 48 c2 20 f0       	mov    0xf020c248,%eax
f01037a9:	a3 4c c2 20 f0       	mov    %eax,0xf020c24c

  // Per-CPU part of the initialization
  env_init_percpu();
f01037ae:	e8 89 ff ff ff       	call   f010373c <env_init_percpu>
f01037b3:	eb 05                	jmp    f01037ba <env_init+0x54>
  // LAB 3: Your code here.
  int i;
  for (i = 0; i < NENV; ++i) {
    envs[i].env_id = 0;
    envs[i].env_status = ENV_FREE;
    envs[i].env_link = (i == NENV - 1) ? env_free_list : &envs[i + 1];
f01037b5:	89 58 c8             	mov    %ebx,-0x38(%eax)
f01037b8:	eb ea                	jmp    f01037a4 <env_init+0x3e>
  }
  env_free_list = envs;

  // Per-CPU part of the initialization
  env_init_percpu();
}
f01037ba:	5b                   	pop    %ebx
f01037bb:	5d                   	pop    %ebp
f01037bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01037c0:	c3                   	ret    

f01037c1 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01037c1:	55                   	push   %ebp
f01037c2:	89 e5                	mov    %esp,%ebp
f01037c4:	56                   	push   %esi
f01037c5:	53                   	push   %ebx
f01037c6:	83 ec 10             	sub    $0x10,%esp
  struct Env *e = env_free_list;
f01037c9:	8b 1d 4c c2 20 f0    	mov    0xf020c24c,%ebx
  if (!e)
f01037cf:	85 db                	test   %ebx,%ebx
f01037d1:	0f 84 58 01 00 00    	je     f010392f <env_alloc+0x16e>
{
  int i;
  struct PageInfo *p;

  // Allocate a page for the page directory
  p = page_alloc(ALLOC_ZERO);
f01037d7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01037de:	e8 d3 d8 ff ff       	call   f01010b6 <page_alloc>
  if (!p)
f01037e3:	85 c0                	test   %eax,%eax
f01037e5:	0f 84 4b 01 00 00    	je     f0103936 <env_alloc+0x175>
f01037eb:	89 c2                	mov    %eax,%edx
f01037ed:	2b 15 90 ce 20 f0    	sub    0xf020ce90,%edx
f01037f3:	c1 fa 03             	sar    $0x3,%edx
f01037f6:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01037f9:	89 d1                	mov    %edx,%ecx
f01037fb:	c1 e9 0c             	shr    $0xc,%ecx
f01037fe:	3b 0d 88 ce 20 f0    	cmp    0xf020ce88,%ecx
f0103804:	72 20                	jb     f0103826 <env_alloc+0x65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103806:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010380a:	c7 44 24 08 a4 6f 10 	movl   $0xf0106fa4,0x8(%esp)
f0103811:	f0 
f0103812:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103819:	00 
f010381a:	c7 04 24 6b 75 10 f0 	movl   $0xf010756b,(%esp)
f0103821:	e8 1a c8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103826:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010382c:	89 53 60             	mov    %edx,0x60(%ebx)
  //      is an exception -- you need to increment env_pgdir's
  //      pp_ref for env_free to work correctly.
  //    - The functions in kern/pmap.h are handy.

  // LAB 3: Your code here.
  e->env_pgdir = page2kva(p);
f010382f:	ba ec 0e 00 00       	mov    $0xeec,%edx

  for (i = PDX(UTOP); i < NPDENTRIES; i++) {
    e->env_pgdir[i] = kern_pgdir[i];
f0103834:	8b 0d 8c ce 20 f0    	mov    0xf020ce8c,%ecx
f010383a:	8b 34 11             	mov    (%ecx,%edx,1),%esi
f010383d:	8b 4b 60             	mov    0x60(%ebx),%ecx
f0103840:	89 34 11             	mov    %esi,(%ecx,%edx,1)
f0103843:	83 c2 04             	add    $0x4,%edx
  //    - The functions in kern/pmap.h are handy.

  // LAB 3: Your code here.
  e->env_pgdir = page2kva(p);

  for (i = PDX(UTOP); i < NPDENTRIES; i++) {
f0103846:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
f010384c:	75 e6                	jne    f0103834 <env_alloc+0x73>
    e->env_pgdir[i] = kern_pgdir[i];
  }

  p->pp_ref++;
f010384e:	66 83 40 04 01       	addw   $0x1,0x4(%eax)

  // UVPT maps the env's own page table read-only.
  // Permissions: kernel R, user R
  e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103853:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103856:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010385b:	77 20                	ja     f010387d <env_alloc+0xbc>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010385d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103861:	c7 44 24 08 c8 6f 10 	movl   $0xf0106fc8,0x8(%esp)
f0103868:	f0 
f0103869:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
f0103870:	00 
f0103871:	c7 04 24 e3 81 10 f0 	movl   $0xf01081e3,(%esp)
f0103878:	e8 c3 c7 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010387d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103883:	83 ca 05             	or     $0x5,%edx
f0103886:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
  int r = env_setup_vm(e);
  if (r < 0)
    return r;

  // Generate an env_id for this environment.
  int32_t gen = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010388c:	8b 43 48             	mov    0x48(%ebx),%eax
f010388f:	05 00 10 00 00       	add    $0x1000,%eax
  if (gen <= 0) // Don't create a negative env_id.
f0103894:	25 00 fc ff ff       	and    $0xfffffc00,%eax
    gen = 1 << ENVGENSHIFT;
f0103899:	ba 00 10 00 00       	mov    $0x1000,%edx
f010389e:	0f 4e c2             	cmovle %edx,%eax
  e->env_id = gen | (e - envs);
f01038a1:	89 da                	mov    %ebx,%edx
f01038a3:	2b 15 48 c2 20 f0    	sub    0xf020c248,%edx
f01038a9:	c1 fa 02             	sar    $0x2,%edx
f01038ac:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01038b2:	09 d0                	or     %edx,%eax
f01038b4:	89 43 48             	mov    %eax,0x48(%ebx)

  // Set the basic status variables.
  e->env_parent_id = parent_id;
f01038b7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01038ba:	89 43 4c             	mov    %eax,0x4c(%ebx)
  e->env_type = ENV_TYPE_USER;
f01038bd:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
  e->env_status = ENV_RUNNABLE;
f01038c4:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
  e->env_runs = 0;
f01038cb:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

  // Clear out all the saved register state,
  // to prevent the register values
  // of a prior environment inhabiting this Env structure
  // from "leaking" into our new environment.
  memset(&e->env_tf, 0, sizeof(e->env_tf));
f01038d2:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f01038d9:	00 
f01038da:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01038e1:	00 
f01038e2:	89 1c 24             	mov    %ebx,(%esp)
f01038e5:	e8 5d 29 00 00       	call   f0106247 <memset>
  // The low 2 bits of each segment register contains the
  // Requestor Privilege Level (RPL); 3 means user mode.  When
  // we switch privilege levels, the hardware does various
  // checks involving the RPL and the Descriptor Privilege Level
  // (DPL) stored in the descriptors themselves.
  e->env_tf.tf_ds = GD_UD | 3;
f01038ea:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
  e->env_tf.tf_es = GD_UD | 3;
f01038f0:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
  e->env_tf.tf_ss = GD_UD | 3;
f01038f6:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
  e->env_tf.tf_esp = USTACKTOP;
f01038fc:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
  e->env_tf.tf_cs = GD_UT | 3;
f0103903:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
  // You will set e->env_tf.tf_eip later.

  // Enable interrupts while in user mode.
  // LAB 4: Your code here.
  e->env_tf.tf_eflags |= FL_IF;
f0103909:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

  // Clear the page fault handler until user installs one.
  e->env_pgfault_upcall = 0;
f0103910:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

  // Also clear the IPC receiving flag.
  e->env_ipc_recving = 0;
f0103917:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

  // commit the allocation
  env_free_list = e->env_link;
f010391b:	8b 43 44             	mov    0x44(%ebx),%eax
f010391e:	a3 4c c2 20 f0       	mov    %eax,0xf020c24c
  *newenv_store = e;
f0103923:	8b 45 08             	mov    0x8(%ebp),%eax
f0103926:	89 18                	mov    %ebx,(%eax)

  // cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
  return 0;
f0103928:	b8 00 00 00 00       	mov    $0x0,%eax
f010392d:	eb 0c                	jmp    f010393b <env_alloc+0x17a>
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
  struct Env *e = env_free_list;
  if (!e)
    return -E_NO_FREE_ENV;
f010392f:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103934:	eb 05                	jmp    f010393b <env_alloc+0x17a>
  struct PageInfo *p;

  // Allocate a page for the page directory
  p = page_alloc(ALLOC_ZERO);
  if (!p)
    return -E_NO_MEM;
f0103936:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  env_free_list = e->env_link;
  *newenv_store = e;

  // cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
  return 0;
}
f010393b:	83 c4 10             	add    $0x10,%esp
f010393e:	5b                   	pop    %ebx
f010393f:	5e                   	pop    %esi
f0103940:	5d                   	pop    %ebp
f0103941:	c3                   	ret    

f0103942 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103942:	55                   	push   %ebp
f0103943:	89 e5                	mov    %esp,%ebp
f0103945:	57                   	push   %edi
f0103946:	56                   	push   %esi
f0103947:	53                   	push   %ebx
f0103948:	83 ec 3c             	sub    $0x3c,%esp
f010394b:	8b 7d 08             	mov    0x8(%ebp),%edi
  struct Env *e;
  int env = env_alloc(&e, 0);
f010394e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103955:	00 
f0103956:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103959:	89 04 24             	mov    %eax,(%esp)
f010395c:	e8 60 fe ff ff       	call   f01037c1 <env_alloc>
  
  if (env == -E_NO_FREE_ENV) {
f0103961:	83 f8 fb             	cmp    $0xfffffffb,%eax
f0103964:	75 1c                	jne    f0103982 <env_create+0x40>
		panic("no free environments"); 
f0103966:	c7 44 24 08 ff 81 10 	movl   $0xf01081ff,0x8(%esp)
f010396d:	f0 
f010396e:	c7 44 24 04 98 01 00 	movl   $0x198,0x4(%esp)
f0103975:	00 
f0103976:	c7 04 24 e3 81 10 f0 	movl   $0xf01081e3,(%esp)
f010397d:	e8 be c6 ff ff       	call   f0100040 <_panic>
	}	else if (env == -E_NO_MEM) {
f0103982:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0103985:	75 1c                	jne    f01039a3 <env_create+0x61>
		panic("no memory"); 
f0103987:	c7 44 24 08 14 82 10 	movl   $0xf0108214,0x8(%esp)
f010398e:	f0 
f010398f:	c7 44 24 04 9a 01 00 	movl   $0x19a,0x4(%esp)
f0103996:	00 
f0103997:	c7 04 24 e3 81 10 f0 	movl   $0xf01081e3,(%esp)
f010399e:	e8 9d c6 ff ff       	call   f0100040 <_panic>
	}

  load_icode(e, binary);
f01039a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01039a6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  //  What?  (See env_run() and env_pop_tf() below.)

  // LAB 3: Your code here.
  struct Elf* elf_h = (struct Elf*) binary;

	if(elf_h->e_magic != ELF_MAGIC) {
f01039a9:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f01039af:	74 1c                	je     f01039cd <env_create+0x8b>
		panic("bad elf file");
f01039b1:	c7 44 24 08 1e 82 10 	movl   $0xf010821e,0x8(%esp)
f01039b8:	f0 
f01039b9:	c7 44 24 04 71 01 00 	movl   $0x171,0x4(%esp)
f01039c0:	00 
f01039c1:	c7 04 24 e3 81 10 f0 	movl   $0xf01081e3,(%esp)
f01039c8:	e8 73 c6 ff ff       	call   f0100040 <_panic>
	}

	struct Proghdr* ph = (struct Proghdr*) ((uint8_t *) elf_h + elf_h->e_phoff);
f01039cd:	89 fb                	mov    %edi,%ebx
f01039cf:	03 5f 1c             	add    0x1c(%edi),%ebx
	struct Proghdr* eph = ph + elf_h->e_phnum;
f01039d2:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f01039d6:	c1 e6 05             	shl    $0x5,%esi
f01039d9:	01 de                	add    %ebx,%esi

	//use env page directory. 
	lcr3(PADDR(e->env_pgdir));
f01039db:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01039de:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01039e1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01039e6:	77 20                	ja     f0103a08 <env_create+0xc6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01039e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01039ec:	c7 44 24 08 c8 6f 10 	movl   $0xf0106fc8,0x8(%esp)
f01039f3:	f0 
f01039f4:	c7 44 24 04 78 01 00 	movl   $0x178,0x4(%esp)
f01039fb:	00 
f01039fc:	c7 04 24 e3 81 10 f0 	movl   $0xf01081e3,(%esp)
f0103a03:	e8 38 c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103a08:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
  __asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103a0d:	0f 22 d8             	mov    %eax,%cr3
f0103a10:	eb 4b                	jmp    f0103a5d <env_create+0x11b>

	while(ph < eph) {
		if(ph->p_type == ELF_PROG_LOAD) {
f0103a12:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103a15:	75 43                	jne    f0103a5a <env_create+0x118>
			region_alloc(e, (void*) ph->p_va, ph->p_memsz);
f0103a17:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103a1a:	8b 53 08             	mov    0x8(%ebx),%edx
f0103a1d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103a20:	e8 db fb ff ff       	call   f0103600 <region_alloc>

			memset((void*) ph->p_va, 0x0, ph->p_memsz);
f0103a25:	8b 43 14             	mov    0x14(%ebx),%eax
f0103a28:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103a2c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103a33:	00 
f0103a34:	8b 43 08             	mov    0x8(%ebx),%eax
f0103a37:	89 04 24             	mov    %eax,(%esp)
f0103a3a:	e8 08 28 00 00       	call   f0106247 <memset>
			memcpy((void*) ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0103a3f:	8b 43 10             	mov    0x10(%ebx),%eax
f0103a42:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103a46:	89 f8                	mov    %edi,%eax
f0103a48:	03 43 04             	add    0x4(%ebx),%eax
f0103a4b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a4f:	8b 43 08             	mov    0x8(%ebx),%eax
f0103a52:	89 04 24             	mov    %eax,(%esp)
f0103a55:	e8 a2 28 00 00       	call   f01062fc <memcpy>
		}
		ph++;
f0103a5a:	83 c3 20             	add    $0x20,%ebx
	struct Proghdr* eph = ph + elf_h->e_phnum;

	//use env page directory. 
	lcr3(PADDR(e->env_pgdir));

	while(ph < eph) {
f0103a5d:	39 de                	cmp    %ebx,%esi
f0103a5f:	77 b1                	ja     f0103a12 <env_create+0xd0>
			memcpy((void*) ph->p_va, binary + ph->p_offset, ph->p_filesz);
		}
		ph++;
	}

	lcr3(PADDR(kern_pgdir));
f0103a61:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103a66:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a6b:	77 20                	ja     f0103a8d <env_create+0x14b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a6d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a71:	c7 44 24 08 c8 6f 10 	movl   $0xf0106fc8,0x8(%esp)
f0103a78:	f0 
f0103a79:	c7 44 24 04 84 01 00 	movl   $0x184,0x4(%esp)
f0103a80:	00 
f0103a81:	c7 04 24 e3 81 10 f0 	movl   $0xf01081e3,(%esp)
f0103a88:	e8 b3 c5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103a8d:	05 00 00 00 10       	add    $0x10000000,%eax
f0103a92:	0f 22 d8             	mov    %eax,%cr3

	e->env_tf.tf_eip = elf_h->e_entry;
f0103a95:	8b 47 18             	mov    0x18(%edi),%eax
f0103a98:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103a9b:	89 47 30             	mov    %eax,0x30(%edi)
	region_alloc(e, (void*) USTACKTOP - PGSIZE, PGSIZE);
f0103a9e:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103aa3:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103aa8:	89 f8                	mov    %edi,%eax
f0103aaa:	e8 51 fb ff ff       	call   f0103600 <region_alloc>
	}	else if (env == -E_NO_MEM) {
		panic("no memory"); 
	}

  load_icode(e, binary);
  e->env_type = type;
f0103aaf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103ab2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103ab5:	89 48 50             	mov    %ecx,0x50(%eax)

  // If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
  // LAB 5: Your code here.
  if(type == ENV_TYPE_FS)
f0103ab8:	83 f9 01             	cmp    $0x1,%ecx
f0103abb:	75 07                	jne    f0103ac4 <env_create+0x182>
    e->env_tf.tf_eflags |= FL_IOPL_3;
f0103abd:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
}
f0103ac4:	83 c4 3c             	add    $0x3c,%esp
f0103ac7:	5b                   	pop    %ebx
f0103ac8:	5e                   	pop    %esi
f0103ac9:	5f                   	pop    %edi
f0103aca:	5d                   	pop    %ebp
f0103acb:	c3                   	ret    

f0103acc <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103acc:	55                   	push   %ebp
f0103acd:	89 e5                	mov    %esp,%ebp
f0103acf:	57                   	push   %edi
f0103ad0:	56                   	push   %esi
f0103ad1:	53                   	push   %ebx
f0103ad2:	83 ec 2c             	sub    $0x2c,%esp
f0103ad5:	8b 7d 08             	mov    0x8(%ebp),%edi
  physaddr_t pa;

  // If freeing the current environment, switch to kern_pgdir
  // before freeing the page directory, just in case the page
  // gets reused.
  if (e == curenv)
f0103ad8:	e8 bc 2d 00 00       	call   f0106899 <cpunum>
f0103add:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ae0:	39 b8 28 d0 20 f0    	cmp    %edi,-0xfdf2fd8(%eax)
f0103ae6:	74 09                	je     f0103af1 <env_free+0x25>
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103ae8:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103aef:	eb 36                	jmp    f0103b27 <env_free+0x5b>

  // If freeing the current environment, switch to kern_pgdir
  // before freeing the page directory, just in case the page
  // gets reused.
  if (e == curenv)
    lcr3(PADDR(kern_pgdir));
f0103af1:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103af6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103afb:	77 20                	ja     f0103b1d <env_free+0x51>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103afd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103b01:	c7 44 24 08 c8 6f 10 	movl   $0xf0106fc8,0x8(%esp)
f0103b08:	f0 
f0103b09:	c7 44 24 04 b4 01 00 	movl   $0x1b4,0x4(%esp)
f0103b10:	00 
f0103b11:	c7 04 24 e3 81 10 f0 	movl   $0xf01081e3,(%esp)
f0103b18:	e8 23 c5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103b1d:	05 00 00 00 10       	add    $0x10000000,%eax
f0103b22:	0f 22 d8             	mov    %eax,%cr3
f0103b25:	eb c1                	jmp    f0103ae8 <env_free+0x1c>
f0103b27:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103b2a:	89 c8                	mov    %ecx,%eax
f0103b2c:	c1 e0 02             	shl    $0x2,%eax
f0103b2f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  // Flush all mapped pages in the user portion of the address space
  static_assert(UTOP % PTSIZE == 0);
  for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

    // only look at mapped page tables
    if (!(e->env_pgdir[pdeno] & PTE_P))
f0103b32:	8b 47 60             	mov    0x60(%edi),%eax
f0103b35:	8b 34 88             	mov    (%eax,%ecx,4),%esi
f0103b38:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103b3e:	0f 84 b7 00 00 00    	je     f0103bfb <env_free+0x12f>
      continue;

    // find the pa and va of the page table
    pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103b44:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b4a:	89 f0                	mov    %esi,%eax
f0103b4c:	c1 e8 0c             	shr    $0xc,%eax
f0103b4f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103b52:	3b 05 88 ce 20 f0    	cmp    0xf020ce88,%eax
f0103b58:	72 20                	jb     f0103b7a <env_free+0xae>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103b5a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103b5e:	c7 44 24 08 a4 6f 10 	movl   $0xf0106fa4,0x8(%esp)
f0103b65:	f0 
f0103b66:	c7 44 24 04 c3 01 00 	movl   $0x1c3,0x4(%esp)
f0103b6d:	00 
f0103b6e:	c7 04 24 e3 81 10 f0 	movl   $0xf01081e3,(%esp)
f0103b75:	e8 c6 c4 ff ff       	call   f0100040 <_panic>
    pt = (pte_t*)KADDR(pa);

    // unmap all PTEs in this page table
    for (pteno = 0; pteno <= PTX(~0); pteno++)
      if (pt[pteno] & PTE_P)
        page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b7a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b7d:	c1 e0 16             	shl    $0x16,%eax
f0103b80:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    // find the pa and va of the page table
    pa = PTE_ADDR(e->env_pgdir[pdeno]);
    pt = (pte_t*)KADDR(pa);

    // unmap all PTEs in this page table
    for (pteno = 0; pteno <= PTX(~0); pteno++)
f0103b83:	bb 00 00 00 00       	mov    $0x0,%ebx
      if (pt[pteno] & PTE_P)
f0103b88:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103b8f:	01 
f0103b90:	74 17                	je     f0103ba9 <env_free+0xdd>
        page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b92:	89 d8                	mov    %ebx,%eax
f0103b94:	c1 e0 0c             	shl    $0xc,%eax
f0103b97:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103b9a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b9e:	8b 47 60             	mov    0x60(%edi),%eax
f0103ba1:	89 04 24             	mov    %eax,(%esp)
f0103ba4:	e8 26 d8 ff ff       	call   f01013cf <page_remove>
    // find the pa and va of the page table
    pa = PTE_ADDR(e->env_pgdir[pdeno]);
    pt = (pte_t*)KADDR(pa);

    // unmap all PTEs in this page table
    for (pteno = 0; pteno <= PTX(~0); pteno++)
f0103ba9:	83 c3 01             	add    $0x1,%ebx
f0103bac:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103bb2:	75 d4                	jne    f0103b88 <env_free+0xbc>
      if (pt[pteno] & PTE_P)
        page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));

    // free the page table itself
    e->env_pgdir[pdeno] = 0;
f0103bb4:	8b 47 60             	mov    0x60(%edi),%eax
f0103bb7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103bba:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103bc1:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103bc4:	3b 05 88 ce 20 f0    	cmp    0xf020ce88,%eax
f0103bca:	72 1c                	jb     f0103be8 <env_free+0x11c>
		panic("pa2page called with invalid pa");
f0103bcc:	c7 44 24 08 74 79 10 	movl   $0xf0107974,0x8(%esp)
f0103bd3:	f0 
f0103bd4:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103bdb:	00 
f0103bdc:	c7 04 24 6b 75 10 f0 	movl   $0xf010756b,(%esp)
f0103be3:	e8 58 c4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103be8:	a1 90 ce 20 f0       	mov    0xf020ce90,%eax
f0103bed:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103bf0:	8d 04 d0             	lea    (%eax,%edx,8),%eax
    page_decref(pa2page(pa));
f0103bf3:	89 04 24             	mov    %eax,(%esp)
f0103bf6:	e8 aa d5 ff ff       	call   f01011a5 <page_decref>
  // Note the environment's demise.
  // cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

  // Flush all mapped pages in the user portion of the address space
  static_assert(UTOP % PTSIZE == 0);
  for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103bfb:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103bff:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103c06:	0f 85 1b ff ff ff    	jne    f0103b27 <env_free+0x5b>
    e->env_pgdir[pdeno] = 0;
    page_decref(pa2page(pa));
  }

  // free the page directory
  pa = PADDR(e->env_pgdir);
f0103c0c:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103c0f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103c14:	77 20                	ja     f0103c36 <env_free+0x16a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103c16:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c1a:	c7 44 24 08 c8 6f 10 	movl   $0xf0106fc8,0x8(%esp)
f0103c21:	f0 
f0103c22:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
f0103c29:	00 
f0103c2a:	c7 04 24 e3 81 10 f0 	movl   $0xf01081e3,(%esp)
f0103c31:	e8 0a c4 ff ff       	call   f0100040 <_panic>
  e->env_pgdir = 0;
f0103c36:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103c3d:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103c42:	c1 e8 0c             	shr    $0xc,%eax
f0103c45:	3b 05 88 ce 20 f0    	cmp    0xf020ce88,%eax
f0103c4b:	72 1c                	jb     f0103c69 <env_free+0x19d>
		panic("pa2page called with invalid pa");
f0103c4d:	c7 44 24 08 74 79 10 	movl   $0xf0107974,0x8(%esp)
f0103c54:	f0 
f0103c55:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103c5c:	00 
f0103c5d:	c7 04 24 6b 75 10 f0 	movl   $0xf010756b,(%esp)
f0103c64:	e8 d7 c3 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103c69:	8b 15 90 ce 20 f0    	mov    0xf020ce90,%edx
f0103c6f:	8d 04 c2             	lea    (%edx,%eax,8),%eax
  page_decref(pa2page(pa));
f0103c72:	89 04 24             	mov    %eax,(%esp)
f0103c75:	e8 2b d5 ff ff       	call   f01011a5 <page_decref>

  // return the environment to the free list
  e->env_status = ENV_FREE;
f0103c7a:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
  e->env_link = env_free_list;
f0103c81:	a1 4c c2 20 f0       	mov    0xf020c24c,%eax
f0103c86:	89 47 44             	mov    %eax,0x44(%edi)
  env_free_list = e;
f0103c89:	89 3d 4c c2 20 f0    	mov    %edi,0xf020c24c
}
f0103c8f:	83 c4 2c             	add    $0x2c,%esp
f0103c92:	5b                   	pop    %ebx
f0103c93:	5e                   	pop    %esi
f0103c94:	5f                   	pop    %edi
f0103c95:	5d                   	pop    %ebp
f0103c96:	c3                   	ret    

f0103c97 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103c97:	55                   	push   %ebp
f0103c98:	89 e5                	mov    %esp,%ebp
f0103c9a:	53                   	push   %ebx
f0103c9b:	83 ec 14             	sub    $0x14,%esp
f0103c9e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  // If e is currently running on other CPUs, we change its state to
  // ENV_DYING. A zombie environment will be freed the next time
  // it traps to the kernel.
  if (e->env_status == ENV_RUNNING && curenv != e) {
f0103ca1:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103ca5:	75 19                	jne    f0103cc0 <env_destroy+0x29>
f0103ca7:	e8 ed 2b 00 00       	call   f0106899 <cpunum>
f0103cac:	6b c0 74             	imul   $0x74,%eax,%eax
f0103caf:	39 98 28 d0 20 f0    	cmp    %ebx,-0xfdf2fd8(%eax)
f0103cb5:	74 09                	je     f0103cc0 <env_destroy+0x29>
    e->env_status = ENV_DYING;
f0103cb7:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
    return;
f0103cbe:	eb 2f                	jmp    f0103cef <env_destroy+0x58>
  }

  env_free(e);
f0103cc0:	89 1c 24             	mov    %ebx,(%esp)
f0103cc3:	e8 04 fe ff ff       	call   f0103acc <env_free>

  if (curenv == e) {
f0103cc8:	e8 cc 2b 00 00       	call   f0106899 <cpunum>
f0103ccd:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cd0:	39 98 28 d0 20 f0    	cmp    %ebx,-0xfdf2fd8(%eax)
f0103cd6:	75 17                	jne    f0103cef <env_destroy+0x58>
    curenv = NULL;
f0103cd8:	e8 bc 2b 00 00       	call   f0106899 <cpunum>
f0103cdd:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ce0:	c7 80 28 d0 20 f0 00 	movl   $0x0,-0xfdf2fd8(%eax)
f0103ce7:	00 00 00 
    sched_yield();
f0103cea:	e8 df 11 00 00       	call   f0104ece <sched_yield>
  }
}
f0103cef:	83 c4 14             	add    $0x14,%esp
f0103cf2:	5b                   	pop    %ebx
f0103cf3:	5d                   	pop    %ebp
f0103cf4:	c3                   	ret    

f0103cf5 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103cf5:	55                   	push   %ebp
f0103cf6:	89 e5                	mov    %esp,%ebp
f0103cf8:	53                   	push   %ebx
f0103cf9:	83 ec 14             	sub    $0x14,%esp
  // Record the CPU we are running on for user-space debugging
  curenv->env_cpunum = cpunum();
f0103cfc:	e8 98 2b 00 00       	call   f0106899 <cpunum>
f0103d01:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d04:	8b 98 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%ebx
f0103d0a:	e8 8a 2b 00 00       	call   f0106899 <cpunum>
f0103d0f:	89 43 5c             	mov    %eax,0x5c(%ebx)

  __asm __volatile("movl %0,%%esp\n"
f0103d12:	8b 65 08             	mov    0x8(%ebp),%esp
f0103d15:	61                   	popa   
f0103d16:	07                   	pop    %es
f0103d17:	1f                   	pop    %ds
f0103d18:	83 c4 08             	add    $0x8,%esp
f0103d1b:	cf                   	iret   
                   "\tpopl %%es\n"
                   "\tpopl %%ds\n"
                   "\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
                   "\tiret"
                   : : "g" (tf) : "memory");
  panic("iret failed");        /* mostly to placate the compiler */
f0103d1c:	c7 44 24 08 2b 82 10 	movl   $0xf010822b,0x8(%esp)
f0103d23:	f0 
f0103d24:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
f0103d2b:	00 
f0103d2c:	c7 04 24 e3 81 10 f0 	movl   $0xf01081e3,(%esp)
f0103d33:	e8 08 c3 ff ff       	call   f0100040 <_panic>

f0103d38 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103d38:	55                   	push   %ebp
f0103d39:	89 e5                	mov    %esp,%ebp
f0103d3b:	53                   	push   %ebx
f0103d3c:	83 ec 14             	sub    $0x14,%esp
f0103d3f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  //	e->env_tf.  Go back through the code you wrote above
  //	and make sure you have set the relevant parts of
  //	e->env_tf to sensible values.

  // LAB 3: Your code here.
  if (curenv && curenv->env_status == ENV_RUNNING) {
f0103d42:	e8 52 2b 00 00       	call   f0106899 <cpunum>
f0103d47:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d4a:	83 b8 28 d0 20 f0 00 	cmpl   $0x0,-0xfdf2fd8(%eax)
f0103d51:	74 29                	je     f0103d7c <env_run+0x44>
f0103d53:	e8 41 2b 00 00       	call   f0106899 <cpunum>
f0103d58:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d5b:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0103d61:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103d65:	75 15                	jne    f0103d7c <env_run+0x44>
    curenv->env_status = ENV_RUNNABLE;
f0103d67:	e8 2d 2b 00 00       	call   f0106899 <cpunum>
f0103d6c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d6f:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0103d75:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
  }
  
  curenv = e;
f0103d7c:	e8 18 2b 00 00       	call   f0106899 <cpunum>
f0103d81:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d84:	89 98 28 d0 20 f0    	mov    %ebx,-0xfdf2fd8(%eax)
  curenv->env_status = ENV_RUNNING;
f0103d8a:	e8 0a 2b 00 00       	call   f0106899 <cpunum>
f0103d8f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d92:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0103d98:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
  curenv->env_runs++;
f0103d9f:	e8 f5 2a 00 00       	call   f0106899 <cpunum>
f0103da4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103da7:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0103dad:	83 40 58 01          	addl   $0x1,0x58(%eax)
  lcr3(PADDR(e->env_pgdir));
f0103db1:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103db4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103db9:	77 20                	ja     f0103ddb <env_run+0xa3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103dbb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103dbf:	c7 44 24 08 c8 6f 10 	movl   $0xf0106fc8,0x8(%esp)
f0103dc6:	f0 
f0103dc7:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
f0103dce:	00 
f0103dcf:	c7 04 24 e3 81 10 f0 	movl   $0xf01081e3,(%esp)
f0103dd6:	e8 65 c2 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103ddb:	05 00 00 00 10       	add    $0x10000000,%eax
f0103de0:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103de3:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0103dea:	e8 d4 2d 00 00       	call   f0106bc3 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103def:	f3 90                	pause  

  unlock_kernel();
  env_pop_tf(&(curenv->env_tf));
f0103df1:	e8 a3 2a 00 00       	call   f0106899 <cpunum>
f0103df6:	6b c0 74             	imul   $0x74,%eax,%eax
f0103df9:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0103dff:	89 04 24             	mov    %eax,(%esp)
f0103e02:	e8 ee fe ff ff       	call   f0103cf5 <env_pop_tf>

f0103e07 <mc146818_read>:

#include <kern/kclock.h>

unsigned
mc146818_read(unsigned reg)
{
f0103e07:	55                   	push   %ebp
f0103e08:	89 e5                	mov    %esp,%ebp
f0103e0a:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
  __asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e0e:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e13:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
  uint8_t data;
  __asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103e14:	b2 71                	mov    $0x71,%dl
f0103e16:	ec                   	in     (%dx),%al
  outb(IO_RTC, reg);
  return inb(IO_RTC+1);
f0103e17:	0f b6 c0             	movzbl %al,%eax
}
f0103e1a:	5d                   	pop    %ebp
f0103e1b:	c3                   	ret    

f0103e1c <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103e1c:	55                   	push   %ebp
f0103e1d:	89 e5                	mov    %esp,%ebp
f0103e1f:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
  __asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e23:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e28:	ee                   	out    %al,(%dx)
f0103e29:	b2 71                	mov    $0x71,%dl
f0103e2b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e2e:	ee                   	out    %al,(%dx)
  outb(IO_RTC, reg);
  outb(IO_RTC+1, datum);
}
f0103e2f:	5d                   	pop    %ebp
f0103e30:	c3                   	ret    

f0103e31 <irq_setmask_8259A>:
    irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103e31:	55                   	push   %ebp
f0103e32:	89 e5                	mov    %esp,%ebp
f0103e34:	56                   	push   %esi
f0103e35:	53                   	push   %ebx
f0103e36:	83 ec 10             	sub    $0x10,%esp
f0103e39:	8b 45 08             	mov    0x8(%ebp),%eax
  int i;

  irq_mask_8259A = mask;
f0103e3c:	66 a3 a8 13 12 f0    	mov    %ax,0xf01213a8
  if (!didinit)
f0103e42:	80 3d 50 c2 20 f0 00 	cmpb   $0x0,0xf020c250
f0103e49:	74 4e                	je     f0103e99 <irq_setmask_8259A+0x68>
f0103e4b:	89 c6                	mov    %eax,%esi
f0103e4d:	ba 21 00 00 00       	mov    $0x21,%edx
f0103e52:	ee                   	out    %al,(%dx)
    return;
  outb(IO_PIC1+1, (char)mask);
  outb(IO_PIC2+1, (char)(mask >> 8));
f0103e53:	66 c1 e8 08          	shr    $0x8,%ax
f0103e57:	b2 a1                	mov    $0xa1,%dl
f0103e59:	ee                   	out    %al,(%dx)
  cprintf("enabled interrupts:");
f0103e5a:	c7 04 24 37 82 10 f0 	movl   $0xf0108237,(%esp)
f0103e61:	e8 0a 01 00 00       	call   f0103f70 <cprintf>
  for (i = 0; i < 16; i++)
f0103e66:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (~mask & (1<<i))
f0103e6b:	0f b7 f6             	movzwl %si,%esi
f0103e6e:	f7 d6                	not    %esi
f0103e70:	0f a3 de             	bt     %ebx,%esi
f0103e73:	73 10                	jae    f0103e85 <irq_setmask_8259A+0x54>
      cprintf(" %d", i);
f0103e75:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e79:	c7 04 24 ff 86 10 f0 	movl   $0xf01086ff,(%esp)
f0103e80:	e8 eb 00 00 00       	call   f0103f70 <cprintf>
  if (!didinit)
    return;
  outb(IO_PIC1+1, (char)mask);
  outb(IO_PIC2+1, (char)(mask >> 8));
  cprintf("enabled interrupts:");
  for (i = 0; i < 16; i++)
f0103e85:	83 c3 01             	add    $0x1,%ebx
f0103e88:	83 fb 10             	cmp    $0x10,%ebx
f0103e8b:	75 e3                	jne    f0103e70 <irq_setmask_8259A+0x3f>
    if (~mask & (1<<i))
      cprintf(" %d", i);
  cprintf("\n");
f0103e8d:	c7 04 24 5d 78 10 f0 	movl   $0xf010785d,(%esp)
f0103e94:	e8 d7 00 00 00       	call   f0103f70 <cprintf>
}
f0103e99:	83 c4 10             	add    $0x10,%esp
f0103e9c:	5b                   	pop    %ebx
f0103e9d:	5e                   	pop    %esi
f0103e9e:	5d                   	pop    %ebp
f0103e9f:	c3                   	ret    

f0103ea0 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
  didinit = 1;
f0103ea0:	c6 05 50 c2 20 f0 01 	movb   $0x1,0xf020c250
f0103ea7:	ba 21 00 00 00       	mov    $0x21,%edx
f0103eac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103eb1:	ee                   	out    %al,(%dx)
f0103eb2:	b2 a1                	mov    $0xa1,%dl
f0103eb4:	ee                   	out    %al,(%dx)
f0103eb5:	b2 20                	mov    $0x20,%dl
f0103eb7:	b8 11 00 00 00       	mov    $0x11,%eax
f0103ebc:	ee                   	out    %al,(%dx)
f0103ebd:	b2 21                	mov    $0x21,%dl
f0103ebf:	b8 20 00 00 00       	mov    $0x20,%eax
f0103ec4:	ee                   	out    %al,(%dx)
f0103ec5:	b8 04 00 00 00       	mov    $0x4,%eax
f0103eca:	ee                   	out    %al,(%dx)
f0103ecb:	b8 03 00 00 00       	mov    $0x3,%eax
f0103ed0:	ee                   	out    %al,(%dx)
f0103ed1:	b2 a0                	mov    $0xa0,%dl
f0103ed3:	b8 11 00 00 00       	mov    $0x11,%eax
f0103ed8:	ee                   	out    %al,(%dx)
f0103ed9:	b2 a1                	mov    $0xa1,%dl
f0103edb:	b8 28 00 00 00       	mov    $0x28,%eax
f0103ee0:	ee                   	out    %al,(%dx)
f0103ee1:	b8 02 00 00 00       	mov    $0x2,%eax
f0103ee6:	ee                   	out    %al,(%dx)
f0103ee7:	b8 01 00 00 00       	mov    $0x1,%eax
f0103eec:	ee                   	out    %al,(%dx)
f0103eed:	b2 20                	mov    $0x20,%dl
f0103eef:	b8 68 00 00 00       	mov    $0x68,%eax
f0103ef4:	ee                   	out    %al,(%dx)
f0103ef5:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103efa:	ee                   	out    %al,(%dx)
f0103efb:	b2 a0                	mov    $0xa0,%dl
f0103efd:	b8 68 00 00 00       	mov    $0x68,%eax
f0103f02:	ee                   	out    %al,(%dx)
f0103f03:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103f08:	ee                   	out    %al,(%dx)
  outb(IO_PIC1, 0x0a);                    /* read IRR by default */

  outb(IO_PIC2, 0x68);                    /* OCW3 */
  outb(IO_PIC2, 0x0a);                    /* OCW3 */

  if (irq_mask_8259A != 0xFFFF)
f0103f09:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f0103f10:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103f14:	74 12                	je     f0103f28 <pic_init+0x88>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103f16:	55                   	push   %ebp
f0103f17:	89 e5                	mov    %esp,%ebp
f0103f19:	83 ec 18             	sub    $0x18,%esp

  outb(IO_PIC2, 0x68);                    /* OCW3 */
  outb(IO_PIC2, 0x0a);                    /* OCW3 */

  if (irq_mask_8259A != 0xFFFF)
    irq_setmask_8259A(irq_mask_8259A);
f0103f1c:	0f b7 c0             	movzwl %ax,%eax
f0103f1f:	89 04 24             	mov    %eax,(%esp)
f0103f22:	e8 0a ff ff ff       	call   f0103e31 <irq_setmask_8259A>
}
f0103f27:	c9                   	leave  
f0103f28:	f3 c3                	repz ret 

f0103f2a <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103f2a:	55                   	push   %ebp
f0103f2b:	89 e5                	mov    %esp,%ebp
f0103f2d:	83 ec 18             	sub    $0x18,%esp
  cputchar(ch);
f0103f30:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f33:	89 04 24             	mov    %eax,(%esp)
f0103f36:	e8 7c c8 ff ff       	call   f01007b7 <cputchar>
  *cnt++;
}
f0103f3b:	c9                   	leave  
f0103f3c:	c3                   	ret    

f0103f3d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103f3d:	55                   	push   %ebp
f0103f3e:	89 e5                	mov    %esp,%ebp
f0103f40:	83 ec 28             	sub    $0x28,%esp
  int cnt = 0;
f0103f43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  vprintfmt((void*)putch, &cnt, fmt, ap);
f0103f4a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f4d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f51:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f54:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f58:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103f5b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f5f:	c7 04 24 2a 3f 10 f0 	movl   $0xf0103f2a,(%esp)
f0103f66:	e8 13 1c 00 00       	call   f0105b7e <vprintfmt>
  return cnt;
}
f0103f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103f6e:	c9                   	leave  
f0103f6f:	c3                   	ret    

f0103f70 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103f70:	55                   	push   %ebp
f0103f71:	89 e5                	mov    %esp,%ebp
f0103f73:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int cnt;

  va_start(ap, fmt);
f0103f76:	8d 45 0c             	lea    0xc(%ebp),%eax
  cnt = vcprintf(fmt, ap);
f0103f79:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f7d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f80:	89 04 24             	mov    %eax,(%esp)
f0103f83:	e8 b5 ff ff ff       	call   f0103f3d <vcprintf>
  va_end(ap);

  return cnt;
}
f0103f88:	c9                   	leave  
f0103f89:	c3                   	ret    
f0103f8a:	66 90                	xchg   %ax,%ax
f0103f8c:	66 90                	xchg   %ax,%ax
f0103f8e:	66 90                	xchg   %ax,%ax

f0103f90 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103f90:	55                   	push   %ebp
f0103f91:	89 e5                	mov    %esp,%ebp
f0103f93:	57                   	push   %edi
f0103f94:	56                   	push   %esi
f0103f95:	53                   	push   %ebx
f0103f96:	83 ec 0c             	sub    $0xc,%esp
  //
  // LAB 4: Your code here:

  // Setup a TSS so that we get the right stack
  // when we trap to the kernel.
  thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - thiscpu->cpu_id * (KSTKSIZE + KSTKGAP);
f0103f99:	e8 fb 28 00 00       	call   f0106899 <cpunum>
f0103f9e:	89 c3                	mov    %eax,%ebx
f0103fa0:	e8 f4 28 00 00       	call   f0106899 <cpunum>
f0103fa5:	6b db 74             	imul   $0x74,%ebx,%ebx
f0103fa8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fab:	0f b6 80 20 d0 20 f0 	movzbl -0xfdf2fe0(%eax),%eax
f0103fb2:	f7 d8                	neg    %eax
f0103fb4:	c1 e0 10             	shl    $0x10,%eax
f0103fb7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103fbc:	89 83 30 d0 20 f0    	mov    %eax,-0xfdf2fd0(%ebx)
  thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103fc2:	e8 d2 28 00 00       	call   f0106899 <cpunum>
f0103fc7:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fca:	66 c7 80 34 d0 20 f0 	movw   $0x10,-0xfdf2fcc(%eax)
f0103fd1:	10 00 

  // Initialize the TSS slot of the gdt.
  gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id] = SEG16(STS_T32A, (uint32_t)(&thiscpu->cpu_ts),
f0103fd3:	e8 c1 28 00 00       	call   f0106899 <cpunum>
f0103fd8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fdb:	0f b6 98 20 d0 20 f0 	movzbl -0xfdf2fe0(%eax),%ebx
f0103fe2:	83 c3 05             	add    $0x5,%ebx
f0103fe5:	e8 af 28 00 00       	call   f0106899 <cpunum>
f0103fea:	89 c7                	mov    %eax,%edi
f0103fec:	e8 a8 28 00 00       	call   f0106899 <cpunum>
f0103ff1:	89 c6                	mov    %eax,%esi
f0103ff3:	e8 a1 28 00 00       	call   f0106899 <cpunum>
f0103ff8:	66 c7 04 dd 40 13 12 	movw   $0x67,-0xfedecc0(,%ebx,8)
f0103fff:	f0 67 00 
f0104002:	6b ff 74             	imul   $0x74,%edi,%edi
f0104005:	81 c7 2c d0 20 f0    	add    $0xf020d02c,%edi
f010400b:	66 89 3c dd 42 13 12 	mov    %di,-0xfedecbe(,%ebx,8)
f0104012:	f0 
f0104013:	6b d6 74             	imul   $0x74,%esi,%edx
f0104016:	81 c2 2c d0 20 f0    	add    $0xf020d02c,%edx
f010401c:	c1 ea 10             	shr    $0x10,%edx
f010401f:	88 14 dd 44 13 12 f0 	mov    %dl,-0xfedecbc(,%ebx,8)
f0104026:	c6 04 dd 45 13 12 f0 	movb   $0x99,-0xfedecbb(,%ebx,8)
f010402d:	99 
f010402e:	c6 04 dd 46 13 12 f0 	movb   $0x40,-0xfedecba(,%ebx,8)
f0104035:	40 
f0104036:	6b c0 74             	imul   $0x74,%eax,%eax
f0104039:	05 2c d0 20 f0       	add    $0xf020d02c,%eax
f010403e:	c1 e8 18             	shr    $0x18,%eax
f0104041:	88 04 dd 47 13 12 f0 	mov    %al,-0xfedecb9(,%ebx,8)
                            sizeof(struct Taskstate) - 1, 0);
  gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id].sd_s = 0;
f0104048:	e8 4c 28 00 00       	call   f0106899 <cpunum>
f010404d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104050:	0f b6 80 20 d0 20 f0 	movzbl -0xfdf2fe0(%eax),%eax
f0104057:	80 24 c5 6d 13 12 f0 	andb   $0xef,-0xfedec93(,%eax,8)
f010405e:	ef 

  // Load the TSS selector (like other segment selectors, the
  // bottom three bits are special; we leave them 0)
  ltr(GD_TSS0 + (thiscpu->cpu_id << 3));
f010405f:	e8 35 28 00 00       	call   f0106899 <cpunum>
f0104064:	6b c0 74             	imul   $0x74,%eax,%eax
f0104067:	0f b6 80 20 d0 20 f0 	movzbl -0xfdf2fe0(%eax),%eax
f010406e:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
}

static __inline void
ltr(uint16_t sel)
{
  __asm __volatile("ltr %0" : : "r" (sel));
f0104075:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
  __asm __volatile("lidt (%0)" : : "r" (p));
f0104078:	b8 aa 13 12 f0       	mov    $0xf01213aa,%eax
f010407d:	0f 01 18             	lidtl  (%eax)

  // Load the IDT
  lidt(&idt_pd);
}
f0104080:	83 c4 0c             	add    $0xc,%esp
f0104083:	5b                   	pop    %ebx
f0104084:	5e                   	pop    %esi
f0104085:	5f                   	pop    %edi
f0104086:	5d                   	pop    %ebp
f0104087:	c3                   	ret    

f0104088 <trap_init>:
}


void
trap_init(void)
{
f0104088:	55                   	push   %ebp
f0104089:	89 e5                	mov    %esp,%ebp
f010408b:	83 ec 08             	sub    $0x8,%esp
  extern void IRQ_15();
  extern void IRQ_TIMER_();
  extern void IRQ_KDB_();
  extern void IRQ_SERIAL_();

  SETGATE(idt[T_DIVIDE],  0, GD_KT, TRAP_DIVIDE,  0);
f010408e:	b8 be 4c 10 f0       	mov    $0xf0104cbe,%eax
f0104093:	66 a3 60 c2 20 f0    	mov    %ax,0xf020c260
f0104099:	66 c7 05 62 c2 20 f0 	movw   $0x8,0xf020c262
f01040a0:	08 00 
f01040a2:	c6 05 64 c2 20 f0 00 	movb   $0x0,0xf020c264
f01040a9:	c6 05 65 c2 20 f0 8e 	movb   $0x8e,0xf020c265
f01040b0:	c1 e8 10             	shr    $0x10,%eax
f01040b3:	66 a3 66 c2 20 f0    	mov    %ax,0xf020c266
  SETGATE(idt[T_DEBUG],   0, GD_KT, TRAP_DEBUG,   0);
f01040b9:	b8 c8 4c 10 f0       	mov    $0xf0104cc8,%eax
f01040be:	66 a3 68 c2 20 f0    	mov    %ax,0xf020c268
f01040c4:	66 c7 05 6a c2 20 f0 	movw   $0x8,0xf020c26a
f01040cb:	08 00 
f01040cd:	c6 05 6c c2 20 f0 00 	movb   $0x0,0xf020c26c
f01040d4:	c6 05 6d c2 20 f0 8e 	movb   $0x8e,0xf020c26d
f01040db:	c1 e8 10             	shr    $0x10,%eax
f01040de:	66 a3 6e c2 20 f0    	mov    %ax,0xf020c26e
  SETGATE(idt[T_BRKPT],   0, GD_KT, TRAP_BRKPT,   3);
f01040e4:	b8 d2 4c 10 f0       	mov    $0xf0104cd2,%eax
f01040e9:	66 a3 78 c2 20 f0    	mov    %ax,0xf020c278
f01040ef:	66 c7 05 7a c2 20 f0 	movw   $0x8,0xf020c27a
f01040f6:	08 00 
f01040f8:	c6 05 7c c2 20 f0 00 	movb   $0x0,0xf020c27c
f01040ff:	c6 05 7d c2 20 f0 ee 	movb   $0xee,0xf020c27d
f0104106:	c1 e8 10             	shr    $0x10,%eax
f0104109:	66 a3 7e c2 20 f0    	mov    %ax,0xf020c27e
  SETGATE(idt[T_OFLOW],   0, GD_KT, TRAP_OFLOW,   0);
f010410f:	b8 dc 4c 10 f0       	mov    $0xf0104cdc,%eax
f0104114:	66 a3 80 c2 20 f0    	mov    %ax,0xf020c280
f010411a:	66 c7 05 82 c2 20 f0 	movw   $0x8,0xf020c282
f0104121:	08 00 
f0104123:	c6 05 84 c2 20 f0 00 	movb   $0x0,0xf020c284
f010412a:	c6 05 85 c2 20 f0 8e 	movb   $0x8e,0xf020c285
f0104131:	c1 e8 10             	shr    $0x10,%eax
f0104134:	66 a3 86 c2 20 f0    	mov    %ax,0xf020c286
  SETGATE(idt[T_BOUND],   0, GD_KT, TRAP_BOUND,   0);
f010413a:	b8 e6 4c 10 f0       	mov    $0xf0104ce6,%eax
f010413f:	66 a3 88 c2 20 f0    	mov    %ax,0xf020c288
f0104145:	66 c7 05 8a c2 20 f0 	movw   $0x8,0xf020c28a
f010414c:	08 00 
f010414e:	c6 05 8c c2 20 f0 00 	movb   $0x0,0xf020c28c
f0104155:	c6 05 8d c2 20 f0 8e 	movb   $0x8e,0xf020c28d
f010415c:	c1 e8 10             	shr    $0x10,%eax
f010415f:	66 a3 8e c2 20 f0    	mov    %ax,0xf020c28e
  SETGATE(idt[T_ILLOP],   0, GD_KT, TRAP_ILLOP,   0);
f0104165:	b8 f0 4c 10 f0       	mov    $0xf0104cf0,%eax
f010416a:	66 a3 90 c2 20 f0    	mov    %ax,0xf020c290
f0104170:	66 c7 05 92 c2 20 f0 	movw   $0x8,0xf020c292
f0104177:	08 00 
f0104179:	c6 05 94 c2 20 f0 00 	movb   $0x0,0xf020c294
f0104180:	c6 05 95 c2 20 f0 8e 	movb   $0x8e,0xf020c295
f0104187:	c1 e8 10             	shr    $0x10,%eax
f010418a:	66 a3 96 c2 20 f0    	mov    %ax,0xf020c296
  SETGATE(idt[T_DEVICE],  0, GD_KT, TRAP_DEVICE,  0);
f0104190:	b8 fa 4c 10 f0       	mov    $0xf0104cfa,%eax
f0104195:	66 a3 98 c2 20 f0    	mov    %ax,0xf020c298
f010419b:	66 c7 05 9a c2 20 f0 	movw   $0x8,0xf020c29a
f01041a2:	08 00 
f01041a4:	c6 05 9c c2 20 f0 00 	movb   $0x0,0xf020c29c
f01041ab:	c6 05 9d c2 20 f0 8e 	movb   $0x8e,0xf020c29d
f01041b2:	c1 e8 10             	shr    $0x10,%eax
f01041b5:	66 a3 9e c2 20 f0    	mov    %ax,0xf020c29e
  SETGATE(idt[T_DBLFLT],  0, GD_KT, TRAP_DBLFLT,  0);
f01041bb:	b8 04 4d 10 f0       	mov    $0xf0104d04,%eax
f01041c0:	66 a3 a0 c2 20 f0    	mov    %ax,0xf020c2a0
f01041c6:	66 c7 05 a2 c2 20 f0 	movw   $0x8,0xf020c2a2
f01041cd:	08 00 
f01041cf:	c6 05 a4 c2 20 f0 00 	movb   $0x0,0xf020c2a4
f01041d6:	c6 05 a5 c2 20 f0 8e 	movb   $0x8e,0xf020c2a5
f01041dd:	c1 e8 10             	shr    $0x10,%eax
f01041e0:	66 a3 a6 c2 20 f0    	mov    %ax,0xf020c2a6
  SETGATE(idt[T_TSS],     0, GD_KT, TRAP_TSS,     0);
f01041e6:	b8 0c 4d 10 f0       	mov    $0xf0104d0c,%eax
f01041eb:	66 a3 b0 c2 20 f0    	mov    %ax,0xf020c2b0
f01041f1:	66 c7 05 b2 c2 20 f0 	movw   $0x8,0xf020c2b2
f01041f8:	08 00 
f01041fa:	c6 05 b4 c2 20 f0 00 	movb   $0x0,0xf020c2b4
f0104201:	c6 05 b5 c2 20 f0 8e 	movb   $0x8e,0xf020c2b5
f0104208:	c1 e8 10             	shr    $0x10,%eax
f010420b:	66 a3 b6 c2 20 f0    	mov    %ax,0xf020c2b6
  SETGATE(idt[T_SEGNP],   0, GD_KT, TRAP_SEGNP,   0);
f0104211:	b8 14 4d 10 f0       	mov    $0xf0104d14,%eax
f0104216:	66 a3 b8 c2 20 f0    	mov    %ax,0xf020c2b8
f010421c:	66 c7 05 ba c2 20 f0 	movw   $0x8,0xf020c2ba
f0104223:	08 00 
f0104225:	c6 05 bc c2 20 f0 00 	movb   $0x0,0xf020c2bc
f010422c:	c6 05 bd c2 20 f0 8e 	movb   $0x8e,0xf020c2bd
f0104233:	c1 e8 10             	shr    $0x10,%eax
f0104236:	66 a3 be c2 20 f0    	mov    %ax,0xf020c2be
  SETGATE(idt[T_STACK],   0, GD_KT, TRAP_STACK,   0);
f010423c:	b8 1c 4d 10 f0       	mov    $0xf0104d1c,%eax
f0104241:	66 a3 c0 c2 20 f0    	mov    %ax,0xf020c2c0
f0104247:	66 c7 05 c2 c2 20 f0 	movw   $0x8,0xf020c2c2
f010424e:	08 00 
f0104250:	c6 05 c4 c2 20 f0 00 	movb   $0x0,0xf020c2c4
f0104257:	c6 05 c5 c2 20 f0 8e 	movb   $0x8e,0xf020c2c5
f010425e:	c1 e8 10             	shr    $0x10,%eax
f0104261:	66 a3 c6 c2 20 f0    	mov    %ax,0xf020c2c6
  SETGATE(idt[T_GPFLT],   0, GD_KT, TRAP_GPFLT,   0);
f0104267:	b8 24 4d 10 f0       	mov    $0xf0104d24,%eax
f010426c:	66 a3 c8 c2 20 f0    	mov    %ax,0xf020c2c8
f0104272:	66 c7 05 ca c2 20 f0 	movw   $0x8,0xf020c2ca
f0104279:	08 00 
f010427b:	c6 05 cc c2 20 f0 00 	movb   $0x0,0xf020c2cc
f0104282:	c6 05 cd c2 20 f0 8e 	movb   $0x8e,0xf020c2cd
f0104289:	c1 e8 10             	shr    $0x10,%eax
f010428c:	66 a3 ce c2 20 f0    	mov    %ax,0xf020c2ce
  SETGATE(idt[T_PGFLT],   0, GD_KT, TRAP_PGFLT,   0);
f0104292:	b8 2c 4d 10 f0       	mov    $0xf0104d2c,%eax
f0104297:	66 a3 d0 c2 20 f0    	mov    %ax,0xf020c2d0
f010429d:	66 c7 05 d2 c2 20 f0 	movw   $0x8,0xf020c2d2
f01042a4:	08 00 
f01042a6:	c6 05 d4 c2 20 f0 00 	movb   $0x0,0xf020c2d4
f01042ad:	c6 05 d5 c2 20 f0 8e 	movb   $0x8e,0xf020c2d5
f01042b4:	c1 e8 10             	shr    $0x10,%eax
f01042b7:	66 a3 d6 c2 20 f0    	mov    %ax,0xf020c2d6
  SETGATE(idt[T_FPERR],   0, GD_KT, TRAP_FPERR,   0);
f01042bd:	b8 34 4d 10 f0       	mov    $0xf0104d34,%eax
f01042c2:	66 a3 e0 c2 20 f0    	mov    %ax,0xf020c2e0
f01042c8:	66 c7 05 e2 c2 20 f0 	movw   $0x8,0xf020c2e2
f01042cf:	08 00 
f01042d1:	c6 05 e4 c2 20 f0 00 	movb   $0x0,0xf020c2e4
f01042d8:	c6 05 e5 c2 20 f0 8e 	movb   $0x8e,0xf020c2e5
f01042df:	c1 e8 10             	shr    $0x10,%eax
f01042e2:	66 a3 e6 c2 20 f0    	mov    %ax,0xf020c2e6
  SETGATE(idt[T_SYSCALL], 0, GD_KT, TRAP_SYSCALL,  3);
f01042e8:	b8 3e 4d 10 f0       	mov    $0xf0104d3e,%eax
f01042ed:	66 a3 e0 c3 20 f0    	mov    %ax,0xf020c3e0
f01042f3:	66 c7 05 e2 c3 20 f0 	movw   $0x8,0xf020c3e2
f01042fa:	08 00 
f01042fc:	c6 05 e4 c3 20 f0 00 	movb   $0x0,0xf020c3e4
f0104303:	c6 05 e5 c3 20 f0 ee 	movb   $0xee,0xf020c3e5
f010430a:	c1 e8 10             	shr    $0x10,%eax
f010430d:	66 a3 e6 c3 20 f0    	mov    %ax,0xf020c3e6
  SETGATE(idt[T_NMI], 0, GD_KT, TRAP_NMI, 0);
f0104313:	b8 48 4d 10 f0       	mov    $0xf0104d48,%eax
f0104318:	66 a3 70 c2 20 f0    	mov    %ax,0xf020c270
f010431e:	66 c7 05 72 c2 20 f0 	movw   $0x8,0xf020c272
f0104325:	08 00 
f0104327:	c6 05 74 c2 20 f0 00 	movb   $0x0,0xf020c274
f010432e:	c6 05 75 c2 20 f0 8e 	movb   $0x8e,0xf020c275
f0104335:	c1 e8 10             	shr    $0x10,%eax
f0104338:	66 a3 76 c2 20 f0    	mov    %ax,0xf020c276
  SETGATE(idt[T_ALIGN], 0, GD_KT, TRAP_ALIGN, 0);
f010433e:	b8 52 4d 10 f0       	mov    $0xf0104d52,%eax
f0104343:	66 a3 e8 c2 20 f0    	mov    %ax,0xf020c2e8
f0104349:	66 c7 05 ea c2 20 f0 	movw   $0x8,0xf020c2ea
f0104350:	08 00 
f0104352:	c6 05 ec c2 20 f0 00 	movb   $0x0,0xf020c2ec
f0104359:	c6 05 ed c2 20 f0 8e 	movb   $0x8e,0xf020c2ed
f0104360:	c1 e8 10             	shr    $0x10,%eax
f0104363:	66 a3 ee c2 20 f0    	mov    %ax,0xf020c2ee
  SETGATE(idt[T_MCHK], 0, GD_KT, TRAP_MCHK, 0);
f0104369:	b8 5a 4d 10 f0       	mov    $0xf0104d5a,%eax
f010436e:	66 a3 f0 c2 20 f0    	mov    %ax,0xf020c2f0
f0104374:	66 c7 05 f2 c2 20 f0 	movw   $0x8,0xf020c2f2
f010437b:	08 00 
f010437d:	c6 05 f4 c2 20 f0 00 	movb   $0x0,0xf020c2f4
f0104384:	c6 05 f5 c2 20 f0 8e 	movb   $0x8e,0xf020c2f5
f010438b:	c1 e8 10             	shr    $0x10,%eax
f010438e:	66 a3 f6 c2 20 f0    	mov    %ax,0xf020c2f6
  SETGATE(idt[T_SIMDERR], 0, GD_KT, TRAP_SIMDERR, 0);
f0104394:	b8 64 4d 10 f0       	mov    $0xf0104d64,%eax
f0104399:	66 a3 f8 c2 20 f0    	mov    %ax,0xf020c2f8
f010439f:	66 c7 05 fa c2 20 f0 	movw   $0x8,0xf020c2fa
f01043a6:	08 00 
f01043a8:	c6 05 fc c2 20 f0 00 	movb   $0x0,0xf020c2fc
f01043af:	c6 05 fd c2 20 f0 8e 	movb   $0x8e,0xf020c2fd
f01043b6:	c1 e8 10             	shr    $0x10,%eax
f01043b9:	66 a3 fe c2 20 f0    	mov    %ax,0xf020c2fe
  SETGATE(idt[T_DEFAULT], 0, GD_KT, TRAP_DEFAULT, 0);
f01043bf:	b8 6a 4d 10 f0       	mov    $0xf0104d6a,%eax
f01043c4:	66 a3 00 d2 20 f0    	mov    %ax,0xf020d200
f01043ca:	66 c7 05 02 d2 20 f0 	movw   $0x8,0xf020d202
f01043d1:	08 00 
f01043d3:	c6 05 04 d2 20 f0 00 	movb   $0x0,0xf020d204
f01043da:	c6 05 05 d2 20 f0 8e 	movb   $0x8e,0xf020d205
f01043e1:	c1 e8 10             	shr    $0x10,%eax
f01043e4:	66 a3 06 d2 20 f0    	mov    %ax,0xf020d206
  SETGATE(idt[IRQ_OFFSET + 0], 0, GD_KT, IRQ_0, 0);
f01043ea:	66 c7 05 62 c3 20 f0 	movw   $0x8,0xf020c362
f01043f1:	08 00 
f01043f3:	c6 05 64 c3 20 f0 00 	movb   $0x0,0xf020c364
f01043fa:	c6 05 65 c3 20 f0 8e 	movb   $0x8e,0xf020c365
  SETGATE(idt[IRQ_OFFSET + 1], 0, GD_KT, IRQ_1, 0);
f0104401:	66 c7 05 6a c3 20 f0 	movw   $0x8,0xf020c36a
f0104408:	08 00 
f010440a:	c6 05 6c c3 20 f0 00 	movb   $0x0,0xf020c36c
f0104411:	c6 05 6d c3 20 f0 8e 	movb   $0x8e,0xf020c36d
  SETGATE(idt[IRQ_OFFSET + 2], 0, GD_KT, IRQ_2, 0);
f0104418:	b8 80 4d 10 f0       	mov    $0xf0104d80,%eax
f010441d:	66 a3 70 c3 20 f0    	mov    %ax,0xf020c370
f0104423:	66 c7 05 72 c3 20 f0 	movw   $0x8,0xf020c372
f010442a:	08 00 
f010442c:	c6 05 74 c3 20 f0 00 	movb   $0x0,0xf020c374
f0104433:	c6 05 75 c3 20 f0 8e 	movb   $0x8e,0xf020c375
f010443a:	c1 e8 10             	shr    $0x10,%eax
f010443d:	66 a3 76 c3 20 f0    	mov    %ax,0xf020c376
  SETGATE(idt[IRQ_OFFSET + 3], 0, GD_KT, IRQ_3, 0);
f0104443:	b8 86 4d 10 f0       	mov    $0xf0104d86,%eax
f0104448:	66 a3 78 c3 20 f0    	mov    %ax,0xf020c378
f010444e:	66 c7 05 7a c3 20 f0 	movw   $0x8,0xf020c37a
f0104455:	08 00 
f0104457:	c6 05 7c c3 20 f0 00 	movb   $0x0,0xf020c37c
f010445e:	c6 05 7d c3 20 f0 8e 	movb   $0x8e,0xf020c37d
f0104465:	c1 e8 10             	shr    $0x10,%eax
f0104468:	66 a3 7e c3 20 f0    	mov    %ax,0xf020c37e
  SETGATE(idt[IRQ_OFFSET + 4], 0, GD_KT, IRQ_4, 0);
f010446e:	66 c7 05 82 c3 20 f0 	movw   $0x8,0xf020c382
f0104475:	08 00 
f0104477:	c6 05 84 c3 20 f0 00 	movb   $0x0,0xf020c384
f010447e:	c6 05 85 c3 20 f0 8e 	movb   $0x8e,0xf020c385
  SETGATE(idt[IRQ_OFFSET + 5], 0, GD_KT, IRQ_5, 0);
f0104485:	b8 92 4d 10 f0       	mov    $0xf0104d92,%eax
f010448a:	66 a3 88 c3 20 f0    	mov    %ax,0xf020c388
f0104490:	66 c7 05 8a c3 20 f0 	movw   $0x8,0xf020c38a
f0104497:	08 00 
f0104499:	c6 05 8c c3 20 f0 00 	movb   $0x0,0xf020c38c
f01044a0:	c6 05 8d c3 20 f0 8e 	movb   $0x8e,0xf020c38d
f01044a7:	c1 e8 10             	shr    $0x10,%eax
f01044aa:	66 a3 8e c3 20 f0    	mov    %ax,0xf020c38e
  SETGATE(idt[IRQ_OFFSET + 6], 0, GD_KT, IRQ_6, 0);
f01044b0:	b8 98 4d 10 f0       	mov    $0xf0104d98,%eax
f01044b5:	66 a3 90 c3 20 f0    	mov    %ax,0xf020c390
f01044bb:	66 c7 05 92 c3 20 f0 	movw   $0x8,0xf020c392
f01044c2:	08 00 
f01044c4:	c6 05 94 c3 20 f0 00 	movb   $0x0,0xf020c394
f01044cb:	c6 05 95 c3 20 f0 8e 	movb   $0x8e,0xf020c395
f01044d2:	c1 e8 10             	shr    $0x10,%eax
f01044d5:	66 a3 96 c3 20 f0    	mov    %ax,0xf020c396
  SETGATE(idt[IRQ_OFFSET + 7], 0, GD_KT, IRQ_7, 0);
f01044db:	b8 9e 4d 10 f0       	mov    $0xf0104d9e,%eax
f01044e0:	66 a3 98 c3 20 f0    	mov    %ax,0xf020c398
f01044e6:	66 c7 05 9a c3 20 f0 	movw   $0x8,0xf020c39a
f01044ed:	08 00 
f01044ef:	c6 05 9c c3 20 f0 00 	movb   $0x0,0xf020c39c
f01044f6:	c6 05 9d c3 20 f0 8e 	movb   $0x8e,0xf020c39d
f01044fd:	c1 e8 10             	shr    $0x10,%eax
f0104500:	66 a3 9e c3 20 f0    	mov    %ax,0xf020c39e
  SETGATE(idt[IRQ_OFFSET + 8], 0, GD_KT, IRQ_8, 0);
f0104506:	b8 a4 4d 10 f0       	mov    $0xf0104da4,%eax
f010450b:	66 a3 a0 c3 20 f0    	mov    %ax,0xf020c3a0
f0104511:	66 c7 05 a2 c3 20 f0 	movw   $0x8,0xf020c3a2
f0104518:	08 00 
f010451a:	c6 05 a4 c3 20 f0 00 	movb   $0x0,0xf020c3a4
f0104521:	c6 05 a5 c3 20 f0 8e 	movb   $0x8e,0xf020c3a5
f0104528:	c1 e8 10             	shr    $0x10,%eax
f010452b:	66 a3 a6 c3 20 f0    	mov    %ax,0xf020c3a6
  SETGATE(idt[IRQ_OFFSET + 9], 0, GD_KT, IRQ_9, 0);
f0104531:	b8 aa 4d 10 f0       	mov    $0xf0104daa,%eax
f0104536:	66 a3 a8 c3 20 f0    	mov    %ax,0xf020c3a8
f010453c:	66 c7 05 aa c3 20 f0 	movw   $0x8,0xf020c3aa
f0104543:	08 00 
f0104545:	c6 05 ac c3 20 f0 00 	movb   $0x0,0xf020c3ac
f010454c:	c6 05 ad c3 20 f0 8e 	movb   $0x8e,0xf020c3ad
f0104553:	c1 e8 10             	shr    $0x10,%eax
f0104556:	66 a3 ae c3 20 f0    	mov    %ax,0xf020c3ae
  SETGATE(idt[IRQ_OFFSET + 10], 0, GD_KT, IRQ_10, 0);
f010455c:	b8 b0 4d 10 f0       	mov    $0xf0104db0,%eax
f0104561:	66 a3 b0 c3 20 f0    	mov    %ax,0xf020c3b0
f0104567:	66 c7 05 b2 c3 20 f0 	movw   $0x8,0xf020c3b2
f010456e:	08 00 
f0104570:	c6 05 b4 c3 20 f0 00 	movb   $0x0,0xf020c3b4
f0104577:	c6 05 b5 c3 20 f0 8e 	movb   $0x8e,0xf020c3b5
f010457e:	c1 e8 10             	shr    $0x10,%eax
f0104581:	66 a3 b6 c3 20 f0    	mov    %ax,0xf020c3b6
  SETGATE(idt[IRQ_OFFSET + 11], 0, GD_KT, IRQ_11, 0);
f0104587:	b8 b6 4d 10 f0       	mov    $0xf0104db6,%eax
f010458c:	66 a3 b8 c3 20 f0    	mov    %ax,0xf020c3b8
f0104592:	66 c7 05 ba c3 20 f0 	movw   $0x8,0xf020c3ba
f0104599:	08 00 
f010459b:	c6 05 bc c3 20 f0 00 	movb   $0x0,0xf020c3bc
f01045a2:	c6 05 bd c3 20 f0 8e 	movb   $0x8e,0xf020c3bd
f01045a9:	c1 e8 10             	shr    $0x10,%eax
f01045ac:	66 a3 be c3 20 f0    	mov    %ax,0xf020c3be
  SETGATE(idt[IRQ_OFFSET + 12], 0, GD_KT, IRQ_12, 0);
f01045b2:	b8 bc 4d 10 f0       	mov    $0xf0104dbc,%eax
f01045b7:	66 a3 c0 c3 20 f0    	mov    %ax,0xf020c3c0
f01045bd:	66 c7 05 c2 c3 20 f0 	movw   $0x8,0xf020c3c2
f01045c4:	08 00 
f01045c6:	c6 05 c4 c3 20 f0 00 	movb   $0x0,0xf020c3c4
f01045cd:	c6 05 c5 c3 20 f0 8e 	movb   $0x8e,0xf020c3c5
f01045d4:	c1 e8 10             	shr    $0x10,%eax
f01045d7:	66 a3 c6 c3 20 f0    	mov    %ax,0xf020c3c6
  SETGATE(idt[IRQ_OFFSET + 13], 0, GD_KT, IRQ_13, 0);
f01045dd:	b8 c2 4d 10 f0       	mov    $0xf0104dc2,%eax
f01045e2:	66 a3 c8 c3 20 f0    	mov    %ax,0xf020c3c8
f01045e8:	66 c7 05 ca c3 20 f0 	movw   $0x8,0xf020c3ca
f01045ef:	08 00 
f01045f1:	c6 05 cc c3 20 f0 00 	movb   $0x0,0xf020c3cc
f01045f8:	c6 05 cd c3 20 f0 8e 	movb   $0x8e,0xf020c3cd
f01045ff:	c1 e8 10             	shr    $0x10,%eax
f0104602:	66 a3 ce c3 20 f0    	mov    %ax,0xf020c3ce
  SETGATE(idt[IRQ_OFFSET + 14], 0, GD_KT, IRQ_14, 0);
f0104608:	b8 c8 4d 10 f0       	mov    $0xf0104dc8,%eax
f010460d:	66 a3 d0 c3 20 f0    	mov    %ax,0xf020c3d0
f0104613:	66 c7 05 d2 c3 20 f0 	movw   $0x8,0xf020c3d2
f010461a:	08 00 
f010461c:	c6 05 d4 c3 20 f0 00 	movb   $0x0,0xf020c3d4
f0104623:	c6 05 d5 c3 20 f0 8e 	movb   $0x8e,0xf020c3d5
f010462a:	c1 e8 10             	shr    $0x10,%eax
f010462d:	66 a3 d6 c3 20 f0    	mov    %ax,0xf020c3d6
  SETGATE(idt[IRQ_OFFSET + 15], 0, GD_KT, IRQ_15, 0);
f0104633:	b8 ce 4d 10 f0       	mov    $0xf0104dce,%eax
f0104638:	66 a3 d8 c3 20 f0    	mov    %ax,0xf020c3d8
f010463e:	66 c7 05 da c3 20 f0 	movw   $0x8,0xf020c3da
f0104645:	08 00 
f0104647:	c6 05 dc c3 20 f0 00 	movb   $0x0,0xf020c3dc
f010464e:	c6 05 dd c3 20 f0 8e 	movb   $0x8e,0xf020c3dd
f0104655:	c1 e8 10             	shr    $0x10,%eax
f0104658:	66 a3 de c3 20 f0    	mov    %ax,0xf020c3de
  SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, IRQ_TIMER_, 0);
f010465e:	b8 d4 4d 10 f0       	mov    $0xf0104dd4,%eax
f0104663:	66 a3 60 c3 20 f0    	mov    %ax,0xf020c360
f0104669:	c1 e8 10             	shr    $0x10,%eax
f010466c:	66 a3 66 c3 20 f0    	mov    %ax,0xf020c366
  SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, IRQ_KDB_, 0);
f0104672:	b8 da 4d 10 f0       	mov    $0xf0104dda,%eax
f0104677:	66 a3 68 c3 20 f0    	mov    %ax,0xf020c368
f010467d:	c1 e8 10             	shr    $0x10,%eax
f0104680:	66 a3 6e c3 20 f0    	mov    %ax,0xf020c36e
  SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, IRQ_SERIAL_, 0);
f0104686:	b8 e0 4d 10 f0       	mov    $0xf0104de0,%eax
f010468b:	66 a3 80 c3 20 f0    	mov    %ax,0xf020c380
f0104691:	c1 e8 10             	shr    $0x10,%eax
f0104694:	66 a3 86 c3 20 f0    	mov    %ax,0xf020c386

  // Per-CPU setup
  trap_init_percpu();
f010469a:	e8 f1 f8 ff ff       	call   f0103f90 <trap_init_percpu>
}
f010469f:	c9                   	leave  
f01046a0:	c3                   	ret    

f01046a1 <print_regs>:
  }
}

void
print_regs(struct PushRegs *regs)
{
f01046a1:	55                   	push   %ebp
f01046a2:	89 e5                	mov    %esp,%ebp
f01046a4:	53                   	push   %ebx
f01046a5:	83 ec 14             	sub    $0x14,%esp
f01046a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  cprintf("  edi  0x%08x\n", regs->reg_edi);
f01046ab:	8b 03                	mov    (%ebx),%eax
f01046ad:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046b1:	c7 04 24 4b 82 10 f0 	movl   $0xf010824b,(%esp)
f01046b8:	e8 b3 f8 ff ff       	call   f0103f70 <cprintf>
  cprintf("  esi  0x%08x\n", regs->reg_esi);
f01046bd:	8b 43 04             	mov    0x4(%ebx),%eax
f01046c0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046c4:	c7 04 24 5a 82 10 f0 	movl   $0xf010825a,(%esp)
f01046cb:	e8 a0 f8 ff ff       	call   f0103f70 <cprintf>
  cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01046d0:	8b 43 08             	mov    0x8(%ebx),%eax
f01046d3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046d7:	c7 04 24 69 82 10 f0 	movl   $0xf0108269,(%esp)
f01046de:	e8 8d f8 ff ff       	call   f0103f70 <cprintf>
  cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01046e3:	8b 43 0c             	mov    0xc(%ebx),%eax
f01046e6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046ea:	c7 04 24 78 82 10 f0 	movl   $0xf0108278,(%esp)
f01046f1:	e8 7a f8 ff ff       	call   f0103f70 <cprintf>
  cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01046f6:	8b 43 10             	mov    0x10(%ebx),%eax
f01046f9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046fd:	c7 04 24 87 82 10 f0 	movl   $0xf0108287,(%esp)
f0104704:	e8 67 f8 ff ff       	call   f0103f70 <cprintf>
  cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104709:	8b 43 14             	mov    0x14(%ebx),%eax
f010470c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104710:	c7 04 24 96 82 10 f0 	movl   $0xf0108296,(%esp)
f0104717:	e8 54 f8 ff ff       	call   f0103f70 <cprintf>
  cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010471c:	8b 43 18             	mov    0x18(%ebx),%eax
f010471f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104723:	c7 04 24 a5 82 10 f0 	movl   $0xf01082a5,(%esp)
f010472a:	e8 41 f8 ff ff       	call   f0103f70 <cprintf>
  cprintf("  eax  0x%08x\n", regs->reg_eax);
f010472f:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104732:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104736:	c7 04 24 b4 82 10 f0 	movl   $0xf01082b4,(%esp)
f010473d:	e8 2e f8 ff ff       	call   f0103f70 <cprintf>
}
f0104742:	83 c4 14             	add    $0x14,%esp
f0104745:	5b                   	pop    %ebx
f0104746:	5d                   	pop    %ebp
f0104747:	c3                   	ret    

f0104748 <print_trapframe>:
  lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0104748:	55                   	push   %ebp
f0104749:	89 e5                	mov    %esp,%ebp
f010474b:	56                   	push   %esi
f010474c:	53                   	push   %ebx
f010474d:	83 ec 10             	sub    $0x10,%esp
f0104750:	8b 5d 08             	mov    0x8(%ebp),%ebx
  cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0104753:	e8 41 21 00 00       	call   f0106899 <cpunum>
f0104758:	89 44 24 08          	mov    %eax,0x8(%esp)
f010475c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104760:	c7 04 24 18 83 10 f0 	movl   $0xf0108318,(%esp)
f0104767:	e8 04 f8 ff ff       	call   f0103f70 <cprintf>
  print_regs(&tf->tf_regs);
f010476c:	89 1c 24             	mov    %ebx,(%esp)
f010476f:	e8 2d ff ff ff       	call   f01046a1 <print_regs>
  cprintf("  es   0x----%04x\n", tf->tf_es);
f0104774:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0104778:	89 44 24 04          	mov    %eax,0x4(%esp)
f010477c:	c7 04 24 36 83 10 f0 	movl   $0xf0108336,(%esp)
f0104783:	e8 e8 f7 ff ff       	call   f0103f70 <cprintf>
  cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104788:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010478c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104790:	c7 04 24 49 83 10 f0 	movl   $0xf0108349,(%esp)
f0104797:	e8 d4 f7 ff ff       	call   f0103f70 <cprintf>
  cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010479c:	8b 43 28             	mov    0x28(%ebx),%eax
    "Alignment Check",
    "Machine-Check",
    "SIMD Floating-Point Exception"
  };

  if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f010479f:	83 f8 13             	cmp    $0x13,%eax
f01047a2:	77 09                	ja     f01047ad <print_trapframe+0x65>
    return excnames[trapno];
f01047a4:	8b 14 85 e0 85 10 f0 	mov    -0xfef7a20(,%eax,4),%edx
f01047ab:	eb 1f                	jmp    f01047cc <print_trapframe+0x84>
  if (trapno == T_SYSCALL)
f01047ad:	83 f8 30             	cmp    $0x30,%eax
f01047b0:	74 15                	je     f01047c7 <print_trapframe+0x7f>
    return "System call";
  if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01047b2:	8d 50 e0             	lea    -0x20(%eax),%edx
    return "Hardware Interrupt";
f01047b5:	83 fa 0f             	cmp    $0xf,%edx
f01047b8:	ba cf 82 10 f0       	mov    $0xf01082cf,%edx
f01047bd:	b9 e2 82 10 f0       	mov    $0xf01082e2,%ecx
f01047c2:	0f 47 d1             	cmova  %ecx,%edx
f01047c5:	eb 05                	jmp    f01047cc <print_trapframe+0x84>
  };

  if (trapno < sizeof(excnames)/sizeof(excnames[0]))
    return excnames[trapno];
  if (trapno == T_SYSCALL)
    return "System call";
f01047c7:	ba c3 82 10 f0       	mov    $0xf01082c3,%edx
{
  cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
  print_regs(&tf->tf_regs);
  cprintf("  es   0x----%04x\n", tf->tf_es);
  cprintf("  ds   0x----%04x\n", tf->tf_ds);
  cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01047cc:	89 54 24 08          	mov    %edx,0x8(%esp)
f01047d0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047d4:	c7 04 24 5c 83 10 f0 	movl   $0xf010835c,(%esp)
f01047db:	e8 90 f7 ff ff       	call   f0103f70 <cprintf>
  // If this trap was a page fault that just happened
  // (so %cr2 is meaningful), print the faulting linear address.
  if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01047e0:	3b 1d 60 ca 20 f0    	cmp    0xf020ca60,%ebx
f01047e6:	75 19                	jne    f0104801 <print_trapframe+0xb9>
f01047e8:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01047ec:	75 13                	jne    f0104801 <print_trapframe+0xb9>

static __inline uint32_t
rcr2(void)
{
  uint32_t val;
  __asm __volatile("movl %%cr2,%0" : "=r" (val));
f01047ee:	0f 20 d0             	mov    %cr2,%eax
    cprintf("  cr2  0x%08x\n", rcr2());
f01047f1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047f5:	c7 04 24 6e 83 10 f0 	movl   $0xf010836e,(%esp)
f01047fc:	e8 6f f7 ff ff       	call   f0103f70 <cprintf>
  cprintf("  err  0x%08x", tf->tf_err);
f0104801:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104804:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104808:	c7 04 24 7d 83 10 f0 	movl   $0xf010837d,(%esp)
f010480f:	e8 5c f7 ff ff       	call   f0103f70 <cprintf>
  // For page faults, print decoded fault error code:
  // U/K=fault occurred in user/kernel mode
  // W/R=a write/read caused the fault
  // PR=a protection violation caused the fault (NP=page not present).
  if (tf->tf_trapno == T_PGFLT)
f0104814:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104818:	75 51                	jne    f010486b <print_trapframe+0x123>
    cprintf(" [%s, %s, %s]\n",
            tf->tf_err & 4 ? "user" : "kernel",
            tf->tf_err & 2 ? "write" : "read",
            tf->tf_err & 1 ? "protection" : "not-present");
f010481a:	8b 43 2c             	mov    0x2c(%ebx),%eax
  // For page faults, print decoded fault error code:
  // U/K=fault occurred in user/kernel mode
  // W/R=a write/read caused the fault
  // PR=a protection violation caused the fault (NP=page not present).
  if (tf->tf_trapno == T_PGFLT)
    cprintf(" [%s, %s, %s]\n",
f010481d:	89 c2                	mov    %eax,%edx
f010481f:	83 e2 01             	and    $0x1,%edx
f0104822:	ba f1 82 10 f0       	mov    $0xf01082f1,%edx
f0104827:	b9 fc 82 10 f0       	mov    $0xf01082fc,%ecx
f010482c:	0f 45 ca             	cmovne %edx,%ecx
f010482f:	89 c2                	mov    %eax,%edx
f0104831:	83 e2 02             	and    $0x2,%edx
f0104834:	ba 08 83 10 f0       	mov    $0xf0108308,%edx
f0104839:	be 0e 83 10 f0       	mov    $0xf010830e,%esi
f010483e:	0f 44 d6             	cmove  %esi,%edx
f0104841:	83 e0 04             	and    $0x4,%eax
f0104844:	b8 13 83 10 f0       	mov    $0xf0108313,%eax
f0104849:	be 60 84 10 f0       	mov    $0xf0108460,%esi
f010484e:	0f 44 c6             	cmove  %esi,%eax
f0104851:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104855:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104859:	89 44 24 04          	mov    %eax,0x4(%esp)
f010485d:	c7 04 24 8b 83 10 f0 	movl   $0xf010838b,(%esp)
f0104864:	e8 07 f7 ff ff       	call   f0103f70 <cprintf>
f0104869:	eb 0c                	jmp    f0104877 <print_trapframe+0x12f>
            tf->tf_err & 4 ? "user" : "kernel",
            tf->tf_err & 2 ? "write" : "read",
            tf->tf_err & 1 ? "protection" : "not-present");
  else
    cprintf("\n");
f010486b:	c7 04 24 5d 78 10 f0 	movl   $0xf010785d,(%esp)
f0104872:	e8 f9 f6 ff ff       	call   f0103f70 <cprintf>
  cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104877:	8b 43 30             	mov    0x30(%ebx),%eax
f010487a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010487e:	c7 04 24 9a 83 10 f0 	movl   $0xf010839a,(%esp)
f0104885:	e8 e6 f6 ff ff       	call   f0103f70 <cprintf>
  cprintf("  cs   0x----%04x\n", tf->tf_cs);
f010488a:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f010488e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104892:	c7 04 24 a9 83 10 f0 	movl   $0xf01083a9,(%esp)
f0104899:	e8 d2 f6 ff ff       	call   f0103f70 <cprintf>
  cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010489e:	8b 43 38             	mov    0x38(%ebx),%eax
f01048a1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048a5:	c7 04 24 bc 83 10 f0 	movl   $0xf01083bc,(%esp)
f01048ac:	e8 bf f6 ff ff       	call   f0103f70 <cprintf>
  if ((tf->tf_cs & 3) != 0) {
f01048b1:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01048b5:	74 27                	je     f01048de <print_trapframe+0x196>
    cprintf("  esp  0x%08x\n", tf->tf_esp);
f01048b7:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01048ba:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048be:	c7 04 24 cb 83 10 f0 	movl   $0xf01083cb,(%esp)
f01048c5:	e8 a6 f6 ff ff       	call   f0103f70 <cprintf>
    cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01048ca:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01048ce:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048d2:	c7 04 24 da 83 10 f0 	movl   $0xf01083da,(%esp)
f01048d9:	e8 92 f6 ff ff       	call   f0103f70 <cprintf>
  }
}
f01048de:	83 c4 10             	add    $0x10,%esp
f01048e1:	5b                   	pop    %ebx
f01048e2:	5e                   	pop    %esi
f01048e3:	5d                   	pop    %ebp
f01048e4:	c3                   	ret    

f01048e5 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01048e5:	55                   	push   %ebp
f01048e6:	89 e5                	mov    %esp,%ebp
f01048e8:	57                   	push   %edi
f01048e9:	56                   	push   %esi
f01048ea:	53                   	push   %ebx
f01048eb:	83 ec 2c             	sub    $0x2c,%esp
f01048ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01048f1:	0f 20 d0             	mov    %cr2,%eax
f01048f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  fault_va = rcr2();

  // Handle kernel-mode page faults.

  // LAB 3: Your code here.
  if ((tf->tf_cs & 3) == 0) {
f01048f7:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01048fb:	75 1c                	jne    f0104919 <page_fault_handler+0x34>
		panic("A Page Fault in Kernel!");
f01048fd:	c7 44 24 08 ed 83 10 	movl   $0xf01083ed,0x8(%esp)
f0104904:	f0 
f0104905:	c7 44 24 04 8f 01 00 	movl   $0x18f,0x4(%esp)
f010490c:	00 
f010490d:	c7 04 24 05 84 10 f0 	movl   $0xf0108405,(%esp)
f0104914:	e8 27 b7 ff ff       	call   f0100040 <_panic>
  //   (the 'tf' variable points at 'curenv->env_tf').

  // LAB 4: Your code here.

  // Destroy the environment that caused the fault.
  if(curenv->env_pgfault_upcall == NULL) {
f0104919:	e8 7b 1f 00 00       	call   f0106899 <cpunum>
f010491e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104921:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0104927:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f010492b:	75 4d                	jne    f010497a <page_fault_handler+0x95>
      cprintf("[%08x] user fault va %08x ip %08x\n",
f010492d:	8b 73 30             	mov    0x30(%ebx),%esi
              curenv->env_id, fault_va, tf->tf_eip);
f0104930:	e8 64 1f 00 00       	call   f0106899 <cpunum>

  // LAB 4: Your code here.

  // Destroy the environment that caused the fault.
  if(curenv->env_pgfault_upcall == NULL) {
      cprintf("[%08x] user fault va %08x ip %08x\n",
f0104935:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104939:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010493c:	89 74 24 08          	mov    %esi,0x8(%esp)
              curenv->env_id, fault_va, tf->tf_eip);
f0104940:	6b c0 74             	imul   $0x74,%eax,%eax

  // LAB 4: Your code here.

  // Destroy the environment that caused the fault.
  if(curenv->env_pgfault_upcall == NULL) {
      cprintf("[%08x] user fault va %08x ip %08x\n",
f0104943:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0104949:	8b 40 48             	mov    0x48(%eax),%eax
f010494c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104950:	c7 04 24 ac 85 10 f0 	movl   $0xf01085ac,(%esp)
f0104957:	e8 14 f6 ff ff       	call   f0103f70 <cprintf>
              curenv->env_id, fault_va, tf->tf_eip);
      print_trapframe(tf);
f010495c:	89 1c 24             	mov    %ebx,(%esp)
f010495f:	e8 e4 fd ff ff       	call   f0104748 <print_trapframe>
      env_destroy(curenv);
f0104964:	e8 30 1f 00 00       	call   f0106899 <cpunum>
f0104969:	6b c0 74             	imul   $0x74,%eax,%eax
f010496c:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0104972:	89 04 24             	mov    %eax,(%esp)
f0104975:	e8 1d f3 ff ff       	call   f0103c97 <env_destroy>
  }

  struct UTrapframe* utf = NULL;

  if(USTACKTOP - PGSIZE <= tf->tf_esp && tf->tf_esp < USTACKTOP) {
f010497a:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010497d:	8d 90 00 30 40 11    	lea    0x11403000(%eax),%edx
      utf = (struct UTrapframe*) (UXSTACKTOP - sizeof(struct UTrapframe));
f0104983:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)
      env_destroy(curenv);
  }

  struct UTrapframe* utf = NULL;

  if(USTACKTOP - PGSIZE <= tf->tf_esp && tf->tf_esp < USTACKTOP) {
f010498a:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104990:	76 1a                	jbe    f01049ac <page_fault_handler+0xc7>
      utf = (struct UTrapframe*) (UXSTACKTOP - sizeof(struct UTrapframe));
  } else if (UXSTACKTOP - PGSIZE <= tf->tf_esp && tf->tf_esp < UXSTACKTOP) {
f0104992:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
      utf = (struct UTrapframe*) (tf->tf_esp - 4 - sizeof(struct UTrapframe));
f0104998:	83 e8 38             	sub    $0x38,%eax
f010499b:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f01049a1:	ba 00 00 00 00       	mov    $0x0,%edx
f01049a6:	0f 46 d0             	cmovbe %eax,%edx
f01049a9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  }

  user_mem_assert(curenv, (void *)utf, sizeof(struct UTrapframe), PTE_U | PTE_W);
f01049ac:	e8 e8 1e 00 00       	call   f0106899 <cpunum>
f01049b1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01049b8:	00 
f01049b9:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f01049c0:	00 
f01049c1:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01049c4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01049c8:	6b c0 74             	imul   $0x74,%eax,%eax
f01049cb:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f01049d1:	89 04 24             	mov    %eax,(%esp)
f01049d4:	e8 cb eb ff ff       	call   f01035a4 <user_mem_assert>

  utf->utf_esp = tf->tf_esp;
f01049d9:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01049dc:	89 46 30             	mov    %eax,0x30(%esi)
  utf->utf_eip = tf->tf_eip;
f01049df:	8b 43 30             	mov    0x30(%ebx),%eax
f01049e2:	89 46 28             	mov    %eax,0x28(%esi)
  utf->utf_regs = tf->tf_regs;
f01049e5:	8d 7e 08             	lea    0x8(%esi),%edi
f01049e8:	89 de                	mov    %ebx,%esi
f01049ea:	b8 20 00 00 00       	mov    $0x20,%eax
f01049ef:	f7 c7 01 00 00 00    	test   $0x1,%edi
f01049f5:	74 03                	je     f01049fa <page_fault_handler+0x115>
f01049f7:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f01049f8:	b0 1f                	mov    $0x1f,%al
f01049fa:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0104a00:	74 05                	je     f0104a07 <page_fault_handler+0x122>
f0104a02:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0104a04:	83 e8 02             	sub    $0x2,%eax
f0104a07:	89 c1                	mov    %eax,%ecx
f0104a09:	c1 e9 02             	shr    $0x2,%ecx
f0104a0c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104a0e:	ba 00 00 00 00       	mov    $0x0,%edx
f0104a13:	a8 02                	test   $0x2,%al
f0104a15:	74 0b                	je     f0104a22 <page_fault_handler+0x13d>
f0104a17:	0f b7 16             	movzwl (%esi),%edx
f0104a1a:	66 89 17             	mov    %dx,(%edi)
f0104a1d:	ba 02 00 00 00       	mov    $0x2,%edx
f0104a22:	a8 01                	test   $0x1,%al
f0104a24:	74 07                	je     f0104a2d <page_fault_handler+0x148>
f0104a26:	0f b6 04 16          	movzbl (%esi,%edx,1),%eax
f0104a2a:	88 04 17             	mov    %al,(%edi,%edx,1)
  utf->utf_eflags = tf->tf_eflags;
f0104a2d:	8b 43 38             	mov    0x38(%ebx),%eax
f0104a30:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104a33:	89 47 2c             	mov    %eax,0x2c(%edi)
  utf->utf_err = tf->tf_err;
f0104a36:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104a39:	89 47 04             	mov    %eax,0x4(%edi)
  utf->utf_fault_va = fault_va;
f0104a3c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a3f:	89 07                	mov    %eax,(%edi)

  tf->tf_eip = (uint32_t) curenv->env_pgfault_upcall;
f0104a41:	e8 53 1e 00 00       	call   f0106899 <cpunum>
f0104a46:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a49:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0104a4f:	8b 40 64             	mov    0x64(%eax),%eax
f0104a52:	89 43 30             	mov    %eax,0x30(%ebx)
  tf->tf_esp = (uint32_t) utf;
f0104a55:	89 7b 3c             	mov    %edi,0x3c(%ebx)

  env_run(curenv);
f0104a58:	e8 3c 1e 00 00       	call   f0106899 <cpunum>
f0104a5d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a60:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0104a66:	89 04 24             	mov    %eax,(%esp)
f0104a69:	e8 ca f2 ff ff       	call   f0103d38 <env_run>

f0104a6e <trap>:
  }
}

void
trap(struct Trapframe *tf)
{
f0104a6e:	55                   	push   %ebp
f0104a6f:	89 e5                	mov    %esp,%ebp
f0104a71:	57                   	push   %edi
f0104a72:	56                   	push   %esi
f0104a73:	83 ec 20             	sub    $0x20,%esp
f0104a76:	8b 75 08             	mov    0x8(%ebp),%esi
  // The environment may have set DF and some versions
  // of GCC rely on DF being clear
  asm volatile ("cld" ::: "cc");
f0104a79:	fc                   	cld    

  // Halt the CPU if some other CPU has called panic()
  extern char *panicstr;
  if (panicstr)
f0104a7a:	83 3d 80 ce 20 f0 00 	cmpl   $0x0,0xf020ce80
f0104a81:	74 01                	je     f0104a84 <trap+0x16>
    asm volatile ("hlt");
f0104a83:	f4                   	hlt    

  // Re-acqurie the big kernel lock if we were halted in
  // sched_yield()
  if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104a84:	e8 10 1e 00 00       	call   f0106899 <cpunum>
f0104a89:	6b d0 74             	imul   $0x74,%eax,%edx
f0104a8c:	81 c2 20 d0 20 f0    	add    $0xf020d020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
  uint32_t result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile ("lock; xchgl %0, %1" :
f0104a92:	b8 01 00 00 00       	mov    $0x1,%eax
f0104a97:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104a9b:	83 f8 02             	cmp    $0x2,%eax
f0104a9e:	75 0c                	jne    f0104aac <trap+0x3e>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104aa0:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0104aa7:	e8 6b 20 00 00       	call   f0106b17 <spin_lock>

static __inline uint32_t
read_eflags(void)
{
  uint32_t eflags;
  __asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104aac:	9c                   	pushf  
f0104aad:	58                   	pop    %eax
    lock_kernel();
  // Check that interrupts are disabled.  If this assertion
  // fails, DO NOT be tempted to fix it by inserting a "cli" in
  // the interrupt path.
  assert(!(read_eflags() & FL_IF));
f0104aae:	f6 c4 02             	test   $0x2,%ah
f0104ab1:	74 24                	je     f0104ad7 <trap+0x69>
f0104ab3:	c7 44 24 0c 11 84 10 	movl   $0xf0108411,0xc(%esp)
f0104aba:	f0 
f0104abb:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0104ac2:	f0 
f0104ac3:	c7 44 24 04 58 01 00 	movl   $0x158,0x4(%esp)
f0104aca:	00 
f0104acb:	c7 04 24 05 84 10 f0 	movl   $0xf0108405,(%esp)
f0104ad2:	e8 69 b5 ff ff       	call   f0100040 <_panic>

  if ((tf->tf_cs & 3) == 3) {
f0104ad7:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104adb:	83 e0 03             	and    $0x3,%eax
f0104ade:	66 83 f8 03          	cmp    $0x3,%ax
f0104ae2:	0f 85 a7 00 00 00    	jne    f0104b8f <trap+0x121>
f0104ae8:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0104aef:	e8 23 20 00 00       	call   f0106b17 <spin_lock>
    // Trapped from user mode.
    // Acquire the big kernel lock before doing any
    // serious kernel work.
    // LAB 4: Your code here.
    lock_kernel();
    assert(curenv);
f0104af4:	e8 a0 1d 00 00       	call   f0106899 <cpunum>
f0104af9:	6b c0 74             	imul   $0x74,%eax,%eax
f0104afc:	83 b8 28 d0 20 f0 00 	cmpl   $0x0,-0xfdf2fd8(%eax)
f0104b03:	75 24                	jne    f0104b29 <trap+0xbb>
f0104b05:	c7 44 24 0c 2a 84 10 	movl   $0xf010842a,0xc(%esp)
f0104b0c:	f0 
f0104b0d:	c7 44 24 08 85 75 10 	movl   $0xf0107585,0x8(%esp)
f0104b14:	f0 
f0104b15:	c7 44 24 04 60 01 00 	movl   $0x160,0x4(%esp)
f0104b1c:	00 
f0104b1d:	c7 04 24 05 84 10 f0 	movl   $0xf0108405,(%esp)
f0104b24:	e8 17 b5 ff ff       	call   f0100040 <_panic>

    // Garbage collect if current enviroment is a zombie
    if (curenv->env_status == ENV_DYING) {
f0104b29:	e8 6b 1d 00 00       	call   f0106899 <cpunum>
f0104b2e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b31:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0104b37:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104b3b:	75 2d                	jne    f0104b6a <trap+0xfc>
      env_free(curenv);
f0104b3d:	e8 57 1d 00 00       	call   f0106899 <cpunum>
f0104b42:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b45:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0104b4b:	89 04 24             	mov    %eax,(%esp)
f0104b4e:	e8 79 ef ff ff       	call   f0103acc <env_free>
      curenv = NULL;
f0104b53:	e8 41 1d 00 00       	call   f0106899 <cpunum>
f0104b58:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b5b:	c7 80 28 d0 20 f0 00 	movl   $0x0,-0xfdf2fd8(%eax)
f0104b62:	00 00 00 
      sched_yield();
f0104b65:	e8 64 03 00 00       	call   f0104ece <sched_yield>
    }

    // Copy trap frame (which is currently on the stack)
    // into 'curenv->env_tf', so that running the environment
    // will restart at the trap point.
    curenv->env_tf = *tf;
f0104b6a:	e8 2a 1d 00 00       	call   f0106899 <cpunum>
f0104b6f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b72:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0104b78:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104b7d:	89 c7                	mov    %eax,%edi
f0104b7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
    // The trapframe on the stack should be ignored from here on.
    tf = &curenv->env_tf;
f0104b81:	e8 13 1d 00 00       	call   f0106899 <cpunum>
f0104b86:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b89:	8b b0 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%esi
  }

  // Record that tf is the last real trapframe so
  // print_trapframe can print some additional information.
  last_tf = tf;
f0104b8f:	89 35 60 ca 20 f0    	mov    %esi,0xf020ca60
  // LAB 3: Your code here.

  // Handle clock interrupts. Don't forget to acknowledge the
  // interrupt using lapic_eoi() before calling the scheduler!
  // LAB 4: Your code here.
  if(tf->tf_trapno == T_PGFLT) {
f0104b95:	8b 46 28             	mov    0x28(%esi),%eax
f0104b98:	83 f8 0e             	cmp    $0xe,%eax
f0104b9b:	75 08                	jne    f0104ba5 <trap+0x137>
		page_fault_handler(tf);
f0104b9d:	89 34 24             	mov    %esi,(%esp)
f0104ba0:	e8 40 fd ff ff       	call   f01048e5 <page_fault_handler>
		return;
	}

  if(tf->tf_trapno == T_BRKPT) {
f0104ba5:	83 f8 03             	cmp    $0x3,%eax
f0104ba8:	75 0d                	jne    f0104bb7 <trap+0x149>
      monitor(tf);
f0104baa:	89 34 24             	mov    %esi,(%esp)
f0104bad:	e8 32 be ff ff       	call   f01009e4 <monitor>
f0104bb2:	e9 c7 00 00 00       	jmp    f0104c7e <trap+0x210>
      return;
  }

  if(tf->tf_trapno == T_SYSCALL) {
f0104bb7:	83 f8 30             	cmp    $0x30,%eax
f0104bba:	75 35                	jne    f0104bf1 <trap+0x183>
      uint32_t sc_arg2 = tf->tf_regs.reg_ecx;
      uint32_t sc_arg3 = tf->tf_regs.reg_ebx;
      uint32_t sc_arg4 = tf->tf_regs.reg_edi;
      uint32_t sc_arg5 = tf->tf_regs.reg_esi;

      uint32_t retval = syscall (sc_num,
f0104bbc:	8b 46 04             	mov    0x4(%esi),%eax
f0104bbf:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104bc3:	8b 06                	mov    (%esi),%eax
f0104bc5:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104bc9:	8b 46 10             	mov    0x10(%esi),%eax
f0104bcc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104bd0:	8b 46 18             	mov    0x18(%esi),%eax
f0104bd3:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104bd7:	8b 46 14             	mov    0x14(%esi),%eax
f0104bda:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104bde:	8b 46 1c             	mov    0x1c(%esi),%eax
f0104be1:	89 04 24             	mov    %eax,(%esp)
f0104be4:	e8 b7 03 00 00       	call   f0104fa0 <syscall>
                  sc_arg1, sc_arg2, sc_arg3, sc_arg4, sc_arg5);

      tf->tf_regs.reg_eax = retval;
f0104be9:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104bec:	e9 8d 00 00 00       	jmp    f0104c7e <trap+0x210>
  }

  // Handle spurious interrupts
  // The hardware sometimes raises these because of noise on the
  // IRQ line or other reasons. We don't care.
  if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104bf1:	83 f8 27             	cmp    $0x27,%eax
f0104bf4:	75 16                	jne    f0104c0c <trap+0x19e>
    cprintf("Spurious interrupt on irq 7\n");
f0104bf6:	c7 04 24 31 84 10 f0 	movl   $0xf0108431,(%esp)
f0104bfd:	e8 6e f3 ff ff       	call   f0103f70 <cprintf>
    print_trapframe(tf);
f0104c02:	89 34 24             	mov    %esi,(%esp)
f0104c05:	e8 3e fb ff ff       	call   f0104748 <print_trapframe>
f0104c0a:	eb 72                	jmp    f0104c7e <trap+0x210>
  }

  // Handle clock interrupts. Don't forget to acknowledge the
  // interrupt using lapic_eoi() before calling the scheduler!
  // LAB 4: Your code here.
  if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f0104c0c:	83 f8 20             	cmp    $0x20,%eax
f0104c0f:	90                   	nop
f0104c10:	75 0a                	jne    f0104c1c <trap+0x1ae>
    lapic_eoi();
f0104c12:	e8 cf 1d 00 00       	call   f01069e6 <lapic_eoi>
    sched_yield();
f0104c17:	e8 b2 02 00 00       	call   f0104ece <sched_yield>
  }

  // Handle keyboard and serial interrupts.
  // LAB 5: Your code here.
  //Added for lab4
  if (tf->tf_trapno == IRQ_OFFSET + IRQ_KBD) {
f0104c1c:	83 f8 21             	cmp    $0x21,%eax
f0104c1f:	90                   	nop
f0104c20:	75 07                	jne    f0104c29 <trap+0x1bb>
    kbd_intr();
f0104c22:	e8 0c ba ff ff       	call   f0100633 <kbd_intr>
f0104c27:	eb 55                	jmp    f0104c7e <trap+0x210>
    return;
  }

  if (tf->tf_trapno == IRQ_OFFSET + IRQ_SERIAL) {
f0104c29:	83 f8 24             	cmp    $0x24,%eax
f0104c2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104c30:	75 07                	jne    f0104c39 <trap+0x1cb>
    kbd_intr();
f0104c32:	e8 fc b9 ff ff       	call   f0100633 <kbd_intr>
f0104c37:	eb 45                	jmp    f0104c7e <trap+0x210>
    return;
  }

  // Unexpected trap: The user process or the kernel has a bug.
  print_trapframe(tf);
f0104c39:	89 34 24             	mov    %esi,(%esp)
f0104c3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104c40:	e8 03 fb ff ff       	call   f0104748 <print_trapframe>
  if (tf->tf_cs == GD_KT)
f0104c45:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104c4a:	75 1c                	jne    f0104c68 <trap+0x1fa>
    panic("unhandled trap in kernel");
f0104c4c:	c7 44 24 08 4e 84 10 	movl   $0xf010844e,0x8(%esp)
f0104c53:	f0 
f0104c54:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
f0104c5b:	00 
f0104c5c:	c7 04 24 05 84 10 f0 	movl   $0xf0108405,(%esp)
f0104c63:	e8 d8 b3 ff ff       	call   f0100040 <_panic>
  else {
    env_destroy(curenv);
f0104c68:	e8 2c 1c 00 00       	call   f0106899 <cpunum>
f0104c6d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c70:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0104c76:	89 04 24             	mov    %eax,(%esp)
f0104c79:	e8 19 f0 ff ff       	call   f0103c97 <env_destroy>
  trap_dispatch(tf);

  // If we made it to this point, then no other environment was
  // scheduled, so we should return to the current environment
  // if doing so makes sense.
  if (curenv && curenv->env_status == ENV_RUNNING)
f0104c7e:	e8 16 1c 00 00       	call   f0106899 <cpunum>
f0104c83:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c86:	83 b8 28 d0 20 f0 00 	cmpl   $0x0,-0xfdf2fd8(%eax)
f0104c8d:	74 2a                	je     f0104cb9 <trap+0x24b>
f0104c8f:	e8 05 1c 00 00       	call   f0106899 <cpunum>
f0104c94:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c97:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0104c9d:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104ca1:	75 16                	jne    f0104cb9 <trap+0x24b>
    env_run(curenv);
f0104ca3:	e8 f1 1b 00 00       	call   f0106899 <cpunum>
f0104ca8:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cab:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0104cb1:	89 04 24             	mov    %eax,(%esp)
f0104cb4:	e8 7f f0 ff ff       	call   f0103d38 <env_run>
  else
    sched_yield();
f0104cb9:	e8 10 02 00 00       	call   f0104ece <sched_yield>

f0104cbe <TRAP_DIVIDE>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(TRAP_DIVIDE, T_DIVIDE)
f0104cbe:	6a 00                	push   $0x0
f0104cc0:	6a 00                	push   $0x0
f0104cc2:	e9 1f 01 00 00       	jmp    f0104de6 <_alltraps>
f0104cc7:	90                   	nop

f0104cc8 <TRAP_DEBUG>:
TRAPHANDLER_NOEC(TRAP_DEBUG, T_DEBUG)
f0104cc8:	6a 00                	push   $0x0
f0104cca:	6a 01                	push   $0x1
f0104ccc:	e9 15 01 00 00       	jmp    f0104de6 <_alltraps>
f0104cd1:	90                   	nop

f0104cd2 <TRAP_BRKPT>:
TRAPHANDLER_NOEC(TRAP_BRKPT, T_BRKPT)
f0104cd2:	6a 00                	push   $0x0
f0104cd4:	6a 03                	push   $0x3
f0104cd6:	e9 0b 01 00 00       	jmp    f0104de6 <_alltraps>
f0104cdb:	90                   	nop

f0104cdc <TRAP_OFLOW>:
TRAPHANDLER_NOEC(TRAP_OFLOW, T_OFLOW)
f0104cdc:	6a 00                	push   $0x0
f0104cde:	6a 04                	push   $0x4
f0104ce0:	e9 01 01 00 00       	jmp    f0104de6 <_alltraps>
f0104ce5:	90                   	nop

f0104ce6 <TRAP_BOUND>:
TRAPHANDLER_NOEC(TRAP_BOUND, T_BOUND)
f0104ce6:	6a 00                	push   $0x0
f0104ce8:	6a 05                	push   $0x5
f0104cea:	e9 f7 00 00 00       	jmp    f0104de6 <_alltraps>
f0104cef:	90                   	nop

f0104cf0 <TRAP_ILLOP>:
TRAPHANDLER_NOEC(TRAP_ILLOP, T_ILLOP)
f0104cf0:	6a 00                	push   $0x0
f0104cf2:	6a 06                	push   $0x6
f0104cf4:	e9 ed 00 00 00       	jmp    f0104de6 <_alltraps>
f0104cf9:	90                   	nop

f0104cfa <TRAP_DEVICE>:
TRAPHANDLER_NOEC(TRAP_DEVICE, T_DEVICE)
f0104cfa:	6a 00                	push   $0x0
f0104cfc:	6a 07                	push   $0x7
f0104cfe:	e9 e3 00 00 00       	jmp    f0104de6 <_alltraps>
f0104d03:	90                   	nop

f0104d04 <TRAP_DBLFLT>:
TRAPHANDLER(TRAP_DBLFLT, T_DBLFLT)
f0104d04:	6a 08                	push   $0x8
f0104d06:	e9 db 00 00 00       	jmp    f0104de6 <_alltraps>
f0104d0b:	90                   	nop

f0104d0c <TRAP_TSS>:
TRAPHANDLER(TRAP_TSS, T_TSS)
f0104d0c:	6a 0a                	push   $0xa
f0104d0e:	e9 d3 00 00 00       	jmp    f0104de6 <_alltraps>
f0104d13:	90                   	nop

f0104d14 <TRAP_SEGNP>:
TRAPHANDLER(TRAP_SEGNP, T_SEGNP)
f0104d14:	6a 0b                	push   $0xb
f0104d16:	e9 cb 00 00 00       	jmp    f0104de6 <_alltraps>
f0104d1b:	90                   	nop

f0104d1c <TRAP_STACK>:
TRAPHANDLER(TRAP_STACK, T_STACK)
f0104d1c:	6a 0c                	push   $0xc
f0104d1e:	e9 c3 00 00 00       	jmp    f0104de6 <_alltraps>
f0104d23:	90                   	nop

f0104d24 <TRAP_GPFLT>:
TRAPHANDLER(TRAP_GPFLT, T_GPFLT)
f0104d24:	6a 0d                	push   $0xd
f0104d26:	e9 bb 00 00 00       	jmp    f0104de6 <_alltraps>
f0104d2b:	90                   	nop

f0104d2c <TRAP_PGFLT>:
TRAPHANDLER(TRAP_PGFLT, T_PGFLT)
f0104d2c:	6a 0e                	push   $0xe
f0104d2e:	e9 b3 00 00 00       	jmp    f0104de6 <_alltraps>
f0104d33:	90                   	nop

f0104d34 <TRAP_FPERR>:
TRAPHANDLER_NOEC(TRAP_FPERR, T_FPERR)
f0104d34:	6a 00                	push   $0x0
f0104d36:	6a 10                	push   $0x10
f0104d38:	e9 a9 00 00 00       	jmp    f0104de6 <_alltraps>
f0104d3d:	90                   	nop

f0104d3e <TRAP_SYSCALL>:
TRAPHANDLER_NOEC(TRAP_SYSCALL, T_SYSCALL)
f0104d3e:	6a 00                	push   $0x0
f0104d40:	6a 30                	push   $0x30
f0104d42:	e9 9f 00 00 00       	jmp    f0104de6 <_alltraps>
f0104d47:	90                   	nop

f0104d48 <TRAP_NMI>:
TRAPHANDLER_NOEC(TRAP_NMI, T_NMI)
f0104d48:	6a 00                	push   $0x0
f0104d4a:	6a 02                	push   $0x2
f0104d4c:	e9 95 00 00 00       	jmp    f0104de6 <_alltraps>
f0104d51:	90                   	nop

f0104d52 <TRAP_ALIGN>:
TRAPHANDLER(TRAP_ALIGN, T_ALIGN)
f0104d52:	6a 11                	push   $0x11
f0104d54:	e9 8d 00 00 00       	jmp    f0104de6 <_alltraps>
f0104d59:	90                   	nop

f0104d5a <TRAP_MCHK>:
TRAPHANDLER_NOEC(TRAP_MCHK, T_MCHK)
f0104d5a:	6a 00                	push   $0x0
f0104d5c:	6a 12                	push   $0x12
f0104d5e:	e9 83 00 00 00       	jmp    f0104de6 <_alltraps>
f0104d63:	90                   	nop

f0104d64 <TRAP_SIMDERR>:
TRAPHANDLER_NOEC(TRAP_SIMDERR, T_SIMDERR)
f0104d64:	6a 00                	push   $0x0
f0104d66:	6a 13                	push   $0x13
f0104d68:	eb 7c                	jmp    f0104de6 <_alltraps>

f0104d6a <TRAP_DEFAULT>:
TRAPHANDLER_NOEC(TRAP_DEFAULT, T_DEFAULT)
f0104d6a:	6a 00                	push   $0x0
f0104d6c:	68 f4 01 00 00       	push   $0x1f4
f0104d71:	eb 73                	jmp    f0104de6 <_alltraps>
f0104d73:	90                   	nop

f0104d74 <IRQ_0>:
TRAPHANDLER_NOEC(IRQ_0, IRQ_OFFSET + 0)
f0104d74:	6a 00                	push   $0x0
f0104d76:	6a 20                	push   $0x20
f0104d78:	eb 6c                	jmp    f0104de6 <_alltraps>

f0104d7a <IRQ_1>:
TRAPHANDLER_NOEC(IRQ_1, IRQ_OFFSET + 1)
f0104d7a:	6a 00                	push   $0x0
f0104d7c:	6a 21                	push   $0x21
f0104d7e:	eb 66                	jmp    f0104de6 <_alltraps>

f0104d80 <IRQ_2>:
TRAPHANDLER_NOEC(IRQ_2, IRQ_OFFSET + 2)
f0104d80:	6a 00                	push   $0x0
f0104d82:	6a 22                	push   $0x22
f0104d84:	eb 60                	jmp    f0104de6 <_alltraps>

f0104d86 <IRQ_3>:
TRAPHANDLER_NOEC(IRQ_3, IRQ_OFFSET + 3)
f0104d86:	6a 00                	push   $0x0
f0104d88:	6a 23                	push   $0x23
f0104d8a:	eb 5a                	jmp    f0104de6 <_alltraps>

f0104d8c <IRQ_4>:
TRAPHANDLER_NOEC(IRQ_4, IRQ_OFFSET + 4)
f0104d8c:	6a 00                	push   $0x0
f0104d8e:	6a 24                	push   $0x24
f0104d90:	eb 54                	jmp    f0104de6 <_alltraps>

f0104d92 <IRQ_5>:
TRAPHANDLER_NOEC(IRQ_5, IRQ_OFFSET + 5)
f0104d92:	6a 00                	push   $0x0
f0104d94:	6a 25                	push   $0x25
f0104d96:	eb 4e                	jmp    f0104de6 <_alltraps>

f0104d98 <IRQ_6>:
TRAPHANDLER_NOEC(IRQ_6, IRQ_OFFSET + 6)
f0104d98:	6a 00                	push   $0x0
f0104d9a:	6a 26                	push   $0x26
f0104d9c:	eb 48                	jmp    f0104de6 <_alltraps>

f0104d9e <IRQ_7>:
TRAPHANDLER_NOEC(IRQ_7, IRQ_OFFSET + 7)
f0104d9e:	6a 00                	push   $0x0
f0104da0:	6a 27                	push   $0x27
f0104da2:	eb 42                	jmp    f0104de6 <_alltraps>

f0104da4 <IRQ_8>:
TRAPHANDLER_NOEC(IRQ_8, IRQ_OFFSET + 8)
f0104da4:	6a 00                	push   $0x0
f0104da6:	6a 28                	push   $0x28
f0104da8:	eb 3c                	jmp    f0104de6 <_alltraps>

f0104daa <IRQ_9>:
TRAPHANDLER_NOEC(IRQ_9, IRQ_OFFSET + 9)
f0104daa:	6a 00                	push   $0x0
f0104dac:	6a 29                	push   $0x29
f0104dae:	eb 36                	jmp    f0104de6 <_alltraps>

f0104db0 <IRQ_10>:
TRAPHANDLER_NOEC(IRQ_10, IRQ_OFFSET + 10)
f0104db0:	6a 00                	push   $0x0
f0104db2:	6a 2a                	push   $0x2a
f0104db4:	eb 30                	jmp    f0104de6 <_alltraps>

f0104db6 <IRQ_11>:
TRAPHANDLER_NOEC(IRQ_11, IRQ_OFFSET + 11)
f0104db6:	6a 00                	push   $0x0
f0104db8:	6a 2b                	push   $0x2b
f0104dba:	eb 2a                	jmp    f0104de6 <_alltraps>

f0104dbc <IRQ_12>:
TRAPHANDLER_NOEC(IRQ_12, IRQ_OFFSET + 12)
f0104dbc:	6a 00                	push   $0x0
f0104dbe:	6a 2c                	push   $0x2c
f0104dc0:	eb 24                	jmp    f0104de6 <_alltraps>

f0104dc2 <IRQ_13>:
TRAPHANDLER_NOEC(IRQ_13, IRQ_OFFSET + 13)
f0104dc2:	6a 00                	push   $0x0
f0104dc4:	6a 2d                	push   $0x2d
f0104dc6:	eb 1e                	jmp    f0104de6 <_alltraps>

f0104dc8 <IRQ_14>:
TRAPHANDLER_NOEC(IRQ_14, IRQ_OFFSET + 14)
f0104dc8:	6a 00                	push   $0x0
f0104dca:	6a 2e                	push   $0x2e
f0104dcc:	eb 18                	jmp    f0104de6 <_alltraps>

f0104dce <IRQ_15>:
TRAPHANDLER_NOEC(IRQ_15, IRQ_OFFSET + 15)
f0104dce:	6a 00                	push   $0x0
f0104dd0:	6a 2f                	push   $0x2f
f0104dd2:	eb 12                	jmp    f0104de6 <_alltraps>

f0104dd4 <IRQ_TIMER_>:
TRAPHANDLER_NOEC(IRQ_TIMER_, IRQ_OFFSET + IRQ_TIMER);
f0104dd4:	6a 00                	push   $0x0
f0104dd6:	6a 20                	push   $0x20
f0104dd8:	eb 0c                	jmp    f0104de6 <_alltraps>

f0104dda <IRQ_KDB_>:
TRAPHANDLER_NOEC(IRQ_KDB_, IRQ_OFFSET + IRQ_KBD);
f0104dda:	6a 00                	push   $0x0
f0104ddc:	6a 21                	push   $0x21
f0104dde:	eb 06                	jmp    f0104de6 <_alltraps>

f0104de0 <IRQ_SERIAL_>:
TRAPHANDLER_NOEC(IRQ_SERIAL_, IRQ_OFFSET + IRQ_SERIAL);
f0104de0:	6a 00                	push   $0x0
f0104de2:	6a 24                	push   $0x24
f0104de4:	eb 00                	jmp    f0104de6 <_alltraps>

f0104de6 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
        pushl %ds
f0104de6:	1e                   	push   %ds
        pushl %es
f0104de7:	06                   	push   %es
	pushal
f0104de8:	60                   	pusha  

        movl $GD_KD, %eax
f0104de9:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f0104dee:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0104df0:	8e c0                	mov    %eax,%es
        
        pushl %esp
f0104df2:	54                   	push   %esp
        call trap
f0104df3:	e8 76 fc ff ff       	call   f0104a6e <trap>

f0104df8 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104df8:	55                   	push   %ebp
f0104df9:	89 e5                	mov    %esp,%ebp
f0104dfb:	83 ec 18             	sub    $0x18,%esp
f0104dfe:	8b 15 48 c2 20 f0    	mov    0xf020c248,%edx
  int i;

  // For debugging and testing purposes, if there are no runnable
  // environments in the system, then drop into the kernel monitor.
  for (i = 0; i < NENV; i++) {
f0104e04:	b8 00 00 00 00       	mov    $0x0,%eax
    if ((envs[i].env_status == ENV_RUNNABLE ||
         envs[i].env_status == ENV_RUNNING ||
f0104e09:	8b 4a 54             	mov    0x54(%edx),%ecx
f0104e0c:	83 e9 01             	sub    $0x1,%ecx
  int i;

  // For debugging and testing purposes, if there are no runnable
  // environments in the system, then drop into the kernel monitor.
  for (i = 0; i < NENV; i++) {
    if ((envs[i].env_status == ENV_RUNNABLE ||
f0104e0f:	83 f9 02             	cmp    $0x2,%ecx
f0104e12:	76 0f                	jbe    f0104e23 <sched_halt+0x2b>
{
  int i;

  // For debugging and testing purposes, if there are no runnable
  // environments in the system, then drop into the kernel monitor.
  for (i = 0; i < NENV; i++) {
f0104e14:	83 c0 01             	add    $0x1,%eax
f0104e17:	83 c2 7c             	add    $0x7c,%edx
f0104e1a:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104e1f:	75 e8                	jne    f0104e09 <sched_halt+0x11>
f0104e21:	eb 07                	jmp    f0104e2a <sched_halt+0x32>
    if ((envs[i].env_status == ENV_RUNNABLE ||
         envs[i].env_status == ENV_RUNNING ||
         envs[i].env_status == ENV_DYING))
      break;
  }
  if (i == NENV) {
f0104e23:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104e28:	75 1a                	jne    f0104e44 <sched_halt+0x4c>
    cprintf("No runnable environments in the system!\n");
f0104e2a:	c7 04 24 30 86 10 f0 	movl   $0xf0108630,(%esp)
f0104e31:	e8 3a f1 ff ff       	call   f0103f70 <cprintf>
    while (1)
      monitor(NULL);
f0104e36:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104e3d:	e8 a2 bb ff ff       	call   f01009e4 <monitor>
f0104e42:	eb f2                	jmp    f0104e36 <sched_halt+0x3e>
  }

  // Mark that no environment is running on this CPU
  curenv = NULL;
f0104e44:	e8 50 1a 00 00       	call   f0106899 <cpunum>
f0104e49:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e4c:	c7 80 28 d0 20 f0 00 	movl   $0x0,-0xfdf2fd8(%eax)
f0104e53:	00 00 00 
  lcr3(PADDR(kern_pgdir));
f0104e56:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104e5b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104e60:	77 20                	ja     f0104e82 <sched_halt+0x8a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104e62:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104e66:	c7 44 24 08 c8 6f 10 	movl   $0xf0106fc8,0x8(%esp)
f0104e6d:	f0 
f0104e6e:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
f0104e75:	00 
f0104e76:	c7 04 24 59 86 10 f0 	movl   $0xf0108659,(%esp)
f0104e7d:	e8 be b1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104e82:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
  __asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104e87:	0f 22 d8             	mov    %eax,%cr3

  // Mark that this CPU is in the HALT state, so that when
  // timer interupts come in, we know we should re-acquire the
  // big kernel lock
  xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104e8a:	e8 0a 1a 00 00       	call   f0106899 <cpunum>
f0104e8f:	6b d0 74             	imul   $0x74,%eax,%edx
f0104e92:	81 c2 20 d0 20 f0    	add    $0xf020d020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
  uint32_t result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile ("lock; xchgl %0, %1" :
f0104e98:	b8 02 00 00 00       	mov    $0x2,%eax
f0104e9d:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104ea1:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0104ea8:	e8 16 1d 00 00       	call   f0106bc3 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104ead:	f3 90                	pause  
    "pushl $0\n"
    "sti\n"
    "1:\n"
    "hlt\n"
    "jmp 1b\n"
    : : "a" (thiscpu->cpu_ts.ts_esp0));
f0104eaf:	e8 e5 19 00 00       	call   f0106899 <cpunum>
f0104eb4:	6b c0 74             	imul   $0x74,%eax,%eax

  // Release the big kernel lock as if we were "leaving" the kernel
  unlock_kernel();

  // Reset stack pointer, enable interrupts and then halt.
  asm volatile (
f0104eb7:	8b 80 30 d0 20 f0    	mov    -0xfdf2fd0(%eax),%eax
f0104ebd:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104ec2:	89 c4                	mov    %eax,%esp
f0104ec4:	6a 00                	push   $0x0
f0104ec6:	6a 00                	push   $0x0
f0104ec8:	fb                   	sti    
f0104ec9:	f4                   	hlt    
f0104eca:	eb fd                	jmp    f0104ec9 <sched_halt+0xd1>
    "sti\n"
    "1:\n"
    "hlt\n"
    "jmp 1b\n"
    : : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104ecc:	c9                   	leave  
f0104ecd:	c3                   	ret    

f0104ece <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104ece:	55                   	push   %ebp
f0104ecf:	89 e5                	mov    %esp,%ebp
f0104ed1:	53                   	push   %ebx
f0104ed2:	83 ec 14             	sub    $0x14,%esp
  // another CPU (env_status == ENV_RUNNING). If there are
  // no runnable environments, simply drop through to the code
  // below to halt the cpu.

  // LAB 4: Your code here.
  int i = (curenv == NULL) ? 0 : (curenv - envs + 1) % NENV;
f0104ed5:	e8 bf 19 00 00       	call   f0106899 <cpunum>
f0104eda:	6b d0 74             	imul   $0x74,%eax,%edx
f0104edd:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ee2:	83 ba 28 d0 20 f0 00 	cmpl   $0x0,-0xfdf2fd8(%edx)
f0104ee9:	74 2d                	je     f0104f18 <sched_yield+0x4a>
f0104eeb:	e8 a9 19 00 00       	call   f0106899 <cpunum>
f0104ef0:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ef3:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0104ef9:	2b 05 48 c2 20 f0    	sub    0xf020c248,%eax
f0104eff:	c1 f8 02             	sar    $0x2,%eax
f0104f02:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
f0104f08:	83 c0 01             	add    $0x1,%eax
f0104f0b:	99                   	cltd   
f0104f0c:	c1 ea 16             	shr    $0x16,%edx
f0104f0f:	01 d0                	add    %edx,%eax
f0104f11:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104f16:	29 d0                	sub    %edx,%eax
  int cnt;
  for (cnt = 0; cnt < NENV; ++ cnt) {
    if (envs[i].env_status == ENV_RUNNABLE) {
f0104f18:	8b 1d 48 c2 20 f0    	mov    0xf020c248,%ebx
f0104f1e:	ba 00 04 00 00       	mov    $0x400,%edx
f0104f23:	6b c8 7c             	imul   $0x7c,%eax,%ecx
f0104f26:	01 d9                	add    %ebx,%ecx
f0104f28:	83 79 54 02          	cmpl   $0x2,0x54(%ecx)
f0104f2c:	75 08                	jne    f0104f36 <sched_yield+0x68>
      env_run(&envs[i]);
f0104f2e:	89 0c 24             	mov    %ecx,(%esp)
f0104f31:	e8 02 ee ff ff       	call   f0103d38 <env_run>
    }
    i = (i + 1) % NENV;
f0104f36:	83 c0 01             	add    $0x1,%eax
f0104f39:	89 c1                	mov    %eax,%ecx
f0104f3b:	c1 f9 1f             	sar    $0x1f,%ecx
f0104f3e:	c1 e9 16             	shr    $0x16,%ecx
f0104f41:	01 c8                	add    %ecx,%eax
f0104f43:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104f48:	29 c8                	sub    %ecx,%eax
  // below to halt the cpu.

  // LAB 4: Your code here.
  int i = (curenv == NULL) ? 0 : (curenv - envs + 1) % NENV;
  int cnt;
  for (cnt = 0; cnt < NENV; ++ cnt) {
f0104f4a:	83 ea 01             	sub    $0x1,%edx
f0104f4d:	75 d4                	jne    f0104f23 <sched_yield+0x55>
      env_run(&envs[i]);
    }
    i = (i + 1) % NENV;
  }

  if (curenv != NULL && curenv->env_status == ENV_RUNNING) {
f0104f4f:	e8 45 19 00 00       	call   f0106899 <cpunum>
f0104f54:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f57:	83 b8 28 d0 20 f0 00 	cmpl   $0x0,-0xfdf2fd8(%eax)
f0104f5e:	74 2a                	je     f0104f8a <sched_yield+0xbc>
f0104f60:	e8 34 19 00 00       	call   f0106899 <cpunum>
f0104f65:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f68:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0104f6e:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104f72:	75 16                	jne    f0104f8a <sched_yield+0xbc>
    env_run(curenv);
f0104f74:	e8 20 19 00 00       	call   f0106899 <cpunum>
f0104f79:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f7c:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0104f82:	89 04 24             	mov    %eax,(%esp)
f0104f85:	e8 ae ed ff ff       	call   f0103d38 <env_run>
  }

  // never returns
  sched_halt();
f0104f8a:	e8 69 fe ff ff       	call   f0104df8 <sched_halt>
}
f0104f8f:	83 c4 14             	add    $0x14,%esp
f0104f92:	5b                   	pop    %ebx
f0104f93:	5d                   	pop    %ebp
f0104f94:	c3                   	ret    
f0104f95:	66 90                	xchg   %ax,%ax
f0104f97:	66 90                	xchg   %ax,%ax
f0104f99:	66 90                	xchg   %ax,%ax
f0104f9b:	66 90                	xchg   %ax,%ax
f0104f9d:	66 90                	xchg   %ax,%ax
f0104f9f:	90                   	nop

f0104fa0 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104fa0:	55                   	push   %ebp
f0104fa1:	89 e5                	mov    %esp,%ebp
f0104fa3:	57                   	push   %edi
f0104fa4:	56                   	push   %esi
f0104fa5:	53                   	push   %ebx
f0104fa6:	83 ec 2c             	sub    $0x2c,%esp
f0104fa9:	8b 45 08             	mov    0x8(%ebp),%eax
  // Call the function corresponding to the 'syscallno' parameter.
  // Return any appropriate return value.
  // LAB 3: Your code here.
  //panic("syscall not implemented");
  switch (syscallno) {
f0104fac:	83 f8 0d             	cmp    $0xd,%eax
f0104faf:	0f 87 0f 06 00 00    	ja     f01055c4 <syscall+0x624>
f0104fb5:	ff 24 85 a0 86 10 f0 	jmp    *-0xfef7960(,%eax,4)
{
  // Check that the user has permission to read memory [s, s+len).
  // Destroy the environment if not.

  // LAB 3: Your code here.
  user_mem_assert(curenv, s, len, PTE_U);
f0104fbc:	e8 d8 18 00 00       	call   f0106899 <cpunum>
f0104fc1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104fc8:	00 
f0104fc9:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104fcc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104fd0:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104fd3:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104fd7:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fda:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0104fe0:	89 04 24             	mov    %eax,(%esp)
f0104fe3:	e8 bc e5 ff ff       	call   f01035a4 <user_mem_assert>

  // Print the string supplied by the user.
  cprintf("%.*s", len, s);
f0104fe8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104feb:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104fef:	8b 45 10             	mov    0x10(%ebp),%eax
f0104ff2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ff6:	c7 04 24 66 86 10 f0 	movl   $0xf0108666,(%esp)
f0104ffd:	e8 6e ef ff ff       	call   f0103f70 <cprintf>
  // LAB 3: Your code here.
  //panic("syscall not implemented");
  switch (syscallno) {
    case SYS_cputs:
      sys_cputs((char *)a1, (size_t) a2);
      return 0;
f0105002:	b8 00 00 00 00       	mov    $0x0,%eax
f0105007:	e9 ec 05 00 00       	jmp    f01055f8 <syscall+0x658>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
  return cons_getc();
f010500c:	e8 34 b6 ff ff       	call   f0100645 <cons_getc>
  switch (syscallno) {
    case SYS_cputs:
      sys_cputs((char *)a1, (size_t) a2);
      return 0;
    case SYS_cgetc:
      return sys_cgetc();
f0105011:	e9 e2 05 00 00       	jmp    f01055f8 <syscall+0x658>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
  return curenv->env_id;
f0105016:	e8 7e 18 00 00       	call   f0106899 <cpunum>
f010501b:	6b c0 74             	imul   $0x74,%eax,%eax
f010501e:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0105024:	8b 40 48             	mov    0x48(%eax),%eax
      sys_cputs((char *)a1, (size_t) a2);
      return 0;
    case SYS_cgetc:
      return sys_cgetc();
    case SYS_getenvid:
      return sys_getenvid();
f0105027:	e9 cc 05 00 00       	jmp    f01055f8 <syscall+0x658>
sys_env_destroy(envid_t envid)
{
  int r;
  struct Env *e;

  if ((r = envid2env(envid, &e, 1)) < 0)
f010502c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105033:	00 
f0105034:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105037:	89 44 24 04          	mov    %eax,0x4(%esp)
f010503b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010503e:	89 04 24             	mov    %eax,(%esp)
f0105041:	e8 59 e6 ff ff       	call   f010369f <envid2env>
    return r;
f0105046:	89 c2                	mov    %eax,%edx
sys_env_destroy(envid_t envid)
{
  int r;
  struct Env *e;

  if ((r = envid2env(envid, &e, 1)) < 0)
f0105048:	85 c0                	test   %eax,%eax
f010504a:	78 6e                	js     f01050ba <syscall+0x11a>
    return r;
  if (e == curenv)
f010504c:	e8 48 18 00 00       	call   f0106899 <cpunum>
f0105051:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105054:	6b c0 74             	imul   $0x74,%eax,%eax
f0105057:	39 90 28 d0 20 f0    	cmp    %edx,-0xfdf2fd8(%eax)
f010505d:	75 23                	jne    f0105082 <syscall+0xe2>
    cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010505f:	e8 35 18 00 00       	call   f0106899 <cpunum>
f0105064:	6b c0 74             	imul   $0x74,%eax,%eax
f0105067:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f010506d:	8b 40 48             	mov    0x48(%eax),%eax
f0105070:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105074:	c7 04 24 6b 86 10 f0 	movl   $0xf010866b,(%esp)
f010507b:	e8 f0 ee ff ff       	call   f0103f70 <cprintf>
f0105080:	eb 28                	jmp    f01050aa <syscall+0x10a>
  else
    cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0105082:	8b 5a 48             	mov    0x48(%edx),%ebx
f0105085:	e8 0f 18 00 00       	call   f0106899 <cpunum>
f010508a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010508e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105091:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0105097:	8b 40 48             	mov    0x48(%eax),%eax
f010509a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010509e:	c7 04 24 86 86 10 f0 	movl   $0xf0108686,(%esp)
f01050a5:	e8 c6 ee ff ff       	call   f0103f70 <cprintf>
  env_destroy(e);
f01050aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01050ad:	89 04 24             	mov    %eax,(%esp)
f01050b0:	e8 e2 eb ff ff       	call   f0103c97 <env_destroy>
  return 0;
f01050b5:	ba 00 00 00 00       	mov    $0x0,%edx
    case SYS_cgetc:
      return sys_cgetc();
    case SYS_getenvid:
      return sys_getenvid();
    case SYS_env_destroy:
      return sys_env_destroy ((envid_t) a1);
f01050ba:	89 d0                	mov    %edx,%eax
f01050bc:	e9 37 05 00 00       	jmp    f01055f8 <syscall+0x658>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
  sched_yield();
f01050c1:	e8 08 fe ff ff       	call   f0104ece <sched_yield>
  // from the current environment -- but tweaked so sys_exofork
  // will appear to return 0.

  // LAB 4: Your code here.
  struct Env *e;
  int ret = env_alloc(&e, curenv->env_id);
f01050c6:	e8 ce 17 00 00       	call   f0106899 <cpunum>
f01050cb:	6b c0 74             	imul   $0x74,%eax,%eax
f01050ce:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f01050d4:	8b 40 48             	mov    0x48(%eax),%eax
f01050d7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050db:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01050de:	89 04 24             	mov    %eax,(%esp)
f01050e1:	e8 db e6 ff ff       	call   f01037c1 <env_alloc>
  if (ret < 0) {
    return ret;
f01050e6:	89 c2                	mov    %eax,%edx
  // will appear to return 0.

  // LAB 4: Your code here.
  struct Env *e;
  int ret = env_alloc(&e, curenv->env_id);
  if (ret < 0) {
f01050e8:	85 c0                	test   %eax,%eax
f01050ea:	78 2e                	js     f010511a <syscall+0x17a>
    return ret;
  }
  e->env_status = ENV_NOT_RUNNABLE;
f01050ec:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01050ef:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
  e->env_tf = curenv->env_tf;
f01050f6:	e8 9e 17 00 00       	call   f0106899 <cpunum>
f01050fb:	6b c0 74             	imul   $0x74,%eax,%eax
f01050fe:	8b b0 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%esi
f0105104:	b9 11 00 00 00       	mov    $0x11,%ecx
f0105109:	89 df                	mov    %ebx,%edi
f010510b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  e->env_tf.tf_regs.reg_eax = 0;
f010510d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105110:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  return e->env_id;
f0105117:	8b 50 48             	mov    0x48(%eax),%edx
      return sys_env_destroy ((envid_t) a1);
    case SYS_yield:
      sys_yield();
      return 0;
    case SYS_exofork:
		  return sys_exofork();
f010511a:	89 d0                	mov    %edx,%eax
f010511c:	e9 d7 04 00 00       	jmp    f01055f8 <syscall+0x658>
  // check whether the current environment has permission to set
  // envid's status.

  // LAB 4: Your code here.
  struct Env *e;
  int ret = envid2env(envid, &e, 1);
f0105121:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105128:	00 
f0105129:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010512c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105130:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105133:	89 04 24             	mov    %eax,(%esp)
f0105136:	e8 64 e5 ff ff       	call   f010369f <envid2env>
  if (ret < 0) {
f010513b:	85 c0                	test   %eax,%eax
f010513d:	0f 88 b5 04 00 00    	js     f01055f8 <syscall+0x658>
    return ret;
  } else if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) {
f0105143:	83 7d 10 04          	cmpl   $0x4,0x10(%ebp)
f0105147:	74 06                	je     f010514f <syscall+0x1af>
f0105149:	83 7d 10 02          	cmpl   $0x2,0x10(%ebp)
f010514d:	75 13                	jne    f0105162 <syscall+0x1c2>
    return -E_INVAL;
  }
  e->env_status = status;
f010514f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105152:	8b 75 10             	mov    0x10(%ebp),%esi
f0105155:	89 70 54             	mov    %esi,0x54(%eax)
  return 0;
f0105158:	b8 00 00 00 00       	mov    $0x0,%eax
f010515d:	e9 96 04 00 00       	jmp    f01055f8 <syscall+0x658>
  struct Env *e;
  int ret = envid2env(envid, &e, 1);
  if (ret < 0) {
    return ret;
  } else if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) {
    return -E_INVAL;
f0105162:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
      sys_yield();
      return 0;
    case SYS_exofork:
		  return sys_exofork();
    case SYS_env_set_status:
		  return sys_env_set_status((envid_t)a1, a2);
f0105167:	e9 8c 04 00 00       	jmp    f01055f8 <syscall+0x658>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
  // LAB 4: Your code here.
  struct Env *e;
  int ret = envid2env(envid, &e, 1);
f010516c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105173:	00 
f0105174:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105177:	89 44 24 04          	mov    %eax,0x4(%esp)
f010517b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010517e:	89 04 24             	mov    %eax,(%esp)
f0105181:	e8 19 e5 ff ff       	call   f010369f <envid2env>
  if (ret < 0) {
f0105186:	85 c0                	test   %eax,%eax
f0105188:	0f 88 6a 04 00 00    	js     f01055f8 <syscall+0x658>
    return ret;
  }
  e->env_pgfault_upcall = func;
f010518e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105191:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105194:	89 48 64             	mov    %ecx,0x64(%eax)
  return 0;
f0105197:	b8 00 00 00 00       	mov    $0x0,%eax
f010519c:	e9 57 04 00 00       	jmp    f01055f8 <syscall+0x658>
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
  if ((uint32_t)dstva % PGSIZE)
f01051a1:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f01051a8:	0f 85 1d 04 00 00    	jne    f01055cb <syscall+0x62b>
    return -E_INVAL;

  curenv->env_ipc_recving = 1;
f01051ae:	e8 e6 16 00 00       	call   f0106899 <cpunum>
f01051b3:	6b c0 74             	imul   $0x74,%eax,%eax
f01051b6:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f01051bc:	c6 40 68 01          	movb   $0x1,0x68(%eax)

  if ((uint32_t) dstva < UTOP)
f01051c0:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f01051c7:	77 14                	ja     f01051dd <syscall+0x23d>
    curenv->env_ipc_dstva = dstva;
f01051c9:	e8 cb 16 00 00       	call   f0106899 <cpunum>
f01051ce:	6b c0 74             	imul   $0x74,%eax,%eax
f01051d1:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f01051d7:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01051da:	89 78 6c             	mov    %edi,0x6c(%eax)

  curenv->env_status = ENV_NOT_RUNNABLE;
f01051dd:	e8 b7 16 00 00       	call   f0106899 <cpunum>
f01051e2:	6b c0 74             	imul   $0x74,%eax,%eax
f01051e5:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f01051eb:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
  sched_yield();
f01051f2:	e8 d7 fc ff ff       	call   f0104ece <sched_yield>
  struct Env* e;
  int r;
  pte_t* ppte;
  struct PageInfo *pp;

  if((r = envid2env(envid, &e, 0)) < 0)
f01051f7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01051fe:	00 
f01051ff:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0105202:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105206:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105209:	89 04 24             	mov    %eax,(%esp)
f010520c:	e8 8e e4 ff ff       	call   f010369f <envid2env>
f0105211:	85 c0                	test   %eax,%eax
f0105213:	0f 88 df 03 00 00    	js     f01055f8 <syscall+0x658>
    return r;

  if ((uint32_t)srcva < UTOP && (uint32_t)srcva % PGSIZE)
f0105219:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0105220:	0f 87 c0 03 00 00    	ja     f01055e6 <syscall+0x646>
f0105226:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f010522d:	0f 84 9f 03 00 00    	je     f01055d2 <syscall+0x632>
f0105233:	e9 d0 00 00 00       	jmp    f0105308 <syscall+0x368>

  if (!e->env_ipc_recving)
    return -E_IPC_NOT_RECV;

  if ((uint32_t)srcva < UTOP &&
      (!(perm & PTE_U) || !(perm & PTE_P) || (perm & ~PTE_SYSCALL)) )
f0105238:	8b 45 18             	mov    0x18(%ebp),%eax
f010523b:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
    return -E_INVAL;

  if (!e->env_ipc_recving)
    return -E_IPC_NOT_RECV;

  if ((uint32_t)srcva < UTOP &&
f0105240:	83 f8 05             	cmp    $0x5,%eax
f0105243:	0f 85 c9 00 00 00    	jne    f0105312 <syscall+0x372>
      (!(perm & PTE_U) || !(perm & PTE_P) || (perm & ~PTE_SYSCALL)) )
    return -E_INVAL;


  if ((uint32_t)srcva < UTOP) {
    pp = page_lookup(curenv->env_pgdir, srcva, &ppte);
f0105249:	e8 4b 16 00 00       	call   f0106899 <cpunum>
f010524e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105251:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105255:	8b 7d 14             	mov    0x14(%ebp),%edi
f0105258:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010525c:	6b c0 74             	imul   $0x74,%eax,%eax
f010525f:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0105265:	8b 40 60             	mov    0x60(%eax),%eax
f0105268:	89 04 24             	mov    %eax,(%esp)
f010526b:	e8 b1 c0 ff ff       	call   f0101321 <page_lookup>

    if (!pp || !ppte)
f0105270:	85 c0                	test   %eax,%eax
f0105272:	0f 84 a4 00 00 00    	je     f010531c <syscall+0x37c>
f0105278:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010527b:	85 d2                	test   %edx,%edx
f010527d:	0f 84 a3 00 00 00    	je     f0105326 <syscall+0x386>
      return -E_INVAL;

    if (perm & PTE_W && !(*ppte & PTE_W))
f0105283:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0105287:	74 09                	je     f0105292 <syscall+0x2f2>
f0105289:	f6 02 02             	testb  $0x2,(%edx)
f010528c:	0f 84 9e 00 00 00    	je     f0105330 <syscall+0x390>
      return -E_INVAL;

    if ((r = page_insert(e->env_pgdir, pp, e->env_ipc_dstva, perm)) < 0)
f0105292:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105295:	8b 75 18             	mov    0x18(%ebp),%esi
f0105298:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010529c:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f010529f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01052a3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052a7:	8b 42 60             	mov    0x60(%edx),%eax
f01052aa:	89 04 24             	mov    %eax,(%esp)
f01052ad:	e8 66 c1 ff ff       	call   f0101418 <page_insert>
f01052b2:	85 c0                	test   %eax,%eax
f01052b4:	0f 88 3e 03 00 00    	js     f01055f8 <syscall+0x658>
      return r;
    e->env_ipc_perm = perm;
f01052ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01052bd:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01052c0:	89 48 78             	mov    %ecx,0x78(%eax)
f01052c3:	eb 07                	jmp    f01052cc <syscall+0x32c>
  } else
    e->env_ipc_perm = 0;
f01052c5:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)

  e->env_ipc_recving = 0;
f01052cc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01052cf:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
  e->env_ipc_from = curenv->env_id;
f01052d3:	e8 c1 15 00 00       	call   f0106899 <cpunum>
f01052d8:	6b c0 74             	imul   $0x74,%eax,%eax
f01052db:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f01052e1:	8b 40 48             	mov    0x48(%eax),%eax
f01052e4:	89 43 74             	mov    %eax,0x74(%ebx)
  e->env_ipc_value = value;
f01052e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01052ea:	8b 7d 10             	mov    0x10(%ebp),%edi
f01052ed:	89 78 70             	mov    %edi,0x70(%eax)
  e->env_status = ENV_RUNNABLE;
f01052f0:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)

  e->env_tf.tf_regs.reg_eax = 0;
f01052f7:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  return 0;
f01052fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0105303:	e9 f0 02 00 00       	jmp    f01055f8 <syscall+0x658>

  if((r = envid2env(envid, &e, 0)) < 0)
    return r;

  if ((uint32_t)srcva < UTOP && (uint32_t)srcva % PGSIZE)
    return -E_INVAL;
f0105308:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010530d:	e9 e6 02 00 00       	jmp    f01055f8 <syscall+0x658>
  if (!e->env_ipc_recving)
    return -E_IPC_NOT_RECV;

  if ((uint32_t)srcva < UTOP &&
      (!(perm & PTE_U) || !(perm & PTE_P) || (perm & ~PTE_SYSCALL)) )
    return -E_INVAL;
f0105312:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105317:	e9 dc 02 00 00       	jmp    f01055f8 <syscall+0x658>

  if ((uint32_t)srcva < UTOP) {
    pp = page_lookup(curenv->env_pgdir, srcva, &ppte);

    if (!pp || !ppte)
      return -E_INVAL;
f010531c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105321:	e9 d2 02 00 00       	jmp    f01055f8 <syscall+0x658>
f0105326:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010532b:	e9 c8 02 00 00       	jmp    f01055f8 <syscall+0x658>

    if (perm & PTE_W && !(*ppte & PTE_W))
      return -E_INVAL;
f0105330:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105335:	e9 be 02 00 00       	jmp    f01055f8 <syscall+0x658>
  //   allocated!

  // LAB 4: Your code here.
  struct Env *e;
  int ret;
  if ((ret = envid2env(envid, &e, 1)) < 0) {
f010533a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105341:	00 
f0105342:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105345:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105349:	8b 45 0c             	mov    0xc(%ebp),%eax
f010534c:	89 04 24             	mov    %eax,(%esp)
f010534f:	e8 4b e3 ff ff       	call   f010369f <envid2env>
f0105354:	85 c0                	test   %eax,%eax
f0105356:	78 64                	js     f01053bc <syscall+0x41c>
    return ret;
  } else if ((uintptr_t)va >= UTOP || (uintptr_t) va % PGSIZE != 0) {
f0105358:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010535f:	77 5f                	ja     f01053c0 <syscall+0x420>
f0105361:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0105368:	75 5d                	jne    f01053c7 <syscall+0x427>
		return -E_INVAL;
	} else if ((perm & ~PTE_SYSCALL) != 0) {
f010536a:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010536d:	81 e3 f8 f1 ff ff    	and    $0xfffff1f8,%ebx
f0105373:	75 59                	jne    f01053ce <syscall+0x42e>
		return -E_INVAL;
	}

  struct PageInfo *p = page_alloc(ALLOC_ZERO);
f0105375:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010537c:	e8 35 bd ff ff       	call   f01010b6 <page_alloc>
f0105381:	89 c6                	mov    %eax,%esi
  if (!p) {
f0105383:	85 c0                	test   %eax,%eax
f0105385:	74 4e                	je     f01053d5 <syscall+0x435>
    return -E_NO_MEM;
  }

  if ((ret = page_insert(e->env_pgdir, p, va, perm | PTE_U | PTE_P)) < 0) {
f0105387:	8b 45 14             	mov    0x14(%ebp),%eax
f010538a:	83 c8 05             	or     $0x5,%eax
f010538d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105391:	8b 45 10             	mov    0x10(%ebp),%eax
f0105394:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105398:	89 74 24 04          	mov    %esi,0x4(%esp)
f010539c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010539f:	8b 40 60             	mov    0x60(%eax),%eax
f01053a2:	89 04 24             	mov    %eax,(%esp)
f01053a5:	e8 6e c0 ff ff       	call   f0101418 <page_insert>
f01053aa:	89 c7                	mov    %eax,%edi
f01053ac:	85 c0                	test   %eax,%eax
f01053ae:	79 2a                	jns    f01053da <syscall+0x43a>
    page_free(p);
f01053b0:	89 34 24             	mov    %esi,(%esp)
f01053b3:	e8 ad bd ff ff       	call   f0101165 <page_free>
    return ret;
f01053b8:	89 fb                	mov    %edi,%ebx
f01053ba:	eb 1e                	jmp    f01053da <syscall+0x43a>

  // LAB 4: Your code here.
  struct Env *e;
  int ret;
  if ((ret = envid2env(envid, &e, 1)) < 0) {
    return ret;
f01053bc:	89 c3                	mov    %eax,%ebx
f01053be:	eb 1a                	jmp    f01053da <syscall+0x43a>
  } else if ((uintptr_t)va >= UTOP || (uintptr_t) va % PGSIZE != 0) {
		return -E_INVAL;
f01053c0:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01053c5:	eb 13                	jmp    f01053da <syscall+0x43a>
f01053c7:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01053cc:	eb 0c                	jmp    f01053da <syscall+0x43a>
	} else if ((perm & ~PTE_SYSCALL) != 0) {
		return -E_INVAL;
f01053ce:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01053d3:	eb 05                	jmp    f01053da <syscall+0x43a>
	}

  struct PageInfo *p = page_alloc(ALLOC_ZERO);
  if (!p) {
    return -E_NO_MEM;
f01053d5:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
      return sys_ipc_recv((void *)a1);
    case SYS_ipc_try_send:
      return sys_ipc_try_send((envid_t)a1, (uint32_t) a2, (void *)a3, (unsigned) a4);

    case SYS_page_alloc:
		  return sys_page_alloc((envid_t)a1, (void *)a2, a3);
f01053da:	89 d8                	mov    %ebx,%eax
f01053dc:	e9 17 02 00 00       	jmp    f01055f8 <syscall+0x658>
  //   parameters for correctness.
  //   Use the third argument to page_lookup() to
  //   check the current permissions on the page.

  // LAB 4: Your code here.
  if ((perm & ~PTE_SYSCALL) != 0) {
f01053e1:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f01053e8:	0f 85 c9 00 00 00    	jne    f01054b7 <syscall+0x517>
		return -E_INVAL;
	}

  if ((uintptr_t) srcva >= UTOP || (uintptr_t) dstva >= UTOP
f01053ee:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01053f5:	0f 87 c3 00 00 00    	ja     f01054be <syscall+0x51e>
f01053fb:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0105402:	0f 87 b6 00 00 00    	ja     f01054be <syscall+0x51e>
f0105408:	8b 45 10             	mov    0x10(%ebp),%eax
f010540b:	0b 45 18             	or     0x18(%ebp),%eax
	    || (uintptr_t) srcva % PGSIZE != 0 || (uintptr_t) dstva % PGSIZE) {
f010540e:	a9 ff 0f 00 00       	test   $0xfff,%eax
f0105413:	0f 85 ac 00 00 00    	jne    f01054c5 <syscall+0x525>
		return -E_INVAL;
	}

  struct Env *src;
  int ret = envid2env(srcenvid, &src, 1);
f0105419:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105420:	00 
f0105421:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0105424:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105428:	8b 45 0c             	mov    0xc(%ebp),%eax
f010542b:	89 04 24             	mov    %eax,(%esp)
f010542e:	e8 6c e2 ff ff       	call   f010369f <envid2env>
  if (ret < 0) {
		return ret;
f0105433:	89 c2                	mov    %eax,%edx
		return -E_INVAL;
	}

  struct Env *src;
  int ret = envid2env(srcenvid, &src, 1);
  if (ret < 0) {
f0105435:	85 c0                	test   %eax,%eax
f0105437:	0f 88 9b 00 00 00    	js     f01054d8 <syscall+0x538>
		return ret;
	}

  struct Env *dst;
  ret = envid2env(dstenvid, &dst, 1);
f010543d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105444:	00 
f0105445:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0105448:	89 44 24 04          	mov    %eax,0x4(%esp)
f010544c:	8b 45 14             	mov    0x14(%ebp),%eax
f010544f:	89 04 24             	mov    %eax,(%esp)
f0105452:	e8 48 e2 ff ff       	call   f010369f <envid2env>
	if (ret < 0) {
		return ret;
f0105457:	89 c2                	mov    %eax,%edx
		return ret;
	}

  struct Env *dst;
  ret = envid2env(dstenvid, &dst, 1);
	if (ret < 0) {
f0105459:	85 c0                	test   %eax,%eax
f010545b:	78 7b                	js     f01054d8 <syscall+0x538>
		return ret;
	}

  pte_t *srcpte;
  struct PageInfo *p = page_lookup(src->env_pgdir, srcva, &srcpte);
f010545d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105460:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105464:	8b 45 10             	mov    0x10(%ebp),%eax
f0105467:	89 44 24 04          	mov    %eax,0x4(%esp)
f010546b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010546e:	8b 40 60             	mov    0x60(%eax),%eax
f0105471:	89 04 24             	mov    %eax,(%esp)
f0105474:	e8 a8 be ff ff       	call   f0101321 <page_lookup>
  if (!p) {
f0105479:	85 c0                	test   %eax,%eax
f010547b:	74 4f                	je     f01054cc <syscall+0x52c>
    return -E_INVAL;
  } else if ((perm & PTE_W) && !(*srcpte & PTE_W)) {
f010547d:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0105481:	74 08                	je     f010548b <syscall+0x4eb>
f0105483:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105486:	f6 02 02             	testb  $0x2,(%edx)
f0105489:	74 48                	je     f01054d3 <syscall+0x533>
		return -E_INVAL;
	}

  ret = page_insert(dst->env_pgdir, p, dstva, perm);
f010548b:	8b 4d 1c             	mov    0x1c(%ebp),%ecx
f010548e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105492:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105495:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105499:	89 44 24 04          	mov    %eax,0x4(%esp)
f010549d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01054a0:	8b 40 60             	mov    0x60(%eax),%eax
f01054a3:	89 04 24             	mov    %eax,(%esp)
f01054a6:	e8 6d bf ff ff       	call   f0101418 <page_insert>
f01054ab:	85 c0                	test   %eax,%eax
f01054ad:	ba 00 00 00 00       	mov    $0x0,%edx
f01054b2:	0f 4e d0             	cmovle %eax,%edx
f01054b5:	eb 21                	jmp    f01054d8 <syscall+0x538>
  //   Use the third argument to page_lookup() to
  //   check the current permissions on the page.

  // LAB 4: Your code here.
  if ((perm & ~PTE_SYSCALL) != 0) {
		return -E_INVAL;
f01054b7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f01054bc:	eb 1a                	jmp    f01054d8 <syscall+0x538>
	}

  if ((uintptr_t) srcva >= UTOP || (uintptr_t) dstva >= UTOP
	    || (uintptr_t) srcva % PGSIZE != 0 || (uintptr_t) dstva % PGSIZE) {
		return -E_INVAL;
f01054be:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f01054c3:	eb 13                	jmp    f01054d8 <syscall+0x538>
f01054c5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f01054ca:	eb 0c                	jmp    f01054d8 <syscall+0x538>
	}

  pte_t *srcpte;
  struct PageInfo *p = page_lookup(src->env_pgdir, srcva, &srcpte);
  if (!p) {
    return -E_INVAL;
f01054cc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f01054d1:	eb 05                	jmp    f01054d8 <syscall+0x538>
  } else if ((perm & PTE_W) && !(*srcpte & PTE_W)) {
		return -E_INVAL;
f01054d3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
      return sys_ipc_try_send((envid_t)a1, (uint32_t) a2, (void *)a3, (unsigned) a4);

    case SYS_page_alloc:
		  return sys_page_alloc((envid_t)a1, (void *)a2, a3);
    case SYS_page_map:
		  return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, 
f01054d8:	89 d0                	mov    %edx,%eax
f01054da:	e9 19 01 00 00       	jmp    f01055f8 <syscall+0x658>
sys_page_unmap(envid_t envid, void *va)
{
  // Hint: This function is a wrapper around page_remove().

  // LAB 4: Your code here.
  if ((uintptr_t) va >= UTOP || (uintptr_t) va % PGSIZE != 0) {
f01054df:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01054e6:	77 45                	ja     f010552d <syscall+0x58d>
f01054e8:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01054ef:	75 43                	jne    f0105534 <syscall+0x594>
		return -E_INVAL;
	}

  struct Env *e;
  int ret = envid2env(envid, &e, 1);
f01054f1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01054f8:	00 
f01054f9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01054fc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105500:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105503:	89 04 24             	mov    %eax,(%esp)
f0105506:	e8 94 e1 ff ff       	call   f010369f <envid2env>
  if (ret < 0) {
    return ret;
f010550b:	89 c2                	mov    %eax,%edx
		return -E_INVAL;
	}

  struct Env *e;
  int ret = envid2env(envid, &e, 1);
  if (ret < 0) {
f010550d:	85 c0                	test   %eax,%eax
f010550f:	78 28                	js     f0105539 <syscall+0x599>
    return ret;
  }
  page_remove(e->env_pgdir, va);
f0105511:	8b 45 10             	mov    0x10(%ebp),%eax
f0105514:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105518:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010551b:	8b 40 60             	mov    0x60(%eax),%eax
f010551e:	89 04 24             	mov    %eax,(%esp)
f0105521:	e8 a9 be ff ff       	call   f01013cf <page_remove>
  return 0;
f0105526:	ba 00 00 00 00       	mov    $0x0,%edx
f010552b:	eb 0c                	jmp    f0105539 <syscall+0x599>
{
  // Hint: This function is a wrapper around page_remove().

  // LAB 4: Your code here.
  if ((uintptr_t) va >= UTOP || (uintptr_t) va % PGSIZE != 0) {
		return -E_INVAL;
f010552d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0105532:	eb 05                	jmp    f0105539 <syscall+0x599>
f0105534:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
		  return sys_page_alloc((envid_t)a1, (void *)a2, a3);
    case SYS_page_map:
		  return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, 
                          (void *)a4, (int)a5);
    case SYS_page_unmap:
		  return sys_page_unmap((envid_t)a1, (void *)a2);
f0105539:	89 d0                	mov    %edx,%eax
f010553b:	e9 b8 00 00 00       	jmp    f01055f8 <syscall+0x658>
  // Remember to check whether the user has supplied us with a good
  // address!
    int r;
    struct Env *env;

    if ((r = envid2env(envid, &env, true)) < 0)
f0105540:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105547:	00 
f0105548:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010554b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010554f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105552:	89 04 24             	mov    %eax,(%esp)
f0105555:	e8 45 e1 ff ff       	call   f010369f <envid2env>
        return r;
f010555a:	89 c2                	mov    %eax,%edx
  // Remember to check whether the user has supplied us with a good
  // address!
    int r;
    struct Env *env;

    if ((r = envid2env(envid, &env, true)) < 0)
f010555c:	85 c0                	test   %eax,%eax
f010555e:	78 60                	js     f01055c0 <syscall+0x620>
		  return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, 
                          (void *)a4, (int)a5);
    case SYS_page_unmap:
		  return sys_page_unmap((envid_t)a1, (void *)a2);
    case SYS_env_set_trapframe:
          return sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
f0105560:	8b 75 10             	mov    0x10(%ebp),%esi
    struct Env *env;

    if ((r = envid2env(envid, &env, true)) < 0)
        return r;

    if ((r = user_mem_check(env, tf, sizeof(struct Trapframe), PTE_U)) < 0)
f0105563:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010556a:	00 
f010556b:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0105572:	00 
f0105573:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105577:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010557a:	89 04 24             	mov    %eax,(%esp)
f010557d:	e8 ab df ff ff       	call   f010352d <user_mem_check>
f0105582:	85 c0                	test   %eax,%eax
f0105584:	78 38                	js     f01055be <syscall+0x61e>
        return r;

    env->env_tf = *tf;
f0105586:	b9 11 00 00 00       	mov    $0x11,%ecx
f010558b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010558e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

    env->env_tf.tf_eflags &= ~FL_IOPL_MASK;
f0105590:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105593:	8b 50 38             	mov    0x38(%eax),%edx
f0105596:	80 e6 cf             	and    $0xcf,%dh

    env->env_tf.tf_eflags |= FL_IF;
f0105599:	80 ce 02             	or     $0x2,%dh
f010559c:	89 50 38             	mov    %edx,0x38(%eax)

    env->env_tf.tf_ds = GD_UD | 3;
f010559f:	66 c7 40 24 23 00    	movw   $0x23,0x24(%eax)
    env->env_tf.tf_es = GD_UD | 3;
f01055a5:	66 c7 40 20 23 00    	movw   $0x23,0x20(%eax)
    env->env_tf.tf_ss = GD_UD | 3;
f01055ab:	66 c7 40 40 23 00    	movw   $0x23,0x40(%eax)
    env->env_tf.tf_cs = GD_UT | 3;
f01055b1:	66 c7 40 34 1b 00    	movw   $0x1b,0x34(%eax)

    return 0;
f01055b7:	ba 00 00 00 00       	mov    $0x0,%edx
f01055bc:	eb 02                	jmp    f01055c0 <syscall+0x620>

    if ((r = envid2env(envid, &env, true)) < 0)
        return r;

    if ((r = user_mem_check(env, tf, sizeof(struct Trapframe), PTE_U)) < 0)
        return r;
f01055be:	89 c2                	mov    %eax,%edx
		  return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, 
                          (void *)a4, (int)a5);
    case SYS_page_unmap:
		  return sys_page_unmap((envid_t)a1, (void *)a2);
    case SYS_env_set_trapframe:
          return sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
f01055c0:	89 d0                	mov    %edx,%eax
f01055c2:	eb 34                	jmp    f01055f8 <syscall+0x658>
    default:
      return -E_INVAL;
f01055c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01055c9:	eb 2d                	jmp    f01055f8 <syscall+0x658>
    case SYS_env_set_status:
		  return sys_env_set_status((envid_t)a1, a2);
    case SYS_env_set_pgfault_upcall:
      return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
    case SYS_ipc_recv:
      return sys_ipc_recv((void *)a1);
f01055cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01055d0:	eb 26                	jmp    f01055f8 <syscall+0x658>
    return r;

  if ((uint32_t)srcva < UTOP && (uint32_t)srcva % PGSIZE)
    return -E_INVAL;

  if (!e->env_ipc_recving)
f01055d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01055d5:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f01055d9:	0f 85 59 fc ff ff    	jne    f0105238 <syscall+0x298>
    return -E_IPC_NOT_RECV;
f01055df:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f01055e4:	eb 12                	jmp    f01055f8 <syscall+0x658>
    return r;

  if ((uint32_t)srcva < UTOP && (uint32_t)srcva % PGSIZE)
    return -E_INVAL;

  if (!e->env_ipc_recving)
f01055e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01055e9:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f01055ed:	0f 85 d2 fc ff ff    	jne    f01052c5 <syscall+0x325>
    return -E_IPC_NOT_RECV;
f01055f3:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
          return sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
    default:
      return -E_INVAL;
	}
  
}
f01055f8:	83 c4 2c             	add    $0x2c,%esp
f01055fb:	5b                   	pop    %ebx
f01055fc:	5e                   	pop    %esi
f01055fd:	5f                   	pop    %edi
f01055fe:	5d                   	pop    %ebp
f01055ff:	c3                   	ret    

f0105600 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
               int type, uintptr_t addr)
{
f0105600:	55                   	push   %ebp
f0105601:	89 e5                	mov    %esp,%ebp
f0105603:	57                   	push   %edi
f0105604:	56                   	push   %esi
f0105605:	53                   	push   %ebx
f0105606:	83 ec 14             	sub    $0x14,%esp
f0105609:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010560c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010560f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105612:	8b 75 08             	mov    0x8(%ebp),%esi
  int l = *region_left, r = *region_right, any_matches = 0;
f0105615:	8b 1a                	mov    (%edx),%ebx
f0105617:	8b 01                	mov    (%ecx),%eax
f0105619:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010561c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

  while (l <= r) {
f0105623:	e9 88 00 00 00       	jmp    f01056b0 <stab_binsearch+0xb0>
    int true_m = (l + r) / 2, m = true_m;
f0105628:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010562b:	01 d8                	add    %ebx,%eax
f010562d:	89 c7                	mov    %eax,%edi
f010562f:	c1 ef 1f             	shr    $0x1f,%edi
f0105632:	01 c7                	add    %eax,%edi
f0105634:	d1 ff                	sar    %edi
f0105636:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0105639:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010563c:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f010563f:	89 f8                	mov    %edi,%eax

    // search for earliest stab with right type
    while (m >= l && stabs[m].n_type != type)
f0105641:	eb 03                	jmp    f0105646 <stab_binsearch+0x46>
      m--;
f0105643:	83 e8 01             	sub    $0x1,%eax

  while (l <= r) {
    int true_m = (l + r) / 2, m = true_m;

    // search for earliest stab with right type
    while (m >= l && stabs[m].n_type != type)
f0105646:	39 c3                	cmp    %eax,%ebx
f0105648:	7f 1f                	jg     f0105669 <stab_binsearch+0x69>
f010564a:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010564e:	83 ea 0c             	sub    $0xc,%edx
f0105651:	39 f1                	cmp    %esi,%ecx
f0105653:	75 ee                	jne    f0105643 <stab_binsearch+0x43>
f0105655:	89 45 e8             	mov    %eax,-0x18(%ebp)
      continue;
    }

    // actual binary search
    any_matches = 1;
    if (stabs[m].n_value < addr) {
f0105658:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010565b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010565e:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0105662:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0105665:	76 18                	jbe    f010567f <stab_binsearch+0x7f>
f0105667:	eb 05                	jmp    f010566e <stab_binsearch+0x6e>

    // search for earliest stab with right type
    while (m >= l && stabs[m].n_type != type)
      m--;
    if (m < l) {                // no match in [l, m]
      l = true_m + 1;
f0105669:	8d 5f 01             	lea    0x1(%edi),%ebx
      continue;
f010566c:	eb 42                	jmp    f01056b0 <stab_binsearch+0xb0>
    }

    // actual binary search
    any_matches = 1;
    if (stabs[m].n_value < addr) {
      *region_left = m;
f010566e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105671:	89 03                	mov    %eax,(%ebx)
      l = true_m + 1;
f0105673:	8d 5f 01             	lea    0x1(%edi),%ebx
      l = true_m + 1;
      continue;
    }

    // actual binary search
    any_matches = 1;
f0105676:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010567d:	eb 31                	jmp    f01056b0 <stab_binsearch+0xb0>
    if (stabs[m].n_value < addr) {
      *region_left = m;
      l = true_m + 1;
    } else if (stabs[m].n_value > addr) {
f010567f:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0105682:	73 17                	jae    f010569b <stab_binsearch+0x9b>
      *region_right = m - 1;
f0105684:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0105687:	83 e8 01             	sub    $0x1,%eax
f010568a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010568d:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105690:	89 07                	mov    %eax,(%edi)
      l = true_m + 1;
      continue;
    }

    // actual binary search
    any_matches = 1;
f0105692:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105699:	eb 15                	jmp    f01056b0 <stab_binsearch+0xb0>
      *region_right = m - 1;
      r = m - 1;
    } else {
      // exact match for 'addr', but continue loop to find
      // *region_right
      *region_left = m;
f010569b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010569e:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01056a1:	89 1f                	mov    %ebx,(%edi)
      l = m;
      addr++;
f01056a3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01056a7:	89 c3                	mov    %eax,%ebx
      l = true_m + 1;
      continue;
    }

    // actual binary search
    any_matches = 1;
f01056a9:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
               int type, uintptr_t addr)
{
  int l = *region_left, r = *region_right, any_matches = 0;

  while (l <= r) {
f01056b0:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01056b3:	0f 8e 6f ff ff ff    	jle    f0105628 <stab_binsearch+0x28>
      l = m;
      addr++;
    }
  }

  if (!any_matches)
f01056b9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01056bd:	75 0f                	jne    f01056ce <stab_binsearch+0xce>
    *region_right = *region_left - 1;
f01056bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01056c2:	8b 00                	mov    (%eax),%eax
f01056c4:	83 e8 01             	sub    $0x1,%eax
f01056c7:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01056ca:	89 07                	mov    %eax,(%edi)
f01056cc:	eb 2c                	jmp    f01056fa <stab_binsearch+0xfa>
  else {
    // find rightmost region containing 'addr'
    for (l = *region_right;
f01056ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01056d1:	8b 00                	mov    (%eax),%eax
         l > *region_left && stabs[l].n_type != type;
f01056d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01056d6:	8b 0f                	mov    (%edi),%ecx
f01056d8:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01056db:	8b 7d ec             	mov    -0x14(%ebp),%edi
f01056de:	8d 14 97             	lea    (%edi,%edx,4),%edx

  if (!any_matches)
    *region_right = *region_left - 1;
  else {
    // find rightmost region containing 'addr'
    for (l = *region_right;
f01056e1:	eb 03                	jmp    f01056e6 <stab_binsearch+0xe6>
         l > *region_left && stabs[l].n_type != type;
         l--)
f01056e3:	83 e8 01             	sub    $0x1,%eax

  if (!any_matches)
    *region_right = *region_left - 1;
  else {
    // find rightmost region containing 'addr'
    for (l = *region_right;
f01056e6:	39 c8                	cmp    %ecx,%eax
f01056e8:	7e 0b                	jle    f01056f5 <stab_binsearch+0xf5>
         l > *region_left && stabs[l].n_type != type;
f01056ea:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01056ee:	83 ea 0c             	sub    $0xc,%edx
f01056f1:	39 f3                	cmp    %esi,%ebx
f01056f3:	75 ee                	jne    f01056e3 <stab_binsearch+0xe3>
         l--)
      /* do nothing */;
    *region_left = l;
f01056f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01056f8:	89 07                	mov    %eax,(%edi)
  }
}
f01056fa:	83 c4 14             	add    $0x14,%esp
f01056fd:	5b                   	pop    %ebx
f01056fe:	5e                   	pop    %esi
f01056ff:	5f                   	pop    %edi
f0105700:	5d                   	pop    %ebp
f0105701:	c3                   	ret    

f0105702 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0105702:	55                   	push   %ebp
f0105703:	89 e5                	mov    %esp,%ebp
f0105705:	57                   	push   %edi
f0105706:	56                   	push   %esi
f0105707:	53                   	push   %ebx
f0105708:	83 ec 4c             	sub    $0x4c,%esp
f010570b:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010570e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  const struct Stab *stabs, *stab_end;
  const char *stabstr, *stabstr_end;
  int lfile, rfile, lfun, rfun, lline, rline;

  // Initialize *info
  info->eip_file = "<unknown>";
f0105711:	c7 07 d8 86 10 f0    	movl   $0xf01086d8,(%edi)
  info->eip_line = 0;
f0105717:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
  info->eip_fn_name = "<unknown>";
f010571e:	c7 47 08 d8 86 10 f0 	movl   $0xf01086d8,0x8(%edi)
  info->eip_fn_namelen = 9;
f0105725:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
  info->eip_fn_addr = addr;
f010572c:	89 5f 10             	mov    %ebx,0x10(%edi)
  info->eip_fn_narg = 0;
f010572f:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

  // Find the relevant set of stabs
  if (addr >= ULIM) {
f0105736:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010573c:	0f 87 c1 00 00 00    	ja     f0105803 <debuginfo_eip+0x101>
    const struct UserStabData *usd = (const struct UserStabData *)USTABDATA;

    // Make sure this memory is valid.
    // Return -1 if it is not.  Hint: Call user_mem_check.
    // LAB 3: Your code here.
    int memResult = user_mem_check(curenv, usd, sizeof(usd), PTE_U);
f0105742:	e8 52 11 00 00       	call   f0106899 <cpunum>
f0105747:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010574e:	00 
f010574f:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0105756:	00 
f0105757:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f010575e:	00 
f010575f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105762:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0105768:	89 04 24             	mov    %eax,(%esp)
f010576b:	e8 bd dd ff ff       	call   f010352d <user_mem_check>

		if(memResult != 0) {
f0105770:	85 c0                	test   %eax,%eax
f0105772:	0f 85 5a 02 00 00    	jne    f01059d2 <debuginfo_eip+0x2d0>
			return -1;
		}

    stabs = usd->stabs;
f0105778:	a1 00 00 20 00       	mov    0x200000,%eax
f010577d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    stab_end = usd->stab_end;
f0105780:	8b 35 04 00 20 00    	mov    0x200004,%esi
    stabstr = usd->stabstr;
f0105786:	a1 08 00 20 00       	mov    0x200008,%eax
f010578b:	89 45 c0             	mov    %eax,-0x40(%ebp)
    stabstr_end = usd->stabstr_end;
f010578e:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0105794:	89 55 bc             	mov    %edx,-0x44(%ebp)

    // Make sure the STABS and string table memory is valid.
    // LAB 3: Your code here.
    memResult = user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U);
f0105797:	e8 fd 10 00 00       	call   f0106899 <cpunum>
f010579c:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01057a3:	00 
f01057a4:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f01057ab:	00 
f01057ac:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01057af:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01057b3:	6b c0 74             	imul   $0x74,%eax,%eax
f01057b6:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f01057bc:	89 04 24             	mov    %eax,(%esp)
f01057bf:	e8 69 dd ff ff       	call   f010352d <user_mem_check>
	 	if(memResult != 0) {
f01057c4:	85 c0                	test   %eax,%eax
f01057c6:	0f 85 0d 02 00 00    	jne    f01059d9 <debuginfo_eip+0x2d7>
			return -1;
		}

		memResult = user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U);
f01057cc:	e8 c8 10 00 00       	call   f0106899 <cpunum>
f01057d1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01057d8:	00 
f01057d9:	8b 55 bc             	mov    -0x44(%ebp),%edx
f01057dc:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01057df:	29 ca                	sub    %ecx,%edx
f01057e1:	89 54 24 08          	mov    %edx,0x8(%esp)
f01057e5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01057e9:	6b c0 74             	imul   $0x74,%eax,%eax
f01057ec:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f01057f2:	89 04 24             	mov    %eax,(%esp)
f01057f5:	e8 33 dd ff ff       	call   f010352d <user_mem_check>

		if(memResult != 0) {
f01057fa:	85 c0                	test   %eax,%eax
f01057fc:	74 1f                	je     f010581d <debuginfo_eip+0x11b>
f01057fe:	e9 dd 01 00 00       	jmp    f01059e0 <debuginfo_eip+0x2de>
  // Find the relevant set of stabs
  if (addr >= ULIM) {
    stabs = __STAB_BEGIN__;
    stab_end = __STAB_END__;
    stabstr = __STABSTR_BEGIN__;
    stabstr_end = __STABSTR_END__;
f0105803:	c7 45 bc 2c 6b 11 f0 	movl   $0xf0116b2c,-0x44(%ebp)

  // Find the relevant set of stabs
  if (addr >= ULIM) {
    stabs = __STAB_BEGIN__;
    stab_end = __STAB_END__;
    stabstr = __STABSTR_BEGIN__;
f010580a:	c7 45 c0 35 34 11 f0 	movl   $0xf0113435,-0x40(%ebp)
  info->eip_fn_narg = 0;

  // Find the relevant set of stabs
  if (addr >= ULIM) {
    stabs = __STAB_BEGIN__;
    stab_end = __STAB_END__;
f0105811:	be 34 34 11 f0       	mov    $0xf0113434,%esi
  info->eip_fn_addr = addr;
  info->eip_fn_narg = 0;

  // Find the relevant set of stabs
  if (addr >= ULIM) {
    stabs = __STAB_BEGIN__;
f0105816:	c7 45 c4 70 8c 10 f0 	movl   $0xf0108c70,-0x3c(%ebp)
		}

  }

  // String table validity checks
  if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010581d:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0105820:	39 45 c0             	cmp    %eax,-0x40(%ebp)
f0105823:	0f 83 be 01 00 00    	jae    f01059e7 <debuginfo_eip+0x2e5>
f0105829:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f010582d:	0f 85 bb 01 00 00    	jne    f01059ee <debuginfo_eip+0x2ec>
  // 'eip'.  First, we find the basic source file containing 'eip'.
  // Then, we look in that source file for the function.  Then we look
  // for the line number.

  // Search the entire set of stabs for the source file (type N_SO).
  lfile = 0;
f0105833:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  rfile = (stab_end - stabs) - 1;
f010583a:	2b 75 c4             	sub    -0x3c(%ebp),%esi
f010583d:	c1 fe 02             	sar    $0x2,%esi
f0105840:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0105846:	83 e8 01             	sub    $0x1,%eax
f0105849:	89 45 e0             	mov    %eax,-0x20(%ebp)
  stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010584c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105850:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0105857:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010585a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010585d:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105860:	89 f0                	mov    %esi,%eax
f0105862:	e8 99 fd ff ff       	call   f0105600 <stab_binsearch>
  if (lfile == 0)
f0105867:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010586a:	85 c0                	test   %eax,%eax
f010586c:	0f 84 83 01 00 00    	je     f01059f5 <debuginfo_eip+0x2f3>
    return -1;

  // Search within that file's stabs for the function definition
  // (N_FUN).
  lfun = lfile;
f0105872:	89 45 dc             	mov    %eax,-0x24(%ebp)
  rfun = rfile;
f0105875:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105878:	89 45 d8             	mov    %eax,-0x28(%ebp)
  stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010587b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010587f:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0105886:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0105889:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010588c:	89 f0                	mov    %esi,%eax
f010588e:	e8 6d fd ff ff       	call   f0105600 <stab_binsearch>

  if (lfun <= rfun) {
f0105893:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105896:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0105899:	39 f0                	cmp    %esi,%eax
f010589b:	7f 32                	jg     f01058cf <debuginfo_eip+0x1cd>
    // stabs[lfun] points to the function name
    // in the string table, but check bounds just in case.
    if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010589d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01058a0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01058a3:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f01058a6:	8b 0a                	mov    (%edx),%ecx
f01058a8:	89 4d b8             	mov    %ecx,-0x48(%ebp)
f01058ab:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f01058ae:	2b 4d c0             	sub    -0x40(%ebp),%ecx
f01058b1:	39 4d b8             	cmp    %ecx,-0x48(%ebp)
f01058b4:	73 09                	jae    f01058bf <debuginfo_eip+0x1bd>
      info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01058b6:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f01058b9:	03 4d c0             	add    -0x40(%ebp),%ecx
f01058bc:	89 4f 08             	mov    %ecx,0x8(%edi)
    info->eip_fn_addr = stabs[lfun].n_value;
f01058bf:	8b 52 08             	mov    0x8(%edx),%edx
f01058c2:	89 57 10             	mov    %edx,0x10(%edi)
    addr -= info->eip_fn_addr;
f01058c5:	29 d3                	sub    %edx,%ebx
    // Search within the function definition for the line number.
    lline = lfun;
f01058c7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    rline = rfun;
f01058ca:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01058cd:	eb 0f                	jmp    f01058de <debuginfo_eip+0x1dc>
  } else {
    // Couldn't find function stab!  Maybe we're in an assembly
    // file.  Search the whole file for the line number.
    info->eip_fn_addr = addr;
f01058cf:	89 5f 10             	mov    %ebx,0x10(%edi)
    lline = lfile;
f01058d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01058d5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    rline = rfile;
f01058d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01058db:	89 45 d0             	mov    %eax,-0x30(%ebp)
  }
  // Ignore stuff after the colon.
  info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01058de:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f01058e5:	00 
f01058e6:	8b 47 08             	mov    0x8(%edi),%eax
f01058e9:	89 04 24             	mov    %eax,(%esp)
f01058ec:	e8 3a 09 00 00       	call   f010622b <strfind>
f01058f1:	2b 47 08             	sub    0x8(%edi),%eax
f01058f4:	89 47 0c             	mov    %eax,0xc(%edi)
  // Hint:
  //	There's a particular stabs type used for line numbers.
  //	Look at the STABS documentation and <inc/stab.h> to find
  //	which one.
  // LAB 1: Your code here.
  stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01058f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01058fb:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0105902:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105905:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0105908:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010590b:	e8 f0 fc ff ff       	call   f0105600 <stab_binsearch>
	
	if (lline == rline) {
f0105910:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105913:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0105916:	75 10                	jne    f0105928 <debuginfo_eip+0x226>
		info->eip_line = stabs[lline].n_desc;
f0105918:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010591b:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010591e:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0105923:	89 47 04             	mov    %eax,0x4(%edi)
f0105926:	eb 07                	jmp    f010592f <debuginfo_eip+0x22d>
	} else {
		info->eip_line = -1;
f0105928:	c7 47 04 ff ff ff ff 	movl   $0xffffffff,0x4(%edi)
  // Search backwards from the line number for the relevant filename
  // stab.
  // We can't just use the "lfile" stab because inlined functions
  // can interpolate code from a different file!
  // Such included source files use the N_SOL stab type.
  while (lline >= lfile
f010592f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105932:	89 c6                	mov    %eax,%esi
f0105934:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105937:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010593a:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010593d:	8d 14 93             	lea    (%ebx,%edx,4),%edx
f0105940:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0105943:	89 f7                	mov    %esi,%edi
f0105945:	eb 06                	jmp    f010594d <debuginfo_eip+0x24b>
f0105947:	83 e8 01             	sub    $0x1,%eax
f010594a:	83 ea 0c             	sub    $0xc,%edx
f010594d:	89 c6                	mov    %eax,%esi
f010594f:	39 c7                	cmp    %eax,%edi
f0105951:	7f 3c                	jg     f010598f <debuginfo_eip+0x28d>
         && stabs[lline].n_type != N_SOL
f0105953:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105957:	80 f9 84             	cmp    $0x84,%cl
f010595a:	75 08                	jne    f0105964 <debuginfo_eip+0x262>
f010595c:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010595f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105962:	eb 11                	jmp    f0105975 <debuginfo_eip+0x273>
         && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105964:	80 f9 64             	cmp    $0x64,%cl
f0105967:	75 de                	jne    f0105947 <debuginfo_eip+0x245>
f0105969:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f010596d:	74 d8                	je     f0105947 <debuginfo_eip+0x245>
f010596f:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105972:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    lline--;
  if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105975:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0105978:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010597b:	8b 04 86             	mov    (%esi,%eax,4),%eax
f010597e:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0105981:	2b 55 c0             	sub    -0x40(%ebp),%edx
f0105984:	39 d0                	cmp    %edx,%eax
f0105986:	73 0a                	jae    f0105992 <debuginfo_eip+0x290>
    info->eip_file = stabstr + stabs[lline].n_strx;
f0105988:	03 45 c0             	add    -0x40(%ebp),%eax
f010598b:	89 07                	mov    %eax,(%edi)
f010598d:	eb 03                	jmp    f0105992 <debuginfo_eip+0x290>
f010598f:	8b 7d 0c             	mov    0xc(%ebp),%edi


  // Set eip_fn_narg to the number of arguments taken by the function,
  // or 0 if there was no containing function.
  if (lfun < rfun)
f0105992:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105995:	8b 5d d8             	mov    -0x28(%ebp),%ebx
    for (lline = lfun + 1;
         lline < rfun && stabs[lline].n_type == N_PSYM;
         lline++)
      info->eip_fn_narg++;

  return 0;
f0105998:	b8 00 00 00 00       	mov    $0x0,%eax
    info->eip_file = stabstr + stabs[lline].n_strx;


  // Set eip_fn_narg to the number of arguments taken by the function,
  // or 0 if there was no containing function.
  if (lfun < rfun)
f010599d:	39 da                	cmp    %ebx,%edx
f010599f:	7d 60                	jge    f0105a01 <debuginfo_eip+0x2ff>
    for (lline = lfun + 1;
f01059a1:	83 c2 01             	add    $0x1,%edx
f01059a4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01059a7:	89 d0                	mov    %edx,%eax
f01059a9:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01059ac:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01059af:	8d 14 96             	lea    (%esi,%edx,4),%edx
f01059b2:	eb 04                	jmp    f01059b8 <debuginfo_eip+0x2b6>
         lline < rfun && stabs[lline].n_type == N_PSYM;
         lline++)
      info->eip_fn_narg++;
f01059b4:	83 47 14 01          	addl   $0x1,0x14(%edi)


  // Set eip_fn_narg to the number of arguments taken by the function,
  // or 0 if there was no containing function.
  if (lfun < rfun)
    for (lline = lfun + 1;
f01059b8:	39 c3                	cmp    %eax,%ebx
f01059ba:	7e 40                	jle    f01059fc <debuginfo_eip+0x2fa>
         lline < rfun && stabs[lline].n_type == N_PSYM;
f01059bc:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01059c0:	83 c0 01             	add    $0x1,%eax
f01059c3:	83 c2 0c             	add    $0xc,%edx
f01059c6:	80 f9 a0             	cmp    $0xa0,%cl
f01059c9:	74 e9                	je     f01059b4 <debuginfo_eip+0x2b2>
         lline++)
      info->eip_fn_narg++;

  return 0;
f01059cb:	b8 00 00 00 00       	mov    $0x0,%eax
f01059d0:	eb 2f                	jmp    f0105a01 <debuginfo_eip+0x2ff>
    // Return -1 if it is not.  Hint: Call user_mem_check.
    // LAB 3: Your code here.
    int memResult = user_mem_check(curenv, usd, sizeof(usd), PTE_U);

		if(memResult != 0) {
			return -1;
f01059d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01059d7:	eb 28                	jmp    f0105a01 <debuginfo_eip+0x2ff>

    // Make sure the STABS and string table memory is valid.
    // LAB 3: Your code here.
    memResult = user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U);
	 	if(memResult != 0) {
			return -1;
f01059d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01059de:	eb 21                	jmp    f0105a01 <debuginfo_eip+0x2ff>
		}

		memResult = user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U);

		if(memResult != 0) {
			return -1;
f01059e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01059e5:	eb 1a                	jmp    f0105a01 <debuginfo_eip+0x2ff>

  }

  // String table validity checks
  if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
    return -1;
f01059e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01059ec:	eb 13                	jmp    f0105a01 <debuginfo_eip+0x2ff>
f01059ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01059f3:	eb 0c                	jmp    f0105a01 <debuginfo_eip+0x2ff>
  // Search the entire set of stabs for the source file (type N_SO).
  lfile = 0;
  rfile = (stab_end - stabs) - 1;
  stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  if (lfile == 0)
    return -1;
f01059f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01059fa:	eb 05                	jmp    f0105a01 <debuginfo_eip+0x2ff>
    for (lline = lfun + 1;
         lline < rfun && stabs[lline].n_type == N_PSYM;
         lline++)
      info->eip_fn_narg++;

  return 0;
f01059fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105a01:	83 c4 4c             	add    $0x4c,%esp
f0105a04:	5b                   	pop    %ebx
f0105a05:	5e                   	pop    %esi
f0105a06:	5f                   	pop    %edi
f0105a07:	5d                   	pop    %ebp
f0105a08:	c3                   	ret    
f0105a09:	66 90                	xchg   %ax,%ax
f0105a0b:	66 90                	xchg   %ax,%ax
f0105a0d:	66 90                	xchg   %ax,%ax
f0105a0f:	90                   	nop

f0105a10 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
         unsigned long long num, unsigned base, int width, int padc)
{
f0105a10:	55                   	push   %ebp
f0105a11:	89 e5                	mov    %esp,%ebp
f0105a13:	57                   	push   %edi
f0105a14:	56                   	push   %esi
f0105a15:	53                   	push   %ebx
f0105a16:	83 ec 3c             	sub    $0x3c,%esp
f0105a19:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105a1c:	89 d7                	mov    %edx,%edi
f0105a1e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a21:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105a24:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105a27:	89 c3                	mov    %eax,%ebx
f0105a29:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105a2c:	8b 45 10             	mov    0x10(%ebp),%eax
f0105a2f:	8b 75 14             	mov    0x14(%ebp),%esi
  // first recursively print all preceding (more significant) digits
  if (num >= base)
f0105a32:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105a37:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105a3a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105a3d:	39 d9                	cmp    %ebx,%ecx
f0105a3f:	72 05                	jb     f0105a46 <printnum+0x36>
f0105a41:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0105a44:	77 69                	ja     f0105aaf <printnum+0x9f>
    printnum(putch, putdat, num / base, base, width - 1, padc);
f0105a46:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105a49:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0105a4d:	83 ee 01             	sub    $0x1,%esi
f0105a50:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105a54:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105a58:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105a5c:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0105a60:	89 c3                	mov    %eax,%ebx
f0105a62:	89 d6                	mov    %edx,%esi
f0105a64:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105a67:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105a6a:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105a6e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105a72:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105a75:	89 04 24             	mov    %eax,(%esp)
f0105a78:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105a7b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105a7f:	e8 5c 12 00 00       	call   f0106ce0 <__udivdi3>
f0105a84:	89 d9                	mov    %ebx,%ecx
f0105a86:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105a8a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105a8e:	89 04 24             	mov    %eax,(%esp)
f0105a91:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105a95:	89 fa                	mov    %edi,%edx
f0105a97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105a9a:	e8 71 ff ff ff       	call   f0105a10 <printnum>
f0105a9f:	eb 1b                	jmp    f0105abc <printnum+0xac>
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
      putch(padc, putdat);
f0105aa1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105aa5:	8b 45 18             	mov    0x18(%ebp),%eax
f0105aa8:	89 04 24             	mov    %eax,(%esp)
f0105aab:	ff d3                	call   *%ebx
f0105aad:	eb 03                	jmp    f0105ab2 <printnum+0xa2>
f0105aaf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  // first recursively print all preceding (more significant) digits
  if (num >= base)
    printnum(putch, putdat, num / base, base, width - 1, padc);
  else {
    // print any needed pad characters before first digit
    while (--width > 0)
f0105ab2:	83 ee 01             	sub    $0x1,%esi
f0105ab5:	85 f6                	test   %esi,%esi
f0105ab7:	7f e8                	jg     f0105aa1 <printnum+0x91>
f0105ab9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
      putch(padc, putdat);
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
f0105abc:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105ac0:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105ac4:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105ac7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105aca:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105ace:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105ad2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105ad5:	89 04 24             	mov    %eax,(%esp)
f0105ad8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105adb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105adf:	e8 2c 13 00 00       	call   f0106e10 <__umoddi3>
f0105ae4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105ae8:	0f be 80 e2 86 10 f0 	movsbl -0xfef791e(%eax),%eax
f0105aef:	89 04 24             	mov    %eax,(%esp)
f0105af2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105af5:	ff d0                	call   *%eax
}
f0105af7:	83 c4 3c             	add    $0x3c,%esp
f0105afa:	5b                   	pop    %ebx
f0105afb:	5e                   	pop    %esi
f0105afc:	5f                   	pop    %edi
f0105afd:	5d                   	pop    %ebp
f0105afe:	c3                   	ret    

f0105aff <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105aff:	55                   	push   %ebp
f0105b00:	89 e5                	mov    %esp,%ebp
  if (lflag >= 2)
f0105b02:	83 fa 01             	cmp    $0x1,%edx
f0105b05:	7e 0e                	jle    f0105b15 <getuint+0x16>
    return va_arg(*ap, unsigned long long);
f0105b07:	8b 10                	mov    (%eax),%edx
f0105b09:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105b0c:	89 08                	mov    %ecx,(%eax)
f0105b0e:	8b 02                	mov    (%edx),%eax
f0105b10:	8b 52 04             	mov    0x4(%edx),%edx
f0105b13:	eb 22                	jmp    f0105b37 <getuint+0x38>
  else if (lflag)
f0105b15:	85 d2                	test   %edx,%edx
f0105b17:	74 10                	je     f0105b29 <getuint+0x2a>
    return va_arg(*ap, unsigned long);
f0105b19:	8b 10                	mov    (%eax),%edx
f0105b1b:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105b1e:	89 08                	mov    %ecx,(%eax)
f0105b20:	8b 02                	mov    (%edx),%eax
f0105b22:	ba 00 00 00 00       	mov    $0x0,%edx
f0105b27:	eb 0e                	jmp    f0105b37 <getuint+0x38>
  else
    return va_arg(*ap, unsigned int);
f0105b29:	8b 10                	mov    (%eax),%edx
f0105b2b:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105b2e:	89 08                	mov    %ecx,(%eax)
f0105b30:	8b 02                	mov    (%edx),%eax
f0105b32:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105b37:	5d                   	pop    %ebp
f0105b38:	c3                   	ret    

f0105b39 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105b39:	55                   	push   %ebp
f0105b3a:	89 e5                	mov    %esp,%ebp
f0105b3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  b->cnt++;
f0105b3f:	83 40 08 01          	addl   $0x1,0x8(%eax)
  if (b->buf < b->ebuf)
f0105b43:	8b 10                	mov    (%eax),%edx
f0105b45:	3b 50 04             	cmp    0x4(%eax),%edx
f0105b48:	73 0a                	jae    f0105b54 <sprintputch+0x1b>
    *b->buf++ = ch;
f0105b4a:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105b4d:	89 08                	mov    %ecx,(%eax)
f0105b4f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b52:	88 02                	mov    %al,(%edx)
}
f0105b54:	5d                   	pop    %ebp
f0105b55:	c3                   	ret    

f0105b56 <printfmt>:
  }
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105b56:	55                   	push   %ebp
f0105b57:	89 e5                	mov    %esp,%ebp
f0105b59:	83 ec 18             	sub    $0x18,%esp
  va_list ap;

  va_start(ap, fmt);
f0105b5c:	8d 45 14             	lea    0x14(%ebp),%eax
  vprintfmt(putch, putdat, fmt, ap);
f0105b5f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105b63:	8b 45 10             	mov    0x10(%ebp),%eax
f0105b66:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105b6a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105b6d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105b71:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b74:	89 04 24             	mov    %eax,(%esp)
f0105b77:	e8 02 00 00 00       	call   f0105b7e <vprintfmt>
  va_end(ap);
}
f0105b7c:	c9                   	leave  
f0105b7d:	c3                   	ret    

f0105b7e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105b7e:	55                   	push   %ebp
f0105b7f:	89 e5                	mov    %esp,%ebp
f0105b81:	57                   	push   %edi
f0105b82:	56                   	push   %esi
f0105b83:	53                   	push   %ebx
f0105b84:	83 ec 3c             	sub    $0x3c,%esp
f0105b87:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105b8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105b8d:	eb 14                	jmp    f0105ba3 <vprintfmt+0x25>
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
      if (ch == '\0')
f0105b8f:	85 c0                	test   %eax,%eax
f0105b91:	0f 84 b3 03 00 00    	je     f0105f4a <vprintfmt+0x3cc>
        return;
      putch(ch, putdat);
f0105b97:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105b9b:	89 04 24             	mov    %eax,(%esp)
f0105b9e:	ff 55 08             	call   *0x8(%ebp)
  unsigned long long num;
  int base, lflag, width, precision, altflag;
  char padc;

  while (1) {
    while ((ch = *(unsigned char*)fmt++) != '%') {
f0105ba1:	89 f3                	mov    %esi,%ebx
f0105ba3:	8d 73 01             	lea    0x1(%ebx),%esi
f0105ba6:	0f b6 03             	movzbl (%ebx),%eax
f0105ba9:	83 f8 25             	cmp    $0x25,%eax
f0105bac:	75 e1                	jne    f0105b8f <vprintfmt+0x11>
f0105bae:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0105bb2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0105bb9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0105bc0:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f0105bc7:	ba 00 00 00 00       	mov    $0x0,%edx
f0105bcc:	eb 1d                	jmp    f0105beb <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
f0105bce:	89 de                	mov    %ebx,%esi

    // flag to pad on the right
    case '-':
      padc = '-';
f0105bd0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0105bd4:	eb 15                	jmp    f0105beb <vprintfmt+0x6d>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
f0105bd6:	89 de                	mov    %ebx,%esi
      padc = '-';
      goto reswitch;

    // flag to pad with 0's instead of spaces
    case '0':
      padc = '0';
f0105bd8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0105bdc:	eb 0d                	jmp    f0105beb <vprintfmt+0x6d>
      altflag = 1;
      goto reswitch;

process_precision:
      if (width < 0)
        width = precision, precision = -1;
f0105bde:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105be1:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105be4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
f0105beb:	8d 5e 01             	lea    0x1(%esi),%ebx
f0105bee:	0f b6 0e             	movzbl (%esi),%ecx
f0105bf1:	0f b6 c1             	movzbl %cl,%eax
f0105bf4:	83 e9 23             	sub    $0x23,%ecx
f0105bf7:	80 f9 55             	cmp    $0x55,%cl
f0105bfa:	0f 87 2a 03 00 00    	ja     f0105f2a <vprintfmt+0x3ac>
f0105c00:	0f b6 c9             	movzbl %cl,%ecx
f0105c03:	ff 24 8d 20 88 10 f0 	jmp    *-0xfef77e0(,%ecx,4)
f0105c0a:	89 de                	mov    %ebx,%esi
f0105c0c:	b9 00 00 00 00       	mov    $0x0,%ecx
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
        precision = precision * 10 + ch - '0';
f0105c11:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0105c14:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
        ch = *fmt;
f0105c18:	0f be 06             	movsbl (%esi),%eax
        if (ch < '0' || ch > '9')
f0105c1b:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0105c1e:	83 fb 09             	cmp    $0x9,%ebx
f0105c21:	77 36                	ja     f0105c59 <vprintfmt+0xdb>
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      for (precision = 0;; ++fmt) {
f0105c23:	83 c6 01             	add    $0x1,%esi
        precision = precision * 10 + ch - '0';
        ch = *fmt;
        if (ch < '0' || ch > '9')
          break;
      }
f0105c26:	eb e9                	jmp    f0105c11 <vprintfmt+0x93>
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
f0105c28:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c2b:	8d 48 04             	lea    0x4(%eax),%ecx
f0105c2e:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105c31:	8b 00                	mov    (%eax),%eax
f0105c33:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
f0105c36:	89 de                	mov    %ebx,%esi
      }
      goto process_precision;

    case '*':
      precision = va_arg(ap, int);
      goto process_precision;
f0105c38:	eb 22                	jmp    f0105c5c <vprintfmt+0xde>
f0105c3a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105c3d:	85 c9                	test   %ecx,%ecx
f0105c3f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c44:	0f 49 c1             	cmovns %ecx,%eax
f0105c47:	89 45 dc             	mov    %eax,-0x24(%ebp)
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
f0105c4a:	89 de                	mov    %ebx,%esi
f0105c4c:	eb 9d                	jmp    f0105beb <vprintfmt+0x6d>
f0105c4e:	89 de                	mov    %ebx,%esi
      if (width < 0)
        width = 0;
      goto reswitch;

    case '#':
      altflag = 1;
f0105c50:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
      goto reswitch;
f0105c57:	eb 92                	jmp    f0105beb <vprintfmt+0x6d>
f0105c59:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

process_precision:
      if (width < 0)
f0105c5c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105c60:	79 89                	jns    f0105beb <vprintfmt+0x6d>
f0105c62:	e9 77 ff ff ff       	jmp    f0105bde <vprintfmt+0x60>
        width = precision, precision = -1;
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
f0105c67:	83 c2 01             	add    $0x1,%edx
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
f0105c6a:	89 de                	mov    %ebx,%esi
      goto reswitch;

    // long flag (doubled for long long)
    case 'l':
      lflag++;
      goto reswitch;
f0105c6c:	e9 7a ff ff ff       	jmp    f0105beb <vprintfmt+0x6d>

    // character
    case 'c':
      putch(va_arg(ap, int), putdat);
f0105c71:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c74:	8d 50 04             	lea    0x4(%eax),%edx
f0105c77:	89 55 14             	mov    %edx,0x14(%ebp)
f0105c7a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105c7e:	8b 00                	mov    (%eax),%eax
f0105c80:	89 04 24             	mov    %eax,(%esp)
f0105c83:	ff 55 08             	call   *0x8(%ebp)
      break;
f0105c86:	e9 18 ff ff ff       	jmp    f0105ba3 <vprintfmt+0x25>

    // error message
    case 'e':
      err = va_arg(ap, int);
f0105c8b:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c8e:	8d 50 04             	lea    0x4(%eax),%edx
f0105c91:	89 55 14             	mov    %edx,0x14(%ebp)
f0105c94:	8b 00                	mov    (%eax),%eax
f0105c96:	99                   	cltd   
f0105c97:	31 d0                	xor    %edx,%eax
f0105c99:	29 d0                	sub    %edx,%eax
      if (err < 0)
        err = -err;
      if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105c9b:	83 f8 0f             	cmp    $0xf,%eax
f0105c9e:	7f 0b                	jg     f0105cab <vprintfmt+0x12d>
f0105ca0:	8b 14 85 80 89 10 f0 	mov    -0xfef7680(,%eax,4),%edx
f0105ca7:	85 d2                	test   %edx,%edx
f0105ca9:	75 20                	jne    f0105ccb <vprintfmt+0x14d>
        printfmt(putch, putdat, "error %d", err);
f0105cab:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105caf:	c7 44 24 08 fa 86 10 	movl   $0xf01086fa,0x8(%esp)
f0105cb6:	f0 
f0105cb7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105cbb:	8b 45 08             	mov    0x8(%ebp),%eax
f0105cbe:	89 04 24             	mov    %eax,(%esp)
f0105cc1:	e8 90 fe ff ff       	call   f0105b56 <printfmt>
f0105cc6:	e9 d8 fe ff ff       	jmp    f0105ba3 <vprintfmt+0x25>
      else
        printfmt(putch, putdat, "%s", p);
f0105ccb:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105ccf:	c7 44 24 08 97 75 10 	movl   $0xf0107597,0x8(%esp)
f0105cd6:	f0 
f0105cd7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105cdb:	8b 45 08             	mov    0x8(%ebp),%eax
f0105cde:	89 04 24             	mov    %eax,(%esp)
f0105ce1:	e8 70 fe ff ff       	call   f0105b56 <printfmt>
f0105ce6:	e9 b8 fe ff ff       	jmp    f0105ba3 <vprintfmt+0x25>
    width = -1;
    precision = -1;
    lflag = 0;
    altflag = 0;
reswitch:
    switch (ch = *(unsigned char*)fmt++) {
f0105ceb:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0105cee:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105cf1:	89 45 d0             	mov    %eax,-0x30(%ebp)
        printfmt(putch, putdat, "%s", p);
      break;

    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
f0105cf4:	8b 45 14             	mov    0x14(%ebp),%eax
f0105cf7:	8d 50 04             	lea    0x4(%eax),%edx
f0105cfa:	89 55 14             	mov    %edx,0x14(%ebp)
f0105cfd:	8b 30                	mov    (%eax),%esi
        p = "(null)";
f0105cff:	85 f6                	test   %esi,%esi
f0105d01:	b8 f3 86 10 f0       	mov    $0xf01086f3,%eax
f0105d06:	0f 44 f0             	cmove  %eax,%esi
      if (width > 0 && padc != '-')
f0105d09:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0105d0d:	0f 84 97 00 00 00    	je     f0105daa <vprintfmt+0x22c>
f0105d13:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0105d17:	0f 8e 9b 00 00 00    	jle    f0105db8 <vprintfmt+0x23a>
        for (width -= strnlen(p, precision); width > 0; width--)
f0105d1d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105d21:	89 34 24             	mov    %esi,(%esp)
f0105d24:	e8 af 03 00 00       	call   f01060d8 <strnlen>
f0105d29:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0105d2c:	29 c2                	sub    %eax,%edx
f0105d2e:	89 55 d0             	mov    %edx,-0x30(%ebp)
          putch(padc, putdat);
f0105d31:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0105d35:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105d38:	89 75 d8             	mov    %esi,-0x28(%ebp)
f0105d3b:	8b 75 08             	mov    0x8(%ebp),%esi
f0105d3e:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105d41:	89 d3                	mov    %edx,%ebx
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
f0105d43:	eb 0f                	jmp    f0105d54 <vprintfmt+0x1d6>
          putch(padc, putdat);
f0105d45:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105d49:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105d4c:	89 04 24             	mov    %eax,(%esp)
f0105d4f:	ff d6                	call   *%esi
    // string
    case 's':
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
f0105d51:	83 eb 01             	sub    $0x1,%ebx
f0105d54:	85 db                	test   %ebx,%ebx
f0105d56:	7f ed                	jg     f0105d45 <vprintfmt+0x1c7>
f0105d58:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0105d5b:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0105d5e:	85 d2                	test   %edx,%edx
f0105d60:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d65:	0f 49 c2             	cmovns %edx,%eax
f0105d68:	29 c2                	sub    %eax,%edx
f0105d6a:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0105d6d:	89 d7                	mov    %edx,%edi
f0105d6f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0105d72:	eb 50                	jmp    f0105dc4 <vprintfmt+0x246>
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
f0105d74:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105d78:	74 1e                	je     f0105d98 <vprintfmt+0x21a>
f0105d7a:	0f be d2             	movsbl %dl,%edx
f0105d7d:	83 ea 20             	sub    $0x20,%edx
f0105d80:	83 fa 5e             	cmp    $0x5e,%edx
f0105d83:	76 13                	jbe    f0105d98 <vprintfmt+0x21a>
          putch('?', putdat);
f0105d85:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105d88:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105d8c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0105d93:	ff 55 08             	call   *0x8(%ebp)
f0105d96:	eb 0d                	jmp    f0105da5 <vprintfmt+0x227>
        else
          putch(ch, putdat);
f0105d98:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105d9b:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105d9f:	89 04 24             	mov    %eax,(%esp)
f0105da2:	ff 55 08             	call   *0x8(%ebp)
      if ((p = va_arg(ap, char *)) == NULL)
        p = "(null)";
      if (width > 0 && padc != '-')
        for (width -= strnlen(p, precision); width > 0; width--)
          putch(padc, putdat);
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105da5:	83 ef 01             	sub    $0x1,%edi
f0105da8:	eb 1a                	jmp    f0105dc4 <vprintfmt+0x246>
f0105daa:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0105dad:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0105db0:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105db3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0105db6:	eb 0c                	jmp    f0105dc4 <vprintfmt+0x246>
f0105db8:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0105dbb:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0105dbe:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105dc1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0105dc4:	83 c6 01             	add    $0x1,%esi
f0105dc7:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
f0105dcb:	0f be c2             	movsbl %dl,%eax
f0105dce:	85 c0                	test   %eax,%eax
f0105dd0:	74 27                	je     f0105df9 <vprintfmt+0x27b>
f0105dd2:	85 db                	test   %ebx,%ebx
f0105dd4:	78 9e                	js     f0105d74 <vprintfmt+0x1f6>
f0105dd6:	83 eb 01             	sub    $0x1,%ebx
f0105dd9:	79 99                	jns    f0105d74 <vprintfmt+0x1f6>
f0105ddb:	89 f8                	mov    %edi,%eax
f0105ddd:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105de0:	8b 75 08             	mov    0x8(%ebp),%esi
f0105de3:	89 c3                	mov    %eax,%ebx
f0105de5:	eb 1a                	jmp    f0105e01 <vprintfmt+0x283>
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
        putch(' ', putdat);
f0105de7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105deb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0105df2:	ff d6                	call   *%esi
      for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
        if (altflag && (ch < ' ' || ch > '~'))
          putch('?', putdat);
        else
          putch(ch, putdat);
      for (; width > 0; width--)
f0105df4:	83 eb 01             	sub    $0x1,%ebx
f0105df7:	eb 08                	jmp    f0105e01 <vprintfmt+0x283>
f0105df9:	89 fb                	mov    %edi,%ebx
f0105dfb:	8b 75 08             	mov    0x8(%ebp),%esi
f0105dfe:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105e01:	85 db                	test   %ebx,%ebx
f0105e03:	7f e2                	jg     f0105de7 <vprintfmt+0x269>
f0105e05:	89 75 08             	mov    %esi,0x8(%ebp)
f0105e08:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105e0b:	e9 93 fd ff ff       	jmp    f0105ba3 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  if (lflag >= 2)
f0105e10:	83 fa 01             	cmp    $0x1,%edx
f0105e13:	7e 16                	jle    f0105e2b <vprintfmt+0x2ad>
    return va_arg(*ap, long long);
f0105e15:	8b 45 14             	mov    0x14(%ebp),%eax
f0105e18:	8d 50 08             	lea    0x8(%eax),%edx
f0105e1b:	89 55 14             	mov    %edx,0x14(%ebp)
f0105e1e:	8b 50 04             	mov    0x4(%eax),%edx
f0105e21:	8b 00                	mov    (%eax),%eax
f0105e23:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105e26:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105e29:	eb 32                	jmp    f0105e5d <vprintfmt+0x2df>
  else if (lflag)
f0105e2b:	85 d2                	test   %edx,%edx
f0105e2d:	74 18                	je     f0105e47 <vprintfmt+0x2c9>
    return va_arg(*ap, long);
f0105e2f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105e32:	8d 50 04             	lea    0x4(%eax),%edx
f0105e35:	89 55 14             	mov    %edx,0x14(%ebp)
f0105e38:	8b 30                	mov    (%eax),%esi
f0105e3a:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0105e3d:	89 f0                	mov    %esi,%eax
f0105e3f:	c1 f8 1f             	sar    $0x1f,%eax
f0105e42:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105e45:	eb 16                	jmp    f0105e5d <vprintfmt+0x2df>
  else
    return va_arg(*ap, int);
f0105e47:	8b 45 14             	mov    0x14(%ebp),%eax
f0105e4a:	8d 50 04             	lea    0x4(%eax),%edx
f0105e4d:	89 55 14             	mov    %edx,0x14(%ebp)
f0105e50:	8b 30                	mov    (%eax),%esi
f0105e52:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0105e55:	89 f0                	mov    %esi,%eax
f0105e57:	c1 f8 1f             	sar    $0x1f,%eax
f0105e5a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        putch(' ', putdat);
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
f0105e5d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105e60:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      if ((long long)num < 0) {
        putch('-', putdat);
        num = -(long long)num;
      }
      base = 10;
f0105e63:	b9 0a 00 00 00       	mov    $0xa,%ecx
      break;

    // (signed) decimal
    case 'd':
      num = getint(&ap, lflag);
      if ((long long)num < 0) {
f0105e68:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105e6c:	0f 89 80 00 00 00    	jns    f0105ef2 <vprintfmt+0x374>
        putch('-', putdat);
f0105e72:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105e76:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0105e7d:	ff 55 08             	call   *0x8(%ebp)
        num = -(long long)num;
f0105e80:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105e83:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105e86:	f7 d8                	neg    %eax
f0105e88:	83 d2 00             	adc    $0x0,%edx
f0105e8b:	f7 da                	neg    %edx
      }
      base = 10;
f0105e8d:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0105e92:	eb 5e                	jmp    f0105ef2 <vprintfmt+0x374>
      goto number;

    // unsigned decimal
    case 'u':
      num = getuint(&ap, lflag);
f0105e94:	8d 45 14             	lea    0x14(%ebp),%eax
f0105e97:	e8 63 fc ff ff       	call   f0105aff <getuint>
      base = 10;
f0105e9c:	b9 0a 00 00 00       	mov    $0xa,%ecx
      goto number;
f0105ea1:	eb 4f                	jmp    f0105ef2 <vprintfmt+0x374>

    // (unsigned) octal
    case 'o':
      num = getuint(&ap, lflag);
f0105ea3:	8d 45 14             	lea    0x14(%ebp),%eax
f0105ea6:	e8 54 fc ff ff       	call   f0105aff <getuint>
      base = 8;
f0105eab:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
f0105eb0:	eb 40                	jmp    f0105ef2 <vprintfmt+0x374>

    // pointer
    case 'p':
      putch('0', putdat);
f0105eb2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105eb6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0105ebd:	ff 55 08             	call   *0x8(%ebp)
      putch('x', putdat);
f0105ec0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105ec4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105ecb:	ff 55 08             	call   *0x8(%ebp)
      num = (unsigned long long)
            (uintptr_t)va_arg(ap, void *);
f0105ece:	8b 45 14             	mov    0x14(%ebp),%eax
f0105ed1:	8d 50 04             	lea    0x4(%eax),%edx
f0105ed4:	89 55 14             	mov    %edx,0x14(%ebp)

    // pointer
    case 'p':
      putch('0', putdat);
      putch('x', putdat);
      num = (unsigned long long)
f0105ed7:	8b 00                	mov    (%eax),%eax
f0105ed9:	ba 00 00 00 00       	mov    $0x0,%edx
            (uintptr_t)va_arg(ap, void *);
      base = 16;
f0105ede:	b9 10 00 00 00       	mov    $0x10,%ecx
      goto number;
f0105ee3:	eb 0d                	jmp    f0105ef2 <vprintfmt+0x374>

    // (unsigned) hexadecimal
    case 'x':
      num = getuint(&ap, lflag);
f0105ee5:	8d 45 14             	lea    0x14(%ebp),%eax
f0105ee8:	e8 12 fc ff ff       	call   f0105aff <getuint>
      base = 16;
f0105eed:	b9 10 00 00 00       	mov    $0x10,%ecx
number:
      printnum(putch, putdat, num, base, width, padc);
f0105ef2:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
f0105ef6:	89 74 24 10          	mov    %esi,0x10(%esp)
f0105efa:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0105efd:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105f01:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105f05:	89 04 24             	mov    %eax,(%esp)
f0105f08:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105f0c:	89 fa                	mov    %edi,%edx
f0105f0e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f11:	e8 fa fa ff ff       	call   f0105a10 <printnum>
      break;
f0105f16:	e9 88 fc ff ff       	jmp    f0105ba3 <vprintfmt+0x25>

    // escaped '%' character
    case '%':
      putch(ch, putdat);
f0105f1b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105f1f:	89 04 24             	mov    %eax,(%esp)
f0105f22:	ff 55 08             	call   *0x8(%ebp)
      break;
f0105f25:	e9 79 fc ff ff       	jmp    f0105ba3 <vprintfmt+0x25>

    // unrecognized escape sequence - just print it literally
    default:
      putch('%', putdat);
f0105f2a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105f2e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105f35:	ff 55 08             	call   *0x8(%ebp)
      for (fmt--; fmt[-1] != '%'; fmt--)
f0105f38:	89 f3                	mov    %esi,%ebx
f0105f3a:	eb 03                	jmp    f0105f3f <vprintfmt+0x3c1>
f0105f3c:	83 eb 01             	sub    $0x1,%ebx
f0105f3f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0105f43:	75 f7                	jne    f0105f3c <vprintfmt+0x3be>
f0105f45:	e9 59 fc ff ff       	jmp    f0105ba3 <vprintfmt+0x25>
        /* do nothing */;
      break;
    }
  }
}
f0105f4a:	83 c4 3c             	add    $0x3c,%esp
f0105f4d:	5b                   	pop    %ebx
f0105f4e:	5e                   	pop    %esi
f0105f4f:	5f                   	pop    %edi
f0105f50:	5d                   	pop    %ebp
f0105f51:	c3                   	ret    

f0105f52 <vsnprintf>:
    *b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105f52:	55                   	push   %ebp
f0105f53:	89 e5                	mov    %esp,%ebp
f0105f55:	83 ec 28             	sub    $0x28,%esp
f0105f58:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  struct sprintbuf b = { buf, buf+n-1, 0 };
f0105f5e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105f61:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105f65:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105f68:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  if (buf == NULL || n < 1)
f0105f6f:	85 c0                	test   %eax,%eax
f0105f71:	74 30                	je     f0105fa3 <vsnprintf+0x51>
f0105f73:	85 d2                	test   %edx,%edx
f0105f75:	7e 2c                	jle    f0105fa3 <vsnprintf+0x51>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105f77:	8b 45 14             	mov    0x14(%ebp),%eax
f0105f7a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105f7e:	8b 45 10             	mov    0x10(%ebp),%eax
f0105f81:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105f85:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105f88:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f8c:	c7 04 24 39 5b 10 f0 	movl   $0xf0105b39,(%esp)
f0105f93:	e8 e6 fb ff ff       	call   f0105b7e <vprintfmt>

  // null terminate the buffer
  *b.buf = '\0';
f0105f98:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105f9b:	c6 00 00             	movb   $0x0,(%eax)

  return b.cnt;
f0105f9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105fa1:	eb 05                	jmp    f0105fa8 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  struct sprintbuf b = { buf, buf+n-1, 0 };

  if (buf == NULL || n < 1)
    return -E_INVAL;
f0105fa3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

  // null terminate the buffer
  *b.buf = '\0';

  return b.cnt;
}
f0105fa8:	c9                   	leave  
f0105fa9:	c3                   	ret    

f0105faa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105faa:	55                   	push   %ebp
f0105fab:	89 e5                	mov    %esp,%ebp
f0105fad:	83 ec 18             	sub    $0x18,%esp
  va_list ap;
  int rc;

  va_start(ap, fmt);
f0105fb0:	8d 45 14             	lea    0x14(%ebp),%eax
  rc = vsnprintf(buf, n, fmt, ap);
f0105fb3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105fb7:	8b 45 10             	mov    0x10(%ebp),%eax
f0105fba:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105fbe:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105fc1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105fc5:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fc8:	89 04 24             	mov    %eax,(%esp)
f0105fcb:	e8 82 ff ff ff       	call   f0105f52 <vsnprintf>
  va_end(ap);

  return rc;
}
f0105fd0:	c9                   	leave  
f0105fd1:	c3                   	ret    
f0105fd2:	66 90                	xchg   %ax,%ax
f0105fd4:	66 90                	xchg   %ax,%ax
f0105fd6:	66 90                	xchg   %ax,%ax
f0105fd8:	66 90                	xchg   %ax,%ax
f0105fda:	66 90                	xchg   %ax,%ax
f0105fdc:	66 90                	xchg   %ax,%ax
f0105fde:	66 90                	xchg   %ax,%ax

f0105fe0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105fe0:	55                   	push   %ebp
f0105fe1:	89 e5                	mov    %esp,%ebp
f0105fe3:	57                   	push   %edi
f0105fe4:	56                   	push   %esi
f0105fe5:	53                   	push   %ebx
f0105fe6:	83 ec 1c             	sub    $0x1c,%esp
f0105fe9:	8b 45 08             	mov    0x8(%ebp),%eax
  int i, c, echoing;

#if JOS_KERNEL
  if (prompt != NULL)
f0105fec:	85 c0                	test   %eax,%eax
f0105fee:	74 10                	je     f0106000 <readline+0x20>
    cprintf("%s", prompt);
f0105ff0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ff4:	c7 04 24 97 75 10 f0 	movl   $0xf0107597,(%esp)
f0105ffb:	e8 70 df ff ff       	call   f0103f70 <cprintf>
  if (prompt != NULL)
    fprintf(1, "%s", prompt);
#endif

  i = 0;
  echoing = iscons(0);
f0106000:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0106007:	e8 cc a7 ff ff       	call   f01007d8 <iscons>
f010600c:	89 c7                	mov    %eax,%edi
#else
  if (prompt != NULL)
    fprintf(1, "%s", prompt);
#endif

  i = 0;
f010600e:	be 00 00 00 00       	mov    $0x0,%esi
  echoing = iscons(0);
  while (1) {
    c = getchar();
f0106013:	e8 af a7 ff ff       	call   f01007c7 <getchar>
f0106018:	89 c3                	mov    %eax,%ebx
    if (c < 0) {
f010601a:	85 c0                	test   %eax,%eax
f010601c:	79 25                	jns    f0106043 <readline+0x63>
      if (c != -E_EOF)
        cprintf("read error: %e\n", c);
      return NULL;
f010601e:	b8 00 00 00 00       	mov    $0x0,%eax
  i = 0;
  echoing = iscons(0);
  while (1) {
    c = getchar();
    if (c < 0) {
      if (c != -E_EOF)
f0106023:	83 fb f8             	cmp    $0xfffffff8,%ebx
f0106026:	0f 84 89 00 00 00    	je     f01060b5 <readline+0xd5>
        cprintf("read error: %e\n", c);
f010602c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106030:	c7 04 24 df 89 10 f0 	movl   $0xf01089df,(%esp)
f0106037:	e8 34 df ff ff       	call   f0103f70 <cprintf>
      return NULL;
f010603c:	b8 00 00 00 00       	mov    $0x0,%eax
f0106041:	eb 72                	jmp    f01060b5 <readline+0xd5>
    } else if ((c == '\b' || c == '\x7f') && i > 0) {
f0106043:	83 f8 7f             	cmp    $0x7f,%eax
f0106046:	74 05                	je     f010604d <readline+0x6d>
f0106048:	83 f8 08             	cmp    $0x8,%eax
f010604b:	75 1a                	jne    f0106067 <readline+0x87>
f010604d:	85 f6                	test   %esi,%esi
f010604f:	90                   	nop
f0106050:	7e 15                	jle    f0106067 <readline+0x87>
      if (echoing)
f0106052:	85 ff                	test   %edi,%edi
f0106054:	74 0c                	je     f0106062 <readline+0x82>
        cputchar('\b');
f0106056:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010605d:	e8 55 a7 ff ff       	call   f01007b7 <cputchar>
      i--;
f0106062:	83 ee 01             	sub    $0x1,%esi
f0106065:	eb ac                	jmp    f0106013 <readline+0x33>
    } else if (c >= ' ' && i < BUFLEN-1) {
f0106067:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010606d:	7f 1c                	jg     f010608b <readline+0xab>
f010606f:	83 fb 1f             	cmp    $0x1f,%ebx
f0106072:	7e 17                	jle    f010608b <readline+0xab>
      if (echoing)
f0106074:	85 ff                	test   %edi,%edi
f0106076:	74 08                	je     f0106080 <readline+0xa0>
        cputchar(c);
f0106078:	89 1c 24             	mov    %ebx,(%esp)
f010607b:	e8 37 a7 ff ff       	call   f01007b7 <cputchar>
      buf[i++] = c;
f0106080:	88 9e 80 ca 20 f0    	mov    %bl,-0xfdf3580(%esi)
f0106086:	8d 76 01             	lea    0x1(%esi),%esi
f0106089:	eb 88                	jmp    f0106013 <readline+0x33>
    } else if (c == '\n' || c == '\r') {
f010608b:	83 fb 0d             	cmp    $0xd,%ebx
f010608e:	74 09                	je     f0106099 <readline+0xb9>
f0106090:	83 fb 0a             	cmp    $0xa,%ebx
f0106093:	0f 85 7a ff ff ff    	jne    f0106013 <readline+0x33>
      if (echoing)
f0106099:	85 ff                	test   %edi,%edi
f010609b:	74 0c                	je     f01060a9 <readline+0xc9>
        cputchar('\n');
f010609d:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f01060a4:	e8 0e a7 ff ff       	call   f01007b7 <cputchar>
      buf[i] = 0;
f01060a9:	c6 86 80 ca 20 f0 00 	movb   $0x0,-0xfdf3580(%esi)
      return buf;
f01060b0:	b8 80 ca 20 f0       	mov    $0xf020ca80,%eax
    }
  }
}
f01060b5:	83 c4 1c             	add    $0x1c,%esp
f01060b8:	5b                   	pop    %ebx
f01060b9:	5e                   	pop    %esi
f01060ba:	5f                   	pop    %edi
f01060bb:	5d                   	pop    %ebp
f01060bc:	c3                   	ret    
f01060bd:	66 90                	xchg   %ax,%ax
f01060bf:	90                   	nop

f01060c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01060c0:	55                   	push   %ebp
f01060c1:	89 e5                	mov    %esp,%ebp
f01060c3:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for (n = 0; *s != '\0'; s++)
f01060c6:	b8 00 00 00 00       	mov    $0x0,%eax
f01060cb:	eb 03                	jmp    f01060d0 <strlen+0x10>
    n++;
f01060cd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
  int n;

  for (n = 0; *s != '\0'; s++)
f01060d0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01060d4:	75 f7                	jne    f01060cd <strlen+0xd>
    n++;
  return n;
}
f01060d6:	5d                   	pop    %ebp
f01060d7:	c3                   	ret    

f01060d8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01060d8:	55                   	push   %ebp
f01060d9:	89 e5                	mov    %esp,%ebp
f01060db:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01060de:	8b 55 0c             	mov    0xc(%ebp),%edx
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01060e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01060e6:	eb 03                	jmp    f01060eb <strnlen+0x13>
    n++;
f01060e8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01060eb:	39 d0                	cmp    %edx,%eax
f01060ed:	74 06                	je     f01060f5 <strnlen+0x1d>
f01060ef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01060f3:	75 f3                	jne    f01060e8 <strnlen+0x10>
    n++;
  return n;
}
f01060f5:	5d                   	pop    %ebp
f01060f6:	c3                   	ret    

f01060f7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01060f7:	55                   	push   %ebp
f01060f8:	89 e5                	mov    %esp,%ebp
f01060fa:	53                   	push   %ebx
f01060fb:	8b 45 08             	mov    0x8(%ebp),%eax
f01060fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
f0106101:	89 c2                	mov    %eax,%edx
f0106103:	83 c2 01             	add    $0x1,%edx
f0106106:	83 c1 01             	add    $0x1,%ecx
f0106109:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010610d:	88 5a ff             	mov    %bl,-0x1(%edx)
f0106110:	84 db                	test   %bl,%bl
f0106112:	75 ef                	jne    f0106103 <strcpy+0xc>
    /* do nothing */;
  return ret;
}
f0106114:	5b                   	pop    %ebx
f0106115:	5d                   	pop    %ebp
f0106116:	c3                   	ret    

f0106117 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0106117:	55                   	push   %ebp
f0106118:	89 e5                	mov    %esp,%ebp
f010611a:	53                   	push   %ebx
f010611b:	83 ec 08             	sub    $0x8,%esp
f010611e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int len = strlen(dst);
f0106121:	89 1c 24             	mov    %ebx,(%esp)
f0106124:	e8 97 ff ff ff       	call   f01060c0 <strlen>

  strcpy(dst + len, src);
f0106129:	8b 55 0c             	mov    0xc(%ebp),%edx
f010612c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106130:	01 d8                	add    %ebx,%eax
f0106132:	89 04 24             	mov    %eax,(%esp)
f0106135:	e8 bd ff ff ff       	call   f01060f7 <strcpy>
  return dst;
}
f010613a:	89 d8                	mov    %ebx,%eax
f010613c:	83 c4 08             	add    $0x8,%esp
f010613f:	5b                   	pop    %ebx
f0106140:	5d                   	pop    %ebp
f0106141:	c3                   	ret    

f0106142 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
f0106142:	55                   	push   %ebp
f0106143:	89 e5                	mov    %esp,%ebp
f0106145:	56                   	push   %esi
f0106146:	53                   	push   %ebx
f0106147:	8b 75 08             	mov    0x8(%ebp),%esi
f010614a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010614d:	89 f3                	mov    %esi,%ebx
f010614f:	03 5d 10             	add    0x10(%ebp),%ebx
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
f0106152:	89 f2                	mov    %esi,%edx
f0106154:	eb 0f                	jmp    f0106165 <strncpy+0x23>
    *dst++ = *src;
f0106156:	83 c2 01             	add    $0x1,%edx
f0106159:	0f b6 01             	movzbl (%ecx),%eax
f010615c:	88 42 ff             	mov    %al,-0x1(%edx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
f010615f:	80 39 01             	cmpb   $0x1,(%ecx)
f0106162:	83 d9 ff             	sbb    $0xffffffff,%ecx
{
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
f0106165:	39 da                	cmp    %ebx,%edx
f0106167:	75 ed                	jne    f0106156 <strncpy+0x14>
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  }
  return ret;
}
f0106169:	89 f0                	mov    %esi,%eax
f010616b:	5b                   	pop    %ebx
f010616c:	5e                   	pop    %esi
f010616d:	5d                   	pop    %ebp
f010616e:	c3                   	ret    

f010616f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010616f:	55                   	push   %ebp
f0106170:	89 e5                	mov    %esp,%ebp
f0106172:	56                   	push   %esi
f0106173:	53                   	push   %ebx
f0106174:	8b 75 08             	mov    0x8(%ebp),%esi
f0106177:	8b 55 0c             	mov    0xc(%ebp),%edx
f010617a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010617d:	89 f0                	mov    %esi,%eax
f010617f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
f0106183:	85 c9                	test   %ecx,%ecx
f0106185:	75 0b                	jne    f0106192 <strlcpy+0x23>
f0106187:	eb 1d                	jmp    f01061a6 <strlcpy+0x37>
    while (--size > 0 && *src != '\0')
      *dst++ = *src++;
f0106189:	83 c0 01             	add    $0x1,%eax
f010618c:	83 c2 01             	add    $0x1,%edx
f010618f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
    while (--size > 0 && *src != '\0')
f0106192:	39 d8                	cmp    %ebx,%eax
f0106194:	74 0b                	je     f01061a1 <strlcpy+0x32>
f0106196:	0f b6 0a             	movzbl (%edx),%ecx
f0106199:	84 c9                	test   %cl,%cl
f010619b:	75 ec                	jne    f0106189 <strlcpy+0x1a>
f010619d:	89 c2                	mov    %eax,%edx
f010619f:	eb 02                	jmp    f01061a3 <strlcpy+0x34>
f01061a1:	89 c2                	mov    %eax,%edx
      *dst++ = *src++;
    *dst = '\0';
f01061a3:	c6 02 00             	movb   $0x0,(%edx)
  }
  return dst - dst_in;
f01061a6:	29 f0                	sub    %esi,%eax
}
f01061a8:	5b                   	pop    %ebx
f01061a9:	5e                   	pop    %esi
f01061aa:	5d                   	pop    %ebp
f01061ab:	c3                   	ret    

f01061ac <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01061ac:	55                   	push   %ebp
f01061ad:	89 e5                	mov    %esp,%ebp
f01061af:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01061b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  while (*p && *p == *q)
f01061b5:	eb 06                	jmp    f01061bd <strcmp+0x11>
    p++, q++;
f01061b7:	83 c1 01             	add    $0x1,%ecx
f01061ba:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
  while (*p && *p == *q)
f01061bd:	0f b6 01             	movzbl (%ecx),%eax
f01061c0:	84 c0                	test   %al,%al
f01061c2:	74 04                	je     f01061c8 <strcmp+0x1c>
f01061c4:	3a 02                	cmp    (%edx),%al
f01061c6:	74 ef                	je     f01061b7 <strcmp+0xb>
    p++, q++;
  return (int)((unsigned char)*p - (unsigned char)*q);
f01061c8:	0f b6 c0             	movzbl %al,%eax
f01061cb:	0f b6 12             	movzbl (%edx),%edx
f01061ce:	29 d0                	sub    %edx,%eax
}
f01061d0:	5d                   	pop    %ebp
f01061d1:	c3                   	ret    

f01061d2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01061d2:	55                   	push   %ebp
f01061d3:	89 e5                	mov    %esp,%ebp
f01061d5:	53                   	push   %ebx
f01061d6:	8b 45 08             	mov    0x8(%ebp),%eax
f01061d9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01061dc:	89 c3                	mov    %eax,%ebx
f01061de:	03 5d 10             	add    0x10(%ebp),%ebx
  while (n > 0 && *p && *p == *q)
f01061e1:	eb 06                	jmp    f01061e9 <strncmp+0x17>
    n--, p++, q++;
f01061e3:	83 c0 01             	add    $0x1,%eax
f01061e6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
f01061e9:	39 d8                	cmp    %ebx,%eax
f01061eb:	74 15                	je     f0106202 <strncmp+0x30>
f01061ed:	0f b6 08             	movzbl (%eax),%ecx
f01061f0:	84 c9                	test   %cl,%cl
f01061f2:	74 04                	je     f01061f8 <strncmp+0x26>
f01061f4:	3a 0a                	cmp    (%edx),%cl
f01061f6:	74 eb                	je     f01061e3 <strncmp+0x11>
    n--, p++, q++;
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
f01061f8:	0f b6 00             	movzbl (%eax),%eax
f01061fb:	0f b6 12             	movzbl (%edx),%edx
f01061fe:	29 d0                	sub    %edx,%eax
f0106200:	eb 05                	jmp    f0106207 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
  while (n > 0 && *p && *p == *q)
    n--, p++, q++;
  if (n == 0)
    return 0;
f0106202:	b8 00 00 00 00       	mov    $0x0,%eax
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
}
f0106207:	5b                   	pop    %ebx
f0106208:	5d                   	pop    %ebp
f0106209:	c3                   	ret    

f010620a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010620a:	55                   	push   %ebp
f010620b:	89 e5                	mov    %esp,%ebp
f010620d:	8b 45 08             	mov    0x8(%ebp),%eax
f0106210:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
f0106214:	eb 07                	jmp    f010621d <strchr+0x13>
    if (*s == c)
f0106216:	38 ca                	cmp    %cl,%dl
f0106218:	74 0f                	je     f0106229 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  for (; *s; s++)
f010621a:	83 c0 01             	add    $0x1,%eax
f010621d:	0f b6 10             	movzbl (%eax),%edx
f0106220:	84 d2                	test   %dl,%dl
f0106222:	75 f2                	jne    f0106216 <strchr+0xc>
    if (*s == c)
      return (char*)s;
  return 0;
f0106224:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106229:	5d                   	pop    %ebp
f010622a:	c3                   	ret    

f010622b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010622b:	55                   	push   %ebp
f010622c:	89 e5                	mov    %esp,%ebp
f010622e:	8b 45 08             	mov    0x8(%ebp),%eax
f0106231:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for (; *s; s++)
f0106235:	eb 07                	jmp    f010623e <strfind+0x13>
    if (*s == c)
f0106237:	38 ca                	cmp    %cl,%dl
f0106239:	74 0a                	je     f0106245 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  for (; *s; s++)
f010623b:	83 c0 01             	add    $0x1,%eax
f010623e:	0f b6 10             	movzbl (%eax),%edx
f0106241:	84 d2                	test   %dl,%dl
f0106243:	75 f2                	jne    f0106237 <strfind+0xc>
    if (*s == c)
      break;
  return (char*)s;
}
f0106245:	5d                   	pop    %ebp
f0106246:	c3                   	ret    

f0106247 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0106247:	55                   	push   %ebp
f0106248:	89 e5                	mov    %esp,%ebp
f010624a:	57                   	push   %edi
f010624b:	56                   	push   %esi
f010624c:	53                   	push   %ebx
f010624d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106250:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *p;

  if (n == 0)
f0106253:	85 c9                	test   %ecx,%ecx
f0106255:	74 36                	je     f010628d <memset+0x46>
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
f0106257:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010625d:	75 28                	jne    f0106287 <memset+0x40>
f010625f:	f6 c1 03             	test   $0x3,%cl
f0106262:	75 23                	jne    f0106287 <memset+0x40>
    c &= 0xFF;
f0106264:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
    c = (c<<24)|(c<<16)|(c<<8)|c;
f0106268:	89 d3                	mov    %edx,%ebx
f010626a:	c1 e3 08             	shl    $0x8,%ebx
f010626d:	89 d6                	mov    %edx,%esi
f010626f:	c1 e6 18             	shl    $0x18,%esi
f0106272:	89 d0                	mov    %edx,%eax
f0106274:	c1 e0 10             	shl    $0x10,%eax
f0106277:	09 f0                	or     %esi,%eax
f0106279:	09 c2                	or     %eax,%edx
f010627b:	89 d0                	mov    %edx,%eax
f010627d:	09 d8                	or     %ebx,%eax
    asm volatile ("cld; rep stosl\n"
                  :: "D" (v), "a" (c), "c" (n/4)
f010627f:	c1 e9 02             	shr    $0x2,%ecx
  if (n == 0)
    return v;
  if ((int)v%4 == 0 && n%4 == 0) {
    c &= 0xFF;
    c = (c<<24)|(c<<16)|(c<<8)|c;
    asm volatile ("cld; rep stosl\n"
f0106282:	fc                   	cld    
f0106283:	f3 ab                	rep stos %eax,%es:(%edi)
f0106285:	eb 06                	jmp    f010628d <memset+0x46>
                  :: "D" (v), "a" (c), "c" (n/4)
                  : "cc", "memory");
  } else
    asm volatile ("cld; rep stosb\n"
f0106287:	8b 45 0c             	mov    0xc(%ebp),%eax
f010628a:	fc                   	cld    
f010628b:	f3 aa                	rep stos %al,%es:(%edi)
                  :: "D" (v), "a" (c), "c" (n)
                  : "cc", "memory");
  return v;
}
f010628d:	89 f8                	mov    %edi,%eax
f010628f:	5b                   	pop    %ebx
f0106290:	5e                   	pop    %esi
f0106291:	5f                   	pop    %edi
f0106292:	5d                   	pop    %ebp
f0106293:	c3                   	ret    

f0106294 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0106294:	55                   	push   %ebp
f0106295:	89 e5                	mov    %esp,%ebp
f0106297:	57                   	push   %edi
f0106298:	56                   	push   %esi
f0106299:	8b 45 08             	mov    0x8(%ebp),%eax
f010629c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010629f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
f01062a2:	39 c6                	cmp    %eax,%esi
f01062a4:	73 35                	jae    f01062db <memmove+0x47>
f01062a6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01062a9:	39 d0                	cmp    %edx,%eax
f01062ab:	73 2e                	jae    f01062db <memmove+0x47>
    s += n;
    d += n;
f01062ad:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f01062b0:	89 d6                	mov    %edx,%esi
f01062b2:	09 fe                	or     %edi,%esi
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01062b4:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01062ba:	75 13                	jne    f01062cf <memmove+0x3b>
f01062bc:	f6 c1 03             	test   $0x3,%cl
f01062bf:	75 0e                	jne    f01062cf <memmove+0x3b>
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01062c1:	83 ef 04             	sub    $0x4,%edi
f01062c4:	8d 72 fc             	lea    -0x4(%edx),%esi
f01062c7:	c1 e9 02             	shr    $0x2,%ecx
  d = dst;
  if (s < d && s + n > d) {
    s += n;
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
f01062ca:	fd                   	std    
f01062cb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01062cd:	eb 09                	jmp    f01062d8 <memmove+0x44>
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01062cf:	83 ef 01             	sub    $0x1,%edi
f01062d2:	8d 72 ff             	lea    -0x1(%edx),%esi
    d += n;
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("std; rep movsl\n"
                    :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("std; rep movsb\n"
f01062d5:	fd                   	std    
f01062d6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
f01062d8:	fc                   	cld    
f01062d9:	eb 1d                	jmp    f01062f8 <memmove+0x64>
f01062db:	89 f2                	mov    %esi,%edx
f01062dd:	09 c2                	or     %eax,%edx
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01062df:	f6 c2 03             	test   $0x3,%dl
f01062e2:	75 0f                	jne    f01062f3 <memmove+0x5f>
f01062e4:	f6 c1 03             	test   $0x3,%cl
f01062e7:	75 0a                	jne    f01062f3 <memmove+0x5f>
      asm volatile ("cld; rep movsl\n"
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01062e9:	c1 e9 02             	shr    $0x2,%ecx
                    :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile ("cld" ::: "cc");
  } else {
    if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
      asm volatile ("cld; rep movsl\n"
f01062ec:	89 c7                	mov    %eax,%edi
f01062ee:	fc                   	cld    
f01062ef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01062f1:	eb 05                	jmp    f01062f8 <memmove+0x64>
                    :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
    else
      asm volatile ("cld; rep movsb\n"
f01062f3:	89 c7                	mov    %eax,%edi
f01062f5:	fc                   	cld    
f01062f6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
                    :: "D" (d), "S" (s), "c" (n) : "cc", "memory");
  }
  return dst;
}
f01062f8:	5e                   	pop    %esi
f01062f9:	5f                   	pop    %edi
f01062fa:	5d                   	pop    %ebp
f01062fb:	c3                   	ret    

f01062fc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01062fc:	55                   	push   %ebp
f01062fd:	89 e5                	mov    %esp,%ebp
f01062ff:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
f0106302:	8b 45 10             	mov    0x10(%ebp),%eax
f0106305:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106309:	8b 45 0c             	mov    0xc(%ebp),%eax
f010630c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106310:	8b 45 08             	mov    0x8(%ebp),%eax
f0106313:	89 04 24             	mov    %eax,(%esp)
f0106316:	e8 79 ff ff ff       	call   f0106294 <memmove>
}
f010631b:	c9                   	leave  
f010631c:	c3                   	ret    

f010631d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010631d:	55                   	push   %ebp
f010631e:	89 e5                	mov    %esp,%ebp
f0106320:	56                   	push   %esi
f0106321:	53                   	push   %ebx
f0106322:	8b 55 08             	mov    0x8(%ebp),%edx
f0106325:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0106328:	89 d6                	mov    %edx,%esi
f010632a:	03 75 10             	add    0x10(%ebp),%esi
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
f010632d:	eb 1a                	jmp    f0106349 <memcmp+0x2c>
    if (*s1 != *s2)
f010632f:	0f b6 02             	movzbl (%edx),%eax
f0106332:	0f b6 19             	movzbl (%ecx),%ebx
f0106335:	38 d8                	cmp    %bl,%al
f0106337:	74 0a                	je     f0106343 <memcmp+0x26>
      return (int)*s1 - (int)*s2;
f0106339:	0f b6 c0             	movzbl %al,%eax
f010633c:	0f b6 db             	movzbl %bl,%ebx
f010633f:	29 d8                	sub    %ebx,%eax
f0106341:	eb 0f                	jmp    f0106352 <memcmp+0x35>
    s1++, s2++;
f0106343:	83 c2 01             	add    $0x1,%edx
f0106346:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
  const uint8_t *s1 = (const uint8_t*)v1;
  const uint8_t *s2 = (const uint8_t*)v2;

  while (n-- > 0) {
f0106349:	39 f2                	cmp    %esi,%edx
f010634b:	75 e2                	jne    f010632f <memcmp+0x12>
    if (*s1 != *s2)
      return (int)*s1 - (int)*s2;
    s1++, s2++;
  }

  return 0;
f010634d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106352:	5b                   	pop    %ebx
f0106353:	5e                   	pop    %esi
f0106354:	5d                   	pop    %ebp
f0106355:	c3                   	ret    

f0106356 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0106356:	55                   	push   %ebp
f0106357:	89 e5                	mov    %esp,%ebp
f0106359:	8b 45 08             	mov    0x8(%ebp),%eax
f010635c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  const void *ends = (const char*)s + n;
f010635f:	89 c2                	mov    %eax,%edx
f0106361:	03 55 10             	add    0x10(%ebp),%edx

  for (; s < ends; s++)
f0106364:	eb 07                	jmp    f010636d <memfind+0x17>
    if (*(const unsigned char*)s == (unsigned char)c)
f0106366:	38 08                	cmp    %cl,(%eax)
f0106368:	74 07                	je     f0106371 <memfind+0x1b>
void *
memfind(const void *s, int c, size_t n)
{
  const void *ends = (const char*)s + n;

  for (; s < ends; s++)
f010636a:	83 c0 01             	add    $0x1,%eax
f010636d:	39 d0                	cmp    %edx,%eax
f010636f:	72 f5                	jb     f0106366 <memfind+0x10>
    if (*(const unsigned char*)s == (unsigned char)c)
      break;
  return (void*)s;
}
f0106371:	5d                   	pop    %ebp
f0106372:	c3                   	ret    

f0106373 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0106373:	55                   	push   %ebp
f0106374:	89 e5                	mov    %esp,%ebp
f0106376:	57                   	push   %edi
f0106377:	56                   	push   %esi
f0106378:	53                   	push   %ebx
f0106379:	8b 55 08             	mov    0x8(%ebp),%edx
f010637c:	8b 45 10             	mov    0x10(%ebp),%eax
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
f010637f:	eb 03                	jmp    f0106384 <strtol+0x11>
    s++;
f0106381:	83 c2 01             	add    $0x1,%edx
{
  int neg = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
f0106384:	0f b6 0a             	movzbl (%edx),%ecx
f0106387:	80 f9 09             	cmp    $0x9,%cl
f010638a:	74 f5                	je     f0106381 <strtol+0xe>
f010638c:	80 f9 20             	cmp    $0x20,%cl
f010638f:	74 f0                	je     f0106381 <strtol+0xe>
    s++;

  // plus/minus sign
  if (*s == '+')
f0106391:	80 f9 2b             	cmp    $0x2b,%cl
f0106394:	75 0a                	jne    f01063a0 <strtol+0x2d>
    s++;
f0106396:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
  int neg = 0;
f0106399:	bf 00 00 00 00       	mov    $0x0,%edi
f010639e:	eb 11                	jmp    f01063b1 <strtol+0x3e>
f01063a0:	bf 00 00 00 00       	mov    $0x0,%edi
    s++;

  // plus/minus sign
  if (*s == '+')
    s++;
  else if (*s == '-')
f01063a5:	80 f9 2d             	cmp    $0x2d,%cl
f01063a8:	75 07                	jne    f01063b1 <strtol+0x3e>
    s++, neg = 1;
f01063aa:	8d 52 01             	lea    0x1(%edx),%edx
f01063ad:	66 bf 01 00          	mov    $0x1,%di

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01063b1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f01063b6:	75 15                	jne    f01063cd <strtol+0x5a>
f01063b8:	80 3a 30             	cmpb   $0x30,(%edx)
f01063bb:	75 10                	jne    f01063cd <strtol+0x5a>
f01063bd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01063c1:	75 0a                	jne    f01063cd <strtol+0x5a>
    s += 2, base = 16;
f01063c3:	83 c2 02             	add    $0x2,%edx
f01063c6:	b8 10 00 00 00       	mov    $0x10,%eax
f01063cb:	eb 10                	jmp    f01063dd <strtol+0x6a>
  else if (base == 0 && s[0] == '0')
f01063cd:	85 c0                	test   %eax,%eax
f01063cf:	75 0c                	jne    f01063dd <strtol+0x6a>
    s++, base = 8;
  else if (base == 0)
    base = 10;
f01063d1:	b0 0a                	mov    $0xa,%al
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
f01063d3:	80 3a 30             	cmpb   $0x30,(%edx)
f01063d6:	75 05                	jne    f01063dd <strtol+0x6a>
    s++, base = 8;
f01063d8:	83 c2 01             	add    $0x1,%edx
f01063db:	b0 08                	mov    $0x8,%al
  else if (base == 0)
    base = 10;
f01063dd:	bb 00 00 00 00       	mov    $0x0,%ebx
f01063e2:	89 45 10             	mov    %eax,0x10(%ebp)

  // digits
  while (1) {
    int dig;

    if (*s >= '0' && *s <= '9')
f01063e5:	0f b6 0a             	movzbl (%edx),%ecx
f01063e8:	8d 71 d0             	lea    -0x30(%ecx),%esi
f01063eb:	89 f0                	mov    %esi,%eax
f01063ed:	3c 09                	cmp    $0x9,%al
f01063ef:	77 08                	ja     f01063f9 <strtol+0x86>
      dig = *s - '0';
f01063f1:	0f be c9             	movsbl %cl,%ecx
f01063f4:	83 e9 30             	sub    $0x30,%ecx
f01063f7:	eb 20                	jmp    f0106419 <strtol+0xa6>
    else if (*s >= 'a' && *s <= 'z')
f01063f9:	8d 71 9f             	lea    -0x61(%ecx),%esi
f01063fc:	89 f0                	mov    %esi,%eax
f01063fe:	3c 19                	cmp    $0x19,%al
f0106400:	77 08                	ja     f010640a <strtol+0x97>
      dig = *s - 'a' + 10;
f0106402:	0f be c9             	movsbl %cl,%ecx
f0106405:	83 e9 57             	sub    $0x57,%ecx
f0106408:	eb 0f                	jmp    f0106419 <strtol+0xa6>
    else if (*s >= 'A' && *s <= 'Z')
f010640a:	8d 71 bf             	lea    -0x41(%ecx),%esi
f010640d:	89 f0                	mov    %esi,%eax
f010640f:	3c 19                	cmp    $0x19,%al
f0106411:	77 16                	ja     f0106429 <strtol+0xb6>
      dig = *s - 'A' + 10;
f0106413:	0f be c9             	movsbl %cl,%ecx
f0106416:	83 e9 37             	sub    $0x37,%ecx
    else
      break;
    if (dig >= base)
f0106419:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f010641c:	7d 0f                	jge    f010642d <strtol+0xba>
      break;
    s++, val = (val * base) + dig;
f010641e:	83 c2 01             	add    $0x1,%edx
f0106421:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f0106425:	01 cb                	add    %ecx,%ebx
    // we don't properly detect overflow!
  }
f0106427:	eb bc                	jmp    f01063e5 <strtol+0x72>
f0106429:	89 d8                	mov    %ebx,%eax
f010642b:	eb 02                	jmp    f010642f <strtol+0xbc>
f010642d:	89 d8                	mov    %ebx,%eax

  if (endptr)
f010642f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0106433:	74 05                	je     f010643a <strtol+0xc7>
    *endptr = (char*)s;
f0106435:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106438:	89 16                	mov    %edx,(%esi)
  return neg ? -val : val;
f010643a:	f7 d8                	neg    %eax
f010643c:	85 ff                	test   %edi,%edi
f010643e:	0f 44 c3             	cmove  %ebx,%eax
}
f0106441:	5b                   	pop    %ebx
f0106442:	5e                   	pop    %esi
f0106443:	5f                   	pop    %edi
f0106444:	5d                   	pop    %ebp
f0106445:	c3                   	ret    
f0106446:	66 90                	xchg   %ax,%ax

f0106448 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0106448:	fa                   	cli    

	xorw    %ax, %ax
f0106449:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010644b:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010644d:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010644f:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0106451:	0f 01 16             	lgdtl  (%esi)
f0106454:	74 70                	je     f01064c6 <mpentry_end+0x4>
	movl    %cr0, %eax
f0106456:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0106459:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f010645d:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0106460:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0106466:	08 00                	or     %al,(%eax)

f0106468 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0106468:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f010646c:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010646e:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106470:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0106472:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0106476:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0106478:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010647a:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f010647f:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0106482:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0106485:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010648a:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f010648d:	8b 25 84 ce 20 f0    	mov    0xf020ce84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0106493:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0106498:	b8 fb 01 10 f0       	mov    $0xf01001fb,%eax
	call    *%eax
f010649d:	ff d0                	call   *%eax

f010649f <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010649f:	eb fe                	jmp    f010649f <spin>
f01064a1:	8d 76 00             	lea    0x0(%esi),%esi

f01064a4 <gdt>:
	...
f01064ac:	ff                   	(bad)  
f01064ad:	ff 00                	incl   (%eax)
f01064af:	00 00                	add    %al,(%eax)
f01064b1:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01064b8:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f01064bc <gdtdesc>:
f01064bc:	17                   	pop    %ss
f01064bd:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01064c2 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01064c2:	90                   	nop
f01064c3:	66 90                	xchg   %ax,%ax
f01064c5:	66 90                	xchg   %ax,%ax
f01064c7:	66 90                	xchg   %ax,%ax
f01064c9:	66 90                	xchg   %ax,%ax
f01064cb:	66 90                	xchg   %ax,%ax
f01064cd:	66 90                	xchg   %ax,%ax
f01064cf:	90                   	nop

f01064d0 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01064d0:	55                   	push   %ebp
f01064d1:	89 e5                	mov    %esp,%ebp
f01064d3:	56                   	push   %esi
f01064d4:	53                   	push   %ebx
f01064d5:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01064d8:	8b 0d 88 ce 20 f0    	mov    0xf020ce88,%ecx
f01064de:	89 c3                	mov    %eax,%ebx
f01064e0:	c1 eb 0c             	shr    $0xc,%ebx
f01064e3:	39 cb                	cmp    %ecx,%ebx
f01064e5:	72 20                	jb     f0106507 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01064e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01064eb:	c7 44 24 08 a4 6f 10 	movl   $0xf0106fa4,0x8(%esp)
f01064f2:	f0 
f01064f3:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01064fa:	00 
f01064fb:	c7 04 24 7d 8b 10 f0 	movl   $0xf0108b7d,(%esp)
f0106502:	e8 39 9b ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106507:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
  struct mp *mp = KADDR(a), *end = KADDR(a + len);
f010650d:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010650f:	89 c2                	mov    %eax,%edx
f0106511:	c1 ea 0c             	shr    $0xc,%edx
f0106514:	39 d1                	cmp    %edx,%ecx
f0106516:	77 20                	ja     f0106538 <mpsearch1+0x68>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106518:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010651c:	c7 44 24 08 a4 6f 10 	movl   $0xf0106fa4,0x8(%esp)
f0106523:	f0 
f0106524:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010652b:	00 
f010652c:	c7 04 24 7d 8b 10 f0 	movl   $0xf0108b7d,(%esp)
f0106533:	e8 08 9b ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106538:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

  for (; mp < end; mp++)
f010653e:	eb 36                	jmp    f0106576 <mpsearch1+0xa6>
    if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106540:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106547:	00 
f0106548:	c7 44 24 04 8d 8b 10 	movl   $0xf0108b8d,0x4(%esp)
f010654f:	f0 
f0106550:	89 1c 24             	mov    %ebx,(%esp)
f0106553:	e8 c5 fd ff ff       	call   f010631d <memcmp>
f0106558:	85 c0                	test   %eax,%eax
f010655a:	75 17                	jne    f0106573 <mpsearch1+0xa3>
sum(void *addr, int len)
{
  int i, sum;

  sum = 0;
  for (i = 0; i < len; i++)
f010655c:	ba 00 00 00 00       	mov    $0x0,%edx
    sum += ((uint8_t*)addr)[i];
f0106561:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0106565:	01 c8                	add    %ecx,%eax
sum(void *addr, int len)
{
  int i, sum;

  sum = 0;
  for (i = 0; i < len; i++)
f0106567:	83 c2 01             	add    $0x1,%edx
f010656a:	83 fa 10             	cmp    $0x10,%edx
f010656d:	75 f2                	jne    f0106561 <mpsearch1+0x91>
mpsearch1(physaddr_t a, int len)
{
  struct mp *mp = KADDR(a), *end = KADDR(a + len);

  for (; mp < end; mp++)
    if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010656f:	84 c0                	test   %al,%al
f0106571:	74 0e                	je     f0106581 <mpsearch1+0xb1>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
  struct mp *mp = KADDR(a), *end = KADDR(a + len);

  for (; mp < end; mp++)
f0106573:	83 c3 10             	add    $0x10,%ebx
f0106576:	39 f3                	cmp    %esi,%ebx
f0106578:	72 c6                	jb     f0106540 <mpsearch1+0x70>
    if (memcmp(mp->signature, "_MP_", 4) == 0 &&
        sum(mp, sizeof(*mp)) == 0)
      return mp;
  return NULL;
f010657a:	b8 00 00 00 00       	mov    $0x0,%eax
f010657f:	eb 02                	jmp    f0106583 <mpsearch1+0xb3>
f0106581:	89 d8                	mov    %ebx,%eax
}
f0106583:	83 c4 10             	add    $0x10,%esp
f0106586:	5b                   	pop    %ebx
f0106587:	5e                   	pop    %esi
f0106588:	5d                   	pop    %ebp
f0106589:	c3                   	ret    

f010658a <mp_init>:
  return conf;
}

void
mp_init(void)
{
f010658a:	55                   	push   %ebp
f010658b:	89 e5                	mov    %esp,%ebp
f010658d:	57                   	push   %edi
f010658e:	56                   	push   %esi
f010658f:	53                   	push   %ebx
f0106590:	83 ec 2c             	sub    $0x2c,%esp
  struct mpconf *conf;
  struct mpproc *proc;
  uint8_t *p;
  unsigned int i;

  bootcpu = &cpus[0];
f0106593:	c7 05 c0 d3 20 f0 20 	movl   $0xf020d020,0xf020d3c0
f010659a:	d0 20 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010659d:	83 3d 88 ce 20 f0 00 	cmpl   $0x0,0xf020ce88
f01065a4:	75 24                	jne    f01065ca <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01065a6:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f01065ad:	00 
f01065ae:	c7 44 24 08 a4 6f 10 	movl   $0xf0106fa4,0x8(%esp)
f01065b5:	f0 
f01065b6:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f01065bd:	00 
f01065be:	c7 04 24 7d 8b 10 f0 	movl   $0xf0108b7d,(%esp)
f01065c5:	e8 76 9a ff ff       	call   f0100040 <_panic>
  // The BIOS data area lives in 16-bit segment 0x40.
  bda = (uint8_t*)KADDR(0x40 << 4);

  // [MP 4] The 16-bit segment of the EBDA is in the two bytes
  // starting at byte 0x0E of the BDA.  0 if not present.
  if ((p = *(uint16_t*)(bda + 0x0E))) {
f01065ca:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01065d1:	85 c0                	test   %eax,%eax
f01065d3:	74 16                	je     f01065eb <mp_init+0x61>
    p <<= 4;                    // Translate from segment to PA
f01065d5:	c1 e0 04             	shl    $0x4,%eax
    if ((mp = mpsearch1(p, 1024)))
f01065d8:	ba 00 04 00 00       	mov    $0x400,%edx
f01065dd:	e8 ee fe ff ff       	call   f01064d0 <mpsearch1>
f01065e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01065e5:	85 c0                	test   %eax,%eax
f01065e7:	75 3c                	jne    f0106625 <mp_init+0x9b>
f01065e9:	eb 20                	jmp    f010660b <mp_init+0x81>
      return mp;
  } else {
    // The size of base memory, in KB is in the two bytes
    // starting at 0x13 of the BDA.
    p = *(uint16_t*)(bda + 0x13) * 1024;
f01065eb:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01065f2:	c1 e0 0a             	shl    $0xa,%eax
    if ((mp = mpsearch1(p - 1024, 1024)))
f01065f5:	2d 00 04 00 00       	sub    $0x400,%eax
f01065fa:	ba 00 04 00 00       	mov    $0x400,%edx
f01065ff:	e8 cc fe ff ff       	call   f01064d0 <mpsearch1>
f0106604:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106607:	85 c0                	test   %eax,%eax
f0106609:	75 1a                	jne    f0106625 <mp_init+0x9b>
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
f010660b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106610:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0106615:	e8 b6 fe ff ff       	call   f01064d0 <mpsearch1>
f010661a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
  struct mpconf *conf;
  struct mp *mp;

  if ((mp = mpsearch()) == 0)
f010661d:	85 c0                	test   %eax,%eax
f010661f:	0f 84 54 02 00 00    	je     f0106879 <mp_init+0x2ef>
    return NULL;
  if (mp->physaddr == 0 || mp->type != 0) {
f0106625:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106628:	8b 70 04             	mov    0x4(%eax),%esi
f010662b:	85 f6                	test   %esi,%esi
f010662d:	74 06                	je     f0106635 <mp_init+0xab>
f010662f:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0106633:	74 11                	je     f0106646 <mp_init+0xbc>
    cprintf("SMP: Default configurations not implemented\n");
f0106635:	c7 04 24 f0 89 10 f0 	movl   $0xf01089f0,(%esp)
f010663c:	e8 2f d9 ff ff       	call   f0103f70 <cprintf>
f0106641:	e9 33 02 00 00       	jmp    f0106879 <mp_init+0x2ef>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106646:	89 f0                	mov    %esi,%eax
f0106648:	c1 e8 0c             	shr    $0xc,%eax
f010664b:	3b 05 88 ce 20 f0    	cmp    0xf020ce88,%eax
f0106651:	72 20                	jb     f0106673 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106653:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106657:	c7 44 24 08 a4 6f 10 	movl   $0xf0106fa4,0x8(%esp)
f010665e:	f0 
f010665f:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0106666:	00 
f0106667:	c7 04 24 7d 8b 10 f0 	movl   $0xf0108b7d,(%esp)
f010666e:	e8 cd 99 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106673:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
    return NULL;
  }
  conf = (struct mpconf *)KADDR(mp->physaddr);
  if (memcmp(conf, "PCMP", 4) != 0) {
f0106679:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106680:	00 
f0106681:	c7 44 24 04 92 8b 10 	movl   $0xf0108b92,0x4(%esp)
f0106688:	f0 
f0106689:	89 1c 24             	mov    %ebx,(%esp)
f010668c:	e8 8c fc ff ff       	call   f010631d <memcmp>
f0106691:	85 c0                	test   %eax,%eax
f0106693:	74 11                	je     f01066a6 <mp_init+0x11c>
    cprintf("SMP: Incorrect MP configuration table signature\n");
f0106695:	c7 04 24 20 8a 10 f0 	movl   $0xf0108a20,(%esp)
f010669c:	e8 cf d8 ff ff       	call   f0103f70 <cprintf>
f01066a1:	e9 d3 01 00 00       	jmp    f0106879 <mp_init+0x2ef>
    return NULL;
  }
  if (sum(conf, conf->length) != 0) {
f01066a6:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f01066aa:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f01066ae:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
  int i, sum;

  sum = 0;
f01066b1:	ba 00 00 00 00       	mov    $0x0,%edx
  for (i = 0; i < len; i++)
f01066b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01066bb:	eb 0d                	jmp    f01066ca <mp_init+0x140>
    sum += ((uint8_t*)addr)[i];
f01066bd:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f01066c4:	f0 
f01066c5:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
  int i, sum;

  sum = 0;
  for (i = 0; i < len; i++)
f01066c7:	83 c0 01             	add    $0x1,%eax
f01066ca:	39 c7                	cmp    %eax,%edi
f01066cc:	7f ef                	jg     f01066bd <mp_init+0x133>
  conf = (struct mpconf *)KADDR(mp->physaddr);
  if (memcmp(conf, "PCMP", 4) != 0) {
    cprintf("SMP: Incorrect MP configuration table signature\n");
    return NULL;
  }
  if (sum(conf, conf->length) != 0) {
f01066ce:	84 d2                	test   %dl,%dl
f01066d0:	74 11                	je     f01066e3 <mp_init+0x159>
    cprintf("SMP: Bad MP configuration checksum\n");
f01066d2:	c7 04 24 54 8a 10 f0 	movl   $0xf0108a54,(%esp)
f01066d9:	e8 92 d8 ff ff       	call   f0103f70 <cprintf>
f01066de:	e9 96 01 00 00       	jmp    f0106879 <mp_init+0x2ef>
    return NULL;
  }
  if (conf->version != 1 && conf->version != 4) {
f01066e3:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f01066e7:	3c 04                	cmp    $0x4,%al
f01066e9:	74 1f                	je     f010670a <mp_init+0x180>
f01066eb:	3c 01                	cmp    $0x1,%al
f01066ed:	8d 76 00             	lea    0x0(%esi),%esi
f01066f0:	74 18                	je     f010670a <mp_init+0x180>
    cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01066f2:	0f b6 c0             	movzbl %al,%eax
f01066f5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01066f9:	c7 04 24 78 8a 10 f0 	movl   $0xf0108a78,(%esp)
f0106700:	e8 6b d8 ff ff       	call   f0103f70 <cprintf>
f0106705:	e9 6f 01 00 00       	jmp    f0106879 <mp_init+0x2ef>
    return NULL;
  }
  if ((sum((uint8_t*)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010670a:	0f b7 73 28          	movzwl 0x28(%ebx),%esi
f010670e:	0f b7 7d e2          	movzwl -0x1e(%ebp),%edi
f0106712:	01 df                	add    %ebx,%edi
static uint8_t
sum(void *addr, int len)
{
  int i, sum;

  sum = 0;
f0106714:	ba 00 00 00 00       	mov    $0x0,%edx
  for (i = 0; i < len; i++)
f0106719:	b8 00 00 00 00       	mov    $0x0,%eax
f010671e:	eb 09                	jmp    f0106729 <mp_init+0x19f>
    sum += ((uint8_t*)addr)[i];
f0106720:	0f b6 0c 07          	movzbl (%edi,%eax,1),%ecx
f0106724:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
  int i, sum;

  sum = 0;
  for (i = 0; i < len; i++)
f0106726:	83 c0 01             	add    $0x1,%eax
f0106729:	39 c6                	cmp    %eax,%esi
f010672b:	7f f3                	jg     f0106720 <mp_init+0x196>
  }
  if (conf->version != 1 && conf->version != 4) {
    cprintf("SMP: Unsupported MP version %d\n", conf->version);
    return NULL;
  }
  if ((sum((uint8_t*)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010672d:	02 53 2a             	add    0x2a(%ebx),%dl
f0106730:	84 d2                	test   %dl,%dl
f0106732:	74 11                	je     f0106745 <mp_init+0x1bb>
    cprintf("SMP: Bad MP configuration extended checksum\n");
f0106734:	c7 04 24 98 8a 10 f0 	movl   $0xf0108a98,(%esp)
f010673b:	e8 30 d8 ff ff       	call   f0103f70 <cprintf>
f0106740:	e9 34 01 00 00       	jmp    f0106879 <mp_init+0x2ef>
  struct mpproc *proc;
  uint8_t *p;
  unsigned int i;

  bootcpu = &cpus[0];
  if ((conf = mpconfig(&mp)) == 0)
f0106745:	85 db                	test   %ebx,%ebx
f0106747:	0f 84 2c 01 00 00    	je     f0106879 <mp_init+0x2ef>
    return;
  ismp = 1;
f010674d:	c7 05 00 d0 20 f0 01 	movl   $0x1,0xf020d000
f0106754:	00 00 00 
  lapicaddr = conf->lapicaddr;
f0106757:	8b 43 24             	mov    0x24(%ebx),%eax
f010675a:	a3 00 e0 24 f0       	mov    %eax,0xf024e000

  for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010675f:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0106762:	be 00 00 00 00       	mov    $0x0,%esi
f0106767:	e9 86 00 00 00       	jmp    f01067f2 <mp_init+0x268>
    switch (*p) {
f010676c:	0f b6 07             	movzbl (%edi),%eax
f010676f:	84 c0                	test   %al,%al
f0106771:	74 06                	je     f0106779 <mp_init+0x1ef>
f0106773:	3c 04                	cmp    $0x4,%al
f0106775:	77 57                	ja     f01067ce <mp_init+0x244>
f0106777:	eb 50                	jmp    f01067c9 <mp_init+0x23f>
    case MPPROC:
      proc = (struct mpproc *)p;
      if (proc->flags & MPPROC_BOOT)
f0106779:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f010677d:	8d 76 00             	lea    0x0(%esi),%esi
f0106780:	74 11                	je     f0106793 <mp_init+0x209>
        bootcpu = &cpus[ncpu];
f0106782:	6b 05 c4 d3 20 f0 74 	imul   $0x74,0xf020d3c4,%eax
f0106789:	05 20 d0 20 f0       	add    $0xf020d020,%eax
f010678e:	a3 c0 d3 20 f0       	mov    %eax,0xf020d3c0
      if (ncpu < NCPU) {
f0106793:	a1 c4 d3 20 f0       	mov    0xf020d3c4,%eax
f0106798:	83 f8 07             	cmp    $0x7,%eax
f010679b:	7f 13                	jg     f01067b0 <mp_init+0x226>
        cpus[ncpu].cpu_id = ncpu;
f010679d:	6b d0 74             	imul   $0x74,%eax,%edx
f01067a0:	88 82 20 d0 20 f0    	mov    %al,-0xfdf2fe0(%edx)
        ncpu++;
f01067a6:	83 c0 01             	add    $0x1,%eax
f01067a9:	a3 c4 d3 20 f0       	mov    %eax,0xf020d3c4
f01067ae:	eb 14                	jmp    f01067c4 <mp_init+0x23a>
      } else
        cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01067b0:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f01067b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01067b8:	c7 04 24 c8 8a 10 f0 	movl   $0xf0108ac8,(%esp)
f01067bf:	e8 ac d7 ff ff       	call   f0103f70 <cprintf>
                proc->apicid);
      p += sizeof(struct mpproc);
f01067c4:	83 c7 14             	add    $0x14,%edi
      continue;
f01067c7:	eb 26                	jmp    f01067ef <mp_init+0x265>
    case MPBUS:
    case MPIOAPIC:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
f01067c9:	83 c7 08             	add    $0x8,%edi
      continue;
f01067cc:	eb 21                	jmp    f01067ef <mp_init+0x265>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
f01067ce:	0f b6 c0             	movzbl %al,%eax
f01067d1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01067d5:	c7 04 24 f0 8a 10 f0 	movl   $0xf0108af0,(%esp)
f01067dc:	e8 8f d7 ff ff       	call   f0103f70 <cprintf>
      ismp = 0;
f01067e1:	c7 05 00 d0 20 f0 00 	movl   $0x0,0xf020d000
f01067e8:	00 00 00 
      i = conf->entry;
f01067eb:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
  if ((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapicaddr = conf->lapicaddr;

  for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01067ef:	83 c6 01             	add    $0x1,%esi
f01067f2:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f01067f6:	39 c6                	cmp    %eax,%esi
f01067f8:	0f 82 6e ff ff ff    	jb     f010676c <mp_init+0x1e2>
      ismp = 0;
      i = conf->entry;
    }
  }

  bootcpu->cpu_status = CPU_STARTED;
f01067fe:	a1 c0 d3 20 f0       	mov    0xf020d3c0,%eax
f0106803:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
  if (!ismp) {
f010680a:	83 3d 00 d0 20 f0 00 	cmpl   $0x0,0xf020d000
f0106811:	75 22                	jne    f0106835 <mp_init+0x2ab>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
f0106813:	c7 05 c4 d3 20 f0 01 	movl   $0x1,0xf020d3c4
f010681a:	00 00 00 
    lapicaddr = 0;
f010681d:	c7 05 00 e0 24 f0 00 	movl   $0x0,0xf024e000
f0106824:	00 00 00 
    cprintf("SMP: configuration not found, SMP disabled\n");
f0106827:	c7 04 24 10 8b 10 f0 	movl   $0xf0108b10,(%esp)
f010682e:	e8 3d d7 ff ff       	call   f0103f70 <cprintf>
    return;
f0106833:	eb 44                	jmp    f0106879 <mp_init+0x2ef>
  }
  cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0106835:	8b 15 c4 d3 20 f0    	mov    0xf020d3c4,%edx
f010683b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010683f:	0f b6 00             	movzbl (%eax),%eax
f0106842:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106846:	c7 04 24 97 8b 10 f0 	movl   $0xf0108b97,(%esp)
f010684d:	e8 1e d7 ff ff       	call   f0103f70 <cprintf>

  if (mp->imcrp) {
f0106852:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106855:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106859:	74 1e                	je     f0106879 <mp_init+0x2ef>
    // [MP 3.2.6.1] If the hardware implements PIC mode,
    // switch to getting interrupts from the LAPIC.
    cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f010685b:	c7 04 24 3c 8b 10 f0 	movl   $0xf0108b3c,(%esp)
f0106862:	e8 09 d7 ff ff       	call   f0103f70 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
  __asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106867:	ba 22 00 00 00       	mov    $0x22,%edx
f010686c:	b8 70 00 00 00       	mov    $0x70,%eax
f0106871:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
  uint8_t data;
  __asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106872:	b2 23                	mov    $0x23,%dl
f0106874:	ec                   	in     (%dx),%al
    outb(0x22, 0x70);               // Select IMCR
    outb(0x23, inb(0x23) | 1);      // Mask external interrupts.
f0106875:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
  __asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106878:	ee                   	out    %al,(%dx)
  }
}
f0106879:	83 c4 2c             	add    $0x2c,%esp
f010687c:	5b                   	pop    %ebx
f010687d:	5e                   	pop    %esi
f010687e:	5f                   	pop    %edi
f010687f:	5d                   	pop    %ebp
f0106880:	c3                   	ret    

f0106881 <lapicw>:
physaddr_t lapicaddr;                 // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0106881:	55                   	push   %ebp
f0106882:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
f0106884:	8b 0d 04 e0 24 f0    	mov    0xf024e004,%ecx
f010688a:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f010688d:	89 10                	mov    %edx,(%eax)
  lapic[ID];        // wait for write to finish, by reading
f010688f:	a1 04 e0 24 f0       	mov    0xf024e004,%eax
f0106894:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106897:	5d                   	pop    %ebp
f0106898:	c3                   	ret    

f0106899 <cpunum>:
  lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106899:	55                   	push   %ebp
f010689a:	89 e5                	mov    %esp,%ebp
  if (lapic)
f010689c:	a1 04 e0 24 f0       	mov    0xf024e004,%eax
f01068a1:	85 c0                	test   %eax,%eax
f01068a3:	74 08                	je     f01068ad <cpunum+0x14>
    return lapic[ID] >> 24;
f01068a5:	8b 40 20             	mov    0x20(%eax),%eax
f01068a8:	c1 e8 18             	shr    $0x18,%eax
f01068ab:	eb 05                	jmp    f01068b2 <cpunum+0x19>
  return 0;
f01068ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01068b2:	5d                   	pop    %ebp
f01068b3:	c3                   	ret    

f01068b4 <lapic_init>:
}

void
lapic_init(void)
{
  if (!lapicaddr)
f01068b4:	a1 00 e0 24 f0       	mov    0xf024e000,%eax
f01068b9:	85 c0                	test   %eax,%eax
f01068bb:	0f 84 23 01 00 00    	je     f01069e4 <lapic_init+0x130>
  lapic[ID];        // wait for write to finish, by reading
}

void
lapic_init(void)
{
f01068c1:	55                   	push   %ebp
f01068c2:	89 e5                	mov    %esp,%ebp
f01068c4:	83 ec 18             	sub    $0x18,%esp
  if (!lapicaddr)
    return;

  // lapicaddr is the physical address of the LAPIC's 4K MMIO
  // region.  Map it in to virtual memory so we can access it.
  lapic = mmio_map_region(lapicaddr, 4096);
f01068c7:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01068ce:	00 
f01068cf:	89 04 24             	mov    %eax,(%esp)
f01068d2:	e8 cb ab ff ff       	call   f01014a2 <mmio_map_region>
f01068d7:	a3 04 e0 24 f0       	mov    %eax,0xf024e004

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01068dc:	ba 27 01 00 00       	mov    $0x127,%edx
f01068e1:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01068e6:	e8 96 ff ff ff       	call   f0106881 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If we cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
f01068eb:	ba 0b 00 00 00       	mov    $0xb,%edx
f01068f0:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01068f5:	e8 87 ff ff ff       	call   f0106881 <lapicw>
  lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01068fa:	ba 20 00 02 00       	mov    $0x20020,%edx
f01068ff:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106904:	e8 78 ff ff ff       	call   f0106881 <lapicw>
  lapicw(TICR, 10000000);
f0106909:	ba 80 96 98 00       	mov    $0x989680,%edx
f010690e:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106913:	e8 69 ff ff ff       	call   f0106881 <lapicw>
  //
  // According to Intel MP Specification, the BIOS should initialize
  // BSP's local APIC in Virtual Wire Mode, in which 8259A's
  // INTR is virtually connected to BSP's LINTIN0. In this mode,
  // we do not need to program the IOAPIC.
  if (thiscpu != bootcpu)
f0106918:	e8 7c ff ff ff       	call   f0106899 <cpunum>
f010691d:	6b c0 74             	imul   $0x74,%eax,%eax
f0106920:	05 20 d0 20 f0       	add    $0xf020d020,%eax
f0106925:	39 05 c0 d3 20 f0    	cmp    %eax,0xf020d3c0
f010692b:	74 0f                	je     f010693c <lapic_init+0x88>
    lapicw(LINT0, MASKED);
f010692d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106932:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106937:	e8 45 ff ff ff       	call   f0106881 <lapicw>

  // Disable NMI (LINT1) on all CPUs
  lapicw(LINT1, MASKED);
f010693c:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106941:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106946:	e8 36 ff ff ff       	call   f0106881 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if (((lapic[VER]>>16) & 0xFF) >= 4)
f010694b:	a1 04 e0 24 f0       	mov    0xf024e004,%eax
f0106950:	8b 40 30             	mov    0x30(%eax),%eax
f0106953:	c1 e8 10             	shr    $0x10,%eax
f0106956:	3c 03                	cmp    $0x3,%al
f0106958:	76 0f                	jbe    f0106969 <lapic_init+0xb5>
    lapicw(PCINT, MASKED);
f010695a:	ba 00 00 01 00       	mov    $0x10000,%edx
f010695f:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106964:	e8 18 ff ff ff       	call   f0106881 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106969:	ba 33 00 00 00       	mov    $0x33,%edx
f010696e:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106973:	e8 09 ff ff ff       	call   f0106881 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
f0106978:	ba 00 00 00 00       	mov    $0x0,%edx
f010697d:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106982:	e8 fa fe ff ff       	call   f0106881 <lapicw>
  lapicw(ESR, 0);
f0106987:	ba 00 00 00 00       	mov    $0x0,%edx
f010698c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106991:	e8 eb fe ff ff       	call   f0106881 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
f0106996:	ba 00 00 00 00       	mov    $0x0,%edx
f010699b:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01069a0:	e8 dc fe ff ff       	call   f0106881 <lapicw>

  // Send an Init Level De-Assert to synchronize arbitration ID's.
  lapicw(ICRHI, 0);
f01069a5:	ba 00 00 00 00       	mov    $0x0,%edx
f01069aa:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01069af:	e8 cd fe ff ff       	call   f0106881 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
f01069b4:	ba 00 85 08 00       	mov    $0x88500,%edx
f01069b9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01069be:	e8 be fe ff ff       	call   f0106881 <lapicw>
  while (lapic[ICRLO] & DELIVS)
f01069c3:	8b 15 04 e0 24 f0    	mov    0xf024e004,%edx
f01069c9:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01069cf:	f6 c4 10             	test   $0x10,%ah
f01069d2:	75 f5                	jne    f01069c9 <lapic_init+0x115>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
f01069d4:	ba 00 00 00 00       	mov    $0x0,%edx
f01069d9:	b8 20 00 00 00       	mov    $0x20,%eax
f01069de:	e8 9e fe ff ff       	call   f0106881 <lapicw>
}
f01069e3:	c9                   	leave  
f01069e4:	f3 c3                	repz ret 

f01069e6 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
  if (lapic)
f01069e6:	83 3d 04 e0 24 f0 00 	cmpl   $0x0,0xf024e004
f01069ed:	74 13                	je     f0106a02 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01069ef:	55                   	push   %ebp
f01069f0:	89 e5                	mov    %esp,%ebp
  if (lapic)
    lapicw(EOI, 0);
f01069f2:	ba 00 00 00 00       	mov    $0x0,%edx
f01069f7:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01069fc:	e8 80 fe ff ff       	call   f0106881 <lapicw>
}
f0106a01:	5d                   	pop    %ebp
f0106a02:	f3 c3                	repz ret 

f0106a04 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106a04:	55                   	push   %ebp
f0106a05:	89 e5                	mov    %esp,%ebp
f0106a07:	56                   	push   %esi
f0106a08:	53                   	push   %ebx
f0106a09:	83 ec 10             	sub    $0x10,%esp
f0106a0c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0106a0f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106a12:	ba 70 00 00 00       	mov    $0x70,%edx
f0106a17:	b8 0f 00 00 00       	mov    $0xf,%eax
f0106a1c:	ee                   	out    %al,(%dx)
f0106a1d:	b2 71                	mov    $0x71,%dl
f0106a1f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106a24:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106a25:	83 3d 88 ce 20 f0 00 	cmpl   $0x0,0xf020ce88
f0106a2c:	75 24                	jne    f0106a52 <lapic_startap+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106a2e:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f0106a35:	00 
f0106a36:	c7 44 24 08 a4 6f 10 	movl   $0xf0106fa4,0x8(%esp)
f0106a3d:	f0 
f0106a3e:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f0106a45:	00 
f0106a46:	c7 04 24 b4 8b 10 f0 	movl   $0xf0108bb4,(%esp)
f0106a4d:	e8 ee 95 ff ff       	call   f0100040 <_panic>
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);                          // offset 0xF is shutdown code
  outb(IO_RTC+1, 0x0A);
  wrv = (uint16_t*)KADDR((0x40 << 4 | 0x67)); // Warm reset vector
  wrv[0] = 0;
f0106a52:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106a59:	00 00 
  wrv[1] = addr >> 4;
f0106a5b:	89 f0                	mov    %esi,%eax
f0106a5d:	c1 e8 04             	shr    $0x4,%eax
f0106a60:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid << 24);
f0106a66:	c1 e3 18             	shl    $0x18,%ebx
f0106a69:	89 da                	mov    %ebx,%edx
f0106a6b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106a70:	e8 0c fe ff ff       	call   f0106881 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106a75:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106a7a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106a7f:	e8 fd fd ff ff       	call   f0106881 <lapicw>
  microdelay(200);
  lapicw(ICRLO, INIT | LEVEL);
f0106a84:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106a89:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106a8e:	e8 ee fd ff ff       	call   f0106881 <lapicw>
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for (i = 0; i < 2; i++) {
    lapicw(ICRHI, apicid << 24);
    lapicw(ICRLO, STARTUP | (addr >> 12));
f0106a93:	c1 ee 0c             	shr    $0xc,%esi
f0106a96:	81 ce 00 06 00 00    	or     $0x600,%esi
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for (i = 0; i < 2; i++) {
    lapicw(ICRHI, apicid << 24);
f0106a9c:	89 da                	mov    %ebx,%edx
f0106a9e:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106aa3:	e8 d9 fd ff ff       	call   f0106881 <lapicw>
    lapicw(ICRLO, STARTUP | (addr >> 12));
f0106aa8:	89 f2                	mov    %esi,%edx
f0106aaa:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106aaf:	e8 cd fd ff ff       	call   f0106881 <lapicw>
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for (i = 0; i < 2; i++) {
    lapicw(ICRHI, apicid << 24);
f0106ab4:	89 da                	mov    %ebx,%edx
f0106ab6:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106abb:	e8 c1 fd ff ff       	call   f0106881 <lapicw>
    lapicw(ICRLO, STARTUP | (addr >> 12));
f0106ac0:	89 f2                	mov    %esi,%edx
f0106ac2:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106ac7:	e8 b5 fd ff ff       	call   f0106881 <lapicw>
    microdelay(200);
  }
}
f0106acc:	83 c4 10             	add    $0x10,%esp
f0106acf:	5b                   	pop    %ebx
f0106ad0:	5e                   	pop    %esi
f0106ad1:	5d                   	pop    %ebp
f0106ad2:	c3                   	ret    

f0106ad3 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106ad3:	55                   	push   %ebp
f0106ad4:	89 e5                	mov    %esp,%ebp
  lapicw(ICRLO, OTHERS | FIXED | vector);
f0106ad6:	8b 55 08             	mov    0x8(%ebp),%edx
f0106ad9:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106adf:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106ae4:	e8 98 fd ff ff       	call   f0106881 <lapicw>
  while (lapic[ICRLO] & DELIVS)
f0106ae9:	8b 15 04 e0 24 f0    	mov    0xf024e004,%edx
f0106aef:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106af5:	f6 c4 10             	test   $0x10,%ah
f0106af8:	75 f5                	jne    f0106aef <lapic_ipi+0x1c>
    ;
}
f0106afa:	5d                   	pop    %ebp
f0106afb:	c3                   	ret    

f0106afc <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106afc:	55                   	push   %ebp
f0106afd:	89 e5                	mov    %esp,%ebp
f0106aff:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->locked = 0;
f0106b02:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
  lk->name = name;
f0106b08:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106b0b:	89 50 04             	mov    %edx,0x4(%eax)
  lk->cpu = 0;
f0106b0e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106b15:	5d                   	pop    %ebp
f0106b16:	c3                   	ret    

f0106b17 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106b17:	55                   	push   %ebp
f0106b18:	89 e5                	mov    %esp,%ebp
f0106b1a:	56                   	push   %esi
f0106b1b:	53                   	push   %ebx
f0106b1c:	83 ec 20             	sub    $0x20,%esp
f0106b1f:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
  return lock->locked && lock->cpu == thiscpu;
f0106b22:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106b25:	75 07                	jne    f0106b2e <spin_lock+0x17>
xchg(volatile uint32_t *addr, uint32_t newval)
{
  uint32_t result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile ("lock; xchgl %0, %1" :
f0106b27:	ba 01 00 00 00       	mov    $0x1,%edx
f0106b2c:	eb 42                	jmp    f0106b70 <spin_lock+0x59>
f0106b2e:	8b 73 08             	mov    0x8(%ebx),%esi
f0106b31:	e8 63 fd ff ff       	call   f0106899 <cpunum>
f0106b36:	6b c0 74             	imul   $0x74,%eax,%eax
f0106b39:	05 20 d0 20 f0       	add    $0xf020d020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
  if (holding(lk))
f0106b3e:	39 c6                	cmp    %eax,%esi
f0106b40:	75 e5                	jne    f0106b27 <spin_lock+0x10>
    panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106b42:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106b45:	e8 4f fd ff ff       	call   f0106899 <cpunum>
f0106b4a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106b4e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106b52:	c7 44 24 08 c4 8b 10 	movl   $0xf0108bc4,0x8(%esp)
f0106b59:	f0 
f0106b5a:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0106b61:	00 
f0106b62:	c7 04 24 28 8c 10 f0 	movl   $0xf0108c28,(%esp)
f0106b69:	e8 d2 94 ff ff       	call   f0100040 <_panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it.
  while (xchg(&lk->locked, 1) != 0)
    asm volatile ("pause");
f0106b6e:	f3 90                	pause  
f0106b70:	89 d0                	mov    %edx,%eax
f0106b72:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it.
  while (xchg(&lk->locked, 1) != 0)
f0106b75:	85 c0                	test   %eax,%eax
f0106b77:	75 f5                	jne    f0106b6e <spin_lock+0x57>
    asm volatile ("pause");

  // Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
  lk->cpu = thiscpu;
f0106b79:	e8 1b fd ff ff       	call   f0106899 <cpunum>
f0106b7e:	6b c0 74             	imul   $0x74,%eax,%eax
f0106b81:	05 20 d0 20 f0       	add    $0xf020d020,%eax
f0106b86:	89 43 08             	mov    %eax,0x8(%ebx)
  get_caller_pcs(lk->pcs);
f0106b89:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
  uint32_t *ebp;
  int i;

  ebp = (uint32_t*)read_ebp();
f0106b8c:	89 ea                	mov    %ebp,%edx
  for (i = 0; i < 10; i++) {
f0106b8e:	b8 00 00 00 00       	mov    $0x0,%eax
    if (ebp == 0 || ebp < (uint32_t*)ULIM)
f0106b93:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106b99:	76 12                	jbe    f0106bad <spin_lock+0x96>
      break;
    pcs[i] = ebp[1];                      // saved %eip
f0106b9b:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106b9e:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
    ebp = (uint32_t*)ebp[0];              // saved %ebp
f0106ba1:	8b 12                	mov    (%edx),%edx
{
  uint32_t *ebp;
  int i;

  ebp = (uint32_t*)read_ebp();
  for (i = 0; i < 10; i++) {
f0106ba3:	83 c0 01             	add    $0x1,%eax
f0106ba6:	83 f8 0a             	cmp    $0xa,%eax
f0106ba9:	75 e8                	jne    f0106b93 <spin_lock+0x7c>
f0106bab:	eb 0f                	jmp    f0106bbc <spin_lock+0xa5>
      break;
    pcs[i] = ebp[1];                      // saved %eip
    ebp = (uint32_t*)ebp[0];              // saved %ebp
  }
  for (; i < 10; i++)
    pcs[i] = 0;
f0106bad:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
    if (ebp == 0 || ebp < (uint32_t*)ULIM)
      break;
    pcs[i] = ebp[1];                      // saved %eip
    ebp = (uint32_t*)ebp[0];              // saved %ebp
  }
  for (; i < 10; i++)
f0106bb4:	83 c0 01             	add    $0x1,%eax
f0106bb7:	83 f8 09             	cmp    $0x9,%eax
f0106bba:	7e f1                	jle    f0106bad <spin_lock+0x96>
  // Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
  lk->cpu = thiscpu;
  get_caller_pcs(lk->pcs);
#endif
}
f0106bbc:	83 c4 20             	add    $0x20,%esp
f0106bbf:	5b                   	pop    %ebx
f0106bc0:	5e                   	pop    %esi
f0106bc1:	5d                   	pop    %ebp
f0106bc2:	c3                   	ret    

f0106bc3 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106bc3:	55                   	push   %ebp
f0106bc4:	89 e5                	mov    %esp,%ebp
f0106bc6:	57                   	push   %edi
f0106bc7:	56                   	push   %esi
f0106bc8:	53                   	push   %ebx
f0106bc9:	83 ec 6c             	sub    $0x6c,%esp
f0106bcc:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
  return lock->locked && lock->cpu == thiscpu;
f0106bcf:	83 3e 00             	cmpl   $0x0,(%esi)
f0106bd2:	74 18                	je     f0106bec <spin_unlock+0x29>
f0106bd4:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106bd7:	e8 bd fc ff ff       	call   f0106899 <cpunum>
f0106bdc:	6b c0 74             	imul   $0x74,%eax,%eax
f0106bdf:	05 20 d0 20 f0       	add    $0xf020d020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
  if (!holding(lk)) {
f0106be4:	39 c3                	cmp    %eax,%ebx
f0106be6:	0f 84 ce 00 00 00    	je     f0106cba <spin_unlock+0xf7>
    int i;
    uint32_t pcs[10];
    // Nab the acquiring EIP chain before it gets released
    memmove(pcs, lk->pcs, sizeof pcs);
f0106bec:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0106bf3:	00 
f0106bf4:	8d 46 0c             	lea    0xc(%esi),%eax
f0106bf7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106bfb:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106bfe:	89 1c 24             	mov    %ebx,(%esp)
f0106c01:	e8 8e f6 ff ff       	call   f0106294 <memmove>
    cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:",
            cpunum(), lk->name, lk->cpu->cpu_id);
f0106c06:	8b 46 08             	mov    0x8(%esi),%eax
  if (!holding(lk)) {
    int i;
    uint32_t pcs[10];
    // Nab the acquiring EIP chain before it gets released
    memmove(pcs, lk->pcs, sizeof pcs);
    cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:",
f0106c09:	0f b6 38             	movzbl (%eax),%edi
f0106c0c:	8b 76 04             	mov    0x4(%esi),%esi
f0106c0f:	e8 85 fc ff ff       	call   f0106899 <cpunum>
f0106c14:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106c18:	89 74 24 08          	mov    %esi,0x8(%esp)
f0106c1c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106c20:	c7 04 24 f0 8b 10 f0 	movl   $0xf0108bf0,(%esp)
f0106c27:	e8 44 d3 ff ff       	call   f0103f70 <cprintf>
            cpunum(), lk->name, lk->cpu->cpu_id);
    for (i = 0; i < 10 && pcs[i]; i++) {
      struct Eipdebuginfo info;
      if (debuginfo_eip(pcs[i], &info) >= 0)
f0106c2c:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0106c2f:	eb 65                	jmp    f0106c96 <spin_unlock+0xd3>
f0106c31:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106c35:	89 04 24             	mov    %eax,(%esp)
f0106c38:	e8 c5 ea ff ff       	call   f0105702 <debuginfo_eip>
f0106c3d:	85 c0                	test   %eax,%eax
f0106c3f:	78 39                	js     f0106c7a <spin_unlock+0xb7>
        cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
                info.eip_file, info.eip_line,
                info.eip_fn_namelen, info.eip_fn_name,
                pcs[i] - info.eip_fn_addr);
f0106c41:	8b 06                	mov    (%esi),%eax
    cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:",
            cpunum(), lk->name, lk->cpu->cpu_id);
    for (i = 0; i < 10 && pcs[i]; i++) {
      struct Eipdebuginfo info;
      if (debuginfo_eip(pcs[i], &info) >= 0)
        cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106c43:	89 c2                	mov    %eax,%edx
f0106c45:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0106c48:	89 54 24 18          	mov    %edx,0x18(%esp)
f0106c4c:	8b 55 b0             	mov    -0x50(%ebp),%edx
f0106c4f:	89 54 24 14          	mov    %edx,0x14(%esp)
f0106c53:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0106c56:	89 54 24 10          	mov    %edx,0x10(%esp)
f0106c5a:	8b 55 ac             	mov    -0x54(%ebp),%edx
f0106c5d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106c61:	8b 55 a8             	mov    -0x58(%ebp),%edx
f0106c64:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106c68:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106c6c:	c7 04 24 38 8c 10 f0 	movl   $0xf0108c38,(%esp)
f0106c73:	e8 f8 d2 ff ff       	call   f0103f70 <cprintf>
f0106c78:	eb 12                	jmp    f0106c8c <spin_unlock+0xc9>
                info.eip_file, info.eip_line,
                info.eip_fn_namelen, info.eip_fn_name,
                pcs[i] - info.eip_fn_addr);
      else
        cprintf("  %08x\n", pcs[i]);
f0106c7a:	8b 06                	mov    (%esi),%eax
f0106c7c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106c80:	c7 04 24 4f 8c 10 f0 	movl   $0xf0108c4f,(%esp)
f0106c87:	e8 e4 d2 ff ff       	call   f0103f70 <cprintf>
f0106c8c:	83 c3 04             	add    $0x4,%ebx
    uint32_t pcs[10];
    // Nab the acquiring EIP chain before it gets released
    memmove(pcs, lk->pcs, sizeof pcs);
    cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:",
            cpunum(), lk->name, lk->cpu->cpu_id);
    for (i = 0; i < 10 && pcs[i]; i++) {
f0106c8f:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106c92:	39 c3                	cmp    %eax,%ebx
f0106c94:	74 08                	je     f0106c9e <spin_unlock+0xdb>
f0106c96:	89 de                	mov    %ebx,%esi
f0106c98:	8b 03                	mov    (%ebx),%eax
f0106c9a:	85 c0                	test   %eax,%eax
f0106c9c:	75 93                	jne    f0106c31 <spin_unlock+0x6e>
                info.eip_fn_namelen, info.eip_fn_name,
                pcs[i] - info.eip_fn_addr);
      else
        cprintf("  %08x\n", pcs[i]);
    }
    panic("spin_unlock");
f0106c9e:	c7 44 24 08 57 8c 10 	movl   $0xf0108c57,0x8(%esp)
f0106ca5:	f0 
f0106ca6:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f0106cad:	00 
f0106cae:	c7 04 24 28 8c 10 f0 	movl   $0xf0108c28,(%esp)
f0106cb5:	e8 86 93 ff ff       	call   f0100040 <_panic>
  }

  lk->pcs[0] = 0;
f0106cba:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
  lk->cpu = 0;
f0106cc1:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
f0106cc8:	b8 00 00 00 00       	mov    $0x0,%eax
f0106ccd:	f0 87 06             	lock xchg %eax,(%esi)
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
}
f0106cd0:	83 c4 6c             	add    $0x6c,%esp
f0106cd3:	5b                   	pop    %ebx
f0106cd4:	5e                   	pop    %esi
f0106cd5:	5f                   	pop    %edi
f0106cd6:	5d                   	pop    %ebp
f0106cd7:	c3                   	ret    
f0106cd8:	66 90                	xchg   %ax,%ax
f0106cda:	66 90                	xchg   %ax,%ax
f0106cdc:	66 90                	xchg   %ax,%ax
f0106cde:	66 90                	xchg   %ax,%ax

f0106ce0 <__udivdi3>:
f0106ce0:	55                   	push   %ebp
f0106ce1:	57                   	push   %edi
f0106ce2:	56                   	push   %esi
f0106ce3:	83 ec 0c             	sub    $0xc,%esp
f0106ce6:	8b 44 24 28          	mov    0x28(%esp),%eax
f0106cea:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f0106cee:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0106cf2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0106cf6:	85 c0                	test   %eax,%eax
f0106cf8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106cfc:	89 ea                	mov    %ebp,%edx
f0106cfe:	89 0c 24             	mov    %ecx,(%esp)
f0106d01:	75 2d                	jne    f0106d30 <__udivdi3+0x50>
f0106d03:	39 e9                	cmp    %ebp,%ecx
f0106d05:	77 61                	ja     f0106d68 <__udivdi3+0x88>
f0106d07:	85 c9                	test   %ecx,%ecx
f0106d09:	89 ce                	mov    %ecx,%esi
f0106d0b:	75 0b                	jne    f0106d18 <__udivdi3+0x38>
f0106d0d:	b8 01 00 00 00       	mov    $0x1,%eax
f0106d12:	31 d2                	xor    %edx,%edx
f0106d14:	f7 f1                	div    %ecx
f0106d16:	89 c6                	mov    %eax,%esi
f0106d18:	31 d2                	xor    %edx,%edx
f0106d1a:	89 e8                	mov    %ebp,%eax
f0106d1c:	f7 f6                	div    %esi
f0106d1e:	89 c5                	mov    %eax,%ebp
f0106d20:	89 f8                	mov    %edi,%eax
f0106d22:	f7 f6                	div    %esi
f0106d24:	89 ea                	mov    %ebp,%edx
f0106d26:	83 c4 0c             	add    $0xc,%esp
f0106d29:	5e                   	pop    %esi
f0106d2a:	5f                   	pop    %edi
f0106d2b:	5d                   	pop    %ebp
f0106d2c:	c3                   	ret    
f0106d2d:	8d 76 00             	lea    0x0(%esi),%esi
f0106d30:	39 e8                	cmp    %ebp,%eax
f0106d32:	77 24                	ja     f0106d58 <__udivdi3+0x78>
f0106d34:	0f bd e8             	bsr    %eax,%ebp
f0106d37:	83 f5 1f             	xor    $0x1f,%ebp
f0106d3a:	75 3c                	jne    f0106d78 <__udivdi3+0x98>
f0106d3c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0106d40:	39 34 24             	cmp    %esi,(%esp)
f0106d43:	0f 86 9f 00 00 00    	jbe    f0106de8 <__udivdi3+0x108>
f0106d49:	39 d0                	cmp    %edx,%eax
f0106d4b:	0f 82 97 00 00 00    	jb     f0106de8 <__udivdi3+0x108>
f0106d51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106d58:	31 d2                	xor    %edx,%edx
f0106d5a:	31 c0                	xor    %eax,%eax
f0106d5c:	83 c4 0c             	add    $0xc,%esp
f0106d5f:	5e                   	pop    %esi
f0106d60:	5f                   	pop    %edi
f0106d61:	5d                   	pop    %ebp
f0106d62:	c3                   	ret    
f0106d63:	90                   	nop
f0106d64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106d68:	89 f8                	mov    %edi,%eax
f0106d6a:	f7 f1                	div    %ecx
f0106d6c:	31 d2                	xor    %edx,%edx
f0106d6e:	83 c4 0c             	add    $0xc,%esp
f0106d71:	5e                   	pop    %esi
f0106d72:	5f                   	pop    %edi
f0106d73:	5d                   	pop    %ebp
f0106d74:	c3                   	ret    
f0106d75:	8d 76 00             	lea    0x0(%esi),%esi
f0106d78:	89 e9                	mov    %ebp,%ecx
f0106d7a:	8b 3c 24             	mov    (%esp),%edi
f0106d7d:	d3 e0                	shl    %cl,%eax
f0106d7f:	89 c6                	mov    %eax,%esi
f0106d81:	b8 20 00 00 00       	mov    $0x20,%eax
f0106d86:	29 e8                	sub    %ebp,%eax
f0106d88:	89 c1                	mov    %eax,%ecx
f0106d8a:	d3 ef                	shr    %cl,%edi
f0106d8c:	89 e9                	mov    %ebp,%ecx
f0106d8e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0106d92:	8b 3c 24             	mov    (%esp),%edi
f0106d95:	09 74 24 08          	or     %esi,0x8(%esp)
f0106d99:	89 d6                	mov    %edx,%esi
f0106d9b:	d3 e7                	shl    %cl,%edi
f0106d9d:	89 c1                	mov    %eax,%ecx
f0106d9f:	89 3c 24             	mov    %edi,(%esp)
f0106da2:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106da6:	d3 ee                	shr    %cl,%esi
f0106da8:	89 e9                	mov    %ebp,%ecx
f0106daa:	d3 e2                	shl    %cl,%edx
f0106dac:	89 c1                	mov    %eax,%ecx
f0106dae:	d3 ef                	shr    %cl,%edi
f0106db0:	09 d7                	or     %edx,%edi
f0106db2:	89 f2                	mov    %esi,%edx
f0106db4:	89 f8                	mov    %edi,%eax
f0106db6:	f7 74 24 08          	divl   0x8(%esp)
f0106dba:	89 d6                	mov    %edx,%esi
f0106dbc:	89 c7                	mov    %eax,%edi
f0106dbe:	f7 24 24             	mull   (%esp)
f0106dc1:	39 d6                	cmp    %edx,%esi
f0106dc3:	89 14 24             	mov    %edx,(%esp)
f0106dc6:	72 30                	jb     f0106df8 <__udivdi3+0x118>
f0106dc8:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106dcc:	89 e9                	mov    %ebp,%ecx
f0106dce:	d3 e2                	shl    %cl,%edx
f0106dd0:	39 c2                	cmp    %eax,%edx
f0106dd2:	73 05                	jae    f0106dd9 <__udivdi3+0xf9>
f0106dd4:	3b 34 24             	cmp    (%esp),%esi
f0106dd7:	74 1f                	je     f0106df8 <__udivdi3+0x118>
f0106dd9:	89 f8                	mov    %edi,%eax
f0106ddb:	31 d2                	xor    %edx,%edx
f0106ddd:	e9 7a ff ff ff       	jmp    f0106d5c <__udivdi3+0x7c>
f0106de2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106de8:	31 d2                	xor    %edx,%edx
f0106dea:	b8 01 00 00 00       	mov    $0x1,%eax
f0106def:	e9 68 ff ff ff       	jmp    f0106d5c <__udivdi3+0x7c>
f0106df4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106df8:	8d 47 ff             	lea    -0x1(%edi),%eax
f0106dfb:	31 d2                	xor    %edx,%edx
f0106dfd:	83 c4 0c             	add    $0xc,%esp
f0106e00:	5e                   	pop    %esi
f0106e01:	5f                   	pop    %edi
f0106e02:	5d                   	pop    %ebp
f0106e03:	c3                   	ret    
f0106e04:	66 90                	xchg   %ax,%ax
f0106e06:	66 90                	xchg   %ax,%ax
f0106e08:	66 90                	xchg   %ax,%ax
f0106e0a:	66 90                	xchg   %ax,%ax
f0106e0c:	66 90                	xchg   %ax,%ax
f0106e0e:	66 90                	xchg   %ax,%ax

f0106e10 <__umoddi3>:
f0106e10:	55                   	push   %ebp
f0106e11:	57                   	push   %edi
f0106e12:	56                   	push   %esi
f0106e13:	83 ec 14             	sub    $0x14,%esp
f0106e16:	8b 44 24 28          	mov    0x28(%esp),%eax
f0106e1a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0106e1e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0106e22:	89 c7                	mov    %eax,%edi
f0106e24:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106e28:	8b 44 24 30          	mov    0x30(%esp),%eax
f0106e2c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0106e30:	89 34 24             	mov    %esi,(%esp)
f0106e33:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106e37:	85 c0                	test   %eax,%eax
f0106e39:	89 c2                	mov    %eax,%edx
f0106e3b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106e3f:	75 17                	jne    f0106e58 <__umoddi3+0x48>
f0106e41:	39 fe                	cmp    %edi,%esi
f0106e43:	76 4b                	jbe    f0106e90 <__umoddi3+0x80>
f0106e45:	89 c8                	mov    %ecx,%eax
f0106e47:	89 fa                	mov    %edi,%edx
f0106e49:	f7 f6                	div    %esi
f0106e4b:	89 d0                	mov    %edx,%eax
f0106e4d:	31 d2                	xor    %edx,%edx
f0106e4f:	83 c4 14             	add    $0x14,%esp
f0106e52:	5e                   	pop    %esi
f0106e53:	5f                   	pop    %edi
f0106e54:	5d                   	pop    %ebp
f0106e55:	c3                   	ret    
f0106e56:	66 90                	xchg   %ax,%ax
f0106e58:	39 f8                	cmp    %edi,%eax
f0106e5a:	77 54                	ja     f0106eb0 <__umoddi3+0xa0>
f0106e5c:	0f bd e8             	bsr    %eax,%ebp
f0106e5f:	83 f5 1f             	xor    $0x1f,%ebp
f0106e62:	75 5c                	jne    f0106ec0 <__umoddi3+0xb0>
f0106e64:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0106e68:	39 3c 24             	cmp    %edi,(%esp)
f0106e6b:	0f 87 e7 00 00 00    	ja     f0106f58 <__umoddi3+0x148>
f0106e71:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106e75:	29 f1                	sub    %esi,%ecx
f0106e77:	19 c7                	sbb    %eax,%edi
f0106e79:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106e7d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106e81:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106e85:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0106e89:	83 c4 14             	add    $0x14,%esp
f0106e8c:	5e                   	pop    %esi
f0106e8d:	5f                   	pop    %edi
f0106e8e:	5d                   	pop    %ebp
f0106e8f:	c3                   	ret    
f0106e90:	85 f6                	test   %esi,%esi
f0106e92:	89 f5                	mov    %esi,%ebp
f0106e94:	75 0b                	jne    f0106ea1 <__umoddi3+0x91>
f0106e96:	b8 01 00 00 00       	mov    $0x1,%eax
f0106e9b:	31 d2                	xor    %edx,%edx
f0106e9d:	f7 f6                	div    %esi
f0106e9f:	89 c5                	mov    %eax,%ebp
f0106ea1:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106ea5:	31 d2                	xor    %edx,%edx
f0106ea7:	f7 f5                	div    %ebp
f0106ea9:	89 c8                	mov    %ecx,%eax
f0106eab:	f7 f5                	div    %ebp
f0106ead:	eb 9c                	jmp    f0106e4b <__umoddi3+0x3b>
f0106eaf:	90                   	nop
f0106eb0:	89 c8                	mov    %ecx,%eax
f0106eb2:	89 fa                	mov    %edi,%edx
f0106eb4:	83 c4 14             	add    $0x14,%esp
f0106eb7:	5e                   	pop    %esi
f0106eb8:	5f                   	pop    %edi
f0106eb9:	5d                   	pop    %ebp
f0106eba:	c3                   	ret    
f0106ebb:	90                   	nop
f0106ebc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106ec0:	8b 04 24             	mov    (%esp),%eax
f0106ec3:	be 20 00 00 00       	mov    $0x20,%esi
f0106ec8:	89 e9                	mov    %ebp,%ecx
f0106eca:	29 ee                	sub    %ebp,%esi
f0106ecc:	d3 e2                	shl    %cl,%edx
f0106ece:	89 f1                	mov    %esi,%ecx
f0106ed0:	d3 e8                	shr    %cl,%eax
f0106ed2:	89 e9                	mov    %ebp,%ecx
f0106ed4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106ed8:	8b 04 24             	mov    (%esp),%eax
f0106edb:	09 54 24 04          	or     %edx,0x4(%esp)
f0106edf:	89 fa                	mov    %edi,%edx
f0106ee1:	d3 e0                	shl    %cl,%eax
f0106ee3:	89 f1                	mov    %esi,%ecx
f0106ee5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106ee9:	8b 44 24 10          	mov    0x10(%esp),%eax
f0106eed:	d3 ea                	shr    %cl,%edx
f0106eef:	89 e9                	mov    %ebp,%ecx
f0106ef1:	d3 e7                	shl    %cl,%edi
f0106ef3:	89 f1                	mov    %esi,%ecx
f0106ef5:	d3 e8                	shr    %cl,%eax
f0106ef7:	89 e9                	mov    %ebp,%ecx
f0106ef9:	09 f8                	or     %edi,%eax
f0106efb:	8b 7c 24 10          	mov    0x10(%esp),%edi
f0106eff:	f7 74 24 04          	divl   0x4(%esp)
f0106f03:	d3 e7                	shl    %cl,%edi
f0106f05:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106f09:	89 d7                	mov    %edx,%edi
f0106f0b:	f7 64 24 08          	mull   0x8(%esp)
f0106f0f:	39 d7                	cmp    %edx,%edi
f0106f11:	89 c1                	mov    %eax,%ecx
f0106f13:	89 14 24             	mov    %edx,(%esp)
f0106f16:	72 2c                	jb     f0106f44 <__umoddi3+0x134>
f0106f18:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f0106f1c:	72 22                	jb     f0106f40 <__umoddi3+0x130>
f0106f1e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106f22:	29 c8                	sub    %ecx,%eax
f0106f24:	19 d7                	sbb    %edx,%edi
f0106f26:	89 e9                	mov    %ebp,%ecx
f0106f28:	89 fa                	mov    %edi,%edx
f0106f2a:	d3 e8                	shr    %cl,%eax
f0106f2c:	89 f1                	mov    %esi,%ecx
f0106f2e:	d3 e2                	shl    %cl,%edx
f0106f30:	89 e9                	mov    %ebp,%ecx
f0106f32:	d3 ef                	shr    %cl,%edi
f0106f34:	09 d0                	or     %edx,%eax
f0106f36:	89 fa                	mov    %edi,%edx
f0106f38:	83 c4 14             	add    $0x14,%esp
f0106f3b:	5e                   	pop    %esi
f0106f3c:	5f                   	pop    %edi
f0106f3d:	5d                   	pop    %ebp
f0106f3e:	c3                   	ret    
f0106f3f:	90                   	nop
f0106f40:	39 d7                	cmp    %edx,%edi
f0106f42:	75 da                	jne    f0106f1e <__umoddi3+0x10e>
f0106f44:	8b 14 24             	mov    (%esp),%edx
f0106f47:	89 c1                	mov    %eax,%ecx
f0106f49:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f0106f4d:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0106f51:	eb cb                	jmp    f0106f1e <__umoddi3+0x10e>
f0106f53:	90                   	nop
f0106f54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106f58:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f0106f5c:	0f 82 0f ff ff ff    	jb     f0106e71 <__umoddi3+0x61>
f0106f62:	e9 1a ff ff ff       	jmp    f0106e81 <__umoddi3+0x71>
