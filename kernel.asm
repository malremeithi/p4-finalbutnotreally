
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
80100015:	b8 00 c0 10 00       	mov    $0x10c000,%eax
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
80100028:	bc 50 e6 10 80       	mov    $0x8010e650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 9f 3a 10 80       	mov    $0x80103a9f,%eax
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
80100041:	68 ac 94 10 80       	push   $0x801094ac
80100046:	68 60 e6 10 80       	push   $0x8010e660
8010004b:	e8 03 53 00 00       	call   80105353 <initlock>
80100050:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100053:	c7 05 ac 2d 11 80 5c 	movl   $0x80112d5c,0x80112dac
8010005a:	2d 11 80 
  bcache.head.next = &bcache.head;
8010005d:	c7 05 b0 2d 11 80 5c 	movl   $0x80112d5c,0x80112db0
80100064:	2d 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100067:	c7 45 f4 94 e6 10 80 	movl   $0x8010e694,-0xc(%ebp)
8010006e:	eb 47                	jmp    801000b7 <binit+0x83>
    b->next = bcache.head.next;
80100070:	8b 15 b0 2d 11 80    	mov    0x80112db0,%edx
80100076:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100079:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
8010007c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007f:	c7 40 50 5c 2d 11 80 	movl   $0x80112d5c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100086:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100089:	83 c0 0c             	add    $0xc,%eax
8010008c:	83 ec 08             	sub    $0x8,%esp
8010008f:	68 b3 94 10 80       	push   $0x801094b3
80100094:	50                   	push   %eax
80100095:	e8 26 51 00 00       	call   801051c0 <initsleeplock>
8010009a:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
8010009d:	a1 b0 2d 11 80       	mov    0x80112db0,%eax
801000a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000a5:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ab:	a3 b0 2d 11 80       	mov    %eax,0x80112db0
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000b0:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b7:	b8 5c 2d 11 80       	mov    $0x80112d5c,%eax
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
801000d2:	68 60 e6 10 80       	push   $0x8010e660
801000d7:	e8 9d 52 00 00       	call   80105379 <acquire>
801000dc:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000df:	a1 b0 2d 11 80       	mov    0x80112db0,%eax
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
80100111:	68 60 e6 10 80       	push   $0x8010e660
80100116:	e8 d0 52 00 00       	call   801053eb <release>
8010011b:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	83 c0 0c             	add    $0xc,%eax
80100124:	83 ec 0c             	sub    $0xc,%esp
80100127:	50                   	push   %eax
80100128:	e8 d3 50 00 00       	call   80105200 <acquiresleep>
8010012d:	83 c4 10             	add    $0x10,%esp
      return b;
80100130:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100133:	e9 9d 00 00 00       	jmp    801001d5 <bget+0x110>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100138:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010013b:	8b 40 54             	mov    0x54(%eax),%eax
8010013e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100141:	81 7d f4 5c 2d 11 80 	cmpl   $0x80112d5c,-0xc(%ebp)
80100148:	75 9f                	jne    801000e9 <bget+0x24>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
8010014a:	a1 ac 2d 11 80       	mov    0x80112dac,%eax
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
80100192:	68 60 e6 10 80       	push   $0x8010e660
80100197:	e8 4f 52 00 00       	call   801053eb <release>
8010019c:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
8010019f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a2:	83 c0 0c             	add    $0xc,%eax
801001a5:	83 ec 0c             	sub    $0xc,%esp
801001a8:	50                   	push   %eax
801001a9:	e8 52 50 00 00       	call   80105200 <acquiresleep>
801001ae:	83 c4 10             	add    $0x10,%esp
      return b;
801001b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b4:	eb 1f                	jmp    801001d5 <bget+0x110>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b9:	8b 40 50             	mov    0x50(%eax),%eax
801001bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001bf:	81 7d f4 5c 2d 11 80 	cmpl   $0x80112d5c,-0xc(%ebp)
801001c6:	75 8c                	jne    80100154 <bget+0x8f>
    }
  }
  panic("bget: no buffers");
801001c8:	83 ec 0c             	sub    $0xc,%esp
801001cb:	68 ba 94 10 80       	push   $0x801094ba
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
80100207:	e8 f2 28 00 00       	call   80102afe <iderw>
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
80100228:	e8 8d 50 00 00       	call   801052ba <holdingsleep>
8010022d:	83 c4 10             	add    $0x10,%esp
80100230:	85 c0                	test   %eax,%eax
80100232:	75 0d                	jne    80100241 <bwrite+0x2d>
    panic("bwrite");
80100234:	83 ec 0c             	sub    $0xc,%esp
80100237:	68 cb 94 10 80       	push   $0x801094cb
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
80100256:	e8 a3 28 00 00       	call   80102afe <iderw>
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
80100275:	e8 40 50 00 00       	call   801052ba <holdingsleep>
8010027a:	83 c4 10             	add    $0x10,%esp
8010027d:	85 c0                	test   %eax,%eax
8010027f:	75 0d                	jne    8010028e <brelse+0x2d>
    panic("brelse");
80100281:	83 ec 0c             	sub    $0xc,%esp
80100284:	68 d2 94 10 80       	push   $0x801094d2
80100289:	e8 7a 03 00 00       	call   80100608 <panic>

  releasesleep(&b->lock);
8010028e:	8b 45 08             	mov    0x8(%ebp),%eax
80100291:	83 c0 0c             	add    $0xc,%eax
80100294:	83 ec 0c             	sub    $0xc,%esp
80100297:	50                   	push   %eax
80100298:	e8 cb 4f 00 00       	call   80105268 <releasesleep>
8010029d:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002a0:	83 ec 0c             	sub    $0xc,%esp
801002a3:	68 60 e6 10 80       	push   $0x8010e660
801002a8:	e8 cc 50 00 00       	call   80105379 <acquire>
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
801002e7:	8b 15 b0 2d 11 80    	mov    0x80112db0,%edx
801002ed:	8b 45 08             	mov    0x8(%ebp),%eax
801002f0:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002f3:	8b 45 08             	mov    0x8(%ebp),%eax
801002f6:	c7 40 50 5c 2d 11 80 	movl   $0x80112d5c,0x50(%eax)
    bcache.head.next->prev = b;
801002fd:	a1 b0 2d 11 80       	mov    0x80112db0,%eax
80100302:	8b 55 08             	mov    0x8(%ebp),%edx
80100305:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100308:	8b 45 08             	mov    0x8(%ebp),%eax
8010030b:	a3 b0 2d 11 80       	mov    %eax,0x80112db0
  }
  
  release(&bcache.lock);
80100310:	83 ec 0c             	sub    $0xc,%esp
80100313:	68 60 e6 10 80       	push   $0x8010e660
80100318:	e8 ce 50 00 00       	call   801053eb <release>
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
801003b9:	0f b6 91 04 b0 10 80 	movzbl -0x7fef4ffc(%ecx),%edx
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
80100422:	a1 f4 d5 10 80       	mov    0x8010d5f4,%eax
80100427:	89 45 e8             	mov    %eax,-0x18(%ebp)
  //changed: added holding check
  if(locking && !holding(&cons.lock))
8010042a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010042e:	74 24                	je     80100454 <cprintf+0x3c>
80100430:	83 ec 0c             	sub    $0xc,%esp
80100433:	68 c0 d5 10 80       	push   $0x8010d5c0
80100438:	e8 83 50 00 00       	call   801054c0 <holding>
8010043d:	83 c4 10             	add    $0x10,%esp
80100440:	85 c0                	test   %eax,%eax
80100442:	75 10                	jne    80100454 <cprintf+0x3c>
    acquire(&cons.lock);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	68 c0 d5 10 80       	push   $0x8010d5c0
8010044c:	e8 28 4f 00 00       	call   80105379 <acquire>
80100451:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100454:	8b 45 08             	mov    0x8(%ebp),%eax
80100457:	85 c0                	test   %eax,%eax
80100459:	75 0d                	jne    80100468 <cprintf+0x50>
    panic("null fmt");
8010045b:	83 ec 0c             	sub    $0xc,%esp
8010045e:	68 dc 94 10 80       	push   $0x801094dc
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
801004ee:	8b 04 85 ec 94 10 80 	mov    -0x7fef6b14(,%eax,4),%eax
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
8010054c:	c7 45 ec e5 94 10 80 	movl   $0x801094e5,-0x14(%ebp)
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
801005f8:	68 c0 d5 10 80       	push   $0x8010d5c0
801005fd:	e8 e9 4d 00 00       	call   801053eb <release>
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
80100617:	c7 05 f4 d5 10 80 00 	movl   $0x0,0x8010d5f4
8010061e:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
80100621:	e8 ca 2b 00 00       	call   801031f0 <lapicid>
80100626:	83 ec 08             	sub    $0x8,%esp
80100629:	50                   	push   %eax
8010062a:	68 44 95 10 80       	push   $0x80109544
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
80100649:	68 58 95 10 80       	push   $0x80109558
8010064e:	e8 c5 fd ff ff       	call   80100418 <cprintf>
80100653:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100656:	83 ec 08             	sub    $0x8,%esp
80100659:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010065c:	50                   	push   %eax
8010065d:	8d 45 08             	lea    0x8(%ebp),%eax
80100660:	50                   	push   %eax
80100661:	e8 db 4d 00 00       	call   80105441 <getcallerpcs>
80100666:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100669:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100670:	eb 1c                	jmp    8010068e <panic+0x86>
    cprintf(" %p", pcs[i]);
80100672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100675:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100679:	83 ec 08             	sub    $0x8,%esp
8010067c:	50                   	push   %eax
8010067d:	68 5a 95 10 80       	push   $0x8010955a
80100682:	e8 91 fd ff ff       	call   80100418 <cprintf>
80100687:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
8010068a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010068e:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80100692:	7e de                	jle    80100672 <panic+0x6a>
  panicked = 1; // freeze other CPU
80100694:	c7 05 a0 d5 10 80 01 	movl   $0x1,0x8010d5a0
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
80100748:	8b 0d 00 b0 10 80    	mov    0x8010b000,%ecx
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
80100772:	68 5e 95 10 80       	push   $0x8010955e
80100777:	e8 8c fe ff ff       	call   80100608 <panic>

  if((pos/80) >= 24){  // Scroll up.
8010077c:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
80100783:	7e 4c                	jle    801007d1 <cgaputc+0x131>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100785:	a1 00 b0 10 80       	mov    0x8010b000,%eax
8010078a:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80100790:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100795:	83 ec 04             	sub    $0x4,%esp
80100798:	68 60 0e 00 00       	push   $0xe60
8010079d:	52                   	push   %edx
8010079e:	50                   	push   %eax
8010079f:	e8 3b 4f 00 00       	call   801056df <memmove>
801007a4:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801007a7:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801007ab:	b8 80 07 00 00       	mov    $0x780,%eax
801007b0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801007b3:	8d 14 00             	lea    (%eax,%eax,1),%edx
801007b6:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801007bb:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801007be:	01 c9                	add    %ecx,%ecx
801007c0:	01 c8                	add    %ecx,%eax
801007c2:	83 ec 04             	sub    $0x4,%esp
801007c5:	52                   	push   %edx
801007c6:	6a 00                	push   $0x0
801007c8:	50                   	push   %eax
801007c9:	e8 4a 4e 00 00       	call   80105618 <memset>
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
80100826:	a1 00 b0 10 80       	mov    0x8010b000,%eax
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
80100847:	a1 a0 d5 10 80       	mov    0x8010d5a0,%eax
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
80100865:	e8 bd 68 00 00       	call   80107127 <uartputc>
8010086a:	83 c4 10             	add    $0x10,%esp
8010086d:	83 ec 0c             	sub    $0xc,%esp
80100870:	6a 20                	push   $0x20
80100872:	e8 b0 68 00 00       	call   80107127 <uartputc>
80100877:	83 c4 10             	add    $0x10,%esp
8010087a:	83 ec 0c             	sub    $0xc,%esp
8010087d:	6a 08                	push   $0x8
8010087f:	e8 a3 68 00 00       	call   80107127 <uartputc>
80100884:	83 c4 10             	add    $0x10,%esp
80100887:	eb 0e                	jmp    80100897 <consputc+0x5a>
  } else
    uartputc(c);
80100889:	83 ec 0c             	sub    $0xc,%esp
8010088c:	ff 75 08             	pushl  0x8(%ebp)
8010088f:	e8 93 68 00 00       	call   80107127 <uartputc>
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
801008bc:	68 c0 d5 10 80       	push   $0x8010d5c0
801008c1:	e8 b3 4a 00 00       	call   80105379 <acquire>
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
8010090e:	a1 48 30 11 80       	mov    0x80113048,%eax
80100913:	83 e8 01             	sub    $0x1,%eax
80100916:	a3 48 30 11 80       	mov    %eax,0x80113048
        consputc(BACKSPACE);
8010091b:	83 ec 0c             	sub    $0xc,%esp
8010091e:	68 00 01 00 00       	push   $0x100
80100923:	e8 15 ff ff ff       	call   8010083d <consputc>
80100928:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
8010092b:	8b 15 48 30 11 80    	mov    0x80113048,%edx
80100931:	a1 44 30 11 80       	mov    0x80113044,%eax
80100936:	39 c2                	cmp    %eax,%edx
80100938:	0f 84 e2 00 00 00    	je     80100a20 <consoleintr+0x178>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010093e:	a1 48 30 11 80       	mov    0x80113048,%eax
80100943:	83 e8 01             	sub    $0x1,%eax
80100946:	83 e0 7f             	and    $0x7f,%eax
80100949:	0f b6 80 c0 2f 11 80 	movzbl -0x7feed040(%eax),%eax
      while(input.e != input.w &&
80100950:	3c 0a                	cmp    $0xa,%al
80100952:	75 ba                	jne    8010090e <consoleintr+0x66>
      }
      break;
80100954:	e9 c7 00 00 00       	jmp    80100a20 <consoleintr+0x178>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100959:	8b 15 48 30 11 80    	mov    0x80113048,%edx
8010095f:	a1 44 30 11 80       	mov    0x80113044,%eax
80100964:	39 c2                	cmp    %eax,%edx
80100966:	0f 84 b4 00 00 00    	je     80100a20 <consoleintr+0x178>
        input.e--;
8010096c:	a1 48 30 11 80       	mov    0x80113048,%eax
80100971:	83 e8 01             	sub    $0x1,%eax
80100974:	a3 48 30 11 80       	mov    %eax,0x80113048
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
80100998:	8b 15 48 30 11 80    	mov    0x80113048,%edx
8010099e:	a1 40 30 11 80       	mov    0x80113040,%eax
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
801009bf:	a1 48 30 11 80       	mov    0x80113048,%eax
801009c4:	8d 50 01             	lea    0x1(%eax),%edx
801009c7:	89 15 48 30 11 80    	mov    %edx,0x80113048
801009cd:	83 e0 7f             	and    $0x7f,%eax
801009d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801009d3:	88 90 c0 2f 11 80    	mov    %dl,-0x7feed040(%eax)
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
801009f3:	a1 48 30 11 80       	mov    0x80113048,%eax
801009f8:	8b 15 40 30 11 80    	mov    0x80113040,%edx
801009fe:	83 ea 80             	sub    $0xffffff80,%edx
80100a01:	39 d0                	cmp    %edx,%eax
80100a03:	75 1a                	jne    80100a1f <consoleintr+0x177>
          input.w = input.e;
80100a05:	a1 48 30 11 80       	mov    0x80113048,%eax
80100a0a:	a3 44 30 11 80       	mov    %eax,0x80113044
          wakeup(&input.r);
80100a0f:	83 ec 0c             	sub    $0xc,%esp
80100a12:	68 40 30 11 80       	push   $0x80113040
80100a17:	e8 dd 45 00 00       	call   80104ff9 <wakeup>
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
80100a35:	68 c0 d5 10 80       	push   $0x8010d5c0
80100a3a:	e8 ac 49 00 00       	call   801053eb <release>
80100a3f:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100a42:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100a46:	74 05                	je     80100a4d <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
80100a48:	e8 72 46 00 00       	call   801050bf <procdump>
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
80100a60:	e8 1f 12 00 00       	call   80101c84 <iunlock>
80100a65:	83 c4 10             	add    $0x10,%esp
  target = n;
80100a68:	8b 45 10             	mov    0x10(%ebp),%eax
80100a6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	68 c0 d5 10 80       	push   $0x8010d5c0
80100a76:	e8 fe 48 00 00       	call   80105379 <acquire>
80100a7b:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100a7e:	e9 ab 00 00 00       	jmp    80100b2e <consoleread+0xde>
    while(input.r == input.w){
      if(myproc()->killed){
80100a83:	e8 99 3a 00 00       	call   80104521 <myproc>
80100a88:	8b 40 24             	mov    0x24(%eax),%eax
80100a8b:	85 c0                	test   %eax,%eax
80100a8d:	74 28                	je     80100ab7 <consoleread+0x67>
        release(&cons.lock);
80100a8f:	83 ec 0c             	sub    $0xc,%esp
80100a92:	68 c0 d5 10 80       	push   $0x8010d5c0
80100a97:	e8 4f 49 00 00       	call   801053eb <release>
80100a9c:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a9f:	83 ec 0c             	sub    $0xc,%esp
80100aa2:	ff 75 08             	pushl  0x8(%ebp)
80100aa5:	e8 c3 10 00 00       	call   80101b6d <ilock>
80100aaa:	83 c4 10             	add    $0x10,%esp
        return -1;
80100aad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ab2:	e9 ab 00 00 00       	jmp    80100b62 <consoleread+0x112>
      }
      sleep(&input.r, &cons.lock);
80100ab7:	83 ec 08             	sub    $0x8,%esp
80100aba:	68 c0 d5 10 80       	push   $0x8010d5c0
80100abf:	68 40 30 11 80       	push   $0x80113040
80100ac4:	e8 3e 44 00 00       	call   80104f07 <sleep>
80100ac9:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100acc:	8b 15 40 30 11 80    	mov    0x80113040,%edx
80100ad2:	a1 44 30 11 80       	mov    0x80113044,%eax
80100ad7:	39 c2                	cmp    %eax,%edx
80100ad9:	74 a8                	je     80100a83 <consoleread+0x33>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100adb:	a1 40 30 11 80       	mov    0x80113040,%eax
80100ae0:	8d 50 01             	lea    0x1(%eax),%edx
80100ae3:	89 15 40 30 11 80    	mov    %edx,0x80113040
80100ae9:	83 e0 7f             	and    $0x7f,%eax
80100aec:	0f b6 80 c0 2f 11 80 	movzbl -0x7feed040(%eax),%eax
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
80100b07:	a1 40 30 11 80       	mov    0x80113040,%eax
80100b0c:	83 e8 01             	sub    $0x1,%eax
80100b0f:	a3 40 30 11 80       	mov    %eax,0x80113040
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
80100b3d:	68 c0 d5 10 80       	push   $0x8010d5c0
80100b42:	e8 a4 48 00 00       	call   801053eb <release>
80100b47:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b4a:	83 ec 0c             	sub    $0xc,%esp
80100b4d:	ff 75 08             	pushl  0x8(%ebp)
80100b50:	e8 18 10 00 00       	call   80101b6d <ilock>
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
80100b74:	e8 0b 11 00 00       	call   80101c84 <iunlock>
80100b79:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100b7c:	83 ec 0c             	sub    $0xc,%esp
80100b7f:	68 c0 d5 10 80       	push   $0x8010d5c0
80100b84:	e8 f0 47 00 00       	call   80105379 <acquire>
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
80100bc1:	68 c0 d5 10 80       	push   $0x8010d5c0
80100bc6:	e8 20 48 00 00       	call   801053eb <release>
80100bcb:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100bce:	83 ec 0c             	sub    $0xc,%esp
80100bd1:	ff 75 08             	pushl  0x8(%ebp)
80100bd4:	e8 94 0f 00 00       	call   80101b6d <ilock>
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
80100bee:	68 71 95 10 80       	push   $0x80109571
80100bf3:	68 c0 d5 10 80       	push   $0x8010d5c0
80100bf8:	e8 56 47 00 00       	call   80105353 <initlock>
80100bfd:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100c00:	c7 05 0c 3a 11 80 64 	movl   $0x80100b64,0x80113a0c
80100c07:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100c0a:	c7 05 08 3a 11 80 50 	movl   $0x80100a50,0x80113a08
80100c11:	0a 10 80 
  cons.locking = 1;
80100c14:	c7 05 f4 d5 10 80 01 	movl   $0x1,0x8010d5f4
80100c1b:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100c1e:	83 ec 08             	sub    $0x8,%esp
80100c21:	6a 00                	push   $0x0
80100c23:	6a 01                	push   $0x1
80100c25:	e8 ad 20 00 00       	call   80102cd7 <ioapicenable>
80100c2a:	83 c4 10             	add    $0x10,%esp
}
80100c2d:	90                   	nop
80100c2e:	c9                   	leave  
80100c2f:	c3                   	ret    

80100c30 <exec>:
#include <stddef.h>

//TODO  Encrypt all those pages set up by the exec function at the end of the exec function. These pages include program text, data, and stack pages. These pages are not allocated through growproc() and thus not handle by the first case
int
exec(char *path, char **argv)
{
80100c30:	f3 0f 1e fb          	endbr32 
80100c34:	55                   	push   %ebp
80100c35:	89 e5                	mov    %esp,%ebp
80100c37:	81 ec 28 01 00 00    	sub    $0x128,%esp
cprintf("IN EXEC ------------------\n");
80100c3d:	83 ec 0c             	sub    $0xc,%esp
80100c40:	68 79 95 10 80       	push   $0x80109579
80100c45:	e8 ce f7 ff ff       	call   80100418 <cprintf>
80100c4a:	83 c4 10             	add    $0x10,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100c4d:	e8 cf 38 00 00       	call   80104521 <myproc>
80100c52:	89 45 c8             	mov    %eax,-0x38(%ebp)
  
  //access this process's queue?*****
//  for(int j=0; j<CLOCKSIZE; j++){
  //	curproc->clock[j]=0;
 // }
  curproc->head = 0;
80100c55:	8b 45 c8             	mov    -0x38(%ebp),%eax
80100c58:	c7 80 9c 00 00 00 00 	movl   $0x0,0x9c(%eax)
80100c5f:	00 00 00 
  begin_op();
80100c62:	e8 fb 2a 00 00       	call   80103762 <begin_op>

  if((ip = namei(path)) == 0){
80100c67:	83 ec 0c             	sub    $0xc,%esp
80100c6a:	ff 75 08             	pushl  0x8(%ebp)
80100c6d:	e8 66 1a 00 00       	call   801026d8 <namei>
80100c72:	83 c4 10             	add    $0x10,%esp
80100c75:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c78:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c7c:	75 1f                	jne    80100c9d <exec+0x6d>
    end_op();
80100c7e:	e8 6f 2b 00 00       	call   801037f2 <end_op>
    cprintf("exec: fail\n");
80100c83:	83 ec 0c             	sub    $0xc,%esp
80100c86:	68 95 95 10 80       	push   $0x80109595
80100c8b:	e8 88 f7 ff ff       	call   80100418 <cprintf>
80100c90:	83 c4 10             	add    $0x10,%esp
    return -1;
80100c93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c98:	e9 66 04 00 00       	jmp    80101103 <exec+0x4d3>
  }
  ilock(ip);
80100c9d:	83 ec 0c             	sub    $0xc,%esp
80100ca0:	ff 75 d8             	pushl  -0x28(%ebp)
80100ca3:	e8 c5 0e 00 00       	call   80101b6d <ilock>
80100ca8:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100cab:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100cb2:	6a 34                	push   $0x34
80100cb4:	6a 00                	push   $0x0
80100cb6:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
80100cbc:	50                   	push   %eax
80100cbd:	ff 75 d8             	pushl  -0x28(%ebp)
80100cc0:	e8 b0 13 00 00       	call   80102075 <readi>
80100cc5:	83 c4 10             	add    $0x10,%esp
80100cc8:	83 f8 34             	cmp    $0x34,%eax
80100ccb:	0f 85 db 03 00 00    	jne    801010ac <exec+0x47c>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100cd1:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100cd7:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100cdc:	0f 85 cd 03 00 00    	jne    801010af <exec+0x47f>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100ce2:	e8 a6 74 00 00       	call   8010818d <setupkvm>
80100ce7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100cea:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100cee:	0f 84 be 03 00 00    	je     801010b2 <exec+0x482>
    goto bad;

  // Load program into memory.
  sz = 0;
80100cf4:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100cfb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100d02:	8b 85 1c ff ff ff    	mov    -0xe4(%ebp),%eax
80100d08:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d0b:	e9 de 00 00 00       	jmp    80100dee <exec+0x1be>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100d10:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d13:	6a 20                	push   $0x20
80100d15:	50                   	push   %eax
80100d16:	8d 85 e0 fe ff ff    	lea    -0x120(%ebp),%eax
80100d1c:	50                   	push   %eax
80100d1d:	ff 75 d8             	pushl  -0x28(%ebp)
80100d20:	e8 50 13 00 00       	call   80102075 <readi>
80100d25:	83 c4 10             	add    $0x10,%esp
80100d28:	83 f8 20             	cmp    $0x20,%eax
80100d2b:	0f 85 84 03 00 00    	jne    801010b5 <exec+0x485>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100d31:	8b 85 e0 fe ff ff    	mov    -0x120(%ebp),%eax
80100d37:	83 f8 01             	cmp    $0x1,%eax
80100d3a:	0f 85 a0 00 00 00    	jne    80100de0 <exec+0x1b0>
      continue;
    if(ph.memsz < ph.filesz)
80100d40:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100d46:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d4c:	39 c2                	cmp    %eax,%edx
80100d4e:	0f 82 64 03 00 00    	jb     801010b8 <exec+0x488>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100d54:	8b 95 e8 fe ff ff    	mov    -0x118(%ebp),%edx
80100d5a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100d60:	01 c2                	add    %eax,%edx
80100d62:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100d68:	39 c2                	cmp    %eax,%edx
80100d6a:	0f 82 4b 03 00 00    	jb     801010bb <exec+0x48b>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100d70:	8b 95 e8 fe ff ff    	mov    -0x118(%ebp),%edx
80100d76:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100d7c:	01 d0                	add    %edx,%eax
80100d7e:	83 ec 04             	sub    $0x4,%esp
80100d81:	50                   	push   %eax
80100d82:	ff 75 e0             	pushl  -0x20(%ebp)
80100d85:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d88:	e8 be 77 00 00       	call   8010854b <allocuvm>
80100d8d:	83 c4 10             	add    $0x10,%esp
80100d90:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d93:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d97:	0f 84 21 03 00 00    	je     801010be <exec+0x48e>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100d9d:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100da3:	25 ff 0f 00 00       	and    $0xfff,%eax
80100da8:	85 c0                	test   %eax,%eax
80100daa:	0f 85 11 03 00 00    	jne    801010c1 <exec+0x491>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100db0:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100db6:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
80100dbc:	8b 8d e8 fe ff ff    	mov    -0x118(%ebp),%ecx
80100dc2:	83 ec 0c             	sub    $0xc,%esp
80100dc5:	52                   	push   %edx
80100dc6:	50                   	push   %eax
80100dc7:	ff 75 d8             	pushl  -0x28(%ebp)
80100dca:	51                   	push   %ecx
80100dcb:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dce:	e8 a7 76 00 00       	call   8010847a <loaduvm>
80100dd3:	83 c4 20             	add    $0x20,%esp
80100dd6:	85 c0                	test   %eax,%eax
80100dd8:	0f 88 e6 02 00 00    	js     801010c4 <exec+0x494>
80100dde:	eb 01                	jmp    80100de1 <exec+0x1b1>
      continue;
80100de0:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100de1:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100de5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100de8:	83 c0 20             	add    $0x20,%eax
80100deb:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100dee:	0f b7 85 2c ff ff ff 	movzwl -0xd4(%ebp),%eax
80100df5:	0f b7 c0             	movzwl %ax,%eax
80100df8:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100dfb:	0f 8c 0f ff ff ff    	jl     80100d10 <exec+0xe0>
      goto bad;
  }
  iunlockput(ip);
80100e01:	83 ec 0c             	sub    $0xc,%esp
80100e04:	ff 75 d8             	pushl  -0x28(%ebp)
80100e07:	e8 9e 0f 00 00       	call   80101daa <iunlockput>
80100e0c:	83 c4 10             	add    $0x10,%esp
  end_op();
80100e0f:	e8 de 29 00 00       	call   801037f2 <end_op>
  ip = 0;
80100e14:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  
 
  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100e1b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e1e:	05 ff 0f 00 00       	add    $0xfff,%eax
80100e23:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100e28:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100e2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e2e:	05 00 20 00 00       	add    $0x2000,%eax
80100e33:	83 ec 04             	sub    $0x4,%esp
80100e36:	50                   	push   %eax
80100e37:	ff 75 e0             	pushl  -0x20(%ebp)
80100e3a:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e3d:	e8 09 77 00 00       	call   8010854b <allocuvm>
80100e42:	83 c4 10             	add    $0x10,%esp
80100e45:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100e48:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100e4c:	0f 84 75 02 00 00    	je     801010c7 <exec+0x497>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100e52:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e55:	2d 00 20 00 00       	sub    $0x2000,%eax
80100e5a:	83 ec 08             	sub    $0x8,%esp
80100e5d:	50                   	push   %eax
80100e5e:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e61:	e8 57 79 00 00       	call   801087bd <clearpteu>
80100e66:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100e69:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e6c:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e6f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100e76:	e9 96 00 00 00       	jmp    80100f11 <exec+0x2e1>
    if(argc >= MAXARG)
80100e7b:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100e7f:	0f 87 45 02 00 00    	ja     801010ca <exec+0x49a>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e88:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e92:	01 d0                	add    %edx,%eax
80100e94:	8b 00                	mov    (%eax),%eax
80100e96:	83 ec 0c             	sub    $0xc,%esp
80100e99:	50                   	push   %eax
80100e9a:	e8 e2 49 00 00       	call   80105881 <strlen>
80100e9f:	83 c4 10             	add    $0x10,%esp
80100ea2:	89 c2                	mov    %eax,%edx
80100ea4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ea7:	29 d0                	sub    %edx,%eax
80100ea9:	83 e8 01             	sub    $0x1,%eax
80100eac:	83 e0 fc             	and    $0xfffffffc,%eax
80100eaf:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100eb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eb5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ebc:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ebf:	01 d0                	add    %edx,%eax
80100ec1:	8b 00                	mov    (%eax),%eax
80100ec3:	83 ec 0c             	sub    $0xc,%esp
80100ec6:	50                   	push   %eax
80100ec7:	e8 b5 49 00 00       	call   80105881 <strlen>
80100ecc:	83 c4 10             	add    $0x10,%esp
80100ecf:	83 c0 01             	add    $0x1,%eax
80100ed2:	89 c1                	mov    %eax,%ecx
80100ed4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ed7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ede:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ee1:	01 d0                	add    %edx,%eax
80100ee3:	8b 00                	mov    (%eax),%eax
80100ee5:	51                   	push   %ecx
80100ee6:	50                   	push   %eax
80100ee7:	ff 75 dc             	pushl  -0x24(%ebp)
80100eea:	ff 75 d4             	pushl  -0x2c(%ebp)
80100eed:	e8 87 7a 00 00       	call   80108979 <copyout>
80100ef2:	83 c4 10             	add    $0x10,%esp
80100ef5:	85 c0                	test   %eax,%eax
80100ef7:	0f 88 d0 01 00 00    	js     801010cd <exec+0x49d>
      goto bad;
    ustack[3+argc] = sp;
80100efd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f00:	8d 50 03             	lea    0x3(%eax),%edx
80100f03:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f06:	89 84 95 34 ff ff ff 	mov    %eax,-0xcc(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100f0d:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100f11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f14:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f1e:	01 d0                	add    %edx,%eax
80100f20:	8b 00                	mov    (%eax),%eax
80100f22:	85 c0                	test   %eax,%eax
80100f24:	0f 85 51 ff ff ff    	jne    80100e7b <exec+0x24b>
  }
  ustack[3+argc] = 0;
80100f2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f2d:	83 c0 03             	add    $0x3,%eax
80100f30:	c7 84 85 34 ff ff ff 	movl   $0x0,-0xcc(%ebp,%eax,4)
80100f37:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100f3b:	c7 85 34 ff ff ff ff 	movl   $0xffffffff,-0xcc(%ebp)
80100f42:	ff ff ff 
  ustack[1] = argc;
80100f45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f48:	89 85 38 ff ff ff    	mov    %eax,-0xc8(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100f4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f51:	83 c0 01             	add    $0x1,%eax
80100f54:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f5b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f5e:	29 d0                	sub    %edx,%eax
80100f60:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%ebp)

  sp -= (3+argc+1) * 4;
80100f66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f69:	83 c0 04             	add    $0x4,%eax
80100f6c:	c1 e0 02             	shl    $0x2,%eax
80100f6f:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100f72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f75:	83 c0 04             	add    $0x4,%eax
80100f78:	c1 e0 02             	shl    $0x2,%eax
80100f7b:	50                   	push   %eax
80100f7c:	8d 85 34 ff ff ff    	lea    -0xcc(%ebp),%eax
80100f82:	50                   	push   %eax
80100f83:	ff 75 dc             	pushl  -0x24(%ebp)
80100f86:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f89:	e8 eb 79 00 00       	call   80108979 <copyout>
80100f8e:	83 c4 10             	add    $0x10,%esp
80100f91:	85 c0                	test   %eax,%eax
80100f93:	0f 88 37 01 00 00    	js     801010d0 <exec+0x4a0>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f99:	8b 45 08             	mov    0x8(%ebp),%eax
80100f9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fa2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100fa5:	eb 17                	jmp    80100fbe <exec+0x38e>
    if(*s == '/')
80100fa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100faa:	0f b6 00             	movzbl (%eax),%eax
80100fad:	3c 2f                	cmp    $0x2f,%al
80100faf:	75 09                	jne    80100fba <exec+0x38a>
      last = s+1;
80100fb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fb4:	83 c0 01             	add    $0x1,%eax
80100fb7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100fba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fc1:	0f b6 00             	movzbl (%eax),%eax
80100fc4:	84 c0                	test   %al,%al
80100fc6:	75 df                	jne    80100fa7 <exec+0x377>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100fc8:	8b 45 c8             	mov    -0x38(%ebp),%eax
80100fcb:	83 c0 6c             	add    $0x6c,%eax
80100fce:	83 ec 04             	sub    $0x4,%esp
80100fd1:	6a 10                	push   $0x10
80100fd3:	ff 75 f0             	pushl  -0x10(%ebp)
80100fd6:	50                   	push   %eax
80100fd7:	e8 57 48 00 00       	call   80105833 <safestrcpy>
80100fdc:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100fdf:	8b 45 c8             	mov    -0x38(%ebp),%eax
80100fe2:	8b 40 04             	mov    0x4(%eax),%eax
80100fe5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  curproc->pgdir = pgdir;
80100fe8:	8b 45 c8             	mov    -0x38(%ebp),%eax
80100feb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100fee:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100ff1:	8b 45 c8             	mov    -0x38(%ebp),%eax
80100ff4:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100ff7:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100ff9:	8b 45 c8             	mov    -0x38(%ebp),%eax
80100ffc:	8b 40 18             	mov    0x18(%eax),%eax
80100fff:	8b 95 18 ff ff ff    	mov    -0xe8(%ebp),%edx
80101005:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80101008:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010100b:	8b 40 18             	mov    0x18(%eax),%eax
8010100e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101011:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80101014:	83 ec 0c             	sub    $0xc,%esp
80101017:	ff 75 c8             	pushl  -0x38(%ebp)
8010101a:	e8 44 72 00 00       	call   80108263 <switchuvm>
8010101f:	83 c4 10             	add    $0x10,%esp
if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
  goto bad;
clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
sp = sz;
*/
    for(int j=0; j<CLOCKSIZE; j++){
80101022:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
80101029:	eb 15                	jmp    80101040 <exec+0x410>
        curproc->clock[j]=NULL;
8010102b:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010102e:	8b 55 d0             	mov    -0x30(%ebp),%edx
80101031:	83 c2 1c             	add    $0x1c,%edx
80101034:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
8010103b:	00 
    for(int j=0; j<CLOCKSIZE; j++){
8010103c:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
80101040:	83 7d d0 07          	cmpl   $0x7,-0x30(%ebp)
80101044:	7e e5                	jle    8010102b <exec+0x3fb>
  }
  curproc->head = 0;
80101046:	8b 45 c8             	mov    -0x38(%ebp),%eax
80101049:	c7 80 9c 00 00 00 00 	movl   $0x0,0x9c(%eax)
80101050:	00 00 00 
//	  if(i!=sz-2*PGSIZE)
//	  	mencrypt((char *)i, 1);
  //}


  int t = sz/PGSIZE;
80101053:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101056:	c1 e8 0c             	shr    $0xc,%eax
80101059:	89 45 cc             	mov    %eax,-0x34(%ebp)
  if(sz%PGSIZE)
8010105c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010105f:	25 ff 0f 00 00       	and    $0xfff,%eax
80101064:	85 c0                	test   %eax,%eax
80101066:	74 04                	je     8010106c <exec+0x43c>
	  t++;
80101068:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
  mencrypt(0, t-2);
8010106c:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010106f:	83 e8 02             	sub    $0x2,%eax
80101072:	83 ec 08             	sub    $0x8,%esp
80101075:	50                   	push   %eax
80101076:	6a 00                	push   $0x0
80101078:	e8 70 7f 00 00       	call   80108fed <mencrypt>
8010107d:	83 c4 10             	add    $0x10,%esp
  mencrypt((char*) ((t-1)*PGSIZE),1);
80101080:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101083:	83 e8 01             	sub    $0x1,%eax
80101086:	c1 e0 0c             	shl    $0xc,%eax
80101089:	83 ec 08             	sub    $0x8,%esp
8010108c:	6a 01                	push   $0x1
8010108e:	50                   	push   %eax
8010108f:	e8 59 7f 00 00       	call   80108fed <mencrypt>
80101094:	83 c4 10             	add    $0x10,%esp
 freevm(oldpgdir);
80101097:	83 ec 0c             	sub    $0xc,%esp
8010109a:	ff 75 c4             	pushl  -0x3c(%ebp)
8010109d:	e8 7c 76 00 00       	call   8010871e <freevm>
801010a2:	83 c4 10             	add    $0x10,%esp
  return 0;
801010a5:	b8 00 00 00 00       	mov    $0x0,%eax
801010aa:	eb 57                	jmp    80101103 <exec+0x4d3>
    goto bad;
801010ac:	90                   	nop
801010ad:	eb 22                	jmp    801010d1 <exec+0x4a1>
    goto bad;
801010af:	90                   	nop
801010b0:	eb 1f                	jmp    801010d1 <exec+0x4a1>
    goto bad;
801010b2:	90                   	nop
801010b3:	eb 1c                	jmp    801010d1 <exec+0x4a1>
      goto bad;
801010b5:	90                   	nop
801010b6:	eb 19                	jmp    801010d1 <exec+0x4a1>
      goto bad;
801010b8:	90                   	nop
801010b9:	eb 16                	jmp    801010d1 <exec+0x4a1>
      goto bad;
801010bb:	90                   	nop
801010bc:	eb 13                	jmp    801010d1 <exec+0x4a1>
      goto bad;
801010be:	90                   	nop
801010bf:	eb 10                	jmp    801010d1 <exec+0x4a1>
      goto bad;
801010c1:	90                   	nop
801010c2:	eb 0d                	jmp    801010d1 <exec+0x4a1>
      goto bad;
801010c4:	90                   	nop
801010c5:	eb 0a                	jmp    801010d1 <exec+0x4a1>
    goto bad;
801010c7:	90                   	nop
801010c8:	eb 07                	jmp    801010d1 <exec+0x4a1>
      goto bad;
801010ca:	90                   	nop
801010cb:	eb 04                	jmp    801010d1 <exec+0x4a1>
      goto bad;
801010cd:	90                   	nop
801010ce:	eb 01                	jmp    801010d1 <exec+0x4a1>
    goto bad;
801010d0:	90                   	nop

 bad:
  if(pgdir)
801010d1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
801010d5:	74 0e                	je     801010e5 <exec+0x4b5>
    freevm(pgdir);
801010d7:	83 ec 0c             	sub    $0xc,%esp
801010da:	ff 75 d4             	pushl  -0x2c(%ebp)
801010dd:	e8 3c 76 00 00       	call   8010871e <freevm>
801010e2:	83 c4 10             	add    $0x10,%esp
  if(ip){
801010e5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
801010e9:	74 13                	je     801010fe <exec+0x4ce>
    iunlockput(ip);
801010eb:	83 ec 0c             	sub    $0xc,%esp
801010ee:	ff 75 d8             	pushl  -0x28(%ebp)
801010f1:	e8 b4 0c 00 00       	call   80101daa <iunlockput>
801010f6:	83 c4 10             	add    $0x10,%esp
    end_op();
801010f9:	e8 f4 26 00 00       	call   801037f2 <end_op>
  }
  return -1;
801010fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101103:	c9                   	leave  
80101104:	c3                   	ret    

80101105 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101105:	f3 0f 1e fb          	endbr32 
80101109:	55                   	push   %ebp
8010110a:	89 e5                	mov    %esp,%ebp
8010110c:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
8010110f:	83 ec 08             	sub    $0x8,%esp
80101112:	68 a1 95 10 80       	push   $0x801095a1
80101117:	68 60 30 11 80       	push   $0x80113060
8010111c:	e8 32 42 00 00       	call   80105353 <initlock>
80101121:	83 c4 10             	add    $0x10,%esp
}
80101124:	90                   	nop
80101125:	c9                   	leave  
80101126:	c3                   	ret    

80101127 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101127:	f3 0f 1e fb          	endbr32 
8010112b:	55                   	push   %ebp
8010112c:	89 e5                	mov    %esp,%ebp
8010112e:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80101131:	83 ec 0c             	sub    $0xc,%esp
80101134:	68 60 30 11 80       	push   $0x80113060
80101139:	e8 3b 42 00 00       	call   80105379 <acquire>
8010113e:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101141:	c7 45 f4 94 30 11 80 	movl   $0x80113094,-0xc(%ebp)
80101148:	eb 2d                	jmp    80101177 <filealloc+0x50>
    if(f->ref == 0){
8010114a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010114d:	8b 40 04             	mov    0x4(%eax),%eax
80101150:	85 c0                	test   %eax,%eax
80101152:	75 1f                	jne    80101173 <filealloc+0x4c>
      f->ref = 1;
80101154:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101157:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010115e:	83 ec 0c             	sub    $0xc,%esp
80101161:	68 60 30 11 80       	push   $0x80113060
80101166:	e8 80 42 00 00       	call   801053eb <release>
8010116b:	83 c4 10             	add    $0x10,%esp
      return f;
8010116e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101171:	eb 23                	jmp    80101196 <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101173:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101177:	b8 f4 39 11 80       	mov    $0x801139f4,%eax
8010117c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010117f:	72 c9                	jb     8010114a <filealloc+0x23>
    }
  }
  release(&ftable.lock);
80101181:	83 ec 0c             	sub    $0xc,%esp
80101184:	68 60 30 11 80       	push   $0x80113060
80101189:	e8 5d 42 00 00       	call   801053eb <release>
8010118e:	83 c4 10             	add    $0x10,%esp
  return 0;
80101191:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101196:	c9                   	leave  
80101197:	c3                   	ret    

80101198 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101198:	f3 0f 1e fb          	endbr32 
8010119c:	55                   	push   %ebp
8010119d:	89 e5                	mov    %esp,%ebp
8010119f:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
801011a2:	83 ec 0c             	sub    $0xc,%esp
801011a5:	68 60 30 11 80       	push   $0x80113060
801011aa:	e8 ca 41 00 00       	call   80105379 <acquire>
801011af:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801011b2:	8b 45 08             	mov    0x8(%ebp),%eax
801011b5:	8b 40 04             	mov    0x4(%eax),%eax
801011b8:	85 c0                	test   %eax,%eax
801011ba:	7f 0d                	jg     801011c9 <filedup+0x31>
    panic("filedup");
801011bc:	83 ec 0c             	sub    $0xc,%esp
801011bf:	68 a8 95 10 80       	push   $0x801095a8
801011c4:	e8 3f f4 ff ff       	call   80100608 <panic>
  f->ref++;
801011c9:	8b 45 08             	mov    0x8(%ebp),%eax
801011cc:	8b 40 04             	mov    0x4(%eax),%eax
801011cf:	8d 50 01             	lea    0x1(%eax),%edx
801011d2:	8b 45 08             	mov    0x8(%ebp),%eax
801011d5:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801011d8:	83 ec 0c             	sub    $0xc,%esp
801011db:	68 60 30 11 80       	push   $0x80113060
801011e0:	e8 06 42 00 00       	call   801053eb <release>
801011e5:	83 c4 10             	add    $0x10,%esp
  return f;
801011e8:	8b 45 08             	mov    0x8(%ebp),%eax
}
801011eb:	c9                   	leave  
801011ec:	c3                   	ret    

801011ed <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801011ed:	f3 0f 1e fb          	endbr32 
801011f1:	55                   	push   %ebp
801011f2:	89 e5                	mov    %esp,%ebp
801011f4:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801011f7:	83 ec 0c             	sub    $0xc,%esp
801011fa:	68 60 30 11 80       	push   $0x80113060
801011ff:	e8 75 41 00 00       	call   80105379 <acquire>
80101204:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101207:	8b 45 08             	mov    0x8(%ebp),%eax
8010120a:	8b 40 04             	mov    0x4(%eax),%eax
8010120d:	85 c0                	test   %eax,%eax
8010120f:	7f 0d                	jg     8010121e <fileclose+0x31>
    panic("fileclose");
80101211:	83 ec 0c             	sub    $0xc,%esp
80101214:	68 b0 95 10 80       	push   $0x801095b0
80101219:	e8 ea f3 ff ff       	call   80100608 <panic>
  if(--f->ref > 0){
8010121e:	8b 45 08             	mov    0x8(%ebp),%eax
80101221:	8b 40 04             	mov    0x4(%eax),%eax
80101224:	8d 50 ff             	lea    -0x1(%eax),%edx
80101227:	8b 45 08             	mov    0x8(%ebp),%eax
8010122a:	89 50 04             	mov    %edx,0x4(%eax)
8010122d:	8b 45 08             	mov    0x8(%ebp),%eax
80101230:	8b 40 04             	mov    0x4(%eax),%eax
80101233:	85 c0                	test   %eax,%eax
80101235:	7e 15                	jle    8010124c <fileclose+0x5f>
    release(&ftable.lock);
80101237:	83 ec 0c             	sub    $0xc,%esp
8010123a:	68 60 30 11 80       	push   $0x80113060
8010123f:	e8 a7 41 00 00       	call   801053eb <release>
80101244:	83 c4 10             	add    $0x10,%esp
80101247:	e9 8b 00 00 00       	jmp    801012d7 <fileclose+0xea>
    return;
  }
  ff = *f;
8010124c:	8b 45 08             	mov    0x8(%ebp),%eax
8010124f:	8b 10                	mov    (%eax),%edx
80101251:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101254:	8b 50 04             	mov    0x4(%eax),%edx
80101257:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010125a:	8b 50 08             	mov    0x8(%eax),%edx
8010125d:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101260:	8b 50 0c             	mov    0xc(%eax),%edx
80101263:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101266:	8b 50 10             	mov    0x10(%eax),%edx
80101269:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010126c:	8b 40 14             	mov    0x14(%eax),%eax
8010126f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101272:	8b 45 08             	mov    0x8(%ebp),%eax
80101275:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010127c:	8b 45 08             	mov    0x8(%ebp),%eax
8010127f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101285:	83 ec 0c             	sub    $0xc,%esp
80101288:	68 60 30 11 80       	push   $0x80113060
8010128d:	e8 59 41 00 00       	call   801053eb <release>
80101292:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101295:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101298:	83 f8 01             	cmp    $0x1,%eax
8010129b:	75 19                	jne    801012b6 <fileclose+0xc9>
    pipeclose(ff.pipe, ff.writable);
8010129d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801012a1:	0f be d0             	movsbl %al,%edx
801012a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012a7:	83 ec 08             	sub    $0x8,%esp
801012aa:	52                   	push   %edx
801012ab:	50                   	push   %eax
801012ac:	e8 e7 2e 00 00       	call   80104198 <pipeclose>
801012b1:	83 c4 10             	add    $0x10,%esp
801012b4:	eb 21                	jmp    801012d7 <fileclose+0xea>
  else if(ff.type == FD_INODE){
801012b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801012b9:	83 f8 02             	cmp    $0x2,%eax
801012bc:	75 19                	jne    801012d7 <fileclose+0xea>
    begin_op();
801012be:	e8 9f 24 00 00       	call   80103762 <begin_op>
    iput(ff.ip);
801012c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012c6:	83 ec 0c             	sub    $0xc,%esp
801012c9:	50                   	push   %eax
801012ca:	e8 07 0a 00 00       	call   80101cd6 <iput>
801012cf:	83 c4 10             	add    $0x10,%esp
    end_op();
801012d2:	e8 1b 25 00 00       	call   801037f2 <end_op>
  }
}
801012d7:	c9                   	leave  
801012d8:	c3                   	ret    

801012d9 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801012d9:	f3 0f 1e fb          	endbr32 
801012dd:	55                   	push   %ebp
801012de:	89 e5                	mov    %esp,%ebp
801012e0:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801012e3:	8b 45 08             	mov    0x8(%ebp),%eax
801012e6:	8b 00                	mov    (%eax),%eax
801012e8:	83 f8 02             	cmp    $0x2,%eax
801012eb:	75 40                	jne    8010132d <filestat+0x54>
    ilock(f->ip);
801012ed:	8b 45 08             	mov    0x8(%ebp),%eax
801012f0:	8b 40 10             	mov    0x10(%eax),%eax
801012f3:	83 ec 0c             	sub    $0xc,%esp
801012f6:	50                   	push   %eax
801012f7:	e8 71 08 00 00       	call   80101b6d <ilock>
801012fc:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801012ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101302:	8b 40 10             	mov    0x10(%eax),%eax
80101305:	83 ec 08             	sub    $0x8,%esp
80101308:	ff 75 0c             	pushl  0xc(%ebp)
8010130b:	50                   	push   %eax
8010130c:	e8 1a 0d 00 00       	call   8010202b <stati>
80101311:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101314:	8b 45 08             	mov    0x8(%ebp),%eax
80101317:	8b 40 10             	mov    0x10(%eax),%eax
8010131a:	83 ec 0c             	sub    $0xc,%esp
8010131d:	50                   	push   %eax
8010131e:	e8 61 09 00 00       	call   80101c84 <iunlock>
80101323:	83 c4 10             	add    $0x10,%esp
    return 0;
80101326:	b8 00 00 00 00       	mov    $0x0,%eax
8010132b:	eb 05                	jmp    80101332 <filestat+0x59>
  }
  return -1;
8010132d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101332:	c9                   	leave  
80101333:	c3                   	ret    

80101334 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101334:	f3 0f 1e fb          	endbr32 
80101338:	55                   	push   %ebp
80101339:	89 e5                	mov    %esp,%ebp
8010133b:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
8010133e:	8b 45 08             	mov    0x8(%ebp),%eax
80101341:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101345:	84 c0                	test   %al,%al
80101347:	75 0a                	jne    80101353 <fileread+0x1f>
    return -1;
80101349:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010134e:	e9 9b 00 00 00       	jmp    801013ee <fileread+0xba>
  if(f->type == FD_PIPE)
80101353:	8b 45 08             	mov    0x8(%ebp),%eax
80101356:	8b 00                	mov    (%eax),%eax
80101358:	83 f8 01             	cmp    $0x1,%eax
8010135b:	75 1a                	jne    80101377 <fileread+0x43>
    return piperead(f->pipe, addr, n);
8010135d:	8b 45 08             	mov    0x8(%ebp),%eax
80101360:	8b 40 0c             	mov    0xc(%eax),%eax
80101363:	83 ec 04             	sub    $0x4,%esp
80101366:	ff 75 10             	pushl  0x10(%ebp)
80101369:	ff 75 0c             	pushl  0xc(%ebp)
8010136c:	50                   	push   %eax
8010136d:	e8 db 2f 00 00       	call   8010434d <piperead>
80101372:	83 c4 10             	add    $0x10,%esp
80101375:	eb 77                	jmp    801013ee <fileread+0xba>
  if(f->type == FD_INODE){
80101377:	8b 45 08             	mov    0x8(%ebp),%eax
8010137a:	8b 00                	mov    (%eax),%eax
8010137c:	83 f8 02             	cmp    $0x2,%eax
8010137f:	75 60                	jne    801013e1 <fileread+0xad>
    ilock(f->ip);
80101381:	8b 45 08             	mov    0x8(%ebp),%eax
80101384:	8b 40 10             	mov    0x10(%eax),%eax
80101387:	83 ec 0c             	sub    $0xc,%esp
8010138a:	50                   	push   %eax
8010138b:	e8 dd 07 00 00       	call   80101b6d <ilock>
80101390:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101393:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101396:	8b 45 08             	mov    0x8(%ebp),%eax
80101399:	8b 50 14             	mov    0x14(%eax),%edx
8010139c:	8b 45 08             	mov    0x8(%ebp),%eax
8010139f:	8b 40 10             	mov    0x10(%eax),%eax
801013a2:	51                   	push   %ecx
801013a3:	52                   	push   %edx
801013a4:	ff 75 0c             	pushl  0xc(%ebp)
801013a7:	50                   	push   %eax
801013a8:	e8 c8 0c 00 00       	call   80102075 <readi>
801013ad:	83 c4 10             	add    $0x10,%esp
801013b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801013b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801013b7:	7e 11                	jle    801013ca <fileread+0x96>
      f->off += r;
801013b9:	8b 45 08             	mov    0x8(%ebp),%eax
801013bc:	8b 50 14             	mov    0x14(%eax),%edx
801013bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013c2:	01 c2                	add    %eax,%edx
801013c4:	8b 45 08             	mov    0x8(%ebp),%eax
801013c7:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801013ca:	8b 45 08             	mov    0x8(%ebp),%eax
801013cd:	8b 40 10             	mov    0x10(%eax),%eax
801013d0:	83 ec 0c             	sub    $0xc,%esp
801013d3:	50                   	push   %eax
801013d4:	e8 ab 08 00 00       	call   80101c84 <iunlock>
801013d9:	83 c4 10             	add    $0x10,%esp
    return r;
801013dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013df:	eb 0d                	jmp    801013ee <fileread+0xba>
  }
  panic("fileread");
801013e1:	83 ec 0c             	sub    $0xc,%esp
801013e4:	68 ba 95 10 80       	push   $0x801095ba
801013e9:	e8 1a f2 ff ff       	call   80100608 <panic>
}
801013ee:	c9                   	leave  
801013ef:	c3                   	ret    

801013f0 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801013f0:	f3 0f 1e fb          	endbr32 
801013f4:	55                   	push   %ebp
801013f5:	89 e5                	mov    %esp,%ebp
801013f7:	53                   	push   %ebx
801013f8:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801013fb:	8b 45 08             	mov    0x8(%ebp),%eax
801013fe:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101402:	84 c0                	test   %al,%al
80101404:	75 0a                	jne    80101410 <filewrite+0x20>
    return -1;
80101406:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010140b:	e9 1b 01 00 00       	jmp    8010152b <filewrite+0x13b>
  if(f->type == FD_PIPE)
80101410:	8b 45 08             	mov    0x8(%ebp),%eax
80101413:	8b 00                	mov    (%eax),%eax
80101415:	83 f8 01             	cmp    $0x1,%eax
80101418:	75 1d                	jne    80101437 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
8010141a:	8b 45 08             	mov    0x8(%ebp),%eax
8010141d:	8b 40 0c             	mov    0xc(%eax),%eax
80101420:	83 ec 04             	sub    $0x4,%esp
80101423:	ff 75 10             	pushl  0x10(%ebp)
80101426:	ff 75 0c             	pushl  0xc(%ebp)
80101429:	50                   	push   %eax
8010142a:	e8 18 2e 00 00       	call   80104247 <pipewrite>
8010142f:	83 c4 10             	add    $0x10,%esp
80101432:	e9 f4 00 00 00       	jmp    8010152b <filewrite+0x13b>
  if(f->type == FD_INODE){
80101437:	8b 45 08             	mov    0x8(%ebp),%eax
8010143a:	8b 00                	mov    (%eax),%eax
8010143c:	83 f8 02             	cmp    $0x2,%eax
8010143f:	0f 85 d9 00 00 00    	jne    8010151e <filewrite+0x12e>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
80101445:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
8010144c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101453:	e9 a3 00 00 00       	jmp    801014fb <filewrite+0x10b>
      int n1 = n - i;
80101458:	8b 45 10             	mov    0x10(%ebp),%eax
8010145b:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010145e:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101461:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101464:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101467:	7e 06                	jle    8010146f <filewrite+0x7f>
        n1 = max;
80101469:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010146c:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010146f:	e8 ee 22 00 00       	call   80103762 <begin_op>
      ilock(f->ip);
80101474:	8b 45 08             	mov    0x8(%ebp),%eax
80101477:	8b 40 10             	mov    0x10(%eax),%eax
8010147a:	83 ec 0c             	sub    $0xc,%esp
8010147d:	50                   	push   %eax
8010147e:	e8 ea 06 00 00       	call   80101b6d <ilock>
80101483:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101486:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101489:	8b 45 08             	mov    0x8(%ebp),%eax
8010148c:	8b 50 14             	mov    0x14(%eax),%edx
8010148f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101492:	8b 45 0c             	mov    0xc(%ebp),%eax
80101495:	01 c3                	add    %eax,%ebx
80101497:	8b 45 08             	mov    0x8(%ebp),%eax
8010149a:	8b 40 10             	mov    0x10(%eax),%eax
8010149d:	51                   	push   %ecx
8010149e:	52                   	push   %edx
8010149f:	53                   	push   %ebx
801014a0:	50                   	push   %eax
801014a1:	e8 28 0d 00 00       	call   801021ce <writei>
801014a6:	83 c4 10             	add    $0x10,%esp
801014a9:	89 45 e8             	mov    %eax,-0x18(%ebp)
801014ac:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801014b0:	7e 11                	jle    801014c3 <filewrite+0xd3>
        f->off += r;
801014b2:	8b 45 08             	mov    0x8(%ebp),%eax
801014b5:	8b 50 14             	mov    0x14(%eax),%edx
801014b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801014bb:	01 c2                	add    %eax,%edx
801014bd:	8b 45 08             	mov    0x8(%ebp),%eax
801014c0:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801014c3:	8b 45 08             	mov    0x8(%ebp),%eax
801014c6:	8b 40 10             	mov    0x10(%eax),%eax
801014c9:	83 ec 0c             	sub    $0xc,%esp
801014cc:	50                   	push   %eax
801014cd:	e8 b2 07 00 00       	call   80101c84 <iunlock>
801014d2:	83 c4 10             	add    $0x10,%esp
      end_op();
801014d5:	e8 18 23 00 00       	call   801037f2 <end_op>

      if(r < 0)
801014da:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801014de:	78 29                	js     80101509 <filewrite+0x119>
        break;
      if(r != n1)
801014e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801014e3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801014e6:	74 0d                	je     801014f5 <filewrite+0x105>
        panic("short filewrite");
801014e8:	83 ec 0c             	sub    $0xc,%esp
801014eb:	68 c3 95 10 80       	push   $0x801095c3
801014f0:	e8 13 f1 ff ff       	call   80100608 <panic>
      i += r;
801014f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801014f8:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
801014fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014fe:	3b 45 10             	cmp    0x10(%ebp),%eax
80101501:	0f 8c 51 ff ff ff    	jl     80101458 <filewrite+0x68>
80101507:	eb 01                	jmp    8010150a <filewrite+0x11a>
        break;
80101509:	90                   	nop
    }
    return i == n ? n : -1;
8010150a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010150d:	3b 45 10             	cmp    0x10(%ebp),%eax
80101510:	75 05                	jne    80101517 <filewrite+0x127>
80101512:	8b 45 10             	mov    0x10(%ebp),%eax
80101515:	eb 14                	jmp    8010152b <filewrite+0x13b>
80101517:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010151c:	eb 0d                	jmp    8010152b <filewrite+0x13b>
  }
  panic("filewrite");
8010151e:	83 ec 0c             	sub    $0xc,%esp
80101521:	68 d3 95 10 80       	push   $0x801095d3
80101526:	e8 dd f0 ff ff       	call   80100608 <panic>
}
8010152b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010152e:	c9                   	leave  
8010152f:	c3                   	ret    

80101530 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101530:	f3 0f 1e fb          	endbr32 
80101534:	55                   	push   %ebp
80101535:	89 e5                	mov    %esp,%ebp
80101537:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
8010153a:	8b 45 08             	mov    0x8(%ebp),%eax
8010153d:	83 ec 08             	sub    $0x8,%esp
80101540:	6a 01                	push   $0x1
80101542:	50                   	push   %eax
80101543:	e8 8f ec ff ff       	call   801001d7 <bread>
80101548:	83 c4 10             	add    $0x10,%esp
8010154b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010154e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101551:	83 c0 5c             	add    $0x5c,%eax
80101554:	83 ec 04             	sub    $0x4,%esp
80101557:	6a 1c                	push   $0x1c
80101559:	50                   	push   %eax
8010155a:	ff 75 0c             	pushl  0xc(%ebp)
8010155d:	e8 7d 41 00 00       	call   801056df <memmove>
80101562:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101565:	83 ec 0c             	sub    $0xc,%esp
80101568:	ff 75 f4             	pushl  -0xc(%ebp)
8010156b:	e8 f1 ec ff ff       	call   80100261 <brelse>
80101570:	83 c4 10             	add    $0x10,%esp
}
80101573:	90                   	nop
80101574:	c9                   	leave  
80101575:	c3                   	ret    

80101576 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101576:	f3 0f 1e fb          	endbr32 
8010157a:	55                   	push   %ebp
8010157b:	89 e5                	mov    %esp,%ebp
8010157d:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101580:	8b 55 0c             	mov    0xc(%ebp),%edx
80101583:	8b 45 08             	mov    0x8(%ebp),%eax
80101586:	83 ec 08             	sub    $0x8,%esp
80101589:	52                   	push   %edx
8010158a:	50                   	push   %eax
8010158b:	e8 47 ec ff ff       	call   801001d7 <bread>
80101590:	83 c4 10             	add    $0x10,%esp
80101593:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101596:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101599:	83 c0 5c             	add    $0x5c,%eax
8010159c:	83 ec 04             	sub    $0x4,%esp
8010159f:	68 00 02 00 00       	push   $0x200
801015a4:	6a 00                	push   $0x0
801015a6:	50                   	push   %eax
801015a7:	e8 6c 40 00 00       	call   80105618 <memset>
801015ac:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801015af:	83 ec 0c             	sub    $0xc,%esp
801015b2:	ff 75 f4             	pushl  -0xc(%ebp)
801015b5:	e8 f1 23 00 00       	call   801039ab <log_write>
801015ba:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801015bd:	83 ec 0c             	sub    $0xc,%esp
801015c0:	ff 75 f4             	pushl  -0xc(%ebp)
801015c3:	e8 99 ec ff ff       	call   80100261 <brelse>
801015c8:	83 c4 10             	add    $0x10,%esp
}
801015cb:	90                   	nop
801015cc:	c9                   	leave  
801015cd:	c3                   	ret    

801015ce <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801015ce:	f3 0f 1e fb          	endbr32 
801015d2:	55                   	push   %ebp
801015d3:	89 e5                	mov    %esp,%ebp
801015d5:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801015d8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801015df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801015e6:	e9 13 01 00 00       	jmp    801016fe <balloc+0x130>
    bp = bread(dev, BBLOCK(b, sb));
801015eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015ee:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801015f4:	85 c0                	test   %eax,%eax
801015f6:	0f 48 c2             	cmovs  %edx,%eax
801015f9:	c1 f8 0c             	sar    $0xc,%eax
801015fc:	89 c2                	mov    %eax,%edx
801015fe:	a1 78 3a 11 80       	mov    0x80113a78,%eax
80101603:	01 d0                	add    %edx,%eax
80101605:	83 ec 08             	sub    $0x8,%esp
80101608:	50                   	push   %eax
80101609:	ff 75 08             	pushl  0x8(%ebp)
8010160c:	e8 c6 eb ff ff       	call   801001d7 <bread>
80101611:	83 c4 10             	add    $0x10,%esp
80101614:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101617:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010161e:	e9 a6 00 00 00       	jmp    801016c9 <balloc+0xfb>
      m = 1 << (bi % 8);
80101623:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101626:	99                   	cltd   
80101627:	c1 ea 1d             	shr    $0x1d,%edx
8010162a:	01 d0                	add    %edx,%eax
8010162c:	83 e0 07             	and    $0x7,%eax
8010162f:	29 d0                	sub    %edx,%eax
80101631:	ba 01 00 00 00       	mov    $0x1,%edx
80101636:	89 c1                	mov    %eax,%ecx
80101638:	d3 e2                	shl    %cl,%edx
8010163a:	89 d0                	mov    %edx,%eax
8010163c:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010163f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101642:	8d 50 07             	lea    0x7(%eax),%edx
80101645:	85 c0                	test   %eax,%eax
80101647:	0f 48 c2             	cmovs  %edx,%eax
8010164a:	c1 f8 03             	sar    $0x3,%eax
8010164d:	89 c2                	mov    %eax,%edx
8010164f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101652:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101657:	0f b6 c0             	movzbl %al,%eax
8010165a:	23 45 e8             	and    -0x18(%ebp),%eax
8010165d:	85 c0                	test   %eax,%eax
8010165f:	75 64                	jne    801016c5 <balloc+0xf7>
        bp->data[bi/8] |= m;  // Mark block in use.
80101661:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101664:	8d 50 07             	lea    0x7(%eax),%edx
80101667:	85 c0                	test   %eax,%eax
80101669:	0f 48 c2             	cmovs  %edx,%eax
8010166c:	c1 f8 03             	sar    $0x3,%eax
8010166f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101672:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101677:	89 d1                	mov    %edx,%ecx
80101679:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010167c:	09 ca                	or     %ecx,%edx
8010167e:	89 d1                	mov    %edx,%ecx
80101680:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101683:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101687:	83 ec 0c             	sub    $0xc,%esp
8010168a:	ff 75 ec             	pushl  -0x14(%ebp)
8010168d:	e8 19 23 00 00       	call   801039ab <log_write>
80101692:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101695:	83 ec 0c             	sub    $0xc,%esp
80101698:	ff 75 ec             	pushl  -0x14(%ebp)
8010169b:	e8 c1 eb ff ff       	call   80100261 <brelse>
801016a0:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
801016a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016a9:	01 c2                	add    %eax,%edx
801016ab:	8b 45 08             	mov    0x8(%ebp),%eax
801016ae:	83 ec 08             	sub    $0x8,%esp
801016b1:	52                   	push   %edx
801016b2:	50                   	push   %eax
801016b3:	e8 be fe ff ff       	call   80101576 <bzero>
801016b8:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801016bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016c1:	01 d0                	add    %edx,%eax
801016c3:	eb 57                	jmp    8010171c <balloc+0x14e>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801016c5:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801016c9:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801016d0:	7f 17                	jg     801016e9 <balloc+0x11b>
801016d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016d8:	01 d0                	add    %edx,%eax
801016da:	89 c2                	mov    %eax,%edx
801016dc:	a1 60 3a 11 80       	mov    0x80113a60,%eax
801016e1:	39 c2                	cmp    %eax,%edx
801016e3:	0f 82 3a ff ff ff    	jb     80101623 <balloc+0x55>
      }
    }
    brelse(bp);
801016e9:	83 ec 0c             	sub    $0xc,%esp
801016ec:	ff 75 ec             	pushl  -0x14(%ebp)
801016ef:	e8 6d eb ff ff       	call   80100261 <brelse>
801016f4:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
801016f7:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801016fe:	8b 15 60 3a 11 80    	mov    0x80113a60,%edx
80101704:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101707:	39 c2                	cmp    %eax,%edx
80101709:	0f 87 dc fe ff ff    	ja     801015eb <balloc+0x1d>
  }
  panic("balloc: out of blocks");
8010170f:	83 ec 0c             	sub    $0xc,%esp
80101712:	68 e0 95 10 80       	push   $0x801095e0
80101717:	e8 ec ee ff ff       	call   80100608 <panic>
}
8010171c:	c9                   	leave  
8010171d:	c3                   	ret    

8010171e <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010171e:	f3 0f 1e fb          	endbr32 
80101722:	55                   	push   %ebp
80101723:	89 e5                	mov    %esp,%ebp
80101725:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
80101728:	8b 45 0c             	mov    0xc(%ebp),%eax
8010172b:	c1 e8 0c             	shr    $0xc,%eax
8010172e:	89 c2                	mov    %eax,%edx
80101730:	a1 78 3a 11 80       	mov    0x80113a78,%eax
80101735:	01 c2                	add    %eax,%edx
80101737:	8b 45 08             	mov    0x8(%ebp),%eax
8010173a:	83 ec 08             	sub    $0x8,%esp
8010173d:	52                   	push   %edx
8010173e:	50                   	push   %eax
8010173f:	e8 93 ea ff ff       	call   801001d7 <bread>
80101744:	83 c4 10             	add    $0x10,%esp
80101747:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
8010174a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010174d:	25 ff 0f 00 00       	and    $0xfff,%eax
80101752:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101755:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101758:	99                   	cltd   
80101759:	c1 ea 1d             	shr    $0x1d,%edx
8010175c:	01 d0                	add    %edx,%eax
8010175e:	83 e0 07             	and    $0x7,%eax
80101761:	29 d0                	sub    %edx,%eax
80101763:	ba 01 00 00 00       	mov    $0x1,%edx
80101768:	89 c1                	mov    %eax,%ecx
8010176a:	d3 e2                	shl    %cl,%edx
8010176c:	89 d0                	mov    %edx,%eax
8010176e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101771:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101774:	8d 50 07             	lea    0x7(%eax),%edx
80101777:	85 c0                	test   %eax,%eax
80101779:	0f 48 c2             	cmovs  %edx,%eax
8010177c:	c1 f8 03             	sar    $0x3,%eax
8010177f:	89 c2                	mov    %eax,%edx
80101781:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101784:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101789:	0f b6 c0             	movzbl %al,%eax
8010178c:	23 45 ec             	and    -0x14(%ebp),%eax
8010178f:	85 c0                	test   %eax,%eax
80101791:	75 0d                	jne    801017a0 <bfree+0x82>
    panic("freeing free block");
80101793:	83 ec 0c             	sub    $0xc,%esp
80101796:	68 f6 95 10 80       	push   $0x801095f6
8010179b:	e8 68 ee ff ff       	call   80100608 <panic>
  bp->data[bi/8] &= ~m;
801017a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017a3:	8d 50 07             	lea    0x7(%eax),%edx
801017a6:	85 c0                	test   %eax,%eax
801017a8:	0f 48 c2             	cmovs  %edx,%eax
801017ab:	c1 f8 03             	sar    $0x3,%eax
801017ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017b1:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801017b6:	89 d1                	mov    %edx,%ecx
801017b8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801017bb:	f7 d2                	not    %edx
801017bd:	21 ca                	and    %ecx,%edx
801017bf:	89 d1                	mov    %edx,%ecx
801017c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017c4:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
801017c8:	83 ec 0c             	sub    $0xc,%esp
801017cb:	ff 75 f4             	pushl  -0xc(%ebp)
801017ce:	e8 d8 21 00 00       	call   801039ab <log_write>
801017d3:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801017d6:	83 ec 0c             	sub    $0xc,%esp
801017d9:	ff 75 f4             	pushl  -0xc(%ebp)
801017dc:	e8 80 ea ff ff       	call   80100261 <brelse>
801017e1:	83 c4 10             	add    $0x10,%esp
}
801017e4:	90                   	nop
801017e5:	c9                   	leave  
801017e6:	c3                   	ret    

801017e7 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801017e7:	f3 0f 1e fb          	endbr32 
801017eb:	55                   	push   %ebp
801017ec:	89 e5                	mov    %esp,%ebp
801017ee:	57                   	push   %edi
801017ef:	56                   	push   %esi
801017f0:	53                   	push   %ebx
801017f1:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
801017f4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
801017fb:	83 ec 08             	sub    $0x8,%esp
801017fe:	68 09 96 10 80       	push   $0x80109609
80101803:	68 80 3a 11 80       	push   $0x80113a80
80101808:	e8 46 3b 00 00       	call   80105353 <initlock>
8010180d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101810:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101817:	eb 2d                	jmp    80101846 <iinit+0x5f>
    initsleeplock(&icache.inode[i].lock, "inode");
80101819:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010181c:	89 d0                	mov    %edx,%eax
8010181e:	c1 e0 03             	shl    $0x3,%eax
80101821:	01 d0                	add    %edx,%eax
80101823:	c1 e0 04             	shl    $0x4,%eax
80101826:	83 c0 30             	add    $0x30,%eax
80101829:	05 80 3a 11 80       	add    $0x80113a80,%eax
8010182e:	83 c0 10             	add    $0x10,%eax
80101831:	83 ec 08             	sub    $0x8,%esp
80101834:	68 10 96 10 80       	push   $0x80109610
80101839:	50                   	push   %eax
8010183a:	e8 81 39 00 00       	call   801051c0 <initsleeplock>
8010183f:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101842:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101846:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
8010184a:	7e cd                	jle    80101819 <iinit+0x32>
  }

  readsb(dev, &sb);
8010184c:	83 ec 08             	sub    $0x8,%esp
8010184f:	68 60 3a 11 80       	push   $0x80113a60
80101854:	ff 75 08             	pushl  0x8(%ebp)
80101857:	e8 d4 fc ff ff       	call   80101530 <readsb>
8010185c:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
8010185f:	a1 78 3a 11 80       	mov    0x80113a78,%eax
80101864:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101867:	8b 3d 74 3a 11 80    	mov    0x80113a74,%edi
8010186d:	8b 35 70 3a 11 80    	mov    0x80113a70,%esi
80101873:	8b 1d 6c 3a 11 80    	mov    0x80113a6c,%ebx
80101879:	8b 0d 68 3a 11 80    	mov    0x80113a68,%ecx
8010187f:	8b 15 64 3a 11 80    	mov    0x80113a64,%edx
80101885:	a1 60 3a 11 80       	mov    0x80113a60,%eax
8010188a:	ff 75 d4             	pushl  -0x2c(%ebp)
8010188d:	57                   	push   %edi
8010188e:	56                   	push   %esi
8010188f:	53                   	push   %ebx
80101890:	51                   	push   %ecx
80101891:	52                   	push   %edx
80101892:	50                   	push   %eax
80101893:	68 18 96 10 80       	push   $0x80109618
80101898:	e8 7b eb ff ff       	call   80100418 <cprintf>
8010189d:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
801018a0:	90                   	nop
801018a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801018a4:	5b                   	pop    %ebx
801018a5:	5e                   	pop    %esi
801018a6:	5f                   	pop    %edi
801018a7:	5d                   	pop    %ebp
801018a8:	c3                   	ret    

801018a9 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
801018a9:	f3 0f 1e fb          	endbr32 
801018ad:	55                   	push   %ebp
801018ae:	89 e5                	mov    %esp,%ebp
801018b0:	83 ec 28             	sub    $0x28,%esp
801018b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801018b6:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801018ba:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801018c1:	e9 9e 00 00 00       	jmp    80101964 <ialloc+0xbb>
    bp = bread(dev, IBLOCK(inum, sb));
801018c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c9:	c1 e8 03             	shr    $0x3,%eax
801018cc:	89 c2                	mov    %eax,%edx
801018ce:	a1 74 3a 11 80       	mov    0x80113a74,%eax
801018d3:	01 d0                	add    %edx,%eax
801018d5:	83 ec 08             	sub    $0x8,%esp
801018d8:	50                   	push   %eax
801018d9:	ff 75 08             	pushl  0x8(%ebp)
801018dc:	e8 f6 e8 ff ff       	call   801001d7 <bread>
801018e1:	83 c4 10             	add    $0x10,%esp
801018e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801018e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018ea:	8d 50 5c             	lea    0x5c(%eax),%edx
801018ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f0:	83 e0 07             	and    $0x7,%eax
801018f3:	c1 e0 06             	shl    $0x6,%eax
801018f6:	01 d0                	add    %edx,%eax
801018f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801018fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018fe:	0f b7 00             	movzwl (%eax),%eax
80101901:	66 85 c0             	test   %ax,%ax
80101904:	75 4c                	jne    80101952 <ialloc+0xa9>
      memset(dip, 0, sizeof(*dip));
80101906:	83 ec 04             	sub    $0x4,%esp
80101909:	6a 40                	push   $0x40
8010190b:	6a 00                	push   $0x0
8010190d:	ff 75 ec             	pushl  -0x14(%ebp)
80101910:	e8 03 3d 00 00       	call   80105618 <memset>
80101915:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101918:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010191b:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010191f:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101922:	83 ec 0c             	sub    $0xc,%esp
80101925:	ff 75 f0             	pushl  -0x10(%ebp)
80101928:	e8 7e 20 00 00       	call   801039ab <log_write>
8010192d:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
80101930:	83 ec 0c             	sub    $0xc,%esp
80101933:	ff 75 f0             	pushl  -0x10(%ebp)
80101936:	e8 26 e9 ff ff       	call   80100261 <brelse>
8010193b:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
8010193e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101941:	83 ec 08             	sub    $0x8,%esp
80101944:	50                   	push   %eax
80101945:	ff 75 08             	pushl  0x8(%ebp)
80101948:	e8 fc 00 00 00       	call   80101a49 <iget>
8010194d:	83 c4 10             	add    $0x10,%esp
80101950:	eb 30                	jmp    80101982 <ialloc+0xd9>
    }
    brelse(bp);
80101952:	83 ec 0c             	sub    $0xc,%esp
80101955:	ff 75 f0             	pushl  -0x10(%ebp)
80101958:	e8 04 e9 ff ff       	call   80100261 <brelse>
8010195d:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
80101960:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101964:	8b 15 68 3a 11 80    	mov    0x80113a68,%edx
8010196a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010196d:	39 c2                	cmp    %eax,%edx
8010196f:	0f 87 51 ff ff ff    	ja     801018c6 <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
80101975:	83 ec 0c             	sub    $0xc,%esp
80101978:	68 6b 96 10 80       	push   $0x8010966b
8010197d:	e8 86 ec ff ff       	call   80100608 <panic>
}
80101982:	c9                   	leave  
80101983:	c3                   	ret    

80101984 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101984:	f3 0f 1e fb          	endbr32 
80101988:	55                   	push   %ebp
80101989:	89 e5                	mov    %esp,%ebp
8010198b:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010198e:	8b 45 08             	mov    0x8(%ebp),%eax
80101991:	8b 40 04             	mov    0x4(%eax),%eax
80101994:	c1 e8 03             	shr    $0x3,%eax
80101997:	89 c2                	mov    %eax,%edx
80101999:	a1 74 3a 11 80       	mov    0x80113a74,%eax
8010199e:	01 c2                	add    %eax,%edx
801019a0:	8b 45 08             	mov    0x8(%ebp),%eax
801019a3:	8b 00                	mov    (%eax),%eax
801019a5:	83 ec 08             	sub    $0x8,%esp
801019a8:	52                   	push   %edx
801019a9:	50                   	push   %eax
801019aa:	e8 28 e8 ff ff       	call   801001d7 <bread>
801019af:	83 c4 10             	add    $0x10,%esp
801019b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801019b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019b8:	8d 50 5c             	lea    0x5c(%eax),%edx
801019bb:	8b 45 08             	mov    0x8(%ebp),%eax
801019be:	8b 40 04             	mov    0x4(%eax),%eax
801019c1:	83 e0 07             	and    $0x7,%eax
801019c4:	c1 e0 06             	shl    $0x6,%eax
801019c7:	01 d0                	add    %edx,%eax
801019c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801019cc:	8b 45 08             	mov    0x8(%ebp),%eax
801019cf:	0f b7 50 50          	movzwl 0x50(%eax),%edx
801019d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019d6:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801019d9:	8b 45 08             	mov    0x8(%ebp),%eax
801019dc:	0f b7 50 52          	movzwl 0x52(%eax),%edx
801019e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019e3:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801019e7:	8b 45 08             	mov    0x8(%ebp),%eax
801019ea:	0f b7 50 54          	movzwl 0x54(%eax),%edx
801019ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019f1:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801019f5:	8b 45 08             	mov    0x8(%ebp),%eax
801019f8:	0f b7 50 56          	movzwl 0x56(%eax),%edx
801019fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019ff:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101a03:	8b 45 08             	mov    0x8(%ebp),%eax
80101a06:	8b 50 58             	mov    0x58(%eax),%edx
80101a09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a0c:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101a0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a12:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a18:	83 c0 0c             	add    $0xc,%eax
80101a1b:	83 ec 04             	sub    $0x4,%esp
80101a1e:	6a 34                	push   $0x34
80101a20:	52                   	push   %edx
80101a21:	50                   	push   %eax
80101a22:	e8 b8 3c 00 00       	call   801056df <memmove>
80101a27:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101a2a:	83 ec 0c             	sub    $0xc,%esp
80101a2d:	ff 75 f4             	pushl  -0xc(%ebp)
80101a30:	e8 76 1f 00 00       	call   801039ab <log_write>
80101a35:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101a38:	83 ec 0c             	sub    $0xc,%esp
80101a3b:	ff 75 f4             	pushl  -0xc(%ebp)
80101a3e:	e8 1e e8 ff ff       	call   80100261 <brelse>
80101a43:	83 c4 10             	add    $0x10,%esp
}
80101a46:	90                   	nop
80101a47:	c9                   	leave  
80101a48:	c3                   	ret    

80101a49 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101a49:	f3 0f 1e fb          	endbr32 
80101a4d:	55                   	push   %ebp
80101a4e:	89 e5                	mov    %esp,%ebp
80101a50:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101a53:	83 ec 0c             	sub    $0xc,%esp
80101a56:	68 80 3a 11 80       	push   $0x80113a80
80101a5b:	e8 19 39 00 00       	call   80105379 <acquire>
80101a60:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101a63:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a6a:	c7 45 f4 b4 3a 11 80 	movl   $0x80113ab4,-0xc(%ebp)
80101a71:	eb 60                	jmp    80101ad3 <iget+0x8a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a76:	8b 40 08             	mov    0x8(%eax),%eax
80101a79:	85 c0                	test   %eax,%eax
80101a7b:	7e 39                	jle    80101ab6 <iget+0x6d>
80101a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a80:	8b 00                	mov    (%eax),%eax
80101a82:	39 45 08             	cmp    %eax,0x8(%ebp)
80101a85:	75 2f                	jne    80101ab6 <iget+0x6d>
80101a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a8a:	8b 40 04             	mov    0x4(%eax),%eax
80101a8d:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101a90:	75 24                	jne    80101ab6 <iget+0x6d>
      ip->ref++;
80101a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a95:	8b 40 08             	mov    0x8(%eax),%eax
80101a98:	8d 50 01             	lea    0x1(%eax),%edx
80101a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a9e:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101aa1:	83 ec 0c             	sub    $0xc,%esp
80101aa4:	68 80 3a 11 80       	push   $0x80113a80
80101aa9:	e8 3d 39 00 00       	call   801053eb <release>
80101aae:	83 c4 10             	add    $0x10,%esp
      return ip;
80101ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ab4:	eb 77                	jmp    80101b2d <iget+0xe4>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101ab6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101aba:	75 10                	jne    80101acc <iget+0x83>
80101abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101abf:	8b 40 08             	mov    0x8(%eax),%eax
80101ac2:	85 c0                	test   %eax,%eax
80101ac4:	75 06                	jne    80101acc <iget+0x83>
      empty = ip;
80101ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ac9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101acc:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101ad3:	81 7d f4 d4 56 11 80 	cmpl   $0x801156d4,-0xc(%ebp)
80101ada:	72 97                	jb     80101a73 <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101adc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101ae0:	75 0d                	jne    80101aef <iget+0xa6>
    panic("iget: no inodes");
80101ae2:	83 ec 0c             	sub    $0xc,%esp
80101ae5:	68 7d 96 10 80       	push   $0x8010967d
80101aea:	e8 19 eb ff ff       	call   80100608 <panic>

  ip = empty;
80101aef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101af2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101af8:	8b 55 08             	mov    0x8(%ebp),%edx
80101afb:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b00:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b03:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b09:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b13:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101b1a:	83 ec 0c             	sub    $0xc,%esp
80101b1d:	68 80 3a 11 80       	push   $0x80113a80
80101b22:	e8 c4 38 00 00       	call   801053eb <release>
80101b27:	83 c4 10             	add    $0x10,%esp

  return ip;
80101b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101b2d:	c9                   	leave  
80101b2e:	c3                   	ret    

80101b2f <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101b2f:	f3 0f 1e fb          	endbr32 
80101b33:	55                   	push   %ebp
80101b34:	89 e5                	mov    %esp,%ebp
80101b36:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101b39:	83 ec 0c             	sub    $0xc,%esp
80101b3c:	68 80 3a 11 80       	push   $0x80113a80
80101b41:	e8 33 38 00 00       	call   80105379 <acquire>
80101b46:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101b49:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4c:	8b 40 08             	mov    0x8(%eax),%eax
80101b4f:	8d 50 01             	lea    0x1(%eax),%edx
80101b52:	8b 45 08             	mov    0x8(%ebp),%eax
80101b55:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b58:	83 ec 0c             	sub    $0xc,%esp
80101b5b:	68 80 3a 11 80       	push   $0x80113a80
80101b60:	e8 86 38 00 00       	call   801053eb <release>
80101b65:	83 c4 10             	add    $0x10,%esp
  return ip;
80101b68:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101b6b:	c9                   	leave  
80101b6c:	c3                   	ret    

80101b6d <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101b6d:	f3 0f 1e fb          	endbr32 
80101b71:	55                   	push   %ebp
80101b72:	89 e5                	mov    %esp,%ebp
80101b74:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101b77:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b7b:	74 0a                	je     80101b87 <ilock+0x1a>
80101b7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b80:	8b 40 08             	mov    0x8(%eax),%eax
80101b83:	85 c0                	test   %eax,%eax
80101b85:	7f 0d                	jg     80101b94 <ilock+0x27>
    panic("ilock");
80101b87:	83 ec 0c             	sub    $0xc,%esp
80101b8a:	68 8d 96 10 80       	push   $0x8010968d
80101b8f:	e8 74 ea ff ff       	call   80100608 <panic>

  acquiresleep(&ip->lock);
80101b94:	8b 45 08             	mov    0x8(%ebp),%eax
80101b97:	83 c0 0c             	add    $0xc,%eax
80101b9a:	83 ec 0c             	sub    $0xc,%esp
80101b9d:	50                   	push   %eax
80101b9e:	e8 5d 36 00 00       	call   80105200 <acquiresleep>
80101ba3:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101ba6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba9:	8b 40 4c             	mov    0x4c(%eax),%eax
80101bac:	85 c0                	test   %eax,%eax
80101bae:	0f 85 cd 00 00 00    	jne    80101c81 <ilock+0x114>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101bb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb7:	8b 40 04             	mov    0x4(%eax),%eax
80101bba:	c1 e8 03             	shr    $0x3,%eax
80101bbd:	89 c2                	mov    %eax,%edx
80101bbf:	a1 74 3a 11 80       	mov    0x80113a74,%eax
80101bc4:	01 c2                	add    %eax,%edx
80101bc6:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc9:	8b 00                	mov    (%eax),%eax
80101bcb:	83 ec 08             	sub    $0x8,%esp
80101bce:	52                   	push   %edx
80101bcf:	50                   	push   %eax
80101bd0:	e8 02 e6 ff ff       	call   801001d7 <bread>
80101bd5:	83 c4 10             	add    $0x10,%esp
80101bd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bde:	8d 50 5c             	lea    0x5c(%eax),%edx
80101be1:	8b 45 08             	mov    0x8(%ebp),%eax
80101be4:	8b 40 04             	mov    0x4(%eax),%eax
80101be7:	83 e0 07             	and    $0x7,%eax
80101bea:	c1 e0 06             	shl    $0x6,%eax
80101bed:	01 d0                	add    %edx,%eax
80101bef:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101bf2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bf5:	0f b7 10             	movzwl (%eax),%edx
80101bf8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfb:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101bff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c02:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101c06:	8b 45 08             	mov    0x8(%ebp),%eax
80101c09:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101c0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c10:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101c14:	8b 45 08             	mov    0x8(%ebp),%eax
80101c17:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101c1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c1e:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101c22:	8b 45 08             	mov    0x8(%ebp),%eax
80101c25:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101c29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c2c:	8b 50 08             	mov    0x8(%eax),%edx
80101c2f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c32:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101c35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c38:	8d 50 0c             	lea    0xc(%eax),%edx
80101c3b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3e:	83 c0 5c             	add    $0x5c,%eax
80101c41:	83 ec 04             	sub    $0x4,%esp
80101c44:	6a 34                	push   $0x34
80101c46:	52                   	push   %edx
80101c47:	50                   	push   %eax
80101c48:	e8 92 3a 00 00       	call   801056df <memmove>
80101c4d:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101c50:	83 ec 0c             	sub    $0xc,%esp
80101c53:	ff 75 f4             	pushl  -0xc(%ebp)
80101c56:	e8 06 e6 ff ff       	call   80100261 <brelse>
80101c5b:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101c5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c61:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101c68:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6b:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101c6f:	66 85 c0             	test   %ax,%ax
80101c72:	75 0d                	jne    80101c81 <ilock+0x114>
      panic("ilock: no type");
80101c74:	83 ec 0c             	sub    $0xc,%esp
80101c77:	68 93 96 10 80       	push   $0x80109693
80101c7c:	e8 87 e9 ff ff       	call   80100608 <panic>
  }
}
80101c81:	90                   	nop
80101c82:	c9                   	leave  
80101c83:	c3                   	ret    

80101c84 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101c84:	f3 0f 1e fb          	endbr32 
80101c88:	55                   	push   %ebp
80101c89:	89 e5                	mov    %esp,%ebp
80101c8b:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101c8e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101c92:	74 20                	je     80101cb4 <iunlock+0x30>
80101c94:	8b 45 08             	mov    0x8(%ebp),%eax
80101c97:	83 c0 0c             	add    $0xc,%eax
80101c9a:	83 ec 0c             	sub    $0xc,%esp
80101c9d:	50                   	push   %eax
80101c9e:	e8 17 36 00 00       	call   801052ba <holdingsleep>
80101ca3:	83 c4 10             	add    $0x10,%esp
80101ca6:	85 c0                	test   %eax,%eax
80101ca8:	74 0a                	je     80101cb4 <iunlock+0x30>
80101caa:	8b 45 08             	mov    0x8(%ebp),%eax
80101cad:	8b 40 08             	mov    0x8(%eax),%eax
80101cb0:	85 c0                	test   %eax,%eax
80101cb2:	7f 0d                	jg     80101cc1 <iunlock+0x3d>
    panic("iunlock");
80101cb4:	83 ec 0c             	sub    $0xc,%esp
80101cb7:	68 a2 96 10 80       	push   $0x801096a2
80101cbc:	e8 47 e9 ff ff       	call   80100608 <panic>

  releasesleep(&ip->lock);
80101cc1:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc4:	83 c0 0c             	add    $0xc,%eax
80101cc7:	83 ec 0c             	sub    $0xc,%esp
80101cca:	50                   	push   %eax
80101ccb:	e8 98 35 00 00       	call   80105268 <releasesleep>
80101cd0:	83 c4 10             	add    $0x10,%esp
}
80101cd3:	90                   	nop
80101cd4:	c9                   	leave  
80101cd5:	c3                   	ret    

80101cd6 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101cd6:	f3 0f 1e fb          	endbr32 
80101cda:	55                   	push   %ebp
80101cdb:	89 e5                	mov    %esp,%ebp
80101cdd:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101ce0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce3:	83 c0 0c             	add    $0xc,%eax
80101ce6:	83 ec 0c             	sub    $0xc,%esp
80101ce9:	50                   	push   %eax
80101cea:	e8 11 35 00 00       	call   80105200 <acquiresleep>
80101cef:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101cf2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf5:	8b 40 4c             	mov    0x4c(%eax),%eax
80101cf8:	85 c0                	test   %eax,%eax
80101cfa:	74 6a                	je     80101d66 <iput+0x90>
80101cfc:	8b 45 08             	mov    0x8(%ebp),%eax
80101cff:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101d03:	66 85 c0             	test   %ax,%ax
80101d06:	75 5e                	jne    80101d66 <iput+0x90>
    acquire(&icache.lock);
80101d08:	83 ec 0c             	sub    $0xc,%esp
80101d0b:	68 80 3a 11 80       	push   $0x80113a80
80101d10:	e8 64 36 00 00       	call   80105379 <acquire>
80101d15:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101d18:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1b:	8b 40 08             	mov    0x8(%eax),%eax
80101d1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101d21:	83 ec 0c             	sub    $0xc,%esp
80101d24:	68 80 3a 11 80       	push   $0x80113a80
80101d29:	e8 bd 36 00 00       	call   801053eb <release>
80101d2e:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101d31:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101d35:	75 2f                	jne    80101d66 <iput+0x90>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101d37:	83 ec 0c             	sub    $0xc,%esp
80101d3a:	ff 75 08             	pushl  0x8(%ebp)
80101d3d:	e8 b5 01 00 00       	call   80101ef7 <itrunc>
80101d42:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101d45:	8b 45 08             	mov    0x8(%ebp),%eax
80101d48:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101d4e:	83 ec 0c             	sub    $0xc,%esp
80101d51:	ff 75 08             	pushl  0x8(%ebp)
80101d54:	e8 2b fc ff ff       	call   80101984 <iupdate>
80101d59:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101d5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5f:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101d66:	8b 45 08             	mov    0x8(%ebp),%eax
80101d69:	83 c0 0c             	add    $0xc,%eax
80101d6c:	83 ec 0c             	sub    $0xc,%esp
80101d6f:	50                   	push   %eax
80101d70:	e8 f3 34 00 00       	call   80105268 <releasesleep>
80101d75:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101d78:	83 ec 0c             	sub    $0xc,%esp
80101d7b:	68 80 3a 11 80       	push   $0x80113a80
80101d80:	e8 f4 35 00 00       	call   80105379 <acquire>
80101d85:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101d88:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8b:	8b 40 08             	mov    0x8(%eax),%eax
80101d8e:	8d 50 ff             	lea    -0x1(%eax),%edx
80101d91:	8b 45 08             	mov    0x8(%ebp),%eax
80101d94:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101d97:	83 ec 0c             	sub    $0xc,%esp
80101d9a:	68 80 3a 11 80       	push   $0x80113a80
80101d9f:	e8 47 36 00 00       	call   801053eb <release>
80101da4:	83 c4 10             	add    $0x10,%esp
}
80101da7:	90                   	nop
80101da8:	c9                   	leave  
80101da9:	c3                   	ret    

80101daa <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101daa:	f3 0f 1e fb          	endbr32 
80101dae:	55                   	push   %ebp
80101daf:	89 e5                	mov    %esp,%ebp
80101db1:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101db4:	83 ec 0c             	sub    $0xc,%esp
80101db7:	ff 75 08             	pushl  0x8(%ebp)
80101dba:	e8 c5 fe ff ff       	call   80101c84 <iunlock>
80101dbf:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101dc2:	83 ec 0c             	sub    $0xc,%esp
80101dc5:	ff 75 08             	pushl  0x8(%ebp)
80101dc8:	e8 09 ff ff ff       	call   80101cd6 <iput>
80101dcd:	83 c4 10             	add    $0x10,%esp
}
80101dd0:	90                   	nop
80101dd1:	c9                   	leave  
80101dd2:	c3                   	ret    

80101dd3 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101dd3:	f3 0f 1e fb          	endbr32 
80101dd7:	55                   	push   %ebp
80101dd8:	89 e5                	mov    %esp,%ebp
80101dda:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101ddd:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101de1:	77 42                	ja     80101e25 <bmap+0x52>
    if((addr = ip->addrs[bn]) == 0)
80101de3:	8b 45 08             	mov    0x8(%ebp),%eax
80101de6:	8b 55 0c             	mov    0xc(%ebp),%edx
80101de9:	83 c2 14             	add    $0x14,%edx
80101dec:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101df0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101df3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101df7:	75 24                	jne    80101e1d <bmap+0x4a>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101df9:	8b 45 08             	mov    0x8(%ebp),%eax
80101dfc:	8b 00                	mov    (%eax),%eax
80101dfe:	83 ec 0c             	sub    $0xc,%esp
80101e01:	50                   	push   %eax
80101e02:	e8 c7 f7 ff ff       	call   801015ce <balloc>
80101e07:	83 c4 10             	add    $0x10,%esp
80101e0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e10:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e13:	8d 4a 14             	lea    0x14(%edx),%ecx
80101e16:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e19:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101e1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e20:	e9 d0 00 00 00       	jmp    80101ef5 <bmap+0x122>
  }
  bn -= NDIRECT;
80101e25:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101e29:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101e2d:	0f 87 b5 00 00 00    	ja     80101ee8 <bmap+0x115>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101e33:	8b 45 08             	mov    0x8(%ebp),%eax
80101e36:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e3f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e43:	75 20                	jne    80101e65 <bmap+0x92>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101e45:	8b 45 08             	mov    0x8(%ebp),%eax
80101e48:	8b 00                	mov    (%eax),%eax
80101e4a:	83 ec 0c             	sub    $0xc,%esp
80101e4d:	50                   	push   %eax
80101e4e:	e8 7b f7 ff ff       	call   801015ce <balloc>
80101e53:	83 c4 10             	add    $0x10,%esp
80101e56:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e59:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e5f:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101e65:	8b 45 08             	mov    0x8(%ebp),%eax
80101e68:	8b 00                	mov    (%eax),%eax
80101e6a:	83 ec 08             	sub    $0x8,%esp
80101e6d:	ff 75 f4             	pushl  -0xc(%ebp)
80101e70:	50                   	push   %eax
80101e71:	e8 61 e3 ff ff       	call   801001d7 <bread>
80101e76:	83 c4 10             	add    $0x10,%esp
80101e79:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101e7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e7f:	83 c0 5c             	add    $0x5c,%eax
80101e82:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101e85:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e88:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e92:	01 d0                	add    %edx,%eax
80101e94:	8b 00                	mov    (%eax),%eax
80101e96:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e99:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e9d:	75 36                	jne    80101ed5 <bmap+0x102>
      a[bn] = addr = balloc(ip->dev);
80101e9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea2:	8b 00                	mov    (%eax),%eax
80101ea4:	83 ec 0c             	sub    $0xc,%esp
80101ea7:	50                   	push   %eax
80101ea8:	e8 21 f7 ff ff       	call   801015ce <balloc>
80101ead:	83 c4 10             	add    $0x10,%esp
80101eb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ebd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ec0:	01 c2                	add    %eax,%edx
80101ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ec5:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101ec7:	83 ec 0c             	sub    $0xc,%esp
80101eca:	ff 75 f0             	pushl  -0x10(%ebp)
80101ecd:	e8 d9 1a 00 00       	call   801039ab <log_write>
80101ed2:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101ed5:	83 ec 0c             	sub    $0xc,%esp
80101ed8:	ff 75 f0             	pushl  -0x10(%ebp)
80101edb:	e8 81 e3 ff ff       	call   80100261 <brelse>
80101ee0:	83 c4 10             	add    $0x10,%esp
    return addr;
80101ee3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ee6:	eb 0d                	jmp    80101ef5 <bmap+0x122>
  }

  panic("bmap: out of range");
80101ee8:	83 ec 0c             	sub    $0xc,%esp
80101eeb:	68 aa 96 10 80       	push   $0x801096aa
80101ef0:	e8 13 e7 ff ff       	call   80100608 <panic>
}
80101ef5:	c9                   	leave  
80101ef6:	c3                   	ret    

80101ef7 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101ef7:	f3 0f 1e fb          	endbr32 
80101efb:	55                   	push   %ebp
80101efc:	89 e5                	mov    %esp,%ebp
80101efe:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101f01:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f08:	eb 45                	jmp    80101f4f <itrunc+0x58>
    if(ip->addrs[i]){
80101f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f10:	83 c2 14             	add    $0x14,%edx
80101f13:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101f17:	85 c0                	test   %eax,%eax
80101f19:	74 30                	je     80101f4b <itrunc+0x54>
      bfree(ip->dev, ip->addrs[i]);
80101f1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f21:	83 c2 14             	add    $0x14,%edx
80101f24:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101f28:	8b 55 08             	mov    0x8(%ebp),%edx
80101f2b:	8b 12                	mov    (%edx),%edx
80101f2d:	83 ec 08             	sub    $0x8,%esp
80101f30:	50                   	push   %eax
80101f31:	52                   	push   %edx
80101f32:	e8 e7 f7 ff ff       	call   8010171e <bfree>
80101f37:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101f3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f40:	83 c2 14             	add    $0x14,%edx
80101f43:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101f4a:	00 
  for(i = 0; i < NDIRECT; i++){
80101f4b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101f4f:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101f53:	7e b5                	jle    80101f0a <itrunc+0x13>
    }
  }

  if(ip->addrs[NDIRECT]){
80101f55:	8b 45 08             	mov    0x8(%ebp),%eax
80101f58:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101f5e:	85 c0                	test   %eax,%eax
80101f60:	0f 84 aa 00 00 00    	je     80102010 <itrunc+0x119>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101f66:	8b 45 08             	mov    0x8(%ebp),%eax
80101f69:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101f6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f72:	8b 00                	mov    (%eax),%eax
80101f74:	83 ec 08             	sub    $0x8,%esp
80101f77:	52                   	push   %edx
80101f78:	50                   	push   %eax
80101f79:	e8 59 e2 ff ff       	call   801001d7 <bread>
80101f7e:	83 c4 10             	add    $0x10,%esp
80101f81:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101f84:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f87:	83 c0 5c             	add    $0x5c,%eax
80101f8a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101f8d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101f94:	eb 3c                	jmp    80101fd2 <itrunc+0xdb>
      if(a[j])
80101f96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f99:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101fa0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101fa3:	01 d0                	add    %edx,%eax
80101fa5:	8b 00                	mov    (%eax),%eax
80101fa7:	85 c0                	test   %eax,%eax
80101fa9:	74 23                	je     80101fce <itrunc+0xd7>
        bfree(ip->dev, a[j]);
80101fab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fae:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101fb5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101fb8:	01 d0                	add    %edx,%eax
80101fba:	8b 00                	mov    (%eax),%eax
80101fbc:	8b 55 08             	mov    0x8(%ebp),%edx
80101fbf:	8b 12                	mov    (%edx),%edx
80101fc1:	83 ec 08             	sub    $0x8,%esp
80101fc4:	50                   	push   %eax
80101fc5:	52                   	push   %edx
80101fc6:	e8 53 f7 ff ff       	call   8010171e <bfree>
80101fcb:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101fce:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101fd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fd5:	83 f8 7f             	cmp    $0x7f,%eax
80101fd8:	76 bc                	jbe    80101f96 <itrunc+0x9f>
    }
    brelse(bp);
80101fda:	83 ec 0c             	sub    $0xc,%esp
80101fdd:	ff 75 ec             	pushl  -0x14(%ebp)
80101fe0:	e8 7c e2 ff ff       	call   80100261 <brelse>
80101fe5:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101fe8:	8b 45 08             	mov    0x8(%ebp),%eax
80101feb:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101ff1:	8b 55 08             	mov    0x8(%ebp),%edx
80101ff4:	8b 12                	mov    (%edx),%edx
80101ff6:	83 ec 08             	sub    $0x8,%esp
80101ff9:	50                   	push   %eax
80101ffa:	52                   	push   %edx
80101ffb:	e8 1e f7 ff ff       	call   8010171e <bfree>
80102000:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80102003:	8b 45 08             	mov    0x8(%ebp),%eax
80102006:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
8010200d:	00 00 00 
  }

  ip->size = 0;
80102010:	8b 45 08             	mov    0x8(%ebp),%eax
80102013:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
8010201a:	83 ec 0c             	sub    $0xc,%esp
8010201d:	ff 75 08             	pushl  0x8(%ebp)
80102020:	e8 5f f9 ff ff       	call   80101984 <iupdate>
80102025:	83 c4 10             	add    $0x10,%esp
}
80102028:	90                   	nop
80102029:	c9                   	leave  
8010202a:	c3                   	ret    

8010202b <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
8010202b:	f3 0f 1e fb          	endbr32 
8010202f:	55                   	push   %ebp
80102030:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80102032:	8b 45 08             	mov    0x8(%ebp),%eax
80102035:	8b 00                	mov    (%eax),%eax
80102037:	89 c2                	mov    %eax,%edx
80102039:	8b 45 0c             	mov    0xc(%ebp),%eax
8010203c:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
8010203f:	8b 45 08             	mov    0x8(%ebp),%eax
80102042:	8b 50 04             	mov    0x4(%eax),%edx
80102045:	8b 45 0c             	mov    0xc(%ebp),%eax
80102048:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
8010204b:	8b 45 08             	mov    0x8(%ebp),%eax
8010204e:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80102052:	8b 45 0c             	mov    0xc(%ebp),%eax
80102055:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80102058:	8b 45 08             	mov    0x8(%ebp),%eax
8010205b:	0f b7 50 56          	movzwl 0x56(%eax),%edx
8010205f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102062:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80102066:	8b 45 08             	mov    0x8(%ebp),%eax
80102069:	8b 50 58             	mov    0x58(%eax),%edx
8010206c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010206f:	89 50 10             	mov    %edx,0x10(%eax)
}
80102072:	90                   	nop
80102073:	5d                   	pop    %ebp
80102074:	c3                   	ret    

80102075 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80102075:	f3 0f 1e fb          	endbr32 
80102079:	55                   	push   %ebp
8010207a:	89 e5                	mov    %esp,%ebp
8010207c:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010207f:	8b 45 08             	mov    0x8(%ebp),%eax
80102082:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102086:	66 83 f8 03          	cmp    $0x3,%ax
8010208a:	75 5c                	jne    801020e8 <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
8010208c:	8b 45 08             	mov    0x8(%ebp),%eax
8010208f:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102093:	66 85 c0             	test   %ax,%ax
80102096:	78 20                	js     801020b8 <readi+0x43>
80102098:	8b 45 08             	mov    0x8(%ebp),%eax
8010209b:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010209f:	66 83 f8 09          	cmp    $0x9,%ax
801020a3:	7f 13                	jg     801020b8 <readi+0x43>
801020a5:	8b 45 08             	mov    0x8(%ebp),%eax
801020a8:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020ac:	98                   	cwtl   
801020ad:	8b 04 c5 00 3a 11 80 	mov    -0x7feec600(,%eax,8),%eax
801020b4:	85 c0                	test   %eax,%eax
801020b6:	75 0a                	jne    801020c2 <readi+0x4d>
      return -1;
801020b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020bd:	e9 0a 01 00 00       	jmp    801021cc <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
801020c2:	8b 45 08             	mov    0x8(%ebp),%eax
801020c5:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020c9:	98                   	cwtl   
801020ca:	8b 04 c5 00 3a 11 80 	mov    -0x7feec600(,%eax,8),%eax
801020d1:	8b 55 14             	mov    0x14(%ebp),%edx
801020d4:	83 ec 04             	sub    $0x4,%esp
801020d7:	52                   	push   %edx
801020d8:	ff 75 0c             	pushl  0xc(%ebp)
801020db:	ff 75 08             	pushl  0x8(%ebp)
801020de:	ff d0                	call   *%eax
801020e0:	83 c4 10             	add    $0x10,%esp
801020e3:	e9 e4 00 00 00       	jmp    801021cc <readi+0x157>
  }

  if(off > ip->size || off + n < off)
801020e8:	8b 45 08             	mov    0x8(%ebp),%eax
801020eb:	8b 40 58             	mov    0x58(%eax),%eax
801020ee:	39 45 10             	cmp    %eax,0x10(%ebp)
801020f1:	77 0d                	ja     80102100 <readi+0x8b>
801020f3:	8b 55 10             	mov    0x10(%ebp),%edx
801020f6:	8b 45 14             	mov    0x14(%ebp),%eax
801020f9:	01 d0                	add    %edx,%eax
801020fb:	39 45 10             	cmp    %eax,0x10(%ebp)
801020fe:	76 0a                	jbe    8010210a <readi+0x95>
    return -1;
80102100:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102105:	e9 c2 00 00 00       	jmp    801021cc <readi+0x157>
  if(off + n > ip->size)
8010210a:	8b 55 10             	mov    0x10(%ebp),%edx
8010210d:	8b 45 14             	mov    0x14(%ebp),%eax
80102110:	01 c2                	add    %eax,%edx
80102112:	8b 45 08             	mov    0x8(%ebp),%eax
80102115:	8b 40 58             	mov    0x58(%eax),%eax
80102118:	39 c2                	cmp    %eax,%edx
8010211a:	76 0c                	jbe    80102128 <readi+0xb3>
    n = ip->size - off;
8010211c:	8b 45 08             	mov    0x8(%ebp),%eax
8010211f:	8b 40 58             	mov    0x58(%eax),%eax
80102122:	2b 45 10             	sub    0x10(%ebp),%eax
80102125:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102128:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010212f:	e9 89 00 00 00       	jmp    801021bd <readi+0x148>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102134:	8b 45 10             	mov    0x10(%ebp),%eax
80102137:	c1 e8 09             	shr    $0x9,%eax
8010213a:	83 ec 08             	sub    $0x8,%esp
8010213d:	50                   	push   %eax
8010213e:	ff 75 08             	pushl  0x8(%ebp)
80102141:	e8 8d fc ff ff       	call   80101dd3 <bmap>
80102146:	83 c4 10             	add    $0x10,%esp
80102149:	8b 55 08             	mov    0x8(%ebp),%edx
8010214c:	8b 12                	mov    (%edx),%edx
8010214e:	83 ec 08             	sub    $0x8,%esp
80102151:	50                   	push   %eax
80102152:	52                   	push   %edx
80102153:	e8 7f e0 ff ff       	call   801001d7 <bread>
80102158:	83 c4 10             	add    $0x10,%esp
8010215b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010215e:	8b 45 10             	mov    0x10(%ebp),%eax
80102161:	25 ff 01 00 00       	and    $0x1ff,%eax
80102166:	ba 00 02 00 00       	mov    $0x200,%edx
8010216b:	29 c2                	sub    %eax,%edx
8010216d:	8b 45 14             	mov    0x14(%ebp),%eax
80102170:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102173:	39 c2                	cmp    %eax,%edx
80102175:	0f 46 c2             	cmovbe %edx,%eax
80102178:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
8010217b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010217e:	8d 50 5c             	lea    0x5c(%eax),%edx
80102181:	8b 45 10             	mov    0x10(%ebp),%eax
80102184:	25 ff 01 00 00       	and    $0x1ff,%eax
80102189:	01 d0                	add    %edx,%eax
8010218b:	83 ec 04             	sub    $0x4,%esp
8010218e:	ff 75 ec             	pushl  -0x14(%ebp)
80102191:	50                   	push   %eax
80102192:	ff 75 0c             	pushl  0xc(%ebp)
80102195:	e8 45 35 00 00       	call   801056df <memmove>
8010219a:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010219d:	83 ec 0c             	sub    $0xc,%esp
801021a0:	ff 75 f0             	pushl  -0x10(%ebp)
801021a3:	e8 b9 e0 ff ff       	call   80100261 <brelse>
801021a8:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801021ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021ae:	01 45 f4             	add    %eax,-0xc(%ebp)
801021b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021b4:	01 45 10             	add    %eax,0x10(%ebp)
801021b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021ba:	01 45 0c             	add    %eax,0xc(%ebp)
801021bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021c0:	3b 45 14             	cmp    0x14(%ebp),%eax
801021c3:	0f 82 6b ff ff ff    	jb     80102134 <readi+0xbf>
  }
  return n;
801021c9:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021cc:	c9                   	leave  
801021cd:	c3                   	ret    

801021ce <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801021ce:	f3 0f 1e fb          	endbr32 
801021d2:	55                   	push   %ebp
801021d3:	89 e5                	mov    %esp,%ebp
801021d5:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801021d8:	8b 45 08             	mov    0x8(%ebp),%eax
801021db:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021df:	66 83 f8 03          	cmp    $0x3,%ax
801021e3:	75 5c                	jne    80102241 <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801021e5:	8b 45 08             	mov    0x8(%ebp),%eax
801021e8:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021ec:	66 85 c0             	test   %ax,%ax
801021ef:	78 20                	js     80102211 <writei+0x43>
801021f1:	8b 45 08             	mov    0x8(%ebp),%eax
801021f4:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021f8:	66 83 f8 09          	cmp    $0x9,%ax
801021fc:	7f 13                	jg     80102211 <writei+0x43>
801021fe:	8b 45 08             	mov    0x8(%ebp),%eax
80102201:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102205:	98                   	cwtl   
80102206:	8b 04 c5 04 3a 11 80 	mov    -0x7feec5fc(,%eax,8),%eax
8010220d:	85 c0                	test   %eax,%eax
8010220f:	75 0a                	jne    8010221b <writei+0x4d>
      return -1;
80102211:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102216:	e9 3b 01 00 00       	jmp    80102356 <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
8010221b:	8b 45 08             	mov    0x8(%ebp),%eax
8010221e:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102222:	98                   	cwtl   
80102223:	8b 04 c5 04 3a 11 80 	mov    -0x7feec5fc(,%eax,8),%eax
8010222a:	8b 55 14             	mov    0x14(%ebp),%edx
8010222d:	83 ec 04             	sub    $0x4,%esp
80102230:	52                   	push   %edx
80102231:	ff 75 0c             	pushl  0xc(%ebp)
80102234:	ff 75 08             	pushl  0x8(%ebp)
80102237:	ff d0                	call   *%eax
80102239:	83 c4 10             	add    $0x10,%esp
8010223c:	e9 15 01 00 00       	jmp    80102356 <writei+0x188>
  }

  if(off > ip->size || off + n < off)
80102241:	8b 45 08             	mov    0x8(%ebp),%eax
80102244:	8b 40 58             	mov    0x58(%eax),%eax
80102247:	39 45 10             	cmp    %eax,0x10(%ebp)
8010224a:	77 0d                	ja     80102259 <writei+0x8b>
8010224c:	8b 55 10             	mov    0x10(%ebp),%edx
8010224f:	8b 45 14             	mov    0x14(%ebp),%eax
80102252:	01 d0                	add    %edx,%eax
80102254:	39 45 10             	cmp    %eax,0x10(%ebp)
80102257:	76 0a                	jbe    80102263 <writei+0x95>
    return -1;
80102259:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010225e:	e9 f3 00 00 00       	jmp    80102356 <writei+0x188>
  if(off + n > MAXFILE*BSIZE)
80102263:	8b 55 10             	mov    0x10(%ebp),%edx
80102266:	8b 45 14             	mov    0x14(%ebp),%eax
80102269:	01 d0                	add    %edx,%eax
8010226b:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102270:	76 0a                	jbe    8010227c <writei+0xae>
    return -1;
80102272:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102277:	e9 da 00 00 00       	jmp    80102356 <writei+0x188>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010227c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102283:	e9 97 00 00 00       	jmp    8010231f <writei+0x151>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102288:	8b 45 10             	mov    0x10(%ebp),%eax
8010228b:	c1 e8 09             	shr    $0x9,%eax
8010228e:	83 ec 08             	sub    $0x8,%esp
80102291:	50                   	push   %eax
80102292:	ff 75 08             	pushl  0x8(%ebp)
80102295:	e8 39 fb ff ff       	call   80101dd3 <bmap>
8010229a:	83 c4 10             	add    $0x10,%esp
8010229d:	8b 55 08             	mov    0x8(%ebp),%edx
801022a0:	8b 12                	mov    (%edx),%edx
801022a2:	83 ec 08             	sub    $0x8,%esp
801022a5:	50                   	push   %eax
801022a6:	52                   	push   %edx
801022a7:	e8 2b df ff ff       	call   801001d7 <bread>
801022ac:	83 c4 10             	add    $0x10,%esp
801022af:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801022b2:	8b 45 10             	mov    0x10(%ebp),%eax
801022b5:	25 ff 01 00 00       	and    $0x1ff,%eax
801022ba:	ba 00 02 00 00       	mov    $0x200,%edx
801022bf:	29 c2                	sub    %eax,%edx
801022c1:	8b 45 14             	mov    0x14(%ebp),%eax
801022c4:	2b 45 f4             	sub    -0xc(%ebp),%eax
801022c7:	39 c2                	cmp    %eax,%edx
801022c9:	0f 46 c2             	cmovbe %edx,%eax
801022cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801022cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022d2:	8d 50 5c             	lea    0x5c(%eax),%edx
801022d5:	8b 45 10             	mov    0x10(%ebp),%eax
801022d8:	25 ff 01 00 00       	and    $0x1ff,%eax
801022dd:	01 d0                	add    %edx,%eax
801022df:	83 ec 04             	sub    $0x4,%esp
801022e2:	ff 75 ec             	pushl  -0x14(%ebp)
801022e5:	ff 75 0c             	pushl  0xc(%ebp)
801022e8:	50                   	push   %eax
801022e9:	e8 f1 33 00 00       	call   801056df <memmove>
801022ee:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801022f1:	83 ec 0c             	sub    $0xc,%esp
801022f4:	ff 75 f0             	pushl  -0x10(%ebp)
801022f7:	e8 af 16 00 00       	call   801039ab <log_write>
801022fc:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801022ff:	83 ec 0c             	sub    $0xc,%esp
80102302:	ff 75 f0             	pushl  -0x10(%ebp)
80102305:	e8 57 df ff ff       	call   80100261 <brelse>
8010230a:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010230d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102310:	01 45 f4             	add    %eax,-0xc(%ebp)
80102313:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102316:	01 45 10             	add    %eax,0x10(%ebp)
80102319:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010231c:	01 45 0c             	add    %eax,0xc(%ebp)
8010231f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102322:	3b 45 14             	cmp    0x14(%ebp),%eax
80102325:	0f 82 5d ff ff ff    	jb     80102288 <writei+0xba>
  }

  if(n > 0 && off > ip->size){
8010232b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010232f:	74 22                	je     80102353 <writei+0x185>
80102331:	8b 45 08             	mov    0x8(%ebp),%eax
80102334:	8b 40 58             	mov    0x58(%eax),%eax
80102337:	39 45 10             	cmp    %eax,0x10(%ebp)
8010233a:	76 17                	jbe    80102353 <writei+0x185>
    ip->size = off;
8010233c:	8b 45 08             	mov    0x8(%ebp),%eax
8010233f:	8b 55 10             	mov    0x10(%ebp),%edx
80102342:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102345:	83 ec 0c             	sub    $0xc,%esp
80102348:	ff 75 08             	pushl  0x8(%ebp)
8010234b:	e8 34 f6 ff ff       	call   80101984 <iupdate>
80102350:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102353:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102356:	c9                   	leave  
80102357:	c3                   	ret    

80102358 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102358:	f3 0f 1e fb          	endbr32 
8010235c:	55                   	push   %ebp
8010235d:	89 e5                	mov    %esp,%ebp
8010235f:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102362:	83 ec 04             	sub    $0x4,%esp
80102365:	6a 0e                	push   $0xe
80102367:	ff 75 0c             	pushl  0xc(%ebp)
8010236a:	ff 75 08             	pushl  0x8(%ebp)
8010236d:	e8 0b 34 00 00       	call   8010577d <strncmp>
80102372:	83 c4 10             	add    $0x10,%esp
}
80102375:	c9                   	leave  
80102376:	c3                   	ret    

80102377 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102377:	f3 0f 1e fb          	endbr32 
8010237b:	55                   	push   %ebp
8010237c:	89 e5                	mov    %esp,%ebp
8010237e:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102381:	8b 45 08             	mov    0x8(%ebp),%eax
80102384:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102388:	66 83 f8 01          	cmp    $0x1,%ax
8010238c:	74 0d                	je     8010239b <dirlookup+0x24>
    panic("dirlookup not DIR");
8010238e:	83 ec 0c             	sub    $0xc,%esp
80102391:	68 bd 96 10 80       	push   $0x801096bd
80102396:	e8 6d e2 ff ff       	call   80100608 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
8010239b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023a2:	eb 7b                	jmp    8010241f <dirlookup+0xa8>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023a4:	6a 10                	push   $0x10
801023a6:	ff 75 f4             	pushl  -0xc(%ebp)
801023a9:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023ac:	50                   	push   %eax
801023ad:	ff 75 08             	pushl  0x8(%ebp)
801023b0:	e8 c0 fc ff ff       	call   80102075 <readi>
801023b5:	83 c4 10             	add    $0x10,%esp
801023b8:	83 f8 10             	cmp    $0x10,%eax
801023bb:	74 0d                	je     801023ca <dirlookup+0x53>
      panic("dirlookup read");
801023bd:	83 ec 0c             	sub    $0xc,%esp
801023c0:	68 cf 96 10 80       	push   $0x801096cf
801023c5:	e8 3e e2 ff ff       	call   80100608 <panic>
    if(de.inum == 0)
801023ca:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023ce:	66 85 c0             	test   %ax,%ax
801023d1:	74 47                	je     8010241a <dirlookup+0xa3>
      continue;
    if(namecmp(name, de.name) == 0){
801023d3:	83 ec 08             	sub    $0x8,%esp
801023d6:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023d9:	83 c0 02             	add    $0x2,%eax
801023dc:	50                   	push   %eax
801023dd:	ff 75 0c             	pushl  0xc(%ebp)
801023e0:	e8 73 ff ff ff       	call   80102358 <namecmp>
801023e5:	83 c4 10             	add    $0x10,%esp
801023e8:	85 c0                	test   %eax,%eax
801023ea:	75 2f                	jne    8010241b <dirlookup+0xa4>
      // entry matches path element
      if(poff)
801023ec:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801023f0:	74 08                	je     801023fa <dirlookup+0x83>
        *poff = off;
801023f2:	8b 45 10             	mov    0x10(%ebp),%eax
801023f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801023f8:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801023fa:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023fe:	0f b7 c0             	movzwl %ax,%eax
80102401:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102404:	8b 45 08             	mov    0x8(%ebp),%eax
80102407:	8b 00                	mov    (%eax),%eax
80102409:	83 ec 08             	sub    $0x8,%esp
8010240c:	ff 75 f0             	pushl  -0x10(%ebp)
8010240f:	50                   	push   %eax
80102410:	e8 34 f6 ff ff       	call   80101a49 <iget>
80102415:	83 c4 10             	add    $0x10,%esp
80102418:	eb 19                	jmp    80102433 <dirlookup+0xbc>
      continue;
8010241a:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
8010241b:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010241f:	8b 45 08             	mov    0x8(%ebp),%eax
80102422:	8b 40 58             	mov    0x58(%eax),%eax
80102425:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102428:	0f 82 76 ff ff ff    	jb     801023a4 <dirlookup+0x2d>
    }
  }

  return 0;
8010242e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102433:	c9                   	leave  
80102434:	c3                   	ret    

80102435 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102435:	f3 0f 1e fb          	endbr32 
80102439:	55                   	push   %ebp
8010243a:	89 e5                	mov    %esp,%ebp
8010243c:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010243f:	83 ec 04             	sub    $0x4,%esp
80102442:	6a 00                	push   $0x0
80102444:	ff 75 0c             	pushl  0xc(%ebp)
80102447:	ff 75 08             	pushl  0x8(%ebp)
8010244a:	e8 28 ff ff ff       	call   80102377 <dirlookup>
8010244f:	83 c4 10             	add    $0x10,%esp
80102452:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102455:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102459:	74 18                	je     80102473 <dirlink+0x3e>
    iput(ip);
8010245b:	83 ec 0c             	sub    $0xc,%esp
8010245e:	ff 75 f0             	pushl  -0x10(%ebp)
80102461:	e8 70 f8 ff ff       	call   80101cd6 <iput>
80102466:	83 c4 10             	add    $0x10,%esp
    return -1;
80102469:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010246e:	e9 9c 00 00 00       	jmp    8010250f <dirlink+0xda>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102473:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010247a:	eb 39                	jmp    801024b5 <dirlink+0x80>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010247c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010247f:	6a 10                	push   $0x10
80102481:	50                   	push   %eax
80102482:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102485:	50                   	push   %eax
80102486:	ff 75 08             	pushl  0x8(%ebp)
80102489:	e8 e7 fb ff ff       	call   80102075 <readi>
8010248e:	83 c4 10             	add    $0x10,%esp
80102491:	83 f8 10             	cmp    $0x10,%eax
80102494:	74 0d                	je     801024a3 <dirlink+0x6e>
      panic("dirlink read");
80102496:	83 ec 0c             	sub    $0xc,%esp
80102499:	68 de 96 10 80       	push   $0x801096de
8010249e:	e8 65 e1 ff ff       	call   80100608 <panic>
    if(de.inum == 0)
801024a3:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801024a7:	66 85 c0             	test   %ax,%ax
801024aa:	74 18                	je     801024c4 <dirlink+0x8f>
  for(off = 0; off < dp->size; off += sizeof(de)){
801024ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024af:	83 c0 10             	add    $0x10,%eax
801024b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024b5:	8b 45 08             	mov    0x8(%ebp),%eax
801024b8:	8b 50 58             	mov    0x58(%eax),%edx
801024bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024be:	39 c2                	cmp    %eax,%edx
801024c0:	77 ba                	ja     8010247c <dirlink+0x47>
801024c2:	eb 01                	jmp    801024c5 <dirlink+0x90>
      break;
801024c4:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801024c5:	83 ec 04             	sub    $0x4,%esp
801024c8:	6a 0e                	push   $0xe
801024ca:	ff 75 0c             	pushl  0xc(%ebp)
801024cd:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024d0:	83 c0 02             	add    $0x2,%eax
801024d3:	50                   	push   %eax
801024d4:	e8 fe 32 00 00       	call   801057d7 <strncpy>
801024d9:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801024dc:	8b 45 10             	mov    0x10(%ebp),%eax
801024df:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801024e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024e6:	6a 10                	push   $0x10
801024e8:	50                   	push   %eax
801024e9:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024ec:	50                   	push   %eax
801024ed:	ff 75 08             	pushl  0x8(%ebp)
801024f0:	e8 d9 fc ff ff       	call   801021ce <writei>
801024f5:	83 c4 10             	add    $0x10,%esp
801024f8:	83 f8 10             	cmp    $0x10,%eax
801024fb:	74 0d                	je     8010250a <dirlink+0xd5>
    panic("dirlink");
801024fd:	83 ec 0c             	sub    $0xc,%esp
80102500:	68 eb 96 10 80       	push   $0x801096eb
80102505:	e8 fe e0 ff ff       	call   80100608 <panic>

  return 0;
8010250a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010250f:	c9                   	leave  
80102510:	c3                   	ret    

80102511 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102511:	f3 0f 1e fb          	endbr32 
80102515:	55                   	push   %ebp
80102516:	89 e5                	mov    %esp,%ebp
80102518:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010251b:	eb 04                	jmp    80102521 <skipelem+0x10>
    path++;
8010251d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102521:	8b 45 08             	mov    0x8(%ebp),%eax
80102524:	0f b6 00             	movzbl (%eax),%eax
80102527:	3c 2f                	cmp    $0x2f,%al
80102529:	74 f2                	je     8010251d <skipelem+0xc>
  if(*path == 0)
8010252b:	8b 45 08             	mov    0x8(%ebp),%eax
8010252e:	0f b6 00             	movzbl (%eax),%eax
80102531:	84 c0                	test   %al,%al
80102533:	75 07                	jne    8010253c <skipelem+0x2b>
    return 0;
80102535:	b8 00 00 00 00       	mov    $0x0,%eax
8010253a:	eb 77                	jmp    801025b3 <skipelem+0xa2>
  s = path;
8010253c:	8b 45 08             	mov    0x8(%ebp),%eax
8010253f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102542:	eb 04                	jmp    80102548 <skipelem+0x37>
    path++;
80102544:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102548:	8b 45 08             	mov    0x8(%ebp),%eax
8010254b:	0f b6 00             	movzbl (%eax),%eax
8010254e:	3c 2f                	cmp    $0x2f,%al
80102550:	74 0a                	je     8010255c <skipelem+0x4b>
80102552:	8b 45 08             	mov    0x8(%ebp),%eax
80102555:	0f b6 00             	movzbl (%eax),%eax
80102558:	84 c0                	test   %al,%al
8010255a:	75 e8                	jne    80102544 <skipelem+0x33>
  len = path - s;
8010255c:	8b 45 08             	mov    0x8(%ebp),%eax
8010255f:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102562:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102565:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102569:	7e 15                	jle    80102580 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
8010256b:	83 ec 04             	sub    $0x4,%esp
8010256e:	6a 0e                	push   $0xe
80102570:	ff 75 f4             	pushl  -0xc(%ebp)
80102573:	ff 75 0c             	pushl  0xc(%ebp)
80102576:	e8 64 31 00 00       	call   801056df <memmove>
8010257b:	83 c4 10             	add    $0x10,%esp
8010257e:	eb 26                	jmp    801025a6 <skipelem+0x95>
  else {
    memmove(name, s, len);
80102580:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102583:	83 ec 04             	sub    $0x4,%esp
80102586:	50                   	push   %eax
80102587:	ff 75 f4             	pushl  -0xc(%ebp)
8010258a:	ff 75 0c             	pushl  0xc(%ebp)
8010258d:	e8 4d 31 00 00       	call   801056df <memmove>
80102592:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
80102595:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102598:	8b 45 0c             	mov    0xc(%ebp),%eax
8010259b:	01 d0                	add    %edx,%eax
8010259d:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801025a0:	eb 04                	jmp    801025a6 <skipelem+0x95>
    path++;
801025a2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801025a6:	8b 45 08             	mov    0x8(%ebp),%eax
801025a9:	0f b6 00             	movzbl (%eax),%eax
801025ac:	3c 2f                	cmp    $0x2f,%al
801025ae:	74 f2                	je     801025a2 <skipelem+0x91>
  return path;
801025b0:	8b 45 08             	mov    0x8(%ebp),%eax
}
801025b3:	c9                   	leave  
801025b4:	c3                   	ret    

801025b5 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801025b5:	f3 0f 1e fb          	endbr32 
801025b9:	55                   	push   %ebp
801025ba:	89 e5                	mov    %esp,%ebp
801025bc:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801025bf:	8b 45 08             	mov    0x8(%ebp),%eax
801025c2:	0f b6 00             	movzbl (%eax),%eax
801025c5:	3c 2f                	cmp    $0x2f,%al
801025c7:	75 17                	jne    801025e0 <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
801025c9:	83 ec 08             	sub    $0x8,%esp
801025cc:	6a 01                	push   $0x1
801025ce:	6a 01                	push   $0x1
801025d0:	e8 74 f4 ff ff       	call   80101a49 <iget>
801025d5:	83 c4 10             	add    $0x10,%esp
801025d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801025db:	e9 ba 00 00 00       	jmp    8010269a <namex+0xe5>
  else
    ip = idup(myproc()->cwd);
801025e0:	e8 3c 1f 00 00       	call   80104521 <myproc>
801025e5:	8b 40 68             	mov    0x68(%eax),%eax
801025e8:	83 ec 0c             	sub    $0xc,%esp
801025eb:	50                   	push   %eax
801025ec:	e8 3e f5 ff ff       	call   80101b2f <idup>
801025f1:	83 c4 10             	add    $0x10,%esp
801025f4:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801025f7:	e9 9e 00 00 00       	jmp    8010269a <namex+0xe5>
    ilock(ip);
801025fc:	83 ec 0c             	sub    $0xc,%esp
801025ff:	ff 75 f4             	pushl  -0xc(%ebp)
80102602:	e8 66 f5 ff ff       	call   80101b6d <ilock>
80102607:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010260a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010260d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102611:	66 83 f8 01          	cmp    $0x1,%ax
80102615:	74 18                	je     8010262f <namex+0x7a>
      iunlockput(ip);
80102617:	83 ec 0c             	sub    $0xc,%esp
8010261a:	ff 75 f4             	pushl  -0xc(%ebp)
8010261d:	e8 88 f7 ff ff       	call   80101daa <iunlockput>
80102622:	83 c4 10             	add    $0x10,%esp
      return 0;
80102625:	b8 00 00 00 00       	mov    $0x0,%eax
8010262a:	e9 a7 00 00 00       	jmp    801026d6 <namex+0x121>
    }
    if(nameiparent && *path == '\0'){
8010262f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102633:	74 20                	je     80102655 <namex+0xa0>
80102635:	8b 45 08             	mov    0x8(%ebp),%eax
80102638:	0f b6 00             	movzbl (%eax),%eax
8010263b:	84 c0                	test   %al,%al
8010263d:	75 16                	jne    80102655 <namex+0xa0>
      // Stop one level early.
      iunlock(ip);
8010263f:	83 ec 0c             	sub    $0xc,%esp
80102642:	ff 75 f4             	pushl  -0xc(%ebp)
80102645:	e8 3a f6 ff ff       	call   80101c84 <iunlock>
8010264a:	83 c4 10             	add    $0x10,%esp
      return ip;
8010264d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102650:	e9 81 00 00 00       	jmp    801026d6 <namex+0x121>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102655:	83 ec 04             	sub    $0x4,%esp
80102658:	6a 00                	push   $0x0
8010265a:	ff 75 10             	pushl  0x10(%ebp)
8010265d:	ff 75 f4             	pushl  -0xc(%ebp)
80102660:	e8 12 fd ff ff       	call   80102377 <dirlookup>
80102665:	83 c4 10             	add    $0x10,%esp
80102668:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010266b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010266f:	75 15                	jne    80102686 <namex+0xd1>
      iunlockput(ip);
80102671:	83 ec 0c             	sub    $0xc,%esp
80102674:	ff 75 f4             	pushl  -0xc(%ebp)
80102677:	e8 2e f7 ff ff       	call   80101daa <iunlockput>
8010267c:	83 c4 10             	add    $0x10,%esp
      return 0;
8010267f:	b8 00 00 00 00       	mov    $0x0,%eax
80102684:	eb 50                	jmp    801026d6 <namex+0x121>
    }
    iunlockput(ip);
80102686:	83 ec 0c             	sub    $0xc,%esp
80102689:	ff 75 f4             	pushl  -0xc(%ebp)
8010268c:	e8 19 f7 ff ff       	call   80101daa <iunlockput>
80102691:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102694:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102697:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
8010269a:	83 ec 08             	sub    $0x8,%esp
8010269d:	ff 75 10             	pushl  0x10(%ebp)
801026a0:	ff 75 08             	pushl  0x8(%ebp)
801026a3:	e8 69 fe ff ff       	call   80102511 <skipelem>
801026a8:	83 c4 10             	add    $0x10,%esp
801026ab:	89 45 08             	mov    %eax,0x8(%ebp)
801026ae:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026b2:	0f 85 44 ff ff ff    	jne    801025fc <namex+0x47>
  }
  if(nameiparent){
801026b8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801026bc:	74 15                	je     801026d3 <namex+0x11e>
    iput(ip);
801026be:	83 ec 0c             	sub    $0xc,%esp
801026c1:	ff 75 f4             	pushl  -0xc(%ebp)
801026c4:	e8 0d f6 ff ff       	call   80101cd6 <iput>
801026c9:	83 c4 10             	add    $0x10,%esp
    return 0;
801026cc:	b8 00 00 00 00       	mov    $0x0,%eax
801026d1:	eb 03                	jmp    801026d6 <namex+0x121>
  }
  return ip;
801026d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801026d6:	c9                   	leave  
801026d7:	c3                   	ret    

801026d8 <namei>:

struct inode*
namei(char *path)
{
801026d8:	f3 0f 1e fb          	endbr32 
801026dc:	55                   	push   %ebp
801026dd:	89 e5                	mov    %esp,%ebp
801026df:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801026e2:	83 ec 04             	sub    $0x4,%esp
801026e5:	8d 45 ea             	lea    -0x16(%ebp),%eax
801026e8:	50                   	push   %eax
801026e9:	6a 00                	push   $0x0
801026eb:	ff 75 08             	pushl  0x8(%ebp)
801026ee:	e8 c2 fe ff ff       	call   801025b5 <namex>
801026f3:	83 c4 10             	add    $0x10,%esp
}
801026f6:	c9                   	leave  
801026f7:	c3                   	ret    

801026f8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801026f8:	f3 0f 1e fb          	endbr32 
801026fc:	55                   	push   %ebp
801026fd:	89 e5                	mov    %esp,%ebp
801026ff:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102702:	83 ec 04             	sub    $0x4,%esp
80102705:	ff 75 0c             	pushl  0xc(%ebp)
80102708:	6a 01                	push   $0x1
8010270a:	ff 75 08             	pushl  0x8(%ebp)
8010270d:	e8 a3 fe ff ff       	call   801025b5 <namex>
80102712:	83 c4 10             	add    $0x10,%esp
}
80102715:	c9                   	leave  
80102716:	c3                   	ret    

80102717 <inb>:
{
80102717:	55                   	push   %ebp
80102718:	89 e5                	mov    %esp,%ebp
8010271a:	83 ec 14             	sub    $0x14,%esp
8010271d:	8b 45 08             	mov    0x8(%ebp),%eax
80102720:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102724:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102728:	89 c2                	mov    %eax,%edx
8010272a:	ec                   	in     (%dx),%al
8010272b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010272e:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102732:	c9                   	leave  
80102733:	c3                   	ret    

80102734 <insl>:
{
80102734:	55                   	push   %ebp
80102735:	89 e5                	mov    %esp,%ebp
80102737:	57                   	push   %edi
80102738:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102739:	8b 55 08             	mov    0x8(%ebp),%edx
8010273c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010273f:	8b 45 10             	mov    0x10(%ebp),%eax
80102742:	89 cb                	mov    %ecx,%ebx
80102744:	89 df                	mov    %ebx,%edi
80102746:	89 c1                	mov    %eax,%ecx
80102748:	fc                   	cld    
80102749:	f3 6d                	rep insl (%dx),%es:(%edi)
8010274b:	89 c8                	mov    %ecx,%eax
8010274d:	89 fb                	mov    %edi,%ebx
8010274f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102752:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102755:	90                   	nop
80102756:	5b                   	pop    %ebx
80102757:	5f                   	pop    %edi
80102758:	5d                   	pop    %ebp
80102759:	c3                   	ret    

8010275a <outb>:
{
8010275a:	55                   	push   %ebp
8010275b:	89 e5                	mov    %esp,%ebp
8010275d:	83 ec 08             	sub    $0x8,%esp
80102760:	8b 45 08             	mov    0x8(%ebp),%eax
80102763:	8b 55 0c             	mov    0xc(%ebp),%edx
80102766:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010276a:	89 d0                	mov    %edx,%eax
8010276c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010276f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102773:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102777:	ee                   	out    %al,(%dx)
}
80102778:	90                   	nop
80102779:	c9                   	leave  
8010277a:	c3                   	ret    

8010277b <outsl>:
{
8010277b:	55                   	push   %ebp
8010277c:	89 e5                	mov    %esp,%ebp
8010277e:	56                   	push   %esi
8010277f:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102780:	8b 55 08             	mov    0x8(%ebp),%edx
80102783:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102786:	8b 45 10             	mov    0x10(%ebp),%eax
80102789:	89 cb                	mov    %ecx,%ebx
8010278b:	89 de                	mov    %ebx,%esi
8010278d:	89 c1                	mov    %eax,%ecx
8010278f:	fc                   	cld    
80102790:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102792:	89 c8                	mov    %ecx,%eax
80102794:	89 f3                	mov    %esi,%ebx
80102796:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102799:	89 45 10             	mov    %eax,0x10(%ebp)
}
8010279c:	90                   	nop
8010279d:	5b                   	pop    %ebx
8010279e:	5e                   	pop    %esi
8010279f:	5d                   	pop    %ebp
801027a0:	c3                   	ret    

801027a1 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801027a1:	f3 0f 1e fb          	endbr32 
801027a5:	55                   	push   %ebp
801027a6:	89 e5                	mov    %esp,%ebp
801027a8:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801027ab:	90                   	nop
801027ac:	68 f7 01 00 00       	push   $0x1f7
801027b1:	e8 61 ff ff ff       	call   80102717 <inb>
801027b6:	83 c4 04             	add    $0x4,%esp
801027b9:	0f b6 c0             	movzbl %al,%eax
801027bc:	89 45 fc             	mov    %eax,-0x4(%ebp)
801027bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801027c2:	25 c0 00 00 00       	and    $0xc0,%eax
801027c7:	83 f8 40             	cmp    $0x40,%eax
801027ca:	75 e0                	jne    801027ac <idewait+0xb>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801027cc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801027d0:	74 11                	je     801027e3 <idewait+0x42>
801027d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801027d5:	83 e0 21             	and    $0x21,%eax
801027d8:	85 c0                	test   %eax,%eax
801027da:	74 07                	je     801027e3 <idewait+0x42>
    return -1;
801027dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801027e1:	eb 05                	jmp    801027e8 <idewait+0x47>
  return 0;
801027e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801027e8:	c9                   	leave  
801027e9:	c3                   	ret    

801027ea <ideinit>:

void
ideinit(void)
{
801027ea:	f3 0f 1e fb          	endbr32 
801027ee:	55                   	push   %ebp
801027ef:	89 e5                	mov    %esp,%ebp
801027f1:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
801027f4:	83 ec 08             	sub    $0x8,%esp
801027f7:	68 f3 96 10 80       	push   $0x801096f3
801027fc:	68 00 d6 10 80       	push   $0x8010d600
80102801:	e8 4d 2b 00 00       	call   80105353 <initlock>
80102806:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102809:	a1 a0 5d 11 80       	mov    0x80115da0,%eax
8010280e:	83 e8 01             	sub    $0x1,%eax
80102811:	83 ec 08             	sub    $0x8,%esp
80102814:	50                   	push   %eax
80102815:	6a 0e                	push   $0xe
80102817:	e8 bb 04 00 00       	call   80102cd7 <ioapicenable>
8010281c:	83 c4 10             	add    $0x10,%esp
  idewait(0);
8010281f:	83 ec 0c             	sub    $0xc,%esp
80102822:	6a 00                	push   $0x0
80102824:	e8 78 ff ff ff       	call   801027a1 <idewait>
80102829:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010282c:	83 ec 08             	sub    $0x8,%esp
8010282f:	68 f0 00 00 00       	push   $0xf0
80102834:	68 f6 01 00 00       	push   $0x1f6
80102839:	e8 1c ff ff ff       	call   8010275a <outb>
8010283e:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102841:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102848:	eb 24                	jmp    8010286e <ideinit+0x84>
    if(inb(0x1f7) != 0){
8010284a:	83 ec 0c             	sub    $0xc,%esp
8010284d:	68 f7 01 00 00       	push   $0x1f7
80102852:	e8 c0 fe ff ff       	call   80102717 <inb>
80102857:	83 c4 10             	add    $0x10,%esp
8010285a:	84 c0                	test   %al,%al
8010285c:	74 0c                	je     8010286a <ideinit+0x80>
      havedisk1 = 1;
8010285e:	c7 05 38 d6 10 80 01 	movl   $0x1,0x8010d638
80102865:	00 00 00 
      break;
80102868:	eb 0d                	jmp    80102877 <ideinit+0x8d>
  for(i=0; i<1000; i++){
8010286a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010286e:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102875:	7e d3                	jle    8010284a <ideinit+0x60>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102877:	83 ec 08             	sub    $0x8,%esp
8010287a:	68 e0 00 00 00       	push   $0xe0
8010287f:	68 f6 01 00 00       	push   $0x1f6
80102884:	e8 d1 fe ff ff       	call   8010275a <outb>
80102889:	83 c4 10             	add    $0x10,%esp
}
8010288c:	90                   	nop
8010288d:	c9                   	leave  
8010288e:	c3                   	ret    

8010288f <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
8010288f:	f3 0f 1e fb          	endbr32 
80102893:	55                   	push   %ebp
80102894:	89 e5                	mov    %esp,%ebp
80102896:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102899:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010289d:	75 0d                	jne    801028ac <idestart+0x1d>
    panic("idestart");
8010289f:	83 ec 0c             	sub    $0xc,%esp
801028a2:	68 f7 96 10 80       	push   $0x801096f7
801028a7:	e8 5c dd ff ff       	call   80100608 <panic>
  if(b->blockno >= FSSIZE)
801028ac:	8b 45 08             	mov    0x8(%ebp),%eax
801028af:	8b 40 08             	mov    0x8(%eax),%eax
801028b2:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801028b7:	76 0d                	jbe    801028c6 <idestart+0x37>
    panic("incorrect blockno");
801028b9:	83 ec 0c             	sub    $0xc,%esp
801028bc:	68 00 97 10 80       	push   $0x80109700
801028c1:	e8 42 dd ff ff       	call   80100608 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801028c6:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801028cd:	8b 45 08             	mov    0x8(%ebp),%eax
801028d0:	8b 50 08             	mov    0x8(%eax),%edx
801028d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d6:	0f af c2             	imul   %edx,%eax
801028d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
801028dc:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801028e0:	75 07                	jne    801028e9 <idestart+0x5a>
801028e2:	b8 20 00 00 00       	mov    $0x20,%eax
801028e7:	eb 05                	jmp    801028ee <idestart+0x5f>
801028e9:	b8 c4 00 00 00       	mov    $0xc4,%eax
801028ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
801028f1:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801028f5:	75 07                	jne    801028fe <idestart+0x6f>
801028f7:	b8 30 00 00 00       	mov    $0x30,%eax
801028fc:	eb 05                	jmp    80102903 <idestart+0x74>
801028fe:	b8 c5 00 00 00       	mov    $0xc5,%eax
80102903:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102906:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
8010290a:	7e 0d                	jle    80102919 <idestart+0x8a>
8010290c:	83 ec 0c             	sub    $0xc,%esp
8010290f:	68 f7 96 10 80       	push   $0x801096f7
80102914:	e8 ef dc ff ff       	call   80100608 <panic>

  idewait(0);
80102919:	83 ec 0c             	sub    $0xc,%esp
8010291c:	6a 00                	push   $0x0
8010291e:	e8 7e fe ff ff       	call   801027a1 <idewait>
80102923:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102926:	83 ec 08             	sub    $0x8,%esp
80102929:	6a 00                	push   $0x0
8010292b:	68 f6 03 00 00       	push   $0x3f6
80102930:	e8 25 fe ff ff       	call   8010275a <outb>
80102935:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102938:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010293b:	0f b6 c0             	movzbl %al,%eax
8010293e:	83 ec 08             	sub    $0x8,%esp
80102941:	50                   	push   %eax
80102942:	68 f2 01 00 00       	push   $0x1f2
80102947:	e8 0e fe ff ff       	call   8010275a <outb>
8010294c:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
8010294f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102952:	0f b6 c0             	movzbl %al,%eax
80102955:	83 ec 08             	sub    $0x8,%esp
80102958:	50                   	push   %eax
80102959:	68 f3 01 00 00       	push   $0x1f3
8010295e:	e8 f7 fd ff ff       	call   8010275a <outb>
80102963:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102966:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102969:	c1 f8 08             	sar    $0x8,%eax
8010296c:	0f b6 c0             	movzbl %al,%eax
8010296f:	83 ec 08             	sub    $0x8,%esp
80102972:	50                   	push   %eax
80102973:	68 f4 01 00 00       	push   $0x1f4
80102978:	e8 dd fd ff ff       	call   8010275a <outb>
8010297d:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102980:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102983:	c1 f8 10             	sar    $0x10,%eax
80102986:	0f b6 c0             	movzbl %al,%eax
80102989:	83 ec 08             	sub    $0x8,%esp
8010298c:	50                   	push   %eax
8010298d:	68 f5 01 00 00       	push   $0x1f5
80102992:	e8 c3 fd ff ff       	call   8010275a <outb>
80102997:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
8010299a:	8b 45 08             	mov    0x8(%ebp),%eax
8010299d:	8b 40 04             	mov    0x4(%eax),%eax
801029a0:	c1 e0 04             	shl    $0x4,%eax
801029a3:	83 e0 10             	and    $0x10,%eax
801029a6:	89 c2                	mov    %eax,%edx
801029a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801029ab:	c1 f8 18             	sar    $0x18,%eax
801029ae:	83 e0 0f             	and    $0xf,%eax
801029b1:	09 d0                	or     %edx,%eax
801029b3:	83 c8 e0             	or     $0xffffffe0,%eax
801029b6:	0f b6 c0             	movzbl %al,%eax
801029b9:	83 ec 08             	sub    $0x8,%esp
801029bc:	50                   	push   %eax
801029bd:	68 f6 01 00 00       	push   $0x1f6
801029c2:	e8 93 fd ff ff       	call   8010275a <outb>
801029c7:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801029ca:	8b 45 08             	mov    0x8(%ebp),%eax
801029cd:	8b 00                	mov    (%eax),%eax
801029cf:	83 e0 04             	and    $0x4,%eax
801029d2:	85 c0                	test   %eax,%eax
801029d4:	74 35                	je     80102a0b <idestart+0x17c>
    outb(0x1f7, write_cmd);
801029d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801029d9:	0f b6 c0             	movzbl %al,%eax
801029dc:	83 ec 08             	sub    $0x8,%esp
801029df:	50                   	push   %eax
801029e0:	68 f7 01 00 00       	push   $0x1f7
801029e5:	e8 70 fd ff ff       	call   8010275a <outb>
801029ea:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
801029ed:	8b 45 08             	mov    0x8(%ebp),%eax
801029f0:	83 c0 5c             	add    $0x5c,%eax
801029f3:	83 ec 04             	sub    $0x4,%esp
801029f6:	68 80 00 00 00       	push   $0x80
801029fb:	50                   	push   %eax
801029fc:	68 f0 01 00 00       	push   $0x1f0
80102a01:	e8 75 fd ff ff       	call   8010277b <outsl>
80102a06:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
80102a09:	eb 17                	jmp    80102a22 <idestart+0x193>
    outb(0x1f7, read_cmd);
80102a0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102a0e:	0f b6 c0             	movzbl %al,%eax
80102a11:	83 ec 08             	sub    $0x8,%esp
80102a14:	50                   	push   %eax
80102a15:	68 f7 01 00 00       	push   $0x1f7
80102a1a:	e8 3b fd ff ff       	call   8010275a <outb>
80102a1f:	83 c4 10             	add    $0x10,%esp
}
80102a22:	90                   	nop
80102a23:	c9                   	leave  
80102a24:	c3                   	ret    

80102a25 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102a25:	f3 0f 1e fb          	endbr32 
80102a29:	55                   	push   %ebp
80102a2a:	89 e5                	mov    %esp,%ebp
80102a2c:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102a2f:	83 ec 0c             	sub    $0xc,%esp
80102a32:	68 00 d6 10 80       	push   $0x8010d600
80102a37:	e8 3d 29 00 00       	call   80105379 <acquire>
80102a3c:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
80102a3f:	a1 34 d6 10 80       	mov    0x8010d634,%eax
80102a44:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a47:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102a4b:	75 15                	jne    80102a62 <ideintr+0x3d>
    release(&idelock);
80102a4d:	83 ec 0c             	sub    $0xc,%esp
80102a50:	68 00 d6 10 80       	push   $0x8010d600
80102a55:	e8 91 29 00 00       	call   801053eb <release>
80102a5a:	83 c4 10             	add    $0x10,%esp
    return;
80102a5d:	e9 9a 00 00 00       	jmp    80102afc <ideintr+0xd7>
  }
  idequeue = b->qnext;
80102a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a65:	8b 40 58             	mov    0x58(%eax),%eax
80102a68:	a3 34 d6 10 80       	mov    %eax,0x8010d634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a70:	8b 00                	mov    (%eax),%eax
80102a72:	83 e0 04             	and    $0x4,%eax
80102a75:	85 c0                	test   %eax,%eax
80102a77:	75 2d                	jne    80102aa6 <ideintr+0x81>
80102a79:	83 ec 0c             	sub    $0xc,%esp
80102a7c:	6a 01                	push   $0x1
80102a7e:	e8 1e fd ff ff       	call   801027a1 <idewait>
80102a83:	83 c4 10             	add    $0x10,%esp
80102a86:	85 c0                	test   %eax,%eax
80102a88:	78 1c                	js     80102aa6 <ideintr+0x81>
    insl(0x1f0, b->data, BSIZE/4);
80102a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a8d:	83 c0 5c             	add    $0x5c,%eax
80102a90:	83 ec 04             	sub    $0x4,%esp
80102a93:	68 80 00 00 00       	push   $0x80
80102a98:	50                   	push   %eax
80102a99:	68 f0 01 00 00       	push   $0x1f0
80102a9e:	e8 91 fc ff ff       	call   80102734 <insl>
80102aa3:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aa9:	8b 00                	mov    (%eax),%eax
80102aab:	83 c8 02             	or     $0x2,%eax
80102aae:	89 c2                	mov    %eax,%edx
80102ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab3:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab8:	8b 00                	mov    (%eax),%eax
80102aba:	83 e0 fb             	and    $0xfffffffb,%eax
80102abd:	89 c2                	mov    %eax,%edx
80102abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac2:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102ac4:	83 ec 0c             	sub    $0xc,%esp
80102ac7:	ff 75 f4             	pushl  -0xc(%ebp)
80102aca:	e8 2a 25 00 00       	call   80104ff9 <wakeup>
80102acf:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102ad2:	a1 34 d6 10 80       	mov    0x8010d634,%eax
80102ad7:	85 c0                	test   %eax,%eax
80102ad9:	74 11                	je     80102aec <ideintr+0xc7>
    idestart(idequeue);
80102adb:	a1 34 d6 10 80       	mov    0x8010d634,%eax
80102ae0:	83 ec 0c             	sub    $0xc,%esp
80102ae3:	50                   	push   %eax
80102ae4:	e8 a6 fd ff ff       	call   8010288f <idestart>
80102ae9:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102aec:	83 ec 0c             	sub    $0xc,%esp
80102aef:	68 00 d6 10 80       	push   $0x8010d600
80102af4:	e8 f2 28 00 00       	call   801053eb <release>
80102af9:	83 c4 10             	add    $0x10,%esp
}
80102afc:	c9                   	leave  
80102afd:	c3                   	ret    

80102afe <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102afe:	f3 0f 1e fb          	endbr32 
80102b02:	55                   	push   %ebp
80102b03:	89 e5                	mov    %esp,%ebp
80102b05:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102b08:	8b 45 08             	mov    0x8(%ebp),%eax
80102b0b:	83 c0 0c             	add    $0xc,%eax
80102b0e:	83 ec 0c             	sub    $0xc,%esp
80102b11:	50                   	push   %eax
80102b12:	e8 a3 27 00 00       	call   801052ba <holdingsleep>
80102b17:	83 c4 10             	add    $0x10,%esp
80102b1a:	85 c0                	test   %eax,%eax
80102b1c:	75 0d                	jne    80102b2b <iderw+0x2d>
    panic("iderw: buf not locked");
80102b1e:	83 ec 0c             	sub    $0xc,%esp
80102b21:	68 12 97 10 80       	push   $0x80109712
80102b26:	e8 dd da ff ff       	call   80100608 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102b2b:	8b 45 08             	mov    0x8(%ebp),%eax
80102b2e:	8b 00                	mov    (%eax),%eax
80102b30:	83 e0 06             	and    $0x6,%eax
80102b33:	83 f8 02             	cmp    $0x2,%eax
80102b36:	75 0d                	jne    80102b45 <iderw+0x47>
    panic("iderw: nothing to do");
80102b38:	83 ec 0c             	sub    $0xc,%esp
80102b3b:	68 28 97 10 80       	push   $0x80109728
80102b40:	e8 c3 da ff ff       	call   80100608 <panic>
  if(b->dev != 0 && !havedisk1)
80102b45:	8b 45 08             	mov    0x8(%ebp),%eax
80102b48:	8b 40 04             	mov    0x4(%eax),%eax
80102b4b:	85 c0                	test   %eax,%eax
80102b4d:	74 16                	je     80102b65 <iderw+0x67>
80102b4f:	a1 38 d6 10 80       	mov    0x8010d638,%eax
80102b54:	85 c0                	test   %eax,%eax
80102b56:	75 0d                	jne    80102b65 <iderw+0x67>
    panic("iderw: ide disk 1 not present");
80102b58:	83 ec 0c             	sub    $0xc,%esp
80102b5b:	68 3d 97 10 80       	push   $0x8010973d
80102b60:	e8 a3 da ff ff       	call   80100608 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102b65:	83 ec 0c             	sub    $0xc,%esp
80102b68:	68 00 d6 10 80       	push   $0x8010d600
80102b6d:	e8 07 28 00 00       	call   80105379 <acquire>
80102b72:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102b75:	8b 45 08             	mov    0x8(%ebp),%eax
80102b78:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102b7f:	c7 45 f4 34 d6 10 80 	movl   $0x8010d634,-0xc(%ebp)
80102b86:	eb 0b                	jmp    80102b93 <iderw+0x95>
80102b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b8b:	8b 00                	mov    (%eax),%eax
80102b8d:	83 c0 58             	add    $0x58,%eax
80102b90:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b96:	8b 00                	mov    (%eax),%eax
80102b98:	85 c0                	test   %eax,%eax
80102b9a:	75 ec                	jne    80102b88 <iderw+0x8a>
    ;
  *pp = b;
80102b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b9f:	8b 55 08             	mov    0x8(%ebp),%edx
80102ba2:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102ba4:	a1 34 d6 10 80       	mov    0x8010d634,%eax
80102ba9:	39 45 08             	cmp    %eax,0x8(%ebp)
80102bac:	75 23                	jne    80102bd1 <iderw+0xd3>
    idestart(b);
80102bae:	83 ec 0c             	sub    $0xc,%esp
80102bb1:	ff 75 08             	pushl  0x8(%ebp)
80102bb4:	e8 d6 fc ff ff       	call   8010288f <idestart>
80102bb9:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102bbc:	eb 13                	jmp    80102bd1 <iderw+0xd3>
    sleep(b, &idelock);
80102bbe:	83 ec 08             	sub    $0x8,%esp
80102bc1:	68 00 d6 10 80       	push   $0x8010d600
80102bc6:	ff 75 08             	pushl  0x8(%ebp)
80102bc9:	e8 39 23 00 00       	call   80104f07 <sleep>
80102bce:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102bd1:	8b 45 08             	mov    0x8(%ebp),%eax
80102bd4:	8b 00                	mov    (%eax),%eax
80102bd6:	83 e0 06             	and    $0x6,%eax
80102bd9:	83 f8 02             	cmp    $0x2,%eax
80102bdc:	75 e0                	jne    80102bbe <iderw+0xc0>
  }


  release(&idelock);
80102bde:	83 ec 0c             	sub    $0xc,%esp
80102be1:	68 00 d6 10 80       	push   $0x8010d600
80102be6:	e8 00 28 00 00       	call   801053eb <release>
80102beb:	83 c4 10             	add    $0x10,%esp
}
80102bee:	90                   	nop
80102bef:	c9                   	leave  
80102bf0:	c3                   	ret    

80102bf1 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102bf1:	f3 0f 1e fb          	endbr32 
80102bf5:	55                   	push   %ebp
80102bf6:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102bf8:	a1 d4 56 11 80       	mov    0x801156d4,%eax
80102bfd:	8b 55 08             	mov    0x8(%ebp),%edx
80102c00:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102c02:	a1 d4 56 11 80       	mov    0x801156d4,%eax
80102c07:	8b 40 10             	mov    0x10(%eax),%eax
}
80102c0a:	5d                   	pop    %ebp
80102c0b:	c3                   	ret    

80102c0c <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102c0c:	f3 0f 1e fb          	endbr32 
80102c10:	55                   	push   %ebp
80102c11:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102c13:	a1 d4 56 11 80       	mov    0x801156d4,%eax
80102c18:	8b 55 08             	mov    0x8(%ebp),%edx
80102c1b:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102c1d:	a1 d4 56 11 80       	mov    0x801156d4,%eax
80102c22:	8b 55 0c             	mov    0xc(%ebp),%edx
80102c25:	89 50 10             	mov    %edx,0x10(%eax)
}
80102c28:	90                   	nop
80102c29:	5d                   	pop    %ebp
80102c2a:	c3                   	ret    

80102c2b <ioapicinit>:

void
ioapicinit(void)
{
80102c2b:	f3 0f 1e fb          	endbr32 
80102c2f:	55                   	push   %ebp
80102c30:	89 e5                	mov    %esp,%ebp
80102c32:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102c35:	c7 05 d4 56 11 80 00 	movl   $0xfec00000,0x801156d4
80102c3c:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102c3f:	6a 01                	push   $0x1
80102c41:	e8 ab ff ff ff       	call   80102bf1 <ioapicread>
80102c46:	83 c4 04             	add    $0x4,%esp
80102c49:	c1 e8 10             	shr    $0x10,%eax
80102c4c:	25 ff 00 00 00       	and    $0xff,%eax
80102c51:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102c54:	6a 00                	push   $0x0
80102c56:	e8 96 ff ff ff       	call   80102bf1 <ioapicread>
80102c5b:	83 c4 04             	add    $0x4,%esp
80102c5e:	c1 e8 18             	shr    $0x18,%eax
80102c61:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102c64:	0f b6 05 00 58 11 80 	movzbl 0x80115800,%eax
80102c6b:	0f b6 c0             	movzbl %al,%eax
80102c6e:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102c71:	74 10                	je     80102c83 <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102c73:	83 ec 0c             	sub    $0xc,%esp
80102c76:	68 5c 97 10 80       	push   $0x8010975c
80102c7b:	e8 98 d7 ff ff       	call   80100418 <cprintf>
80102c80:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c83:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c8a:	eb 3f                	jmp    80102ccb <ioapicinit+0xa0>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102c8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c8f:	83 c0 20             	add    $0x20,%eax
80102c92:	0d 00 00 01 00       	or     $0x10000,%eax
80102c97:	89 c2                	mov    %eax,%edx
80102c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c9c:	83 c0 08             	add    $0x8,%eax
80102c9f:	01 c0                	add    %eax,%eax
80102ca1:	83 ec 08             	sub    $0x8,%esp
80102ca4:	52                   	push   %edx
80102ca5:	50                   	push   %eax
80102ca6:	e8 61 ff ff ff       	call   80102c0c <ioapicwrite>
80102cab:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cb1:	83 c0 08             	add    $0x8,%eax
80102cb4:	01 c0                	add    %eax,%eax
80102cb6:	83 c0 01             	add    $0x1,%eax
80102cb9:	83 ec 08             	sub    $0x8,%esp
80102cbc:	6a 00                	push   $0x0
80102cbe:	50                   	push   %eax
80102cbf:	e8 48 ff ff ff       	call   80102c0c <ioapicwrite>
80102cc4:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102cc7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ccb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cce:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102cd1:	7e b9                	jle    80102c8c <ioapicinit+0x61>
  }
}
80102cd3:	90                   	nop
80102cd4:	90                   	nop
80102cd5:	c9                   	leave  
80102cd6:	c3                   	ret    

80102cd7 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102cd7:	f3 0f 1e fb          	endbr32 
80102cdb:	55                   	push   %ebp
80102cdc:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102cde:	8b 45 08             	mov    0x8(%ebp),%eax
80102ce1:	83 c0 20             	add    $0x20,%eax
80102ce4:	89 c2                	mov    %eax,%edx
80102ce6:	8b 45 08             	mov    0x8(%ebp),%eax
80102ce9:	83 c0 08             	add    $0x8,%eax
80102cec:	01 c0                	add    %eax,%eax
80102cee:	52                   	push   %edx
80102cef:	50                   	push   %eax
80102cf0:	e8 17 ff ff ff       	call   80102c0c <ioapicwrite>
80102cf5:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102cf8:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cfb:	c1 e0 18             	shl    $0x18,%eax
80102cfe:	89 c2                	mov    %eax,%edx
80102d00:	8b 45 08             	mov    0x8(%ebp),%eax
80102d03:	83 c0 08             	add    $0x8,%eax
80102d06:	01 c0                	add    %eax,%eax
80102d08:	83 c0 01             	add    $0x1,%eax
80102d0b:	52                   	push   %edx
80102d0c:	50                   	push   %eax
80102d0d:	e8 fa fe ff ff       	call   80102c0c <ioapicwrite>
80102d12:	83 c4 08             	add    $0x8,%esp
}
80102d15:	90                   	nop
80102d16:	c9                   	leave  
80102d17:	c3                   	ret    

80102d18 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102d18:	f3 0f 1e fb          	endbr32 
80102d1c:	55                   	push   %ebp
80102d1d:	89 e5                	mov    %esp,%ebp
80102d1f:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102d22:	83 ec 08             	sub    $0x8,%esp
80102d25:	68 90 97 10 80       	push   $0x80109790
80102d2a:	68 e0 56 11 80       	push   $0x801156e0
80102d2f:	e8 1f 26 00 00       	call   80105353 <initlock>
80102d34:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102d37:	c7 05 14 57 11 80 00 	movl   $0x0,0x80115714
80102d3e:	00 00 00 
  freerange(vstart, vend);
80102d41:	83 ec 08             	sub    $0x8,%esp
80102d44:	ff 75 0c             	pushl  0xc(%ebp)
80102d47:	ff 75 08             	pushl  0x8(%ebp)
80102d4a:	e8 2e 00 00 00       	call   80102d7d <freerange>
80102d4f:	83 c4 10             	add    $0x10,%esp
}
80102d52:	90                   	nop
80102d53:	c9                   	leave  
80102d54:	c3                   	ret    

80102d55 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102d55:	f3 0f 1e fb          	endbr32 
80102d59:	55                   	push   %ebp
80102d5a:	89 e5                	mov    %esp,%ebp
80102d5c:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102d5f:	83 ec 08             	sub    $0x8,%esp
80102d62:	ff 75 0c             	pushl  0xc(%ebp)
80102d65:	ff 75 08             	pushl  0x8(%ebp)
80102d68:	e8 10 00 00 00       	call   80102d7d <freerange>
80102d6d:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102d70:	c7 05 14 57 11 80 01 	movl   $0x1,0x80115714
80102d77:	00 00 00 
}
80102d7a:	90                   	nop
80102d7b:	c9                   	leave  
80102d7c:	c3                   	ret    

80102d7d <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d7d:	f3 0f 1e fb          	endbr32 
80102d81:	55                   	push   %ebp
80102d82:	89 e5                	mov    %esp,%ebp
80102d84:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102d87:	8b 45 08             	mov    0x8(%ebp),%eax
80102d8a:	05 ff 0f 00 00       	add    $0xfff,%eax
80102d8f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102d94:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d97:	eb 15                	jmp    80102dae <freerange+0x31>
    kfree(p);
80102d99:	83 ec 0c             	sub    $0xc,%esp
80102d9c:	ff 75 f4             	pushl  -0xc(%ebp)
80102d9f:	e8 1b 00 00 00       	call   80102dbf <kfree>
80102da4:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102da7:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102dae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102db1:	05 00 10 00 00       	add    $0x1000,%eax
80102db6:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102db9:	73 de                	jae    80102d99 <freerange+0x1c>
}
80102dbb:	90                   	nop
80102dbc:	90                   	nop
80102dbd:	c9                   	leave  
80102dbe:	c3                   	ret    

80102dbf <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102dbf:	f3 0f 1e fb          	endbr32 
80102dc3:	55                   	push   %ebp
80102dc4:	89 e5                	mov    %esp,%ebp
80102dc6:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102dc9:	8b 45 08             	mov    0x8(%ebp),%eax
80102dcc:	25 ff 0f 00 00       	and    $0xfff,%eax
80102dd1:	85 c0                	test   %eax,%eax
80102dd3:	75 18                	jne    80102ded <kfree+0x2e>
80102dd5:	81 7d 08 48 8e 11 80 	cmpl   $0x80118e48,0x8(%ebp)
80102ddc:	72 0f                	jb     80102ded <kfree+0x2e>
80102dde:	8b 45 08             	mov    0x8(%ebp),%eax
80102de1:	05 00 00 00 80       	add    $0x80000000,%eax
80102de6:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102deb:	76 0d                	jbe    80102dfa <kfree+0x3b>
    panic("kfree");
80102ded:	83 ec 0c             	sub    $0xc,%esp
80102df0:	68 95 97 10 80       	push   $0x80109795
80102df5:	e8 0e d8 ff ff       	call   80100608 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102dfa:	83 ec 04             	sub    $0x4,%esp
80102dfd:	68 00 10 00 00       	push   $0x1000
80102e02:	6a 01                	push   $0x1
80102e04:	ff 75 08             	pushl  0x8(%ebp)
80102e07:	e8 0c 28 00 00       	call   80105618 <memset>
80102e0c:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102e0f:	a1 14 57 11 80       	mov    0x80115714,%eax
80102e14:	85 c0                	test   %eax,%eax
80102e16:	74 10                	je     80102e28 <kfree+0x69>
    acquire(&kmem.lock);
80102e18:	83 ec 0c             	sub    $0xc,%esp
80102e1b:	68 e0 56 11 80       	push   $0x801156e0
80102e20:	e8 54 25 00 00       	call   80105379 <acquire>
80102e25:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102e28:	8b 45 08             	mov    0x8(%ebp),%eax
80102e2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102e2e:	8b 15 18 57 11 80    	mov    0x80115718,%edx
80102e34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e37:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102e39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e3c:	a3 18 57 11 80       	mov    %eax,0x80115718
  if(kmem.use_lock)
80102e41:	a1 14 57 11 80       	mov    0x80115714,%eax
80102e46:	85 c0                	test   %eax,%eax
80102e48:	74 10                	je     80102e5a <kfree+0x9b>
    release(&kmem.lock);
80102e4a:	83 ec 0c             	sub    $0xc,%esp
80102e4d:	68 e0 56 11 80       	push   $0x801156e0
80102e52:	e8 94 25 00 00       	call   801053eb <release>
80102e57:	83 c4 10             	add    $0x10,%esp
}
80102e5a:	90                   	nop
80102e5b:	c9                   	leave  
80102e5c:	c3                   	ret    

80102e5d <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102e5d:	f3 0f 1e fb          	endbr32 
80102e61:	55                   	push   %ebp
80102e62:	89 e5                	mov    %esp,%ebp
80102e64:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102e67:	a1 14 57 11 80       	mov    0x80115714,%eax
80102e6c:	85 c0                	test   %eax,%eax
80102e6e:	74 10                	je     80102e80 <kalloc+0x23>
    acquire(&kmem.lock);
80102e70:	83 ec 0c             	sub    $0xc,%esp
80102e73:	68 e0 56 11 80       	push   $0x801156e0
80102e78:	e8 fc 24 00 00       	call   80105379 <acquire>
80102e7d:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102e80:	a1 18 57 11 80       	mov    0x80115718,%eax
80102e85:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102e88:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e8c:	74 0a                	je     80102e98 <kalloc+0x3b>
    kmem.freelist = r->next;
80102e8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e91:	8b 00                	mov    (%eax),%eax
80102e93:	a3 18 57 11 80       	mov    %eax,0x80115718
  if(kmem.use_lock)
80102e98:	a1 14 57 11 80       	mov    0x80115714,%eax
80102e9d:	85 c0                	test   %eax,%eax
80102e9f:	74 10                	je     80102eb1 <kalloc+0x54>
    release(&kmem.lock);
80102ea1:	83 ec 0c             	sub    $0xc,%esp
80102ea4:	68 e0 56 11 80       	push   $0x801156e0
80102ea9:	e8 3d 25 00 00       	call   801053eb <release>
80102eae:	83 c4 10             	add    $0x10,%esp
  cprintf("p4Debug : kalloc returns %d %x\n", PPN(V2P(r)), V2P(r));
80102eb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102eb4:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80102eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ebd:	05 00 00 00 80       	add    $0x80000000,%eax
80102ec2:	c1 e8 0c             	shr    $0xc,%eax
80102ec5:	83 ec 04             	sub    $0x4,%esp
80102ec8:	52                   	push   %edx
80102ec9:	50                   	push   %eax
80102eca:	68 9c 97 10 80       	push   $0x8010979c
80102ecf:	e8 44 d5 ff ff       	call   80100418 <cprintf>
80102ed4:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102ed7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102eda:	c9                   	leave  
80102edb:	c3                   	ret    

80102edc <inb>:
{
80102edc:	55                   	push   %ebp
80102edd:	89 e5                	mov    %esp,%ebp
80102edf:	83 ec 14             	sub    $0x14,%esp
80102ee2:	8b 45 08             	mov    0x8(%ebp),%eax
80102ee5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ee9:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102eed:	89 c2                	mov    %eax,%edx
80102eef:	ec                   	in     (%dx),%al
80102ef0:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102ef3:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102ef7:	c9                   	leave  
80102ef8:	c3                   	ret    

80102ef9 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102ef9:	f3 0f 1e fb          	endbr32 
80102efd:	55                   	push   %ebp
80102efe:	89 e5                	mov    %esp,%ebp
80102f00:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102f03:	6a 64                	push   $0x64
80102f05:	e8 d2 ff ff ff       	call   80102edc <inb>
80102f0a:	83 c4 04             	add    $0x4,%esp
80102f0d:	0f b6 c0             	movzbl %al,%eax
80102f10:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102f13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f16:	83 e0 01             	and    $0x1,%eax
80102f19:	85 c0                	test   %eax,%eax
80102f1b:	75 0a                	jne    80102f27 <kbdgetc+0x2e>
    return -1;
80102f1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102f22:	e9 23 01 00 00       	jmp    8010304a <kbdgetc+0x151>
  data = inb(KBDATAP);
80102f27:	6a 60                	push   $0x60
80102f29:	e8 ae ff ff ff       	call   80102edc <inb>
80102f2e:	83 c4 04             	add    $0x4,%esp
80102f31:	0f b6 c0             	movzbl %al,%eax
80102f34:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102f37:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102f3e:	75 17                	jne    80102f57 <kbdgetc+0x5e>
    shift |= E0ESC;
80102f40:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80102f45:	83 c8 40             	or     $0x40,%eax
80102f48:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
    return 0;
80102f4d:	b8 00 00 00 00       	mov    $0x0,%eax
80102f52:	e9 f3 00 00 00       	jmp    8010304a <kbdgetc+0x151>
  } else if(data & 0x80){
80102f57:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f5a:	25 80 00 00 00       	and    $0x80,%eax
80102f5f:	85 c0                	test   %eax,%eax
80102f61:	74 45                	je     80102fa8 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102f63:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80102f68:	83 e0 40             	and    $0x40,%eax
80102f6b:	85 c0                	test   %eax,%eax
80102f6d:	75 08                	jne    80102f77 <kbdgetc+0x7e>
80102f6f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f72:	83 e0 7f             	and    $0x7f,%eax
80102f75:	eb 03                	jmp    80102f7a <kbdgetc+0x81>
80102f77:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f7a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102f7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f80:	05 20 b0 10 80       	add    $0x8010b020,%eax
80102f85:	0f b6 00             	movzbl (%eax),%eax
80102f88:	83 c8 40             	or     $0x40,%eax
80102f8b:	0f b6 c0             	movzbl %al,%eax
80102f8e:	f7 d0                	not    %eax
80102f90:	89 c2                	mov    %eax,%edx
80102f92:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80102f97:	21 d0                	and    %edx,%eax
80102f99:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
    return 0;
80102f9e:	b8 00 00 00 00       	mov    $0x0,%eax
80102fa3:	e9 a2 00 00 00       	jmp    8010304a <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102fa8:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80102fad:	83 e0 40             	and    $0x40,%eax
80102fb0:	85 c0                	test   %eax,%eax
80102fb2:	74 14                	je     80102fc8 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102fb4:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102fbb:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80102fc0:	83 e0 bf             	and    $0xffffffbf,%eax
80102fc3:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
  }

  shift |= shiftcode[data];
80102fc8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fcb:	05 20 b0 10 80       	add    $0x8010b020,%eax
80102fd0:	0f b6 00             	movzbl (%eax),%eax
80102fd3:	0f b6 d0             	movzbl %al,%edx
80102fd6:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80102fdb:	09 d0                	or     %edx,%eax
80102fdd:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
  shift ^= togglecode[data];
80102fe2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fe5:	05 20 b1 10 80       	add    $0x8010b120,%eax
80102fea:	0f b6 00             	movzbl (%eax),%eax
80102fed:	0f b6 d0             	movzbl %al,%edx
80102ff0:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80102ff5:	31 d0                	xor    %edx,%eax
80102ff7:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102ffc:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80103001:	83 e0 03             	and    $0x3,%eax
80103004:	8b 14 85 20 b5 10 80 	mov    -0x7fef4ae0(,%eax,4),%edx
8010300b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010300e:	01 d0                	add    %edx,%eax
80103010:	0f b6 00             	movzbl (%eax),%eax
80103013:	0f b6 c0             	movzbl %al,%eax
80103016:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80103019:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
8010301e:	83 e0 08             	and    $0x8,%eax
80103021:	85 c0                	test   %eax,%eax
80103023:	74 22                	je     80103047 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80103025:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80103029:	76 0c                	jbe    80103037 <kbdgetc+0x13e>
8010302b:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
8010302f:	77 06                	ja     80103037 <kbdgetc+0x13e>
      c += 'A' - 'a';
80103031:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80103035:	eb 10                	jmp    80103047 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80103037:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
8010303b:	76 0a                	jbe    80103047 <kbdgetc+0x14e>
8010303d:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80103041:	77 04                	ja     80103047 <kbdgetc+0x14e>
      c += 'a' - 'A';
80103043:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80103047:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010304a:	c9                   	leave  
8010304b:	c3                   	ret    

8010304c <kbdintr>:

void
kbdintr(void)
{
8010304c:	f3 0f 1e fb          	endbr32 
80103050:	55                   	push   %ebp
80103051:	89 e5                	mov    %esp,%ebp
80103053:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80103056:	83 ec 0c             	sub    $0xc,%esp
80103059:	68 f9 2e 10 80       	push   $0x80102ef9
8010305e:	e8 45 d8 ff ff       	call   801008a8 <consoleintr>
80103063:	83 c4 10             	add    $0x10,%esp
}
80103066:	90                   	nop
80103067:	c9                   	leave  
80103068:	c3                   	ret    

80103069 <inb>:
{
80103069:	55                   	push   %ebp
8010306a:	89 e5                	mov    %esp,%ebp
8010306c:	83 ec 14             	sub    $0x14,%esp
8010306f:	8b 45 08             	mov    0x8(%ebp),%eax
80103072:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103076:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010307a:	89 c2                	mov    %eax,%edx
8010307c:	ec                   	in     (%dx),%al
8010307d:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103080:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103084:	c9                   	leave  
80103085:	c3                   	ret    

80103086 <outb>:
{
80103086:	55                   	push   %ebp
80103087:	89 e5                	mov    %esp,%ebp
80103089:	83 ec 08             	sub    $0x8,%esp
8010308c:	8b 45 08             	mov    0x8(%ebp),%eax
8010308f:	8b 55 0c             	mov    0xc(%ebp),%edx
80103092:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103096:	89 d0                	mov    %edx,%eax
80103098:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010309b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010309f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801030a3:	ee                   	out    %al,(%dx)
}
801030a4:	90                   	nop
801030a5:	c9                   	leave  
801030a6:	c3                   	ret    

801030a7 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
801030a7:	f3 0f 1e fb          	endbr32 
801030ab:	55                   	push   %ebp
801030ac:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801030ae:	a1 1c 57 11 80       	mov    0x8011571c,%eax
801030b3:	8b 55 08             	mov    0x8(%ebp),%edx
801030b6:	c1 e2 02             	shl    $0x2,%edx
801030b9:	01 c2                	add    %eax,%edx
801030bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801030be:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801030c0:	a1 1c 57 11 80       	mov    0x8011571c,%eax
801030c5:	83 c0 20             	add    $0x20,%eax
801030c8:	8b 00                	mov    (%eax),%eax
}
801030ca:	90                   	nop
801030cb:	5d                   	pop    %ebp
801030cc:	c3                   	ret    

801030cd <lapicinit>:

void
lapicinit(void)
{
801030cd:	f3 0f 1e fb          	endbr32 
801030d1:	55                   	push   %ebp
801030d2:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801030d4:	a1 1c 57 11 80       	mov    0x8011571c,%eax
801030d9:	85 c0                	test   %eax,%eax
801030db:	0f 84 0c 01 00 00    	je     801031ed <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801030e1:	68 3f 01 00 00       	push   $0x13f
801030e6:	6a 3c                	push   $0x3c
801030e8:	e8 ba ff ff ff       	call   801030a7 <lapicw>
801030ed:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801030f0:	6a 0b                	push   $0xb
801030f2:	68 f8 00 00 00       	push   $0xf8
801030f7:	e8 ab ff ff ff       	call   801030a7 <lapicw>
801030fc:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801030ff:	68 20 00 02 00       	push   $0x20020
80103104:	68 c8 00 00 00       	push   $0xc8
80103109:	e8 99 ff ff ff       	call   801030a7 <lapicw>
8010310e:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80103111:	68 80 96 98 00       	push   $0x989680
80103116:	68 e0 00 00 00       	push   $0xe0
8010311b:	e8 87 ff ff ff       	call   801030a7 <lapicw>
80103120:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80103123:	68 00 00 01 00       	push   $0x10000
80103128:	68 d4 00 00 00       	push   $0xd4
8010312d:	e8 75 ff ff ff       	call   801030a7 <lapicw>
80103132:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80103135:	68 00 00 01 00       	push   $0x10000
8010313a:	68 d8 00 00 00       	push   $0xd8
8010313f:	e8 63 ff ff ff       	call   801030a7 <lapicw>
80103144:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80103147:	a1 1c 57 11 80       	mov    0x8011571c,%eax
8010314c:	83 c0 30             	add    $0x30,%eax
8010314f:	8b 00                	mov    (%eax),%eax
80103151:	c1 e8 10             	shr    $0x10,%eax
80103154:	25 fc 00 00 00       	and    $0xfc,%eax
80103159:	85 c0                	test   %eax,%eax
8010315b:	74 12                	je     8010316f <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
8010315d:	68 00 00 01 00       	push   $0x10000
80103162:	68 d0 00 00 00       	push   $0xd0
80103167:	e8 3b ff ff ff       	call   801030a7 <lapicw>
8010316c:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
8010316f:	6a 33                	push   $0x33
80103171:	68 dc 00 00 00       	push   $0xdc
80103176:	e8 2c ff ff ff       	call   801030a7 <lapicw>
8010317b:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
8010317e:	6a 00                	push   $0x0
80103180:	68 a0 00 00 00       	push   $0xa0
80103185:	e8 1d ff ff ff       	call   801030a7 <lapicw>
8010318a:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
8010318d:	6a 00                	push   $0x0
8010318f:	68 a0 00 00 00       	push   $0xa0
80103194:	e8 0e ff ff ff       	call   801030a7 <lapicw>
80103199:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
8010319c:	6a 00                	push   $0x0
8010319e:	6a 2c                	push   $0x2c
801031a0:	e8 02 ff ff ff       	call   801030a7 <lapicw>
801031a5:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
801031a8:	6a 00                	push   $0x0
801031aa:	68 c4 00 00 00       	push   $0xc4
801031af:	e8 f3 fe ff ff       	call   801030a7 <lapicw>
801031b4:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801031b7:	68 00 85 08 00       	push   $0x88500
801031bc:	68 c0 00 00 00       	push   $0xc0
801031c1:	e8 e1 fe ff ff       	call   801030a7 <lapicw>
801031c6:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
801031c9:	90                   	nop
801031ca:	a1 1c 57 11 80       	mov    0x8011571c,%eax
801031cf:	05 00 03 00 00       	add    $0x300,%eax
801031d4:	8b 00                	mov    (%eax),%eax
801031d6:	25 00 10 00 00       	and    $0x1000,%eax
801031db:	85 c0                	test   %eax,%eax
801031dd:	75 eb                	jne    801031ca <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801031df:	6a 00                	push   $0x0
801031e1:	6a 20                	push   $0x20
801031e3:	e8 bf fe ff ff       	call   801030a7 <lapicw>
801031e8:	83 c4 08             	add    $0x8,%esp
801031eb:	eb 01                	jmp    801031ee <lapicinit+0x121>
    return;
801031ed:	90                   	nop
}
801031ee:	c9                   	leave  
801031ef:	c3                   	ret    

801031f0 <lapicid>:

int
lapicid(void)
{
801031f0:	f3 0f 1e fb          	endbr32 
801031f4:	55                   	push   %ebp
801031f5:	89 e5                	mov    %esp,%ebp
  if (!lapic)
801031f7:	a1 1c 57 11 80       	mov    0x8011571c,%eax
801031fc:	85 c0                	test   %eax,%eax
801031fe:	75 07                	jne    80103207 <lapicid+0x17>
    return 0;
80103200:	b8 00 00 00 00       	mov    $0x0,%eax
80103205:	eb 0d                	jmp    80103214 <lapicid+0x24>
  return lapic[ID] >> 24;
80103207:	a1 1c 57 11 80       	mov    0x8011571c,%eax
8010320c:	83 c0 20             	add    $0x20,%eax
8010320f:	8b 00                	mov    (%eax),%eax
80103211:	c1 e8 18             	shr    $0x18,%eax
}
80103214:	5d                   	pop    %ebp
80103215:	c3                   	ret    

80103216 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103216:	f3 0f 1e fb          	endbr32 
8010321a:	55                   	push   %ebp
8010321b:	89 e5                	mov    %esp,%ebp
  if(lapic)
8010321d:	a1 1c 57 11 80       	mov    0x8011571c,%eax
80103222:	85 c0                	test   %eax,%eax
80103224:	74 0c                	je     80103232 <lapiceoi+0x1c>
    lapicw(EOI, 0);
80103226:	6a 00                	push   $0x0
80103228:	6a 2c                	push   $0x2c
8010322a:	e8 78 fe ff ff       	call   801030a7 <lapicw>
8010322f:	83 c4 08             	add    $0x8,%esp
}
80103232:	90                   	nop
80103233:	c9                   	leave  
80103234:	c3                   	ret    

80103235 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103235:	f3 0f 1e fb          	endbr32 
80103239:	55                   	push   %ebp
8010323a:	89 e5                	mov    %esp,%ebp
}
8010323c:	90                   	nop
8010323d:	5d                   	pop    %ebp
8010323e:	c3                   	ret    

8010323f <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
8010323f:	f3 0f 1e fb          	endbr32 
80103243:	55                   	push   %ebp
80103244:	89 e5                	mov    %esp,%ebp
80103246:	83 ec 14             	sub    $0x14,%esp
80103249:	8b 45 08             	mov    0x8(%ebp),%eax
8010324c:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
8010324f:	6a 0f                	push   $0xf
80103251:	6a 70                	push   $0x70
80103253:	e8 2e fe ff ff       	call   80103086 <outb>
80103258:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
8010325b:	6a 0a                	push   $0xa
8010325d:	6a 71                	push   $0x71
8010325f:	e8 22 fe ff ff       	call   80103086 <outb>
80103264:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103267:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010326e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103271:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103276:	8b 45 0c             	mov    0xc(%ebp),%eax
80103279:	c1 e8 04             	shr    $0x4,%eax
8010327c:	89 c2                	mov    %eax,%edx
8010327e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103281:	83 c0 02             	add    $0x2,%eax
80103284:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103287:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010328b:	c1 e0 18             	shl    $0x18,%eax
8010328e:	50                   	push   %eax
8010328f:	68 c4 00 00 00       	push   $0xc4
80103294:	e8 0e fe ff ff       	call   801030a7 <lapicw>
80103299:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010329c:	68 00 c5 00 00       	push   $0xc500
801032a1:	68 c0 00 00 00       	push   $0xc0
801032a6:	e8 fc fd ff ff       	call   801030a7 <lapicw>
801032ab:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801032ae:	68 c8 00 00 00       	push   $0xc8
801032b3:	e8 7d ff ff ff       	call   80103235 <microdelay>
801032b8:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801032bb:	68 00 85 00 00       	push   $0x8500
801032c0:	68 c0 00 00 00       	push   $0xc0
801032c5:	e8 dd fd ff ff       	call   801030a7 <lapicw>
801032ca:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801032cd:	6a 64                	push   $0x64
801032cf:	e8 61 ff ff ff       	call   80103235 <microdelay>
801032d4:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801032d7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801032de:	eb 3d                	jmp    8010331d <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
801032e0:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801032e4:	c1 e0 18             	shl    $0x18,%eax
801032e7:	50                   	push   %eax
801032e8:	68 c4 00 00 00       	push   $0xc4
801032ed:	e8 b5 fd ff ff       	call   801030a7 <lapicw>
801032f2:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801032f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801032f8:	c1 e8 0c             	shr    $0xc,%eax
801032fb:	80 cc 06             	or     $0x6,%ah
801032fe:	50                   	push   %eax
801032ff:	68 c0 00 00 00       	push   $0xc0
80103304:	e8 9e fd ff ff       	call   801030a7 <lapicw>
80103309:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
8010330c:	68 c8 00 00 00       	push   $0xc8
80103311:	e8 1f ff ff ff       	call   80103235 <microdelay>
80103316:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80103319:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010331d:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103321:	7e bd                	jle    801032e0 <lapicstartap+0xa1>
  }
}
80103323:	90                   	nop
80103324:	90                   	nop
80103325:	c9                   	leave  
80103326:	c3                   	ret    

80103327 <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
80103327:	f3 0f 1e fb          	endbr32 
8010332b:	55                   	push   %ebp
8010332c:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
8010332e:	8b 45 08             	mov    0x8(%ebp),%eax
80103331:	0f b6 c0             	movzbl %al,%eax
80103334:	50                   	push   %eax
80103335:	6a 70                	push   $0x70
80103337:	e8 4a fd ff ff       	call   80103086 <outb>
8010333c:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010333f:	68 c8 00 00 00       	push   $0xc8
80103344:	e8 ec fe ff ff       	call   80103235 <microdelay>
80103349:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
8010334c:	6a 71                	push   $0x71
8010334e:	e8 16 fd ff ff       	call   80103069 <inb>
80103353:	83 c4 04             	add    $0x4,%esp
80103356:	0f b6 c0             	movzbl %al,%eax
}
80103359:	c9                   	leave  
8010335a:	c3                   	ret    

8010335b <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
8010335b:	f3 0f 1e fb          	endbr32 
8010335f:	55                   	push   %ebp
80103360:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103362:	6a 00                	push   $0x0
80103364:	e8 be ff ff ff       	call   80103327 <cmos_read>
80103369:	83 c4 04             	add    $0x4,%esp
8010336c:	8b 55 08             	mov    0x8(%ebp),%edx
8010336f:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103371:	6a 02                	push   $0x2
80103373:	e8 af ff ff ff       	call   80103327 <cmos_read>
80103378:	83 c4 04             	add    $0x4,%esp
8010337b:	8b 55 08             	mov    0x8(%ebp),%edx
8010337e:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103381:	6a 04                	push   $0x4
80103383:	e8 9f ff ff ff       	call   80103327 <cmos_read>
80103388:	83 c4 04             	add    $0x4,%esp
8010338b:	8b 55 08             	mov    0x8(%ebp),%edx
8010338e:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103391:	6a 07                	push   $0x7
80103393:	e8 8f ff ff ff       	call   80103327 <cmos_read>
80103398:	83 c4 04             	add    $0x4,%esp
8010339b:	8b 55 08             	mov    0x8(%ebp),%edx
8010339e:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
801033a1:	6a 08                	push   $0x8
801033a3:	e8 7f ff ff ff       	call   80103327 <cmos_read>
801033a8:	83 c4 04             	add    $0x4,%esp
801033ab:	8b 55 08             	mov    0x8(%ebp),%edx
801033ae:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
801033b1:	6a 09                	push   $0x9
801033b3:	e8 6f ff ff ff       	call   80103327 <cmos_read>
801033b8:	83 c4 04             	add    $0x4,%esp
801033bb:	8b 55 08             	mov    0x8(%ebp),%edx
801033be:	89 42 14             	mov    %eax,0x14(%edx)
}
801033c1:	90                   	nop
801033c2:	c9                   	leave  
801033c3:	c3                   	ret    

801033c4 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
801033c4:	f3 0f 1e fb          	endbr32 
801033c8:	55                   	push   %ebp
801033c9:	89 e5                	mov    %esp,%ebp
801033cb:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801033ce:	6a 0b                	push   $0xb
801033d0:	e8 52 ff ff ff       	call   80103327 <cmos_read>
801033d5:	83 c4 04             	add    $0x4,%esp
801033d8:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801033db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033de:	83 e0 04             	and    $0x4,%eax
801033e1:	85 c0                	test   %eax,%eax
801033e3:	0f 94 c0             	sete   %al
801033e6:	0f b6 c0             	movzbl %al,%eax
801033e9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801033ec:	8d 45 d8             	lea    -0x28(%ebp),%eax
801033ef:	50                   	push   %eax
801033f0:	e8 66 ff ff ff       	call   8010335b <fill_rtcdate>
801033f5:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801033f8:	6a 0a                	push   $0xa
801033fa:	e8 28 ff ff ff       	call   80103327 <cmos_read>
801033ff:	83 c4 04             	add    $0x4,%esp
80103402:	25 80 00 00 00       	and    $0x80,%eax
80103407:	85 c0                	test   %eax,%eax
80103409:	75 27                	jne    80103432 <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
8010340b:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010340e:	50                   	push   %eax
8010340f:	e8 47 ff ff ff       	call   8010335b <fill_rtcdate>
80103414:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80103417:	83 ec 04             	sub    $0x4,%esp
8010341a:	6a 18                	push   $0x18
8010341c:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010341f:	50                   	push   %eax
80103420:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103423:	50                   	push   %eax
80103424:	e8 5a 22 00 00       	call   80105683 <memcmp>
80103429:	83 c4 10             	add    $0x10,%esp
8010342c:	85 c0                	test   %eax,%eax
8010342e:	74 05                	je     80103435 <cmostime+0x71>
80103430:	eb ba                	jmp    801033ec <cmostime+0x28>
        continue;
80103432:	90                   	nop
    fill_rtcdate(&t1);
80103433:	eb b7                	jmp    801033ec <cmostime+0x28>
      break;
80103435:	90                   	nop
  }

  // convert
  if(bcd) {
80103436:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010343a:	0f 84 b4 00 00 00    	je     801034f4 <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103440:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103443:	c1 e8 04             	shr    $0x4,%eax
80103446:	89 c2                	mov    %eax,%edx
80103448:	89 d0                	mov    %edx,%eax
8010344a:	c1 e0 02             	shl    $0x2,%eax
8010344d:	01 d0                	add    %edx,%eax
8010344f:	01 c0                	add    %eax,%eax
80103451:	89 c2                	mov    %eax,%edx
80103453:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103456:	83 e0 0f             	and    $0xf,%eax
80103459:	01 d0                	add    %edx,%eax
8010345b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
8010345e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103461:	c1 e8 04             	shr    $0x4,%eax
80103464:	89 c2                	mov    %eax,%edx
80103466:	89 d0                	mov    %edx,%eax
80103468:	c1 e0 02             	shl    $0x2,%eax
8010346b:	01 d0                	add    %edx,%eax
8010346d:	01 c0                	add    %eax,%eax
8010346f:	89 c2                	mov    %eax,%edx
80103471:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103474:	83 e0 0f             	and    $0xf,%eax
80103477:	01 d0                	add    %edx,%eax
80103479:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010347c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010347f:	c1 e8 04             	shr    $0x4,%eax
80103482:	89 c2                	mov    %eax,%edx
80103484:	89 d0                	mov    %edx,%eax
80103486:	c1 e0 02             	shl    $0x2,%eax
80103489:	01 d0                	add    %edx,%eax
8010348b:	01 c0                	add    %eax,%eax
8010348d:	89 c2                	mov    %eax,%edx
8010348f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103492:	83 e0 0f             	and    $0xf,%eax
80103495:	01 d0                	add    %edx,%eax
80103497:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010349a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010349d:	c1 e8 04             	shr    $0x4,%eax
801034a0:	89 c2                	mov    %eax,%edx
801034a2:	89 d0                	mov    %edx,%eax
801034a4:	c1 e0 02             	shl    $0x2,%eax
801034a7:	01 d0                	add    %edx,%eax
801034a9:	01 c0                	add    %eax,%eax
801034ab:	89 c2                	mov    %eax,%edx
801034ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801034b0:	83 e0 0f             	and    $0xf,%eax
801034b3:	01 d0                	add    %edx,%eax
801034b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801034b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801034bb:	c1 e8 04             	shr    $0x4,%eax
801034be:	89 c2                	mov    %eax,%edx
801034c0:	89 d0                	mov    %edx,%eax
801034c2:	c1 e0 02             	shl    $0x2,%eax
801034c5:	01 d0                	add    %edx,%eax
801034c7:	01 c0                	add    %eax,%eax
801034c9:	89 c2                	mov    %eax,%edx
801034cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801034ce:	83 e0 0f             	and    $0xf,%eax
801034d1:	01 d0                	add    %edx,%eax
801034d3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801034d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034d9:	c1 e8 04             	shr    $0x4,%eax
801034dc:	89 c2                	mov    %eax,%edx
801034de:	89 d0                	mov    %edx,%eax
801034e0:	c1 e0 02             	shl    $0x2,%eax
801034e3:	01 d0                	add    %edx,%eax
801034e5:	01 c0                	add    %eax,%eax
801034e7:	89 c2                	mov    %eax,%edx
801034e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034ec:	83 e0 0f             	and    $0xf,%eax
801034ef:	01 d0                	add    %edx,%eax
801034f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801034f4:	8b 45 08             	mov    0x8(%ebp),%eax
801034f7:	8b 55 d8             	mov    -0x28(%ebp),%edx
801034fa:	89 10                	mov    %edx,(%eax)
801034fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
801034ff:	89 50 04             	mov    %edx,0x4(%eax)
80103502:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103505:	89 50 08             	mov    %edx,0x8(%eax)
80103508:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010350b:	89 50 0c             	mov    %edx,0xc(%eax)
8010350e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103511:	89 50 10             	mov    %edx,0x10(%eax)
80103514:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103517:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
8010351a:	8b 45 08             	mov    0x8(%ebp),%eax
8010351d:	8b 40 14             	mov    0x14(%eax),%eax
80103520:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103526:	8b 45 08             	mov    0x8(%ebp),%eax
80103529:	89 50 14             	mov    %edx,0x14(%eax)
}
8010352c:	90                   	nop
8010352d:	c9                   	leave  
8010352e:	c3                   	ret    

8010352f <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
8010352f:	f3 0f 1e fb          	endbr32 
80103533:	55                   	push   %ebp
80103534:	89 e5                	mov    %esp,%ebp
80103536:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103539:	83 ec 08             	sub    $0x8,%esp
8010353c:	68 bc 97 10 80       	push   $0x801097bc
80103541:	68 20 57 11 80       	push   $0x80115720
80103546:	e8 08 1e 00 00       	call   80105353 <initlock>
8010354b:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010354e:	83 ec 08             	sub    $0x8,%esp
80103551:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103554:	50                   	push   %eax
80103555:	ff 75 08             	pushl  0x8(%ebp)
80103558:	e8 d3 df ff ff       	call   80101530 <readsb>
8010355d:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80103560:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103563:	a3 54 57 11 80       	mov    %eax,0x80115754
  log.size = sb.nlog;
80103568:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010356b:	a3 58 57 11 80       	mov    %eax,0x80115758
  log.dev = dev;
80103570:	8b 45 08             	mov    0x8(%ebp),%eax
80103573:	a3 64 57 11 80       	mov    %eax,0x80115764
  recover_from_log();
80103578:	e8 bf 01 00 00       	call   8010373c <recover_from_log>
}
8010357d:	90                   	nop
8010357e:	c9                   	leave  
8010357f:	c3                   	ret    

80103580 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80103580:	f3 0f 1e fb          	endbr32 
80103584:	55                   	push   %ebp
80103585:	89 e5                	mov    %esp,%ebp
80103587:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010358a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103591:	e9 95 00 00 00       	jmp    8010362b <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103596:	8b 15 54 57 11 80    	mov    0x80115754,%edx
8010359c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010359f:	01 d0                	add    %edx,%eax
801035a1:	83 c0 01             	add    $0x1,%eax
801035a4:	89 c2                	mov    %eax,%edx
801035a6:	a1 64 57 11 80       	mov    0x80115764,%eax
801035ab:	83 ec 08             	sub    $0x8,%esp
801035ae:	52                   	push   %edx
801035af:	50                   	push   %eax
801035b0:	e8 22 cc ff ff       	call   801001d7 <bread>
801035b5:	83 c4 10             	add    $0x10,%esp
801035b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801035bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035be:	83 c0 10             	add    $0x10,%eax
801035c1:	8b 04 85 2c 57 11 80 	mov    -0x7feea8d4(,%eax,4),%eax
801035c8:	89 c2                	mov    %eax,%edx
801035ca:	a1 64 57 11 80       	mov    0x80115764,%eax
801035cf:	83 ec 08             	sub    $0x8,%esp
801035d2:	52                   	push   %edx
801035d3:	50                   	push   %eax
801035d4:	e8 fe cb ff ff       	call   801001d7 <bread>
801035d9:	83 c4 10             	add    $0x10,%esp
801035dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801035df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035e2:	8d 50 5c             	lea    0x5c(%eax),%edx
801035e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035e8:	83 c0 5c             	add    $0x5c,%eax
801035eb:	83 ec 04             	sub    $0x4,%esp
801035ee:	68 00 02 00 00       	push   $0x200
801035f3:	52                   	push   %edx
801035f4:	50                   	push   %eax
801035f5:	e8 e5 20 00 00       	call   801056df <memmove>
801035fa:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801035fd:	83 ec 0c             	sub    $0xc,%esp
80103600:	ff 75 ec             	pushl  -0x14(%ebp)
80103603:	e8 0c cc ff ff       	call   80100214 <bwrite>
80103608:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
8010360b:	83 ec 0c             	sub    $0xc,%esp
8010360e:	ff 75 f0             	pushl  -0x10(%ebp)
80103611:	e8 4b cc ff ff       	call   80100261 <brelse>
80103616:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103619:	83 ec 0c             	sub    $0xc,%esp
8010361c:	ff 75 ec             	pushl  -0x14(%ebp)
8010361f:	e8 3d cc ff ff       	call   80100261 <brelse>
80103624:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103627:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010362b:	a1 68 57 11 80       	mov    0x80115768,%eax
80103630:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103633:	0f 8c 5d ff ff ff    	jl     80103596 <install_trans+0x16>
  }
}
80103639:	90                   	nop
8010363a:	90                   	nop
8010363b:	c9                   	leave  
8010363c:	c3                   	ret    

8010363d <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010363d:	f3 0f 1e fb          	endbr32 
80103641:	55                   	push   %ebp
80103642:	89 e5                	mov    %esp,%ebp
80103644:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103647:	a1 54 57 11 80       	mov    0x80115754,%eax
8010364c:	89 c2                	mov    %eax,%edx
8010364e:	a1 64 57 11 80       	mov    0x80115764,%eax
80103653:	83 ec 08             	sub    $0x8,%esp
80103656:	52                   	push   %edx
80103657:	50                   	push   %eax
80103658:	e8 7a cb ff ff       	call   801001d7 <bread>
8010365d:	83 c4 10             	add    $0x10,%esp
80103660:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103663:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103666:	83 c0 5c             	add    $0x5c,%eax
80103669:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010366c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010366f:	8b 00                	mov    (%eax),%eax
80103671:	a3 68 57 11 80       	mov    %eax,0x80115768
  for (i = 0; i < log.lh.n; i++) {
80103676:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010367d:	eb 1b                	jmp    8010369a <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
8010367f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103682:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103685:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103689:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010368c:	83 c2 10             	add    $0x10,%edx
8010368f:	89 04 95 2c 57 11 80 	mov    %eax,-0x7feea8d4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103696:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010369a:	a1 68 57 11 80       	mov    0x80115768,%eax
8010369f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801036a2:	7c db                	jl     8010367f <read_head+0x42>
  }
  brelse(buf);
801036a4:	83 ec 0c             	sub    $0xc,%esp
801036a7:	ff 75 f0             	pushl  -0x10(%ebp)
801036aa:	e8 b2 cb ff ff       	call   80100261 <brelse>
801036af:	83 c4 10             	add    $0x10,%esp
}
801036b2:	90                   	nop
801036b3:	c9                   	leave  
801036b4:	c3                   	ret    

801036b5 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801036b5:	f3 0f 1e fb          	endbr32 
801036b9:	55                   	push   %ebp
801036ba:	89 e5                	mov    %esp,%ebp
801036bc:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801036bf:	a1 54 57 11 80       	mov    0x80115754,%eax
801036c4:	89 c2                	mov    %eax,%edx
801036c6:	a1 64 57 11 80       	mov    0x80115764,%eax
801036cb:	83 ec 08             	sub    $0x8,%esp
801036ce:	52                   	push   %edx
801036cf:	50                   	push   %eax
801036d0:	e8 02 cb ff ff       	call   801001d7 <bread>
801036d5:	83 c4 10             	add    $0x10,%esp
801036d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801036db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036de:	83 c0 5c             	add    $0x5c,%eax
801036e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801036e4:	8b 15 68 57 11 80    	mov    0x80115768,%edx
801036ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036ed:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801036ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036f6:	eb 1b                	jmp    80103713 <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
801036f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036fb:	83 c0 10             	add    $0x10,%eax
801036fe:	8b 0c 85 2c 57 11 80 	mov    -0x7feea8d4(,%eax,4),%ecx
80103705:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103708:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010370b:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010370f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103713:	a1 68 57 11 80       	mov    0x80115768,%eax
80103718:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010371b:	7c db                	jl     801036f8 <write_head+0x43>
  }
  bwrite(buf);
8010371d:	83 ec 0c             	sub    $0xc,%esp
80103720:	ff 75 f0             	pushl  -0x10(%ebp)
80103723:	e8 ec ca ff ff       	call   80100214 <bwrite>
80103728:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
8010372b:	83 ec 0c             	sub    $0xc,%esp
8010372e:	ff 75 f0             	pushl  -0x10(%ebp)
80103731:	e8 2b cb ff ff       	call   80100261 <brelse>
80103736:	83 c4 10             	add    $0x10,%esp
}
80103739:	90                   	nop
8010373a:	c9                   	leave  
8010373b:	c3                   	ret    

8010373c <recover_from_log>:

static void
recover_from_log(void)
{
8010373c:	f3 0f 1e fb          	endbr32 
80103740:	55                   	push   %ebp
80103741:	89 e5                	mov    %esp,%ebp
80103743:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103746:	e8 f2 fe ff ff       	call   8010363d <read_head>
  install_trans(); // if committed, copy from log to disk
8010374b:	e8 30 fe ff ff       	call   80103580 <install_trans>
  log.lh.n = 0;
80103750:	c7 05 68 57 11 80 00 	movl   $0x0,0x80115768
80103757:	00 00 00 
  write_head(); // clear the log
8010375a:	e8 56 ff ff ff       	call   801036b5 <write_head>
}
8010375f:	90                   	nop
80103760:	c9                   	leave  
80103761:	c3                   	ret    

80103762 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103762:	f3 0f 1e fb          	endbr32 
80103766:	55                   	push   %ebp
80103767:	89 e5                	mov    %esp,%ebp
80103769:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010376c:	83 ec 0c             	sub    $0xc,%esp
8010376f:	68 20 57 11 80       	push   $0x80115720
80103774:	e8 00 1c 00 00       	call   80105379 <acquire>
80103779:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010377c:	a1 60 57 11 80       	mov    0x80115760,%eax
80103781:	85 c0                	test   %eax,%eax
80103783:	74 17                	je     8010379c <begin_op+0x3a>
      sleep(&log, &log.lock);
80103785:	83 ec 08             	sub    $0x8,%esp
80103788:	68 20 57 11 80       	push   $0x80115720
8010378d:	68 20 57 11 80       	push   $0x80115720
80103792:	e8 70 17 00 00       	call   80104f07 <sleep>
80103797:	83 c4 10             	add    $0x10,%esp
8010379a:	eb e0                	jmp    8010377c <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010379c:	8b 0d 68 57 11 80    	mov    0x80115768,%ecx
801037a2:	a1 5c 57 11 80       	mov    0x8011575c,%eax
801037a7:	8d 50 01             	lea    0x1(%eax),%edx
801037aa:	89 d0                	mov    %edx,%eax
801037ac:	c1 e0 02             	shl    $0x2,%eax
801037af:	01 d0                	add    %edx,%eax
801037b1:	01 c0                	add    %eax,%eax
801037b3:	01 c8                	add    %ecx,%eax
801037b5:	83 f8 1e             	cmp    $0x1e,%eax
801037b8:	7e 17                	jle    801037d1 <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801037ba:	83 ec 08             	sub    $0x8,%esp
801037bd:	68 20 57 11 80       	push   $0x80115720
801037c2:	68 20 57 11 80       	push   $0x80115720
801037c7:	e8 3b 17 00 00       	call   80104f07 <sleep>
801037cc:	83 c4 10             	add    $0x10,%esp
801037cf:	eb ab                	jmp    8010377c <begin_op+0x1a>
    } else {
      log.outstanding += 1;
801037d1:	a1 5c 57 11 80       	mov    0x8011575c,%eax
801037d6:	83 c0 01             	add    $0x1,%eax
801037d9:	a3 5c 57 11 80       	mov    %eax,0x8011575c
      release(&log.lock);
801037de:	83 ec 0c             	sub    $0xc,%esp
801037e1:	68 20 57 11 80       	push   $0x80115720
801037e6:	e8 00 1c 00 00       	call   801053eb <release>
801037eb:	83 c4 10             	add    $0x10,%esp
      break;
801037ee:	90                   	nop
    }
  }
}
801037ef:	90                   	nop
801037f0:	c9                   	leave  
801037f1:	c3                   	ret    

801037f2 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801037f2:	f3 0f 1e fb          	endbr32 
801037f6:	55                   	push   %ebp
801037f7:	89 e5                	mov    %esp,%ebp
801037f9:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801037fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103803:	83 ec 0c             	sub    $0xc,%esp
80103806:	68 20 57 11 80       	push   $0x80115720
8010380b:	e8 69 1b 00 00       	call   80105379 <acquire>
80103810:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103813:	a1 5c 57 11 80       	mov    0x8011575c,%eax
80103818:	83 e8 01             	sub    $0x1,%eax
8010381b:	a3 5c 57 11 80       	mov    %eax,0x8011575c
  if(log.committing)
80103820:	a1 60 57 11 80       	mov    0x80115760,%eax
80103825:	85 c0                	test   %eax,%eax
80103827:	74 0d                	je     80103836 <end_op+0x44>
    panic("log.committing");
80103829:	83 ec 0c             	sub    $0xc,%esp
8010382c:	68 c0 97 10 80       	push   $0x801097c0
80103831:	e8 d2 cd ff ff       	call   80100608 <panic>
  if(log.outstanding == 0){
80103836:	a1 5c 57 11 80       	mov    0x8011575c,%eax
8010383b:	85 c0                	test   %eax,%eax
8010383d:	75 13                	jne    80103852 <end_op+0x60>
    do_commit = 1;
8010383f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103846:	c7 05 60 57 11 80 01 	movl   $0x1,0x80115760
8010384d:	00 00 00 
80103850:	eb 10                	jmp    80103862 <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103852:	83 ec 0c             	sub    $0xc,%esp
80103855:	68 20 57 11 80       	push   $0x80115720
8010385a:	e8 9a 17 00 00       	call   80104ff9 <wakeup>
8010385f:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103862:	83 ec 0c             	sub    $0xc,%esp
80103865:	68 20 57 11 80       	push   $0x80115720
8010386a:	e8 7c 1b 00 00       	call   801053eb <release>
8010386f:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103872:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103876:	74 3f                	je     801038b7 <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103878:	e8 fa 00 00 00       	call   80103977 <commit>
    acquire(&log.lock);
8010387d:	83 ec 0c             	sub    $0xc,%esp
80103880:	68 20 57 11 80       	push   $0x80115720
80103885:	e8 ef 1a 00 00       	call   80105379 <acquire>
8010388a:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010388d:	c7 05 60 57 11 80 00 	movl   $0x0,0x80115760
80103894:	00 00 00 
    wakeup(&log);
80103897:	83 ec 0c             	sub    $0xc,%esp
8010389a:	68 20 57 11 80       	push   $0x80115720
8010389f:	e8 55 17 00 00       	call   80104ff9 <wakeup>
801038a4:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801038a7:	83 ec 0c             	sub    $0xc,%esp
801038aa:	68 20 57 11 80       	push   $0x80115720
801038af:	e8 37 1b 00 00       	call   801053eb <release>
801038b4:	83 c4 10             	add    $0x10,%esp
  }
}
801038b7:	90                   	nop
801038b8:	c9                   	leave  
801038b9:	c3                   	ret    

801038ba <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801038ba:	f3 0f 1e fb          	endbr32 
801038be:	55                   	push   %ebp
801038bf:	89 e5                	mov    %esp,%ebp
801038c1:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801038c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038cb:	e9 95 00 00 00       	jmp    80103965 <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801038d0:	8b 15 54 57 11 80    	mov    0x80115754,%edx
801038d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038d9:	01 d0                	add    %edx,%eax
801038db:	83 c0 01             	add    $0x1,%eax
801038de:	89 c2                	mov    %eax,%edx
801038e0:	a1 64 57 11 80       	mov    0x80115764,%eax
801038e5:	83 ec 08             	sub    $0x8,%esp
801038e8:	52                   	push   %edx
801038e9:	50                   	push   %eax
801038ea:	e8 e8 c8 ff ff       	call   801001d7 <bread>
801038ef:	83 c4 10             	add    $0x10,%esp
801038f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801038f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038f8:	83 c0 10             	add    $0x10,%eax
801038fb:	8b 04 85 2c 57 11 80 	mov    -0x7feea8d4(,%eax,4),%eax
80103902:	89 c2                	mov    %eax,%edx
80103904:	a1 64 57 11 80       	mov    0x80115764,%eax
80103909:	83 ec 08             	sub    $0x8,%esp
8010390c:	52                   	push   %edx
8010390d:	50                   	push   %eax
8010390e:	e8 c4 c8 ff ff       	call   801001d7 <bread>
80103913:	83 c4 10             	add    $0x10,%esp
80103916:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103919:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010391c:	8d 50 5c             	lea    0x5c(%eax),%edx
8010391f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103922:	83 c0 5c             	add    $0x5c,%eax
80103925:	83 ec 04             	sub    $0x4,%esp
80103928:	68 00 02 00 00       	push   $0x200
8010392d:	52                   	push   %edx
8010392e:	50                   	push   %eax
8010392f:	e8 ab 1d 00 00       	call   801056df <memmove>
80103934:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103937:	83 ec 0c             	sub    $0xc,%esp
8010393a:	ff 75 f0             	pushl  -0x10(%ebp)
8010393d:	e8 d2 c8 ff ff       	call   80100214 <bwrite>
80103942:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103945:	83 ec 0c             	sub    $0xc,%esp
80103948:	ff 75 ec             	pushl  -0x14(%ebp)
8010394b:	e8 11 c9 ff ff       	call   80100261 <brelse>
80103950:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103953:	83 ec 0c             	sub    $0xc,%esp
80103956:	ff 75 f0             	pushl  -0x10(%ebp)
80103959:	e8 03 c9 ff ff       	call   80100261 <brelse>
8010395e:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103961:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103965:	a1 68 57 11 80       	mov    0x80115768,%eax
8010396a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010396d:	0f 8c 5d ff ff ff    	jl     801038d0 <write_log+0x16>
  }
}
80103973:	90                   	nop
80103974:	90                   	nop
80103975:	c9                   	leave  
80103976:	c3                   	ret    

80103977 <commit>:

static void
commit()
{
80103977:	f3 0f 1e fb          	endbr32 
8010397b:	55                   	push   %ebp
8010397c:	89 e5                	mov    %esp,%ebp
8010397e:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103981:	a1 68 57 11 80       	mov    0x80115768,%eax
80103986:	85 c0                	test   %eax,%eax
80103988:	7e 1e                	jle    801039a8 <commit+0x31>
    write_log();     // Write modified blocks from cache to log
8010398a:	e8 2b ff ff ff       	call   801038ba <write_log>
    write_head();    // Write header to disk -- the real commit
8010398f:	e8 21 fd ff ff       	call   801036b5 <write_head>
    install_trans(); // Now install writes to home locations
80103994:	e8 e7 fb ff ff       	call   80103580 <install_trans>
    log.lh.n = 0;
80103999:	c7 05 68 57 11 80 00 	movl   $0x0,0x80115768
801039a0:	00 00 00 
    write_head();    // Erase the transaction from the log
801039a3:	e8 0d fd ff ff       	call   801036b5 <write_head>
  }
}
801039a8:	90                   	nop
801039a9:	c9                   	leave  
801039aa:	c3                   	ret    

801039ab <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801039ab:	f3 0f 1e fb          	endbr32 
801039af:	55                   	push   %ebp
801039b0:	89 e5                	mov    %esp,%ebp
801039b2:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801039b5:	a1 68 57 11 80       	mov    0x80115768,%eax
801039ba:	83 f8 1d             	cmp    $0x1d,%eax
801039bd:	7f 12                	jg     801039d1 <log_write+0x26>
801039bf:	a1 68 57 11 80       	mov    0x80115768,%eax
801039c4:	8b 15 58 57 11 80    	mov    0x80115758,%edx
801039ca:	83 ea 01             	sub    $0x1,%edx
801039cd:	39 d0                	cmp    %edx,%eax
801039cf:	7c 0d                	jl     801039de <log_write+0x33>
    panic("too big a transaction");
801039d1:	83 ec 0c             	sub    $0xc,%esp
801039d4:	68 cf 97 10 80       	push   $0x801097cf
801039d9:	e8 2a cc ff ff       	call   80100608 <panic>
  if (log.outstanding < 1)
801039de:	a1 5c 57 11 80       	mov    0x8011575c,%eax
801039e3:	85 c0                	test   %eax,%eax
801039e5:	7f 0d                	jg     801039f4 <log_write+0x49>
    panic("log_write outside of trans");
801039e7:	83 ec 0c             	sub    $0xc,%esp
801039ea:	68 e5 97 10 80       	push   $0x801097e5
801039ef:	e8 14 cc ff ff       	call   80100608 <panic>

  acquire(&log.lock);
801039f4:	83 ec 0c             	sub    $0xc,%esp
801039f7:	68 20 57 11 80       	push   $0x80115720
801039fc:	e8 78 19 00 00       	call   80105379 <acquire>
80103a01:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103a04:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103a0b:	eb 1d                	jmp    80103a2a <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a10:	83 c0 10             	add    $0x10,%eax
80103a13:	8b 04 85 2c 57 11 80 	mov    -0x7feea8d4(,%eax,4),%eax
80103a1a:	89 c2                	mov    %eax,%edx
80103a1c:	8b 45 08             	mov    0x8(%ebp),%eax
80103a1f:	8b 40 08             	mov    0x8(%eax),%eax
80103a22:	39 c2                	cmp    %eax,%edx
80103a24:	74 10                	je     80103a36 <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
80103a26:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a2a:	a1 68 57 11 80       	mov    0x80115768,%eax
80103a2f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a32:	7c d9                	jl     80103a0d <log_write+0x62>
80103a34:	eb 01                	jmp    80103a37 <log_write+0x8c>
      break;
80103a36:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103a37:	8b 45 08             	mov    0x8(%ebp),%eax
80103a3a:	8b 40 08             	mov    0x8(%eax),%eax
80103a3d:	89 c2                	mov    %eax,%edx
80103a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a42:	83 c0 10             	add    $0x10,%eax
80103a45:	89 14 85 2c 57 11 80 	mov    %edx,-0x7feea8d4(,%eax,4)
  if (i == log.lh.n)
80103a4c:	a1 68 57 11 80       	mov    0x80115768,%eax
80103a51:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a54:	75 0d                	jne    80103a63 <log_write+0xb8>
    log.lh.n++;
80103a56:	a1 68 57 11 80       	mov    0x80115768,%eax
80103a5b:	83 c0 01             	add    $0x1,%eax
80103a5e:	a3 68 57 11 80       	mov    %eax,0x80115768
  b->flags |= B_DIRTY; // prevent eviction
80103a63:	8b 45 08             	mov    0x8(%ebp),%eax
80103a66:	8b 00                	mov    (%eax),%eax
80103a68:	83 c8 04             	or     $0x4,%eax
80103a6b:	89 c2                	mov    %eax,%edx
80103a6d:	8b 45 08             	mov    0x8(%ebp),%eax
80103a70:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103a72:	83 ec 0c             	sub    $0xc,%esp
80103a75:	68 20 57 11 80       	push   $0x80115720
80103a7a:	e8 6c 19 00 00       	call   801053eb <release>
80103a7f:	83 c4 10             	add    $0x10,%esp
}
80103a82:	90                   	nop
80103a83:	c9                   	leave  
80103a84:	c3                   	ret    

80103a85 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103a85:	55                   	push   %ebp
80103a86:	89 e5                	mov    %esp,%ebp
80103a88:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103a8b:	8b 55 08             	mov    0x8(%ebp),%edx
80103a8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a91:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103a94:	f0 87 02             	lock xchg %eax,(%edx)
80103a97:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103a9a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103a9d:	c9                   	leave  
80103a9e:	c3                   	ret    

80103a9f <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103a9f:	f3 0f 1e fb          	endbr32 
80103aa3:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103aa7:	83 e4 f0             	and    $0xfffffff0,%esp
80103aaa:	ff 71 fc             	pushl  -0x4(%ecx)
80103aad:	55                   	push   %ebp
80103aae:	89 e5                	mov    %esp,%ebp
80103ab0:	51                   	push   %ecx
80103ab1:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103ab4:	83 ec 08             	sub    $0x8,%esp
80103ab7:	68 00 00 40 80       	push   $0x80400000
80103abc:	68 48 8e 11 80       	push   $0x80118e48
80103ac1:	e8 52 f2 ff ff       	call   80102d18 <kinit1>
80103ac6:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103ac9:	e8 5c 47 00 00       	call   8010822a <kvmalloc>
  mpinit();        // detect other processors
80103ace:	e8 d9 03 00 00       	call   80103eac <mpinit>
  lapicinit();     // interrupt controller
80103ad3:	e8 f5 f5 ff ff       	call   801030cd <lapicinit>
  seginit();       // segment descriptors
80103ad8:	e8 d6 41 00 00       	call   80107cb3 <seginit>
  picinit();       // disable pic
80103add:	e8 35 05 00 00       	call   80104017 <picinit>
  ioapicinit();    // another interrupt controller
80103ae2:	e8 44 f1 ff ff       	call   80102c2b <ioapicinit>
  consoleinit();   // console hardware
80103ae7:	e8 f5 d0 ff ff       	call   80100be1 <consoleinit>
  uartinit();      // serial port
80103aec:	e8 4b 35 00 00       	call   8010703c <uartinit>
  pinit();         // process table
80103af1:	e8 6e 09 00 00       	call   80104464 <pinit>
  tvinit();        // trap vectors
80103af6:	e8 d9 30 00 00       	call   80106bd4 <tvinit>
  binit();         // buffer cache
80103afb:	e8 34 c5 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103b00:	e8 00 d6 ff ff       	call   80101105 <fileinit>
  ideinit();       // disk 
80103b05:	e8 e0 ec ff ff       	call   801027ea <ideinit>
  startothers();   // start other processors
80103b0a:	e8 88 00 00 00       	call   80103b97 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103b0f:	83 ec 08             	sub    $0x8,%esp
80103b12:	68 00 00 00 8e       	push   $0x8e000000
80103b17:	68 00 00 40 80       	push   $0x80400000
80103b1c:	e8 34 f2 ff ff       	call   80102d55 <kinit2>
80103b21:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103b24:	e8 34 0b 00 00       	call   8010465d <userinit>
  mpmain();        // finish this processor's setup
80103b29:	e8 1e 00 00 00       	call   80103b4c <mpmain>

80103b2e <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103b2e:	f3 0f 1e fb          	endbr32 
80103b32:	55                   	push   %ebp
80103b33:	89 e5                	mov    %esp,%ebp
80103b35:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103b38:	e8 09 47 00 00       	call   80108246 <switchkvm>
  seginit();
80103b3d:	e8 71 41 00 00       	call   80107cb3 <seginit>
  lapicinit();
80103b42:	e8 86 f5 ff ff       	call   801030cd <lapicinit>
  mpmain();
80103b47:	e8 00 00 00 00       	call   80103b4c <mpmain>

80103b4c <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103b4c:	f3 0f 1e fb          	endbr32 
80103b50:	55                   	push   %ebp
80103b51:	89 e5                	mov    %esp,%ebp
80103b53:	53                   	push   %ebx
80103b54:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103b57:	e8 2a 09 00 00       	call   80104486 <cpuid>
80103b5c:	89 c3                	mov    %eax,%ebx
80103b5e:	e8 23 09 00 00       	call   80104486 <cpuid>
80103b63:	83 ec 04             	sub    $0x4,%esp
80103b66:	53                   	push   %ebx
80103b67:	50                   	push   %eax
80103b68:	68 00 98 10 80       	push   $0x80109800
80103b6d:	e8 a6 c8 ff ff       	call   80100418 <cprintf>
80103b72:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103b75:	e8 d4 31 00 00       	call   80106d4e <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103b7a:	e8 26 09 00 00       	call   801044a5 <mycpu>
80103b7f:	05 a0 00 00 00       	add    $0xa0,%eax
80103b84:	83 ec 08             	sub    $0x8,%esp
80103b87:	6a 01                	push   $0x1
80103b89:	50                   	push   %eax
80103b8a:	e8 f6 fe ff ff       	call   80103a85 <xchg>
80103b8f:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103b92:	e8 6c 11 00 00       	call   80104d03 <scheduler>

80103b97 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103b97:	f3 0f 1e fb          	endbr32 
80103b9b:	55                   	push   %ebp
80103b9c:	89 e5                	mov    %esp,%ebp
80103b9e:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103ba1:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103ba8:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103bad:	83 ec 04             	sub    $0x4,%esp
80103bb0:	50                   	push   %eax
80103bb1:	68 0c d5 10 80       	push   $0x8010d50c
80103bb6:	ff 75 f0             	pushl  -0x10(%ebp)
80103bb9:	e8 21 1b 00 00       	call   801056df <memmove>
80103bbe:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103bc1:	c7 45 f4 20 58 11 80 	movl   $0x80115820,-0xc(%ebp)
80103bc8:	eb 79                	jmp    80103c43 <startothers+0xac>
    if(c == mycpu())  // We've started already.
80103bca:	e8 d6 08 00 00       	call   801044a5 <mycpu>
80103bcf:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103bd2:	74 67                	je     80103c3b <startothers+0xa4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103bd4:	e8 84 f2 ff ff       	call   80102e5d <kalloc>
80103bd9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103bdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bdf:	83 e8 04             	sub    $0x4,%eax
80103be2:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103be5:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103beb:	89 10                	mov    %edx,(%eax)
    *(void(**)(void))(code-8) = mpenter;
80103bed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bf0:	83 e8 08             	sub    $0x8,%eax
80103bf3:	c7 00 2e 3b 10 80    	movl   $0x80103b2e,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103bf9:	b8 00 c0 10 80       	mov    $0x8010c000,%eax
80103bfe:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103c04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c07:	83 e8 0c             	sub    $0xc,%eax
80103c0a:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
80103c0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c0f:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103c15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c18:	0f b6 00             	movzbl (%eax),%eax
80103c1b:	0f b6 c0             	movzbl %al,%eax
80103c1e:	83 ec 08             	sub    $0x8,%esp
80103c21:	52                   	push   %edx
80103c22:	50                   	push   %eax
80103c23:	e8 17 f6 ff ff       	call   8010323f <lapicstartap>
80103c28:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103c2b:	90                   	nop
80103c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c2f:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103c35:	85 c0                	test   %eax,%eax
80103c37:	74 f3                	je     80103c2c <startothers+0x95>
80103c39:	eb 01                	jmp    80103c3c <startothers+0xa5>
      continue;
80103c3b:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103c3c:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103c43:	a1 a0 5d 11 80       	mov    0x80115da0,%eax
80103c48:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103c4e:	05 20 58 11 80       	add    $0x80115820,%eax
80103c53:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103c56:	0f 82 6e ff ff ff    	jb     80103bca <startothers+0x33>
      ;
  }
}
80103c5c:	90                   	nop
80103c5d:	90                   	nop
80103c5e:	c9                   	leave  
80103c5f:	c3                   	ret    

80103c60 <inb>:
{
80103c60:	55                   	push   %ebp
80103c61:	89 e5                	mov    %esp,%ebp
80103c63:	83 ec 14             	sub    $0x14,%esp
80103c66:	8b 45 08             	mov    0x8(%ebp),%eax
80103c69:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103c6d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103c71:	89 c2                	mov    %eax,%edx
80103c73:	ec                   	in     (%dx),%al
80103c74:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103c77:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103c7b:	c9                   	leave  
80103c7c:	c3                   	ret    

80103c7d <outb>:
{
80103c7d:	55                   	push   %ebp
80103c7e:	89 e5                	mov    %esp,%ebp
80103c80:	83 ec 08             	sub    $0x8,%esp
80103c83:	8b 45 08             	mov    0x8(%ebp),%eax
80103c86:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c89:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103c8d:	89 d0                	mov    %edx,%eax
80103c8f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103c92:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103c96:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103c9a:	ee                   	out    %al,(%dx)
}
80103c9b:	90                   	nop
80103c9c:	c9                   	leave  
80103c9d:	c3                   	ret    

80103c9e <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103c9e:	f3 0f 1e fb          	endbr32 
80103ca2:	55                   	push   %ebp
80103ca3:	89 e5                	mov    %esp,%ebp
80103ca5:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103ca8:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103caf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103cb6:	eb 15                	jmp    80103ccd <sum+0x2f>
    sum += addr[i];
80103cb8:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103cbb:	8b 45 08             	mov    0x8(%ebp),%eax
80103cbe:	01 d0                	add    %edx,%eax
80103cc0:	0f b6 00             	movzbl (%eax),%eax
80103cc3:	0f b6 c0             	movzbl %al,%eax
80103cc6:	01 45 f8             	add    %eax,-0x8(%ebp)
  for(i=0; i<len; i++)
80103cc9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103ccd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103cd0:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103cd3:	7c e3                	jl     80103cb8 <sum+0x1a>
  return sum;
80103cd5:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103cd8:	c9                   	leave  
80103cd9:	c3                   	ret    

80103cda <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103cda:	f3 0f 1e fb          	endbr32 
80103cde:	55                   	push   %ebp
80103cdf:	89 e5                	mov    %esp,%ebp
80103ce1:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103ce4:	8b 45 08             	mov    0x8(%ebp),%eax
80103ce7:	05 00 00 00 80       	add    $0x80000000,%eax
80103cec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103cef:	8b 55 0c             	mov    0xc(%ebp),%edx
80103cf2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cf5:	01 d0                	add    %edx,%eax
80103cf7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103cfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cfd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d00:	eb 36                	jmp    80103d38 <mpsearch1+0x5e>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103d02:	83 ec 04             	sub    $0x4,%esp
80103d05:	6a 04                	push   $0x4
80103d07:	68 14 98 10 80       	push   $0x80109814
80103d0c:	ff 75 f4             	pushl  -0xc(%ebp)
80103d0f:	e8 6f 19 00 00       	call   80105683 <memcmp>
80103d14:	83 c4 10             	add    $0x10,%esp
80103d17:	85 c0                	test   %eax,%eax
80103d19:	75 19                	jne    80103d34 <mpsearch1+0x5a>
80103d1b:	83 ec 08             	sub    $0x8,%esp
80103d1e:	6a 10                	push   $0x10
80103d20:	ff 75 f4             	pushl  -0xc(%ebp)
80103d23:	e8 76 ff ff ff       	call   80103c9e <sum>
80103d28:	83 c4 10             	add    $0x10,%esp
80103d2b:	84 c0                	test   %al,%al
80103d2d:	75 05                	jne    80103d34 <mpsearch1+0x5a>
      return (struct mp*)p;
80103d2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d32:	eb 11                	jmp    80103d45 <mpsearch1+0x6b>
  for(p = addr; p < e; p += sizeof(struct mp))
80103d34:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d3b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103d3e:	72 c2                	jb     80103d02 <mpsearch1+0x28>
  return 0;
80103d40:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d45:	c9                   	leave  
80103d46:	c3                   	ret    

80103d47 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103d47:	f3 0f 1e fb          	endbr32 
80103d4b:	55                   	push   %ebp
80103d4c:	89 e5                	mov    %esp,%ebp
80103d4e:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103d51:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103d58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d5b:	83 c0 0f             	add    $0xf,%eax
80103d5e:	0f b6 00             	movzbl (%eax),%eax
80103d61:	0f b6 c0             	movzbl %al,%eax
80103d64:	c1 e0 08             	shl    $0x8,%eax
80103d67:	89 c2                	mov    %eax,%edx
80103d69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d6c:	83 c0 0e             	add    $0xe,%eax
80103d6f:	0f b6 00             	movzbl (%eax),%eax
80103d72:	0f b6 c0             	movzbl %al,%eax
80103d75:	09 d0                	or     %edx,%eax
80103d77:	c1 e0 04             	shl    $0x4,%eax
80103d7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103d7d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d81:	74 21                	je     80103da4 <mpsearch+0x5d>
    if((mp = mpsearch1(p, 1024)))
80103d83:	83 ec 08             	sub    $0x8,%esp
80103d86:	68 00 04 00 00       	push   $0x400
80103d8b:	ff 75 f0             	pushl  -0x10(%ebp)
80103d8e:	e8 47 ff ff ff       	call   80103cda <mpsearch1>
80103d93:	83 c4 10             	add    $0x10,%esp
80103d96:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d99:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d9d:	74 51                	je     80103df0 <mpsearch+0xa9>
      return mp;
80103d9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103da2:	eb 61                	jmp    80103e05 <mpsearch+0xbe>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103da7:	83 c0 14             	add    $0x14,%eax
80103daa:	0f b6 00             	movzbl (%eax),%eax
80103dad:	0f b6 c0             	movzbl %al,%eax
80103db0:	c1 e0 08             	shl    $0x8,%eax
80103db3:	89 c2                	mov    %eax,%edx
80103db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103db8:	83 c0 13             	add    $0x13,%eax
80103dbb:	0f b6 00             	movzbl (%eax),%eax
80103dbe:	0f b6 c0             	movzbl %al,%eax
80103dc1:	09 d0                	or     %edx,%eax
80103dc3:	c1 e0 0a             	shl    $0xa,%eax
80103dc6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103dc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dcc:	2d 00 04 00 00       	sub    $0x400,%eax
80103dd1:	83 ec 08             	sub    $0x8,%esp
80103dd4:	68 00 04 00 00       	push   $0x400
80103dd9:	50                   	push   %eax
80103dda:	e8 fb fe ff ff       	call   80103cda <mpsearch1>
80103ddf:	83 c4 10             	add    $0x10,%esp
80103de2:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103de5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103de9:	74 05                	je     80103df0 <mpsearch+0xa9>
      return mp;
80103deb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103dee:	eb 15                	jmp    80103e05 <mpsearch+0xbe>
  }
  return mpsearch1(0xF0000, 0x10000);
80103df0:	83 ec 08             	sub    $0x8,%esp
80103df3:	68 00 00 01 00       	push   $0x10000
80103df8:	68 00 00 0f 00       	push   $0xf0000
80103dfd:	e8 d8 fe ff ff       	call   80103cda <mpsearch1>
80103e02:	83 c4 10             	add    $0x10,%esp
}
80103e05:	c9                   	leave  
80103e06:	c3                   	ret    

80103e07 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103e07:	f3 0f 1e fb          	endbr32 
80103e0b:	55                   	push   %ebp
80103e0c:	89 e5                	mov    %esp,%ebp
80103e0e:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103e11:	e8 31 ff ff ff       	call   80103d47 <mpsearch>
80103e16:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e19:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e1d:	74 0a                	je     80103e29 <mpconfig+0x22>
80103e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e22:	8b 40 04             	mov    0x4(%eax),%eax
80103e25:	85 c0                	test   %eax,%eax
80103e27:	75 07                	jne    80103e30 <mpconfig+0x29>
    return 0;
80103e29:	b8 00 00 00 00       	mov    $0x0,%eax
80103e2e:	eb 7a                	jmp    80103eaa <mpconfig+0xa3>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103e30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e33:	8b 40 04             	mov    0x4(%eax),%eax
80103e36:	05 00 00 00 80       	add    $0x80000000,%eax
80103e3b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103e3e:	83 ec 04             	sub    $0x4,%esp
80103e41:	6a 04                	push   $0x4
80103e43:	68 19 98 10 80       	push   $0x80109819
80103e48:	ff 75 f0             	pushl  -0x10(%ebp)
80103e4b:	e8 33 18 00 00       	call   80105683 <memcmp>
80103e50:	83 c4 10             	add    $0x10,%esp
80103e53:	85 c0                	test   %eax,%eax
80103e55:	74 07                	je     80103e5e <mpconfig+0x57>
    return 0;
80103e57:	b8 00 00 00 00       	mov    $0x0,%eax
80103e5c:	eb 4c                	jmp    80103eaa <mpconfig+0xa3>
  if(conf->version != 1 && conf->version != 4)
80103e5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e61:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103e65:	3c 01                	cmp    $0x1,%al
80103e67:	74 12                	je     80103e7b <mpconfig+0x74>
80103e69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e6c:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103e70:	3c 04                	cmp    $0x4,%al
80103e72:	74 07                	je     80103e7b <mpconfig+0x74>
    return 0;
80103e74:	b8 00 00 00 00       	mov    $0x0,%eax
80103e79:	eb 2f                	jmp    80103eaa <mpconfig+0xa3>
  if(sum((uchar*)conf, conf->length) != 0)
80103e7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e7e:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103e82:	0f b7 c0             	movzwl %ax,%eax
80103e85:	83 ec 08             	sub    $0x8,%esp
80103e88:	50                   	push   %eax
80103e89:	ff 75 f0             	pushl  -0x10(%ebp)
80103e8c:	e8 0d fe ff ff       	call   80103c9e <sum>
80103e91:	83 c4 10             	add    $0x10,%esp
80103e94:	84 c0                	test   %al,%al
80103e96:	74 07                	je     80103e9f <mpconfig+0x98>
    return 0;
80103e98:	b8 00 00 00 00       	mov    $0x0,%eax
80103e9d:	eb 0b                	jmp    80103eaa <mpconfig+0xa3>
  *pmp = mp;
80103e9f:	8b 45 08             	mov    0x8(%ebp),%eax
80103ea2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ea5:	89 10                	mov    %edx,(%eax)
  return conf;
80103ea7:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103eaa:	c9                   	leave  
80103eab:	c3                   	ret    

80103eac <mpinit>:

void
mpinit(void)
{
80103eac:	f3 0f 1e fb          	endbr32 
80103eb0:	55                   	push   %ebp
80103eb1:	89 e5                	mov    %esp,%ebp
80103eb3:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103eb6:	83 ec 0c             	sub    $0xc,%esp
80103eb9:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103ebc:	50                   	push   %eax
80103ebd:	e8 45 ff ff ff       	call   80103e07 <mpconfig>
80103ec2:	83 c4 10             	add    $0x10,%esp
80103ec5:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ec8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ecc:	75 0d                	jne    80103edb <mpinit+0x2f>
    panic("Expect to run on an SMP");
80103ece:	83 ec 0c             	sub    $0xc,%esp
80103ed1:	68 1e 98 10 80       	push   $0x8010981e
80103ed6:	e8 2d c7 ff ff       	call   80100608 <panic>
  ismp = 1;
80103edb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103ee2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ee5:	8b 40 24             	mov    0x24(%eax),%eax
80103ee8:	a3 1c 57 11 80       	mov    %eax,0x8011571c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103eed:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ef0:	83 c0 2c             	add    $0x2c,%eax
80103ef3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ef6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ef9:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103efd:	0f b7 d0             	movzwl %ax,%edx
80103f00:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f03:	01 d0                	add    %edx,%eax
80103f05:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103f08:	e9 8c 00 00 00       	jmp    80103f99 <mpinit+0xed>
    switch(*p){
80103f0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f10:	0f b6 00             	movzbl (%eax),%eax
80103f13:	0f b6 c0             	movzbl %al,%eax
80103f16:	83 f8 04             	cmp    $0x4,%eax
80103f19:	7f 76                	jg     80103f91 <mpinit+0xe5>
80103f1b:	83 f8 03             	cmp    $0x3,%eax
80103f1e:	7d 6b                	jge    80103f8b <mpinit+0xdf>
80103f20:	83 f8 02             	cmp    $0x2,%eax
80103f23:	74 4e                	je     80103f73 <mpinit+0xc7>
80103f25:	83 f8 02             	cmp    $0x2,%eax
80103f28:	7f 67                	jg     80103f91 <mpinit+0xe5>
80103f2a:	85 c0                	test   %eax,%eax
80103f2c:	74 07                	je     80103f35 <mpinit+0x89>
80103f2e:	83 f8 01             	cmp    $0x1,%eax
80103f31:	74 58                	je     80103f8b <mpinit+0xdf>
80103f33:	eb 5c                	jmp    80103f91 <mpinit+0xe5>
    case MPPROC:
      proc = (struct mpproc*)p;
80103f35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f38:	89 45 e0             	mov    %eax,-0x20(%ebp)
      if(ncpu < NCPU) {
80103f3b:	a1 a0 5d 11 80       	mov    0x80115da0,%eax
80103f40:	83 f8 07             	cmp    $0x7,%eax
80103f43:	7f 28                	jg     80103f6d <mpinit+0xc1>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103f45:	8b 15 a0 5d 11 80    	mov    0x80115da0,%edx
80103f4b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f4e:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103f52:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80103f58:	81 c2 20 58 11 80    	add    $0x80115820,%edx
80103f5e:	88 02                	mov    %al,(%edx)
        ncpu++;
80103f60:	a1 a0 5d 11 80       	mov    0x80115da0,%eax
80103f65:	83 c0 01             	add    $0x1,%eax
80103f68:	a3 a0 5d 11 80       	mov    %eax,0x80115da0
      }
      p += sizeof(struct mpproc);
80103f6d:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103f71:	eb 26                	jmp    80103f99 <mpinit+0xed>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103f73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f76:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103f79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103f7c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103f80:	a2 00 58 11 80       	mov    %al,0x80115800
      p += sizeof(struct mpioapic);
80103f85:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f89:	eb 0e                	jmp    80103f99 <mpinit+0xed>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103f8b:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f8f:	eb 08                	jmp    80103f99 <mpinit+0xed>
    default:
      ismp = 0;
80103f91:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103f98:	90                   	nop
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103f99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f9c:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103f9f:	0f 82 68 ff ff ff    	jb     80103f0d <mpinit+0x61>
    }
  }
  if(!ismp)
80103fa5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103fa9:	75 0d                	jne    80103fb8 <mpinit+0x10c>
    panic("Didn't find a suitable machine");
80103fab:	83 ec 0c             	sub    $0xc,%esp
80103fae:	68 38 98 10 80       	push   $0x80109838
80103fb3:	e8 50 c6 ff ff       	call   80100608 <panic>

  if(mp->imcrp){
80103fb8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fbb:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103fbf:	84 c0                	test   %al,%al
80103fc1:	74 30                	je     80103ff3 <mpinit+0x147>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103fc3:	83 ec 08             	sub    $0x8,%esp
80103fc6:	6a 70                	push   $0x70
80103fc8:	6a 22                	push   $0x22
80103fca:	e8 ae fc ff ff       	call   80103c7d <outb>
80103fcf:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103fd2:	83 ec 0c             	sub    $0xc,%esp
80103fd5:	6a 23                	push   $0x23
80103fd7:	e8 84 fc ff ff       	call   80103c60 <inb>
80103fdc:	83 c4 10             	add    $0x10,%esp
80103fdf:	83 c8 01             	or     $0x1,%eax
80103fe2:	0f b6 c0             	movzbl %al,%eax
80103fe5:	83 ec 08             	sub    $0x8,%esp
80103fe8:	50                   	push   %eax
80103fe9:	6a 23                	push   $0x23
80103feb:	e8 8d fc ff ff       	call   80103c7d <outb>
80103ff0:	83 c4 10             	add    $0x10,%esp
  }
}
80103ff3:	90                   	nop
80103ff4:	c9                   	leave  
80103ff5:	c3                   	ret    

80103ff6 <outb>:
{
80103ff6:	55                   	push   %ebp
80103ff7:	89 e5                	mov    %esp,%ebp
80103ff9:	83 ec 08             	sub    $0x8,%esp
80103ffc:	8b 45 08             	mov    0x8(%ebp),%eax
80103fff:	8b 55 0c             	mov    0xc(%ebp),%edx
80104002:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80104006:	89 d0                	mov    %edx,%eax
80104008:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010400b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010400f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80104013:	ee                   	out    %al,(%dx)
}
80104014:	90                   	nop
80104015:	c9                   	leave  
80104016:	c3                   	ret    

80104017 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80104017:	f3 0f 1e fb          	endbr32 
8010401b:	55                   	push   %ebp
8010401c:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
8010401e:	68 ff 00 00 00       	push   $0xff
80104023:	6a 21                	push   $0x21
80104025:	e8 cc ff ff ff       	call   80103ff6 <outb>
8010402a:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
8010402d:	68 ff 00 00 00       	push   $0xff
80104032:	68 a1 00 00 00       	push   $0xa1
80104037:	e8 ba ff ff ff       	call   80103ff6 <outb>
8010403c:	83 c4 08             	add    $0x8,%esp
}
8010403f:	90                   	nop
80104040:	c9                   	leave  
80104041:	c3                   	ret    

80104042 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104042:	f3 0f 1e fb          	endbr32 
80104046:	55                   	push   %ebp
80104047:	89 e5                	mov    %esp,%ebp
80104049:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
8010404c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104053:	8b 45 0c             	mov    0xc(%ebp),%eax
80104056:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010405c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010405f:	8b 10                	mov    (%eax),%edx
80104061:	8b 45 08             	mov    0x8(%ebp),%eax
80104064:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104066:	e8 bc d0 ff ff       	call   80101127 <filealloc>
8010406b:	8b 55 08             	mov    0x8(%ebp),%edx
8010406e:	89 02                	mov    %eax,(%edx)
80104070:	8b 45 08             	mov    0x8(%ebp),%eax
80104073:	8b 00                	mov    (%eax),%eax
80104075:	85 c0                	test   %eax,%eax
80104077:	0f 84 c8 00 00 00    	je     80104145 <pipealloc+0x103>
8010407d:	e8 a5 d0 ff ff       	call   80101127 <filealloc>
80104082:	8b 55 0c             	mov    0xc(%ebp),%edx
80104085:	89 02                	mov    %eax,(%edx)
80104087:	8b 45 0c             	mov    0xc(%ebp),%eax
8010408a:	8b 00                	mov    (%eax),%eax
8010408c:	85 c0                	test   %eax,%eax
8010408e:	0f 84 b1 00 00 00    	je     80104145 <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104094:	e8 c4 ed ff ff       	call   80102e5d <kalloc>
80104099:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010409c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040a0:	0f 84 a2 00 00 00    	je     80104148 <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
801040a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a9:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801040b0:	00 00 00 
  p->writeopen = 1;
801040b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b6:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801040bd:	00 00 00 
  p->nwrite = 0;
801040c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c3:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801040ca:	00 00 00 
  p->nread = 0;
801040cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d0:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801040d7:	00 00 00 
  initlock(&p->lock, "pipe");
801040da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040dd:	83 ec 08             	sub    $0x8,%esp
801040e0:	68 57 98 10 80       	push   $0x80109857
801040e5:	50                   	push   %eax
801040e6:	e8 68 12 00 00       	call   80105353 <initlock>
801040eb:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801040ee:	8b 45 08             	mov    0x8(%ebp),%eax
801040f1:	8b 00                	mov    (%eax),%eax
801040f3:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801040f9:	8b 45 08             	mov    0x8(%ebp),%eax
801040fc:	8b 00                	mov    (%eax),%eax
801040fe:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104102:	8b 45 08             	mov    0x8(%ebp),%eax
80104105:	8b 00                	mov    (%eax),%eax
80104107:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010410b:	8b 45 08             	mov    0x8(%ebp),%eax
8010410e:	8b 00                	mov    (%eax),%eax
80104110:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104113:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104116:	8b 45 0c             	mov    0xc(%ebp),%eax
80104119:	8b 00                	mov    (%eax),%eax
8010411b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104121:	8b 45 0c             	mov    0xc(%ebp),%eax
80104124:	8b 00                	mov    (%eax),%eax
80104126:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010412a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010412d:	8b 00                	mov    (%eax),%eax
8010412f:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104133:	8b 45 0c             	mov    0xc(%ebp),%eax
80104136:	8b 00                	mov    (%eax),%eax
80104138:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010413b:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
8010413e:	b8 00 00 00 00       	mov    $0x0,%eax
80104143:	eb 51                	jmp    80104196 <pipealloc+0x154>
    goto bad;
80104145:	90                   	nop
80104146:	eb 01                	jmp    80104149 <pipealloc+0x107>
    goto bad;
80104148:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80104149:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010414d:	74 0e                	je     8010415d <pipealloc+0x11b>
    kfree((char*)p);
8010414f:	83 ec 0c             	sub    $0xc,%esp
80104152:	ff 75 f4             	pushl  -0xc(%ebp)
80104155:	e8 65 ec ff ff       	call   80102dbf <kfree>
8010415a:	83 c4 10             	add    $0x10,%esp
  if(*f0)
8010415d:	8b 45 08             	mov    0x8(%ebp),%eax
80104160:	8b 00                	mov    (%eax),%eax
80104162:	85 c0                	test   %eax,%eax
80104164:	74 11                	je     80104177 <pipealloc+0x135>
    fileclose(*f0);
80104166:	8b 45 08             	mov    0x8(%ebp),%eax
80104169:	8b 00                	mov    (%eax),%eax
8010416b:	83 ec 0c             	sub    $0xc,%esp
8010416e:	50                   	push   %eax
8010416f:	e8 79 d0 ff ff       	call   801011ed <fileclose>
80104174:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104177:	8b 45 0c             	mov    0xc(%ebp),%eax
8010417a:	8b 00                	mov    (%eax),%eax
8010417c:	85 c0                	test   %eax,%eax
8010417e:	74 11                	je     80104191 <pipealloc+0x14f>
    fileclose(*f1);
80104180:	8b 45 0c             	mov    0xc(%ebp),%eax
80104183:	8b 00                	mov    (%eax),%eax
80104185:	83 ec 0c             	sub    $0xc,%esp
80104188:	50                   	push   %eax
80104189:	e8 5f d0 ff ff       	call   801011ed <fileclose>
8010418e:	83 c4 10             	add    $0x10,%esp
  return -1;
80104191:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104196:	c9                   	leave  
80104197:	c3                   	ret    

80104198 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104198:	f3 0f 1e fb          	endbr32 
8010419c:	55                   	push   %ebp
8010419d:	89 e5                	mov    %esp,%ebp
8010419f:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801041a2:	8b 45 08             	mov    0x8(%ebp),%eax
801041a5:	83 ec 0c             	sub    $0xc,%esp
801041a8:	50                   	push   %eax
801041a9:	e8 cb 11 00 00       	call   80105379 <acquire>
801041ae:	83 c4 10             	add    $0x10,%esp
  if(writable){
801041b1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801041b5:	74 23                	je     801041da <pipeclose+0x42>
    p->writeopen = 0;
801041b7:	8b 45 08             	mov    0x8(%ebp),%eax
801041ba:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801041c1:	00 00 00 
    wakeup(&p->nread);
801041c4:	8b 45 08             	mov    0x8(%ebp),%eax
801041c7:	05 34 02 00 00       	add    $0x234,%eax
801041cc:	83 ec 0c             	sub    $0xc,%esp
801041cf:	50                   	push   %eax
801041d0:	e8 24 0e 00 00       	call   80104ff9 <wakeup>
801041d5:	83 c4 10             	add    $0x10,%esp
801041d8:	eb 21                	jmp    801041fb <pipeclose+0x63>
  } else {
    p->readopen = 0;
801041da:	8b 45 08             	mov    0x8(%ebp),%eax
801041dd:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801041e4:	00 00 00 
    wakeup(&p->nwrite);
801041e7:	8b 45 08             	mov    0x8(%ebp),%eax
801041ea:	05 38 02 00 00       	add    $0x238,%eax
801041ef:	83 ec 0c             	sub    $0xc,%esp
801041f2:	50                   	push   %eax
801041f3:	e8 01 0e 00 00       	call   80104ff9 <wakeup>
801041f8:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
801041fb:	8b 45 08             	mov    0x8(%ebp),%eax
801041fe:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104204:	85 c0                	test   %eax,%eax
80104206:	75 2c                	jne    80104234 <pipeclose+0x9c>
80104208:	8b 45 08             	mov    0x8(%ebp),%eax
8010420b:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104211:	85 c0                	test   %eax,%eax
80104213:	75 1f                	jne    80104234 <pipeclose+0x9c>
    release(&p->lock);
80104215:	8b 45 08             	mov    0x8(%ebp),%eax
80104218:	83 ec 0c             	sub    $0xc,%esp
8010421b:	50                   	push   %eax
8010421c:	e8 ca 11 00 00       	call   801053eb <release>
80104221:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104224:	83 ec 0c             	sub    $0xc,%esp
80104227:	ff 75 08             	pushl  0x8(%ebp)
8010422a:	e8 90 eb ff ff       	call   80102dbf <kfree>
8010422f:	83 c4 10             	add    $0x10,%esp
80104232:	eb 10                	jmp    80104244 <pipeclose+0xac>
  } else
    release(&p->lock);
80104234:	8b 45 08             	mov    0x8(%ebp),%eax
80104237:	83 ec 0c             	sub    $0xc,%esp
8010423a:	50                   	push   %eax
8010423b:	e8 ab 11 00 00       	call   801053eb <release>
80104240:	83 c4 10             	add    $0x10,%esp
}
80104243:	90                   	nop
80104244:	90                   	nop
80104245:	c9                   	leave  
80104246:	c3                   	ret    

80104247 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104247:	f3 0f 1e fb          	endbr32 
8010424b:	55                   	push   %ebp
8010424c:	89 e5                	mov    %esp,%ebp
8010424e:	53                   	push   %ebx
8010424f:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104252:	8b 45 08             	mov    0x8(%ebp),%eax
80104255:	83 ec 0c             	sub    $0xc,%esp
80104258:	50                   	push   %eax
80104259:	e8 1b 11 00 00       	call   80105379 <acquire>
8010425e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104261:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104268:	e9 ad 00 00 00       	jmp    8010431a <pipewrite+0xd3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
8010426d:	8b 45 08             	mov    0x8(%ebp),%eax
80104270:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104276:	85 c0                	test   %eax,%eax
80104278:	74 0c                	je     80104286 <pipewrite+0x3f>
8010427a:	e8 a2 02 00 00       	call   80104521 <myproc>
8010427f:	8b 40 24             	mov    0x24(%eax),%eax
80104282:	85 c0                	test   %eax,%eax
80104284:	74 19                	je     8010429f <pipewrite+0x58>
        release(&p->lock);
80104286:	8b 45 08             	mov    0x8(%ebp),%eax
80104289:	83 ec 0c             	sub    $0xc,%esp
8010428c:	50                   	push   %eax
8010428d:	e8 59 11 00 00       	call   801053eb <release>
80104292:	83 c4 10             	add    $0x10,%esp
        return -1;
80104295:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010429a:	e9 a9 00 00 00       	jmp    80104348 <pipewrite+0x101>
      }
      wakeup(&p->nread);
8010429f:	8b 45 08             	mov    0x8(%ebp),%eax
801042a2:	05 34 02 00 00       	add    $0x234,%eax
801042a7:	83 ec 0c             	sub    $0xc,%esp
801042aa:	50                   	push   %eax
801042ab:	e8 49 0d 00 00       	call   80104ff9 <wakeup>
801042b0:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801042b3:	8b 45 08             	mov    0x8(%ebp),%eax
801042b6:	8b 55 08             	mov    0x8(%ebp),%edx
801042b9:	81 c2 38 02 00 00    	add    $0x238,%edx
801042bf:	83 ec 08             	sub    $0x8,%esp
801042c2:	50                   	push   %eax
801042c3:	52                   	push   %edx
801042c4:	e8 3e 0c 00 00       	call   80104f07 <sleep>
801042c9:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801042cc:	8b 45 08             	mov    0x8(%ebp),%eax
801042cf:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801042d5:	8b 45 08             	mov    0x8(%ebp),%eax
801042d8:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801042de:	05 00 02 00 00       	add    $0x200,%eax
801042e3:	39 c2                	cmp    %eax,%edx
801042e5:	74 86                	je     8010426d <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801042e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801042ed:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801042f0:	8b 45 08             	mov    0x8(%ebp),%eax
801042f3:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042f9:	8d 48 01             	lea    0x1(%eax),%ecx
801042fc:	8b 55 08             	mov    0x8(%ebp),%edx
801042ff:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104305:	25 ff 01 00 00       	and    $0x1ff,%eax
8010430a:	89 c1                	mov    %eax,%ecx
8010430c:	0f b6 13             	movzbl (%ebx),%edx
8010430f:	8b 45 08             	mov    0x8(%ebp),%eax
80104312:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80104316:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010431a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010431d:	3b 45 10             	cmp    0x10(%ebp),%eax
80104320:	7c aa                	jl     801042cc <pipewrite+0x85>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104322:	8b 45 08             	mov    0x8(%ebp),%eax
80104325:	05 34 02 00 00       	add    $0x234,%eax
8010432a:	83 ec 0c             	sub    $0xc,%esp
8010432d:	50                   	push   %eax
8010432e:	e8 c6 0c 00 00       	call   80104ff9 <wakeup>
80104333:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104336:	8b 45 08             	mov    0x8(%ebp),%eax
80104339:	83 ec 0c             	sub    $0xc,%esp
8010433c:	50                   	push   %eax
8010433d:	e8 a9 10 00 00       	call   801053eb <release>
80104342:	83 c4 10             	add    $0x10,%esp
  return n;
80104345:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104348:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010434b:	c9                   	leave  
8010434c:	c3                   	ret    

8010434d <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010434d:	f3 0f 1e fb          	endbr32 
80104351:	55                   	push   %ebp
80104352:	89 e5                	mov    %esp,%ebp
80104354:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104357:	8b 45 08             	mov    0x8(%ebp),%eax
8010435a:	83 ec 0c             	sub    $0xc,%esp
8010435d:	50                   	push   %eax
8010435e:	e8 16 10 00 00       	call   80105379 <acquire>
80104363:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104366:	eb 3e                	jmp    801043a6 <piperead+0x59>
    if(myproc()->killed){
80104368:	e8 b4 01 00 00       	call   80104521 <myproc>
8010436d:	8b 40 24             	mov    0x24(%eax),%eax
80104370:	85 c0                	test   %eax,%eax
80104372:	74 19                	je     8010438d <piperead+0x40>
      release(&p->lock);
80104374:	8b 45 08             	mov    0x8(%ebp),%eax
80104377:	83 ec 0c             	sub    $0xc,%esp
8010437a:	50                   	push   %eax
8010437b:	e8 6b 10 00 00       	call   801053eb <release>
80104380:	83 c4 10             	add    $0x10,%esp
      return -1;
80104383:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104388:	e9 be 00 00 00       	jmp    8010444b <piperead+0xfe>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010438d:	8b 45 08             	mov    0x8(%ebp),%eax
80104390:	8b 55 08             	mov    0x8(%ebp),%edx
80104393:	81 c2 34 02 00 00    	add    $0x234,%edx
80104399:	83 ec 08             	sub    $0x8,%esp
8010439c:	50                   	push   %eax
8010439d:	52                   	push   %edx
8010439e:	e8 64 0b 00 00       	call   80104f07 <sleep>
801043a3:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801043a6:	8b 45 08             	mov    0x8(%ebp),%eax
801043a9:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801043af:	8b 45 08             	mov    0x8(%ebp),%eax
801043b2:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043b8:	39 c2                	cmp    %eax,%edx
801043ba:	75 0d                	jne    801043c9 <piperead+0x7c>
801043bc:	8b 45 08             	mov    0x8(%ebp),%eax
801043bf:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801043c5:	85 c0                	test   %eax,%eax
801043c7:	75 9f                	jne    80104368 <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801043c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801043d0:	eb 48                	jmp    8010441a <piperead+0xcd>
    if(p->nread == p->nwrite)
801043d2:	8b 45 08             	mov    0x8(%ebp),%eax
801043d5:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801043db:	8b 45 08             	mov    0x8(%ebp),%eax
801043de:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043e4:	39 c2                	cmp    %eax,%edx
801043e6:	74 3c                	je     80104424 <piperead+0xd7>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801043e8:	8b 45 08             	mov    0x8(%ebp),%eax
801043eb:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801043f1:	8d 48 01             	lea    0x1(%eax),%ecx
801043f4:	8b 55 08             	mov    0x8(%ebp),%edx
801043f7:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801043fd:	25 ff 01 00 00       	and    $0x1ff,%eax
80104402:	89 c1                	mov    %eax,%ecx
80104404:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104407:	8b 45 0c             	mov    0xc(%ebp),%eax
8010440a:	01 c2                	add    %eax,%edx
8010440c:	8b 45 08             	mov    0x8(%ebp),%eax
8010440f:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80104414:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104416:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010441a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010441d:	3b 45 10             	cmp    0x10(%ebp),%eax
80104420:	7c b0                	jl     801043d2 <piperead+0x85>
80104422:	eb 01                	jmp    80104425 <piperead+0xd8>
      break;
80104424:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104425:	8b 45 08             	mov    0x8(%ebp),%eax
80104428:	05 38 02 00 00       	add    $0x238,%eax
8010442d:	83 ec 0c             	sub    $0xc,%esp
80104430:	50                   	push   %eax
80104431:	e8 c3 0b 00 00       	call   80104ff9 <wakeup>
80104436:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104439:	8b 45 08             	mov    0x8(%ebp),%eax
8010443c:	83 ec 0c             	sub    $0xc,%esp
8010443f:	50                   	push   %eax
80104440:	e8 a6 0f 00 00       	call   801053eb <release>
80104445:	83 c4 10             	add    $0x10,%esp
  return i;
80104448:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010444b:	c9                   	leave  
8010444c:	c3                   	ret    

8010444d <readeflags>:
{
8010444d:	55                   	push   %ebp
8010444e:	89 e5                	mov    %esp,%ebp
80104450:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104453:	9c                   	pushf  
80104454:	58                   	pop    %eax
80104455:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104458:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010445b:	c9                   	leave  
8010445c:	c3                   	ret    

8010445d <sti>:
{
8010445d:	55                   	push   %ebp
8010445e:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104460:	fb                   	sti    
}
80104461:	90                   	nop
80104462:	5d                   	pop    %ebp
80104463:	c3                   	ret    

80104464 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104464:	f3 0f 1e fb          	endbr32 
80104468:	55                   	push   %ebp
80104469:	89 e5                	mov    %esp,%ebp
8010446b:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
8010446e:	83 ec 08             	sub    $0x8,%esp
80104471:	68 5c 98 10 80       	push   $0x8010985c
80104476:	68 c0 5d 11 80       	push   $0x80115dc0
8010447b:	e8 d3 0e 00 00       	call   80105353 <initlock>
80104480:	83 c4 10             	add    $0x10,%esp
}
80104483:	90                   	nop
80104484:	c9                   	leave  
80104485:	c3                   	ret    

80104486 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80104486:	f3 0f 1e fb          	endbr32 
8010448a:	55                   	push   %ebp
8010448b:	89 e5                	mov    %esp,%ebp
8010448d:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80104490:	e8 10 00 00 00       	call   801044a5 <mycpu>
80104495:	2d 20 58 11 80       	sub    $0x80115820,%eax
8010449a:	c1 f8 04             	sar    $0x4,%eax
8010449d:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801044a3:	c9                   	leave  
801044a4:	c3                   	ret    

801044a5 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801044a5:	f3 0f 1e fb          	endbr32 
801044a9:	55                   	push   %ebp
801044aa:	89 e5                	mov    %esp,%ebp
801044ac:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
801044af:	e8 99 ff ff ff       	call   8010444d <readeflags>
801044b4:	25 00 02 00 00       	and    $0x200,%eax
801044b9:	85 c0                	test   %eax,%eax
801044bb:	74 0d                	je     801044ca <mycpu+0x25>
    panic("mycpu called with interrupts enabled\n");
801044bd:	83 ec 0c             	sub    $0xc,%esp
801044c0:	68 64 98 10 80       	push   $0x80109864
801044c5:	e8 3e c1 ff ff       	call   80100608 <panic>
  
  apicid = lapicid();
801044ca:	e8 21 ed ff ff       	call   801031f0 <lapicid>
801044cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801044d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801044d9:	eb 2d                	jmp    80104508 <mycpu+0x63>
    if (cpus[i].apicid == apicid)
801044db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044de:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801044e4:	05 20 58 11 80       	add    $0x80115820,%eax
801044e9:	0f b6 00             	movzbl (%eax),%eax
801044ec:	0f b6 c0             	movzbl %al,%eax
801044ef:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801044f2:	75 10                	jne    80104504 <mycpu+0x5f>
      return &cpus[i];
801044f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f7:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801044fd:	05 20 58 11 80       	add    $0x80115820,%eax
80104502:	eb 1b                	jmp    8010451f <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
80104504:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104508:	a1 a0 5d 11 80       	mov    0x80115da0,%eax
8010450d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104510:	7c c9                	jl     801044db <mycpu+0x36>
  }
  panic("unknown apicid\n");
80104512:	83 ec 0c             	sub    $0xc,%esp
80104515:	68 8a 98 10 80       	push   $0x8010988a
8010451a:	e8 e9 c0 ff ff       	call   80100608 <panic>
}
8010451f:	c9                   	leave  
80104520:	c3                   	ret    

80104521 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80104521:	f3 0f 1e fb          	endbr32 
80104525:	55                   	push   %ebp
80104526:	89 e5                	mov    %esp,%ebp
80104528:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
8010452b:	e8 d5 0f 00 00       	call   80105505 <pushcli>
  c = mycpu();
80104530:	e8 70 ff ff ff       	call   801044a5 <mycpu>
80104535:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80104538:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010453b:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104541:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80104544:	e8 0d 10 00 00       	call   80105556 <popcli>
  return p;
80104549:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010454c:	c9                   	leave  
8010454d:	c3                   	ret    

8010454e <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010454e:	f3 0f 1e fb          	endbr32 
80104552:	55                   	push   %ebp
80104553:	89 e5                	mov    %esp,%ebp
80104555:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104558:	83 ec 0c             	sub    $0xc,%esp
8010455b:	68 c0 5d 11 80       	push   $0x80115dc0
80104560:	e8 14 0e 00 00       	call   80105379 <acquire>
80104565:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104568:	c7 45 f4 f4 5d 11 80 	movl   $0x80115df4,-0xc(%ebp)
8010456f:	eb 11                	jmp    80104582 <allocproc+0x34>
    if(p->state == UNUSED)
80104571:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104574:	8b 40 0c             	mov    0xc(%eax),%eax
80104577:	85 c0                	test   %eax,%eax
80104579:	74 2a                	je     801045a5 <allocproc+0x57>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010457b:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104582:	81 7d f4 f4 85 11 80 	cmpl   $0x801185f4,-0xc(%ebp)
80104589:	72 e6                	jb     80104571 <allocproc+0x23>
      goto found;

  release(&ptable.lock);
8010458b:	83 ec 0c             	sub    $0xc,%esp
8010458e:	68 c0 5d 11 80       	push   $0x80115dc0
80104593:	e8 53 0e 00 00       	call   801053eb <release>
80104598:	83 c4 10             	add    $0x10,%esp
  return 0;
8010459b:	b8 00 00 00 00       	mov    $0x0,%eax
801045a0:	e9 b6 00 00 00       	jmp    8010465b <allocproc+0x10d>
      goto found;
801045a5:	90                   	nop
801045a6:	f3 0f 1e fb          	endbr32 

found:
  p->state = EMBRYO;
801045aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ad:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801045b4:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801045b9:	8d 50 01             	lea    0x1(%eax),%edx
801045bc:	89 15 00 d0 10 80    	mov    %edx,0x8010d000
801045c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045c5:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
801045c8:	83 ec 0c             	sub    $0xc,%esp
801045cb:	68 c0 5d 11 80       	push   $0x80115dc0
801045d0:	e8 16 0e 00 00       	call   801053eb <release>
801045d5:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801045d8:	e8 80 e8 ff ff       	call   80102e5d <kalloc>
801045dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045e0:	89 42 08             	mov    %eax,0x8(%edx)
801045e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e6:	8b 40 08             	mov    0x8(%eax),%eax
801045e9:	85 c0                	test   %eax,%eax
801045eb:	75 11                	jne    801045fe <allocproc+0xb0>
    p->state = UNUSED;
801045ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801045f7:	b8 00 00 00 00       	mov    $0x0,%eax
801045fc:	eb 5d                	jmp    8010465b <allocproc+0x10d>
  }
  sp = p->kstack + KSTACKSIZE;
801045fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104601:	8b 40 08             	mov    0x8(%eax),%eax
80104604:	05 00 10 00 00       	add    $0x1000,%eax
80104609:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010460c:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104610:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104613:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104616:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104619:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010461d:	ba 8e 6b 10 80       	mov    $0x80106b8e,%edx
80104622:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104625:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104627:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010462b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010462e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104631:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104634:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104637:	8b 40 1c             	mov    0x1c(%eax),%eax
8010463a:	83 ec 04             	sub    $0x4,%esp
8010463d:	6a 14                	push   $0x14
8010463f:	6a 00                	push   $0x0
80104641:	50                   	push   %eax
80104642:	e8 d1 0f 00 00       	call   80105618 <memset>
80104647:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
8010464a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010464d:	8b 40 1c             	mov    0x1c(%eax),%eax
80104650:	ba bd 4e 10 80       	mov    $0x80104ebd,%edx
80104655:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104658:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010465b:	c9                   	leave  
8010465c:	c3                   	ret    

8010465d <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010465d:	f3 0f 1e fb          	endbr32 
80104661:	55                   	push   %ebp
80104662:	89 e5                	mov    %esp,%ebp
80104664:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80104667:	e8 e2 fe ff ff       	call   8010454e <allocproc>
8010466c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
8010466f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104672:	a3 40 d6 10 80       	mov    %eax,0x8010d640
  if((p->pgdir = setupkvm()) == 0)
80104677:	e8 11 3b 00 00       	call   8010818d <setupkvm>
8010467c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010467f:	89 42 04             	mov    %eax,0x4(%edx)
80104682:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104685:	8b 40 04             	mov    0x4(%eax),%eax
80104688:	85 c0                	test   %eax,%eax
8010468a:	75 0d                	jne    80104699 <userinit+0x3c>
    panic("userinit: out of memory?");
8010468c:	83 ec 0c             	sub    $0xc,%esp
8010468f:	68 9a 98 10 80       	push   $0x8010989a
80104694:	e8 6f bf ff ff       	call   80100608 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104699:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010469e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a1:	8b 40 04             	mov    0x4(%eax),%eax
801046a4:	83 ec 04             	sub    $0x4,%esp
801046a7:	52                   	push   %edx
801046a8:	68 e0 d4 10 80       	push   $0x8010d4e0
801046ad:	50                   	push   %eax
801046ae:	e8 53 3d 00 00       	call   80108406 <inituvm>
801046b3:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
801046b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b9:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801046bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c2:	8b 40 18             	mov    0x18(%eax),%eax
801046c5:	83 ec 04             	sub    $0x4,%esp
801046c8:	6a 4c                	push   $0x4c
801046ca:	6a 00                	push   $0x0
801046cc:	50                   	push   %eax
801046cd:	e8 46 0f 00 00       	call   80105618 <memset>
801046d2:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801046d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d8:	8b 40 18             	mov    0x18(%eax),%eax
801046db:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801046e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e4:	8b 40 18             	mov    0x18(%eax),%eax
801046e7:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801046ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f0:	8b 50 18             	mov    0x18(%eax),%edx
801046f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f6:	8b 40 18             	mov    0x18(%eax),%eax
801046f9:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801046fd:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104701:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104704:	8b 50 18             	mov    0x18(%eax),%edx
80104707:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010470a:	8b 40 18             	mov    0x18(%eax),%eax
8010470d:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104711:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104718:	8b 40 18             	mov    0x18(%eax),%eax
8010471b:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104722:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104725:	8b 40 18             	mov    0x18(%eax),%eax
80104728:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010472f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104732:	8b 40 18             	mov    0x18(%eax),%eax
80104735:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010473c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010473f:	83 c0 6c             	add    $0x6c,%eax
80104742:	83 ec 04             	sub    $0x4,%esp
80104745:	6a 10                	push   $0x10
80104747:	68 b3 98 10 80       	push   $0x801098b3
8010474c:	50                   	push   %eax
8010474d:	e8 e1 10 00 00       	call   80105833 <safestrcpy>
80104752:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104755:	83 ec 0c             	sub    $0xc,%esp
80104758:	68 bc 98 10 80       	push   $0x801098bc
8010475d:	e8 76 df ff ff       	call   801026d8 <namei>
80104762:	83 c4 10             	add    $0x10,%esp
80104765:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104768:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignpent to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
8010476b:	83 ec 0c             	sub    $0xc,%esp
8010476e:	68 c0 5d 11 80       	push   $0x80115dc0
80104773:	e8 01 0c 00 00       	call   80105379 <acquire>
80104778:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
8010477b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010477e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104785:	83 ec 0c             	sub    $0xc,%esp
80104788:	68 c0 5d 11 80       	push   $0x80115dc0
8010478d:	e8 59 0c 00 00       	call   801053eb <release>
80104792:	83 c4 10             	add    $0x10,%esp
}
80104795:	90                   	nop
80104796:	c9                   	leave  
80104797:	c3                   	ret    

80104798 <growproc>:
//
// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104798:	f3 0f 1e fb          	endbr32 
8010479c:	55                   	push   %ebp
8010479d:	89 e5                	mov    %esp,%ebp
8010479f:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
801047a2:	e8 7a fd ff ff       	call   80104521 <myproc>
801047a7:	89 45 ec             	mov    %eax,-0x14(%ebp)

  sz = curproc->sz;
801047aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047ad:	8b 00                	mov    (%eax),%eax
801047af:	89 45 f4             	mov    %eax,-0xc(%ebp)

 //  uint sz_copy = sz;
  if(n > 0){
801047b2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801047b6:	0f 8e 80 00 00 00    	jle    8010483c <growproc+0xa4>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801047bc:	8b 55 08             	mov    0x8(%ebp),%edx
801047bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047c2:	01 c2                	add    %eax,%edx
801047c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047c7:	8b 40 04             	mov    0x4(%eax),%eax
801047ca:	83 ec 04             	sub    $0x4,%esp
801047cd:	52                   	push   %edx
801047ce:	ff 75 f4             	pushl  -0xc(%ebp)
801047d1:	50                   	push   %eax
801047d2:	e8 74 3d 00 00       	call   8010854b <allocuvm>
801047d7:	83 c4 10             	add    $0x10,%esp
801047da:	89 45 f4             	mov    %eax,-0xc(%ebp)
801047dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047e1:	75 0a                	jne    801047ed <growproc+0x55>
      return -1;
801047e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047e8:	e9 9e 00 00 00       	jmp    8010488b <growproc+0xf3>
    uint a;
    a = curproc->sz;
801047ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047f0:	8b 00                	mov    (%eax),%eax
801047f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (n % PGSIZE)
801047f5:	8b 45 08             	mov    0x8(%ebp),%eax
801047f8:	25 ff 0f 00 00       	and    $0xfff,%eax
801047fd:	85 c0                	test   %eax,%eax
801047ff:	74 2a                	je     8010482b <growproc+0x93>
      n = PGROUNDUP(n);
80104801:	8b 45 08             	mov    0x8(%ebp),%eax
80104804:	05 ff 0f 00 00       	add    $0xfff,%eax
80104809:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010480e:	89 45 08             	mov    %eax,0x8(%ebp)
    for ( ; a<curproc->sz+n; a+=PGSIZE){
80104811:	eb 18                	jmp    8010482b <growproc+0x93>
    	mencrypt((char*)a, 1);
80104813:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104816:	83 ec 08             	sub    $0x8,%esp
80104819:	6a 01                	push   $0x1
8010481b:	50                   	push   %eax
8010481c:	e8 cc 47 00 00       	call   80108fed <mencrypt>
80104821:	83 c4 10             	add    $0x10,%esp
    for ( ; a<curproc->sz+n; a+=PGSIZE){
80104824:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
8010482b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010482e:	8b 10                	mov    (%eax),%edx
80104830:	8b 45 08             	mov    0x8(%ebp),%eax
80104833:	01 d0                	add    %edx,%eax
80104835:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80104838:	72 d9                	jb     80104813 <growproc+0x7b>
8010483a:	eb 34                	jmp    80104870 <growproc+0xd8>
 // mencrypt(0, t-2);
 // mencrypt((char*) ((t-1)*PGSIZE),1);
 // mencrypt((char*) ((t)*PGSIZE),n/PGSIZE);


  } else if(n < 0){
8010483c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104840:	79 2e                	jns    80104870 <growproc+0xd8>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104842:	8b 55 08             	mov    0x8(%ebp),%edx
80104845:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104848:	01 c2                	add    %eax,%edx
8010484a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010484d:	8b 40 04             	mov    0x4(%eax),%eax
80104850:	83 ec 04             	sub    $0x4,%esp
80104853:	52                   	push   %edx
80104854:	ff 75 f4             	pushl  -0xc(%ebp)
80104857:	50                   	push   %eax
80104858:	e8 f7 3d 00 00       	call   80108654 <deallocuvm>
8010485d:	83 c4 10             	add    $0x10,%esp
80104860:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104863:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104867:	75 07                	jne    80104870 <growproc+0xd8>
	//	    int ind = inQ(curproc, (char* )(sz + i*PGSIZE));
	  //  	    if(ind!=-1)
	//	    {curproc->clock[ind]=0;
	//	    	    cprintf("==========change head ??\n");}
	  //  }
	    return -1;}
80104869:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010486e:	eb 1b                	jmp    8010488b <growproc+0xf3>
	*pte = *pte & ~PTE_A;
        //curproc->clock[i].ref = 0;
      }
*/
  }
  curproc->sz = sz;
80104870:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104873:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104876:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80104878:	83 ec 0c             	sub    $0xc,%esp
8010487b:	ff 75 ec             	pushl  -0x14(%ebp)
8010487e:	e8 e0 39 00 00       	call   80108263 <switchuvm>
80104883:	83 c4 10             	add    $0x10,%esp
  return 0;
80104886:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010488b:	c9                   	leave  
8010488c:	c3                   	ret    

8010488d <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010488d:	f3 0f 1e fb          	endbr32 
80104891:	55                   	push   %ebp
80104892:	89 e5                	mov    %esp,%ebp
80104894:	57                   	push   %edi
80104895:	56                   	push   %esi
80104896:	53                   	push   %ebx
80104897:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
8010489a:	e8 82 fc ff ff       	call   80104521 <myproc>
8010489f:	89 45 d8             	mov    %eax,-0x28(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
801048a2:	e8 a7 fc ff ff       	call   8010454e <allocproc>
801048a7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801048aa:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
801048ae:	75 0a                	jne    801048ba <fork+0x2d>
    return -1;
801048b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048b5:	e9 f3 01 00 00       	jmp    80104aad <fork+0x220>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801048ba:	8b 45 d8             	mov    -0x28(%ebp),%eax
801048bd:	8b 10                	mov    (%eax),%edx
801048bf:	8b 45 d8             	mov    -0x28(%ebp),%eax
801048c2:	8b 40 04             	mov    0x4(%eax),%eax
801048c5:	83 ec 08             	sub    $0x8,%esp
801048c8:	52                   	push   %edx
801048c9:	50                   	push   %eax
801048ca:	e8 33 3f 00 00       	call   80108802 <copyuvm>
801048cf:	83 c4 10             	add    $0x10,%esp
801048d2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801048d5:	89 42 04             	mov    %eax,0x4(%edx)
801048d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801048db:	8b 40 04             	mov    0x4(%eax),%eax
801048de:	85 c0                	test   %eax,%eax
801048e0:	75 30                	jne    80104912 <fork+0x85>
    kfree(np->kstack);
801048e2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801048e5:	8b 40 08             	mov    0x8(%eax),%eax
801048e8:	83 ec 0c             	sub    $0xc,%esp
801048eb:	50                   	push   %eax
801048ec:	e8 ce e4 ff ff       	call   80102dbf <kfree>
801048f1:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801048f4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801048f7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801048fe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80104901:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104908:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010490d:	e9 9b 01 00 00       	jmp    80104aad <fork+0x220>
  }
  np->sz = curproc->sz;
80104912:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104915:	8b 10                	mov    (%eax),%edx
80104917:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010491a:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
8010491c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010491f:	8b 55 d8             	mov    -0x28(%ebp),%edx
80104922:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80104925:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104928:	8b 48 18             	mov    0x18(%eax),%ecx
8010492b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010492e:	8b 40 18             	mov    0x18(%eax),%eax
80104931:	89 c2                	mov    %eax,%edx
80104933:	89 cb                	mov    %ecx,%ebx
80104935:	b8 13 00 00 00       	mov    $0x13,%eax
8010493a:	89 d7                	mov    %edx,%edi
8010493c:	89 de                	mov    %ebx,%esi
8010493e:	89 c1                	mov    %eax,%ecx
80104940:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
    np->clock[i].addr = curproc->clock[i].addr;
    np->clock[i].ref = curproc->clock[i].ref; 
  }
*/

  for(int i=0; i<CLOCKSIZE; i++){
80104942:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80104949:	eb 15                	jmp    80104960 <fork+0xd3>
  np->clock[i] = NULL;}
8010494b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010494e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104951:	83 c2 1c             	add    $0x1c,%edx
80104954:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
8010495b:	00 
  for(int i=0; i<CLOCKSIZE; i++){
8010495c:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80104960:	83 7d e0 07          	cmpl   $0x7,-0x20(%ebp)
80104964:	7e e5                	jle    8010494b <fork+0xbe>
  np->head = curproc->head;
80104966:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104969:	8b 90 9c 00 00 00    	mov    0x9c(%eax),%edx
8010496f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80104972:	89 90 9c 00 00 00    	mov    %edx,0x9c(%eax)
  
  for(int i=np->head; i<np->head+CLOCKSIZE; i++)
80104978:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010497b:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80104981:	89 45 dc             	mov    %eax,-0x24(%ebp)
80104984:	eb 56                	jmp    801049dc <fork+0x14f>
  {
	  if(curproc->clock[i%CLOCKSIZE]!=NULL){
80104986:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104989:	99                   	cltd   
8010498a:	c1 ea 1d             	shr    $0x1d,%edx
8010498d:	01 d0                	add    %edx,%eax
8010498f:	83 e0 07             	and    $0x7,%eax
80104992:	29 d0                	sub    %edx,%eax
80104994:	89 c2                	mov    %eax,%edx
80104996:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104999:	83 c2 1c             	add    $0x1c,%edx
8010499c:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801049a0:	85 c0                	test   %eax,%eax
801049a2:	74 34                	je     801049d8 <fork+0x14b>
		  //char * check = curproc->clock[i%CLOCKSIZE];
		  //& PTE_A)>0)
		  np->clock[i%CLOCKSIZE] = curproc->clock[i%CLOCKSIZE];
801049a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049a7:	99                   	cltd   
801049a8:	c1 ea 1d             	shr    $0x1d,%edx
801049ab:	01 d0                	add    %edx,%eax
801049ad:	83 e0 07             	and    $0x7,%eax
801049b0:	29 d0                	sub    %edx,%eax
801049b2:	89 c3                	mov    %eax,%ebx
801049b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049b7:	99                   	cltd   
801049b8:	c1 ea 1d             	shr    $0x1d,%edx
801049bb:	01 d0                	add    %edx,%eax
801049bd:	83 e0 07             	and    $0x7,%eax
801049c0:	29 d0                	sub    %edx,%eax
801049c2:	89 c1                	mov    %eax,%ecx
801049c4:	8b 45 d8             	mov    -0x28(%ebp),%eax
801049c7:	8d 53 1c             	lea    0x1c(%ebx),%edx
801049ca:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
801049ce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801049d1:	83 c1 1c             	add    $0x1c,%ecx
801049d4:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
  for(int i=np->head; i<np->head+CLOCKSIZE; i++)
801049d8:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
801049dc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801049df:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
801049e5:	83 c0 07             	add    $0x7,%eax
801049e8:	39 45 dc             	cmp    %eax,-0x24(%ebp)
801049eb:	7e 99                	jle    80104986 <fork+0xf9>
 		 }
  }


  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801049ed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801049f0:	8b 40 18             	mov    0x18(%eax),%eax
801049f3:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801049fa:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104a01:	eb 3b                	jmp    80104a3e <fork+0x1b1>
    if(curproc->ofile[i])
80104a03:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104a06:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104a09:	83 c2 08             	add    $0x8,%edx
80104a0c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a10:	85 c0                	test   %eax,%eax
80104a12:	74 26                	je     80104a3a <fork+0x1ad>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104a14:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104a17:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104a1a:	83 c2 08             	add    $0x8,%edx
80104a1d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a21:	83 ec 0c             	sub    $0xc,%esp
80104a24:	50                   	push   %eax
80104a25:	e8 6e c7 ff ff       	call   80101198 <filedup>
80104a2a:	83 c4 10             	add    $0x10,%esp
80104a2d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80104a30:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104a33:	83 c1 08             	add    $0x8,%ecx
80104a36:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80104a3a:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104a3e:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104a42:	7e bf                	jle    80104a03 <fork+0x176>
  np->cwd = idup(curproc->cwd);
80104a44:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104a47:	8b 40 68             	mov    0x68(%eax),%eax
80104a4a:	83 ec 0c             	sub    $0xc,%esp
80104a4d:	50                   	push   %eax
80104a4e:	e8 dc d0 ff ff       	call   80101b2f <idup>
80104a53:	83 c4 10             	add    $0x10,%esp
80104a56:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80104a59:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104a5c:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104a5f:	8d 50 6c             	lea    0x6c(%eax),%edx
80104a62:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80104a65:	83 c0 6c             	add    $0x6c,%eax
80104a68:	83 ec 04             	sub    $0x4,%esp
80104a6b:	6a 10                	push   $0x10
80104a6d:	52                   	push   %edx
80104a6e:	50                   	push   %eax
80104a6f:	e8 bf 0d 00 00       	call   80105833 <safestrcpy>
80104a74:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104a77:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80104a7a:	8b 40 10             	mov    0x10(%eax),%eax
80104a7d:	89 45 d0             	mov    %eax,-0x30(%ebp)

  acquire(&ptable.lock);
80104a80:	83 ec 0c             	sub    $0xc,%esp
80104a83:	68 c0 5d 11 80       	push   $0x80115dc0
80104a88:	e8 ec 08 00 00       	call   80105379 <acquire>
80104a8d:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80104a90:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80104a93:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104a9a:	83 ec 0c             	sub    $0xc,%esp
80104a9d:	68 c0 5d 11 80       	push   $0x80115dc0
80104aa2:	e8 44 09 00 00       	call   801053eb <release>
80104aa7:	83 c4 10             	add    $0x10,%esp

  return pid;
80104aaa:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
80104aad:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104ab0:	5b                   	pop    %ebx
80104ab1:	5e                   	pop    %esi
80104ab2:	5f                   	pop    %edi
80104ab3:	5d                   	pop    %ebp
80104ab4:	c3                   	ret    

80104ab5 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104ab5:	f3 0f 1e fb          	endbr32 
80104ab9:	55                   	push   %ebp
80104aba:	89 e5                	mov    %esp,%ebp
80104abc:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104abf:	e8 5d fa ff ff       	call   80104521 <myproc>
80104ac4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104ac7:	a1 40 d6 10 80       	mov    0x8010d640,%eax
80104acc:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104acf:	75 0d                	jne    80104ade <exit+0x29>
    panic("init exiting");
80104ad1:	83 ec 0c             	sub    $0xc,%esp
80104ad4:	68 be 98 10 80       	push   $0x801098be
80104ad9:	e8 2a bb ff ff       	call   80100608 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104ade:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104ae5:	eb 3f                	jmp    80104b26 <exit+0x71>
    if(curproc->ofile[fd]){
80104ae7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104aea:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104aed:	83 c2 08             	add    $0x8,%edx
80104af0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104af4:	85 c0                	test   %eax,%eax
80104af6:	74 2a                	je     80104b22 <exit+0x6d>
      fileclose(curproc->ofile[fd]);
80104af8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104afb:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104afe:	83 c2 08             	add    $0x8,%edx
80104b01:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104b05:	83 ec 0c             	sub    $0xc,%esp
80104b08:	50                   	push   %eax
80104b09:	e8 df c6 ff ff       	call   801011ed <fileclose>
80104b0e:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104b11:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b14:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104b17:	83 c2 08             	add    $0x8,%edx
80104b1a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104b21:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104b22:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104b26:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104b2a:	7e bb                	jle    80104ae7 <exit+0x32>
    }
  }

  begin_op();
80104b2c:	e8 31 ec ff ff       	call   80103762 <begin_op>
  iput(curproc->cwd);
80104b31:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b34:	8b 40 68             	mov    0x68(%eax),%eax
80104b37:	83 ec 0c             	sub    $0xc,%esp
80104b3a:	50                   	push   %eax
80104b3b:	e8 96 d1 ff ff       	call   80101cd6 <iput>
80104b40:	83 c4 10             	add    $0x10,%esp
  end_op();
80104b43:	e8 aa ec ff ff       	call   801037f2 <end_op>
  curproc->cwd = 0;
80104b48:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b4b:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104b52:	83 ec 0c             	sub    $0xc,%esp
80104b55:	68 c0 5d 11 80       	push   $0x80115dc0
80104b5a:	e8 1a 08 00 00       	call   80105379 <acquire>
80104b5f:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104b62:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b65:	8b 40 14             	mov    0x14(%eax),%eax
80104b68:	83 ec 0c             	sub    $0xc,%esp
80104b6b:	50                   	push   %eax
80104b6c:	e8 41 04 00 00       	call   80104fb2 <wakeup1>
80104b71:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b74:	c7 45 f4 f4 5d 11 80 	movl   $0x80115df4,-0xc(%ebp)
80104b7b:	eb 3a                	jmp    80104bb7 <exit+0x102>
    if(p->parent == curproc){
80104b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b80:	8b 40 14             	mov    0x14(%eax),%eax
80104b83:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104b86:	75 28                	jne    80104bb0 <exit+0xfb>
      p->parent = initproc;
80104b88:	8b 15 40 d6 10 80    	mov    0x8010d640,%edx
80104b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b91:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104b94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b97:	8b 40 0c             	mov    0xc(%eax),%eax
80104b9a:	83 f8 05             	cmp    $0x5,%eax
80104b9d:	75 11                	jne    80104bb0 <exit+0xfb>
        wakeup1(initproc);
80104b9f:	a1 40 d6 10 80       	mov    0x8010d640,%eax
80104ba4:	83 ec 0c             	sub    $0xc,%esp
80104ba7:	50                   	push   %eax
80104ba8:	e8 05 04 00 00       	call   80104fb2 <wakeup1>
80104bad:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bb0:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104bb7:	81 7d f4 f4 85 11 80 	cmpl   $0x801185f4,-0xc(%ebp)
80104bbe:	72 bd                	jb     80104b7d <exit+0xc8>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104bc0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104bc3:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104bca:	e8 f3 01 00 00       	call   80104dc2 <sched>
  panic("zombie exit");
80104bcf:	83 ec 0c             	sub    $0xc,%esp
80104bd2:	68 cb 98 10 80       	push   $0x801098cb
80104bd7:	e8 2c ba ff ff       	call   80100608 <panic>

80104bdc <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104bdc:	f3 0f 1e fb          	endbr32 
80104be0:	55                   	push   %ebp
80104be1:	89 e5                	mov    %esp,%ebp
80104be3:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104be6:	e8 36 f9 ff ff       	call   80104521 <myproc>
80104beb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104bee:	83 ec 0c             	sub    $0xc,%esp
80104bf1:	68 c0 5d 11 80       	push   $0x80115dc0
80104bf6:	e8 7e 07 00 00       	call   80105379 <acquire>
80104bfb:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104bfe:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c05:	c7 45 f4 f4 5d 11 80 	movl   $0x80115df4,-0xc(%ebp)
80104c0c:	e9 a4 00 00 00       	jmp    80104cb5 <wait+0xd9>
      if(p->parent != curproc)
80104c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c14:	8b 40 14             	mov    0x14(%eax),%eax
80104c17:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104c1a:	0f 85 8d 00 00 00    	jne    80104cad <wait+0xd1>
        continue;
      havekids = 1;
80104c20:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c2a:	8b 40 0c             	mov    0xc(%eax),%eax
80104c2d:	83 f8 05             	cmp    $0x5,%eax
80104c30:	75 7c                	jne    80104cae <wait+0xd2>
        // Found one.
        pid = p->pid;
80104c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c35:	8b 40 10             	mov    0x10(%eax),%eax
80104c38:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c3e:	8b 40 08             	mov    0x8(%eax),%eax
80104c41:	83 ec 0c             	sub    $0xc,%esp
80104c44:	50                   	push   %eax
80104c45:	e8 75 e1 ff ff       	call   80102dbf <kfree>
80104c4a:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c50:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c5a:	8b 40 04             	mov    0x4(%eax),%eax
80104c5d:	83 ec 0c             	sub    $0xc,%esp
80104c60:	50                   	push   %eax
80104c61:	e8 b8 3a 00 00       	call   8010871e <freevm>
80104c66:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104c69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c6c:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c76:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104c7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c80:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104c84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c87:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c91:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104c98:	83 ec 0c             	sub    $0xc,%esp
80104c9b:	68 c0 5d 11 80       	push   $0x80115dc0
80104ca0:	e8 46 07 00 00       	call   801053eb <release>
80104ca5:	83 c4 10             	add    $0x10,%esp
        return pid;
80104ca8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104cab:	eb 54                	jmp    80104d01 <wait+0x125>
        continue;
80104cad:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cae:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104cb5:	81 7d f4 f4 85 11 80 	cmpl   $0x801185f4,-0xc(%ebp)
80104cbc:	0f 82 4f ff ff ff    	jb     80104c11 <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104cc2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104cc6:	74 0a                	je     80104cd2 <wait+0xf6>
80104cc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ccb:	8b 40 24             	mov    0x24(%eax),%eax
80104cce:	85 c0                	test   %eax,%eax
80104cd0:	74 17                	je     80104ce9 <wait+0x10d>
      release(&ptable.lock);
80104cd2:	83 ec 0c             	sub    $0xc,%esp
80104cd5:	68 c0 5d 11 80       	push   $0x80115dc0
80104cda:	e8 0c 07 00 00       	call   801053eb <release>
80104cdf:	83 c4 10             	add    $0x10,%esp
      return -1;
80104ce2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ce7:	eb 18                	jmp    80104d01 <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104ce9:	83 ec 08             	sub    $0x8,%esp
80104cec:	68 c0 5d 11 80       	push   $0x80115dc0
80104cf1:	ff 75 ec             	pushl  -0x14(%ebp)
80104cf4:	e8 0e 02 00 00       	call   80104f07 <sleep>
80104cf9:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104cfc:	e9 fd fe ff ff       	jmp    80104bfe <wait+0x22>
  }
}
80104d01:	c9                   	leave  
80104d02:	c3                   	ret    

80104d03 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104d03:	f3 0f 1e fb          	endbr32 
80104d07:	55                   	push   %ebp
80104d08:	89 e5                	mov    %esp,%ebp
80104d0a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104d0d:	e8 93 f7 ff ff       	call   801044a5 <mycpu>
80104d12:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104d15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d18:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104d1f:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104d22:	e8 36 f7 ff ff       	call   8010445d <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104d27:	83 ec 0c             	sub    $0xc,%esp
80104d2a:	68 c0 5d 11 80       	push   $0x80115dc0
80104d2f:	e8 45 06 00 00       	call   80105379 <acquire>
80104d34:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d37:	c7 45 f4 f4 5d 11 80 	movl   $0x80115df4,-0xc(%ebp)
80104d3e:	eb 64                	jmp    80104da4 <scheduler+0xa1>
      if(p->state != RUNNABLE)
80104d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d43:	8b 40 0c             	mov    0xc(%eax),%eax
80104d46:	83 f8 03             	cmp    $0x3,%eax
80104d49:	75 51                	jne    80104d9c <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104d4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d4e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d51:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104d57:	83 ec 0c             	sub    $0xc,%esp
80104d5a:	ff 75 f4             	pushl  -0xc(%ebp)
80104d5d:	e8 01 35 00 00       	call   80108263 <switchuvm>
80104d62:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104d65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d68:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d72:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d75:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d78:	83 c2 04             	add    $0x4,%edx
80104d7b:	83 ec 08             	sub    $0x8,%esp
80104d7e:	50                   	push   %eax
80104d7f:	52                   	push   %edx
80104d80:	e8 27 0b 00 00       	call   801058ac <swtch>
80104d85:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104d88:	e8 b9 34 00 00       	call   80108246 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104d8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d90:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104d97:	00 00 00 
80104d9a:	eb 01                	jmp    80104d9d <scheduler+0x9a>
        continue;
80104d9c:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d9d:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104da4:	81 7d f4 f4 85 11 80 	cmpl   $0x801185f4,-0xc(%ebp)
80104dab:	72 93                	jb     80104d40 <scheduler+0x3d>
    }
    release(&ptable.lock);
80104dad:	83 ec 0c             	sub    $0xc,%esp
80104db0:	68 c0 5d 11 80       	push   $0x80115dc0
80104db5:	e8 31 06 00 00       	call   801053eb <release>
80104dba:	83 c4 10             	add    $0x10,%esp
    sti();
80104dbd:	e9 60 ff ff ff       	jmp    80104d22 <scheduler+0x1f>

80104dc2 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104dc2:	f3 0f 1e fb          	endbr32 
80104dc6:	55                   	push   %ebp
80104dc7:	89 e5                	mov    %esp,%ebp
80104dc9:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104dcc:	e8 50 f7 ff ff       	call   80104521 <myproc>
80104dd1:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104dd4:	83 ec 0c             	sub    $0xc,%esp
80104dd7:	68 c0 5d 11 80       	push   $0x80115dc0
80104ddc:	e8 df 06 00 00       	call   801054c0 <holding>
80104de1:	83 c4 10             	add    $0x10,%esp
80104de4:	85 c0                	test   %eax,%eax
80104de6:	75 0d                	jne    80104df5 <sched+0x33>
    panic("sched ptable.lock");
80104de8:	83 ec 0c             	sub    $0xc,%esp
80104deb:	68 d7 98 10 80       	push   $0x801098d7
80104df0:	e8 13 b8 ff ff       	call   80100608 <panic>
  if(mycpu()->ncli != 1)
80104df5:	e8 ab f6 ff ff       	call   801044a5 <mycpu>
80104dfa:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104e00:	83 f8 01             	cmp    $0x1,%eax
80104e03:	74 0d                	je     80104e12 <sched+0x50>
    panic("sched locks");
80104e05:	83 ec 0c             	sub    $0xc,%esp
80104e08:	68 e9 98 10 80       	push   $0x801098e9
80104e0d:	e8 f6 b7 ff ff       	call   80100608 <panic>
  if(p->state == RUNNING)
80104e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e15:	8b 40 0c             	mov    0xc(%eax),%eax
80104e18:	83 f8 04             	cmp    $0x4,%eax
80104e1b:	75 0d                	jne    80104e2a <sched+0x68>
    panic("sched running");
80104e1d:	83 ec 0c             	sub    $0xc,%esp
80104e20:	68 f5 98 10 80       	push   $0x801098f5
80104e25:	e8 de b7 ff ff       	call   80100608 <panic>
  if(readeflags()&FL_IF)
80104e2a:	e8 1e f6 ff ff       	call   8010444d <readeflags>
80104e2f:	25 00 02 00 00       	and    $0x200,%eax
80104e34:	85 c0                	test   %eax,%eax
80104e36:	74 0d                	je     80104e45 <sched+0x83>
    panic("sched interruptible");
80104e38:	83 ec 0c             	sub    $0xc,%esp
80104e3b:	68 03 99 10 80       	push   $0x80109903
80104e40:	e8 c3 b7 ff ff       	call   80100608 <panic>
  intena = mycpu()->intena;
80104e45:	e8 5b f6 ff ff       	call   801044a5 <mycpu>
80104e4a:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104e50:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104e53:	e8 4d f6 ff ff       	call   801044a5 <mycpu>
80104e58:	8b 40 04             	mov    0x4(%eax),%eax
80104e5b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e5e:	83 c2 1c             	add    $0x1c,%edx
80104e61:	83 ec 08             	sub    $0x8,%esp
80104e64:	50                   	push   %eax
80104e65:	52                   	push   %edx
80104e66:	e8 41 0a 00 00       	call   801058ac <swtch>
80104e6b:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104e6e:	e8 32 f6 ff ff       	call   801044a5 <mycpu>
80104e73:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e76:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104e7c:	90                   	nop
80104e7d:	c9                   	leave  
80104e7e:	c3                   	ret    

80104e7f <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104e7f:	f3 0f 1e fb          	endbr32 
80104e83:	55                   	push   %ebp
80104e84:	89 e5                	mov    %esp,%ebp
80104e86:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104e89:	83 ec 0c             	sub    $0xc,%esp
80104e8c:	68 c0 5d 11 80       	push   $0x80115dc0
80104e91:	e8 e3 04 00 00       	call   80105379 <acquire>
80104e96:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104e99:	e8 83 f6 ff ff       	call   80104521 <myproc>
80104e9e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104ea5:	e8 18 ff ff ff       	call   80104dc2 <sched>
  release(&ptable.lock);
80104eaa:	83 ec 0c             	sub    $0xc,%esp
80104ead:	68 c0 5d 11 80       	push   $0x80115dc0
80104eb2:	e8 34 05 00 00       	call   801053eb <release>
80104eb7:	83 c4 10             	add    $0x10,%esp
}
80104eba:	90                   	nop
80104ebb:	c9                   	leave  
80104ebc:	c3                   	ret    

80104ebd <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104ebd:	f3 0f 1e fb          	endbr32 
80104ec1:	55                   	push   %ebp
80104ec2:	89 e5                	mov    %esp,%ebp
80104ec4:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104ec7:	83 ec 0c             	sub    $0xc,%esp
80104eca:	68 c0 5d 11 80       	push   $0x80115dc0
80104ecf:	e8 17 05 00 00       	call   801053eb <release>
80104ed4:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104ed7:	a1 04 d0 10 80       	mov    0x8010d004,%eax
80104edc:	85 c0                	test   %eax,%eax
80104ede:	74 24                	je     80104f04 <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104ee0:	c7 05 04 d0 10 80 00 	movl   $0x0,0x8010d004
80104ee7:	00 00 00 
    iinit(ROOTDEV);
80104eea:	83 ec 0c             	sub    $0xc,%esp
80104eed:	6a 01                	push   $0x1
80104eef:	e8 f3 c8 ff ff       	call   801017e7 <iinit>
80104ef4:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104ef7:	83 ec 0c             	sub    $0xc,%esp
80104efa:	6a 01                	push   $0x1
80104efc:	e8 2e e6 ff ff       	call   8010352f <initlog>
80104f01:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104f04:	90                   	nop
80104f05:	c9                   	leave  
80104f06:	c3                   	ret    

80104f07 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104f07:	f3 0f 1e fb          	endbr32 
80104f0b:	55                   	push   %ebp
80104f0c:	89 e5                	mov    %esp,%ebp
80104f0e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104f11:	e8 0b f6 ff ff       	call   80104521 <myproc>
80104f16:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104f19:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104f1d:	75 0d                	jne    80104f2c <sleep+0x25>
    panic("sleep");
80104f1f:	83 ec 0c             	sub    $0xc,%esp
80104f22:	68 17 99 10 80       	push   $0x80109917
80104f27:	e8 dc b6 ff ff       	call   80100608 <panic>

  if(lk == 0)
80104f2c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104f30:	75 0d                	jne    80104f3f <sleep+0x38>
    panic("sleep without lk");
80104f32:	83 ec 0c             	sub    $0xc,%esp
80104f35:	68 1d 99 10 80       	push   $0x8010991d
80104f3a:	e8 c9 b6 ff ff       	call   80100608 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104f3f:	81 7d 0c c0 5d 11 80 	cmpl   $0x80115dc0,0xc(%ebp)
80104f46:	74 1e                	je     80104f66 <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104f48:	83 ec 0c             	sub    $0xc,%esp
80104f4b:	68 c0 5d 11 80       	push   $0x80115dc0
80104f50:	e8 24 04 00 00       	call   80105379 <acquire>
80104f55:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104f58:	83 ec 0c             	sub    $0xc,%esp
80104f5b:	ff 75 0c             	pushl  0xc(%ebp)
80104f5e:	e8 88 04 00 00       	call   801053eb <release>
80104f63:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104f66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f69:	8b 55 08             	mov    0x8(%ebp),%edx
80104f6c:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104f6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f72:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104f79:	e8 44 fe ff ff       	call   80104dc2 <sched>

  // Tidy up.
  p->chan = 0;
80104f7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f81:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104f88:	81 7d 0c c0 5d 11 80 	cmpl   $0x80115dc0,0xc(%ebp)
80104f8f:	74 1e                	je     80104faf <sleep+0xa8>
    release(&ptable.lock);
80104f91:	83 ec 0c             	sub    $0xc,%esp
80104f94:	68 c0 5d 11 80       	push   $0x80115dc0
80104f99:	e8 4d 04 00 00       	call   801053eb <release>
80104f9e:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104fa1:	83 ec 0c             	sub    $0xc,%esp
80104fa4:	ff 75 0c             	pushl  0xc(%ebp)
80104fa7:	e8 cd 03 00 00       	call   80105379 <acquire>
80104fac:	83 c4 10             	add    $0x10,%esp
  }
}
80104faf:	90                   	nop
80104fb0:	c9                   	leave  
80104fb1:	c3                   	ret    

80104fb2 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104fb2:	f3 0f 1e fb          	endbr32 
80104fb6:	55                   	push   %ebp
80104fb7:	89 e5                	mov    %esp,%ebp
80104fb9:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104fbc:	c7 45 fc f4 5d 11 80 	movl   $0x80115df4,-0x4(%ebp)
80104fc3:	eb 27                	jmp    80104fec <wakeup1+0x3a>
    if(p->state == SLEEPING && p->chan == chan)
80104fc5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fc8:	8b 40 0c             	mov    0xc(%eax),%eax
80104fcb:	83 f8 02             	cmp    $0x2,%eax
80104fce:	75 15                	jne    80104fe5 <wakeup1+0x33>
80104fd0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fd3:	8b 40 20             	mov    0x20(%eax),%eax
80104fd6:	39 45 08             	cmp    %eax,0x8(%ebp)
80104fd9:	75 0a                	jne    80104fe5 <wakeup1+0x33>
      p->state = RUNNABLE;
80104fdb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fde:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104fe5:	81 45 fc a0 00 00 00 	addl   $0xa0,-0x4(%ebp)
80104fec:	81 7d fc f4 85 11 80 	cmpl   $0x801185f4,-0x4(%ebp)
80104ff3:	72 d0                	jb     80104fc5 <wakeup1+0x13>
}
80104ff5:	90                   	nop
80104ff6:	90                   	nop
80104ff7:	c9                   	leave  
80104ff8:	c3                   	ret    

80104ff9 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104ff9:	f3 0f 1e fb          	endbr32 
80104ffd:	55                   	push   %ebp
80104ffe:	89 e5                	mov    %esp,%ebp
80105000:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80105003:	83 ec 0c             	sub    $0xc,%esp
80105006:	68 c0 5d 11 80       	push   $0x80115dc0
8010500b:	e8 69 03 00 00       	call   80105379 <acquire>
80105010:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80105013:	83 ec 0c             	sub    $0xc,%esp
80105016:	ff 75 08             	pushl  0x8(%ebp)
80105019:	e8 94 ff ff ff       	call   80104fb2 <wakeup1>
8010501e:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80105021:	83 ec 0c             	sub    $0xc,%esp
80105024:	68 c0 5d 11 80       	push   $0x80115dc0
80105029:	e8 bd 03 00 00       	call   801053eb <release>
8010502e:	83 c4 10             	add    $0x10,%esp
}
80105031:	90                   	nop
80105032:	c9                   	leave  
80105033:	c3                   	ret    

80105034 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80105034:	f3 0f 1e fb          	endbr32 
80105038:	55                   	push   %ebp
80105039:	89 e5                	mov    %esp,%ebp
8010503b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
8010503e:	83 ec 0c             	sub    $0xc,%esp
80105041:	68 c0 5d 11 80       	push   $0x80115dc0
80105046:	e8 2e 03 00 00       	call   80105379 <acquire>
8010504b:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010504e:	c7 45 f4 f4 5d 11 80 	movl   $0x80115df4,-0xc(%ebp)
80105055:	eb 48                	jmp    8010509f <kill+0x6b>
    if(p->pid == pid){
80105057:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010505a:	8b 40 10             	mov    0x10(%eax),%eax
8010505d:	39 45 08             	cmp    %eax,0x8(%ebp)
80105060:	75 36                	jne    80105098 <kill+0x64>
      p->killed = 1;
80105062:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105065:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010506c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010506f:	8b 40 0c             	mov    0xc(%eax),%eax
80105072:	83 f8 02             	cmp    $0x2,%eax
80105075:	75 0a                	jne    80105081 <kill+0x4d>
        p->state = RUNNABLE;
80105077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010507a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80105081:	83 ec 0c             	sub    $0xc,%esp
80105084:	68 c0 5d 11 80       	push   $0x80115dc0
80105089:	e8 5d 03 00 00       	call   801053eb <release>
8010508e:	83 c4 10             	add    $0x10,%esp
      return 0;
80105091:	b8 00 00 00 00       	mov    $0x0,%eax
80105096:	eb 25                	jmp    801050bd <kill+0x89>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105098:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
8010509f:	81 7d f4 f4 85 11 80 	cmpl   $0x801185f4,-0xc(%ebp)
801050a6:	72 af                	jb     80105057 <kill+0x23>
    }
  }
  release(&ptable.lock);
801050a8:	83 ec 0c             	sub    $0xc,%esp
801050ab:	68 c0 5d 11 80       	push   $0x80115dc0
801050b0:	e8 36 03 00 00       	call   801053eb <release>
801050b5:	83 c4 10             	add    $0x10,%esp
  return -1;
801050b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801050bd:	c9                   	leave  
801050be:	c3                   	ret    

801050bf <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801050bf:	f3 0f 1e fb          	endbr32 
801050c3:	55                   	push   %ebp
801050c4:	89 e5                	mov    %esp,%ebp
801050c6:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050c9:	c7 45 f0 f4 5d 11 80 	movl   $0x80115df4,-0x10(%ebp)
801050d0:	e9 da 00 00 00       	jmp    801051af <procdump+0xf0>
    if(p->state == UNUSED)
801050d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050d8:	8b 40 0c             	mov    0xc(%eax),%eax
801050db:	85 c0                	test   %eax,%eax
801050dd:	0f 84 c4 00 00 00    	je     801051a7 <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801050e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050e6:	8b 40 0c             	mov    0xc(%eax),%eax
801050e9:	83 f8 05             	cmp    $0x5,%eax
801050ec:	77 23                	ja     80105111 <procdump+0x52>
801050ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050f1:	8b 40 0c             	mov    0xc(%eax),%eax
801050f4:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
801050fb:	85 c0                	test   %eax,%eax
801050fd:	74 12                	je     80105111 <procdump+0x52>
      state = states[p->state];
801050ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105102:	8b 40 0c             	mov    0xc(%eax),%eax
80105105:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
8010510c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010510f:	eb 07                	jmp    80105118 <procdump+0x59>
    else
      state = "???";
80105111:	c7 45 ec 2e 99 10 80 	movl   $0x8010992e,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80105118:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010511b:	8d 50 6c             	lea    0x6c(%eax),%edx
8010511e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105121:	8b 40 10             	mov    0x10(%eax),%eax
80105124:	52                   	push   %edx
80105125:	ff 75 ec             	pushl  -0x14(%ebp)
80105128:	50                   	push   %eax
80105129:	68 32 99 10 80       	push   $0x80109932
8010512e:	e8 e5 b2 ff ff       	call   80100418 <cprintf>
80105133:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80105136:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105139:	8b 40 0c             	mov    0xc(%eax),%eax
8010513c:	83 f8 02             	cmp    $0x2,%eax
8010513f:	75 54                	jne    80105195 <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105141:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105144:	8b 40 1c             	mov    0x1c(%eax),%eax
80105147:	8b 40 0c             	mov    0xc(%eax),%eax
8010514a:	83 c0 08             	add    $0x8,%eax
8010514d:	89 c2                	mov    %eax,%edx
8010514f:	83 ec 08             	sub    $0x8,%esp
80105152:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80105155:	50                   	push   %eax
80105156:	52                   	push   %edx
80105157:	e8 e5 02 00 00       	call   80105441 <getcallerpcs>
8010515c:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010515f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105166:	eb 1c                	jmp    80105184 <procdump+0xc5>
        cprintf(" %p", pc[i]);
80105168:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010516b:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010516f:	83 ec 08             	sub    $0x8,%esp
80105172:	50                   	push   %eax
80105173:	68 3b 99 10 80       	push   $0x8010993b
80105178:	e8 9b b2 ff ff       	call   80100418 <cprintf>
8010517d:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105180:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105184:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105188:	7f 0b                	jg     80105195 <procdump+0xd6>
8010518a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010518d:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105191:	85 c0                	test   %eax,%eax
80105193:	75 d3                	jne    80105168 <procdump+0xa9>
    }
    cprintf("\n");
80105195:	83 ec 0c             	sub    $0xc,%esp
80105198:	68 3f 99 10 80       	push   $0x8010993f
8010519d:	e8 76 b2 ff ff       	call   80100418 <cprintf>
801051a2:	83 c4 10             	add    $0x10,%esp
801051a5:	eb 01                	jmp    801051a8 <procdump+0xe9>
      continue;
801051a7:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051a8:	81 45 f0 a0 00 00 00 	addl   $0xa0,-0x10(%ebp)
801051af:	81 7d f0 f4 85 11 80 	cmpl   $0x801185f4,-0x10(%ebp)
801051b6:	0f 82 19 ff ff ff    	jb     801050d5 <procdump+0x16>
  }
801051bc:	90                   	nop
801051bd:	90                   	nop
801051be:	c9                   	leave  
801051bf:	c3                   	ret    

801051c0 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801051c0:	f3 0f 1e fb          	endbr32 
801051c4:	55                   	push   %ebp
801051c5:	89 e5                	mov    %esp,%ebp
801051c7:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
801051ca:	8b 45 08             	mov    0x8(%ebp),%eax
801051cd:	83 c0 04             	add    $0x4,%eax
801051d0:	83 ec 08             	sub    $0x8,%esp
801051d3:	68 6b 99 10 80       	push   $0x8010996b
801051d8:	50                   	push   %eax
801051d9:	e8 75 01 00 00       	call   80105353 <initlock>
801051de:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801051e1:	8b 45 08             	mov    0x8(%ebp),%eax
801051e4:	8b 55 0c             	mov    0xc(%ebp),%edx
801051e7:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801051ea:	8b 45 08             	mov    0x8(%ebp),%eax
801051ed:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801051f3:	8b 45 08             	mov    0x8(%ebp),%eax
801051f6:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801051fd:	90                   	nop
801051fe:	c9                   	leave  
801051ff:	c3                   	ret    

80105200 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80105200:	f3 0f 1e fb          	endbr32 
80105204:	55                   	push   %ebp
80105205:	89 e5                	mov    %esp,%ebp
80105207:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
8010520a:	8b 45 08             	mov    0x8(%ebp),%eax
8010520d:	83 c0 04             	add    $0x4,%eax
80105210:	83 ec 0c             	sub    $0xc,%esp
80105213:	50                   	push   %eax
80105214:	e8 60 01 00 00       	call   80105379 <acquire>
80105219:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
8010521c:	eb 15                	jmp    80105233 <acquiresleep+0x33>
    sleep(lk, &lk->lk);
8010521e:	8b 45 08             	mov    0x8(%ebp),%eax
80105221:	83 c0 04             	add    $0x4,%eax
80105224:	83 ec 08             	sub    $0x8,%esp
80105227:	50                   	push   %eax
80105228:	ff 75 08             	pushl  0x8(%ebp)
8010522b:	e8 d7 fc ff ff       	call   80104f07 <sleep>
80105230:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80105233:	8b 45 08             	mov    0x8(%ebp),%eax
80105236:	8b 00                	mov    (%eax),%eax
80105238:	85 c0                	test   %eax,%eax
8010523a:	75 e2                	jne    8010521e <acquiresleep+0x1e>
  }
  lk->locked = 1;
8010523c:	8b 45 08             	mov    0x8(%ebp),%eax
8010523f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80105245:	e8 d7 f2 ff ff       	call   80104521 <myproc>
8010524a:	8b 50 10             	mov    0x10(%eax),%edx
8010524d:	8b 45 08             	mov    0x8(%ebp),%eax
80105250:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80105253:	8b 45 08             	mov    0x8(%ebp),%eax
80105256:	83 c0 04             	add    $0x4,%eax
80105259:	83 ec 0c             	sub    $0xc,%esp
8010525c:	50                   	push   %eax
8010525d:	e8 89 01 00 00       	call   801053eb <release>
80105262:	83 c4 10             	add    $0x10,%esp
}
80105265:	90                   	nop
80105266:	c9                   	leave  
80105267:	c3                   	ret    

80105268 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80105268:	f3 0f 1e fb          	endbr32 
8010526c:	55                   	push   %ebp
8010526d:	89 e5                	mov    %esp,%ebp
8010526f:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80105272:	8b 45 08             	mov    0x8(%ebp),%eax
80105275:	83 c0 04             	add    $0x4,%eax
80105278:	83 ec 0c             	sub    $0xc,%esp
8010527b:	50                   	push   %eax
8010527c:	e8 f8 00 00 00       	call   80105379 <acquire>
80105281:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80105284:	8b 45 08             	mov    0x8(%ebp),%eax
80105287:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010528d:	8b 45 08             	mov    0x8(%ebp),%eax
80105290:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80105297:	83 ec 0c             	sub    $0xc,%esp
8010529a:	ff 75 08             	pushl  0x8(%ebp)
8010529d:	e8 57 fd ff ff       	call   80104ff9 <wakeup>
801052a2:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
801052a5:	8b 45 08             	mov    0x8(%ebp),%eax
801052a8:	83 c0 04             	add    $0x4,%eax
801052ab:	83 ec 0c             	sub    $0xc,%esp
801052ae:	50                   	push   %eax
801052af:	e8 37 01 00 00       	call   801053eb <release>
801052b4:	83 c4 10             	add    $0x10,%esp
}
801052b7:	90                   	nop
801052b8:	c9                   	leave  
801052b9:	c3                   	ret    

801052ba <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801052ba:	f3 0f 1e fb          	endbr32 
801052be:	55                   	push   %ebp
801052bf:	89 e5                	mov    %esp,%ebp
801052c1:	53                   	push   %ebx
801052c2:	83 ec 14             	sub    $0x14,%esp
  int r;
  
  acquire(&lk->lk);
801052c5:	8b 45 08             	mov    0x8(%ebp),%eax
801052c8:	83 c0 04             	add    $0x4,%eax
801052cb:	83 ec 0c             	sub    $0xc,%esp
801052ce:	50                   	push   %eax
801052cf:	e8 a5 00 00 00       	call   80105379 <acquire>
801052d4:	83 c4 10             	add    $0x10,%esp
  r = lk->locked && (lk->pid == myproc()->pid);
801052d7:	8b 45 08             	mov    0x8(%ebp),%eax
801052da:	8b 00                	mov    (%eax),%eax
801052dc:	85 c0                	test   %eax,%eax
801052de:	74 19                	je     801052f9 <holdingsleep+0x3f>
801052e0:	8b 45 08             	mov    0x8(%ebp),%eax
801052e3:	8b 58 3c             	mov    0x3c(%eax),%ebx
801052e6:	e8 36 f2 ff ff       	call   80104521 <myproc>
801052eb:	8b 40 10             	mov    0x10(%eax),%eax
801052ee:	39 c3                	cmp    %eax,%ebx
801052f0:	75 07                	jne    801052f9 <holdingsleep+0x3f>
801052f2:	b8 01 00 00 00       	mov    $0x1,%eax
801052f7:	eb 05                	jmp    801052fe <holdingsleep+0x44>
801052f9:	b8 00 00 00 00       	mov    $0x0,%eax
801052fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80105301:	8b 45 08             	mov    0x8(%ebp),%eax
80105304:	83 c0 04             	add    $0x4,%eax
80105307:	83 ec 0c             	sub    $0xc,%esp
8010530a:	50                   	push   %eax
8010530b:	e8 db 00 00 00       	call   801053eb <release>
80105310:	83 c4 10             	add    $0x10,%esp
  return r;
80105313:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105316:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105319:	c9                   	leave  
8010531a:	c3                   	ret    

8010531b <readeflags>:
{
8010531b:	55                   	push   %ebp
8010531c:	89 e5                	mov    %esp,%ebp
8010531e:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105321:	9c                   	pushf  
80105322:	58                   	pop    %eax
80105323:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105326:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105329:	c9                   	leave  
8010532a:	c3                   	ret    

8010532b <cli>:
{
8010532b:	55                   	push   %ebp
8010532c:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010532e:	fa                   	cli    
}
8010532f:	90                   	nop
80105330:	5d                   	pop    %ebp
80105331:	c3                   	ret    

80105332 <sti>:
{
80105332:	55                   	push   %ebp
80105333:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105335:	fb                   	sti    
}
80105336:	90                   	nop
80105337:	5d                   	pop    %ebp
80105338:	c3                   	ret    

80105339 <xchg>:
{
80105339:	55                   	push   %ebp
8010533a:	89 e5                	mov    %esp,%ebp
8010533c:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
8010533f:	8b 55 08             	mov    0x8(%ebp),%edx
80105342:	8b 45 0c             	mov    0xc(%ebp),%eax
80105345:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105348:	f0 87 02             	lock xchg %eax,(%edx)
8010534b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
8010534e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105351:	c9                   	leave  
80105352:	c3                   	ret    

80105353 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105353:	f3 0f 1e fb          	endbr32 
80105357:	55                   	push   %ebp
80105358:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010535a:	8b 45 08             	mov    0x8(%ebp),%eax
8010535d:	8b 55 0c             	mov    0xc(%ebp),%edx
80105360:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105363:	8b 45 08             	mov    0x8(%ebp),%eax
80105366:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010536c:	8b 45 08             	mov    0x8(%ebp),%eax
8010536f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105376:	90                   	nop
80105377:	5d                   	pop    %ebp
80105378:	c3                   	ret    

80105379 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105379:	f3 0f 1e fb          	endbr32 
8010537d:	55                   	push   %ebp
8010537e:	89 e5                	mov    %esp,%ebp
80105380:	53                   	push   %ebx
80105381:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105384:	e8 7c 01 00 00       	call   80105505 <pushcli>
  if(holding(lk))
80105389:	8b 45 08             	mov    0x8(%ebp),%eax
8010538c:	83 ec 0c             	sub    $0xc,%esp
8010538f:	50                   	push   %eax
80105390:	e8 2b 01 00 00       	call   801054c0 <holding>
80105395:	83 c4 10             	add    $0x10,%esp
80105398:	85 c0                	test   %eax,%eax
8010539a:	74 0d                	je     801053a9 <acquire+0x30>
    panic("acquire");
8010539c:	83 ec 0c             	sub    $0xc,%esp
8010539f:	68 76 99 10 80       	push   $0x80109976
801053a4:	e8 5f b2 ff ff       	call   80100608 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
801053a9:	90                   	nop
801053aa:	8b 45 08             	mov    0x8(%ebp),%eax
801053ad:	83 ec 08             	sub    $0x8,%esp
801053b0:	6a 01                	push   $0x1
801053b2:	50                   	push   %eax
801053b3:	e8 81 ff ff ff       	call   80105339 <xchg>
801053b8:	83 c4 10             	add    $0x10,%esp
801053bb:	85 c0                	test   %eax,%eax
801053bd:	75 eb                	jne    801053aa <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
801053bf:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
801053c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
801053c7:	e8 d9 f0 ff ff       	call   801044a5 <mycpu>
801053cc:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801053cf:	8b 45 08             	mov    0x8(%ebp),%eax
801053d2:	83 c0 0c             	add    $0xc,%eax
801053d5:	83 ec 08             	sub    $0x8,%esp
801053d8:	50                   	push   %eax
801053d9:	8d 45 08             	lea    0x8(%ebp),%eax
801053dc:	50                   	push   %eax
801053dd:	e8 5f 00 00 00       	call   80105441 <getcallerpcs>
801053e2:	83 c4 10             	add    $0x10,%esp
}
801053e5:	90                   	nop
801053e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801053e9:	c9                   	leave  
801053ea:	c3                   	ret    

801053eb <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801053eb:	f3 0f 1e fb          	endbr32 
801053ef:	55                   	push   %ebp
801053f0:	89 e5                	mov    %esp,%ebp
801053f2:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801053f5:	83 ec 0c             	sub    $0xc,%esp
801053f8:	ff 75 08             	pushl  0x8(%ebp)
801053fb:	e8 c0 00 00 00       	call   801054c0 <holding>
80105400:	83 c4 10             	add    $0x10,%esp
80105403:	85 c0                	test   %eax,%eax
80105405:	75 0d                	jne    80105414 <release+0x29>
    panic("release");
80105407:	83 ec 0c             	sub    $0xc,%esp
8010540a:	68 7e 99 10 80       	push   $0x8010997e
8010540f:	e8 f4 b1 ff ff       	call   80100608 <panic>

  lk->pcs[0] = 0;
80105414:	8b 45 08             	mov    0x8(%ebp),%eax
80105417:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010541e:	8b 45 08             	mov    0x8(%ebp),%eax
80105421:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80105428:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
8010542d:	8b 45 08             	mov    0x8(%ebp),%eax
80105430:	8b 55 08             	mov    0x8(%ebp),%edx
80105433:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80105439:	e8 18 01 00 00       	call   80105556 <popcli>
}
8010543e:	90                   	nop
8010543f:	c9                   	leave  
80105440:	c3                   	ret    

80105441 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105441:	f3 0f 1e fb          	endbr32 
80105445:	55                   	push   %ebp
80105446:	89 e5                	mov    %esp,%ebp
80105448:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
8010544b:	8b 45 08             	mov    0x8(%ebp),%eax
8010544e:	83 e8 08             	sub    $0x8,%eax
80105451:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105454:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010545b:	eb 38                	jmp    80105495 <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
8010545d:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105461:	74 53                	je     801054b6 <getcallerpcs+0x75>
80105463:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
8010546a:	76 4a                	jbe    801054b6 <getcallerpcs+0x75>
8010546c:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105470:	74 44                	je     801054b6 <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105472:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105475:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010547c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010547f:	01 c2                	add    %eax,%edx
80105481:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105484:	8b 40 04             	mov    0x4(%eax),%eax
80105487:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105489:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010548c:	8b 00                	mov    (%eax),%eax
8010548e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105491:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105495:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105499:	7e c2                	jle    8010545d <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
8010549b:	eb 19                	jmp    801054b6 <getcallerpcs+0x75>
    pcs[i] = 0;
8010549d:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054a0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801054a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801054aa:	01 d0                	add    %edx,%eax
801054ac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
801054b2:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801054b6:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801054ba:	7e e1                	jle    8010549d <getcallerpcs+0x5c>
}
801054bc:	90                   	nop
801054bd:	90                   	nop
801054be:	c9                   	leave  
801054bf:	c3                   	ret    

801054c0 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801054c0:	f3 0f 1e fb          	endbr32 
801054c4:	55                   	push   %ebp
801054c5:	89 e5                	mov    %esp,%ebp
801054c7:	53                   	push   %ebx
801054c8:	83 ec 14             	sub    $0x14,%esp
  int r;
  pushcli();
801054cb:	e8 35 00 00 00       	call   80105505 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
801054d0:	8b 45 08             	mov    0x8(%ebp),%eax
801054d3:	8b 00                	mov    (%eax),%eax
801054d5:	85 c0                	test   %eax,%eax
801054d7:	74 16                	je     801054ef <holding+0x2f>
801054d9:	8b 45 08             	mov    0x8(%ebp),%eax
801054dc:	8b 58 08             	mov    0x8(%eax),%ebx
801054df:	e8 c1 ef ff ff       	call   801044a5 <mycpu>
801054e4:	39 c3                	cmp    %eax,%ebx
801054e6:	75 07                	jne    801054ef <holding+0x2f>
801054e8:	b8 01 00 00 00       	mov    $0x1,%eax
801054ed:	eb 05                	jmp    801054f4 <holding+0x34>
801054ef:	b8 00 00 00 00       	mov    $0x0,%eax
801054f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();
801054f7:	e8 5a 00 00 00       	call   80105556 <popcli>
  return r;
801054fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801054ff:	83 c4 14             	add    $0x14,%esp
80105502:	5b                   	pop    %ebx
80105503:	5d                   	pop    %ebp
80105504:	c3                   	ret    

80105505 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105505:	f3 0f 1e fb          	endbr32 
80105509:	55                   	push   %ebp
8010550a:	89 e5                	mov    %esp,%ebp
8010550c:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
8010550f:	e8 07 fe ff ff       	call   8010531b <readeflags>
80105514:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80105517:	e8 0f fe ff ff       	call   8010532b <cli>
  if(mycpu()->ncli == 0)
8010551c:	e8 84 ef ff ff       	call   801044a5 <mycpu>
80105521:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105527:	85 c0                	test   %eax,%eax
80105529:	75 14                	jne    8010553f <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
8010552b:	e8 75 ef ff ff       	call   801044a5 <mycpu>
80105530:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105533:	81 e2 00 02 00 00    	and    $0x200,%edx
80105539:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
8010553f:	e8 61 ef ff ff       	call   801044a5 <mycpu>
80105544:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010554a:	83 c2 01             	add    $0x1,%edx
8010554d:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80105553:	90                   	nop
80105554:	c9                   	leave  
80105555:	c3                   	ret    

80105556 <popcli>:

void
popcli(void)
{
80105556:	f3 0f 1e fb          	endbr32 
8010555a:	55                   	push   %ebp
8010555b:	89 e5                	mov    %esp,%ebp
8010555d:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105560:	e8 b6 fd ff ff       	call   8010531b <readeflags>
80105565:	25 00 02 00 00       	and    $0x200,%eax
8010556a:	85 c0                	test   %eax,%eax
8010556c:	74 0d                	je     8010557b <popcli+0x25>
    panic("popcli - interruptible");
8010556e:	83 ec 0c             	sub    $0xc,%esp
80105571:	68 86 99 10 80       	push   $0x80109986
80105576:	e8 8d b0 ff ff       	call   80100608 <panic>
  if(--mycpu()->ncli < 0)
8010557b:	e8 25 ef ff ff       	call   801044a5 <mycpu>
80105580:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105586:	83 ea 01             	sub    $0x1,%edx
80105589:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
8010558f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105595:	85 c0                	test   %eax,%eax
80105597:	79 0d                	jns    801055a6 <popcli+0x50>
    panic("popcli");
80105599:	83 ec 0c             	sub    $0xc,%esp
8010559c:	68 9d 99 10 80       	push   $0x8010999d
801055a1:	e8 62 b0 ff ff       	call   80100608 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
801055a6:	e8 fa ee ff ff       	call   801044a5 <mycpu>
801055ab:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801055b1:	85 c0                	test   %eax,%eax
801055b3:	75 14                	jne    801055c9 <popcli+0x73>
801055b5:	e8 eb ee ff ff       	call   801044a5 <mycpu>
801055ba:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801055c0:	85 c0                	test   %eax,%eax
801055c2:	74 05                	je     801055c9 <popcli+0x73>
    sti();
801055c4:	e8 69 fd ff ff       	call   80105332 <sti>
}
801055c9:	90                   	nop
801055ca:	c9                   	leave  
801055cb:	c3                   	ret    

801055cc <stosb>:
{
801055cc:	55                   	push   %ebp
801055cd:	89 e5                	mov    %esp,%ebp
801055cf:	57                   	push   %edi
801055d0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801055d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
801055d4:	8b 55 10             	mov    0x10(%ebp),%edx
801055d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801055da:	89 cb                	mov    %ecx,%ebx
801055dc:	89 df                	mov    %ebx,%edi
801055de:	89 d1                	mov    %edx,%ecx
801055e0:	fc                   	cld    
801055e1:	f3 aa                	rep stos %al,%es:(%edi)
801055e3:	89 ca                	mov    %ecx,%edx
801055e5:	89 fb                	mov    %edi,%ebx
801055e7:	89 5d 08             	mov    %ebx,0x8(%ebp)
801055ea:	89 55 10             	mov    %edx,0x10(%ebp)
}
801055ed:	90                   	nop
801055ee:	5b                   	pop    %ebx
801055ef:	5f                   	pop    %edi
801055f0:	5d                   	pop    %ebp
801055f1:	c3                   	ret    

801055f2 <stosl>:
{
801055f2:	55                   	push   %ebp
801055f3:	89 e5                	mov    %esp,%ebp
801055f5:	57                   	push   %edi
801055f6:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801055f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
801055fa:	8b 55 10             	mov    0x10(%ebp),%edx
801055fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80105600:	89 cb                	mov    %ecx,%ebx
80105602:	89 df                	mov    %ebx,%edi
80105604:	89 d1                	mov    %edx,%ecx
80105606:	fc                   	cld    
80105607:	f3 ab                	rep stos %eax,%es:(%edi)
80105609:	89 ca                	mov    %ecx,%edx
8010560b:	89 fb                	mov    %edi,%ebx
8010560d:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105610:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105613:	90                   	nop
80105614:	5b                   	pop    %ebx
80105615:	5f                   	pop    %edi
80105616:	5d                   	pop    %ebp
80105617:	c3                   	ret    

80105618 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105618:	f3 0f 1e fb          	endbr32 
8010561c:	55                   	push   %ebp
8010561d:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
8010561f:	8b 45 08             	mov    0x8(%ebp),%eax
80105622:	83 e0 03             	and    $0x3,%eax
80105625:	85 c0                	test   %eax,%eax
80105627:	75 43                	jne    8010566c <memset+0x54>
80105629:	8b 45 10             	mov    0x10(%ebp),%eax
8010562c:	83 e0 03             	and    $0x3,%eax
8010562f:	85 c0                	test   %eax,%eax
80105631:	75 39                	jne    8010566c <memset+0x54>
    c &= 0xFF;
80105633:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010563a:	8b 45 10             	mov    0x10(%ebp),%eax
8010563d:	c1 e8 02             	shr    $0x2,%eax
80105640:	89 c1                	mov    %eax,%ecx
80105642:	8b 45 0c             	mov    0xc(%ebp),%eax
80105645:	c1 e0 18             	shl    $0x18,%eax
80105648:	89 c2                	mov    %eax,%edx
8010564a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010564d:	c1 e0 10             	shl    $0x10,%eax
80105650:	09 c2                	or     %eax,%edx
80105652:	8b 45 0c             	mov    0xc(%ebp),%eax
80105655:	c1 e0 08             	shl    $0x8,%eax
80105658:	09 d0                	or     %edx,%eax
8010565a:	0b 45 0c             	or     0xc(%ebp),%eax
8010565d:	51                   	push   %ecx
8010565e:	50                   	push   %eax
8010565f:	ff 75 08             	pushl  0x8(%ebp)
80105662:	e8 8b ff ff ff       	call   801055f2 <stosl>
80105667:	83 c4 0c             	add    $0xc,%esp
8010566a:	eb 12                	jmp    8010567e <memset+0x66>
  } else
    stosb(dst, c, n);
8010566c:	8b 45 10             	mov    0x10(%ebp),%eax
8010566f:	50                   	push   %eax
80105670:	ff 75 0c             	pushl  0xc(%ebp)
80105673:	ff 75 08             	pushl  0x8(%ebp)
80105676:	e8 51 ff ff ff       	call   801055cc <stosb>
8010567b:	83 c4 0c             	add    $0xc,%esp
  return dst;
8010567e:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105681:	c9                   	leave  
80105682:	c3                   	ret    

80105683 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105683:	f3 0f 1e fb          	endbr32 
80105687:	55                   	push   %ebp
80105688:	89 e5                	mov    %esp,%ebp
8010568a:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
8010568d:	8b 45 08             	mov    0x8(%ebp),%eax
80105690:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105693:	8b 45 0c             	mov    0xc(%ebp),%eax
80105696:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105699:	eb 30                	jmp    801056cb <memcmp+0x48>
    if(*s1 != *s2)
8010569b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010569e:	0f b6 10             	movzbl (%eax),%edx
801056a1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801056a4:	0f b6 00             	movzbl (%eax),%eax
801056a7:	38 c2                	cmp    %al,%dl
801056a9:	74 18                	je     801056c3 <memcmp+0x40>
      return *s1 - *s2;
801056ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056ae:	0f b6 00             	movzbl (%eax),%eax
801056b1:	0f b6 d0             	movzbl %al,%edx
801056b4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801056b7:	0f b6 00             	movzbl (%eax),%eax
801056ba:	0f b6 c0             	movzbl %al,%eax
801056bd:	29 c2                	sub    %eax,%edx
801056bf:	89 d0                	mov    %edx,%eax
801056c1:	eb 1a                	jmp    801056dd <memcmp+0x5a>
    s1++, s2++;
801056c3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801056c7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
801056cb:	8b 45 10             	mov    0x10(%ebp),%eax
801056ce:	8d 50 ff             	lea    -0x1(%eax),%edx
801056d1:	89 55 10             	mov    %edx,0x10(%ebp)
801056d4:	85 c0                	test   %eax,%eax
801056d6:	75 c3                	jne    8010569b <memcmp+0x18>
  }

  return 0;
801056d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056dd:	c9                   	leave  
801056de:	c3                   	ret    

801056df <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801056df:	f3 0f 1e fb          	endbr32 
801056e3:	55                   	push   %ebp
801056e4:	89 e5                	mov    %esp,%ebp
801056e6:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801056e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801056ec:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801056ef:	8b 45 08             	mov    0x8(%ebp),%eax
801056f2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801056f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056f8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801056fb:	73 54                	jae    80105751 <memmove+0x72>
801056fd:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105700:	8b 45 10             	mov    0x10(%ebp),%eax
80105703:	01 d0                	add    %edx,%eax
80105705:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80105708:	73 47                	jae    80105751 <memmove+0x72>
    s += n;
8010570a:	8b 45 10             	mov    0x10(%ebp),%eax
8010570d:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105710:	8b 45 10             	mov    0x10(%ebp),%eax
80105713:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105716:	eb 13                	jmp    8010572b <memmove+0x4c>
      *--d = *--s;
80105718:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010571c:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105720:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105723:	0f b6 10             	movzbl (%eax),%edx
80105726:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105729:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
8010572b:	8b 45 10             	mov    0x10(%ebp),%eax
8010572e:	8d 50 ff             	lea    -0x1(%eax),%edx
80105731:	89 55 10             	mov    %edx,0x10(%ebp)
80105734:	85 c0                	test   %eax,%eax
80105736:	75 e0                	jne    80105718 <memmove+0x39>
  if(s < d && s + n > d){
80105738:	eb 24                	jmp    8010575e <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
8010573a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010573d:	8d 42 01             	lea    0x1(%edx),%eax
80105740:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105743:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105746:	8d 48 01             	lea    0x1(%eax),%ecx
80105749:	89 4d f8             	mov    %ecx,-0x8(%ebp)
8010574c:	0f b6 12             	movzbl (%edx),%edx
8010574f:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105751:	8b 45 10             	mov    0x10(%ebp),%eax
80105754:	8d 50 ff             	lea    -0x1(%eax),%edx
80105757:	89 55 10             	mov    %edx,0x10(%ebp)
8010575a:	85 c0                	test   %eax,%eax
8010575c:	75 dc                	jne    8010573a <memmove+0x5b>

  return dst;
8010575e:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105761:	c9                   	leave  
80105762:	c3                   	ret    

80105763 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105763:	f3 0f 1e fb          	endbr32 
80105767:	55                   	push   %ebp
80105768:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
8010576a:	ff 75 10             	pushl  0x10(%ebp)
8010576d:	ff 75 0c             	pushl  0xc(%ebp)
80105770:	ff 75 08             	pushl  0x8(%ebp)
80105773:	e8 67 ff ff ff       	call   801056df <memmove>
80105778:	83 c4 0c             	add    $0xc,%esp
}
8010577b:	c9                   	leave  
8010577c:	c3                   	ret    

8010577d <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010577d:	f3 0f 1e fb          	endbr32 
80105781:	55                   	push   %ebp
80105782:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105784:	eb 0c                	jmp    80105792 <strncmp+0x15>
    n--, p++, q++;
80105786:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010578a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010578e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80105792:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105796:	74 1a                	je     801057b2 <strncmp+0x35>
80105798:	8b 45 08             	mov    0x8(%ebp),%eax
8010579b:	0f b6 00             	movzbl (%eax),%eax
8010579e:	84 c0                	test   %al,%al
801057a0:	74 10                	je     801057b2 <strncmp+0x35>
801057a2:	8b 45 08             	mov    0x8(%ebp),%eax
801057a5:	0f b6 10             	movzbl (%eax),%edx
801057a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801057ab:	0f b6 00             	movzbl (%eax),%eax
801057ae:	38 c2                	cmp    %al,%dl
801057b0:	74 d4                	je     80105786 <strncmp+0x9>
  if(n == 0)
801057b2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057b6:	75 07                	jne    801057bf <strncmp+0x42>
    return 0;
801057b8:	b8 00 00 00 00       	mov    $0x0,%eax
801057bd:	eb 16                	jmp    801057d5 <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
801057bf:	8b 45 08             	mov    0x8(%ebp),%eax
801057c2:	0f b6 00             	movzbl (%eax),%eax
801057c5:	0f b6 d0             	movzbl %al,%edx
801057c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801057cb:	0f b6 00             	movzbl (%eax),%eax
801057ce:	0f b6 c0             	movzbl %al,%eax
801057d1:	29 c2                	sub    %eax,%edx
801057d3:	89 d0                	mov    %edx,%eax
}
801057d5:	5d                   	pop    %ebp
801057d6:	c3                   	ret    

801057d7 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801057d7:	f3 0f 1e fb          	endbr32 
801057db:	55                   	push   %ebp
801057dc:	89 e5                	mov    %esp,%ebp
801057de:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801057e1:	8b 45 08             	mov    0x8(%ebp),%eax
801057e4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801057e7:	90                   	nop
801057e8:	8b 45 10             	mov    0x10(%ebp),%eax
801057eb:	8d 50 ff             	lea    -0x1(%eax),%edx
801057ee:	89 55 10             	mov    %edx,0x10(%ebp)
801057f1:	85 c0                	test   %eax,%eax
801057f3:	7e 2c                	jle    80105821 <strncpy+0x4a>
801057f5:	8b 55 0c             	mov    0xc(%ebp),%edx
801057f8:	8d 42 01             	lea    0x1(%edx),%eax
801057fb:	89 45 0c             	mov    %eax,0xc(%ebp)
801057fe:	8b 45 08             	mov    0x8(%ebp),%eax
80105801:	8d 48 01             	lea    0x1(%eax),%ecx
80105804:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105807:	0f b6 12             	movzbl (%edx),%edx
8010580a:	88 10                	mov    %dl,(%eax)
8010580c:	0f b6 00             	movzbl (%eax),%eax
8010580f:	84 c0                	test   %al,%al
80105811:	75 d5                	jne    801057e8 <strncpy+0x11>
    ;
  while(n-- > 0)
80105813:	eb 0c                	jmp    80105821 <strncpy+0x4a>
    *s++ = 0;
80105815:	8b 45 08             	mov    0x8(%ebp),%eax
80105818:	8d 50 01             	lea    0x1(%eax),%edx
8010581b:	89 55 08             	mov    %edx,0x8(%ebp)
8010581e:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80105821:	8b 45 10             	mov    0x10(%ebp),%eax
80105824:	8d 50 ff             	lea    -0x1(%eax),%edx
80105827:	89 55 10             	mov    %edx,0x10(%ebp)
8010582a:	85 c0                	test   %eax,%eax
8010582c:	7f e7                	jg     80105815 <strncpy+0x3e>
  return os;
8010582e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105831:	c9                   	leave  
80105832:	c3                   	ret    

80105833 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105833:	f3 0f 1e fb          	endbr32 
80105837:	55                   	push   %ebp
80105838:	89 e5                	mov    %esp,%ebp
8010583a:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010583d:	8b 45 08             	mov    0x8(%ebp),%eax
80105840:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105843:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105847:	7f 05                	jg     8010584e <safestrcpy+0x1b>
    return os;
80105849:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010584c:	eb 31                	jmp    8010587f <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
8010584e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105852:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105856:	7e 1e                	jle    80105876 <safestrcpy+0x43>
80105858:	8b 55 0c             	mov    0xc(%ebp),%edx
8010585b:	8d 42 01             	lea    0x1(%edx),%eax
8010585e:	89 45 0c             	mov    %eax,0xc(%ebp)
80105861:	8b 45 08             	mov    0x8(%ebp),%eax
80105864:	8d 48 01             	lea    0x1(%eax),%ecx
80105867:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010586a:	0f b6 12             	movzbl (%edx),%edx
8010586d:	88 10                	mov    %dl,(%eax)
8010586f:	0f b6 00             	movzbl (%eax),%eax
80105872:	84 c0                	test   %al,%al
80105874:	75 d8                	jne    8010584e <safestrcpy+0x1b>
    ;
  *s = 0;
80105876:	8b 45 08             	mov    0x8(%ebp),%eax
80105879:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010587c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010587f:	c9                   	leave  
80105880:	c3                   	ret    

80105881 <strlen>:

int
strlen(const char *s)
{
80105881:	f3 0f 1e fb          	endbr32 
80105885:	55                   	push   %ebp
80105886:	89 e5                	mov    %esp,%ebp
80105888:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010588b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105892:	eb 04                	jmp    80105898 <strlen+0x17>
80105894:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105898:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010589b:	8b 45 08             	mov    0x8(%ebp),%eax
8010589e:	01 d0                	add    %edx,%eax
801058a0:	0f b6 00             	movzbl (%eax),%eax
801058a3:	84 c0                	test   %al,%al
801058a5:	75 ed                	jne    80105894 <strlen+0x13>
    ;
  return n;
801058a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801058aa:	c9                   	leave  
801058ab:	c3                   	ret    

801058ac <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801058ac:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801058b0:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
801058b4:	55                   	push   %ebp
  pushl %ebx
801058b5:	53                   	push   %ebx
  pushl %esi
801058b6:	56                   	push   %esi
  pushl %edi
801058b7:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801058b8:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801058ba:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
801058bc:	5f                   	pop    %edi
  popl %esi
801058bd:	5e                   	pop    %esi
  popl %ebx
801058be:	5b                   	pop    %ebx
  popl %ebp
801058bf:	5d                   	pop    %ebp
  ret
801058c0:	c3                   	ret    

801058c1 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801058c1:	f3 0f 1e fb          	endbr32 
801058c5:	55                   	push   %ebp
801058c6:	89 e5                	mov    %esp,%ebp
801058c8:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801058cb:	e8 51 ec ff ff       	call   80104521 <myproc>
801058d0:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801058d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058d6:	8b 00                	mov    (%eax),%eax
801058d8:	39 45 08             	cmp    %eax,0x8(%ebp)
801058db:	73 0f                	jae    801058ec <fetchint+0x2b>
801058dd:	8b 45 08             	mov    0x8(%ebp),%eax
801058e0:	8d 50 04             	lea    0x4(%eax),%edx
801058e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058e6:	8b 00                	mov    (%eax),%eax
801058e8:	39 c2                	cmp    %eax,%edx
801058ea:	76 07                	jbe    801058f3 <fetchint+0x32>
    return -1;
801058ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058f1:	eb 0f                	jmp    80105902 <fetchint+0x41>
  *ip = *(int*)(addr);
801058f3:	8b 45 08             	mov    0x8(%ebp),%eax
801058f6:	8b 10                	mov    (%eax),%edx
801058f8:	8b 45 0c             	mov    0xc(%ebp),%eax
801058fb:	89 10                	mov    %edx,(%eax)
  return 0;
801058fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105902:	c9                   	leave  
80105903:	c3                   	ret    

80105904 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105904:	f3 0f 1e fb          	endbr32 
80105908:	55                   	push   %ebp
80105909:	89 e5                	mov    %esp,%ebp
8010590b:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
8010590e:	e8 0e ec ff ff       	call   80104521 <myproc>
80105913:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105916:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105919:	8b 00                	mov    (%eax),%eax
8010591b:	39 45 08             	cmp    %eax,0x8(%ebp)
8010591e:	72 07                	jb     80105927 <fetchstr+0x23>
    return -1;
80105920:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105925:	eb 43                	jmp    8010596a <fetchstr+0x66>
  *pp = (char*)addr;
80105927:	8b 55 08             	mov    0x8(%ebp),%edx
8010592a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010592d:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
8010592f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105932:	8b 00                	mov    (%eax),%eax
80105934:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105937:	8b 45 0c             	mov    0xc(%ebp),%eax
8010593a:	8b 00                	mov    (%eax),%eax
8010593c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010593f:	eb 1c                	jmp    8010595d <fetchstr+0x59>
    if(*s == 0)
80105941:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105944:	0f b6 00             	movzbl (%eax),%eax
80105947:	84 c0                	test   %al,%al
80105949:	75 0e                	jne    80105959 <fetchstr+0x55>
      return s - *pp;
8010594b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010594e:	8b 00                	mov    (%eax),%eax
80105950:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105953:	29 c2                	sub    %eax,%edx
80105955:	89 d0                	mov    %edx,%eax
80105957:	eb 11                	jmp    8010596a <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
80105959:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010595d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105960:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105963:	72 dc                	jb     80105941 <fetchstr+0x3d>
  }
  return -1;
80105965:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010596a:	c9                   	leave  
8010596b:	c3                   	ret    

8010596c <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010596c:	f3 0f 1e fb          	endbr32 
80105970:	55                   	push   %ebp
80105971:	89 e5                	mov    %esp,%ebp
80105973:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105976:	e8 a6 eb ff ff       	call   80104521 <myproc>
8010597b:	8b 40 18             	mov    0x18(%eax),%eax
8010597e:	8b 40 44             	mov    0x44(%eax),%eax
80105981:	8b 55 08             	mov    0x8(%ebp),%edx
80105984:	c1 e2 02             	shl    $0x2,%edx
80105987:	01 d0                	add    %edx,%eax
80105989:	83 c0 04             	add    $0x4,%eax
8010598c:	83 ec 08             	sub    $0x8,%esp
8010598f:	ff 75 0c             	pushl  0xc(%ebp)
80105992:	50                   	push   %eax
80105993:	e8 29 ff ff ff       	call   801058c1 <fetchint>
80105998:	83 c4 10             	add    $0x10,%esp
}
8010599b:	c9                   	leave  
8010599c:	c3                   	ret    

8010599d <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010599d:	f3 0f 1e fb          	endbr32 
801059a1:	55                   	push   %ebp
801059a2:	89 e5                	mov    %esp,%ebp
801059a4:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
801059a7:	e8 75 eb ff ff       	call   80104521 <myproc>
801059ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
801059af:	83 ec 08             	sub    $0x8,%esp
801059b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059b5:	50                   	push   %eax
801059b6:	ff 75 08             	pushl  0x8(%ebp)
801059b9:	e8 ae ff ff ff       	call   8010596c <argint>
801059be:	83 c4 10             	add    $0x10,%esp
801059c1:	85 c0                	test   %eax,%eax
801059c3:	79 07                	jns    801059cc <argptr+0x2f>
    return -1;
801059c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059ca:	eb 3b                	jmp    80105a07 <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801059cc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801059d0:	78 1f                	js     801059f1 <argptr+0x54>
801059d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d5:	8b 00                	mov    (%eax),%eax
801059d7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059da:	39 d0                	cmp    %edx,%eax
801059dc:	76 13                	jbe    801059f1 <argptr+0x54>
801059de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059e1:	89 c2                	mov    %eax,%edx
801059e3:	8b 45 10             	mov    0x10(%ebp),%eax
801059e6:	01 c2                	add    %eax,%edx
801059e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059eb:	8b 00                	mov    (%eax),%eax
801059ed:	39 c2                	cmp    %eax,%edx
801059ef:	76 07                	jbe    801059f8 <argptr+0x5b>
    return -1;
801059f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059f6:	eb 0f                	jmp    80105a07 <argptr+0x6a>
  *pp = (char*)i;
801059f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059fb:	89 c2                	mov    %eax,%edx
801059fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a00:	89 10                	mov    %edx,(%eax)
  return 0;
80105a02:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a07:	c9                   	leave  
80105a08:	c3                   	ret    

80105a09 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105a09:	f3 0f 1e fb          	endbr32 
80105a0d:	55                   	push   %ebp
80105a0e:	89 e5                	mov    %esp,%ebp
80105a10:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105a13:	83 ec 08             	sub    $0x8,%esp
80105a16:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a19:	50                   	push   %eax
80105a1a:	ff 75 08             	pushl  0x8(%ebp)
80105a1d:	e8 4a ff ff ff       	call   8010596c <argint>
80105a22:	83 c4 10             	add    $0x10,%esp
80105a25:	85 c0                	test   %eax,%eax
80105a27:	79 07                	jns    80105a30 <argstr+0x27>
    return -1;
80105a29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a2e:	eb 12                	jmp    80105a42 <argstr+0x39>
  return fetchstr(addr, pp);
80105a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a33:	83 ec 08             	sub    $0x8,%esp
80105a36:	ff 75 0c             	pushl  0xc(%ebp)
80105a39:	50                   	push   %eax
80105a3a:	e8 c5 fe ff ff       	call   80105904 <fetchstr>
80105a3f:	83 c4 10             	add    $0x10,%esp
}
80105a42:	c9                   	leave  
80105a43:	c3                   	ret    

80105a44 <syscall>:
[SYS_dump_rawphymem] sys_dump_rawphymem,
};

void
syscall(void)
{
80105a44:	f3 0f 1e fb          	endbr32 
80105a48:	55                   	push   %ebp
80105a49:	89 e5                	mov    %esp,%ebp
80105a4b:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105a4e:	e8 ce ea ff ff       	call   80104521 <myproc>
80105a53:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a59:	8b 40 18             	mov    0x18(%eax),%eax
80105a5c:	8b 40 1c             	mov    0x1c(%eax),%eax
80105a5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105a62:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a66:	7e 2f                	jle    80105a97 <syscall+0x53>
80105a68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a6b:	83 f8 18             	cmp    $0x18,%eax
80105a6e:	77 27                	ja     80105a97 <syscall+0x53>
80105a70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a73:	8b 04 85 20 d0 10 80 	mov    -0x7fef2fe0(,%eax,4),%eax
80105a7a:	85 c0                	test   %eax,%eax
80105a7c:	74 19                	je     80105a97 <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
80105a7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a81:	8b 04 85 20 d0 10 80 	mov    -0x7fef2fe0(,%eax,4),%eax
80105a88:	ff d0                	call   *%eax
80105a8a:	89 c2                	mov    %eax,%edx
80105a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a8f:	8b 40 18             	mov    0x18(%eax),%eax
80105a92:	89 50 1c             	mov    %edx,0x1c(%eax)
80105a95:	eb 2c                	jmp    80105ac3 <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a9a:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80105a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aa0:	8b 40 10             	mov    0x10(%eax),%eax
80105aa3:	ff 75 f0             	pushl  -0x10(%ebp)
80105aa6:	52                   	push   %edx
80105aa7:	50                   	push   %eax
80105aa8:	68 a4 99 10 80       	push   $0x801099a4
80105aad:	e8 66 a9 ff ff       	call   80100418 <cprintf>
80105ab2:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ab8:	8b 40 18             	mov    0x18(%eax),%eax
80105abb:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105ac2:	90                   	nop
80105ac3:	90                   	nop
80105ac4:	c9                   	leave  
80105ac5:	c3                   	ret    

80105ac6 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105ac6:	f3 0f 1e fb          	endbr32 
80105aca:	55                   	push   %ebp
80105acb:	89 e5                	mov    %esp,%ebp
80105acd:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105ad0:	83 ec 08             	sub    $0x8,%esp
80105ad3:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ad6:	50                   	push   %eax
80105ad7:	ff 75 08             	pushl  0x8(%ebp)
80105ada:	e8 8d fe ff ff       	call   8010596c <argint>
80105adf:	83 c4 10             	add    $0x10,%esp
80105ae2:	85 c0                	test   %eax,%eax
80105ae4:	79 07                	jns    80105aed <argfd+0x27>
    return -1;
80105ae6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aeb:	eb 4f                	jmp    80105b3c <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105aed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105af0:	85 c0                	test   %eax,%eax
80105af2:	78 20                	js     80105b14 <argfd+0x4e>
80105af4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105af7:	83 f8 0f             	cmp    $0xf,%eax
80105afa:	7f 18                	jg     80105b14 <argfd+0x4e>
80105afc:	e8 20 ea ff ff       	call   80104521 <myproc>
80105b01:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b04:	83 c2 08             	add    $0x8,%edx
80105b07:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105b0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b0e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b12:	75 07                	jne    80105b1b <argfd+0x55>
    return -1;
80105b14:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b19:	eb 21                	jmp    80105b3c <argfd+0x76>
  if(pfd)
80105b1b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105b1f:	74 08                	je     80105b29 <argfd+0x63>
    *pfd = fd;
80105b21:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b24:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b27:	89 10                	mov    %edx,(%eax)
  if(pf)
80105b29:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105b2d:	74 08                	je     80105b37 <argfd+0x71>
    *pf = f;
80105b2f:	8b 45 10             	mov    0x10(%ebp),%eax
80105b32:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b35:	89 10                	mov    %edx,(%eax)
  return 0;
80105b37:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b3c:	c9                   	leave  
80105b3d:	c3                   	ret    

80105b3e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105b3e:	f3 0f 1e fb          	endbr32 
80105b42:	55                   	push   %ebp
80105b43:	89 e5                	mov    %esp,%ebp
80105b45:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105b48:	e8 d4 e9 ff ff       	call   80104521 <myproc>
80105b4d:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105b50:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105b57:	eb 2a                	jmp    80105b83 <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
80105b59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b5c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b5f:	83 c2 08             	add    $0x8,%edx
80105b62:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105b66:	85 c0                	test   %eax,%eax
80105b68:	75 15                	jne    80105b7f <fdalloc+0x41>
      curproc->ofile[fd] = f;
80105b6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b70:	8d 4a 08             	lea    0x8(%edx),%ecx
80105b73:	8b 55 08             	mov    0x8(%ebp),%edx
80105b76:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b7d:	eb 0f                	jmp    80105b8e <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80105b7f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105b83:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105b87:	7e d0                	jle    80105b59 <fdalloc+0x1b>
    }
  }
  return -1;
80105b89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b8e:	c9                   	leave  
80105b8f:	c3                   	ret    

80105b90 <sys_dup>:

int
sys_dup(void)
{
80105b90:	f3 0f 1e fb          	endbr32 
80105b94:	55                   	push   %ebp
80105b95:	89 e5                	mov    %esp,%ebp
80105b97:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105b9a:	83 ec 04             	sub    $0x4,%esp
80105b9d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ba0:	50                   	push   %eax
80105ba1:	6a 00                	push   $0x0
80105ba3:	6a 00                	push   $0x0
80105ba5:	e8 1c ff ff ff       	call   80105ac6 <argfd>
80105baa:	83 c4 10             	add    $0x10,%esp
80105bad:	85 c0                	test   %eax,%eax
80105baf:	79 07                	jns    80105bb8 <sys_dup+0x28>
    return -1;
80105bb1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bb6:	eb 31                	jmp    80105be9 <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
80105bb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bbb:	83 ec 0c             	sub    $0xc,%esp
80105bbe:	50                   	push   %eax
80105bbf:	e8 7a ff ff ff       	call   80105b3e <fdalloc>
80105bc4:	83 c4 10             	add    $0x10,%esp
80105bc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bce:	79 07                	jns    80105bd7 <sys_dup+0x47>
    return -1;
80105bd0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bd5:	eb 12                	jmp    80105be9 <sys_dup+0x59>
  filedup(f);
80105bd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bda:	83 ec 0c             	sub    $0xc,%esp
80105bdd:	50                   	push   %eax
80105bde:	e8 b5 b5 ff ff       	call   80101198 <filedup>
80105be3:	83 c4 10             	add    $0x10,%esp
  return fd;
80105be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105be9:	c9                   	leave  
80105bea:	c3                   	ret    

80105beb <sys_read>:

int
sys_read(void)
{
80105beb:	f3 0f 1e fb          	endbr32 
80105bef:	55                   	push   %ebp
80105bf0:	89 e5                	mov    %esp,%ebp
80105bf2:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105bf5:	83 ec 04             	sub    $0x4,%esp
80105bf8:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bfb:	50                   	push   %eax
80105bfc:	6a 00                	push   $0x0
80105bfe:	6a 00                	push   $0x0
80105c00:	e8 c1 fe ff ff       	call   80105ac6 <argfd>
80105c05:	83 c4 10             	add    $0x10,%esp
80105c08:	85 c0                	test   %eax,%eax
80105c0a:	78 2e                	js     80105c3a <sys_read+0x4f>
80105c0c:	83 ec 08             	sub    $0x8,%esp
80105c0f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c12:	50                   	push   %eax
80105c13:	6a 02                	push   $0x2
80105c15:	e8 52 fd ff ff       	call   8010596c <argint>
80105c1a:	83 c4 10             	add    $0x10,%esp
80105c1d:	85 c0                	test   %eax,%eax
80105c1f:	78 19                	js     80105c3a <sys_read+0x4f>
80105c21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c24:	83 ec 04             	sub    $0x4,%esp
80105c27:	50                   	push   %eax
80105c28:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c2b:	50                   	push   %eax
80105c2c:	6a 01                	push   $0x1
80105c2e:	e8 6a fd ff ff       	call   8010599d <argptr>
80105c33:	83 c4 10             	add    $0x10,%esp
80105c36:	85 c0                	test   %eax,%eax
80105c38:	79 07                	jns    80105c41 <sys_read+0x56>
    return -1;
80105c3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c3f:	eb 17                	jmp    80105c58 <sys_read+0x6d>
  return fileread(f, p, n);
80105c41:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105c44:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c4a:	83 ec 04             	sub    $0x4,%esp
80105c4d:	51                   	push   %ecx
80105c4e:	52                   	push   %edx
80105c4f:	50                   	push   %eax
80105c50:	e8 df b6 ff ff       	call   80101334 <fileread>
80105c55:	83 c4 10             	add    $0x10,%esp
}
80105c58:	c9                   	leave  
80105c59:	c3                   	ret    

80105c5a <sys_write>:

int
sys_write(void)
{
80105c5a:	f3 0f 1e fb          	endbr32 
80105c5e:	55                   	push   %ebp
80105c5f:	89 e5                	mov    %esp,%ebp
80105c61:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105c64:	83 ec 04             	sub    $0x4,%esp
80105c67:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c6a:	50                   	push   %eax
80105c6b:	6a 00                	push   $0x0
80105c6d:	6a 00                	push   $0x0
80105c6f:	e8 52 fe ff ff       	call   80105ac6 <argfd>
80105c74:	83 c4 10             	add    $0x10,%esp
80105c77:	85 c0                	test   %eax,%eax
80105c79:	78 2e                	js     80105ca9 <sys_write+0x4f>
80105c7b:	83 ec 08             	sub    $0x8,%esp
80105c7e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c81:	50                   	push   %eax
80105c82:	6a 02                	push   $0x2
80105c84:	e8 e3 fc ff ff       	call   8010596c <argint>
80105c89:	83 c4 10             	add    $0x10,%esp
80105c8c:	85 c0                	test   %eax,%eax
80105c8e:	78 19                	js     80105ca9 <sys_write+0x4f>
80105c90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c93:	83 ec 04             	sub    $0x4,%esp
80105c96:	50                   	push   %eax
80105c97:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c9a:	50                   	push   %eax
80105c9b:	6a 01                	push   $0x1
80105c9d:	e8 fb fc ff ff       	call   8010599d <argptr>
80105ca2:	83 c4 10             	add    $0x10,%esp
80105ca5:	85 c0                	test   %eax,%eax
80105ca7:	79 07                	jns    80105cb0 <sys_write+0x56>
    return -1;
80105ca9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cae:	eb 17                	jmp    80105cc7 <sys_write+0x6d>
  return filewrite(f, p, n);
80105cb0:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105cb3:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cb9:	83 ec 04             	sub    $0x4,%esp
80105cbc:	51                   	push   %ecx
80105cbd:	52                   	push   %edx
80105cbe:	50                   	push   %eax
80105cbf:	e8 2c b7 ff ff       	call   801013f0 <filewrite>
80105cc4:	83 c4 10             	add    $0x10,%esp
}
80105cc7:	c9                   	leave  
80105cc8:	c3                   	ret    

80105cc9 <sys_close>:

int
sys_close(void)
{
80105cc9:	f3 0f 1e fb          	endbr32 
80105ccd:	55                   	push   %ebp
80105cce:	89 e5                	mov    %esp,%ebp
80105cd0:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105cd3:	83 ec 04             	sub    $0x4,%esp
80105cd6:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cd9:	50                   	push   %eax
80105cda:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105cdd:	50                   	push   %eax
80105cde:	6a 00                	push   $0x0
80105ce0:	e8 e1 fd ff ff       	call   80105ac6 <argfd>
80105ce5:	83 c4 10             	add    $0x10,%esp
80105ce8:	85 c0                	test   %eax,%eax
80105cea:	79 07                	jns    80105cf3 <sys_close+0x2a>
    return -1;
80105cec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cf1:	eb 27                	jmp    80105d1a <sys_close+0x51>
  myproc()->ofile[fd] = 0;
80105cf3:	e8 29 e8 ff ff       	call   80104521 <myproc>
80105cf8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105cfb:	83 c2 08             	add    $0x8,%edx
80105cfe:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105d05:	00 
  fileclose(f);
80105d06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d09:	83 ec 0c             	sub    $0xc,%esp
80105d0c:	50                   	push   %eax
80105d0d:	e8 db b4 ff ff       	call   801011ed <fileclose>
80105d12:	83 c4 10             	add    $0x10,%esp
  return 0;
80105d15:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d1a:	c9                   	leave  
80105d1b:	c3                   	ret    

80105d1c <sys_fstat>:

int
sys_fstat(void)
{
80105d1c:	f3 0f 1e fb          	endbr32 
80105d20:	55                   	push   %ebp
80105d21:	89 e5                	mov    %esp,%ebp
80105d23:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105d26:	83 ec 04             	sub    $0x4,%esp
80105d29:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d2c:	50                   	push   %eax
80105d2d:	6a 00                	push   $0x0
80105d2f:	6a 00                	push   $0x0
80105d31:	e8 90 fd ff ff       	call   80105ac6 <argfd>
80105d36:	83 c4 10             	add    $0x10,%esp
80105d39:	85 c0                	test   %eax,%eax
80105d3b:	78 17                	js     80105d54 <sys_fstat+0x38>
80105d3d:	83 ec 04             	sub    $0x4,%esp
80105d40:	6a 14                	push   $0x14
80105d42:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d45:	50                   	push   %eax
80105d46:	6a 01                	push   $0x1
80105d48:	e8 50 fc ff ff       	call   8010599d <argptr>
80105d4d:	83 c4 10             	add    $0x10,%esp
80105d50:	85 c0                	test   %eax,%eax
80105d52:	79 07                	jns    80105d5b <sys_fstat+0x3f>
    return -1;
80105d54:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d59:	eb 13                	jmp    80105d6e <sys_fstat+0x52>
  return filestat(f, st);
80105d5b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d61:	83 ec 08             	sub    $0x8,%esp
80105d64:	52                   	push   %edx
80105d65:	50                   	push   %eax
80105d66:	e8 6e b5 ff ff       	call   801012d9 <filestat>
80105d6b:	83 c4 10             	add    $0x10,%esp
}
80105d6e:	c9                   	leave  
80105d6f:	c3                   	ret    

80105d70 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105d70:	f3 0f 1e fb          	endbr32 
80105d74:	55                   	push   %ebp
80105d75:	89 e5                	mov    %esp,%ebp
80105d77:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105d7a:	83 ec 08             	sub    $0x8,%esp
80105d7d:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105d80:	50                   	push   %eax
80105d81:	6a 00                	push   $0x0
80105d83:	e8 81 fc ff ff       	call   80105a09 <argstr>
80105d88:	83 c4 10             	add    $0x10,%esp
80105d8b:	85 c0                	test   %eax,%eax
80105d8d:	78 15                	js     80105da4 <sys_link+0x34>
80105d8f:	83 ec 08             	sub    $0x8,%esp
80105d92:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105d95:	50                   	push   %eax
80105d96:	6a 01                	push   $0x1
80105d98:	e8 6c fc ff ff       	call   80105a09 <argstr>
80105d9d:	83 c4 10             	add    $0x10,%esp
80105da0:	85 c0                	test   %eax,%eax
80105da2:	79 0a                	jns    80105dae <sys_link+0x3e>
    return -1;
80105da4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105da9:	e9 68 01 00 00       	jmp    80105f16 <sys_link+0x1a6>

  begin_op();
80105dae:	e8 af d9 ff ff       	call   80103762 <begin_op>
  if((ip = namei(old)) == 0){
80105db3:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105db6:	83 ec 0c             	sub    $0xc,%esp
80105db9:	50                   	push   %eax
80105dba:	e8 19 c9 ff ff       	call   801026d8 <namei>
80105dbf:	83 c4 10             	add    $0x10,%esp
80105dc2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105dc5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105dc9:	75 0f                	jne    80105dda <sys_link+0x6a>
    end_op();
80105dcb:	e8 22 da ff ff       	call   801037f2 <end_op>
    return -1;
80105dd0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dd5:	e9 3c 01 00 00       	jmp    80105f16 <sys_link+0x1a6>
  }

  ilock(ip);
80105dda:	83 ec 0c             	sub    $0xc,%esp
80105ddd:	ff 75 f4             	pushl  -0xc(%ebp)
80105de0:	e8 88 bd ff ff       	call   80101b6d <ilock>
80105de5:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105deb:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105def:	66 83 f8 01          	cmp    $0x1,%ax
80105df3:	75 1d                	jne    80105e12 <sys_link+0xa2>
    iunlockput(ip);
80105df5:	83 ec 0c             	sub    $0xc,%esp
80105df8:	ff 75 f4             	pushl  -0xc(%ebp)
80105dfb:	e8 aa bf ff ff       	call   80101daa <iunlockput>
80105e00:	83 c4 10             	add    $0x10,%esp
    end_op();
80105e03:	e8 ea d9 ff ff       	call   801037f2 <end_op>
    return -1;
80105e08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e0d:	e9 04 01 00 00       	jmp    80105f16 <sys_link+0x1a6>
  }

  ip->nlink++;
80105e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e15:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105e19:	83 c0 01             	add    $0x1,%eax
80105e1c:	89 c2                	mov    %eax,%edx
80105e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e21:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105e25:	83 ec 0c             	sub    $0xc,%esp
80105e28:	ff 75 f4             	pushl  -0xc(%ebp)
80105e2b:	e8 54 bb ff ff       	call   80101984 <iupdate>
80105e30:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105e33:	83 ec 0c             	sub    $0xc,%esp
80105e36:	ff 75 f4             	pushl  -0xc(%ebp)
80105e39:	e8 46 be ff ff       	call   80101c84 <iunlock>
80105e3e:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105e41:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105e44:	83 ec 08             	sub    $0x8,%esp
80105e47:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105e4a:	52                   	push   %edx
80105e4b:	50                   	push   %eax
80105e4c:	e8 a7 c8 ff ff       	call   801026f8 <nameiparent>
80105e51:	83 c4 10             	add    $0x10,%esp
80105e54:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e57:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e5b:	74 71                	je     80105ece <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105e5d:	83 ec 0c             	sub    $0xc,%esp
80105e60:	ff 75 f0             	pushl  -0x10(%ebp)
80105e63:	e8 05 bd ff ff       	call   80101b6d <ilock>
80105e68:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105e6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e6e:	8b 10                	mov    (%eax),%edx
80105e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e73:	8b 00                	mov    (%eax),%eax
80105e75:	39 c2                	cmp    %eax,%edx
80105e77:	75 1d                	jne    80105e96 <sys_link+0x126>
80105e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e7c:	8b 40 04             	mov    0x4(%eax),%eax
80105e7f:	83 ec 04             	sub    $0x4,%esp
80105e82:	50                   	push   %eax
80105e83:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105e86:	50                   	push   %eax
80105e87:	ff 75 f0             	pushl  -0x10(%ebp)
80105e8a:	e8 a6 c5 ff ff       	call   80102435 <dirlink>
80105e8f:	83 c4 10             	add    $0x10,%esp
80105e92:	85 c0                	test   %eax,%eax
80105e94:	79 10                	jns    80105ea6 <sys_link+0x136>
    iunlockput(dp);
80105e96:	83 ec 0c             	sub    $0xc,%esp
80105e99:	ff 75 f0             	pushl  -0x10(%ebp)
80105e9c:	e8 09 bf ff ff       	call   80101daa <iunlockput>
80105ea1:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105ea4:	eb 29                	jmp    80105ecf <sys_link+0x15f>
  }
  iunlockput(dp);
80105ea6:	83 ec 0c             	sub    $0xc,%esp
80105ea9:	ff 75 f0             	pushl  -0x10(%ebp)
80105eac:	e8 f9 be ff ff       	call   80101daa <iunlockput>
80105eb1:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105eb4:	83 ec 0c             	sub    $0xc,%esp
80105eb7:	ff 75 f4             	pushl  -0xc(%ebp)
80105eba:	e8 17 be ff ff       	call   80101cd6 <iput>
80105ebf:	83 c4 10             	add    $0x10,%esp

  end_op();
80105ec2:	e8 2b d9 ff ff       	call   801037f2 <end_op>

  return 0;
80105ec7:	b8 00 00 00 00       	mov    $0x0,%eax
80105ecc:	eb 48                	jmp    80105f16 <sys_link+0x1a6>
    goto bad;
80105ece:	90                   	nop

bad:
  ilock(ip);
80105ecf:	83 ec 0c             	sub    $0xc,%esp
80105ed2:	ff 75 f4             	pushl  -0xc(%ebp)
80105ed5:	e8 93 bc ff ff       	call   80101b6d <ilock>
80105eda:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105edd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ee0:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105ee4:	83 e8 01             	sub    $0x1,%eax
80105ee7:	89 c2                	mov    %eax,%edx
80105ee9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eec:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105ef0:	83 ec 0c             	sub    $0xc,%esp
80105ef3:	ff 75 f4             	pushl  -0xc(%ebp)
80105ef6:	e8 89 ba ff ff       	call   80101984 <iupdate>
80105efb:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105efe:	83 ec 0c             	sub    $0xc,%esp
80105f01:	ff 75 f4             	pushl  -0xc(%ebp)
80105f04:	e8 a1 be ff ff       	call   80101daa <iunlockput>
80105f09:	83 c4 10             	add    $0x10,%esp
  end_op();
80105f0c:	e8 e1 d8 ff ff       	call   801037f2 <end_op>
  return -1;
80105f11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105f16:	c9                   	leave  
80105f17:	c3                   	ret    

80105f18 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105f18:	f3 0f 1e fb          	endbr32 
80105f1c:	55                   	push   %ebp
80105f1d:	89 e5                	mov    %esp,%ebp
80105f1f:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105f22:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105f29:	eb 40                	jmp    80105f6b <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105f2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f2e:	6a 10                	push   $0x10
80105f30:	50                   	push   %eax
80105f31:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f34:	50                   	push   %eax
80105f35:	ff 75 08             	pushl  0x8(%ebp)
80105f38:	e8 38 c1 ff ff       	call   80102075 <readi>
80105f3d:	83 c4 10             	add    $0x10,%esp
80105f40:	83 f8 10             	cmp    $0x10,%eax
80105f43:	74 0d                	je     80105f52 <isdirempty+0x3a>
      panic("isdirempty: readi");
80105f45:	83 ec 0c             	sub    $0xc,%esp
80105f48:	68 c0 99 10 80       	push   $0x801099c0
80105f4d:	e8 b6 a6 ff ff       	call   80100608 <panic>
    if(de.inum != 0)
80105f52:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105f56:	66 85 c0             	test   %ax,%ax
80105f59:	74 07                	je     80105f62 <isdirempty+0x4a>
      return 0;
80105f5b:	b8 00 00 00 00       	mov    $0x0,%eax
80105f60:	eb 1b                	jmp    80105f7d <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105f62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f65:	83 c0 10             	add    $0x10,%eax
80105f68:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f6b:	8b 45 08             	mov    0x8(%ebp),%eax
80105f6e:	8b 50 58             	mov    0x58(%eax),%edx
80105f71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f74:	39 c2                	cmp    %eax,%edx
80105f76:	77 b3                	ja     80105f2b <isdirempty+0x13>
  }
  return 1;
80105f78:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105f7d:	c9                   	leave  
80105f7e:	c3                   	ret    

80105f7f <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105f7f:	f3 0f 1e fb          	endbr32 
80105f83:	55                   	push   %ebp
80105f84:	89 e5                	mov    %esp,%ebp
80105f86:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105f89:	83 ec 08             	sub    $0x8,%esp
80105f8c:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105f8f:	50                   	push   %eax
80105f90:	6a 00                	push   $0x0
80105f92:	e8 72 fa ff ff       	call   80105a09 <argstr>
80105f97:	83 c4 10             	add    $0x10,%esp
80105f9a:	85 c0                	test   %eax,%eax
80105f9c:	79 0a                	jns    80105fa8 <sys_unlink+0x29>
    return -1;
80105f9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fa3:	e9 bf 01 00 00       	jmp    80106167 <sys_unlink+0x1e8>

  begin_op();
80105fa8:	e8 b5 d7 ff ff       	call   80103762 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105fad:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105fb0:	83 ec 08             	sub    $0x8,%esp
80105fb3:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105fb6:	52                   	push   %edx
80105fb7:	50                   	push   %eax
80105fb8:	e8 3b c7 ff ff       	call   801026f8 <nameiparent>
80105fbd:	83 c4 10             	add    $0x10,%esp
80105fc0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fc3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fc7:	75 0f                	jne    80105fd8 <sys_unlink+0x59>
    end_op();
80105fc9:	e8 24 d8 ff ff       	call   801037f2 <end_op>
    return -1;
80105fce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fd3:	e9 8f 01 00 00       	jmp    80106167 <sys_unlink+0x1e8>
  }

  ilock(dp);
80105fd8:	83 ec 0c             	sub    $0xc,%esp
80105fdb:	ff 75 f4             	pushl  -0xc(%ebp)
80105fde:	e8 8a bb ff ff       	call   80101b6d <ilock>
80105fe3:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105fe6:	83 ec 08             	sub    $0x8,%esp
80105fe9:	68 d2 99 10 80       	push   $0x801099d2
80105fee:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105ff1:	50                   	push   %eax
80105ff2:	e8 61 c3 ff ff       	call   80102358 <namecmp>
80105ff7:	83 c4 10             	add    $0x10,%esp
80105ffa:	85 c0                	test   %eax,%eax
80105ffc:	0f 84 49 01 00 00    	je     8010614b <sys_unlink+0x1cc>
80106002:	83 ec 08             	sub    $0x8,%esp
80106005:	68 d4 99 10 80       	push   $0x801099d4
8010600a:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010600d:	50                   	push   %eax
8010600e:	e8 45 c3 ff ff       	call   80102358 <namecmp>
80106013:	83 c4 10             	add    $0x10,%esp
80106016:	85 c0                	test   %eax,%eax
80106018:	0f 84 2d 01 00 00    	je     8010614b <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
8010601e:	83 ec 04             	sub    $0x4,%esp
80106021:	8d 45 c8             	lea    -0x38(%ebp),%eax
80106024:	50                   	push   %eax
80106025:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106028:	50                   	push   %eax
80106029:	ff 75 f4             	pushl  -0xc(%ebp)
8010602c:	e8 46 c3 ff ff       	call   80102377 <dirlookup>
80106031:	83 c4 10             	add    $0x10,%esp
80106034:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106037:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010603b:	0f 84 0d 01 00 00    	je     8010614e <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80106041:	83 ec 0c             	sub    $0xc,%esp
80106044:	ff 75 f0             	pushl  -0x10(%ebp)
80106047:	e8 21 bb ff ff       	call   80101b6d <ilock>
8010604c:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
8010604f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106052:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106056:	66 85 c0             	test   %ax,%ax
80106059:	7f 0d                	jg     80106068 <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
8010605b:	83 ec 0c             	sub    $0xc,%esp
8010605e:	68 d7 99 10 80       	push   $0x801099d7
80106063:	e8 a0 a5 ff ff       	call   80100608 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80106068:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010606b:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010606f:	66 83 f8 01          	cmp    $0x1,%ax
80106073:	75 25                	jne    8010609a <sys_unlink+0x11b>
80106075:	83 ec 0c             	sub    $0xc,%esp
80106078:	ff 75 f0             	pushl  -0x10(%ebp)
8010607b:	e8 98 fe ff ff       	call   80105f18 <isdirempty>
80106080:	83 c4 10             	add    $0x10,%esp
80106083:	85 c0                	test   %eax,%eax
80106085:	75 13                	jne    8010609a <sys_unlink+0x11b>
    iunlockput(ip);
80106087:	83 ec 0c             	sub    $0xc,%esp
8010608a:	ff 75 f0             	pushl  -0x10(%ebp)
8010608d:	e8 18 bd ff ff       	call   80101daa <iunlockput>
80106092:	83 c4 10             	add    $0x10,%esp
    goto bad;
80106095:	e9 b5 00 00 00       	jmp    8010614f <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
8010609a:	83 ec 04             	sub    $0x4,%esp
8010609d:	6a 10                	push   $0x10
8010609f:	6a 00                	push   $0x0
801060a1:	8d 45 e0             	lea    -0x20(%ebp),%eax
801060a4:	50                   	push   %eax
801060a5:	e8 6e f5 ff ff       	call   80105618 <memset>
801060aa:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801060ad:	8b 45 c8             	mov    -0x38(%ebp),%eax
801060b0:	6a 10                	push   $0x10
801060b2:	50                   	push   %eax
801060b3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801060b6:	50                   	push   %eax
801060b7:	ff 75 f4             	pushl  -0xc(%ebp)
801060ba:	e8 0f c1 ff ff       	call   801021ce <writei>
801060bf:	83 c4 10             	add    $0x10,%esp
801060c2:	83 f8 10             	cmp    $0x10,%eax
801060c5:	74 0d                	je     801060d4 <sys_unlink+0x155>
    panic("unlink: writei");
801060c7:	83 ec 0c             	sub    $0xc,%esp
801060ca:	68 e9 99 10 80       	push   $0x801099e9
801060cf:	e8 34 a5 ff ff       	call   80100608 <panic>
  if(ip->type == T_DIR){
801060d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060d7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801060db:	66 83 f8 01          	cmp    $0x1,%ax
801060df:	75 21                	jne    80106102 <sys_unlink+0x183>
    dp->nlink--;
801060e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060e4:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801060e8:	83 e8 01             	sub    $0x1,%eax
801060eb:	89 c2                	mov    %eax,%edx
801060ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060f0:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801060f4:	83 ec 0c             	sub    $0xc,%esp
801060f7:	ff 75 f4             	pushl  -0xc(%ebp)
801060fa:	e8 85 b8 ff ff       	call   80101984 <iupdate>
801060ff:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80106102:	83 ec 0c             	sub    $0xc,%esp
80106105:	ff 75 f4             	pushl  -0xc(%ebp)
80106108:	e8 9d bc ff ff       	call   80101daa <iunlockput>
8010610d:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80106110:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106113:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106117:	83 e8 01             	sub    $0x1,%eax
8010611a:	89 c2                	mov    %eax,%edx
8010611c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010611f:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80106123:	83 ec 0c             	sub    $0xc,%esp
80106126:	ff 75 f0             	pushl  -0x10(%ebp)
80106129:	e8 56 b8 ff ff       	call   80101984 <iupdate>
8010612e:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106131:	83 ec 0c             	sub    $0xc,%esp
80106134:	ff 75 f0             	pushl  -0x10(%ebp)
80106137:	e8 6e bc ff ff       	call   80101daa <iunlockput>
8010613c:	83 c4 10             	add    $0x10,%esp

  end_op();
8010613f:	e8 ae d6 ff ff       	call   801037f2 <end_op>

  return 0;
80106144:	b8 00 00 00 00       	mov    $0x0,%eax
80106149:	eb 1c                	jmp    80106167 <sys_unlink+0x1e8>
    goto bad;
8010614b:	90                   	nop
8010614c:	eb 01                	jmp    8010614f <sys_unlink+0x1d0>
    goto bad;
8010614e:	90                   	nop

bad:
  iunlockput(dp);
8010614f:	83 ec 0c             	sub    $0xc,%esp
80106152:	ff 75 f4             	pushl  -0xc(%ebp)
80106155:	e8 50 bc ff ff       	call   80101daa <iunlockput>
8010615a:	83 c4 10             	add    $0x10,%esp
  end_op();
8010615d:	e8 90 d6 ff ff       	call   801037f2 <end_op>
  return -1;
80106162:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106167:	c9                   	leave  
80106168:	c3                   	ret    

80106169 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80106169:	f3 0f 1e fb          	endbr32 
8010616d:	55                   	push   %ebp
8010616e:	89 e5                	mov    %esp,%ebp
80106170:	83 ec 38             	sub    $0x38,%esp
80106173:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106176:	8b 55 10             	mov    0x10(%ebp),%edx
80106179:	8b 45 14             	mov    0x14(%ebp),%eax
8010617c:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106180:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106184:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106188:	83 ec 08             	sub    $0x8,%esp
8010618b:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010618e:	50                   	push   %eax
8010618f:	ff 75 08             	pushl  0x8(%ebp)
80106192:	e8 61 c5 ff ff       	call   801026f8 <nameiparent>
80106197:	83 c4 10             	add    $0x10,%esp
8010619a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010619d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061a1:	75 0a                	jne    801061ad <create+0x44>
    return 0;
801061a3:	b8 00 00 00 00       	mov    $0x0,%eax
801061a8:	e9 8e 01 00 00       	jmp    8010633b <create+0x1d2>
  ilock(dp);
801061ad:	83 ec 0c             	sub    $0xc,%esp
801061b0:	ff 75 f4             	pushl  -0xc(%ebp)
801061b3:	e8 b5 b9 ff ff       	call   80101b6d <ilock>
801061b8:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, 0)) != 0){
801061bb:	83 ec 04             	sub    $0x4,%esp
801061be:	6a 00                	push   $0x0
801061c0:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801061c3:	50                   	push   %eax
801061c4:	ff 75 f4             	pushl  -0xc(%ebp)
801061c7:	e8 ab c1 ff ff       	call   80102377 <dirlookup>
801061cc:	83 c4 10             	add    $0x10,%esp
801061cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061d2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061d6:	74 50                	je     80106228 <create+0xbf>
    iunlockput(dp);
801061d8:	83 ec 0c             	sub    $0xc,%esp
801061db:	ff 75 f4             	pushl  -0xc(%ebp)
801061de:	e8 c7 bb ff ff       	call   80101daa <iunlockput>
801061e3:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801061e6:	83 ec 0c             	sub    $0xc,%esp
801061e9:	ff 75 f0             	pushl  -0x10(%ebp)
801061ec:	e8 7c b9 ff ff       	call   80101b6d <ilock>
801061f1:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801061f4:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801061f9:	75 15                	jne    80106210 <create+0xa7>
801061fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061fe:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106202:	66 83 f8 02          	cmp    $0x2,%ax
80106206:	75 08                	jne    80106210 <create+0xa7>
      return ip;
80106208:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010620b:	e9 2b 01 00 00       	jmp    8010633b <create+0x1d2>
    iunlockput(ip);
80106210:	83 ec 0c             	sub    $0xc,%esp
80106213:	ff 75 f0             	pushl  -0x10(%ebp)
80106216:	e8 8f bb ff ff       	call   80101daa <iunlockput>
8010621b:	83 c4 10             	add    $0x10,%esp
    return 0;
8010621e:	b8 00 00 00 00       	mov    $0x0,%eax
80106223:	e9 13 01 00 00       	jmp    8010633b <create+0x1d2>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106228:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010622c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010622f:	8b 00                	mov    (%eax),%eax
80106231:	83 ec 08             	sub    $0x8,%esp
80106234:	52                   	push   %edx
80106235:	50                   	push   %eax
80106236:	e8 6e b6 ff ff       	call   801018a9 <ialloc>
8010623b:	83 c4 10             	add    $0x10,%esp
8010623e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106241:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106245:	75 0d                	jne    80106254 <create+0xeb>
    panic("create: ialloc");
80106247:	83 ec 0c             	sub    $0xc,%esp
8010624a:	68 f8 99 10 80       	push   $0x801099f8
8010624f:	e8 b4 a3 ff ff       	call   80100608 <panic>

  ilock(ip);
80106254:	83 ec 0c             	sub    $0xc,%esp
80106257:	ff 75 f0             	pushl  -0x10(%ebp)
8010625a:	e8 0e b9 ff ff       	call   80101b6d <ilock>
8010625f:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80106262:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106265:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106269:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
8010626d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106270:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106274:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80106278:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010627b:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80106281:	83 ec 0c             	sub    $0xc,%esp
80106284:	ff 75 f0             	pushl  -0x10(%ebp)
80106287:	e8 f8 b6 ff ff       	call   80101984 <iupdate>
8010628c:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
8010628f:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106294:	75 6a                	jne    80106300 <create+0x197>
    dp->nlink++;  // for ".."
80106296:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106299:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010629d:	83 c0 01             	add    $0x1,%eax
801062a0:	89 c2                	mov    %eax,%edx
801062a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062a5:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801062a9:	83 ec 0c             	sub    $0xc,%esp
801062ac:	ff 75 f4             	pushl  -0xc(%ebp)
801062af:	e8 d0 b6 ff ff       	call   80101984 <iupdate>
801062b4:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801062b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062ba:	8b 40 04             	mov    0x4(%eax),%eax
801062bd:	83 ec 04             	sub    $0x4,%esp
801062c0:	50                   	push   %eax
801062c1:	68 d2 99 10 80       	push   $0x801099d2
801062c6:	ff 75 f0             	pushl  -0x10(%ebp)
801062c9:	e8 67 c1 ff ff       	call   80102435 <dirlink>
801062ce:	83 c4 10             	add    $0x10,%esp
801062d1:	85 c0                	test   %eax,%eax
801062d3:	78 1e                	js     801062f3 <create+0x18a>
801062d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062d8:	8b 40 04             	mov    0x4(%eax),%eax
801062db:	83 ec 04             	sub    $0x4,%esp
801062de:	50                   	push   %eax
801062df:	68 d4 99 10 80       	push   $0x801099d4
801062e4:	ff 75 f0             	pushl  -0x10(%ebp)
801062e7:	e8 49 c1 ff ff       	call   80102435 <dirlink>
801062ec:	83 c4 10             	add    $0x10,%esp
801062ef:	85 c0                	test   %eax,%eax
801062f1:	79 0d                	jns    80106300 <create+0x197>
      panic("create dots");
801062f3:	83 ec 0c             	sub    $0xc,%esp
801062f6:	68 07 9a 10 80       	push   $0x80109a07
801062fb:	e8 08 a3 ff ff       	call   80100608 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106300:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106303:	8b 40 04             	mov    0x4(%eax),%eax
80106306:	83 ec 04             	sub    $0x4,%esp
80106309:	50                   	push   %eax
8010630a:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010630d:	50                   	push   %eax
8010630e:	ff 75 f4             	pushl  -0xc(%ebp)
80106311:	e8 1f c1 ff ff       	call   80102435 <dirlink>
80106316:	83 c4 10             	add    $0x10,%esp
80106319:	85 c0                	test   %eax,%eax
8010631b:	79 0d                	jns    8010632a <create+0x1c1>
    panic("create: dirlink");
8010631d:	83 ec 0c             	sub    $0xc,%esp
80106320:	68 13 9a 10 80       	push   $0x80109a13
80106325:	e8 de a2 ff ff       	call   80100608 <panic>

  iunlockput(dp);
8010632a:	83 ec 0c             	sub    $0xc,%esp
8010632d:	ff 75 f4             	pushl  -0xc(%ebp)
80106330:	e8 75 ba ff ff       	call   80101daa <iunlockput>
80106335:	83 c4 10             	add    $0x10,%esp

  return ip;
80106338:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010633b:	c9                   	leave  
8010633c:	c3                   	ret    

8010633d <sys_open>:

int
sys_open(void)
{
8010633d:	f3 0f 1e fb          	endbr32 
80106341:	55                   	push   %ebp
80106342:	89 e5                	mov    %esp,%ebp
80106344:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106347:	83 ec 08             	sub    $0x8,%esp
8010634a:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010634d:	50                   	push   %eax
8010634e:	6a 00                	push   $0x0
80106350:	e8 b4 f6 ff ff       	call   80105a09 <argstr>
80106355:	83 c4 10             	add    $0x10,%esp
80106358:	85 c0                	test   %eax,%eax
8010635a:	78 15                	js     80106371 <sys_open+0x34>
8010635c:	83 ec 08             	sub    $0x8,%esp
8010635f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106362:	50                   	push   %eax
80106363:	6a 01                	push   $0x1
80106365:	e8 02 f6 ff ff       	call   8010596c <argint>
8010636a:	83 c4 10             	add    $0x10,%esp
8010636d:	85 c0                	test   %eax,%eax
8010636f:	79 0a                	jns    8010637b <sys_open+0x3e>
    return -1;
80106371:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106376:	e9 61 01 00 00       	jmp    801064dc <sys_open+0x19f>

  begin_op();
8010637b:	e8 e2 d3 ff ff       	call   80103762 <begin_op>

  if(omode & O_CREATE){
80106380:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106383:	25 00 02 00 00       	and    $0x200,%eax
80106388:	85 c0                	test   %eax,%eax
8010638a:	74 2a                	je     801063b6 <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
8010638c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010638f:	6a 00                	push   $0x0
80106391:	6a 00                	push   $0x0
80106393:	6a 02                	push   $0x2
80106395:	50                   	push   %eax
80106396:	e8 ce fd ff ff       	call   80106169 <create>
8010639b:	83 c4 10             	add    $0x10,%esp
8010639e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801063a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063a5:	75 75                	jne    8010641c <sys_open+0xdf>
      end_op();
801063a7:	e8 46 d4 ff ff       	call   801037f2 <end_op>
      return -1;
801063ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063b1:	e9 26 01 00 00       	jmp    801064dc <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
801063b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801063b9:	83 ec 0c             	sub    $0xc,%esp
801063bc:	50                   	push   %eax
801063bd:	e8 16 c3 ff ff       	call   801026d8 <namei>
801063c2:	83 c4 10             	add    $0x10,%esp
801063c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063cc:	75 0f                	jne    801063dd <sys_open+0xa0>
      end_op();
801063ce:	e8 1f d4 ff ff       	call   801037f2 <end_op>
      return -1;
801063d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063d8:	e9 ff 00 00 00       	jmp    801064dc <sys_open+0x19f>
    }
    ilock(ip);
801063dd:	83 ec 0c             	sub    $0xc,%esp
801063e0:	ff 75 f4             	pushl  -0xc(%ebp)
801063e3:	e8 85 b7 ff ff       	call   80101b6d <ilock>
801063e8:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
801063eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063ee:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801063f2:	66 83 f8 01          	cmp    $0x1,%ax
801063f6:	75 24                	jne    8010641c <sys_open+0xdf>
801063f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063fb:	85 c0                	test   %eax,%eax
801063fd:	74 1d                	je     8010641c <sys_open+0xdf>
      iunlockput(ip);
801063ff:	83 ec 0c             	sub    $0xc,%esp
80106402:	ff 75 f4             	pushl  -0xc(%ebp)
80106405:	e8 a0 b9 ff ff       	call   80101daa <iunlockput>
8010640a:	83 c4 10             	add    $0x10,%esp
      end_op();
8010640d:	e8 e0 d3 ff ff       	call   801037f2 <end_op>
      return -1;
80106412:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106417:	e9 c0 00 00 00       	jmp    801064dc <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010641c:	e8 06 ad ff ff       	call   80101127 <filealloc>
80106421:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106424:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106428:	74 17                	je     80106441 <sys_open+0x104>
8010642a:	83 ec 0c             	sub    $0xc,%esp
8010642d:	ff 75 f0             	pushl  -0x10(%ebp)
80106430:	e8 09 f7 ff ff       	call   80105b3e <fdalloc>
80106435:	83 c4 10             	add    $0x10,%esp
80106438:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010643b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010643f:	79 2e                	jns    8010646f <sys_open+0x132>
    if(f)
80106441:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106445:	74 0e                	je     80106455 <sys_open+0x118>
      fileclose(f);
80106447:	83 ec 0c             	sub    $0xc,%esp
8010644a:	ff 75 f0             	pushl  -0x10(%ebp)
8010644d:	e8 9b ad ff ff       	call   801011ed <fileclose>
80106452:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106455:	83 ec 0c             	sub    $0xc,%esp
80106458:	ff 75 f4             	pushl  -0xc(%ebp)
8010645b:	e8 4a b9 ff ff       	call   80101daa <iunlockput>
80106460:	83 c4 10             	add    $0x10,%esp
    end_op();
80106463:	e8 8a d3 ff ff       	call   801037f2 <end_op>
    return -1;
80106468:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010646d:	eb 6d                	jmp    801064dc <sys_open+0x19f>
  }
  iunlock(ip);
8010646f:	83 ec 0c             	sub    $0xc,%esp
80106472:	ff 75 f4             	pushl  -0xc(%ebp)
80106475:	e8 0a b8 ff ff       	call   80101c84 <iunlock>
8010647a:	83 c4 10             	add    $0x10,%esp
  end_op();
8010647d:	e8 70 d3 ff ff       	call   801037f2 <end_op>

  f->type = FD_INODE;
80106482:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106485:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
8010648b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010648e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106491:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106494:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106497:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
8010649e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064a1:	83 e0 01             	and    $0x1,%eax
801064a4:	85 c0                	test   %eax,%eax
801064a6:	0f 94 c0             	sete   %al
801064a9:	89 c2                	mov    %eax,%edx
801064ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064ae:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801064b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064b4:	83 e0 01             	and    $0x1,%eax
801064b7:	85 c0                	test   %eax,%eax
801064b9:	75 0a                	jne    801064c5 <sys_open+0x188>
801064bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064be:	83 e0 02             	and    $0x2,%eax
801064c1:	85 c0                	test   %eax,%eax
801064c3:	74 07                	je     801064cc <sys_open+0x18f>
801064c5:	b8 01 00 00 00       	mov    $0x1,%eax
801064ca:	eb 05                	jmp    801064d1 <sys_open+0x194>
801064cc:	b8 00 00 00 00       	mov    $0x0,%eax
801064d1:	89 c2                	mov    %eax,%edx
801064d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064d6:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801064d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801064dc:	c9                   	leave  
801064dd:	c3                   	ret    

801064de <sys_mkdir>:

int
sys_mkdir(void)
{
801064de:	f3 0f 1e fb          	endbr32 
801064e2:	55                   	push   %ebp
801064e3:	89 e5                	mov    %esp,%ebp
801064e5:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801064e8:	e8 75 d2 ff ff       	call   80103762 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801064ed:	83 ec 08             	sub    $0x8,%esp
801064f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064f3:	50                   	push   %eax
801064f4:	6a 00                	push   $0x0
801064f6:	e8 0e f5 ff ff       	call   80105a09 <argstr>
801064fb:	83 c4 10             	add    $0x10,%esp
801064fe:	85 c0                	test   %eax,%eax
80106500:	78 1b                	js     8010651d <sys_mkdir+0x3f>
80106502:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106505:	6a 00                	push   $0x0
80106507:	6a 00                	push   $0x0
80106509:	6a 01                	push   $0x1
8010650b:	50                   	push   %eax
8010650c:	e8 58 fc ff ff       	call   80106169 <create>
80106511:	83 c4 10             	add    $0x10,%esp
80106514:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106517:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010651b:	75 0c                	jne    80106529 <sys_mkdir+0x4b>
    end_op();
8010651d:	e8 d0 d2 ff ff       	call   801037f2 <end_op>
    return -1;
80106522:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106527:	eb 18                	jmp    80106541 <sys_mkdir+0x63>
  }
  iunlockput(ip);
80106529:	83 ec 0c             	sub    $0xc,%esp
8010652c:	ff 75 f4             	pushl  -0xc(%ebp)
8010652f:	e8 76 b8 ff ff       	call   80101daa <iunlockput>
80106534:	83 c4 10             	add    $0x10,%esp
  end_op();
80106537:	e8 b6 d2 ff ff       	call   801037f2 <end_op>
  return 0;
8010653c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106541:	c9                   	leave  
80106542:	c3                   	ret    

80106543 <sys_mknod>:

int
sys_mknod(void)
{
80106543:	f3 0f 1e fb          	endbr32 
80106547:	55                   	push   %ebp
80106548:	89 e5                	mov    %esp,%ebp
8010654a:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
8010654d:	e8 10 d2 ff ff       	call   80103762 <begin_op>
  if((argstr(0, &path)) < 0 ||
80106552:	83 ec 08             	sub    $0x8,%esp
80106555:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106558:	50                   	push   %eax
80106559:	6a 00                	push   $0x0
8010655b:	e8 a9 f4 ff ff       	call   80105a09 <argstr>
80106560:	83 c4 10             	add    $0x10,%esp
80106563:	85 c0                	test   %eax,%eax
80106565:	78 4f                	js     801065b6 <sys_mknod+0x73>
     argint(1, &major) < 0 ||
80106567:	83 ec 08             	sub    $0x8,%esp
8010656a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010656d:	50                   	push   %eax
8010656e:	6a 01                	push   $0x1
80106570:	e8 f7 f3 ff ff       	call   8010596c <argint>
80106575:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80106578:	85 c0                	test   %eax,%eax
8010657a:	78 3a                	js     801065b6 <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
8010657c:	83 ec 08             	sub    $0x8,%esp
8010657f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106582:	50                   	push   %eax
80106583:	6a 02                	push   $0x2
80106585:	e8 e2 f3 ff ff       	call   8010596c <argint>
8010658a:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
8010658d:	85 c0                	test   %eax,%eax
8010658f:	78 25                	js     801065b6 <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
80106591:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106594:	0f bf c8             	movswl %ax,%ecx
80106597:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010659a:	0f bf d0             	movswl %ax,%edx
8010659d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065a0:	51                   	push   %ecx
801065a1:	52                   	push   %edx
801065a2:	6a 03                	push   $0x3
801065a4:	50                   	push   %eax
801065a5:	e8 bf fb ff ff       	call   80106169 <create>
801065aa:	83 c4 10             	add    $0x10,%esp
801065ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
801065b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065b4:	75 0c                	jne    801065c2 <sys_mknod+0x7f>
    end_op();
801065b6:	e8 37 d2 ff ff       	call   801037f2 <end_op>
    return -1;
801065bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065c0:	eb 18                	jmp    801065da <sys_mknod+0x97>
  }
  iunlockput(ip);
801065c2:	83 ec 0c             	sub    $0xc,%esp
801065c5:	ff 75 f4             	pushl  -0xc(%ebp)
801065c8:	e8 dd b7 ff ff       	call   80101daa <iunlockput>
801065cd:	83 c4 10             	add    $0x10,%esp
  end_op();
801065d0:	e8 1d d2 ff ff       	call   801037f2 <end_op>
  return 0;
801065d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065da:	c9                   	leave  
801065db:	c3                   	ret    

801065dc <sys_chdir>:

int
sys_chdir(void)
{
801065dc:	f3 0f 1e fb          	endbr32 
801065e0:	55                   	push   %ebp
801065e1:	89 e5                	mov    %esp,%ebp
801065e3:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801065e6:	e8 36 df ff ff       	call   80104521 <myproc>
801065eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801065ee:	e8 6f d1 ff ff       	call   80103762 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801065f3:	83 ec 08             	sub    $0x8,%esp
801065f6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801065f9:	50                   	push   %eax
801065fa:	6a 00                	push   $0x0
801065fc:	e8 08 f4 ff ff       	call   80105a09 <argstr>
80106601:	83 c4 10             	add    $0x10,%esp
80106604:	85 c0                	test   %eax,%eax
80106606:	78 18                	js     80106620 <sys_chdir+0x44>
80106608:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010660b:	83 ec 0c             	sub    $0xc,%esp
8010660e:	50                   	push   %eax
8010660f:	e8 c4 c0 ff ff       	call   801026d8 <namei>
80106614:	83 c4 10             	add    $0x10,%esp
80106617:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010661a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010661e:	75 0c                	jne    8010662c <sys_chdir+0x50>
    end_op();
80106620:	e8 cd d1 ff ff       	call   801037f2 <end_op>
    return -1;
80106625:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010662a:	eb 68                	jmp    80106694 <sys_chdir+0xb8>
  }
  ilock(ip);
8010662c:	83 ec 0c             	sub    $0xc,%esp
8010662f:	ff 75 f0             	pushl  -0x10(%ebp)
80106632:	e8 36 b5 ff ff       	call   80101b6d <ilock>
80106637:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
8010663a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010663d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106641:	66 83 f8 01          	cmp    $0x1,%ax
80106645:	74 1a                	je     80106661 <sys_chdir+0x85>
    iunlockput(ip);
80106647:	83 ec 0c             	sub    $0xc,%esp
8010664a:	ff 75 f0             	pushl  -0x10(%ebp)
8010664d:	e8 58 b7 ff ff       	call   80101daa <iunlockput>
80106652:	83 c4 10             	add    $0x10,%esp
    end_op();
80106655:	e8 98 d1 ff ff       	call   801037f2 <end_op>
    return -1;
8010665a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010665f:	eb 33                	jmp    80106694 <sys_chdir+0xb8>
  }
  iunlock(ip);
80106661:	83 ec 0c             	sub    $0xc,%esp
80106664:	ff 75 f0             	pushl  -0x10(%ebp)
80106667:	e8 18 b6 ff ff       	call   80101c84 <iunlock>
8010666c:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
8010666f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106672:	8b 40 68             	mov    0x68(%eax),%eax
80106675:	83 ec 0c             	sub    $0xc,%esp
80106678:	50                   	push   %eax
80106679:	e8 58 b6 ff ff       	call   80101cd6 <iput>
8010667e:	83 c4 10             	add    $0x10,%esp
  end_op();
80106681:	e8 6c d1 ff ff       	call   801037f2 <end_op>
  curproc->cwd = ip;
80106686:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106689:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010668c:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
8010668f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106694:	c9                   	leave  
80106695:	c3                   	ret    

80106696 <sys_exec>:

int
sys_exec(void)
{
80106696:	f3 0f 1e fb          	endbr32 
8010669a:	55                   	push   %ebp
8010669b:	89 e5                	mov    %esp,%ebp
8010669d:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801066a3:	83 ec 08             	sub    $0x8,%esp
801066a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066a9:	50                   	push   %eax
801066aa:	6a 00                	push   $0x0
801066ac:	e8 58 f3 ff ff       	call   80105a09 <argstr>
801066b1:	83 c4 10             	add    $0x10,%esp
801066b4:	85 c0                	test   %eax,%eax
801066b6:	78 18                	js     801066d0 <sys_exec+0x3a>
801066b8:	83 ec 08             	sub    $0x8,%esp
801066bb:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801066c1:	50                   	push   %eax
801066c2:	6a 01                	push   $0x1
801066c4:	e8 a3 f2 ff ff       	call   8010596c <argint>
801066c9:	83 c4 10             	add    $0x10,%esp
801066cc:	85 c0                	test   %eax,%eax
801066ce:	79 0a                	jns    801066da <sys_exec+0x44>
    return -1;
801066d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066d5:	e9 c6 00 00 00       	jmp    801067a0 <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
801066da:	83 ec 04             	sub    $0x4,%esp
801066dd:	68 80 00 00 00       	push   $0x80
801066e2:	6a 00                	push   $0x0
801066e4:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801066ea:	50                   	push   %eax
801066eb:	e8 28 ef ff ff       	call   80105618 <memset>
801066f0:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801066f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801066fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066fd:	83 f8 1f             	cmp    $0x1f,%eax
80106700:	76 0a                	jbe    8010670c <sys_exec+0x76>
      return -1;
80106702:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106707:	e9 94 00 00 00       	jmp    801067a0 <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010670c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010670f:	c1 e0 02             	shl    $0x2,%eax
80106712:	89 c2                	mov    %eax,%edx
80106714:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010671a:	01 c2                	add    %eax,%edx
8010671c:	83 ec 08             	sub    $0x8,%esp
8010671f:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106725:	50                   	push   %eax
80106726:	52                   	push   %edx
80106727:	e8 95 f1 ff ff       	call   801058c1 <fetchint>
8010672c:	83 c4 10             	add    $0x10,%esp
8010672f:	85 c0                	test   %eax,%eax
80106731:	79 07                	jns    8010673a <sys_exec+0xa4>
      return -1;
80106733:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106738:	eb 66                	jmp    801067a0 <sys_exec+0x10a>
    if(uarg == 0){
8010673a:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106740:	85 c0                	test   %eax,%eax
80106742:	75 27                	jne    8010676b <sys_exec+0xd5>
      argv[i] = 0;
80106744:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106747:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010674e:	00 00 00 00 
      break;
80106752:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106753:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106756:	83 ec 08             	sub    $0x8,%esp
80106759:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010675f:	52                   	push   %edx
80106760:	50                   	push   %eax
80106761:	e8 ca a4 ff ff       	call   80100c30 <exec>
80106766:	83 c4 10             	add    $0x10,%esp
80106769:	eb 35                	jmp    801067a0 <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
8010676b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106771:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106774:	c1 e2 02             	shl    $0x2,%edx
80106777:	01 c2                	add    %eax,%edx
80106779:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010677f:	83 ec 08             	sub    $0x8,%esp
80106782:	52                   	push   %edx
80106783:	50                   	push   %eax
80106784:	e8 7b f1 ff ff       	call   80105904 <fetchstr>
80106789:	83 c4 10             	add    $0x10,%esp
8010678c:	85 c0                	test   %eax,%eax
8010678e:	79 07                	jns    80106797 <sys_exec+0x101>
      return -1;
80106790:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106795:	eb 09                	jmp    801067a0 <sys_exec+0x10a>
  for(i=0;; i++){
80106797:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
8010679b:	e9 5a ff ff ff       	jmp    801066fa <sys_exec+0x64>
}
801067a0:	c9                   	leave  
801067a1:	c3                   	ret    

801067a2 <sys_pipe>:

int
sys_pipe(void)
{
801067a2:	f3 0f 1e fb          	endbr32 
801067a6:	55                   	push   %ebp
801067a7:	89 e5                	mov    %esp,%ebp
801067a9:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801067ac:	83 ec 04             	sub    $0x4,%esp
801067af:	6a 08                	push   $0x8
801067b1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801067b4:	50                   	push   %eax
801067b5:	6a 00                	push   $0x0
801067b7:	e8 e1 f1 ff ff       	call   8010599d <argptr>
801067bc:	83 c4 10             	add    $0x10,%esp
801067bf:	85 c0                	test   %eax,%eax
801067c1:	79 0a                	jns    801067cd <sys_pipe+0x2b>
    return -1;
801067c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067c8:	e9 ae 00 00 00       	jmp    8010687b <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
801067cd:	83 ec 08             	sub    $0x8,%esp
801067d0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801067d3:	50                   	push   %eax
801067d4:	8d 45 e8             	lea    -0x18(%ebp),%eax
801067d7:	50                   	push   %eax
801067d8:	e8 65 d8 ff ff       	call   80104042 <pipealloc>
801067dd:	83 c4 10             	add    $0x10,%esp
801067e0:	85 c0                	test   %eax,%eax
801067e2:	79 0a                	jns    801067ee <sys_pipe+0x4c>
    return -1;
801067e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067e9:	e9 8d 00 00 00       	jmp    8010687b <sys_pipe+0xd9>
  fd0 = -1;
801067ee:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801067f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801067f8:	83 ec 0c             	sub    $0xc,%esp
801067fb:	50                   	push   %eax
801067fc:	e8 3d f3 ff ff       	call   80105b3e <fdalloc>
80106801:	83 c4 10             	add    $0x10,%esp
80106804:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106807:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010680b:	78 18                	js     80106825 <sys_pipe+0x83>
8010680d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106810:	83 ec 0c             	sub    $0xc,%esp
80106813:	50                   	push   %eax
80106814:	e8 25 f3 ff ff       	call   80105b3e <fdalloc>
80106819:	83 c4 10             	add    $0x10,%esp
8010681c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010681f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106823:	79 3e                	jns    80106863 <sys_pipe+0xc1>
    if(fd0 >= 0)
80106825:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106829:	78 13                	js     8010683e <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
8010682b:	e8 f1 dc ff ff       	call   80104521 <myproc>
80106830:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106833:	83 c2 08             	add    $0x8,%edx
80106836:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010683d:	00 
    fileclose(rf);
8010683e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106841:	83 ec 0c             	sub    $0xc,%esp
80106844:	50                   	push   %eax
80106845:	e8 a3 a9 ff ff       	call   801011ed <fileclose>
8010684a:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
8010684d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106850:	83 ec 0c             	sub    $0xc,%esp
80106853:	50                   	push   %eax
80106854:	e8 94 a9 ff ff       	call   801011ed <fileclose>
80106859:	83 c4 10             	add    $0x10,%esp
    return -1;
8010685c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106861:	eb 18                	jmp    8010687b <sys_pipe+0xd9>
  }
  fd[0] = fd0;
80106863:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106866:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106869:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010686b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010686e:	8d 50 04             	lea    0x4(%eax),%edx
80106871:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106874:	89 02                	mov    %eax,(%edx)
  return 0;
80106876:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010687b:	c9                   	leave  
8010687c:	c3                   	ret    

8010687d <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
8010687d:	f3 0f 1e fb          	endbr32 
80106881:	55                   	push   %ebp
80106882:	89 e5                	mov    %esp,%ebp
80106884:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106887:	e8 01 e0 ff ff       	call   8010488d <fork>
}
8010688c:	c9                   	leave  
8010688d:	c3                   	ret    

8010688e <sys_exit>:

int
sys_exit(void)
{
8010688e:	f3 0f 1e fb          	endbr32 
80106892:	55                   	push   %ebp
80106893:	89 e5                	mov    %esp,%ebp
80106895:	83 ec 08             	sub    $0x8,%esp
  exit();
80106898:	e8 18 e2 ff ff       	call   80104ab5 <exit>
  return 0;  // not reached
8010689d:	b8 00 00 00 00       	mov    $0x0,%eax
}
801068a2:	c9                   	leave  
801068a3:	c3                   	ret    

801068a4 <sys_wait>:

int
sys_wait(void)
{
801068a4:	f3 0f 1e fb          	endbr32 
801068a8:	55                   	push   %ebp
801068a9:	89 e5                	mov    %esp,%ebp
801068ab:	83 ec 08             	sub    $0x8,%esp
  return wait();
801068ae:	e8 29 e3 ff ff       	call   80104bdc <wait>
}
801068b3:	c9                   	leave  
801068b4:	c3                   	ret    

801068b5 <sys_kill>:

int
sys_kill(void)
{
801068b5:	f3 0f 1e fb          	endbr32 
801068b9:	55                   	push   %ebp
801068ba:	89 e5                	mov    %esp,%ebp
801068bc:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801068bf:	83 ec 08             	sub    $0x8,%esp
801068c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801068c5:	50                   	push   %eax
801068c6:	6a 00                	push   $0x0
801068c8:	e8 9f f0 ff ff       	call   8010596c <argint>
801068cd:	83 c4 10             	add    $0x10,%esp
801068d0:	85 c0                	test   %eax,%eax
801068d2:	79 07                	jns    801068db <sys_kill+0x26>
    return -1;
801068d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068d9:	eb 0f                	jmp    801068ea <sys_kill+0x35>
  return kill(pid);
801068db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068de:	83 ec 0c             	sub    $0xc,%esp
801068e1:	50                   	push   %eax
801068e2:	e8 4d e7 ff ff       	call   80105034 <kill>
801068e7:	83 c4 10             	add    $0x10,%esp
}
801068ea:	c9                   	leave  
801068eb:	c3                   	ret    

801068ec <sys_getpid>:

int
sys_getpid(void)
{
801068ec:	f3 0f 1e fb          	endbr32 
801068f0:	55                   	push   %ebp
801068f1:	89 e5                	mov    %esp,%ebp
801068f3:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801068f6:	e8 26 dc ff ff       	call   80104521 <myproc>
801068fb:	8b 40 10             	mov    0x10(%eax),%eax
}
801068fe:	c9                   	leave  
801068ff:	c3                   	ret    

80106900 <sys_sbrk>:

int
sys_sbrk(void)
{
80106900:	f3 0f 1e fb          	endbr32 
80106904:	55                   	push   %ebp
80106905:	89 e5                	mov    %esp,%ebp
80106907:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010690a:	83 ec 08             	sub    $0x8,%esp
8010690d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106910:	50                   	push   %eax
80106911:	6a 00                	push   $0x0
80106913:	e8 54 f0 ff ff       	call   8010596c <argint>
80106918:	83 c4 10             	add    $0x10,%esp
8010691b:	85 c0                	test   %eax,%eax
8010691d:	79 07                	jns    80106926 <sys_sbrk+0x26>
    return -1;
8010691f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106924:	eb 27                	jmp    8010694d <sys_sbrk+0x4d>
  addr = myproc()->sz;
80106926:	e8 f6 db ff ff       	call   80104521 <myproc>
8010692b:	8b 00                	mov    (%eax),%eax
8010692d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106930:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106933:	83 ec 0c             	sub    $0xc,%esp
80106936:	50                   	push   %eax
80106937:	e8 5c de ff ff       	call   80104798 <growproc>
8010693c:	83 c4 10             	add    $0x10,%esp
8010693f:	85 c0                	test   %eax,%eax
80106941:	79 07                	jns    8010694a <sys_sbrk+0x4a>
    return -1;
80106943:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106948:	eb 03                	jmp    8010694d <sys_sbrk+0x4d>
  return addr;
8010694a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010694d:	c9                   	leave  
8010694e:	c3                   	ret    

8010694f <sys_sleep>:

int
sys_sleep(void)
{
8010694f:	f3 0f 1e fb          	endbr32 
80106953:	55                   	push   %ebp
80106954:	89 e5                	mov    %esp,%ebp
80106956:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106959:	83 ec 08             	sub    $0x8,%esp
8010695c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010695f:	50                   	push   %eax
80106960:	6a 00                	push   $0x0
80106962:	e8 05 f0 ff ff       	call   8010596c <argint>
80106967:	83 c4 10             	add    $0x10,%esp
8010696a:	85 c0                	test   %eax,%eax
8010696c:	79 07                	jns    80106975 <sys_sleep+0x26>
    return -1;
8010696e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106973:	eb 76                	jmp    801069eb <sys_sleep+0x9c>
  acquire(&tickslock);
80106975:	83 ec 0c             	sub    $0xc,%esp
80106978:	68 00 86 11 80       	push   $0x80118600
8010697d:	e8 f7 e9 ff ff       	call   80105379 <acquire>
80106982:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106985:	a1 40 8e 11 80       	mov    0x80118e40,%eax
8010698a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010698d:	eb 38                	jmp    801069c7 <sys_sleep+0x78>
    if(myproc()->killed){
8010698f:	e8 8d db ff ff       	call   80104521 <myproc>
80106994:	8b 40 24             	mov    0x24(%eax),%eax
80106997:	85 c0                	test   %eax,%eax
80106999:	74 17                	je     801069b2 <sys_sleep+0x63>
      release(&tickslock);
8010699b:	83 ec 0c             	sub    $0xc,%esp
8010699e:	68 00 86 11 80       	push   $0x80118600
801069a3:	e8 43 ea ff ff       	call   801053eb <release>
801069a8:	83 c4 10             	add    $0x10,%esp
      return -1;
801069ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069b0:	eb 39                	jmp    801069eb <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
801069b2:	83 ec 08             	sub    $0x8,%esp
801069b5:	68 00 86 11 80       	push   $0x80118600
801069ba:	68 40 8e 11 80       	push   $0x80118e40
801069bf:	e8 43 e5 ff ff       	call   80104f07 <sleep>
801069c4:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
801069c7:	a1 40 8e 11 80       	mov    0x80118e40,%eax
801069cc:	2b 45 f4             	sub    -0xc(%ebp),%eax
801069cf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801069d2:	39 d0                	cmp    %edx,%eax
801069d4:	72 b9                	jb     8010698f <sys_sleep+0x40>
  }
  release(&tickslock);
801069d6:	83 ec 0c             	sub    $0xc,%esp
801069d9:	68 00 86 11 80       	push   $0x80118600
801069de:	e8 08 ea ff ff       	call   801053eb <release>
801069e3:	83 c4 10             	add    $0x10,%esp
  return 0;
801069e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801069eb:	c9                   	leave  
801069ec:	c3                   	ret    

801069ed <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801069ed:	f3 0f 1e fb          	endbr32 
801069f1:	55                   	push   %ebp
801069f2:	89 e5                	mov    %esp,%ebp
801069f4:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
801069f7:	83 ec 0c             	sub    $0xc,%esp
801069fa:	68 00 86 11 80       	push   $0x80118600
801069ff:	e8 75 e9 ff ff       	call   80105379 <acquire>
80106a04:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106a07:	a1 40 8e 11 80       	mov    0x80118e40,%eax
80106a0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106a0f:	83 ec 0c             	sub    $0xc,%esp
80106a12:	68 00 86 11 80       	push   $0x80118600
80106a17:	e8 cf e9 ff ff       	call   801053eb <release>
80106a1c:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106a22:	c9                   	leave  
80106a23:	c3                   	ret    

80106a24 <sys_mencrypt>:

//changed: added wrapper here
int sys_mencrypt(void) {
80106a24:	f3 0f 1e fb          	endbr32 
80106a28:	55                   	push   %ebp
80106a29:	89 e5                	mov    %esp,%ebp
80106a2b:	83 ec 18             	sub    $0x18,%esp
  int len;
  char * virtual_addr;

  if(argint(1, &len) < 0)
80106a2e:	83 ec 08             	sub    $0x8,%esp
80106a31:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a34:	50                   	push   %eax
80106a35:	6a 01                	push   $0x1
80106a37:	e8 30 ef ff ff       	call   8010596c <argint>
80106a3c:	83 c4 10             	add    $0x10,%esp
80106a3f:	85 c0                	test   %eax,%eax
80106a41:	79 07                	jns    80106a4a <sys_mencrypt+0x26>
    return -1;
80106a43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a48:	eb 50                	jmp    80106a9a <sys_mencrypt+0x76>
  if (len <= 0) {
80106a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a4d:	85 c0                	test   %eax,%eax
80106a4f:	7f 07                	jg     80106a58 <sys_mencrypt+0x34>
    return -1;
80106a51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a56:	eb 42                	jmp    80106a9a <sys_mencrypt+0x76>
  }
  if(argptr(0, &virtual_addr, 1) < 0)
80106a58:	83 ec 04             	sub    $0x4,%esp
80106a5b:	6a 01                	push   $0x1
80106a5d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a60:	50                   	push   %eax
80106a61:	6a 00                	push   $0x0
80106a63:	e8 35 ef ff ff       	call   8010599d <argptr>
80106a68:	83 c4 10             	add    $0x10,%esp
80106a6b:	85 c0                	test   %eax,%eax
80106a6d:	79 07                	jns    80106a76 <sys_mencrypt+0x52>
    return -1;
80106a6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a74:	eb 24                	jmp    80106a9a <sys_mencrypt+0x76>
  if ((void *) virtual_addr >= P2V(PHYSTOP)) {
80106a76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a79:	3d ff ff ff 8d       	cmp    $0x8dffffff,%eax
80106a7e:	76 07                	jbe    80106a87 <sys_mencrypt+0x63>
    return -1;
80106a80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a85:	eb 13                	jmp    80106a9a <sys_mencrypt+0x76>
  }
  return mencrypt(virtual_addr, len);
80106a87:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106a8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a8d:	83 ec 08             	sub    $0x8,%esp
80106a90:	52                   	push   %edx
80106a91:	50                   	push   %eax
80106a92:	e8 56 25 00 00       	call   80108fed <mencrypt>
80106a97:	83 c4 10             	add    $0x10,%esp
}
80106a9a:	c9                   	leave  
80106a9b:	c3                   	ret    

80106a9c <sys_getpgtable>:

int sys_getpgtable(void) {
80106a9c:	f3 0f 1e fb          	endbr32 
80106aa0:	55                   	push   %ebp
80106aa1:	89 e5                	mov    %esp,%ebp
80106aa3:	83 ec 18             	sub    $0x18,%esp
  struct pt_entry * entries; 
  int num,wsetOnly;

  if(argint(1, &num) < 0)
80106aa6:	83 ec 08             	sub    $0x8,%esp
80106aa9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106aac:	50                   	push   %eax
80106aad:	6a 01                	push   $0x1
80106aaf:	e8 b8 ee ff ff       	call   8010596c <argint>
80106ab4:	83 c4 10             	add    $0x10,%esp
80106ab7:	85 c0                	test   %eax,%eax
80106ab9:	79 07                	jns    80106ac2 <sys_getpgtable+0x26>
    return -1;
80106abb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ac0:	eb 56                	jmp    80106b18 <sys_getpgtable+0x7c>
  if(argint(2, &wsetOnly) < 0)
80106ac2:	83 ec 08             	sub    $0x8,%esp
80106ac5:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106ac8:	50                   	push   %eax
80106ac9:	6a 02                	push   $0x2
80106acb:	e8 9c ee ff ff       	call   8010596c <argint>
80106ad0:	83 c4 10             	add    $0x10,%esp
80106ad3:	85 c0                	test   %eax,%eax
80106ad5:	79 07                	jns    80106ade <sys_getpgtable+0x42>
    return -1;
80106ad7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106adc:	eb 3a                	jmp    80106b18 <sys_getpgtable+0x7c>
  if(argptr(0, (char**)&entries, num*sizeof(struct pt_entry)) < 0){
80106ade:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ae1:	c1 e0 03             	shl    $0x3,%eax
80106ae4:	83 ec 04             	sub    $0x4,%esp
80106ae7:	50                   	push   %eax
80106ae8:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106aeb:	50                   	push   %eax
80106aec:	6a 00                	push   $0x0
80106aee:	e8 aa ee ff ff       	call   8010599d <argptr>
80106af3:	83 c4 10             	add    $0x10,%esp
80106af6:	85 c0                	test   %eax,%eax
80106af8:	79 07                	jns    80106b01 <sys_getpgtable+0x65>
    return -1;
80106afa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106aff:	eb 17                	jmp    80106b18 <sys_getpgtable+0x7c>
  }
  return getpgtable(entries, num,wsetOnly);
80106b01:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80106b04:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b0a:	83 ec 04             	sub    $0x4,%esp
80106b0d:	51                   	push   %ecx
80106b0e:	52                   	push   %edx
80106b0f:	50                   	push   %eax
80106b10:	e8 b5 26 00 00       	call   801091ca <getpgtable>
80106b15:	83 c4 10             	add    $0x10,%esp
}
80106b18:	c9                   	leave  
80106b19:	c3                   	ret    

80106b1a <sys_dump_rawphymem>:


int sys_dump_rawphymem(void) {
80106b1a:	f3 0f 1e fb          	endbr32 
80106b1e:	55                   	push   %ebp
80106b1f:	89 e5                	mov    %esp,%ebp
80106b21:	83 ec 18             	sub    $0x18,%esp
  char * physical_addr; 
  char * buffer;
  if(argptr(1, &buffer, PGSIZE) < 0)
80106b24:	83 ec 04             	sub    $0x4,%esp
80106b27:	68 00 10 00 00       	push   $0x1000
80106b2c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b2f:	50                   	push   %eax
80106b30:	6a 01                	push   $0x1
80106b32:	e8 66 ee ff ff       	call   8010599d <argptr>
80106b37:	83 c4 10             	add    $0x10,%esp
80106b3a:	85 c0                	test   %eax,%eax
80106b3c:	79 07                	jns    80106b45 <sys_dump_rawphymem+0x2b>
    return -1;
80106b3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b43:	eb 2f                	jmp    80106b74 <sys_dump_rawphymem+0x5a>
  if(argint(0, (int*)&physical_addr) < 0)
80106b45:	83 ec 08             	sub    $0x8,%esp
80106b48:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106b4b:	50                   	push   %eax
80106b4c:	6a 00                	push   $0x0
80106b4e:	e8 19 ee ff ff       	call   8010596c <argint>
80106b53:	83 c4 10             	add    $0x10,%esp
80106b56:	85 c0                	test   %eax,%eax
80106b58:	79 07                	jns    80106b61 <sys_dump_rawphymem+0x47>
    return -1;
80106b5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b5f:	eb 13                	jmp    80106b74 <sys_dump_rawphymem+0x5a>
  return dump_rawphymem(physical_addr, buffer);
80106b61:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b67:	83 ec 08             	sub    $0x8,%esp
80106b6a:	52                   	push   %edx
80106b6b:	50                   	push   %eax
80106b6c:	e8 c7 28 00 00       	call   80109438 <dump_rawphymem>
80106b71:	83 c4 10             	add    $0x10,%esp
80106b74:	c9                   	leave  
80106b75:	c3                   	ret    

80106b76 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106b76:	1e                   	push   %ds
  pushl %es
80106b77:	06                   	push   %es
  pushl %fs
80106b78:	0f a0                	push   %fs
  pushl %gs
80106b7a:	0f a8                	push   %gs
  pushal
80106b7c:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106b7d:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106b81:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106b83:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106b85:	54                   	push   %esp
  call trap
80106b86:	e8 df 01 00 00       	call   80106d6a <trap>
  addl $4, %esp
80106b8b:	83 c4 04             	add    $0x4,%esp

80106b8e <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106b8e:	61                   	popa   
  popl %gs
80106b8f:	0f a9                	pop    %gs
  popl %fs
80106b91:	0f a1                	pop    %fs
  popl %es
80106b93:	07                   	pop    %es
  popl %ds
80106b94:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106b95:	83 c4 08             	add    $0x8,%esp
  iret
80106b98:	cf                   	iret   

80106b99 <lidt>:
{
80106b99:	55                   	push   %ebp
80106b9a:	89 e5                	mov    %esp,%ebp
80106b9c:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106b9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ba2:	83 e8 01             	sub    $0x1,%eax
80106ba5:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106ba9:	8b 45 08             	mov    0x8(%ebp),%eax
80106bac:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106bb0:	8b 45 08             	mov    0x8(%ebp),%eax
80106bb3:	c1 e8 10             	shr    $0x10,%eax
80106bb6:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106bba:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106bbd:	0f 01 18             	lidtl  (%eax)
}
80106bc0:	90                   	nop
80106bc1:	c9                   	leave  
80106bc2:	c3                   	ret    

80106bc3 <rcr2>:

static inline uint
rcr2(void)
{
80106bc3:	55                   	push   %ebp
80106bc4:	89 e5                	mov    %esp,%ebp
80106bc6:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106bc9:	0f 20 d0             	mov    %cr2,%eax
80106bcc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106bcf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106bd2:	c9                   	leave  
80106bd3:	c3                   	ret    

80106bd4 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106bd4:	f3 0f 1e fb          	endbr32 
80106bd8:	55                   	push   %ebp
80106bd9:	89 e5                	mov    %esp,%ebp
80106bdb:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106bde:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106be5:	e9 c3 00 00 00       	jmp    80106cad <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bed:	8b 04 85 84 d0 10 80 	mov    -0x7fef2f7c(,%eax,4),%eax
80106bf4:	89 c2                	mov    %eax,%edx
80106bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bf9:	66 89 14 c5 40 86 11 	mov    %dx,-0x7fee79c0(,%eax,8)
80106c00:	80 
80106c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c04:	66 c7 04 c5 42 86 11 	movw   $0x8,-0x7fee79be(,%eax,8)
80106c0b:	80 08 00 
80106c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c11:	0f b6 14 c5 44 86 11 	movzbl -0x7fee79bc(,%eax,8),%edx
80106c18:	80 
80106c19:	83 e2 e0             	and    $0xffffffe0,%edx
80106c1c:	88 14 c5 44 86 11 80 	mov    %dl,-0x7fee79bc(,%eax,8)
80106c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c26:	0f b6 14 c5 44 86 11 	movzbl -0x7fee79bc(,%eax,8),%edx
80106c2d:	80 
80106c2e:	83 e2 1f             	and    $0x1f,%edx
80106c31:	88 14 c5 44 86 11 80 	mov    %dl,-0x7fee79bc(,%eax,8)
80106c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c3b:	0f b6 14 c5 45 86 11 	movzbl -0x7fee79bb(,%eax,8),%edx
80106c42:	80 
80106c43:	83 e2 f0             	and    $0xfffffff0,%edx
80106c46:	83 ca 0e             	or     $0xe,%edx
80106c49:	88 14 c5 45 86 11 80 	mov    %dl,-0x7fee79bb(,%eax,8)
80106c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c53:	0f b6 14 c5 45 86 11 	movzbl -0x7fee79bb(,%eax,8),%edx
80106c5a:	80 
80106c5b:	83 e2 ef             	and    $0xffffffef,%edx
80106c5e:	88 14 c5 45 86 11 80 	mov    %dl,-0x7fee79bb(,%eax,8)
80106c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c68:	0f b6 14 c5 45 86 11 	movzbl -0x7fee79bb(,%eax,8),%edx
80106c6f:	80 
80106c70:	83 e2 9f             	and    $0xffffff9f,%edx
80106c73:	88 14 c5 45 86 11 80 	mov    %dl,-0x7fee79bb(,%eax,8)
80106c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c7d:	0f b6 14 c5 45 86 11 	movzbl -0x7fee79bb(,%eax,8),%edx
80106c84:	80 
80106c85:	83 ca 80             	or     $0xffffff80,%edx
80106c88:	88 14 c5 45 86 11 80 	mov    %dl,-0x7fee79bb(,%eax,8)
80106c8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c92:	8b 04 85 84 d0 10 80 	mov    -0x7fef2f7c(,%eax,4),%eax
80106c99:	c1 e8 10             	shr    $0x10,%eax
80106c9c:	89 c2                	mov    %eax,%edx
80106c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ca1:	66 89 14 c5 46 86 11 	mov    %dx,-0x7fee79ba(,%eax,8)
80106ca8:	80 
  for(i = 0; i < 256; i++)
80106ca9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106cad:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106cb4:	0f 8e 30 ff ff ff    	jle    80106bea <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106cba:	a1 84 d1 10 80       	mov    0x8010d184,%eax
80106cbf:	66 a3 40 88 11 80    	mov    %ax,0x80118840
80106cc5:	66 c7 05 42 88 11 80 	movw   $0x8,0x80118842
80106ccc:	08 00 
80106cce:	0f b6 05 44 88 11 80 	movzbl 0x80118844,%eax
80106cd5:	83 e0 e0             	and    $0xffffffe0,%eax
80106cd8:	a2 44 88 11 80       	mov    %al,0x80118844
80106cdd:	0f b6 05 44 88 11 80 	movzbl 0x80118844,%eax
80106ce4:	83 e0 1f             	and    $0x1f,%eax
80106ce7:	a2 44 88 11 80       	mov    %al,0x80118844
80106cec:	0f b6 05 45 88 11 80 	movzbl 0x80118845,%eax
80106cf3:	83 c8 0f             	or     $0xf,%eax
80106cf6:	a2 45 88 11 80       	mov    %al,0x80118845
80106cfb:	0f b6 05 45 88 11 80 	movzbl 0x80118845,%eax
80106d02:	83 e0 ef             	and    $0xffffffef,%eax
80106d05:	a2 45 88 11 80       	mov    %al,0x80118845
80106d0a:	0f b6 05 45 88 11 80 	movzbl 0x80118845,%eax
80106d11:	83 c8 60             	or     $0x60,%eax
80106d14:	a2 45 88 11 80       	mov    %al,0x80118845
80106d19:	0f b6 05 45 88 11 80 	movzbl 0x80118845,%eax
80106d20:	83 c8 80             	or     $0xffffff80,%eax
80106d23:	a2 45 88 11 80       	mov    %al,0x80118845
80106d28:	a1 84 d1 10 80       	mov    0x8010d184,%eax
80106d2d:	c1 e8 10             	shr    $0x10,%eax
80106d30:	66 a3 46 88 11 80    	mov    %ax,0x80118846

  initlock(&tickslock, "time");
80106d36:	83 ec 08             	sub    $0x8,%esp
80106d39:	68 24 9a 10 80       	push   $0x80109a24
80106d3e:	68 00 86 11 80       	push   $0x80118600
80106d43:	e8 0b e6 ff ff       	call   80105353 <initlock>
80106d48:	83 c4 10             	add    $0x10,%esp
}
80106d4b:	90                   	nop
80106d4c:	c9                   	leave  
80106d4d:	c3                   	ret    

80106d4e <idtinit>:

void
idtinit(void)
{
80106d4e:	f3 0f 1e fb          	endbr32 
80106d52:	55                   	push   %ebp
80106d53:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106d55:	68 00 08 00 00       	push   $0x800
80106d5a:	68 40 86 11 80       	push   $0x80118640
80106d5f:	e8 35 fe ff ff       	call   80106b99 <lidt>
80106d64:	83 c4 08             	add    $0x8,%esp
}
80106d67:	90                   	nop
80106d68:	c9                   	leave  
80106d69:	c3                   	ret    

80106d6a <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106d6a:	f3 0f 1e fb          	endbr32 
80106d6e:	55                   	push   %ebp
80106d6f:	89 e5                	mov    %esp,%ebp
80106d71:	57                   	push   %edi
80106d72:	56                   	push   %esi
80106d73:	53                   	push   %ebx
80106d74:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80106d77:	8b 45 08             	mov    0x8(%ebp),%eax
80106d7a:	8b 40 30             	mov    0x30(%eax),%eax
80106d7d:	83 f8 40             	cmp    $0x40,%eax
80106d80:	75 3b                	jne    80106dbd <trap+0x53>
    if(myproc()->killed)
80106d82:	e8 9a d7 ff ff       	call   80104521 <myproc>
80106d87:	8b 40 24             	mov    0x24(%eax),%eax
80106d8a:	85 c0                	test   %eax,%eax
80106d8c:	74 05                	je     80106d93 <trap+0x29>
      exit();
80106d8e:	e8 22 dd ff ff       	call   80104ab5 <exit>
    myproc()->tf = tf;
80106d93:	e8 89 d7 ff ff       	call   80104521 <myproc>
80106d98:	8b 55 08             	mov    0x8(%ebp),%edx
80106d9b:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106d9e:	e8 a1 ec ff ff       	call   80105a44 <syscall>
    if(myproc()->killed)
80106da3:	e8 79 d7 ff ff       	call   80104521 <myproc>
80106da8:	8b 40 24             	mov    0x24(%eax),%eax
80106dab:	85 c0                	test   %eax,%eax
80106dad:	0f 84 42 02 00 00    	je     80106ff5 <trap+0x28b>
      exit();
80106db3:	e8 fd dc ff ff       	call   80104ab5 <exit>
    return;
80106db8:	e9 38 02 00 00       	jmp    80106ff5 <trap+0x28b>
  }
  char *addr;
  switch(tf->trapno){
80106dbd:	8b 45 08             	mov    0x8(%ebp),%eax
80106dc0:	8b 40 30             	mov    0x30(%eax),%eax
80106dc3:	83 e8 0e             	sub    $0xe,%eax
80106dc6:	83 f8 31             	cmp    $0x31,%eax
80106dc9:	0f 87 ee 00 00 00    	ja     80106ebd <trap+0x153>
80106dcf:	8b 04 85 e4 9a 10 80 	mov    -0x7fef651c(,%eax,4),%eax
80106dd6:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106dd9:	e8 a8 d6 ff ff       	call   80104486 <cpuid>
80106dde:	85 c0                	test   %eax,%eax
80106de0:	75 3d                	jne    80106e1f <trap+0xb5>
      acquire(&tickslock);
80106de2:	83 ec 0c             	sub    $0xc,%esp
80106de5:	68 00 86 11 80       	push   $0x80118600
80106dea:	e8 8a e5 ff ff       	call   80105379 <acquire>
80106def:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106df2:	a1 40 8e 11 80       	mov    0x80118e40,%eax
80106df7:	83 c0 01             	add    $0x1,%eax
80106dfa:	a3 40 8e 11 80       	mov    %eax,0x80118e40
      wakeup(&ticks);
80106dff:	83 ec 0c             	sub    $0xc,%esp
80106e02:	68 40 8e 11 80       	push   $0x80118e40
80106e07:	e8 ed e1 ff ff       	call   80104ff9 <wakeup>
80106e0c:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106e0f:	83 ec 0c             	sub    $0xc,%esp
80106e12:	68 00 86 11 80       	push   $0x80118600
80106e17:	e8 cf e5 ff ff       	call   801053eb <release>
80106e1c:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106e1f:	e8 f2 c3 ff ff       	call   80103216 <lapiceoi>
    break;
80106e24:	e9 4c 01 00 00       	jmp    80106f75 <trap+0x20b>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106e29:	e8 f7 bb ff ff       	call   80102a25 <ideintr>
    lapiceoi();
80106e2e:	e8 e3 c3 ff ff       	call   80103216 <lapiceoi>
    break;
80106e33:	e9 3d 01 00 00       	jmp    80106f75 <trap+0x20b>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106e38:	e8 0f c2 ff ff       	call   8010304c <kbdintr>
    lapiceoi();
80106e3d:	e8 d4 c3 ff ff       	call   80103216 <lapiceoi>
    break;
80106e42:	e9 2e 01 00 00       	jmp    80106f75 <trap+0x20b>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106e47:	e8 8b 03 00 00       	call   801071d7 <uartintr>
    lapiceoi();
80106e4c:	e8 c5 c3 ff ff       	call   80103216 <lapiceoi>
    break;
80106e51:	e9 1f 01 00 00       	jmp    80106f75 <trap+0x20b>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106e56:	8b 45 08             	mov    0x8(%ebp),%eax
80106e59:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106e5c:	8b 45 08             	mov    0x8(%ebp),%eax
80106e5f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106e63:	0f b7 d8             	movzwl %ax,%ebx
80106e66:	e8 1b d6 ff ff       	call   80104486 <cpuid>
80106e6b:	56                   	push   %esi
80106e6c:	53                   	push   %ebx
80106e6d:	50                   	push   %eax
80106e6e:	68 2c 9a 10 80       	push   $0x80109a2c
80106e73:	e8 a0 95 ff ff       	call   80100418 <cprintf>
80106e78:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106e7b:	e8 96 c3 ff ff       	call   80103216 <lapiceoi>
    break;
80106e80:	e9 f0 00 00 00       	jmp    80106f75 <trap+0x20b>
  case T_PGFLT:
    //Food for thought: How can one distinguish between a regular page fault and a decryption request?
    cprintf("p4Debug : Page fault !\n");
80106e85:	83 ec 0c             	sub    $0xc,%esp
80106e88:	68 50 9a 10 80       	push   $0x80109a50
80106e8d:	e8 86 95 ff ff       	call   80100418 <cprintf>
80106e92:	83 c4 10             	add    $0x10,%esp
    addr = (char*)rcr2();
80106e95:	e8 29 fd ff ff       	call   80106bc3 <rcr2>
80106e9a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (mdecrypt(addr))
80106e9d:	83 ec 0c             	sub    $0xc,%esp
80106ea0:	ff 75 e4             	pushl  -0x1c(%ebp)
80106ea3:	e8 d4 1e 00 00       	call   80108d7c <mdecrypt>
80106ea8:	83 c4 10             	add    $0x10,%esp
80106eab:	85 c0                	test   %eax,%eax
80106ead:	0f 84 c1 00 00 00    	je     80106f74 <trap+0x20a>
    {
        //panic("p4Debug: Memory fault");
        exit();
80106eb3:	e8 fd db ff ff       	call   80104ab5 <exit>
    };
    break;
80106eb8:	e9 b7 00 00 00       	jmp    80106f74 <trap+0x20a>
  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106ebd:	e8 5f d6 ff ff       	call   80104521 <myproc>
80106ec2:	85 c0                	test   %eax,%eax
80106ec4:	74 11                	je     80106ed7 <trap+0x16d>
80106ec6:	8b 45 08             	mov    0x8(%ebp),%eax
80106ec9:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106ecd:	0f b7 c0             	movzwl %ax,%eax
80106ed0:	83 e0 03             	and    $0x3,%eax
80106ed3:	85 c0                	test   %eax,%eax
80106ed5:	75 39                	jne    80106f10 <trap+0x1a6>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106ed7:	e8 e7 fc ff ff       	call   80106bc3 <rcr2>
80106edc:	89 c3                	mov    %eax,%ebx
80106ede:	8b 45 08             	mov    0x8(%ebp),%eax
80106ee1:	8b 70 38             	mov    0x38(%eax),%esi
80106ee4:	e8 9d d5 ff ff       	call   80104486 <cpuid>
80106ee9:	8b 55 08             	mov    0x8(%ebp),%edx
80106eec:	8b 52 30             	mov    0x30(%edx),%edx
80106eef:	83 ec 0c             	sub    $0xc,%esp
80106ef2:	53                   	push   %ebx
80106ef3:	56                   	push   %esi
80106ef4:	50                   	push   %eax
80106ef5:	52                   	push   %edx
80106ef6:	68 68 9a 10 80       	push   $0x80109a68
80106efb:	e8 18 95 ff ff       	call   80100418 <cprintf>
80106f00:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106f03:	83 ec 0c             	sub    $0xc,%esp
80106f06:	68 9a 9a 10 80       	push   $0x80109a9a
80106f0b:	e8 f8 96 ff ff       	call   80100608 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106f10:	e8 ae fc ff ff       	call   80106bc3 <rcr2>
80106f15:	89 c6                	mov    %eax,%esi
80106f17:	8b 45 08             	mov    0x8(%ebp),%eax
80106f1a:	8b 40 38             	mov    0x38(%eax),%eax
80106f1d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106f20:	e8 61 d5 ff ff       	call   80104486 <cpuid>
80106f25:	89 c3                	mov    %eax,%ebx
80106f27:	8b 45 08             	mov    0x8(%ebp),%eax
80106f2a:	8b 48 34             	mov    0x34(%eax),%ecx
80106f2d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106f30:	8b 45 08             	mov    0x8(%ebp),%eax
80106f33:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106f36:	e8 e6 d5 ff ff       	call   80104521 <myproc>
80106f3b:	8d 50 6c             	lea    0x6c(%eax),%edx
80106f3e:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106f41:	e8 db d5 ff ff       	call   80104521 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106f46:	8b 40 10             	mov    0x10(%eax),%eax
80106f49:	56                   	push   %esi
80106f4a:	ff 75 d4             	pushl  -0x2c(%ebp)
80106f4d:	53                   	push   %ebx
80106f4e:	ff 75 d0             	pushl  -0x30(%ebp)
80106f51:	57                   	push   %edi
80106f52:	ff 75 cc             	pushl  -0x34(%ebp)
80106f55:	50                   	push   %eax
80106f56:	68 a0 9a 10 80       	push   $0x80109aa0
80106f5b:	e8 b8 94 ff ff       	call   80100418 <cprintf>
80106f60:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106f63:	e8 b9 d5 ff ff       	call   80104521 <myproc>
80106f68:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106f6f:	eb 04                	jmp    80106f75 <trap+0x20b>
    break;
80106f71:	90                   	nop
80106f72:	eb 01                	jmp    80106f75 <trap+0x20b>
    break;
80106f74:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106f75:	e8 a7 d5 ff ff       	call   80104521 <myproc>
80106f7a:	85 c0                	test   %eax,%eax
80106f7c:	74 23                	je     80106fa1 <trap+0x237>
80106f7e:	e8 9e d5 ff ff       	call   80104521 <myproc>
80106f83:	8b 40 24             	mov    0x24(%eax),%eax
80106f86:	85 c0                	test   %eax,%eax
80106f88:	74 17                	je     80106fa1 <trap+0x237>
80106f8a:	8b 45 08             	mov    0x8(%ebp),%eax
80106f8d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106f91:	0f b7 c0             	movzwl %ax,%eax
80106f94:	83 e0 03             	and    $0x3,%eax
80106f97:	83 f8 03             	cmp    $0x3,%eax
80106f9a:	75 05                	jne    80106fa1 <trap+0x237>
    exit();
80106f9c:	e8 14 db ff ff       	call   80104ab5 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106fa1:	e8 7b d5 ff ff       	call   80104521 <myproc>
80106fa6:	85 c0                	test   %eax,%eax
80106fa8:	74 1d                	je     80106fc7 <trap+0x25d>
80106faa:	e8 72 d5 ff ff       	call   80104521 <myproc>
80106faf:	8b 40 0c             	mov    0xc(%eax),%eax
80106fb2:	83 f8 04             	cmp    $0x4,%eax
80106fb5:	75 10                	jne    80106fc7 <trap+0x25d>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106fb7:	8b 45 08             	mov    0x8(%ebp),%eax
80106fba:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106fbd:	83 f8 20             	cmp    $0x20,%eax
80106fc0:	75 05                	jne    80106fc7 <trap+0x25d>
    yield();
80106fc2:	e8 b8 de ff ff       	call   80104e7f <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106fc7:	e8 55 d5 ff ff       	call   80104521 <myproc>
80106fcc:	85 c0                	test   %eax,%eax
80106fce:	74 26                	je     80106ff6 <trap+0x28c>
80106fd0:	e8 4c d5 ff ff       	call   80104521 <myproc>
80106fd5:	8b 40 24             	mov    0x24(%eax),%eax
80106fd8:	85 c0                	test   %eax,%eax
80106fda:	74 1a                	je     80106ff6 <trap+0x28c>
80106fdc:	8b 45 08             	mov    0x8(%ebp),%eax
80106fdf:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106fe3:	0f b7 c0             	movzwl %ax,%eax
80106fe6:	83 e0 03             	and    $0x3,%eax
80106fe9:	83 f8 03             	cmp    $0x3,%eax
80106fec:	75 08                	jne    80106ff6 <trap+0x28c>
    exit();
80106fee:	e8 c2 da ff ff       	call   80104ab5 <exit>
80106ff3:	eb 01                	jmp    80106ff6 <trap+0x28c>
    return;
80106ff5:	90                   	nop
}
80106ff6:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106ff9:	5b                   	pop    %ebx
80106ffa:	5e                   	pop    %esi
80106ffb:	5f                   	pop    %edi
80106ffc:	5d                   	pop    %ebp
80106ffd:	c3                   	ret    

80106ffe <inb>:
{
80106ffe:	55                   	push   %ebp
80106fff:	89 e5                	mov    %esp,%ebp
80107001:	83 ec 14             	sub    $0x14,%esp
80107004:	8b 45 08             	mov    0x8(%ebp),%eax
80107007:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010700b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010700f:	89 c2                	mov    %eax,%edx
80107011:	ec                   	in     (%dx),%al
80107012:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107015:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107019:	c9                   	leave  
8010701a:	c3                   	ret    

8010701b <outb>:
{
8010701b:	55                   	push   %ebp
8010701c:	89 e5                	mov    %esp,%ebp
8010701e:	83 ec 08             	sub    $0x8,%esp
80107021:	8b 45 08             	mov    0x8(%ebp),%eax
80107024:	8b 55 0c             	mov    0xc(%ebp),%edx
80107027:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010702b:	89 d0                	mov    %edx,%eax
8010702d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107030:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107034:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107038:	ee                   	out    %al,(%dx)
}
80107039:	90                   	nop
8010703a:	c9                   	leave  
8010703b:	c3                   	ret    

8010703c <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010703c:	f3 0f 1e fb          	endbr32 
80107040:	55                   	push   %ebp
80107041:	89 e5                	mov    %esp,%ebp
80107043:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107046:	6a 00                	push   $0x0
80107048:	68 fa 03 00 00       	push   $0x3fa
8010704d:	e8 c9 ff ff ff       	call   8010701b <outb>
80107052:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107055:	68 80 00 00 00       	push   $0x80
8010705a:	68 fb 03 00 00       	push   $0x3fb
8010705f:	e8 b7 ff ff ff       	call   8010701b <outb>
80107064:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107067:	6a 0c                	push   $0xc
80107069:	68 f8 03 00 00       	push   $0x3f8
8010706e:	e8 a8 ff ff ff       	call   8010701b <outb>
80107073:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107076:	6a 00                	push   $0x0
80107078:	68 f9 03 00 00       	push   $0x3f9
8010707d:	e8 99 ff ff ff       	call   8010701b <outb>
80107082:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107085:	6a 03                	push   $0x3
80107087:	68 fb 03 00 00       	push   $0x3fb
8010708c:	e8 8a ff ff ff       	call   8010701b <outb>
80107091:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107094:	6a 00                	push   $0x0
80107096:	68 fc 03 00 00       	push   $0x3fc
8010709b:	e8 7b ff ff ff       	call   8010701b <outb>
801070a0:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801070a3:	6a 01                	push   $0x1
801070a5:	68 f9 03 00 00       	push   $0x3f9
801070aa:	e8 6c ff ff ff       	call   8010701b <outb>
801070af:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801070b2:	68 fd 03 00 00       	push   $0x3fd
801070b7:	e8 42 ff ff ff       	call   80106ffe <inb>
801070bc:	83 c4 04             	add    $0x4,%esp
801070bf:	3c ff                	cmp    $0xff,%al
801070c1:	74 61                	je     80107124 <uartinit+0xe8>
    return;
  uart = 1;
801070c3:	c7 05 44 d6 10 80 01 	movl   $0x1,0x8010d644
801070ca:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801070cd:	68 fa 03 00 00       	push   $0x3fa
801070d2:	e8 27 ff ff ff       	call   80106ffe <inb>
801070d7:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801070da:	68 f8 03 00 00       	push   $0x3f8
801070df:	e8 1a ff ff ff       	call   80106ffe <inb>
801070e4:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
801070e7:	83 ec 08             	sub    $0x8,%esp
801070ea:	6a 00                	push   $0x0
801070ec:	6a 04                	push   $0x4
801070ee:	e8 e4 bb ff ff       	call   80102cd7 <ioapicenable>
801070f3:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801070f6:	c7 45 f4 ac 9b 10 80 	movl   $0x80109bac,-0xc(%ebp)
801070fd:	eb 19                	jmp    80107118 <uartinit+0xdc>
    uartputc(*p);
801070ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107102:	0f b6 00             	movzbl (%eax),%eax
80107105:	0f be c0             	movsbl %al,%eax
80107108:	83 ec 0c             	sub    $0xc,%esp
8010710b:	50                   	push   %eax
8010710c:	e8 16 00 00 00       	call   80107127 <uartputc>
80107111:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80107114:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107118:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010711b:	0f b6 00             	movzbl (%eax),%eax
8010711e:	84 c0                	test   %al,%al
80107120:	75 dd                	jne    801070ff <uartinit+0xc3>
80107122:	eb 01                	jmp    80107125 <uartinit+0xe9>
    return;
80107124:	90                   	nop
}
80107125:	c9                   	leave  
80107126:	c3                   	ret    

80107127 <uartputc>:

void
uartputc(int c)
{
80107127:	f3 0f 1e fb          	endbr32 
8010712b:	55                   	push   %ebp
8010712c:	89 e5                	mov    %esp,%ebp
8010712e:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80107131:	a1 44 d6 10 80       	mov    0x8010d644,%eax
80107136:	85 c0                	test   %eax,%eax
80107138:	74 53                	je     8010718d <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010713a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107141:	eb 11                	jmp    80107154 <uartputc+0x2d>
    microdelay(10);
80107143:	83 ec 0c             	sub    $0xc,%esp
80107146:	6a 0a                	push   $0xa
80107148:	e8 e8 c0 ff ff       	call   80103235 <microdelay>
8010714d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107150:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107154:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107158:	7f 1a                	jg     80107174 <uartputc+0x4d>
8010715a:	83 ec 0c             	sub    $0xc,%esp
8010715d:	68 fd 03 00 00       	push   $0x3fd
80107162:	e8 97 fe ff ff       	call   80106ffe <inb>
80107167:	83 c4 10             	add    $0x10,%esp
8010716a:	0f b6 c0             	movzbl %al,%eax
8010716d:	83 e0 20             	and    $0x20,%eax
80107170:	85 c0                	test   %eax,%eax
80107172:	74 cf                	je     80107143 <uartputc+0x1c>
  outb(COM1+0, c);
80107174:	8b 45 08             	mov    0x8(%ebp),%eax
80107177:	0f b6 c0             	movzbl %al,%eax
8010717a:	83 ec 08             	sub    $0x8,%esp
8010717d:	50                   	push   %eax
8010717e:	68 f8 03 00 00       	push   $0x3f8
80107183:	e8 93 fe ff ff       	call   8010701b <outb>
80107188:	83 c4 10             	add    $0x10,%esp
8010718b:	eb 01                	jmp    8010718e <uartputc+0x67>
    return;
8010718d:	90                   	nop
}
8010718e:	c9                   	leave  
8010718f:	c3                   	ret    

80107190 <uartgetc>:

static int
uartgetc(void)
{
80107190:	f3 0f 1e fb          	endbr32 
80107194:	55                   	push   %ebp
80107195:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107197:	a1 44 d6 10 80       	mov    0x8010d644,%eax
8010719c:	85 c0                	test   %eax,%eax
8010719e:	75 07                	jne    801071a7 <uartgetc+0x17>
    return -1;
801071a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071a5:	eb 2e                	jmp    801071d5 <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
801071a7:	68 fd 03 00 00       	push   $0x3fd
801071ac:	e8 4d fe ff ff       	call   80106ffe <inb>
801071b1:	83 c4 04             	add    $0x4,%esp
801071b4:	0f b6 c0             	movzbl %al,%eax
801071b7:	83 e0 01             	and    $0x1,%eax
801071ba:	85 c0                	test   %eax,%eax
801071bc:	75 07                	jne    801071c5 <uartgetc+0x35>
    return -1;
801071be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071c3:	eb 10                	jmp    801071d5 <uartgetc+0x45>
  return inb(COM1+0);
801071c5:	68 f8 03 00 00       	push   $0x3f8
801071ca:	e8 2f fe ff ff       	call   80106ffe <inb>
801071cf:	83 c4 04             	add    $0x4,%esp
801071d2:	0f b6 c0             	movzbl %al,%eax
}
801071d5:	c9                   	leave  
801071d6:	c3                   	ret    

801071d7 <uartintr>:

void
uartintr(void)
{
801071d7:	f3 0f 1e fb          	endbr32 
801071db:	55                   	push   %ebp
801071dc:	89 e5                	mov    %esp,%ebp
801071de:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
801071e1:	83 ec 0c             	sub    $0xc,%esp
801071e4:	68 90 71 10 80       	push   $0x80107190
801071e9:	e8 ba 96 ff ff       	call   801008a8 <consoleintr>
801071ee:	83 c4 10             	add    $0x10,%esp
}
801071f1:	90                   	nop
801071f2:	c9                   	leave  
801071f3:	c3                   	ret    

801071f4 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801071f4:	6a 00                	push   $0x0
  pushl $0
801071f6:	6a 00                	push   $0x0
  jmp alltraps
801071f8:	e9 79 f9 ff ff       	jmp    80106b76 <alltraps>

801071fd <vector1>:
.globl vector1
vector1:
  pushl $0
801071fd:	6a 00                	push   $0x0
  pushl $1
801071ff:	6a 01                	push   $0x1
  jmp alltraps
80107201:	e9 70 f9 ff ff       	jmp    80106b76 <alltraps>

80107206 <vector2>:
.globl vector2
vector2:
  pushl $0
80107206:	6a 00                	push   $0x0
  pushl $2
80107208:	6a 02                	push   $0x2
  jmp alltraps
8010720a:	e9 67 f9 ff ff       	jmp    80106b76 <alltraps>

8010720f <vector3>:
.globl vector3
vector3:
  pushl $0
8010720f:	6a 00                	push   $0x0
  pushl $3
80107211:	6a 03                	push   $0x3
  jmp alltraps
80107213:	e9 5e f9 ff ff       	jmp    80106b76 <alltraps>

80107218 <vector4>:
.globl vector4
vector4:
  pushl $0
80107218:	6a 00                	push   $0x0
  pushl $4
8010721a:	6a 04                	push   $0x4
  jmp alltraps
8010721c:	e9 55 f9 ff ff       	jmp    80106b76 <alltraps>

80107221 <vector5>:
.globl vector5
vector5:
  pushl $0
80107221:	6a 00                	push   $0x0
  pushl $5
80107223:	6a 05                	push   $0x5
  jmp alltraps
80107225:	e9 4c f9 ff ff       	jmp    80106b76 <alltraps>

8010722a <vector6>:
.globl vector6
vector6:
  pushl $0
8010722a:	6a 00                	push   $0x0
  pushl $6
8010722c:	6a 06                	push   $0x6
  jmp alltraps
8010722e:	e9 43 f9 ff ff       	jmp    80106b76 <alltraps>

80107233 <vector7>:
.globl vector7
vector7:
  pushl $0
80107233:	6a 00                	push   $0x0
  pushl $7
80107235:	6a 07                	push   $0x7
  jmp alltraps
80107237:	e9 3a f9 ff ff       	jmp    80106b76 <alltraps>

8010723c <vector8>:
.globl vector8
vector8:
  pushl $8
8010723c:	6a 08                	push   $0x8
  jmp alltraps
8010723e:	e9 33 f9 ff ff       	jmp    80106b76 <alltraps>

80107243 <vector9>:
.globl vector9
vector9:
  pushl $0
80107243:	6a 00                	push   $0x0
  pushl $9
80107245:	6a 09                	push   $0x9
  jmp alltraps
80107247:	e9 2a f9 ff ff       	jmp    80106b76 <alltraps>

8010724c <vector10>:
.globl vector10
vector10:
  pushl $10
8010724c:	6a 0a                	push   $0xa
  jmp alltraps
8010724e:	e9 23 f9 ff ff       	jmp    80106b76 <alltraps>

80107253 <vector11>:
.globl vector11
vector11:
  pushl $11
80107253:	6a 0b                	push   $0xb
  jmp alltraps
80107255:	e9 1c f9 ff ff       	jmp    80106b76 <alltraps>

8010725a <vector12>:
.globl vector12
vector12:
  pushl $12
8010725a:	6a 0c                	push   $0xc
  jmp alltraps
8010725c:	e9 15 f9 ff ff       	jmp    80106b76 <alltraps>

80107261 <vector13>:
.globl vector13
vector13:
  pushl $13
80107261:	6a 0d                	push   $0xd
  jmp alltraps
80107263:	e9 0e f9 ff ff       	jmp    80106b76 <alltraps>

80107268 <vector14>:
.globl vector14
vector14:
  pushl $14
80107268:	6a 0e                	push   $0xe
  jmp alltraps
8010726a:	e9 07 f9 ff ff       	jmp    80106b76 <alltraps>

8010726f <vector15>:
.globl vector15
vector15:
  pushl $0
8010726f:	6a 00                	push   $0x0
  pushl $15
80107271:	6a 0f                	push   $0xf
  jmp alltraps
80107273:	e9 fe f8 ff ff       	jmp    80106b76 <alltraps>

80107278 <vector16>:
.globl vector16
vector16:
  pushl $0
80107278:	6a 00                	push   $0x0
  pushl $16
8010727a:	6a 10                	push   $0x10
  jmp alltraps
8010727c:	e9 f5 f8 ff ff       	jmp    80106b76 <alltraps>

80107281 <vector17>:
.globl vector17
vector17:
  pushl $17
80107281:	6a 11                	push   $0x11
  jmp alltraps
80107283:	e9 ee f8 ff ff       	jmp    80106b76 <alltraps>

80107288 <vector18>:
.globl vector18
vector18:
  pushl $0
80107288:	6a 00                	push   $0x0
  pushl $18
8010728a:	6a 12                	push   $0x12
  jmp alltraps
8010728c:	e9 e5 f8 ff ff       	jmp    80106b76 <alltraps>

80107291 <vector19>:
.globl vector19
vector19:
  pushl $0
80107291:	6a 00                	push   $0x0
  pushl $19
80107293:	6a 13                	push   $0x13
  jmp alltraps
80107295:	e9 dc f8 ff ff       	jmp    80106b76 <alltraps>

8010729a <vector20>:
.globl vector20
vector20:
  pushl $0
8010729a:	6a 00                	push   $0x0
  pushl $20
8010729c:	6a 14                	push   $0x14
  jmp alltraps
8010729e:	e9 d3 f8 ff ff       	jmp    80106b76 <alltraps>

801072a3 <vector21>:
.globl vector21
vector21:
  pushl $0
801072a3:	6a 00                	push   $0x0
  pushl $21
801072a5:	6a 15                	push   $0x15
  jmp alltraps
801072a7:	e9 ca f8 ff ff       	jmp    80106b76 <alltraps>

801072ac <vector22>:
.globl vector22
vector22:
  pushl $0
801072ac:	6a 00                	push   $0x0
  pushl $22
801072ae:	6a 16                	push   $0x16
  jmp alltraps
801072b0:	e9 c1 f8 ff ff       	jmp    80106b76 <alltraps>

801072b5 <vector23>:
.globl vector23
vector23:
  pushl $0
801072b5:	6a 00                	push   $0x0
  pushl $23
801072b7:	6a 17                	push   $0x17
  jmp alltraps
801072b9:	e9 b8 f8 ff ff       	jmp    80106b76 <alltraps>

801072be <vector24>:
.globl vector24
vector24:
  pushl $0
801072be:	6a 00                	push   $0x0
  pushl $24
801072c0:	6a 18                	push   $0x18
  jmp alltraps
801072c2:	e9 af f8 ff ff       	jmp    80106b76 <alltraps>

801072c7 <vector25>:
.globl vector25
vector25:
  pushl $0
801072c7:	6a 00                	push   $0x0
  pushl $25
801072c9:	6a 19                	push   $0x19
  jmp alltraps
801072cb:	e9 a6 f8 ff ff       	jmp    80106b76 <alltraps>

801072d0 <vector26>:
.globl vector26
vector26:
  pushl $0
801072d0:	6a 00                	push   $0x0
  pushl $26
801072d2:	6a 1a                	push   $0x1a
  jmp alltraps
801072d4:	e9 9d f8 ff ff       	jmp    80106b76 <alltraps>

801072d9 <vector27>:
.globl vector27
vector27:
  pushl $0
801072d9:	6a 00                	push   $0x0
  pushl $27
801072db:	6a 1b                	push   $0x1b
  jmp alltraps
801072dd:	e9 94 f8 ff ff       	jmp    80106b76 <alltraps>

801072e2 <vector28>:
.globl vector28
vector28:
  pushl $0
801072e2:	6a 00                	push   $0x0
  pushl $28
801072e4:	6a 1c                	push   $0x1c
  jmp alltraps
801072e6:	e9 8b f8 ff ff       	jmp    80106b76 <alltraps>

801072eb <vector29>:
.globl vector29
vector29:
  pushl $0
801072eb:	6a 00                	push   $0x0
  pushl $29
801072ed:	6a 1d                	push   $0x1d
  jmp alltraps
801072ef:	e9 82 f8 ff ff       	jmp    80106b76 <alltraps>

801072f4 <vector30>:
.globl vector30
vector30:
  pushl $0
801072f4:	6a 00                	push   $0x0
  pushl $30
801072f6:	6a 1e                	push   $0x1e
  jmp alltraps
801072f8:	e9 79 f8 ff ff       	jmp    80106b76 <alltraps>

801072fd <vector31>:
.globl vector31
vector31:
  pushl $0
801072fd:	6a 00                	push   $0x0
  pushl $31
801072ff:	6a 1f                	push   $0x1f
  jmp alltraps
80107301:	e9 70 f8 ff ff       	jmp    80106b76 <alltraps>

80107306 <vector32>:
.globl vector32
vector32:
  pushl $0
80107306:	6a 00                	push   $0x0
  pushl $32
80107308:	6a 20                	push   $0x20
  jmp alltraps
8010730a:	e9 67 f8 ff ff       	jmp    80106b76 <alltraps>

8010730f <vector33>:
.globl vector33
vector33:
  pushl $0
8010730f:	6a 00                	push   $0x0
  pushl $33
80107311:	6a 21                	push   $0x21
  jmp alltraps
80107313:	e9 5e f8 ff ff       	jmp    80106b76 <alltraps>

80107318 <vector34>:
.globl vector34
vector34:
  pushl $0
80107318:	6a 00                	push   $0x0
  pushl $34
8010731a:	6a 22                	push   $0x22
  jmp alltraps
8010731c:	e9 55 f8 ff ff       	jmp    80106b76 <alltraps>

80107321 <vector35>:
.globl vector35
vector35:
  pushl $0
80107321:	6a 00                	push   $0x0
  pushl $35
80107323:	6a 23                	push   $0x23
  jmp alltraps
80107325:	e9 4c f8 ff ff       	jmp    80106b76 <alltraps>

8010732a <vector36>:
.globl vector36
vector36:
  pushl $0
8010732a:	6a 00                	push   $0x0
  pushl $36
8010732c:	6a 24                	push   $0x24
  jmp alltraps
8010732e:	e9 43 f8 ff ff       	jmp    80106b76 <alltraps>

80107333 <vector37>:
.globl vector37
vector37:
  pushl $0
80107333:	6a 00                	push   $0x0
  pushl $37
80107335:	6a 25                	push   $0x25
  jmp alltraps
80107337:	e9 3a f8 ff ff       	jmp    80106b76 <alltraps>

8010733c <vector38>:
.globl vector38
vector38:
  pushl $0
8010733c:	6a 00                	push   $0x0
  pushl $38
8010733e:	6a 26                	push   $0x26
  jmp alltraps
80107340:	e9 31 f8 ff ff       	jmp    80106b76 <alltraps>

80107345 <vector39>:
.globl vector39
vector39:
  pushl $0
80107345:	6a 00                	push   $0x0
  pushl $39
80107347:	6a 27                	push   $0x27
  jmp alltraps
80107349:	e9 28 f8 ff ff       	jmp    80106b76 <alltraps>

8010734e <vector40>:
.globl vector40
vector40:
  pushl $0
8010734e:	6a 00                	push   $0x0
  pushl $40
80107350:	6a 28                	push   $0x28
  jmp alltraps
80107352:	e9 1f f8 ff ff       	jmp    80106b76 <alltraps>

80107357 <vector41>:
.globl vector41
vector41:
  pushl $0
80107357:	6a 00                	push   $0x0
  pushl $41
80107359:	6a 29                	push   $0x29
  jmp alltraps
8010735b:	e9 16 f8 ff ff       	jmp    80106b76 <alltraps>

80107360 <vector42>:
.globl vector42
vector42:
  pushl $0
80107360:	6a 00                	push   $0x0
  pushl $42
80107362:	6a 2a                	push   $0x2a
  jmp alltraps
80107364:	e9 0d f8 ff ff       	jmp    80106b76 <alltraps>

80107369 <vector43>:
.globl vector43
vector43:
  pushl $0
80107369:	6a 00                	push   $0x0
  pushl $43
8010736b:	6a 2b                	push   $0x2b
  jmp alltraps
8010736d:	e9 04 f8 ff ff       	jmp    80106b76 <alltraps>

80107372 <vector44>:
.globl vector44
vector44:
  pushl $0
80107372:	6a 00                	push   $0x0
  pushl $44
80107374:	6a 2c                	push   $0x2c
  jmp alltraps
80107376:	e9 fb f7 ff ff       	jmp    80106b76 <alltraps>

8010737b <vector45>:
.globl vector45
vector45:
  pushl $0
8010737b:	6a 00                	push   $0x0
  pushl $45
8010737d:	6a 2d                	push   $0x2d
  jmp alltraps
8010737f:	e9 f2 f7 ff ff       	jmp    80106b76 <alltraps>

80107384 <vector46>:
.globl vector46
vector46:
  pushl $0
80107384:	6a 00                	push   $0x0
  pushl $46
80107386:	6a 2e                	push   $0x2e
  jmp alltraps
80107388:	e9 e9 f7 ff ff       	jmp    80106b76 <alltraps>

8010738d <vector47>:
.globl vector47
vector47:
  pushl $0
8010738d:	6a 00                	push   $0x0
  pushl $47
8010738f:	6a 2f                	push   $0x2f
  jmp alltraps
80107391:	e9 e0 f7 ff ff       	jmp    80106b76 <alltraps>

80107396 <vector48>:
.globl vector48
vector48:
  pushl $0
80107396:	6a 00                	push   $0x0
  pushl $48
80107398:	6a 30                	push   $0x30
  jmp alltraps
8010739a:	e9 d7 f7 ff ff       	jmp    80106b76 <alltraps>

8010739f <vector49>:
.globl vector49
vector49:
  pushl $0
8010739f:	6a 00                	push   $0x0
  pushl $49
801073a1:	6a 31                	push   $0x31
  jmp alltraps
801073a3:	e9 ce f7 ff ff       	jmp    80106b76 <alltraps>

801073a8 <vector50>:
.globl vector50
vector50:
  pushl $0
801073a8:	6a 00                	push   $0x0
  pushl $50
801073aa:	6a 32                	push   $0x32
  jmp alltraps
801073ac:	e9 c5 f7 ff ff       	jmp    80106b76 <alltraps>

801073b1 <vector51>:
.globl vector51
vector51:
  pushl $0
801073b1:	6a 00                	push   $0x0
  pushl $51
801073b3:	6a 33                	push   $0x33
  jmp alltraps
801073b5:	e9 bc f7 ff ff       	jmp    80106b76 <alltraps>

801073ba <vector52>:
.globl vector52
vector52:
  pushl $0
801073ba:	6a 00                	push   $0x0
  pushl $52
801073bc:	6a 34                	push   $0x34
  jmp alltraps
801073be:	e9 b3 f7 ff ff       	jmp    80106b76 <alltraps>

801073c3 <vector53>:
.globl vector53
vector53:
  pushl $0
801073c3:	6a 00                	push   $0x0
  pushl $53
801073c5:	6a 35                	push   $0x35
  jmp alltraps
801073c7:	e9 aa f7 ff ff       	jmp    80106b76 <alltraps>

801073cc <vector54>:
.globl vector54
vector54:
  pushl $0
801073cc:	6a 00                	push   $0x0
  pushl $54
801073ce:	6a 36                	push   $0x36
  jmp alltraps
801073d0:	e9 a1 f7 ff ff       	jmp    80106b76 <alltraps>

801073d5 <vector55>:
.globl vector55
vector55:
  pushl $0
801073d5:	6a 00                	push   $0x0
  pushl $55
801073d7:	6a 37                	push   $0x37
  jmp alltraps
801073d9:	e9 98 f7 ff ff       	jmp    80106b76 <alltraps>

801073de <vector56>:
.globl vector56
vector56:
  pushl $0
801073de:	6a 00                	push   $0x0
  pushl $56
801073e0:	6a 38                	push   $0x38
  jmp alltraps
801073e2:	e9 8f f7 ff ff       	jmp    80106b76 <alltraps>

801073e7 <vector57>:
.globl vector57
vector57:
  pushl $0
801073e7:	6a 00                	push   $0x0
  pushl $57
801073e9:	6a 39                	push   $0x39
  jmp alltraps
801073eb:	e9 86 f7 ff ff       	jmp    80106b76 <alltraps>

801073f0 <vector58>:
.globl vector58
vector58:
  pushl $0
801073f0:	6a 00                	push   $0x0
  pushl $58
801073f2:	6a 3a                	push   $0x3a
  jmp alltraps
801073f4:	e9 7d f7 ff ff       	jmp    80106b76 <alltraps>

801073f9 <vector59>:
.globl vector59
vector59:
  pushl $0
801073f9:	6a 00                	push   $0x0
  pushl $59
801073fb:	6a 3b                	push   $0x3b
  jmp alltraps
801073fd:	e9 74 f7 ff ff       	jmp    80106b76 <alltraps>

80107402 <vector60>:
.globl vector60
vector60:
  pushl $0
80107402:	6a 00                	push   $0x0
  pushl $60
80107404:	6a 3c                	push   $0x3c
  jmp alltraps
80107406:	e9 6b f7 ff ff       	jmp    80106b76 <alltraps>

8010740b <vector61>:
.globl vector61
vector61:
  pushl $0
8010740b:	6a 00                	push   $0x0
  pushl $61
8010740d:	6a 3d                	push   $0x3d
  jmp alltraps
8010740f:	e9 62 f7 ff ff       	jmp    80106b76 <alltraps>

80107414 <vector62>:
.globl vector62
vector62:
  pushl $0
80107414:	6a 00                	push   $0x0
  pushl $62
80107416:	6a 3e                	push   $0x3e
  jmp alltraps
80107418:	e9 59 f7 ff ff       	jmp    80106b76 <alltraps>

8010741d <vector63>:
.globl vector63
vector63:
  pushl $0
8010741d:	6a 00                	push   $0x0
  pushl $63
8010741f:	6a 3f                	push   $0x3f
  jmp alltraps
80107421:	e9 50 f7 ff ff       	jmp    80106b76 <alltraps>

80107426 <vector64>:
.globl vector64
vector64:
  pushl $0
80107426:	6a 00                	push   $0x0
  pushl $64
80107428:	6a 40                	push   $0x40
  jmp alltraps
8010742a:	e9 47 f7 ff ff       	jmp    80106b76 <alltraps>

8010742f <vector65>:
.globl vector65
vector65:
  pushl $0
8010742f:	6a 00                	push   $0x0
  pushl $65
80107431:	6a 41                	push   $0x41
  jmp alltraps
80107433:	e9 3e f7 ff ff       	jmp    80106b76 <alltraps>

80107438 <vector66>:
.globl vector66
vector66:
  pushl $0
80107438:	6a 00                	push   $0x0
  pushl $66
8010743a:	6a 42                	push   $0x42
  jmp alltraps
8010743c:	e9 35 f7 ff ff       	jmp    80106b76 <alltraps>

80107441 <vector67>:
.globl vector67
vector67:
  pushl $0
80107441:	6a 00                	push   $0x0
  pushl $67
80107443:	6a 43                	push   $0x43
  jmp alltraps
80107445:	e9 2c f7 ff ff       	jmp    80106b76 <alltraps>

8010744a <vector68>:
.globl vector68
vector68:
  pushl $0
8010744a:	6a 00                	push   $0x0
  pushl $68
8010744c:	6a 44                	push   $0x44
  jmp alltraps
8010744e:	e9 23 f7 ff ff       	jmp    80106b76 <alltraps>

80107453 <vector69>:
.globl vector69
vector69:
  pushl $0
80107453:	6a 00                	push   $0x0
  pushl $69
80107455:	6a 45                	push   $0x45
  jmp alltraps
80107457:	e9 1a f7 ff ff       	jmp    80106b76 <alltraps>

8010745c <vector70>:
.globl vector70
vector70:
  pushl $0
8010745c:	6a 00                	push   $0x0
  pushl $70
8010745e:	6a 46                	push   $0x46
  jmp alltraps
80107460:	e9 11 f7 ff ff       	jmp    80106b76 <alltraps>

80107465 <vector71>:
.globl vector71
vector71:
  pushl $0
80107465:	6a 00                	push   $0x0
  pushl $71
80107467:	6a 47                	push   $0x47
  jmp alltraps
80107469:	e9 08 f7 ff ff       	jmp    80106b76 <alltraps>

8010746e <vector72>:
.globl vector72
vector72:
  pushl $0
8010746e:	6a 00                	push   $0x0
  pushl $72
80107470:	6a 48                	push   $0x48
  jmp alltraps
80107472:	e9 ff f6 ff ff       	jmp    80106b76 <alltraps>

80107477 <vector73>:
.globl vector73
vector73:
  pushl $0
80107477:	6a 00                	push   $0x0
  pushl $73
80107479:	6a 49                	push   $0x49
  jmp alltraps
8010747b:	e9 f6 f6 ff ff       	jmp    80106b76 <alltraps>

80107480 <vector74>:
.globl vector74
vector74:
  pushl $0
80107480:	6a 00                	push   $0x0
  pushl $74
80107482:	6a 4a                	push   $0x4a
  jmp alltraps
80107484:	e9 ed f6 ff ff       	jmp    80106b76 <alltraps>

80107489 <vector75>:
.globl vector75
vector75:
  pushl $0
80107489:	6a 00                	push   $0x0
  pushl $75
8010748b:	6a 4b                	push   $0x4b
  jmp alltraps
8010748d:	e9 e4 f6 ff ff       	jmp    80106b76 <alltraps>

80107492 <vector76>:
.globl vector76
vector76:
  pushl $0
80107492:	6a 00                	push   $0x0
  pushl $76
80107494:	6a 4c                	push   $0x4c
  jmp alltraps
80107496:	e9 db f6 ff ff       	jmp    80106b76 <alltraps>

8010749b <vector77>:
.globl vector77
vector77:
  pushl $0
8010749b:	6a 00                	push   $0x0
  pushl $77
8010749d:	6a 4d                	push   $0x4d
  jmp alltraps
8010749f:	e9 d2 f6 ff ff       	jmp    80106b76 <alltraps>

801074a4 <vector78>:
.globl vector78
vector78:
  pushl $0
801074a4:	6a 00                	push   $0x0
  pushl $78
801074a6:	6a 4e                	push   $0x4e
  jmp alltraps
801074a8:	e9 c9 f6 ff ff       	jmp    80106b76 <alltraps>

801074ad <vector79>:
.globl vector79
vector79:
  pushl $0
801074ad:	6a 00                	push   $0x0
  pushl $79
801074af:	6a 4f                	push   $0x4f
  jmp alltraps
801074b1:	e9 c0 f6 ff ff       	jmp    80106b76 <alltraps>

801074b6 <vector80>:
.globl vector80
vector80:
  pushl $0
801074b6:	6a 00                	push   $0x0
  pushl $80
801074b8:	6a 50                	push   $0x50
  jmp alltraps
801074ba:	e9 b7 f6 ff ff       	jmp    80106b76 <alltraps>

801074bf <vector81>:
.globl vector81
vector81:
  pushl $0
801074bf:	6a 00                	push   $0x0
  pushl $81
801074c1:	6a 51                	push   $0x51
  jmp alltraps
801074c3:	e9 ae f6 ff ff       	jmp    80106b76 <alltraps>

801074c8 <vector82>:
.globl vector82
vector82:
  pushl $0
801074c8:	6a 00                	push   $0x0
  pushl $82
801074ca:	6a 52                	push   $0x52
  jmp alltraps
801074cc:	e9 a5 f6 ff ff       	jmp    80106b76 <alltraps>

801074d1 <vector83>:
.globl vector83
vector83:
  pushl $0
801074d1:	6a 00                	push   $0x0
  pushl $83
801074d3:	6a 53                	push   $0x53
  jmp alltraps
801074d5:	e9 9c f6 ff ff       	jmp    80106b76 <alltraps>

801074da <vector84>:
.globl vector84
vector84:
  pushl $0
801074da:	6a 00                	push   $0x0
  pushl $84
801074dc:	6a 54                	push   $0x54
  jmp alltraps
801074de:	e9 93 f6 ff ff       	jmp    80106b76 <alltraps>

801074e3 <vector85>:
.globl vector85
vector85:
  pushl $0
801074e3:	6a 00                	push   $0x0
  pushl $85
801074e5:	6a 55                	push   $0x55
  jmp alltraps
801074e7:	e9 8a f6 ff ff       	jmp    80106b76 <alltraps>

801074ec <vector86>:
.globl vector86
vector86:
  pushl $0
801074ec:	6a 00                	push   $0x0
  pushl $86
801074ee:	6a 56                	push   $0x56
  jmp alltraps
801074f0:	e9 81 f6 ff ff       	jmp    80106b76 <alltraps>

801074f5 <vector87>:
.globl vector87
vector87:
  pushl $0
801074f5:	6a 00                	push   $0x0
  pushl $87
801074f7:	6a 57                	push   $0x57
  jmp alltraps
801074f9:	e9 78 f6 ff ff       	jmp    80106b76 <alltraps>

801074fe <vector88>:
.globl vector88
vector88:
  pushl $0
801074fe:	6a 00                	push   $0x0
  pushl $88
80107500:	6a 58                	push   $0x58
  jmp alltraps
80107502:	e9 6f f6 ff ff       	jmp    80106b76 <alltraps>

80107507 <vector89>:
.globl vector89
vector89:
  pushl $0
80107507:	6a 00                	push   $0x0
  pushl $89
80107509:	6a 59                	push   $0x59
  jmp alltraps
8010750b:	e9 66 f6 ff ff       	jmp    80106b76 <alltraps>

80107510 <vector90>:
.globl vector90
vector90:
  pushl $0
80107510:	6a 00                	push   $0x0
  pushl $90
80107512:	6a 5a                	push   $0x5a
  jmp alltraps
80107514:	e9 5d f6 ff ff       	jmp    80106b76 <alltraps>

80107519 <vector91>:
.globl vector91
vector91:
  pushl $0
80107519:	6a 00                	push   $0x0
  pushl $91
8010751b:	6a 5b                	push   $0x5b
  jmp alltraps
8010751d:	e9 54 f6 ff ff       	jmp    80106b76 <alltraps>

80107522 <vector92>:
.globl vector92
vector92:
  pushl $0
80107522:	6a 00                	push   $0x0
  pushl $92
80107524:	6a 5c                	push   $0x5c
  jmp alltraps
80107526:	e9 4b f6 ff ff       	jmp    80106b76 <alltraps>

8010752b <vector93>:
.globl vector93
vector93:
  pushl $0
8010752b:	6a 00                	push   $0x0
  pushl $93
8010752d:	6a 5d                	push   $0x5d
  jmp alltraps
8010752f:	e9 42 f6 ff ff       	jmp    80106b76 <alltraps>

80107534 <vector94>:
.globl vector94
vector94:
  pushl $0
80107534:	6a 00                	push   $0x0
  pushl $94
80107536:	6a 5e                	push   $0x5e
  jmp alltraps
80107538:	e9 39 f6 ff ff       	jmp    80106b76 <alltraps>

8010753d <vector95>:
.globl vector95
vector95:
  pushl $0
8010753d:	6a 00                	push   $0x0
  pushl $95
8010753f:	6a 5f                	push   $0x5f
  jmp alltraps
80107541:	e9 30 f6 ff ff       	jmp    80106b76 <alltraps>

80107546 <vector96>:
.globl vector96
vector96:
  pushl $0
80107546:	6a 00                	push   $0x0
  pushl $96
80107548:	6a 60                	push   $0x60
  jmp alltraps
8010754a:	e9 27 f6 ff ff       	jmp    80106b76 <alltraps>

8010754f <vector97>:
.globl vector97
vector97:
  pushl $0
8010754f:	6a 00                	push   $0x0
  pushl $97
80107551:	6a 61                	push   $0x61
  jmp alltraps
80107553:	e9 1e f6 ff ff       	jmp    80106b76 <alltraps>

80107558 <vector98>:
.globl vector98
vector98:
  pushl $0
80107558:	6a 00                	push   $0x0
  pushl $98
8010755a:	6a 62                	push   $0x62
  jmp alltraps
8010755c:	e9 15 f6 ff ff       	jmp    80106b76 <alltraps>

80107561 <vector99>:
.globl vector99
vector99:
  pushl $0
80107561:	6a 00                	push   $0x0
  pushl $99
80107563:	6a 63                	push   $0x63
  jmp alltraps
80107565:	e9 0c f6 ff ff       	jmp    80106b76 <alltraps>

8010756a <vector100>:
.globl vector100
vector100:
  pushl $0
8010756a:	6a 00                	push   $0x0
  pushl $100
8010756c:	6a 64                	push   $0x64
  jmp alltraps
8010756e:	e9 03 f6 ff ff       	jmp    80106b76 <alltraps>

80107573 <vector101>:
.globl vector101
vector101:
  pushl $0
80107573:	6a 00                	push   $0x0
  pushl $101
80107575:	6a 65                	push   $0x65
  jmp alltraps
80107577:	e9 fa f5 ff ff       	jmp    80106b76 <alltraps>

8010757c <vector102>:
.globl vector102
vector102:
  pushl $0
8010757c:	6a 00                	push   $0x0
  pushl $102
8010757e:	6a 66                	push   $0x66
  jmp alltraps
80107580:	e9 f1 f5 ff ff       	jmp    80106b76 <alltraps>

80107585 <vector103>:
.globl vector103
vector103:
  pushl $0
80107585:	6a 00                	push   $0x0
  pushl $103
80107587:	6a 67                	push   $0x67
  jmp alltraps
80107589:	e9 e8 f5 ff ff       	jmp    80106b76 <alltraps>

8010758e <vector104>:
.globl vector104
vector104:
  pushl $0
8010758e:	6a 00                	push   $0x0
  pushl $104
80107590:	6a 68                	push   $0x68
  jmp alltraps
80107592:	e9 df f5 ff ff       	jmp    80106b76 <alltraps>

80107597 <vector105>:
.globl vector105
vector105:
  pushl $0
80107597:	6a 00                	push   $0x0
  pushl $105
80107599:	6a 69                	push   $0x69
  jmp alltraps
8010759b:	e9 d6 f5 ff ff       	jmp    80106b76 <alltraps>

801075a0 <vector106>:
.globl vector106
vector106:
  pushl $0
801075a0:	6a 00                	push   $0x0
  pushl $106
801075a2:	6a 6a                	push   $0x6a
  jmp alltraps
801075a4:	e9 cd f5 ff ff       	jmp    80106b76 <alltraps>

801075a9 <vector107>:
.globl vector107
vector107:
  pushl $0
801075a9:	6a 00                	push   $0x0
  pushl $107
801075ab:	6a 6b                	push   $0x6b
  jmp alltraps
801075ad:	e9 c4 f5 ff ff       	jmp    80106b76 <alltraps>

801075b2 <vector108>:
.globl vector108
vector108:
  pushl $0
801075b2:	6a 00                	push   $0x0
  pushl $108
801075b4:	6a 6c                	push   $0x6c
  jmp alltraps
801075b6:	e9 bb f5 ff ff       	jmp    80106b76 <alltraps>

801075bb <vector109>:
.globl vector109
vector109:
  pushl $0
801075bb:	6a 00                	push   $0x0
  pushl $109
801075bd:	6a 6d                	push   $0x6d
  jmp alltraps
801075bf:	e9 b2 f5 ff ff       	jmp    80106b76 <alltraps>

801075c4 <vector110>:
.globl vector110
vector110:
  pushl $0
801075c4:	6a 00                	push   $0x0
  pushl $110
801075c6:	6a 6e                	push   $0x6e
  jmp alltraps
801075c8:	e9 a9 f5 ff ff       	jmp    80106b76 <alltraps>

801075cd <vector111>:
.globl vector111
vector111:
  pushl $0
801075cd:	6a 00                	push   $0x0
  pushl $111
801075cf:	6a 6f                	push   $0x6f
  jmp alltraps
801075d1:	e9 a0 f5 ff ff       	jmp    80106b76 <alltraps>

801075d6 <vector112>:
.globl vector112
vector112:
  pushl $0
801075d6:	6a 00                	push   $0x0
  pushl $112
801075d8:	6a 70                	push   $0x70
  jmp alltraps
801075da:	e9 97 f5 ff ff       	jmp    80106b76 <alltraps>

801075df <vector113>:
.globl vector113
vector113:
  pushl $0
801075df:	6a 00                	push   $0x0
  pushl $113
801075e1:	6a 71                	push   $0x71
  jmp alltraps
801075e3:	e9 8e f5 ff ff       	jmp    80106b76 <alltraps>

801075e8 <vector114>:
.globl vector114
vector114:
  pushl $0
801075e8:	6a 00                	push   $0x0
  pushl $114
801075ea:	6a 72                	push   $0x72
  jmp alltraps
801075ec:	e9 85 f5 ff ff       	jmp    80106b76 <alltraps>

801075f1 <vector115>:
.globl vector115
vector115:
  pushl $0
801075f1:	6a 00                	push   $0x0
  pushl $115
801075f3:	6a 73                	push   $0x73
  jmp alltraps
801075f5:	e9 7c f5 ff ff       	jmp    80106b76 <alltraps>

801075fa <vector116>:
.globl vector116
vector116:
  pushl $0
801075fa:	6a 00                	push   $0x0
  pushl $116
801075fc:	6a 74                	push   $0x74
  jmp alltraps
801075fe:	e9 73 f5 ff ff       	jmp    80106b76 <alltraps>

80107603 <vector117>:
.globl vector117
vector117:
  pushl $0
80107603:	6a 00                	push   $0x0
  pushl $117
80107605:	6a 75                	push   $0x75
  jmp alltraps
80107607:	e9 6a f5 ff ff       	jmp    80106b76 <alltraps>

8010760c <vector118>:
.globl vector118
vector118:
  pushl $0
8010760c:	6a 00                	push   $0x0
  pushl $118
8010760e:	6a 76                	push   $0x76
  jmp alltraps
80107610:	e9 61 f5 ff ff       	jmp    80106b76 <alltraps>

80107615 <vector119>:
.globl vector119
vector119:
  pushl $0
80107615:	6a 00                	push   $0x0
  pushl $119
80107617:	6a 77                	push   $0x77
  jmp alltraps
80107619:	e9 58 f5 ff ff       	jmp    80106b76 <alltraps>

8010761e <vector120>:
.globl vector120
vector120:
  pushl $0
8010761e:	6a 00                	push   $0x0
  pushl $120
80107620:	6a 78                	push   $0x78
  jmp alltraps
80107622:	e9 4f f5 ff ff       	jmp    80106b76 <alltraps>

80107627 <vector121>:
.globl vector121
vector121:
  pushl $0
80107627:	6a 00                	push   $0x0
  pushl $121
80107629:	6a 79                	push   $0x79
  jmp alltraps
8010762b:	e9 46 f5 ff ff       	jmp    80106b76 <alltraps>

80107630 <vector122>:
.globl vector122
vector122:
  pushl $0
80107630:	6a 00                	push   $0x0
  pushl $122
80107632:	6a 7a                	push   $0x7a
  jmp alltraps
80107634:	e9 3d f5 ff ff       	jmp    80106b76 <alltraps>

80107639 <vector123>:
.globl vector123
vector123:
  pushl $0
80107639:	6a 00                	push   $0x0
  pushl $123
8010763b:	6a 7b                	push   $0x7b
  jmp alltraps
8010763d:	e9 34 f5 ff ff       	jmp    80106b76 <alltraps>

80107642 <vector124>:
.globl vector124
vector124:
  pushl $0
80107642:	6a 00                	push   $0x0
  pushl $124
80107644:	6a 7c                	push   $0x7c
  jmp alltraps
80107646:	e9 2b f5 ff ff       	jmp    80106b76 <alltraps>

8010764b <vector125>:
.globl vector125
vector125:
  pushl $0
8010764b:	6a 00                	push   $0x0
  pushl $125
8010764d:	6a 7d                	push   $0x7d
  jmp alltraps
8010764f:	e9 22 f5 ff ff       	jmp    80106b76 <alltraps>

80107654 <vector126>:
.globl vector126
vector126:
  pushl $0
80107654:	6a 00                	push   $0x0
  pushl $126
80107656:	6a 7e                	push   $0x7e
  jmp alltraps
80107658:	e9 19 f5 ff ff       	jmp    80106b76 <alltraps>

8010765d <vector127>:
.globl vector127
vector127:
  pushl $0
8010765d:	6a 00                	push   $0x0
  pushl $127
8010765f:	6a 7f                	push   $0x7f
  jmp alltraps
80107661:	e9 10 f5 ff ff       	jmp    80106b76 <alltraps>

80107666 <vector128>:
.globl vector128
vector128:
  pushl $0
80107666:	6a 00                	push   $0x0
  pushl $128
80107668:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010766d:	e9 04 f5 ff ff       	jmp    80106b76 <alltraps>

80107672 <vector129>:
.globl vector129
vector129:
  pushl $0
80107672:	6a 00                	push   $0x0
  pushl $129
80107674:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107679:	e9 f8 f4 ff ff       	jmp    80106b76 <alltraps>

8010767e <vector130>:
.globl vector130
vector130:
  pushl $0
8010767e:	6a 00                	push   $0x0
  pushl $130
80107680:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107685:	e9 ec f4 ff ff       	jmp    80106b76 <alltraps>

8010768a <vector131>:
.globl vector131
vector131:
  pushl $0
8010768a:	6a 00                	push   $0x0
  pushl $131
8010768c:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107691:	e9 e0 f4 ff ff       	jmp    80106b76 <alltraps>

80107696 <vector132>:
.globl vector132
vector132:
  pushl $0
80107696:	6a 00                	push   $0x0
  pushl $132
80107698:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010769d:	e9 d4 f4 ff ff       	jmp    80106b76 <alltraps>

801076a2 <vector133>:
.globl vector133
vector133:
  pushl $0
801076a2:	6a 00                	push   $0x0
  pushl $133
801076a4:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801076a9:	e9 c8 f4 ff ff       	jmp    80106b76 <alltraps>

801076ae <vector134>:
.globl vector134
vector134:
  pushl $0
801076ae:	6a 00                	push   $0x0
  pushl $134
801076b0:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801076b5:	e9 bc f4 ff ff       	jmp    80106b76 <alltraps>

801076ba <vector135>:
.globl vector135
vector135:
  pushl $0
801076ba:	6a 00                	push   $0x0
  pushl $135
801076bc:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801076c1:	e9 b0 f4 ff ff       	jmp    80106b76 <alltraps>

801076c6 <vector136>:
.globl vector136
vector136:
  pushl $0
801076c6:	6a 00                	push   $0x0
  pushl $136
801076c8:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801076cd:	e9 a4 f4 ff ff       	jmp    80106b76 <alltraps>

801076d2 <vector137>:
.globl vector137
vector137:
  pushl $0
801076d2:	6a 00                	push   $0x0
  pushl $137
801076d4:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801076d9:	e9 98 f4 ff ff       	jmp    80106b76 <alltraps>

801076de <vector138>:
.globl vector138
vector138:
  pushl $0
801076de:	6a 00                	push   $0x0
  pushl $138
801076e0:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801076e5:	e9 8c f4 ff ff       	jmp    80106b76 <alltraps>

801076ea <vector139>:
.globl vector139
vector139:
  pushl $0
801076ea:	6a 00                	push   $0x0
  pushl $139
801076ec:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801076f1:	e9 80 f4 ff ff       	jmp    80106b76 <alltraps>

801076f6 <vector140>:
.globl vector140
vector140:
  pushl $0
801076f6:	6a 00                	push   $0x0
  pushl $140
801076f8:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801076fd:	e9 74 f4 ff ff       	jmp    80106b76 <alltraps>

80107702 <vector141>:
.globl vector141
vector141:
  pushl $0
80107702:	6a 00                	push   $0x0
  pushl $141
80107704:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107709:	e9 68 f4 ff ff       	jmp    80106b76 <alltraps>

8010770e <vector142>:
.globl vector142
vector142:
  pushl $0
8010770e:	6a 00                	push   $0x0
  pushl $142
80107710:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107715:	e9 5c f4 ff ff       	jmp    80106b76 <alltraps>

8010771a <vector143>:
.globl vector143
vector143:
  pushl $0
8010771a:	6a 00                	push   $0x0
  pushl $143
8010771c:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107721:	e9 50 f4 ff ff       	jmp    80106b76 <alltraps>

80107726 <vector144>:
.globl vector144
vector144:
  pushl $0
80107726:	6a 00                	push   $0x0
  pushl $144
80107728:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010772d:	e9 44 f4 ff ff       	jmp    80106b76 <alltraps>

80107732 <vector145>:
.globl vector145
vector145:
  pushl $0
80107732:	6a 00                	push   $0x0
  pushl $145
80107734:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107739:	e9 38 f4 ff ff       	jmp    80106b76 <alltraps>

8010773e <vector146>:
.globl vector146
vector146:
  pushl $0
8010773e:	6a 00                	push   $0x0
  pushl $146
80107740:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107745:	e9 2c f4 ff ff       	jmp    80106b76 <alltraps>

8010774a <vector147>:
.globl vector147
vector147:
  pushl $0
8010774a:	6a 00                	push   $0x0
  pushl $147
8010774c:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107751:	e9 20 f4 ff ff       	jmp    80106b76 <alltraps>

80107756 <vector148>:
.globl vector148
vector148:
  pushl $0
80107756:	6a 00                	push   $0x0
  pushl $148
80107758:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010775d:	e9 14 f4 ff ff       	jmp    80106b76 <alltraps>

80107762 <vector149>:
.globl vector149
vector149:
  pushl $0
80107762:	6a 00                	push   $0x0
  pushl $149
80107764:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107769:	e9 08 f4 ff ff       	jmp    80106b76 <alltraps>

8010776e <vector150>:
.globl vector150
vector150:
  pushl $0
8010776e:	6a 00                	push   $0x0
  pushl $150
80107770:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107775:	e9 fc f3 ff ff       	jmp    80106b76 <alltraps>

8010777a <vector151>:
.globl vector151
vector151:
  pushl $0
8010777a:	6a 00                	push   $0x0
  pushl $151
8010777c:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107781:	e9 f0 f3 ff ff       	jmp    80106b76 <alltraps>

80107786 <vector152>:
.globl vector152
vector152:
  pushl $0
80107786:	6a 00                	push   $0x0
  pushl $152
80107788:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010778d:	e9 e4 f3 ff ff       	jmp    80106b76 <alltraps>

80107792 <vector153>:
.globl vector153
vector153:
  pushl $0
80107792:	6a 00                	push   $0x0
  pushl $153
80107794:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107799:	e9 d8 f3 ff ff       	jmp    80106b76 <alltraps>

8010779e <vector154>:
.globl vector154
vector154:
  pushl $0
8010779e:	6a 00                	push   $0x0
  pushl $154
801077a0:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801077a5:	e9 cc f3 ff ff       	jmp    80106b76 <alltraps>

801077aa <vector155>:
.globl vector155
vector155:
  pushl $0
801077aa:	6a 00                	push   $0x0
  pushl $155
801077ac:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801077b1:	e9 c0 f3 ff ff       	jmp    80106b76 <alltraps>

801077b6 <vector156>:
.globl vector156
vector156:
  pushl $0
801077b6:	6a 00                	push   $0x0
  pushl $156
801077b8:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801077bd:	e9 b4 f3 ff ff       	jmp    80106b76 <alltraps>

801077c2 <vector157>:
.globl vector157
vector157:
  pushl $0
801077c2:	6a 00                	push   $0x0
  pushl $157
801077c4:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801077c9:	e9 a8 f3 ff ff       	jmp    80106b76 <alltraps>

801077ce <vector158>:
.globl vector158
vector158:
  pushl $0
801077ce:	6a 00                	push   $0x0
  pushl $158
801077d0:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801077d5:	e9 9c f3 ff ff       	jmp    80106b76 <alltraps>

801077da <vector159>:
.globl vector159
vector159:
  pushl $0
801077da:	6a 00                	push   $0x0
  pushl $159
801077dc:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801077e1:	e9 90 f3 ff ff       	jmp    80106b76 <alltraps>

801077e6 <vector160>:
.globl vector160
vector160:
  pushl $0
801077e6:	6a 00                	push   $0x0
  pushl $160
801077e8:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801077ed:	e9 84 f3 ff ff       	jmp    80106b76 <alltraps>

801077f2 <vector161>:
.globl vector161
vector161:
  pushl $0
801077f2:	6a 00                	push   $0x0
  pushl $161
801077f4:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801077f9:	e9 78 f3 ff ff       	jmp    80106b76 <alltraps>

801077fe <vector162>:
.globl vector162
vector162:
  pushl $0
801077fe:	6a 00                	push   $0x0
  pushl $162
80107800:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107805:	e9 6c f3 ff ff       	jmp    80106b76 <alltraps>

8010780a <vector163>:
.globl vector163
vector163:
  pushl $0
8010780a:	6a 00                	push   $0x0
  pushl $163
8010780c:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107811:	e9 60 f3 ff ff       	jmp    80106b76 <alltraps>

80107816 <vector164>:
.globl vector164
vector164:
  pushl $0
80107816:	6a 00                	push   $0x0
  pushl $164
80107818:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010781d:	e9 54 f3 ff ff       	jmp    80106b76 <alltraps>

80107822 <vector165>:
.globl vector165
vector165:
  pushl $0
80107822:	6a 00                	push   $0x0
  pushl $165
80107824:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107829:	e9 48 f3 ff ff       	jmp    80106b76 <alltraps>

8010782e <vector166>:
.globl vector166
vector166:
  pushl $0
8010782e:	6a 00                	push   $0x0
  pushl $166
80107830:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107835:	e9 3c f3 ff ff       	jmp    80106b76 <alltraps>

8010783a <vector167>:
.globl vector167
vector167:
  pushl $0
8010783a:	6a 00                	push   $0x0
  pushl $167
8010783c:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107841:	e9 30 f3 ff ff       	jmp    80106b76 <alltraps>

80107846 <vector168>:
.globl vector168
vector168:
  pushl $0
80107846:	6a 00                	push   $0x0
  pushl $168
80107848:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010784d:	e9 24 f3 ff ff       	jmp    80106b76 <alltraps>

80107852 <vector169>:
.globl vector169
vector169:
  pushl $0
80107852:	6a 00                	push   $0x0
  pushl $169
80107854:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107859:	e9 18 f3 ff ff       	jmp    80106b76 <alltraps>

8010785e <vector170>:
.globl vector170
vector170:
  pushl $0
8010785e:	6a 00                	push   $0x0
  pushl $170
80107860:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107865:	e9 0c f3 ff ff       	jmp    80106b76 <alltraps>

8010786a <vector171>:
.globl vector171
vector171:
  pushl $0
8010786a:	6a 00                	push   $0x0
  pushl $171
8010786c:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107871:	e9 00 f3 ff ff       	jmp    80106b76 <alltraps>

80107876 <vector172>:
.globl vector172
vector172:
  pushl $0
80107876:	6a 00                	push   $0x0
  pushl $172
80107878:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010787d:	e9 f4 f2 ff ff       	jmp    80106b76 <alltraps>

80107882 <vector173>:
.globl vector173
vector173:
  pushl $0
80107882:	6a 00                	push   $0x0
  pushl $173
80107884:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107889:	e9 e8 f2 ff ff       	jmp    80106b76 <alltraps>

8010788e <vector174>:
.globl vector174
vector174:
  pushl $0
8010788e:	6a 00                	push   $0x0
  pushl $174
80107890:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107895:	e9 dc f2 ff ff       	jmp    80106b76 <alltraps>

8010789a <vector175>:
.globl vector175
vector175:
  pushl $0
8010789a:	6a 00                	push   $0x0
  pushl $175
8010789c:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801078a1:	e9 d0 f2 ff ff       	jmp    80106b76 <alltraps>

801078a6 <vector176>:
.globl vector176
vector176:
  pushl $0
801078a6:	6a 00                	push   $0x0
  pushl $176
801078a8:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801078ad:	e9 c4 f2 ff ff       	jmp    80106b76 <alltraps>

801078b2 <vector177>:
.globl vector177
vector177:
  pushl $0
801078b2:	6a 00                	push   $0x0
  pushl $177
801078b4:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801078b9:	e9 b8 f2 ff ff       	jmp    80106b76 <alltraps>

801078be <vector178>:
.globl vector178
vector178:
  pushl $0
801078be:	6a 00                	push   $0x0
  pushl $178
801078c0:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801078c5:	e9 ac f2 ff ff       	jmp    80106b76 <alltraps>

801078ca <vector179>:
.globl vector179
vector179:
  pushl $0
801078ca:	6a 00                	push   $0x0
  pushl $179
801078cc:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801078d1:	e9 a0 f2 ff ff       	jmp    80106b76 <alltraps>

801078d6 <vector180>:
.globl vector180
vector180:
  pushl $0
801078d6:	6a 00                	push   $0x0
  pushl $180
801078d8:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801078dd:	e9 94 f2 ff ff       	jmp    80106b76 <alltraps>

801078e2 <vector181>:
.globl vector181
vector181:
  pushl $0
801078e2:	6a 00                	push   $0x0
  pushl $181
801078e4:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801078e9:	e9 88 f2 ff ff       	jmp    80106b76 <alltraps>

801078ee <vector182>:
.globl vector182
vector182:
  pushl $0
801078ee:	6a 00                	push   $0x0
  pushl $182
801078f0:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801078f5:	e9 7c f2 ff ff       	jmp    80106b76 <alltraps>

801078fa <vector183>:
.globl vector183
vector183:
  pushl $0
801078fa:	6a 00                	push   $0x0
  pushl $183
801078fc:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107901:	e9 70 f2 ff ff       	jmp    80106b76 <alltraps>

80107906 <vector184>:
.globl vector184
vector184:
  pushl $0
80107906:	6a 00                	push   $0x0
  pushl $184
80107908:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010790d:	e9 64 f2 ff ff       	jmp    80106b76 <alltraps>

80107912 <vector185>:
.globl vector185
vector185:
  pushl $0
80107912:	6a 00                	push   $0x0
  pushl $185
80107914:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107919:	e9 58 f2 ff ff       	jmp    80106b76 <alltraps>

8010791e <vector186>:
.globl vector186
vector186:
  pushl $0
8010791e:	6a 00                	push   $0x0
  pushl $186
80107920:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107925:	e9 4c f2 ff ff       	jmp    80106b76 <alltraps>

8010792a <vector187>:
.globl vector187
vector187:
  pushl $0
8010792a:	6a 00                	push   $0x0
  pushl $187
8010792c:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107931:	e9 40 f2 ff ff       	jmp    80106b76 <alltraps>

80107936 <vector188>:
.globl vector188
vector188:
  pushl $0
80107936:	6a 00                	push   $0x0
  pushl $188
80107938:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010793d:	e9 34 f2 ff ff       	jmp    80106b76 <alltraps>

80107942 <vector189>:
.globl vector189
vector189:
  pushl $0
80107942:	6a 00                	push   $0x0
  pushl $189
80107944:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107949:	e9 28 f2 ff ff       	jmp    80106b76 <alltraps>

8010794e <vector190>:
.globl vector190
vector190:
  pushl $0
8010794e:	6a 00                	push   $0x0
  pushl $190
80107950:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107955:	e9 1c f2 ff ff       	jmp    80106b76 <alltraps>

8010795a <vector191>:
.globl vector191
vector191:
  pushl $0
8010795a:	6a 00                	push   $0x0
  pushl $191
8010795c:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107961:	e9 10 f2 ff ff       	jmp    80106b76 <alltraps>

80107966 <vector192>:
.globl vector192
vector192:
  pushl $0
80107966:	6a 00                	push   $0x0
  pushl $192
80107968:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010796d:	e9 04 f2 ff ff       	jmp    80106b76 <alltraps>

80107972 <vector193>:
.globl vector193
vector193:
  pushl $0
80107972:	6a 00                	push   $0x0
  pushl $193
80107974:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107979:	e9 f8 f1 ff ff       	jmp    80106b76 <alltraps>

8010797e <vector194>:
.globl vector194
vector194:
  pushl $0
8010797e:	6a 00                	push   $0x0
  pushl $194
80107980:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107985:	e9 ec f1 ff ff       	jmp    80106b76 <alltraps>

8010798a <vector195>:
.globl vector195
vector195:
  pushl $0
8010798a:	6a 00                	push   $0x0
  pushl $195
8010798c:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107991:	e9 e0 f1 ff ff       	jmp    80106b76 <alltraps>

80107996 <vector196>:
.globl vector196
vector196:
  pushl $0
80107996:	6a 00                	push   $0x0
  pushl $196
80107998:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010799d:	e9 d4 f1 ff ff       	jmp    80106b76 <alltraps>

801079a2 <vector197>:
.globl vector197
vector197:
  pushl $0
801079a2:	6a 00                	push   $0x0
  pushl $197
801079a4:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801079a9:	e9 c8 f1 ff ff       	jmp    80106b76 <alltraps>

801079ae <vector198>:
.globl vector198
vector198:
  pushl $0
801079ae:	6a 00                	push   $0x0
  pushl $198
801079b0:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801079b5:	e9 bc f1 ff ff       	jmp    80106b76 <alltraps>

801079ba <vector199>:
.globl vector199
vector199:
  pushl $0
801079ba:	6a 00                	push   $0x0
  pushl $199
801079bc:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801079c1:	e9 b0 f1 ff ff       	jmp    80106b76 <alltraps>

801079c6 <vector200>:
.globl vector200
vector200:
  pushl $0
801079c6:	6a 00                	push   $0x0
  pushl $200
801079c8:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801079cd:	e9 a4 f1 ff ff       	jmp    80106b76 <alltraps>

801079d2 <vector201>:
.globl vector201
vector201:
  pushl $0
801079d2:	6a 00                	push   $0x0
  pushl $201
801079d4:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801079d9:	e9 98 f1 ff ff       	jmp    80106b76 <alltraps>

801079de <vector202>:
.globl vector202
vector202:
  pushl $0
801079de:	6a 00                	push   $0x0
  pushl $202
801079e0:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801079e5:	e9 8c f1 ff ff       	jmp    80106b76 <alltraps>

801079ea <vector203>:
.globl vector203
vector203:
  pushl $0
801079ea:	6a 00                	push   $0x0
  pushl $203
801079ec:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801079f1:	e9 80 f1 ff ff       	jmp    80106b76 <alltraps>

801079f6 <vector204>:
.globl vector204
vector204:
  pushl $0
801079f6:	6a 00                	push   $0x0
  pushl $204
801079f8:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801079fd:	e9 74 f1 ff ff       	jmp    80106b76 <alltraps>

80107a02 <vector205>:
.globl vector205
vector205:
  pushl $0
80107a02:	6a 00                	push   $0x0
  pushl $205
80107a04:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107a09:	e9 68 f1 ff ff       	jmp    80106b76 <alltraps>

80107a0e <vector206>:
.globl vector206
vector206:
  pushl $0
80107a0e:	6a 00                	push   $0x0
  pushl $206
80107a10:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107a15:	e9 5c f1 ff ff       	jmp    80106b76 <alltraps>

80107a1a <vector207>:
.globl vector207
vector207:
  pushl $0
80107a1a:	6a 00                	push   $0x0
  pushl $207
80107a1c:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107a21:	e9 50 f1 ff ff       	jmp    80106b76 <alltraps>

80107a26 <vector208>:
.globl vector208
vector208:
  pushl $0
80107a26:	6a 00                	push   $0x0
  pushl $208
80107a28:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107a2d:	e9 44 f1 ff ff       	jmp    80106b76 <alltraps>

80107a32 <vector209>:
.globl vector209
vector209:
  pushl $0
80107a32:	6a 00                	push   $0x0
  pushl $209
80107a34:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107a39:	e9 38 f1 ff ff       	jmp    80106b76 <alltraps>

80107a3e <vector210>:
.globl vector210
vector210:
  pushl $0
80107a3e:	6a 00                	push   $0x0
  pushl $210
80107a40:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107a45:	e9 2c f1 ff ff       	jmp    80106b76 <alltraps>

80107a4a <vector211>:
.globl vector211
vector211:
  pushl $0
80107a4a:	6a 00                	push   $0x0
  pushl $211
80107a4c:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107a51:	e9 20 f1 ff ff       	jmp    80106b76 <alltraps>

80107a56 <vector212>:
.globl vector212
vector212:
  pushl $0
80107a56:	6a 00                	push   $0x0
  pushl $212
80107a58:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107a5d:	e9 14 f1 ff ff       	jmp    80106b76 <alltraps>

80107a62 <vector213>:
.globl vector213
vector213:
  pushl $0
80107a62:	6a 00                	push   $0x0
  pushl $213
80107a64:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107a69:	e9 08 f1 ff ff       	jmp    80106b76 <alltraps>

80107a6e <vector214>:
.globl vector214
vector214:
  pushl $0
80107a6e:	6a 00                	push   $0x0
  pushl $214
80107a70:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107a75:	e9 fc f0 ff ff       	jmp    80106b76 <alltraps>

80107a7a <vector215>:
.globl vector215
vector215:
  pushl $0
80107a7a:	6a 00                	push   $0x0
  pushl $215
80107a7c:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107a81:	e9 f0 f0 ff ff       	jmp    80106b76 <alltraps>

80107a86 <vector216>:
.globl vector216
vector216:
  pushl $0
80107a86:	6a 00                	push   $0x0
  pushl $216
80107a88:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107a8d:	e9 e4 f0 ff ff       	jmp    80106b76 <alltraps>

80107a92 <vector217>:
.globl vector217
vector217:
  pushl $0
80107a92:	6a 00                	push   $0x0
  pushl $217
80107a94:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107a99:	e9 d8 f0 ff ff       	jmp    80106b76 <alltraps>

80107a9e <vector218>:
.globl vector218
vector218:
  pushl $0
80107a9e:	6a 00                	push   $0x0
  pushl $218
80107aa0:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107aa5:	e9 cc f0 ff ff       	jmp    80106b76 <alltraps>

80107aaa <vector219>:
.globl vector219
vector219:
  pushl $0
80107aaa:	6a 00                	push   $0x0
  pushl $219
80107aac:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107ab1:	e9 c0 f0 ff ff       	jmp    80106b76 <alltraps>

80107ab6 <vector220>:
.globl vector220
vector220:
  pushl $0
80107ab6:	6a 00                	push   $0x0
  pushl $220
80107ab8:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107abd:	e9 b4 f0 ff ff       	jmp    80106b76 <alltraps>

80107ac2 <vector221>:
.globl vector221
vector221:
  pushl $0
80107ac2:	6a 00                	push   $0x0
  pushl $221
80107ac4:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107ac9:	e9 a8 f0 ff ff       	jmp    80106b76 <alltraps>

80107ace <vector222>:
.globl vector222
vector222:
  pushl $0
80107ace:	6a 00                	push   $0x0
  pushl $222
80107ad0:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107ad5:	e9 9c f0 ff ff       	jmp    80106b76 <alltraps>

80107ada <vector223>:
.globl vector223
vector223:
  pushl $0
80107ada:	6a 00                	push   $0x0
  pushl $223
80107adc:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107ae1:	e9 90 f0 ff ff       	jmp    80106b76 <alltraps>

80107ae6 <vector224>:
.globl vector224
vector224:
  pushl $0
80107ae6:	6a 00                	push   $0x0
  pushl $224
80107ae8:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107aed:	e9 84 f0 ff ff       	jmp    80106b76 <alltraps>

80107af2 <vector225>:
.globl vector225
vector225:
  pushl $0
80107af2:	6a 00                	push   $0x0
  pushl $225
80107af4:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107af9:	e9 78 f0 ff ff       	jmp    80106b76 <alltraps>

80107afe <vector226>:
.globl vector226
vector226:
  pushl $0
80107afe:	6a 00                	push   $0x0
  pushl $226
80107b00:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107b05:	e9 6c f0 ff ff       	jmp    80106b76 <alltraps>

80107b0a <vector227>:
.globl vector227
vector227:
  pushl $0
80107b0a:	6a 00                	push   $0x0
  pushl $227
80107b0c:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107b11:	e9 60 f0 ff ff       	jmp    80106b76 <alltraps>

80107b16 <vector228>:
.globl vector228
vector228:
  pushl $0
80107b16:	6a 00                	push   $0x0
  pushl $228
80107b18:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107b1d:	e9 54 f0 ff ff       	jmp    80106b76 <alltraps>

80107b22 <vector229>:
.globl vector229
vector229:
  pushl $0
80107b22:	6a 00                	push   $0x0
  pushl $229
80107b24:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107b29:	e9 48 f0 ff ff       	jmp    80106b76 <alltraps>

80107b2e <vector230>:
.globl vector230
vector230:
  pushl $0
80107b2e:	6a 00                	push   $0x0
  pushl $230
80107b30:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107b35:	e9 3c f0 ff ff       	jmp    80106b76 <alltraps>

80107b3a <vector231>:
.globl vector231
vector231:
  pushl $0
80107b3a:	6a 00                	push   $0x0
  pushl $231
80107b3c:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107b41:	e9 30 f0 ff ff       	jmp    80106b76 <alltraps>

80107b46 <vector232>:
.globl vector232
vector232:
  pushl $0
80107b46:	6a 00                	push   $0x0
  pushl $232
80107b48:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107b4d:	e9 24 f0 ff ff       	jmp    80106b76 <alltraps>

80107b52 <vector233>:
.globl vector233
vector233:
  pushl $0
80107b52:	6a 00                	push   $0x0
  pushl $233
80107b54:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107b59:	e9 18 f0 ff ff       	jmp    80106b76 <alltraps>

80107b5e <vector234>:
.globl vector234
vector234:
  pushl $0
80107b5e:	6a 00                	push   $0x0
  pushl $234
80107b60:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107b65:	e9 0c f0 ff ff       	jmp    80106b76 <alltraps>

80107b6a <vector235>:
.globl vector235
vector235:
  pushl $0
80107b6a:	6a 00                	push   $0x0
  pushl $235
80107b6c:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107b71:	e9 00 f0 ff ff       	jmp    80106b76 <alltraps>

80107b76 <vector236>:
.globl vector236
vector236:
  pushl $0
80107b76:	6a 00                	push   $0x0
  pushl $236
80107b78:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107b7d:	e9 f4 ef ff ff       	jmp    80106b76 <alltraps>

80107b82 <vector237>:
.globl vector237
vector237:
  pushl $0
80107b82:	6a 00                	push   $0x0
  pushl $237
80107b84:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107b89:	e9 e8 ef ff ff       	jmp    80106b76 <alltraps>

80107b8e <vector238>:
.globl vector238
vector238:
  pushl $0
80107b8e:	6a 00                	push   $0x0
  pushl $238
80107b90:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107b95:	e9 dc ef ff ff       	jmp    80106b76 <alltraps>

80107b9a <vector239>:
.globl vector239
vector239:
  pushl $0
80107b9a:	6a 00                	push   $0x0
  pushl $239
80107b9c:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107ba1:	e9 d0 ef ff ff       	jmp    80106b76 <alltraps>

80107ba6 <vector240>:
.globl vector240
vector240:
  pushl $0
80107ba6:	6a 00                	push   $0x0
  pushl $240
80107ba8:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107bad:	e9 c4 ef ff ff       	jmp    80106b76 <alltraps>

80107bb2 <vector241>:
.globl vector241
vector241:
  pushl $0
80107bb2:	6a 00                	push   $0x0
  pushl $241
80107bb4:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107bb9:	e9 b8 ef ff ff       	jmp    80106b76 <alltraps>

80107bbe <vector242>:
.globl vector242
vector242:
  pushl $0
80107bbe:	6a 00                	push   $0x0
  pushl $242
80107bc0:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107bc5:	e9 ac ef ff ff       	jmp    80106b76 <alltraps>

80107bca <vector243>:
.globl vector243
vector243:
  pushl $0
80107bca:	6a 00                	push   $0x0
  pushl $243
80107bcc:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107bd1:	e9 a0 ef ff ff       	jmp    80106b76 <alltraps>

80107bd6 <vector244>:
.globl vector244
vector244:
  pushl $0
80107bd6:	6a 00                	push   $0x0
  pushl $244
80107bd8:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107bdd:	e9 94 ef ff ff       	jmp    80106b76 <alltraps>

80107be2 <vector245>:
.globl vector245
vector245:
  pushl $0
80107be2:	6a 00                	push   $0x0
  pushl $245
80107be4:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107be9:	e9 88 ef ff ff       	jmp    80106b76 <alltraps>

80107bee <vector246>:
.globl vector246
vector246:
  pushl $0
80107bee:	6a 00                	push   $0x0
  pushl $246
80107bf0:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107bf5:	e9 7c ef ff ff       	jmp    80106b76 <alltraps>

80107bfa <vector247>:
.globl vector247
vector247:
  pushl $0
80107bfa:	6a 00                	push   $0x0
  pushl $247
80107bfc:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107c01:	e9 70 ef ff ff       	jmp    80106b76 <alltraps>

80107c06 <vector248>:
.globl vector248
vector248:
  pushl $0
80107c06:	6a 00                	push   $0x0
  pushl $248
80107c08:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107c0d:	e9 64 ef ff ff       	jmp    80106b76 <alltraps>

80107c12 <vector249>:
.globl vector249
vector249:
  pushl $0
80107c12:	6a 00                	push   $0x0
  pushl $249
80107c14:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107c19:	e9 58 ef ff ff       	jmp    80106b76 <alltraps>

80107c1e <vector250>:
.globl vector250
vector250:
  pushl $0
80107c1e:	6a 00                	push   $0x0
  pushl $250
80107c20:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107c25:	e9 4c ef ff ff       	jmp    80106b76 <alltraps>

80107c2a <vector251>:
.globl vector251
vector251:
  pushl $0
80107c2a:	6a 00                	push   $0x0
  pushl $251
80107c2c:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107c31:	e9 40 ef ff ff       	jmp    80106b76 <alltraps>

80107c36 <vector252>:
.globl vector252
vector252:
  pushl $0
80107c36:	6a 00                	push   $0x0
  pushl $252
80107c38:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107c3d:	e9 34 ef ff ff       	jmp    80106b76 <alltraps>

80107c42 <vector253>:
.globl vector253
vector253:
  pushl $0
80107c42:	6a 00                	push   $0x0
  pushl $253
80107c44:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107c49:	e9 28 ef ff ff       	jmp    80106b76 <alltraps>

80107c4e <vector254>:
.globl vector254
vector254:
  pushl $0
80107c4e:	6a 00                	push   $0x0
  pushl $254
80107c50:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107c55:	e9 1c ef ff ff       	jmp    80106b76 <alltraps>

80107c5a <vector255>:
.globl vector255
vector255:
  pushl $0
80107c5a:	6a 00                	push   $0x0
  pushl $255
80107c5c:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107c61:	e9 10 ef ff ff       	jmp    80106b76 <alltraps>

80107c66 <lgdt>:
{
80107c66:	55                   	push   %ebp
80107c67:	89 e5                	mov    %esp,%ebp
80107c69:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107c6c:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c6f:	83 e8 01             	sub    $0x1,%eax
80107c72:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107c76:	8b 45 08             	mov    0x8(%ebp),%eax
80107c79:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107c7d:	8b 45 08             	mov    0x8(%ebp),%eax
80107c80:	c1 e8 10             	shr    $0x10,%eax
80107c83:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107c87:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107c8a:	0f 01 10             	lgdtl  (%eax)
}
80107c8d:	90                   	nop
80107c8e:	c9                   	leave  
80107c8f:	c3                   	ret    

80107c90 <ltr>:
{
80107c90:	55                   	push   %ebp
80107c91:	89 e5                	mov    %esp,%ebp
80107c93:	83 ec 04             	sub    $0x4,%esp
80107c96:	8b 45 08             	mov    0x8(%ebp),%eax
80107c99:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107c9d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107ca1:	0f 00 d8             	ltr    %ax
}
80107ca4:	90                   	nop
80107ca5:	c9                   	leave  
80107ca6:	c3                   	ret    

80107ca7 <lcr3>:

static inline void
lcr3(uint val)
{
80107ca7:	55                   	push   %ebp
80107ca8:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107caa:	8b 45 08             	mov    0x8(%ebp),%eax
80107cad:	0f 22 d8             	mov    %eax,%cr3
}
80107cb0:	90                   	nop
80107cb1:	5d                   	pop    %ebp
80107cb2:	c3                   	ret    

80107cb3 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107cb3:	f3 0f 1e fb          	endbr32 
80107cb7:	55                   	push   %ebp
80107cb8:	89 e5                	mov    %esp,%ebp
80107cba:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107cbd:	e8 c4 c7 ff ff       	call   80104486 <cpuid>
80107cc2:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107cc8:	05 20 58 11 80       	add    $0x80115820,%eax
80107ccd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107cd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd3:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cdc:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce5:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cec:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107cf0:	83 e2 f0             	and    $0xfffffff0,%edx
80107cf3:	83 ca 0a             	or     $0xa,%edx
80107cf6:	88 50 7d             	mov    %dl,0x7d(%eax)
80107cf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cfc:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107d00:	83 ca 10             	or     $0x10,%edx
80107d03:	88 50 7d             	mov    %dl,0x7d(%eax)
80107d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d09:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107d0d:	83 e2 9f             	and    $0xffffff9f,%edx
80107d10:	88 50 7d             	mov    %dl,0x7d(%eax)
80107d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d16:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107d1a:	83 ca 80             	or     $0xffffff80,%edx
80107d1d:	88 50 7d             	mov    %dl,0x7d(%eax)
80107d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d23:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d27:	83 ca 0f             	or     $0xf,%edx
80107d2a:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d30:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d34:	83 e2 ef             	and    $0xffffffef,%edx
80107d37:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d41:	83 e2 df             	and    $0xffffffdf,%edx
80107d44:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d4e:	83 ca 40             	or     $0x40,%edx
80107d51:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d57:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d5b:	83 ca 80             	or     $0xffffff80,%edx
80107d5e:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d64:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6b:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107d72:	ff ff 
80107d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d77:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107d7e:	00 00 
80107d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d83:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107d8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d8d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d94:	83 e2 f0             	and    $0xfffffff0,%edx
80107d97:	83 ca 02             	or     $0x2,%edx
80107d9a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107da0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da3:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107daa:	83 ca 10             	or     $0x10,%edx
80107dad:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107db3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db6:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107dbd:	83 e2 9f             	and    $0xffffff9f,%edx
80107dc0:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107dc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc9:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107dd0:	83 ca 80             	or     $0xffffff80,%edx
80107dd3:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ddc:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107de3:	83 ca 0f             	or     $0xf,%edx
80107de6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107def:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107df6:	83 e2 ef             	and    $0xffffffef,%edx
80107df9:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107dff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e02:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e09:	83 e2 df             	and    $0xffffffdf,%edx
80107e0c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e15:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e1c:	83 ca 40             	or     $0x40,%edx
80107e1f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e28:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e2f:	83 ca 80             	or     $0xffffff80,%edx
80107e32:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e3b:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e45:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107e4c:	ff ff 
80107e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e51:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107e58:	00 00 
80107e5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5d:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107e64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e67:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107e6e:	83 e2 f0             	and    $0xfffffff0,%edx
80107e71:	83 ca 0a             	or     $0xa,%edx
80107e74:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e7d:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107e84:	83 ca 10             	or     $0x10,%edx
80107e87:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e90:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107e97:	83 ca 60             	or     $0x60,%edx
80107e9a:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea3:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107eaa:	83 ca 80             	or     $0xffffff80,%edx
80107ead:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb6:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107ebd:	83 ca 0f             	or     $0xf,%edx
80107ec0:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107ec6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec9:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107ed0:	83 e2 ef             	and    $0xffffffef,%edx
80107ed3:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107ed9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107edc:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107ee3:	83 e2 df             	and    $0xffffffdf,%edx
80107ee6:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107eec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eef:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107ef6:	83 ca 40             	or     $0x40,%edx
80107ef9:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107eff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f02:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107f09:	83 ca 80             	or     $0xffffff80,%edx
80107f0c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107f12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f15:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f1f:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107f26:	ff ff 
80107f28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f2b:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107f32:	00 00 
80107f34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f37:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107f3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f41:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107f48:	83 e2 f0             	and    $0xfffffff0,%edx
80107f4b:	83 ca 02             	or     $0x2,%edx
80107f4e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107f54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f57:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107f5e:	83 ca 10             	or     $0x10,%edx
80107f61:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107f67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107f71:	83 ca 60             	or     $0x60,%edx
80107f74:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107f7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f7d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107f84:	83 ca 80             	or     $0xffffff80,%edx
80107f87:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f90:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f97:	83 ca 0f             	or     $0xf,%edx
80107f9a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107fa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa3:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107faa:	83 e2 ef             	and    $0xffffffef,%edx
80107fad:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fb6:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107fbd:	83 e2 df             	and    $0xffffffdf,%edx
80107fc0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107fc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107fd0:	83 ca 40             	or     $0x40,%edx
80107fd3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107fd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fdc:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107fe3:	83 ca 80             	or     $0xffffff80,%edx
80107fe6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107fec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fef:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff9:	83 c0 70             	add    $0x70,%eax
80107ffc:	83 ec 08             	sub    $0x8,%esp
80107fff:	6a 30                	push   $0x30
80108001:	50                   	push   %eax
80108002:	e8 5f fc ff ff       	call   80107c66 <lgdt>
80108007:	83 c4 10             	add    $0x10,%esp
}
8010800a:	90                   	nop
8010800b:	c9                   	leave  
8010800c:	c3                   	ret    

8010800d <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010800d:	f3 0f 1e fb          	endbr32 
80108011:	55                   	push   %ebp
80108012:	89 e5                	mov    %esp,%ebp
80108014:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;
  pte_t* pte = P2V((PTE_ADDR((char*)va)));
80108017:	8b 45 0c             	mov    0xc(%ebp),%eax
8010801a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010801f:	05 00 00 00 80       	add    $0x80000000,%eax
80108024:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *pte = *pte | PTE_A;
80108027:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010802a:	8b 00                	mov    (%eax),%eax
8010802c:	83 c8 20             	or     $0x20,%eax
8010802f:	89 c2                	mov    %eax,%edx
80108031:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108034:	89 10                	mov    %edx,(%eax)
  pde = &pgdir[PDX(va)];
80108036:	8b 45 0c             	mov    0xc(%ebp),%eax
80108039:	c1 e8 16             	shr    $0x16,%eax
8010803c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108043:	8b 45 08             	mov    0x8(%ebp),%eax
80108046:	01 d0                	add    %edx,%eax
80108048:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(*pde & PTE_P){
8010804b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010804e:	8b 00                	mov    (%eax),%eax
80108050:	83 e0 01             	and    $0x1,%eax
80108053:	85 c0                	test   %eax,%eax
80108055:	74 14                	je     8010806b <walkpgdir+0x5e>
    //if (!alloc)
      //cprintf("page directory is good\n");
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80108057:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010805a:	8b 00                	mov    (%eax),%eax
8010805c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108061:	05 00 00 00 80       	add    $0x80000000,%eax
80108066:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108069:	eb 42                	jmp    801080ad <walkpgdir+0xa0>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010806b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010806f:	74 0e                	je     8010807f <walkpgdir+0x72>
80108071:	e8 e7 ad ff ff       	call   80102e5d <kalloc>
80108076:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108079:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010807d:	75 07                	jne    80108086 <walkpgdir+0x79>
      return 0;
8010807f:	b8 00 00 00 00       	mov    $0x0,%eax
80108084:	eb 3e                	jmp    801080c4 <walkpgdir+0xb7>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108086:	83 ec 04             	sub    $0x4,%esp
80108089:	68 00 10 00 00       	push   $0x1000
8010808e:	6a 00                	push   $0x0
80108090:	ff 75 f4             	pushl  -0xc(%ebp)
80108093:	e8 80 d5 ff ff       	call   80105618 <memset>
80108098:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010809b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010809e:	05 00 00 00 80       	add    $0x80000000,%eax
801080a3:	83 c8 07             	or     $0x7,%eax
801080a6:	89 c2                	mov    %eax,%edx
801080a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080ab:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801080ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801080b0:	c1 e8 0c             	shr    $0xc,%eax
801080b3:	25 ff 03 00 00       	and    $0x3ff,%eax
801080b8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801080bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080c2:	01 d0                	add    %edx,%eax
}
801080c4:	c9                   	leave  
801080c5:	c3                   	ret    

801080c6 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801080c6:	f3 0f 1e fb          	endbr32 
801080ca:	55                   	push   %ebp
801080cb:	89 e5                	mov    %esp,%ebp
801080cd:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801080d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801080d3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801080db:	8b 55 0c             	mov    0xc(%ebp),%edx
801080de:	8b 45 10             	mov    0x10(%ebp),%eax
801080e1:	01 d0                	add    %edx,%eax
801080e3:	83 e8 01             	sub    $0x1,%eax
801080e6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801080ee:	83 ec 04             	sub    $0x4,%esp
801080f1:	6a 01                	push   $0x1
801080f3:	ff 75 f4             	pushl  -0xc(%ebp)
801080f6:	ff 75 08             	pushl  0x8(%ebp)
801080f9:	e8 0f ff ff ff       	call   8010800d <walkpgdir>
801080fe:	83 c4 10             	add    $0x10,%esp
80108101:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108104:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108108:	75 07                	jne    80108111 <mappages+0x4b>
      return -1;
8010810a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010810f:	eb 7a                	jmp    8010818b <mappages+0xc5>
    if(*pte & (PTE_P | PTE_E))
80108111:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108114:	8b 00                	mov    (%eax),%eax
80108116:	25 01 04 00 00       	and    $0x401,%eax
8010811b:	85 c0                	test   %eax,%eax
8010811d:	74 0d                	je     8010812c <mappages+0x66>
      panic("p4Debug, remapping page");
8010811f:	83 ec 0c             	sub    $0xc,%esp
80108122:	68 b4 9b 10 80       	push   $0x80109bb4
80108127:	e8 dc 84 ff ff       	call   80100608 <panic>

    if (perm & PTE_E)
8010812c:	8b 45 18             	mov    0x18(%ebp),%eax
8010812f:	25 00 04 00 00       	and    $0x400,%eax
80108134:	85 c0                	test   %eax,%eax
80108136:	74 22                	je     8010815a <mappages+0x94>
    { *pte = pa | perm | PTE_E;
80108138:	8b 45 18             	mov    0x18(%ebp),%eax
8010813b:	0b 45 14             	or     0x14(%ebp),%eax
8010813e:	80 cc 04             	or     $0x4,%ah
80108141:	89 c2                	mov    %eax,%edx
80108143:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108146:	89 10                	mov    %edx,(%eax)
	    cprintf("juudas");}
80108148:	83 ec 0c             	sub    $0xc,%esp
8010814b:	68 cc 9b 10 80       	push   $0x80109bcc
80108150:	e8 c3 82 ff ff       	call   80100418 <cprintf>
80108155:	83 c4 10             	add    $0x10,%esp
80108158:	eb 10                	jmp    8010816a <mappages+0xa4>
    else
      *pte = pa | perm | PTE_P;
8010815a:	8b 45 18             	mov    0x18(%ebp),%eax
8010815d:	0b 45 14             	or     0x14(%ebp),%eax
80108160:	83 c8 01             	or     $0x1,%eax
80108163:	89 c2                	mov    %eax,%edx
80108165:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108168:	89 10                	mov    %edx,(%eax)


    if(a == last)
8010816a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010816d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108170:	74 13                	je     80108185 <mappages+0xbf>
      break;
    a += PGSIZE;
80108172:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108179:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108180:	e9 69 ff ff ff       	jmp    801080ee <mappages+0x28>
      break;
80108185:	90                   	nop
  }
  return 0;
80108186:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010818b:	c9                   	leave  
8010818c:	c3                   	ret    

8010818d <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
8010818d:	f3 0f 1e fb          	endbr32 
80108191:	55                   	push   %ebp
80108192:	89 e5                	mov    %esp,%ebp
80108194:	53                   	push   %ebx
80108195:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108198:	e8 c0 ac ff ff       	call   80102e5d <kalloc>
8010819d:	89 45 f0             	mov    %eax,-0x10(%ebp)
801081a0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801081a4:	75 07                	jne    801081ad <setupkvm+0x20>
    return 0;
801081a6:	b8 00 00 00 00       	mov    $0x0,%eax
801081ab:	eb 78                	jmp    80108225 <setupkvm+0x98>
  memset(pgdir, 0, PGSIZE);
801081ad:	83 ec 04             	sub    $0x4,%esp
801081b0:	68 00 10 00 00       	push   $0x1000
801081b5:	6a 00                	push   $0x0
801081b7:	ff 75 f0             	pushl  -0x10(%ebp)
801081ba:	e8 59 d4 ff ff       	call   80105618 <memset>
801081bf:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801081c2:	c7 45 f4 a0 d4 10 80 	movl   $0x8010d4a0,-0xc(%ebp)
801081c9:	eb 4e                	jmp    80108219 <setupkvm+0x8c>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801081cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ce:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
801081d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081d4:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801081d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081da:	8b 58 08             	mov    0x8(%eax),%ebx
801081dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081e0:	8b 40 04             	mov    0x4(%eax),%eax
801081e3:	29 c3                	sub    %eax,%ebx
801081e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081e8:	8b 00                	mov    (%eax),%eax
801081ea:	83 ec 0c             	sub    $0xc,%esp
801081ed:	51                   	push   %ecx
801081ee:	52                   	push   %edx
801081ef:	53                   	push   %ebx
801081f0:	50                   	push   %eax
801081f1:	ff 75 f0             	pushl  -0x10(%ebp)
801081f4:	e8 cd fe ff ff       	call   801080c6 <mappages>
801081f9:	83 c4 20             	add    $0x20,%esp
801081fc:	85 c0                	test   %eax,%eax
801081fe:	79 15                	jns    80108215 <setupkvm+0x88>
      freevm(pgdir);
80108200:	83 ec 0c             	sub    $0xc,%esp
80108203:	ff 75 f0             	pushl  -0x10(%ebp)
80108206:	e8 13 05 00 00       	call   8010871e <freevm>
8010820b:	83 c4 10             	add    $0x10,%esp
      return 0;
8010820e:	b8 00 00 00 00       	mov    $0x0,%eax
80108213:	eb 10                	jmp    80108225 <setupkvm+0x98>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108215:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108219:	81 7d f4 e0 d4 10 80 	cmpl   $0x8010d4e0,-0xc(%ebp)
80108220:	72 a9                	jb     801081cb <setupkvm+0x3e>
    }
  return pgdir;
80108222:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108225:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108228:	c9                   	leave  
80108229:	c3                   	ret    

8010822a <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
8010822a:	f3 0f 1e fb          	endbr32 
8010822e:	55                   	push   %ebp
8010822f:	89 e5                	mov    %esp,%ebp
80108231:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108234:	e8 54 ff ff ff       	call   8010818d <setupkvm>
80108239:	a3 44 8e 11 80       	mov    %eax,0x80118e44
  switchkvm();
8010823e:	e8 03 00 00 00       	call   80108246 <switchkvm>
}
80108243:	90                   	nop
80108244:	c9                   	leave  
80108245:	c3                   	ret    

80108246 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108246:	f3 0f 1e fb          	endbr32 
8010824a:	55                   	push   %ebp
8010824b:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
8010824d:	a1 44 8e 11 80       	mov    0x80118e44,%eax
80108252:	05 00 00 00 80       	add    $0x80000000,%eax
80108257:	50                   	push   %eax
80108258:	e8 4a fa ff ff       	call   80107ca7 <lcr3>
8010825d:	83 c4 04             	add    $0x4,%esp
}
80108260:	90                   	nop
80108261:	c9                   	leave  
80108262:	c3                   	ret    

80108263 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108263:	f3 0f 1e fb          	endbr32 
80108267:	55                   	push   %ebp
80108268:	89 e5                	mov    %esp,%ebp
8010826a:	56                   	push   %esi
8010826b:	53                   	push   %ebx
8010826c:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
8010826f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108273:	75 0d                	jne    80108282 <switchuvm+0x1f>
    panic("switchuvm: no process");
80108275:	83 ec 0c             	sub    $0xc,%esp
80108278:	68 d3 9b 10 80       	push   $0x80109bd3
8010827d:	e8 86 83 ff ff       	call   80100608 <panic>
  if(p->kstack == 0)
80108282:	8b 45 08             	mov    0x8(%ebp),%eax
80108285:	8b 40 08             	mov    0x8(%eax),%eax
80108288:	85 c0                	test   %eax,%eax
8010828a:	75 0d                	jne    80108299 <switchuvm+0x36>
    panic("switchuvm: no kstack");
8010828c:	83 ec 0c             	sub    $0xc,%esp
8010828f:	68 e9 9b 10 80       	push   $0x80109be9
80108294:	e8 6f 83 ff ff       	call   80100608 <panic>
  if(p->pgdir == 0)
80108299:	8b 45 08             	mov    0x8(%ebp),%eax
8010829c:	8b 40 04             	mov    0x4(%eax),%eax
8010829f:	85 c0                	test   %eax,%eax
801082a1:	75 0d                	jne    801082b0 <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
801082a3:	83 ec 0c             	sub    $0xc,%esp
801082a6:	68 fe 9b 10 80       	push   $0x80109bfe
801082ab:	e8 58 83 ff ff       	call   80100608 <panic>

  pushcli();
801082b0:	e8 50 d2 ff ff       	call   80105505 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801082b5:	e8 eb c1 ff ff       	call   801044a5 <mycpu>
801082ba:	89 c3                	mov    %eax,%ebx
801082bc:	e8 e4 c1 ff ff       	call   801044a5 <mycpu>
801082c1:	83 c0 08             	add    $0x8,%eax
801082c4:	89 c6                	mov    %eax,%esi
801082c6:	e8 da c1 ff ff       	call   801044a5 <mycpu>
801082cb:	83 c0 08             	add    $0x8,%eax
801082ce:	c1 e8 10             	shr    $0x10,%eax
801082d1:	88 45 f7             	mov    %al,-0x9(%ebp)
801082d4:	e8 cc c1 ff ff       	call   801044a5 <mycpu>
801082d9:	83 c0 08             	add    $0x8,%eax
801082dc:	c1 e8 18             	shr    $0x18,%eax
801082df:	89 c2                	mov    %eax,%edx
801082e1:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801082e8:	67 00 
801082ea:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
801082f1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
801082f5:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
801082fb:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108302:	83 e0 f0             	and    $0xfffffff0,%eax
80108305:	83 c8 09             	or     $0x9,%eax
80108308:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010830e:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108315:	83 c8 10             	or     $0x10,%eax
80108318:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010831e:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108325:	83 e0 9f             	and    $0xffffff9f,%eax
80108328:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010832e:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108335:	83 c8 80             	or     $0xffffff80,%eax
80108338:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010833e:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108345:	83 e0 f0             	and    $0xfffffff0,%eax
80108348:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010834e:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108355:	83 e0 ef             	and    $0xffffffef,%eax
80108358:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010835e:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108365:	83 e0 df             	and    $0xffffffdf,%eax
80108368:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010836e:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108375:	83 c8 40             	or     $0x40,%eax
80108378:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010837e:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108385:	83 e0 7f             	and    $0x7f,%eax
80108388:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010838e:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80108394:	e8 0c c1 ff ff       	call   801044a5 <mycpu>
80108399:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801083a0:	83 e2 ef             	and    $0xffffffef,%edx
801083a3:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801083a9:	e8 f7 c0 ff ff       	call   801044a5 <mycpu>
801083ae:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801083b4:	8b 45 08             	mov    0x8(%ebp),%eax
801083b7:	8b 40 08             	mov    0x8(%eax),%eax
801083ba:	89 c3                	mov    %eax,%ebx
801083bc:	e8 e4 c0 ff ff       	call   801044a5 <mycpu>
801083c1:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
801083c7:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801083ca:	e8 d6 c0 ff ff       	call   801044a5 <mycpu>
801083cf:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
801083d5:	83 ec 0c             	sub    $0xc,%esp
801083d8:	6a 28                	push   $0x28
801083da:	e8 b1 f8 ff ff       	call   80107c90 <ltr>
801083df:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
801083e2:	8b 45 08             	mov    0x8(%ebp),%eax
801083e5:	8b 40 04             	mov    0x4(%eax),%eax
801083e8:	05 00 00 00 80       	add    $0x80000000,%eax
801083ed:	83 ec 0c             	sub    $0xc,%esp
801083f0:	50                   	push   %eax
801083f1:	e8 b1 f8 ff ff       	call   80107ca7 <lcr3>
801083f6:	83 c4 10             	add    $0x10,%esp
  popcli();
801083f9:	e8 58 d1 ff ff       	call   80105556 <popcli>
}
801083fe:	90                   	nop
801083ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108402:	5b                   	pop    %ebx
80108403:	5e                   	pop    %esi
80108404:	5d                   	pop    %ebp
80108405:	c3                   	ret    

80108406 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108406:	f3 0f 1e fb          	endbr32 
8010840a:	55                   	push   %ebp
8010840b:	89 e5                	mov    %esp,%ebp
8010840d:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80108410:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108417:	76 0d                	jbe    80108426 <inituvm+0x20>
    panic("inituvm: more than a page");
80108419:	83 ec 0c             	sub    $0xc,%esp
8010841c:	68 12 9c 10 80       	push   $0x80109c12
80108421:	e8 e2 81 ff ff       	call   80100608 <panic>
  mem = kalloc();
80108426:	e8 32 aa ff ff       	call   80102e5d <kalloc>
8010842b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010842e:	83 ec 04             	sub    $0x4,%esp
80108431:	68 00 10 00 00       	push   $0x1000
80108436:	6a 00                	push   $0x0
80108438:	ff 75 f4             	pushl  -0xc(%ebp)
8010843b:	e8 d8 d1 ff ff       	call   80105618 <memset>
80108440:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80108443:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108446:	05 00 00 00 80       	add    $0x80000000,%eax
8010844b:	83 ec 0c             	sub    $0xc,%esp
8010844e:	6a 06                	push   $0x6
80108450:	50                   	push   %eax
80108451:	68 00 10 00 00       	push   $0x1000
80108456:	6a 00                	push   $0x0
80108458:	ff 75 08             	pushl  0x8(%ebp)
8010845b:	e8 66 fc ff ff       	call   801080c6 <mappages>
80108460:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108463:	83 ec 04             	sub    $0x4,%esp
80108466:	ff 75 10             	pushl  0x10(%ebp)
80108469:	ff 75 0c             	pushl  0xc(%ebp)
8010846c:	ff 75 f4             	pushl  -0xc(%ebp)
8010846f:	e8 6b d2 ff ff       	call   801056df <memmove>
80108474:	83 c4 10             	add    $0x10,%esp
}
80108477:	90                   	nop
80108478:	c9                   	leave  
80108479:	c3                   	ret    

8010847a <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010847a:	f3 0f 1e fb          	endbr32 
8010847e:	55                   	push   %ebp
8010847f:	89 e5                	mov    %esp,%ebp
80108481:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108484:	8b 45 0c             	mov    0xc(%ebp),%eax
80108487:	25 ff 0f 00 00       	and    $0xfff,%eax
8010848c:	85 c0                	test   %eax,%eax
8010848e:	74 0d                	je     8010849d <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
80108490:	83 ec 0c             	sub    $0xc,%esp
80108493:	68 2c 9c 10 80       	push   $0x80109c2c
80108498:	e8 6b 81 ff ff       	call   80100608 <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010849d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801084a4:	e9 8f 00 00 00       	jmp    80108538 <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801084a9:	8b 55 0c             	mov    0xc(%ebp),%edx
801084ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084af:	01 d0                	add    %edx,%eax
801084b1:	83 ec 04             	sub    $0x4,%esp
801084b4:	6a 00                	push   $0x0
801084b6:	50                   	push   %eax
801084b7:	ff 75 08             	pushl  0x8(%ebp)
801084ba:	e8 4e fb ff ff       	call   8010800d <walkpgdir>
801084bf:	83 c4 10             	add    $0x10,%esp
801084c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
801084c5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801084c9:	75 0d                	jne    801084d8 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
801084cb:	83 ec 0c             	sub    $0xc,%esp
801084ce:	68 4f 9c 10 80       	push   $0x80109c4f
801084d3:	e8 30 81 ff ff       	call   80100608 <panic>
    pa = PTE_ADDR(*pte);
801084d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084db:	8b 00                	mov    (%eax),%eax
801084dd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084e2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801084e5:	8b 45 18             	mov    0x18(%ebp),%eax
801084e8:	2b 45 f4             	sub    -0xc(%ebp),%eax
801084eb:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801084f0:	77 0b                	ja     801084fd <loaduvm+0x83>
      n = sz - i;
801084f2:	8b 45 18             	mov    0x18(%ebp),%eax
801084f5:	2b 45 f4             	sub    -0xc(%ebp),%eax
801084f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801084fb:	eb 07                	jmp    80108504 <loaduvm+0x8a>
    else
      n = PGSIZE;
801084fd:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108504:	8b 55 14             	mov    0x14(%ebp),%edx
80108507:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010850a:	01 d0                	add    %edx,%eax
8010850c:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010850f:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108515:	ff 75 f0             	pushl  -0x10(%ebp)
80108518:	50                   	push   %eax
80108519:	52                   	push   %edx
8010851a:	ff 75 10             	pushl  0x10(%ebp)
8010851d:	e8 53 9b ff ff       	call   80102075 <readi>
80108522:	83 c4 10             	add    $0x10,%esp
80108525:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80108528:	74 07                	je     80108531 <loaduvm+0xb7>
      return -1;
8010852a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010852f:	eb 18                	jmp    80108549 <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
80108531:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108538:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010853b:	3b 45 18             	cmp    0x18(%ebp),%eax
8010853e:	0f 82 65 ff ff ff    	jb     801084a9 <loaduvm+0x2f>
  }
  return 0;
80108544:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108549:	c9                   	leave  
8010854a:	c3                   	ret    

8010854b <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010854b:	f3 0f 1e fb          	endbr32 
8010854f:	55                   	push   %ebp
80108550:	89 e5                	mov    %esp,%ebp
80108552:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108555:	8b 45 10             	mov    0x10(%ebp),%eax
80108558:	85 c0                	test   %eax,%eax
8010855a:	79 0a                	jns    80108566 <allocuvm+0x1b>
    return 0;
8010855c:	b8 00 00 00 00       	mov    $0x0,%eax
80108561:	e9 ec 00 00 00       	jmp    80108652 <allocuvm+0x107>
  if(newsz < oldsz)
80108566:	8b 45 10             	mov    0x10(%ebp),%eax
80108569:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010856c:	73 08                	jae    80108576 <allocuvm+0x2b>
    return oldsz;
8010856e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108571:	e9 dc 00 00 00       	jmp    80108652 <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
80108576:	8b 45 0c             	mov    0xc(%ebp),%eax
80108579:	05 ff 0f 00 00       	add    $0xfff,%eax
8010857e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108583:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108586:	e9 b8 00 00 00       	jmp    80108643 <allocuvm+0xf8>
    mem = kalloc();
8010858b:	e8 cd a8 ff ff       	call   80102e5d <kalloc>
80108590:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108593:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108597:	75 2e                	jne    801085c7 <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
80108599:	83 ec 0c             	sub    $0xc,%esp
8010859c:	68 6d 9c 10 80       	push   $0x80109c6d
801085a1:	e8 72 7e ff ff       	call   80100418 <cprintf>
801085a6:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801085a9:	83 ec 04             	sub    $0x4,%esp
801085ac:	ff 75 0c             	pushl  0xc(%ebp)
801085af:	ff 75 10             	pushl  0x10(%ebp)
801085b2:	ff 75 08             	pushl  0x8(%ebp)
801085b5:	e8 9a 00 00 00       	call   80108654 <deallocuvm>
801085ba:	83 c4 10             	add    $0x10,%esp
      return 0;
801085bd:	b8 00 00 00 00       	mov    $0x0,%eax
801085c2:	e9 8b 00 00 00       	jmp    80108652 <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
801085c7:	83 ec 04             	sub    $0x4,%esp
801085ca:	68 00 10 00 00       	push   $0x1000
801085cf:	6a 00                	push   $0x0
801085d1:	ff 75 f0             	pushl  -0x10(%ebp)
801085d4:	e8 3f d0 ff ff       	call   80105618 <memset>
801085d9:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801085dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085df:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801085e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085e8:	83 ec 0c             	sub    $0xc,%esp
801085eb:	6a 06                	push   $0x6
801085ed:	52                   	push   %edx
801085ee:	68 00 10 00 00       	push   $0x1000
801085f3:	50                   	push   %eax
801085f4:	ff 75 08             	pushl  0x8(%ebp)
801085f7:	e8 ca fa ff ff       	call   801080c6 <mappages>
801085fc:	83 c4 20             	add    $0x20,%esp
801085ff:	85 c0                	test   %eax,%eax
80108601:	79 39                	jns    8010863c <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
80108603:	83 ec 0c             	sub    $0xc,%esp
80108606:	68 85 9c 10 80       	push   $0x80109c85
8010860b:	e8 08 7e ff ff       	call   80100418 <cprintf>
80108610:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108613:	83 ec 04             	sub    $0x4,%esp
80108616:	ff 75 0c             	pushl  0xc(%ebp)
80108619:	ff 75 10             	pushl  0x10(%ebp)
8010861c:	ff 75 08             	pushl  0x8(%ebp)
8010861f:	e8 30 00 00 00       	call   80108654 <deallocuvm>
80108624:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80108627:	83 ec 0c             	sub    $0xc,%esp
8010862a:	ff 75 f0             	pushl  -0x10(%ebp)
8010862d:	e8 8d a7 ff ff       	call   80102dbf <kfree>
80108632:	83 c4 10             	add    $0x10,%esp
      return 0;
80108635:	b8 00 00 00 00       	mov    $0x0,%eax
8010863a:	eb 16                	jmp    80108652 <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
8010863c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108643:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108646:	3b 45 10             	cmp    0x10(%ebp),%eax
80108649:	0f 82 3c ff ff ff    	jb     8010858b <allocuvm+0x40>
    }
  }
  return newsz;
8010864f:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108652:	c9                   	leave  
80108653:	c3                   	ret    

80108654 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108654:	f3 0f 1e fb          	endbr32 
80108658:	55                   	push   %ebp
80108659:	89 e5                	mov    %esp,%ebp
8010865b:	83 ec 18             	sub    $0x18,%esp
//	cprintf("DDEAD\n");
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010865e:	8b 45 10             	mov    0x10(%ebp),%eax
80108661:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108664:	72 08                	jb     8010866e <deallocuvm+0x1a>
    return oldsz;
80108666:	8b 45 0c             	mov    0xc(%ebp),%eax
80108669:	e9 ae 00 00 00       	jmp    8010871c <deallocuvm+0xc8>

  a = PGROUNDUP(newsz);
8010866e:	8b 45 10             	mov    0x10(%ebp),%eax
80108671:	05 ff 0f 00 00       	add    $0xfff,%eax
80108676:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010867b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010867e:	e9 8a 00 00 00       	jmp    8010870d <deallocuvm+0xb9>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108683:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108686:	83 ec 04             	sub    $0x4,%esp
80108689:	6a 00                	push   $0x0
8010868b:	50                   	push   %eax
8010868c:	ff 75 08             	pushl  0x8(%ebp)
8010868f:	e8 79 f9 ff ff       	call   8010800d <walkpgdir>
80108694:	83 c4 10             	add    $0x10,%esp
80108697:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
8010869a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010869e:	75 16                	jne    801086b6 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801086a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a3:	c1 e8 16             	shr    $0x16,%eax
801086a6:	83 c0 01             	add    $0x1,%eax
801086a9:	c1 e0 16             	shl    $0x16,%eax
801086ac:	2d 00 10 00 00       	sub    $0x1000,%eax
801086b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801086b4:	eb 50                	jmp    80108706 <deallocuvm+0xb2>
    else if((*pte & (PTE_P | PTE_E)) != 0){
801086b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086b9:	8b 00                	mov    (%eax),%eax
801086bb:	25 01 04 00 00       	and    $0x401,%eax
801086c0:	85 c0                	test   %eax,%eax
801086c2:	74 42                	je     80108706 <deallocuvm+0xb2>
      pa = PTE_ADDR(*pte);
801086c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086c7:	8b 00                	mov    (%eax),%eax
801086c9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801086d1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801086d5:	75 0d                	jne    801086e4 <deallocuvm+0x90>
        panic("kfree");
801086d7:	83 ec 0c             	sub    $0xc,%esp
801086da:	68 a1 9c 10 80       	push   $0x80109ca1
801086df:	e8 24 7f ff ff       	call   80100608 <panic>
      char *v = P2V(pa);
801086e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086e7:	05 00 00 00 80       	add    $0x80000000,%eax
801086ec:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801086ef:	83 ec 0c             	sub    $0xc,%esp
801086f2:	ff 75 e8             	pushl  -0x18(%ebp)
801086f5:	e8 c5 a6 ff ff       	call   80102dbf <kfree>
801086fa:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801086fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108700:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80108706:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010870d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108710:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108713:	0f 82 6a ff ff ff    	jb     80108683 <deallocuvm+0x2f>
    }
  }
  return newsz;
80108719:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010871c:	c9                   	leave  
8010871d:	c3                   	ret    

8010871e <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010871e:	f3 0f 1e fb          	endbr32 
80108722:	55                   	push   %ebp
80108723:	89 e5                	mov    %esp,%ebp
80108725:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108728:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010872c:	75 0d                	jne    8010873b <freevm+0x1d>
    panic("freevm: no pgdir");
8010872e:	83 ec 0c             	sub    $0xc,%esp
80108731:	68 a7 9c 10 80       	push   $0x80109ca7
80108736:	e8 cd 7e ff ff       	call   80100608 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010873b:	83 ec 04             	sub    $0x4,%esp
8010873e:	6a 00                	push   $0x0
80108740:	68 00 00 00 80       	push   $0x80000000
80108745:	ff 75 08             	pushl  0x8(%ebp)
80108748:	e8 07 ff ff ff       	call   80108654 <deallocuvm>
8010874d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108750:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108757:	eb 4a                	jmp    801087a3 <freevm+0x85>
    if(pgdir[i] & (PTE_P | PTE_E)){
80108759:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010875c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108763:	8b 45 08             	mov    0x8(%ebp),%eax
80108766:	01 d0                	add    %edx,%eax
80108768:	8b 00                	mov    (%eax),%eax
8010876a:	25 01 04 00 00       	and    $0x401,%eax
8010876f:	85 c0                	test   %eax,%eax
80108771:	74 2c                	je     8010879f <freevm+0x81>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108773:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108776:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010877d:	8b 45 08             	mov    0x8(%ebp),%eax
80108780:	01 d0                	add    %edx,%eax
80108782:	8b 00                	mov    (%eax),%eax
80108784:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108789:	05 00 00 00 80       	add    $0x80000000,%eax
8010878e:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108791:	83 ec 0c             	sub    $0xc,%esp
80108794:	ff 75 f0             	pushl  -0x10(%ebp)
80108797:	e8 23 a6 ff ff       	call   80102dbf <kfree>
8010879c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010879f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801087a3:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801087aa:	76 ad                	jbe    80108759 <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
801087ac:	83 ec 0c             	sub    $0xc,%esp
801087af:	ff 75 08             	pushl  0x8(%ebp)
801087b2:	e8 08 a6 ff ff       	call   80102dbf <kfree>
801087b7:	83 c4 10             	add    $0x10,%esp
}
801087ba:	90                   	nop
801087bb:	c9                   	leave  
801087bc:	c3                   	ret    

801087bd <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801087bd:	f3 0f 1e fb          	endbr32 
801087c1:	55                   	push   %ebp
801087c2:	89 e5                	mov    %esp,%ebp
801087c4:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801087c7:	83 ec 04             	sub    $0x4,%esp
801087ca:	6a 00                	push   $0x0
801087cc:	ff 75 0c             	pushl  0xc(%ebp)
801087cf:	ff 75 08             	pushl  0x8(%ebp)
801087d2:	e8 36 f8 ff ff       	call   8010800d <walkpgdir>
801087d7:	83 c4 10             	add    $0x10,%esp
801087da:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801087dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801087e1:	75 0d                	jne    801087f0 <clearpteu+0x33>
    panic("clearpteu");
801087e3:	83 ec 0c             	sub    $0xc,%esp
801087e6:	68 b8 9c 10 80       	push   $0x80109cb8
801087eb:	e8 18 7e ff ff       	call   80100608 <panic>
  *pte &= ~PTE_U;
801087f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f3:	8b 00                	mov    (%eax),%eax
801087f5:	83 e0 fb             	and    $0xfffffffb,%eax
801087f8:	89 c2                	mov    %eax,%edx
801087fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087fd:	89 10                	mov    %edx,(%eax)
}
801087ff:	90                   	nop
80108800:	c9                   	leave  
80108801:	c3                   	ret    

80108802 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108802:	f3 0f 1e fb          	endbr32 
80108806:	55                   	push   %ebp
80108807:	89 e5                	mov    %esp,%ebp
80108809:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010880c:	e8 7c f9 ff ff       	call   8010818d <setupkvm>
80108811:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108814:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108818:	75 0a                	jne    80108824 <copyuvm+0x22>
    return 0;
8010881a:	b8 00 00 00 00       	mov    $0x0,%eax
8010881f:	e9 fa 00 00 00       	jmp    8010891e <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
80108824:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010882b:	e9 c9 00 00 00       	jmp    801088f9 <copyuvm+0xf7>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108830:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108833:	83 ec 04             	sub    $0x4,%esp
80108836:	6a 00                	push   $0x0
80108838:	50                   	push   %eax
80108839:	ff 75 08             	pushl  0x8(%ebp)
8010883c:	e8 cc f7 ff ff       	call   8010800d <walkpgdir>
80108841:	83 c4 10             	add    $0x10,%esp
80108844:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108847:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010884b:	75 0d                	jne    8010885a <copyuvm+0x58>
      panic("p4Debug: inside copyuvm, pte should exist");
8010884d:	83 ec 0c             	sub    $0xc,%esp
80108850:	68 c4 9c 10 80       	push   $0x80109cc4
80108855:	e8 ae 7d ff ff       	call   80100608 <panic>
    if(!(*pte & (PTE_P | PTE_E)))
8010885a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010885d:	8b 00                	mov    (%eax),%eax
8010885f:	25 01 04 00 00       	and    $0x401,%eax
80108864:	85 c0                	test   %eax,%eax
80108866:	75 0d                	jne    80108875 <copyuvm+0x73>
      panic("p4Debug: inside copyuvm, page not present");
80108868:	83 ec 0c             	sub    $0xc,%esp
8010886b:	68 f0 9c 10 80       	push   $0x80109cf0
80108870:	e8 93 7d ff ff       	call   80100608 <panic>
    pa = PTE_ADDR(*pte);
80108875:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108878:	8b 00                	mov    (%eax),%eax
8010887a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010887f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108882:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108885:	8b 00                	mov    (%eax),%eax
80108887:	25 ff 0f 00 00       	and    $0xfff,%eax
8010888c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010888f:	e8 c9 a5 ff ff       	call   80102e5d <kalloc>
80108894:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108897:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010889b:	74 6d                	je     8010890a <copyuvm+0x108>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
8010889d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801088a0:	05 00 00 00 80       	add    $0x80000000,%eax
801088a5:	83 ec 04             	sub    $0x4,%esp
801088a8:	68 00 10 00 00       	push   $0x1000
801088ad:	50                   	push   %eax
801088ae:	ff 75 e0             	pushl  -0x20(%ebp)
801088b1:	e8 29 ce ff ff       	call   801056df <memmove>
801088b6:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
801088b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801088bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801088bf:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801088c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088c8:	83 ec 0c             	sub    $0xc,%esp
801088cb:	52                   	push   %edx
801088cc:	51                   	push   %ecx
801088cd:	68 00 10 00 00       	push   $0x1000
801088d2:	50                   	push   %eax
801088d3:	ff 75 f0             	pushl  -0x10(%ebp)
801088d6:	e8 eb f7 ff ff       	call   801080c6 <mappages>
801088db:	83 c4 20             	add    $0x20,%esp
801088de:	85 c0                	test   %eax,%eax
801088e0:	79 10                	jns    801088f2 <copyuvm+0xf0>
      kfree(mem);
801088e2:	83 ec 0c             	sub    $0xc,%esp
801088e5:	ff 75 e0             	pushl  -0x20(%ebp)
801088e8:	e8 d2 a4 ff ff       	call   80102dbf <kfree>
801088ed:	83 c4 10             	add    $0x10,%esp
      goto bad;
801088f0:	eb 19                	jmp    8010890b <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
801088f2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801088f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088fc:	3b 45 0c             	cmp    0xc(%ebp),%eax
801088ff:	0f 82 2b ff ff ff    	jb     80108830 <copyuvm+0x2e>
    }
  }
  return d;
80108905:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108908:	eb 14                	jmp    8010891e <copyuvm+0x11c>
      goto bad;
8010890a:	90                   	nop

bad:
  freevm(d);
8010890b:	83 ec 0c             	sub    $0xc,%esp
8010890e:	ff 75 f0             	pushl  -0x10(%ebp)
80108911:	e8 08 fe ff ff       	call   8010871e <freevm>
80108916:	83 c4 10             	add    $0x10,%esp
  return 0;
80108919:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010891e:	c9                   	leave  
8010891f:	c3                   	ret    

80108920 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108920:	f3 0f 1e fb          	endbr32 
80108924:	55                   	push   %ebp
80108925:	89 e5                	mov    %esp,%ebp
80108927:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010892a:	83 ec 04             	sub    $0x4,%esp
8010892d:	6a 00                	push   $0x0
8010892f:	ff 75 0c             	pushl  0xc(%ebp)
80108932:	ff 75 08             	pushl  0x8(%ebp)
80108935:	e8 d3 f6 ff ff       	call   8010800d <walkpgdir>
8010893a:	83 c4 10             	add    $0x10,%esp
8010893d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  // p4Debug: Check for page's present and encrypted flags.
  if(((*pte & PTE_P) | (*pte & PTE_E)) == 0)
80108940:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108943:	8b 00                	mov    (%eax),%eax
80108945:	25 01 04 00 00       	and    $0x401,%eax
8010894a:	85 c0                	test   %eax,%eax
8010894c:	75 07                	jne    80108955 <uva2ka+0x35>
    return 0;
8010894e:	b8 00 00 00 00       	mov    $0x0,%eax
80108953:	eb 22                	jmp    80108977 <uva2ka+0x57>
  if((*pte & PTE_U) == 0)
80108955:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108958:	8b 00                	mov    (%eax),%eax
8010895a:	83 e0 04             	and    $0x4,%eax
8010895d:	85 c0                	test   %eax,%eax
8010895f:	75 07                	jne    80108968 <uva2ka+0x48>
    return 0;
80108961:	b8 00 00 00 00       	mov    $0x0,%eax
80108966:	eb 0f                	jmp    80108977 <uva2ka+0x57>
  return (char*)P2V(PTE_ADDR(*pte));
80108968:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010896b:	8b 00                	mov    (%eax),%eax
8010896d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108972:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108977:	c9                   	leave  
80108978:	c3                   	ret    

80108979 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108979:	f3 0f 1e fb          	endbr32 
8010897d:	55                   	push   %ebp
8010897e:	89 e5                	mov    %esp,%ebp
80108980:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108983:	8b 45 10             	mov    0x10(%ebp),%eax
80108986:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108989:	eb 7f                	jmp    80108a0a <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
8010898b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010898e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108993:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108996:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108999:	83 ec 08             	sub    $0x8,%esp
8010899c:	50                   	push   %eax
8010899d:	ff 75 08             	pushl  0x8(%ebp)
801089a0:	e8 7b ff ff ff       	call   80108920 <uva2ka>
801089a5:	83 c4 10             	add    $0x10,%esp
801089a8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801089ab:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801089af:	75 07                	jne    801089b8 <copyout+0x3f>
    {
      //p4Debug : Cannot find page in kernel space.
      return -1;
801089b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801089b6:	eb 61                	jmp    80108a19 <copyout+0xa0>
    }
    n = PGSIZE - (va - va0);
801089b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089bb:	2b 45 0c             	sub    0xc(%ebp),%eax
801089be:	05 00 10 00 00       	add    $0x1000,%eax
801089c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801089c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089c9:	3b 45 14             	cmp    0x14(%ebp),%eax
801089cc:	76 06                	jbe    801089d4 <copyout+0x5b>
      n = len;
801089ce:	8b 45 14             	mov    0x14(%ebp),%eax
801089d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801089d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801089d7:	2b 45 ec             	sub    -0x14(%ebp),%eax
801089da:	89 c2                	mov    %eax,%edx
801089dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801089df:	01 d0                	add    %edx,%eax
801089e1:	83 ec 04             	sub    $0x4,%esp
801089e4:	ff 75 f0             	pushl  -0x10(%ebp)
801089e7:	ff 75 f4             	pushl  -0xc(%ebp)
801089ea:	50                   	push   %eax
801089eb:	e8 ef cc ff ff       	call   801056df <memmove>
801089f0:	83 c4 10             	add    $0x10,%esp
    len -= n;
801089f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089f6:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801089f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089fc:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801089ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a02:	05 00 10 00 00       	add    $0x1000,%eax
80108a07:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108a0a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108a0e:	0f 85 77 ff ff ff    	jne    8010898b <copyout+0x12>
  }
  return 0;
80108a14:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108a19:	c9                   	leave  
80108a1a:	c3                   	ret    

80108a1b <translate_and_set>:

//This function is just like uva2ka but sets the PTE_E bit and clears PTE_P
char* translate_and_set(pde_t *pgdir, char *uva) {
80108a1b:	f3 0f 1e fb          	endbr32 
80108a1f:	55                   	push   %ebp
80108a20:	89 e5                	mov    %esp,%ebp
80108a22:	83 ec 18             	sub    $0x18,%esp
  cprintf("p4Debug: setting PTE_E for %p, VPN %d\n", uva, PPN(uva));
80108a25:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a28:	c1 e8 0c             	shr    $0xc,%eax
80108a2b:	83 ec 04             	sub    $0x4,%esp
80108a2e:	50                   	push   %eax
80108a2f:	ff 75 0c             	pushl  0xc(%ebp)
80108a32:	68 1c 9d 10 80       	push   $0x80109d1c
80108a37:	e8 dc 79 ff ff       	call   80100418 <cprintf>
80108a3c:	83 c4 10             	add    $0x10,%esp
  pte_t *pte;
  pte = walkpgdir(pgdir, uva, 0);
80108a3f:	83 ec 04             	sub    $0x4,%esp
80108a42:	6a 00                	push   $0x0
80108a44:	ff 75 0c             	pushl  0xc(%ebp)
80108a47:	ff 75 08             	pushl  0x8(%ebp)
80108a4a:	e8 be f5 ff ff       	call   8010800d <walkpgdir>
80108a4f:	83 c4 10             	add    $0x10,%esp
80108a52:	89 45 f4             	mov    %eax,-0xc(%ebp)

  //p4Debug: If page is not present AND it is not encrypted.
  if((*pte & PTE_P) == 0 && (*pte & PTE_E) == 0)
80108a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a58:	8b 00                	mov    (%eax),%eax
80108a5a:	83 e0 01             	and    $0x1,%eax
80108a5d:	85 c0                	test   %eax,%eax
80108a5f:	75 18                	jne    80108a79 <translate_and_set+0x5e>
80108a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a64:	8b 00                	mov    (%eax),%eax
80108a66:	25 00 04 00 00       	and    $0x400,%eax
80108a6b:	85 c0                	test   %eax,%eax
80108a6d:	75 0a                	jne    80108a79 <translate_and_set+0x5e>
    return 0;
80108a6f:	b8 00 00 00 00       	mov    $0x0,%eax
80108a74:	e9 93 00 00 00       	jmp    80108b0c <translate_and_set+0xf1>
  //p4Debug: If page is already encrypted, i.e. PTE_E is set, return NULL as error;
  if((*pte & PTE_E)) {
80108a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a7c:	8b 00                	mov    (%eax),%eax
80108a7e:	25 00 04 00 00       	and    $0x400,%eax
80108a83:	85 c0                	test   %eax,%eax
80108a85:	74 07                	je     80108a8e <translate_and_set+0x73>
    return 0;
80108a87:	b8 00 00 00 00       	mov    $0x0,%eax
80108a8c:	eb 7e                	jmp    80108b0c <translate_and_set+0xf1>
  }
  // p4Debug: Check if users are allowed to use this page
  if((*pte & PTE_U) == 0)
80108a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a91:	8b 00                	mov    (%eax),%eax
80108a93:	83 e0 04             	and    $0x4,%eax
80108a96:	85 c0                	test   %eax,%eax
80108a98:	75 07                	jne    80108aa1 <translate_and_set+0x86>
    return 0;
80108a9a:	b8 00 00 00 00       	mov    $0x0,%eax
80108a9f:	eb 6b                	jmp    80108b0c <translate_and_set+0xf1>
  //p4Debug: Set Page as encrypted and not present so that we can trap(see trap.c) to decrypt page
  cprintf("p4Debug: PTE was %x and its pointer %p\n", *pte, pte);
80108aa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aa4:	8b 00                	mov    (%eax),%eax
80108aa6:	83 ec 04             	sub    $0x4,%esp
80108aa9:	ff 75 f4             	pushl  -0xc(%ebp)
80108aac:	50                   	push   %eax
80108aad:	68 44 9d 10 80       	push   $0x80109d44
80108ab2:	e8 61 79 ff ff       	call   80100418 <cprintf>
80108ab7:	83 c4 10             	add    $0x10,%esp
  *pte = *pte | PTE_E;
80108aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108abd:	8b 00                	mov    (%eax),%eax
80108abf:	80 cc 04             	or     $0x4,%ah
80108ac2:	89 c2                	mov    %eax,%edx
80108ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ac7:	89 10                	mov    %edx,(%eax)
  *pte =* pte & ~PTE_P;
80108ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108acc:	8b 00                	mov    (%eax),%eax
80108ace:	83 e0 fe             	and    $0xfffffffe,%eax
80108ad1:	89 c2                	mov    %eax,%edx
80108ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ad6:	89 10                	mov    %edx,(%eax)
 //
 *pte = *pte & ~PTE_A;
80108ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108adb:	8b 00                	mov    (%eax),%eax
80108add:	83 e0 df             	and    $0xffffffdf,%eax
80108ae0:	89 c2                	mov    %eax,%edx
80108ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ae5:	89 10                	mov    %edx,(%eax)
  cprintf("p4Debug: PTE is now %x\n", *pte);
80108ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aea:	8b 00                	mov    (%eax),%eax
80108aec:	83 ec 08             	sub    $0x8,%esp
80108aef:	50                   	push   %eax
80108af0:	68 6c 9d 10 80       	push   $0x80109d6c
80108af5:	e8 1e 79 ff ff       	call   80100418 <cprintf>
80108afa:	83 c4 10             	add    $0x10,%esp
  return (char*)P2V(PTE_ADDR(*pte));
80108afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b00:	8b 00                	mov    (%eax),%eax
80108b02:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b07:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108b0c:	c9                   	leave  
80108b0d:	c3                   	ret    

80108b0e <inQ>:
int inQ(struct  proc * p, char* virt){
80108b0e:	f3 0f 1e fb          	endbr32 
80108b12:	55                   	push   %ebp
80108b13:	89 e5                	mov    %esp,%ebp
80108b15:	83 ec 18             	sub    $0x18,%esp
        cprintf("you called inQ, %x\n",(uint) virt);
80108b18:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b1b:	83 ec 08             	sub    $0x8,%esp
80108b1e:	50                   	push   %eax
80108b1f:	68 84 9d 10 80       	push   $0x80109d84
80108b24:	e8 ef 78 ff ff       	call   80100418 <cprintf>
80108b29:	83 c4 10             	add    $0x10,%esp
        int myhead = p->head%CLOCKSIZE;
80108b2c:	8b 45 08             	mov    0x8(%ebp),%eax
80108b2f:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108b35:	99                   	cltd   
80108b36:	c1 ea 1d             	shr    $0x1d,%edx
80108b39:	01 d0                	add    %edx,%eax
80108b3b:	83 e0 07             	and    $0x7,%eax
80108b3e:	29 d0                	sub    %edx,%eax
80108b40:	89 45 f0             	mov    %eax,-0x10(%ebp)
	 for(int i=myhead; i<myhead+CLOCKSIZE; i++)
80108b43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b46:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108b49:	eb 49                	jmp    80108b94 <inQ+0x86>
	 {
	//	cprintf("head %d\n", myhead);
	char* check = p->clock[i%CLOCKSIZE];
80108b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b4e:	99                   	cltd   
80108b4f:	c1 ea 1d             	shr    $0x1d,%edx
80108b52:	01 d0                	add    %edx,%eax
80108b54:	83 e0 07             	and    $0x7,%eax
80108b57:	29 d0                	sub    %edx,%eax
80108b59:	89 c2                	mov    %eax,%edx
80108b5b:	8b 45 08             	mov    0x8(%ebp),%eax
80108b5e:	83 c2 1c             	add    $0x1c,%edx
80108b61:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80108b65:	89 45 ec             	mov    %eax,-0x14(%ebp)

		if(check==virt)
80108b68:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b6b:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108b6e:	75 20                	jne    80108b90 <inQ+0x82>
                {
                        cprintf("and they are equal\n");
80108b70:	83 ec 0c             	sub    $0xc,%esp
80108b73:	68 98 9d 10 80       	push   $0x80109d98
80108b78:	e8 9b 78 ff ff       	call   80100418 <cprintf>
80108b7d:	83 c4 10             	add    $0x10,%esp
			return i%CLOCKSIZE; 
80108b80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b83:	99                   	cltd   
80108b84:	c1 ea 1d             	shr    $0x1d,%edx
80108b87:	01 d0                	add    %edx,%eax
80108b89:	83 e0 07             	and    $0x7,%eax
80108b8c:	29 d0                	sub    %edx,%eax
80108b8e:	eb 14                	jmp    80108ba4 <inQ+0x96>
	 for(int i=myhead; i<myhead+CLOCKSIZE; i++)
80108b90:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108b94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b97:	83 c0 07             	add    $0x7,%eax
80108b9a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80108b9d:	7e ac                	jle    80108b4b <inQ+0x3d>
                }
	 } 

	 return -1;
80108b9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80108ba4:	c9                   	leave  
80108ba5:	c3                   	ret    

80108ba6 <addClock>:


int addClock(struct proc * p, char *va)
{
80108ba6:	f3 0f 1e fb          	endbr32 
80108baa:	55                   	push   %ebp
80108bab:	89 e5                	mov    %esp,%ebp
80108bad:	83 ec 28             	sub    $0x28,%esp
        pde_t* mypd = p->pgdir;
80108bb0:	8b 45 08             	mov    0x8(%ebp),%eax
80108bb3:	8b 40 04             	mov    0x4(%eax),%eax
80108bb6:	89 45 e8             	mov    %eax,-0x18(%ebp)
        int head = p->head;
80108bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80108bbc:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108bc2:	89 45 e4             	mov    %eax,-0x1c(%ebp)

        for(int i=head+CLOCKSIZE; i>head; i--)
80108bc5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108bc8:	83 c0 08             	add    $0x8,%eax
80108bcb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108bce:	e9 97 00 00 00       	jmp    80108c6a <addClock+0xc4>
        {
       	 	if(p->clock[(i)%CLOCKSIZE]==NULL){
80108bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bd6:	99                   	cltd   
80108bd7:	c1 ea 1d             	shr    $0x1d,%edx
80108bda:	01 d0                	add    %edx,%eax
80108bdc:	83 e0 07             	and    $0x7,%eax
80108bdf:	29 d0                	sub    %edx,%eax
80108be1:	89 c2                	mov    %eax,%edx
80108be3:	8b 45 08             	mov    0x8(%ebp),%eax
80108be6:	83 c2 1c             	add    $0x1c,%edx
80108be9:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80108bed:	85 c0                	test   %eax,%eax
80108bef:	75 75                	jne    80108c66 <addClock+0xc0>
        	 	 p->clock[(i)%CLOCKSIZE] =(char*)PGROUNDDOWN((uint)va); 
80108bf1:	8b 45 0c             	mov    0xc(%ebp),%eax
80108bf4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108bf9:	89 c1                	mov    %eax,%ecx
80108bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bfe:	99                   	cltd   
80108bff:	c1 ea 1d             	shr    $0x1d,%edx
80108c02:	01 d0                	add    %edx,%eax
80108c04:	83 e0 07             	and    $0x7,%eax
80108c07:	29 d0                	sub    %edx,%eax
80108c09:	89 c2                	mov    %eax,%edx
80108c0b:	8b 45 08             	mov    0x8(%ebp),%eax
80108c0e:	83 c2 1c             	add    $0x1c,%edx
80108c11:	89 4c 90 0c          	mov    %ecx,0xc(%eax,%edx,4)
	        	p->head = (i+1)%CLOCKSIZE;
80108c15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c18:	8d 50 01             	lea    0x1(%eax),%edx
80108c1b:	89 d0                	mov    %edx,%eax
80108c1d:	c1 f8 1f             	sar    $0x1f,%eax
80108c20:	c1 e8 1d             	shr    $0x1d,%eax
80108c23:	01 c2                	add    %eax,%edx
80108c25:	83 e2 07             	and    $0x7,%edx
80108c28:	29 c2                	sub    %eax,%edx
80108c2a:	89 d0                	mov    %edx,%eax
80108c2c:	89 c2                	mov    %eax,%edx
80108c2e:	8b 45 08             	mov    0x8(%ebp),%eax
80108c31:	89 90 9c 00 00 00    	mov    %edx,0x9c(%eax)
			pte_t * pte1 = walkpgdir(mypd, va, 0);
80108c37:	83 ec 04             	sub    $0x4,%esp
80108c3a:	6a 00                	push   $0x0
80108c3c:	ff 75 0c             	pushl  0xc(%ebp)
80108c3f:	ff 75 e8             	pushl  -0x18(%ebp)
80108c42:	e8 c6 f3 ff ff       	call   8010800d <walkpgdir>
80108c47:	83 c4 10             	add    $0x10,%esp
80108c4a:	89 45 dc             	mov    %eax,-0x24(%ebp)
			*pte1 = *pte1 | PTE_A;
80108c4d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108c50:	8b 00                	mov    (%eax),%eax
80108c52:	83 c8 20             	or     $0x20,%eax
80108c55:	89 c2                	mov    %eax,%edx
80108c57:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108c5a:	89 10                	mov    %edx,(%eax)
      	      		return 0;
80108c5c:	b8 00 00 00 00       	mov    $0x0,%eax
80108c61:	e9 14 01 00 00       	jmp    80108d7a <addClock+0x1d4>
        for(int i=head+CLOCKSIZE; i>head; i--)
80108c66:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80108c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c6d:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
80108c70:	0f 8f 5d ff ff ff    	jg     80108bd3 <addClock+0x2d>
        	}
        }


        //if no empty spaces
         char* cur_va = p->clock[head];
80108c76:	8b 45 08             	mov    0x8(%ebp),%eax
80108c79:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108c7c:	83 c2 1c             	add    $0x1c,%edx
80108c7f:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80108c83:	89 45 f0             	mov    %eax,-0x10(%ebp)
         int found =0;
80108c86:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
         while(!found){
80108c8d:	e9 d9 00 00 00       	jmp    80108d6b <addClock+0x1c5>
               pte_t * pte = walkpgdir(mypd, cur_va, 0);
80108c92:	83 ec 04             	sub    $0x4,%esp
80108c95:	6a 00                	push   $0x0
80108c97:	ff 75 f0             	pushl  -0x10(%ebp)
80108c9a:	ff 75 e8             	pushl  -0x18(%ebp)
80108c9d:	e8 6b f3 ff ff       	call   8010800d <walkpgdir>
80108ca2:	83 c4 10             	add    $0x10,%esp
80108ca5:	89 45 e0             	mov    %eax,-0x20(%ebp)
               if(!(*pte & PTE_A)){ //ref bit is 0
80108ca8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108cab:	8b 00                	mov    (%eax),%eax
80108cad:	83 e0 20             	and    $0x20,%eax
80108cb0:	85 c0                	test   %eax,%eax
80108cb2:	75 64                	jne    80108d18 <addClock+0x172>
               //evict
		      mencrypt(cur_va, 1); //encrypt
80108cb4:	83 ec 08             	sub    $0x8,%esp
80108cb7:	6a 01                	push   $0x1
80108cb9:	ff 75 f0             	pushl  -0x10(%ebp)
80108cbc:	e8 2c 03 00 00       	call   80108fed <mencrypt>
80108cc1:	83 c4 10             	add    $0x10,%esp
	       p->clock[head] = (char*)PGROUNDDOWN((uint)va); 
80108cc4:	8b 45 0c             	mov    0xc(%ebp),%eax
80108cc7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ccc:	89 c1                	mov    %eax,%ecx
80108cce:	8b 45 08             	mov    0x8(%ebp),%eax
80108cd1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108cd4:	83 c2 1c             	add    $0x1c,%edx
80108cd7:	89 4c 90 0c          	mov    %ecx,0xc(%eax,%edx,4)
               p->head += 1;
80108cdb:	8b 45 08             	mov    0x8(%ebp),%eax
80108cde:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108ce4:	8d 50 01             	lea    0x1(%eax),%edx
80108ce7:	8b 45 08             	mov    0x8(%ebp),%eax
80108cea:	89 90 9c 00 00 00    	mov    %edx,0x9c(%eax)
	       p->head = p->head%CLOCKSIZE;
80108cf0:	8b 45 08             	mov    0x8(%ebp),%eax
80108cf3:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108cf9:	99                   	cltd   
80108cfa:	c1 ea 1d             	shr    $0x1d,%edx
80108cfd:	01 d0                	add    %edx,%eax
80108cff:	83 e0 07             	and    $0x7,%eax
80108d02:	29 d0                	sub    %edx,%eax
80108d04:	89 c2                	mov    %eax,%edx
80108d06:	8b 45 08             	mov    0x8(%ebp),%eax
80108d09:	89 90 9c 00 00 00    	mov    %edx,0x9c(%eax)
	       found =1;
80108d0f:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
80108d16:	eb 53                	jmp    80108d6b <addClock+0x1c5>
         
          }
          else{
          *pte = *pte & ~PTE_A;
80108d18:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d1b:	8b 00                	mov    (%eax),%eax
80108d1d:	83 e0 df             	and    $0xffffffdf,%eax
80108d20:	89 c2                	mov    %eax,%edx
80108d22:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d25:	89 10                	mov    %edx,(%eax)
           p->head += 1;
80108d27:	8b 45 08             	mov    0x8(%ebp),%eax
80108d2a:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108d30:	8d 50 01             	lea    0x1(%eax),%edx
80108d33:	8b 45 08             	mov    0x8(%ebp),%eax
80108d36:	89 90 9c 00 00 00    	mov    %edx,0x9c(%eax)
           p->head = p->head%CLOCKSIZE;
80108d3c:	8b 45 08             	mov    0x8(%ebp),%eax
80108d3f:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108d45:	99                   	cltd   
80108d46:	c1 ea 1d             	shr    $0x1d,%edx
80108d49:	01 d0                	add    %edx,%eax
80108d4b:	83 e0 07             	and    $0x7,%eax
80108d4e:	29 d0                	sub    %edx,%eax
80108d50:	89 c2                	mov    %eax,%edx
80108d52:	8b 45 08             	mov    0x8(%ebp),%eax
80108d55:	89 90 9c 00 00 00    	mov    %edx,0x9c(%eax)
	   cur_va = p->clock[head];
80108d5b:	8b 45 08             	mov    0x8(%ebp),%eax
80108d5e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108d61:	83 c2 1c             	add    $0x1c,%edx
80108d64:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80108d68:	89 45 f0             	mov    %eax,-0x10(%ebp)
         while(!found){
80108d6b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108d6f:	0f 84 1d ff ff ff    	je     80108c92 <addClock+0xec>
          }
  }


        return 0;
80108d75:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108d7a:	c9                   	leave  
80108d7b:	c3                   	ret    

80108d7c <mdecrypt>:




int mdecrypt(char *virtual_addr) {
80108d7c:	f3 0f 1e fb          	endbr32 
80108d80:	55                   	push   %ebp
80108d81:	89 e5                	mov    %esp,%ebp
80108d83:	83 ec 38             	sub    $0x38,%esp
cprintf("ADDRESS %p\n, &PTE_E");
80108d86:	83 ec 0c             	sub    $0xc,%esp
80108d89:	68 ac 9d 10 80       	push   $0x80109dac
80108d8e:	e8 85 76 ff ff       	call   80100418 <cprintf>
80108d93:	83 c4 10             	add    $0x10,%esp
      	cprintf("p4Debug:  mdecrypt VPN %d, %p, pid %d\n", PPN(virtual_addr), virtual_addr, myproc()->pid);
80108d96:	e8 86 b7 ff ff       	call   80104521 <myproc>
80108d9b:	8b 40 10             	mov    0x10(%eax),%eax
80108d9e:	8b 55 08             	mov    0x8(%ebp),%edx
80108da1:	c1 ea 0c             	shr    $0xc,%edx
80108da4:	50                   	push   %eax
80108da5:	ff 75 08             	pushl  0x8(%ebp)
80108da8:	52                   	push   %edx
80108da9:	68 c0 9d 10 80       	push   $0x80109dc0
80108dae:	e8 65 76 ff ff       	call   80100418 <cprintf>
80108db3:	83 c4 10             	add    $0x10,%esp
  //p4Debug: virtual_addr is a virtual address in this PID's userspace.
  struct proc * p = myproc();
80108db6:	e8 66 b7 ff ff       	call   80104521 <myproc>
80108dbb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  pde_t* mypd = p->pgdir;
80108dbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108dc1:	8b 40 04             	mov    0x4(%eax),%eax
80108dc4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  //set the present bit to true and encrypt bit to false
  pte_t * pte = walkpgdir(mypd, virtual_addr, 0);
80108dc7:	83 ec 04             	sub    $0x4,%esp
80108dca:	6a 00                	push   $0x0
80108dcc:	ff 75 08             	pushl  0x8(%ebp)
80108dcf:	ff 75 e0             	pushl  -0x20(%ebp)
80108dd2:	e8 36 f2 ff ff       	call   8010800d <walkpgdir>
80108dd7:	83 c4 10             	add    $0x10,%esp
80108dda:	89 45 dc             	mov    %eax,-0x24(%ebp)

  if (!pte || *pte == 0) {
80108ddd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80108de1:	74 09                	je     80108dec <mdecrypt+0x70>
80108de3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108de6:	8b 00                	mov    (%eax),%eax
80108de8:	85 c0                	test   %eax,%eax
80108dea:	75 1a                	jne    80108e06 <mdecrypt+0x8a>
    cprintf("p4Debug: walkpgdir failed\n");
80108dec:	83 ec 0c             	sub    $0xc,%esp
80108def:	68 e7 9d 10 80       	push   $0x80109de7
80108df4:	e8 1f 76 ff ff       	call   80100418 <cprintf>
80108df9:	83 c4 10             	add    $0x10,%esp
    return -1;
80108dfc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108e01:	e9 e5 01 00 00       	jmp    80108feb <mdecrypt+0x26f>
  }
  
  if(inQ(p, virtual_addr)==-1){
80108e06:	83 ec 08             	sub    $0x8,%esp
80108e09:	ff 75 08             	pushl  0x8(%ebp)
80108e0c:	ff 75 e4             	pushl  -0x1c(%ebp)
80108e0f:	e8 fa fc ff ff       	call   80108b0e <inQ>
80108e14:	83 c4 10             	add    $0x10,%esp
80108e17:	83 f8 ff             	cmp    $0xffffffff,%eax
80108e1a:	75 11                	jne    80108e2d <mdecrypt+0xb1>
        addClock(p, virtual_addr);
80108e1c:	83 ec 08             	sub    $0x8,%esp
80108e1f:	ff 75 08             	pushl  0x8(%ebp)
80108e22:	ff 75 e4             	pushl  -0x1c(%ebp)
80108e25:	e8 7c fd ff ff       	call   80108ba6 <addClock>
80108e2a:	83 c4 10             	add    $0x10,%esp
  }
  for(int k=p->head; k<p->head + CLOCKSIZE; k++)
80108e2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108e30:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108e36:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108e39:	eb 42                	jmp    80108e7d <mdecrypt+0x101>
          cprintf("FROM ENCRYPT ==== OUT CYCLE: %x,   e bit: %d\n", (uint)p->clock[k%CLOCKSIZE], (*pte & PTE_E) > 0);
80108e3b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108e3e:	8b 00                	mov    (%eax),%eax
80108e40:	25 00 04 00 00       	and    $0x400,%eax
80108e45:	85 c0                	test   %eax,%eax
80108e47:	0f 95 c0             	setne  %al
80108e4a:	0f b6 c8             	movzbl %al,%ecx
80108e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e50:	99                   	cltd   
80108e51:	c1 ea 1d             	shr    $0x1d,%edx
80108e54:	01 d0                	add    %edx,%eax
80108e56:	83 e0 07             	and    $0x7,%eax
80108e59:	29 d0                	sub    %edx,%eax
80108e5b:	89 c2                	mov    %eax,%edx
80108e5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108e60:	83 c2 1c             	add    $0x1c,%edx
80108e63:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80108e67:	83 ec 04             	sub    $0x4,%esp
80108e6a:	51                   	push   %ecx
80108e6b:	50                   	push   %eax
80108e6c:	68 04 9e 10 80       	push   $0x80109e04
80108e71:	e8 a2 75 ff ff       	call   80100418 <cprintf>
80108e76:	83 c4 10             	add    $0x10,%esp
  for(int k=p->head; k<p->head + CLOCKSIZE; k++)
80108e79:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108e7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108e80:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108e86:	83 c0 07             	add    $0x7,%eax
80108e89:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80108e8c:	7e ad                	jle    80108e3b <mdecrypt+0xbf>

  cprintf("p4Debug: pte was %x\n", *pte);
80108e8e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108e91:	8b 00                	mov    (%eax),%eax
80108e93:	83 ec 08             	sub    $0x8,%esp
80108e96:	50                   	push   %eax
80108e97:	68 32 9e 10 80       	push   $0x80109e32
80108e9c:	e8 77 75 ff ff       	call   80100418 <cprintf>
80108ea1:	83 c4 10             	add    $0x10,%esp
  *pte = *pte & ~PTE_E;
80108ea4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108ea7:	8b 00                	mov    (%eax),%eax
80108ea9:	80 e4 fb             	and    $0xfb,%ah
80108eac:	89 c2                	mov    %eax,%edx
80108eae:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108eb1:	89 10                	mov    %edx,(%eax)
  *pte = *pte | PTE_P;
80108eb3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108eb6:	8b 00                	mov    (%eax),%eax
80108eb8:	83 c8 01             	or     $0x1,%eax
80108ebb:	89 c2                	mov    %eax,%edx
80108ebd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108ec0:	89 10                	mov    %edx,(%eax)
  cprintf("p4Debug: pte is %x\n", *pte);
80108ec2:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108ec5:	8b 00                	mov    (%eax),%eax
80108ec7:	83 ec 08             	sub    $0x8,%esp
80108eca:	50                   	push   %eax
80108ecb:	68 47 9e 10 80       	push   $0x80109e47
80108ed0:	e8 43 75 ff ff       	call   80100418 <cprintf>
80108ed5:	83 c4 10             	add    $0x10,%esp
  char * original = uva2ka(mypd, virtual_addr) + OFFSET(virtual_addr);
80108ed8:	83 ec 08             	sub    $0x8,%esp
80108edb:	ff 75 08             	pushl  0x8(%ebp)
80108ede:	ff 75 e0             	pushl  -0x20(%ebp)
80108ee1:	e8 3a fa ff ff       	call   80108920 <uva2ka>
80108ee6:	83 c4 10             	add    $0x10,%esp
80108ee9:	8b 55 08             	mov    0x8(%ebp),%edx
80108eec:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
80108ef2:	01 d0                	add    %edx,%eax
80108ef4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  cprintf("p4Debug: Original in decrypt was %p\n", original);
80108ef7:	83 ec 08             	sub    $0x8,%esp
80108efa:	ff 75 d8             	pushl  -0x28(%ebp)
80108efd:	68 5c 9e 10 80       	push   $0x80109e5c
80108f02:	e8 11 75 ff ff       	call   80100418 <cprintf>
80108f07:	83 c4 10             	add    $0x10,%esp
  virtual_addr = (char *)PGROUNDDOWN((uint)virtual_addr);
80108f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80108f0d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f12:	89 45 08             	mov    %eax,0x8(%ebp)
  cprintf("pDebug: mdecrypt: rounded down va is %p\n", virtual_addr);
80108f15:	83 ec 08             	sub    $0x8,%esp
80108f18:	ff 75 08             	pushl  0x8(%ebp)
80108f1b:	68 84 9e 10 80       	push   $0x80109e84
80108f20:	e8 f3 74 ff ff       	call   80100418 <cprintf>
80108f25:	83 c4 10             	add    $0x10,%esp



  char * kvp = uva2ka(mypd, virtual_addr);
80108f28:	83 ec 08             	sub    $0x8,%esp
80108f2b:	ff 75 08             	pushl  0x8(%ebp)
80108f2e:	ff 75 e0             	pushl  -0x20(%ebp)
80108f31:	e8 ea f9 ff ff       	call   80108920 <uva2ka>
80108f36:	83 c4 10             	add    $0x10,%esp
80108f39:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  if (!kvp || *kvp == 0) {
80108f3c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80108f40:	74 0a                	je     80108f4c <mdecrypt+0x1d0>
80108f42:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108f45:	0f b6 00             	movzbl (%eax),%eax
80108f48:	84 c0                	test   %al,%al
80108f4a:	75 0a                	jne    80108f56 <mdecrypt+0x1da>
    return -1;
80108f4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108f51:	e9 95 00 00 00       	jmp    80108feb <mdecrypt+0x26f>
  }
  char * slider = virtual_addr;
80108f56:	8b 45 08             	mov    0x8(%ebp),%eax
80108f59:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for (int offset = 0; offset < PGSIZE; offset++) {
80108f5c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108f63:	eb 17                	jmp    80108f7c <mdecrypt+0x200>
    *slider = *slider ^ 0xFF;
80108f65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f68:	0f b6 00             	movzbl (%eax),%eax
80108f6b:	f7 d0                	not    %eax
80108f6d:	89 c2                	mov    %eax,%edx
80108f6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f72:	88 10                	mov    %dl,(%eax)
    slider++;
80108f74:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  for (int offset = 0; offset < PGSIZE; offset++) {
80108f78:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108f7c:	81 7d ec ff 0f 00 00 	cmpl   $0xfff,-0x14(%ebp)
80108f83:	7e e0                	jle    80108f65 <mdecrypt+0x1e9>
  }

	for(int k=p->head; k<p->head + CLOCKSIZE; k++) 
80108f85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f88:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108f8e:	89 45 e8             	mov    %eax,-0x18(%ebp)
80108f91:	eb 42                	jmp    80108fd5 <mdecrypt+0x259>
		cprintf("OUT CYCLE: %x,e bit: %d\n", (uint)p->clock[k%CLOCKSIZE], (*pte & PTE_E) > 0);
80108f93:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108f96:	8b 00                	mov    (%eax),%eax
80108f98:	25 00 04 00 00       	and    $0x400,%eax
80108f9d:	85 c0                	test   %eax,%eax
80108f9f:	0f 95 c0             	setne  %al
80108fa2:	0f b6 c8             	movzbl %al,%ecx
80108fa5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108fa8:	99                   	cltd   
80108fa9:	c1 ea 1d             	shr    $0x1d,%edx
80108fac:	01 d0                	add    %edx,%eax
80108fae:	83 e0 07             	and    $0x7,%eax
80108fb1:	29 d0                	sub    %edx,%eax
80108fb3:	89 c2                	mov    %eax,%edx
80108fb5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108fb8:	83 c2 1c             	add    $0x1c,%edx
80108fbb:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80108fbf:	83 ec 04             	sub    $0x4,%esp
80108fc2:	51                   	push   %ecx
80108fc3:	50                   	push   %eax
80108fc4:	68 ad 9e 10 80       	push   $0x80109ead
80108fc9:	e8 4a 74 ff ff       	call   80100418 <cprintf>
80108fce:	83 c4 10             	add    $0x10,%esp
	for(int k=p->head; k<p->head + CLOCKSIZE; k++) 
80108fd1:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80108fd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108fd8:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108fde:	83 c0 07             	add    $0x7,%eax
80108fe1:	39 45 e8             	cmp    %eax,-0x18(%ebp)
80108fe4:	7e ad                	jle    80108f93 <mdecrypt+0x217>

  return 0;
80108fe6:	b8 00 00 00 00       	mov    $0x0,%eax

 }
80108feb:	c9                   	leave  
80108fec:	c3                   	ret    

80108fed <mencrypt>:


int mencrypt(char *virtual_addr, int len) {
80108fed:	f3 0f 1e fb          	endbr32 
80108ff1:	55                   	push   %ebp
80108ff2:	89 e5                	mov    %esp,%ebp
80108ff4:	83 ec 38             	sub    $0x38,%esp

  cprintf("p4Debug: mencrypt: %p %d\n", virtual_addr, len);
80108ff7:	83 ec 04             	sub    $0x4,%esp
80108ffa:	ff 75 0c             	pushl  0xc(%ebp)
80108ffd:	ff 75 08             	pushl  0x8(%ebp)
80109000:	68 c6 9e 10 80       	push   $0x80109ec6
80109005:	e8 0e 74 ff ff       	call   80100418 <cprintf>
8010900a:	83 c4 10             	add    $0x10,%esp
  //the given pointer is a virtual address in this pid's userspace
  struct proc * p = myproc();
8010900d:	e8 0f b5 ff ff       	call   80104521 <myproc>
80109012:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  pde_t* mypd = p->pgdir;
80109015:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109018:	8b 40 04             	mov    0x4(%eax),%eax
8010901b:	89 45 e0             	mov    %eax,-0x20(%ebp)


  //if we encrypt, we kick a page out of the queue --
  //find a page, check it actually is in queue, set it to 0
virtual_addr = (char *)PGROUNDDOWN((uint)virtual_addr);
8010901e:	8b 45 08             	mov    0x8(%ebp),%eax
80109021:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109026:	89 45 08             	mov    %eax,0x8(%ebp)

  //error checking first. all or nothing.
  char * slider = virtual_addr;
80109029:	8b 45 08             	mov    0x8(%ebp),%eax
8010902c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
8010902f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109036:	eb 55                	jmp    8010908d <mencrypt+0xa0>
    //check page table for each translation first
    char * kvp = uva2ka(mypd, slider);
80109038:	83 ec 08             	sub    $0x8,%esp
8010903b:	ff 75 f4             	pushl  -0xc(%ebp)
8010903e:	ff 75 e0             	pushl  -0x20(%ebp)
80109041:	e8 da f8 ff ff       	call   80108920 <uva2ka>
80109046:	83 c4 10             	add    $0x10,%esp
80109049:	89 45 d0             	mov    %eax,-0x30(%ebp)
    cprintf("p4Debug: slider %p, kvp for err check is %p\n",slider, kvp);
8010904c:	83 ec 04             	sub    $0x4,%esp
8010904f:	ff 75 d0             	pushl  -0x30(%ebp)
80109052:	ff 75 f4             	pushl  -0xc(%ebp)
80109055:	68 e0 9e 10 80       	push   $0x80109ee0
8010905a:	e8 b9 73 ff ff       	call   80100418 <cprintf>
8010905f:	83 c4 10             	add    $0x10,%esp
    if (!kvp) {
80109062:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
80109066:	75 1a                	jne    80109082 <mencrypt+0x95>
      cprintf("p4Debug: mencrypt: kvp = NULL\n");
80109068:	83 ec 0c             	sub    $0xc,%esp
8010906b:	68 10 9f 10 80       	push   $0x80109f10
80109070:	e8 a3 73 ff ff       	call   80100418 <cprintf>
80109075:	83 c4 10             	add    $0x10,%esp
      return -1;
80109078:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010907d:	e9 46 01 00 00       	jmp    801091c8 <mencrypt+0x1db>
    }
    slider = slider + PGSIZE;
80109082:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
80109089:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010908d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109090:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109093:	7c a3                	jl     80109038 <mencrypt+0x4b>
  }

  //encrypt stage. Have to do this before setting flag 
  //or else we'll page fault
  slider = virtual_addr;
80109095:	8b 45 08             	mov    0x8(%ebp),%eax
80109098:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int i = 0; i < len; i++) {
8010909b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801090a2:	e9 ff 00 00 00       	jmp    801091a6 <mencrypt+0x1b9>
    cprintf("p4Debug: mencryptr: VPN %d, %p\n", PPN(slider), slider);
801090a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090aa:	c1 e8 0c             	shr    $0xc,%eax
801090ad:	83 ec 04             	sub    $0x4,%esp
801090b0:	ff 75 f4             	pushl  -0xc(%ebp)
801090b3:	50                   	push   %eax
801090b4:	68 30 9f 10 80       	push   $0x80109f30
801090b9:	e8 5a 73 ff ff       	call   80100418 <cprintf>
801090be:	83 c4 10             	add    $0x10,%esp
    //kvp = kernel virtual pointer
    //virtual address in kernel space that maps to the given pointer
    char * kvp = uva2ka(mypd, slider);
801090c1:	83 ec 08             	sub    $0x8,%esp
801090c4:	ff 75 f4             	pushl  -0xc(%ebp)
801090c7:	ff 75 e0             	pushl  -0x20(%ebp)
801090ca:	e8 51 f8 ff ff       	call   80108920 <uva2ka>
801090cf:	83 c4 10             	add    $0x10,%esp
801090d2:	89 45 dc             	mov    %eax,-0x24(%ebp)
    cprintf("p4Debug: kvp for encrypt stage is %p\n", kvp);
801090d5:	83 ec 08             	sub    $0x8,%esp
801090d8:	ff 75 dc             	pushl  -0x24(%ebp)
801090db:	68 50 9f 10 80       	push   $0x80109f50
801090e0:	e8 33 73 ff ff       	call   80100418 <cprintf>
801090e5:	83 c4 10             	add    $0x10,%esp
    pte_t * mypte = walkpgdir(mypd, slider, 0);
801090e8:	83 ec 04             	sub    $0x4,%esp
801090eb:	6a 00                	push   $0x0
801090ed:	ff 75 f4             	pushl  -0xc(%ebp)
801090f0:	ff 75 e0             	pushl  -0x20(%ebp)
801090f3:	e8 15 ef ff ff       	call   8010800d <walkpgdir>
801090f8:	83 c4 10             	add    $0x10,%esp
801090fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
    cprintf("p4Debug: pte is %x\n", *mypte);
801090fe:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109101:	8b 00                	mov    (%eax),%eax
80109103:	83 ec 08             	sub    $0x8,%esp
80109106:	50                   	push   %eax
80109107:	68 47 9e 10 80       	push   $0x80109e47
8010910c:	e8 07 73 ff ff       	call   80100418 <cprintf>
80109111:	83 c4 10             	add    $0x10,%esp
    if (*mypte & PTE_E) {
80109114:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109117:	8b 00                	mov    (%eax),%eax
80109119:	25 00 04 00 00       	and    $0x400,%eax
8010911e:	85 c0                	test   %eax,%eax
80109120:	74 1d                	je     8010913f <mencrypt+0x152>
	    cprintf("p4Debug: already encrypted\n");
80109122:	83 ec 0c             	sub    $0xc,%esp
80109125:	68 76 9f 10 80       	push   $0x80109f76
8010912a:	e8 e9 72 ff ff       	call   80100418 <cprintf>
8010912f:	83 c4 10             	add    $0x10,%esp
      slider += PGSIZE;
80109132:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  for (int i = 0; i < len; i++) {
80109139:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010913d:	eb 67                	jmp    801091a6 <mencrypt+0x1b9>
      continue;
    }
    for (int offset = 0; offset < PGSIZE; offset++) {
8010913f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
80109146:	eb 17                	jmp    8010915f <mencrypt+0x172>
      *slider = *slider ^ 0xFF;
80109148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010914b:	0f b6 00             	movzbl (%eax),%eax
8010914e:	f7 d0                	not    %eax
80109150:	89 c2                	mov    %eax,%edx
80109152:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109155:	88 10                	mov    %dl,(%eax)
      slider++;
80109157:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    for (int offset = 0; offset < PGSIZE; offset++) {
8010915b:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
8010915f:	81 7d e8 ff 0f 00 00 	cmpl   $0xfff,-0x18(%ebp)
80109166:	7e e0                	jle    80109148 <mencrypt+0x15b>
    }
    char * kvp_translated = translate_and_set(mypd, slider-PGSIZE);
80109168:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010916b:	2d 00 10 00 00       	sub    $0x1000,%eax
80109170:	83 ec 08             	sub    $0x8,%esp
80109173:	50                   	push   %eax
80109174:	ff 75 e0             	pushl  -0x20(%ebp)
80109177:	e8 9f f8 ff ff       	call   80108a1b <translate_and_set>
8010917c:	83 c4 10             	add    $0x10,%esp
8010917f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    if (!kvp_translated) {
80109182:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80109186:	75 17                	jne    8010919f <mencrypt+0x1b2>
      cprintf("p4Debug: translate failed!");
80109188:	83 ec 0c             	sub    $0xc,%esp
8010918b:	68 92 9f 10 80       	push   $0x80109f92
80109190:	e8 83 72 ff ff       	call   80100418 <cprintf>
80109195:	83 c4 10             	add    $0x10,%esp
      return -1;
80109198:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010919d:	eb 29                	jmp    801091c8 <mencrypt+0x1db>
    }
    
	
	return 0;
8010919f:	b8 00 00 00 00       	mov    $0x0,%eax
801091a4:	eb 22                	jmp    801091c8 <mencrypt+0x1db>
  for (int i = 0; i < len; i++) {
801091a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091a9:	3b 45 0c             	cmp    0xc(%ebp),%eax
801091ac:	0f 8c f5 fe ff ff    	jl     801090a7 <mencrypt+0xba>
  }

  switchuvm(myproc());
801091b2:	e8 6a b3 ff ff       	call   80104521 <myproc>
801091b7:	83 ec 0c             	sub    $0xc,%esp
801091ba:	50                   	push   %eax
801091bb:	e8 a3 f0 ff ff       	call   80108263 <switchuvm>
801091c0:	83 c4 10             	add    $0x10,%esp
  return 0; 
801091c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801091c8:	c9                   	leave  
801091c9:	c3                   	ret    

801091ca <getpgtable>:

int getpgtable(struct pt_entry* pt_entries, int num, int wsetOnly) {
801091ca:	f3 0f 1e fb          	endbr32 
801091ce:	55                   	push   %ebp
801091cf:	89 e5                	mov    %esp,%ebp
801091d1:	83 ec 28             	sub    $0x28,%esp

	cprintf("p4Debug: getpgtable: %p, %d\n", pt_entries, num);
801091d4:	83 ec 04             	sub    $0x4,%esp
801091d7:	ff 75 0c             	pushl  0xc(%ebp)
801091da:	ff 75 08             	pushl  0x8(%ebp)
801091dd:	68 ad 9f 10 80       	push   $0x80109fad
801091e2:	e8 31 72 ff ff       	call   80100418 <cprintf>
801091e7:	83 c4 10             	add    $0x10,%esp
//van
      	if(wsetOnly!=0 && wsetOnly !=1)
801091ea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801091ee:	74 10                	je     80109200 <getpgtable+0x36>
801091f0:	83 7d 10 01          	cmpl   $0x1,0x10(%ebp)
801091f4:	74 0a                	je     80109200 <getpgtable+0x36>
		  return -1;
801091f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801091fb:	e9 36 02 00 00       	jmp    80109436 <getpgtable+0x26c>

	struct proc *curproc = myproc();
80109200:	e8 1c b3 ff ff       	call   80104521 <myproc>
80109205:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pde_t *pgdir = curproc->pgdir;
80109208:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010920b:	8b 40 04             	mov    0x4(%eax),%eax
8010920e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint uva = 0;
80109211:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if (curproc->sz % PGSIZE == 0)
80109218:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010921b:	8b 00                	mov    (%eax),%eax
8010921d:	25 ff 0f 00 00       	and    $0xfff,%eax
80109222:	85 c0                	test   %eax,%eax
80109224:	75 0f                	jne    80109235 <getpgtable+0x6b>
    uva = curproc->sz - PGSIZE;
80109226:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109229:	8b 00                	mov    (%eax),%eax
8010922b:	2d 00 10 00 00       	sub    $0x1000,%eax
80109230:	89 45 f4             	mov    %eax,-0xc(%ebp)
80109233:	eb 0d                	jmp    80109242 <getpgtable+0x78>
  else 
    uva = PGROUNDDOWN(curproc->sz);
80109235:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109238:	8b 00                	mov    (%eax),%eax
8010923a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010923f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  int i = 0;
80109242:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  for (;;uva -=PGSIZE)
  {
    pte_t *pte = walkpgdir(pgdir, (const void *)uva, 0);
80109249:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010924c:	83 ec 04             	sub    $0x4,%esp
8010924f:	6a 00                	push   $0x0
80109251:	50                   	push   %eax
80109252:	ff 75 e8             	pushl  -0x18(%ebp)
80109255:	e8 b3 ed ff ff       	call   8010800d <walkpgdir>
8010925a:	83 c4 10             	add    $0x10,%esp
8010925d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  //  if(wsetOnly && inQ(curproc, (char* )uva)==-1)
    //{
    //	    num++;
//	    continue;
  //  }
    if (!(*pte & PTE_U) || !(*pte & (PTE_P | PTE_E)))
80109260:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109263:	8b 00                	mov    (%eax),%eax
80109265:	83 e0 04             	and    $0x4,%eax
80109268:	85 c0                	test   %eax,%eax
8010926a:	0f 84 b6 01 00 00    	je     80109426 <getpgtable+0x25c>
80109270:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109273:	8b 00                	mov    (%eax),%eax
80109275:	25 01 04 00 00       	and    $0x401,%eax
8010927a:	85 c0                	test   %eax,%eax
8010927c:	0f 84 a4 01 00 00    	je     80109426 <getpgtable+0x25c>
      continue;

    if(wsetOnly && inQ(curproc, (char* )uva)==-1)
80109282:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80109286:	74 1b                	je     801092a3 <getpgtable+0xd9>
80109288:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010928b:	83 ec 08             	sub    $0x8,%esp
8010928e:	50                   	push   %eax
8010928f:	ff 75 ec             	pushl  -0x14(%ebp)
80109292:	e8 77 f8 ff ff       	call   80108b0e <inQ>
80109297:	83 c4 10             	add    $0x10,%esp
8010929a:	83 f8 ff             	cmp    $0xffffffff,%eax
8010929d:	0f 84 86 01 00 00    	je     80109429 <getpgtable+0x25f>
            
            continue;
    }
    

    pt_entries[i].pdx = PDX(uva);
801092a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092a6:	c1 e8 16             	shr    $0x16,%eax
801092a9:	89 c1                	mov    %eax,%ecx
801092ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092ae:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
801092b5:	8b 45 08             	mov    0x8(%ebp),%eax
801092b8:	01 c2                	add    %eax,%edx
801092ba:	89 c8                	mov    %ecx,%eax
801092bc:	66 25 ff 03          	and    $0x3ff,%ax
801092c0:	66 25 ff 03          	and    $0x3ff,%ax
801092c4:	89 c1                	mov    %eax,%ecx
801092c6:	0f b7 02             	movzwl (%edx),%eax
801092c9:	66 25 00 fc          	and    $0xfc00,%ax
801092cd:	09 c8                	or     %ecx,%eax
801092cf:	66 89 02             	mov    %ax,(%edx)
    pt_entries[i].ptx = PTX(uva);
801092d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092d5:	c1 e8 0c             	shr    $0xc,%eax
801092d8:	89 c1                	mov    %eax,%ecx
801092da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092dd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
801092e4:	8b 45 08             	mov    0x8(%ebp),%eax
801092e7:	01 c2                	add    %eax,%edx
801092e9:	89 c8                	mov    %ecx,%eax
801092eb:	66 25 ff 03          	and    $0x3ff,%ax
801092ef:	0f b7 c0             	movzwl %ax,%eax
801092f2:	25 ff 03 00 00       	and    $0x3ff,%eax
801092f7:	c1 e0 0a             	shl    $0xa,%eax
801092fa:	89 c1                	mov    %eax,%ecx
801092fc:	8b 02                	mov    (%edx),%eax
801092fe:	25 ff 03 f0 ff       	and    $0xfff003ff,%eax
80109303:	09 c8                	or     %ecx,%eax
80109305:	89 02                	mov    %eax,(%edx)
    pt_entries[i].ppage = *pte >> PTXSHIFT;
80109307:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010930a:	8b 00                	mov    (%eax),%eax
8010930c:	c1 e8 0c             	shr    $0xc,%eax
8010930f:	89 c2                	mov    %eax,%edx
80109311:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109314:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
8010931b:	8b 45 08             	mov    0x8(%ebp),%eax
8010931e:	01 c8                	add    %ecx,%eax
80109320:	81 e2 ff ff 0f 00    	and    $0xfffff,%edx
80109326:	89 d1                	mov    %edx,%ecx
80109328:	81 e1 ff ff 0f 00    	and    $0xfffff,%ecx
8010932e:	8b 50 04             	mov    0x4(%eax),%edx
80109331:	81 e2 00 00 f0 ff    	and    $0xfff00000,%edx
80109337:	09 ca                	or     %ecx,%edx
80109339:	89 50 04             	mov    %edx,0x4(%eax)
    pt_entries[i].present = *pte & PTE_P;
8010933c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010933f:	8b 08                	mov    (%eax),%ecx
80109341:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109344:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
8010934b:	8b 45 08             	mov    0x8(%ebp),%eax
8010934e:	01 c2                	add    %eax,%edx
80109350:	89 c8                	mov    %ecx,%eax
80109352:	83 e0 01             	and    $0x1,%eax
80109355:	83 e0 01             	and    $0x1,%eax
80109358:	c1 e0 04             	shl    $0x4,%eax
8010935b:	89 c1                	mov    %eax,%ecx
8010935d:	0f b6 42 06          	movzbl 0x6(%edx),%eax
80109361:	83 e0 ef             	and    $0xffffffef,%eax
80109364:	09 c8                	or     %ecx,%eax
80109366:	88 42 06             	mov    %al,0x6(%edx)
    pt_entries[i].writable = (*pte & PTE_W) > 0;
80109369:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010936c:	8b 00                	mov    (%eax),%eax
8010936e:	83 e0 02             	and    $0x2,%eax
80109371:	89 c2                	mov    %eax,%edx
80109373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109376:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
8010937d:	8b 45 08             	mov    0x8(%ebp),%eax
80109380:	01 c8                	add    %ecx,%eax
80109382:	85 d2                	test   %edx,%edx
80109384:	0f 95 c2             	setne  %dl
80109387:	83 e2 01             	and    $0x1,%edx
8010938a:	89 d1                	mov    %edx,%ecx
8010938c:	c1 e1 05             	shl    $0x5,%ecx
8010938f:	0f b6 50 06          	movzbl 0x6(%eax),%edx
80109393:	83 e2 df             	and    $0xffffffdf,%edx
80109396:	09 ca                	or     %ecx,%edx
80109398:	88 50 06             	mov    %dl,0x6(%eax)
    pt_entries[i].encrypted = (*pte & PTE_E) > 0;
8010939b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010939e:	8b 00                	mov    (%eax),%eax
801093a0:	25 00 04 00 00       	and    $0x400,%eax
801093a5:	89 c2                	mov    %eax,%edx
801093a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093aa:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
801093b1:	8b 45 08             	mov    0x8(%ebp),%eax
801093b4:	01 c8                	add    %ecx,%eax
801093b6:	85 d2                	test   %edx,%edx
801093b8:	0f 95 c2             	setne  %dl
801093bb:	89 d1                	mov    %edx,%ecx
801093bd:	c1 e1 07             	shl    $0x7,%ecx
801093c0:	0f b6 50 06          	movzbl 0x6(%eax),%edx
801093c4:	83 e2 7f             	and    $0x7f,%edx
801093c7:	09 ca                	or     %ecx,%edx
801093c9:	88 50 06             	mov    %dl,0x6(%eax)
    pt_entries[i].ref = (*pte & PTE_A) > 0;
801093cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801093cf:	8b 00                	mov    (%eax),%eax
801093d1:	83 e0 20             	and    $0x20,%eax
801093d4:	89 c2                	mov    %eax,%edx
801093d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093d9:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
801093e0:	8b 45 08             	mov    0x8(%ebp),%eax
801093e3:	01 c8                	add    %ecx,%eax
801093e5:	85 d2                	test   %edx,%edx
801093e7:	0f 95 c2             	setne  %dl
801093ea:	89 d1                	mov    %edx,%ecx
801093ec:	83 e1 01             	and    $0x1,%ecx
801093ef:	0f b6 50 07          	movzbl 0x7(%eax),%edx
801093f3:	83 e2 fe             	and    $0xfffffffe,%edx
801093f6:	09 ca                	or     %ecx,%edx
801093f8:	88 50 07             	mov    %dl,0x7(%eax)
    //PT_A flag needs to be modified as per clock algo.
    //if((inQ(curproc,(char*)uva))!=-1 && !pt_entries[i].ref)
     // *pte = *pte | PTE_A;
    i ++;
801093fb:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    if (uva == 0 || i == num) { cprintf("get page table i = %d\n", i); break;}
801093ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109403:	74 08                	je     8010940d <getpgtable+0x243>
80109405:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109408:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010940b:	75 1d                	jne    8010942a <getpgtable+0x260>
8010940d:	83 ec 08             	sub    $0x8,%esp
80109410:	ff 75 f0             	pushl  -0x10(%ebp)
80109413:	68 ca 9f 10 80       	push   $0x80109fca
80109418:	e8 fb 6f ff ff       	call   80100418 <cprintf>
8010941d:	83 c4 10             	add    $0x10,%esp
80109420:	90                   	nop

  }
  return i;
80109421:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109424:	eb 10                	jmp    80109436 <getpgtable+0x26c>
      continue;
80109426:	90                   	nop
80109427:	eb 01                	jmp    8010942a <getpgtable+0x260>
            continue;
80109429:	90                   	nop
  for (;;uva -=PGSIZE)
8010942a:	81 6d f4 00 10 00 00 	subl   $0x1000,-0xc(%ebp)
  {
80109431:	e9 13 fe ff ff       	jmp    80109249 <getpgtable+0x7f>

}
80109436:	c9                   	leave  
80109437:	c3                   	ret    

80109438 <dump_rawphymem>:


int dump_rawphymem(char *physical_addr, char * buffer) {
80109438:	f3 0f 1e fb          	endbr32 
8010943c:	55                   	push   %ebp
8010943d:	89 e5                	mov    %esp,%ebp
8010943f:	56                   	push   %esi
80109440:	53                   	push   %ebx
80109441:	83 ec 10             	sub    $0x10,%esp
  *buffer = *buffer;
80109444:	8b 45 0c             	mov    0xc(%ebp),%eax
80109447:	0f b6 10             	movzbl (%eax),%edx
8010944a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010944d:	88 10                	mov    %dl,(%eax)
  cprintf("p4Debug: dump_rawphymem: %p, %p\n", physical_addr, buffer);
8010944f:	83 ec 04             	sub    $0x4,%esp
80109452:	ff 75 0c             	pushl  0xc(%ebp)
80109455:	ff 75 08             	pushl  0x8(%ebp)
80109458:	68 e4 9f 10 80       	push   $0x80109fe4
8010945d:	e8 b6 6f ff ff       	call   80100418 <cprintf>
80109462:	83 c4 10             	add    $0x10,%esp
  int retval = copyout(myproc()->pgdir, (uint) buffer, (void *) PGROUNDDOWN((int)P2V(physical_addr)), PGSIZE);
80109465:	8b 45 08             	mov    0x8(%ebp),%eax
80109468:	05 00 00 00 80       	add    $0x80000000,%eax
8010946d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109472:	89 c6                	mov    %eax,%esi
80109474:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80109477:	e8 a5 b0 ff ff       	call   80104521 <myproc>
8010947c:	8b 40 04             	mov    0x4(%eax),%eax
8010947f:	68 00 10 00 00       	push   $0x1000
80109484:	56                   	push   %esi
80109485:	53                   	push   %ebx
80109486:	50                   	push   %eax
80109487:	e8 ed f4 ff ff       	call   80108979 <copyout>
8010948c:	83 c4 10             	add    $0x10,%esp
8010948f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (retval)
80109492:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109496:	74 07                	je     8010949f <dump_rawphymem+0x67>
    return -1;
80109498:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010949d:	eb 05                	jmp    801094a4 <dump_rawphymem+0x6c>
  return 0;
8010949f:	b8 00 00 00 00       	mov    $0x0,%eax
}
801094a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801094a7:	5b                   	pop    %ebx
801094a8:	5e                   	pop    %esi
801094a9:	5d                   	pop    %ebp
801094aa:	c3                   	ret    
