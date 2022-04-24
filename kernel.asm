
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
80100041:	68 94 93 10 80       	push   $0x80109394
80100046:	68 60 d6 10 80       	push   $0x8010d660
8010004b:	e8 64 52 00 00       	call   801052b4 <initlock>
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
8010008f:	68 9b 93 10 80       	push   $0x8010939b
80100094:	50                   	push   %eax
80100095:	e8 87 50 00 00       	call   80105121 <initsleeplock>
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
801000d7:	e8 fe 51 00 00       	call   801052da <acquire>
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
80100116:	e8 31 52 00 00       	call   8010534c <release>
8010011b:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	83 c0 0c             	add    $0xc,%eax
80100124:	83 ec 0c             	sub    $0xc,%esp
80100127:	50                   	push   %eax
80100128:	e8 34 50 00 00       	call   80105161 <acquiresleep>
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
80100197:	e8 b0 51 00 00       	call   8010534c <release>
8010019c:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
8010019f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a2:	83 c0 0c             	add    $0xc,%eax
801001a5:	83 ec 0c             	sub    $0xc,%esp
801001a8:	50                   	push   %eax
801001a9:	e8 b3 4f 00 00       	call   80105161 <acquiresleep>
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
801001cb:	68 a2 93 10 80       	push   $0x801093a2
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
80100228:	e8 ee 4f 00 00       	call   8010521b <holdingsleep>
8010022d:	83 c4 10             	add    $0x10,%esp
80100230:	85 c0                	test   %eax,%eax
80100232:	75 0d                	jne    80100241 <bwrite+0x2d>
    panic("bwrite");
80100234:	83 ec 0c             	sub    $0xc,%esp
80100237:	68 b3 93 10 80       	push   $0x801093b3
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
80100275:	e8 a1 4f 00 00       	call   8010521b <holdingsleep>
8010027a:	83 c4 10             	add    $0x10,%esp
8010027d:	85 c0                	test   %eax,%eax
8010027f:	75 0d                	jne    8010028e <brelse+0x2d>
    panic("brelse");
80100281:	83 ec 0c             	sub    $0xc,%esp
80100284:	68 ba 93 10 80       	push   $0x801093ba
80100289:	e8 7a 03 00 00       	call   80100608 <panic>

  releasesleep(&b->lock);
8010028e:	8b 45 08             	mov    0x8(%ebp),%eax
80100291:	83 c0 0c             	add    $0xc,%eax
80100294:	83 ec 0c             	sub    $0xc,%esp
80100297:	50                   	push   %eax
80100298:	e8 2c 4f 00 00       	call   801051c9 <releasesleep>
8010029d:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002a0:	83 ec 0c             	sub    $0xc,%esp
801002a3:	68 60 d6 10 80       	push   $0x8010d660
801002a8:	e8 2d 50 00 00       	call   801052da <acquire>
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
80100318:	e8 2f 50 00 00       	call   8010534c <release>
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
80100438:	e8 e4 4f 00 00       	call   80105421 <holding>
8010043d:	83 c4 10             	add    $0x10,%esp
80100440:	85 c0                	test   %eax,%eax
80100442:	75 10                	jne    80100454 <cprintf+0x3c>
    acquire(&cons.lock);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	68 c0 c5 10 80       	push   $0x8010c5c0
8010044c:	e8 89 4e 00 00       	call   801052da <acquire>
80100451:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100454:	8b 45 08             	mov    0x8(%ebp),%eax
80100457:	85 c0                	test   %eax,%eax
80100459:	75 0d                	jne    80100468 <cprintf+0x50>
    panic("null fmt");
8010045b:	83 ec 0c             	sub    $0xc,%esp
8010045e:	68 c4 93 10 80       	push   $0x801093c4
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
801004ee:	8b 04 85 d4 93 10 80 	mov    -0x7fef6c2c(,%eax,4),%eax
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
8010054c:	c7 45 ec cd 93 10 80 	movl   $0x801093cd,-0x14(%ebp)
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
801005fd:	e8 4a 4d 00 00       	call   8010534c <release>
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
8010062a:	68 2c 94 10 80       	push   $0x8010942c
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
80100649:	68 40 94 10 80       	push   $0x80109440
8010064e:	e8 c5 fd ff ff       	call   80100418 <cprintf>
80100653:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100656:	83 ec 08             	sub    $0x8,%esp
80100659:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010065c:	50                   	push   %eax
8010065d:	8d 45 08             	lea    0x8(%ebp),%eax
80100660:	50                   	push   %eax
80100661:	e8 3c 4d 00 00       	call   801053a2 <getcallerpcs>
80100666:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100669:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100670:	eb 1c                	jmp    8010068e <panic+0x86>
    cprintf(" %p", pcs[i]);
80100672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100675:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100679:	83 ec 08             	sub    $0x8,%esp
8010067c:	50                   	push   %eax
8010067d:	68 42 94 10 80       	push   $0x80109442
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
80100772:	68 46 94 10 80       	push   $0x80109446
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
8010079f:	e8 9c 4e 00 00       	call   80105640 <memmove>
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
801007c9:	e8 ab 4d 00 00       	call   80105579 <memset>
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
80100865:	e8 1e 68 00 00       	call   80107088 <uartputc>
8010086a:	83 c4 10             	add    $0x10,%esp
8010086d:	83 ec 0c             	sub    $0xc,%esp
80100870:	6a 20                	push   $0x20
80100872:	e8 11 68 00 00       	call   80107088 <uartputc>
80100877:	83 c4 10             	add    $0x10,%esp
8010087a:	83 ec 0c             	sub    $0xc,%esp
8010087d:	6a 08                	push   $0x8
8010087f:	e8 04 68 00 00       	call   80107088 <uartputc>
80100884:	83 c4 10             	add    $0x10,%esp
80100887:	eb 0e                	jmp    80100897 <consputc+0x5a>
  } else
    uartputc(c);
80100889:	83 ec 0c             	sub    $0xc,%esp
8010088c:	ff 75 08             	pushl  0x8(%ebp)
8010088f:	e8 f4 67 00 00       	call   80107088 <uartputc>
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
801008c1:	e8 14 4a 00 00       	call   801052da <acquire>
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
80100a17:	e8 3e 45 00 00       	call   80104f5a <wakeup>
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
80100a3a:	e8 0d 49 00 00       	call   8010534c <release>
80100a3f:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100a42:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100a46:	74 05                	je     80100a4d <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
80100a48:	e8 d3 45 00 00       	call   80105020 <procdump>
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
80100a76:	e8 5f 48 00 00       	call   801052da <acquire>
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
80100a97:	e8 b0 48 00 00       	call   8010534c <release>
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
80100ac4:	e8 9f 43 00 00       	call   80104e68 <sleep>
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
80100b42:	e8 05 48 00 00       	call   8010534c <release>
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
80100b84:	e8 51 47 00 00       	call   801052da <acquire>
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
80100bc6:	e8 81 47 00 00       	call   8010534c <release>
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
80100bee:	68 59 94 10 80       	push   $0x80109459
80100bf3:	68 c0 c5 10 80       	push   $0x8010c5c0
80100bf8:	e8 b7 46 00 00       	call   801052b4 <initlock>
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
80100cb3:	68 61 94 10 80       	push   $0x80109461
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
80100d0f:	e8 ab 73 00 00       	call   801080bf <setupkvm>
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
80100db5:	e8 c3 76 00 00       	call   8010847d <allocuvm>
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
80100dfb:	e8 ac 75 00 00       	call   801083ac <loaduvm>
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
80100e6a:	e8 0e 76 00 00       	call   8010847d <allocuvm>
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
80100e8e:	e8 5c 78 00 00       	call   801086ef <clearpteu>
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
80100ec7:	e8 16 49 00 00       	call   801057e2 <strlen>
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
80100ef4:	e8 e9 48 00 00       	call   801057e2 <strlen>
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
80100f1a:	e8 8c 79 00 00       	call   801088ab <copyout>
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
80100fb6:	e8 f0 78 00 00       	call   801088ab <copyout>
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
80101004:	e8 8b 47 00 00       	call   80105794 <safestrcpy>
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
80101047:	e8 49 71 00 00       	call   80108195 <switchuvm>
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
8010106e:	e8 f9 7d 00 00       	call   80108e6c <mencrypt>
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
8010108b:	e8 c0 75 00 00       	call   80108650 <freevm>
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
801010cb:	e8 80 75 00 00       	call   80108650 <freevm>
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
80101100:	68 6d 94 10 80       	push   $0x8010946d
80101105:	68 60 20 11 80       	push   $0x80112060
8010110a:	e8 a5 41 00 00       	call   801052b4 <initlock>
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
80101127:	e8 ae 41 00 00       	call   801052da <acquire>
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
80101154:	e8 f3 41 00 00       	call   8010534c <release>
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
80101177:	e8 d0 41 00 00       	call   8010534c <release>
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
80101198:	e8 3d 41 00 00       	call   801052da <acquire>
8010119d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801011a0:	8b 45 08             	mov    0x8(%ebp),%eax
801011a3:	8b 40 04             	mov    0x4(%eax),%eax
801011a6:	85 c0                	test   %eax,%eax
801011a8:	7f 0d                	jg     801011b7 <filedup+0x31>
    panic("filedup");
801011aa:	83 ec 0c             	sub    $0xc,%esp
801011ad:	68 74 94 10 80       	push   $0x80109474
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
801011ce:	e8 79 41 00 00       	call   8010534c <release>
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
801011ed:	e8 e8 40 00 00       	call   801052da <acquire>
801011f2:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801011f5:	8b 45 08             	mov    0x8(%ebp),%eax
801011f8:	8b 40 04             	mov    0x4(%eax),%eax
801011fb:	85 c0                	test   %eax,%eax
801011fd:	7f 0d                	jg     8010120c <fileclose+0x31>
    panic("fileclose");
801011ff:	83 ec 0c             	sub    $0xc,%esp
80101202:	68 7c 94 10 80       	push   $0x8010947c
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
8010122d:	e8 1a 41 00 00       	call   8010534c <release>
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
8010127b:	e8 cc 40 00 00       	call   8010534c <release>
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
801013d2:	68 86 94 10 80       	push   $0x80109486
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
801014d9:	68 8f 94 10 80       	push   $0x8010948f
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
8010150f:	68 9f 94 10 80       	push   $0x8010949f
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
8010154b:	e8 f0 40 00 00       	call   80105640 <memmove>
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
80101595:	e8 df 3f 00 00       	call   80105579 <memset>
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
80101700:	68 ac 94 10 80       	push   $0x801094ac
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
80101784:	68 c2 94 10 80       	push   $0x801094c2
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
801017ec:	68 d5 94 10 80       	push   $0x801094d5
801017f1:	68 80 2a 11 80       	push   $0x80112a80
801017f6:	e8 b9 3a 00 00       	call   801052b4 <initlock>
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
80101822:	68 dc 94 10 80       	push   $0x801094dc
80101827:	50                   	push   %eax
80101828:	e8 f4 38 00 00       	call   80105121 <initsleeplock>
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
80101881:	68 e4 94 10 80       	push   $0x801094e4
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
801018fe:	e8 76 3c 00 00       	call   80105579 <memset>
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
80101966:	68 37 95 10 80       	push   $0x80109537
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
80101a10:	e8 2b 3c 00 00       	call   80105640 <memmove>
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
80101a49:	e8 8c 38 00 00       	call   801052da <acquire>
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
80101a97:	e8 b0 38 00 00       	call   8010534c <release>
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
80101ad3:	68 49 95 10 80       	push   $0x80109549
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
80101b10:	e8 37 38 00 00       	call   8010534c <release>
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
80101b2f:	e8 a6 37 00 00       	call   801052da <acquire>
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
80101b4e:	e8 f9 37 00 00       	call   8010534c <release>
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
80101b78:	68 59 95 10 80       	push   $0x80109559
80101b7d:	e8 86 ea ff ff       	call   80100608 <panic>

  acquiresleep(&ip->lock);
80101b82:	8b 45 08             	mov    0x8(%ebp),%eax
80101b85:	83 c0 0c             	add    $0xc,%eax
80101b88:	83 ec 0c             	sub    $0xc,%esp
80101b8b:	50                   	push   %eax
80101b8c:	e8 d0 35 00 00       	call   80105161 <acquiresleep>
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
80101c36:	e8 05 3a 00 00       	call   80105640 <memmove>
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
80101c65:	68 5f 95 10 80       	push   $0x8010955f
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
80101c8c:	e8 8a 35 00 00       	call   8010521b <holdingsleep>
80101c91:	83 c4 10             	add    $0x10,%esp
80101c94:	85 c0                	test   %eax,%eax
80101c96:	74 0a                	je     80101ca2 <iunlock+0x30>
80101c98:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9b:	8b 40 08             	mov    0x8(%eax),%eax
80101c9e:	85 c0                	test   %eax,%eax
80101ca0:	7f 0d                	jg     80101caf <iunlock+0x3d>
    panic("iunlock");
80101ca2:	83 ec 0c             	sub    $0xc,%esp
80101ca5:	68 6e 95 10 80       	push   $0x8010956e
80101caa:	e8 59 e9 ff ff       	call   80100608 <panic>

  releasesleep(&ip->lock);
80101caf:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb2:	83 c0 0c             	add    $0xc,%eax
80101cb5:	83 ec 0c             	sub    $0xc,%esp
80101cb8:	50                   	push   %eax
80101cb9:	e8 0b 35 00 00       	call   801051c9 <releasesleep>
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
80101cd8:	e8 84 34 00 00       	call   80105161 <acquiresleep>
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
80101cfe:	e8 d7 35 00 00       	call   801052da <acquire>
80101d03:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101d06:	8b 45 08             	mov    0x8(%ebp),%eax
80101d09:	8b 40 08             	mov    0x8(%eax),%eax
80101d0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101d0f:	83 ec 0c             	sub    $0xc,%esp
80101d12:	68 80 2a 11 80       	push   $0x80112a80
80101d17:	e8 30 36 00 00       	call   8010534c <release>
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
80101d5e:	e8 66 34 00 00       	call   801051c9 <releasesleep>
80101d63:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101d66:	83 ec 0c             	sub    $0xc,%esp
80101d69:	68 80 2a 11 80       	push   $0x80112a80
80101d6e:	e8 67 35 00 00       	call   801052da <acquire>
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
80101d8d:	e8 ba 35 00 00       	call   8010534c <release>
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
80101ed9:	68 76 95 10 80       	push   $0x80109576
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
80102183:	e8 b8 34 00 00       	call   80105640 <memmove>
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
801022d7:	e8 64 33 00 00       	call   80105640 <memmove>
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
8010235b:	e8 7e 33 00 00       	call   801056de <strncmp>
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
8010237f:	68 89 95 10 80       	push   $0x80109589
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
801023ae:	68 9b 95 10 80       	push   $0x8010959b
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
80102487:	68 aa 95 10 80       	push   $0x801095aa
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
801024c2:	e8 71 32 00 00       	call   80105738 <strncpy>
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
801024ee:	68 b7 95 10 80       	push   $0x801095b7
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
80102564:	e8 d7 30 00 00       	call   80105640 <memmove>
80102569:	83 c4 10             	add    $0x10,%esp
8010256c:	eb 26                	jmp    80102594 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010256e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102571:	83 ec 04             	sub    $0x4,%esp
80102574:	50                   	push   %eax
80102575:	ff 75 f4             	pushl  -0xc(%ebp)
80102578:	ff 75 0c             	pushl  0xc(%ebp)
8010257b:	e8 c0 30 00 00       	call   80105640 <memmove>
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
801027e5:	68 bf 95 10 80       	push   $0x801095bf
801027ea:	68 00 c6 10 80       	push   $0x8010c600
801027ef:	e8 c0 2a 00 00       	call   801052b4 <initlock>
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
80102890:	68 c3 95 10 80       	push   $0x801095c3
80102895:	e8 6e dd ff ff       	call   80100608 <panic>
  if(b->blockno >= FSSIZE)
8010289a:	8b 45 08             	mov    0x8(%ebp),%eax
8010289d:	8b 40 08             	mov    0x8(%eax),%eax
801028a0:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801028a5:	76 0d                	jbe    801028b4 <idestart+0x37>
    panic("incorrect blockno");
801028a7:	83 ec 0c             	sub    $0xc,%esp
801028aa:	68 cc 95 10 80       	push   $0x801095cc
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
801028fd:	68 c3 95 10 80       	push   $0x801095c3
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
80102a25:	e8 b0 28 00 00       	call   801052da <acquire>
80102a2a:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
80102a2d:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102a32:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a35:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102a39:	75 15                	jne    80102a50 <ideintr+0x3d>
    release(&idelock);
80102a3b:	83 ec 0c             	sub    $0xc,%esp
80102a3e:	68 00 c6 10 80       	push   $0x8010c600
80102a43:	e8 04 29 00 00       	call   8010534c <release>
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
80102ab8:	e8 9d 24 00 00       	call   80104f5a <wakeup>
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
80102ae2:	e8 65 28 00 00       	call   8010534c <release>
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
80102b00:	e8 16 27 00 00       	call   8010521b <holdingsleep>
80102b05:	83 c4 10             	add    $0x10,%esp
80102b08:	85 c0                	test   %eax,%eax
80102b0a:	75 0d                	jne    80102b19 <iderw+0x2d>
    panic("iderw: buf not locked");
80102b0c:	83 ec 0c             	sub    $0xc,%esp
80102b0f:	68 de 95 10 80       	push   $0x801095de
80102b14:	e8 ef da ff ff       	call   80100608 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102b19:	8b 45 08             	mov    0x8(%ebp),%eax
80102b1c:	8b 00                	mov    (%eax),%eax
80102b1e:	83 e0 06             	and    $0x6,%eax
80102b21:	83 f8 02             	cmp    $0x2,%eax
80102b24:	75 0d                	jne    80102b33 <iderw+0x47>
    panic("iderw: nothing to do");
80102b26:	83 ec 0c             	sub    $0xc,%esp
80102b29:	68 f4 95 10 80       	push   $0x801095f4
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
80102b49:	68 09 96 10 80       	push   $0x80109609
80102b4e:	e8 b5 da ff ff       	call   80100608 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102b53:	83 ec 0c             	sub    $0xc,%esp
80102b56:	68 00 c6 10 80       	push   $0x8010c600
80102b5b:	e8 7a 27 00 00       	call   801052da <acquire>
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
80102bb7:	e8 ac 22 00 00       	call   80104e68 <sleep>
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
80102bd4:	e8 73 27 00 00       	call   8010534c <release>
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
80102c64:	68 28 96 10 80       	push   $0x80109628
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
80102d13:	68 5c 96 10 80       	push   $0x8010965c
80102d18:	68 e0 46 11 80       	push   $0x801146e0
80102d1d:	e8 92 25 00 00       	call   801052b4 <initlock>
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
80102dde:	68 61 96 10 80       	push   $0x80109661
80102de3:	e8 20 d8 ff ff       	call   80100608 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102de8:	83 ec 04             	sub    $0x4,%esp
80102deb:	68 00 10 00 00       	push   $0x1000
80102df0:	6a 01                	push   $0x1
80102df2:	ff 75 08             	pushl  0x8(%ebp)
80102df5:	e8 7f 27 00 00       	call   80105579 <memset>
80102dfa:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102dfd:	a1 14 47 11 80       	mov    0x80114714,%eax
80102e02:	85 c0                	test   %eax,%eax
80102e04:	74 10                	je     80102e16 <kfree+0x69>
    acquire(&kmem.lock);
80102e06:	83 ec 0c             	sub    $0xc,%esp
80102e09:	68 e0 46 11 80       	push   $0x801146e0
80102e0e:	e8 c7 24 00 00       	call   801052da <acquire>
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
80102e40:	e8 07 25 00 00       	call   8010534c <release>
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
80102e66:	e8 6f 24 00 00       	call   801052da <acquire>
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
80102e97:	e8 b0 24 00 00       	call   8010534c <release>
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
80102eb8:	68 68 96 10 80       	push   $0x80109668
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
80103412:	e8 cd 21 00 00       	call   801055e4 <memcmp>
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
8010352a:	68 88 96 10 80       	push   $0x80109688
8010352f:	68 20 47 11 80       	push   $0x80114720
80103534:	e8 7b 1d 00 00       	call   801052b4 <initlock>
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
801035e3:	e8 58 20 00 00       	call   80105640 <memmove>
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
80103762:	e8 73 1b 00 00       	call   801052da <acquire>
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
80103780:	e8 e3 16 00 00       	call   80104e68 <sleep>
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
801037b5:	e8 ae 16 00 00       	call   80104e68 <sleep>
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
801037d4:	e8 73 1b 00 00       	call   8010534c <release>
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
801037f9:	e8 dc 1a 00 00       	call   801052da <acquire>
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
8010381a:	68 8c 96 10 80       	push   $0x8010968c
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
80103848:	e8 0d 17 00 00       	call   80104f5a <wakeup>
8010384d:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103850:	83 ec 0c             	sub    $0xc,%esp
80103853:	68 20 47 11 80       	push   $0x80114720
80103858:	e8 ef 1a 00 00       	call   8010534c <release>
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
80103873:	e8 62 1a 00 00       	call   801052da <acquire>
80103878:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010387b:	c7 05 60 47 11 80 00 	movl   $0x0,0x80114760
80103882:	00 00 00 
    wakeup(&log);
80103885:	83 ec 0c             	sub    $0xc,%esp
80103888:	68 20 47 11 80       	push   $0x80114720
8010388d:	e8 c8 16 00 00       	call   80104f5a <wakeup>
80103892:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103895:	83 ec 0c             	sub    $0xc,%esp
80103898:	68 20 47 11 80       	push   $0x80114720
8010389d:	e8 aa 1a 00 00       	call   8010534c <release>
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
8010391d:	e8 1e 1d 00 00       	call   80105640 <memmove>
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
801039c2:	68 9b 96 10 80       	push   $0x8010969b
801039c7:	e8 3c cc ff ff       	call   80100608 <panic>
  if (log.outstanding < 1)
801039cc:	a1 5c 47 11 80       	mov    0x8011475c,%eax
801039d1:	85 c0                	test   %eax,%eax
801039d3:	7f 0d                	jg     801039e2 <log_write+0x49>
    panic("log_write outside of trans");
801039d5:	83 ec 0c             	sub    $0xc,%esp
801039d8:	68 b1 96 10 80       	push   $0x801096b1
801039dd:	e8 26 cc ff ff       	call   80100608 <panic>

  acquire(&log.lock);
801039e2:	83 ec 0c             	sub    $0xc,%esp
801039e5:	68 20 47 11 80       	push   $0x80114720
801039ea:	e8 eb 18 00 00       	call   801052da <acquire>
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
80103a68:	e8 df 18 00 00       	call   8010534c <release>
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
80103ab7:	e8 a0 46 00 00       	call   8010815c <kvmalloc>
  mpinit();        // detect other processors
80103abc:	e8 d9 03 00 00       	call   80103e9a <mpinit>
  lapicinit();     // interrupt controller
80103ac1:	e8 f5 f5 ff ff       	call   801030bb <lapicinit>
  seginit();       // segment descriptors
80103ac6:	e8 49 41 00 00       	call   80107c14 <seginit>
  picinit();       // disable pic
80103acb:	e8 35 05 00 00       	call   80104005 <picinit>
  ioapicinit();    // another interrupt controller
80103ad0:	e8 44 f1 ff ff       	call   80102c19 <ioapicinit>
  consoleinit();   // console hardware
80103ad5:	e8 07 d1 ff ff       	call   80100be1 <consoleinit>
  uartinit();      // serial port
80103ada:	e8 be 34 00 00       	call   80106f9d <uartinit>
  pinit();         // process table
80103adf:	e8 6e 09 00 00       	call   80104452 <pinit>
  tvinit();        // trap vectors
80103ae4:	e8 4c 30 00 00       	call   80106b35 <tvinit>
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
80103b26:	e8 4d 46 00 00       	call   80108178 <switchkvm>
  seginit();
80103b2b:	e8 e4 40 00 00       	call   80107c14 <seginit>
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
80103b56:	68 cc 96 10 80       	push   $0x801096cc
80103b5b:	e8 b8 c8 ff ff       	call   80100418 <cprintf>
80103b60:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103b63:	e8 47 31 00 00       	call   80106caf <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103b68:	e8 26 09 00 00       	call   80104493 <mycpu>
80103b6d:	05 a0 00 00 00       	add    $0xa0,%eax
80103b72:	83 ec 08             	sub    $0x8,%esp
80103b75:	6a 01                	push   $0x1
80103b77:	50                   	push   %eax
80103b78:	e8 f6 fe ff ff       	call   80103a73 <xchg>
80103b7d:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103b80:	e8 df 10 00 00       	call   80104c64 <scheduler>

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
80103ba7:	e8 94 1a 00 00       	call   80105640 <memmove>
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
80103cf5:	68 e0 96 10 80       	push   $0x801096e0
80103cfa:	ff 75 f4             	pushl  -0xc(%ebp)
80103cfd:	e8 e2 18 00 00       	call   801055e4 <memcmp>
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
80103e31:	68 e5 96 10 80       	push   $0x801096e5
80103e36:	ff 75 f0             	pushl  -0x10(%ebp)
80103e39:	e8 a6 17 00 00       	call   801055e4 <memcmp>
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
80103ebf:	68 ea 96 10 80       	push   $0x801096ea
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
80103f9c:	68 04 97 10 80       	push   $0x80109704
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
801040ce:	68 23 97 10 80       	push   $0x80109723
801040d3:	50                   	push   %eax
801040d4:	e8 db 11 00 00       	call   801052b4 <initlock>
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
80104197:	e8 3e 11 00 00       	call   801052da <acquire>
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
801041be:	e8 97 0d 00 00       	call   80104f5a <wakeup>
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
801041e1:	e8 74 0d 00 00       	call   80104f5a <wakeup>
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
8010420a:	e8 3d 11 00 00       	call   8010534c <release>
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
80104229:	e8 1e 11 00 00       	call   8010534c <release>
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
80104247:	e8 8e 10 00 00       	call   801052da <acquire>
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
8010427b:	e8 cc 10 00 00       	call   8010534c <release>
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
80104299:	e8 bc 0c 00 00       	call   80104f5a <wakeup>
8010429e:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801042a1:	8b 45 08             	mov    0x8(%ebp),%eax
801042a4:	8b 55 08             	mov    0x8(%ebp),%edx
801042a7:	81 c2 38 02 00 00    	add    $0x238,%edx
801042ad:	83 ec 08             	sub    $0x8,%esp
801042b0:	50                   	push   %eax
801042b1:	52                   	push   %edx
801042b2:	e8 b1 0b 00 00       	call   80104e68 <sleep>
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
8010431c:	e8 39 0c 00 00       	call   80104f5a <wakeup>
80104321:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104324:	8b 45 08             	mov    0x8(%ebp),%eax
80104327:	83 ec 0c             	sub    $0xc,%esp
8010432a:	50                   	push   %eax
8010432b:	e8 1c 10 00 00       	call   8010534c <release>
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
8010434c:	e8 89 0f 00 00       	call   801052da <acquire>
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
80104369:	e8 de 0f 00 00       	call   8010534c <release>
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
8010438c:	e8 d7 0a 00 00       	call   80104e68 <sleep>
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
8010441f:	e8 36 0b 00 00       	call   80104f5a <wakeup>
80104424:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104427:	8b 45 08             	mov    0x8(%ebp),%eax
8010442a:	83 ec 0c             	sub    $0xc,%esp
8010442d:	50                   	push   %eax
8010442e:	e8 19 0f 00 00       	call   8010534c <release>
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
8010445f:	68 28 97 10 80       	push   $0x80109728
80104464:	68 c0 4d 11 80       	push   $0x80114dc0
80104469:	e8 46 0e 00 00       	call   801052b4 <initlock>
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
801044ae:	68 30 97 10 80       	push   $0x80109730
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
80104503:	68 56 97 10 80       	push   $0x80109756
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
80104519:	e8 48 0f 00 00       	call   80105466 <pushcli>
  c = mycpu();
8010451e:	e8 70 ff ff ff       	call   80104493 <mycpu>
80104523:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80104526:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104529:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010452f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80104532:	e8 80 0f 00 00       	call   801054b7 <popcli>
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
8010454e:	e8 87 0d 00 00       	call   801052da <acquire>
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
80104581:	e8 c6 0d 00 00       	call   8010534c <release>
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
801045be:	e8 89 0d 00 00       	call   8010534c <release>
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
8010460b:	ba ef 6a 10 80       	mov    $0x80106aef,%edx
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
80104630:	e8 44 0f 00 00       	call   80105579 <memset>
80104635:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104638:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010463b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010463e:	ba 1e 4e 10 80       	mov    $0x80104e1e,%edx
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
80104665:	e8 55 3a 00 00       	call   801080bf <setupkvm>
8010466a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010466d:	89 42 04             	mov    %eax,0x4(%edx)
80104670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104673:	8b 40 04             	mov    0x4(%eax),%eax
80104676:	85 c0                	test   %eax,%eax
80104678:	75 0d                	jne    80104687 <userinit+0x3c>
    panic("userinit: out of memory?");
8010467a:	83 ec 0c             	sub    $0xc,%esp
8010467d:	68 66 97 10 80       	push   $0x80109766
80104682:	e8 81 bf ff ff       	call   80100608 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104687:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010468c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010468f:	8b 40 04             	mov    0x4(%eax),%eax
80104692:	83 ec 04             	sub    $0x4,%esp
80104695:	52                   	push   %edx
80104696:	68 e0 c4 10 80       	push   $0x8010c4e0
8010469b:	50                   	push   %eax
8010469c:	e8 97 3c 00 00       	call   80108338 <inituvm>
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
801046bb:	e8 b9 0e 00 00       	call   80105579 <memset>
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
80104735:	68 7f 97 10 80       	push   $0x8010977f
8010473a:	50                   	push   %eax
8010473b:	e8 54 10 00 00       	call   80105794 <safestrcpy>
80104740:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104743:	83 ec 0c             	sub    $0xc,%esp
80104746:	68 88 97 10 80       	push   $0x80109788
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
80104761:	e8 74 0b 00 00       	call   801052da <acquire>
80104766:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80104769:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010476c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104773:	83 ec 0c             	sub    $0xc,%esp
80104776:	68 c0 4d 11 80       	push   $0x80114dc0
8010477b:	e8 cc 0b 00 00       	call   8010534c <release>
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
80104795:	89 45 e8             	mov    %eax,-0x18(%ebp)

  sz = curproc->sz;
80104798:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010479b:	8b 00                	mov    (%eax),%eax
8010479d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801047a0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801047a4:	7e 61                	jle    80104807 <growproc+0x81>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801047a6:	8b 55 08             	mov    0x8(%ebp),%edx
801047a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ac:	01 c2                	add    %eax,%edx
801047ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
801047b1:	8b 40 04             	mov    0x4(%eax),%eax
801047b4:	83 ec 04             	sub    $0x4,%esp
801047b7:	52                   	push   %edx
801047b8:	ff 75 f4             	pushl  -0xc(%ebp)
801047bb:	50                   	push   %eax
801047bc:	e8 bc 3c 00 00       	call   8010847d <allocuvm>
801047c1:	83 c4 10             	add    $0x10,%esp
801047c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801047c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047cb:	75 0a                	jne    801047d7 <growproc+0x51>
      return -1;
801047cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047d2:	e9 c0 00 00 00       	jmp    80104897 <growproc+0x111>
   
   
    uint a;
    a = 0;
801047d7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (; a < sz + n; a += PGSIZE){
801047de:	eb 18                	jmp    801047f8 <growproc+0x72>
      mencrypt((char*)a, 1);
801047e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047e3:	83 ec 08             	sub    $0x8,%esp
801047e6:	6a 01                	push   $0x1
801047e8:	50                   	push   %eax
801047e9:	e8 7e 46 00 00       	call   80108e6c <mencrypt>
801047ee:	83 c4 10             	add    $0x10,%esp
    for (; a < sz + n; a += PGSIZE){
801047f1:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
801047f8:	8b 55 08             	mov    0x8(%ebp),%edx
801047fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047fe:	01 d0                	add    %edx,%eax
80104800:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80104803:	72 db                	jb     801047e0 <growproc+0x5a>
80104805:	eb 75                	jmp    8010487c <growproc+0xf6>
  if (sz%PGSIZE)
    t++;
  mencrypt(0,t-2);
  mencrypt((char*)((t-1)*PGSIZE),1);
*/
  } else if(n < 0){
80104807:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010480b:	79 6f                	jns    8010487c <growproc+0xf6>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0){
8010480d:	8b 55 08             	mov    0x8(%ebp),%edx
80104810:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104813:	01 c2                	add    %eax,%edx
80104815:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104818:	8b 40 04             	mov    0x4(%eax),%eax
8010481b:	83 ec 04             	sub    $0x4,%esp
8010481e:	52                   	push   %edx
8010481f:	ff 75 f4             	pushl  -0xc(%ebp)
80104822:	50                   	push   %eax
80104823:	e8 5e 3d 00 00       	call   80108586 <deallocuvm>
80104828:	83 c4 10             	add    $0x10,%esp
8010482b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010482e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104832:	75 41                	jne    80104875 <growproc+0xef>
      for(int i = 0; i < CLOCKSIZE; i++){
80104834:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010483b:	eb 32                	jmp    8010486f <growproc+0xe9>
        if(!not_in_queue((char*)sz + i*PGSIZE))
8010483d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104840:	c1 e0 0c             	shl    $0xc,%eax
80104843:	89 c2                	mov    %eax,%edx
80104845:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104848:	01 d0                	add    %edx,%eax
8010484a:	83 ec 0c             	sub    $0xc,%esp
8010484d:	50                   	push   %eax
8010484e:	e8 de 41 00 00       	call   80108a31 <not_in_queue>
80104853:	83 c4 10             	add    $0x10,%esp
80104856:	85 c0                	test   %eax,%eax
80104858:	75 11                	jne    8010486b <growproc+0xe5>
          curproc->clock[i] = 0;
8010485a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010485d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104860:	83 c2 1c             	add    $0x1c,%edx
80104863:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
8010486a:	00 
      for(int i = 0; i < CLOCKSIZE; i++){
8010486b:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010486f:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80104873:	7e c8                	jle    8010483d <growproc+0xb7>
      }
    }
      return -1;
80104875:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010487a:	eb 1b                	jmp    80104897 <growproc+0x111>
  }
  curproc->sz = sz;
8010487c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010487f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104882:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80104884:	83 ec 0c             	sub    $0xc,%esp
80104887:	ff 75 e8             	pushl  -0x18(%ebp)
8010488a:	e8 06 39 00 00       	call   80108195 <switchuvm>
8010488f:	83 c4 10             	add    $0x10,%esp
  return 0;
80104892:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104897:	c9                   	leave  
80104898:	c3                   	ret    

80104899 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104899:	f3 0f 1e fb          	endbr32 
8010489d:	55                   	push   %ebp
8010489e:	89 e5                	mov    %esp,%ebp
801048a0:	57                   	push   %edi
801048a1:	56                   	push   %esi
801048a2:	53                   	push   %ebx
801048a3:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
801048a6:	e8 64 fc ff ff       	call   8010450f <myproc>
801048ab:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
801048ae:	e8 89 fc ff ff       	call   8010453c <allocproc>
801048b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
801048b6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801048ba:	75 0a                	jne    801048c6 <fork+0x2d>
    return -1;
801048bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048c1:	e9 48 01 00 00       	jmp    80104a0e <fork+0x175>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801048c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048c9:	8b 10                	mov    (%eax),%edx
801048cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048ce:	8b 40 04             	mov    0x4(%eax),%eax
801048d1:	83 ec 08             	sub    $0x8,%esp
801048d4:	52                   	push   %edx
801048d5:	50                   	push   %eax
801048d6:	e8 59 3e 00 00       	call   80108734 <copyuvm>
801048db:	83 c4 10             	add    $0x10,%esp
801048de:	8b 55 dc             	mov    -0x24(%ebp),%edx
801048e1:	89 42 04             	mov    %eax,0x4(%edx)
801048e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048e7:	8b 40 04             	mov    0x4(%eax),%eax
801048ea:	85 c0                	test   %eax,%eax
801048ec:	75 30                	jne    8010491e <fork+0x85>
    kfree(np->kstack);
801048ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048f1:	8b 40 08             	mov    0x8(%eax),%eax
801048f4:	83 ec 0c             	sub    $0xc,%esp
801048f7:	50                   	push   %eax
801048f8:	e8 b0 e4 ff ff       	call   80102dad <kfree>
801048fd:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104900:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104903:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
8010490a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010490d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104914:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104919:	e9 f0 00 00 00       	jmp    80104a0e <fork+0x175>
  }
  np->sz = curproc->sz;
8010491e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104921:	8b 10                	mov    (%eax),%edx
80104923:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104926:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80104928:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010492b:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010492e:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80104931:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104934:	8b 48 18             	mov    0x18(%eax),%ecx
80104937:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010493a:	8b 40 18             	mov    0x18(%eax),%eax
8010493d:	89 c2                	mov    %eax,%edx
8010493f:	89 cb                	mov    %ecx,%ebx
80104941:	b8 13 00 00 00       	mov    $0x13,%eax
80104946:	89 d7                	mov    %edx,%edi
80104948:	89 de                	mov    %ebx,%esi
8010494a:	89 c1                	mov    %eax,%ecx
8010494c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010494e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104951:	8b 40 18             	mov    0x18(%eax),%eax
80104954:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010495b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104962:	eb 3b                	jmp    8010499f <fork+0x106>
    if(curproc->ofile[i])
80104964:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104967:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010496a:	83 c2 08             	add    $0x8,%edx
8010496d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104971:	85 c0                	test   %eax,%eax
80104973:	74 26                	je     8010499b <fork+0x102>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104975:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104978:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010497b:	83 c2 08             	add    $0x8,%edx
8010497e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104982:	83 ec 0c             	sub    $0xc,%esp
80104985:	50                   	push   %eax
80104986:	e8 fb c7 ff ff       	call   80101186 <filedup>
8010498b:	83 c4 10             	add    $0x10,%esp
8010498e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104991:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104994:	83 c1 08             	add    $0x8,%ecx
80104997:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
8010499b:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010499f:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801049a3:	7e bf                	jle    80104964 <fork+0xcb>
  np->cwd = idup(curproc->cwd);
801049a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049a8:	8b 40 68             	mov    0x68(%eax),%eax
801049ab:	83 ec 0c             	sub    $0xc,%esp
801049ae:	50                   	push   %eax
801049af:	e8 69 d1 ff ff       	call   80101b1d <idup>
801049b4:	83 c4 10             	add    $0x10,%esp
801049b7:	8b 55 dc             	mov    -0x24(%ebp),%edx
801049ba:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801049bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049c0:	8d 50 6c             	lea    0x6c(%eax),%edx
801049c3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049c6:	83 c0 6c             	add    $0x6c,%eax
801049c9:	83 ec 04             	sub    $0x4,%esp
801049cc:	6a 10                	push   $0x10
801049ce:	52                   	push   %edx
801049cf:	50                   	push   %eax
801049d0:	e8 bf 0d 00 00       	call   80105794 <safestrcpy>
801049d5:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
801049d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049db:	8b 40 10             	mov    0x10(%eax),%eax
801049de:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
801049e1:	83 ec 0c             	sub    $0xc,%esp
801049e4:	68 c0 4d 11 80       	push   $0x80114dc0
801049e9:	e8 ec 08 00 00       	call   801052da <acquire>
801049ee:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
801049f1:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049f4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801049fb:	83 ec 0c             	sub    $0xc,%esp
801049fe:	68 c0 4d 11 80       	push   $0x80114dc0
80104a03:	e8 44 09 00 00       	call   8010534c <release>
80104a08:	83 c4 10             	add    $0x10,%esp

  return pid;
80104a0b:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104a0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104a11:	5b                   	pop    %ebx
80104a12:	5e                   	pop    %esi
80104a13:	5f                   	pop    %edi
80104a14:	5d                   	pop    %ebp
80104a15:	c3                   	ret    

80104a16 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104a16:	f3 0f 1e fb          	endbr32 
80104a1a:	55                   	push   %ebp
80104a1b:	89 e5                	mov    %esp,%ebp
80104a1d:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104a20:	e8 ea fa ff ff       	call   8010450f <myproc>
80104a25:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104a28:	a1 40 c6 10 80       	mov    0x8010c640,%eax
80104a2d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104a30:	75 0d                	jne    80104a3f <exit+0x29>
    panic("init exiting");
80104a32:	83 ec 0c             	sub    $0xc,%esp
80104a35:	68 8a 97 10 80       	push   $0x8010978a
80104a3a:	e8 c9 bb ff ff       	call   80100608 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104a3f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104a46:	eb 3f                	jmp    80104a87 <exit+0x71>
    if(curproc->ofile[fd]){
80104a48:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a4b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a4e:	83 c2 08             	add    $0x8,%edx
80104a51:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a55:	85 c0                	test   %eax,%eax
80104a57:	74 2a                	je     80104a83 <exit+0x6d>
      fileclose(curproc->ofile[fd]);
80104a59:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a5c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a5f:	83 c2 08             	add    $0x8,%edx
80104a62:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a66:	83 ec 0c             	sub    $0xc,%esp
80104a69:	50                   	push   %eax
80104a6a:	e8 6c c7 ff ff       	call   801011db <fileclose>
80104a6f:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104a72:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a75:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a78:	83 c2 08             	add    $0x8,%edx
80104a7b:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104a82:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104a83:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104a87:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104a8b:	7e bb                	jle    80104a48 <exit+0x32>
    }
  }

  begin_op();
80104a8d:	e8 be ec ff ff       	call   80103750 <begin_op>
  iput(curproc->cwd);
80104a92:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a95:	8b 40 68             	mov    0x68(%eax),%eax
80104a98:	83 ec 0c             	sub    $0xc,%esp
80104a9b:	50                   	push   %eax
80104a9c:	e8 23 d2 ff ff       	call   80101cc4 <iput>
80104aa1:	83 c4 10             	add    $0x10,%esp
  end_op();
80104aa4:	e8 37 ed ff ff       	call   801037e0 <end_op>
  curproc->cwd = 0;
80104aa9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104aac:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104ab3:	83 ec 0c             	sub    $0xc,%esp
80104ab6:	68 c0 4d 11 80       	push   $0x80114dc0
80104abb:	e8 1a 08 00 00       	call   801052da <acquire>
80104ac0:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104ac3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ac6:	8b 40 14             	mov    0x14(%eax),%eax
80104ac9:	83 ec 0c             	sub    $0xc,%esp
80104acc:	50                   	push   %eax
80104acd:	e8 41 04 00 00       	call   80104f13 <wakeup1>
80104ad2:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ad5:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104adc:	eb 3a                	jmp    80104b18 <exit+0x102>
    if(p->parent == curproc){
80104ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae1:	8b 40 14             	mov    0x14(%eax),%eax
80104ae4:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104ae7:	75 28                	jne    80104b11 <exit+0xfb>
      p->parent = initproc;
80104ae9:	8b 15 40 c6 10 80    	mov    0x8010c640,%edx
80104aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af2:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af8:	8b 40 0c             	mov    0xc(%eax),%eax
80104afb:	83 f8 05             	cmp    $0x5,%eax
80104afe:	75 11                	jne    80104b11 <exit+0xfb>
        wakeup1(initproc);
80104b00:	a1 40 c6 10 80       	mov    0x8010c640,%eax
80104b05:	83 ec 0c             	sub    $0xc,%esp
80104b08:	50                   	push   %eax
80104b09:	e8 05 04 00 00       	call   80104f13 <wakeup1>
80104b0e:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b11:	81 45 f4 a4 00 00 00 	addl   $0xa4,-0xc(%ebp)
80104b18:	81 7d f4 f4 76 11 80 	cmpl   $0x801176f4,-0xc(%ebp)
80104b1f:	72 bd                	jb     80104ade <exit+0xc8>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104b21:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b24:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104b2b:	e8 f3 01 00 00       	call   80104d23 <sched>
  panic("zombie exit");
80104b30:	83 ec 0c             	sub    $0xc,%esp
80104b33:	68 97 97 10 80       	push   $0x80109797
80104b38:	e8 cb ba ff ff       	call   80100608 <panic>

80104b3d <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104b3d:	f3 0f 1e fb          	endbr32 
80104b41:	55                   	push   %ebp
80104b42:	89 e5                	mov    %esp,%ebp
80104b44:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104b47:	e8 c3 f9 ff ff       	call   8010450f <myproc>
80104b4c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104b4f:	83 ec 0c             	sub    $0xc,%esp
80104b52:	68 c0 4d 11 80       	push   $0x80114dc0
80104b57:	e8 7e 07 00 00       	call   801052da <acquire>
80104b5c:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104b5f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b66:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104b6d:	e9 a4 00 00 00       	jmp    80104c16 <wait+0xd9>
      if(p->parent != curproc)
80104b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b75:	8b 40 14             	mov    0x14(%eax),%eax
80104b78:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104b7b:	0f 85 8d 00 00 00    	jne    80104c0e <wait+0xd1>
        continue;
      havekids = 1;
80104b81:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b8b:	8b 40 0c             	mov    0xc(%eax),%eax
80104b8e:	83 f8 05             	cmp    $0x5,%eax
80104b91:	75 7c                	jne    80104c0f <wait+0xd2>
        // Found one.
        pid = p->pid;
80104b93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b96:	8b 40 10             	mov    0x10(%eax),%eax
80104b99:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b9f:	8b 40 08             	mov    0x8(%eax),%eax
80104ba2:	83 ec 0c             	sub    $0xc,%esp
80104ba5:	50                   	push   %eax
80104ba6:	e8 02 e2 ff ff       	call   80102dad <kfree>
80104bab:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104bb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bbb:	8b 40 04             	mov    0x4(%eax),%eax
80104bbe:	83 ec 0c             	sub    $0xc,%esp
80104bc1:	50                   	push   %eax
80104bc2:	e8 89 3a 00 00       	call   80108650 <freevm>
80104bc7:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104bca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bcd:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd7:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be1:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be8:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104bf9:	83 ec 0c             	sub    $0xc,%esp
80104bfc:	68 c0 4d 11 80       	push   $0x80114dc0
80104c01:	e8 46 07 00 00       	call   8010534c <release>
80104c06:	83 c4 10             	add    $0x10,%esp
        return pid;
80104c09:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104c0c:	eb 54                	jmp    80104c62 <wait+0x125>
        continue;
80104c0e:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c0f:	81 45 f4 a4 00 00 00 	addl   $0xa4,-0xc(%ebp)
80104c16:	81 7d f4 f4 76 11 80 	cmpl   $0x801176f4,-0xc(%ebp)
80104c1d:	0f 82 4f ff ff ff    	jb     80104b72 <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104c23:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c27:	74 0a                	je     80104c33 <wait+0xf6>
80104c29:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c2c:	8b 40 24             	mov    0x24(%eax),%eax
80104c2f:	85 c0                	test   %eax,%eax
80104c31:	74 17                	je     80104c4a <wait+0x10d>
      release(&ptable.lock);
80104c33:	83 ec 0c             	sub    $0xc,%esp
80104c36:	68 c0 4d 11 80       	push   $0x80114dc0
80104c3b:	e8 0c 07 00 00       	call   8010534c <release>
80104c40:	83 c4 10             	add    $0x10,%esp
      return -1;
80104c43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c48:	eb 18                	jmp    80104c62 <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104c4a:	83 ec 08             	sub    $0x8,%esp
80104c4d:	68 c0 4d 11 80       	push   $0x80114dc0
80104c52:	ff 75 ec             	pushl  -0x14(%ebp)
80104c55:	e8 0e 02 00 00       	call   80104e68 <sleep>
80104c5a:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104c5d:	e9 fd fe ff ff       	jmp    80104b5f <wait+0x22>
  }
}
80104c62:	c9                   	leave  
80104c63:	c3                   	ret    

80104c64 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104c64:	f3 0f 1e fb          	endbr32 
80104c68:	55                   	push   %ebp
80104c69:	89 e5                	mov    %esp,%ebp
80104c6b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104c6e:	e8 20 f8 ff ff       	call   80104493 <mycpu>
80104c73:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104c76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c79:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104c80:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104c83:	e8 c3 f7 ff ff       	call   8010444b <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104c88:	83 ec 0c             	sub    $0xc,%esp
80104c8b:	68 c0 4d 11 80       	push   $0x80114dc0
80104c90:	e8 45 06 00 00       	call   801052da <acquire>
80104c95:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c98:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104c9f:	eb 64                	jmp    80104d05 <scheduler+0xa1>
      if(p->state != RUNNABLE)
80104ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ca4:	8b 40 0c             	mov    0xc(%eax),%eax
80104ca7:	83 f8 03             	cmp    $0x3,%eax
80104caa:	75 51                	jne    80104cfd <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104cac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104caf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cb2:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104cb8:	83 ec 0c             	sub    $0xc,%esp
80104cbb:	ff 75 f4             	pushl  -0xc(%ebp)
80104cbe:	e8 d2 34 00 00       	call   80108195 <switchuvm>
80104cc3:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cc9:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104cd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cd3:	8b 40 1c             	mov    0x1c(%eax),%eax
80104cd6:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104cd9:	83 c2 04             	add    $0x4,%edx
80104cdc:	83 ec 08             	sub    $0x8,%esp
80104cdf:	50                   	push   %eax
80104ce0:	52                   	push   %edx
80104ce1:	e8 27 0b 00 00       	call   8010580d <swtch>
80104ce6:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104ce9:	e8 8a 34 00 00       	call   80108178 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104cee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cf1:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104cf8:	00 00 00 
80104cfb:	eb 01                	jmp    80104cfe <scheduler+0x9a>
        continue;
80104cfd:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cfe:	81 45 f4 a4 00 00 00 	addl   $0xa4,-0xc(%ebp)
80104d05:	81 7d f4 f4 76 11 80 	cmpl   $0x801176f4,-0xc(%ebp)
80104d0c:	72 93                	jb     80104ca1 <scheduler+0x3d>
    }
    release(&ptable.lock);
80104d0e:	83 ec 0c             	sub    $0xc,%esp
80104d11:	68 c0 4d 11 80       	push   $0x80114dc0
80104d16:	e8 31 06 00 00       	call   8010534c <release>
80104d1b:	83 c4 10             	add    $0x10,%esp
    sti();
80104d1e:	e9 60 ff ff ff       	jmp    80104c83 <scheduler+0x1f>

80104d23 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104d23:	f3 0f 1e fb          	endbr32 
80104d27:	55                   	push   %ebp
80104d28:	89 e5                	mov    %esp,%ebp
80104d2a:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104d2d:	e8 dd f7 ff ff       	call   8010450f <myproc>
80104d32:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104d35:	83 ec 0c             	sub    $0xc,%esp
80104d38:	68 c0 4d 11 80       	push   $0x80114dc0
80104d3d:	e8 df 06 00 00       	call   80105421 <holding>
80104d42:	83 c4 10             	add    $0x10,%esp
80104d45:	85 c0                	test   %eax,%eax
80104d47:	75 0d                	jne    80104d56 <sched+0x33>
    panic("sched ptable.lock");
80104d49:	83 ec 0c             	sub    $0xc,%esp
80104d4c:	68 a3 97 10 80       	push   $0x801097a3
80104d51:	e8 b2 b8 ff ff       	call   80100608 <panic>
  if(mycpu()->ncli != 1)
80104d56:	e8 38 f7 ff ff       	call   80104493 <mycpu>
80104d5b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d61:	83 f8 01             	cmp    $0x1,%eax
80104d64:	74 0d                	je     80104d73 <sched+0x50>
    panic("sched locks");
80104d66:	83 ec 0c             	sub    $0xc,%esp
80104d69:	68 b5 97 10 80       	push   $0x801097b5
80104d6e:	e8 95 b8 ff ff       	call   80100608 <panic>
  if(p->state == RUNNING)
80104d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d76:	8b 40 0c             	mov    0xc(%eax),%eax
80104d79:	83 f8 04             	cmp    $0x4,%eax
80104d7c:	75 0d                	jne    80104d8b <sched+0x68>
    panic("sched running");
80104d7e:	83 ec 0c             	sub    $0xc,%esp
80104d81:	68 c1 97 10 80       	push   $0x801097c1
80104d86:	e8 7d b8 ff ff       	call   80100608 <panic>
  if(readeflags()&FL_IF)
80104d8b:	e8 ab f6 ff ff       	call   8010443b <readeflags>
80104d90:	25 00 02 00 00       	and    $0x200,%eax
80104d95:	85 c0                	test   %eax,%eax
80104d97:	74 0d                	je     80104da6 <sched+0x83>
    panic("sched interruptible");
80104d99:	83 ec 0c             	sub    $0xc,%esp
80104d9c:	68 cf 97 10 80       	push   $0x801097cf
80104da1:	e8 62 b8 ff ff       	call   80100608 <panic>
  intena = mycpu()->intena;
80104da6:	e8 e8 f6 ff ff       	call   80104493 <mycpu>
80104dab:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104db1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104db4:	e8 da f6 ff ff       	call   80104493 <mycpu>
80104db9:	8b 40 04             	mov    0x4(%eax),%eax
80104dbc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104dbf:	83 c2 1c             	add    $0x1c,%edx
80104dc2:	83 ec 08             	sub    $0x8,%esp
80104dc5:	50                   	push   %eax
80104dc6:	52                   	push   %edx
80104dc7:	e8 41 0a 00 00       	call   8010580d <swtch>
80104dcc:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104dcf:	e8 bf f6 ff ff       	call   80104493 <mycpu>
80104dd4:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104dd7:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104ddd:	90                   	nop
80104dde:	c9                   	leave  
80104ddf:	c3                   	ret    

80104de0 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104de0:	f3 0f 1e fb          	endbr32 
80104de4:	55                   	push   %ebp
80104de5:	89 e5                	mov    %esp,%ebp
80104de7:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104dea:	83 ec 0c             	sub    $0xc,%esp
80104ded:	68 c0 4d 11 80       	push   $0x80114dc0
80104df2:	e8 e3 04 00 00       	call   801052da <acquire>
80104df7:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104dfa:	e8 10 f7 ff ff       	call   8010450f <myproc>
80104dff:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104e06:	e8 18 ff ff ff       	call   80104d23 <sched>
  release(&ptable.lock);
80104e0b:	83 ec 0c             	sub    $0xc,%esp
80104e0e:	68 c0 4d 11 80       	push   $0x80114dc0
80104e13:	e8 34 05 00 00       	call   8010534c <release>
80104e18:	83 c4 10             	add    $0x10,%esp
}
80104e1b:	90                   	nop
80104e1c:	c9                   	leave  
80104e1d:	c3                   	ret    

80104e1e <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104e1e:	f3 0f 1e fb          	endbr32 
80104e22:	55                   	push   %ebp
80104e23:	89 e5                	mov    %esp,%ebp
80104e25:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104e28:	83 ec 0c             	sub    $0xc,%esp
80104e2b:	68 c0 4d 11 80       	push   $0x80114dc0
80104e30:	e8 17 05 00 00       	call   8010534c <release>
80104e35:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104e38:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104e3d:	85 c0                	test   %eax,%eax
80104e3f:	74 24                	je     80104e65 <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104e41:	c7 05 04 c0 10 80 00 	movl   $0x0,0x8010c004
80104e48:	00 00 00 
    iinit(ROOTDEV);
80104e4b:	83 ec 0c             	sub    $0xc,%esp
80104e4e:	6a 01                	push   $0x1
80104e50:	e8 80 c9 ff ff       	call   801017d5 <iinit>
80104e55:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104e58:	83 ec 0c             	sub    $0xc,%esp
80104e5b:	6a 01                	push   $0x1
80104e5d:	e8 bb e6 ff ff       	call   8010351d <initlog>
80104e62:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104e65:	90                   	nop
80104e66:	c9                   	leave  
80104e67:	c3                   	ret    

80104e68 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104e68:	f3 0f 1e fb          	endbr32 
80104e6c:	55                   	push   %ebp
80104e6d:	89 e5                	mov    %esp,%ebp
80104e6f:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104e72:	e8 98 f6 ff ff       	call   8010450f <myproc>
80104e77:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104e7a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e7e:	75 0d                	jne    80104e8d <sleep+0x25>
    panic("sleep");
80104e80:	83 ec 0c             	sub    $0xc,%esp
80104e83:	68 e3 97 10 80       	push   $0x801097e3
80104e88:	e8 7b b7 ff ff       	call   80100608 <panic>

  if(lk == 0)
80104e8d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104e91:	75 0d                	jne    80104ea0 <sleep+0x38>
    panic("sleep without lk");
80104e93:	83 ec 0c             	sub    $0xc,%esp
80104e96:	68 e9 97 10 80       	push   $0x801097e9
80104e9b:	e8 68 b7 ff ff       	call   80100608 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104ea0:	81 7d 0c c0 4d 11 80 	cmpl   $0x80114dc0,0xc(%ebp)
80104ea7:	74 1e                	je     80104ec7 <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104ea9:	83 ec 0c             	sub    $0xc,%esp
80104eac:	68 c0 4d 11 80       	push   $0x80114dc0
80104eb1:	e8 24 04 00 00       	call   801052da <acquire>
80104eb6:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104eb9:	83 ec 0c             	sub    $0xc,%esp
80104ebc:	ff 75 0c             	pushl  0xc(%ebp)
80104ebf:	e8 88 04 00 00       	call   8010534c <release>
80104ec4:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eca:	8b 55 08             	mov    0x8(%ebp),%edx
80104ecd:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104ed0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ed3:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104eda:	e8 44 fe ff ff       	call   80104d23 <sched>

  // Tidy up.
  p->chan = 0;
80104edf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ee2:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104ee9:	81 7d 0c c0 4d 11 80 	cmpl   $0x80114dc0,0xc(%ebp)
80104ef0:	74 1e                	je     80104f10 <sleep+0xa8>
    release(&ptable.lock);
80104ef2:	83 ec 0c             	sub    $0xc,%esp
80104ef5:	68 c0 4d 11 80       	push   $0x80114dc0
80104efa:	e8 4d 04 00 00       	call   8010534c <release>
80104eff:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104f02:	83 ec 0c             	sub    $0xc,%esp
80104f05:	ff 75 0c             	pushl  0xc(%ebp)
80104f08:	e8 cd 03 00 00       	call   801052da <acquire>
80104f0d:	83 c4 10             	add    $0x10,%esp
  }
}
80104f10:	90                   	nop
80104f11:	c9                   	leave  
80104f12:	c3                   	ret    

80104f13 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104f13:	f3 0f 1e fb          	endbr32 
80104f17:	55                   	push   %ebp
80104f18:	89 e5                	mov    %esp,%ebp
80104f1a:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f1d:	c7 45 fc f4 4d 11 80 	movl   $0x80114df4,-0x4(%ebp)
80104f24:	eb 27                	jmp    80104f4d <wakeup1+0x3a>
    if(p->state == SLEEPING && p->chan == chan)
80104f26:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f29:	8b 40 0c             	mov    0xc(%eax),%eax
80104f2c:	83 f8 02             	cmp    $0x2,%eax
80104f2f:	75 15                	jne    80104f46 <wakeup1+0x33>
80104f31:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f34:	8b 40 20             	mov    0x20(%eax),%eax
80104f37:	39 45 08             	cmp    %eax,0x8(%ebp)
80104f3a:	75 0a                	jne    80104f46 <wakeup1+0x33>
      p->state = RUNNABLE;
80104f3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f3f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f46:	81 45 fc a4 00 00 00 	addl   $0xa4,-0x4(%ebp)
80104f4d:	81 7d fc f4 76 11 80 	cmpl   $0x801176f4,-0x4(%ebp)
80104f54:	72 d0                	jb     80104f26 <wakeup1+0x13>
}
80104f56:	90                   	nop
80104f57:	90                   	nop
80104f58:	c9                   	leave  
80104f59:	c3                   	ret    

80104f5a <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104f5a:	f3 0f 1e fb          	endbr32 
80104f5e:	55                   	push   %ebp
80104f5f:	89 e5                	mov    %esp,%ebp
80104f61:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104f64:	83 ec 0c             	sub    $0xc,%esp
80104f67:	68 c0 4d 11 80       	push   $0x80114dc0
80104f6c:	e8 69 03 00 00       	call   801052da <acquire>
80104f71:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104f74:	83 ec 0c             	sub    $0xc,%esp
80104f77:	ff 75 08             	pushl  0x8(%ebp)
80104f7a:	e8 94 ff ff ff       	call   80104f13 <wakeup1>
80104f7f:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104f82:	83 ec 0c             	sub    $0xc,%esp
80104f85:	68 c0 4d 11 80       	push   $0x80114dc0
80104f8a:	e8 bd 03 00 00       	call   8010534c <release>
80104f8f:	83 c4 10             	add    $0x10,%esp
}
80104f92:	90                   	nop
80104f93:	c9                   	leave  
80104f94:	c3                   	ret    

80104f95 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104f95:	f3 0f 1e fb          	endbr32 
80104f99:	55                   	push   %ebp
80104f9a:	89 e5                	mov    %esp,%ebp
80104f9c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104f9f:	83 ec 0c             	sub    $0xc,%esp
80104fa2:	68 c0 4d 11 80       	push   $0x80114dc0
80104fa7:	e8 2e 03 00 00       	call   801052da <acquire>
80104fac:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104faf:	c7 45 f4 f4 4d 11 80 	movl   $0x80114df4,-0xc(%ebp)
80104fb6:	eb 48                	jmp    80105000 <kill+0x6b>
    if(p->pid == pid){
80104fb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fbb:	8b 40 10             	mov    0x10(%eax),%eax
80104fbe:	39 45 08             	cmp    %eax,0x8(%ebp)
80104fc1:	75 36                	jne    80104ff9 <kill+0x64>
      p->killed = 1;
80104fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fc6:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104fcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fd0:	8b 40 0c             	mov    0xc(%eax),%eax
80104fd3:	83 f8 02             	cmp    $0x2,%eax
80104fd6:	75 0a                	jne    80104fe2 <kill+0x4d>
        p->state = RUNNABLE;
80104fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fdb:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104fe2:	83 ec 0c             	sub    $0xc,%esp
80104fe5:	68 c0 4d 11 80       	push   $0x80114dc0
80104fea:	e8 5d 03 00 00       	call   8010534c <release>
80104fef:	83 c4 10             	add    $0x10,%esp
      return 0;
80104ff2:	b8 00 00 00 00       	mov    $0x0,%eax
80104ff7:	eb 25                	jmp    8010501e <kill+0x89>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ff9:	81 45 f4 a4 00 00 00 	addl   $0xa4,-0xc(%ebp)
80105000:	81 7d f4 f4 76 11 80 	cmpl   $0x801176f4,-0xc(%ebp)
80105007:	72 af                	jb     80104fb8 <kill+0x23>
    }
  }
  release(&ptable.lock);
80105009:	83 ec 0c             	sub    $0xc,%esp
8010500c:	68 c0 4d 11 80       	push   $0x80114dc0
80105011:	e8 36 03 00 00       	call   8010534c <release>
80105016:	83 c4 10             	add    $0x10,%esp
  return -1;
80105019:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010501e:	c9                   	leave  
8010501f:	c3                   	ret    

80105020 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105020:	f3 0f 1e fb          	endbr32 
80105024:	55                   	push   %ebp
80105025:	89 e5                	mov    %esp,%ebp
80105027:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010502a:	c7 45 f0 f4 4d 11 80 	movl   $0x80114df4,-0x10(%ebp)
80105031:	e9 da 00 00 00       	jmp    80105110 <procdump+0xf0>
    if(p->state == UNUSED)
80105036:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105039:	8b 40 0c             	mov    0xc(%eax),%eax
8010503c:	85 c0                	test   %eax,%eax
8010503e:	0f 84 c4 00 00 00    	je     80105108 <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105044:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105047:	8b 40 0c             	mov    0xc(%eax),%eax
8010504a:	83 f8 05             	cmp    $0x5,%eax
8010504d:	77 23                	ja     80105072 <procdump+0x52>
8010504f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105052:	8b 40 0c             	mov    0xc(%eax),%eax
80105055:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
8010505c:	85 c0                	test   %eax,%eax
8010505e:	74 12                	je     80105072 <procdump+0x52>
      state = states[p->state];
80105060:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105063:	8b 40 0c             	mov    0xc(%eax),%eax
80105066:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
8010506d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105070:	eb 07                	jmp    80105079 <procdump+0x59>
    else
      state = "???";
80105072:	c7 45 ec fa 97 10 80 	movl   $0x801097fa,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80105079:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010507c:	8d 50 6c             	lea    0x6c(%eax),%edx
8010507f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105082:	8b 40 10             	mov    0x10(%eax),%eax
80105085:	52                   	push   %edx
80105086:	ff 75 ec             	pushl  -0x14(%ebp)
80105089:	50                   	push   %eax
8010508a:	68 fe 97 10 80       	push   $0x801097fe
8010508f:	e8 84 b3 ff ff       	call   80100418 <cprintf>
80105094:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80105097:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010509a:	8b 40 0c             	mov    0xc(%eax),%eax
8010509d:	83 f8 02             	cmp    $0x2,%eax
801050a0:	75 54                	jne    801050f6 <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801050a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050a5:	8b 40 1c             	mov    0x1c(%eax),%eax
801050a8:	8b 40 0c             	mov    0xc(%eax),%eax
801050ab:	83 c0 08             	add    $0x8,%eax
801050ae:	89 c2                	mov    %eax,%edx
801050b0:	83 ec 08             	sub    $0x8,%esp
801050b3:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801050b6:	50                   	push   %eax
801050b7:	52                   	push   %edx
801050b8:	e8 e5 02 00 00       	call   801053a2 <getcallerpcs>
801050bd:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801050c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801050c7:	eb 1c                	jmp    801050e5 <procdump+0xc5>
        cprintf(" %p", pc[i]);
801050c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050cc:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801050d0:	83 ec 08             	sub    $0x8,%esp
801050d3:	50                   	push   %eax
801050d4:	68 07 98 10 80       	push   $0x80109807
801050d9:	e8 3a b3 ff ff       	call   80100418 <cprintf>
801050de:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801050e1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801050e5:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801050e9:	7f 0b                	jg     801050f6 <procdump+0xd6>
801050eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050ee:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801050f2:	85 c0                	test   %eax,%eax
801050f4:	75 d3                	jne    801050c9 <procdump+0xa9>
    }
    cprintf("\n");
801050f6:	83 ec 0c             	sub    $0xc,%esp
801050f9:	68 0b 98 10 80       	push   $0x8010980b
801050fe:	e8 15 b3 ff ff       	call   80100418 <cprintf>
80105103:	83 c4 10             	add    $0x10,%esp
80105106:	eb 01                	jmp    80105109 <procdump+0xe9>
      continue;
80105108:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105109:	81 45 f0 a4 00 00 00 	addl   $0xa4,-0x10(%ebp)
80105110:	81 7d f0 f4 76 11 80 	cmpl   $0x801176f4,-0x10(%ebp)
80105117:	0f 82 19 ff ff ff    	jb     80105036 <procdump+0x16>
  }
}
8010511d:	90                   	nop
8010511e:	90                   	nop
8010511f:	c9                   	leave  
80105120:	c3                   	ret    

80105121 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80105121:	f3 0f 1e fb          	endbr32 
80105125:	55                   	push   %ebp
80105126:	89 e5                	mov    %esp,%ebp
80105128:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
8010512b:	8b 45 08             	mov    0x8(%ebp),%eax
8010512e:	83 c0 04             	add    $0x4,%eax
80105131:	83 ec 08             	sub    $0x8,%esp
80105134:	68 37 98 10 80       	push   $0x80109837
80105139:	50                   	push   %eax
8010513a:	e8 75 01 00 00       	call   801052b4 <initlock>
8010513f:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80105142:	8b 45 08             	mov    0x8(%ebp),%eax
80105145:	8b 55 0c             	mov    0xc(%ebp),%edx
80105148:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
8010514b:	8b 45 08             	mov    0x8(%ebp),%eax
8010514e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105154:	8b 45 08             	mov    0x8(%ebp),%eax
80105157:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
8010515e:	90                   	nop
8010515f:	c9                   	leave  
80105160:	c3                   	ret    

80105161 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80105161:	f3 0f 1e fb          	endbr32 
80105165:	55                   	push   %ebp
80105166:	89 e5                	mov    %esp,%ebp
80105168:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
8010516b:	8b 45 08             	mov    0x8(%ebp),%eax
8010516e:	83 c0 04             	add    $0x4,%eax
80105171:	83 ec 0c             	sub    $0xc,%esp
80105174:	50                   	push   %eax
80105175:	e8 60 01 00 00       	call   801052da <acquire>
8010517a:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
8010517d:	eb 15                	jmp    80105194 <acquiresleep+0x33>
    sleep(lk, &lk->lk);
8010517f:	8b 45 08             	mov    0x8(%ebp),%eax
80105182:	83 c0 04             	add    $0x4,%eax
80105185:	83 ec 08             	sub    $0x8,%esp
80105188:	50                   	push   %eax
80105189:	ff 75 08             	pushl  0x8(%ebp)
8010518c:	e8 d7 fc ff ff       	call   80104e68 <sleep>
80105191:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80105194:	8b 45 08             	mov    0x8(%ebp),%eax
80105197:	8b 00                	mov    (%eax),%eax
80105199:	85 c0                	test   %eax,%eax
8010519b:	75 e2                	jne    8010517f <acquiresleep+0x1e>
  }
  lk->locked = 1;
8010519d:	8b 45 08             	mov    0x8(%ebp),%eax
801051a0:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
801051a6:	e8 64 f3 ff ff       	call   8010450f <myproc>
801051ab:	8b 50 10             	mov    0x10(%eax),%edx
801051ae:	8b 45 08             	mov    0x8(%ebp),%eax
801051b1:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
801051b4:	8b 45 08             	mov    0x8(%ebp),%eax
801051b7:	83 c0 04             	add    $0x4,%eax
801051ba:	83 ec 0c             	sub    $0xc,%esp
801051bd:	50                   	push   %eax
801051be:	e8 89 01 00 00       	call   8010534c <release>
801051c3:	83 c4 10             	add    $0x10,%esp
}
801051c6:	90                   	nop
801051c7:	c9                   	leave  
801051c8:	c3                   	ret    

801051c9 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801051c9:	f3 0f 1e fb          	endbr32 
801051cd:	55                   	push   %ebp
801051ce:	89 e5                	mov    %esp,%ebp
801051d0:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801051d3:	8b 45 08             	mov    0x8(%ebp),%eax
801051d6:	83 c0 04             	add    $0x4,%eax
801051d9:	83 ec 0c             	sub    $0xc,%esp
801051dc:	50                   	push   %eax
801051dd:	e8 f8 00 00 00       	call   801052da <acquire>
801051e2:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
801051e5:	8b 45 08             	mov    0x8(%ebp),%eax
801051e8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801051ee:	8b 45 08             	mov    0x8(%ebp),%eax
801051f1:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
801051f8:	83 ec 0c             	sub    $0xc,%esp
801051fb:	ff 75 08             	pushl  0x8(%ebp)
801051fe:	e8 57 fd ff ff       	call   80104f5a <wakeup>
80105203:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80105206:	8b 45 08             	mov    0x8(%ebp),%eax
80105209:	83 c0 04             	add    $0x4,%eax
8010520c:	83 ec 0c             	sub    $0xc,%esp
8010520f:	50                   	push   %eax
80105210:	e8 37 01 00 00       	call   8010534c <release>
80105215:	83 c4 10             	add    $0x10,%esp
}
80105218:	90                   	nop
80105219:	c9                   	leave  
8010521a:	c3                   	ret    

8010521b <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
8010521b:	f3 0f 1e fb          	endbr32 
8010521f:	55                   	push   %ebp
80105220:	89 e5                	mov    %esp,%ebp
80105222:	53                   	push   %ebx
80105223:	83 ec 14             	sub    $0x14,%esp
  int r;
  
  acquire(&lk->lk);
80105226:	8b 45 08             	mov    0x8(%ebp),%eax
80105229:	83 c0 04             	add    $0x4,%eax
8010522c:	83 ec 0c             	sub    $0xc,%esp
8010522f:	50                   	push   %eax
80105230:	e8 a5 00 00 00       	call   801052da <acquire>
80105235:	83 c4 10             	add    $0x10,%esp
  r = lk->locked && (lk->pid == myproc()->pid);
80105238:	8b 45 08             	mov    0x8(%ebp),%eax
8010523b:	8b 00                	mov    (%eax),%eax
8010523d:	85 c0                	test   %eax,%eax
8010523f:	74 19                	je     8010525a <holdingsleep+0x3f>
80105241:	8b 45 08             	mov    0x8(%ebp),%eax
80105244:	8b 58 3c             	mov    0x3c(%eax),%ebx
80105247:	e8 c3 f2 ff ff       	call   8010450f <myproc>
8010524c:	8b 40 10             	mov    0x10(%eax),%eax
8010524f:	39 c3                	cmp    %eax,%ebx
80105251:	75 07                	jne    8010525a <holdingsleep+0x3f>
80105253:	b8 01 00 00 00       	mov    $0x1,%eax
80105258:	eb 05                	jmp    8010525f <holdingsleep+0x44>
8010525a:	b8 00 00 00 00       	mov    $0x0,%eax
8010525f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80105262:	8b 45 08             	mov    0x8(%ebp),%eax
80105265:	83 c0 04             	add    $0x4,%eax
80105268:	83 ec 0c             	sub    $0xc,%esp
8010526b:	50                   	push   %eax
8010526c:	e8 db 00 00 00       	call   8010534c <release>
80105271:	83 c4 10             	add    $0x10,%esp
  return r;
80105274:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105277:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010527a:	c9                   	leave  
8010527b:	c3                   	ret    

8010527c <readeflags>:
{
8010527c:	55                   	push   %ebp
8010527d:	89 e5                	mov    %esp,%ebp
8010527f:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105282:	9c                   	pushf  
80105283:	58                   	pop    %eax
80105284:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105287:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010528a:	c9                   	leave  
8010528b:	c3                   	ret    

8010528c <cli>:
{
8010528c:	55                   	push   %ebp
8010528d:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010528f:	fa                   	cli    
}
80105290:	90                   	nop
80105291:	5d                   	pop    %ebp
80105292:	c3                   	ret    

80105293 <sti>:
{
80105293:	55                   	push   %ebp
80105294:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105296:	fb                   	sti    
}
80105297:	90                   	nop
80105298:	5d                   	pop    %ebp
80105299:	c3                   	ret    

8010529a <xchg>:
{
8010529a:	55                   	push   %ebp
8010529b:	89 e5                	mov    %esp,%ebp
8010529d:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
801052a0:	8b 55 08             	mov    0x8(%ebp),%edx
801052a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801052a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052a9:	f0 87 02             	lock xchg %eax,(%edx)
801052ac:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
801052af:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801052b2:	c9                   	leave  
801052b3:	c3                   	ret    

801052b4 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801052b4:	f3 0f 1e fb          	endbr32 
801052b8:	55                   	push   %ebp
801052b9:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801052bb:	8b 45 08             	mov    0x8(%ebp),%eax
801052be:	8b 55 0c             	mov    0xc(%ebp),%edx
801052c1:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801052c4:	8b 45 08             	mov    0x8(%ebp),%eax
801052c7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801052cd:	8b 45 08             	mov    0x8(%ebp),%eax
801052d0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801052d7:	90                   	nop
801052d8:	5d                   	pop    %ebp
801052d9:	c3                   	ret    

801052da <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801052da:	f3 0f 1e fb          	endbr32 
801052de:	55                   	push   %ebp
801052df:	89 e5                	mov    %esp,%ebp
801052e1:	53                   	push   %ebx
801052e2:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801052e5:	e8 7c 01 00 00       	call   80105466 <pushcli>
  if(holding(lk))
801052ea:	8b 45 08             	mov    0x8(%ebp),%eax
801052ed:	83 ec 0c             	sub    $0xc,%esp
801052f0:	50                   	push   %eax
801052f1:	e8 2b 01 00 00       	call   80105421 <holding>
801052f6:	83 c4 10             	add    $0x10,%esp
801052f9:	85 c0                	test   %eax,%eax
801052fb:	74 0d                	je     8010530a <acquire+0x30>
    panic("acquire");
801052fd:	83 ec 0c             	sub    $0xc,%esp
80105300:	68 42 98 10 80       	push   $0x80109842
80105305:	e8 fe b2 ff ff       	call   80100608 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
8010530a:	90                   	nop
8010530b:	8b 45 08             	mov    0x8(%ebp),%eax
8010530e:	83 ec 08             	sub    $0x8,%esp
80105311:	6a 01                	push   $0x1
80105313:	50                   	push   %eax
80105314:	e8 81 ff ff ff       	call   8010529a <xchg>
80105319:	83 c4 10             	add    $0x10,%esp
8010531c:	85 c0                	test   %eax,%eax
8010531e:	75 eb                	jne    8010530b <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80105320:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80105325:	8b 5d 08             	mov    0x8(%ebp),%ebx
80105328:	e8 66 f1 ff ff       	call   80104493 <mycpu>
8010532d:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80105330:	8b 45 08             	mov    0x8(%ebp),%eax
80105333:	83 c0 0c             	add    $0xc,%eax
80105336:	83 ec 08             	sub    $0x8,%esp
80105339:	50                   	push   %eax
8010533a:	8d 45 08             	lea    0x8(%ebp),%eax
8010533d:	50                   	push   %eax
8010533e:	e8 5f 00 00 00       	call   801053a2 <getcallerpcs>
80105343:	83 c4 10             	add    $0x10,%esp
}
80105346:	90                   	nop
80105347:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010534a:	c9                   	leave  
8010534b:	c3                   	ret    

8010534c <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
8010534c:	f3 0f 1e fb          	endbr32 
80105350:	55                   	push   %ebp
80105351:	89 e5                	mov    %esp,%ebp
80105353:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105356:	83 ec 0c             	sub    $0xc,%esp
80105359:	ff 75 08             	pushl  0x8(%ebp)
8010535c:	e8 c0 00 00 00       	call   80105421 <holding>
80105361:	83 c4 10             	add    $0x10,%esp
80105364:	85 c0                	test   %eax,%eax
80105366:	75 0d                	jne    80105375 <release+0x29>
    panic("release");
80105368:	83 ec 0c             	sub    $0xc,%esp
8010536b:	68 4a 98 10 80       	push   $0x8010984a
80105370:	e8 93 b2 ff ff       	call   80100608 <panic>

  lk->pcs[0] = 0;
80105375:	8b 45 08             	mov    0x8(%ebp),%eax
80105378:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010537f:	8b 45 08             	mov    0x8(%ebp),%eax
80105382:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80105389:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
8010538e:	8b 45 08             	mov    0x8(%ebp),%eax
80105391:	8b 55 08             	mov    0x8(%ebp),%edx
80105394:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
8010539a:	e8 18 01 00 00       	call   801054b7 <popcli>
}
8010539f:	90                   	nop
801053a0:	c9                   	leave  
801053a1:	c3                   	ret    

801053a2 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801053a2:	f3 0f 1e fb          	endbr32 
801053a6:	55                   	push   %ebp
801053a7:	89 e5                	mov    %esp,%ebp
801053a9:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801053ac:	8b 45 08             	mov    0x8(%ebp),%eax
801053af:	83 e8 08             	sub    $0x8,%eax
801053b2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801053b5:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801053bc:	eb 38                	jmp    801053f6 <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801053be:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801053c2:	74 53                	je     80105417 <getcallerpcs+0x75>
801053c4:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801053cb:	76 4a                	jbe    80105417 <getcallerpcs+0x75>
801053cd:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801053d1:	74 44                	je     80105417 <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
801053d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053d6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801053dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801053e0:	01 c2                	add    %eax,%edx
801053e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053e5:	8b 40 04             	mov    0x4(%eax),%eax
801053e8:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801053ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053ed:	8b 00                	mov    (%eax),%eax
801053ef:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801053f2:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801053f6:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801053fa:	7e c2                	jle    801053be <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
801053fc:	eb 19                	jmp    80105417 <getcallerpcs+0x75>
    pcs[i] = 0;
801053fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105401:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105408:	8b 45 0c             	mov    0xc(%ebp),%eax
8010540b:	01 d0                	add    %edx,%eax
8010540d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80105413:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105417:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010541b:	7e e1                	jle    801053fe <getcallerpcs+0x5c>
}
8010541d:	90                   	nop
8010541e:	90                   	nop
8010541f:	c9                   	leave  
80105420:	c3                   	ret    

80105421 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105421:	f3 0f 1e fb          	endbr32 
80105425:	55                   	push   %ebp
80105426:	89 e5                	mov    %esp,%ebp
80105428:	53                   	push   %ebx
80105429:	83 ec 14             	sub    $0x14,%esp
  int r;
  pushcli();
8010542c:	e8 35 00 00 00       	call   80105466 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80105431:	8b 45 08             	mov    0x8(%ebp),%eax
80105434:	8b 00                	mov    (%eax),%eax
80105436:	85 c0                	test   %eax,%eax
80105438:	74 16                	je     80105450 <holding+0x2f>
8010543a:	8b 45 08             	mov    0x8(%ebp),%eax
8010543d:	8b 58 08             	mov    0x8(%eax),%ebx
80105440:	e8 4e f0 ff ff       	call   80104493 <mycpu>
80105445:	39 c3                	cmp    %eax,%ebx
80105447:	75 07                	jne    80105450 <holding+0x2f>
80105449:	b8 01 00 00 00       	mov    $0x1,%eax
8010544e:	eb 05                	jmp    80105455 <holding+0x34>
80105450:	b8 00 00 00 00       	mov    $0x0,%eax
80105455:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();
80105458:	e8 5a 00 00 00       	call   801054b7 <popcli>
  return r;
8010545d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105460:	83 c4 14             	add    $0x14,%esp
80105463:	5b                   	pop    %ebx
80105464:	5d                   	pop    %ebp
80105465:	c3                   	ret    

80105466 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105466:	f3 0f 1e fb          	endbr32 
8010546a:	55                   	push   %ebp
8010546b:	89 e5                	mov    %esp,%ebp
8010546d:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80105470:	e8 07 fe ff ff       	call   8010527c <readeflags>
80105475:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80105478:	e8 0f fe ff ff       	call   8010528c <cli>
  if(mycpu()->ncli == 0)
8010547d:	e8 11 f0 ff ff       	call   80104493 <mycpu>
80105482:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105488:	85 c0                	test   %eax,%eax
8010548a:	75 14                	jne    801054a0 <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
8010548c:	e8 02 f0 ff ff       	call   80104493 <mycpu>
80105491:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105494:	81 e2 00 02 00 00    	and    $0x200,%edx
8010549a:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801054a0:	e8 ee ef ff ff       	call   80104493 <mycpu>
801054a5:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801054ab:	83 c2 01             	add    $0x1,%edx
801054ae:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801054b4:	90                   	nop
801054b5:	c9                   	leave  
801054b6:	c3                   	ret    

801054b7 <popcli>:

void
popcli(void)
{
801054b7:	f3 0f 1e fb          	endbr32 
801054bb:	55                   	push   %ebp
801054bc:	89 e5                	mov    %esp,%ebp
801054be:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801054c1:	e8 b6 fd ff ff       	call   8010527c <readeflags>
801054c6:	25 00 02 00 00       	and    $0x200,%eax
801054cb:	85 c0                	test   %eax,%eax
801054cd:	74 0d                	je     801054dc <popcli+0x25>
    panic("popcli - interruptible");
801054cf:	83 ec 0c             	sub    $0xc,%esp
801054d2:	68 52 98 10 80       	push   $0x80109852
801054d7:	e8 2c b1 ff ff       	call   80100608 <panic>
  if(--mycpu()->ncli < 0)
801054dc:	e8 b2 ef ff ff       	call   80104493 <mycpu>
801054e1:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801054e7:	83 ea 01             	sub    $0x1,%edx
801054ea:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801054f0:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801054f6:	85 c0                	test   %eax,%eax
801054f8:	79 0d                	jns    80105507 <popcli+0x50>
    panic("popcli");
801054fa:	83 ec 0c             	sub    $0xc,%esp
801054fd:	68 69 98 10 80       	push   $0x80109869
80105502:	e8 01 b1 ff ff       	call   80100608 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105507:	e8 87 ef ff ff       	call   80104493 <mycpu>
8010550c:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105512:	85 c0                	test   %eax,%eax
80105514:	75 14                	jne    8010552a <popcli+0x73>
80105516:	e8 78 ef ff ff       	call   80104493 <mycpu>
8010551b:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80105521:	85 c0                	test   %eax,%eax
80105523:	74 05                	je     8010552a <popcli+0x73>
    sti();
80105525:	e8 69 fd ff ff       	call   80105293 <sti>
}
8010552a:	90                   	nop
8010552b:	c9                   	leave  
8010552c:	c3                   	ret    

8010552d <stosb>:
{
8010552d:	55                   	push   %ebp
8010552e:	89 e5                	mov    %esp,%ebp
80105530:	57                   	push   %edi
80105531:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105532:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105535:	8b 55 10             	mov    0x10(%ebp),%edx
80105538:	8b 45 0c             	mov    0xc(%ebp),%eax
8010553b:	89 cb                	mov    %ecx,%ebx
8010553d:	89 df                	mov    %ebx,%edi
8010553f:	89 d1                	mov    %edx,%ecx
80105541:	fc                   	cld    
80105542:	f3 aa                	rep stos %al,%es:(%edi)
80105544:	89 ca                	mov    %ecx,%edx
80105546:	89 fb                	mov    %edi,%ebx
80105548:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010554b:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010554e:	90                   	nop
8010554f:	5b                   	pop    %ebx
80105550:	5f                   	pop    %edi
80105551:	5d                   	pop    %ebp
80105552:	c3                   	ret    

80105553 <stosl>:
{
80105553:	55                   	push   %ebp
80105554:	89 e5                	mov    %esp,%ebp
80105556:	57                   	push   %edi
80105557:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105558:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010555b:	8b 55 10             	mov    0x10(%ebp),%edx
8010555e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105561:	89 cb                	mov    %ecx,%ebx
80105563:	89 df                	mov    %ebx,%edi
80105565:	89 d1                	mov    %edx,%ecx
80105567:	fc                   	cld    
80105568:	f3 ab                	rep stos %eax,%es:(%edi)
8010556a:	89 ca                	mov    %ecx,%edx
8010556c:	89 fb                	mov    %edi,%ebx
8010556e:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105571:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105574:	90                   	nop
80105575:	5b                   	pop    %ebx
80105576:	5f                   	pop    %edi
80105577:	5d                   	pop    %ebp
80105578:	c3                   	ret    

80105579 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105579:	f3 0f 1e fb          	endbr32 
8010557d:	55                   	push   %ebp
8010557e:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105580:	8b 45 08             	mov    0x8(%ebp),%eax
80105583:	83 e0 03             	and    $0x3,%eax
80105586:	85 c0                	test   %eax,%eax
80105588:	75 43                	jne    801055cd <memset+0x54>
8010558a:	8b 45 10             	mov    0x10(%ebp),%eax
8010558d:	83 e0 03             	and    $0x3,%eax
80105590:	85 c0                	test   %eax,%eax
80105592:	75 39                	jne    801055cd <memset+0x54>
    c &= 0xFF;
80105594:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010559b:	8b 45 10             	mov    0x10(%ebp),%eax
8010559e:	c1 e8 02             	shr    $0x2,%eax
801055a1:	89 c1                	mov    %eax,%ecx
801055a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801055a6:	c1 e0 18             	shl    $0x18,%eax
801055a9:	89 c2                	mov    %eax,%edx
801055ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801055ae:	c1 e0 10             	shl    $0x10,%eax
801055b1:	09 c2                	or     %eax,%edx
801055b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801055b6:	c1 e0 08             	shl    $0x8,%eax
801055b9:	09 d0                	or     %edx,%eax
801055bb:	0b 45 0c             	or     0xc(%ebp),%eax
801055be:	51                   	push   %ecx
801055bf:	50                   	push   %eax
801055c0:	ff 75 08             	pushl  0x8(%ebp)
801055c3:	e8 8b ff ff ff       	call   80105553 <stosl>
801055c8:	83 c4 0c             	add    $0xc,%esp
801055cb:	eb 12                	jmp    801055df <memset+0x66>
  } else
    stosb(dst, c, n);
801055cd:	8b 45 10             	mov    0x10(%ebp),%eax
801055d0:	50                   	push   %eax
801055d1:	ff 75 0c             	pushl  0xc(%ebp)
801055d4:	ff 75 08             	pushl  0x8(%ebp)
801055d7:	e8 51 ff ff ff       	call   8010552d <stosb>
801055dc:	83 c4 0c             	add    $0xc,%esp
  return dst;
801055df:	8b 45 08             	mov    0x8(%ebp),%eax
}
801055e2:	c9                   	leave  
801055e3:	c3                   	ret    

801055e4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801055e4:	f3 0f 1e fb          	endbr32 
801055e8:	55                   	push   %ebp
801055e9:	89 e5                	mov    %esp,%ebp
801055eb:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801055ee:	8b 45 08             	mov    0x8(%ebp),%eax
801055f1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801055f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801055f7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801055fa:	eb 30                	jmp    8010562c <memcmp+0x48>
    if(*s1 != *s2)
801055fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055ff:	0f b6 10             	movzbl (%eax),%edx
80105602:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105605:	0f b6 00             	movzbl (%eax),%eax
80105608:	38 c2                	cmp    %al,%dl
8010560a:	74 18                	je     80105624 <memcmp+0x40>
      return *s1 - *s2;
8010560c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010560f:	0f b6 00             	movzbl (%eax),%eax
80105612:	0f b6 d0             	movzbl %al,%edx
80105615:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105618:	0f b6 00             	movzbl (%eax),%eax
8010561b:	0f b6 c0             	movzbl %al,%eax
8010561e:	29 c2                	sub    %eax,%edx
80105620:	89 d0                	mov    %edx,%eax
80105622:	eb 1a                	jmp    8010563e <memcmp+0x5a>
    s1++, s2++;
80105624:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105628:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
8010562c:	8b 45 10             	mov    0x10(%ebp),%eax
8010562f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105632:	89 55 10             	mov    %edx,0x10(%ebp)
80105635:	85 c0                	test   %eax,%eax
80105637:	75 c3                	jne    801055fc <memcmp+0x18>
  }

  return 0;
80105639:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010563e:	c9                   	leave  
8010563f:	c3                   	ret    

80105640 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105640:	f3 0f 1e fb          	endbr32 
80105644:	55                   	push   %ebp
80105645:	89 e5                	mov    %esp,%ebp
80105647:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010564a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010564d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105650:	8b 45 08             	mov    0x8(%ebp),%eax
80105653:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105656:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105659:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010565c:	73 54                	jae    801056b2 <memmove+0x72>
8010565e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105661:	8b 45 10             	mov    0x10(%ebp),%eax
80105664:	01 d0                	add    %edx,%eax
80105666:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80105669:	73 47                	jae    801056b2 <memmove+0x72>
    s += n;
8010566b:	8b 45 10             	mov    0x10(%ebp),%eax
8010566e:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105671:	8b 45 10             	mov    0x10(%ebp),%eax
80105674:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105677:	eb 13                	jmp    8010568c <memmove+0x4c>
      *--d = *--s;
80105679:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010567d:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105681:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105684:	0f b6 10             	movzbl (%eax),%edx
80105687:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010568a:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
8010568c:	8b 45 10             	mov    0x10(%ebp),%eax
8010568f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105692:	89 55 10             	mov    %edx,0x10(%ebp)
80105695:	85 c0                	test   %eax,%eax
80105697:	75 e0                	jne    80105679 <memmove+0x39>
  if(s < d && s + n > d){
80105699:	eb 24                	jmp    801056bf <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
8010569b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010569e:	8d 42 01             	lea    0x1(%edx),%eax
801056a1:	89 45 fc             	mov    %eax,-0x4(%ebp)
801056a4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801056a7:	8d 48 01             	lea    0x1(%eax),%ecx
801056aa:	89 4d f8             	mov    %ecx,-0x8(%ebp)
801056ad:	0f b6 12             	movzbl (%edx),%edx
801056b0:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801056b2:	8b 45 10             	mov    0x10(%ebp),%eax
801056b5:	8d 50 ff             	lea    -0x1(%eax),%edx
801056b8:	89 55 10             	mov    %edx,0x10(%ebp)
801056bb:	85 c0                	test   %eax,%eax
801056bd:	75 dc                	jne    8010569b <memmove+0x5b>

  return dst;
801056bf:	8b 45 08             	mov    0x8(%ebp),%eax
}
801056c2:	c9                   	leave  
801056c3:	c3                   	ret    

801056c4 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801056c4:	f3 0f 1e fb          	endbr32 
801056c8:	55                   	push   %ebp
801056c9:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801056cb:	ff 75 10             	pushl  0x10(%ebp)
801056ce:	ff 75 0c             	pushl  0xc(%ebp)
801056d1:	ff 75 08             	pushl  0x8(%ebp)
801056d4:	e8 67 ff ff ff       	call   80105640 <memmove>
801056d9:	83 c4 0c             	add    $0xc,%esp
}
801056dc:	c9                   	leave  
801056dd:	c3                   	ret    

801056de <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801056de:	f3 0f 1e fb          	endbr32 
801056e2:	55                   	push   %ebp
801056e3:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801056e5:	eb 0c                	jmp    801056f3 <strncmp+0x15>
    n--, p++, q++;
801056e7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801056eb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801056ef:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
801056f3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056f7:	74 1a                	je     80105713 <strncmp+0x35>
801056f9:	8b 45 08             	mov    0x8(%ebp),%eax
801056fc:	0f b6 00             	movzbl (%eax),%eax
801056ff:	84 c0                	test   %al,%al
80105701:	74 10                	je     80105713 <strncmp+0x35>
80105703:	8b 45 08             	mov    0x8(%ebp),%eax
80105706:	0f b6 10             	movzbl (%eax),%edx
80105709:	8b 45 0c             	mov    0xc(%ebp),%eax
8010570c:	0f b6 00             	movzbl (%eax),%eax
8010570f:	38 c2                	cmp    %al,%dl
80105711:	74 d4                	je     801056e7 <strncmp+0x9>
  if(n == 0)
80105713:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105717:	75 07                	jne    80105720 <strncmp+0x42>
    return 0;
80105719:	b8 00 00 00 00       	mov    $0x0,%eax
8010571e:	eb 16                	jmp    80105736 <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
80105720:	8b 45 08             	mov    0x8(%ebp),%eax
80105723:	0f b6 00             	movzbl (%eax),%eax
80105726:	0f b6 d0             	movzbl %al,%edx
80105729:	8b 45 0c             	mov    0xc(%ebp),%eax
8010572c:	0f b6 00             	movzbl (%eax),%eax
8010572f:	0f b6 c0             	movzbl %al,%eax
80105732:	29 c2                	sub    %eax,%edx
80105734:	89 d0                	mov    %edx,%eax
}
80105736:	5d                   	pop    %ebp
80105737:	c3                   	ret    

80105738 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105738:	f3 0f 1e fb          	endbr32 
8010573c:	55                   	push   %ebp
8010573d:	89 e5                	mov    %esp,%ebp
8010573f:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105742:	8b 45 08             	mov    0x8(%ebp),%eax
80105745:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105748:	90                   	nop
80105749:	8b 45 10             	mov    0x10(%ebp),%eax
8010574c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010574f:	89 55 10             	mov    %edx,0x10(%ebp)
80105752:	85 c0                	test   %eax,%eax
80105754:	7e 2c                	jle    80105782 <strncpy+0x4a>
80105756:	8b 55 0c             	mov    0xc(%ebp),%edx
80105759:	8d 42 01             	lea    0x1(%edx),%eax
8010575c:	89 45 0c             	mov    %eax,0xc(%ebp)
8010575f:	8b 45 08             	mov    0x8(%ebp),%eax
80105762:	8d 48 01             	lea    0x1(%eax),%ecx
80105765:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105768:	0f b6 12             	movzbl (%edx),%edx
8010576b:	88 10                	mov    %dl,(%eax)
8010576d:	0f b6 00             	movzbl (%eax),%eax
80105770:	84 c0                	test   %al,%al
80105772:	75 d5                	jne    80105749 <strncpy+0x11>
    ;
  while(n-- > 0)
80105774:	eb 0c                	jmp    80105782 <strncpy+0x4a>
    *s++ = 0;
80105776:	8b 45 08             	mov    0x8(%ebp),%eax
80105779:	8d 50 01             	lea    0x1(%eax),%edx
8010577c:	89 55 08             	mov    %edx,0x8(%ebp)
8010577f:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80105782:	8b 45 10             	mov    0x10(%ebp),%eax
80105785:	8d 50 ff             	lea    -0x1(%eax),%edx
80105788:	89 55 10             	mov    %edx,0x10(%ebp)
8010578b:	85 c0                	test   %eax,%eax
8010578d:	7f e7                	jg     80105776 <strncpy+0x3e>
  return os;
8010578f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105792:	c9                   	leave  
80105793:	c3                   	ret    

80105794 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105794:	f3 0f 1e fb          	endbr32 
80105798:	55                   	push   %ebp
80105799:	89 e5                	mov    %esp,%ebp
8010579b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010579e:	8b 45 08             	mov    0x8(%ebp),%eax
801057a1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801057a4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057a8:	7f 05                	jg     801057af <safestrcpy+0x1b>
    return os;
801057aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057ad:	eb 31                	jmp    801057e0 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
801057af:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801057b3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057b7:	7e 1e                	jle    801057d7 <safestrcpy+0x43>
801057b9:	8b 55 0c             	mov    0xc(%ebp),%edx
801057bc:	8d 42 01             	lea    0x1(%edx),%eax
801057bf:	89 45 0c             	mov    %eax,0xc(%ebp)
801057c2:	8b 45 08             	mov    0x8(%ebp),%eax
801057c5:	8d 48 01             	lea    0x1(%eax),%ecx
801057c8:	89 4d 08             	mov    %ecx,0x8(%ebp)
801057cb:	0f b6 12             	movzbl (%edx),%edx
801057ce:	88 10                	mov    %dl,(%eax)
801057d0:	0f b6 00             	movzbl (%eax),%eax
801057d3:	84 c0                	test   %al,%al
801057d5:	75 d8                	jne    801057af <safestrcpy+0x1b>
    ;
  *s = 0;
801057d7:	8b 45 08             	mov    0x8(%ebp),%eax
801057da:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801057dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057e0:	c9                   	leave  
801057e1:	c3                   	ret    

801057e2 <strlen>:

int
strlen(const char *s)
{
801057e2:	f3 0f 1e fb          	endbr32 
801057e6:	55                   	push   %ebp
801057e7:	89 e5                	mov    %esp,%ebp
801057e9:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801057ec:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801057f3:	eb 04                	jmp    801057f9 <strlen+0x17>
801057f5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801057f9:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057fc:	8b 45 08             	mov    0x8(%ebp),%eax
801057ff:	01 d0                	add    %edx,%eax
80105801:	0f b6 00             	movzbl (%eax),%eax
80105804:	84 c0                	test   %al,%al
80105806:	75 ed                	jne    801057f5 <strlen+0x13>
    ;
  return n;
80105808:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010580b:	c9                   	leave  
8010580c:	c3                   	ret    

8010580d <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010580d:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105811:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80105815:	55                   	push   %ebp
  pushl %ebx
80105816:	53                   	push   %ebx
  pushl %esi
80105817:	56                   	push   %esi
  pushl %edi
80105818:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105819:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010581b:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
8010581d:	5f                   	pop    %edi
  popl %esi
8010581e:	5e                   	pop    %esi
  popl %ebx
8010581f:	5b                   	pop    %ebx
  popl %ebp
80105820:	5d                   	pop    %ebp
  ret
80105821:	c3                   	ret    

80105822 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105822:	f3 0f 1e fb          	endbr32 
80105826:	55                   	push   %ebp
80105827:	89 e5                	mov    %esp,%ebp
80105829:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010582c:	e8 de ec ff ff       	call   8010450f <myproc>
80105831:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105834:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105837:	8b 00                	mov    (%eax),%eax
80105839:	39 45 08             	cmp    %eax,0x8(%ebp)
8010583c:	73 0f                	jae    8010584d <fetchint+0x2b>
8010583e:	8b 45 08             	mov    0x8(%ebp),%eax
80105841:	8d 50 04             	lea    0x4(%eax),%edx
80105844:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105847:	8b 00                	mov    (%eax),%eax
80105849:	39 c2                	cmp    %eax,%edx
8010584b:	76 07                	jbe    80105854 <fetchint+0x32>
    return -1;
8010584d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105852:	eb 0f                	jmp    80105863 <fetchint+0x41>
  *ip = *(int*)(addr);
80105854:	8b 45 08             	mov    0x8(%ebp),%eax
80105857:	8b 10                	mov    (%eax),%edx
80105859:	8b 45 0c             	mov    0xc(%ebp),%eax
8010585c:	89 10                	mov    %edx,(%eax)
  return 0;
8010585e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105863:	c9                   	leave  
80105864:	c3                   	ret    

80105865 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105865:	f3 0f 1e fb          	endbr32 
80105869:	55                   	push   %ebp
8010586a:	89 e5                	mov    %esp,%ebp
8010586c:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
8010586f:	e8 9b ec ff ff       	call   8010450f <myproc>
80105874:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105877:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010587a:	8b 00                	mov    (%eax),%eax
8010587c:	39 45 08             	cmp    %eax,0x8(%ebp)
8010587f:	72 07                	jb     80105888 <fetchstr+0x23>
    return -1;
80105881:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105886:	eb 43                	jmp    801058cb <fetchstr+0x66>
  *pp = (char*)addr;
80105888:	8b 55 08             	mov    0x8(%ebp),%edx
8010588b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010588e:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105890:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105893:	8b 00                	mov    (%eax),%eax
80105895:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105898:	8b 45 0c             	mov    0xc(%ebp),%eax
8010589b:	8b 00                	mov    (%eax),%eax
8010589d:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058a0:	eb 1c                	jmp    801058be <fetchstr+0x59>
    if(*s == 0)
801058a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058a5:	0f b6 00             	movzbl (%eax),%eax
801058a8:	84 c0                	test   %al,%al
801058aa:	75 0e                	jne    801058ba <fetchstr+0x55>
      return s - *pp;
801058ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801058af:	8b 00                	mov    (%eax),%eax
801058b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058b4:	29 c2                	sub    %eax,%edx
801058b6:	89 d0                	mov    %edx,%eax
801058b8:	eb 11                	jmp    801058cb <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
801058ba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801058be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058c1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801058c4:	72 dc                	jb     801058a2 <fetchstr+0x3d>
  }
  return -1;
801058c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801058cb:	c9                   	leave  
801058cc:	c3                   	ret    

801058cd <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801058cd:	f3 0f 1e fb          	endbr32 
801058d1:	55                   	push   %ebp
801058d2:	89 e5                	mov    %esp,%ebp
801058d4:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801058d7:	e8 33 ec ff ff       	call   8010450f <myproc>
801058dc:	8b 40 18             	mov    0x18(%eax),%eax
801058df:	8b 40 44             	mov    0x44(%eax),%eax
801058e2:	8b 55 08             	mov    0x8(%ebp),%edx
801058e5:	c1 e2 02             	shl    $0x2,%edx
801058e8:	01 d0                	add    %edx,%eax
801058ea:	83 c0 04             	add    $0x4,%eax
801058ed:	83 ec 08             	sub    $0x8,%esp
801058f0:	ff 75 0c             	pushl  0xc(%ebp)
801058f3:	50                   	push   %eax
801058f4:	e8 29 ff ff ff       	call   80105822 <fetchint>
801058f9:	83 c4 10             	add    $0x10,%esp
}
801058fc:	c9                   	leave  
801058fd:	c3                   	ret    

801058fe <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801058fe:	f3 0f 1e fb          	endbr32 
80105902:	55                   	push   %ebp
80105903:	89 e5                	mov    %esp,%ebp
80105905:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80105908:	e8 02 ec ff ff       	call   8010450f <myproc>
8010590d:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105910:	83 ec 08             	sub    $0x8,%esp
80105913:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105916:	50                   	push   %eax
80105917:	ff 75 08             	pushl  0x8(%ebp)
8010591a:	e8 ae ff ff ff       	call   801058cd <argint>
8010591f:	83 c4 10             	add    $0x10,%esp
80105922:	85 c0                	test   %eax,%eax
80105924:	79 07                	jns    8010592d <argptr+0x2f>
    return -1;
80105926:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010592b:	eb 3b                	jmp    80105968 <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010592d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105931:	78 1f                	js     80105952 <argptr+0x54>
80105933:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105936:	8b 00                	mov    (%eax),%eax
80105938:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010593b:	39 d0                	cmp    %edx,%eax
8010593d:	76 13                	jbe    80105952 <argptr+0x54>
8010593f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105942:	89 c2                	mov    %eax,%edx
80105944:	8b 45 10             	mov    0x10(%ebp),%eax
80105947:	01 c2                	add    %eax,%edx
80105949:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010594c:	8b 00                	mov    (%eax),%eax
8010594e:	39 c2                	cmp    %eax,%edx
80105950:	76 07                	jbe    80105959 <argptr+0x5b>
    return -1;
80105952:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105957:	eb 0f                	jmp    80105968 <argptr+0x6a>
  *pp = (char*)i;
80105959:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010595c:	89 c2                	mov    %eax,%edx
8010595e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105961:	89 10                	mov    %edx,(%eax)
  return 0;
80105963:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105968:	c9                   	leave  
80105969:	c3                   	ret    

8010596a <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010596a:	f3 0f 1e fb          	endbr32 
8010596e:	55                   	push   %ebp
8010596f:	89 e5                	mov    %esp,%ebp
80105971:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105974:	83 ec 08             	sub    $0x8,%esp
80105977:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010597a:	50                   	push   %eax
8010597b:	ff 75 08             	pushl  0x8(%ebp)
8010597e:	e8 4a ff ff ff       	call   801058cd <argint>
80105983:	83 c4 10             	add    $0x10,%esp
80105986:	85 c0                	test   %eax,%eax
80105988:	79 07                	jns    80105991 <argstr+0x27>
    return -1;
8010598a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010598f:	eb 12                	jmp    801059a3 <argstr+0x39>
  return fetchstr(addr, pp);
80105991:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105994:	83 ec 08             	sub    $0x8,%esp
80105997:	ff 75 0c             	pushl  0xc(%ebp)
8010599a:	50                   	push   %eax
8010599b:	e8 c5 fe ff ff       	call   80105865 <fetchstr>
801059a0:	83 c4 10             	add    $0x10,%esp
}
801059a3:	c9                   	leave  
801059a4:	c3                   	ret    

801059a5 <syscall>:
[SYS_dump_rawphymem] sys_dump_rawphymem,
};

void
syscall(void)
{
801059a5:	f3 0f 1e fb          	endbr32 
801059a9:	55                   	push   %ebp
801059aa:	89 e5                	mov    %esp,%ebp
801059ac:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
801059af:	e8 5b eb ff ff       	call   8010450f <myproc>
801059b4:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801059b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ba:	8b 40 18             	mov    0x18(%eax),%eax
801059bd:	8b 40 1c             	mov    0x1c(%eax),%eax
801059c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801059c3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059c7:	7e 2f                	jle    801059f8 <syscall+0x53>
801059c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059cc:	83 f8 18             	cmp    $0x18,%eax
801059cf:	77 27                	ja     801059f8 <syscall+0x53>
801059d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059d4:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
801059db:	85 c0                	test   %eax,%eax
801059dd:	74 19                	je     801059f8 <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
801059df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059e2:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
801059e9:	ff d0                	call   *%eax
801059eb:	89 c2                	mov    %eax,%edx
801059ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f0:	8b 40 18             	mov    0x18(%eax),%eax
801059f3:	89 50 1c             	mov    %edx,0x1c(%eax)
801059f6:	eb 2c                	jmp    80105a24 <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801059f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059fb:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
801059fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a01:	8b 40 10             	mov    0x10(%eax),%eax
80105a04:	ff 75 f0             	pushl  -0x10(%ebp)
80105a07:	52                   	push   %edx
80105a08:	50                   	push   %eax
80105a09:	68 70 98 10 80       	push   $0x80109870
80105a0e:	e8 05 aa ff ff       	call   80100418 <cprintf>
80105a13:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a19:	8b 40 18             	mov    0x18(%eax),%eax
80105a1c:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105a23:	90                   	nop
80105a24:	90                   	nop
80105a25:	c9                   	leave  
80105a26:	c3                   	ret    

80105a27 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105a27:	f3 0f 1e fb          	endbr32 
80105a2b:	55                   	push   %ebp
80105a2c:	89 e5                	mov    %esp,%ebp
80105a2e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105a31:	83 ec 08             	sub    $0x8,%esp
80105a34:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a37:	50                   	push   %eax
80105a38:	ff 75 08             	pushl  0x8(%ebp)
80105a3b:	e8 8d fe ff ff       	call   801058cd <argint>
80105a40:	83 c4 10             	add    $0x10,%esp
80105a43:	85 c0                	test   %eax,%eax
80105a45:	79 07                	jns    80105a4e <argfd+0x27>
    return -1;
80105a47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a4c:	eb 4f                	jmp    80105a9d <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105a4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a51:	85 c0                	test   %eax,%eax
80105a53:	78 20                	js     80105a75 <argfd+0x4e>
80105a55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a58:	83 f8 0f             	cmp    $0xf,%eax
80105a5b:	7f 18                	jg     80105a75 <argfd+0x4e>
80105a5d:	e8 ad ea ff ff       	call   8010450f <myproc>
80105a62:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a65:	83 c2 08             	add    $0x8,%edx
80105a68:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105a6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a6f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a73:	75 07                	jne    80105a7c <argfd+0x55>
    return -1;
80105a75:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a7a:	eb 21                	jmp    80105a9d <argfd+0x76>
  if(pfd)
80105a7c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105a80:	74 08                	je     80105a8a <argfd+0x63>
    *pfd = fd;
80105a82:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a85:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a88:	89 10                	mov    %edx,(%eax)
  if(pf)
80105a8a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105a8e:	74 08                	je     80105a98 <argfd+0x71>
    *pf = f;
80105a90:	8b 45 10             	mov    0x10(%ebp),%eax
80105a93:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a96:	89 10                	mov    %edx,(%eax)
  return 0;
80105a98:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a9d:	c9                   	leave  
80105a9e:	c3                   	ret    

80105a9f <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105a9f:	f3 0f 1e fb          	endbr32 
80105aa3:	55                   	push   %ebp
80105aa4:	89 e5                	mov    %esp,%ebp
80105aa6:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105aa9:	e8 61 ea ff ff       	call   8010450f <myproc>
80105aae:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105ab1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105ab8:	eb 2a                	jmp    80105ae4 <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
80105aba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105abd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ac0:	83 c2 08             	add    $0x8,%edx
80105ac3:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105ac7:	85 c0                	test   %eax,%eax
80105ac9:	75 15                	jne    80105ae0 <fdalloc+0x41>
      curproc->ofile[fd] = f;
80105acb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ace:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ad1:	8d 4a 08             	lea    0x8(%edx),%ecx
80105ad4:	8b 55 08             	mov    0x8(%ebp),%edx
80105ad7:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ade:	eb 0f                	jmp    80105aef <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80105ae0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105ae4:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105ae8:	7e d0                	jle    80105aba <fdalloc+0x1b>
    }
  }
  return -1;
80105aea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105aef:	c9                   	leave  
80105af0:	c3                   	ret    

80105af1 <sys_dup>:

int
sys_dup(void)
{
80105af1:	f3 0f 1e fb          	endbr32 
80105af5:	55                   	push   %ebp
80105af6:	89 e5                	mov    %esp,%ebp
80105af8:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105afb:	83 ec 04             	sub    $0x4,%esp
80105afe:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b01:	50                   	push   %eax
80105b02:	6a 00                	push   $0x0
80105b04:	6a 00                	push   $0x0
80105b06:	e8 1c ff ff ff       	call   80105a27 <argfd>
80105b0b:	83 c4 10             	add    $0x10,%esp
80105b0e:	85 c0                	test   %eax,%eax
80105b10:	79 07                	jns    80105b19 <sys_dup+0x28>
    return -1;
80105b12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b17:	eb 31                	jmp    80105b4a <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
80105b19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b1c:	83 ec 0c             	sub    $0xc,%esp
80105b1f:	50                   	push   %eax
80105b20:	e8 7a ff ff ff       	call   80105a9f <fdalloc>
80105b25:	83 c4 10             	add    $0x10,%esp
80105b28:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b2b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b2f:	79 07                	jns    80105b38 <sys_dup+0x47>
    return -1;
80105b31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b36:	eb 12                	jmp    80105b4a <sys_dup+0x59>
  filedup(f);
80105b38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b3b:	83 ec 0c             	sub    $0xc,%esp
80105b3e:	50                   	push   %eax
80105b3f:	e8 42 b6 ff ff       	call   80101186 <filedup>
80105b44:	83 c4 10             	add    $0x10,%esp
  return fd;
80105b47:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105b4a:	c9                   	leave  
80105b4b:	c3                   	ret    

80105b4c <sys_read>:

int
sys_read(void)
{
80105b4c:	f3 0f 1e fb          	endbr32 
80105b50:	55                   	push   %ebp
80105b51:	89 e5                	mov    %esp,%ebp
80105b53:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b56:	83 ec 04             	sub    $0x4,%esp
80105b59:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b5c:	50                   	push   %eax
80105b5d:	6a 00                	push   $0x0
80105b5f:	6a 00                	push   $0x0
80105b61:	e8 c1 fe ff ff       	call   80105a27 <argfd>
80105b66:	83 c4 10             	add    $0x10,%esp
80105b69:	85 c0                	test   %eax,%eax
80105b6b:	78 2e                	js     80105b9b <sys_read+0x4f>
80105b6d:	83 ec 08             	sub    $0x8,%esp
80105b70:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b73:	50                   	push   %eax
80105b74:	6a 02                	push   $0x2
80105b76:	e8 52 fd ff ff       	call   801058cd <argint>
80105b7b:	83 c4 10             	add    $0x10,%esp
80105b7e:	85 c0                	test   %eax,%eax
80105b80:	78 19                	js     80105b9b <sys_read+0x4f>
80105b82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b85:	83 ec 04             	sub    $0x4,%esp
80105b88:	50                   	push   %eax
80105b89:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b8c:	50                   	push   %eax
80105b8d:	6a 01                	push   $0x1
80105b8f:	e8 6a fd ff ff       	call   801058fe <argptr>
80105b94:	83 c4 10             	add    $0x10,%esp
80105b97:	85 c0                	test   %eax,%eax
80105b99:	79 07                	jns    80105ba2 <sys_read+0x56>
    return -1;
80105b9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ba0:	eb 17                	jmp    80105bb9 <sys_read+0x6d>
  return fileread(f, p, n);
80105ba2:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105ba5:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bab:	83 ec 04             	sub    $0x4,%esp
80105bae:	51                   	push   %ecx
80105baf:	52                   	push   %edx
80105bb0:	50                   	push   %eax
80105bb1:	e8 6c b7 ff ff       	call   80101322 <fileread>
80105bb6:	83 c4 10             	add    $0x10,%esp
}
80105bb9:	c9                   	leave  
80105bba:	c3                   	ret    

80105bbb <sys_write>:

int
sys_write(void)
{
80105bbb:	f3 0f 1e fb          	endbr32 
80105bbf:	55                   	push   %ebp
80105bc0:	89 e5                	mov    %esp,%ebp
80105bc2:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105bc5:	83 ec 04             	sub    $0x4,%esp
80105bc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bcb:	50                   	push   %eax
80105bcc:	6a 00                	push   $0x0
80105bce:	6a 00                	push   $0x0
80105bd0:	e8 52 fe ff ff       	call   80105a27 <argfd>
80105bd5:	83 c4 10             	add    $0x10,%esp
80105bd8:	85 c0                	test   %eax,%eax
80105bda:	78 2e                	js     80105c0a <sys_write+0x4f>
80105bdc:	83 ec 08             	sub    $0x8,%esp
80105bdf:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105be2:	50                   	push   %eax
80105be3:	6a 02                	push   $0x2
80105be5:	e8 e3 fc ff ff       	call   801058cd <argint>
80105bea:	83 c4 10             	add    $0x10,%esp
80105bed:	85 c0                	test   %eax,%eax
80105bef:	78 19                	js     80105c0a <sys_write+0x4f>
80105bf1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bf4:	83 ec 04             	sub    $0x4,%esp
80105bf7:	50                   	push   %eax
80105bf8:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105bfb:	50                   	push   %eax
80105bfc:	6a 01                	push   $0x1
80105bfe:	e8 fb fc ff ff       	call   801058fe <argptr>
80105c03:	83 c4 10             	add    $0x10,%esp
80105c06:	85 c0                	test   %eax,%eax
80105c08:	79 07                	jns    80105c11 <sys_write+0x56>
    return -1;
80105c0a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c0f:	eb 17                	jmp    80105c28 <sys_write+0x6d>
  return filewrite(f, p, n);
80105c11:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105c14:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c1a:	83 ec 04             	sub    $0x4,%esp
80105c1d:	51                   	push   %ecx
80105c1e:	52                   	push   %edx
80105c1f:	50                   	push   %eax
80105c20:	e8 b9 b7 ff ff       	call   801013de <filewrite>
80105c25:	83 c4 10             	add    $0x10,%esp
}
80105c28:	c9                   	leave  
80105c29:	c3                   	ret    

80105c2a <sys_close>:

int
sys_close(void)
{
80105c2a:	f3 0f 1e fb          	endbr32 
80105c2e:	55                   	push   %ebp
80105c2f:	89 e5                	mov    %esp,%ebp
80105c31:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105c34:	83 ec 04             	sub    $0x4,%esp
80105c37:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c3a:	50                   	push   %eax
80105c3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c3e:	50                   	push   %eax
80105c3f:	6a 00                	push   $0x0
80105c41:	e8 e1 fd ff ff       	call   80105a27 <argfd>
80105c46:	83 c4 10             	add    $0x10,%esp
80105c49:	85 c0                	test   %eax,%eax
80105c4b:	79 07                	jns    80105c54 <sys_close+0x2a>
    return -1;
80105c4d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c52:	eb 27                	jmp    80105c7b <sys_close+0x51>
  myproc()->ofile[fd] = 0;
80105c54:	e8 b6 e8 ff ff       	call   8010450f <myproc>
80105c59:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c5c:	83 c2 08             	add    $0x8,%edx
80105c5f:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105c66:	00 
  fileclose(f);
80105c67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c6a:	83 ec 0c             	sub    $0xc,%esp
80105c6d:	50                   	push   %eax
80105c6e:	e8 68 b5 ff ff       	call   801011db <fileclose>
80105c73:	83 c4 10             	add    $0x10,%esp
  return 0;
80105c76:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c7b:	c9                   	leave  
80105c7c:	c3                   	ret    

80105c7d <sys_fstat>:

int
sys_fstat(void)
{
80105c7d:	f3 0f 1e fb          	endbr32 
80105c81:	55                   	push   %ebp
80105c82:	89 e5                	mov    %esp,%ebp
80105c84:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105c87:	83 ec 04             	sub    $0x4,%esp
80105c8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c8d:	50                   	push   %eax
80105c8e:	6a 00                	push   $0x0
80105c90:	6a 00                	push   $0x0
80105c92:	e8 90 fd ff ff       	call   80105a27 <argfd>
80105c97:	83 c4 10             	add    $0x10,%esp
80105c9a:	85 c0                	test   %eax,%eax
80105c9c:	78 17                	js     80105cb5 <sys_fstat+0x38>
80105c9e:	83 ec 04             	sub    $0x4,%esp
80105ca1:	6a 14                	push   $0x14
80105ca3:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ca6:	50                   	push   %eax
80105ca7:	6a 01                	push   $0x1
80105ca9:	e8 50 fc ff ff       	call   801058fe <argptr>
80105cae:	83 c4 10             	add    $0x10,%esp
80105cb1:	85 c0                	test   %eax,%eax
80105cb3:	79 07                	jns    80105cbc <sys_fstat+0x3f>
    return -1;
80105cb5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cba:	eb 13                	jmp    80105ccf <sys_fstat+0x52>
  return filestat(f, st);
80105cbc:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cc2:	83 ec 08             	sub    $0x8,%esp
80105cc5:	52                   	push   %edx
80105cc6:	50                   	push   %eax
80105cc7:	e8 fb b5 ff ff       	call   801012c7 <filestat>
80105ccc:	83 c4 10             	add    $0x10,%esp
}
80105ccf:	c9                   	leave  
80105cd0:	c3                   	ret    

80105cd1 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105cd1:	f3 0f 1e fb          	endbr32 
80105cd5:	55                   	push   %ebp
80105cd6:	89 e5                	mov    %esp,%ebp
80105cd8:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105cdb:	83 ec 08             	sub    $0x8,%esp
80105cde:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105ce1:	50                   	push   %eax
80105ce2:	6a 00                	push   $0x0
80105ce4:	e8 81 fc ff ff       	call   8010596a <argstr>
80105ce9:	83 c4 10             	add    $0x10,%esp
80105cec:	85 c0                	test   %eax,%eax
80105cee:	78 15                	js     80105d05 <sys_link+0x34>
80105cf0:	83 ec 08             	sub    $0x8,%esp
80105cf3:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105cf6:	50                   	push   %eax
80105cf7:	6a 01                	push   $0x1
80105cf9:	e8 6c fc ff ff       	call   8010596a <argstr>
80105cfe:	83 c4 10             	add    $0x10,%esp
80105d01:	85 c0                	test   %eax,%eax
80105d03:	79 0a                	jns    80105d0f <sys_link+0x3e>
    return -1;
80105d05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d0a:	e9 68 01 00 00       	jmp    80105e77 <sys_link+0x1a6>

  begin_op();
80105d0f:	e8 3c da ff ff       	call   80103750 <begin_op>
  if((ip = namei(old)) == 0){
80105d14:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105d17:	83 ec 0c             	sub    $0xc,%esp
80105d1a:	50                   	push   %eax
80105d1b:	e8 a6 c9 ff ff       	call   801026c6 <namei>
80105d20:	83 c4 10             	add    $0x10,%esp
80105d23:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d26:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d2a:	75 0f                	jne    80105d3b <sys_link+0x6a>
    end_op();
80105d2c:	e8 af da ff ff       	call   801037e0 <end_op>
    return -1;
80105d31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d36:	e9 3c 01 00 00       	jmp    80105e77 <sys_link+0x1a6>
  }

  ilock(ip);
80105d3b:	83 ec 0c             	sub    $0xc,%esp
80105d3e:	ff 75 f4             	pushl  -0xc(%ebp)
80105d41:	e8 15 be ff ff       	call   80101b5b <ilock>
80105d46:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d4c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d50:	66 83 f8 01          	cmp    $0x1,%ax
80105d54:	75 1d                	jne    80105d73 <sys_link+0xa2>
    iunlockput(ip);
80105d56:	83 ec 0c             	sub    $0xc,%esp
80105d59:	ff 75 f4             	pushl  -0xc(%ebp)
80105d5c:	e8 37 c0 ff ff       	call   80101d98 <iunlockput>
80105d61:	83 c4 10             	add    $0x10,%esp
    end_op();
80105d64:	e8 77 da ff ff       	call   801037e0 <end_op>
    return -1;
80105d69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d6e:	e9 04 01 00 00       	jmp    80105e77 <sys_link+0x1a6>
  }

  ip->nlink++;
80105d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d76:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105d7a:	83 c0 01             	add    $0x1,%eax
80105d7d:	89 c2                	mov    %eax,%edx
80105d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d82:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105d86:	83 ec 0c             	sub    $0xc,%esp
80105d89:	ff 75 f4             	pushl  -0xc(%ebp)
80105d8c:	e8 e1 bb ff ff       	call   80101972 <iupdate>
80105d91:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105d94:	83 ec 0c             	sub    $0xc,%esp
80105d97:	ff 75 f4             	pushl  -0xc(%ebp)
80105d9a:	e8 d3 be ff ff       	call   80101c72 <iunlock>
80105d9f:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105da2:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105da5:	83 ec 08             	sub    $0x8,%esp
80105da8:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105dab:	52                   	push   %edx
80105dac:	50                   	push   %eax
80105dad:	e8 34 c9 ff ff       	call   801026e6 <nameiparent>
80105db2:	83 c4 10             	add    $0x10,%esp
80105db5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105db8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105dbc:	74 71                	je     80105e2f <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105dbe:	83 ec 0c             	sub    $0xc,%esp
80105dc1:	ff 75 f0             	pushl  -0x10(%ebp)
80105dc4:	e8 92 bd ff ff       	call   80101b5b <ilock>
80105dc9:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105dcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dcf:	8b 10                	mov    (%eax),%edx
80105dd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dd4:	8b 00                	mov    (%eax),%eax
80105dd6:	39 c2                	cmp    %eax,%edx
80105dd8:	75 1d                	jne    80105df7 <sys_link+0x126>
80105dda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ddd:	8b 40 04             	mov    0x4(%eax),%eax
80105de0:	83 ec 04             	sub    $0x4,%esp
80105de3:	50                   	push   %eax
80105de4:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105de7:	50                   	push   %eax
80105de8:	ff 75 f0             	pushl  -0x10(%ebp)
80105deb:	e8 33 c6 ff ff       	call   80102423 <dirlink>
80105df0:	83 c4 10             	add    $0x10,%esp
80105df3:	85 c0                	test   %eax,%eax
80105df5:	79 10                	jns    80105e07 <sys_link+0x136>
    iunlockput(dp);
80105df7:	83 ec 0c             	sub    $0xc,%esp
80105dfa:	ff 75 f0             	pushl  -0x10(%ebp)
80105dfd:	e8 96 bf ff ff       	call   80101d98 <iunlockput>
80105e02:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105e05:	eb 29                	jmp    80105e30 <sys_link+0x15f>
  }
  iunlockput(dp);
80105e07:	83 ec 0c             	sub    $0xc,%esp
80105e0a:	ff 75 f0             	pushl  -0x10(%ebp)
80105e0d:	e8 86 bf ff ff       	call   80101d98 <iunlockput>
80105e12:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105e15:	83 ec 0c             	sub    $0xc,%esp
80105e18:	ff 75 f4             	pushl  -0xc(%ebp)
80105e1b:	e8 a4 be ff ff       	call   80101cc4 <iput>
80105e20:	83 c4 10             	add    $0x10,%esp

  end_op();
80105e23:	e8 b8 d9 ff ff       	call   801037e0 <end_op>

  return 0;
80105e28:	b8 00 00 00 00       	mov    $0x0,%eax
80105e2d:	eb 48                	jmp    80105e77 <sys_link+0x1a6>
    goto bad;
80105e2f:	90                   	nop

bad:
  ilock(ip);
80105e30:	83 ec 0c             	sub    $0xc,%esp
80105e33:	ff 75 f4             	pushl  -0xc(%ebp)
80105e36:	e8 20 bd ff ff       	call   80101b5b <ilock>
80105e3b:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e41:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105e45:	83 e8 01             	sub    $0x1,%eax
80105e48:	89 c2                	mov    %eax,%edx
80105e4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e4d:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105e51:	83 ec 0c             	sub    $0xc,%esp
80105e54:	ff 75 f4             	pushl  -0xc(%ebp)
80105e57:	e8 16 bb ff ff       	call   80101972 <iupdate>
80105e5c:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105e5f:	83 ec 0c             	sub    $0xc,%esp
80105e62:	ff 75 f4             	pushl  -0xc(%ebp)
80105e65:	e8 2e bf ff ff       	call   80101d98 <iunlockput>
80105e6a:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e6d:	e8 6e d9 ff ff       	call   801037e0 <end_op>
  return -1;
80105e72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e77:	c9                   	leave  
80105e78:	c3                   	ret    

80105e79 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105e79:	f3 0f 1e fb          	endbr32 
80105e7d:	55                   	push   %ebp
80105e7e:	89 e5                	mov    %esp,%ebp
80105e80:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105e83:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105e8a:	eb 40                	jmp    80105ecc <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105e8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e8f:	6a 10                	push   $0x10
80105e91:	50                   	push   %eax
80105e92:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105e95:	50                   	push   %eax
80105e96:	ff 75 08             	pushl  0x8(%ebp)
80105e99:	e8 c5 c1 ff ff       	call   80102063 <readi>
80105e9e:	83 c4 10             	add    $0x10,%esp
80105ea1:	83 f8 10             	cmp    $0x10,%eax
80105ea4:	74 0d                	je     80105eb3 <isdirempty+0x3a>
      panic("isdirempty: readi");
80105ea6:	83 ec 0c             	sub    $0xc,%esp
80105ea9:	68 8c 98 10 80       	push   $0x8010988c
80105eae:	e8 55 a7 ff ff       	call   80100608 <panic>
    if(de.inum != 0)
80105eb3:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105eb7:	66 85 c0             	test   %ax,%ax
80105eba:	74 07                	je     80105ec3 <isdirempty+0x4a>
      return 0;
80105ebc:	b8 00 00 00 00       	mov    $0x0,%eax
80105ec1:	eb 1b                	jmp    80105ede <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105ec3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec6:	83 c0 10             	add    $0x10,%eax
80105ec9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ecc:	8b 45 08             	mov    0x8(%ebp),%eax
80105ecf:	8b 50 58             	mov    0x58(%eax),%edx
80105ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ed5:	39 c2                	cmp    %eax,%edx
80105ed7:	77 b3                	ja     80105e8c <isdirempty+0x13>
  }
  return 1;
80105ed9:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105ede:	c9                   	leave  
80105edf:	c3                   	ret    

80105ee0 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105ee0:	f3 0f 1e fb          	endbr32 
80105ee4:	55                   	push   %ebp
80105ee5:	89 e5                	mov    %esp,%ebp
80105ee7:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105eea:	83 ec 08             	sub    $0x8,%esp
80105eed:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105ef0:	50                   	push   %eax
80105ef1:	6a 00                	push   $0x0
80105ef3:	e8 72 fa ff ff       	call   8010596a <argstr>
80105ef8:	83 c4 10             	add    $0x10,%esp
80105efb:	85 c0                	test   %eax,%eax
80105efd:	79 0a                	jns    80105f09 <sys_unlink+0x29>
    return -1;
80105eff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f04:	e9 bf 01 00 00       	jmp    801060c8 <sys_unlink+0x1e8>

  begin_op();
80105f09:	e8 42 d8 ff ff       	call   80103750 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105f0e:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105f11:	83 ec 08             	sub    $0x8,%esp
80105f14:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105f17:	52                   	push   %edx
80105f18:	50                   	push   %eax
80105f19:	e8 c8 c7 ff ff       	call   801026e6 <nameiparent>
80105f1e:	83 c4 10             	add    $0x10,%esp
80105f21:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f24:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f28:	75 0f                	jne    80105f39 <sys_unlink+0x59>
    end_op();
80105f2a:	e8 b1 d8 ff ff       	call   801037e0 <end_op>
    return -1;
80105f2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f34:	e9 8f 01 00 00       	jmp    801060c8 <sys_unlink+0x1e8>
  }

  ilock(dp);
80105f39:	83 ec 0c             	sub    $0xc,%esp
80105f3c:	ff 75 f4             	pushl  -0xc(%ebp)
80105f3f:	e8 17 bc ff ff       	call   80101b5b <ilock>
80105f44:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105f47:	83 ec 08             	sub    $0x8,%esp
80105f4a:	68 9e 98 10 80       	push   $0x8010989e
80105f4f:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f52:	50                   	push   %eax
80105f53:	e8 ee c3 ff ff       	call   80102346 <namecmp>
80105f58:	83 c4 10             	add    $0x10,%esp
80105f5b:	85 c0                	test   %eax,%eax
80105f5d:	0f 84 49 01 00 00    	je     801060ac <sys_unlink+0x1cc>
80105f63:	83 ec 08             	sub    $0x8,%esp
80105f66:	68 a0 98 10 80       	push   $0x801098a0
80105f6b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f6e:	50                   	push   %eax
80105f6f:	e8 d2 c3 ff ff       	call   80102346 <namecmp>
80105f74:	83 c4 10             	add    $0x10,%esp
80105f77:	85 c0                	test   %eax,%eax
80105f79:	0f 84 2d 01 00 00    	je     801060ac <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105f7f:	83 ec 04             	sub    $0x4,%esp
80105f82:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105f85:	50                   	push   %eax
80105f86:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f89:	50                   	push   %eax
80105f8a:	ff 75 f4             	pushl  -0xc(%ebp)
80105f8d:	e8 d3 c3 ff ff       	call   80102365 <dirlookup>
80105f92:	83 c4 10             	add    $0x10,%esp
80105f95:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f98:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f9c:	0f 84 0d 01 00 00    	je     801060af <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80105fa2:	83 ec 0c             	sub    $0xc,%esp
80105fa5:	ff 75 f0             	pushl  -0x10(%ebp)
80105fa8:	e8 ae bb ff ff       	call   80101b5b <ilock>
80105fad:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105fb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fb3:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105fb7:	66 85 c0             	test   %ax,%ax
80105fba:	7f 0d                	jg     80105fc9 <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
80105fbc:	83 ec 0c             	sub    $0xc,%esp
80105fbf:	68 a3 98 10 80       	push   $0x801098a3
80105fc4:	e8 3f a6 ff ff       	call   80100608 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105fc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fcc:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105fd0:	66 83 f8 01          	cmp    $0x1,%ax
80105fd4:	75 25                	jne    80105ffb <sys_unlink+0x11b>
80105fd6:	83 ec 0c             	sub    $0xc,%esp
80105fd9:	ff 75 f0             	pushl  -0x10(%ebp)
80105fdc:	e8 98 fe ff ff       	call   80105e79 <isdirempty>
80105fe1:	83 c4 10             	add    $0x10,%esp
80105fe4:	85 c0                	test   %eax,%eax
80105fe6:	75 13                	jne    80105ffb <sys_unlink+0x11b>
    iunlockput(ip);
80105fe8:	83 ec 0c             	sub    $0xc,%esp
80105feb:	ff 75 f0             	pushl  -0x10(%ebp)
80105fee:	e8 a5 bd ff ff       	call   80101d98 <iunlockput>
80105ff3:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105ff6:	e9 b5 00 00 00       	jmp    801060b0 <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
80105ffb:	83 ec 04             	sub    $0x4,%esp
80105ffe:	6a 10                	push   $0x10
80106000:	6a 00                	push   $0x0
80106002:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106005:	50                   	push   %eax
80106006:	e8 6e f5 ff ff       	call   80105579 <memset>
8010600b:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010600e:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106011:	6a 10                	push   $0x10
80106013:	50                   	push   %eax
80106014:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106017:	50                   	push   %eax
80106018:	ff 75 f4             	pushl  -0xc(%ebp)
8010601b:	e8 9c c1 ff ff       	call   801021bc <writei>
80106020:	83 c4 10             	add    $0x10,%esp
80106023:	83 f8 10             	cmp    $0x10,%eax
80106026:	74 0d                	je     80106035 <sys_unlink+0x155>
    panic("unlink: writei");
80106028:	83 ec 0c             	sub    $0xc,%esp
8010602b:	68 b5 98 10 80       	push   $0x801098b5
80106030:	e8 d3 a5 ff ff       	call   80100608 <panic>
  if(ip->type == T_DIR){
80106035:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106038:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010603c:	66 83 f8 01          	cmp    $0x1,%ax
80106040:	75 21                	jne    80106063 <sys_unlink+0x183>
    dp->nlink--;
80106042:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106045:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106049:	83 e8 01             	sub    $0x1,%eax
8010604c:	89 c2                	mov    %eax,%edx
8010604e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106051:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80106055:	83 ec 0c             	sub    $0xc,%esp
80106058:	ff 75 f4             	pushl  -0xc(%ebp)
8010605b:	e8 12 b9 ff ff       	call   80101972 <iupdate>
80106060:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80106063:	83 ec 0c             	sub    $0xc,%esp
80106066:	ff 75 f4             	pushl  -0xc(%ebp)
80106069:	e8 2a bd ff ff       	call   80101d98 <iunlockput>
8010606e:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80106071:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106074:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106078:	83 e8 01             	sub    $0x1,%eax
8010607b:	89 c2                	mov    %eax,%edx
8010607d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106080:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80106084:	83 ec 0c             	sub    $0xc,%esp
80106087:	ff 75 f0             	pushl  -0x10(%ebp)
8010608a:	e8 e3 b8 ff ff       	call   80101972 <iupdate>
8010608f:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106092:	83 ec 0c             	sub    $0xc,%esp
80106095:	ff 75 f0             	pushl  -0x10(%ebp)
80106098:	e8 fb bc ff ff       	call   80101d98 <iunlockput>
8010609d:	83 c4 10             	add    $0x10,%esp

  end_op();
801060a0:	e8 3b d7 ff ff       	call   801037e0 <end_op>

  return 0;
801060a5:	b8 00 00 00 00       	mov    $0x0,%eax
801060aa:	eb 1c                	jmp    801060c8 <sys_unlink+0x1e8>
    goto bad;
801060ac:	90                   	nop
801060ad:	eb 01                	jmp    801060b0 <sys_unlink+0x1d0>
    goto bad;
801060af:	90                   	nop

bad:
  iunlockput(dp);
801060b0:	83 ec 0c             	sub    $0xc,%esp
801060b3:	ff 75 f4             	pushl  -0xc(%ebp)
801060b6:	e8 dd bc ff ff       	call   80101d98 <iunlockput>
801060bb:	83 c4 10             	add    $0x10,%esp
  end_op();
801060be:	e8 1d d7 ff ff       	call   801037e0 <end_op>
  return -1;
801060c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801060c8:	c9                   	leave  
801060c9:	c3                   	ret    

801060ca <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801060ca:	f3 0f 1e fb          	endbr32 
801060ce:	55                   	push   %ebp
801060cf:	89 e5                	mov    %esp,%ebp
801060d1:	83 ec 38             	sub    $0x38,%esp
801060d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801060d7:	8b 55 10             	mov    0x10(%ebp),%edx
801060da:	8b 45 14             	mov    0x14(%ebp),%eax
801060dd:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801060e1:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801060e5:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801060e9:	83 ec 08             	sub    $0x8,%esp
801060ec:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801060ef:	50                   	push   %eax
801060f0:	ff 75 08             	pushl  0x8(%ebp)
801060f3:	e8 ee c5 ff ff       	call   801026e6 <nameiparent>
801060f8:	83 c4 10             	add    $0x10,%esp
801060fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106102:	75 0a                	jne    8010610e <create+0x44>
    return 0;
80106104:	b8 00 00 00 00       	mov    $0x0,%eax
80106109:	e9 8e 01 00 00       	jmp    8010629c <create+0x1d2>
  ilock(dp);
8010610e:	83 ec 0c             	sub    $0xc,%esp
80106111:	ff 75 f4             	pushl  -0xc(%ebp)
80106114:	e8 42 ba ff ff       	call   80101b5b <ilock>
80106119:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, 0)) != 0){
8010611c:	83 ec 04             	sub    $0x4,%esp
8010611f:	6a 00                	push   $0x0
80106121:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106124:	50                   	push   %eax
80106125:	ff 75 f4             	pushl  -0xc(%ebp)
80106128:	e8 38 c2 ff ff       	call   80102365 <dirlookup>
8010612d:	83 c4 10             	add    $0x10,%esp
80106130:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106133:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106137:	74 50                	je     80106189 <create+0xbf>
    iunlockput(dp);
80106139:	83 ec 0c             	sub    $0xc,%esp
8010613c:	ff 75 f4             	pushl  -0xc(%ebp)
8010613f:	e8 54 bc ff ff       	call   80101d98 <iunlockput>
80106144:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80106147:	83 ec 0c             	sub    $0xc,%esp
8010614a:	ff 75 f0             	pushl  -0x10(%ebp)
8010614d:	e8 09 ba ff ff       	call   80101b5b <ilock>
80106152:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80106155:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
8010615a:	75 15                	jne    80106171 <create+0xa7>
8010615c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010615f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106163:	66 83 f8 02          	cmp    $0x2,%ax
80106167:	75 08                	jne    80106171 <create+0xa7>
      return ip;
80106169:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010616c:	e9 2b 01 00 00       	jmp    8010629c <create+0x1d2>
    iunlockput(ip);
80106171:	83 ec 0c             	sub    $0xc,%esp
80106174:	ff 75 f0             	pushl  -0x10(%ebp)
80106177:	e8 1c bc ff ff       	call   80101d98 <iunlockput>
8010617c:	83 c4 10             	add    $0x10,%esp
    return 0;
8010617f:	b8 00 00 00 00       	mov    $0x0,%eax
80106184:	e9 13 01 00 00       	jmp    8010629c <create+0x1d2>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106189:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010618d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106190:	8b 00                	mov    (%eax),%eax
80106192:	83 ec 08             	sub    $0x8,%esp
80106195:	52                   	push   %edx
80106196:	50                   	push   %eax
80106197:	e8 fb b6 ff ff       	call   80101897 <ialloc>
8010619c:	83 c4 10             	add    $0x10,%esp
8010619f:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061a2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061a6:	75 0d                	jne    801061b5 <create+0xeb>
    panic("create: ialloc");
801061a8:	83 ec 0c             	sub    $0xc,%esp
801061ab:	68 c4 98 10 80       	push   $0x801098c4
801061b0:	e8 53 a4 ff ff       	call   80100608 <panic>

  ilock(ip);
801061b5:	83 ec 0c             	sub    $0xc,%esp
801061b8:	ff 75 f0             	pushl  -0x10(%ebp)
801061bb:	e8 9b b9 ff ff       	call   80101b5b <ilock>
801061c0:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801061c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061c6:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801061ca:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
801061ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061d1:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801061d5:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
801061d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061dc:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801061e2:	83 ec 0c             	sub    $0xc,%esp
801061e5:	ff 75 f0             	pushl  -0x10(%ebp)
801061e8:	e8 85 b7 ff ff       	call   80101972 <iupdate>
801061ed:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801061f0:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801061f5:	75 6a                	jne    80106261 <create+0x197>
    dp->nlink++;  // for ".."
801061f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061fa:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801061fe:	83 c0 01             	add    $0x1,%eax
80106201:	89 c2                	mov    %eax,%edx
80106203:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106206:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
8010620a:	83 ec 0c             	sub    $0xc,%esp
8010620d:	ff 75 f4             	pushl  -0xc(%ebp)
80106210:	e8 5d b7 ff ff       	call   80101972 <iupdate>
80106215:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106218:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010621b:	8b 40 04             	mov    0x4(%eax),%eax
8010621e:	83 ec 04             	sub    $0x4,%esp
80106221:	50                   	push   %eax
80106222:	68 9e 98 10 80       	push   $0x8010989e
80106227:	ff 75 f0             	pushl  -0x10(%ebp)
8010622a:	e8 f4 c1 ff ff       	call   80102423 <dirlink>
8010622f:	83 c4 10             	add    $0x10,%esp
80106232:	85 c0                	test   %eax,%eax
80106234:	78 1e                	js     80106254 <create+0x18a>
80106236:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106239:	8b 40 04             	mov    0x4(%eax),%eax
8010623c:	83 ec 04             	sub    $0x4,%esp
8010623f:	50                   	push   %eax
80106240:	68 a0 98 10 80       	push   $0x801098a0
80106245:	ff 75 f0             	pushl  -0x10(%ebp)
80106248:	e8 d6 c1 ff ff       	call   80102423 <dirlink>
8010624d:	83 c4 10             	add    $0x10,%esp
80106250:	85 c0                	test   %eax,%eax
80106252:	79 0d                	jns    80106261 <create+0x197>
      panic("create dots");
80106254:	83 ec 0c             	sub    $0xc,%esp
80106257:	68 d3 98 10 80       	push   $0x801098d3
8010625c:	e8 a7 a3 ff ff       	call   80100608 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106261:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106264:	8b 40 04             	mov    0x4(%eax),%eax
80106267:	83 ec 04             	sub    $0x4,%esp
8010626a:	50                   	push   %eax
8010626b:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010626e:	50                   	push   %eax
8010626f:	ff 75 f4             	pushl  -0xc(%ebp)
80106272:	e8 ac c1 ff ff       	call   80102423 <dirlink>
80106277:	83 c4 10             	add    $0x10,%esp
8010627a:	85 c0                	test   %eax,%eax
8010627c:	79 0d                	jns    8010628b <create+0x1c1>
    panic("create: dirlink");
8010627e:	83 ec 0c             	sub    $0xc,%esp
80106281:	68 df 98 10 80       	push   $0x801098df
80106286:	e8 7d a3 ff ff       	call   80100608 <panic>

  iunlockput(dp);
8010628b:	83 ec 0c             	sub    $0xc,%esp
8010628e:	ff 75 f4             	pushl  -0xc(%ebp)
80106291:	e8 02 bb ff ff       	call   80101d98 <iunlockput>
80106296:	83 c4 10             	add    $0x10,%esp

  return ip;
80106299:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010629c:	c9                   	leave  
8010629d:	c3                   	ret    

8010629e <sys_open>:

int
sys_open(void)
{
8010629e:	f3 0f 1e fb          	endbr32 
801062a2:	55                   	push   %ebp
801062a3:	89 e5                	mov    %esp,%ebp
801062a5:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801062a8:	83 ec 08             	sub    $0x8,%esp
801062ab:	8d 45 e8             	lea    -0x18(%ebp),%eax
801062ae:	50                   	push   %eax
801062af:	6a 00                	push   $0x0
801062b1:	e8 b4 f6 ff ff       	call   8010596a <argstr>
801062b6:	83 c4 10             	add    $0x10,%esp
801062b9:	85 c0                	test   %eax,%eax
801062bb:	78 15                	js     801062d2 <sys_open+0x34>
801062bd:	83 ec 08             	sub    $0x8,%esp
801062c0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801062c3:	50                   	push   %eax
801062c4:	6a 01                	push   $0x1
801062c6:	e8 02 f6 ff ff       	call   801058cd <argint>
801062cb:	83 c4 10             	add    $0x10,%esp
801062ce:	85 c0                	test   %eax,%eax
801062d0:	79 0a                	jns    801062dc <sys_open+0x3e>
    return -1;
801062d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062d7:	e9 61 01 00 00       	jmp    8010643d <sys_open+0x19f>

  begin_op();
801062dc:	e8 6f d4 ff ff       	call   80103750 <begin_op>

  if(omode & O_CREATE){
801062e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062e4:	25 00 02 00 00       	and    $0x200,%eax
801062e9:	85 c0                	test   %eax,%eax
801062eb:	74 2a                	je     80106317 <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
801062ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062f0:	6a 00                	push   $0x0
801062f2:	6a 00                	push   $0x0
801062f4:	6a 02                	push   $0x2
801062f6:	50                   	push   %eax
801062f7:	e8 ce fd ff ff       	call   801060ca <create>
801062fc:	83 c4 10             	add    $0x10,%esp
801062ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106302:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106306:	75 75                	jne    8010637d <sys_open+0xdf>
      end_op();
80106308:	e8 d3 d4 ff ff       	call   801037e0 <end_op>
      return -1;
8010630d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106312:	e9 26 01 00 00       	jmp    8010643d <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
80106317:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010631a:	83 ec 0c             	sub    $0xc,%esp
8010631d:	50                   	push   %eax
8010631e:	e8 a3 c3 ff ff       	call   801026c6 <namei>
80106323:	83 c4 10             	add    $0x10,%esp
80106326:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106329:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010632d:	75 0f                	jne    8010633e <sys_open+0xa0>
      end_op();
8010632f:	e8 ac d4 ff ff       	call   801037e0 <end_op>
      return -1;
80106334:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106339:	e9 ff 00 00 00       	jmp    8010643d <sys_open+0x19f>
    }
    ilock(ip);
8010633e:	83 ec 0c             	sub    $0xc,%esp
80106341:	ff 75 f4             	pushl  -0xc(%ebp)
80106344:	e8 12 b8 ff ff       	call   80101b5b <ilock>
80106349:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
8010634c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010634f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106353:	66 83 f8 01          	cmp    $0x1,%ax
80106357:	75 24                	jne    8010637d <sys_open+0xdf>
80106359:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010635c:	85 c0                	test   %eax,%eax
8010635e:	74 1d                	je     8010637d <sys_open+0xdf>
      iunlockput(ip);
80106360:	83 ec 0c             	sub    $0xc,%esp
80106363:	ff 75 f4             	pushl  -0xc(%ebp)
80106366:	e8 2d ba ff ff       	call   80101d98 <iunlockput>
8010636b:	83 c4 10             	add    $0x10,%esp
      end_op();
8010636e:	e8 6d d4 ff ff       	call   801037e0 <end_op>
      return -1;
80106373:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106378:	e9 c0 00 00 00       	jmp    8010643d <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010637d:	e8 93 ad ff ff       	call   80101115 <filealloc>
80106382:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106385:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106389:	74 17                	je     801063a2 <sys_open+0x104>
8010638b:	83 ec 0c             	sub    $0xc,%esp
8010638e:	ff 75 f0             	pushl  -0x10(%ebp)
80106391:	e8 09 f7 ff ff       	call   80105a9f <fdalloc>
80106396:	83 c4 10             	add    $0x10,%esp
80106399:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010639c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801063a0:	79 2e                	jns    801063d0 <sys_open+0x132>
    if(f)
801063a2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063a6:	74 0e                	je     801063b6 <sys_open+0x118>
      fileclose(f);
801063a8:	83 ec 0c             	sub    $0xc,%esp
801063ab:	ff 75 f0             	pushl  -0x10(%ebp)
801063ae:	e8 28 ae ff ff       	call   801011db <fileclose>
801063b3:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801063b6:	83 ec 0c             	sub    $0xc,%esp
801063b9:	ff 75 f4             	pushl  -0xc(%ebp)
801063bc:	e8 d7 b9 ff ff       	call   80101d98 <iunlockput>
801063c1:	83 c4 10             	add    $0x10,%esp
    end_op();
801063c4:	e8 17 d4 ff ff       	call   801037e0 <end_op>
    return -1;
801063c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063ce:	eb 6d                	jmp    8010643d <sys_open+0x19f>
  }
  iunlock(ip);
801063d0:	83 ec 0c             	sub    $0xc,%esp
801063d3:	ff 75 f4             	pushl  -0xc(%ebp)
801063d6:	e8 97 b8 ff ff       	call   80101c72 <iunlock>
801063db:	83 c4 10             	add    $0x10,%esp
  end_op();
801063de:	e8 fd d3 ff ff       	call   801037e0 <end_op>

  f->type = FD_INODE;
801063e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063e6:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801063ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063f2:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801063f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063f8:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801063ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106402:	83 e0 01             	and    $0x1,%eax
80106405:	85 c0                	test   %eax,%eax
80106407:	0f 94 c0             	sete   %al
8010640a:	89 c2                	mov    %eax,%edx
8010640c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010640f:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106412:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106415:	83 e0 01             	and    $0x1,%eax
80106418:	85 c0                	test   %eax,%eax
8010641a:	75 0a                	jne    80106426 <sys_open+0x188>
8010641c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010641f:	83 e0 02             	and    $0x2,%eax
80106422:	85 c0                	test   %eax,%eax
80106424:	74 07                	je     8010642d <sys_open+0x18f>
80106426:	b8 01 00 00 00       	mov    $0x1,%eax
8010642b:	eb 05                	jmp    80106432 <sys_open+0x194>
8010642d:	b8 00 00 00 00       	mov    $0x0,%eax
80106432:	89 c2                	mov    %eax,%edx
80106434:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106437:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010643a:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010643d:	c9                   	leave  
8010643e:	c3                   	ret    

8010643f <sys_mkdir>:

int
sys_mkdir(void)
{
8010643f:	f3 0f 1e fb          	endbr32 
80106443:	55                   	push   %ebp
80106444:	89 e5                	mov    %esp,%ebp
80106446:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106449:	e8 02 d3 ff ff       	call   80103750 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010644e:	83 ec 08             	sub    $0x8,%esp
80106451:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106454:	50                   	push   %eax
80106455:	6a 00                	push   $0x0
80106457:	e8 0e f5 ff ff       	call   8010596a <argstr>
8010645c:	83 c4 10             	add    $0x10,%esp
8010645f:	85 c0                	test   %eax,%eax
80106461:	78 1b                	js     8010647e <sys_mkdir+0x3f>
80106463:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106466:	6a 00                	push   $0x0
80106468:	6a 00                	push   $0x0
8010646a:	6a 01                	push   $0x1
8010646c:	50                   	push   %eax
8010646d:	e8 58 fc ff ff       	call   801060ca <create>
80106472:	83 c4 10             	add    $0x10,%esp
80106475:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106478:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010647c:	75 0c                	jne    8010648a <sys_mkdir+0x4b>
    end_op();
8010647e:	e8 5d d3 ff ff       	call   801037e0 <end_op>
    return -1;
80106483:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106488:	eb 18                	jmp    801064a2 <sys_mkdir+0x63>
  }
  iunlockput(ip);
8010648a:	83 ec 0c             	sub    $0xc,%esp
8010648d:	ff 75 f4             	pushl  -0xc(%ebp)
80106490:	e8 03 b9 ff ff       	call   80101d98 <iunlockput>
80106495:	83 c4 10             	add    $0x10,%esp
  end_op();
80106498:	e8 43 d3 ff ff       	call   801037e0 <end_op>
  return 0;
8010649d:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064a2:	c9                   	leave  
801064a3:	c3                   	ret    

801064a4 <sys_mknod>:

int
sys_mknod(void)
{
801064a4:	f3 0f 1e fb          	endbr32 
801064a8:	55                   	push   %ebp
801064a9:	89 e5                	mov    %esp,%ebp
801064ab:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801064ae:	e8 9d d2 ff ff       	call   80103750 <begin_op>
  if((argstr(0, &path)) < 0 ||
801064b3:	83 ec 08             	sub    $0x8,%esp
801064b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064b9:	50                   	push   %eax
801064ba:	6a 00                	push   $0x0
801064bc:	e8 a9 f4 ff ff       	call   8010596a <argstr>
801064c1:	83 c4 10             	add    $0x10,%esp
801064c4:	85 c0                	test   %eax,%eax
801064c6:	78 4f                	js     80106517 <sys_mknod+0x73>
     argint(1, &major) < 0 ||
801064c8:	83 ec 08             	sub    $0x8,%esp
801064cb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801064ce:	50                   	push   %eax
801064cf:	6a 01                	push   $0x1
801064d1:	e8 f7 f3 ff ff       	call   801058cd <argint>
801064d6:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
801064d9:	85 c0                	test   %eax,%eax
801064db:	78 3a                	js     80106517 <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
801064dd:	83 ec 08             	sub    $0x8,%esp
801064e0:	8d 45 e8             	lea    -0x18(%ebp),%eax
801064e3:	50                   	push   %eax
801064e4:	6a 02                	push   $0x2
801064e6:	e8 e2 f3 ff ff       	call   801058cd <argint>
801064eb:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
801064ee:	85 c0                	test   %eax,%eax
801064f0:	78 25                	js     80106517 <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
801064f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064f5:	0f bf c8             	movswl %ax,%ecx
801064f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801064fb:	0f bf d0             	movswl %ax,%edx
801064fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106501:	51                   	push   %ecx
80106502:	52                   	push   %edx
80106503:	6a 03                	push   $0x3
80106505:	50                   	push   %eax
80106506:	e8 bf fb ff ff       	call   801060ca <create>
8010650b:	83 c4 10             	add    $0x10,%esp
8010650e:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80106511:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106515:	75 0c                	jne    80106523 <sys_mknod+0x7f>
    end_op();
80106517:	e8 c4 d2 ff ff       	call   801037e0 <end_op>
    return -1;
8010651c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106521:	eb 18                	jmp    8010653b <sys_mknod+0x97>
  }
  iunlockput(ip);
80106523:	83 ec 0c             	sub    $0xc,%esp
80106526:	ff 75 f4             	pushl  -0xc(%ebp)
80106529:	e8 6a b8 ff ff       	call   80101d98 <iunlockput>
8010652e:	83 c4 10             	add    $0x10,%esp
  end_op();
80106531:	e8 aa d2 ff ff       	call   801037e0 <end_op>
  return 0;
80106536:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010653b:	c9                   	leave  
8010653c:	c3                   	ret    

8010653d <sys_chdir>:

int
sys_chdir(void)
{
8010653d:	f3 0f 1e fb          	endbr32 
80106541:	55                   	push   %ebp
80106542:	89 e5                	mov    %esp,%ebp
80106544:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80106547:	e8 c3 df ff ff       	call   8010450f <myproc>
8010654c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
8010654f:	e8 fc d1 ff ff       	call   80103750 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106554:	83 ec 08             	sub    $0x8,%esp
80106557:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010655a:	50                   	push   %eax
8010655b:	6a 00                	push   $0x0
8010655d:	e8 08 f4 ff ff       	call   8010596a <argstr>
80106562:	83 c4 10             	add    $0x10,%esp
80106565:	85 c0                	test   %eax,%eax
80106567:	78 18                	js     80106581 <sys_chdir+0x44>
80106569:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010656c:	83 ec 0c             	sub    $0xc,%esp
8010656f:	50                   	push   %eax
80106570:	e8 51 c1 ff ff       	call   801026c6 <namei>
80106575:	83 c4 10             	add    $0x10,%esp
80106578:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010657b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010657f:	75 0c                	jne    8010658d <sys_chdir+0x50>
    end_op();
80106581:	e8 5a d2 ff ff       	call   801037e0 <end_op>
    return -1;
80106586:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010658b:	eb 68                	jmp    801065f5 <sys_chdir+0xb8>
  }
  ilock(ip);
8010658d:	83 ec 0c             	sub    $0xc,%esp
80106590:	ff 75 f0             	pushl  -0x10(%ebp)
80106593:	e8 c3 b5 ff ff       	call   80101b5b <ilock>
80106598:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
8010659b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010659e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801065a2:	66 83 f8 01          	cmp    $0x1,%ax
801065a6:	74 1a                	je     801065c2 <sys_chdir+0x85>
    iunlockput(ip);
801065a8:	83 ec 0c             	sub    $0xc,%esp
801065ab:	ff 75 f0             	pushl  -0x10(%ebp)
801065ae:	e8 e5 b7 ff ff       	call   80101d98 <iunlockput>
801065b3:	83 c4 10             	add    $0x10,%esp
    end_op();
801065b6:	e8 25 d2 ff ff       	call   801037e0 <end_op>
    return -1;
801065bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065c0:	eb 33                	jmp    801065f5 <sys_chdir+0xb8>
  }
  iunlock(ip);
801065c2:	83 ec 0c             	sub    $0xc,%esp
801065c5:	ff 75 f0             	pushl  -0x10(%ebp)
801065c8:	e8 a5 b6 ff ff       	call   80101c72 <iunlock>
801065cd:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
801065d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065d3:	8b 40 68             	mov    0x68(%eax),%eax
801065d6:	83 ec 0c             	sub    $0xc,%esp
801065d9:	50                   	push   %eax
801065da:	e8 e5 b6 ff ff       	call   80101cc4 <iput>
801065df:	83 c4 10             	add    $0x10,%esp
  end_op();
801065e2:	e8 f9 d1 ff ff       	call   801037e0 <end_op>
  curproc->cwd = ip;
801065e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065ea:	8b 55 f0             	mov    -0x10(%ebp),%edx
801065ed:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801065f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065f5:	c9                   	leave  
801065f6:	c3                   	ret    

801065f7 <sys_exec>:

int
sys_exec(void)
{
801065f7:	f3 0f 1e fb          	endbr32 
801065fb:	55                   	push   %ebp
801065fc:	89 e5                	mov    %esp,%ebp
801065fe:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106604:	83 ec 08             	sub    $0x8,%esp
80106607:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010660a:	50                   	push   %eax
8010660b:	6a 00                	push   $0x0
8010660d:	e8 58 f3 ff ff       	call   8010596a <argstr>
80106612:	83 c4 10             	add    $0x10,%esp
80106615:	85 c0                	test   %eax,%eax
80106617:	78 18                	js     80106631 <sys_exec+0x3a>
80106619:	83 ec 08             	sub    $0x8,%esp
8010661c:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106622:	50                   	push   %eax
80106623:	6a 01                	push   $0x1
80106625:	e8 a3 f2 ff ff       	call   801058cd <argint>
8010662a:	83 c4 10             	add    $0x10,%esp
8010662d:	85 c0                	test   %eax,%eax
8010662f:	79 0a                	jns    8010663b <sys_exec+0x44>
    return -1;
80106631:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106636:	e9 c6 00 00 00       	jmp    80106701 <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
8010663b:	83 ec 04             	sub    $0x4,%esp
8010663e:	68 80 00 00 00       	push   $0x80
80106643:	6a 00                	push   $0x0
80106645:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010664b:	50                   	push   %eax
8010664c:	e8 28 ef ff ff       	call   80105579 <memset>
80106651:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106654:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010665b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010665e:	83 f8 1f             	cmp    $0x1f,%eax
80106661:	76 0a                	jbe    8010666d <sys_exec+0x76>
      return -1;
80106663:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106668:	e9 94 00 00 00       	jmp    80106701 <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010666d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106670:	c1 e0 02             	shl    $0x2,%eax
80106673:	89 c2                	mov    %eax,%edx
80106675:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010667b:	01 c2                	add    %eax,%edx
8010667d:	83 ec 08             	sub    $0x8,%esp
80106680:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106686:	50                   	push   %eax
80106687:	52                   	push   %edx
80106688:	e8 95 f1 ff ff       	call   80105822 <fetchint>
8010668d:	83 c4 10             	add    $0x10,%esp
80106690:	85 c0                	test   %eax,%eax
80106692:	79 07                	jns    8010669b <sys_exec+0xa4>
      return -1;
80106694:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106699:	eb 66                	jmp    80106701 <sys_exec+0x10a>
    if(uarg == 0){
8010669b:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801066a1:	85 c0                	test   %eax,%eax
801066a3:	75 27                	jne    801066cc <sys_exec+0xd5>
      argv[i] = 0;
801066a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066a8:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801066af:	00 00 00 00 
      break;
801066b3:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801066b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066b7:	83 ec 08             	sub    $0x8,%esp
801066ba:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801066c0:	52                   	push   %edx
801066c1:	50                   	push   %eax
801066c2:	e8 69 a5 ff ff       	call   80100c30 <exec>
801066c7:	83 c4 10             	add    $0x10,%esp
801066ca:	eb 35                	jmp    80106701 <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
801066cc:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801066d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066d5:	c1 e2 02             	shl    $0x2,%edx
801066d8:	01 c2                	add    %eax,%edx
801066da:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801066e0:	83 ec 08             	sub    $0x8,%esp
801066e3:	52                   	push   %edx
801066e4:	50                   	push   %eax
801066e5:	e8 7b f1 ff ff       	call   80105865 <fetchstr>
801066ea:	83 c4 10             	add    $0x10,%esp
801066ed:	85 c0                	test   %eax,%eax
801066ef:	79 07                	jns    801066f8 <sys_exec+0x101>
      return -1;
801066f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066f6:	eb 09                	jmp    80106701 <sys_exec+0x10a>
  for(i=0;; i++){
801066f8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
801066fc:	e9 5a ff ff ff       	jmp    8010665b <sys_exec+0x64>
}
80106701:	c9                   	leave  
80106702:	c3                   	ret    

80106703 <sys_pipe>:

int
sys_pipe(void)
{
80106703:	f3 0f 1e fb          	endbr32 
80106707:	55                   	push   %ebp
80106708:	89 e5                	mov    %esp,%ebp
8010670a:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010670d:	83 ec 04             	sub    $0x4,%esp
80106710:	6a 08                	push   $0x8
80106712:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106715:	50                   	push   %eax
80106716:	6a 00                	push   $0x0
80106718:	e8 e1 f1 ff ff       	call   801058fe <argptr>
8010671d:	83 c4 10             	add    $0x10,%esp
80106720:	85 c0                	test   %eax,%eax
80106722:	79 0a                	jns    8010672e <sys_pipe+0x2b>
    return -1;
80106724:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106729:	e9 ae 00 00 00       	jmp    801067dc <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
8010672e:	83 ec 08             	sub    $0x8,%esp
80106731:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106734:	50                   	push   %eax
80106735:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106738:	50                   	push   %eax
80106739:	e8 f2 d8 ff ff       	call   80104030 <pipealloc>
8010673e:	83 c4 10             	add    $0x10,%esp
80106741:	85 c0                	test   %eax,%eax
80106743:	79 0a                	jns    8010674f <sys_pipe+0x4c>
    return -1;
80106745:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010674a:	e9 8d 00 00 00       	jmp    801067dc <sys_pipe+0xd9>
  fd0 = -1;
8010674f:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106756:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106759:	83 ec 0c             	sub    $0xc,%esp
8010675c:	50                   	push   %eax
8010675d:	e8 3d f3 ff ff       	call   80105a9f <fdalloc>
80106762:	83 c4 10             	add    $0x10,%esp
80106765:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106768:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010676c:	78 18                	js     80106786 <sys_pipe+0x83>
8010676e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106771:	83 ec 0c             	sub    $0xc,%esp
80106774:	50                   	push   %eax
80106775:	e8 25 f3 ff ff       	call   80105a9f <fdalloc>
8010677a:	83 c4 10             	add    $0x10,%esp
8010677d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106780:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106784:	79 3e                	jns    801067c4 <sys_pipe+0xc1>
    if(fd0 >= 0)
80106786:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010678a:	78 13                	js     8010679f <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
8010678c:	e8 7e dd ff ff       	call   8010450f <myproc>
80106791:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106794:	83 c2 08             	add    $0x8,%edx
80106797:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010679e:	00 
    fileclose(rf);
8010679f:	8b 45 e8             	mov    -0x18(%ebp),%eax
801067a2:	83 ec 0c             	sub    $0xc,%esp
801067a5:	50                   	push   %eax
801067a6:	e8 30 aa ff ff       	call   801011db <fileclose>
801067ab:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
801067ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067b1:	83 ec 0c             	sub    $0xc,%esp
801067b4:	50                   	push   %eax
801067b5:	e8 21 aa ff ff       	call   801011db <fileclose>
801067ba:	83 c4 10             	add    $0x10,%esp
    return -1;
801067bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067c2:	eb 18                	jmp    801067dc <sys_pipe+0xd9>
  }
  fd[0] = fd0;
801067c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801067c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067ca:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801067cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801067cf:	8d 50 04             	lea    0x4(%eax),%edx
801067d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067d5:	89 02                	mov    %eax,(%edx)
  return 0;
801067d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067dc:	c9                   	leave  
801067dd:	c3                   	ret    

801067de <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801067de:	f3 0f 1e fb          	endbr32 
801067e2:	55                   	push   %ebp
801067e3:	89 e5                	mov    %esp,%ebp
801067e5:	83 ec 08             	sub    $0x8,%esp
  return fork();
801067e8:	e8 ac e0 ff ff       	call   80104899 <fork>
}
801067ed:	c9                   	leave  
801067ee:	c3                   	ret    

801067ef <sys_exit>:

int
sys_exit(void)
{
801067ef:	f3 0f 1e fb          	endbr32 
801067f3:	55                   	push   %ebp
801067f4:	89 e5                	mov    %esp,%ebp
801067f6:	83 ec 08             	sub    $0x8,%esp
  exit();
801067f9:	e8 18 e2 ff ff       	call   80104a16 <exit>
  return 0;  // not reached
801067fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106803:	c9                   	leave  
80106804:	c3                   	ret    

80106805 <sys_wait>:

int
sys_wait(void)
{
80106805:	f3 0f 1e fb          	endbr32 
80106809:	55                   	push   %ebp
8010680a:	89 e5                	mov    %esp,%ebp
8010680c:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010680f:	e8 29 e3 ff ff       	call   80104b3d <wait>
}
80106814:	c9                   	leave  
80106815:	c3                   	ret    

80106816 <sys_kill>:

int
sys_kill(void)
{
80106816:	f3 0f 1e fb          	endbr32 
8010681a:	55                   	push   %ebp
8010681b:	89 e5                	mov    %esp,%ebp
8010681d:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106820:	83 ec 08             	sub    $0x8,%esp
80106823:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106826:	50                   	push   %eax
80106827:	6a 00                	push   $0x0
80106829:	e8 9f f0 ff ff       	call   801058cd <argint>
8010682e:	83 c4 10             	add    $0x10,%esp
80106831:	85 c0                	test   %eax,%eax
80106833:	79 07                	jns    8010683c <sys_kill+0x26>
    return -1;
80106835:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010683a:	eb 0f                	jmp    8010684b <sys_kill+0x35>
  return kill(pid);
8010683c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010683f:	83 ec 0c             	sub    $0xc,%esp
80106842:	50                   	push   %eax
80106843:	e8 4d e7 ff ff       	call   80104f95 <kill>
80106848:	83 c4 10             	add    $0x10,%esp
}
8010684b:	c9                   	leave  
8010684c:	c3                   	ret    

8010684d <sys_getpid>:

int
sys_getpid(void)
{
8010684d:	f3 0f 1e fb          	endbr32 
80106851:	55                   	push   %ebp
80106852:	89 e5                	mov    %esp,%ebp
80106854:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106857:	e8 b3 dc ff ff       	call   8010450f <myproc>
8010685c:	8b 40 10             	mov    0x10(%eax),%eax
}
8010685f:	c9                   	leave  
80106860:	c3                   	ret    

80106861 <sys_sbrk>:

int
sys_sbrk(void)
{
80106861:	f3 0f 1e fb          	endbr32 
80106865:	55                   	push   %ebp
80106866:	89 e5                	mov    %esp,%ebp
80106868:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010686b:	83 ec 08             	sub    $0x8,%esp
8010686e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106871:	50                   	push   %eax
80106872:	6a 00                	push   $0x0
80106874:	e8 54 f0 ff ff       	call   801058cd <argint>
80106879:	83 c4 10             	add    $0x10,%esp
8010687c:	85 c0                	test   %eax,%eax
8010687e:	79 07                	jns    80106887 <sys_sbrk+0x26>
    return -1;
80106880:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106885:	eb 27                	jmp    801068ae <sys_sbrk+0x4d>
  addr = myproc()->sz;
80106887:	e8 83 dc ff ff       	call   8010450f <myproc>
8010688c:	8b 00                	mov    (%eax),%eax
8010688e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106891:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106894:	83 ec 0c             	sub    $0xc,%esp
80106897:	50                   	push   %eax
80106898:	e8 e9 de ff ff       	call   80104786 <growproc>
8010689d:	83 c4 10             	add    $0x10,%esp
801068a0:	85 c0                	test   %eax,%eax
801068a2:	79 07                	jns    801068ab <sys_sbrk+0x4a>
    return -1;
801068a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068a9:	eb 03                	jmp    801068ae <sys_sbrk+0x4d>
  return addr;
801068ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801068ae:	c9                   	leave  
801068af:	c3                   	ret    

801068b0 <sys_sleep>:

int
sys_sleep(void)
{
801068b0:	f3 0f 1e fb          	endbr32 
801068b4:	55                   	push   %ebp
801068b5:	89 e5                	mov    %esp,%ebp
801068b7:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801068ba:	83 ec 08             	sub    $0x8,%esp
801068bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801068c0:	50                   	push   %eax
801068c1:	6a 00                	push   $0x0
801068c3:	e8 05 f0 ff ff       	call   801058cd <argint>
801068c8:	83 c4 10             	add    $0x10,%esp
801068cb:	85 c0                	test   %eax,%eax
801068cd:	79 07                	jns    801068d6 <sys_sleep+0x26>
    return -1;
801068cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068d4:	eb 76                	jmp    8010694c <sys_sleep+0x9c>
  acquire(&tickslock);
801068d6:	83 ec 0c             	sub    $0xc,%esp
801068d9:	68 00 77 11 80       	push   $0x80117700
801068de:	e8 f7 e9 ff ff       	call   801052da <acquire>
801068e3:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801068e6:	a1 40 7f 11 80       	mov    0x80117f40,%eax
801068eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801068ee:	eb 38                	jmp    80106928 <sys_sleep+0x78>
    if(myproc()->killed){
801068f0:	e8 1a dc ff ff       	call   8010450f <myproc>
801068f5:	8b 40 24             	mov    0x24(%eax),%eax
801068f8:	85 c0                	test   %eax,%eax
801068fa:	74 17                	je     80106913 <sys_sleep+0x63>
      release(&tickslock);
801068fc:	83 ec 0c             	sub    $0xc,%esp
801068ff:	68 00 77 11 80       	push   $0x80117700
80106904:	e8 43 ea ff ff       	call   8010534c <release>
80106909:	83 c4 10             	add    $0x10,%esp
      return -1;
8010690c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106911:	eb 39                	jmp    8010694c <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
80106913:	83 ec 08             	sub    $0x8,%esp
80106916:	68 00 77 11 80       	push   $0x80117700
8010691b:	68 40 7f 11 80       	push   $0x80117f40
80106920:	e8 43 e5 ff ff       	call   80104e68 <sleep>
80106925:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106928:	a1 40 7f 11 80       	mov    0x80117f40,%eax
8010692d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106930:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106933:	39 d0                	cmp    %edx,%eax
80106935:	72 b9                	jb     801068f0 <sys_sleep+0x40>
  }
  release(&tickslock);
80106937:	83 ec 0c             	sub    $0xc,%esp
8010693a:	68 00 77 11 80       	push   $0x80117700
8010693f:	e8 08 ea ff ff       	call   8010534c <release>
80106944:	83 c4 10             	add    $0x10,%esp
  return 0;
80106947:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010694c:	c9                   	leave  
8010694d:	c3                   	ret    

8010694e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010694e:	f3 0f 1e fb          	endbr32 
80106952:	55                   	push   %ebp
80106953:	89 e5                	mov    %esp,%ebp
80106955:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106958:	83 ec 0c             	sub    $0xc,%esp
8010695b:	68 00 77 11 80       	push   $0x80117700
80106960:	e8 75 e9 ff ff       	call   801052da <acquire>
80106965:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106968:	a1 40 7f 11 80       	mov    0x80117f40,%eax
8010696d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106970:	83 ec 0c             	sub    $0xc,%esp
80106973:	68 00 77 11 80       	push   $0x80117700
80106978:	e8 cf e9 ff ff       	call   8010534c <release>
8010697d:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106980:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106983:	c9                   	leave  
80106984:	c3                   	ret    

80106985 <sys_mencrypt>:

//changed: added wrapper here
int sys_mencrypt(void) {
80106985:	f3 0f 1e fb          	endbr32 
80106989:	55                   	push   %ebp
8010698a:	89 e5                	mov    %esp,%ebp
8010698c:	83 ec 18             	sub    $0x18,%esp
  int len;
  char * virtual_addr;

  if(argint(1, &len) < 0)
8010698f:	83 ec 08             	sub    $0x8,%esp
80106992:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106995:	50                   	push   %eax
80106996:	6a 01                	push   $0x1
80106998:	e8 30 ef ff ff       	call   801058cd <argint>
8010699d:	83 c4 10             	add    $0x10,%esp
801069a0:	85 c0                	test   %eax,%eax
801069a2:	79 07                	jns    801069ab <sys_mencrypt+0x26>
    return -1;
801069a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069a9:	eb 50                	jmp    801069fb <sys_mencrypt+0x76>
  if (len <= 0) {
801069ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ae:	85 c0                	test   %eax,%eax
801069b0:	7f 07                	jg     801069b9 <sys_mencrypt+0x34>
    return -1;
801069b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069b7:	eb 42                	jmp    801069fb <sys_mencrypt+0x76>
  }
  if(argptr(0, &virtual_addr, 1) < 0)
801069b9:	83 ec 04             	sub    $0x4,%esp
801069bc:	6a 01                	push   $0x1
801069be:	8d 45 f0             	lea    -0x10(%ebp),%eax
801069c1:	50                   	push   %eax
801069c2:	6a 00                	push   $0x0
801069c4:	e8 35 ef ff ff       	call   801058fe <argptr>
801069c9:	83 c4 10             	add    $0x10,%esp
801069cc:	85 c0                	test   %eax,%eax
801069ce:	79 07                	jns    801069d7 <sys_mencrypt+0x52>
    return -1;
801069d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069d5:	eb 24                	jmp    801069fb <sys_mencrypt+0x76>
  if ((void *) virtual_addr >= P2V(PHYSTOP)) {
801069d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069da:	3d ff ff ff 8d       	cmp    $0x8dffffff,%eax
801069df:	76 07                	jbe    801069e8 <sys_mencrypt+0x63>
    return -1;
801069e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069e6:	eb 13                	jmp    801069fb <sys_mencrypt+0x76>
  }
  return mencrypt(virtual_addr, len);
801069e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801069eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069ee:	83 ec 08             	sub    $0x8,%esp
801069f1:	52                   	push   %edx
801069f2:	50                   	push   %eax
801069f3:	e8 74 24 00 00       	call   80108e6c <mencrypt>
801069f8:	83 c4 10             	add    $0x10,%esp
}
801069fb:	c9                   	leave  
801069fc:	c3                   	ret    

801069fd <sys_getpgtable>:

int sys_getpgtable(void) {
801069fd:	f3 0f 1e fb          	endbr32 
80106a01:	55                   	push   %ebp
80106a02:	89 e5                	mov    %esp,%ebp
80106a04:	83 ec 18             	sub    $0x18,%esp
  struct pt_entry * entries; 
  int num,wsetOnly;

  if(argint(1, &num) < 0)
80106a07:	83 ec 08             	sub    $0x8,%esp
80106a0a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a0d:	50                   	push   %eax
80106a0e:	6a 01                	push   $0x1
80106a10:	e8 b8 ee ff ff       	call   801058cd <argint>
80106a15:	83 c4 10             	add    $0x10,%esp
80106a18:	85 c0                	test   %eax,%eax
80106a1a:	79 07                	jns    80106a23 <sys_getpgtable+0x26>
    return -1;
80106a1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a21:	eb 56                	jmp    80106a79 <sys_getpgtable+0x7c>
  if(argint(2, &wsetOnly) < 0)
80106a23:	83 ec 08             	sub    $0x8,%esp
80106a26:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106a29:	50                   	push   %eax
80106a2a:	6a 02                	push   $0x2
80106a2c:	e8 9c ee ff ff       	call   801058cd <argint>
80106a31:	83 c4 10             	add    $0x10,%esp
80106a34:	85 c0                	test   %eax,%eax
80106a36:	79 07                	jns    80106a3f <sys_getpgtable+0x42>
    return -1;
80106a38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a3d:	eb 3a                	jmp    80106a79 <sys_getpgtable+0x7c>
  if(argptr(0, (char**)&entries, num*sizeof(struct pt_entry)) < 0){
80106a3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a42:	c1 e0 03             	shl    $0x3,%eax
80106a45:	83 ec 04             	sub    $0x4,%esp
80106a48:	50                   	push   %eax
80106a49:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a4c:	50                   	push   %eax
80106a4d:	6a 00                	push   $0x0
80106a4f:	e8 aa ee ff ff       	call   801058fe <argptr>
80106a54:	83 c4 10             	add    $0x10,%esp
80106a57:	85 c0                	test   %eax,%eax
80106a59:	79 07                	jns    80106a62 <sys_getpgtable+0x65>
    return -1;
80106a5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a60:	eb 17                	jmp    80106a79 <sys_getpgtable+0x7c>
  }
  return getpgtable(entries, num,wsetOnly);
80106a62:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80106a65:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a6b:	83 ec 04             	sub    $0x4,%esp
80106a6e:	51                   	push   %ecx
80106a6f:	52                   	push   %edx
80106a70:	50                   	push   %eax
80106a71:	e8 eb 25 00 00       	call   80109061 <getpgtable>
80106a76:	83 c4 10             	add    $0x10,%esp
}
80106a79:	c9                   	leave  
80106a7a:	c3                   	ret    

80106a7b <sys_dump_rawphymem>:


int sys_dump_rawphymem(void) {
80106a7b:	f3 0f 1e fb          	endbr32 
80106a7f:	55                   	push   %ebp
80106a80:	89 e5                	mov    %esp,%ebp
80106a82:	83 ec 18             	sub    $0x18,%esp
  char * physical_addr; 
  char * buffer;
  if(argptr(1, &buffer, PGSIZE) < 0)
80106a85:	83 ec 04             	sub    $0x4,%esp
80106a88:	68 00 10 00 00       	push   $0x1000
80106a8d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a90:	50                   	push   %eax
80106a91:	6a 01                	push   $0x1
80106a93:	e8 66 ee ff ff       	call   801058fe <argptr>
80106a98:	83 c4 10             	add    $0x10,%esp
80106a9b:	85 c0                	test   %eax,%eax
80106a9d:	79 07                	jns    80106aa6 <sys_dump_rawphymem+0x2b>
    return -1;
80106a9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106aa4:	eb 2f                	jmp    80106ad5 <sys_dump_rawphymem+0x5a>
  if(argint(0, (int*)&physical_addr) < 0)
80106aa6:	83 ec 08             	sub    $0x8,%esp
80106aa9:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106aac:	50                   	push   %eax
80106aad:	6a 00                	push   $0x0
80106aaf:	e8 19 ee ff ff       	call   801058cd <argint>
80106ab4:	83 c4 10             	add    $0x10,%esp
80106ab7:	85 c0                	test   %eax,%eax
80106ab9:	79 07                	jns    80106ac2 <sys_dump_rawphymem+0x47>
    return -1;
80106abb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ac0:	eb 13                	jmp    80106ad5 <sys_dump_rawphymem+0x5a>
  return dump_rawphymem(physical_addr, buffer);
80106ac2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ac8:	83 ec 08             	sub    $0x8,%esp
80106acb:	52                   	push   %edx
80106acc:	50                   	push   %eax
80106acd:	e8 1f 28 00 00       	call   801092f1 <dump_rawphymem>
80106ad2:	83 c4 10             	add    $0x10,%esp
80106ad5:	c9                   	leave  
80106ad6:	c3                   	ret    

80106ad7 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106ad7:	1e                   	push   %ds
  pushl %es
80106ad8:	06                   	push   %es
  pushl %fs
80106ad9:	0f a0                	push   %fs
  pushl %gs
80106adb:	0f a8                	push   %gs
  pushal
80106add:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106ade:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106ae2:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106ae4:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106ae6:	54                   	push   %esp
  call trap
80106ae7:	e8 df 01 00 00       	call   80106ccb <trap>
  addl $4, %esp
80106aec:	83 c4 04             	add    $0x4,%esp

80106aef <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106aef:	61                   	popa   
  popl %gs
80106af0:	0f a9                	pop    %gs
  popl %fs
80106af2:	0f a1                	pop    %fs
  popl %es
80106af4:	07                   	pop    %es
  popl %ds
80106af5:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106af6:	83 c4 08             	add    $0x8,%esp
  iret
80106af9:	cf                   	iret   

80106afa <lidt>:
{
80106afa:	55                   	push   %ebp
80106afb:	89 e5                	mov    %esp,%ebp
80106afd:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106b00:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b03:	83 e8 01             	sub    $0x1,%eax
80106b06:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106b0a:	8b 45 08             	mov    0x8(%ebp),%eax
80106b0d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106b11:	8b 45 08             	mov    0x8(%ebp),%eax
80106b14:	c1 e8 10             	shr    $0x10,%eax
80106b17:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106b1b:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106b1e:	0f 01 18             	lidtl  (%eax)
}
80106b21:	90                   	nop
80106b22:	c9                   	leave  
80106b23:	c3                   	ret    

80106b24 <rcr2>:

static inline uint
rcr2(void)
{
80106b24:	55                   	push   %ebp
80106b25:	89 e5                	mov    %esp,%ebp
80106b27:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106b2a:	0f 20 d0             	mov    %cr2,%eax
80106b2d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106b30:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106b33:	c9                   	leave  
80106b34:	c3                   	ret    

80106b35 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106b35:	f3 0f 1e fb          	endbr32 
80106b39:	55                   	push   %ebp
80106b3a:	89 e5                	mov    %esp,%ebp
80106b3c:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106b3f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106b46:	e9 c3 00 00 00       	jmp    80106c0e <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b4e:	8b 04 85 84 c0 10 80 	mov    -0x7fef3f7c(,%eax,4),%eax
80106b55:	89 c2                	mov    %eax,%edx
80106b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b5a:	66 89 14 c5 40 77 11 	mov    %dx,-0x7fee88c0(,%eax,8)
80106b61:	80 
80106b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b65:	66 c7 04 c5 42 77 11 	movw   $0x8,-0x7fee88be(,%eax,8)
80106b6c:	80 08 00 
80106b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b72:	0f b6 14 c5 44 77 11 	movzbl -0x7fee88bc(,%eax,8),%edx
80106b79:	80 
80106b7a:	83 e2 e0             	and    $0xffffffe0,%edx
80106b7d:	88 14 c5 44 77 11 80 	mov    %dl,-0x7fee88bc(,%eax,8)
80106b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b87:	0f b6 14 c5 44 77 11 	movzbl -0x7fee88bc(,%eax,8),%edx
80106b8e:	80 
80106b8f:	83 e2 1f             	and    $0x1f,%edx
80106b92:	88 14 c5 44 77 11 80 	mov    %dl,-0x7fee88bc(,%eax,8)
80106b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b9c:	0f b6 14 c5 45 77 11 	movzbl -0x7fee88bb(,%eax,8),%edx
80106ba3:	80 
80106ba4:	83 e2 f0             	and    $0xfffffff0,%edx
80106ba7:	83 ca 0e             	or     $0xe,%edx
80106baa:	88 14 c5 45 77 11 80 	mov    %dl,-0x7fee88bb(,%eax,8)
80106bb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bb4:	0f b6 14 c5 45 77 11 	movzbl -0x7fee88bb(,%eax,8),%edx
80106bbb:	80 
80106bbc:	83 e2 ef             	and    $0xffffffef,%edx
80106bbf:	88 14 c5 45 77 11 80 	mov    %dl,-0x7fee88bb(,%eax,8)
80106bc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bc9:	0f b6 14 c5 45 77 11 	movzbl -0x7fee88bb(,%eax,8),%edx
80106bd0:	80 
80106bd1:	83 e2 9f             	and    $0xffffff9f,%edx
80106bd4:	88 14 c5 45 77 11 80 	mov    %dl,-0x7fee88bb(,%eax,8)
80106bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bde:	0f b6 14 c5 45 77 11 	movzbl -0x7fee88bb(,%eax,8),%edx
80106be5:	80 
80106be6:	83 ca 80             	or     $0xffffff80,%edx
80106be9:	88 14 c5 45 77 11 80 	mov    %dl,-0x7fee88bb(,%eax,8)
80106bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bf3:	8b 04 85 84 c0 10 80 	mov    -0x7fef3f7c(,%eax,4),%eax
80106bfa:	c1 e8 10             	shr    $0x10,%eax
80106bfd:	89 c2                	mov    %eax,%edx
80106bff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c02:	66 89 14 c5 46 77 11 	mov    %dx,-0x7fee88ba(,%eax,8)
80106c09:	80 
  for(i = 0; i < 256; i++)
80106c0a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c0e:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106c15:	0f 8e 30 ff ff ff    	jle    80106b4b <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106c1b:	a1 84 c1 10 80       	mov    0x8010c184,%eax
80106c20:	66 a3 40 79 11 80    	mov    %ax,0x80117940
80106c26:	66 c7 05 42 79 11 80 	movw   $0x8,0x80117942
80106c2d:	08 00 
80106c2f:	0f b6 05 44 79 11 80 	movzbl 0x80117944,%eax
80106c36:	83 e0 e0             	and    $0xffffffe0,%eax
80106c39:	a2 44 79 11 80       	mov    %al,0x80117944
80106c3e:	0f b6 05 44 79 11 80 	movzbl 0x80117944,%eax
80106c45:	83 e0 1f             	and    $0x1f,%eax
80106c48:	a2 44 79 11 80       	mov    %al,0x80117944
80106c4d:	0f b6 05 45 79 11 80 	movzbl 0x80117945,%eax
80106c54:	83 c8 0f             	or     $0xf,%eax
80106c57:	a2 45 79 11 80       	mov    %al,0x80117945
80106c5c:	0f b6 05 45 79 11 80 	movzbl 0x80117945,%eax
80106c63:	83 e0 ef             	and    $0xffffffef,%eax
80106c66:	a2 45 79 11 80       	mov    %al,0x80117945
80106c6b:	0f b6 05 45 79 11 80 	movzbl 0x80117945,%eax
80106c72:	83 c8 60             	or     $0x60,%eax
80106c75:	a2 45 79 11 80       	mov    %al,0x80117945
80106c7a:	0f b6 05 45 79 11 80 	movzbl 0x80117945,%eax
80106c81:	83 c8 80             	or     $0xffffff80,%eax
80106c84:	a2 45 79 11 80       	mov    %al,0x80117945
80106c89:	a1 84 c1 10 80       	mov    0x8010c184,%eax
80106c8e:	c1 e8 10             	shr    $0x10,%eax
80106c91:	66 a3 46 79 11 80    	mov    %ax,0x80117946

  initlock(&tickslock, "time");
80106c97:	83 ec 08             	sub    $0x8,%esp
80106c9a:	68 f0 98 10 80       	push   $0x801098f0
80106c9f:	68 00 77 11 80       	push   $0x80117700
80106ca4:	e8 0b e6 ff ff       	call   801052b4 <initlock>
80106ca9:	83 c4 10             	add    $0x10,%esp
}
80106cac:	90                   	nop
80106cad:	c9                   	leave  
80106cae:	c3                   	ret    

80106caf <idtinit>:

void
idtinit(void)
{
80106caf:	f3 0f 1e fb          	endbr32 
80106cb3:	55                   	push   %ebp
80106cb4:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106cb6:	68 00 08 00 00       	push   $0x800
80106cbb:	68 40 77 11 80       	push   $0x80117740
80106cc0:	e8 35 fe ff ff       	call   80106afa <lidt>
80106cc5:	83 c4 08             	add    $0x8,%esp
}
80106cc8:	90                   	nop
80106cc9:	c9                   	leave  
80106cca:	c3                   	ret    

80106ccb <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106ccb:	f3 0f 1e fb          	endbr32 
80106ccf:	55                   	push   %ebp
80106cd0:	89 e5                	mov    %esp,%ebp
80106cd2:	57                   	push   %edi
80106cd3:	56                   	push   %esi
80106cd4:	53                   	push   %ebx
80106cd5:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80106cd8:	8b 45 08             	mov    0x8(%ebp),%eax
80106cdb:	8b 40 30             	mov    0x30(%eax),%eax
80106cde:	83 f8 40             	cmp    $0x40,%eax
80106ce1:	75 3b                	jne    80106d1e <trap+0x53>
    if(myproc()->killed)
80106ce3:	e8 27 d8 ff ff       	call   8010450f <myproc>
80106ce8:	8b 40 24             	mov    0x24(%eax),%eax
80106ceb:	85 c0                	test   %eax,%eax
80106ced:	74 05                	je     80106cf4 <trap+0x29>
      exit();
80106cef:	e8 22 dd ff ff       	call   80104a16 <exit>
    myproc()->tf = tf;
80106cf4:	e8 16 d8 ff ff       	call   8010450f <myproc>
80106cf9:	8b 55 08             	mov    0x8(%ebp),%edx
80106cfc:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106cff:	e8 a1 ec ff ff       	call   801059a5 <syscall>
    if(myproc()->killed)
80106d04:	e8 06 d8 ff ff       	call   8010450f <myproc>
80106d09:	8b 40 24             	mov    0x24(%eax),%eax
80106d0c:	85 c0                	test   %eax,%eax
80106d0e:	0f 84 42 02 00 00    	je     80106f56 <trap+0x28b>
      exit();
80106d14:	e8 fd dc ff ff       	call   80104a16 <exit>
    return;
80106d19:	e9 38 02 00 00       	jmp    80106f56 <trap+0x28b>
  }
  char *addr;
  switch(tf->trapno){
80106d1e:	8b 45 08             	mov    0x8(%ebp),%eax
80106d21:	8b 40 30             	mov    0x30(%eax),%eax
80106d24:	83 e8 0e             	sub    $0xe,%eax
80106d27:	83 f8 31             	cmp    $0x31,%eax
80106d2a:	0f 87 ee 00 00 00    	ja     80106e1e <trap+0x153>
80106d30:	8b 04 85 b0 99 10 80 	mov    -0x7fef6650(,%eax,4),%eax
80106d37:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106d3a:	e8 35 d7 ff ff       	call   80104474 <cpuid>
80106d3f:	85 c0                	test   %eax,%eax
80106d41:	75 3d                	jne    80106d80 <trap+0xb5>
      acquire(&tickslock);
80106d43:	83 ec 0c             	sub    $0xc,%esp
80106d46:	68 00 77 11 80       	push   $0x80117700
80106d4b:	e8 8a e5 ff ff       	call   801052da <acquire>
80106d50:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106d53:	a1 40 7f 11 80       	mov    0x80117f40,%eax
80106d58:	83 c0 01             	add    $0x1,%eax
80106d5b:	a3 40 7f 11 80       	mov    %eax,0x80117f40
      wakeup(&ticks);
80106d60:	83 ec 0c             	sub    $0xc,%esp
80106d63:	68 40 7f 11 80       	push   $0x80117f40
80106d68:	e8 ed e1 ff ff       	call   80104f5a <wakeup>
80106d6d:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106d70:	83 ec 0c             	sub    $0xc,%esp
80106d73:	68 00 77 11 80       	push   $0x80117700
80106d78:	e8 cf e5 ff ff       	call   8010534c <release>
80106d7d:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106d80:	e8 7f c4 ff ff       	call   80103204 <lapiceoi>
    break;
80106d85:	e9 4c 01 00 00       	jmp    80106ed6 <trap+0x20b>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106d8a:	e8 84 bc ff ff       	call   80102a13 <ideintr>
    lapiceoi();
80106d8f:	e8 70 c4 ff ff       	call   80103204 <lapiceoi>
    break;
80106d94:	e9 3d 01 00 00       	jmp    80106ed6 <trap+0x20b>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106d99:	e8 9c c2 ff ff       	call   8010303a <kbdintr>
    lapiceoi();
80106d9e:	e8 61 c4 ff ff       	call   80103204 <lapiceoi>
    break;
80106da3:	e9 2e 01 00 00       	jmp    80106ed6 <trap+0x20b>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106da8:	e8 8b 03 00 00       	call   80107138 <uartintr>
    lapiceoi();
80106dad:	e8 52 c4 ff ff       	call   80103204 <lapiceoi>
    break;
80106db2:	e9 1f 01 00 00       	jmp    80106ed6 <trap+0x20b>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106db7:	8b 45 08             	mov    0x8(%ebp),%eax
80106dba:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106dbd:	8b 45 08             	mov    0x8(%ebp),%eax
80106dc0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106dc4:	0f b7 d8             	movzwl %ax,%ebx
80106dc7:	e8 a8 d6 ff ff       	call   80104474 <cpuid>
80106dcc:	56                   	push   %esi
80106dcd:	53                   	push   %ebx
80106dce:	50                   	push   %eax
80106dcf:	68 f8 98 10 80       	push   $0x801098f8
80106dd4:	e8 3f 96 ff ff       	call   80100418 <cprintf>
80106dd9:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106ddc:	e8 23 c4 ff ff       	call   80103204 <lapiceoi>
    break;
80106de1:	e9 f0 00 00 00       	jmp    80106ed6 <trap+0x20b>
  case T_PGFLT:
    //Food for thought: How can one distinguish between a regular page fault and a decryption request?
    cprintf("p4Debug : Page fault !\n");
80106de6:	83 ec 0c             	sub    $0xc,%esp
80106de9:	68 1c 99 10 80       	push   $0x8010991c
80106dee:	e8 25 96 ff ff       	call   80100418 <cprintf>
80106df3:	83 c4 10             	add    $0x10,%esp
    addr = (char*)rcr2();
80106df6:	e8 29 fd ff ff       	call   80106b24 <rcr2>
80106dfb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (mdecrypt(addr))
80106dfe:	83 ec 0c             	sub    $0xc,%esp
80106e01:	ff 75 e4             	pushl  -0x1c(%ebp)
80106e04:	e8 7e 1e 00 00       	call   80108c87 <mdecrypt>
80106e09:	83 c4 10             	add    $0x10,%esp
80106e0c:	85 c0                	test   %eax,%eax
80106e0e:	0f 84 c1 00 00 00    	je     80106ed5 <trap+0x20a>
    {
        //panic("p4Debug: Memory fault");
        exit();
80106e14:	e8 fd db ff ff       	call   80104a16 <exit>
    };
    break;
80106e19:	e9 b7 00 00 00       	jmp    80106ed5 <trap+0x20a>
  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106e1e:	e8 ec d6 ff ff       	call   8010450f <myproc>
80106e23:	85 c0                	test   %eax,%eax
80106e25:	74 11                	je     80106e38 <trap+0x16d>
80106e27:	8b 45 08             	mov    0x8(%ebp),%eax
80106e2a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106e2e:	0f b7 c0             	movzwl %ax,%eax
80106e31:	83 e0 03             	and    $0x3,%eax
80106e34:	85 c0                	test   %eax,%eax
80106e36:	75 39                	jne    80106e71 <trap+0x1a6>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106e38:	e8 e7 fc ff ff       	call   80106b24 <rcr2>
80106e3d:	89 c3                	mov    %eax,%ebx
80106e3f:	8b 45 08             	mov    0x8(%ebp),%eax
80106e42:	8b 70 38             	mov    0x38(%eax),%esi
80106e45:	e8 2a d6 ff ff       	call   80104474 <cpuid>
80106e4a:	8b 55 08             	mov    0x8(%ebp),%edx
80106e4d:	8b 52 30             	mov    0x30(%edx),%edx
80106e50:	83 ec 0c             	sub    $0xc,%esp
80106e53:	53                   	push   %ebx
80106e54:	56                   	push   %esi
80106e55:	50                   	push   %eax
80106e56:	52                   	push   %edx
80106e57:	68 34 99 10 80       	push   $0x80109934
80106e5c:	e8 b7 95 ff ff       	call   80100418 <cprintf>
80106e61:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106e64:	83 ec 0c             	sub    $0xc,%esp
80106e67:	68 66 99 10 80       	push   $0x80109966
80106e6c:	e8 97 97 ff ff       	call   80100608 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e71:	e8 ae fc ff ff       	call   80106b24 <rcr2>
80106e76:	89 c6                	mov    %eax,%esi
80106e78:	8b 45 08             	mov    0x8(%ebp),%eax
80106e7b:	8b 40 38             	mov    0x38(%eax),%eax
80106e7e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106e81:	e8 ee d5 ff ff       	call   80104474 <cpuid>
80106e86:	89 c3                	mov    %eax,%ebx
80106e88:	8b 45 08             	mov    0x8(%ebp),%eax
80106e8b:	8b 48 34             	mov    0x34(%eax),%ecx
80106e8e:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106e91:	8b 45 08             	mov    0x8(%ebp),%eax
80106e94:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106e97:	e8 73 d6 ff ff       	call   8010450f <myproc>
80106e9c:	8d 50 6c             	lea    0x6c(%eax),%edx
80106e9f:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106ea2:	e8 68 d6 ff ff       	call   8010450f <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106ea7:	8b 40 10             	mov    0x10(%eax),%eax
80106eaa:	56                   	push   %esi
80106eab:	ff 75 d4             	pushl  -0x2c(%ebp)
80106eae:	53                   	push   %ebx
80106eaf:	ff 75 d0             	pushl  -0x30(%ebp)
80106eb2:	57                   	push   %edi
80106eb3:	ff 75 cc             	pushl  -0x34(%ebp)
80106eb6:	50                   	push   %eax
80106eb7:	68 6c 99 10 80       	push   $0x8010996c
80106ebc:	e8 57 95 ff ff       	call   80100418 <cprintf>
80106ec1:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106ec4:	e8 46 d6 ff ff       	call   8010450f <myproc>
80106ec9:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106ed0:	eb 04                	jmp    80106ed6 <trap+0x20b>
    break;
80106ed2:	90                   	nop
80106ed3:	eb 01                	jmp    80106ed6 <trap+0x20b>
    break;
80106ed5:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106ed6:	e8 34 d6 ff ff       	call   8010450f <myproc>
80106edb:	85 c0                	test   %eax,%eax
80106edd:	74 23                	je     80106f02 <trap+0x237>
80106edf:	e8 2b d6 ff ff       	call   8010450f <myproc>
80106ee4:	8b 40 24             	mov    0x24(%eax),%eax
80106ee7:	85 c0                	test   %eax,%eax
80106ee9:	74 17                	je     80106f02 <trap+0x237>
80106eeb:	8b 45 08             	mov    0x8(%ebp),%eax
80106eee:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106ef2:	0f b7 c0             	movzwl %ax,%eax
80106ef5:	83 e0 03             	and    $0x3,%eax
80106ef8:	83 f8 03             	cmp    $0x3,%eax
80106efb:	75 05                	jne    80106f02 <trap+0x237>
    exit();
80106efd:	e8 14 db ff ff       	call   80104a16 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106f02:	e8 08 d6 ff ff       	call   8010450f <myproc>
80106f07:	85 c0                	test   %eax,%eax
80106f09:	74 1d                	je     80106f28 <trap+0x25d>
80106f0b:	e8 ff d5 ff ff       	call   8010450f <myproc>
80106f10:	8b 40 0c             	mov    0xc(%eax),%eax
80106f13:	83 f8 04             	cmp    $0x4,%eax
80106f16:	75 10                	jne    80106f28 <trap+0x25d>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106f18:	8b 45 08             	mov    0x8(%ebp),%eax
80106f1b:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106f1e:	83 f8 20             	cmp    $0x20,%eax
80106f21:	75 05                	jne    80106f28 <trap+0x25d>
    yield();
80106f23:	e8 b8 de ff ff       	call   80104de0 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106f28:	e8 e2 d5 ff ff       	call   8010450f <myproc>
80106f2d:	85 c0                	test   %eax,%eax
80106f2f:	74 26                	je     80106f57 <trap+0x28c>
80106f31:	e8 d9 d5 ff ff       	call   8010450f <myproc>
80106f36:	8b 40 24             	mov    0x24(%eax),%eax
80106f39:	85 c0                	test   %eax,%eax
80106f3b:	74 1a                	je     80106f57 <trap+0x28c>
80106f3d:	8b 45 08             	mov    0x8(%ebp),%eax
80106f40:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106f44:	0f b7 c0             	movzwl %ax,%eax
80106f47:	83 e0 03             	and    $0x3,%eax
80106f4a:	83 f8 03             	cmp    $0x3,%eax
80106f4d:	75 08                	jne    80106f57 <trap+0x28c>
    exit();
80106f4f:	e8 c2 da ff ff       	call   80104a16 <exit>
80106f54:	eb 01                	jmp    80106f57 <trap+0x28c>
    return;
80106f56:	90                   	nop
}
80106f57:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106f5a:	5b                   	pop    %ebx
80106f5b:	5e                   	pop    %esi
80106f5c:	5f                   	pop    %edi
80106f5d:	5d                   	pop    %ebp
80106f5e:	c3                   	ret    

80106f5f <inb>:
{
80106f5f:	55                   	push   %ebp
80106f60:	89 e5                	mov    %esp,%ebp
80106f62:	83 ec 14             	sub    $0x14,%esp
80106f65:	8b 45 08             	mov    0x8(%ebp),%eax
80106f68:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106f6c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106f70:	89 c2                	mov    %eax,%edx
80106f72:	ec                   	in     (%dx),%al
80106f73:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106f76:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106f7a:	c9                   	leave  
80106f7b:	c3                   	ret    

80106f7c <outb>:
{
80106f7c:	55                   	push   %ebp
80106f7d:	89 e5                	mov    %esp,%ebp
80106f7f:	83 ec 08             	sub    $0x8,%esp
80106f82:	8b 45 08             	mov    0x8(%ebp),%eax
80106f85:	8b 55 0c             	mov    0xc(%ebp),%edx
80106f88:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106f8c:	89 d0                	mov    %edx,%eax
80106f8e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106f91:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106f95:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106f99:	ee                   	out    %al,(%dx)
}
80106f9a:	90                   	nop
80106f9b:	c9                   	leave  
80106f9c:	c3                   	ret    

80106f9d <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106f9d:	f3 0f 1e fb          	endbr32 
80106fa1:	55                   	push   %ebp
80106fa2:	89 e5                	mov    %esp,%ebp
80106fa4:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106fa7:	6a 00                	push   $0x0
80106fa9:	68 fa 03 00 00       	push   $0x3fa
80106fae:	e8 c9 ff ff ff       	call   80106f7c <outb>
80106fb3:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106fb6:	68 80 00 00 00       	push   $0x80
80106fbb:	68 fb 03 00 00       	push   $0x3fb
80106fc0:	e8 b7 ff ff ff       	call   80106f7c <outb>
80106fc5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106fc8:	6a 0c                	push   $0xc
80106fca:	68 f8 03 00 00       	push   $0x3f8
80106fcf:	e8 a8 ff ff ff       	call   80106f7c <outb>
80106fd4:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106fd7:	6a 00                	push   $0x0
80106fd9:	68 f9 03 00 00       	push   $0x3f9
80106fde:	e8 99 ff ff ff       	call   80106f7c <outb>
80106fe3:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106fe6:	6a 03                	push   $0x3
80106fe8:	68 fb 03 00 00       	push   $0x3fb
80106fed:	e8 8a ff ff ff       	call   80106f7c <outb>
80106ff2:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106ff5:	6a 00                	push   $0x0
80106ff7:	68 fc 03 00 00       	push   $0x3fc
80106ffc:	e8 7b ff ff ff       	call   80106f7c <outb>
80107001:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107004:	6a 01                	push   $0x1
80107006:	68 f9 03 00 00       	push   $0x3f9
8010700b:	e8 6c ff ff ff       	call   80106f7c <outb>
80107010:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107013:	68 fd 03 00 00       	push   $0x3fd
80107018:	e8 42 ff ff ff       	call   80106f5f <inb>
8010701d:	83 c4 04             	add    $0x4,%esp
80107020:	3c ff                	cmp    $0xff,%al
80107022:	74 61                	je     80107085 <uartinit+0xe8>
    return;
  uart = 1;
80107024:	c7 05 44 c6 10 80 01 	movl   $0x1,0x8010c644
8010702b:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010702e:	68 fa 03 00 00       	push   $0x3fa
80107033:	e8 27 ff ff ff       	call   80106f5f <inb>
80107038:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
8010703b:	68 f8 03 00 00       	push   $0x3f8
80107040:	e8 1a ff ff ff       	call   80106f5f <inb>
80107045:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80107048:	83 ec 08             	sub    $0x8,%esp
8010704b:	6a 00                	push   $0x0
8010704d:	6a 04                	push   $0x4
8010704f:	e8 71 bc ff ff       	call   80102cc5 <ioapicenable>
80107054:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107057:	c7 45 f4 78 9a 10 80 	movl   $0x80109a78,-0xc(%ebp)
8010705e:	eb 19                	jmp    80107079 <uartinit+0xdc>
    uartputc(*p);
80107060:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107063:	0f b6 00             	movzbl (%eax),%eax
80107066:	0f be c0             	movsbl %al,%eax
80107069:	83 ec 0c             	sub    $0xc,%esp
8010706c:	50                   	push   %eax
8010706d:	e8 16 00 00 00       	call   80107088 <uartputc>
80107072:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80107075:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107079:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010707c:	0f b6 00             	movzbl (%eax),%eax
8010707f:	84 c0                	test   %al,%al
80107081:	75 dd                	jne    80107060 <uartinit+0xc3>
80107083:	eb 01                	jmp    80107086 <uartinit+0xe9>
    return;
80107085:	90                   	nop
}
80107086:	c9                   	leave  
80107087:	c3                   	ret    

80107088 <uartputc>:

void
uartputc(int c)
{
80107088:	f3 0f 1e fb          	endbr32 
8010708c:	55                   	push   %ebp
8010708d:	89 e5                	mov    %esp,%ebp
8010708f:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80107092:	a1 44 c6 10 80       	mov    0x8010c644,%eax
80107097:	85 c0                	test   %eax,%eax
80107099:	74 53                	je     801070ee <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010709b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801070a2:	eb 11                	jmp    801070b5 <uartputc+0x2d>
    microdelay(10);
801070a4:	83 ec 0c             	sub    $0xc,%esp
801070a7:	6a 0a                	push   $0xa
801070a9:	e8 75 c1 ff ff       	call   80103223 <microdelay>
801070ae:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801070b1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801070b5:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801070b9:	7f 1a                	jg     801070d5 <uartputc+0x4d>
801070bb:	83 ec 0c             	sub    $0xc,%esp
801070be:	68 fd 03 00 00       	push   $0x3fd
801070c3:	e8 97 fe ff ff       	call   80106f5f <inb>
801070c8:	83 c4 10             	add    $0x10,%esp
801070cb:	0f b6 c0             	movzbl %al,%eax
801070ce:	83 e0 20             	and    $0x20,%eax
801070d1:	85 c0                	test   %eax,%eax
801070d3:	74 cf                	je     801070a4 <uartputc+0x1c>
  outb(COM1+0, c);
801070d5:	8b 45 08             	mov    0x8(%ebp),%eax
801070d8:	0f b6 c0             	movzbl %al,%eax
801070db:	83 ec 08             	sub    $0x8,%esp
801070de:	50                   	push   %eax
801070df:	68 f8 03 00 00       	push   $0x3f8
801070e4:	e8 93 fe ff ff       	call   80106f7c <outb>
801070e9:	83 c4 10             	add    $0x10,%esp
801070ec:	eb 01                	jmp    801070ef <uartputc+0x67>
    return;
801070ee:	90                   	nop
}
801070ef:	c9                   	leave  
801070f0:	c3                   	ret    

801070f1 <uartgetc>:

static int
uartgetc(void)
{
801070f1:	f3 0f 1e fb          	endbr32 
801070f5:	55                   	push   %ebp
801070f6:	89 e5                	mov    %esp,%ebp
  if(!uart)
801070f8:	a1 44 c6 10 80       	mov    0x8010c644,%eax
801070fd:	85 c0                	test   %eax,%eax
801070ff:	75 07                	jne    80107108 <uartgetc+0x17>
    return -1;
80107101:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107106:	eb 2e                	jmp    80107136 <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
80107108:	68 fd 03 00 00       	push   $0x3fd
8010710d:	e8 4d fe ff ff       	call   80106f5f <inb>
80107112:	83 c4 04             	add    $0x4,%esp
80107115:	0f b6 c0             	movzbl %al,%eax
80107118:	83 e0 01             	and    $0x1,%eax
8010711b:	85 c0                	test   %eax,%eax
8010711d:	75 07                	jne    80107126 <uartgetc+0x35>
    return -1;
8010711f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107124:	eb 10                	jmp    80107136 <uartgetc+0x45>
  return inb(COM1+0);
80107126:	68 f8 03 00 00       	push   $0x3f8
8010712b:	e8 2f fe ff ff       	call   80106f5f <inb>
80107130:	83 c4 04             	add    $0x4,%esp
80107133:	0f b6 c0             	movzbl %al,%eax
}
80107136:	c9                   	leave  
80107137:	c3                   	ret    

80107138 <uartintr>:

void
uartintr(void)
{
80107138:	f3 0f 1e fb          	endbr32 
8010713c:	55                   	push   %ebp
8010713d:	89 e5                	mov    %esp,%ebp
8010713f:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107142:	83 ec 0c             	sub    $0xc,%esp
80107145:	68 f1 70 10 80       	push   $0x801070f1
8010714a:	e8 59 97 ff ff       	call   801008a8 <consoleintr>
8010714f:	83 c4 10             	add    $0x10,%esp
}
80107152:	90                   	nop
80107153:	c9                   	leave  
80107154:	c3                   	ret    

80107155 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107155:	6a 00                	push   $0x0
  pushl $0
80107157:	6a 00                	push   $0x0
  jmp alltraps
80107159:	e9 79 f9 ff ff       	jmp    80106ad7 <alltraps>

8010715e <vector1>:
.globl vector1
vector1:
  pushl $0
8010715e:	6a 00                	push   $0x0
  pushl $1
80107160:	6a 01                	push   $0x1
  jmp alltraps
80107162:	e9 70 f9 ff ff       	jmp    80106ad7 <alltraps>

80107167 <vector2>:
.globl vector2
vector2:
  pushl $0
80107167:	6a 00                	push   $0x0
  pushl $2
80107169:	6a 02                	push   $0x2
  jmp alltraps
8010716b:	e9 67 f9 ff ff       	jmp    80106ad7 <alltraps>

80107170 <vector3>:
.globl vector3
vector3:
  pushl $0
80107170:	6a 00                	push   $0x0
  pushl $3
80107172:	6a 03                	push   $0x3
  jmp alltraps
80107174:	e9 5e f9 ff ff       	jmp    80106ad7 <alltraps>

80107179 <vector4>:
.globl vector4
vector4:
  pushl $0
80107179:	6a 00                	push   $0x0
  pushl $4
8010717b:	6a 04                	push   $0x4
  jmp alltraps
8010717d:	e9 55 f9 ff ff       	jmp    80106ad7 <alltraps>

80107182 <vector5>:
.globl vector5
vector5:
  pushl $0
80107182:	6a 00                	push   $0x0
  pushl $5
80107184:	6a 05                	push   $0x5
  jmp alltraps
80107186:	e9 4c f9 ff ff       	jmp    80106ad7 <alltraps>

8010718b <vector6>:
.globl vector6
vector6:
  pushl $0
8010718b:	6a 00                	push   $0x0
  pushl $6
8010718d:	6a 06                	push   $0x6
  jmp alltraps
8010718f:	e9 43 f9 ff ff       	jmp    80106ad7 <alltraps>

80107194 <vector7>:
.globl vector7
vector7:
  pushl $0
80107194:	6a 00                	push   $0x0
  pushl $7
80107196:	6a 07                	push   $0x7
  jmp alltraps
80107198:	e9 3a f9 ff ff       	jmp    80106ad7 <alltraps>

8010719d <vector8>:
.globl vector8
vector8:
  pushl $8
8010719d:	6a 08                	push   $0x8
  jmp alltraps
8010719f:	e9 33 f9 ff ff       	jmp    80106ad7 <alltraps>

801071a4 <vector9>:
.globl vector9
vector9:
  pushl $0
801071a4:	6a 00                	push   $0x0
  pushl $9
801071a6:	6a 09                	push   $0x9
  jmp alltraps
801071a8:	e9 2a f9 ff ff       	jmp    80106ad7 <alltraps>

801071ad <vector10>:
.globl vector10
vector10:
  pushl $10
801071ad:	6a 0a                	push   $0xa
  jmp alltraps
801071af:	e9 23 f9 ff ff       	jmp    80106ad7 <alltraps>

801071b4 <vector11>:
.globl vector11
vector11:
  pushl $11
801071b4:	6a 0b                	push   $0xb
  jmp alltraps
801071b6:	e9 1c f9 ff ff       	jmp    80106ad7 <alltraps>

801071bb <vector12>:
.globl vector12
vector12:
  pushl $12
801071bb:	6a 0c                	push   $0xc
  jmp alltraps
801071bd:	e9 15 f9 ff ff       	jmp    80106ad7 <alltraps>

801071c2 <vector13>:
.globl vector13
vector13:
  pushl $13
801071c2:	6a 0d                	push   $0xd
  jmp alltraps
801071c4:	e9 0e f9 ff ff       	jmp    80106ad7 <alltraps>

801071c9 <vector14>:
.globl vector14
vector14:
  pushl $14
801071c9:	6a 0e                	push   $0xe
  jmp alltraps
801071cb:	e9 07 f9 ff ff       	jmp    80106ad7 <alltraps>

801071d0 <vector15>:
.globl vector15
vector15:
  pushl $0
801071d0:	6a 00                	push   $0x0
  pushl $15
801071d2:	6a 0f                	push   $0xf
  jmp alltraps
801071d4:	e9 fe f8 ff ff       	jmp    80106ad7 <alltraps>

801071d9 <vector16>:
.globl vector16
vector16:
  pushl $0
801071d9:	6a 00                	push   $0x0
  pushl $16
801071db:	6a 10                	push   $0x10
  jmp alltraps
801071dd:	e9 f5 f8 ff ff       	jmp    80106ad7 <alltraps>

801071e2 <vector17>:
.globl vector17
vector17:
  pushl $17
801071e2:	6a 11                	push   $0x11
  jmp alltraps
801071e4:	e9 ee f8 ff ff       	jmp    80106ad7 <alltraps>

801071e9 <vector18>:
.globl vector18
vector18:
  pushl $0
801071e9:	6a 00                	push   $0x0
  pushl $18
801071eb:	6a 12                	push   $0x12
  jmp alltraps
801071ed:	e9 e5 f8 ff ff       	jmp    80106ad7 <alltraps>

801071f2 <vector19>:
.globl vector19
vector19:
  pushl $0
801071f2:	6a 00                	push   $0x0
  pushl $19
801071f4:	6a 13                	push   $0x13
  jmp alltraps
801071f6:	e9 dc f8 ff ff       	jmp    80106ad7 <alltraps>

801071fb <vector20>:
.globl vector20
vector20:
  pushl $0
801071fb:	6a 00                	push   $0x0
  pushl $20
801071fd:	6a 14                	push   $0x14
  jmp alltraps
801071ff:	e9 d3 f8 ff ff       	jmp    80106ad7 <alltraps>

80107204 <vector21>:
.globl vector21
vector21:
  pushl $0
80107204:	6a 00                	push   $0x0
  pushl $21
80107206:	6a 15                	push   $0x15
  jmp alltraps
80107208:	e9 ca f8 ff ff       	jmp    80106ad7 <alltraps>

8010720d <vector22>:
.globl vector22
vector22:
  pushl $0
8010720d:	6a 00                	push   $0x0
  pushl $22
8010720f:	6a 16                	push   $0x16
  jmp alltraps
80107211:	e9 c1 f8 ff ff       	jmp    80106ad7 <alltraps>

80107216 <vector23>:
.globl vector23
vector23:
  pushl $0
80107216:	6a 00                	push   $0x0
  pushl $23
80107218:	6a 17                	push   $0x17
  jmp alltraps
8010721a:	e9 b8 f8 ff ff       	jmp    80106ad7 <alltraps>

8010721f <vector24>:
.globl vector24
vector24:
  pushl $0
8010721f:	6a 00                	push   $0x0
  pushl $24
80107221:	6a 18                	push   $0x18
  jmp alltraps
80107223:	e9 af f8 ff ff       	jmp    80106ad7 <alltraps>

80107228 <vector25>:
.globl vector25
vector25:
  pushl $0
80107228:	6a 00                	push   $0x0
  pushl $25
8010722a:	6a 19                	push   $0x19
  jmp alltraps
8010722c:	e9 a6 f8 ff ff       	jmp    80106ad7 <alltraps>

80107231 <vector26>:
.globl vector26
vector26:
  pushl $0
80107231:	6a 00                	push   $0x0
  pushl $26
80107233:	6a 1a                	push   $0x1a
  jmp alltraps
80107235:	e9 9d f8 ff ff       	jmp    80106ad7 <alltraps>

8010723a <vector27>:
.globl vector27
vector27:
  pushl $0
8010723a:	6a 00                	push   $0x0
  pushl $27
8010723c:	6a 1b                	push   $0x1b
  jmp alltraps
8010723e:	e9 94 f8 ff ff       	jmp    80106ad7 <alltraps>

80107243 <vector28>:
.globl vector28
vector28:
  pushl $0
80107243:	6a 00                	push   $0x0
  pushl $28
80107245:	6a 1c                	push   $0x1c
  jmp alltraps
80107247:	e9 8b f8 ff ff       	jmp    80106ad7 <alltraps>

8010724c <vector29>:
.globl vector29
vector29:
  pushl $0
8010724c:	6a 00                	push   $0x0
  pushl $29
8010724e:	6a 1d                	push   $0x1d
  jmp alltraps
80107250:	e9 82 f8 ff ff       	jmp    80106ad7 <alltraps>

80107255 <vector30>:
.globl vector30
vector30:
  pushl $0
80107255:	6a 00                	push   $0x0
  pushl $30
80107257:	6a 1e                	push   $0x1e
  jmp alltraps
80107259:	e9 79 f8 ff ff       	jmp    80106ad7 <alltraps>

8010725e <vector31>:
.globl vector31
vector31:
  pushl $0
8010725e:	6a 00                	push   $0x0
  pushl $31
80107260:	6a 1f                	push   $0x1f
  jmp alltraps
80107262:	e9 70 f8 ff ff       	jmp    80106ad7 <alltraps>

80107267 <vector32>:
.globl vector32
vector32:
  pushl $0
80107267:	6a 00                	push   $0x0
  pushl $32
80107269:	6a 20                	push   $0x20
  jmp alltraps
8010726b:	e9 67 f8 ff ff       	jmp    80106ad7 <alltraps>

80107270 <vector33>:
.globl vector33
vector33:
  pushl $0
80107270:	6a 00                	push   $0x0
  pushl $33
80107272:	6a 21                	push   $0x21
  jmp alltraps
80107274:	e9 5e f8 ff ff       	jmp    80106ad7 <alltraps>

80107279 <vector34>:
.globl vector34
vector34:
  pushl $0
80107279:	6a 00                	push   $0x0
  pushl $34
8010727b:	6a 22                	push   $0x22
  jmp alltraps
8010727d:	e9 55 f8 ff ff       	jmp    80106ad7 <alltraps>

80107282 <vector35>:
.globl vector35
vector35:
  pushl $0
80107282:	6a 00                	push   $0x0
  pushl $35
80107284:	6a 23                	push   $0x23
  jmp alltraps
80107286:	e9 4c f8 ff ff       	jmp    80106ad7 <alltraps>

8010728b <vector36>:
.globl vector36
vector36:
  pushl $0
8010728b:	6a 00                	push   $0x0
  pushl $36
8010728d:	6a 24                	push   $0x24
  jmp alltraps
8010728f:	e9 43 f8 ff ff       	jmp    80106ad7 <alltraps>

80107294 <vector37>:
.globl vector37
vector37:
  pushl $0
80107294:	6a 00                	push   $0x0
  pushl $37
80107296:	6a 25                	push   $0x25
  jmp alltraps
80107298:	e9 3a f8 ff ff       	jmp    80106ad7 <alltraps>

8010729d <vector38>:
.globl vector38
vector38:
  pushl $0
8010729d:	6a 00                	push   $0x0
  pushl $38
8010729f:	6a 26                	push   $0x26
  jmp alltraps
801072a1:	e9 31 f8 ff ff       	jmp    80106ad7 <alltraps>

801072a6 <vector39>:
.globl vector39
vector39:
  pushl $0
801072a6:	6a 00                	push   $0x0
  pushl $39
801072a8:	6a 27                	push   $0x27
  jmp alltraps
801072aa:	e9 28 f8 ff ff       	jmp    80106ad7 <alltraps>

801072af <vector40>:
.globl vector40
vector40:
  pushl $0
801072af:	6a 00                	push   $0x0
  pushl $40
801072b1:	6a 28                	push   $0x28
  jmp alltraps
801072b3:	e9 1f f8 ff ff       	jmp    80106ad7 <alltraps>

801072b8 <vector41>:
.globl vector41
vector41:
  pushl $0
801072b8:	6a 00                	push   $0x0
  pushl $41
801072ba:	6a 29                	push   $0x29
  jmp alltraps
801072bc:	e9 16 f8 ff ff       	jmp    80106ad7 <alltraps>

801072c1 <vector42>:
.globl vector42
vector42:
  pushl $0
801072c1:	6a 00                	push   $0x0
  pushl $42
801072c3:	6a 2a                	push   $0x2a
  jmp alltraps
801072c5:	e9 0d f8 ff ff       	jmp    80106ad7 <alltraps>

801072ca <vector43>:
.globl vector43
vector43:
  pushl $0
801072ca:	6a 00                	push   $0x0
  pushl $43
801072cc:	6a 2b                	push   $0x2b
  jmp alltraps
801072ce:	e9 04 f8 ff ff       	jmp    80106ad7 <alltraps>

801072d3 <vector44>:
.globl vector44
vector44:
  pushl $0
801072d3:	6a 00                	push   $0x0
  pushl $44
801072d5:	6a 2c                	push   $0x2c
  jmp alltraps
801072d7:	e9 fb f7 ff ff       	jmp    80106ad7 <alltraps>

801072dc <vector45>:
.globl vector45
vector45:
  pushl $0
801072dc:	6a 00                	push   $0x0
  pushl $45
801072de:	6a 2d                	push   $0x2d
  jmp alltraps
801072e0:	e9 f2 f7 ff ff       	jmp    80106ad7 <alltraps>

801072e5 <vector46>:
.globl vector46
vector46:
  pushl $0
801072e5:	6a 00                	push   $0x0
  pushl $46
801072e7:	6a 2e                	push   $0x2e
  jmp alltraps
801072e9:	e9 e9 f7 ff ff       	jmp    80106ad7 <alltraps>

801072ee <vector47>:
.globl vector47
vector47:
  pushl $0
801072ee:	6a 00                	push   $0x0
  pushl $47
801072f0:	6a 2f                	push   $0x2f
  jmp alltraps
801072f2:	e9 e0 f7 ff ff       	jmp    80106ad7 <alltraps>

801072f7 <vector48>:
.globl vector48
vector48:
  pushl $0
801072f7:	6a 00                	push   $0x0
  pushl $48
801072f9:	6a 30                	push   $0x30
  jmp alltraps
801072fb:	e9 d7 f7 ff ff       	jmp    80106ad7 <alltraps>

80107300 <vector49>:
.globl vector49
vector49:
  pushl $0
80107300:	6a 00                	push   $0x0
  pushl $49
80107302:	6a 31                	push   $0x31
  jmp alltraps
80107304:	e9 ce f7 ff ff       	jmp    80106ad7 <alltraps>

80107309 <vector50>:
.globl vector50
vector50:
  pushl $0
80107309:	6a 00                	push   $0x0
  pushl $50
8010730b:	6a 32                	push   $0x32
  jmp alltraps
8010730d:	e9 c5 f7 ff ff       	jmp    80106ad7 <alltraps>

80107312 <vector51>:
.globl vector51
vector51:
  pushl $0
80107312:	6a 00                	push   $0x0
  pushl $51
80107314:	6a 33                	push   $0x33
  jmp alltraps
80107316:	e9 bc f7 ff ff       	jmp    80106ad7 <alltraps>

8010731b <vector52>:
.globl vector52
vector52:
  pushl $0
8010731b:	6a 00                	push   $0x0
  pushl $52
8010731d:	6a 34                	push   $0x34
  jmp alltraps
8010731f:	e9 b3 f7 ff ff       	jmp    80106ad7 <alltraps>

80107324 <vector53>:
.globl vector53
vector53:
  pushl $0
80107324:	6a 00                	push   $0x0
  pushl $53
80107326:	6a 35                	push   $0x35
  jmp alltraps
80107328:	e9 aa f7 ff ff       	jmp    80106ad7 <alltraps>

8010732d <vector54>:
.globl vector54
vector54:
  pushl $0
8010732d:	6a 00                	push   $0x0
  pushl $54
8010732f:	6a 36                	push   $0x36
  jmp alltraps
80107331:	e9 a1 f7 ff ff       	jmp    80106ad7 <alltraps>

80107336 <vector55>:
.globl vector55
vector55:
  pushl $0
80107336:	6a 00                	push   $0x0
  pushl $55
80107338:	6a 37                	push   $0x37
  jmp alltraps
8010733a:	e9 98 f7 ff ff       	jmp    80106ad7 <alltraps>

8010733f <vector56>:
.globl vector56
vector56:
  pushl $0
8010733f:	6a 00                	push   $0x0
  pushl $56
80107341:	6a 38                	push   $0x38
  jmp alltraps
80107343:	e9 8f f7 ff ff       	jmp    80106ad7 <alltraps>

80107348 <vector57>:
.globl vector57
vector57:
  pushl $0
80107348:	6a 00                	push   $0x0
  pushl $57
8010734a:	6a 39                	push   $0x39
  jmp alltraps
8010734c:	e9 86 f7 ff ff       	jmp    80106ad7 <alltraps>

80107351 <vector58>:
.globl vector58
vector58:
  pushl $0
80107351:	6a 00                	push   $0x0
  pushl $58
80107353:	6a 3a                	push   $0x3a
  jmp alltraps
80107355:	e9 7d f7 ff ff       	jmp    80106ad7 <alltraps>

8010735a <vector59>:
.globl vector59
vector59:
  pushl $0
8010735a:	6a 00                	push   $0x0
  pushl $59
8010735c:	6a 3b                	push   $0x3b
  jmp alltraps
8010735e:	e9 74 f7 ff ff       	jmp    80106ad7 <alltraps>

80107363 <vector60>:
.globl vector60
vector60:
  pushl $0
80107363:	6a 00                	push   $0x0
  pushl $60
80107365:	6a 3c                	push   $0x3c
  jmp alltraps
80107367:	e9 6b f7 ff ff       	jmp    80106ad7 <alltraps>

8010736c <vector61>:
.globl vector61
vector61:
  pushl $0
8010736c:	6a 00                	push   $0x0
  pushl $61
8010736e:	6a 3d                	push   $0x3d
  jmp alltraps
80107370:	e9 62 f7 ff ff       	jmp    80106ad7 <alltraps>

80107375 <vector62>:
.globl vector62
vector62:
  pushl $0
80107375:	6a 00                	push   $0x0
  pushl $62
80107377:	6a 3e                	push   $0x3e
  jmp alltraps
80107379:	e9 59 f7 ff ff       	jmp    80106ad7 <alltraps>

8010737e <vector63>:
.globl vector63
vector63:
  pushl $0
8010737e:	6a 00                	push   $0x0
  pushl $63
80107380:	6a 3f                	push   $0x3f
  jmp alltraps
80107382:	e9 50 f7 ff ff       	jmp    80106ad7 <alltraps>

80107387 <vector64>:
.globl vector64
vector64:
  pushl $0
80107387:	6a 00                	push   $0x0
  pushl $64
80107389:	6a 40                	push   $0x40
  jmp alltraps
8010738b:	e9 47 f7 ff ff       	jmp    80106ad7 <alltraps>

80107390 <vector65>:
.globl vector65
vector65:
  pushl $0
80107390:	6a 00                	push   $0x0
  pushl $65
80107392:	6a 41                	push   $0x41
  jmp alltraps
80107394:	e9 3e f7 ff ff       	jmp    80106ad7 <alltraps>

80107399 <vector66>:
.globl vector66
vector66:
  pushl $0
80107399:	6a 00                	push   $0x0
  pushl $66
8010739b:	6a 42                	push   $0x42
  jmp alltraps
8010739d:	e9 35 f7 ff ff       	jmp    80106ad7 <alltraps>

801073a2 <vector67>:
.globl vector67
vector67:
  pushl $0
801073a2:	6a 00                	push   $0x0
  pushl $67
801073a4:	6a 43                	push   $0x43
  jmp alltraps
801073a6:	e9 2c f7 ff ff       	jmp    80106ad7 <alltraps>

801073ab <vector68>:
.globl vector68
vector68:
  pushl $0
801073ab:	6a 00                	push   $0x0
  pushl $68
801073ad:	6a 44                	push   $0x44
  jmp alltraps
801073af:	e9 23 f7 ff ff       	jmp    80106ad7 <alltraps>

801073b4 <vector69>:
.globl vector69
vector69:
  pushl $0
801073b4:	6a 00                	push   $0x0
  pushl $69
801073b6:	6a 45                	push   $0x45
  jmp alltraps
801073b8:	e9 1a f7 ff ff       	jmp    80106ad7 <alltraps>

801073bd <vector70>:
.globl vector70
vector70:
  pushl $0
801073bd:	6a 00                	push   $0x0
  pushl $70
801073bf:	6a 46                	push   $0x46
  jmp alltraps
801073c1:	e9 11 f7 ff ff       	jmp    80106ad7 <alltraps>

801073c6 <vector71>:
.globl vector71
vector71:
  pushl $0
801073c6:	6a 00                	push   $0x0
  pushl $71
801073c8:	6a 47                	push   $0x47
  jmp alltraps
801073ca:	e9 08 f7 ff ff       	jmp    80106ad7 <alltraps>

801073cf <vector72>:
.globl vector72
vector72:
  pushl $0
801073cf:	6a 00                	push   $0x0
  pushl $72
801073d1:	6a 48                	push   $0x48
  jmp alltraps
801073d3:	e9 ff f6 ff ff       	jmp    80106ad7 <alltraps>

801073d8 <vector73>:
.globl vector73
vector73:
  pushl $0
801073d8:	6a 00                	push   $0x0
  pushl $73
801073da:	6a 49                	push   $0x49
  jmp alltraps
801073dc:	e9 f6 f6 ff ff       	jmp    80106ad7 <alltraps>

801073e1 <vector74>:
.globl vector74
vector74:
  pushl $0
801073e1:	6a 00                	push   $0x0
  pushl $74
801073e3:	6a 4a                	push   $0x4a
  jmp alltraps
801073e5:	e9 ed f6 ff ff       	jmp    80106ad7 <alltraps>

801073ea <vector75>:
.globl vector75
vector75:
  pushl $0
801073ea:	6a 00                	push   $0x0
  pushl $75
801073ec:	6a 4b                	push   $0x4b
  jmp alltraps
801073ee:	e9 e4 f6 ff ff       	jmp    80106ad7 <alltraps>

801073f3 <vector76>:
.globl vector76
vector76:
  pushl $0
801073f3:	6a 00                	push   $0x0
  pushl $76
801073f5:	6a 4c                	push   $0x4c
  jmp alltraps
801073f7:	e9 db f6 ff ff       	jmp    80106ad7 <alltraps>

801073fc <vector77>:
.globl vector77
vector77:
  pushl $0
801073fc:	6a 00                	push   $0x0
  pushl $77
801073fe:	6a 4d                	push   $0x4d
  jmp alltraps
80107400:	e9 d2 f6 ff ff       	jmp    80106ad7 <alltraps>

80107405 <vector78>:
.globl vector78
vector78:
  pushl $0
80107405:	6a 00                	push   $0x0
  pushl $78
80107407:	6a 4e                	push   $0x4e
  jmp alltraps
80107409:	e9 c9 f6 ff ff       	jmp    80106ad7 <alltraps>

8010740e <vector79>:
.globl vector79
vector79:
  pushl $0
8010740e:	6a 00                	push   $0x0
  pushl $79
80107410:	6a 4f                	push   $0x4f
  jmp alltraps
80107412:	e9 c0 f6 ff ff       	jmp    80106ad7 <alltraps>

80107417 <vector80>:
.globl vector80
vector80:
  pushl $0
80107417:	6a 00                	push   $0x0
  pushl $80
80107419:	6a 50                	push   $0x50
  jmp alltraps
8010741b:	e9 b7 f6 ff ff       	jmp    80106ad7 <alltraps>

80107420 <vector81>:
.globl vector81
vector81:
  pushl $0
80107420:	6a 00                	push   $0x0
  pushl $81
80107422:	6a 51                	push   $0x51
  jmp alltraps
80107424:	e9 ae f6 ff ff       	jmp    80106ad7 <alltraps>

80107429 <vector82>:
.globl vector82
vector82:
  pushl $0
80107429:	6a 00                	push   $0x0
  pushl $82
8010742b:	6a 52                	push   $0x52
  jmp alltraps
8010742d:	e9 a5 f6 ff ff       	jmp    80106ad7 <alltraps>

80107432 <vector83>:
.globl vector83
vector83:
  pushl $0
80107432:	6a 00                	push   $0x0
  pushl $83
80107434:	6a 53                	push   $0x53
  jmp alltraps
80107436:	e9 9c f6 ff ff       	jmp    80106ad7 <alltraps>

8010743b <vector84>:
.globl vector84
vector84:
  pushl $0
8010743b:	6a 00                	push   $0x0
  pushl $84
8010743d:	6a 54                	push   $0x54
  jmp alltraps
8010743f:	e9 93 f6 ff ff       	jmp    80106ad7 <alltraps>

80107444 <vector85>:
.globl vector85
vector85:
  pushl $0
80107444:	6a 00                	push   $0x0
  pushl $85
80107446:	6a 55                	push   $0x55
  jmp alltraps
80107448:	e9 8a f6 ff ff       	jmp    80106ad7 <alltraps>

8010744d <vector86>:
.globl vector86
vector86:
  pushl $0
8010744d:	6a 00                	push   $0x0
  pushl $86
8010744f:	6a 56                	push   $0x56
  jmp alltraps
80107451:	e9 81 f6 ff ff       	jmp    80106ad7 <alltraps>

80107456 <vector87>:
.globl vector87
vector87:
  pushl $0
80107456:	6a 00                	push   $0x0
  pushl $87
80107458:	6a 57                	push   $0x57
  jmp alltraps
8010745a:	e9 78 f6 ff ff       	jmp    80106ad7 <alltraps>

8010745f <vector88>:
.globl vector88
vector88:
  pushl $0
8010745f:	6a 00                	push   $0x0
  pushl $88
80107461:	6a 58                	push   $0x58
  jmp alltraps
80107463:	e9 6f f6 ff ff       	jmp    80106ad7 <alltraps>

80107468 <vector89>:
.globl vector89
vector89:
  pushl $0
80107468:	6a 00                	push   $0x0
  pushl $89
8010746a:	6a 59                	push   $0x59
  jmp alltraps
8010746c:	e9 66 f6 ff ff       	jmp    80106ad7 <alltraps>

80107471 <vector90>:
.globl vector90
vector90:
  pushl $0
80107471:	6a 00                	push   $0x0
  pushl $90
80107473:	6a 5a                	push   $0x5a
  jmp alltraps
80107475:	e9 5d f6 ff ff       	jmp    80106ad7 <alltraps>

8010747a <vector91>:
.globl vector91
vector91:
  pushl $0
8010747a:	6a 00                	push   $0x0
  pushl $91
8010747c:	6a 5b                	push   $0x5b
  jmp alltraps
8010747e:	e9 54 f6 ff ff       	jmp    80106ad7 <alltraps>

80107483 <vector92>:
.globl vector92
vector92:
  pushl $0
80107483:	6a 00                	push   $0x0
  pushl $92
80107485:	6a 5c                	push   $0x5c
  jmp alltraps
80107487:	e9 4b f6 ff ff       	jmp    80106ad7 <alltraps>

8010748c <vector93>:
.globl vector93
vector93:
  pushl $0
8010748c:	6a 00                	push   $0x0
  pushl $93
8010748e:	6a 5d                	push   $0x5d
  jmp alltraps
80107490:	e9 42 f6 ff ff       	jmp    80106ad7 <alltraps>

80107495 <vector94>:
.globl vector94
vector94:
  pushl $0
80107495:	6a 00                	push   $0x0
  pushl $94
80107497:	6a 5e                	push   $0x5e
  jmp alltraps
80107499:	e9 39 f6 ff ff       	jmp    80106ad7 <alltraps>

8010749e <vector95>:
.globl vector95
vector95:
  pushl $0
8010749e:	6a 00                	push   $0x0
  pushl $95
801074a0:	6a 5f                	push   $0x5f
  jmp alltraps
801074a2:	e9 30 f6 ff ff       	jmp    80106ad7 <alltraps>

801074a7 <vector96>:
.globl vector96
vector96:
  pushl $0
801074a7:	6a 00                	push   $0x0
  pushl $96
801074a9:	6a 60                	push   $0x60
  jmp alltraps
801074ab:	e9 27 f6 ff ff       	jmp    80106ad7 <alltraps>

801074b0 <vector97>:
.globl vector97
vector97:
  pushl $0
801074b0:	6a 00                	push   $0x0
  pushl $97
801074b2:	6a 61                	push   $0x61
  jmp alltraps
801074b4:	e9 1e f6 ff ff       	jmp    80106ad7 <alltraps>

801074b9 <vector98>:
.globl vector98
vector98:
  pushl $0
801074b9:	6a 00                	push   $0x0
  pushl $98
801074bb:	6a 62                	push   $0x62
  jmp alltraps
801074bd:	e9 15 f6 ff ff       	jmp    80106ad7 <alltraps>

801074c2 <vector99>:
.globl vector99
vector99:
  pushl $0
801074c2:	6a 00                	push   $0x0
  pushl $99
801074c4:	6a 63                	push   $0x63
  jmp alltraps
801074c6:	e9 0c f6 ff ff       	jmp    80106ad7 <alltraps>

801074cb <vector100>:
.globl vector100
vector100:
  pushl $0
801074cb:	6a 00                	push   $0x0
  pushl $100
801074cd:	6a 64                	push   $0x64
  jmp alltraps
801074cf:	e9 03 f6 ff ff       	jmp    80106ad7 <alltraps>

801074d4 <vector101>:
.globl vector101
vector101:
  pushl $0
801074d4:	6a 00                	push   $0x0
  pushl $101
801074d6:	6a 65                	push   $0x65
  jmp alltraps
801074d8:	e9 fa f5 ff ff       	jmp    80106ad7 <alltraps>

801074dd <vector102>:
.globl vector102
vector102:
  pushl $0
801074dd:	6a 00                	push   $0x0
  pushl $102
801074df:	6a 66                	push   $0x66
  jmp alltraps
801074e1:	e9 f1 f5 ff ff       	jmp    80106ad7 <alltraps>

801074e6 <vector103>:
.globl vector103
vector103:
  pushl $0
801074e6:	6a 00                	push   $0x0
  pushl $103
801074e8:	6a 67                	push   $0x67
  jmp alltraps
801074ea:	e9 e8 f5 ff ff       	jmp    80106ad7 <alltraps>

801074ef <vector104>:
.globl vector104
vector104:
  pushl $0
801074ef:	6a 00                	push   $0x0
  pushl $104
801074f1:	6a 68                	push   $0x68
  jmp alltraps
801074f3:	e9 df f5 ff ff       	jmp    80106ad7 <alltraps>

801074f8 <vector105>:
.globl vector105
vector105:
  pushl $0
801074f8:	6a 00                	push   $0x0
  pushl $105
801074fa:	6a 69                	push   $0x69
  jmp alltraps
801074fc:	e9 d6 f5 ff ff       	jmp    80106ad7 <alltraps>

80107501 <vector106>:
.globl vector106
vector106:
  pushl $0
80107501:	6a 00                	push   $0x0
  pushl $106
80107503:	6a 6a                	push   $0x6a
  jmp alltraps
80107505:	e9 cd f5 ff ff       	jmp    80106ad7 <alltraps>

8010750a <vector107>:
.globl vector107
vector107:
  pushl $0
8010750a:	6a 00                	push   $0x0
  pushl $107
8010750c:	6a 6b                	push   $0x6b
  jmp alltraps
8010750e:	e9 c4 f5 ff ff       	jmp    80106ad7 <alltraps>

80107513 <vector108>:
.globl vector108
vector108:
  pushl $0
80107513:	6a 00                	push   $0x0
  pushl $108
80107515:	6a 6c                	push   $0x6c
  jmp alltraps
80107517:	e9 bb f5 ff ff       	jmp    80106ad7 <alltraps>

8010751c <vector109>:
.globl vector109
vector109:
  pushl $0
8010751c:	6a 00                	push   $0x0
  pushl $109
8010751e:	6a 6d                	push   $0x6d
  jmp alltraps
80107520:	e9 b2 f5 ff ff       	jmp    80106ad7 <alltraps>

80107525 <vector110>:
.globl vector110
vector110:
  pushl $0
80107525:	6a 00                	push   $0x0
  pushl $110
80107527:	6a 6e                	push   $0x6e
  jmp alltraps
80107529:	e9 a9 f5 ff ff       	jmp    80106ad7 <alltraps>

8010752e <vector111>:
.globl vector111
vector111:
  pushl $0
8010752e:	6a 00                	push   $0x0
  pushl $111
80107530:	6a 6f                	push   $0x6f
  jmp alltraps
80107532:	e9 a0 f5 ff ff       	jmp    80106ad7 <alltraps>

80107537 <vector112>:
.globl vector112
vector112:
  pushl $0
80107537:	6a 00                	push   $0x0
  pushl $112
80107539:	6a 70                	push   $0x70
  jmp alltraps
8010753b:	e9 97 f5 ff ff       	jmp    80106ad7 <alltraps>

80107540 <vector113>:
.globl vector113
vector113:
  pushl $0
80107540:	6a 00                	push   $0x0
  pushl $113
80107542:	6a 71                	push   $0x71
  jmp alltraps
80107544:	e9 8e f5 ff ff       	jmp    80106ad7 <alltraps>

80107549 <vector114>:
.globl vector114
vector114:
  pushl $0
80107549:	6a 00                	push   $0x0
  pushl $114
8010754b:	6a 72                	push   $0x72
  jmp alltraps
8010754d:	e9 85 f5 ff ff       	jmp    80106ad7 <alltraps>

80107552 <vector115>:
.globl vector115
vector115:
  pushl $0
80107552:	6a 00                	push   $0x0
  pushl $115
80107554:	6a 73                	push   $0x73
  jmp alltraps
80107556:	e9 7c f5 ff ff       	jmp    80106ad7 <alltraps>

8010755b <vector116>:
.globl vector116
vector116:
  pushl $0
8010755b:	6a 00                	push   $0x0
  pushl $116
8010755d:	6a 74                	push   $0x74
  jmp alltraps
8010755f:	e9 73 f5 ff ff       	jmp    80106ad7 <alltraps>

80107564 <vector117>:
.globl vector117
vector117:
  pushl $0
80107564:	6a 00                	push   $0x0
  pushl $117
80107566:	6a 75                	push   $0x75
  jmp alltraps
80107568:	e9 6a f5 ff ff       	jmp    80106ad7 <alltraps>

8010756d <vector118>:
.globl vector118
vector118:
  pushl $0
8010756d:	6a 00                	push   $0x0
  pushl $118
8010756f:	6a 76                	push   $0x76
  jmp alltraps
80107571:	e9 61 f5 ff ff       	jmp    80106ad7 <alltraps>

80107576 <vector119>:
.globl vector119
vector119:
  pushl $0
80107576:	6a 00                	push   $0x0
  pushl $119
80107578:	6a 77                	push   $0x77
  jmp alltraps
8010757a:	e9 58 f5 ff ff       	jmp    80106ad7 <alltraps>

8010757f <vector120>:
.globl vector120
vector120:
  pushl $0
8010757f:	6a 00                	push   $0x0
  pushl $120
80107581:	6a 78                	push   $0x78
  jmp alltraps
80107583:	e9 4f f5 ff ff       	jmp    80106ad7 <alltraps>

80107588 <vector121>:
.globl vector121
vector121:
  pushl $0
80107588:	6a 00                	push   $0x0
  pushl $121
8010758a:	6a 79                	push   $0x79
  jmp alltraps
8010758c:	e9 46 f5 ff ff       	jmp    80106ad7 <alltraps>

80107591 <vector122>:
.globl vector122
vector122:
  pushl $0
80107591:	6a 00                	push   $0x0
  pushl $122
80107593:	6a 7a                	push   $0x7a
  jmp alltraps
80107595:	e9 3d f5 ff ff       	jmp    80106ad7 <alltraps>

8010759a <vector123>:
.globl vector123
vector123:
  pushl $0
8010759a:	6a 00                	push   $0x0
  pushl $123
8010759c:	6a 7b                	push   $0x7b
  jmp alltraps
8010759e:	e9 34 f5 ff ff       	jmp    80106ad7 <alltraps>

801075a3 <vector124>:
.globl vector124
vector124:
  pushl $0
801075a3:	6a 00                	push   $0x0
  pushl $124
801075a5:	6a 7c                	push   $0x7c
  jmp alltraps
801075a7:	e9 2b f5 ff ff       	jmp    80106ad7 <alltraps>

801075ac <vector125>:
.globl vector125
vector125:
  pushl $0
801075ac:	6a 00                	push   $0x0
  pushl $125
801075ae:	6a 7d                	push   $0x7d
  jmp alltraps
801075b0:	e9 22 f5 ff ff       	jmp    80106ad7 <alltraps>

801075b5 <vector126>:
.globl vector126
vector126:
  pushl $0
801075b5:	6a 00                	push   $0x0
  pushl $126
801075b7:	6a 7e                	push   $0x7e
  jmp alltraps
801075b9:	e9 19 f5 ff ff       	jmp    80106ad7 <alltraps>

801075be <vector127>:
.globl vector127
vector127:
  pushl $0
801075be:	6a 00                	push   $0x0
  pushl $127
801075c0:	6a 7f                	push   $0x7f
  jmp alltraps
801075c2:	e9 10 f5 ff ff       	jmp    80106ad7 <alltraps>

801075c7 <vector128>:
.globl vector128
vector128:
  pushl $0
801075c7:	6a 00                	push   $0x0
  pushl $128
801075c9:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801075ce:	e9 04 f5 ff ff       	jmp    80106ad7 <alltraps>

801075d3 <vector129>:
.globl vector129
vector129:
  pushl $0
801075d3:	6a 00                	push   $0x0
  pushl $129
801075d5:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801075da:	e9 f8 f4 ff ff       	jmp    80106ad7 <alltraps>

801075df <vector130>:
.globl vector130
vector130:
  pushl $0
801075df:	6a 00                	push   $0x0
  pushl $130
801075e1:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801075e6:	e9 ec f4 ff ff       	jmp    80106ad7 <alltraps>

801075eb <vector131>:
.globl vector131
vector131:
  pushl $0
801075eb:	6a 00                	push   $0x0
  pushl $131
801075ed:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801075f2:	e9 e0 f4 ff ff       	jmp    80106ad7 <alltraps>

801075f7 <vector132>:
.globl vector132
vector132:
  pushl $0
801075f7:	6a 00                	push   $0x0
  pushl $132
801075f9:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801075fe:	e9 d4 f4 ff ff       	jmp    80106ad7 <alltraps>

80107603 <vector133>:
.globl vector133
vector133:
  pushl $0
80107603:	6a 00                	push   $0x0
  pushl $133
80107605:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010760a:	e9 c8 f4 ff ff       	jmp    80106ad7 <alltraps>

8010760f <vector134>:
.globl vector134
vector134:
  pushl $0
8010760f:	6a 00                	push   $0x0
  pushl $134
80107611:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107616:	e9 bc f4 ff ff       	jmp    80106ad7 <alltraps>

8010761b <vector135>:
.globl vector135
vector135:
  pushl $0
8010761b:	6a 00                	push   $0x0
  pushl $135
8010761d:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107622:	e9 b0 f4 ff ff       	jmp    80106ad7 <alltraps>

80107627 <vector136>:
.globl vector136
vector136:
  pushl $0
80107627:	6a 00                	push   $0x0
  pushl $136
80107629:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010762e:	e9 a4 f4 ff ff       	jmp    80106ad7 <alltraps>

80107633 <vector137>:
.globl vector137
vector137:
  pushl $0
80107633:	6a 00                	push   $0x0
  pushl $137
80107635:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010763a:	e9 98 f4 ff ff       	jmp    80106ad7 <alltraps>

8010763f <vector138>:
.globl vector138
vector138:
  pushl $0
8010763f:	6a 00                	push   $0x0
  pushl $138
80107641:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107646:	e9 8c f4 ff ff       	jmp    80106ad7 <alltraps>

8010764b <vector139>:
.globl vector139
vector139:
  pushl $0
8010764b:	6a 00                	push   $0x0
  pushl $139
8010764d:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107652:	e9 80 f4 ff ff       	jmp    80106ad7 <alltraps>

80107657 <vector140>:
.globl vector140
vector140:
  pushl $0
80107657:	6a 00                	push   $0x0
  pushl $140
80107659:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010765e:	e9 74 f4 ff ff       	jmp    80106ad7 <alltraps>

80107663 <vector141>:
.globl vector141
vector141:
  pushl $0
80107663:	6a 00                	push   $0x0
  pushl $141
80107665:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010766a:	e9 68 f4 ff ff       	jmp    80106ad7 <alltraps>

8010766f <vector142>:
.globl vector142
vector142:
  pushl $0
8010766f:	6a 00                	push   $0x0
  pushl $142
80107671:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107676:	e9 5c f4 ff ff       	jmp    80106ad7 <alltraps>

8010767b <vector143>:
.globl vector143
vector143:
  pushl $0
8010767b:	6a 00                	push   $0x0
  pushl $143
8010767d:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107682:	e9 50 f4 ff ff       	jmp    80106ad7 <alltraps>

80107687 <vector144>:
.globl vector144
vector144:
  pushl $0
80107687:	6a 00                	push   $0x0
  pushl $144
80107689:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010768e:	e9 44 f4 ff ff       	jmp    80106ad7 <alltraps>

80107693 <vector145>:
.globl vector145
vector145:
  pushl $0
80107693:	6a 00                	push   $0x0
  pushl $145
80107695:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010769a:	e9 38 f4 ff ff       	jmp    80106ad7 <alltraps>

8010769f <vector146>:
.globl vector146
vector146:
  pushl $0
8010769f:	6a 00                	push   $0x0
  pushl $146
801076a1:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801076a6:	e9 2c f4 ff ff       	jmp    80106ad7 <alltraps>

801076ab <vector147>:
.globl vector147
vector147:
  pushl $0
801076ab:	6a 00                	push   $0x0
  pushl $147
801076ad:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801076b2:	e9 20 f4 ff ff       	jmp    80106ad7 <alltraps>

801076b7 <vector148>:
.globl vector148
vector148:
  pushl $0
801076b7:	6a 00                	push   $0x0
  pushl $148
801076b9:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801076be:	e9 14 f4 ff ff       	jmp    80106ad7 <alltraps>

801076c3 <vector149>:
.globl vector149
vector149:
  pushl $0
801076c3:	6a 00                	push   $0x0
  pushl $149
801076c5:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801076ca:	e9 08 f4 ff ff       	jmp    80106ad7 <alltraps>

801076cf <vector150>:
.globl vector150
vector150:
  pushl $0
801076cf:	6a 00                	push   $0x0
  pushl $150
801076d1:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801076d6:	e9 fc f3 ff ff       	jmp    80106ad7 <alltraps>

801076db <vector151>:
.globl vector151
vector151:
  pushl $0
801076db:	6a 00                	push   $0x0
  pushl $151
801076dd:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801076e2:	e9 f0 f3 ff ff       	jmp    80106ad7 <alltraps>

801076e7 <vector152>:
.globl vector152
vector152:
  pushl $0
801076e7:	6a 00                	push   $0x0
  pushl $152
801076e9:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801076ee:	e9 e4 f3 ff ff       	jmp    80106ad7 <alltraps>

801076f3 <vector153>:
.globl vector153
vector153:
  pushl $0
801076f3:	6a 00                	push   $0x0
  pushl $153
801076f5:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801076fa:	e9 d8 f3 ff ff       	jmp    80106ad7 <alltraps>

801076ff <vector154>:
.globl vector154
vector154:
  pushl $0
801076ff:	6a 00                	push   $0x0
  pushl $154
80107701:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107706:	e9 cc f3 ff ff       	jmp    80106ad7 <alltraps>

8010770b <vector155>:
.globl vector155
vector155:
  pushl $0
8010770b:	6a 00                	push   $0x0
  pushl $155
8010770d:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107712:	e9 c0 f3 ff ff       	jmp    80106ad7 <alltraps>

80107717 <vector156>:
.globl vector156
vector156:
  pushl $0
80107717:	6a 00                	push   $0x0
  pushl $156
80107719:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010771e:	e9 b4 f3 ff ff       	jmp    80106ad7 <alltraps>

80107723 <vector157>:
.globl vector157
vector157:
  pushl $0
80107723:	6a 00                	push   $0x0
  pushl $157
80107725:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010772a:	e9 a8 f3 ff ff       	jmp    80106ad7 <alltraps>

8010772f <vector158>:
.globl vector158
vector158:
  pushl $0
8010772f:	6a 00                	push   $0x0
  pushl $158
80107731:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107736:	e9 9c f3 ff ff       	jmp    80106ad7 <alltraps>

8010773b <vector159>:
.globl vector159
vector159:
  pushl $0
8010773b:	6a 00                	push   $0x0
  pushl $159
8010773d:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107742:	e9 90 f3 ff ff       	jmp    80106ad7 <alltraps>

80107747 <vector160>:
.globl vector160
vector160:
  pushl $0
80107747:	6a 00                	push   $0x0
  pushl $160
80107749:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010774e:	e9 84 f3 ff ff       	jmp    80106ad7 <alltraps>

80107753 <vector161>:
.globl vector161
vector161:
  pushl $0
80107753:	6a 00                	push   $0x0
  pushl $161
80107755:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010775a:	e9 78 f3 ff ff       	jmp    80106ad7 <alltraps>

8010775f <vector162>:
.globl vector162
vector162:
  pushl $0
8010775f:	6a 00                	push   $0x0
  pushl $162
80107761:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107766:	e9 6c f3 ff ff       	jmp    80106ad7 <alltraps>

8010776b <vector163>:
.globl vector163
vector163:
  pushl $0
8010776b:	6a 00                	push   $0x0
  pushl $163
8010776d:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107772:	e9 60 f3 ff ff       	jmp    80106ad7 <alltraps>

80107777 <vector164>:
.globl vector164
vector164:
  pushl $0
80107777:	6a 00                	push   $0x0
  pushl $164
80107779:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010777e:	e9 54 f3 ff ff       	jmp    80106ad7 <alltraps>

80107783 <vector165>:
.globl vector165
vector165:
  pushl $0
80107783:	6a 00                	push   $0x0
  pushl $165
80107785:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010778a:	e9 48 f3 ff ff       	jmp    80106ad7 <alltraps>

8010778f <vector166>:
.globl vector166
vector166:
  pushl $0
8010778f:	6a 00                	push   $0x0
  pushl $166
80107791:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107796:	e9 3c f3 ff ff       	jmp    80106ad7 <alltraps>

8010779b <vector167>:
.globl vector167
vector167:
  pushl $0
8010779b:	6a 00                	push   $0x0
  pushl $167
8010779d:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801077a2:	e9 30 f3 ff ff       	jmp    80106ad7 <alltraps>

801077a7 <vector168>:
.globl vector168
vector168:
  pushl $0
801077a7:	6a 00                	push   $0x0
  pushl $168
801077a9:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801077ae:	e9 24 f3 ff ff       	jmp    80106ad7 <alltraps>

801077b3 <vector169>:
.globl vector169
vector169:
  pushl $0
801077b3:	6a 00                	push   $0x0
  pushl $169
801077b5:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801077ba:	e9 18 f3 ff ff       	jmp    80106ad7 <alltraps>

801077bf <vector170>:
.globl vector170
vector170:
  pushl $0
801077bf:	6a 00                	push   $0x0
  pushl $170
801077c1:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801077c6:	e9 0c f3 ff ff       	jmp    80106ad7 <alltraps>

801077cb <vector171>:
.globl vector171
vector171:
  pushl $0
801077cb:	6a 00                	push   $0x0
  pushl $171
801077cd:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801077d2:	e9 00 f3 ff ff       	jmp    80106ad7 <alltraps>

801077d7 <vector172>:
.globl vector172
vector172:
  pushl $0
801077d7:	6a 00                	push   $0x0
  pushl $172
801077d9:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801077de:	e9 f4 f2 ff ff       	jmp    80106ad7 <alltraps>

801077e3 <vector173>:
.globl vector173
vector173:
  pushl $0
801077e3:	6a 00                	push   $0x0
  pushl $173
801077e5:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801077ea:	e9 e8 f2 ff ff       	jmp    80106ad7 <alltraps>

801077ef <vector174>:
.globl vector174
vector174:
  pushl $0
801077ef:	6a 00                	push   $0x0
  pushl $174
801077f1:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801077f6:	e9 dc f2 ff ff       	jmp    80106ad7 <alltraps>

801077fb <vector175>:
.globl vector175
vector175:
  pushl $0
801077fb:	6a 00                	push   $0x0
  pushl $175
801077fd:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107802:	e9 d0 f2 ff ff       	jmp    80106ad7 <alltraps>

80107807 <vector176>:
.globl vector176
vector176:
  pushl $0
80107807:	6a 00                	push   $0x0
  pushl $176
80107809:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010780e:	e9 c4 f2 ff ff       	jmp    80106ad7 <alltraps>

80107813 <vector177>:
.globl vector177
vector177:
  pushl $0
80107813:	6a 00                	push   $0x0
  pushl $177
80107815:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010781a:	e9 b8 f2 ff ff       	jmp    80106ad7 <alltraps>

8010781f <vector178>:
.globl vector178
vector178:
  pushl $0
8010781f:	6a 00                	push   $0x0
  pushl $178
80107821:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107826:	e9 ac f2 ff ff       	jmp    80106ad7 <alltraps>

8010782b <vector179>:
.globl vector179
vector179:
  pushl $0
8010782b:	6a 00                	push   $0x0
  pushl $179
8010782d:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107832:	e9 a0 f2 ff ff       	jmp    80106ad7 <alltraps>

80107837 <vector180>:
.globl vector180
vector180:
  pushl $0
80107837:	6a 00                	push   $0x0
  pushl $180
80107839:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010783e:	e9 94 f2 ff ff       	jmp    80106ad7 <alltraps>

80107843 <vector181>:
.globl vector181
vector181:
  pushl $0
80107843:	6a 00                	push   $0x0
  pushl $181
80107845:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010784a:	e9 88 f2 ff ff       	jmp    80106ad7 <alltraps>

8010784f <vector182>:
.globl vector182
vector182:
  pushl $0
8010784f:	6a 00                	push   $0x0
  pushl $182
80107851:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107856:	e9 7c f2 ff ff       	jmp    80106ad7 <alltraps>

8010785b <vector183>:
.globl vector183
vector183:
  pushl $0
8010785b:	6a 00                	push   $0x0
  pushl $183
8010785d:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107862:	e9 70 f2 ff ff       	jmp    80106ad7 <alltraps>

80107867 <vector184>:
.globl vector184
vector184:
  pushl $0
80107867:	6a 00                	push   $0x0
  pushl $184
80107869:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010786e:	e9 64 f2 ff ff       	jmp    80106ad7 <alltraps>

80107873 <vector185>:
.globl vector185
vector185:
  pushl $0
80107873:	6a 00                	push   $0x0
  pushl $185
80107875:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010787a:	e9 58 f2 ff ff       	jmp    80106ad7 <alltraps>

8010787f <vector186>:
.globl vector186
vector186:
  pushl $0
8010787f:	6a 00                	push   $0x0
  pushl $186
80107881:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107886:	e9 4c f2 ff ff       	jmp    80106ad7 <alltraps>

8010788b <vector187>:
.globl vector187
vector187:
  pushl $0
8010788b:	6a 00                	push   $0x0
  pushl $187
8010788d:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107892:	e9 40 f2 ff ff       	jmp    80106ad7 <alltraps>

80107897 <vector188>:
.globl vector188
vector188:
  pushl $0
80107897:	6a 00                	push   $0x0
  pushl $188
80107899:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010789e:	e9 34 f2 ff ff       	jmp    80106ad7 <alltraps>

801078a3 <vector189>:
.globl vector189
vector189:
  pushl $0
801078a3:	6a 00                	push   $0x0
  pushl $189
801078a5:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801078aa:	e9 28 f2 ff ff       	jmp    80106ad7 <alltraps>

801078af <vector190>:
.globl vector190
vector190:
  pushl $0
801078af:	6a 00                	push   $0x0
  pushl $190
801078b1:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801078b6:	e9 1c f2 ff ff       	jmp    80106ad7 <alltraps>

801078bb <vector191>:
.globl vector191
vector191:
  pushl $0
801078bb:	6a 00                	push   $0x0
  pushl $191
801078bd:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801078c2:	e9 10 f2 ff ff       	jmp    80106ad7 <alltraps>

801078c7 <vector192>:
.globl vector192
vector192:
  pushl $0
801078c7:	6a 00                	push   $0x0
  pushl $192
801078c9:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801078ce:	e9 04 f2 ff ff       	jmp    80106ad7 <alltraps>

801078d3 <vector193>:
.globl vector193
vector193:
  pushl $0
801078d3:	6a 00                	push   $0x0
  pushl $193
801078d5:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801078da:	e9 f8 f1 ff ff       	jmp    80106ad7 <alltraps>

801078df <vector194>:
.globl vector194
vector194:
  pushl $0
801078df:	6a 00                	push   $0x0
  pushl $194
801078e1:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801078e6:	e9 ec f1 ff ff       	jmp    80106ad7 <alltraps>

801078eb <vector195>:
.globl vector195
vector195:
  pushl $0
801078eb:	6a 00                	push   $0x0
  pushl $195
801078ed:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801078f2:	e9 e0 f1 ff ff       	jmp    80106ad7 <alltraps>

801078f7 <vector196>:
.globl vector196
vector196:
  pushl $0
801078f7:	6a 00                	push   $0x0
  pushl $196
801078f9:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801078fe:	e9 d4 f1 ff ff       	jmp    80106ad7 <alltraps>

80107903 <vector197>:
.globl vector197
vector197:
  pushl $0
80107903:	6a 00                	push   $0x0
  pushl $197
80107905:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010790a:	e9 c8 f1 ff ff       	jmp    80106ad7 <alltraps>

8010790f <vector198>:
.globl vector198
vector198:
  pushl $0
8010790f:	6a 00                	push   $0x0
  pushl $198
80107911:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107916:	e9 bc f1 ff ff       	jmp    80106ad7 <alltraps>

8010791b <vector199>:
.globl vector199
vector199:
  pushl $0
8010791b:	6a 00                	push   $0x0
  pushl $199
8010791d:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107922:	e9 b0 f1 ff ff       	jmp    80106ad7 <alltraps>

80107927 <vector200>:
.globl vector200
vector200:
  pushl $0
80107927:	6a 00                	push   $0x0
  pushl $200
80107929:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010792e:	e9 a4 f1 ff ff       	jmp    80106ad7 <alltraps>

80107933 <vector201>:
.globl vector201
vector201:
  pushl $0
80107933:	6a 00                	push   $0x0
  pushl $201
80107935:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010793a:	e9 98 f1 ff ff       	jmp    80106ad7 <alltraps>

8010793f <vector202>:
.globl vector202
vector202:
  pushl $0
8010793f:	6a 00                	push   $0x0
  pushl $202
80107941:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107946:	e9 8c f1 ff ff       	jmp    80106ad7 <alltraps>

8010794b <vector203>:
.globl vector203
vector203:
  pushl $0
8010794b:	6a 00                	push   $0x0
  pushl $203
8010794d:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107952:	e9 80 f1 ff ff       	jmp    80106ad7 <alltraps>

80107957 <vector204>:
.globl vector204
vector204:
  pushl $0
80107957:	6a 00                	push   $0x0
  pushl $204
80107959:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010795e:	e9 74 f1 ff ff       	jmp    80106ad7 <alltraps>

80107963 <vector205>:
.globl vector205
vector205:
  pushl $0
80107963:	6a 00                	push   $0x0
  pushl $205
80107965:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010796a:	e9 68 f1 ff ff       	jmp    80106ad7 <alltraps>

8010796f <vector206>:
.globl vector206
vector206:
  pushl $0
8010796f:	6a 00                	push   $0x0
  pushl $206
80107971:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107976:	e9 5c f1 ff ff       	jmp    80106ad7 <alltraps>

8010797b <vector207>:
.globl vector207
vector207:
  pushl $0
8010797b:	6a 00                	push   $0x0
  pushl $207
8010797d:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107982:	e9 50 f1 ff ff       	jmp    80106ad7 <alltraps>

80107987 <vector208>:
.globl vector208
vector208:
  pushl $0
80107987:	6a 00                	push   $0x0
  pushl $208
80107989:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010798e:	e9 44 f1 ff ff       	jmp    80106ad7 <alltraps>

80107993 <vector209>:
.globl vector209
vector209:
  pushl $0
80107993:	6a 00                	push   $0x0
  pushl $209
80107995:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010799a:	e9 38 f1 ff ff       	jmp    80106ad7 <alltraps>

8010799f <vector210>:
.globl vector210
vector210:
  pushl $0
8010799f:	6a 00                	push   $0x0
  pushl $210
801079a1:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801079a6:	e9 2c f1 ff ff       	jmp    80106ad7 <alltraps>

801079ab <vector211>:
.globl vector211
vector211:
  pushl $0
801079ab:	6a 00                	push   $0x0
  pushl $211
801079ad:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801079b2:	e9 20 f1 ff ff       	jmp    80106ad7 <alltraps>

801079b7 <vector212>:
.globl vector212
vector212:
  pushl $0
801079b7:	6a 00                	push   $0x0
  pushl $212
801079b9:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801079be:	e9 14 f1 ff ff       	jmp    80106ad7 <alltraps>

801079c3 <vector213>:
.globl vector213
vector213:
  pushl $0
801079c3:	6a 00                	push   $0x0
  pushl $213
801079c5:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801079ca:	e9 08 f1 ff ff       	jmp    80106ad7 <alltraps>

801079cf <vector214>:
.globl vector214
vector214:
  pushl $0
801079cf:	6a 00                	push   $0x0
  pushl $214
801079d1:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801079d6:	e9 fc f0 ff ff       	jmp    80106ad7 <alltraps>

801079db <vector215>:
.globl vector215
vector215:
  pushl $0
801079db:	6a 00                	push   $0x0
  pushl $215
801079dd:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801079e2:	e9 f0 f0 ff ff       	jmp    80106ad7 <alltraps>

801079e7 <vector216>:
.globl vector216
vector216:
  pushl $0
801079e7:	6a 00                	push   $0x0
  pushl $216
801079e9:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801079ee:	e9 e4 f0 ff ff       	jmp    80106ad7 <alltraps>

801079f3 <vector217>:
.globl vector217
vector217:
  pushl $0
801079f3:	6a 00                	push   $0x0
  pushl $217
801079f5:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801079fa:	e9 d8 f0 ff ff       	jmp    80106ad7 <alltraps>

801079ff <vector218>:
.globl vector218
vector218:
  pushl $0
801079ff:	6a 00                	push   $0x0
  pushl $218
80107a01:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107a06:	e9 cc f0 ff ff       	jmp    80106ad7 <alltraps>

80107a0b <vector219>:
.globl vector219
vector219:
  pushl $0
80107a0b:	6a 00                	push   $0x0
  pushl $219
80107a0d:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107a12:	e9 c0 f0 ff ff       	jmp    80106ad7 <alltraps>

80107a17 <vector220>:
.globl vector220
vector220:
  pushl $0
80107a17:	6a 00                	push   $0x0
  pushl $220
80107a19:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107a1e:	e9 b4 f0 ff ff       	jmp    80106ad7 <alltraps>

80107a23 <vector221>:
.globl vector221
vector221:
  pushl $0
80107a23:	6a 00                	push   $0x0
  pushl $221
80107a25:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107a2a:	e9 a8 f0 ff ff       	jmp    80106ad7 <alltraps>

80107a2f <vector222>:
.globl vector222
vector222:
  pushl $0
80107a2f:	6a 00                	push   $0x0
  pushl $222
80107a31:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107a36:	e9 9c f0 ff ff       	jmp    80106ad7 <alltraps>

80107a3b <vector223>:
.globl vector223
vector223:
  pushl $0
80107a3b:	6a 00                	push   $0x0
  pushl $223
80107a3d:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107a42:	e9 90 f0 ff ff       	jmp    80106ad7 <alltraps>

80107a47 <vector224>:
.globl vector224
vector224:
  pushl $0
80107a47:	6a 00                	push   $0x0
  pushl $224
80107a49:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107a4e:	e9 84 f0 ff ff       	jmp    80106ad7 <alltraps>

80107a53 <vector225>:
.globl vector225
vector225:
  pushl $0
80107a53:	6a 00                	push   $0x0
  pushl $225
80107a55:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107a5a:	e9 78 f0 ff ff       	jmp    80106ad7 <alltraps>

80107a5f <vector226>:
.globl vector226
vector226:
  pushl $0
80107a5f:	6a 00                	push   $0x0
  pushl $226
80107a61:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107a66:	e9 6c f0 ff ff       	jmp    80106ad7 <alltraps>

80107a6b <vector227>:
.globl vector227
vector227:
  pushl $0
80107a6b:	6a 00                	push   $0x0
  pushl $227
80107a6d:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107a72:	e9 60 f0 ff ff       	jmp    80106ad7 <alltraps>

80107a77 <vector228>:
.globl vector228
vector228:
  pushl $0
80107a77:	6a 00                	push   $0x0
  pushl $228
80107a79:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107a7e:	e9 54 f0 ff ff       	jmp    80106ad7 <alltraps>

80107a83 <vector229>:
.globl vector229
vector229:
  pushl $0
80107a83:	6a 00                	push   $0x0
  pushl $229
80107a85:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107a8a:	e9 48 f0 ff ff       	jmp    80106ad7 <alltraps>

80107a8f <vector230>:
.globl vector230
vector230:
  pushl $0
80107a8f:	6a 00                	push   $0x0
  pushl $230
80107a91:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107a96:	e9 3c f0 ff ff       	jmp    80106ad7 <alltraps>

80107a9b <vector231>:
.globl vector231
vector231:
  pushl $0
80107a9b:	6a 00                	push   $0x0
  pushl $231
80107a9d:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107aa2:	e9 30 f0 ff ff       	jmp    80106ad7 <alltraps>

80107aa7 <vector232>:
.globl vector232
vector232:
  pushl $0
80107aa7:	6a 00                	push   $0x0
  pushl $232
80107aa9:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107aae:	e9 24 f0 ff ff       	jmp    80106ad7 <alltraps>

80107ab3 <vector233>:
.globl vector233
vector233:
  pushl $0
80107ab3:	6a 00                	push   $0x0
  pushl $233
80107ab5:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107aba:	e9 18 f0 ff ff       	jmp    80106ad7 <alltraps>

80107abf <vector234>:
.globl vector234
vector234:
  pushl $0
80107abf:	6a 00                	push   $0x0
  pushl $234
80107ac1:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107ac6:	e9 0c f0 ff ff       	jmp    80106ad7 <alltraps>

80107acb <vector235>:
.globl vector235
vector235:
  pushl $0
80107acb:	6a 00                	push   $0x0
  pushl $235
80107acd:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107ad2:	e9 00 f0 ff ff       	jmp    80106ad7 <alltraps>

80107ad7 <vector236>:
.globl vector236
vector236:
  pushl $0
80107ad7:	6a 00                	push   $0x0
  pushl $236
80107ad9:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107ade:	e9 f4 ef ff ff       	jmp    80106ad7 <alltraps>

80107ae3 <vector237>:
.globl vector237
vector237:
  pushl $0
80107ae3:	6a 00                	push   $0x0
  pushl $237
80107ae5:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107aea:	e9 e8 ef ff ff       	jmp    80106ad7 <alltraps>

80107aef <vector238>:
.globl vector238
vector238:
  pushl $0
80107aef:	6a 00                	push   $0x0
  pushl $238
80107af1:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107af6:	e9 dc ef ff ff       	jmp    80106ad7 <alltraps>

80107afb <vector239>:
.globl vector239
vector239:
  pushl $0
80107afb:	6a 00                	push   $0x0
  pushl $239
80107afd:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107b02:	e9 d0 ef ff ff       	jmp    80106ad7 <alltraps>

80107b07 <vector240>:
.globl vector240
vector240:
  pushl $0
80107b07:	6a 00                	push   $0x0
  pushl $240
80107b09:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107b0e:	e9 c4 ef ff ff       	jmp    80106ad7 <alltraps>

80107b13 <vector241>:
.globl vector241
vector241:
  pushl $0
80107b13:	6a 00                	push   $0x0
  pushl $241
80107b15:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107b1a:	e9 b8 ef ff ff       	jmp    80106ad7 <alltraps>

80107b1f <vector242>:
.globl vector242
vector242:
  pushl $0
80107b1f:	6a 00                	push   $0x0
  pushl $242
80107b21:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107b26:	e9 ac ef ff ff       	jmp    80106ad7 <alltraps>

80107b2b <vector243>:
.globl vector243
vector243:
  pushl $0
80107b2b:	6a 00                	push   $0x0
  pushl $243
80107b2d:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107b32:	e9 a0 ef ff ff       	jmp    80106ad7 <alltraps>

80107b37 <vector244>:
.globl vector244
vector244:
  pushl $0
80107b37:	6a 00                	push   $0x0
  pushl $244
80107b39:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107b3e:	e9 94 ef ff ff       	jmp    80106ad7 <alltraps>

80107b43 <vector245>:
.globl vector245
vector245:
  pushl $0
80107b43:	6a 00                	push   $0x0
  pushl $245
80107b45:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107b4a:	e9 88 ef ff ff       	jmp    80106ad7 <alltraps>

80107b4f <vector246>:
.globl vector246
vector246:
  pushl $0
80107b4f:	6a 00                	push   $0x0
  pushl $246
80107b51:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107b56:	e9 7c ef ff ff       	jmp    80106ad7 <alltraps>

80107b5b <vector247>:
.globl vector247
vector247:
  pushl $0
80107b5b:	6a 00                	push   $0x0
  pushl $247
80107b5d:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107b62:	e9 70 ef ff ff       	jmp    80106ad7 <alltraps>

80107b67 <vector248>:
.globl vector248
vector248:
  pushl $0
80107b67:	6a 00                	push   $0x0
  pushl $248
80107b69:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107b6e:	e9 64 ef ff ff       	jmp    80106ad7 <alltraps>

80107b73 <vector249>:
.globl vector249
vector249:
  pushl $0
80107b73:	6a 00                	push   $0x0
  pushl $249
80107b75:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107b7a:	e9 58 ef ff ff       	jmp    80106ad7 <alltraps>

80107b7f <vector250>:
.globl vector250
vector250:
  pushl $0
80107b7f:	6a 00                	push   $0x0
  pushl $250
80107b81:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107b86:	e9 4c ef ff ff       	jmp    80106ad7 <alltraps>

80107b8b <vector251>:
.globl vector251
vector251:
  pushl $0
80107b8b:	6a 00                	push   $0x0
  pushl $251
80107b8d:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107b92:	e9 40 ef ff ff       	jmp    80106ad7 <alltraps>

80107b97 <vector252>:
.globl vector252
vector252:
  pushl $0
80107b97:	6a 00                	push   $0x0
  pushl $252
80107b99:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107b9e:	e9 34 ef ff ff       	jmp    80106ad7 <alltraps>

80107ba3 <vector253>:
.globl vector253
vector253:
  pushl $0
80107ba3:	6a 00                	push   $0x0
  pushl $253
80107ba5:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107baa:	e9 28 ef ff ff       	jmp    80106ad7 <alltraps>

80107baf <vector254>:
.globl vector254
vector254:
  pushl $0
80107baf:	6a 00                	push   $0x0
  pushl $254
80107bb1:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107bb6:	e9 1c ef ff ff       	jmp    80106ad7 <alltraps>

80107bbb <vector255>:
.globl vector255
vector255:
  pushl $0
80107bbb:	6a 00                	push   $0x0
  pushl $255
80107bbd:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107bc2:	e9 10 ef ff ff       	jmp    80106ad7 <alltraps>

80107bc7 <lgdt>:
{
80107bc7:	55                   	push   %ebp
80107bc8:	89 e5                	mov    %esp,%ebp
80107bca:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107bcd:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bd0:	83 e8 01             	sub    $0x1,%eax
80107bd3:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107bd7:	8b 45 08             	mov    0x8(%ebp),%eax
80107bda:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107bde:	8b 45 08             	mov    0x8(%ebp),%eax
80107be1:	c1 e8 10             	shr    $0x10,%eax
80107be4:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107be8:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107beb:	0f 01 10             	lgdtl  (%eax)
}
80107bee:	90                   	nop
80107bef:	c9                   	leave  
80107bf0:	c3                   	ret    

80107bf1 <ltr>:
{
80107bf1:	55                   	push   %ebp
80107bf2:	89 e5                	mov    %esp,%ebp
80107bf4:	83 ec 04             	sub    $0x4,%esp
80107bf7:	8b 45 08             	mov    0x8(%ebp),%eax
80107bfa:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107bfe:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107c02:	0f 00 d8             	ltr    %ax
}
80107c05:	90                   	nop
80107c06:	c9                   	leave  
80107c07:	c3                   	ret    

80107c08 <lcr3>:

static inline void
lcr3(uint val)
{
80107c08:	55                   	push   %ebp
80107c09:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107c0b:	8b 45 08             	mov    0x8(%ebp),%eax
80107c0e:	0f 22 d8             	mov    %eax,%cr3
}
80107c11:	90                   	nop
80107c12:	5d                   	pop    %ebp
80107c13:	c3                   	ret    

80107c14 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107c14:	f3 0f 1e fb          	endbr32 
80107c18:	55                   	push   %ebp
80107c19:	89 e5                	mov    %esp,%ebp
80107c1b:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107c1e:	e8 51 c8 ff ff       	call   80104474 <cpuid>
80107c23:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107c29:	05 20 48 11 80       	add    $0x80114820,%eax
80107c2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c34:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107c3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3d:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c46:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107c4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4d:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c51:	83 e2 f0             	and    $0xfffffff0,%edx
80107c54:	83 ca 0a             	or     $0xa,%edx
80107c57:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c5d:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c61:	83 ca 10             	or     $0x10,%edx
80107c64:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c6a:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c6e:	83 e2 9f             	and    $0xffffff9f,%edx
80107c71:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c77:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c7b:	83 ca 80             	or     $0xffffff80,%edx
80107c7e:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c84:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c88:	83 ca 0f             	or     $0xf,%edx
80107c8b:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c91:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c95:	83 e2 ef             	and    $0xffffffef,%edx
80107c98:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ca2:	83 e2 df             	and    $0xffffffdf,%edx
80107ca5:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ca8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cab:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107caf:	83 ca 40             	or     $0x40,%edx
80107cb2:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb8:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107cbc:	83 ca 80             	or     $0xffffff80,%edx
80107cbf:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc5:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ccc:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107cd3:	ff ff 
80107cd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd8:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107cdf:	00 00 
80107ce1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce4:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107ceb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cee:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107cf5:	83 e2 f0             	and    $0xfffffff0,%edx
80107cf8:	83 ca 02             	or     $0x2,%edx
80107cfb:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d04:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d0b:	83 ca 10             	or     $0x10,%edx
80107d0e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d17:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d1e:	83 e2 9f             	and    $0xffffff9f,%edx
80107d21:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d31:	83 ca 80             	or     $0xffffff80,%edx
80107d34:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d44:	83 ca 0f             	or     $0xf,%edx
80107d47:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d50:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d57:	83 e2 ef             	and    $0xffffffef,%edx
80107d5a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d63:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d6a:	83 e2 df             	and    $0xffffffdf,%edx
80107d6d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d76:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d7d:	83 ca 40             	or     $0x40,%edx
80107d80:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d89:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d90:	83 ca 80             	or     $0xffffff80,%edx
80107d93:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9c:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107da3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da6:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107dad:	ff ff 
80107daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db2:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107db9:	00 00 
80107dbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dbe:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107dc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc8:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107dcf:	83 e2 f0             	and    $0xfffffff0,%edx
80107dd2:	83 ca 0a             	or     $0xa,%edx
80107dd5:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dde:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107de5:	83 ca 10             	or     $0x10,%edx
80107de8:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df1:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107df8:	83 ca 60             	or     $0x60,%edx
80107dfb:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107e01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e04:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107e0b:	83 ca 80             	or     $0xffffff80,%edx
80107e0e:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e17:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e1e:	83 ca 0f             	or     $0xf,%edx
80107e21:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e2a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e31:	83 e2 ef             	and    $0xffffffef,%edx
80107e34:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e3d:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e44:	83 e2 df             	and    $0xffffffdf,%edx
80107e47:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e50:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e57:	83 ca 40             	or     $0x40,%edx
80107e5a:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e63:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e6a:	83 ca 80             	or     $0xffffff80,%edx
80107e6d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e76:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e80:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107e87:	ff ff 
80107e89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e8c:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107e93:	00 00 
80107e95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e98:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107e9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea2:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ea9:	83 e2 f0             	and    $0xfffffff0,%edx
80107eac:	83 ca 02             	or     $0x2,%edx
80107eaf:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb8:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ebf:	83 ca 10             	or     $0x10,%edx
80107ec2:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ec8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ecb:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ed2:	83 ca 60             	or     $0x60,%edx
80107ed5:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ede:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ee5:	83 ca 80             	or     $0xffffff80,%edx
80107ee8:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107eee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef1:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ef8:	83 ca 0f             	or     $0xf,%edx
80107efb:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f04:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f0b:	83 e2 ef             	and    $0xffffffef,%edx
80107f0e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f17:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f1e:	83 e2 df             	and    $0xffffffdf,%edx
80107f21:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f2a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f31:	83 ca 40             	or     $0x40,%edx
80107f34:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f3d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f44:	83 ca 80             	or     $0xffffff80,%edx
80107f47:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f50:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107f57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f5a:	83 c0 70             	add    $0x70,%eax
80107f5d:	83 ec 08             	sub    $0x8,%esp
80107f60:	6a 30                	push   $0x30
80107f62:	50                   	push   %eax
80107f63:	e8 5f fc ff ff       	call   80107bc7 <lgdt>
80107f68:	83 c4 10             	add    $0x10,%esp
}
80107f6b:	90                   	nop
80107f6c:	c9                   	leave  
80107f6d:	c3                   	ret    

80107f6e <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107f6e:	f3 0f 1e fb          	endbr32 
80107f72:	55                   	push   %ebp
80107f73:	89 e5                	mov    %esp,%ebp
80107f75:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107f78:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f7b:	c1 e8 16             	shr    $0x16,%eax
80107f7e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f85:	8b 45 08             	mov    0x8(%ebp),%eax
80107f88:	01 d0                	add    %edx,%eax
80107f8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107f8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f90:	8b 00                	mov    (%eax),%eax
80107f92:	83 e0 01             	and    $0x1,%eax
80107f95:	85 c0                	test   %eax,%eax
80107f97:	74 14                	je     80107fad <walkpgdir+0x3f>
    //if (!alloc)
      //cprintf("page directory is good\n");
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107f99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f9c:	8b 00                	mov    (%eax),%eax
80107f9e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fa3:	05 00 00 00 80       	add    $0x80000000,%eax
80107fa8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107fab:	eb 42                	jmp    80107fef <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107fad:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107fb1:	74 0e                	je     80107fc1 <walkpgdir+0x53>
80107fb3:	e8 93 ae ff ff       	call   80102e4b <kalloc>
80107fb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107fbb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107fbf:	75 07                	jne    80107fc8 <walkpgdir+0x5a>
      return 0;
80107fc1:	b8 00 00 00 00       	mov    $0x0,%eax
80107fc6:	eb 3e                	jmp    80108006 <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107fc8:	83 ec 04             	sub    $0x4,%esp
80107fcb:	68 00 10 00 00       	push   $0x1000
80107fd0:	6a 00                	push   $0x0
80107fd2:	ff 75 f4             	pushl  -0xc(%ebp)
80107fd5:	e8 9f d5 ff ff       	call   80105579 <memset>
80107fda:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe0:	05 00 00 00 80       	add    $0x80000000,%eax
80107fe5:	83 c8 07             	or     $0x7,%eax
80107fe8:	89 c2                	mov    %eax,%edx
80107fea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fed:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107fef:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ff2:	c1 e8 0c             	shr    $0xc,%eax
80107ff5:	25 ff 03 00 00       	and    $0x3ff,%eax
80107ffa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108001:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108004:	01 d0                	add    %edx,%eax
}
80108006:	c9                   	leave  
80108007:	c3                   	ret    

80108008 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108008:	f3 0f 1e fb          	endbr32 
8010800c:	55                   	push   %ebp
8010800d:	89 e5                	mov    %esp,%ebp
8010800f:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80108012:	8b 45 0c             	mov    0xc(%ebp),%eax
80108015:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010801a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010801d:	8b 55 0c             	mov    0xc(%ebp),%edx
80108020:	8b 45 10             	mov    0x10(%ebp),%eax
80108023:	01 d0                	add    %edx,%eax
80108025:	83 e8 01             	sub    $0x1,%eax
80108028:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010802d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108030:	83 ec 04             	sub    $0x4,%esp
80108033:	6a 01                	push   $0x1
80108035:	ff 75 f4             	pushl  -0xc(%ebp)
80108038:	ff 75 08             	pushl  0x8(%ebp)
8010803b:	e8 2e ff ff ff       	call   80107f6e <walkpgdir>
80108040:	83 c4 10             	add    $0x10,%esp
80108043:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108046:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010804a:	75 07                	jne    80108053 <mappages+0x4b>
      return -1;
8010804c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108051:	eb 6a                	jmp    801080bd <mappages+0xb5>
    if(*pte & (PTE_P | PTE_E))
80108053:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108056:	8b 00                	mov    (%eax),%eax
80108058:	25 01 04 00 00       	and    $0x401,%eax
8010805d:	85 c0                	test   %eax,%eax
8010805f:	74 0d                	je     8010806e <mappages+0x66>
      panic("p4Debug, remapping page");
80108061:	83 ec 0c             	sub    $0xc,%esp
80108064:	68 80 9a 10 80       	push   $0x80109a80
80108069:	e8 9a 85 ff ff       	call   80100608 <panic>

    if (perm & PTE_E)
8010806e:	8b 45 18             	mov    0x18(%ebp),%eax
80108071:	25 00 04 00 00       	and    $0x400,%eax
80108076:	85 c0                	test   %eax,%eax
80108078:	74 12                	je     8010808c <mappages+0x84>
      *pte = pa | perm | PTE_E;
8010807a:	8b 45 18             	mov    0x18(%ebp),%eax
8010807d:	0b 45 14             	or     0x14(%ebp),%eax
80108080:	80 cc 04             	or     $0x4,%ah
80108083:	89 c2                	mov    %eax,%edx
80108085:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108088:	89 10                	mov    %edx,(%eax)
8010808a:	eb 10                	jmp    8010809c <mappages+0x94>
    else
      *pte = pa | perm | PTE_P;
8010808c:	8b 45 18             	mov    0x18(%ebp),%eax
8010808f:	0b 45 14             	or     0x14(%ebp),%eax
80108092:	83 c8 01             	or     $0x1,%eax
80108095:	89 c2                	mov    %eax,%edx
80108097:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010809a:	89 10                	mov    %edx,(%eax)


    if(a == last)
8010809c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010809f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801080a2:	74 13                	je     801080b7 <mappages+0xaf>
      break;
    a += PGSIZE;
801080a4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801080ab:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801080b2:	e9 79 ff ff ff       	jmp    80108030 <mappages+0x28>
      break;
801080b7:	90                   	nop
  }
  return 0;
801080b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801080bd:	c9                   	leave  
801080be:	c3                   	ret    

801080bf <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801080bf:	f3 0f 1e fb          	endbr32 
801080c3:	55                   	push   %ebp
801080c4:	89 e5                	mov    %esp,%ebp
801080c6:	53                   	push   %ebx
801080c7:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801080ca:	e8 7c ad ff ff       	call   80102e4b <kalloc>
801080cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
801080d2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801080d6:	75 07                	jne    801080df <setupkvm+0x20>
    return 0;
801080d8:	b8 00 00 00 00       	mov    $0x0,%eax
801080dd:	eb 78                	jmp    80108157 <setupkvm+0x98>
  memset(pgdir, 0, PGSIZE);
801080df:	83 ec 04             	sub    $0x4,%esp
801080e2:	68 00 10 00 00       	push   $0x1000
801080e7:	6a 00                	push   $0x0
801080e9:	ff 75 f0             	pushl  -0x10(%ebp)
801080ec:	e8 88 d4 ff ff       	call   80105579 <memset>
801080f1:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801080f4:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
801080fb:	eb 4e                	jmp    8010814b <setupkvm+0x8c>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801080fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108100:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80108103:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108106:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010810c:	8b 58 08             	mov    0x8(%eax),%ebx
8010810f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108112:	8b 40 04             	mov    0x4(%eax),%eax
80108115:	29 c3                	sub    %eax,%ebx
80108117:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010811a:	8b 00                	mov    (%eax),%eax
8010811c:	83 ec 0c             	sub    $0xc,%esp
8010811f:	51                   	push   %ecx
80108120:	52                   	push   %edx
80108121:	53                   	push   %ebx
80108122:	50                   	push   %eax
80108123:	ff 75 f0             	pushl  -0x10(%ebp)
80108126:	e8 dd fe ff ff       	call   80108008 <mappages>
8010812b:	83 c4 20             	add    $0x20,%esp
8010812e:	85 c0                	test   %eax,%eax
80108130:	79 15                	jns    80108147 <setupkvm+0x88>
      freevm(pgdir);
80108132:	83 ec 0c             	sub    $0xc,%esp
80108135:	ff 75 f0             	pushl  -0x10(%ebp)
80108138:	e8 13 05 00 00       	call   80108650 <freevm>
8010813d:	83 c4 10             	add    $0x10,%esp
      return 0;
80108140:	b8 00 00 00 00       	mov    $0x0,%eax
80108145:	eb 10                	jmp    80108157 <setupkvm+0x98>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108147:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010814b:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
80108152:	72 a9                	jb     801080fd <setupkvm+0x3e>
    }
  return pgdir;
80108154:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108157:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010815a:	c9                   	leave  
8010815b:	c3                   	ret    

8010815c <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
8010815c:	f3 0f 1e fb          	endbr32 
80108160:	55                   	push   %ebp
80108161:	89 e5                	mov    %esp,%ebp
80108163:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108166:	e8 54 ff ff ff       	call   801080bf <setupkvm>
8010816b:	a3 44 7f 11 80       	mov    %eax,0x80117f44
  switchkvm();
80108170:	e8 03 00 00 00       	call   80108178 <switchkvm>
}
80108175:	90                   	nop
80108176:	c9                   	leave  
80108177:	c3                   	ret    

80108178 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108178:	f3 0f 1e fb          	endbr32 
8010817c:	55                   	push   %ebp
8010817d:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
8010817f:	a1 44 7f 11 80       	mov    0x80117f44,%eax
80108184:	05 00 00 00 80       	add    $0x80000000,%eax
80108189:	50                   	push   %eax
8010818a:	e8 79 fa ff ff       	call   80107c08 <lcr3>
8010818f:	83 c4 04             	add    $0x4,%esp
}
80108192:	90                   	nop
80108193:	c9                   	leave  
80108194:	c3                   	ret    

80108195 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108195:	f3 0f 1e fb          	endbr32 
80108199:	55                   	push   %ebp
8010819a:	89 e5                	mov    %esp,%ebp
8010819c:	56                   	push   %esi
8010819d:	53                   	push   %ebx
8010819e:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
801081a1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801081a5:	75 0d                	jne    801081b4 <switchuvm+0x1f>
    panic("switchuvm: no process");
801081a7:	83 ec 0c             	sub    $0xc,%esp
801081aa:	68 98 9a 10 80       	push   $0x80109a98
801081af:	e8 54 84 ff ff       	call   80100608 <panic>
  if(p->kstack == 0)
801081b4:	8b 45 08             	mov    0x8(%ebp),%eax
801081b7:	8b 40 08             	mov    0x8(%eax),%eax
801081ba:	85 c0                	test   %eax,%eax
801081bc:	75 0d                	jne    801081cb <switchuvm+0x36>
    panic("switchuvm: no kstack");
801081be:	83 ec 0c             	sub    $0xc,%esp
801081c1:	68 ae 9a 10 80       	push   $0x80109aae
801081c6:	e8 3d 84 ff ff       	call   80100608 <panic>
  if(p->pgdir == 0)
801081cb:	8b 45 08             	mov    0x8(%ebp),%eax
801081ce:	8b 40 04             	mov    0x4(%eax),%eax
801081d1:	85 c0                	test   %eax,%eax
801081d3:	75 0d                	jne    801081e2 <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
801081d5:	83 ec 0c             	sub    $0xc,%esp
801081d8:	68 c3 9a 10 80       	push   $0x80109ac3
801081dd:	e8 26 84 ff ff       	call   80100608 <panic>

  pushcli();
801081e2:	e8 7f d2 ff ff       	call   80105466 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801081e7:	e8 a7 c2 ff ff       	call   80104493 <mycpu>
801081ec:	89 c3                	mov    %eax,%ebx
801081ee:	e8 a0 c2 ff ff       	call   80104493 <mycpu>
801081f3:	83 c0 08             	add    $0x8,%eax
801081f6:	89 c6                	mov    %eax,%esi
801081f8:	e8 96 c2 ff ff       	call   80104493 <mycpu>
801081fd:	83 c0 08             	add    $0x8,%eax
80108200:	c1 e8 10             	shr    $0x10,%eax
80108203:	88 45 f7             	mov    %al,-0x9(%ebp)
80108206:	e8 88 c2 ff ff       	call   80104493 <mycpu>
8010820b:	83 c0 08             	add    $0x8,%eax
8010820e:	c1 e8 18             	shr    $0x18,%eax
80108211:	89 c2                	mov    %eax,%edx
80108213:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
8010821a:	67 00 
8010821c:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80108223:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80108227:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
8010822d:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108234:	83 e0 f0             	and    $0xfffffff0,%eax
80108237:	83 c8 09             	or     $0x9,%eax
8010823a:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108240:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108247:	83 c8 10             	or     $0x10,%eax
8010824a:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108250:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108257:	83 e0 9f             	and    $0xffffff9f,%eax
8010825a:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108260:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108267:	83 c8 80             	or     $0xffffff80,%eax
8010826a:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108270:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108277:	83 e0 f0             	and    $0xfffffff0,%eax
8010827a:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108280:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108287:	83 e0 ef             	and    $0xffffffef,%eax
8010828a:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108290:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108297:	83 e0 df             	and    $0xffffffdf,%eax
8010829a:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801082a0:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801082a7:	83 c8 40             	or     $0x40,%eax
801082aa:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801082b0:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801082b7:	83 e0 7f             	and    $0x7f,%eax
801082ba:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801082c0:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801082c6:	e8 c8 c1 ff ff       	call   80104493 <mycpu>
801082cb:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801082d2:	83 e2 ef             	and    $0xffffffef,%edx
801082d5:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801082db:	e8 b3 c1 ff ff       	call   80104493 <mycpu>
801082e0:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801082e6:	8b 45 08             	mov    0x8(%ebp),%eax
801082e9:	8b 40 08             	mov    0x8(%eax),%eax
801082ec:	89 c3                	mov    %eax,%ebx
801082ee:	e8 a0 c1 ff ff       	call   80104493 <mycpu>
801082f3:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
801082f9:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801082fc:	e8 92 c1 ff ff       	call   80104493 <mycpu>
80108301:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80108307:	83 ec 0c             	sub    $0xc,%esp
8010830a:	6a 28                	push   $0x28
8010830c:	e8 e0 f8 ff ff       	call   80107bf1 <ltr>
80108311:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80108314:	8b 45 08             	mov    0x8(%ebp),%eax
80108317:	8b 40 04             	mov    0x4(%eax),%eax
8010831a:	05 00 00 00 80       	add    $0x80000000,%eax
8010831f:	83 ec 0c             	sub    $0xc,%esp
80108322:	50                   	push   %eax
80108323:	e8 e0 f8 ff ff       	call   80107c08 <lcr3>
80108328:	83 c4 10             	add    $0x10,%esp
  popcli();
8010832b:	e8 87 d1 ff ff       	call   801054b7 <popcli>
}
80108330:	90                   	nop
80108331:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108334:	5b                   	pop    %ebx
80108335:	5e                   	pop    %esi
80108336:	5d                   	pop    %ebp
80108337:	c3                   	ret    

80108338 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108338:	f3 0f 1e fb          	endbr32 
8010833c:	55                   	push   %ebp
8010833d:	89 e5                	mov    %esp,%ebp
8010833f:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80108342:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108349:	76 0d                	jbe    80108358 <inituvm+0x20>
    panic("inituvm: more than a page");
8010834b:	83 ec 0c             	sub    $0xc,%esp
8010834e:	68 d7 9a 10 80       	push   $0x80109ad7
80108353:	e8 b0 82 ff ff       	call   80100608 <panic>
  mem = kalloc();
80108358:	e8 ee aa ff ff       	call   80102e4b <kalloc>
8010835d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108360:	83 ec 04             	sub    $0x4,%esp
80108363:	68 00 10 00 00       	push   $0x1000
80108368:	6a 00                	push   $0x0
8010836a:	ff 75 f4             	pushl  -0xc(%ebp)
8010836d:	e8 07 d2 ff ff       	call   80105579 <memset>
80108372:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80108375:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108378:	05 00 00 00 80       	add    $0x80000000,%eax
8010837d:	83 ec 0c             	sub    $0xc,%esp
80108380:	6a 06                	push   $0x6
80108382:	50                   	push   %eax
80108383:	68 00 10 00 00       	push   $0x1000
80108388:	6a 00                	push   $0x0
8010838a:	ff 75 08             	pushl  0x8(%ebp)
8010838d:	e8 76 fc ff ff       	call   80108008 <mappages>
80108392:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108395:	83 ec 04             	sub    $0x4,%esp
80108398:	ff 75 10             	pushl  0x10(%ebp)
8010839b:	ff 75 0c             	pushl  0xc(%ebp)
8010839e:	ff 75 f4             	pushl  -0xc(%ebp)
801083a1:	e8 9a d2 ff ff       	call   80105640 <memmove>
801083a6:	83 c4 10             	add    $0x10,%esp
}
801083a9:	90                   	nop
801083aa:	c9                   	leave  
801083ab:	c3                   	ret    

801083ac <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801083ac:	f3 0f 1e fb          	endbr32 
801083b0:	55                   	push   %ebp
801083b1:	89 e5                	mov    %esp,%ebp
801083b3:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801083b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801083b9:	25 ff 0f 00 00       	and    $0xfff,%eax
801083be:	85 c0                	test   %eax,%eax
801083c0:	74 0d                	je     801083cf <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
801083c2:	83 ec 0c             	sub    $0xc,%esp
801083c5:	68 f4 9a 10 80       	push   $0x80109af4
801083ca:	e8 39 82 ff ff       	call   80100608 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801083cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083d6:	e9 8f 00 00 00       	jmp    8010846a <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801083db:	8b 55 0c             	mov    0xc(%ebp),%edx
801083de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e1:	01 d0                	add    %edx,%eax
801083e3:	83 ec 04             	sub    $0x4,%esp
801083e6:	6a 00                	push   $0x0
801083e8:	50                   	push   %eax
801083e9:	ff 75 08             	pushl  0x8(%ebp)
801083ec:	e8 7d fb ff ff       	call   80107f6e <walkpgdir>
801083f1:	83 c4 10             	add    $0x10,%esp
801083f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801083f7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801083fb:	75 0d                	jne    8010840a <loaduvm+0x5e>
      panic("loaduvm: address should exist");
801083fd:	83 ec 0c             	sub    $0xc,%esp
80108400:	68 17 9b 10 80       	push   $0x80109b17
80108405:	e8 fe 81 ff ff       	call   80100608 <panic>
    pa = PTE_ADDR(*pte);
8010840a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010840d:	8b 00                	mov    (%eax),%eax
8010840f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108414:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108417:	8b 45 18             	mov    0x18(%ebp),%eax
8010841a:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010841d:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108422:	77 0b                	ja     8010842f <loaduvm+0x83>
      n = sz - i;
80108424:	8b 45 18             	mov    0x18(%ebp),%eax
80108427:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010842a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010842d:	eb 07                	jmp    80108436 <loaduvm+0x8a>
    else
      n = PGSIZE;
8010842f:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108436:	8b 55 14             	mov    0x14(%ebp),%edx
80108439:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010843c:	01 d0                	add    %edx,%eax
8010843e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108441:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108447:	ff 75 f0             	pushl  -0x10(%ebp)
8010844a:	50                   	push   %eax
8010844b:	52                   	push   %edx
8010844c:	ff 75 10             	pushl  0x10(%ebp)
8010844f:	e8 0f 9c ff ff       	call   80102063 <readi>
80108454:	83 c4 10             	add    $0x10,%esp
80108457:	39 45 f0             	cmp    %eax,-0x10(%ebp)
8010845a:	74 07                	je     80108463 <loaduvm+0xb7>
      return -1;
8010845c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108461:	eb 18                	jmp    8010847b <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
80108463:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010846a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010846d:	3b 45 18             	cmp    0x18(%ebp),%eax
80108470:	0f 82 65 ff ff ff    	jb     801083db <loaduvm+0x2f>
  }
  return 0;
80108476:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010847b:	c9                   	leave  
8010847c:	c3                   	ret    

8010847d <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010847d:	f3 0f 1e fb          	endbr32 
80108481:	55                   	push   %ebp
80108482:	89 e5                	mov    %esp,%ebp
80108484:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108487:	8b 45 10             	mov    0x10(%ebp),%eax
8010848a:	85 c0                	test   %eax,%eax
8010848c:	79 0a                	jns    80108498 <allocuvm+0x1b>
    return 0;
8010848e:	b8 00 00 00 00       	mov    $0x0,%eax
80108493:	e9 ec 00 00 00       	jmp    80108584 <allocuvm+0x107>
  if(newsz < oldsz)
80108498:	8b 45 10             	mov    0x10(%ebp),%eax
8010849b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010849e:	73 08                	jae    801084a8 <allocuvm+0x2b>
    return oldsz;
801084a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801084a3:	e9 dc 00 00 00       	jmp    80108584 <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
801084a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801084ab:	05 ff 0f 00 00       	add    $0xfff,%eax
801084b0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801084b8:	e9 b8 00 00 00       	jmp    80108575 <allocuvm+0xf8>
    mem = kalloc();
801084bd:	e8 89 a9 ff ff       	call   80102e4b <kalloc>
801084c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801084c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801084c9:	75 2e                	jne    801084f9 <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
801084cb:	83 ec 0c             	sub    $0xc,%esp
801084ce:	68 35 9b 10 80       	push   $0x80109b35
801084d3:	e8 40 7f ff ff       	call   80100418 <cprintf>
801084d8:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801084db:	83 ec 04             	sub    $0x4,%esp
801084de:	ff 75 0c             	pushl  0xc(%ebp)
801084e1:	ff 75 10             	pushl  0x10(%ebp)
801084e4:	ff 75 08             	pushl  0x8(%ebp)
801084e7:	e8 9a 00 00 00       	call   80108586 <deallocuvm>
801084ec:	83 c4 10             	add    $0x10,%esp
      return 0;
801084ef:	b8 00 00 00 00       	mov    $0x0,%eax
801084f4:	e9 8b 00 00 00       	jmp    80108584 <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
801084f9:	83 ec 04             	sub    $0x4,%esp
801084fc:	68 00 10 00 00       	push   $0x1000
80108501:	6a 00                	push   $0x0
80108503:	ff 75 f0             	pushl  -0x10(%ebp)
80108506:	e8 6e d0 ff ff       	call   80105579 <memset>
8010850b:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
8010850e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108511:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108517:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010851a:	83 ec 0c             	sub    $0xc,%esp
8010851d:	6a 06                	push   $0x6
8010851f:	52                   	push   %edx
80108520:	68 00 10 00 00       	push   $0x1000
80108525:	50                   	push   %eax
80108526:	ff 75 08             	pushl  0x8(%ebp)
80108529:	e8 da fa ff ff       	call   80108008 <mappages>
8010852e:	83 c4 20             	add    $0x20,%esp
80108531:	85 c0                	test   %eax,%eax
80108533:	79 39                	jns    8010856e <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
80108535:	83 ec 0c             	sub    $0xc,%esp
80108538:	68 4d 9b 10 80       	push   $0x80109b4d
8010853d:	e8 d6 7e ff ff       	call   80100418 <cprintf>
80108542:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108545:	83 ec 04             	sub    $0x4,%esp
80108548:	ff 75 0c             	pushl  0xc(%ebp)
8010854b:	ff 75 10             	pushl  0x10(%ebp)
8010854e:	ff 75 08             	pushl  0x8(%ebp)
80108551:	e8 30 00 00 00       	call   80108586 <deallocuvm>
80108556:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80108559:	83 ec 0c             	sub    $0xc,%esp
8010855c:	ff 75 f0             	pushl  -0x10(%ebp)
8010855f:	e8 49 a8 ff ff       	call   80102dad <kfree>
80108564:	83 c4 10             	add    $0x10,%esp
      return 0;
80108567:	b8 00 00 00 00       	mov    $0x0,%eax
8010856c:	eb 16                	jmp    80108584 <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
8010856e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108575:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108578:	3b 45 10             	cmp    0x10(%ebp),%eax
8010857b:	0f 82 3c ff ff ff    	jb     801084bd <allocuvm+0x40>
    }
  }
  return newsz;
80108581:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108584:	c9                   	leave  
80108585:	c3                   	ret    

80108586 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108586:	f3 0f 1e fb          	endbr32 
8010858a:	55                   	push   %ebp
8010858b:	89 e5                	mov    %esp,%ebp
8010858d:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108590:	8b 45 10             	mov    0x10(%ebp),%eax
80108593:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108596:	72 08                	jb     801085a0 <deallocuvm+0x1a>
    return oldsz;
80108598:	8b 45 0c             	mov    0xc(%ebp),%eax
8010859b:	e9 ae 00 00 00       	jmp    8010864e <deallocuvm+0xc8>

  a = PGROUNDUP(newsz);
801085a0:	8b 45 10             	mov    0x10(%ebp),%eax
801085a3:	05 ff 0f 00 00       	add    $0xfff,%eax
801085a8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801085b0:	e9 8a 00 00 00       	jmp    8010863f <deallocuvm+0xb9>
    pte = walkpgdir(pgdir, (char*)a, 0);
801085b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b8:	83 ec 04             	sub    $0x4,%esp
801085bb:	6a 00                	push   $0x0
801085bd:	50                   	push   %eax
801085be:	ff 75 08             	pushl  0x8(%ebp)
801085c1:	e8 a8 f9 ff ff       	call   80107f6e <walkpgdir>
801085c6:	83 c4 10             	add    $0x10,%esp
801085c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801085cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801085d0:	75 16                	jne    801085e8 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801085d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d5:	c1 e8 16             	shr    $0x16,%eax
801085d8:	83 c0 01             	add    $0x1,%eax
801085db:	c1 e0 16             	shl    $0x16,%eax
801085de:	2d 00 10 00 00       	sub    $0x1000,%eax
801085e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801085e6:	eb 50                	jmp    80108638 <deallocuvm+0xb2>
    else if((*pte & (PTE_P | PTE_E)) != 0){
801085e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085eb:	8b 00                	mov    (%eax),%eax
801085ed:	25 01 04 00 00       	and    $0x401,%eax
801085f2:	85 c0                	test   %eax,%eax
801085f4:	74 42                	je     80108638 <deallocuvm+0xb2>
      pa = PTE_ADDR(*pte);
801085f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085f9:	8b 00                	mov    (%eax),%eax
801085fb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108600:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108603:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108607:	75 0d                	jne    80108616 <deallocuvm+0x90>
        panic("kfree");
80108609:	83 ec 0c             	sub    $0xc,%esp
8010860c:	68 69 9b 10 80       	push   $0x80109b69
80108611:	e8 f2 7f ff ff       	call   80100608 <panic>
      char *v = P2V(pa);
80108616:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108619:	05 00 00 00 80       	add    $0x80000000,%eax
8010861e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108621:	83 ec 0c             	sub    $0xc,%esp
80108624:	ff 75 e8             	pushl  -0x18(%ebp)
80108627:	e8 81 a7 ff ff       	call   80102dad <kfree>
8010862c:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
8010862f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108632:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80108638:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010863f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108642:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108645:	0f 82 6a ff ff ff    	jb     801085b5 <deallocuvm+0x2f>
    }
  }
  return newsz;
8010864b:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010864e:	c9                   	leave  
8010864f:	c3                   	ret    

80108650 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108650:	f3 0f 1e fb          	endbr32 
80108654:	55                   	push   %ebp
80108655:	89 e5                	mov    %esp,%ebp
80108657:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
8010865a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010865e:	75 0d                	jne    8010866d <freevm+0x1d>
    panic("freevm: no pgdir");
80108660:	83 ec 0c             	sub    $0xc,%esp
80108663:	68 6f 9b 10 80       	push   $0x80109b6f
80108668:	e8 9b 7f ff ff       	call   80100608 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010866d:	83 ec 04             	sub    $0x4,%esp
80108670:	6a 00                	push   $0x0
80108672:	68 00 00 00 80       	push   $0x80000000
80108677:	ff 75 08             	pushl  0x8(%ebp)
8010867a:	e8 07 ff ff ff       	call   80108586 <deallocuvm>
8010867f:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108682:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108689:	eb 4a                	jmp    801086d5 <freevm+0x85>
    if(pgdir[i] & (PTE_P | PTE_E)){
8010868b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010868e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108695:	8b 45 08             	mov    0x8(%ebp),%eax
80108698:	01 d0                	add    %edx,%eax
8010869a:	8b 00                	mov    (%eax),%eax
8010869c:	25 01 04 00 00       	and    $0x401,%eax
801086a1:	85 c0                	test   %eax,%eax
801086a3:	74 2c                	je     801086d1 <freevm+0x81>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801086a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801086af:	8b 45 08             	mov    0x8(%ebp),%eax
801086b2:	01 d0                	add    %edx,%eax
801086b4:	8b 00                	mov    (%eax),%eax
801086b6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086bb:	05 00 00 00 80       	add    $0x80000000,%eax
801086c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801086c3:	83 ec 0c             	sub    $0xc,%esp
801086c6:	ff 75 f0             	pushl  -0x10(%ebp)
801086c9:	e8 df a6 ff ff       	call   80102dad <kfree>
801086ce:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801086d1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801086d5:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801086dc:	76 ad                	jbe    8010868b <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
801086de:	83 ec 0c             	sub    $0xc,%esp
801086e1:	ff 75 08             	pushl  0x8(%ebp)
801086e4:	e8 c4 a6 ff ff       	call   80102dad <kfree>
801086e9:	83 c4 10             	add    $0x10,%esp
}
801086ec:	90                   	nop
801086ed:	c9                   	leave  
801086ee:	c3                   	ret    

801086ef <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801086ef:	f3 0f 1e fb          	endbr32 
801086f3:	55                   	push   %ebp
801086f4:	89 e5                	mov    %esp,%ebp
801086f6:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801086f9:	83 ec 04             	sub    $0x4,%esp
801086fc:	6a 00                	push   $0x0
801086fe:	ff 75 0c             	pushl  0xc(%ebp)
80108701:	ff 75 08             	pushl  0x8(%ebp)
80108704:	e8 65 f8 ff ff       	call   80107f6e <walkpgdir>
80108709:	83 c4 10             	add    $0x10,%esp
8010870c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010870f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108713:	75 0d                	jne    80108722 <clearpteu+0x33>
    panic("clearpteu");
80108715:	83 ec 0c             	sub    $0xc,%esp
80108718:	68 80 9b 10 80       	push   $0x80109b80
8010871d:	e8 e6 7e ff ff       	call   80100608 <panic>
  *pte &= ~PTE_U;
80108722:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108725:	8b 00                	mov    (%eax),%eax
80108727:	83 e0 fb             	and    $0xfffffffb,%eax
8010872a:	89 c2                	mov    %eax,%edx
8010872c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010872f:	89 10                	mov    %edx,(%eax)
}
80108731:	90                   	nop
80108732:	c9                   	leave  
80108733:	c3                   	ret    

80108734 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108734:	f3 0f 1e fb          	endbr32 
80108738:	55                   	push   %ebp
80108739:	89 e5                	mov    %esp,%ebp
8010873b:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010873e:	e8 7c f9 ff ff       	call   801080bf <setupkvm>
80108743:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108746:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010874a:	75 0a                	jne    80108756 <copyuvm+0x22>
    return 0;
8010874c:	b8 00 00 00 00       	mov    $0x0,%eax
80108751:	e9 fa 00 00 00       	jmp    80108850 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
80108756:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010875d:	e9 c9 00 00 00       	jmp    8010882b <copyuvm+0xf7>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108762:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108765:	83 ec 04             	sub    $0x4,%esp
80108768:	6a 00                	push   $0x0
8010876a:	50                   	push   %eax
8010876b:	ff 75 08             	pushl  0x8(%ebp)
8010876e:	e8 fb f7 ff ff       	call   80107f6e <walkpgdir>
80108773:	83 c4 10             	add    $0x10,%esp
80108776:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108779:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010877d:	75 0d                	jne    8010878c <copyuvm+0x58>
      panic("p4Debug: inside copyuvm, pte should exist");
8010877f:	83 ec 0c             	sub    $0xc,%esp
80108782:	68 8c 9b 10 80       	push   $0x80109b8c
80108787:	e8 7c 7e ff ff       	call   80100608 <panic>
    if(!(*pte & (PTE_P | PTE_E)))
8010878c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010878f:	8b 00                	mov    (%eax),%eax
80108791:	25 01 04 00 00       	and    $0x401,%eax
80108796:	85 c0                	test   %eax,%eax
80108798:	75 0d                	jne    801087a7 <copyuvm+0x73>
      panic("p4Debug: inside copyuvm, page not present");
8010879a:	83 ec 0c             	sub    $0xc,%esp
8010879d:	68 b8 9b 10 80       	push   $0x80109bb8
801087a2:	e8 61 7e ff ff       	call   80100608 <panic>
    pa = PTE_ADDR(*pte);
801087a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087aa:	8b 00                	mov    (%eax),%eax
801087ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087b1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801087b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087b7:	8b 00                	mov    (%eax),%eax
801087b9:	25 ff 0f 00 00       	and    $0xfff,%eax
801087be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801087c1:	e8 85 a6 ff ff       	call   80102e4b <kalloc>
801087c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
801087c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801087cd:	74 6d                	je     8010883c <copyuvm+0x108>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801087cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801087d2:	05 00 00 00 80       	add    $0x80000000,%eax
801087d7:	83 ec 04             	sub    $0x4,%esp
801087da:	68 00 10 00 00       	push   $0x1000
801087df:	50                   	push   %eax
801087e0:	ff 75 e0             	pushl  -0x20(%ebp)
801087e3:	e8 58 ce ff ff       	call   80105640 <memmove>
801087e8:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
801087eb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801087ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087f1:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801087f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087fa:	83 ec 0c             	sub    $0xc,%esp
801087fd:	52                   	push   %edx
801087fe:	51                   	push   %ecx
801087ff:	68 00 10 00 00       	push   $0x1000
80108804:	50                   	push   %eax
80108805:	ff 75 f0             	pushl  -0x10(%ebp)
80108808:	e8 fb f7 ff ff       	call   80108008 <mappages>
8010880d:	83 c4 20             	add    $0x20,%esp
80108810:	85 c0                	test   %eax,%eax
80108812:	79 10                	jns    80108824 <copyuvm+0xf0>
      kfree(mem);
80108814:	83 ec 0c             	sub    $0xc,%esp
80108817:	ff 75 e0             	pushl  -0x20(%ebp)
8010881a:	e8 8e a5 ff ff       	call   80102dad <kfree>
8010881f:	83 c4 10             	add    $0x10,%esp
      goto bad;
80108822:	eb 19                	jmp    8010883d <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80108824:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010882b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010882e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108831:	0f 82 2b ff ff ff    	jb     80108762 <copyuvm+0x2e>
    }
  }
  return d;
80108837:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010883a:	eb 14                	jmp    80108850 <copyuvm+0x11c>
      goto bad;
8010883c:	90                   	nop

bad:
  freevm(d);
8010883d:	83 ec 0c             	sub    $0xc,%esp
80108840:	ff 75 f0             	pushl  -0x10(%ebp)
80108843:	e8 08 fe ff ff       	call   80108650 <freevm>
80108848:	83 c4 10             	add    $0x10,%esp
  return 0;
8010884b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108850:	c9                   	leave  
80108851:	c3                   	ret    

80108852 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108852:	f3 0f 1e fb          	endbr32 
80108856:	55                   	push   %ebp
80108857:	89 e5                	mov    %esp,%ebp
80108859:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010885c:	83 ec 04             	sub    $0x4,%esp
8010885f:	6a 00                	push   $0x0
80108861:	ff 75 0c             	pushl  0xc(%ebp)
80108864:	ff 75 08             	pushl  0x8(%ebp)
80108867:	e8 02 f7 ff ff       	call   80107f6e <walkpgdir>
8010886c:	83 c4 10             	add    $0x10,%esp
8010886f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  // p4Debug: Check for page's present and encrypted flags.
  if(((*pte & PTE_P) | (*pte & PTE_E)) == 0)
80108872:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108875:	8b 00                	mov    (%eax),%eax
80108877:	25 01 04 00 00       	and    $0x401,%eax
8010887c:	85 c0                	test   %eax,%eax
8010887e:	75 07                	jne    80108887 <uva2ka+0x35>
    return 0;
80108880:	b8 00 00 00 00       	mov    $0x0,%eax
80108885:	eb 22                	jmp    801088a9 <uva2ka+0x57>
  if((*pte & PTE_U) == 0)
80108887:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010888a:	8b 00                	mov    (%eax),%eax
8010888c:	83 e0 04             	and    $0x4,%eax
8010888f:	85 c0                	test   %eax,%eax
80108891:	75 07                	jne    8010889a <uva2ka+0x48>
    return 0;
80108893:	b8 00 00 00 00       	mov    $0x0,%eax
80108898:	eb 0f                	jmp    801088a9 <uva2ka+0x57>
  return (char*)P2V(PTE_ADDR(*pte));
8010889a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010889d:	8b 00                	mov    (%eax),%eax
8010889f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088a4:	05 00 00 00 80       	add    $0x80000000,%eax
}
801088a9:	c9                   	leave  
801088aa:	c3                   	ret    

801088ab <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801088ab:	f3 0f 1e fb          	endbr32 
801088af:	55                   	push   %ebp
801088b0:	89 e5                	mov    %esp,%ebp
801088b2:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801088b5:	8b 45 10             	mov    0x10(%ebp),%eax
801088b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801088bb:	eb 7f                	jmp    8010893c <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
801088bd:	8b 45 0c             	mov    0xc(%ebp),%eax
801088c0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801088c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088cb:	83 ec 08             	sub    $0x8,%esp
801088ce:	50                   	push   %eax
801088cf:	ff 75 08             	pushl  0x8(%ebp)
801088d2:	e8 7b ff ff ff       	call   80108852 <uva2ka>
801088d7:	83 c4 10             	add    $0x10,%esp
801088da:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801088dd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801088e1:	75 07                	jne    801088ea <copyout+0x3f>
    {
      //p4Debug : Cannot find page in kernel space.
      return -1;
801088e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801088e8:	eb 61                	jmp    8010894b <copyout+0xa0>
    }
    n = PGSIZE - (va - va0);
801088ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088ed:	2b 45 0c             	sub    0xc(%ebp),%eax
801088f0:	05 00 10 00 00       	add    $0x1000,%eax
801088f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801088f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088fb:	3b 45 14             	cmp    0x14(%ebp),%eax
801088fe:	76 06                	jbe    80108906 <copyout+0x5b>
      n = len;
80108900:	8b 45 14             	mov    0x14(%ebp),%eax
80108903:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108906:	8b 45 0c             	mov    0xc(%ebp),%eax
80108909:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010890c:	89 c2                	mov    %eax,%edx
8010890e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108911:	01 d0                	add    %edx,%eax
80108913:	83 ec 04             	sub    $0x4,%esp
80108916:	ff 75 f0             	pushl  -0x10(%ebp)
80108919:	ff 75 f4             	pushl  -0xc(%ebp)
8010891c:	50                   	push   %eax
8010891d:	e8 1e cd ff ff       	call   80105640 <memmove>
80108922:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108925:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108928:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010892b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010892e:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108931:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108934:	05 00 10 00 00       	add    $0x1000,%eax
80108939:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
8010893c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108940:	0f 85 77 ff ff ff    	jne    801088bd <copyout+0x12>
  }
  return 0;
80108946:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010894b:	c9                   	leave  
8010894c:	c3                   	ret    

8010894d <translate_and_set>:

//This function is just like uva2ka but sets the PTE_E bit and clears PTE_P
char* translate_and_set(pde_t *pgdir, char *uva) {
8010894d:	f3 0f 1e fb          	endbr32 
80108951:	55                   	push   %ebp
80108952:	89 e5                	mov    %esp,%ebp
80108954:	83 ec 18             	sub    $0x18,%esp
  cprintf("p4Debug: setting PTE_E for %p, VPN %d\n", uva, PPN(uva));
80108957:	8b 45 0c             	mov    0xc(%ebp),%eax
8010895a:	c1 e8 0c             	shr    $0xc,%eax
8010895d:	83 ec 04             	sub    $0x4,%esp
80108960:	50                   	push   %eax
80108961:	ff 75 0c             	pushl  0xc(%ebp)
80108964:	68 e4 9b 10 80       	push   $0x80109be4
80108969:	e8 aa 7a ff ff       	call   80100418 <cprintf>
8010896e:	83 c4 10             	add    $0x10,%esp
  pte_t *pte;
  pte = walkpgdir(pgdir, uva, 0);
80108971:	83 ec 04             	sub    $0x4,%esp
80108974:	6a 00                	push   $0x0
80108976:	ff 75 0c             	pushl  0xc(%ebp)
80108979:	ff 75 08             	pushl  0x8(%ebp)
8010897c:	e8 ed f5 ff ff       	call   80107f6e <walkpgdir>
80108981:	83 c4 10             	add    $0x10,%esp
80108984:	89 45 f4             	mov    %eax,-0xc(%ebp)

  //p4Debug: If page is not present AND it is not encrypted.
  if((*pte & PTE_P) == 0 && (*pte & PTE_E) == 0)
80108987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010898a:	8b 00                	mov    (%eax),%eax
8010898c:	83 e0 01             	and    $0x1,%eax
8010898f:	85 c0                	test   %eax,%eax
80108991:	75 18                	jne    801089ab <translate_and_set+0x5e>
80108993:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108996:	8b 00                	mov    (%eax),%eax
80108998:	25 00 04 00 00       	and    $0x400,%eax
8010899d:	85 c0                	test   %eax,%eax
8010899f:	75 0a                	jne    801089ab <translate_and_set+0x5e>
    return 0;
801089a1:	b8 00 00 00 00       	mov    $0x0,%eax
801089a6:	e9 84 00 00 00       	jmp    80108a2f <translate_and_set+0xe2>
  //p4Debug: If page is already encrypted, i.e. PTE_E is set, return NULL as error;
  if((*pte & PTE_E)) {
801089ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ae:	8b 00                	mov    (%eax),%eax
801089b0:	25 00 04 00 00       	and    $0x400,%eax
801089b5:	85 c0                	test   %eax,%eax
801089b7:	74 07                	je     801089c0 <translate_and_set+0x73>
    return 0;
801089b9:	b8 00 00 00 00       	mov    $0x0,%eax
801089be:	eb 6f                	jmp    80108a2f <translate_and_set+0xe2>
  }
  // p4Debug: Check if users are allowed to use this page
  if((*pte & PTE_U) == 0)
801089c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c3:	8b 00                	mov    (%eax),%eax
801089c5:	83 e0 04             	and    $0x4,%eax
801089c8:	85 c0                	test   %eax,%eax
801089ca:	75 07                	jne    801089d3 <translate_and_set+0x86>
    return 0;
801089cc:	b8 00 00 00 00       	mov    $0x0,%eax
801089d1:	eb 5c                	jmp    80108a2f <translate_and_set+0xe2>
  //p4Debug: Set Page as encrypted and not present so that we can trap(see trap.c) to decrypt page
  cprintf("p4Debug: PTE was %x and its pointer %p\n", *pte, pte);
801089d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089d6:	8b 00                	mov    (%eax),%eax
801089d8:	83 ec 04             	sub    $0x4,%esp
801089db:	ff 75 f4             	pushl  -0xc(%ebp)
801089de:	50                   	push   %eax
801089df:	68 0c 9c 10 80       	push   $0x80109c0c
801089e4:	e8 2f 7a ff ff       	call   80100418 <cprintf>
801089e9:	83 c4 10             	add    $0x10,%esp
  *pte = *pte | PTE_E;
801089ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ef:	8b 00                	mov    (%eax),%eax
801089f1:	80 cc 04             	or     $0x4,%ah
801089f4:	89 c2                	mov    %eax,%edx
801089f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089f9:	89 10                	mov    %edx,(%eax)
  *pte = *pte & ~PTE_P;
801089fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089fe:	8b 00                	mov    (%eax),%eax
80108a00:	83 e0 fe             	and    $0xfffffffe,%eax
80108a03:	89 c2                	mov    %eax,%edx
80108a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a08:	89 10                	mov    %edx,(%eax)
  cprintf("p4Debug: PTE is now %x\n", *pte);
80108a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a0d:	8b 00                	mov    (%eax),%eax
80108a0f:	83 ec 08             	sub    $0x8,%esp
80108a12:	50                   	push   %eax
80108a13:	68 34 9c 10 80       	push   $0x80109c34
80108a18:	e8 fb 79 ff ff       	call   80100418 <cprintf>
80108a1d:	83 c4 10             	add    $0x10,%esp
  return (char*)P2V(PTE_ADDR(*pte));
80108a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a23:	8b 00                	mov    (%eax),%eax
80108a25:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a2a:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108a2f:	c9                   	leave  
80108a30:	c3                   	ret    

80108a31 <not_in_queue>:

int not_in_queue(char *VA){
80108a31:	f3 0f 1e fb          	endbr32 
80108a35:	55                   	push   %ebp
80108a36:	89 e5                	mov    %esp,%ebp
80108a38:	83 ec 18             	sub    $0x18,%esp
  
  struct proc *curproc = myproc();
80108a3b:	e8 cf ba ff ff       	call   8010450f <myproc>
80108a40:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for (int k=curproc->hand;k<curproc->hand + CLOCKSIZE; k++ ){
80108a43:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a46:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108a4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108a4f:	eb 2f                	jmp    80108a80 <not_in_queue+0x4f>
  cprintf("IN NOT IN QUEUE %x\n", (uint)curproc->clock[k%CLOCKSIZE]);
80108a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a54:	99                   	cltd   
80108a55:	c1 ea 1d             	shr    $0x1d,%edx
80108a58:	01 d0                	add    %edx,%eax
80108a5a:	83 e0 07             	and    $0x7,%eax
80108a5d:	29 d0                	sub    %edx,%eax
80108a5f:	89 c2                	mov    %eax,%edx
80108a61:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a64:	83 c2 1c             	add    $0x1c,%edx
80108a67:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80108a6b:	83 ec 08             	sub    $0x8,%esp
80108a6e:	50                   	push   %eax
80108a6f:	68 4c 9c 10 80       	push   $0x80109c4c
80108a74:	e8 9f 79 ff ff       	call   80100418 <cprintf>
80108a79:	83 c4 10             	add    $0x10,%esp
  for (int k=curproc->hand;k<curproc->hand + CLOCKSIZE; k++ ){
80108a7c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108a80:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a83:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108a89:	83 c0 07             	add    $0x7,%eax
80108a8c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80108a8f:	7e c0                	jle    80108a51 <not_in_queue+0x20>
  }
  for(int i=0; i < curproc->clock_len;i++){
80108a91:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108a98:	eb 1d                	jmp    80108ab7 <not_in_queue+0x86>
    if(VA==curproc->clock[i]){
80108a9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a9d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108aa0:	83 c2 1c             	add    $0x1c,%edx
80108aa3:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80108aa7:	39 45 08             	cmp    %eax,0x8(%ebp)
80108aaa:	75 07                	jne    80108ab3 <not_in_queue+0x82>
      return 0;
80108aac:	b8 00 00 00 00       	mov    $0x0,%eax
80108ab1:	eb 17                	jmp    80108aca <not_in_queue+0x99>
  for(int i=0; i < curproc->clock_len;i++){
80108ab3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108ab7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108aba:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80108ac0:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80108ac3:	7c d5                	jl     80108a9a <not_in_queue+0x69>
    }
  }
  return 1;
80108ac5:	b8 01 00 00 00       	mov    $0x1,%eax
}
80108aca:	c9                   	leave  
80108acb:	c3                   	ret    

80108acc <add_to_clock>:

void add_to_clock(char *VA){
80108acc:	f3 0f 1e fb          	endbr32 
80108ad0:	55                   	push   %ebp
80108ad1:	89 e5                	mov    %esp,%ebp
80108ad3:	83 ec 28             	sub    $0x28,%esp
  if(!not_in_queue(VA))
80108ad6:	83 ec 0c             	sub    $0xc,%esp
80108ad9:	ff 75 08             	pushl  0x8(%ebp)
80108adc:	e8 50 ff ff ff       	call   80108a31 <not_in_queue>
80108ae1:	83 c4 10             	add    $0x10,%esp
80108ae4:	85 c0                	test   %eax,%eax
80108ae6:	0f 84 98 01 00 00    	je     80108c84 <add_to_clock+0x1b8>
    return;
  struct proc *curproc = myproc();
80108aec:	e8 1e ba ff ff       	call   8010450f <myproc>
80108af1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  cprintf("~~~~~~~~~~~~~~~ in add to clock ~~~~~~~~~~\n");
80108af4:	83 ec 0c             	sub    $0xc,%esp
80108af7:	68 60 9c 10 80       	push   $0x80109c60
80108afc:	e8 17 79 ff ff       	call   80100418 <cprintf>
80108b01:	83 c4 10             	add    $0x10,%esp
  
  if (curproc->clock_len < CLOCKSIZE){
80108b04:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b07:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80108b0d:	83 f8 07             	cmp    $0x7,%eax
80108b10:	7f 30                	jg     80108b42 <add_to_clock+0x76>
    curproc->clock[curproc->clock_len] = VA;
80108b12:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b15:	8b 90 a0 00 00 00    	mov    0xa0(%eax),%edx
80108b1b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b1e:	8d 4a 1c             	lea    0x1c(%edx),%ecx
80108b21:	8b 55 08             	mov    0x8(%ebp),%edx
80108b24:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    curproc -> clock_len = curproc->clock_len + 1;
80108b28:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b2b:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80108b31:	8d 50 01             	lea    0x1(%eax),%edx
80108b34:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b37:	89 90 a0 00 00 00    	mov    %edx,0xa0(%eax)
80108b3d:	e9 f2 00 00 00       	jmp    80108c34 <add_to_clock+0x168>
    
  } else {
    
    char* cur_va = curproc->clock[curproc->hand];
80108b42:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b45:	8b 90 9c 00 00 00    	mov    0x9c(%eax),%edx
80108b4b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b4e:	83 c2 1c             	add    $0x1c,%edx
80108b51:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80108b55:	89 45 f4             	mov    %eax,-0xc(%ebp)
    pde_t* mypd = curproc->pgdir;
80108b58:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b5b:	8b 40 04             	mov    0x4(%eax),%eax
80108b5e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    int check = 0;
80108b61:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    while (!check){
80108b68:	e9 bd 00 00 00       	jmp    80108c2a <add_to_clock+0x15e>
      pte_t *pte = walkpgdir(mypd, cur_va, 0);
80108b6d:	83 ec 04             	sub    $0x4,%esp
80108b70:	6a 00                	push   $0x0
80108b72:	ff 75 f4             	pushl  -0xc(%ebp)
80108b75:	ff 75 e4             	pushl  -0x1c(%ebp)
80108b78:	e8 f1 f3 ff ff       	call   80107f6e <walkpgdir>
80108b7d:	83 c4 10             	add    $0x10,%esp
80108b80:	89 45 e0             	mov    %eax,-0x20(%ebp)
      if(!(*pte & PTE_A)){
80108b83:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b86:	8b 00                	mov    (%eax),%eax
80108b88:	83 e0 20             	and    $0x20,%eax
80108b8b:	85 c0                	test   %eax,%eax
80108b8d:	75 54                	jne    80108be3 <add_to_clock+0x117>
        //evict
        cprintf("~~~~~~~~~~~~~~~ WE FINNA FAIL ~~~~~~~~~~");
80108b8f:	83 ec 0c             	sub    $0xc,%esp
80108b92:	68 8c 9c 10 80       	push   $0x80109c8c
80108b97:	e8 7c 78 ff ff       	call   80100418 <cprintf>
80108b9c:	83 c4 10             	add    $0x10,%esp
        curproc -> clock[curproc->hand] = VA;
80108b9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ba2:	8b 90 9c 00 00 00    	mov    0x9c(%eax),%edx
80108ba8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108bab:	8d 4a 1c             	lea    0x1c(%edx),%ecx
80108bae:	8b 55 08             	mov    0x8(%ebp),%edx
80108bb1:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
        mencrypt(cur_va,1);
80108bb5:	83 ec 08             	sub    $0x8,%esp
80108bb8:	6a 01                	push   $0x1
80108bba:	ff 75 f4             	pushl  -0xc(%ebp)
80108bbd:	e8 aa 02 00 00       	call   80108e6c <mencrypt>
80108bc2:	83 c4 10             	add    $0x10,%esp
        curproc->hand++;
80108bc5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108bc8:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108bce:	8d 50 01             	lea    0x1(%eax),%edx
80108bd1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108bd4:	89 90 9c 00 00 00    	mov    %edx,0x9c(%eax)
        check = 1;
80108bda:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
80108be1:	eb 47                	jmp    80108c2a <add_to_clock+0x15e>
      } else {
        *pte = *pte & ~PTE_A;
80108be3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108be6:	8b 00                	mov    (%eax),%eax
80108be8:	83 e0 df             	and    $0xffffffdf,%eax
80108beb:	89 c2                	mov    %eax,%edx
80108bed:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bf0:	89 10                	mov    %edx,(%eax)
        curproc->hand++;
80108bf2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108bf5:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108bfb:	8d 50 01             	lea    0x1(%eax),%edx
80108bfe:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c01:	89 90 9c 00 00 00    	mov    %edx,0x9c(%eax)
        cur_va = curproc->clock[(curproc->hand)%CLOCKSIZE];
80108c07:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c0a:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108c10:	99                   	cltd   
80108c11:	c1 ea 1d             	shr    $0x1d,%edx
80108c14:	01 d0                	add    %edx,%eax
80108c16:	83 e0 07             	and    $0x7,%eax
80108c19:	29 d0                	sub    %edx,%eax
80108c1b:	89 c2                	mov    %eax,%edx
80108c1d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c20:	83 c2 1c             	add    $0x1c,%edx
80108c23:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80108c27:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (!check){
80108c2a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108c2e:	0f 84 39 ff ff ff    	je     80108b6d <add_to_clock+0xa1>
      }
    }
  }
  for (int k=curproc->hand; k<curproc->hand + CLOCKSIZE; k++){
80108c34:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c37:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108c3d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108c40:	eb 2f                	jmp    80108c71 <add_to_clock+0x1a5>
    cprintf("=============QUEUE RN IS : %x\n", (uint)curproc->clock[k%CLOCKSIZE]);
80108c42:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c45:	99                   	cltd   
80108c46:	c1 ea 1d             	shr    $0x1d,%edx
80108c49:	01 d0                	add    %edx,%eax
80108c4b:	83 e0 07             	and    $0x7,%eax
80108c4e:	29 d0                	sub    %edx,%eax
80108c50:	89 c2                	mov    %eax,%edx
80108c52:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c55:	83 c2 1c             	add    $0x1c,%edx
80108c58:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80108c5c:	83 ec 08             	sub    $0x8,%esp
80108c5f:	50                   	push   %eax
80108c60:	68 b8 9c 10 80       	push   $0x80109cb8
80108c65:	e8 ae 77 ff ff       	call   80100418 <cprintf>
80108c6a:	83 c4 10             	add    $0x10,%esp
  for (int k=curproc->hand; k<curproc->hand + CLOCKSIZE; k++){
80108c6d:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108c71:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c74:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108c7a:	83 c0 07             	add    $0x7,%eax
80108c7d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108c80:	7e c0                	jle    80108c42 <add_to_clock+0x176>
80108c82:	eb 01                	jmp    80108c85 <add_to_clock+0x1b9>
    return;
80108c84:	90                   	nop
  }
}
80108c85:	c9                   	leave  
80108c86:	c3                   	ret    

80108c87 <mdecrypt>:
int mdecrypt(char *virtual_addr) {
80108c87:	f3 0f 1e fb          	endbr32 
80108c8b:	55                   	push   %ebp
80108c8c:	89 e5                	mov    %esp,%ebp
80108c8e:	83 ec 28             	sub    $0x28,%esp
  cprintf("p4Debug:  mdecrypt VPN %d, %p, pid %d\n", PPN(virtual_addr), virtual_addr, myproc()->pid);
80108c91:	e8 79 b8 ff ff       	call   8010450f <myproc>
80108c96:	8b 40 10             	mov    0x10(%eax),%eax
80108c99:	8b 55 08             	mov    0x8(%ebp),%edx
80108c9c:	c1 ea 0c             	shr    $0xc,%edx
80108c9f:	50                   	push   %eax
80108ca0:	ff 75 08             	pushl  0x8(%ebp)
80108ca3:	52                   	push   %edx
80108ca4:	68 d8 9c 10 80       	push   $0x80109cd8
80108ca9:	e8 6a 77 ff ff       	call   80100418 <cprintf>
80108cae:	83 c4 10             	add    $0x10,%esp
  //p4Debug: virtual_addr is a virtual address in this PID's userspace.
  struct proc * p = myproc();
80108cb1:	e8 59 b8 ff ff       	call   8010450f <myproc>
80108cb6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  pde_t* mypd = p->pgdir;
80108cb9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108cbc:	8b 40 04             	mov    0x4(%eax),%eax
80108cbf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  //set the present bit to true and encrypt bit to false
  pte_t * pte = walkpgdir(mypd, virtual_addr, 0);
80108cc2:	83 ec 04             	sub    $0x4,%esp
80108cc5:	6a 00                	push   $0x0
80108cc7:	ff 75 08             	pushl  0x8(%ebp)
80108cca:	ff 75 e4             	pushl  -0x1c(%ebp)
80108ccd:	e8 9c f2 ff ff       	call   80107f6e <walkpgdir>
80108cd2:	83 c4 10             	add    $0x10,%esp
80108cd5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if (!pte || *pte == 0) {
80108cd8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108cdc:	74 09                	je     80108ce7 <mdecrypt+0x60>
80108cde:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ce1:	8b 00                	mov    (%eax),%eax
80108ce3:	85 c0                	test   %eax,%eax
80108ce5:	75 1a                	jne    80108d01 <mdecrypt+0x7a>
    cprintf("p4Debug: walkpgdir failed\n");
80108ce7:	83 ec 0c             	sub    $0xc,%esp
80108cea:	68 ff 9c 10 80       	push   $0x80109cff
80108cef:	e8 24 77 ff ff       	call   80100418 <cprintf>
80108cf4:	83 c4 10             	add    $0x10,%esp
    return -1;
80108cf7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108cfc:	e9 69 01 00 00       	jmp    80108e6a <mdecrypt+0x1e3>
  }
  cprintf("p4Debug: pte was %x\n", *pte);
80108d01:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d04:	8b 00                	mov    (%eax),%eax
80108d06:	83 ec 08             	sub    $0x8,%esp
80108d09:	50                   	push   %eax
80108d0a:	68 1a 9d 10 80       	push   $0x80109d1a
80108d0f:	e8 04 77 ff ff       	call   80100418 <cprintf>
80108d14:	83 c4 10             	add    $0x10,%esp
  *pte = *pte & ~PTE_E;
80108d17:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d1a:	8b 00                	mov    (%eax),%eax
80108d1c:	80 e4 fb             	and    $0xfb,%ah
80108d1f:	89 c2                	mov    %eax,%edx
80108d21:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d24:	89 10                	mov    %edx,(%eax)
  *pte = *pte | PTE_P;
80108d26:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d29:	8b 00                	mov    (%eax),%eax
80108d2b:	83 c8 01             	or     $0x1,%eax
80108d2e:	89 c2                	mov    %eax,%edx
80108d30:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d33:	89 10                	mov    %edx,(%eax)
  cprintf("p4Debug: pte is %x\n", *pte);
80108d35:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d38:	8b 00                	mov    (%eax),%eax
80108d3a:	83 ec 08             	sub    $0x8,%esp
80108d3d:	50                   	push   %eax
80108d3e:	68 2f 9d 10 80       	push   $0x80109d2f
80108d43:	e8 d0 76 ff ff       	call   80100418 <cprintf>
80108d48:	83 c4 10             	add    $0x10,%esp
  
  add_to_clock((char*)P2V(PTE_ADDR(*pte)));
80108d4b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d4e:	8b 00                	mov    (%eax),%eax
80108d50:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108d55:	05 00 00 00 80       	add    $0x80000000,%eax
80108d5a:	83 ec 0c             	sub    $0xc,%esp
80108d5d:	50                   	push   %eax
80108d5e:	e8 69 fd ff ff       	call   80108acc <add_to_clock>
80108d63:	83 c4 10             	add    $0x10,%esp


  char * original = uva2ka(mypd, virtual_addr) + OFFSET(virtual_addr);
80108d66:	83 ec 08             	sub    $0x8,%esp
80108d69:	ff 75 08             	pushl  0x8(%ebp)
80108d6c:	ff 75 e4             	pushl  -0x1c(%ebp)
80108d6f:	e8 de fa ff ff       	call   80108852 <uva2ka>
80108d74:	83 c4 10             	add    $0x10,%esp
80108d77:	8b 55 08             	mov    0x8(%ebp),%edx
80108d7a:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
80108d80:	01 d0                	add    %edx,%eax
80108d82:	89 45 dc             	mov    %eax,-0x24(%ebp)
  cprintf("p4Debug: Original in decrypt was %p\n", original);
80108d85:	83 ec 08             	sub    $0x8,%esp
80108d88:	ff 75 dc             	pushl  -0x24(%ebp)
80108d8b:	68 44 9d 10 80       	push   $0x80109d44
80108d90:	e8 83 76 ff ff       	call   80100418 <cprintf>
80108d95:	83 c4 10             	add    $0x10,%esp
  virtual_addr = (char *)PGROUNDDOWN((uint)virtual_addr);
80108d98:	8b 45 08             	mov    0x8(%ebp),%eax
80108d9b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108da0:	89 45 08             	mov    %eax,0x8(%ebp)
  cprintf("p4Debug: mdecrypt: rounded down va is %p\n", virtual_addr);
80108da3:	83 ec 08             	sub    $0x8,%esp
80108da6:	ff 75 08             	pushl  0x8(%ebp)
80108da9:	68 6c 9d 10 80       	push   $0x80109d6c
80108dae:	e8 65 76 ff ff       	call   80100418 <cprintf>
80108db3:	83 c4 10             	add    $0x10,%esp

  char * kvp = uva2ka(mypd, virtual_addr);
80108db6:	83 ec 08             	sub    $0x8,%esp
80108db9:	ff 75 08             	pushl  0x8(%ebp)
80108dbc:	ff 75 e4             	pushl  -0x1c(%ebp)
80108dbf:	e8 8e fa ff ff       	call   80108852 <uva2ka>
80108dc4:	83 c4 10             	add    $0x10,%esp
80108dc7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  if (!kvp || *kvp == 0) {
80108dca:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80108dce:	74 0a                	je     80108dda <mdecrypt+0x153>
80108dd0:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108dd3:	0f b6 00             	movzbl (%eax),%eax
80108dd6:	84 c0                	test   %al,%al
80108dd8:	75 0a                	jne    80108de4 <mdecrypt+0x15d>
    return -1;
80108dda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108ddf:	e9 86 00 00 00       	jmp    80108e6a <mdecrypt+0x1e3>
  }
  char * slider = virtual_addr;
80108de4:	8b 45 08             	mov    0x8(%ebp),%eax
80108de7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int offset = 0; offset < PGSIZE; offset++) {
80108dea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108df1:	eb 17                	jmp    80108e0a <mdecrypt+0x183>
    *slider = *slider ^ 0xFF;
80108df3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108df6:	0f b6 00             	movzbl (%eax),%eax
80108df9:	f7 d0                	not    %eax
80108dfb:	89 c2                	mov    %eax,%edx
80108dfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e00:	88 10                	mov    %dl,(%eax)
    slider++;
80108e02:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  for (int offset = 0; offset < PGSIZE; offset++) {
80108e06:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108e0a:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80108e11:	7e e0                	jle    80108df3 <mdecrypt+0x16c>
  }
  for (int k=p->hand;k<p->hand + CLOCKSIZE; k++ ){
80108e13:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e16:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108e1c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108e1f:	eb 33                	jmp    80108e54 <mdecrypt+0x1cd>
  cprintf("IN DECRYPT: %x  %x\n", (uint)p->clock[k%CLOCKSIZE], (uint) virtual_addr);
80108e21:	8b 4d 08             	mov    0x8(%ebp),%ecx
80108e24:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e27:	99                   	cltd   
80108e28:	c1 ea 1d             	shr    $0x1d,%edx
80108e2b:	01 d0                	add    %edx,%eax
80108e2d:	83 e0 07             	and    $0x7,%eax
80108e30:	29 d0                	sub    %edx,%eax
80108e32:	89 c2                	mov    %eax,%edx
80108e34:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e37:	83 c2 1c             	add    $0x1c,%edx
80108e3a:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80108e3e:	83 ec 04             	sub    $0x4,%esp
80108e41:	51                   	push   %ecx
80108e42:	50                   	push   %eax
80108e43:	68 96 9d 10 80       	push   $0x80109d96
80108e48:	e8 cb 75 ff ff       	call   80100418 <cprintf>
80108e4d:	83 c4 10             	add    $0x10,%esp
  for (int k=p->hand;k<p->hand + CLOCKSIZE; k++ ){
80108e50:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108e54:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e57:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108e5d:	83 c0 07             	add    $0x7,%eax
80108e60:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108e63:	7e bc                	jle    80108e21 <mdecrypt+0x19a>
  }
  return 0;
80108e65:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108e6a:	c9                   	leave  
80108e6b:	c3                   	ret    

80108e6c <mencrypt>:

int mencrypt(char *virtual_addr, int len) {
80108e6c:	f3 0f 1e fb          	endbr32 
80108e70:	55                   	push   %ebp
80108e71:	89 e5                	mov    %esp,%ebp
80108e73:	83 ec 38             	sub    $0x38,%esp

  if(len==0)
80108e76:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80108e7a:	75 0a                	jne    80108e86 <mencrypt+0x1a>
    return 0;
80108e7c:	b8 00 00 00 00       	mov    $0x0,%eax
80108e81:	e9 d9 01 00 00       	jmp    8010905f <mencrypt+0x1f3>

  cprintf("p4Debug: mencrypt: %p %d\n", virtual_addr, len);
80108e86:	83 ec 04             	sub    $0x4,%esp
80108e89:	ff 75 0c             	pushl  0xc(%ebp)
80108e8c:	ff 75 08             	pushl  0x8(%ebp)
80108e8f:	68 aa 9d 10 80       	push   $0x80109daa
80108e94:	e8 7f 75 ff ff       	call   80100418 <cprintf>
80108e99:	83 c4 10             	add    $0x10,%esp
  //the given pointer is a virtual address in this pid's userspace
  struct proc * p = myproc();
80108e9c:	e8 6e b6 ff ff       	call   8010450f <myproc>
80108ea1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  pde_t* mypd = p->pgdir;
80108ea4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108ea7:	8b 40 04             	mov    0x4(%eax),%eax
80108eaa:	89 45 e0             	mov    %eax,-0x20(%ebp)

  virtual_addr = (char *)PGROUNDDOWN((uint)virtual_addr);
80108ead:	8b 45 08             	mov    0x8(%ebp),%eax
80108eb0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108eb5:	89 45 08             	mov    %eax,0x8(%ebp)

  
  //error checking first. all or nothing.
  char * slider = virtual_addr;
80108eb8:	8b 45 08             	mov    0x8(%ebp),%eax
80108ebb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
80108ebe:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108ec5:	eb 55                	jmp    80108f1c <mencrypt+0xb0>
    //check page table for each translation first
    char * kvp = uva2ka(mypd, slider);
80108ec7:	83 ec 08             	sub    $0x8,%esp
80108eca:	ff 75 f4             	pushl  -0xc(%ebp)
80108ecd:	ff 75 e0             	pushl  -0x20(%ebp)
80108ed0:	e8 7d f9 ff ff       	call   80108852 <uva2ka>
80108ed5:	83 c4 10             	add    $0x10,%esp
80108ed8:	89 45 d0             	mov    %eax,-0x30(%ebp)
    cprintf("p4Debug: slider %p, kvp for err check is %p\n",slider, kvp);
80108edb:	83 ec 04             	sub    $0x4,%esp
80108ede:	ff 75 d0             	pushl  -0x30(%ebp)
80108ee1:	ff 75 f4             	pushl  -0xc(%ebp)
80108ee4:	68 c4 9d 10 80       	push   $0x80109dc4
80108ee9:	e8 2a 75 ff ff       	call   80100418 <cprintf>
80108eee:	83 c4 10             	add    $0x10,%esp
    if (!kvp) {
80108ef1:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
80108ef5:	75 1a                	jne    80108f11 <mencrypt+0xa5>
      cprintf("p4Debug: mencrypt: kvp = NULL\n");
80108ef7:	83 ec 0c             	sub    $0xc,%esp
80108efa:	68 f4 9d 10 80       	push   $0x80109df4
80108eff:	e8 14 75 ff ff       	call   80100418 <cprintf>
80108f04:	83 c4 10             	add    $0x10,%esp
      return -1;
80108f07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108f0c:	e9 4e 01 00 00       	jmp    8010905f <mencrypt+0x1f3>
    }
    slider = slider + PGSIZE;
80108f11:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
80108f18:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108f1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f1f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108f22:	7c a3                	jl     80108ec7 <mencrypt+0x5b>
  }

  //encrypt stage. Have to do this before setting flag 
  //or else we'll page fault
  slider = virtual_addr;
80108f24:	8b 45 08             	mov    0x8(%ebp),%eax
80108f27:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int i = 0; i < len; i++) {
80108f2a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108f31:	e9 07 01 00 00       	jmp    8010903d <mencrypt+0x1d1>
    cprintf("p4Debug: mencryptr: VPN %d, %p\n", PPN(slider), slider);
80108f36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f39:	c1 e8 0c             	shr    $0xc,%eax
80108f3c:	83 ec 04             	sub    $0x4,%esp
80108f3f:	ff 75 f4             	pushl  -0xc(%ebp)
80108f42:	50                   	push   %eax
80108f43:	68 14 9e 10 80       	push   $0x80109e14
80108f48:	e8 cb 74 ff ff       	call   80100418 <cprintf>
80108f4d:	83 c4 10             	add    $0x10,%esp
    //kvp = kernel virtual pointer
    //virtual address in kernel space that maps to the given pointer
    char * kvp = uva2ka(mypd, slider);
80108f50:	83 ec 08             	sub    $0x8,%esp
80108f53:	ff 75 f4             	pushl  -0xc(%ebp)
80108f56:	ff 75 e0             	pushl  -0x20(%ebp)
80108f59:	e8 f4 f8 ff ff       	call   80108852 <uva2ka>
80108f5e:	83 c4 10             	add    $0x10,%esp
80108f61:	89 45 dc             	mov    %eax,-0x24(%ebp)
    cprintf("p4Debug: kvp for encrypt stage is %p\n", kvp);
80108f64:	83 ec 08             	sub    $0x8,%esp
80108f67:	ff 75 dc             	pushl  -0x24(%ebp)
80108f6a:	68 34 9e 10 80       	push   $0x80109e34
80108f6f:	e8 a4 74 ff ff       	call   80100418 <cprintf>
80108f74:	83 c4 10             	add    $0x10,%esp
    pte_t * mypte = walkpgdir(mypd, slider, 0);
80108f77:	83 ec 04             	sub    $0x4,%esp
80108f7a:	6a 00                	push   $0x0
80108f7c:	ff 75 f4             	pushl  -0xc(%ebp)
80108f7f:	ff 75 e0             	pushl  -0x20(%ebp)
80108f82:	e8 e7 ef ff ff       	call   80107f6e <walkpgdir>
80108f87:	83 c4 10             	add    $0x10,%esp
80108f8a:	89 45 d8             	mov    %eax,-0x28(%ebp)
    cprintf("p4Debug: pte is %x\n", *mypte);
80108f8d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108f90:	8b 00                	mov    (%eax),%eax
80108f92:	83 ec 08             	sub    $0x8,%esp
80108f95:	50                   	push   %eax
80108f96:	68 2f 9d 10 80       	push   $0x80109d2f
80108f9b:	e8 78 74 ff ff       	call   80100418 <cprintf>
80108fa0:	83 c4 10             	add    $0x10,%esp
    if (*mypte & PTE_E) {
80108fa3:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108fa6:	8b 00                	mov    (%eax),%eax
80108fa8:	25 00 04 00 00       	and    $0x400,%eax
80108fad:	85 c0                	test   %eax,%eax
80108faf:	74 19                	je     80108fca <mencrypt+0x15e>
      cprintf("p4Debug: already encrypted\n");
80108fb1:	83 ec 0c             	sub    $0xc,%esp
80108fb4:	68 5a 9e 10 80       	push   $0x80109e5a
80108fb9:	e8 5a 74 ff ff       	call   80100418 <cprintf>
80108fbe:	83 c4 10             	add    $0x10,%esp
      slider += PGSIZE;
80108fc1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
      continue;
80108fc8:	eb 6f                	jmp    80109039 <mencrypt+0x1cd>
    }
    for (int offset = 0; offset < PGSIZE; offset++) {
80108fca:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
80108fd1:	eb 17                	jmp    80108fea <mencrypt+0x17e>
      *slider = *slider ^ 0xFF;
80108fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fd6:	0f b6 00             	movzbl (%eax),%eax
80108fd9:	f7 d0                	not    %eax
80108fdb:	89 c2                	mov    %eax,%edx
80108fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fe0:	88 10                	mov    %dl,(%eax)
      slider++;
80108fe2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    for (int offset = 0; offset < PGSIZE; offset++) {
80108fe6:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80108fea:	81 7d e8 ff 0f 00 00 	cmpl   $0xfff,-0x18(%ebp)
80108ff1:	7e e0                	jle    80108fd3 <mencrypt+0x167>
    }
    char * kvp_translated = translate_and_set(mypd, slider-PGSIZE);
80108ff3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ff6:	2d 00 10 00 00       	sub    $0x1000,%eax
80108ffb:	83 ec 08             	sub    $0x8,%esp
80108ffe:	50                   	push   %eax
80108fff:	ff 75 e0             	pushl  -0x20(%ebp)
80109002:	e8 46 f9 ff ff       	call   8010894d <translate_and_set>
80109007:	83 c4 10             	add    $0x10,%esp
8010900a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    if (!kvp_translated) {
8010900d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80109011:	75 17                	jne    8010902a <mencrypt+0x1be>
      cprintf("p4Debug: translate failed!");
80109013:	83 ec 0c             	sub    $0xc,%esp
80109016:	68 76 9e 10 80       	push   $0x80109e76
8010901b:	e8 f8 73 ff ff       	call   80100418 <cprintf>
80109020:	83 c4 10             	add    $0x10,%esp
      return -1;
80109023:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109028:	eb 35                	jmp    8010905f <mencrypt+0x1f3>
    }
    *mypte = *mypte & ~PTE_A;
8010902a:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010902d:	8b 00                	mov    (%eax),%eax
8010902f:	83 e0 df             	and    $0xffffffdf,%eax
80109032:	89 c2                	mov    %eax,%edx
80109034:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109037:	89 10                	mov    %edx,(%eax)
  for (int i = 0; i < len; i++) {
80109039:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010903d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109040:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109043:	0f 8c ed fe ff ff    	jl     80108f36 <mencrypt+0xca>
  }

  switchuvm(myproc());
80109049:	e8 c1 b4 ff ff       	call   8010450f <myproc>
8010904e:	83 ec 0c             	sub    $0xc,%esp
80109051:	50                   	push   %eax
80109052:	e8 3e f1 ff ff       	call   80108195 <switchuvm>
80109057:	83 c4 10             	add    $0x10,%esp
  return 0;
8010905a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010905f:	c9                   	leave  
80109060:	c3                   	ret    

80109061 <getpgtable>:

int getpgtable(struct pt_entry* pt_entries, int num, int wsetOnly) {
80109061:	f3 0f 1e fb          	endbr32 
80109065:	55                   	push   %ebp
80109066:	89 e5                	mov    %esp,%ebp
80109068:	83 ec 28             	sub    $0x28,%esp
  cprintf("p4Debug: table: %p, %d\n", pt_entries, num);
8010906b:	83 ec 04             	sub    $0x4,%esp
8010906e:	ff 75 0c             	pushl  0xc(%ebp)
80109071:	ff 75 08             	pushl  0x8(%ebp)
80109074:	68 91 9e 10 80       	push   $0x80109e91
80109079:	e8 9a 73 ff ff       	call   80100418 <cprintf>
8010907e:	83 c4 10             	add    $0x10,%esp

  struct proc *curproc = myproc();
80109081:	e8 89 b4 ff ff       	call   8010450f <myproc>
80109086:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pde_t *pgdir = curproc->pgdir;
80109089:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010908c:	8b 40 04             	mov    0x4(%eax),%eax
8010908f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint uva = 0;
80109092:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if (curproc->sz % PGSIZE == 0)
80109099:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010909c:	8b 00                	mov    (%eax),%eax
8010909e:	25 ff 0f 00 00       	and    $0xfff,%eax
801090a3:	85 c0                	test   %eax,%eax
801090a5:	75 0f                	jne    801090b6 <getpgtable+0x55>
    uva = curproc->sz - PGSIZE;
801090a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090aa:	8b 00                	mov    (%eax),%eax
801090ac:	2d 00 10 00 00       	sub    $0x1000,%eax
801090b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801090b4:	eb 0d                	jmp    801090c3 <getpgtable+0x62>
  else 
    uva = PGROUNDDOWN(curproc->sz);
801090b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090b9:	8b 00                	mov    (%eax),%eax
801090bb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801090c0:	89 45 f4             	mov    %eax,-0xc(%ebp)

  int i = 0;
801090c3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for (;;uva -=PGSIZE)
  {
    cprintf("MARZOOQI======================\n");
801090ca:	83 ec 0c             	sub    $0xc,%esp
801090cd:	68 ac 9e 10 80       	push   $0x80109eac
801090d2:	e8 41 73 ff ff       	call   80100418 <cprintf>
801090d7:	83 c4 10             	add    $0x10,%esp
    pte_t *pte = walkpgdir(pgdir, (const void *)uva, 0);
801090da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090dd:	83 ec 04             	sub    $0x4,%esp
801090e0:	6a 00                	push   $0x0
801090e2:	50                   	push   %eax
801090e3:	ff 75 e8             	pushl  -0x18(%ebp)
801090e6:	e8 83 ee ff ff       	call   80107f6e <walkpgdir>
801090eb:	83 c4 10             	add    $0x10,%esp
801090ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(wsetOnly && not_in_queue((char*)P2V(PTE_ADDR(*pte)))){
801090f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801090f5:	74 3a                	je     80109131 <getpgtable+0xd0>
801090f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801090fa:	8b 00                	mov    (%eax),%eax
801090fc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109101:	05 00 00 00 80       	add    $0x80000000,%eax
80109106:	83 ec 0c             	sub    $0xc,%esp
80109109:	50                   	push   %eax
8010910a:	e8 22 f9 ff ff       	call   80108a31 <not_in_queue>
8010910f:	83 c4 10             	add    $0x10,%esp
80109112:	85 c0                	test   %eax,%eax
80109114:	74 1b                	je     80109131 <getpgtable+0xd0>
      if(uva == 0 || i == num){
80109116:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010911a:	0f 84 cc 01 00 00    	je     801092ec <getpgtable+0x28b>
80109120:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109123:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109126:	0f 84 c0 01 00 00    	je     801092ec <getpgtable+0x28b>
        break;
      }
      continue;
8010912c:	e9 af 01 00 00       	jmp    801092e0 <getpgtable+0x27f>
    }
    if (!(*pte & PTE_U) || !(*pte & (PTE_P | PTE_E)))
80109131:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109134:	8b 00                	mov    (%eax),%eax
80109136:	83 e0 04             	and    $0x4,%eax
80109139:	85 c0                	test   %eax,%eax
8010913b:	0f 84 9e 01 00 00    	je     801092df <getpgtable+0x27e>
80109141:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109144:	8b 00                	mov    (%eax),%eax
80109146:	25 01 04 00 00       	and    $0x401,%eax
8010914b:	85 c0                	test   %eax,%eax
8010914d:	0f 84 8c 01 00 00    	je     801092df <getpgtable+0x27e>
      continue;
    cprintf("points ==================\n");
80109153:	83 ec 0c             	sub    $0xc,%esp
80109156:	68 cc 9e 10 80       	push   $0x80109ecc
8010915b:	e8 b8 72 ff ff       	call   80100418 <cprintf>
80109160:	83 c4 10             	add    $0x10,%esp
    pt_entries[i].pdx = PDX(uva);
80109163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109166:	c1 e8 16             	shr    $0x16,%eax
80109169:	89 c1                	mov    %eax,%ecx
8010916b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010916e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80109175:	8b 45 08             	mov    0x8(%ebp),%eax
80109178:	01 c2                	add    %eax,%edx
8010917a:	89 c8                	mov    %ecx,%eax
8010917c:	66 25 ff 03          	and    $0x3ff,%ax
80109180:	66 25 ff 03          	and    $0x3ff,%ax
80109184:	89 c1                	mov    %eax,%ecx
80109186:	0f b7 02             	movzwl (%edx),%eax
80109189:	66 25 00 fc          	and    $0xfc00,%ax
8010918d:	09 c8                	or     %ecx,%eax
8010918f:	66 89 02             	mov    %ax,(%edx)
    pt_entries[i].ptx = PTX(uva);
80109192:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109195:	c1 e8 0c             	shr    $0xc,%eax
80109198:	89 c1                	mov    %eax,%ecx
8010919a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010919d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
801091a4:	8b 45 08             	mov    0x8(%ebp),%eax
801091a7:	01 c2                	add    %eax,%edx
801091a9:	89 c8                	mov    %ecx,%eax
801091ab:	66 25 ff 03          	and    $0x3ff,%ax
801091af:	0f b7 c0             	movzwl %ax,%eax
801091b2:	25 ff 03 00 00       	and    $0x3ff,%eax
801091b7:	c1 e0 0a             	shl    $0xa,%eax
801091ba:	89 c1                	mov    %eax,%ecx
801091bc:	8b 02                	mov    (%edx),%eax
801091be:	25 ff 03 f0 ff       	and    $0xfff003ff,%eax
801091c3:	09 c8                	or     %ecx,%eax
801091c5:	89 02                	mov    %eax,(%edx)
    pt_entries[i].ppage = *pte >> PTXSHIFT;
801091c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801091ca:	8b 00                	mov    (%eax),%eax
801091cc:	c1 e8 0c             	shr    $0xc,%eax
801091cf:	89 c2                	mov    %eax,%edx
801091d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091d4:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
801091db:	8b 45 08             	mov    0x8(%ebp),%eax
801091de:	01 c8                	add    %ecx,%eax
801091e0:	81 e2 ff ff 0f 00    	and    $0xfffff,%edx
801091e6:	89 d1                	mov    %edx,%ecx
801091e8:	81 e1 ff ff 0f 00    	and    $0xfffff,%ecx
801091ee:	8b 50 04             	mov    0x4(%eax),%edx
801091f1:	81 e2 00 00 f0 ff    	and    $0xfff00000,%edx
801091f7:	09 ca                	or     %ecx,%edx
801091f9:	89 50 04             	mov    %edx,0x4(%eax)
    pt_entries[i].present = *pte & PTE_P;
801091fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801091ff:	8b 08                	mov    (%eax),%ecx
80109201:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109204:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
8010920b:	8b 45 08             	mov    0x8(%ebp),%eax
8010920e:	01 c2                	add    %eax,%edx
80109210:	89 c8                	mov    %ecx,%eax
80109212:	83 e0 01             	and    $0x1,%eax
80109215:	83 e0 01             	and    $0x1,%eax
80109218:	c1 e0 04             	shl    $0x4,%eax
8010921b:	89 c1                	mov    %eax,%ecx
8010921d:	0f b6 42 06          	movzbl 0x6(%edx),%eax
80109221:	83 e0 ef             	and    $0xffffffef,%eax
80109224:	09 c8                	or     %ecx,%eax
80109226:	88 42 06             	mov    %al,0x6(%edx)
    pt_entries[i].writable = (*pte & PTE_W) > 0;
80109229:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010922c:	8b 00                	mov    (%eax),%eax
8010922e:	83 e0 02             	and    $0x2,%eax
80109231:	89 c2                	mov    %eax,%edx
80109233:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109236:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
8010923d:	8b 45 08             	mov    0x8(%ebp),%eax
80109240:	01 c8                	add    %ecx,%eax
80109242:	85 d2                	test   %edx,%edx
80109244:	0f 95 c2             	setne  %dl
80109247:	83 e2 01             	and    $0x1,%edx
8010924a:	89 d1                	mov    %edx,%ecx
8010924c:	c1 e1 05             	shl    $0x5,%ecx
8010924f:	0f b6 50 06          	movzbl 0x6(%eax),%edx
80109253:	83 e2 df             	and    $0xffffffdf,%edx
80109256:	09 ca                	or     %ecx,%edx
80109258:	88 50 06             	mov    %dl,0x6(%eax)
    pt_entries[i].encrypted = (*pte & PTE_E) > 0;
8010925b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010925e:	8b 00                	mov    (%eax),%eax
80109260:	25 00 04 00 00       	and    $0x400,%eax
80109265:	89 c2                	mov    %eax,%edx
80109267:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010926a:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80109271:	8b 45 08             	mov    0x8(%ebp),%eax
80109274:	01 c8                	add    %ecx,%eax
80109276:	85 d2                	test   %edx,%edx
80109278:	0f 95 c2             	setne  %dl
8010927b:	89 d1                	mov    %edx,%ecx
8010927d:	c1 e1 07             	shl    $0x7,%ecx
80109280:	0f b6 50 06          	movzbl 0x6(%eax),%edx
80109284:	83 e2 7f             	and    $0x7f,%edx
80109287:	09 ca                	or     %ecx,%edx
80109289:	88 50 06             	mov    %dl,0x6(%eax)
    pt_entries[i].ref = (*pte & PTE_A) > 0;
8010928c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010928f:	8b 00                	mov    (%eax),%eax
80109291:	83 e0 20             	and    $0x20,%eax
80109294:	89 c2                	mov    %eax,%edx
80109296:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109299:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
801092a0:	8b 45 08             	mov    0x8(%ebp),%eax
801092a3:	01 c8                	add    %ecx,%eax
801092a5:	85 d2                	test   %edx,%edx
801092a7:	0f 95 c2             	setne  %dl
801092aa:	89 d1                	mov    %edx,%ecx
801092ac:	83 e1 01             	and    $0x1,%ecx
801092af:	0f b6 50 07          	movzbl 0x7(%eax),%edx
801092b3:	83 e2 fe             	and    $0xfffffffe,%edx
801092b6:	09 ca                	or     %ecx,%edx
801092b8:	88 50 07             	mov    %dl,0x7(%eax)
    //PT_A flag needs to be modified as per clock algo.
    cprintf("increment ==================\n");
801092bb:	83 ec 0c             	sub    $0xc,%esp
801092be:	68 e7 9e 10 80       	push   $0x80109ee7
801092c3:	e8 50 71 ff ff       	call   80100418 <cprintf>
801092c8:	83 c4 10             	add    $0x10,%esp
    i ++;
801092cb:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    if (uva == 0 || i == num) break;
801092cf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801092d3:	74 17                	je     801092ec <getpgtable+0x28b>
801092d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092d8:	3b 45 0c             	cmp    0xc(%ebp),%eax
801092db:	74 0f                	je     801092ec <getpgtable+0x28b>
801092dd:	eb 01                	jmp    801092e0 <getpgtable+0x27f>
      continue;
801092df:	90                   	nop
  for (;;uva -=PGSIZE)
801092e0:	81 6d f4 00 10 00 00 	subl   $0x1000,-0xc(%ebp)
  {
801092e7:	e9 de fd ff ff       	jmp    801090ca <getpgtable+0x69>

  }

  return i;
801092ec:	8b 45 f0             	mov    -0x10(%ebp),%eax

}
801092ef:	c9                   	leave  
801092f0:	c3                   	ret    

801092f1 <dump_rawphymem>:


int dump_rawphymem(char *physical_addr, char * buffer) {
801092f1:	f3 0f 1e fb          	endbr32 
801092f5:	55                   	push   %ebp
801092f6:	89 e5                	mov    %esp,%ebp
801092f8:	56                   	push   %esi
801092f9:	53                   	push   %ebx
801092fa:	83 ec 10             	sub    $0x10,%esp
  *buffer = *buffer;
801092fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80109300:	0f b6 10             	movzbl (%eax),%edx
80109303:	8b 45 0c             	mov    0xc(%ebp),%eax
80109306:	88 10                	mov    %dl,(%eax)
  cprintf("p4Debug: dump_rawphymem: %p, %p\n", physical_addr, buffer);
80109308:	83 ec 04             	sub    $0x4,%esp
8010930b:	ff 75 0c             	pushl  0xc(%ebp)
8010930e:	ff 75 08             	pushl  0x8(%ebp)
80109311:	68 08 9f 10 80       	push   $0x80109f08
80109316:	e8 fd 70 ff ff       	call   80100418 <cprintf>
8010931b:	83 c4 10             	add    $0x10,%esp
  int retval = copyout(myproc()->pgdir, (uint) buffer, (void *) PGROUNDDOWN((int)P2V(physical_addr)), PGSIZE);
8010931e:	8b 45 08             	mov    0x8(%ebp),%eax
80109321:	05 00 00 00 80       	add    $0x80000000,%eax
80109326:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010932b:	89 c6                	mov    %eax,%esi
8010932d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80109330:	e8 da b1 ff ff       	call   8010450f <myproc>
80109335:	8b 40 04             	mov    0x4(%eax),%eax
80109338:	68 00 10 00 00       	push   $0x1000
8010933d:	56                   	push   %esi
8010933e:	53                   	push   %ebx
8010933f:	50                   	push   %eax
80109340:	e8 66 f5 ff ff       	call   801088ab <copyout>
80109345:	83 c4 10             	add    $0x10,%esp
80109348:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  cprintf("\t\t\t\t\t\t\tIN DUMPRAWPHYMEM: \n");
8010934b:	83 ec 0c             	sub    $0xc,%esp
8010934e:	68 29 9f 10 80       	push   $0x80109f29
80109353:	e8 c0 70 ff ff       	call   80100418 <cprintf>
80109358:	83 c4 10             	add    $0x10,%esp
  
  if (retval){
8010935b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010935f:	74 17                	je     80109378 <dump_rawphymem+0x87>
    cprintf("==================== NOT VIBES");
80109361:	83 ec 0c             	sub    $0xc,%esp
80109364:	68 44 9f 10 80       	push   $0x80109f44
80109369:	e8 aa 70 ff ff       	call   80100418 <cprintf>
8010936e:	83 c4 10             	add    $0x10,%esp
    return -1;
80109371:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109376:	eb 15                	jmp    8010938d <dump_rawphymem+0x9c>
  }
  cprintf("======================VIBES");
80109378:	83 ec 0c             	sub    $0xc,%esp
8010937b:	68 63 9f 10 80       	push   $0x80109f63
80109380:	e8 93 70 ff ff       	call   80100418 <cprintf>
80109385:	83 c4 10             	add    $0x10,%esp
  return 0;
80109388:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010938d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80109390:	5b                   	pop    %ebx
80109391:	5e                   	pop    %esi
80109392:	5d                   	pop    %ebp
80109393:	c3                   	ret    
