
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 50 d6 10 80       	mov    $0x8010d650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 8d 3a 10 80       	mov    $0x80103a8d,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	f3 0f 1e fb          	endbr32 
80100038:	55                   	push   %ebp
80100039:	89 e5                	mov    %esp,%ebp
8010003b:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003e:	83 ec 08             	sub    $0x8,%esp
80100041:	68 80 91 10 80       	push   $0x80109180
80100046:	68 60 d6 10 80       	push   $0x8010d660
8010004b:	e8 39 52 00 00       	call   80105289 <initlock>
80100050:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100053:	c7 05 ac 1d 11 80 5c 	movl   $0x80111d5c,0x80111dac
8010005a:	1d 11 80 
  bcache.head.next = &bcache.head;
8010005d:	c7 05 b0 1d 11 80 5c 	movl   $0x80111d5c,0x80111db0
80100064:	1d 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100067:	c7 45 f4 94 d6 10 80 	movl   $0x8010d694,-0xc(%ebp)
8010006e:	eb 47                	jmp    801000b7 <binit+0x83>
    b->next = bcache.head.next;
80100070:	8b 15 b0 1d 11 80    	mov    0x80111db0,%edx
80100076:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100079:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
8010007c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007f:	c7 40 50 5c 1d 11 80 	movl   $0x80111d5c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100086:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100089:	83 c0 0c             	add    $0xc,%eax
8010008c:	83 ec 08             	sub    $0x8,%esp
8010008f:	68 87 91 10 80       	push   $0x80109187
80100094:	50                   	push   %eax
80100095:	e8 5c 50 00 00       	call   801050f6 <initsleeplock>
8010009a:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
8010009d:	a1 b0 1d 11 80       	mov    0x80111db0,%eax
801000a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000a5:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ab:	a3 b0 1d 11 80       	mov    %eax,0x80111db0
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000b0:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b7:	b8 5c 1d 11 80       	mov    $0x80111d5c,%eax
801000bc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000bf:	72 af                	jb     80100070 <binit+0x3c>
  }
}
801000c1:	90                   	nop
801000c2:	90                   	nop
801000c3:	c9                   	leave  
801000c4:	c3                   	ret    

801000c5 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000c5:	f3 0f 1e fb          	endbr32 
801000c9:	55                   	push   %ebp
801000ca:	89 e5                	mov    %esp,%ebp
801000cc:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000cf:	83 ec 0c             	sub    $0xc,%esp
801000d2:	68 60 d6 10 80       	push   $0x8010d660
801000d7:	e8 d3 51 00 00       	call   801052af <acquire>
801000dc:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000df:	a1 b0 1d 11 80       	mov    0x80111db0,%eax
801000e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000e7:	eb 58                	jmp    80100141 <bget+0x7c>
    if(b->dev == dev && b->blockno == blockno){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 40 04             	mov    0x4(%eax),%eax
801000ef:	39 45 08             	cmp    %eax,0x8(%ebp)
801000f2:	75 44                	jne    80100138 <bget+0x73>
801000f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f7:	8b 40 08             	mov    0x8(%eax),%eax
801000fa:	39 45 0c             	cmp    %eax,0xc(%ebp)
801000fd:	75 39                	jne    80100138 <bget+0x73>
      b->refcnt++;
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	8b 40 4c             	mov    0x4c(%eax),%eax
80100105:	8d 50 01             	lea    0x1(%eax),%edx
80100108:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010b:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
8010010e:	83 ec 0c             	sub    $0xc,%esp
80100111:	68 60 d6 10 80       	push   $0x8010d660
80100116:	e8 06 52 00 00       	call   80105321 <release>
8010011b:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	83 c0 0c             	add    $0xc,%eax
80100124:	83 ec 0c             	sub    $0xc,%esp
80100127:	50                   	push   %eax
80100128:	e8 09 50 00 00       	call   80105136 <acquiresleep>
8010012d:	83 c4 10             	add    $0x10,%esp
      return b;
80100130:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100133:	e9 9d 00 00 00       	jmp    801001d5 <bget+0x110>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100138:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010013b:	8b 40 54             	mov    0x54(%eax),%eax
8010013e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100141:	81 7d f4 5c 1d 11 80 	cmpl   $0x80111d5c,-0xc(%ebp)
80100148:	75 9f                	jne    801000e9 <bget+0x24>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
8010014a:	a1 ac 1d 11 80       	mov    0x80111dac,%eax
8010014f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100152:	eb 6b                	jmp    801001bf <bget+0xfa>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
80100154:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100157:	8b 40 4c             	mov    0x4c(%eax),%eax
8010015a:	85 c0                	test   %eax,%eax
8010015c:	75 58                	jne    801001b6 <bget+0xf1>
8010015e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100161:	8b 00                	mov    (%eax),%eax
80100163:	83 e0 04             	and    $0x4,%eax
80100166:	85 c0                	test   %eax,%eax
80100168:	75 4c                	jne    801001b6 <bget+0xf1>
      b->dev = dev;
8010016a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016d:	8b 55 08             	mov    0x8(%ebp),%edx
80100170:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
80100173:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100176:	8b 55 0c             	mov    0xc(%ebp),%edx
80100179:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
8010017c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
80100185:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100188:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
8010018f:	83 ec 0c             	sub    $0xc,%esp
80100192:	68 60 d6 10 80       	push   $0x8010d660
80100197:	e8 85 51 00 00       	call   80105321 <release>
8010019c:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
8010019f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a2:	83 c0 0c             	add    $0xc,%eax
801001a5:	83 ec 0c             	sub    $0xc,%esp
801001a8:	50                   	push   %eax
801001a9:	e8 88 4f 00 00       	call   80105136 <acquiresleep>
801001ae:	83 c4 10             	add    $0x10,%esp
      return b;
801001b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b4:	eb 1f                	jmp    801001d5 <bget+0x110>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b9:	8b 40 50             	mov    0x50(%eax),%eax
801001bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001bf:	81 7d f4 5c 1d 11 80 	cmpl   $0x80111d5c,-0xc(%ebp)
801001c6:	75 8c                	jne    80100154 <bget+0x8f>
    }
  }
  panic("bget: no buffers");
801001c8:	83 ec 0c             	sub    $0xc,%esp
801001cb:	68 8e 91 10 80       	push   $0x8010918e
801001d0:	e8 33 04 00 00       	call   80100608 <panic>
}
801001d5:	c9                   	leave  
801001d6:	c3                   	ret    

801001d7 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001d7:	f3 0f 1e fb          	endbr32 
801001db:	55                   	push   %ebp
801001dc:	89 e5                	mov    %esp,%ebp
801001de:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001e1:	83 ec 08             	sub    $0x8,%esp
801001e4:	ff 75 0c             	pushl  0xc(%ebp)
801001e7:	ff 75 08             	pushl  0x8(%ebp)
801001ea:	e8 d6 fe ff ff       	call   801000c5 <bget>
801001ef:	83 c4 10             	add    $0x10,%esp
801001f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
801001f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 02             	and    $0x2,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0e                	jne    8010020f <bread+0x38>
    iderw(b);
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	ff 75 f4             	pushl  -0xc(%ebp)
80100207:	e8 e0 28 00 00       	call   80102aec <iderw>
8010020c:	83 c4 10             	add    $0x10,%esp
  }
  return b;
8010020f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100212:	c9                   	leave  
80100213:	c3                   	ret    

80100214 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
80100214:	f3 0f 1e fb          	endbr32 
80100218:	55                   	push   %ebp
80100219:	89 e5                	mov    %esp,%ebp
8010021b:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
8010021e:	8b 45 08             	mov    0x8(%ebp),%eax
80100221:	83 c0 0c             	add    $0xc,%eax
80100224:	83 ec 0c             	sub    $0xc,%esp
80100227:	50                   	push   %eax
80100228:	e8 c3 4f 00 00       	call   801051f0 <holdingsleep>
8010022d:	83 c4 10             	add    $0x10,%esp
80100230:	85 c0                	test   %eax,%eax
80100232:	75 0d                	jne    80100241 <bwrite+0x2d>
    panic("bwrite");
80100234:	83 ec 0c             	sub    $0xc,%esp
80100237:	68 9f 91 10 80       	push   $0x8010919f
8010023c:	e8 c7 03 00 00       	call   80100608 <panic>
  b->flags |= B_DIRTY;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 00                	mov    (%eax),%eax
80100246:	83 c8 04             	or     $0x4,%eax
80100249:	89 c2                	mov    %eax,%edx
8010024b:	8b 45 08             	mov    0x8(%ebp),%eax
8010024e:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100250:	83 ec 0c             	sub    $0xc,%esp
80100253:	ff 75 08             	pushl  0x8(%ebp)
80100256:	e8 91 28 00 00       	call   80102aec <iderw>
8010025b:	83 c4 10             	add    $0x10,%esp
}
8010025e:	90                   	nop
8010025f:	c9                   	leave  
80100260:	c3                   	ret    

80100261 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100261:	f3 0f 1e fb          	endbr32 
80100265:	55                   	push   %ebp
80100266:	89 e5                	mov    %esp,%ebp
80100268:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	83 c0 0c             	add    $0xc,%eax
80100271:	83 ec 0c             	sub    $0xc,%esp
80100274:	50                   	push   %eax
80100275:	e8 76 4f 00 00       	call   801051f0 <holdingsleep>
8010027a:	83 c4 10             	add    $0x10,%esp
8010027d:	85 c0                	test   %eax,%eax
8010027f:	75 0d                	jne    8010028e <brelse+0x2d>
    panic("brelse");
80100281:	83 ec 0c             	sub    $0xc,%esp
80100284:	68 a6 91 10 80       	push   $0x801091a6
80100289:	e8 7a 03 00 00       	call   80100608 <panic>

  releasesleep(&b->lock);
8010028e:	8b 45 08             	mov    0x8(%ebp),%eax
80100291:	83 c0 0c             	add    $0xc,%eax
80100294:	83 ec 0c             	sub    $0xc,%esp
80100297:	50                   	push   %eax
80100298:	e8 01 4f 00 00       	call   8010519e <releasesleep>
8010029d:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002a0:	83 ec 0c             	sub    $0xc,%esp
801002a3:	68 60 d6 10 80       	push   $0x8010d660
801002a8:	e8 02 50 00 00       	call   801052af <acquire>
801002ad:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002b0:	8b 45 08             	mov    0x8(%ebp),%eax
801002b3:	8b 40 4c             	mov    0x4c(%eax),%eax
801002b6:	8d 50 ff             	lea    -0x1(%eax),%edx
801002b9:	8b 45 08             	mov    0x8(%ebp),%eax
801002bc:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002bf:	8b 45 08             	mov    0x8(%ebp),%eax
801002c2:	8b 40 4c             	mov    0x4c(%eax),%eax
801002c5:	85 c0                	test   %eax,%eax
801002c7:	75 47                	jne    80100310 <brelse+0xaf>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002c9:	8b 45 08             	mov    0x8(%ebp),%eax
801002cc:	8b 40 54             	mov    0x54(%eax),%eax
801002cf:	8b 55 08             	mov    0x8(%ebp),%edx
801002d2:	8b 52 50             	mov    0x50(%edx),%edx
801002d5:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002d8:	8b 45 08             	mov    0x8(%ebp),%eax
801002db:	8b 40 50             	mov    0x50(%eax),%eax
801002de:	8b 55 08             	mov    0x8(%ebp),%edx
801002e1:	8b 52 54             	mov    0x54(%edx),%edx
801002e4:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
801002e7:	8b 15 b0 1d 11 80    	mov    0x80111db0,%edx
801002ed:	8b 45 08             	mov    0x8(%ebp),%eax
801002f0:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002f3:	8b 45 08             	mov    0x8(%ebp),%eax
801002f6:	c7 40 50 5c 1d 11 80 	movl   $0x80111d5c,0x50(%eax)
    bcache.head.next->prev = b;
801002fd:	a1 b0 1d 11 80       	mov    0x80111db0,%eax
80100302:	8b 55 08             	mov    0x8(%ebp),%edx
80100305:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100308:	8b 45 08             	mov    0x8(%ebp),%eax
8010030b:	a3 b0 1d 11 80       	mov    %eax,0x80111db0
  }
  
  release(&bcache.lock);
80100310:	83 ec 0c             	sub    $0xc,%esp
80100313:	68 60 d6 10 80       	push   $0x8010d660
80100318:	e8 04 50 00 00       	call   80105321 <release>
8010031d:	83 c4 10             	add    $0x10,%esp
}
80100320:	90                   	nop
80100321:	c9                   	leave  
80100322:	c3                   	ret    

80100323 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80100323:	55                   	push   %ebp
80100324:	89 e5                	mov    %esp,%ebp
80100326:	83 ec 14             	sub    $0x14,%esp
80100329:	8b 45 08             	mov    0x8(%ebp),%eax
8010032c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80100330:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80100334:	89 c2                	mov    %eax,%edx
80100336:	ec                   	in     (%dx),%al
80100337:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010033a:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010033e:	c9                   	leave  
8010033f:	c3                   	ret    

80100340 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80100340:	55                   	push   %ebp
80100341:	89 e5                	mov    %esp,%ebp
80100343:	83 ec 08             	sub    $0x8,%esp
80100346:	8b 45 08             	mov    0x8(%ebp),%eax
80100349:	8b 55 0c             	mov    0xc(%ebp),%edx
8010034c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80100350:	89 d0                	mov    %edx,%eax
80100352:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100355:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100359:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010035d:	ee                   	out    %al,(%dx)
}
8010035e:	90                   	nop
8010035f:	c9                   	leave  
80100360:	c3                   	ret    

80100361 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100361:	55                   	push   %ebp
80100362:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100364:	fa                   	cli    
}
80100365:	90                   	nop
80100366:	5d                   	pop    %ebp
80100367:	c3                   	ret    

80100368 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100368:	f3 0f 1e fb          	endbr32 
8010036c:	55                   	push   %ebp
8010036d:	89 e5                	mov    %esp,%ebp
8010036f:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100372:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100376:	74 1c                	je     80100394 <printint+0x2c>
80100378:	8b 45 08             	mov    0x8(%ebp),%eax
8010037b:	c1 e8 1f             	shr    $0x1f,%eax
8010037e:	0f b6 c0             	movzbl %al,%eax
80100381:	89 45 10             	mov    %eax,0x10(%ebp)
80100384:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100388:	74 0a                	je     80100394 <printint+0x2c>
    x = -xx;
8010038a:	8b 45 08             	mov    0x8(%ebp),%eax
8010038d:	f7 d8                	neg    %eax
8010038f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100392:	eb 06                	jmp    8010039a <printint+0x32>
  else
    x = xx;
80100394:	8b 45 08             	mov    0x8(%ebp),%eax
80100397:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
8010039a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
801003a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003a7:	ba 00 00 00 00       	mov    $0x0,%edx
801003ac:	f7 f1                	div    %ecx
801003ae:	89 d1                	mov    %edx,%ecx
801003b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003b3:	8d 50 01             	lea    0x1(%eax),%edx
801003b6:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003b9:	0f b6 91 04 a0 10 80 	movzbl -0x7fef5ffc(%ecx),%edx
801003c0:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003ca:	ba 00 00 00 00       	mov    $0x0,%edx
801003cf:	f7 f1                	div    %ecx
801003d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003d8:	75 c7                	jne    801003a1 <printint+0x39>

  if(sign)
801003da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003de:	74 2a                	je     8010040a <printint+0xa2>
    buf[i++] = '-';
801003e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003e3:	8d 50 01             	lea    0x1(%eax),%edx
801003e6:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003e9:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003ee:	eb 1a                	jmp    8010040a <printint+0xa2>
    consputc(buf[i]);
801003f0:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003f6:	01 d0                	add    %edx,%eax
801003f8:	0f b6 00             	movzbl (%eax),%eax
801003fb:	0f be c0             	movsbl %al,%eax
801003fe:	83 ec 0c             	sub    $0xc,%esp
80100401:	50                   	push   %eax
80100402:	e8 36 04 00 00       	call   8010083d <consputc>
80100407:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
8010040a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010040e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100412:	79 dc                	jns    801003f0 <printint+0x88>
}
80100414:	90                   	nop
80100415:	90                   	nop
80100416:	c9                   	leave  
80100417:	c3                   	ret    

80100418 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
80100418:	f3 0f 1e fb          	endbr32 
8010041c:	55                   	push   %ebp
8010041d:	89 e5                	mov    %esp,%ebp
8010041f:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
80100422:	a1 f4 c5 10 80       	mov    0x8010c5f4,%eax
80100427:	89 45 e8             	mov    %eax,-0x18(%ebp)
  //changed: added holding check
  if(locking && !holding(&cons.lock))
8010042a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010042e:	74 24                	je     80100454 <cprintf+0x3c>
80100430:	83 ec 0c             	sub    $0xc,%esp
80100433:	68 c0 c5 10 80       	push   $0x8010c5c0
80100438:	e8 b9 4f 00 00       	call   801053f6 <holding>
8010043d:	83 c4 10             	add    $0x10,%esp
80100440:	85 c0                	test   %eax,%eax
80100442:	75 10                	jne    80100454 <cprintf+0x3c>
    acquire(&cons.lock);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	68 c0 c5 10 80       	push   $0x8010c5c0
8010044c:	e8 5e 4e 00 00       	call   801052af <acquire>
80100451:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100454:	8b 45 08             	mov    0x8(%ebp),%eax
80100457:	85 c0                	test   %eax,%eax
80100459:	75 0d                	jne    80100468 <cprintf+0x50>
    panic("null fmt");
8010045b:	83 ec 0c             	sub    $0xc,%esp
8010045e:	68 b0 91 10 80       	push   $0x801091b0
80100463:	e8 a0 01 00 00       	call   80100608 <panic>

  argp = (uint*)(void*)(&fmt + 1);
80100468:	8d 45 0c             	lea    0xc(%ebp),%eax
8010046b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010046e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100475:	e9 52 01 00 00       	jmp    801005cc <cprintf+0x1b4>
    if(c != '%'){
8010047a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010047e:	74 13                	je     80100493 <cprintf+0x7b>
      consputc(c);
80100480:	83 ec 0c             	sub    $0xc,%esp
80100483:	ff 75 e4             	pushl  -0x1c(%ebp)
80100486:	e8 b2 03 00 00       	call   8010083d <consputc>
8010048b:	83 c4 10             	add    $0x10,%esp
      continue;
8010048e:	e9 35 01 00 00       	jmp    801005c8 <cprintf+0x1b0>
    }
    c = fmt[++i] & 0xff;
80100493:	8b 55 08             	mov    0x8(%ebp),%edx
80100496:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010049a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010049d:	01 d0                	add    %edx,%eax
8010049f:	0f b6 00             	movzbl (%eax),%eax
801004a2:	0f be c0             	movsbl %al,%eax
801004a5:	25 ff 00 00 00       	and    $0xff,%eax
801004aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
801004ad:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801004b1:	0f 84 37 01 00 00    	je     801005ee <cprintf+0x1d6>
      break;
    switch(c){
801004b7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004bb:	0f 84 dc 00 00 00    	je     8010059d <cprintf+0x185>
801004c1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004c5:	0f 8c e1 00 00 00    	jl     801005ac <cprintf+0x194>
801004cb:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
801004cf:	0f 8f d7 00 00 00    	jg     801005ac <cprintf+0x194>
801004d5:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
801004d9:	0f 8c cd 00 00 00    	jl     801005ac <cprintf+0x194>
801004df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004e2:	83 e8 63             	sub    $0x63,%eax
801004e5:	83 f8 15             	cmp    $0x15,%eax
801004e8:	0f 87 be 00 00 00    	ja     801005ac <cprintf+0x194>
801004ee:	8b 04 85 c0 91 10 80 	mov    -0x7fef6e40(,%eax,4),%eax
801004f5:	3e ff e0             	notrack jmp *%eax
    case 'd':
      printint(*argp++, 10, 1);
801004f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004fb:	8d 50 04             	lea    0x4(%eax),%edx
801004fe:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100501:	8b 00                	mov    (%eax),%eax
80100503:	83 ec 04             	sub    $0x4,%esp
80100506:	6a 01                	push   $0x1
80100508:	6a 0a                	push   $0xa
8010050a:	50                   	push   %eax
8010050b:	e8 58 fe ff ff       	call   80100368 <printint>
80100510:	83 c4 10             	add    $0x10,%esp
      break;
80100513:	e9 b0 00 00 00       	jmp    801005c8 <cprintf+0x1b0>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100518:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010051b:	8d 50 04             	lea    0x4(%eax),%edx
8010051e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100521:	8b 00                	mov    (%eax),%eax
80100523:	83 ec 04             	sub    $0x4,%esp
80100526:	6a 00                	push   $0x0
80100528:	6a 10                	push   $0x10
8010052a:	50                   	push   %eax
8010052b:	e8 38 fe ff ff       	call   80100368 <printint>
80100530:	83 c4 10             	add    $0x10,%esp
      break;
80100533:	e9 90 00 00 00       	jmp    801005c8 <cprintf+0x1b0>
    case 's':
      if((s = (char*)*argp++) == 0)
80100538:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010053b:	8d 50 04             	lea    0x4(%eax),%edx
8010053e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100541:	8b 00                	mov    (%eax),%eax
80100543:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100546:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010054a:	75 22                	jne    8010056e <cprintf+0x156>
        s = "(null)";
8010054c:	c7 45 ec b9 91 10 80 	movl   $0x801091b9,-0x14(%ebp)
      for(; *s; s++)
80100553:	eb 19                	jmp    8010056e <cprintf+0x156>
        consputc(*s);
80100555:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100558:	0f b6 00             	movzbl (%eax),%eax
8010055b:	0f be c0             	movsbl %al,%eax
8010055e:	83 ec 0c             	sub    $0xc,%esp
80100561:	50                   	push   %eax
80100562:	e8 d6 02 00 00       	call   8010083d <consputc>
80100567:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010056a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010056e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100571:	0f b6 00             	movzbl (%eax),%eax
80100574:	84 c0                	test   %al,%al
80100576:	75 dd                	jne    80100555 <cprintf+0x13d>
      break;
80100578:	eb 4e                	jmp    801005c8 <cprintf+0x1b0>
    case 'c':
      s = (char*)argp++;
8010057a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010057d:	8d 50 04             	lea    0x4(%eax),%edx
80100580:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100583:	89 45 ec             	mov    %eax,-0x14(%ebp)
      consputc(*(s));
80100586:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100589:	0f b6 00             	movzbl (%eax),%eax
8010058c:	0f be c0             	movsbl %al,%eax
8010058f:	83 ec 0c             	sub    $0xc,%esp
80100592:	50                   	push   %eax
80100593:	e8 a5 02 00 00       	call   8010083d <consputc>
80100598:	83 c4 10             	add    $0x10,%esp
      break;
8010059b:	eb 2b                	jmp    801005c8 <cprintf+0x1b0>
    case '%':
      consputc('%');
8010059d:	83 ec 0c             	sub    $0xc,%esp
801005a0:	6a 25                	push   $0x25
801005a2:	e8 96 02 00 00       	call   8010083d <consputc>
801005a7:	83 c4 10             	add    $0x10,%esp
      break;
801005aa:	eb 1c                	jmp    801005c8 <cprintf+0x1b0>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801005ac:	83 ec 0c             	sub    $0xc,%esp
801005af:	6a 25                	push   $0x25
801005b1:	e8 87 02 00 00       	call   8010083d <consputc>
801005b6:	83 c4 10             	add    $0x10,%esp
      consputc(c);
801005b9:	83 ec 0c             	sub    $0xc,%esp
801005bc:	ff 75 e4             	pushl  -0x1c(%ebp)
801005bf:	e8 79 02 00 00       	call   8010083d <consputc>
801005c4:	83 c4 10             	add    $0x10,%esp
      break;
801005c7:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801005c8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005cc:	8b 55 08             	mov    0x8(%ebp),%edx
801005cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d2:	01 d0                	add    %edx,%eax
801005d4:	0f b6 00             	movzbl (%eax),%eax
801005d7:	0f be c0             	movsbl %al,%eax
801005da:	25 ff 00 00 00       	and    $0xff,%eax
801005df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801005e2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801005e6:	0f 85 8e fe ff ff    	jne    8010047a <cprintf+0x62>
801005ec:	eb 01                	jmp    801005ef <cprintf+0x1d7>
      break;
801005ee:	90                   	nop
    }
  }

  if(locking)
801005ef:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801005f3:	74 10                	je     80100605 <cprintf+0x1ed>
    release(&cons.lock);
801005f5:	83 ec 0c             	sub    $0xc,%esp
801005f8:	68 c0 c5 10 80       	push   $0x8010c5c0
801005fd:	e8 1f 4d 00 00       	call   80105321 <release>
80100602:	83 c4 10             	add    $0x10,%esp
}
80100605:	90                   	nop
80100606:	c9                   	leave  
80100607:	c3                   	ret    

80100608 <panic>:

void
panic(char *s)
{
80100608:	f3 0f 1e fb          	endbr32 
8010060c:	55                   	push   %ebp
8010060d:	89 e5                	mov    %esp,%ebp
8010060f:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
80100612:	e8 4a fd ff ff       	call   80100361 <cli>
  cons.locking = 0;
80100617:	c7 05 f4 c5 10 80 00 	movl   $0x0,0x8010c5f4
8010061e:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
80100621:	e8 b8 2b 00 00       	call   801031de <lapicid>
80100626:	83 ec 08             	sub    $0x8,%esp
80100629:	50                   	push   %eax
8010062a:	68 18 92 10 80       	push   $0x80109218
8010062f:	e8 e4 fd ff ff       	call   80100418 <cprintf>
80100634:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100637:	8b 45 08             	mov    0x8(%ebp),%eax
8010063a:	83 ec 0c             	sub    $0xc,%esp
8010063d:	50                   	push   %eax
8010063e:	e8 d5 fd ff ff       	call   80100418 <cprintf>
80100643:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80100646:	83 ec 0c             	sub    $0xc,%esp
80100649:	68 2c 92 10 80       	push   $0x8010922c
8010064e:	e8 c5 fd ff ff       	call   80100418 <cprintf>
80100653:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100656:	83 ec 08             	sub    $0x8,%esp
80100659:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010065c:	50                   	push   %eax
8010065d:	8d 45 08             	lea    0x8(%ebp),%eax
80100660:	50                   	push   %eax
80100661:	e8 11 4d 00 00       	call   80105377 <getcallerpcs>
80100666:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100669:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100670:	eb 1c                	jmp    8010068e <panic+0x86>
    cprintf(" %p", pcs[i]);
80100672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100675:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100679:	83 ec 08             	sub    $0x8,%esp
8010067c:	50                   	push   %eax
8010067d:	68 2e 92 10 80       	push   $0x8010922e
80100682:	e8 91 fd ff ff       	call   80100418 <cprintf>
80100687:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
8010068a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010068e:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80100692:	7e de                	jle    80100672 <panic+0x6a>
  panicked = 1; // freeze other CPU
80100694:	c7 05 a0 c5 10 80 01 	movl   $0x1,0x8010c5a0
8010069b:	00 00 00 
  for(;;)
8010069e:	eb fe                	jmp    8010069e <panic+0x96>

801006a0 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801006a0:	f3 0f 1e fb          	endbr32 
801006a4:	55                   	push   %ebp
801006a5:	89 e5                	mov    %esp,%ebp
801006a7:	53                   	push   %ebx
801006a8:	83 ec 14             	sub    $0x14,%esp
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801006ab:	6a 0e                	push   $0xe
801006ad:	68 d4 03 00 00       	push   $0x3d4
801006b2:	e8 89 fc ff ff       	call   80100340 <outb>
801006b7:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
801006ba:	68 d5 03 00 00       	push   $0x3d5
801006bf:	e8 5f fc ff ff       	call   80100323 <inb>
801006c4:	83 c4 04             	add    $0x4,%esp
801006c7:	0f b6 c0             	movzbl %al,%eax
801006ca:	c1 e0 08             	shl    $0x8,%eax
801006cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801006d0:	6a 0f                	push   $0xf
801006d2:	68 d4 03 00 00       	push   $0x3d4
801006d7:	e8 64 fc ff ff       	call   80100340 <outb>
801006dc:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
801006df:	68 d5 03 00 00       	push   $0x3d5
801006e4:	e8 3a fc ff ff       	call   80100323 <inb>
801006e9:	83 c4 04             	add    $0x4,%esp
801006ec:	0f b6 c0             	movzbl %al,%eax
801006ef:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
801006f2:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
801006f6:	75 30                	jne    80100728 <cgaputc+0x88>
    pos += 80 - pos%80;
801006f8:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006fb:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100700:	89 c8                	mov    %ecx,%eax
80100702:	f7 ea                	imul   %edx
80100704:	c1 fa 05             	sar    $0x5,%edx
80100707:	89 c8                	mov    %ecx,%eax
80100709:	c1 f8 1f             	sar    $0x1f,%eax
8010070c:	29 c2                	sub    %eax,%edx
8010070e:	89 d0                	mov    %edx,%eax
80100710:	c1 e0 02             	shl    $0x2,%eax
80100713:	01 d0                	add    %edx,%eax
80100715:	c1 e0 04             	shl    $0x4,%eax
80100718:	29 c1                	sub    %eax,%ecx
8010071a:	89 ca                	mov    %ecx,%edx
8010071c:	b8 50 00 00 00       	mov    $0x50,%eax
80100721:	29 d0                	sub    %edx,%eax
80100723:	01 45 f4             	add    %eax,-0xc(%ebp)
80100726:	eb 38                	jmp    80100760 <cgaputc+0xc0>
  else if(c == BACKSPACE){
80100728:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010072f:	75 0c                	jne    8010073d <cgaputc+0x9d>
    if(pos > 0) --pos;
80100731:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100735:	7e 29                	jle    80100760 <cgaputc+0xc0>
80100737:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010073b:	eb 23                	jmp    80100760 <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010073d:	8b 45 08             	mov    0x8(%ebp),%eax
80100740:	0f b6 c0             	movzbl %al,%eax
80100743:	80 cc 07             	or     $0x7,%ah
80100746:	89 c3                	mov    %eax,%ebx
80100748:	8b 0d 00 a0 10 80    	mov    0x8010a000,%ecx
8010074e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100751:	8d 50 01             	lea    0x1(%eax),%edx
80100754:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100757:	01 c0                	add    %eax,%eax
80100759:	01 c8                	add    %ecx,%eax
8010075b:	89 da                	mov    %ebx,%edx
8010075d:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
80100760:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100764:	78 09                	js     8010076f <cgaputc+0xcf>
80100766:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
8010076d:	7e 0d                	jle    8010077c <cgaputc+0xdc>
    panic("pos under/overflow");
8010076f:	83 ec 0c             	sub    $0xc,%esp
80100772:	68 32 92 10 80       	push   $0x80109232
80100777:	e8 8c fe ff ff       	call   80100608 <panic>

  if((pos/80) >= 24){  // Scroll up.
8010077c:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
80100783:	7e 4c                	jle    801007d1 <cgaputc+0x131>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100785:	a1 00 a0 10 80       	mov    0x8010a000,%eax
8010078a:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80100790:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100795:	83 ec 04             	sub    $0x4,%esp
80100798:	68 60 0e 00 00       	push   $0xe60
8010079d:	52                   	push   %edx
8010079e:	50                   	push   %eax
8010079f:	e8 71 4e 00 00       	call   80105615 <memmove>
801007a4:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801007a7:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801007ab:	b8 80 07 00 00       	mov    $0x780,%eax
801007b0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801007b3:	8d 14 00             	lea    (%eax,%eax,1),%edx
801007b6:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801007bb:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801007be:	01 c9                	add    %ecx,%ecx
801007c0:	01 c8                	add    %ecx,%eax
801007c2:	83 ec 04             	sub    $0x4,%esp
801007c5:	52                   	push   %edx
801007c6:	6a 00                	push   $0x0
801007c8:	50                   	push   %eax
801007c9:	e8 80 4d 00 00       	call   8010554e <memset>
801007ce:	83 c4 10             	add    $0x10,%esp
  }

  outb(CRTPORT, 14);
801007d1:	83 ec 08             	sub    $0x8,%esp
801007d4:	6a 0e                	push   $0xe
801007d6:	68 d4 03 00 00       	push   $0x3d4
801007db:	e8 60 fb ff ff       	call   80100340 <outb>
801007e0:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
801007e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007e6:	c1 f8 08             	sar    $0x8,%eax
801007e9:	0f b6 c0             	movzbl %al,%eax
801007ec:	83 ec 08             	sub    $0x8,%esp
801007ef:	50                   	push   %eax
801007f0:	68 d5 03 00 00       	push   $0x3d5
801007f5:	e8 46 fb ff ff       	call   80100340 <outb>
801007fa:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
801007fd:	83 ec 08             	sub    $0x8,%esp
80100800:	6a 0f                	push   $0xf
80100802:	68 d4 03 00 00       	push   $0x3d4
80100807:	e8 34 fb ff ff       	call   80100340 <outb>
8010080c:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
8010080f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100812:	0f b6 c0             	movzbl %al,%eax
80100815:	83 ec 08             	sub    $0x8,%esp
80100818:	50                   	push   %eax
80100819:	68 d5 03 00 00       	push   $0x3d5
8010081e:	e8 1d fb ff ff       	call   80100340 <outb>
80100823:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
80100826:	a1 00 a0 10 80       	mov    0x8010a000,%eax
8010082b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010082e:	01 d2                	add    %edx,%edx
80100830:	01 d0                	add    %edx,%eax
80100832:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100837:	90                   	nop
80100838:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010083b:	c9                   	leave  
8010083c:	c3                   	ret    

8010083d <consputc>:

void
consputc(int c)
{
8010083d:	f3 0f 1e fb          	endbr32 
80100841:	55                   	push   %ebp
80100842:	89 e5                	mov    %esp,%ebp
80100844:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100847:	a1 a0 c5 10 80       	mov    0x8010c5a0,%eax
8010084c:	85 c0                	test   %eax,%eax
8010084e:	74 07                	je     80100857 <consputc+0x1a>
    cli();
80100850:	e8 0c fb ff ff       	call   80100361 <cli>
    for(;;)
80100855:	eb fe                	jmp    80100855 <consputc+0x18>
      ;
  }

  if(c == BACKSPACE){
80100857:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010085e:	75 29                	jne    80100889 <consputc+0x4c>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100860:	83 ec 0c             	sub    $0xc,%esp
80100863:	6a 08                	push   $0x8
80100865:	e8 f3 67 00 00       	call   8010705d <uartputc>
8010086a:	83 c4 10             	add    $0x10,%esp
8010086d:	83 ec 0c             	sub    $0xc,%esp
80100870:	6a 20                	push   $0x20
80100872:	e8 e6 67 00 00       	call   8010705d <uartputc>
80100877:	83 c4 10             	add    $0x10,%esp
8010087a:	83 ec 0c             	sub    $0xc,%esp
8010087d:	6a 08                	push   $0x8
8010087f:	e8 d9 67 00 00       	call   8010705d <uartputc>
80100884:	83 c4 10             	add    $0x10,%esp
80100887:	eb 0e                	jmp    80100897 <consputc+0x5a>
  } else
    uartputc(c);
80100889:	83 ec 0c             	sub    $0xc,%esp
8010088c:	ff 75 08             	pushl  0x8(%ebp)
8010088f:	e8 c9 67 00 00       	call   8010705d <uartputc>
80100894:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
80100897:	83 ec 0c             	sub    $0xc,%esp
8010089a:	ff 75 08             	pushl  0x8(%ebp)
8010089d:	e8 fe fd ff ff       	call   801006a0 <cgaputc>
801008a2:	83 c4 10             	add    $0x10,%esp
}
801008a5:	90                   	nop
801008a6:	c9                   	leave  
801008a7:	c3                   	ret    

801008a8 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801008a8:	f3 0f 1e fb          	endbr32 
801008ac:	55                   	push   %ebp
801008ad:	89 e5                	mov    %esp,%ebp
801008af:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801008b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801008b9:	83 ec 0c             	sub    $0xc,%esp
801008bc:	68 c0 c5 10 80       	push   $0x8010c5c0
801008c1:	e8 e9 49 00 00       	call   801052af <acquire>
801008c6:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801008c9:	e9 52 01 00 00       	jmp    80100a20 <consoleintr+0x178>
    switch(c){
801008ce:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801008d2:	0f 84 81 00 00 00    	je     80100959 <consoleintr+0xb1>
801008d8:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801008dc:	0f 8f ac 00 00 00    	jg     8010098e <consoleintr+0xe6>
801008e2:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
801008e6:	74 43                	je     8010092b <consoleintr+0x83>
801008e8:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
801008ec:	0f 8f 9c 00 00 00    	jg     8010098e <consoleintr+0xe6>
801008f2:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
801008f6:	74 61                	je     80100959 <consoleintr+0xb1>
801008f8:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
801008fc:	0f 85 8c 00 00 00    	jne    8010098e <consoleintr+0xe6>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
80100902:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100909:	e9 12 01 00 00       	jmp    80100a20 <consoleintr+0x178>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010090e:	a1 48 20 11 80       	mov    0x80112048,%eax
80100913:	83 e8 01             	sub    $0x1,%eax
80100916:	a3 48 20 11 80       	mov    %eax,0x80112048
        consputc(BACKSPACE);
8010091b:	83 ec 0c             	sub    $0xc,%esp
8010091e:	68 00 01 00 00       	push   $0x100
80100923:	e8 15 ff ff ff       	call   8010083d <consputc>
80100928:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
8010092b:	8b 15 48 20 11 80    	mov    0x80112048,%edx
80100931:	a1 44 20 11 80       	mov    0x80112044,%eax
80100936:	39 c2                	cmp    %eax,%edx
80100938:	0f 84 e2 00 00 00    	je     80100a20 <consoleintr+0x178>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010093e:	a1 48 20 11 80       	mov    0x80112048,%eax
80100943:	83 e8 01             	sub    $0x1,%eax
80100946:	83 e0 7f             	and    $0x7f,%eax
80100949:	0f b6 80 c0 1f 11 80 	movzbl -0x7feee040(%eax),%eax
      while(input.e != input.w &&
80100950:	3c 0a                	cmp    $0xa,%al
80100952:	75 ba                	jne    8010090e <consoleintr+0x66>
      }
      break;
80100954:	e9 c7 00 00 00       	jmp    80100a20 <consoleintr+0x178>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100959:	8b 15 48 20 11 80    	mov    0x80112048,%edx
8010095f:	a1 44 20 11 80       	mov    0x80112044,%eax
80100964:	39 c2                	cmp    %eax,%edx
80100966:	0f 84 b4 00 00 00    	je     80100a20 <consoleintr+0x178>
        input.e--;
8010096c:	a1 48 20 11 80       	mov    0x80112048,%eax
80100971:	83 e8 01             	sub    $0x1,%eax
80100974:	a3 48 20 11 80       	mov    %eax,0x80112048
        consputc(BACKSPACE);
80100979:	83 ec 0c             	sub    $0xc,%esp
8010097c:	68 00 01 00 00       	push   $0x100
80100981:	e8 b7 fe ff ff       	call   8010083d <consputc>
80100986:	83 c4 10             	add    $0x10,%esp
      }
      break;
80100989:	e9 92 00 00 00       	jmp    80100a20 <consoleintr+0x178>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010098e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100992:	0f 84 87 00 00 00    	je     80100a1f <consoleintr+0x177>
80100998:	8b 15 48 20 11 80    	mov    0x80112048,%edx
8010099e:	a1 40 20 11 80       	mov    0x80112040,%eax
801009a3:	29 c2                	sub    %eax,%edx
801009a5:	89 d0                	mov    %edx,%eax
801009a7:	83 f8 7f             	cmp    $0x7f,%eax
801009aa:	77 73                	ja     80100a1f <consoleintr+0x177>
        c = (c == '\r') ? '\n' : c;
801009ac:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801009b0:	74 05                	je     801009b7 <consoleintr+0x10f>
801009b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801009b5:	eb 05                	jmp    801009bc <consoleintr+0x114>
801009b7:	b8 0a 00 00 00       	mov    $0xa,%eax
801009bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801009bf:	a1 48 20 11 80       	mov    0x80112048,%eax
801009c4:	8d 50 01             	lea    0x1(%eax),%edx
801009c7:	89 15 48 20 11 80    	mov    %edx,0x80112048
801009cd:	83 e0 7f             	and    $0x7f,%eax
801009d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801009d3:	88 90 c0 1f 11 80    	mov    %dl,-0x7feee040(%eax)
        consputc(c);
801009d9:	83 ec 0c             	sub    $0xc,%esp
801009dc:	ff 75 f0             	pushl  -0x10(%ebp)
801009df:	e8 59 fe ff ff       	call   8010083d <consputc>
801009e4:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801009e7:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801009eb:	74 18                	je     80100a05 <consoleintr+0x15d>
801009ed:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009f1:	74 12                	je     80100a05 <consoleintr+0x15d>
801009f3:	a1 48 20 11 80       	mov    0x80112048,%eax
801009f8:	8b 15 40 20 11 80    	mov    0x80112040,%edx
801009fe:	83 ea 80             	sub    $0xffffff80,%edx
80100a01:	39 d0                	cmp    %edx,%eax
80100a03:	75 1a                	jne    80100a1f <consoleintr+0x177>
          input.w = input.e;
80100a05:	a1 48 20 11 80       	mov    0x80112048,%eax
80100a0a:	a3 44 20 11 80       	mov    %eax,0x80112044
          wakeup(&input.r);
80100a0f:	83 ec 0c             	sub    $0xc,%esp
80100a12:	68 40 20 11 80       	push   $0x80112040
80100a17:	e8 13 45 00 00       	call   80104f2f <wakeup>
80100a1c:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100a1f:	90                   	nop
  while((c = getc()) >= 0){
80100a20:	8b 45 08             	mov    0x8(%ebp),%eax
80100a23:	ff d0                	call   *%eax
80100a25:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100a28:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100a2c:	0f 89 9c fe ff ff    	jns    801008ce <consoleintr+0x26>
    }
  }
  release(&cons.lock);
80100a32:	83 ec 0c             	sub    $0xc,%esp
80100a35:	68 c0 c5 10 80       	push   $0x8010c5c0
80100a3a:	e8 e2 48 00 00       	call   80105321 <release>
80100a3f:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100a42:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100a46:	74 05                	je     80100a4d <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
80100a48:	e8 a8 45 00 00       	call   80104ff5 <procdump>
  }
}
80100a4d:	90                   	nop
80100a4e:	c9                   	leave  
80100a4f:	c3                   	ret    

80100a50 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100a50:	f3 0f 1e fb          	endbr32 
80100a54:	55                   	push   %ebp
80100a55:	89 e5                	mov    %esp,%ebp
80100a57:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100a5a:	83 ec 0c             	sub    $0xc,%esp
80100a5d:	ff 75 08             	pushl  0x8(%ebp)
80100a60:	e8 0d 12 00 00       	call   80101c72 <iunlock>
80100a65:	83 c4 10             	add    $0x10,%esp
  target = n;
80100a68:	8b 45 10             	mov    0x10(%ebp),%eax
80100a6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	68 c0 c5 10 80       	push   $0x8010c5c0
80100a76:	e8 34 48 00 00       	call   801052af <acquire>
80100a7b:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100a7e:	e9 ab 00 00 00       	jmp    80100b2e <consoleread+0xde>
    while(input.r == input.w){
      if(myproc()->killed){
80100a83:	e8 87 3a 00 00       	call   8010450f <myproc>
80100a88:	8b 40 24             	mov    0x24(%eax),%eax
80100a8b:	85 c0                	test   %eax,%eax
80100a8d:	74 28                	je     80100ab7 <consoleread+0x67>
        release(&cons.lock);
80100a8f:	83 ec 0c             	sub    $0xc,%esp
80100a92:	68 c0 c5 10 80       	push   $0x8010c5c0
80100a97:	e8 85 48 00 00       	call   80105321 <release>
80100a9c:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a9f:	83 ec 0c             	sub    $0xc,%esp
80100aa2:	ff 75 08             	pushl  0x8(%ebp)
80100aa5:	e8 b1 10 00 00       	call   80101b5b <ilock>
80100aaa:	83 c4 10             	add    $0x10,%esp
        return -1;
80100aad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ab2:	e9 ab 00 00 00       	jmp    80100b62 <consoleread+0x112>
      }
      sleep(&input.r, &cons.lock);
80100ab7:	83 ec 08             	sub    $0x8,%esp
80100aba:	68 c0 c5 10 80       	push   $0x8010c5c0
80100abf:	68 40 20 11 80       	push   $0x80112040
80100ac4:	e8 74 43 00 00       	call   80104e3d <sleep>
80100ac9:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100acc:	8b 15 40 20 11 80    	mov    0x80112040,%edx
80100ad2:	a1 44 20 11 80       	mov    0x80112044,%eax
80100ad7:	39 c2                	cmp    %eax,%edx
80100ad9:	74 a8                	je     80100a83 <consoleread+0x33>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100adb:	a1 40 20 11 80       	mov    0x80112040,%eax
80100ae0:	8d 50 01             	lea    0x1(%eax),%edx
80100ae3:	89 15 40 20 11 80    	mov    %edx,0x80112040
80100ae9:	83 e0 7f             	and    $0x7f,%eax
80100aec:	0f b6 80 c0 1f 11 80 	movzbl -0x7feee040(%eax),%eax
80100af3:	0f be c0             	movsbl %al,%eax
80100af6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100af9:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100afd:	75 17                	jne    80100b16 <consoleread+0xc6>
      if(n < target){
80100aff:	8b 45 10             	mov    0x10(%ebp),%eax
80100b02:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100b05:	76 2f                	jbe    80100b36 <consoleread+0xe6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100b07:	a1 40 20 11 80       	mov    0x80112040,%eax
80100b0c:	83 e8 01             	sub    $0x1,%eax
80100b0f:	a3 40 20 11 80       	mov    %eax,0x80112040
      }
      break;
80100b14:	eb 20                	jmp    80100b36 <consoleread+0xe6>
    }
    *dst++ = c;
80100b16:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b19:	8d 50 01             	lea    0x1(%eax),%edx
80100b1c:	89 55 0c             	mov    %edx,0xc(%ebp)
80100b1f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100b22:	88 10                	mov    %dl,(%eax)
    --n;
80100b24:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100b28:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100b2c:	74 0b                	je     80100b39 <consoleread+0xe9>
  while(n > 0){
80100b2e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100b32:	7f 98                	jg     80100acc <consoleread+0x7c>
80100b34:	eb 04                	jmp    80100b3a <consoleread+0xea>
      break;
80100b36:	90                   	nop
80100b37:	eb 01                	jmp    80100b3a <consoleread+0xea>
      break;
80100b39:	90                   	nop
  }
  release(&cons.lock);
80100b3a:	83 ec 0c             	sub    $0xc,%esp
80100b3d:	68 c0 c5 10 80       	push   $0x8010c5c0
80100b42:	e8 da 47 00 00       	call   80105321 <release>
80100b47:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b4a:	83 ec 0c             	sub    $0xc,%esp
80100b4d:	ff 75 08             	pushl  0x8(%ebp)
80100b50:	e8 06 10 00 00       	call   80101b5b <ilock>
80100b55:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100b58:	8b 45 10             	mov    0x10(%ebp),%eax
80100b5b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b5e:	29 c2                	sub    %eax,%edx
80100b60:	89 d0                	mov    %edx,%eax
}
80100b62:	c9                   	leave  
80100b63:	c3                   	ret    

80100b64 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100b64:	f3 0f 1e fb          	endbr32 
80100b68:	55                   	push   %ebp
80100b69:	89 e5                	mov    %esp,%ebp
80100b6b:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100b6e:	83 ec 0c             	sub    $0xc,%esp
80100b71:	ff 75 08             	pushl  0x8(%ebp)
80100b74:	e8 f9 10 00 00       	call   80101c72 <iunlock>
80100b79:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100b7c:	83 ec 0c             	sub    $0xc,%esp
80100b7f:	68 c0 c5 10 80       	push   $0x8010c5c0
80100b84:	e8 26 47 00 00       	call   801052af <acquire>
80100b89:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b8c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100b93:	eb 21                	jmp    80100bb6 <consolewrite+0x52>
    consputc(buf[i] & 0xff);
80100b95:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b98:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b9b:	01 d0                	add    %edx,%eax
80100b9d:	0f b6 00             	movzbl (%eax),%eax
80100ba0:	0f be c0             	movsbl %al,%eax
80100ba3:	0f b6 c0             	movzbl %al,%eax
80100ba6:	83 ec 0c             	sub    $0xc,%esp
80100ba9:	50                   	push   %eax
80100baa:	e8 8e fc ff ff       	call   8010083d <consputc>
80100baf:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100bb2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100bb9:	3b 45 10             	cmp    0x10(%ebp),%eax
80100bbc:	7c d7                	jl     80100b95 <consolewrite+0x31>
  release(&cons.lock);
80100bbe:	83 ec 0c             	sub    $0xc,%esp
80100bc1:	68 c0 c5 10 80       	push   $0x8010c5c0
80100bc6:	e8 56 47 00 00       	call   80105321 <release>
80100bcb:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100bce:	83 ec 0c             	sub    $0xc,%esp
80100bd1:	ff 75 08             	pushl  0x8(%ebp)
80100bd4:	e8 82 0f 00 00       	call   80101b5b <ilock>
80100bd9:	83 c4 10             	add    $0x10,%esp

  return n;
80100bdc:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100bdf:	c9                   	leave  
80100be0:	c3                   	ret    

80100be1 <consoleinit>:

void
consoleinit(void)
{
80100be1:	f3 0f 1e fb          	endbr32 
80100be5:	55                   	push   %ebp
80100be6:	89 e5                	mov    %esp,%ebp
80100be8:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100beb:	83 ec 08             	sub    $0x8,%esp
80100bee:	68 45 92 10 80       	push   $0x80109245
80100bf3:	68 c0 c5 10 80       	push   $0x8010c5c0
80100bf8:	e8 8c 46 00 00       	call   80105289 <initlock>
80100bfd:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100c00:	c7 05 0c 2a 11 80 64 	movl   $0x80100b64,0x80112a0c
80100c07:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100c0a:	c7 05 08 2a 11 80 50 	movl   $0x80100a50,0x80112a08
80100c11:	0a 10 80 
  cons.locking = 1;
80100c14:	c7 05 f4 c5 10 80 01 	movl   $0x1,0x8010c5f4
80100c1b:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100c1e:	83 ec 08             	sub    $0x8,%esp
80100c21:	6a 00                	push   $0x0
80100c23:	6a 01                	push   $0x1
80100c25:	e8 9b 20 00 00       	call   80102cc5 <ioapicenable>
80100c2a:	83 c4 10             	add    $0x10,%esp
}
80100c2d:	90                   	nop
80100c2e:	c9                   	leave  
80100c2f:	c3                   	ret    

80100c30 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100c30:	f3 0f 1e fb          	endbr32 
80100c34:	55                   	push   %ebp
80100c35:	89 e5                	mov    %esp,%ebp
80100c37:	81 ec 28 01 00 00    	sub    $0x128,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100c3d:	e8 cd 38 00 00       	call   8010450f <myproc>
80100c42:	89 45 c8             	mov    %eax,-0x38(%ebp)


  int len=0;
80100c45:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
  int hand = 0;
80100c4c:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%ebp)
  for (int i = 0; i < CLOCKSIZE; i++){
80100c53:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
80100c5a:	eb 15                	jmp    80100c71 <exec+0x41>
    curproc->clock[i] = 0;
80100c5c:	8b 45 c8             	mov    -0x38(%ebp),%eax
80100c5f:	8b 55 d0             	mov    -0x30(%ebp),%edx
80100c62:	83 c2 1c             	add    $0x1c,%edx
80100c65:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80100c6c:	00 
  for (int i = 0; i < CLOCKSIZE; i++){
80100c6d:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
80100c71:	83 7d d0 07          	cmpl   $0x7,-0x30(%ebp)
80100c75:	7e e5                	jle    80100c5c <exec+0x2c>
  }
  curproc->clock_len = len;
80100c77:	8b 45 c8             	mov    -0x38(%ebp),%eax
80100c7a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
80100c7d:	89 90 a0 00 00 00    	mov    %edx,0xa0(%eax)
  curproc->hand = hand;
80100c83:	8b 45 c8             	mov    -0x38(%ebp),%eax
80100c86:	8b 55 c0             	mov    -0x40(%ebp),%edx
80100c89:	89 90 9c 00 00 00    	mov    %edx,0x9c(%eax)

  begin_op();
80100c8f:	e8 bc 2a 00 00       	call   80103750 <begin_op>

  if((ip = namei(path)) == 0){
80100c94:	83 ec 0c             	sub    $0xc,%esp
80100c97:	ff 75 08             	pushl  0x8(%ebp)
80100c9a:	e8 27 1a 00 00       	call   801026c6 <namei>
80100c9f:	83 c4 10             	add    $0x10,%esp
80100ca2:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100ca5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100ca9:	75 1f                	jne    80100cca <exec+0x9a>
    end_op();
80100cab:	e8 30 2b 00 00       	call   801037e0 <end_op>
    cprintf("exec: fail\n");
80100cb0:	83 ec 0c             	sub    $0xc,%esp
80100cb3:	68 4d 92 10 80       	push   $0x8010924d
80100cb8:	e8 5b f7 ff ff       	call   80100418 <cprintf>
80100cbd:	83 c4 10             	add    $0x10,%esp
    return -1;
80100cc0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100cc5:	e9 27 04 00 00       	jmp    801010f1 <exec+0x4c1>
  }
  ilock(ip);
80100cca:	83 ec 0c             	sub    $0xc,%esp
80100ccd:	ff 75 d8             	pushl  -0x28(%ebp)
80100cd0:	e8 86 0e 00 00       	call   80101b5b <ilock>
80100cd5:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100cd8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100cdf:	6a 34                	push   $0x34
80100ce1:	6a 00                	push   $0x0
80100ce3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
80100ce9:	50                   	push   %eax
80100cea:	ff 75 d8             	pushl  -0x28(%ebp)
80100ced:	e8 71 13 00 00       	call   80102063 <readi>
80100cf2:	83 c4 10             	add    $0x10,%esp
80100cf5:	83 f8 34             	cmp    $0x34,%eax
80100cf8:	0f 85 9c 03 00 00    	jne    8010109a <exec+0x46a>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100cfe:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100d04:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100d09:	0f 85 8e 03 00 00    	jne    8010109d <exec+0x46d>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100d0f:	e8 80 73 00 00       	call   80108094 <setupkvm>
80100d14:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100d17:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100d1b:	0f 84 7f 03 00 00    	je     801010a0 <exec+0x470>
    goto bad;

  // Load program into memory.
  sz = 0;
80100d21:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d28:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100d2f:	8b 85 14 ff ff ff    	mov    -0xec(%ebp),%eax
80100d35:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d38:	e9 de 00 00 00       	jmp    80100e1b <exec+0x1eb>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100d3d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d40:	6a 20                	push   $0x20
80100d42:	50                   	push   %eax
80100d43:	8d 85 d8 fe ff ff    	lea    -0x128(%ebp),%eax
80100d49:	50                   	push   %eax
80100d4a:	ff 75 d8             	pushl  -0x28(%ebp)
80100d4d:	e8 11 13 00 00       	call   80102063 <readi>
80100d52:	83 c4 10             	add    $0x10,%esp
80100d55:	83 f8 20             	cmp    $0x20,%eax
80100d58:	0f 85 45 03 00 00    	jne    801010a3 <exec+0x473>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100d5e:	8b 85 d8 fe ff ff    	mov    -0x128(%ebp),%eax
80100d64:	83 f8 01             	cmp    $0x1,%eax
80100d67:	0f 85 a0 00 00 00    	jne    80100e0d <exec+0x1dd>
      continue;
    if(ph.memsz < ph.filesz)
80100d6d:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100d73:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100d79:	39 c2                	cmp    %eax,%edx
80100d7b:	0f 82 25 03 00 00    	jb     801010a6 <exec+0x476>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100d81:	8b 95 e0 fe ff ff    	mov    -0x120(%ebp),%edx
80100d87:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d8d:	01 c2                	add    %eax,%edx
80100d8f:	8b 85 e0 fe ff ff    	mov    -0x120(%ebp),%eax
80100d95:	39 c2                	cmp    %eax,%edx
80100d97:	0f 82 0c 03 00 00    	jb     801010a9 <exec+0x479>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100d9d:	8b 95 e0 fe ff ff    	mov    -0x120(%ebp),%edx
80100da3:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100da9:	01 d0                	add    %edx,%eax
80100dab:	83 ec 04             	sub    $0x4,%esp
80100dae:	50                   	push   %eax
80100daf:	ff 75 e0             	pushl  -0x20(%ebp)
80100db2:	ff 75 d4             	pushl  -0x2c(%ebp)
80100db5:	e8 98 76 00 00       	call   80108452 <allocuvm>
80100dba:	83 c4 10             	add    $0x10,%esp
80100dbd:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100dc0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100dc4:	0f 84 e2 02 00 00    	je     801010ac <exec+0x47c>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100dca:	8b 85 e0 fe ff ff    	mov    -0x120(%ebp),%eax
80100dd0:	25 ff 0f 00 00       	and    $0xfff,%eax
80100dd5:	85 c0                	test   %eax,%eax
80100dd7:	0f 85 d2 02 00 00    	jne    801010af <exec+0x47f>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100ddd:	8b 95 e8 fe ff ff    	mov    -0x118(%ebp),%edx
80100de3:	8b 85 dc fe ff ff    	mov    -0x124(%ebp),%eax
80100de9:	8b 8d e0 fe ff ff    	mov    -0x120(%ebp),%ecx
80100def:	83 ec 0c             	sub    $0xc,%esp
80100df2:	52                   	push   %edx
80100df3:	50                   	push   %eax
80100df4:	ff 75 d8             	pushl  -0x28(%ebp)
80100df7:	51                   	push   %ecx
80100df8:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dfb:	e8 81 75 00 00       	call   80108381 <loaduvm>
80100e00:	83 c4 20             	add    $0x20,%esp
80100e03:	85 c0                	test   %eax,%eax
80100e05:	0f 88 a7 02 00 00    	js     801010b2 <exec+0x482>
80100e0b:	eb 01                	jmp    80100e0e <exec+0x1de>
      continue;
80100e0d:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100e0e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100e12:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100e15:	83 c0 20             	add    $0x20,%eax
80100e18:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100e1b:	0f b7 85 24 ff ff ff 	movzwl -0xdc(%ebp),%eax
80100e22:	0f b7 c0             	movzwl %ax,%eax
80100e25:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100e28:	0f 8c 0f ff ff ff    	jl     80100d3d <exec+0x10d>
      goto bad;
  }
  iunlockput(ip);
80100e2e:	83 ec 0c             	sub    $0xc,%esp
80100e31:	ff 75 d8             	pushl  -0x28(%ebp)
80100e34:	e8 5f 0f 00 00       	call   80101d98 <iunlockput>
80100e39:	83 c4 10             	add    $0x10,%esp
  end_op();
80100e3c:	e8 9f 29 00 00       	call   801037e0 <end_op>
  ip = 0;
80100e41:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100e48:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e4b:	05 ff 0f 00 00       	add    $0xfff,%eax
80100e50:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100e55:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100e58:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e5b:	05 00 20 00 00       	add    $0x2000,%eax
80100e60:	83 ec 04             	sub    $0x4,%esp
80100e63:	50                   	push   %eax
80100e64:	ff 75 e0             	pushl  -0x20(%ebp)
80100e67:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e6a:	e8 e3 75 00 00       	call   80108452 <allocuvm>
80100e6f:	83 c4 10             	add    $0x10,%esp
80100e72:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100e75:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100e79:	0f 84 36 02 00 00    	je     801010b5 <exec+0x485>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100e7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e82:	2d 00 20 00 00       	sub    $0x2000,%eax
80100e87:	83 ec 08             	sub    $0x8,%esp
80100e8a:	50                   	push   %eax
80100e8b:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e8e:	e8 31 78 00 00       	call   801086c4 <clearpteu>
80100e93:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100e96:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e99:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e9c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100ea3:	e9 96 00 00 00       	jmp    80100f3e <exec+0x30e>
    if(argc >= MAXARG)
80100ea8:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100eac:	0f 87 06 02 00 00    	ja     801010b8 <exec+0x488>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100eb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eb5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ebc:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ebf:	01 d0                	add    %edx,%eax
80100ec1:	8b 00                	mov    (%eax),%eax
80100ec3:	83 ec 0c             	sub    $0xc,%esp
80100ec6:	50                   	push   %eax
80100ec7:	e8 eb 48 00 00       	call   801057b7 <strlen>
80100ecc:	83 c4 10             	add    $0x10,%esp
80100ecf:	89 c2                	mov    %eax,%edx
80100ed1:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ed4:	29 d0                	sub    %edx,%eax
80100ed6:	83 e8 01             	sub    $0x1,%eax
80100ed9:	83 e0 fc             	and    $0xfffffffc,%eax
80100edc:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100edf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ee2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ee9:	8b 45 0c             	mov    0xc(%ebp),%eax
80100eec:	01 d0                	add    %edx,%eax
80100eee:	8b 00                	mov    (%eax),%eax
80100ef0:	83 ec 0c             	sub    $0xc,%esp
80100ef3:	50                   	push   %eax
80100ef4:	e8 be 48 00 00       	call   801057b7 <strlen>
80100ef9:	83 c4 10             	add    $0x10,%esp
80100efc:	83 c0 01             	add    $0x1,%eax
80100eff:	89 c1                	mov    %eax,%ecx
80100f01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f04:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f0b:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f0e:	01 d0                	add    %edx,%eax
80100f10:	8b 00                	mov    (%eax),%eax
80100f12:	51                   	push   %ecx
80100f13:	50                   	push   %eax
80100f14:	ff 75 dc             	pushl  -0x24(%ebp)
80100f17:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f1a:	e8 61 79 00 00       	call   80108880 <copyout>
80100f1f:	83 c4 10             	add    $0x10,%esp
80100f22:	85 c0                	test   %eax,%eax
80100f24:	0f 88 91 01 00 00    	js     801010bb <exec+0x48b>
      goto bad;
    ustack[3+argc] = sp;
80100f2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f2d:	8d 50 03             	lea    0x3(%eax),%edx
80100f30:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f33:	89 84 95 2c ff ff ff 	mov    %eax,-0xd4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100f3a:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100f3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f41:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f48:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f4b:	01 d0                	add    %edx,%eax
80100f4d:	8b 00                	mov    (%eax),%eax
80100f4f:	85 c0                	test   %eax,%eax
80100f51:	0f 85 51 ff ff ff    	jne    80100ea8 <exec+0x278>
  }
  ustack[3+argc] = 0;
80100f57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f5a:	83 c0 03             	add    $0x3,%eax
80100f5d:	c7 84 85 2c ff ff ff 	movl   $0x0,-0xd4(%ebp,%eax,4)
80100f64:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100f68:	c7 85 2c ff ff ff ff 	movl   $0xffffffff,-0xd4(%ebp)
80100f6f:	ff ff ff 
  ustack[1] = argc;
80100f72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f75:	89 85 30 ff ff ff    	mov    %eax,-0xd0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100f7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f7e:	83 c0 01             	add    $0x1,%eax
80100f81:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f88:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f8b:	29 d0                	sub    %edx,%eax
80100f8d:	89 85 34 ff ff ff    	mov    %eax,-0xcc(%ebp)

  sp -= (3+argc+1) * 4;
80100f93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f96:	83 c0 04             	add    $0x4,%eax
80100f99:	c1 e0 02             	shl    $0x2,%eax
80100f9c:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100f9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100fa2:	83 c0 04             	add    $0x4,%eax
80100fa5:	c1 e0 02             	shl    $0x2,%eax
80100fa8:	50                   	push   %eax
80100fa9:	8d 85 2c ff ff ff    	lea    -0xd4(%ebp),%eax
80100faf:	50                   	push   %eax
80100fb0:	ff 75 dc             	pushl  -0x24(%ebp)
80100fb3:	ff 75 d4             	pushl  -0x2c(%ebp)
80100fb6:	e8 c5 78 00 00       	call   80108880 <copyout>
80100fbb:	83 c4 10             	add    $0x10,%esp
80100fbe:	85 c0                	test   %eax,%eax
80100fc0:	0f 88 f8 00 00 00    	js     801010be <exec+0x48e>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100fc6:	8b 45 08             	mov    0x8(%ebp),%eax
80100fc9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fcf:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100fd2:	eb 17                	jmp    80100feb <exec+0x3bb>
    if(*s == '/')
80100fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fd7:	0f b6 00             	movzbl (%eax),%eax
80100fda:	3c 2f                	cmp    $0x2f,%al
80100fdc:	75 09                	jne    80100fe7 <exec+0x3b7>
      last = s+1;
80100fde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fe1:	83 c0 01             	add    $0x1,%eax
80100fe4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100fe7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100feb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fee:	0f b6 00             	movzbl (%eax),%eax
80100ff1:	84 c0                	test   %al,%al
80100ff3:	75 df                	jne    80100fd4 <exec+0x3a4>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100ff5:	8b 45 c8             	mov    -0x38(%ebp),%eax
80100ff8:	83 c0 6c             	add    $0x6c,%eax
80100ffb:	83 ec 04             	sub    $0x4,%esp
80100ffe:	6a 10                	push   $0x10
80101000:	ff 75 f0             	pushl  -0x10(%ebp)
80101003:	50                   	push   %eax
80101004:	e8 60 47 00 00       	call   80105769 <safestrcpy>
80101009:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
8010100c:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010100f:	8b 40 04             	mov    0x4(%eax),%eax
80101012:	89 45 bc             	mov    %eax,-0x44(%ebp)
  curproc->pgdir = pgdir;
80101015:	8b 45 c8             	mov    -0x38(%ebp),%eax
80101018:	8b 55 d4             	mov    -0x2c(%ebp),%edx
8010101b:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
8010101e:	8b 45 c8             	mov    -0x38(%ebp),%eax
80101021:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101024:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80101026:	8b 45 c8             	mov    -0x38(%ebp),%eax
80101029:	8b 40 18             	mov    0x18(%eax),%eax
8010102c:	8b 95 10 ff ff ff    	mov    -0xf0(%ebp),%edx
80101032:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80101035:	8b 45 c8             	mov    -0x38(%ebp),%eax
80101038:	8b 40 18             	mov    0x18(%eax),%eax
8010103b:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010103e:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80101041:	83 ec 0c             	sub    $0xc,%esp
80101044:	ff 75 c8             	pushl  -0x38(%ebp)
80101047:	e8 1e 71 00 00       	call   8010816a <switchuvm>
8010104c:	83 c4 10             	add    $0x10,%esp
  
  uint a;
  a = 0;
8010104f:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  for (; a < sz; a += PGSIZE){
80101056:	eb 25                	jmp    8010107d <exec+0x44d>
    if(a!=sz-2*PGSIZE)
80101058:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010105b:	2d 00 20 00 00       	sub    $0x2000,%eax
80101060:	39 45 cc             	cmp    %eax,-0x34(%ebp)
80101063:	74 11                	je     80101076 <exec+0x446>
      mencrypt((char*)a,1);
80101065:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101068:	83 ec 08             	sub    $0x8,%esp
8010106b:	6a 01                	push   $0x1
8010106d:	50                   	push   %eax
8010106e:	e8 54 7c 00 00       	call   80108cc7 <mencrypt>
80101073:	83 c4 10             	add    $0x10,%esp
  for (; a < sz; a += PGSIZE){
80101076:	81 45 cc 00 10 00 00 	addl   $0x1000,-0x34(%ebp)
8010107d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101080:	3b 45 e0             	cmp    -0x20(%ebp),%eax
80101083:	72 d3                	jb     80101058 <exec+0x428>
  }
  
  
  
  freevm(oldpgdir);
80101085:	83 ec 0c             	sub    $0xc,%esp
80101088:	ff 75 bc             	pushl  -0x44(%ebp)
8010108b:	e8 95 75 00 00       	call   80108625 <freevm>
80101090:	83 c4 10             	add    $0x10,%esp
  return 0;
80101093:	b8 00 00 00 00       	mov    $0x0,%eax
80101098:	eb 57                	jmp    801010f1 <exec+0x4c1>
    goto bad;
8010109a:	90                   	nop
8010109b:	eb 22                	jmp    801010bf <exec+0x48f>
    goto bad;
8010109d:	90                   	nop
8010109e:	eb 1f                	jmp    801010bf <exec+0x48f>
    goto bad;
801010a0:	90                   	nop
801010a1:	eb 1c                	jmp    801010bf <exec+0x48f>
      goto bad;
801010a3:	90                   	nop
801010a4:	eb 19                	jmp    801010bf <exec+0x48f>
      goto bad;
801010a6:	90                   	nop
801010a7:	eb 16                	jmp    801010bf <exec+0x48f>
      goto bad;
801010a9:	90                   	nop
801010aa:	eb 13                	jmp    801010bf <exec+0x48f>
      goto bad;
801010ac:	90                   	nop
801010ad:	eb 10                	jmp    801010bf <exec+0x48f>
      goto bad;
801010af:	90                   	nop
801010b0:	eb 0d                	jmp    801010bf <exec+0x48f>
      goto bad;
801010b2:	90                   	nop
801010b3:	eb 0a                	jmp    801010bf <exec+0x48f>
    goto bad;
801010b5:	90                   	nop
801010b6:	eb 07                	jmp    801010bf <exec+0x48f>
      goto bad;
801010b8:	90                   	nop
801010b9:	eb 04                	jmp    801010bf <exec+0x48f>
      goto bad;
801010bb:	90                   	nop
801010bc:	eb 01                	jmp    801010bf <exec+0x48f>
    goto bad;
801010be:	90                   	nop

 bad:
  if(pgdir)
801010bf:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
801010c3:	74 0e                	je     801010d3 <exec+0x4a3>
    freevm(pgdir);
801010c5:	83 ec 0c             	sub    $0xc,%esp
801010c8:	ff 75 d4             	pushl  -0x2c(%ebp)
801010cb:	e8 55 75 00 00       	call   80108625 <freevm>
801010d0:	83 c4 10             	add    $0x10,%esp
  if(ip){
801010d3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
801010d7:	74 13                	je     801010ec <exec+0x4bc>
    iunlockput(ip);
801010d9:	83 ec 0c             	sub    $0xc,%esp
801010dc:	ff 75 d8             	pushl  -0x28(%ebp)
801010df:	e8 b4 0c 00 00       	call   80101d98 <iunlockput>
801010e4:	83 c4 10             	add    $0x10,%esp
    end_op();
801010e7:	e8 f4 26 00 00       	call   801037e0 <end_op>
  }
  return -1;
801010ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801010f1:	c9                   	leave  
801010f2:	c3                   	ret    

801010f3 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
801010f3:	f3 0f 1e fb          	endbr32 
801010f7:	55                   	push   %ebp
801010f8:	89 e5                	mov    %esp,%ebp
801010fa:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
801010fd:	83 ec 08             	sub    $0x8,%esp
80101100:	68 59 92 10 80       	push   $0x80109259
80101105:	68 60 20 11 80       	push   $0x80112060
8010110a:	e8 7a 41 00 00       	call   80105289 <initlock>
8010110f:	83 c4 10             	add    $0x10,%esp
}
80101112:	90                   	nop
80101113:	c9                   	leave  
80101114:	c3                   	ret    

80101115 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101115:	f3 0f 1e fb          	endbr32 
80101119:	55                   	push   %ebp
8010111a:	89 e5                	mov    %esp,%ebp
8010111c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
8010111f:	83 ec 0c             	sub    $0xc,%esp
80101122:	68 60 20 11 80       	push   $0x80112060
80101127:	e8 83 41 00 00       	call   801052af <acquire>
8010112c:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010112f:	c7 45 f4 94 20 11 80 	movl   $0x80112094,-0xc(%ebp)
80101136:	eb 2d                	jmp    80101165 <filealloc+0x50>
    if(f->ref == 0){
80101138:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010113b:	8b 40 04             	mov    0x4(%eax),%eax
8010113e:	85 c0                	test   %eax,%eax
80101140:	75 1f                	jne    80101161 <filealloc+0x4c>
      f->ref = 1;
80101142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101145:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010114c:	83 ec 0c             	sub    $0xc,%esp
8010114f:	68 60 20 11 80       	push   $0x80112060
80101154:	e8 c8 41 00 00       	call   80105321 <release>
80101159:	83 c4 10             	add    $0x10,%esp
      return f;
8010115c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010115f:	eb 23                	jmp    80101184 <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101161:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101165:	b8 f4 29 11 80       	mov    $0x801129f4,%eax
8010116a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010116d:	72 c9                	jb     80101138 <filealloc+0x23>
    }
  }
  release(&ftable.lock);
8010116f:	83 ec 0c             	sub    $0xc,%esp
80101172:	68 60 20 11 80       	push   $0x80112060
80101177:	e8 a5 41 00 00       	call   80105321 <release>
8010117c:	83 c4 10             	add    $0x10,%esp
  return 0;
8010117f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101184:	c9                   	leave  
80101185:	c3                   	ret    

80101186 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101186:	f3 0f 1e fb          	endbr32 
8010118a:	55                   	push   %ebp
8010118b:	89 e5                	mov    %esp,%ebp
8010118d:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101190:	83 ec 0c             	sub    $0xc,%esp
80101193:	68 60 20 11 80       	push   $0x80112060
80101198:	e8 12 41 00 00       	call   801052af <acquire>
8010119d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801011a0:	8b 45 08             	mov    0x8(%ebp),%eax
801011a3:	8b 40 04             	mov    0x4(%eax),%eax
801011a6:	85 c0                	test   %eax,%eax
801011a8:	7f 0d                	jg     801011b7 <filedup+0x31>
    panic("filedup");
801011aa:	83 ec 0c             	sub    $0xc,%esp
801011ad:	68 60 92 10 80       	push   $0x80109260
801011b2:	e8 51 f4 ff ff       	call   80100608 <panic>
  f->ref++;
801011b7:	8b 45 08             	mov    0x8(%ebp),%eax
801011ba:	8b 40 04             	mov    0x4(%eax),%eax
801011bd:	8d 50 01             	lea    0x1(%eax),%edx
801011c0:	8b 45 08             	mov    0x8(%ebp),%eax
801011c3:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801011c6:	83 ec 0c             	sub    $0xc,%esp
801011c9:	68 60 20 11 80       	push   $0x80112060
801011ce:	e8 4e 41 00 00       	call   80105321 <release>
801011d3:	83 c4 10             	add    $0x10,%esp
  return f;
801011d6:	8b 45 08             	mov    0x8(%ebp),%eax
}
801011d9:	c9                   	leave  
801011da:	c3                   	ret    

801011db <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801011db:	f3 0f 1e fb          	endbr32 
801011df:	55                   	push   %ebp
801011e0:	89 e5                	mov    %esp,%ebp
801011e2:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801011e5:	83 ec 0c             	sub    $0xc,%esp
801011e8:	68 60 20 11 80       	push   $0x80112060
801011ed:	e8 bd 40 00 00       	call   801052af <acquire>
801011f2:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801011f5:	8b 45 08             	mov    0x8(%ebp),%eax
801011f8:	8b 40 04             	mov    0x4(%eax),%eax
801011fb:	85 c0                	test   %eax,%eax
801011fd:	7f 0d                	jg     8010120c <fileclose+0x31>
    panic("fileclose");
801011ff:	83 ec 0c             	sub    $0xc,%esp
80101202:	68 68 92 10 80       	push   $0x80109268
80101207:	e8 fc f3 ff ff       	call   80100608 <panic>
  if(--f->ref > 0){
8010120c:	8b 45 08             	mov    0x8(%ebp),%eax
8010120f:	8b 40 04             	mov    0x4(%eax),%eax
80101212:	8d 50 ff             	lea    -0x1(%eax),%edx
80101215:	8b 45 08             	mov    0x8(%ebp),%eax
80101218:	89 50 04             	mov    %edx,0x4(%eax)
8010121b:	8b 45 08             	mov    0x8(%ebp),%eax
8010121e:	8b 40 04             	mov    0x4(%eax),%eax
80101221:	85 c0                	test   %eax,%eax
80101223:	7e 15                	jle    8010123a <fileclose+0x5f>
    release(&ftable.lock);
80101225:	83 ec 0c             	sub    $0xc,%esp
80101228:	68 60 20 11 80       	push   $0x80112060
8010122d:	e8 ef 40 00 00       	call   80105321 <release>
80101232:	83 c4 10             	add    $0x10,%esp
80101235:	e9 8b 00 00 00       	jmp    801012c5 <fileclose+0xea>
    return;
  }
  ff = *f;
8010123a:	8b 45 08             	mov    0x8(%ebp),%eax
8010123d:	8b 10                	mov    (%eax),%edx
8010123f:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101242:	8b 50 04             	mov    0x4(%eax),%edx
80101245:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101248:	8b 50 08             	mov    0x8(%eax),%edx
8010124b:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010124e:	8b 50 0c             	mov    0xc(%eax),%edx
80101251:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101254:	8b 50 10             	mov    0x10(%eax),%edx
80101257:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010125a:	8b 40 14             	mov    0x14(%eax),%eax
8010125d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101260:	8b 45 08             	mov    0x8(%ebp),%eax
80101263:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010126a:	8b 45 08             	mov    0x8(%ebp),%eax
8010126d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101273:	83 ec 0c             	sub    $0xc,%esp
80101276:	68 60 20 11 80       	push   $0x80112060
8010127b:	e8 a1 40 00 00       	call   80105321 <release>
80101280:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101283:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101286:	83 f8 01             	cmp    $0x1,%eax
80101289:	75 19                	jne    801012a4 <fileclose+0xc9>
    pipeclose(ff.pipe, ff.writable);
8010128b:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010128f:	0f be d0             	movsbl %al,%edx
80101292:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101295:	83 ec 08             	sub    $0x8,%esp
80101298:	52                   	push   %edx
80101299:	50                   	push   %eax
8010129a:	e8 e7 2e 00 00       	call   80104186 <pipeclose>
8010129f:	83 c4 10             	add    $0x10,%esp
801012a2:	eb 21                	jmp    801012c5 <fileclose+0xea>
  else if(ff.type == FD_INODE){
801012a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801012a7:	83 f8 02             	cmp    $0x2,%eax
801012aa:	75 19                	jne    801012c5 <fileclose+0xea>
    begin_op();
801012ac:	e8 9f 24 00 00       	call   80103750 <begin_op>
    iput(ff.ip);
801012b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012b4:	83 ec 0c             	sub    $0xc,%esp
801012b7:	50                   	push   %eax
801012b8:	e8 07 0a 00 00       	call   80101cc4 <iput>
801012bd:	83 c4 10             	add    $0x10,%esp
    end_op();
801012c0:	e8 1b 25 00 00       	call   801037e0 <end_op>
  }
}
801012c5:	c9                   	leave  
801012c6:	c3                   	ret    

801012c7 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801012c7:	f3 0f 1e fb          	endbr32 
801012cb:	55                   	push   %ebp
801012cc:	89 e5                	mov    %esp,%ebp
801012ce:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801012d1:	8b 45 08             	mov    0x8(%ebp),%eax
801012d4:	8b 00                	mov    (%eax),%eax
801012d6:	83 f8 02             	cmp    $0x2,%eax
801012d9:	75 40                	jne    8010131b <filestat+0x54>
    ilock(f->ip);
801012db:	8b 45 08             	mov    0x8(%ebp),%eax
801012de:	8b 40 10             	mov    0x10(%eax),%eax
801012e1:	83 ec 0c             	sub    $0xc,%esp
801012e4:	50                   	push   %eax
801012e5:	e8 71 08 00 00       	call   80101b5b <ilock>
801012ea:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801012ed:	8b 45 08             	mov    0x8(%ebp),%eax
801012f0:	8b 40 10             	mov    0x10(%eax),%eax
801012f3:	83 ec 08             	sub    $0x8,%esp
801012f6:	ff 75 0c             	pushl  0xc(%ebp)
801012f9:	50                   	push   %eax
801012fa:	e8 1a 0d 00 00       	call   80102019 <stati>
801012ff:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101302:	8b 45 08             	mov    0x8(%ebp),%eax
80101305:	8b 40 10             	mov    0x10(%eax),%eax
80101308:	83 ec 0c             	sub    $0xc,%esp
8010130b:	50                   	push   %eax
8010130c:	e8 61 09 00 00       	call   80101c72 <iunlock>
80101311:	83 c4 10             	add    $0x10,%esp
    return 0;
80101314:	b8 00 00 00 00       	mov    $0x0,%eax
80101319:	eb 05                	jmp    80101320 <filestat+0x59>
  }
  return -1;
8010131b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101320:	c9                   	leave  
80101321:	c3                   	ret    

80101322 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101322:	f3 0f 1e fb          	endbr32 
80101326:	55                   	push   %ebp
80101327:	89 e5                	mov    %esp,%ebp
80101329:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
8010132c:	8b 45 08             	mov    0x8(%ebp),%eax
8010132f:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101333:	84 c0                	test   %al,%al
80101335:	75 0a                	jne    80101341 <fileread+0x1f>
    return -1;
80101337:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010133c:	e9 9b 00 00 00       	jmp    801013dc <fileread+0xba>
  if(f->type == FD_PIPE)
80101341:	8b 45 08             	mov    0x8(%ebp),%eax
80101344:	8b 00                	mov    (%eax),%eax
80101346:	83 f8 01             	cmp    $0x1,%eax
80101349:	75 1a                	jne    80101365 <fileread+0x43>
    return piperead(f->pipe, addr, n);
8010134b:	8b 45 08             	mov    0x8(%ebp),%eax
8010134e:	8b 40 0c             	mov    0xc(%eax),%eax
80101351:	83 ec 04             	sub    $0x4,%esp
80101354:	ff 75 10             	pushl  0x10(%ebp)
80101357:	ff 75 0c             	pushl  0xc(%ebp)
8010135a:	50                   	push   %eax
8010135b:	e8 db 2f 00 00       	call   8010433b <piperead>
80101360:	83 c4 10             	add    $0x10,%esp
80101363:	eb 77                	jmp    801013dc <fileread+0xba>
  if(f->type == FD_INODE){
80101365:	8b 45 08             	mov    0x8(%ebp),%eax
80101368:	8b 00                	mov    (%eax),%eax
8010136a:	83 f8 02             	cmp    $0x2,%eax
8010136d:	75 60                	jne    801013cf <fileread+0xad>
    ilock(f->ip);
8010136f:	8b 45 08             	mov    0x8(%ebp),%eax
80101372:	8b 40 10             	mov    0x10(%eax),%eax
80101375:	83 ec 0c             	sub    $0xc,%esp
80101378:	50                   	push   %eax
80101379:	e8 dd 07 00 00       	call   80101b5b <ilock>
8010137e:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101381:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101384:	8b 45 08             	mov    0x8(%ebp),%eax
80101387:	8b 50 14             	mov    0x14(%eax),%edx
8010138a:	8b 45 08             	mov    0x8(%ebp),%eax
8010138d:	8b 40 10             	mov    0x10(%eax),%eax
80101390:	51                   	push   %ecx
80101391:	52                   	push   %edx
80101392:	ff 75 0c             	pushl  0xc(%ebp)
80101395:	50                   	push   %eax
80101396:	e8 c8 0c 00 00       	call   80102063 <readi>
8010139b:	83 c4 10             	add    $0x10,%esp
8010139e:	89 45 f4             	mov    %eax,-0xc(%ebp)
801013a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801013a5:	7e 11                	jle    801013b8 <fileread+0x96>
      f->off += r;
801013a7:	8b 45 08             	mov    0x8(%ebp),%eax
801013aa:	8b 50 14             	mov    0x14(%eax),%edx
801013ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013b0:	01 c2                	add    %eax,%edx
801013b2:	8b 45 08             	mov    0x8(%ebp),%eax
801013b5:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801013b8:	8b 45 08             	mov    0x8(%ebp),%eax
801013bb:	8b 40 10             	mov    0x10(%eax),%eax
801013be:	83 ec 0c             	sub    $0xc,%esp
801013c1:	50                   	push   %eax
801013c2:	e8 ab 08 00 00       	call   80101c72 <iunlock>
801013c7:	83 c4 10             	add    $0x10,%esp
    return r;
801013ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013cd:	eb 0d                	jmp    801013dc <fileread+0xba>
  }
  panic("fileread");
801013cf:	83 ec 0c             	sub    $0xc,%esp
801013d2:	68 72 92 10 80       	push   $0x80109272
801013d7:	e8 2c f2 ff ff       	call   80100608 <panic>
}
801013dc:	c9                   	leave  
801013dd:	c3                   	ret    

801013de <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801013de:	f3 0f 1e fb          	endbr32 
801013e2:	55                   	push   %ebp
801013e3:	89 e5                	mov    %esp,%ebp
801013e5:	53                   	push   %ebx
801013e6:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801013e9:	8b 45 08             	mov    0x8(%ebp),%eax
801013ec:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801013f0:	84 c0                	test   %al,%al
801013f2:	75 0a                	jne    801013fe <filewrite+0x20>
    return -1;
801013f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013f9:	e9 1b 01 00 00       	jmp    80101519 <filewrite+0x13b>
  if(f->type == FD_PIPE)
801013fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101401:	8b 00                	mov    (%eax),%eax
80101403:	83 f8 01             	cmp    $0x1,%eax
80101406:	75 1d                	jne    80101425 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
80101408:	8b 45 08             	mov    0x8(%ebp),%eax
8010140b:	8b 40 0c             	mov    0xc(%eax),%eax
8010140e:	83 ec 04             	sub    $0x4,%esp
80101411:	ff 75 10             	pushl  0x10(%ebp)
80101414:	ff 75 0c             	pushl  0xc(%ebp)
80101417:	50                   	push   %eax
80101418:	e8 18 2e 00 00       	call   80104235 <pipewrite>
8010141d:	83 c4 10             	add    $0x10,%esp
80101420:	e9 f4 00 00 00       	jmp    80101519 <filewrite+0x13b>
  if(f->type == FD_INODE){
80101425:	8b 45 08             	mov    0x8(%ebp),%eax
80101428:	8b 00                	mov    (%eax),%eax
8010142a:	83 f8 02             	cmp    $0x2,%eax
8010142d:	0f 85 d9 00 00 00    	jne    8010150c <filewrite+0x12e>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
80101433:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
8010143a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101441:	e9 a3 00 00 00       	jmp    801014e9 <filewrite+0x10b>
      int n1 = n - i;
80101446:	8b 45 10             	mov    0x10(%ebp),%eax
80101449:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010144c:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010144f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101452:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101455:	7e 06                	jle    8010145d <filewrite+0x7f>
        n1 = max;
80101457:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010145a:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010145d:	e8 ee 22 00 00       	call   80103750 <begin_op>
      ilock(f->ip);
80101462:	8b 45 08             	mov    0x8(%ebp),%eax
80101465:	8b 40 10             	mov    0x10(%eax),%eax
80101468:	83 ec 0c             	sub    $0xc,%esp
8010146b:	50                   	push   %eax
8010146c:	e8 ea 06 00 00       	call   80101b5b <ilock>
80101471:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101474:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101477:	8b 45 08             	mov    0x8(%ebp),%eax
8010147a:	8b 50 14             	mov    0x14(%eax),%edx
8010147d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101480:	8b 45 0c             	mov    0xc(%ebp),%eax
80101483:	01 c3                	add    %eax,%ebx
80101485:	8b 45 08             	mov    0x8(%ebp),%eax
80101488:	8b 40 10             	mov    0x10(%eax),%eax
8010148b:	51                   	push   %ecx
8010148c:	52                   	push   %edx
8010148d:	53                   	push   %ebx
8010148e:	50                   	push   %eax
8010148f:	e8 28 0d 00 00       	call   801021bc <writei>
80101494:	83 c4 10             	add    $0x10,%esp
80101497:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010149a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010149e:	7e 11                	jle    801014b1 <filewrite+0xd3>
        f->off += r;
801014a0:	8b 45 08             	mov    0x8(%ebp),%eax
801014a3:	8b 50 14             	mov    0x14(%eax),%edx
801014a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801014a9:	01 c2                	add    %eax,%edx
801014ab:	8b 45 08             	mov    0x8(%ebp),%eax
801014ae:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801014b1:	8b 45 08             	mov    0x8(%ebp),%eax
801014b4:	8b 40 10             	mov    0x10(%eax),%eax
801014b7:	83 ec 0c             	sub    $0xc,%esp
801014ba:	50                   	push   %eax
801014bb:	e8 b2 07 00 00       	call   80101c72 <iunlock>
801014c0:	83 c4 10             	add    $0x10,%esp
      end_op();
801014c3:	e8 18 23 00 00       	call   801037e0 <end_op>

      if(r < 0)
801014c8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801014cc:	78 29                	js     801014f7 <filewrite+0x119>
        break;
      if(r != n1)
801014ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
801014d1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801014d4:	74 0d                	je     801014e3 <filewrite+0x105>
        panic("short filewrite");
801014d6:	83 ec 0c             	sub    $0xc,%esp
801014d9:	68 7b 92 10 80       	push   $0x8010927b
801014de:	e8 25 f1 ff ff       	call   80100608 <panic>
      i += r;
801014e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801014e6:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
801014e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014ec:	3b 45 10             	cmp    0x10(%ebp),%eax
801014ef:	0f 8c 51 ff ff ff    	jl     80101446 <filewrite+0x68>
801014f5:	eb 01                	jmp    801014f8 <filewrite+0x11a>
        break;
801014f7:	90                   	nop
    }
    return i == n ? n : -1;
801014f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014fb:	3b 45 10             	cmp    0x10(%ebp),%eax
801014fe:	75 05                	jne    80101505 <filewrite+0x127>
80101500:	8b 45 10             	mov    0x10(%ebp),%eax
80101503:	eb 14                	jmp    80101519 <filewrite+0x13b>
80101505:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010150a:	eb 0d                	jmp    80101519 <filewrite+0x13b>
  }
  panic("filewrite");
8010150c:	83 ec 0c             	sub    $0xc,%esp
8010150f:	68 8b 92 10 80       	push   $0x8010928b
80101514:	e8 ef f0 ff ff       	call   80100608 <panic>
}
80101519:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010151c:	c9                   	leave  
8010151d:	c3                   	ret    

8010151e <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010151e:	f3 0f 1e fb          	endbr32 
80101522:	55                   	push   %ebp
80101523:	89 e5                	mov    %esp,%ebp
80101525:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
80101528:	8b 45 08             	mov    0x8(%ebp),%eax
8010152b:	83 ec 08             	sub    $0x8,%esp
8010152e:	6a 01                	push   $0x1
80101530:	50                   	push   %eax
80101531:	e8 a1 ec ff ff       	call   801001d7 <bread>
80101536:	83 c4 10             	add    $0x10,%esp
80101539:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010153c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010153f:	83 c0 5c             	add    $0x5c,%eax
80101542:	83 ec 04             	sub    $0x4,%esp
80101545:	6a 1c                	push   $0x1c
80101547:	50                   	push   %eax
80101548:	ff 75 0c             	pushl  0xc(%ebp)
8010154b:	e8 c5 40 00 00       	call   80105615 <memmove>
80101550:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101553:	83 ec 0c             	sub    $0xc,%esp
80101556:	ff 75 f4             	pushl  -0xc(%ebp)
80101559:	e8 03 ed ff ff       	call   80100261 <brelse>
8010155e:	83 c4 10             	add    $0x10,%esp
}
80101561:	90                   	nop
80101562:	c9                   	leave  
80101563:	c3                   	ret    

80101564 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101564:	f3 0f 1e fb          	endbr32 
80101568:	55                   	push   %ebp
80101569:	89 e5                	mov    %esp,%ebp
8010156b:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
8010156e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101571:	8b 45 08             	mov    0x8(%ebp),%eax
80101574:	83 ec 08             	sub    $0x8,%esp
80101577:	52                   	push   %edx
80101578:	50                   	push   %eax
80101579:	e8 59 ec ff ff       	call   801001d7 <bread>
8010157e:	83 c4 10             	add    $0x10,%esp
80101581:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101584:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101587:	83 c0 5c             	add    $0x5c,%eax
8010158a:	83 ec 04             	sub    $0x4,%esp
8010158d:	68 00 02 00 00       	push   $0x200
80101592:	6a 00                	push   $0x0
80101594:	50                   	push   %eax
80101595:	e8 b4 3f 00 00       	call   8010554e <memset>
8010159a:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010159d:	83 ec 0c             	sub    $0xc,%esp
801015a0:	ff 75 f4             	pushl  -0xc(%ebp)
801015a3:	e8 f1 23 00 00       	call   80103999 <log_write>
801015a8:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801015ab:	83 ec 0c             	sub    $0xc,%esp
801015ae:	ff 75 f4             	pushl  -0xc(%ebp)
801015b1:	e8 ab ec ff ff       	call   80100261 <brelse>
801015b6:	83 c4 10             	add    $0x10,%esp
}
801015b9:	90                   	nop
801015ba:	c9                   	leave  
801015bb:	c3                   	ret    

801015bc <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801015bc:	f3 0f 1e fb          	endbr32 
801015c0:	55                   	push   %ebp
801015c1:	89 e5                	mov    %esp,%ebp
801015c3:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801015c6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801015cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801015d4:	e9 13 01 00 00       	jmp    801016ec <balloc+0x130>
    bp = bread(dev, BBLOCK(b, sb));
801015d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015dc:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801015e2:	85 c0                	test   %eax,%eax
801015e4:	0f 48 c2             	cmovs  %edx,%eax
801015e7:	c1 f8 0c             	sar    $0xc,%eax
801015ea:	89 c2                	mov    %eax,%edx
801015ec:	a1 78 2a 11 80       	mov    0x80112a78,%eax
801015f1:	01 d0                	add    %edx,%eax
801015f3:	83 ec 08             	sub    $0x8,%esp
801015f6:	50                   	push   %eax
801015f7:	ff 75 08             	pushl  0x8(%ebp)
801015fa:	e8 d8 eb ff ff       	call   801001d7 <bread>
801015ff:	83 c4 10             	add    $0x10,%esp
80101602:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101605:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010160c:	e9 a6 00 00 00       	jmp    801016b7 <balloc+0xfb>
      m = 1 << (bi % 8);
80101611:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101614:	99                   	cltd   
80101615:	c1 ea 1d             	shr    $0x1d,%edx
80101618:	01 d0                	add    %edx,%eax
8010161a:	83 e0 07             	and    $0x7,%eax
8010161d:	29 d0                	sub    %edx,%eax
8010161f:	ba 01 00 00 00       	mov    $0x1,%edx
80101624:	89 c1                	mov    %eax,%ecx
80101626:	d3 e2                	shl    %cl,%edx
80101628:	89 d0                	mov    %edx,%eax
8010162a:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010162d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101630:	8d 50 07             	lea    0x7(%eax),%edx
80101633:	85 c0                	test   %eax,%eax
80101635:	0f 48 c2             	cmovs  %edx,%eax
80101638:	c1 f8 03             	sar    $0x3,%eax
8010163b:	89 c2                	mov    %eax,%edx
8010163d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101640:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101645:	0f b6 c0             	movzbl %al,%eax
80101648:	23 45 e8             	and    -0x18(%ebp),%eax
8010164b:	85 c0                	test   %eax,%eax
8010164d:	75 64                	jne    801016b3 <balloc+0xf7>
        bp->data[bi/8] |= m;  // Mark block in use.
8010164f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101652:	8d 50 07             	lea    0x7(%eax),%edx
80101655:	85 c0                	test   %eax,%eax
80101657:	0f 48 c2             	cmovs  %edx,%eax
8010165a:	c1 f8 03             	sar    $0x3,%eax
8010165d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101660:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101665:	89 d1                	mov    %edx,%ecx
80101667:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010166a:	09 ca                	or     %ecx,%edx
8010166c:	89 d1                	mov    %edx,%ecx
8010166e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101671:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101675:	83 ec 0c             	sub    $0xc,%esp
80101678:	ff 75 ec             	pushl  -0x14(%ebp)
8010167b:	e8 19 23 00 00       	call   80103999 <log_write>
80101680:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101683:	83 ec 0c             	sub    $0xc,%esp
80101686:	ff 75 ec             	pushl  -0x14(%ebp)
80101689:	e8 d3 eb ff ff       	call   80100261 <brelse>
8010168e:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101691:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101694:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101697:	01 c2                	add    %eax,%edx
80101699:	8b 45 08             	mov    0x8(%ebp),%eax
8010169c:	83 ec 08             	sub    $0x8,%esp
8010169f:	52                   	push   %edx
801016a0:	50                   	push   %eax
801016a1:	e8 be fe ff ff       	call   80101564 <bzero>
801016a6:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801016a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016af:	01 d0                	add    %edx,%eax
801016b1:	eb 57                	jmp    8010170a <balloc+0x14e>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801016b3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801016b7:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801016be:	7f 17                	jg     801016d7 <balloc+0x11b>
801016c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016c6:	01 d0                	add    %edx,%eax
801016c8:	89 c2                	mov    %eax,%edx
801016ca:	a1 60 2a 11 80       	mov    0x80112a60,%eax
801016cf:	39 c2                	cmp    %eax,%edx
801016d1:	0f 82 3a ff ff ff    	jb     80101611 <balloc+0x55>
      }
    }
    brelse(bp);
801016d7:	83 ec 0c             	sub    $0xc,%esp
801016da:	ff 75 ec             	pushl  -0x14(%ebp)
801016dd:	e8 7f eb ff ff       	call   80100261 <brelse>
801016e2:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
801016e5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801016ec:	8b 15 60 2a 11 80    	mov    0x80112a60,%edx
801016f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016f5:	39 c2                	cmp    %eax,%edx
801016f7:	0f 87 dc fe ff ff    	ja     801015d9 <balloc+0x1d>
  }
  panic("balloc: out of blocks");
801016fd:	83 ec 0c             	sub    $0xc,%esp
80101700:	68 98 92 10 80       	push   $0x80109298
80101705:	e8 fe ee ff ff       	call   80100608 <panic>
}
8010170a:	c9                   	leave  
8010170b:	c3                   	ret    

8010170c <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010170c:	f3 0f 1e fb          	endbr32 
80101710:	55                   	push   %ebp
80101711:	89 e5                	mov    %esp,%ebp
80101713:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
80101716:	8b 45 0c             	mov    0xc(%ebp),%eax
80101719:	c1 e8 0c             	shr    $0xc,%eax
8010171c:	89 c2                	mov    %eax,%edx
8010171e:	a1 78 2a 11 80       	mov    0x80112a78,%eax
80101723:	01 c2                	add    %eax,%edx
80101725:	8b 45 08             	mov    0x8(%ebp),%eax
80101728:	83 ec 08             	sub    $0x8,%esp
8010172b:	52                   	push   %edx
8010172c:	50                   	push   %eax
8010172d:	e8 a5 ea ff ff       	call   801001d7 <bread>
80101732:	83 c4 10             	add    $0x10,%esp
80101735:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101738:	8b 45 0c             	mov    0xc(%ebp),%eax
8010173b:	25 ff 0f 00 00       	and    $0xfff,%eax
80101740:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101743:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101746:	99                   	cltd   
80101747:	c1 ea 1d             	shr    $0x1d,%edx
8010174a:	01 d0                	add    %edx,%eax
8010174c:	83 e0 07             	and    $0x7,%eax
8010174f:	29 d0                	sub    %edx,%eax
80101751:	ba 01 00 00 00       	mov    $0x1,%edx
80101756:	89 c1                	mov    %eax,%ecx
80101758:	d3 e2                	shl    %cl,%edx
8010175a:	89 d0                	mov    %edx,%eax
8010175c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010175f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101762:	8d 50 07             	lea    0x7(%eax),%edx
80101765:	85 c0                	test   %eax,%eax
80101767:	0f 48 c2             	cmovs  %edx,%eax
8010176a:	c1 f8 03             	sar    $0x3,%eax
8010176d:	89 c2                	mov    %eax,%edx
8010176f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101772:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101777:	0f b6 c0             	movzbl %al,%eax
8010177a:	23 45 ec             	and    -0x14(%ebp),%eax
8010177d:	85 c0                	test   %eax,%eax
8010177f:	75 0d                	jne    8010178e <bfree+0x82>
    panic("freeing free block");
80101781:	83 ec 0c             	sub    $0xc,%esp
80101784:	68 ae 92 10 80       	push   $0x801092ae
80101789:	e8 7a ee ff ff       	call   80100608 <panic>
  bp->data[bi/8] &= ~m;
8010178e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101791:	8d 50 07             	lea    0x7(%eax),%edx
80101794:	85 c0                	test   %eax,%eax
80101796:	0f 48 c2             	cmovs  %edx,%eax
80101799:	c1 f8 03             	sar    $0x3,%eax
8010179c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010179f:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801017a4:	89 d1                	mov    %edx,%ecx
801017a6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801017a9:	f7 d2                	not    %edx
801017ab:	21 ca                	and    %ecx,%edx
801017ad:	89 d1                	mov    %edx,%ecx
801017af:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017b2:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
801017b6:	83 ec 0c             	sub    $0xc,%esp
801017b9:	ff 75 f4             	pushl  -0xc(%ebp)
801017bc:	e8 d8 21 00 00       	call   80103999 <log_write>
801017c1:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801017c4:	83 ec 0c             	sub    $0xc,%esp
801017c7:	ff 75 f4             	pushl  -0xc(%ebp)
801017ca:	e8 92 ea ff ff       	call   80100261 <brelse>
801017cf:	83 c4 10             	add    $0x10,%esp
}
801017d2:	90                   	nop
801017d3:	c9                   	leave  
801017d4:	c3                   	ret    

801017d5 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801017d5:	f3 0f 1e fb          	endbr32 
801017d9:	55                   	push   %ebp
801017da:	89 e5                	mov    %esp,%ebp
801017dc:	57                   	push   %edi
801017dd:	56                   	push   %esi
801017de:	53                   	push   %ebx
801017df:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
801017e2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
801017e9:	83 ec 08             	sub    $0x8,%esp
801017ec:	68 c1 92 10 80       	push   $0x801092c1
801017f1:	68 80 2a 11 80       	push   $0x80112a80
801017f6:	e8 8e 3a 00 00       	call   80105289 <initlock>
801017fb:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801017fe:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101805:	eb 2d                	jmp    80101834 <iinit+0x5f>
    initsleeplock(&icache.inode[i].lock, "inode");
80101807:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010180a:	89 d0                	mov    %edx,%eax
8010180c:	c1 e0 03             	shl    $0x3,%eax
8010180f:	01 d0                	add    %edx,%eax
80101811:	c1 e0 04             	shl    $0x4,%eax
80101814:	83 c0 30             	add    $0x30,%eax
80101817:	05 80 2a 11 80       	add    $0x80112a80,%eax
8010181c:	83 c0 10             	add    $0x10,%eax
8010181f:	83 ec 08             	sub    $0x8,%esp
80101822:	68 c8 92 10 80       	push   $0x801092c8
80101827:	50                   	push   %eax
80101828:	e8 c9 38 00 00       	call   801050f6 <initsleeplock>
8010182d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101830:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101834:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
80101838:	7e cd                	jle    80101807 <iinit+0x32>
  }

  readsb(dev, &sb);
8010183a:	83 ec 08             	sub    $0x8,%esp
8010183d:	68 60 2a 11 80       	push   $0x80112a60
80101842:	ff 75 08             	pushl  0x8(%ebp)
80101845:	e8 d4 fc ff ff       	call   8010151e <readsb>
8010184a:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
8010184d:	a1 78 2a 11 80       	mov    0x80112a78,%eax
80101852:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101855:	8b 3d 74 2a 11 80    	mov    0x80112a74,%edi
8010185b:	8b 35 70 2a 11 80    	mov    0x80112a70,%esi
80101861:	8b 1d 6c 2a 11 80    	mov    0x80112a6c,%ebx
80101867:	8b 0d 68 2a 11 80    	mov    0x80112a68,%ecx
8010186d:	8b 15 64 2a 11 80    	mov    0x80112a64,%edx
80101873:	a1 60 2a 11 80       	mov    0x80112a60,%eax
80101878:	ff 75 d4             	pushl  -0x2c(%ebp)
8010187b:	57                   	push   %edi
8010187c:	56                   	push   %esi
8010187d:	53                   	push   %ebx
8010187e:	51                   	push   %ecx
8010187f:	52                   	push   %edx
80101880:	50                   	push   %eax
80101881:	68 d0 92 10 80       	push   $0x801092d0
80101886:	e8 8d eb ff ff       	call   80100418 <cprintf>
8010188b:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010188e:	90                   	nop
8010188f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101892:	5b                   	pop    %ebx
80101893:	5e                   	pop    %esi
80101894:	5f                   	pop    %edi
80101895:	5d                   	pop    %ebp
80101896:	c3                   	ret    

80101897 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101897:	f3 0f 1e fb          	endbr32 
8010189b:	55                   	push   %ebp
8010189c:	89 e5                	mov    %esp,%ebp
8010189e:	83 ec 28             	sub    $0x28,%esp
801018a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801018a4:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801018a8:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801018af:	e9 9e 00 00 00       	jmp    80101952 <ialloc+0xbb>
    bp = bread(dev, IBLOCK(inum, sb));
801018b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b7:	c1 e8 03             	shr    $0x3,%eax
801018ba:	89 c2                	mov    %eax,%edx
801018bc:	a1 74 2a 11 80       	mov    0x80112a74,%eax
801018c1:	01 d0                	add    %edx,%eax
801018c3:	83 ec 08             	sub    $0x8,%esp
801018c6:	50                   	push   %eax
801018c7:	ff 75 08             	pushl  0x8(%ebp)
801018ca:	e8 08 e9 ff ff       	call   801001d7 <bread>
801018cf:	83 c4 10             	add    $0x10,%esp
801018d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801018d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018d8:	8d 50 5c             	lea    0x5c(%eax),%edx
801018db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018de:	83 e0 07             	and    $0x7,%eax
801018e1:	c1 e0 06             	shl    $0x6,%eax
801018e4:	01 d0                	add    %edx,%eax
801018e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801018e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018ec:	0f b7 00             	movzwl (%eax),%eax
801018ef:	66 85 c0             	test   %ax,%ax
801018f2:	75 4c                	jne    80101940 <ialloc+0xa9>
      memset(dip, 0, sizeof(*dip));
801018f4:	83 ec 04             	sub    $0x4,%esp
801018f7:	6a 40                	push   $0x40
801018f9:	6a 00                	push   $0x0
801018fb:	ff 75 ec             	pushl  -0x14(%ebp)
801018fe:	e8 4b 3c 00 00       	call   8010554e <memset>
80101903:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101906:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101909:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010190d:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101910:	83 ec 0c             	sub    $0xc,%esp
80101913:	ff 75 f0             	pushl  -0x10(%ebp)
80101916:	e8 7e 20 00 00       	call   80103999 <log_write>
8010191b:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
8010191e:	83 ec 0c             	sub    $0xc,%esp
80101921:	ff 75 f0             	pushl  -0x10(%ebp)
80101924:	e8 38 e9 ff ff       	call   80100261 <brelse>
80101929:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
8010192c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010192f:	83 ec 08             	sub    $0x8,%esp
80101932:	50                   	push   %eax
80101933:	ff 75 08             	pushl  0x8(%ebp)
80101936:	e8 fc 00 00 00       	call   80101a37 <iget>
8010193b:	83 c4 10             	add    $0x10,%esp
8010193e:	eb 30                	jmp    80101970 <ialloc+0xd9>
    }
    brelse(bp);
80101940:	83 ec 0c             	sub    $0xc,%esp
80101943:	ff 75 f0             	pushl  -0x10(%ebp)
80101946:	e8 16 e9 ff ff       	call   80100261 <brelse>
8010194b:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
8010194e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101952:	8b 15 68 2a 11 80    	mov    0x80112a68,%edx
80101958:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010195b:	39 c2                	cmp    %eax,%edx
8010195d:	0f 87 51 ff ff ff    	ja     801018b4 <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
80101963:	83 ec 0c             	sub    $0xc,%esp
80101966:	68 23 93 10 80       	push   $0x80109323
8010196b:	e8 98 ec ff ff       	call   80100608 <panic>
}
80101970:	c9                   	leave  
80101971:	c3                   	ret    

80101972 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101972:	f3 0f 1e fb          	endbr32 
80101976:	55                   	push   %ebp
80101977:	89 e5                	mov    %esp,%ebp
80101979:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010197c:	8b 45 08             	mov    0x8(%ebp),%eax
8010197f:	8b 40 04             	mov    0x4(%eax),%eax
80101982:	c1 e8 03             	shr    $0x3,%eax
80101985:	89 c2                	mov    %eax,%edx
80101987:	a1 74 2a 11 80       	mov    0x80112a74,%eax
8010198c:	01 c2                	add    %eax,%edx
8010198e:	8b 45 08             	mov    0x8(%ebp),%eax
80101991:	8b 00                	mov    (%eax),%eax
80101993:	83 ec 08             	sub    $0x8,%esp
80101996:	52                   	push   %edx
80101997:	50                   	push   %eax
80101998:	e8 3a e8 ff ff       	call   801001d7 <bread>
8010199d:	83 c4 10             	add    $0x10,%esp
801019a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801019a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a6:	8d 50 5c             	lea    0x5c(%eax),%edx
801019a9:	8b 45 08             	mov    0x8(%ebp),%eax
801019ac:	8b 40 04             	mov    0x4(%eax),%eax
801019af:	83 e0 07             	and    $0x7,%eax
801019b2:	c1 e0 06             	shl    $0x6,%eax
801019b5:	01 d0                	add    %edx,%eax
801019b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801019ba:	8b 45 08             	mov    0x8(%ebp),%eax
801019bd:	0f b7 50 50          	movzwl 0x50(%eax),%edx
801019c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019c4:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801019c7:	8b 45 08             	mov    0x8(%ebp),%eax
801019ca:	0f b7 50 52          	movzwl 0x52(%eax),%edx
801019ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019d1:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801019d5:	8b 45 08             	mov    0x8(%ebp),%eax
801019d8:	0f b7 50 54          	movzwl 0x54(%eax),%edx
801019dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019df:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801019e3:	8b 45 08             	mov    0x8(%ebp),%eax
801019e6:	0f b7 50 56          	movzwl 0x56(%eax),%edx
801019ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019ed:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801019f1:	8b 45 08             	mov    0x8(%ebp),%eax
801019f4:	8b 50 58             	mov    0x58(%eax),%edx
801019f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019fa:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801019fd:	8b 45 08             	mov    0x8(%ebp),%eax
80101a00:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a06:	83 c0 0c             	add    $0xc,%eax
80101a09:	83 ec 04             	sub    $0x4,%esp
80101a0c:	6a 34                	push   $0x34
80101a0e:	52                   	push   %edx
80101a0f:	50                   	push   %eax
80101a10:	e8 00 3c 00 00       	call   80105615 <memmove>
80101a15:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101a18:	83 ec 0c             	sub    $0xc,%esp
80101a1b:	ff 75 f4             	pushl  -0xc(%ebp)
80101a1e:	e8 76 1f 00 00       	call   80103999 <log_write>
80101a23:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101a26:	83 ec 0c             	sub    $0xc,%esp
80101a29:	ff 75 f4             	pushl  -0xc(%ebp)
80101a2c:	e8 30 e8 ff ff       	call   80100261 <brelse>
80101a31:	83 c4 10             	add    $0x10,%esp
}
80101a34:	90                   	nop
80101a35:	c9                   	leave  
80101a36:	c3                   	ret    

80101a37 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101a37:	f3 0f 1e fb          	endbr32 
80101a3b:	55                   	push   %ebp
80101a3c:	89 e5                	mov    %esp,%ebp
80101a3e:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101a41:	83 ec 0c             	sub    $0xc,%esp
80101a44:	68 80 2a 11 80       	push   $0x80112a80
80101a49:	e8 61 38 00 00       	call   801052af <acquire>
80101a4e:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101a51:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a58:	c7 45 f4 b4 2a 11 80 	movl   $0x80112ab4,-0xc(%ebp)
80101a5f:	eb 60                	jmp    80101ac1 <iget+0x8a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a64:	8b 40 08             	mov    0x8(%eax),%eax
80101a67:	85 c0                	test   %eax,%eax
80101a69:	7e 39                	jle    80101aa4 <iget+0x6d>
80101a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a6e:	8b 00                	mov    (%eax),%eax
80101a70:	39 45 08             	cmp    %eax,0x8(%ebp)
80101a73:	75 2f                	jne    80101aa4 <iget+0x6d>
80101a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a78:	8b 40 04             	mov    0x4(%eax),%eax
80101a7b:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101a7e:	75 24                	jne    80101aa4 <iget+0x6d>
      ip->ref++;
80101a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a83:	8b 40 08             	mov    0x8(%eax),%eax
80101a86:	8d 50 01             	lea    0x1(%eax),%edx
80101a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a8c:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101a8f:	83 ec 0c             	sub    $0xc,%esp
80101a92:	68 80 2a 11 80       	push   $0x80112a80
80101a97:	e8 85 38 00 00       	call   80105321 <release>
80101a9c:	83 c4 10             	add    $0x10,%esp
      return ip;
80101a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aa2:	eb 77                	jmp    80101b1b <iget+0xe4>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101aa4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101aa8:	75 10                	jne    80101aba <iget+0x83>
80101aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aad:	8b 40 08             	mov    0x8(%eax),%eax
80101ab0:	85 c0                	test   %eax,%eax
80101ab2:	75 06                	jne    80101aba <iget+0x83>
      empty = ip;
80101ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ab7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101aba:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101ac1:	81 7d f4 d4 46 11 80 	cmpl   $0x801146d4,-0xc(%ebp)
80101ac8:	72 97                	jb     80101a61 <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101aca:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101ace:	75 0d                	jne    80101add <iget+0xa6>
    panic("iget: no inodes");
80101ad0:	83 ec 0c             	sub    $0xc,%esp
80101ad3:	68 35 93 10 80       	push   $0x80109335
80101ad8:	e8 2b eb ff ff       	call   80100608 <panic>

  ip = empty;
80101add:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ae0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ae6:	8b 55 08             	mov    0x8(%ebp),%edx
80101ae9:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aee:	8b 55 0c             	mov    0xc(%ebp),%edx
80101af1:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101af7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b01:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101b08:	83 ec 0c             	sub    $0xc,%esp
80101b0b:	68 80 2a 11 80       	push   $0x80112a80
80101b10:	e8 0c 38 00 00       	call   80105321 <release>
80101b15:	83 c4 10             	add    $0x10,%esp

  return ip;
80101b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101b1b:	c9                   	leave  
80101b1c:	c3                   	ret    

80101b1d <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101b1d:	f3 0f 1e fb          	endbr32 
80101b21:	55                   	push   %ebp
80101b22:	89 e5                	mov    %esp,%ebp
80101b24:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101b27:	83 ec 0c             	sub    $0xc,%esp
80101b2a:	68 80 2a 11 80       	push   $0x80112a80
80101b2f:	e8 7b 37 00 00       	call   801052af <acquire>
80101b34:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101b37:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3a:	8b 40 08             	mov    0x8(%eax),%eax
80101b3d:	8d 50 01             	lea    0x1(%eax),%edx
80101b40:	8b 45 08             	mov    0x8(%ebp),%eax
80101b43:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b46:	83 ec 0c             	sub    $0xc,%esp
80101b49:	68 80 2a 11 80       	push   $0x80112a80
80101b4e:	e8 ce 37 00 00       	call   80105321 <release>
80101b53:	83 c4 10             	add    $0x10,%esp
  return ip;
80101b56:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101b59:	c9                   	leave  
80101b5a:	c3                   	ret    

80101b5b <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101b5b:	f3 0f 1e fb          	endbr32 
80101b5f:	55                   	push   %ebp
80101b60:	89 e5                	mov    %esp,%ebp
80101b62:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101b65:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b69:	74 0a                	je     80101b75 <ilock+0x1a>
80101b6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6e:	8b 40 08             	mov    0x8(%eax),%eax
80101b71:	85 c0                	test   %eax,%eax
80101b73:	7f 0d                	jg     80101b82 <ilock+0x27>
    panic("ilock");
80101b75:	83 ec 0c             	sub    $0xc,%esp
80101b78:	68 45 93 10 80       	push   $0x80109345
80101b7d:	e8 86 ea ff ff       	call   80100608 <panic>

  acquiresleep(&ip->lock);
80101b82:	8b 45 08             	mov    0x8(%ebp),%eax
80101b85:	83 c0 0c             	add    $0xc,%eax
80101b88:	83 ec 0c             	sub    $0xc,%esp
80101b8b:	50                   	push   %eax
80101b8c:	e8 a5 35 00 00       	call   80105136 <acquiresleep>
80101b91:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101b94:	8b 45 08             	mov    0x8(%ebp),%eax
80101b97:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b9a:	85 c0                	test   %eax,%eax
80101b9c:	0f 85 cd 00 00 00    	jne    80101c6f <ilock+0x114>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101ba2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba5:	8b 40 04             	mov    0x4(%eax),%eax
80101ba8:	c1 e8 03             	shr    $0x3,%eax
80101bab:	89 c2                	mov    %eax,%edx
80101bad:	a1 74 2a 11 80       	mov    0x80112a74,%eax
80101bb2:	01 c2                	add    %eax,%edx
80101bb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb7:	8b 00                	mov    (%eax),%eax
80101bb9:	83 ec 08             	sub    $0x8,%esp
80101bbc:	52                   	push   %edx
80101bbd:	50                   	push   %eax
80101bbe:	e8 14 e6 ff ff       	call   801001d7 <bread>
80101bc3:	83 c4 10             	add    $0x10,%esp
80101bc6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bcc:	8d 50 5c             	lea    0x5c(%eax),%edx
80101bcf:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd2:	8b 40 04             	mov    0x4(%eax),%eax
80101bd5:	83 e0 07             	and    $0x7,%eax
80101bd8:	c1 e0 06             	shl    $0x6,%eax
80101bdb:	01 d0                	add    %edx,%eax
80101bdd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101be0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101be3:	0f b7 10             	movzwl (%eax),%edx
80101be6:	8b 45 08             	mov    0x8(%ebp),%eax
80101be9:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101bed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bf0:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101bf4:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf7:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101bfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bfe:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101c02:	8b 45 08             	mov    0x8(%ebp),%eax
80101c05:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101c09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c0c:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101c10:	8b 45 08             	mov    0x8(%ebp),%eax
80101c13:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101c17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c1a:	8b 50 08             	mov    0x8(%eax),%edx
80101c1d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c20:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101c23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c26:	8d 50 0c             	lea    0xc(%eax),%edx
80101c29:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2c:	83 c0 5c             	add    $0x5c,%eax
80101c2f:	83 ec 04             	sub    $0x4,%esp
80101c32:	6a 34                	push   $0x34
80101c34:	52                   	push   %edx
80101c35:	50                   	push   %eax
80101c36:	e8 da 39 00 00       	call   80105615 <memmove>
80101c3b:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101c3e:	83 ec 0c             	sub    $0xc,%esp
80101c41:	ff 75 f4             	pushl  -0xc(%ebp)
80101c44:	e8 18 e6 ff ff       	call   80100261 <brelse>
80101c49:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101c4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4f:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101c56:	8b 45 08             	mov    0x8(%ebp),%eax
80101c59:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101c5d:	66 85 c0             	test   %ax,%ax
80101c60:	75 0d                	jne    80101c6f <ilock+0x114>
      panic("ilock: no type");
80101c62:	83 ec 0c             	sub    $0xc,%esp
80101c65:	68 4b 93 10 80       	push   $0x8010934b
80101c6a:	e8 99 e9 ff ff       	call   80100608 <panic>
  }
}
80101c6f:	90                   	nop
80101c70:	c9                   	leave  
80101c71:	c3                   	ret    

80101c72 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101c72:	f3 0f 1e fb          	endbr32 
80101c76:	55                   	push   %ebp
80101c77:	89 e5                	mov    %esp,%ebp
80101c79:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101c7c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101c80:	74 20                	je     80101ca2 <iunlock+0x30>
80101c82:	8b 45 08             	mov    0x8(%ebp),%eax
80101c85:	83 c0 0c             	add    $0xc,%eax
80101c88:	83 ec 0c             	sub    $0xc,%esp
80101c8b:	50                   	push   %eax
80101c8c:	e8 5f 35 00 00       	call   801051f0 <holdingsleep>
80101c91:	83 c4 10             	add    $0x10,%esp
80101c94:	85 c0                	test   %eax,%eax
80101c96:	74 0a                	je     80101ca2 <iunlock+0x30>
80101c98:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9b:	8b 40 08             	mov    0x8(%eax),%eax
80101c9e:	85 c0                	test   %eax,%eax
80101ca0:	7f 0d                	jg     80101caf <iunlock+0x3d>
    panic("iunlock");
80101ca2:	83 ec 0c             	sub    $0xc,%esp
80101ca5:	68 5a 93 10 80       	push   $0x8010935a
80101caa:	e8 59 e9 ff ff       	call   80100608 <panic>

  releasesleep(&ip->lock);
80101caf:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb2:	83 c0 0c             	add    $0xc,%eax
80101cb5:	83 ec 0c             	sub    $0xc,%esp
80101cb8:	50                   	push   %eax
80101cb9:	e8 e0 34 00 00       	call   8010519e <releasesleep>
80101cbe:	83 c4 10             	add    $0x10,%esp
}
80101cc1:	90                   	nop
80101cc2:	c9                   	leave  
80101cc3:	c3                   	ret    

80101cc4 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101cc4:	f3 0f 1e fb          	endbr32 
80101cc8:	55                   	push   %ebp
80101cc9:	89 e5                	mov    %esp,%ebp
80101ccb:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101cce:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd1:	83 c0 0c             	add    $0xc,%eax
80101cd4:	83 ec 0c             	sub    $0xc,%esp
80101cd7:	50                   	push   %eax
80101cd8:	e8 59 34 00 00       	call   80105136 <acquiresleep>
80101cdd:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101ce0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce3:	8b 40 4c             	mov    0x4c(%eax),%eax
80101ce6:	85 c0                	test   %eax,%eax
80101ce8:	74 6a                	je     80101d54 <iput+0x90>
80101cea:	8b 45 08             	mov    0x8(%ebp),%eax
80101ced:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101cf1:	66 85 c0             	test   %ax,%ax
80101cf4:	75 5e                	jne    80101d54 <iput+0x90>
    acquire(&icache.lock);
80101cf6:	83 ec 0c             	sub    $0xc,%esp
80101cf9:	68 80 2a 11 80       	push   $0x80112a80
80101cfe:	e8 ac 35 00 00       	call   801052af <acquire>
80101d03:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101d06:	8b 45 08             	mov    0x8(%ebp),%eax
80101d09:	8b 40 08             	mov    0x8(%eax),%eax
80101d0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101d0f:	83 ec 0c             	sub    $0xc,%esp
80101d12:	68 80 2a 11 80       	push   $0x80112a80
80101d17:	e8 05 36 00 00       	call   80105321 <release>
80101d1c:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101d1f:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101d23:	75 2f                	jne    80101d54 <iput+0x90>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101d25:	83 ec 0c             	sub    $0xc,%esp
80101d28:	ff 75 08             	pushl  0x8(%ebp)
80101d2b:	e8 b5 01 00 00       	call   80101ee5 <itrunc>
80101d30:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101d33:	8b 45 08             	mov    0x8(%ebp),%eax
80101d36:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101d3c:	83 ec 0c             	sub    $0xc,%esp
80101d3f:	ff 75 08             	pushl  0x8(%ebp)
80101d42:	e8 2b fc ff ff       	call   80101972 <iupdate>
80101d47:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101d4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d4d:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101d54:	8b 45 08             	mov    0x8(%ebp),%eax
80101d57:	83 c0 0c             	add    $0xc,%eax
80101d5a:	83 ec 0c             	sub    $0xc,%esp
80101d5d:	50                   	push   %eax
80101d5e:	e8 3b 34 00 00       	call   8010519e <releasesleep>
80101d63:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101d66:	83 ec 0c             	sub    $0xc,%esp
80101d69:	68 80 2a 11 80       	push   $0x80112a80
80101d6e:	e8 3c 35 00 00       	call   801052af <acquire>
80101d73:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101d76:	8b 45 08             	mov    0x8(%ebp),%eax
80101d79:	8b 40 08             	mov    0x8(%eax),%eax
80101d7c:	8d 50 ff             	lea    -0x1(%eax),%edx
80101d7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d82:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101d85:	83 ec 0c             	sub    $0xc,%esp
80101d88:	68 80 2a 11 80       	push   $0x80112a80
80101d8d:	e8 8f 35 00 00       	call   80105321 <release>
80101d92:	83 c4 10             	add    $0x10,%esp
}
80101d95:	90                   	nop
80101d96:	c9                   	leave  
80101d97:	c3                   	ret    

80101d98 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101d98:	f3 0f 1e fb          	endbr32 
80101d9c:	55                   	push   %ebp
80101d9d:	89 e5                	mov    %esp,%ebp
80101d9f:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101da2:	83 ec 0c             	sub    $0xc,%esp
80101da5:	ff 75 08             	pushl  0x8(%ebp)
80101da8:	e8 c5 fe ff ff       	call   80101c72 <iunlock>
80101dad:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101db0:	83 ec 0c             	sub    $0xc,%esp
80101db3:	ff 75 08             	pushl  0x8(%ebp)
80101db6:	e8 09 ff ff ff       	call   80101cc4 <iput>
80101dbb:	83 c4 10             	add    $0x10,%esp
}
80101dbe:	90                   	nop
80101dbf:	c9                   	leave  
80101dc0:	c3                   	ret    

80101dc1 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101dc1:	f3 0f 1e fb          	endbr32 
80101dc5:	55                   	push   %ebp
80101dc6:	89 e5                	mov    %esp,%ebp
80101dc8:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101dcb:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101dcf:	77 42                	ja     80101e13 <bmap+0x52>
    if((addr = ip->addrs[bn]) == 0)
80101dd1:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd4:	8b 55 0c             	mov    0xc(%ebp),%edx
80101dd7:	83 c2 14             	add    $0x14,%edx
80101dda:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101dde:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101de1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101de5:	75 24                	jne    80101e0b <bmap+0x4a>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101de7:	8b 45 08             	mov    0x8(%ebp),%eax
80101dea:	8b 00                	mov    (%eax),%eax
80101dec:	83 ec 0c             	sub    $0xc,%esp
80101def:	50                   	push   %eax
80101df0:	e8 c7 f7 ff ff       	call   801015bc <balloc>
80101df5:	83 c4 10             	add    $0x10,%esp
80101df8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dfb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dfe:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e01:	8d 4a 14             	lea    0x14(%edx),%ecx
80101e04:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e07:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e0e:	e9 d0 00 00 00       	jmp    80101ee3 <bmap+0x122>
  }
  bn -= NDIRECT;
80101e13:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101e17:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101e1b:	0f 87 b5 00 00 00    	ja     80101ed6 <bmap+0x115>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101e21:	8b 45 08             	mov    0x8(%ebp),%eax
80101e24:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e2d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e31:	75 20                	jne    80101e53 <bmap+0x92>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101e33:	8b 45 08             	mov    0x8(%ebp),%eax
80101e36:	8b 00                	mov    (%eax),%eax
80101e38:	83 ec 0c             	sub    $0xc,%esp
80101e3b:	50                   	push   %eax
80101e3c:	e8 7b f7 ff ff       	call   801015bc <balloc>
80101e41:	83 c4 10             	add    $0x10,%esp
80101e44:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e47:	8b 45 08             	mov    0x8(%ebp),%eax
80101e4a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e4d:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101e53:	8b 45 08             	mov    0x8(%ebp),%eax
80101e56:	8b 00                	mov    (%eax),%eax
80101e58:	83 ec 08             	sub    $0x8,%esp
80101e5b:	ff 75 f4             	pushl  -0xc(%ebp)
80101e5e:	50                   	push   %eax
80101e5f:	e8 73 e3 ff ff       	call   801001d7 <bread>
80101e64:	83 c4 10             	add    $0x10,%esp
80101e67:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101e6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e6d:	83 c0 5c             	add    $0x5c,%eax
80101e70:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101e73:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e76:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e7d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e80:	01 d0                	add    %edx,%eax
80101e82:	8b 00                	mov    (%eax),%eax
80101e84:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e87:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e8b:	75 36                	jne    80101ec3 <bmap+0x102>
      a[bn] = addr = balloc(ip->dev);
80101e8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e90:	8b 00                	mov    (%eax),%eax
80101e92:	83 ec 0c             	sub    $0xc,%esp
80101e95:	50                   	push   %eax
80101e96:	e8 21 f7 ff ff       	call   801015bc <balloc>
80101e9b:	83 c4 10             	add    $0x10,%esp
80101e9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ea1:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101eab:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eae:	01 c2                	add    %eax,%edx
80101eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101eb3:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101eb5:	83 ec 0c             	sub    $0xc,%esp
80101eb8:	ff 75 f0             	pushl  -0x10(%ebp)
80101ebb:	e8 d9 1a 00 00       	call   80103999 <log_write>
80101ec0:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101ec3:	83 ec 0c             	sub    $0xc,%esp
80101ec6:	ff 75 f0             	pushl  -0x10(%ebp)
80101ec9:	e8 93 e3 ff ff       	call   80100261 <brelse>
80101ece:	83 c4 10             	add    $0x10,%esp
    return addr;
80101ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ed4:	eb 0d                	jmp    80101ee3 <bmap+0x122>
  }

  panic("bmap: out of range");
80101ed6:	83 ec 0c             	sub    $0xc,%esp
80101ed9:	68 62 93 10 80       	push   $0x80109362
80101ede:	e8 25 e7 ff ff       	call   80100608 <panic>
}
80101ee3:	c9                   	leave  
80101ee4:	c3                   	ret    

80101ee5 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101ee5:	f3 0f 1e fb          	endbr32 
80101ee9:	55                   	push   %ebp
80101eea:	89 e5                	mov    %esp,%ebp
80101eec:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101eef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101ef6:	eb 45                	jmp    80101f3d <itrunc+0x58>
    if(ip->addrs[i]){
80101ef8:	8b 45 08             	mov    0x8(%ebp),%eax
80101efb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101efe:	83 c2 14             	add    $0x14,%edx
80101f01:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101f05:	85 c0                	test   %eax,%eax
80101f07:	74 30                	je     80101f39 <itrunc+0x54>
      bfree(ip->dev, ip->addrs[i]);
80101f09:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f0f:	83 c2 14             	add    $0x14,%edx
80101f12:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101f16:	8b 55 08             	mov    0x8(%ebp),%edx
80101f19:	8b 12                	mov    (%edx),%edx
80101f1b:	83 ec 08             	sub    $0x8,%esp
80101f1e:	50                   	push   %eax
80101f1f:	52                   	push   %edx
80101f20:	e8 e7 f7 ff ff       	call   8010170c <bfree>
80101f25:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101f28:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f2e:	83 c2 14             	add    $0x14,%edx
80101f31:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101f38:	00 
  for(i = 0; i < NDIRECT; i++){
80101f39:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101f3d:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101f41:	7e b5                	jle    80101ef8 <itrunc+0x13>
    }
  }

  if(ip->addrs[NDIRECT]){
80101f43:	8b 45 08             	mov    0x8(%ebp),%eax
80101f46:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101f4c:	85 c0                	test   %eax,%eax
80101f4e:	0f 84 aa 00 00 00    	je     80101ffe <itrunc+0x119>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101f54:	8b 45 08             	mov    0x8(%ebp),%eax
80101f57:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101f5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f60:	8b 00                	mov    (%eax),%eax
80101f62:	83 ec 08             	sub    $0x8,%esp
80101f65:	52                   	push   %edx
80101f66:	50                   	push   %eax
80101f67:	e8 6b e2 ff ff       	call   801001d7 <bread>
80101f6c:	83 c4 10             	add    $0x10,%esp
80101f6f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101f72:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f75:	83 c0 5c             	add    $0x5c,%eax
80101f78:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101f7b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101f82:	eb 3c                	jmp    80101fc0 <itrunc+0xdb>
      if(a[j])
80101f84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f87:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f8e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f91:	01 d0                	add    %edx,%eax
80101f93:	8b 00                	mov    (%eax),%eax
80101f95:	85 c0                	test   %eax,%eax
80101f97:	74 23                	je     80101fbc <itrunc+0xd7>
        bfree(ip->dev, a[j]);
80101f99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f9c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101fa3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101fa6:	01 d0                	add    %edx,%eax
80101fa8:	8b 00                	mov    (%eax),%eax
80101faa:	8b 55 08             	mov    0x8(%ebp),%edx
80101fad:	8b 12                	mov    (%edx),%edx
80101faf:	83 ec 08             	sub    $0x8,%esp
80101fb2:	50                   	push   %eax
80101fb3:	52                   	push   %edx
80101fb4:	e8 53 f7 ff ff       	call   8010170c <bfree>
80101fb9:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101fbc:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101fc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fc3:	83 f8 7f             	cmp    $0x7f,%eax
80101fc6:	76 bc                	jbe    80101f84 <itrunc+0x9f>
    }
    brelse(bp);
80101fc8:	83 ec 0c             	sub    $0xc,%esp
80101fcb:	ff 75 ec             	pushl  -0x14(%ebp)
80101fce:	e8 8e e2 ff ff       	call   80100261 <brelse>
80101fd3:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101fd6:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd9:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101fdf:	8b 55 08             	mov    0x8(%ebp),%edx
80101fe2:	8b 12                	mov    (%edx),%edx
80101fe4:	83 ec 08             	sub    $0x8,%esp
80101fe7:	50                   	push   %eax
80101fe8:	52                   	push   %edx
80101fe9:	e8 1e f7 ff ff       	call   8010170c <bfree>
80101fee:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101ff1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff4:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101ffb:	00 00 00 
  }

  ip->size = 0;
80101ffe:	8b 45 08             	mov    0x8(%ebp),%eax
80102001:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80102008:	83 ec 0c             	sub    $0xc,%esp
8010200b:	ff 75 08             	pushl  0x8(%ebp)
8010200e:	e8 5f f9 ff ff       	call   80101972 <iupdate>
80102013:	83 c4 10             	add    $0x10,%esp
}
80102016:	90                   	nop
80102017:	c9                   	leave  
80102018:	c3                   	ret    

80102019 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80102019:	f3 0f 1e fb          	endbr32 
8010201d:	55                   	push   %ebp
8010201e:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80102020:	8b 45 08             	mov    0x8(%ebp),%eax
80102023:	8b 00                	mov    (%eax),%eax
80102025:	89 c2                	mov    %eax,%edx
80102027:	8b 45 0c             	mov    0xc(%ebp),%eax
8010202a:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
8010202d:	8b 45 08             	mov    0x8(%ebp),%eax
80102030:	8b 50 04             	mov    0x4(%eax),%edx
80102033:	8b 45 0c             	mov    0xc(%ebp),%eax
80102036:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80102039:	8b 45 08             	mov    0x8(%ebp),%eax
8010203c:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80102040:	8b 45 0c             	mov    0xc(%ebp),%eax
80102043:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80102046:	8b 45 08             	mov    0x8(%ebp),%eax
80102049:	0f b7 50 56          	movzwl 0x56(%eax),%edx
8010204d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102050:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80102054:	8b 45 08             	mov    0x8(%ebp),%eax
80102057:	8b 50 58             	mov    0x58(%eax),%edx
8010205a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010205d:	89 50 10             	mov    %edx,0x10(%eax)
}
80102060:	90                   	nop
80102061:	5d                   	pop    %ebp
80102062:	c3                   	ret    

80102063 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80102063:	f3 0f 1e fb          	endbr32 
80102067:	55                   	push   %ebp
80102068:	89 e5                	mov    %esp,%ebp
8010206a:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010206d:	8b 45 08             	mov    0x8(%ebp),%eax
80102070:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102074:	66 83 f8 03          	cmp    $0x3,%ax
80102078:	75 5c                	jne    801020d6 <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
8010207a:	8b 45 08             	mov    0x8(%ebp),%eax
8010207d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102081:	66 85 c0             	test   %ax,%ax
80102084:	78 20                	js     801020a6 <readi+0x43>
80102086:	8b 45 08             	mov    0x8(%ebp),%eax
80102089:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010208d:	66 83 f8 09          	cmp    $0x9,%ax
80102091:	7f 13                	jg     801020a6 <readi+0x43>
80102093:	8b 45 08             	mov    0x8(%ebp),%eax
80102096:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010209a:	98                   	cwtl   
8010209b:	8b 04 c5 00 2a 11 80 	mov    -0x7feed600(,%eax,8),%eax
801020a2:	85 c0                	test   %eax,%eax
801020a4:	75 0a                	jne    801020b0 <readi+0x4d>
      return -1;
801020a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020ab:	e9 0a 01 00 00       	jmp    801021ba <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
801020b0:	8b 45 08             	mov    0x8(%ebp),%eax
801020b3:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020b7:	98                   	cwtl   
801020b8:	8b 04 c5 00 2a 11 80 	mov    -0x7feed600(,%eax,8),%eax
801020bf:	8b 55 14             	mov    0x14(%ebp),%edx
801020c2:	83 ec 04             	sub    $0x4,%esp
801020c5:	52                   	push   %edx
801020c6:	ff 75 0c             	pushl  0xc(%ebp)
801020c9:	ff 75 08             	pushl  0x8(%ebp)
801020cc:	ff d0                	call   *%eax
801020ce:	83 c4 10             	add    $0x10,%esp
801020d1:	e9 e4 00 00 00       	jmp    801021ba <readi+0x157>
  }

  if(off > ip->size || off + n < off)
801020d6:	8b 45 08             	mov    0x8(%ebp),%eax
801020d9:	8b 40 58             	mov    0x58(%eax),%eax
801020dc:	39 45 10             	cmp    %eax,0x10(%ebp)
801020df:	77 0d                	ja     801020ee <readi+0x8b>
801020e1:	8b 55 10             	mov    0x10(%ebp),%edx
801020e4:	8b 45 14             	mov    0x14(%ebp),%eax
801020e7:	01 d0                	add    %edx,%eax
801020e9:	39 45 10             	cmp    %eax,0x10(%ebp)
801020ec:	76 0a                	jbe    801020f8 <readi+0x95>
    return -1;
801020ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020f3:	e9 c2 00 00 00       	jmp    801021ba <readi+0x157>
  if(off + n > ip->size)
801020f8:	8b 55 10             	mov    0x10(%ebp),%edx
801020fb:	8b 45 14             	mov    0x14(%ebp),%eax
801020fe:	01 c2                	add    %eax,%edx
80102100:	8b 45 08             	mov    0x8(%ebp),%eax
80102103:	8b 40 58             	mov    0x58(%eax),%eax
80102106:	39 c2                	cmp    %eax,%edx
80102108:	76 0c                	jbe    80102116 <readi+0xb3>
    n = ip->size - off;
8010210a:	8b 45 08             	mov    0x8(%ebp),%eax
8010210d:	8b 40 58             	mov    0x58(%eax),%eax
80102110:	2b 45 10             	sub    0x10(%ebp),%eax
80102113:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102116:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010211d:	e9 89 00 00 00       	jmp    801021ab <readi+0x148>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102122:	8b 45 10             	mov    0x10(%ebp),%eax
80102125:	c1 e8 09             	shr    $0x9,%eax
80102128:	83 ec 08             	sub    $0x8,%esp
8010212b:	50                   	push   %eax
8010212c:	ff 75 08             	pushl  0x8(%ebp)
8010212f:	e8 8d fc ff ff       	call   80101dc1 <bmap>
80102134:	83 c4 10             	add    $0x10,%esp
80102137:	8b 55 08             	mov    0x8(%ebp),%edx
8010213a:	8b 12                	mov    (%edx),%edx
8010213c:	83 ec 08             	sub    $0x8,%esp
8010213f:	50                   	push   %eax
80102140:	52                   	push   %edx
80102141:	e8 91 e0 ff ff       	call   801001d7 <bread>
80102146:	83 c4 10             	add    $0x10,%esp
80102149:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010214c:	8b 45 10             	mov    0x10(%ebp),%eax
8010214f:	25 ff 01 00 00       	and    $0x1ff,%eax
80102154:	ba 00 02 00 00       	mov    $0x200,%edx
80102159:	29 c2                	sub    %eax,%edx
8010215b:	8b 45 14             	mov    0x14(%ebp),%eax
8010215e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102161:	39 c2                	cmp    %eax,%edx
80102163:	0f 46 c2             	cmovbe %edx,%eax
80102166:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102169:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010216c:	8d 50 5c             	lea    0x5c(%eax),%edx
8010216f:	8b 45 10             	mov    0x10(%ebp),%eax
80102172:	25 ff 01 00 00       	and    $0x1ff,%eax
80102177:	01 d0                	add    %edx,%eax
80102179:	83 ec 04             	sub    $0x4,%esp
8010217c:	ff 75 ec             	pushl  -0x14(%ebp)
8010217f:	50                   	push   %eax
80102180:	ff 75 0c             	pushl  0xc(%ebp)
80102183:	e8 8d 34 00 00       	call   80105615 <memmove>
80102188:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010218b:	83 ec 0c             	sub    $0xc,%esp
8010218e:	ff 75 f0             	pushl  -0x10(%ebp)
80102191:	e8 cb e0 ff ff       	call   80100261 <brelse>
80102196:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102199:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010219c:	01 45 f4             	add    %eax,-0xc(%ebp)
8010219f:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021a2:	01 45 10             	add    %eax,0x10(%ebp)
801021a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021a8:	01 45 0c             	add    %eax,0xc(%ebp)
801021ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021ae:	3b 45 14             	cmp    0x14(%ebp),%eax
801021b1:	0f 82 6b ff ff ff    	jb     80102122 <readi+0xbf>
  }
  return n;
801021b7:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021ba:	c9                   	leave  
801021bb:	c3                   	ret    

801021bc <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801021bc:	f3 0f 1e fb          	endbr32 
801021c0:	55                   	push   %ebp
801021c1:	89 e5                	mov    %esp,%ebp
801021c3:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801021c6:	8b 45 08             	mov    0x8(%ebp),%eax
801021c9:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021cd:	66 83 f8 03          	cmp    $0x3,%ax
801021d1:	75 5c                	jne    8010222f <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801021d3:	8b 45 08             	mov    0x8(%ebp),%eax
801021d6:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021da:	66 85 c0             	test   %ax,%ax
801021dd:	78 20                	js     801021ff <writei+0x43>
801021df:	8b 45 08             	mov    0x8(%ebp),%eax
801021e2:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021e6:	66 83 f8 09          	cmp    $0x9,%ax
801021ea:	7f 13                	jg     801021ff <writei+0x43>
801021ec:	8b 45 08             	mov    0x8(%ebp),%eax
801021ef:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021f3:	98                   	cwtl   
801021f4:	8b 04 c5 04 2a 11 80 	mov    -0x7feed5fc(,%eax,8),%eax
801021fb:	85 c0                	test   %eax,%eax
801021fd:	75 0a                	jne    80102209 <writei+0x4d>
      return -1;
801021ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102204:	e9 3b 01 00 00       	jmp    80102344 <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
80102209:	8b 45 08             	mov    0x8(%ebp),%eax
8010220c:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102210:	98                   	cwtl   
80102211:	8b 04 c5 04 2a 11 80 	mov    -0x7feed5fc(,%eax,8),%eax
80102218:	8b 55 14             	mov    0x14(%ebp),%edx
8010221b:	83 ec 04             	sub    $0x4,%esp
8010221e:	52                   	push   %edx
8010221f:	ff 75 0c             	pushl  0xc(%ebp)
80102222:	ff 75 08             	pushl  0x8(%ebp)
80102225:	ff d0                	call   *%eax
80102227:	83 c4 10             	add    $0x10,%esp
8010222a:	e9 15 01 00 00       	jmp    80102344 <writei+0x188>
  }

  if(off > ip->size || off + n < off)
8010222f:	8b 45 08             	mov    0x8(%ebp),%eax
80102232:	8b 40 58             	mov    0x58(%eax),%eax
80102235:	39 45 10             	cmp    %eax,0x10(%ebp)
80102238:	77 0d                	ja     80102247 <writei+0x8b>
8010223a:	8b 55 10             	mov    0x10(%ebp),%edx
8010223d:	8b 45 14             	mov    0x14(%ebp),%eax
80102240:	01 d0                	add    %edx,%eax
80102242:	39 45 10             	cmp    %eax,0x10(%ebp)
80102245:	76 0a                	jbe    80102251 <writei+0x95>
    return -1;
80102247:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010224c:	e9 f3 00 00 00       	jmp    80102344 <writei+0x188>
  if(off + n > MAXFILE*BSIZE)
80102251:	8b 55 10             	mov    0x10(%ebp),%edx
80102254:	8b 45 14             	mov    0x14(%ebp),%eax
80102257:	01 d0                	add    %edx,%eax
80102259:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010225e:	76 0a                	jbe    8010226a <writei+0xae>
    return -1;
80102260:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102265:	e9 da 00 00 00       	jmp    80102344 <writei+0x188>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010226a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102271:	e9 97 00 00 00       	jmp    8010230d <writei+0x151>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102276:	8b 45 10             	mov    0x10(%ebp),%eax
80102279:	c1 e8 09             	shr    $0x9,%eax
8010227c:	83 ec 08             	sub    $0x8,%esp
8010227f:	50                   	push   %eax
80102280:	ff 75 08             	pushl  0x8(%ebp)
80102283:	e8 39 fb ff ff       	call   80101dc1 <bmap>
80102288:	83 c4 10             	add    $0x10,%esp
8010228b:	8b 55 08             	mov    0x8(%ebp),%edx
8010228e:	8b 12                	mov    (%edx),%edx
80102290:	83 ec 08             	sub    $0x8,%esp
80102293:	50                   	push   %eax
80102294:	52                   	push   %edx
80102295:	e8 3d df ff ff       	call   801001d7 <bread>
8010229a:	83 c4 10             	add    $0x10,%esp
8010229d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801022a0:	8b 45 10             	mov    0x10(%ebp),%eax
801022a3:	25 ff 01 00 00       	and    $0x1ff,%eax
801022a8:	ba 00 02 00 00       	mov    $0x200,%edx
801022ad:	29 c2                	sub    %eax,%edx
801022af:	8b 45 14             	mov    0x14(%ebp),%eax
801022b2:	2b 45 f4             	sub    -0xc(%ebp),%eax
801022b5:	39 c2                	cmp    %eax,%edx
801022b7:	0f 46 c2             	cmovbe %edx,%eax
801022ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801022bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022c0:	8d 50 5c             	lea    0x5c(%eax),%edx
801022c3:	8b 45 10             	mov    0x10(%ebp),%eax
801022c6:	25 ff 01 00 00       	and    $0x1ff,%eax
801022cb:	01 d0                	add    %edx,%eax
801022cd:	83 ec 04             	sub    $0x4,%esp
801022d0:	ff 75 ec             	pushl  -0x14(%ebp)
801022d3:	ff 75 0c             	pushl  0xc(%ebp)
801022d6:	50                   	push   %eax
801022d7:	e8 39 33 00 00       	call   80105615 <memmove>
801022dc:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801022df:	83 ec 0c             	sub    $0xc,%esp
801022e2:	ff 75 f0             	pushl  -0x10(%ebp)
801022e5:	e8 af 16 00 00       	call   80103999 <log_write>
801022ea:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801022ed:	83 ec 0c             	sub    $0xc,%esp
801022f0:	ff 75 f0             	pushl  -0x10(%ebp)
801022f3:	e8 69 df ff ff       	call   80100261 <brelse>
801022f8:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801022fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022fe:	01 45 f4             	add    %eax,-0xc(%ebp)
80102301:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102304:	01 45 10             	add    %eax,0x10(%ebp)
80102307:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010230a:	01 45 0c             	add    %eax,0xc(%ebp)
8010230d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102310:	3b 45 14             	cmp    0x14(%ebp),%eax
80102313:	0f 82 5d ff ff ff    	jb     80102276 <writei+0xba>
  }

  if(n > 0 && off > ip->size){
80102319:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010231d:	74 22                	je     80102341 <writei+0x185>
8010231f:	8b 45 08             	mov    0x8(%ebp),%eax
80102322:	8b 40 58             	mov    0x58(%eax),%eax
80102325:	39 45 10             	cmp    %eax,0x10(%ebp)
80102328:	76 17                	jbe    80102341 <writei+0x185>
    ip->size = off;
8010232a:	8b 45 08             	mov    0x8(%ebp),%eax
8010232d:	8b 55 10             	mov    0x10(%ebp),%edx
80102330:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102333:	83 ec 0c             	sub    $0xc,%esp
80102336:	ff 75 08             	pushl  0x8(%ebp)
80102339:	e8 34 f6 ff ff       	call   80101972 <iupdate>
8010233e:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102341:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102344:	c9                   	leave  
80102345:	c3                   	ret    

80102346 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102346:	f3 0f 1e fb          	endbr32 
8010234a:	55                   	push   %ebp
8010234b:	89 e5                	mov    %esp,%ebp
8010234d:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102350:	83 ec 04             	sub    $0x4,%esp
80102353:	6a 0e                	push   $0xe
80102355:	ff 75 0c             	pushl  0xc(%ebp)
80102358:	ff 75 08             	pushl  0x8(%ebp)
8010235b:	e8 53 33 00 00       	call   801056b3 <strncmp>
80102360:	83 c4 10             	add    $0x10,%esp
}
80102363:	c9                   	leave  
80102364:	c3                   	ret    

80102365 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102365:	f3 0f 1e fb          	endbr32 
80102369:	55                   	push   %ebp
8010236a:	89 e5                	mov    %esp,%ebp
8010236c:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
8010236f:	8b 45 08             	mov    0x8(%ebp),%eax
80102372:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102376:	66 83 f8 01          	cmp    $0x1,%ax
8010237a:	74 0d                	je     80102389 <dirlookup+0x24>
    panic("dirlookup not DIR");
8010237c:	83 ec 0c             	sub    $0xc,%esp
8010237f:	68 75 93 10 80       	push   $0x80109375
80102384:	e8 7f e2 ff ff       	call   80100608 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102389:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102390:	eb 7b                	jmp    8010240d <dirlookup+0xa8>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102392:	6a 10                	push   $0x10
80102394:	ff 75 f4             	pushl  -0xc(%ebp)
80102397:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010239a:	50                   	push   %eax
8010239b:	ff 75 08             	pushl  0x8(%ebp)
8010239e:	e8 c0 fc ff ff       	call   80102063 <readi>
801023a3:	83 c4 10             	add    $0x10,%esp
801023a6:	83 f8 10             	cmp    $0x10,%eax
801023a9:	74 0d                	je     801023b8 <dirlookup+0x53>
      panic("dirlookup read");
801023ab:	83 ec 0c             	sub    $0xc,%esp
801023ae:	68 87 93 10 80       	push   $0x80109387
801023b3:	e8 50 e2 ff ff       	call   80100608 <panic>
    if(de.inum == 0)
801023b8:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023bc:	66 85 c0             	test   %ax,%ax
801023bf:	74 47                	je     80102408 <dirlookup+0xa3>
      continue;
    if(namecmp(name, de.name) == 0){
801023c1:	83 ec 08             	sub    $0x8,%esp
801023c4:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023c7:	83 c0 02             	add    $0x2,%eax
801023ca:	50                   	push   %eax
801023cb:	ff 75 0c             	pushl  0xc(%ebp)
801023ce:	e8 73 ff ff ff       	call   80102346 <namecmp>
801023d3:	83 c4 10             	add    $0x10,%esp
801023d6:	85 c0                	test   %eax,%eax
801023d8:	75 2f                	jne    80102409 <dirlookup+0xa4>
      // entry matches path element
      if(poff)
801023da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801023de:	74 08                	je     801023e8 <dirlookup+0x83>
        *poff = off;
801023e0:	8b 45 10             	mov    0x10(%ebp),%eax
801023e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801023e6:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801023e8:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023ec:	0f b7 c0             	movzwl %ax,%eax
801023ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801023f2:	8b 45 08             	mov    0x8(%ebp),%eax
801023f5:	8b 00                	mov    (%eax),%eax
801023f7:	83 ec 08             	sub    $0x8,%esp
801023fa:	ff 75 f0             	pushl  -0x10(%ebp)
801023fd:	50                   	push   %eax
801023fe:	e8 34 f6 ff ff       	call   80101a37 <iget>
80102403:	83 c4 10             	add    $0x10,%esp
80102406:	eb 19                	jmp    80102421 <dirlookup+0xbc>
      continue;
80102408:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
80102409:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010240d:	8b 45 08             	mov    0x8(%ebp),%eax
80102410:	8b 40 58             	mov    0x58(%eax),%eax
80102413:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102416:	0f 82 76 ff ff ff    	jb     80102392 <dirlookup+0x2d>
    }
  }

  return 0;
8010241c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102421:	c9                   	leave  
80102422:	c3                   	ret    

80102423 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102423:	f3 0f 1e fb          	endbr32 
80102427:	55                   	push   %ebp
80102428:	89 e5                	mov    %esp,%ebp
8010242a:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010242d:	83 ec 04             	sub    $0x4,%esp
80102430:	6a 00                	push   $0x0
80102432:	ff 75 0c             	pushl  0xc(%ebp)
80102435:	ff 75 08             	pushl  0x8(%ebp)
80102438:	e8 28 ff ff ff       	call   80102365 <dirlookup>
8010243d:	83 c4 10             	add    $0x10,%esp
80102440:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102443:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102447:	74 18                	je     80102461 <dirlink+0x3e>
    iput(ip);
80102449:	83 ec 0c             	sub    $0xc,%esp
8010244c:	ff 75 f0             	pushl  -0x10(%ebp)
8010244f:	e8 70 f8 ff ff       	call   80101cc4 <iput>
80102454:	83 c4 10             	add    $0x10,%esp
    return -1;
80102457:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010245c:	e9 9c 00 00 00       	jmp    801024fd <dirlink+0xda>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102461:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102468:	eb 39                	jmp    801024a3 <dirlink+0x80>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010246a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010246d:	6a 10                	push   $0x10
8010246f:	50                   	push   %eax
80102470:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102473:	50                   	push   %eax
80102474:	ff 75 08             	pushl  0x8(%ebp)
80102477:	e8 e7 fb ff ff       	call   80102063 <readi>
8010247c:	83 c4 10             	add    $0x10,%esp
8010247f:	83 f8 10             	cmp    $0x10,%eax
80102482:	74 0d                	je     80102491 <dirlink+0x6e>
      panic("dirlink read");
80102484:	83 ec 0c             	sub    $0xc,%esp
80102487:	68 96 93 10 80       	push   $0x80109396
8010248c:	e8 77 e1 ff ff       	call   80100608 <panic>
    if(de.inum == 0)
80102491:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102495:	66 85 c0             	test   %ax,%ax
80102498:	74 18                	je     801024b2 <dirlink+0x8f>
  for(off = 0; off < dp->size; off += sizeof(de)){
8010249a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010249d:	83 c0 10             	add    $0x10,%eax
801024a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024a3:	8b 45 08             	mov    0x8(%ebp),%eax
801024a6:	8b 50 58             	mov    0x58(%eax),%edx
801024a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024ac:	39 c2                	cmp    %eax,%edx
801024ae:	77 ba                	ja     8010246a <dirlink+0x47>
801024b0:	eb 01                	jmp    801024b3 <dirlink+0x90>
      break;
801024b2:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801024b3:	83 ec 04             	sub    $0x4,%esp
801024b6:	6a 0e                	push   $0xe
801024b8:	ff 75 0c             	pushl  0xc(%ebp)
801024bb:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024be:	83 c0 02             	add    $0x2,%eax
801024c1:	50                   	push   %eax
801024c2:	e8 46 32 00 00       	call   8010570d <strncpy>
801024c7:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801024ca:	8b 45 10             	mov    0x10(%ebp),%eax
801024cd:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801024d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024d4:	6a 10                	push   $0x10
801024d6:	50                   	push   %eax
801024d7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024da:	50                   	push   %eax
801024db:	ff 75 08             	pushl  0x8(%ebp)
801024de:	e8 d9 fc ff ff       	call   801021bc <writei>
801024e3:	83 c4 10             	add    $0x10,%esp
801024e6:	83 f8 10             	cmp    $0x10,%eax
801024e9:	74 0d                	je     801024f8 <dirlink+0xd5>
    panic("dirlink");
801024eb:	83 ec 0c             	sub    $0xc,%esp
801024ee:	68 a3 93 10 80       	push   $0x801093a3
801024f3:	e8 10 e1 ff ff       	call   80100608 <panic>

  return 0;
801024f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801024fd:	c9                   	leave  
801024fe:	c3                   	ret    

801024ff <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801024ff:	f3 0f 1e fb          	endbr32 
80102503:	55                   	push   %ebp
80102504:	89 e5                	mov    %esp,%ebp
80102506:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102509:	eb 04                	jmp    8010250f <skipelem+0x10>
    path++;
8010250b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010250f:	8b 45 08             	mov    0x8(%ebp),%eax
80102512:	0f b6 00             	movzbl (%eax),%eax
80102515:	3c 2f                	cmp    $0x2f,%al
80102517:	74 f2                	je     8010250b <skipelem+0xc>
  if(*path == 0)
80102519:	8b 45 08             	mov    0x8(%ebp),%eax
8010251c:	0f b6 00             	movzbl (%eax),%eax
8010251f:	84 c0                	test   %al,%al
80102521:	75 07                	jne    8010252a <skipelem+0x2b>
    return 0;
80102523:	b8 00 00 00 00       	mov    $0x0,%eax
80102528:	eb 77                	jmp    801025a1 <skipelem+0xa2>
  s = path;
8010252a:	8b 45 08             	mov    0x8(%ebp),%eax
8010252d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102530:	eb 04                	jmp    80102536 <skipelem+0x37>
    path++;
80102532:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102536:	8b 45 08             	mov    0x8(%ebp),%eax
80102539:	0f b6 00             	movzbl (%eax),%eax
8010253c:	3c 2f                	cmp    $0x2f,%al
8010253e:	74 0a                	je     8010254a <skipelem+0x4b>
80102540:	8b 45 08             	mov    0x8(%ebp),%eax
80102543:	0f b6 00             	movzbl (%eax),%eax
80102546:	84 c0                	test   %al,%al
80102548:	75 e8                	jne    80102532 <skipelem+0x33>
  len = path - s;
8010254a:	8b 45 08             	mov    0x8(%ebp),%eax
8010254d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102550:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102553:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102557:	7e 15                	jle    8010256e <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
80102559:	83 ec 04             	sub    $0x4,%esp
8010255c:	6a 0e                	push   $0xe
8010255e:	ff 75 f4             	pushl  -0xc(%ebp)
80102561:	ff 75 0c             	pushl  0xc(%ebp)
80102564:	e8 ac 30 00 00       	call   80105615 <memmove>
80102569:	83 c4 10             	add    $0x10,%esp
8010256c:	eb 26                	jmp    80102594 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010256e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102571:	83 ec 04             	sub    $0x4,%esp
80102574:	50                   	push   %eax
80102575:	ff 75 f4             	pushl  -0xc(%ebp)
80102578:	ff 75 0c             	pushl  0xc(%ebp)
8010257b:	e8 95 30 00 00       	call   80105615 <memmove>
80102580:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
80102583:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102586:	8b 45 0c             	mov    0xc(%ebp),%eax
80102589:	01 d0                	add    %edx,%eax
8010258b:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
8010258e:	eb 04                	jmp    80102594 <skipelem+0x95>
    path++;
80102590:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102594:	8b 45 08             	mov    0x8(%ebp),%eax
80102597:	0f b6 00             	movzbl (%eax),%eax
8010259a:	3c 2f                	cmp    $0x2f,%al
8010259c:	74 f2                	je     80102590 <skipelem+0x91>
  return path;
8010259e:	8b 45 08             	mov    0x8(%ebp),%eax
}
801025a1:	c9                   	leave  
801025a2:	c3                   	ret    

801025a3 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801025a3:	f3 0f 1e fb          	endbr32 
801025a7:	55                   	push   %ebp
801025a8:	89 e5                	mov    %esp,%ebp
801025aa:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801025ad:	8b 45 08             	mov    0x8(%ebp),%eax
801025b0:	0f b6 00             	movzbl (%eax),%eax
801025b3:	3c 2f                	cmp    $0x2f,%al
801025b5:	75 17                	jne    801025ce <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
801025b7:	83 ec 08             	sub    $0x8,%esp
801025ba:	6a 01                	push   $0x1
801025bc:	6a 01                	push   $0x1
801025be:	e8 74 f4 ff ff       	call   80101a37 <iget>
801025c3:	83 c4 10             	add    $0x10,%esp
801025c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801025c9:	e9 ba 00 00 00       	jmp    80102688 <namex+0xe5>
  else
    ip = idup(myproc()->cwd);
801025ce:	e8 3c 1f 00 00       	call   8010450f <myproc>
801025d3:	8b 40 68             	mov    0x68(%eax),%eax
801025d6:	83 ec 0c             	sub    $0xc,%esp
801025d9:	50                   	push   %eax
801025da:	e8 3e f5 ff ff       	call   80101b1d <idup>
801025df:	83 c4 10             	add    $0x10,%esp
801025e2:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801025e5:	e9 9e 00 00 00       	jmp    80102688 <namex+0xe5>
    ilock(ip);
801025ea:	83 ec 0c             	sub    $0xc,%esp
801025ed:	ff 75 f4             	pushl  -0xc(%ebp)
801025f0:	e8 66 f5 ff ff       	call   80101b5b <ilock>
801025f5:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
801025f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025fb:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801025ff:	66 83 f8 01          	cmp    $0x1,%ax
80102603:	74 18                	je     8010261d <namex+0x7a>
      iunlockput(ip);
80102605:	83 ec 0c             	sub    $0xc,%esp
80102608:	ff 75 f4             	pushl  -0xc(%ebp)
8010260b:	e8 88 f7 ff ff       	call   80101d98 <iunlockput>
80102610:	83 c4 10             	add    $0x10,%esp
      return 0;
80102613:	b8 00 00 00 00       	mov    $0x0,%eax
80102618:	e9 a7 00 00 00       	jmp    801026c4 <namex+0x121>
    }
    if(nameiparent && *path == '\0'){
8010261d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102621:	74 20                	je     80102643 <namex+0xa0>
80102623:	8b 45 08             	mov    0x8(%ebp),%eax
80102626:	0f b6 00             	movzbl (%eax),%eax
80102629:	84 c0                	test   %al,%al
8010262b:	75 16                	jne    80102643 <namex+0xa0>
      // Stop one level early.
      iunlock(ip);
8010262d:	83 ec 0c             	sub    $0xc,%esp
80102630:	ff 75 f4             	pushl  -0xc(%ebp)
80102633:	e8 3a f6 ff ff       	call   80101c72 <iunlock>
80102638:	83 c4 10             	add    $0x10,%esp
      return ip;
8010263b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010263e:	e9 81 00 00 00       	jmp    801026c4 <namex+0x121>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102643:	83 ec 04             	sub    $0x4,%esp
80102646:	6a 00                	push   $0x0
80102648:	ff 75 10             	pushl  0x10(%ebp)
8010264b:	ff 75 f4             	pushl  -0xc(%ebp)
8010264e:	e8 12 fd ff ff       	call   80102365 <dirlookup>
80102653:	83 c4 10             	add    $0x10,%esp
80102656:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102659:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010265d:	75 15                	jne    80102674 <namex+0xd1>
      iunlockput(ip);
8010265f:	83 ec 0c             	sub    $0xc,%esp
80102662:	ff 75 f4             	pushl  -0xc(%ebp)
80102665:	e8 2e f7 ff ff       	call   80101d98 <iunlockput>
8010266a:	83 c4 10             	add    $0x10,%esp
      return 0;
8010266d:	b8 00 00 00 00       	mov    $0x0,%eax
80102672:	eb 50                	jmp    801026c4 <namex+0x121>
    }
    iunlockput(ip);
80102674:	83 ec 0c             	sub    $0xc,%esp
80102677:	ff 75 f4             	pushl  -0xc(%ebp)
8010267a:	e8 19 f7 ff ff       	call   80101d98 <iunlockput>
8010267f:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102682:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102685:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
80102688:	83 ec 08             	sub    $0x8,%esp
8010268b:	ff 75 10             	pushl  0x10(%ebp)
8010268e:	ff 75 08             	pushl  0x8(%ebp)
80102691:	e8 69 fe ff ff       	call   801024ff <skipelem>
80102696:	83 c4 10             	add    $0x10,%esp
80102699:	89 45 08             	mov    %eax,0x8(%ebp)
8010269c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026a0:	0f 85 44 ff ff ff    	jne    801025ea <namex+0x47>
  }
  if(nameiparent){
801026a6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801026aa:	74 15                	je     801026c1 <namex+0x11e>
    iput(ip);
801026ac:	83 ec 0c             	sub    $0xc,%esp
801026af:	ff 75 f4             	pushl  -0xc(%ebp)
801026b2:	e8 0d f6 ff ff       	call   80101cc4 <iput>
801026b7:	83 c4 10             	add    $0x10,%esp
    return 0;
801026ba:	b8 00 00 00 00       	mov    $0x0,%eax
801026bf:	eb 03                	jmp    801026c4 <namex+0x121>
  }
  return ip;
801026c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801026c4:	c9                   	leave  
801026c5:	c3                   	ret    

801026c6 <namei>:

struct inode*
namei(char *path)
{
801026c6:	f3 0f 1e fb          	endbr32 
801026ca:	55                   	push   %ebp
801026cb:	89 e5                	mov    %esp,%ebp
801026cd:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801026d0:	83 ec 04             	sub    $0x4,%esp
801026d3:	8d 45 ea             	lea    -0x16(%ebp),%eax
801026d6:	50                   	push   %eax
801026d7:	6a 00                	push   $0x0
801026d9:	ff 75 08             	pushl  0x8(%ebp)
801026dc:	e8 c2 fe ff ff       	call   801025a3 <namex>
801026e1:	83 c4 10             	add    $0x10,%esp
}
801026e4:	c9                   	leave  
801026e5:	c3                   	ret    

801026e6 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801026e6:	f3 0f 1e fb          	endbr32 
801026ea:	55                   	push   %ebp
801026eb:	89 e5                	mov    %esp,%ebp
801026ed:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
801026f0:	83 ec 04             	sub    $0x4,%esp
801026f3:	ff 75 0c             	pushl  0xc(%ebp)
801026f6:	6a 01                	push   $0x1
801026f8:	ff 75 08             	pushl  0x8(%ebp)
801026fb:	e8 a3 fe ff ff       	call   801025a3 <namex>
80102700:	83 c4 10             	add    $0x10,%esp
}
80102703:	c9                   	leave  
80102704:	c3                   	ret    

80102705 <inb>:
{
80102705:	55                   	push   %ebp
80102706:	89 e5                	mov    %esp,%ebp
80102708:	83 ec 14             	sub    $0x14,%esp
8010270b:	8b 45 08             	mov    0x8(%ebp),%eax
8010270e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102712:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102716:	89 c2                	mov    %eax,%edx
80102718:	ec                   	in     (%dx),%al
80102719:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010271c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102720:	c9                   	leave  
80102721:	c3                   	ret    

80102722 <insl>:
{
80102722:	55                   	push   %ebp
80102723:	89 e5                	mov    %esp,%ebp
80102725:	57                   	push   %edi
80102726:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102727:	8b 55 08             	mov    0x8(%ebp),%edx
8010272a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010272d:	8b 45 10             	mov    0x10(%ebp),%eax
80102730:	89 cb                	mov    %ecx,%ebx
80102732:	89 df                	mov    %ebx,%edi
80102734:	89 c1                	mov    %eax,%ecx
80102736:	fc                   	cld    
80102737:	f3 6d                	rep insl (%dx),%es:(%edi)
80102739:	89 c8                	mov    %ecx,%eax
8010273b:	89 fb                	mov    %edi,%ebx
8010273d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102740:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102743:	90                   	nop
80102744:	5b                   	pop    %ebx
80102745:	5f                   	pop    %edi
80102746:	5d                   	pop    %ebp
80102747:	c3                   	ret    

80102748 <outb>:
{
80102748:	55                   	push   %ebp
80102749:	89 e5                	mov    %esp,%ebp
8010274b:	83 ec 08             	sub    $0x8,%esp
8010274e:	8b 45 08             	mov    0x8(%ebp),%eax
80102751:	8b 55 0c             	mov    0xc(%ebp),%edx
80102754:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102758:	89 d0                	mov    %edx,%eax
8010275a:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010275d:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102761:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102765:	ee                   	out    %al,(%dx)
}
80102766:	90                   	nop
80102767:	c9                   	leave  
80102768:	c3                   	ret    

80102769 <outsl>:
{
80102769:	55                   	push   %ebp
8010276a:	89 e5                	mov    %esp,%ebp
8010276c:	56                   	push   %esi
8010276d:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010276e:	8b 55 08             	mov    0x8(%ebp),%edx
80102771:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102774:	8b 45 10             	mov    0x10(%ebp),%eax
80102777:	89 cb                	mov    %ecx,%ebx
80102779:	89 de                	mov    %ebx,%esi
8010277b:	89 c1                	mov    %eax,%ecx
8010277d:	fc                   	cld    
8010277e:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102780:	89 c8                	mov    %ecx,%eax
80102782:	89 f3                	mov    %esi,%ebx
80102784:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102787:	89 45 10             	mov    %eax,0x10(%ebp)
}
8010278a:	90                   	nop
8010278b:	5b                   	pop    %ebx
8010278c:	5e                   	pop    %esi
8010278d:	5d                   	pop    %ebp
8010278e:	c3                   	ret    

8010278f <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010278f:	f3 0f 1e fb          	endbr32 
80102793:	55                   	push   %ebp
80102794:	89 e5                	mov    %esp,%ebp
80102796:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102799:	90                   	nop
8010279a:	68 f7 01 00 00       	push   $0x1f7
8010279f:	e8 61 ff ff ff       	call   80102705 <inb>
801027a4:	83 c4 04             	add    $0x4,%esp
801027a7:	0f b6 c0             	movzbl %al,%eax
801027aa:	89 45 fc             	mov    %eax,-0x4(%ebp)
801027ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
801027b0:	25 c0 00 00 00       	and    $0xc0,%eax
801027b5:	83 f8 40             	cmp    $0x40,%eax
801027b8:	75 e0                	jne    8010279a <idewait+0xb>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801027ba:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801027be:	74 11                	je     801027d1 <idewait+0x42>
801027c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801027c3:	83 e0 21             	and    $0x21,%eax
801027c6:	85 c0                	test   %eax,%eax
801027c8:	74 07                	je     801027d1 <idewait+0x42>
    return -1;
801027ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801027cf:	eb 05                	jmp    801027d6 <idewait+0x47>
  return 0;
801027d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801027d6:	c9                   	leave  
801027d7:	c3                   	ret    

801027d8 <ideinit>:

void
ideinit(void)
{
801027d8:	f3 0f 1e fb          	endbr32 
801027dc:	55                   	push   %ebp
801027dd:	89 e5                	mov    %esp,%ebp
801027df:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
801027e2:	83 ec 08             	sub    $0x8,%esp
801027e5:	68 ab 93 10 80       	push   $0x801093ab
801027ea:	68 00 c6 10 80       	push   $0x8010c600
801027ef:	e8 95 2a 00 00       	call   80105289 <initlock>
801027f4:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801027f7:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
801027fc:	83 e8 01             	sub    $0x1,%eax
801027ff:	83 ec 08             	sub    $0x8,%esp
80102802:	50                   	push   %eax
80102803:	6a 0e                	push   $0xe
80102805:	e8 bb 04 00 00       	call   80102cc5 <ioapicenable>
8010280a:	83 c4 10             	add    $0x10,%esp
  idewait(0);
8010280d:	83 ec 0c             	sub    $0xc,%esp
80102810:	6a 00                	push   $0x0
80102812:	e8 78 ff ff ff       	call   8010278f <idewait>
80102817:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010281a:	83 ec 08             	sub    $0x8,%esp
8010281d:	68 f0 00 00 00       	push   $0xf0
80102822:	68 f6 01 00 00       	push   $0x1f6
80102827:	e8 1c ff ff ff       	call   80102748 <outb>
8010282c:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
8010282f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102836:	eb 24                	jmp    8010285c <ideinit+0x84>
    if(inb(0x1f7) != 0){
80102838:	83 ec 0c             	sub    $0xc,%esp
8010283b:	68 f7 01 00 00       	push   $0x1f7
80102840:	e8 c0 fe ff ff       	call   80102705 <inb>
80102845:	83 c4 10             	add    $0x10,%esp
80102848:	84 c0                	test   %al,%al
8010284a:	74 0c                	je     80102858 <ideinit+0x80>
      havedisk1 = 1;
8010284c:	c7 05 38 c6 10 80 01 	movl   $0x1,0x8010c638
80102853:	00 00 00 
      break;
80102856:	eb 0d                	jmp    80102865 <ideinit+0x8d>
  for(i=0; i<1000; i++){
80102858:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010285c:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102863:	7e d3                	jle    80102838 <ideinit+0x60>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102865:	83 ec 08             	sub    $0x8,%esp
80102868:	68 e0 00 00 00       	push   $0xe0
8010286d:	68 f6 01 00 00       	push   $0x1f6
80102872:	e8 d1 fe ff ff       	call   80102748 <outb>
80102877:	83 c4 10             	add    $0x10,%esp
}
8010287a:	90                   	nop
8010287b:	c9                   	leave  
8010287c:	c3                   	ret    

8010287d <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
8010287d:	f3 0f 1e fb          	endbr32 
80102881:	55                   	push   %ebp
80102882:	89 e5                	mov    %esp,%ebp
80102884:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102887:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010288b:	75 0d                	jne    8010289a <idestart+0x1d>
    panic("idestart");
8010288d:	83 ec 0c             	sub    $0xc,%esp
80102890:	68 af 93 10 80       	push   $0x801093af
80102895:	e8 6e dd ff ff       	call   80100608 <panic>
  if(b->blockno >= FSSIZE)
8010289a:	8b 45 08             	mov    0x8(%ebp),%eax
8010289d:	8b 40 08             	mov    0x8(%eax),%eax
801028a0:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801028a5:	76 0d                	jbe    801028b4 <idestart+0x37>
    panic("incorrect blockno");
801028a7:	83 ec 0c             	sub    $0xc,%esp
801028aa:	68 b8 93 10 80       	push   $0x801093b8
801028af:	e8 54 dd ff ff       	call   80100608 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801028b4:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801028bb:	8b 45 08             	mov    0x8(%ebp),%eax
801028be:	8b 50 08             	mov    0x8(%eax),%edx
801028c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c4:	0f af c2             	imul   %edx,%eax
801028c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
801028ca:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801028ce:	75 07                	jne    801028d7 <idestart+0x5a>
801028d0:	b8 20 00 00 00       	mov    $0x20,%eax
801028d5:	eb 05                	jmp    801028dc <idestart+0x5f>
801028d7:	b8 c4 00 00 00       	mov    $0xc4,%eax
801028dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
801028df:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801028e3:	75 07                	jne    801028ec <idestart+0x6f>
801028e5:	b8 30 00 00 00       	mov    $0x30,%eax
801028ea:	eb 05                	jmp    801028f1 <idestart+0x74>
801028ec:	b8 c5 00 00 00       	mov    $0xc5,%eax
801028f1:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
801028f4:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801028f8:	7e 0d                	jle    80102907 <idestart+0x8a>
801028fa:	83 ec 0c             	sub    $0xc,%esp
801028fd:	68 af 93 10 80       	push   $0x801093af
80102902:	e8 01 dd ff ff       	call   80100608 <panic>

  idewait(0);
80102907:	83 ec 0c             	sub    $0xc,%esp
8010290a:	6a 00                	push   $0x0
8010290c:	e8 7e fe ff ff       	call   8010278f <idewait>
80102911:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102914:	83 ec 08             	sub    $0x8,%esp
80102917:	6a 00                	push   $0x0
80102919:	68 f6 03 00 00       	push   $0x3f6
8010291e:	e8 25 fe ff ff       	call   80102748 <outb>
80102923:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102926:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102929:	0f b6 c0             	movzbl %al,%eax
8010292c:	83 ec 08             	sub    $0x8,%esp
8010292f:	50                   	push   %eax
80102930:	68 f2 01 00 00       	push   $0x1f2
80102935:	e8 0e fe ff ff       	call   80102748 <outb>
8010293a:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
8010293d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102940:	0f b6 c0             	movzbl %al,%eax
80102943:	83 ec 08             	sub    $0x8,%esp
80102946:	50                   	push   %eax
80102947:	68 f3 01 00 00       	push   $0x1f3
8010294c:	e8 f7 fd ff ff       	call   80102748 <outb>
80102951:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102954:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102957:	c1 f8 08             	sar    $0x8,%eax
8010295a:	0f b6 c0             	movzbl %al,%eax
8010295d:	83 ec 08             	sub    $0x8,%esp
80102960:	50                   	push   %eax
80102961:	68 f4 01 00 00       	push   $0x1f4
80102966:	e8 dd fd ff ff       	call   80102748 <outb>
8010296b:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
8010296e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102971:	c1 f8 10             	sar    $0x10,%eax
80102974:	0f b6 c0             	movzbl %al,%eax
80102977:	83 ec 08             	sub    $0x8,%esp
8010297a:	50                   	push   %eax
8010297b:	68 f5 01 00 00       	push   $0x1f5
80102980:	e8 c3 fd ff ff       	call   80102748 <outb>
80102985:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102988:	8b 45 08             	mov    0x8(%ebp),%eax
8010298b:	8b 40 04             	mov    0x4(%eax),%eax
8010298e:	c1 e0 04             	shl    $0x4,%eax
80102991:	83 e0 10             	and    $0x10,%eax
80102994:	89 c2                	mov    %eax,%edx
80102996:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102999:	c1 f8 18             	sar    $0x18,%eax
8010299c:	83 e0 0f             	and    $0xf,%eax
8010299f:	09 d0                	or     %edx,%eax
801029a1:	83 c8 e0             	or     $0xffffffe0,%eax
801029a4:	0f b6 c0             	movzbl %al,%eax
801029a7:	83 ec 08             	sub    $0x8,%esp
801029aa:	50                   	push   %eax
801029ab:	68 f6 01 00 00       	push   $0x1f6
801029b0:	e8 93 fd ff ff       	call   80102748 <outb>
801029b5:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801029b8:	8b 45 08             	mov    0x8(%ebp),%eax
801029bb:	8b 00                	mov    (%eax),%eax
801029bd:	83 e0 04             	and    $0x4,%eax
801029c0:	85 c0                	test   %eax,%eax
801029c2:	74 35                	je     801029f9 <idestart+0x17c>
    outb(0x1f7, write_cmd);
801029c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801029c7:	0f b6 c0             	movzbl %al,%eax
801029ca:	83 ec 08             	sub    $0x8,%esp
801029cd:	50                   	push   %eax
801029ce:	68 f7 01 00 00       	push   $0x1f7
801029d3:	e8 70 fd ff ff       	call   80102748 <outb>
801029d8:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
801029db:	8b 45 08             	mov    0x8(%ebp),%eax
801029de:	83 c0 5c             	add    $0x5c,%eax
801029e1:	83 ec 04             	sub    $0x4,%esp
801029e4:	68 80 00 00 00       	push   $0x80
801029e9:	50                   	push   %eax
801029ea:	68 f0 01 00 00       	push   $0x1f0
801029ef:	e8 75 fd ff ff       	call   80102769 <outsl>
801029f4:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
801029f7:	eb 17                	jmp    80102a10 <idestart+0x193>
    outb(0x1f7, read_cmd);
801029f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801029fc:	0f b6 c0             	movzbl %al,%eax
801029ff:	83 ec 08             	sub    $0x8,%esp
80102a02:	50                   	push   %eax
80102a03:	68 f7 01 00 00       	push   $0x1f7
80102a08:	e8 3b fd ff ff       	call   80102748 <outb>
80102a0d:	83 c4 10             	add    $0x10,%esp
}
80102a10:	90                   	nop
80102a11:	c9                   	leave  
80102a12:	c3                   	ret    

80102a13 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102a13:	f3 0f 1e fb          	endbr32 
80102a17:	55                   	push   %ebp
80102a18:	89 e5                	mov    %esp,%ebp
80102a1a:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102a1d:	83 ec 0c             	sub    $0xc,%esp
80102a20:	68 00 c6 10 80       	push   $0x8010c600
80102a25:	e8 85 28 00 00       	call   801052af <acquire>
80102a2a:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
80102a2d:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102a32:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a35:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102a39:	75 15                	jne    80102a50 <ideintr+0x3d>
    release(&idelock);
80102a3b:	83 ec 0c             	sub    $0xc,%esp
80102a3e:	68 00 c6 10 80       	push   $0x8010c600
80102a43:	e8 d9 28 00 00       	call   80105321 <release>
80102a48:	83 c4 10             	add    $0x10,%esp
    return;
80102a4b:	e9 9a 00 00 00       	jmp    80102aea <ideintr+0xd7>
  }
  idequeue = b->qnext;
80102a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a53:	8b 40 58             	mov    0x58(%eax),%eax
80102a56:	a3 34 c6 10 80       	mov    %eax,0x8010c634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a5e:	8b 00                	mov    (%eax),%eax
80102a60:	83 e0 04             	and    $0x4,%eax
80102a63:	85 c0                	test   %eax,%eax
80102a65:	75 2d                	jne    80102a94 <ideintr+0x81>
80102a67:	83 ec 0c             	sub    $0xc,%esp
80102a6a:	6a 01                	push   $0x1
80102a6c:	e8 1e fd ff ff       	call   8010278f <idewait>
80102a71:	83 c4 10             	add    $0x10,%esp
80102a74:	85 c0                	test   %eax,%eax
80102a76:	78 1c                	js     80102a94 <ideintr+0x81>
    insl(0x1f0, b->data, BSIZE/4);
80102a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a7b:	83 c0 5c             	add    $0x5c,%eax
80102a7e:	83 ec 04             	sub    $0x4,%esp
80102a81:	68 80 00 00 00       	push   $0x80
80102a86:	50                   	push   %eax
80102a87:	68 f0 01 00 00       	push   $0x1f0
80102a8c:	e8 91 fc ff ff       	call   80102722 <insl>
80102a91:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a97:	8b 00                	mov    (%eax),%eax
80102a99:	83 c8 02             	or     $0x2,%eax
80102a9c:	89 c2                	mov    %eax,%edx
80102a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aa1:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aa6:	8b 00                	mov    (%eax),%eax
80102aa8:	83 e0 fb             	and    $0xfffffffb,%eax
80102aab:	89 c2                	mov    %eax,%edx
80102aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab0:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102ab2:	83 ec 0c             	sub    $0xc,%esp
80102ab5:	ff 75 f4             	pushl  -0xc(%ebp)
80102ab8:	e8 72 24 00 00       	call   80104f2f <wakeup>
80102abd:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102ac0:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102ac5:	85 c0                	test   %eax,%eax
80102ac7:	74 11                	je     80102ada <ideintr+0xc7>
    idestart(idequeue);
80102ac9:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102ace:	83 ec 0c             	sub    $0xc,%esp
80102ad1:	50                   	push   %eax
80102ad2:	e8 a6 fd ff ff       	call   8010287d <idestart>
80102ad7:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102ada:	83 ec 0c             	sub    $0xc,%esp
80102add:	68 00 c6 10 80       	push   $0x8010c600
80102ae2:	e8 3a 28 00 00       	call   80105321 <release>
80102ae7:	83 c4 10             	add    $0x10,%esp
}
80102aea:	c9                   	leave  
80102aeb:	c3                   	ret    

80102aec <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102aec:	f3 0f 1e fb          	endbr32 
80102af0:	55                   	push   %ebp
80102af1:	89 e5                	mov    %esp,%ebp
80102af3:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102af6:	8b 45 08             	mov    0x8(%ebp),%eax
80102af9:	83 c0 0c             	add    $0xc,%eax
80102afc:	83 ec 0c             	sub    $0xc,%esp
80102aff:	50                   	push   %eax
80102b00:	e8 eb 26 00 00       	call   801051f0 <holdingsleep>
80102b05:	83 c4 10             	add    $0x10,%esp
80102b08:	85 c0                	test   %eax,%eax
80102b0a:	75 0d                	jne    80102b19 <iderw+0x2d>
    panic("iderw: buf not locked");
80102b0c:	83 ec 0c             	sub    $0xc,%esp
80102b0f:	68 ca 93 10 80       	push   $0x801093ca
80102b14:	e8 ef da ff ff       	call   80100608 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102b19:	8b 45 08             	mov    0x8(%ebp),%eax
80102b1c:	8b 00                	mov    (%eax),%eax
80102b1e:	83 e0 06             	and    $0x6,%eax
80102b21:	83 f8 02             	cmp    $0x2,%eax
80102b24:	75 0d                	jne    80102b33 <iderw+0x47>
    panic("iderw: nothing to do");
80102b26:	83 ec 0c             	sub    $0xc,%esp
80102b29:	68 e0 93 10 80       	push   $0x801093e0
80102b2e:	e8 d5 da ff ff       	call   80100608 <panic>
  if(b->dev != 0 && !havedisk1)
80102b33:	8b 45 08             	mov    0x8(%ebp),%eax
80102b36:	8b 40 04             	mov    0x4(%eax),%eax
80102b39:	85 c0                	test   %eax,%eax
80102b3b:	74 16                	je     80102b53 <iderw+0x67>
80102b3d:	a1 38 c6 10 80       	mov    0x8010c638,%eax
80102b42:	85 c0                	test   %eax,%eax
80102b44:	75 0d                	jne    80102b53 <iderw+0x67>
    panic("iderw: ide disk 1 not present");
80102b46:	83 ec 0c             	sub    $0xc,%esp
80102b49:	68 f5 93 10 80       	push   $0x801093f5
80102b4e:	e8 b5 da ff ff       	call   80100608 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102b53:	83 ec 0c             	sub    $0xc,%esp
80102b56:	68 00 c6 10 80       	push   $0x8010c600
80102b5b:	e8 4f 27 00 00       	call   801052af <acquire>
80102b60:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102b63:	8b 45 08             	mov    0x8(%ebp),%eax
80102b66:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102b6d:	c7 45 f4 34 c6 10 80 	movl   $0x8010c634,-0xc(%ebp)
80102b74:	eb 0b                	jmp    80102b81 <iderw+0x95>
80102b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b79:	8b 00                	mov    (%eax),%eax
80102b7b:	83 c0 58             	add    $0x58,%eax
80102b7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b84:	8b 00                	mov    (%eax),%eax
80102b86:	85 c0                	test   %eax,%eax
80102b88:	75 ec                	jne    80102b76 <iderw+0x8a>
    ;
  *pp = b;
80102b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b8d:	8b 55 08             	mov    0x8(%ebp),%edx
80102b90:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102b92:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102b97:	39 45 08             	cmp    %eax,0x8(%ebp)
80102b9a:	75 23                	jne    80102bbf <iderw+0xd3>
    idestart(b);
80102b9c:	83 ec 0c             	sub    $0xc,%esp
80102b9f:	ff 75 08             	pushl  0x8(%ebp)
80102ba2:	e8 d6 fc ff ff       	call   8010287d <idestart>
80102ba7:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102baa:	eb 13                	jmp    80102bbf <iderw+0xd3>
    sleep(b, &idelock);
80102bac:	83 ec 08             	sub    $0x8,%esp
80102baf:	68 00 c6 10 80       	push   $0x8010c600
80102bb4:	ff 75 08             	pushl  0x8(%ebp)
80102bb7:	e8 81 22 00 00       	call   80104e3d <sleep>
80102bbc:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102bbf:	8b 45 08             	mov    0x8(%ebp),%eax
80102bc2:	8b 00                	mov    (%eax),%eax
80102bc4:	83 e0 06             	and    $0x6,%eax
80102bc7:	83 f8 02             	cmp    $0x2,%eax
80102bca:	75 e0                	jne    80102bac <iderw+0xc0>
  }


  release(&idelock);
80102bcc:	83 ec 0c             	sub    $0xc,%esp
80102bcf:	68 00 c6 10 80       	push   $0x8010c600
80102bd4:	e8 48 27 00 00       	call   80105321 <release>
80102bd9:	83 c4 10             	add    $0x10,%esp
}
80102bdc:	90                   	nop
80102bdd:	c9                   	leave  
80102bde:	c3                   	ret    

80102bdf <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102bdf:	f3 0f 1e fb          	endbr32 
80102be3:	55                   	push   %ebp
80102be4:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102be6:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102beb:	8b 55 08             	mov    0x8(%ebp),%edx
80102bee:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102bf0:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102bf5:	8b 40 10             	mov    0x10(%eax),%eax
}
80102bf8:	5d                   	pop    %ebp
80102bf9:	c3                   	ret    

80102bfa <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102bfa:	f3 0f 1e fb          	endbr32 
80102bfe:	55                   	push   %ebp
80102bff:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102c01:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102c06:	8b 55 08             	mov    0x8(%ebp),%edx
80102c09:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102c0b:	a1 d4 46 11 80       	mov    0x801146d4,%eax
80102c10:	8b 55 0c             	mov    0xc(%ebp),%edx
80102c13:	89 50 10             	mov    %edx,0x10(%eax)
}
80102c16:	90                   	nop
80102c17:	5d                   	pop    %ebp
80102c18:	c3                   	ret    

80102c19 <ioapicinit>:

void
ioapicinit(void)
{
80102c19:	f3 0f 1e fb          	endbr32 
80102c1d:	55                   	push   %ebp
80102c1e:	89 e5                	mov    %esp,%ebp
80102c20:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102c23:	c7 05 d4 46 11 80 00 	movl   $0xfec00000,0x801146d4
80102c2a:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102c2d:	6a 01                	push   $0x1
80102c2f:	e8 ab ff ff ff       	call   80102bdf <ioapicread>
80102c34:	83 c4 04             	add    $0x4,%esp
80102c37:	c1 e8 10             	shr    $0x10,%eax
80102c3a:	25 ff 00 00 00       	and    $0xff,%eax
80102c3f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102c42:	6a 00                	push   $0x0
80102c44:	e8 96 ff ff ff       	call   80102bdf <ioapicread>
80102c49:	83 c4 04             	add    $0x4,%esp
80102c4c:	c1 e8 18             	shr    $0x18,%eax
80102c4f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102c52:	0f b6 05 00 48 11 80 	movzbl 0x80114800,%eax
80102c59:	0f b6 c0             	movzbl %al,%eax
80102c5c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102c5f:	74 10                	je     80102c71 <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102c61:	83 ec 0c             	sub    $0xc,%esp
80102c64:	68 14 94 10 80       	push   $0x80109414
80102c69:	e8 aa d7 ff ff       	call   80100418 <cprintf>
80102c6e:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c71:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c78:	eb 3f                	jmp    80102cb9 <ioapicinit+0xa0>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c7d:	83 c0 20             	add    $0x20,%eax
80102c80:	0d 00 00 01 00       	or     $0x10000,%eax
80102c85:	89 c2                	mov    %eax,%edx
80102c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c8a:	83 c0 08             	add    $0x8,%eax
80102c8d:	01 c0                	add    %eax,%eax
80102c8f:	83 ec 08             	sub    $0x8,%esp
80102c92:	52                   	push   %edx
80102c93:	50                   	push   %eax
80102c94:	e8 61 ff ff ff       	call   80102bfa <ioapicwrite>
80102c99:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102c9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c9f:	83 c0 08             	add    $0x8,%eax
80102ca2:	01 c0                	add    %eax,%eax
80102ca4:	83 c0 01             	add    $0x1,%eax
80102ca7:	83 ec 08             	sub    $0x8,%esp
80102caa:	6a 00                	push   $0x0
80102cac:	50                   	push   %eax
80102cad:	e8 48 ff ff ff       	call   80102bfa <ioapicwrite>
80102cb2:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102cb5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cbc:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102cbf:	7e b9                	jle    80102c7a <ioapicinit+0x61>
  }
}
80102cc1:	90                   	nop
80102cc2:	90                   	nop
80102cc3:	c9                   	leave  
80102cc4:	c3                   	ret    

80102cc5 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102cc5:	f3 0f 1e fb          	endbr32 
80102cc9:	55                   	push   %ebp
80102cca:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102ccc:	8b 45 08             	mov    0x8(%ebp),%eax
80102ccf:	83 c0 20             	add    $0x20,%eax
80102cd2:	89 c2                	mov    %eax,%edx
80102cd4:	8b 45 08             	mov    0x8(%ebp),%eax
80102cd7:	83 c0 08             	add    $0x8,%eax
80102cda:	01 c0                	add    %eax,%eax
80102cdc:	52                   	push   %edx
80102cdd:	50                   	push   %eax
80102cde:	e8 17 ff ff ff       	call   80102bfa <ioapicwrite>
80102ce3:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102ce6:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ce9:	c1 e0 18             	shl    $0x18,%eax
80102cec:	89 c2                	mov    %eax,%edx
80102cee:	8b 45 08             	mov    0x8(%ebp),%eax
80102cf1:	83 c0 08             	add    $0x8,%eax
80102cf4:	01 c0                	add    %eax,%eax
80102cf6:	83 c0 01             	add    $0x1,%eax
80102cf9:	52                   	push   %edx
80102cfa:	50                   	push   %eax
80102cfb:	e8 fa fe ff ff       	call   80102bfa <ioapicwrite>
80102d00:	83 c4 08             	add    $0x8,%esp
}
80102d03:	90                   	nop
80102d04:	c9                   	leave  
80102d05:	c3                   	ret    

80102d06 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102d06:	f3 0f 1e fb          	endbr32 
80102d0a:	55                   	push   %ebp
80102d0b:	89 e5                	mov    %esp,%ebp
80102d0d:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102d10:	83 ec 08             	sub    $0x8,%esp
80102d13:	68 48 94 10 80       	push   $0x80109448
80102d18:	68 e0 46 11 80       	push   $0x801146e0
80102d1d:	e8 67 25 00 00       	call   80105289 <initlock>
80102d22:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102d25:	c7 05 14 47 11 80 00 	movl   $0x0,0x80114714
80102d2c:	00 00 00 
  freerange(vstart, vend);
80102d2f:	83 ec 08             	sub    $0x8,%esp
80102d32:	ff 75 0c             	pushl  0xc(%ebp)
80102d35:	ff 75 08             	pushl  0x8(%ebp)
80102d38:	e8 2e 00 00 00       	call   80102d6b <freerange>
80102d3d:	83 c4 10             	add    $0x10,%esp
}
80102d40:	90                   	nop
80102d41:	c9                   	leave  
80102d42:	c3                   	ret    

80102d43 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102d43:	f3 0f 1e fb          	endbr32 
80102d47:	55                   	push   %ebp
80102d48:	89 e5                	mov    %esp,%ebp
80102d4a:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102d4d:	83 ec 08             	sub    $0x8,%esp
80102d50:	ff 75 0c             	pushl  0xc(%ebp)
80102d53:	ff 75 08             	pushl  0x8(%ebp)
80102d56:	e8 10 00 00 00       	call   80102d6b <freerange>
80102d5b:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102d5e:	c7 05 14 47 11 80 01 	movl   $0x1,0x80114714
80102d65:	00 00 00 
}
80102d68:	90                   	nop
80102d69:	c9                   	leave  
80102d6a:	c3                   	ret    

80102d6b <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d6b:	f3 0f 1e fb          	endbr32 
80102d6f:	55                   	push   %ebp
80102d70:	89 e5                	mov    %esp,%ebp
80102d72:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102d75:	8b 45 08             	mov    0x8(%ebp),%eax
80102d78:	05 ff 0f 00 00       	add    $0xfff,%eax
80102d7d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102d82:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d85:	eb 15                	jmp    80102d9c <freerange+0x31>
    kfree(p);
80102d87:	83 ec 0c             	sub    $0xc,%esp
80102d8a:	ff 75 f4             	pushl  -0xc(%ebp)
80102d8d:	e8 1b 00 00 00       	call   80102dad <kfree>
80102d92:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d95:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d9f:	05 00 10 00 00       	add    $0x1000,%eax
80102da4:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102da7:	73 de                	jae    80102d87 <freerange+0x1c>
}
80102da9:	90                   	nop
80102daa:	90                   	nop
80102dab:	c9                   	leave  
80102dac:	c3                   	ret    

80102dad <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102dad:	f3 0f 1e fb          	endbr32 
80102db1:	55                   	push   %ebp
80102db2:	89 e5                	mov    %esp,%ebp
80102db4:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102db7:	8b 45 08             	mov    0x8(%ebp),%eax
80102dba:	25 ff 0f 00 00       	and    $0xfff,%eax
80102dbf:	85 c0                	test   %eax,%eax
80102dc1:	75 18                	jne    80102ddb <kfree+0x2e>
80102dc3:	81 7d 08 48 7f 11 80 	cmpl   $0x80117f48,0x8(%ebp)
80102dca:	72 0f                	jb     80102ddb <kfree+0x2e>
80102dcc:	8b 45 08             	mov    0x8(%ebp),%eax
80102dcf:	05 00 00 00 80       	add    $0x80000000,%eax
80102dd4:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102dd9:	76 0d                	jbe    80102de8 <kfree+0x3b>
    panic("kfree");
80102ddb:	83 ec 0c             	sub    $0xc,%esp
80102dde:	68 4d 94 10 80       	push   $0x8010944d
80102de3:	e8 20 d8 ff ff       	call   80100608 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102de8:	83 ec 04             	sub    $0x4,%esp
80102deb:	68 00 10 00 00       	push   $0x1000
80102df0:	6a 01                	push   $0x1
80102df2:	ff 75 08             	pushl  0x8(%ebp)
80102df5:	e8 54 27 00 00       	call   8010554e <memset>
80102dfa:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102dfd:	a1 14 47 11 80       	mov    0x80114714,%eax
80102e02:	85 c0                	test   %eax,%eax
80102e04:	74 10                	je     80102e16 <kfree+0x69>
    acquire(&kmem.lock);
80102e06:	83 ec 0c             	sub    $0xc,%esp
80102e09:	68 e0 46 11 80       	push   $0x801146e0
80102e0e:	e8 9c 24 00 00       	call   801052af <acquire>
80102e13:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102e16:	8b 45 08             	mov    0x8(%ebp),%eax
80102e19:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102e1c:	8b 15 18 47 11 80    	mov    0x80114718,%edx
80102e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e25:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e2a:	a3 18 47 11 80       	mov    %eax,0x80114718
  if(kmem.use_lock)
80102e2f:	a1 14 47 11 80       	mov    0x80114714,%eax
80102e34:	85 c0                	test   %eax,%eax
80102e36:	74 10                	je     80102e48 <kfree+0x9b>
    release(&kmem.lock);
80102e38:	83 ec 0c             	sub    $0xc,%esp
80102e3b:	68 e0 46 11 80       	push   $0x801146e0
80102e40:	e8 dc 24 00 00       	call   80105321 <release>
80102e45:	83 c4 10             	add    $0x10,%esp
}
80102e48:	90                   	nop
80102e49:	c9                   	leave  
80102e4a:	c3                   	ret    

80102e4b <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102e4b:	f3 0f 1e fb          	endbr32 
80102e4f:	55                   	push   %ebp
80102e50:	89 e5                	mov    %esp,%ebp
80102e52:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102e55:	a1 14 47 11 80       	mov    0x80114714,%eax
80102e5a:	85 c0                	test   %eax,%eax
80102e5c:	74 10                	je     80102e6e <kalloc+0x23>
    acquire(&kmem.lock);
80102e5e:	83 ec 0c             	sub    $0xc,%esp
80102e61:	68 e0 46 11 80       	push   $0x801146e0
80102e66:	e8 44 24 00 00       	call   801052af <acquire>
80102e6b:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102e6e:	a1 18 47 11 80       	mov    0x80114718,%eax
80102e73:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102e76:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e7a:	74 0a                	je     80102e86 <kalloc+0x3b>
    kmem.freelist = r->next;
80102e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e7f:	8b 00                	mov    (%eax),%eax
80102e81:	a3 18 47 11 80       	mov    %eax,0x80114718
  if(kmem.use_lock)
80102e86:	a1 14 47 11 80       	mov    0x80114714,%eax
80102e8b:	85 c0                	test   %eax,%eax
80102e8d:	74 10                	je     80102e9f <kalloc+0x54>
    release(&kmem.lock);
80102e8f:	83 ec 0c             	sub    $0xc,%esp
80102e92:	68 e0 46 11 80       	push   $0x801146e0
80102e97:	e8 85 24 00 00       	call   80105321 <release>
80102e9c:	83 c4 10             	add    $0x10,%esp
  cprintf("p4Debug : kalloc returns %d %x\n", PPN(V2P(r)), V2P(r));
80102e9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ea2:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80102ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102eab:	05 00 00 00 80       	add    $0x80000000,%eax
80102eb0:	c1 e8 0c             	shr    $0xc,%eax
80102eb3:	83 ec 04             	sub    $0x4,%esp
80102eb6:	52                   	push   %edx
80102eb7:	50                   	push   %eax
80102eb8:	68 54 94 10 80       	push   $0x80109454
80102ebd:	e8 56 d5 ff ff       	call   80100418 <cprintf>
80102ec2:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102ec5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102ec8:	c9                   	leave  
80102ec9:	c3                   	ret    

80102eca <inb>:
{
80102eca:	55                   	push   %ebp
80102ecb:	89 e5                	mov    %esp,%ebp
80102ecd:	83 ec 14             	sub    $0x14,%esp
80102ed0:	8b 45 08             	mov    0x8(%ebp),%eax
80102ed3:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ed7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102edb:	89 c2                	mov    %eax,%edx
80102edd:	ec                   	in     (%dx),%al
80102ede:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102ee1:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102ee5:	c9                   	leave  
80102ee6:	c3                   	ret    

80102ee7 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102ee7:	f3 0f 1e fb          	endbr32 
80102eeb:	55                   	push   %ebp
80102eec:	89 e5                	mov    %esp,%ebp
80102eee:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102ef1:	6a 64                	push   $0x64
80102ef3:	e8 d2 ff ff ff       	call   80102eca <inb>
80102ef8:	83 c4 04             	add    $0x4,%esp
80102efb:	0f b6 c0             	movzbl %al,%eax
80102efe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102f01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f04:	83 e0 01             	and    $0x1,%eax
80102f07:	85 c0                	test   %eax,%eax
80102f09:	75 0a                	jne    80102f15 <kbdgetc+0x2e>
    return -1;
80102f0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102f10:	e9 23 01 00 00       	jmp    80103038 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102f15:	6a 60                	push   $0x60
80102f17:	e8 ae ff ff ff       	call   80102eca <inb>
80102f1c:	83 c4 04             	add    $0x4,%esp
80102f1f:	0f b6 c0             	movzbl %al,%eax
80102f22:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102f25:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102f2c:	75 17                	jne    80102f45 <kbdgetc+0x5e>
    shift |= E0ESC;
80102f2e:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f33:	83 c8 40             	or     $0x40,%eax
80102f36:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102f3b:	b8 00 00 00 00       	mov    $0x0,%eax
80102f40:	e9 f3 00 00 00       	jmp    80103038 <kbdgetc+0x151>
  } else if(data & 0x80){
80102f45:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f48:	25 80 00 00 00       	and    $0x80,%eax
80102f4d:	85 c0                	test   %eax,%eax
80102f4f:	74 45                	je     80102f96 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102f51:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f56:	83 e0 40             	and    $0x40,%eax
80102f59:	85 c0                	test   %eax,%eax
80102f5b:	75 08                	jne    80102f65 <kbdgetc+0x7e>
80102f5d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f60:	83 e0 7f             	and    $0x7f,%eax
80102f63:	eb 03                	jmp    80102f68 <kbdgetc+0x81>
80102f65:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f68:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102f6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f6e:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102f73:	0f b6 00             	movzbl (%eax),%eax
80102f76:	83 c8 40             	or     $0x40,%eax
80102f79:	0f b6 c0             	movzbl %al,%eax
80102f7c:	f7 d0                	not    %eax
80102f7e:	89 c2                	mov    %eax,%edx
80102f80:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f85:	21 d0                	and    %edx,%eax
80102f87:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102f8c:	b8 00 00 00 00       	mov    $0x0,%eax
80102f91:	e9 a2 00 00 00       	jmp    80103038 <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102f96:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f9b:	83 e0 40             	and    $0x40,%eax
80102f9e:	85 c0                	test   %eax,%eax
80102fa0:	74 14                	je     80102fb6 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102fa2:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102fa9:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102fae:	83 e0 bf             	and    $0xffffffbf,%eax
80102fb1:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  }

  shift |= shiftcode[data];
80102fb6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fb9:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102fbe:	0f b6 00             	movzbl (%eax),%eax
80102fc1:	0f b6 d0             	movzbl %al,%edx
80102fc4:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102fc9:	09 d0                	or     %edx,%eax
80102fcb:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  shift ^= togglecode[data];
80102fd0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fd3:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102fd8:	0f b6 00             	movzbl (%eax),%eax
80102fdb:	0f b6 d0             	movzbl %al,%edx
80102fde:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102fe3:	31 d0                	xor    %edx,%eax
80102fe5:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102fea:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102fef:	83 e0 03             	and    $0x3,%eax
80102ff2:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102ff9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ffc:	01 d0                	add    %edx,%eax
80102ffe:	0f b6 00             	movzbl (%eax),%eax
80103001:	0f b6 c0             	movzbl %al,%eax
80103004:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80103007:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
8010300c:	83 e0 08             	and    $0x8,%eax
8010300f:	85 c0                	test   %eax,%eax
80103011:	74 22                	je     80103035 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80103013:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80103017:	76 0c                	jbe    80103025 <kbdgetc+0x13e>
80103019:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
8010301d:	77 06                	ja     80103025 <kbdgetc+0x13e>
      c += 'A' - 'a';
8010301f:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80103023:	eb 10                	jmp    80103035 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80103025:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80103029:	76 0a                	jbe    80103035 <kbdgetc+0x14e>
8010302b:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
8010302f:	77 04                	ja     80103035 <kbdgetc+0x14e>
      c += 'a' - 'A';
80103031:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80103035:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103038:	c9                   	leave  
80103039:	c3                   	ret    

8010303a <kbdintr>:

void
kbdintr(void)
{
8010303a:	f3 0f 1e fb          	endbr32 
8010303e:	55                   	push   %ebp
8010303f:	89 e5                	mov    %esp,%ebp
80103041:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80103044:	83 ec 0c             	sub    $0xc,%esp
80103047:	68 e7 2e 10 80       	push   $0x80102ee7
8010304c:	e8 57 d8 ff ff       	call   801008a8 <consoleintr>
80103051:	83 c4 10             	add    $0x10,%esp
}
80103054:	90                   	nop
80103055:	c9                   	leave  
80103056:	c3                   	ret    

80103057 <inb>:
{
80103057:	55                   	push   %ebp
80103058:	89 e5                	mov    %esp,%ebp
8010305a:	83 ec 14             	sub    $0x14,%esp
8010305d:	8b 45 08             	mov    0x8(%ebp),%eax
80103060:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103064:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103068:	89 c2                	mov    %eax,%edx
8010306a:	ec                   	in     (%dx),%al
8010306b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010306e:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103072:	c9                   	leave  
80103073:	c3                   	ret    

80103074 <outb>:
{
80103074:	55                   	push   %ebp
80103075:	89 e5                	mov    %esp,%ebp
80103077:	83 ec 08             	sub    $0x8,%esp
8010307a:	8b 45 08             	mov    0x8(%ebp),%eax
8010307d:	8b 55 0c             	mov    0xc(%ebp),%edx
80103080:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103084:	89 d0                	mov    %edx,%eax
80103086:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103089:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010308d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103091:	ee                   	out    %al,(%dx)
}
80103092:	90                   	nop
80103093:	c9                   	leave  
80103094:	c3                   	ret    

80103095 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80103095:	f3 0f 1e fb          	endbr32 
80103099:	55                   	push   %ebp
8010309a:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
8010309c:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801030a1:	8b 55 08             	mov    0x8(%ebp),%edx
801030a4:	c1 e2 02             	shl    $0x2,%edx
801030a7:	01 c2                	add    %eax,%edx
801030a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801030ac:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801030ae:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801030b3:	83 c0 20             	add    $0x20,%eax
801030b6:	8b 00                	mov    (%eax),%eax
}
801030b8:	90                   	nop
801030b9:	5d                   	pop    %ebp
801030ba:	c3                   	ret    

801030bb <lapicinit>:

void
lapicinit(void)
{
801030bb:	f3 0f 1e fb          	endbr32 
801030bf:	55                   	push   %ebp
801030c0:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801030c2:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801030c7:	85 c0                	test   %eax,%eax
801030c9:	0f 84 0c 01 00 00    	je     801031db <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801030cf:	68 3f 01 00 00       	push   $0x13f
801030d4:	6a 3c                	push   $0x3c
801030d6:	e8 ba ff ff ff       	call   80103095 <lapicw>
801030db:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801030de:	6a 0b                	push   $0xb
801030e0:	68 f8 00 00 00       	push   $0xf8
801030e5:	e8 ab ff ff ff       	call   80103095 <lapicw>
801030ea:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801030ed:	68 20 00 02 00       	push   $0x20020
801030f2:	68 c8 00 00 00       	push   $0xc8
801030f7:	e8 99 ff ff ff       	call   80103095 <lapicw>
801030fc:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
801030ff:	68 80 96 98 00       	push   $0x989680
80103104:	68 e0 00 00 00       	push   $0xe0
80103109:	e8 87 ff ff ff       	call   80103095 <lapicw>
8010310e:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80103111:	68 00 00 01 00       	push   $0x10000
80103116:	68 d4 00 00 00       	push   $0xd4
8010311b:	e8 75 ff ff ff       	call   80103095 <lapicw>
80103120:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80103123:	68 00 00 01 00       	push   $0x10000
80103128:	68 d8 00 00 00       	push   $0xd8
8010312d:	e8 63 ff ff ff       	call   80103095 <lapicw>
80103132:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80103135:	a1 1c 47 11 80       	mov    0x8011471c,%eax
8010313a:	83 c0 30             	add    $0x30,%eax
8010313d:	8b 00                	mov    (%eax),%eax
8010313f:	c1 e8 10             	shr    $0x10,%eax
80103142:	25 fc 00 00 00       	and    $0xfc,%eax
80103147:	85 c0                	test   %eax,%eax
80103149:	74 12                	je     8010315d <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
8010314b:	68 00 00 01 00       	push   $0x10000
80103150:	68 d0 00 00 00       	push   $0xd0
80103155:	e8 3b ff ff ff       	call   80103095 <lapicw>
8010315a:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
8010315d:	6a 33                	push   $0x33
8010315f:	68 dc 00 00 00       	push   $0xdc
80103164:	e8 2c ff ff ff       	call   80103095 <lapicw>
80103169:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
8010316c:	6a 00                	push   $0x0
8010316e:	68 a0 00 00 00       	push   $0xa0
80103173:	e8 1d ff ff ff       	call   80103095 <lapicw>
80103178:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
8010317b:	6a 00                	push   $0x0
8010317d:	68 a0 00 00 00       	push   $0xa0
80103182:	e8 0e ff ff ff       	call   80103095 <lapicw>
80103187:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
8010318a:	6a 00                	push   $0x0
8010318c:	6a 2c                	push   $0x2c
8010318e:	e8 02 ff ff ff       	call   80103095 <lapicw>
80103193:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103196:	6a 00                	push   $0x0
80103198:	68 c4 00 00 00       	push   $0xc4
8010319d:	e8 f3 fe ff ff       	call   80103095 <lapicw>
801031a2:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801031a5:	68 00 85 08 00       	push   $0x88500
801031aa:	68 c0 00 00 00       	push   $0xc0
801031af:	e8 e1 fe ff ff       	call   80103095 <lapicw>
801031b4:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
801031b7:	90                   	nop
801031b8:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801031bd:	05 00 03 00 00       	add    $0x300,%eax
801031c2:	8b 00                	mov    (%eax),%eax
801031c4:	25 00 10 00 00       	and    $0x1000,%eax
801031c9:	85 c0                	test   %eax,%eax
801031cb:	75 eb                	jne    801031b8 <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801031cd:	6a 00                	push   $0x0
801031cf:	6a 20                	push   $0x20
801031d1:	e8 bf fe ff ff       	call   80103095 <lapicw>
801031d6:	83 c4 08             	add    $0x8,%esp
801031d9:	eb 01                	jmp    801031dc <lapicinit+0x121>
    return;
801031db:	90                   	nop
}
801031dc:	c9                   	leave  
801031dd:	c3                   	ret    

801031de <lapicid>:

int
lapicid(void)
{
801031de:	f3 0f 1e fb          	endbr32 
801031e2:	55                   	push   %ebp
801031e3:	89 e5                	mov    %esp,%ebp
  if (!lapic)
801031e5:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801031ea:	85 c0                	test   %eax,%eax
801031ec:	75 07                	jne    801031f5 <lapicid+0x17>
    return 0;
801031ee:	b8 00 00 00 00       	mov    $0x0,%eax
801031f3:	eb 0d                	jmp    80103202 <lapicid+0x24>
  return lapic[ID] >> 24;
801031f5:	a1 1c 47 11 80       	mov    0x8011471c,%eax
801031fa:	83 c0 20             	add    $0x20,%eax
801031fd:	8b 00                	mov    (%eax),%eax
801031ff:	c1 e8 18             	shr    $0x18,%eax
}
80103202:	5d                   	pop    %ebp
80103203:	c3                   	ret    

80103204 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103204:	f3 0f 1e fb          	endbr32 
80103208:	55                   	push   %ebp
80103209:	89 e5                	mov    %esp,%ebp
  if(lapic)
8010320b:	a1 1c 47 11 80       	mov    0x8011471c,%eax
80103210:	85 c0                	test   %eax,%eax
80103212:	74 0c                	je     80103220 <lapiceoi+0x1c>
    lapicw(EOI, 0);
80103214:	6a 00                	push   $0x0
80103216:	6a 2c                	push   $0x2c
80103218:	e8 78 fe ff ff       	call   80103095 <lapicw>
8010321d:	83 c4 08             	add    $0x8,%esp
}
80103220:	90                   	nop
80103221:	c9                   	leave  
80103222:	c3                   	ret    

80103223 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103223:	f3 0f 1e fb          	endbr32 
80103227:	55                   	push   %ebp
80103228:	89 e5                	mov    %esp,%ebp
}
8010322a:	90                   	nop
8010322b:	5d                   	pop    %ebp
8010322c:	c3                   	ret    

8010322d <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
8010322d:	f3 0f 1e fb          	endbr32 
80103231:	55                   	push   %ebp
80103232:	89 e5                	mov    %esp,%ebp
80103234:	83 ec 14             	sub    $0x14,%esp
80103237:	8b 45 08             	mov    0x8(%ebp),%eax
8010323a:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
8010323d:	6a 0f                	push   $0xf
8010323f:	6a 70                	push   $0x70
80103241:	e8 2e fe ff ff       	call   80103074 <outb>
80103246:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103249:	6a 0a                	push   $0xa
8010324b:	6a 71                	push   $0x71
8010324d:	e8 22 fe ff ff       	call   80103074 <outb>
80103252:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103255:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010325c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010325f:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103264:	8b 45 0c             	mov    0xc(%ebp),%eax
80103267:	c1 e8 04             	shr    $0x4,%eax
8010326a:	89 c2                	mov    %eax,%edx
8010326c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010326f:	83 c0 02             	add    $0x2,%eax
80103272:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103275:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103279:	c1 e0 18             	shl    $0x18,%eax
8010327c:	50                   	push   %eax
8010327d:	68 c4 00 00 00       	push   $0xc4
80103282:	e8 0e fe ff ff       	call   80103095 <lapicw>
80103287:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010328a:	68 00 c5 00 00       	push   $0xc500
8010328f:	68 c0 00 00 00       	push   $0xc0
80103294:	e8 fc fd ff ff       	call   80103095 <lapicw>
80103299:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010329c:	68 c8 00 00 00       	push   $0xc8
801032a1:	e8 7d ff ff ff       	call   80103223 <microdelay>
801032a6:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801032a9:	68 00 85 00 00       	push   $0x8500
801032ae:	68 c0 00 00 00       	push   $0xc0
801032b3:	e8 dd fd ff ff       	call   80103095 <lapicw>
801032b8:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801032bb:	6a 64                	push   $0x64
801032bd:	e8 61 ff ff ff       	call   80103223 <microdelay>
801032c2:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801032c5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801032cc:	eb 3d                	jmp    8010330b <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
801032ce:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801032d2:	c1 e0 18             	shl    $0x18,%eax
801032d5:	50                   	push   %eax
801032d6:	68 c4 00 00 00       	push   $0xc4
801032db:	e8 b5 fd ff ff       	call   80103095 <lapicw>
801032e0:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801032e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801032e6:	c1 e8 0c             	shr    $0xc,%eax
801032e9:	80 cc 06             	or     $0x6,%ah
801032ec:	50                   	push   %eax
801032ed:	68 c0 00 00 00       	push   $0xc0
801032f2:	e8 9e fd ff ff       	call   80103095 <lapicw>
801032f7:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801032fa:	68 c8 00 00 00       	push   $0xc8
801032ff:	e8 1f ff ff ff       	call   80103223 <microdelay>
80103304:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80103307:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010330b:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010330f:	7e bd                	jle    801032ce <lapicstartap+0xa1>
  }
}
80103311:	90                   	nop
80103312:	90                   	nop
80103313:	c9                   	leave  
80103314:	c3                   	ret    

80103315 <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
80103315:	f3 0f 1e fb          	endbr32 
80103319:	55                   	push   %ebp
8010331a:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
8010331c:	8b 45 08             	mov    0x8(%ebp),%eax
8010331f:	0f b6 c0             	movzbl %al,%eax
80103322:	50                   	push   %eax
80103323:	6a 70                	push   $0x70
80103325:	e8 4a fd ff ff       	call   80103074 <outb>
8010332a:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010332d:	68 c8 00 00 00       	push   $0xc8
80103332:	e8 ec fe ff ff       	call   80103223 <microdelay>
80103337:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
8010333a:	6a 71                	push   $0x71
8010333c:	e8 16 fd ff ff       	call   80103057 <inb>
80103341:	83 c4 04             	add    $0x4,%esp
80103344:	0f b6 c0             	movzbl %al,%eax
}
80103347:	c9                   	leave  
80103348:	c3                   	ret    

80103349 <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
80103349:	f3 0f 1e fb          	endbr32 
8010334d:	55                   	push   %ebp
8010334e:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103350:	6a 00                	push   $0x0
80103352:	e8 be ff ff ff       	call   80103315 <cmos_read>
80103357:	83 c4 04             	add    $0x4,%esp
8010335a:	8b 55 08             	mov    0x8(%ebp),%edx
8010335d:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
8010335f:	6a 02                	push   $0x2
80103361:	e8 af ff ff ff       	call   80103315 <cmos_read>
80103366:	83 c4 04             	add    $0x4,%esp
80103369:	8b 55 08             	mov    0x8(%ebp),%edx
8010336c:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
8010336f:	6a 04                	push   $0x4
80103371:	e8 9f ff ff ff       	call   80103315 <cmos_read>
80103376:	83 c4 04             	add    $0x4,%esp
80103379:	8b 55 08             	mov    0x8(%ebp),%edx
8010337c:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
8010337f:	6a 07                	push   $0x7
80103381:	e8 8f ff ff ff       	call   80103315 <cmos_read>
80103386:	83 c4 04             	add    $0x4,%esp
80103389:	8b 55 08             	mov    0x8(%ebp),%edx
8010338c:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
8010338f:	6a 08                	push   $0x8
80103391:	e8 7f ff ff ff       	call   80103315 <cmos_read>
80103396:	83 c4 04             	add    $0x4,%esp
80103399:	8b 55 08             	mov    0x8(%ebp),%edx
8010339c:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
8010339f:	6a 09                	push   $0x9
801033a1:	e8 6f ff ff ff       	call   80103315 <cmos_read>
801033a6:	83 c4 04             	add    $0x4,%esp
801033a9:	8b 55 08             	mov    0x8(%ebp),%edx
801033ac:	89 42 14             	mov    %eax,0x14(%edx)
}
801033af:	90                   	nop
801033b0:	c9                   	leave  
801033b1:	c3                   	ret    

801033b2 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
801033b2:	f3 0f 1e fb          	endbr32 
801033b6:	55                   	push   %ebp
801033b7:	89 e5                	mov    %esp,%ebp
801033b9:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801033bc:	6a 0b                	push   $0xb
801033be:	e8 52 ff ff ff       	call   80103315 <cmos_read>
801033c3:	83 c4 04             	add    $0x4,%esp
801033c6:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801033c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033cc:	83 e0 04             	and    $0x4,%eax
801033cf:	85 c0                	test   %eax,%eax
801033d1:	0f 94 c0             	sete   %al
801033d4:	0f b6 c0             	movzbl %al,%eax
801033d7:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801033da:	8d 45 d8             	lea    -0x28(%ebp),%eax
801033dd:	50                   	push   %eax
801033de:	e8 66 ff ff ff       	call   80103349 <fill_rtcdate>
801033e3:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801033e6:	6a 0a                	push   $0xa
801033e8:	e8 28 ff ff ff       	call   80103315 <cmos_read>
801033ed:	83 c4 04             	add    $0x4,%esp
801033f0:	25 80 00 00 00       	and    $0x80,%eax
801033f5:	85 c0                	test   %eax,%eax
801033f7:	75 27                	jne    80103420 <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
801033f9:	8d 45 c0             	lea    -0x40(%ebp),%eax
801033fc:	50                   	push   %eax
801033fd:	e8 47 ff ff ff       	call   80103349 <fill_rtcdate>
80103402:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80103405:	83 ec 04             	sub    $0x4,%esp
80103408:	6a 18                	push   $0x18
8010340a:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010340d:	50                   	push   %eax
8010340e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103411:	50                   	push   %eax
80103412:	e8 a2 21 00 00       	call   801055b9 <memcmp>
80103417:	83 c4 10             	add    $0x10,%esp
8010341a:	85 c0                	test   %eax,%eax
8010341c:	74 05                	je     80103423 <cmostime+0x71>
8010341e:	eb ba                	jmp    801033da <cmostime+0x28>
        continue;
80103420:	90                   	nop
    fill_rtcdate(&t1);
80103421:	eb b7                	jmp    801033da <cmostime+0x28>
      break;
80103423:	90                   	nop
  }

  // convert
  if(bcd) {
80103424:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103428:	0f 84 b4 00 00 00    	je     801034e2 <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010342e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103431:	c1 e8 04             	shr    $0x4,%eax
80103434:	89 c2                	mov    %eax,%edx
80103436:	89 d0                	mov    %edx,%eax
80103438:	c1 e0 02             	shl    $0x2,%eax
8010343b:	01 d0                	add    %edx,%eax
8010343d:	01 c0                	add    %eax,%eax
8010343f:	89 c2                	mov    %eax,%edx
80103441:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103444:	83 e0 0f             	and    $0xf,%eax
80103447:	01 d0                	add    %edx,%eax
80103449:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
8010344c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010344f:	c1 e8 04             	shr    $0x4,%eax
80103452:	89 c2                	mov    %eax,%edx
80103454:	89 d0                	mov    %edx,%eax
80103456:	c1 e0 02             	shl    $0x2,%eax
80103459:	01 d0                	add    %edx,%eax
8010345b:	01 c0                	add    %eax,%eax
8010345d:	89 c2                	mov    %eax,%edx
8010345f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103462:	83 e0 0f             	and    $0xf,%eax
80103465:	01 d0                	add    %edx,%eax
80103467:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010346a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010346d:	c1 e8 04             	shr    $0x4,%eax
80103470:	89 c2                	mov    %eax,%edx
80103472:	89 d0                	mov    %edx,%eax
80103474:	c1 e0 02             	shl    $0x2,%eax
80103477:	01 d0                	add    %edx,%eax
80103479:	01 c0                	add    %eax,%eax
8010347b:	89 c2                	mov    %eax,%edx
8010347d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103480:	83 e0 0f             	and    $0xf,%eax
80103483:	01 d0                	add    %edx,%eax
80103485:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103488:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010348b:	c1 e8 04             	shr    $0x4,%eax
8010348e:	89 c2                	mov    %eax,%edx
80103490:	89 d0                	mov    %edx,%eax
80103492:	c1 e0 02             	shl    $0x2,%eax
80103495:	01 d0                	add    %edx,%eax
80103497:	01 c0                	add    %eax,%eax
80103499:	89 c2                	mov    %eax,%edx
8010349b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010349e:	83 e0 0f             	and    $0xf,%eax
801034a1:	01 d0                	add    %edx,%eax
801034a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801034a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801034a9:	c1 e8 04             	shr    $0x4,%eax
801034ac:	89 c2                	mov    %eax,%edx
801034ae:	89 d0                	mov    %edx,%eax
801034b0:	c1 e0 02             	shl    $0x2,%eax
801034b3:	01 d0                	add    %edx,%eax
801034b5:	01 c0                	add    %eax,%eax
801034b7:	89 c2                	mov    %eax,%edx
801034b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801034bc:	83 e0 0f             	and    $0xf,%eax
801034bf:	01 d0                	add    %edx,%eax
801034c1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801034c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034c7:	c1 e8 04             	shr    $0x4,%eax
801034ca:	89 c2                	mov    %eax,%edx
801034cc:	89 d0                	mov    %edx,%eax
801034ce:	c1 e0 02             	shl    $0x2,%eax
801034d1:	01 d0                	add    %edx,%eax
801034d3:	01 c0                	add    %eax,%eax
801034d5:	89 c2                	mov    %eax,%edx
801034d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034da:	83 e0 0f             	and    $0xf,%eax
801034dd:	01 d0                	add    %edx,%eax
801034df:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801034e2:	8b 45 08             	mov    0x8(%ebp),%eax
801034e5:	8b 55 d8             	mov    -0x28(%ebp),%edx
801034e8:	89 10                	mov    %edx,(%eax)
801034ea:	8b 55 dc             	mov    -0x24(%ebp),%edx
801034ed:	89 50 04             	mov    %edx,0x4(%eax)
801034f0:	8b 55 e0             	mov    -0x20(%ebp),%edx
801034f3:	89 50 08             	mov    %edx,0x8(%eax)
801034f6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801034f9:	89 50 0c             	mov    %edx,0xc(%eax)
801034fc:	8b 55 e8             	mov    -0x18(%ebp),%edx
801034ff:	89 50 10             	mov    %edx,0x10(%eax)
80103502:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103505:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103508:	8b 45 08             	mov    0x8(%ebp),%eax
8010350b:	8b 40 14             	mov    0x14(%eax),%eax
8010350e:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103514:	8b 45 08             	mov    0x8(%ebp),%eax
80103517:	89 50 14             	mov    %edx,0x14(%eax)
}
8010351a:	90                   	nop
8010351b:	c9                   	leave  
8010351c:	c3                   	ret    

8010351d <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
8010351d:	f3 0f 1e fb          	endbr32 
80103521:	55                   	push   %ebp
80103522:	89 e5                	mov    %esp,%ebp
80103524:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103527:	83 ec 08             	sub    $0x8,%esp
8010352a:	68 74 94 10 80       	push   $0x80109474
8010352f:	68 20 47 11 80       	push   $0x80114720
80103534:	e8 50 1d 00 00       	call   80105289 <initlock>
80103539:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010353c:	83 ec 08             	sub    $0x8,%esp
8010353f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103542:	50                   	push   %eax
80103543:	ff 75 08             	pushl  0x8(%ebp)
80103546:	e8 d3 df ff ff       	call   8010151e <readsb>
8010354b:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
8010354e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103551:	a3 54 47 11 80       	mov    %eax,0x80114754
  log.size = sb.nlog;
80103556:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103559:	a3 58 47 11 80       	mov    %eax,0x80114758
  log.dev = dev;
8010355e:	8b 45 08             	mov    0x8(%ebp),%eax
80103561:	a3 64 47 11 80       	mov    %eax,0x80114764
  recover_from_log();
80103566:	e8 bf 01 00 00       	call   8010372a <recover_from_log>
}
8010356b:	90                   	nop
8010356c:	c9                   	leave  
8010356d:	c3                   	ret    

8010356e <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
8010356e:	f3 0f 1e fb          	endbr32 
80103572:	55                   	push   %ebp
80103573:	89 e5                	mov    %esp,%ebp
80103575:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103578:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010357f:	e9 95 00 00 00       	jmp    80103619 <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103584:	8b 15 54 47 11 80    	mov    0x80114754,%edx
8010358a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010358d:	01 d0                	add    %edx,%eax
8010358f:	83 c0 01             	add    $0x1,%eax
80103592:	89 c2                	mov    %eax,%edx
80103594:	a1 64 47 11 80       	mov    0x80114764,%eax
80103599:	83 ec 08             	sub    $0x8,%esp
8010359c:	52                   	push   %edx
8010359d:	50                   	push   %eax
8010359e:	e8 34 cc ff ff       	call   801001d7 <bread>
801035a3:	83 c4 10             	add    $0x10,%esp
801035a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801035a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035ac:	83 c0 10             	add    $0x10,%eax
801035af:	8b 04 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%eax
801035b6:	89 c2                	mov    %eax,%edx
801035b8:	a1 64 47 11 80       	mov    0x80114764,%eax
801035bd:	83 ec 08             	sub    $0x8,%esp
801035c0:	52                   	push   %edx
801035c1:	50                   	push   %eax
801035c2:	e8 10 cc ff ff       	call   801001d7 <bread>
801035c7:	83 c4 10             	add    $0x10,%esp
801035ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801035cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035d0:	8d 50 5c             	lea    0x5c(%eax),%edx
801035d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035d6:	83 c0 5c             	add    $0x5c,%eax
801035d9:	83 ec 04             	sub    $0x4,%esp
801035dc:	68 00 02 00 00       	push   $0x200
801035e1:	52                   	push   %edx
801035e2:	50                   	push   %eax
801035e3:	e8 2d 20 00 00       	call   80105615 <memmove>
801035e8:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801035eb:	83 ec 0c             	sub    $0xc,%esp
801035ee:	ff 75 ec             	pushl  -0x14(%ebp)
801035f1:	e8 1e cc ff ff       	call   80100214 <bwrite>
801035f6:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
801035f9:	83 ec 0c             	sub    $0xc,%esp
801035fc:	ff 75 f0             	pushl  -0x10(%ebp)
801035ff:	e8 5d cc ff ff       	call   80100261 <brelse>
80103604:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103607:	83 ec 0c             	sub    $0xc,%esp
8010360a:	ff 75 ec             	pushl  -0x14(%ebp)
8010360d:	e8 4f cc ff ff       	call   80100261 <brelse>
80103612:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103615:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103619:	a1 68 47 11 80       	mov    0x80114768,%eax
8010361e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103621:	0f 8c 5d ff ff ff    	jl     80103584 <install_trans+0x16>
  }
}
80103627:	90                   	nop
80103628:	90                   	nop
80103629:	c9                   	leave  
8010362a:	c3                   	ret    

8010362b <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010362b:	f3 0f 1e fb          	endbr32 
8010362f:	55                   	push   %ebp
80103630:	89 e5                	mov    %esp,%ebp
80103632:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103635:	a1 54 47 11 80       	mov    0x80114754,%eax
8010363a:	89 c2                	mov    %eax,%edx
8010363c:	a1 64 47 11 80       	mov    0x80114764,%eax
80103641:	83 ec 08             	sub    $0x8,%esp
80103644:	52                   	push   %edx
80103645:	50                   	push   %eax
80103646:	e8 8c cb ff ff       	call   801001d7 <bread>
8010364b:	83 c4 10             	add    $0x10,%esp
8010364e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103651:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103654:	83 c0 5c             	add    $0x5c,%eax
80103657:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010365a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010365d:	8b 00                	mov    (%eax),%eax
8010365f:	a3 68 47 11 80       	mov    %eax,0x80114768
  for (i = 0; i < log.lh.n; i++) {
80103664:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010366b:	eb 1b                	jmp    80103688 <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
8010366d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103670:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103673:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103677:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010367a:	83 c2 10             	add    $0x10,%edx
8010367d:	89 04 95 2c 47 11 80 	mov    %eax,-0x7feeb8d4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103684:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103688:	a1 68 47 11 80       	mov    0x80114768,%eax
8010368d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103690:	7c db                	jl     8010366d <read_head+0x42>
  }
  brelse(buf);
80103692:	83 ec 0c             	sub    $0xc,%esp
80103695:	ff 75 f0             	pushl  -0x10(%ebp)
80103698:	e8 c4 cb ff ff       	call   80100261 <brelse>
8010369d:	83 c4 10             	add    $0x10,%esp
}
801036a0:	90                   	nop
801036a1:	c9                   	leave  
801036a2:	c3                   	ret    

801036a3 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801036a3:	f3 0f 1e fb          	endbr32 
801036a7:	55                   	push   %ebp
801036a8:	89 e5                	mov    %esp,%ebp
801036aa:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801036ad:	a1 54 47 11 80       	mov    0x80114754,%eax
801036b2:	89 c2                	mov    %eax,%edx
801036b4:	a1 64 47 11 80       	mov    0x80114764,%eax
801036b9:	83 ec 08             	sub    $0x8,%esp
801036bc:	52                   	push   %edx
801036bd:	50                   	push   %eax
801036be:	e8 14 cb ff ff       	call   801001d7 <bread>
801036c3:	83 c4 10             	add    $0x10,%esp
801036c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801036c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036cc:	83 c0 5c             	add    $0x5c,%eax
801036cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801036d2:	8b 15 68 47 11 80    	mov    0x80114768,%edx
801036d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036db:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801036dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036e4:	eb 1b                	jmp    80103701 <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
801036e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036e9:	83 c0 10             	add    $0x10,%eax
801036ec:	8b 0c 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%ecx
801036f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801036f9:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801036fd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103701:	a1 68 47 11 80       	mov    0x80114768,%eax
80103706:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103709:	7c db                	jl     801036e6 <write_head+0x43>
  }
  bwrite(buf);
8010370b:	83 ec 0c             	sub    $0xc,%esp
8010370e:	ff 75 f0             	pushl  -0x10(%ebp)
80103711:	e8 fe ca ff ff       	call   80100214 <bwrite>
80103716:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103719:	83 ec 0c             	sub    $0xc,%esp
8010371c:	ff 75 f0             	pushl  -0x10(%ebp)
8010371f:	e8 3d cb ff ff       	call   80100261 <brelse>
80103724:	83 c4 10             	add    $0x10,%esp
}
80103727:	90                   	nop
80103728:	c9                   	leave  
80103729:	c3                   	ret    

8010372a <recover_from_log>:

static void
recover_from_log(void)
{
8010372a:	f3 0f 1e fb          	endbr32 
8010372e:	55                   	push   %ebp
8010372f:	89 e5                	mov    %esp,%ebp
80103731:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103734:	e8 f2 fe ff ff       	call   8010362b <read_head>
  install_trans(); // if committed, copy from log to disk
80103739:	e8 30 fe ff ff       	call   8010356e <install_trans>
  log.lh.n = 0;
8010373e:	c7 05 68 47 11 80 00 	movl   $0x0,0x80114768
80103745:	00 00 00 
  write_head(); // clear the log
80103748:	e8 56 ff ff ff       	call   801036a3 <write_head>
}
8010374d:	90                   	nop
8010374e:	c9                   	leave  
8010374f:	c3                   	ret    

80103750 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103750:	f3 0f 1e fb          	endbr32 
80103754:	55                   	push   %ebp
80103755:	89 e5                	mov    %esp,%ebp
80103757:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010375a:	83 ec 0c             	sub    $0xc,%esp
8010375d:	68 20 47 11 80       	push   $0x80114720
80103762:	e8 48 1b 00 00       	call   801052af <acquire>
80103767:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010376a:	a1 60 47 11 80       	mov    0x80114760,%eax
8010376f:	85 c0                	test   %eax,%eax
80103771:	74 17                	je     8010378a <begin_op+0x3a>
      sleep(&log, &log.lock);
80103773:	83 ec 08             	sub    $0x8,%esp
80103776:	68 20 47 11 80       	push   $0x80114720
8010377b:	68 20 47 11 80       	push   $0x80114720
80103780:	e8 b8 16 00 00       	call   80104e3d <sleep>
80103785:	83 c4 10             	add    $0x10,%esp
80103788:	eb e0                	jmp    8010376a <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010378a:	8b 0d 68 47 11 80    	mov    0x80114768,%ecx
80103790:	a1 5c 47 11 80       	mov    0x8011475c,%eax
80103795:	8d 50 01             	lea    0x1(%eax),%edx
80103798:	89 d0                	mov    %edx,%eax
8010379a:	c1 e0 02             	shl    $0x2,%eax
8010379d:	01 d0                	add    %edx,%eax
8010379f:	01 c0                	add    %eax,%eax
801037a1:	01 c8                	add    %ecx,%eax
801037a3:	83 f8 1e             	cmp    $0x1e,%eax
801037a6:	7e 17                	jle    801037bf <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801037a8:	83 ec 08             	sub    $0x8,%esp
801037ab:	68 20 47 11 80       	push   $0x80114720
801037b0:	68 20 47 11 80       	push   $0x80114720
801037b5:	e8 83 16 00 00       	call   80104e3d <sleep>
801037ba:	83 c4 10             	add    $0x10,%esp
801037bd:	eb ab                	jmp    8010376a <begin_op+0x1a>
    } else {
      log.outstanding += 1;
801037bf:	a1 5c 47 11 80       	mov    0x8011475c,%eax
801037c4:	83 c0 01             	add    $0x1,%eax
801037c7:	a3 5c 47 11 80       	mov    %eax,0x8011475c
      release(&log.lock);
801037cc:	83 ec 0c             	sub    $0xc,%esp
801037cf:	68 20 47 11 80       	push   $0x80114720
801037d4:	e8 48 1b 00 00       	call   80105321 <release>
801037d9:	83 c4 10             	add    $0x10,%esp
      break;
801037dc:	90                   	nop
    }
  }
}
801037dd:	90                   	nop
801037de:	c9                   	leave  
801037df:	c3                   	ret    

801037e0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801037e0:	f3 0f 1e fb          	endbr32 
801037e4:	55                   	push   %ebp
801037e5:	89 e5                	mov    %esp,%ebp
801037e7:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801037ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801037f1:	83 ec 0c             	sub    $0xc,%esp
801037f4:	68 20 47 11 80       	push   $0x80114720
801037f9:	e8 b1 1a 00 00       	call   801052af <acquire>
801037fe:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103801:	a1 5c 47 11 80       	mov    0x8011475c,%eax
80103806:	83 e8 01             	sub    $0x1,%eax
80103809:	a3 5c 47 11 80       	mov    %eax,0x8011475c
  if(log.committing)
8010380e:	a1 60 47 11 80       	mov    0x80114760,%eax
80103813:	85 c0                	test   %eax,%eax
80103815:	74 0d                	je     80103824 <end_op+0x44>
    panic("log.committing");
80103817:	83 ec 0c             	sub    $0xc,%esp
8010381a:	68 78 94 10 80       	push   $0x80109478
8010381f:	e8 e4 cd ff ff       	call   80100608 <panic>
  if(log.outstanding == 0){
80103824:	a1 5c 47 11 80       	mov    0x8011475c,%eax
80103829:	85 c0                	test   %eax,%eax
8010382b:	75 13                	jne    80103840 <end_op+0x60>
    do_commit = 1;
8010382d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103834:	c7 05 60 47 11 80 01 	movl   $0x1,0x80114760
8010383b:	00 00 00 
8010383e:	eb 10                	jmp    80103850 <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103840:	83 ec 0c             	sub    $0xc,%esp
80103843:	68 20 47 11 80       	push   $0x80114720
80103848:	e8 e2 16 00 00       	call   80104f2f <wakeup>
8010384d:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103850:	83 ec 0c             	sub    $0xc,%esp
80103853:	68 20 47 11 80       	push   $0x80114720
80103858:	e8 c4 1a 00 00       	call   80105321 <release>
8010385d:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103860:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103864:	74 3f                	je     801038a5 <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103866:	e8 fa 00 00 00       	call   80103965 <commit>
    acquire(&log.lock);
8010386b:	83 ec 0c             	sub    $0xc,%esp
8010386e:	68 20 47 11 80       	push   $0x80114720
80103873:	e8 37 1a 00 00       	call   801052af <acquire>
80103878:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010387b:	c7 05 60 47 11 80 00 	movl   $0x0,0x80114760
80103882:	00 00 00 
    wakeup(&log);
80103885:	83 ec 0c             	sub    $0xc,%esp
80103888:	68 20 47 11 80       	push   $0x80114720
8010388d:	e8 9d 16 00 00       	call   80104f2f <wakeup>
80103892:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103895:	83 ec 0c             	sub    $0xc,%esp
80103898:	68 20 47 11 80       	push   $0x80114720
8010389d:	e8 7f 1a 00 00       	call   80105321 <release>
801038a2:	83 c4 10             	add    $0x10,%esp
  }
}
801038a5:	90                   	nop
801038a6:	c9                   	leave  
801038a7:	c3                   	ret    

801038a8 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801038a8:	f3 0f 1e fb          	endbr32 
801038ac:	55                   	push   %ebp
801038ad:	89 e5                	mov    %esp,%ebp
801038af:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801038b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038b9:	e9 95 00 00 00       	jmp    80103953 <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801038be:	8b 15 54 47 11 80    	mov    0x80114754,%edx
801038c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038c7:	01 d0                	add    %edx,%eax
801038c9:	83 c0 01             	add    $0x1,%eax
801038cc:	89 c2                	mov    %eax,%edx
801038ce:	a1 64 47 11 80       	mov    0x80114764,%eax
801038d3:	83 ec 08             	sub    $0x8,%esp
801038d6:	52                   	push   %edx
801038d7:	50                   	push   %eax
801038d8:	e8 fa c8 ff ff       	call   801001d7 <bread>
801038dd:	83 c4 10             	add    $0x10,%esp
801038e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801038e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038e6:	83 c0 10             	add    $0x10,%eax
801038e9:	8b 04 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%eax
801038f0:	89 c2                	mov    %eax,%edx
801038f2:	a1 64 47 11 80       	mov    0x80114764,%eax
801038f7:	83 ec 08             	sub    $0x8,%esp
801038fa:	52                   	push   %edx
801038fb:	50                   	push   %eax
801038fc:	e8 d6 c8 ff ff       	call   801001d7 <bread>
80103901:	83 c4 10             	add    $0x10,%esp
80103904:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103907:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010390a:	8d 50 5c             	lea    0x5c(%eax),%edx
8010390d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103910:	83 c0 5c             	add    $0x5c,%eax
80103913:	83 ec 04             	sub    $0x4,%esp
80103916:	68 00 02 00 00       	push   $0x200
8010391b:	52                   	push   %edx
8010391c:	50                   	push   %eax
8010391d:	e8 f3 1c 00 00       	call   80105615 <memmove>
80103922:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103925:	83 ec 0c             	sub    $0xc,%esp
80103928:	ff 75 f0             	pushl  -0x10(%ebp)
8010392b:	e8 e4 c8 ff ff       	call   80100214 <bwrite>
80103930:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103933:	83 ec 0c             	sub    $0xc,%esp
80103936:	ff 75 ec             	pushl  -0x14(%ebp)
80103939:	e8 23 c9 ff ff       	call   80100261 <brelse>
8010393e:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103941:	83 ec 0c             	sub    $0xc,%esp
80103944:	ff 75 f0             	pushl  -0x10(%ebp)
80103947:	e8 15 c9 ff ff       	call   80100261 <brelse>
8010394c:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010394f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103953:	a1 68 47 11 80       	mov    0x80114768,%eax
80103958:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010395b:	0f 8c 5d ff ff ff    	jl     801038be <write_log+0x16>
  }
}
80103961:	90                   	nop
80103962:	90                   	nop
80103963:	c9                   	leave  
80103964:	c3                   	ret    

80103965 <commit>:

static void
commit()
{
80103965:	f3 0f 1e fb          	endbr32 
80103969:	55                   	push   %ebp
8010396a:	89 e5                	mov    %esp,%ebp
8010396c:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010396f:	a1 68 47 11 80       	mov    0x80114768,%eax
80103974:	85 c0                	test   %eax,%eax
80103976:	7e 1e                	jle    80103996 <commit+0x31>
    write_log();     // Write modified blocks from cache to log
80103978:	e8 2b ff ff ff       	call   801038a8 <write_log>
    write_head();    // Write header to disk -- the real commit
8010397d:	e8 21 fd ff ff       	call   801036a3 <write_head>
    install_trans(); // Now install writes to home locations
80103982:	e8 e7 fb ff ff       	call   8010356e <install_trans>
    log.lh.n = 0;
80103987:	c7 05 68 47 11 80 00 	movl   $0x0,0x80114768
8010398e:	00 00 00 
    write_head();    // Erase the transaction from the log
80103991:	e8 0d fd ff ff       	call   801036a3 <write_head>
  }
}
80103996:	90                   	nop
80103997:	c9                   	leave  
80103998:	c3                   	ret    

80103999 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103999:	f3 0f 1e fb          	endbr32 
8010399d:	55                   	push   %ebp
8010399e:	89 e5                	mov    %esp,%ebp
801039a0:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801039a3:	a1 68 47 11 80       	mov    0x80114768,%eax
801039a8:	83 f8 1d             	cmp    $0x1d,%eax
801039ab:	7f 12                	jg     801039bf <log_write+0x26>
801039ad:	a1 68 47 11 80       	mov    0x80114768,%eax
801039b2:	8b 15 58 47 11 80    	mov    0x80114758,%edx
801039b8:	83 ea 01             	sub    $0x1,%edx
801039bb:	39 d0                	cmp    %edx,%eax
801039bd:	7c 0d                	jl     801039cc <log_write+0x33>
    panic("too big a transaction");
801039bf:	83 ec 0c             	sub    $0xc,%esp
801039c2:	68 87 94 10 80       	push   $0x80109487
801039c7:	e8 3c cc ff ff       	call   80100608 <panic>
  if (log.outstanding < 1)
801039cc:	a1 5c 47 11 80       	mov    0x8011475c,%eax
801039d1:	85 c0                	test   %eax,%eax
801039d3:	7f 0d                	jg     801039e2 <log_write+0x49>
    panic("log_write outside of trans");
801039d5:	83 ec 0c             	sub    $0xc,%esp
801039d8:	68 9d 94 10 80       	push   $0x8010949d
801039dd:	e8 26 cc ff ff       	call   80100608 <panic>

  acquire(&log.lock);
801039e2:	83 ec 0c             	sub    $0xc,%esp
801039e5:	68 20 47 11 80       	push   $0x80114720
801039ea:	e8 c0 18 00 00       	call   801052af <acquire>
801039ef:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801039f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039f9:	eb 1d                	jmp    80103a18 <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801039fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039fe:	83 c0 10             	add    $0x10,%eax
80103a01:	8b 04 85 2c 47 11 80 	mov    -0x7feeb8d4(,%eax,4),%eax
80103a08:	89 c2                	mov    %eax,%edx
80103a0a:	8b 45 08             	mov    0x8(%ebp),%eax
80103a0d:	8b 40 08             	mov    0x8(%eax),%eax
80103a10:	39 c2                	cmp    %eax,%edx
80103a12:	74 10                	je     80103a24 <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
80103a14:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a18:	a1 68 47 11 80       	mov    0x80114768,%eax
80103a1d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a20:	7c d9                	jl     801039fb <log_write+0x62>
80103a22:	eb 01                	jmp    80103a25 <log_write+0x8c>
      break;
80103a24:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103a25:	8b 45 08             	mov    0x8(%ebp),%eax
80103a28:	8b 40 08             	mov    0x8(%eax),%eax
80103a2b:	89 c2                	mov    %eax,%edx
80103a2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a30:	83 c0 10             	add    $0x10,%eax
80103a33:	89 14 85 2c 47 11 80 	mov    %edx,-0x7feeb8d4(,%eax,4)
  if (i == log.lh.n)
80103a3a:	a1 68 47 11 80       	mov    0x80114768,%eax
80103a3f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a42:	75 0d                	jne    80103a51 <log_write+0xb8>
    log.lh.n++;
80103a44:	a1 68 47 11 80       	mov    0x80114768,%eax
80103a49:	83 c0 01             	add    $0x1,%eax
80103a4c:	a3 68 47 11 80       	mov    %eax,0x80114768
  b->flags |= B_DIRTY; // prevent eviction
80103a51:	8b 45 08             	mov    0x8(%ebp),%eax
80103a54:	8b 00                	mov    (%eax),%eax
80103a56:	83 c8 04             	or     $0x4,%eax
80103a59:	89 c2                	mov    %eax,%edx
80103a5b:	8b 45 08             	mov    0x8(%ebp),%eax
80103a5e:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103a60:	83 ec 0c             	sub    $0xc,%esp
80103a63:	68 20 47 11 80       	push   $0x80114720
80103a68:	e8 b4 18 00 00       	call   80105321 <release>
80103a6d:	83 c4 10             	add    $0x10,%esp
}
80103a70:	90                   	nop
80103a71:	c9                   	leave  
80103a72:	c3                   	ret    

80103a73 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103a73:	55                   	push   %ebp
80103a74:	89 e5                	mov    %esp,%ebp
80103a76:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103a79:	8b 55 08             	mov    0x8(%ebp),%edx
80103a7c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103a82:	f0 87 02             	lock xchg %eax,(%edx)
80103a85:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103a88:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103a8b:	c9                   	leave  
80103a8c:	c3                   	ret    

80103a8d <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103a8d:	f3 0f 1e fb          	endbr32 
80103a91:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103a95:	83 e4 f0             	and    $0xfffffff0,%esp
80103a98:	ff 71 fc             	pushl  -0x4(%ecx)
80103a9b:	55                   	push   %ebp
80103a9c:	89 e5                	mov    %esp,%ebp
80103a9e:	51                   	push   %ecx
80103a9f:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103aa2:	83 ec 08             	sub    $0x8,%esp
80103aa5:	68 00 00 40 80       	push   $0x80400000
80103aaa:	68 48 7f 11 80       	push   $0x80117f48
80103aaf:	e8 52 f2 ff ff       	call   80102d06 <kinit1>
80103ab4:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103ab7:	e8 75 46 00 00       	call   80108131 <kvmalloc>
  mpinit();        // detect other processors
80103abc:	e8 d9 03 00 00       	call   80103e9a <mpinit>
  lapicinit();     // interrupt controller
80103ac1:	e8 f5 f5 ff ff       	call   801030bb <lapicinit>
  seginit();       // segment descriptors
80103ac6:	e8 1e 41 00 00       	call   80107be9 <seginit>
  picinit();       // disable pic
80103acb:	e8 35 05 00 00       	call   80104005 <picinit>
  ioapicinit();    // another interrupt controller
80103ad0:	e8 44 f1 ff ff       	call   80102c19 <ioapicinit>
  consoleinit();   // console hardware
80103ad5:	e8 07 d1 ff ff       	call   80100be1 <consoleinit>
  uartinit();      // serial port
80103ada:	e8 93 34 00 00       	call   80106f72 <uartinit>
  pinit();         // process table
80103adf:	e8 6e 09 00 00       	call   80104452 <pinit>
  tvinit();        // trap vectors
80103ae4:	e8 21 30 00 00       	call   80106b0a <tvinit>
  binit();         // buffer cache
80103ae9:	e8 46 c5 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103aee:	e8 00 d6 ff ff       	call   801010f3 <fileinit>
  ideinit();       // disk 
80103af3:	e8 e0 ec ff ff       	call   801027d8 <ideinit>
  startothers();   // start other processors
80103af8:	e8 88 00 00 00       	call   80103b85 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103afd:	83 ec 08             	sub    $0x8,%esp
80103b00:	68 00 00 00 8e       	push   $0x8e000000
80103b05:	68 00 00 40 80       	push   $0x80400000
80103b0a:	e8 34 f2 ff ff       	call   80102d43 <kinit2>
80103b0f:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103b12:	e8 34 0b 00 00       	call   8010464b <userinit>
  mpmain();        // finish this processor's setup
80103b17:	e8 1e 00 00 00       	call   80103b3a <mpmain>

80103b1c <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103b1c:	f3 0f 1e fb          	endbr32 
80103b20:	55                   	push   %ebp
80103b21:	89 e5                	mov    %esp,%ebp
80103b23:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103b26:	e8 22 46 00 00       	call   8010814d <switchkvm>
  seginit();
80103b2b:	e8 b9 40 00 00       	call   80107be9 <seginit>
  lapicinit();
80103b30:	e8 86 f5 ff ff       	call   801030bb <lapicinit>
  mpmain();
80103b35:	e8 00 00 00 00       	call   80103b3a <mpmain>

80103b3a <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103b3a:	f3 0f 1e fb          	endbr32 
80103b3e:	55                   	push   %ebp
80103b3f:	89 e5                	mov    %esp,%ebp
80103b41:	53                   	push   %ebx
80103b42:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103b45:	e8 2a 09 00 00       	call   80104474 <cpuid>
80103b4a:	89 c3                	mov    %eax,%ebx
80103b4c:	e8 23 09 00 00       	call   80104474 <cpuid>
80103b51:	83 ec 04             	sub    $0x4,%esp
80103b54:	53                   	push   %ebx
80103b55:	50                   	push   %eax
80103b56:	68 b8 94 10 80       	push   $0x801094b8
80103b5b:	e8 b8 c8 ff ff       	call   80100418 <cprintf>
80103b60:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103b63:	e8 1c 31 00 00       	call   80106c84 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103b68:	e8 26 09 00 00       	call   80104493 <mycpu>
80103b6d:	05 a0 00 00 00       	add    $0xa0,%eax
80103b72:	83 ec 08             	sub    $0x8,%esp
80103b75:	6a 01                	push   $0x1
80103b77:	50                   	push   %eax
80103b78:	e8 f6 fe ff ff       	call   80103a73 <xchg>
80103b7d:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103b80:	e8 b4 10 00 00       	call   80104c39 <scheduler>

80103b85 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103b85:	f3 0f 1e fb          	endbr32 
80103b89:	55                   	push   %ebp
80103b8a:	89 e5                	mov    %esp,%ebp
80103b8c:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103b8f:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103b96:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103b9b:	83 ec 04             	sub    $0x4,%esp
80103b9e:	50                   	push   %eax
80103b9f:	68 0c c5 10 80       	push   $0x8010c50c
80103ba4:	ff 75 f0             	pushl  -0x10(%ebp)
80103ba7:	e8 69 1a 00 00       	call   80105615 <memmove>
80103bac:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103baf:	c7 45 f4 20 48 11 80 	movl   $0x80114820,-0xc(%ebp)
80103bb6:	eb 79                	jmp    80103c31 <startothers+0xac>
    if(c == mycpu())  // We've started already.
80103bb8:	e8 d6 08 00 00       	call   80104493 <mycpu>
80103bbd:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103bc0:	74 67                	je     80103c29 <startothers+0xa4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103bc2:	e8 84 f2 ff ff       	call   80102e4b <kalloc>
80103bc7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103bca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bcd:	83 e8 04             	sub    $0x4,%eax
80103bd0:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103bd3:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103bd9:	89 10                	mov    %edx,(%eax)
    *(void(**)(void))(code-8) = mpenter;
80103bdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bde:	83 e8 08             	sub    $0x8,%eax
80103be1:	c7 00 1c 3b 10 80    	movl   $0x80103b1c,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103be7:	b8 00 b0 10 80       	mov    $0x8010b000,%eax
80103bec:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103bf2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bf5:	83 e8 0c             	sub    $0xc,%eax
80103bf8:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
80103bfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bfd:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c06:	0f b6 00             	movzbl (%eax),%eax
80103c09:	0f b6 c0             	movzbl %al,%eax
80103c0c:	83 ec 08             	sub    $0x8,%esp
80103c0f:	52                   	push   %edx
80103c10:	50                   	push   %eax
80103c11:	e8 17 f6 ff ff       	call   8010322d <lapicstartap>
80103c16:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103c19:	90                   	nop
80103c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c1d:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103c23:	85 c0                	test   %eax,%eax
80103c25:	74 f3                	je     80103c1a <startothers+0x95>
80103c27:	eb 01                	jmp    80103c2a <startothers+0xa5>
      continue;
80103c29:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103c2a:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103c31:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80103c36:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103c3c:	05 20 48 11 80       	add    $0x80114820,%eax
80103c41:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103c44:	0f 82 6e ff ff ff    	jb     80103bb8 <startothers+0x33>
      ;
  }
}
80103c4a:	90                   	nop
80103c4b:	90                   	nop
80103c4c:	c9                   	leave  
80103c4d:	c3                   	ret    

80103c4e <inb>:
{
80103c4e:	55                   	push   %ebp
80103c4f:	89 e5                	mov    %esp,%ebp
80103c51:	83 ec 14             	sub    $0x14,%esp
80103c54:	8b 45 08             	mov    0x8(%ebp),%eax
80103c57:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103c5b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103c5f:	89 c2                	mov    %eax,%edx
80103c61:	ec                   	in     (%dx),%al
80103c62:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103c65:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103c69:	c9                   	leave  
80103c6a:	c3                   	ret    

80103c6b <outb>:
{
80103c6b:	55                   	push   %ebp
80103c6c:	89 e5                	mov    %esp,%ebp
80103c6e:	83 ec 08             	sub    $0x8,%esp
80103c71:	8b 45 08             	mov    0x8(%ebp),%eax
80103c74:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c77:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103c7b:	89 d0                	mov    %edx,%eax
80103c7d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103c80:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103c84:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103c88:	ee                   	out    %al,(%dx)
}
80103c89:	90                   	nop
80103c8a:	c9                   	leave  
80103c8b:	c3                   	ret    

80103c8c <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103c8c:	f3 0f 1e fb          	endbr32 
80103c90:	55                   	push   %ebp
80103c91:	89 e5                	mov    %esp,%ebp
80103c93:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103c96:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103c9d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103ca4:	eb 15                	jmp    80103cbb <sum+0x2f>
    sum += addr[i];
80103ca6:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103ca9:	8b 45 08             	mov    0x8(%ebp),%eax
80103cac:	01 d0                	add    %edx,%eax
80103cae:	0f b6 00             	movzbl (%eax),%eax
80103cb1:	0f b6 c0             	movzbl %al,%eax
80103cb4:	01 45 f8             	add    %eax,-0x8(%ebp)
  for(i=0; i<len; i++)
80103cb7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103cbb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103cbe:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103cc1:	7c e3                	jl     80103ca6 <sum+0x1a>
  return sum;
80103cc3:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103cc6:	c9                   	leave  
80103cc7:	c3                   	ret    

80103cc8 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103cc8:	f3 0f 1e fb          	endbr32 
80103ccc:	55                   	push   %ebp
80103ccd:	89 e5                	mov    %esp,%ebp
80103ccf:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103cd2:	8b 45 08             	mov    0x8(%ebp),%eax
80103cd5:	05 00 00 00 80       	add    $0x80000000,%eax
80103cda:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103cdd:	8b 55 0c             	mov    0xc(%ebp),%edx
80103ce0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ce3:	01 d0                	add    %edx,%eax
80103ce5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103ce8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ceb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cee:	eb 36                	jmp    80103d26 <mpsearch1+0x5e>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103cf0:	83 ec 04             	sub    $0x4,%esp
80103cf3:	6a 04                	push   $0x4
80103cf5:	68 cc 94 10 80       	push   $0x801094cc
80103cfa:	ff 75 f4             	pushl  -0xc(%ebp)
80103cfd:	e8 b7 18 00 00       	call   801055b9 <memcmp>
80103d02:	83 c4 10             	add    $0x10,%esp
80103d05:	85 c0                	test   %eax,%eax
80103d07:	75 19                	jne    80103d22 <mpsearch1+0x5a>
80103d09:	83 ec 08             	sub    $0x8,%esp
80103d0c:	6a 10                	push   $0x10
80103d0e:	ff 75 f4             	pushl  -0xc(%ebp)
80103d11:	e8 76 ff ff ff       	call   80103c8c <sum>
80103d16:	83 c4 10             	add    $0x10,%esp
80103d19:	84 c0                	test   %al,%al
80103d1b:	75 05                	jne    80103d22 <mpsearch1+0x5a>
      return (struct mp*)p;
80103d1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d20:	eb 11                	jmp    80103d33 <mpsearch1+0x6b>
  for(p = addr; p < e; p += sizeof(struct mp))
80103d22:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d29:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103d2c:	72 c2                	jb     80103cf0 <mpsearch1+0x28>
  return 0;
80103d2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d33:	c9                   	leave  
80103d34:	c3                   	ret    

80103d35 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103d35:	f3 0f 1e fb          	endbr32 
80103d39:	55                   	push   %ebp
80103d3a:	89 e5                	mov    %esp,%ebp
80103d3c:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103d3f:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d49:	83 c0 0f             	add    $0xf,%eax
80103d4c:	0f b6 00             	movzbl (%eax),%eax
80103d4f:	0f b6 c0             	movzbl %al,%eax
80103d52:	c1 e0 08             	shl    $0x8,%eax
80103d55:	89 c2                	mov    %eax,%edx
80103d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d5a:	83 c0 0e             	add    $0xe,%eax
80103d5d:	0f b6 00             	movzbl (%eax),%eax
80103d60:	0f b6 c0             	movzbl %al,%eax
80103d63:	09 d0                	or     %edx,%eax
80103d65:	c1 e0 04             	shl    $0x4,%eax
80103d68:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103d6b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d6f:	74 21                	je     80103d92 <mpsearch+0x5d>
    if((mp = mpsearch1(p, 1024)))
80103d71:	83 ec 08             	sub    $0x8,%esp
80103d74:	68 00 04 00 00       	push   $0x400
80103d79:	ff 75 f0             	pushl  -0x10(%ebp)
80103d7c:	e8 47 ff ff ff       	call   80103cc8 <mpsearch1>
80103d81:	83 c4 10             	add    $0x10,%esp
80103d84:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d87:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d8b:	74 51                	je     80103dde <mpsearch+0xa9>
      return mp;
80103d8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d90:	eb 61                	jmp    80103df3 <mpsearch+0xbe>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103d92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d95:	83 c0 14             	add    $0x14,%eax
80103d98:	0f b6 00             	movzbl (%eax),%eax
80103d9b:	0f b6 c0             	movzbl %al,%eax
80103d9e:	c1 e0 08             	shl    $0x8,%eax
80103da1:	89 c2                	mov    %eax,%edx
80103da3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103da6:	83 c0 13             	add    $0x13,%eax
80103da9:	0f b6 00             	movzbl (%eax),%eax
80103dac:	0f b6 c0             	movzbl %al,%eax
80103daf:	09 d0                	or     %edx,%eax
80103db1:	c1 e0 0a             	shl    $0xa,%eax
80103db4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103db7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dba:	2d 00 04 00 00       	sub    $0x400,%eax
80103dbf:	83 ec 08             	sub    $0x8,%esp
80103dc2:	68 00 04 00 00       	push   $0x400
80103dc7:	50                   	push   %eax
80103dc8:	e8 fb fe ff ff       	call   80103cc8 <mpsearch1>
80103dcd:	83 c4 10             	add    $0x10,%esp
80103dd0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103dd3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103dd7:	74 05                	je     80103dde <mpsearch+0xa9>
      return mp;
80103dd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ddc:	eb 15                	jmp    80103df3 <mpsearch+0xbe>
  }
  return mpsearch1(0xF0000, 0x10000);
80103dde:	83 ec 08             	sub    $0x8,%esp
80103de1:	68 00 00 01 00       	push   $0x10000
80103de6:	68 00 00 0f 00       	push   $0xf0000
80103deb:	e8 d8 fe ff ff       	call   80103cc8 <mpsearch1>
80103df0:	83 c4 10             	add    $0x10,%esp
}
80103df3:	c9                   	leave  
80103df4:	c3                   	ret    

80103df5 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103df5:	f3 0f 1e fb          	endbr32 
80103df9:	55                   	push   %ebp
80103dfa:	89 e5                	mov    %esp,%ebp
80103dfc:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103dff:	e8 31 ff ff ff       	call   80103d35 <mpsearch>
80103e04:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e07:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e0b:	74 0a                	je     80103e17 <mpconfig+0x22>
80103e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e10:	8b 40 04             	mov    0x4(%eax),%eax
80103e13:	85 c0                	test   %eax,%eax
80103e15:	75 07                	jne    80103e1e <mpconfig+0x29>
    return 0;
80103e17:	b8 00 00 00 00       	mov    $0x0,%eax
80103e1c:	eb 7a                	jmp    80103e98 <mpconfig+0xa3>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e21:	8b 40 04             	mov    0x4(%eax),%eax
80103e24:	05 00 00 00 80       	add    $0x80000000,%eax
80103e29:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103e2c:	83 ec 04             	sub    $0x4,%esp
80103e2f:	6a 04                	push   $0x4
80103e31:	68 d1 94 10 80       	push   $0x801094d1
80103e36:	ff 75 f0             	pushl  -0x10(%ebp)
80103e39:	e8 7b 17 00 00       	call   801055b9 <memcmp>
80103e3e:	83 c4 10             	add    $0x10,%esp
80103e41:	85 c0                	test   %eax,%eax
80103e43:	74 07                	je     80103e4c <mpconfig+0x57>
    return 0;
80103e45:	b8 00 00 00 00       	mov    $0x0,%eax
80103e4a:	eb 4c                	jmp    80103e98 <mpconfig+0xa3>
  if(conf->version != 1 && conf->version != 4)
80103e4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e4f:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103e53:	3c 01                	cmp    $0x1,%al
80103e55:	74 12                	je     80103e69 <mpconfig+0x74>
80103e57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e5a:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103e5e:	3c 04                	cmp    $0x4,%al
80103e60:	74 07                	je     80103e69 <mpconfig+0x74>
    return 0;
80103e62:	b8 00 00 00 00       	mov    $0x0,%eax
80103e67:	eb 2f                	jmp    80103e98 <mpconfig+0xa3>
  if(sum((uchar*)conf, conf->length) != 0)
80103e69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e6c:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103e70:	0f b7 c0             	movzwl %ax,%eax
80103e73:	83 ec 08             	sub    $0x8,%esp
80103e76:	50                   	push   %eax
80103e77:	ff 75 f0             	pushl  -0x10(%ebp)
80103e7a:	e8 0d fe ff ff       	call   80103c8c <sum>
80103e7f:	83 c4 10             	add    $0x10,%esp
80103e82:	84 c0                	test   %al,%al
80103e84:	74 07                	je     80103e8d <mpconfig+0x98>
    return 0;
80103e86:	b8 00 00 00 00       	mov    $0x0,%eax
80103e8b:	eb 0b                	jmp    80103e98 <mpconfig+0xa3>
  *pmp = mp;
80103e8d:	8b 45 08             	mov    0x8(%ebp),%eax
80103e90:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e93:	89 10                	mov    %edx,(%eax)
  return conf;
80103e95:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103e98:	c9                   	leave  
80103e99:	c3                   	ret    

80103e9a <mpinit>:

void
mpinit(void)
{
80103e9a:	f3 0f 1e fb          	endbr32 
80103e9e:	55                   	push   %ebp
80103e9f:	89 e5                	mov    %esp,%ebp
80103ea1:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103ea4:	83 ec 0c             	sub    $0xc,%esp
80103ea7:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103eaa:	50                   	push   %eax
80103eab:	e8 45 ff ff ff       	call   80103df5 <mpconfig>
80103eb0:	83 c4 10             	add    $0x10,%esp
80103eb3:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103eb6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103eba:	75 0d                	jne    80103ec9 <mpinit+0x2f>
    panic("Expect to run on an SMP");
80103ebc:	83 ec 0c             	sub    $0xc,%esp
80103ebf:	68 d6 94 10 80       	push   $0x801094d6
80103ec4:	e8 3f c7 ff ff       	call   80100608 <panic>
  ismp = 1;
80103ec9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103ed0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ed3:	8b 40 24             	mov    0x24(%eax),%eax
80103ed6:	a3 1c 47 11 80       	mov    %eax,0x8011471c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103edb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ede:	83 c0 2c             	add    $0x2c,%eax
80103ee1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ee4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ee7:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103eeb:	0f b7 d0             	movzwl %ax,%edx
80103eee:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ef1:	01 d0                	add    %edx,%eax
80103ef3:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103ef6:	e9 8c 00 00 00       	jmp    80103f87 <mpinit+0xed>
    switch(*p){
80103efb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103efe:	0f b6 00             	movzbl (%eax),%eax
80103f01:	0f b6 c0             	movzbl %al,%eax
80103f04:	83 f8 04             	cmp    $0x4,%eax
80103f07:	7f 76                	jg     80103f7f <mpinit+0xe5>
80103f09:	83 f8 03             	cmp    $0x3,%eax
80103f0c:	7d 6b                	jge    80103f79 <mpinit+0xdf>
80103f0e:	83 f8 02             	cmp    $0x2,%eax
80103f11:	74 4e                	je     80103f61 <mpinit+0xc7>
80103f13:	83 f8 02             	cmp    $0x2,%eax
80103f16:	7f 67                	jg     80103f7f <mpinit+0xe5>
80103f18:	85 c0                	test   %eax,%eax
80103f1a:	74 07                	je     80103f23 <mpinit+0x89>
80103f1c:	83 f8 01             	cmp    $0x1,%eax
80103f1f:	74 58                	je     80103f79 <mpinit+0xdf>
80103f21:	eb 5c                	jmp    80103f7f <mpinit+0xe5>
    case MPPROC:
      proc = (struct mpproc*)p;
80103f23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f26:	89 45 e0             	mov    %eax,-0x20(%ebp)
      if(ncpu < NCPU) {
80103f29:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80103f2e:	83 f8 07             	cmp    $0x7,%eax
80103f31:	7f 28                	jg     80103f5b <mpinit+0xc1>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103f33:	8b 15 a0 4d 11 80    	mov    0x80114da0,%edx
80103f39:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f3c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103f40:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80103f46:	81 c2 20 48 11 80    	add    $0x80114820,%edx
80103f4c:	88 02                	mov    %al,(%edx)
        ncpu++;
80103f4e:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80103f53:	83 c0 01             	add    $0x1,%eax
80103f56:	a3 a0 4d 11 80       	mov    %eax,0x80114da0
      }
      p += sizeof(struct mpproc);
80103f5b:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103f5f:	eb 26                	jmp    80103f87 <mpinit+0xed>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f64:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103f67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103f6a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103f6e:	a2 00 48 11 80       	mov    %al,0x80114800
      p += sizeof(struct mpioapic);
80103f73:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f77:	eb 0e                	jmp    80103f87 <mpinit+0xed>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103f79:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f7d:	eb 08                	jmp    80103f87 <mpinit+0xed>
    default:
      ismp = 0;
80103f7f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103f86:	90                   	nop
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103f87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f8a:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103f8d:	0f 82 68 ff ff ff    	jb     80103efb <mpinit+0x61>
    }
  }
  if(!ismp)
80103f93:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103f97:	75 0d                	jne    80103fa6 <mpinit+0x10c>
    panic("Didn't find a suitable machine");
80103f99:	83 ec 0c             	sub    $0xc,%esp
80103f9c:	68 f0 94 10 80       	push   $0x801094f0
80103fa1:	e8 62 c6 ff ff       	call   80100608 <panic>

  if(mp->imcrp){
80103fa6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fa9:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103fad:	84 c0                	test   %al,%al
80103faf:	74 30                	je     80103fe1 <mpinit+0x147>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103fb1:	83 ec 08             	sub    $0x8,%esp
80103fb4:	6a 70                	push   $0x70
80103fb6:	6a 22                	push   $0x22
80103fb8:	e8 ae fc ff ff       	call   80103c6b <outb>
80103fbd:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103fc0:	83 ec 0c             	sub    $0xc,%esp
80103fc3:	6a 23                	push   $0x23
80103fc5:	e8 84 fc ff ff       	call   80103c4e <inb>
80103fca:	83 c4 10             	add    $0x10,%esp
80103fcd:	83 c8 01             	or     $0x1,%eax
80103fd0:	0f b6 c0             	movzbl %al,%eax
80103fd3:	83 ec 08             	sub    $0x8,%esp
80103fd6:	50                   	push   %eax
80103fd7:	6a 23                	push   $0x23
80103fd9:	e8 8d fc ff ff       	call   80103c6b <outb>
80103fde:	83 c4 10             	add    $0x10,%esp
  }
}
80103fe1:	90                   	nop
80103fe2:	c9                   	leave  
80103fe3:	c3                   	ret    

80103fe4 <outb>:
{
80103fe4:	55                   	push   %ebp
80103fe5:	89 e5                	mov    %esp,%ebp
80103fe7:	83 ec 08             	sub    $0x8,%esp
80103fea:	8b 45 08             	mov    0x8(%ebp),%eax
80103fed:	8b 55 0c             	mov    0xc(%ebp),%edx
80103ff0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103ff4:	89 d0                	mov    %edx,%eax
80103ff6:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103ff9:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103ffd:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80104001:	ee                   	out    %al,(%dx)
}
80104002:	90                   	nop
80104003:	c9                   	leave  
80104004:	c3                   	ret    

80104005 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80104005:	f3 0f 1e fb          	endbr32 
80104009:	55                   	push   %ebp
8010400a:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
8010400c:	68 ff 00 00 00       	push   $0xff
80104011:	6a 21                	push   $0x21
80104013:	e8 cc ff ff ff       	call   80103fe4 <outb>
80104018:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
8010401b:	68 ff 00 00 00       	push   $0xff
80104020:	68 a1 00 00 00       	push   $0xa1
80104025:	e8 ba ff ff ff       	call   80103fe4 <outb>
8010402a:	83 c4 08             	add    $0x8,%esp
}
8010402d:	90                   	nop
8010402e:	c9                   	leave  
8010402f:	c3                   	ret    

80104030 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104030:	f3 0f 1e fb          	endbr32 
80104034:	55                   	push   %ebp
80104035:	89 e5                	mov    %esp,%ebp
80104037:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
8010403a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104041:	8b 45 0c             	mov    0xc(%ebp),%eax
80104044:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010404a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010404d:	8b 10                	mov    (%eax),%edx
8010404f:	8b 45 08             	mov    0x8(%ebp),%eax
80104052:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104054:	e8 bc d0 ff ff       	call   80101115 <filealloc>
80104059:	8b 55 08             	mov    0x8(%ebp),%edx
8010405c:	89 02                	mov    %eax,(%edx)
8010405e:	8b 45 08             	mov    0x8(%ebp),%eax
80104061:	8b 00                	mov    (%eax),%eax
80104063:	85 c0                	test   %eax,%eax
80104065:	0f 84 c8 00 00 00    	je     80104133 <pipealloc+0x103>
8010406b:	e8 a5 d0 ff ff       	call   80101115 <filealloc>
80104070:	8b 55 0c             	mov    0xc(%ebp),%edx
80104073:	89 02                	mov    %eax,(%edx)
80104075:	8b 45 0c             	mov    0xc(%ebp),%eax
80104078:	8b 00                	mov    (%eax),%eax
8010407a:	85 c0                	test   %eax,%eax
8010407c:	0f 84 b1 00 00 00    	je     80104133 <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104082:	e8 c4 ed ff ff       	call   80102e4b <kalloc>
80104087:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010408a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010408e:	0f 84 a2 00 00 00    	je     80104136 <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
80104094:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104097:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010409e:	00 00 00 
  p->writeopen = 1;
801040a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a4:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801040ab:	00 00 00 
  p->nwrite = 0;
801040ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b1:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801040b8:	00 00 00 
  p->nread = 0;
801040bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040be:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801040c5:	00 00 00 
  initlock(&p->lock, "pipe");
801040c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040cb:	83 ec 08             	sub    $0x8,%esp
801040ce:	68 0f 95 10 80       	push   $0x8010950f
801040d3:	50                   	push   %eax
801040d4:	e8 b0 11 00 00       	call   80105289 <initlock>
801040d9:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801040dc:	8b 45 08             	mov    0x8(%ebp),%eax
801040df:	8b 00                	mov    (%eax),%eax
801040e1:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801040e7:	8b 45 08             	mov    0x8(%ebp),%eax
801040ea:	8b 00                	mov    (%eax),%eax
801040ec:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801040f0:	8b 45 08             	mov    0x8(%ebp),%eax
801040f3:	8b 00                	mov    (%eax),%eax
801040f5:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801040f9:	8b 45 08             	mov    0x8(%ebp),%eax
801040fc:	8b 00                	mov    (%eax),%eax
801040fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104101:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104104:	8b 45 0c             	mov    0xc(%ebp),%eax
80104107:	8b 00                	mov    (%eax),%eax
80104109:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010410f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104112:	8b 00                	mov    (%eax),%eax
80104114:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104118:	8b 45 0c             	mov    0xc(%ebp),%eax
8010411b:	8b 00                	mov    (%eax),%eax
8010411d:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104121:	8b 45 0c             	mov    0xc(%ebp),%eax
80104124:	8b 00                	mov    (%eax),%eax
80104126:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104129:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
8010412c:	b8 00 00 00 00       	mov    $0x0,%eax
80104131:	eb 51                	jmp    80104184 <pipealloc+0x154>
    goto bad;
80104133:	90                   	nop
80104134:	eb 01                	jmp    80104137 <pipealloc+0x107>
    goto bad;
80104136:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80104137:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010413b:	74 0e                	je     8010414b <pipealloc+0x11b>
    kfree((char*)p);
8010413d:	83 ec 0c             	sub    $0xc,%esp
80104140:	ff 75 f4             	pushl  -0xc(%ebp)
80104143:	e8 65 ec ff ff       	call   80102dad <kfree>
80104148:	83 c4 10             	add    $0x10,%esp
  if(*f0)
8010414b:	8b 45 08             	mov    0x8(%ebp),%eax
8010414e:	8b 00                	mov    (%eax),%eax
80104150:	85 c0                	test   %eax,%eax
80104152:	74 11                	je     80104165 <pipealloc+0x135>
    fileclose(*f0);
80104154:	8b 45 08             	mov    0x8(%ebp),%eax
80104157:	8b 00                	mov    (%eax),%eax
80104159:	83 ec 0c             	sub    $0xc,%esp
8010415c:	50                   	push   %eax
8010415d:	e8 79 d0 ff ff       	call   801011db <fileclose>
80104162:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104165:	8b 45 0c             	mov    0xc(%ebp),%eax
80104168:	8b 00                	mov    (%eax),%eax
8010416a:	85 c0                	test   %eax,%eax
8010416c:	74 11                	je     8010417f <pipealloc+0x14f>
    fileclose(*f1);
8010416e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104171:	8b 00                	mov    (%eax),%eax
80104173:	83 ec 0c             	sub    $0xc,%esp
80104176:	50                   	push   %eax
80104177:	e8 5f d0 ff ff       	call   801011db <fileclose>
8010417c:	83 c4 10             	add    $0x10,%esp
  return -1;
8010417f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104184:	c9                   	leave  
80104185:	c3                   	ret    

80104186 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104186:	f3 0f 1e fb          	endbr32 
8010418a:	55                   	push   %ebp
8010418b:	89 e5                	mov    %esp,%ebp
8010418d:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80104190:	8b 45 08             	mov    0x8(%ebp),%eax
80104193:	83 ec 0c             	sub    $0xc,%esp
80104196:	50                   	push   %eax
80104197:	e8 13 11 00 00       	call   801052af <acquire>
8010419c:	83 c4 10             	add    $0x10,%esp
  if(writable){
8010419f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801041a3:	74 23                	je     801041c8 <pipeclose+0x42>
    p->writeopen = 0;
801041a5:	8b 45 08             	mov    0x8(%ebp),%eax
801041a8:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801041af:	00 00 00 
    wakeup(&p->nread);
801041b2:	8b 45 08             	mov    0x8(%ebp),%eax
801041b5:	05 34 02 00 00       	add    $0x234,%eax
801041ba:	83 ec 0c             	sub    $0xc,%esp
801041bd:	50                   	push   %eax
801041be:	e8 6c 0d 00 00       	call   80104f2f <wakeup>
801041c3:	83 c4 10             	add    $0x10,%esp
801041c6:	eb 21                	jmp    801041e9 <pipeclose+0x63>
  } else {
    p->readopen = 0;
801041c8:	8b 45 08             	mov    0x8(%ebp),%eax
801041cb:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801041d2:	00 00 00 
    wakeup(&p->nwrite);
801041d5:	8b 45 08             	mov    0x8(%ebp),%eax
801041d8:	05 38 02 00 00       	add    $0x238,%eax
801041dd:	83 ec 0c             	sub    $0xc,%esp
801041e0:	50                   	push   %eax
801041e1:	e8 49 0d 00 00       	call   80104f2f <wakeup>
801041e6:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
801041e9:	8b 45 08             	mov    0x8(%ebp),%eax
801041ec:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041f2:	85 c0                	test   %eax,%eax
801041f4:	75 2c                	jne    80104222 <pipeclose+0x9c>
801041f6:	8b 45 08             	mov    0x8(%ebp),%eax
801041f9:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801041ff:	85 c0                	test   %eax,%eax
80104201:	75 1f                	jne    80104222 <pipeclose+0x9c>
    release(&p->lock);
80104203:	8b 45 08             	mov    0x8(%ebp),%eax
80104206:	83 ec 0c             	sub    $0xc,%esp
80104209:	50                   	push   %eax
8010420a:	e8 12 11 00 00       	call   80105321 <release>
8010420f:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104212:	83 ec 0c             	sub    $0xc,%esp
80104215:	ff 75 08             	pushl  0x8(%ebp)
80104218:	e8 90 eb ff ff       	call   80102dad <kfree>
8010421d:	83 c4 10             	add    $0x10,%esp
80104220:	eb 10                	jmp    80104232 <pipeclose+0xac>
  } else
    release(&p->lock);
80104222:	8b 45 08             	mov    0x8(%ebp),%eax
80104225:	83 ec 0c             	sub    $0xc,%esp
80104228:	50                   	push   %eax
80104229:	e8 f3 10 00 00       	call   80105321 <release>
8010422e:	83 c4 10             	add    $0x10,%esp
}
80104231:	90                   	nop
80104232:	90                   	nop
80104233:	c9                   	leave  
80104234:	c3                   	ret    

80104235 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104235:	f3 0f 1e fb          	endbr32 
80104239:	55                   	push   %ebp
8010423a:	89 e5                	mov    %esp,%ebp
8010423c:	53                   	push   %ebx
8010423d:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104240:	8b 45 08             	mov    0x8(%ebp),%eax
80104243:	83 ec 0c             	sub    $0xc,%esp
80104246:	50                   	push   %eax
80104247:	e8 63 10 00 00       	call   801052af <acquire>
8010424c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
8010424f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104256:	e9 ad 00 00 00       	jmp    80104308 <pipewrite+0xd3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
8010425b:	8b 45 08             	mov    0x8(%ebp),%eax
8010425e:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104264:	85 c0                	test   %eax,%eax
80104266:	74 0c                	je     80104274 <pipewrite+0x3f>
80104268:	e8 a2 02 00 00       	call   8010450f <myproc>
8010426d:	8b 40 24             	mov    0x24(%eax),%eax
80104270:	85 c0                	test   %eax,%eax
80104272:	74 19                	je     8010428d <pipewrite+0x58>
        release(&p->lock);
80104274:	8b 45 08             	mov    0x8(%ebp),%eax
80104277:	83 ec 0c             	sub    $0xc,%esp
8010427a:	50                   	push   %eax
8010427b:	e8 a1 10 00 00       	call   80105321 <release>
80104280:	83 c4 10             	add    $0x10,%esp
        return -1;
80104283:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104288:	e9 a9 00 00 00       	jmp    80104336 <pipewrite+0x101>
      }
      wakeup(&p->nread);
8010428d:	8b 45 08             	mov    0x8(%ebp),%eax
80104290:	05 34 02 00 00       	add    $0x234,%eax
80104295:	83 ec 0c             	sub    $0xc,%esp
80104298:	50                   	push   %eax
80104299:	e8 91 0c 00 00       	call   80104f2f <wakeup>
8010429e:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801042a1:	8b 45 08             	mov    0x8(%ebp),%eax
801042a4:	8b 55 08             	mov    0x8(%ebp),%edx
801042a7:	81 c2 38 02 00 00    	add    $0x238,%edx
801042ad:	83 ec 08             	sub    $0x8,%esp
801042b0:	50                   	push   %eax
801042b1:	52                   	push   %edx
801042b2:	e8 86 0b 00 00       	call   80104e3d <sleep>
801042b7:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801042ba:	8b 45 08             	mov    0x8(%ebp),%eax
801042bd:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801042c3:	8b 45 08             	mov    0x8(%ebp),%eax
801042c6:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801042cc:	05 00 02 00 00       	add    $0x200,%eax
801042d1:	39 c2                	cmp    %eax,%edx
801042d3:	74 86                	je     8010425b <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801042d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801042db:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801042de:	8b 45 08             	mov    0x8(%ebp),%eax
801042e1:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042e7:	8d 48 01             	lea    0x1(%eax),%ecx
801042ea:	8b 55 08             	mov    0x8(%ebp),%edx
801042ed:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801042f3:	25 ff 01 00 00       	and    $0x1ff,%eax
801042f8:	89 c1                	mov    %eax,%ecx
801042fa:	0f b6 13             	movzbl (%ebx),%edx
801042fd:	8b 45 08             	mov    0x8(%ebp),%eax
80104300:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80104304:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010430b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010430e:	7c aa                	jl     801042ba <pipewrite+0x85>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104310:	8b 45 08             	mov    0x8(%ebp),%eax
80104313:	05 34 02 00 00       	add    $0x234,%eax
80104318:	83 ec 0c             	sub    $0xc,%esp
8010431b:	50                   	push   %eax
8010431c:	e8 0e 0c 00 00       	call   80104f2f <wakeup>
80104321:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104324:	8b 45 08             	mov    0x8(%ebp),%eax
80104327:	83 ec 0c             	sub    $0xc,%esp
8010432a:	50                   	push   %eax
8010432b:	e8 f1 0f 00 00       	call   80105321 <release>
80104330:	83 c4 10             	add    $0x10,%esp
  return n;
80104333:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104336:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104339:	c9                   	leave  
8010433a:	c3                   	ret    

8010433b <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010433b:	f3 0f 1e fb          	endbr32 
8010433f:	55                   	push   %ebp
80104340:	89 e5                	mov    %esp,%ebp
80104342:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104345:	8b 45 08             	mov    0x8(%ebp),%eax
80104348:	83 ec 0c             	sub    $0xc,%esp
8010434b:	50                   	push   %eax
8010434c:	e8 5e 0f 00 00       	call   801052af <acquire>
80104351:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104354:	eb 3e                	jmp    80104394 <piperead+0x59>
    if(myproc()->killed){
80104356:	e8 b4 01 00 00       	call   8010450f <myproc>
8010435b:	8b 40 24             	mov    0x24(%eax),%eax
8010435e:	85 c0                	test   %eax,%eax
80104360:	74 19                	je     8010437b <piperead+0x40>
      release(&p->lock);
80104362:	8b 45 08             	mov    0x8(%ebp),%eax
80104365:	83 ec 0c             	sub    $0xc,%esp
80104368:	50                   	push   %eax
80104369:	e8 b3 0f 00 00       	call   80105321 <release>
8010436e:	83 c4 10             	add    $0x10,%esp
      return -1;
80104371:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104376:	e9 be 00 00 00       	jmp    80104439 <piperead+0xfe>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010437b:	8b 45 08             	mov    0x8(%ebp),%eax
8010437e:	8b 55 08             	mov    0x8(%ebp),%edx
80104381:	81 c2 34 02 00 00    	add    $0x234,%edx
80104387:	83 ec 08             	sub    $0x8,%esp
8010438a:	50                   	push   %eax
8010438b:	52                   	push   %edx
8010438c:	e8 ac 0a 00 00       	call   80104e3d <sleep>
80104391:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104394:	8b 45 08             	mov    0x8(%ebp),%eax
80104397:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010439d:	8b 45 08             	mov    0x8(%ebp),%eax
801043a0:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043a6:	39 c2                	cmp    %eax,%edx
801043a8:	75 0d                	jne    801043b7 <piperead+0x7c>
801043aa:	8b 45 08             	mov    0x8(%ebp),%eax
801043ad:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801043b3:	85 c0                	test   %eax,%eax
801043b5:	75 9f                	jne    80104356 <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801043b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801043be:	eb 48                	jmp    80104408 <piperead+0xcd>
    if(p->nread == p->nwrite)
801043c0:	8b 45 08             	mov    0x8(%ebp),%eax
801043c3:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801043c9:	8b 45 08             	mov    0x8(%ebp),%eax
801043cc:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043d2:	39 c2                	cmp    %eax,%edx
801043d4:	74 3c                	je     80104412 <piperead+0xd7>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801043d6:	8b 45 08             	mov    0x8(%ebp),%eax
801043d9:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801043df:	8d 48 01             	lea    0x1(%eax),%ecx
801043e2:	8b 55 08             	mov    0x8(%ebp),%edx
801043e5:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801043eb:	25 ff 01 00 00       	and    $0x1ff,%eax
801043f0:	89 c1                	mov    %eax,%ecx
801043f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801043f8:	01 c2                	add    %eax,%edx
801043fa:	8b 45 08             	mov    0x8(%ebp),%eax
801043fd:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80104402:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104404:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104408:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010440b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010440e:	7c b0                	jl     801043c0 <piperead+0x85>
80104410:	eb 01                	jmp    80104413 <piperead+0xd8>
      break;
80104412:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104413:	8b 45 08             	mov    0x8(%ebp),%eax
80104416:	05 38 02 00 00       	add    $0x238,%eax
8010441b:	83 ec 0c             	sub    $0xc,%esp
8010441e:	50                   	push   %eax
8010441f:	e8 0b 0b 00 00       	call   80104f2f <wakeup>
80104424:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104427:	8b 45 08             	mov    0x8(%ebp),%eax
8010442a:	83 ec 0c             	sub    $0xc,%esp
8010442d:	50                   	push   %eax
8010442e:	e8 ee 0e 00 00       	call   80105321 <release>
80104433:	83 c4 10             	add    $0x10,%esp
  return i;
80104436:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104439:	c9                   	leave  
8010443a:	c3                   	ret    

8010443b <readeflags>:
{
8010443b:	55                   	push   %ebp
8010443c:	89 e5                	mov    %esp,%ebp
8010443e:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104441:	9c                   	pushf  
80104442:	58                   	pop    %eax
80104443:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104446:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104449:	c9                   	leave  
8010444a:	c3                   	ret    

8010444b <sti>:
{
8010444b:	55                   	push   %ebp
8010444c:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010444e:	fb                   	sti    
}
8010444f:	90                   	nop
80104450:	5d                   	pop    %ebp
80104451:	c3                   	ret    

80104452 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104452:	f3 0f 1e fb          	endbr32 
80104456:	55                   	push   %ebp
80104457:	89 e5                	mov    %esp,%ebp
80104459:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
8010445c:	83 ec 08             	sub    $0x8,%esp
8010445f:	68 14 95 10 80       	push   $0x80109514
80104464:	68 c0 4d 11 80       	push   $0x80114dc0
80104469:	e8 1b 0e 00 00       	call   80105289 <initlock>
8010446e:	83 c4 10             	add    $0x10,%esp
}
80104471:	90                   	nop
80104472:	c9                   	leave  
80104473:	c3                   	ret    

80104474 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80104474:	f3 0f 1e fb          	endbr32 
80104478:	55                   	push   %ebp
80104479:	89 e5                	mov    %esp,%ebp
8010447b:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
8010447e:	e8 10 00 00 00       	call   80104493 <mycpu>
80104483:	2d 20 48 11 80       	sub    $0x80114820,%eax
80104488:	c1 f8 04             	sar    $0x4,%eax
8010448b:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80104491:	c9                   	leave  
80104492:	c3                   	ret    

80104493 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80104493:	f3 0f 1e fb          	endbr32 
80104497:	55                   	push   %ebp
80104498:	89 e5                	mov    %esp,%ebp
8010449a:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
8010449d:	e8 99 ff ff ff       	call   8010443b <readeflags>
801044a2:	25 00 02 00 00       	and    $0x200,%eax
801044a7:	85 c0                	test   %eax,%eax
801044a9:	74 0d                	je     801044b8 <mycpu+0x25>
    panic("mycpu called with interrupts enabled\n");
801044ab:	83 ec 0c             	sub    $0xc,%esp
801044ae:	68 1c 95 10 80       	push   $0x8010951c
801044b3:	e8 50 c1 ff ff       	call   80100608 <panic>
  
  apicid = lapicid();
801044b8:	e8 21 ed ff ff       	call   801031de <lapicid>
801044bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801044c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801044c7:	eb 2d                	jmp    801044f6 <mycpu+0x63>
    if (cpus[i].apicid == apicid)
801044c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044cc:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801044d2:	05 20 48 11 80       	add    $0x80114820,%eax
801044d7:	0f b6 00             	movzbl (%eax),%eax
801044da:	0f b6 c0             	movzbl %al,%eax
801044dd:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801044e0:	75 10                	jne    801044f2 <mycpu+0x5f>
      return &cpus[i];
801044e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e5:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801044eb:	05 20 48 11 80       	add    $0x80114820,%eax
801044f0:	eb 1b                	jmp    8010450d <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
801044f2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801044f6:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
801044fb:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801044fe:	7c c9                	jl     801044c9 <mycpu+0x36>
  }
  panic("unknown apicid\n");
80104500:	83 ec 0c             	sub    $0xc,%esp
80104503:	68 42 95 10 80       	push   $0x80109542
80104508:	e8 fb c0 ff ff       	call   80100608 <panic>
}
8010450d:	c9                   	leave  
8010450e:	c3                   	ret    

8010450f <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
8010450f:	f3 0f 1e fb          	endbr32 
80104513:	55                   	push   %ebp
80104514:	89 e5                	mov    %esp,%ebp
80104516:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80104519:	e8 1d 0f 00 00       	call   8010543b <pushcli>
  c = mycpu();
8010451e:	e8 70 ff ff ff       	call   80104493 <mycpu>
80104523:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80104526:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104529:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010452f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80104532:	e8 55 0f 00 00       	call   8010548c <popcli>
  return p;
80104537:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010453a:	c9                   	leave  
8010453b:	c3                   	ret    

8010453c <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010453c:	f3 0f 1e fb          	endbr32 
80104540:	55                   	push   %ebp
80104541:	89 e5                	mov    %esp,%ebp
80104543:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104546:	83 ec 0c             	sub    $0xc,%esp
80104549:	68 c0 4d 11 80       	push   $0x80114dc0
8010454e:	e8 5c 0d 00 00       	call   801052af <acquire>
80104553:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104556:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
8010455d:	eb 11                	jmp    80104570 <allocproc+0x34>
    if(p->state == UNUSED)
8010455f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104562:	8b 40 0c             	mov    0xc(%eax),%eax
80104565:	85 c0                	test   %eax,%eax
80104567:	74 2a                	je     80104593 <allocproc+0x57>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104569:	81 45 f4 a4 00 00 00 	addl   $0xa4,-0xc(%ebp)
80104570:	81 7d f4 f4 76 11 80 	cmpl   $0x801176f4,-0xc(%ebp)
80104577:	72 e6                	jb     8010455f <allocproc+0x23>
      goto found;

  release(&ptable.lock);
80104579:	83 ec 0c             	sub    $0xc,%esp
8010457c:	68 c0 4d 11 80       	push   $0x80114dc0
80104581:	e8 9b 0d 00 00       	call   80105321 <release>
80104586:	83 c4 10             	add    $0x10,%esp
  return 0;
80104589:	b8 00 00 00 00       	mov    $0x0,%eax
8010458e:	e9 b6 00 00 00       	jmp    80104649 <allocproc+0x10d>
      goto found;
80104593:	90                   	nop
80104594:	f3 0f 1e fb          	endbr32 

found:
  p->state = EMBRYO;
80104598:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010459b:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801045a2:	a1 00 c0 10 80       	mov    0x8010c000,%eax
801045a7:	8d 50 01             	lea    0x1(%eax),%edx
801045aa:	89 15 00 c0 10 80    	mov    %edx,0x8010c000
801045b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045b3:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
801045b6:	83 ec 0c             	sub    $0xc,%esp
801045b9:	68 c0 4d 11 80       	push   $0x80114dc0
801045be:	e8 5e 0d 00 00       	call   80105321 <release>
801045c3:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801045c6:	e8 80 e8 ff ff       	call   80102e4b <kalloc>
801045cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045ce:	89 42 08             	mov    %eax,0x8(%edx)
801045d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d4:	8b 40 08             	mov    0x8(%eax),%eax
801045d7:	85 c0                	test   %eax,%eax
801045d9:	75 11                	jne    801045ec <allocproc+0xb0>
    p->state = UNUSED;
801045db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045de:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801045e5:	b8 00 00 00 00       	mov    $0x0,%eax
801045ea:	eb 5d                	jmp    80104649 <allocproc+0x10d>
  }
  sp = p->kstack + KSTACKSIZE;
801045ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ef:	8b 40 08             	mov    0x8(%eax),%eax
801045f2:	05 00 10 00 00       	add    $0x1000,%eax
801045f7:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801045fa:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801045fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104601:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104604:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104607:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010460b:	ba c4 6a 10 80       	mov    $0x80106ac4,%edx
80104610:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104613:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104615:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104619:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010461c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010461f:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104622:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104625:	8b 40 1c             	mov    0x1c(%eax),%eax
80104628:	83 ec 04             	sub    $0x4,%esp
8010462b:	6a 14                	push   $0x14
8010462d:	6a 00                	push   $0x0
8010462f:	50                   	push   %eax
80104630:	e8 19 0f 00 00       	call   8010554e <memset>
80104635:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104638:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010463b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010463e:	ba f3 4d 10 80       	mov    $0x80104df3,%edx
80104643:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104646:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104649:	c9                   	leave  
8010464a:	c3                   	ret    

8010464b <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010464b:	f3 0f 1e fb          	endbr32 
8010464f:	55                   	push   %ebp
80104650:	89 e5                	mov    %esp,%ebp
80104652:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80104655:	e8 e2 fe ff ff       	call   8010453c <allocproc>
8010465a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
8010465d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104660:	a3 40 c6 10 80       	mov    %eax,0x8010c640
  if((p->pgdir = setupkvm()) == 0)
80104665:	e8 2a 3a 00 00       	call   80108094 <setupkvm>
8010466a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010466d:	89 42 04             	mov    %eax,0x4(%edx)
80104670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104673:	8b 40 04             	mov    0x4(%eax),%eax
80104676:	85 c0                	test   %eax,%eax
80104678:	75 0d                	jne    80104687 <userinit+0x3c>
    panic("userinit: out of memory?");
8010467a:	83 ec 0c             	sub    $0xc,%esp
8010467d:	68 52 95 10 80       	push   $0x80109552
80104682:	e8 81 bf ff ff       	call   80100608 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104687:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010468c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010468f:	8b 40 04             	mov    0x4(%eax),%eax
80104692:	83 ec 04             	sub    $0x4,%esp
80104695:	52                   	push   %edx
80104696:	68 e0 c4 10 80       	push   $0x8010c4e0
8010469b:	50                   	push   %eax
8010469c:	e8 6c 3c 00 00       	call   8010830d <inituvm>
801046a1:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
801046a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a7:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801046ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b0:	8b 40 18             	mov    0x18(%eax),%eax
801046b3:	83 ec 04             	sub    $0x4,%esp
801046b6:	6a 4c                	push   $0x4c
801046b8:	6a 00                	push   $0x0
801046ba:	50                   	push   %eax
801046bb:	e8 8e 0e 00 00       	call   8010554e <memset>
801046c0:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801046c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c6:	8b 40 18             	mov    0x18(%eax),%eax
801046c9:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801046cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d2:	8b 40 18             	mov    0x18(%eax),%eax
801046d5:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801046db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046de:	8b 50 18             	mov    0x18(%eax),%edx
801046e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e4:	8b 40 18             	mov    0x18(%eax),%eax
801046e7:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801046eb:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801046ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f2:	8b 50 18             	mov    0x18(%eax),%edx
801046f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f8:	8b 40 18             	mov    0x18(%eax),%eax
801046fb:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801046ff:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104703:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104706:	8b 40 18             	mov    0x18(%eax),%eax
80104709:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104710:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104713:	8b 40 18             	mov    0x18(%eax),%eax
80104716:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010471d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104720:	8b 40 18             	mov    0x18(%eax),%eax
80104723:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010472a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010472d:	83 c0 6c             	add    $0x6c,%eax
80104730:	83 ec 04             	sub    $0x4,%esp
80104733:	6a 10                	push   $0x10
80104735:	68 6b 95 10 80       	push   $0x8010956b
8010473a:	50                   	push   %eax
8010473b:	e8 29 10 00 00       	call   80105769 <safestrcpy>
80104740:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104743:	83 ec 0c             	sub    $0xc,%esp
80104746:	68 74 95 10 80       	push   $0x80109574
8010474b:	e8 76 df ff ff       	call   801026c6 <namei>
80104750:	83 c4 10             	add    $0x10,%esp
80104753:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104756:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80104759:	83 ec 0c             	sub    $0xc,%esp
8010475c:	68 c0 4d 11 80       	push   $0x80114dc0
80104761:	e8 49 0b 00 00       	call   801052af <acquire>
80104766:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80104769:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010476c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104773:	83 ec 0c             	sub    $0xc,%esp
80104776:	68 c0 4d 11 80       	push   $0x80114dc0
8010477b:	e8 a1 0b 00 00       	call   80105321 <release>
80104780:	83 c4 10             	add    $0x10,%esp
}
80104783:	90                   	nop
80104784:	c9                   	leave  
80104785:	c3                   	ret    

80104786 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104786:	f3 0f 1e fb          	endbr32 
8010478a:	55                   	push   %ebp
8010478b:	89 e5                	mov    %esp,%ebp
8010478d:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80104790:	e8 7a fd ff ff       	call   8010450f <myproc>
80104795:	89 45 ec             	mov    %eax,-0x14(%ebp)

  sz = curproc->sz;
80104798:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010479b:	8b 00                	mov    (%eax),%eax
8010479d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801047a0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801047a4:	7e 77                	jle    8010481d <growproc+0x97>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801047a6:	8b 55 08             	mov    0x8(%ebp),%edx
801047a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ac:	01 c2                	add    %eax,%edx
801047ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047b1:	8b 40 04             	mov    0x4(%eax),%eax
801047b4:	83 ec 04             	sub    $0x4,%esp
801047b7:	52                   	push   %edx
801047b8:	ff 75 f4             	pushl  -0xc(%ebp)
801047bb:	50                   	push   %eax
801047bc:	e8 91 3c 00 00       	call   80108452 <allocuvm>
801047c1:	83 c4 10             	add    $0x10,%esp
801047c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801047c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047cb:	75 0a                	jne    801047d7 <growproc+0x51>
      return -1;
801047cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047d2:	e9 95 00 00 00       	jmp    8010486c <growproc+0xe6>
   
    /*uint a;
    a = PGROUNDUP(sz);
    mencrypt((char*)a, a/PGSIZE);*/

  int t = sz/PGSIZE;
801047d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047da:	c1 e8 0c             	shr    $0xc,%eax
801047dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if (sz%PGSIZE)
801047e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e3:	25 ff 0f 00 00       	and    $0xfff,%eax
801047e8:	85 c0                	test   %eax,%eax
801047ea:	74 04                	je     801047f0 <growproc+0x6a>
    t++;
801047ec:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  mencrypt(0,t-2);
801047f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047f3:	83 e8 02             	sub    $0x2,%eax
801047f6:	83 ec 08             	sub    $0x8,%esp
801047f9:	50                   	push   %eax
801047fa:	6a 00                	push   $0x0
801047fc:	e8 c6 44 00 00       	call   80108cc7 <mencrypt>
80104801:	83 c4 10             	add    $0x10,%esp
  mencrypt((char*)((t-1)*PGSIZE),1);
80104804:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104807:	83 e8 01             	sub    $0x1,%eax
8010480a:	c1 e0 0c             	shl    $0xc,%eax
8010480d:	83 ec 08             	sub    $0x8,%esp
80104810:	6a 01                	push   $0x1
80104812:	50                   	push   %eax
80104813:	e8 af 44 00 00       	call   80108cc7 <mencrypt>
80104818:	83 c4 10             	add    $0x10,%esp
8010481b:	eb 34                	jmp    80104851 <growproc+0xcb>

  } else if(n < 0){
8010481d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104821:	79 2e                	jns    80104851 <growproc+0xcb>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104823:	8b 55 08             	mov    0x8(%ebp),%edx
80104826:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104829:	01 c2                	add    %eax,%edx
8010482b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010482e:	8b 40 04             	mov    0x4(%eax),%eax
80104831:	83 ec 04             	sub    $0x4,%esp
80104834:	52                   	push   %edx
80104835:	ff 75 f4             	pushl  -0xc(%ebp)
80104838:	50                   	push   %eax
80104839:	e8 1d 3d 00 00       	call   8010855b <deallocuvm>
8010483e:	83 c4 10             	add    $0x10,%esp
80104841:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104844:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104848:	75 07                	jne    80104851 <growproc+0xcb>
      return -1;
8010484a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010484f:	eb 1b                	jmp    8010486c <growproc+0xe6>
  }
  curproc->sz = sz;
80104851:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104854:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104857:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80104859:	83 ec 0c             	sub    $0xc,%esp
8010485c:	ff 75 ec             	pushl  -0x14(%ebp)
8010485f:	e8 06 39 00 00       	call   8010816a <switchuvm>
80104864:	83 c4 10             	add    $0x10,%esp
  return 0;
80104867:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010486c:	c9                   	leave  
8010486d:	c3                   	ret    

8010486e <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010486e:	f3 0f 1e fb          	endbr32 
80104872:	55                   	push   %ebp
80104873:	89 e5                	mov    %esp,%ebp
80104875:	57                   	push   %edi
80104876:	56                   	push   %esi
80104877:	53                   	push   %ebx
80104878:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
8010487b:	e8 8f fc ff ff       	call   8010450f <myproc>
80104880:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80104883:	e8 b4 fc ff ff       	call   8010453c <allocproc>
80104888:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010488b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
8010488f:	75 0a                	jne    8010489b <fork+0x2d>
    return -1;
80104891:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104896:	e9 48 01 00 00       	jmp    801049e3 <fork+0x175>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
8010489b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010489e:	8b 10                	mov    (%eax),%edx
801048a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048a3:	8b 40 04             	mov    0x4(%eax),%eax
801048a6:	83 ec 08             	sub    $0x8,%esp
801048a9:	52                   	push   %edx
801048aa:	50                   	push   %eax
801048ab:	e8 59 3e 00 00       	call   80108709 <copyuvm>
801048b0:	83 c4 10             	add    $0x10,%esp
801048b3:	8b 55 dc             	mov    -0x24(%ebp),%edx
801048b6:	89 42 04             	mov    %eax,0x4(%edx)
801048b9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048bc:	8b 40 04             	mov    0x4(%eax),%eax
801048bf:	85 c0                	test   %eax,%eax
801048c1:	75 30                	jne    801048f3 <fork+0x85>
    kfree(np->kstack);
801048c3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048c6:	8b 40 08             	mov    0x8(%eax),%eax
801048c9:	83 ec 0c             	sub    $0xc,%esp
801048cc:	50                   	push   %eax
801048cd:	e8 db e4 ff ff       	call   80102dad <kfree>
801048d2:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801048d5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048d8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801048df:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048e2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801048e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048ee:	e9 f0 00 00 00       	jmp    801049e3 <fork+0x175>
  }
  np->sz = curproc->sz;
801048f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048f6:	8b 10                	mov    (%eax),%edx
801048f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048fb:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
801048fd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104900:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104903:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80104906:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104909:	8b 48 18             	mov    0x18(%eax),%ecx
8010490c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010490f:	8b 40 18             	mov    0x18(%eax),%eax
80104912:	89 c2                	mov    %eax,%edx
80104914:	89 cb                	mov    %ecx,%ebx
80104916:	b8 13 00 00 00       	mov    $0x13,%eax
8010491b:	89 d7                	mov    %edx,%edi
8010491d:	89 de                	mov    %ebx,%esi
8010491f:	89 c1                	mov    %eax,%ecx
80104921:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104923:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104926:	8b 40 18             	mov    0x18(%eax),%eax
80104929:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104930:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104937:	eb 3b                	jmp    80104974 <fork+0x106>
    if(curproc->ofile[i])
80104939:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010493c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010493f:	83 c2 08             	add    $0x8,%edx
80104942:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104946:	85 c0                	test   %eax,%eax
80104948:	74 26                	je     80104970 <fork+0x102>
      np->ofile[i] = filedup(curproc->ofile[i]);
8010494a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010494d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104950:	83 c2 08             	add    $0x8,%edx
80104953:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104957:	83 ec 0c             	sub    $0xc,%esp
8010495a:	50                   	push   %eax
8010495b:	e8 26 c8 ff ff       	call   80101186 <filedup>
80104960:	83 c4 10             	add    $0x10,%esp
80104963:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104966:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104969:	83 c1 08             	add    $0x8,%ecx
8010496c:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80104970:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104974:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104978:	7e bf                	jle    80104939 <fork+0xcb>
  np->cwd = idup(curproc->cwd);
8010497a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010497d:	8b 40 68             	mov    0x68(%eax),%eax
80104980:	83 ec 0c             	sub    $0xc,%esp
80104983:	50                   	push   %eax
80104984:	e8 94 d1 ff ff       	call   80101b1d <idup>
80104989:	83 c4 10             	add    $0x10,%esp
8010498c:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010498f:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104992:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104995:	8d 50 6c             	lea    0x6c(%eax),%edx
80104998:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010499b:	83 c0 6c             	add    $0x6c,%eax
8010499e:	83 ec 04             	sub    $0x4,%esp
801049a1:	6a 10                	push   $0x10
801049a3:	52                   	push   %edx
801049a4:	50                   	push   %eax
801049a5:	e8 bf 0d 00 00       	call   80105769 <safestrcpy>
801049aa:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
801049ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049b0:	8b 40 10             	mov    0x10(%eax),%eax
801049b3:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
801049b6:	83 ec 0c             	sub    $0xc,%esp
801049b9:	68 c0 4d 11 80       	push   $0x80114dc0
801049be:	e8 ec 08 00 00       	call   801052af <acquire>
801049c3:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
801049c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049c9:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801049d0:	83 ec 0c             	sub    $0xc,%esp
801049d3:	68 c0 4d 11 80       	push   $0x80114dc0
801049d8:	e8 44 09 00 00       	call   80105321 <release>
801049dd:	83 c4 10             	add    $0x10,%esp

  return pid;
801049e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
801049e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801049e6:	5b                   	pop    %ebx
801049e7:	5e                   	pop    %esi
801049e8:	5f                   	pop    %edi
801049e9:	5d                   	pop    %ebp
801049ea:	c3                   	ret    

801049eb <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801049eb:	f3 0f 1e fb          	endbr32 
801049ef:	55                   	push   %ebp
801049f0:	89 e5                	mov    %esp,%ebp
801049f2:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801049f5:	e8 15 fb ff ff       	call   8010450f <myproc>
801049fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
801049fd:	a1 40 c6 10 80       	mov    0x8010c640,%eax
80104a02:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104a05:	75 0d                	jne    80104a14 <exit+0x29>
    panic("init exiting");
80104a07:	83 ec 0c             	sub    $0xc,%esp
80104a0a:	68 76 95 10 80       	push   $0x80109576
80104a0f:	e8 f4 bb ff ff       	call   80100608 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104a14:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104a1b:	eb 3f                	jmp    80104a5c <exit+0x71>
    if(curproc->ofile[fd]){
80104a1d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a20:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a23:	83 c2 08             	add    $0x8,%edx
80104a26:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a2a:	85 c0                	test   %eax,%eax
80104a2c:	74 2a                	je     80104a58 <exit+0x6d>
      fileclose(curproc->ofile[fd]);
80104a2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a31:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a34:	83 c2 08             	add    $0x8,%edx
80104a37:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a3b:	83 ec 0c             	sub    $0xc,%esp
80104a3e:	50                   	push   %eax
80104a3f:	e8 97 c7 ff ff       	call   801011db <fileclose>
80104a44:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104a47:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a4a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a4d:	83 c2 08             	add    $0x8,%edx
80104a50:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104a57:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104a58:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104a5c:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104a60:	7e bb                	jle    80104a1d <exit+0x32>
    }
  }

  begin_op();
80104a62:	e8 e9 ec ff ff       	call   80103750 <begin_op>
  iput(curproc->cwd);
80104a67:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a6a:	8b 40 68             	mov    0x68(%eax),%eax
80104a6d:	83 ec 0c             	sub    $0xc,%esp
80104a70:	50                   	push   %eax
80104a71:	e8 4e d2 ff ff       	call   80101cc4 <iput>
80104a76:	83 c4 10             	add    $0x10,%esp
  end_op();
80104a79:	e8 62 ed ff ff       	call   801037e0 <end_op>
  curproc->cwd = 0;
80104a7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a81:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104a88:	83 ec 0c             	sub    $0xc,%esp
80104a8b:	68 c0 4d 11 80       	push   $0x80114dc0
80104a90:	e8 1a 08 00 00       	call   801052af <acquire>
80104a95:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104a98:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a9b:	8b 40 14             	mov    0x14(%eax),%eax
80104a9e:	83 ec 0c             	sub    $0xc,%esp
80104aa1:	50                   	push   %eax
80104aa2:	e8 41 04 00 00       	call   80104ee8 <wakeup1>
80104aa7:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104aaa:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104ab1:	eb 3a                	jmp    80104aed <exit+0x102>
    if(p->parent == curproc){
80104ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab6:	8b 40 14             	mov    0x14(%eax),%eax
80104ab9:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104abc:	75 28                	jne    80104ae6 <exit+0xfb>
      p->parent = initproc;
80104abe:	8b 15 40 c6 10 80    	mov    0x8010c640,%edx
80104ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac7:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104acd:	8b 40 0c             	mov    0xc(%eax),%eax
80104ad0:	83 f8 05             	cmp    $0x5,%eax
80104ad3:	75 11                	jne    80104ae6 <exit+0xfb>
        wakeup1(initproc);
80104ad5:	a1 40 c6 10 80       	mov    0x8010c640,%eax
80104ada:	83 ec 0c             	sub    $0xc,%esp
80104add:	50                   	push   %eax
80104ade:	e8 05 04 00 00       	call   80104ee8 <wakeup1>
80104ae3:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ae6:	81 45 f4 a4 00 00 00 	addl   $0xa4,-0xc(%ebp)
80104aed:	81 7d f4 f4 76 11 80 	cmpl   $0x801176f4,-0xc(%ebp)
80104af4:	72 bd                	jb     80104ab3 <exit+0xc8>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104af6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104af9:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104b00:	e8 f3 01 00 00       	call   80104cf8 <sched>
  panic("zombie exit");
80104b05:	83 ec 0c             	sub    $0xc,%esp
80104b08:	68 83 95 10 80       	push   $0x80109583
80104b0d:	e8 f6 ba ff ff       	call   80100608 <panic>

80104b12 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104b12:	f3 0f 1e fb          	endbr32 
80104b16:	55                   	push   %ebp
80104b17:	89 e5                	mov    %esp,%ebp
80104b19:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104b1c:	e8 ee f9 ff ff       	call   8010450f <myproc>
80104b21:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104b24:	83 ec 0c             	sub    $0xc,%esp
80104b27:	68 c0 4d 11 80       	push   $0x80114dc0
80104b2c:	e8 7e 07 00 00       	call   801052af <acquire>
80104b31:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104b34:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b3b:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104b42:	e9 a4 00 00 00       	jmp    80104beb <wait+0xd9>
      if(p->parent != curproc)
80104b47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b4a:	8b 40 14             	mov    0x14(%eax),%eax
80104b4d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104b50:	0f 85 8d 00 00 00    	jne    80104be3 <wait+0xd1>
        continue;
      havekids = 1;
80104b56:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104b5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b60:	8b 40 0c             	mov    0xc(%eax),%eax
80104b63:	83 f8 05             	cmp    $0x5,%eax
80104b66:	75 7c                	jne    80104be4 <wait+0xd2>
        // Found one.
        pid = p->pid;
80104b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b6b:	8b 40 10             	mov    0x10(%eax),%eax
80104b6e:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b74:	8b 40 08             	mov    0x8(%eax),%eax
80104b77:	83 ec 0c             	sub    $0xc,%esp
80104b7a:	50                   	push   %eax
80104b7b:	e8 2d e2 ff ff       	call   80102dad <kfree>
80104b80:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104b83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b86:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b90:	8b 40 04             	mov    0x4(%eax),%eax
80104b93:	83 ec 0c             	sub    $0xc,%esp
80104b96:	50                   	push   %eax
80104b97:	e8 89 3a 00 00       	call   80108625 <freevm>
80104b9c:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba2:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bac:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb6:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bbd:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104bce:	83 ec 0c             	sub    $0xc,%esp
80104bd1:	68 c0 4d 11 80       	push   $0x80114dc0
80104bd6:	e8 46 07 00 00       	call   80105321 <release>
80104bdb:	83 c4 10             	add    $0x10,%esp
        return pid;
80104bde:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104be1:	eb 54                	jmp    80104c37 <wait+0x125>
        continue;
80104be3:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104be4:	81 45 f4 a4 00 00 00 	addl   $0xa4,-0xc(%ebp)
80104beb:	81 7d f4 f4 76 11 80 	cmpl   $0x801176f4,-0xc(%ebp)
80104bf2:	0f 82 4f ff ff ff    	jb     80104b47 <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104bf8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104bfc:	74 0a                	je     80104c08 <wait+0xf6>
80104bfe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c01:	8b 40 24             	mov    0x24(%eax),%eax
80104c04:	85 c0                	test   %eax,%eax
80104c06:	74 17                	je     80104c1f <wait+0x10d>
      release(&ptable.lock);
80104c08:	83 ec 0c             	sub    $0xc,%esp
80104c0b:	68 c0 4d 11 80       	push   $0x80114dc0
80104c10:	e8 0c 07 00 00       	call   80105321 <release>
80104c15:	83 c4 10             	add    $0x10,%esp
      return -1;
80104c18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c1d:	eb 18                	jmp    80104c37 <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104c1f:	83 ec 08             	sub    $0x8,%esp
80104c22:	68 c0 4d 11 80       	push   $0x80114dc0
80104c27:	ff 75 ec             	pushl  -0x14(%ebp)
80104c2a:	e8 0e 02 00 00       	call   80104e3d <sleep>
80104c2f:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104c32:	e9 fd fe ff ff       	jmp    80104b34 <wait+0x22>
  }
}
80104c37:	c9                   	leave  
80104c38:	c3                   	ret    

80104c39 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104c39:	f3 0f 1e fb          	endbr32 
80104c3d:	55                   	push   %ebp
80104c3e:	89 e5                	mov    %esp,%ebp
80104c40:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104c43:	e8 4b f8 ff ff       	call   80104493 <mycpu>
80104c48:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104c4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c4e:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104c55:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104c58:	e8 ee f7 ff ff       	call   8010444b <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104c5d:	83 ec 0c             	sub    $0xc,%esp
80104c60:	68 c0 4d 11 80       	push   $0x80114dc0
80104c65:	e8 45 06 00 00       	call   801052af <acquire>
80104c6a:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c6d:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104c74:	eb 64                	jmp    80104cda <scheduler+0xa1>
      if(p->state != RUNNABLE)
80104c76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c79:	8b 40 0c             	mov    0xc(%eax),%eax
80104c7c:	83 f8 03             	cmp    $0x3,%eax
80104c7f:	75 51                	jne    80104cd2 <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104c81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c84:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c87:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104c8d:	83 ec 0c             	sub    $0xc,%esp
80104c90:	ff 75 f4             	pushl  -0xc(%ebp)
80104c93:	e8 d2 34 00 00       	call   8010816a <switchuvm>
80104c98:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c9e:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ca8:	8b 40 1c             	mov    0x1c(%eax),%eax
80104cab:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104cae:	83 c2 04             	add    $0x4,%edx
80104cb1:	83 ec 08             	sub    $0x8,%esp
80104cb4:	50                   	push   %eax
80104cb5:	52                   	push   %edx
80104cb6:	e8 27 0b 00 00       	call   801057e2 <swtch>
80104cbb:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104cbe:	e8 8a 34 00 00       	call   8010814d <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104cc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cc6:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104ccd:	00 00 00 
80104cd0:	eb 01                	jmp    80104cd3 <scheduler+0x9a>
        continue;
80104cd2:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cd3:	81 45 f4 a4 00 00 00 	addl   $0xa4,-0xc(%ebp)
80104cda:	81 7d f4 f4 76 11 80 	cmpl   $0x801176f4,-0xc(%ebp)
80104ce1:	72 93                	jb     80104c76 <scheduler+0x3d>
    }
    release(&ptable.lock);
80104ce3:	83 ec 0c             	sub    $0xc,%esp
80104ce6:	68 c0 4d 11 80       	push   $0x80114dc0
80104ceb:	e8 31 06 00 00       	call   80105321 <release>
80104cf0:	83 c4 10             	add    $0x10,%esp
    sti();
80104cf3:	e9 60 ff ff ff       	jmp    80104c58 <scheduler+0x1f>

80104cf8 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104cf8:	f3 0f 1e fb          	endbr32 
80104cfc:	55                   	push   %ebp
80104cfd:	89 e5                	mov    %esp,%ebp
80104cff:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104d02:	e8 08 f8 ff ff       	call   8010450f <myproc>
80104d07:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104d0a:	83 ec 0c             	sub    $0xc,%esp
80104d0d:	68 c0 4d 11 80       	push   $0x80114dc0
80104d12:	e8 df 06 00 00       	call   801053f6 <holding>
80104d17:	83 c4 10             	add    $0x10,%esp
80104d1a:	85 c0                	test   %eax,%eax
80104d1c:	75 0d                	jne    80104d2b <sched+0x33>
    panic("sched ptable.lock");
80104d1e:	83 ec 0c             	sub    $0xc,%esp
80104d21:	68 8f 95 10 80       	push   $0x8010958f
80104d26:	e8 dd b8 ff ff       	call   80100608 <panic>
  if(mycpu()->ncli != 1)
80104d2b:	e8 63 f7 ff ff       	call   80104493 <mycpu>
80104d30:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d36:	83 f8 01             	cmp    $0x1,%eax
80104d39:	74 0d                	je     80104d48 <sched+0x50>
    panic("sched locks");
80104d3b:	83 ec 0c             	sub    $0xc,%esp
80104d3e:	68 a1 95 10 80       	push   $0x801095a1
80104d43:	e8 c0 b8 ff ff       	call   80100608 <panic>
  if(p->state == RUNNING)
80104d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d4b:	8b 40 0c             	mov    0xc(%eax),%eax
80104d4e:	83 f8 04             	cmp    $0x4,%eax
80104d51:	75 0d                	jne    80104d60 <sched+0x68>
    panic("sched running");
80104d53:	83 ec 0c             	sub    $0xc,%esp
80104d56:	68 ad 95 10 80       	push   $0x801095ad
80104d5b:	e8 a8 b8 ff ff       	call   80100608 <panic>
  if(readeflags()&FL_IF)
80104d60:	e8 d6 f6 ff ff       	call   8010443b <readeflags>
80104d65:	25 00 02 00 00       	and    $0x200,%eax
80104d6a:	85 c0                	test   %eax,%eax
80104d6c:	74 0d                	je     80104d7b <sched+0x83>
    panic("sched interruptible");
80104d6e:	83 ec 0c             	sub    $0xc,%esp
80104d71:	68 bb 95 10 80       	push   $0x801095bb
80104d76:	e8 8d b8 ff ff       	call   80100608 <panic>
  intena = mycpu()->intena;
80104d7b:	e8 13 f7 ff ff       	call   80104493 <mycpu>
80104d80:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104d86:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104d89:	e8 05 f7 ff ff       	call   80104493 <mycpu>
80104d8e:	8b 40 04             	mov    0x4(%eax),%eax
80104d91:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d94:	83 c2 1c             	add    $0x1c,%edx
80104d97:	83 ec 08             	sub    $0x8,%esp
80104d9a:	50                   	push   %eax
80104d9b:	52                   	push   %edx
80104d9c:	e8 41 0a 00 00       	call   801057e2 <swtch>
80104da1:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104da4:	e8 ea f6 ff ff       	call   80104493 <mycpu>
80104da9:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104dac:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104db2:	90                   	nop
80104db3:	c9                   	leave  
80104db4:	c3                   	ret    

80104db5 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104db5:	f3 0f 1e fb          	endbr32 
80104db9:	55                   	push   %ebp
80104dba:	89 e5                	mov    %esp,%ebp
80104dbc:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104dbf:	83 ec 0c             	sub    $0xc,%esp
80104dc2:	68 c0 4d 11 80       	push   $0x80114dc0
80104dc7:	e8 e3 04 00 00       	call   801052af <acquire>
80104dcc:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104dcf:	e8 3b f7 ff ff       	call   8010450f <myproc>
80104dd4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104ddb:	e8 18 ff ff ff       	call   80104cf8 <sched>
  release(&ptable.lock);
80104de0:	83 ec 0c             	sub    $0xc,%esp
80104de3:	68 c0 4d 11 80       	push   $0x80114dc0
80104de8:	e8 34 05 00 00       	call   80105321 <release>
80104ded:	83 c4 10             	add    $0x10,%esp
}
80104df0:	90                   	nop
80104df1:	c9                   	leave  
80104df2:	c3                   	ret    

80104df3 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104df3:	f3 0f 1e fb          	endbr32 
80104df7:	55                   	push   %ebp
80104df8:	89 e5                	mov    %esp,%ebp
80104dfa:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104dfd:	83 ec 0c             	sub    $0xc,%esp
80104e00:	68 c0 4d 11 80       	push   $0x80114dc0
80104e05:	e8 17 05 00 00       	call   80105321 <release>
80104e0a:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104e0d:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104e12:	85 c0                	test   %eax,%eax
80104e14:	74 24                	je     80104e3a <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104e16:	c7 05 04 c0 10 80 00 	movl   $0x0,0x8010c004
80104e1d:	00 00 00 
    iinit(ROOTDEV);
80104e20:	83 ec 0c             	sub    $0xc,%esp
80104e23:	6a 01                	push   $0x1
80104e25:	e8 ab c9 ff ff       	call   801017d5 <iinit>
80104e2a:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104e2d:	83 ec 0c             	sub    $0xc,%esp
80104e30:	6a 01                	push   $0x1
80104e32:	e8 e6 e6 ff ff       	call   8010351d <initlog>
80104e37:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104e3a:	90                   	nop
80104e3b:	c9                   	leave  
80104e3c:	c3                   	ret    

80104e3d <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104e3d:	f3 0f 1e fb          	endbr32 
80104e41:	55                   	push   %ebp
80104e42:	89 e5                	mov    %esp,%ebp
80104e44:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104e47:	e8 c3 f6 ff ff       	call   8010450f <myproc>
80104e4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104e4f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e53:	75 0d                	jne    80104e62 <sleep+0x25>
    panic("sleep");
80104e55:	83 ec 0c             	sub    $0xc,%esp
80104e58:	68 cf 95 10 80       	push   $0x801095cf
80104e5d:	e8 a6 b7 ff ff       	call   80100608 <panic>

  if(lk == 0)
80104e62:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104e66:	75 0d                	jne    80104e75 <sleep+0x38>
    panic("sleep without lk");
80104e68:	83 ec 0c             	sub    $0xc,%esp
80104e6b:	68 d5 95 10 80       	push   $0x801095d5
80104e70:	e8 93 b7 ff ff       	call   80100608 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104e75:	81 7d 0c c0 4d 11 80 	cmpl   $0x80114dc0,0xc(%ebp)
80104e7c:	74 1e                	je     80104e9c <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104e7e:	83 ec 0c             	sub    $0xc,%esp
80104e81:	68 c0 4d 11 80       	push   $0x80114dc0
80104e86:	e8 24 04 00 00       	call   801052af <acquire>
80104e8b:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104e8e:	83 ec 0c             	sub    $0xc,%esp
80104e91:	ff 75 0c             	pushl  0xc(%ebp)
80104e94:	e8 88 04 00 00       	call   80105321 <release>
80104e99:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104e9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e9f:	8b 55 08             	mov    0x8(%ebp),%edx
80104ea2:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104ea5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ea8:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104eaf:	e8 44 fe ff ff       	call   80104cf8 <sched>

  // Tidy up.
  p->chan = 0;
80104eb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eb7:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104ebe:	81 7d 0c c0 4d 11 80 	cmpl   $0x80114dc0,0xc(%ebp)
80104ec5:	74 1e                	je     80104ee5 <sleep+0xa8>
    release(&ptable.lock);
80104ec7:	83 ec 0c             	sub    $0xc,%esp
80104eca:	68 c0 4d 11 80       	push   $0x80114dc0
80104ecf:	e8 4d 04 00 00       	call   80105321 <release>
80104ed4:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104ed7:	83 ec 0c             	sub    $0xc,%esp
80104eda:	ff 75 0c             	pushl  0xc(%ebp)
80104edd:	e8 cd 03 00 00       	call   801052af <acquire>
80104ee2:	83 c4 10             	add    $0x10,%esp
  }
}
80104ee5:	90                   	nop
80104ee6:	c9                   	leave  
80104ee7:	c3                   	ret    

80104ee8 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104ee8:	f3 0f 1e fb          	endbr32 
80104eec:	55                   	push   %ebp
80104eed:	89 e5                	mov    %esp,%ebp
80104eef:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104ef2:	c7 45 fc f4 4d 11 80 	movl   $0x80114df4,-0x4(%ebp)
80104ef9:	eb 27                	jmp    80104f22 <wakeup1+0x3a>
    if(p->state == SLEEPING && p->chan == chan)
80104efb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104efe:	8b 40 0c             	mov    0xc(%eax),%eax
80104f01:	83 f8 02             	cmp    $0x2,%eax
80104f04:	75 15                	jne    80104f1b <wakeup1+0x33>
80104f06:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f09:	8b 40 20             	mov    0x20(%eax),%eax
80104f0c:	39 45 08             	cmp    %eax,0x8(%ebp)
80104f0f:	75 0a                	jne    80104f1b <wakeup1+0x33>
      p->state = RUNNABLE;
80104f11:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f14:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f1b:	81 45 fc a4 00 00 00 	addl   $0xa4,-0x4(%ebp)
80104f22:	81 7d fc f4 76 11 80 	cmpl   $0x801176f4,-0x4(%ebp)
80104f29:	72 d0                	jb     80104efb <wakeup1+0x13>
}
80104f2b:	90                   	nop
80104f2c:	90                   	nop
80104f2d:	c9                   	leave  
80104f2e:	c3                   	ret    

80104f2f <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104f2f:	f3 0f 1e fb          	endbr32 
80104f33:	55                   	push   %ebp
80104f34:	89 e5                	mov    %esp,%ebp
80104f36:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104f39:	83 ec 0c             	sub    $0xc,%esp
80104f3c:	68 c0 4d 11 80       	push   $0x80114dc0
80104f41:	e8 69 03 00 00       	call   801052af <acquire>
80104f46:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104f49:	83 ec 0c             	sub    $0xc,%esp
80104f4c:	ff 75 08             	pushl  0x8(%ebp)
80104f4f:	e8 94 ff ff ff       	call   80104ee8 <wakeup1>
80104f54:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104f57:	83 ec 0c             	sub    $0xc,%esp
80104f5a:	68 c0 4d 11 80       	push   $0x80114dc0
80104f5f:	e8 bd 03 00 00       	call   80105321 <release>
80104f64:	83 c4 10             	add    $0x10,%esp
}
80104f67:	90                   	nop
80104f68:	c9                   	leave  
80104f69:	c3                   	ret    

80104f6a <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104f6a:	f3 0f 1e fb          	endbr32 
80104f6e:	55                   	push   %ebp
80104f6f:	89 e5                	mov    %esp,%ebp
80104f71:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104f74:	83 ec 0c             	sub    $0xc,%esp
80104f77:	68 c0 4d 11 80       	push   $0x80114dc0
80104f7c:	e8 2e 03 00 00       	call   801052af <acquire>
80104f81:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f84:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104f8b:	eb 48                	jmp    80104fd5 <kill+0x6b>
    if(p->pid == pid){
80104f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f90:	8b 40 10             	mov    0x10(%eax),%eax
80104f93:	39 45 08             	cmp    %eax,0x8(%ebp)
80104f96:	75 36                	jne    80104fce <kill+0x64>
      p->killed = 1;
80104f98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f9b:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104fa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fa5:	8b 40 0c             	mov    0xc(%eax),%eax
80104fa8:	83 f8 02             	cmp    $0x2,%eax
80104fab:	75 0a                	jne    80104fb7 <kill+0x4d>
        p->state = RUNNABLE;
80104fad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fb0:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104fb7:	83 ec 0c             	sub    $0xc,%esp
80104fba:	68 c0 4d 11 80       	push   $0x80114dc0
80104fbf:	e8 5d 03 00 00       	call   80105321 <release>
80104fc4:	83 c4 10             	add    $0x10,%esp
      return 0;
80104fc7:	b8 00 00 00 00       	mov    $0x0,%eax
80104fcc:	eb 25                	jmp    80104ff3 <kill+0x89>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fce:	81 45 f4 a4 00 00 00 	addl   $0xa4,-0xc(%ebp)
80104fd5:	81 7d f4 f4 76 11 80 	cmpl   $0x801176f4,-0xc(%ebp)
80104fdc:	72 af                	jb     80104f8d <kill+0x23>
    }
  }
  release(&ptable.lock);
80104fde:	83 ec 0c             	sub    $0xc,%esp
80104fe1:	68 c0 4d 11 80       	push   $0x80114dc0
80104fe6:	e8 36 03 00 00       	call   80105321 <release>
80104feb:	83 c4 10             	add    $0x10,%esp
  return -1;
80104fee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104ff3:	c9                   	leave  
80104ff4:	c3                   	ret    

80104ff5 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104ff5:	f3 0f 1e fb          	endbr32 
80104ff9:	55                   	push   %ebp
80104ffa:	89 e5                	mov    %esp,%ebp
80104ffc:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fff:	c7 45 f0 f4 4d 11 80 	movl   $0x80114df4,-0x10(%ebp)
80105006:	e9 da 00 00 00       	jmp    801050e5 <procdump+0xf0>
    if(p->state == UNUSED)
8010500b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010500e:	8b 40 0c             	mov    0xc(%eax),%eax
80105011:	85 c0                	test   %eax,%eax
80105013:	0f 84 c4 00 00 00    	je     801050dd <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105019:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010501c:	8b 40 0c             	mov    0xc(%eax),%eax
8010501f:	83 f8 05             	cmp    $0x5,%eax
80105022:	77 23                	ja     80105047 <procdump+0x52>
80105024:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105027:	8b 40 0c             	mov    0xc(%eax),%eax
8010502a:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105031:	85 c0                	test   %eax,%eax
80105033:	74 12                	je     80105047 <procdump+0x52>
      state = states[p->state];
80105035:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105038:	8b 40 0c             	mov    0xc(%eax),%eax
8010503b:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105042:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105045:	eb 07                	jmp    8010504e <procdump+0x59>
    else
      state = "???";
80105047:	c7 45 ec e6 95 10 80 	movl   $0x801095e6,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
8010504e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105051:	8d 50 6c             	lea    0x6c(%eax),%edx
80105054:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105057:	8b 40 10             	mov    0x10(%eax),%eax
8010505a:	52                   	push   %edx
8010505b:	ff 75 ec             	pushl  -0x14(%ebp)
8010505e:	50                   	push   %eax
8010505f:	68 ea 95 10 80       	push   $0x801095ea
80105064:	e8 af b3 ff ff       	call   80100418 <cprintf>
80105069:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
8010506c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010506f:	8b 40 0c             	mov    0xc(%eax),%eax
80105072:	83 f8 02             	cmp    $0x2,%eax
80105075:	75 54                	jne    801050cb <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105077:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010507a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010507d:	8b 40 0c             	mov    0xc(%eax),%eax
80105080:	83 c0 08             	add    $0x8,%eax
80105083:	89 c2                	mov    %eax,%edx
80105085:	83 ec 08             	sub    $0x8,%esp
80105088:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010508b:	50                   	push   %eax
8010508c:	52                   	push   %edx
8010508d:	e8 e5 02 00 00       	call   80105377 <getcallerpcs>
80105092:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105095:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010509c:	eb 1c                	jmp    801050ba <procdump+0xc5>
        cprintf(" %p", pc[i]);
8010509e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050a1:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801050a5:	83 ec 08             	sub    $0x8,%esp
801050a8:	50                   	push   %eax
801050a9:	68 f3 95 10 80       	push   $0x801095f3
801050ae:	e8 65 b3 ff ff       	call   80100418 <cprintf>
801050b3:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801050b6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801050ba:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801050be:	7f 0b                	jg     801050cb <procdump+0xd6>
801050c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050c3:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801050c7:	85 c0                	test   %eax,%eax
801050c9:	75 d3                	jne    8010509e <procdump+0xa9>
    }
    cprintf("\n");
801050cb:	83 ec 0c             	sub    $0xc,%esp
801050ce:	68 f7 95 10 80       	push   $0x801095f7
801050d3:	e8 40 b3 ff ff       	call   80100418 <cprintf>
801050d8:	83 c4 10             	add    $0x10,%esp
801050db:	eb 01                	jmp    801050de <procdump+0xe9>
      continue;
801050dd:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050de:	81 45 f0 a4 00 00 00 	addl   $0xa4,-0x10(%ebp)
801050e5:	81 7d f0 f4 76 11 80 	cmpl   $0x801176f4,-0x10(%ebp)
801050ec:	0f 82 19 ff ff ff    	jb     8010500b <procdump+0x16>
  }
}
801050f2:	90                   	nop
801050f3:	90                   	nop
801050f4:	c9                   	leave  
801050f5:	c3                   	ret    

801050f6 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801050f6:	f3 0f 1e fb          	endbr32 
801050fa:	55                   	push   %ebp
801050fb:	89 e5                	mov    %esp,%ebp
801050fd:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80105100:	8b 45 08             	mov    0x8(%ebp),%eax
80105103:	83 c0 04             	add    $0x4,%eax
80105106:	83 ec 08             	sub    $0x8,%esp
80105109:	68 23 96 10 80       	push   $0x80109623
8010510e:	50                   	push   %eax
8010510f:	e8 75 01 00 00       	call   80105289 <initlock>
80105114:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80105117:	8b 45 08             	mov    0x8(%ebp),%eax
8010511a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010511d:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80105120:	8b 45 08             	mov    0x8(%ebp),%eax
80105123:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105129:	8b 45 08             	mov    0x8(%ebp),%eax
8010512c:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80105133:	90                   	nop
80105134:	c9                   	leave  
80105135:	c3                   	ret    

80105136 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80105136:	f3 0f 1e fb          	endbr32 
8010513a:	55                   	push   %ebp
8010513b:	89 e5                	mov    %esp,%ebp
8010513d:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80105140:	8b 45 08             	mov    0x8(%ebp),%eax
80105143:	83 c0 04             	add    $0x4,%eax
80105146:	83 ec 0c             	sub    $0xc,%esp
80105149:	50                   	push   %eax
8010514a:	e8 60 01 00 00       	call   801052af <acquire>
8010514f:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80105152:	eb 15                	jmp    80105169 <acquiresleep+0x33>
    sleep(lk, &lk->lk);
80105154:	8b 45 08             	mov    0x8(%ebp),%eax
80105157:	83 c0 04             	add    $0x4,%eax
8010515a:	83 ec 08             	sub    $0x8,%esp
8010515d:	50                   	push   %eax
8010515e:	ff 75 08             	pushl  0x8(%ebp)
80105161:	e8 d7 fc ff ff       	call   80104e3d <sleep>
80105166:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80105169:	8b 45 08             	mov    0x8(%ebp),%eax
8010516c:	8b 00                	mov    (%eax),%eax
8010516e:	85 c0                	test   %eax,%eax
80105170:	75 e2                	jne    80105154 <acquiresleep+0x1e>
  }
  lk->locked = 1;
80105172:	8b 45 08             	mov    0x8(%ebp),%eax
80105175:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
8010517b:	e8 8f f3 ff ff       	call   8010450f <myproc>
80105180:	8b 50 10             	mov    0x10(%eax),%edx
80105183:	8b 45 08             	mov    0x8(%ebp),%eax
80105186:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80105189:	8b 45 08             	mov    0x8(%ebp),%eax
8010518c:	83 c0 04             	add    $0x4,%eax
8010518f:	83 ec 0c             	sub    $0xc,%esp
80105192:	50                   	push   %eax
80105193:	e8 89 01 00 00       	call   80105321 <release>
80105198:	83 c4 10             	add    $0x10,%esp
}
8010519b:	90                   	nop
8010519c:	c9                   	leave  
8010519d:	c3                   	ret    

8010519e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
8010519e:	f3 0f 1e fb          	endbr32 
801051a2:	55                   	push   %ebp
801051a3:	89 e5                	mov    %esp,%ebp
801051a5:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801051a8:	8b 45 08             	mov    0x8(%ebp),%eax
801051ab:	83 c0 04             	add    $0x4,%eax
801051ae:	83 ec 0c             	sub    $0xc,%esp
801051b1:	50                   	push   %eax
801051b2:	e8 f8 00 00 00       	call   801052af <acquire>
801051b7:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
801051ba:	8b 45 08             	mov    0x8(%ebp),%eax
801051bd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801051c3:	8b 45 08             	mov    0x8(%ebp),%eax
801051c6:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
801051cd:	83 ec 0c             	sub    $0xc,%esp
801051d0:	ff 75 08             	pushl  0x8(%ebp)
801051d3:	e8 57 fd ff ff       	call   80104f2f <wakeup>
801051d8:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
801051db:	8b 45 08             	mov    0x8(%ebp),%eax
801051de:	83 c0 04             	add    $0x4,%eax
801051e1:	83 ec 0c             	sub    $0xc,%esp
801051e4:	50                   	push   %eax
801051e5:	e8 37 01 00 00       	call   80105321 <release>
801051ea:	83 c4 10             	add    $0x10,%esp
}
801051ed:	90                   	nop
801051ee:	c9                   	leave  
801051ef:	c3                   	ret    

801051f0 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801051f0:	f3 0f 1e fb          	endbr32 
801051f4:	55                   	push   %ebp
801051f5:	89 e5                	mov    %esp,%ebp
801051f7:	53                   	push   %ebx
801051f8:	83 ec 14             	sub    $0x14,%esp
  int r;
  
  acquire(&lk->lk);
801051fb:	8b 45 08             	mov    0x8(%ebp),%eax
801051fe:	83 c0 04             	add    $0x4,%eax
80105201:	83 ec 0c             	sub    $0xc,%esp
80105204:	50                   	push   %eax
80105205:	e8 a5 00 00 00       	call   801052af <acquire>
8010520a:	83 c4 10             	add    $0x10,%esp
  r = lk->locked && (lk->pid == myproc()->pid);
8010520d:	8b 45 08             	mov    0x8(%ebp),%eax
80105210:	8b 00                	mov    (%eax),%eax
80105212:	85 c0                	test   %eax,%eax
80105214:	74 19                	je     8010522f <holdingsleep+0x3f>
80105216:	8b 45 08             	mov    0x8(%ebp),%eax
80105219:	8b 58 3c             	mov    0x3c(%eax),%ebx
8010521c:	e8 ee f2 ff ff       	call   8010450f <myproc>
80105221:	8b 40 10             	mov    0x10(%eax),%eax
80105224:	39 c3                	cmp    %eax,%ebx
80105226:	75 07                	jne    8010522f <holdingsleep+0x3f>
80105228:	b8 01 00 00 00       	mov    $0x1,%eax
8010522d:	eb 05                	jmp    80105234 <holdingsleep+0x44>
8010522f:	b8 00 00 00 00       	mov    $0x0,%eax
80105234:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80105237:	8b 45 08             	mov    0x8(%ebp),%eax
8010523a:	83 c0 04             	add    $0x4,%eax
8010523d:	83 ec 0c             	sub    $0xc,%esp
80105240:	50                   	push   %eax
80105241:	e8 db 00 00 00       	call   80105321 <release>
80105246:	83 c4 10             	add    $0x10,%esp
  return r;
80105249:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010524c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010524f:	c9                   	leave  
80105250:	c3                   	ret    

80105251 <readeflags>:
{
80105251:	55                   	push   %ebp
80105252:	89 e5                	mov    %esp,%ebp
80105254:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105257:	9c                   	pushf  
80105258:	58                   	pop    %eax
80105259:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010525c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010525f:	c9                   	leave  
80105260:	c3                   	ret    

80105261 <cli>:
{
80105261:	55                   	push   %ebp
80105262:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105264:	fa                   	cli    
}
80105265:	90                   	nop
80105266:	5d                   	pop    %ebp
80105267:	c3                   	ret    

80105268 <sti>:
{
80105268:	55                   	push   %ebp
80105269:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010526b:	fb                   	sti    
}
8010526c:	90                   	nop
8010526d:	5d                   	pop    %ebp
8010526e:	c3                   	ret    

8010526f <xchg>:
{
8010526f:	55                   	push   %ebp
80105270:	89 e5                	mov    %esp,%ebp
80105272:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80105275:	8b 55 08             	mov    0x8(%ebp),%edx
80105278:	8b 45 0c             	mov    0xc(%ebp),%eax
8010527b:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010527e:	f0 87 02             	lock xchg %eax,(%edx)
80105281:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80105284:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105287:	c9                   	leave  
80105288:	c3                   	ret    

80105289 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105289:	f3 0f 1e fb          	endbr32 
8010528d:	55                   	push   %ebp
8010528e:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105290:	8b 45 08             	mov    0x8(%ebp),%eax
80105293:	8b 55 0c             	mov    0xc(%ebp),%edx
80105296:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105299:	8b 45 08             	mov    0x8(%ebp),%eax
8010529c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801052a2:	8b 45 08             	mov    0x8(%ebp),%eax
801052a5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801052ac:	90                   	nop
801052ad:	5d                   	pop    %ebp
801052ae:	c3                   	ret    

801052af <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801052af:	f3 0f 1e fb          	endbr32 
801052b3:	55                   	push   %ebp
801052b4:	89 e5                	mov    %esp,%ebp
801052b6:	53                   	push   %ebx
801052b7:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801052ba:	e8 7c 01 00 00       	call   8010543b <pushcli>
  if(holding(lk))
801052bf:	8b 45 08             	mov    0x8(%ebp),%eax
801052c2:	83 ec 0c             	sub    $0xc,%esp
801052c5:	50                   	push   %eax
801052c6:	e8 2b 01 00 00       	call   801053f6 <holding>
801052cb:	83 c4 10             	add    $0x10,%esp
801052ce:	85 c0                	test   %eax,%eax
801052d0:	74 0d                	je     801052df <acquire+0x30>
    panic("acquire");
801052d2:	83 ec 0c             	sub    $0xc,%esp
801052d5:	68 2e 96 10 80       	push   $0x8010962e
801052da:	e8 29 b3 ff ff       	call   80100608 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
801052df:	90                   	nop
801052e0:	8b 45 08             	mov    0x8(%ebp),%eax
801052e3:	83 ec 08             	sub    $0x8,%esp
801052e6:	6a 01                	push   $0x1
801052e8:	50                   	push   %eax
801052e9:	e8 81 ff ff ff       	call   8010526f <xchg>
801052ee:	83 c4 10             	add    $0x10,%esp
801052f1:	85 c0                	test   %eax,%eax
801052f3:	75 eb                	jne    801052e0 <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
801052f5:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
801052fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
801052fd:	e8 91 f1 ff ff       	call   80104493 <mycpu>
80105302:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80105305:	8b 45 08             	mov    0x8(%ebp),%eax
80105308:	83 c0 0c             	add    $0xc,%eax
8010530b:	83 ec 08             	sub    $0x8,%esp
8010530e:	50                   	push   %eax
8010530f:	8d 45 08             	lea    0x8(%ebp),%eax
80105312:	50                   	push   %eax
80105313:	e8 5f 00 00 00       	call   80105377 <getcallerpcs>
80105318:	83 c4 10             	add    $0x10,%esp
}
8010531b:	90                   	nop
8010531c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010531f:	c9                   	leave  
80105320:	c3                   	ret    

80105321 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105321:	f3 0f 1e fb          	endbr32 
80105325:	55                   	push   %ebp
80105326:	89 e5                	mov    %esp,%ebp
80105328:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
8010532b:	83 ec 0c             	sub    $0xc,%esp
8010532e:	ff 75 08             	pushl  0x8(%ebp)
80105331:	e8 c0 00 00 00       	call   801053f6 <holding>
80105336:	83 c4 10             	add    $0x10,%esp
80105339:	85 c0                	test   %eax,%eax
8010533b:	75 0d                	jne    8010534a <release+0x29>
    panic("release");
8010533d:	83 ec 0c             	sub    $0xc,%esp
80105340:	68 36 96 10 80       	push   $0x80109636
80105345:	e8 be b2 ff ff       	call   80100608 <panic>

  lk->pcs[0] = 0;
8010534a:	8b 45 08             	mov    0x8(%ebp),%eax
8010534d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105354:	8b 45 08             	mov    0x8(%ebp),%eax
80105357:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
8010535e:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80105363:	8b 45 08             	mov    0x8(%ebp),%eax
80105366:	8b 55 08             	mov    0x8(%ebp),%edx
80105369:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
8010536f:	e8 18 01 00 00       	call   8010548c <popcli>
}
80105374:	90                   	nop
80105375:	c9                   	leave  
80105376:	c3                   	ret    

80105377 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105377:	f3 0f 1e fb          	endbr32 
8010537b:	55                   	push   %ebp
8010537c:	89 e5                	mov    %esp,%ebp
8010537e:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105381:	8b 45 08             	mov    0x8(%ebp),%eax
80105384:	83 e8 08             	sub    $0x8,%eax
80105387:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010538a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105391:	eb 38                	jmp    801053cb <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105393:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105397:	74 53                	je     801053ec <getcallerpcs+0x75>
80105399:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801053a0:	76 4a                	jbe    801053ec <getcallerpcs+0x75>
801053a2:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801053a6:	74 44                	je     801053ec <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
801053a8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053ab:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801053b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801053b5:	01 c2                	add    %eax,%edx
801053b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053ba:	8b 40 04             	mov    0x4(%eax),%eax
801053bd:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801053bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053c2:	8b 00                	mov    (%eax),%eax
801053c4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801053c7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801053cb:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801053cf:	7e c2                	jle    80105393 <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
801053d1:	eb 19                	jmp    801053ec <getcallerpcs+0x75>
    pcs[i] = 0;
801053d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053d6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801053dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801053e0:	01 d0                	add    %edx,%eax
801053e2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
801053e8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801053ec:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801053f0:	7e e1                	jle    801053d3 <getcallerpcs+0x5c>
}
801053f2:	90                   	nop
801053f3:	90                   	nop
801053f4:	c9                   	leave  
801053f5:	c3                   	ret    

801053f6 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801053f6:	f3 0f 1e fb          	endbr32 
801053fa:	55                   	push   %ebp
801053fb:	89 e5                	mov    %esp,%ebp
801053fd:	53                   	push   %ebx
801053fe:	83 ec 14             	sub    $0x14,%esp
  int r;
  pushcli();
80105401:	e8 35 00 00 00       	call   8010543b <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80105406:	8b 45 08             	mov    0x8(%ebp),%eax
80105409:	8b 00                	mov    (%eax),%eax
8010540b:	85 c0                	test   %eax,%eax
8010540d:	74 16                	je     80105425 <holding+0x2f>
8010540f:	8b 45 08             	mov    0x8(%ebp),%eax
80105412:	8b 58 08             	mov    0x8(%eax),%ebx
80105415:	e8 79 f0 ff ff       	call   80104493 <mycpu>
8010541a:	39 c3                	cmp    %eax,%ebx
8010541c:	75 07                	jne    80105425 <holding+0x2f>
8010541e:	b8 01 00 00 00       	mov    $0x1,%eax
80105423:	eb 05                	jmp    8010542a <holding+0x34>
80105425:	b8 00 00 00 00       	mov    $0x0,%eax
8010542a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();
8010542d:	e8 5a 00 00 00       	call   8010548c <popcli>
  return r;
80105432:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105435:	83 c4 14             	add    $0x14,%esp
80105438:	5b                   	pop    %ebx
80105439:	5d                   	pop    %ebp
8010543a:	c3                   	ret    

8010543b <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010543b:	f3 0f 1e fb          	endbr32 
8010543f:	55                   	push   %ebp
80105440:	89 e5                	mov    %esp,%ebp
80105442:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80105445:	e8 07 fe ff ff       	call   80105251 <readeflags>
8010544a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
8010544d:	e8 0f fe ff ff       	call   80105261 <cli>
  if(mycpu()->ncli == 0)
80105452:	e8 3c f0 ff ff       	call   80104493 <mycpu>
80105457:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010545d:	85 c0                	test   %eax,%eax
8010545f:	75 14                	jne    80105475 <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
80105461:	e8 2d f0 ff ff       	call   80104493 <mycpu>
80105466:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105469:	81 e2 00 02 00 00    	and    $0x200,%edx
8010546f:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80105475:	e8 19 f0 ff ff       	call   80104493 <mycpu>
8010547a:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105480:	83 c2 01             	add    $0x1,%edx
80105483:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80105489:	90                   	nop
8010548a:	c9                   	leave  
8010548b:	c3                   	ret    

8010548c <popcli>:

void
popcli(void)
{
8010548c:	f3 0f 1e fb          	endbr32 
80105490:	55                   	push   %ebp
80105491:	89 e5                	mov    %esp,%ebp
80105493:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105496:	e8 b6 fd ff ff       	call   80105251 <readeflags>
8010549b:	25 00 02 00 00       	and    $0x200,%eax
801054a0:	85 c0                	test   %eax,%eax
801054a2:	74 0d                	je     801054b1 <popcli+0x25>
    panic("popcli - interruptible");
801054a4:	83 ec 0c             	sub    $0xc,%esp
801054a7:	68 3e 96 10 80       	push   $0x8010963e
801054ac:	e8 57 b1 ff ff       	call   80100608 <panic>
  if(--mycpu()->ncli < 0)
801054b1:	e8 dd ef ff ff       	call   80104493 <mycpu>
801054b6:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801054bc:	83 ea 01             	sub    $0x1,%edx
801054bf:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801054c5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801054cb:	85 c0                	test   %eax,%eax
801054cd:	79 0d                	jns    801054dc <popcli+0x50>
    panic("popcli");
801054cf:	83 ec 0c             	sub    $0xc,%esp
801054d2:	68 55 96 10 80       	push   $0x80109655
801054d7:	e8 2c b1 ff ff       	call   80100608 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
801054dc:	e8 b2 ef ff ff       	call   80104493 <mycpu>
801054e1:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801054e7:	85 c0                	test   %eax,%eax
801054e9:	75 14                	jne    801054ff <popcli+0x73>
801054eb:	e8 a3 ef ff ff       	call   80104493 <mycpu>
801054f0:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801054f6:	85 c0                	test   %eax,%eax
801054f8:	74 05                	je     801054ff <popcli+0x73>
    sti();
801054fa:	e8 69 fd ff ff       	call   80105268 <sti>
}
801054ff:	90                   	nop
80105500:	c9                   	leave  
80105501:	c3                   	ret    

80105502 <stosb>:
{
80105502:	55                   	push   %ebp
80105503:	89 e5                	mov    %esp,%ebp
80105505:	57                   	push   %edi
80105506:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105507:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010550a:	8b 55 10             	mov    0x10(%ebp),%edx
8010550d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105510:	89 cb                	mov    %ecx,%ebx
80105512:	89 df                	mov    %ebx,%edi
80105514:	89 d1                	mov    %edx,%ecx
80105516:	fc                   	cld    
80105517:	f3 aa                	rep stos %al,%es:(%edi)
80105519:	89 ca                	mov    %ecx,%edx
8010551b:	89 fb                	mov    %edi,%ebx
8010551d:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105520:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105523:	90                   	nop
80105524:	5b                   	pop    %ebx
80105525:	5f                   	pop    %edi
80105526:	5d                   	pop    %ebp
80105527:	c3                   	ret    

80105528 <stosl>:
{
80105528:	55                   	push   %ebp
80105529:	89 e5                	mov    %esp,%ebp
8010552b:	57                   	push   %edi
8010552c:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010552d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105530:	8b 55 10             	mov    0x10(%ebp),%edx
80105533:	8b 45 0c             	mov    0xc(%ebp),%eax
80105536:	89 cb                	mov    %ecx,%ebx
80105538:	89 df                	mov    %ebx,%edi
8010553a:	89 d1                	mov    %edx,%ecx
8010553c:	fc                   	cld    
8010553d:	f3 ab                	rep stos %eax,%es:(%edi)
8010553f:	89 ca                	mov    %ecx,%edx
80105541:	89 fb                	mov    %edi,%ebx
80105543:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105546:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105549:	90                   	nop
8010554a:	5b                   	pop    %ebx
8010554b:	5f                   	pop    %edi
8010554c:	5d                   	pop    %ebp
8010554d:	c3                   	ret    

8010554e <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010554e:	f3 0f 1e fb          	endbr32 
80105552:	55                   	push   %ebp
80105553:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105555:	8b 45 08             	mov    0x8(%ebp),%eax
80105558:	83 e0 03             	and    $0x3,%eax
8010555b:	85 c0                	test   %eax,%eax
8010555d:	75 43                	jne    801055a2 <memset+0x54>
8010555f:	8b 45 10             	mov    0x10(%ebp),%eax
80105562:	83 e0 03             	and    $0x3,%eax
80105565:	85 c0                	test   %eax,%eax
80105567:	75 39                	jne    801055a2 <memset+0x54>
    c &= 0xFF;
80105569:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105570:	8b 45 10             	mov    0x10(%ebp),%eax
80105573:	c1 e8 02             	shr    $0x2,%eax
80105576:	89 c1                	mov    %eax,%ecx
80105578:	8b 45 0c             	mov    0xc(%ebp),%eax
8010557b:	c1 e0 18             	shl    $0x18,%eax
8010557e:	89 c2                	mov    %eax,%edx
80105580:	8b 45 0c             	mov    0xc(%ebp),%eax
80105583:	c1 e0 10             	shl    $0x10,%eax
80105586:	09 c2                	or     %eax,%edx
80105588:	8b 45 0c             	mov    0xc(%ebp),%eax
8010558b:	c1 e0 08             	shl    $0x8,%eax
8010558e:	09 d0                	or     %edx,%eax
80105590:	0b 45 0c             	or     0xc(%ebp),%eax
80105593:	51                   	push   %ecx
80105594:	50                   	push   %eax
80105595:	ff 75 08             	pushl  0x8(%ebp)
80105598:	e8 8b ff ff ff       	call   80105528 <stosl>
8010559d:	83 c4 0c             	add    $0xc,%esp
801055a0:	eb 12                	jmp    801055b4 <memset+0x66>
  } else
    stosb(dst, c, n);
801055a2:	8b 45 10             	mov    0x10(%ebp),%eax
801055a5:	50                   	push   %eax
801055a6:	ff 75 0c             	pushl  0xc(%ebp)
801055a9:	ff 75 08             	pushl  0x8(%ebp)
801055ac:	e8 51 ff ff ff       	call   80105502 <stosb>
801055b1:	83 c4 0c             	add    $0xc,%esp
  return dst;
801055b4:	8b 45 08             	mov    0x8(%ebp),%eax
}
801055b7:	c9                   	leave  
801055b8:	c3                   	ret    

801055b9 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801055b9:	f3 0f 1e fb          	endbr32 
801055bd:	55                   	push   %ebp
801055be:	89 e5                	mov    %esp,%ebp
801055c0:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801055c3:	8b 45 08             	mov    0x8(%ebp),%eax
801055c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801055c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801055cc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801055cf:	eb 30                	jmp    80105601 <memcmp+0x48>
    if(*s1 != *s2)
801055d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055d4:	0f b6 10             	movzbl (%eax),%edx
801055d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055da:	0f b6 00             	movzbl (%eax),%eax
801055dd:	38 c2                	cmp    %al,%dl
801055df:	74 18                	je     801055f9 <memcmp+0x40>
      return *s1 - *s2;
801055e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055e4:	0f b6 00             	movzbl (%eax),%eax
801055e7:	0f b6 d0             	movzbl %al,%edx
801055ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055ed:	0f b6 00             	movzbl (%eax),%eax
801055f0:	0f b6 c0             	movzbl %al,%eax
801055f3:	29 c2                	sub    %eax,%edx
801055f5:	89 d0                	mov    %edx,%eax
801055f7:	eb 1a                	jmp    80105613 <memcmp+0x5a>
    s1++, s2++;
801055f9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801055fd:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80105601:	8b 45 10             	mov    0x10(%ebp),%eax
80105604:	8d 50 ff             	lea    -0x1(%eax),%edx
80105607:	89 55 10             	mov    %edx,0x10(%ebp)
8010560a:	85 c0                	test   %eax,%eax
8010560c:	75 c3                	jne    801055d1 <memcmp+0x18>
  }

  return 0;
8010560e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105613:	c9                   	leave  
80105614:	c3                   	ret    

80105615 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105615:	f3 0f 1e fb          	endbr32 
80105619:	55                   	push   %ebp
8010561a:	89 e5                	mov    %esp,%ebp
8010561c:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010561f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105622:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105625:	8b 45 08             	mov    0x8(%ebp),%eax
80105628:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010562b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010562e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105631:	73 54                	jae    80105687 <memmove+0x72>
80105633:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105636:	8b 45 10             	mov    0x10(%ebp),%eax
80105639:	01 d0                	add    %edx,%eax
8010563b:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010563e:	73 47                	jae    80105687 <memmove+0x72>
    s += n;
80105640:	8b 45 10             	mov    0x10(%ebp),%eax
80105643:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105646:	8b 45 10             	mov    0x10(%ebp),%eax
80105649:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010564c:	eb 13                	jmp    80105661 <memmove+0x4c>
      *--d = *--s;
8010564e:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105652:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105656:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105659:	0f b6 10             	movzbl (%eax),%edx
8010565c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010565f:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105661:	8b 45 10             	mov    0x10(%ebp),%eax
80105664:	8d 50 ff             	lea    -0x1(%eax),%edx
80105667:	89 55 10             	mov    %edx,0x10(%ebp)
8010566a:	85 c0                	test   %eax,%eax
8010566c:	75 e0                	jne    8010564e <memmove+0x39>
  if(s < d && s + n > d){
8010566e:	eb 24                	jmp    80105694 <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
80105670:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105673:	8d 42 01             	lea    0x1(%edx),%eax
80105676:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105679:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010567c:	8d 48 01             	lea    0x1(%eax),%ecx
8010567f:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80105682:	0f b6 12             	movzbl (%edx),%edx
80105685:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105687:	8b 45 10             	mov    0x10(%ebp),%eax
8010568a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010568d:	89 55 10             	mov    %edx,0x10(%ebp)
80105690:	85 c0                	test   %eax,%eax
80105692:	75 dc                	jne    80105670 <memmove+0x5b>

  return dst;
80105694:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105697:	c9                   	leave  
80105698:	c3                   	ret    

80105699 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105699:	f3 0f 1e fb          	endbr32 
8010569d:	55                   	push   %ebp
8010569e:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801056a0:	ff 75 10             	pushl  0x10(%ebp)
801056a3:	ff 75 0c             	pushl  0xc(%ebp)
801056a6:	ff 75 08             	pushl  0x8(%ebp)
801056a9:	e8 67 ff ff ff       	call   80105615 <memmove>
801056ae:	83 c4 0c             	add    $0xc,%esp
}
801056b1:	c9                   	leave  
801056b2:	c3                   	ret    

801056b3 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801056b3:	f3 0f 1e fb          	endbr32 
801056b7:	55                   	push   %ebp
801056b8:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801056ba:	eb 0c                	jmp    801056c8 <strncmp+0x15>
    n--, p++, q++;
801056bc:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801056c0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801056c4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
801056c8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056cc:	74 1a                	je     801056e8 <strncmp+0x35>
801056ce:	8b 45 08             	mov    0x8(%ebp),%eax
801056d1:	0f b6 00             	movzbl (%eax),%eax
801056d4:	84 c0                	test   %al,%al
801056d6:	74 10                	je     801056e8 <strncmp+0x35>
801056d8:	8b 45 08             	mov    0x8(%ebp),%eax
801056db:	0f b6 10             	movzbl (%eax),%edx
801056de:	8b 45 0c             	mov    0xc(%ebp),%eax
801056e1:	0f b6 00             	movzbl (%eax),%eax
801056e4:	38 c2                	cmp    %al,%dl
801056e6:	74 d4                	je     801056bc <strncmp+0x9>
  if(n == 0)
801056e8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056ec:	75 07                	jne    801056f5 <strncmp+0x42>
    return 0;
801056ee:	b8 00 00 00 00       	mov    $0x0,%eax
801056f3:	eb 16                	jmp    8010570b <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
801056f5:	8b 45 08             	mov    0x8(%ebp),%eax
801056f8:	0f b6 00             	movzbl (%eax),%eax
801056fb:	0f b6 d0             	movzbl %al,%edx
801056fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80105701:	0f b6 00             	movzbl (%eax),%eax
80105704:	0f b6 c0             	movzbl %al,%eax
80105707:	29 c2                	sub    %eax,%edx
80105709:	89 d0                	mov    %edx,%eax
}
8010570b:	5d                   	pop    %ebp
8010570c:	c3                   	ret    

8010570d <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010570d:	f3 0f 1e fb          	endbr32 
80105711:	55                   	push   %ebp
80105712:	89 e5                	mov    %esp,%ebp
80105714:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105717:	8b 45 08             	mov    0x8(%ebp),%eax
8010571a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010571d:	90                   	nop
8010571e:	8b 45 10             	mov    0x10(%ebp),%eax
80105721:	8d 50 ff             	lea    -0x1(%eax),%edx
80105724:	89 55 10             	mov    %edx,0x10(%ebp)
80105727:	85 c0                	test   %eax,%eax
80105729:	7e 2c                	jle    80105757 <strncpy+0x4a>
8010572b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010572e:	8d 42 01             	lea    0x1(%edx),%eax
80105731:	89 45 0c             	mov    %eax,0xc(%ebp)
80105734:	8b 45 08             	mov    0x8(%ebp),%eax
80105737:	8d 48 01             	lea    0x1(%eax),%ecx
8010573a:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010573d:	0f b6 12             	movzbl (%edx),%edx
80105740:	88 10                	mov    %dl,(%eax)
80105742:	0f b6 00             	movzbl (%eax),%eax
80105745:	84 c0                	test   %al,%al
80105747:	75 d5                	jne    8010571e <strncpy+0x11>
    ;
  while(n-- > 0)
80105749:	eb 0c                	jmp    80105757 <strncpy+0x4a>
    *s++ = 0;
8010574b:	8b 45 08             	mov    0x8(%ebp),%eax
8010574e:	8d 50 01             	lea    0x1(%eax),%edx
80105751:	89 55 08             	mov    %edx,0x8(%ebp)
80105754:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80105757:	8b 45 10             	mov    0x10(%ebp),%eax
8010575a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010575d:	89 55 10             	mov    %edx,0x10(%ebp)
80105760:	85 c0                	test   %eax,%eax
80105762:	7f e7                	jg     8010574b <strncpy+0x3e>
  return os;
80105764:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105767:	c9                   	leave  
80105768:	c3                   	ret    

80105769 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105769:	f3 0f 1e fb          	endbr32 
8010576d:	55                   	push   %ebp
8010576e:	89 e5                	mov    %esp,%ebp
80105770:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105773:	8b 45 08             	mov    0x8(%ebp),%eax
80105776:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105779:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010577d:	7f 05                	jg     80105784 <safestrcpy+0x1b>
    return os;
8010577f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105782:	eb 31                	jmp    801057b5 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80105784:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105788:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010578c:	7e 1e                	jle    801057ac <safestrcpy+0x43>
8010578e:	8b 55 0c             	mov    0xc(%ebp),%edx
80105791:	8d 42 01             	lea    0x1(%edx),%eax
80105794:	89 45 0c             	mov    %eax,0xc(%ebp)
80105797:	8b 45 08             	mov    0x8(%ebp),%eax
8010579a:	8d 48 01             	lea    0x1(%eax),%ecx
8010579d:	89 4d 08             	mov    %ecx,0x8(%ebp)
801057a0:	0f b6 12             	movzbl (%edx),%edx
801057a3:	88 10                	mov    %dl,(%eax)
801057a5:	0f b6 00             	movzbl (%eax),%eax
801057a8:	84 c0                	test   %al,%al
801057aa:	75 d8                	jne    80105784 <safestrcpy+0x1b>
    ;
  *s = 0;
801057ac:	8b 45 08             	mov    0x8(%ebp),%eax
801057af:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801057b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057b5:	c9                   	leave  
801057b6:	c3                   	ret    

801057b7 <strlen>:

int
strlen(const char *s)
{
801057b7:	f3 0f 1e fb          	endbr32 
801057bb:	55                   	push   %ebp
801057bc:	89 e5                	mov    %esp,%ebp
801057be:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801057c1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801057c8:	eb 04                	jmp    801057ce <strlen+0x17>
801057ca:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801057ce:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057d1:	8b 45 08             	mov    0x8(%ebp),%eax
801057d4:	01 d0                	add    %edx,%eax
801057d6:	0f b6 00             	movzbl (%eax),%eax
801057d9:	84 c0                	test   %al,%al
801057db:	75 ed                	jne    801057ca <strlen+0x13>
    ;
  return n;
801057dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057e0:	c9                   	leave  
801057e1:	c3                   	ret    

801057e2 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801057e2:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801057e6:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
801057ea:	55                   	push   %ebp
  pushl %ebx
801057eb:	53                   	push   %ebx
  pushl %esi
801057ec:	56                   	push   %esi
  pushl %edi
801057ed:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801057ee:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801057f0:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
801057f2:	5f                   	pop    %edi
  popl %esi
801057f3:	5e                   	pop    %esi
  popl %ebx
801057f4:	5b                   	pop    %ebx
  popl %ebp
801057f5:	5d                   	pop    %ebp
  ret
801057f6:	c3                   	ret    

801057f7 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801057f7:	f3 0f 1e fb          	endbr32 
801057fb:	55                   	push   %ebp
801057fc:	89 e5                	mov    %esp,%ebp
801057fe:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105801:	e8 09 ed ff ff       	call   8010450f <myproc>
80105806:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105809:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010580c:	8b 00                	mov    (%eax),%eax
8010580e:	39 45 08             	cmp    %eax,0x8(%ebp)
80105811:	73 0f                	jae    80105822 <fetchint+0x2b>
80105813:	8b 45 08             	mov    0x8(%ebp),%eax
80105816:	8d 50 04             	lea    0x4(%eax),%edx
80105819:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010581c:	8b 00                	mov    (%eax),%eax
8010581e:	39 c2                	cmp    %eax,%edx
80105820:	76 07                	jbe    80105829 <fetchint+0x32>
    return -1;
80105822:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105827:	eb 0f                	jmp    80105838 <fetchint+0x41>
  *ip = *(int*)(addr);
80105829:	8b 45 08             	mov    0x8(%ebp),%eax
8010582c:	8b 10                	mov    (%eax),%edx
8010582e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105831:	89 10                	mov    %edx,(%eax)
  return 0;
80105833:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105838:	c9                   	leave  
80105839:	c3                   	ret    

8010583a <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010583a:	f3 0f 1e fb          	endbr32 
8010583e:	55                   	push   %ebp
8010583f:	89 e5                	mov    %esp,%ebp
80105841:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105844:	e8 c6 ec ff ff       	call   8010450f <myproc>
80105849:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
8010584c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010584f:	8b 00                	mov    (%eax),%eax
80105851:	39 45 08             	cmp    %eax,0x8(%ebp)
80105854:	72 07                	jb     8010585d <fetchstr+0x23>
    return -1;
80105856:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010585b:	eb 43                	jmp    801058a0 <fetchstr+0x66>
  *pp = (char*)addr;
8010585d:	8b 55 08             	mov    0x8(%ebp),%edx
80105860:	8b 45 0c             	mov    0xc(%ebp),%eax
80105863:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105865:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105868:	8b 00                	mov    (%eax),%eax
8010586a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
8010586d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105870:	8b 00                	mov    (%eax),%eax
80105872:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105875:	eb 1c                	jmp    80105893 <fetchstr+0x59>
    if(*s == 0)
80105877:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010587a:	0f b6 00             	movzbl (%eax),%eax
8010587d:	84 c0                	test   %al,%al
8010587f:	75 0e                	jne    8010588f <fetchstr+0x55>
      return s - *pp;
80105881:	8b 45 0c             	mov    0xc(%ebp),%eax
80105884:	8b 00                	mov    (%eax),%eax
80105886:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105889:	29 c2                	sub    %eax,%edx
8010588b:	89 d0                	mov    %edx,%eax
8010588d:	eb 11                	jmp    801058a0 <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
8010588f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105893:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105896:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105899:	72 dc                	jb     80105877 <fetchstr+0x3d>
  }
  return -1;
8010589b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801058a0:	c9                   	leave  
801058a1:	c3                   	ret    

801058a2 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801058a2:	f3 0f 1e fb          	endbr32 
801058a6:	55                   	push   %ebp
801058a7:	89 e5                	mov    %esp,%ebp
801058a9:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801058ac:	e8 5e ec ff ff       	call   8010450f <myproc>
801058b1:	8b 40 18             	mov    0x18(%eax),%eax
801058b4:	8b 40 44             	mov    0x44(%eax),%eax
801058b7:	8b 55 08             	mov    0x8(%ebp),%edx
801058ba:	c1 e2 02             	shl    $0x2,%edx
801058bd:	01 d0                	add    %edx,%eax
801058bf:	83 c0 04             	add    $0x4,%eax
801058c2:	83 ec 08             	sub    $0x8,%esp
801058c5:	ff 75 0c             	pushl  0xc(%ebp)
801058c8:	50                   	push   %eax
801058c9:	e8 29 ff ff ff       	call   801057f7 <fetchint>
801058ce:	83 c4 10             	add    $0x10,%esp
}
801058d1:	c9                   	leave  
801058d2:	c3                   	ret    

801058d3 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801058d3:	f3 0f 1e fb          	endbr32 
801058d7:	55                   	push   %ebp
801058d8:	89 e5                	mov    %esp,%ebp
801058da:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
801058dd:	e8 2d ec ff ff       	call   8010450f <myproc>
801058e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
801058e5:	83 ec 08             	sub    $0x8,%esp
801058e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058eb:	50                   	push   %eax
801058ec:	ff 75 08             	pushl  0x8(%ebp)
801058ef:	e8 ae ff ff ff       	call   801058a2 <argint>
801058f4:	83 c4 10             	add    $0x10,%esp
801058f7:	85 c0                	test   %eax,%eax
801058f9:	79 07                	jns    80105902 <argptr+0x2f>
    return -1;
801058fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105900:	eb 3b                	jmp    8010593d <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105902:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105906:	78 1f                	js     80105927 <argptr+0x54>
80105908:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010590b:	8b 00                	mov    (%eax),%eax
8010590d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105910:	39 d0                	cmp    %edx,%eax
80105912:	76 13                	jbe    80105927 <argptr+0x54>
80105914:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105917:	89 c2                	mov    %eax,%edx
80105919:	8b 45 10             	mov    0x10(%ebp),%eax
8010591c:	01 c2                	add    %eax,%edx
8010591e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105921:	8b 00                	mov    (%eax),%eax
80105923:	39 c2                	cmp    %eax,%edx
80105925:	76 07                	jbe    8010592e <argptr+0x5b>
    return -1;
80105927:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010592c:	eb 0f                	jmp    8010593d <argptr+0x6a>
  *pp = (char*)i;
8010592e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105931:	89 c2                	mov    %eax,%edx
80105933:	8b 45 0c             	mov    0xc(%ebp),%eax
80105936:	89 10                	mov    %edx,(%eax)
  return 0;
80105938:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010593d:	c9                   	leave  
8010593e:	c3                   	ret    

8010593f <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010593f:	f3 0f 1e fb          	endbr32 
80105943:	55                   	push   %ebp
80105944:	89 e5                	mov    %esp,%ebp
80105946:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105949:	83 ec 08             	sub    $0x8,%esp
8010594c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010594f:	50                   	push   %eax
80105950:	ff 75 08             	pushl  0x8(%ebp)
80105953:	e8 4a ff ff ff       	call   801058a2 <argint>
80105958:	83 c4 10             	add    $0x10,%esp
8010595b:	85 c0                	test   %eax,%eax
8010595d:	79 07                	jns    80105966 <argstr+0x27>
    return -1;
8010595f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105964:	eb 12                	jmp    80105978 <argstr+0x39>
  return fetchstr(addr, pp);
80105966:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105969:	83 ec 08             	sub    $0x8,%esp
8010596c:	ff 75 0c             	pushl  0xc(%ebp)
8010596f:	50                   	push   %eax
80105970:	e8 c5 fe ff ff       	call   8010583a <fetchstr>
80105975:	83 c4 10             	add    $0x10,%esp
}
80105978:	c9                   	leave  
80105979:	c3                   	ret    

8010597a <syscall>:
[SYS_dump_rawphymem] sys_dump_rawphymem,
};

void
syscall(void)
{
8010597a:	f3 0f 1e fb          	endbr32 
8010597e:	55                   	push   %ebp
8010597f:	89 e5                	mov    %esp,%ebp
80105981:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105984:	e8 86 eb ff ff       	call   8010450f <myproc>
80105989:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
8010598c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010598f:	8b 40 18             	mov    0x18(%eax),%eax
80105992:	8b 40 1c             	mov    0x1c(%eax),%eax
80105995:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105998:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010599c:	7e 2f                	jle    801059cd <syscall+0x53>
8010599e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059a1:	83 f8 18             	cmp    $0x18,%eax
801059a4:	77 27                	ja     801059cd <syscall+0x53>
801059a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059a9:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
801059b0:	85 c0                	test   %eax,%eax
801059b2:	74 19                	je     801059cd <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
801059b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059b7:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
801059be:	ff d0                	call   *%eax
801059c0:	89 c2                	mov    %eax,%edx
801059c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c5:	8b 40 18             	mov    0x18(%eax),%eax
801059c8:	89 50 1c             	mov    %edx,0x1c(%eax)
801059cb:	eb 2c                	jmp    801059f9 <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801059cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d0:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
801059d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d6:	8b 40 10             	mov    0x10(%eax),%eax
801059d9:	ff 75 f0             	pushl  -0x10(%ebp)
801059dc:	52                   	push   %edx
801059dd:	50                   	push   %eax
801059de:	68 5c 96 10 80       	push   $0x8010965c
801059e3:	e8 30 aa ff ff       	call   80100418 <cprintf>
801059e8:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801059eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ee:	8b 40 18             	mov    0x18(%eax),%eax
801059f1:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801059f8:	90                   	nop
801059f9:	90                   	nop
801059fa:	c9                   	leave  
801059fb:	c3                   	ret    

801059fc <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801059fc:	f3 0f 1e fb          	endbr32 
80105a00:	55                   	push   %ebp
80105a01:	89 e5                	mov    %esp,%ebp
80105a03:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105a06:	83 ec 08             	sub    $0x8,%esp
80105a09:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a0c:	50                   	push   %eax
80105a0d:	ff 75 08             	pushl  0x8(%ebp)
80105a10:	e8 8d fe ff ff       	call   801058a2 <argint>
80105a15:	83 c4 10             	add    $0x10,%esp
80105a18:	85 c0                	test   %eax,%eax
80105a1a:	79 07                	jns    80105a23 <argfd+0x27>
    return -1;
80105a1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a21:	eb 4f                	jmp    80105a72 <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105a23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a26:	85 c0                	test   %eax,%eax
80105a28:	78 20                	js     80105a4a <argfd+0x4e>
80105a2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a2d:	83 f8 0f             	cmp    $0xf,%eax
80105a30:	7f 18                	jg     80105a4a <argfd+0x4e>
80105a32:	e8 d8 ea ff ff       	call   8010450f <myproc>
80105a37:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a3a:	83 c2 08             	add    $0x8,%edx
80105a3d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105a41:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a44:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a48:	75 07                	jne    80105a51 <argfd+0x55>
    return -1;
80105a4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a4f:	eb 21                	jmp    80105a72 <argfd+0x76>
  if(pfd)
80105a51:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105a55:	74 08                	je     80105a5f <argfd+0x63>
    *pfd = fd;
80105a57:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a5a:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a5d:	89 10                	mov    %edx,(%eax)
  if(pf)
80105a5f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105a63:	74 08                	je     80105a6d <argfd+0x71>
    *pf = f;
80105a65:	8b 45 10             	mov    0x10(%ebp),%eax
80105a68:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a6b:	89 10                	mov    %edx,(%eax)
  return 0;
80105a6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a72:	c9                   	leave  
80105a73:	c3                   	ret    

80105a74 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105a74:	f3 0f 1e fb          	endbr32 
80105a78:	55                   	push   %ebp
80105a79:	89 e5                	mov    %esp,%ebp
80105a7b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105a7e:	e8 8c ea ff ff       	call   8010450f <myproc>
80105a83:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105a86:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105a8d:	eb 2a                	jmp    80105ab9 <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
80105a8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a92:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a95:	83 c2 08             	add    $0x8,%edx
80105a98:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105a9c:	85 c0                	test   %eax,%eax
80105a9e:	75 15                	jne    80105ab5 <fdalloc+0x41>
      curproc->ofile[fd] = f;
80105aa0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aa3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105aa6:	8d 4a 08             	lea    0x8(%edx),%ecx
80105aa9:	8b 55 08             	mov    0x8(%ebp),%edx
80105aac:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ab3:	eb 0f                	jmp    80105ac4 <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80105ab5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105ab9:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105abd:	7e d0                	jle    80105a8f <fdalloc+0x1b>
    }
  }
  return -1;
80105abf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ac4:	c9                   	leave  
80105ac5:	c3                   	ret    

80105ac6 <sys_dup>:

int
sys_dup(void)
{
80105ac6:	f3 0f 1e fb          	endbr32 
80105aca:	55                   	push   %ebp
80105acb:	89 e5                	mov    %esp,%ebp
80105acd:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105ad0:	83 ec 04             	sub    $0x4,%esp
80105ad3:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ad6:	50                   	push   %eax
80105ad7:	6a 00                	push   $0x0
80105ad9:	6a 00                	push   $0x0
80105adb:	e8 1c ff ff ff       	call   801059fc <argfd>
80105ae0:	83 c4 10             	add    $0x10,%esp
80105ae3:	85 c0                	test   %eax,%eax
80105ae5:	79 07                	jns    80105aee <sys_dup+0x28>
    return -1;
80105ae7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aec:	eb 31                	jmp    80105b1f <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
80105aee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105af1:	83 ec 0c             	sub    $0xc,%esp
80105af4:	50                   	push   %eax
80105af5:	e8 7a ff ff ff       	call   80105a74 <fdalloc>
80105afa:	83 c4 10             	add    $0x10,%esp
80105afd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b00:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b04:	79 07                	jns    80105b0d <sys_dup+0x47>
    return -1;
80105b06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b0b:	eb 12                	jmp    80105b1f <sys_dup+0x59>
  filedup(f);
80105b0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b10:	83 ec 0c             	sub    $0xc,%esp
80105b13:	50                   	push   %eax
80105b14:	e8 6d b6 ff ff       	call   80101186 <filedup>
80105b19:	83 c4 10             	add    $0x10,%esp
  return fd;
80105b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105b1f:	c9                   	leave  
80105b20:	c3                   	ret    

80105b21 <sys_read>:

int
sys_read(void)
{
80105b21:	f3 0f 1e fb          	endbr32 
80105b25:	55                   	push   %ebp
80105b26:	89 e5                	mov    %esp,%ebp
80105b28:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b2b:	83 ec 04             	sub    $0x4,%esp
80105b2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b31:	50                   	push   %eax
80105b32:	6a 00                	push   $0x0
80105b34:	6a 00                	push   $0x0
80105b36:	e8 c1 fe ff ff       	call   801059fc <argfd>
80105b3b:	83 c4 10             	add    $0x10,%esp
80105b3e:	85 c0                	test   %eax,%eax
80105b40:	78 2e                	js     80105b70 <sys_read+0x4f>
80105b42:	83 ec 08             	sub    $0x8,%esp
80105b45:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b48:	50                   	push   %eax
80105b49:	6a 02                	push   $0x2
80105b4b:	e8 52 fd ff ff       	call   801058a2 <argint>
80105b50:	83 c4 10             	add    $0x10,%esp
80105b53:	85 c0                	test   %eax,%eax
80105b55:	78 19                	js     80105b70 <sys_read+0x4f>
80105b57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b5a:	83 ec 04             	sub    $0x4,%esp
80105b5d:	50                   	push   %eax
80105b5e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b61:	50                   	push   %eax
80105b62:	6a 01                	push   $0x1
80105b64:	e8 6a fd ff ff       	call   801058d3 <argptr>
80105b69:	83 c4 10             	add    $0x10,%esp
80105b6c:	85 c0                	test   %eax,%eax
80105b6e:	79 07                	jns    80105b77 <sys_read+0x56>
    return -1;
80105b70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b75:	eb 17                	jmp    80105b8e <sys_read+0x6d>
  return fileread(f, p, n);
80105b77:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105b7a:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b80:	83 ec 04             	sub    $0x4,%esp
80105b83:	51                   	push   %ecx
80105b84:	52                   	push   %edx
80105b85:	50                   	push   %eax
80105b86:	e8 97 b7 ff ff       	call   80101322 <fileread>
80105b8b:	83 c4 10             	add    $0x10,%esp
}
80105b8e:	c9                   	leave  
80105b8f:	c3                   	ret    

80105b90 <sys_write>:

int
sys_write(void)
{
80105b90:	f3 0f 1e fb          	endbr32 
80105b94:	55                   	push   %ebp
80105b95:	89 e5                	mov    %esp,%ebp
80105b97:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b9a:	83 ec 04             	sub    $0x4,%esp
80105b9d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ba0:	50                   	push   %eax
80105ba1:	6a 00                	push   $0x0
80105ba3:	6a 00                	push   $0x0
80105ba5:	e8 52 fe ff ff       	call   801059fc <argfd>
80105baa:	83 c4 10             	add    $0x10,%esp
80105bad:	85 c0                	test   %eax,%eax
80105baf:	78 2e                	js     80105bdf <sys_write+0x4f>
80105bb1:	83 ec 08             	sub    $0x8,%esp
80105bb4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bb7:	50                   	push   %eax
80105bb8:	6a 02                	push   $0x2
80105bba:	e8 e3 fc ff ff       	call   801058a2 <argint>
80105bbf:	83 c4 10             	add    $0x10,%esp
80105bc2:	85 c0                	test   %eax,%eax
80105bc4:	78 19                	js     80105bdf <sys_write+0x4f>
80105bc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bc9:	83 ec 04             	sub    $0x4,%esp
80105bcc:	50                   	push   %eax
80105bcd:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105bd0:	50                   	push   %eax
80105bd1:	6a 01                	push   $0x1
80105bd3:	e8 fb fc ff ff       	call   801058d3 <argptr>
80105bd8:	83 c4 10             	add    $0x10,%esp
80105bdb:	85 c0                	test   %eax,%eax
80105bdd:	79 07                	jns    80105be6 <sys_write+0x56>
    return -1;
80105bdf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105be4:	eb 17                	jmp    80105bfd <sys_write+0x6d>
  return filewrite(f, p, n);
80105be6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105be9:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bef:	83 ec 04             	sub    $0x4,%esp
80105bf2:	51                   	push   %ecx
80105bf3:	52                   	push   %edx
80105bf4:	50                   	push   %eax
80105bf5:	e8 e4 b7 ff ff       	call   801013de <filewrite>
80105bfa:	83 c4 10             	add    $0x10,%esp
}
80105bfd:	c9                   	leave  
80105bfe:	c3                   	ret    

80105bff <sys_close>:

int
sys_close(void)
{
80105bff:	f3 0f 1e fb          	endbr32 
80105c03:	55                   	push   %ebp
80105c04:	89 e5                	mov    %esp,%ebp
80105c06:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105c09:	83 ec 04             	sub    $0x4,%esp
80105c0c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c0f:	50                   	push   %eax
80105c10:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c13:	50                   	push   %eax
80105c14:	6a 00                	push   $0x0
80105c16:	e8 e1 fd ff ff       	call   801059fc <argfd>
80105c1b:	83 c4 10             	add    $0x10,%esp
80105c1e:	85 c0                	test   %eax,%eax
80105c20:	79 07                	jns    80105c29 <sys_close+0x2a>
    return -1;
80105c22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c27:	eb 27                	jmp    80105c50 <sys_close+0x51>
  myproc()->ofile[fd] = 0;
80105c29:	e8 e1 e8 ff ff       	call   8010450f <myproc>
80105c2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c31:	83 c2 08             	add    $0x8,%edx
80105c34:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105c3b:	00 
  fileclose(f);
80105c3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c3f:	83 ec 0c             	sub    $0xc,%esp
80105c42:	50                   	push   %eax
80105c43:	e8 93 b5 ff ff       	call   801011db <fileclose>
80105c48:	83 c4 10             	add    $0x10,%esp
  return 0;
80105c4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c50:	c9                   	leave  
80105c51:	c3                   	ret    

80105c52 <sys_fstat>:

int
sys_fstat(void)
{
80105c52:	f3 0f 1e fb          	endbr32 
80105c56:	55                   	push   %ebp
80105c57:	89 e5                	mov    %esp,%ebp
80105c59:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105c5c:	83 ec 04             	sub    $0x4,%esp
80105c5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c62:	50                   	push   %eax
80105c63:	6a 00                	push   $0x0
80105c65:	6a 00                	push   $0x0
80105c67:	e8 90 fd ff ff       	call   801059fc <argfd>
80105c6c:	83 c4 10             	add    $0x10,%esp
80105c6f:	85 c0                	test   %eax,%eax
80105c71:	78 17                	js     80105c8a <sys_fstat+0x38>
80105c73:	83 ec 04             	sub    $0x4,%esp
80105c76:	6a 14                	push   $0x14
80105c78:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c7b:	50                   	push   %eax
80105c7c:	6a 01                	push   $0x1
80105c7e:	e8 50 fc ff ff       	call   801058d3 <argptr>
80105c83:	83 c4 10             	add    $0x10,%esp
80105c86:	85 c0                	test   %eax,%eax
80105c88:	79 07                	jns    80105c91 <sys_fstat+0x3f>
    return -1;
80105c8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c8f:	eb 13                	jmp    80105ca4 <sys_fstat+0x52>
  return filestat(f, st);
80105c91:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c97:	83 ec 08             	sub    $0x8,%esp
80105c9a:	52                   	push   %edx
80105c9b:	50                   	push   %eax
80105c9c:	e8 26 b6 ff ff       	call   801012c7 <filestat>
80105ca1:	83 c4 10             	add    $0x10,%esp
}
80105ca4:	c9                   	leave  
80105ca5:	c3                   	ret    

80105ca6 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105ca6:	f3 0f 1e fb          	endbr32 
80105caa:	55                   	push   %ebp
80105cab:	89 e5                	mov    %esp,%ebp
80105cad:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105cb0:	83 ec 08             	sub    $0x8,%esp
80105cb3:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105cb6:	50                   	push   %eax
80105cb7:	6a 00                	push   $0x0
80105cb9:	e8 81 fc ff ff       	call   8010593f <argstr>
80105cbe:	83 c4 10             	add    $0x10,%esp
80105cc1:	85 c0                	test   %eax,%eax
80105cc3:	78 15                	js     80105cda <sys_link+0x34>
80105cc5:	83 ec 08             	sub    $0x8,%esp
80105cc8:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105ccb:	50                   	push   %eax
80105ccc:	6a 01                	push   $0x1
80105cce:	e8 6c fc ff ff       	call   8010593f <argstr>
80105cd3:	83 c4 10             	add    $0x10,%esp
80105cd6:	85 c0                	test   %eax,%eax
80105cd8:	79 0a                	jns    80105ce4 <sys_link+0x3e>
    return -1;
80105cda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cdf:	e9 68 01 00 00       	jmp    80105e4c <sys_link+0x1a6>

  begin_op();
80105ce4:	e8 67 da ff ff       	call   80103750 <begin_op>
  if((ip = namei(old)) == 0){
80105ce9:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105cec:	83 ec 0c             	sub    $0xc,%esp
80105cef:	50                   	push   %eax
80105cf0:	e8 d1 c9 ff ff       	call   801026c6 <namei>
80105cf5:	83 c4 10             	add    $0x10,%esp
80105cf8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cfb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cff:	75 0f                	jne    80105d10 <sys_link+0x6a>
    end_op();
80105d01:	e8 da da ff ff       	call   801037e0 <end_op>
    return -1;
80105d06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d0b:	e9 3c 01 00 00       	jmp    80105e4c <sys_link+0x1a6>
  }

  ilock(ip);
80105d10:	83 ec 0c             	sub    $0xc,%esp
80105d13:	ff 75 f4             	pushl  -0xc(%ebp)
80105d16:	e8 40 be ff ff       	call   80101b5b <ilock>
80105d1b:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d21:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d25:	66 83 f8 01          	cmp    $0x1,%ax
80105d29:	75 1d                	jne    80105d48 <sys_link+0xa2>
    iunlockput(ip);
80105d2b:	83 ec 0c             	sub    $0xc,%esp
80105d2e:	ff 75 f4             	pushl  -0xc(%ebp)
80105d31:	e8 62 c0 ff ff       	call   80101d98 <iunlockput>
80105d36:	83 c4 10             	add    $0x10,%esp
    end_op();
80105d39:	e8 a2 da ff ff       	call   801037e0 <end_op>
    return -1;
80105d3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d43:	e9 04 01 00 00       	jmp    80105e4c <sys_link+0x1a6>
  }

  ip->nlink++;
80105d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d4b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105d4f:	83 c0 01             	add    $0x1,%eax
80105d52:	89 c2                	mov    %eax,%edx
80105d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d57:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105d5b:	83 ec 0c             	sub    $0xc,%esp
80105d5e:	ff 75 f4             	pushl  -0xc(%ebp)
80105d61:	e8 0c bc ff ff       	call   80101972 <iupdate>
80105d66:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105d69:	83 ec 0c             	sub    $0xc,%esp
80105d6c:	ff 75 f4             	pushl  -0xc(%ebp)
80105d6f:	e8 fe be ff ff       	call   80101c72 <iunlock>
80105d74:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105d77:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105d7a:	83 ec 08             	sub    $0x8,%esp
80105d7d:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105d80:	52                   	push   %edx
80105d81:	50                   	push   %eax
80105d82:	e8 5f c9 ff ff       	call   801026e6 <nameiparent>
80105d87:	83 c4 10             	add    $0x10,%esp
80105d8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d8d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d91:	74 71                	je     80105e04 <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105d93:	83 ec 0c             	sub    $0xc,%esp
80105d96:	ff 75 f0             	pushl  -0x10(%ebp)
80105d99:	e8 bd bd ff ff       	call   80101b5b <ilock>
80105d9e:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105da1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105da4:	8b 10                	mov    (%eax),%edx
80105da6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105da9:	8b 00                	mov    (%eax),%eax
80105dab:	39 c2                	cmp    %eax,%edx
80105dad:	75 1d                	jne    80105dcc <sys_link+0x126>
80105daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105db2:	8b 40 04             	mov    0x4(%eax),%eax
80105db5:	83 ec 04             	sub    $0x4,%esp
80105db8:	50                   	push   %eax
80105db9:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105dbc:	50                   	push   %eax
80105dbd:	ff 75 f0             	pushl  -0x10(%ebp)
80105dc0:	e8 5e c6 ff ff       	call   80102423 <dirlink>
80105dc5:	83 c4 10             	add    $0x10,%esp
80105dc8:	85 c0                	test   %eax,%eax
80105dca:	79 10                	jns    80105ddc <sys_link+0x136>
    iunlockput(dp);
80105dcc:	83 ec 0c             	sub    $0xc,%esp
80105dcf:	ff 75 f0             	pushl  -0x10(%ebp)
80105dd2:	e8 c1 bf ff ff       	call   80101d98 <iunlockput>
80105dd7:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105dda:	eb 29                	jmp    80105e05 <sys_link+0x15f>
  }
  iunlockput(dp);
80105ddc:	83 ec 0c             	sub    $0xc,%esp
80105ddf:	ff 75 f0             	pushl  -0x10(%ebp)
80105de2:	e8 b1 bf ff ff       	call   80101d98 <iunlockput>
80105de7:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105dea:	83 ec 0c             	sub    $0xc,%esp
80105ded:	ff 75 f4             	pushl  -0xc(%ebp)
80105df0:	e8 cf be ff ff       	call   80101cc4 <iput>
80105df5:	83 c4 10             	add    $0x10,%esp

  end_op();
80105df8:	e8 e3 d9 ff ff       	call   801037e0 <end_op>

  return 0;
80105dfd:	b8 00 00 00 00       	mov    $0x0,%eax
80105e02:	eb 48                	jmp    80105e4c <sys_link+0x1a6>
    goto bad;
80105e04:	90                   	nop

bad:
  ilock(ip);
80105e05:	83 ec 0c             	sub    $0xc,%esp
80105e08:	ff 75 f4             	pushl  -0xc(%ebp)
80105e0b:	e8 4b bd ff ff       	call   80101b5b <ilock>
80105e10:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e16:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105e1a:	83 e8 01             	sub    $0x1,%eax
80105e1d:	89 c2                	mov    %eax,%edx
80105e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e22:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105e26:	83 ec 0c             	sub    $0xc,%esp
80105e29:	ff 75 f4             	pushl  -0xc(%ebp)
80105e2c:	e8 41 bb ff ff       	call   80101972 <iupdate>
80105e31:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105e34:	83 ec 0c             	sub    $0xc,%esp
80105e37:	ff 75 f4             	pushl  -0xc(%ebp)
80105e3a:	e8 59 bf ff ff       	call   80101d98 <iunlockput>
80105e3f:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e42:	e8 99 d9 ff ff       	call   801037e0 <end_op>
  return -1;
80105e47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e4c:	c9                   	leave  
80105e4d:	c3                   	ret    

80105e4e <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105e4e:	f3 0f 1e fb          	endbr32 
80105e52:	55                   	push   %ebp
80105e53:	89 e5                	mov    %esp,%ebp
80105e55:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105e58:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105e5f:	eb 40                	jmp    80105ea1 <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e64:	6a 10                	push   $0x10
80105e66:	50                   	push   %eax
80105e67:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105e6a:	50                   	push   %eax
80105e6b:	ff 75 08             	pushl  0x8(%ebp)
80105e6e:	e8 f0 c1 ff ff       	call   80102063 <readi>
80105e73:	83 c4 10             	add    $0x10,%esp
80105e76:	83 f8 10             	cmp    $0x10,%eax
80105e79:	74 0d                	je     80105e88 <isdirempty+0x3a>
      panic("isdirempty: readi");
80105e7b:	83 ec 0c             	sub    $0xc,%esp
80105e7e:	68 78 96 10 80       	push   $0x80109678
80105e83:	e8 80 a7 ff ff       	call   80100608 <panic>
    if(de.inum != 0)
80105e88:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105e8c:	66 85 c0             	test   %ax,%ax
80105e8f:	74 07                	je     80105e98 <isdirempty+0x4a>
      return 0;
80105e91:	b8 00 00 00 00       	mov    $0x0,%eax
80105e96:	eb 1b                	jmp    80105eb3 <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105e98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e9b:	83 c0 10             	add    $0x10,%eax
80105e9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ea1:	8b 45 08             	mov    0x8(%ebp),%eax
80105ea4:	8b 50 58             	mov    0x58(%eax),%edx
80105ea7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eaa:	39 c2                	cmp    %eax,%edx
80105eac:	77 b3                	ja     80105e61 <isdirempty+0x13>
  }
  return 1;
80105eae:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105eb3:	c9                   	leave  
80105eb4:	c3                   	ret    

80105eb5 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105eb5:	f3 0f 1e fb          	endbr32 
80105eb9:	55                   	push   %ebp
80105eba:	89 e5                	mov    %esp,%ebp
80105ebc:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105ebf:	83 ec 08             	sub    $0x8,%esp
80105ec2:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105ec5:	50                   	push   %eax
80105ec6:	6a 00                	push   $0x0
80105ec8:	e8 72 fa ff ff       	call   8010593f <argstr>
80105ecd:	83 c4 10             	add    $0x10,%esp
80105ed0:	85 c0                	test   %eax,%eax
80105ed2:	79 0a                	jns    80105ede <sys_unlink+0x29>
    return -1;
80105ed4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ed9:	e9 bf 01 00 00       	jmp    8010609d <sys_unlink+0x1e8>

  begin_op();
80105ede:	e8 6d d8 ff ff       	call   80103750 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105ee3:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105ee6:	83 ec 08             	sub    $0x8,%esp
80105ee9:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105eec:	52                   	push   %edx
80105eed:	50                   	push   %eax
80105eee:	e8 f3 c7 ff ff       	call   801026e6 <nameiparent>
80105ef3:	83 c4 10             	add    $0x10,%esp
80105ef6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ef9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105efd:	75 0f                	jne    80105f0e <sys_unlink+0x59>
    end_op();
80105eff:	e8 dc d8 ff ff       	call   801037e0 <end_op>
    return -1;
80105f04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f09:	e9 8f 01 00 00       	jmp    8010609d <sys_unlink+0x1e8>
  }

  ilock(dp);
80105f0e:	83 ec 0c             	sub    $0xc,%esp
80105f11:	ff 75 f4             	pushl  -0xc(%ebp)
80105f14:	e8 42 bc ff ff       	call   80101b5b <ilock>
80105f19:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105f1c:	83 ec 08             	sub    $0x8,%esp
80105f1f:	68 8a 96 10 80       	push   $0x8010968a
80105f24:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f27:	50                   	push   %eax
80105f28:	e8 19 c4 ff ff       	call   80102346 <namecmp>
80105f2d:	83 c4 10             	add    $0x10,%esp
80105f30:	85 c0                	test   %eax,%eax
80105f32:	0f 84 49 01 00 00    	je     80106081 <sys_unlink+0x1cc>
80105f38:	83 ec 08             	sub    $0x8,%esp
80105f3b:	68 8c 96 10 80       	push   $0x8010968c
80105f40:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f43:	50                   	push   %eax
80105f44:	e8 fd c3 ff ff       	call   80102346 <namecmp>
80105f49:	83 c4 10             	add    $0x10,%esp
80105f4c:	85 c0                	test   %eax,%eax
80105f4e:	0f 84 2d 01 00 00    	je     80106081 <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105f54:	83 ec 04             	sub    $0x4,%esp
80105f57:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105f5a:	50                   	push   %eax
80105f5b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f5e:	50                   	push   %eax
80105f5f:	ff 75 f4             	pushl  -0xc(%ebp)
80105f62:	e8 fe c3 ff ff       	call   80102365 <dirlookup>
80105f67:	83 c4 10             	add    $0x10,%esp
80105f6a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f6d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f71:	0f 84 0d 01 00 00    	je     80106084 <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80105f77:	83 ec 0c             	sub    $0xc,%esp
80105f7a:	ff 75 f0             	pushl  -0x10(%ebp)
80105f7d:	e8 d9 bb ff ff       	call   80101b5b <ilock>
80105f82:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105f85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f88:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105f8c:	66 85 c0             	test   %ax,%ax
80105f8f:	7f 0d                	jg     80105f9e <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
80105f91:	83 ec 0c             	sub    $0xc,%esp
80105f94:	68 8f 96 10 80       	push   $0x8010968f
80105f99:	e8 6a a6 ff ff       	call   80100608 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105f9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fa1:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105fa5:	66 83 f8 01          	cmp    $0x1,%ax
80105fa9:	75 25                	jne    80105fd0 <sys_unlink+0x11b>
80105fab:	83 ec 0c             	sub    $0xc,%esp
80105fae:	ff 75 f0             	pushl  -0x10(%ebp)
80105fb1:	e8 98 fe ff ff       	call   80105e4e <isdirempty>
80105fb6:	83 c4 10             	add    $0x10,%esp
80105fb9:	85 c0                	test   %eax,%eax
80105fbb:	75 13                	jne    80105fd0 <sys_unlink+0x11b>
    iunlockput(ip);
80105fbd:	83 ec 0c             	sub    $0xc,%esp
80105fc0:	ff 75 f0             	pushl  -0x10(%ebp)
80105fc3:	e8 d0 bd ff ff       	call   80101d98 <iunlockput>
80105fc8:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105fcb:	e9 b5 00 00 00       	jmp    80106085 <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
80105fd0:	83 ec 04             	sub    $0x4,%esp
80105fd3:	6a 10                	push   $0x10
80105fd5:	6a 00                	push   $0x0
80105fd7:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105fda:	50                   	push   %eax
80105fdb:	e8 6e f5 ff ff       	call   8010554e <memset>
80105fe0:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105fe3:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105fe6:	6a 10                	push   $0x10
80105fe8:	50                   	push   %eax
80105fe9:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105fec:	50                   	push   %eax
80105fed:	ff 75 f4             	pushl  -0xc(%ebp)
80105ff0:	e8 c7 c1 ff ff       	call   801021bc <writei>
80105ff5:	83 c4 10             	add    $0x10,%esp
80105ff8:	83 f8 10             	cmp    $0x10,%eax
80105ffb:	74 0d                	je     8010600a <sys_unlink+0x155>
    panic("unlink: writei");
80105ffd:	83 ec 0c             	sub    $0xc,%esp
80106000:	68 a1 96 10 80       	push   $0x801096a1
80106005:	e8 fe a5 ff ff       	call   80100608 <panic>
  if(ip->type == T_DIR){
8010600a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010600d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106011:	66 83 f8 01          	cmp    $0x1,%ax
80106015:	75 21                	jne    80106038 <sys_unlink+0x183>
    dp->nlink--;
80106017:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010601a:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010601e:	83 e8 01             	sub    $0x1,%eax
80106021:	89 c2                	mov    %eax,%edx
80106023:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106026:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
8010602a:	83 ec 0c             	sub    $0xc,%esp
8010602d:	ff 75 f4             	pushl  -0xc(%ebp)
80106030:	e8 3d b9 ff ff       	call   80101972 <iupdate>
80106035:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80106038:	83 ec 0c             	sub    $0xc,%esp
8010603b:	ff 75 f4             	pushl  -0xc(%ebp)
8010603e:	e8 55 bd ff ff       	call   80101d98 <iunlockput>
80106043:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80106046:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106049:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010604d:	83 e8 01             	sub    $0x1,%eax
80106050:	89 c2                	mov    %eax,%edx
80106052:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106055:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80106059:	83 ec 0c             	sub    $0xc,%esp
8010605c:	ff 75 f0             	pushl  -0x10(%ebp)
8010605f:	e8 0e b9 ff ff       	call   80101972 <iupdate>
80106064:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106067:	83 ec 0c             	sub    $0xc,%esp
8010606a:	ff 75 f0             	pushl  -0x10(%ebp)
8010606d:	e8 26 bd ff ff       	call   80101d98 <iunlockput>
80106072:	83 c4 10             	add    $0x10,%esp

  end_op();
80106075:	e8 66 d7 ff ff       	call   801037e0 <end_op>

  return 0;
8010607a:	b8 00 00 00 00       	mov    $0x0,%eax
8010607f:	eb 1c                	jmp    8010609d <sys_unlink+0x1e8>
    goto bad;
80106081:	90                   	nop
80106082:	eb 01                	jmp    80106085 <sys_unlink+0x1d0>
    goto bad;
80106084:	90                   	nop

bad:
  iunlockput(dp);
80106085:	83 ec 0c             	sub    $0xc,%esp
80106088:	ff 75 f4             	pushl  -0xc(%ebp)
8010608b:	e8 08 bd ff ff       	call   80101d98 <iunlockput>
80106090:	83 c4 10             	add    $0x10,%esp
  end_op();
80106093:	e8 48 d7 ff ff       	call   801037e0 <end_op>
  return -1;
80106098:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010609d:	c9                   	leave  
8010609e:	c3                   	ret    

8010609f <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010609f:	f3 0f 1e fb          	endbr32 
801060a3:	55                   	push   %ebp
801060a4:	89 e5                	mov    %esp,%ebp
801060a6:	83 ec 38             	sub    $0x38,%esp
801060a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801060ac:	8b 55 10             	mov    0x10(%ebp),%edx
801060af:	8b 45 14             	mov    0x14(%ebp),%eax
801060b2:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801060b6:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801060ba:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801060be:	83 ec 08             	sub    $0x8,%esp
801060c1:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801060c4:	50                   	push   %eax
801060c5:	ff 75 08             	pushl  0x8(%ebp)
801060c8:	e8 19 c6 ff ff       	call   801026e6 <nameiparent>
801060cd:	83 c4 10             	add    $0x10,%esp
801060d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060d7:	75 0a                	jne    801060e3 <create+0x44>
    return 0;
801060d9:	b8 00 00 00 00       	mov    $0x0,%eax
801060de:	e9 8e 01 00 00       	jmp    80106271 <create+0x1d2>
  ilock(dp);
801060e3:	83 ec 0c             	sub    $0xc,%esp
801060e6:	ff 75 f4             	pushl  -0xc(%ebp)
801060e9:	e8 6d ba ff ff       	call   80101b5b <ilock>
801060ee:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, 0)) != 0){
801060f1:	83 ec 04             	sub    $0x4,%esp
801060f4:	6a 00                	push   $0x0
801060f6:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801060f9:	50                   	push   %eax
801060fa:	ff 75 f4             	pushl  -0xc(%ebp)
801060fd:	e8 63 c2 ff ff       	call   80102365 <dirlookup>
80106102:	83 c4 10             	add    $0x10,%esp
80106105:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106108:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010610c:	74 50                	je     8010615e <create+0xbf>
    iunlockput(dp);
8010610e:	83 ec 0c             	sub    $0xc,%esp
80106111:	ff 75 f4             	pushl  -0xc(%ebp)
80106114:	e8 7f bc ff ff       	call   80101d98 <iunlockput>
80106119:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
8010611c:	83 ec 0c             	sub    $0xc,%esp
8010611f:	ff 75 f0             	pushl  -0x10(%ebp)
80106122:	e8 34 ba ff ff       	call   80101b5b <ilock>
80106127:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010612a:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
8010612f:	75 15                	jne    80106146 <create+0xa7>
80106131:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106134:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106138:	66 83 f8 02          	cmp    $0x2,%ax
8010613c:	75 08                	jne    80106146 <create+0xa7>
      return ip;
8010613e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106141:	e9 2b 01 00 00       	jmp    80106271 <create+0x1d2>
    iunlockput(ip);
80106146:	83 ec 0c             	sub    $0xc,%esp
80106149:	ff 75 f0             	pushl  -0x10(%ebp)
8010614c:	e8 47 bc ff ff       	call   80101d98 <iunlockput>
80106151:	83 c4 10             	add    $0x10,%esp
    return 0;
80106154:	b8 00 00 00 00       	mov    $0x0,%eax
80106159:	e9 13 01 00 00       	jmp    80106271 <create+0x1d2>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010615e:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106165:	8b 00                	mov    (%eax),%eax
80106167:	83 ec 08             	sub    $0x8,%esp
8010616a:	52                   	push   %edx
8010616b:	50                   	push   %eax
8010616c:	e8 26 b7 ff ff       	call   80101897 <ialloc>
80106171:	83 c4 10             	add    $0x10,%esp
80106174:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106177:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010617b:	75 0d                	jne    8010618a <create+0xeb>
    panic("create: ialloc");
8010617d:	83 ec 0c             	sub    $0xc,%esp
80106180:	68 b0 96 10 80       	push   $0x801096b0
80106185:	e8 7e a4 ff ff       	call   80100608 <panic>

  ilock(ip);
8010618a:	83 ec 0c             	sub    $0xc,%esp
8010618d:	ff 75 f0             	pushl  -0x10(%ebp)
80106190:	e8 c6 b9 ff ff       	call   80101b5b <ilock>
80106195:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80106198:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010619b:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010619f:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
801061a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061a6:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801061aa:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
801061ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061b1:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801061b7:	83 ec 0c             	sub    $0xc,%esp
801061ba:	ff 75 f0             	pushl  -0x10(%ebp)
801061bd:	e8 b0 b7 ff ff       	call   80101972 <iupdate>
801061c2:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801061c5:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801061ca:	75 6a                	jne    80106236 <create+0x197>
    dp->nlink++;  // for ".."
801061cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061cf:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801061d3:	83 c0 01             	add    $0x1,%eax
801061d6:	89 c2                	mov    %eax,%edx
801061d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061db:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801061df:	83 ec 0c             	sub    $0xc,%esp
801061e2:	ff 75 f4             	pushl  -0xc(%ebp)
801061e5:	e8 88 b7 ff ff       	call   80101972 <iupdate>
801061ea:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801061ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061f0:	8b 40 04             	mov    0x4(%eax),%eax
801061f3:	83 ec 04             	sub    $0x4,%esp
801061f6:	50                   	push   %eax
801061f7:	68 8a 96 10 80       	push   $0x8010968a
801061fc:	ff 75 f0             	pushl  -0x10(%ebp)
801061ff:	e8 1f c2 ff ff       	call   80102423 <dirlink>
80106204:	83 c4 10             	add    $0x10,%esp
80106207:	85 c0                	test   %eax,%eax
80106209:	78 1e                	js     80106229 <create+0x18a>
8010620b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010620e:	8b 40 04             	mov    0x4(%eax),%eax
80106211:	83 ec 04             	sub    $0x4,%esp
80106214:	50                   	push   %eax
80106215:	68 8c 96 10 80       	push   $0x8010968c
8010621a:	ff 75 f0             	pushl  -0x10(%ebp)
8010621d:	e8 01 c2 ff ff       	call   80102423 <dirlink>
80106222:	83 c4 10             	add    $0x10,%esp
80106225:	85 c0                	test   %eax,%eax
80106227:	79 0d                	jns    80106236 <create+0x197>
      panic("create dots");
80106229:	83 ec 0c             	sub    $0xc,%esp
8010622c:	68 bf 96 10 80       	push   $0x801096bf
80106231:	e8 d2 a3 ff ff       	call   80100608 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106236:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106239:	8b 40 04             	mov    0x4(%eax),%eax
8010623c:	83 ec 04             	sub    $0x4,%esp
8010623f:	50                   	push   %eax
80106240:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106243:	50                   	push   %eax
80106244:	ff 75 f4             	pushl  -0xc(%ebp)
80106247:	e8 d7 c1 ff ff       	call   80102423 <dirlink>
8010624c:	83 c4 10             	add    $0x10,%esp
8010624f:	85 c0                	test   %eax,%eax
80106251:	79 0d                	jns    80106260 <create+0x1c1>
    panic("create: dirlink");
80106253:	83 ec 0c             	sub    $0xc,%esp
80106256:	68 cb 96 10 80       	push   $0x801096cb
8010625b:	e8 a8 a3 ff ff       	call   80100608 <panic>

  iunlockput(dp);
80106260:	83 ec 0c             	sub    $0xc,%esp
80106263:	ff 75 f4             	pushl  -0xc(%ebp)
80106266:	e8 2d bb ff ff       	call   80101d98 <iunlockput>
8010626b:	83 c4 10             	add    $0x10,%esp

  return ip;
8010626e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106271:	c9                   	leave  
80106272:	c3                   	ret    

80106273 <sys_open>:

int
sys_open(void)
{
80106273:	f3 0f 1e fb          	endbr32 
80106277:	55                   	push   %ebp
80106278:	89 e5                	mov    %esp,%ebp
8010627a:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010627d:	83 ec 08             	sub    $0x8,%esp
80106280:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106283:	50                   	push   %eax
80106284:	6a 00                	push   $0x0
80106286:	e8 b4 f6 ff ff       	call   8010593f <argstr>
8010628b:	83 c4 10             	add    $0x10,%esp
8010628e:	85 c0                	test   %eax,%eax
80106290:	78 15                	js     801062a7 <sys_open+0x34>
80106292:	83 ec 08             	sub    $0x8,%esp
80106295:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106298:	50                   	push   %eax
80106299:	6a 01                	push   $0x1
8010629b:	e8 02 f6 ff ff       	call   801058a2 <argint>
801062a0:	83 c4 10             	add    $0x10,%esp
801062a3:	85 c0                	test   %eax,%eax
801062a5:	79 0a                	jns    801062b1 <sys_open+0x3e>
    return -1;
801062a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062ac:	e9 61 01 00 00       	jmp    80106412 <sys_open+0x19f>

  begin_op();
801062b1:	e8 9a d4 ff ff       	call   80103750 <begin_op>

  if(omode & O_CREATE){
801062b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062b9:	25 00 02 00 00       	and    $0x200,%eax
801062be:	85 c0                	test   %eax,%eax
801062c0:	74 2a                	je     801062ec <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
801062c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062c5:	6a 00                	push   $0x0
801062c7:	6a 00                	push   $0x0
801062c9:	6a 02                	push   $0x2
801062cb:	50                   	push   %eax
801062cc:	e8 ce fd ff ff       	call   8010609f <create>
801062d1:	83 c4 10             	add    $0x10,%esp
801062d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801062d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062db:	75 75                	jne    80106352 <sys_open+0xdf>
      end_op();
801062dd:	e8 fe d4 ff ff       	call   801037e0 <end_op>
      return -1;
801062e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062e7:	e9 26 01 00 00       	jmp    80106412 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
801062ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062ef:	83 ec 0c             	sub    $0xc,%esp
801062f2:	50                   	push   %eax
801062f3:	e8 ce c3 ff ff       	call   801026c6 <namei>
801062f8:	83 c4 10             	add    $0x10,%esp
801062fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106302:	75 0f                	jne    80106313 <sys_open+0xa0>
      end_op();
80106304:	e8 d7 d4 ff ff       	call   801037e0 <end_op>
      return -1;
80106309:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010630e:	e9 ff 00 00 00       	jmp    80106412 <sys_open+0x19f>
    }
    ilock(ip);
80106313:	83 ec 0c             	sub    $0xc,%esp
80106316:	ff 75 f4             	pushl  -0xc(%ebp)
80106319:	e8 3d b8 ff ff       	call   80101b5b <ilock>
8010631e:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106321:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106324:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106328:	66 83 f8 01          	cmp    $0x1,%ax
8010632c:	75 24                	jne    80106352 <sys_open+0xdf>
8010632e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106331:	85 c0                	test   %eax,%eax
80106333:	74 1d                	je     80106352 <sys_open+0xdf>
      iunlockput(ip);
80106335:	83 ec 0c             	sub    $0xc,%esp
80106338:	ff 75 f4             	pushl  -0xc(%ebp)
8010633b:	e8 58 ba ff ff       	call   80101d98 <iunlockput>
80106340:	83 c4 10             	add    $0x10,%esp
      end_op();
80106343:	e8 98 d4 ff ff       	call   801037e0 <end_op>
      return -1;
80106348:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010634d:	e9 c0 00 00 00       	jmp    80106412 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106352:	e8 be ad ff ff       	call   80101115 <filealloc>
80106357:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010635a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010635e:	74 17                	je     80106377 <sys_open+0x104>
80106360:	83 ec 0c             	sub    $0xc,%esp
80106363:	ff 75 f0             	pushl  -0x10(%ebp)
80106366:	e8 09 f7 ff ff       	call   80105a74 <fdalloc>
8010636b:	83 c4 10             	add    $0x10,%esp
8010636e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106371:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106375:	79 2e                	jns    801063a5 <sys_open+0x132>
    if(f)
80106377:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010637b:	74 0e                	je     8010638b <sys_open+0x118>
      fileclose(f);
8010637d:	83 ec 0c             	sub    $0xc,%esp
80106380:	ff 75 f0             	pushl  -0x10(%ebp)
80106383:	e8 53 ae ff ff       	call   801011db <fileclose>
80106388:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010638b:	83 ec 0c             	sub    $0xc,%esp
8010638e:	ff 75 f4             	pushl  -0xc(%ebp)
80106391:	e8 02 ba ff ff       	call   80101d98 <iunlockput>
80106396:	83 c4 10             	add    $0x10,%esp
    end_op();
80106399:	e8 42 d4 ff ff       	call   801037e0 <end_op>
    return -1;
8010639e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063a3:	eb 6d                	jmp    80106412 <sys_open+0x19f>
  }
  iunlock(ip);
801063a5:	83 ec 0c             	sub    $0xc,%esp
801063a8:	ff 75 f4             	pushl  -0xc(%ebp)
801063ab:	e8 c2 b8 ff ff       	call   80101c72 <iunlock>
801063b0:	83 c4 10             	add    $0x10,%esp
  end_op();
801063b3:	e8 28 d4 ff ff       	call   801037e0 <end_op>

  f->type = FD_INODE;
801063b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063bb:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801063c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063c7:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801063ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063cd:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801063d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063d7:	83 e0 01             	and    $0x1,%eax
801063da:	85 c0                	test   %eax,%eax
801063dc:	0f 94 c0             	sete   %al
801063df:	89 c2                	mov    %eax,%edx
801063e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063e4:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801063e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063ea:	83 e0 01             	and    $0x1,%eax
801063ed:	85 c0                	test   %eax,%eax
801063ef:	75 0a                	jne    801063fb <sys_open+0x188>
801063f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063f4:	83 e0 02             	and    $0x2,%eax
801063f7:	85 c0                	test   %eax,%eax
801063f9:	74 07                	je     80106402 <sys_open+0x18f>
801063fb:	b8 01 00 00 00       	mov    $0x1,%eax
80106400:	eb 05                	jmp    80106407 <sys_open+0x194>
80106402:	b8 00 00 00 00       	mov    $0x0,%eax
80106407:	89 c2                	mov    %eax,%edx
80106409:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010640c:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010640f:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106412:	c9                   	leave  
80106413:	c3                   	ret    

80106414 <sys_mkdir>:

int
sys_mkdir(void)
{
80106414:	f3 0f 1e fb          	endbr32 
80106418:	55                   	push   %ebp
80106419:	89 e5                	mov    %esp,%ebp
8010641b:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010641e:	e8 2d d3 ff ff       	call   80103750 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106423:	83 ec 08             	sub    $0x8,%esp
80106426:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106429:	50                   	push   %eax
8010642a:	6a 00                	push   $0x0
8010642c:	e8 0e f5 ff ff       	call   8010593f <argstr>
80106431:	83 c4 10             	add    $0x10,%esp
80106434:	85 c0                	test   %eax,%eax
80106436:	78 1b                	js     80106453 <sys_mkdir+0x3f>
80106438:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010643b:	6a 00                	push   $0x0
8010643d:	6a 00                	push   $0x0
8010643f:	6a 01                	push   $0x1
80106441:	50                   	push   %eax
80106442:	e8 58 fc ff ff       	call   8010609f <create>
80106447:	83 c4 10             	add    $0x10,%esp
8010644a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010644d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106451:	75 0c                	jne    8010645f <sys_mkdir+0x4b>
    end_op();
80106453:	e8 88 d3 ff ff       	call   801037e0 <end_op>
    return -1;
80106458:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010645d:	eb 18                	jmp    80106477 <sys_mkdir+0x63>
  }
  iunlockput(ip);
8010645f:	83 ec 0c             	sub    $0xc,%esp
80106462:	ff 75 f4             	pushl  -0xc(%ebp)
80106465:	e8 2e b9 ff ff       	call   80101d98 <iunlockput>
8010646a:	83 c4 10             	add    $0x10,%esp
  end_op();
8010646d:	e8 6e d3 ff ff       	call   801037e0 <end_op>
  return 0;
80106472:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106477:	c9                   	leave  
80106478:	c3                   	ret    

80106479 <sys_mknod>:

int
sys_mknod(void)
{
80106479:	f3 0f 1e fb          	endbr32 
8010647d:	55                   	push   %ebp
8010647e:	89 e5                	mov    %esp,%ebp
80106480:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106483:	e8 c8 d2 ff ff       	call   80103750 <begin_op>
  if((argstr(0, &path)) < 0 ||
80106488:	83 ec 08             	sub    $0x8,%esp
8010648b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010648e:	50                   	push   %eax
8010648f:	6a 00                	push   $0x0
80106491:	e8 a9 f4 ff ff       	call   8010593f <argstr>
80106496:	83 c4 10             	add    $0x10,%esp
80106499:	85 c0                	test   %eax,%eax
8010649b:	78 4f                	js     801064ec <sys_mknod+0x73>
     argint(1, &major) < 0 ||
8010649d:	83 ec 08             	sub    $0x8,%esp
801064a0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801064a3:	50                   	push   %eax
801064a4:	6a 01                	push   $0x1
801064a6:	e8 f7 f3 ff ff       	call   801058a2 <argint>
801064ab:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
801064ae:	85 c0                	test   %eax,%eax
801064b0:	78 3a                	js     801064ec <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
801064b2:	83 ec 08             	sub    $0x8,%esp
801064b5:	8d 45 e8             	lea    -0x18(%ebp),%eax
801064b8:	50                   	push   %eax
801064b9:	6a 02                	push   $0x2
801064bb:	e8 e2 f3 ff ff       	call   801058a2 <argint>
801064c0:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
801064c3:	85 c0                	test   %eax,%eax
801064c5:	78 25                	js     801064ec <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
801064c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064ca:	0f bf c8             	movswl %ax,%ecx
801064cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801064d0:	0f bf d0             	movswl %ax,%edx
801064d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064d6:	51                   	push   %ecx
801064d7:	52                   	push   %edx
801064d8:	6a 03                	push   $0x3
801064da:	50                   	push   %eax
801064db:	e8 bf fb ff ff       	call   8010609f <create>
801064e0:	83 c4 10             	add    $0x10,%esp
801064e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
801064e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064ea:	75 0c                	jne    801064f8 <sys_mknod+0x7f>
    end_op();
801064ec:	e8 ef d2 ff ff       	call   801037e0 <end_op>
    return -1;
801064f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064f6:	eb 18                	jmp    80106510 <sys_mknod+0x97>
  }
  iunlockput(ip);
801064f8:	83 ec 0c             	sub    $0xc,%esp
801064fb:	ff 75 f4             	pushl  -0xc(%ebp)
801064fe:	e8 95 b8 ff ff       	call   80101d98 <iunlockput>
80106503:	83 c4 10             	add    $0x10,%esp
  end_op();
80106506:	e8 d5 d2 ff ff       	call   801037e0 <end_op>
  return 0;
8010650b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106510:	c9                   	leave  
80106511:	c3                   	ret    

80106512 <sys_chdir>:

int
sys_chdir(void)
{
80106512:	f3 0f 1e fb          	endbr32 
80106516:	55                   	push   %ebp
80106517:	89 e5                	mov    %esp,%ebp
80106519:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
8010651c:	e8 ee df ff ff       	call   8010450f <myproc>
80106521:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80106524:	e8 27 d2 ff ff       	call   80103750 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106529:	83 ec 08             	sub    $0x8,%esp
8010652c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010652f:	50                   	push   %eax
80106530:	6a 00                	push   $0x0
80106532:	e8 08 f4 ff ff       	call   8010593f <argstr>
80106537:	83 c4 10             	add    $0x10,%esp
8010653a:	85 c0                	test   %eax,%eax
8010653c:	78 18                	js     80106556 <sys_chdir+0x44>
8010653e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106541:	83 ec 0c             	sub    $0xc,%esp
80106544:	50                   	push   %eax
80106545:	e8 7c c1 ff ff       	call   801026c6 <namei>
8010654a:	83 c4 10             	add    $0x10,%esp
8010654d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106550:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106554:	75 0c                	jne    80106562 <sys_chdir+0x50>
    end_op();
80106556:	e8 85 d2 ff ff       	call   801037e0 <end_op>
    return -1;
8010655b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106560:	eb 68                	jmp    801065ca <sys_chdir+0xb8>
  }
  ilock(ip);
80106562:	83 ec 0c             	sub    $0xc,%esp
80106565:	ff 75 f0             	pushl  -0x10(%ebp)
80106568:	e8 ee b5 ff ff       	call   80101b5b <ilock>
8010656d:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106570:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106573:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106577:	66 83 f8 01          	cmp    $0x1,%ax
8010657b:	74 1a                	je     80106597 <sys_chdir+0x85>
    iunlockput(ip);
8010657d:	83 ec 0c             	sub    $0xc,%esp
80106580:	ff 75 f0             	pushl  -0x10(%ebp)
80106583:	e8 10 b8 ff ff       	call   80101d98 <iunlockput>
80106588:	83 c4 10             	add    $0x10,%esp
    end_op();
8010658b:	e8 50 d2 ff ff       	call   801037e0 <end_op>
    return -1;
80106590:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106595:	eb 33                	jmp    801065ca <sys_chdir+0xb8>
  }
  iunlock(ip);
80106597:	83 ec 0c             	sub    $0xc,%esp
8010659a:	ff 75 f0             	pushl  -0x10(%ebp)
8010659d:	e8 d0 b6 ff ff       	call   80101c72 <iunlock>
801065a2:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
801065a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065a8:	8b 40 68             	mov    0x68(%eax),%eax
801065ab:	83 ec 0c             	sub    $0xc,%esp
801065ae:	50                   	push   %eax
801065af:	e8 10 b7 ff ff       	call   80101cc4 <iput>
801065b4:	83 c4 10             	add    $0x10,%esp
  end_op();
801065b7:	e8 24 d2 ff ff       	call   801037e0 <end_op>
  curproc->cwd = ip;
801065bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065bf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801065c2:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801065c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065ca:	c9                   	leave  
801065cb:	c3                   	ret    

801065cc <sys_exec>:

int
sys_exec(void)
{
801065cc:	f3 0f 1e fb          	endbr32 
801065d0:	55                   	push   %ebp
801065d1:	89 e5                	mov    %esp,%ebp
801065d3:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801065d9:	83 ec 08             	sub    $0x8,%esp
801065dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065df:	50                   	push   %eax
801065e0:	6a 00                	push   $0x0
801065e2:	e8 58 f3 ff ff       	call   8010593f <argstr>
801065e7:	83 c4 10             	add    $0x10,%esp
801065ea:	85 c0                	test   %eax,%eax
801065ec:	78 18                	js     80106606 <sys_exec+0x3a>
801065ee:	83 ec 08             	sub    $0x8,%esp
801065f1:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801065f7:	50                   	push   %eax
801065f8:	6a 01                	push   $0x1
801065fa:	e8 a3 f2 ff ff       	call   801058a2 <argint>
801065ff:	83 c4 10             	add    $0x10,%esp
80106602:	85 c0                	test   %eax,%eax
80106604:	79 0a                	jns    80106610 <sys_exec+0x44>
    return -1;
80106606:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010660b:	e9 c6 00 00 00       	jmp    801066d6 <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
80106610:	83 ec 04             	sub    $0x4,%esp
80106613:	68 80 00 00 00       	push   $0x80
80106618:	6a 00                	push   $0x0
8010661a:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106620:	50                   	push   %eax
80106621:	e8 28 ef ff ff       	call   8010554e <memset>
80106626:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106629:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106630:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106633:	83 f8 1f             	cmp    $0x1f,%eax
80106636:	76 0a                	jbe    80106642 <sys_exec+0x76>
      return -1;
80106638:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010663d:	e9 94 00 00 00       	jmp    801066d6 <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106642:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106645:	c1 e0 02             	shl    $0x2,%eax
80106648:	89 c2                	mov    %eax,%edx
8010664a:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106650:	01 c2                	add    %eax,%edx
80106652:	83 ec 08             	sub    $0x8,%esp
80106655:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
8010665b:	50                   	push   %eax
8010665c:	52                   	push   %edx
8010665d:	e8 95 f1 ff ff       	call   801057f7 <fetchint>
80106662:	83 c4 10             	add    $0x10,%esp
80106665:	85 c0                	test   %eax,%eax
80106667:	79 07                	jns    80106670 <sys_exec+0xa4>
      return -1;
80106669:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010666e:	eb 66                	jmp    801066d6 <sys_exec+0x10a>
    if(uarg == 0){
80106670:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106676:	85 c0                	test   %eax,%eax
80106678:	75 27                	jne    801066a1 <sys_exec+0xd5>
      argv[i] = 0;
8010667a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010667d:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106684:	00 00 00 00 
      break;
80106688:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106689:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010668c:	83 ec 08             	sub    $0x8,%esp
8010668f:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106695:	52                   	push   %edx
80106696:	50                   	push   %eax
80106697:	e8 94 a5 ff ff       	call   80100c30 <exec>
8010669c:	83 c4 10             	add    $0x10,%esp
8010669f:	eb 35                	jmp    801066d6 <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
801066a1:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801066a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066aa:	c1 e2 02             	shl    $0x2,%edx
801066ad:	01 c2                	add    %eax,%edx
801066af:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801066b5:	83 ec 08             	sub    $0x8,%esp
801066b8:	52                   	push   %edx
801066b9:	50                   	push   %eax
801066ba:	e8 7b f1 ff ff       	call   8010583a <fetchstr>
801066bf:	83 c4 10             	add    $0x10,%esp
801066c2:	85 c0                	test   %eax,%eax
801066c4:	79 07                	jns    801066cd <sys_exec+0x101>
      return -1;
801066c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066cb:	eb 09                	jmp    801066d6 <sys_exec+0x10a>
  for(i=0;; i++){
801066cd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
801066d1:	e9 5a ff ff ff       	jmp    80106630 <sys_exec+0x64>
}
801066d6:	c9                   	leave  
801066d7:	c3                   	ret    

801066d8 <sys_pipe>:

int
sys_pipe(void)
{
801066d8:	f3 0f 1e fb          	endbr32 
801066dc:	55                   	push   %ebp
801066dd:	89 e5                	mov    %esp,%ebp
801066df:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801066e2:	83 ec 04             	sub    $0x4,%esp
801066e5:	6a 08                	push   $0x8
801066e7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801066ea:	50                   	push   %eax
801066eb:	6a 00                	push   $0x0
801066ed:	e8 e1 f1 ff ff       	call   801058d3 <argptr>
801066f2:	83 c4 10             	add    $0x10,%esp
801066f5:	85 c0                	test   %eax,%eax
801066f7:	79 0a                	jns    80106703 <sys_pipe+0x2b>
    return -1;
801066f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066fe:	e9 ae 00 00 00       	jmp    801067b1 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
80106703:	83 ec 08             	sub    $0x8,%esp
80106706:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106709:	50                   	push   %eax
8010670a:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010670d:	50                   	push   %eax
8010670e:	e8 1d d9 ff ff       	call   80104030 <pipealloc>
80106713:	83 c4 10             	add    $0x10,%esp
80106716:	85 c0                	test   %eax,%eax
80106718:	79 0a                	jns    80106724 <sys_pipe+0x4c>
    return -1;
8010671a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010671f:	e9 8d 00 00 00       	jmp    801067b1 <sys_pipe+0xd9>
  fd0 = -1;
80106724:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010672b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010672e:	83 ec 0c             	sub    $0xc,%esp
80106731:	50                   	push   %eax
80106732:	e8 3d f3 ff ff       	call   80105a74 <fdalloc>
80106737:	83 c4 10             	add    $0x10,%esp
8010673a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010673d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106741:	78 18                	js     8010675b <sys_pipe+0x83>
80106743:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106746:	83 ec 0c             	sub    $0xc,%esp
80106749:	50                   	push   %eax
8010674a:	e8 25 f3 ff ff       	call   80105a74 <fdalloc>
8010674f:	83 c4 10             	add    $0x10,%esp
80106752:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106755:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106759:	79 3e                	jns    80106799 <sys_pipe+0xc1>
    if(fd0 >= 0)
8010675b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010675f:	78 13                	js     80106774 <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
80106761:	e8 a9 dd ff ff       	call   8010450f <myproc>
80106766:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106769:	83 c2 08             	add    $0x8,%edx
8010676c:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106773:	00 
    fileclose(rf);
80106774:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106777:	83 ec 0c             	sub    $0xc,%esp
8010677a:	50                   	push   %eax
8010677b:	e8 5b aa ff ff       	call   801011db <fileclose>
80106780:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106783:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106786:	83 ec 0c             	sub    $0xc,%esp
80106789:	50                   	push   %eax
8010678a:	e8 4c aa ff ff       	call   801011db <fileclose>
8010678f:	83 c4 10             	add    $0x10,%esp
    return -1;
80106792:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106797:	eb 18                	jmp    801067b1 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
80106799:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010679c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010679f:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801067a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801067a4:	8d 50 04             	lea    0x4(%eax),%edx
801067a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067aa:	89 02                	mov    %eax,(%edx)
  return 0;
801067ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067b1:	c9                   	leave  
801067b2:	c3                   	ret    

801067b3 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801067b3:	f3 0f 1e fb          	endbr32 
801067b7:	55                   	push   %ebp
801067b8:	89 e5                	mov    %esp,%ebp
801067ba:	83 ec 08             	sub    $0x8,%esp
  return fork();
801067bd:	e8 ac e0 ff ff       	call   8010486e <fork>
}
801067c2:	c9                   	leave  
801067c3:	c3                   	ret    

801067c4 <sys_exit>:

int
sys_exit(void)
{
801067c4:	f3 0f 1e fb          	endbr32 
801067c8:	55                   	push   %ebp
801067c9:	89 e5                	mov    %esp,%ebp
801067cb:	83 ec 08             	sub    $0x8,%esp
  exit();
801067ce:	e8 18 e2 ff ff       	call   801049eb <exit>
  return 0;  // not reached
801067d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067d8:	c9                   	leave  
801067d9:	c3                   	ret    

801067da <sys_wait>:

int
sys_wait(void)
{
801067da:	f3 0f 1e fb          	endbr32 
801067de:	55                   	push   %ebp
801067df:	89 e5                	mov    %esp,%ebp
801067e1:	83 ec 08             	sub    $0x8,%esp
  return wait();
801067e4:	e8 29 e3 ff ff       	call   80104b12 <wait>
}
801067e9:	c9                   	leave  
801067ea:	c3                   	ret    

801067eb <sys_kill>:

int
sys_kill(void)
{
801067eb:	f3 0f 1e fb          	endbr32 
801067ef:	55                   	push   %ebp
801067f0:	89 e5                	mov    %esp,%ebp
801067f2:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801067f5:	83 ec 08             	sub    $0x8,%esp
801067f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801067fb:	50                   	push   %eax
801067fc:	6a 00                	push   $0x0
801067fe:	e8 9f f0 ff ff       	call   801058a2 <argint>
80106803:	83 c4 10             	add    $0x10,%esp
80106806:	85 c0                	test   %eax,%eax
80106808:	79 07                	jns    80106811 <sys_kill+0x26>
    return -1;
8010680a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010680f:	eb 0f                	jmp    80106820 <sys_kill+0x35>
  return kill(pid);
80106811:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106814:	83 ec 0c             	sub    $0xc,%esp
80106817:	50                   	push   %eax
80106818:	e8 4d e7 ff ff       	call   80104f6a <kill>
8010681d:	83 c4 10             	add    $0x10,%esp
}
80106820:	c9                   	leave  
80106821:	c3                   	ret    

80106822 <sys_getpid>:

int
sys_getpid(void)
{
80106822:	f3 0f 1e fb          	endbr32 
80106826:	55                   	push   %ebp
80106827:	89 e5                	mov    %esp,%ebp
80106829:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010682c:	e8 de dc ff ff       	call   8010450f <myproc>
80106831:	8b 40 10             	mov    0x10(%eax),%eax
}
80106834:	c9                   	leave  
80106835:	c3                   	ret    

80106836 <sys_sbrk>:

int
sys_sbrk(void)
{
80106836:	f3 0f 1e fb          	endbr32 
8010683a:	55                   	push   %ebp
8010683b:	89 e5                	mov    %esp,%ebp
8010683d:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106840:	83 ec 08             	sub    $0x8,%esp
80106843:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106846:	50                   	push   %eax
80106847:	6a 00                	push   $0x0
80106849:	e8 54 f0 ff ff       	call   801058a2 <argint>
8010684e:	83 c4 10             	add    $0x10,%esp
80106851:	85 c0                	test   %eax,%eax
80106853:	79 07                	jns    8010685c <sys_sbrk+0x26>
    return -1;
80106855:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010685a:	eb 27                	jmp    80106883 <sys_sbrk+0x4d>
  addr = myproc()->sz;
8010685c:	e8 ae dc ff ff       	call   8010450f <myproc>
80106861:	8b 00                	mov    (%eax),%eax
80106863:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106866:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106869:	83 ec 0c             	sub    $0xc,%esp
8010686c:	50                   	push   %eax
8010686d:	e8 14 df ff ff       	call   80104786 <growproc>
80106872:	83 c4 10             	add    $0x10,%esp
80106875:	85 c0                	test   %eax,%eax
80106877:	79 07                	jns    80106880 <sys_sbrk+0x4a>
    return -1;
80106879:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010687e:	eb 03                	jmp    80106883 <sys_sbrk+0x4d>
  return addr;
80106880:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106883:	c9                   	leave  
80106884:	c3                   	ret    

80106885 <sys_sleep>:

int
sys_sleep(void)
{
80106885:	f3 0f 1e fb          	endbr32 
80106889:	55                   	push   %ebp
8010688a:	89 e5                	mov    %esp,%ebp
8010688c:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
8010688f:	83 ec 08             	sub    $0x8,%esp
80106892:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106895:	50                   	push   %eax
80106896:	6a 00                	push   $0x0
80106898:	e8 05 f0 ff ff       	call   801058a2 <argint>
8010689d:	83 c4 10             	add    $0x10,%esp
801068a0:	85 c0                	test   %eax,%eax
801068a2:	79 07                	jns    801068ab <sys_sleep+0x26>
    return -1;
801068a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068a9:	eb 76                	jmp    80106921 <sys_sleep+0x9c>
  acquire(&tickslock);
801068ab:	83 ec 0c             	sub    $0xc,%esp
801068ae:	68 00 77 11 80       	push   $0x80117700
801068b3:	e8 f7 e9 ff ff       	call   801052af <acquire>
801068b8:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801068bb:	a1 40 7f 11 80       	mov    0x80117f40,%eax
801068c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801068c3:	eb 38                	jmp    801068fd <sys_sleep+0x78>
    if(myproc()->killed){
801068c5:	e8 45 dc ff ff       	call   8010450f <myproc>
801068ca:	8b 40 24             	mov    0x24(%eax),%eax
801068cd:	85 c0                	test   %eax,%eax
801068cf:	74 17                	je     801068e8 <sys_sleep+0x63>
      release(&tickslock);
801068d1:	83 ec 0c             	sub    $0xc,%esp
801068d4:	68 00 77 11 80       	push   $0x80117700
801068d9:	e8 43 ea ff ff       	call   80105321 <release>
801068de:	83 c4 10             	add    $0x10,%esp
      return -1;
801068e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068e6:	eb 39                	jmp    80106921 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
801068e8:	83 ec 08             	sub    $0x8,%esp
801068eb:	68 00 77 11 80       	push   $0x80117700
801068f0:	68 40 7f 11 80       	push   $0x80117f40
801068f5:	e8 43 e5 ff ff       	call   80104e3d <sleep>
801068fa:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
801068fd:	a1 40 7f 11 80       	mov    0x80117f40,%eax
80106902:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106905:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106908:	39 d0                	cmp    %edx,%eax
8010690a:	72 b9                	jb     801068c5 <sys_sleep+0x40>
  }
  release(&tickslock);
8010690c:	83 ec 0c             	sub    $0xc,%esp
8010690f:	68 00 77 11 80       	push   $0x80117700
80106914:	e8 08 ea ff ff       	call   80105321 <release>
80106919:	83 c4 10             	add    $0x10,%esp
  return 0;
8010691c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106921:	c9                   	leave  
80106922:	c3                   	ret    

80106923 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106923:	f3 0f 1e fb          	endbr32 
80106927:	55                   	push   %ebp
80106928:	89 e5                	mov    %esp,%ebp
8010692a:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
8010692d:	83 ec 0c             	sub    $0xc,%esp
80106930:	68 00 77 11 80       	push   $0x80117700
80106935:	e8 75 e9 ff ff       	call   801052af <acquire>
8010693a:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
8010693d:	a1 40 7f 11 80       	mov    0x80117f40,%eax
80106942:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106945:	83 ec 0c             	sub    $0xc,%esp
80106948:	68 00 77 11 80       	push   $0x80117700
8010694d:	e8 cf e9 ff ff       	call   80105321 <release>
80106952:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106955:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106958:	c9                   	leave  
80106959:	c3                   	ret    

8010695a <sys_mencrypt>:

//changed: added wrapper here
int sys_mencrypt(void) {
8010695a:	f3 0f 1e fb          	endbr32 
8010695e:	55                   	push   %ebp
8010695f:	89 e5                	mov    %esp,%ebp
80106961:	83 ec 18             	sub    $0x18,%esp
  int len;
  char * virtual_addr;

  if(argint(1, &len) < 0)
80106964:	83 ec 08             	sub    $0x8,%esp
80106967:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010696a:	50                   	push   %eax
8010696b:	6a 01                	push   $0x1
8010696d:	e8 30 ef ff ff       	call   801058a2 <argint>
80106972:	83 c4 10             	add    $0x10,%esp
80106975:	85 c0                	test   %eax,%eax
80106977:	79 07                	jns    80106980 <sys_mencrypt+0x26>
    return -1;
80106979:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010697e:	eb 50                	jmp    801069d0 <sys_mencrypt+0x76>
  if (len <= 0) {
80106980:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106983:	85 c0                	test   %eax,%eax
80106985:	7f 07                	jg     8010698e <sys_mencrypt+0x34>
    return -1;
80106987:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010698c:	eb 42                	jmp    801069d0 <sys_mencrypt+0x76>
  }
  if(argptr(0, &virtual_addr, 1) < 0)
8010698e:	83 ec 04             	sub    $0x4,%esp
80106991:	6a 01                	push   $0x1
80106993:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106996:	50                   	push   %eax
80106997:	6a 00                	push   $0x0
80106999:	e8 35 ef ff ff       	call   801058d3 <argptr>
8010699e:	83 c4 10             	add    $0x10,%esp
801069a1:	85 c0                	test   %eax,%eax
801069a3:	79 07                	jns    801069ac <sys_mencrypt+0x52>
    return -1;
801069a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069aa:	eb 24                	jmp    801069d0 <sys_mencrypt+0x76>
  if ((void *) virtual_addr >= P2V(PHYSTOP)) {
801069ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069af:	3d ff ff ff 8d       	cmp    $0x8dffffff,%eax
801069b4:	76 07                	jbe    801069bd <sys_mencrypt+0x63>
    return -1;
801069b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069bb:	eb 13                	jmp    801069d0 <sys_mencrypt+0x76>
  }
  return mencrypt(virtual_addr, len);
801069bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801069c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069c3:	83 ec 08             	sub    $0x8,%esp
801069c6:	52                   	push   %edx
801069c7:	50                   	push   %eax
801069c8:	e8 fa 22 00 00       	call   80108cc7 <mencrypt>
801069cd:	83 c4 10             	add    $0x10,%esp
}
801069d0:	c9                   	leave  
801069d1:	c3                   	ret    

801069d2 <sys_getpgtable>:

int sys_getpgtable(void) {
801069d2:	f3 0f 1e fb          	endbr32 
801069d6:	55                   	push   %ebp
801069d7:	89 e5                	mov    %esp,%ebp
801069d9:	83 ec 18             	sub    $0x18,%esp
  struct pt_entry * entries; 
  int num,wsetOnly;

  if(argint(1, &num) < 0)
801069dc:	83 ec 08             	sub    $0x8,%esp
801069df:	8d 45 f0             	lea    -0x10(%ebp),%eax
801069e2:	50                   	push   %eax
801069e3:	6a 01                	push   $0x1
801069e5:	e8 b8 ee ff ff       	call   801058a2 <argint>
801069ea:	83 c4 10             	add    $0x10,%esp
801069ed:	85 c0                	test   %eax,%eax
801069ef:	79 07                	jns    801069f8 <sys_getpgtable+0x26>
    return -1;
801069f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069f6:	eb 56                	jmp    80106a4e <sys_getpgtable+0x7c>
  if(argint(2, &wsetOnly) < 0)
801069f8:	83 ec 08             	sub    $0x8,%esp
801069fb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801069fe:	50                   	push   %eax
801069ff:	6a 02                	push   $0x2
80106a01:	e8 9c ee ff ff       	call   801058a2 <argint>
80106a06:	83 c4 10             	add    $0x10,%esp
80106a09:	85 c0                	test   %eax,%eax
80106a0b:	79 07                	jns    80106a14 <sys_getpgtable+0x42>
    return -1;
80106a0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a12:	eb 3a                	jmp    80106a4e <sys_getpgtable+0x7c>
  if(argptr(0, (char**)&entries, num*sizeof(struct pt_entry)) < 0){
80106a14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a17:	c1 e0 03             	shl    $0x3,%eax
80106a1a:	83 ec 04             	sub    $0x4,%esp
80106a1d:	50                   	push   %eax
80106a1e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a21:	50                   	push   %eax
80106a22:	6a 00                	push   $0x0
80106a24:	e8 aa ee ff ff       	call   801058d3 <argptr>
80106a29:	83 c4 10             	add    $0x10,%esp
80106a2c:	85 c0                	test   %eax,%eax
80106a2e:	79 07                	jns    80106a37 <sys_getpgtable+0x65>
    return -1;
80106a30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a35:	eb 17                	jmp    80106a4e <sys_getpgtable+0x7c>
  }
  return getpgtable(entries, num,wsetOnly);
80106a37:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80106a3a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a40:	83 ec 04             	sub    $0x4,%esp
80106a43:	51                   	push   %ecx
80106a44:	52                   	push   %edx
80106a45:	50                   	push   %eax
80106a46:	e8 62 24 00 00       	call   80108ead <getpgtable>
80106a4b:	83 c4 10             	add    $0x10,%esp
}
80106a4e:	c9                   	leave  
80106a4f:	c3                   	ret    

80106a50 <sys_dump_rawphymem>:


int sys_dump_rawphymem(void) {
80106a50:	f3 0f 1e fb          	endbr32 
80106a54:	55                   	push   %ebp
80106a55:	89 e5                	mov    %esp,%ebp
80106a57:	83 ec 18             	sub    $0x18,%esp
  char * physical_addr; 
  char * buffer;
  if(argptr(1, &buffer, PGSIZE) < 0)
80106a5a:	83 ec 04             	sub    $0x4,%esp
80106a5d:	68 00 10 00 00       	push   $0x1000
80106a62:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a65:	50                   	push   %eax
80106a66:	6a 01                	push   $0x1
80106a68:	e8 66 ee ff ff       	call   801058d3 <argptr>
80106a6d:	83 c4 10             	add    $0x10,%esp
80106a70:	85 c0                	test   %eax,%eax
80106a72:	79 07                	jns    80106a7b <sys_dump_rawphymem+0x2b>
    return -1;
80106a74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a79:	eb 2f                	jmp    80106aaa <sys_dump_rawphymem+0x5a>
  if(argint(0, (int*)&physical_addr) < 0)
80106a7b:	83 ec 08             	sub    $0x8,%esp
80106a7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a81:	50                   	push   %eax
80106a82:	6a 00                	push   $0x0
80106a84:	e8 19 ee ff ff       	call   801058a2 <argint>
80106a89:	83 c4 10             	add    $0x10,%esp
80106a8c:	85 c0                	test   %eax,%eax
80106a8e:	79 07                	jns    80106a97 <sys_dump_rawphymem+0x47>
    return -1;
80106a90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a95:	eb 13                	jmp    80106aaa <sys_dump_rawphymem+0x5a>
  return dump_rawphymem(physical_addr, buffer);
80106a97:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a9d:	83 ec 08             	sub    $0x8,%esp
80106aa0:	52                   	push   %edx
80106aa1:	50                   	push   %eax
80106aa2:	e8 66 26 00 00       	call   8010910d <dump_rawphymem>
80106aa7:	83 c4 10             	add    $0x10,%esp
80106aaa:	c9                   	leave  
80106aab:	c3                   	ret    

80106aac <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106aac:	1e                   	push   %ds
  pushl %es
80106aad:	06                   	push   %es
  pushl %fs
80106aae:	0f a0                	push   %fs
  pushl %gs
80106ab0:	0f a8                	push   %gs
  pushal
80106ab2:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106ab3:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106ab7:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106ab9:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106abb:	54                   	push   %esp
  call trap
80106abc:	e8 df 01 00 00       	call   80106ca0 <trap>
  addl $4, %esp
80106ac1:	83 c4 04             	add    $0x4,%esp

80106ac4 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106ac4:	61                   	popa   
  popl %gs
80106ac5:	0f a9                	pop    %gs
  popl %fs
80106ac7:	0f a1                	pop    %fs
  popl %es
80106ac9:	07                   	pop    %es
  popl %ds
80106aca:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106acb:	83 c4 08             	add    $0x8,%esp
  iret
80106ace:	cf                   	iret   

80106acf <lidt>:
{
80106acf:	55                   	push   %ebp
80106ad0:	89 e5                	mov    %esp,%ebp
80106ad2:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106ad5:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ad8:	83 e8 01             	sub    $0x1,%eax
80106adb:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106adf:	8b 45 08             	mov    0x8(%ebp),%eax
80106ae2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106ae6:	8b 45 08             	mov    0x8(%ebp),%eax
80106ae9:	c1 e8 10             	shr    $0x10,%eax
80106aec:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106af0:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106af3:	0f 01 18             	lidtl  (%eax)
}
80106af6:	90                   	nop
80106af7:	c9                   	leave  
80106af8:	c3                   	ret    

80106af9 <rcr2>:

static inline uint
rcr2(void)
{
80106af9:	55                   	push   %ebp
80106afa:	89 e5                	mov    %esp,%ebp
80106afc:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106aff:	0f 20 d0             	mov    %cr2,%eax
80106b02:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106b05:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106b08:	c9                   	leave  
80106b09:	c3                   	ret    

80106b0a <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106b0a:	f3 0f 1e fb          	endbr32 
80106b0e:	55                   	push   %ebp
80106b0f:	89 e5                	mov    %esp,%ebp
80106b11:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106b14:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106b1b:	e9 c3 00 00 00       	jmp    80106be3 <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b23:	8b 04 85 84 c0 10 80 	mov    -0x7fef3f7c(,%eax,4),%eax
80106b2a:	89 c2                	mov    %eax,%edx
80106b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b2f:	66 89 14 c5 40 77 11 	mov    %dx,-0x7fee88c0(,%eax,8)
80106b36:	80 
80106b37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b3a:	66 c7 04 c5 42 77 11 	movw   $0x8,-0x7fee88be(,%eax,8)
80106b41:	80 08 00 
80106b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b47:	0f b6 14 c5 44 77 11 	movzbl -0x7fee88bc(,%eax,8),%edx
80106b4e:	80 
80106b4f:	83 e2 e0             	and    $0xffffffe0,%edx
80106b52:	88 14 c5 44 77 11 80 	mov    %dl,-0x7fee88bc(,%eax,8)
80106b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b5c:	0f b6 14 c5 44 77 11 	movzbl -0x7fee88bc(,%eax,8),%edx
80106b63:	80 
80106b64:	83 e2 1f             	and    $0x1f,%edx
80106b67:	88 14 c5 44 77 11 80 	mov    %dl,-0x7fee88bc(,%eax,8)
80106b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b71:	0f b6 14 c5 45 77 11 	movzbl -0x7fee88bb(,%eax,8),%edx
80106b78:	80 
80106b79:	83 e2 f0             	and    $0xfffffff0,%edx
80106b7c:	83 ca 0e             	or     $0xe,%edx
80106b7f:	88 14 c5 45 77 11 80 	mov    %dl,-0x7fee88bb(,%eax,8)
80106b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b89:	0f b6 14 c5 45 77 11 	movzbl -0x7fee88bb(,%eax,8),%edx
80106b90:	80 
80106b91:	83 e2 ef             	and    $0xffffffef,%edx
80106b94:	88 14 c5 45 77 11 80 	mov    %dl,-0x7fee88bb(,%eax,8)
80106b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b9e:	0f b6 14 c5 45 77 11 	movzbl -0x7fee88bb(,%eax,8),%edx
80106ba5:	80 
80106ba6:	83 e2 9f             	and    $0xffffff9f,%edx
80106ba9:	88 14 c5 45 77 11 80 	mov    %dl,-0x7fee88bb(,%eax,8)
80106bb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bb3:	0f b6 14 c5 45 77 11 	movzbl -0x7fee88bb(,%eax,8),%edx
80106bba:	80 
80106bbb:	83 ca 80             	or     $0xffffff80,%edx
80106bbe:	88 14 c5 45 77 11 80 	mov    %dl,-0x7fee88bb(,%eax,8)
80106bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bc8:	8b 04 85 84 c0 10 80 	mov    -0x7fef3f7c(,%eax,4),%eax
80106bcf:	c1 e8 10             	shr    $0x10,%eax
80106bd2:	89 c2                	mov    %eax,%edx
80106bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bd7:	66 89 14 c5 46 77 11 	mov    %dx,-0x7fee88ba(,%eax,8)
80106bde:	80 
  for(i = 0; i < 256; i++)
80106bdf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106be3:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106bea:	0f 8e 30 ff ff ff    	jle    80106b20 <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106bf0:	a1 84 c1 10 80       	mov    0x8010c184,%eax
80106bf5:	66 a3 40 79 11 80    	mov    %ax,0x80117940
80106bfb:	66 c7 05 42 79 11 80 	movw   $0x8,0x80117942
80106c02:	08 00 
80106c04:	0f b6 05 44 79 11 80 	movzbl 0x80117944,%eax
80106c0b:	83 e0 e0             	and    $0xffffffe0,%eax
80106c0e:	a2 44 79 11 80       	mov    %al,0x80117944
80106c13:	0f b6 05 44 79 11 80 	movzbl 0x80117944,%eax
80106c1a:	83 e0 1f             	and    $0x1f,%eax
80106c1d:	a2 44 79 11 80       	mov    %al,0x80117944
80106c22:	0f b6 05 45 79 11 80 	movzbl 0x80117945,%eax
80106c29:	83 c8 0f             	or     $0xf,%eax
80106c2c:	a2 45 79 11 80       	mov    %al,0x80117945
80106c31:	0f b6 05 45 79 11 80 	movzbl 0x80117945,%eax
80106c38:	83 e0 ef             	and    $0xffffffef,%eax
80106c3b:	a2 45 79 11 80       	mov    %al,0x80117945
80106c40:	0f b6 05 45 79 11 80 	movzbl 0x80117945,%eax
80106c47:	83 c8 60             	or     $0x60,%eax
80106c4a:	a2 45 79 11 80       	mov    %al,0x80117945
80106c4f:	0f b6 05 45 79 11 80 	movzbl 0x80117945,%eax
80106c56:	83 c8 80             	or     $0xffffff80,%eax
80106c59:	a2 45 79 11 80       	mov    %al,0x80117945
80106c5e:	a1 84 c1 10 80       	mov    0x8010c184,%eax
80106c63:	c1 e8 10             	shr    $0x10,%eax
80106c66:	66 a3 46 79 11 80    	mov    %ax,0x80117946

  initlock(&tickslock, "time");
80106c6c:	83 ec 08             	sub    $0x8,%esp
80106c6f:	68 dc 96 10 80       	push   $0x801096dc
80106c74:	68 00 77 11 80       	push   $0x80117700
80106c79:	e8 0b e6 ff ff       	call   80105289 <initlock>
80106c7e:	83 c4 10             	add    $0x10,%esp
}
80106c81:	90                   	nop
80106c82:	c9                   	leave  
80106c83:	c3                   	ret    

80106c84 <idtinit>:

void
idtinit(void)
{
80106c84:	f3 0f 1e fb          	endbr32 
80106c88:	55                   	push   %ebp
80106c89:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106c8b:	68 00 08 00 00       	push   $0x800
80106c90:	68 40 77 11 80       	push   $0x80117740
80106c95:	e8 35 fe ff ff       	call   80106acf <lidt>
80106c9a:	83 c4 08             	add    $0x8,%esp
}
80106c9d:	90                   	nop
80106c9e:	c9                   	leave  
80106c9f:	c3                   	ret    

80106ca0 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106ca0:	f3 0f 1e fb          	endbr32 
80106ca4:	55                   	push   %ebp
80106ca5:	89 e5                	mov    %esp,%ebp
80106ca7:	57                   	push   %edi
80106ca8:	56                   	push   %esi
80106ca9:	53                   	push   %ebx
80106caa:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80106cad:	8b 45 08             	mov    0x8(%ebp),%eax
80106cb0:	8b 40 30             	mov    0x30(%eax),%eax
80106cb3:	83 f8 40             	cmp    $0x40,%eax
80106cb6:	75 3b                	jne    80106cf3 <trap+0x53>
    if(myproc()->killed)
80106cb8:	e8 52 d8 ff ff       	call   8010450f <myproc>
80106cbd:	8b 40 24             	mov    0x24(%eax),%eax
80106cc0:	85 c0                	test   %eax,%eax
80106cc2:	74 05                	je     80106cc9 <trap+0x29>
      exit();
80106cc4:	e8 22 dd ff ff       	call   801049eb <exit>
    myproc()->tf = tf;
80106cc9:	e8 41 d8 ff ff       	call   8010450f <myproc>
80106cce:	8b 55 08             	mov    0x8(%ebp),%edx
80106cd1:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106cd4:	e8 a1 ec ff ff       	call   8010597a <syscall>
    if(myproc()->killed)
80106cd9:	e8 31 d8 ff ff       	call   8010450f <myproc>
80106cde:	8b 40 24             	mov    0x24(%eax),%eax
80106ce1:	85 c0                	test   %eax,%eax
80106ce3:	0f 84 42 02 00 00    	je     80106f2b <trap+0x28b>
      exit();
80106ce9:	e8 fd dc ff ff       	call   801049eb <exit>
    return;
80106cee:	e9 38 02 00 00       	jmp    80106f2b <trap+0x28b>
  }
  char *addr;
  switch(tf->trapno){
80106cf3:	8b 45 08             	mov    0x8(%ebp),%eax
80106cf6:	8b 40 30             	mov    0x30(%eax),%eax
80106cf9:	83 e8 0e             	sub    $0xe,%eax
80106cfc:	83 f8 31             	cmp    $0x31,%eax
80106cff:	0f 87 ee 00 00 00    	ja     80106df3 <trap+0x153>
80106d05:	8b 04 85 9c 97 10 80 	mov    -0x7fef6864(,%eax,4),%eax
80106d0c:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106d0f:	e8 60 d7 ff ff       	call   80104474 <cpuid>
80106d14:	85 c0                	test   %eax,%eax
80106d16:	75 3d                	jne    80106d55 <trap+0xb5>
      acquire(&tickslock);
80106d18:	83 ec 0c             	sub    $0xc,%esp
80106d1b:	68 00 77 11 80       	push   $0x80117700
80106d20:	e8 8a e5 ff ff       	call   801052af <acquire>
80106d25:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106d28:	a1 40 7f 11 80       	mov    0x80117f40,%eax
80106d2d:	83 c0 01             	add    $0x1,%eax
80106d30:	a3 40 7f 11 80       	mov    %eax,0x80117f40
      wakeup(&ticks);
80106d35:	83 ec 0c             	sub    $0xc,%esp
80106d38:	68 40 7f 11 80       	push   $0x80117f40
80106d3d:	e8 ed e1 ff ff       	call   80104f2f <wakeup>
80106d42:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106d45:	83 ec 0c             	sub    $0xc,%esp
80106d48:	68 00 77 11 80       	push   $0x80117700
80106d4d:	e8 cf e5 ff ff       	call   80105321 <release>
80106d52:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106d55:	e8 aa c4 ff ff       	call   80103204 <lapiceoi>
    break;
80106d5a:	e9 4c 01 00 00       	jmp    80106eab <trap+0x20b>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106d5f:	e8 af bc ff ff       	call   80102a13 <ideintr>
    lapiceoi();
80106d64:	e8 9b c4 ff ff       	call   80103204 <lapiceoi>
    break;
80106d69:	e9 3d 01 00 00       	jmp    80106eab <trap+0x20b>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106d6e:	e8 c7 c2 ff ff       	call   8010303a <kbdintr>
    lapiceoi();
80106d73:	e8 8c c4 ff ff       	call   80103204 <lapiceoi>
    break;
80106d78:	e9 2e 01 00 00       	jmp    80106eab <trap+0x20b>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106d7d:	e8 8b 03 00 00       	call   8010710d <uartintr>
    lapiceoi();
80106d82:	e8 7d c4 ff ff       	call   80103204 <lapiceoi>
    break;
80106d87:	e9 1f 01 00 00       	jmp    80106eab <trap+0x20b>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106d8c:	8b 45 08             	mov    0x8(%ebp),%eax
80106d8f:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106d92:	8b 45 08             	mov    0x8(%ebp),%eax
80106d95:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106d99:	0f b7 d8             	movzwl %ax,%ebx
80106d9c:	e8 d3 d6 ff ff       	call   80104474 <cpuid>
80106da1:	56                   	push   %esi
80106da2:	53                   	push   %ebx
80106da3:	50                   	push   %eax
80106da4:	68 e4 96 10 80       	push   $0x801096e4
80106da9:	e8 6a 96 ff ff       	call   80100418 <cprintf>
80106dae:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106db1:	e8 4e c4 ff ff       	call   80103204 <lapiceoi>
    break;
80106db6:	e9 f0 00 00 00       	jmp    80106eab <trap+0x20b>
  case T_PGFLT:
    //Food for thought: How can one distinguish between a regular page fault and a decryption request?
    cprintf("p4Debug : Page fault !\n");
80106dbb:	83 ec 0c             	sub    $0xc,%esp
80106dbe:	68 08 97 10 80       	push   $0x80109708
80106dc3:	e8 50 96 ff ff       	call   80100418 <cprintf>
80106dc8:	83 c4 10             	add    $0x10,%esp
    addr = (char*)rcr2();
80106dcb:	e8 29 fd ff ff       	call   80106af9 <rcr2>
80106dd0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (mdecrypt(addr))
80106dd3:	83 ec 0c             	sub    $0xc,%esp
80106dd6:	ff 75 e4             	pushl  -0x1c(%ebp)
80106dd9:	e8 11 1d 00 00       	call   80108aef <mdecrypt>
80106dde:	83 c4 10             	add    $0x10,%esp
80106de1:	85 c0                	test   %eax,%eax
80106de3:	0f 84 c1 00 00 00    	je     80106eaa <trap+0x20a>
    {
        //panic("p4Debug: Memory fault");
        exit();
80106de9:	e8 fd db ff ff       	call   801049eb <exit>
    };
    break;
80106dee:	e9 b7 00 00 00       	jmp    80106eaa <trap+0x20a>
  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106df3:	e8 17 d7 ff ff       	call   8010450f <myproc>
80106df8:	85 c0                	test   %eax,%eax
80106dfa:	74 11                	je     80106e0d <trap+0x16d>
80106dfc:	8b 45 08             	mov    0x8(%ebp),%eax
80106dff:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106e03:	0f b7 c0             	movzwl %ax,%eax
80106e06:	83 e0 03             	and    $0x3,%eax
80106e09:	85 c0                	test   %eax,%eax
80106e0b:	75 39                	jne    80106e46 <trap+0x1a6>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106e0d:	e8 e7 fc ff ff       	call   80106af9 <rcr2>
80106e12:	89 c3                	mov    %eax,%ebx
80106e14:	8b 45 08             	mov    0x8(%ebp),%eax
80106e17:	8b 70 38             	mov    0x38(%eax),%esi
80106e1a:	e8 55 d6 ff ff       	call   80104474 <cpuid>
80106e1f:	8b 55 08             	mov    0x8(%ebp),%edx
80106e22:	8b 52 30             	mov    0x30(%edx),%edx
80106e25:	83 ec 0c             	sub    $0xc,%esp
80106e28:	53                   	push   %ebx
80106e29:	56                   	push   %esi
80106e2a:	50                   	push   %eax
80106e2b:	52                   	push   %edx
80106e2c:	68 20 97 10 80       	push   $0x80109720
80106e31:	e8 e2 95 ff ff       	call   80100418 <cprintf>
80106e36:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106e39:	83 ec 0c             	sub    $0xc,%esp
80106e3c:	68 52 97 10 80       	push   $0x80109752
80106e41:	e8 c2 97 ff ff       	call   80100608 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e46:	e8 ae fc ff ff       	call   80106af9 <rcr2>
80106e4b:	89 c6                	mov    %eax,%esi
80106e4d:	8b 45 08             	mov    0x8(%ebp),%eax
80106e50:	8b 40 38             	mov    0x38(%eax),%eax
80106e53:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106e56:	e8 19 d6 ff ff       	call   80104474 <cpuid>
80106e5b:	89 c3                	mov    %eax,%ebx
80106e5d:	8b 45 08             	mov    0x8(%ebp),%eax
80106e60:	8b 48 34             	mov    0x34(%eax),%ecx
80106e63:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106e66:	8b 45 08             	mov    0x8(%ebp),%eax
80106e69:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106e6c:	e8 9e d6 ff ff       	call   8010450f <myproc>
80106e71:	8d 50 6c             	lea    0x6c(%eax),%edx
80106e74:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106e77:	e8 93 d6 ff ff       	call   8010450f <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e7c:	8b 40 10             	mov    0x10(%eax),%eax
80106e7f:	56                   	push   %esi
80106e80:	ff 75 d4             	pushl  -0x2c(%ebp)
80106e83:	53                   	push   %ebx
80106e84:	ff 75 d0             	pushl  -0x30(%ebp)
80106e87:	57                   	push   %edi
80106e88:	ff 75 cc             	pushl  -0x34(%ebp)
80106e8b:	50                   	push   %eax
80106e8c:	68 58 97 10 80       	push   $0x80109758
80106e91:	e8 82 95 ff ff       	call   80100418 <cprintf>
80106e96:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106e99:	e8 71 d6 ff ff       	call   8010450f <myproc>
80106e9e:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106ea5:	eb 04                	jmp    80106eab <trap+0x20b>
    break;
80106ea7:	90                   	nop
80106ea8:	eb 01                	jmp    80106eab <trap+0x20b>
    break;
80106eaa:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106eab:	e8 5f d6 ff ff       	call   8010450f <myproc>
80106eb0:	85 c0                	test   %eax,%eax
80106eb2:	74 23                	je     80106ed7 <trap+0x237>
80106eb4:	e8 56 d6 ff ff       	call   8010450f <myproc>
80106eb9:	8b 40 24             	mov    0x24(%eax),%eax
80106ebc:	85 c0                	test   %eax,%eax
80106ebe:	74 17                	je     80106ed7 <trap+0x237>
80106ec0:	8b 45 08             	mov    0x8(%ebp),%eax
80106ec3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106ec7:	0f b7 c0             	movzwl %ax,%eax
80106eca:	83 e0 03             	and    $0x3,%eax
80106ecd:	83 f8 03             	cmp    $0x3,%eax
80106ed0:	75 05                	jne    80106ed7 <trap+0x237>
    exit();
80106ed2:	e8 14 db ff ff       	call   801049eb <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106ed7:	e8 33 d6 ff ff       	call   8010450f <myproc>
80106edc:	85 c0                	test   %eax,%eax
80106ede:	74 1d                	je     80106efd <trap+0x25d>
80106ee0:	e8 2a d6 ff ff       	call   8010450f <myproc>
80106ee5:	8b 40 0c             	mov    0xc(%eax),%eax
80106ee8:	83 f8 04             	cmp    $0x4,%eax
80106eeb:	75 10                	jne    80106efd <trap+0x25d>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106eed:	8b 45 08             	mov    0x8(%ebp),%eax
80106ef0:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106ef3:	83 f8 20             	cmp    $0x20,%eax
80106ef6:	75 05                	jne    80106efd <trap+0x25d>
    yield();
80106ef8:	e8 b8 de ff ff       	call   80104db5 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106efd:	e8 0d d6 ff ff       	call   8010450f <myproc>
80106f02:	85 c0                	test   %eax,%eax
80106f04:	74 26                	je     80106f2c <trap+0x28c>
80106f06:	e8 04 d6 ff ff       	call   8010450f <myproc>
80106f0b:	8b 40 24             	mov    0x24(%eax),%eax
80106f0e:	85 c0                	test   %eax,%eax
80106f10:	74 1a                	je     80106f2c <trap+0x28c>
80106f12:	8b 45 08             	mov    0x8(%ebp),%eax
80106f15:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106f19:	0f b7 c0             	movzwl %ax,%eax
80106f1c:	83 e0 03             	and    $0x3,%eax
80106f1f:	83 f8 03             	cmp    $0x3,%eax
80106f22:	75 08                	jne    80106f2c <trap+0x28c>
    exit();
80106f24:	e8 c2 da ff ff       	call   801049eb <exit>
80106f29:	eb 01                	jmp    80106f2c <trap+0x28c>
    return;
80106f2b:	90                   	nop
}
80106f2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106f2f:	5b                   	pop    %ebx
80106f30:	5e                   	pop    %esi
80106f31:	5f                   	pop    %edi
80106f32:	5d                   	pop    %ebp
80106f33:	c3                   	ret    

80106f34 <inb>:
{
80106f34:	55                   	push   %ebp
80106f35:	89 e5                	mov    %esp,%ebp
80106f37:	83 ec 14             	sub    $0x14,%esp
80106f3a:	8b 45 08             	mov    0x8(%ebp),%eax
80106f3d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106f41:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106f45:	89 c2                	mov    %eax,%edx
80106f47:	ec                   	in     (%dx),%al
80106f48:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106f4b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106f4f:	c9                   	leave  
80106f50:	c3                   	ret    

80106f51 <outb>:
{
80106f51:	55                   	push   %ebp
80106f52:	89 e5                	mov    %esp,%ebp
80106f54:	83 ec 08             	sub    $0x8,%esp
80106f57:	8b 45 08             	mov    0x8(%ebp),%eax
80106f5a:	8b 55 0c             	mov    0xc(%ebp),%edx
80106f5d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106f61:	89 d0                	mov    %edx,%eax
80106f63:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106f66:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106f6a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106f6e:	ee                   	out    %al,(%dx)
}
80106f6f:	90                   	nop
80106f70:	c9                   	leave  
80106f71:	c3                   	ret    

80106f72 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106f72:	f3 0f 1e fb          	endbr32 
80106f76:	55                   	push   %ebp
80106f77:	89 e5                	mov    %esp,%ebp
80106f79:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106f7c:	6a 00                	push   $0x0
80106f7e:	68 fa 03 00 00       	push   $0x3fa
80106f83:	e8 c9 ff ff ff       	call   80106f51 <outb>
80106f88:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106f8b:	68 80 00 00 00       	push   $0x80
80106f90:	68 fb 03 00 00       	push   $0x3fb
80106f95:	e8 b7 ff ff ff       	call   80106f51 <outb>
80106f9a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106f9d:	6a 0c                	push   $0xc
80106f9f:	68 f8 03 00 00       	push   $0x3f8
80106fa4:	e8 a8 ff ff ff       	call   80106f51 <outb>
80106fa9:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106fac:	6a 00                	push   $0x0
80106fae:	68 f9 03 00 00       	push   $0x3f9
80106fb3:	e8 99 ff ff ff       	call   80106f51 <outb>
80106fb8:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106fbb:	6a 03                	push   $0x3
80106fbd:	68 fb 03 00 00       	push   $0x3fb
80106fc2:	e8 8a ff ff ff       	call   80106f51 <outb>
80106fc7:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106fca:	6a 00                	push   $0x0
80106fcc:	68 fc 03 00 00       	push   $0x3fc
80106fd1:	e8 7b ff ff ff       	call   80106f51 <outb>
80106fd6:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106fd9:	6a 01                	push   $0x1
80106fdb:	68 f9 03 00 00       	push   $0x3f9
80106fe0:	e8 6c ff ff ff       	call   80106f51 <outb>
80106fe5:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106fe8:	68 fd 03 00 00       	push   $0x3fd
80106fed:	e8 42 ff ff ff       	call   80106f34 <inb>
80106ff2:	83 c4 04             	add    $0x4,%esp
80106ff5:	3c ff                	cmp    $0xff,%al
80106ff7:	74 61                	je     8010705a <uartinit+0xe8>
    return;
  uart = 1;
80106ff9:	c7 05 44 c6 10 80 01 	movl   $0x1,0x8010c644
80107000:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107003:	68 fa 03 00 00       	push   $0x3fa
80107008:	e8 27 ff ff ff       	call   80106f34 <inb>
8010700d:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80107010:	68 f8 03 00 00       	push   $0x3f8
80107015:	e8 1a ff ff ff       	call   80106f34 <inb>
8010701a:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
8010701d:	83 ec 08             	sub    $0x8,%esp
80107020:	6a 00                	push   $0x0
80107022:	6a 04                	push   $0x4
80107024:	e8 9c bc ff ff       	call   80102cc5 <ioapicenable>
80107029:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010702c:	c7 45 f4 64 98 10 80 	movl   $0x80109864,-0xc(%ebp)
80107033:	eb 19                	jmp    8010704e <uartinit+0xdc>
    uartputc(*p);
80107035:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107038:	0f b6 00             	movzbl (%eax),%eax
8010703b:	0f be c0             	movsbl %al,%eax
8010703e:	83 ec 0c             	sub    $0xc,%esp
80107041:	50                   	push   %eax
80107042:	e8 16 00 00 00       	call   8010705d <uartputc>
80107047:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
8010704a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010704e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107051:	0f b6 00             	movzbl (%eax),%eax
80107054:	84 c0                	test   %al,%al
80107056:	75 dd                	jne    80107035 <uartinit+0xc3>
80107058:	eb 01                	jmp    8010705b <uartinit+0xe9>
    return;
8010705a:	90                   	nop
}
8010705b:	c9                   	leave  
8010705c:	c3                   	ret    

8010705d <uartputc>:

void
uartputc(int c)
{
8010705d:	f3 0f 1e fb          	endbr32 
80107061:	55                   	push   %ebp
80107062:	89 e5                	mov    %esp,%ebp
80107064:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80107067:	a1 44 c6 10 80       	mov    0x8010c644,%eax
8010706c:	85 c0                	test   %eax,%eax
8010706e:	74 53                	je     801070c3 <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107070:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107077:	eb 11                	jmp    8010708a <uartputc+0x2d>
    microdelay(10);
80107079:	83 ec 0c             	sub    $0xc,%esp
8010707c:	6a 0a                	push   $0xa
8010707e:	e8 a0 c1 ff ff       	call   80103223 <microdelay>
80107083:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107086:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010708a:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010708e:	7f 1a                	jg     801070aa <uartputc+0x4d>
80107090:	83 ec 0c             	sub    $0xc,%esp
80107093:	68 fd 03 00 00       	push   $0x3fd
80107098:	e8 97 fe ff ff       	call   80106f34 <inb>
8010709d:	83 c4 10             	add    $0x10,%esp
801070a0:	0f b6 c0             	movzbl %al,%eax
801070a3:	83 e0 20             	and    $0x20,%eax
801070a6:	85 c0                	test   %eax,%eax
801070a8:	74 cf                	je     80107079 <uartputc+0x1c>
  outb(COM1+0, c);
801070aa:	8b 45 08             	mov    0x8(%ebp),%eax
801070ad:	0f b6 c0             	movzbl %al,%eax
801070b0:	83 ec 08             	sub    $0x8,%esp
801070b3:	50                   	push   %eax
801070b4:	68 f8 03 00 00       	push   $0x3f8
801070b9:	e8 93 fe ff ff       	call   80106f51 <outb>
801070be:	83 c4 10             	add    $0x10,%esp
801070c1:	eb 01                	jmp    801070c4 <uartputc+0x67>
    return;
801070c3:	90                   	nop
}
801070c4:	c9                   	leave  
801070c5:	c3                   	ret    

801070c6 <uartgetc>:

static int
uartgetc(void)
{
801070c6:	f3 0f 1e fb          	endbr32 
801070ca:	55                   	push   %ebp
801070cb:	89 e5                	mov    %esp,%ebp
  if(!uart)
801070cd:	a1 44 c6 10 80       	mov    0x8010c644,%eax
801070d2:	85 c0                	test   %eax,%eax
801070d4:	75 07                	jne    801070dd <uartgetc+0x17>
    return -1;
801070d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070db:	eb 2e                	jmp    8010710b <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
801070dd:	68 fd 03 00 00       	push   $0x3fd
801070e2:	e8 4d fe ff ff       	call   80106f34 <inb>
801070e7:	83 c4 04             	add    $0x4,%esp
801070ea:	0f b6 c0             	movzbl %al,%eax
801070ed:	83 e0 01             	and    $0x1,%eax
801070f0:	85 c0                	test   %eax,%eax
801070f2:	75 07                	jne    801070fb <uartgetc+0x35>
    return -1;
801070f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070f9:	eb 10                	jmp    8010710b <uartgetc+0x45>
  return inb(COM1+0);
801070fb:	68 f8 03 00 00       	push   $0x3f8
80107100:	e8 2f fe ff ff       	call   80106f34 <inb>
80107105:	83 c4 04             	add    $0x4,%esp
80107108:	0f b6 c0             	movzbl %al,%eax
}
8010710b:	c9                   	leave  
8010710c:	c3                   	ret    

8010710d <uartintr>:

void
uartintr(void)
{
8010710d:	f3 0f 1e fb          	endbr32 
80107111:	55                   	push   %ebp
80107112:	89 e5                	mov    %esp,%ebp
80107114:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107117:	83 ec 0c             	sub    $0xc,%esp
8010711a:	68 c6 70 10 80       	push   $0x801070c6
8010711f:	e8 84 97 ff ff       	call   801008a8 <consoleintr>
80107124:	83 c4 10             	add    $0x10,%esp
}
80107127:	90                   	nop
80107128:	c9                   	leave  
80107129:	c3                   	ret    

8010712a <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010712a:	6a 00                	push   $0x0
  pushl $0
8010712c:	6a 00                	push   $0x0
  jmp alltraps
8010712e:	e9 79 f9 ff ff       	jmp    80106aac <alltraps>

80107133 <vector1>:
.globl vector1
vector1:
  pushl $0
80107133:	6a 00                	push   $0x0
  pushl $1
80107135:	6a 01                	push   $0x1
  jmp alltraps
80107137:	e9 70 f9 ff ff       	jmp    80106aac <alltraps>

8010713c <vector2>:
.globl vector2
vector2:
  pushl $0
8010713c:	6a 00                	push   $0x0
  pushl $2
8010713e:	6a 02                	push   $0x2
  jmp alltraps
80107140:	e9 67 f9 ff ff       	jmp    80106aac <alltraps>

80107145 <vector3>:
.globl vector3
vector3:
  pushl $0
80107145:	6a 00                	push   $0x0
  pushl $3
80107147:	6a 03                	push   $0x3
  jmp alltraps
80107149:	e9 5e f9 ff ff       	jmp    80106aac <alltraps>

8010714e <vector4>:
.globl vector4
vector4:
  pushl $0
8010714e:	6a 00                	push   $0x0
  pushl $4
80107150:	6a 04                	push   $0x4
  jmp alltraps
80107152:	e9 55 f9 ff ff       	jmp    80106aac <alltraps>

80107157 <vector5>:
.globl vector5
vector5:
  pushl $0
80107157:	6a 00                	push   $0x0
  pushl $5
80107159:	6a 05                	push   $0x5
  jmp alltraps
8010715b:	e9 4c f9 ff ff       	jmp    80106aac <alltraps>

80107160 <vector6>:
.globl vector6
vector6:
  pushl $0
80107160:	6a 00                	push   $0x0
  pushl $6
80107162:	6a 06                	push   $0x6
  jmp alltraps
80107164:	e9 43 f9 ff ff       	jmp    80106aac <alltraps>

80107169 <vector7>:
.globl vector7
vector7:
  pushl $0
80107169:	6a 00                	push   $0x0
  pushl $7
8010716b:	6a 07                	push   $0x7
  jmp alltraps
8010716d:	e9 3a f9 ff ff       	jmp    80106aac <alltraps>

80107172 <vector8>:
.globl vector8
vector8:
  pushl $8
80107172:	6a 08                	push   $0x8
  jmp alltraps
80107174:	e9 33 f9 ff ff       	jmp    80106aac <alltraps>

80107179 <vector9>:
.globl vector9
vector9:
  pushl $0
80107179:	6a 00                	push   $0x0
  pushl $9
8010717b:	6a 09                	push   $0x9
  jmp alltraps
8010717d:	e9 2a f9 ff ff       	jmp    80106aac <alltraps>

80107182 <vector10>:
.globl vector10
vector10:
  pushl $10
80107182:	6a 0a                	push   $0xa
  jmp alltraps
80107184:	e9 23 f9 ff ff       	jmp    80106aac <alltraps>

80107189 <vector11>:
.globl vector11
vector11:
  pushl $11
80107189:	6a 0b                	push   $0xb
  jmp alltraps
8010718b:	e9 1c f9 ff ff       	jmp    80106aac <alltraps>

80107190 <vector12>:
.globl vector12
vector12:
  pushl $12
80107190:	6a 0c                	push   $0xc
  jmp alltraps
80107192:	e9 15 f9 ff ff       	jmp    80106aac <alltraps>

80107197 <vector13>:
.globl vector13
vector13:
  pushl $13
80107197:	6a 0d                	push   $0xd
  jmp alltraps
80107199:	e9 0e f9 ff ff       	jmp    80106aac <alltraps>

8010719e <vector14>:
.globl vector14
vector14:
  pushl $14
8010719e:	6a 0e                	push   $0xe
  jmp alltraps
801071a0:	e9 07 f9 ff ff       	jmp    80106aac <alltraps>

801071a5 <vector15>:
.globl vector15
vector15:
  pushl $0
801071a5:	6a 00                	push   $0x0
  pushl $15
801071a7:	6a 0f                	push   $0xf
  jmp alltraps
801071a9:	e9 fe f8 ff ff       	jmp    80106aac <alltraps>

801071ae <vector16>:
.globl vector16
vector16:
  pushl $0
801071ae:	6a 00                	push   $0x0
  pushl $16
801071b0:	6a 10                	push   $0x10
  jmp alltraps
801071b2:	e9 f5 f8 ff ff       	jmp    80106aac <alltraps>

801071b7 <vector17>:
.globl vector17
vector17:
  pushl $17
801071b7:	6a 11                	push   $0x11
  jmp alltraps
801071b9:	e9 ee f8 ff ff       	jmp    80106aac <alltraps>

801071be <vector18>:
.globl vector18
vector18:
  pushl $0
801071be:	6a 00                	push   $0x0
  pushl $18
801071c0:	6a 12                	push   $0x12
  jmp alltraps
801071c2:	e9 e5 f8 ff ff       	jmp    80106aac <alltraps>

801071c7 <vector19>:
.globl vector19
vector19:
  pushl $0
801071c7:	6a 00                	push   $0x0
  pushl $19
801071c9:	6a 13                	push   $0x13
  jmp alltraps
801071cb:	e9 dc f8 ff ff       	jmp    80106aac <alltraps>

801071d0 <vector20>:
.globl vector20
vector20:
  pushl $0
801071d0:	6a 00                	push   $0x0
  pushl $20
801071d2:	6a 14                	push   $0x14
  jmp alltraps
801071d4:	e9 d3 f8 ff ff       	jmp    80106aac <alltraps>

801071d9 <vector21>:
.globl vector21
vector21:
  pushl $0
801071d9:	6a 00                	push   $0x0
  pushl $21
801071db:	6a 15                	push   $0x15
  jmp alltraps
801071dd:	e9 ca f8 ff ff       	jmp    80106aac <alltraps>

801071e2 <vector22>:
.globl vector22
vector22:
  pushl $0
801071e2:	6a 00                	push   $0x0
  pushl $22
801071e4:	6a 16                	push   $0x16
  jmp alltraps
801071e6:	e9 c1 f8 ff ff       	jmp    80106aac <alltraps>

801071eb <vector23>:
.globl vector23
vector23:
  pushl $0
801071eb:	6a 00                	push   $0x0
  pushl $23
801071ed:	6a 17                	push   $0x17
  jmp alltraps
801071ef:	e9 b8 f8 ff ff       	jmp    80106aac <alltraps>

801071f4 <vector24>:
.globl vector24
vector24:
  pushl $0
801071f4:	6a 00                	push   $0x0
  pushl $24
801071f6:	6a 18                	push   $0x18
  jmp alltraps
801071f8:	e9 af f8 ff ff       	jmp    80106aac <alltraps>

801071fd <vector25>:
.globl vector25
vector25:
  pushl $0
801071fd:	6a 00                	push   $0x0
  pushl $25
801071ff:	6a 19                	push   $0x19
  jmp alltraps
80107201:	e9 a6 f8 ff ff       	jmp    80106aac <alltraps>

80107206 <vector26>:
.globl vector26
vector26:
  pushl $0
80107206:	6a 00                	push   $0x0
  pushl $26
80107208:	6a 1a                	push   $0x1a
  jmp alltraps
8010720a:	e9 9d f8 ff ff       	jmp    80106aac <alltraps>

8010720f <vector27>:
.globl vector27
vector27:
  pushl $0
8010720f:	6a 00                	push   $0x0
  pushl $27
80107211:	6a 1b                	push   $0x1b
  jmp alltraps
80107213:	e9 94 f8 ff ff       	jmp    80106aac <alltraps>

80107218 <vector28>:
.globl vector28
vector28:
  pushl $0
80107218:	6a 00                	push   $0x0
  pushl $28
8010721a:	6a 1c                	push   $0x1c
  jmp alltraps
8010721c:	e9 8b f8 ff ff       	jmp    80106aac <alltraps>

80107221 <vector29>:
.globl vector29
vector29:
  pushl $0
80107221:	6a 00                	push   $0x0
  pushl $29
80107223:	6a 1d                	push   $0x1d
  jmp alltraps
80107225:	e9 82 f8 ff ff       	jmp    80106aac <alltraps>

8010722a <vector30>:
.globl vector30
vector30:
  pushl $0
8010722a:	6a 00                	push   $0x0
  pushl $30
8010722c:	6a 1e                	push   $0x1e
  jmp alltraps
8010722e:	e9 79 f8 ff ff       	jmp    80106aac <alltraps>

80107233 <vector31>:
.globl vector31
vector31:
  pushl $0
80107233:	6a 00                	push   $0x0
  pushl $31
80107235:	6a 1f                	push   $0x1f
  jmp alltraps
80107237:	e9 70 f8 ff ff       	jmp    80106aac <alltraps>

8010723c <vector32>:
.globl vector32
vector32:
  pushl $0
8010723c:	6a 00                	push   $0x0
  pushl $32
8010723e:	6a 20                	push   $0x20
  jmp alltraps
80107240:	e9 67 f8 ff ff       	jmp    80106aac <alltraps>

80107245 <vector33>:
.globl vector33
vector33:
  pushl $0
80107245:	6a 00                	push   $0x0
  pushl $33
80107247:	6a 21                	push   $0x21
  jmp alltraps
80107249:	e9 5e f8 ff ff       	jmp    80106aac <alltraps>

8010724e <vector34>:
.globl vector34
vector34:
  pushl $0
8010724e:	6a 00                	push   $0x0
  pushl $34
80107250:	6a 22                	push   $0x22
  jmp alltraps
80107252:	e9 55 f8 ff ff       	jmp    80106aac <alltraps>

80107257 <vector35>:
.globl vector35
vector35:
  pushl $0
80107257:	6a 00                	push   $0x0
  pushl $35
80107259:	6a 23                	push   $0x23
  jmp alltraps
8010725b:	e9 4c f8 ff ff       	jmp    80106aac <alltraps>

80107260 <vector36>:
.globl vector36
vector36:
  pushl $0
80107260:	6a 00                	push   $0x0
  pushl $36
80107262:	6a 24                	push   $0x24
  jmp alltraps
80107264:	e9 43 f8 ff ff       	jmp    80106aac <alltraps>

80107269 <vector37>:
.globl vector37
vector37:
  pushl $0
80107269:	6a 00                	push   $0x0
  pushl $37
8010726b:	6a 25                	push   $0x25
  jmp alltraps
8010726d:	e9 3a f8 ff ff       	jmp    80106aac <alltraps>

80107272 <vector38>:
.globl vector38
vector38:
  pushl $0
80107272:	6a 00                	push   $0x0
  pushl $38
80107274:	6a 26                	push   $0x26
  jmp alltraps
80107276:	e9 31 f8 ff ff       	jmp    80106aac <alltraps>

8010727b <vector39>:
.globl vector39
vector39:
  pushl $0
8010727b:	6a 00                	push   $0x0
  pushl $39
8010727d:	6a 27                	push   $0x27
  jmp alltraps
8010727f:	e9 28 f8 ff ff       	jmp    80106aac <alltraps>

80107284 <vector40>:
.globl vector40
vector40:
  pushl $0
80107284:	6a 00                	push   $0x0
  pushl $40
80107286:	6a 28                	push   $0x28
  jmp alltraps
80107288:	e9 1f f8 ff ff       	jmp    80106aac <alltraps>

8010728d <vector41>:
.globl vector41
vector41:
  pushl $0
8010728d:	6a 00                	push   $0x0
  pushl $41
8010728f:	6a 29                	push   $0x29
  jmp alltraps
80107291:	e9 16 f8 ff ff       	jmp    80106aac <alltraps>

80107296 <vector42>:
.globl vector42
vector42:
  pushl $0
80107296:	6a 00                	push   $0x0
  pushl $42
80107298:	6a 2a                	push   $0x2a
  jmp alltraps
8010729a:	e9 0d f8 ff ff       	jmp    80106aac <alltraps>

8010729f <vector43>:
.globl vector43
vector43:
  pushl $0
8010729f:	6a 00                	push   $0x0
  pushl $43
801072a1:	6a 2b                	push   $0x2b
  jmp alltraps
801072a3:	e9 04 f8 ff ff       	jmp    80106aac <alltraps>

801072a8 <vector44>:
.globl vector44
vector44:
  pushl $0
801072a8:	6a 00                	push   $0x0
  pushl $44
801072aa:	6a 2c                	push   $0x2c
  jmp alltraps
801072ac:	e9 fb f7 ff ff       	jmp    80106aac <alltraps>

801072b1 <vector45>:
.globl vector45
vector45:
  pushl $0
801072b1:	6a 00                	push   $0x0
  pushl $45
801072b3:	6a 2d                	push   $0x2d
  jmp alltraps
801072b5:	e9 f2 f7 ff ff       	jmp    80106aac <alltraps>

801072ba <vector46>:
.globl vector46
vector46:
  pushl $0
801072ba:	6a 00                	push   $0x0
  pushl $46
801072bc:	6a 2e                	push   $0x2e
  jmp alltraps
801072be:	e9 e9 f7 ff ff       	jmp    80106aac <alltraps>

801072c3 <vector47>:
.globl vector47
vector47:
  pushl $0
801072c3:	6a 00                	push   $0x0
  pushl $47
801072c5:	6a 2f                	push   $0x2f
  jmp alltraps
801072c7:	e9 e0 f7 ff ff       	jmp    80106aac <alltraps>

801072cc <vector48>:
.globl vector48
vector48:
  pushl $0
801072cc:	6a 00                	push   $0x0
  pushl $48
801072ce:	6a 30                	push   $0x30
  jmp alltraps
801072d0:	e9 d7 f7 ff ff       	jmp    80106aac <alltraps>

801072d5 <vector49>:
.globl vector49
vector49:
  pushl $0
801072d5:	6a 00                	push   $0x0
  pushl $49
801072d7:	6a 31                	push   $0x31
  jmp alltraps
801072d9:	e9 ce f7 ff ff       	jmp    80106aac <alltraps>

801072de <vector50>:
.globl vector50
vector50:
  pushl $0
801072de:	6a 00                	push   $0x0
  pushl $50
801072e0:	6a 32                	push   $0x32
  jmp alltraps
801072e2:	e9 c5 f7 ff ff       	jmp    80106aac <alltraps>

801072e7 <vector51>:
.globl vector51
vector51:
  pushl $0
801072e7:	6a 00                	push   $0x0
  pushl $51
801072e9:	6a 33                	push   $0x33
  jmp alltraps
801072eb:	e9 bc f7 ff ff       	jmp    80106aac <alltraps>

801072f0 <vector52>:
.globl vector52
vector52:
  pushl $0
801072f0:	6a 00                	push   $0x0
  pushl $52
801072f2:	6a 34                	push   $0x34
  jmp alltraps
801072f4:	e9 b3 f7 ff ff       	jmp    80106aac <alltraps>

801072f9 <vector53>:
.globl vector53
vector53:
  pushl $0
801072f9:	6a 00                	push   $0x0
  pushl $53
801072fb:	6a 35                	push   $0x35
  jmp alltraps
801072fd:	e9 aa f7 ff ff       	jmp    80106aac <alltraps>

80107302 <vector54>:
.globl vector54
vector54:
  pushl $0
80107302:	6a 00                	push   $0x0
  pushl $54
80107304:	6a 36                	push   $0x36
  jmp alltraps
80107306:	e9 a1 f7 ff ff       	jmp    80106aac <alltraps>

8010730b <vector55>:
.globl vector55
vector55:
  pushl $0
8010730b:	6a 00                	push   $0x0
  pushl $55
8010730d:	6a 37                	push   $0x37
  jmp alltraps
8010730f:	e9 98 f7 ff ff       	jmp    80106aac <alltraps>

80107314 <vector56>:
.globl vector56
vector56:
  pushl $0
80107314:	6a 00                	push   $0x0
  pushl $56
80107316:	6a 38                	push   $0x38
  jmp alltraps
80107318:	e9 8f f7 ff ff       	jmp    80106aac <alltraps>

8010731d <vector57>:
.globl vector57
vector57:
  pushl $0
8010731d:	6a 00                	push   $0x0
  pushl $57
8010731f:	6a 39                	push   $0x39
  jmp alltraps
80107321:	e9 86 f7 ff ff       	jmp    80106aac <alltraps>

80107326 <vector58>:
.globl vector58
vector58:
  pushl $0
80107326:	6a 00                	push   $0x0
  pushl $58
80107328:	6a 3a                	push   $0x3a
  jmp alltraps
8010732a:	e9 7d f7 ff ff       	jmp    80106aac <alltraps>

8010732f <vector59>:
.globl vector59
vector59:
  pushl $0
8010732f:	6a 00                	push   $0x0
  pushl $59
80107331:	6a 3b                	push   $0x3b
  jmp alltraps
80107333:	e9 74 f7 ff ff       	jmp    80106aac <alltraps>

80107338 <vector60>:
.globl vector60
vector60:
  pushl $0
80107338:	6a 00                	push   $0x0
  pushl $60
8010733a:	6a 3c                	push   $0x3c
  jmp alltraps
8010733c:	e9 6b f7 ff ff       	jmp    80106aac <alltraps>

80107341 <vector61>:
.globl vector61
vector61:
  pushl $0
80107341:	6a 00                	push   $0x0
  pushl $61
80107343:	6a 3d                	push   $0x3d
  jmp alltraps
80107345:	e9 62 f7 ff ff       	jmp    80106aac <alltraps>

8010734a <vector62>:
.globl vector62
vector62:
  pushl $0
8010734a:	6a 00                	push   $0x0
  pushl $62
8010734c:	6a 3e                	push   $0x3e
  jmp alltraps
8010734e:	e9 59 f7 ff ff       	jmp    80106aac <alltraps>

80107353 <vector63>:
.globl vector63
vector63:
  pushl $0
80107353:	6a 00                	push   $0x0
  pushl $63
80107355:	6a 3f                	push   $0x3f
  jmp alltraps
80107357:	e9 50 f7 ff ff       	jmp    80106aac <alltraps>

8010735c <vector64>:
.globl vector64
vector64:
  pushl $0
8010735c:	6a 00                	push   $0x0
  pushl $64
8010735e:	6a 40                	push   $0x40
  jmp alltraps
80107360:	e9 47 f7 ff ff       	jmp    80106aac <alltraps>

80107365 <vector65>:
.globl vector65
vector65:
  pushl $0
80107365:	6a 00                	push   $0x0
  pushl $65
80107367:	6a 41                	push   $0x41
  jmp alltraps
80107369:	e9 3e f7 ff ff       	jmp    80106aac <alltraps>

8010736e <vector66>:
.globl vector66
vector66:
  pushl $0
8010736e:	6a 00                	push   $0x0
  pushl $66
80107370:	6a 42                	push   $0x42
  jmp alltraps
80107372:	e9 35 f7 ff ff       	jmp    80106aac <alltraps>

80107377 <vector67>:
.globl vector67
vector67:
  pushl $0
80107377:	6a 00                	push   $0x0
  pushl $67
80107379:	6a 43                	push   $0x43
  jmp alltraps
8010737b:	e9 2c f7 ff ff       	jmp    80106aac <alltraps>

80107380 <vector68>:
.globl vector68
vector68:
  pushl $0
80107380:	6a 00                	push   $0x0
  pushl $68
80107382:	6a 44                	push   $0x44
  jmp alltraps
80107384:	e9 23 f7 ff ff       	jmp    80106aac <alltraps>

80107389 <vector69>:
.globl vector69
vector69:
  pushl $0
80107389:	6a 00                	push   $0x0
  pushl $69
8010738b:	6a 45                	push   $0x45
  jmp alltraps
8010738d:	e9 1a f7 ff ff       	jmp    80106aac <alltraps>

80107392 <vector70>:
.globl vector70
vector70:
  pushl $0
80107392:	6a 00                	push   $0x0
  pushl $70
80107394:	6a 46                	push   $0x46
  jmp alltraps
80107396:	e9 11 f7 ff ff       	jmp    80106aac <alltraps>

8010739b <vector71>:
.globl vector71
vector71:
  pushl $0
8010739b:	6a 00                	push   $0x0
  pushl $71
8010739d:	6a 47                	push   $0x47
  jmp alltraps
8010739f:	e9 08 f7 ff ff       	jmp    80106aac <alltraps>

801073a4 <vector72>:
.globl vector72
vector72:
  pushl $0
801073a4:	6a 00                	push   $0x0
  pushl $72
801073a6:	6a 48                	push   $0x48
  jmp alltraps
801073a8:	e9 ff f6 ff ff       	jmp    80106aac <alltraps>

801073ad <vector73>:
.globl vector73
vector73:
  pushl $0
801073ad:	6a 00                	push   $0x0
  pushl $73
801073af:	6a 49                	push   $0x49
  jmp alltraps
801073b1:	e9 f6 f6 ff ff       	jmp    80106aac <alltraps>

801073b6 <vector74>:
.globl vector74
vector74:
  pushl $0
801073b6:	6a 00                	push   $0x0
  pushl $74
801073b8:	6a 4a                	push   $0x4a
  jmp alltraps
801073ba:	e9 ed f6 ff ff       	jmp    80106aac <alltraps>

801073bf <vector75>:
.globl vector75
vector75:
  pushl $0
801073bf:	6a 00                	push   $0x0
  pushl $75
801073c1:	6a 4b                	push   $0x4b
  jmp alltraps
801073c3:	e9 e4 f6 ff ff       	jmp    80106aac <alltraps>

801073c8 <vector76>:
.globl vector76
vector76:
  pushl $0
801073c8:	6a 00                	push   $0x0
  pushl $76
801073ca:	6a 4c                	push   $0x4c
  jmp alltraps
801073cc:	e9 db f6 ff ff       	jmp    80106aac <alltraps>

801073d1 <vector77>:
.globl vector77
vector77:
  pushl $0
801073d1:	6a 00                	push   $0x0
  pushl $77
801073d3:	6a 4d                	push   $0x4d
  jmp alltraps
801073d5:	e9 d2 f6 ff ff       	jmp    80106aac <alltraps>

801073da <vector78>:
.globl vector78
vector78:
  pushl $0
801073da:	6a 00                	push   $0x0
  pushl $78
801073dc:	6a 4e                	push   $0x4e
  jmp alltraps
801073de:	e9 c9 f6 ff ff       	jmp    80106aac <alltraps>

801073e3 <vector79>:
.globl vector79
vector79:
  pushl $0
801073e3:	6a 00                	push   $0x0
  pushl $79
801073e5:	6a 4f                	push   $0x4f
  jmp alltraps
801073e7:	e9 c0 f6 ff ff       	jmp    80106aac <alltraps>

801073ec <vector80>:
.globl vector80
vector80:
  pushl $0
801073ec:	6a 00                	push   $0x0
  pushl $80
801073ee:	6a 50                	push   $0x50
  jmp alltraps
801073f0:	e9 b7 f6 ff ff       	jmp    80106aac <alltraps>

801073f5 <vector81>:
.globl vector81
vector81:
  pushl $0
801073f5:	6a 00                	push   $0x0
  pushl $81
801073f7:	6a 51                	push   $0x51
  jmp alltraps
801073f9:	e9 ae f6 ff ff       	jmp    80106aac <alltraps>

801073fe <vector82>:
.globl vector82
vector82:
  pushl $0
801073fe:	6a 00                	push   $0x0
  pushl $82
80107400:	6a 52                	push   $0x52
  jmp alltraps
80107402:	e9 a5 f6 ff ff       	jmp    80106aac <alltraps>

80107407 <vector83>:
.globl vector83
vector83:
  pushl $0
80107407:	6a 00                	push   $0x0
  pushl $83
80107409:	6a 53                	push   $0x53
  jmp alltraps
8010740b:	e9 9c f6 ff ff       	jmp    80106aac <alltraps>

80107410 <vector84>:
.globl vector84
vector84:
  pushl $0
80107410:	6a 00                	push   $0x0
  pushl $84
80107412:	6a 54                	push   $0x54
  jmp alltraps
80107414:	e9 93 f6 ff ff       	jmp    80106aac <alltraps>

80107419 <vector85>:
.globl vector85
vector85:
  pushl $0
80107419:	6a 00                	push   $0x0
  pushl $85
8010741b:	6a 55                	push   $0x55
  jmp alltraps
8010741d:	e9 8a f6 ff ff       	jmp    80106aac <alltraps>

80107422 <vector86>:
.globl vector86
vector86:
  pushl $0
80107422:	6a 00                	push   $0x0
  pushl $86
80107424:	6a 56                	push   $0x56
  jmp alltraps
80107426:	e9 81 f6 ff ff       	jmp    80106aac <alltraps>

8010742b <vector87>:
.globl vector87
vector87:
  pushl $0
8010742b:	6a 00                	push   $0x0
  pushl $87
8010742d:	6a 57                	push   $0x57
  jmp alltraps
8010742f:	e9 78 f6 ff ff       	jmp    80106aac <alltraps>

80107434 <vector88>:
.globl vector88
vector88:
  pushl $0
80107434:	6a 00                	push   $0x0
  pushl $88
80107436:	6a 58                	push   $0x58
  jmp alltraps
80107438:	e9 6f f6 ff ff       	jmp    80106aac <alltraps>

8010743d <vector89>:
.globl vector89
vector89:
  pushl $0
8010743d:	6a 00                	push   $0x0
  pushl $89
8010743f:	6a 59                	push   $0x59
  jmp alltraps
80107441:	e9 66 f6 ff ff       	jmp    80106aac <alltraps>

80107446 <vector90>:
.globl vector90
vector90:
  pushl $0
80107446:	6a 00                	push   $0x0
  pushl $90
80107448:	6a 5a                	push   $0x5a
  jmp alltraps
8010744a:	e9 5d f6 ff ff       	jmp    80106aac <alltraps>

8010744f <vector91>:
.globl vector91
vector91:
  pushl $0
8010744f:	6a 00                	push   $0x0
  pushl $91
80107451:	6a 5b                	push   $0x5b
  jmp alltraps
80107453:	e9 54 f6 ff ff       	jmp    80106aac <alltraps>

80107458 <vector92>:
.globl vector92
vector92:
  pushl $0
80107458:	6a 00                	push   $0x0
  pushl $92
8010745a:	6a 5c                	push   $0x5c
  jmp alltraps
8010745c:	e9 4b f6 ff ff       	jmp    80106aac <alltraps>

80107461 <vector93>:
.globl vector93
vector93:
  pushl $0
80107461:	6a 00                	push   $0x0
  pushl $93
80107463:	6a 5d                	push   $0x5d
  jmp alltraps
80107465:	e9 42 f6 ff ff       	jmp    80106aac <alltraps>

8010746a <vector94>:
.globl vector94
vector94:
  pushl $0
8010746a:	6a 00                	push   $0x0
  pushl $94
8010746c:	6a 5e                	push   $0x5e
  jmp alltraps
8010746e:	e9 39 f6 ff ff       	jmp    80106aac <alltraps>

80107473 <vector95>:
.globl vector95
vector95:
  pushl $0
80107473:	6a 00                	push   $0x0
  pushl $95
80107475:	6a 5f                	push   $0x5f
  jmp alltraps
80107477:	e9 30 f6 ff ff       	jmp    80106aac <alltraps>

8010747c <vector96>:
.globl vector96
vector96:
  pushl $0
8010747c:	6a 00                	push   $0x0
  pushl $96
8010747e:	6a 60                	push   $0x60
  jmp alltraps
80107480:	e9 27 f6 ff ff       	jmp    80106aac <alltraps>

80107485 <vector97>:
.globl vector97
vector97:
  pushl $0
80107485:	6a 00                	push   $0x0
  pushl $97
80107487:	6a 61                	push   $0x61
  jmp alltraps
80107489:	e9 1e f6 ff ff       	jmp    80106aac <alltraps>

8010748e <vector98>:
.globl vector98
vector98:
  pushl $0
8010748e:	6a 00                	push   $0x0
  pushl $98
80107490:	6a 62                	push   $0x62
  jmp alltraps
80107492:	e9 15 f6 ff ff       	jmp    80106aac <alltraps>

80107497 <vector99>:
.globl vector99
vector99:
  pushl $0
80107497:	6a 00                	push   $0x0
  pushl $99
80107499:	6a 63                	push   $0x63
  jmp alltraps
8010749b:	e9 0c f6 ff ff       	jmp    80106aac <alltraps>

801074a0 <vector100>:
.globl vector100
vector100:
  pushl $0
801074a0:	6a 00                	push   $0x0
  pushl $100
801074a2:	6a 64                	push   $0x64
  jmp alltraps
801074a4:	e9 03 f6 ff ff       	jmp    80106aac <alltraps>

801074a9 <vector101>:
.globl vector101
vector101:
  pushl $0
801074a9:	6a 00                	push   $0x0
  pushl $101
801074ab:	6a 65                	push   $0x65
  jmp alltraps
801074ad:	e9 fa f5 ff ff       	jmp    80106aac <alltraps>

801074b2 <vector102>:
.globl vector102
vector102:
  pushl $0
801074b2:	6a 00                	push   $0x0
  pushl $102
801074b4:	6a 66                	push   $0x66
  jmp alltraps
801074b6:	e9 f1 f5 ff ff       	jmp    80106aac <alltraps>

801074bb <vector103>:
.globl vector103
vector103:
  pushl $0
801074bb:	6a 00                	push   $0x0
  pushl $103
801074bd:	6a 67                	push   $0x67
  jmp alltraps
801074bf:	e9 e8 f5 ff ff       	jmp    80106aac <alltraps>

801074c4 <vector104>:
.globl vector104
vector104:
  pushl $0
801074c4:	6a 00                	push   $0x0
  pushl $104
801074c6:	6a 68                	push   $0x68
  jmp alltraps
801074c8:	e9 df f5 ff ff       	jmp    80106aac <alltraps>

801074cd <vector105>:
.globl vector105
vector105:
  pushl $0
801074cd:	6a 00                	push   $0x0
  pushl $105
801074cf:	6a 69                	push   $0x69
  jmp alltraps
801074d1:	e9 d6 f5 ff ff       	jmp    80106aac <alltraps>

801074d6 <vector106>:
.globl vector106
vector106:
  pushl $0
801074d6:	6a 00                	push   $0x0
  pushl $106
801074d8:	6a 6a                	push   $0x6a
  jmp alltraps
801074da:	e9 cd f5 ff ff       	jmp    80106aac <alltraps>

801074df <vector107>:
.globl vector107
vector107:
  pushl $0
801074df:	6a 00                	push   $0x0
  pushl $107
801074e1:	6a 6b                	push   $0x6b
  jmp alltraps
801074e3:	e9 c4 f5 ff ff       	jmp    80106aac <alltraps>

801074e8 <vector108>:
.globl vector108
vector108:
  pushl $0
801074e8:	6a 00                	push   $0x0
  pushl $108
801074ea:	6a 6c                	push   $0x6c
  jmp alltraps
801074ec:	e9 bb f5 ff ff       	jmp    80106aac <alltraps>

801074f1 <vector109>:
.globl vector109
vector109:
  pushl $0
801074f1:	6a 00                	push   $0x0
  pushl $109
801074f3:	6a 6d                	push   $0x6d
  jmp alltraps
801074f5:	e9 b2 f5 ff ff       	jmp    80106aac <alltraps>

801074fa <vector110>:
.globl vector110
vector110:
  pushl $0
801074fa:	6a 00                	push   $0x0
  pushl $110
801074fc:	6a 6e                	push   $0x6e
  jmp alltraps
801074fe:	e9 a9 f5 ff ff       	jmp    80106aac <alltraps>

80107503 <vector111>:
.globl vector111
vector111:
  pushl $0
80107503:	6a 00                	push   $0x0
  pushl $111
80107505:	6a 6f                	push   $0x6f
  jmp alltraps
80107507:	e9 a0 f5 ff ff       	jmp    80106aac <alltraps>

8010750c <vector112>:
.globl vector112
vector112:
  pushl $0
8010750c:	6a 00                	push   $0x0
  pushl $112
8010750e:	6a 70                	push   $0x70
  jmp alltraps
80107510:	e9 97 f5 ff ff       	jmp    80106aac <alltraps>

80107515 <vector113>:
.globl vector113
vector113:
  pushl $0
80107515:	6a 00                	push   $0x0
  pushl $113
80107517:	6a 71                	push   $0x71
  jmp alltraps
80107519:	e9 8e f5 ff ff       	jmp    80106aac <alltraps>

8010751e <vector114>:
.globl vector114
vector114:
  pushl $0
8010751e:	6a 00                	push   $0x0
  pushl $114
80107520:	6a 72                	push   $0x72
  jmp alltraps
80107522:	e9 85 f5 ff ff       	jmp    80106aac <alltraps>

80107527 <vector115>:
.globl vector115
vector115:
  pushl $0
80107527:	6a 00                	push   $0x0
  pushl $115
80107529:	6a 73                	push   $0x73
  jmp alltraps
8010752b:	e9 7c f5 ff ff       	jmp    80106aac <alltraps>

80107530 <vector116>:
.globl vector116
vector116:
  pushl $0
80107530:	6a 00                	push   $0x0
  pushl $116
80107532:	6a 74                	push   $0x74
  jmp alltraps
80107534:	e9 73 f5 ff ff       	jmp    80106aac <alltraps>

80107539 <vector117>:
.globl vector117
vector117:
  pushl $0
80107539:	6a 00                	push   $0x0
  pushl $117
8010753b:	6a 75                	push   $0x75
  jmp alltraps
8010753d:	e9 6a f5 ff ff       	jmp    80106aac <alltraps>

80107542 <vector118>:
.globl vector118
vector118:
  pushl $0
80107542:	6a 00                	push   $0x0
  pushl $118
80107544:	6a 76                	push   $0x76
  jmp alltraps
80107546:	e9 61 f5 ff ff       	jmp    80106aac <alltraps>

8010754b <vector119>:
.globl vector119
vector119:
  pushl $0
8010754b:	6a 00                	push   $0x0
  pushl $119
8010754d:	6a 77                	push   $0x77
  jmp alltraps
8010754f:	e9 58 f5 ff ff       	jmp    80106aac <alltraps>

80107554 <vector120>:
.globl vector120
vector120:
  pushl $0
80107554:	6a 00                	push   $0x0
  pushl $120
80107556:	6a 78                	push   $0x78
  jmp alltraps
80107558:	e9 4f f5 ff ff       	jmp    80106aac <alltraps>

8010755d <vector121>:
.globl vector121
vector121:
  pushl $0
8010755d:	6a 00                	push   $0x0
  pushl $121
8010755f:	6a 79                	push   $0x79
  jmp alltraps
80107561:	e9 46 f5 ff ff       	jmp    80106aac <alltraps>

80107566 <vector122>:
.globl vector122
vector122:
  pushl $0
80107566:	6a 00                	push   $0x0
  pushl $122
80107568:	6a 7a                	push   $0x7a
  jmp alltraps
8010756a:	e9 3d f5 ff ff       	jmp    80106aac <alltraps>

8010756f <vector123>:
.globl vector123
vector123:
  pushl $0
8010756f:	6a 00                	push   $0x0
  pushl $123
80107571:	6a 7b                	push   $0x7b
  jmp alltraps
80107573:	e9 34 f5 ff ff       	jmp    80106aac <alltraps>

80107578 <vector124>:
.globl vector124
vector124:
  pushl $0
80107578:	6a 00                	push   $0x0
  pushl $124
8010757a:	6a 7c                	push   $0x7c
  jmp alltraps
8010757c:	e9 2b f5 ff ff       	jmp    80106aac <alltraps>

80107581 <vector125>:
.globl vector125
vector125:
  pushl $0
80107581:	6a 00                	push   $0x0
  pushl $125
80107583:	6a 7d                	push   $0x7d
  jmp alltraps
80107585:	e9 22 f5 ff ff       	jmp    80106aac <alltraps>

8010758a <vector126>:
.globl vector126
vector126:
  pushl $0
8010758a:	6a 00                	push   $0x0
  pushl $126
8010758c:	6a 7e                	push   $0x7e
  jmp alltraps
8010758e:	e9 19 f5 ff ff       	jmp    80106aac <alltraps>

80107593 <vector127>:
.globl vector127
vector127:
  pushl $0
80107593:	6a 00                	push   $0x0
  pushl $127
80107595:	6a 7f                	push   $0x7f
  jmp alltraps
80107597:	e9 10 f5 ff ff       	jmp    80106aac <alltraps>

8010759c <vector128>:
.globl vector128
vector128:
  pushl $0
8010759c:	6a 00                	push   $0x0
  pushl $128
8010759e:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801075a3:	e9 04 f5 ff ff       	jmp    80106aac <alltraps>

801075a8 <vector129>:
.globl vector129
vector129:
  pushl $0
801075a8:	6a 00                	push   $0x0
  pushl $129
801075aa:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801075af:	e9 f8 f4 ff ff       	jmp    80106aac <alltraps>

801075b4 <vector130>:
.globl vector130
vector130:
  pushl $0
801075b4:	6a 00                	push   $0x0
  pushl $130
801075b6:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801075bb:	e9 ec f4 ff ff       	jmp    80106aac <alltraps>

801075c0 <vector131>:
.globl vector131
vector131:
  pushl $0
801075c0:	6a 00                	push   $0x0
  pushl $131
801075c2:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801075c7:	e9 e0 f4 ff ff       	jmp    80106aac <alltraps>

801075cc <vector132>:
.globl vector132
vector132:
  pushl $0
801075cc:	6a 00                	push   $0x0
  pushl $132
801075ce:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801075d3:	e9 d4 f4 ff ff       	jmp    80106aac <alltraps>

801075d8 <vector133>:
.globl vector133
vector133:
  pushl $0
801075d8:	6a 00                	push   $0x0
  pushl $133
801075da:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801075df:	e9 c8 f4 ff ff       	jmp    80106aac <alltraps>

801075e4 <vector134>:
.globl vector134
vector134:
  pushl $0
801075e4:	6a 00                	push   $0x0
  pushl $134
801075e6:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801075eb:	e9 bc f4 ff ff       	jmp    80106aac <alltraps>

801075f0 <vector135>:
.globl vector135
vector135:
  pushl $0
801075f0:	6a 00                	push   $0x0
  pushl $135
801075f2:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801075f7:	e9 b0 f4 ff ff       	jmp    80106aac <alltraps>

801075fc <vector136>:
.globl vector136
vector136:
  pushl $0
801075fc:	6a 00                	push   $0x0
  pushl $136
801075fe:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107603:	e9 a4 f4 ff ff       	jmp    80106aac <alltraps>

80107608 <vector137>:
.globl vector137
vector137:
  pushl $0
80107608:	6a 00                	push   $0x0
  pushl $137
8010760a:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010760f:	e9 98 f4 ff ff       	jmp    80106aac <alltraps>

80107614 <vector138>:
.globl vector138
vector138:
  pushl $0
80107614:	6a 00                	push   $0x0
  pushl $138
80107616:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010761b:	e9 8c f4 ff ff       	jmp    80106aac <alltraps>

80107620 <vector139>:
.globl vector139
vector139:
  pushl $0
80107620:	6a 00                	push   $0x0
  pushl $139
80107622:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107627:	e9 80 f4 ff ff       	jmp    80106aac <alltraps>

8010762c <vector140>:
.globl vector140
vector140:
  pushl $0
8010762c:	6a 00                	push   $0x0
  pushl $140
8010762e:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107633:	e9 74 f4 ff ff       	jmp    80106aac <alltraps>

80107638 <vector141>:
.globl vector141
vector141:
  pushl $0
80107638:	6a 00                	push   $0x0
  pushl $141
8010763a:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010763f:	e9 68 f4 ff ff       	jmp    80106aac <alltraps>

80107644 <vector142>:
.globl vector142
vector142:
  pushl $0
80107644:	6a 00                	push   $0x0
  pushl $142
80107646:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010764b:	e9 5c f4 ff ff       	jmp    80106aac <alltraps>

80107650 <vector143>:
.globl vector143
vector143:
  pushl $0
80107650:	6a 00                	push   $0x0
  pushl $143
80107652:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107657:	e9 50 f4 ff ff       	jmp    80106aac <alltraps>

8010765c <vector144>:
.globl vector144
vector144:
  pushl $0
8010765c:	6a 00                	push   $0x0
  pushl $144
8010765e:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107663:	e9 44 f4 ff ff       	jmp    80106aac <alltraps>

80107668 <vector145>:
.globl vector145
vector145:
  pushl $0
80107668:	6a 00                	push   $0x0
  pushl $145
8010766a:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010766f:	e9 38 f4 ff ff       	jmp    80106aac <alltraps>

80107674 <vector146>:
.globl vector146
vector146:
  pushl $0
80107674:	6a 00                	push   $0x0
  pushl $146
80107676:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010767b:	e9 2c f4 ff ff       	jmp    80106aac <alltraps>

80107680 <vector147>:
.globl vector147
vector147:
  pushl $0
80107680:	6a 00                	push   $0x0
  pushl $147
80107682:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107687:	e9 20 f4 ff ff       	jmp    80106aac <alltraps>

8010768c <vector148>:
.globl vector148
vector148:
  pushl $0
8010768c:	6a 00                	push   $0x0
  pushl $148
8010768e:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107693:	e9 14 f4 ff ff       	jmp    80106aac <alltraps>

80107698 <vector149>:
.globl vector149
vector149:
  pushl $0
80107698:	6a 00                	push   $0x0
  pushl $149
8010769a:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010769f:	e9 08 f4 ff ff       	jmp    80106aac <alltraps>

801076a4 <vector150>:
.globl vector150
vector150:
  pushl $0
801076a4:	6a 00                	push   $0x0
  pushl $150
801076a6:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801076ab:	e9 fc f3 ff ff       	jmp    80106aac <alltraps>

801076b0 <vector151>:
.globl vector151
vector151:
  pushl $0
801076b0:	6a 00                	push   $0x0
  pushl $151
801076b2:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801076b7:	e9 f0 f3 ff ff       	jmp    80106aac <alltraps>

801076bc <vector152>:
.globl vector152
vector152:
  pushl $0
801076bc:	6a 00                	push   $0x0
  pushl $152
801076be:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801076c3:	e9 e4 f3 ff ff       	jmp    80106aac <alltraps>

801076c8 <vector153>:
.globl vector153
vector153:
  pushl $0
801076c8:	6a 00                	push   $0x0
  pushl $153
801076ca:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801076cf:	e9 d8 f3 ff ff       	jmp    80106aac <alltraps>

801076d4 <vector154>:
.globl vector154
vector154:
  pushl $0
801076d4:	6a 00                	push   $0x0
  pushl $154
801076d6:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801076db:	e9 cc f3 ff ff       	jmp    80106aac <alltraps>

801076e0 <vector155>:
.globl vector155
vector155:
  pushl $0
801076e0:	6a 00                	push   $0x0
  pushl $155
801076e2:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801076e7:	e9 c0 f3 ff ff       	jmp    80106aac <alltraps>

801076ec <vector156>:
.globl vector156
vector156:
  pushl $0
801076ec:	6a 00                	push   $0x0
  pushl $156
801076ee:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801076f3:	e9 b4 f3 ff ff       	jmp    80106aac <alltraps>

801076f8 <vector157>:
.globl vector157
vector157:
  pushl $0
801076f8:	6a 00                	push   $0x0
  pushl $157
801076fa:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801076ff:	e9 a8 f3 ff ff       	jmp    80106aac <alltraps>

80107704 <vector158>:
.globl vector158
vector158:
  pushl $0
80107704:	6a 00                	push   $0x0
  pushl $158
80107706:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010770b:	e9 9c f3 ff ff       	jmp    80106aac <alltraps>

80107710 <vector159>:
.globl vector159
vector159:
  pushl $0
80107710:	6a 00                	push   $0x0
  pushl $159
80107712:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107717:	e9 90 f3 ff ff       	jmp    80106aac <alltraps>

8010771c <vector160>:
.globl vector160
vector160:
  pushl $0
8010771c:	6a 00                	push   $0x0
  pushl $160
8010771e:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107723:	e9 84 f3 ff ff       	jmp    80106aac <alltraps>

80107728 <vector161>:
.globl vector161
vector161:
  pushl $0
80107728:	6a 00                	push   $0x0
  pushl $161
8010772a:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010772f:	e9 78 f3 ff ff       	jmp    80106aac <alltraps>

80107734 <vector162>:
.globl vector162
vector162:
  pushl $0
80107734:	6a 00                	push   $0x0
  pushl $162
80107736:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010773b:	e9 6c f3 ff ff       	jmp    80106aac <alltraps>

80107740 <vector163>:
.globl vector163
vector163:
  pushl $0
80107740:	6a 00                	push   $0x0
  pushl $163
80107742:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107747:	e9 60 f3 ff ff       	jmp    80106aac <alltraps>

8010774c <vector164>:
.globl vector164
vector164:
  pushl $0
8010774c:	6a 00                	push   $0x0
  pushl $164
8010774e:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107753:	e9 54 f3 ff ff       	jmp    80106aac <alltraps>

80107758 <vector165>:
.globl vector165
vector165:
  pushl $0
80107758:	6a 00                	push   $0x0
  pushl $165
8010775a:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010775f:	e9 48 f3 ff ff       	jmp    80106aac <alltraps>

80107764 <vector166>:
.globl vector166
vector166:
  pushl $0
80107764:	6a 00                	push   $0x0
  pushl $166
80107766:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010776b:	e9 3c f3 ff ff       	jmp    80106aac <alltraps>

80107770 <vector167>:
.globl vector167
vector167:
  pushl $0
80107770:	6a 00                	push   $0x0
  pushl $167
80107772:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107777:	e9 30 f3 ff ff       	jmp    80106aac <alltraps>

8010777c <vector168>:
.globl vector168
vector168:
  pushl $0
8010777c:	6a 00                	push   $0x0
  pushl $168
8010777e:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107783:	e9 24 f3 ff ff       	jmp    80106aac <alltraps>

80107788 <vector169>:
.globl vector169
vector169:
  pushl $0
80107788:	6a 00                	push   $0x0
  pushl $169
8010778a:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010778f:	e9 18 f3 ff ff       	jmp    80106aac <alltraps>

80107794 <vector170>:
.globl vector170
vector170:
  pushl $0
80107794:	6a 00                	push   $0x0
  pushl $170
80107796:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010779b:	e9 0c f3 ff ff       	jmp    80106aac <alltraps>

801077a0 <vector171>:
.globl vector171
vector171:
  pushl $0
801077a0:	6a 00                	push   $0x0
  pushl $171
801077a2:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801077a7:	e9 00 f3 ff ff       	jmp    80106aac <alltraps>

801077ac <vector172>:
.globl vector172
vector172:
  pushl $0
801077ac:	6a 00                	push   $0x0
  pushl $172
801077ae:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801077b3:	e9 f4 f2 ff ff       	jmp    80106aac <alltraps>

801077b8 <vector173>:
.globl vector173
vector173:
  pushl $0
801077b8:	6a 00                	push   $0x0
  pushl $173
801077ba:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801077bf:	e9 e8 f2 ff ff       	jmp    80106aac <alltraps>

801077c4 <vector174>:
.globl vector174
vector174:
  pushl $0
801077c4:	6a 00                	push   $0x0
  pushl $174
801077c6:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801077cb:	e9 dc f2 ff ff       	jmp    80106aac <alltraps>

801077d0 <vector175>:
.globl vector175
vector175:
  pushl $0
801077d0:	6a 00                	push   $0x0
  pushl $175
801077d2:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801077d7:	e9 d0 f2 ff ff       	jmp    80106aac <alltraps>

801077dc <vector176>:
.globl vector176
vector176:
  pushl $0
801077dc:	6a 00                	push   $0x0
  pushl $176
801077de:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801077e3:	e9 c4 f2 ff ff       	jmp    80106aac <alltraps>

801077e8 <vector177>:
.globl vector177
vector177:
  pushl $0
801077e8:	6a 00                	push   $0x0
  pushl $177
801077ea:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801077ef:	e9 b8 f2 ff ff       	jmp    80106aac <alltraps>

801077f4 <vector178>:
.globl vector178
vector178:
  pushl $0
801077f4:	6a 00                	push   $0x0
  pushl $178
801077f6:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801077fb:	e9 ac f2 ff ff       	jmp    80106aac <alltraps>

80107800 <vector179>:
.globl vector179
vector179:
  pushl $0
80107800:	6a 00                	push   $0x0
  pushl $179
80107802:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107807:	e9 a0 f2 ff ff       	jmp    80106aac <alltraps>

8010780c <vector180>:
.globl vector180
vector180:
  pushl $0
8010780c:	6a 00                	push   $0x0
  pushl $180
8010780e:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107813:	e9 94 f2 ff ff       	jmp    80106aac <alltraps>

80107818 <vector181>:
.globl vector181
vector181:
  pushl $0
80107818:	6a 00                	push   $0x0
  pushl $181
8010781a:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010781f:	e9 88 f2 ff ff       	jmp    80106aac <alltraps>

80107824 <vector182>:
.globl vector182
vector182:
  pushl $0
80107824:	6a 00                	push   $0x0
  pushl $182
80107826:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010782b:	e9 7c f2 ff ff       	jmp    80106aac <alltraps>

80107830 <vector183>:
.globl vector183
vector183:
  pushl $0
80107830:	6a 00                	push   $0x0
  pushl $183
80107832:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107837:	e9 70 f2 ff ff       	jmp    80106aac <alltraps>

8010783c <vector184>:
.globl vector184
vector184:
  pushl $0
8010783c:	6a 00                	push   $0x0
  pushl $184
8010783e:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107843:	e9 64 f2 ff ff       	jmp    80106aac <alltraps>

80107848 <vector185>:
.globl vector185
vector185:
  pushl $0
80107848:	6a 00                	push   $0x0
  pushl $185
8010784a:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010784f:	e9 58 f2 ff ff       	jmp    80106aac <alltraps>

80107854 <vector186>:
.globl vector186
vector186:
  pushl $0
80107854:	6a 00                	push   $0x0
  pushl $186
80107856:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010785b:	e9 4c f2 ff ff       	jmp    80106aac <alltraps>

80107860 <vector187>:
.globl vector187
vector187:
  pushl $0
80107860:	6a 00                	push   $0x0
  pushl $187
80107862:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107867:	e9 40 f2 ff ff       	jmp    80106aac <alltraps>

8010786c <vector188>:
.globl vector188
vector188:
  pushl $0
8010786c:	6a 00                	push   $0x0
  pushl $188
8010786e:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107873:	e9 34 f2 ff ff       	jmp    80106aac <alltraps>

80107878 <vector189>:
.globl vector189
vector189:
  pushl $0
80107878:	6a 00                	push   $0x0
  pushl $189
8010787a:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010787f:	e9 28 f2 ff ff       	jmp    80106aac <alltraps>

80107884 <vector190>:
.globl vector190
vector190:
  pushl $0
80107884:	6a 00                	push   $0x0
  pushl $190
80107886:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010788b:	e9 1c f2 ff ff       	jmp    80106aac <alltraps>

80107890 <vector191>:
.globl vector191
vector191:
  pushl $0
80107890:	6a 00                	push   $0x0
  pushl $191
80107892:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107897:	e9 10 f2 ff ff       	jmp    80106aac <alltraps>

8010789c <vector192>:
.globl vector192
vector192:
  pushl $0
8010789c:	6a 00                	push   $0x0
  pushl $192
8010789e:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801078a3:	e9 04 f2 ff ff       	jmp    80106aac <alltraps>

801078a8 <vector193>:
.globl vector193
vector193:
  pushl $0
801078a8:	6a 00                	push   $0x0
  pushl $193
801078aa:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801078af:	e9 f8 f1 ff ff       	jmp    80106aac <alltraps>

801078b4 <vector194>:
.globl vector194
vector194:
  pushl $0
801078b4:	6a 00                	push   $0x0
  pushl $194
801078b6:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801078bb:	e9 ec f1 ff ff       	jmp    80106aac <alltraps>

801078c0 <vector195>:
.globl vector195
vector195:
  pushl $0
801078c0:	6a 00                	push   $0x0
  pushl $195
801078c2:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801078c7:	e9 e0 f1 ff ff       	jmp    80106aac <alltraps>

801078cc <vector196>:
.globl vector196
vector196:
  pushl $0
801078cc:	6a 00                	push   $0x0
  pushl $196
801078ce:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801078d3:	e9 d4 f1 ff ff       	jmp    80106aac <alltraps>

801078d8 <vector197>:
.globl vector197
vector197:
  pushl $0
801078d8:	6a 00                	push   $0x0
  pushl $197
801078da:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801078df:	e9 c8 f1 ff ff       	jmp    80106aac <alltraps>

801078e4 <vector198>:
.globl vector198
vector198:
  pushl $0
801078e4:	6a 00                	push   $0x0
  pushl $198
801078e6:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801078eb:	e9 bc f1 ff ff       	jmp    80106aac <alltraps>

801078f0 <vector199>:
.globl vector199
vector199:
  pushl $0
801078f0:	6a 00                	push   $0x0
  pushl $199
801078f2:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801078f7:	e9 b0 f1 ff ff       	jmp    80106aac <alltraps>

801078fc <vector200>:
.globl vector200
vector200:
  pushl $0
801078fc:	6a 00                	push   $0x0
  pushl $200
801078fe:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107903:	e9 a4 f1 ff ff       	jmp    80106aac <alltraps>

80107908 <vector201>:
.globl vector201
vector201:
  pushl $0
80107908:	6a 00                	push   $0x0
  pushl $201
8010790a:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010790f:	e9 98 f1 ff ff       	jmp    80106aac <alltraps>

80107914 <vector202>:
.globl vector202
vector202:
  pushl $0
80107914:	6a 00                	push   $0x0
  pushl $202
80107916:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010791b:	e9 8c f1 ff ff       	jmp    80106aac <alltraps>

80107920 <vector203>:
.globl vector203
vector203:
  pushl $0
80107920:	6a 00                	push   $0x0
  pushl $203
80107922:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107927:	e9 80 f1 ff ff       	jmp    80106aac <alltraps>

8010792c <vector204>:
.globl vector204
vector204:
  pushl $0
8010792c:	6a 00                	push   $0x0
  pushl $204
8010792e:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107933:	e9 74 f1 ff ff       	jmp    80106aac <alltraps>

80107938 <vector205>:
.globl vector205
vector205:
  pushl $0
80107938:	6a 00                	push   $0x0
  pushl $205
8010793a:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010793f:	e9 68 f1 ff ff       	jmp    80106aac <alltraps>

80107944 <vector206>:
.globl vector206
vector206:
  pushl $0
80107944:	6a 00                	push   $0x0
  pushl $206
80107946:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010794b:	e9 5c f1 ff ff       	jmp    80106aac <alltraps>

80107950 <vector207>:
.globl vector207
vector207:
  pushl $0
80107950:	6a 00                	push   $0x0
  pushl $207
80107952:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107957:	e9 50 f1 ff ff       	jmp    80106aac <alltraps>

8010795c <vector208>:
.globl vector208
vector208:
  pushl $0
8010795c:	6a 00                	push   $0x0
  pushl $208
8010795e:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107963:	e9 44 f1 ff ff       	jmp    80106aac <alltraps>

80107968 <vector209>:
.globl vector209
vector209:
  pushl $0
80107968:	6a 00                	push   $0x0
  pushl $209
8010796a:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010796f:	e9 38 f1 ff ff       	jmp    80106aac <alltraps>

80107974 <vector210>:
.globl vector210
vector210:
  pushl $0
80107974:	6a 00                	push   $0x0
  pushl $210
80107976:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010797b:	e9 2c f1 ff ff       	jmp    80106aac <alltraps>

80107980 <vector211>:
.globl vector211
vector211:
  pushl $0
80107980:	6a 00                	push   $0x0
  pushl $211
80107982:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107987:	e9 20 f1 ff ff       	jmp    80106aac <alltraps>

8010798c <vector212>:
.globl vector212
vector212:
  pushl $0
8010798c:	6a 00                	push   $0x0
  pushl $212
8010798e:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107993:	e9 14 f1 ff ff       	jmp    80106aac <alltraps>

80107998 <vector213>:
.globl vector213
vector213:
  pushl $0
80107998:	6a 00                	push   $0x0
  pushl $213
8010799a:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010799f:	e9 08 f1 ff ff       	jmp    80106aac <alltraps>

801079a4 <vector214>:
.globl vector214
vector214:
  pushl $0
801079a4:	6a 00                	push   $0x0
  pushl $214
801079a6:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801079ab:	e9 fc f0 ff ff       	jmp    80106aac <alltraps>

801079b0 <vector215>:
.globl vector215
vector215:
  pushl $0
801079b0:	6a 00                	push   $0x0
  pushl $215
801079b2:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801079b7:	e9 f0 f0 ff ff       	jmp    80106aac <alltraps>

801079bc <vector216>:
.globl vector216
vector216:
  pushl $0
801079bc:	6a 00                	push   $0x0
  pushl $216
801079be:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801079c3:	e9 e4 f0 ff ff       	jmp    80106aac <alltraps>

801079c8 <vector217>:
.globl vector217
vector217:
  pushl $0
801079c8:	6a 00                	push   $0x0
  pushl $217
801079ca:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801079cf:	e9 d8 f0 ff ff       	jmp    80106aac <alltraps>

801079d4 <vector218>:
.globl vector218
vector218:
  pushl $0
801079d4:	6a 00                	push   $0x0
  pushl $218
801079d6:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801079db:	e9 cc f0 ff ff       	jmp    80106aac <alltraps>

801079e0 <vector219>:
.globl vector219
vector219:
  pushl $0
801079e0:	6a 00                	push   $0x0
  pushl $219
801079e2:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801079e7:	e9 c0 f0 ff ff       	jmp    80106aac <alltraps>

801079ec <vector220>:
.globl vector220
vector220:
  pushl $0
801079ec:	6a 00                	push   $0x0
  pushl $220
801079ee:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801079f3:	e9 b4 f0 ff ff       	jmp    80106aac <alltraps>

801079f8 <vector221>:
.globl vector221
vector221:
  pushl $0
801079f8:	6a 00                	push   $0x0
  pushl $221
801079fa:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801079ff:	e9 a8 f0 ff ff       	jmp    80106aac <alltraps>

80107a04 <vector222>:
.globl vector222
vector222:
  pushl $0
80107a04:	6a 00                	push   $0x0
  pushl $222
80107a06:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107a0b:	e9 9c f0 ff ff       	jmp    80106aac <alltraps>

80107a10 <vector223>:
.globl vector223
vector223:
  pushl $0
80107a10:	6a 00                	push   $0x0
  pushl $223
80107a12:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107a17:	e9 90 f0 ff ff       	jmp    80106aac <alltraps>

80107a1c <vector224>:
.globl vector224
vector224:
  pushl $0
80107a1c:	6a 00                	push   $0x0
  pushl $224
80107a1e:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107a23:	e9 84 f0 ff ff       	jmp    80106aac <alltraps>

80107a28 <vector225>:
.globl vector225
vector225:
  pushl $0
80107a28:	6a 00                	push   $0x0
  pushl $225
80107a2a:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107a2f:	e9 78 f0 ff ff       	jmp    80106aac <alltraps>

80107a34 <vector226>:
.globl vector226
vector226:
  pushl $0
80107a34:	6a 00                	push   $0x0
  pushl $226
80107a36:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107a3b:	e9 6c f0 ff ff       	jmp    80106aac <alltraps>

80107a40 <vector227>:
.globl vector227
vector227:
  pushl $0
80107a40:	6a 00                	push   $0x0
  pushl $227
80107a42:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107a47:	e9 60 f0 ff ff       	jmp    80106aac <alltraps>

80107a4c <vector228>:
.globl vector228
vector228:
  pushl $0
80107a4c:	6a 00                	push   $0x0
  pushl $228
80107a4e:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107a53:	e9 54 f0 ff ff       	jmp    80106aac <alltraps>

80107a58 <vector229>:
.globl vector229
vector229:
  pushl $0
80107a58:	6a 00                	push   $0x0
  pushl $229
80107a5a:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107a5f:	e9 48 f0 ff ff       	jmp    80106aac <alltraps>

80107a64 <vector230>:
.globl vector230
vector230:
  pushl $0
80107a64:	6a 00                	push   $0x0
  pushl $230
80107a66:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107a6b:	e9 3c f0 ff ff       	jmp    80106aac <alltraps>

80107a70 <vector231>:
.globl vector231
vector231:
  pushl $0
80107a70:	6a 00                	push   $0x0
  pushl $231
80107a72:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107a77:	e9 30 f0 ff ff       	jmp    80106aac <alltraps>

80107a7c <vector232>:
.globl vector232
vector232:
  pushl $0
80107a7c:	6a 00                	push   $0x0
  pushl $232
80107a7e:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107a83:	e9 24 f0 ff ff       	jmp    80106aac <alltraps>

80107a88 <vector233>:
.globl vector233
vector233:
  pushl $0
80107a88:	6a 00                	push   $0x0
  pushl $233
80107a8a:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107a8f:	e9 18 f0 ff ff       	jmp    80106aac <alltraps>

80107a94 <vector234>:
.globl vector234
vector234:
  pushl $0
80107a94:	6a 00                	push   $0x0
  pushl $234
80107a96:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107a9b:	e9 0c f0 ff ff       	jmp    80106aac <alltraps>

80107aa0 <vector235>:
.globl vector235
vector235:
  pushl $0
80107aa0:	6a 00                	push   $0x0
  pushl $235
80107aa2:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107aa7:	e9 00 f0 ff ff       	jmp    80106aac <alltraps>

80107aac <vector236>:
.globl vector236
vector236:
  pushl $0
80107aac:	6a 00                	push   $0x0
  pushl $236
80107aae:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107ab3:	e9 f4 ef ff ff       	jmp    80106aac <alltraps>

80107ab8 <vector237>:
.globl vector237
vector237:
  pushl $0
80107ab8:	6a 00                	push   $0x0
  pushl $237
80107aba:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107abf:	e9 e8 ef ff ff       	jmp    80106aac <alltraps>

80107ac4 <vector238>:
.globl vector238
vector238:
  pushl $0
80107ac4:	6a 00                	push   $0x0
  pushl $238
80107ac6:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107acb:	e9 dc ef ff ff       	jmp    80106aac <alltraps>

80107ad0 <vector239>:
.globl vector239
vector239:
  pushl $0
80107ad0:	6a 00                	push   $0x0
  pushl $239
80107ad2:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107ad7:	e9 d0 ef ff ff       	jmp    80106aac <alltraps>

80107adc <vector240>:
.globl vector240
vector240:
  pushl $0
80107adc:	6a 00                	push   $0x0
  pushl $240
80107ade:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107ae3:	e9 c4 ef ff ff       	jmp    80106aac <alltraps>

80107ae8 <vector241>:
.globl vector241
vector241:
  pushl $0
80107ae8:	6a 00                	push   $0x0
  pushl $241
80107aea:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107aef:	e9 b8 ef ff ff       	jmp    80106aac <alltraps>

80107af4 <vector242>:
.globl vector242
vector242:
  pushl $0
80107af4:	6a 00                	push   $0x0
  pushl $242
80107af6:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107afb:	e9 ac ef ff ff       	jmp    80106aac <alltraps>

80107b00 <vector243>:
.globl vector243
vector243:
  pushl $0
80107b00:	6a 00                	push   $0x0
  pushl $243
80107b02:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107b07:	e9 a0 ef ff ff       	jmp    80106aac <alltraps>

80107b0c <vector244>:
.globl vector244
vector244:
  pushl $0
80107b0c:	6a 00                	push   $0x0
  pushl $244
80107b0e:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107b13:	e9 94 ef ff ff       	jmp    80106aac <alltraps>

80107b18 <vector245>:
.globl vector245
vector245:
  pushl $0
80107b18:	6a 00                	push   $0x0
  pushl $245
80107b1a:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107b1f:	e9 88 ef ff ff       	jmp    80106aac <alltraps>

80107b24 <vector246>:
.globl vector246
vector246:
  pushl $0
80107b24:	6a 00                	push   $0x0
  pushl $246
80107b26:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107b2b:	e9 7c ef ff ff       	jmp    80106aac <alltraps>

80107b30 <vector247>:
.globl vector247
vector247:
  pushl $0
80107b30:	6a 00                	push   $0x0
  pushl $247
80107b32:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107b37:	e9 70 ef ff ff       	jmp    80106aac <alltraps>

80107b3c <vector248>:
.globl vector248
vector248:
  pushl $0
80107b3c:	6a 00                	push   $0x0
  pushl $248
80107b3e:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107b43:	e9 64 ef ff ff       	jmp    80106aac <alltraps>

80107b48 <vector249>:
.globl vector249
vector249:
  pushl $0
80107b48:	6a 00                	push   $0x0
  pushl $249
80107b4a:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107b4f:	e9 58 ef ff ff       	jmp    80106aac <alltraps>

80107b54 <vector250>:
.globl vector250
vector250:
  pushl $0
80107b54:	6a 00                	push   $0x0
  pushl $250
80107b56:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107b5b:	e9 4c ef ff ff       	jmp    80106aac <alltraps>

80107b60 <vector251>:
.globl vector251
vector251:
  pushl $0
80107b60:	6a 00                	push   $0x0
  pushl $251
80107b62:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107b67:	e9 40 ef ff ff       	jmp    80106aac <alltraps>

80107b6c <vector252>:
.globl vector252
vector252:
  pushl $0
80107b6c:	6a 00                	push   $0x0
  pushl $252
80107b6e:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107b73:	e9 34 ef ff ff       	jmp    80106aac <alltraps>

80107b78 <vector253>:
.globl vector253
vector253:
  pushl $0
80107b78:	6a 00                	push   $0x0
  pushl $253
80107b7a:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107b7f:	e9 28 ef ff ff       	jmp    80106aac <alltraps>

80107b84 <vector254>:
.globl vector254
vector254:
  pushl $0
80107b84:	6a 00                	push   $0x0
  pushl $254
80107b86:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107b8b:	e9 1c ef ff ff       	jmp    80106aac <alltraps>

80107b90 <vector255>:
.globl vector255
vector255:
  pushl $0
80107b90:	6a 00                	push   $0x0
  pushl $255
80107b92:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107b97:	e9 10 ef ff ff       	jmp    80106aac <alltraps>

80107b9c <lgdt>:
{
80107b9c:	55                   	push   %ebp
80107b9d:	89 e5                	mov    %esp,%ebp
80107b9f:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107ba2:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ba5:	83 e8 01             	sub    $0x1,%eax
80107ba8:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107bac:	8b 45 08             	mov    0x8(%ebp),%eax
80107baf:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107bb3:	8b 45 08             	mov    0x8(%ebp),%eax
80107bb6:	c1 e8 10             	shr    $0x10,%eax
80107bb9:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107bbd:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107bc0:	0f 01 10             	lgdtl  (%eax)
}
80107bc3:	90                   	nop
80107bc4:	c9                   	leave  
80107bc5:	c3                   	ret    

80107bc6 <ltr>:
{
80107bc6:	55                   	push   %ebp
80107bc7:	89 e5                	mov    %esp,%ebp
80107bc9:	83 ec 04             	sub    $0x4,%esp
80107bcc:	8b 45 08             	mov    0x8(%ebp),%eax
80107bcf:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107bd3:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107bd7:	0f 00 d8             	ltr    %ax
}
80107bda:	90                   	nop
80107bdb:	c9                   	leave  
80107bdc:	c3                   	ret    

80107bdd <lcr3>:

static inline void
lcr3(uint val)
{
80107bdd:	55                   	push   %ebp
80107bde:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107be0:	8b 45 08             	mov    0x8(%ebp),%eax
80107be3:	0f 22 d8             	mov    %eax,%cr3
}
80107be6:	90                   	nop
80107be7:	5d                   	pop    %ebp
80107be8:	c3                   	ret    

80107be9 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107be9:	f3 0f 1e fb          	endbr32 
80107bed:	55                   	push   %ebp
80107bee:	89 e5                	mov    %esp,%ebp
80107bf0:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107bf3:	e8 7c c8 ff ff       	call   80104474 <cpuid>
80107bf8:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107bfe:	05 20 48 11 80       	add    $0x80114820,%eax
80107c03:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c09:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107c0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c12:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c1b:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107c1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c22:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c26:	83 e2 f0             	and    $0xfffffff0,%edx
80107c29:	83 ca 0a             	or     $0xa,%edx
80107c2c:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c32:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c36:	83 ca 10             	or     $0x10,%edx
80107c39:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c43:	83 e2 9f             	and    $0xffffff9f,%edx
80107c46:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c50:	83 ca 80             	or     $0xffffff80,%edx
80107c53:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c59:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c5d:	83 ca 0f             	or     $0xf,%edx
80107c60:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c66:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c6a:	83 e2 ef             	and    $0xffffffef,%edx
80107c6d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c73:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c77:	83 e2 df             	and    $0xffffffdf,%edx
80107c7a:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c80:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c84:	83 ca 40             	or     $0x40,%edx
80107c87:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c8d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c91:	83 ca 80             	or     $0xffffff80,%edx
80107c94:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9a:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca1:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107ca8:	ff ff 
80107caa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cad:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107cb4:	00 00 
80107cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb9:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc3:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107cca:	83 e2 f0             	and    $0xfffffff0,%edx
80107ccd:	83 ca 02             	or     $0x2,%edx
80107cd0:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd9:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107ce0:	83 ca 10             	or     $0x10,%edx
80107ce3:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cec:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107cf3:	83 e2 9f             	and    $0xffffff9f,%edx
80107cf6:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107cfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cff:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d06:	83 ca 80             	or     $0xffffff80,%edx
80107d09:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d12:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d19:	83 ca 0f             	or     $0xf,%edx
80107d1c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d25:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d2c:	83 e2 ef             	and    $0xffffffef,%edx
80107d2f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d38:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d3f:	83 e2 df             	and    $0xffffffdf,%edx
80107d42:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d52:	83 ca 40             	or     $0x40,%edx
80107d55:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d5e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d65:	83 ca 80             	or     $0xffffff80,%edx
80107d68:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d71:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d7b:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107d82:	ff ff 
80107d84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d87:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107d8e:	00 00 
80107d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d93:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107d9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9d:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107da4:	83 e2 f0             	and    $0xfffffff0,%edx
80107da7:	83 ca 0a             	or     $0xa,%edx
80107daa:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db3:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107dba:	83 ca 10             	or     $0x10,%edx
80107dbd:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107dc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc6:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107dcd:	83 ca 60             	or     $0x60,%edx
80107dd0:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107dd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd9:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107de0:	83 ca 80             	or     $0xffffff80,%edx
80107de3:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107de9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dec:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107df3:	83 ca 0f             	or     $0xf,%edx
80107df6:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dff:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e06:	83 e2 ef             	and    $0xffffffef,%edx
80107e09:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e12:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e19:	83 e2 df             	and    $0xffffffdf,%edx
80107e1c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e25:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e2c:	83 ca 40             	or     $0x40,%edx
80107e2f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e38:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e3f:	83 ca 80             	or     $0xffffff80,%edx
80107e42:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4b:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e55:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107e5c:	ff ff 
80107e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e61:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107e68:	00 00 
80107e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e6d:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e77:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107e7e:	83 e2 f0             	and    $0xfffffff0,%edx
80107e81:	83 ca 02             	or     $0x2,%edx
80107e84:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e8d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107e94:	83 ca 10             	or     $0x10,%edx
80107e97:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea0:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ea7:	83 ca 60             	or     $0x60,%edx
80107eaa:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb3:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107eba:	83 ca 80             	or     $0xffffff80,%edx
80107ebd:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ec3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec6:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ecd:	83 ca 0f             	or     $0xf,%edx
80107ed0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ee0:	83 e2 ef             	and    $0xffffffef,%edx
80107ee3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ee9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eec:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ef3:	83 e2 df             	and    $0xffffffdf,%edx
80107ef6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eff:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f06:	83 ca 40             	or     $0x40,%edx
80107f09:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f12:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f19:	83 ca 80             	or     $0xffffff80,%edx
80107f1c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f25:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107f2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f2f:	83 c0 70             	add    $0x70,%eax
80107f32:	83 ec 08             	sub    $0x8,%esp
80107f35:	6a 30                	push   $0x30
80107f37:	50                   	push   %eax
80107f38:	e8 5f fc ff ff       	call   80107b9c <lgdt>
80107f3d:	83 c4 10             	add    $0x10,%esp
}
80107f40:	90                   	nop
80107f41:	c9                   	leave  
80107f42:	c3                   	ret    

80107f43 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107f43:	f3 0f 1e fb          	endbr32 
80107f47:	55                   	push   %ebp
80107f48:	89 e5                	mov    %esp,%ebp
80107f4a:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107f4d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f50:	c1 e8 16             	shr    $0x16,%eax
80107f53:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f5a:	8b 45 08             	mov    0x8(%ebp),%eax
80107f5d:	01 d0                	add    %edx,%eax
80107f5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107f62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f65:	8b 00                	mov    (%eax),%eax
80107f67:	83 e0 01             	and    $0x1,%eax
80107f6a:	85 c0                	test   %eax,%eax
80107f6c:	74 14                	je     80107f82 <walkpgdir+0x3f>
    //if (!alloc)
      //cprintf("page directory is good\n");
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107f6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f71:	8b 00                	mov    (%eax),%eax
80107f73:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f78:	05 00 00 00 80       	add    $0x80000000,%eax
80107f7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f80:	eb 42                	jmp    80107fc4 <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107f82:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107f86:	74 0e                	je     80107f96 <walkpgdir+0x53>
80107f88:	e8 be ae ff ff       	call   80102e4b <kalloc>
80107f8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f90:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107f94:	75 07                	jne    80107f9d <walkpgdir+0x5a>
      return 0;
80107f96:	b8 00 00 00 00       	mov    $0x0,%eax
80107f9b:	eb 3e                	jmp    80107fdb <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107f9d:	83 ec 04             	sub    $0x4,%esp
80107fa0:	68 00 10 00 00       	push   $0x1000
80107fa5:	6a 00                	push   $0x0
80107fa7:	ff 75 f4             	pushl  -0xc(%ebp)
80107faa:	e8 9f d5 ff ff       	call   8010554e <memset>
80107faf:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107fb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fb5:	05 00 00 00 80       	add    $0x80000000,%eax
80107fba:	83 c8 07             	or     $0x7,%eax
80107fbd:	89 c2                	mov    %eax,%edx
80107fbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fc2:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107fc4:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fc7:	c1 e8 0c             	shr    $0xc,%eax
80107fca:	25 ff 03 00 00       	and    $0x3ff,%eax
80107fcf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd9:	01 d0                	add    %edx,%eax
}
80107fdb:	c9                   	leave  
80107fdc:	c3                   	ret    

80107fdd <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107fdd:	f3 0f 1e fb          	endbr32 
80107fe1:	55                   	push   %ebp
80107fe2:	89 e5                	mov    %esp,%ebp
80107fe4:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107fe7:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107ff2:	8b 55 0c             	mov    0xc(%ebp),%edx
80107ff5:	8b 45 10             	mov    0x10(%ebp),%eax
80107ff8:	01 d0                	add    %edx,%eax
80107ffa:	83 e8 01             	sub    $0x1,%eax
80107ffd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108002:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108005:	83 ec 04             	sub    $0x4,%esp
80108008:	6a 01                	push   $0x1
8010800a:	ff 75 f4             	pushl  -0xc(%ebp)
8010800d:	ff 75 08             	pushl  0x8(%ebp)
80108010:	e8 2e ff ff ff       	call   80107f43 <walkpgdir>
80108015:	83 c4 10             	add    $0x10,%esp
80108018:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010801b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010801f:	75 07                	jne    80108028 <mappages+0x4b>
      return -1;
80108021:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108026:	eb 6a                	jmp    80108092 <mappages+0xb5>
    if(*pte & (PTE_P | PTE_E))
80108028:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010802b:	8b 00                	mov    (%eax),%eax
8010802d:	25 01 04 00 00       	and    $0x401,%eax
80108032:	85 c0                	test   %eax,%eax
80108034:	74 0d                	je     80108043 <mappages+0x66>
      panic("p4Debug, remapping page");
80108036:	83 ec 0c             	sub    $0xc,%esp
80108039:	68 6c 98 10 80       	push   $0x8010986c
8010803e:	e8 c5 85 ff ff       	call   80100608 <panic>

    if (perm & PTE_E)
80108043:	8b 45 18             	mov    0x18(%ebp),%eax
80108046:	25 00 04 00 00       	and    $0x400,%eax
8010804b:	85 c0                	test   %eax,%eax
8010804d:	74 12                	je     80108061 <mappages+0x84>
      *pte = pa | perm | PTE_E;
8010804f:	8b 45 18             	mov    0x18(%ebp),%eax
80108052:	0b 45 14             	or     0x14(%ebp),%eax
80108055:	80 cc 04             	or     $0x4,%ah
80108058:	89 c2                	mov    %eax,%edx
8010805a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010805d:	89 10                	mov    %edx,(%eax)
8010805f:	eb 10                	jmp    80108071 <mappages+0x94>
    else
      *pte = pa | perm | PTE_P;
80108061:	8b 45 18             	mov    0x18(%ebp),%eax
80108064:	0b 45 14             	or     0x14(%ebp),%eax
80108067:	83 c8 01             	or     $0x1,%eax
8010806a:	89 c2                	mov    %eax,%edx
8010806c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010806f:	89 10                	mov    %edx,(%eax)


    if(a == last)
80108071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108074:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108077:	74 13                	je     8010808c <mappages+0xaf>
      break;
    a += PGSIZE;
80108079:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108080:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108087:	e9 79 ff ff ff       	jmp    80108005 <mappages+0x28>
      break;
8010808c:	90                   	nop
  }
  return 0;
8010808d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108092:	c9                   	leave  
80108093:	c3                   	ret    

80108094 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108094:	f3 0f 1e fb          	endbr32 
80108098:	55                   	push   %ebp
80108099:	89 e5                	mov    %esp,%ebp
8010809b:	53                   	push   %ebx
8010809c:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
8010809f:	e8 a7 ad ff ff       	call   80102e4b <kalloc>
801080a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801080a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801080ab:	75 07                	jne    801080b4 <setupkvm+0x20>
    return 0;
801080ad:	b8 00 00 00 00       	mov    $0x0,%eax
801080b2:	eb 78                	jmp    8010812c <setupkvm+0x98>
  memset(pgdir, 0, PGSIZE);
801080b4:	83 ec 04             	sub    $0x4,%esp
801080b7:	68 00 10 00 00       	push   $0x1000
801080bc:	6a 00                	push   $0x0
801080be:	ff 75 f0             	pushl  -0x10(%ebp)
801080c1:	e8 88 d4 ff ff       	call   8010554e <memset>
801080c6:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801080c9:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
801080d0:	eb 4e                	jmp    80108120 <setupkvm+0x8c>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801080d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080d5:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
801080d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080db:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801080de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e1:	8b 58 08             	mov    0x8(%eax),%ebx
801080e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e7:	8b 40 04             	mov    0x4(%eax),%eax
801080ea:	29 c3                	sub    %eax,%ebx
801080ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ef:	8b 00                	mov    (%eax),%eax
801080f1:	83 ec 0c             	sub    $0xc,%esp
801080f4:	51                   	push   %ecx
801080f5:	52                   	push   %edx
801080f6:	53                   	push   %ebx
801080f7:	50                   	push   %eax
801080f8:	ff 75 f0             	pushl  -0x10(%ebp)
801080fb:	e8 dd fe ff ff       	call   80107fdd <mappages>
80108100:	83 c4 20             	add    $0x20,%esp
80108103:	85 c0                	test   %eax,%eax
80108105:	79 15                	jns    8010811c <setupkvm+0x88>
      freevm(pgdir);
80108107:	83 ec 0c             	sub    $0xc,%esp
8010810a:	ff 75 f0             	pushl  -0x10(%ebp)
8010810d:	e8 13 05 00 00       	call   80108625 <freevm>
80108112:	83 c4 10             	add    $0x10,%esp
      return 0;
80108115:	b8 00 00 00 00       	mov    $0x0,%eax
8010811a:	eb 10                	jmp    8010812c <setupkvm+0x98>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010811c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108120:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
80108127:	72 a9                	jb     801080d2 <setupkvm+0x3e>
    }
  return pgdir;
80108129:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010812c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010812f:	c9                   	leave  
80108130:	c3                   	ret    

80108131 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108131:	f3 0f 1e fb          	endbr32 
80108135:	55                   	push   %ebp
80108136:	89 e5                	mov    %esp,%ebp
80108138:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010813b:	e8 54 ff ff ff       	call   80108094 <setupkvm>
80108140:	a3 44 7f 11 80       	mov    %eax,0x80117f44
  switchkvm();
80108145:	e8 03 00 00 00       	call   8010814d <switchkvm>
}
8010814a:	90                   	nop
8010814b:	c9                   	leave  
8010814c:	c3                   	ret    

8010814d <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010814d:	f3 0f 1e fb          	endbr32 
80108151:	55                   	push   %ebp
80108152:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80108154:	a1 44 7f 11 80       	mov    0x80117f44,%eax
80108159:	05 00 00 00 80       	add    $0x80000000,%eax
8010815e:	50                   	push   %eax
8010815f:	e8 79 fa ff ff       	call   80107bdd <lcr3>
80108164:	83 c4 04             	add    $0x4,%esp
}
80108167:	90                   	nop
80108168:	c9                   	leave  
80108169:	c3                   	ret    

8010816a <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
8010816a:	f3 0f 1e fb          	endbr32 
8010816e:	55                   	push   %ebp
8010816f:	89 e5                	mov    %esp,%ebp
80108171:	56                   	push   %esi
80108172:	53                   	push   %ebx
80108173:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80108176:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010817a:	75 0d                	jne    80108189 <switchuvm+0x1f>
    panic("switchuvm: no process");
8010817c:	83 ec 0c             	sub    $0xc,%esp
8010817f:	68 84 98 10 80       	push   $0x80109884
80108184:	e8 7f 84 ff ff       	call   80100608 <panic>
  if(p->kstack == 0)
80108189:	8b 45 08             	mov    0x8(%ebp),%eax
8010818c:	8b 40 08             	mov    0x8(%eax),%eax
8010818f:	85 c0                	test   %eax,%eax
80108191:	75 0d                	jne    801081a0 <switchuvm+0x36>
    panic("switchuvm: no kstack");
80108193:	83 ec 0c             	sub    $0xc,%esp
80108196:	68 9a 98 10 80       	push   $0x8010989a
8010819b:	e8 68 84 ff ff       	call   80100608 <panic>
  if(p->pgdir == 0)
801081a0:	8b 45 08             	mov    0x8(%ebp),%eax
801081a3:	8b 40 04             	mov    0x4(%eax),%eax
801081a6:	85 c0                	test   %eax,%eax
801081a8:	75 0d                	jne    801081b7 <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
801081aa:	83 ec 0c             	sub    $0xc,%esp
801081ad:	68 af 98 10 80       	push   $0x801098af
801081b2:	e8 51 84 ff ff       	call   80100608 <panic>

  pushcli();
801081b7:	e8 7f d2 ff ff       	call   8010543b <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801081bc:	e8 d2 c2 ff ff       	call   80104493 <mycpu>
801081c1:	89 c3                	mov    %eax,%ebx
801081c3:	e8 cb c2 ff ff       	call   80104493 <mycpu>
801081c8:	83 c0 08             	add    $0x8,%eax
801081cb:	89 c6                	mov    %eax,%esi
801081cd:	e8 c1 c2 ff ff       	call   80104493 <mycpu>
801081d2:	83 c0 08             	add    $0x8,%eax
801081d5:	c1 e8 10             	shr    $0x10,%eax
801081d8:	88 45 f7             	mov    %al,-0x9(%ebp)
801081db:	e8 b3 c2 ff ff       	call   80104493 <mycpu>
801081e0:	83 c0 08             	add    $0x8,%eax
801081e3:	c1 e8 18             	shr    $0x18,%eax
801081e6:	89 c2                	mov    %eax,%edx
801081e8:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801081ef:	67 00 
801081f1:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
801081f8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
801081fc:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80108202:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108209:	83 e0 f0             	and    $0xfffffff0,%eax
8010820c:	83 c8 09             	or     $0x9,%eax
8010820f:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108215:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010821c:	83 c8 10             	or     $0x10,%eax
8010821f:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108225:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010822c:	83 e0 9f             	and    $0xffffff9f,%eax
8010822f:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108235:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010823c:	83 c8 80             	or     $0xffffff80,%eax
8010823f:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108245:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010824c:	83 e0 f0             	and    $0xfffffff0,%eax
8010824f:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108255:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010825c:	83 e0 ef             	and    $0xffffffef,%eax
8010825f:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108265:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010826c:	83 e0 df             	and    $0xffffffdf,%eax
8010826f:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108275:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010827c:	83 c8 40             	or     $0x40,%eax
8010827f:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108285:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010828c:	83 e0 7f             	and    $0x7f,%eax
8010828f:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108295:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
8010829b:	e8 f3 c1 ff ff       	call   80104493 <mycpu>
801082a0:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801082a7:	83 e2 ef             	and    $0xffffffef,%edx
801082aa:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801082b0:	e8 de c1 ff ff       	call   80104493 <mycpu>
801082b5:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801082bb:	8b 45 08             	mov    0x8(%ebp),%eax
801082be:	8b 40 08             	mov    0x8(%eax),%eax
801082c1:	89 c3                	mov    %eax,%ebx
801082c3:	e8 cb c1 ff ff       	call   80104493 <mycpu>
801082c8:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
801082ce:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801082d1:	e8 bd c1 ff ff       	call   80104493 <mycpu>
801082d6:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
801082dc:	83 ec 0c             	sub    $0xc,%esp
801082df:	6a 28                	push   $0x28
801082e1:	e8 e0 f8 ff ff       	call   80107bc6 <ltr>
801082e6:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
801082e9:	8b 45 08             	mov    0x8(%ebp),%eax
801082ec:	8b 40 04             	mov    0x4(%eax),%eax
801082ef:	05 00 00 00 80       	add    $0x80000000,%eax
801082f4:	83 ec 0c             	sub    $0xc,%esp
801082f7:	50                   	push   %eax
801082f8:	e8 e0 f8 ff ff       	call   80107bdd <lcr3>
801082fd:	83 c4 10             	add    $0x10,%esp
  popcli();
80108300:	e8 87 d1 ff ff       	call   8010548c <popcli>
}
80108305:	90                   	nop
80108306:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108309:	5b                   	pop    %ebx
8010830a:	5e                   	pop    %esi
8010830b:	5d                   	pop    %ebp
8010830c:	c3                   	ret    

8010830d <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010830d:	f3 0f 1e fb          	endbr32 
80108311:	55                   	push   %ebp
80108312:	89 e5                	mov    %esp,%ebp
80108314:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80108317:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
8010831e:	76 0d                	jbe    8010832d <inituvm+0x20>
    panic("inituvm: more than a page");
80108320:	83 ec 0c             	sub    $0xc,%esp
80108323:	68 c3 98 10 80       	push   $0x801098c3
80108328:	e8 db 82 ff ff       	call   80100608 <panic>
  mem = kalloc();
8010832d:	e8 19 ab ff ff       	call   80102e4b <kalloc>
80108332:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108335:	83 ec 04             	sub    $0x4,%esp
80108338:	68 00 10 00 00       	push   $0x1000
8010833d:	6a 00                	push   $0x0
8010833f:	ff 75 f4             	pushl  -0xc(%ebp)
80108342:	e8 07 d2 ff ff       	call   8010554e <memset>
80108347:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
8010834a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010834d:	05 00 00 00 80       	add    $0x80000000,%eax
80108352:	83 ec 0c             	sub    $0xc,%esp
80108355:	6a 06                	push   $0x6
80108357:	50                   	push   %eax
80108358:	68 00 10 00 00       	push   $0x1000
8010835d:	6a 00                	push   $0x0
8010835f:	ff 75 08             	pushl  0x8(%ebp)
80108362:	e8 76 fc ff ff       	call   80107fdd <mappages>
80108367:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
8010836a:	83 ec 04             	sub    $0x4,%esp
8010836d:	ff 75 10             	pushl  0x10(%ebp)
80108370:	ff 75 0c             	pushl  0xc(%ebp)
80108373:	ff 75 f4             	pushl  -0xc(%ebp)
80108376:	e8 9a d2 ff ff       	call   80105615 <memmove>
8010837b:	83 c4 10             	add    $0x10,%esp
}
8010837e:	90                   	nop
8010837f:	c9                   	leave  
80108380:	c3                   	ret    

80108381 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108381:	f3 0f 1e fb          	endbr32 
80108385:	55                   	push   %ebp
80108386:	89 e5                	mov    %esp,%ebp
80108388:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010838b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010838e:	25 ff 0f 00 00       	and    $0xfff,%eax
80108393:	85 c0                	test   %eax,%eax
80108395:	74 0d                	je     801083a4 <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
80108397:	83 ec 0c             	sub    $0xc,%esp
8010839a:	68 e0 98 10 80       	push   $0x801098e0
8010839f:	e8 64 82 ff ff       	call   80100608 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801083a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083ab:	e9 8f 00 00 00       	jmp    8010843f <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801083b0:	8b 55 0c             	mov    0xc(%ebp),%edx
801083b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b6:	01 d0                	add    %edx,%eax
801083b8:	83 ec 04             	sub    $0x4,%esp
801083bb:	6a 00                	push   $0x0
801083bd:	50                   	push   %eax
801083be:	ff 75 08             	pushl  0x8(%ebp)
801083c1:	e8 7d fb ff ff       	call   80107f43 <walkpgdir>
801083c6:	83 c4 10             	add    $0x10,%esp
801083c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
801083cc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801083d0:	75 0d                	jne    801083df <loaduvm+0x5e>
      panic("loaduvm: address should exist");
801083d2:	83 ec 0c             	sub    $0xc,%esp
801083d5:	68 03 99 10 80       	push   $0x80109903
801083da:	e8 29 82 ff ff       	call   80100608 <panic>
    pa = PTE_ADDR(*pte);
801083df:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083e2:	8b 00                	mov    (%eax),%eax
801083e4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083e9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801083ec:	8b 45 18             	mov    0x18(%ebp),%eax
801083ef:	2b 45 f4             	sub    -0xc(%ebp),%eax
801083f2:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801083f7:	77 0b                	ja     80108404 <loaduvm+0x83>
      n = sz - i;
801083f9:	8b 45 18             	mov    0x18(%ebp),%eax
801083fc:	2b 45 f4             	sub    -0xc(%ebp),%eax
801083ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108402:	eb 07                	jmp    8010840b <loaduvm+0x8a>
    else
      n = PGSIZE;
80108404:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010840b:	8b 55 14             	mov    0x14(%ebp),%edx
8010840e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108411:	01 d0                	add    %edx,%eax
80108413:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108416:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010841c:	ff 75 f0             	pushl  -0x10(%ebp)
8010841f:	50                   	push   %eax
80108420:	52                   	push   %edx
80108421:	ff 75 10             	pushl  0x10(%ebp)
80108424:	e8 3a 9c ff ff       	call   80102063 <readi>
80108429:	83 c4 10             	add    $0x10,%esp
8010842c:	39 45 f0             	cmp    %eax,-0x10(%ebp)
8010842f:	74 07                	je     80108438 <loaduvm+0xb7>
      return -1;
80108431:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108436:	eb 18                	jmp    80108450 <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
80108438:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010843f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108442:	3b 45 18             	cmp    0x18(%ebp),%eax
80108445:	0f 82 65 ff ff ff    	jb     801083b0 <loaduvm+0x2f>
  }
  return 0;
8010844b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108450:	c9                   	leave  
80108451:	c3                   	ret    

80108452 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108452:	f3 0f 1e fb          	endbr32 
80108456:	55                   	push   %ebp
80108457:	89 e5                	mov    %esp,%ebp
80108459:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010845c:	8b 45 10             	mov    0x10(%ebp),%eax
8010845f:	85 c0                	test   %eax,%eax
80108461:	79 0a                	jns    8010846d <allocuvm+0x1b>
    return 0;
80108463:	b8 00 00 00 00       	mov    $0x0,%eax
80108468:	e9 ec 00 00 00       	jmp    80108559 <allocuvm+0x107>
  if(newsz < oldsz)
8010846d:	8b 45 10             	mov    0x10(%ebp),%eax
80108470:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108473:	73 08                	jae    8010847d <allocuvm+0x2b>
    return oldsz;
80108475:	8b 45 0c             	mov    0xc(%ebp),%eax
80108478:	e9 dc 00 00 00       	jmp    80108559 <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
8010847d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108480:	05 ff 0f 00 00       	add    $0xfff,%eax
80108485:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010848a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010848d:	e9 b8 00 00 00       	jmp    8010854a <allocuvm+0xf8>
    mem = kalloc();
80108492:	e8 b4 a9 ff ff       	call   80102e4b <kalloc>
80108497:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010849a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010849e:	75 2e                	jne    801084ce <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
801084a0:	83 ec 0c             	sub    $0xc,%esp
801084a3:	68 21 99 10 80       	push   $0x80109921
801084a8:	e8 6b 7f ff ff       	call   80100418 <cprintf>
801084ad:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801084b0:	83 ec 04             	sub    $0x4,%esp
801084b3:	ff 75 0c             	pushl  0xc(%ebp)
801084b6:	ff 75 10             	pushl  0x10(%ebp)
801084b9:	ff 75 08             	pushl  0x8(%ebp)
801084bc:	e8 9a 00 00 00       	call   8010855b <deallocuvm>
801084c1:	83 c4 10             	add    $0x10,%esp
      return 0;
801084c4:	b8 00 00 00 00       	mov    $0x0,%eax
801084c9:	e9 8b 00 00 00       	jmp    80108559 <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
801084ce:	83 ec 04             	sub    $0x4,%esp
801084d1:	68 00 10 00 00       	push   $0x1000
801084d6:	6a 00                	push   $0x0
801084d8:	ff 75 f0             	pushl  -0x10(%ebp)
801084db:	e8 6e d0 ff ff       	call   8010554e <memset>
801084e0:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801084e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084e6:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801084ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ef:	83 ec 0c             	sub    $0xc,%esp
801084f2:	6a 06                	push   $0x6
801084f4:	52                   	push   %edx
801084f5:	68 00 10 00 00       	push   $0x1000
801084fa:	50                   	push   %eax
801084fb:	ff 75 08             	pushl  0x8(%ebp)
801084fe:	e8 da fa ff ff       	call   80107fdd <mappages>
80108503:	83 c4 20             	add    $0x20,%esp
80108506:	85 c0                	test   %eax,%eax
80108508:	79 39                	jns    80108543 <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
8010850a:	83 ec 0c             	sub    $0xc,%esp
8010850d:	68 39 99 10 80       	push   $0x80109939
80108512:	e8 01 7f ff ff       	call   80100418 <cprintf>
80108517:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010851a:	83 ec 04             	sub    $0x4,%esp
8010851d:	ff 75 0c             	pushl  0xc(%ebp)
80108520:	ff 75 10             	pushl  0x10(%ebp)
80108523:	ff 75 08             	pushl  0x8(%ebp)
80108526:	e8 30 00 00 00       	call   8010855b <deallocuvm>
8010852b:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
8010852e:	83 ec 0c             	sub    $0xc,%esp
80108531:	ff 75 f0             	pushl  -0x10(%ebp)
80108534:	e8 74 a8 ff ff       	call   80102dad <kfree>
80108539:	83 c4 10             	add    $0x10,%esp
      return 0;
8010853c:	b8 00 00 00 00       	mov    $0x0,%eax
80108541:	eb 16                	jmp    80108559 <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
80108543:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010854a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010854d:	3b 45 10             	cmp    0x10(%ebp),%eax
80108550:	0f 82 3c ff ff ff    	jb     80108492 <allocuvm+0x40>
    }
  }
  return newsz;
80108556:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108559:	c9                   	leave  
8010855a:	c3                   	ret    

8010855b <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010855b:	f3 0f 1e fb          	endbr32 
8010855f:	55                   	push   %ebp
80108560:	89 e5                	mov    %esp,%ebp
80108562:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108565:	8b 45 10             	mov    0x10(%ebp),%eax
80108568:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010856b:	72 08                	jb     80108575 <deallocuvm+0x1a>
    return oldsz;
8010856d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108570:	e9 ae 00 00 00       	jmp    80108623 <deallocuvm+0xc8>

  a = PGROUNDUP(newsz);
80108575:	8b 45 10             	mov    0x10(%ebp),%eax
80108578:	05 ff 0f 00 00       	add    $0xfff,%eax
8010857d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108582:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108585:	e9 8a 00 00 00       	jmp    80108614 <deallocuvm+0xb9>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010858a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010858d:	83 ec 04             	sub    $0x4,%esp
80108590:	6a 00                	push   $0x0
80108592:	50                   	push   %eax
80108593:	ff 75 08             	pushl  0x8(%ebp)
80108596:	e8 a8 f9 ff ff       	call   80107f43 <walkpgdir>
8010859b:	83 c4 10             	add    $0x10,%esp
8010859e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801085a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801085a5:	75 16                	jne    801085bd <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801085a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085aa:	c1 e8 16             	shr    $0x16,%eax
801085ad:	83 c0 01             	add    $0x1,%eax
801085b0:	c1 e0 16             	shl    $0x16,%eax
801085b3:	2d 00 10 00 00       	sub    $0x1000,%eax
801085b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801085bb:	eb 50                	jmp    8010860d <deallocuvm+0xb2>
    else if((*pte & (PTE_P | PTE_E)) != 0){
801085bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085c0:	8b 00                	mov    (%eax),%eax
801085c2:	25 01 04 00 00       	and    $0x401,%eax
801085c7:	85 c0                	test   %eax,%eax
801085c9:	74 42                	je     8010860d <deallocuvm+0xb2>
      pa = PTE_ADDR(*pte);
801085cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085ce:	8b 00                	mov    (%eax),%eax
801085d0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801085d8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801085dc:	75 0d                	jne    801085eb <deallocuvm+0x90>
        panic("kfree");
801085de:	83 ec 0c             	sub    $0xc,%esp
801085e1:	68 55 99 10 80       	push   $0x80109955
801085e6:	e8 1d 80 ff ff       	call   80100608 <panic>
      char *v = P2V(pa);
801085eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085ee:	05 00 00 00 80       	add    $0x80000000,%eax
801085f3:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801085f6:	83 ec 0c             	sub    $0xc,%esp
801085f9:	ff 75 e8             	pushl  -0x18(%ebp)
801085fc:	e8 ac a7 ff ff       	call   80102dad <kfree>
80108601:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108604:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108607:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
8010860d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108614:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108617:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010861a:	0f 82 6a ff ff ff    	jb     8010858a <deallocuvm+0x2f>
    }
  }
  return newsz;
80108620:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108623:	c9                   	leave  
80108624:	c3                   	ret    

80108625 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108625:	f3 0f 1e fb          	endbr32 
80108629:	55                   	push   %ebp
8010862a:	89 e5                	mov    %esp,%ebp
8010862c:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
8010862f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108633:	75 0d                	jne    80108642 <freevm+0x1d>
    panic("freevm: no pgdir");
80108635:	83 ec 0c             	sub    $0xc,%esp
80108638:	68 5b 99 10 80       	push   $0x8010995b
8010863d:	e8 c6 7f ff ff       	call   80100608 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108642:	83 ec 04             	sub    $0x4,%esp
80108645:	6a 00                	push   $0x0
80108647:	68 00 00 00 80       	push   $0x80000000
8010864c:	ff 75 08             	pushl  0x8(%ebp)
8010864f:	e8 07 ff ff ff       	call   8010855b <deallocuvm>
80108654:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108657:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010865e:	eb 4a                	jmp    801086aa <freevm+0x85>
    if(pgdir[i] & (PTE_P | PTE_E)){
80108660:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108663:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010866a:	8b 45 08             	mov    0x8(%ebp),%eax
8010866d:	01 d0                	add    %edx,%eax
8010866f:	8b 00                	mov    (%eax),%eax
80108671:	25 01 04 00 00       	and    $0x401,%eax
80108676:	85 c0                	test   %eax,%eax
80108678:	74 2c                	je     801086a6 <freevm+0x81>
      char * v = P2V(PTE_ADDR(pgdir[i]));
8010867a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010867d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108684:	8b 45 08             	mov    0x8(%ebp),%eax
80108687:	01 d0                	add    %edx,%eax
80108689:	8b 00                	mov    (%eax),%eax
8010868b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108690:	05 00 00 00 80       	add    $0x80000000,%eax
80108695:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108698:	83 ec 0c             	sub    $0xc,%esp
8010869b:	ff 75 f0             	pushl  -0x10(%ebp)
8010869e:	e8 0a a7 ff ff       	call   80102dad <kfree>
801086a3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801086a6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801086aa:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801086b1:	76 ad                	jbe    80108660 <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
801086b3:	83 ec 0c             	sub    $0xc,%esp
801086b6:	ff 75 08             	pushl  0x8(%ebp)
801086b9:	e8 ef a6 ff ff       	call   80102dad <kfree>
801086be:	83 c4 10             	add    $0x10,%esp
}
801086c1:	90                   	nop
801086c2:	c9                   	leave  
801086c3:	c3                   	ret    

801086c4 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801086c4:	f3 0f 1e fb          	endbr32 
801086c8:	55                   	push   %ebp
801086c9:	89 e5                	mov    %esp,%ebp
801086cb:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801086ce:	83 ec 04             	sub    $0x4,%esp
801086d1:	6a 00                	push   $0x0
801086d3:	ff 75 0c             	pushl  0xc(%ebp)
801086d6:	ff 75 08             	pushl  0x8(%ebp)
801086d9:	e8 65 f8 ff ff       	call   80107f43 <walkpgdir>
801086de:	83 c4 10             	add    $0x10,%esp
801086e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801086e4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801086e8:	75 0d                	jne    801086f7 <clearpteu+0x33>
    panic("clearpteu");
801086ea:	83 ec 0c             	sub    $0xc,%esp
801086ed:	68 6c 99 10 80       	push   $0x8010996c
801086f2:	e8 11 7f ff ff       	call   80100608 <panic>
  *pte &= ~PTE_U;
801086f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086fa:	8b 00                	mov    (%eax),%eax
801086fc:	83 e0 fb             	and    $0xfffffffb,%eax
801086ff:	89 c2                	mov    %eax,%edx
80108701:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108704:	89 10                	mov    %edx,(%eax)
}
80108706:	90                   	nop
80108707:	c9                   	leave  
80108708:	c3                   	ret    

80108709 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108709:	f3 0f 1e fb          	endbr32 
8010870d:	55                   	push   %ebp
8010870e:	89 e5                	mov    %esp,%ebp
80108710:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108713:	e8 7c f9 ff ff       	call   80108094 <setupkvm>
80108718:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010871b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010871f:	75 0a                	jne    8010872b <copyuvm+0x22>
    return 0;
80108721:	b8 00 00 00 00       	mov    $0x0,%eax
80108726:	e9 fa 00 00 00       	jmp    80108825 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
8010872b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108732:	e9 c9 00 00 00       	jmp    80108800 <copyuvm+0xf7>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108737:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010873a:	83 ec 04             	sub    $0x4,%esp
8010873d:	6a 00                	push   $0x0
8010873f:	50                   	push   %eax
80108740:	ff 75 08             	pushl  0x8(%ebp)
80108743:	e8 fb f7 ff ff       	call   80107f43 <walkpgdir>
80108748:	83 c4 10             	add    $0x10,%esp
8010874b:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010874e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108752:	75 0d                	jne    80108761 <copyuvm+0x58>
      panic("p4Debug: inside copyuvm, pte should exist");
80108754:	83 ec 0c             	sub    $0xc,%esp
80108757:	68 78 99 10 80       	push   $0x80109978
8010875c:	e8 a7 7e ff ff       	call   80100608 <panic>
    if(!(*pte & (PTE_P | PTE_E)))
80108761:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108764:	8b 00                	mov    (%eax),%eax
80108766:	25 01 04 00 00       	and    $0x401,%eax
8010876b:	85 c0                	test   %eax,%eax
8010876d:	75 0d                	jne    8010877c <copyuvm+0x73>
      panic("p4Debug: inside copyuvm, page not present");
8010876f:	83 ec 0c             	sub    $0xc,%esp
80108772:	68 a4 99 10 80       	push   $0x801099a4
80108777:	e8 8c 7e ff ff       	call   80100608 <panic>
    pa = PTE_ADDR(*pte);
8010877c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010877f:	8b 00                	mov    (%eax),%eax
80108781:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108786:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108789:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010878c:	8b 00                	mov    (%eax),%eax
8010878e:	25 ff 0f 00 00       	and    $0xfff,%eax
80108793:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108796:	e8 b0 a6 ff ff       	call   80102e4b <kalloc>
8010879b:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010879e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801087a2:	74 6d                	je     80108811 <copyuvm+0x108>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801087a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801087a7:	05 00 00 00 80       	add    $0x80000000,%eax
801087ac:	83 ec 04             	sub    $0x4,%esp
801087af:	68 00 10 00 00       	push   $0x1000
801087b4:	50                   	push   %eax
801087b5:	ff 75 e0             	pushl  -0x20(%ebp)
801087b8:	e8 58 ce ff ff       	call   80105615 <memmove>
801087bd:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
801087c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801087c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087c6:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801087cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087cf:	83 ec 0c             	sub    $0xc,%esp
801087d2:	52                   	push   %edx
801087d3:	51                   	push   %ecx
801087d4:	68 00 10 00 00       	push   $0x1000
801087d9:	50                   	push   %eax
801087da:	ff 75 f0             	pushl  -0x10(%ebp)
801087dd:	e8 fb f7 ff ff       	call   80107fdd <mappages>
801087e2:	83 c4 20             	add    $0x20,%esp
801087e5:	85 c0                	test   %eax,%eax
801087e7:	79 10                	jns    801087f9 <copyuvm+0xf0>
      kfree(mem);
801087e9:	83 ec 0c             	sub    $0xc,%esp
801087ec:	ff 75 e0             	pushl  -0x20(%ebp)
801087ef:	e8 b9 a5 ff ff       	call   80102dad <kfree>
801087f4:	83 c4 10             	add    $0x10,%esp
      goto bad;
801087f7:	eb 19                	jmp    80108812 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
801087f9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108803:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108806:	0f 82 2b ff ff ff    	jb     80108737 <copyuvm+0x2e>
    }
  }
  return d;
8010880c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010880f:	eb 14                	jmp    80108825 <copyuvm+0x11c>
      goto bad;
80108811:	90                   	nop

bad:
  freevm(d);
80108812:	83 ec 0c             	sub    $0xc,%esp
80108815:	ff 75 f0             	pushl  -0x10(%ebp)
80108818:	e8 08 fe ff ff       	call   80108625 <freevm>
8010881d:	83 c4 10             	add    $0x10,%esp
  return 0;
80108820:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108825:	c9                   	leave  
80108826:	c3                   	ret    

80108827 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108827:	f3 0f 1e fb          	endbr32 
8010882b:	55                   	push   %ebp
8010882c:	89 e5                	mov    %esp,%ebp
8010882e:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108831:	83 ec 04             	sub    $0x4,%esp
80108834:	6a 00                	push   $0x0
80108836:	ff 75 0c             	pushl  0xc(%ebp)
80108839:	ff 75 08             	pushl  0x8(%ebp)
8010883c:	e8 02 f7 ff ff       	call   80107f43 <walkpgdir>
80108841:	83 c4 10             	add    $0x10,%esp
80108844:	89 45 f4             	mov    %eax,-0xc(%ebp)
  // p4Debug: Check for page's present and encrypted flags.
  if(((*pte & PTE_P) | (*pte & PTE_E)) == 0)
80108847:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010884a:	8b 00                	mov    (%eax),%eax
8010884c:	25 01 04 00 00       	and    $0x401,%eax
80108851:	85 c0                	test   %eax,%eax
80108853:	75 07                	jne    8010885c <uva2ka+0x35>
    return 0;
80108855:	b8 00 00 00 00       	mov    $0x0,%eax
8010885a:	eb 22                	jmp    8010887e <uva2ka+0x57>
  if((*pte & PTE_U) == 0)
8010885c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010885f:	8b 00                	mov    (%eax),%eax
80108861:	83 e0 04             	and    $0x4,%eax
80108864:	85 c0                	test   %eax,%eax
80108866:	75 07                	jne    8010886f <uva2ka+0x48>
    return 0;
80108868:	b8 00 00 00 00       	mov    $0x0,%eax
8010886d:	eb 0f                	jmp    8010887e <uva2ka+0x57>
  return (char*)P2V(PTE_ADDR(*pte));
8010886f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108872:	8b 00                	mov    (%eax),%eax
80108874:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108879:	05 00 00 00 80       	add    $0x80000000,%eax
}
8010887e:	c9                   	leave  
8010887f:	c3                   	ret    

80108880 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108880:	f3 0f 1e fb          	endbr32 
80108884:	55                   	push   %ebp
80108885:	89 e5                	mov    %esp,%ebp
80108887:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010888a:	8b 45 10             	mov    0x10(%ebp),%eax
8010888d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108890:	eb 7f                	jmp    80108911 <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
80108892:	8b 45 0c             	mov    0xc(%ebp),%eax
80108895:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010889a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010889d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088a0:	83 ec 08             	sub    $0x8,%esp
801088a3:	50                   	push   %eax
801088a4:	ff 75 08             	pushl  0x8(%ebp)
801088a7:	e8 7b ff ff ff       	call   80108827 <uva2ka>
801088ac:	83 c4 10             	add    $0x10,%esp
801088af:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801088b2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801088b6:	75 07                	jne    801088bf <copyout+0x3f>
    {
      //p4Debug : Cannot find page in kernel space.
      return -1;
801088b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801088bd:	eb 61                	jmp    80108920 <copyout+0xa0>
    }
    n = PGSIZE - (va - va0);
801088bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088c2:	2b 45 0c             	sub    0xc(%ebp),%eax
801088c5:	05 00 10 00 00       	add    $0x1000,%eax
801088ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801088cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088d0:	3b 45 14             	cmp    0x14(%ebp),%eax
801088d3:	76 06                	jbe    801088db <copyout+0x5b>
      n = len;
801088d5:	8b 45 14             	mov    0x14(%ebp),%eax
801088d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801088db:	8b 45 0c             	mov    0xc(%ebp),%eax
801088de:	2b 45 ec             	sub    -0x14(%ebp),%eax
801088e1:	89 c2                	mov    %eax,%edx
801088e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801088e6:	01 d0                	add    %edx,%eax
801088e8:	83 ec 04             	sub    $0x4,%esp
801088eb:	ff 75 f0             	pushl  -0x10(%ebp)
801088ee:	ff 75 f4             	pushl  -0xc(%ebp)
801088f1:	50                   	push   %eax
801088f2:	e8 1e cd ff ff       	call   80105615 <memmove>
801088f7:	83 c4 10             	add    $0x10,%esp
    len -= n;
801088fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088fd:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108900:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108903:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108906:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108909:	05 00 10 00 00       	add    $0x1000,%eax
8010890e:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108911:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108915:	0f 85 77 ff ff ff    	jne    80108892 <copyout+0x12>
  }
  return 0;
8010891b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108920:	c9                   	leave  
80108921:	c3                   	ret    

80108922 <translate_and_set>:

//This function is just like uva2ka but sets the PTE_E bit and clears PTE_P
char* translate_and_set(pde_t *pgdir, char *uva) {
80108922:	f3 0f 1e fb          	endbr32 
80108926:	55                   	push   %ebp
80108927:	89 e5                	mov    %esp,%ebp
80108929:	83 ec 18             	sub    $0x18,%esp
  cprintf("p4Debug: setting PTE_E for %p, VPN %d\n", uva, PPN(uva));
8010892c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010892f:	c1 e8 0c             	shr    $0xc,%eax
80108932:	83 ec 04             	sub    $0x4,%esp
80108935:	50                   	push   %eax
80108936:	ff 75 0c             	pushl  0xc(%ebp)
80108939:	68 d0 99 10 80       	push   $0x801099d0
8010893e:	e8 d5 7a ff ff       	call   80100418 <cprintf>
80108943:	83 c4 10             	add    $0x10,%esp
  pte_t *pte;
  pte = walkpgdir(pgdir, uva, 0);
80108946:	83 ec 04             	sub    $0x4,%esp
80108949:	6a 00                	push   $0x0
8010894b:	ff 75 0c             	pushl  0xc(%ebp)
8010894e:	ff 75 08             	pushl  0x8(%ebp)
80108951:	e8 ed f5 ff ff       	call   80107f43 <walkpgdir>
80108956:	83 c4 10             	add    $0x10,%esp
80108959:	89 45 f4             	mov    %eax,-0xc(%ebp)

  //p4Debug: If page is not present AND it is not encrypted.
  if((*pte & PTE_P) == 0 && (*pte & PTE_E) == 0)
8010895c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010895f:	8b 00                	mov    (%eax),%eax
80108961:	83 e0 01             	and    $0x1,%eax
80108964:	85 c0                	test   %eax,%eax
80108966:	75 18                	jne    80108980 <translate_and_set+0x5e>
80108968:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010896b:	8b 00                	mov    (%eax),%eax
8010896d:	25 00 04 00 00       	and    $0x400,%eax
80108972:	85 c0                	test   %eax,%eax
80108974:	75 0a                	jne    80108980 <translate_and_set+0x5e>
    return 0;
80108976:	b8 00 00 00 00       	mov    $0x0,%eax
8010897b:	e9 84 00 00 00       	jmp    80108a04 <translate_and_set+0xe2>
  //p4Debug: If page is already encrypted, i.e. PTE_E is set, return NULL as error;
  if((*pte & PTE_E)) {
80108980:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108983:	8b 00                	mov    (%eax),%eax
80108985:	25 00 04 00 00       	and    $0x400,%eax
8010898a:	85 c0                	test   %eax,%eax
8010898c:	74 07                	je     80108995 <translate_and_set+0x73>
    return 0;
8010898e:	b8 00 00 00 00       	mov    $0x0,%eax
80108993:	eb 6f                	jmp    80108a04 <translate_and_set+0xe2>
  }
  // p4Debug: Check if users are allowed to use this page
  if((*pte & PTE_U) == 0)
80108995:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108998:	8b 00                	mov    (%eax),%eax
8010899a:	83 e0 04             	and    $0x4,%eax
8010899d:	85 c0                	test   %eax,%eax
8010899f:	75 07                	jne    801089a8 <translate_and_set+0x86>
    return 0;
801089a1:	b8 00 00 00 00       	mov    $0x0,%eax
801089a6:	eb 5c                	jmp    80108a04 <translate_and_set+0xe2>
  //p4Debug: Set Page as encrypted and not present so that we can trap(see trap.c) to decrypt page
  cprintf("p4Debug: PTE was %x and its pointer %p\n", *pte, pte);
801089a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ab:	8b 00                	mov    (%eax),%eax
801089ad:	83 ec 04             	sub    $0x4,%esp
801089b0:	ff 75 f4             	pushl  -0xc(%ebp)
801089b3:	50                   	push   %eax
801089b4:	68 f8 99 10 80       	push   $0x801099f8
801089b9:	e8 5a 7a ff ff       	call   80100418 <cprintf>
801089be:	83 c4 10             	add    $0x10,%esp
  *pte = *pte | PTE_E;
801089c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c4:	8b 00                	mov    (%eax),%eax
801089c6:	80 cc 04             	or     $0x4,%ah
801089c9:	89 c2                	mov    %eax,%edx
801089cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ce:	89 10                	mov    %edx,(%eax)
  *pte = *pte & ~PTE_P;
801089d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089d3:	8b 00                	mov    (%eax),%eax
801089d5:	83 e0 fe             	and    $0xfffffffe,%eax
801089d8:	89 c2                	mov    %eax,%edx
801089da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089dd:	89 10                	mov    %edx,(%eax)
  cprintf("p4Debug: PTE is now %x\n", *pte);
801089df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089e2:	8b 00                	mov    (%eax),%eax
801089e4:	83 ec 08             	sub    $0x8,%esp
801089e7:	50                   	push   %eax
801089e8:	68 20 9a 10 80       	push   $0x80109a20
801089ed:	e8 26 7a ff ff       	call   80100418 <cprintf>
801089f2:	83 c4 10             	add    $0x10,%esp
  return (char*)P2V(PTE_ADDR(*pte));
801089f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089f8:	8b 00                	mov    (%eax),%eax
801089fa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801089ff:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108a04:	c9                   	leave  
80108a05:	c3                   	ret    

80108a06 <not_in_queue>:

int not_in_queue(char *VA){
80108a06:	f3 0f 1e fb          	endbr32 
80108a0a:	55                   	push   %ebp
80108a0b:	89 e5                	mov    %esp,%ebp
80108a0d:	83 ec 18             	sub    $0x18,%esp
  
  struct proc *curproc = myproc();
80108a10:	e8 fa ba ff ff       	call   8010450f <myproc>
80108a15:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for (int k=curproc->hand;k<curproc->hand + CLOCKSIZE; k++ ){
80108a18:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a1b:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108a21:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108a24:	eb 2f                	jmp    80108a55 <not_in_queue+0x4f>
  cprintf("IN NOT IN QUEUE %x\n", (uint)curproc->clock[k%CLOCKSIZE]);
80108a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a29:	99                   	cltd   
80108a2a:	c1 ea 1d             	shr    $0x1d,%edx
80108a2d:	01 d0                	add    %edx,%eax
80108a2f:	83 e0 07             	and    $0x7,%eax
80108a32:	29 d0                	sub    %edx,%eax
80108a34:	89 c2                	mov    %eax,%edx
80108a36:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a39:	83 c2 1c             	add    $0x1c,%edx
80108a3c:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80108a40:	83 ec 08             	sub    $0x8,%esp
80108a43:	50                   	push   %eax
80108a44:	68 38 9a 10 80       	push   $0x80109a38
80108a49:	e8 ca 79 ff ff       	call   80100418 <cprintf>
80108a4e:	83 c4 10             	add    $0x10,%esp
  for (int k=curproc->hand;k<curproc->hand + CLOCKSIZE; k++ ){
80108a51:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108a55:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a58:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108a5e:	83 c0 07             	add    $0x7,%eax
80108a61:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80108a64:	7e c0                	jle    80108a26 <not_in_queue+0x20>
  }
  for(int i=0; i < curproc->clock_len;i++){
80108a66:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108a6d:	eb 1d                	jmp    80108a8c <not_in_queue+0x86>
    if(VA==curproc->clock[i]){
80108a6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a72:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108a75:	83 c2 1c             	add    $0x1c,%edx
80108a78:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80108a7c:	39 45 08             	cmp    %eax,0x8(%ebp)
80108a7f:	75 07                	jne    80108a88 <not_in_queue+0x82>
      return 0;
80108a81:	b8 00 00 00 00       	mov    $0x0,%eax
80108a86:	eb 17                	jmp    80108a9f <not_in_queue+0x99>
  for(int i=0; i < curproc->clock_len;i++){
80108a88:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108a8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a8f:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80108a95:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80108a98:	7c d5                	jl     80108a6f <not_in_queue+0x69>
    }
  }
  return 1;
80108a9a:	b8 01 00 00 00       	mov    $0x1,%eax
}
80108a9f:	c9                   	leave  
80108aa0:	c3                   	ret    

80108aa1 <add_to_clock>:

void add_to_clock(char *VA){
80108aa1:	f3 0f 1e fb          	endbr32 
80108aa5:	55                   	push   %ebp
80108aa6:	89 e5                	mov    %esp,%ebp
80108aa8:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80108aab:	e8 5f ba ff ff       	call   8010450f <myproc>
80108ab0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (curproc->clock_len < CLOCKSIZE){
80108ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ab6:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80108abc:	83 f8 07             	cmp    $0x7,%eax
80108abf:	7f 2b                	jg     80108aec <add_to_clock+0x4b>
    curproc->clock[curproc->clock_len] = VA;
80108ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ac4:	8b 90 a0 00 00 00    	mov    0xa0(%eax),%edx
80108aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108acd:	8d 4a 1c             	lea    0x1c(%edx),%ecx
80108ad0:	8b 55 08             	mov    0x8(%ebp),%edx
80108ad3:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    curproc -> clock_len = curproc->clock_len + 1;
80108ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ada:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80108ae0:	8d 50 01             	lea    0x1(%eax),%edx
80108ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ae6:	89 90 a0 00 00 00    	mov    %edx,0xa0(%eax)
  }
}
80108aec:	90                   	nop
80108aed:	c9                   	leave  
80108aee:	c3                   	ret    

80108aef <mdecrypt>:
int mdecrypt(char *virtual_addr) {
80108aef:	f3 0f 1e fb          	endbr32 
80108af3:	55                   	push   %ebp
80108af4:	89 e5                	mov    %esp,%ebp
80108af6:	83 ec 28             	sub    $0x28,%esp
  cprintf("p4Debug:  mdecrypt VPN %d, %p, pid %d\n", PPN(virtual_addr), virtual_addr, myproc()->pid);
80108af9:	e8 11 ba ff ff       	call   8010450f <myproc>
80108afe:	8b 40 10             	mov    0x10(%eax),%eax
80108b01:	8b 55 08             	mov    0x8(%ebp),%edx
80108b04:	c1 ea 0c             	shr    $0xc,%edx
80108b07:	50                   	push   %eax
80108b08:	ff 75 08             	pushl  0x8(%ebp)
80108b0b:	52                   	push   %edx
80108b0c:	68 4c 9a 10 80       	push   $0x80109a4c
80108b11:	e8 02 79 ff ff       	call   80100418 <cprintf>
80108b16:	83 c4 10             	add    $0x10,%esp
  //p4Debug: virtual_addr is a virtual address in this PID's userspace.
  struct proc * p = myproc();
80108b19:	e8 f1 b9 ff ff       	call   8010450f <myproc>
80108b1e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  pde_t* mypd = p->pgdir;
80108b21:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b24:	8b 40 04             	mov    0x4(%eax),%eax
80108b27:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  //set the present bit to true and encrypt bit to false
  pte_t * pte = walkpgdir(mypd, virtual_addr, 0);
80108b2a:	83 ec 04             	sub    $0x4,%esp
80108b2d:	6a 00                	push   $0x0
80108b2f:	ff 75 08             	pushl  0x8(%ebp)
80108b32:	ff 75 e4             	pushl  -0x1c(%ebp)
80108b35:	e8 09 f4 ff ff       	call   80107f43 <walkpgdir>
80108b3a:	83 c4 10             	add    $0x10,%esp
80108b3d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if (!pte || *pte == 0) {
80108b40:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108b44:	74 09                	je     80108b4f <mdecrypt+0x60>
80108b46:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b49:	8b 00                	mov    (%eax),%eax
80108b4b:	85 c0                	test   %eax,%eax
80108b4d:	75 1a                	jne    80108b69 <mdecrypt+0x7a>
    cprintf("p4Debug: walkpgdir failed\n");
80108b4f:	83 ec 0c             	sub    $0xc,%esp
80108b52:	68 73 9a 10 80       	push   $0x80109a73
80108b57:	e8 bc 78 ff ff       	call   80100418 <cprintf>
80108b5c:	83 c4 10             	add    $0x10,%esp
    return -1;
80108b5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108b64:	e9 5c 01 00 00       	jmp    80108cc5 <mdecrypt+0x1d6>
  }
  cprintf("p4Debug: pte was %x\n", *pte);
80108b69:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b6c:	8b 00                	mov    (%eax),%eax
80108b6e:	83 ec 08             	sub    $0x8,%esp
80108b71:	50                   	push   %eax
80108b72:	68 8e 9a 10 80       	push   $0x80109a8e
80108b77:	e8 9c 78 ff ff       	call   80100418 <cprintf>
80108b7c:	83 c4 10             	add    $0x10,%esp
  *pte = *pte & ~PTE_E;
80108b7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b82:	8b 00                	mov    (%eax),%eax
80108b84:	80 e4 fb             	and    $0xfb,%ah
80108b87:	89 c2                	mov    %eax,%edx
80108b89:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b8c:	89 10                	mov    %edx,(%eax)
  *pte = *pte | PTE_P;
80108b8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b91:	8b 00                	mov    (%eax),%eax
80108b93:	83 c8 01             	or     $0x1,%eax
80108b96:	89 c2                	mov    %eax,%edx
80108b98:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b9b:	89 10                	mov    %edx,(%eax)
  cprintf("p4Debug: pte is %x\n", *pte);
80108b9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ba0:	8b 00                	mov    (%eax),%eax
80108ba2:	83 ec 08             	sub    $0x8,%esp
80108ba5:	50                   	push   %eax
80108ba6:	68 a3 9a 10 80       	push   $0x80109aa3
80108bab:	e8 68 78 ff ff       	call   80100418 <cprintf>
80108bb0:	83 c4 10             	add    $0x10,%esp
  
  add_to_clock(virtual_addr);
80108bb3:	83 ec 0c             	sub    $0xc,%esp
80108bb6:	ff 75 08             	pushl  0x8(%ebp)
80108bb9:	e8 e3 fe ff ff       	call   80108aa1 <add_to_clock>
80108bbe:	83 c4 10             	add    $0x10,%esp


  char * original = uva2ka(mypd, virtual_addr) + OFFSET(virtual_addr);
80108bc1:	83 ec 08             	sub    $0x8,%esp
80108bc4:	ff 75 08             	pushl  0x8(%ebp)
80108bc7:	ff 75 e4             	pushl  -0x1c(%ebp)
80108bca:	e8 58 fc ff ff       	call   80108827 <uva2ka>
80108bcf:	83 c4 10             	add    $0x10,%esp
80108bd2:	8b 55 08             	mov    0x8(%ebp),%edx
80108bd5:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
80108bdb:	01 d0                	add    %edx,%eax
80108bdd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  cprintf("p4Debug: Original in decrypt was %p\n", original);
80108be0:	83 ec 08             	sub    $0x8,%esp
80108be3:	ff 75 dc             	pushl  -0x24(%ebp)
80108be6:	68 b8 9a 10 80       	push   $0x80109ab8
80108beb:	e8 28 78 ff ff       	call   80100418 <cprintf>
80108bf0:	83 c4 10             	add    $0x10,%esp
  virtual_addr = (char *)PGROUNDDOWN((uint)virtual_addr);
80108bf3:	8b 45 08             	mov    0x8(%ebp),%eax
80108bf6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108bfb:	89 45 08             	mov    %eax,0x8(%ebp)
  cprintf("p4Debug: mdecrypt: rounded down va is %p\n", virtual_addr);
80108bfe:	83 ec 08             	sub    $0x8,%esp
80108c01:	ff 75 08             	pushl  0x8(%ebp)
80108c04:	68 e0 9a 10 80       	push   $0x80109ae0
80108c09:	e8 0a 78 ff ff       	call   80100418 <cprintf>
80108c0e:	83 c4 10             	add    $0x10,%esp

  char * kvp = uva2ka(mypd, virtual_addr);
80108c11:	83 ec 08             	sub    $0x8,%esp
80108c14:	ff 75 08             	pushl  0x8(%ebp)
80108c17:	ff 75 e4             	pushl  -0x1c(%ebp)
80108c1a:	e8 08 fc ff ff       	call   80108827 <uva2ka>
80108c1f:	83 c4 10             	add    $0x10,%esp
80108c22:	89 45 d8             	mov    %eax,-0x28(%ebp)
  if (!kvp || *kvp == 0) {
80108c25:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80108c29:	74 0a                	je     80108c35 <mdecrypt+0x146>
80108c2b:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108c2e:	0f b6 00             	movzbl (%eax),%eax
80108c31:	84 c0                	test   %al,%al
80108c33:	75 0a                	jne    80108c3f <mdecrypt+0x150>
    return -1;
80108c35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c3a:	e9 86 00 00 00       	jmp    80108cc5 <mdecrypt+0x1d6>
  }
  char * slider = virtual_addr;
80108c3f:	8b 45 08             	mov    0x8(%ebp),%eax
80108c42:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int offset = 0; offset < PGSIZE; offset++) {
80108c45:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108c4c:	eb 17                	jmp    80108c65 <mdecrypt+0x176>
    *slider = *slider ^ 0xFF;
80108c4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c51:	0f b6 00             	movzbl (%eax),%eax
80108c54:	f7 d0                	not    %eax
80108c56:	89 c2                	mov    %eax,%edx
80108c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c5b:	88 10                	mov    %dl,(%eax)
    slider++;
80108c5d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  for (int offset = 0; offset < PGSIZE; offset++) {
80108c61:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108c65:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80108c6c:	7e e0                	jle    80108c4e <mdecrypt+0x15f>
  }
  for (int k=p->hand;k<p->hand + CLOCKSIZE; k++ ){
80108c6e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c71:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108c77:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108c7a:	eb 33                	jmp    80108caf <mdecrypt+0x1c0>
  cprintf("IN DECRYPT: %x  %x\n", (uint)p->clock[k%CLOCKSIZE], (uint) virtual_addr);
80108c7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
80108c7f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c82:	99                   	cltd   
80108c83:	c1 ea 1d             	shr    $0x1d,%edx
80108c86:	01 d0                	add    %edx,%eax
80108c88:	83 e0 07             	and    $0x7,%eax
80108c8b:	29 d0                	sub    %edx,%eax
80108c8d:	89 c2                	mov    %eax,%edx
80108c8f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c92:	83 c2 1c             	add    $0x1c,%edx
80108c95:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80108c99:	83 ec 04             	sub    $0x4,%esp
80108c9c:	51                   	push   %ecx
80108c9d:	50                   	push   %eax
80108c9e:	68 0a 9b 10 80       	push   $0x80109b0a
80108ca3:	e8 70 77 ff ff       	call   80100418 <cprintf>
80108ca8:	83 c4 10             	add    $0x10,%esp
  for (int k=p->hand;k<p->hand + CLOCKSIZE; k++ ){
80108cab:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108caf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108cb2:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108cb8:	83 c0 07             	add    $0x7,%eax
80108cbb:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108cbe:	7e bc                	jle    80108c7c <mdecrypt+0x18d>
  }
  return 0;
80108cc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108cc5:	c9                   	leave  
80108cc6:	c3                   	ret    

80108cc7 <mencrypt>:

int mencrypt(char *virtual_addr, int len) {
80108cc7:	f3 0f 1e fb          	endbr32 
80108ccb:	55                   	push   %ebp
80108ccc:	89 e5                	mov    %esp,%ebp
80108cce:	83 ec 38             	sub    $0x38,%esp

  if(len==0)
80108cd1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80108cd5:	75 0a                	jne    80108ce1 <mencrypt+0x1a>
    return 0;
80108cd7:	b8 00 00 00 00       	mov    $0x0,%eax
80108cdc:	e9 ca 01 00 00       	jmp    80108eab <mencrypt+0x1e4>

  cprintf("p4Debug: mencrypt: %p %d\n", virtual_addr, len);
80108ce1:	83 ec 04             	sub    $0x4,%esp
80108ce4:	ff 75 0c             	pushl  0xc(%ebp)
80108ce7:	ff 75 08             	pushl  0x8(%ebp)
80108cea:	68 1e 9b 10 80       	push   $0x80109b1e
80108cef:	e8 24 77 ff ff       	call   80100418 <cprintf>
80108cf4:	83 c4 10             	add    $0x10,%esp
  //the given pointer is a virtual address in this pid's userspace
  struct proc * p = myproc();
80108cf7:	e8 13 b8 ff ff       	call   8010450f <myproc>
80108cfc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  pde_t* mypd = p->pgdir;
80108cff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108d02:	8b 40 04             	mov    0x4(%eax),%eax
80108d05:	89 45 e0             	mov    %eax,-0x20(%ebp)

  virtual_addr = (char *)PGROUNDDOWN((uint)virtual_addr);
80108d08:	8b 45 08             	mov    0x8(%ebp),%eax
80108d0b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108d10:	89 45 08             	mov    %eax,0x8(%ebp)

  //error checking first. all or nothing.
  char * slider = virtual_addr;
80108d13:	8b 45 08             	mov    0x8(%ebp),%eax
80108d16:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
80108d19:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108d20:	eb 55                	jmp    80108d77 <mencrypt+0xb0>
    //check page table for each translation first
    char * kvp = uva2ka(mypd, slider);
80108d22:	83 ec 08             	sub    $0x8,%esp
80108d25:	ff 75 f4             	pushl  -0xc(%ebp)
80108d28:	ff 75 e0             	pushl  -0x20(%ebp)
80108d2b:	e8 f7 fa ff ff       	call   80108827 <uva2ka>
80108d30:	83 c4 10             	add    $0x10,%esp
80108d33:	89 45 d0             	mov    %eax,-0x30(%ebp)
    cprintf("p4Debug: slider %p, kvp for err check is %p\n",slider, kvp);
80108d36:	83 ec 04             	sub    $0x4,%esp
80108d39:	ff 75 d0             	pushl  -0x30(%ebp)
80108d3c:	ff 75 f4             	pushl  -0xc(%ebp)
80108d3f:	68 38 9b 10 80       	push   $0x80109b38
80108d44:	e8 cf 76 ff ff       	call   80100418 <cprintf>
80108d49:	83 c4 10             	add    $0x10,%esp
    if (!kvp) {
80108d4c:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
80108d50:	75 1a                	jne    80108d6c <mencrypt+0xa5>
      cprintf("p4Debug: mencrypt: kvp = NULL\n");
80108d52:	83 ec 0c             	sub    $0xc,%esp
80108d55:	68 68 9b 10 80       	push   $0x80109b68
80108d5a:	e8 b9 76 ff ff       	call   80100418 <cprintf>
80108d5f:	83 c4 10             	add    $0x10,%esp
      return -1;
80108d62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d67:	e9 3f 01 00 00       	jmp    80108eab <mencrypt+0x1e4>
    }
    slider = slider + PGSIZE;
80108d6c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
80108d73:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108d77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d7a:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108d7d:	7c a3                	jl     80108d22 <mencrypt+0x5b>
  }

  //encrypt stage. Have to do this before setting flag 
  //or else we'll page fault
  slider = virtual_addr;
80108d7f:	8b 45 08             	mov    0x8(%ebp),%eax
80108d82:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int i = 0; i < len; i++) {
80108d85:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108d8c:	e9 f8 00 00 00       	jmp    80108e89 <mencrypt+0x1c2>
    cprintf("p4Debug: mencryptr: VPN %d, %p\n", PPN(slider), slider);
80108d91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d94:	c1 e8 0c             	shr    $0xc,%eax
80108d97:	83 ec 04             	sub    $0x4,%esp
80108d9a:	ff 75 f4             	pushl  -0xc(%ebp)
80108d9d:	50                   	push   %eax
80108d9e:	68 88 9b 10 80       	push   $0x80109b88
80108da3:	e8 70 76 ff ff       	call   80100418 <cprintf>
80108da8:	83 c4 10             	add    $0x10,%esp
    //kvp = kernel virtual pointer
    //virtual address in kernel space that maps to the given pointer
    char * kvp = uva2ka(mypd, slider);
80108dab:	83 ec 08             	sub    $0x8,%esp
80108dae:	ff 75 f4             	pushl  -0xc(%ebp)
80108db1:	ff 75 e0             	pushl  -0x20(%ebp)
80108db4:	e8 6e fa ff ff       	call   80108827 <uva2ka>
80108db9:	83 c4 10             	add    $0x10,%esp
80108dbc:	89 45 dc             	mov    %eax,-0x24(%ebp)
    cprintf("p4Debug: kvp for encrypt stage is %p\n", kvp);
80108dbf:	83 ec 08             	sub    $0x8,%esp
80108dc2:	ff 75 dc             	pushl  -0x24(%ebp)
80108dc5:	68 a8 9b 10 80       	push   $0x80109ba8
80108dca:	e8 49 76 ff ff       	call   80100418 <cprintf>
80108dcf:	83 c4 10             	add    $0x10,%esp
    pte_t * mypte = walkpgdir(mypd, slider, 0);
80108dd2:	83 ec 04             	sub    $0x4,%esp
80108dd5:	6a 00                	push   $0x0
80108dd7:	ff 75 f4             	pushl  -0xc(%ebp)
80108dda:	ff 75 e0             	pushl  -0x20(%ebp)
80108ddd:	e8 61 f1 ff ff       	call   80107f43 <walkpgdir>
80108de2:	83 c4 10             	add    $0x10,%esp
80108de5:	89 45 d8             	mov    %eax,-0x28(%ebp)
    cprintf("p4Debug: pte is %x\n", *mypte);
80108de8:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108deb:	8b 00                	mov    (%eax),%eax
80108ded:	83 ec 08             	sub    $0x8,%esp
80108df0:	50                   	push   %eax
80108df1:	68 a3 9a 10 80       	push   $0x80109aa3
80108df6:	e8 1d 76 ff ff       	call   80100418 <cprintf>
80108dfb:	83 c4 10             	add    $0x10,%esp
    if (*mypte & PTE_E) {
80108dfe:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108e01:	8b 00                	mov    (%eax),%eax
80108e03:	25 00 04 00 00       	and    $0x400,%eax
80108e08:	85 c0                	test   %eax,%eax
80108e0a:	74 19                	je     80108e25 <mencrypt+0x15e>
      cprintf("p4Debug: already encrypted\n");
80108e0c:	83 ec 0c             	sub    $0xc,%esp
80108e0f:	68 ce 9b 10 80       	push   $0x80109bce
80108e14:	e8 ff 75 ff ff       	call   80100418 <cprintf>
80108e19:	83 c4 10             	add    $0x10,%esp
      slider += PGSIZE;
80108e1c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
      continue;
80108e23:	eb 60                	jmp    80108e85 <mencrypt+0x1be>
    }
    for (int offset = 0; offset < PGSIZE; offset++) {
80108e25:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
80108e2c:	eb 17                	jmp    80108e45 <mencrypt+0x17e>
      *slider = *slider ^ 0xFF;
80108e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e31:	0f b6 00             	movzbl (%eax),%eax
80108e34:	f7 d0                	not    %eax
80108e36:	89 c2                	mov    %eax,%edx
80108e38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e3b:	88 10                	mov    %dl,(%eax)
      slider++;
80108e3d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    for (int offset = 0; offset < PGSIZE; offset++) {
80108e41:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80108e45:	81 7d e8 ff 0f 00 00 	cmpl   $0xfff,-0x18(%ebp)
80108e4c:	7e e0                	jle    80108e2e <mencrypt+0x167>
    }
    char * kvp_translated = translate_and_set(mypd, slider-PGSIZE);
80108e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e51:	2d 00 10 00 00       	sub    $0x1000,%eax
80108e56:	83 ec 08             	sub    $0x8,%esp
80108e59:	50                   	push   %eax
80108e5a:	ff 75 e0             	pushl  -0x20(%ebp)
80108e5d:	e8 c0 fa ff ff       	call   80108922 <translate_and_set>
80108e62:	83 c4 10             	add    $0x10,%esp
80108e65:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    if (!kvp_translated) {
80108e68:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80108e6c:	75 17                	jne    80108e85 <mencrypt+0x1be>
      cprintf("p4Debug: translate failed!");
80108e6e:	83 ec 0c             	sub    $0xc,%esp
80108e71:	68 ea 9b 10 80       	push   $0x80109bea
80108e76:	e8 9d 75 ff ff       	call   80100418 <cprintf>
80108e7b:	83 c4 10             	add    $0x10,%esp
      return -1;
80108e7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108e83:	eb 26                	jmp    80108eab <mencrypt+0x1e4>
  for (int i = 0; i < len; i++) {
80108e85:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108e89:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e8c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108e8f:	0f 8c fc fe ff ff    	jl     80108d91 <mencrypt+0xca>
    }
  }

  switchuvm(myproc());
80108e95:	e8 75 b6 ff ff       	call   8010450f <myproc>
80108e9a:	83 ec 0c             	sub    $0xc,%esp
80108e9d:	50                   	push   %eax
80108e9e:	e8 c7 f2 ff ff       	call   8010816a <switchuvm>
80108ea3:	83 c4 10             	add    $0x10,%esp
  return 0;
80108ea6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108eab:	c9                   	leave  
80108eac:	c3                   	ret    

80108ead <getpgtable>:

int getpgtable(struct pt_entry* pt_entries, int num, int wsetOnly) {
80108ead:	f3 0f 1e fb          	endbr32 
80108eb1:	55                   	push   %ebp
80108eb2:	89 e5                	mov    %esp,%ebp
80108eb4:	83 ec 28             	sub    $0x28,%esp
  cprintf("p4Debug: getpgtable: %p, %d\n", pt_entries, num);
80108eb7:	83 ec 04             	sub    $0x4,%esp
80108eba:	ff 75 0c             	pushl  0xc(%ebp)
80108ebd:	ff 75 08             	pushl  0x8(%ebp)
80108ec0:	68 05 9c 10 80       	push   $0x80109c05
80108ec5:	e8 4e 75 ff ff       	call   80100418 <cprintf>
80108eca:	83 c4 10             	add    $0x10,%esp

  struct proc *curproc = myproc();
80108ecd:	e8 3d b6 ff ff       	call   8010450f <myproc>
80108ed2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pde_t *pgdir = curproc->pgdir;
80108ed5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ed8:	8b 40 04             	mov    0x4(%eax),%eax
80108edb:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint uva = 0;
80108ede:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if (curproc->sz % PGSIZE == 0)
80108ee5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ee8:	8b 00                	mov    (%eax),%eax
80108eea:	25 ff 0f 00 00       	and    $0xfff,%eax
80108eef:	85 c0                	test   %eax,%eax
80108ef1:	75 0f                	jne    80108f02 <getpgtable+0x55>
    uva = curproc->sz - PGSIZE;
80108ef3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ef6:	8b 00                	mov    (%eax),%eax
80108ef8:	2d 00 10 00 00       	sub    $0x1000,%eax
80108efd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108f00:	eb 0d                	jmp    80108f0f <getpgtable+0x62>
  else 
    uva = PGROUNDDOWN(curproc->sz);
80108f02:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f05:	8b 00                	mov    (%eax),%eax
80108f07:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f0c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  int i = 0;
80108f0f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for (;;uva -=PGSIZE)
  {
    
    pte_t *pte = walkpgdir(pgdir, (const void *)uva, 0);
80108f16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f19:	83 ec 04             	sub    $0x4,%esp
80108f1c:	6a 00                	push   $0x0
80108f1e:	50                   	push   %eax
80108f1f:	ff 75 e8             	pushl  -0x18(%ebp)
80108f22:	e8 1c f0 ff ff       	call   80107f43 <walkpgdir>
80108f27:	83 c4 10             	add    $0x10,%esp
80108f2a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(wsetOnly && not_in_queue((char*)P2V(PTE_ADDR(*pte)))){
80108f2d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108f31:	74 3a                	je     80108f6d <getpgtable+0xc0>
80108f33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f36:	8b 00                	mov    (%eax),%eax
80108f38:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f3d:	05 00 00 00 80       	add    $0x80000000,%eax
80108f42:	83 ec 0c             	sub    $0xc,%esp
80108f45:	50                   	push   %eax
80108f46:	e8 bb fa ff ff       	call   80108a06 <not_in_queue>
80108f4b:	83 c4 10             	add    $0x10,%esp
80108f4e:	85 c0                	test   %eax,%eax
80108f50:	74 1b                	je     80108f6d <getpgtable+0xc0>
      if(uva == 0 || i == num){
80108f52:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108f56:	0f 84 ac 01 00 00    	je     80109108 <getpgtable+0x25b>
80108f5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f5f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108f62:	0f 84 a0 01 00 00    	je     80109108 <getpgtable+0x25b>
        break;
      }
      continue;
80108f68:	e9 8f 01 00 00       	jmp    801090fc <getpgtable+0x24f>
    }
    if (!(*pte & PTE_U) || !(*pte & (PTE_P | PTE_E)))
80108f6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f70:	8b 00                	mov    (%eax),%eax
80108f72:	83 e0 04             	and    $0x4,%eax
80108f75:	85 c0                	test   %eax,%eax
80108f77:	0f 84 7e 01 00 00    	je     801090fb <getpgtable+0x24e>
80108f7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f80:	8b 00                	mov    (%eax),%eax
80108f82:	25 01 04 00 00       	and    $0x401,%eax
80108f87:	85 c0                	test   %eax,%eax
80108f89:	0f 84 6c 01 00 00    	je     801090fb <getpgtable+0x24e>
      continue;

    pt_entries[i].pdx = PDX(uva);
80108f8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f92:	c1 e8 16             	shr    $0x16,%eax
80108f95:	89 c1                	mov    %eax,%ecx
80108f97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f9a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80108fa1:	8b 45 08             	mov    0x8(%ebp),%eax
80108fa4:	01 c2                	add    %eax,%edx
80108fa6:	89 c8                	mov    %ecx,%eax
80108fa8:	66 25 ff 03          	and    $0x3ff,%ax
80108fac:	66 25 ff 03          	and    $0x3ff,%ax
80108fb0:	89 c1                	mov    %eax,%ecx
80108fb2:	0f b7 02             	movzwl (%edx),%eax
80108fb5:	66 25 00 fc          	and    $0xfc00,%ax
80108fb9:	09 c8                	or     %ecx,%eax
80108fbb:	66 89 02             	mov    %ax,(%edx)
    pt_entries[i].ptx = PTX(uva);
80108fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fc1:	c1 e8 0c             	shr    $0xc,%eax
80108fc4:	89 c1                	mov    %eax,%ecx
80108fc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fc9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80108fd0:	8b 45 08             	mov    0x8(%ebp),%eax
80108fd3:	01 c2                	add    %eax,%edx
80108fd5:	89 c8                	mov    %ecx,%eax
80108fd7:	66 25 ff 03          	and    $0x3ff,%ax
80108fdb:	0f b7 c0             	movzwl %ax,%eax
80108fde:	25 ff 03 00 00       	and    $0x3ff,%eax
80108fe3:	c1 e0 0a             	shl    $0xa,%eax
80108fe6:	89 c1                	mov    %eax,%ecx
80108fe8:	8b 02                	mov    (%edx),%eax
80108fea:	25 ff 03 f0 ff       	and    $0xfff003ff,%eax
80108fef:	09 c8                	or     %ecx,%eax
80108ff1:	89 02                	mov    %eax,(%edx)
    pt_entries[i].ppage = *pte >> PTXSHIFT;
80108ff3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108ff6:	8b 00                	mov    (%eax),%eax
80108ff8:	c1 e8 0c             	shr    $0xc,%eax
80108ffb:	89 c2                	mov    %eax,%edx
80108ffd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109000:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80109007:	8b 45 08             	mov    0x8(%ebp),%eax
8010900a:	01 c8                	add    %ecx,%eax
8010900c:	81 e2 ff ff 0f 00    	and    $0xfffff,%edx
80109012:	89 d1                	mov    %edx,%ecx
80109014:	81 e1 ff ff 0f 00    	and    $0xfffff,%ecx
8010901a:	8b 50 04             	mov    0x4(%eax),%edx
8010901d:	81 e2 00 00 f0 ff    	and    $0xfff00000,%edx
80109023:	09 ca                	or     %ecx,%edx
80109025:	89 50 04             	mov    %edx,0x4(%eax)
    pt_entries[i].present = *pte & PTE_P;
80109028:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010902b:	8b 08                	mov    (%eax),%ecx
8010902d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109030:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80109037:	8b 45 08             	mov    0x8(%ebp),%eax
8010903a:	01 c2                	add    %eax,%edx
8010903c:	89 c8                	mov    %ecx,%eax
8010903e:	83 e0 01             	and    $0x1,%eax
80109041:	83 e0 01             	and    $0x1,%eax
80109044:	c1 e0 04             	shl    $0x4,%eax
80109047:	89 c1                	mov    %eax,%ecx
80109049:	0f b6 42 06          	movzbl 0x6(%edx),%eax
8010904d:	83 e0 ef             	and    $0xffffffef,%eax
80109050:	09 c8                	or     %ecx,%eax
80109052:	88 42 06             	mov    %al,0x6(%edx)
    pt_entries[i].writable = (*pte & PTE_W) > 0;
80109055:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109058:	8b 00                	mov    (%eax),%eax
8010905a:	83 e0 02             	and    $0x2,%eax
8010905d:	89 c2                	mov    %eax,%edx
8010905f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109062:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80109069:	8b 45 08             	mov    0x8(%ebp),%eax
8010906c:	01 c8                	add    %ecx,%eax
8010906e:	85 d2                	test   %edx,%edx
80109070:	0f 95 c2             	setne  %dl
80109073:	83 e2 01             	and    $0x1,%edx
80109076:	89 d1                	mov    %edx,%ecx
80109078:	c1 e1 05             	shl    $0x5,%ecx
8010907b:	0f b6 50 06          	movzbl 0x6(%eax),%edx
8010907f:	83 e2 df             	and    $0xffffffdf,%edx
80109082:	09 ca                	or     %ecx,%edx
80109084:	88 50 06             	mov    %dl,0x6(%eax)
    pt_entries[i].encrypted = (*pte & PTE_E) > 0;
80109087:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010908a:	8b 00                	mov    (%eax),%eax
8010908c:	25 00 04 00 00       	and    $0x400,%eax
80109091:	89 c2                	mov    %eax,%edx
80109093:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109096:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
8010909d:	8b 45 08             	mov    0x8(%ebp),%eax
801090a0:	01 c8                	add    %ecx,%eax
801090a2:	85 d2                	test   %edx,%edx
801090a4:	0f 95 c2             	setne  %dl
801090a7:	89 d1                	mov    %edx,%ecx
801090a9:	c1 e1 07             	shl    $0x7,%ecx
801090ac:	0f b6 50 06          	movzbl 0x6(%eax),%edx
801090b0:	83 e2 7f             	and    $0x7f,%edx
801090b3:	09 ca                	or     %ecx,%edx
801090b5:	88 50 06             	mov    %dl,0x6(%eax)
    pt_entries[i].ref = (*pte & PTE_A) > 0;
801090b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801090bb:	8b 00                	mov    (%eax),%eax
801090bd:	83 e0 20             	and    $0x20,%eax
801090c0:	89 c2                	mov    %eax,%edx
801090c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090c5:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
801090cc:	8b 45 08             	mov    0x8(%ebp),%eax
801090cf:	01 c8                	add    %ecx,%eax
801090d1:	85 d2                	test   %edx,%edx
801090d3:	0f 95 c2             	setne  %dl
801090d6:	89 d1                	mov    %edx,%ecx
801090d8:	83 e1 01             	and    $0x1,%ecx
801090db:	0f b6 50 07          	movzbl 0x7(%eax),%edx
801090df:	83 e2 fe             	and    $0xfffffffe,%edx
801090e2:	09 ca                	or     %ecx,%edx
801090e4:	88 50 07             	mov    %dl,0x7(%eax)
    //PT_A flag needs to be modified as per clock algo.
    i ++;
801090e7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    if (uva == 0 || i == num) break;
801090eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801090ef:	74 17                	je     80109108 <getpgtable+0x25b>
801090f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090f4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801090f7:	74 0f                	je     80109108 <getpgtable+0x25b>
801090f9:	eb 01                	jmp    801090fc <getpgtable+0x24f>
      continue;
801090fb:	90                   	nop
  for (;;uva -=PGSIZE)
801090fc:	81 6d f4 00 10 00 00 	subl   $0x1000,-0xc(%ebp)
  {
80109103:	e9 0e fe ff ff       	jmp    80108f16 <getpgtable+0x69>

  }

  return i;
80109108:	8b 45 f0             	mov    -0x10(%ebp),%eax

}
8010910b:	c9                   	leave  
8010910c:	c3                   	ret    

8010910d <dump_rawphymem>:


int dump_rawphymem(char *physical_addr, char * buffer) {
8010910d:	f3 0f 1e fb          	endbr32 
80109111:	55                   	push   %ebp
80109112:	89 e5                	mov    %esp,%ebp
80109114:	56                   	push   %esi
80109115:	53                   	push   %ebx
80109116:	83 ec 10             	sub    $0x10,%esp
  *buffer = *buffer;
80109119:	8b 45 0c             	mov    0xc(%ebp),%eax
8010911c:	0f b6 10             	movzbl (%eax),%edx
8010911f:	8b 45 0c             	mov    0xc(%ebp),%eax
80109122:	88 10                	mov    %dl,(%eax)
  cprintf("p4Debug: dump_rawphymem: %p, %p\n", physical_addr, buffer);
80109124:	83 ec 04             	sub    $0x4,%esp
80109127:	ff 75 0c             	pushl  0xc(%ebp)
8010912a:	ff 75 08             	pushl  0x8(%ebp)
8010912d:	68 24 9c 10 80       	push   $0x80109c24
80109132:	e8 e1 72 ff ff       	call   80100418 <cprintf>
80109137:	83 c4 10             	add    $0x10,%esp
  int retval = copyout(myproc()->pgdir, (uint) buffer, (void *) PGROUNDDOWN((int)P2V(physical_addr)), PGSIZE);
8010913a:	8b 45 08             	mov    0x8(%ebp),%eax
8010913d:	05 00 00 00 80       	add    $0x80000000,%eax
80109142:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109147:	89 c6                	mov    %eax,%esi
80109149:	8b 5d 0c             	mov    0xc(%ebp),%ebx
8010914c:	e8 be b3 ff ff       	call   8010450f <myproc>
80109151:	8b 40 04             	mov    0x4(%eax),%eax
80109154:	68 00 10 00 00       	push   $0x1000
80109159:	56                   	push   %esi
8010915a:	53                   	push   %ebx
8010915b:	50                   	push   %eax
8010915c:	e8 1f f7 ff ff       	call   80108880 <copyout>
80109161:	83 c4 10             	add    $0x10,%esp
80109164:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (retval)
80109167:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010916b:	74 07                	je     80109174 <dump_rawphymem+0x67>
    return -1;
8010916d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109172:	eb 05                	jmp    80109179 <dump_rawphymem+0x6c>
  return 0;
80109174:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109179:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010917c:	5b                   	pop    %ebx
8010917d:	5e                   	pop    %esi
8010917e:	5d                   	pop    %ebp
8010917f:	c3                   	ret    
