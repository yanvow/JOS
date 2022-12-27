
obj/boot/boot.out:     file format elf32-i386


Disassembly of section .text:

00007c00 <start>:
.set CR0_PE_ON,      0x1         # protected mode enable flag

.globl start
start:
  .code16                     # Assemble for 16-bit mode
  cli                         # Disable interrupts
    7c00:	fa                   	cli    
  cld                         # String operations increment
    7c01:	fc                   	cld    

  # Set up the important data segment registers (DS, ES, SS).
  xorw    %ax,%ax             # Segment number zero
    7c02:	31 c0                	xor    %eax,%eax
  movw    %ax,%ds             # -> Data Segment
    7c04:	8e d8                	mov    %eax,%ds
  movw    %ax,%es             # -> Extra Segment
    7c06:	8e c0                	mov    %eax,%es
  movw    %ax,%ss             # -> Stack Segment
    7c08:	8e d0                	mov    %eax,%ss

00007c0a <seta20.1>:
  # Enable A20:
  #   For backwards compatibility with the earliest PCs, physical
  #   address line 20 is tied low, so that addresses higher than
  #   1MB wrap around to zero by default.  This code undoes this.
seta20.1:
  inb     $0x64,%al               # Wait for not busy
    7c0a:	e4 64                	in     $0x64,%al
  testb   $0x2,%al
    7c0c:	a8 02                	test   $0x2,%al
  jnz     seta20.1
    7c0e:	75 fa                	jne    7c0a <seta20.1>

  movb    $0xd1,%al               # 0xd1 -> port 0x64
    7c10:	b0 d1                	mov    $0xd1,%al
  outb    %al,$0x64
    7c12:	e6 64                	out    %al,$0x64

00007c14 <seta20.2>:

seta20.2:
  inb     $0x64,%al               # Wait for not busy
    7c14:	e4 64                	in     $0x64,%al
  testb   $0x2,%al
    7c16:	a8 02                	test   $0x2,%al
  jnz     seta20.2
    7c18:	75 fa                	jne    7c14 <seta20.2>

  movb    $0xdf,%al               # 0xdf -> port 0x60
    7c1a:	b0 df                	mov    $0xdf,%al
  outb    %al,$0x60
    7c1c:	e6 60                	out    %al,$0x60

  # Switch from real to protected mode, using a bootstrap GDT
  # and segment translation that makes virtual addresses 
  # identical to their physical addresses, so that the 
  # effective memory map does not change during the switch.
  lgdt    gdtdesc
    7c1e:	0f 01 16             	lgdtl  (%esi)
    7c21:	64                   	fs
    7c22:	7c 0f                	jl     7c33 <protcseg+0x1>
  movl    %cr0, %eax
    7c24:	20 c0                	and    %al,%al
  orl     $CR0_PE_ON, %eax
    7c26:	66 83 c8 01          	or     $0x1,%ax
  movl    %eax, %cr0
    7c2a:	0f 22 c0             	mov    %eax,%cr0
  
  # Jump to next instruction, but in 32-bit code segment.
  # Switches processor into 32-bit mode.
  ljmp    $PROT_MODE_CSEG, $protcseg
    7c2d:	ea 32 7c 08 00 66 b8 	ljmp   $0xb866,$0x87c32

00007c32 <protcseg>:

  .code32                     # Assemble for 32-bit mode
protcseg:
  # Set up the protected-mode data segment registers
  movw    $PROT_MODE_DSEG, %ax    # Our data segment selector
    7c32:	66 b8 10 00          	mov    $0x10,%ax
  movw    %ax, %ds                # -> DS: Data Segment
    7c36:	8e d8                	mov    %eax,%ds
  movw    %ax, %es                # -> ES: Extra Segment
    7c38:	8e c0                	mov    %eax,%es
  movw    %ax, %fs                # -> FS
    7c3a:	8e e0                	mov    %eax,%fs
  movw    %ax, %gs                # -> GS
    7c3c:	8e e8                	mov    %eax,%gs
  movw    %ax, %ss                # -> SS: Stack Segment
    7c3e:	8e d0                	mov    %eax,%ss
  
  # Set up the stack pointer and call into C.
  movl    $start, %esp
    7c40:	bc 00 7c 00 00       	mov    $0x7c00,%esp
  call bootmain
    7c45:	e8 cc 00 00 00       	call   7d16 <bootmain>

00007c4a <spin>:

  # If bootmain returns (it shouldn't), loop.
spin:
  jmp spin
    7c4a:	eb fe                	jmp    7c4a <spin>

00007c4c <gdt>:
	...
    7c54:	ff                   	(bad)  
    7c55:	ff 00                	incl   (%eax)
    7c57:	00 00                	add    %al,(%eax)
    7c59:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
    7c60:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

00007c64 <gdtdesc>:
    7c64:	17                   	pop    %ss
    7c65:	00 4c 7c 00          	add    %cl,0x0(%esp,%edi,2)
	...

00007c6a <waitdisk>:
  }
}

void
waitdisk(void)
{
    7c6a:	55                   	push   %ebp
    7c6b:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
  uint8_t data;
  __asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
    7c6d:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7c72:	ec                   	in     (%dx),%al
  // Bit 4: DF, device fault
  // Bit 3: DRQ, device request
  // Bit 0: ERR, error

  // wait for disk reaady
  while ((inb(0x1F7) & 0xC0) != 0x40)
    7c73:	83 e0 c0             	and    $0xffffffc0,%eax
    7c76:	3c 40                	cmp    $0x40,%al
    7c78:	75 f8                	jne    7c72 <waitdisk+0x8>
    /* do nothing */;
}
    7c7a:	5d                   	pop    %ebp
    7c7b:	c3                   	ret    

00007c7c <readsect>:

void
readsect(void *dst, uint32_t offset)
{
    7c7c:	55                   	push   %ebp
    7c7d:	89 e5                	mov    %esp,%ebp
    7c7f:	57                   	push   %edi
    7c80:	53                   	push   %ebx
    7c81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  // wait for disk to be ready
  waitdisk();
    7c84:	e8 e1 ff ff ff       	call   7c6a <waitdisk>
}

static __inline void
outb(int port, uint8_t data)
{
  __asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
    7c89:	ba f2 01 00 00       	mov    $0x1f2,%edx
    7c8e:	b8 01 00 00 00       	mov    $0x1,%eax
    7c93:	ee                   	out    %al,(%dx)
    7c94:	b2 f3                	mov    $0xf3,%dl
    7c96:	89 d8                	mov    %ebx,%eax
    7c98:	ee                   	out    %al,(%dx)
    7c99:	0f b6 c7             	movzbl %bh,%eax
    7c9c:	b2 f4                	mov    $0xf4,%dl
    7c9e:	ee                   	out    %al,(%dx)

  // ref. "7.35 READ SECTOR(S)" in [ATA8-ACS]
  outb(0x1F2, 1);                     // sector count = 1
  outb(0x1F3, offset);                // LBA low : LBA28 [ 0: 7]
  outb(0x1F4, offset >> 8);           // LBA mid : LBA28 [ 8:15]
  outb(0x1F5, offset >> 16);          // LBA high: LBA28 [16:23]
    7c9f:	89 d8                	mov    %ebx,%eax
    7ca1:	c1 e8 10             	shr    $0x10,%eax
    7ca4:	b2 f5                	mov    $0xf5,%dl
    7ca6:	ee                   	out    %al,(%dx)
  //  Bit 7: obsolete in LBA, 1 in CHS
  //  Bit 6: mode, 1=LBA, 0=CHS
  //  Bit 5: obsolete in LBA, 1 in CHS
  //  Bit 4: dev, 0=master, 1=slave
  //  Bit 3-0: [24:27] in LSB, #head in CHS
  outb(0x1F6, (offset >> 24) | 0xE0); // Dev: LBA28 [24:27], LBA=1, master
    7ca7:	c1 eb 18             	shr    $0x18,%ebx
    7caa:	89 d8                	mov    %ebx,%eax
    7cac:	83 c8 e0             	or     $0xffffffe0,%eax
    7caf:	b2 f6                	mov    $0xf6,%dl
    7cb1:	ee                   	out    %al,(%dx)
    7cb2:	b2 f7                	mov    $0xf7,%dl
    7cb4:	b8 20 00 00 00       	mov    $0x20,%eax
    7cb9:	ee                   	out    %al,(%dx)
  outb(0x1F7, 0x20);                  // cmd 0x20 - read sectors

  // wait for disk to be ready
  waitdisk();
    7cba:	e8 ab ff ff ff       	call   7c6a <waitdisk>
}

static __inline void
insl(int port, void *addr, int cnt)
{
  __asm __volatile("cld\n\trepne\n\tinsl"                 :
    7cbf:	8b 7d 08             	mov    0x8(%ebp),%edi
    7cc2:	b9 80 00 00 00       	mov    $0x80,%ecx
    7cc7:	ba f0 01 00 00       	mov    $0x1f0,%edx
    7ccc:	fc                   	cld    
    7ccd:	f2 6d                	repnz insl (%dx),%es:(%edi)

  // read a sector from a data port
  insl(0x1F0, dst, SECTSIZE/4);
}
    7ccf:	5b                   	pop    %ebx
    7cd0:	5f                   	pop    %edi
    7cd1:	5d                   	pop    %ebp
    7cd2:	c3                   	ret    

00007cd3 <readseg>:

// Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
// Might copy more than asked
void
readseg(uint32_t pa, uint32_t count, uint32_t offset)
{
    7cd3:	55                   	push   %ebp
    7cd4:	89 e5                	mov    %esp,%ebp
    7cd6:	57                   	push   %edi
    7cd7:	56                   	push   %esi
    7cd8:	53                   	push   %ebx
    7cd9:	83 ec 08             	sub    $0x8,%esp
    7cdc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint32_t end_pa;

  end_pa = pa + count;
    7cdf:	89 df                	mov    %ebx,%edi
    7ce1:	03 7d 0c             	add    0xc(%ebp),%edi

  // round down to sector boundary
  pa &= ~(SECTSIZE - 1);
    7ce4:	81 e3 00 fe ff ff    	and    $0xfffffe00,%ebx

  // translate from bytes to sectors, and kernel starts at sector 1
  offset = (offset / SECTSIZE) + 1;
    7cea:	8b 75 10             	mov    0x10(%ebp),%esi
    7ced:	c1 ee 09             	shr    $0x9,%esi
    7cf0:	83 c6 01             	add    $0x1,%esi

  // If this is too slow, we could read lots of sectors at a time.
  // We'd write more to memory than asked, but it doesn't matter --
  // we load in increasing order.
  while (pa < end_pa) {
    7cf3:	eb 15                	jmp    7d0a <readseg+0x37>
    // Since we haven't enabled paging yet and we're using
    // an identity segment mapping (see boot.S), we can
    // use physical addresses directly.  This won't be the
    // case once JOS enables the MMU.
    readsect((uint8_t *)pa, offset);
    7cf5:	89 74 24 04          	mov    %esi,0x4(%esp)
    7cf9:	89 1c 24             	mov    %ebx,(%esp)
    7cfc:	e8 7b ff ff ff       	call   7c7c <readsect>
    pa += SECTSIZE;
    7d01:	81 c3 00 02 00 00    	add    $0x200,%ebx
    offset++;
    7d07:	83 c6 01             	add    $0x1,%esi
  offset = (offset / SECTSIZE) + 1;

  // If this is too slow, we could read lots of sectors at a time.
  // We'd write more to memory than asked, but it doesn't matter --
  // we load in increasing order.
  while (pa < end_pa) {
    7d0a:	39 fb                	cmp    %edi,%ebx
    7d0c:	72 e7                	jb     7cf5 <readseg+0x22>
    // case once JOS enables the MMU.
    readsect((uint8_t *)pa, offset);
    pa += SECTSIZE;
    offset++;
  }
}
    7d0e:	83 c4 08             	add    $0x8,%esp
    7d11:	5b                   	pop    %ebx
    7d12:	5e                   	pop    %esi
    7d13:	5f                   	pop    %edi
    7d14:	5d                   	pop    %ebp
    7d15:	c3                   	ret    

00007d16 <bootmain>:
void readsect(void *, uint32_t);
void readseg(uint32_t, uint32_t, uint32_t);

void
bootmain(void)
{
    7d16:	55                   	push   %ebp
    7d17:	89 e5                	mov    %esp,%ebp
    7d19:	56                   	push   %esi
    7d1a:	53                   	push   %ebx
    7d1b:	83 ec 10             	sub    $0x10,%esp
  struct Proghdr *ph, *eph;

  // read 1st page off disk
  readseg((uint32_t)ELFHDR, SECTSIZE*8, 0);
    7d1e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
    7d25:	00 
    7d26:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
    7d2d:	00 
    7d2e:	c7 04 24 00 00 01 00 	movl   $0x10000,(%esp)
    7d35:	e8 99 ff ff ff       	call   7cd3 <readseg>

  // is this a valid ELF?
  if (ELFHDR->e_magic != ELF_MAGIC)
    7d3a:	81 3d 00 00 01 00 7f 	cmpl   $0x464c457f,0x10000
    7d41:	45 4c 46 
    7d44:	75 40                	jne    7d86 <bootmain+0x70>
    goto bad;

  // load each program segment (ignores ph flags)
  ph = (struct Proghdr *)((uint8_t *)ELFHDR + ELFHDR->e_phoff);
    7d46:	a1 1c 00 01 00       	mov    0x1001c,%eax
    7d4b:	8d 98 00 00 01 00    	lea    0x10000(%eax),%ebx
  eph = ph + ELFHDR->e_phnum;
    7d51:	0f b7 05 2c 00 01 00 	movzwl 0x1002c,%eax
    7d58:	c1 e0 05             	shl    $0x5,%eax
    7d5b:	8d 34 03             	lea    (%ebx,%eax,1),%esi
  for (; ph < eph; ph++)
    7d5e:	eb 1c                	jmp    7d7c <bootmain+0x66>
    // p_pa is the load address of this segment (as well
    // as the physical address)
    readseg(ph->p_pa, ph->p_memsz, ph->p_offset);
    7d60:	8b 43 04             	mov    0x4(%ebx),%eax
    7d63:	89 44 24 08          	mov    %eax,0x8(%esp)
    7d67:	8b 43 14             	mov    0x14(%ebx),%eax
    7d6a:	89 44 24 04          	mov    %eax,0x4(%esp)
    7d6e:	8b 43 0c             	mov    0xc(%ebx),%eax
    7d71:	89 04 24             	mov    %eax,(%esp)
    7d74:	e8 5a ff ff ff       	call   7cd3 <readseg>
    goto bad;

  // load each program segment (ignores ph flags)
  ph = (struct Proghdr *)((uint8_t *)ELFHDR + ELFHDR->e_phoff);
  eph = ph + ELFHDR->e_phnum;
  for (; ph < eph; ph++)
    7d79:	83 c3 20             	add    $0x20,%ebx
    7d7c:	39 f3                	cmp    %esi,%ebx
    7d7e:	72 e0                	jb     7d60 <bootmain+0x4a>
    // as the physical address)
    readseg(ph->p_pa, ph->p_memsz, ph->p_offset);

  // call the entry point from the ELF header
  // note: does not return!
  ((void (*)(void))(ELFHDR->e_entry))();
    7d80:	ff 15 18 00 01 00    	call   *0x10018
}

static __inline void
outw(int port, uint16_t data)
{
  __asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
    7d86:	ba 00 8a 00 00       	mov    $0x8a00,%edx
    7d8b:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
    7d90:	66 ef                	out    %ax,(%dx)
    7d92:	b0 e0                	mov    $0xe0,%al
    7d94:	66 ef                	out    %ax,(%dx)
    7d96:	eb fe                	jmp    7d96 <bootmain+0x80>
