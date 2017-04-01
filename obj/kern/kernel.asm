
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
	# physical addresses [0, 4MB).  This 4MB region will be suffice
	# until we set up our real page table in mem_init in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 70 11 00       	mov    $0x117000,%eax
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
f0100034:	bc 00 70 11 f0       	mov    $0xf0117000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/kclock.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	57                   	push   %edi
f0100044:	56                   	push   %esi
f0100045:	53                   	push   %ebx
f0100046:	81 ec 2c 01 00 00    	sub    $0x12c,%esp
	extern char edata[], end[];
   	// Lab1 only
	char chnum1 = 0, chnum2 = 0, ntest[256] = {};
f010004c:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
f0100050:	c6 45 e6 00          	movb   $0x0,-0x1a(%ebp)
f0100054:	66 c7 85 e6 fe ff ff 	movw   $0x0,-0x11a(%ebp)
f010005b:	00 00 
f010005d:	8d bd e8 fe ff ff    	lea    -0x118(%ebp),%edi
f0100063:	bb fe 00 00 00       	mov    $0xfe,%ebx
f0100068:	89 d9                	mov    %ebx,%ecx
f010006a:	c1 e9 02             	shr    $0x2,%ecx
f010006d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100072:	f3 ab                	rep stos %eax,%es:(%edi)
f0100074:	f6 c3 02             	test   $0x2,%bl
f0100077:	74 08                	je     f0100081 <i386_init+0x41>
f0100079:	66 c7 07 00 00       	movw   $0x0,(%edi)
f010007e:	83 c7 02             	add    $0x2,%edi
f0100081:	83 e3 01             	and    $0x1,%ebx
f0100084:	85 db                	test   %ebx,%ebx
f0100086:	74 03                	je     f010008b <i386_init+0x4b>
f0100088:	c6 07 00             	movb   $0x0,(%edi)

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010008b:	b8 8c 99 11 f0       	mov    $0xf011998c,%eax
f0100090:	2d 00 93 11 f0       	sub    $0xf0119300,%eax
f0100095:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100099:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000a0:	00 
f01000a1:	c7 04 24 00 93 11 f0 	movl   $0xf0119300,(%esp)
f01000a8:	e8 47 43 00 00       	call   f01043f4 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000ad:	e8 57 05 00 00       	call   f0100609 <cons_init>

	cprintf("6828 decimal is %o octal!%n\n%n", 6828, &chnum1, &chnum2);
f01000b2:	8d 45 e6             	lea    -0x1a(%ebp),%eax
f01000b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01000b9:	8d 75 e7             	lea    -0x19(%ebp),%esi
f01000bc:	89 74 24 08          	mov    %esi,0x8(%esp)
f01000c0:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000c7:	00 
f01000c8:	c7 04 24 40 49 10 f0 	movl   $0xf0104940,(%esp)
f01000cf:	e8 29 32 00 00       	call   f01032fd <cprintf>
	cprintf("pading space in the right to number 22: %-8d.\n", 22);
f01000d4:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
f01000db:	00 
f01000dc:	c7 04 24 60 49 10 f0 	movl   $0xf0104960,(%esp)
f01000e3:	e8 15 32 00 00       	call   f01032fd <cprintf>
	cprintf("chnum1: %d chnum2: %d\n", chnum1, chnum2);
f01000e8:	0f be 45 e6          	movsbl -0x1a(%ebp),%eax
f01000ec:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000f0:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
f01000f4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000f8:	c7 04 24 8f 49 10 f0 	movl   $0xf010498f,(%esp)
f01000ff:	e8 f9 31 00 00       	call   f01032fd <cprintf>
	cprintf("%n", NULL);
f0100104:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010010b:	00 
f010010c:	c7 04 24 a8 49 10 f0 	movl   $0xf01049a8,(%esp)
f0100113:	e8 e5 31 00 00       	call   f01032fd <cprintf>
	memset(ntest, 0xd, sizeof(ntest) - 1);
f0100118:	c7 44 24 08 ff 00 00 	movl   $0xff,0x8(%esp)
f010011f:	00 
f0100120:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
f0100127:	00 
f0100128:	8d 9d e6 fe ff ff    	lea    -0x11a(%ebp),%ebx
f010012e:	89 1c 24             	mov    %ebx,(%esp)
f0100131:	e8 be 42 00 00       	call   f01043f4 <memset>
	cprintf("%s%n", ntest, &chnum1); 
f0100136:	89 74 24 08          	mov    %esi,0x8(%esp)
f010013a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010013e:	c7 04 24 a6 49 10 f0 	movl   $0xf01049a6,(%esp)
f0100145:	e8 b3 31 00 00       	call   f01032fd <cprintf>
	cprintf("chnum1: %d\n", chnum1);
f010014a:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
f010014e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100152:	c7 04 24 ab 49 10 f0 	movl   $0xf01049ab,(%esp)
f0100159:	e8 9f 31 00 00       	call   f01032fd <cprintf>
	cprintf("show me the sign: %+d, %+d\n", 1024, -1024);
f010015e:	c7 44 24 08 00 fc ff 	movl   $0xfffffc00,0x8(%esp)
f0100165:	ff 
f0100166:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f010016d:	00 
f010016e:	c7 04 24 b7 49 10 f0 	movl   $0xf01049b7,(%esp)
f0100175:	e8 83 31 00 00       	call   f01032fd <cprintf>


	// Lab 2 memory management initialization functions
	mem_init();
f010017a:	e8 cc 15 00 00       	call   f010174b <mem_init>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010017f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100186:	e8 dc 09 00 00       	call   f0100b67 <monitor>
f010018b:	eb f2                	jmp    f010017f <i386_init+0x13f>

f010018d <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010018d:	55                   	push   %ebp
f010018e:	89 e5                	mov    %esp,%ebp
f0100190:	56                   	push   %esi
f0100191:	53                   	push   %ebx
f0100192:	83 ec 10             	sub    $0x10,%esp
f0100195:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100198:	83 3d 00 93 11 f0 00 	cmpl   $0x0,0xf0119300
f010019f:	75 3d                	jne    f01001de <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01001a1:	89 35 00 93 11 f0    	mov    %esi,0xf0119300

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01001a7:	fa                   	cli    
f01001a8:	fc                   	cld    

	va_start(ap, fmt);
f01001a9:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
f01001af:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001b3:	8b 45 08             	mov    0x8(%ebp),%eax
f01001b6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01001ba:	c7 04 24 d3 49 10 f0 	movl   $0xf01049d3,(%esp)
f01001c1:	e8 37 31 00 00       	call   f01032fd <cprintf>
	vcprintf(fmt, ap);
f01001c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01001ca:	89 34 24             	mov    %esi,(%esp)
f01001cd:	e8 f8 30 00 00       	call   f01032ca <vcprintf>
	cprintf("\n");
f01001d2:	c7 04 24 09 5a 10 f0 	movl   $0xf0105a09,(%esp)
f01001d9:	e8 1f 31 00 00       	call   f01032fd <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01001de:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01001e5:	e8 7d 09 00 00       	call   f0100b67 <monitor>
f01001ea:	eb f2                	jmp    f01001de <_panic+0x51>

f01001ec <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01001ec:	55                   	push   %ebp
f01001ed:	89 e5                	mov    %esp,%ebp
f01001ef:	53                   	push   %ebx
f01001f0:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f01001f3:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01001f6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01001f9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001fd:	8b 45 08             	mov    0x8(%ebp),%eax
f0100200:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100204:	c7 04 24 eb 49 10 f0 	movl   $0xf01049eb,(%esp)
f010020b:	e8 ed 30 00 00       	call   f01032fd <cprintf>
	vcprintf(fmt, ap);
f0100210:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100214:	8b 45 10             	mov    0x10(%ebp),%eax
f0100217:	89 04 24             	mov    %eax,(%esp)
f010021a:	e8 ab 30 00 00       	call   f01032ca <vcprintf>
	cprintf("\n");
f010021f:	c7 04 24 09 5a 10 f0 	movl   $0xf0105a09,(%esp)
f0100226:	e8 d2 30 00 00       	call   f01032fd <cprintf>
	va_end(ap);
}
f010022b:	83 c4 14             	add    $0x14,%esp
f010022e:	5b                   	pop    %ebx
f010022f:	5d                   	pop    %ebp
f0100230:	c3                   	ret    
	...

f0100240 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100240:	55                   	push   %ebp
f0100241:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100243:	ba 84 00 00 00       	mov    $0x84,%edx
f0100248:	ec                   	in     (%dx),%al
f0100249:	ec                   	in     (%dx),%al
f010024a:	ec                   	in     (%dx),%al
f010024b:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f010024c:	5d                   	pop    %ebp
f010024d:	c3                   	ret    

f010024e <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010024e:	55                   	push   %ebp
f010024f:	89 e5                	mov    %esp,%ebp
f0100251:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100256:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100257:	a8 01                	test   $0x1,%al
f0100259:	74 08                	je     f0100263 <serial_proc_data+0x15>
f010025b:	b2 f8                	mov    $0xf8,%dl
f010025d:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010025e:	0f b6 c0             	movzbl %al,%eax
f0100261:	eb 05                	jmp    f0100268 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100263:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100268:	5d                   	pop    %ebp
f0100269:	c3                   	ret    

f010026a <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010026a:	55                   	push   %ebp
f010026b:	89 e5                	mov    %esp,%ebp
f010026d:	53                   	push   %ebx
f010026e:	83 ec 04             	sub    $0x4,%esp
f0100271:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100273:	eb 29                	jmp    f010029e <cons_intr+0x34>
		if (c == 0)
f0100275:	85 d2                	test   %edx,%edx
f0100277:	74 25                	je     f010029e <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f0100279:	a1 44 95 11 f0       	mov    0xf0119544,%eax
f010027e:	88 90 40 93 11 f0    	mov    %dl,-0xfee6cc0(%eax)
f0100284:	8d 50 01             	lea    0x1(%eax),%edx
		if (cons.wpos == CONSBUFSIZE)
f0100287:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f010028d:	0f 94 c0             	sete   %al
f0100290:	0f b6 c0             	movzbl %al,%eax
f0100293:	83 e8 01             	sub    $0x1,%eax
f0100296:	21 c2                	and    %eax,%edx
f0100298:	89 15 44 95 11 f0    	mov    %edx,0xf0119544
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010029e:	ff d3                	call   *%ebx
f01002a0:	89 c2                	mov    %eax,%edx
f01002a2:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002a5:	75 ce                	jne    f0100275 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002a7:	83 c4 04             	add    $0x4,%esp
f01002aa:	5b                   	pop    %ebx
f01002ab:	5d                   	pop    %ebp
f01002ac:	c3                   	ret    

f01002ad <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002ad:	55                   	push   %ebp
f01002ae:	89 e5                	mov    %esp,%ebp
f01002b0:	57                   	push   %edi
f01002b1:	56                   	push   %esi
f01002b2:	53                   	push   %ebx
f01002b3:	83 ec 2c             	sub    $0x2c,%esp
f01002b6:	89 c7                	mov    %eax,%edi
f01002b8:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002bd:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f01002be:	a8 20                	test   $0x20,%al
f01002c0:	75 1b                	jne    f01002dd <cons_putc+0x30>
f01002c2:	bb 00 32 00 00       	mov    $0x3200,%ebx
f01002c7:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f01002cc:	e8 6f ff ff ff       	call   f0100240 <delay>
f01002d1:	89 f2                	mov    %esi,%edx
f01002d3:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f01002d4:	a8 20                	test   $0x20,%al
f01002d6:	75 05                	jne    f01002dd <cons_putc+0x30>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002d8:	83 eb 01             	sub    $0x1,%ebx
f01002db:	75 ef                	jne    f01002cc <cons_putc+0x1f>
f01002dd:	89 fa                	mov    %edi,%edx
f01002df:	89 f8                	mov    %edi,%eax
f01002e1:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002e4:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002e9:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002ea:	b2 79                	mov    $0x79,%dl
f01002ec:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002ed:	84 c0                	test   %al,%al
f01002ef:	78 1b                	js     f010030c <cons_putc+0x5f>
f01002f1:	bb 00 32 00 00       	mov    $0x3200,%ebx
f01002f6:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f01002fb:	e8 40 ff ff ff       	call   f0100240 <delay>
f0100300:	89 f2                	mov    %esi,%edx
f0100302:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100303:	84 c0                	test   %al,%al
f0100305:	78 05                	js     f010030c <cons_putc+0x5f>
f0100307:	83 eb 01             	sub    $0x1,%ebx
f010030a:	75 ef                	jne    f01002fb <cons_putc+0x4e>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010030c:	ba 78 03 00 00       	mov    $0x378,%edx
f0100311:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100315:	ee                   	out    %al,(%dx)
f0100316:	b2 7a                	mov    $0x7a,%dl
f0100318:	b8 0d 00 00 00       	mov    $0xd,%eax
f010031d:	ee                   	out    %al,(%dx)
f010031e:	b8 08 00 00 00       	mov    $0x8,%eax
f0100323:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100324:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f010032a:	75 06                	jne    f0100332 <cons_putc+0x85>
		c |= 0x0700;
f010032c:	81 cf 00 07 00 00    	or     $0x700,%edi

	switch (c & 0xff) {
f0100332:	89 f8                	mov    %edi,%eax
f0100334:	25 ff 00 00 00       	and    $0xff,%eax
f0100339:	83 f8 09             	cmp    $0x9,%eax
f010033c:	74 7b                	je     f01003b9 <cons_putc+0x10c>
f010033e:	83 f8 09             	cmp    $0x9,%eax
f0100341:	7f 0f                	jg     f0100352 <cons_putc+0xa5>
f0100343:	83 f8 08             	cmp    $0x8,%eax
f0100346:	0f 85 a1 00 00 00    	jne    f01003ed <cons_putc+0x140>
f010034c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100350:	eb 10                	jmp    f0100362 <cons_putc+0xb5>
f0100352:	83 f8 0a             	cmp    $0xa,%eax
f0100355:	74 3c                	je     f0100393 <cons_putc+0xe6>
f0100357:	83 f8 0d             	cmp    $0xd,%eax
f010035a:	0f 85 8d 00 00 00    	jne    f01003ed <cons_putc+0x140>
f0100360:	eb 39                	jmp    f010039b <cons_putc+0xee>
	case '\b':
		if (crt_pos > 0) {
f0100362:	0f b7 05 54 95 11 f0 	movzwl 0xf0119554,%eax
f0100369:	66 85 c0             	test   %ax,%ax
f010036c:	0f 84 e5 00 00 00    	je     f0100457 <cons_putc+0x1aa>
			crt_pos--;
f0100372:	83 e8 01             	sub    $0x1,%eax
f0100375:	66 a3 54 95 11 f0    	mov    %ax,0xf0119554
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010037b:	0f b7 c0             	movzwl %ax,%eax
f010037e:	81 e7 00 ff ff ff    	and    $0xffffff00,%edi
f0100384:	83 cf 20             	or     $0x20,%edi
f0100387:	8b 15 50 95 11 f0    	mov    0xf0119550,%edx
f010038d:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100391:	eb 77                	jmp    f010040a <cons_putc+0x15d>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100393:	66 83 05 54 95 11 f0 	addw   $0x50,0xf0119554
f010039a:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010039b:	0f b7 05 54 95 11 f0 	movzwl 0xf0119554,%eax
f01003a2:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003a8:	c1 e8 16             	shr    $0x16,%eax
f01003ab:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003ae:	c1 e0 04             	shl    $0x4,%eax
f01003b1:	66 a3 54 95 11 f0    	mov    %ax,0xf0119554
f01003b7:	eb 51                	jmp    f010040a <cons_putc+0x15d>
		break;
	case '\t':
		cons_putc(' ');
f01003b9:	b8 20 00 00 00       	mov    $0x20,%eax
f01003be:	e8 ea fe ff ff       	call   f01002ad <cons_putc>
		cons_putc(' ');
f01003c3:	b8 20 00 00 00       	mov    $0x20,%eax
f01003c8:	e8 e0 fe ff ff       	call   f01002ad <cons_putc>
		cons_putc(' ');
f01003cd:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d2:	e8 d6 fe ff ff       	call   f01002ad <cons_putc>
		cons_putc(' ');
f01003d7:	b8 20 00 00 00       	mov    $0x20,%eax
f01003dc:	e8 cc fe ff ff       	call   f01002ad <cons_putc>
		cons_putc(' ');
f01003e1:	b8 20 00 00 00       	mov    $0x20,%eax
f01003e6:	e8 c2 fe ff ff       	call   f01002ad <cons_putc>
f01003eb:	eb 1d                	jmp    f010040a <cons_putc+0x15d>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003ed:	0f b7 05 54 95 11 f0 	movzwl 0xf0119554,%eax
f01003f4:	0f b7 c8             	movzwl %ax,%ecx
f01003f7:	8b 15 50 95 11 f0    	mov    0xf0119550,%edx
f01003fd:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f0100401:	83 c0 01             	add    $0x1,%eax
f0100404:	66 a3 54 95 11 f0    	mov    %ax,0xf0119554
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010040a:	66 81 3d 54 95 11 f0 	cmpw   $0x7cf,0xf0119554
f0100411:	cf 07 
f0100413:	76 42                	jbe    f0100457 <cons_putc+0x1aa>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100415:	a1 50 95 11 f0       	mov    0xf0119550,%eax
f010041a:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100421:	00 
f0100422:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100428:	89 54 24 04          	mov    %edx,0x4(%esp)
f010042c:	89 04 24             	mov    %eax,(%esp)
f010042f:	e8 1e 40 00 00       	call   f0104452 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100434:	8b 15 50 95 11 f0    	mov    0xf0119550,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010043a:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f010043f:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100445:	83 c0 01             	add    $0x1,%eax
f0100448:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f010044d:	75 f0                	jne    f010043f <cons_putc+0x192>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010044f:	66 83 2d 54 95 11 f0 	subw   $0x50,0xf0119554
f0100456:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100457:	8b 0d 4c 95 11 f0    	mov    0xf011954c,%ecx
f010045d:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100462:	89 ca                	mov    %ecx,%edx
f0100464:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100465:	0f b7 1d 54 95 11 f0 	movzwl 0xf0119554,%ebx
f010046c:	8d 71 01             	lea    0x1(%ecx),%esi
f010046f:	89 d8                	mov    %ebx,%eax
f0100471:	66 c1 e8 08          	shr    $0x8,%ax
f0100475:	89 f2                	mov    %esi,%edx
f0100477:	ee                   	out    %al,(%dx)
f0100478:	b8 0f 00 00 00       	mov    $0xf,%eax
f010047d:	89 ca                	mov    %ecx,%edx
f010047f:	ee                   	out    %al,(%dx)
f0100480:	89 d8                	mov    %ebx,%eax
f0100482:	89 f2                	mov    %esi,%edx
f0100484:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100485:	83 c4 2c             	add    $0x2c,%esp
f0100488:	5b                   	pop    %ebx
f0100489:	5e                   	pop    %esi
f010048a:	5f                   	pop    %edi
f010048b:	5d                   	pop    %ebp
f010048c:	c3                   	ret    

f010048d <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010048d:	55                   	push   %ebp
f010048e:	89 e5                	mov    %esp,%ebp
f0100490:	53                   	push   %ebx
f0100491:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100494:	ba 64 00 00 00       	mov    $0x64,%edx
f0100499:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f010049a:	a8 01                	test   $0x1,%al
f010049c:	0f 84 e4 00 00 00    	je     f0100586 <kbd_proc_data+0xf9>
f01004a2:	b2 60                	mov    $0x60,%dl
f01004a4:	ec                   	in     (%dx),%al
f01004a5:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01004a7:	3c e0                	cmp    $0xe0,%al
f01004a9:	75 11                	jne    f01004bc <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01004ab:	83 0d 48 95 11 f0 40 	orl    $0x40,0xf0119548
		return 0;
f01004b2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01004b7:	e9 cf 00 00 00       	jmp    f010058b <kbd_proc_data+0xfe>
	} else if (data & 0x80) {
f01004bc:	84 c0                	test   %al,%al
f01004be:	79 34                	jns    f01004f4 <kbd_proc_data+0x67>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01004c0:	8b 0d 48 95 11 f0    	mov    0xf0119548,%ecx
f01004c6:	f6 c1 40             	test   $0x40,%cl
f01004c9:	75 05                	jne    f01004d0 <kbd_proc_data+0x43>
f01004cb:	89 c2                	mov    %eax,%edx
f01004cd:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01004d0:	0f b6 d2             	movzbl %dl,%edx
f01004d3:	0f b6 82 40 4a 10 f0 	movzbl -0xfefb5c0(%edx),%eax
f01004da:	83 c8 40             	or     $0x40,%eax
f01004dd:	0f b6 c0             	movzbl %al,%eax
f01004e0:	f7 d0                	not    %eax
f01004e2:	21 c1                	and    %eax,%ecx
f01004e4:	89 0d 48 95 11 f0    	mov    %ecx,0xf0119548
		return 0;
f01004ea:	bb 00 00 00 00       	mov    $0x0,%ebx
f01004ef:	e9 97 00 00 00       	jmp    f010058b <kbd_proc_data+0xfe>
	} else if (shift & E0ESC) {
f01004f4:	8b 0d 48 95 11 f0    	mov    0xf0119548,%ecx
f01004fa:	f6 c1 40             	test   $0x40,%cl
f01004fd:	74 0e                	je     f010050d <kbd_proc_data+0x80>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01004ff:	89 c2                	mov    %eax,%edx
f0100501:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f0100504:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100507:	89 0d 48 95 11 f0    	mov    %ecx,0xf0119548
	}

	shift |= shiftcode[data];
f010050d:	0f b6 c2             	movzbl %dl,%eax
f0100510:	0f b6 90 40 4a 10 f0 	movzbl -0xfefb5c0(%eax),%edx
f0100517:	0b 15 48 95 11 f0    	or     0xf0119548,%edx
	shift ^= togglecode[data];
f010051d:	0f b6 88 40 4b 10 f0 	movzbl -0xfefb4c0(%eax),%ecx
f0100524:	31 ca                	xor    %ecx,%edx
f0100526:	89 15 48 95 11 f0    	mov    %edx,0xf0119548

	c = charcode[shift & (CTL | SHIFT)][data];
f010052c:	89 d1                	mov    %edx,%ecx
f010052e:	83 e1 03             	and    $0x3,%ecx
f0100531:	8b 0c 8d 40 4c 10 f0 	mov    -0xfefb3c0(,%ecx,4),%ecx
f0100538:	0f b6 04 01          	movzbl (%ecx,%eax,1),%eax
f010053c:	0f b6 d8             	movzbl %al,%ebx
	if (shift & CAPSLOCK) {
f010053f:	f6 c2 08             	test   $0x8,%dl
f0100542:	74 1a                	je     f010055e <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f0100544:	89 d8                	mov    %ebx,%eax
f0100546:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100549:	83 f9 19             	cmp    $0x19,%ecx
f010054c:	77 05                	ja     f0100553 <kbd_proc_data+0xc6>
			c += 'A' - 'a';
f010054e:	83 eb 20             	sub    $0x20,%ebx
f0100551:	eb 0b                	jmp    f010055e <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f0100553:	83 e8 41             	sub    $0x41,%eax
f0100556:	83 f8 19             	cmp    $0x19,%eax
f0100559:	77 03                	ja     f010055e <kbd_proc_data+0xd1>
			c += 'a' - 'A';
f010055b:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010055e:	f7 d2                	not    %edx
f0100560:	f6 c2 06             	test   $0x6,%dl
f0100563:	75 26                	jne    f010058b <kbd_proc_data+0xfe>
f0100565:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010056b:	75 1e                	jne    f010058b <kbd_proc_data+0xfe>
		cprintf("Rebooting!\n");
f010056d:	c7 04 24 05 4a 10 f0 	movl   $0xf0104a05,(%esp)
f0100574:	e8 84 2d 00 00       	call   f01032fd <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100579:	ba 92 00 00 00       	mov    $0x92,%edx
f010057e:	b8 03 00 00 00       	mov    $0x3,%eax
f0100583:	ee                   	out    %al,(%dx)
f0100584:	eb 05                	jmp    f010058b <kbd_proc_data+0xfe>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100586:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010058b:	89 d8                	mov    %ebx,%eax
f010058d:	83 c4 14             	add    $0x14,%esp
f0100590:	5b                   	pop    %ebx
f0100591:	5d                   	pop    %ebp
f0100592:	c3                   	ret    

f0100593 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100593:	83 3d 20 93 11 f0 00 	cmpl   $0x0,0xf0119320
f010059a:	74 11                	je     f01005ad <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010059c:	55                   	push   %ebp
f010059d:	89 e5                	mov    %esp,%ebp
f010059f:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005a2:	b8 4e 02 10 f0       	mov    $0xf010024e,%eax
f01005a7:	e8 be fc ff ff       	call   f010026a <cons_intr>
}
f01005ac:	c9                   	leave  
f01005ad:	f3 c3                	repz ret 

f01005af <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005af:	55                   	push   %ebp
f01005b0:	89 e5                	mov    %esp,%ebp
f01005b2:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005b5:	b8 8d 04 10 f0       	mov    $0xf010048d,%eax
f01005ba:	e8 ab fc ff ff       	call   f010026a <cons_intr>
}
f01005bf:	c9                   	leave  
f01005c0:	c3                   	ret    

f01005c1 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01005c1:	55                   	push   %ebp
f01005c2:	89 e5                	mov    %esp,%ebp
f01005c4:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01005c7:	e8 c7 ff ff ff       	call   f0100593 <serial_intr>
	kbd_intr();
f01005cc:	e8 de ff ff ff       	call   f01005af <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01005d1:	8b 15 40 95 11 f0    	mov    0xf0119540,%edx
f01005d7:	3b 15 44 95 11 f0    	cmp    0xf0119544,%edx
f01005dd:	74 23                	je     f0100602 <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f01005df:	0f b6 82 40 93 11 f0 	movzbl -0xfee6cc0(%edx),%eax
f01005e6:	83 c2 01             	add    $0x1,%edx
f01005e9:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01005ef:	0f 94 c1             	sete   %cl
f01005f2:	0f b6 c9             	movzbl %cl,%ecx
f01005f5:	83 e9 01             	sub    $0x1,%ecx
f01005f8:	21 ca                	and    %ecx,%edx
f01005fa:	89 15 40 95 11 f0    	mov    %edx,0xf0119540
f0100600:	eb 05                	jmp    f0100607 <cons_getc+0x46>
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f0100602:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100607:	c9                   	leave  
f0100608:	c3                   	ret    

f0100609 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100609:	55                   	push   %ebp
f010060a:	89 e5                	mov    %esp,%ebp
f010060c:	57                   	push   %edi
f010060d:	56                   	push   %esi
f010060e:	53                   	push   %ebx
f010060f:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100612:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100619:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100620:	5a a5 
	if (*cp != 0xA55A) {
f0100622:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100629:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010062d:	74 11                	je     f0100640 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010062f:	c7 05 4c 95 11 f0 b4 	movl   $0x3b4,0xf011954c
f0100636:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100639:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f010063e:	eb 16                	jmp    f0100656 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100640:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100647:	c7 05 4c 95 11 f0 d4 	movl   $0x3d4,0xf011954c
f010064e:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100651:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
		*cp = was;
		addr_6845 = CGA_BASE;
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f0100656:	8b 0d 4c 95 11 f0    	mov    0xf011954c,%ecx
f010065c:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100661:	89 ca                	mov    %ecx,%edx
f0100663:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100664:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100667:	89 da                	mov    %ebx,%edx
f0100669:	ec                   	in     (%dx),%al
f010066a:	0f b6 f0             	movzbl %al,%esi
f010066d:	c1 e6 08             	shl    $0x8,%esi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100670:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100675:	89 ca                	mov    %ecx,%edx
f0100677:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100678:	89 da                	mov    %ebx,%edx
f010067a:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010067b:	89 3d 50 95 11 f0    	mov    %edi,0xf0119550
	
	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100681:	0f b6 d8             	movzbl %al,%ebx
f0100684:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100686:	66 89 35 54 95 11 f0 	mov    %si,0xf0119554
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010068d:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100692:	b8 00 00 00 00       	mov    $0x0,%eax
f0100697:	89 f2                	mov    %esi,%edx
f0100699:	ee                   	out    %al,(%dx)
f010069a:	b2 fb                	mov    $0xfb,%dl
f010069c:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006a1:	ee                   	out    %al,(%dx)
f01006a2:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01006a7:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006ac:	89 da                	mov    %ebx,%edx
f01006ae:	ee                   	out    %al,(%dx)
f01006af:	b2 f9                	mov    $0xf9,%dl
f01006b1:	b8 00 00 00 00       	mov    $0x0,%eax
f01006b6:	ee                   	out    %al,(%dx)
f01006b7:	b2 fb                	mov    $0xfb,%dl
f01006b9:	b8 03 00 00 00       	mov    $0x3,%eax
f01006be:	ee                   	out    %al,(%dx)
f01006bf:	b2 fc                	mov    $0xfc,%dl
f01006c1:	b8 00 00 00 00       	mov    $0x0,%eax
f01006c6:	ee                   	out    %al,(%dx)
f01006c7:	b2 f9                	mov    $0xf9,%dl
f01006c9:	b8 01 00 00 00       	mov    $0x1,%eax
f01006ce:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006cf:	b2 fd                	mov    $0xfd,%dl
f01006d1:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006d2:	3c ff                	cmp    $0xff,%al
f01006d4:	0f 95 c1             	setne  %cl
f01006d7:	0f b6 c9             	movzbl %cl,%ecx
f01006da:	89 0d 20 93 11 f0    	mov    %ecx,0xf0119320
f01006e0:	89 f2                	mov    %esi,%edx
f01006e2:	ec                   	in     (%dx),%al
f01006e3:	89 da                	mov    %ebx,%edx
f01006e5:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006e6:	85 c9                	test   %ecx,%ecx
f01006e8:	75 0c                	jne    f01006f6 <cons_init+0xed>
		cprintf("Serial port does not exist!\n");
f01006ea:	c7 04 24 11 4a 10 f0 	movl   $0xf0104a11,(%esp)
f01006f1:	e8 07 2c 00 00       	call   f01032fd <cprintf>
}
f01006f6:	83 c4 1c             	add    $0x1c,%esp
f01006f9:	5b                   	pop    %ebx
f01006fa:	5e                   	pop    %esi
f01006fb:	5f                   	pop    %edi
f01006fc:	5d                   	pop    %ebp
f01006fd:	c3                   	ret    

f01006fe <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01006fe:	55                   	push   %ebp
f01006ff:	89 e5                	mov    %esp,%ebp
f0100701:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100704:	8b 45 08             	mov    0x8(%ebp),%eax
f0100707:	e8 a1 fb ff ff       	call   f01002ad <cons_putc>
}
f010070c:	c9                   	leave  
f010070d:	c3                   	ret    

f010070e <getchar>:

int
getchar(void)
{
f010070e:	55                   	push   %ebp
f010070f:	89 e5                	mov    %esp,%ebp
f0100711:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100714:	e8 a8 fe ff ff       	call   f01005c1 <cons_getc>
f0100719:	85 c0                	test   %eax,%eax
f010071b:	74 f7                	je     f0100714 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010071d:	c9                   	leave  
f010071e:	c3                   	ret    

f010071f <iscons>:

int
iscons(int fdnum)
{
f010071f:	55                   	push   %ebp
f0100720:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100722:	b8 01 00 00 00       	mov    $0x1,%eax
f0100727:	5d                   	pop    %ebp
f0100728:	c3                   	ret    
f0100729:	00 00                	add    %al,(%eax)
f010072b:	00 00                	add    %al,(%eax)
f010072d:	00 00                	add    %al,(%eax)
	...

f0100730 <do_overflow>:
    return pretaddr;
}

void
do_overflow(void)
{
f0100730:	55                   	push   %ebp
f0100731:	89 e5                	mov    %esp,%ebp
f0100733:	83 ec 18             	sub    $0x18,%esp
    cprintf("Overflow success\n");
f0100736:	c7 04 24 50 4c 10 f0 	movl   $0xf0104c50,(%esp)
f010073d:	e8 bb 2b 00 00       	call   f01032fd <cprintf>
}
f0100742:	c9                   	leave  
f0100743:	c3                   	ret    

f0100744 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100744:	55                   	push   %ebp
f0100745:	89 e5                	mov    %esp,%ebp
f0100747:	83 ec 18             	sub    $0x18,%esp
	extern char entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010074a:	c7 04 24 62 4c 10 f0 	movl   $0xf0104c62,(%esp)
f0100751:	e8 a7 2b 00 00       	call   f01032fd <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100756:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010075d:	00 
f010075e:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100765:	f0 
f0100766:	c7 04 24 c4 4d 10 f0 	movl   $0xf0104dc4,(%esp)
f010076d:	e8 8b 2b 00 00       	call   f01032fd <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100772:	c7 44 24 08 2d 49 10 	movl   $0x10492d,0x8(%esp)
f0100779:	00 
f010077a:	c7 44 24 04 2d 49 10 	movl   $0xf010492d,0x4(%esp)
f0100781:	f0 
f0100782:	c7 04 24 e8 4d 10 f0 	movl   $0xf0104de8,(%esp)
f0100789:	e8 6f 2b 00 00       	call   f01032fd <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010078e:	c7 44 24 08 00 93 11 	movl   $0x119300,0x8(%esp)
f0100795:	00 
f0100796:	c7 44 24 04 00 93 11 	movl   $0xf0119300,0x4(%esp)
f010079d:	f0 
f010079e:	c7 04 24 0c 4e 10 f0 	movl   $0xf0104e0c,(%esp)
f01007a5:	e8 53 2b 00 00       	call   f01032fd <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01007aa:	c7 44 24 08 8c 99 11 	movl   $0x11998c,0x8(%esp)
f01007b1:	00 
f01007b2:	c7 44 24 04 8c 99 11 	movl   $0xf011998c,0x4(%esp)
f01007b9:	f0 
f01007ba:	c7 04 24 30 4e 10 f0 	movl   $0xf0104e30,(%esp)
f01007c1:	e8 37 2b 00 00       	call   f01032fd <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		(end-entry+1023)/1024);
f01007c6:	b8 8b 9d 11 f0       	mov    $0xf0119d8b,%eax
f01007cb:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Special kernel symbols:\n");
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01007d0:	89 c2                	mov    %eax,%edx
f01007d2:	c1 fa 1f             	sar    $0x1f,%edx
f01007d5:	c1 ea 16             	shr    $0x16,%edx
f01007d8:	01 d0                	add    %edx,%eax
f01007da:	c1 f8 0a             	sar    $0xa,%eax
f01007dd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007e1:	c7 04 24 54 4e 10 f0 	movl   $0xf0104e54,(%esp)
f01007e8:	e8 10 2b 00 00       	call   f01032fd <cprintf>
		(end-entry+1023)/1024);
	return 0;
}
f01007ed:	b8 00 00 00 00       	mov    $0x0,%eax
f01007f2:	c9                   	leave  
f01007f3:	c3                   	ret    

f01007f4 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007f4:	55                   	push   %ebp
f01007f5:	89 e5                	mov    %esp,%ebp
f01007f7:	56                   	push   %esi
f01007f8:	53                   	push   %ebx
f01007f9:	83 ec 10             	sub    $0x10,%esp
f01007fc:	bb 24 50 10 f0       	mov    $0xf0105024,%ebx
unsigned read_eip();

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
f0100801:	be 6c 50 10 f0       	mov    $0xf010506c,%esi
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100806:	8b 03                	mov    (%ebx),%eax
f0100808:	89 44 24 08          	mov    %eax,0x8(%esp)
f010080c:	8b 43 fc             	mov    -0x4(%ebx),%eax
f010080f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100813:	c7 04 24 7b 4c 10 f0 	movl   $0xf0104c7b,(%esp)
f010081a:	e8 de 2a 00 00       	call   f01032fd <cprintf>
f010081f:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100822:	39 f3                	cmp    %esi,%ebx
f0100824:	75 e0                	jne    f0100806 <mon_help+0x12>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100826:	b8 00 00 00 00       	mov    $0x0,%eax
f010082b:	83 c4 10             	add    $0x10,%esp
f010082e:	5b                   	pop    %ebx
f010082f:	5e                   	pop    %esi
f0100830:	5d                   	pop    %ebp
f0100831:	c3                   	ret    

f0100832 <dumpmem>:
	else  *pte = *pte | perm;
	cprintf("Mapping Set Succeed");
	return 0;
}

int dumpmem(int argc, char **argv, struct Trapframe *tf) {
f0100832:	55                   	push   %ebp
f0100833:	89 e5                	mov    %esp,%ebp
f0100835:	57                   	push   %edi
f0100836:	56                   	push   %esi
f0100837:	53                   	push   %ebx
f0100838:	83 ec 2c             	sub    $0x2c,%esp
f010083b:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc == 1)
f010083e:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100842:	75 11                	jne    f0100855 <dumpmem+0x23>
	{
		cprintf("Usage: dumpmem [v|p] [BEGIN] [END]\n");
f0100844:	c7 04 24 80 4e 10 f0 	movl   $0xf0104e80,(%esp)
f010084b:	e8 ad 2a 00 00       	call   f01032fd <cprintf>
		return 0;
f0100850:	e9 fd 00 00 00       	jmp    f0100952 <dumpmem+0x120>
	}
	uint32_t begin=strtol(argv[2],0,0);
f0100855:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010085c:	00 
f010085d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100864:	00 
f0100865:	8b 46 08             	mov    0x8(%esi),%eax
f0100868:	89 04 24             	mov    %eax,(%esp)
f010086b:	e8 fb 3c 00 00       	call   f010456b <strtol>
f0100870:	89 c3                	mov    %eax,%ebx
	uint32_t end=strtol(argv[3],0,0);
f0100872:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100879:	00 
f010087a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100881:	00 
f0100882:	8b 46 0c             	mov    0xc(%esi),%eax
f0100885:	89 04 24             	mov    %eax,(%esp)
f0100888:	e8 de 3c 00 00       	call   f010456b <strtol>
	if(begin!=ROUNDUP(begin,4) || end!=ROUNDUP(end,4) || begin > end)
f010088d:	8d 53 03             	lea    0x3(%ebx),%edx
f0100890:	83 e2 fc             	and    $0xfffffffc,%edx
f0100893:	39 d3                	cmp    %edx,%ebx
f0100895:	75 10                	jne    f01008a7 <dumpmem+0x75>
	{
		cprintf("Usage: dumpmem [v|p] [BEGIN] [END]\n");
		return 0;
	}
	uint32_t begin=strtol(argv[2],0,0);
	uint32_t end=strtol(argv[3],0,0);
f0100897:	89 c7                	mov    %eax,%edi
	if(begin!=ROUNDUP(begin,4) || end!=ROUNDUP(end,4) || begin > end)
f0100899:	8d 50 03             	lea    0x3(%eax),%edx
f010089c:	83 e2 fc             	and    $0xfffffffc,%edx
f010089f:	39 d0                	cmp    %edx,%eax
f01008a1:	75 04                	jne    f01008a7 <dumpmem+0x75>
f01008a3:	39 c3                	cmp    %eax,%ebx
f01008a5:	76 11                	jbe    f01008b8 <dumpmem+0x86>
	{
		cprintf("dumpmem: Invalid address\n");
f01008a7:	c7 04 24 84 4c 10 f0 	movl   $0xf0104c84,(%esp)
f01008ae:	e8 4a 2a 00 00       	call   f01032fd <cprintf>
		return 0;
f01008b3:	e9 9a 00 00 00       	jmp    f0100952 <dumpmem+0x120>
	}
	if(argv[1][0]!='v' && argv[1][0]!='p')
f01008b8:	8b 56 04             	mov    0x4(%esi),%edx
f01008bb:	0f b6 12             	movzbl (%edx),%edx
f01008be:	80 fa 70             	cmp    $0x70,%dl
f01008c1:	74 13                	je     f01008d6 <dumpmem+0xa4>
f01008c3:	80 fa 76             	cmp    $0x76,%dl
f01008c6:	74 0e                	je     f01008d6 <dumpmem+0xa4>
	{
		cprintf("dumpmem: Invalid address type\n");
f01008c8:	c7 04 24 a4 4e 10 f0 	movl   $0xf0104ea4,(%esp)
f01008cf:	e8 29 2a 00 00       	call   f01032fd <cprintf>
		return 0;
f01008d4:	eb 7c                	jmp    f0100952 <dumpmem+0x120>
	}
	if(argv[1][0]=='p')
f01008d6:	80 fa 70             	cmp    $0x70,%dl
f01008d9:	75 0c                	jne    f01008e7 <dumpmem+0xb5>
	{
		begin+=KERNBASE;
f01008db:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
		end+=KERNBASE;
f01008e1:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
	}
	while(begin<end)
f01008e7:	39 df                	cmp    %ebx,%edi
f01008e9:	77 50                	ja     f010093b <dumpmem+0x109>
f01008eb:	eb 65                	jmp    f0100952 <dumpmem+0x120>
	{
		cprintf("0x%08x: ",begin);
f01008ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01008f1:	c7 04 24 9e 4c 10 f0 	movl   $0xf0104c9e,(%esp)
f01008f8:	e8 00 2a 00 00       	call   f01032fd <cprintf>
		int i;
		for(i=0;i<4 && begin<end;i++,begin+=4){
f01008fd:	be 00 00 00 00       	mov    $0x0,%esi
			cprintf("0x%08x ",*((uint32_t*)begin));
f0100902:	8b 03                	mov    (%ebx),%eax
f0100904:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100908:	c7 04 24 a7 4c 10 f0 	movl   $0xf0104ca7,(%esp)
f010090f:	e8 e9 29 00 00       	call   f01032fd <cprintf>
	}
	while(begin<end)
	{
		cprintf("0x%08x: ",begin);
		int i;
		for(i=0;i<4 && begin<end;i++,begin+=4){
f0100914:	83 c6 01             	add    $0x1,%esi
f0100917:	83 c3 04             	add    $0x4,%ebx
f010091a:	39 df                	cmp    %ebx,%edi
f010091c:	0f 97 45 e7          	seta   -0x19(%ebp)
f0100920:	76 05                	jbe    f0100927 <dumpmem+0xf5>
f0100922:	83 fe 03             	cmp    $0x3,%esi
f0100925:	7e db                	jle    f0100902 <dumpmem+0xd0>
			cprintf("0x%08x ",*((uint32_t*)begin));
		}
		cprintf("\n");
f0100927:	c7 04 24 09 5a 10 f0 	movl   $0xf0105a09,(%esp)
f010092e:	e8 ca 29 00 00       	call   f01032fd <cprintf>
	if(argv[1][0]=='p')
	{
		begin+=KERNBASE;
		end+=KERNBASE;
	}
	while(begin<end)
f0100933:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f0100937:	75 b4                	jne    f01008ed <dumpmem+0xbb>
f0100939:	eb 17                	jmp    f0100952 <dumpmem+0x120>
	{
		cprintf("0x%08x: ",begin);
f010093b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010093f:	c7 04 24 9e 4c 10 f0 	movl   $0xf0104c9e,(%esp)
f0100946:	e8 b2 29 00 00       	call   f01032fd <cprintf>
		int i;
		for(i=0;i<4 && begin<end;i++,begin+=4){
f010094b:	be 00 00 00 00       	mov    $0x0,%esi
f0100950:	eb b0                	jmp    f0100902 <dumpmem+0xd0>
			cprintf("0x%08x ",*((uint32_t*)begin));
		}
		cprintf("\n");
	}
	return 0;
}
f0100952:	b8 00 00 00 00       	mov    $0x0,%eax
f0100957:	83 c4 2c             	add    $0x2c,%esp
f010095a:	5b                   	pop    %ebx
f010095b:	5e                   	pop    %esi
f010095c:	5f                   	pop    %edi
f010095d:	5d                   	pop    %ebp
f010095e:	c3                   	ret    

f010095f <start_overflow>:
    cprintf("Overflow success\n");
}

void
start_overflow(void)
{
f010095f:	55                   	push   %ebp
f0100960:	89 e5                	mov    %esp,%ebp
f0100962:	57                   	push   %edi
f0100963:	56                   	push   %esi
f0100964:	53                   	push   %ebx
f0100965:	81 ec 2c 01 00 00    	sub    $0x12c,%esp

	// hint: You can use the read_pretaddr function to retrieve 
	//       the pointer to the function call return address;

	// Your code here.
        char str[256] = {};
f010096b:	8d bd e8 fe ff ff    	lea    -0x118(%ebp),%edi
f0100971:	b9 40 00 00 00       	mov    $0x40,%ecx
f0100976:	b8 00 00 00 00       	mov    $0x0,%eax
f010097b:	f3 ab                	rep stos %eax,%es:(%edi)
// Lab1 only
// read the pointer to the retaddr on the stack
static uint32_t
read_pretaddr() {
    uint32_t pretaddr;
    __asm __volatile("leal 4(%%ebp), %0" : "=r" (pretaddr)); 
f010097d:	8d 5d 04             	lea    0x4(%ebp),%ebx

	// Your code here.
        char str[256] = {};
        int nstr = 0;
        char *pret_addr=(char*)read_pretaddr();
	unsigned int ret_addr=*(unsigned int*)pret_addr;
f0100980:	8b 03                	mov    (%ebx),%eax
f0100982:	89 85 d8 fe ff ff    	mov    %eax,-0x128(%ebp)
	memset(str,'a',256);
f0100988:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
f010098f:	00 
f0100990:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
f0100997:	00 
f0100998:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
f010099e:	89 34 24             	mov    %esi,(%esp)
f01009a1:	e8 4e 3a 00 00       	call   f01043f4 <memset>
	uint32_t hack_address = (uint32_t)do_overflow+3;
f01009a6:	bf 33 07 10 f0       	mov    $0xf0100733,%edi
	uint32_t a0 = hack_address & 0xff;
f01009ab:	89 f8                	mov    %edi,%eax
f01009ad:	25 ff 00 00 00       	and    $0xff,%eax
f01009b2:	89 85 e4 fe ff ff    	mov    %eax,-0x11c(%ebp)
	uint32_t a1 = (hack_address >> 8) & 0xff;
f01009b8:	89 f8                	mov    %edi,%eax
f01009ba:	0f b6 c4             	movzbl %ah,%eax
f01009bd:	89 85 e0 fe ff ff    	mov    %eax,-0x120(%ebp)
	uint32_t a2 = (hack_address >> 16) & 0xff;
f01009c3:	89 f8                	mov    %edi,%eax
f01009c5:	c1 e8 10             	shr    $0x10,%eax
f01009c8:	25 ff 00 00 00       	and    $0xff,%eax
f01009cd:	89 85 dc fe ff ff    	mov    %eax,-0x124(%ebp)
	uint32_t a3 = (hack_address >> 24) & 0xff;
	str[a0] = '\0';
f01009d3:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
f01009d9:	c6 84 05 e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%eax,1)
f01009e0:	00 
	cprintf("%s%n", str, pret_addr);
f01009e1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01009e5:	89 74 24 04          	mov    %esi,0x4(%esp)
f01009e9:	c7 04 24 a6 49 10 f0 	movl   $0xf01049a6,(%esp)
f01009f0:	e8 08 29 00 00       	call   f01032fd <cprintf>
	str[a0] = 'a';
f01009f5:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
f01009fb:	c6 84 05 e8 fe ff ff 	movb   $0x61,-0x118(%ebp,%eax,1)
f0100a02:	61 
	str[a1] = '\0';
f0100a03:	8b 85 e0 fe ff ff    	mov    -0x120(%ebp),%eax
f0100a09:	c6 84 05 e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%eax,1)
f0100a10:	00 
	cprintf("%s%n", str, pret_addr+1);
f0100a11:	8d 43 01             	lea    0x1(%ebx),%eax
f0100a14:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a18:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a1c:	c7 04 24 a6 49 10 f0 	movl   $0xf01049a6,(%esp)
f0100a23:	e8 d5 28 00 00       	call   f01032fd <cprintf>
	str[a1] = 'a';
f0100a28:	8b 85 e0 fe ff ff    	mov    -0x120(%ebp),%eax
f0100a2e:	c6 84 05 e8 fe ff ff 	movb   $0x61,-0x118(%ebp,%eax,1)
f0100a35:	61 
	str[a2] = '\0';
f0100a36:	8b 85 dc fe ff ff    	mov    -0x124(%ebp),%eax
f0100a3c:	c6 84 05 e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%eax,1)
f0100a43:	00 
	cprintf("%s%n", str, pret_addr+2);
f0100a44:	8d 43 02             	lea    0x2(%ebx),%eax
f0100a47:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a4b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a4f:	c7 04 24 a6 49 10 f0 	movl   $0xf01049a6,(%esp)
f0100a56:	e8 a2 28 00 00       	call   f01032fd <cprintf>
	str[a2] = 'a';
f0100a5b:	8b 85 dc fe ff ff    	mov    -0x124(%ebp),%eax
f0100a61:	c6 84 05 e8 fe ff ff 	movb   $0x61,-0x118(%ebp,%eax,1)
f0100a68:	61 
	memset(str,'a',256);
	uint32_t hack_address = (uint32_t)do_overflow+3;
	uint32_t a0 = hack_address & 0xff;
	uint32_t a1 = (hack_address >> 8) & 0xff;
	uint32_t a2 = (hack_address >> 16) & 0xff;
	uint32_t a3 = (hack_address >> 24) & 0xff;
f0100a69:	c1 ef 18             	shr    $0x18,%edi
	cprintf("%s%n", str, pret_addr+1);
	str[a1] = 'a';
	str[a2] = '\0';
	cprintf("%s%n", str, pret_addr+2);
	str[a2] = 'a';
	str[a3] = '\0';
f0100a6c:	c6 84 3d e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%edi,1)
f0100a73:	00 
	cprintf("%s%n", str, pret_addr+3);
f0100a74:	8d 43 03             	lea    0x3(%ebx),%eax
f0100a77:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a7b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a7f:	c7 04 24 a6 49 10 f0 	movl   $0xf01049a6,(%esp)
f0100a86:	e8 72 28 00 00       	call   f01032fd <cprintf>
	*(((unsigned int*)pret_addr)+1)=ret_addr;
f0100a8b:	8b 85 d8 fe ff ff    	mov    -0x128(%ebp),%eax
f0100a91:	89 43 04             	mov    %eax,0x4(%ebx)



}
f0100a94:	81 c4 2c 01 00 00    	add    $0x12c,%esp
f0100a9a:	5b                   	pop    %ebx
f0100a9b:	5e                   	pop    %esi
f0100a9c:	5f                   	pop    %edi
f0100a9d:	5d                   	pop    %ebp
f0100a9e:	c3                   	ret    

f0100a9f <overflow_me>:

void
overflow_me(void)
{
f0100a9f:	55                   	push   %ebp
f0100aa0:	89 e5                	mov    %esp,%ebp
f0100aa2:	83 ec 08             	sub    $0x8,%esp
        start_overflow();
f0100aa5:	e8 b5 fe ff ff       	call   f010095f <start_overflow>
}
f0100aaa:	c9                   	leave  
f0100aab:	c3                   	ret    

f0100aac <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100aac:	55                   	push   %ebp
f0100aad:	89 e5                	mov    %esp,%ebp
f0100aaf:	57                   	push   %edi
f0100ab0:	56                   	push   %esi
f0100ab1:	53                   	push   %ebx
f0100ab2:	83 ec 4c             	sub    $0x4c,%esp

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100ab5:	89 e8                	mov    %ebp,%eax
	// Your code here.
	unsigned int ebp=read_ebp();
	struct Eipdebuginfo info;
	while (ebp!=0)
f0100ab7:	85 c0                	test   %eax,%eax
f0100ab9:	0f 84 8a 00 00 00    	je     f0100b49 <mon_backtrace+0x9d>
f0100abf:	89 c3                	mov    %eax,%ebx
	{
		unsigned int* _ebp=(unsigned int*)ebp;
		cprintf("eip %08x ebp %08x args %08x %08x %08x %08x %08x\n",*(_ebp+1),ebp,*(_ebp+2),*(_ebp+3),*(_ebp+4),*(_ebp+5),*(_ebp+6));
		int re=debuginfo_eip(*(_ebp+1), &info);
f0100ac1:	8d 7d d0             	lea    -0x30(%ebp),%edi
	// Your code here.
	unsigned int ebp=read_ebp();
	struct Eipdebuginfo info;
	while (ebp!=0)
	{
		unsigned int* _ebp=(unsigned int*)ebp;
f0100ac4:	89 de                	mov    %ebx,%esi
		cprintf("eip %08x ebp %08x args %08x %08x %08x %08x %08x\n",*(_ebp+1),ebp,*(_ebp+2),*(_ebp+3),*(_ebp+4),*(_ebp+5),*(_ebp+6));
f0100ac6:	8b 43 18             	mov    0x18(%ebx),%eax
f0100ac9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0100acd:	8b 43 14             	mov    0x14(%ebx),%eax
f0100ad0:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100ad4:	8b 43 10             	mov    0x10(%ebx),%eax
f0100ad7:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100adb:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100ade:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100ae2:	8b 43 08             	mov    0x8(%ebx),%eax
f0100ae5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ae9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100aed:	8b 43 04             	mov    0x4(%ebx),%eax
f0100af0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100af4:	c7 04 24 c4 4e 10 f0 	movl   $0xf0104ec4,(%esp)
f0100afb:	e8 fd 27 00 00       	call   f01032fd <cprintf>
		int re=debuginfo_eip(*(_ebp+1), &info);
f0100b00:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100b04:	8b 43 04             	mov    0x4(%ebx),%eax
f0100b07:	89 04 24             	mov    %eax,(%esp)
f0100b0a:	e8 ee 28 00 00       	call   f01033fd <debuginfo_eip>
		if (re!=-1)
f0100b0f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100b12:	74 2b                	je     f0100b3f <mon_backtrace+0x93>
		{
			cprintf("%s:%d: %s+%d\n",info.eip_file,info.eip_line,info.eip_fn_name,*(_ebp+1)-info.eip_fn_addr);
f0100b14:	8b 43 04             	mov    0x4(%ebx),%eax
f0100b17:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100b1a:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100b1e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100b21:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100b25:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100b28:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100b2c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100b2f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b33:	c7 04 24 af 4c 10 f0 	movl   $0xf0104caf,(%esp)
f0100b3a:	e8 be 27 00 00       	call   f01032fd <cprintf>
		}
		ebp=*_ebp;
f0100b3f:	8b 1e                	mov    (%esi),%ebx
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	unsigned int ebp=read_ebp();
	struct Eipdebuginfo info;
	while (ebp!=0)
f0100b41:	85 db                	test   %ebx,%ebx
f0100b43:	0f 85 7b ff ff ff    	jne    f0100ac4 <mon_backtrace+0x18>
		{
			cprintf("%s:%d: %s+%d\n",info.eip_file,info.eip_line,info.eip_fn_name,*(_ebp+1)-info.eip_fn_addr);
		}
		ebp=*_ebp;
	}
    overflow_me();
f0100b49:	e8 51 ff ff ff       	call   f0100a9f <overflow_me>
    cprintf("Backtrace success\n");
f0100b4e:	c7 04 24 bd 4c 10 f0 	movl   $0xf0104cbd,(%esp)
f0100b55:	e8 a3 27 00 00       	call   f01032fd <cprintf>
	return 0;
}
f0100b5a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b5f:	83 c4 4c             	add    $0x4c,%esp
f0100b62:	5b                   	pop    %ebx
f0100b63:	5e                   	pop    %esi
f0100b64:	5f                   	pop    %edi
f0100b65:	5d                   	pop    %ebp
f0100b66:	c3                   	ret    

f0100b67 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100b67:	55                   	push   %ebp
f0100b68:	89 e5                	mov    %esp,%ebp
f0100b6a:	57                   	push   %edi
f0100b6b:	56                   	push   %esi
f0100b6c:	53                   	push   %ebx
f0100b6d:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100b70:	c7 04 24 f8 4e 10 f0 	movl   $0xf0104ef8,(%esp)
f0100b77:	e8 81 27 00 00       	call   f01032fd <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100b7c:	c7 04 24 1c 4f 10 f0 	movl   $0xf0104f1c,(%esp)
f0100b83:	e8 75 27 00 00       	call   f01032fd <cprintf>


	while (1) {
		buf = readline("K> ");
f0100b88:	c7 04 24 d0 4c 10 f0 	movl   $0xf0104cd0,(%esp)
f0100b8f:	e8 bc 35 00 00       	call   f0104150 <readline>
f0100b94:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f0100b96:	85 c0                	test   %eax,%eax
f0100b98:	74 ee                	je     f0100b88 <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100b9a:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100ba1:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100ba6:	eb 06                	jmp    f0100bae <monitor+0x47>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100ba8:	c6 06 00             	movb   $0x0,(%esi)
f0100bab:	83 c6 01             	add    $0x1,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100bae:	0f b6 06             	movzbl (%esi),%eax
f0100bb1:	84 c0                	test   %al,%al
f0100bb3:	74 6a                	je     f0100c1f <monitor+0xb8>
f0100bb5:	0f be c0             	movsbl %al,%eax
f0100bb8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100bbc:	c7 04 24 d4 4c 10 f0 	movl   $0xf0104cd4,(%esp)
f0100bc3:	e8 d2 37 00 00       	call   f010439a <strchr>
f0100bc8:	85 c0                	test   %eax,%eax
f0100bca:	75 dc                	jne    f0100ba8 <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
f0100bcc:	80 3e 00             	cmpb   $0x0,(%esi)
f0100bcf:	74 4e                	je     f0100c1f <monitor+0xb8>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100bd1:	83 fb 0f             	cmp    $0xf,%ebx
f0100bd4:	75 16                	jne    f0100bec <monitor+0x85>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100bd6:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100bdd:	00 
f0100bde:	c7 04 24 d9 4c 10 f0 	movl   $0xf0104cd9,(%esp)
f0100be5:	e8 13 27 00 00       	call   f01032fd <cprintf>
f0100bea:	eb 9c                	jmp    f0100b88 <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
f0100bec:	89 74 9d a8          	mov    %esi,-0x58(%ebp,%ebx,4)
f0100bf0:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100bf3:	0f b6 06             	movzbl (%esi),%eax
f0100bf6:	84 c0                	test   %al,%al
f0100bf8:	75 0c                	jne    f0100c06 <monitor+0x9f>
f0100bfa:	eb b2                	jmp    f0100bae <monitor+0x47>
			buf++;
f0100bfc:	83 c6 01             	add    $0x1,%esi
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100bff:	0f b6 06             	movzbl (%esi),%eax
f0100c02:	84 c0                	test   %al,%al
f0100c04:	74 a8                	je     f0100bae <monitor+0x47>
f0100c06:	0f be c0             	movsbl %al,%eax
f0100c09:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c0d:	c7 04 24 d4 4c 10 f0 	movl   $0xf0104cd4,(%esp)
f0100c14:	e8 81 37 00 00       	call   f010439a <strchr>
f0100c19:	85 c0                	test   %eax,%eax
f0100c1b:	74 df                	je     f0100bfc <monitor+0x95>
f0100c1d:	eb 8f                	jmp    f0100bae <monitor+0x47>
			buf++;
	}
	argv[argc] = 0;
f0100c1f:	c7 44 9d a8 00 00 00 	movl   $0x0,-0x58(%ebp,%ebx,4)
f0100c26:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100c27:	85 db                	test   %ebx,%ebx
f0100c29:	0f 84 59 ff ff ff    	je     f0100b88 <monitor+0x21>
f0100c2f:	bf 20 50 10 f0       	mov    $0xf0105020,%edi
f0100c34:	be 00 00 00 00       	mov    $0x0,%esi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100c39:	8b 07                	mov    (%edi),%eax
f0100c3b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c3f:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100c42:	89 04 24             	mov    %eax,(%esp)
f0100c45:	e8 cc 36 00 00       	call   f0104316 <strcmp>
f0100c4a:	85 c0                	test   %eax,%eax
f0100c4c:	75 24                	jne    f0100c72 <monitor+0x10b>
			return commands[i].func(argc, argv, tf);
f0100c4e:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100c51:	8b 55 08             	mov    0x8(%ebp),%edx
f0100c54:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100c58:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100c5b:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100c5f:	89 1c 24             	mov    %ebx,(%esp)
f0100c62:	ff 14 85 28 50 10 f0 	call   *-0xfefafd8(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100c69:	85 c0                	test   %eax,%eax
f0100c6b:	78 28                	js     f0100c95 <monitor+0x12e>
f0100c6d:	e9 16 ff ff ff       	jmp    f0100b88 <monitor+0x21>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100c72:	83 c6 01             	add    $0x1,%esi
f0100c75:	83 c7 0c             	add    $0xc,%edi
f0100c78:	83 fe 06             	cmp    $0x6,%esi
f0100c7b:	75 bc                	jne    f0100c39 <monitor+0xd2>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100c7d:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100c80:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c84:	c7 04 24 f6 4c 10 f0 	movl   $0xf0104cf6,(%esp)
f0100c8b:	e8 6d 26 00 00       	call   f01032fd <cprintf>
f0100c90:	e9 f3 fe ff ff       	jmp    f0100b88 <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100c95:	83 c4 5c             	add    $0x5c,%esp
f0100c98:	5b                   	pop    %ebx
f0100c99:	5e                   	pop    %esi
f0100c9a:	5f                   	pop    %edi
f0100c9b:	5d                   	pop    %ebp
f0100c9c:	c3                   	ret    

f0100c9d <xtoi>:

uint32_t xtoi(char* buf) {
f0100c9d:	55                   	push   %ebp
f0100c9e:	89 e5                	mov    %esp,%ebp
f0100ca0:	8b 45 08             	mov    0x8(%ebp),%eax
	uint32_t res = 0;
	buf += 2;
f0100ca3:	8d 50 02             	lea    0x2(%eax),%edx
	while (*buf) { 
f0100ca6:	0f b6 48 02          	movzbl 0x2(%eax),%ecx
f0100caa:	84 c9                	test   %cl,%cl
f0100cac:	74 25                	je     f0100cd3 <xtoi+0x36>
				break;
	}
}

uint32_t xtoi(char* buf) {
	uint32_t res = 0;
f0100cae:	b8 00 00 00 00       	mov    $0x0,%eax
	buf += 2;
	while (*buf) { 
		if (*buf >= 'a') *buf = *buf-'a'+'0'+10;
f0100cb3:	80 f9 60             	cmp    $0x60,%cl
f0100cb6:	7e 05                	jle    f0100cbd <xtoi+0x20>
f0100cb8:	83 e9 27             	sub    $0x27,%ecx
f0100cbb:	88 0a                	mov    %cl,(%edx)
		res = res*16 + *buf - '0';
f0100cbd:	c1 e0 04             	shl    $0x4,%eax
f0100cc0:	0f be 0a             	movsbl (%edx),%ecx
f0100cc3:	8d 44 08 d0          	lea    -0x30(%eax,%ecx,1),%eax
		++buf;
f0100cc7:	83 c2 01             	add    $0x1,%edx
}

uint32_t xtoi(char* buf) {
	uint32_t res = 0;
	buf += 2;
	while (*buf) { 
f0100cca:	0f b6 0a             	movzbl (%edx),%ecx
f0100ccd:	84 c9                	test   %cl,%cl
f0100ccf:	75 e2                	jne    f0100cb3 <xtoi+0x16>
f0100cd1:	eb 05                	jmp    f0100cd8 <xtoi+0x3b>
				break;
	}
}

uint32_t xtoi(char* buf) {
	uint32_t res = 0;
f0100cd3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*buf >= 'a') *buf = *buf-'a'+'0'+10;
		res = res*16 + *buf - '0';
		++buf;
	}
	return res;
}
f0100cd8:	5d                   	pop    %ebp
f0100cd9:	c3                   	ret    

f0100cda <setmapping>:
		} else cprintf("Page Not Exist: 0x%x\n", begin);
	}
	return 0;
}

int setmapping(int argc, char **argv, struct Trapframe *tf) {
f0100cda:	55                   	push   %ebp
f0100cdb:	89 e5                	mov    %esp,%ebp
f0100cdd:	53                   	push   %ebx
f0100cde:	83 ec 14             	sub    $0x14,%esp
f0100ce1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if (argc == 1) 
f0100ce4:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100ce8:	75 0e                	jne    f0100cf8 <setmapping+0x1e>
	{
		cprintf("Usage: setmapping [addr] [0|1] [P|U|W]\n");
f0100cea:	c7 04 24 44 4f 10 f0 	movl   $0xf0104f44,(%esp)
f0100cf1:	e8 07 26 00 00       	call   f01032fd <cprintf>
		return 0;
f0100cf6:	eb 60                	jmp    f0100d58 <setmapping+0x7e>
	}
	uint32_t addr = xtoi(argv[1]);
f0100cf8:	8b 43 04             	mov    0x4(%ebx),%eax
f0100cfb:	89 04 24             	mov    %eax,(%esp)
f0100cfe:	e8 9a ff ff ff       	call   f0100c9d <xtoi>
	pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 1);
f0100d03:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0100d0a:	00 
f0100d0b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d0f:	a1 84 99 11 f0       	mov    0xf0119984,%eax
f0100d14:	89 04 24             	mov    %eax,(%esp)
f0100d17:	e8 89 07 00 00       	call   f01014a5 <pgdir_walk>
	uint32_t perm = 0;

	if (argv[3][0] == 'P') perm = PTE_P;
f0100d1c:	8b 53 0c             	mov    0xc(%ebx),%edx
f0100d1f:	0f b6 0a             	movzbl (%edx),%ecx
	if (argv[3][0] == 'U') perm = PTE_U;
f0100d22:	ba 04 00 00 00       	mov    $0x4,%edx
f0100d27:	80 f9 55             	cmp    $0x55,%cl
f0100d2a:	74 10                	je     f0100d3c <setmapping+0x62>
	if (argv[3][0] == 'W') perm = PTE_W;
f0100d2c:	b2 02                	mov    $0x2,%dl
f0100d2e:	80 f9 57             	cmp    $0x57,%cl
f0100d31:	74 09                	je     f0100d3c <setmapping+0x62>
	}
	uint32_t addr = xtoi(argv[1]);
	pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 1);
	uint32_t perm = 0;

	if (argv[3][0] == 'P') perm = PTE_P;
f0100d33:	80 f9 50             	cmp    $0x50,%cl
		cprintf("Usage: setmapping [addr] [0|1] [P|U|W]\n");
		return 0;
	}
	uint32_t addr = xtoi(argv[1]);
	pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 1);
	uint32_t perm = 0;
f0100d36:	0f 94 c2             	sete   %dl
f0100d39:	0f b6 d2             	movzbl %dl,%edx

	if (argv[3][0] == 'P') perm = PTE_P;
	if (argv[3][0] == 'U') perm = PTE_U;
	if (argv[3][0] == 'W') perm = PTE_W;

	if (argv[2][0] == '0') *pte = *pte & ~perm;
f0100d3c:	8b 4b 08             	mov    0x8(%ebx),%ecx
f0100d3f:	80 39 30             	cmpb   $0x30,(%ecx)
f0100d42:	75 06                	jne    f0100d4a <setmapping+0x70>
f0100d44:	f7 d2                	not    %edx
f0100d46:	21 10                	and    %edx,(%eax)
f0100d48:	eb 02                	jmp    f0100d4c <setmapping+0x72>
	else  *pte = *pte | perm;
f0100d4a:	09 10                	or     %edx,(%eax)
	cprintf("Mapping Set Succeed");
f0100d4c:	c7 04 24 0c 4d 10 f0 	movl   $0xf0104d0c,(%esp)
f0100d53:	e8 a5 25 00 00       	call   f01032fd <cprintf>
	return 0;
}
f0100d58:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d5d:	83 c4 14             	add    $0x14,%esp
f0100d60:	5b                   	pop    %ebx
f0100d61:	5d                   	pop    %ebp
f0100d62:	c3                   	ret    

f0100d63 <print_pte>:
		res = res*16 + *buf - '0';
		++buf;
	}
	return res;
}
void print_pte(pte_t *pte) {
f0100d63:	55                   	push   %ebp
f0100d64:	89 e5                	mov    %esp,%ebp
f0100d66:	83 ec 18             	sub    $0x18,%esp
	cprintf("PTE_P: %x, PTE_W: %x, PTE_U: %x\n", 
		*pte&PTE_P, *pte&PTE_W, *pte&PTE_U);
f0100d69:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d6c:	8b 00                	mov    (%eax),%eax
		++buf;
	}
	return res;
}
void print_pte(pte_t *pte) {
	cprintf("PTE_P: %x, PTE_W: %x, PTE_U: %x\n", 
f0100d6e:	89 c2                	mov    %eax,%edx
f0100d70:	83 e2 04             	and    $0x4,%edx
f0100d73:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100d77:	89 c2                	mov    %eax,%edx
f0100d79:	83 e2 02             	and    $0x2,%edx
f0100d7c:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100d80:	83 e0 01             	and    $0x1,%eax
f0100d83:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d87:	c7 04 24 6c 4f 10 f0 	movl   $0xf0104f6c,(%esp)
f0100d8e:	e8 6a 25 00 00       	call   f01032fd <cprintf>
		*pte&PTE_P, *pte&PTE_W, *pte&PTE_U);
}
f0100d93:	c9                   	leave  
f0100d94:	c3                   	ret    

f0100d95 <showmappings>:
int
showmappings(int argc, char **argv, struct Trapframe *tf)
{
f0100d95:	55                   	push   %ebp
f0100d96:	89 e5                	mov    %esp,%ebp
f0100d98:	57                   	push   %edi
f0100d99:	56                   	push   %esi
f0100d9a:	53                   	push   %ebx
f0100d9b:	83 ec 1c             	sub    $0x1c,%esp
f0100d9e:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc == 1) 
f0100da1:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100da5:	75 11                	jne    f0100db8 <showmappings+0x23>
	{
		cprintf("Usage: showmappings [begin] [end]\n");
f0100da7:	c7 04 24 90 4f 10 f0 	movl   $0xf0104f90,(%esp)
f0100dae:	e8 4a 25 00 00       	call   f01032fd <cprintf>
		return 0;
f0100db3:	e9 a6 00 00 00       	jmp    f0100e5e <showmappings+0xc9>
	}
	uint32_t begin = xtoi(argv[1]), end = xtoi(argv[2]);
f0100db8:	8b 46 04             	mov    0x4(%esi),%eax
f0100dbb:	89 04 24             	mov    %eax,(%esp)
f0100dbe:	e8 da fe ff ff       	call   f0100c9d <xtoi>
f0100dc3:	89 c3                	mov    %eax,%ebx
f0100dc5:	8b 46 08             	mov    0x8(%esi),%eax
f0100dc8:	89 04 24             	mov    %eax,(%esp)
f0100dcb:	e8 cd fe ff ff       	call   f0100c9d <xtoi>
f0100dd0:	89 c7                	mov    %eax,%edi
	cprintf("Mapping begin: 0x%x, end: 0x%x\n", begin, end);
f0100dd2:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100dd6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100dda:	c7 04 24 b4 4f 10 f0 	movl   $0xf0104fb4,(%esp)
f0100de1:	e8 17 25 00 00       	call   f01032fd <cprintf>
	for (; begin <= end; begin += PGSIZE) 
f0100de6:	39 fb                	cmp    %edi,%ebx
f0100de8:	77 74                	ja     f0100e5e <showmappings+0xc9>
	{
		pte_t *pte = pgdir_walk(kern_pgdir, (void *) begin, 1);
f0100dea:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0100df1:	00 
f0100df2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100df6:	a1 84 99 11 f0       	mov    0xf0119984,%eax
f0100dfb:	89 04 24             	mov    %eax,(%esp)
f0100dfe:	e8 a2 06 00 00       	call   f01014a5 <pgdir_walk>
f0100e03:	89 c6                	mov    %eax,%esi
		if (!pte) panic("show mapping error: out of memory");
f0100e05:	85 c0                	test   %eax,%eax
f0100e07:	75 1c                	jne    f0100e25 <showmappings+0x90>
f0100e09:	c7 44 24 08 d4 4f 10 	movl   $0xf0104fd4,0x8(%esp)
f0100e10:	f0 
f0100e11:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
f0100e18:	00 
f0100e19:	c7 04 24 20 4d 10 f0 	movl   $0xf0104d20,(%esp)
f0100e20:	e8 68 f3 ff ff       	call   f010018d <_panic>
		if (*pte & PTE_P) 
f0100e25:	f6 00 01             	testb  $0x1,(%eax)
f0100e28:	74 1a                	je     f0100e44 <showmappings+0xaf>
		{
			cprintf("Page 0x%x Info: ", begin);
f0100e2a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100e2e:	c7 04 24 2f 4d 10 f0 	movl   $0xf0104d2f,(%esp)
f0100e35:	e8 c3 24 00 00       	call   f01032fd <cprintf>
			print_pte(pte);
f0100e3a:	89 34 24             	mov    %esi,(%esp)
f0100e3d:	e8 21 ff ff ff       	call   f0100d63 <print_pte>
f0100e42:	eb 10                	jmp    f0100e54 <showmappings+0xbf>
		} else cprintf("Page Not Exist: 0x%x\n", begin);
f0100e44:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100e48:	c7 04 24 40 4d 10 f0 	movl   $0xf0104d40,(%esp)
f0100e4f:	e8 a9 24 00 00       	call   f01032fd <cprintf>
		cprintf("Usage: showmappings [begin] [end]\n");
		return 0;
	}
	uint32_t begin = xtoi(argv[1]), end = xtoi(argv[2]);
	cprintf("Mapping begin: 0x%x, end: 0x%x\n", begin, end);
	for (; begin <= end; begin += PGSIZE) 
f0100e54:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100e5a:	39 df                	cmp    %ebx,%edi
f0100e5c:	73 8c                	jae    f0100dea <showmappings+0x55>
			cprintf("Page 0x%x Info: ", begin);
			print_pte(pte);
		} else cprintf("Page Not Exist: 0x%x\n", begin);
	}
	return 0;
}
f0100e5e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e63:	83 c4 1c             	add    $0x1c,%esp
f0100e66:	5b                   	pop    %ebx
f0100e67:	5e                   	pop    %esi
f0100e68:	5f                   	pop    %edi
f0100e69:	5d                   	pop    %ebp
f0100e6a:	c3                   	ret    

f0100e6b <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f0100e6b:	55                   	push   %ebp
f0100e6c:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f0100e6e:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f0100e71:	5d                   	pop    %ebp
f0100e72:	c3                   	ret    
	...

f0100e80 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100e80:	55                   	push   %ebp
f0100e81:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100e83:	83 3d 5c 95 11 f0 00 	cmpl   $0x0,0xf011955c
f0100e8a:	75 11                	jne    f0100e9d <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100e8c:	ba 8b a9 11 f0       	mov    $0xf011a98b,%edx
f0100e91:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100e97:	89 15 5c 95 11 f0    	mov    %edx,0xf011955c
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if(n == 0) return nextfree;
f0100e9d:	8b 15 5c 95 11 f0    	mov    0xf011955c,%edx
f0100ea3:	85 c0                	test   %eax,%eax
f0100ea5:	74 17                	je     f0100ebe <boot_alloc+0x3e>
	result = nextfree;
f0100ea7:	8b 15 5c 95 11 f0    	mov    0xf011955c,%edx
	nextfree += (int)ROUNDUP((char*)n, PGSIZE);
f0100ead:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100eb2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100eb7:	01 d0                	add    %edx,%eax
f0100eb9:	a3 5c 95 11 f0       	mov    %eax,0xf011955c
	return result;
}
f0100ebe:	89 d0                	mov    %edx,%eax
f0100ec0:	5d                   	pop    %ebp
f0100ec1:	c3                   	ret    

f0100ec2 <check_va2pa_large>:
	return PTE_ADDR(p[PTX(va)]);
}

static physaddr_t
check_va2pa_large(pde_t *pgdir, uintptr_t va)
{
f0100ec2:	55                   	push   %ebp
f0100ec3:	89 e5                	mov    %esp,%ebp
	pgdir = &pgdir[PDX(va)];
f0100ec5:	c1 ea 16             	shr    $0x16,%edx
	if (!(*pgdir & PTE_P) | !(*pgdir & PTE_PS))
f0100ec8:	8b 04 90             	mov    (%eax,%edx,4),%eax
f0100ecb:	89 c1                	mov    %eax,%ecx
f0100ecd:	81 e1 81 00 00 00    	and    $0x81,%ecx
		return ~0;
	return PTE_ADDR(*pgdir);
f0100ed3:	89 c2                	mov    %eax,%edx
f0100ed5:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100edb:	81 f9 81 00 00 00    	cmp    $0x81,%ecx
f0100ee1:	0f 94 c0             	sete   %al
f0100ee4:	0f b6 c0             	movzbl %al,%eax
f0100ee7:	83 e8 01             	sub    $0x1,%eax
f0100eea:	09 d0                	or     %edx,%eax
}
f0100eec:	5d                   	pop    %ebp
f0100eed:	c3                   	ret    

f0100eee <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100eee:	89 d1                	mov    %edx,%ecx
f0100ef0:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100ef3:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100ef6:	a8 01                	test   $0x1,%al
f0100ef8:	74 5a                	je     f0100f54 <check_va2pa+0x66>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100efa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100eff:	89 c1                	mov    %eax,%ecx
f0100f01:	c1 e9 0c             	shr    $0xc,%ecx
f0100f04:	3b 0d 80 99 11 f0    	cmp    0xf0119980,%ecx
f0100f0a:	72 26                	jb     f0100f32 <check_va2pa+0x44>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100f0c:	55                   	push   %ebp
f0100f0d:	89 e5                	mov    %esp,%ebp
f0100f0f:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f12:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f16:	c7 44 24 08 68 50 10 	movl   $0xf0105068,0x8(%esp)
f0100f1d:	f0 
f0100f1e:	c7 44 24 04 e9 02 00 	movl   $0x2e9,0x4(%esp)
f0100f25:	00 
f0100f26:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0100f2d:	e8 5b f2 ff ff       	call   f010018d <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100f32:	c1 ea 0c             	shr    $0xc,%edx
f0100f35:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100f3b:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100f42:	89 c2                	mov    %eax,%edx
f0100f44:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100f47:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f4c:	83 fa 01             	cmp    $0x1,%edx
f0100f4f:	19 d2                	sbb    %edx,%edx
f0100f51:	09 d0                	or     %edx,%eax
f0100f53:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100f54:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100f59:	c3                   	ret    

f0100f5a <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100f5a:	55                   	push   %ebp
f0100f5b:	89 e5                	mov    %esp,%ebp
f0100f5d:	83 ec 18             	sub    $0x18,%esp
f0100f60:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100f63:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100f66:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100f68:	89 04 24             	mov    %eax,(%esp)
f0100f6b:	e8 10 23 00 00       	call   f0103280 <mc146818_read>
f0100f70:	89 c6                	mov    %eax,%esi
f0100f72:	83 c3 01             	add    $0x1,%ebx
f0100f75:	89 1c 24             	mov    %ebx,(%esp)
f0100f78:	e8 03 23 00 00       	call   f0103280 <mc146818_read>
f0100f7d:	c1 e0 08             	shl    $0x8,%eax
f0100f80:	09 f0                	or     %esi,%eax
}
f0100f82:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100f85:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100f88:	89 ec                	mov    %ebp,%esp
f0100f8a:	5d                   	pop    %ebp
f0100f8b:	c3                   	ret    

f0100f8c <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100f8c:	55                   	push   %ebp
f0100f8d:	89 e5                	mov    %esp,%ebp
f0100f8f:	57                   	push   %edi
f0100f90:	56                   	push   %esi
f0100f91:	53                   	push   %ebx
f0100f92:	83 ec 3c             	sub    $0x3c,%esp
	struct Page *pp;
	int pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f95:	85 c0                	test   %eax,%eax
f0100f97:	0f 85 39 03 00 00    	jne    f01012d6 <check_page_free_list+0x34a>
f0100f9d:	e9 46 03 00 00       	jmp    f01012e8 <check_page_free_list+0x35c>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100fa2:	c7 44 24 08 8c 50 10 	movl   $0xf010508c,0x8(%esp)
f0100fa9:	f0 
f0100faa:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
f0100fb1:	00 
f0100fb2:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0100fb9:	e8 cf f1 ff ff       	call   f010018d <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
f0100fbe:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100fc1:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100fc4:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100fc7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0100fca:	89 c2                	mov    %eax,%edx
f0100fcc:	2b 15 88 99 11 f0    	sub    0xf0119988,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100fd2:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100fd8:	0f 95 c2             	setne  %dl
f0100fdb:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100fde:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100fe2:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100fe4:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100fe8:	8b 00                	mov    (%eax),%eax
f0100fea:	85 c0                	test   %eax,%eax
f0100fec:	75 dc                	jne    f0100fca <check_page_free_list+0x3e>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100fee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ff1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100ff7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ffa:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100ffd:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100fff:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101002:	a3 60 95 11 f0       	mov    %eax,0xf0119560
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0101007:	89 c3                	mov    %eax,%ebx
f0101009:	85 c0                	test   %eax,%eax
f010100b:	74 6c                	je     f0101079 <check_page_free_list+0xed>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct Page *pp;
	int pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010100d:	be 01 00 00 00       	mov    $0x1,%esi
f0101012:	89 d8                	mov    %ebx,%eax
f0101014:	2b 05 88 99 11 f0    	sub    0xf0119988,%eax
f010101a:	c1 f8 03             	sar    $0x3,%eax
f010101d:	c1 e0 0c             	shl    $0xc,%eax
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
		if (PDX(page2pa(pp)) < pdx_limit)
f0101020:	89 c2                	mov    %eax,%edx
f0101022:	c1 ea 16             	shr    $0x16,%edx
f0101025:	39 f2                	cmp    %esi,%edx
f0101027:	73 4a                	jae    f0101073 <check_page_free_list+0xe7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101029:	89 c2                	mov    %eax,%edx
f010102b:	c1 ea 0c             	shr    $0xc,%edx
f010102e:	3b 15 80 99 11 f0    	cmp    0xf0119980,%edx
f0101034:	72 20                	jb     f0101056 <check_page_free_list+0xca>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101036:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010103a:	c7 44 24 08 68 50 10 	movl   $0xf0105068,0x8(%esp)
f0101041:	f0 
f0101042:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0101049:	00 
f010104a:	c7 04 24 85 57 10 f0 	movl   $0xf0105785,(%esp)
f0101051:	e8 37 f1 ff ff       	call   f010018d <_panic>
			memset(page2kva(pp), 0x97, 128);
f0101056:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f010105d:	00 
f010105e:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0101065:	00 
	return (void *)(pa + KERNBASE);
f0101066:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010106b:	89 04 24             	mov    %eax,(%esp)
f010106e:	e8 81 33 00 00       	call   f01043f4 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0101073:	8b 1b                	mov    (%ebx),%ebx
f0101075:	85 db                	test   %ebx,%ebx
f0101077:	75 99                	jne    f0101012 <check_page_free_list+0x86>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
f0101079:	b8 00 00 00 00       	mov    $0x0,%eax
f010107e:	e8 fd fd ff ff       	call   f0100e80 <boot_alloc>
f0101083:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101086:	8b 15 60 95 11 f0    	mov    0xf0119560,%edx
f010108c:	85 d2                	test   %edx,%edx
f010108e:	0f 84 f6 01 00 00    	je     f010128a <check_page_free_list+0x2fe>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101094:	8b 1d 88 99 11 f0    	mov    0xf0119988,%ebx
f010109a:	39 da                	cmp    %ebx,%edx
f010109c:	72 4d                	jb     f01010eb <check_page_free_list+0x15f>
		assert(pp < pages + npages);
f010109e:	a1 80 99 11 f0       	mov    0xf0119980,%eax
f01010a3:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01010a6:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f01010a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01010ac:	39 c2                	cmp    %eax,%edx
f01010ae:	73 64                	jae    f0101114 <check_page_free_list+0x188>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01010b0:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f01010b3:	89 d0                	mov    %edx,%eax
f01010b5:	29 d8                	sub    %ebx,%eax
f01010b7:	a8 07                	test   $0x7,%al
f01010b9:	0f 85 82 00 00 00    	jne    f0101141 <check_page_free_list+0x1b5>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01010bf:	c1 f8 03             	sar    $0x3,%eax
f01010c2:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01010c5:	85 c0                	test   %eax,%eax
f01010c7:	0f 84 a2 00 00 00    	je     f010116f <check_page_free_list+0x1e3>
		assert(page2pa(pp) != IOPHYSMEM);
f01010cd:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01010d2:	0f 84 c2 00 00 00    	je     f010119a <check_page_free_list+0x20e>
static void
check_page_free_list(bool only_low_memory)
{
	struct Page *pp;
	int pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f01010d8:	be 00 00 00 00       	mov    $0x0,%esi
f01010dd:	bf 00 00 00 00       	mov    $0x0,%edi
f01010e2:	e9 d7 00 00 00       	jmp    f01011be <check_page_free_list+0x232>
	}

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01010e7:	39 da                	cmp    %ebx,%edx
f01010e9:	73 24                	jae    f010110f <check_page_free_list+0x183>
f01010eb:	c7 44 24 0c 93 57 10 	movl   $0xf0105793,0xc(%esp)
f01010f2:	f0 
f01010f3:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f01010fa:	f0 
f01010fb:	c7 44 24 04 3f 02 00 	movl   $0x23f,0x4(%esp)
f0101102:	00 
f0101103:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f010110a:	e8 7e f0 ff ff       	call   f010018d <_panic>
		assert(pp < pages + npages);
f010110f:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0101112:	72 24                	jb     f0101138 <check_page_free_list+0x1ac>
f0101114:	c7 44 24 0c b4 57 10 	movl   $0xf01057b4,0xc(%esp)
f010111b:	f0 
f010111c:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0101123:	f0 
f0101124:	c7 44 24 04 40 02 00 	movl   $0x240,0x4(%esp)
f010112b:	00 
f010112c:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0101133:	e8 55 f0 ff ff       	call   f010018d <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101138:	89 d0                	mov    %edx,%eax
f010113a:	2b 45 d0             	sub    -0x30(%ebp),%eax
f010113d:	a8 07                	test   $0x7,%al
f010113f:	74 24                	je     f0101165 <check_page_free_list+0x1d9>
f0101141:	c7 44 24 0c b0 50 10 	movl   $0xf01050b0,0xc(%esp)
f0101148:	f0 
f0101149:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0101150:	f0 
f0101151:	c7 44 24 04 41 02 00 	movl   $0x241,0x4(%esp)
f0101158:	00 
f0101159:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0101160:	e8 28 f0 ff ff       	call   f010018d <_panic>
f0101165:	c1 f8 03             	sar    $0x3,%eax
f0101168:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f010116b:	85 c0                	test   %eax,%eax
f010116d:	75 24                	jne    f0101193 <check_page_free_list+0x207>
f010116f:	c7 44 24 0c c8 57 10 	movl   $0xf01057c8,0xc(%esp)
f0101176:	f0 
f0101177:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f010117e:	f0 
f010117f:	c7 44 24 04 44 02 00 	movl   $0x244,0x4(%esp)
f0101186:	00 
f0101187:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f010118e:	e8 fa ef ff ff       	call   f010018d <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101193:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101198:	75 24                	jne    f01011be <check_page_free_list+0x232>
f010119a:	c7 44 24 0c d9 57 10 	movl   $0xf01057d9,0xc(%esp)
f01011a1:	f0 
f01011a2:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f01011a9:	f0 
f01011aa:	c7 44 24 04 45 02 00 	movl   $0x245,0x4(%esp)
f01011b1:	00 
f01011b2:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f01011b9:	e8 cf ef ff ff       	call   f010018d <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01011be:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f01011c3:	75 24                	jne    f01011e9 <check_page_free_list+0x25d>
f01011c5:	c7 44 24 0c e4 50 10 	movl   $0xf01050e4,0xc(%esp)
f01011cc:	f0 
f01011cd:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f01011d4:	f0 
f01011d5:	c7 44 24 04 46 02 00 	movl   $0x246,0x4(%esp)
f01011dc:	00 
f01011dd:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f01011e4:	e8 a4 ef ff ff       	call   f010018d <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f01011e9:	3d 00 00 10 00       	cmp    $0x100000,%eax
f01011ee:	75 24                	jne    f0101214 <check_page_free_list+0x288>
f01011f0:	c7 44 24 0c f2 57 10 	movl   $0xf01057f2,0xc(%esp)
f01011f7:	f0 
f01011f8:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f01011ff:	f0 
f0101200:	c7 44 24 04 47 02 00 	movl   $0x247,0x4(%esp)
f0101207:	00 
f0101208:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f010120f:	e8 79 ef ff ff       	call   f010018d <_panic>
f0101214:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101216:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f010121b:	76 57                	jbe    f0101274 <check_page_free_list+0x2e8>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010121d:	c1 e8 0c             	shr    $0xc,%eax
f0101220:	3b 45 cc             	cmp    -0x34(%ebp),%eax
f0101223:	72 20                	jb     f0101245 <check_page_free_list+0x2b9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101225:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0101229:	c7 44 24 08 68 50 10 	movl   $0xf0105068,0x8(%esp)
f0101230:	f0 
f0101231:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0101238:	00 
f0101239:	c7 04 24 85 57 10 f0 	movl   $0xf0105785,(%esp)
f0101240:	e8 48 ef ff ff       	call   f010018d <_panic>
	return (void *)(pa + KERNBASE);
f0101245:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f010124b:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f010124e:	76 29                	jbe    f0101279 <check_page_free_list+0x2ed>
f0101250:	c7 44 24 0c 08 51 10 	movl   $0xf0105108,0xc(%esp)
f0101257:	f0 
f0101258:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f010125f:	f0 
f0101260:	c7 44 24 04 48 02 00 	movl   $0x248,0x4(%esp)
f0101267:	00 
f0101268:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f010126f:	e8 19 ef ff ff       	call   f010018d <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0101274:	83 c7 01             	add    $0x1,%edi
f0101277:	eb 03                	jmp    f010127c <check_page_free_list+0x2f0>
		else
			++nfree_extmem;
f0101279:	83 c6 01             	add    $0x1,%esi
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010127c:	8b 12                	mov    (%edx),%edx
f010127e:	85 d2                	test   %edx,%edx
f0101280:	0f 85 61 fe ff ff    	jne    f01010e7 <check_page_free_list+0x15b>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0101286:	85 ff                	test   %edi,%edi
f0101288:	7f 24                	jg     f01012ae <check_page_free_list+0x322>
f010128a:	c7 44 24 0c 0c 58 10 	movl   $0xf010580c,0xc(%esp)
f0101291:	f0 
f0101292:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0101299:	f0 
f010129a:	c7 44 24 04 50 02 00 	movl   $0x250,0x4(%esp)
f01012a1:	00 
f01012a2:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f01012a9:	e8 df ee ff ff       	call   f010018d <_panic>
	assert(nfree_extmem > 0);
f01012ae:	85 f6                	test   %esi,%esi
f01012b0:	7f 53                	jg     f0101305 <check_page_free_list+0x379>
f01012b2:	c7 44 24 0c 1e 58 10 	movl   $0xf010581e,0xc(%esp)
f01012b9:	f0 
f01012ba:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f01012c1:	f0 
f01012c2:	c7 44 24 04 51 02 00 	movl   $0x251,0x4(%esp)
f01012c9:	00 
f01012ca:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f01012d1:	e8 b7 ee ff ff       	call   f010018d <_panic>
	struct Page *pp;
	int pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f01012d6:	a1 60 95 11 f0       	mov    0xf0119560,%eax
f01012db:	85 c0                	test   %eax,%eax
f01012dd:	0f 85 db fc ff ff    	jne    f0100fbe <check_page_free_list+0x32>
f01012e3:	e9 ba fc ff ff       	jmp    f0100fa2 <check_page_free_list+0x16>
f01012e8:	83 3d 60 95 11 f0 00 	cmpl   $0x0,0xf0119560
f01012ef:	0f 84 ad fc ff ff    	je     f0100fa2 <check_page_free_list+0x16>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f01012f5:	8b 1d 60 95 11 f0    	mov    0xf0119560,%ebx
//
static void
check_page_free_list(bool only_low_memory)
{
	struct Page *pp;
	int pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01012fb:	be 00 04 00 00       	mov    $0x400,%esi
f0101300:	e9 0d fd ff ff       	jmp    f0101012 <check_page_free_list+0x86>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0101305:	83 c4 3c             	add    $0x3c,%esp
f0101308:	5b                   	pop    %ebx
f0101309:	5e                   	pop    %esi
f010130a:	5f                   	pop    %edi
f010130b:	5d                   	pop    %ebp
f010130c:	c3                   	ret    

f010130d <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f010130d:	55                   	push   %ebp
f010130e:	89 e5                	mov    %esp,%ebp
f0101310:	57                   	push   %edi
f0101311:	56                   	push   %esi
f0101312:	53                   	push   %ebx
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	size_t i;
	int pageStart = ((int)pages-KERNBASE)/PGSIZE;
	int pageEnd = ((int)(pages+npages)-KERNBASE)/PGSIZE;
f0101313:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f0101318:	8b 15 80 99 11 f0    	mov    0xf0119980,%edx
f010131e:	8d bc d0 00 00 00 10 	lea    0x10000000(%eax,%edx,8),%edi
f0101325:	c1 ef 0c             	shr    $0xc,%edi
	page_free_list = NULL;
f0101328:	c7 05 60 95 11 f0 00 	movl   $0x0,0xf0119560
f010132f:	00 00 00 
	for (i= 1; i < npages_basemem; ++i) 
f0101332:	8b 35 58 95 11 f0    	mov    0xf0119558,%esi
f0101338:	83 fe 01             	cmp    $0x1,%esi
f010133b:	76 36                	jbe    f0101373 <page_init+0x66>
f010133d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101342:	b8 01 00 00 00       	mov    $0x1,%eax
// After this is done, NEVER use boot_alloc again.  ONLY use the page
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
f0101347:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
	int pageStart = ((int)pages-KERNBASE)/PGSIZE;
	int pageEnd = ((int)(pages+npages)-KERNBASE)/PGSIZE;
	page_free_list = NULL;
	for (i= 1; i < npages_basemem; ++i) 
	{
		pages[i].pp_ref = 0;
f010134e:	8b 0d 88 99 11 f0    	mov    0xf0119988,%ecx
f0101354:	66 c7 44 11 04 00 00 	movw   $0x0,0x4(%ecx,%edx,1)
		pages[i].pp_link = page_free_list;
f010135b:	89 1c c1             	mov    %ebx,(%ecx,%eax,8)
		page_free_list = &pages[i];
f010135e:	8b 1d 88 99 11 f0    	mov    0xf0119988,%ebx
f0101364:	01 d3                	add    %edx,%ebx

	size_t i;
	int pageStart = ((int)pages-KERNBASE)/PGSIZE;
	int pageEnd = ((int)(pages+npages)-KERNBASE)/PGSIZE;
	page_free_list = NULL;
	for (i= 1; i < npages_basemem; ++i) 
f0101366:	83 c0 01             	add    $0x1,%eax
f0101369:	39 f0                	cmp    %esi,%eax
f010136b:	72 da                	jb     f0101347 <page_init+0x3a>
f010136d:	89 1d 60 95 11 f0    	mov    %ebx,0xf0119560
	{
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	for(i= pageEnd+1; i< npages; ++i)
f0101373:	8d 47 01             	lea    0x1(%edi),%eax
f0101376:	89 c2                	mov    %eax,%edx
f0101378:	3b 05 80 99 11 f0    	cmp    0xf0119980,%eax
f010137e:	73 35                	jae    f01013b5 <page_init+0xa8>
f0101380:	8b 1d 60 95 11 f0    	mov    0xf0119560,%ebx
// After this is done, NEVER use boot_alloc again.  ONLY use the page
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
f0101386:	c1 e0 03             	shl    $0x3,%eax
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	for(i= pageEnd+1; i< npages; ++i)
	{
		pages[i].pp_ref = 0;
f0101389:	8b 0d 88 99 11 f0    	mov    0xf0119988,%ecx
f010138f:	01 c1                	add    %eax,%ecx
f0101391:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0101397:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0101399:	8b 1d 88 99 11 f0    	mov    0xf0119988,%ebx
f010139f:	01 c3                	add    %eax,%ebx
	{
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	for(i= pageEnd+1; i< npages; ++i)
f01013a1:	83 c2 01             	add    $0x1,%edx
f01013a4:	83 c0 08             	add    $0x8,%eax
f01013a7:	39 15 80 99 11 f0    	cmp    %edx,0xf0119980
f01013ad:	77 da                	ja     f0101389 <page_init+0x7c>
f01013af:	89 1d 60 95 11 f0    	mov    %ebx,0xf0119560
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	
	chunk_list = NULL;
f01013b5:	c7 05 64 95 11 f0 00 	movl   $0x0,0xf0119564
f01013bc:	00 00 00 
}
f01013bf:	5b                   	pop    %ebx
f01013c0:	5e                   	pop    %esi
f01013c1:	5f                   	pop    %edi
f01013c2:	5d                   	pop    %ebp
f01013c3:	c3                   	ret    

f01013c4 <page_alloc>:
struct Page *
page_alloc(int alloc_flags)
{
	// Fill this function in

	if(page_free_list == NULL) return NULL;
f01013c4:	a1 60 95 11 f0       	mov    0xf0119560,%eax
f01013c9:	85 c0                	test   %eax,%eax
f01013cb:	74 77                	je     f0101444 <page_alloc+0x80>
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct Page *
page_alloc(int alloc_flags)
{
f01013cd:	55                   	push   %ebp
f01013ce:	89 e5                	mov    %esp,%ebp
f01013d0:	83 ec 18             	sub    $0x18,%esp
	// Fill this function in

	if(page_free_list == NULL) return NULL;
	else if(alloc_flags & ALLOC_ZERO)  memset(page2kva(page_free_list), '\0', PGSIZE);
f01013d3:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01013d7:	74 56                	je     f010142f <page_alloc+0x6b>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01013d9:	2b 05 88 99 11 f0    	sub    0xf0119988,%eax
f01013df:	c1 f8 03             	sar    $0x3,%eax
f01013e2:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013e5:	89 c2                	mov    %eax,%edx
f01013e7:	c1 ea 0c             	shr    $0xc,%edx
f01013ea:	3b 15 80 99 11 f0    	cmp    0xf0119980,%edx
f01013f0:	72 20                	jb     f0101412 <page_alloc+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01013f6:	c7 44 24 08 68 50 10 	movl   $0xf0105068,0x8(%esp)
f01013fd:	f0 
f01013fe:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0101405:	00 
f0101406:	c7 04 24 85 57 10 f0 	movl   $0xf0105785,(%esp)
f010140d:	e8 7b ed ff ff       	call   f010018d <_panic>
f0101412:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101419:	00 
f010141a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101421:	00 
	return (void *)(pa + KERNBASE);
f0101422:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101427:	89 04 24             	mov    %eax,(%esp)
f010142a:	e8 c5 2f 00 00       	call   f01043f4 <memset>
	struct Page *pret = page_free_list;
f010142f:	a1 60 95 11 f0       	mov    0xf0119560,%eax
	page_free_list = pret->pp_link;
f0101434:	8b 10                	mov    (%eax),%edx
f0101436:	89 15 60 95 11 f0    	mov    %edx,0xf0119560
	pret->pp_link = NULL;
f010143c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return pret;
f0101442:	eb 06                	jmp    f010144a <page_alloc+0x86>
struct Page *
page_alloc(int alloc_flags)
{
	// Fill this function in

	if(page_free_list == NULL) return NULL;
f0101444:	b8 00 00 00 00       	mov    $0x0,%eax
f0101449:	c3                   	ret    
	else if(alloc_flags & ALLOC_ZERO)  memset(page2kva(page_free_list), '\0', PGSIZE);
	struct Page *pret = page_free_list;
	page_free_list = pret->pp_link;
	pret->pp_link = NULL;
	return pret;
}
f010144a:	c9                   	leave  
f010144b:	c3                   	ret    

f010144c <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f010144c:	55                   	push   %ebp
f010144d:	89 e5                	mov    %esp,%ebp
f010144f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Fill this function in
	struct Page *tmpp = NULL;
	pp->pp_link = page_free_list;
f0101452:	8b 15 60 95 11 f0    	mov    0xf0119560,%edx
f0101458:	89 11                	mov    %edx,(%ecx)
	while(pp->pp_link && (pp < pp->pp_link))
f010145a:	85 d2                	test   %edx,%edx
f010145c:	74 1c                	je     f010147a <page_free+0x2e>
f010145e:	39 ca                	cmp    %ecx,%edx
f0101460:	77 04                	ja     f0101466 <page_free+0x1a>
f0101462:	eb 16                	jmp    f010147a <page_free+0x2e>
f0101464:	89 c2                	mov    %eax,%edx
	{
		tmpp = pp->pp_link;
		pp->pp_link = pp->pp_link->pp_link;
f0101466:	8b 02                	mov    (%edx),%eax
f0101468:	89 01                	mov    %eax,(%ecx)
page_free(struct Page *pp)
{
	// Fill this function in
	struct Page *tmpp = NULL;
	pp->pp_link = page_free_list;
	while(pp->pp_link && (pp < pp->pp_link))
f010146a:	85 c0                	test   %eax,%eax
f010146c:	74 04                	je     f0101472 <page_free+0x26>
f010146e:	39 c1                	cmp    %eax,%ecx
f0101470:	72 f2                	jb     f0101464 <page_free+0x18>
	{
		tmpp = pp->pp_link;
		pp->pp_link = pp->pp_link->pp_link;
	}
	if(tmpp) tmpp->pp_link = pp;
f0101472:	85 d2                	test   %edx,%edx
f0101474:	74 04                	je     f010147a <page_free+0x2e>
f0101476:	89 0a                	mov    %ecx,(%edx)
f0101478:	eb 06                	jmp    f0101480 <page_free+0x34>
	else page_free_list = pp;
f010147a:	89 0d 60 95 11 f0    	mov    %ecx,0xf0119560
}
f0101480:	5d                   	pop    %ebp
f0101481:	c3                   	ret    

f0101482 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f0101482:	55                   	push   %ebp
f0101483:	89 e5                	mov    %esp,%ebp
f0101485:	83 ec 04             	sub    $0x4,%esp
f0101488:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0) page_free(pp);
f010148b:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f010148f:	83 ea 01             	sub    $0x1,%edx
f0101492:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101496:	66 85 d2             	test   %dx,%dx
f0101499:	75 08                	jne    f01014a3 <page_decref+0x21>
f010149b:	89 04 24             	mov    %eax,(%esp)
f010149e:	e8 a9 ff ff ff       	call   f010144c <page_free>
}
f01014a3:	c9                   	leave  
f01014a4:	c3                   	ret    

f01014a5 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01014a5:	55                   	push   %ebp
f01014a6:	89 e5                	mov    %esp,%ebp
f01014a8:	56                   	push   %esi
f01014a9:	53                   	push   %ebx
f01014aa:	83 ec 10             	sub    $0x10,%esp
f01014ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pde_t *pde = &(pgdir[PDX(va)]);
f01014b0:	89 de                	mov    %ebx,%esi
f01014b2:	c1 ee 16             	shr    $0x16,%esi
f01014b5:	c1 e6 02             	shl    $0x2,%esi
f01014b8:	03 75 08             	add    0x8(%ebp),%esi
	pde_t *pgtab = NULL;
	if((*pde) & PTE_P)
f01014bb:	8b 06                	mov    (%esi),%eax
f01014bd:	a8 01                	test   $0x1,%al
f01014bf:	74 39                	je     f01014fa <pgdir_walk+0x55>
	{
		pgtab = (pte_t*)KADDR(PTE_ADDR(*pde));
f01014c1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014c6:	89 c2                	mov    %eax,%edx
f01014c8:	c1 ea 0c             	shr    $0xc,%edx
f01014cb:	3b 15 80 99 11 f0    	cmp    0xf0119980,%edx
f01014d1:	72 20                	jb     f01014f3 <pgdir_walk+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01014d7:	c7 44 24 08 68 50 10 	movl   $0xf0105068,0x8(%esp)
f01014de:	f0 
f01014df:	c7 44 24 04 68 01 00 	movl   $0x168,0x4(%esp)
f01014e6:	00 
f01014e7:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f01014ee:	e8 9a ec ff ff       	call   f010018d <_panic>
	return (void *)(pa + KERNBASE);
f01014f3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01014f8:	eb 6c                	jmp    f0101566 <pgdir_walk+0xc1>
	}
	else
	{
		if(!create) return NULL;
f01014fa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01014fe:	74 73                	je     f0101573 <pgdir_walk+0xce>
		struct Page *pp = page_alloc(ALLOC_ZERO);
f0101500:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101507:	e8 b8 fe ff ff       	call   f01013c4 <page_alloc>
		if(!pp) return NULL;
f010150c:	85 c0                	test   %eax,%eax
f010150e:	74 6a                	je     f010157a <pgdir_walk+0xd5>
		pp->pp_ref++;	
f0101510:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101515:	89 c2                	mov    %eax,%edx
f0101517:	2b 15 88 99 11 f0    	sub    0xf0119988,%edx
f010151d:	c1 fa 03             	sar    $0x3,%edx
f0101520:	c1 e2 0c             	shl    $0xc,%edx
		*pde = page2pa(pp) | PTE_P | PTE_U | PTE_W;
f0101523:	83 ca 07             	or     $0x7,%edx
f0101526:	89 16                	mov    %edx,(%esi)
f0101528:	2b 05 88 99 11 f0    	sub    0xf0119988,%eax
f010152e:	c1 f8 03             	sar    $0x3,%eax
f0101531:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101534:	89 c2                	mov    %eax,%edx
f0101536:	c1 ea 0c             	shr    $0xc,%edx
f0101539:	3b 15 80 99 11 f0    	cmp    0xf0119980,%edx
f010153f:	72 20                	jb     f0101561 <pgdir_walk+0xbc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101541:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101545:	c7 44 24 08 68 50 10 	movl   $0xf0105068,0x8(%esp)
f010154c:	f0 
f010154d:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0101554:	00 
f0101555:	c7 04 24 85 57 10 f0 	movl   $0xf0105785,(%esp)
f010155c:	e8 2c ec ff ff       	call   f010018d <_panic>
	return (void *)(pa + KERNBASE);
f0101561:	2d 00 00 00 10       	sub    $0x10000000,%eax
		pgtab = (pde_t*)page2kva(pp);
	}
	return &(pgtab[PTX(va)]);
f0101566:	c1 eb 0a             	shr    $0xa,%ebx
f0101569:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f010156f:	01 d8                	add    %ebx,%eax
f0101571:	eb 0c                	jmp    f010157f <pgdir_walk+0xda>
	{
		pgtab = (pte_t*)KADDR(PTE_ADDR(*pde));
	}
	else
	{
		if(!create) return NULL;
f0101573:	b8 00 00 00 00       	mov    $0x0,%eax
f0101578:	eb 05                	jmp    f010157f <pgdir_walk+0xda>
		struct Page *pp = page_alloc(ALLOC_ZERO);
		if(!pp) return NULL;
f010157a:	b8 00 00 00 00       	mov    $0x0,%eax
		pp->pp_ref++;	
		*pde = page2pa(pp) | PTE_P | PTE_U | PTE_W;
		pgtab = (pde_t*)page2kva(pp);
	}
	return &(pgtab[PTX(va)]);
}
f010157f:	83 c4 10             	add    $0x10,%esp
f0101582:	5b                   	pop    %ebx
f0101583:	5e                   	pop    %esi
f0101584:	5d                   	pop    %ebp
f0101585:	c3                   	ret    

f0101586 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101586:	55                   	push   %ebp
f0101587:	89 e5                	mov    %esp,%ebp
f0101589:	57                   	push   %edi
f010158a:	56                   	push   %esi
f010158b:	53                   	push   %ebx
f010158c:	83 ec 1c             	sub    $0x1c,%esp
f010158f:	89 d6                	mov    %edx,%esi
	// Fill this function in
	if(va < UTOP) return;
f0101591:	81 fa ff ff bf ee    	cmp    $0xeebfffff,%edx
f0101597:	76 3a                	jbe    f01015d3 <boot_map_region+0x4d>
f0101599:	89 c7                	mov    %eax,%edi
f010159b:	89 cb                	mov    %ecx,%ebx
	while(size)
f010159d:	85 c9                	test   %ecx,%ecx
f010159f:	74 32                	je     f01015d3 <boot_map_region+0x4d>
	{
		size -= PGSIZE;
f01015a1:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
		pte_t *pte = pgdir_walk(pgdir,(void*)(va + size), 1);
f01015a7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01015ae:	00 
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f01015af:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
	// Fill this function in
	if(va < UTOP) return;
	while(size)
	{
		size -= PGSIZE;
		pte_t *pte = pgdir_walk(pgdir,(void*)(va + size), 1);
f01015b2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015b6:	89 3c 24             	mov    %edi,(%esp)
f01015b9:	e8 e7 fe ff ff       	call   f01014a5 <pgdir_walk>
		if(pte)	*pte = (pa + size) | perm | PTE_P;
f01015be:	85 c0                	test   %eax,%eax
f01015c0:	74 0d                	je     f01015cf <boot_map_region+0x49>
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f01015c2:	8b 55 08             	mov    0x8(%ebp),%edx
f01015c5:	01 da                	add    %ebx,%edx
	if(va < UTOP) return;
	while(size)
	{
		size -= PGSIZE;
		pte_t *pte = pgdir_walk(pgdir,(void*)(va + size), 1);
		if(pte)	*pte = (pa + size) | perm | PTE_P;
f01015c7:	0b 55 0c             	or     0xc(%ebp),%edx
f01015ca:	83 ca 01             	or     $0x1,%edx
f01015cd:	89 10                	mov    %edx,(%eax)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	if(va < UTOP) return;
	while(size)
f01015cf:	85 db                	test   %ebx,%ebx
f01015d1:	75 ce                	jne    f01015a1 <boot_map_region+0x1b>
	{
		size -= PGSIZE;
		pte_t *pte = pgdir_walk(pgdir,(void*)(va + size), 1);
		if(pte)	*pte = (pa + size) | perm | PTE_P;
	}
}
f01015d3:	83 c4 1c             	add    $0x1c,%esp
f01015d6:	5b                   	pop    %ebx
f01015d7:	5e                   	pop    %esi
f01015d8:	5f                   	pop    %edi
f01015d9:	5d                   	pop    %ebp
f01015da:	c3                   	ret    

f01015db <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01015db:	55                   	push   %ebp
f01015dc:	89 e5                	mov    %esp,%ebp
f01015de:	53                   	push   %ebx
f01015df:	83 ec 14             	sub    $0x14,%esp
f01015e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f01015e5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01015ec:	00 
f01015ed:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015f0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015f4:	8b 45 08             	mov    0x8(%ebp),%eax
f01015f7:	89 04 24             	mov    %eax,(%esp)
f01015fa:	e8 a6 fe ff ff       	call   f01014a5 <pgdir_walk>
	if(!pte || !((*pte) | PTE_P)) return NULL;
f01015ff:	85 c0                	test   %eax,%eax
f0101601:	74 3e                	je     f0101641 <page_lookup+0x66>
	if(pte_store) *pte_store = pte;
f0101603:	85 db                	test   %ebx,%ebx
f0101605:	74 02                	je     f0101609 <page_lookup+0x2e>
f0101607:	89 03                	mov    %eax,(%ebx)
	if(*pte == 0) 
f0101609:	8b 00                	mov    (%eax),%eax
f010160b:	85 c0                	test   %eax,%eax
f010160d:	74 39                	je     f0101648 <page_lookup+0x6d>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010160f:	c1 e8 0c             	shr    $0xc,%eax
f0101612:	3b 05 80 99 11 f0    	cmp    0xf0119980,%eax
f0101618:	72 1c                	jb     f0101636 <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f010161a:	c7 44 24 08 50 51 10 	movl   $0xf0105150,0x8(%esp)
f0101621:	f0 
f0101622:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
f0101629:	00 
f010162a:	c7 04 24 85 57 10 f0 	movl   $0xf0105785,(%esp)
f0101631:	e8 57 eb ff ff       	call   f010018d <_panic>
	return &pages[PGNUM(pa)];
f0101636:	8b 15 88 99 11 f0    	mov    0xf0119988,%edx
f010163c:	8d 04 c2             	lea    (%edx,%eax,8),%eax
		return NULL;
	else 
		return pa2page(*pte);
f010163f:	eb 0c                	jmp    f010164d <page_lookup+0x72>
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 0);
	if(!pte || !((*pte) | PTE_P)) return NULL;
f0101641:	b8 00 00 00 00       	mov    $0x0,%eax
f0101646:	eb 05                	jmp    f010164d <page_lookup+0x72>
	if(pte_store) *pte_store = pte;
	if(*pte == 0) 
		return NULL;
f0101648:	b8 00 00 00 00       	mov    $0x0,%eax
	else 
		return pa2page(*pte);
	return NULL;
}
f010164d:	83 c4 14             	add    $0x14,%esp
f0101650:	5b                   	pop    %ebx
f0101651:	5d                   	pop    %ebp
f0101652:	c3                   	ret    

f0101653 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101653:	55                   	push   %ebp
f0101654:	89 e5                	mov    %esp,%ebp
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101656:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101659:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f010165c:	5d                   	pop    %ebp
f010165d:	c3                   	ret    

f010165e <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010165e:	55                   	push   %ebp
f010165f:	89 e5                	mov    %esp,%ebp
f0101661:	83 ec 28             	sub    $0x28,%esp
f0101664:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0101667:	89 75 fc             	mov    %esi,-0x4(%ebp)
f010166a:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010166d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	pte_t *pte;
	struct Page *pp = page_lookup(pgdir, va, &pte);
f0101670:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101673:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101677:	89 74 24 04          	mov    %esi,0x4(%esp)
f010167b:	89 1c 24             	mov    %ebx,(%esp)
f010167e:	e8 58 ff ff ff       	call   f01015db <page_lookup>
	if(!pp) return;
f0101683:	85 c0                	test   %eax,%eax
f0101685:	74 21                	je     f01016a8 <page_remove+0x4a>
	page_decref(pp); 
f0101687:	89 04 24             	mov    %eax,(%esp)
f010168a:	e8 f3 fd ff ff       	call   f0101482 <page_decref>
	tlb_invalidate(pgdir, va);
f010168f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101693:	89 1c 24             	mov    %ebx,(%esp)
f0101696:	e8 b8 ff ff ff       	call   f0101653 <tlb_invalidate>
	if(pte) *pte = 0;
f010169b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010169e:	85 c0                	test   %eax,%eax
f01016a0:	74 06                	je     f01016a8 <page_remove+0x4a>
f01016a2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
f01016a8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f01016ab:	8b 75 fc             	mov    -0x4(%ebp),%esi
f01016ae:	89 ec                	mov    %ebp,%esp
f01016b0:	5d                   	pop    %ebp
f01016b1:	c3                   	ret    

f01016b2 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm)
{
f01016b2:	55                   	push   %ebp
f01016b3:	89 e5                	mov    %esp,%ebp
f01016b5:	83 ec 28             	sub    $0x28,%esp
f01016b8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01016bb:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01016be:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01016c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01016c4:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f01016c7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01016ce:	00 
f01016cf:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01016d3:	8b 45 08             	mov    0x8(%ebp),%eax
f01016d6:	89 04 24             	mov    %eax,(%esp)
f01016d9:	e8 c7 fd ff ff       	call   f01014a5 <pgdir_walk>
f01016de:	89 c6                	mov    %eax,%esi
	if(pte && ((*pte) | PTE_P))
f01016e0:	85 c0                	test   %eax,%eax
f01016e2:	74 16                	je     f01016fa <page_insert+0x48>
	{
		pp->pp_ref++;
f01016e4:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
		page_remove(pgdir, va);
f01016e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01016ed:	8b 45 08             	mov    0x8(%ebp),%eax
f01016f0:	89 04 24             	mov    %eax,(%esp)
f01016f3:	e8 66 ff ff ff       	call   f010165e <page_remove>
f01016f8:	eb 22                	jmp    f010171c <page_insert+0x6a>
	}
	else
	{
		pte = pgdir_walk(pgdir, va, 1);
f01016fa:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101701:	00 
f0101702:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101706:	8b 45 08             	mov    0x8(%ebp),%eax
f0101709:	89 04 24             	mov    %eax,(%esp)
f010170c:	e8 94 fd ff ff       	call   f01014a5 <pgdir_walk>
f0101711:	89 c6                	mov    %eax,%esi
		if(!pte) return -E_NO_MEM;
f0101713:	85 c0                	test   %eax,%eax
f0101715:	74 22                	je     f0101739 <page_insert+0x87>
		else pp->pp_ref++;
f0101717:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	}
	*pte = page2pa(pp) | PTE_P | perm;
f010171c:	8b 45 14             	mov    0x14(%ebp),%eax
f010171f:	83 c8 01             	or     $0x1,%eax
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101722:	2b 1d 88 99 11 f0    	sub    0xf0119988,%ebx
f0101728:	c1 fb 03             	sar    $0x3,%ebx
f010172b:	c1 e3 0c             	shl    $0xc,%ebx
f010172e:	09 c3                	or     %eax,%ebx
f0101730:	89 1e                	mov    %ebx,(%esi)
	return 0;	
f0101732:	b8 00 00 00 00       	mov    $0x0,%eax
f0101737:	eb 05                	jmp    f010173e <page_insert+0x8c>
		page_remove(pgdir, va);
	}
	else
	{
		pte = pgdir_walk(pgdir, va, 1);
		if(!pte) return -E_NO_MEM;
f0101739:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		else pp->pp_ref++;
	}
	*pte = page2pa(pp) | PTE_P | perm;
	return 0;	
}
f010173e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101741:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101744:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101747:	89 ec                	mov    %ebp,%esp
f0101749:	5d                   	pop    %ebp
f010174a:	c3                   	ret    

f010174b <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010174b:	55                   	push   %ebp
f010174c:	89 e5                	mov    %esp,%ebp
f010174e:	57                   	push   %edi
f010174f:	56                   	push   %esi
f0101750:	53                   	push   %ebx
f0101751:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101754:	b8 15 00 00 00       	mov    $0x15,%eax
f0101759:	e8 fc f7 ff ff       	call   f0100f5a <nvram_read>
f010175e:	c1 e0 0a             	shl    $0xa,%eax
f0101761:	89 c2                	mov    %eax,%edx
f0101763:	c1 fa 1f             	sar    $0x1f,%edx
f0101766:	c1 ea 14             	shr    $0x14,%edx
f0101769:	01 d0                	add    %edx,%eax
f010176b:	c1 f8 0c             	sar    $0xc,%eax
f010176e:	a3 58 95 11 f0       	mov    %eax,0xf0119558
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101773:	b8 17 00 00 00       	mov    $0x17,%eax
f0101778:	e8 dd f7 ff ff       	call   f0100f5a <nvram_read>
f010177d:	c1 e0 0a             	shl    $0xa,%eax
f0101780:	89 c2                	mov    %eax,%edx
f0101782:	c1 fa 1f             	sar    $0x1f,%edx
f0101785:	c1 ea 14             	shr    $0x14,%edx
f0101788:	01 d0                	add    %edx,%eax
f010178a:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010178d:	85 c0                	test   %eax,%eax
f010178f:	74 0e                	je     f010179f <mem_init+0x54>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101791:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101797:	89 15 80 99 11 f0    	mov    %edx,0xf0119980
f010179d:	eb 0c                	jmp    f01017ab <mem_init+0x60>
	else
		npages = npages_basemem;
f010179f:	8b 15 58 95 11 f0    	mov    0xf0119558,%edx
f01017a5:	89 15 80 99 11 f0    	mov    %edx,0xf0119980

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f01017ab:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01017ae:	c1 e8 0a             	shr    $0xa,%eax
f01017b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f01017b5:	a1 58 95 11 f0       	mov    0xf0119558,%eax
f01017ba:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01017bd:	c1 e8 0a             	shr    $0xa,%eax
f01017c0:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f01017c4:	a1 80 99 11 f0       	mov    0xf0119980,%eax
f01017c9:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01017cc:	c1 e8 0a             	shr    $0xa,%eax
f01017cf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01017d3:	c7 04 24 70 51 10 f0 	movl   $0xf0105170,(%esp)
f01017da:	e8 1e 1b 00 00       	call   f01032fd <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01017df:	b8 00 10 00 00       	mov    $0x1000,%eax
f01017e4:	e8 97 f6 ff ff       	call   f0100e80 <boot_alloc>
f01017e9:	a3 84 99 11 f0       	mov    %eax,0xf0119984
	memset(kern_pgdir, 0, PGSIZE);
f01017ee:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01017f5:	00 
f01017f6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01017fd:	00 
f01017fe:	89 04 24             	mov    %eax,(%esp)
f0101801:	e8 ee 2b 00 00       	call   f01043f4 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101806:	a1 84 99 11 f0       	mov    0xf0119984,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010180b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101810:	77 20                	ja     f0101832 <mem_init+0xe7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101812:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101816:	c7 44 24 08 ac 51 10 	movl   $0xf01051ac,0x8(%esp)
f010181d:	f0 
f010181e:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0101825:	00 
f0101826:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f010182d:	e8 5b e9 ff ff       	call   f010018d <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101832:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101838:	83 ca 05             	or     $0x5,%edx
f010183b:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct Page's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct Page in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
	pages = boot_alloc(npages * sizeof(struct Page));
f0101841:	a1 80 99 11 f0       	mov    0xf0119980,%eax
f0101846:	c1 e0 03             	shl    $0x3,%eax
f0101849:	e8 32 f6 ff ff       	call   f0100e80 <boot_alloc>
f010184e:	a3 88 99 11 f0       	mov    %eax,0xf0119988
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101853:	e8 b5 fa ff ff       	call   f010130d <page_init>

	check_page_free_list(1);
f0101858:	b8 01 00 00 00       	mov    $0x1,%eax
f010185d:	e8 2a f7 ff ff       	call   f0100f8c <check_page_free_list>
	int nfree;
	struct Page *fl;
	char *c;
	int i;

	if (!pages)
f0101862:	83 3d 88 99 11 f0 00 	cmpl   $0x0,0xf0119988
f0101869:	75 1c                	jne    f0101887 <mem_init+0x13c>
		panic("'pages' is a null pointer!");
f010186b:	c7 44 24 08 2f 58 10 	movl   $0xf010582f,0x8(%esp)
f0101872:	f0 
f0101873:	c7 44 24 04 62 02 00 	movl   $0x262,0x4(%esp)
f010187a:	00 
f010187b:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0101882:	e8 06 e9 ff ff       	call   f010018d <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101887:	a1 60 95 11 f0       	mov    0xf0119560,%eax
f010188c:	85 c0                	test   %eax,%eax
f010188e:	74 10                	je     f01018a0 <mem_init+0x155>
f0101890:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f0101895:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101898:	8b 00                	mov    (%eax),%eax
f010189a:	85 c0                	test   %eax,%eax
f010189c:	75 f7                	jne    f0101895 <mem_init+0x14a>
f010189e:	eb 05                	jmp    f01018a5 <mem_init+0x15a>
f01018a0:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01018a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018ac:	e8 13 fb ff ff       	call   f01013c4 <page_alloc>
f01018b1:	89 c7                	mov    %eax,%edi
f01018b3:	85 c0                	test   %eax,%eax
f01018b5:	75 24                	jne    f01018db <mem_init+0x190>
f01018b7:	c7 44 24 0c 4a 58 10 	movl   $0xf010584a,0xc(%esp)
f01018be:	f0 
f01018bf:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f01018c6:	f0 
f01018c7:	c7 44 24 04 6a 02 00 	movl   $0x26a,0x4(%esp)
f01018ce:	00 
f01018cf:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f01018d6:	e8 b2 e8 ff ff       	call   f010018d <_panic>
	assert((pp1 = page_alloc(0)));
f01018db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018e2:	e8 dd fa ff ff       	call   f01013c4 <page_alloc>
f01018e7:	89 c6                	mov    %eax,%esi
f01018e9:	85 c0                	test   %eax,%eax
f01018eb:	75 24                	jne    f0101911 <mem_init+0x1c6>
f01018ed:	c7 44 24 0c 60 58 10 	movl   $0xf0105860,0xc(%esp)
f01018f4:	f0 
f01018f5:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f01018fc:	f0 
f01018fd:	c7 44 24 04 6b 02 00 	movl   $0x26b,0x4(%esp)
f0101904:	00 
f0101905:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f010190c:	e8 7c e8 ff ff       	call   f010018d <_panic>
	assert((pp2 = page_alloc(0)));
f0101911:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101918:	e8 a7 fa ff ff       	call   f01013c4 <page_alloc>
f010191d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101920:	85 c0                	test   %eax,%eax
f0101922:	75 24                	jne    f0101948 <mem_init+0x1fd>
f0101924:	c7 44 24 0c 76 58 10 	movl   $0xf0105876,0xc(%esp)
f010192b:	f0 
f010192c:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0101933:	f0 
f0101934:	c7 44 24 04 6c 02 00 	movl   $0x26c,0x4(%esp)
f010193b:	00 
f010193c:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0101943:	e8 45 e8 ff ff       	call   f010018d <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101948:	39 f7                	cmp    %esi,%edi
f010194a:	75 24                	jne    f0101970 <mem_init+0x225>
f010194c:	c7 44 24 0c 8c 58 10 	movl   $0xf010588c,0xc(%esp)
f0101953:	f0 
f0101954:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f010195b:	f0 
f010195c:	c7 44 24 04 6f 02 00 	movl   $0x26f,0x4(%esp)
f0101963:	00 
f0101964:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f010196b:	e8 1d e8 ff ff       	call   f010018d <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101970:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101973:	74 05                	je     f010197a <mem_init+0x22f>
f0101975:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101978:	75 24                	jne    f010199e <mem_init+0x253>
f010197a:	c7 44 24 0c d0 51 10 	movl   $0xf01051d0,0xc(%esp)
f0101981:	f0 
f0101982:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0101989:	f0 
f010198a:	c7 44 24 04 70 02 00 	movl   $0x270,0x4(%esp)
f0101991:	00 
f0101992:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0101999:	e8 ef e7 ff ff       	call   f010018d <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010199e:	8b 15 88 99 11 f0    	mov    0xf0119988,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01019a4:	a1 80 99 11 f0       	mov    0xf0119980,%eax
f01019a9:	c1 e0 0c             	shl    $0xc,%eax
f01019ac:	89 f9                	mov    %edi,%ecx
f01019ae:	29 d1                	sub    %edx,%ecx
f01019b0:	c1 f9 03             	sar    $0x3,%ecx
f01019b3:	c1 e1 0c             	shl    $0xc,%ecx
f01019b6:	39 c1                	cmp    %eax,%ecx
f01019b8:	72 24                	jb     f01019de <mem_init+0x293>
f01019ba:	c7 44 24 0c 9e 58 10 	movl   $0xf010589e,0xc(%esp)
f01019c1:	f0 
f01019c2:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f01019c9:	f0 
f01019ca:	c7 44 24 04 71 02 00 	movl   $0x271,0x4(%esp)
f01019d1:	00 
f01019d2:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f01019d9:	e8 af e7 ff ff       	call   f010018d <_panic>
f01019de:	89 f1                	mov    %esi,%ecx
f01019e0:	29 d1                	sub    %edx,%ecx
f01019e2:	c1 f9 03             	sar    $0x3,%ecx
f01019e5:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f01019e8:	39 c8                	cmp    %ecx,%eax
f01019ea:	77 24                	ja     f0101a10 <mem_init+0x2c5>
f01019ec:	c7 44 24 0c bb 58 10 	movl   $0xf01058bb,0xc(%esp)
f01019f3:	f0 
f01019f4:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f01019fb:	f0 
f01019fc:	c7 44 24 04 72 02 00 	movl   $0x272,0x4(%esp)
f0101a03:	00 
f0101a04:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0101a0b:	e8 7d e7 ff ff       	call   f010018d <_panic>
f0101a10:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101a13:	29 d1                	sub    %edx,%ecx
f0101a15:	89 ca                	mov    %ecx,%edx
f0101a17:	c1 fa 03             	sar    $0x3,%edx
f0101a1a:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101a1d:	39 d0                	cmp    %edx,%eax
f0101a1f:	77 24                	ja     f0101a45 <mem_init+0x2fa>
f0101a21:	c7 44 24 0c d8 58 10 	movl   $0xf01058d8,0xc(%esp)
f0101a28:	f0 
f0101a29:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0101a30:	f0 
f0101a31:	c7 44 24 04 73 02 00 	movl   $0x273,0x4(%esp)
f0101a38:	00 
f0101a39:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0101a40:	e8 48 e7 ff ff       	call   f010018d <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101a45:	a1 60 95 11 f0       	mov    0xf0119560,%eax
f0101a4a:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101a4d:	c7 05 60 95 11 f0 00 	movl   $0x0,0xf0119560
f0101a54:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101a57:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a5e:	e8 61 f9 ff ff       	call   f01013c4 <page_alloc>
f0101a63:	85 c0                	test   %eax,%eax
f0101a65:	74 24                	je     f0101a8b <mem_init+0x340>
f0101a67:	c7 44 24 0c f5 58 10 	movl   $0xf01058f5,0xc(%esp)
f0101a6e:	f0 
f0101a6f:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0101a76:	f0 
f0101a77:	c7 44 24 04 7a 02 00 	movl   $0x27a,0x4(%esp)
f0101a7e:	00 
f0101a7f:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0101a86:	e8 02 e7 ff ff       	call   f010018d <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101a8b:	89 3c 24             	mov    %edi,(%esp)
f0101a8e:	e8 b9 f9 ff ff       	call   f010144c <page_free>
	page_free(pp1);
f0101a93:	89 34 24             	mov    %esi,(%esp)
f0101a96:	e8 b1 f9 ff ff       	call   f010144c <page_free>
	page_free(pp2);
f0101a9b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a9e:	89 04 24             	mov    %eax,(%esp)
f0101aa1:	e8 a6 f9 ff ff       	call   f010144c <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101aa6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101aad:	e8 12 f9 ff ff       	call   f01013c4 <page_alloc>
f0101ab2:	89 c6                	mov    %eax,%esi
f0101ab4:	85 c0                	test   %eax,%eax
f0101ab6:	75 24                	jne    f0101adc <mem_init+0x391>
f0101ab8:	c7 44 24 0c 4a 58 10 	movl   $0xf010584a,0xc(%esp)
f0101abf:	f0 
f0101ac0:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0101ac7:	f0 
f0101ac8:	c7 44 24 04 81 02 00 	movl   $0x281,0x4(%esp)
f0101acf:	00 
f0101ad0:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0101ad7:	e8 b1 e6 ff ff       	call   f010018d <_panic>
	assert((pp1 = page_alloc(0)));
f0101adc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ae3:	e8 dc f8 ff ff       	call   f01013c4 <page_alloc>
f0101ae8:	89 c7                	mov    %eax,%edi
f0101aea:	85 c0                	test   %eax,%eax
f0101aec:	75 24                	jne    f0101b12 <mem_init+0x3c7>
f0101aee:	c7 44 24 0c 60 58 10 	movl   $0xf0105860,0xc(%esp)
f0101af5:	f0 
f0101af6:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0101afd:	f0 
f0101afe:	c7 44 24 04 82 02 00 	movl   $0x282,0x4(%esp)
f0101b05:	00 
f0101b06:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0101b0d:	e8 7b e6 ff ff       	call   f010018d <_panic>
	assert((pp2 = page_alloc(0)));
f0101b12:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b19:	e8 a6 f8 ff ff       	call   f01013c4 <page_alloc>
f0101b1e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101b21:	85 c0                	test   %eax,%eax
f0101b23:	75 24                	jne    f0101b49 <mem_init+0x3fe>
f0101b25:	c7 44 24 0c 76 58 10 	movl   $0xf0105876,0xc(%esp)
f0101b2c:	f0 
f0101b2d:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0101b34:	f0 
f0101b35:	c7 44 24 04 83 02 00 	movl   $0x283,0x4(%esp)
f0101b3c:	00 
f0101b3d:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0101b44:	e8 44 e6 ff ff       	call   f010018d <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101b49:	39 fe                	cmp    %edi,%esi
f0101b4b:	75 24                	jne    f0101b71 <mem_init+0x426>
f0101b4d:	c7 44 24 0c 8c 58 10 	movl   $0xf010588c,0xc(%esp)
f0101b54:	f0 
f0101b55:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0101b5c:	f0 
f0101b5d:	c7 44 24 04 85 02 00 	movl   $0x285,0x4(%esp)
f0101b64:	00 
f0101b65:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0101b6c:	e8 1c e6 ff ff       	call   f010018d <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b71:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101b74:	74 05                	je     f0101b7b <mem_init+0x430>
f0101b76:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101b79:	75 24                	jne    f0101b9f <mem_init+0x454>
f0101b7b:	c7 44 24 0c d0 51 10 	movl   $0xf01051d0,0xc(%esp)
f0101b82:	f0 
f0101b83:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0101b8a:	f0 
f0101b8b:	c7 44 24 04 86 02 00 	movl   $0x286,0x4(%esp)
f0101b92:	00 
f0101b93:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0101b9a:	e8 ee e5 ff ff       	call   f010018d <_panic>
	assert(!page_alloc(0));
f0101b9f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ba6:	e8 19 f8 ff ff       	call   f01013c4 <page_alloc>
f0101bab:	85 c0                	test   %eax,%eax
f0101bad:	74 24                	je     f0101bd3 <mem_init+0x488>
f0101baf:	c7 44 24 0c f5 58 10 	movl   $0xf01058f5,0xc(%esp)
f0101bb6:	f0 
f0101bb7:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0101bbe:	f0 
f0101bbf:	c7 44 24 04 87 02 00 	movl   $0x287,0x4(%esp)
f0101bc6:	00 
f0101bc7:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0101bce:	e8 ba e5 ff ff       	call   f010018d <_panic>
f0101bd3:	89 f0                	mov    %esi,%eax
f0101bd5:	2b 05 88 99 11 f0    	sub    0xf0119988,%eax
f0101bdb:	c1 f8 03             	sar    $0x3,%eax
f0101bde:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101be1:	89 c2                	mov    %eax,%edx
f0101be3:	c1 ea 0c             	shr    $0xc,%edx
f0101be6:	3b 15 80 99 11 f0    	cmp    0xf0119980,%edx
f0101bec:	72 20                	jb     f0101c0e <mem_init+0x4c3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101bee:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101bf2:	c7 44 24 08 68 50 10 	movl   $0xf0105068,0x8(%esp)
f0101bf9:	f0 
f0101bfa:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0101c01:	00 
f0101c02:	c7 04 24 85 57 10 f0 	movl   $0xf0105785,(%esp)
f0101c09:	e8 7f e5 ff ff       	call   f010018d <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101c0e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101c15:	00 
f0101c16:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101c1d:	00 
	return (void *)(pa + KERNBASE);
f0101c1e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101c23:	89 04 24             	mov    %eax,(%esp)
f0101c26:	e8 c9 27 00 00       	call   f01043f4 <memset>
	page_free(pp0);
f0101c2b:	89 34 24             	mov    %esi,(%esp)
f0101c2e:	e8 19 f8 ff ff       	call   f010144c <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101c33:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101c3a:	e8 85 f7 ff ff       	call   f01013c4 <page_alloc>
f0101c3f:	85 c0                	test   %eax,%eax
f0101c41:	75 24                	jne    f0101c67 <mem_init+0x51c>
f0101c43:	c7 44 24 0c 04 59 10 	movl   $0xf0105904,0xc(%esp)
f0101c4a:	f0 
f0101c4b:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0101c52:	f0 
f0101c53:	c7 44 24 04 8c 02 00 	movl   $0x28c,0x4(%esp)
f0101c5a:	00 
f0101c5b:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0101c62:	e8 26 e5 ff ff       	call   f010018d <_panic>
	assert(pp && pp0 == pp);
f0101c67:	39 c6                	cmp    %eax,%esi
f0101c69:	74 24                	je     f0101c8f <mem_init+0x544>
f0101c6b:	c7 44 24 0c 22 59 10 	movl   $0xf0105922,0xc(%esp)
f0101c72:	f0 
f0101c73:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0101c7a:	f0 
f0101c7b:	c7 44 24 04 8d 02 00 	movl   $0x28d,0x4(%esp)
f0101c82:	00 
f0101c83:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0101c8a:	e8 fe e4 ff ff       	call   f010018d <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101c8f:	89 f2                	mov    %esi,%edx
f0101c91:	2b 15 88 99 11 f0    	sub    0xf0119988,%edx
f0101c97:	c1 fa 03             	sar    $0x3,%edx
f0101c9a:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101c9d:	89 d0                	mov    %edx,%eax
f0101c9f:	c1 e8 0c             	shr    $0xc,%eax
f0101ca2:	3b 05 80 99 11 f0    	cmp    0xf0119980,%eax
f0101ca8:	72 20                	jb     f0101cca <mem_init+0x57f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101caa:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101cae:	c7 44 24 08 68 50 10 	movl   $0xf0105068,0x8(%esp)
f0101cb5:	f0 
f0101cb6:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0101cbd:	00 
f0101cbe:	c7 04 24 85 57 10 f0 	movl   $0xf0105785,(%esp)
f0101cc5:	e8 c3 e4 ff ff       	call   f010018d <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101cca:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101cd1:	75 11                	jne    f0101ce4 <mem_init+0x599>
f0101cd3:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101cd9:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101cdf:	80 38 00             	cmpb   $0x0,(%eax)
f0101ce2:	74 24                	je     f0101d08 <mem_init+0x5bd>
f0101ce4:	c7 44 24 0c 32 59 10 	movl   $0xf0105932,0xc(%esp)
f0101ceb:	f0 
f0101cec:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0101cf3:	f0 
f0101cf4:	c7 44 24 04 90 02 00 	movl   $0x290,0x4(%esp)
f0101cfb:	00 
f0101cfc:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0101d03:	e8 85 e4 ff ff       	call   f010018d <_panic>
f0101d08:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101d0b:	39 d0                	cmp    %edx,%eax
f0101d0d:	75 d0                	jne    f0101cdf <mem_init+0x594>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101d0f:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101d12:	89 15 60 95 11 f0    	mov    %edx,0xf0119560

	// free the pages we took
	page_free(pp0);
f0101d18:	89 34 24             	mov    %esi,(%esp)
f0101d1b:	e8 2c f7 ff ff       	call   f010144c <page_free>
	page_free(pp1);
f0101d20:	89 3c 24             	mov    %edi,(%esp)
f0101d23:	e8 24 f7 ff ff       	call   f010144c <page_free>
	page_free(pp2);
f0101d28:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d2b:	89 04 24             	mov    %eax,(%esp)
f0101d2e:	e8 19 f7 ff ff       	call   f010144c <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101d33:	a1 60 95 11 f0       	mov    0xf0119560,%eax
f0101d38:	85 c0                	test   %eax,%eax
f0101d3a:	74 09                	je     f0101d45 <mem_init+0x5fa>
		--nfree;
f0101d3c:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101d3f:	8b 00                	mov    (%eax),%eax
f0101d41:	85 c0                	test   %eax,%eax
f0101d43:	75 f7                	jne    f0101d3c <mem_init+0x5f1>
		--nfree;
	assert(nfree == 0);
f0101d45:	85 db                	test   %ebx,%ebx
f0101d47:	74 24                	je     f0101d6d <mem_init+0x622>
f0101d49:	c7 44 24 0c 3c 59 10 	movl   $0xf010593c,0xc(%esp)
f0101d50:	f0 
f0101d51:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0101d58:	f0 
f0101d59:	c7 44 24 04 9d 02 00 	movl   $0x29d,0x4(%esp)
f0101d60:	00 
f0101d61:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0101d68:	e8 20 e4 ff ff       	call   f010018d <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101d6d:	c7 04 24 f0 51 10 f0 	movl   $0xf01051f0,(%esp)
f0101d74:	e8 84 15 00 00       	call   f01032fd <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101d79:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d80:	e8 3f f6 ff ff       	call   f01013c4 <page_alloc>
f0101d85:	89 c3                	mov    %eax,%ebx
f0101d87:	85 c0                	test   %eax,%eax
f0101d89:	75 24                	jne    f0101daf <mem_init+0x664>
f0101d8b:	c7 44 24 0c 4a 58 10 	movl   $0xf010584a,0xc(%esp)
f0101d92:	f0 
f0101d93:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0101d9a:	f0 
f0101d9b:	c7 44 24 04 06 03 00 	movl   $0x306,0x4(%esp)
f0101da2:	00 
f0101da3:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0101daa:	e8 de e3 ff ff       	call   f010018d <_panic>
	assert((pp1 = page_alloc(0)));
f0101daf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101db6:	e8 09 f6 ff ff       	call   f01013c4 <page_alloc>
f0101dbb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101dbe:	85 c0                	test   %eax,%eax
f0101dc0:	75 24                	jne    f0101de6 <mem_init+0x69b>
f0101dc2:	c7 44 24 0c 60 58 10 	movl   $0xf0105860,0xc(%esp)
f0101dc9:	f0 
f0101dca:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0101dd1:	f0 
f0101dd2:	c7 44 24 04 07 03 00 	movl   $0x307,0x4(%esp)
f0101dd9:	00 
f0101dda:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0101de1:	e8 a7 e3 ff ff       	call   f010018d <_panic>
	assert((pp2 = page_alloc(0)));
f0101de6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ded:	e8 d2 f5 ff ff       	call   f01013c4 <page_alloc>
f0101df2:	89 c6                	mov    %eax,%esi
f0101df4:	85 c0                	test   %eax,%eax
f0101df6:	75 24                	jne    f0101e1c <mem_init+0x6d1>
f0101df8:	c7 44 24 0c 76 58 10 	movl   $0xf0105876,0xc(%esp)
f0101dff:	f0 
f0101e00:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0101e07:	f0 
f0101e08:	c7 44 24 04 08 03 00 	movl   $0x308,0x4(%esp)
f0101e0f:	00 
f0101e10:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0101e17:	e8 71 e3 ff ff       	call   f010018d <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101e1c:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0101e1f:	75 24                	jne    f0101e45 <mem_init+0x6fa>
f0101e21:	c7 44 24 0c 8c 58 10 	movl   $0xf010588c,0xc(%esp)
f0101e28:	f0 
f0101e29:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0101e30:	f0 
f0101e31:	c7 44 24 04 0b 03 00 	movl   $0x30b,0x4(%esp)
f0101e38:	00 
f0101e39:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0101e40:	e8 48 e3 ff ff       	call   f010018d <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101e45:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101e48:	74 04                	je     f0101e4e <mem_init+0x703>
f0101e4a:	39 c3                	cmp    %eax,%ebx
f0101e4c:	75 24                	jne    f0101e72 <mem_init+0x727>
f0101e4e:	c7 44 24 0c d0 51 10 	movl   $0xf01051d0,0xc(%esp)
f0101e55:	f0 
f0101e56:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0101e5d:	f0 
f0101e5e:	c7 44 24 04 0c 03 00 	movl   $0x30c,0x4(%esp)
f0101e65:	00 
f0101e66:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0101e6d:	e8 1b e3 ff ff       	call   f010018d <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101e72:	8b 3d 60 95 11 f0    	mov    0xf0119560,%edi
f0101e78:	89 7d c8             	mov    %edi,-0x38(%ebp)
	page_free_list = 0;
f0101e7b:	c7 05 60 95 11 f0 00 	movl   $0x0,0xf0119560
f0101e82:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101e85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e8c:	e8 33 f5 ff ff       	call   f01013c4 <page_alloc>
f0101e91:	85 c0                	test   %eax,%eax
f0101e93:	74 24                	je     f0101eb9 <mem_init+0x76e>
f0101e95:	c7 44 24 0c f5 58 10 	movl   $0xf01058f5,0xc(%esp)
f0101e9c:	f0 
f0101e9d:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0101ea4:	f0 
f0101ea5:	c7 44 24 04 13 03 00 	movl   $0x313,0x4(%esp)
f0101eac:	00 
f0101ead:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0101eb4:	e8 d4 e2 ff ff       	call   f010018d <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101eb9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101ebc:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101ec0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101ec7:	00 
f0101ec8:	a1 84 99 11 f0       	mov    0xf0119984,%eax
f0101ecd:	89 04 24             	mov    %eax,(%esp)
f0101ed0:	e8 06 f7 ff ff       	call   f01015db <page_lookup>
f0101ed5:	85 c0                	test   %eax,%eax
f0101ed7:	74 24                	je     f0101efd <mem_init+0x7b2>
f0101ed9:	c7 44 24 0c 10 52 10 	movl   $0xf0105210,0xc(%esp)
f0101ee0:	f0 
f0101ee1:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0101ee8:	f0 
f0101ee9:	c7 44 24 04 16 03 00 	movl   $0x316,0x4(%esp)
f0101ef0:	00 
f0101ef1:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0101ef8:	e8 90 e2 ff ff       	call   f010018d <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101efd:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f04:	00 
f0101f05:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101f0c:	00 
f0101f0d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f10:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101f14:	a1 84 99 11 f0       	mov    0xf0119984,%eax
f0101f19:	89 04 24             	mov    %eax,(%esp)
f0101f1c:	e8 91 f7 ff ff       	call   f01016b2 <page_insert>
f0101f21:	85 c0                	test   %eax,%eax
f0101f23:	78 24                	js     f0101f49 <mem_init+0x7fe>
f0101f25:	c7 44 24 0c 48 52 10 	movl   $0xf0105248,0xc(%esp)
f0101f2c:	f0 
f0101f2d:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0101f34:	f0 
f0101f35:	c7 44 24 04 19 03 00 	movl   $0x319,0x4(%esp)
f0101f3c:	00 
f0101f3d:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0101f44:	e8 44 e2 ff ff       	call   f010018d <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101f49:	89 1c 24             	mov    %ebx,(%esp)
f0101f4c:	e8 fb f4 ff ff       	call   f010144c <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101f51:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f58:	00 
f0101f59:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101f60:	00 
f0101f61:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f64:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101f68:	a1 84 99 11 f0       	mov    0xf0119984,%eax
f0101f6d:	89 04 24             	mov    %eax,(%esp)
f0101f70:	e8 3d f7 ff ff       	call   f01016b2 <page_insert>
f0101f75:	85 c0                	test   %eax,%eax
f0101f77:	74 24                	je     f0101f9d <mem_init+0x852>
f0101f79:	c7 44 24 0c 78 52 10 	movl   $0xf0105278,0xc(%esp)
f0101f80:	f0 
f0101f81:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0101f88:	f0 
f0101f89:	c7 44 24 04 1d 03 00 	movl   $0x31d,0x4(%esp)
f0101f90:	00 
f0101f91:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0101f98:	e8 f0 e1 ff ff       	call   f010018d <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101f9d:	8b 3d 84 99 11 f0    	mov    0xf0119984,%edi
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101fa3:	8b 15 88 99 11 f0    	mov    0xf0119988,%edx
f0101fa9:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0101fac:	8b 17                	mov    (%edi),%edx
f0101fae:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101fb4:	89 d8                	mov    %ebx,%eax
f0101fb6:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101fb9:	c1 f8 03             	sar    $0x3,%eax
f0101fbc:	c1 e0 0c             	shl    $0xc,%eax
f0101fbf:	39 c2                	cmp    %eax,%edx
f0101fc1:	74 24                	je     f0101fe7 <mem_init+0x89c>
f0101fc3:	c7 44 24 0c a8 52 10 	movl   $0xf01052a8,0xc(%esp)
f0101fca:	f0 
f0101fcb:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0101fd2:	f0 
f0101fd3:	c7 44 24 04 1e 03 00 	movl   $0x31e,0x4(%esp)
f0101fda:	00 
f0101fdb:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0101fe2:	e8 a6 e1 ff ff       	call   f010018d <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101fe7:	ba 00 00 00 00       	mov    $0x0,%edx
f0101fec:	89 f8                	mov    %edi,%eax
f0101fee:	e8 fb ee ff ff       	call   f0100eee <check_va2pa>
f0101ff3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101ff6:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101ff9:	c1 fa 03             	sar    $0x3,%edx
f0101ffc:	c1 e2 0c             	shl    $0xc,%edx
f0101fff:	39 d0                	cmp    %edx,%eax
f0102001:	74 24                	je     f0102027 <mem_init+0x8dc>
f0102003:	c7 44 24 0c d0 52 10 	movl   $0xf01052d0,0xc(%esp)
f010200a:	f0 
f010200b:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102012:	f0 
f0102013:	c7 44 24 04 1f 03 00 	movl   $0x31f,0x4(%esp)
f010201a:	00 
f010201b:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102022:	e8 66 e1 ff ff       	call   f010018d <_panic>
	assert(pp1->pp_ref == 1);
f0102027:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010202a:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010202f:	74 24                	je     f0102055 <mem_init+0x90a>
f0102031:	c7 44 24 0c 47 59 10 	movl   $0xf0105947,0xc(%esp)
f0102038:	f0 
f0102039:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102040:	f0 
f0102041:	c7 44 24 04 20 03 00 	movl   $0x320,0x4(%esp)
f0102048:	00 
f0102049:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102050:	e8 38 e1 ff ff       	call   f010018d <_panic>
	assert(pp0->pp_ref == 1);
f0102055:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010205a:	74 24                	je     f0102080 <mem_init+0x935>
f010205c:	c7 44 24 0c 58 59 10 	movl   $0xf0105958,0xc(%esp)
f0102063:	f0 
f0102064:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f010206b:	f0 
f010206c:	c7 44 24 04 21 03 00 	movl   $0x321,0x4(%esp)
f0102073:	00 
f0102074:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f010207b:	e8 0d e1 ff ff       	call   f010018d <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102080:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102087:	00 
f0102088:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010208f:	00 
f0102090:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102094:	89 3c 24             	mov    %edi,(%esp)
f0102097:	e8 16 f6 ff ff       	call   f01016b2 <page_insert>
f010209c:	85 c0                	test   %eax,%eax
f010209e:	74 24                	je     f01020c4 <mem_init+0x979>
f01020a0:	c7 44 24 0c 00 53 10 	movl   $0xf0105300,0xc(%esp)
f01020a7:	f0 
f01020a8:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f01020af:	f0 
f01020b0:	c7 44 24 04 24 03 00 	movl   $0x324,0x4(%esp)
f01020b7:	00 
f01020b8:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f01020bf:	e8 c9 e0 ff ff       	call   f010018d <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01020c4:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020c9:	a1 84 99 11 f0       	mov    0xf0119984,%eax
f01020ce:	e8 1b ee ff ff       	call   f0100eee <check_va2pa>
f01020d3:	89 f2                	mov    %esi,%edx
f01020d5:	2b 15 88 99 11 f0    	sub    0xf0119988,%edx
f01020db:	c1 fa 03             	sar    $0x3,%edx
f01020de:	c1 e2 0c             	shl    $0xc,%edx
f01020e1:	39 d0                	cmp    %edx,%eax
f01020e3:	74 24                	je     f0102109 <mem_init+0x9be>
f01020e5:	c7 44 24 0c 3c 53 10 	movl   $0xf010533c,0xc(%esp)
f01020ec:	f0 
f01020ed:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f01020f4:	f0 
f01020f5:	c7 44 24 04 25 03 00 	movl   $0x325,0x4(%esp)
f01020fc:	00 
f01020fd:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102104:	e8 84 e0 ff ff       	call   f010018d <_panic>
	assert(pp2->pp_ref == 1);
f0102109:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010210e:	74 24                	je     f0102134 <mem_init+0x9e9>
f0102110:	c7 44 24 0c 69 59 10 	movl   $0xf0105969,0xc(%esp)
f0102117:	f0 
f0102118:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f010211f:	f0 
f0102120:	c7 44 24 04 26 03 00 	movl   $0x326,0x4(%esp)
f0102127:	00 
f0102128:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f010212f:	e8 59 e0 ff ff       	call   f010018d <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102134:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010213b:	e8 84 f2 ff ff       	call   f01013c4 <page_alloc>
f0102140:	85 c0                	test   %eax,%eax
f0102142:	74 24                	je     f0102168 <mem_init+0xa1d>
f0102144:	c7 44 24 0c f5 58 10 	movl   $0xf01058f5,0xc(%esp)
f010214b:	f0 
f010214c:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102153:	f0 
f0102154:	c7 44 24 04 29 03 00 	movl   $0x329,0x4(%esp)
f010215b:	00 
f010215c:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102163:	e8 25 e0 ff ff       	call   f010018d <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102168:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010216f:	00 
f0102170:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102177:	00 
f0102178:	89 74 24 04          	mov    %esi,0x4(%esp)
f010217c:	a1 84 99 11 f0       	mov    0xf0119984,%eax
f0102181:	89 04 24             	mov    %eax,(%esp)
f0102184:	e8 29 f5 ff ff       	call   f01016b2 <page_insert>
f0102189:	85 c0                	test   %eax,%eax
f010218b:	74 24                	je     f01021b1 <mem_init+0xa66>
f010218d:	c7 44 24 0c 00 53 10 	movl   $0xf0105300,0xc(%esp)
f0102194:	f0 
f0102195:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f010219c:	f0 
f010219d:	c7 44 24 04 2c 03 00 	movl   $0x32c,0x4(%esp)
f01021a4:	00 
f01021a5:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f01021ac:	e8 dc df ff ff       	call   f010018d <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01021b1:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021b6:	a1 84 99 11 f0       	mov    0xf0119984,%eax
f01021bb:	e8 2e ed ff ff       	call   f0100eee <check_va2pa>
f01021c0:	89 f2                	mov    %esi,%edx
f01021c2:	2b 15 88 99 11 f0    	sub    0xf0119988,%edx
f01021c8:	c1 fa 03             	sar    $0x3,%edx
f01021cb:	c1 e2 0c             	shl    $0xc,%edx
f01021ce:	39 d0                	cmp    %edx,%eax
f01021d0:	74 24                	je     f01021f6 <mem_init+0xaab>
f01021d2:	c7 44 24 0c 3c 53 10 	movl   $0xf010533c,0xc(%esp)
f01021d9:	f0 
f01021da:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f01021e1:	f0 
f01021e2:	c7 44 24 04 2d 03 00 	movl   $0x32d,0x4(%esp)
f01021e9:	00 
f01021ea:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f01021f1:	e8 97 df ff ff       	call   f010018d <_panic>
	assert(pp2->pp_ref == 1);
f01021f6:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01021fb:	74 24                	je     f0102221 <mem_init+0xad6>
f01021fd:	c7 44 24 0c 69 59 10 	movl   $0xf0105969,0xc(%esp)
f0102204:	f0 
f0102205:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f010220c:	f0 
f010220d:	c7 44 24 04 2e 03 00 	movl   $0x32e,0x4(%esp)
f0102214:	00 
f0102215:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f010221c:	e8 6c df ff ff       	call   f010018d <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0102221:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102228:	e8 97 f1 ff ff       	call   f01013c4 <page_alloc>
f010222d:	85 c0                	test   %eax,%eax
f010222f:	74 24                	je     f0102255 <mem_init+0xb0a>
f0102231:	c7 44 24 0c f5 58 10 	movl   $0xf01058f5,0xc(%esp)
f0102238:	f0 
f0102239:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102240:	f0 
f0102241:	c7 44 24 04 32 03 00 	movl   $0x332,0x4(%esp)
f0102248:	00 
f0102249:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102250:	e8 38 df ff ff       	call   f010018d <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0102255:	8b 15 84 99 11 f0    	mov    0xf0119984,%edx
f010225b:	8b 02                	mov    (%edx),%eax
f010225d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102262:	89 c1                	mov    %eax,%ecx
f0102264:	c1 e9 0c             	shr    $0xc,%ecx
f0102267:	3b 0d 80 99 11 f0    	cmp    0xf0119980,%ecx
f010226d:	72 20                	jb     f010228f <mem_init+0xb44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010226f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102273:	c7 44 24 08 68 50 10 	movl   $0xf0105068,0x8(%esp)
f010227a:	f0 
f010227b:	c7 44 24 04 35 03 00 	movl   $0x335,0x4(%esp)
f0102282:	00 
f0102283:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f010228a:	e8 fe de ff ff       	call   f010018d <_panic>
	return (void *)(pa + KERNBASE);
f010228f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102294:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102297:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010229e:	00 
f010229f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01022a6:	00 
f01022a7:	89 14 24             	mov    %edx,(%esp)
f01022aa:	e8 f6 f1 ff ff       	call   f01014a5 <pgdir_walk>
f01022af:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01022b2:	83 c2 04             	add    $0x4,%edx
f01022b5:	39 d0                	cmp    %edx,%eax
f01022b7:	74 24                	je     f01022dd <mem_init+0xb92>
f01022b9:	c7 44 24 0c 6c 53 10 	movl   $0xf010536c,0xc(%esp)
f01022c0:	f0 
f01022c1:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f01022c8:	f0 
f01022c9:	c7 44 24 04 36 03 00 	movl   $0x336,0x4(%esp)
f01022d0:	00 
f01022d1:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f01022d8:	e8 b0 de ff ff       	call   f010018d <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01022dd:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01022e4:	00 
f01022e5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01022ec:	00 
f01022ed:	89 74 24 04          	mov    %esi,0x4(%esp)
f01022f1:	a1 84 99 11 f0       	mov    0xf0119984,%eax
f01022f6:	89 04 24             	mov    %eax,(%esp)
f01022f9:	e8 b4 f3 ff ff       	call   f01016b2 <page_insert>
f01022fe:	85 c0                	test   %eax,%eax
f0102300:	74 24                	je     f0102326 <mem_init+0xbdb>
f0102302:	c7 44 24 0c ac 53 10 	movl   $0xf01053ac,0xc(%esp)
f0102309:	f0 
f010230a:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102311:	f0 
f0102312:	c7 44 24 04 39 03 00 	movl   $0x339,0x4(%esp)
f0102319:	00 
f010231a:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102321:	e8 67 de ff ff       	call   f010018d <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102326:	8b 3d 84 99 11 f0    	mov    0xf0119984,%edi
f010232c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102331:	89 f8                	mov    %edi,%eax
f0102333:	e8 b6 eb ff ff       	call   f0100eee <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102338:	89 f2                	mov    %esi,%edx
f010233a:	2b 15 88 99 11 f0    	sub    0xf0119988,%edx
f0102340:	c1 fa 03             	sar    $0x3,%edx
f0102343:	c1 e2 0c             	shl    $0xc,%edx
f0102346:	39 d0                	cmp    %edx,%eax
f0102348:	74 24                	je     f010236e <mem_init+0xc23>
f010234a:	c7 44 24 0c 3c 53 10 	movl   $0xf010533c,0xc(%esp)
f0102351:	f0 
f0102352:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102359:	f0 
f010235a:	c7 44 24 04 3a 03 00 	movl   $0x33a,0x4(%esp)
f0102361:	00 
f0102362:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102369:	e8 1f de ff ff       	call   f010018d <_panic>
	assert(pp2->pp_ref == 1);
f010236e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102373:	74 24                	je     f0102399 <mem_init+0xc4e>
f0102375:	c7 44 24 0c 69 59 10 	movl   $0xf0105969,0xc(%esp)
f010237c:	f0 
f010237d:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102384:	f0 
f0102385:	c7 44 24 04 3b 03 00 	movl   $0x33b,0x4(%esp)
f010238c:	00 
f010238d:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102394:	e8 f4 dd ff ff       	call   f010018d <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102399:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01023a0:	00 
f01023a1:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01023a8:	00 
f01023a9:	89 3c 24             	mov    %edi,(%esp)
f01023ac:	e8 f4 f0 ff ff       	call   f01014a5 <pgdir_walk>
f01023b1:	f6 00 04             	testb  $0x4,(%eax)
f01023b4:	75 24                	jne    f01023da <mem_init+0xc8f>
f01023b6:	c7 44 24 0c ec 53 10 	movl   $0xf01053ec,0xc(%esp)
f01023bd:	f0 
f01023be:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f01023c5:	f0 
f01023c6:	c7 44 24 04 3c 03 00 	movl   $0x33c,0x4(%esp)
f01023cd:	00 
f01023ce:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f01023d5:	e8 b3 dd ff ff       	call   f010018d <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01023da:	a1 84 99 11 f0       	mov    0xf0119984,%eax
f01023df:	f6 00 04             	testb  $0x4,(%eax)
f01023e2:	75 24                	jne    f0102408 <mem_init+0xcbd>
f01023e4:	c7 44 24 0c 7a 59 10 	movl   $0xf010597a,0xc(%esp)
f01023eb:	f0 
f01023ec:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f01023f3:	f0 
f01023f4:	c7 44 24 04 3d 03 00 	movl   $0x33d,0x4(%esp)
f01023fb:	00 
f01023fc:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102403:	e8 85 dd ff ff       	call   f010018d <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102408:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010240f:	00 
f0102410:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0102417:	00 
f0102418:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010241c:	89 04 24             	mov    %eax,(%esp)
f010241f:	e8 8e f2 ff ff       	call   f01016b2 <page_insert>
f0102424:	85 c0                	test   %eax,%eax
f0102426:	78 24                	js     f010244c <mem_init+0xd01>
f0102428:	c7 44 24 0c 20 54 10 	movl   $0xf0105420,0xc(%esp)
f010242f:	f0 
f0102430:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102437:	f0 
f0102438:	c7 44 24 04 40 03 00 	movl   $0x340,0x4(%esp)
f010243f:	00 
f0102440:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102447:	e8 41 dd ff ff       	call   f010018d <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010244c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102453:	00 
f0102454:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010245b:	00 
f010245c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010245f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102463:	a1 84 99 11 f0       	mov    0xf0119984,%eax
f0102468:	89 04 24             	mov    %eax,(%esp)
f010246b:	e8 42 f2 ff ff       	call   f01016b2 <page_insert>
f0102470:	85 c0                	test   %eax,%eax
f0102472:	74 24                	je     f0102498 <mem_init+0xd4d>
f0102474:	c7 44 24 0c 58 54 10 	movl   $0xf0105458,0xc(%esp)
f010247b:	f0 
f010247c:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102483:	f0 
f0102484:	c7 44 24 04 43 03 00 	movl   $0x343,0x4(%esp)
f010248b:	00 
f010248c:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102493:	e8 f5 dc ff ff       	call   f010018d <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102498:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010249f:	00 
f01024a0:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01024a7:	00 
f01024a8:	a1 84 99 11 f0       	mov    0xf0119984,%eax
f01024ad:	89 04 24             	mov    %eax,(%esp)
f01024b0:	e8 f0 ef ff ff       	call   f01014a5 <pgdir_walk>
f01024b5:	f6 00 04             	testb  $0x4,(%eax)
f01024b8:	74 24                	je     f01024de <mem_init+0xd93>
f01024ba:	c7 44 24 0c 94 54 10 	movl   $0xf0105494,0xc(%esp)
f01024c1:	f0 
f01024c2:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f01024c9:	f0 
f01024ca:	c7 44 24 04 44 03 00 	movl   $0x344,0x4(%esp)
f01024d1:	00 
f01024d2:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f01024d9:	e8 af dc ff ff       	call   f010018d <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01024de:	8b 3d 84 99 11 f0    	mov    0xf0119984,%edi
f01024e4:	ba 00 00 00 00       	mov    $0x0,%edx
f01024e9:	89 f8                	mov    %edi,%eax
f01024eb:	e8 fe e9 ff ff       	call   f0100eee <check_va2pa>
f01024f0:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01024f3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024f6:	2b 05 88 99 11 f0    	sub    0xf0119988,%eax
f01024fc:	c1 f8 03             	sar    $0x3,%eax
f01024ff:	c1 e0 0c             	shl    $0xc,%eax
f0102502:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102505:	74 24                	je     f010252b <mem_init+0xde0>
f0102507:	c7 44 24 0c cc 54 10 	movl   $0xf01054cc,0xc(%esp)
f010250e:	f0 
f010250f:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102516:	f0 
f0102517:	c7 44 24 04 47 03 00 	movl   $0x347,0x4(%esp)
f010251e:	00 
f010251f:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102526:	e8 62 dc ff ff       	call   f010018d <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010252b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102530:	89 f8                	mov    %edi,%eax
f0102532:	e8 b7 e9 ff ff       	call   f0100eee <check_va2pa>
f0102537:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010253a:	74 24                	je     f0102560 <mem_init+0xe15>
f010253c:	c7 44 24 0c f8 54 10 	movl   $0xf01054f8,0xc(%esp)
f0102543:	f0 
f0102544:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f010254b:	f0 
f010254c:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f0102553:	00 
f0102554:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f010255b:	e8 2d dc ff ff       	call   f010018d <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102560:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102563:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f0102568:	74 24                	je     f010258e <mem_init+0xe43>
f010256a:	c7 44 24 0c 90 59 10 	movl   $0xf0105990,0xc(%esp)
f0102571:	f0 
f0102572:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102579:	f0 
f010257a:	c7 44 24 04 4a 03 00 	movl   $0x34a,0x4(%esp)
f0102581:	00 
f0102582:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102589:	e8 ff db ff ff       	call   f010018d <_panic>
	assert(pp2->pp_ref == 0);
f010258e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102593:	74 24                	je     f01025b9 <mem_init+0xe6e>
f0102595:	c7 44 24 0c a1 59 10 	movl   $0xf01059a1,0xc(%esp)
f010259c:	f0 
f010259d:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f01025a4:	f0 
f01025a5:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f01025ac:	00 
f01025ad:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f01025b4:	e8 d4 db ff ff       	call   f010018d <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01025b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01025c0:	e8 ff ed ff ff       	call   f01013c4 <page_alloc>
f01025c5:	85 c0                	test   %eax,%eax
f01025c7:	74 04                	je     f01025cd <mem_init+0xe82>
f01025c9:	39 c6                	cmp    %eax,%esi
f01025cb:	74 24                	je     f01025f1 <mem_init+0xea6>
f01025cd:	c7 44 24 0c 28 55 10 	movl   $0xf0105528,0xc(%esp)
f01025d4:	f0 
f01025d5:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f01025dc:	f0 
f01025dd:	c7 44 24 04 4e 03 00 	movl   $0x34e,0x4(%esp)
f01025e4:	00 
f01025e5:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f01025ec:	e8 9c db ff ff       	call   f010018d <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01025f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01025f8:	00 
f01025f9:	a1 84 99 11 f0       	mov    0xf0119984,%eax
f01025fe:	89 04 24             	mov    %eax,(%esp)
f0102601:	e8 58 f0 ff ff       	call   f010165e <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102606:	8b 3d 84 99 11 f0    	mov    0xf0119984,%edi
f010260c:	ba 00 00 00 00       	mov    $0x0,%edx
f0102611:	89 f8                	mov    %edi,%eax
f0102613:	e8 d6 e8 ff ff       	call   f0100eee <check_va2pa>
f0102618:	83 f8 ff             	cmp    $0xffffffff,%eax
f010261b:	74 24                	je     f0102641 <mem_init+0xef6>
f010261d:	c7 44 24 0c 4c 55 10 	movl   $0xf010554c,0xc(%esp)
f0102624:	f0 
f0102625:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f010262c:	f0 
f010262d:	c7 44 24 04 52 03 00 	movl   $0x352,0x4(%esp)
f0102634:	00 
f0102635:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f010263c:	e8 4c db ff ff       	call   f010018d <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102641:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102646:	89 f8                	mov    %edi,%eax
f0102648:	e8 a1 e8 ff ff       	call   f0100eee <check_va2pa>
f010264d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102650:	2b 15 88 99 11 f0    	sub    0xf0119988,%edx
f0102656:	c1 fa 03             	sar    $0x3,%edx
f0102659:	c1 e2 0c             	shl    $0xc,%edx
f010265c:	39 d0                	cmp    %edx,%eax
f010265e:	74 24                	je     f0102684 <mem_init+0xf39>
f0102660:	c7 44 24 0c f8 54 10 	movl   $0xf01054f8,0xc(%esp)
f0102667:	f0 
f0102668:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f010266f:	f0 
f0102670:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f0102677:	00 
f0102678:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f010267f:	e8 09 db ff ff       	call   f010018d <_panic>
	assert(pp1->pp_ref == 1);
f0102684:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102687:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010268c:	74 24                	je     f01026b2 <mem_init+0xf67>
f010268e:	c7 44 24 0c 47 59 10 	movl   $0xf0105947,0xc(%esp)
f0102695:	f0 
f0102696:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f010269d:	f0 
f010269e:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f01026a5:	00 
f01026a6:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f01026ad:	e8 db da ff ff       	call   f010018d <_panic>
	assert(pp2->pp_ref == 0);
f01026b2:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01026b7:	74 24                	je     f01026dd <mem_init+0xf92>
f01026b9:	c7 44 24 0c a1 59 10 	movl   $0xf01059a1,0xc(%esp)
f01026c0:	f0 
f01026c1:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f01026c8:	f0 
f01026c9:	c7 44 24 04 55 03 00 	movl   $0x355,0x4(%esp)
f01026d0:	00 
f01026d1:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f01026d8:	e8 b0 da ff ff       	call   f010018d <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01026dd:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01026e4:	00 
f01026e5:	89 3c 24             	mov    %edi,(%esp)
f01026e8:	e8 71 ef ff ff       	call   f010165e <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01026ed:	8b 3d 84 99 11 f0    	mov    0xf0119984,%edi
f01026f3:	ba 00 00 00 00       	mov    $0x0,%edx
f01026f8:	89 f8                	mov    %edi,%eax
f01026fa:	e8 ef e7 ff ff       	call   f0100eee <check_va2pa>
f01026ff:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102702:	74 24                	je     f0102728 <mem_init+0xfdd>
f0102704:	c7 44 24 0c 4c 55 10 	movl   $0xf010554c,0xc(%esp)
f010270b:	f0 
f010270c:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102713:	f0 
f0102714:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
f010271b:	00 
f010271c:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102723:	e8 65 da ff ff       	call   f010018d <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102728:	ba 00 10 00 00       	mov    $0x1000,%edx
f010272d:	89 f8                	mov    %edi,%eax
f010272f:	e8 ba e7 ff ff       	call   f0100eee <check_va2pa>
f0102734:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102737:	74 24                	je     f010275d <mem_init+0x1012>
f0102739:	c7 44 24 0c 70 55 10 	movl   $0xf0105570,0xc(%esp)
f0102740:	f0 
f0102741:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102748:	f0 
f0102749:	c7 44 24 04 5a 03 00 	movl   $0x35a,0x4(%esp)
f0102750:	00 
f0102751:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102758:	e8 30 da ff ff       	call   f010018d <_panic>
	assert(pp1->pp_ref == 0);
f010275d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102760:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102765:	74 24                	je     f010278b <mem_init+0x1040>
f0102767:	c7 44 24 0c b2 59 10 	movl   $0xf01059b2,0xc(%esp)
f010276e:	f0 
f010276f:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102776:	f0 
f0102777:	c7 44 24 04 5b 03 00 	movl   $0x35b,0x4(%esp)
f010277e:	00 
f010277f:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102786:	e8 02 da ff ff       	call   f010018d <_panic>
	assert(pp2->pp_ref == 0);
f010278b:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102790:	74 24                	je     f01027b6 <mem_init+0x106b>
f0102792:	c7 44 24 0c a1 59 10 	movl   $0xf01059a1,0xc(%esp)
f0102799:	f0 
f010279a:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f01027a1:	f0 
f01027a2:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f01027a9:	00 
f01027aa:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f01027b1:	e8 d7 d9 ff ff       	call   f010018d <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01027b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01027bd:	e8 02 ec ff ff       	call   f01013c4 <page_alloc>
f01027c2:	85 c0                	test   %eax,%eax
f01027c4:	74 05                	je     f01027cb <mem_init+0x1080>
f01027c6:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01027c9:	74 24                	je     f01027ef <mem_init+0x10a4>
f01027cb:	c7 44 24 0c 98 55 10 	movl   $0xf0105598,0xc(%esp)
f01027d2:	f0 
f01027d3:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f01027da:	f0 
f01027db:	c7 44 24 04 5f 03 00 	movl   $0x35f,0x4(%esp)
f01027e2:	00 
f01027e3:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f01027ea:	e8 9e d9 ff ff       	call   f010018d <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01027ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01027f6:	e8 c9 eb ff ff       	call   f01013c4 <page_alloc>
f01027fb:	85 c0                	test   %eax,%eax
f01027fd:	74 24                	je     f0102823 <mem_init+0x10d8>
f01027ff:	c7 44 24 0c f5 58 10 	movl   $0xf01058f5,0xc(%esp)
f0102806:	f0 
f0102807:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f010280e:	f0 
f010280f:	c7 44 24 04 62 03 00 	movl   $0x362,0x4(%esp)
f0102816:	00 
f0102817:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f010281e:	e8 6a d9 ff ff       	call   f010018d <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102823:	a1 84 99 11 f0       	mov    0xf0119984,%eax
f0102828:	8b 08                	mov    (%eax),%ecx
f010282a:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102830:	89 da                	mov    %ebx,%edx
f0102832:	2b 15 88 99 11 f0    	sub    0xf0119988,%edx
f0102838:	c1 fa 03             	sar    $0x3,%edx
f010283b:	c1 e2 0c             	shl    $0xc,%edx
f010283e:	39 d1                	cmp    %edx,%ecx
f0102840:	74 24                	je     f0102866 <mem_init+0x111b>
f0102842:	c7 44 24 0c a8 52 10 	movl   $0xf01052a8,0xc(%esp)
f0102849:	f0 
f010284a:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102851:	f0 
f0102852:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f0102859:	00 
f010285a:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102861:	e8 27 d9 ff ff       	call   f010018d <_panic>
	kern_pgdir[0] = 0;
f0102866:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010286c:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102871:	74 24                	je     f0102897 <mem_init+0x114c>
f0102873:	c7 44 24 0c 58 59 10 	movl   $0xf0105958,0xc(%esp)
f010287a:	f0 
f010287b:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102882:	f0 
f0102883:	c7 44 24 04 67 03 00 	movl   $0x367,0x4(%esp)
f010288a:	00 
f010288b:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102892:	e8 f6 d8 ff ff       	call   f010018d <_panic>
	pp0->pp_ref = 0;
f0102897:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010289d:	89 1c 24             	mov    %ebx,(%esp)
f01028a0:	e8 a7 eb ff ff       	call   f010144c <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01028a5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01028ac:	00 
f01028ad:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f01028b4:	00 
f01028b5:	a1 84 99 11 f0       	mov    0xf0119984,%eax
f01028ba:	89 04 24             	mov    %eax,(%esp)
f01028bd:	e8 e3 eb ff ff       	call   f01014a5 <pgdir_walk>
f01028c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01028c5:	8b 15 84 99 11 f0    	mov    0xf0119984,%edx
f01028cb:	8b 4a 04             	mov    0x4(%edx),%ecx
f01028ce:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01028d4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01028d7:	8b 0d 80 99 11 f0    	mov    0xf0119980,%ecx
f01028dd:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01028e0:	c1 ef 0c             	shr    $0xc,%edi
f01028e3:	39 cf                	cmp    %ecx,%edi
f01028e5:	72 23                	jb     f010290a <mem_init+0x11bf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01028e7:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01028ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01028ee:	c7 44 24 08 68 50 10 	movl   $0xf0105068,0x8(%esp)
f01028f5:	f0 
f01028f6:	c7 44 24 04 6e 03 00 	movl   $0x36e,0x4(%esp)
f01028fd:	00 
f01028fe:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102905:	e8 83 d8 ff ff       	call   f010018d <_panic>
	assert(ptep == ptep1 + PTX(va));
f010290a:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010290d:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f0102913:	39 f8                	cmp    %edi,%eax
f0102915:	74 24                	je     f010293b <mem_init+0x11f0>
f0102917:	c7 44 24 0c c3 59 10 	movl   $0xf01059c3,0xc(%esp)
f010291e:	f0 
f010291f:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102926:	f0 
f0102927:	c7 44 24 04 6f 03 00 	movl   $0x36f,0x4(%esp)
f010292e:	00 
f010292f:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102936:	e8 52 d8 ff ff       	call   f010018d <_panic>
	kern_pgdir[PDX(va)] = 0;
f010293b:	c7 42 04 00 00 00 00 	movl   $0x0,0x4(%edx)
	pp0->pp_ref = 0;
f0102942:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102948:	89 d8                	mov    %ebx,%eax
f010294a:	2b 05 88 99 11 f0    	sub    0xf0119988,%eax
f0102950:	c1 f8 03             	sar    $0x3,%eax
f0102953:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102956:	89 c2                	mov    %eax,%edx
f0102958:	c1 ea 0c             	shr    $0xc,%edx
f010295b:	39 d1                	cmp    %edx,%ecx
f010295d:	77 20                	ja     f010297f <mem_init+0x1234>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010295f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102963:	c7 44 24 08 68 50 10 	movl   $0xf0105068,0x8(%esp)
f010296a:	f0 
f010296b:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102972:	00 
f0102973:	c7 04 24 85 57 10 f0 	movl   $0xf0105785,(%esp)
f010297a:	e8 0e d8 ff ff       	call   f010018d <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010297f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102986:	00 
f0102987:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f010298e:	00 
	return (void *)(pa + KERNBASE);
f010298f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102994:	89 04 24             	mov    %eax,(%esp)
f0102997:	e8 58 1a 00 00       	call   f01043f4 <memset>
	page_free(pp0);
f010299c:	89 1c 24             	mov    %ebx,(%esp)
f010299f:	e8 a8 ea ff ff       	call   f010144c <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01029a4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01029ab:	00 
f01029ac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01029b3:	00 
f01029b4:	a1 84 99 11 f0       	mov    0xf0119984,%eax
f01029b9:	89 04 24             	mov    %eax,(%esp)
f01029bc:	e8 e4 ea ff ff       	call   f01014a5 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01029c1:	89 da                	mov    %ebx,%edx
f01029c3:	2b 15 88 99 11 f0    	sub    0xf0119988,%edx
f01029c9:	c1 fa 03             	sar    $0x3,%edx
f01029cc:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01029cf:	89 d0                	mov    %edx,%eax
f01029d1:	c1 e8 0c             	shr    $0xc,%eax
f01029d4:	3b 05 80 99 11 f0    	cmp    0xf0119980,%eax
f01029da:	72 20                	jb     f01029fc <mem_init+0x12b1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01029dc:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01029e0:	c7 44 24 08 68 50 10 	movl   $0xf0105068,0x8(%esp)
f01029e7:	f0 
f01029e8:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01029ef:	00 
f01029f0:	c7 04 24 85 57 10 f0 	movl   $0xf0105785,(%esp)
f01029f7:	e8 91 d7 ff ff       	call   f010018d <_panic>
	return (void *)(pa + KERNBASE);
f01029fc:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102a02:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102a05:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0102a0c:	75 11                	jne    f0102a1f <mem_init+0x12d4>
f0102a0e:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102a14:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102a1a:	f6 00 01             	testb  $0x1,(%eax)
f0102a1d:	74 24                	je     f0102a43 <mem_init+0x12f8>
f0102a1f:	c7 44 24 0c db 59 10 	movl   $0xf01059db,0xc(%esp)
f0102a26:	f0 
f0102a27:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102a2e:	f0 
f0102a2f:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0102a36:	00 
f0102a37:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102a3e:	e8 4a d7 ff ff       	call   f010018d <_panic>
f0102a43:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102a46:	39 d0                	cmp    %edx,%eax
f0102a48:	75 d0                	jne    f0102a1a <mem_init+0x12cf>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102a4a:	a1 84 99 11 f0       	mov    0xf0119984,%eax
f0102a4f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102a55:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// give free list back
	page_free_list = fl;
f0102a5b:	8b 7d c8             	mov    -0x38(%ebp),%edi
f0102a5e:	89 3d 60 95 11 f0    	mov    %edi,0xf0119560

	// free the pages we took
	page_free(pp0);
f0102a64:	89 1c 24             	mov    %ebx,(%esp)
f0102a67:	e8 e0 e9 ff ff       	call   f010144c <page_free>
	page_free(pp1);
f0102a6c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a6f:	89 04 24             	mov    %eax,(%esp)
f0102a72:	e8 d5 e9 ff ff       	call   f010144c <page_free>
	page_free(pp2);
f0102a77:	89 34 24             	mov    %esi,(%esp)
f0102a7a:	e8 cd e9 ff ff       	call   f010144c <page_free>

	cprintf("check_page() succeeded!\n");
f0102a7f:	c7 04 24 f2 59 10 f0 	movl   $0xf01059f2,(%esp)
f0102a86:	e8 72 08 00 00       	call   f01032fd <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, ROUNDUP(npages*pageSize, PGSIZE), PADDR(pages), PTE_P | PTE_U);
f0102a8b:	a1 88 99 11 f0       	mov    0xf0119988,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a90:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a95:	77 20                	ja     f0102ab7 <mem_init+0x136c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a97:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a9b:	c7 44 24 08 ac 51 10 	movl   $0xf01051ac,0x8(%esp)
f0102aa2:	f0 
f0102aa3:	c7 44 24 04 af 00 00 	movl   $0xaf,0x4(%esp)
f0102aaa:	00 
f0102aab:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102ab2:	e8 d6 d6 ff ff       	call   f010018d <_panic>
f0102ab7:	8b 15 80 99 11 f0    	mov    0xf0119980,%edx
f0102abd:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f0102ac4:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102aca:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102ad1:	00 
	return (physaddr_t)kva - KERNBASE;
f0102ad2:	05 00 00 00 10       	add    $0x10000000,%eax
f0102ad7:	89 04 24             	mov    %eax,(%esp)
f0102ada:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102adf:	a1 84 99 11 f0       	mov    0xf0119984,%eax
f0102ae4:	e8 9d ea ff ff       	call   f0101586 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ae9:	ba 00 f0 10 f0       	mov    $0xf010f000,%edx
f0102aee:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102af4:	77 20                	ja     f0102b16 <mem_init+0x13cb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102af6:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102afa:	c7 44 24 08 ac 51 10 	movl   $0xf01051ac,0x8(%esp)
f0102b01:	f0 
f0102b02:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
f0102b09:	00 
f0102b0a:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102b11:	e8 77 d6 ff ff       	call   f010018d <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102b16:	c7 45 cc 00 f0 10 00 	movl   $0x10f000,-0x34(%ebp)
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_P | PTE_W);
f0102b1d:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102b24:	00 
f0102b25:	c7 04 24 00 f0 10 00 	movl   $0x10f000,(%esp)
f0102b2c:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102b31:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f0102b36:	a1 84 99 11 f0       	mov    0xf0119984,%eax
f0102b3b:	e8 46 ea ff ff       	call   f0101586 <boot_map_region>

static __inline uint32_t
rcr4(void)
{
	uint32_t cr4;
	__asm __volatile("movl %%cr4,%0" : "=r" (cr4));
f0102b40:	0f 20 e0             	mov    %cr4,%eax
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	uint32_t cr4;
	cr4 = rcr4();
	cr4 |= CR4_PSE;
f0102b43:	83 c8 10             	or     $0x10,%eax
}

static __inline void
lcr4(uint32_t val)
{
	__asm __volatile("movl %0,%%cr4" : : "r" (val));
f0102b46:	0f 22 e0             	mov    %eax,%cr4
static void
boot_map_region_large(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	size_t numOfPage= 64;
	uintptr_t vva = va;
f0102b49:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
	physaddr_t ppa = pa;
	size_t i = 0;
	for (i = 0; i < numOfPage; ++i) 
	{
		kern_pgdir[PDX(vva)] = ppa | PTE_W | PTE_P | PTE_PS;
f0102b4e:	89 c1                	mov    %eax,%ecx
f0102b50:	c1 e9 16             	shr    $0x16,%ecx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102b53:	8d 98 00 00 00 10    	lea    0x10000000(%eax),%ebx
	uintptr_t vva = va;
	physaddr_t ppa = pa;
	size_t i = 0;
	for (i = 0; i < numOfPage; ++i) 
	{
		kern_pgdir[PDX(vva)] = ppa | PTE_W | PTE_P | PTE_PS;
f0102b59:	80 cb 83             	or     $0x83,%bl
f0102b5c:	8b 15 84 99 11 f0    	mov    0xf0119984,%edx
f0102b62:	89 1c 8a             	mov    %ebx,(%edx,%ecx,4)
	// Fill this function in
	size_t numOfPage= 64;
	uintptr_t vva = va;
	physaddr_t ppa = pa;
	size_t i = 0;
	for (i = 0; i < numOfPage; ++i) 
f0102b65:	05 00 00 40 00       	add    $0x400000,%eax
f0102b6a:	75 e2                	jne    f0102b4e <mem_init+0x1403>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102b6c:	8b 1d 84 99 11 f0    	mov    0xf0119984,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
f0102b72:	8b 3d 80 99 11 f0    	mov    0xf0119980,%edi
f0102b78:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0102b7b:	8d 04 fd ff 0f 00 00 	lea    0xfff(,%edi,8),%eax
	for (i = 0; i < n; i += PGSIZE)
f0102b82:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102b87:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102b8a:	74 7f                	je     f0102c0b <mem_init+0x14c0>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102b8c:	8b 35 88 99 11 f0    	mov    0xf0119988,%esi
f0102b92:	8d be 00 00 00 10    	lea    0x10000000(%esi),%edi
f0102b98:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102b9d:	89 d8                	mov    %ebx,%eax
f0102b9f:	e8 4a e3 ff ff       	call   f0100eee <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ba4:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102baa:	77 20                	ja     f0102bcc <mem_init+0x1481>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bac:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102bb0:	c7 44 24 08 ac 51 10 	movl   $0xf01051ac,0x8(%esp)
f0102bb7:	f0 
f0102bb8:	c7 44 24 04 b5 02 00 	movl   $0x2b5,0x4(%esp)
f0102bbf:	00 
f0102bc0:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102bc7:	e8 c1 d5 ff ff       	call   f010018d <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102bcc:	ba 00 00 00 00       	mov    $0x0,%edx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102bd1:	8d 0c 17             	lea    (%edi,%edx,1),%ecx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102bd4:	39 c1                	cmp    %eax,%ecx
f0102bd6:	74 24                	je     f0102bfc <mem_init+0x14b1>
f0102bd8:	c7 44 24 0c bc 55 10 	movl   $0xf01055bc,0xc(%esp)
f0102bdf:	f0 
f0102be0:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102be7:	f0 
f0102be8:	c7 44 24 04 b5 02 00 	movl   $0x2b5,0x4(%esp)
f0102bef:	00 
f0102bf0:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102bf7:	e8 91 d5 ff ff       	call   f010018d <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102bfc:	8d b2 00 10 00 00    	lea    0x1000(%edx),%esi
f0102c02:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f0102c05:	0f 87 58 06 00 00    	ja     f0103263 <mem_init+0x1b18>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
f0102c0b:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102c10:	89 d8                	mov    %ebx,%eax
f0102c12:	e8 ab e2 ff ff       	call   f0100ec2 <check_va2pa_large>
f0102c17:	85 c0                	test   %eax,%eax
f0102c19:	74 14                	je     f0102c2f <mem_init+0x14e4>
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);

		cprintf("large page installed!\n");
	} else {
	    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102c1b:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0102c1e:	c1 e7 0c             	shl    $0xc,%edi
f0102c21:	be 00 00 00 00       	mov    $0x0,%esi
f0102c26:	85 ff                	test   %edi,%edi
f0102c28:	75 64                	jne    f0102c8e <mem_init+0x1543>
f0102c2a:	e9 fd 05 00 00       	jmp    f010322c <mem_init+0x1ae1>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
f0102c2f:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0102c32:	c1 e7 0c             	shl    $0xc,%edi
f0102c35:	85 ff                	test   %edi,%edi
f0102c37:	74 44                	je     f0102c7d <mem_init+0x1532>
f0102c39:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102c3e:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx


	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);
f0102c44:	89 d8                	mov    %ebx,%eax
f0102c46:	e8 77 e2 ff ff       	call   f0100ec2 <check_va2pa_large>
f0102c4b:	39 c6                	cmp    %eax,%esi
f0102c4d:	74 24                	je     f0102c73 <mem_init+0x1528>
f0102c4f:	c7 44 24 0c f0 55 10 	movl   $0xf01055f0,0xc(%esp)
f0102c56:	f0 
f0102c57:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102c5e:	f0 
f0102c5f:	c7 44 24 04 bb 02 00 	movl   $0x2bb,0x4(%esp)
f0102c66:	00 
f0102c67:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102c6e:	e8 1a d5 ff ff       	call   f010018d <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
f0102c73:	81 c6 00 00 40 00    	add    $0x400000,%esi
f0102c79:	39 fe                	cmp    %edi,%esi
f0102c7b:	72 c1                	jb     f0102c3e <mem_init+0x14f3>
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);

		cprintf("large page installed!\n");
f0102c7d:	c7 04 24 0b 5a 10 f0 	movl   $0xf0105a0b,(%esp)
f0102c84:	e8 74 06 00 00       	call   f01032fd <cprintf>
f0102c89:	e9 9e 05 00 00       	jmp    f010322c <mem_init+0x1ae1>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102c8e:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);

		cprintf("large page installed!\n");
	} else {
	    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		    assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102c94:	89 d8                	mov    %ebx,%eax
f0102c96:	e8 53 e2 ff ff       	call   f0100eee <check_va2pa>
f0102c9b:	39 c6                	cmp    %eax,%esi
f0102c9d:	74 24                	je     f0102cc3 <mem_init+0x1578>
f0102c9f:	c7 44 24 0c 1c 56 10 	movl   $0xf010561c,0xc(%esp)
f0102ca6:	f0 
f0102ca7:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102cae:	f0 
f0102caf:	c7 44 24 04 c0 02 00 	movl   $0x2c0,0x4(%esp)
f0102cb6:	00 
f0102cb7:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102cbe:	e8 ca d4 ff ff       	call   f010018d <_panic>
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);

		cprintf("large page installed!\n");
	} else {
	    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102cc3:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102cc9:	39 f7                	cmp    %esi,%edi
f0102ccb:	77 c1                	ja     f0102c8e <mem_init+0x1543>
f0102ccd:	e9 5a 05 00 00       	jmp    f010322c <mem_init+0x1ae1>
		    assert(check_va2pa(pgdir, KERNBASE + i) == i);
	}

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102cd2:	39 c3                	cmp    %eax,%ebx
f0102cd4:	74 24                	je     f0102cfa <mem_init+0x15af>
f0102cd6:	c7 44 24 0c 44 56 10 	movl   $0xf0105644,0xc(%esp)
f0102cdd:	f0 
f0102cde:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102ce5:	f0 
f0102ce6:	c7 44 24 04 c5 02 00 	movl   $0x2c5,0x4(%esp)
f0102ced:	00 
f0102cee:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102cf5:	e8 93 d4 ff ff       	call   f010018d <_panic>
f0102cfa:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		    assert(check_va2pa(pgdir, KERNBASE + i) == i);
	}

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102d00:	39 f3                	cmp    %esi,%ebx
f0102d02:	0f 85 4b 05 00 00    	jne    f0103253 <mem_init+0x1b08>
f0102d08:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102d0b:	ba 00 00 80 ef       	mov    $0xef800000,%edx
f0102d10:	89 d8                	mov    %ebx,%eax
f0102d12:	e8 d7 e1 ff ff       	call   f0100eee <check_va2pa>
f0102d17:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102d1a:	74 24                	je     f0102d40 <mem_init+0x15f5>
f0102d1c:	c7 44 24 0c 8c 56 10 	movl   $0xf010568c,0xc(%esp)
f0102d23:	f0 
f0102d24:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102d2b:	f0 
f0102d2c:	c7 44 24 04 c6 02 00 	movl   $0x2c6,0x4(%esp)
f0102d33:	00 
f0102d34:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102d3b:	e8 4d d4 ff ff       	call   f010018d <_panic>
f0102d40:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102d45:	8d 90 44 fc ff ff    	lea    -0x3bc(%eax),%edx
f0102d4b:	83 fa 02             	cmp    $0x2,%edx
f0102d4e:	77 2e                	ja     f0102d7e <mem_init+0x1633>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f0102d50:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102d54:	0f 85 aa 00 00 00    	jne    f0102e04 <mem_init+0x16b9>
f0102d5a:	c7 44 24 0c 22 5a 10 	movl   $0xf0105a22,0xc(%esp)
f0102d61:	f0 
f0102d62:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102d69:	f0 
f0102d6a:	c7 44 24 04 ce 02 00 	movl   $0x2ce,0x4(%esp)
f0102d71:	00 
f0102d72:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102d79:	e8 0f d4 ff ff       	call   f010018d <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102d7e:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102d83:	76 55                	jbe    f0102dda <mem_init+0x168f>
				assert(pgdir[i] & PTE_P);
f0102d85:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102d88:	f6 c2 01             	test   $0x1,%dl
f0102d8b:	75 24                	jne    f0102db1 <mem_init+0x1666>
f0102d8d:	c7 44 24 0c 22 5a 10 	movl   $0xf0105a22,0xc(%esp)
f0102d94:	f0 
f0102d95:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102d9c:	f0 
f0102d9d:	c7 44 24 04 d2 02 00 	movl   $0x2d2,0x4(%esp)
f0102da4:	00 
f0102da5:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102dac:	e8 dc d3 ff ff       	call   f010018d <_panic>
				assert(pgdir[i] & PTE_W);
f0102db1:	f6 c2 02             	test   $0x2,%dl
f0102db4:	75 4e                	jne    f0102e04 <mem_init+0x16b9>
f0102db6:	c7 44 24 0c 33 5a 10 	movl   $0xf0105a33,0xc(%esp)
f0102dbd:	f0 
f0102dbe:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102dc5:	f0 
f0102dc6:	c7 44 24 04 d3 02 00 	movl   $0x2d3,0x4(%esp)
f0102dcd:	00 
f0102dce:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102dd5:	e8 b3 d3 ff ff       	call   f010018d <_panic>
			} else
				assert(pgdir[i] == 0);
f0102dda:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102dde:	74 24                	je     f0102e04 <mem_init+0x16b9>
f0102de0:	c7 44 24 0c 44 5a 10 	movl   $0xf0105a44,0xc(%esp)
f0102de7:	f0 
f0102de8:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102def:	f0 
f0102df0:	c7 44 24 04 d5 02 00 	movl   $0x2d5,0x4(%esp)
f0102df7:	00 
f0102df8:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102dff:	e8 89 d3 ff ff       	call   f010018d <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102e04:	83 c0 01             	add    $0x1,%eax
f0102e07:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102e0c:	0f 85 33 ff ff ff    	jne    f0102d45 <mem_init+0x15fa>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102e12:	c7 04 24 bc 56 10 f0 	movl   $0xf01056bc,(%esp)
f0102e19:	e8 df 04 00 00       	call   f01032fd <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102e1e:	a1 84 99 11 f0       	mov    0xf0119984,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e23:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e28:	77 20                	ja     f0102e4a <mem_init+0x16ff>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e2a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102e2e:	c7 44 24 08 ac 51 10 	movl   $0xf01051ac,0x8(%esp)
f0102e35:	f0 
f0102e36:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
f0102e3d:	00 
f0102e3e:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102e45:	e8 43 d3 ff ff       	call   f010018d <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102e4a:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102e4f:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102e52:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e57:	e8 30 e1 ff ff       	call   f0100f8c <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102e5c:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f0102e5f:	83 e0 f3             	and    $0xfffffff3,%eax
f0102e62:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102e67:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102e6a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102e71:	e8 4e e5 ff ff       	call   f01013c4 <page_alloc>
f0102e76:	89 c3                	mov    %eax,%ebx
f0102e78:	85 c0                	test   %eax,%eax
f0102e7a:	75 24                	jne    f0102ea0 <mem_init+0x1755>
f0102e7c:	c7 44 24 0c 4a 58 10 	movl   $0xf010584a,0xc(%esp)
f0102e83:	f0 
f0102e84:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102e8b:	f0 
f0102e8c:	c7 44 24 04 95 03 00 	movl   $0x395,0x4(%esp)
f0102e93:	00 
f0102e94:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102e9b:	e8 ed d2 ff ff       	call   f010018d <_panic>
	assert((pp1 = page_alloc(0)));
f0102ea0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ea7:	e8 18 e5 ff ff       	call   f01013c4 <page_alloc>
f0102eac:	89 c7                	mov    %eax,%edi
f0102eae:	85 c0                	test   %eax,%eax
f0102eb0:	75 24                	jne    f0102ed6 <mem_init+0x178b>
f0102eb2:	c7 44 24 0c 60 58 10 	movl   $0xf0105860,0xc(%esp)
f0102eb9:	f0 
f0102eba:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102ec1:	f0 
f0102ec2:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f0102ec9:	00 
f0102eca:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102ed1:	e8 b7 d2 ff ff       	call   f010018d <_panic>
	assert((pp2 = page_alloc(0)));
f0102ed6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102edd:	e8 e2 e4 ff ff       	call   f01013c4 <page_alloc>
f0102ee2:	89 c6                	mov    %eax,%esi
f0102ee4:	85 c0                	test   %eax,%eax
f0102ee6:	75 24                	jne    f0102f0c <mem_init+0x17c1>
f0102ee8:	c7 44 24 0c 76 58 10 	movl   $0xf0105876,0xc(%esp)
f0102eef:	f0 
f0102ef0:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102ef7:	f0 
f0102ef8:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f0102eff:	00 
f0102f00:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0102f07:	e8 81 d2 ff ff       	call   f010018d <_panic>
	page_free(pp0);
f0102f0c:	89 1c 24             	mov    %ebx,(%esp)
f0102f0f:	e8 38 e5 ff ff       	call   f010144c <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102f14:	89 f8                	mov    %edi,%eax
f0102f16:	2b 05 88 99 11 f0    	sub    0xf0119988,%eax
f0102f1c:	c1 f8 03             	sar    $0x3,%eax
f0102f1f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102f22:	89 c2                	mov    %eax,%edx
f0102f24:	c1 ea 0c             	shr    $0xc,%edx
f0102f27:	3b 15 80 99 11 f0    	cmp    0xf0119980,%edx
f0102f2d:	72 20                	jb     f0102f4f <mem_init+0x1804>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f2f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102f33:	c7 44 24 08 68 50 10 	movl   $0xf0105068,0x8(%esp)
f0102f3a:	f0 
f0102f3b:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102f42:	00 
f0102f43:	c7 04 24 85 57 10 f0 	movl   $0xf0105785,(%esp)
f0102f4a:	e8 3e d2 ff ff       	call   f010018d <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102f4f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102f56:	00 
f0102f57:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102f5e:	00 
	return (void *)(pa + KERNBASE);
f0102f5f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102f64:	89 04 24             	mov    %eax,(%esp)
f0102f67:	e8 88 14 00 00       	call   f01043f4 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102f6c:	89 f0                	mov    %esi,%eax
f0102f6e:	2b 05 88 99 11 f0    	sub    0xf0119988,%eax
f0102f74:	c1 f8 03             	sar    $0x3,%eax
f0102f77:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102f7a:	89 c2                	mov    %eax,%edx
f0102f7c:	c1 ea 0c             	shr    $0xc,%edx
f0102f7f:	3b 15 80 99 11 f0    	cmp    0xf0119980,%edx
f0102f85:	72 20                	jb     f0102fa7 <mem_init+0x185c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f87:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102f8b:	c7 44 24 08 68 50 10 	movl   $0xf0105068,0x8(%esp)
f0102f92:	f0 
f0102f93:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102f9a:	00 
f0102f9b:	c7 04 24 85 57 10 f0 	movl   $0xf0105785,(%esp)
f0102fa2:	e8 e6 d1 ff ff       	call   f010018d <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102fa7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102fae:	00 
f0102faf:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102fb6:	00 
	return (void *)(pa + KERNBASE);
f0102fb7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102fbc:	89 04 24             	mov    %eax,(%esp)
f0102fbf:	e8 30 14 00 00       	call   f01043f4 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102fc4:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102fcb:	00 
f0102fcc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102fd3:	00 
f0102fd4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102fd8:	a1 84 99 11 f0       	mov    0xf0119984,%eax
f0102fdd:	89 04 24             	mov    %eax,(%esp)
f0102fe0:	e8 cd e6 ff ff       	call   f01016b2 <page_insert>
	assert(pp1->pp_ref == 1);
f0102fe5:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102fea:	74 24                	je     f0103010 <mem_init+0x18c5>
f0102fec:	c7 44 24 0c 47 59 10 	movl   $0xf0105947,0xc(%esp)
f0102ff3:	f0 
f0102ff4:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0102ffb:	f0 
f0102ffc:	c7 44 24 04 9c 03 00 	movl   $0x39c,0x4(%esp)
f0103003:	00 
f0103004:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f010300b:	e8 7d d1 ff ff       	call   f010018d <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103010:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103017:	01 01 01 
f010301a:	74 24                	je     f0103040 <mem_init+0x18f5>
f010301c:	c7 44 24 0c dc 56 10 	movl   $0xf01056dc,0xc(%esp)
f0103023:	f0 
f0103024:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f010302b:	f0 
f010302c:	c7 44 24 04 9d 03 00 	movl   $0x39d,0x4(%esp)
f0103033:	00 
f0103034:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f010303b:	e8 4d d1 ff ff       	call   f010018d <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0103040:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103047:	00 
f0103048:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010304f:	00 
f0103050:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103054:	a1 84 99 11 f0       	mov    0xf0119984,%eax
f0103059:	89 04 24             	mov    %eax,(%esp)
f010305c:	e8 51 e6 ff ff       	call   f01016b2 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103061:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0103068:	02 02 02 
f010306b:	74 24                	je     f0103091 <mem_init+0x1946>
f010306d:	c7 44 24 0c 00 57 10 	movl   $0xf0105700,0xc(%esp)
f0103074:	f0 
f0103075:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f010307c:	f0 
f010307d:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f0103084:	00 
f0103085:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f010308c:	e8 fc d0 ff ff       	call   f010018d <_panic>
	assert(pp2->pp_ref == 1);
f0103091:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103096:	74 24                	je     f01030bc <mem_init+0x1971>
f0103098:	c7 44 24 0c 69 59 10 	movl   $0xf0105969,0xc(%esp)
f010309f:	f0 
f01030a0:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f01030a7:	f0 
f01030a8:	c7 44 24 04 a0 03 00 	movl   $0x3a0,0x4(%esp)
f01030af:	00 
f01030b0:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f01030b7:	e8 d1 d0 ff ff       	call   f010018d <_panic>
	assert(pp1->pp_ref == 0);
f01030bc:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01030c1:	74 24                	je     f01030e7 <mem_init+0x199c>
f01030c3:	c7 44 24 0c b2 59 10 	movl   $0xf01059b2,0xc(%esp)
f01030ca:	f0 
f01030cb:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f01030d2:	f0 
f01030d3:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f01030da:	00 
f01030db:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f01030e2:	e8 a6 d0 ff ff       	call   f010018d <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01030e7:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01030ee:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01030f1:	89 f0                	mov    %esi,%eax
f01030f3:	2b 05 88 99 11 f0    	sub    0xf0119988,%eax
f01030f9:	c1 f8 03             	sar    $0x3,%eax
f01030fc:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01030ff:	89 c2                	mov    %eax,%edx
f0103101:	c1 ea 0c             	shr    $0xc,%edx
f0103104:	3b 15 80 99 11 f0    	cmp    0xf0119980,%edx
f010310a:	72 20                	jb     f010312c <mem_init+0x19e1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010310c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103110:	c7 44 24 08 68 50 10 	movl   $0xf0105068,0x8(%esp)
f0103117:	f0 
f0103118:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f010311f:	00 
f0103120:	c7 04 24 85 57 10 f0 	movl   $0xf0105785,(%esp)
f0103127:	e8 61 d0 ff ff       	call   f010018d <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010312c:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103133:	03 03 03 
f0103136:	74 24                	je     f010315c <mem_init+0x1a11>
f0103138:	c7 44 24 0c 24 57 10 	movl   $0xf0105724,0xc(%esp)
f010313f:	f0 
f0103140:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0103147:	f0 
f0103148:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f010314f:	00 
f0103150:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0103157:	e8 31 d0 ff ff       	call   f010018d <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010315c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103163:	00 
f0103164:	a1 84 99 11 f0       	mov    0xf0119984,%eax
f0103169:	89 04 24             	mov    %eax,(%esp)
f010316c:	e8 ed e4 ff ff       	call   f010165e <page_remove>
	assert(pp2->pp_ref == 0);
f0103171:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0103176:	74 24                	je     f010319c <mem_init+0x1a51>
f0103178:	c7 44 24 0c a1 59 10 	movl   $0xf01059a1,0xc(%esp)
f010317f:	f0 
f0103180:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f0103187:	f0 
f0103188:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f010318f:	00 
f0103190:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f0103197:	e8 f1 cf ff ff       	call   f010018d <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010319c:	a1 84 99 11 f0       	mov    0xf0119984,%eax
f01031a1:	8b 08                	mov    (%eax),%ecx
f01031a3:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01031a9:	89 da                	mov    %ebx,%edx
f01031ab:	2b 15 88 99 11 f0    	sub    0xf0119988,%edx
f01031b1:	c1 fa 03             	sar    $0x3,%edx
f01031b4:	c1 e2 0c             	shl    $0xc,%edx
f01031b7:	39 d1                	cmp    %edx,%ecx
f01031b9:	74 24                	je     f01031df <mem_init+0x1a94>
f01031bb:	c7 44 24 0c a8 52 10 	movl   $0xf01052a8,0xc(%esp)
f01031c2:	f0 
f01031c3:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f01031ca:	f0 
f01031cb:	c7 44 24 04 a8 03 00 	movl   $0x3a8,0x4(%esp)
f01031d2:	00 
f01031d3:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f01031da:	e8 ae cf ff ff       	call   f010018d <_panic>
	kern_pgdir[0] = 0;
f01031df:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01031e5:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01031ea:	74 24                	je     f0103210 <mem_init+0x1ac5>
f01031ec:	c7 44 24 0c 58 59 10 	movl   $0xf0105958,0xc(%esp)
f01031f3:	f0 
f01031f4:	c7 44 24 08 9f 57 10 	movl   $0xf010579f,0x8(%esp)
f01031fb:	f0 
f01031fc:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f0103203:	00 
f0103204:	c7 04 24 79 57 10 f0 	movl   $0xf0105779,(%esp)
f010320b:	e8 7d cf ff ff       	call   f010018d <_panic>
	pp0->pp_ref = 0;
f0103210:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0103216:	89 1c 24             	mov    %ebx,(%esp)
f0103219:	e8 2e e2 ff ff       	call   f010144c <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f010321e:	c7 04 24 50 57 10 f0 	movl   $0xf0105750,(%esp)
f0103225:	e8 d3 00 00 00       	call   f01032fd <cprintf>
f010322a:	eb 4b                	jmp    f0103277 <mem_init+0x1b2c>
		    assert(check_va2pa(pgdir, KERNBASE + i) == i);
	}

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010322c:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f0103231:	89 d8                	mov    %ebx,%eax
f0103233:	e8 b6 dc ff ff       	call   f0100eee <check_va2pa>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0103238:	be 00 70 11 00       	mov    $0x117000,%esi
f010323d:	bf 00 80 bf df       	mov    $0xdfbf8000,%edi
f0103242:	81 ef 00 f0 10 f0    	sub    $0xf010f000,%edi
f0103248:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f010324b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f010324e:	e9 7f fa ff ff       	jmp    f0102cd2 <mem_init+0x1587>
f0103253:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
		    assert(check_va2pa(pgdir, KERNBASE + i) == i);
	}

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0103256:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103259:	e8 90 dc ff ff       	call   f0100eee <check_va2pa>
f010325e:	e9 6f fa ff ff       	jmp    f0102cd2 <mem_init+0x1587>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0103263:	81 ea 00 f0 ff 10    	sub    $0x10fff000,%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0103269:	89 d8                	mov    %ebx,%eax
f010326b:	e8 7e dc ff ff       	call   f0100eee <check_va2pa>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0103270:	89 f2                	mov    %esi,%edx
f0103272:	e9 5a f9 ff ff       	jmp    f0102bd1 <mem_init+0x1486>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0103277:	83 c4 3c             	add    $0x3c,%esp
f010327a:	5b                   	pop    %ebx
f010327b:	5e                   	pop    %esi
f010327c:	5f                   	pop    %edi
f010327d:	5d                   	pop    %ebp
f010327e:	c3                   	ret    
	...

f0103280 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103280:	55                   	push   %ebp
f0103281:	89 e5                	mov    %esp,%ebp
void
mc146818_write(unsigned reg, unsigned datum)
{
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103283:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103287:	ba 70 00 00 00       	mov    $0x70,%edx
f010328c:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010328d:	b2 71                	mov    $0x71,%dl
f010328f:	ec                   	in     (%dx),%al

unsigned
mc146818_read(unsigned reg)
{
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103290:	0f b6 c0             	movzbl %al,%eax
}
f0103293:	5d                   	pop    %ebp
f0103294:	c3                   	ret    

f0103295 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103295:	55                   	push   %ebp
f0103296:	89 e5                	mov    %esp,%ebp
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103298:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010329c:	ba 70 00 00 00       	mov    $0x70,%edx
f01032a1:	ee                   	out    %al,(%dx)
f01032a2:	0f b6 45 0c          	movzbl 0xc(%ebp),%eax
f01032a6:	b2 71                	mov    $0x71,%dl
f01032a8:	ee                   	out    %al,(%dx)
f01032a9:	5d                   	pop    %ebp
f01032aa:	c3                   	ret    
	...

f01032ac <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01032ac:	55                   	push   %ebp
f01032ad:	89 e5                	mov    %esp,%ebp
f01032af:	53                   	push   %ebx
f01032b0:	83 ec 14             	sub    $0x14,%esp
f01032b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	cputchar(ch);
f01032b6:	8b 45 08             	mov    0x8(%ebp),%eax
f01032b9:	89 04 24             	mov    %eax,(%esp)
f01032bc:	e8 3d d4 ff ff       	call   f01006fe <cputchar>
    (*cnt)++;
f01032c1:	83 03 01             	addl   $0x1,(%ebx)
}
f01032c4:	83 c4 14             	add    $0x14,%esp
f01032c7:	5b                   	pop    %ebx
f01032c8:	5d                   	pop    %ebp
f01032c9:	c3                   	ret    

f01032ca <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01032ca:	55                   	push   %ebp
f01032cb:	89 e5                	mov    %esp,%ebp
f01032cd:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01032d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01032d7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032da:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01032de:	8b 45 08             	mov    0x8(%ebp),%eax
f01032e1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01032e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01032e8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01032ec:	c7 04 24 ac 32 10 f0 	movl   $0xf01032ac,(%esp)
f01032f3:	e8 33 05 00 00       	call   f010382b <vprintfmt>
	return cnt;
}
f01032f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01032fb:	c9                   	leave  
f01032fc:	c3                   	ret    

f01032fd <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01032fd:	55                   	push   %ebp
f01032fe:	89 e5                	mov    %esp,%ebp
f0103300:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103303:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103306:	89 44 24 04          	mov    %eax,0x4(%esp)
f010330a:	8b 45 08             	mov    0x8(%ebp),%eax
f010330d:	89 04 24             	mov    %eax,(%esp)
f0103310:	e8 b5 ff ff ff       	call   f01032ca <vcprintf>
	va_end(ap);

	return cnt;
}
f0103315:	c9                   	leave  
f0103316:	c3                   	ret    
	...

f0103320 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103320:	55                   	push   %ebp
f0103321:	89 e5                	mov    %esp,%ebp
f0103323:	57                   	push   %edi
f0103324:	56                   	push   %esi
f0103325:	53                   	push   %ebx
f0103326:	83 ec 10             	sub    $0x10,%esp
f0103329:	89 c6                	mov    %eax,%esi
f010332b:	89 55 e8             	mov    %edx,-0x18(%ebp)
f010332e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0103331:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103334:	8b 1a                	mov    (%edx),%ebx
f0103336:	8b 09                	mov    (%ecx),%ecx
f0103338:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010333b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	
	while (l <= r) {
f0103342:	eb 77                	jmp    f01033bb <stab_binsearch+0x9b>
		int true_m = (l + r) / 2, m = true_m;
f0103344:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103347:	01 d8                	add    %ebx,%eax
f0103349:	b9 02 00 00 00       	mov    $0x2,%ecx
f010334e:	99                   	cltd   
f010334f:	f7 f9                	idiv   %ecx
f0103351:	89 c1                	mov    %eax,%ecx
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103353:	eb 01                	jmp    f0103356 <stab_binsearch+0x36>
			m--;
f0103355:	49                   	dec    %ecx
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103356:	39 d9                	cmp    %ebx,%ecx
f0103358:	7c 1d                	jl     f0103377 <stab_binsearch+0x57>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f010335a:	6b d1 0c             	imul   $0xc,%ecx,%edx
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010335d:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f0103362:	39 fa                	cmp    %edi,%edx
f0103364:	75 ef                	jne    f0103355 <stab_binsearch+0x35>
f0103366:	89 4d ec             	mov    %ecx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103369:	6b d1 0c             	imul   $0xc,%ecx,%edx
f010336c:	8b 54 16 08          	mov    0x8(%esi,%edx,1),%edx
f0103370:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103373:	73 18                	jae    f010338d <stab_binsearch+0x6d>
f0103375:	eb 05                	jmp    f010337c <stab_binsearch+0x5c>
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103377:	8d 58 01             	lea    0x1(%eax),%ebx
			continue;
f010337a:	eb 3f                	jmp    f01033bb <stab_binsearch+0x9b>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f010337c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010337f:	89 0a                	mov    %ecx,(%edx)
			l = true_m + 1;
f0103381:	8d 58 01             	lea    0x1(%eax),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103384:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f010338b:	eb 2e                	jmp    f01033bb <stab_binsearch+0x9b>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010338d:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0103390:	73 15                	jae    f01033a7 <stab_binsearch+0x87>
			*region_right = m - 1;
f0103392:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103395:	49                   	dec    %ecx
f0103396:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103399:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010339c:	89 08                	mov    %ecx,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010339e:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f01033a5:	eb 14                	jmp    f01033bb <stab_binsearch+0x9b>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01033a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01033aa:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01033ad:	89 02                	mov    %eax,(%edx)
			l = m;
			addr++;
f01033af:	ff 45 0c             	incl   0xc(%ebp)
f01033b2:	89 cb                	mov    %ecx,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01033b4:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f01033bb:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01033be:	7e 84                	jle    f0103344 <stab_binsearch+0x24>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01033c0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f01033c4:	75 0d                	jne    f01033d3 <stab_binsearch+0xb3>
		*region_right = *region_left - 1;
f01033c6:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01033c9:	8b 02                	mov    (%edx),%eax
f01033cb:	48                   	dec    %eax
f01033cc:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01033cf:	89 01                	mov    %eax,(%ecx)
f01033d1:	eb 22                	jmp    f01033f5 <stab_binsearch+0xd5>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01033d3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01033d6:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f01033d8:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01033db:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01033dd:	eb 01                	jmp    f01033e0 <stab_binsearch+0xc0>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01033df:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01033e0:	39 c1                	cmp    %eax,%ecx
f01033e2:	7d 0c                	jge    f01033f0 <stab_binsearch+0xd0>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01033e4:	6b d0 0c             	imul   $0xc,%eax,%edx
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f01033e7:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f01033ec:	39 fa                	cmp    %edi,%edx
f01033ee:	75 ef                	jne    f01033df <stab_binsearch+0xbf>
		     l--)
			/* do nothing */;
		*region_left = l;
f01033f0:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01033f3:	89 02                	mov    %eax,(%edx)
	}
}
f01033f5:	83 c4 10             	add    $0x10,%esp
f01033f8:	5b                   	pop    %ebx
f01033f9:	5e                   	pop    %esi
f01033fa:	5f                   	pop    %edi
f01033fb:	5d                   	pop    %ebp
f01033fc:	c3                   	ret    

f01033fd <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01033fd:	55                   	push   %ebp
f01033fe:	89 e5                	mov    %esp,%ebp
f0103400:	83 ec 58             	sub    $0x58,%esp
f0103403:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103406:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103409:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010340c:	8b 75 08             	mov    0x8(%ebp),%esi
f010340f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103412:	c7 03 52 5a 10 f0    	movl   $0xf0105a52,(%ebx)
	info->eip_line = 0;
f0103418:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f010341f:	c7 43 08 52 5a 10 f0 	movl   $0xf0105a52,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103426:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010342d:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103430:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103437:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010343d:	76 12                	jbe    f0103451 <debuginfo_eip+0x54>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010343f:	b8 fe ea 10 f0       	mov    $0xf010eafe,%eax
f0103444:	3d e5 ca 10 f0       	cmp    $0xf010cae5,%eax
f0103449:	0f 86 eb 01 00 00    	jbe    f010363a <debuginfo_eip+0x23d>
f010344f:	eb 1c                	jmp    f010346d <debuginfo_eip+0x70>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0103451:	c7 44 24 08 5c 5a 10 	movl   $0xf0105a5c,0x8(%esp)
f0103458:	f0 
f0103459:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0103460:	00 
f0103461:	c7 04 24 69 5a 10 f0 	movl   $0xf0105a69,(%esp)
f0103468:	e8 20 cd ff ff       	call   f010018d <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010346d:	80 3d fd ea 10 f0 00 	cmpb   $0x0,0xf010eafd
f0103474:	0f 85 c7 01 00 00    	jne    f0103641 <debuginfo_eip+0x244>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010347a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103481:	b8 e4 ca 10 f0       	mov    $0xf010cae4,%eax
f0103486:	2d 04 5d 10 f0       	sub    $0xf0105d04,%eax
f010348b:	c1 f8 02             	sar    $0x2,%eax
f010348e:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103494:	83 e8 01             	sub    $0x1,%eax
f0103497:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010349a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010349e:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01034a5:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01034a8:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01034ab:	b8 04 5d 10 f0       	mov    $0xf0105d04,%eax
f01034b0:	e8 6b fe ff ff       	call   f0103320 <stab_binsearch>
	if (lfile == 0)
f01034b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01034b8:	85 c0                	test   %eax,%eax
f01034ba:	0f 84 88 01 00 00    	je     f0103648 <debuginfo_eip+0x24b>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01034c0:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01034c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01034c9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01034cd:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01034d4:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01034d7:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01034da:	b8 04 5d 10 f0       	mov    $0xf0105d04,%eax
f01034df:	e8 3c fe ff ff       	call   f0103320 <stab_binsearch>

	if (lfun <= rfun) {
f01034e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01034e7:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01034ea:	39 d0                	cmp    %edx,%eax
f01034ec:	7f 3d                	jg     f010352b <debuginfo_eip+0x12e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01034ee:	6b c8 0c             	imul   $0xc,%eax,%ecx
f01034f1:	8d b9 04 5d 10 f0    	lea    -0xfefa2fc(%ecx),%edi
f01034f7:	89 7d c0             	mov    %edi,-0x40(%ebp)
f01034fa:	8b 89 04 5d 10 f0    	mov    -0xfefa2fc(%ecx),%ecx
f0103500:	bf fe ea 10 f0       	mov    $0xf010eafe,%edi
f0103505:	81 ef e5 ca 10 f0    	sub    $0xf010cae5,%edi
f010350b:	39 f9                	cmp    %edi,%ecx
f010350d:	73 09                	jae    f0103518 <debuginfo_eip+0x11b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010350f:	81 c1 e5 ca 10 f0    	add    $0xf010cae5,%ecx
f0103515:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103518:	8b 7d c0             	mov    -0x40(%ebp),%edi
f010351b:	8b 4f 08             	mov    0x8(%edi),%ecx
f010351e:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0103521:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0103523:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103526:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0103529:	eb 0f                	jmp    f010353a <debuginfo_eip+0x13d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010352b:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010352e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103531:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103534:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103537:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010353a:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0103541:	00 
f0103542:	8b 43 08             	mov    0x8(%ebx),%eax
f0103545:	89 04 24             	mov    %eax,(%esp)
f0103548:	e8 80 0e 00 00       	call   f01043cd <strfind>
f010354d:	2b 43 08             	sub    0x8(%ebx),%eax
f0103550:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs,&lline,&rline,N_SLINE,addr);
f0103553:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103557:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f010355e:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103561:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103564:	b8 04 5d 10 f0       	mov    $0xf0105d04,%eax
f0103569:	e8 b2 fd ff ff       	call   f0103320 <stab_binsearch>
	if (lline<=rline)
f010356e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103571:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0103574:	0f 8f d5 00 00 00    	jg     f010364f <debuginfo_eip+0x252>
		info->eip_line=rline;
f010357a:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010357d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103580:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103583:	39 f0                	cmp    %esi,%eax
f0103585:	7c 63                	jl     f01035ea <debuginfo_eip+0x1ed>
	       && stabs[lline].n_type != N_SOL
f0103587:	6b f8 0c             	imul   $0xc,%eax,%edi
f010358a:	81 c7 04 5d 10 f0    	add    $0xf0105d04,%edi
f0103590:	0f b6 4f 04          	movzbl 0x4(%edi),%ecx
f0103594:	80 f9 84             	cmp    $0x84,%cl
f0103597:	74 32                	je     f01035cb <debuginfo_eip+0x1ce>
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0103599:	8d 50 ff             	lea    -0x1(%eax),%edx
f010359c:	6b d2 0c             	imul   $0xc,%edx,%edx
f010359f:	81 c2 04 5d 10 f0    	add    $0xf0105d04,%edx
f01035a5:	eb 15                	jmp    f01035bc <debuginfo_eip+0x1bf>
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01035a7:	83 e8 01             	sub    $0x1,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01035aa:	39 f0                	cmp    %esi,%eax
f01035ac:	7c 3c                	jl     f01035ea <debuginfo_eip+0x1ed>
	       && stabs[lline].n_type != N_SOL
f01035ae:	89 d7                	mov    %edx,%edi
f01035b0:	83 ea 0c             	sub    $0xc,%edx
f01035b3:	0f b6 4a 10          	movzbl 0x10(%edx),%ecx
f01035b7:	80 f9 84             	cmp    $0x84,%cl
f01035ba:	74 0f                	je     f01035cb <debuginfo_eip+0x1ce>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01035bc:	80 f9 64             	cmp    $0x64,%cl
f01035bf:	75 e6                	jne    f01035a7 <debuginfo_eip+0x1aa>
f01035c1:	83 7f 08 00          	cmpl   $0x0,0x8(%edi)
f01035c5:	74 e0                	je     f01035a7 <debuginfo_eip+0x1aa>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01035c7:	39 c6                	cmp    %eax,%esi
f01035c9:	7f 1f                	jg     f01035ea <debuginfo_eip+0x1ed>
f01035cb:	6b c0 0c             	imul   $0xc,%eax,%eax
f01035ce:	8b 80 04 5d 10 f0    	mov    -0xfefa2fc(%eax),%eax
f01035d4:	ba fe ea 10 f0       	mov    $0xf010eafe,%edx
f01035d9:	81 ea e5 ca 10 f0    	sub    $0xf010cae5,%edx
f01035df:	39 d0                	cmp    %edx,%eax
f01035e1:	73 07                	jae    f01035ea <debuginfo_eip+0x1ed>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01035e3:	05 e5 ca 10 f0       	add    $0xf010cae5,%eax
f01035e8:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01035ea:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01035ed:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
f01035f0:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01035f5:	39 ca                	cmp    %ecx,%edx
f01035f7:	7d 70                	jge    f0103669 <debuginfo_eip+0x26c>
		for (lline = lfun + 1;
f01035f9:	8d 42 01             	lea    0x1(%edx),%eax
f01035fc:	39 c1                	cmp    %eax,%ecx
f01035fe:	7e 56                	jle    f0103656 <debuginfo_eip+0x259>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103600:	6b c0 0c             	imul   $0xc,%eax,%eax
f0103603:	80 b8 08 5d 10 f0 a0 	cmpb   $0xa0,-0xfefa2f8(%eax)
f010360a:	75 51                	jne    f010365d <debuginfo_eip+0x260>
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f010360c:	8d 42 02             	lea    0x2(%edx),%eax
f010360f:	6b d2 0c             	imul   $0xc,%edx,%edx
f0103612:	81 c2 04 5d 10 f0    	add    $0xf0105d04,%edx
f0103618:	89 cf                	mov    %ecx,%edi
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f010361a:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010361e:	39 f8                	cmp    %edi,%eax
f0103620:	74 42                	je     f0103664 <debuginfo_eip+0x267>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103622:	0f b6 72 1c          	movzbl 0x1c(%edx),%esi
f0103626:	83 c0 01             	add    $0x1,%eax
f0103629:	83 c2 0c             	add    $0xc,%edx
f010362c:	89 f1                	mov    %esi,%ecx
f010362e:	80 f9 a0             	cmp    $0xa0,%cl
f0103631:	74 e7                	je     f010361a <debuginfo_eip+0x21d>
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
f0103633:	b8 00 00 00 00       	mov    $0x0,%eax
f0103638:	eb 2f                	jmp    f0103669 <debuginfo_eip+0x26c>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f010363a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010363f:	eb 28                	jmp    f0103669 <debuginfo_eip+0x26c>
f0103641:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103646:	eb 21                	jmp    f0103669 <debuginfo_eip+0x26c>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0103648:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010364d:	eb 1a                	jmp    f0103669 <debuginfo_eip+0x26c>
	// Your code here.
	stab_binsearch(stabs,&lline,&rline,N_SLINE,addr);
	if (lline<=rline)
		info->eip_line=rline;
	else 
		return -1;
f010364f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103654:	eb 13                	jmp    f0103669 <debuginfo_eip+0x26c>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
f0103656:	b8 00 00 00 00       	mov    $0x0,%eax
f010365b:	eb 0c                	jmp    f0103669 <debuginfo_eip+0x26c>
f010365d:	b8 00 00 00 00       	mov    $0x0,%eax
f0103662:	eb 05                	jmp    f0103669 <debuginfo_eip+0x26c>
f0103664:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103669:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010366c:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010366f:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0103672:	89 ec                	mov    %ebp,%esp
f0103674:	5d                   	pop    %ebp
f0103675:	c3                   	ret    
	...

f0103680 <_printnum>:
};

static void
_printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103680:	55                   	push   %ebp
f0103681:	89 e5                	mov    %esp,%ebp
f0103683:	57                   	push   %edi
f0103684:	56                   	push   %esi
f0103685:	53                   	push   %ebx
f0103686:	83 ec 4c             	sub    $0x4c,%esp
f0103689:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010368c:	89 d7                	mov    %edx,%edi
f010368e:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103691:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0103694:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103697:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010369a:	85 db                	test   %ebx,%ebx
f010369c:	75 08                	jne    f01036a6 <_printnum+0x26>
f010369e:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f01036a1:	39 5d 10             	cmp    %ebx,0x10(%ebp)
f01036a4:	77 61                	ja     f0103707 <_printnum+0x87>
		_printnum(putch, putdat, num / base, base, width - 1, padc);
f01036a6:	8b 5d 18             	mov    0x18(%ebp),%ebx
f01036a9:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f01036ad:	8b 45 14             	mov    0x14(%ebp),%eax
f01036b0:	83 e8 01             	sub    $0x1,%eax
f01036b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01036b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01036ba:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01036be:	8b 44 24 08          	mov    0x8(%esp),%eax
f01036c2:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01036c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01036c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01036cc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01036d3:	00 
f01036d4:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f01036d7:	89 1c 24             	mov    %ebx,(%esp)
f01036da:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01036dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01036e1:	e8 6a 0f 00 00       	call   f0104650 <__udivdi3>
f01036e6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01036e9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01036ec:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01036f0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01036f4:	89 04 24             	mov    %eax,(%esp)
f01036f7:	89 54 24 04          	mov    %edx,0x4(%esp)
f01036fb:	89 fa                	mov    %edi,%edx
f01036fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103700:	e8 7b ff ff ff       	call   f0103680 <_printnum>
f0103705:	eb 27                	jmp    f010372e <_printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		if (padc!='-') while (--width > 0)
f0103707:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
f010370b:	74 21                	je     f010372e <_printnum+0xae>
f010370d:	8b 75 14             	mov    0x14(%ebp),%esi
f0103710:	83 ee 01             	sub    $0x1,%esi
f0103713:	85 f6                	test   %esi,%esi
f0103715:	7e 17                	jle    f010372e <_printnum+0xae>
f0103717:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			putch(padc, putdat);
f010371a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010371e:	8b 45 18             	mov    0x18(%ebp),%eax
f0103721:	89 04 24             	mov    %eax,(%esp)
f0103724:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		_printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc!='-') while (--width > 0)
f0103726:	83 ee 01             	sub    $0x1,%esi
f0103729:	75 ef                	jne    f010371a <_printnum+0x9a>
f010372b:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010372e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103732:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103736:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0103739:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010373d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0103744:	00 
f0103745:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0103748:	89 1c 24             	mov    %ebx,(%esp)
f010374b:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f010374e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103752:	e8 59 10 00 00       	call   f01047b0 <__umoddi3>
f0103757:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010375b:	0f be 80 77 5a 10 f0 	movsbl -0xfefa589(%eax),%eax
f0103762:	89 04 24             	mov    %eax,(%esp)
f0103765:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103768:	ff d0                	call   *%eax
}
f010376a:	83 c4 4c             	add    $0x4c,%esp
f010376d:	5b                   	pop    %ebx
f010376e:	5e                   	pop    %esi
f010376f:	5f                   	pop    %edi
f0103770:	5d                   	pop    %ebp
f0103771:	c3                   	ret    

f0103772 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0103772:	55                   	push   %ebp
f0103773:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103775:	83 fa 01             	cmp    $0x1,%edx
f0103778:	7e 0e                	jle    f0103788 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010377a:	8b 10                	mov    (%eax),%edx
f010377c:	8d 4a 08             	lea    0x8(%edx),%ecx
f010377f:	89 08                	mov    %ecx,(%eax)
f0103781:	8b 02                	mov    (%edx),%eax
f0103783:	8b 52 04             	mov    0x4(%edx),%edx
f0103786:	eb 22                	jmp    f01037aa <getuint+0x38>
	else if (lflag)
f0103788:	85 d2                	test   %edx,%edx
f010378a:	74 10                	je     f010379c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f010378c:	8b 10                	mov    (%eax),%edx
f010378e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103791:	89 08                	mov    %ecx,(%eax)
f0103793:	8b 02                	mov    (%edx),%eax
f0103795:	ba 00 00 00 00       	mov    $0x0,%edx
f010379a:	eb 0e                	jmp    f01037aa <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f010379c:	8b 10                	mov    (%eax),%edx
f010379e:	8d 4a 04             	lea    0x4(%edx),%ecx
f01037a1:	89 08                	mov    %ecx,(%eax)
f01037a3:	8b 02                	mov    (%edx),%eax
f01037a5:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01037aa:	5d                   	pop    %ebp
f01037ab:	c3                   	ret    

f01037ac <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f01037ac:	55                   	push   %ebp
f01037ad:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01037af:	83 fa 01             	cmp    $0x1,%edx
f01037b2:	7e 0e                	jle    f01037c2 <getint+0x16>
		return va_arg(*ap, long long);
f01037b4:	8b 10                	mov    (%eax),%edx
f01037b6:	8d 4a 08             	lea    0x8(%edx),%ecx
f01037b9:	89 08                	mov    %ecx,(%eax)
f01037bb:	8b 02                	mov    (%edx),%eax
f01037bd:	8b 52 04             	mov    0x4(%edx),%edx
f01037c0:	eb 22                	jmp    f01037e4 <getint+0x38>
	else if (lflag)
f01037c2:	85 d2                	test   %edx,%edx
f01037c4:	74 10                	je     f01037d6 <getint+0x2a>
		return va_arg(*ap, long);
f01037c6:	8b 10                	mov    (%eax),%edx
f01037c8:	8d 4a 04             	lea    0x4(%edx),%ecx
f01037cb:	89 08                	mov    %ecx,(%eax)
f01037cd:	8b 02                	mov    (%edx),%eax
f01037cf:	89 c2                	mov    %eax,%edx
f01037d1:	c1 fa 1f             	sar    $0x1f,%edx
f01037d4:	eb 0e                	jmp    f01037e4 <getint+0x38>
	else
		return va_arg(*ap, int);
f01037d6:	8b 10                	mov    (%eax),%edx
f01037d8:	8d 4a 04             	lea    0x4(%edx),%ecx
f01037db:	89 08                	mov    %ecx,(%eax)
f01037dd:	8b 02                	mov    (%edx),%eax
f01037df:	89 c2                	mov    %eax,%edx
f01037e1:	c1 fa 1f             	sar    $0x1f,%edx
}
f01037e4:	5d                   	pop    %ebp
f01037e5:	c3                   	ret    

f01037e6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01037e6:	55                   	push   %ebp
f01037e7:	89 e5                	mov    %esp,%ebp
f01037e9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01037ec:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01037f0:	8b 10                	mov    (%eax),%edx
f01037f2:	3b 50 04             	cmp    0x4(%eax),%edx
f01037f5:	73 0a                	jae    f0103801 <sprintputch+0x1b>
		*b->buf++ = ch;
f01037f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01037fa:	88 0a                	mov    %cl,(%edx)
f01037fc:	83 c2 01             	add    $0x1,%edx
f01037ff:	89 10                	mov    %edx,(%eax)
}
f0103801:	5d                   	pop    %ebp
f0103802:	c3                   	ret    

f0103803 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103803:	55                   	push   %ebp
f0103804:	89 e5                	mov    %esp,%ebp
f0103806:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0103809:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010380c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103810:	8b 45 10             	mov    0x10(%ebp),%eax
f0103813:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103817:	8b 45 0c             	mov    0xc(%ebp),%eax
f010381a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010381e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103821:	89 04 24             	mov    %eax,(%esp)
f0103824:	e8 02 00 00 00       	call   f010382b <vprintfmt>
	va_end(ap);
}
f0103829:	c9                   	leave  
f010382a:	c3                   	ret    

f010382b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010382b:	55                   	push   %ebp
f010382c:	89 e5                	mov    %esp,%ebp
f010382e:	57                   	push   %edi
f010382f:	56                   	push   %esi
f0103830:	53                   	push   %ebx
f0103831:	81 ec 5c 01 00 00    	sub    $0x15c,%esp
f0103837:	8b 75 0c             	mov    0xc(%ebp),%esi
f010383a:	8b 7d 10             	mov    0x10(%ebp),%edi
f010383d:	89 fb                	mov    %edi,%ebx
f010383f:	89 f7                	mov    %esi,%edi
f0103841:	eb 14                	jmp    f0103857 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0103843:	85 c0                	test   %eax,%eax
f0103845:	0f 84 6b 08 00 00    	je     f01040b6 <vprintfmt+0x88b>
				return;
			putch(ch, putdat);
f010384b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010384f:	89 04 24             	mov    %eax,(%esp)
f0103852:	8b 45 08             	mov    0x8(%ebp),%eax
f0103855:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103857:	0f b6 03             	movzbl (%ebx),%eax
f010385a:	83 c3 01             	add    $0x1,%ebx
f010385d:	83 f8 25             	cmp    $0x25,%eax
f0103860:	75 e1                	jne    f0103843 <vprintfmt+0x18>
f0103862:	c6 85 d8 fe ff ff 20 	movb   $0x20,-0x128(%ebp)
f0103869:	c7 85 c8 fe ff ff 00 	movl   $0x0,-0x138(%ebp)
f0103870:	00 00 00 
f0103873:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0103878:	c7 85 e0 fe ff ff ff 	movl   $0xffffffff,-0x120(%ebp)
f010387f:	ff ff ff 
f0103882:	ba 00 00 00 00       	mov    $0x0,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103887:	0f b6 0b             	movzbl (%ebx),%ecx
f010388a:	8d 43 01             	lea    0x1(%ebx),%eax
f010388d:	89 85 d4 fe ff ff    	mov    %eax,-0x12c(%ebp)
f0103893:	0f b6 03             	movzbl (%ebx),%eax
f0103896:	83 e8 23             	sub    $0x23,%eax
f0103899:	3c 55                	cmp    $0x55,%al
f010389b:	0f 87 27 06 00 00    	ja     f0103ec8 <vprintfmt+0x69d>
f01038a1:	0f b6 c0             	movzbl %al,%eax
f01038a4:	ff 24 85 80 5b 10 f0 	jmp    *-0xfefa480(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01038ab:	8d 71 d0             	lea    -0x30(%ecx),%esi
				ch = *fmt;
f01038ae:	0f be 43 01          	movsbl 0x1(%ebx),%eax
				if (ch < '0' || ch > '9')
f01038b2:	8d 48 d0             	lea    -0x30(%eax),%ecx
f01038b5:	83 f9 09             	cmp    $0x9,%ecx
f01038b8:	77 6e                	ja     f0103928 <vprintfmt+0xfd>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01038ba:	8b 9d d4 fe ff ff    	mov    -0x12c(%ebp),%ebx
f01038c0:	eb 0f                	jmp    f01038d1 <vprintfmt+0xa6>
f01038c2:	8b 9d d4 fe ff ff    	mov    -0x12c(%ebp),%ebx
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01038c8:	c6 85 d8 fe ff ff 30 	movb   $0x30,-0x128(%ebp)
f01038cf:	eb b6                	jmp    f0103887 <vprintfmt+0x5c>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01038d1:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f01038d4:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
f01038d7:	8d 74 48 d0          	lea    -0x30(%eax,%ecx,2),%esi
				ch = *fmt;
f01038db:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f01038de:	8d 48 d0             	lea    -0x30(%eax),%ecx
f01038e1:	83 f9 09             	cmp    $0x9,%ecx
f01038e4:	76 eb                	jbe    f01038d1 <vprintfmt+0xa6>
f01038e6:	eb 46                	jmp    f010392e <vprintfmt+0x103>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01038e8:	8b 45 14             	mov    0x14(%ebp),%eax
f01038eb:	8d 48 04             	lea    0x4(%eax),%ecx
f01038ee:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01038f1:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01038f3:	8b 9d d4 fe ff ff    	mov    -0x12c(%ebp),%ebx
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01038f9:	eb 33                	jmp    f010392e <vprintfmt+0x103>

		case '.':
			if (width < 0)
f01038fb:	83 bd e0 fe ff ff 00 	cmpl   $0x0,-0x120(%ebp)
f0103902:	0f 88 0b 06 00 00    	js     f0103f13 <vprintfmt+0x6e8>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103908:	8b 9d d4 fe ff ff    	mov    -0x12c(%ebp),%ebx
f010390e:	e9 74 ff ff ff       	jmp    f0103887 <vprintfmt+0x5c>
f0103913:	8b 9d d4 fe ff ff    	mov    -0x12c(%ebp),%ebx
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103919:	c7 85 c8 fe ff ff 01 	movl   $0x1,-0x138(%ebp)
f0103920:	00 00 00 
f0103923:	e9 5f ff ff ff       	jmp    f0103887 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103928:	8b 9d d4 fe ff ff    	mov    -0x12c(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f010392e:	83 bd e0 fe ff ff 00 	cmpl   $0x0,-0x120(%ebp)
f0103935:	0f 89 4c ff ff ff    	jns    f0103887 <vprintfmt+0x5c>
f010393b:	e9 e8 05 00 00       	jmp    f0103f28 <vprintfmt+0x6fd>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103940:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103943:	8b 9d d4 fe ff ff    	mov    -0x12c(%ebp),%ebx
f0103949:	e9 39 ff ff ff       	jmp    f0103887 <vprintfmt+0x5c>
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f010394e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103951:	8d 50 04             	lea    0x4(%eax),%edx
f0103954:	89 55 14             	mov    %edx,0x14(%ebp)
f0103957:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010395b:	8b 00                	mov    (%eax),%eax
f010395d:	89 04 24             	mov    %eax,(%esp)
f0103960:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103963:	ff d3                	call   *%ebx
f0103965:	e9 d4 05 00 00       	jmp    f0103f3e <vprintfmt+0x713>
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f010396a:	8b 45 14             	mov    0x14(%ebp),%eax
f010396d:	8d 50 04             	lea    0x4(%eax),%edx
f0103970:	89 55 14             	mov    %edx,0x14(%ebp)
f0103973:	8b 00                	mov    (%eax),%eax
f0103975:	89 c2                	mov    %eax,%edx
f0103977:	c1 fa 1f             	sar    $0x1f,%edx
f010397a:	31 d0                	xor    %edx,%eax
f010397c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010397e:	83 f8 06             	cmp    $0x6,%eax
f0103981:	7f 0b                	jg     f010398e <vprintfmt+0x163>
f0103983:	8b 14 85 d8 5c 10 f0 	mov    -0xfefa328(,%eax,4),%edx
f010398a:	85 d2                	test   %edx,%edx
f010398c:	75 20                	jne    f01039ae <vprintfmt+0x183>
				printfmt(putch, putdat, "error %d", err);
f010398e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103992:	c7 44 24 08 8f 5a 10 	movl   $0xf0105a8f,0x8(%esp)
f0103999:	f0 
f010399a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010399e:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01039a1:	89 1c 24             	mov    %ebx,(%esp)
f01039a4:	e8 5a fe ff ff       	call   f0103803 <printfmt>
f01039a9:	e9 90 05 00 00       	jmp    f0103f3e <vprintfmt+0x713>
			else
				printfmt(putch, putdat, "%s", p);
f01039ae:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01039b2:	c7 44 24 08 b1 57 10 	movl   $0xf01057b1,0x8(%esp)
f01039b9:	f0 
f01039ba:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01039be:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01039c1:	89 1c 24             	mov    %ebx,(%esp)
f01039c4:	e8 3a fe ff ff       	call   f0103803 <printfmt>
f01039c9:	e9 70 05 00 00       	jmp    f0103f3e <vprintfmt+0x713>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01039ce:	89 f1                	mov    %esi,%ecx
f01039d0:	8b 9d e0 fe ff ff    	mov    -0x120(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01039d6:	8b 45 14             	mov    0x14(%ebp),%eax
f01039d9:	8d 50 04             	lea    0x4(%eax),%edx
f01039dc:	89 55 14             	mov    %edx,0x14(%ebp)
f01039df:	8b 00                	mov    (%eax),%eax
f01039e1:	89 85 c0 fe ff ff    	mov    %eax,-0x140(%ebp)
f01039e7:	85 c0                	test   %eax,%eax
f01039e9:	75 0a                	jne    f01039f5 <vprintfmt+0x1ca>
				p = "(null)";
f01039eb:	c7 85 c0 fe ff ff 88 	movl   $0xf0105a88,-0x140(%ebp)
f01039f2:	5a 10 f0 
			if (width > 0 && padc != '-')
f01039f5:	80 bd d8 fe ff ff 2d 	cmpb   $0x2d,-0x128(%ebp)
f01039fc:	74 04                	je     f0103a02 <vprintfmt+0x1d7>
f01039fe:	85 db                	test   %ebx,%ebx
f0103a00:	7f 1c                	jg     f0103a1e <vprintfmt+0x1f3>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103a02:	8b 9d c0 fe ff ff    	mov    -0x140(%ebp),%ebx
f0103a08:	0f b6 13             	movzbl (%ebx),%edx
f0103a0b:	0f be c2             	movsbl %dl,%eax
f0103a0e:	83 c3 01             	add    $0x1,%ebx
f0103a11:	85 c0                	test   %eax,%eax
f0103a13:	0f 85 bd 00 00 00    	jne    f0103ad6 <vprintfmt+0x2ab>
f0103a19:	e9 aa 00 00 00       	jmp    f0103ac8 <vprintfmt+0x29d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103a1e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103a22:	8b 85 c0 fe ff ff    	mov    -0x140(%ebp),%eax
f0103a28:	89 04 24             	mov    %eax,(%esp)
f0103a2b:	e8 12 08 00 00       	call   f0104242 <strnlen>
f0103a30:	29 c3                	sub    %eax,%ebx
f0103a32:	89 9d e0 fe ff ff    	mov    %ebx,-0x120(%ebp)
f0103a38:	85 db                	test   %ebx,%ebx
f0103a3a:	7e c6                	jle    f0103a02 <vprintfmt+0x1d7>
					putch(padc, putdat);
f0103a3c:	0f be 9d d8 fe ff ff 	movsbl -0x128(%ebp),%ebx
f0103a43:	89 b5 d8 fe ff ff    	mov    %esi,-0x128(%ebp)
f0103a49:	8b b5 e0 fe ff ff    	mov    -0x120(%ebp),%esi
f0103a4f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103a53:	89 1c 24             	mov    %ebx,(%esp)
f0103a56:	8b 55 08             	mov    0x8(%ebp),%edx
f0103a59:	ff d2                	call   *%edx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103a5b:	83 ee 01             	sub    $0x1,%esi
f0103a5e:	75 ef                	jne    f0103a4f <vprintfmt+0x224>
f0103a60:	89 b5 e0 fe ff ff    	mov    %esi,-0x120(%ebp)
f0103a66:	8b b5 d8 fe ff ff    	mov    -0x128(%ebp),%esi
f0103a6c:	eb 94                	jmp    f0103a02 <vprintfmt+0x1d7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0103a6e:	83 bd c8 fe ff ff 00 	cmpl   $0x0,-0x138(%ebp)
f0103a75:	74 23                	je     f0103a9a <vprintfmt+0x26f>
f0103a77:	0f be d2             	movsbl %dl,%edx
f0103a7a:	83 ea 20             	sub    $0x20,%edx
f0103a7d:	83 fa 5e             	cmp    $0x5e,%edx
f0103a80:	76 18                	jbe    f0103a9a <vprintfmt+0x26f>
					putch('?', putdat);
f0103a82:	8b 8d d8 fe ff ff    	mov    -0x128(%ebp),%ecx
f0103a88:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103a8c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0103a93:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a96:	ff d0                	call   *%eax
f0103a98:	eb 12                	jmp    f0103aac <vprintfmt+0x281>
				else
					putch(ch, putdat);
f0103a9a:	8b 95 d8 fe ff ff    	mov    -0x128(%ebp),%edx
f0103aa0:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103aa4:	89 04 24             	mov    %eax,(%esp)
f0103aa7:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103aaa:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103aac:	83 ef 01             	sub    $0x1,%edi
f0103aaf:	0f b6 13             	movzbl (%ebx),%edx
f0103ab2:	0f be c2             	movsbl %dl,%eax
f0103ab5:	83 c3 01             	add    $0x1,%ebx
f0103ab8:	85 c0                	test   %eax,%eax
f0103aba:	75 26                	jne    f0103ae2 <vprintfmt+0x2b7>
f0103abc:	89 bd e0 fe ff ff    	mov    %edi,-0x120(%ebp)
f0103ac2:	8b bd d8 fe ff ff    	mov    -0x128(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103ac8:	83 bd e0 fe ff ff 00 	cmpl   $0x0,-0x120(%ebp)
f0103acf:	7f 28                	jg     f0103af9 <vprintfmt+0x2ce>
f0103ad1:	e9 68 04 00 00       	jmp    f0103f3e <vprintfmt+0x713>
f0103ad6:	89 bd d8 fe ff ff    	mov    %edi,-0x128(%ebp)
f0103adc:	8b bd e0 fe ff ff    	mov    -0x120(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103ae2:	85 f6                	test   %esi,%esi
f0103ae4:	78 88                	js     f0103a6e <vprintfmt+0x243>
f0103ae6:	83 ee 01             	sub    $0x1,%esi
f0103ae9:	79 83                	jns    f0103a6e <vprintfmt+0x243>
f0103aeb:	89 bd e0 fe ff ff    	mov    %edi,-0x120(%ebp)
f0103af1:	8b bd d8 fe ff ff    	mov    -0x128(%ebp),%edi
f0103af7:	eb cf                	jmp    f0103ac8 <vprintfmt+0x29d>
f0103af9:	8b 9d e0 fe ff ff    	mov    -0x120(%ebp),%ebx
f0103aff:	8b 75 08             	mov    0x8(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0103b02:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103b06:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0103b0d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103b0f:	83 eb 01             	sub    $0x1,%ebx
f0103b12:	75 ee                	jne    f0103b02 <vprintfmt+0x2d7>
f0103b14:	e9 25 04 00 00       	jmp    f0103f3e <vprintfmt+0x713>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103b19:	8d 45 14             	lea    0x14(%ebp),%eax
f0103b1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103b20:	e8 87 fc ff ff       	call   f01037ac <getint>
f0103b25:	89 85 c0 fe ff ff    	mov    %eax,-0x140(%ebp)
f0103b2b:	89 95 c4 fe ff ff    	mov    %edx,-0x13c(%ebp)
f0103b31:	89 85 c8 fe ff ff    	mov    %eax,-0x138(%ebp)
f0103b37:	89 95 cc fe ff ff    	mov    %edx,-0x134(%ebp)
			if ((long long) num < 0) {
f0103b3d:	83 bd c4 fe ff ff 00 	cmpl   $0x0,-0x13c(%ebp)
f0103b44:	79 39                	jns    f0103b7f <vprintfmt+0x354>
				putch('-', putdat);
f0103b46:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103b4a:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0103b51:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103b54:	ff d3                	call   *%ebx
				num = -(long long) num;
f0103b56:	8b 85 c0 fe ff ff    	mov    -0x140(%ebp),%eax
f0103b5c:	8b 95 c4 fe ff ff    	mov    -0x13c(%ebp),%edx
f0103b62:	f7 d8                	neg    %eax
f0103b64:	83 d2 00             	adc    $0x0,%edx
f0103b67:	f7 da                	neg    %edx
f0103b69:	89 85 c8 fe ff ff    	mov    %eax,-0x138(%ebp)
f0103b6f:	89 95 cc fe ff ff    	mov    %edx,-0x134(%ebp)
			}
			else if (padc=='+')
			{
				putch('+',putdat);
			}
			base = 10;
f0103b75:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103b7a:	e9 4b 01 00 00       	jmp    f0103cca <vprintfmt+0x49f>
f0103b7f:	b8 0a 00 00 00       	mov    $0xa,%eax
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			else if (padc=='+')
f0103b84:	80 bd d8 fe ff ff 2b 	cmpb   $0x2b,-0x128(%ebp)
f0103b8b:	0f 85 39 01 00 00    	jne    f0103cca <vprintfmt+0x49f>
			{
				putch('+',putdat);
f0103b91:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103b95:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
f0103b9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103b9f:	ff d3                	call   *%ebx
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103ba1:	83 bd c4 fe ff ff 00 	cmpl   $0x0,-0x13c(%ebp)
f0103ba8:	0f 87 42 04 00 00    	ja     f0103ff0 <vprintfmt+0x7c5>
f0103bae:	83 bd c0 fe ff ff 09 	cmpl   $0x9,-0x140(%ebp)
f0103bb5:	0f 87 35 04 00 00    	ja     f0103ff0 <vprintfmt+0x7c5>
f0103bbb:	c7 85 d8 fe ff ff 0a 	movl   $0xa,-0x128(%ebp)
f0103bc2:	00 00 00 
f0103bc5:	c7 85 dc fe ff ff 00 	movl   $0x0,-0x124(%ebp)
f0103bcc:	00 00 00 
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103bcf:	c7 85 bc fe ff ff 2b 	movl   $0x2b,-0x144(%ebp)
f0103bd6:	00 00 00 
f0103bd9:	e9 08 02 00 00       	jmp    f0103de6 <vprintfmt+0x5bb>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0103bde:	8d 45 14             	lea    0x14(%ebp),%eax
f0103be1:	e8 8c fb ff ff       	call   f0103772 <getuint>
f0103be6:	89 85 c8 fe ff ff    	mov    %eax,-0x138(%ebp)
f0103bec:	89 95 cc fe ff ff    	mov    %edx,-0x134(%ebp)
			base = 10;
f0103bf2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0103bf7:	e9 ce 00 00 00       	jmp    f0103cca <vprintfmt+0x49f>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
                        num = getint(&ap,lflag);
f0103bfc:	8d 45 14             	lea    0x14(%ebp),%eax
f0103bff:	e8 a8 fb ff ff       	call   f01037ac <getint>
			unsigned long long temp=num;
			int i=0;
			int a[64];
      			while (temp>0)
f0103c04:	89 d1                	mov    %edx,%ecx
f0103c06:	09 c1                	or     %eax,%ecx
f0103c08:	0f 84 3b 03 00 00    	je     f0103f49 <vprintfmt+0x71e>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
                        num = getint(&ap,lflag);
			unsigned long long temp=num;
f0103c0e:	89 c1                	mov    %eax,%ecx
f0103c10:	89 d3                	mov    %edx,%ebx
			int i=0;
f0103c12:	b8 00 00 00 00       	mov    $0x0,%eax
			int a[64];
      			while (temp>0)
			{
				a[i]=temp & 7;
f0103c17:	89 ca                	mov    %ecx,%edx
f0103c19:	83 e2 07             	and    $0x7,%edx
f0103c1c:	89 94 85 e8 fe ff ff 	mov    %edx,-0x118(%ebp,%eax,4)
				temp=temp>>3;
f0103c23:	0f ac d9 03          	shrd   $0x3,%ebx,%ecx
f0103c27:	c1 eb 03             	shr    $0x3,%ebx
				i++;
f0103c2a:	83 c0 01             	add    $0x1,%eax
			// display a number in octal form and the form should begin with '0'
                        num = getint(&ap,lflag);
			unsigned long long temp=num;
			int i=0;
			int a[64];
      			while (temp>0)
f0103c2d:	89 da                	mov    %ebx,%edx
f0103c2f:	09 ca                	or     %ecx,%edx
f0103c31:	75 e4                	jne    f0103c17 <vprintfmt+0x3ec>
			{
				a[i]=temp & 7;
				temp=temp>>3;
				i++;
			}
			i--;
f0103c33:	8d 58 ff             	lea    -0x1(%eax),%ebx
			putch('0', putdat);
f0103c36:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103c3a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0103c41:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103c44:	ff d1                	call   *%ecx
			for (;i>=0;i--) putch(a[i]+'0',putdat);
f0103c46:	85 db                	test   %ebx,%ebx
f0103c48:	0f 88 f0 02 00 00    	js     f0103f3e <vprintfmt+0x713>
f0103c4e:	8b 75 08             	mov    0x8(%ebp),%esi
f0103c51:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103c55:	8b 84 9d e8 fe ff ff 	mov    -0x118(%ebp,%ebx,4),%eax
f0103c5c:	83 c0 30             	add    $0x30,%eax
f0103c5f:	89 04 24             	mov    %eax,(%esp)
f0103c62:	ff d6                	call   *%esi
f0103c64:	83 eb 01             	sub    $0x1,%ebx
f0103c67:	83 fb ff             	cmp    $0xffffffff,%ebx
f0103c6a:	75 e5                	jne    f0103c51 <vprintfmt+0x426>
f0103c6c:	e9 cd 02 00 00       	jmp    f0103f3e <vprintfmt+0x713>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f0103c71:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103c75:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0103c7c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103c7f:	ff d3                	call   *%ebx
			putch('x', putdat);
f0103c81:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103c85:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0103c8c:	ff d3                	call   *%ebx
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0103c8e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c91:	8d 50 04             	lea    0x4(%eax),%edx
f0103c94:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0103c97:	8b 10                	mov    (%eax),%edx
f0103c99:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103c9e:	89 95 c8 fe ff ff    	mov    %edx,-0x138(%ebp)
f0103ca4:	89 8d cc fe ff ff    	mov    %ecx,-0x134(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0103caa:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0103caf:	eb 19                	jmp    f0103cca <vprintfmt+0x49f>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0103cb1:	8d 45 14             	lea    0x14(%ebp),%eax
f0103cb4:	e8 b9 fa ff ff       	call   f0103772 <getuint>
f0103cb9:	89 85 c8 fe ff ff    	mov    %eax,-0x138(%ebp)
f0103cbf:	89 95 cc fe ff ff    	mov    %edx,-0x134(%ebp)
			base = 16;
f0103cc5:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103cca:	0f be 9d d8 fe ff ff 	movsbl -0x128(%ebp),%ebx
f0103cd1:	89 9d bc fe ff ff    	mov    %ebx,-0x144(%ebp)
f0103cd7:	89 c2                	mov    %eax,%edx
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103cd9:	89 85 d8 fe ff ff    	mov    %eax,-0x128(%ebp)
f0103cdf:	c7 85 dc fe ff ff 00 	movl   $0x0,-0x124(%ebp)
f0103ce6:	00 00 00 
f0103ce9:	83 bd cc fe ff ff 00 	cmpl   $0x0,-0x134(%ebp)
f0103cf0:	77 12                	ja     f0103d04 <vprintfmt+0x4d9>
f0103cf2:	8b 85 d8 fe ff ff    	mov    -0x128(%ebp),%eax
f0103cf8:	39 85 c8 fe ff ff    	cmp    %eax,-0x138(%ebp)
f0103cfe:	0f 82 d5 00 00 00    	jb     f0103dd9 <vprintfmt+0x5ae>
		_printnum(putch, putdat, num / base, base, width - 1, padc);
f0103d04:	8b 9d bc fe ff ff    	mov    -0x144(%ebp),%ebx
f0103d0a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0103d0e:	8b 85 e0 fe ff ff    	mov    -0x120(%ebp),%eax
f0103d14:	83 e8 01             	sub    $0x1,%eax
f0103d17:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103d1b:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103d1f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103d23:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0103d27:	89 85 c0 fe ff ff    	mov    %eax,-0x140(%ebp)
f0103d2d:	89 95 c4 fe ff ff    	mov    %edx,-0x13c(%ebp)
f0103d33:	8b 95 d8 fe ff ff    	mov    -0x128(%ebp),%edx
f0103d39:	8b 8d dc fe ff ff    	mov    -0x124(%ebp),%ecx
f0103d3f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103d43:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103d47:	8b 8d c8 fe ff ff    	mov    -0x138(%ebp),%ecx
f0103d4d:	8b 9d cc fe ff ff    	mov    -0x134(%ebp),%ebx
f0103d53:	89 0c 24             	mov    %ecx,(%esp)
f0103d56:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103d5a:	e8 f1 08 00 00       	call   f0104650 <__udivdi3>
f0103d5f:	8b 8d c0 fe ff ff    	mov    -0x140(%ebp),%ecx
f0103d65:	8b 9d c4 fe ff ff    	mov    -0x13c(%ebp),%ebx
f0103d6b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103d6f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0103d73:	89 04 24             	mov    %eax,(%esp)
f0103d76:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103d7a:	89 fa                	mov    %edi,%edx
f0103d7c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d7f:	e8 fc f8 ff ff       	call   f0103680 <_printnum>
		if (padc!='-') while (--width > 0)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103d84:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103d88:	8b 74 24 04          	mov    0x4(%esp),%esi
f0103d8c:	8b 85 d8 fe ff ff    	mov    -0x128(%ebp),%eax
f0103d92:	8b 95 dc fe ff ff    	mov    -0x124(%ebp),%edx
f0103d98:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103d9c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103da0:	8b 95 c8 fe ff ff    	mov    -0x138(%ebp),%edx
f0103da6:	8b 8d cc fe ff ff    	mov    -0x134(%ebp),%ecx
f0103dac:	89 14 24             	mov    %edx,(%esp)
f0103daf:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103db3:	e8 f8 09 00 00       	call   f01047b0 <__umoddi3>
f0103db8:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103dbc:	0f be 80 77 5a 10 f0 	movsbl -0xfefa589(%eax),%eax
f0103dc3:	89 04 24             	mov    %eax,(%esp)
f0103dc6:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103dc9:	ff d3                	call   *%ebx
	int i=0;
	if (padc == '-') 
f0103dcb:	83 bd bc fe ff ff 2d 	cmpl   $0x2d,-0x144(%ebp)
f0103dd2:	74 3f                	je     f0103e13 <vprintfmt+0x5e8>
f0103dd4:	e9 65 01 00 00       	jmp    f0103f3e <vprintfmt+0x713>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		_printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc!='-') while (--width > 0)
f0103dd9:	83 bd bc fe ff ff 2d 	cmpl   $0x2d,-0x144(%ebp)
f0103de0:	0f 84 be 01 00 00    	je     f0103fa4 <vprintfmt+0x779>
f0103de6:	8b b5 e0 fe ff ff    	mov    -0x120(%ebp),%esi
f0103dec:	83 ee 01             	sub    $0x1,%esi
f0103def:	85 f6                	test   %esi,%esi
f0103df1:	0f 8e 64 01 00 00    	jle    f0103f5b <vprintfmt+0x730>
f0103df7:	8b 9d bc fe ff ff    	mov    -0x144(%ebp),%ebx
			putch(padc, putdat);
f0103dfd:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103e01:	89 1c 24             	mov    %ebx,(%esp)
f0103e04:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e07:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		_printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc!='-') while (--width > 0)
f0103e09:	83 ee 01             	sub    $0x1,%esi
f0103e0c:	75 ef                	jne    f0103dfd <vprintfmt+0x5d2>
f0103e0e:	e9 48 01 00 00       	jmp    f0103f5b <vprintfmt+0x730>
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	int i=0;
	if (padc == '-') 
	{
		for (i=0;i<width-1;i++) putch(' ',putdat);
f0103e13:	8b b5 e0 fe ff ff    	mov    -0x120(%ebp),%esi
f0103e19:	83 ee 01             	sub    $0x1,%esi
f0103e1c:	85 f6                	test   %esi,%esi
f0103e1e:	0f 8e 1a 01 00 00    	jle    f0103f3e <vprintfmt+0x713>
f0103e24:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103e29:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103e2d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0103e34:	8b 55 08             	mov    0x8(%ebp),%edx
f0103e37:	ff d2                	call   *%edx
f0103e39:	83 c3 01             	add    $0x1,%ebx
f0103e3c:	39 f3                	cmp    %esi,%ebx
f0103e3e:	75 e9                	jne    f0103e29 <vprintfmt+0x5fe>
f0103e40:	e9 f9 00 00 00       	jmp    f0103f3e <vprintfmt+0x713>

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
	    num = getuint(&ap,lflag);
f0103e45:	8d 45 14             	lea    0x14(%ebp),%eax
f0103e48:	e8 25 f9 ff ff       	call   f0103772 <getuint>
f0103e4d:	89 c3                	mov    %eax,%ebx
            unsigned int ttemp=(unsigned int)num;
	    char* temp=(char *)ttemp;
	    if (!temp) { printfmt(putch,putdat,"%s",null_error); break;}
f0103e4f:	85 c0                	test   %eax,%eax
f0103e51:	75 24                	jne    f0103e77 <vprintfmt+0x64c>
f0103e53:	c7 44 24 0c 04 5b 10 	movl   $0xf0105b04,0xc(%esp)
f0103e5a:	f0 
f0103e5b:	c7 44 24 08 b1 57 10 	movl   $0xf01057b1,0x8(%esp)
f0103e62:	f0 
f0103e63:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103e67:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103e6a:	89 1c 24             	mov    %ebx,(%esp)
f0103e6d:	e8 91 f9 ff ff       	call   f0103803 <printfmt>
f0103e72:	e9 c7 00 00 00       	jmp    f0103f3e <vprintfmt+0x713>
	    //printfmt(putch,putdat,"%d\n",*(unsigned int*)putdat);
	    unsigned int ttt=*(unsigned int*)putdat;
f0103e77:	8b 37                	mov    (%edi),%esi
            if (ttt>127) 
f0103e79:	83 fe 7f             	cmp    $0x7f,%esi
f0103e7c:	76 32                	jbe    f0103eb0 <vprintfmt+0x685>
	    {
                printfmt(putch,putdat,"%s",overflow_error); 
f0103e7e:	c7 44 24 0c 3c 5b 10 	movl   $0xf0105b3c,0xc(%esp)
f0103e85:	f0 
f0103e86:	c7 44 24 08 b1 57 10 	movl   $0xf01057b1,0x8(%esp)
f0103e8d:	f0 
f0103e8e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103e92:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e95:	89 04 24             	mov    %eax,(%esp)
f0103e98:	e8 66 f9 ff ff       	call   f0103803 <printfmt>
	        if (ttt<256) *temp=ttt;
f0103e9d:	81 fe 00 01 00 00    	cmp    $0x100,%esi
f0103ea3:	19 c0                	sbb    %eax,%eax
f0103ea5:	f7 d0                	not    %eax
f0103ea7:	09 f0                	or     %esi,%eax
f0103ea9:	88 03                	mov    %al,(%ebx)
f0103eab:	e9 8e 00 00 00       	jmp    f0103f3e <vprintfmt+0x713>
 		else *temp=-1;
                break;
	    }
	    *temp=*(char*)putdat;
f0103eb0:	0f b6 07             	movzbl (%edi),%eax
f0103eb3:	88 03                	mov    %al,(%ebx)
f0103eb5:	e9 84 00 00 00       	jmp    f0103f3e <vprintfmt+0x713>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103eba:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103ebe:	89 0c 24             	mov    %ecx,(%esp)
f0103ec1:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103ec4:	ff d3                	call   *%ebx
f0103ec6:	eb 76                	jmp    f0103f3e <vprintfmt+0x713>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103ec8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103ecc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0103ed3:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ed6:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103ed8:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0103edc:	74 5a                	je     f0103f38 <vprintfmt+0x70d>
f0103ede:	83 eb 01             	sub    $0x1,%ebx
f0103ee1:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0103ee5:	75 f7                	jne    f0103ede <vprintfmt+0x6b3>
f0103ee7:	89 9d d4 fe ff ff    	mov    %ebx,-0x12c(%ebp)
f0103eed:	eb 4f                	jmp    f0103f3e <vprintfmt+0x713>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103eef:	8b 9d d4 fe ff ff    	mov    -0x12c(%ebp),%ebx
                case '+':
			padc = '+';
f0103ef5:	c6 85 d8 fe ff ff 2b 	movb   $0x2b,-0x128(%ebp)
f0103efc:	e9 86 f9 ff ff       	jmp    f0103887 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f01:	8b 9d d4 fe ff ff    	mov    -0x12c(%ebp),%ebx
			padc = '+';
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
f0103f07:	c6 85 d8 fe ff ff 2d 	movb   $0x2d,-0x128(%ebp)
f0103f0e:	e9 74 f9 ff ff       	jmp    f0103887 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f13:	8b 9d d4 fe ff ff    	mov    -0x12c(%ebp),%ebx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0103f19:	c7 85 e0 fe ff ff 00 	movl   $0x0,-0x120(%ebp)
f0103f20:	00 00 00 
f0103f23:	e9 5f f9 ff ff       	jmp    f0103887 <vprintfmt+0x5c>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0103f28:	89 b5 e0 fe ff ff    	mov    %esi,-0x120(%ebp)
f0103f2e:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0103f33:	e9 4f f9 ff ff       	jmp    f0103887 <vprintfmt+0x5c>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103f38:	89 9d d4 fe ff ff    	mov    %ebx,-0x12c(%ebp)
				/* do nothing */;
			break;
		}
	}
f0103f3e:	8b 9d d4 fe ff ff    	mov    -0x12c(%ebp),%ebx
f0103f44:	e9 0e f9 ff ff       	jmp    f0103857 <vprintfmt+0x2c>
				a[i]=temp & 7;
				temp=temp>>3;
				i++;
			}
			i--;
			putch('0', putdat);
f0103f49:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103f4d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0103f54:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103f57:	ff d3                	call   *%ebx
f0103f59:	eb e3                	jmp    f0103f3e <vprintfmt+0x713>
		if (padc!='-') while (--width > 0)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103f5b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103f5f:	8b 74 24 04          	mov    0x4(%esp),%esi
f0103f63:	8b 85 d8 fe ff ff    	mov    -0x128(%ebp),%eax
f0103f69:	8b 95 dc fe ff ff    	mov    -0x124(%ebp),%edx
f0103f6f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f73:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103f77:	8b 95 c8 fe ff ff    	mov    -0x138(%ebp),%edx
f0103f7d:	8b 8d cc fe ff ff    	mov    -0x134(%ebp),%ecx
f0103f83:	89 14 24             	mov    %edx,(%esp)
f0103f86:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103f8a:	e8 21 08 00 00       	call   f01047b0 <__umoddi3>
f0103f8f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103f93:	0f be 80 77 5a 10 f0 	movsbl -0xfefa589(%eax),%eax
f0103f9a:	89 04 24             	mov    %eax,(%esp)
f0103f9d:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103fa0:	ff d3                	call   *%ebx
f0103fa2:	eb 9a                	jmp    f0103f3e <vprintfmt+0x713>
f0103fa4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103fa8:	8b 74 24 04          	mov    0x4(%esp),%esi
f0103fac:	8b 85 d8 fe ff ff    	mov    -0x128(%ebp),%eax
f0103fb2:	8b 95 dc fe ff ff    	mov    -0x124(%ebp),%edx
f0103fb8:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103fbc:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103fc0:	8b 95 c8 fe ff ff    	mov    -0x138(%ebp),%edx
f0103fc6:	8b 8d cc fe ff ff    	mov    -0x134(%ebp),%ecx
f0103fcc:	89 14 24             	mov    %edx,(%esp)
f0103fcf:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103fd3:	e8 d8 07 00 00       	call   f01047b0 <__umoddi3>
f0103fd8:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103fdc:	0f be 80 77 5a 10 f0 	movsbl -0xfefa589(%eax),%eax
f0103fe3:	89 04 24             	mov    %eax,(%esp)
f0103fe6:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103fe9:	ff d3                	call   *%ebx
f0103feb:	e9 23 fe ff ff       	jmp    f0103e13 <vprintfmt+0x5e8>
	// you can add helper function if needed.
	// your code here:

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		_printnum(putch, putdat, num / base, base, width - 1, padc);
f0103ff0:	c7 44 24 10 2b 00 00 	movl   $0x2b,0x10(%esp)
f0103ff7:	00 
f0103ff8:	8b 85 e0 fe ff ff    	mov    -0x120(%ebp),%eax
f0103ffe:	83 e8 01             	sub    $0x1,%eax
f0104001:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104005:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f010400c:	00 
f010400d:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104011:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0104015:	89 85 e0 fe ff ff    	mov    %eax,-0x120(%ebp)
f010401b:	89 95 e4 fe ff ff    	mov    %edx,-0x11c(%ebp)
f0104021:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f0104028:	00 
f0104029:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104030:	00 
f0104031:	8b 95 c0 fe ff ff    	mov    -0x140(%ebp),%edx
f0104037:	8b 8d c4 fe ff ff    	mov    -0x13c(%ebp),%ecx
f010403d:	89 14 24             	mov    %edx,(%esp)
f0104040:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104044:	e8 07 06 00 00       	call   f0104650 <__udivdi3>
f0104049:	8b 8d e0 fe ff ff    	mov    -0x120(%ebp),%ecx
f010404f:	8b 9d e4 fe ff ff    	mov    -0x11c(%ebp),%ebx
f0104055:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104059:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010405d:	89 04 24             	mov    %eax,(%esp)
f0104060:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104064:	89 fa                	mov    %edi,%edx
f0104066:	8b 45 08             	mov    0x8(%ebp),%eax
f0104069:	e8 12 f6 ff ff       	call   f0103680 <_printnum>
		if (padc!='-') while (--width > 0)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010406e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104072:	8b 74 24 04          	mov    0x4(%esp),%esi
f0104076:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f010407d:	00 
f010407e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104085:	00 
f0104086:	8b 85 c0 fe ff ff    	mov    -0x140(%ebp),%eax
f010408c:	8b 95 c4 fe ff ff    	mov    -0x13c(%ebp),%edx
f0104092:	89 04 24             	mov    %eax,(%esp)
f0104095:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104099:	e8 12 07 00 00       	call   f01047b0 <__umoddi3>
f010409e:	89 74 24 04          	mov    %esi,0x4(%esp)
f01040a2:	0f be 80 77 5a 10 f0 	movsbl -0xfefa589(%eax),%eax
f01040a9:	89 04 24             	mov    %eax,(%esp)
f01040ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01040af:	ff d3                	call   *%ebx
f01040b1:	e9 88 fe ff ff       	jmp    f0103f3e <vprintfmt+0x713>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
f01040b6:	81 c4 5c 01 00 00    	add    $0x15c,%esp
f01040bc:	5b                   	pop    %ebx
f01040bd:	5e                   	pop    %esi
f01040be:	5f                   	pop    %edi
f01040bf:	5d                   	pop    %ebp
f01040c0:	c3                   	ret    

f01040c1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01040c1:	55                   	push   %ebp
f01040c2:	89 e5                	mov    %esp,%ebp
f01040c4:	83 ec 28             	sub    $0x28,%esp
f01040c7:	8b 45 08             	mov    0x8(%ebp),%eax
f01040ca:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01040cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01040d0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01040d4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01040d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01040de:	85 d2                	test   %edx,%edx
f01040e0:	7e 30                	jle    f0104112 <vsnprintf+0x51>
f01040e2:	85 c0                	test   %eax,%eax
f01040e4:	74 2c                	je     f0104112 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01040e6:	8b 45 14             	mov    0x14(%ebp),%eax
f01040e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01040ed:	8b 45 10             	mov    0x10(%ebp),%eax
f01040f0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01040f4:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01040f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040fb:	c7 04 24 e6 37 10 f0 	movl   $0xf01037e6,(%esp)
f0104102:	e8 24 f7 ff ff       	call   f010382b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104107:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010410a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010410d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104110:	eb 05                	jmp    f0104117 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0104112:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0104117:	c9                   	leave  
f0104118:	c3                   	ret    

f0104119 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104119:	55                   	push   %ebp
f010411a:	89 e5                	mov    %esp,%ebp
f010411c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010411f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104122:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104126:	8b 45 10             	mov    0x10(%ebp),%eax
f0104129:	89 44 24 08          	mov    %eax,0x8(%esp)
f010412d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104130:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104134:	8b 45 08             	mov    0x8(%ebp),%eax
f0104137:	89 04 24             	mov    %eax,(%esp)
f010413a:	e8 82 ff ff ff       	call   f01040c1 <vsnprintf>
	va_end(ap);

	return rc;
}
f010413f:	c9                   	leave  
f0104140:	c3                   	ret    
	...

f0104150 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104150:	55                   	push   %ebp
f0104151:	89 e5                	mov    %esp,%ebp
f0104153:	57                   	push   %edi
f0104154:	56                   	push   %esi
f0104155:	53                   	push   %ebx
f0104156:	83 ec 1c             	sub    $0x1c,%esp
f0104159:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010415c:	85 c0                	test   %eax,%eax
f010415e:	74 10                	je     f0104170 <readline+0x20>
		cprintf("%s", prompt);
f0104160:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104164:	c7 04 24 b1 57 10 f0 	movl   $0xf01057b1,(%esp)
f010416b:	e8 8d f1 ff ff       	call   f01032fd <cprintf>

	i = 0;
	echoing = iscons(0);
f0104170:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104177:	e8 a3 c5 ff ff       	call   f010071f <iscons>
f010417c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010417e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104183:	e8 86 c5 ff ff       	call   f010070e <getchar>
f0104188:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010418a:	85 c0                	test   %eax,%eax
f010418c:	79 17                	jns    f01041a5 <readline+0x55>
			cprintf("read error: %e\n", c);
f010418e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104192:	c7 04 24 f4 5c 10 f0 	movl   $0xf0105cf4,(%esp)
f0104199:	e8 5f f1 ff ff       	call   f01032fd <cprintf>
			return NULL;
f010419e:	b8 00 00 00 00       	mov    $0x0,%eax
f01041a3:	eb 6d                	jmp    f0104212 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01041a5:	83 f8 7f             	cmp    $0x7f,%eax
f01041a8:	74 05                	je     f01041af <readline+0x5f>
f01041aa:	83 f8 08             	cmp    $0x8,%eax
f01041ad:	75 19                	jne    f01041c8 <readline+0x78>
f01041af:	85 f6                	test   %esi,%esi
f01041b1:	7e 15                	jle    f01041c8 <readline+0x78>
			if (echoing)
f01041b3:	85 ff                	test   %edi,%edi
f01041b5:	74 0c                	je     f01041c3 <readline+0x73>
				cputchar('\b');
f01041b7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f01041be:	e8 3b c5 ff ff       	call   f01006fe <cputchar>
			i--;
f01041c3:	83 ee 01             	sub    $0x1,%esi
f01041c6:	eb bb                	jmp    f0104183 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01041c8:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01041ce:	7f 1c                	jg     f01041ec <readline+0x9c>
f01041d0:	83 fb 1f             	cmp    $0x1f,%ebx
f01041d3:	7e 17                	jle    f01041ec <readline+0x9c>
			if (echoing)
f01041d5:	85 ff                	test   %edi,%edi
f01041d7:	74 08                	je     f01041e1 <readline+0x91>
				cputchar(c);
f01041d9:	89 1c 24             	mov    %ebx,(%esp)
f01041dc:	e8 1d c5 ff ff       	call   f01006fe <cputchar>
			buf[i++] = c;
f01041e1:	88 9e 80 95 11 f0    	mov    %bl,-0xfee6a80(%esi)
f01041e7:	83 c6 01             	add    $0x1,%esi
f01041ea:	eb 97                	jmp    f0104183 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01041ec:	83 fb 0d             	cmp    $0xd,%ebx
f01041ef:	74 05                	je     f01041f6 <readline+0xa6>
f01041f1:	83 fb 0a             	cmp    $0xa,%ebx
f01041f4:	75 8d                	jne    f0104183 <readline+0x33>
			if (echoing)
f01041f6:	85 ff                	test   %edi,%edi
f01041f8:	74 0c                	je     f0104206 <readline+0xb6>
				cputchar('\n');
f01041fa:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0104201:	e8 f8 c4 ff ff       	call   f01006fe <cputchar>
			buf[i] = 0;
f0104206:	c6 86 80 95 11 f0 00 	movb   $0x0,-0xfee6a80(%esi)
			return buf;
f010420d:	b8 80 95 11 f0       	mov    $0xf0119580,%eax
		}
	}
}
f0104212:	83 c4 1c             	add    $0x1c,%esp
f0104215:	5b                   	pop    %ebx
f0104216:	5e                   	pop    %esi
f0104217:	5f                   	pop    %edi
f0104218:	5d                   	pop    %ebp
f0104219:	c3                   	ret    
f010421a:	00 00                	add    %al,(%eax)
f010421c:	00 00                	add    %al,(%eax)
	...

f0104220 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104220:	55                   	push   %ebp
f0104221:	89 e5                	mov    %esp,%ebp
f0104223:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104226:	80 3a 00             	cmpb   $0x0,(%edx)
f0104229:	74 10                	je     f010423b <strlen+0x1b>
f010422b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0104230:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0104233:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104237:	75 f7                	jne    f0104230 <strlen+0x10>
f0104239:	eb 05                	jmp    f0104240 <strlen+0x20>
f010423b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0104240:	5d                   	pop    %ebp
f0104241:	c3                   	ret    

f0104242 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104242:	55                   	push   %ebp
f0104243:	89 e5                	mov    %esp,%ebp
f0104245:	53                   	push   %ebx
f0104246:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104249:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010424c:	85 c9                	test   %ecx,%ecx
f010424e:	74 1c                	je     f010426c <strnlen+0x2a>
f0104250:	80 3b 00             	cmpb   $0x0,(%ebx)
f0104253:	74 1e                	je     f0104273 <strnlen+0x31>
f0104255:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f010425a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010425c:	39 ca                	cmp    %ecx,%edx
f010425e:	74 18                	je     f0104278 <strnlen+0x36>
f0104260:	83 c2 01             	add    $0x1,%edx
f0104263:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0104268:	75 f0                	jne    f010425a <strnlen+0x18>
f010426a:	eb 0c                	jmp    f0104278 <strnlen+0x36>
f010426c:	b8 00 00 00 00       	mov    $0x0,%eax
f0104271:	eb 05                	jmp    f0104278 <strnlen+0x36>
f0104273:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0104278:	5b                   	pop    %ebx
f0104279:	5d                   	pop    %ebp
f010427a:	c3                   	ret    

f010427b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010427b:	55                   	push   %ebp
f010427c:	89 e5                	mov    %esp,%ebp
f010427e:	53                   	push   %ebx
f010427f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104285:	89 c2                	mov    %eax,%edx
f0104287:	0f b6 19             	movzbl (%ecx),%ebx
f010428a:	88 1a                	mov    %bl,(%edx)
f010428c:	83 c2 01             	add    $0x1,%edx
f010428f:	83 c1 01             	add    $0x1,%ecx
f0104292:	84 db                	test   %bl,%bl
f0104294:	75 f1                	jne    f0104287 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0104296:	5b                   	pop    %ebx
f0104297:	5d                   	pop    %ebp
f0104298:	c3                   	ret    

f0104299 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104299:	55                   	push   %ebp
f010429a:	89 e5                	mov    %esp,%ebp
f010429c:	56                   	push   %esi
f010429d:	53                   	push   %ebx
f010429e:	8b 75 08             	mov    0x8(%ebp),%esi
f01042a1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01042a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01042a7:	85 db                	test   %ebx,%ebx
f01042a9:	74 16                	je     f01042c1 <strncpy+0x28>
		/* do nothing */;
	return ret;
}

char *
strncpy(char *dst, const char *src, size_t size) {
f01042ab:	01 f3                	add    %esi,%ebx
f01042ad:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
f01042af:	0f b6 02             	movzbl (%edx),%eax
f01042b2:	88 01                	mov    %al,(%ecx)
f01042b4:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01042b7:	80 3a 01             	cmpb   $0x1,(%edx)
f01042ba:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01042bd:	39 d9                	cmp    %ebx,%ecx
f01042bf:	75 ee                	jne    f01042af <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01042c1:	89 f0                	mov    %esi,%eax
f01042c3:	5b                   	pop    %ebx
f01042c4:	5e                   	pop    %esi
f01042c5:	5d                   	pop    %ebp
f01042c6:	c3                   	ret    

f01042c7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01042c7:	55                   	push   %ebp
f01042c8:	89 e5                	mov    %esp,%ebp
f01042ca:	57                   	push   %edi
f01042cb:	56                   	push   %esi
f01042cc:	53                   	push   %ebx
f01042cd:	8b 7d 08             	mov    0x8(%ebp),%edi
f01042d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01042d3:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01042d6:	89 f8                	mov    %edi,%eax
f01042d8:	85 f6                	test   %esi,%esi
f01042da:	74 33                	je     f010430f <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
f01042dc:	83 fe 01             	cmp    $0x1,%esi
f01042df:	74 25                	je     f0104306 <strlcpy+0x3f>
f01042e1:	0f b6 0b             	movzbl (%ebx),%ecx
f01042e4:	84 c9                	test   %cl,%cl
f01042e6:	74 22                	je     f010430a <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f01042e8:	83 ee 02             	sub    $0x2,%esi
f01042eb:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01042f0:	88 08                	mov    %cl,(%eax)
f01042f2:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01042f5:	39 f2                	cmp    %esi,%edx
f01042f7:	74 13                	je     f010430c <strlcpy+0x45>
f01042f9:	83 c2 01             	add    $0x1,%edx
f01042fc:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0104300:	84 c9                	test   %cl,%cl
f0104302:	75 ec                	jne    f01042f0 <strlcpy+0x29>
f0104304:	eb 06                	jmp    f010430c <strlcpy+0x45>
f0104306:	89 f8                	mov    %edi,%eax
f0104308:	eb 02                	jmp    f010430c <strlcpy+0x45>
f010430a:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f010430c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010430f:	29 f8                	sub    %edi,%eax
}
f0104311:	5b                   	pop    %ebx
f0104312:	5e                   	pop    %esi
f0104313:	5f                   	pop    %edi
f0104314:	5d                   	pop    %ebp
f0104315:	c3                   	ret    

f0104316 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104316:	55                   	push   %ebp
f0104317:	89 e5                	mov    %esp,%ebp
f0104319:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010431c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010431f:	0f b6 01             	movzbl (%ecx),%eax
f0104322:	84 c0                	test   %al,%al
f0104324:	74 15                	je     f010433b <strcmp+0x25>
f0104326:	3a 02                	cmp    (%edx),%al
f0104328:	75 11                	jne    f010433b <strcmp+0x25>
		p++, q++;
f010432a:	83 c1 01             	add    $0x1,%ecx
f010432d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0104330:	0f b6 01             	movzbl (%ecx),%eax
f0104333:	84 c0                	test   %al,%al
f0104335:	74 04                	je     f010433b <strcmp+0x25>
f0104337:	3a 02                	cmp    (%edx),%al
f0104339:	74 ef                	je     f010432a <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010433b:	0f b6 c0             	movzbl %al,%eax
f010433e:	0f b6 12             	movzbl (%edx),%edx
f0104341:	29 d0                	sub    %edx,%eax
}
f0104343:	5d                   	pop    %ebp
f0104344:	c3                   	ret    

f0104345 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104345:	55                   	push   %ebp
f0104346:	89 e5                	mov    %esp,%ebp
f0104348:	56                   	push   %esi
f0104349:	53                   	push   %ebx
f010434a:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010434d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104350:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
f0104353:	85 f6                	test   %esi,%esi
f0104355:	74 29                	je     f0104380 <strncmp+0x3b>
f0104357:	0f b6 03             	movzbl (%ebx),%eax
f010435a:	84 c0                	test   %al,%al
f010435c:	74 30                	je     f010438e <strncmp+0x49>
f010435e:	3a 02                	cmp    (%edx),%al
f0104360:	75 2c                	jne    f010438e <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
f0104362:	8d 43 01             	lea    0x1(%ebx),%eax
f0104365:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
f0104367:	89 c3                	mov    %eax,%ebx
f0104369:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010436c:	39 f0                	cmp    %esi,%eax
f010436e:	74 17                	je     f0104387 <strncmp+0x42>
f0104370:	0f b6 08             	movzbl (%eax),%ecx
f0104373:	84 c9                	test   %cl,%cl
f0104375:	74 17                	je     f010438e <strncmp+0x49>
f0104377:	83 c0 01             	add    $0x1,%eax
f010437a:	3a 0a                	cmp    (%edx),%cl
f010437c:	74 e9                	je     f0104367 <strncmp+0x22>
f010437e:	eb 0e                	jmp    f010438e <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104380:	b8 00 00 00 00       	mov    $0x0,%eax
f0104385:	eb 0f                	jmp    f0104396 <strncmp+0x51>
f0104387:	b8 00 00 00 00       	mov    $0x0,%eax
f010438c:	eb 08                	jmp    f0104396 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010438e:	0f b6 03             	movzbl (%ebx),%eax
f0104391:	0f b6 12             	movzbl (%edx),%edx
f0104394:	29 d0                	sub    %edx,%eax
}
f0104396:	5b                   	pop    %ebx
f0104397:	5e                   	pop    %esi
f0104398:	5d                   	pop    %ebp
f0104399:	c3                   	ret    

f010439a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010439a:	55                   	push   %ebp
f010439b:	89 e5                	mov    %esp,%ebp
f010439d:	8b 45 08             	mov    0x8(%ebp),%eax
f01043a0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01043a4:	0f b6 10             	movzbl (%eax),%edx
f01043a7:	84 d2                	test   %dl,%dl
f01043a9:	74 1b                	je     f01043c6 <strchr+0x2c>
		if (*s == c)
f01043ab:	38 ca                	cmp    %cl,%dl
f01043ad:	75 06                	jne    f01043b5 <strchr+0x1b>
f01043af:	eb 1a                	jmp    f01043cb <strchr+0x31>
f01043b1:	38 ca                	cmp    %cl,%dl
f01043b3:	74 16                	je     f01043cb <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01043b5:	83 c0 01             	add    $0x1,%eax
f01043b8:	0f b6 10             	movzbl (%eax),%edx
f01043bb:	84 d2                	test   %dl,%dl
f01043bd:	75 f2                	jne    f01043b1 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
f01043bf:	b8 00 00 00 00       	mov    $0x0,%eax
f01043c4:	eb 05                	jmp    f01043cb <strchr+0x31>
f01043c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01043cb:	5d                   	pop    %ebp
f01043cc:	c3                   	ret    

f01043cd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01043cd:	55                   	push   %ebp
f01043ce:	89 e5                	mov    %esp,%ebp
f01043d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01043d3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01043d7:	0f b6 10             	movzbl (%eax),%edx
f01043da:	84 d2                	test   %dl,%dl
f01043dc:	74 14                	je     f01043f2 <strfind+0x25>
		if (*s == c)
f01043de:	38 ca                	cmp    %cl,%dl
f01043e0:	75 06                	jne    f01043e8 <strfind+0x1b>
f01043e2:	eb 0e                	jmp    f01043f2 <strfind+0x25>
f01043e4:	38 ca                	cmp    %cl,%dl
f01043e6:	74 0a                	je     f01043f2 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01043e8:	83 c0 01             	add    $0x1,%eax
f01043eb:	0f b6 10             	movzbl (%eax),%edx
f01043ee:	84 d2                	test   %dl,%dl
f01043f0:	75 f2                	jne    f01043e4 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f01043f2:	5d                   	pop    %ebp
f01043f3:	c3                   	ret    

f01043f4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01043f4:	55                   	push   %ebp
f01043f5:	89 e5                	mov    %esp,%ebp
f01043f7:	83 ec 0c             	sub    $0xc,%esp
f01043fa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01043fd:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0104400:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0104403:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104406:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104409:	85 c9                	test   %ecx,%ecx
f010440b:	74 36                	je     f0104443 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010440d:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104413:	75 28                	jne    f010443d <memset+0x49>
f0104415:	f6 c1 03             	test   $0x3,%cl
f0104418:	75 23                	jne    f010443d <memset+0x49>
		c &= 0xFF;
f010441a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010441e:	89 d3                	mov    %edx,%ebx
f0104420:	c1 e3 08             	shl    $0x8,%ebx
f0104423:	89 d6                	mov    %edx,%esi
f0104425:	c1 e6 18             	shl    $0x18,%esi
f0104428:	89 d0                	mov    %edx,%eax
f010442a:	c1 e0 10             	shl    $0x10,%eax
f010442d:	09 f0                	or     %esi,%eax
f010442f:	09 c2                	or     %eax,%edx
f0104431:	89 d0                	mov    %edx,%eax
f0104433:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0104435:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0104438:	fc                   	cld    
f0104439:	f3 ab                	rep stos %eax,%es:(%edi)
f010443b:	eb 06                	jmp    f0104443 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010443d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104440:	fc                   	cld    
f0104441:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104443:	89 f8                	mov    %edi,%eax
f0104445:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0104448:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010444b:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010444e:	89 ec                	mov    %ebp,%esp
f0104450:	5d                   	pop    %ebp
f0104451:	c3                   	ret    

f0104452 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104452:	55                   	push   %ebp
f0104453:	89 e5                	mov    %esp,%ebp
f0104455:	83 ec 08             	sub    $0x8,%esp
f0104458:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010445b:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010445e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104461:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104464:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104467:	39 c6                	cmp    %eax,%esi
f0104469:	73 36                	jae    f01044a1 <memmove+0x4f>
f010446b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010446e:	39 d0                	cmp    %edx,%eax
f0104470:	73 2f                	jae    f01044a1 <memmove+0x4f>
		s += n;
		d += n;
f0104472:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104475:	f6 c2 03             	test   $0x3,%dl
f0104478:	75 1b                	jne    f0104495 <memmove+0x43>
f010447a:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104480:	75 13                	jne    f0104495 <memmove+0x43>
f0104482:	f6 c1 03             	test   $0x3,%cl
f0104485:	75 0e                	jne    f0104495 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0104487:	83 ef 04             	sub    $0x4,%edi
f010448a:	8d 72 fc             	lea    -0x4(%edx),%esi
f010448d:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0104490:	fd                   	std    
f0104491:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104493:	eb 09                	jmp    f010449e <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0104495:	83 ef 01             	sub    $0x1,%edi
f0104498:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010449b:	fd                   	std    
f010449c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010449e:	fc                   	cld    
f010449f:	eb 20                	jmp    f01044c1 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01044a1:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01044a7:	75 13                	jne    f01044bc <memmove+0x6a>
f01044a9:	a8 03                	test   $0x3,%al
f01044ab:	75 0f                	jne    f01044bc <memmove+0x6a>
f01044ad:	f6 c1 03             	test   $0x3,%cl
f01044b0:	75 0a                	jne    f01044bc <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01044b2:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01044b5:	89 c7                	mov    %eax,%edi
f01044b7:	fc                   	cld    
f01044b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01044ba:	eb 05                	jmp    f01044c1 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01044bc:	89 c7                	mov    %eax,%edi
f01044be:	fc                   	cld    
f01044bf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01044c1:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01044c4:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01044c7:	89 ec                	mov    %ebp,%esp
f01044c9:	5d                   	pop    %ebp
f01044ca:	c3                   	ret    

f01044cb <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f01044cb:	55                   	push   %ebp
f01044cc:	89 e5                	mov    %esp,%ebp
f01044ce:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01044d1:	8b 45 10             	mov    0x10(%ebp),%eax
f01044d4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01044d8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01044db:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044df:	8b 45 08             	mov    0x8(%ebp),%eax
f01044e2:	89 04 24             	mov    %eax,(%esp)
f01044e5:	e8 68 ff ff ff       	call   f0104452 <memmove>
}
f01044ea:	c9                   	leave  
f01044eb:	c3                   	ret    

f01044ec <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01044ec:	55                   	push   %ebp
f01044ed:	89 e5                	mov    %esp,%ebp
f01044ef:	57                   	push   %edi
f01044f0:	56                   	push   %esi
f01044f1:	53                   	push   %ebx
f01044f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01044f5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01044f8:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01044fb:	8d 78 ff             	lea    -0x1(%eax),%edi
f01044fe:	85 c0                	test   %eax,%eax
f0104500:	74 36                	je     f0104538 <memcmp+0x4c>
		if (*s1 != *s2)
f0104502:	0f b6 03             	movzbl (%ebx),%eax
f0104505:	0f b6 0e             	movzbl (%esi),%ecx
f0104508:	38 c8                	cmp    %cl,%al
f010450a:	75 17                	jne    f0104523 <memcmp+0x37>
f010450c:	ba 00 00 00 00       	mov    $0x0,%edx
f0104511:	eb 1a                	jmp    f010452d <memcmp+0x41>
f0104513:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f0104518:	83 c2 01             	add    $0x1,%edx
f010451b:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f010451f:	38 c8                	cmp    %cl,%al
f0104521:	74 0a                	je     f010452d <memcmp+0x41>
			return (int) *s1 - (int) *s2;
f0104523:	0f b6 c0             	movzbl %al,%eax
f0104526:	0f b6 c9             	movzbl %cl,%ecx
f0104529:	29 c8                	sub    %ecx,%eax
f010452b:	eb 10                	jmp    f010453d <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010452d:	39 fa                	cmp    %edi,%edx
f010452f:	75 e2                	jne    f0104513 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0104531:	b8 00 00 00 00       	mov    $0x0,%eax
f0104536:	eb 05                	jmp    f010453d <memcmp+0x51>
f0104538:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010453d:	5b                   	pop    %ebx
f010453e:	5e                   	pop    %esi
f010453f:	5f                   	pop    %edi
f0104540:	5d                   	pop    %ebp
f0104541:	c3                   	ret    

f0104542 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104542:	55                   	push   %ebp
f0104543:	89 e5                	mov    %esp,%ebp
f0104545:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0104548:	89 c2                	mov    %eax,%edx
f010454a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010454d:	39 d0                	cmp    %edx,%eax
f010454f:	73 18                	jae    f0104569 <memfind+0x27>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104551:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0104555:	38 08                	cmp    %cl,(%eax)
f0104557:	75 09                	jne    f0104562 <memfind+0x20>
f0104559:	eb 0e                	jmp    f0104569 <memfind+0x27>
f010455b:	38 08                	cmp    %cl,(%eax)
f010455d:	8d 76 00             	lea    0x0(%esi),%esi
f0104560:	74 07                	je     f0104569 <memfind+0x27>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104562:	83 c0 01             	add    $0x1,%eax
f0104565:	39 d0                	cmp    %edx,%eax
f0104567:	75 f2                	jne    f010455b <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104569:	5d                   	pop    %ebp
f010456a:	c3                   	ret    

f010456b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010456b:	55                   	push   %ebp
f010456c:	89 e5                	mov    %esp,%ebp
f010456e:	57                   	push   %edi
f010456f:	56                   	push   %esi
f0104570:	53                   	push   %ebx
f0104571:	83 ec 04             	sub    $0x4,%esp
f0104574:	8b 55 08             	mov    0x8(%ebp),%edx
f0104577:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010457a:	0f b6 02             	movzbl (%edx),%eax
f010457d:	3c 09                	cmp    $0x9,%al
f010457f:	74 04                	je     f0104585 <strtol+0x1a>
f0104581:	3c 20                	cmp    $0x20,%al
f0104583:	75 0e                	jne    f0104593 <strtol+0x28>
		s++;
f0104585:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104588:	0f b6 02             	movzbl (%edx),%eax
f010458b:	3c 09                	cmp    $0x9,%al
f010458d:	74 f6                	je     f0104585 <strtol+0x1a>
f010458f:	3c 20                	cmp    $0x20,%al
f0104591:	74 f2                	je     f0104585 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104593:	3c 2b                	cmp    $0x2b,%al
f0104595:	75 0a                	jne    f01045a1 <strtol+0x36>
		s++;
f0104597:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010459a:	bf 00 00 00 00       	mov    $0x0,%edi
f010459f:	eb 10                	jmp    f01045b1 <strtol+0x46>
f01045a1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01045a6:	3c 2d                	cmp    $0x2d,%al
f01045a8:	75 07                	jne    f01045b1 <strtol+0x46>
		s++, neg = 1;
f01045aa:	83 c2 01             	add    $0x1,%edx
f01045ad:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01045b1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01045b7:	75 15                	jne    f01045ce <strtol+0x63>
f01045b9:	80 3a 30             	cmpb   $0x30,(%edx)
f01045bc:	75 10                	jne    f01045ce <strtol+0x63>
f01045be:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01045c2:	75 0a                	jne    f01045ce <strtol+0x63>
		s += 2, base = 16;
f01045c4:	83 c2 02             	add    $0x2,%edx
f01045c7:	bb 10 00 00 00       	mov    $0x10,%ebx
f01045cc:	eb 10                	jmp    f01045de <strtol+0x73>
	else if (base == 0 && s[0] == '0')
f01045ce:	85 db                	test   %ebx,%ebx
f01045d0:	75 0c                	jne    f01045de <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01045d2:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01045d4:	80 3a 30             	cmpb   $0x30,(%edx)
f01045d7:	75 05                	jne    f01045de <strtol+0x73>
		s++, base = 8;
f01045d9:	83 c2 01             	add    $0x1,%edx
f01045dc:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f01045de:	b8 00 00 00 00       	mov    $0x0,%eax
f01045e3:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01045e6:	0f b6 0a             	movzbl (%edx),%ecx
f01045e9:	8d 71 d0             	lea    -0x30(%ecx),%esi
f01045ec:	89 f3                	mov    %esi,%ebx
f01045ee:	80 fb 09             	cmp    $0x9,%bl
f01045f1:	77 08                	ja     f01045fb <strtol+0x90>
			dig = *s - '0';
f01045f3:	0f be c9             	movsbl %cl,%ecx
f01045f6:	83 e9 30             	sub    $0x30,%ecx
f01045f9:	eb 22                	jmp    f010461d <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
f01045fb:	8d 71 9f             	lea    -0x61(%ecx),%esi
f01045fe:	89 f3                	mov    %esi,%ebx
f0104600:	80 fb 19             	cmp    $0x19,%bl
f0104603:	77 08                	ja     f010460d <strtol+0xa2>
			dig = *s - 'a' + 10;
f0104605:	0f be c9             	movsbl %cl,%ecx
f0104608:	83 e9 57             	sub    $0x57,%ecx
f010460b:	eb 10                	jmp    f010461d <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
f010460d:	8d 71 bf             	lea    -0x41(%ecx),%esi
f0104610:	89 f3                	mov    %esi,%ebx
f0104612:	80 fb 19             	cmp    $0x19,%bl
f0104615:	77 16                	ja     f010462d <strtol+0xc2>
			dig = *s - 'A' + 10;
f0104617:	0f be c9             	movsbl %cl,%ecx
f010461a:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010461d:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0104620:	7d 0f                	jge    f0104631 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
f0104622:	83 c2 01             	add    $0x1,%edx
f0104625:	0f af 45 f0          	imul   -0x10(%ebp),%eax
f0104629:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f010462b:	eb b9                	jmp    f01045e6 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f010462d:	89 c1                	mov    %eax,%ecx
f010462f:	eb 02                	jmp    f0104633 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0104631:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0104633:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104637:	74 05                	je     f010463e <strtol+0xd3>
		*endptr = (char *) s;
f0104639:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010463c:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f010463e:	85 ff                	test   %edi,%edi
f0104640:	74 04                	je     f0104646 <strtol+0xdb>
f0104642:	89 c8                	mov    %ecx,%eax
f0104644:	f7 d8                	neg    %eax
}
f0104646:	83 c4 04             	add    $0x4,%esp
f0104649:	5b                   	pop    %ebx
f010464a:	5e                   	pop    %esi
f010464b:	5f                   	pop    %edi
f010464c:	5d                   	pop    %ebp
f010464d:	c3                   	ret    
	...

f0104650 <__udivdi3>:
f0104650:	83 ec 1c             	sub    $0x1c,%esp
f0104653:	8b 44 24 2c          	mov    0x2c(%esp),%eax
f0104657:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f010465b:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f010465f:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0104663:	89 74 24 10          	mov    %esi,0x10(%esp)
f0104667:	8b 74 24 24          	mov    0x24(%esp),%esi
f010466b:	85 c0                	test   %eax,%eax
f010466d:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0104671:	89 cf                	mov    %ecx,%edi
f0104673:	89 6c 24 04          	mov    %ebp,0x4(%esp)
f0104677:	75 37                	jne    f01046b0 <__udivdi3+0x60>
f0104679:	39 f1                	cmp    %esi,%ecx
f010467b:	77 73                	ja     f01046f0 <__udivdi3+0xa0>
f010467d:	85 c9                	test   %ecx,%ecx
f010467f:	75 0b                	jne    f010468c <__udivdi3+0x3c>
f0104681:	b8 01 00 00 00       	mov    $0x1,%eax
f0104686:	31 d2                	xor    %edx,%edx
f0104688:	f7 f1                	div    %ecx
f010468a:	89 c1                	mov    %eax,%ecx
f010468c:	89 f0                	mov    %esi,%eax
f010468e:	31 d2                	xor    %edx,%edx
f0104690:	f7 f1                	div    %ecx
f0104692:	89 c6                	mov    %eax,%esi
f0104694:	89 e8                	mov    %ebp,%eax
f0104696:	f7 f1                	div    %ecx
f0104698:	89 f2                	mov    %esi,%edx
f010469a:	8b 74 24 10          	mov    0x10(%esp),%esi
f010469e:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01046a2:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01046a6:	83 c4 1c             	add    $0x1c,%esp
f01046a9:	c3                   	ret    
f01046aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01046b0:	39 f0                	cmp    %esi,%eax
f01046b2:	77 24                	ja     f01046d8 <__udivdi3+0x88>
f01046b4:	0f bd e8             	bsr    %eax,%ebp
f01046b7:	83 f5 1f             	xor    $0x1f,%ebp
f01046ba:	75 4c                	jne    f0104708 <__udivdi3+0xb8>
f01046bc:	31 d2                	xor    %edx,%edx
f01046be:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f01046c2:	0f 86 b0 00 00 00    	jbe    f0104778 <__udivdi3+0x128>
f01046c8:	39 f0                	cmp    %esi,%eax
f01046ca:	0f 82 a8 00 00 00    	jb     f0104778 <__udivdi3+0x128>
f01046d0:	31 c0                	xor    %eax,%eax
f01046d2:	eb c6                	jmp    f010469a <__udivdi3+0x4a>
f01046d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01046d8:	31 d2                	xor    %edx,%edx
f01046da:	31 c0                	xor    %eax,%eax
f01046dc:	8b 74 24 10          	mov    0x10(%esp),%esi
f01046e0:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01046e4:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01046e8:	83 c4 1c             	add    $0x1c,%esp
f01046eb:	c3                   	ret    
f01046ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01046f0:	89 e8                	mov    %ebp,%eax
f01046f2:	89 f2                	mov    %esi,%edx
f01046f4:	f7 f1                	div    %ecx
f01046f6:	31 d2                	xor    %edx,%edx
f01046f8:	8b 74 24 10          	mov    0x10(%esp),%esi
f01046fc:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104700:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0104704:	83 c4 1c             	add    $0x1c,%esp
f0104707:	c3                   	ret    
f0104708:	89 e9                	mov    %ebp,%ecx
f010470a:	89 fa                	mov    %edi,%edx
f010470c:	d3 e0                	shl    %cl,%eax
f010470e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104712:	b8 20 00 00 00       	mov    $0x20,%eax
f0104717:	29 e8                	sub    %ebp,%eax
f0104719:	89 c1                	mov    %eax,%ecx
f010471b:	d3 ea                	shr    %cl,%edx
f010471d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0104721:	09 ca                	or     %ecx,%edx
f0104723:	89 e9                	mov    %ebp,%ecx
f0104725:	d3 e7                	shl    %cl,%edi
f0104727:	89 c1                	mov    %eax,%ecx
f0104729:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010472d:	89 f2                	mov    %esi,%edx
f010472f:	d3 ea                	shr    %cl,%edx
f0104731:	89 e9                	mov    %ebp,%ecx
f0104733:	89 14 24             	mov    %edx,(%esp)
f0104736:	8b 54 24 04          	mov    0x4(%esp),%edx
f010473a:	d3 e6                	shl    %cl,%esi
f010473c:	89 c1                	mov    %eax,%ecx
f010473e:	d3 ea                	shr    %cl,%edx
f0104740:	89 d0                	mov    %edx,%eax
f0104742:	09 f0                	or     %esi,%eax
f0104744:	8b 34 24             	mov    (%esp),%esi
f0104747:	89 f2                	mov    %esi,%edx
f0104749:	f7 74 24 0c          	divl   0xc(%esp)
f010474d:	89 d6                	mov    %edx,%esi
f010474f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104753:	f7 e7                	mul    %edi
f0104755:	39 d6                	cmp    %edx,%esi
f0104757:	72 2f                	jb     f0104788 <__udivdi3+0x138>
f0104759:	8b 7c 24 04          	mov    0x4(%esp),%edi
f010475d:	89 e9                	mov    %ebp,%ecx
f010475f:	d3 e7                	shl    %cl,%edi
f0104761:	39 c7                	cmp    %eax,%edi
f0104763:	73 04                	jae    f0104769 <__udivdi3+0x119>
f0104765:	39 d6                	cmp    %edx,%esi
f0104767:	74 1f                	je     f0104788 <__udivdi3+0x138>
f0104769:	8b 44 24 08          	mov    0x8(%esp),%eax
f010476d:	31 d2                	xor    %edx,%edx
f010476f:	e9 26 ff ff ff       	jmp    f010469a <__udivdi3+0x4a>
f0104774:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104778:	b8 01 00 00 00       	mov    $0x1,%eax
f010477d:	e9 18 ff ff ff       	jmp    f010469a <__udivdi3+0x4a>
f0104782:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104788:	8b 44 24 08          	mov    0x8(%esp),%eax
f010478c:	31 d2                	xor    %edx,%edx
f010478e:	83 e8 01             	sub    $0x1,%eax
f0104791:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104795:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104799:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010479d:	83 c4 1c             	add    $0x1c,%esp
f01047a0:	c3                   	ret    
	...

f01047b0 <__umoddi3>:
f01047b0:	83 ec 1c             	sub    $0x1c,%esp
f01047b3:	8b 54 24 2c          	mov    0x2c(%esp),%edx
f01047b7:	8b 44 24 20          	mov    0x20(%esp),%eax
f01047bb:	89 74 24 10          	mov    %esi,0x10(%esp)
f01047bf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f01047c3:	8b 74 24 24          	mov    0x24(%esp),%esi
f01047c7:	85 d2                	test   %edx,%edx
f01047c9:	89 7c 24 14          	mov    %edi,0x14(%esp)
f01047cd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f01047d1:	89 cf                	mov    %ecx,%edi
f01047d3:	89 c5                	mov    %eax,%ebp
f01047d5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01047d9:	89 34 24             	mov    %esi,(%esp)
f01047dc:	75 22                	jne    f0104800 <__umoddi3+0x50>
f01047de:	39 f1                	cmp    %esi,%ecx
f01047e0:	76 56                	jbe    f0104838 <__umoddi3+0x88>
f01047e2:	89 f2                	mov    %esi,%edx
f01047e4:	f7 f1                	div    %ecx
f01047e6:	89 d0                	mov    %edx,%eax
f01047e8:	31 d2                	xor    %edx,%edx
f01047ea:	8b 74 24 10          	mov    0x10(%esp),%esi
f01047ee:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01047f2:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01047f6:	83 c4 1c             	add    $0x1c,%esp
f01047f9:	c3                   	ret    
f01047fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104800:	39 f2                	cmp    %esi,%edx
f0104802:	77 54                	ja     f0104858 <__umoddi3+0xa8>
f0104804:	0f bd c2             	bsr    %edx,%eax
f0104807:	83 f0 1f             	xor    $0x1f,%eax
f010480a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010480e:	75 60                	jne    f0104870 <__umoddi3+0xc0>
f0104810:	39 e9                	cmp    %ebp,%ecx
f0104812:	0f 87 08 01 00 00    	ja     f0104920 <__umoddi3+0x170>
f0104818:	29 cd                	sub    %ecx,%ebp
f010481a:	19 d6                	sbb    %edx,%esi
f010481c:	89 34 24             	mov    %esi,(%esp)
f010481f:	8b 14 24             	mov    (%esp),%edx
f0104822:	89 e8                	mov    %ebp,%eax
f0104824:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104828:	8b 7c 24 14          	mov    0x14(%esp),%edi
f010482c:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0104830:	83 c4 1c             	add    $0x1c,%esp
f0104833:	c3                   	ret    
f0104834:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104838:	85 c9                	test   %ecx,%ecx
f010483a:	75 0b                	jne    f0104847 <__umoddi3+0x97>
f010483c:	b8 01 00 00 00       	mov    $0x1,%eax
f0104841:	31 d2                	xor    %edx,%edx
f0104843:	f7 f1                	div    %ecx
f0104845:	89 c1                	mov    %eax,%ecx
f0104847:	89 f0                	mov    %esi,%eax
f0104849:	31 d2                	xor    %edx,%edx
f010484b:	f7 f1                	div    %ecx
f010484d:	89 e8                	mov    %ebp,%eax
f010484f:	f7 f1                	div    %ecx
f0104851:	eb 93                	jmp    f01047e6 <__umoddi3+0x36>
f0104853:	90                   	nop
f0104854:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104858:	89 f2                	mov    %esi,%edx
f010485a:	8b 74 24 10          	mov    0x10(%esp),%esi
f010485e:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104862:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0104866:	83 c4 1c             	add    $0x1c,%esp
f0104869:	c3                   	ret    
f010486a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104870:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104875:	bd 20 00 00 00       	mov    $0x20,%ebp
f010487a:	89 f8                	mov    %edi,%eax
f010487c:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f0104880:	d3 e2                	shl    %cl,%edx
f0104882:	89 e9                	mov    %ebp,%ecx
f0104884:	d3 e8                	shr    %cl,%eax
f0104886:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010488b:	09 d0                	or     %edx,%eax
f010488d:	89 f2                	mov    %esi,%edx
f010488f:	89 04 24             	mov    %eax,(%esp)
f0104892:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104896:	d3 e7                	shl    %cl,%edi
f0104898:	89 e9                	mov    %ebp,%ecx
f010489a:	d3 ea                	shr    %cl,%edx
f010489c:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01048a1:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01048a5:	d3 e6                	shl    %cl,%esi
f01048a7:	89 e9                	mov    %ebp,%ecx
f01048a9:	d3 e8                	shr    %cl,%eax
f01048ab:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01048b0:	09 f0                	or     %esi,%eax
f01048b2:	8b 74 24 08          	mov    0x8(%esp),%esi
f01048b6:	f7 34 24             	divl   (%esp)
f01048b9:	d3 e6                	shl    %cl,%esi
f01048bb:	89 74 24 08          	mov    %esi,0x8(%esp)
f01048bf:	89 d6                	mov    %edx,%esi
f01048c1:	f7 e7                	mul    %edi
f01048c3:	39 d6                	cmp    %edx,%esi
f01048c5:	89 c7                	mov    %eax,%edi
f01048c7:	89 d1                	mov    %edx,%ecx
f01048c9:	72 41                	jb     f010490c <__umoddi3+0x15c>
f01048cb:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01048cf:	72 37                	jb     f0104908 <__umoddi3+0x158>
f01048d1:	8b 44 24 08          	mov    0x8(%esp),%eax
f01048d5:	29 f8                	sub    %edi,%eax
f01048d7:	19 ce                	sbb    %ecx,%esi
f01048d9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01048de:	89 f2                	mov    %esi,%edx
f01048e0:	d3 e8                	shr    %cl,%eax
f01048e2:	89 e9                	mov    %ebp,%ecx
f01048e4:	d3 e2                	shl    %cl,%edx
f01048e6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01048eb:	09 d0                	or     %edx,%eax
f01048ed:	89 f2                	mov    %esi,%edx
f01048ef:	d3 ea                	shr    %cl,%edx
f01048f1:	8b 74 24 10          	mov    0x10(%esp),%esi
f01048f5:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01048f9:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01048fd:	83 c4 1c             	add    $0x1c,%esp
f0104900:	c3                   	ret    
f0104901:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104908:	39 d6                	cmp    %edx,%esi
f010490a:	75 c5                	jne    f01048d1 <__umoddi3+0x121>
f010490c:	89 d1                	mov    %edx,%ecx
f010490e:	89 c7                	mov    %eax,%edi
f0104910:	2b 7c 24 0c          	sub    0xc(%esp),%edi
f0104914:	1b 0c 24             	sbb    (%esp),%ecx
f0104917:	eb b8                	jmp    f01048d1 <__umoddi3+0x121>
f0104919:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104920:	39 f2                	cmp    %esi,%edx
f0104922:	0f 82 f0 fe ff ff    	jb     f0104818 <__umoddi3+0x68>
f0104928:	e9 f2 fe ff ff       	jmp    f010481f <__umoddi3+0x6f>
