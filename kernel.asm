
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
8010002d:	b8 77 3a 10 80       	mov    $0x80103a77,%eax
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
80100041:	68 4c 95 10 80       	push   $0x8010954c
80100046:	68 60 e6 10 80       	push   $0x8010e660
8010004b:	e8 6f 52 00 00       	call   801052bf <initlock>
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
8010008f:	68 53 95 10 80       	push   $0x80109553
80100094:	50                   	push   %eax
80100095:	e8 92 50 00 00       	call   8010512c <initsleeplock>
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
801000d7:	e8 09 52 00 00       	call   801052e5 <acquire>
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
80100116:	e8 3c 52 00 00       	call   80105357 <release>
8010011b:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	83 c0 0c             	add    $0xc,%eax
80100124:	83 ec 0c             	sub    $0xc,%esp
80100127:	50                   	push   %eax
80100128:	e8 3f 50 00 00       	call   8010516c <acquiresleep>
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
80100197:	e8 bb 51 00 00       	call   80105357 <release>
8010019c:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
8010019f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a2:	83 c0 0c             	add    $0xc,%eax
801001a5:	83 ec 0c             	sub    $0xc,%esp
801001a8:	50                   	push   %eax
801001a9:	e8 be 4f 00 00       	call   8010516c <acquiresleep>
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
801001cb:	68 5a 95 10 80       	push   $0x8010955a
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
80100207:	e8 ca 28 00 00       	call   80102ad6 <iderw>
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
80100228:	e8 f9 4f 00 00       	call   80105226 <holdingsleep>
8010022d:	83 c4 10             	add    $0x10,%esp
80100230:	85 c0                	test   %eax,%eax
80100232:	75 0d                	jne    80100241 <bwrite+0x2d>
    panic("bwrite");
80100234:	83 ec 0c             	sub    $0xc,%esp
80100237:	68 6b 95 10 80       	push   $0x8010956b
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
80100256:	e8 7b 28 00 00       	call   80102ad6 <iderw>
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
80100275:	e8 ac 4f 00 00       	call   80105226 <holdingsleep>
8010027a:	83 c4 10             	add    $0x10,%esp
8010027d:	85 c0                	test   %eax,%eax
8010027f:	75 0d                	jne    8010028e <brelse+0x2d>
    panic("brelse");
80100281:	83 ec 0c             	sub    $0xc,%esp
80100284:	68 72 95 10 80       	push   $0x80109572
80100289:	e8 7a 03 00 00       	call   80100608 <panic>

  releasesleep(&b->lock);
8010028e:	8b 45 08             	mov    0x8(%ebp),%eax
80100291:	83 c0 0c             	add    $0xc,%eax
80100294:	83 ec 0c             	sub    $0xc,%esp
80100297:	50                   	push   %eax
80100298:	e8 37 4f 00 00       	call   801051d4 <releasesleep>
8010029d:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002a0:	83 ec 0c             	sub    $0xc,%esp
801002a3:	68 60 e6 10 80       	push   $0x8010e660
801002a8:	e8 38 50 00 00       	call   801052e5 <acquire>
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
80100318:	e8 3a 50 00 00       	call   80105357 <release>
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
80100438:	e8 ef 4f 00 00       	call   8010542c <holding>
8010043d:	83 c4 10             	add    $0x10,%esp
80100440:	85 c0                	test   %eax,%eax
80100442:	75 10                	jne    80100454 <cprintf+0x3c>
    acquire(&cons.lock);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	68 c0 d5 10 80       	push   $0x8010d5c0
8010044c:	e8 94 4e 00 00       	call   801052e5 <acquire>
80100451:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100454:	8b 45 08             	mov    0x8(%ebp),%eax
80100457:	85 c0                	test   %eax,%eax
80100459:	75 0d                	jne    80100468 <cprintf+0x50>
    panic("null fmt");
8010045b:	83 ec 0c             	sub    $0xc,%esp
8010045e:	68 7c 95 10 80       	push   $0x8010957c
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
801004ee:	8b 04 85 8c 95 10 80 	mov    -0x7fef6a74(,%eax,4),%eax
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
8010054c:	c7 45 ec 85 95 10 80 	movl   $0x80109585,-0x14(%ebp)
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
801005fd:	e8 55 4d 00 00       	call   80105357 <release>
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
80100621:	e8 a2 2b 00 00       	call   801031c8 <lapicid>
80100626:	83 ec 08             	sub    $0x8,%esp
80100629:	50                   	push   %eax
8010062a:	68 e4 95 10 80       	push   $0x801095e4
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
80100649:	68 f8 95 10 80       	push   $0x801095f8
8010064e:	e8 c5 fd ff ff       	call   80100418 <cprintf>
80100653:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100656:	83 ec 08             	sub    $0x8,%esp
80100659:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010065c:	50                   	push   %eax
8010065d:	8d 45 08             	lea    0x8(%ebp),%eax
80100660:	50                   	push   %eax
80100661:	e8 47 4d 00 00       	call   801053ad <getcallerpcs>
80100666:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100669:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100670:	eb 1c                	jmp    8010068e <panic+0x86>
    cprintf(" %p", pcs[i]);
80100672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100675:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100679:	83 ec 08             	sub    $0x8,%esp
8010067c:	50                   	push   %eax
8010067d:	68 fa 95 10 80       	push   $0x801095fa
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
80100772:	68 fe 95 10 80       	push   $0x801095fe
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
8010079f:	e8 a7 4e 00 00       	call   8010564b <memmove>
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
801007c9:	e8 b6 4d 00 00       	call   80105584 <memset>
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
80100865:	e8 29 68 00 00       	call   80107093 <uartputc>
8010086a:	83 c4 10             	add    $0x10,%esp
8010086d:	83 ec 0c             	sub    $0xc,%esp
80100870:	6a 20                	push   $0x20
80100872:	e8 1c 68 00 00       	call   80107093 <uartputc>
80100877:	83 c4 10             	add    $0x10,%esp
8010087a:	83 ec 0c             	sub    $0xc,%esp
8010087d:	6a 08                	push   $0x8
8010087f:	e8 0f 68 00 00       	call   80107093 <uartputc>
80100884:	83 c4 10             	add    $0x10,%esp
80100887:	eb 0e                	jmp    80100897 <consputc+0x5a>
  } else
    uartputc(c);
80100889:	83 ec 0c             	sub    $0xc,%esp
8010088c:	ff 75 08             	pushl  0x8(%ebp)
8010088f:	e8 ff 67 00 00       	call   80107093 <uartputc>
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
801008c1:	e8 1f 4a 00 00       	call   801052e5 <acquire>
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
80100a17:	e8 49 45 00 00       	call   80104f65 <wakeup>
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
80100a3a:	e8 18 49 00 00       	call   80105357 <release>
80100a3f:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100a42:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100a46:	74 05                	je     80100a4d <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
80100a48:	e8 de 45 00 00       	call   8010502b <procdump>
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
80100a60:	e8 f7 11 00 00       	call   80101c5c <iunlock>
80100a65:	83 c4 10             	add    $0x10,%esp
  target = n;
80100a68:	8b 45 10             	mov    0x10(%ebp),%eax
80100a6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	68 c0 d5 10 80       	push   $0x8010d5c0
80100a76:	e8 6a 48 00 00       	call   801052e5 <acquire>
80100a7b:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100a7e:	e9 ab 00 00 00       	jmp    80100b2e <consoleread+0xde>
    while(input.r == input.w){
      if(myproc()->killed){
80100a83:	e8 71 3a 00 00       	call   801044f9 <myproc>
80100a88:	8b 40 24             	mov    0x24(%eax),%eax
80100a8b:	85 c0                	test   %eax,%eax
80100a8d:	74 28                	je     80100ab7 <consoleread+0x67>
        release(&cons.lock);
80100a8f:	83 ec 0c             	sub    $0xc,%esp
80100a92:	68 c0 d5 10 80       	push   $0x8010d5c0
80100a97:	e8 bb 48 00 00       	call   80105357 <release>
80100a9c:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a9f:	83 ec 0c             	sub    $0xc,%esp
80100aa2:	ff 75 08             	pushl  0x8(%ebp)
80100aa5:	e8 9b 10 00 00       	call   80101b45 <ilock>
80100aaa:	83 c4 10             	add    $0x10,%esp
        return -1;
80100aad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ab2:	e9 ab 00 00 00       	jmp    80100b62 <consoleread+0x112>
      }
      sleep(&input.r, &cons.lock);
80100ab7:	83 ec 08             	sub    $0x8,%esp
80100aba:	68 c0 d5 10 80       	push   $0x8010d5c0
80100abf:	68 40 30 11 80       	push   $0x80113040
80100ac4:	e8 aa 43 00 00       	call   80104e73 <sleep>
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
80100b42:	e8 10 48 00 00       	call   80105357 <release>
80100b47:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b4a:	83 ec 0c             	sub    $0xc,%esp
80100b4d:	ff 75 08             	pushl  0x8(%ebp)
80100b50:	e8 f0 0f 00 00       	call   80101b45 <ilock>
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
80100b74:	e8 e3 10 00 00       	call   80101c5c <iunlock>
80100b79:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100b7c:	83 ec 0c             	sub    $0xc,%esp
80100b7f:	68 c0 d5 10 80       	push   $0x8010d5c0
80100b84:	e8 5c 47 00 00       	call   801052e5 <acquire>
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
80100bc6:	e8 8c 47 00 00       	call   80105357 <release>
80100bcb:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100bce:	83 ec 0c             	sub    $0xc,%esp
80100bd1:	ff 75 08             	pushl  0x8(%ebp)
80100bd4:	e8 6c 0f 00 00       	call   80101b45 <ilock>
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
80100bee:	68 11 96 10 80       	push   $0x80109611
80100bf3:	68 c0 d5 10 80       	push   $0x8010d5c0
80100bf8:	e8 c2 46 00 00       	call   801052bf <initlock>
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
80100c25:	e8 85 20 00 00       	call   80102caf <ioapicenable>
80100c2a:	83 c4 10             	add    $0x10,%esp
}
80100c2d:	90                   	nop
80100c2e:	c9                   	leave  
80100c2f:	c3                   	ret    

80100c30 <exec>:
#include "x86.h"
#include "elf.h"
//TODO  Encrypt all those pages set up by the exec function at the end of the exec function. These pages include program text, data, and stack pages. These pages are not allocated through growproc() and thus not handle by the first case
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
80100c3d:	e8 b7 38 00 00       	call   801044f9 <myproc>
80100c42:	89 45 cc             	mov    %eax,-0x34(%ebp)

  
  //access this process's queue?*****
  for(int j=0; j<CLOCKSIZE; j++){
80100c45:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
80100c4c:	eb 15                	jmp    80100c63 <exec+0x33>
  	curproc->clock[j].addr=0;
80100c4e:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100c51:	8b 55 d0             	mov    -0x30(%ebp),%edx
80100c54:	83 c2 0e             	add    $0xe,%edx
80100c57:	c7 44 d0 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,8)
80100c5e:	00 
  for(int j=0; j<CLOCKSIZE; j++){
80100c5f:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
80100c63:	83 7d d0 07          	cmpl   $0x7,-0x30(%ebp)
80100c67:	7e e5                	jle    80100c4e <exec+0x1e>
  }
  curproc->head = 0;
80100c69:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100c6c:	c7 80 bc 00 00 00 00 	movl   $0x0,0xbc(%eax)
80100c73:	00 00 00 
  begin_op();
80100c76:	e8 bf 2a 00 00       	call   8010373a <begin_op>

  if((ip = namei(path)) == 0){
80100c7b:	83 ec 0c             	sub    $0xc,%esp
80100c7e:	ff 75 08             	pushl  0x8(%ebp)
80100c81:	e8 2a 1a 00 00       	call   801026b0 <namei>
80100c86:	83 c4 10             	add    $0x10,%esp
80100c89:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c8c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c90:	75 1f                	jne    80100cb1 <exec+0x81>
    end_op();
80100c92:	e8 33 2b 00 00       	call   801037ca <end_op>
    cprintf("exec: fail\n");
80100c97:	83 ec 0c             	sub    $0xc,%esp
80100c9a:	68 19 96 10 80       	push   $0x80109619
80100c9f:	e8 74 f7 ff ff       	call   80100418 <cprintf>
80100ca4:	83 c4 10             	add    $0x10,%esp
    return -1;
80100ca7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100cac:	e9 2a 04 00 00       	jmp    801010db <exec+0x4ab>
  }
  ilock(ip);
80100cb1:	83 ec 0c             	sub    $0xc,%esp
80100cb4:	ff 75 d8             	pushl  -0x28(%ebp)
80100cb7:	e8 89 0e 00 00       	call   80101b45 <ilock>
80100cbc:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100cbf:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100cc6:	6a 34                	push   $0x34
80100cc8:	6a 00                	push   $0x0
80100cca:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
80100cd0:	50                   	push   %eax
80100cd1:	ff 75 d8             	pushl  -0x28(%ebp)
80100cd4:	e8 74 13 00 00       	call   8010204d <readi>
80100cd9:	83 c4 10             	add    $0x10,%esp
80100cdc:	83 f8 34             	cmp    $0x34,%eax
80100cdf:	0f 85 9f 03 00 00    	jne    80101084 <exec+0x454>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100ce5:	8b 85 04 ff ff ff    	mov    -0xfc(%ebp),%eax
80100ceb:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100cf0:	0f 85 91 03 00 00    	jne    80101087 <exec+0x457>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100cf6:	e8 cf 73 00 00       	call   801080ca <setupkvm>
80100cfb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100cfe:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100d02:	0f 84 82 03 00 00    	je     8010108a <exec+0x45a>
    goto bad;

  // Load program into memory.
  sz = 0;
80100d08:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d0f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100d16:	8b 85 20 ff ff ff    	mov    -0xe0(%ebp),%eax
80100d1c:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d1f:	e9 de 00 00 00       	jmp    80100e02 <exec+0x1d2>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100d24:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d27:	6a 20                	push   $0x20
80100d29:	50                   	push   %eax
80100d2a:	8d 85 e4 fe ff ff    	lea    -0x11c(%ebp),%eax
80100d30:	50                   	push   %eax
80100d31:	ff 75 d8             	pushl  -0x28(%ebp)
80100d34:	e8 14 13 00 00       	call   8010204d <readi>
80100d39:	83 c4 10             	add    $0x10,%esp
80100d3c:	83 f8 20             	cmp    $0x20,%eax
80100d3f:	0f 85 48 03 00 00    	jne    8010108d <exec+0x45d>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100d45:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
80100d4b:	83 f8 01             	cmp    $0x1,%eax
80100d4e:	0f 85 a0 00 00 00    	jne    80100df4 <exec+0x1c4>
      continue;
    if(ph.memsz < ph.filesz)
80100d54:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100d5a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100d60:	39 c2                	cmp    %eax,%edx
80100d62:	0f 82 28 03 00 00    	jb     80101090 <exec+0x460>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100d68:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100d6e:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100d74:	01 c2                	add    %eax,%edx
80100d76:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d7c:	39 c2                	cmp    %eax,%edx
80100d7e:	0f 82 0f 03 00 00    	jb     80101093 <exec+0x463>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100d84:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100d8a:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100d90:	01 d0                	add    %edx,%eax
80100d92:	83 ec 04             	sub    $0x4,%esp
80100d95:	50                   	push   %eax
80100d96:	ff 75 e0             	pushl  -0x20(%ebp)
80100d99:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d9c:	e8 e7 76 00 00       	call   80108488 <allocuvm>
80100da1:	83 c4 10             	add    $0x10,%esp
80100da4:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100da7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100dab:	0f 84 e5 02 00 00    	je     80101096 <exec+0x466>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100db1:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100db7:	25 ff 0f 00 00       	and    $0xfff,%eax
80100dbc:	85 c0                	test   %eax,%eax
80100dbe:	0f 85 d5 02 00 00    	jne    80101099 <exec+0x469>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100dc4:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100dca:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100dd0:	8b 8d ec fe ff ff    	mov    -0x114(%ebp),%ecx
80100dd6:	83 ec 0c             	sub    $0xc,%esp
80100dd9:	52                   	push   %edx
80100dda:	50                   	push   %eax
80100ddb:	ff 75 d8             	pushl  -0x28(%ebp)
80100dde:	51                   	push   %ecx
80100ddf:	ff 75 d4             	pushl  -0x2c(%ebp)
80100de2:	e8 d0 75 00 00       	call   801083b7 <loaduvm>
80100de7:	83 c4 20             	add    $0x20,%esp
80100dea:	85 c0                	test   %eax,%eax
80100dec:	0f 88 aa 02 00 00    	js     8010109c <exec+0x46c>
80100df2:	eb 01                	jmp    80100df5 <exec+0x1c5>
      continue;
80100df4:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100df5:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100df9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100dfc:	83 c0 20             	add    $0x20,%eax
80100dff:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100e02:	0f b7 85 30 ff ff ff 	movzwl -0xd0(%ebp),%eax
80100e09:	0f b7 c0             	movzwl %ax,%eax
80100e0c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100e0f:	0f 8c 0f ff ff ff    	jl     80100d24 <exec+0xf4>
      goto bad;
  }
  iunlockput(ip);
80100e15:	83 ec 0c             	sub    $0xc,%esp
80100e18:	ff 75 d8             	pushl  -0x28(%ebp)
80100e1b:	e8 62 0f 00 00       	call   80101d82 <iunlockput>
80100e20:	83 c4 10             	add    $0x10,%esp
  end_op();
80100e23:	e8 a2 29 00 00       	call   801037ca <end_op>
  ip = 0;
80100e28:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  
 
  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100e2f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e32:	05 ff 0f 00 00       	add    $0xfff,%eax
80100e37:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100e3c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100e3f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e42:	05 00 20 00 00       	add    $0x2000,%eax
80100e47:	83 ec 04             	sub    $0x4,%esp
80100e4a:	50                   	push   %eax
80100e4b:	ff 75 e0             	pushl  -0x20(%ebp)
80100e4e:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e51:	e8 32 76 00 00       	call   80108488 <allocuvm>
80100e56:	83 c4 10             	add    $0x10,%esp
80100e59:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100e5c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100e60:	0f 84 39 02 00 00    	je     8010109f <exec+0x46f>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100e66:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e69:	2d 00 20 00 00       	sub    $0x2000,%eax
80100e6e:	83 ec 08             	sub    $0x8,%esp
80100e71:	50                   	push   %eax
80100e72:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e75:	e8 80 78 00 00       	call   801086fa <clearpteu>
80100e7a:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100e7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e80:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e83:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100e8a:	e9 96 00 00 00       	jmp    80100f25 <exec+0x2f5>
    if(argc >= MAXARG)
80100e8f:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100e93:	0f 87 09 02 00 00    	ja     801010a2 <exec+0x472>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e9c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ea3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ea6:	01 d0                	add    %edx,%eax
80100ea8:	8b 00                	mov    (%eax),%eax
80100eaa:	83 ec 0c             	sub    $0xc,%esp
80100ead:	50                   	push   %eax
80100eae:	e8 3a 49 00 00       	call   801057ed <strlen>
80100eb3:	83 c4 10             	add    $0x10,%esp
80100eb6:	89 c2                	mov    %eax,%edx
80100eb8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ebb:	29 d0                	sub    %edx,%eax
80100ebd:	83 e8 01             	sub    $0x1,%eax
80100ec0:	83 e0 fc             	and    $0xfffffffc,%eax
80100ec3:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100ec6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ec9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ed0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ed3:	01 d0                	add    %edx,%eax
80100ed5:	8b 00                	mov    (%eax),%eax
80100ed7:	83 ec 0c             	sub    $0xc,%esp
80100eda:	50                   	push   %eax
80100edb:	e8 0d 49 00 00       	call   801057ed <strlen>
80100ee0:	83 c4 10             	add    $0x10,%esp
80100ee3:	83 c0 01             	add    $0x1,%eax
80100ee6:	89 c1                	mov    %eax,%ecx
80100ee8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eeb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ef2:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ef5:	01 d0                	add    %edx,%eax
80100ef7:	8b 00                	mov    (%eax),%eax
80100ef9:	51                   	push   %ecx
80100efa:	50                   	push   %eax
80100efb:	ff 75 dc             	pushl  -0x24(%ebp)
80100efe:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f01:	e8 b0 79 00 00       	call   801088b6 <copyout>
80100f06:	83 c4 10             	add    $0x10,%esp
80100f09:	85 c0                	test   %eax,%eax
80100f0b:	0f 88 94 01 00 00    	js     801010a5 <exec+0x475>
      goto bad;
    ustack[3+argc] = sp;
80100f11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f14:	8d 50 03             	lea    0x3(%eax),%edx
80100f17:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f1a:	89 84 95 38 ff ff ff 	mov    %eax,-0xc8(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100f21:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100f25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f28:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f32:	01 d0                	add    %edx,%eax
80100f34:	8b 00                	mov    (%eax),%eax
80100f36:	85 c0                	test   %eax,%eax
80100f38:	0f 85 51 ff ff ff    	jne    80100e8f <exec+0x25f>
  }
  ustack[3+argc] = 0;
80100f3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f41:	83 c0 03             	add    $0x3,%eax
80100f44:	c7 84 85 38 ff ff ff 	movl   $0x0,-0xc8(%ebp,%eax,4)
80100f4b:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100f4f:	c7 85 38 ff ff ff ff 	movl   $0xffffffff,-0xc8(%ebp)
80100f56:	ff ff ff 
  ustack[1] = argc;
80100f59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f5c:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100f62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f65:	83 c0 01             	add    $0x1,%eax
80100f68:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f6f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f72:	29 d0                	sub    %edx,%eax
80100f74:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)

  sp -= (3+argc+1) * 4;
80100f7a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f7d:	83 c0 04             	add    $0x4,%eax
80100f80:	c1 e0 02             	shl    $0x2,%eax
80100f83:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100f86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f89:	83 c0 04             	add    $0x4,%eax
80100f8c:	c1 e0 02             	shl    $0x2,%eax
80100f8f:	50                   	push   %eax
80100f90:	8d 85 38 ff ff ff    	lea    -0xc8(%ebp),%eax
80100f96:	50                   	push   %eax
80100f97:	ff 75 dc             	pushl  -0x24(%ebp)
80100f9a:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f9d:	e8 14 79 00 00       	call   801088b6 <copyout>
80100fa2:	83 c4 10             	add    $0x10,%esp
80100fa5:	85 c0                	test   %eax,%eax
80100fa7:	0f 88 fb 00 00 00    	js     801010a8 <exec+0x478>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100fad:	8b 45 08             	mov    0x8(%ebp),%eax
80100fb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100fb9:	eb 17                	jmp    80100fd2 <exec+0x3a2>
    if(*s == '/')
80100fbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fbe:	0f b6 00             	movzbl (%eax),%eax
80100fc1:	3c 2f                	cmp    $0x2f,%al
80100fc3:	75 09                	jne    80100fce <exec+0x39e>
      last = s+1;
80100fc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fc8:	83 c0 01             	add    $0x1,%eax
80100fcb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100fce:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fd5:	0f b6 00             	movzbl (%eax),%eax
80100fd8:	84 c0                	test   %al,%al
80100fda:	75 df                	jne    80100fbb <exec+0x38b>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100fdc:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100fdf:	83 c0 6c             	add    $0x6c,%eax
80100fe2:	83 ec 04             	sub    $0x4,%esp
80100fe5:	6a 10                	push   $0x10
80100fe7:	ff 75 f0             	pushl  -0x10(%ebp)
80100fea:	50                   	push   %eax
80100feb:	e8 af 47 00 00       	call   8010579f <safestrcpy>
80100ff0:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100ff3:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100ff6:	8b 40 04             	mov    0x4(%eax),%eax
80100ff9:	89 45 c8             	mov    %eax,-0x38(%ebp)
  curproc->pgdir = pgdir;
80100ffc:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100fff:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80101002:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80101005:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101008:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010100b:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
8010100d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101010:	8b 40 18             	mov    0x18(%eax),%eax
80101013:	8b 95 1c ff ff ff    	mov    -0xe4(%ebp),%edx
80101019:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
8010101c:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010101f:	8b 40 18             	mov    0x18(%eax),%eax
80101022:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101025:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80101028:	83 ec 0c             	sub    $0xc,%esp
8010102b:	ff 75 cc             	pushl  -0x34(%ebp)
8010102e:	e8 6d 71 00 00       	call   801081a0 <switchuvm>
80101033:	83 c4 10             	add    $0x10,%esp
if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
  goto bad;
clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
sp = sz;
*/
  for(i=0; i<sz; i+=PGSIZE)
80101036:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010103d:	eb 28                	jmp    80101067 <exec+0x437>
  {
	  if(i!=sz-2*PGSIZE)
8010103f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101042:	8d 90 00 e0 ff ff    	lea    -0x2000(%eax),%edx
80101048:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010104b:	39 c2                	cmp    %eax,%edx
8010104d:	74 11                	je     80101060 <exec+0x430>
	  	mencrypt((char *)i, 1);
8010104f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101052:	83 ec 08             	sub    $0x8,%esp
80101055:	6a 01                	push   $0x1
80101057:	50                   	push   %eax
80101058:	e8 d0 7f 00 00       	call   8010902d <mencrypt>
8010105d:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<sz; i+=PGSIZE)
80101060:	81 45 ec 00 10 00 00 	addl   $0x1000,-0x14(%ebp)
80101067:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010106a:	39 45 e0             	cmp    %eax,-0x20(%ebp)
8010106d:	77 d0                	ja     8010103f <exec+0x40f>
  int t = sz/PGSIZE;
  if(sz%PGSIZE)
	  t++;
  mencrypt(0, t-2);
  mencrypt((char*) ((t-1)*PGSIZE),1);*/
 freevm(oldpgdir);
8010106f:	83 ec 0c             	sub    $0xc,%esp
80101072:	ff 75 c8             	pushl  -0x38(%ebp)
80101075:	e8 e1 75 00 00       	call   8010865b <freevm>
8010107a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010107d:	b8 00 00 00 00       	mov    $0x0,%eax
80101082:	eb 57                	jmp    801010db <exec+0x4ab>
    goto bad;
80101084:	90                   	nop
80101085:	eb 22                	jmp    801010a9 <exec+0x479>
    goto bad;
80101087:	90                   	nop
80101088:	eb 1f                	jmp    801010a9 <exec+0x479>
    goto bad;
8010108a:	90                   	nop
8010108b:	eb 1c                	jmp    801010a9 <exec+0x479>
      goto bad;
8010108d:	90                   	nop
8010108e:	eb 19                	jmp    801010a9 <exec+0x479>
      goto bad;
80101090:	90                   	nop
80101091:	eb 16                	jmp    801010a9 <exec+0x479>
      goto bad;
80101093:	90                   	nop
80101094:	eb 13                	jmp    801010a9 <exec+0x479>
      goto bad;
80101096:	90                   	nop
80101097:	eb 10                	jmp    801010a9 <exec+0x479>
      goto bad;
80101099:	90                   	nop
8010109a:	eb 0d                	jmp    801010a9 <exec+0x479>
      goto bad;
8010109c:	90                   	nop
8010109d:	eb 0a                	jmp    801010a9 <exec+0x479>
    goto bad;
8010109f:	90                   	nop
801010a0:	eb 07                	jmp    801010a9 <exec+0x479>
      goto bad;
801010a2:	90                   	nop
801010a3:	eb 04                	jmp    801010a9 <exec+0x479>
      goto bad;
801010a5:	90                   	nop
801010a6:	eb 01                	jmp    801010a9 <exec+0x479>
    goto bad;
801010a8:	90                   	nop

 bad:
  if(pgdir)
801010a9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
801010ad:	74 0e                	je     801010bd <exec+0x48d>
    freevm(pgdir);
801010af:	83 ec 0c             	sub    $0xc,%esp
801010b2:	ff 75 d4             	pushl  -0x2c(%ebp)
801010b5:	e8 a1 75 00 00       	call   8010865b <freevm>
801010ba:	83 c4 10             	add    $0x10,%esp
  if(ip){
801010bd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
801010c1:	74 13                	je     801010d6 <exec+0x4a6>
    iunlockput(ip);
801010c3:	83 ec 0c             	sub    $0xc,%esp
801010c6:	ff 75 d8             	pushl  -0x28(%ebp)
801010c9:	e8 b4 0c 00 00       	call   80101d82 <iunlockput>
801010ce:	83 c4 10             	add    $0x10,%esp
    end_op();
801010d1:	e8 f4 26 00 00       	call   801037ca <end_op>
  }
  return -1;
801010d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801010db:	c9                   	leave  
801010dc:	c3                   	ret    

801010dd <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
801010dd:	f3 0f 1e fb          	endbr32 
801010e1:	55                   	push   %ebp
801010e2:	89 e5                	mov    %esp,%ebp
801010e4:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
801010e7:	83 ec 08             	sub    $0x8,%esp
801010ea:	68 25 96 10 80       	push   $0x80109625
801010ef:	68 60 30 11 80       	push   $0x80113060
801010f4:	e8 c6 41 00 00       	call   801052bf <initlock>
801010f9:	83 c4 10             	add    $0x10,%esp
}
801010fc:	90                   	nop
801010fd:	c9                   	leave  
801010fe:	c3                   	ret    

801010ff <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
801010ff:	f3 0f 1e fb          	endbr32 
80101103:	55                   	push   %ebp
80101104:	89 e5                	mov    %esp,%ebp
80101106:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80101109:	83 ec 0c             	sub    $0xc,%esp
8010110c:	68 60 30 11 80       	push   $0x80113060
80101111:	e8 cf 41 00 00       	call   801052e5 <acquire>
80101116:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101119:	c7 45 f4 94 30 11 80 	movl   $0x80113094,-0xc(%ebp)
80101120:	eb 2d                	jmp    8010114f <filealloc+0x50>
    if(f->ref == 0){
80101122:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101125:	8b 40 04             	mov    0x4(%eax),%eax
80101128:	85 c0                	test   %eax,%eax
8010112a:	75 1f                	jne    8010114b <filealloc+0x4c>
      f->ref = 1;
8010112c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010112f:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101136:	83 ec 0c             	sub    $0xc,%esp
80101139:	68 60 30 11 80       	push   $0x80113060
8010113e:	e8 14 42 00 00       	call   80105357 <release>
80101143:	83 c4 10             	add    $0x10,%esp
      return f;
80101146:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101149:	eb 23                	jmp    8010116e <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010114b:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
8010114f:	b8 f4 39 11 80       	mov    $0x801139f4,%eax
80101154:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101157:	72 c9                	jb     80101122 <filealloc+0x23>
    }
  }
  release(&ftable.lock);
80101159:	83 ec 0c             	sub    $0xc,%esp
8010115c:	68 60 30 11 80       	push   $0x80113060
80101161:	e8 f1 41 00 00       	call   80105357 <release>
80101166:	83 c4 10             	add    $0x10,%esp
  return 0;
80101169:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010116e:	c9                   	leave  
8010116f:	c3                   	ret    

80101170 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101170:	f3 0f 1e fb          	endbr32 
80101174:	55                   	push   %ebp
80101175:	89 e5                	mov    %esp,%ebp
80101177:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
8010117a:	83 ec 0c             	sub    $0xc,%esp
8010117d:	68 60 30 11 80       	push   $0x80113060
80101182:	e8 5e 41 00 00       	call   801052e5 <acquire>
80101187:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010118a:	8b 45 08             	mov    0x8(%ebp),%eax
8010118d:	8b 40 04             	mov    0x4(%eax),%eax
80101190:	85 c0                	test   %eax,%eax
80101192:	7f 0d                	jg     801011a1 <filedup+0x31>
    panic("filedup");
80101194:	83 ec 0c             	sub    $0xc,%esp
80101197:	68 2c 96 10 80       	push   $0x8010962c
8010119c:	e8 67 f4 ff ff       	call   80100608 <panic>
  f->ref++;
801011a1:	8b 45 08             	mov    0x8(%ebp),%eax
801011a4:	8b 40 04             	mov    0x4(%eax),%eax
801011a7:	8d 50 01             	lea    0x1(%eax),%edx
801011aa:	8b 45 08             	mov    0x8(%ebp),%eax
801011ad:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801011b0:	83 ec 0c             	sub    $0xc,%esp
801011b3:	68 60 30 11 80       	push   $0x80113060
801011b8:	e8 9a 41 00 00       	call   80105357 <release>
801011bd:	83 c4 10             	add    $0x10,%esp
  return f;
801011c0:	8b 45 08             	mov    0x8(%ebp),%eax
}
801011c3:	c9                   	leave  
801011c4:	c3                   	ret    

801011c5 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801011c5:	f3 0f 1e fb          	endbr32 
801011c9:	55                   	push   %ebp
801011ca:	89 e5                	mov    %esp,%ebp
801011cc:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801011cf:	83 ec 0c             	sub    $0xc,%esp
801011d2:	68 60 30 11 80       	push   $0x80113060
801011d7:	e8 09 41 00 00       	call   801052e5 <acquire>
801011dc:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801011df:	8b 45 08             	mov    0x8(%ebp),%eax
801011e2:	8b 40 04             	mov    0x4(%eax),%eax
801011e5:	85 c0                	test   %eax,%eax
801011e7:	7f 0d                	jg     801011f6 <fileclose+0x31>
    panic("fileclose");
801011e9:	83 ec 0c             	sub    $0xc,%esp
801011ec:	68 34 96 10 80       	push   $0x80109634
801011f1:	e8 12 f4 ff ff       	call   80100608 <panic>
  if(--f->ref > 0){
801011f6:	8b 45 08             	mov    0x8(%ebp),%eax
801011f9:	8b 40 04             	mov    0x4(%eax),%eax
801011fc:	8d 50 ff             	lea    -0x1(%eax),%edx
801011ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101202:	89 50 04             	mov    %edx,0x4(%eax)
80101205:	8b 45 08             	mov    0x8(%ebp),%eax
80101208:	8b 40 04             	mov    0x4(%eax),%eax
8010120b:	85 c0                	test   %eax,%eax
8010120d:	7e 15                	jle    80101224 <fileclose+0x5f>
    release(&ftable.lock);
8010120f:	83 ec 0c             	sub    $0xc,%esp
80101212:	68 60 30 11 80       	push   $0x80113060
80101217:	e8 3b 41 00 00       	call   80105357 <release>
8010121c:	83 c4 10             	add    $0x10,%esp
8010121f:	e9 8b 00 00 00       	jmp    801012af <fileclose+0xea>
    return;
  }
  ff = *f;
80101224:	8b 45 08             	mov    0x8(%ebp),%eax
80101227:	8b 10                	mov    (%eax),%edx
80101229:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010122c:	8b 50 04             	mov    0x4(%eax),%edx
8010122f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101232:	8b 50 08             	mov    0x8(%eax),%edx
80101235:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101238:	8b 50 0c             	mov    0xc(%eax),%edx
8010123b:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010123e:	8b 50 10             	mov    0x10(%eax),%edx
80101241:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101244:	8b 40 14             	mov    0x14(%eax),%eax
80101247:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010124a:	8b 45 08             	mov    0x8(%ebp),%eax
8010124d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101254:	8b 45 08             	mov    0x8(%ebp),%eax
80101257:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010125d:	83 ec 0c             	sub    $0xc,%esp
80101260:	68 60 30 11 80       	push   $0x80113060
80101265:	e8 ed 40 00 00       	call   80105357 <release>
8010126a:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
8010126d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101270:	83 f8 01             	cmp    $0x1,%eax
80101273:	75 19                	jne    8010128e <fileclose+0xc9>
    pipeclose(ff.pipe, ff.writable);
80101275:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101279:	0f be d0             	movsbl %al,%edx
8010127c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010127f:	83 ec 08             	sub    $0x8,%esp
80101282:	52                   	push   %edx
80101283:	50                   	push   %eax
80101284:	e8 e7 2e 00 00       	call   80104170 <pipeclose>
80101289:	83 c4 10             	add    $0x10,%esp
8010128c:	eb 21                	jmp    801012af <fileclose+0xea>
  else if(ff.type == FD_INODE){
8010128e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101291:	83 f8 02             	cmp    $0x2,%eax
80101294:	75 19                	jne    801012af <fileclose+0xea>
    begin_op();
80101296:	e8 9f 24 00 00       	call   8010373a <begin_op>
    iput(ff.ip);
8010129b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010129e:	83 ec 0c             	sub    $0xc,%esp
801012a1:	50                   	push   %eax
801012a2:	e8 07 0a 00 00       	call   80101cae <iput>
801012a7:	83 c4 10             	add    $0x10,%esp
    end_op();
801012aa:	e8 1b 25 00 00       	call   801037ca <end_op>
  }
}
801012af:	c9                   	leave  
801012b0:	c3                   	ret    

801012b1 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801012b1:	f3 0f 1e fb          	endbr32 
801012b5:	55                   	push   %ebp
801012b6:	89 e5                	mov    %esp,%ebp
801012b8:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801012bb:	8b 45 08             	mov    0x8(%ebp),%eax
801012be:	8b 00                	mov    (%eax),%eax
801012c0:	83 f8 02             	cmp    $0x2,%eax
801012c3:	75 40                	jne    80101305 <filestat+0x54>
    ilock(f->ip);
801012c5:	8b 45 08             	mov    0x8(%ebp),%eax
801012c8:	8b 40 10             	mov    0x10(%eax),%eax
801012cb:	83 ec 0c             	sub    $0xc,%esp
801012ce:	50                   	push   %eax
801012cf:	e8 71 08 00 00       	call   80101b45 <ilock>
801012d4:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801012d7:	8b 45 08             	mov    0x8(%ebp),%eax
801012da:	8b 40 10             	mov    0x10(%eax),%eax
801012dd:	83 ec 08             	sub    $0x8,%esp
801012e0:	ff 75 0c             	pushl  0xc(%ebp)
801012e3:	50                   	push   %eax
801012e4:	e8 1a 0d 00 00       	call   80102003 <stati>
801012e9:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801012ec:	8b 45 08             	mov    0x8(%ebp),%eax
801012ef:	8b 40 10             	mov    0x10(%eax),%eax
801012f2:	83 ec 0c             	sub    $0xc,%esp
801012f5:	50                   	push   %eax
801012f6:	e8 61 09 00 00       	call   80101c5c <iunlock>
801012fb:	83 c4 10             	add    $0x10,%esp
    return 0;
801012fe:	b8 00 00 00 00       	mov    $0x0,%eax
80101303:	eb 05                	jmp    8010130a <filestat+0x59>
  }
  return -1;
80101305:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010130a:	c9                   	leave  
8010130b:	c3                   	ret    

8010130c <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010130c:	f3 0f 1e fb          	endbr32 
80101310:	55                   	push   %ebp
80101311:	89 e5                	mov    %esp,%ebp
80101313:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101316:	8b 45 08             	mov    0x8(%ebp),%eax
80101319:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010131d:	84 c0                	test   %al,%al
8010131f:	75 0a                	jne    8010132b <fileread+0x1f>
    return -1;
80101321:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101326:	e9 9b 00 00 00       	jmp    801013c6 <fileread+0xba>
  if(f->type == FD_PIPE)
8010132b:	8b 45 08             	mov    0x8(%ebp),%eax
8010132e:	8b 00                	mov    (%eax),%eax
80101330:	83 f8 01             	cmp    $0x1,%eax
80101333:	75 1a                	jne    8010134f <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101335:	8b 45 08             	mov    0x8(%ebp),%eax
80101338:	8b 40 0c             	mov    0xc(%eax),%eax
8010133b:	83 ec 04             	sub    $0x4,%esp
8010133e:	ff 75 10             	pushl  0x10(%ebp)
80101341:	ff 75 0c             	pushl  0xc(%ebp)
80101344:	50                   	push   %eax
80101345:	e8 db 2f 00 00       	call   80104325 <piperead>
8010134a:	83 c4 10             	add    $0x10,%esp
8010134d:	eb 77                	jmp    801013c6 <fileread+0xba>
  if(f->type == FD_INODE){
8010134f:	8b 45 08             	mov    0x8(%ebp),%eax
80101352:	8b 00                	mov    (%eax),%eax
80101354:	83 f8 02             	cmp    $0x2,%eax
80101357:	75 60                	jne    801013b9 <fileread+0xad>
    ilock(f->ip);
80101359:	8b 45 08             	mov    0x8(%ebp),%eax
8010135c:	8b 40 10             	mov    0x10(%eax),%eax
8010135f:	83 ec 0c             	sub    $0xc,%esp
80101362:	50                   	push   %eax
80101363:	e8 dd 07 00 00       	call   80101b45 <ilock>
80101368:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010136b:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010136e:	8b 45 08             	mov    0x8(%ebp),%eax
80101371:	8b 50 14             	mov    0x14(%eax),%edx
80101374:	8b 45 08             	mov    0x8(%ebp),%eax
80101377:	8b 40 10             	mov    0x10(%eax),%eax
8010137a:	51                   	push   %ecx
8010137b:	52                   	push   %edx
8010137c:	ff 75 0c             	pushl  0xc(%ebp)
8010137f:	50                   	push   %eax
80101380:	e8 c8 0c 00 00       	call   8010204d <readi>
80101385:	83 c4 10             	add    $0x10,%esp
80101388:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010138b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010138f:	7e 11                	jle    801013a2 <fileread+0x96>
      f->off += r;
80101391:	8b 45 08             	mov    0x8(%ebp),%eax
80101394:	8b 50 14             	mov    0x14(%eax),%edx
80101397:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010139a:	01 c2                	add    %eax,%edx
8010139c:	8b 45 08             	mov    0x8(%ebp),%eax
8010139f:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801013a2:	8b 45 08             	mov    0x8(%ebp),%eax
801013a5:	8b 40 10             	mov    0x10(%eax),%eax
801013a8:	83 ec 0c             	sub    $0xc,%esp
801013ab:	50                   	push   %eax
801013ac:	e8 ab 08 00 00       	call   80101c5c <iunlock>
801013b1:	83 c4 10             	add    $0x10,%esp
    return r;
801013b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013b7:	eb 0d                	jmp    801013c6 <fileread+0xba>
  }
  panic("fileread");
801013b9:	83 ec 0c             	sub    $0xc,%esp
801013bc:	68 3e 96 10 80       	push   $0x8010963e
801013c1:	e8 42 f2 ff ff       	call   80100608 <panic>
}
801013c6:	c9                   	leave  
801013c7:	c3                   	ret    

801013c8 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801013c8:	f3 0f 1e fb          	endbr32 
801013cc:	55                   	push   %ebp
801013cd:	89 e5                	mov    %esp,%ebp
801013cf:	53                   	push   %ebx
801013d0:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801013d3:	8b 45 08             	mov    0x8(%ebp),%eax
801013d6:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801013da:	84 c0                	test   %al,%al
801013dc:	75 0a                	jne    801013e8 <filewrite+0x20>
    return -1;
801013de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013e3:	e9 1b 01 00 00       	jmp    80101503 <filewrite+0x13b>
  if(f->type == FD_PIPE)
801013e8:	8b 45 08             	mov    0x8(%ebp),%eax
801013eb:	8b 00                	mov    (%eax),%eax
801013ed:	83 f8 01             	cmp    $0x1,%eax
801013f0:	75 1d                	jne    8010140f <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801013f2:	8b 45 08             	mov    0x8(%ebp),%eax
801013f5:	8b 40 0c             	mov    0xc(%eax),%eax
801013f8:	83 ec 04             	sub    $0x4,%esp
801013fb:	ff 75 10             	pushl  0x10(%ebp)
801013fe:	ff 75 0c             	pushl  0xc(%ebp)
80101401:	50                   	push   %eax
80101402:	e8 18 2e 00 00       	call   8010421f <pipewrite>
80101407:	83 c4 10             	add    $0x10,%esp
8010140a:	e9 f4 00 00 00       	jmp    80101503 <filewrite+0x13b>
  if(f->type == FD_INODE){
8010140f:	8b 45 08             	mov    0x8(%ebp),%eax
80101412:	8b 00                	mov    (%eax),%eax
80101414:	83 f8 02             	cmp    $0x2,%eax
80101417:	0f 85 d9 00 00 00    	jne    801014f6 <filewrite+0x12e>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
8010141d:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101424:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010142b:	e9 a3 00 00 00       	jmp    801014d3 <filewrite+0x10b>
      int n1 = n - i;
80101430:	8b 45 10             	mov    0x10(%ebp),%eax
80101433:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101436:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101439:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010143c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010143f:	7e 06                	jle    80101447 <filewrite+0x7f>
        n1 = max;
80101441:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101444:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101447:	e8 ee 22 00 00       	call   8010373a <begin_op>
      ilock(f->ip);
8010144c:	8b 45 08             	mov    0x8(%ebp),%eax
8010144f:	8b 40 10             	mov    0x10(%eax),%eax
80101452:	83 ec 0c             	sub    $0xc,%esp
80101455:	50                   	push   %eax
80101456:	e8 ea 06 00 00       	call   80101b45 <ilock>
8010145b:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010145e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101461:	8b 45 08             	mov    0x8(%ebp),%eax
80101464:	8b 50 14             	mov    0x14(%eax),%edx
80101467:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010146a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010146d:	01 c3                	add    %eax,%ebx
8010146f:	8b 45 08             	mov    0x8(%ebp),%eax
80101472:	8b 40 10             	mov    0x10(%eax),%eax
80101475:	51                   	push   %ecx
80101476:	52                   	push   %edx
80101477:	53                   	push   %ebx
80101478:	50                   	push   %eax
80101479:	e8 28 0d 00 00       	call   801021a6 <writei>
8010147e:	83 c4 10             	add    $0x10,%esp
80101481:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101484:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101488:	7e 11                	jle    8010149b <filewrite+0xd3>
        f->off += r;
8010148a:	8b 45 08             	mov    0x8(%ebp),%eax
8010148d:	8b 50 14             	mov    0x14(%eax),%edx
80101490:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101493:	01 c2                	add    %eax,%edx
80101495:	8b 45 08             	mov    0x8(%ebp),%eax
80101498:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010149b:	8b 45 08             	mov    0x8(%ebp),%eax
8010149e:	8b 40 10             	mov    0x10(%eax),%eax
801014a1:	83 ec 0c             	sub    $0xc,%esp
801014a4:	50                   	push   %eax
801014a5:	e8 b2 07 00 00       	call   80101c5c <iunlock>
801014aa:	83 c4 10             	add    $0x10,%esp
      end_op();
801014ad:	e8 18 23 00 00       	call   801037ca <end_op>

      if(r < 0)
801014b2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801014b6:	78 29                	js     801014e1 <filewrite+0x119>
        break;
      if(r != n1)
801014b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801014bb:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801014be:	74 0d                	je     801014cd <filewrite+0x105>
        panic("short filewrite");
801014c0:	83 ec 0c             	sub    $0xc,%esp
801014c3:	68 47 96 10 80       	push   $0x80109647
801014c8:	e8 3b f1 ff ff       	call   80100608 <panic>
      i += r;
801014cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801014d0:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
801014d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014d6:	3b 45 10             	cmp    0x10(%ebp),%eax
801014d9:	0f 8c 51 ff ff ff    	jl     80101430 <filewrite+0x68>
801014df:	eb 01                	jmp    801014e2 <filewrite+0x11a>
        break;
801014e1:	90                   	nop
    }
    return i == n ? n : -1;
801014e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014e5:	3b 45 10             	cmp    0x10(%ebp),%eax
801014e8:	75 05                	jne    801014ef <filewrite+0x127>
801014ea:	8b 45 10             	mov    0x10(%ebp),%eax
801014ed:	eb 14                	jmp    80101503 <filewrite+0x13b>
801014ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801014f4:	eb 0d                	jmp    80101503 <filewrite+0x13b>
  }
  panic("filewrite");
801014f6:	83 ec 0c             	sub    $0xc,%esp
801014f9:	68 57 96 10 80       	push   $0x80109657
801014fe:	e8 05 f1 ff ff       	call   80100608 <panic>
}
80101503:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101506:	c9                   	leave  
80101507:	c3                   	ret    

80101508 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101508:	f3 0f 1e fb          	endbr32 
8010150c:	55                   	push   %ebp
8010150d:	89 e5                	mov    %esp,%ebp
8010150f:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
80101512:	8b 45 08             	mov    0x8(%ebp),%eax
80101515:	83 ec 08             	sub    $0x8,%esp
80101518:	6a 01                	push   $0x1
8010151a:	50                   	push   %eax
8010151b:	e8 b7 ec ff ff       	call   801001d7 <bread>
80101520:	83 c4 10             	add    $0x10,%esp
80101523:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101526:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101529:	83 c0 5c             	add    $0x5c,%eax
8010152c:	83 ec 04             	sub    $0x4,%esp
8010152f:	6a 1c                	push   $0x1c
80101531:	50                   	push   %eax
80101532:	ff 75 0c             	pushl  0xc(%ebp)
80101535:	e8 11 41 00 00       	call   8010564b <memmove>
8010153a:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010153d:	83 ec 0c             	sub    $0xc,%esp
80101540:	ff 75 f4             	pushl  -0xc(%ebp)
80101543:	e8 19 ed ff ff       	call   80100261 <brelse>
80101548:	83 c4 10             	add    $0x10,%esp
}
8010154b:	90                   	nop
8010154c:	c9                   	leave  
8010154d:	c3                   	ret    

8010154e <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010154e:	f3 0f 1e fb          	endbr32 
80101552:	55                   	push   %ebp
80101553:	89 e5                	mov    %esp,%ebp
80101555:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101558:	8b 55 0c             	mov    0xc(%ebp),%edx
8010155b:	8b 45 08             	mov    0x8(%ebp),%eax
8010155e:	83 ec 08             	sub    $0x8,%esp
80101561:	52                   	push   %edx
80101562:	50                   	push   %eax
80101563:	e8 6f ec ff ff       	call   801001d7 <bread>
80101568:	83 c4 10             	add    $0x10,%esp
8010156b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010156e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101571:	83 c0 5c             	add    $0x5c,%eax
80101574:	83 ec 04             	sub    $0x4,%esp
80101577:	68 00 02 00 00       	push   $0x200
8010157c:	6a 00                	push   $0x0
8010157e:	50                   	push   %eax
8010157f:	e8 00 40 00 00       	call   80105584 <memset>
80101584:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101587:	83 ec 0c             	sub    $0xc,%esp
8010158a:	ff 75 f4             	pushl  -0xc(%ebp)
8010158d:	e8 f1 23 00 00       	call   80103983 <log_write>
80101592:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101595:	83 ec 0c             	sub    $0xc,%esp
80101598:	ff 75 f4             	pushl  -0xc(%ebp)
8010159b:	e8 c1 ec ff ff       	call   80100261 <brelse>
801015a0:	83 c4 10             	add    $0x10,%esp
}
801015a3:	90                   	nop
801015a4:	c9                   	leave  
801015a5:	c3                   	ret    

801015a6 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801015a6:	f3 0f 1e fb          	endbr32 
801015aa:	55                   	push   %ebp
801015ab:	89 e5                	mov    %esp,%ebp
801015ad:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801015b0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801015b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801015be:	e9 13 01 00 00       	jmp    801016d6 <balloc+0x130>
    bp = bread(dev, BBLOCK(b, sb));
801015c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015c6:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801015cc:	85 c0                	test   %eax,%eax
801015ce:	0f 48 c2             	cmovs  %edx,%eax
801015d1:	c1 f8 0c             	sar    $0xc,%eax
801015d4:	89 c2                	mov    %eax,%edx
801015d6:	a1 78 3a 11 80       	mov    0x80113a78,%eax
801015db:	01 d0                	add    %edx,%eax
801015dd:	83 ec 08             	sub    $0x8,%esp
801015e0:	50                   	push   %eax
801015e1:	ff 75 08             	pushl  0x8(%ebp)
801015e4:	e8 ee eb ff ff       	call   801001d7 <bread>
801015e9:	83 c4 10             	add    $0x10,%esp
801015ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015ef:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801015f6:	e9 a6 00 00 00       	jmp    801016a1 <balloc+0xfb>
      m = 1 << (bi % 8);
801015fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015fe:	99                   	cltd   
801015ff:	c1 ea 1d             	shr    $0x1d,%edx
80101602:	01 d0                	add    %edx,%eax
80101604:	83 e0 07             	and    $0x7,%eax
80101607:	29 d0                	sub    %edx,%eax
80101609:	ba 01 00 00 00       	mov    $0x1,%edx
8010160e:	89 c1                	mov    %eax,%ecx
80101610:	d3 e2                	shl    %cl,%edx
80101612:	89 d0                	mov    %edx,%eax
80101614:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101617:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010161a:	8d 50 07             	lea    0x7(%eax),%edx
8010161d:	85 c0                	test   %eax,%eax
8010161f:	0f 48 c2             	cmovs  %edx,%eax
80101622:	c1 f8 03             	sar    $0x3,%eax
80101625:	89 c2                	mov    %eax,%edx
80101627:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010162a:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010162f:	0f b6 c0             	movzbl %al,%eax
80101632:	23 45 e8             	and    -0x18(%ebp),%eax
80101635:	85 c0                	test   %eax,%eax
80101637:	75 64                	jne    8010169d <balloc+0xf7>
        bp->data[bi/8] |= m;  // Mark block in use.
80101639:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010163c:	8d 50 07             	lea    0x7(%eax),%edx
8010163f:	85 c0                	test   %eax,%eax
80101641:	0f 48 c2             	cmovs  %edx,%eax
80101644:	c1 f8 03             	sar    $0x3,%eax
80101647:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010164a:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
8010164f:	89 d1                	mov    %edx,%ecx
80101651:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101654:	09 ca                	or     %ecx,%edx
80101656:	89 d1                	mov    %edx,%ecx
80101658:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010165b:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
8010165f:	83 ec 0c             	sub    $0xc,%esp
80101662:	ff 75 ec             	pushl  -0x14(%ebp)
80101665:	e8 19 23 00 00       	call   80103983 <log_write>
8010166a:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
8010166d:	83 ec 0c             	sub    $0xc,%esp
80101670:	ff 75 ec             	pushl  -0x14(%ebp)
80101673:	e8 e9 eb ff ff       	call   80100261 <brelse>
80101678:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010167b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010167e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101681:	01 c2                	add    %eax,%edx
80101683:	8b 45 08             	mov    0x8(%ebp),%eax
80101686:	83 ec 08             	sub    $0x8,%esp
80101689:	52                   	push   %edx
8010168a:	50                   	push   %eax
8010168b:	e8 be fe ff ff       	call   8010154e <bzero>
80101690:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101693:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101696:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101699:	01 d0                	add    %edx,%eax
8010169b:	eb 57                	jmp    801016f4 <balloc+0x14e>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010169d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801016a1:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801016a8:	7f 17                	jg     801016c1 <balloc+0x11b>
801016aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016b0:	01 d0                	add    %edx,%eax
801016b2:	89 c2                	mov    %eax,%edx
801016b4:	a1 60 3a 11 80       	mov    0x80113a60,%eax
801016b9:	39 c2                	cmp    %eax,%edx
801016bb:	0f 82 3a ff ff ff    	jb     801015fb <balloc+0x55>
      }
    }
    brelse(bp);
801016c1:	83 ec 0c             	sub    $0xc,%esp
801016c4:	ff 75 ec             	pushl  -0x14(%ebp)
801016c7:	e8 95 eb ff ff       	call   80100261 <brelse>
801016cc:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
801016cf:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801016d6:	8b 15 60 3a 11 80    	mov    0x80113a60,%edx
801016dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016df:	39 c2                	cmp    %eax,%edx
801016e1:	0f 87 dc fe ff ff    	ja     801015c3 <balloc+0x1d>
  }
  panic("balloc: out of blocks");
801016e7:	83 ec 0c             	sub    $0xc,%esp
801016ea:	68 64 96 10 80       	push   $0x80109664
801016ef:	e8 14 ef ff ff       	call   80100608 <panic>
}
801016f4:	c9                   	leave  
801016f5:	c3                   	ret    

801016f6 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801016f6:	f3 0f 1e fb          	endbr32 
801016fa:	55                   	push   %ebp
801016fb:	89 e5                	mov    %esp,%ebp
801016fd:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
80101700:	8b 45 0c             	mov    0xc(%ebp),%eax
80101703:	c1 e8 0c             	shr    $0xc,%eax
80101706:	89 c2                	mov    %eax,%edx
80101708:	a1 78 3a 11 80       	mov    0x80113a78,%eax
8010170d:	01 c2                	add    %eax,%edx
8010170f:	8b 45 08             	mov    0x8(%ebp),%eax
80101712:	83 ec 08             	sub    $0x8,%esp
80101715:	52                   	push   %edx
80101716:	50                   	push   %eax
80101717:	e8 bb ea ff ff       	call   801001d7 <bread>
8010171c:	83 c4 10             	add    $0x10,%esp
8010171f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101722:	8b 45 0c             	mov    0xc(%ebp),%eax
80101725:	25 ff 0f 00 00       	and    $0xfff,%eax
8010172a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010172d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101730:	99                   	cltd   
80101731:	c1 ea 1d             	shr    $0x1d,%edx
80101734:	01 d0                	add    %edx,%eax
80101736:	83 e0 07             	and    $0x7,%eax
80101739:	29 d0                	sub    %edx,%eax
8010173b:	ba 01 00 00 00       	mov    $0x1,%edx
80101740:	89 c1                	mov    %eax,%ecx
80101742:	d3 e2                	shl    %cl,%edx
80101744:	89 d0                	mov    %edx,%eax
80101746:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101749:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010174c:	8d 50 07             	lea    0x7(%eax),%edx
8010174f:	85 c0                	test   %eax,%eax
80101751:	0f 48 c2             	cmovs  %edx,%eax
80101754:	c1 f8 03             	sar    $0x3,%eax
80101757:	89 c2                	mov    %eax,%edx
80101759:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010175c:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101761:	0f b6 c0             	movzbl %al,%eax
80101764:	23 45 ec             	and    -0x14(%ebp),%eax
80101767:	85 c0                	test   %eax,%eax
80101769:	75 0d                	jne    80101778 <bfree+0x82>
    panic("freeing free block");
8010176b:	83 ec 0c             	sub    $0xc,%esp
8010176e:	68 7a 96 10 80       	push   $0x8010967a
80101773:	e8 90 ee ff ff       	call   80100608 <panic>
  bp->data[bi/8] &= ~m;
80101778:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010177b:	8d 50 07             	lea    0x7(%eax),%edx
8010177e:	85 c0                	test   %eax,%eax
80101780:	0f 48 c2             	cmovs  %edx,%eax
80101783:	c1 f8 03             	sar    $0x3,%eax
80101786:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101789:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
8010178e:	89 d1                	mov    %edx,%ecx
80101790:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101793:	f7 d2                	not    %edx
80101795:	21 ca                	and    %ecx,%edx
80101797:	89 d1                	mov    %edx,%ecx
80101799:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010179c:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
801017a0:	83 ec 0c             	sub    $0xc,%esp
801017a3:	ff 75 f4             	pushl  -0xc(%ebp)
801017a6:	e8 d8 21 00 00       	call   80103983 <log_write>
801017ab:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801017ae:	83 ec 0c             	sub    $0xc,%esp
801017b1:	ff 75 f4             	pushl  -0xc(%ebp)
801017b4:	e8 a8 ea ff ff       	call   80100261 <brelse>
801017b9:	83 c4 10             	add    $0x10,%esp
}
801017bc:	90                   	nop
801017bd:	c9                   	leave  
801017be:	c3                   	ret    

801017bf <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801017bf:	f3 0f 1e fb          	endbr32 
801017c3:	55                   	push   %ebp
801017c4:	89 e5                	mov    %esp,%ebp
801017c6:	57                   	push   %edi
801017c7:	56                   	push   %esi
801017c8:	53                   	push   %ebx
801017c9:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
801017cc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
801017d3:	83 ec 08             	sub    $0x8,%esp
801017d6:	68 8d 96 10 80       	push   $0x8010968d
801017db:	68 80 3a 11 80       	push   $0x80113a80
801017e0:	e8 da 3a 00 00       	call   801052bf <initlock>
801017e5:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801017e8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801017ef:	eb 2d                	jmp    8010181e <iinit+0x5f>
    initsleeplock(&icache.inode[i].lock, "inode");
801017f1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801017f4:	89 d0                	mov    %edx,%eax
801017f6:	c1 e0 03             	shl    $0x3,%eax
801017f9:	01 d0                	add    %edx,%eax
801017fb:	c1 e0 04             	shl    $0x4,%eax
801017fe:	83 c0 30             	add    $0x30,%eax
80101801:	05 80 3a 11 80       	add    $0x80113a80,%eax
80101806:	83 c0 10             	add    $0x10,%eax
80101809:	83 ec 08             	sub    $0x8,%esp
8010180c:	68 94 96 10 80       	push   $0x80109694
80101811:	50                   	push   %eax
80101812:	e8 15 39 00 00       	call   8010512c <initsleeplock>
80101817:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010181a:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010181e:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
80101822:	7e cd                	jle    801017f1 <iinit+0x32>
  }

  readsb(dev, &sb);
80101824:	83 ec 08             	sub    $0x8,%esp
80101827:	68 60 3a 11 80       	push   $0x80113a60
8010182c:	ff 75 08             	pushl  0x8(%ebp)
8010182f:	e8 d4 fc ff ff       	call   80101508 <readsb>
80101834:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101837:	a1 78 3a 11 80       	mov    0x80113a78,%eax
8010183c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
8010183f:	8b 3d 74 3a 11 80    	mov    0x80113a74,%edi
80101845:	8b 35 70 3a 11 80    	mov    0x80113a70,%esi
8010184b:	8b 1d 6c 3a 11 80    	mov    0x80113a6c,%ebx
80101851:	8b 0d 68 3a 11 80    	mov    0x80113a68,%ecx
80101857:	8b 15 64 3a 11 80    	mov    0x80113a64,%edx
8010185d:	a1 60 3a 11 80       	mov    0x80113a60,%eax
80101862:	ff 75 d4             	pushl  -0x2c(%ebp)
80101865:	57                   	push   %edi
80101866:	56                   	push   %esi
80101867:	53                   	push   %ebx
80101868:	51                   	push   %ecx
80101869:	52                   	push   %edx
8010186a:	50                   	push   %eax
8010186b:	68 9c 96 10 80       	push   $0x8010969c
80101870:	e8 a3 eb ff ff       	call   80100418 <cprintf>
80101875:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101878:	90                   	nop
80101879:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010187c:	5b                   	pop    %ebx
8010187d:	5e                   	pop    %esi
8010187e:	5f                   	pop    %edi
8010187f:	5d                   	pop    %ebp
80101880:	c3                   	ret    

80101881 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101881:	f3 0f 1e fb          	endbr32 
80101885:	55                   	push   %ebp
80101886:	89 e5                	mov    %esp,%ebp
80101888:	83 ec 28             	sub    $0x28,%esp
8010188b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010188e:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101892:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101899:	e9 9e 00 00 00       	jmp    8010193c <ialloc+0xbb>
    bp = bread(dev, IBLOCK(inum, sb));
8010189e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a1:	c1 e8 03             	shr    $0x3,%eax
801018a4:	89 c2                	mov    %eax,%edx
801018a6:	a1 74 3a 11 80       	mov    0x80113a74,%eax
801018ab:	01 d0                	add    %edx,%eax
801018ad:	83 ec 08             	sub    $0x8,%esp
801018b0:	50                   	push   %eax
801018b1:	ff 75 08             	pushl  0x8(%ebp)
801018b4:	e8 1e e9 ff ff       	call   801001d7 <bread>
801018b9:	83 c4 10             	add    $0x10,%esp
801018bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801018bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018c2:	8d 50 5c             	lea    0x5c(%eax),%edx
801018c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c8:	83 e0 07             	and    $0x7,%eax
801018cb:	c1 e0 06             	shl    $0x6,%eax
801018ce:	01 d0                	add    %edx,%eax
801018d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801018d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018d6:	0f b7 00             	movzwl (%eax),%eax
801018d9:	66 85 c0             	test   %ax,%ax
801018dc:	75 4c                	jne    8010192a <ialloc+0xa9>
      memset(dip, 0, sizeof(*dip));
801018de:	83 ec 04             	sub    $0x4,%esp
801018e1:	6a 40                	push   $0x40
801018e3:	6a 00                	push   $0x0
801018e5:	ff 75 ec             	pushl  -0x14(%ebp)
801018e8:	e8 97 3c 00 00       	call   80105584 <memset>
801018ed:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801018f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018f3:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801018f7:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801018fa:	83 ec 0c             	sub    $0xc,%esp
801018fd:	ff 75 f0             	pushl  -0x10(%ebp)
80101900:	e8 7e 20 00 00       	call   80103983 <log_write>
80101905:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
80101908:	83 ec 0c             	sub    $0xc,%esp
8010190b:	ff 75 f0             	pushl  -0x10(%ebp)
8010190e:	e8 4e e9 ff ff       	call   80100261 <brelse>
80101913:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
80101916:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101919:	83 ec 08             	sub    $0x8,%esp
8010191c:	50                   	push   %eax
8010191d:	ff 75 08             	pushl  0x8(%ebp)
80101920:	e8 fc 00 00 00       	call   80101a21 <iget>
80101925:	83 c4 10             	add    $0x10,%esp
80101928:	eb 30                	jmp    8010195a <ialloc+0xd9>
    }
    brelse(bp);
8010192a:	83 ec 0c             	sub    $0xc,%esp
8010192d:	ff 75 f0             	pushl  -0x10(%ebp)
80101930:	e8 2c e9 ff ff       	call   80100261 <brelse>
80101935:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
80101938:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010193c:	8b 15 68 3a 11 80    	mov    0x80113a68,%edx
80101942:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101945:	39 c2                	cmp    %eax,%edx
80101947:	0f 87 51 ff ff ff    	ja     8010189e <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
8010194d:	83 ec 0c             	sub    $0xc,%esp
80101950:	68 ef 96 10 80       	push   $0x801096ef
80101955:	e8 ae ec ff ff       	call   80100608 <panic>
}
8010195a:	c9                   	leave  
8010195b:	c3                   	ret    

8010195c <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
8010195c:	f3 0f 1e fb          	endbr32 
80101960:	55                   	push   %ebp
80101961:	89 e5                	mov    %esp,%ebp
80101963:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101966:	8b 45 08             	mov    0x8(%ebp),%eax
80101969:	8b 40 04             	mov    0x4(%eax),%eax
8010196c:	c1 e8 03             	shr    $0x3,%eax
8010196f:	89 c2                	mov    %eax,%edx
80101971:	a1 74 3a 11 80       	mov    0x80113a74,%eax
80101976:	01 c2                	add    %eax,%edx
80101978:	8b 45 08             	mov    0x8(%ebp),%eax
8010197b:	8b 00                	mov    (%eax),%eax
8010197d:	83 ec 08             	sub    $0x8,%esp
80101980:	52                   	push   %edx
80101981:	50                   	push   %eax
80101982:	e8 50 e8 ff ff       	call   801001d7 <bread>
80101987:	83 c4 10             	add    $0x10,%esp
8010198a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010198d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101990:	8d 50 5c             	lea    0x5c(%eax),%edx
80101993:	8b 45 08             	mov    0x8(%ebp),%eax
80101996:	8b 40 04             	mov    0x4(%eax),%eax
80101999:	83 e0 07             	and    $0x7,%eax
8010199c:	c1 e0 06             	shl    $0x6,%eax
8010199f:	01 d0                	add    %edx,%eax
801019a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801019a4:	8b 45 08             	mov    0x8(%ebp),%eax
801019a7:	0f b7 50 50          	movzwl 0x50(%eax),%edx
801019ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019ae:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801019b1:	8b 45 08             	mov    0x8(%ebp),%eax
801019b4:	0f b7 50 52          	movzwl 0x52(%eax),%edx
801019b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019bb:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801019bf:	8b 45 08             	mov    0x8(%ebp),%eax
801019c2:	0f b7 50 54          	movzwl 0x54(%eax),%edx
801019c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019c9:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801019cd:	8b 45 08             	mov    0x8(%ebp),%eax
801019d0:	0f b7 50 56          	movzwl 0x56(%eax),%edx
801019d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019d7:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801019db:	8b 45 08             	mov    0x8(%ebp),%eax
801019de:	8b 50 58             	mov    0x58(%eax),%edx
801019e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019e4:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801019e7:	8b 45 08             	mov    0x8(%ebp),%eax
801019ea:	8d 50 5c             	lea    0x5c(%eax),%edx
801019ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019f0:	83 c0 0c             	add    $0xc,%eax
801019f3:	83 ec 04             	sub    $0x4,%esp
801019f6:	6a 34                	push   $0x34
801019f8:	52                   	push   %edx
801019f9:	50                   	push   %eax
801019fa:	e8 4c 3c 00 00       	call   8010564b <memmove>
801019ff:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101a02:	83 ec 0c             	sub    $0xc,%esp
80101a05:	ff 75 f4             	pushl  -0xc(%ebp)
80101a08:	e8 76 1f 00 00       	call   80103983 <log_write>
80101a0d:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101a10:	83 ec 0c             	sub    $0xc,%esp
80101a13:	ff 75 f4             	pushl  -0xc(%ebp)
80101a16:	e8 46 e8 ff ff       	call   80100261 <brelse>
80101a1b:	83 c4 10             	add    $0x10,%esp
}
80101a1e:	90                   	nop
80101a1f:	c9                   	leave  
80101a20:	c3                   	ret    

80101a21 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101a21:	f3 0f 1e fb          	endbr32 
80101a25:	55                   	push   %ebp
80101a26:	89 e5                	mov    %esp,%ebp
80101a28:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101a2b:	83 ec 0c             	sub    $0xc,%esp
80101a2e:	68 80 3a 11 80       	push   $0x80113a80
80101a33:	e8 ad 38 00 00       	call   801052e5 <acquire>
80101a38:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101a3b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a42:	c7 45 f4 b4 3a 11 80 	movl   $0x80113ab4,-0xc(%ebp)
80101a49:	eb 60                	jmp    80101aab <iget+0x8a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a4e:	8b 40 08             	mov    0x8(%eax),%eax
80101a51:	85 c0                	test   %eax,%eax
80101a53:	7e 39                	jle    80101a8e <iget+0x6d>
80101a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a58:	8b 00                	mov    (%eax),%eax
80101a5a:	39 45 08             	cmp    %eax,0x8(%ebp)
80101a5d:	75 2f                	jne    80101a8e <iget+0x6d>
80101a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a62:	8b 40 04             	mov    0x4(%eax),%eax
80101a65:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101a68:	75 24                	jne    80101a8e <iget+0x6d>
      ip->ref++;
80101a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a6d:	8b 40 08             	mov    0x8(%eax),%eax
80101a70:	8d 50 01             	lea    0x1(%eax),%edx
80101a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a76:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101a79:	83 ec 0c             	sub    $0xc,%esp
80101a7c:	68 80 3a 11 80       	push   $0x80113a80
80101a81:	e8 d1 38 00 00       	call   80105357 <release>
80101a86:	83 c4 10             	add    $0x10,%esp
      return ip;
80101a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a8c:	eb 77                	jmp    80101b05 <iget+0xe4>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101a8e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a92:	75 10                	jne    80101aa4 <iget+0x83>
80101a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a97:	8b 40 08             	mov    0x8(%eax),%eax
80101a9a:	85 c0                	test   %eax,%eax
80101a9c:	75 06                	jne    80101aa4 <iget+0x83>
      empty = ip;
80101a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aa1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101aa4:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101aab:	81 7d f4 d4 56 11 80 	cmpl   $0x801156d4,-0xc(%ebp)
80101ab2:	72 97                	jb     80101a4b <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101ab4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101ab8:	75 0d                	jne    80101ac7 <iget+0xa6>
    panic("iget: no inodes");
80101aba:	83 ec 0c             	sub    $0xc,%esp
80101abd:	68 01 97 10 80       	push   $0x80109701
80101ac2:	e8 41 eb ff ff       	call   80100608 <panic>

  ip = empty;
80101ac7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ad0:	8b 55 08             	mov    0x8(%ebp),%edx
80101ad3:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ad8:	8b 55 0c             	mov    0xc(%ebp),%edx
80101adb:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ae1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aeb:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101af2:	83 ec 0c             	sub    $0xc,%esp
80101af5:	68 80 3a 11 80       	push   $0x80113a80
80101afa:	e8 58 38 00 00       	call   80105357 <release>
80101aff:	83 c4 10             	add    $0x10,%esp

  return ip;
80101b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101b05:	c9                   	leave  
80101b06:	c3                   	ret    

80101b07 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101b07:	f3 0f 1e fb          	endbr32 
80101b0b:	55                   	push   %ebp
80101b0c:	89 e5                	mov    %esp,%ebp
80101b0e:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101b11:	83 ec 0c             	sub    $0xc,%esp
80101b14:	68 80 3a 11 80       	push   $0x80113a80
80101b19:	e8 c7 37 00 00       	call   801052e5 <acquire>
80101b1e:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101b21:	8b 45 08             	mov    0x8(%ebp),%eax
80101b24:	8b 40 08             	mov    0x8(%eax),%eax
80101b27:	8d 50 01             	lea    0x1(%eax),%edx
80101b2a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2d:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b30:	83 ec 0c             	sub    $0xc,%esp
80101b33:	68 80 3a 11 80       	push   $0x80113a80
80101b38:	e8 1a 38 00 00       	call   80105357 <release>
80101b3d:	83 c4 10             	add    $0x10,%esp
  return ip;
80101b40:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101b43:	c9                   	leave  
80101b44:	c3                   	ret    

80101b45 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101b45:	f3 0f 1e fb          	endbr32 
80101b49:	55                   	push   %ebp
80101b4a:	89 e5                	mov    %esp,%ebp
80101b4c:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101b4f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b53:	74 0a                	je     80101b5f <ilock+0x1a>
80101b55:	8b 45 08             	mov    0x8(%ebp),%eax
80101b58:	8b 40 08             	mov    0x8(%eax),%eax
80101b5b:	85 c0                	test   %eax,%eax
80101b5d:	7f 0d                	jg     80101b6c <ilock+0x27>
    panic("ilock");
80101b5f:	83 ec 0c             	sub    $0xc,%esp
80101b62:	68 11 97 10 80       	push   $0x80109711
80101b67:	e8 9c ea ff ff       	call   80100608 <panic>

  acquiresleep(&ip->lock);
80101b6c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6f:	83 c0 0c             	add    $0xc,%eax
80101b72:	83 ec 0c             	sub    $0xc,%esp
80101b75:	50                   	push   %eax
80101b76:	e8 f1 35 00 00       	call   8010516c <acquiresleep>
80101b7b:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101b7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b81:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b84:	85 c0                	test   %eax,%eax
80101b86:	0f 85 cd 00 00 00    	jne    80101c59 <ilock+0x114>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101b8c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8f:	8b 40 04             	mov    0x4(%eax),%eax
80101b92:	c1 e8 03             	shr    $0x3,%eax
80101b95:	89 c2                	mov    %eax,%edx
80101b97:	a1 74 3a 11 80       	mov    0x80113a74,%eax
80101b9c:	01 c2                	add    %eax,%edx
80101b9e:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba1:	8b 00                	mov    (%eax),%eax
80101ba3:	83 ec 08             	sub    $0x8,%esp
80101ba6:	52                   	push   %edx
80101ba7:	50                   	push   %eax
80101ba8:	e8 2a e6 ff ff       	call   801001d7 <bread>
80101bad:	83 c4 10             	add    $0x10,%esp
80101bb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bb6:	8d 50 5c             	lea    0x5c(%eax),%edx
80101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbc:	8b 40 04             	mov    0x4(%eax),%eax
80101bbf:	83 e0 07             	and    $0x7,%eax
80101bc2:	c1 e0 06             	shl    $0x6,%eax
80101bc5:	01 d0                	add    %edx,%eax
80101bc7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101bca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bcd:	0f b7 10             	movzwl (%eax),%edx
80101bd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd3:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101bd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bda:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101bde:	8b 45 08             	mov    0x8(%ebp),%eax
80101be1:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101be5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101be8:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101bec:	8b 45 08             	mov    0x8(%ebp),%eax
80101bef:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101bf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bf6:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101bfa:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfd:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101c01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c04:	8b 50 08             	mov    0x8(%eax),%edx
80101c07:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0a:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101c0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c10:	8d 50 0c             	lea    0xc(%eax),%edx
80101c13:	8b 45 08             	mov    0x8(%ebp),%eax
80101c16:	83 c0 5c             	add    $0x5c,%eax
80101c19:	83 ec 04             	sub    $0x4,%esp
80101c1c:	6a 34                	push   $0x34
80101c1e:	52                   	push   %edx
80101c1f:	50                   	push   %eax
80101c20:	e8 26 3a 00 00       	call   8010564b <memmove>
80101c25:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101c28:	83 ec 0c             	sub    $0xc,%esp
80101c2b:	ff 75 f4             	pushl  -0xc(%ebp)
80101c2e:	e8 2e e6 ff ff       	call   80100261 <brelse>
80101c33:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101c36:	8b 45 08             	mov    0x8(%ebp),%eax
80101c39:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101c40:	8b 45 08             	mov    0x8(%ebp),%eax
80101c43:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101c47:	66 85 c0             	test   %ax,%ax
80101c4a:	75 0d                	jne    80101c59 <ilock+0x114>
      panic("ilock: no type");
80101c4c:	83 ec 0c             	sub    $0xc,%esp
80101c4f:	68 17 97 10 80       	push   $0x80109717
80101c54:	e8 af e9 ff ff       	call   80100608 <panic>
  }
}
80101c59:	90                   	nop
80101c5a:	c9                   	leave  
80101c5b:	c3                   	ret    

80101c5c <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101c5c:	f3 0f 1e fb          	endbr32 
80101c60:	55                   	push   %ebp
80101c61:	89 e5                	mov    %esp,%ebp
80101c63:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101c66:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101c6a:	74 20                	je     80101c8c <iunlock+0x30>
80101c6c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6f:	83 c0 0c             	add    $0xc,%eax
80101c72:	83 ec 0c             	sub    $0xc,%esp
80101c75:	50                   	push   %eax
80101c76:	e8 ab 35 00 00       	call   80105226 <holdingsleep>
80101c7b:	83 c4 10             	add    $0x10,%esp
80101c7e:	85 c0                	test   %eax,%eax
80101c80:	74 0a                	je     80101c8c <iunlock+0x30>
80101c82:	8b 45 08             	mov    0x8(%ebp),%eax
80101c85:	8b 40 08             	mov    0x8(%eax),%eax
80101c88:	85 c0                	test   %eax,%eax
80101c8a:	7f 0d                	jg     80101c99 <iunlock+0x3d>
    panic("iunlock");
80101c8c:	83 ec 0c             	sub    $0xc,%esp
80101c8f:	68 26 97 10 80       	push   $0x80109726
80101c94:	e8 6f e9 ff ff       	call   80100608 <panic>

  releasesleep(&ip->lock);
80101c99:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9c:	83 c0 0c             	add    $0xc,%eax
80101c9f:	83 ec 0c             	sub    $0xc,%esp
80101ca2:	50                   	push   %eax
80101ca3:	e8 2c 35 00 00       	call   801051d4 <releasesleep>
80101ca8:	83 c4 10             	add    $0x10,%esp
}
80101cab:	90                   	nop
80101cac:	c9                   	leave  
80101cad:	c3                   	ret    

80101cae <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101cae:	f3 0f 1e fb          	endbr32 
80101cb2:	55                   	push   %ebp
80101cb3:	89 e5                	mov    %esp,%ebp
80101cb5:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101cb8:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbb:	83 c0 0c             	add    $0xc,%eax
80101cbe:	83 ec 0c             	sub    $0xc,%esp
80101cc1:	50                   	push   %eax
80101cc2:	e8 a5 34 00 00       	call   8010516c <acquiresleep>
80101cc7:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101cca:	8b 45 08             	mov    0x8(%ebp),%eax
80101ccd:	8b 40 4c             	mov    0x4c(%eax),%eax
80101cd0:	85 c0                	test   %eax,%eax
80101cd2:	74 6a                	je     80101d3e <iput+0x90>
80101cd4:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd7:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101cdb:	66 85 c0             	test   %ax,%ax
80101cde:	75 5e                	jne    80101d3e <iput+0x90>
    acquire(&icache.lock);
80101ce0:	83 ec 0c             	sub    $0xc,%esp
80101ce3:	68 80 3a 11 80       	push   $0x80113a80
80101ce8:	e8 f8 35 00 00       	call   801052e5 <acquire>
80101ced:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101cf0:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf3:	8b 40 08             	mov    0x8(%eax),%eax
80101cf6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101cf9:	83 ec 0c             	sub    $0xc,%esp
80101cfc:	68 80 3a 11 80       	push   $0x80113a80
80101d01:	e8 51 36 00 00       	call   80105357 <release>
80101d06:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101d09:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101d0d:	75 2f                	jne    80101d3e <iput+0x90>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101d0f:	83 ec 0c             	sub    $0xc,%esp
80101d12:	ff 75 08             	pushl  0x8(%ebp)
80101d15:	e8 b5 01 00 00       	call   80101ecf <itrunc>
80101d1a:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101d1d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d20:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101d26:	83 ec 0c             	sub    $0xc,%esp
80101d29:	ff 75 08             	pushl  0x8(%ebp)
80101d2c:	e8 2b fc ff ff       	call   8010195c <iupdate>
80101d31:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101d34:	8b 45 08             	mov    0x8(%ebp),%eax
80101d37:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101d3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d41:	83 c0 0c             	add    $0xc,%eax
80101d44:	83 ec 0c             	sub    $0xc,%esp
80101d47:	50                   	push   %eax
80101d48:	e8 87 34 00 00       	call   801051d4 <releasesleep>
80101d4d:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101d50:	83 ec 0c             	sub    $0xc,%esp
80101d53:	68 80 3a 11 80       	push   $0x80113a80
80101d58:	e8 88 35 00 00       	call   801052e5 <acquire>
80101d5d:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101d60:	8b 45 08             	mov    0x8(%ebp),%eax
80101d63:	8b 40 08             	mov    0x8(%eax),%eax
80101d66:	8d 50 ff             	lea    -0x1(%eax),%edx
80101d69:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6c:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101d6f:	83 ec 0c             	sub    $0xc,%esp
80101d72:	68 80 3a 11 80       	push   $0x80113a80
80101d77:	e8 db 35 00 00       	call   80105357 <release>
80101d7c:	83 c4 10             	add    $0x10,%esp
}
80101d7f:	90                   	nop
80101d80:	c9                   	leave  
80101d81:	c3                   	ret    

80101d82 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101d82:	f3 0f 1e fb          	endbr32 
80101d86:	55                   	push   %ebp
80101d87:	89 e5                	mov    %esp,%ebp
80101d89:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101d8c:	83 ec 0c             	sub    $0xc,%esp
80101d8f:	ff 75 08             	pushl  0x8(%ebp)
80101d92:	e8 c5 fe ff ff       	call   80101c5c <iunlock>
80101d97:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101d9a:	83 ec 0c             	sub    $0xc,%esp
80101d9d:	ff 75 08             	pushl  0x8(%ebp)
80101da0:	e8 09 ff ff ff       	call   80101cae <iput>
80101da5:	83 c4 10             	add    $0x10,%esp
}
80101da8:	90                   	nop
80101da9:	c9                   	leave  
80101daa:	c3                   	ret    

80101dab <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101dab:	f3 0f 1e fb          	endbr32 
80101daf:	55                   	push   %ebp
80101db0:	89 e5                	mov    %esp,%ebp
80101db2:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101db5:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101db9:	77 42                	ja     80101dfd <bmap+0x52>
    if((addr = ip->addrs[bn]) == 0)
80101dbb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dbe:	8b 55 0c             	mov    0xc(%ebp),%edx
80101dc1:	83 c2 14             	add    $0x14,%edx
80101dc4:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101dc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dcb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101dcf:	75 24                	jne    80101df5 <bmap+0x4a>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101dd1:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd4:	8b 00                	mov    (%eax),%eax
80101dd6:	83 ec 0c             	sub    $0xc,%esp
80101dd9:	50                   	push   %eax
80101dda:	e8 c7 f7 ff ff       	call   801015a6 <balloc>
80101ddf:	83 c4 10             	add    $0x10,%esp
80101de2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101de5:	8b 45 08             	mov    0x8(%ebp),%eax
80101de8:	8b 55 0c             	mov    0xc(%ebp),%edx
80101deb:	8d 4a 14             	lea    0x14(%edx),%ecx
80101dee:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101df1:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101df5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101df8:	e9 d0 00 00 00       	jmp    80101ecd <bmap+0x122>
  }
  bn -= NDIRECT;
80101dfd:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101e01:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101e05:	0f 87 b5 00 00 00    	ja     80101ec0 <bmap+0x115>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101e0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0e:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e14:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e17:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e1b:	75 20                	jne    80101e3d <bmap+0x92>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101e1d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e20:	8b 00                	mov    (%eax),%eax
80101e22:	83 ec 0c             	sub    $0xc,%esp
80101e25:	50                   	push   %eax
80101e26:	e8 7b f7 ff ff       	call   801015a6 <balloc>
80101e2b:	83 c4 10             	add    $0x10,%esp
80101e2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e31:	8b 45 08             	mov    0x8(%ebp),%eax
80101e34:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e37:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101e3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e40:	8b 00                	mov    (%eax),%eax
80101e42:	83 ec 08             	sub    $0x8,%esp
80101e45:	ff 75 f4             	pushl  -0xc(%ebp)
80101e48:	50                   	push   %eax
80101e49:	e8 89 e3 ff ff       	call   801001d7 <bread>
80101e4e:	83 c4 10             	add    $0x10,%esp
80101e51:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101e54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e57:	83 c0 5c             	add    $0x5c,%eax
80101e5a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101e5d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e60:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e67:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e6a:	01 d0                	add    %edx,%eax
80101e6c:	8b 00                	mov    (%eax),%eax
80101e6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e71:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e75:	75 36                	jne    80101ead <bmap+0x102>
      a[bn] = addr = balloc(ip->dev);
80101e77:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7a:	8b 00                	mov    (%eax),%eax
80101e7c:	83 ec 0c             	sub    $0xc,%esp
80101e7f:	50                   	push   %eax
80101e80:	e8 21 f7 ff ff       	call   801015a6 <balloc>
80101e85:	83 c4 10             	add    $0x10,%esp
80101e88:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e8e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e95:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e98:	01 c2                	add    %eax,%edx
80101e9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e9d:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101e9f:	83 ec 0c             	sub    $0xc,%esp
80101ea2:	ff 75 f0             	pushl  -0x10(%ebp)
80101ea5:	e8 d9 1a 00 00       	call   80103983 <log_write>
80101eaa:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101ead:	83 ec 0c             	sub    $0xc,%esp
80101eb0:	ff 75 f0             	pushl  -0x10(%ebp)
80101eb3:	e8 a9 e3 ff ff       	call   80100261 <brelse>
80101eb8:	83 c4 10             	add    $0x10,%esp
    return addr;
80101ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ebe:	eb 0d                	jmp    80101ecd <bmap+0x122>
  }

  panic("bmap: out of range");
80101ec0:	83 ec 0c             	sub    $0xc,%esp
80101ec3:	68 2e 97 10 80       	push   $0x8010972e
80101ec8:	e8 3b e7 ff ff       	call   80100608 <panic>
}
80101ecd:	c9                   	leave  
80101ece:	c3                   	ret    

80101ecf <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101ecf:	f3 0f 1e fb          	endbr32 
80101ed3:	55                   	push   %ebp
80101ed4:	89 e5                	mov    %esp,%ebp
80101ed6:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101ed9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101ee0:	eb 45                	jmp    80101f27 <itrunc+0x58>
    if(ip->addrs[i]){
80101ee2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ee8:	83 c2 14             	add    $0x14,%edx
80101eeb:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101eef:	85 c0                	test   %eax,%eax
80101ef1:	74 30                	je     80101f23 <itrunc+0x54>
      bfree(ip->dev, ip->addrs[i]);
80101ef3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ef9:	83 c2 14             	add    $0x14,%edx
80101efc:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101f00:	8b 55 08             	mov    0x8(%ebp),%edx
80101f03:	8b 12                	mov    (%edx),%edx
80101f05:	83 ec 08             	sub    $0x8,%esp
80101f08:	50                   	push   %eax
80101f09:	52                   	push   %edx
80101f0a:	e8 e7 f7 ff ff       	call   801016f6 <bfree>
80101f0f:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101f12:	8b 45 08             	mov    0x8(%ebp),%eax
80101f15:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f18:	83 c2 14             	add    $0x14,%edx
80101f1b:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101f22:	00 
  for(i = 0; i < NDIRECT; i++){
80101f23:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101f27:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101f2b:	7e b5                	jle    80101ee2 <itrunc+0x13>
    }
  }

  if(ip->addrs[NDIRECT]){
80101f2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f30:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101f36:	85 c0                	test   %eax,%eax
80101f38:	0f 84 aa 00 00 00    	je     80101fe8 <itrunc+0x119>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101f3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f41:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101f47:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4a:	8b 00                	mov    (%eax),%eax
80101f4c:	83 ec 08             	sub    $0x8,%esp
80101f4f:	52                   	push   %edx
80101f50:	50                   	push   %eax
80101f51:	e8 81 e2 ff ff       	call   801001d7 <bread>
80101f56:	83 c4 10             	add    $0x10,%esp
80101f59:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101f5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f5f:	83 c0 5c             	add    $0x5c,%eax
80101f62:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101f65:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101f6c:	eb 3c                	jmp    80101faa <itrunc+0xdb>
      if(a[j])
80101f6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f71:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f78:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f7b:	01 d0                	add    %edx,%eax
80101f7d:	8b 00                	mov    (%eax),%eax
80101f7f:	85 c0                	test   %eax,%eax
80101f81:	74 23                	je     80101fa6 <itrunc+0xd7>
        bfree(ip->dev, a[j]);
80101f83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f86:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f8d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f90:	01 d0                	add    %edx,%eax
80101f92:	8b 00                	mov    (%eax),%eax
80101f94:	8b 55 08             	mov    0x8(%ebp),%edx
80101f97:	8b 12                	mov    (%edx),%edx
80101f99:	83 ec 08             	sub    $0x8,%esp
80101f9c:	50                   	push   %eax
80101f9d:	52                   	push   %edx
80101f9e:	e8 53 f7 ff ff       	call   801016f6 <bfree>
80101fa3:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101fa6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101faa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fad:	83 f8 7f             	cmp    $0x7f,%eax
80101fb0:	76 bc                	jbe    80101f6e <itrunc+0x9f>
    }
    brelse(bp);
80101fb2:	83 ec 0c             	sub    $0xc,%esp
80101fb5:	ff 75 ec             	pushl  -0x14(%ebp)
80101fb8:	e8 a4 e2 ff ff       	call   80100261 <brelse>
80101fbd:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101fc0:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc3:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101fc9:	8b 55 08             	mov    0x8(%ebp),%edx
80101fcc:	8b 12                	mov    (%edx),%edx
80101fce:	83 ec 08             	sub    $0x8,%esp
80101fd1:	50                   	push   %eax
80101fd2:	52                   	push   %edx
80101fd3:	e8 1e f7 ff ff       	call   801016f6 <bfree>
80101fd8:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101fdb:	8b 45 08             	mov    0x8(%ebp),%eax
80101fde:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101fe5:	00 00 00 
  }

  ip->size = 0;
80101fe8:	8b 45 08             	mov    0x8(%ebp),%eax
80101feb:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101ff2:	83 ec 0c             	sub    $0xc,%esp
80101ff5:	ff 75 08             	pushl  0x8(%ebp)
80101ff8:	e8 5f f9 ff ff       	call   8010195c <iupdate>
80101ffd:	83 c4 10             	add    $0x10,%esp
}
80102000:	90                   	nop
80102001:	c9                   	leave  
80102002:	c3                   	ret    

80102003 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80102003:	f3 0f 1e fb          	endbr32 
80102007:	55                   	push   %ebp
80102008:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
8010200a:	8b 45 08             	mov    0x8(%ebp),%eax
8010200d:	8b 00                	mov    (%eax),%eax
8010200f:	89 c2                	mov    %eax,%edx
80102011:	8b 45 0c             	mov    0xc(%ebp),%eax
80102014:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80102017:	8b 45 08             	mov    0x8(%ebp),%eax
8010201a:	8b 50 04             	mov    0x4(%eax),%edx
8010201d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102020:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80102023:	8b 45 08             	mov    0x8(%ebp),%eax
80102026:	0f b7 50 50          	movzwl 0x50(%eax),%edx
8010202a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010202d:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80102030:	8b 45 08             	mov    0x8(%ebp),%eax
80102033:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80102037:	8b 45 0c             	mov    0xc(%ebp),%eax
8010203a:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
8010203e:	8b 45 08             	mov    0x8(%ebp),%eax
80102041:	8b 50 58             	mov    0x58(%eax),%edx
80102044:	8b 45 0c             	mov    0xc(%ebp),%eax
80102047:	89 50 10             	mov    %edx,0x10(%eax)
}
8010204a:	90                   	nop
8010204b:	5d                   	pop    %ebp
8010204c:	c3                   	ret    

8010204d <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
8010204d:	f3 0f 1e fb          	endbr32 
80102051:	55                   	push   %ebp
80102052:	89 e5                	mov    %esp,%ebp
80102054:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102057:	8b 45 08             	mov    0x8(%ebp),%eax
8010205a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010205e:	66 83 f8 03          	cmp    $0x3,%ax
80102062:	75 5c                	jne    801020c0 <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80102064:	8b 45 08             	mov    0x8(%ebp),%eax
80102067:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010206b:	66 85 c0             	test   %ax,%ax
8010206e:	78 20                	js     80102090 <readi+0x43>
80102070:	8b 45 08             	mov    0x8(%ebp),%eax
80102073:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102077:	66 83 f8 09          	cmp    $0x9,%ax
8010207b:	7f 13                	jg     80102090 <readi+0x43>
8010207d:	8b 45 08             	mov    0x8(%ebp),%eax
80102080:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102084:	98                   	cwtl   
80102085:	8b 04 c5 00 3a 11 80 	mov    -0x7feec600(,%eax,8),%eax
8010208c:	85 c0                	test   %eax,%eax
8010208e:	75 0a                	jne    8010209a <readi+0x4d>
      return -1;
80102090:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102095:	e9 0a 01 00 00       	jmp    801021a4 <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
8010209a:	8b 45 08             	mov    0x8(%ebp),%eax
8010209d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020a1:	98                   	cwtl   
801020a2:	8b 04 c5 00 3a 11 80 	mov    -0x7feec600(,%eax,8),%eax
801020a9:	8b 55 14             	mov    0x14(%ebp),%edx
801020ac:	83 ec 04             	sub    $0x4,%esp
801020af:	52                   	push   %edx
801020b0:	ff 75 0c             	pushl  0xc(%ebp)
801020b3:	ff 75 08             	pushl  0x8(%ebp)
801020b6:	ff d0                	call   *%eax
801020b8:	83 c4 10             	add    $0x10,%esp
801020bb:	e9 e4 00 00 00       	jmp    801021a4 <readi+0x157>
  }

  if(off > ip->size || off + n < off)
801020c0:	8b 45 08             	mov    0x8(%ebp),%eax
801020c3:	8b 40 58             	mov    0x58(%eax),%eax
801020c6:	39 45 10             	cmp    %eax,0x10(%ebp)
801020c9:	77 0d                	ja     801020d8 <readi+0x8b>
801020cb:	8b 55 10             	mov    0x10(%ebp),%edx
801020ce:	8b 45 14             	mov    0x14(%ebp),%eax
801020d1:	01 d0                	add    %edx,%eax
801020d3:	39 45 10             	cmp    %eax,0x10(%ebp)
801020d6:	76 0a                	jbe    801020e2 <readi+0x95>
    return -1;
801020d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020dd:	e9 c2 00 00 00       	jmp    801021a4 <readi+0x157>
  if(off + n > ip->size)
801020e2:	8b 55 10             	mov    0x10(%ebp),%edx
801020e5:	8b 45 14             	mov    0x14(%ebp),%eax
801020e8:	01 c2                	add    %eax,%edx
801020ea:	8b 45 08             	mov    0x8(%ebp),%eax
801020ed:	8b 40 58             	mov    0x58(%eax),%eax
801020f0:	39 c2                	cmp    %eax,%edx
801020f2:	76 0c                	jbe    80102100 <readi+0xb3>
    n = ip->size - off;
801020f4:	8b 45 08             	mov    0x8(%ebp),%eax
801020f7:	8b 40 58             	mov    0x58(%eax),%eax
801020fa:	2b 45 10             	sub    0x10(%ebp),%eax
801020fd:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102100:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102107:	e9 89 00 00 00       	jmp    80102195 <readi+0x148>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010210c:	8b 45 10             	mov    0x10(%ebp),%eax
8010210f:	c1 e8 09             	shr    $0x9,%eax
80102112:	83 ec 08             	sub    $0x8,%esp
80102115:	50                   	push   %eax
80102116:	ff 75 08             	pushl  0x8(%ebp)
80102119:	e8 8d fc ff ff       	call   80101dab <bmap>
8010211e:	83 c4 10             	add    $0x10,%esp
80102121:	8b 55 08             	mov    0x8(%ebp),%edx
80102124:	8b 12                	mov    (%edx),%edx
80102126:	83 ec 08             	sub    $0x8,%esp
80102129:	50                   	push   %eax
8010212a:	52                   	push   %edx
8010212b:	e8 a7 e0 ff ff       	call   801001d7 <bread>
80102130:	83 c4 10             	add    $0x10,%esp
80102133:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102136:	8b 45 10             	mov    0x10(%ebp),%eax
80102139:	25 ff 01 00 00       	and    $0x1ff,%eax
8010213e:	ba 00 02 00 00       	mov    $0x200,%edx
80102143:	29 c2                	sub    %eax,%edx
80102145:	8b 45 14             	mov    0x14(%ebp),%eax
80102148:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010214b:	39 c2                	cmp    %eax,%edx
8010214d:	0f 46 c2             	cmovbe %edx,%eax
80102150:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102153:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102156:	8d 50 5c             	lea    0x5c(%eax),%edx
80102159:	8b 45 10             	mov    0x10(%ebp),%eax
8010215c:	25 ff 01 00 00       	and    $0x1ff,%eax
80102161:	01 d0                	add    %edx,%eax
80102163:	83 ec 04             	sub    $0x4,%esp
80102166:	ff 75 ec             	pushl  -0x14(%ebp)
80102169:	50                   	push   %eax
8010216a:	ff 75 0c             	pushl  0xc(%ebp)
8010216d:	e8 d9 34 00 00       	call   8010564b <memmove>
80102172:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102175:	83 ec 0c             	sub    $0xc,%esp
80102178:	ff 75 f0             	pushl  -0x10(%ebp)
8010217b:	e8 e1 e0 ff ff       	call   80100261 <brelse>
80102180:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102183:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102186:	01 45 f4             	add    %eax,-0xc(%ebp)
80102189:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010218c:	01 45 10             	add    %eax,0x10(%ebp)
8010218f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102192:	01 45 0c             	add    %eax,0xc(%ebp)
80102195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102198:	3b 45 14             	cmp    0x14(%ebp),%eax
8010219b:	0f 82 6b ff ff ff    	jb     8010210c <readi+0xbf>
  }
  return n;
801021a1:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021a4:	c9                   	leave  
801021a5:	c3                   	ret    

801021a6 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801021a6:	f3 0f 1e fb          	endbr32 
801021aa:	55                   	push   %ebp
801021ab:	89 e5                	mov    %esp,%ebp
801021ad:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801021b0:	8b 45 08             	mov    0x8(%ebp),%eax
801021b3:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021b7:	66 83 f8 03          	cmp    $0x3,%ax
801021bb:	75 5c                	jne    80102219 <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801021bd:	8b 45 08             	mov    0x8(%ebp),%eax
801021c0:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021c4:	66 85 c0             	test   %ax,%ax
801021c7:	78 20                	js     801021e9 <writei+0x43>
801021c9:	8b 45 08             	mov    0x8(%ebp),%eax
801021cc:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021d0:	66 83 f8 09          	cmp    $0x9,%ax
801021d4:	7f 13                	jg     801021e9 <writei+0x43>
801021d6:	8b 45 08             	mov    0x8(%ebp),%eax
801021d9:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021dd:	98                   	cwtl   
801021de:	8b 04 c5 04 3a 11 80 	mov    -0x7feec5fc(,%eax,8),%eax
801021e5:	85 c0                	test   %eax,%eax
801021e7:	75 0a                	jne    801021f3 <writei+0x4d>
      return -1;
801021e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021ee:	e9 3b 01 00 00       	jmp    8010232e <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
801021f3:	8b 45 08             	mov    0x8(%ebp),%eax
801021f6:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021fa:	98                   	cwtl   
801021fb:	8b 04 c5 04 3a 11 80 	mov    -0x7feec5fc(,%eax,8),%eax
80102202:	8b 55 14             	mov    0x14(%ebp),%edx
80102205:	83 ec 04             	sub    $0x4,%esp
80102208:	52                   	push   %edx
80102209:	ff 75 0c             	pushl  0xc(%ebp)
8010220c:	ff 75 08             	pushl  0x8(%ebp)
8010220f:	ff d0                	call   *%eax
80102211:	83 c4 10             	add    $0x10,%esp
80102214:	e9 15 01 00 00       	jmp    8010232e <writei+0x188>
  }

  if(off > ip->size || off + n < off)
80102219:	8b 45 08             	mov    0x8(%ebp),%eax
8010221c:	8b 40 58             	mov    0x58(%eax),%eax
8010221f:	39 45 10             	cmp    %eax,0x10(%ebp)
80102222:	77 0d                	ja     80102231 <writei+0x8b>
80102224:	8b 55 10             	mov    0x10(%ebp),%edx
80102227:	8b 45 14             	mov    0x14(%ebp),%eax
8010222a:	01 d0                	add    %edx,%eax
8010222c:	39 45 10             	cmp    %eax,0x10(%ebp)
8010222f:	76 0a                	jbe    8010223b <writei+0x95>
    return -1;
80102231:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102236:	e9 f3 00 00 00       	jmp    8010232e <writei+0x188>
  if(off + n > MAXFILE*BSIZE)
8010223b:	8b 55 10             	mov    0x10(%ebp),%edx
8010223e:	8b 45 14             	mov    0x14(%ebp),%eax
80102241:	01 d0                	add    %edx,%eax
80102243:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102248:	76 0a                	jbe    80102254 <writei+0xae>
    return -1;
8010224a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010224f:	e9 da 00 00 00       	jmp    8010232e <writei+0x188>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102254:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010225b:	e9 97 00 00 00       	jmp    801022f7 <writei+0x151>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102260:	8b 45 10             	mov    0x10(%ebp),%eax
80102263:	c1 e8 09             	shr    $0x9,%eax
80102266:	83 ec 08             	sub    $0x8,%esp
80102269:	50                   	push   %eax
8010226a:	ff 75 08             	pushl  0x8(%ebp)
8010226d:	e8 39 fb ff ff       	call   80101dab <bmap>
80102272:	83 c4 10             	add    $0x10,%esp
80102275:	8b 55 08             	mov    0x8(%ebp),%edx
80102278:	8b 12                	mov    (%edx),%edx
8010227a:	83 ec 08             	sub    $0x8,%esp
8010227d:	50                   	push   %eax
8010227e:	52                   	push   %edx
8010227f:	e8 53 df ff ff       	call   801001d7 <bread>
80102284:	83 c4 10             	add    $0x10,%esp
80102287:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010228a:	8b 45 10             	mov    0x10(%ebp),%eax
8010228d:	25 ff 01 00 00       	and    $0x1ff,%eax
80102292:	ba 00 02 00 00       	mov    $0x200,%edx
80102297:	29 c2                	sub    %eax,%edx
80102299:	8b 45 14             	mov    0x14(%ebp),%eax
8010229c:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010229f:	39 c2                	cmp    %eax,%edx
801022a1:	0f 46 c2             	cmovbe %edx,%eax
801022a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801022a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022aa:	8d 50 5c             	lea    0x5c(%eax),%edx
801022ad:	8b 45 10             	mov    0x10(%ebp),%eax
801022b0:	25 ff 01 00 00       	and    $0x1ff,%eax
801022b5:	01 d0                	add    %edx,%eax
801022b7:	83 ec 04             	sub    $0x4,%esp
801022ba:	ff 75 ec             	pushl  -0x14(%ebp)
801022bd:	ff 75 0c             	pushl  0xc(%ebp)
801022c0:	50                   	push   %eax
801022c1:	e8 85 33 00 00       	call   8010564b <memmove>
801022c6:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801022c9:	83 ec 0c             	sub    $0xc,%esp
801022cc:	ff 75 f0             	pushl  -0x10(%ebp)
801022cf:	e8 af 16 00 00       	call   80103983 <log_write>
801022d4:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801022d7:	83 ec 0c             	sub    $0xc,%esp
801022da:	ff 75 f0             	pushl  -0x10(%ebp)
801022dd:	e8 7f df ff ff       	call   80100261 <brelse>
801022e2:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801022e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022e8:	01 45 f4             	add    %eax,-0xc(%ebp)
801022eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022ee:	01 45 10             	add    %eax,0x10(%ebp)
801022f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022f4:	01 45 0c             	add    %eax,0xc(%ebp)
801022f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022fa:	3b 45 14             	cmp    0x14(%ebp),%eax
801022fd:	0f 82 5d ff ff ff    	jb     80102260 <writei+0xba>
  }

  if(n > 0 && off > ip->size){
80102303:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102307:	74 22                	je     8010232b <writei+0x185>
80102309:	8b 45 08             	mov    0x8(%ebp),%eax
8010230c:	8b 40 58             	mov    0x58(%eax),%eax
8010230f:	39 45 10             	cmp    %eax,0x10(%ebp)
80102312:	76 17                	jbe    8010232b <writei+0x185>
    ip->size = off;
80102314:	8b 45 08             	mov    0x8(%ebp),%eax
80102317:	8b 55 10             	mov    0x10(%ebp),%edx
8010231a:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
8010231d:	83 ec 0c             	sub    $0xc,%esp
80102320:	ff 75 08             	pushl  0x8(%ebp)
80102323:	e8 34 f6 ff ff       	call   8010195c <iupdate>
80102328:	83 c4 10             	add    $0x10,%esp
  }
  return n;
8010232b:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010232e:	c9                   	leave  
8010232f:	c3                   	ret    

80102330 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102330:	f3 0f 1e fb          	endbr32 
80102334:	55                   	push   %ebp
80102335:	89 e5                	mov    %esp,%ebp
80102337:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
8010233a:	83 ec 04             	sub    $0x4,%esp
8010233d:	6a 0e                	push   $0xe
8010233f:	ff 75 0c             	pushl  0xc(%ebp)
80102342:	ff 75 08             	pushl  0x8(%ebp)
80102345:	e8 9f 33 00 00       	call   801056e9 <strncmp>
8010234a:	83 c4 10             	add    $0x10,%esp
}
8010234d:	c9                   	leave  
8010234e:	c3                   	ret    

8010234f <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010234f:	f3 0f 1e fb          	endbr32 
80102353:	55                   	push   %ebp
80102354:	89 e5                	mov    %esp,%ebp
80102356:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102359:	8b 45 08             	mov    0x8(%ebp),%eax
8010235c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102360:	66 83 f8 01          	cmp    $0x1,%ax
80102364:	74 0d                	je     80102373 <dirlookup+0x24>
    panic("dirlookup not DIR");
80102366:	83 ec 0c             	sub    $0xc,%esp
80102369:	68 41 97 10 80       	push   $0x80109741
8010236e:	e8 95 e2 ff ff       	call   80100608 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102373:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010237a:	eb 7b                	jmp    801023f7 <dirlookup+0xa8>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010237c:	6a 10                	push   $0x10
8010237e:	ff 75 f4             	pushl  -0xc(%ebp)
80102381:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102384:	50                   	push   %eax
80102385:	ff 75 08             	pushl  0x8(%ebp)
80102388:	e8 c0 fc ff ff       	call   8010204d <readi>
8010238d:	83 c4 10             	add    $0x10,%esp
80102390:	83 f8 10             	cmp    $0x10,%eax
80102393:	74 0d                	je     801023a2 <dirlookup+0x53>
      panic("dirlookup read");
80102395:	83 ec 0c             	sub    $0xc,%esp
80102398:	68 53 97 10 80       	push   $0x80109753
8010239d:	e8 66 e2 ff ff       	call   80100608 <panic>
    if(de.inum == 0)
801023a2:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023a6:	66 85 c0             	test   %ax,%ax
801023a9:	74 47                	je     801023f2 <dirlookup+0xa3>
      continue;
    if(namecmp(name, de.name) == 0){
801023ab:	83 ec 08             	sub    $0x8,%esp
801023ae:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023b1:	83 c0 02             	add    $0x2,%eax
801023b4:	50                   	push   %eax
801023b5:	ff 75 0c             	pushl  0xc(%ebp)
801023b8:	e8 73 ff ff ff       	call   80102330 <namecmp>
801023bd:	83 c4 10             	add    $0x10,%esp
801023c0:	85 c0                	test   %eax,%eax
801023c2:	75 2f                	jne    801023f3 <dirlookup+0xa4>
      // entry matches path element
      if(poff)
801023c4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801023c8:	74 08                	je     801023d2 <dirlookup+0x83>
        *poff = off;
801023ca:	8b 45 10             	mov    0x10(%ebp),%eax
801023cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801023d0:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801023d2:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023d6:	0f b7 c0             	movzwl %ax,%eax
801023d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801023dc:	8b 45 08             	mov    0x8(%ebp),%eax
801023df:	8b 00                	mov    (%eax),%eax
801023e1:	83 ec 08             	sub    $0x8,%esp
801023e4:	ff 75 f0             	pushl  -0x10(%ebp)
801023e7:	50                   	push   %eax
801023e8:	e8 34 f6 ff ff       	call   80101a21 <iget>
801023ed:	83 c4 10             	add    $0x10,%esp
801023f0:	eb 19                	jmp    8010240b <dirlookup+0xbc>
      continue;
801023f2:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
801023f3:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801023f7:	8b 45 08             	mov    0x8(%ebp),%eax
801023fa:	8b 40 58             	mov    0x58(%eax),%eax
801023fd:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102400:	0f 82 76 ff ff ff    	jb     8010237c <dirlookup+0x2d>
    }
  }

  return 0;
80102406:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010240b:	c9                   	leave  
8010240c:	c3                   	ret    

8010240d <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010240d:	f3 0f 1e fb          	endbr32 
80102411:	55                   	push   %ebp
80102412:	89 e5                	mov    %esp,%ebp
80102414:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102417:	83 ec 04             	sub    $0x4,%esp
8010241a:	6a 00                	push   $0x0
8010241c:	ff 75 0c             	pushl  0xc(%ebp)
8010241f:	ff 75 08             	pushl  0x8(%ebp)
80102422:	e8 28 ff ff ff       	call   8010234f <dirlookup>
80102427:	83 c4 10             	add    $0x10,%esp
8010242a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010242d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102431:	74 18                	je     8010244b <dirlink+0x3e>
    iput(ip);
80102433:	83 ec 0c             	sub    $0xc,%esp
80102436:	ff 75 f0             	pushl  -0x10(%ebp)
80102439:	e8 70 f8 ff ff       	call   80101cae <iput>
8010243e:	83 c4 10             	add    $0x10,%esp
    return -1;
80102441:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102446:	e9 9c 00 00 00       	jmp    801024e7 <dirlink+0xda>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010244b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102452:	eb 39                	jmp    8010248d <dirlink+0x80>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102454:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102457:	6a 10                	push   $0x10
80102459:	50                   	push   %eax
8010245a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010245d:	50                   	push   %eax
8010245e:	ff 75 08             	pushl  0x8(%ebp)
80102461:	e8 e7 fb ff ff       	call   8010204d <readi>
80102466:	83 c4 10             	add    $0x10,%esp
80102469:	83 f8 10             	cmp    $0x10,%eax
8010246c:	74 0d                	je     8010247b <dirlink+0x6e>
      panic("dirlink read");
8010246e:	83 ec 0c             	sub    $0xc,%esp
80102471:	68 62 97 10 80       	push   $0x80109762
80102476:	e8 8d e1 ff ff       	call   80100608 <panic>
    if(de.inum == 0)
8010247b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010247f:	66 85 c0             	test   %ax,%ax
80102482:	74 18                	je     8010249c <dirlink+0x8f>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102484:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102487:	83 c0 10             	add    $0x10,%eax
8010248a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010248d:	8b 45 08             	mov    0x8(%ebp),%eax
80102490:	8b 50 58             	mov    0x58(%eax),%edx
80102493:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102496:	39 c2                	cmp    %eax,%edx
80102498:	77 ba                	ja     80102454 <dirlink+0x47>
8010249a:	eb 01                	jmp    8010249d <dirlink+0x90>
      break;
8010249c:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
8010249d:	83 ec 04             	sub    $0x4,%esp
801024a0:	6a 0e                	push   $0xe
801024a2:	ff 75 0c             	pushl  0xc(%ebp)
801024a5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024a8:	83 c0 02             	add    $0x2,%eax
801024ab:	50                   	push   %eax
801024ac:	e8 92 32 00 00       	call   80105743 <strncpy>
801024b1:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801024b4:	8b 45 10             	mov    0x10(%ebp),%eax
801024b7:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801024bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024be:	6a 10                	push   $0x10
801024c0:	50                   	push   %eax
801024c1:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024c4:	50                   	push   %eax
801024c5:	ff 75 08             	pushl  0x8(%ebp)
801024c8:	e8 d9 fc ff ff       	call   801021a6 <writei>
801024cd:	83 c4 10             	add    $0x10,%esp
801024d0:	83 f8 10             	cmp    $0x10,%eax
801024d3:	74 0d                	je     801024e2 <dirlink+0xd5>
    panic("dirlink");
801024d5:	83 ec 0c             	sub    $0xc,%esp
801024d8:	68 6f 97 10 80       	push   $0x8010976f
801024dd:	e8 26 e1 ff ff       	call   80100608 <panic>

  return 0;
801024e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801024e7:	c9                   	leave  
801024e8:	c3                   	ret    

801024e9 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801024e9:	f3 0f 1e fb          	endbr32 
801024ed:	55                   	push   %ebp
801024ee:	89 e5                	mov    %esp,%ebp
801024f0:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
801024f3:	eb 04                	jmp    801024f9 <skipelem+0x10>
    path++;
801024f5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801024f9:	8b 45 08             	mov    0x8(%ebp),%eax
801024fc:	0f b6 00             	movzbl (%eax),%eax
801024ff:	3c 2f                	cmp    $0x2f,%al
80102501:	74 f2                	je     801024f5 <skipelem+0xc>
  if(*path == 0)
80102503:	8b 45 08             	mov    0x8(%ebp),%eax
80102506:	0f b6 00             	movzbl (%eax),%eax
80102509:	84 c0                	test   %al,%al
8010250b:	75 07                	jne    80102514 <skipelem+0x2b>
    return 0;
8010250d:	b8 00 00 00 00       	mov    $0x0,%eax
80102512:	eb 77                	jmp    8010258b <skipelem+0xa2>
  s = path;
80102514:	8b 45 08             	mov    0x8(%ebp),%eax
80102517:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010251a:	eb 04                	jmp    80102520 <skipelem+0x37>
    path++;
8010251c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102520:	8b 45 08             	mov    0x8(%ebp),%eax
80102523:	0f b6 00             	movzbl (%eax),%eax
80102526:	3c 2f                	cmp    $0x2f,%al
80102528:	74 0a                	je     80102534 <skipelem+0x4b>
8010252a:	8b 45 08             	mov    0x8(%ebp),%eax
8010252d:	0f b6 00             	movzbl (%eax),%eax
80102530:	84 c0                	test   %al,%al
80102532:	75 e8                	jne    8010251c <skipelem+0x33>
  len = path - s;
80102534:	8b 45 08             	mov    0x8(%ebp),%eax
80102537:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010253a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
8010253d:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102541:	7e 15                	jle    80102558 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
80102543:	83 ec 04             	sub    $0x4,%esp
80102546:	6a 0e                	push   $0xe
80102548:	ff 75 f4             	pushl  -0xc(%ebp)
8010254b:	ff 75 0c             	pushl  0xc(%ebp)
8010254e:	e8 f8 30 00 00       	call   8010564b <memmove>
80102553:	83 c4 10             	add    $0x10,%esp
80102556:	eb 26                	jmp    8010257e <skipelem+0x95>
  else {
    memmove(name, s, len);
80102558:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010255b:	83 ec 04             	sub    $0x4,%esp
8010255e:	50                   	push   %eax
8010255f:	ff 75 f4             	pushl  -0xc(%ebp)
80102562:	ff 75 0c             	pushl  0xc(%ebp)
80102565:	e8 e1 30 00 00       	call   8010564b <memmove>
8010256a:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
8010256d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102570:	8b 45 0c             	mov    0xc(%ebp),%eax
80102573:	01 d0                	add    %edx,%eax
80102575:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102578:	eb 04                	jmp    8010257e <skipelem+0x95>
    path++;
8010257a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010257e:	8b 45 08             	mov    0x8(%ebp),%eax
80102581:	0f b6 00             	movzbl (%eax),%eax
80102584:	3c 2f                	cmp    $0x2f,%al
80102586:	74 f2                	je     8010257a <skipelem+0x91>
  return path;
80102588:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010258b:	c9                   	leave  
8010258c:	c3                   	ret    

8010258d <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010258d:	f3 0f 1e fb          	endbr32 
80102591:	55                   	push   %ebp
80102592:	89 e5                	mov    %esp,%ebp
80102594:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102597:	8b 45 08             	mov    0x8(%ebp),%eax
8010259a:	0f b6 00             	movzbl (%eax),%eax
8010259d:	3c 2f                	cmp    $0x2f,%al
8010259f:	75 17                	jne    801025b8 <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
801025a1:	83 ec 08             	sub    $0x8,%esp
801025a4:	6a 01                	push   $0x1
801025a6:	6a 01                	push   $0x1
801025a8:	e8 74 f4 ff ff       	call   80101a21 <iget>
801025ad:	83 c4 10             	add    $0x10,%esp
801025b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801025b3:	e9 ba 00 00 00       	jmp    80102672 <namex+0xe5>
  else
    ip = idup(myproc()->cwd);
801025b8:	e8 3c 1f 00 00       	call   801044f9 <myproc>
801025bd:	8b 40 68             	mov    0x68(%eax),%eax
801025c0:	83 ec 0c             	sub    $0xc,%esp
801025c3:	50                   	push   %eax
801025c4:	e8 3e f5 ff ff       	call   80101b07 <idup>
801025c9:	83 c4 10             	add    $0x10,%esp
801025cc:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801025cf:	e9 9e 00 00 00       	jmp    80102672 <namex+0xe5>
    ilock(ip);
801025d4:	83 ec 0c             	sub    $0xc,%esp
801025d7:	ff 75 f4             	pushl  -0xc(%ebp)
801025da:	e8 66 f5 ff ff       	call   80101b45 <ilock>
801025df:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
801025e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025e5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801025e9:	66 83 f8 01          	cmp    $0x1,%ax
801025ed:	74 18                	je     80102607 <namex+0x7a>
      iunlockput(ip);
801025ef:	83 ec 0c             	sub    $0xc,%esp
801025f2:	ff 75 f4             	pushl  -0xc(%ebp)
801025f5:	e8 88 f7 ff ff       	call   80101d82 <iunlockput>
801025fa:	83 c4 10             	add    $0x10,%esp
      return 0;
801025fd:	b8 00 00 00 00       	mov    $0x0,%eax
80102602:	e9 a7 00 00 00       	jmp    801026ae <namex+0x121>
    }
    if(nameiparent && *path == '\0'){
80102607:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010260b:	74 20                	je     8010262d <namex+0xa0>
8010260d:	8b 45 08             	mov    0x8(%ebp),%eax
80102610:	0f b6 00             	movzbl (%eax),%eax
80102613:	84 c0                	test   %al,%al
80102615:	75 16                	jne    8010262d <namex+0xa0>
      // Stop one level early.
      iunlock(ip);
80102617:	83 ec 0c             	sub    $0xc,%esp
8010261a:	ff 75 f4             	pushl  -0xc(%ebp)
8010261d:	e8 3a f6 ff ff       	call   80101c5c <iunlock>
80102622:	83 c4 10             	add    $0x10,%esp
      return ip;
80102625:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102628:	e9 81 00 00 00       	jmp    801026ae <namex+0x121>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010262d:	83 ec 04             	sub    $0x4,%esp
80102630:	6a 00                	push   $0x0
80102632:	ff 75 10             	pushl  0x10(%ebp)
80102635:	ff 75 f4             	pushl  -0xc(%ebp)
80102638:	e8 12 fd ff ff       	call   8010234f <dirlookup>
8010263d:	83 c4 10             	add    $0x10,%esp
80102640:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102643:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102647:	75 15                	jne    8010265e <namex+0xd1>
      iunlockput(ip);
80102649:	83 ec 0c             	sub    $0xc,%esp
8010264c:	ff 75 f4             	pushl  -0xc(%ebp)
8010264f:	e8 2e f7 ff ff       	call   80101d82 <iunlockput>
80102654:	83 c4 10             	add    $0x10,%esp
      return 0;
80102657:	b8 00 00 00 00       	mov    $0x0,%eax
8010265c:	eb 50                	jmp    801026ae <namex+0x121>
    }
    iunlockput(ip);
8010265e:	83 ec 0c             	sub    $0xc,%esp
80102661:	ff 75 f4             	pushl  -0xc(%ebp)
80102664:	e8 19 f7 ff ff       	call   80101d82 <iunlockput>
80102669:	83 c4 10             	add    $0x10,%esp
    ip = next;
8010266c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010266f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
80102672:	83 ec 08             	sub    $0x8,%esp
80102675:	ff 75 10             	pushl  0x10(%ebp)
80102678:	ff 75 08             	pushl  0x8(%ebp)
8010267b:	e8 69 fe ff ff       	call   801024e9 <skipelem>
80102680:	83 c4 10             	add    $0x10,%esp
80102683:	89 45 08             	mov    %eax,0x8(%ebp)
80102686:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010268a:	0f 85 44 ff ff ff    	jne    801025d4 <namex+0x47>
  }
  if(nameiparent){
80102690:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102694:	74 15                	je     801026ab <namex+0x11e>
    iput(ip);
80102696:	83 ec 0c             	sub    $0xc,%esp
80102699:	ff 75 f4             	pushl  -0xc(%ebp)
8010269c:	e8 0d f6 ff ff       	call   80101cae <iput>
801026a1:	83 c4 10             	add    $0x10,%esp
    return 0;
801026a4:	b8 00 00 00 00       	mov    $0x0,%eax
801026a9:	eb 03                	jmp    801026ae <namex+0x121>
  }
  return ip;
801026ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801026ae:	c9                   	leave  
801026af:	c3                   	ret    

801026b0 <namei>:

struct inode*
namei(char *path)
{
801026b0:	f3 0f 1e fb          	endbr32 
801026b4:	55                   	push   %ebp
801026b5:	89 e5                	mov    %esp,%ebp
801026b7:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801026ba:	83 ec 04             	sub    $0x4,%esp
801026bd:	8d 45 ea             	lea    -0x16(%ebp),%eax
801026c0:	50                   	push   %eax
801026c1:	6a 00                	push   $0x0
801026c3:	ff 75 08             	pushl  0x8(%ebp)
801026c6:	e8 c2 fe ff ff       	call   8010258d <namex>
801026cb:	83 c4 10             	add    $0x10,%esp
}
801026ce:	c9                   	leave  
801026cf:	c3                   	ret    

801026d0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801026d0:	f3 0f 1e fb          	endbr32 
801026d4:	55                   	push   %ebp
801026d5:	89 e5                	mov    %esp,%ebp
801026d7:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
801026da:	83 ec 04             	sub    $0x4,%esp
801026dd:	ff 75 0c             	pushl  0xc(%ebp)
801026e0:	6a 01                	push   $0x1
801026e2:	ff 75 08             	pushl  0x8(%ebp)
801026e5:	e8 a3 fe ff ff       	call   8010258d <namex>
801026ea:	83 c4 10             	add    $0x10,%esp
}
801026ed:	c9                   	leave  
801026ee:	c3                   	ret    

801026ef <inb>:
{
801026ef:	55                   	push   %ebp
801026f0:	89 e5                	mov    %esp,%ebp
801026f2:	83 ec 14             	sub    $0x14,%esp
801026f5:	8b 45 08             	mov    0x8(%ebp),%eax
801026f8:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801026fc:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102700:	89 c2                	mov    %eax,%edx
80102702:	ec                   	in     (%dx),%al
80102703:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102706:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010270a:	c9                   	leave  
8010270b:	c3                   	ret    

8010270c <insl>:
{
8010270c:	55                   	push   %ebp
8010270d:	89 e5                	mov    %esp,%ebp
8010270f:	57                   	push   %edi
80102710:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102711:	8b 55 08             	mov    0x8(%ebp),%edx
80102714:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102717:	8b 45 10             	mov    0x10(%ebp),%eax
8010271a:	89 cb                	mov    %ecx,%ebx
8010271c:	89 df                	mov    %ebx,%edi
8010271e:	89 c1                	mov    %eax,%ecx
80102720:	fc                   	cld    
80102721:	f3 6d                	rep insl (%dx),%es:(%edi)
80102723:	89 c8                	mov    %ecx,%eax
80102725:	89 fb                	mov    %edi,%ebx
80102727:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010272a:	89 45 10             	mov    %eax,0x10(%ebp)
}
8010272d:	90                   	nop
8010272e:	5b                   	pop    %ebx
8010272f:	5f                   	pop    %edi
80102730:	5d                   	pop    %ebp
80102731:	c3                   	ret    

80102732 <outb>:
{
80102732:	55                   	push   %ebp
80102733:	89 e5                	mov    %esp,%ebp
80102735:	83 ec 08             	sub    $0x8,%esp
80102738:	8b 45 08             	mov    0x8(%ebp),%eax
8010273b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010273e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102742:	89 d0                	mov    %edx,%eax
80102744:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102747:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010274b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010274f:	ee                   	out    %al,(%dx)
}
80102750:	90                   	nop
80102751:	c9                   	leave  
80102752:	c3                   	ret    

80102753 <outsl>:
{
80102753:	55                   	push   %ebp
80102754:	89 e5                	mov    %esp,%ebp
80102756:	56                   	push   %esi
80102757:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102758:	8b 55 08             	mov    0x8(%ebp),%edx
8010275b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010275e:	8b 45 10             	mov    0x10(%ebp),%eax
80102761:	89 cb                	mov    %ecx,%ebx
80102763:	89 de                	mov    %ebx,%esi
80102765:	89 c1                	mov    %eax,%ecx
80102767:	fc                   	cld    
80102768:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010276a:	89 c8                	mov    %ecx,%eax
8010276c:	89 f3                	mov    %esi,%ebx
8010276e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102771:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102774:	90                   	nop
80102775:	5b                   	pop    %ebx
80102776:	5e                   	pop    %esi
80102777:	5d                   	pop    %ebp
80102778:	c3                   	ret    

80102779 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102779:	f3 0f 1e fb          	endbr32 
8010277d:	55                   	push   %ebp
8010277e:	89 e5                	mov    %esp,%ebp
80102780:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102783:	90                   	nop
80102784:	68 f7 01 00 00       	push   $0x1f7
80102789:	e8 61 ff ff ff       	call   801026ef <inb>
8010278e:	83 c4 04             	add    $0x4,%esp
80102791:	0f b6 c0             	movzbl %al,%eax
80102794:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102797:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010279a:	25 c0 00 00 00       	and    $0xc0,%eax
8010279f:	83 f8 40             	cmp    $0x40,%eax
801027a2:	75 e0                	jne    80102784 <idewait+0xb>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801027a4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801027a8:	74 11                	je     801027bb <idewait+0x42>
801027aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
801027ad:	83 e0 21             	and    $0x21,%eax
801027b0:	85 c0                	test   %eax,%eax
801027b2:	74 07                	je     801027bb <idewait+0x42>
    return -1;
801027b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801027b9:	eb 05                	jmp    801027c0 <idewait+0x47>
  return 0;
801027bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801027c0:	c9                   	leave  
801027c1:	c3                   	ret    

801027c2 <ideinit>:

void
ideinit(void)
{
801027c2:	f3 0f 1e fb          	endbr32 
801027c6:	55                   	push   %ebp
801027c7:	89 e5                	mov    %esp,%ebp
801027c9:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
801027cc:	83 ec 08             	sub    $0x8,%esp
801027cf:	68 77 97 10 80       	push   $0x80109777
801027d4:	68 00 d6 10 80       	push   $0x8010d600
801027d9:	e8 e1 2a 00 00       	call   801052bf <initlock>
801027de:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801027e1:	a1 a0 5d 11 80       	mov    0x80115da0,%eax
801027e6:	83 e8 01             	sub    $0x1,%eax
801027e9:	83 ec 08             	sub    $0x8,%esp
801027ec:	50                   	push   %eax
801027ed:	6a 0e                	push   $0xe
801027ef:	e8 bb 04 00 00       	call   80102caf <ioapicenable>
801027f4:	83 c4 10             	add    $0x10,%esp
  idewait(0);
801027f7:	83 ec 0c             	sub    $0xc,%esp
801027fa:	6a 00                	push   $0x0
801027fc:	e8 78 ff ff ff       	call   80102779 <idewait>
80102801:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102804:	83 ec 08             	sub    $0x8,%esp
80102807:	68 f0 00 00 00       	push   $0xf0
8010280c:	68 f6 01 00 00       	push   $0x1f6
80102811:	e8 1c ff ff ff       	call   80102732 <outb>
80102816:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102819:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102820:	eb 24                	jmp    80102846 <ideinit+0x84>
    if(inb(0x1f7) != 0){
80102822:	83 ec 0c             	sub    $0xc,%esp
80102825:	68 f7 01 00 00       	push   $0x1f7
8010282a:	e8 c0 fe ff ff       	call   801026ef <inb>
8010282f:	83 c4 10             	add    $0x10,%esp
80102832:	84 c0                	test   %al,%al
80102834:	74 0c                	je     80102842 <ideinit+0x80>
      havedisk1 = 1;
80102836:	c7 05 38 d6 10 80 01 	movl   $0x1,0x8010d638
8010283d:	00 00 00 
      break;
80102840:	eb 0d                	jmp    8010284f <ideinit+0x8d>
  for(i=0; i<1000; i++){
80102842:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102846:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
8010284d:	7e d3                	jle    80102822 <ideinit+0x60>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
8010284f:	83 ec 08             	sub    $0x8,%esp
80102852:	68 e0 00 00 00       	push   $0xe0
80102857:	68 f6 01 00 00       	push   $0x1f6
8010285c:	e8 d1 fe ff ff       	call   80102732 <outb>
80102861:	83 c4 10             	add    $0x10,%esp
}
80102864:	90                   	nop
80102865:	c9                   	leave  
80102866:	c3                   	ret    

80102867 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102867:	f3 0f 1e fb          	endbr32 
8010286b:	55                   	push   %ebp
8010286c:	89 e5                	mov    %esp,%ebp
8010286e:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102871:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102875:	75 0d                	jne    80102884 <idestart+0x1d>
    panic("idestart");
80102877:	83 ec 0c             	sub    $0xc,%esp
8010287a:	68 7b 97 10 80       	push   $0x8010977b
8010287f:	e8 84 dd ff ff       	call   80100608 <panic>
  if(b->blockno >= FSSIZE)
80102884:	8b 45 08             	mov    0x8(%ebp),%eax
80102887:	8b 40 08             	mov    0x8(%eax),%eax
8010288a:	3d e7 03 00 00       	cmp    $0x3e7,%eax
8010288f:	76 0d                	jbe    8010289e <idestart+0x37>
    panic("incorrect blockno");
80102891:	83 ec 0c             	sub    $0xc,%esp
80102894:	68 84 97 10 80       	push   $0x80109784
80102899:	e8 6a dd ff ff       	call   80100608 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
8010289e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801028a5:	8b 45 08             	mov    0x8(%ebp),%eax
801028a8:	8b 50 08             	mov    0x8(%eax),%edx
801028ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ae:	0f af c2             	imul   %edx,%eax
801028b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
801028b4:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801028b8:	75 07                	jne    801028c1 <idestart+0x5a>
801028ba:	b8 20 00 00 00       	mov    $0x20,%eax
801028bf:	eb 05                	jmp    801028c6 <idestart+0x5f>
801028c1:	b8 c4 00 00 00       	mov    $0xc4,%eax
801028c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
801028c9:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801028cd:	75 07                	jne    801028d6 <idestart+0x6f>
801028cf:	b8 30 00 00 00       	mov    $0x30,%eax
801028d4:	eb 05                	jmp    801028db <idestart+0x74>
801028d6:	b8 c5 00 00 00       	mov    $0xc5,%eax
801028db:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
801028de:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801028e2:	7e 0d                	jle    801028f1 <idestart+0x8a>
801028e4:	83 ec 0c             	sub    $0xc,%esp
801028e7:	68 7b 97 10 80       	push   $0x8010977b
801028ec:	e8 17 dd ff ff       	call   80100608 <panic>

  idewait(0);
801028f1:	83 ec 0c             	sub    $0xc,%esp
801028f4:	6a 00                	push   $0x0
801028f6:	e8 7e fe ff ff       	call   80102779 <idewait>
801028fb:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
801028fe:	83 ec 08             	sub    $0x8,%esp
80102901:	6a 00                	push   $0x0
80102903:	68 f6 03 00 00       	push   $0x3f6
80102908:	e8 25 fe ff ff       	call   80102732 <outb>
8010290d:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102910:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102913:	0f b6 c0             	movzbl %al,%eax
80102916:	83 ec 08             	sub    $0x8,%esp
80102919:	50                   	push   %eax
8010291a:	68 f2 01 00 00       	push   $0x1f2
8010291f:	e8 0e fe ff ff       	call   80102732 <outb>
80102924:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102927:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010292a:	0f b6 c0             	movzbl %al,%eax
8010292d:	83 ec 08             	sub    $0x8,%esp
80102930:	50                   	push   %eax
80102931:	68 f3 01 00 00       	push   $0x1f3
80102936:	e8 f7 fd ff ff       	call   80102732 <outb>
8010293b:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
8010293e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102941:	c1 f8 08             	sar    $0x8,%eax
80102944:	0f b6 c0             	movzbl %al,%eax
80102947:	83 ec 08             	sub    $0x8,%esp
8010294a:	50                   	push   %eax
8010294b:	68 f4 01 00 00       	push   $0x1f4
80102950:	e8 dd fd ff ff       	call   80102732 <outb>
80102955:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102958:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010295b:	c1 f8 10             	sar    $0x10,%eax
8010295e:	0f b6 c0             	movzbl %al,%eax
80102961:	83 ec 08             	sub    $0x8,%esp
80102964:	50                   	push   %eax
80102965:	68 f5 01 00 00       	push   $0x1f5
8010296a:	e8 c3 fd ff ff       	call   80102732 <outb>
8010296f:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102972:	8b 45 08             	mov    0x8(%ebp),%eax
80102975:	8b 40 04             	mov    0x4(%eax),%eax
80102978:	c1 e0 04             	shl    $0x4,%eax
8010297b:	83 e0 10             	and    $0x10,%eax
8010297e:	89 c2                	mov    %eax,%edx
80102980:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102983:	c1 f8 18             	sar    $0x18,%eax
80102986:	83 e0 0f             	and    $0xf,%eax
80102989:	09 d0                	or     %edx,%eax
8010298b:	83 c8 e0             	or     $0xffffffe0,%eax
8010298e:	0f b6 c0             	movzbl %al,%eax
80102991:	83 ec 08             	sub    $0x8,%esp
80102994:	50                   	push   %eax
80102995:	68 f6 01 00 00       	push   $0x1f6
8010299a:	e8 93 fd ff ff       	call   80102732 <outb>
8010299f:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801029a2:	8b 45 08             	mov    0x8(%ebp),%eax
801029a5:	8b 00                	mov    (%eax),%eax
801029a7:	83 e0 04             	and    $0x4,%eax
801029aa:	85 c0                	test   %eax,%eax
801029ac:	74 35                	je     801029e3 <idestart+0x17c>
    outb(0x1f7, write_cmd);
801029ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
801029b1:	0f b6 c0             	movzbl %al,%eax
801029b4:	83 ec 08             	sub    $0x8,%esp
801029b7:	50                   	push   %eax
801029b8:	68 f7 01 00 00       	push   $0x1f7
801029bd:	e8 70 fd ff ff       	call   80102732 <outb>
801029c2:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
801029c5:	8b 45 08             	mov    0x8(%ebp),%eax
801029c8:	83 c0 5c             	add    $0x5c,%eax
801029cb:	83 ec 04             	sub    $0x4,%esp
801029ce:	68 80 00 00 00       	push   $0x80
801029d3:	50                   	push   %eax
801029d4:	68 f0 01 00 00       	push   $0x1f0
801029d9:	e8 75 fd ff ff       	call   80102753 <outsl>
801029de:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
801029e1:	eb 17                	jmp    801029fa <idestart+0x193>
    outb(0x1f7, read_cmd);
801029e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801029e6:	0f b6 c0             	movzbl %al,%eax
801029e9:	83 ec 08             	sub    $0x8,%esp
801029ec:	50                   	push   %eax
801029ed:	68 f7 01 00 00       	push   $0x1f7
801029f2:	e8 3b fd ff ff       	call   80102732 <outb>
801029f7:	83 c4 10             	add    $0x10,%esp
}
801029fa:	90                   	nop
801029fb:	c9                   	leave  
801029fc:	c3                   	ret    

801029fd <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801029fd:	f3 0f 1e fb          	endbr32 
80102a01:	55                   	push   %ebp
80102a02:	89 e5                	mov    %esp,%ebp
80102a04:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102a07:	83 ec 0c             	sub    $0xc,%esp
80102a0a:	68 00 d6 10 80       	push   $0x8010d600
80102a0f:	e8 d1 28 00 00       	call   801052e5 <acquire>
80102a14:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
80102a17:	a1 34 d6 10 80       	mov    0x8010d634,%eax
80102a1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a1f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102a23:	75 15                	jne    80102a3a <ideintr+0x3d>
    release(&idelock);
80102a25:	83 ec 0c             	sub    $0xc,%esp
80102a28:	68 00 d6 10 80       	push   $0x8010d600
80102a2d:	e8 25 29 00 00       	call   80105357 <release>
80102a32:	83 c4 10             	add    $0x10,%esp
    return;
80102a35:	e9 9a 00 00 00       	jmp    80102ad4 <ideintr+0xd7>
  }
  idequeue = b->qnext;
80102a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a3d:	8b 40 58             	mov    0x58(%eax),%eax
80102a40:	a3 34 d6 10 80       	mov    %eax,0x8010d634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a48:	8b 00                	mov    (%eax),%eax
80102a4a:	83 e0 04             	and    $0x4,%eax
80102a4d:	85 c0                	test   %eax,%eax
80102a4f:	75 2d                	jne    80102a7e <ideintr+0x81>
80102a51:	83 ec 0c             	sub    $0xc,%esp
80102a54:	6a 01                	push   $0x1
80102a56:	e8 1e fd ff ff       	call   80102779 <idewait>
80102a5b:	83 c4 10             	add    $0x10,%esp
80102a5e:	85 c0                	test   %eax,%eax
80102a60:	78 1c                	js     80102a7e <ideintr+0x81>
    insl(0x1f0, b->data, BSIZE/4);
80102a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a65:	83 c0 5c             	add    $0x5c,%eax
80102a68:	83 ec 04             	sub    $0x4,%esp
80102a6b:	68 80 00 00 00       	push   $0x80
80102a70:	50                   	push   %eax
80102a71:	68 f0 01 00 00       	push   $0x1f0
80102a76:	e8 91 fc ff ff       	call   8010270c <insl>
80102a7b:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a81:	8b 00                	mov    (%eax),%eax
80102a83:	83 c8 02             	or     $0x2,%eax
80102a86:	89 c2                	mov    %eax,%edx
80102a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a8b:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a90:	8b 00                	mov    (%eax),%eax
80102a92:	83 e0 fb             	and    $0xfffffffb,%eax
80102a95:	89 c2                	mov    %eax,%edx
80102a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a9a:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102a9c:	83 ec 0c             	sub    $0xc,%esp
80102a9f:	ff 75 f4             	pushl  -0xc(%ebp)
80102aa2:	e8 be 24 00 00       	call   80104f65 <wakeup>
80102aa7:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102aaa:	a1 34 d6 10 80       	mov    0x8010d634,%eax
80102aaf:	85 c0                	test   %eax,%eax
80102ab1:	74 11                	je     80102ac4 <ideintr+0xc7>
    idestart(idequeue);
80102ab3:	a1 34 d6 10 80       	mov    0x8010d634,%eax
80102ab8:	83 ec 0c             	sub    $0xc,%esp
80102abb:	50                   	push   %eax
80102abc:	e8 a6 fd ff ff       	call   80102867 <idestart>
80102ac1:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102ac4:	83 ec 0c             	sub    $0xc,%esp
80102ac7:	68 00 d6 10 80       	push   $0x8010d600
80102acc:	e8 86 28 00 00       	call   80105357 <release>
80102ad1:	83 c4 10             	add    $0x10,%esp
}
80102ad4:	c9                   	leave  
80102ad5:	c3                   	ret    

80102ad6 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102ad6:	f3 0f 1e fb          	endbr32 
80102ada:	55                   	push   %ebp
80102adb:	89 e5                	mov    %esp,%ebp
80102add:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102ae0:	8b 45 08             	mov    0x8(%ebp),%eax
80102ae3:	83 c0 0c             	add    $0xc,%eax
80102ae6:	83 ec 0c             	sub    $0xc,%esp
80102ae9:	50                   	push   %eax
80102aea:	e8 37 27 00 00       	call   80105226 <holdingsleep>
80102aef:	83 c4 10             	add    $0x10,%esp
80102af2:	85 c0                	test   %eax,%eax
80102af4:	75 0d                	jne    80102b03 <iderw+0x2d>
    panic("iderw: buf not locked");
80102af6:	83 ec 0c             	sub    $0xc,%esp
80102af9:	68 96 97 10 80       	push   $0x80109796
80102afe:	e8 05 db ff ff       	call   80100608 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102b03:	8b 45 08             	mov    0x8(%ebp),%eax
80102b06:	8b 00                	mov    (%eax),%eax
80102b08:	83 e0 06             	and    $0x6,%eax
80102b0b:	83 f8 02             	cmp    $0x2,%eax
80102b0e:	75 0d                	jne    80102b1d <iderw+0x47>
    panic("iderw: nothing to do");
80102b10:	83 ec 0c             	sub    $0xc,%esp
80102b13:	68 ac 97 10 80       	push   $0x801097ac
80102b18:	e8 eb da ff ff       	call   80100608 <panic>
  if(b->dev != 0 && !havedisk1)
80102b1d:	8b 45 08             	mov    0x8(%ebp),%eax
80102b20:	8b 40 04             	mov    0x4(%eax),%eax
80102b23:	85 c0                	test   %eax,%eax
80102b25:	74 16                	je     80102b3d <iderw+0x67>
80102b27:	a1 38 d6 10 80       	mov    0x8010d638,%eax
80102b2c:	85 c0                	test   %eax,%eax
80102b2e:	75 0d                	jne    80102b3d <iderw+0x67>
    panic("iderw: ide disk 1 not present");
80102b30:	83 ec 0c             	sub    $0xc,%esp
80102b33:	68 c1 97 10 80       	push   $0x801097c1
80102b38:	e8 cb da ff ff       	call   80100608 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102b3d:	83 ec 0c             	sub    $0xc,%esp
80102b40:	68 00 d6 10 80       	push   $0x8010d600
80102b45:	e8 9b 27 00 00       	call   801052e5 <acquire>
80102b4a:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102b4d:	8b 45 08             	mov    0x8(%ebp),%eax
80102b50:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102b57:	c7 45 f4 34 d6 10 80 	movl   $0x8010d634,-0xc(%ebp)
80102b5e:	eb 0b                	jmp    80102b6b <iderw+0x95>
80102b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b63:	8b 00                	mov    (%eax),%eax
80102b65:	83 c0 58             	add    $0x58,%eax
80102b68:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b6e:	8b 00                	mov    (%eax),%eax
80102b70:	85 c0                	test   %eax,%eax
80102b72:	75 ec                	jne    80102b60 <iderw+0x8a>
    ;
  *pp = b;
80102b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b77:	8b 55 08             	mov    0x8(%ebp),%edx
80102b7a:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102b7c:	a1 34 d6 10 80       	mov    0x8010d634,%eax
80102b81:	39 45 08             	cmp    %eax,0x8(%ebp)
80102b84:	75 23                	jne    80102ba9 <iderw+0xd3>
    idestart(b);
80102b86:	83 ec 0c             	sub    $0xc,%esp
80102b89:	ff 75 08             	pushl  0x8(%ebp)
80102b8c:	e8 d6 fc ff ff       	call   80102867 <idestart>
80102b91:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b94:	eb 13                	jmp    80102ba9 <iderw+0xd3>
    sleep(b, &idelock);
80102b96:	83 ec 08             	sub    $0x8,%esp
80102b99:	68 00 d6 10 80       	push   $0x8010d600
80102b9e:	ff 75 08             	pushl  0x8(%ebp)
80102ba1:	e8 cd 22 00 00       	call   80104e73 <sleep>
80102ba6:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102ba9:	8b 45 08             	mov    0x8(%ebp),%eax
80102bac:	8b 00                	mov    (%eax),%eax
80102bae:	83 e0 06             	and    $0x6,%eax
80102bb1:	83 f8 02             	cmp    $0x2,%eax
80102bb4:	75 e0                	jne    80102b96 <iderw+0xc0>
  }


  release(&idelock);
80102bb6:	83 ec 0c             	sub    $0xc,%esp
80102bb9:	68 00 d6 10 80       	push   $0x8010d600
80102bbe:	e8 94 27 00 00       	call   80105357 <release>
80102bc3:	83 c4 10             	add    $0x10,%esp
}
80102bc6:	90                   	nop
80102bc7:	c9                   	leave  
80102bc8:	c3                   	ret    

80102bc9 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102bc9:	f3 0f 1e fb          	endbr32 
80102bcd:	55                   	push   %ebp
80102bce:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102bd0:	a1 d4 56 11 80       	mov    0x801156d4,%eax
80102bd5:	8b 55 08             	mov    0x8(%ebp),%edx
80102bd8:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102bda:	a1 d4 56 11 80       	mov    0x801156d4,%eax
80102bdf:	8b 40 10             	mov    0x10(%eax),%eax
}
80102be2:	5d                   	pop    %ebp
80102be3:	c3                   	ret    

80102be4 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102be4:	f3 0f 1e fb          	endbr32 
80102be8:	55                   	push   %ebp
80102be9:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102beb:	a1 d4 56 11 80       	mov    0x801156d4,%eax
80102bf0:	8b 55 08             	mov    0x8(%ebp),%edx
80102bf3:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102bf5:	a1 d4 56 11 80       	mov    0x801156d4,%eax
80102bfa:	8b 55 0c             	mov    0xc(%ebp),%edx
80102bfd:	89 50 10             	mov    %edx,0x10(%eax)
}
80102c00:	90                   	nop
80102c01:	5d                   	pop    %ebp
80102c02:	c3                   	ret    

80102c03 <ioapicinit>:

void
ioapicinit(void)
{
80102c03:	f3 0f 1e fb          	endbr32 
80102c07:	55                   	push   %ebp
80102c08:	89 e5                	mov    %esp,%ebp
80102c0a:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102c0d:	c7 05 d4 56 11 80 00 	movl   $0xfec00000,0x801156d4
80102c14:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102c17:	6a 01                	push   $0x1
80102c19:	e8 ab ff ff ff       	call   80102bc9 <ioapicread>
80102c1e:	83 c4 04             	add    $0x4,%esp
80102c21:	c1 e8 10             	shr    $0x10,%eax
80102c24:	25 ff 00 00 00       	and    $0xff,%eax
80102c29:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102c2c:	6a 00                	push   $0x0
80102c2e:	e8 96 ff ff ff       	call   80102bc9 <ioapicread>
80102c33:	83 c4 04             	add    $0x4,%esp
80102c36:	c1 e8 18             	shr    $0x18,%eax
80102c39:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102c3c:	0f b6 05 00 58 11 80 	movzbl 0x80115800,%eax
80102c43:	0f b6 c0             	movzbl %al,%eax
80102c46:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102c49:	74 10                	je     80102c5b <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102c4b:	83 ec 0c             	sub    $0xc,%esp
80102c4e:	68 e0 97 10 80       	push   $0x801097e0
80102c53:	e8 c0 d7 ff ff       	call   80100418 <cprintf>
80102c58:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c5b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c62:	eb 3f                	jmp    80102ca3 <ioapicinit+0xa0>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c67:	83 c0 20             	add    $0x20,%eax
80102c6a:	0d 00 00 01 00       	or     $0x10000,%eax
80102c6f:	89 c2                	mov    %eax,%edx
80102c71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c74:	83 c0 08             	add    $0x8,%eax
80102c77:	01 c0                	add    %eax,%eax
80102c79:	83 ec 08             	sub    $0x8,%esp
80102c7c:	52                   	push   %edx
80102c7d:	50                   	push   %eax
80102c7e:	e8 61 ff ff ff       	call   80102be4 <ioapicwrite>
80102c83:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c89:	83 c0 08             	add    $0x8,%eax
80102c8c:	01 c0                	add    %eax,%eax
80102c8e:	83 c0 01             	add    $0x1,%eax
80102c91:	83 ec 08             	sub    $0x8,%esp
80102c94:	6a 00                	push   $0x0
80102c96:	50                   	push   %eax
80102c97:	e8 48 ff ff ff       	call   80102be4 <ioapicwrite>
80102c9c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102c9f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ca3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ca6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102ca9:	7e b9                	jle    80102c64 <ioapicinit+0x61>
  }
}
80102cab:	90                   	nop
80102cac:	90                   	nop
80102cad:	c9                   	leave  
80102cae:	c3                   	ret    

80102caf <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102caf:	f3 0f 1e fb          	endbr32 
80102cb3:	55                   	push   %ebp
80102cb4:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102cb6:	8b 45 08             	mov    0x8(%ebp),%eax
80102cb9:	83 c0 20             	add    $0x20,%eax
80102cbc:	89 c2                	mov    %eax,%edx
80102cbe:	8b 45 08             	mov    0x8(%ebp),%eax
80102cc1:	83 c0 08             	add    $0x8,%eax
80102cc4:	01 c0                	add    %eax,%eax
80102cc6:	52                   	push   %edx
80102cc7:	50                   	push   %eax
80102cc8:	e8 17 ff ff ff       	call   80102be4 <ioapicwrite>
80102ccd:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102cd0:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cd3:	c1 e0 18             	shl    $0x18,%eax
80102cd6:	89 c2                	mov    %eax,%edx
80102cd8:	8b 45 08             	mov    0x8(%ebp),%eax
80102cdb:	83 c0 08             	add    $0x8,%eax
80102cde:	01 c0                	add    %eax,%eax
80102ce0:	83 c0 01             	add    $0x1,%eax
80102ce3:	52                   	push   %edx
80102ce4:	50                   	push   %eax
80102ce5:	e8 fa fe ff ff       	call   80102be4 <ioapicwrite>
80102cea:	83 c4 08             	add    $0x8,%esp
}
80102ced:	90                   	nop
80102cee:	c9                   	leave  
80102cef:	c3                   	ret    

80102cf0 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102cf0:	f3 0f 1e fb          	endbr32 
80102cf4:	55                   	push   %ebp
80102cf5:	89 e5                	mov    %esp,%ebp
80102cf7:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102cfa:	83 ec 08             	sub    $0x8,%esp
80102cfd:	68 14 98 10 80       	push   $0x80109814
80102d02:	68 e0 56 11 80       	push   $0x801156e0
80102d07:	e8 b3 25 00 00       	call   801052bf <initlock>
80102d0c:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102d0f:	c7 05 14 57 11 80 00 	movl   $0x0,0x80115714
80102d16:	00 00 00 
  freerange(vstart, vend);
80102d19:	83 ec 08             	sub    $0x8,%esp
80102d1c:	ff 75 0c             	pushl  0xc(%ebp)
80102d1f:	ff 75 08             	pushl  0x8(%ebp)
80102d22:	e8 2e 00 00 00       	call   80102d55 <freerange>
80102d27:	83 c4 10             	add    $0x10,%esp
}
80102d2a:	90                   	nop
80102d2b:	c9                   	leave  
80102d2c:	c3                   	ret    

80102d2d <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102d2d:	f3 0f 1e fb          	endbr32 
80102d31:	55                   	push   %ebp
80102d32:	89 e5                	mov    %esp,%ebp
80102d34:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102d37:	83 ec 08             	sub    $0x8,%esp
80102d3a:	ff 75 0c             	pushl  0xc(%ebp)
80102d3d:	ff 75 08             	pushl  0x8(%ebp)
80102d40:	e8 10 00 00 00       	call   80102d55 <freerange>
80102d45:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102d48:	c7 05 14 57 11 80 01 	movl   $0x1,0x80115714
80102d4f:	00 00 00 
}
80102d52:	90                   	nop
80102d53:	c9                   	leave  
80102d54:	c3                   	ret    

80102d55 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d55:	f3 0f 1e fb          	endbr32 
80102d59:	55                   	push   %ebp
80102d5a:	89 e5                	mov    %esp,%ebp
80102d5c:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102d5f:	8b 45 08             	mov    0x8(%ebp),%eax
80102d62:	05 ff 0f 00 00       	add    $0xfff,%eax
80102d67:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102d6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d6f:	eb 15                	jmp    80102d86 <freerange+0x31>
    kfree(p);
80102d71:	83 ec 0c             	sub    $0xc,%esp
80102d74:	ff 75 f4             	pushl  -0xc(%ebp)
80102d77:	e8 1b 00 00 00       	call   80102d97 <kfree>
80102d7c:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d7f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d89:	05 00 10 00 00       	add    $0x1000,%eax
80102d8e:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102d91:	73 de                	jae    80102d71 <freerange+0x1c>
}
80102d93:	90                   	nop
80102d94:	90                   	nop
80102d95:	c9                   	leave  
80102d96:	c3                   	ret    

80102d97 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102d97:	f3 0f 1e fb          	endbr32 
80102d9b:	55                   	push   %ebp
80102d9c:	89 e5                	mov    %esp,%ebp
80102d9e:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102da1:	8b 45 08             	mov    0x8(%ebp),%eax
80102da4:	25 ff 0f 00 00       	and    $0xfff,%eax
80102da9:	85 c0                	test   %eax,%eax
80102dab:	75 18                	jne    80102dc5 <kfree+0x2e>
80102dad:	81 7d 08 48 96 11 80 	cmpl   $0x80119648,0x8(%ebp)
80102db4:	72 0f                	jb     80102dc5 <kfree+0x2e>
80102db6:	8b 45 08             	mov    0x8(%ebp),%eax
80102db9:	05 00 00 00 80       	add    $0x80000000,%eax
80102dbe:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102dc3:	76 0d                	jbe    80102dd2 <kfree+0x3b>
    panic("kfree");
80102dc5:	83 ec 0c             	sub    $0xc,%esp
80102dc8:	68 19 98 10 80       	push   $0x80109819
80102dcd:	e8 36 d8 ff ff       	call   80100608 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102dd2:	83 ec 04             	sub    $0x4,%esp
80102dd5:	68 00 10 00 00       	push   $0x1000
80102dda:	6a 01                	push   $0x1
80102ddc:	ff 75 08             	pushl  0x8(%ebp)
80102ddf:	e8 a0 27 00 00       	call   80105584 <memset>
80102de4:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102de7:	a1 14 57 11 80       	mov    0x80115714,%eax
80102dec:	85 c0                	test   %eax,%eax
80102dee:	74 10                	je     80102e00 <kfree+0x69>
    acquire(&kmem.lock);
80102df0:	83 ec 0c             	sub    $0xc,%esp
80102df3:	68 e0 56 11 80       	push   $0x801156e0
80102df8:	e8 e8 24 00 00       	call   801052e5 <acquire>
80102dfd:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102e00:	8b 45 08             	mov    0x8(%ebp),%eax
80102e03:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102e06:	8b 15 18 57 11 80    	mov    0x80115718,%edx
80102e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e0f:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102e11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e14:	a3 18 57 11 80       	mov    %eax,0x80115718
  if(kmem.use_lock)
80102e19:	a1 14 57 11 80       	mov    0x80115714,%eax
80102e1e:	85 c0                	test   %eax,%eax
80102e20:	74 10                	je     80102e32 <kfree+0x9b>
    release(&kmem.lock);
80102e22:	83 ec 0c             	sub    $0xc,%esp
80102e25:	68 e0 56 11 80       	push   $0x801156e0
80102e2a:	e8 28 25 00 00       	call   80105357 <release>
80102e2f:	83 c4 10             	add    $0x10,%esp
}
80102e32:	90                   	nop
80102e33:	c9                   	leave  
80102e34:	c3                   	ret    

80102e35 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102e35:	f3 0f 1e fb          	endbr32 
80102e39:	55                   	push   %ebp
80102e3a:	89 e5                	mov    %esp,%ebp
80102e3c:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102e3f:	a1 14 57 11 80       	mov    0x80115714,%eax
80102e44:	85 c0                	test   %eax,%eax
80102e46:	74 10                	je     80102e58 <kalloc+0x23>
    acquire(&kmem.lock);
80102e48:	83 ec 0c             	sub    $0xc,%esp
80102e4b:	68 e0 56 11 80       	push   $0x801156e0
80102e50:	e8 90 24 00 00       	call   801052e5 <acquire>
80102e55:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102e58:	a1 18 57 11 80       	mov    0x80115718,%eax
80102e5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102e60:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e64:	74 0a                	je     80102e70 <kalloc+0x3b>
    kmem.freelist = r->next;
80102e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e69:	8b 00                	mov    (%eax),%eax
80102e6b:	a3 18 57 11 80       	mov    %eax,0x80115718
  if(kmem.use_lock)
80102e70:	a1 14 57 11 80       	mov    0x80115714,%eax
80102e75:	85 c0                	test   %eax,%eax
80102e77:	74 10                	je     80102e89 <kalloc+0x54>
    release(&kmem.lock);
80102e79:	83 ec 0c             	sub    $0xc,%esp
80102e7c:	68 e0 56 11 80       	push   $0x801156e0
80102e81:	e8 d1 24 00 00       	call   80105357 <release>
80102e86:	83 c4 10             	add    $0x10,%esp
  cprintf("p4Debug : kalloc returns %d %x\n", PPN(V2P(r)), V2P(r));
80102e89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e8c:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80102e92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e95:	05 00 00 00 80       	add    $0x80000000,%eax
80102e9a:	c1 e8 0c             	shr    $0xc,%eax
80102e9d:	83 ec 04             	sub    $0x4,%esp
80102ea0:	52                   	push   %edx
80102ea1:	50                   	push   %eax
80102ea2:	68 20 98 10 80       	push   $0x80109820
80102ea7:	e8 6c d5 ff ff       	call   80100418 <cprintf>
80102eac:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102eaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102eb2:	c9                   	leave  
80102eb3:	c3                   	ret    

80102eb4 <inb>:
{
80102eb4:	55                   	push   %ebp
80102eb5:	89 e5                	mov    %esp,%ebp
80102eb7:	83 ec 14             	sub    $0x14,%esp
80102eba:	8b 45 08             	mov    0x8(%ebp),%eax
80102ebd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ec1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102ec5:	89 c2                	mov    %eax,%edx
80102ec7:	ec                   	in     (%dx),%al
80102ec8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102ecb:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102ecf:	c9                   	leave  
80102ed0:	c3                   	ret    

80102ed1 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102ed1:	f3 0f 1e fb          	endbr32 
80102ed5:	55                   	push   %ebp
80102ed6:	89 e5                	mov    %esp,%ebp
80102ed8:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102edb:	6a 64                	push   $0x64
80102edd:	e8 d2 ff ff ff       	call   80102eb4 <inb>
80102ee2:	83 c4 04             	add    $0x4,%esp
80102ee5:	0f b6 c0             	movzbl %al,%eax
80102ee8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102eeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102eee:	83 e0 01             	and    $0x1,%eax
80102ef1:	85 c0                	test   %eax,%eax
80102ef3:	75 0a                	jne    80102eff <kbdgetc+0x2e>
    return -1;
80102ef5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102efa:	e9 23 01 00 00       	jmp    80103022 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102eff:	6a 60                	push   $0x60
80102f01:	e8 ae ff ff ff       	call   80102eb4 <inb>
80102f06:	83 c4 04             	add    $0x4,%esp
80102f09:	0f b6 c0             	movzbl %al,%eax
80102f0c:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102f0f:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102f16:	75 17                	jne    80102f2f <kbdgetc+0x5e>
    shift |= E0ESC;
80102f18:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80102f1d:	83 c8 40             	or     $0x40,%eax
80102f20:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
    return 0;
80102f25:	b8 00 00 00 00       	mov    $0x0,%eax
80102f2a:	e9 f3 00 00 00       	jmp    80103022 <kbdgetc+0x151>
  } else if(data & 0x80){
80102f2f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f32:	25 80 00 00 00       	and    $0x80,%eax
80102f37:	85 c0                	test   %eax,%eax
80102f39:	74 45                	je     80102f80 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102f3b:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80102f40:	83 e0 40             	and    $0x40,%eax
80102f43:	85 c0                	test   %eax,%eax
80102f45:	75 08                	jne    80102f4f <kbdgetc+0x7e>
80102f47:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f4a:	83 e0 7f             	and    $0x7f,%eax
80102f4d:	eb 03                	jmp    80102f52 <kbdgetc+0x81>
80102f4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f52:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102f55:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f58:	05 20 b0 10 80       	add    $0x8010b020,%eax
80102f5d:	0f b6 00             	movzbl (%eax),%eax
80102f60:	83 c8 40             	or     $0x40,%eax
80102f63:	0f b6 c0             	movzbl %al,%eax
80102f66:	f7 d0                	not    %eax
80102f68:	89 c2                	mov    %eax,%edx
80102f6a:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80102f6f:	21 d0                	and    %edx,%eax
80102f71:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
    return 0;
80102f76:	b8 00 00 00 00       	mov    $0x0,%eax
80102f7b:	e9 a2 00 00 00       	jmp    80103022 <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102f80:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80102f85:	83 e0 40             	and    $0x40,%eax
80102f88:	85 c0                	test   %eax,%eax
80102f8a:	74 14                	je     80102fa0 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102f8c:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102f93:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80102f98:	83 e0 bf             	and    $0xffffffbf,%eax
80102f9b:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
  }

  shift |= shiftcode[data];
80102fa0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fa3:	05 20 b0 10 80       	add    $0x8010b020,%eax
80102fa8:	0f b6 00             	movzbl (%eax),%eax
80102fab:	0f b6 d0             	movzbl %al,%edx
80102fae:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80102fb3:	09 d0                	or     %edx,%eax
80102fb5:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
  shift ^= togglecode[data];
80102fba:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fbd:	05 20 b1 10 80       	add    $0x8010b120,%eax
80102fc2:	0f b6 00             	movzbl (%eax),%eax
80102fc5:	0f b6 d0             	movzbl %al,%edx
80102fc8:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80102fcd:	31 d0                	xor    %edx,%eax
80102fcf:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102fd4:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80102fd9:	83 e0 03             	and    $0x3,%eax
80102fdc:	8b 14 85 20 b5 10 80 	mov    -0x7fef4ae0(,%eax,4),%edx
80102fe3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fe6:	01 d0                	add    %edx,%eax
80102fe8:	0f b6 00             	movzbl (%eax),%eax
80102feb:	0f b6 c0             	movzbl %al,%eax
80102fee:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102ff1:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80102ff6:	83 e0 08             	and    $0x8,%eax
80102ff9:	85 c0                	test   %eax,%eax
80102ffb:	74 22                	je     8010301f <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102ffd:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80103001:	76 0c                	jbe    8010300f <kbdgetc+0x13e>
80103003:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80103007:	77 06                	ja     8010300f <kbdgetc+0x13e>
      c += 'A' - 'a';
80103009:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
8010300d:	eb 10                	jmp    8010301f <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
8010300f:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80103013:	76 0a                	jbe    8010301f <kbdgetc+0x14e>
80103015:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80103019:	77 04                	ja     8010301f <kbdgetc+0x14e>
      c += 'a' - 'A';
8010301b:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
8010301f:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103022:	c9                   	leave  
80103023:	c3                   	ret    

80103024 <kbdintr>:

void
kbdintr(void)
{
80103024:	f3 0f 1e fb          	endbr32 
80103028:	55                   	push   %ebp
80103029:	89 e5                	mov    %esp,%ebp
8010302b:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
8010302e:	83 ec 0c             	sub    $0xc,%esp
80103031:	68 d1 2e 10 80       	push   $0x80102ed1
80103036:	e8 6d d8 ff ff       	call   801008a8 <consoleintr>
8010303b:	83 c4 10             	add    $0x10,%esp
}
8010303e:	90                   	nop
8010303f:	c9                   	leave  
80103040:	c3                   	ret    

80103041 <inb>:
{
80103041:	55                   	push   %ebp
80103042:	89 e5                	mov    %esp,%ebp
80103044:	83 ec 14             	sub    $0x14,%esp
80103047:	8b 45 08             	mov    0x8(%ebp),%eax
8010304a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010304e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103052:	89 c2                	mov    %eax,%edx
80103054:	ec                   	in     (%dx),%al
80103055:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103058:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010305c:	c9                   	leave  
8010305d:	c3                   	ret    

8010305e <outb>:
{
8010305e:	55                   	push   %ebp
8010305f:	89 e5                	mov    %esp,%ebp
80103061:	83 ec 08             	sub    $0x8,%esp
80103064:	8b 45 08             	mov    0x8(%ebp),%eax
80103067:	8b 55 0c             	mov    0xc(%ebp),%edx
8010306a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010306e:	89 d0                	mov    %edx,%eax
80103070:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103073:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103077:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010307b:	ee                   	out    %al,(%dx)
}
8010307c:	90                   	nop
8010307d:	c9                   	leave  
8010307e:	c3                   	ret    

8010307f <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
8010307f:	f3 0f 1e fb          	endbr32 
80103083:	55                   	push   %ebp
80103084:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80103086:	a1 1c 57 11 80       	mov    0x8011571c,%eax
8010308b:	8b 55 08             	mov    0x8(%ebp),%edx
8010308e:	c1 e2 02             	shl    $0x2,%edx
80103091:	01 c2                	add    %eax,%edx
80103093:	8b 45 0c             	mov    0xc(%ebp),%eax
80103096:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103098:	a1 1c 57 11 80       	mov    0x8011571c,%eax
8010309d:	83 c0 20             	add    $0x20,%eax
801030a0:	8b 00                	mov    (%eax),%eax
}
801030a2:	90                   	nop
801030a3:	5d                   	pop    %ebp
801030a4:	c3                   	ret    

801030a5 <lapicinit>:

void
lapicinit(void)
{
801030a5:	f3 0f 1e fb          	endbr32 
801030a9:	55                   	push   %ebp
801030aa:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801030ac:	a1 1c 57 11 80       	mov    0x8011571c,%eax
801030b1:	85 c0                	test   %eax,%eax
801030b3:	0f 84 0c 01 00 00    	je     801031c5 <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801030b9:	68 3f 01 00 00       	push   $0x13f
801030be:	6a 3c                	push   $0x3c
801030c0:	e8 ba ff ff ff       	call   8010307f <lapicw>
801030c5:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801030c8:	6a 0b                	push   $0xb
801030ca:	68 f8 00 00 00       	push   $0xf8
801030cf:	e8 ab ff ff ff       	call   8010307f <lapicw>
801030d4:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801030d7:	68 20 00 02 00       	push   $0x20020
801030dc:	68 c8 00 00 00       	push   $0xc8
801030e1:	e8 99 ff ff ff       	call   8010307f <lapicw>
801030e6:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
801030e9:	68 80 96 98 00       	push   $0x989680
801030ee:	68 e0 00 00 00       	push   $0xe0
801030f3:	e8 87 ff ff ff       	call   8010307f <lapicw>
801030f8:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
801030fb:	68 00 00 01 00       	push   $0x10000
80103100:	68 d4 00 00 00       	push   $0xd4
80103105:	e8 75 ff ff ff       	call   8010307f <lapicw>
8010310a:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
8010310d:	68 00 00 01 00       	push   $0x10000
80103112:	68 d8 00 00 00       	push   $0xd8
80103117:	e8 63 ff ff ff       	call   8010307f <lapicw>
8010311c:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010311f:	a1 1c 57 11 80       	mov    0x8011571c,%eax
80103124:	83 c0 30             	add    $0x30,%eax
80103127:	8b 00                	mov    (%eax),%eax
80103129:	c1 e8 10             	shr    $0x10,%eax
8010312c:	25 fc 00 00 00       	and    $0xfc,%eax
80103131:	85 c0                	test   %eax,%eax
80103133:	74 12                	je     80103147 <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
80103135:	68 00 00 01 00       	push   $0x10000
8010313a:	68 d0 00 00 00       	push   $0xd0
8010313f:	e8 3b ff ff ff       	call   8010307f <lapicw>
80103144:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103147:	6a 33                	push   $0x33
80103149:	68 dc 00 00 00       	push   $0xdc
8010314e:	e8 2c ff ff ff       	call   8010307f <lapicw>
80103153:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103156:	6a 00                	push   $0x0
80103158:	68 a0 00 00 00       	push   $0xa0
8010315d:	e8 1d ff ff ff       	call   8010307f <lapicw>
80103162:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80103165:	6a 00                	push   $0x0
80103167:	68 a0 00 00 00       	push   $0xa0
8010316c:	e8 0e ff ff ff       	call   8010307f <lapicw>
80103171:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103174:	6a 00                	push   $0x0
80103176:	6a 2c                	push   $0x2c
80103178:	e8 02 ff ff ff       	call   8010307f <lapicw>
8010317d:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103180:	6a 00                	push   $0x0
80103182:	68 c4 00 00 00       	push   $0xc4
80103187:	e8 f3 fe ff ff       	call   8010307f <lapicw>
8010318c:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
8010318f:	68 00 85 08 00       	push   $0x88500
80103194:	68 c0 00 00 00       	push   $0xc0
80103199:	e8 e1 fe ff ff       	call   8010307f <lapicw>
8010319e:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
801031a1:	90                   	nop
801031a2:	a1 1c 57 11 80       	mov    0x8011571c,%eax
801031a7:	05 00 03 00 00       	add    $0x300,%eax
801031ac:	8b 00                	mov    (%eax),%eax
801031ae:	25 00 10 00 00       	and    $0x1000,%eax
801031b3:	85 c0                	test   %eax,%eax
801031b5:	75 eb                	jne    801031a2 <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801031b7:	6a 00                	push   $0x0
801031b9:	6a 20                	push   $0x20
801031bb:	e8 bf fe ff ff       	call   8010307f <lapicw>
801031c0:	83 c4 08             	add    $0x8,%esp
801031c3:	eb 01                	jmp    801031c6 <lapicinit+0x121>
    return;
801031c5:	90                   	nop
}
801031c6:	c9                   	leave  
801031c7:	c3                   	ret    

801031c8 <lapicid>:

int
lapicid(void)
{
801031c8:	f3 0f 1e fb          	endbr32 
801031cc:	55                   	push   %ebp
801031cd:	89 e5                	mov    %esp,%ebp
  if (!lapic)
801031cf:	a1 1c 57 11 80       	mov    0x8011571c,%eax
801031d4:	85 c0                	test   %eax,%eax
801031d6:	75 07                	jne    801031df <lapicid+0x17>
    return 0;
801031d8:	b8 00 00 00 00       	mov    $0x0,%eax
801031dd:	eb 0d                	jmp    801031ec <lapicid+0x24>
  return lapic[ID] >> 24;
801031df:	a1 1c 57 11 80       	mov    0x8011571c,%eax
801031e4:	83 c0 20             	add    $0x20,%eax
801031e7:	8b 00                	mov    (%eax),%eax
801031e9:	c1 e8 18             	shr    $0x18,%eax
}
801031ec:	5d                   	pop    %ebp
801031ed:	c3                   	ret    

801031ee <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801031ee:	f3 0f 1e fb          	endbr32 
801031f2:	55                   	push   %ebp
801031f3:	89 e5                	mov    %esp,%ebp
  if(lapic)
801031f5:	a1 1c 57 11 80       	mov    0x8011571c,%eax
801031fa:	85 c0                	test   %eax,%eax
801031fc:	74 0c                	je     8010320a <lapiceoi+0x1c>
    lapicw(EOI, 0);
801031fe:	6a 00                	push   $0x0
80103200:	6a 2c                	push   $0x2c
80103202:	e8 78 fe ff ff       	call   8010307f <lapicw>
80103207:	83 c4 08             	add    $0x8,%esp
}
8010320a:	90                   	nop
8010320b:	c9                   	leave  
8010320c:	c3                   	ret    

8010320d <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010320d:	f3 0f 1e fb          	endbr32 
80103211:	55                   	push   %ebp
80103212:	89 e5                	mov    %esp,%ebp
}
80103214:	90                   	nop
80103215:	5d                   	pop    %ebp
80103216:	c3                   	ret    

80103217 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103217:	f3 0f 1e fb          	endbr32 
8010321b:	55                   	push   %ebp
8010321c:	89 e5                	mov    %esp,%ebp
8010321e:	83 ec 14             	sub    $0x14,%esp
80103221:	8b 45 08             	mov    0x8(%ebp),%eax
80103224:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103227:	6a 0f                	push   $0xf
80103229:	6a 70                	push   $0x70
8010322b:	e8 2e fe ff ff       	call   8010305e <outb>
80103230:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103233:	6a 0a                	push   $0xa
80103235:	6a 71                	push   $0x71
80103237:	e8 22 fe ff ff       	call   8010305e <outb>
8010323c:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010323f:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103246:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103249:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
8010324e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103251:	c1 e8 04             	shr    $0x4,%eax
80103254:	89 c2                	mov    %eax,%edx
80103256:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103259:	83 c0 02             	add    $0x2,%eax
8010325c:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010325f:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103263:	c1 e0 18             	shl    $0x18,%eax
80103266:	50                   	push   %eax
80103267:	68 c4 00 00 00       	push   $0xc4
8010326c:	e8 0e fe ff ff       	call   8010307f <lapicw>
80103271:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103274:	68 00 c5 00 00       	push   $0xc500
80103279:	68 c0 00 00 00       	push   $0xc0
8010327e:	e8 fc fd ff ff       	call   8010307f <lapicw>
80103283:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103286:	68 c8 00 00 00       	push   $0xc8
8010328b:	e8 7d ff ff ff       	call   8010320d <microdelay>
80103290:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80103293:	68 00 85 00 00       	push   $0x8500
80103298:	68 c0 00 00 00       	push   $0xc0
8010329d:	e8 dd fd ff ff       	call   8010307f <lapicw>
801032a2:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801032a5:	6a 64                	push   $0x64
801032a7:	e8 61 ff ff ff       	call   8010320d <microdelay>
801032ac:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801032af:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801032b6:	eb 3d                	jmp    801032f5 <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
801032b8:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801032bc:	c1 e0 18             	shl    $0x18,%eax
801032bf:	50                   	push   %eax
801032c0:	68 c4 00 00 00       	push   $0xc4
801032c5:	e8 b5 fd ff ff       	call   8010307f <lapicw>
801032ca:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801032cd:	8b 45 0c             	mov    0xc(%ebp),%eax
801032d0:	c1 e8 0c             	shr    $0xc,%eax
801032d3:	80 cc 06             	or     $0x6,%ah
801032d6:	50                   	push   %eax
801032d7:	68 c0 00 00 00       	push   $0xc0
801032dc:	e8 9e fd ff ff       	call   8010307f <lapicw>
801032e1:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801032e4:	68 c8 00 00 00       	push   $0xc8
801032e9:	e8 1f ff ff ff       	call   8010320d <microdelay>
801032ee:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
801032f1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801032f5:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801032f9:	7e bd                	jle    801032b8 <lapicstartap+0xa1>
  }
}
801032fb:	90                   	nop
801032fc:	90                   	nop
801032fd:	c9                   	leave  
801032fe:	c3                   	ret    

801032ff <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
801032ff:	f3 0f 1e fb          	endbr32 
80103303:	55                   	push   %ebp
80103304:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103306:	8b 45 08             	mov    0x8(%ebp),%eax
80103309:	0f b6 c0             	movzbl %al,%eax
8010330c:	50                   	push   %eax
8010330d:	6a 70                	push   $0x70
8010330f:	e8 4a fd ff ff       	call   8010305e <outb>
80103314:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103317:	68 c8 00 00 00       	push   $0xc8
8010331c:	e8 ec fe ff ff       	call   8010320d <microdelay>
80103321:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103324:	6a 71                	push   $0x71
80103326:	e8 16 fd ff ff       	call   80103041 <inb>
8010332b:	83 c4 04             	add    $0x4,%esp
8010332e:	0f b6 c0             	movzbl %al,%eax
}
80103331:	c9                   	leave  
80103332:	c3                   	ret    

80103333 <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
80103333:	f3 0f 1e fb          	endbr32 
80103337:	55                   	push   %ebp
80103338:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
8010333a:	6a 00                	push   $0x0
8010333c:	e8 be ff ff ff       	call   801032ff <cmos_read>
80103341:	83 c4 04             	add    $0x4,%esp
80103344:	8b 55 08             	mov    0x8(%ebp),%edx
80103347:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103349:	6a 02                	push   $0x2
8010334b:	e8 af ff ff ff       	call   801032ff <cmos_read>
80103350:	83 c4 04             	add    $0x4,%esp
80103353:	8b 55 08             	mov    0x8(%ebp),%edx
80103356:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103359:	6a 04                	push   $0x4
8010335b:	e8 9f ff ff ff       	call   801032ff <cmos_read>
80103360:	83 c4 04             	add    $0x4,%esp
80103363:	8b 55 08             	mov    0x8(%ebp),%edx
80103366:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103369:	6a 07                	push   $0x7
8010336b:	e8 8f ff ff ff       	call   801032ff <cmos_read>
80103370:	83 c4 04             	add    $0x4,%esp
80103373:	8b 55 08             	mov    0x8(%ebp),%edx
80103376:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103379:	6a 08                	push   $0x8
8010337b:	e8 7f ff ff ff       	call   801032ff <cmos_read>
80103380:	83 c4 04             	add    $0x4,%esp
80103383:	8b 55 08             	mov    0x8(%ebp),%edx
80103386:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103389:	6a 09                	push   $0x9
8010338b:	e8 6f ff ff ff       	call   801032ff <cmos_read>
80103390:	83 c4 04             	add    $0x4,%esp
80103393:	8b 55 08             	mov    0x8(%ebp),%edx
80103396:	89 42 14             	mov    %eax,0x14(%edx)
}
80103399:	90                   	nop
8010339a:	c9                   	leave  
8010339b:	c3                   	ret    

8010339c <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
8010339c:	f3 0f 1e fb          	endbr32 
801033a0:	55                   	push   %ebp
801033a1:	89 e5                	mov    %esp,%ebp
801033a3:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801033a6:	6a 0b                	push   $0xb
801033a8:	e8 52 ff ff ff       	call   801032ff <cmos_read>
801033ad:	83 c4 04             	add    $0x4,%esp
801033b0:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801033b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033b6:	83 e0 04             	and    $0x4,%eax
801033b9:	85 c0                	test   %eax,%eax
801033bb:	0f 94 c0             	sete   %al
801033be:	0f b6 c0             	movzbl %al,%eax
801033c1:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801033c4:	8d 45 d8             	lea    -0x28(%ebp),%eax
801033c7:	50                   	push   %eax
801033c8:	e8 66 ff ff ff       	call   80103333 <fill_rtcdate>
801033cd:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801033d0:	6a 0a                	push   $0xa
801033d2:	e8 28 ff ff ff       	call   801032ff <cmos_read>
801033d7:	83 c4 04             	add    $0x4,%esp
801033da:	25 80 00 00 00       	and    $0x80,%eax
801033df:	85 c0                	test   %eax,%eax
801033e1:	75 27                	jne    8010340a <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
801033e3:	8d 45 c0             	lea    -0x40(%ebp),%eax
801033e6:	50                   	push   %eax
801033e7:	e8 47 ff ff ff       	call   80103333 <fill_rtcdate>
801033ec:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801033ef:	83 ec 04             	sub    $0x4,%esp
801033f2:	6a 18                	push   $0x18
801033f4:	8d 45 c0             	lea    -0x40(%ebp),%eax
801033f7:	50                   	push   %eax
801033f8:	8d 45 d8             	lea    -0x28(%ebp),%eax
801033fb:	50                   	push   %eax
801033fc:	e8 ee 21 00 00       	call   801055ef <memcmp>
80103401:	83 c4 10             	add    $0x10,%esp
80103404:	85 c0                	test   %eax,%eax
80103406:	74 05                	je     8010340d <cmostime+0x71>
80103408:	eb ba                	jmp    801033c4 <cmostime+0x28>
        continue;
8010340a:	90                   	nop
    fill_rtcdate(&t1);
8010340b:	eb b7                	jmp    801033c4 <cmostime+0x28>
      break;
8010340d:	90                   	nop
  }

  // convert
  if(bcd) {
8010340e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103412:	0f 84 b4 00 00 00    	je     801034cc <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103418:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010341b:	c1 e8 04             	shr    $0x4,%eax
8010341e:	89 c2                	mov    %eax,%edx
80103420:	89 d0                	mov    %edx,%eax
80103422:	c1 e0 02             	shl    $0x2,%eax
80103425:	01 d0                	add    %edx,%eax
80103427:	01 c0                	add    %eax,%eax
80103429:	89 c2                	mov    %eax,%edx
8010342b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010342e:	83 e0 0f             	and    $0xf,%eax
80103431:	01 d0                	add    %edx,%eax
80103433:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103436:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103439:	c1 e8 04             	shr    $0x4,%eax
8010343c:	89 c2                	mov    %eax,%edx
8010343e:	89 d0                	mov    %edx,%eax
80103440:	c1 e0 02             	shl    $0x2,%eax
80103443:	01 d0                	add    %edx,%eax
80103445:	01 c0                	add    %eax,%eax
80103447:	89 c2                	mov    %eax,%edx
80103449:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010344c:	83 e0 0f             	and    $0xf,%eax
8010344f:	01 d0                	add    %edx,%eax
80103451:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103454:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103457:	c1 e8 04             	shr    $0x4,%eax
8010345a:	89 c2                	mov    %eax,%edx
8010345c:	89 d0                	mov    %edx,%eax
8010345e:	c1 e0 02             	shl    $0x2,%eax
80103461:	01 d0                	add    %edx,%eax
80103463:	01 c0                	add    %eax,%eax
80103465:	89 c2                	mov    %eax,%edx
80103467:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010346a:	83 e0 0f             	and    $0xf,%eax
8010346d:	01 d0                	add    %edx,%eax
8010346f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103472:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103475:	c1 e8 04             	shr    $0x4,%eax
80103478:	89 c2                	mov    %eax,%edx
8010347a:	89 d0                	mov    %edx,%eax
8010347c:	c1 e0 02             	shl    $0x2,%eax
8010347f:	01 d0                	add    %edx,%eax
80103481:	01 c0                	add    %eax,%eax
80103483:	89 c2                	mov    %eax,%edx
80103485:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103488:	83 e0 0f             	and    $0xf,%eax
8010348b:	01 d0                	add    %edx,%eax
8010348d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103490:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103493:	c1 e8 04             	shr    $0x4,%eax
80103496:	89 c2                	mov    %eax,%edx
80103498:	89 d0                	mov    %edx,%eax
8010349a:	c1 e0 02             	shl    $0x2,%eax
8010349d:	01 d0                	add    %edx,%eax
8010349f:	01 c0                	add    %eax,%eax
801034a1:	89 c2                	mov    %eax,%edx
801034a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801034a6:	83 e0 0f             	and    $0xf,%eax
801034a9:	01 d0                	add    %edx,%eax
801034ab:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801034ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034b1:	c1 e8 04             	shr    $0x4,%eax
801034b4:	89 c2                	mov    %eax,%edx
801034b6:	89 d0                	mov    %edx,%eax
801034b8:	c1 e0 02             	shl    $0x2,%eax
801034bb:	01 d0                	add    %edx,%eax
801034bd:	01 c0                	add    %eax,%eax
801034bf:	89 c2                	mov    %eax,%edx
801034c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034c4:	83 e0 0f             	and    $0xf,%eax
801034c7:	01 d0                	add    %edx,%eax
801034c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801034cc:	8b 45 08             	mov    0x8(%ebp),%eax
801034cf:	8b 55 d8             	mov    -0x28(%ebp),%edx
801034d2:	89 10                	mov    %edx,(%eax)
801034d4:	8b 55 dc             	mov    -0x24(%ebp),%edx
801034d7:	89 50 04             	mov    %edx,0x4(%eax)
801034da:	8b 55 e0             	mov    -0x20(%ebp),%edx
801034dd:	89 50 08             	mov    %edx,0x8(%eax)
801034e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801034e3:	89 50 0c             	mov    %edx,0xc(%eax)
801034e6:	8b 55 e8             	mov    -0x18(%ebp),%edx
801034e9:	89 50 10             	mov    %edx,0x10(%eax)
801034ec:	8b 55 ec             	mov    -0x14(%ebp),%edx
801034ef:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801034f2:	8b 45 08             	mov    0x8(%ebp),%eax
801034f5:	8b 40 14             	mov    0x14(%eax),%eax
801034f8:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801034fe:	8b 45 08             	mov    0x8(%ebp),%eax
80103501:	89 50 14             	mov    %edx,0x14(%eax)
}
80103504:	90                   	nop
80103505:	c9                   	leave  
80103506:	c3                   	ret    

80103507 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103507:	f3 0f 1e fb          	endbr32 
8010350b:	55                   	push   %ebp
8010350c:	89 e5                	mov    %esp,%ebp
8010350e:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103511:	83 ec 08             	sub    $0x8,%esp
80103514:	68 40 98 10 80       	push   $0x80109840
80103519:	68 20 57 11 80       	push   $0x80115720
8010351e:	e8 9c 1d 00 00       	call   801052bf <initlock>
80103523:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80103526:	83 ec 08             	sub    $0x8,%esp
80103529:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010352c:	50                   	push   %eax
8010352d:	ff 75 08             	pushl  0x8(%ebp)
80103530:	e8 d3 df ff ff       	call   80101508 <readsb>
80103535:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80103538:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010353b:	a3 54 57 11 80       	mov    %eax,0x80115754
  log.size = sb.nlog;
80103540:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103543:	a3 58 57 11 80       	mov    %eax,0x80115758
  log.dev = dev;
80103548:	8b 45 08             	mov    0x8(%ebp),%eax
8010354b:	a3 64 57 11 80       	mov    %eax,0x80115764
  recover_from_log();
80103550:	e8 bf 01 00 00       	call   80103714 <recover_from_log>
}
80103555:	90                   	nop
80103556:	c9                   	leave  
80103557:	c3                   	ret    

80103558 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80103558:	f3 0f 1e fb          	endbr32 
8010355c:	55                   	push   %ebp
8010355d:	89 e5                	mov    %esp,%ebp
8010355f:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103562:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103569:	e9 95 00 00 00       	jmp    80103603 <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010356e:	8b 15 54 57 11 80    	mov    0x80115754,%edx
80103574:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103577:	01 d0                	add    %edx,%eax
80103579:	83 c0 01             	add    $0x1,%eax
8010357c:	89 c2                	mov    %eax,%edx
8010357e:	a1 64 57 11 80       	mov    0x80115764,%eax
80103583:	83 ec 08             	sub    $0x8,%esp
80103586:	52                   	push   %edx
80103587:	50                   	push   %eax
80103588:	e8 4a cc ff ff       	call   801001d7 <bread>
8010358d:	83 c4 10             	add    $0x10,%esp
80103590:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103593:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103596:	83 c0 10             	add    $0x10,%eax
80103599:	8b 04 85 2c 57 11 80 	mov    -0x7feea8d4(,%eax,4),%eax
801035a0:	89 c2                	mov    %eax,%edx
801035a2:	a1 64 57 11 80       	mov    0x80115764,%eax
801035a7:	83 ec 08             	sub    $0x8,%esp
801035aa:	52                   	push   %edx
801035ab:	50                   	push   %eax
801035ac:	e8 26 cc ff ff       	call   801001d7 <bread>
801035b1:	83 c4 10             	add    $0x10,%esp
801035b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801035b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035ba:	8d 50 5c             	lea    0x5c(%eax),%edx
801035bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035c0:	83 c0 5c             	add    $0x5c,%eax
801035c3:	83 ec 04             	sub    $0x4,%esp
801035c6:	68 00 02 00 00       	push   $0x200
801035cb:	52                   	push   %edx
801035cc:	50                   	push   %eax
801035cd:	e8 79 20 00 00       	call   8010564b <memmove>
801035d2:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801035d5:	83 ec 0c             	sub    $0xc,%esp
801035d8:	ff 75 ec             	pushl  -0x14(%ebp)
801035db:	e8 34 cc ff ff       	call   80100214 <bwrite>
801035e0:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
801035e3:	83 ec 0c             	sub    $0xc,%esp
801035e6:	ff 75 f0             	pushl  -0x10(%ebp)
801035e9:	e8 73 cc ff ff       	call   80100261 <brelse>
801035ee:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801035f1:	83 ec 0c             	sub    $0xc,%esp
801035f4:	ff 75 ec             	pushl  -0x14(%ebp)
801035f7:	e8 65 cc ff ff       	call   80100261 <brelse>
801035fc:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801035ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103603:	a1 68 57 11 80       	mov    0x80115768,%eax
80103608:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010360b:	0f 8c 5d ff ff ff    	jl     8010356e <install_trans+0x16>
  }
}
80103611:	90                   	nop
80103612:	90                   	nop
80103613:	c9                   	leave  
80103614:	c3                   	ret    

80103615 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103615:	f3 0f 1e fb          	endbr32 
80103619:	55                   	push   %ebp
8010361a:	89 e5                	mov    %esp,%ebp
8010361c:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010361f:	a1 54 57 11 80       	mov    0x80115754,%eax
80103624:	89 c2                	mov    %eax,%edx
80103626:	a1 64 57 11 80       	mov    0x80115764,%eax
8010362b:	83 ec 08             	sub    $0x8,%esp
8010362e:	52                   	push   %edx
8010362f:	50                   	push   %eax
80103630:	e8 a2 cb ff ff       	call   801001d7 <bread>
80103635:	83 c4 10             	add    $0x10,%esp
80103638:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010363b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010363e:	83 c0 5c             	add    $0x5c,%eax
80103641:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103644:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103647:	8b 00                	mov    (%eax),%eax
80103649:	a3 68 57 11 80       	mov    %eax,0x80115768
  for (i = 0; i < log.lh.n; i++) {
8010364e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103655:	eb 1b                	jmp    80103672 <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
80103657:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010365a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010365d:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103661:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103664:	83 c2 10             	add    $0x10,%edx
80103667:	89 04 95 2c 57 11 80 	mov    %eax,-0x7feea8d4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010366e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103672:	a1 68 57 11 80       	mov    0x80115768,%eax
80103677:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010367a:	7c db                	jl     80103657 <read_head+0x42>
  }
  brelse(buf);
8010367c:	83 ec 0c             	sub    $0xc,%esp
8010367f:	ff 75 f0             	pushl  -0x10(%ebp)
80103682:	e8 da cb ff ff       	call   80100261 <brelse>
80103687:	83 c4 10             	add    $0x10,%esp
}
8010368a:	90                   	nop
8010368b:	c9                   	leave  
8010368c:	c3                   	ret    

8010368d <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010368d:	f3 0f 1e fb          	endbr32 
80103691:	55                   	push   %ebp
80103692:	89 e5                	mov    %esp,%ebp
80103694:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103697:	a1 54 57 11 80       	mov    0x80115754,%eax
8010369c:	89 c2                	mov    %eax,%edx
8010369e:	a1 64 57 11 80       	mov    0x80115764,%eax
801036a3:	83 ec 08             	sub    $0x8,%esp
801036a6:	52                   	push   %edx
801036a7:	50                   	push   %eax
801036a8:	e8 2a cb ff ff       	call   801001d7 <bread>
801036ad:	83 c4 10             	add    $0x10,%esp
801036b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801036b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036b6:	83 c0 5c             	add    $0x5c,%eax
801036b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801036bc:	8b 15 68 57 11 80    	mov    0x80115768,%edx
801036c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036c5:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801036c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036ce:	eb 1b                	jmp    801036eb <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
801036d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036d3:	83 c0 10             	add    $0x10,%eax
801036d6:	8b 0c 85 2c 57 11 80 	mov    -0x7feea8d4(,%eax,4),%ecx
801036dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801036e3:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801036e7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801036eb:	a1 68 57 11 80       	mov    0x80115768,%eax
801036f0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801036f3:	7c db                	jl     801036d0 <write_head+0x43>
  }
  bwrite(buf);
801036f5:	83 ec 0c             	sub    $0xc,%esp
801036f8:	ff 75 f0             	pushl  -0x10(%ebp)
801036fb:	e8 14 cb ff ff       	call   80100214 <bwrite>
80103700:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103703:	83 ec 0c             	sub    $0xc,%esp
80103706:	ff 75 f0             	pushl  -0x10(%ebp)
80103709:	e8 53 cb ff ff       	call   80100261 <brelse>
8010370e:	83 c4 10             	add    $0x10,%esp
}
80103711:	90                   	nop
80103712:	c9                   	leave  
80103713:	c3                   	ret    

80103714 <recover_from_log>:

static void
recover_from_log(void)
{
80103714:	f3 0f 1e fb          	endbr32 
80103718:	55                   	push   %ebp
80103719:	89 e5                	mov    %esp,%ebp
8010371b:	83 ec 08             	sub    $0x8,%esp
  read_head();
8010371e:	e8 f2 fe ff ff       	call   80103615 <read_head>
  install_trans(); // if committed, copy from log to disk
80103723:	e8 30 fe ff ff       	call   80103558 <install_trans>
  log.lh.n = 0;
80103728:	c7 05 68 57 11 80 00 	movl   $0x0,0x80115768
8010372f:	00 00 00 
  write_head(); // clear the log
80103732:	e8 56 ff ff ff       	call   8010368d <write_head>
}
80103737:	90                   	nop
80103738:	c9                   	leave  
80103739:	c3                   	ret    

8010373a <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010373a:	f3 0f 1e fb          	endbr32 
8010373e:	55                   	push   %ebp
8010373f:	89 e5                	mov    %esp,%ebp
80103741:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103744:	83 ec 0c             	sub    $0xc,%esp
80103747:	68 20 57 11 80       	push   $0x80115720
8010374c:	e8 94 1b 00 00       	call   801052e5 <acquire>
80103751:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103754:	a1 60 57 11 80       	mov    0x80115760,%eax
80103759:	85 c0                	test   %eax,%eax
8010375b:	74 17                	je     80103774 <begin_op+0x3a>
      sleep(&log, &log.lock);
8010375d:	83 ec 08             	sub    $0x8,%esp
80103760:	68 20 57 11 80       	push   $0x80115720
80103765:	68 20 57 11 80       	push   $0x80115720
8010376a:	e8 04 17 00 00       	call   80104e73 <sleep>
8010376f:	83 c4 10             	add    $0x10,%esp
80103772:	eb e0                	jmp    80103754 <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103774:	8b 0d 68 57 11 80    	mov    0x80115768,%ecx
8010377a:	a1 5c 57 11 80       	mov    0x8011575c,%eax
8010377f:	8d 50 01             	lea    0x1(%eax),%edx
80103782:	89 d0                	mov    %edx,%eax
80103784:	c1 e0 02             	shl    $0x2,%eax
80103787:	01 d0                	add    %edx,%eax
80103789:	01 c0                	add    %eax,%eax
8010378b:	01 c8                	add    %ecx,%eax
8010378d:	83 f8 1e             	cmp    $0x1e,%eax
80103790:	7e 17                	jle    801037a9 <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103792:	83 ec 08             	sub    $0x8,%esp
80103795:	68 20 57 11 80       	push   $0x80115720
8010379a:	68 20 57 11 80       	push   $0x80115720
8010379f:	e8 cf 16 00 00       	call   80104e73 <sleep>
801037a4:	83 c4 10             	add    $0x10,%esp
801037a7:	eb ab                	jmp    80103754 <begin_op+0x1a>
    } else {
      log.outstanding += 1;
801037a9:	a1 5c 57 11 80       	mov    0x8011575c,%eax
801037ae:	83 c0 01             	add    $0x1,%eax
801037b1:	a3 5c 57 11 80       	mov    %eax,0x8011575c
      release(&log.lock);
801037b6:	83 ec 0c             	sub    $0xc,%esp
801037b9:	68 20 57 11 80       	push   $0x80115720
801037be:	e8 94 1b 00 00       	call   80105357 <release>
801037c3:	83 c4 10             	add    $0x10,%esp
      break;
801037c6:	90                   	nop
    }
  }
}
801037c7:	90                   	nop
801037c8:	c9                   	leave  
801037c9:	c3                   	ret    

801037ca <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801037ca:	f3 0f 1e fb          	endbr32 
801037ce:	55                   	push   %ebp
801037cf:	89 e5                	mov    %esp,%ebp
801037d1:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801037d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801037db:	83 ec 0c             	sub    $0xc,%esp
801037de:	68 20 57 11 80       	push   $0x80115720
801037e3:	e8 fd 1a 00 00       	call   801052e5 <acquire>
801037e8:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801037eb:	a1 5c 57 11 80       	mov    0x8011575c,%eax
801037f0:	83 e8 01             	sub    $0x1,%eax
801037f3:	a3 5c 57 11 80       	mov    %eax,0x8011575c
  if(log.committing)
801037f8:	a1 60 57 11 80       	mov    0x80115760,%eax
801037fd:	85 c0                	test   %eax,%eax
801037ff:	74 0d                	je     8010380e <end_op+0x44>
    panic("log.committing");
80103801:	83 ec 0c             	sub    $0xc,%esp
80103804:	68 44 98 10 80       	push   $0x80109844
80103809:	e8 fa cd ff ff       	call   80100608 <panic>
  if(log.outstanding == 0){
8010380e:	a1 5c 57 11 80       	mov    0x8011575c,%eax
80103813:	85 c0                	test   %eax,%eax
80103815:	75 13                	jne    8010382a <end_op+0x60>
    do_commit = 1;
80103817:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010381e:	c7 05 60 57 11 80 01 	movl   $0x1,0x80115760
80103825:	00 00 00 
80103828:	eb 10                	jmp    8010383a <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
8010382a:	83 ec 0c             	sub    $0xc,%esp
8010382d:	68 20 57 11 80       	push   $0x80115720
80103832:	e8 2e 17 00 00       	call   80104f65 <wakeup>
80103837:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
8010383a:	83 ec 0c             	sub    $0xc,%esp
8010383d:	68 20 57 11 80       	push   $0x80115720
80103842:	e8 10 1b 00 00       	call   80105357 <release>
80103847:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
8010384a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010384e:	74 3f                	je     8010388f <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103850:	e8 fa 00 00 00       	call   8010394f <commit>
    acquire(&log.lock);
80103855:	83 ec 0c             	sub    $0xc,%esp
80103858:	68 20 57 11 80       	push   $0x80115720
8010385d:	e8 83 1a 00 00       	call   801052e5 <acquire>
80103862:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103865:	c7 05 60 57 11 80 00 	movl   $0x0,0x80115760
8010386c:	00 00 00 
    wakeup(&log);
8010386f:	83 ec 0c             	sub    $0xc,%esp
80103872:	68 20 57 11 80       	push   $0x80115720
80103877:	e8 e9 16 00 00       	call   80104f65 <wakeup>
8010387c:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010387f:	83 ec 0c             	sub    $0xc,%esp
80103882:	68 20 57 11 80       	push   $0x80115720
80103887:	e8 cb 1a 00 00       	call   80105357 <release>
8010388c:	83 c4 10             	add    $0x10,%esp
  }
}
8010388f:	90                   	nop
80103890:	c9                   	leave  
80103891:	c3                   	ret    

80103892 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103892:	f3 0f 1e fb          	endbr32 
80103896:	55                   	push   %ebp
80103897:	89 e5                	mov    %esp,%ebp
80103899:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010389c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038a3:	e9 95 00 00 00       	jmp    8010393d <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801038a8:	8b 15 54 57 11 80    	mov    0x80115754,%edx
801038ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038b1:	01 d0                	add    %edx,%eax
801038b3:	83 c0 01             	add    $0x1,%eax
801038b6:	89 c2                	mov    %eax,%edx
801038b8:	a1 64 57 11 80       	mov    0x80115764,%eax
801038bd:	83 ec 08             	sub    $0x8,%esp
801038c0:	52                   	push   %edx
801038c1:	50                   	push   %eax
801038c2:	e8 10 c9 ff ff       	call   801001d7 <bread>
801038c7:	83 c4 10             	add    $0x10,%esp
801038ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801038cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038d0:	83 c0 10             	add    $0x10,%eax
801038d3:	8b 04 85 2c 57 11 80 	mov    -0x7feea8d4(,%eax,4),%eax
801038da:	89 c2                	mov    %eax,%edx
801038dc:	a1 64 57 11 80       	mov    0x80115764,%eax
801038e1:	83 ec 08             	sub    $0x8,%esp
801038e4:	52                   	push   %edx
801038e5:	50                   	push   %eax
801038e6:	e8 ec c8 ff ff       	call   801001d7 <bread>
801038eb:	83 c4 10             	add    $0x10,%esp
801038ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801038f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801038f4:	8d 50 5c             	lea    0x5c(%eax),%edx
801038f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038fa:	83 c0 5c             	add    $0x5c,%eax
801038fd:	83 ec 04             	sub    $0x4,%esp
80103900:	68 00 02 00 00       	push   $0x200
80103905:	52                   	push   %edx
80103906:	50                   	push   %eax
80103907:	e8 3f 1d 00 00       	call   8010564b <memmove>
8010390c:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
8010390f:	83 ec 0c             	sub    $0xc,%esp
80103912:	ff 75 f0             	pushl  -0x10(%ebp)
80103915:	e8 fa c8 ff ff       	call   80100214 <bwrite>
8010391a:	83 c4 10             	add    $0x10,%esp
    brelse(from);
8010391d:	83 ec 0c             	sub    $0xc,%esp
80103920:	ff 75 ec             	pushl  -0x14(%ebp)
80103923:	e8 39 c9 ff ff       	call   80100261 <brelse>
80103928:	83 c4 10             	add    $0x10,%esp
    brelse(to);
8010392b:	83 ec 0c             	sub    $0xc,%esp
8010392e:	ff 75 f0             	pushl  -0x10(%ebp)
80103931:	e8 2b c9 ff ff       	call   80100261 <brelse>
80103936:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103939:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010393d:	a1 68 57 11 80       	mov    0x80115768,%eax
80103942:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103945:	0f 8c 5d ff ff ff    	jl     801038a8 <write_log+0x16>
  }
}
8010394b:	90                   	nop
8010394c:	90                   	nop
8010394d:	c9                   	leave  
8010394e:	c3                   	ret    

8010394f <commit>:

static void
commit()
{
8010394f:	f3 0f 1e fb          	endbr32 
80103953:	55                   	push   %ebp
80103954:	89 e5                	mov    %esp,%ebp
80103956:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103959:	a1 68 57 11 80       	mov    0x80115768,%eax
8010395e:	85 c0                	test   %eax,%eax
80103960:	7e 1e                	jle    80103980 <commit+0x31>
    write_log();     // Write modified blocks from cache to log
80103962:	e8 2b ff ff ff       	call   80103892 <write_log>
    write_head();    // Write header to disk -- the real commit
80103967:	e8 21 fd ff ff       	call   8010368d <write_head>
    install_trans(); // Now install writes to home locations
8010396c:	e8 e7 fb ff ff       	call   80103558 <install_trans>
    log.lh.n = 0;
80103971:	c7 05 68 57 11 80 00 	movl   $0x0,0x80115768
80103978:	00 00 00 
    write_head();    // Erase the transaction from the log
8010397b:	e8 0d fd ff ff       	call   8010368d <write_head>
  }
}
80103980:	90                   	nop
80103981:	c9                   	leave  
80103982:	c3                   	ret    

80103983 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103983:	f3 0f 1e fb          	endbr32 
80103987:	55                   	push   %ebp
80103988:	89 e5                	mov    %esp,%ebp
8010398a:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010398d:	a1 68 57 11 80       	mov    0x80115768,%eax
80103992:	83 f8 1d             	cmp    $0x1d,%eax
80103995:	7f 12                	jg     801039a9 <log_write+0x26>
80103997:	a1 68 57 11 80       	mov    0x80115768,%eax
8010399c:	8b 15 58 57 11 80    	mov    0x80115758,%edx
801039a2:	83 ea 01             	sub    $0x1,%edx
801039a5:	39 d0                	cmp    %edx,%eax
801039a7:	7c 0d                	jl     801039b6 <log_write+0x33>
    panic("too big a transaction");
801039a9:	83 ec 0c             	sub    $0xc,%esp
801039ac:	68 53 98 10 80       	push   $0x80109853
801039b1:	e8 52 cc ff ff       	call   80100608 <panic>
  if (log.outstanding < 1)
801039b6:	a1 5c 57 11 80       	mov    0x8011575c,%eax
801039bb:	85 c0                	test   %eax,%eax
801039bd:	7f 0d                	jg     801039cc <log_write+0x49>
    panic("log_write outside of trans");
801039bf:	83 ec 0c             	sub    $0xc,%esp
801039c2:	68 69 98 10 80       	push   $0x80109869
801039c7:	e8 3c cc ff ff       	call   80100608 <panic>

  acquire(&log.lock);
801039cc:	83 ec 0c             	sub    $0xc,%esp
801039cf:	68 20 57 11 80       	push   $0x80115720
801039d4:	e8 0c 19 00 00       	call   801052e5 <acquire>
801039d9:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801039dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039e3:	eb 1d                	jmp    80103a02 <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801039e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039e8:	83 c0 10             	add    $0x10,%eax
801039eb:	8b 04 85 2c 57 11 80 	mov    -0x7feea8d4(,%eax,4),%eax
801039f2:	89 c2                	mov    %eax,%edx
801039f4:	8b 45 08             	mov    0x8(%ebp),%eax
801039f7:	8b 40 08             	mov    0x8(%eax),%eax
801039fa:	39 c2                	cmp    %eax,%edx
801039fc:	74 10                	je     80103a0e <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
801039fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a02:	a1 68 57 11 80       	mov    0x80115768,%eax
80103a07:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a0a:	7c d9                	jl     801039e5 <log_write+0x62>
80103a0c:	eb 01                	jmp    80103a0f <log_write+0x8c>
      break;
80103a0e:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103a0f:	8b 45 08             	mov    0x8(%ebp),%eax
80103a12:	8b 40 08             	mov    0x8(%eax),%eax
80103a15:	89 c2                	mov    %eax,%edx
80103a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a1a:	83 c0 10             	add    $0x10,%eax
80103a1d:	89 14 85 2c 57 11 80 	mov    %edx,-0x7feea8d4(,%eax,4)
  if (i == log.lh.n)
80103a24:	a1 68 57 11 80       	mov    0x80115768,%eax
80103a29:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a2c:	75 0d                	jne    80103a3b <log_write+0xb8>
    log.lh.n++;
80103a2e:	a1 68 57 11 80       	mov    0x80115768,%eax
80103a33:	83 c0 01             	add    $0x1,%eax
80103a36:	a3 68 57 11 80       	mov    %eax,0x80115768
  b->flags |= B_DIRTY; // prevent eviction
80103a3b:	8b 45 08             	mov    0x8(%ebp),%eax
80103a3e:	8b 00                	mov    (%eax),%eax
80103a40:	83 c8 04             	or     $0x4,%eax
80103a43:	89 c2                	mov    %eax,%edx
80103a45:	8b 45 08             	mov    0x8(%ebp),%eax
80103a48:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103a4a:	83 ec 0c             	sub    $0xc,%esp
80103a4d:	68 20 57 11 80       	push   $0x80115720
80103a52:	e8 00 19 00 00       	call   80105357 <release>
80103a57:	83 c4 10             	add    $0x10,%esp
}
80103a5a:	90                   	nop
80103a5b:	c9                   	leave  
80103a5c:	c3                   	ret    

80103a5d <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103a5d:	55                   	push   %ebp
80103a5e:	89 e5                	mov    %esp,%ebp
80103a60:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103a63:	8b 55 08             	mov    0x8(%ebp),%edx
80103a66:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a69:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103a6c:	f0 87 02             	lock xchg %eax,(%edx)
80103a6f:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103a72:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103a75:	c9                   	leave  
80103a76:	c3                   	ret    

80103a77 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103a77:	f3 0f 1e fb          	endbr32 
80103a7b:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103a7f:	83 e4 f0             	and    $0xfffffff0,%esp
80103a82:	ff 71 fc             	pushl  -0x4(%ecx)
80103a85:	55                   	push   %ebp
80103a86:	89 e5                	mov    %esp,%ebp
80103a88:	51                   	push   %ecx
80103a89:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103a8c:	83 ec 08             	sub    $0x8,%esp
80103a8f:	68 00 00 40 80       	push   $0x80400000
80103a94:	68 48 96 11 80       	push   $0x80119648
80103a99:	e8 52 f2 ff ff       	call   80102cf0 <kinit1>
80103a9e:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103aa1:	e8 c1 46 00 00       	call   80108167 <kvmalloc>
  mpinit();        // detect other processors
80103aa6:	e8 d9 03 00 00       	call   80103e84 <mpinit>
  lapicinit();     // interrupt controller
80103aab:	e8 f5 f5 ff ff       	call   801030a5 <lapicinit>
  seginit();       // segment descriptors
80103ab0:	e8 6a 41 00 00       	call   80107c1f <seginit>
  picinit();       // disable pic
80103ab5:	e8 35 05 00 00       	call   80103fef <picinit>
  ioapicinit();    // another interrupt controller
80103aba:	e8 44 f1 ff ff       	call   80102c03 <ioapicinit>
  consoleinit();   // console hardware
80103abf:	e8 1d d1 ff ff       	call   80100be1 <consoleinit>
  uartinit();      // serial port
80103ac4:	e8 df 34 00 00       	call   80106fa8 <uartinit>
  pinit();         // process table
80103ac9:	e8 6e 09 00 00       	call   8010443c <pinit>
  tvinit();        // trap vectors
80103ace:	e8 6d 30 00 00       	call   80106b40 <tvinit>
  binit();         // buffer cache
80103ad3:	e8 5c c5 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103ad8:	e8 00 d6 ff ff       	call   801010dd <fileinit>
  ideinit();       // disk 
80103add:	e8 e0 ec ff ff       	call   801027c2 <ideinit>
  startothers();   // start other processors
80103ae2:	e8 88 00 00 00       	call   80103b6f <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103ae7:	83 ec 08             	sub    $0x8,%esp
80103aea:	68 00 00 00 8e       	push   $0x8e000000
80103aef:	68 00 00 40 80       	push   $0x80400000
80103af4:	e8 34 f2 ff ff       	call   80102d2d <kinit2>
80103af9:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103afc:	e8 34 0b 00 00       	call   80104635 <userinit>
  mpmain();        // finish this processor's setup
80103b01:	e8 1e 00 00 00       	call   80103b24 <mpmain>

80103b06 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103b06:	f3 0f 1e fb          	endbr32 
80103b0a:	55                   	push   %ebp
80103b0b:	89 e5                	mov    %esp,%ebp
80103b0d:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103b10:	e8 6e 46 00 00       	call   80108183 <switchkvm>
  seginit();
80103b15:	e8 05 41 00 00       	call   80107c1f <seginit>
  lapicinit();
80103b1a:	e8 86 f5 ff ff       	call   801030a5 <lapicinit>
  mpmain();
80103b1f:	e8 00 00 00 00       	call   80103b24 <mpmain>

80103b24 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103b24:	f3 0f 1e fb          	endbr32 
80103b28:	55                   	push   %ebp
80103b29:	89 e5                	mov    %esp,%ebp
80103b2b:	53                   	push   %ebx
80103b2c:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103b2f:	e8 2a 09 00 00       	call   8010445e <cpuid>
80103b34:	89 c3                	mov    %eax,%ebx
80103b36:	e8 23 09 00 00       	call   8010445e <cpuid>
80103b3b:	83 ec 04             	sub    $0x4,%esp
80103b3e:	53                   	push   %ebx
80103b3f:	50                   	push   %eax
80103b40:	68 84 98 10 80       	push   $0x80109884
80103b45:	e8 ce c8 ff ff       	call   80100418 <cprintf>
80103b4a:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103b4d:	e8 68 31 00 00       	call   80106cba <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103b52:	e8 26 09 00 00       	call   8010447d <mycpu>
80103b57:	05 a0 00 00 00       	add    $0xa0,%eax
80103b5c:	83 ec 08             	sub    $0x8,%esp
80103b5f:	6a 01                	push   $0x1
80103b61:	50                   	push   %eax
80103b62:	e8 f6 fe ff ff       	call   80103a5d <xchg>
80103b67:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103b6a:	e8 00 11 00 00       	call   80104c6f <scheduler>

80103b6f <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103b6f:	f3 0f 1e fb          	endbr32 
80103b73:	55                   	push   %ebp
80103b74:	89 e5                	mov    %esp,%ebp
80103b76:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103b79:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103b80:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103b85:	83 ec 04             	sub    $0x4,%esp
80103b88:	50                   	push   %eax
80103b89:	68 0c d5 10 80       	push   $0x8010d50c
80103b8e:	ff 75 f0             	pushl  -0x10(%ebp)
80103b91:	e8 b5 1a 00 00       	call   8010564b <memmove>
80103b96:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103b99:	c7 45 f4 20 58 11 80 	movl   $0x80115820,-0xc(%ebp)
80103ba0:	eb 79                	jmp    80103c1b <startothers+0xac>
    if(c == mycpu())  // We've started already.
80103ba2:	e8 d6 08 00 00       	call   8010447d <mycpu>
80103ba7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103baa:	74 67                	je     80103c13 <startothers+0xa4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103bac:	e8 84 f2 ff ff       	call   80102e35 <kalloc>
80103bb1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103bb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bb7:	83 e8 04             	sub    $0x4,%eax
80103bba:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103bbd:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103bc3:	89 10                	mov    %edx,(%eax)
    *(void(**)(void))(code-8) = mpenter;
80103bc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bc8:	83 e8 08             	sub    $0x8,%eax
80103bcb:	c7 00 06 3b 10 80    	movl   $0x80103b06,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103bd1:	b8 00 c0 10 80       	mov    $0x8010c000,%eax
80103bd6:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103bdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bdf:	83 e8 0c             	sub    $0xc,%eax
80103be2:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
80103be4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103be7:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf0:	0f b6 00             	movzbl (%eax),%eax
80103bf3:	0f b6 c0             	movzbl %al,%eax
80103bf6:	83 ec 08             	sub    $0x8,%esp
80103bf9:	52                   	push   %edx
80103bfa:	50                   	push   %eax
80103bfb:	e8 17 f6 ff ff       	call   80103217 <lapicstartap>
80103c00:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103c03:	90                   	nop
80103c04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c07:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103c0d:	85 c0                	test   %eax,%eax
80103c0f:	74 f3                	je     80103c04 <startothers+0x95>
80103c11:	eb 01                	jmp    80103c14 <startothers+0xa5>
      continue;
80103c13:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103c14:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103c1b:	a1 a0 5d 11 80       	mov    0x80115da0,%eax
80103c20:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103c26:	05 20 58 11 80       	add    $0x80115820,%eax
80103c2b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103c2e:	0f 82 6e ff ff ff    	jb     80103ba2 <startothers+0x33>
      ;
  }
}
80103c34:	90                   	nop
80103c35:	90                   	nop
80103c36:	c9                   	leave  
80103c37:	c3                   	ret    

80103c38 <inb>:
{
80103c38:	55                   	push   %ebp
80103c39:	89 e5                	mov    %esp,%ebp
80103c3b:	83 ec 14             	sub    $0x14,%esp
80103c3e:	8b 45 08             	mov    0x8(%ebp),%eax
80103c41:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103c45:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103c49:	89 c2                	mov    %eax,%edx
80103c4b:	ec                   	in     (%dx),%al
80103c4c:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103c4f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103c53:	c9                   	leave  
80103c54:	c3                   	ret    

80103c55 <outb>:
{
80103c55:	55                   	push   %ebp
80103c56:	89 e5                	mov    %esp,%ebp
80103c58:	83 ec 08             	sub    $0x8,%esp
80103c5b:	8b 45 08             	mov    0x8(%ebp),%eax
80103c5e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c61:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103c65:	89 d0                	mov    %edx,%eax
80103c67:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103c6a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103c6e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103c72:	ee                   	out    %al,(%dx)
}
80103c73:	90                   	nop
80103c74:	c9                   	leave  
80103c75:	c3                   	ret    

80103c76 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103c76:	f3 0f 1e fb          	endbr32 
80103c7a:	55                   	push   %ebp
80103c7b:	89 e5                	mov    %esp,%ebp
80103c7d:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103c80:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103c87:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103c8e:	eb 15                	jmp    80103ca5 <sum+0x2f>
    sum += addr[i];
80103c90:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103c93:	8b 45 08             	mov    0x8(%ebp),%eax
80103c96:	01 d0                	add    %edx,%eax
80103c98:	0f b6 00             	movzbl (%eax),%eax
80103c9b:	0f b6 c0             	movzbl %al,%eax
80103c9e:	01 45 f8             	add    %eax,-0x8(%ebp)
  for(i=0; i<len; i++)
80103ca1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103ca5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103ca8:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103cab:	7c e3                	jl     80103c90 <sum+0x1a>
  return sum;
80103cad:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103cb0:	c9                   	leave  
80103cb1:	c3                   	ret    

80103cb2 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103cb2:	f3 0f 1e fb          	endbr32 
80103cb6:	55                   	push   %ebp
80103cb7:	89 e5                	mov    %esp,%ebp
80103cb9:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103cbc:	8b 45 08             	mov    0x8(%ebp),%eax
80103cbf:	05 00 00 00 80       	add    $0x80000000,%eax
80103cc4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103cc7:	8b 55 0c             	mov    0xc(%ebp),%edx
80103cca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ccd:	01 d0                	add    %edx,%eax
80103ccf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103cd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cd8:	eb 36                	jmp    80103d10 <mpsearch1+0x5e>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103cda:	83 ec 04             	sub    $0x4,%esp
80103cdd:	6a 04                	push   $0x4
80103cdf:	68 98 98 10 80       	push   $0x80109898
80103ce4:	ff 75 f4             	pushl  -0xc(%ebp)
80103ce7:	e8 03 19 00 00       	call   801055ef <memcmp>
80103cec:	83 c4 10             	add    $0x10,%esp
80103cef:	85 c0                	test   %eax,%eax
80103cf1:	75 19                	jne    80103d0c <mpsearch1+0x5a>
80103cf3:	83 ec 08             	sub    $0x8,%esp
80103cf6:	6a 10                	push   $0x10
80103cf8:	ff 75 f4             	pushl  -0xc(%ebp)
80103cfb:	e8 76 ff ff ff       	call   80103c76 <sum>
80103d00:	83 c4 10             	add    $0x10,%esp
80103d03:	84 c0                	test   %al,%al
80103d05:	75 05                	jne    80103d0c <mpsearch1+0x5a>
      return (struct mp*)p;
80103d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d0a:	eb 11                	jmp    80103d1d <mpsearch1+0x6b>
  for(p = addr; p < e; p += sizeof(struct mp))
80103d0c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d13:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103d16:	72 c2                	jb     80103cda <mpsearch1+0x28>
  return 0;
80103d18:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d1d:	c9                   	leave  
80103d1e:	c3                   	ret    

80103d1f <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103d1f:	f3 0f 1e fb          	endbr32 
80103d23:	55                   	push   %ebp
80103d24:	89 e5                	mov    %esp,%ebp
80103d26:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103d29:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103d30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d33:	83 c0 0f             	add    $0xf,%eax
80103d36:	0f b6 00             	movzbl (%eax),%eax
80103d39:	0f b6 c0             	movzbl %al,%eax
80103d3c:	c1 e0 08             	shl    $0x8,%eax
80103d3f:	89 c2                	mov    %eax,%edx
80103d41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d44:	83 c0 0e             	add    $0xe,%eax
80103d47:	0f b6 00             	movzbl (%eax),%eax
80103d4a:	0f b6 c0             	movzbl %al,%eax
80103d4d:	09 d0                	or     %edx,%eax
80103d4f:	c1 e0 04             	shl    $0x4,%eax
80103d52:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103d55:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d59:	74 21                	je     80103d7c <mpsearch+0x5d>
    if((mp = mpsearch1(p, 1024)))
80103d5b:	83 ec 08             	sub    $0x8,%esp
80103d5e:	68 00 04 00 00       	push   $0x400
80103d63:	ff 75 f0             	pushl  -0x10(%ebp)
80103d66:	e8 47 ff ff ff       	call   80103cb2 <mpsearch1>
80103d6b:	83 c4 10             	add    $0x10,%esp
80103d6e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d71:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d75:	74 51                	je     80103dc8 <mpsearch+0xa9>
      return mp;
80103d77:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d7a:	eb 61                	jmp    80103ddd <mpsearch+0xbe>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103d7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d7f:	83 c0 14             	add    $0x14,%eax
80103d82:	0f b6 00             	movzbl (%eax),%eax
80103d85:	0f b6 c0             	movzbl %al,%eax
80103d88:	c1 e0 08             	shl    $0x8,%eax
80103d8b:	89 c2                	mov    %eax,%edx
80103d8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d90:	83 c0 13             	add    $0x13,%eax
80103d93:	0f b6 00             	movzbl (%eax),%eax
80103d96:	0f b6 c0             	movzbl %al,%eax
80103d99:	09 d0                	or     %edx,%eax
80103d9b:	c1 e0 0a             	shl    $0xa,%eax
80103d9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103da1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103da4:	2d 00 04 00 00       	sub    $0x400,%eax
80103da9:	83 ec 08             	sub    $0x8,%esp
80103dac:	68 00 04 00 00       	push   $0x400
80103db1:	50                   	push   %eax
80103db2:	e8 fb fe ff ff       	call   80103cb2 <mpsearch1>
80103db7:	83 c4 10             	add    $0x10,%esp
80103dba:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103dbd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103dc1:	74 05                	je     80103dc8 <mpsearch+0xa9>
      return mp;
80103dc3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103dc6:	eb 15                	jmp    80103ddd <mpsearch+0xbe>
  }
  return mpsearch1(0xF0000, 0x10000);
80103dc8:	83 ec 08             	sub    $0x8,%esp
80103dcb:	68 00 00 01 00       	push   $0x10000
80103dd0:	68 00 00 0f 00       	push   $0xf0000
80103dd5:	e8 d8 fe ff ff       	call   80103cb2 <mpsearch1>
80103dda:	83 c4 10             	add    $0x10,%esp
}
80103ddd:	c9                   	leave  
80103dde:	c3                   	ret    

80103ddf <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103ddf:	f3 0f 1e fb          	endbr32 
80103de3:	55                   	push   %ebp
80103de4:	89 e5                	mov    %esp,%ebp
80103de6:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103de9:	e8 31 ff ff ff       	call   80103d1f <mpsearch>
80103dee:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103df1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103df5:	74 0a                	je     80103e01 <mpconfig+0x22>
80103df7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dfa:	8b 40 04             	mov    0x4(%eax),%eax
80103dfd:	85 c0                	test   %eax,%eax
80103dff:	75 07                	jne    80103e08 <mpconfig+0x29>
    return 0;
80103e01:	b8 00 00 00 00       	mov    $0x0,%eax
80103e06:	eb 7a                	jmp    80103e82 <mpconfig+0xa3>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e0b:	8b 40 04             	mov    0x4(%eax),%eax
80103e0e:	05 00 00 00 80       	add    $0x80000000,%eax
80103e13:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103e16:	83 ec 04             	sub    $0x4,%esp
80103e19:	6a 04                	push   $0x4
80103e1b:	68 9d 98 10 80       	push   $0x8010989d
80103e20:	ff 75 f0             	pushl  -0x10(%ebp)
80103e23:	e8 c7 17 00 00       	call   801055ef <memcmp>
80103e28:	83 c4 10             	add    $0x10,%esp
80103e2b:	85 c0                	test   %eax,%eax
80103e2d:	74 07                	je     80103e36 <mpconfig+0x57>
    return 0;
80103e2f:	b8 00 00 00 00       	mov    $0x0,%eax
80103e34:	eb 4c                	jmp    80103e82 <mpconfig+0xa3>
  if(conf->version != 1 && conf->version != 4)
80103e36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e39:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103e3d:	3c 01                	cmp    $0x1,%al
80103e3f:	74 12                	je     80103e53 <mpconfig+0x74>
80103e41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e44:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103e48:	3c 04                	cmp    $0x4,%al
80103e4a:	74 07                	je     80103e53 <mpconfig+0x74>
    return 0;
80103e4c:	b8 00 00 00 00       	mov    $0x0,%eax
80103e51:	eb 2f                	jmp    80103e82 <mpconfig+0xa3>
  if(sum((uchar*)conf, conf->length) != 0)
80103e53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e56:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103e5a:	0f b7 c0             	movzwl %ax,%eax
80103e5d:	83 ec 08             	sub    $0x8,%esp
80103e60:	50                   	push   %eax
80103e61:	ff 75 f0             	pushl  -0x10(%ebp)
80103e64:	e8 0d fe ff ff       	call   80103c76 <sum>
80103e69:	83 c4 10             	add    $0x10,%esp
80103e6c:	84 c0                	test   %al,%al
80103e6e:	74 07                	je     80103e77 <mpconfig+0x98>
    return 0;
80103e70:	b8 00 00 00 00       	mov    $0x0,%eax
80103e75:	eb 0b                	jmp    80103e82 <mpconfig+0xa3>
  *pmp = mp;
80103e77:	8b 45 08             	mov    0x8(%ebp),%eax
80103e7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e7d:	89 10                	mov    %edx,(%eax)
  return conf;
80103e7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103e82:	c9                   	leave  
80103e83:	c3                   	ret    

80103e84 <mpinit>:

void
mpinit(void)
{
80103e84:	f3 0f 1e fb          	endbr32 
80103e88:	55                   	push   %ebp
80103e89:	89 e5                	mov    %esp,%ebp
80103e8b:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103e8e:	83 ec 0c             	sub    $0xc,%esp
80103e91:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103e94:	50                   	push   %eax
80103e95:	e8 45 ff ff ff       	call   80103ddf <mpconfig>
80103e9a:	83 c4 10             	add    $0x10,%esp
80103e9d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ea0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ea4:	75 0d                	jne    80103eb3 <mpinit+0x2f>
    panic("Expect to run on an SMP");
80103ea6:	83 ec 0c             	sub    $0xc,%esp
80103ea9:	68 a2 98 10 80       	push   $0x801098a2
80103eae:	e8 55 c7 ff ff       	call   80100608 <panic>
  ismp = 1;
80103eb3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103eba:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ebd:	8b 40 24             	mov    0x24(%eax),%eax
80103ec0:	a3 1c 57 11 80       	mov    %eax,0x8011571c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103ec5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ec8:	83 c0 2c             	add    $0x2c,%eax
80103ecb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ece:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ed1:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103ed5:	0f b7 d0             	movzwl %ax,%edx
80103ed8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103edb:	01 d0                	add    %edx,%eax
80103edd:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103ee0:	e9 8c 00 00 00       	jmp    80103f71 <mpinit+0xed>
    switch(*p){
80103ee5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ee8:	0f b6 00             	movzbl (%eax),%eax
80103eeb:	0f b6 c0             	movzbl %al,%eax
80103eee:	83 f8 04             	cmp    $0x4,%eax
80103ef1:	7f 76                	jg     80103f69 <mpinit+0xe5>
80103ef3:	83 f8 03             	cmp    $0x3,%eax
80103ef6:	7d 6b                	jge    80103f63 <mpinit+0xdf>
80103ef8:	83 f8 02             	cmp    $0x2,%eax
80103efb:	74 4e                	je     80103f4b <mpinit+0xc7>
80103efd:	83 f8 02             	cmp    $0x2,%eax
80103f00:	7f 67                	jg     80103f69 <mpinit+0xe5>
80103f02:	85 c0                	test   %eax,%eax
80103f04:	74 07                	je     80103f0d <mpinit+0x89>
80103f06:	83 f8 01             	cmp    $0x1,%eax
80103f09:	74 58                	je     80103f63 <mpinit+0xdf>
80103f0b:	eb 5c                	jmp    80103f69 <mpinit+0xe5>
    case MPPROC:
      proc = (struct mpproc*)p;
80103f0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f10:	89 45 e0             	mov    %eax,-0x20(%ebp)
      if(ncpu < NCPU) {
80103f13:	a1 a0 5d 11 80       	mov    0x80115da0,%eax
80103f18:	83 f8 07             	cmp    $0x7,%eax
80103f1b:	7f 28                	jg     80103f45 <mpinit+0xc1>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103f1d:	8b 15 a0 5d 11 80    	mov    0x80115da0,%edx
80103f23:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f26:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103f2a:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80103f30:	81 c2 20 58 11 80    	add    $0x80115820,%edx
80103f36:	88 02                	mov    %al,(%edx)
        ncpu++;
80103f38:	a1 a0 5d 11 80       	mov    0x80115da0,%eax
80103f3d:	83 c0 01             	add    $0x1,%eax
80103f40:	a3 a0 5d 11 80       	mov    %eax,0x80115da0
      }
      p += sizeof(struct mpproc);
80103f45:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103f49:	eb 26                	jmp    80103f71 <mpinit+0xed>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103f4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f4e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103f51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103f54:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103f58:	a2 00 58 11 80       	mov    %al,0x80115800
      p += sizeof(struct mpioapic);
80103f5d:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f61:	eb 0e                	jmp    80103f71 <mpinit+0xed>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103f63:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f67:	eb 08                	jmp    80103f71 <mpinit+0xed>
    default:
      ismp = 0;
80103f69:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103f70:	90                   	nop
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103f71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f74:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103f77:	0f 82 68 ff ff ff    	jb     80103ee5 <mpinit+0x61>
    }
  }
  if(!ismp)
80103f7d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103f81:	75 0d                	jne    80103f90 <mpinit+0x10c>
    panic("Didn't find a suitable machine");
80103f83:	83 ec 0c             	sub    $0xc,%esp
80103f86:	68 bc 98 10 80       	push   $0x801098bc
80103f8b:	e8 78 c6 ff ff       	call   80100608 <panic>

  if(mp->imcrp){
80103f90:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f93:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103f97:	84 c0                	test   %al,%al
80103f99:	74 30                	je     80103fcb <mpinit+0x147>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103f9b:	83 ec 08             	sub    $0x8,%esp
80103f9e:	6a 70                	push   $0x70
80103fa0:	6a 22                	push   $0x22
80103fa2:	e8 ae fc ff ff       	call   80103c55 <outb>
80103fa7:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103faa:	83 ec 0c             	sub    $0xc,%esp
80103fad:	6a 23                	push   $0x23
80103faf:	e8 84 fc ff ff       	call   80103c38 <inb>
80103fb4:	83 c4 10             	add    $0x10,%esp
80103fb7:	83 c8 01             	or     $0x1,%eax
80103fba:	0f b6 c0             	movzbl %al,%eax
80103fbd:	83 ec 08             	sub    $0x8,%esp
80103fc0:	50                   	push   %eax
80103fc1:	6a 23                	push   $0x23
80103fc3:	e8 8d fc ff ff       	call   80103c55 <outb>
80103fc8:	83 c4 10             	add    $0x10,%esp
  }
}
80103fcb:	90                   	nop
80103fcc:	c9                   	leave  
80103fcd:	c3                   	ret    

80103fce <outb>:
{
80103fce:	55                   	push   %ebp
80103fcf:	89 e5                	mov    %esp,%ebp
80103fd1:	83 ec 08             	sub    $0x8,%esp
80103fd4:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd7:	8b 55 0c             	mov    0xc(%ebp),%edx
80103fda:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103fde:	89 d0                	mov    %edx,%eax
80103fe0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103fe3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103fe7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103feb:	ee                   	out    %al,(%dx)
}
80103fec:	90                   	nop
80103fed:	c9                   	leave  
80103fee:	c3                   	ret    

80103fef <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103fef:	f3 0f 1e fb          	endbr32 
80103ff3:	55                   	push   %ebp
80103ff4:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103ff6:	68 ff 00 00 00       	push   $0xff
80103ffb:	6a 21                	push   $0x21
80103ffd:	e8 cc ff ff ff       	call   80103fce <outb>
80104002:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80104005:	68 ff 00 00 00       	push   $0xff
8010400a:	68 a1 00 00 00       	push   $0xa1
8010400f:	e8 ba ff ff ff       	call   80103fce <outb>
80104014:	83 c4 08             	add    $0x8,%esp
}
80104017:	90                   	nop
80104018:	c9                   	leave  
80104019:	c3                   	ret    

8010401a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010401a:	f3 0f 1e fb          	endbr32 
8010401e:	55                   	push   %ebp
8010401f:	89 e5                	mov    %esp,%ebp
80104021:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80104024:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010402b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010402e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104034:	8b 45 0c             	mov    0xc(%ebp),%eax
80104037:	8b 10                	mov    (%eax),%edx
80104039:	8b 45 08             	mov    0x8(%ebp),%eax
8010403c:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010403e:	e8 bc d0 ff ff       	call   801010ff <filealloc>
80104043:	8b 55 08             	mov    0x8(%ebp),%edx
80104046:	89 02                	mov    %eax,(%edx)
80104048:	8b 45 08             	mov    0x8(%ebp),%eax
8010404b:	8b 00                	mov    (%eax),%eax
8010404d:	85 c0                	test   %eax,%eax
8010404f:	0f 84 c8 00 00 00    	je     8010411d <pipealloc+0x103>
80104055:	e8 a5 d0 ff ff       	call   801010ff <filealloc>
8010405a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010405d:	89 02                	mov    %eax,(%edx)
8010405f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104062:	8b 00                	mov    (%eax),%eax
80104064:	85 c0                	test   %eax,%eax
80104066:	0f 84 b1 00 00 00    	je     8010411d <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010406c:	e8 c4 ed ff ff       	call   80102e35 <kalloc>
80104071:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104074:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104078:	0f 84 a2 00 00 00    	je     80104120 <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
8010407e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104081:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104088:	00 00 00 
  p->writeopen = 1;
8010408b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010408e:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104095:	00 00 00 
  p->nwrite = 0;
80104098:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010409b:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801040a2:	00 00 00 
  p->nread = 0;
801040a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a8:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801040af:	00 00 00 
  initlock(&p->lock, "pipe");
801040b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b5:	83 ec 08             	sub    $0x8,%esp
801040b8:	68 db 98 10 80       	push   $0x801098db
801040bd:	50                   	push   %eax
801040be:	e8 fc 11 00 00       	call   801052bf <initlock>
801040c3:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801040c6:	8b 45 08             	mov    0x8(%ebp),%eax
801040c9:	8b 00                	mov    (%eax),%eax
801040cb:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801040d1:	8b 45 08             	mov    0x8(%ebp),%eax
801040d4:	8b 00                	mov    (%eax),%eax
801040d6:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801040da:	8b 45 08             	mov    0x8(%ebp),%eax
801040dd:	8b 00                	mov    (%eax),%eax
801040df:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801040e3:	8b 45 08             	mov    0x8(%ebp),%eax
801040e6:	8b 00                	mov    (%eax),%eax
801040e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040eb:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
801040ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801040f1:	8b 00                	mov    (%eax),%eax
801040f3:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801040f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801040fc:	8b 00                	mov    (%eax),%eax
801040fe:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104102:	8b 45 0c             	mov    0xc(%ebp),%eax
80104105:	8b 00                	mov    (%eax),%eax
80104107:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010410b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010410e:	8b 00                	mov    (%eax),%eax
80104110:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104113:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104116:	b8 00 00 00 00       	mov    $0x0,%eax
8010411b:	eb 51                	jmp    8010416e <pipealloc+0x154>
    goto bad;
8010411d:	90                   	nop
8010411e:	eb 01                	jmp    80104121 <pipealloc+0x107>
    goto bad;
80104120:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80104121:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104125:	74 0e                	je     80104135 <pipealloc+0x11b>
    kfree((char*)p);
80104127:	83 ec 0c             	sub    $0xc,%esp
8010412a:	ff 75 f4             	pushl  -0xc(%ebp)
8010412d:	e8 65 ec ff ff       	call   80102d97 <kfree>
80104132:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80104135:	8b 45 08             	mov    0x8(%ebp),%eax
80104138:	8b 00                	mov    (%eax),%eax
8010413a:	85 c0                	test   %eax,%eax
8010413c:	74 11                	je     8010414f <pipealloc+0x135>
    fileclose(*f0);
8010413e:	8b 45 08             	mov    0x8(%ebp),%eax
80104141:	8b 00                	mov    (%eax),%eax
80104143:	83 ec 0c             	sub    $0xc,%esp
80104146:	50                   	push   %eax
80104147:	e8 79 d0 ff ff       	call   801011c5 <fileclose>
8010414c:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010414f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104152:	8b 00                	mov    (%eax),%eax
80104154:	85 c0                	test   %eax,%eax
80104156:	74 11                	je     80104169 <pipealloc+0x14f>
    fileclose(*f1);
80104158:	8b 45 0c             	mov    0xc(%ebp),%eax
8010415b:	8b 00                	mov    (%eax),%eax
8010415d:	83 ec 0c             	sub    $0xc,%esp
80104160:	50                   	push   %eax
80104161:	e8 5f d0 ff ff       	call   801011c5 <fileclose>
80104166:	83 c4 10             	add    $0x10,%esp
  return -1;
80104169:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010416e:	c9                   	leave  
8010416f:	c3                   	ret    

80104170 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104170:	f3 0f 1e fb          	endbr32 
80104174:	55                   	push   %ebp
80104175:	89 e5                	mov    %esp,%ebp
80104177:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
8010417a:	8b 45 08             	mov    0x8(%ebp),%eax
8010417d:	83 ec 0c             	sub    $0xc,%esp
80104180:	50                   	push   %eax
80104181:	e8 5f 11 00 00       	call   801052e5 <acquire>
80104186:	83 c4 10             	add    $0x10,%esp
  if(writable){
80104189:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010418d:	74 23                	je     801041b2 <pipeclose+0x42>
    p->writeopen = 0;
8010418f:	8b 45 08             	mov    0x8(%ebp),%eax
80104192:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104199:	00 00 00 
    wakeup(&p->nread);
8010419c:	8b 45 08             	mov    0x8(%ebp),%eax
8010419f:	05 34 02 00 00       	add    $0x234,%eax
801041a4:	83 ec 0c             	sub    $0xc,%esp
801041a7:	50                   	push   %eax
801041a8:	e8 b8 0d 00 00       	call   80104f65 <wakeup>
801041ad:	83 c4 10             	add    $0x10,%esp
801041b0:	eb 21                	jmp    801041d3 <pipeclose+0x63>
  } else {
    p->readopen = 0;
801041b2:	8b 45 08             	mov    0x8(%ebp),%eax
801041b5:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801041bc:	00 00 00 
    wakeup(&p->nwrite);
801041bf:	8b 45 08             	mov    0x8(%ebp),%eax
801041c2:	05 38 02 00 00       	add    $0x238,%eax
801041c7:	83 ec 0c             	sub    $0xc,%esp
801041ca:	50                   	push   %eax
801041cb:	e8 95 0d 00 00       	call   80104f65 <wakeup>
801041d0:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
801041d3:	8b 45 08             	mov    0x8(%ebp),%eax
801041d6:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041dc:	85 c0                	test   %eax,%eax
801041de:	75 2c                	jne    8010420c <pipeclose+0x9c>
801041e0:	8b 45 08             	mov    0x8(%ebp),%eax
801041e3:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801041e9:	85 c0                	test   %eax,%eax
801041eb:	75 1f                	jne    8010420c <pipeclose+0x9c>
    release(&p->lock);
801041ed:	8b 45 08             	mov    0x8(%ebp),%eax
801041f0:	83 ec 0c             	sub    $0xc,%esp
801041f3:	50                   	push   %eax
801041f4:	e8 5e 11 00 00       	call   80105357 <release>
801041f9:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
801041fc:	83 ec 0c             	sub    $0xc,%esp
801041ff:	ff 75 08             	pushl  0x8(%ebp)
80104202:	e8 90 eb ff ff       	call   80102d97 <kfree>
80104207:	83 c4 10             	add    $0x10,%esp
8010420a:	eb 10                	jmp    8010421c <pipeclose+0xac>
  } else
    release(&p->lock);
8010420c:	8b 45 08             	mov    0x8(%ebp),%eax
8010420f:	83 ec 0c             	sub    $0xc,%esp
80104212:	50                   	push   %eax
80104213:	e8 3f 11 00 00       	call   80105357 <release>
80104218:	83 c4 10             	add    $0x10,%esp
}
8010421b:	90                   	nop
8010421c:	90                   	nop
8010421d:	c9                   	leave  
8010421e:	c3                   	ret    

8010421f <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010421f:	f3 0f 1e fb          	endbr32 
80104223:	55                   	push   %ebp
80104224:	89 e5                	mov    %esp,%ebp
80104226:	53                   	push   %ebx
80104227:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
8010422a:	8b 45 08             	mov    0x8(%ebp),%eax
8010422d:	83 ec 0c             	sub    $0xc,%esp
80104230:	50                   	push   %eax
80104231:	e8 af 10 00 00       	call   801052e5 <acquire>
80104236:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104239:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104240:	e9 ad 00 00 00       	jmp    801042f2 <pipewrite+0xd3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80104245:	8b 45 08             	mov    0x8(%ebp),%eax
80104248:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010424e:	85 c0                	test   %eax,%eax
80104250:	74 0c                	je     8010425e <pipewrite+0x3f>
80104252:	e8 a2 02 00 00       	call   801044f9 <myproc>
80104257:	8b 40 24             	mov    0x24(%eax),%eax
8010425a:	85 c0                	test   %eax,%eax
8010425c:	74 19                	je     80104277 <pipewrite+0x58>
        release(&p->lock);
8010425e:	8b 45 08             	mov    0x8(%ebp),%eax
80104261:	83 ec 0c             	sub    $0xc,%esp
80104264:	50                   	push   %eax
80104265:	e8 ed 10 00 00       	call   80105357 <release>
8010426a:	83 c4 10             	add    $0x10,%esp
        return -1;
8010426d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104272:	e9 a9 00 00 00       	jmp    80104320 <pipewrite+0x101>
      }
      wakeup(&p->nread);
80104277:	8b 45 08             	mov    0x8(%ebp),%eax
8010427a:	05 34 02 00 00       	add    $0x234,%eax
8010427f:	83 ec 0c             	sub    $0xc,%esp
80104282:	50                   	push   %eax
80104283:	e8 dd 0c 00 00       	call   80104f65 <wakeup>
80104288:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010428b:	8b 45 08             	mov    0x8(%ebp),%eax
8010428e:	8b 55 08             	mov    0x8(%ebp),%edx
80104291:	81 c2 38 02 00 00    	add    $0x238,%edx
80104297:	83 ec 08             	sub    $0x8,%esp
8010429a:	50                   	push   %eax
8010429b:	52                   	push   %edx
8010429c:	e8 d2 0b 00 00       	call   80104e73 <sleep>
801042a1:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801042a4:	8b 45 08             	mov    0x8(%ebp),%eax
801042a7:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801042ad:	8b 45 08             	mov    0x8(%ebp),%eax
801042b0:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801042b6:	05 00 02 00 00       	add    $0x200,%eax
801042bb:	39 c2                	cmp    %eax,%edx
801042bd:	74 86                	je     80104245 <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801042bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801042c5:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801042c8:	8b 45 08             	mov    0x8(%ebp),%eax
801042cb:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042d1:	8d 48 01             	lea    0x1(%eax),%ecx
801042d4:	8b 55 08             	mov    0x8(%ebp),%edx
801042d7:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801042dd:	25 ff 01 00 00       	and    $0x1ff,%eax
801042e2:	89 c1                	mov    %eax,%ecx
801042e4:	0f b6 13             	movzbl (%ebx),%edx
801042e7:	8b 45 08             	mov    0x8(%ebp),%eax
801042ea:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
801042ee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801042f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042f5:	3b 45 10             	cmp    0x10(%ebp),%eax
801042f8:	7c aa                	jl     801042a4 <pipewrite+0x85>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801042fa:	8b 45 08             	mov    0x8(%ebp),%eax
801042fd:	05 34 02 00 00       	add    $0x234,%eax
80104302:	83 ec 0c             	sub    $0xc,%esp
80104305:	50                   	push   %eax
80104306:	e8 5a 0c 00 00       	call   80104f65 <wakeup>
8010430b:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
8010430e:	8b 45 08             	mov    0x8(%ebp),%eax
80104311:	83 ec 0c             	sub    $0xc,%esp
80104314:	50                   	push   %eax
80104315:	e8 3d 10 00 00       	call   80105357 <release>
8010431a:	83 c4 10             	add    $0x10,%esp
  return n;
8010431d:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104320:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104323:	c9                   	leave  
80104324:	c3                   	ret    

80104325 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104325:	f3 0f 1e fb          	endbr32 
80104329:	55                   	push   %ebp
8010432a:	89 e5                	mov    %esp,%ebp
8010432c:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
8010432f:	8b 45 08             	mov    0x8(%ebp),%eax
80104332:	83 ec 0c             	sub    $0xc,%esp
80104335:	50                   	push   %eax
80104336:	e8 aa 0f 00 00       	call   801052e5 <acquire>
8010433b:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010433e:	eb 3e                	jmp    8010437e <piperead+0x59>
    if(myproc()->killed){
80104340:	e8 b4 01 00 00       	call   801044f9 <myproc>
80104345:	8b 40 24             	mov    0x24(%eax),%eax
80104348:	85 c0                	test   %eax,%eax
8010434a:	74 19                	je     80104365 <piperead+0x40>
      release(&p->lock);
8010434c:	8b 45 08             	mov    0x8(%ebp),%eax
8010434f:	83 ec 0c             	sub    $0xc,%esp
80104352:	50                   	push   %eax
80104353:	e8 ff 0f 00 00       	call   80105357 <release>
80104358:	83 c4 10             	add    $0x10,%esp
      return -1;
8010435b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104360:	e9 be 00 00 00       	jmp    80104423 <piperead+0xfe>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104365:	8b 45 08             	mov    0x8(%ebp),%eax
80104368:	8b 55 08             	mov    0x8(%ebp),%edx
8010436b:	81 c2 34 02 00 00    	add    $0x234,%edx
80104371:	83 ec 08             	sub    $0x8,%esp
80104374:	50                   	push   %eax
80104375:	52                   	push   %edx
80104376:	e8 f8 0a 00 00       	call   80104e73 <sleep>
8010437b:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010437e:	8b 45 08             	mov    0x8(%ebp),%eax
80104381:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104387:	8b 45 08             	mov    0x8(%ebp),%eax
8010438a:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104390:	39 c2                	cmp    %eax,%edx
80104392:	75 0d                	jne    801043a1 <piperead+0x7c>
80104394:	8b 45 08             	mov    0x8(%ebp),%eax
80104397:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010439d:	85 c0                	test   %eax,%eax
8010439f:	75 9f                	jne    80104340 <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801043a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801043a8:	eb 48                	jmp    801043f2 <piperead+0xcd>
    if(p->nread == p->nwrite)
801043aa:	8b 45 08             	mov    0x8(%ebp),%eax
801043ad:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801043b3:	8b 45 08             	mov    0x8(%ebp),%eax
801043b6:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043bc:	39 c2                	cmp    %eax,%edx
801043be:	74 3c                	je     801043fc <piperead+0xd7>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801043c0:	8b 45 08             	mov    0x8(%ebp),%eax
801043c3:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801043c9:	8d 48 01             	lea    0x1(%eax),%ecx
801043cc:	8b 55 08             	mov    0x8(%ebp),%edx
801043cf:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801043d5:	25 ff 01 00 00       	and    $0x1ff,%eax
801043da:	89 c1                	mov    %eax,%ecx
801043dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043df:	8b 45 0c             	mov    0xc(%ebp),%eax
801043e2:	01 c2                	add    %eax,%edx
801043e4:	8b 45 08             	mov    0x8(%ebp),%eax
801043e7:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
801043ec:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801043ee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801043f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f5:	3b 45 10             	cmp    0x10(%ebp),%eax
801043f8:	7c b0                	jl     801043aa <piperead+0x85>
801043fa:	eb 01                	jmp    801043fd <piperead+0xd8>
      break;
801043fc:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801043fd:	8b 45 08             	mov    0x8(%ebp),%eax
80104400:	05 38 02 00 00       	add    $0x238,%eax
80104405:	83 ec 0c             	sub    $0xc,%esp
80104408:	50                   	push   %eax
80104409:	e8 57 0b 00 00       	call   80104f65 <wakeup>
8010440e:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104411:	8b 45 08             	mov    0x8(%ebp),%eax
80104414:	83 ec 0c             	sub    $0xc,%esp
80104417:	50                   	push   %eax
80104418:	e8 3a 0f 00 00       	call   80105357 <release>
8010441d:	83 c4 10             	add    $0x10,%esp
  return i;
80104420:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104423:	c9                   	leave  
80104424:	c3                   	ret    

80104425 <readeflags>:
{
80104425:	55                   	push   %ebp
80104426:	89 e5                	mov    %esp,%ebp
80104428:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010442b:	9c                   	pushf  
8010442c:	58                   	pop    %eax
8010442d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104430:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104433:	c9                   	leave  
80104434:	c3                   	ret    

80104435 <sti>:
{
80104435:	55                   	push   %ebp
80104436:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104438:	fb                   	sti    
}
80104439:	90                   	nop
8010443a:	5d                   	pop    %ebp
8010443b:	c3                   	ret    

8010443c <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010443c:	f3 0f 1e fb          	endbr32 
80104440:	55                   	push   %ebp
80104441:	89 e5                	mov    %esp,%ebp
80104443:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104446:	83 ec 08             	sub    $0x8,%esp
80104449:	68 e0 98 10 80       	push   $0x801098e0
8010444e:	68 c0 5d 11 80       	push   $0x80115dc0
80104453:	e8 67 0e 00 00       	call   801052bf <initlock>
80104458:	83 c4 10             	add    $0x10,%esp
}
8010445b:	90                   	nop
8010445c:	c9                   	leave  
8010445d:	c3                   	ret    

8010445e <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
8010445e:	f3 0f 1e fb          	endbr32 
80104462:	55                   	push   %ebp
80104463:	89 e5                	mov    %esp,%ebp
80104465:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80104468:	e8 10 00 00 00       	call   8010447d <mycpu>
8010446d:	2d 20 58 11 80       	sub    $0x80115820,%eax
80104472:	c1 f8 04             	sar    $0x4,%eax
80104475:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
8010447b:	c9                   	leave  
8010447c:	c3                   	ret    

8010447d <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
8010447d:	f3 0f 1e fb          	endbr32 
80104481:	55                   	push   %ebp
80104482:	89 e5                	mov    %esp,%ebp
80104484:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
80104487:	e8 99 ff ff ff       	call   80104425 <readeflags>
8010448c:	25 00 02 00 00       	and    $0x200,%eax
80104491:	85 c0                	test   %eax,%eax
80104493:	74 0d                	je     801044a2 <mycpu+0x25>
    panic("mycpu called with interrupts enabled\n");
80104495:	83 ec 0c             	sub    $0xc,%esp
80104498:	68 e8 98 10 80       	push   $0x801098e8
8010449d:	e8 66 c1 ff ff       	call   80100608 <panic>
  
  apicid = lapicid();
801044a2:	e8 21 ed ff ff       	call   801031c8 <lapicid>
801044a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801044aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801044b1:	eb 2d                	jmp    801044e0 <mycpu+0x63>
    if (cpus[i].apicid == apicid)
801044b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b6:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801044bc:	05 20 58 11 80       	add    $0x80115820,%eax
801044c1:	0f b6 00             	movzbl (%eax),%eax
801044c4:	0f b6 c0             	movzbl %al,%eax
801044c7:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801044ca:	75 10                	jne    801044dc <mycpu+0x5f>
      return &cpus[i];
801044cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044cf:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801044d5:	05 20 58 11 80       	add    $0x80115820,%eax
801044da:	eb 1b                	jmp    801044f7 <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
801044dc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801044e0:	a1 a0 5d 11 80       	mov    0x80115da0,%eax
801044e5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801044e8:	7c c9                	jl     801044b3 <mycpu+0x36>
  }
  panic("unknown apicid\n");
801044ea:	83 ec 0c             	sub    $0xc,%esp
801044ed:	68 0e 99 10 80       	push   $0x8010990e
801044f2:	e8 11 c1 ff ff       	call   80100608 <panic>
}
801044f7:	c9                   	leave  
801044f8:	c3                   	ret    

801044f9 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
801044f9:	f3 0f 1e fb          	endbr32 
801044fd:	55                   	push   %ebp
801044fe:	89 e5                	mov    %esp,%ebp
80104500:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80104503:	e8 69 0f 00 00       	call   80105471 <pushcli>
  c = mycpu();
80104508:	e8 70 ff ff ff       	call   8010447d <mycpu>
8010450d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80104510:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104513:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104519:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
8010451c:	e8 a1 0f 00 00       	call   801054c2 <popcli>
  return p;
80104521:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80104524:	c9                   	leave  
80104525:	c3                   	ret    

80104526 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104526:	f3 0f 1e fb          	endbr32 
8010452a:	55                   	push   %ebp
8010452b:	89 e5                	mov    %esp,%ebp
8010452d:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104530:	83 ec 0c             	sub    $0xc,%esp
80104533:	68 c0 5d 11 80       	push   $0x80115dc0
80104538:	e8 a8 0d 00 00       	call   801052e5 <acquire>
8010453d:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104540:	c7 45 f4 f4 5d 11 80 	movl   $0x80115df4,-0xc(%ebp)
80104547:	eb 11                	jmp    8010455a <allocproc+0x34>
    if(p->state == UNUSED)
80104549:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454c:	8b 40 0c             	mov    0xc(%eax),%eax
8010454f:	85 c0                	test   %eax,%eax
80104551:	74 2a                	je     8010457d <allocproc+0x57>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104553:	81 45 f4 c0 00 00 00 	addl   $0xc0,-0xc(%ebp)
8010455a:	81 7d f4 f4 8d 11 80 	cmpl   $0x80118df4,-0xc(%ebp)
80104561:	72 e6                	jb     80104549 <allocproc+0x23>
      goto found;

  release(&ptable.lock);
80104563:	83 ec 0c             	sub    $0xc,%esp
80104566:	68 c0 5d 11 80       	push   $0x80115dc0
8010456b:	e8 e7 0d 00 00       	call   80105357 <release>
80104570:	83 c4 10             	add    $0x10,%esp
  return 0;
80104573:	b8 00 00 00 00       	mov    $0x0,%eax
80104578:	e9 b6 00 00 00       	jmp    80104633 <allocproc+0x10d>
      goto found;
8010457d:	90                   	nop
8010457e:	f3 0f 1e fb          	endbr32 

found:
  p->state = EMBRYO;
80104582:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104585:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
8010458c:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80104591:	8d 50 01             	lea    0x1(%eax),%edx
80104594:	89 15 00 d0 10 80    	mov    %edx,0x8010d000
8010459a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010459d:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
801045a0:	83 ec 0c             	sub    $0xc,%esp
801045a3:	68 c0 5d 11 80       	push   $0x80115dc0
801045a8:	e8 aa 0d 00 00       	call   80105357 <release>
801045ad:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801045b0:	e8 80 e8 ff ff       	call   80102e35 <kalloc>
801045b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045b8:	89 42 08             	mov    %eax,0x8(%edx)
801045bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045be:	8b 40 08             	mov    0x8(%eax),%eax
801045c1:	85 c0                	test   %eax,%eax
801045c3:	75 11                	jne    801045d6 <allocproc+0xb0>
    p->state = UNUSED;
801045c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801045cf:	b8 00 00 00 00       	mov    $0x0,%eax
801045d4:	eb 5d                	jmp    80104633 <allocproc+0x10d>
  }
  sp = p->kstack + KSTACKSIZE;
801045d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d9:	8b 40 08             	mov    0x8(%eax),%eax
801045dc:	05 00 10 00 00       	add    $0x1000,%eax
801045e1:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801045e4:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801045e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045eb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045ee:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801045f1:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801045f5:	ba fa 6a 10 80       	mov    $0x80106afa,%edx
801045fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045fd:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801045ff:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104603:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104606:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104609:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010460c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010460f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104612:	83 ec 04             	sub    $0x4,%esp
80104615:	6a 14                	push   $0x14
80104617:	6a 00                	push   $0x0
80104619:	50                   	push   %eax
8010461a:	e8 65 0f 00 00       	call   80105584 <memset>
8010461f:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104622:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104625:	8b 40 1c             	mov    0x1c(%eax),%eax
80104628:	ba 29 4e 10 80       	mov    $0x80104e29,%edx
8010462d:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104630:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104633:	c9                   	leave  
80104634:	c3                   	ret    

80104635 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104635:	f3 0f 1e fb          	endbr32 
80104639:	55                   	push   %ebp
8010463a:	89 e5                	mov    %esp,%ebp
8010463c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
8010463f:	e8 e2 fe ff ff       	call   80104526 <allocproc>
80104644:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80104647:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010464a:	a3 40 d6 10 80       	mov    %eax,0x8010d640
  if((p->pgdir = setupkvm()) == 0)
8010464f:	e8 76 3a 00 00       	call   801080ca <setupkvm>
80104654:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104657:	89 42 04             	mov    %eax,0x4(%edx)
8010465a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010465d:	8b 40 04             	mov    0x4(%eax),%eax
80104660:	85 c0                	test   %eax,%eax
80104662:	75 0d                	jne    80104671 <userinit+0x3c>
    panic("userinit: out of memory?");
80104664:	83 ec 0c             	sub    $0xc,%esp
80104667:	68 1e 99 10 80       	push   $0x8010991e
8010466c:	e8 97 bf ff ff       	call   80100608 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104671:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104676:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104679:	8b 40 04             	mov    0x4(%eax),%eax
8010467c:	83 ec 04             	sub    $0x4,%esp
8010467f:	52                   	push   %edx
80104680:	68 e0 d4 10 80       	push   $0x8010d4e0
80104685:	50                   	push   %eax
80104686:	e8 b8 3c 00 00       	call   80108343 <inituvm>
8010468b:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
8010468e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104691:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104697:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010469a:	8b 40 18             	mov    0x18(%eax),%eax
8010469d:	83 ec 04             	sub    $0x4,%esp
801046a0:	6a 4c                	push   $0x4c
801046a2:	6a 00                	push   $0x0
801046a4:	50                   	push   %eax
801046a5:	e8 da 0e 00 00       	call   80105584 <memset>
801046aa:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801046ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b0:	8b 40 18             	mov    0x18(%eax),%eax
801046b3:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801046b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046bc:	8b 40 18             	mov    0x18(%eax),%eax
801046bf:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801046c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c8:	8b 50 18             	mov    0x18(%eax),%edx
801046cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ce:	8b 40 18             	mov    0x18(%eax),%eax
801046d1:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801046d5:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801046d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046dc:	8b 50 18             	mov    0x18(%eax),%edx
801046df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e2:	8b 40 18             	mov    0x18(%eax),%eax
801046e5:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801046e9:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801046ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f0:	8b 40 18             	mov    0x18(%eax),%eax
801046f3:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801046fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046fd:	8b 40 18             	mov    0x18(%eax),%eax
80104700:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104707:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010470a:	8b 40 18             	mov    0x18(%eax),%eax
8010470d:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104714:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104717:	83 c0 6c             	add    $0x6c,%eax
8010471a:	83 ec 04             	sub    $0x4,%esp
8010471d:	6a 10                	push   $0x10
8010471f:	68 37 99 10 80       	push   $0x80109937
80104724:	50                   	push   %eax
80104725:	e8 75 10 00 00       	call   8010579f <safestrcpy>
8010472a:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
8010472d:	83 ec 0c             	sub    $0xc,%esp
80104730:	68 40 99 10 80       	push   $0x80109940
80104735:	e8 76 df ff ff       	call   801026b0 <namei>
8010473a:	83 c4 10             	add    $0x10,%esp
8010473d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104740:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignpent to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80104743:	83 ec 0c             	sub    $0xc,%esp
80104746:	68 c0 5d 11 80       	push   $0x80115dc0
8010474b:	e8 95 0b 00 00       	call   801052e5 <acquire>
80104750:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80104753:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104756:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010475d:	83 ec 0c             	sub    $0xc,%esp
80104760:	68 c0 5d 11 80       	push   $0x80115dc0
80104765:	e8 ed 0b 00 00       	call   80105357 <release>
8010476a:	83 c4 10             	add    $0x10,%esp
}
8010476d:	90                   	nop
8010476e:	c9                   	leave  
8010476f:	c3                   	ret    

80104770 <growproc>:
//
// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104770:	f3 0f 1e fb          	endbr32 
80104774:	55                   	push   %ebp
80104775:	89 e5                	mov    %esp,%ebp
80104777:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  struct proc *curproc = myproc();
8010477a:	e8 7a fd ff ff       	call   801044f9 <myproc>
8010477f:	89 45 e8             	mov    %eax,-0x18(%ebp)

  sz = curproc->sz;
80104782:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104785:	8b 00                	mov    (%eax),%eax
80104787:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010478a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010478e:	7e 64                	jle    801047f4 <growproc+0x84>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104790:	8b 55 08             	mov    0x8(%ebp),%edx
80104793:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104796:	01 c2                	add    %eax,%edx
80104798:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010479b:	8b 40 04             	mov    0x4(%eax),%eax
8010479e:	83 ec 04             	sub    $0x4,%esp
801047a1:	52                   	push   %edx
801047a2:	ff 75 f4             	pushl  -0xc(%ebp)
801047a5:	50                   	push   %eax
801047a6:	e8 dd 3c 00 00       	call   80108488 <allocuvm>
801047ab:	83 c4 10             	add    $0x10,%esp
801047ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
801047b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047b5:	75 0a                	jne    801047c1 <growproc+0x51>
      return -1;
801047b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047bc:	e9 e1 00 00 00       	jmp    801048a2 <growproc+0x132>
    uint a;
    a = 0;
801047c1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for ( ; a<sz+n; a+=PGSIZE){
801047c8:	eb 18                	jmp    801047e2 <growproc+0x72>
    	
      mencrypt((char*)a, 1);
801047ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047cd:	83 ec 08             	sub    $0x8,%esp
801047d0:	6a 01                	push   $0x1
801047d2:	50                   	push   %eax
801047d3:	e8 55 48 00 00       	call   8010902d <mencrypt>
801047d8:	83 c4 10             	add    $0x10,%esp
    for ( ; a<sz+n; a+=PGSIZE){
801047db:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
801047e2:	8b 55 08             	mov    0x8(%ebp),%edx
801047e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e8:	01 d0                	add    %edx,%eax
801047ea:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801047ed:	72 db                	jb     801047ca <growproc+0x5a>
801047ef:	e9 93 00 00 00       	jmp    80104887 <growproc+0x117>
 // mencrypt(0, t-2);
 // mencrypt((char*) ((t-1)*PGSIZE),1);
 // mencrypt((char*) ((t)*PGSIZE),n/PGSIZE);


  } else if(n < 0){
801047f4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801047f8:	0f 89 89 00 00 00    	jns    80104887 <growproc+0x117>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801047fe:	8b 55 08             	mov    0x8(%ebp),%edx
80104801:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104804:	01 c2                	add    %eax,%edx
80104806:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104809:	8b 40 04             	mov    0x4(%eax),%eax
8010480c:	83 ec 04             	sub    $0x4,%esp
8010480f:	52                   	push   %edx
80104810:	ff 75 f4             	pushl  -0xc(%ebp)
80104813:	50                   	push   %eax
80104814:	e8 78 3d 00 00       	call   80108591 <deallocuvm>
80104819:	83 c4 10             	add    $0x10,%esp
8010481c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010481f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104823:	75 62                	jne    80104887 <growproc+0x117>
    {
	    for(int i=0; i<n; i++)
80104825:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010482c:	eb 4a                	jmp    80104878 <growproc+0x108>
	    {
		    int ind = inQ(curproc, (char* )(sz + i*PGSIZE));
8010482e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104831:	c1 e0 0c             	shl    $0xc,%eax
80104834:	89 c2                	mov    %eax,%edx
80104836:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104839:	01 d0                	add    %edx,%eax
8010483b:	83 ec 08             	sub    $0x8,%esp
8010483e:	50                   	push   %eax
8010483f:	ff 75 e8             	pushl  -0x18(%ebp)
80104842:	e8 04 42 00 00       	call   80108a4b <inQ>
80104847:	83 c4 10             	add    $0x10,%esp
8010484a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	    	    if(ind!=-1)
8010484d:	83 7d e4 ff          	cmpl   $0xffffffff,-0x1c(%ebp)
80104851:	74 21                	je     80104874 <growproc+0x104>
		    {curproc->clock[ind].addr=0;
80104853:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104856:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104859:	83 c2 0e             	add    $0xe,%edx
8010485c:	c7 44 d0 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,8)
80104863:	00 
		    	    cprintf("==========change head ??\n");}
80104864:	83 ec 0c             	sub    $0xc,%esp
80104867:	68 42 99 10 80       	push   $0x80109942
8010486c:	e8 a7 bb ff ff       	call   80100418 <cprintf>
80104871:	83 c4 10             	add    $0x10,%esp
	    for(int i=0; i<n; i++)
80104874:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80104878:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010487b:	3b 45 08             	cmp    0x8(%ebp),%eax
8010487e:	7c ae                	jl     8010482e <growproc+0xbe>
	    }
	    return -1;}
80104880:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104885:	eb 1b                	jmp    801048a2 <growproc+0x132>
  }
  curproc->sz = sz;
80104887:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010488a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010488d:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
8010488f:	83 ec 0c             	sub    $0xc,%esp
80104892:	ff 75 e8             	pushl  -0x18(%ebp)
80104895:	e8 06 39 00 00       	call   801081a0 <switchuvm>
8010489a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010489d:	b8 00 00 00 00       	mov    $0x0,%eax
}
801048a2:	c9                   	leave  
801048a3:	c3                   	ret    

801048a4 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801048a4:	f3 0f 1e fb          	endbr32 
801048a8:	55                   	push   %ebp
801048a9:	89 e5                	mov    %esp,%ebp
801048ab:	57                   	push   %edi
801048ac:	56                   	push   %esi
801048ad:	53                   	push   %ebx
801048ae:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
801048b1:	e8 43 fc ff ff       	call   801044f9 <myproc>
801048b6:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
801048b9:	e8 68 fc ff ff       	call   80104526 <allocproc>
801048be:	89 45 dc             	mov    %eax,-0x24(%ebp)
801048c1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801048c5:	75 0a                	jne    801048d1 <fork+0x2d>
    return -1;
801048c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048cc:	e9 48 01 00 00       	jmp    80104a19 <fork+0x175>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801048d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048d4:	8b 10                	mov    (%eax),%edx
801048d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048d9:	8b 40 04             	mov    0x4(%eax),%eax
801048dc:	83 ec 08             	sub    $0x8,%esp
801048df:	52                   	push   %edx
801048e0:	50                   	push   %eax
801048e1:	e8 59 3e 00 00       	call   8010873f <copyuvm>
801048e6:	83 c4 10             	add    $0x10,%esp
801048e9:	8b 55 dc             	mov    -0x24(%ebp),%edx
801048ec:	89 42 04             	mov    %eax,0x4(%edx)
801048ef:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048f2:	8b 40 04             	mov    0x4(%eax),%eax
801048f5:	85 c0                	test   %eax,%eax
801048f7:	75 30                	jne    80104929 <fork+0x85>
    kfree(np->kstack);
801048f9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048fc:	8b 40 08             	mov    0x8(%eax),%eax
801048ff:	83 ec 0c             	sub    $0xc,%esp
80104902:	50                   	push   %eax
80104903:	e8 8f e4 ff ff       	call   80102d97 <kfree>
80104908:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
8010490b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010490e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104915:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104918:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010491f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104924:	e9 f0 00 00 00       	jmp    80104a19 <fork+0x175>
  }
  np->sz = curproc->sz;
80104929:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010492c:	8b 10                	mov    (%eax),%edx
8010492e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104931:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80104933:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104936:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104939:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
8010493c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010493f:	8b 48 18             	mov    0x18(%eax),%ecx
80104942:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104945:	8b 40 18             	mov    0x18(%eax),%eax
80104948:	89 c2                	mov    %eax,%edx
8010494a:	89 cb                	mov    %ecx,%ebx
8010494c:	b8 13 00 00 00       	mov    $0x13,%eax
80104951:	89 d7                	mov    %edx,%edi
80104953:	89 de                	mov    %ebx,%esi
80104955:	89 c1                	mov    %eax,%ecx
80104957:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104959:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010495c:	8b 40 18             	mov    0x18(%eax),%eax
8010495f:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104966:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010496d:	eb 3b                	jmp    801049aa <fork+0x106>
    if(curproc->ofile[i])
8010496f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104972:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104975:	83 c2 08             	add    $0x8,%edx
80104978:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010497c:	85 c0                	test   %eax,%eax
8010497e:	74 26                	je     801049a6 <fork+0x102>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104980:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104983:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104986:	83 c2 08             	add    $0x8,%edx
80104989:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010498d:	83 ec 0c             	sub    $0xc,%esp
80104990:	50                   	push   %eax
80104991:	e8 da c7 ff ff       	call   80101170 <filedup>
80104996:	83 c4 10             	add    $0x10,%esp
80104999:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010499c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010499f:	83 c1 08             	add    $0x8,%ecx
801049a2:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
801049a6:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801049aa:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801049ae:	7e bf                	jle    8010496f <fork+0xcb>
  np->cwd = idup(curproc->cwd);
801049b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049b3:	8b 40 68             	mov    0x68(%eax),%eax
801049b6:	83 ec 0c             	sub    $0xc,%esp
801049b9:	50                   	push   %eax
801049ba:	e8 48 d1 ff ff       	call   80101b07 <idup>
801049bf:	83 c4 10             	add    $0x10,%esp
801049c2:	8b 55 dc             	mov    -0x24(%ebp),%edx
801049c5:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801049c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049cb:	8d 50 6c             	lea    0x6c(%eax),%edx
801049ce:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049d1:	83 c0 6c             	add    $0x6c,%eax
801049d4:	83 ec 04             	sub    $0x4,%esp
801049d7:	6a 10                	push   $0x10
801049d9:	52                   	push   %edx
801049da:	50                   	push   %eax
801049db:	e8 bf 0d 00 00       	call   8010579f <safestrcpy>
801049e0:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
801049e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049e6:	8b 40 10             	mov    0x10(%eax),%eax
801049e9:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
801049ec:	83 ec 0c             	sub    $0xc,%esp
801049ef:	68 c0 5d 11 80       	push   $0x80115dc0
801049f4:	e8 ec 08 00 00       	call   801052e5 <acquire>
801049f9:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
801049fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049ff:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104a06:	83 ec 0c             	sub    $0xc,%esp
80104a09:	68 c0 5d 11 80       	push   $0x80115dc0
80104a0e:	e8 44 09 00 00       	call   80105357 <release>
80104a13:	83 c4 10             	add    $0x10,%esp

  return pid;
80104a16:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104a19:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104a1c:	5b                   	pop    %ebx
80104a1d:	5e                   	pop    %esi
80104a1e:	5f                   	pop    %edi
80104a1f:	5d                   	pop    %ebp
80104a20:	c3                   	ret    

80104a21 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104a21:	f3 0f 1e fb          	endbr32 
80104a25:	55                   	push   %ebp
80104a26:	89 e5                	mov    %esp,%ebp
80104a28:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104a2b:	e8 c9 fa ff ff       	call   801044f9 <myproc>
80104a30:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104a33:	a1 40 d6 10 80       	mov    0x8010d640,%eax
80104a38:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104a3b:	75 0d                	jne    80104a4a <exit+0x29>
    panic("init exiting");
80104a3d:	83 ec 0c             	sub    $0xc,%esp
80104a40:	68 5c 99 10 80       	push   $0x8010995c
80104a45:	e8 be bb ff ff       	call   80100608 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104a4a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104a51:	eb 3f                	jmp    80104a92 <exit+0x71>
    if(curproc->ofile[fd]){
80104a53:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a56:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a59:	83 c2 08             	add    $0x8,%edx
80104a5c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a60:	85 c0                	test   %eax,%eax
80104a62:	74 2a                	je     80104a8e <exit+0x6d>
      fileclose(curproc->ofile[fd]);
80104a64:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a67:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a6a:	83 c2 08             	add    $0x8,%edx
80104a6d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a71:	83 ec 0c             	sub    $0xc,%esp
80104a74:	50                   	push   %eax
80104a75:	e8 4b c7 ff ff       	call   801011c5 <fileclose>
80104a7a:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104a7d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a80:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a83:	83 c2 08             	add    $0x8,%edx
80104a86:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104a8d:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104a8e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104a92:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104a96:	7e bb                	jle    80104a53 <exit+0x32>
    }
  }

  begin_op();
80104a98:	e8 9d ec ff ff       	call   8010373a <begin_op>
  iput(curproc->cwd);
80104a9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104aa0:	8b 40 68             	mov    0x68(%eax),%eax
80104aa3:	83 ec 0c             	sub    $0xc,%esp
80104aa6:	50                   	push   %eax
80104aa7:	e8 02 d2 ff ff       	call   80101cae <iput>
80104aac:	83 c4 10             	add    $0x10,%esp
  end_op();
80104aaf:	e8 16 ed ff ff       	call   801037ca <end_op>
  curproc->cwd = 0;
80104ab4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ab7:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104abe:	83 ec 0c             	sub    $0xc,%esp
80104ac1:	68 c0 5d 11 80       	push   $0x80115dc0
80104ac6:	e8 1a 08 00 00       	call   801052e5 <acquire>
80104acb:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104ace:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ad1:	8b 40 14             	mov    0x14(%eax),%eax
80104ad4:	83 ec 0c             	sub    $0xc,%esp
80104ad7:	50                   	push   %eax
80104ad8:	e8 41 04 00 00       	call   80104f1e <wakeup1>
80104add:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ae0:	c7 45 f4 f4 5d 11 80 	movl   $0x80115df4,-0xc(%ebp)
80104ae7:	eb 3a                	jmp    80104b23 <exit+0x102>
    if(p->parent == curproc){
80104ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aec:	8b 40 14             	mov    0x14(%eax),%eax
80104aef:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104af2:	75 28                	jne    80104b1c <exit+0xfb>
      p->parent = initproc;
80104af4:	8b 15 40 d6 10 80    	mov    0x8010d640,%edx
80104afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104afd:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b03:	8b 40 0c             	mov    0xc(%eax),%eax
80104b06:	83 f8 05             	cmp    $0x5,%eax
80104b09:	75 11                	jne    80104b1c <exit+0xfb>
        wakeup1(initproc);
80104b0b:	a1 40 d6 10 80       	mov    0x8010d640,%eax
80104b10:	83 ec 0c             	sub    $0xc,%esp
80104b13:	50                   	push   %eax
80104b14:	e8 05 04 00 00       	call   80104f1e <wakeup1>
80104b19:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b1c:	81 45 f4 c0 00 00 00 	addl   $0xc0,-0xc(%ebp)
80104b23:	81 7d f4 f4 8d 11 80 	cmpl   $0x80118df4,-0xc(%ebp)
80104b2a:	72 bd                	jb     80104ae9 <exit+0xc8>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104b2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b2f:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104b36:	e8 f3 01 00 00       	call   80104d2e <sched>
  panic("zombie exit");
80104b3b:	83 ec 0c             	sub    $0xc,%esp
80104b3e:	68 69 99 10 80       	push   $0x80109969
80104b43:	e8 c0 ba ff ff       	call   80100608 <panic>

80104b48 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104b48:	f3 0f 1e fb          	endbr32 
80104b4c:	55                   	push   %ebp
80104b4d:	89 e5                	mov    %esp,%ebp
80104b4f:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104b52:	e8 a2 f9 ff ff       	call   801044f9 <myproc>
80104b57:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104b5a:	83 ec 0c             	sub    $0xc,%esp
80104b5d:	68 c0 5d 11 80       	push   $0x80115dc0
80104b62:	e8 7e 07 00 00       	call   801052e5 <acquire>
80104b67:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104b6a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b71:	c7 45 f4 f4 5d 11 80 	movl   $0x80115df4,-0xc(%ebp)
80104b78:	e9 a4 00 00 00       	jmp    80104c21 <wait+0xd9>
      if(p->parent != curproc)
80104b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b80:	8b 40 14             	mov    0x14(%eax),%eax
80104b83:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104b86:	0f 85 8d 00 00 00    	jne    80104c19 <wait+0xd1>
        continue;
      havekids = 1;
80104b8c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104b93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b96:	8b 40 0c             	mov    0xc(%eax),%eax
80104b99:	83 f8 05             	cmp    $0x5,%eax
80104b9c:	75 7c                	jne    80104c1a <wait+0xd2>
        // Found one.
        pid = p->pid;
80104b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba1:	8b 40 10             	mov    0x10(%eax),%eax
80104ba4:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104baa:	8b 40 08             	mov    0x8(%eax),%eax
80104bad:	83 ec 0c             	sub    $0xc,%esp
80104bb0:	50                   	push   %eax
80104bb1:	e8 e1 e1 ff ff       	call   80102d97 <kfree>
80104bb6:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bbc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc6:	8b 40 04             	mov    0x4(%eax),%eax
80104bc9:	83 ec 0c             	sub    $0xc,%esp
80104bcc:	50                   	push   %eax
80104bcd:	e8 89 3a 00 00       	call   8010865b <freevm>
80104bd2:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd8:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be2:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bec:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf3:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104bfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bfd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104c04:	83 ec 0c             	sub    $0xc,%esp
80104c07:	68 c0 5d 11 80       	push   $0x80115dc0
80104c0c:	e8 46 07 00 00       	call   80105357 <release>
80104c11:	83 c4 10             	add    $0x10,%esp
        return pid;
80104c14:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104c17:	eb 54                	jmp    80104c6d <wait+0x125>
        continue;
80104c19:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c1a:	81 45 f4 c0 00 00 00 	addl   $0xc0,-0xc(%ebp)
80104c21:	81 7d f4 f4 8d 11 80 	cmpl   $0x80118df4,-0xc(%ebp)
80104c28:	0f 82 4f ff ff ff    	jb     80104b7d <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104c2e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c32:	74 0a                	je     80104c3e <wait+0xf6>
80104c34:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c37:	8b 40 24             	mov    0x24(%eax),%eax
80104c3a:	85 c0                	test   %eax,%eax
80104c3c:	74 17                	je     80104c55 <wait+0x10d>
      release(&ptable.lock);
80104c3e:	83 ec 0c             	sub    $0xc,%esp
80104c41:	68 c0 5d 11 80       	push   $0x80115dc0
80104c46:	e8 0c 07 00 00       	call   80105357 <release>
80104c4b:	83 c4 10             	add    $0x10,%esp
      return -1;
80104c4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c53:	eb 18                	jmp    80104c6d <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104c55:	83 ec 08             	sub    $0x8,%esp
80104c58:	68 c0 5d 11 80       	push   $0x80115dc0
80104c5d:	ff 75 ec             	pushl  -0x14(%ebp)
80104c60:	e8 0e 02 00 00       	call   80104e73 <sleep>
80104c65:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104c68:	e9 fd fe ff ff       	jmp    80104b6a <wait+0x22>
  }
}
80104c6d:	c9                   	leave  
80104c6e:	c3                   	ret    

80104c6f <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104c6f:	f3 0f 1e fb          	endbr32 
80104c73:	55                   	push   %ebp
80104c74:	89 e5                	mov    %esp,%ebp
80104c76:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104c79:	e8 ff f7 ff ff       	call   8010447d <mycpu>
80104c7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104c81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c84:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104c8b:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104c8e:	e8 a2 f7 ff ff       	call   80104435 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104c93:	83 ec 0c             	sub    $0xc,%esp
80104c96:	68 c0 5d 11 80       	push   $0x80115dc0
80104c9b:	e8 45 06 00 00       	call   801052e5 <acquire>
80104ca0:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ca3:	c7 45 f4 f4 5d 11 80 	movl   $0x80115df4,-0xc(%ebp)
80104caa:	eb 64                	jmp    80104d10 <scheduler+0xa1>
      if(p->state != RUNNABLE)
80104cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104caf:	8b 40 0c             	mov    0xc(%eax),%eax
80104cb2:	83 f8 03             	cmp    $0x3,%eax
80104cb5:	75 51                	jne    80104d08 <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104cb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cba:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cbd:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104cc3:	83 ec 0c             	sub    $0xc,%esp
80104cc6:	ff 75 f4             	pushl  -0xc(%ebp)
80104cc9:	e8 d2 34 00 00       	call   801081a0 <switchuvm>
80104cce:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cd4:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104cdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cde:	8b 40 1c             	mov    0x1c(%eax),%eax
80104ce1:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ce4:	83 c2 04             	add    $0x4,%edx
80104ce7:	83 ec 08             	sub    $0x8,%esp
80104cea:	50                   	push   %eax
80104ceb:	52                   	push   %edx
80104cec:	e8 27 0b 00 00       	call   80105818 <swtch>
80104cf1:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104cf4:	e8 8a 34 00 00       	call   80108183 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104cf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cfc:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104d03:	00 00 00 
80104d06:	eb 01                	jmp    80104d09 <scheduler+0x9a>
        continue;
80104d08:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d09:	81 45 f4 c0 00 00 00 	addl   $0xc0,-0xc(%ebp)
80104d10:	81 7d f4 f4 8d 11 80 	cmpl   $0x80118df4,-0xc(%ebp)
80104d17:	72 93                	jb     80104cac <scheduler+0x3d>
    }
    release(&ptable.lock);
80104d19:	83 ec 0c             	sub    $0xc,%esp
80104d1c:	68 c0 5d 11 80       	push   $0x80115dc0
80104d21:	e8 31 06 00 00       	call   80105357 <release>
80104d26:	83 c4 10             	add    $0x10,%esp
    sti();
80104d29:	e9 60 ff ff ff       	jmp    80104c8e <scheduler+0x1f>

80104d2e <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104d2e:	f3 0f 1e fb          	endbr32 
80104d32:	55                   	push   %ebp
80104d33:	89 e5                	mov    %esp,%ebp
80104d35:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104d38:	e8 bc f7 ff ff       	call   801044f9 <myproc>
80104d3d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104d40:	83 ec 0c             	sub    $0xc,%esp
80104d43:	68 c0 5d 11 80       	push   $0x80115dc0
80104d48:	e8 df 06 00 00       	call   8010542c <holding>
80104d4d:	83 c4 10             	add    $0x10,%esp
80104d50:	85 c0                	test   %eax,%eax
80104d52:	75 0d                	jne    80104d61 <sched+0x33>
    panic("sched ptable.lock");
80104d54:	83 ec 0c             	sub    $0xc,%esp
80104d57:	68 75 99 10 80       	push   $0x80109975
80104d5c:	e8 a7 b8 ff ff       	call   80100608 <panic>
  if(mycpu()->ncli != 1)
80104d61:	e8 17 f7 ff ff       	call   8010447d <mycpu>
80104d66:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d6c:	83 f8 01             	cmp    $0x1,%eax
80104d6f:	74 0d                	je     80104d7e <sched+0x50>
    panic("sched locks");
80104d71:	83 ec 0c             	sub    $0xc,%esp
80104d74:	68 87 99 10 80       	push   $0x80109987
80104d79:	e8 8a b8 ff ff       	call   80100608 <panic>
  if(p->state == RUNNING)
80104d7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d81:	8b 40 0c             	mov    0xc(%eax),%eax
80104d84:	83 f8 04             	cmp    $0x4,%eax
80104d87:	75 0d                	jne    80104d96 <sched+0x68>
    panic("sched running");
80104d89:	83 ec 0c             	sub    $0xc,%esp
80104d8c:	68 93 99 10 80       	push   $0x80109993
80104d91:	e8 72 b8 ff ff       	call   80100608 <panic>
  if(readeflags()&FL_IF)
80104d96:	e8 8a f6 ff ff       	call   80104425 <readeflags>
80104d9b:	25 00 02 00 00       	and    $0x200,%eax
80104da0:	85 c0                	test   %eax,%eax
80104da2:	74 0d                	je     80104db1 <sched+0x83>
    panic("sched interruptible");
80104da4:	83 ec 0c             	sub    $0xc,%esp
80104da7:	68 a1 99 10 80       	push   $0x801099a1
80104dac:	e8 57 b8 ff ff       	call   80100608 <panic>
  intena = mycpu()->intena;
80104db1:	e8 c7 f6 ff ff       	call   8010447d <mycpu>
80104db6:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104dbc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104dbf:	e8 b9 f6 ff ff       	call   8010447d <mycpu>
80104dc4:	8b 40 04             	mov    0x4(%eax),%eax
80104dc7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104dca:	83 c2 1c             	add    $0x1c,%edx
80104dcd:	83 ec 08             	sub    $0x8,%esp
80104dd0:	50                   	push   %eax
80104dd1:	52                   	push   %edx
80104dd2:	e8 41 0a 00 00       	call   80105818 <swtch>
80104dd7:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104dda:	e8 9e f6 ff ff       	call   8010447d <mycpu>
80104ddf:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104de2:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104de8:	90                   	nop
80104de9:	c9                   	leave  
80104dea:	c3                   	ret    

80104deb <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104deb:	f3 0f 1e fb          	endbr32 
80104def:	55                   	push   %ebp
80104df0:	89 e5                	mov    %esp,%ebp
80104df2:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104df5:	83 ec 0c             	sub    $0xc,%esp
80104df8:	68 c0 5d 11 80       	push   $0x80115dc0
80104dfd:	e8 e3 04 00 00       	call   801052e5 <acquire>
80104e02:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104e05:	e8 ef f6 ff ff       	call   801044f9 <myproc>
80104e0a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104e11:	e8 18 ff ff ff       	call   80104d2e <sched>
  release(&ptable.lock);
80104e16:	83 ec 0c             	sub    $0xc,%esp
80104e19:	68 c0 5d 11 80       	push   $0x80115dc0
80104e1e:	e8 34 05 00 00       	call   80105357 <release>
80104e23:	83 c4 10             	add    $0x10,%esp
}
80104e26:	90                   	nop
80104e27:	c9                   	leave  
80104e28:	c3                   	ret    

80104e29 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104e29:	f3 0f 1e fb          	endbr32 
80104e2d:	55                   	push   %ebp
80104e2e:	89 e5                	mov    %esp,%ebp
80104e30:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104e33:	83 ec 0c             	sub    $0xc,%esp
80104e36:	68 c0 5d 11 80       	push   $0x80115dc0
80104e3b:	e8 17 05 00 00       	call   80105357 <release>
80104e40:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104e43:	a1 04 d0 10 80       	mov    0x8010d004,%eax
80104e48:	85 c0                	test   %eax,%eax
80104e4a:	74 24                	je     80104e70 <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104e4c:	c7 05 04 d0 10 80 00 	movl   $0x0,0x8010d004
80104e53:	00 00 00 
    iinit(ROOTDEV);
80104e56:	83 ec 0c             	sub    $0xc,%esp
80104e59:	6a 01                	push   $0x1
80104e5b:	e8 5f c9 ff ff       	call   801017bf <iinit>
80104e60:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104e63:	83 ec 0c             	sub    $0xc,%esp
80104e66:	6a 01                	push   $0x1
80104e68:	e8 9a e6 ff ff       	call   80103507 <initlog>
80104e6d:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104e70:	90                   	nop
80104e71:	c9                   	leave  
80104e72:	c3                   	ret    

80104e73 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104e73:	f3 0f 1e fb          	endbr32 
80104e77:	55                   	push   %ebp
80104e78:	89 e5                	mov    %esp,%ebp
80104e7a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104e7d:	e8 77 f6 ff ff       	call   801044f9 <myproc>
80104e82:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104e85:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e89:	75 0d                	jne    80104e98 <sleep+0x25>
    panic("sleep");
80104e8b:	83 ec 0c             	sub    $0xc,%esp
80104e8e:	68 b5 99 10 80       	push   $0x801099b5
80104e93:	e8 70 b7 ff ff       	call   80100608 <panic>

  if(lk == 0)
80104e98:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104e9c:	75 0d                	jne    80104eab <sleep+0x38>
    panic("sleep without lk");
80104e9e:	83 ec 0c             	sub    $0xc,%esp
80104ea1:	68 bb 99 10 80       	push   $0x801099bb
80104ea6:	e8 5d b7 ff ff       	call   80100608 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104eab:	81 7d 0c c0 5d 11 80 	cmpl   $0x80115dc0,0xc(%ebp)
80104eb2:	74 1e                	je     80104ed2 <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104eb4:	83 ec 0c             	sub    $0xc,%esp
80104eb7:	68 c0 5d 11 80       	push   $0x80115dc0
80104ebc:	e8 24 04 00 00       	call   801052e5 <acquire>
80104ec1:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104ec4:	83 ec 0c             	sub    $0xc,%esp
80104ec7:	ff 75 0c             	pushl  0xc(%ebp)
80104eca:	e8 88 04 00 00       	call   80105357 <release>
80104ecf:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ed5:	8b 55 08             	mov    0x8(%ebp),%edx
80104ed8:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ede:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104ee5:	e8 44 fe ff ff       	call   80104d2e <sched>

  // Tidy up.
  p->chan = 0;
80104eea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eed:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104ef4:	81 7d 0c c0 5d 11 80 	cmpl   $0x80115dc0,0xc(%ebp)
80104efb:	74 1e                	je     80104f1b <sleep+0xa8>
    release(&ptable.lock);
80104efd:	83 ec 0c             	sub    $0xc,%esp
80104f00:	68 c0 5d 11 80       	push   $0x80115dc0
80104f05:	e8 4d 04 00 00       	call   80105357 <release>
80104f0a:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104f0d:	83 ec 0c             	sub    $0xc,%esp
80104f10:	ff 75 0c             	pushl  0xc(%ebp)
80104f13:	e8 cd 03 00 00       	call   801052e5 <acquire>
80104f18:	83 c4 10             	add    $0x10,%esp
  }
}
80104f1b:	90                   	nop
80104f1c:	c9                   	leave  
80104f1d:	c3                   	ret    

80104f1e <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104f1e:	f3 0f 1e fb          	endbr32 
80104f22:	55                   	push   %ebp
80104f23:	89 e5                	mov    %esp,%ebp
80104f25:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f28:	c7 45 fc f4 5d 11 80 	movl   $0x80115df4,-0x4(%ebp)
80104f2f:	eb 27                	jmp    80104f58 <wakeup1+0x3a>
    if(p->state == SLEEPING && p->chan == chan)
80104f31:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f34:	8b 40 0c             	mov    0xc(%eax),%eax
80104f37:	83 f8 02             	cmp    $0x2,%eax
80104f3a:	75 15                	jne    80104f51 <wakeup1+0x33>
80104f3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f3f:	8b 40 20             	mov    0x20(%eax),%eax
80104f42:	39 45 08             	cmp    %eax,0x8(%ebp)
80104f45:	75 0a                	jne    80104f51 <wakeup1+0x33>
      p->state = RUNNABLE;
80104f47:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f4a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f51:	81 45 fc c0 00 00 00 	addl   $0xc0,-0x4(%ebp)
80104f58:	81 7d fc f4 8d 11 80 	cmpl   $0x80118df4,-0x4(%ebp)
80104f5f:	72 d0                	jb     80104f31 <wakeup1+0x13>
}
80104f61:	90                   	nop
80104f62:	90                   	nop
80104f63:	c9                   	leave  
80104f64:	c3                   	ret    

80104f65 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104f65:	f3 0f 1e fb          	endbr32 
80104f69:	55                   	push   %ebp
80104f6a:	89 e5                	mov    %esp,%ebp
80104f6c:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104f6f:	83 ec 0c             	sub    $0xc,%esp
80104f72:	68 c0 5d 11 80       	push   $0x80115dc0
80104f77:	e8 69 03 00 00       	call   801052e5 <acquire>
80104f7c:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104f7f:	83 ec 0c             	sub    $0xc,%esp
80104f82:	ff 75 08             	pushl  0x8(%ebp)
80104f85:	e8 94 ff ff ff       	call   80104f1e <wakeup1>
80104f8a:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104f8d:	83 ec 0c             	sub    $0xc,%esp
80104f90:	68 c0 5d 11 80       	push   $0x80115dc0
80104f95:	e8 bd 03 00 00       	call   80105357 <release>
80104f9a:	83 c4 10             	add    $0x10,%esp
}
80104f9d:	90                   	nop
80104f9e:	c9                   	leave  
80104f9f:	c3                   	ret    

80104fa0 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104fa0:	f3 0f 1e fb          	endbr32 
80104fa4:	55                   	push   %ebp
80104fa5:	89 e5                	mov    %esp,%ebp
80104fa7:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104faa:	83 ec 0c             	sub    $0xc,%esp
80104fad:	68 c0 5d 11 80       	push   $0x80115dc0
80104fb2:	e8 2e 03 00 00       	call   801052e5 <acquire>
80104fb7:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fba:	c7 45 f4 f4 5d 11 80 	movl   $0x80115df4,-0xc(%ebp)
80104fc1:	eb 48                	jmp    8010500b <kill+0x6b>
    if(p->pid == pid){
80104fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fc6:	8b 40 10             	mov    0x10(%eax),%eax
80104fc9:	39 45 08             	cmp    %eax,0x8(%ebp)
80104fcc:	75 36                	jne    80105004 <kill+0x64>
      p->killed = 1;
80104fce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fd1:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fdb:	8b 40 0c             	mov    0xc(%eax),%eax
80104fde:	83 f8 02             	cmp    $0x2,%eax
80104fe1:	75 0a                	jne    80104fed <kill+0x4d>
        p->state = RUNNABLE;
80104fe3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fe6:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104fed:	83 ec 0c             	sub    $0xc,%esp
80104ff0:	68 c0 5d 11 80       	push   $0x80115dc0
80104ff5:	e8 5d 03 00 00       	call   80105357 <release>
80104ffa:	83 c4 10             	add    $0x10,%esp
      return 0;
80104ffd:	b8 00 00 00 00       	mov    $0x0,%eax
80105002:	eb 25                	jmp    80105029 <kill+0x89>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105004:	81 45 f4 c0 00 00 00 	addl   $0xc0,-0xc(%ebp)
8010500b:	81 7d f4 f4 8d 11 80 	cmpl   $0x80118df4,-0xc(%ebp)
80105012:	72 af                	jb     80104fc3 <kill+0x23>
    }
  }
  release(&ptable.lock);
80105014:	83 ec 0c             	sub    $0xc,%esp
80105017:	68 c0 5d 11 80       	push   $0x80115dc0
8010501c:	e8 36 03 00 00       	call   80105357 <release>
80105021:	83 c4 10             	add    $0x10,%esp
  return -1;
80105024:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105029:	c9                   	leave  
8010502a:	c3                   	ret    

8010502b <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010502b:	f3 0f 1e fb          	endbr32 
8010502f:	55                   	push   %ebp
80105030:	89 e5                	mov    %esp,%ebp
80105032:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105035:	c7 45 f0 f4 5d 11 80 	movl   $0x80115df4,-0x10(%ebp)
8010503c:	e9 da 00 00 00       	jmp    8010511b <procdump+0xf0>
    if(p->state == UNUSED)
80105041:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105044:	8b 40 0c             	mov    0xc(%eax),%eax
80105047:	85 c0                	test   %eax,%eax
80105049:	0f 84 c4 00 00 00    	je     80105113 <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010504f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105052:	8b 40 0c             	mov    0xc(%eax),%eax
80105055:	83 f8 05             	cmp    $0x5,%eax
80105058:	77 23                	ja     8010507d <procdump+0x52>
8010505a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010505d:	8b 40 0c             	mov    0xc(%eax),%eax
80105060:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
80105067:	85 c0                	test   %eax,%eax
80105069:	74 12                	je     8010507d <procdump+0x52>
      state = states[p->state];
8010506b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010506e:	8b 40 0c             	mov    0xc(%eax),%eax
80105071:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
80105078:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010507b:	eb 07                	jmp    80105084 <procdump+0x59>
    else
      state = "???";
8010507d:	c7 45 ec cc 99 10 80 	movl   $0x801099cc,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80105084:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105087:	8d 50 6c             	lea    0x6c(%eax),%edx
8010508a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010508d:	8b 40 10             	mov    0x10(%eax),%eax
80105090:	52                   	push   %edx
80105091:	ff 75 ec             	pushl  -0x14(%ebp)
80105094:	50                   	push   %eax
80105095:	68 d0 99 10 80       	push   $0x801099d0
8010509a:	e8 79 b3 ff ff       	call   80100418 <cprintf>
8010509f:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801050a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050a5:	8b 40 0c             	mov    0xc(%eax),%eax
801050a8:	83 f8 02             	cmp    $0x2,%eax
801050ab:	75 54                	jne    80105101 <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801050ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050b0:	8b 40 1c             	mov    0x1c(%eax),%eax
801050b3:	8b 40 0c             	mov    0xc(%eax),%eax
801050b6:	83 c0 08             	add    $0x8,%eax
801050b9:	89 c2                	mov    %eax,%edx
801050bb:	83 ec 08             	sub    $0x8,%esp
801050be:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801050c1:	50                   	push   %eax
801050c2:	52                   	push   %edx
801050c3:	e8 e5 02 00 00       	call   801053ad <getcallerpcs>
801050c8:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801050cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801050d2:	eb 1c                	jmp    801050f0 <procdump+0xc5>
        cprintf(" %p", pc[i]);
801050d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050d7:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801050db:	83 ec 08             	sub    $0x8,%esp
801050de:	50                   	push   %eax
801050df:	68 d9 99 10 80       	push   $0x801099d9
801050e4:	e8 2f b3 ff ff       	call   80100418 <cprintf>
801050e9:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801050ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801050f0:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801050f4:	7f 0b                	jg     80105101 <procdump+0xd6>
801050f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050f9:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801050fd:	85 c0                	test   %eax,%eax
801050ff:	75 d3                	jne    801050d4 <procdump+0xa9>
    }
    cprintf("\n");
80105101:	83 ec 0c             	sub    $0xc,%esp
80105104:	68 dd 99 10 80       	push   $0x801099dd
80105109:	e8 0a b3 ff ff       	call   80100418 <cprintf>
8010510e:	83 c4 10             	add    $0x10,%esp
80105111:	eb 01                	jmp    80105114 <procdump+0xe9>
      continue;
80105113:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105114:	81 45 f0 c0 00 00 00 	addl   $0xc0,-0x10(%ebp)
8010511b:	81 7d f0 f4 8d 11 80 	cmpl   $0x80118df4,-0x10(%ebp)
80105122:	0f 82 19 ff ff ff    	jb     80105041 <procdump+0x16>
  }
80105128:	90                   	nop
80105129:	90                   	nop
8010512a:	c9                   	leave  
8010512b:	c3                   	ret    

8010512c <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
8010512c:	f3 0f 1e fb          	endbr32 
80105130:	55                   	push   %ebp
80105131:	89 e5                	mov    %esp,%ebp
80105133:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80105136:	8b 45 08             	mov    0x8(%ebp),%eax
80105139:	83 c0 04             	add    $0x4,%eax
8010513c:	83 ec 08             	sub    $0x8,%esp
8010513f:	68 09 9a 10 80       	push   $0x80109a09
80105144:	50                   	push   %eax
80105145:	e8 75 01 00 00       	call   801052bf <initlock>
8010514a:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
8010514d:	8b 45 08             	mov    0x8(%ebp),%eax
80105150:	8b 55 0c             	mov    0xc(%ebp),%edx
80105153:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80105156:	8b 45 08             	mov    0x8(%ebp),%eax
80105159:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010515f:	8b 45 08             	mov    0x8(%ebp),%eax
80105162:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80105169:	90                   	nop
8010516a:	c9                   	leave  
8010516b:	c3                   	ret    

8010516c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
8010516c:	f3 0f 1e fb          	endbr32 
80105170:	55                   	push   %ebp
80105171:	89 e5                	mov    %esp,%ebp
80105173:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80105176:	8b 45 08             	mov    0x8(%ebp),%eax
80105179:	83 c0 04             	add    $0x4,%eax
8010517c:	83 ec 0c             	sub    $0xc,%esp
8010517f:	50                   	push   %eax
80105180:	e8 60 01 00 00       	call   801052e5 <acquire>
80105185:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80105188:	eb 15                	jmp    8010519f <acquiresleep+0x33>
    sleep(lk, &lk->lk);
8010518a:	8b 45 08             	mov    0x8(%ebp),%eax
8010518d:	83 c0 04             	add    $0x4,%eax
80105190:	83 ec 08             	sub    $0x8,%esp
80105193:	50                   	push   %eax
80105194:	ff 75 08             	pushl  0x8(%ebp)
80105197:	e8 d7 fc ff ff       	call   80104e73 <sleep>
8010519c:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
8010519f:	8b 45 08             	mov    0x8(%ebp),%eax
801051a2:	8b 00                	mov    (%eax),%eax
801051a4:	85 c0                	test   %eax,%eax
801051a6:	75 e2                	jne    8010518a <acquiresleep+0x1e>
  }
  lk->locked = 1;
801051a8:	8b 45 08             	mov    0x8(%ebp),%eax
801051ab:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
801051b1:	e8 43 f3 ff ff       	call   801044f9 <myproc>
801051b6:	8b 50 10             	mov    0x10(%eax),%edx
801051b9:	8b 45 08             	mov    0x8(%ebp),%eax
801051bc:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
801051bf:	8b 45 08             	mov    0x8(%ebp),%eax
801051c2:	83 c0 04             	add    $0x4,%eax
801051c5:	83 ec 0c             	sub    $0xc,%esp
801051c8:	50                   	push   %eax
801051c9:	e8 89 01 00 00       	call   80105357 <release>
801051ce:	83 c4 10             	add    $0x10,%esp
}
801051d1:	90                   	nop
801051d2:	c9                   	leave  
801051d3:	c3                   	ret    

801051d4 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801051d4:	f3 0f 1e fb          	endbr32 
801051d8:	55                   	push   %ebp
801051d9:	89 e5                	mov    %esp,%ebp
801051db:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801051de:	8b 45 08             	mov    0x8(%ebp),%eax
801051e1:	83 c0 04             	add    $0x4,%eax
801051e4:	83 ec 0c             	sub    $0xc,%esp
801051e7:	50                   	push   %eax
801051e8:	e8 f8 00 00 00       	call   801052e5 <acquire>
801051ed:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
801051f0:	8b 45 08             	mov    0x8(%ebp),%eax
801051f3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801051f9:	8b 45 08             	mov    0x8(%ebp),%eax
801051fc:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80105203:	83 ec 0c             	sub    $0xc,%esp
80105206:	ff 75 08             	pushl  0x8(%ebp)
80105209:	e8 57 fd ff ff       	call   80104f65 <wakeup>
8010520e:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80105211:	8b 45 08             	mov    0x8(%ebp),%eax
80105214:	83 c0 04             	add    $0x4,%eax
80105217:	83 ec 0c             	sub    $0xc,%esp
8010521a:	50                   	push   %eax
8010521b:	e8 37 01 00 00       	call   80105357 <release>
80105220:	83 c4 10             	add    $0x10,%esp
}
80105223:	90                   	nop
80105224:	c9                   	leave  
80105225:	c3                   	ret    

80105226 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80105226:	f3 0f 1e fb          	endbr32 
8010522a:	55                   	push   %ebp
8010522b:	89 e5                	mov    %esp,%ebp
8010522d:	53                   	push   %ebx
8010522e:	83 ec 14             	sub    $0x14,%esp
  int r;
  
  acquire(&lk->lk);
80105231:	8b 45 08             	mov    0x8(%ebp),%eax
80105234:	83 c0 04             	add    $0x4,%eax
80105237:	83 ec 0c             	sub    $0xc,%esp
8010523a:	50                   	push   %eax
8010523b:	e8 a5 00 00 00       	call   801052e5 <acquire>
80105240:	83 c4 10             	add    $0x10,%esp
  r = lk->locked && (lk->pid == myproc()->pid);
80105243:	8b 45 08             	mov    0x8(%ebp),%eax
80105246:	8b 00                	mov    (%eax),%eax
80105248:	85 c0                	test   %eax,%eax
8010524a:	74 19                	je     80105265 <holdingsleep+0x3f>
8010524c:	8b 45 08             	mov    0x8(%ebp),%eax
8010524f:	8b 58 3c             	mov    0x3c(%eax),%ebx
80105252:	e8 a2 f2 ff ff       	call   801044f9 <myproc>
80105257:	8b 40 10             	mov    0x10(%eax),%eax
8010525a:	39 c3                	cmp    %eax,%ebx
8010525c:	75 07                	jne    80105265 <holdingsleep+0x3f>
8010525e:	b8 01 00 00 00       	mov    $0x1,%eax
80105263:	eb 05                	jmp    8010526a <holdingsleep+0x44>
80105265:	b8 00 00 00 00       	mov    $0x0,%eax
8010526a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
8010526d:	8b 45 08             	mov    0x8(%ebp),%eax
80105270:	83 c0 04             	add    $0x4,%eax
80105273:	83 ec 0c             	sub    $0xc,%esp
80105276:	50                   	push   %eax
80105277:	e8 db 00 00 00       	call   80105357 <release>
8010527c:	83 c4 10             	add    $0x10,%esp
  return r;
8010527f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105282:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105285:	c9                   	leave  
80105286:	c3                   	ret    

80105287 <readeflags>:
{
80105287:	55                   	push   %ebp
80105288:	89 e5                	mov    %esp,%ebp
8010528a:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010528d:	9c                   	pushf  
8010528e:	58                   	pop    %eax
8010528f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105292:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105295:	c9                   	leave  
80105296:	c3                   	ret    

80105297 <cli>:
{
80105297:	55                   	push   %ebp
80105298:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010529a:	fa                   	cli    
}
8010529b:	90                   	nop
8010529c:	5d                   	pop    %ebp
8010529d:	c3                   	ret    

8010529e <sti>:
{
8010529e:	55                   	push   %ebp
8010529f:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801052a1:	fb                   	sti    
}
801052a2:	90                   	nop
801052a3:	5d                   	pop    %ebp
801052a4:	c3                   	ret    

801052a5 <xchg>:
{
801052a5:	55                   	push   %ebp
801052a6:	89 e5                	mov    %esp,%ebp
801052a8:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
801052ab:	8b 55 08             	mov    0x8(%ebp),%edx
801052ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801052b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052b4:	f0 87 02             	lock xchg %eax,(%edx)
801052b7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
801052ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801052bd:	c9                   	leave  
801052be:	c3                   	ret    

801052bf <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801052bf:	f3 0f 1e fb          	endbr32 
801052c3:	55                   	push   %ebp
801052c4:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801052c6:	8b 45 08             	mov    0x8(%ebp),%eax
801052c9:	8b 55 0c             	mov    0xc(%ebp),%edx
801052cc:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801052cf:	8b 45 08             	mov    0x8(%ebp),%eax
801052d2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801052d8:	8b 45 08             	mov    0x8(%ebp),%eax
801052db:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801052e2:	90                   	nop
801052e3:	5d                   	pop    %ebp
801052e4:	c3                   	ret    

801052e5 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801052e5:	f3 0f 1e fb          	endbr32 
801052e9:	55                   	push   %ebp
801052ea:	89 e5                	mov    %esp,%ebp
801052ec:	53                   	push   %ebx
801052ed:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801052f0:	e8 7c 01 00 00       	call   80105471 <pushcli>
  if(holding(lk))
801052f5:	8b 45 08             	mov    0x8(%ebp),%eax
801052f8:	83 ec 0c             	sub    $0xc,%esp
801052fb:	50                   	push   %eax
801052fc:	e8 2b 01 00 00       	call   8010542c <holding>
80105301:	83 c4 10             	add    $0x10,%esp
80105304:	85 c0                	test   %eax,%eax
80105306:	74 0d                	je     80105315 <acquire+0x30>
    panic("acquire");
80105308:	83 ec 0c             	sub    $0xc,%esp
8010530b:	68 14 9a 10 80       	push   $0x80109a14
80105310:	e8 f3 b2 ff ff       	call   80100608 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80105315:	90                   	nop
80105316:	8b 45 08             	mov    0x8(%ebp),%eax
80105319:	83 ec 08             	sub    $0x8,%esp
8010531c:	6a 01                	push   $0x1
8010531e:	50                   	push   %eax
8010531f:	e8 81 ff ff ff       	call   801052a5 <xchg>
80105324:	83 c4 10             	add    $0x10,%esp
80105327:	85 c0                	test   %eax,%eax
80105329:	75 eb                	jne    80105316 <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010532b:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80105330:	8b 5d 08             	mov    0x8(%ebp),%ebx
80105333:	e8 45 f1 ff ff       	call   8010447d <mycpu>
80105338:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010533b:	8b 45 08             	mov    0x8(%ebp),%eax
8010533e:	83 c0 0c             	add    $0xc,%eax
80105341:	83 ec 08             	sub    $0x8,%esp
80105344:	50                   	push   %eax
80105345:	8d 45 08             	lea    0x8(%ebp),%eax
80105348:	50                   	push   %eax
80105349:	e8 5f 00 00 00       	call   801053ad <getcallerpcs>
8010534e:	83 c4 10             	add    $0x10,%esp
}
80105351:	90                   	nop
80105352:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105355:	c9                   	leave  
80105356:	c3                   	ret    

80105357 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105357:	f3 0f 1e fb          	endbr32 
8010535b:	55                   	push   %ebp
8010535c:	89 e5                	mov    %esp,%ebp
8010535e:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105361:	83 ec 0c             	sub    $0xc,%esp
80105364:	ff 75 08             	pushl  0x8(%ebp)
80105367:	e8 c0 00 00 00       	call   8010542c <holding>
8010536c:	83 c4 10             	add    $0x10,%esp
8010536f:	85 c0                	test   %eax,%eax
80105371:	75 0d                	jne    80105380 <release+0x29>
    panic("release");
80105373:	83 ec 0c             	sub    $0xc,%esp
80105376:	68 1c 9a 10 80       	push   $0x80109a1c
8010537b:	e8 88 b2 ff ff       	call   80100608 <panic>

  lk->pcs[0] = 0;
80105380:	8b 45 08             	mov    0x8(%ebp),%eax
80105383:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010538a:	8b 45 08             	mov    0x8(%ebp),%eax
8010538d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80105394:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80105399:	8b 45 08             	mov    0x8(%ebp),%eax
8010539c:	8b 55 08             	mov    0x8(%ebp),%edx
8010539f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801053a5:	e8 18 01 00 00       	call   801054c2 <popcli>
}
801053aa:	90                   	nop
801053ab:	c9                   	leave  
801053ac:	c3                   	ret    

801053ad <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801053ad:	f3 0f 1e fb          	endbr32 
801053b1:	55                   	push   %ebp
801053b2:	89 e5                	mov    %esp,%ebp
801053b4:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801053b7:	8b 45 08             	mov    0x8(%ebp),%eax
801053ba:	83 e8 08             	sub    $0x8,%eax
801053bd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801053c0:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801053c7:	eb 38                	jmp    80105401 <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801053c9:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801053cd:	74 53                	je     80105422 <getcallerpcs+0x75>
801053cf:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801053d6:	76 4a                	jbe    80105422 <getcallerpcs+0x75>
801053d8:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801053dc:	74 44                	je     80105422 <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
801053de:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053e1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801053e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801053eb:	01 c2                	add    %eax,%edx
801053ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053f0:	8b 40 04             	mov    0x4(%eax),%eax
801053f3:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801053f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053f8:	8b 00                	mov    (%eax),%eax
801053fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801053fd:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105401:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105405:	7e c2                	jle    801053c9 <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
80105407:	eb 19                	jmp    80105422 <getcallerpcs+0x75>
    pcs[i] = 0;
80105409:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010540c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105413:	8b 45 0c             	mov    0xc(%ebp),%eax
80105416:	01 d0                	add    %edx,%eax
80105418:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
8010541e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105422:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105426:	7e e1                	jle    80105409 <getcallerpcs+0x5c>
}
80105428:	90                   	nop
80105429:	90                   	nop
8010542a:	c9                   	leave  
8010542b:	c3                   	ret    

8010542c <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010542c:	f3 0f 1e fb          	endbr32 
80105430:	55                   	push   %ebp
80105431:	89 e5                	mov    %esp,%ebp
80105433:	53                   	push   %ebx
80105434:	83 ec 14             	sub    $0x14,%esp
  int r;
  pushcli();
80105437:	e8 35 00 00 00       	call   80105471 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
8010543c:	8b 45 08             	mov    0x8(%ebp),%eax
8010543f:	8b 00                	mov    (%eax),%eax
80105441:	85 c0                	test   %eax,%eax
80105443:	74 16                	je     8010545b <holding+0x2f>
80105445:	8b 45 08             	mov    0x8(%ebp),%eax
80105448:	8b 58 08             	mov    0x8(%eax),%ebx
8010544b:	e8 2d f0 ff ff       	call   8010447d <mycpu>
80105450:	39 c3                	cmp    %eax,%ebx
80105452:	75 07                	jne    8010545b <holding+0x2f>
80105454:	b8 01 00 00 00       	mov    $0x1,%eax
80105459:	eb 05                	jmp    80105460 <holding+0x34>
8010545b:	b8 00 00 00 00       	mov    $0x0,%eax
80105460:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();
80105463:	e8 5a 00 00 00       	call   801054c2 <popcli>
  return r;
80105468:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010546b:	83 c4 14             	add    $0x14,%esp
8010546e:	5b                   	pop    %ebx
8010546f:	5d                   	pop    %ebp
80105470:	c3                   	ret    

80105471 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105471:	f3 0f 1e fb          	endbr32 
80105475:	55                   	push   %ebp
80105476:	89 e5                	mov    %esp,%ebp
80105478:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
8010547b:	e8 07 fe ff ff       	call   80105287 <readeflags>
80105480:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80105483:	e8 0f fe ff ff       	call   80105297 <cli>
  if(mycpu()->ncli == 0)
80105488:	e8 f0 ef ff ff       	call   8010447d <mycpu>
8010548d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105493:	85 c0                	test   %eax,%eax
80105495:	75 14                	jne    801054ab <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
80105497:	e8 e1 ef ff ff       	call   8010447d <mycpu>
8010549c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010549f:	81 e2 00 02 00 00    	and    $0x200,%edx
801054a5:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801054ab:	e8 cd ef ff ff       	call   8010447d <mycpu>
801054b0:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801054b6:	83 c2 01             	add    $0x1,%edx
801054b9:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801054bf:	90                   	nop
801054c0:	c9                   	leave  
801054c1:	c3                   	ret    

801054c2 <popcli>:

void
popcli(void)
{
801054c2:	f3 0f 1e fb          	endbr32 
801054c6:	55                   	push   %ebp
801054c7:	89 e5                	mov    %esp,%ebp
801054c9:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801054cc:	e8 b6 fd ff ff       	call   80105287 <readeflags>
801054d1:	25 00 02 00 00       	and    $0x200,%eax
801054d6:	85 c0                	test   %eax,%eax
801054d8:	74 0d                	je     801054e7 <popcli+0x25>
    panic("popcli - interruptible");
801054da:	83 ec 0c             	sub    $0xc,%esp
801054dd:	68 24 9a 10 80       	push   $0x80109a24
801054e2:	e8 21 b1 ff ff       	call   80100608 <panic>
  if(--mycpu()->ncli < 0)
801054e7:	e8 91 ef ff ff       	call   8010447d <mycpu>
801054ec:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801054f2:	83 ea 01             	sub    $0x1,%edx
801054f5:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801054fb:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105501:	85 c0                	test   %eax,%eax
80105503:	79 0d                	jns    80105512 <popcli+0x50>
    panic("popcli");
80105505:	83 ec 0c             	sub    $0xc,%esp
80105508:	68 3b 9a 10 80       	push   $0x80109a3b
8010550d:	e8 f6 b0 ff ff       	call   80100608 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105512:	e8 66 ef ff ff       	call   8010447d <mycpu>
80105517:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010551d:	85 c0                	test   %eax,%eax
8010551f:	75 14                	jne    80105535 <popcli+0x73>
80105521:	e8 57 ef ff ff       	call   8010447d <mycpu>
80105526:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010552c:	85 c0                	test   %eax,%eax
8010552e:	74 05                	je     80105535 <popcli+0x73>
    sti();
80105530:	e8 69 fd ff ff       	call   8010529e <sti>
}
80105535:	90                   	nop
80105536:	c9                   	leave  
80105537:	c3                   	ret    

80105538 <stosb>:
{
80105538:	55                   	push   %ebp
80105539:	89 e5                	mov    %esp,%ebp
8010553b:	57                   	push   %edi
8010553c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010553d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105540:	8b 55 10             	mov    0x10(%ebp),%edx
80105543:	8b 45 0c             	mov    0xc(%ebp),%eax
80105546:	89 cb                	mov    %ecx,%ebx
80105548:	89 df                	mov    %ebx,%edi
8010554a:	89 d1                	mov    %edx,%ecx
8010554c:	fc                   	cld    
8010554d:	f3 aa                	rep stos %al,%es:(%edi)
8010554f:	89 ca                	mov    %ecx,%edx
80105551:	89 fb                	mov    %edi,%ebx
80105553:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105556:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105559:	90                   	nop
8010555a:	5b                   	pop    %ebx
8010555b:	5f                   	pop    %edi
8010555c:	5d                   	pop    %ebp
8010555d:	c3                   	ret    

8010555e <stosl>:
{
8010555e:	55                   	push   %ebp
8010555f:	89 e5                	mov    %esp,%ebp
80105561:	57                   	push   %edi
80105562:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105563:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105566:	8b 55 10             	mov    0x10(%ebp),%edx
80105569:	8b 45 0c             	mov    0xc(%ebp),%eax
8010556c:	89 cb                	mov    %ecx,%ebx
8010556e:	89 df                	mov    %ebx,%edi
80105570:	89 d1                	mov    %edx,%ecx
80105572:	fc                   	cld    
80105573:	f3 ab                	rep stos %eax,%es:(%edi)
80105575:	89 ca                	mov    %ecx,%edx
80105577:	89 fb                	mov    %edi,%ebx
80105579:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010557c:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010557f:	90                   	nop
80105580:	5b                   	pop    %ebx
80105581:	5f                   	pop    %edi
80105582:	5d                   	pop    %ebp
80105583:	c3                   	ret    

80105584 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105584:	f3 0f 1e fb          	endbr32 
80105588:	55                   	push   %ebp
80105589:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
8010558b:	8b 45 08             	mov    0x8(%ebp),%eax
8010558e:	83 e0 03             	and    $0x3,%eax
80105591:	85 c0                	test   %eax,%eax
80105593:	75 43                	jne    801055d8 <memset+0x54>
80105595:	8b 45 10             	mov    0x10(%ebp),%eax
80105598:	83 e0 03             	and    $0x3,%eax
8010559b:	85 c0                	test   %eax,%eax
8010559d:	75 39                	jne    801055d8 <memset+0x54>
    c &= 0xFF;
8010559f:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801055a6:	8b 45 10             	mov    0x10(%ebp),%eax
801055a9:	c1 e8 02             	shr    $0x2,%eax
801055ac:	89 c1                	mov    %eax,%ecx
801055ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801055b1:	c1 e0 18             	shl    $0x18,%eax
801055b4:	89 c2                	mov    %eax,%edx
801055b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801055b9:	c1 e0 10             	shl    $0x10,%eax
801055bc:	09 c2                	or     %eax,%edx
801055be:	8b 45 0c             	mov    0xc(%ebp),%eax
801055c1:	c1 e0 08             	shl    $0x8,%eax
801055c4:	09 d0                	or     %edx,%eax
801055c6:	0b 45 0c             	or     0xc(%ebp),%eax
801055c9:	51                   	push   %ecx
801055ca:	50                   	push   %eax
801055cb:	ff 75 08             	pushl  0x8(%ebp)
801055ce:	e8 8b ff ff ff       	call   8010555e <stosl>
801055d3:	83 c4 0c             	add    $0xc,%esp
801055d6:	eb 12                	jmp    801055ea <memset+0x66>
  } else
    stosb(dst, c, n);
801055d8:	8b 45 10             	mov    0x10(%ebp),%eax
801055db:	50                   	push   %eax
801055dc:	ff 75 0c             	pushl  0xc(%ebp)
801055df:	ff 75 08             	pushl  0x8(%ebp)
801055e2:	e8 51 ff ff ff       	call   80105538 <stosb>
801055e7:	83 c4 0c             	add    $0xc,%esp
  return dst;
801055ea:	8b 45 08             	mov    0x8(%ebp),%eax
}
801055ed:	c9                   	leave  
801055ee:	c3                   	ret    

801055ef <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801055ef:	f3 0f 1e fb          	endbr32 
801055f3:	55                   	push   %ebp
801055f4:	89 e5                	mov    %esp,%ebp
801055f6:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801055f9:	8b 45 08             	mov    0x8(%ebp),%eax
801055fc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801055ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80105602:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105605:	eb 30                	jmp    80105637 <memcmp+0x48>
    if(*s1 != *s2)
80105607:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010560a:	0f b6 10             	movzbl (%eax),%edx
8010560d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105610:	0f b6 00             	movzbl (%eax),%eax
80105613:	38 c2                	cmp    %al,%dl
80105615:	74 18                	je     8010562f <memcmp+0x40>
      return *s1 - *s2;
80105617:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010561a:	0f b6 00             	movzbl (%eax),%eax
8010561d:	0f b6 d0             	movzbl %al,%edx
80105620:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105623:	0f b6 00             	movzbl (%eax),%eax
80105626:	0f b6 c0             	movzbl %al,%eax
80105629:	29 c2                	sub    %eax,%edx
8010562b:	89 d0                	mov    %edx,%eax
8010562d:	eb 1a                	jmp    80105649 <memcmp+0x5a>
    s1++, s2++;
8010562f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105633:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80105637:	8b 45 10             	mov    0x10(%ebp),%eax
8010563a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010563d:	89 55 10             	mov    %edx,0x10(%ebp)
80105640:	85 c0                	test   %eax,%eax
80105642:	75 c3                	jne    80105607 <memcmp+0x18>
  }

  return 0;
80105644:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105649:	c9                   	leave  
8010564a:	c3                   	ret    

8010564b <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
8010564b:	f3 0f 1e fb          	endbr32 
8010564f:	55                   	push   %ebp
80105650:	89 e5                	mov    %esp,%ebp
80105652:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105655:	8b 45 0c             	mov    0xc(%ebp),%eax
80105658:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010565b:	8b 45 08             	mov    0x8(%ebp),%eax
8010565e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105661:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105664:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105667:	73 54                	jae    801056bd <memmove+0x72>
80105669:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010566c:	8b 45 10             	mov    0x10(%ebp),%eax
8010566f:	01 d0                	add    %edx,%eax
80105671:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80105674:	73 47                	jae    801056bd <memmove+0x72>
    s += n;
80105676:	8b 45 10             	mov    0x10(%ebp),%eax
80105679:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010567c:	8b 45 10             	mov    0x10(%ebp),%eax
8010567f:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105682:	eb 13                	jmp    80105697 <memmove+0x4c>
      *--d = *--s;
80105684:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105688:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010568c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010568f:	0f b6 10             	movzbl (%eax),%edx
80105692:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105695:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105697:	8b 45 10             	mov    0x10(%ebp),%eax
8010569a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010569d:	89 55 10             	mov    %edx,0x10(%ebp)
801056a0:	85 c0                	test   %eax,%eax
801056a2:	75 e0                	jne    80105684 <memmove+0x39>
  if(s < d && s + n > d){
801056a4:	eb 24                	jmp    801056ca <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
801056a6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801056a9:	8d 42 01             	lea    0x1(%edx),%eax
801056ac:	89 45 fc             	mov    %eax,-0x4(%ebp)
801056af:	8b 45 f8             	mov    -0x8(%ebp),%eax
801056b2:	8d 48 01             	lea    0x1(%eax),%ecx
801056b5:	89 4d f8             	mov    %ecx,-0x8(%ebp)
801056b8:	0f b6 12             	movzbl (%edx),%edx
801056bb:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801056bd:	8b 45 10             	mov    0x10(%ebp),%eax
801056c0:	8d 50 ff             	lea    -0x1(%eax),%edx
801056c3:	89 55 10             	mov    %edx,0x10(%ebp)
801056c6:	85 c0                	test   %eax,%eax
801056c8:	75 dc                	jne    801056a6 <memmove+0x5b>

  return dst;
801056ca:	8b 45 08             	mov    0x8(%ebp),%eax
}
801056cd:	c9                   	leave  
801056ce:	c3                   	ret    

801056cf <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801056cf:	f3 0f 1e fb          	endbr32 
801056d3:	55                   	push   %ebp
801056d4:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801056d6:	ff 75 10             	pushl  0x10(%ebp)
801056d9:	ff 75 0c             	pushl  0xc(%ebp)
801056dc:	ff 75 08             	pushl  0x8(%ebp)
801056df:	e8 67 ff ff ff       	call   8010564b <memmove>
801056e4:	83 c4 0c             	add    $0xc,%esp
}
801056e7:	c9                   	leave  
801056e8:	c3                   	ret    

801056e9 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801056e9:	f3 0f 1e fb          	endbr32 
801056ed:	55                   	push   %ebp
801056ee:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801056f0:	eb 0c                	jmp    801056fe <strncmp+0x15>
    n--, p++, q++;
801056f2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801056f6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801056fa:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
801056fe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105702:	74 1a                	je     8010571e <strncmp+0x35>
80105704:	8b 45 08             	mov    0x8(%ebp),%eax
80105707:	0f b6 00             	movzbl (%eax),%eax
8010570a:	84 c0                	test   %al,%al
8010570c:	74 10                	je     8010571e <strncmp+0x35>
8010570e:	8b 45 08             	mov    0x8(%ebp),%eax
80105711:	0f b6 10             	movzbl (%eax),%edx
80105714:	8b 45 0c             	mov    0xc(%ebp),%eax
80105717:	0f b6 00             	movzbl (%eax),%eax
8010571a:	38 c2                	cmp    %al,%dl
8010571c:	74 d4                	je     801056f2 <strncmp+0x9>
  if(n == 0)
8010571e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105722:	75 07                	jne    8010572b <strncmp+0x42>
    return 0;
80105724:	b8 00 00 00 00       	mov    $0x0,%eax
80105729:	eb 16                	jmp    80105741 <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
8010572b:	8b 45 08             	mov    0x8(%ebp),%eax
8010572e:	0f b6 00             	movzbl (%eax),%eax
80105731:	0f b6 d0             	movzbl %al,%edx
80105734:	8b 45 0c             	mov    0xc(%ebp),%eax
80105737:	0f b6 00             	movzbl (%eax),%eax
8010573a:	0f b6 c0             	movzbl %al,%eax
8010573d:	29 c2                	sub    %eax,%edx
8010573f:	89 d0                	mov    %edx,%eax
}
80105741:	5d                   	pop    %ebp
80105742:	c3                   	ret    

80105743 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105743:	f3 0f 1e fb          	endbr32 
80105747:	55                   	push   %ebp
80105748:	89 e5                	mov    %esp,%ebp
8010574a:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010574d:	8b 45 08             	mov    0x8(%ebp),%eax
80105750:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105753:	90                   	nop
80105754:	8b 45 10             	mov    0x10(%ebp),%eax
80105757:	8d 50 ff             	lea    -0x1(%eax),%edx
8010575a:	89 55 10             	mov    %edx,0x10(%ebp)
8010575d:	85 c0                	test   %eax,%eax
8010575f:	7e 2c                	jle    8010578d <strncpy+0x4a>
80105761:	8b 55 0c             	mov    0xc(%ebp),%edx
80105764:	8d 42 01             	lea    0x1(%edx),%eax
80105767:	89 45 0c             	mov    %eax,0xc(%ebp)
8010576a:	8b 45 08             	mov    0x8(%ebp),%eax
8010576d:	8d 48 01             	lea    0x1(%eax),%ecx
80105770:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105773:	0f b6 12             	movzbl (%edx),%edx
80105776:	88 10                	mov    %dl,(%eax)
80105778:	0f b6 00             	movzbl (%eax),%eax
8010577b:	84 c0                	test   %al,%al
8010577d:	75 d5                	jne    80105754 <strncpy+0x11>
    ;
  while(n-- > 0)
8010577f:	eb 0c                	jmp    8010578d <strncpy+0x4a>
    *s++ = 0;
80105781:	8b 45 08             	mov    0x8(%ebp),%eax
80105784:	8d 50 01             	lea    0x1(%eax),%edx
80105787:	89 55 08             	mov    %edx,0x8(%ebp)
8010578a:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
8010578d:	8b 45 10             	mov    0x10(%ebp),%eax
80105790:	8d 50 ff             	lea    -0x1(%eax),%edx
80105793:	89 55 10             	mov    %edx,0x10(%ebp)
80105796:	85 c0                	test   %eax,%eax
80105798:	7f e7                	jg     80105781 <strncpy+0x3e>
  return os;
8010579a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010579d:	c9                   	leave  
8010579e:	c3                   	ret    

8010579f <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010579f:	f3 0f 1e fb          	endbr32 
801057a3:	55                   	push   %ebp
801057a4:	89 e5                	mov    %esp,%ebp
801057a6:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801057a9:	8b 45 08             	mov    0x8(%ebp),%eax
801057ac:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801057af:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057b3:	7f 05                	jg     801057ba <safestrcpy+0x1b>
    return os;
801057b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057b8:	eb 31                	jmp    801057eb <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
801057ba:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801057be:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057c2:	7e 1e                	jle    801057e2 <safestrcpy+0x43>
801057c4:	8b 55 0c             	mov    0xc(%ebp),%edx
801057c7:	8d 42 01             	lea    0x1(%edx),%eax
801057ca:	89 45 0c             	mov    %eax,0xc(%ebp)
801057cd:	8b 45 08             	mov    0x8(%ebp),%eax
801057d0:	8d 48 01             	lea    0x1(%eax),%ecx
801057d3:	89 4d 08             	mov    %ecx,0x8(%ebp)
801057d6:	0f b6 12             	movzbl (%edx),%edx
801057d9:	88 10                	mov    %dl,(%eax)
801057db:	0f b6 00             	movzbl (%eax),%eax
801057de:	84 c0                	test   %al,%al
801057e0:	75 d8                	jne    801057ba <safestrcpy+0x1b>
    ;
  *s = 0;
801057e2:	8b 45 08             	mov    0x8(%ebp),%eax
801057e5:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801057e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057eb:	c9                   	leave  
801057ec:	c3                   	ret    

801057ed <strlen>:

int
strlen(const char *s)
{
801057ed:	f3 0f 1e fb          	endbr32 
801057f1:	55                   	push   %ebp
801057f2:	89 e5                	mov    %esp,%ebp
801057f4:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801057f7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801057fe:	eb 04                	jmp    80105804 <strlen+0x17>
80105800:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105804:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105807:	8b 45 08             	mov    0x8(%ebp),%eax
8010580a:	01 d0                	add    %edx,%eax
8010580c:	0f b6 00             	movzbl (%eax),%eax
8010580f:	84 c0                	test   %al,%al
80105811:	75 ed                	jne    80105800 <strlen+0x13>
    ;
  return n;
80105813:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105816:	c9                   	leave  
80105817:	c3                   	ret    

80105818 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105818:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010581c:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80105820:	55                   	push   %ebp
  pushl %ebx
80105821:	53                   	push   %ebx
  pushl %esi
80105822:	56                   	push   %esi
  pushl %edi
80105823:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105824:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105826:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80105828:	5f                   	pop    %edi
  popl %esi
80105829:	5e                   	pop    %esi
  popl %ebx
8010582a:	5b                   	pop    %ebx
  popl %ebp
8010582b:	5d                   	pop    %ebp
  ret
8010582c:	c3                   	ret    

8010582d <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010582d:	f3 0f 1e fb          	endbr32 
80105831:	55                   	push   %ebp
80105832:	89 e5                	mov    %esp,%ebp
80105834:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105837:	e8 bd ec ff ff       	call   801044f9 <myproc>
8010583c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
8010583f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105842:	8b 00                	mov    (%eax),%eax
80105844:	39 45 08             	cmp    %eax,0x8(%ebp)
80105847:	73 0f                	jae    80105858 <fetchint+0x2b>
80105849:	8b 45 08             	mov    0x8(%ebp),%eax
8010584c:	8d 50 04             	lea    0x4(%eax),%edx
8010584f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105852:	8b 00                	mov    (%eax),%eax
80105854:	39 c2                	cmp    %eax,%edx
80105856:	76 07                	jbe    8010585f <fetchint+0x32>
    return -1;
80105858:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010585d:	eb 0f                	jmp    8010586e <fetchint+0x41>
  *ip = *(int*)(addr);
8010585f:	8b 45 08             	mov    0x8(%ebp),%eax
80105862:	8b 10                	mov    (%eax),%edx
80105864:	8b 45 0c             	mov    0xc(%ebp),%eax
80105867:	89 10                	mov    %edx,(%eax)
  return 0;
80105869:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010586e:	c9                   	leave  
8010586f:	c3                   	ret    

80105870 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105870:	f3 0f 1e fb          	endbr32 
80105874:	55                   	push   %ebp
80105875:	89 e5                	mov    %esp,%ebp
80105877:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
8010587a:	e8 7a ec ff ff       	call   801044f9 <myproc>
8010587f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105882:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105885:	8b 00                	mov    (%eax),%eax
80105887:	39 45 08             	cmp    %eax,0x8(%ebp)
8010588a:	72 07                	jb     80105893 <fetchstr+0x23>
    return -1;
8010588c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105891:	eb 43                	jmp    801058d6 <fetchstr+0x66>
  *pp = (char*)addr;
80105893:	8b 55 08             	mov    0x8(%ebp),%edx
80105896:	8b 45 0c             	mov    0xc(%ebp),%eax
80105899:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
8010589b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010589e:	8b 00                	mov    (%eax),%eax
801058a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
801058a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801058a6:	8b 00                	mov    (%eax),%eax
801058a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058ab:	eb 1c                	jmp    801058c9 <fetchstr+0x59>
    if(*s == 0)
801058ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058b0:	0f b6 00             	movzbl (%eax),%eax
801058b3:	84 c0                	test   %al,%al
801058b5:	75 0e                	jne    801058c5 <fetchstr+0x55>
      return s - *pp;
801058b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801058ba:	8b 00                	mov    (%eax),%eax
801058bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058bf:	29 c2                	sub    %eax,%edx
801058c1:	89 d0                	mov    %edx,%eax
801058c3:	eb 11                	jmp    801058d6 <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
801058c5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801058c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058cc:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801058cf:	72 dc                	jb     801058ad <fetchstr+0x3d>
  }
  return -1;
801058d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801058d6:	c9                   	leave  
801058d7:	c3                   	ret    

801058d8 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801058d8:	f3 0f 1e fb          	endbr32 
801058dc:	55                   	push   %ebp
801058dd:	89 e5                	mov    %esp,%ebp
801058df:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801058e2:	e8 12 ec ff ff       	call   801044f9 <myproc>
801058e7:	8b 40 18             	mov    0x18(%eax),%eax
801058ea:	8b 40 44             	mov    0x44(%eax),%eax
801058ed:	8b 55 08             	mov    0x8(%ebp),%edx
801058f0:	c1 e2 02             	shl    $0x2,%edx
801058f3:	01 d0                	add    %edx,%eax
801058f5:	83 c0 04             	add    $0x4,%eax
801058f8:	83 ec 08             	sub    $0x8,%esp
801058fb:	ff 75 0c             	pushl  0xc(%ebp)
801058fe:	50                   	push   %eax
801058ff:	e8 29 ff ff ff       	call   8010582d <fetchint>
80105904:	83 c4 10             	add    $0x10,%esp
}
80105907:	c9                   	leave  
80105908:	c3                   	ret    

80105909 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105909:	f3 0f 1e fb          	endbr32 
8010590d:	55                   	push   %ebp
8010590e:	89 e5                	mov    %esp,%ebp
80105910:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80105913:	e8 e1 eb ff ff       	call   801044f9 <myproc>
80105918:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
8010591b:	83 ec 08             	sub    $0x8,%esp
8010591e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105921:	50                   	push   %eax
80105922:	ff 75 08             	pushl  0x8(%ebp)
80105925:	e8 ae ff ff ff       	call   801058d8 <argint>
8010592a:	83 c4 10             	add    $0x10,%esp
8010592d:	85 c0                	test   %eax,%eax
8010592f:	79 07                	jns    80105938 <argptr+0x2f>
    return -1;
80105931:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105936:	eb 3b                	jmp    80105973 <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105938:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010593c:	78 1f                	js     8010595d <argptr+0x54>
8010593e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105941:	8b 00                	mov    (%eax),%eax
80105943:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105946:	39 d0                	cmp    %edx,%eax
80105948:	76 13                	jbe    8010595d <argptr+0x54>
8010594a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010594d:	89 c2                	mov    %eax,%edx
8010594f:	8b 45 10             	mov    0x10(%ebp),%eax
80105952:	01 c2                	add    %eax,%edx
80105954:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105957:	8b 00                	mov    (%eax),%eax
80105959:	39 c2                	cmp    %eax,%edx
8010595b:	76 07                	jbe    80105964 <argptr+0x5b>
    return -1;
8010595d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105962:	eb 0f                	jmp    80105973 <argptr+0x6a>
  *pp = (char*)i;
80105964:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105967:	89 c2                	mov    %eax,%edx
80105969:	8b 45 0c             	mov    0xc(%ebp),%eax
8010596c:	89 10                	mov    %edx,(%eax)
  return 0;
8010596e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105973:	c9                   	leave  
80105974:	c3                   	ret    

80105975 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105975:	f3 0f 1e fb          	endbr32 
80105979:	55                   	push   %ebp
8010597a:	89 e5                	mov    %esp,%ebp
8010597c:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010597f:	83 ec 08             	sub    $0x8,%esp
80105982:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105985:	50                   	push   %eax
80105986:	ff 75 08             	pushl  0x8(%ebp)
80105989:	e8 4a ff ff ff       	call   801058d8 <argint>
8010598e:	83 c4 10             	add    $0x10,%esp
80105991:	85 c0                	test   %eax,%eax
80105993:	79 07                	jns    8010599c <argstr+0x27>
    return -1;
80105995:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010599a:	eb 12                	jmp    801059ae <argstr+0x39>
  return fetchstr(addr, pp);
8010599c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010599f:	83 ec 08             	sub    $0x8,%esp
801059a2:	ff 75 0c             	pushl  0xc(%ebp)
801059a5:	50                   	push   %eax
801059a6:	e8 c5 fe ff ff       	call   80105870 <fetchstr>
801059ab:	83 c4 10             	add    $0x10,%esp
}
801059ae:	c9                   	leave  
801059af:	c3                   	ret    

801059b0 <syscall>:
[SYS_dump_rawphymem] sys_dump_rawphymem,
};

void
syscall(void)
{
801059b0:	f3 0f 1e fb          	endbr32 
801059b4:	55                   	push   %ebp
801059b5:	89 e5                	mov    %esp,%ebp
801059b7:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
801059ba:	e8 3a eb ff ff       	call   801044f9 <myproc>
801059bf:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801059c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c5:	8b 40 18             	mov    0x18(%eax),%eax
801059c8:	8b 40 1c             	mov    0x1c(%eax),%eax
801059cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801059ce:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059d2:	7e 2f                	jle    80105a03 <syscall+0x53>
801059d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059d7:	83 f8 18             	cmp    $0x18,%eax
801059da:	77 27                	ja     80105a03 <syscall+0x53>
801059dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059df:	8b 04 85 20 d0 10 80 	mov    -0x7fef2fe0(,%eax,4),%eax
801059e6:	85 c0                	test   %eax,%eax
801059e8:	74 19                	je     80105a03 <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
801059ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059ed:	8b 04 85 20 d0 10 80 	mov    -0x7fef2fe0(,%eax,4),%eax
801059f4:	ff d0                	call   *%eax
801059f6:	89 c2                	mov    %eax,%edx
801059f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059fb:	8b 40 18             	mov    0x18(%eax),%eax
801059fe:	89 50 1c             	mov    %edx,0x1c(%eax)
80105a01:	eb 2c                	jmp    80105a2f <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a06:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80105a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a0c:	8b 40 10             	mov    0x10(%eax),%eax
80105a0f:	ff 75 f0             	pushl  -0x10(%ebp)
80105a12:	52                   	push   %edx
80105a13:	50                   	push   %eax
80105a14:	68 42 9a 10 80       	push   $0x80109a42
80105a19:	e8 fa a9 ff ff       	call   80100418 <cprintf>
80105a1e:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105a21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a24:	8b 40 18             	mov    0x18(%eax),%eax
80105a27:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105a2e:	90                   	nop
80105a2f:	90                   	nop
80105a30:	c9                   	leave  
80105a31:	c3                   	ret    

80105a32 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105a32:	f3 0f 1e fb          	endbr32 
80105a36:	55                   	push   %ebp
80105a37:	89 e5                	mov    %esp,%ebp
80105a39:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105a3c:	83 ec 08             	sub    $0x8,%esp
80105a3f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a42:	50                   	push   %eax
80105a43:	ff 75 08             	pushl  0x8(%ebp)
80105a46:	e8 8d fe ff ff       	call   801058d8 <argint>
80105a4b:	83 c4 10             	add    $0x10,%esp
80105a4e:	85 c0                	test   %eax,%eax
80105a50:	79 07                	jns    80105a59 <argfd+0x27>
    return -1;
80105a52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a57:	eb 4f                	jmp    80105aa8 <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105a59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a5c:	85 c0                	test   %eax,%eax
80105a5e:	78 20                	js     80105a80 <argfd+0x4e>
80105a60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a63:	83 f8 0f             	cmp    $0xf,%eax
80105a66:	7f 18                	jg     80105a80 <argfd+0x4e>
80105a68:	e8 8c ea ff ff       	call   801044f9 <myproc>
80105a6d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a70:	83 c2 08             	add    $0x8,%edx
80105a73:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105a77:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a7a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a7e:	75 07                	jne    80105a87 <argfd+0x55>
    return -1;
80105a80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a85:	eb 21                	jmp    80105aa8 <argfd+0x76>
  if(pfd)
80105a87:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105a8b:	74 08                	je     80105a95 <argfd+0x63>
    *pfd = fd;
80105a8d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a90:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a93:	89 10                	mov    %edx,(%eax)
  if(pf)
80105a95:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105a99:	74 08                	je     80105aa3 <argfd+0x71>
    *pf = f;
80105a9b:	8b 45 10             	mov    0x10(%ebp),%eax
80105a9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105aa1:	89 10                	mov    %edx,(%eax)
  return 0;
80105aa3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105aa8:	c9                   	leave  
80105aa9:	c3                   	ret    

80105aaa <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105aaa:	f3 0f 1e fb          	endbr32 
80105aae:	55                   	push   %ebp
80105aaf:	89 e5                	mov    %esp,%ebp
80105ab1:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105ab4:	e8 40 ea ff ff       	call   801044f9 <myproc>
80105ab9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105abc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105ac3:	eb 2a                	jmp    80105aef <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
80105ac5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ac8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105acb:	83 c2 08             	add    $0x8,%edx
80105ace:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105ad2:	85 c0                	test   %eax,%eax
80105ad4:	75 15                	jne    80105aeb <fdalloc+0x41>
      curproc->ofile[fd] = f;
80105ad6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ad9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105adc:	8d 4a 08             	lea    0x8(%edx),%ecx
80105adf:	8b 55 08             	mov    0x8(%ebp),%edx
80105ae2:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ae9:	eb 0f                	jmp    80105afa <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80105aeb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105aef:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105af3:	7e d0                	jle    80105ac5 <fdalloc+0x1b>
    }
  }
  return -1;
80105af5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105afa:	c9                   	leave  
80105afb:	c3                   	ret    

80105afc <sys_dup>:

int
sys_dup(void)
{
80105afc:	f3 0f 1e fb          	endbr32 
80105b00:	55                   	push   %ebp
80105b01:	89 e5                	mov    %esp,%ebp
80105b03:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105b06:	83 ec 04             	sub    $0x4,%esp
80105b09:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b0c:	50                   	push   %eax
80105b0d:	6a 00                	push   $0x0
80105b0f:	6a 00                	push   $0x0
80105b11:	e8 1c ff ff ff       	call   80105a32 <argfd>
80105b16:	83 c4 10             	add    $0x10,%esp
80105b19:	85 c0                	test   %eax,%eax
80105b1b:	79 07                	jns    80105b24 <sys_dup+0x28>
    return -1;
80105b1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b22:	eb 31                	jmp    80105b55 <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
80105b24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b27:	83 ec 0c             	sub    $0xc,%esp
80105b2a:	50                   	push   %eax
80105b2b:	e8 7a ff ff ff       	call   80105aaa <fdalloc>
80105b30:	83 c4 10             	add    $0x10,%esp
80105b33:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b36:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b3a:	79 07                	jns    80105b43 <sys_dup+0x47>
    return -1;
80105b3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b41:	eb 12                	jmp    80105b55 <sys_dup+0x59>
  filedup(f);
80105b43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b46:	83 ec 0c             	sub    $0xc,%esp
80105b49:	50                   	push   %eax
80105b4a:	e8 21 b6 ff ff       	call   80101170 <filedup>
80105b4f:	83 c4 10             	add    $0x10,%esp
  return fd;
80105b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105b55:	c9                   	leave  
80105b56:	c3                   	ret    

80105b57 <sys_read>:

int
sys_read(void)
{
80105b57:	f3 0f 1e fb          	endbr32 
80105b5b:	55                   	push   %ebp
80105b5c:	89 e5                	mov    %esp,%ebp
80105b5e:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b61:	83 ec 04             	sub    $0x4,%esp
80105b64:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b67:	50                   	push   %eax
80105b68:	6a 00                	push   $0x0
80105b6a:	6a 00                	push   $0x0
80105b6c:	e8 c1 fe ff ff       	call   80105a32 <argfd>
80105b71:	83 c4 10             	add    $0x10,%esp
80105b74:	85 c0                	test   %eax,%eax
80105b76:	78 2e                	js     80105ba6 <sys_read+0x4f>
80105b78:	83 ec 08             	sub    $0x8,%esp
80105b7b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b7e:	50                   	push   %eax
80105b7f:	6a 02                	push   $0x2
80105b81:	e8 52 fd ff ff       	call   801058d8 <argint>
80105b86:	83 c4 10             	add    $0x10,%esp
80105b89:	85 c0                	test   %eax,%eax
80105b8b:	78 19                	js     80105ba6 <sys_read+0x4f>
80105b8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b90:	83 ec 04             	sub    $0x4,%esp
80105b93:	50                   	push   %eax
80105b94:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b97:	50                   	push   %eax
80105b98:	6a 01                	push   $0x1
80105b9a:	e8 6a fd ff ff       	call   80105909 <argptr>
80105b9f:	83 c4 10             	add    $0x10,%esp
80105ba2:	85 c0                	test   %eax,%eax
80105ba4:	79 07                	jns    80105bad <sys_read+0x56>
    return -1;
80105ba6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bab:	eb 17                	jmp    80105bc4 <sys_read+0x6d>
  return fileread(f, p, n);
80105bad:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105bb0:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bb6:	83 ec 04             	sub    $0x4,%esp
80105bb9:	51                   	push   %ecx
80105bba:	52                   	push   %edx
80105bbb:	50                   	push   %eax
80105bbc:	e8 4b b7 ff ff       	call   8010130c <fileread>
80105bc1:	83 c4 10             	add    $0x10,%esp
}
80105bc4:	c9                   	leave  
80105bc5:	c3                   	ret    

80105bc6 <sys_write>:

int
sys_write(void)
{
80105bc6:	f3 0f 1e fb          	endbr32 
80105bca:	55                   	push   %ebp
80105bcb:	89 e5                	mov    %esp,%ebp
80105bcd:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105bd0:	83 ec 04             	sub    $0x4,%esp
80105bd3:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bd6:	50                   	push   %eax
80105bd7:	6a 00                	push   $0x0
80105bd9:	6a 00                	push   $0x0
80105bdb:	e8 52 fe ff ff       	call   80105a32 <argfd>
80105be0:	83 c4 10             	add    $0x10,%esp
80105be3:	85 c0                	test   %eax,%eax
80105be5:	78 2e                	js     80105c15 <sys_write+0x4f>
80105be7:	83 ec 08             	sub    $0x8,%esp
80105bea:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bed:	50                   	push   %eax
80105bee:	6a 02                	push   $0x2
80105bf0:	e8 e3 fc ff ff       	call   801058d8 <argint>
80105bf5:	83 c4 10             	add    $0x10,%esp
80105bf8:	85 c0                	test   %eax,%eax
80105bfa:	78 19                	js     80105c15 <sys_write+0x4f>
80105bfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bff:	83 ec 04             	sub    $0x4,%esp
80105c02:	50                   	push   %eax
80105c03:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c06:	50                   	push   %eax
80105c07:	6a 01                	push   $0x1
80105c09:	e8 fb fc ff ff       	call   80105909 <argptr>
80105c0e:	83 c4 10             	add    $0x10,%esp
80105c11:	85 c0                	test   %eax,%eax
80105c13:	79 07                	jns    80105c1c <sys_write+0x56>
    return -1;
80105c15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c1a:	eb 17                	jmp    80105c33 <sys_write+0x6d>
  return filewrite(f, p, n);
80105c1c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105c1f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c25:	83 ec 04             	sub    $0x4,%esp
80105c28:	51                   	push   %ecx
80105c29:	52                   	push   %edx
80105c2a:	50                   	push   %eax
80105c2b:	e8 98 b7 ff ff       	call   801013c8 <filewrite>
80105c30:	83 c4 10             	add    $0x10,%esp
}
80105c33:	c9                   	leave  
80105c34:	c3                   	ret    

80105c35 <sys_close>:

int
sys_close(void)
{
80105c35:	f3 0f 1e fb          	endbr32 
80105c39:	55                   	push   %ebp
80105c3a:	89 e5                	mov    %esp,%ebp
80105c3c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105c3f:	83 ec 04             	sub    $0x4,%esp
80105c42:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c45:	50                   	push   %eax
80105c46:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c49:	50                   	push   %eax
80105c4a:	6a 00                	push   $0x0
80105c4c:	e8 e1 fd ff ff       	call   80105a32 <argfd>
80105c51:	83 c4 10             	add    $0x10,%esp
80105c54:	85 c0                	test   %eax,%eax
80105c56:	79 07                	jns    80105c5f <sys_close+0x2a>
    return -1;
80105c58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c5d:	eb 27                	jmp    80105c86 <sys_close+0x51>
  myproc()->ofile[fd] = 0;
80105c5f:	e8 95 e8 ff ff       	call   801044f9 <myproc>
80105c64:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c67:	83 c2 08             	add    $0x8,%edx
80105c6a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105c71:	00 
  fileclose(f);
80105c72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c75:	83 ec 0c             	sub    $0xc,%esp
80105c78:	50                   	push   %eax
80105c79:	e8 47 b5 ff ff       	call   801011c5 <fileclose>
80105c7e:	83 c4 10             	add    $0x10,%esp
  return 0;
80105c81:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c86:	c9                   	leave  
80105c87:	c3                   	ret    

80105c88 <sys_fstat>:

int
sys_fstat(void)
{
80105c88:	f3 0f 1e fb          	endbr32 
80105c8c:	55                   	push   %ebp
80105c8d:	89 e5                	mov    %esp,%ebp
80105c8f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105c92:	83 ec 04             	sub    $0x4,%esp
80105c95:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c98:	50                   	push   %eax
80105c99:	6a 00                	push   $0x0
80105c9b:	6a 00                	push   $0x0
80105c9d:	e8 90 fd ff ff       	call   80105a32 <argfd>
80105ca2:	83 c4 10             	add    $0x10,%esp
80105ca5:	85 c0                	test   %eax,%eax
80105ca7:	78 17                	js     80105cc0 <sys_fstat+0x38>
80105ca9:	83 ec 04             	sub    $0x4,%esp
80105cac:	6a 14                	push   $0x14
80105cae:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cb1:	50                   	push   %eax
80105cb2:	6a 01                	push   $0x1
80105cb4:	e8 50 fc ff ff       	call   80105909 <argptr>
80105cb9:	83 c4 10             	add    $0x10,%esp
80105cbc:	85 c0                	test   %eax,%eax
80105cbe:	79 07                	jns    80105cc7 <sys_fstat+0x3f>
    return -1;
80105cc0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cc5:	eb 13                	jmp    80105cda <sys_fstat+0x52>
  return filestat(f, st);
80105cc7:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ccd:	83 ec 08             	sub    $0x8,%esp
80105cd0:	52                   	push   %edx
80105cd1:	50                   	push   %eax
80105cd2:	e8 da b5 ff ff       	call   801012b1 <filestat>
80105cd7:	83 c4 10             	add    $0x10,%esp
}
80105cda:	c9                   	leave  
80105cdb:	c3                   	ret    

80105cdc <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105cdc:	f3 0f 1e fb          	endbr32 
80105ce0:	55                   	push   %ebp
80105ce1:	89 e5                	mov    %esp,%ebp
80105ce3:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105ce6:	83 ec 08             	sub    $0x8,%esp
80105ce9:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105cec:	50                   	push   %eax
80105ced:	6a 00                	push   $0x0
80105cef:	e8 81 fc ff ff       	call   80105975 <argstr>
80105cf4:	83 c4 10             	add    $0x10,%esp
80105cf7:	85 c0                	test   %eax,%eax
80105cf9:	78 15                	js     80105d10 <sys_link+0x34>
80105cfb:	83 ec 08             	sub    $0x8,%esp
80105cfe:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105d01:	50                   	push   %eax
80105d02:	6a 01                	push   $0x1
80105d04:	e8 6c fc ff ff       	call   80105975 <argstr>
80105d09:	83 c4 10             	add    $0x10,%esp
80105d0c:	85 c0                	test   %eax,%eax
80105d0e:	79 0a                	jns    80105d1a <sys_link+0x3e>
    return -1;
80105d10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d15:	e9 68 01 00 00       	jmp    80105e82 <sys_link+0x1a6>

  begin_op();
80105d1a:	e8 1b da ff ff       	call   8010373a <begin_op>
  if((ip = namei(old)) == 0){
80105d1f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105d22:	83 ec 0c             	sub    $0xc,%esp
80105d25:	50                   	push   %eax
80105d26:	e8 85 c9 ff ff       	call   801026b0 <namei>
80105d2b:	83 c4 10             	add    $0x10,%esp
80105d2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d31:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d35:	75 0f                	jne    80105d46 <sys_link+0x6a>
    end_op();
80105d37:	e8 8e da ff ff       	call   801037ca <end_op>
    return -1;
80105d3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d41:	e9 3c 01 00 00       	jmp    80105e82 <sys_link+0x1a6>
  }

  ilock(ip);
80105d46:	83 ec 0c             	sub    $0xc,%esp
80105d49:	ff 75 f4             	pushl  -0xc(%ebp)
80105d4c:	e8 f4 bd ff ff       	call   80101b45 <ilock>
80105d51:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d57:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d5b:	66 83 f8 01          	cmp    $0x1,%ax
80105d5f:	75 1d                	jne    80105d7e <sys_link+0xa2>
    iunlockput(ip);
80105d61:	83 ec 0c             	sub    $0xc,%esp
80105d64:	ff 75 f4             	pushl  -0xc(%ebp)
80105d67:	e8 16 c0 ff ff       	call   80101d82 <iunlockput>
80105d6c:	83 c4 10             	add    $0x10,%esp
    end_op();
80105d6f:	e8 56 da ff ff       	call   801037ca <end_op>
    return -1;
80105d74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d79:	e9 04 01 00 00       	jmp    80105e82 <sys_link+0x1a6>
  }

  ip->nlink++;
80105d7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d81:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105d85:	83 c0 01             	add    $0x1,%eax
80105d88:	89 c2                	mov    %eax,%edx
80105d8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d8d:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105d91:	83 ec 0c             	sub    $0xc,%esp
80105d94:	ff 75 f4             	pushl  -0xc(%ebp)
80105d97:	e8 c0 bb ff ff       	call   8010195c <iupdate>
80105d9c:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105d9f:	83 ec 0c             	sub    $0xc,%esp
80105da2:	ff 75 f4             	pushl  -0xc(%ebp)
80105da5:	e8 b2 be ff ff       	call   80101c5c <iunlock>
80105daa:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105dad:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105db0:	83 ec 08             	sub    $0x8,%esp
80105db3:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105db6:	52                   	push   %edx
80105db7:	50                   	push   %eax
80105db8:	e8 13 c9 ff ff       	call   801026d0 <nameiparent>
80105dbd:	83 c4 10             	add    $0x10,%esp
80105dc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105dc3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105dc7:	74 71                	je     80105e3a <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105dc9:	83 ec 0c             	sub    $0xc,%esp
80105dcc:	ff 75 f0             	pushl  -0x10(%ebp)
80105dcf:	e8 71 bd ff ff       	call   80101b45 <ilock>
80105dd4:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105dd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dda:	8b 10                	mov    (%eax),%edx
80105ddc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ddf:	8b 00                	mov    (%eax),%eax
80105de1:	39 c2                	cmp    %eax,%edx
80105de3:	75 1d                	jne    80105e02 <sys_link+0x126>
80105de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de8:	8b 40 04             	mov    0x4(%eax),%eax
80105deb:	83 ec 04             	sub    $0x4,%esp
80105dee:	50                   	push   %eax
80105def:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105df2:	50                   	push   %eax
80105df3:	ff 75 f0             	pushl  -0x10(%ebp)
80105df6:	e8 12 c6 ff ff       	call   8010240d <dirlink>
80105dfb:	83 c4 10             	add    $0x10,%esp
80105dfe:	85 c0                	test   %eax,%eax
80105e00:	79 10                	jns    80105e12 <sys_link+0x136>
    iunlockput(dp);
80105e02:	83 ec 0c             	sub    $0xc,%esp
80105e05:	ff 75 f0             	pushl  -0x10(%ebp)
80105e08:	e8 75 bf ff ff       	call   80101d82 <iunlockput>
80105e0d:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105e10:	eb 29                	jmp    80105e3b <sys_link+0x15f>
  }
  iunlockput(dp);
80105e12:	83 ec 0c             	sub    $0xc,%esp
80105e15:	ff 75 f0             	pushl  -0x10(%ebp)
80105e18:	e8 65 bf ff ff       	call   80101d82 <iunlockput>
80105e1d:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105e20:	83 ec 0c             	sub    $0xc,%esp
80105e23:	ff 75 f4             	pushl  -0xc(%ebp)
80105e26:	e8 83 be ff ff       	call   80101cae <iput>
80105e2b:	83 c4 10             	add    $0x10,%esp

  end_op();
80105e2e:	e8 97 d9 ff ff       	call   801037ca <end_op>

  return 0;
80105e33:	b8 00 00 00 00       	mov    $0x0,%eax
80105e38:	eb 48                	jmp    80105e82 <sys_link+0x1a6>
    goto bad;
80105e3a:	90                   	nop

bad:
  ilock(ip);
80105e3b:	83 ec 0c             	sub    $0xc,%esp
80105e3e:	ff 75 f4             	pushl  -0xc(%ebp)
80105e41:	e8 ff bc ff ff       	call   80101b45 <ilock>
80105e46:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105e49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e4c:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105e50:	83 e8 01             	sub    $0x1,%eax
80105e53:	89 c2                	mov    %eax,%edx
80105e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e58:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105e5c:	83 ec 0c             	sub    $0xc,%esp
80105e5f:	ff 75 f4             	pushl  -0xc(%ebp)
80105e62:	e8 f5 ba ff ff       	call   8010195c <iupdate>
80105e67:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105e6a:	83 ec 0c             	sub    $0xc,%esp
80105e6d:	ff 75 f4             	pushl  -0xc(%ebp)
80105e70:	e8 0d bf ff ff       	call   80101d82 <iunlockput>
80105e75:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e78:	e8 4d d9 ff ff       	call   801037ca <end_op>
  return -1;
80105e7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e82:	c9                   	leave  
80105e83:	c3                   	ret    

80105e84 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105e84:	f3 0f 1e fb          	endbr32 
80105e88:	55                   	push   %ebp
80105e89:	89 e5                	mov    %esp,%ebp
80105e8b:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105e8e:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105e95:	eb 40                	jmp    80105ed7 <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105e97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e9a:	6a 10                	push   $0x10
80105e9c:	50                   	push   %eax
80105e9d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105ea0:	50                   	push   %eax
80105ea1:	ff 75 08             	pushl  0x8(%ebp)
80105ea4:	e8 a4 c1 ff ff       	call   8010204d <readi>
80105ea9:	83 c4 10             	add    $0x10,%esp
80105eac:	83 f8 10             	cmp    $0x10,%eax
80105eaf:	74 0d                	je     80105ebe <isdirempty+0x3a>
      panic("isdirempty: readi");
80105eb1:	83 ec 0c             	sub    $0xc,%esp
80105eb4:	68 5e 9a 10 80       	push   $0x80109a5e
80105eb9:	e8 4a a7 ff ff       	call   80100608 <panic>
    if(de.inum != 0)
80105ebe:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105ec2:	66 85 c0             	test   %ax,%ax
80105ec5:	74 07                	je     80105ece <isdirempty+0x4a>
      return 0;
80105ec7:	b8 00 00 00 00       	mov    $0x0,%eax
80105ecc:	eb 1b                	jmp    80105ee9 <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ed1:	83 c0 10             	add    $0x10,%eax
80105ed4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ed7:	8b 45 08             	mov    0x8(%ebp),%eax
80105eda:	8b 50 58             	mov    0x58(%eax),%edx
80105edd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ee0:	39 c2                	cmp    %eax,%edx
80105ee2:	77 b3                	ja     80105e97 <isdirempty+0x13>
  }
  return 1;
80105ee4:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105ee9:	c9                   	leave  
80105eea:	c3                   	ret    

80105eeb <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105eeb:	f3 0f 1e fb          	endbr32 
80105eef:	55                   	push   %ebp
80105ef0:	89 e5                	mov    %esp,%ebp
80105ef2:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105ef5:	83 ec 08             	sub    $0x8,%esp
80105ef8:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105efb:	50                   	push   %eax
80105efc:	6a 00                	push   $0x0
80105efe:	e8 72 fa ff ff       	call   80105975 <argstr>
80105f03:	83 c4 10             	add    $0x10,%esp
80105f06:	85 c0                	test   %eax,%eax
80105f08:	79 0a                	jns    80105f14 <sys_unlink+0x29>
    return -1;
80105f0a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f0f:	e9 bf 01 00 00       	jmp    801060d3 <sys_unlink+0x1e8>

  begin_op();
80105f14:	e8 21 d8 ff ff       	call   8010373a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105f19:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105f1c:	83 ec 08             	sub    $0x8,%esp
80105f1f:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105f22:	52                   	push   %edx
80105f23:	50                   	push   %eax
80105f24:	e8 a7 c7 ff ff       	call   801026d0 <nameiparent>
80105f29:	83 c4 10             	add    $0x10,%esp
80105f2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f33:	75 0f                	jne    80105f44 <sys_unlink+0x59>
    end_op();
80105f35:	e8 90 d8 ff ff       	call   801037ca <end_op>
    return -1;
80105f3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f3f:	e9 8f 01 00 00       	jmp    801060d3 <sys_unlink+0x1e8>
  }

  ilock(dp);
80105f44:	83 ec 0c             	sub    $0xc,%esp
80105f47:	ff 75 f4             	pushl  -0xc(%ebp)
80105f4a:	e8 f6 bb ff ff       	call   80101b45 <ilock>
80105f4f:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105f52:	83 ec 08             	sub    $0x8,%esp
80105f55:	68 70 9a 10 80       	push   $0x80109a70
80105f5a:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f5d:	50                   	push   %eax
80105f5e:	e8 cd c3 ff ff       	call   80102330 <namecmp>
80105f63:	83 c4 10             	add    $0x10,%esp
80105f66:	85 c0                	test   %eax,%eax
80105f68:	0f 84 49 01 00 00    	je     801060b7 <sys_unlink+0x1cc>
80105f6e:	83 ec 08             	sub    $0x8,%esp
80105f71:	68 72 9a 10 80       	push   $0x80109a72
80105f76:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f79:	50                   	push   %eax
80105f7a:	e8 b1 c3 ff ff       	call   80102330 <namecmp>
80105f7f:	83 c4 10             	add    $0x10,%esp
80105f82:	85 c0                	test   %eax,%eax
80105f84:	0f 84 2d 01 00 00    	je     801060b7 <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105f8a:	83 ec 04             	sub    $0x4,%esp
80105f8d:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105f90:	50                   	push   %eax
80105f91:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f94:	50                   	push   %eax
80105f95:	ff 75 f4             	pushl  -0xc(%ebp)
80105f98:	e8 b2 c3 ff ff       	call   8010234f <dirlookup>
80105f9d:	83 c4 10             	add    $0x10,%esp
80105fa0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fa3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fa7:	0f 84 0d 01 00 00    	je     801060ba <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80105fad:	83 ec 0c             	sub    $0xc,%esp
80105fb0:	ff 75 f0             	pushl  -0x10(%ebp)
80105fb3:	e8 8d bb ff ff       	call   80101b45 <ilock>
80105fb8:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105fbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fbe:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105fc2:	66 85 c0             	test   %ax,%ax
80105fc5:	7f 0d                	jg     80105fd4 <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
80105fc7:	83 ec 0c             	sub    $0xc,%esp
80105fca:	68 75 9a 10 80       	push   $0x80109a75
80105fcf:	e8 34 a6 ff ff       	call   80100608 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105fd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fd7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105fdb:	66 83 f8 01          	cmp    $0x1,%ax
80105fdf:	75 25                	jne    80106006 <sys_unlink+0x11b>
80105fe1:	83 ec 0c             	sub    $0xc,%esp
80105fe4:	ff 75 f0             	pushl  -0x10(%ebp)
80105fe7:	e8 98 fe ff ff       	call   80105e84 <isdirempty>
80105fec:	83 c4 10             	add    $0x10,%esp
80105fef:	85 c0                	test   %eax,%eax
80105ff1:	75 13                	jne    80106006 <sys_unlink+0x11b>
    iunlockput(ip);
80105ff3:	83 ec 0c             	sub    $0xc,%esp
80105ff6:	ff 75 f0             	pushl  -0x10(%ebp)
80105ff9:	e8 84 bd ff ff       	call   80101d82 <iunlockput>
80105ffe:	83 c4 10             	add    $0x10,%esp
    goto bad;
80106001:	e9 b5 00 00 00       	jmp    801060bb <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
80106006:	83 ec 04             	sub    $0x4,%esp
80106009:	6a 10                	push   $0x10
8010600b:	6a 00                	push   $0x0
8010600d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106010:	50                   	push   %eax
80106011:	e8 6e f5 ff ff       	call   80105584 <memset>
80106016:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106019:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010601c:	6a 10                	push   $0x10
8010601e:	50                   	push   %eax
8010601f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106022:	50                   	push   %eax
80106023:	ff 75 f4             	pushl  -0xc(%ebp)
80106026:	e8 7b c1 ff ff       	call   801021a6 <writei>
8010602b:	83 c4 10             	add    $0x10,%esp
8010602e:	83 f8 10             	cmp    $0x10,%eax
80106031:	74 0d                	je     80106040 <sys_unlink+0x155>
    panic("unlink: writei");
80106033:	83 ec 0c             	sub    $0xc,%esp
80106036:	68 87 9a 10 80       	push   $0x80109a87
8010603b:	e8 c8 a5 ff ff       	call   80100608 <panic>
  if(ip->type == T_DIR){
80106040:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106043:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106047:	66 83 f8 01          	cmp    $0x1,%ax
8010604b:	75 21                	jne    8010606e <sys_unlink+0x183>
    dp->nlink--;
8010604d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106050:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106054:	83 e8 01             	sub    $0x1,%eax
80106057:	89 c2                	mov    %eax,%edx
80106059:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010605c:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80106060:	83 ec 0c             	sub    $0xc,%esp
80106063:	ff 75 f4             	pushl  -0xc(%ebp)
80106066:	e8 f1 b8 ff ff       	call   8010195c <iupdate>
8010606b:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
8010606e:	83 ec 0c             	sub    $0xc,%esp
80106071:	ff 75 f4             	pushl  -0xc(%ebp)
80106074:	e8 09 bd ff ff       	call   80101d82 <iunlockput>
80106079:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
8010607c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010607f:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106083:	83 e8 01             	sub    $0x1,%eax
80106086:	89 c2                	mov    %eax,%edx
80106088:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010608b:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010608f:	83 ec 0c             	sub    $0xc,%esp
80106092:	ff 75 f0             	pushl  -0x10(%ebp)
80106095:	e8 c2 b8 ff ff       	call   8010195c <iupdate>
8010609a:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010609d:	83 ec 0c             	sub    $0xc,%esp
801060a0:	ff 75 f0             	pushl  -0x10(%ebp)
801060a3:	e8 da bc ff ff       	call   80101d82 <iunlockput>
801060a8:	83 c4 10             	add    $0x10,%esp

  end_op();
801060ab:	e8 1a d7 ff ff       	call   801037ca <end_op>

  return 0;
801060b0:	b8 00 00 00 00       	mov    $0x0,%eax
801060b5:	eb 1c                	jmp    801060d3 <sys_unlink+0x1e8>
    goto bad;
801060b7:	90                   	nop
801060b8:	eb 01                	jmp    801060bb <sys_unlink+0x1d0>
    goto bad;
801060ba:	90                   	nop

bad:
  iunlockput(dp);
801060bb:	83 ec 0c             	sub    $0xc,%esp
801060be:	ff 75 f4             	pushl  -0xc(%ebp)
801060c1:	e8 bc bc ff ff       	call   80101d82 <iunlockput>
801060c6:	83 c4 10             	add    $0x10,%esp
  end_op();
801060c9:	e8 fc d6 ff ff       	call   801037ca <end_op>
  return -1;
801060ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801060d3:	c9                   	leave  
801060d4:	c3                   	ret    

801060d5 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801060d5:	f3 0f 1e fb          	endbr32 
801060d9:	55                   	push   %ebp
801060da:	89 e5                	mov    %esp,%ebp
801060dc:	83 ec 38             	sub    $0x38,%esp
801060df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801060e2:	8b 55 10             	mov    0x10(%ebp),%edx
801060e5:	8b 45 14             	mov    0x14(%ebp),%eax
801060e8:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801060ec:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801060f0:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801060f4:	83 ec 08             	sub    $0x8,%esp
801060f7:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801060fa:	50                   	push   %eax
801060fb:	ff 75 08             	pushl  0x8(%ebp)
801060fe:	e8 cd c5 ff ff       	call   801026d0 <nameiparent>
80106103:	83 c4 10             	add    $0x10,%esp
80106106:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106109:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010610d:	75 0a                	jne    80106119 <create+0x44>
    return 0;
8010610f:	b8 00 00 00 00       	mov    $0x0,%eax
80106114:	e9 8e 01 00 00       	jmp    801062a7 <create+0x1d2>
  ilock(dp);
80106119:	83 ec 0c             	sub    $0xc,%esp
8010611c:	ff 75 f4             	pushl  -0xc(%ebp)
8010611f:	e8 21 ba ff ff       	call   80101b45 <ilock>
80106124:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, 0)) != 0){
80106127:	83 ec 04             	sub    $0x4,%esp
8010612a:	6a 00                	push   $0x0
8010612c:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010612f:	50                   	push   %eax
80106130:	ff 75 f4             	pushl  -0xc(%ebp)
80106133:	e8 17 c2 ff ff       	call   8010234f <dirlookup>
80106138:	83 c4 10             	add    $0x10,%esp
8010613b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010613e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106142:	74 50                	je     80106194 <create+0xbf>
    iunlockput(dp);
80106144:	83 ec 0c             	sub    $0xc,%esp
80106147:	ff 75 f4             	pushl  -0xc(%ebp)
8010614a:	e8 33 bc ff ff       	call   80101d82 <iunlockput>
8010614f:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80106152:	83 ec 0c             	sub    $0xc,%esp
80106155:	ff 75 f0             	pushl  -0x10(%ebp)
80106158:	e8 e8 b9 ff ff       	call   80101b45 <ilock>
8010615d:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80106160:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106165:	75 15                	jne    8010617c <create+0xa7>
80106167:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010616a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010616e:	66 83 f8 02          	cmp    $0x2,%ax
80106172:	75 08                	jne    8010617c <create+0xa7>
      return ip;
80106174:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106177:	e9 2b 01 00 00       	jmp    801062a7 <create+0x1d2>
    iunlockput(ip);
8010617c:	83 ec 0c             	sub    $0xc,%esp
8010617f:	ff 75 f0             	pushl  -0x10(%ebp)
80106182:	e8 fb bb ff ff       	call   80101d82 <iunlockput>
80106187:	83 c4 10             	add    $0x10,%esp
    return 0;
8010618a:	b8 00 00 00 00       	mov    $0x0,%eax
8010618f:	e9 13 01 00 00       	jmp    801062a7 <create+0x1d2>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106194:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106198:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010619b:	8b 00                	mov    (%eax),%eax
8010619d:	83 ec 08             	sub    $0x8,%esp
801061a0:	52                   	push   %edx
801061a1:	50                   	push   %eax
801061a2:	e8 da b6 ff ff       	call   80101881 <ialloc>
801061a7:	83 c4 10             	add    $0x10,%esp
801061aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061ad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061b1:	75 0d                	jne    801061c0 <create+0xeb>
    panic("create: ialloc");
801061b3:	83 ec 0c             	sub    $0xc,%esp
801061b6:	68 96 9a 10 80       	push   $0x80109a96
801061bb:	e8 48 a4 ff ff       	call   80100608 <panic>

  ilock(ip);
801061c0:	83 ec 0c             	sub    $0xc,%esp
801061c3:	ff 75 f0             	pushl  -0x10(%ebp)
801061c6:	e8 7a b9 ff ff       	call   80101b45 <ilock>
801061cb:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801061ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061d1:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801061d5:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
801061d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061dc:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801061e0:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
801061e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061e7:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801061ed:	83 ec 0c             	sub    $0xc,%esp
801061f0:	ff 75 f0             	pushl  -0x10(%ebp)
801061f3:	e8 64 b7 ff ff       	call   8010195c <iupdate>
801061f8:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801061fb:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106200:	75 6a                	jne    8010626c <create+0x197>
    dp->nlink++;  // for ".."
80106202:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106205:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106209:	83 c0 01             	add    $0x1,%eax
8010620c:	89 c2                	mov    %eax,%edx
8010620e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106211:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80106215:	83 ec 0c             	sub    $0xc,%esp
80106218:	ff 75 f4             	pushl  -0xc(%ebp)
8010621b:	e8 3c b7 ff ff       	call   8010195c <iupdate>
80106220:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106223:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106226:	8b 40 04             	mov    0x4(%eax),%eax
80106229:	83 ec 04             	sub    $0x4,%esp
8010622c:	50                   	push   %eax
8010622d:	68 70 9a 10 80       	push   $0x80109a70
80106232:	ff 75 f0             	pushl  -0x10(%ebp)
80106235:	e8 d3 c1 ff ff       	call   8010240d <dirlink>
8010623a:	83 c4 10             	add    $0x10,%esp
8010623d:	85 c0                	test   %eax,%eax
8010623f:	78 1e                	js     8010625f <create+0x18a>
80106241:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106244:	8b 40 04             	mov    0x4(%eax),%eax
80106247:	83 ec 04             	sub    $0x4,%esp
8010624a:	50                   	push   %eax
8010624b:	68 72 9a 10 80       	push   $0x80109a72
80106250:	ff 75 f0             	pushl  -0x10(%ebp)
80106253:	e8 b5 c1 ff ff       	call   8010240d <dirlink>
80106258:	83 c4 10             	add    $0x10,%esp
8010625b:	85 c0                	test   %eax,%eax
8010625d:	79 0d                	jns    8010626c <create+0x197>
      panic("create dots");
8010625f:	83 ec 0c             	sub    $0xc,%esp
80106262:	68 a5 9a 10 80       	push   $0x80109aa5
80106267:	e8 9c a3 ff ff       	call   80100608 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010626c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010626f:	8b 40 04             	mov    0x4(%eax),%eax
80106272:	83 ec 04             	sub    $0x4,%esp
80106275:	50                   	push   %eax
80106276:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106279:	50                   	push   %eax
8010627a:	ff 75 f4             	pushl  -0xc(%ebp)
8010627d:	e8 8b c1 ff ff       	call   8010240d <dirlink>
80106282:	83 c4 10             	add    $0x10,%esp
80106285:	85 c0                	test   %eax,%eax
80106287:	79 0d                	jns    80106296 <create+0x1c1>
    panic("create: dirlink");
80106289:	83 ec 0c             	sub    $0xc,%esp
8010628c:	68 b1 9a 10 80       	push   $0x80109ab1
80106291:	e8 72 a3 ff ff       	call   80100608 <panic>

  iunlockput(dp);
80106296:	83 ec 0c             	sub    $0xc,%esp
80106299:	ff 75 f4             	pushl  -0xc(%ebp)
8010629c:	e8 e1 ba ff ff       	call   80101d82 <iunlockput>
801062a1:	83 c4 10             	add    $0x10,%esp

  return ip;
801062a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801062a7:	c9                   	leave  
801062a8:	c3                   	ret    

801062a9 <sys_open>:

int
sys_open(void)
{
801062a9:	f3 0f 1e fb          	endbr32 
801062ad:	55                   	push   %ebp
801062ae:	89 e5                	mov    %esp,%ebp
801062b0:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801062b3:	83 ec 08             	sub    $0x8,%esp
801062b6:	8d 45 e8             	lea    -0x18(%ebp),%eax
801062b9:	50                   	push   %eax
801062ba:	6a 00                	push   $0x0
801062bc:	e8 b4 f6 ff ff       	call   80105975 <argstr>
801062c1:	83 c4 10             	add    $0x10,%esp
801062c4:	85 c0                	test   %eax,%eax
801062c6:	78 15                	js     801062dd <sys_open+0x34>
801062c8:	83 ec 08             	sub    $0x8,%esp
801062cb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801062ce:	50                   	push   %eax
801062cf:	6a 01                	push   $0x1
801062d1:	e8 02 f6 ff ff       	call   801058d8 <argint>
801062d6:	83 c4 10             	add    $0x10,%esp
801062d9:	85 c0                	test   %eax,%eax
801062db:	79 0a                	jns    801062e7 <sys_open+0x3e>
    return -1;
801062dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062e2:	e9 61 01 00 00       	jmp    80106448 <sys_open+0x19f>

  begin_op();
801062e7:	e8 4e d4 ff ff       	call   8010373a <begin_op>

  if(omode & O_CREATE){
801062ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062ef:	25 00 02 00 00       	and    $0x200,%eax
801062f4:	85 c0                	test   %eax,%eax
801062f6:	74 2a                	je     80106322 <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
801062f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062fb:	6a 00                	push   $0x0
801062fd:	6a 00                	push   $0x0
801062ff:	6a 02                	push   $0x2
80106301:	50                   	push   %eax
80106302:	e8 ce fd ff ff       	call   801060d5 <create>
80106307:	83 c4 10             	add    $0x10,%esp
8010630a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
8010630d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106311:	75 75                	jne    80106388 <sys_open+0xdf>
      end_op();
80106313:	e8 b2 d4 ff ff       	call   801037ca <end_op>
      return -1;
80106318:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010631d:	e9 26 01 00 00       	jmp    80106448 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
80106322:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106325:	83 ec 0c             	sub    $0xc,%esp
80106328:	50                   	push   %eax
80106329:	e8 82 c3 ff ff       	call   801026b0 <namei>
8010632e:	83 c4 10             	add    $0x10,%esp
80106331:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106334:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106338:	75 0f                	jne    80106349 <sys_open+0xa0>
      end_op();
8010633a:	e8 8b d4 ff ff       	call   801037ca <end_op>
      return -1;
8010633f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106344:	e9 ff 00 00 00       	jmp    80106448 <sys_open+0x19f>
    }
    ilock(ip);
80106349:	83 ec 0c             	sub    $0xc,%esp
8010634c:	ff 75 f4             	pushl  -0xc(%ebp)
8010634f:	e8 f1 b7 ff ff       	call   80101b45 <ilock>
80106354:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106357:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010635a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010635e:	66 83 f8 01          	cmp    $0x1,%ax
80106362:	75 24                	jne    80106388 <sys_open+0xdf>
80106364:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106367:	85 c0                	test   %eax,%eax
80106369:	74 1d                	je     80106388 <sys_open+0xdf>
      iunlockput(ip);
8010636b:	83 ec 0c             	sub    $0xc,%esp
8010636e:	ff 75 f4             	pushl  -0xc(%ebp)
80106371:	e8 0c ba ff ff       	call   80101d82 <iunlockput>
80106376:	83 c4 10             	add    $0x10,%esp
      end_op();
80106379:	e8 4c d4 ff ff       	call   801037ca <end_op>
      return -1;
8010637e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106383:	e9 c0 00 00 00       	jmp    80106448 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106388:	e8 72 ad ff ff       	call   801010ff <filealloc>
8010638d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106390:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106394:	74 17                	je     801063ad <sys_open+0x104>
80106396:	83 ec 0c             	sub    $0xc,%esp
80106399:	ff 75 f0             	pushl  -0x10(%ebp)
8010639c:	e8 09 f7 ff ff       	call   80105aaa <fdalloc>
801063a1:	83 c4 10             	add    $0x10,%esp
801063a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801063a7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801063ab:	79 2e                	jns    801063db <sys_open+0x132>
    if(f)
801063ad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063b1:	74 0e                	je     801063c1 <sys_open+0x118>
      fileclose(f);
801063b3:	83 ec 0c             	sub    $0xc,%esp
801063b6:	ff 75 f0             	pushl  -0x10(%ebp)
801063b9:	e8 07 ae ff ff       	call   801011c5 <fileclose>
801063be:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801063c1:	83 ec 0c             	sub    $0xc,%esp
801063c4:	ff 75 f4             	pushl  -0xc(%ebp)
801063c7:	e8 b6 b9 ff ff       	call   80101d82 <iunlockput>
801063cc:	83 c4 10             	add    $0x10,%esp
    end_op();
801063cf:	e8 f6 d3 ff ff       	call   801037ca <end_op>
    return -1;
801063d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063d9:	eb 6d                	jmp    80106448 <sys_open+0x19f>
  }
  iunlock(ip);
801063db:	83 ec 0c             	sub    $0xc,%esp
801063de:	ff 75 f4             	pushl  -0xc(%ebp)
801063e1:	e8 76 b8 ff ff       	call   80101c5c <iunlock>
801063e6:	83 c4 10             	add    $0x10,%esp
  end_op();
801063e9:	e8 dc d3 ff ff       	call   801037ca <end_op>

  f->type = FD_INODE;
801063ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063f1:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801063f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063fd:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106400:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106403:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
8010640a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010640d:	83 e0 01             	and    $0x1,%eax
80106410:	85 c0                	test   %eax,%eax
80106412:	0f 94 c0             	sete   %al
80106415:	89 c2                	mov    %eax,%edx
80106417:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010641a:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010641d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106420:	83 e0 01             	and    $0x1,%eax
80106423:	85 c0                	test   %eax,%eax
80106425:	75 0a                	jne    80106431 <sys_open+0x188>
80106427:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010642a:	83 e0 02             	and    $0x2,%eax
8010642d:	85 c0                	test   %eax,%eax
8010642f:	74 07                	je     80106438 <sys_open+0x18f>
80106431:	b8 01 00 00 00       	mov    $0x1,%eax
80106436:	eb 05                	jmp    8010643d <sys_open+0x194>
80106438:	b8 00 00 00 00       	mov    $0x0,%eax
8010643d:	89 c2                	mov    %eax,%edx
8010643f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106442:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106445:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106448:	c9                   	leave  
80106449:	c3                   	ret    

8010644a <sys_mkdir>:

int
sys_mkdir(void)
{
8010644a:	f3 0f 1e fb          	endbr32 
8010644e:	55                   	push   %ebp
8010644f:	89 e5                	mov    %esp,%ebp
80106451:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106454:	e8 e1 d2 ff ff       	call   8010373a <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106459:	83 ec 08             	sub    $0x8,%esp
8010645c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010645f:	50                   	push   %eax
80106460:	6a 00                	push   $0x0
80106462:	e8 0e f5 ff ff       	call   80105975 <argstr>
80106467:	83 c4 10             	add    $0x10,%esp
8010646a:	85 c0                	test   %eax,%eax
8010646c:	78 1b                	js     80106489 <sys_mkdir+0x3f>
8010646e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106471:	6a 00                	push   $0x0
80106473:	6a 00                	push   $0x0
80106475:	6a 01                	push   $0x1
80106477:	50                   	push   %eax
80106478:	e8 58 fc ff ff       	call   801060d5 <create>
8010647d:	83 c4 10             	add    $0x10,%esp
80106480:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106483:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106487:	75 0c                	jne    80106495 <sys_mkdir+0x4b>
    end_op();
80106489:	e8 3c d3 ff ff       	call   801037ca <end_op>
    return -1;
8010648e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106493:	eb 18                	jmp    801064ad <sys_mkdir+0x63>
  }
  iunlockput(ip);
80106495:	83 ec 0c             	sub    $0xc,%esp
80106498:	ff 75 f4             	pushl  -0xc(%ebp)
8010649b:	e8 e2 b8 ff ff       	call   80101d82 <iunlockput>
801064a0:	83 c4 10             	add    $0x10,%esp
  end_op();
801064a3:	e8 22 d3 ff ff       	call   801037ca <end_op>
  return 0;
801064a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064ad:	c9                   	leave  
801064ae:	c3                   	ret    

801064af <sys_mknod>:

int
sys_mknod(void)
{
801064af:	f3 0f 1e fb          	endbr32 
801064b3:	55                   	push   %ebp
801064b4:	89 e5                	mov    %esp,%ebp
801064b6:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801064b9:	e8 7c d2 ff ff       	call   8010373a <begin_op>
  if((argstr(0, &path)) < 0 ||
801064be:	83 ec 08             	sub    $0x8,%esp
801064c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064c4:	50                   	push   %eax
801064c5:	6a 00                	push   $0x0
801064c7:	e8 a9 f4 ff ff       	call   80105975 <argstr>
801064cc:	83 c4 10             	add    $0x10,%esp
801064cf:	85 c0                	test   %eax,%eax
801064d1:	78 4f                	js     80106522 <sys_mknod+0x73>
     argint(1, &major) < 0 ||
801064d3:	83 ec 08             	sub    $0x8,%esp
801064d6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801064d9:	50                   	push   %eax
801064da:	6a 01                	push   $0x1
801064dc:	e8 f7 f3 ff ff       	call   801058d8 <argint>
801064e1:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
801064e4:	85 c0                	test   %eax,%eax
801064e6:	78 3a                	js     80106522 <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
801064e8:	83 ec 08             	sub    $0x8,%esp
801064eb:	8d 45 e8             	lea    -0x18(%ebp),%eax
801064ee:	50                   	push   %eax
801064ef:	6a 02                	push   $0x2
801064f1:	e8 e2 f3 ff ff       	call   801058d8 <argint>
801064f6:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
801064f9:	85 c0                	test   %eax,%eax
801064fb:	78 25                	js     80106522 <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
801064fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106500:	0f bf c8             	movswl %ax,%ecx
80106503:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106506:	0f bf d0             	movswl %ax,%edx
80106509:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010650c:	51                   	push   %ecx
8010650d:	52                   	push   %edx
8010650e:	6a 03                	push   $0x3
80106510:	50                   	push   %eax
80106511:	e8 bf fb ff ff       	call   801060d5 <create>
80106516:	83 c4 10             	add    $0x10,%esp
80106519:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
8010651c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106520:	75 0c                	jne    8010652e <sys_mknod+0x7f>
    end_op();
80106522:	e8 a3 d2 ff ff       	call   801037ca <end_op>
    return -1;
80106527:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010652c:	eb 18                	jmp    80106546 <sys_mknod+0x97>
  }
  iunlockput(ip);
8010652e:	83 ec 0c             	sub    $0xc,%esp
80106531:	ff 75 f4             	pushl  -0xc(%ebp)
80106534:	e8 49 b8 ff ff       	call   80101d82 <iunlockput>
80106539:	83 c4 10             	add    $0x10,%esp
  end_op();
8010653c:	e8 89 d2 ff ff       	call   801037ca <end_op>
  return 0;
80106541:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106546:	c9                   	leave  
80106547:	c3                   	ret    

80106548 <sys_chdir>:

int
sys_chdir(void)
{
80106548:	f3 0f 1e fb          	endbr32 
8010654c:	55                   	push   %ebp
8010654d:	89 e5                	mov    %esp,%ebp
8010654f:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80106552:	e8 a2 df ff ff       	call   801044f9 <myproc>
80106557:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
8010655a:	e8 db d1 ff ff       	call   8010373a <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
8010655f:	83 ec 08             	sub    $0x8,%esp
80106562:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106565:	50                   	push   %eax
80106566:	6a 00                	push   $0x0
80106568:	e8 08 f4 ff ff       	call   80105975 <argstr>
8010656d:	83 c4 10             	add    $0x10,%esp
80106570:	85 c0                	test   %eax,%eax
80106572:	78 18                	js     8010658c <sys_chdir+0x44>
80106574:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106577:	83 ec 0c             	sub    $0xc,%esp
8010657a:	50                   	push   %eax
8010657b:	e8 30 c1 ff ff       	call   801026b0 <namei>
80106580:	83 c4 10             	add    $0x10,%esp
80106583:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106586:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010658a:	75 0c                	jne    80106598 <sys_chdir+0x50>
    end_op();
8010658c:	e8 39 d2 ff ff       	call   801037ca <end_op>
    return -1;
80106591:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106596:	eb 68                	jmp    80106600 <sys_chdir+0xb8>
  }
  ilock(ip);
80106598:	83 ec 0c             	sub    $0xc,%esp
8010659b:	ff 75 f0             	pushl  -0x10(%ebp)
8010659e:	e8 a2 b5 ff ff       	call   80101b45 <ilock>
801065a3:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
801065a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065a9:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801065ad:	66 83 f8 01          	cmp    $0x1,%ax
801065b1:	74 1a                	je     801065cd <sys_chdir+0x85>
    iunlockput(ip);
801065b3:	83 ec 0c             	sub    $0xc,%esp
801065b6:	ff 75 f0             	pushl  -0x10(%ebp)
801065b9:	e8 c4 b7 ff ff       	call   80101d82 <iunlockput>
801065be:	83 c4 10             	add    $0x10,%esp
    end_op();
801065c1:	e8 04 d2 ff ff       	call   801037ca <end_op>
    return -1;
801065c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065cb:	eb 33                	jmp    80106600 <sys_chdir+0xb8>
  }
  iunlock(ip);
801065cd:	83 ec 0c             	sub    $0xc,%esp
801065d0:	ff 75 f0             	pushl  -0x10(%ebp)
801065d3:	e8 84 b6 ff ff       	call   80101c5c <iunlock>
801065d8:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
801065db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065de:	8b 40 68             	mov    0x68(%eax),%eax
801065e1:	83 ec 0c             	sub    $0xc,%esp
801065e4:	50                   	push   %eax
801065e5:	e8 c4 b6 ff ff       	call   80101cae <iput>
801065ea:	83 c4 10             	add    $0x10,%esp
  end_op();
801065ed:	e8 d8 d1 ff ff       	call   801037ca <end_op>
  curproc->cwd = ip;
801065f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065f5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801065f8:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801065fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106600:	c9                   	leave  
80106601:	c3                   	ret    

80106602 <sys_exec>:

int
sys_exec(void)
{
80106602:	f3 0f 1e fb          	endbr32 
80106606:	55                   	push   %ebp
80106607:	89 e5                	mov    %esp,%ebp
80106609:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010660f:	83 ec 08             	sub    $0x8,%esp
80106612:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106615:	50                   	push   %eax
80106616:	6a 00                	push   $0x0
80106618:	e8 58 f3 ff ff       	call   80105975 <argstr>
8010661d:	83 c4 10             	add    $0x10,%esp
80106620:	85 c0                	test   %eax,%eax
80106622:	78 18                	js     8010663c <sys_exec+0x3a>
80106624:	83 ec 08             	sub    $0x8,%esp
80106627:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010662d:	50                   	push   %eax
8010662e:	6a 01                	push   $0x1
80106630:	e8 a3 f2 ff ff       	call   801058d8 <argint>
80106635:	83 c4 10             	add    $0x10,%esp
80106638:	85 c0                	test   %eax,%eax
8010663a:	79 0a                	jns    80106646 <sys_exec+0x44>
    return -1;
8010663c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106641:	e9 c6 00 00 00       	jmp    8010670c <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
80106646:	83 ec 04             	sub    $0x4,%esp
80106649:	68 80 00 00 00       	push   $0x80
8010664e:	6a 00                	push   $0x0
80106650:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106656:	50                   	push   %eax
80106657:	e8 28 ef ff ff       	call   80105584 <memset>
8010665c:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
8010665f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106666:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106669:	83 f8 1f             	cmp    $0x1f,%eax
8010666c:	76 0a                	jbe    80106678 <sys_exec+0x76>
      return -1;
8010666e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106673:	e9 94 00 00 00       	jmp    8010670c <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106678:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010667b:	c1 e0 02             	shl    $0x2,%eax
8010667e:	89 c2                	mov    %eax,%edx
80106680:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106686:	01 c2                	add    %eax,%edx
80106688:	83 ec 08             	sub    $0x8,%esp
8010668b:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106691:	50                   	push   %eax
80106692:	52                   	push   %edx
80106693:	e8 95 f1 ff ff       	call   8010582d <fetchint>
80106698:	83 c4 10             	add    $0x10,%esp
8010669b:	85 c0                	test   %eax,%eax
8010669d:	79 07                	jns    801066a6 <sys_exec+0xa4>
      return -1;
8010669f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066a4:	eb 66                	jmp    8010670c <sys_exec+0x10a>
    if(uarg == 0){
801066a6:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801066ac:	85 c0                	test   %eax,%eax
801066ae:	75 27                	jne    801066d7 <sys_exec+0xd5>
      argv[i] = 0;
801066b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066b3:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801066ba:	00 00 00 00 
      break;
801066be:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801066bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066c2:	83 ec 08             	sub    $0x8,%esp
801066c5:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801066cb:	52                   	push   %edx
801066cc:	50                   	push   %eax
801066cd:	e8 5e a5 ff ff       	call   80100c30 <exec>
801066d2:	83 c4 10             	add    $0x10,%esp
801066d5:	eb 35                	jmp    8010670c <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
801066d7:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801066dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066e0:	c1 e2 02             	shl    $0x2,%edx
801066e3:	01 c2                	add    %eax,%edx
801066e5:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801066eb:	83 ec 08             	sub    $0x8,%esp
801066ee:	52                   	push   %edx
801066ef:	50                   	push   %eax
801066f0:	e8 7b f1 ff ff       	call   80105870 <fetchstr>
801066f5:	83 c4 10             	add    $0x10,%esp
801066f8:	85 c0                	test   %eax,%eax
801066fa:	79 07                	jns    80106703 <sys_exec+0x101>
      return -1;
801066fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106701:	eb 09                	jmp    8010670c <sys_exec+0x10a>
  for(i=0;; i++){
80106703:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80106707:	e9 5a ff ff ff       	jmp    80106666 <sys_exec+0x64>
}
8010670c:	c9                   	leave  
8010670d:	c3                   	ret    

8010670e <sys_pipe>:

int
sys_pipe(void)
{
8010670e:	f3 0f 1e fb          	endbr32 
80106712:	55                   	push   %ebp
80106713:	89 e5                	mov    %esp,%ebp
80106715:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106718:	83 ec 04             	sub    $0x4,%esp
8010671b:	6a 08                	push   $0x8
8010671d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106720:	50                   	push   %eax
80106721:	6a 00                	push   $0x0
80106723:	e8 e1 f1 ff ff       	call   80105909 <argptr>
80106728:	83 c4 10             	add    $0x10,%esp
8010672b:	85 c0                	test   %eax,%eax
8010672d:	79 0a                	jns    80106739 <sys_pipe+0x2b>
    return -1;
8010672f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106734:	e9 ae 00 00 00       	jmp    801067e7 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
80106739:	83 ec 08             	sub    $0x8,%esp
8010673c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010673f:	50                   	push   %eax
80106740:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106743:	50                   	push   %eax
80106744:	e8 d1 d8 ff ff       	call   8010401a <pipealloc>
80106749:	83 c4 10             	add    $0x10,%esp
8010674c:	85 c0                	test   %eax,%eax
8010674e:	79 0a                	jns    8010675a <sys_pipe+0x4c>
    return -1;
80106750:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106755:	e9 8d 00 00 00       	jmp    801067e7 <sys_pipe+0xd9>
  fd0 = -1;
8010675a:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106761:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106764:	83 ec 0c             	sub    $0xc,%esp
80106767:	50                   	push   %eax
80106768:	e8 3d f3 ff ff       	call   80105aaa <fdalloc>
8010676d:	83 c4 10             	add    $0x10,%esp
80106770:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106773:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106777:	78 18                	js     80106791 <sys_pipe+0x83>
80106779:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010677c:	83 ec 0c             	sub    $0xc,%esp
8010677f:	50                   	push   %eax
80106780:	e8 25 f3 ff ff       	call   80105aaa <fdalloc>
80106785:	83 c4 10             	add    $0x10,%esp
80106788:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010678b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010678f:	79 3e                	jns    801067cf <sys_pipe+0xc1>
    if(fd0 >= 0)
80106791:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106795:	78 13                	js     801067aa <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
80106797:	e8 5d dd ff ff       	call   801044f9 <myproc>
8010679c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010679f:	83 c2 08             	add    $0x8,%edx
801067a2:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801067a9:	00 
    fileclose(rf);
801067aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
801067ad:	83 ec 0c             	sub    $0xc,%esp
801067b0:	50                   	push   %eax
801067b1:	e8 0f aa ff ff       	call   801011c5 <fileclose>
801067b6:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
801067b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067bc:	83 ec 0c             	sub    $0xc,%esp
801067bf:	50                   	push   %eax
801067c0:	e8 00 aa ff ff       	call   801011c5 <fileclose>
801067c5:	83 c4 10             	add    $0x10,%esp
    return -1;
801067c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067cd:	eb 18                	jmp    801067e7 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
801067cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801067d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067d5:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801067d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801067da:	8d 50 04             	lea    0x4(%eax),%edx
801067dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067e0:	89 02                	mov    %eax,(%edx)
  return 0;
801067e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067e7:	c9                   	leave  
801067e8:	c3                   	ret    

801067e9 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801067e9:	f3 0f 1e fb          	endbr32 
801067ed:	55                   	push   %ebp
801067ee:	89 e5                	mov    %esp,%ebp
801067f0:	83 ec 08             	sub    $0x8,%esp
  return fork();
801067f3:	e8 ac e0 ff ff       	call   801048a4 <fork>
}
801067f8:	c9                   	leave  
801067f9:	c3                   	ret    

801067fa <sys_exit>:

int
sys_exit(void)
{
801067fa:	f3 0f 1e fb          	endbr32 
801067fe:	55                   	push   %ebp
801067ff:	89 e5                	mov    %esp,%ebp
80106801:	83 ec 08             	sub    $0x8,%esp
  exit();
80106804:	e8 18 e2 ff ff       	call   80104a21 <exit>
  return 0;  // not reached
80106809:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010680e:	c9                   	leave  
8010680f:	c3                   	ret    

80106810 <sys_wait>:

int
sys_wait(void)
{
80106810:	f3 0f 1e fb          	endbr32 
80106814:	55                   	push   %ebp
80106815:	89 e5                	mov    %esp,%ebp
80106817:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010681a:	e8 29 e3 ff ff       	call   80104b48 <wait>
}
8010681f:	c9                   	leave  
80106820:	c3                   	ret    

80106821 <sys_kill>:

int
sys_kill(void)
{
80106821:	f3 0f 1e fb          	endbr32 
80106825:	55                   	push   %ebp
80106826:	89 e5                	mov    %esp,%ebp
80106828:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010682b:	83 ec 08             	sub    $0x8,%esp
8010682e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106831:	50                   	push   %eax
80106832:	6a 00                	push   $0x0
80106834:	e8 9f f0 ff ff       	call   801058d8 <argint>
80106839:	83 c4 10             	add    $0x10,%esp
8010683c:	85 c0                	test   %eax,%eax
8010683e:	79 07                	jns    80106847 <sys_kill+0x26>
    return -1;
80106840:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106845:	eb 0f                	jmp    80106856 <sys_kill+0x35>
  return kill(pid);
80106847:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010684a:	83 ec 0c             	sub    $0xc,%esp
8010684d:	50                   	push   %eax
8010684e:	e8 4d e7 ff ff       	call   80104fa0 <kill>
80106853:	83 c4 10             	add    $0x10,%esp
}
80106856:	c9                   	leave  
80106857:	c3                   	ret    

80106858 <sys_getpid>:

int
sys_getpid(void)
{
80106858:	f3 0f 1e fb          	endbr32 
8010685c:	55                   	push   %ebp
8010685d:	89 e5                	mov    %esp,%ebp
8010685f:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106862:	e8 92 dc ff ff       	call   801044f9 <myproc>
80106867:	8b 40 10             	mov    0x10(%eax),%eax
}
8010686a:	c9                   	leave  
8010686b:	c3                   	ret    

8010686c <sys_sbrk>:

int
sys_sbrk(void)
{
8010686c:	f3 0f 1e fb          	endbr32 
80106870:	55                   	push   %ebp
80106871:	89 e5                	mov    %esp,%ebp
80106873:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106876:	83 ec 08             	sub    $0x8,%esp
80106879:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010687c:	50                   	push   %eax
8010687d:	6a 00                	push   $0x0
8010687f:	e8 54 f0 ff ff       	call   801058d8 <argint>
80106884:	83 c4 10             	add    $0x10,%esp
80106887:	85 c0                	test   %eax,%eax
80106889:	79 07                	jns    80106892 <sys_sbrk+0x26>
    return -1;
8010688b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106890:	eb 27                	jmp    801068b9 <sys_sbrk+0x4d>
  addr = myproc()->sz;
80106892:	e8 62 dc ff ff       	call   801044f9 <myproc>
80106897:	8b 00                	mov    (%eax),%eax
80106899:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010689c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010689f:	83 ec 0c             	sub    $0xc,%esp
801068a2:	50                   	push   %eax
801068a3:	e8 c8 de ff ff       	call   80104770 <growproc>
801068a8:	83 c4 10             	add    $0x10,%esp
801068ab:	85 c0                	test   %eax,%eax
801068ad:	79 07                	jns    801068b6 <sys_sbrk+0x4a>
    return -1;
801068af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068b4:	eb 03                	jmp    801068b9 <sys_sbrk+0x4d>
  return addr;
801068b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801068b9:	c9                   	leave  
801068ba:	c3                   	ret    

801068bb <sys_sleep>:

int
sys_sleep(void)
{
801068bb:	f3 0f 1e fb          	endbr32 
801068bf:	55                   	push   %ebp
801068c0:	89 e5                	mov    %esp,%ebp
801068c2:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801068c5:	83 ec 08             	sub    $0x8,%esp
801068c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801068cb:	50                   	push   %eax
801068cc:	6a 00                	push   $0x0
801068ce:	e8 05 f0 ff ff       	call   801058d8 <argint>
801068d3:	83 c4 10             	add    $0x10,%esp
801068d6:	85 c0                	test   %eax,%eax
801068d8:	79 07                	jns    801068e1 <sys_sleep+0x26>
    return -1;
801068da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068df:	eb 76                	jmp    80106957 <sys_sleep+0x9c>
  acquire(&tickslock);
801068e1:	83 ec 0c             	sub    $0xc,%esp
801068e4:	68 00 8e 11 80       	push   $0x80118e00
801068e9:	e8 f7 e9 ff ff       	call   801052e5 <acquire>
801068ee:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801068f1:	a1 40 96 11 80       	mov    0x80119640,%eax
801068f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801068f9:	eb 38                	jmp    80106933 <sys_sleep+0x78>
    if(myproc()->killed){
801068fb:	e8 f9 db ff ff       	call   801044f9 <myproc>
80106900:	8b 40 24             	mov    0x24(%eax),%eax
80106903:	85 c0                	test   %eax,%eax
80106905:	74 17                	je     8010691e <sys_sleep+0x63>
      release(&tickslock);
80106907:	83 ec 0c             	sub    $0xc,%esp
8010690a:	68 00 8e 11 80       	push   $0x80118e00
8010690f:	e8 43 ea ff ff       	call   80105357 <release>
80106914:	83 c4 10             	add    $0x10,%esp
      return -1;
80106917:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010691c:	eb 39                	jmp    80106957 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
8010691e:	83 ec 08             	sub    $0x8,%esp
80106921:	68 00 8e 11 80       	push   $0x80118e00
80106926:	68 40 96 11 80       	push   $0x80119640
8010692b:	e8 43 e5 ff ff       	call   80104e73 <sleep>
80106930:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106933:	a1 40 96 11 80       	mov    0x80119640,%eax
80106938:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010693b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010693e:	39 d0                	cmp    %edx,%eax
80106940:	72 b9                	jb     801068fb <sys_sleep+0x40>
  }
  release(&tickslock);
80106942:	83 ec 0c             	sub    $0xc,%esp
80106945:	68 00 8e 11 80       	push   $0x80118e00
8010694a:	e8 08 ea ff ff       	call   80105357 <release>
8010694f:	83 c4 10             	add    $0x10,%esp
  return 0;
80106952:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106957:	c9                   	leave  
80106958:	c3                   	ret    

80106959 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106959:	f3 0f 1e fb          	endbr32 
8010695d:	55                   	push   %ebp
8010695e:	89 e5                	mov    %esp,%ebp
80106960:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106963:	83 ec 0c             	sub    $0xc,%esp
80106966:	68 00 8e 11 80       	push   $0x80118e00
8010696b:	e8 75 e9 ff ff       	call   801052e5 <acquire>
80106970:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106973:	a1 40 96 11 80       	mov    0x80119640,%eax
80106978:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010697b:	83 ec 0c             	sub    $0xc,%esp
8010697e:	68 00 8e 11 80       	push   $0x80118e00
80106983:	e8 cf e9 ff ff       	call   80105357 <release>
80106988:	83 c4 10             	add    $0x10,%esp
  return xticks;
8010698b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010698e:	c9                   	leave  
8010698f:	c3                   	ret    

80106990 <sys_mencrypt>:

//changed: added wrapper here
int sys_mencrypt(void) {
80106990:	f3 0f 1e fb          	endbr32 
80106994:	55                   	push   %ebp
80106995:	89 e5                	mov    %esp,%ebp
80106997:	83 ec 18             	sub    $0x18,%esp
  int len;
  char * virtual_addr;

  if(argint(1, &len) < 0)
8010699a:	83 ec 08             	sub    $0x8,%esp
8010699d:	8d 45 f4             	lea    -0xc(%ebp),%eax
801069a0:	50                   	push   %eax
801069a1:	6a 01                	push   $0x1
801069a3:	e8 30 ef ff ff       	call   801058d8 <argint>
801069a8:	83 c4 10             	add    $0x10,%esp
801069ab:	85 c0                	test   %eax,%eax
801069ad:	79 07                	jns    801069b6 <sys_mencrypt+0x26>
    return -1;
801069af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069b4:	eb 50                	jmp    80106a06 <sys_mencrypt+0x76>
  if (len <= 0) {
801069b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069b9:	85 c0                	test   %eax,%eax
801069bb:	7f 07                	jg     801069c4 <sys_mencrypt+0x34>
    return -1;
801069bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069c2:	eb 42                	jmp    80106a06 <sys_mencrypt+0x76>
  }
  if(argptr(0, &virtual_addr, 1) < 0)
801069c4:	83 ec 04             	sub    $0x4,%esp
801069c7:	6a 01                	push   $0x1
801069c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801069cc:	50                   	push   %eax
801069cd:	6a 00                	push   $0x0
801069cf:	e8 35 ef ff ff       	call   80105909 <argptr>
801069d4:	83 c4 10             	add    $0x10,%esp
801069d7:	85 c0                	test   %eax,%eax
801069d9:	79 07                	jns    801069e2 <sys_mencrypt+0x52>
    return -1;
801069db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069e0:	eb 24                	jmp    80106a06 <sys_mencrypt+0x76>
  if ((void *) virtual_addr >= P2V(PHYSTOP)) {
801069e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069e5:	3d ff ff ff 8d       	cmp    $0x8dffffff,%eax
801069ea:	76 07                	jbe    801069f3 <sys_mencrypt+0x63>
    return -1;
801069ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069f1:	eb 13                	jmp    80106a06 <sys_mencrypt+0x76>
  }
  return mencrypt(virtual_addr, len);
801069f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801069f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069f9:	83 ec 08             	sub    $0x8,%esp
801069fc:	52                   	push   %edx
801069fd:	50                   	push   %eax
801069fe:	e8 2a 26 00 00       	call   8010902d <mencrypt>
80106a03:	83 c4 10             	add    $0x10,%esp
}
80106a06:	c9                   	leave  
80106a07:	c3                   	ret    

80106a08 <sys_getpgtable>:

int sys_getpgtable(void) {
80106a08:	f3 0f 1e fb          	endbr32 
80106a0c:	55                   	push   %ebp
80106a0d:	89 e5                	mov    %esp,%ebp
80106a0f:	83 ec 18             	sub    $0x18,%esp
  struct pt_entry * entries; 
  int num,wsetOnly;

  if(argint(1, &num) < 0)
80106a12:	83 ec 08             	sub    $0x8,%esp
80106a15:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a18:	50                   	push   %eax
80106a19:	6a 01                	push   $0x1
80106a1b:	e8 b8 ee ff ff       	call   801058d8 <argint>
80106a20:	83 c4 10             	add    $0x10,%esp
80106a23:	85 c0                	test   %eax,%eax
80106a25:	79 07                	jns    80106a2e <sys_getpgtable+0x26>
    return -1;
80106a27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a2c:	eb 56                	jmp    80106a84 <sys_getpgtable+0x7c>
  if(argint(2, &wsetOnly) < 0)
80106a2e:	83 ec 08             	sub    $0x8,%esp
80106a31:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106a34:	50                   	push   %eax
80106a35:	6a 02                	push   $0x2
80106a37:	e8 9c ee ff ff       	call   801058d8 <argint>
80106a3c:	83 c4 10             	add    $0x10,%esp
80106a3f:	85 c0                	test   %eax,%eax
80106a41:	79 07                	jns    80106a4a <sys_getpgtable+0x42>
    return -1;
80106a43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a48:	eb 3a                	jmp    80106a84 <sys_getpgtable+0x7c>
  if(argptr(0, (char**)&entries, num*sizeof(struct pt_entry)) < 0){
80106a4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a4d:	c1 e0 03             	shl    $0x3,%eax
80106a50:	83 ec 04             	sub    $0x4,%esp
80106a53:	50                   	push   %eax
80106a54:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a57:	50                   	push   %eax
80106a58:	6a 00                	push   $0x0
80106a5a:	e8 aa ee ff ff       	call   80105909 <argptr>
80106a5f:	83 c4 10             	add    $0x10,%esp
80106a62:	85 c0                	test   %eax,%eax
80106a64:	79 07                	jns    80106a6d <sys_getpgtable+0x65>
    return -1;
80106a66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a6b:	eb 17                	jmp    80106a84 <sys_getpgtable+0x7c>
  }
  return getpgtable(entries, num,wsetOnly);
80106a6d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80106a70:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a76:	83 ec 04             	sub    $0x4,%esp
80106a79:	51                   	push   %ecx
80106a7a:	52                   	push   %edx
80106a7b:	50                   	push   %eax
80106a7c:	e8 d3 27 00 00       	call   80109254 <getpgtable>
80106a81:	83 c4 10             	add    $0x10,%esp
}
80106a84:	c9                   	leave  
80106a85:	c3                   	ret    

80106a86 <sys_dump_rawphymem>:


int sys_dump_rawphymem(void) {
80106a86:	f3 0f 1e fb          	endbr32 
80106a8a:	55                   	push   %ebp
80106a8b:	89 e5                	mov    %esp,%ebp
80106a8d:	83 ec 18             	sub    $0x18,%esp
  char * physical_addr; 
  char * buffer;
  if(argptr(1, &buffer, PGSIZE) < 0)
80106a90:	83 ec 04             	sub    $0x4,%esp
80106a93:	68 00 10 00 00       	push   $0x1000
80106a98:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a9b:	50                   	push   %eax
80106a9c:	6a 01                	push   $0x1
80106a9e:	e8 66 ee ff ff       	call   80105909 <argptr>
80106aa3:	83 c4 10             	add    $0x10,%esp
80106aa6:	85 c0                	test   %eax,%eax
80106aa8:	79 07                	jns    80106ab1 <sys_dump_rawphymem+0x2b>
    return -1;
80106aaa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106aaf:	eb 2f                	jmp    80106ae0 <sys_dump_rawphymem+0x5a>
  if(argint(0, (int*)&physical_addr) < 0)
80106ab1:	83 ec 08             	sub    $0x8,%esp
80106ab4:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106ab7:	50                   	push   %eax
80106ab8:	6a 00                	push   $0x0
80106aba:	e8 19 ee ff ff       	call   801058d8 <argint>
80106abf:	83 c4 10             	add    $0x10,%esp
80106ac2:	85 c0                	test   %eax,%eax
80106ac4:	79 07                	jns    80106acd <sys_dump_rawphymem+0x47>
    return -1;
80106ac6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106acb:	eb 13                	jmp    80106ae0 <sys_dump_rawphymem+0x5a>
  return dump_rawphymem(physical_addr, buffer);
80106acd:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ad3:	83 ec 08             	sub    $0x8,%esp
80106ad6:	52                   	push   %edx
80106ad7:	50                   	push   %eax
80106ad8:	e8 fc 29 00 00       	call   801094d9 <dump_rawphymem>
80106add:	83 c4 10             	add    $0x10,%esp
80106ae0:	c9                   	leave  
80106ae1:	c3                   	ret    

80106ae2 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106ae2:	1e                   	push   %ds
  pushl %es
80106ae3:	06                   	push   %es
  pushl %fs
80106ae4:	0f a0                	push   %fs
  pushl %gs
80106ae6:	0f a8                	push   %gs
  pushal
80106ae8:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106ae9:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106aed:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106aef:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106af1:	54                   	push   %esp
  call trap
80106af2:	e8 df 01 00 00       	call   80106cd6 <trap>
  addl $4, %esp
80106af7:	83 c4 04             	add    $0x4,%esp

80106afa <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106afa:	61                   	popa   
  popl %gs
80106afb:	0f a9                	pop    %gs
  popl %fs
80106afd:	0f a1                	pop    %fs
  popl %es
80106aff:	07                   	pop    %es
  popl %ds
80106b00:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106b01:	83 c4 08             	add    $0x8,%esp
  iret
80106b04:	cf                   	iret   

80106b05 <lidt>:
{
80106b05:	55                   	push   %ebp
80106b06:	89 e5                	mov    %esp,%ebp
80106b08:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106b0b:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b0e:	83 e8 01             	sub    $0x1,%eax
80106b11:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106b15:	8b 45 08             	mov    0x8(%ebp),%eax
80106b18:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106b1c:	8b 45 08             	mov    0x8(%ebp),%eax
80106b1f:	c1 e8 10             	shr    $0x10,%eax
80106b22:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106b26:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106b29:	0f 01 18             	lidtl  (%eax)
}
80106b2c:	90                   	nop
80106b2d:	c9                   	leave  
80106b2e:	c3                   	ret    

80106b2f <rcr2>:

static inline uint
rcr2(void)
{
80106b2f:	55                   	push   %ebp
80106b30:	89 e5                	mov    %esp,%ebp
80106b32:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106b35:	0f 20 d0             	mov    %cr2,%eax
80106b38:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106b3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106b3e:	c9                   	leave  
80106b3f:	c3                   	ret    

80106b40 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106b40:	f3 0f 1e fb          	endbr32 
80106b44:	55                   	push   %ebp
80106b45:	89 e5                	mov    %esp,%ebp
80106b47:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106b4a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106b51:	e9 c3 00 00 00       	jmp    80106c19 <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106b56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b59:	8b 04 85 84 d0 10 80 	mov    -0x7fef2f7c(,%eax,4),%eax
80106b60:	89 c2                	mov    %eax,%edx
80106b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b65:	66 89 14 c5 40 8e 11 	mov    %dx,-0x7fee71c0(,%eax,8)
80106b6c:	80 
80106b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b70:	66 c7 04 c5 42 8e 11 	movw   $0x8,-0x7fee71be(,%eax,8)
80106b77:	80 08 00 
80106b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b7d:	0f b6 14 c5 44 8e 11 	movzbl -0x7fee71bc(,%eax,8),%edx
80106b84:	80 
80106b85:	83 e2 e0             	and    $0xffffffe0,%edx
80106b88:	88 14 c5 44 8e 11 80 	mov    %dl,-0x7fee71bc(,%eax,8)
80106b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b92:	0f b6 14 c5 44 8e 11 	movzbl -0x7fee71bc(,%eax,8),%edx
80106b99:	80 
80106b9a:	83 e2 1f             	and    $0x1f,%edx
80106b9d:	88 14 c5 44 8e 11 80 	mov    %dl,-0x7fee71bc(,%eax,8)
80106ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ba7:	0f b6 14 c5 45 8e 11 	movzbl -0x7fee71bb(,%eax,8),%edx
80106bae:	80 
80106baf:	83 e2 f0             	and    $0xfffffff0,%edx
80106bb2:	83 ca 0e             	or     $0xe,%edx
80106bb5:	88 14 c5 45 8e 11 80 	mov    %dl,-0x7fee71bb(,%eax,8)
80106bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bbf:	0f b6 14 c5 45 8e 11 	movzbl -0x7fee71bb(,%eax,8),%edx
80106bc6:	80 
80106bc7:	83 e2 ef             	and    $0xffffffef,%edx
80106bca:	88 14 c5 45 8e 11 80 	mov    %dl,-0x7fee71bb(,%eax,8)
80106bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bd4:	0f b6 14 c5 45 8e 11 	movzbl -0x7fee71bb(,%eax,8),%edx
80106bdb:	80 
80106bdc:	83 e2 9f             	and    $0xffffff9f,%edx
80106bdf:	88 14 c5 45 8e 11 80 	mov    %dl,-0x7fee71bb(,%eax,8)
80106be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106be9:	0f b6 14 c5 45 8e 11 	movzbl -0x7fee71bb(,%eax,8),%edx
80106bf0:	80 
80106bf1:	83 ca 80             	or     $0xffffff80,%edx
80106bf4:	88 14 c5 45 8e 11 80 	mov    %dl,-0x7fee71bb(,%eax,8)
80106bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bfe:	8b 04 85 84 d0 10 80 	mov    -0x7fef2f7c(,%eax,4),%eax
80106c05:	c1 e8 10             	shr    $0x10,%eax
80106c08:	89 c2                	mov    %eax,%edx
80106c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c0d:	66 89 14 c5 46 8e 11 	mov    %dx,-0x7fee71ba(,%eax,8)
80106c14:	80 
  for(i = 0; i < 256; i++)
80106c15:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c19:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106c20:	0f 8e 30 ff ff ff    	jle    80106b56 <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106c26:	a1 84 d1 10 80       	mov    0x8010d184,%eax
80106c2b:	66 a3 40 90 11 80    	mov    %ax,0x80119040
80106c31:	66 c7 05 42 90 11 80 	movw   $0x8,0x80119042
80106c38:	08 00 
80106c3a:	0f b6 05 44 90 11 80 	movzbl 0x80119044,%eax
80106c41:	83 e0 e0             	and    $0xffffffe0,%eax
80106c44:	a2 44 90 11 80       	mov    %al,0x80119044
80106c49:	0f b6 05 44 90 11 80 	movzbl 0x80119044,%eax
80106c50:	83 e0 1f             	and    $0x1f,%eax
80106c53:	a2 44 90 11 80       	mov    %al,0x80119044
80106c58:	0f b6 05 45 90 11 80 	movzbl 0x80119045,%eax
80106c5f:	83 c8 0f             	or     $0xf,%eax
80106c62:	a2 45 90 11 80       	mov    %al,0x80119045
80106c67:	0f b6 05 45 90 11 80 	movzbl 0x80119045,%eax
80106c6e:	83 e0 ef             	and    $0xffffffef,%eax
80106c71:	a2 45 90 11 80       	mov    %al,0x80119045
80106c76:	0f b6 05 45 90 11 80 	movzbl 0x80119045,%eax
80106c7d:	83 c8 60             	or     $0x60,%eax
80106c80:	a2 45 90 11 80       	mov    %al,0x80119045
80106c85:	0f b6 05 45 90 11 80 	movzbl 0x80119045,%eax
80106c8c:	83 c8 80             	or     $0xffffff80,%eax
80106c8f:	a2 45 90 11 80       	mov    %al,0x80119045
80106c94:	a1 84 d1 10 80       	mov    0x8010d184,%eax
80106c99:	c1 e8 10             	shr    $0x10,%eax
80106c9c:	66 a3 46 90 11 80    	mov    %ax,0x80119046

  initlock(&tickslock, "time");
80106ca2:	83 ec 08             	sub    $0x8,%esp
80106ca5:	68 c4 9a 10 80       	push   $0x80109ac4
80106caa:	68 00 8e 11 80       	push   $0x80118e00
80106caf:	e8 0b e6 ff ff       	call   801052bf <initlock>
80106cb4:	83 c4 10             	add    $0x10,%esp
}
80106cb7:	90                   	nop
80106cb8:	c9                   	leave  
80106cb9:	c3                   	ret    

80106cba <idtinit>:

void
idtinit(void)
{
80106cba:	f3 0f 1e fb          	endbr32 
80106cbe:	55                   	push   %ebp
80106cbf:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106cc1:	68 00 08 00 00       	push   $0x800
80106cc6:	68 40 8e 11 80       	push   $0x80118e40
80106ccb:	e8 35 fe ff ff       	call   80106b05 <lidt>
80106cd0:	83 c4 08             	add    $0x8,%esp
}
80106cd3:	90                   	nop
80106cd4:	c9                   	leave  
80106cd5:	c3                   	ret    

80106cd6 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106cd6:	f3 0f 1e fb          	endbr32 
80106cda:	55                   	push   %ebp
80106cdb:	89 e5                	mov    %esp,%ebp
80106cdd:	57                   	push   %edi
80106cde:	56                   	push   %esi
80106cdf:	53                   	push   %ebx
80106ce0:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80106ce3:	8b 45 08             	mov    0x8(%ebp),%eax
80106ce6:	8b 40 30             	mov    0x30(%eax),%eax
80106ce9:	83 f8 40             	cmp    $0x40,%eax
80106cec:	75 3b                	jne    80106d29 <trap+0x53>
    if(myproc()->killed)
80106cee:	e8 06 d8 ff ff       	call   801044f9 <myproc>
80106cf3:	8b 40 24             	mov    0x24(%eax),%eax
80106cf6:	85 c0                	test   %eax,%eax
80106cf8:	74 05                	je     80106cff <trap+0x29>
      exit();
80106cfa:	e8 22 dd ff ff       	call   80104a21 <exit>
    myproc()->tf = tf;
80106cff:	e8 f5 d7 ff ff       	call   801044f9 <myproc>
80106d04:	8b 55 08             	mov    0x8(%ebp),%edx
80106d07:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106d0a:	e8 a1 ec ff ff       	call   801059b0 <syscall>
    if(myproc()->killed)
80106d0f:	e8 e5 d7 ff ff       	call   801044f9 <myproc>
80106d14:	8b 40 24             	mov    0x24(%eax),%eax
80106d17:	85 c0                	test   %eax,%eax
80106d19:	0f 84 42 02 00 00    	je     80106f61 <trap+0x28b>
      exit();
80106d1f:	e8 fd dc ff ff       	call   80104a21 <exit>
    return;
80106d24:	e9 38 02 00 00       	jmp    80106f61 <trap+0x28b>
  }
  char *addr;
  switch(tf->trapno){
80106d29:	8b 45 08             	mov    0x8(%ebp),%eax
80106d2c:	8b 40 30             	mov    0x30(%eax),%eax
80106d2f:	83 e8 0e             	sub    $0xe,%eax
80106d32:	83 f8 31             	cmp    $0x31,%eax
80106d35:	0f 87 ee 00 00 00    	ja     80106e29 <trap+0x153>
80106d3b:	8b 04 85 84 9b 10 80 	mov    -0x7fef647c(,%eax,4),%eax
80106d42:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106d45:	e8 14 d7 ff ff       	call   8010445e <cpuid>
80106d4a:	85 c0                	test   %eax,%eax
80106d4c:	75 3d                	jne    80106d8b <trap+0xb5>
      acquire(&tickslock);
80106d4e:	83 ec 0c             	sub    $0xc,%esp
80106d51:	68 00 8e 11 80       	push   $0x80118e00
80106d56:	e8 8a e5 ff ff       	call   801052e5 <acquire>
80106d5b:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106d5e:	a1 40 96 11 80       	mov    0x80119640,%eax
80106d63:	83 c0 01             	add    $0x1,%eax
80106d66:	a3 40 96 11 80       	mov    %eax,0x80119640
      wakeup(&ticks);
80106d6b:	83 ec 0c             	sub    $0xc,%esp
80106d6e:	68 40 96 11 80       	push   $0x80119640
80106d73:	e8 ed e1 ff ff       	call   80104f65 <wakeup>
80106d78:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106d7b:	83 ec 0c             	sub    $0xc,%esp
80106d7e:	68 00 8e 11 80       	push   $0x80118e00
80106d83:	e8 cf e5 ff ff       	call   80105357 <release>
80106d88:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106d8b:	e8 5e c4 ff ff       	call   801031ee <lapiceoi>
    break;
80106d90:	e9 4c 01 00 00       	jmp    80106ee1 <trap+0x20b>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106d95:	e8 63 bc ff ff       	call   801029fd <ideintr>
    lapiceoi();
80106d9a:	e8 4f c4 ff ff       	call   801031ee <lapiceoi>
    break;
80106d9f:	e9 3d 01 00 00       	jmp    80106ee1 <trap+0x20b>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106da4:	e8 7b c2 ff ff       	call   80103024 <kbdintr>
    lapiceoi();
80106da9:	e8 40 c4 ff ff       	call   801031ee <lapiceoi>
    break;
80106dae:	e9 2e 01 00 00       	jmp    80106ee1 <trap+0x20b>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106db3:	e8 8b 03 00 00       	call   80107143 <uartintr>
    lapiceoi();
80106db8:	e8 31 c4 ff ff       	call   801031ee <lapiceoi>
    break;
80106dbd:	e9 1f 01 00 00       	jmp    80106ee1 <trap+0x20b>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106dc2:	8b 45 08             	mov    0x8(%ebp),%eax
80106dc5:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106dc8:	8b 45 08             	mov    0x8(%ebp),%eax
80106dcb:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106dcf:	0f b7 d8             	movzwl %ax,%ebx
80106dd2:	e8 87 d6 ff ff       	call   8010445e <cpuid>
80106dd7:	56                   	push   %esi
80106dd8:	53                   	push   %ebx
80106dd9:	50                   	push   %eax
80106dda:	68 cc 9a 10 80       	push   $0x80109acc
80106ddf:	e8 34 96 ff ff       	call   80100418 <cprintf>
80106de4:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106de7:	e8 02 c4 ff ff       	call   801031ee <lapiceoi>
    break;
80106dec:	e9 f0 00 00 00       	jmp    80106ee1 <trap+0x20b>
  case T_PGFLT:
    //Food for thought: How can one distinguish between a regular page fault and a decryption request?
    cprintf("p4Debug : Page fault !\n");
80106df1:	83 ec 0c             	sub    $0xc,%esp
80106df4:	68 f0 9a 10 80       	push   $0x80109af0
80106df9:	e8 1a 96 ff ff       	call   80100418 <cprintf>
80106dfe:	83 c4 10             	add    $0x10,%esp
    addr = (char*)rcr2();
80106e01:	e8 29 fd ff ff       	call   80106b2f <rcr2>
80106e06:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (mdecrypt(addr))
80106e09:	83 ec 0c             	sub    $0xc,%esp
80106e0c:	ff 75 e4             	pushl  -0x1c(%ebp)
80106e0f:	e8 b2 1e 00 00       	call   80108cc6 <mdecrypt>
80106e14:	83 c4 10             	add    $0x10,%esp
80106e17:	85 c0                	test   %eax,%eax
80106e19:	0f 84 c1 00 00 00    	je     80106ee0 <trap+0x20a>
    {
        //panic("p4Debug: Memory fault");
        exit();
80106e1f:	e8 fd db ff ff       	call   80104a21 <exit>
    };
    break;
80106e24:	e9 b7 00 00 00       	jmp    80106ee0 <trap+0x20a>
  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106e29:	e8 cb d6 ff ff       	call   801044f9 <myproc>
80106e2e:	85 c0                	test   %eax,%eax
80106e30:	74 11                	je     80106e43 <trap+0x16d>
80106e32:	8b 45 08             	mov    0x8(%ebp),%eax
80106e35:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106e39:	0f b7 c0             	movzwl %ax,%eax
80106e3c:	83 e0 03             	and    $0x3,%eax
80106e3f:	85 c0                	test   %eax,%eax
80106e41:	75 39                	jne    80106e7c <trap+0x1a6>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106e43:	e8 e7 fc ff ff       	call   80106b2f <rcr2>
80106e48:	89 c3                	mov    %eax,%ebx
80106e4a:	8b 45 08             	mov    0x8(%ebp),%eax
80106e4d:	8b 70 38             	mov    0x38(%eax),%esi
80106e50:	e8 09 d6 ff ff       	call   8010445e <cpuid>
80106e55:	8b 55 08             	mov    0x8(%ebp),%edx
80106e58:	8b 52 30             	mov    0x30(%edx),%edx
80106e5b:	83 ec 0c             	sub    $0xc,%esp
80106e5e:	53                   	push   %ebx
80106e5f:	56                   	push   %esi
80106e60:	50                   	push   %eax
80106e61:	52                   	push   %edx
80106e62:	68 08 9b 10 80       	push   $0x80109b08
80106e67:	e8 ac 95 ff ff       	call   80100418 <cprintf>
80106e6c:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106e6f:	83 ec 0c             	sub    $0xc,%esp
80106e72:	68 3a 9b 10 80       	push   $0x80109b3a
80106e77:	e8 8c 97 ff ff       	call   80100608 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e7c:	e8 ae fc ff ff       	call   80106b2f <rcr2>
80106e81:	89 c6                	mov    %eax,%esi
80106e83:	8b 45 08             	mov    0x8(%ebp),%eax
80106e86:	8b 40 38             	mov    0x38(%eax),%eax
80106e89:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106e8c:	e8 cd d5 ff ff       	call   8010445e <cpuid>
80106e91:	89 c3                	mov    %eax,%ebx
80106e93:	8b 45 08             	mov    0x8(%ebp),%eax
80106e96:	8b 48 34             	mov    0x34(%eax),%ecx
80106e99:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106e9c:	8b 45 08             	mov    0x8(%ebp),%eax
80106e9f:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106ea2:	e8 52 d6 ff ff       	call   801044f9 <myproc>
80106ea7:	8d 50 6c             	lea    0x6c(%eax),%edx
80106eaa:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106ead:	e8 47 d6 ff ff       	call   801044f9 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106eb2:	8b 40 10             	mov    0x10(%eax),%eax
80106eb5:	56                   	push   %esi
80106eb6:	ff 75 d4             	pushl  -0x2c(%ebp)
80106eb9:	53                   	push   %ebx
80106eba:	ff 75 d0             	pushl  -0x30(%ebp)
80106ebd:	57                   	push   %edi
80106ebe:	ff 75 cc             	pushl  -0x34(%ebp)
80106ec1:	50                   	push   %eax
80106ec2:	68 40 9b 10 80       	push   $0x80109b40
80106ec7:	e8 4c 95 ff ff       	call   80100418 <cprintf>
80106ecc:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106ecf:	e8 25 d6 ff ff       	call   801044f9 <myproc>
80106ed4:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106edb:	eb 04                	jmp    80106ee1 <trap+0x20b>
    break;
80106edd:	90                   	nop
80106ede:	eb 01                	jmp    80106ee1 <trap+0x20b>
    break;
80106ee0:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106ee1:	e8 13 d6 ff ff       	call   801044f9 <myproc>
80106ee6:	85 c0                	test   %eax,%eax
80106ee8:	74 23                	je     80106f0d <trap+0x237>
80106eea:	e8 0a d6 ff ff       	call   801044f9 <myproc>
80106eef:	8b 40 24             	mov    0x24(%eax),%eax
80106ef2:	85 c0                	test   %eax,%eax
80106ef4:	74 17                	je     80106f0d <trap+0x237>
80106ef6:	8b 45 08             	mov    0x8(%ebp),%eax
80106ef9:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106efd:	0f b7 c0             	movzwl %ax,%eax
80106f00:	83 e0 03             	and    $0x3,%eax
80106f03:	83 f8 03             	cmp    $0x3,%eax
80106f06:	75 05                	jne    80106f0d <trap+0x237>
    exit();
80106f08:	e8 14 db ff ff       	call   80104a21 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106f0d:	e8 e7 d5 ff ff       	call   801044f9 <myproc>
80106f12:	85 c0                	test   %eax,%eax
80106f14:	74 1d                	je     80106f33 <trap+0x25d>
80106f16:	e8 de d5 ff ff       	call   801044f9 <myproc>
80106f1b:	8b 40 0c             	mov    0xc(%eax),%eax
80106f1e:	83 f8 04             	cmp    $0x4,%eax
80106f21:	75 10                	jne    80106f33 <trap+0x25d>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106f23:	8b 45 08             	mov    0x8(%ebp),%eax
80106f26:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106f29:	83 f8 20             	cmp    $0x20,%eax
80106f2c:	75 05                	jne    80106f33 <trap+0x25d>
    yield();
80106f2e:	e8 b8 de ff ff       	call   80104deb <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106f33:	e8 c1 d5 ff ff       	call   801044f9 <myproc>
80106f38:	85 c0                	test   %eax,%eax
80106f3a:	74 26                	je     80106f62 <trap+0x28c>
80106f3c:	e8 b8 d5 ff ff       	call   801044f9 <myproc>
80106f41:	8b 40 24             	mov    0x24(%eax),%eax
80106f44:	85 c0                	test   %eax,%eax
80106f46:	74 1a                	je     80106f62 <trap+0x28c>
80106f48:	8b 45 08             	mov    0x8(%ebp),%eax
80106f4b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106f4f:	0f b7 c0             	movzwl %ax,%eax
80106f52:	83 e0 03             	and    $0x3,%eax
80106f55:	83 f8 03             	cmp    $0x3,%eax
80106f58:	75 08                	jne    80106f62 <trap+0x28c>
    exit();
80106f5a:	e8 c2 da ff ff       	call   80104a21 <exit>
80106f5f:	eb 01                	jmp    80106f62 <trap+0x28c>
    return;
80106f61:	90                   	nop
}
80106f62:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106f65:	5b                   	pop    %ebx
80106f66:	5e                   	pop    %esi
80106f67:	5f                   	pop    %edi
80106f68:	5d                   	pop    %ebp
80106f69:	c3                   	ret    

80106f6a <inb>:
{
80106f6a:	55                   	push   %ebp
80106f6b:	89 e5                	mov    %esp,%ebp
80106f6d:	83 ec 14             	sub    $0x14,%esp
80106f70:	8b 45 08             	mov    0x8(%ebp),%eax
80106f73:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106f77:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106f7b:	89 c2                	mov    %eax,%edx
80106f7d:	ec                   	in     (%dx),%al
80106f7e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106f81:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106f85:	c9                   	leave  
80106f86:	c3                   	ret    

80106f87 <outb>:
{
80106f87:	55                   	push   %ebp
80106f88:	89 e5                	mov    %esp,%ebp
80106f8a:	83 ec 08             	sub    $0x8,%esp
80106f8d:	8b 45 08             	mov    0x8(%ebp),%eax
80106f90:	8b 55 0c             	mov    0xc(%ebp),%edx
80106f93:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106f97:	89 d0                	mov    %edx,%eax
80106f99:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106f9c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106fa0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106fa4:	ee                   	out    %al,(%dx)
}
80106fa5:	90                   	nop
80106fa6:	c9                   	leave  
80106fa7:	c3                   	ret    

80106fa8 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106fa8:	f3 0f 1e fb          	endbr32 
80106fac:	55                   	push   %ebp
80106fad:	89 e5                	mov    %esp,%ebp
80106faf:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106fb2:	6a 00                	push   $0x0
80106fb4:	68 fa 03 00 00       	push   $0x3fa
80106fb9:	e8 c9 ff ff ff       	call   80106f87 <outb>
80106fbe:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106fc1:	68 80 00 00 00       	push   $0x80
80106fc6:	68 fb 03 00 00       	push   $0x3fb
80106fcb:	e8 b7 ff ff ff       	call   80106f87 <outb>
80106fd0:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106fd3:	6a 0c                	push   $0xc
80106fd5:	68 f8 03 00 00       	push   $0x3f8
80106fda:	e8 a8 ff ff ff       	call   80106f87 <outb>
80106fdf:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106fe2:	6a 00                	push   $0x0
80106fe4:	68 f9 03 00 00       	push   $0x3f9
80106fe9:	e8 99 ff ff ff       	call   80106f87 <outb>
80106fee:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106ff1:	6a 03                	push   $0x3
80106ff3:	68 fb 03 00 00       	push   $0x3fb
80106ff8:	e8 8a ff ff ff       	call   80106f87 <outb>
80106ffd:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107000:	6a 00                	push   $0x0
80107002:	68 fc 03 00 00       	push   $0x3fc
80107007:	e8 7b ff ff ff       	call   80106f87 <outb>
8010700c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010700f:	6a 01                	push   $0x1
80107011:	68 f9 03 00 00       	push   $0x3f9
80107016:	e8 6c ff ff ff       	call   80106f87 <outb>
8010701b:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
8010701e:	68 fd 03 00 00       	push   $0x3fd
80107023:	e8 42 ff ff ff       	call   80106f6a <inb>
80107028:	83 c4 04             	add    $0x4,%esp
8010702b:	3c ff                	cmp    $0xff,%al
8010702d:	74 61                	je     80107090 <uartinit+0xe8>
    return;
  uart = 1;
8010702f:	c7 05 44 d6 10 80 01 	movl   $0x1,0x8010d644
80107036:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107039:	68 fa 03 00 00       	push   $0x3fa
8010703e:	e8 27 ff ff ff       	call   80106f6a <inb>
80107043:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80107046:	68 f8 03 00 00       	push   $0x3f8
8010704b:	e8 1a ff ff ff       	call   80106f6a <inb>
80107050:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80107053:	83 ec 08             	sub    $0x8,%esp
80107056:	6a 00                	push   $0x0
80107058:	6a 04                	push   $0x4
8010705a:	e8 50 bc ff ff       	call   80102caf <ioapicenable>
8010705f:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107062:	c7 45 f4 4c 9c 10 80 	movl   $0x80109c4c,-0xc(%ebp)
80107069:	eb 19                	jmp    80107084 <uartinit+0xdc>
    uartputc(*p);
8010706b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010706e:	0f b6 00             	movzbl (%eax),%eax
80107071:	0f be c0             	movsbl %al,%eax
80107074:	83 ec 0c             	sub    $0xc,%esp
80107077:	50                   	push   %eax
80107078:	e8 16 00 00 00       	call   80107093 <uartputc>
8010707d:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80107080:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107084:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107087:	0f b6 00             	movzbl (%eax),%eax
8010708a:	84 c0                	test   %al,%al
8010708c:	75 dd                	jne    8010706b <uartinit+0xc3>
8010708e:	eb 01                	jmp    80107091 <uartinit+0xe9>
    return;
80107090:	90                   	nop
}
80107091:	c9                   	leave  
80107092:	c3                   	ret    

80107093 <uartputc>:

void
uartputc(int c)
{
80107093:	f3 0f 1e fb          	endbr32 
80107097:	55                   	push   %ebp
80107098:	89 e5                	mov    %esp,%ebp
8010709a:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
8010709d:	a1 44 d6 10 80       	mov    0x8010d644,%eax
801070a2:	85 c0                	test   %eax,%eax
801070a4:	74 53                	je     801070f9 <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801070a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801070ad:	eb 11                	jmp    801070c0 <uartputc+0x2d>
    microdelay(10);
801070af:	83 ec 0c             	sub    $0xc,%esp
801070b2:	6a 0a                	push   $0xa
801070b4:	e8 54 c1 ff ff       	call   8010320d <microdelay>
801070b9:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801070bc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801070c0:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801070c4:	7f 1a                	jg     801070e0 <uartputc+0x4d>
801070c6:	83 ec 0c             	sub    $0xc,%esp
801070c9:	68 fd 03 00 00       	push   $0x3fd
801070ce:	e8 97 fe ff ff       	call   80106f6a <inb>
801070d3:	83 c4 10             	add    $0x10,%esp
801070d6:	0f b6 c0             	movzbl %al,%eax
801070d9:	83 e0 20             	and    $0x20,%eax
801070dc:	85 c0                	test   %eax,%eax
801070de:	74 cf                	je     801070af <uartputc+0x1c>
  outb(COM1+0, c);
801070e0:	8b 45 08             	mov    0x8(%ebp),%eax
801070e3:	0f b6 c0             	movzbl %al,%eax
801070e6:	83 ec 08             	sub    $0x8,%esp
801070e9:	50                   	push   %eax
801070ea:	68 f8 03 00 00       	push   $0x3f8
801070ef:	e8 93 fe ff ff       	call   80106f87 <outb>
801070f4:	83 c4 10             	add    $0x10,%esp
801070f7:	eb 01                	jmp    801070fa <uartputc+0x67>
    return;
801070f9:	90                   	nop
}
801070fa:	c9                   	leave  
801070fb:	c3                   	ret    

801070fc <uartgetc>:

static int
uartgetc(void)
{
801070fc:	f3 0f 1e fb          	endbr32 
80107100:	55                   	push   %ebp
80107101:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107103:	a1 44 d6 10 80       	mov    0x8010d644,%eax
80107108:	85 c0                	test   %eax,%eax
8010710a:	75 07                	jne    80107113 <uartgetc+0x17>
    return -1;
8010710c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107111:	eb 2e                	jmp    80107141 <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
80107113:	68 fd 03 00 00       	push   $0x3fd
80107118:	e8 4d fe ff ff       	call   80106f6a <inb>
8010711d:	83 c4 04             	add    $0x4,%esp
80107120:	0f b6 c0             	movzbl %al,%eax
80107123:	83 e0 01             	and    $0x1,%eax
80107126:	85 c0                	test   %eax,%eax
80107128:	75 07                	jne    80107131 <uartgetc+0x35>
    return -1;
8010712a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010712f:	eb 10                	jmp    80107141 <uartgetc+0x45>
  return inb(COM1+0);
80107131:	68 f8 03 00 00       	push   $0x3f8
80107136:	e8 2f fe ff ff       	call   80106f6a <inb>
8010713b:	83 c4 04             	add    $0x4,%esp
8010713e:	0f b6 c0             	movzbl %al,%eax
}
80107141:	c9                   	leave  
80107142:	c3                   	ret    

80107143 <uartintr>:

void
uartintr(void)
{
80107143:	f3 0f 1e fb          	endbr32 
80107147:	55                   	push   %ebp
80107148:	89 e5                	mov    %esp,%ebp
8010714a:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
8010714d:	83 ec 0c             	sub    $0xc,%esp
80107150:	68 fc 70 10 80       	push   $0x801070fc
80107155:	e8 4e 97 ff ff       	call   801008a8 <consoleintr>
8010715a:	83 c4 10             	add    $0x10,%esp
}
8010715d:	90                   	nop
8010715e:	c9                   	leave  
8010715f:	c3                   	ret    

80107160 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107160:	6a 00                	push   $0x0
  pushl $0
80107162:	6a 00                	push   $0x0
  jmp alltraps
80107164:	e9 79 f9 ff ff       	jmp    80106ae2 <alltraps>

80107169 <vector1>:
.globl vector1
vector1:
  pushl $0
80107169:	6a 00                	push   $0x0
  pushl $1
8010716b:	6a 01                	push   $0x1
  jmp alltraps
8010716d:	e9 70 f9 ff ff       	jmp    80106ae2 <alltraps>

80107172 <vector2>:
.globl vector2
vector2:
  pushl $0
80107172:	6a 00                	push   $0x0
  pushl $2
80107174:	6a 02                	push   $0x2
  jmp alltraps
80107176:	e9 67 f9 ff ff       	jmp    80106ae2 <alltraps>

8010717b <vector3>:
.globl vector3
vector3:
  pushl $0
8010717b:	6a 00                	push   $0x0
  pushl $3
8010717d:	6a 03                	push   $0x3
  jmp alltraps
8010717f:	e9 5e f9 ff ff       	jmp    80106ae2 <alltraps>

80107184 <vector4>:
.globl vector4
vector4:
  pushl $0
80107184:	6a 00                	push   $0x0
  pushl $4
80107186:	6a 04                	push   $0x4
  jmp alltraps
80107188:	e9 55 f9 ff ff       	jmp    80106ae2 <alltraps>

8010718d <vector5>:
.globl vector5
vector5:
  pushl $0
8010718d:	6a 00                	push   $0x0
  pushl $5
8010718f:	6a 05                	push   $0x5
  jmp alltraps
80107191:	e9 4c f9 ff ff       	jmp    80106ae2 <alltraps>

80107196 <vector6>:
.globl vector6
vector6:
  pushl $0
80107196:	6a 00                	push   $0x0
  pushl $6
80107198:	6a 06                	push   $0x6
  jmp alltraps
8010719a:	e9 43 f9 ff ff       	jmp    80106ae2 <alltraps>

8010719f <vector7>:
.globl vector7
vector7:
  pushl $0
8010719f:	6a 00                	push   $0x0
  pushl $7
801071a1:	6a 07                	push   $0x7
  jmp alltraps
801071a3:	e9 3a f9 ff ff       	jmp    80106ae2 <alltraps>

801071a8 <vector8>:
.globl vector8
vector8:
  pushl $8
801071a8:	6a 08                	push   $0x8
  jmp alltraps
801071aa:	e9 33 f9 ff ff       	jmp    80106ae2 <alltraps>

801071af <vector9>:
.globl vector9
vector9:
  pushl $0
801071af:	6a 00                	push   $0x0
  pushl $9
801071b1:	6a 09                	push   $0x9
  jmp alltraps
801071b3:	e9 2a f9 ff ff       	jmp    80106ae2 <alltraps>

801071b8 <vector10>:
.globl vector10
vector10:
  pushl $10
801071b8:	6a 0a                	push   $0xa
  jmp alltraps
801071ba:	e9 23 f9 ff ff       	jmp    80106ae2 <alltraps>

801071bf <vector11>:
.globl vector11
vector11:
  pushl $11
801071bf:	6a 0b                	push   $0xb
  jmp alltraps
801071c1:	e9 1c f9 ff ff       	jmp    80106ae2 <alltraps>

801071c6 <vector12>:
.globl vector12
vector12:
  pushl $12
801071c6:	6a 0c                	push   $0xc
  jmp alltraps
801071c8:	e9 15 f9 ff ff       	jmp    80106ae2 <alltraps>

801071cd <vector13>:
.globl vector13
vector13:
  pushl $13
801071cd:	6a 0d                	push   $0xd
  jmp alltraps
801071cf:	e9 0e f9 ff ff       	jmp    80106ae2 <alltraps>

801071d4 <vector14>:
.globl vector14
vector14:
  pushl $14
801071d4:	6a 0e                	push   $0xe
  jmp alltraps
801071d6:	e9 07 f9 ff ff       	jmp    80106ae2 <alltraps>

801071db <vector15>:
.globl vector15
vector15:
  pushl $0
801071db:	6a 00                	push   $0x0
  pushl $15
801071dd:	6a 0f                	push   $0xf
  jmp alltraps
801071df:	e9 fe f8 ff ff       	jmp    80106ae2 <alltraps>

801071e4 <vector16>:
.globl vector16
vector16:
  pushl $0
801071e4:	6a 00                	push   $0x0
  pushl $16
801071e6:	6a 10                	push   $0x10
  jmp alltraps
801071e8:	e9 f5 f8 ff ff       	jmp    80106ae2 <alltraps>

801071ed <vector17>:
.globl vector17
vector17:
  pushl $17
801071ed:	6a 11                	push   $0x11
  jmp alltraps
801071ef:	e9 ee f8 ff ff       	jmp    80106ae2 <alltraps>

801071f4 <vector18>:
.globl vector18
vector18:
  pushl $0
801071f4:	6a 00                	push   $0x0
  pushl $18
801071f6:	6a 12                	push   $0x12
  jmp alltraps
801071f8:	e9 e5 f8 ff ff       	jmp    80106ae2 <alltraps>

801071fd <vector19>:
.globl vector19
vector19:
  pushl $0
801071fd:	6a 00                	push   $0x0
  pushl $19
801071ff:	6a 13                	push   $0x13
  jmp alltraps
80107201:	e9 dc f8 ff ff       	jmp    80106ae2 <alltraps>

80107206 <vector20>:
.globl vector20
vector20:
  pushl $0
80107206:	6a 00                	push   $0x0
  pushl $20
80107208:	6a 14                	push   $0x14
  jmp alltraps
8010720a:	e9 d3 f8 ff ff       	jmp    80106ae2 <alltraps>

8010720f <vector21>:
.globl vector21
vector21:
  pushl $0
8010720f:	6a 00                	push   $0x0
  pushl $21
80107211:	6a 15                	push   $0x15
  jmp alltraps
80107213:	e9 ca f8 ff ff       	jmp    80106ae2 <alltraps>

80107218 <vector22>:
.globl vector22
vector22:
  pushl $0
80107218:	6a 00                	push   $0x0
  pushl $22
8010721a:	6a 16                	push   $0x16
  jmp alltraps
8010721c:	e9 c1 f8 ff ff       	jmp    80106ae2 <alltraps>

80107221 <vector23>:
.globl vector23
vector23:
  pushl $0
80107221:	6a 00                	push   $0x0
  pushl $23
80107223:	6a 17                	push   $0x17
  jmp alltraps
80107225:	e9 b8 f8 ff ff       	jmp    80106ae2 <alltraps>

8010722a <vector24>:
.globl vector24
vector24:
  pushl $0
8010722a:	6a 00                	push   $0x0
  pushl $24
8010722c:	6a 18                	push   $0x18
  jmp alltraps
8010722e:	e9 af f8 ff ff       	jmp    80106ae2 <alltraps>

80107233 <vector25>:
.globl vector25
vector25:
  pushl $0
80107233:	6a 00                	push   $0x0
  pushl $25
80107235:	6a 19                	push   $0x19
  jmp alltraps
80107237:	e9 a6 f8 ff ff       	jmp    80106ae2 <alltraps>

8010723c <vector26>:
.globl vector26
vector26:
  pushl $0
8010723c:	6a 00                	push   $0x0
  pushl $26
8010723e:	6a 1a                	push   $0x1a
  jmp alltraps
80107240:	e9 9d f8 ff ff       	jmp    80106ae2 <alltraps>

80107245 <vector27>:
.globl vector27
vector27:
  pushl $0
80107245:	6a 00                	push   $0x0
  pushl $27
80107247:	6a 1b                	push   $0x1b
  jmp alltraps
80107249:	e9 94 f8 ff ff       	jmp    80106ae2 <alltraps>

8010724e <vector28>:
.globl vector28
vector28:
  pushl $0
8010724e:	6a 00                	push   $0x0
  pushl $28
80107250:	6a 1c                	push   $0x1c
  jmp alltraps
80107252:	e9 8b f8 ff ff       	jmp    80106ae2 <alltraps>

80107257 <vector29>:
.globl vector29
vector29:
  pushl $0
80107257:	6a 00                	push   $0x0
  pushl $29
80107259:	6a 1d                	push   $0x1d
  jmp alltraps
8010725b:	e9 82 f8 ff ff       	jmp    80106ae2 <alltraps>

80107260 <vector30>:
.globl vector30
vector30:
  pushl $0
80107260:	6a 00                	push   $0x0
  pushl $30
80107262:	6a 1e                	push   $0x1e
  jmp alltraps
80107264:	e9 79 f8 ff ff       	jmp    80106ae2 <alltraps>

80107269 <vector31>:
.globl vector31
vector31:
  pushl $0
80107269:	6a 00                	push   $0x0
  pushl $31
8010726b:	6a 1f                	push   $0x1f
  jmp alltraps
8010726d:	e9 70 f8 ff ff       	jmp    80106ae2 <alltraps>

80107272 <vector32>:
.globl vector32
vector32:
  pushl $0
80107272:	6a 00                	push   $0x0
  pushl $32
80107274:	6a 20                	push   $0x20
  jmp alltraps
80107276:	e9 67 f8 ff ff       	jmp    80106ae2 <alltraps>

8010727b <vector33>:
.globl vector33
vector33:
  pushl $0
8010727b:	6a 00                	push   $0x0
  pushl $33
8010727d:	6a 21                	push   $0x21
  jmp alltraps
8010727f:	e9 5e f8 ff ff       	jmp    80106ae2 <alltraps>

80107284 <vector34>:
.globl vector34
vector34:
  pushl $0
80107284:	6a 00                	push   $0x0
  pushl $34
80107286:	6a 22                	push   $0x22
  jmp alltraps
80107288:	e9 55 f8 ff ff       	jmp    80106ae2 <alltraps>

8010728d <vector35>:
.globl vector35
vector35:
  pushl $0
8010728d:	6a 00                	push   $0x0
  pushl $35
8010728f:	6a 23                	push   $0x23
  jmp alltraps
80107291:	e9 4c f8 ff ff       	jmp    80106ae2 <alltraps>

80107296 <vector36>:
.globl vector36
vector36:
  pushl $0
80107296:	6a 00                	push   $0x0
  pushl $36
80107298:	6a 24                	push   $0x24
  jmp alltraps
8010729a:	e9 43 f8 ff ff       	jmp    80106ae2 <alltraps>

8010729f <vector37>:
.globl vector37
vector37:
  pushl $0
8010729f:	6a 00                	push   $0x0
  pushl $37
801072a1:	6a 25                	push   $0x25
  jmp alltraps
801072a3:	e9 3a f8 ff ff       	jmp    80106ae2 <alltraps>

801072a8 <vector38>:
.globl vector38
vector38:
  pushl $0
801072a8:	6a 00                	push   $0x0
  pushl $38
801072aa:	6a 26                	push   $0x26
  jmp alltraps
801072ac:	e9 31 f8 ff ff       	jmp    80106ae2 <alltraps>

801072b1 <vector39>:
.globl vector39
vector39:
  pushl $0
801072b1:	6a 00                	push   $0x0
  pushl $39
801072b3:	6a 27                	push   $0x27
  jmp alltraps
801072b5:	e9 28 f8 ff ff       	jmp    80106ae2 <alltraps>

801072ba <vector40>:
.globl vector40
vector40:
  pushl $0
801072ba:	6a 00                	push   $0x0
  pushl $40
801072bc:	6a 28                	push   $0x28
  jmp alltraps
801072be:	e9 1f f8 ff ff       	jmp    80106ae2 <alltraps>

801072c3 <vector41>:
.globl vector41
vector41:
  pushl $0
801072c3:	6a 00                	push   $0x0
  pushl $41
801072c5:	6a 29                	push   $0x29
  jmp alltraps
801072c7:	e9 16 f8 ff ff       	jmp    80106ae2 <alltraps>

801072cc <vector42>:
.globl vector42
vector42:
  pushl $0
801072cc:	6a 00                	push   $0x0
  pushl $42
801072ce:	6a 2a                	push   $0x2a
  jmp alltraps
801072d0:	e9 0d f8 ff ff       	jmp    80106ae2 <alltraps>

801072d5 <vector43>:
.globl vector43
vector43:
  pushl $0
801072d5:	6a 00                	push   $0x0
  pushl $43
801072d7:	6a 2b                	push   $0x2b
  jmp alltraps
801072d9:	e9 04 f8 ff ff       	jmp    80106ae2 <alltraps>

801072de <vector44>:
.globl vector44
vector44:
  pushl $0
801072de:	6a 00                	push   $0x0
  pushl $44
801072e0:	6a 2c                	push   $0x2c
  jmp alltraps
801072e2:	e9 fb f7 ff ff       	jmp    80106ae2 <alltraps>

801072e7 <vector45>:
.globl vector45
vector45:
  pushl $0
801072e7:	6a 00                	push   $0x0
  pushl $45
801072e9:	6a 2d                	push   $0x2d
  jmp alltraps
801072eb:	e9 f2 f7 ff ff       	jmp    80106ae2 <alltraps>

801072f0 <vector46>:
.globl vector46
vector46:
  pushl $0
801072f0:	6a 00                	push   $0x0
  pushl $46
801072f2:	6a 2e                	push   $0x2e
  jmp alltraps
801072f4:	e9 e9 f7 ff ff       	jmp    80106ae2 <alltraps>

801072f9 <vector47>:
.globl vector47
vector47:
  pushl $0
801072f9:	6a 00                	push   $0x0
  pushl $47
801072fb:	6a 2f                	push   $0x2f
  jmp alltraps
801072fd:	e9 e0 f7 ff ff       	jmp    80106ae2 <alltraps>

80107302 <vector48>:
.globl vector48
vector48:
  pushl $0
80107302:	6a 00                	push   $0x0
  pushl $48
80107304:	6a 30                	push   $0x30
  jmp alltraps
80107306:	e9 d7 f7 ff ff       	jmp    80106ae2 <alltraps>

8010730b <vector49>:
.globl vector49
vector49:
  pushl $0
8010730b:	6a 00                	push   $0x0
  pushl $49
8010730d:	6a 31                	push   $0x31
  jmp alltraps
8010730f:	e9 ce f7 ff ff       	jmp    80106ae2 <alltraps>

80107314 <vector50>:
.globl vector50
vector50:
  pushl $0
80107314:	6a 00                	push   $0x0
  pushl $50
80107316:	6a 32                	push   $0x32
  jmp alltraps
80107318:	e9 c5 f7 ff ff       	jmp    80106ae2 <alltraps>

8010731d <vector51>:
.globl vector51
vector51:
  pushl $0
8010731d:	6a 00                	push   $0x0
  pushl $51
8010731f:	6a 33                	push   $0x33
  jmp alltraps
80107321:	e9 bc f7 ff ff       	jmp    80106ae2 <alltraps>

80107326 <vector52>:
.globl vector52
vector52:
  pushl $0
80107326:	6a 00                	push   $0x0
  pushl $52
80107328:	6a 34                	push   $0x34
  jmp alltraps
8010732a:	e9 b3 f7 ff ff       	jmp    80106ae2 <alltraps>

8010732f <vector53>:
.globl vector53
vector53:
  pushl $0
8010732f:	6a 00                	push   $0x0
  pushl $53
80107331:	6a 35                	push   $0x35
  jmp alltraps
80107333:	e9 aa f7 ff ff       	jmp    80106ae2 <alltraps>

80107338 <vector54>:
.globl vector54
vector54:
  pushl $0
80107338:	6a 00                	push   $0x0
  pushl $54
8010733a:	6a 36                	push   $0x36
  jmp alltraps
8010733c:	e9 a1 f7 ff ff       	jmp    80106ae2 <alltraps>

80107341 <vector55>:
.globl vector55
vector55:
  pushl $0
80107341:	6a 00                	push   $0x0
  pushl $55
80107343:	6a 37                	push   $0x37
  jmp alltraps
80107345:	e9 98 f7 ff ff       	jmp    80106ae2 <alltraps>

8010734a <vector56>:
.globl vector56
vector56:
  pushl $0
8010734a:	6a 00                	push   $0x0
  pushl $56
8010734c:	6a 38                	push   $0x38
  jmp alltraps
8010734e:	e9 8f f7 ff ff       	jmp    80106ae2 <alltraps>

80107353 <vector57>:
.globl vector57
vector57:
  pushl $0
80107353:	6a 00                	push   $0x0
  pushl $57
80107355:	6a 39                	push   $0x39
  jmp alltraps
80107357:	e9 86 f7 ff ff       	jmp    80106ae2 <alltraps>

8010735c <vector58>:
.globl vector58
vector58:
  pushl $0
8010735c:	6a 00                	push   $0x0
  pushl $58
8010735e:	6a 3a                	push   $0x3a
  jmp alltraps
80107360:	e9 7d f7 ff ff       	jmp    80106ae2 <alltraps>

80107365 <vector59>:
.globl vector59
vector59:
  pushl $0
80107365:	6a 00                	push   $0x0
  pushl $59
80107367:	6a 3b                	push   $0x3b
  jmp alltraps
80107369:	e9 74 f7 ff ff       	jmp    80106ae2 <alltraps>

8010736e <vector60>:
.globl vector60
vector60:
  pushl $0
8010736e:	6a 00                	push   $0x0
  pushl $60
80107370:	6a 3c                	push   $0x3c
  jmp alltraps
80107372:	e9 6b f7 ff ff       	jmp    80106ae2 <alltraps>

80107377 <vector61>:
.globl vector61
vector61:
  pushl $0
80107377:	6a 00                	push   $0x0
  pushl $61
80107379:	6a 3d                	push   $0x3d
  jmp alltraps
8010737b:	e9 62 f7 ff ff       	jmp    80106ae2 <alltraps>

80107380 <vector62>:
.globl vector62
vector62:
  pushl $0
80107380:	6a 00                	push   $0x0
  pushl $62
80107382:	6a 3e                	push   $0x3e
  jmp alltraps
80107384:	e9 59 f7 ff ff       	jmp    80106ae2 <alltraps>

80107389 <vector63>:
.globl vector63
vector63:
  pushl $0
80107389:	6a 00                	push   $0x0
  pushl $63
8010738b:	6a 3f                	push   $0x3f
  jmp alltraps
8010738d:	e9 50 f7 ff ff       	jmp    80106ae2 <alltraps>

80107392 <vector64>:
.globl vector64
vector64:
  pushl $0
80107392:	6a 00                	push   $0x0
  pushl $64
80107394:	6a 40                	push   $0x40
  jmp alltraps
80107396:	e9 47 f7 ff ff       	jmp    80106ae2 <alltraps>

8010739b <vector65>:
.globl vector65
vector65:
  pushl $0
8010739b:	6a 00                	push   $0x0
  pushl $65
8010739d:	6a 41                	push   $0x41
  jmp alltraps
8010739f:	e9 3e f7 ff ff       	jmp    80106ae2 <alltraps>

801073a4 <vector66>:
.globl vector66
vector66:
  pushl $0
801073a4:	6a 00                	push   $0x0
  pushl $66
801073a6:	6a 42                	push   $0x42
  jmp alltraps
801073a8:	e9 35 f7 ff ff       	jmp    80106ae2 <alltraps>

801073ad <vector67>:
.globl vector67
vector67:
  pushl $0
801073ad:	6a 00                	push   $0x0
  pushl $67
801073af:	6a 43                	push   $0x43
  jmp alltraps
801073b1:	e9 2c f7 ff ff       	jmp    80106ae2 <alltraps>

801073b6 <vector68>:
.globl vector68
vector68:
  pushl $0
801073b6:	6a 00                	push   $0x0
  pushl $68
801073b8:	6a 44                	push   $0x44
  jmp alltraps
801073ba:	e9 23 f7 ff ff       	jmp    80106ae2 <alltraps>

801073bf <vector69>:
.globl vector69
vector69:
  pushl $0
801073bf:	6a 00                	push   $0x0
  pushl $69
801073c1:	6a 45                	push   $0x45
  jmp alltraps
801073c3:	e9 1a f7 ff ff       	jmp    80106ae2 <alltraps>

801073c8 <vector70>:
.globl vector70
vector70:
  pushl $0
801073c8:	6a 00                	push   $0x0
  pushl $70
801073ca:	6a 46                	push   $0x46
  jmp alltraps
801073cc:	e9 11 f7 ff ff       	jmp    80106ae2 <alltraps>

801073d1 <vector71>:
.globl vector71
vector71:
  pushl $0
801073d1:	6a 00                	push   $0x0
  pushl $71
801073d3:	6a 47                	push   $0x47
  jmp alltraps
801073d5:	e9 08 f7 ff ff       	jmp    80106ae2 <alltraps>

801073da <vector72>:
.globl vector72
vector72:
  pushl $0
801073da:	6a 00                	push   $0x0
  pushl $72
801073dc:	6a 48                	push   $0x48
  jmp alltraps
801073de:	e9 ff f6 ff ff       	jmp    80106ae2 <alltraps>

801073e3 <vector73>:
.globl vector73
vector73:
  pushl $0
801073e3:	6a 00                	push   $0x0
  pushl $73
801073e5:	6a 49                	push   $0x49
  jmp alltraps
801073e7:	e9 f6 f6 ff ff       	jmp    80106ae2 <alltraps>

801073ec <vector74>:
.globl vector74
vector74:
  pushl $0
801073ec:	6a 00                	push   $0x0
  pushl $74
801073ee:	6a 4a                	push   $0x4a
  jmp alltraps
801073f0:	e9 ed f6 ff ff       	jmp    80106ae2 <alltraps>

801073f5 <vector75>:
.globl vector75
vector75:
  pushl $0
801073f5:	6a 00                	push   $0x0
  pushl $75
801073f7:	6a 4b                	push   $0x4b
  jmp alltraps
801073f9:	e9 e4 f6 ff ff       	jmp    80106ae2 <alltraps>

801073fe <vector76>:
.globl vector76
vector76:
  pushl $0
801073fe:	6a 00                	push   $0x0
  pushl $76
80107400:	6a 4c                	push   $0x4c
  jmp alltraps
80107402:	e9 db f6 ff ff       	jmp    80106ae2 <alltraps>

80107407 <vector77>:
.globl vector77
vector77:
  pushl $0
80107407:	6a 00                	push   $0x0
  pushl $77
80107409:	6a 4d                	push   $0x4d
  jmp alltraps
8010740b:	e9 d2 f6 ff ff       	jmp    80106ae2 <alltraps>

80107410 <vector78>:
.globl vector78
vector78:
  pushl $0
80107410:	6a 00                	push   $0x0
  pushl $78
80107412:	6a 4e                	push   $0x4e
  jmp alltraps
80107414:	e9 c9 f6 ff ff       	jmp    80106ae2 <alltraps>

80107419 <vector79>:
.globl vector79
vector79:
  pushl $0
80107419:	6a 00                	push   $0x0
  pushl $79
8010741b:	6a 4f                	push   $0x4f
  jmp alltraps
8010741d:	e9 c0 f6 ff ff       	jmp    80106ae2 <alltraps>

80107422 <vector80>:
.globl vector80
vector80:
  pushl $0
80107422:	6a 00                	push   $0x0
  pushl $80
80107424:	6a 50                	push   $0x50
  jmp alltraps
80107426:	e9 b7 f6 ff ff       	jmp    80106ae2 <alltraps>

8010742b <vector81>:
.globl vector81
vector81:
  pushl $0
8010742b:	6a 00                	push   $0x0
  pushl $81
8010742d:	6a 51                	push   $0x51
  jmp alltraps
8010742f:	e9 ae f6 ff ff       	jmp    80106ae2 <alltraps>

80107434 <vector82>:
.globl vector82
vector82:
  pushl $0
80107434:	6a 00                	push   $0x0
  pushl $82
80107436:	6a 52                	push   $0x52
  jmp alltraps
80107438:	e9 a5 f6 ff ff       	jmp    80106ae2 <alltraps>

8010743d <vector83>:
.globl vector83
vector83:
  pushl $0
8010743d:	6a 00                	push   $0x0
  pushl $83
8010743f:	6a 53                	push   $0x53
  jmp alltraps
80107441:	e9 9c f6 ff ff       	jmp    80106ae2 <alltraps>

80107446 <vector84>:
.globl vector84
vector84:
  pushl $0
80107446:	6a 00                	push   $0x0
  pushl $84
80107448:	6a 54                	push   $0x54
  jmp alltraps
8010744a:	e9 93 f6 ff ff       	jmp    80106ae2 <alltraps>

8010744f <vector85>:
.globl vector85
vector85:
  pushl $0
8010744f:	6a 00                	push   $0x0
  pushl $85
80107451:	6a 55                	push   $0x55
  jmp alltraps
80107453:	e9 8a f6 ff ff       	jmp    80106ae2 <alltraps>

80107458 <vector86>:
.globl vector86
vector86:
  pushl $0
80107458:	6a 00                	push   $0x0
  pushl $86
8010745a:	6a 56                	push   $0x56
  jmp alltraps
8010745c:	e9 81 f6 ff ff       	jmp    80106ae2 <alltraps>

80107461 <vector87>:
.globl vector87
vector87:
  pushl $0
80107461:	6a 00                	push   $0x0
  pushl $87
80107463:	6a 57                	push   $0x57
  jmp alltraps
80107465:	e9 78 f6 ff ff       	jmp    80106ae2 <alltraps>

8010746a <vector88>:
.globl vector88
vector88:
  pushl $0
8010746a:	6a 00                	push   $0x0
  pushl $88
8010746c:	6a 58                	push   $0x58
  jmp alltraps
8010746e:	e9 6f f6 ff ff       	jmp    80106ae2 <alltraps>

80107473 <vector89>:
.globl vector89
vector89:
  pushl $0
80107473:	6a 00                	push   $0x0
  pushl $89
80107475:	6a 59                	push   $0x59
  jmp alltraps
80107477:	e9 66 f6 ff ff       	jmp    80106ae2 <alltraps>

8010747c <vector90>:
.globl vector90
vector90:
  pushl $0
8010747c:	6a 00                	push   $0x0
  pushl $90
8010747e:	6a 5a                	push   $0x5a
  jmp alltraps
80107480:	e9 5d f6 ff ff       	jmp    80106ae2 <alltraps>

80107485 <vector91>:
.globl vector91
vector91:
  pushl $0
80107485:	6a 00                	push   $0x0
  pushl $91
80107487:	6a 5b                	push   $0x5b
  jmp alltraps
80107489:	e9 54 f6 ff ff       	jmp    80106ae2 <alltraps>

8010748e <vector92>:
.globl vector92
vector92:
  pushl $0
8010748e:	6a 00                	push   $0x0
  pushl $92
80107490:	6a 5c                	push   $0x5c
  jmp alltraps
80107492:	e9 4b f6 ff ff       	jmp    80106ae2 <alltraps>

80107497 <vector93>:
.globl vector93
vector93:
  pushl $0
80107497:	6a 00                	push   $0x0
  pushl $93
80107499:	6a 5d                	push   $0x5d
  jmp alltraps
8010749b:	e9 42 f6 ff ff       	jmp    80106ae2 <alltraps>

801074a0 <vector94>:
.globl vector94
vector94:
  pushl $0
801074a0:	6a 00                	push   $0x0
  pushl $94
801074a2:	6a 5e                	push   $0x5e
  jmp alltraps
801074a4:	e9 39 f6 ff ff       	jmp    80106ae2 <alltraps>

801074a9 <vector95>:
.globl vector95
vector95:
  pushl $0
801074a9:	6a 00                	push   $0x0
  pushl $95
801074ab:	6a 5f                	push   $0x5f
  jmp alltraps
801074ad:	e9 30 f6 ff ff       	jmp    80106ae2 <alltraps>

801074b2 <vector96>:
.globl vector96
vector96:
  pushl $0
801074b2:	6a 00                	push   $0x0
  pushl $96
801074b4:	6a 60                	push   $0x60
  jmp alltraps
801074b6:	e9 27 f6 ff ff       	jmp    80106ae2 <alltraps>

801074bb <vector97>:
.globl vector97
vector97:
  pushl $0
801074bb:	6a 00                	push   $0x0
  pushl $97
801074bd:	6a 61                	push   $0x61
  jmp alltraps
801074bf:	e9 1e f6 ff ff       	jmp    80106ae2 <alltraps>

801074c4 <vector98>:
.globl vector98
vector98:
  pushl $0
801074c4:	6a 00                	push   $0x0
  pushl $98
801074c6:	6a 62                	push   $0x62
  jmp alltraps
801074c8:	e9 15 f6 ff ff       	jmp    80106ae2 <alltraps>

801074cd <vector99>:
.globl vector99
vector99:
  pushl $0
801074cd:	6a 00                	push   $0x0
  pushl $99
801074cf:	6a 63                	push   $0x63
  jmp alltraps
801074d1:	e9 0c f6 ff ff       	jmp    80106ae2 <alltraps>

801074d6 <vector100>:
.globl vector100
vector100:
  pushl $0
801074d6:	6a 00                	push   $0x0
  pushl $100
801074d8:	6a 64                	push   $0x64
  jmp alltraps
801074da:	e9 03 f6 ff ff       	jmp    80106ae2 <alltraps>

801074df <vector101>:
.globl vector101
vector101:
  pushl $0
801074df:	6a 00                	push   $0x0
  pushl $101
801074e1:	6a 65                	push   $0x65
  jmp alltraps
801074e3:	e9 fa f5 ff ff       	jmp    80106ae2 <alltraps>

801074e8 <vector102>:
.globl vector102
vector102:
  pushl $0
801074e8:	6a 00                	push   $0x0
  pushl $102
801074ea:	6a 66                	push   $0x66
  jmp alltraps
801074ec:	e9 f1 f5 ff ff       	jmp    80106ae2 <alltraps>

801074f1 <vector103>:
.globl vector103
vector103:
  pushl $0
801074f1:	6a 00                	push   $0x0
  pushl $103
801074f3:	6a 67                	push   $0x67
  jmp alltraps
801074f5:	e9 e8 f5 ff ff       	jmp    80106ae2 <alltraps>

801074fa <vector104>:
.globl vector104
vector104:
  pushl $0
801074fa:	6a 00                	push   $0x0
  pushl $104
801074fc:	6a 68                	push   $0x68
  jmp alltraps
801074fe:	e9 df f5 ff ff       	jmp    80106ae2 <alltraps>

80107503 <vector105>:
.globl vector105
vector105:
  pushl $0
80107503:	6a 00                	push   $0x0
  pushl $105
80107505:	6a 69                	push   $0x69
  jmp alltraps
80107507:	e9 d6 f5 ff ff       	jmp    80106ae2 <alltraps>

8010750c <vector106>:
.globl vector106
vector106:
  pushl $0
8010750c:	6a 00                	push   $0x0
  pushl $106
8010750e:	6a 6a                	push   $0x6a
  jmp alltraps
80107510:	e9 cd f5 ff ff       	jmp    80106ae2 <alltraps>

80107515 <vector107>:
.globl vector107
vector107:
  pushl $0
80107515:	6a 00                	push   $0x0
  pushl $107
80107517:	6a 6b                	push   $0x6b
  jmp alltraps
80107519:	e9 c4 f5 ff ff       	jmp    80106ae2 <alltraps>

8010751e <vector108>:
.globl vector108
vector108:
  pushl $0
8010751e:	6a 00                	push   $0x0
  pushl $108
80107520:	6a 6c                	push   $0x6c
  jmp alltraps
80107522:	e9 bb f5 ff ff       	jmp    80106ae2 <alltraps>

80107527 <vector109>:
.globl vector109
vector109:
  pushl $0
80107527:	6a 00                	push   $0x0
  pushl $109
80107529:	6a 6d                	push   $0x6d
  jmp alltraps
8010752b:	e9 b2 f5 ff ff       	jmp    80106ae2 <alltraps>

80107530 <vector110>:
.globl vector110
vector110:
  pushl $0
80107530:	6a 00                	push   $0x0
  pushl $110
80107532:	6a 6e                	push   $0x6e
  jmp alltraps
80107534:	e9 a9 f5 ff ff       	jmp    80106ae2 <alltraps>

80107539 <vector111>:
.globl vector111
vector111:
  pushl $0
80107539:	6a 00                	push   $0x0
  pushl $111
8010753b:	6a 6f                	push   $0x6f
  jmp alltraps
8010753d:	e9 a0 f5 ff ff       	jmp    80106ae2 <alltraps>

80107542 <vector112>:
.globl vector112
vector112:
  pushl $0
80107542:	6a 00                	push   $0x0
  pushl $112
80107544:	6a 70                	push   $0x70
  jmp alltraps
80107546:	e9 97 f5 ff ff       	jmp    80106ae2 <alltraps>

8010754b <vector113>:
.globl vector113
vector113:
  pushl $0
8010754b:	6a 00                	push   $0x0
  pushl $113
8010754d:	6a 71                	push   $0x71
  jmp alltraps
8010754f:	e9 8e f5 ff ff       	jmp    80106ae2 <alltraps>

80107554 <vector114>:
.globl vector114
vector114:
  pushl $0
80107554:	6a 00                	push   $0x0
  pushl $114
80107556:	6a 72                	push   $0x72
  jmp alltraps
80107558:	e9 85 f5 ff ff       	jmp    80106ae2 <alltraps>

8010755d <vector115>:
.globl vector115
vector115:
  pushl $0
8010755d:	6a 00                	push   $0x0
  pushl $115
8010755f:	6a 73                	push   $0x73
  jmp alltraps
80107561:	e9 7c f5 ff ff       	jmp    80106ae2 <alltraps>

80107566 <vector116>:
.globl vector116
vector116:
  pushl $0
80107566:	6a 00                	push   $0x0
  pushl $116
80107568:	6a 74                	push   $0x74
  jmp alltraps
8010756a:	e9 73 f5 ff ff       	jmp    80106ae2 <alltraps>

8010756f <vector117>:
.globl vector117
vector117:
  pushl $0
8010756f:	6a 00                	push   $0x0
  pushl $117
80107571:	6a 75                	push   $0x75
  jmp alltraps
80107573:	e9 6a f5 ff ff       	jmp    80106ae2 <alltraps>

80107578 <vector118>:
.globl vector118
vector118:
  pushl $0
80107578:	6a 00                	push   $0x0
  pushl $118
8010757a:	6a 76                	push   $0x76
  jmp alltraps
8010757c:	e9 61 f5 ff ff       	jmp    80106ae2 <alltraps>

80107581 <vector119>:
.globl vector119
vector119:
  pushl $0
80107581:	6a 00                	push   $0x0
  pushl $119
80107583:	6a 77                	push   $0x77
  jmp alltraps
80107585:	e9 58 f5 ff ff       	jmp    80106ae2 <alltraps>

8010758a <vector120>:
.globl vector120
vector120:
  pushl $0
8010758a:	6a 00                	push   $0x0
  pushl $120
8010758c:	6a 78                	push   $0x78
  jmp alltraps
8010758e:	e9 4f f5 ff ff       	jmp    80106ae2 <alltraps>

80107593 <vector121>:
.globl vector121
vector121:
  pushl $0
80107593:	6a 00                	push   $0x0
  pushl $121
80107595:	6a 79                	push   $0x79
  jmp alltraps
80107597:	e9 46 f5 ff ff       	jmp    80106ae2 <alltraps>

8010759c <vector122>:
.globl vector122
vector122:
  pushl $0
8010759c:	6a 00                	push   $0x0
  pushl $122
8010759e:	6a 7a                	push   $0x7a
  jmp alltraps
801075a0:	e9 3d f5 ff ff       	jmp    80106ae2 <alltraps>

801075a5 <vector123>:
.globl vector123
vector123:
  pushl $0
801075a5:	6a 00                	push   $0x0
  pushl $123
801075a7:	6a 7b                	push   $0x7b
  jmp alltraps
801075a9:	e9 34 f5 ff ff       	jmp    80106ae2 <alltraps>

801075ae <vector124>:
.globl vector124
vector124:
  pushl $0
801075ae:	6a 00                	push   $0x0
  pushl $124
801075b0:	6a 7c                	push   $0x7c
  jmp alltraps
801075b2:	e9 2b f5 ff ff       	jmp    80106ae2 <alltraps>

801075b7 <vector125>:
.globl vector125
vector125:
  pushl $0
801075b7:	6a 00                	push   $0x0
  pushl $125
801075b9:	6a 7d                	push   $0x7d
  jmp alltraps
801075bb:	e9 22 f5 ff ff       	jmp    80106ae2 <alltraps>

801075c0 <vector126>:
.globl vector126
vector126:
  pushl $0
801075c0:	6a 00                	push   $0x0
  pushl $126
801075c2:	6a 7e                	push   $0x7e
  jmp alltraps
801075c4:	e9 19 f5 ff ff       	jmp    80106ae2 <alltraps>

801075c9 <vector127>:
.globl vector127
vector127:
  pushl $0
801075c9:	6a 00                	push   $0x0
  pushl $127
801075cb:	6a 7f                	push   $0x7f
  jmp alltraps
801075cd:	e9 10 f5 ff ff       	jmp    80106ae2 <alltraps>

801075d2 <vector128>:
.globl vector128
vector128:
  pushl $0
801075d2:	6a 00                	push   $0x0
  pushl $128
801075d4:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801075d9:	e9 04 f5 ff ff       	jmp    80106ae2 <alltraps>

801075de <vector129>:
.globl vector129
vector129:
  pushl $0
801075de:	6a 00                	push   $0x0
  pushl $129
801075e0:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801075e5:	e9 f8 f4 ff ff       	jmp    80106ae2 <alltraps>

801075ea <vector130>:
.globl vector130
vector130:
  pushl $0
801075ea:	6a 00                	push   $0x0
  pushl $130
801075ec:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801075f1:	e9 ec f4 ff ff       	jmp    80106ae2 <alltraps>

801075f6 <vector131>:
.globl vector131
vector131:
  pushl $0
801075f6:	6a 00                	push   $0x0
  pushl $131
801075f8:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801075fd:	e9 e0 f4 ff ff       	jmp    80106ae2 <alltraps>

80107602 <vector132>:
.globl vector132
vector132:
  pushl $0
80107602:	6a 00                	push   $0x0
  pushl $132
80107604:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107609:	e9 d4 f4 ff ff       	jmp    80106ae2 <alltraps>

8010760e <vector133>:
.globl vector133
vector133:
  pushl $0
8010760e:	6a 00                	push   $0x0
  pushl $133
80107610:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107615:	e9 c8 f4 ff ff       	jmp    80106ae2 <alltraps>

8010761a <vector134>:
.globl vector134
vector134:
  pushl $0
8010761a:	6a 00                	push   $0x0
  pushl $134
8010761c:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107621:	e9 bc f4 ff ff       	jmp    80106ae2 <alltraps>

80107626 <vector135>:
.globl vector135
vector135:
  pushl $0
80107626:	6a 00                	push   $0x0
  pushl $135
80107628:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010762d:	e9 b0 f4 ff ff       	jmp    80106ae2 <alltraps>

80107632 <vector136>:
.globl vector136
vector136:
  pushl $0
80107632:	6a 00                	push   $0x0
  pushl $136
80107634:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107639:	e9 a4 f4 ff ff       	jmp    80106ae2 <alltraps>

8010763e <vector137>:
.globl vector137
vector137:
  pushl $0
8010763e:	6a 00                	push   $0x0
  pushl $137
80107640:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107645:	e9 98 f4 ff ff       	jmp    80106ae2 <alltraps>

8010764a <vector138>:
.globl vector138
vector138:
  pushl $0
8010764a:	6a 00                	push   $0x0
  pushl $138
8010764c:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107651:	e9 8c f4 ff ff       	jmp    80106ae2 <alltraps>

80107656 <vector139>:
.globl vector139
vector139:
  pushl $0
80107656:	6a 00                	push   $0x0
  pushl $139
80107658:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010765d:	e9 80 f4 ff ff       	jmp    80106ae2 <alltraps>

80107662 <vector140>:
.globl vector140
vector140:
  pushl $0
80107662:	6a 00                	push   $0x0
  pushl $140
80107664:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107669:	e9 74 f4 ff ff       	jmp    80106ae2 <alltraps>

8010766e <vector141>:
.globl vector141
vector141:
  pushl $0
8010766e:	6a 00                	push   $0x0
  pushl $141
80107670:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107675:	e9 68 f4 ff ff       	jmp    80106ae2 <alltraps>

8010767a <vector142>:
.globl vector142
vector142:
  pushl $0
8010767a:	6a 00                	push   $0x0
  pushl $142
8010767c:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107681:	e9 5c f4 ff ff       	jmp    80106ae2 <alltraps>

80107686 <vector143>:
.globl vector143
vector143:
  pushl $0
80107686:	6a 00                	push   $0x0
  pushl $143
80107688:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010768d:	e9 50 f4 ff ff       	jmp    80106ae2 <alltraps>

80107692 <vector144>:
.globl vector144
vector144:
  pushl $0
80107692:	6a 00                	push   $0x0
  pushl $144
80107694:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107699:	e9 44 f4 ff ff       	jmp    80106ae2 <alltraps>

8010769e <vector145>:
.globl vector145
vector145:
  pushl $0
8010769e:	6a 00                	push   $0x0
  pushl $145
801076a0:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801076a5:	e9 38 f4 ff ff       	jmp    80106ae2 <alltraps>

801076aa <vector146>:
.globl vector146
vector146:
  pushl $0
801076aa:	6a 00                	push   $0x0
  pushl $146
801076ac:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801076b1:	e9 2c f4 ff ff       	jmp    80106ae2 <alltraps>

801076b6 <vector147>:
.globl vector147
vector147:
  pushl $0
801076b6:	6a 00                	push   $0x0
  pushl $147
801076b8:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801076bd:	e9 20 f4 ff ff       	jmp    80106ae2 <alltraps>

801076c2 <vector148>:
.globl vector148
vector148:
  pushl $0
801076c2:	6a 00                	push   $0x0
  pushl $148
801076c4:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801076c9:	e9 14 f4 ff ff       	jmp    80106ae2 <alltraps>

801076ce <vector149>:
.globl vector149
vector149:
  pushl $0
801076ce:	6a 00                	push   $0x0
  pushl $149
801076d0:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801076d5:	e9 08 f4 ff ff       	jmp    80106ae2 <alltraps>

801076da <vector150>:
.globl vector150
vector150:
  pushl $0
801076da:	6a 00                	push   $0x0
  pushl $150
801076dc:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801076e1:	e9 fc f3 ff ff       	jmp    80106ae2 <alltraps>

801076e6 <vector151>:
.globl vector151
vector151:
  pushl $0
801076e6:	6a 00                	push   $0x0
  pushl $151
801076e8:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801076ed:	e9 f0 f3 ff ff       	jmp    80106ae2 <alltraps>

801076f2 <vector152>:
.globl vector152
vector152:
  pushl $0
801076f2:	6a 00                	push   $0x0
  pushl $152
801076f4:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801076f9:	e9 e4 f3 ff ff       	jmp    80106ae2 <alltraps>

801076fe <vector153>:
.globl vector153
vector153:
  pushl $0
801076fe:	6a 00                	push   $0x0
  pushl $153
80107700:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107705:	e9 d8 f3 ff ff       	jmp    80106ae2 <alltraps>

8010770a <vector154>:
.globl vector154
vector154:
  pushl $0
8010770a:	6a 00                	push   $0x0
  pushl $154
8010770c:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107711:	e9 cc f3 ff ff       	jmp    80106ae2 <alltraps>

80107716 <vector155>:
.globl vector155
vector155:
  pushl $0
80107716:	6a 00                	push   $0x0
  pushl $155
80107718:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010771d:	e9 c0 f3 ff ff       	jmp    80106ae2 <alltraps>

80107722 <vector156>:
.globl vector156
vector156:
  pushl $0
80107722:	6a 00                	push   $0x0
  pushl $156
80107724:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107729:	e9 b4 f3 ff ff       	jmp    80106ae2 <alltraps>

8010772e <vector157>:
.globl vector157
vector157:
  pushl $0
8010772e:	6a 00                	push   $0x0
  pushl $157
80107730:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107735:	e9 a8 f3 ff ff       	jmp    80106ae2 <alltraps>

8010773a <vector158>:
.globl vector158
vector158:
  pushl $0
8010773a:	6a 00                	push   $0x0
  pushl $158
8010773c:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107741:	e9 9c f3 ff ff       	jmp    80106ae2 <alltraps>

80107746 <vector159>:
.globl vector159
vector159:
  pushl $0
80107746:	6a 00                	push   $0x0
  pushl $159
80107748:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010774d:	e9 90 f3 ff ff       	jmp    80106ae2 <alltraps>

80107752 <vector160>:
.globl vector160
vector160:
  pushl $0
80107752:	6a 00                	push   $0x0
  pushl $160
80107754:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107759:	e9 84 f3 ff ff       	jmp    80106ae2 <alltraps>

8010775e <vector161>:
.globl vector161
vector161:
  pushl $0
8010775e:	6a 00                	push   $0x0
  pushl $161
80107760:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107765:	e9 78 f3 ff ff       	jmp    80106ae2 <alltraps>

8010776a <vector162>:
.globl vector162
vector162:
  pushl $0
8010776a:	6a 00                	push   $0x0
  pushl $162
8010776c:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107771:	e9 6c f3 ff ff       	jmp    80106ae2 <alltraps>

80107776 <vector163>:
.globl vector163
vector163:
  pushl $0
80107776:	6a 00                	push   $0x0
  pushl $163
80107778:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010777d:	e9 60 f3 ff ff       	jmp    80106ae2 <alltraps>

80107782 <vector164>:
.globl vector164
vector164:
  pushl $0
80107782:	6a 00                	push   $0x0
  pushl $164
80107784:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107789:	e9 54 f3 ff ff       	jmp    80106ae2 <alltraps>

8010778e <vector165>:
.globl vector165
vector165:
  pushl $0
8010778e:	6a 00                	push   $0x0
  pushl $165
80107790:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107795:	e9 48 f3 ff ff       	jmp    80106ae2 <alltraps>

8010779a <vector166>:
.globl vector166
vector166:
  pushl $0
8010779a:	6a 00                	push   $0x0
  pushl $166
8010779c:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801077a1:	e9 3c f3 ff ff       	jmp    80106ae2 <alltraps>

801077a6 <vector167>:
.globl vector167
vector167:
  pushl $0
801077a6:	6a 00                	push   $0x0
  pushl $167
801077a8:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801077ad:	e9 30 f3 ff ff       	jmp    80106ae2 <alltraps>

801077b2 <vector168>:
.globl vector168
vector168:
  pushl $0
801077b2:	6a 00                	push   $0x0
  pushl $168
801077b4:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801077b9:	e9 24 f3 ff ff       	jmp    80106ae2 <alltraps>

801077be <vector169>:
.globl vector169
vector169:
  pushl $0
801077be:	6a 00                	push   $0x0
  pushl $169
801077c0:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801077c5:	e9 18 f3 ff ff       	jmp    80106ae2 <alltraps>

801077ca <vector170>:
.globl vector170
vector170:
  pushl $0
801077ca:	6a 00                	push   $0x0
  pushl $170
801077cc:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801077d1:	e9 0c f3 ff ff       	jmp    80106ae2 <alltraps>

801077d6 <vector171>:
.globl vector171
vector171:
  pushl $0
801077d6:	6a 00                	push   $0x0
  pushl $171
801077d8:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801077dd:	e9 00 f3 ff ff       	jmp    80106ae2 <alltraps>

801077e2 <vector172>:
.globl vector172
vector172:
  pushl $0
801077e2:	6a 00                	push   $0x0
  pushl $172
801077e4:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801077e9:	e9 f4 f2 ff ff       	jmp    80106ae2 <alltraps>

801077ee <vector173>:
.globl vector173
vector173:
  pushl $0
801077ee:	6a 00                	push   $0x0
  pushl $173
801077f0:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801077f5:	e9 e8 f2 ff ff       	jmp    80106ae2 <alltraps>

801077fa <vector174>:
.globl vector174
vector174:
  pushl $0
801077fa:	6a 00                	push   $0x0
  pushl $174
801077fc:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107801:	e9 dc f2 ff ff       	jmp    80106ae2 <alltraps>

80107806 <vector175>:
.globl vector175
vector175:
  pushl $0
80107806:	6a 00                	push   $0x0
  pushl $175
80107808:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010780d:	e9 d0 f2 ff ff       	jmp    80106ae2 <alltraps>

80107812 <vector176>:
.globl vector176
vector176:
  pushl $0
80107812:	6a 00                	push   $0x0
  pushl $176
80107814:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107819:	e9 c4 f2 ff ff       	jmp    80106ae2 <alltraps>

8010781e <vector177>:
.globl vector177
vector177:
  pushl $0
8010781e:	6a 00                	push   $0x0
  pushl $177
80107820:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107825:	e9 b8 f2 ff ff       	jmp    80106ae2 <alltraps>

8010782a <vector178>:
.globl vector178
vector178:
  pushl $0
8010782a:	6a 00                	push   $0x0
  pushl $178
8010782c:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107831:	e9 ac f2 ff ff       	jmp    80106ae2 <alltraps>

80107836 <vector179>:
.globl vector179
vector179:
  pushl $0
80107836:	6a 00                	push   $0x0
  pushl $179
80107838:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010783d:	e9 a0 f2 ff ff       	jmp    80106ae2 <alltraps>

80107842 <vector180>:
.globl vector180
vector180:
  pushl $0
80107842:	6a 00                	push   $0x0
  pushl $180
80107844:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107849:	e9 94 f2 ff ff       	jmp    80106ae2 <alltraps>

8010784e <vector181>:
.globl vector181
vector181:
  pushl $0
8010784e:	6a 00                	push   $0x0
  pushl $181
80107850:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107855:	e9 88 f2 ff ff       	jmp    80106ae2 <alltraps>

8010785a <vector182>:
.globl vector182
vector182:
  pushl $0
8010785a:	6a 00                	push   $0x0
  pushl $182
8010785c:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107861:	e9 7c f2 ff ff       	jmp    80106ae2 <alltraps>

80107866 <vector183>:
.globl vector183
vector183:
  pushl $0
80107866:	6a 00                	push   $0x0
  pushl $183
80107868:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010786d:	e9 70 f2 ff ff       	jmp    80106ae2 <alltraps>

80107872 <vector184>:
.globl vector184
vector184:
  pushl $0
80107872:	6a 00                	push   $0x0
  pushl $184
80107874:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107879:	e9 64 f2 ff ff       	jmp    80106ae2 <alltraps>

8010787e <vector185>:
.globl vector185
vector185:
  pushl $0
8010787e:	6a 00                	push   $0x0
  pushl $185
80107880:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107885:	e9 58 f2 ff ff       	jmp    80106ae2 <alltraps>

8010788a <vector186>:
.globl vector186
vector186:
  pushl $0
8010788a:	6a 00                	push   $0x0
  pushl $186
8010788c:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107891:	e9 4c f2 ff ff       	jmp    80106ae2 <alltraps>

80107896 <vector187>:
.globl vector187
vector187:
  pushl $0
80107896:	6a 00                	push   $0x0
  pushl $187
80107898:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010789d:	e9 40 f2 ff ff       	jmp    80106ae2 <alltraps>

801078a2 <vector188>:
.globl vector188
vector188:
  pushl $0
801078a2:	6a 00                	push   $0x0
  pushl $188
801078a4:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801078a9:	e9 34 f2 ff ff       	jmp    80106ae2 <alltraps>

801078ae <vector189>:
.globl vector189
vector189:
  pushl $0
801078ae:	6a 00                	push   $0x0
  pushl $189
801078b0:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801078b5:	e9 28 f2 ff ff       	jmp    80106ae2 <alltraps>

801078ba <vector190>:
.globl vector190
vector190:
  pushl $0
801078ba:	6a 00                	push   $0x0
  pushl $190
801078bc:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801078c1:	e9 1c f2 ff ff       	jmp    80106ae2 <alltraps>

801078c6 <vector191>:
.globl vector191
vector191:
  pushl $0
801078c6:	6a 00                	push   $0x0
  pushl $191
801078c8:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801078cd:	e9 10 f2 ff ff       	jmp    80106ae2 <alltraps>

801078d2 <vector192>:
.globl vector192
vector192:
  pushl $0
801078d2:	6a 00                	push   $0x0
  pushl $192
801078d4:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801078d9:	e9 04 f2 ff ff       	jmp    80106ae2 <alltraps>

801078de <vector193>:
.globl vector193
vector193:
  pushl $0
801078de:	6a 00                	push   $0x0
  pushl $193
801078e0:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801078e5:	e9 f8 f1 ff ff       	jmp    80106ae2 <alltraps>

801078ea <vector194>:
.globl vector194
vector194:
  pushl $0
801078ea:	6a 00                	push   $0x0
  pushl $194
801078ec:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801078f1:	e9 ec f1 ff ff       	jmp    80106ae2 <alltraps>

801078f6 <vector195>:
.globl vector195
vector195:
  pushl $0
801078f6:	6a 00                	push   $0x0
  pushl $195
801078f8:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801078fd:	e9 e0 f1 ff ff       	jmp    80106ae2 <alltraps>

80107902 <vector196>:
.globl vector196
vector196:
  pushl $0
80107902:	6a 00                	push   $0x0
  pushl $196
80107904:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107909:	e9 d4 f1 ff ff       	jmp    80106ae2 <alltraps>

8010790e <vector197>:
.globl vector197
vector197:
  pushl $0
8010790e:	6a 00                	push   $0x0
  pushl $197
80107910:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107915:	e9 c8 f1 ff ff       	jmp    80106ae2 <alltraps>

8010791a <vector198>:
.globl vector198
vector198:
  pushl $0
8010791a:	6a 00                	push   $0x0
  pushl $198
8010791c:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107921:	e9 bc f1 ff ff       	jmp    80106ae2 <alltraps>

80107926 <vector199>:
.globl vector199
vector199:
  pushl $0
80107926:	6a 00                	push   $0x0
  pushl $199
80107928:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010792d:	e9 b0 f1 ff ff       	jmp    80106ae2 <alltraps>

80107932 <vector200>:
.globl vector200
vector200:
  pushl $0
80107932:	6a 00                	push   $0x0
  pushl $200
80107934:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107939:	e9 a4 f1 ff ff       	jmp    80106ae2 <alltraps>

8010793e <vector201>:
.globl vector201
vector201:
  pushl $0
8010793e:	6a 00                	push   $0x0
  pushl $201
80107940:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107945:	e9 98 f1 ff ff       	jmp    80106ae2 <alltraps>

8010794a <vector202>:
.globl vector202
vector202:
  pushl $0
8010794a:	6a 00                	push   $0x0
  pushl $202
8010794c:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107951:	e9 8c f1 ff ff       	jmp    80106ae2 <alltraps>

80107956 <vector203>:
.globl vector203
vector203:
  pushl $0
80107956:	6a 00                	push   $0x0
  pushl $203
80107958:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010795d:	e9 80 f1 ff ff       	jmp    80106ae2 <alltraps>

80107962 <vector204>:
.globl vector204
vector204:
  pushl $0
80107962:	6a 00                	push   $0x0
  pushl $204
80107964:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107969:	e9 74 f1 ff ff       	jmp    80106ae2 <alltraps>

8010796e <vector205>:
.globl vector205
vector205:
  pushl $0
8010796e:	6a 00                	push   $0x0
  pushl $205
80107970:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107975:	e9 68 f1 ff ff       	jmp    80106ae2 <alltraps>

8010797a <vector206>:
.globl vector206
vector206:
  pushl $0
8010797a:	6a 00                	push   $0x0
  pushl $206
8010797c:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107981:	e9 5c f1 ff ff       	jmp    80106ae2 <alltraps>

80107986 <vector207>:
.globl vector207
vector207:
  pushl $0
80107986:	6a 00                	push   $0x0
  pushl $207
80107988:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010798d:	e9 50 f1 ff ff       	jmp    80106ae2 <alltraps>

80107992 <vector208>:
.globl vector208
vector208:
  pushl $0
80107992:	6a 00                	push   $0x0
  pushl $208
80107994:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107999:	e9 44 f1 ff ff       	jmp    80106ae2 <alltraps>

8010799e <vector209>:
.globl vector209
vector209:
  pushl $0
8010799e:	6a 00                	push   $0x0
  pushl $209
801079a0:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801079a5:	e9 38 f1 ff ff       	jmp    80106ae2 <alltraps>

801079aa <vector210>:
.globl vector210
vector210:
  pushl $0
801079aa:	6a 00                	push   $0x0
  pushl $210
801079ac:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801079b1:	e9 2c f1 ff ff       	jmp    80106ae2 <alltraps>

801079b6 <vector211>:
.globl vector211
vector211:
  pushl $0
801079b6:	6a 00                	push   $0x0
  pushl $211
801079b8:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801079bd:	e9 20 f1 ff ff       	jmp    80106ae2 <alltraps>

801079c2 <vector212>:
.globl vector212
vector212:
  pushl $0
801079c2:	6a 00                	push   $0x0
  pushl $212
801079c4:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801079c9:	e9 14 f1 ff ff       	jmp    80106ae2 <alltraps>

801079ce <vector213>:
.globl vector213
vector213:
  pushl $0
801079ce:	6a 00                	push   $0x0
  pushl $213
801079d0:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801079d5:	e9 08 f1 ff ff       	jmp    80106ae2 <alltraps>

801079da <vector214>:
.globl vector214
vector214:
  pushl $0
801079da:	6a 00                	push   $0x0
  pushl $214
801079dc:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801079e1:	e9 fc f0 ff ff       	jmp    80106ae2 <alltraps>

801079e6 <vector215>:
.globl vector215
vector215:
  pushl $0
801079e6:	6a 00                	push   $0x0
  pushl $215
801079e8:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801079ed:	e9 f0 f0 ff ff       	jmp    80106ae2 <alltraps>

801079f2 <vector216>:
.globl vector216
vector216:
  pushl $0
801079f2:	6a 00                	push   $0x0
  pushl $216
801079f4:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801079f9:	e9 e4 f0 ff ff       	jmp    80106ae2 <alltraps>

801079fe <vector217>:
.globl vector217
vector217:
  pushl $0
801079fe:	6a 00                	push   $0x0
  pushl $217
80107a00:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107a05:	e9 d8 f0 ff ff       	jmp    80106ae2 <alltraps>

80107a0a <vector218>:
.globl vector218
vector218:
  pushl $0
80107a0a:	6a 00                	push   $0x0
  pushl $218
80107a0c:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107a11:	e9 cc f0 ff ff       	jmp    80106ae2 <alltraps>

80107a16 <vector219>:
.globl vector219
vector219:
  pushl $0
80107a16:	6a 00                	push   $0x0
  pushl $219
80107a18:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107a1d:	e9 c0 f0 ff ff       	jmp    80106ae2 <alltraps>

80107a22 <vector220>:
.globl vector220
vector220:
  pushl $0
80107a22:	6a 00                	push   $0x0
  pushl $220
80107a24:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107a29:	e9 b4 f0 ff ff       	jmp    80106ae2 <alltraps>

80107a2e <vector221>:
.globl vector221
vector221:
  pushl $0
80107a2e:	6a 00                	push   $0x0
  pushl $221
80107a30:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107a35:	e9 a8 f0 ff ff       	jmp    80106ae2 <alltraps>

80107a3a <vector222>:
.globl vector222
vector222:
  pushl $0
80107a3a:	6a 00                	push   $0x0
  pushl $222
80107a3c:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107a41:	e9 9c f0 ff ff       	jmp    80106ae2 <alltraps>

80107a46 <vector223>:
.globl vector223
vector223:
  pushl $0
80107a46:	6a 00                	push   $0x0
  pushl $223
80107a48:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107a4d:	e9 90 f0 ff ff       	jmp    80106ae2 <alltraps>

80107a52 <vector224>:
.globl vector224
vector224:
  pushl $0
80107a52:	6a 00                	push   $0x0
  pushl $224
80107a54:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107a59:	e9 84 f0 ff ff       	jmp    80106ae2 <alltraps>

80107a5e <vector225>:
.globl vector225
vector225:
  pushl $0
80107a5e:	6a 00                	push   $0x0
  pushl $225
80107a60:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107a65:	e9 78 f0 ff ff       	jmp    80106ae2 <alltraps>

80107a6a <vector226>:
.globl vector226
vector226:
  pushl $0
80107a6a:	6a 00                	push   $0x0
  pushl $226
80107a6c:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107a71:	e9 6c f0 ff ff       	jmp    80106ae2 <alltraps>

80107a76 <vector227>:
.globl vector227
vector227:
  pushl $0
80107a76:	6a 00                	push   $0x0
  pushl $227
80107a78:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107a7d:	e9 60 f0 ff ff       	jmp    80106ae2 <alltraps>

80107a82 <vector228>:
.globl vector228
vector228:
  pushl $0
80107a82:	6a 00                	push   $0x0
  pushl $228
80107a84:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107a89:	e9 54 f0 ff ff       	jmp    80106ae2 <alltraps>

80107a8e <vector229>:
.globl vector229
vector229:
  pushl $0
80107a8e:	6a 00                	push   $0x0
  pushl $229
80107a90:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107a95:	e9 48 f0 ff ff       	jmp    80106ae2 <alltraps>

80107a9a <vector230>:
.globl vector230
vector230:
  pushl $0
80107a9a:	6a 00                	push   $0x0
  pushl $230
80107a9c:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107aa1:	e9 3c f0 ff ff       	jmp    80106ae2 <alltraps>

80107aa6 <vector231>:
.globl vector231
vector231:
  pushl $0
80107aa6:	6a 00                	push   $0x0
  pushl $231
80107aa8:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107aad:	e9 30 f0 ff ff       	jmp    80106ae2 <alltraps>

80107ab2 <vector232>:
.globl vector232
vector232:
  pushl $0
80107ab2:	6a 00                	push   $0x0
  pushl $232
80107ab4:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107ab9:	e9 24 f0 ff ff       	jmp    80106ae2 <alltraps>

80107abe <vector233>:
.globl vector233
vector233:
  pushl $0
80107abe:	6a 00                	push   $0x0
  pushl $233
80107ac0:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107ac5:	e9 18 f0 ff ff       	jmp    80106ae2 <alltraps>

80107aca <vector234>:
.globl vector234
vector234:
  pushl $0
80107aca:	6a 00                	push   $0x0
  pushl $234
80107acc:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107ad1:	e9 0c f0 ff ff       	jmp    80106ae2 <alltraps>

80107ad6 <vector235>:
.globl vector235
vector235:
  pushl $0
80107ad6:	6a 00                	push   $0x0
  pushl $235
80107ad8:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107add:	e9 00 f0 ff ff       	jmp    80106ae2 <alltraps>

80107ae2 <vector236>:
.globl vector236
vector236:
  pushl $0
80107ae2:	6a 00                	push   $0x0
  pushl $236
80107ae4:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107ae9:	e9 f4 ef ff ff       	jmp    80106ae2 <alltraps>

80107aee <vector237>:
.globl vector237
vector237:
  pushl $0
80107aee:	6a 00                	push   $0x0
  pushl $237
80107af0:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107af5:	e9 e8 ef ff ff       	jmp    80106ae2 <alltraps>

80107afa <vector238>:
.globl vector238
vector238:
  pushl $0
80107afa:	6a 00                	push   $0x0
  pushl $238
80107afc:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107b01:	e9 dc ef ff ff       	jmp    80106ae2 <alltraps>

80107b06 <vector239>:
.globl vector239
vector239:
  pushl $0
80107b06:	6a 00                	push   $0x0
  pushl $239
80107b08:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107b0d:	e9 d0 ef ff ff       	jmp    80106ae2 <alltraps>

80107b12 <vector240>:
.globl vector240
vector240:
  pushl $0
80107b12:	6a 00                	push   $0x0
  pushl $240
80107b14:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107b19:	e9 c4 ef ff ff       	jmp    80106ae2 <alltraps>

80107b1e <vector241>:
.globl vector241
vector241:
  pushl $0
80107b1e:	6a 00                	push   $0x0
  pushl $241
80107b20:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107b25:	e9 b8 ef ff ff       	jmp    80106ae2 <alltraps>

80107b2a <vector242>:
.globl vector242
vector242:
  pushl $0
80107b2a:	6a 00                	push   $0x0
  pushl $242
80107b2c:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107b31:	e9 ac ef ff ff       	jmp    80106ae2 <alltraps>

80107b36 <vector243>:
.globl vector243
vector243:
  pushl $0
80107b36:	6a 00                	push   $0x0
  pushl $243
80107b38:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107b3d:	e9 a0 ef ff ff       	jmp    80106ae2 <alltraps>

80107b42 <vector244>:
.globl vector244
vector244:
  pushl $0
80107b42:	6a 00                	push   $0x0
  pushl $244
80107b44:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107b49:	e9 94 ef ff ff       	jmp    80106ae2 <alltraps>

80107b4e <vector245>:
.globl vector245
vector245:
  pushl $0
80107b4e:	6a 00                	push   $0x0
  pushl $245
80107b50:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107b55:	e9 88 ef ff ff       	jmp    80106ae2 <alltraps>

80107b5a <vector246>:
.globl vector246
vector246:
  pushl $0
80107b5a:	6a 00                	push   $0x0
  pushl $246
80107b5c:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107b61:	e9 7c ef ff ff       	jmp    80106ae2 <alltraps>

80107b66 <vector247>:
.globl vector247
vector247:
  pushl $0
80107b66:	6a 00                	push   $0x0
  pushl $247
80107b68:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107b6d:	e9 70 ef ff ff       	jmp    80106ae2 <alltraps>

80107b72 <vector248>:
.globl vector248
vector248:
  pushl $0
80107b72:	6a 00                	push   $0x0
  pushl $248
80107b74:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107b79:	e9 64 ef ff ff       	jmp    80106ae2 <alltraps>

80107b7e <vector249>:
.globl vector249
vector249:
  pushl $0
80107b7e:	6a 00                	push   $0x0
  pushl $249
80107b80:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107b85:	e9 58 ef ff ff       	jmp    80106ae2 <alltraps>

80107b8a <vector250>:
.globl vector250
vector250:
  pushl $0
80107b8a:	6a 00                	push   $0x0
  pushl $250
80107b8c:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107b91:	e9 4c ef ff ff       	jmp    80106ae2 <alltraps>

80107b96 <vector251>:
.globl vector251
vector251:
  pushl $0
80107b96:	6a 00                	push   $0x0
  pushl $251
80107b98:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107b9d:	e9 40 ef ff ff       	jmp    80106ae2 <alltraps>

80107ba2 <vector252>:
.globl vector252
vector252:
  pushl $0
80107ba2:	6a 00                	push   $0x0
  pushl $252
80107ba4:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107ba9:	e9 34 ef ff ff       	jmp    80106ae2 <alltraps>

80107bae <vector253>:
.globl vector253
vector253:
  pushl $0
80107bae:	6a 00                	push   $0x0
  pushl $253
80107bb0:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107bb5:	e9 28 ef ff ff       	jmp    80106ae2 <alltraps>

80107bba <vector254>:
.globl vector254
vector254:
  pushl $0
80107bba:	6a 00                	push   $0x0
  pushl $254
80107bbc:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107bc1:	e9 1c ef ff ff       	jmp    80106ae2 <alltraps>

80107bc6 <vector255>:
.globl vector255
vector255:
  pushl $0
80107bc6:	6a 00                	push   $0x0
  pushl $255
80107bc8:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107bcd:	e9 10 ef ff ff       	jmp    80106ae2 <alltraps>

80107bd2 <lgdt>:
{
80107bd2:	55                   	push   %ebp
80107bd3:	89 e5                	mov    %esp,%ebp
80107bd5:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107bd8:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bdb:	83 e8 01             	sub    $0x1,%eax
80107bde:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107be2:	8b 45 08             	mov    0x8(%ebp),%eax
80107be5:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107be9:	8b 45 08             	mov    0x8(%ebp),%eax
80107bec:	c1 e8 10             	shr    $0x10,%eax
80107bef:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107bf3:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107bf6:	0f 01 10             	lgdtl  (%eax)
}
80107bf9:	90                   	nop
80107bfa:	c9                   	leave  
80107bfb:	c3                   	ret    

80107bfc <ltr>:
{
80107bfc:	55                   	push   %ebp
80107bfd:	89 e5                	mov    %esp,%ebp
80107bff:	83 ec 04             	sub    $0x4,%esp
80107c02:	8b 45 08             	mov    0x8(%ebp),%eax
80107c05:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107c09:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107c0d:	0f 00 d8             	ltr    %ax
}
80107c10:	90                   	nop
80107c11:	c9                   	leave  
80107c12:	c3                   	ret    

80107c13 <lcr3>:

static inline void
lcr3(uint val)
{
80107c13:	55                   	push   %ebp
80107c14:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107c16:	8b 45 08             	mov    0x8(%ebp),%eax
80107c19:	0f 22 d8             	mov    %eax,%cr3
}
80107c1c:	90                   	nop
80107c1d:	5d                   	pop    %ebp
80107c1e:	c3                   	ret    

80107c1f <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107c1f:	f3 0f 1e fb          	endbr32 
80107c23:	55                   	push   %ebp
80107c24:	89 e5                	mov    %esp,%ebp
80107c26:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107c29:	e8 30 c8 ff ff       	call   8010445e <cpuid>
80107c2e:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107c34:	05 20 58 11 80       	add    $0x80115820,%eax
80107c39:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3f:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c48:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107c4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c51:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c58:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c5c:	83 e2 f0             	and    $0xfffffff0,%edx
80107c5f:	83 ca 0a             	or     $0xa,%edx
80107c62:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c68:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c6c:	83 ca 10             	or     $0x10,%edx
80107c6f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c75:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c79:	83 e2 9f             	and    $0xffffff9f,%edx
80107c7c:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c82:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c86:	83 ca 80             	or     $0xffffff80,%edx
80107c89:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c8f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c93:	83 ca 0f             	or     $0xf,%edx
80107c96:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ca0:	83 e2 ef             	and    $0xffffffef,%edx
80107ca3:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca9:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107cad:	83 e2 df             	and    $0xffffffdf,%edx
80107cb0:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb6:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107cba:	83 ca 40             	or     $0x40,%edx
80107cbd:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc3:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107cc7:	83 ca 80             	or     $0xffffff80,%edx
80107cca:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd0:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107cd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd7:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107cde:	ff ff 
80107ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce3:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107cea:	00 00 
80107cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cef:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107cf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf9:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d00:	83 e2 f0             	and    $0xfffffff0,%edx
80107d03:	83 ca 02             	or     $0x2,%edx
80107d06:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d0f:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d16:	83 ca 10             	or     $0x10,%edx
80107d19:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d22:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d29:	83 e2 9f             	and    $0xffffff9f,%edx
80107d2c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d35:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d3c:	83 ca 80             	or     $0xffffff80,%edx
80107d3f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d48:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d4f:	83 ca 0f             	or     $0xf,%edx
80107d52:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d5b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d62:	83 e2 ef             	and    $0xffffffef,%edx
80107d65:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d75:	83 e2 df             	and    $0xffffffdf,%edx
80107d78:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d81:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d88:	83 ca 40             	or     $0x40,%edx
80107d8b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d94:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d9b:	83 ca 80             	or     $0xffffff80,%edx
80107d9e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da7:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107dae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db1:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107db8:	ff ff 
80107dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dbd:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107dc4:	00 00 
80107dc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc9:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107dd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd3:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107dda:	83 e2 f0             	and    $0xfffffff0,%edx
80107ddd:	83 ca 0a             	or     $0xa,%edx
80107de0:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de9:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107df0:	83 ca 10             	or     $0x10,%edx
80107df3:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107df9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dfc:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107e03:	83 ca 60             	or     $0x60,%edx
80107e06:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e0f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107e16:	83 ca 80             	or     $0xffffff80,%edx
80107e19:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e22:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e29:	83 ca 0f             	or     $0xf,%edx
80107e2c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e35:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e3c:	83 e2 ef             	and    $0xffffffef,%edx
80107e3f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e48:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e4f:	83 e2 df             	and    $0xffffffdf,%edx
80107e52:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e62:	83 ca 40             	or     $0x40,%edx
80107e65:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e6e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e75:	83 ca 80             	or     $0xffffff80,%edx
80107e78:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e81:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107e88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e8b:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107e92:	ff ff 
80107e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e97:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107e9e:	00 00 
80107ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea3:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107eaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ead:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107eb4:	83 e2 f0             	and    $0xfffffff0,%edx
80107eb7:	83 ca 02             	or     $0x2,%edx
80107eba:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ec0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec3:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107eca:	83 ca 10             	or     $0x10,%edx
80107ecd:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ed3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed6:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107edd:	83 ca 60             	or     $0x60,%edx
80107ee0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ee6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee9:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ef0:	83 ca 80             	or     $0xffffff80,%edx
80107ef3:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107efc:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f03:	83 ca 0f             	or     $0xf,%edx
80107f06:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f0f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f16:	83 e2 ef             	and    $0xffffffef,%edx
80107f19:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f22:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f29:	83 e2 df             	and    $0xffffffdf,%edx
80107f2c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f35:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f3c:	83 ca 40             	or     $0x40,%edx
80107f3f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f48:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107f4f:	83 ca 80             	or     $0xffffff80,%edx
80107f52:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f5b:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107f62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f65:	83 c0 70             	add    $0x70,%eax
80107f68:	83 ec 08             	sub    $0x8,%esp
80107f6b:	6a 30                	push   $0x30
80107f6d:	50                   	push   %eax
80107f6e:	e8 5f fc ff ff       	call   80107bd2 <lgdt>
80107f73:	83 c4 10             	add    $0x10,%esp
}
80107f76:	90                   	nop
80107f77:	c9                   	leave  
80107f78:	c3                   	ret    

80107f79 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107f79:	f3 0f 1e fb          	endbr32 
80107f7d:	55                   	push   %ebp
80107f7e:	89 e5                	mov    %esp,%ebp
80107f80:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107f83:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f86:	c1 e8 16             	shr    $0x16,%eax
80107f89:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f90:	8b 45 08             	mov    0x8(%ebp),%eax
80107f93:	01 d0                	add    %edx,%eax
80107f95:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107f98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f9b:	8b 00                	mov    (%eax),%eax
80107f9d:	83 e0 01             	and    $0x1,%eax
80107fa0:	85 c0                	test   %eax,%eax
80107fa2:	74 14                	je     80107fb8 <walkpgdir+0x3f>
    //if (!alloc)
      //cprintf("page directory is good\n");
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107fa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fa7:	8b 00                	mov    (%eax),%eax
80107fa9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fae:	05 00 00 00 80       	add    $0x80000000,%eax
80107fb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107fb6:	eb 42                	jmp    80107ffa <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107fb8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107fbc:	74 0e                	je     80107fcc <walkpgdir+0x53>
80107fbe:	e8 72 ae ff ff       	call   80102e35 <kalloc>
80107fc3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107fc6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107fca:	75 07                	jne    80107fd3 <walkpgdir+0x5a>
      return 0;
80107fcc:	b8 00 00 00 00       	mov    $0x0,%eax
80107fd1:	eb 3e                	jmp    80108011 <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107fd3:	83 ec 04             	sub    $0x4,%esp
80107fd6:	68 00 10 00 00       	push   $0x1000
80107fdb:	6a 00                	push   $0x0
80107fdd:	ff 75 f4             	pushl  -0xc(%ebp)
80107fe0:	e8 9f d5 ff ff       	call   80105584 <memset>
80107fe5:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107feb:	05 00 00 00 80       	add    $0x80000000,%eax
80107ff0:	83 c8 07             	or     $0x7,%eax
80107ff3:	89 c2                	mov    %eax,%edx
80107ff5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ff8:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107ffa:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ffd:	c1 e8 0c             	shr    $0xc,%eax
80108000:	25 ff 03 00 00       	and    $0x3ff,%eax
80108005:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010800c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010800f:	01 d0                	add    %edx,%eax
}
80108011:	c9                   	leave  
80108012:	c3                   	ret    

80108013 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108013:	f3 0f 1e fb          	endbr32 
80108017:	55                   	push   %ebp
80108018:	89 e5                	mov    %esp,%ebp
8010801a:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010801d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108020:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108025:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108028:	8b 55 0c             	mov    0xc(%ebp),%edx
8010802b:	8b 45 10             	mov    0x10(%ebp),%eax
8010802e:	01 d0                	add    %edx,%eax
80108030:	83 e8 01             	sub    $0x1,%eax
80108033:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108038:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010803b:	83 ec 04             	sub    $0x4,%esp
8010803e:	6a 01                	push   $0x1
80108040:	ff 75 f4             	pushl  -0xc(%ebp)
80108043:	ff 75 08             	pushl  0x8(%ebp)
80108046:	e8 2e ff ff ff       	call   80107f79 <walkpgdir>
8010804b:	83 c4 10             	add    $0x10,%esp
8010804e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108051:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108055:	75 07                	jne    8010805e <mappages+0x4b>
      return -1;
80108057:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010805c:	eb 6a                	jmp    801080c8 <mappages+0xb5>
    if(*pte & (PTE_P | PTE_E))
8010805e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108061:	8b 00                	mov    (%eax),%eax
80108063:	25 01 04 00 00       	and    $0x401,%eax
80108068:	85 c0                	test   %eax,%eax
8010806a:	74 0d                	je     80108079 <mappages+0x66>
      panic("p4Debug, remapping page");
8010806c:	83 ec 0c             	sub    $0xc,%esp
8010806f:	68 54 9c 10 80       	push   $0x80109c54
80108074:	e8 8f 85 ff ff       	call   80100608 <panic>

    if (perm & PTE_E)
80108079:	8b 45 18             	mov    0x18(%ebp),%eax
8010807c:	25 00 04 00 00       	and    $0x400,%eax
80108081:	85 c0                	test   %eax,%eax
80108083:	74 12                	je     80108097 <mappages+0x84>
      *pte = pa | perm | PTE_E;
80108085:	8b 45 18             	mov    0x18(%ebp),%eax
80108088:	0b 45 14             	or     0x14(%ebp),%eax
8010808b:	80 cc 04             	or     $0x4,%ah
8010808e:	89 c2                	mov    %eax,%edx
80108090:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108093:	89 10                	mov    %edx,(%eax)
80108095:	eb 10                	jmp    801080a7 <mappages+0x94>
    else
      *pte = pa | perm | PTE_P;
80108097:	8b 45 18             	mov    0x18(%ebp),%eax
8010809a:	0b 45 14             	or     0x14(%ebp),%eax
8010809d:	83 c8 01             	or     $0x1,%eax
801080a0:	89 c2                	mov    %eax,%edx
801080a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080a5:	89 10                	mov    %edx,(%eax)


    if(a == last)
801080a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080aa:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801080ad:	74 13                	je     801080c2 <mappages+0xaf>
      break;
    a += PGSIZE;
801080af:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801080b6:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801080bd:	e9 79 ff ff ff       	jmp    8010803b <mappages+0x28>
      break;
801080c2:	90                   	nop
  }
  return 0;
801080c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801080c8:	c9                   	leave  
801080c9:	c3                   	ret    

801080ca <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801080ca:	f3 0f 1e fb          	endbr32 
801080ce:	55                   	push   %ebp
801080cf:	89 e5                	mov    %esp,%ebp
801080d1:	53                   	push   %ebx
801080d2:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801080d5:	e8 5b ad ff ff       	call   80102e35 <kalloc>
801080da:	89 45 f0             	mov    %eax,-0x10(%ebp)
801080dd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801080e1:	75 07                	jne    801080ea <setupkvm+0x20>
    return 0;
801080e3:	b8 00 00 00 00       	mov    $0x0,%eax
801080e8:	eb 78                	jmp    80108162 <setupkvm+0x98>
  memset(pgdir, 0, PGSIZE);
801080ea:	83 ec 04             	sub    $0x4,%esp
801080ed:	68 00 10 00 00       	push   $0x1000
801080f2:	6a 00                	push   $0x0
801080f4:	ff 75 f0             	pushl  -0x10(%ebp)
801080f7:	e8 88 d4 ff ff       	call   80105584 <memset>
801080fc:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801080ff:	c7 45 f4 a0 d4 10 80 	movl   $0x8010d4a0,-0xc(%ebp)
80108106:	eb 4e                	jmp    80108156 <setupkvm+0x8c>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108108:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010810b:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
8010810e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108111:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108117:	8b 58 08             	mov    0x8(%eax),%ebx
8010811a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010811d:	8b 40 04             	mov    0x4(%eax),%eax
80108120:	29 c3                	sub    %eax,%ebx
80108122:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108125:	8b 00                	mov    (%eax),%eax
80108127:	83 ec 0c             	sub    $0xc,%esp
8010812a:	51                   	push   %ecx
8010812b:	52                   	push   %edx
8010812c:	53                   	push   %ebx
8010812d:	50                   	push   %eax
8010812e:	ff 75 f0             	pushl  -0x10(%ebp)
80108131:	e8 dd fe ff ff       	call   80108013 <mappages>
80108136:	83 c4 20             	add    $0x20,%esp
80108139:	85 c0                	test   %eax,%eax
8010813b:	79 15                	jns    80108152 <setupkvm+0x88>
      freevm(pgdir);
8010813d:	83 ec 0c             	sub    $0xc,%esp
80108140:	ff 75 f0             	pushl  -0x10(%ebp)
80108143:	e8 13 05 00 00       	call   8010865b <freevm>
80108148:	83 c4 10             	add    $0x10,%esp
      return 0;
8010814b:	b8 00 00 00 00       	mov    $0x0,%eax
80108150:	eb 10                	jmp    80108162 <setupkvm+0x98>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108152:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108156:	81 7d f4 e0 d4 10 80 	cmpl   $0x8010d4e0,-0xc(%ebp)
8010815d:	72 a9                	jb     80108108 <setupkvm+0x3e>
    }
  return pgdir;
8010815f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108162:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108165:	c9                   	leave  
80108166:	c3                   	ret    

80108167 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108167:	f3 0f 1e fb          	endbr32 
8010816b:	55                   	push   %ebp
8010816c:	89 e5                	mov    %esp,%ebp
8010816e:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108171:	e8 54 ff ff ff       	call   801080ca <setupkvm>
80108176:	a3 44 96 11 80       	mov    %eax,0x80119644
  switchkvm();
8010817b:	e8 03 00 00 00       	call   80108183 <switchkvm>
}
80108180:	90                   	nop
80108181:	c9                   	leave  
80108182:	c3                   	ret    

80108183 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108183:	f3 0f 1e fb          	endbr32 
80108187:	55                   	push   %ebp
80108188:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
8010818a:	a1 44 96 11 80       	mov    0x80119644,%eax
8010818f:	05 00 00 00 80       	add    $0x80000000,%eax
80108194:	50                   	push   %eax
80108195:	e8 79 fa ff ff       	call   80107c13 <lcr3>
8010819a:	83 c4 04             	add    $0x4,%esp
}
8010819d:	90                   	nop
8010819e:	c9                   	leave  
8010819f:	c3                   	ret    

801081a0 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801081a0:	f3 0f 1e fb          	endbr32 
801081a4:	55                   	push   %ebp
801081a5:	89 e5                	mov    %esp,%ebp
801081a7:	56                   	push   %esi
801081a8:	53                   	push   %ebx
801081a9:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
801081ac:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801081b0:	75 0d                	jne    801081bf <switchuvm+0x1f>
    panic("switchuvm: no process");
801081b2:	83 ec 0c             	sub    $0xc,%esp
801081b5:	68 6c 9c 10 80       	push   $0x80109c6c
801081ba:	e8 49 84 ff ff       	call   80100608 <panic>
  if(p->kstack == 0)
801081bf:	8b 45 08             	mov    0x8(%ebp),%eax
801081c2:	8b 40 08             	mov    0x8(%eax),%eax
801081c5:	85 c0                	test   %eax,%eax
801081c7:	75 0d                	jne    801081d6 <switchuvm+0x36>
    panic("switchuvm: no kstack");
801081c9:	83 ec 0c             	sub    $0xc,%esp
801081cc:	68 82 9c 10 80       	push   $0x80109c82
801081d1:	e8 32 84 ff ff       	call   80100608 <panic>
  if(p->pgdir == 0)
801081d6:	8b 45 08             	mov    0x8(%ebp),%eax
801081d9:	8b 40 04             	mov    0x4(%eax),%eax
801081dc:	85 c0                	test   %eax,%eax
801081de:	75 0d                	jne    801081ed <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
801081e0:	83 ec 0c             	sub    $0xc,%esp
801081e3:	68 97 9c 10 80       	push   $0x80109c97
801081e8:	e8 1b 84 ff ff       	call   80100608 <panic>

  pushcli();
801081ed:	e8 7f d2 ff ff       	call   80105471 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801081f2:	e8 86 c2 ff ff       	call   8010447d <mycpu>
801081f7:	89 c3                	mov    %eax,%ebx
801081f9:	e8 7f c2 ff ff       	call   8010447d <mycpu>
801081fe:	83 c0 08             	add    $0x8,%eax
80108201:	89 c6                	mov    %eax,%esi
80108203:	e8 75 c2 ff ff       	call   8010447d <mycpu>
80108208:	83 c0 08             	add    $0x8,%eax
8010820b:	c1 e8 10             	shr    $0x10,%eax
8010820e:	88 45 f7             	mov    %al,-0x9(%ebp)
80108211:	e8 67 c2 ff ff       	call   8010447d <mycpu>
80108216:	83 c0 08             	add    $0x8,%eax
80108219:	c1 e8 18             	shr    $0x18,%eax
8010821c:	89 c2                	mov    %eax,%edx
8010821e:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80108225:	67 00 
80108227:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
8010822e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80108232:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80108238:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010823f:	83 e0 f0             	and    $0xfffffff0,%eax
80108242:	83 c8 09             	or     $0x9,%eax
80108245:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010824b:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108252:	83 c8 10             	or     $0x10,%eax
80108255:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010825b:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108262:	83 e0 9f             	and    $0xffffff9f,%eax
80108265:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010826b:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108272:	83 c8 80             	or     $0xffffff80,%eax
80108275:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010827b:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108282:	83 e0 f0             	and    $0xfffffff0,%eax
80108285:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010828b:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108292:	83 e0 ef             	and    $0xffffffef,%eax
80108295:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010829b:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801082a2:	83 e0 df             	and    $0xffffffdf,%eax
801082a5:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801082ab:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801082b2:	83 c8 40             	or     $0x40,%eax
801082b5:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801082bb:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801082c2:	83 e0 7f             	and    $0x7f,%eax
801082c5:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801082cb:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801082d1:	e8 a7 c1 ff ff       	call   8010447d <mycpu>
801082d6:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801082dd:	83 e2 ef             	and    $0xffffffef,%edx
801082e0:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801082e6:	e8 92 c1 ff ff       	call   8010447d <mycpu>
801082eb:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801082f1:	8b 45 08             	mov    0x8(%ebp),%eax
801082f4:	8b 40 08             	mov    0x8(%eax),%eax
801082f7:	89 c3                	mov    %eax,%ebx
801082f9:	e8 7f c1 ff ff       	call   8010447d <mycpu>
801082fe:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80108304:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80108307:	e8 71 c1 ff ff       	call   8010447d <mycpu>
8010830c:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80108312:	83 ec 0c             	sub    $0xc,%esp
80108315:	6a 28                	push   $0x28
80108317:	e8 e0 f8 ff ff       	call   80107bfc <ltr>
8010831c:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
8010831f:	8b 45 08             	mov    0x8(%ebp),%eax
80108322:	8b 40 04             	mov    0x4(%eax),%eax
80108325:	05 00 00 00 80       	add    $0x80000000,%eax
8010832a:	83 ec 0c             	sub    $0xc,%esp
8010832d:	50                   	push   %eax
8010832e:	e8 e0 f8 ff ff       	call   80107c13 <lcr3>
80108333:	83 c4 10             	add    $0x10,%esp
  popcli();
80108336:	e8 87 d1 ff ff       	call   801054c2 <popcli>
}
8010833b:	90                   	nop
8010833c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010833f:	5b                   	pop    %ebx
80108340:	5e                   	pop    %esi
80108341:	5d                   	pop    %ebp
80108342:	c3                   	ret    

80108343 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108343:	f3 0f 1e fb          	endbr32 
80108347:	55                   	push   %ebp
80108348:	89 e5                	mov    %esp,%ebp
8010834a:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
8010834d:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108354:	76 0d                	jbe    80108363 <inituvm+0x20>
    panic("inituvm: more than a page");
80108356:	83 ec 0c             	sub    $0xc,%esp
80108359:	68 ab 9c 10 80       	push   $0x80109cab
8010835e:	e8 a5 82 ff ff       	call   80100608 <panic>
  mem = kalloc();
80108363:	e8 cd aa ff ff       	call   80102e35 <kalloc>
80108368:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010836b:	83 ec 04             	sub    $0x4,%esp
8010836e:	68 00 10 00 00       	push   $0x1000
80108373:	6a 00                	push   $0x0
80108375:	ff 75 f4             	pushl  -0xc(%ebp)
80108378:	e8 07 d2 ff ff       	call   80105584 <memset>
8010837d:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80108380:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108383:	05 00 00 00 80       	add    $0x80000000,%eax
80108388:	83 ec 0c             	sub    $0xc,%esp
8010838b:	6a 06                	push   $0x6
8010838d:	50                   	push   %eax
8010838e:	68 00 10 00 00       	push   $0x1000
80108393:	6a 00                	push   $0x0
80108395:	ff 75 08             	pushl  0x8(%ebp)
80108398:	e8 76 fc ff ff       	call   80108013 <mappages>
8010839d:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801083a0:	83 ec 04             	sub    $0x4,%esp
801083a3:	ff 75 10             	pushl  0x10(%ebp)
801083a6:	ff 75 0c             	pushl  0xc(%ebp)
801083a9:	ff 75 f4             	pushl  -0xc(%ebp)
801083ac:	e8 9a d2 ff ff       	call   8010564b <memmove>
801083b1:	83 c4 10             	add    $0x10,%esp
}
801083b4:	90                   	nop
801083b5:	c9                   	leave  
801083b6:	c3                   	ret    

801083b7 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801083b7:	f3 0f 1e fb          	endbr32 
801083bb:	55                   	push   %ebp
801083bc:	89 e5                	mov    %esp,%ebp
801083be:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801083c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801083c4:	25 ff 0f 00 00       	and    $0xfff,%eax
801083c9:	85 c0                	test   %eax,%eax
801083cb:	74 0d                	je     801083da <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
801083cd:	83 ec 0c             	sub    $0xc,%esp
801083d0:	68 c8 9c 10 80       	push   $0x80109cc8
801083d5:	e8 2e 82 ff ff       	call   80100608 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801083da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083e1:	e9 8f 00 00 00       	jmp    80108475 <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801083e6:	8b 55 0c             	mov    0xc(%ebp),%edx
801083e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ec:	01 d0                	add    %edx,%eax
801083ee:	83 ec 04             	sub    $0x4,%esp
801083f1:	6a 00                	push   $0x0
801083f3:	50                   	push   %eax
801083f4:	ff 75 08             	pushl  0x8(%ebp)
801083f7:	e8 7d fb ff ff       	call   80107f79 <walkpgdir>
801083fc:	83 c4 10             	add    $0x10,%esp
801083ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108402:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108406:	75 0d                	jne    80108415 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80108408:	83 ec 0c             	sub    $0xc,%esp
8010840b:	68 eb 9c 10 80       	push   $0x80109ceb
80108410:	e8 f3 81 ff ff       	call   80100608 <panic>
    pa = PTE_ADDR(*pte);
80108415:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108418:	8b 00                	mov    (%eax),%eax
8010841a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010841f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108422:	8b 45 18             	mov    0x18(%ebp),%eax
80108425:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108428:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010842d:	77 0b                	ja     8010843a <loaduvm+0x83>
      n = sz - i;
8010842f:	8b 45 18             	mov    0x18(%ebp),%eax
80108432:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108435:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108438:	eb 07                	jmp    80108441 <loaduvm+0x8a>
    else
      n = PGSIZE;
8010843a:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108441:	8b 55 14             	mov    0x14(%ebp),%edx
80108444:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108447:	01 d0                	add    %edx,%eax
80108449:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010844c:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108452:	ff 75 f0             	pushl  -0x10(%ebp)
80108455:	50                   	push   %eax
80108456:	52                   	push   %edx
80108457:	ff 75 10             	pushl  0x10(%ebp)
8010845a:	e8 ee 9b ff ff       	call   8010204d <readi>
8010845f:	83 c4 10             	add    $0x10,%esp
80108462:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80108465:	74 07                	je     8010846e <loaduvm+0xb7>
      return -1;
80108467:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010846c:	eb 18                	jmp    80108486 <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
8010846e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108475:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108478:	3b 45 18             	cmp    0x18(%ebp),%eax
8010847b:	0f 82 65 ff ff ff    	jb     801083e6 <loaduvm+0x2f>
  }
  return 0;
80108481:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108486:	c9                   	leave  
80108487:	c3                   	ret    

80108488 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108488:	f3 0f 1e fb          	endbr32 
8010848c:	55                   	push   %ebp
8010848d:	89 e5                	mov    %esp,%ebp
8010848f:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108492:	8b 45 10             	mov    0x10(%ebp),%eax
80108495:	85 c0                	test   %eax,%eax
80108497:	79 0a                	jns    801084a3 <allocuvm+0x1b>
    return 0;
80108499:	b8 00 00 00 00       	mov    $0x0,%eax
8010849e:	e9 ec 00 00 00       	jmp    8010858f <allocuvm+0x107>
  if(newsz < oldsz)
801084a3:	8b 45 10             	mov    0x10(%ebp),%eax
801084a6:	3b 45 0c             	cmp    0xc(%ebp),%eax
801084a9:	73 08                	jae    801084b3 <allocuvm+0x2b>
    return oldsz;
801084ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801084ae:	e9 dc 00 00 00       	jmp    8010858f <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
801084b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801084b6:	05 ff 0f 00 00       	add    $0xfff,%eax
801084bb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801084c3:	e9 b8 00 00 00       	jmp    80108580 <allocuvm+0xf8>
    mem = kalloc();
801084c8:	e8 68 a9 ff ff       	call   80102e35 <kalloc>
801084cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801084d0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801084d4:	75 2e                	jne    80108504 <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
801084d6:	83 ec 0c             	sub    $0xc,%esp
801084d9:	68 09 9d 10 80       	push   $0x80109d09
801084de:	e8 35 7f ff ff       	call   80100418 <cprintf>
801084e3:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801084e6:	83 ec 04             	sub    $0x4,%esp
801084e9:	ff 75 0c             	pushl  0xc(%ebp)
801084ec:	ff 75 10             	pushl  0x10(%ebp)
801084ef:	ff 75 08             	pushl  0x8(%ebp)
801084f2:	e8 9a 00 00 00       	call   80108591 <deallocuvm>
801084f7:	83 c4 10             	add    $0x10,%esp
      return 0;
801084fa:	b8 00 00 00 00       	mov    $0x0,%eax
801084ff:	e9 8b 00 00 00       	jmp    8010858f <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
80108504:	83 ec 04             	sub    $0x4,%esp
80108507:	68 00 10 00 00       	push   $0x1000
8010850c:	6a 00                	push   $0x0
8010850e:	ff 75 f0             	pushl  -0x10(%ebp)
80108511:	e8 6e d0 ff ff       	call   80105584 <memset>
80108516:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108519:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010851c:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108522:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108525:	83 ec 0c             	sub    $0xc,%esp
80108528:	6a 06                	push   $0x6
8010852a:	52                   	push   %edx
8010852b:	68 00 10 00 00       	push   $0x1000
80108530:	50                   	push   %eax
80108531:	ff 75 08             	pushl  0x8(%ebp)
80108534:	e8 da fa ff ff       	call   80108013 <mappages>
80108539:	83 c4 20             	add    $0x20,%esp
8010853c:	85 c0                	test   %eax,%eax
8010853e:	79 39                	jns    80108579 <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
80108540:	83 ec 0c             	sub    $0xc,%esp
80108543:	68 21 9d 10 80       	push   $0x80109d21
80108548:	e8 cb 7e ff ff       	call   80100418 <cprintf>
8010854d:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108550:	83 ec 04             	sub    $0x4,%esp
80108553:	ff 75 0c             	pushl  0xc(%ebp)
80108556:	ff 75 10             	pushl  0x10(%ebp)
80108559:	ff 75 08             	pushl  0x8(%ebp)
8010855c:	e8 30 00 00 00       	call   80108591 <deallocuvm>
80108561:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80108564:	83 ec 0c             	sub    $0xc,%esp
80108567:	ff 75 f0             	pushl  -0x10(%ebp)
8010856a:	e8 28 a8 ff ff       	call   80102d97 <kfree>
8010856f:	83 c4 10             	add    $0x10,%esp
      return 0;
80108572:	b8 00 00 00 00       	mov    $0x0,%eax
80108577:	eb 16                	jmp    8010858f <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
80108579:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108580:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108583:	3b 45 10             	cmp    0x10(%ebp),%eax
80108586:	0f 82 3c ff ff ff    	jb     801084c8 <allocuvm+0x40>
    }
  }
  return newsz;
8010858c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010858f:	c9                   	leave  
80108590:	c3                   	ret    

80108591 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108591:	f3 0f 1e fb          	endbr32 
80108595:	55                   	push   %ebp
80108596:	89 e5                	mov    %esp,%ebp
80108598:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010859b:	8b 45 10             	mov    0x10(%ebp),%eax
8010859e:	3b 45 0c             	cmp    0xc(%ebp),%eax
801085a1:	72 08                	jb     801085ab <deallocuvm+0x1a>
    return oldsz;
801085a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801085a6:	e9 ae 00 00 00       	jmp    80108659 <deallocuvm+0xc8>

  a = PGROUNDUP(newsz);
801085ab:	8b 45 10             	mov    0x10(%ebp),%eax
801085ae:	05 ff 0f 00 00       	add    $0xfff,%eax
801085b3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801085bb:	e9 8a 00 00 00       	jmp    8010864a <deallocuvm+0xb9>
    pte = walkpgdir(pgdir, (char*)a, 0);
801085c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c3:	83 ec 04             	sub    $0x4,%esp
801085c6:	6a 00                	push   $0x0
801085c8:	50                   	push   %eax
801085c9:	ff 75 08             	pushl  0x8(%ebp)
801085cc:	e8 a8 f9 ff ff       	call   80107f79 <walkpgdir>
801085d1:	83 c4 10             	add    $0x10,%esp
801085d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801085d7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801085db:	75 16                	jne    801085f3 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801085dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085e0:	c1 e8 16             	shr    $0x16,%eax
801085e3:	83 c0 01             	add    $0x1,%eax
801085e6:	c1 e0 16             	shl    $0x16,%eax
801085e9:	2d 00 10 00 00       	sub    $0x1000,%eax
801085ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
801085f1:	eb 50                	jmp    80108643 <deallocuvm+0xb2>
    else if((*pte & (PTE_P | PTE_E)) != 0){
801085f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085f6:	8b 00                	mov    (%eax),%eax
801085f8:	25 01 04 00 00       	and    $0x401,%eax
801085fd:	85 c0                	test   %eax,%eax
801085ff:	74 42                	je     80108643 <deallocuvm+0xb2>
      pa = PTE_ADDR(*pte);
80108601:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108604:	8b 00                	mov    (%eax),%eax
80108606:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010860b:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
8010860e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108612:	75 0d                	jne    80108621 <deallocuvm+0x90>
        panic("kfree");
80108614:	83 ec 0c             	sub    $0xc,%esp
80108617:	68 3d 9d 10 80       	push   $0x80109d3d
8010861c:	e8 e7 7f ff ff       	call   80100608 <panic>
      char *v = P2V(pa);
80108621:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108624:	05 00 00 00 80       	add    $0x80000000,%eax
80108629:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010862c:	83 ec 0c             	sub    $0xc,%esp
8010862f:	ff 75 e8             	pushl  -0x18(%ebp)
80108632:	e8 60 a7 ff ff       	call   80102d97 <kfree>
80108637:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
8010863a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010863d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80108643:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010864a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010864d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108650:	0f 82 6a ff ff ff    	jb     801085c0 <deallocuvm+0x2f>
    }
  }
  return newsz;
80108656:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108659:	c9                   	leave  
8010865a:	c3                   	ret    

8010865b <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010865b:	f3 0f 1e fb          	endbr32 
8010865f:	55                   	push   %ebp
80108660:	89 e5                	mov    %esp,%ebp
80108662:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108665:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108669:	75 0d                	jne    80108678 <freevm+0x1d>
    panic("freevm: no pgdir");
8010866b:	83 ec 0c             	sub    $0xc,%esp
8010866e:	68 43 9d 10 80       	push   $0x80109d43
80108673:	e8 90 7f ff ff       	call   80100608 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108678:	83 ec 04             	sub    $0x4,%esp
8010867b:	6a 00                	push   $0x0
8010867d:	68 00 00 00 80       	push   $0x80000000
80108682:	ff 75 08             	pushl  0x8(%ebp)
80108685:	e8 07 ff ff ff       	call   80108591 <deallocuvm>
8010868a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010868d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108694:	eb 4a                	jmp    801086e0 <freevm+0x85>
    if(pgdir[i] & (PTE_P | PTE_E)){
80108696:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108699:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801086a0:	8b 45 08             	mov    0x8(%ebp),%eax
801086a3:	01 d0                	add    %edx,%eax
801086a5:	8b 00                	mov    (%eax),%eax
801086a7:	25 01 04 00 00       	and    $0x401,%eax
801086ac:	85 c0                	test   %eax,%eax
801086ae:	74 2c                	je     801086dc <freevm+0x81>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801086b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801086ba:	8b 45 08             	mov    0x8(%ebp),%eax
801086bd:	01 d0                	add    %edx,%eax
801086bf:	8b 00                	mov    (%eax),%eax
801086c1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086c6:	05 00 00 00 80       	add    $0x80000000,%eax
801086cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801086ce:	83 ec 0c             	sub    $0xc,%esp
801086d1:	ff 75 f0             	pushl  -0x10(%ebp)
801086d4:	e8 be a6 ff ff       	call   80102d97 <kfree>
801086d9:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801086dc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801086e0:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801086e7:	76 ad                	jbe    80108696 <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
801086e9:	83 ec 0c             	sub    $0xc,%esp
801086ec:	ff 75 08             	pushl  0x8(%ebp)
801086ef:	e8 a3 a6 ff ff       	call   80102d97 <kfree>
801086f4:	83 c4 10             	add    $0x10,%esp
}
801086f7:	90                   	nop
801086f8:	c9                   	leave  
801086f9:	c3                   	ret    

801086fa <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801086fa:	f3 0f 1e fb          	endbr32 
801086fe:	55                   	push   %ebp
801086ff:	89 e5                	mov    %esp,%ebp
80108701:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108704:	83 ec 04             	sub    $0x4,%esp
80108707:	6a 00                	push   $0x0
80108709:	ff 75 0c             	pushl  0xc(%ebp)
8010870c:	ff 75 08             	pushl  0x8(%ebp)
8010870f:	e8 65 f8 ff ff       	call   80107f79 <walkpgdir>
80108714:	83 c4 10             	add    $0x10,%esp
80108717:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010871a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010871e:	75 0d                	jne    8010872d <clearpteu+0x33>
    panic("clearpteu");
80108720:	83 ec 0c             	sub    $0xc,%esp
80108723:	68 54 9d 10 80       	push   $0x80109d54
80108728:	e8 db 7e ff ff       	call   80100608 <panic>
  *pte &= ~PTE_U;
8010872d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108730:	8b 00                	mov    (%eax),%eax
80108732:	83 e0 fb             	and    $0xfffffffb,%eax
80108735:	89 c2                	mov    %eax,%edx
80108737:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010873a:	89 10                	mov    %edx,(%eax)
}
8010873c:	90                   	nop
8010873d:	c9                   	leave  
8010873e:	c3                   	ret    

8010873f <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010873f:	f3 0f 1e fb          	endbr32 
80108743:	55                   	push   %ebp
80108744:	89 e5                	mov    %esp,%ebp
80108746:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108749:	e8 7c f9 ff ff       	call   801080ca <setupkvm>
8010874e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108751:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108755:	75 0a                	jne    80108761 <copyuvm+0x22>
    return 0;
80108757:	b8 00 00 00 00       	mov    $0x0,%eax
8010875c:	e9 fa 00 00 00       	jmp    8010885b <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
80108761:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108768:	e9 c9 00 00 00       	jmp    80108836 <copyuvm+0xf7>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010876d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108770:	83 ec 04             	sub    $0x4,%esp
80108773:	6a 00                	push   $0x0
80108775:	50                   	push   %eax
80108776:	ff 75 08             	pushl  0x8(%ebp)
80108779:	e8 fb f7 ff ff       	call   80107f79 <walkpgdir>
8010877e:	83 c4 10             	add    $0x10,%esp
80108781:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108784:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108788:	75 0d                	jne    80108797 <copyuvm+0x58>
      panic("p4Debug: inside copyuvm, pte should exist");
8010878a:	83 ec 0c             	sub    $0xc,%esp
8010878d:	68 60 9d 10 80       	push   $0x80109d60
80108792:	e8 71 7e ff ff       	call   80100608 <panic>
    if(!(*pte & (PTE_P | PTE_E)))
80108797:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010879a:	8b 00                	mov    (%eax),%eax
8010879c:	25 01 04 00 00       	and    $0x401,%eax
801087a1:	85 c0                	test   %eax,%eax
801087a3:	75 0d                	jne    801087b2 <copyuvm+0x73>
      panic("p4Debug: inside copyuvm, page not present");
801087a5:	83 ec 0c             	sub    $0xc,%esp
801087a8:	68 8c 9d 10 80       	push   $0x80109d8c
801087ad:	e8 56 7e ff ff       	call   80100608 <panic>
    pa = PTE_ADDR(*pte);
801087b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087b5:	8b 00                	mov    (%eax),%eax
801087b7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087bc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801087bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087c2:	8b 00                	mov    (%eax),%eax
801087c4:	25 ff 0f 00 00       	and    $0xfff,%eax
801087c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801087cc:	e8 64 a6 ff ff       	call   80102e35 <kalloc>
801087d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
801087d4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801087d8:	74 6d                	je     80108847 <copyuvm+0x108>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801087da:	8b 45 e8             	mov    -0x18(%ebp),%eax
801087dd:	05 00 00 00 80       	add    $0x80000000,%eax
801087e2:	83 ec 04             	sub    $0x4,%esp
801087e5:	68 00 10 00 00       	push   $0x1000
801087ea:	50                   	push   %eax
801087eb:	ff 75 e0             	pushl  -0x20(%ebp)
801087ee:	e8 58 ce ff ff       	call   8010564b <memmove>
801087f3:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
801087f6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801087f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087fc:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108802:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108805:	83 ec 0c             	sub    $0xc,%esp
80108808:	52                   	push   %edx
80108809:	51                   	push   %ecx
8010880a:	68 00 10 00 00       	push   $0x1000
8010880f:	50                   	push   %eax
80108810:	ff 75 f0             	pushl  -0x10(%ebp)
80108813:	e8 fb f7 ff ff       	call   80108013 <mappages>
80108818:	83 c4 20             	add    $0x20,%esp
8010881b:	85 c0                	test   %eax,%eax
8010881d:	79 10                	jns    8010882f <copyuvm+0xf0>
      kfree(mem);
8010881f:	83 ec 0c             	sub    $0xc,%esp
80108822:	ff 75 e0             	pushl  -0x20(%ebp)
80108825:	e8 6d a5 ff ff       	call   80102d97 <kfree>
8010882a:	83 c4 10             	add    $0x10,%esp
      goto bad;
8010882d:	eb 19                	jmp    80108848 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
8010882f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108836:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108839:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010883c:	0f 82 2b ff ff ff    	jb     8010876d <copyuvm+0x2e>
    }
  }
  return d;
80108842:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108845:	eb 14                	jmp    8010885b <copyuvm+0x11c>
      goto bad;
80108847:	90                   	nop

bad:
  freevm(d);
80108848:	83 ec 0c             	sub    $0xc,%esp
8010884b:	ff 75 f0             	pushl  -0x10(%ebp)
8010884e:	e8 08 fe ff ff       	call   8010865b <freevm>
80108853:	83 c4 10             	add    $0x10,%esp
  return 0;
80108856:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010885b:	c9                   	leave  
8010885c:	c3                   	ret    

8010885d <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010885d:	f3 0f 1e fb          	endbr32 
80108861:	55                   	push   %ebp
80108862:	89 e5                	mov    %esp,%ebp
80108864:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108867:	83 ec 04             	sub    $0x4,%esp
8010886a:	6a 00                	push   $0x0
8010886c:	ff 75 0c             	pushl  0xc(%ebp)
8010886f:	ff 75 08             	pushl  0x8(%ebp)
80108872:	e8 02 f7 ff ff       	call   80107f79 <walkpgdir>
80108877:	83 c4 10             	add    $0x10,%esp
8010887a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  // p4Debug: Check for page's present and encrypted flags.
  if(((*pte & PTE_P) | (*pte & PTE_E)) == 0)
8010887d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108880:	8b 00                	mov    (%eax),%eax
80108882:	25 01 04 00 00       	and    $0x401,%eax
80108887:	85 c0                	test   %eax,%eax
80108889:	75 07                	jne    80108892 <uva2ka+0x35>
    return 0;
8010888b:	b8 00 00 00 00       	mov    $0x0,%eax
80108890:	eb 22                	jmp    801088b4 <uva2ka+0x57>
  if((*pte & PTE_U) == 0)
80108892:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108895:	8b 00                	mov    (%eax),%eax
80108897:	83 e0 04             	and    $0x4,%eax
8010889a:	85 c0                	test   %eax,%eax
8010889c:	75 07                	jne    801088a5 <uva2ka+0x48>
    return 0;
8010889e:	b8 00 00 00 00       	mov    $0x0,%eax
801088a3:	eb 0f                	jmp    801088b4 <uva2ka+0x57>
  return (char*)P2V(PTE_ADDR(*pte));
801088a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088a8:	8b 00                	mov    (%eax),%eax
801088aa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088af:	05 00 00 00 80       	add    $0x80000000,%eax
}
801088b4:	c9                   	leave  
801088b5:	c3                   	ret    

801088b6 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801088b6:	f3 0f 1e fb          	endbr32 
801088ba:	55                   	push   %ebp
801088bb:	89 e5                	mov    %esp,%ebp
801088bd:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801088c0:	8b 45 10             	mov    0x10(%ebp),%eax
801088c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801088c6:	eb 7f                	jmp    80108947 <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
801088c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801088cb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801088d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088d6:	83 ec 08             	sub    $0x8,%esp
801088d9:	50                   	push   %eax
801088da:	ff 75 08             	pushl  0x8(%ebp)
801088dd:	e8 7b ff ff ff       	call   8010885d <uva2ka>
801088e2:	83 c4 10             	add    $0x10,%esp
801088e5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801088e8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801088ec:	75 07                	jne    801088f5 <copyout+0x3f>
    {
      //p4Debug : Cannot find page in kernel space.
      return -1;
801088ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801088f3:	eb 61                	jmp    80108956 <copyout+0xa0>
    }
    n = PGSIZE - (va - va0);
801088f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088f8:	2b 45 0c             	sub    0xc(%ebp),%eax
801088fb:	05 00 10 00 00       	add    $0x1000,%eax
80108900:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108903:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108906:	3b 45 14             	cmp    0x14(%ebp),%eax
80108909:	76 06                	jbe    80108911 <copyout+0x5b>
      n = len;
8010890b:	8b 45 14             	mov    0x14(%ebp),%eax
8010890e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108911:	8b 45 0c             	mov    0xc(%ebp),%eax
80108914:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108917:	89 c2                	mov    %eax,%edx
80108919:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010891c:	01 d0                	add    %edx,%eax
8010891e:	83 ec 04             	sub    $0x4,%esp
80108921:	ff 75 f0             	pushl  -0x10(%ebp)
80108924:	ff 75 f4             	pushl  -0xc(%ebp)
80108927:	50                   	push   %eax
80108928:	e8 1e cd ff ff       	call   8010564b <memmove>
8010892d:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108930:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108933:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108936:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108939:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010893c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010893f:	05 00 10 00 00       	add    $0x1000,%eax
80108944:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108947:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010894b:	0f 85 77 ff ff ff    	jne    801088c8 <copyout+0x12>
  }
  return 0;
80108951:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108956:	c9                   	leave  
80108957:	c3                   	ret    

80108958 <translate_and_set>:

//This function is just like uva2ka but sets the PTE_E bit and clears PTE_P
char* translate_and_set(pde_t *pgdir, char *uva) {
80108958:	f3 0f 1e fb          	endbr32 
8010895c:	55                   	push   %ebp
8010895d:	89 e5                	mov    %esp,%ebp
8010895f:	83 ec 18             	sub    $0x18,%esp
  cprintf("p4Debug: setting PTE_E for %p, VPN %d\n", uva, PPN(uva));
80108962:	8b 45 0c             	mov    0xc(%ebp),%eax
80108965:	c1 e8 0c             	shr    $0xc,%eax
80108968:	83 ec 04             	sub    $0x4,%esp
8010896b:	50                   	push   %eax
8010896c:	ff 75 0c             	pushl  0xc(%ebp)
8010896f:	68 b8 9d 10 80       	push   $0x80109db8
80108974:	e8 9f 7a ff ff       	call   80100418 <cprintf>
80108979:	83 c4 10             	add    $0x10,%esp
  pte_t *pte;
  pte = walkpgdir(pgdir, uva, 0);
8010897c:	83 ec 04             	sub    $0x4,%esp
8010897f:	6a 00                	push   $0x0
80108981:	ff 75 0c             	pushl  0xc(%ebp)
80108984:	ff 75 08             	pushl  0x8(%ebp)
80108987:	e8 ed f5 ff ff       	call   80107f79 <walkpgdir>
8010898c:	83 c4 10             	add    $0x10,%esp
8010898f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  //p4Debug: If page is not present AND it is not encrypted.
  if((*pte & PTE_P) == 0 && (*pte & PTE_E) == 0)
80108992:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108995:	8b 00                	mov    (%eax),%eax
80108997:	83 e0 01             	and    $0x1,%eax
8010899a:	85 c0                	test   %eax,%eax
8010899c:	75 18                	jne    801089b6 <translate_and_set+0x5e>
8010899e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089a1:	8b 00                	mov    (%eax),%eax
801089a3:	25 00 04 00 00       	and    $0x400,%eax
801089a8:	85 c0                	test   %eax,%eax
801089aa:	75 0a                	jne    801089b6 <translate_and_set+0x5e>
    return 0;
801089ac:	b8 00 00 00 00       	mov    $0x0,%eax
801089b1:	e9 93 00 00 00       	jmp    80108a49 <translate_and_set+0xf1>
  //p4Debug: If page is already encrypted, i.e. PTE_E is set, return NULL as error;
  if((*pte & PTE_E)) {
801089b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089b9:	8b 00                	mov    (%eax),%eax
801089bb:	25 00 04 00 00       	and    $0x400,%eax
801089c0:	85 c0                	test   %eax,%eax
801089c2:	74 07                	je     801089cb <translate_and_set+0x73>
    return 0;
801089c4:	b8 00 00 00 00       	mov    $0x0,%eax
801089c9:	eb 7e                	jmp    80108a49 <translate_and_set+0xf1>
  }
  // p4Debug: Check if users are allowed to use this page
  if((*pte & PTE_U) == 0)
801089cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ce:	8b 00                	mov    (%eax),%eax
801089d0:	83 e0 04             	and    $0x4,%eax
801089d3:	85 c0                	test   %eax,%eax
801089d5:	75 07                	jne    801089de <translate_and_set+0x86>
    return 0;
801089d7:	b8 00 00 00 00       	mov    $0x0,%eax
801089dc:	eb 6b                	jmp    80108a49 <translate_and_set+0xf1>
  //p4Debug: Set Page as encrypted and not present so that we can trap(see trap.c) to decrypt page
  cprintf("p4Debug: PTE was %x and its pointer %p\n", *pte, pte);
801089de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089e1:	8b 00                	mov    (%eax),%eax
801089e3:	83 ec 04             	sub    $0x4,%esp
801089e6:	ff 75 f4             	pushl  -0xc(%ebp)
801089e9:	50                   	push   %eax
801089ea:	68 e0 9d 10 80       	push   $0x80109de0
801089ef:	e8 24 7a ff ff       	call   80100418 <cprintf>
801089f4:	83 c4 10             	add    $0x10,%esp
  *pte = *pte | PTE_E;
801089f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089fa:	8b 00                	mov    (%eax),%eax
801089fc:	80 cc 04             	or     $0x4,%ah
801089ff:	89 c2                	mov    %eax,%edx
80108a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a04:	89 10                	mov    %edx,(%eax)
  *pte =* pte & ~PTE_P;
80108a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a09:	8b 00                	mov    (%eax),%eax
80108a0b:	83 e0 fe             	and    $0xfffffffe,%eax
80108a0e:	89 c2                	mov    %eax,%edx
80108a10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a13:	89 10                	mov    %edx,(%eax)
 //
 *pte = *pte & ~PTE_A;
80108a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a18:	8b 00                	mov    (%eax),%eax
80108a1a:	83 e0 df             	and    $0xffffffdf,%eax
80108a1d:	89 c2                	mov    %eax,%edx
80108a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a22:	89 10                	mov    %edx,(%eax)
  cprintf("p4Debug: PTE is now %x\n", *pte);
80108a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a27:	8b 00                	mov    (%eax),%eax
80108a29:	83 ec 08             	sub    $0x8,%esp
80108a2c:	50                   	push   %eax
80108a2d:	68 08 9e 10 80       	push   $0x80109e08
80108a32:	e8 e1 79 ff ff       	call   80100418 <cprintf>
80108a37:	83 c4 10             	add    $0x10,%esp
  return (char*)P2V(PTE_ADDR(*pte));
80108a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a3d:	8b 00                	mov    (%eax),%eax
80108a3f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a44:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108a49:	c9                   	leave  
80108a4a:	c3                   	ret    

80108a4b <inQ>:
int inQ(struct  proc * p, char* virt){
80108a4b:	f3 0f 1e fb          	endbr32 
80108a4f:	55                   	push   %ebp
80108a50:	89 e5                	mov    %esp,%ebp
80108a52:	83 ec 10             	sub    $0x10,%esp
        //cprintf("you called inQ, %x\n",(uint) virt);
        int myhead = p->head%CLOCKSIZE;
80108a55:	8b 45 08             	mov    0x8(%ebp),%eax
80108a58:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
80108a5e:	99                   	cltd   
80108a5f:	c1 ea 1d             	shr    $0x1d,%edx
80108a62:	01 d0                	add    %edx,%eax
80108a64:	83 e0 07             	and    $0x7,%eax
80108a67:	29 d0                	sub    %edx,%eax
80108a69:	89 45 f8             	mov    %eax,-0x8(%ebp)
	 for(int i=myhead; i<myhead+CLOCKSIZE; i++)
80108a6c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108a6f:	89 45 fc             	mov    %eax,-0x4(%ebp)
80108a72:	eb 39                	jmp    80108aad <inQ+0x62>
	 {
		//cprintf("%d\n", myhead);
		//cprintf("%d\n", CLOCKSIZE);
	char* check = p->clock[i%CLOCKSIZE].addr;
80108a74:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108a77:	99                   	cltd   
80108a78:	c1 ea 1d             	shr    $0x1d,%edx
80108a7b:	01 d0                	add    %edx,%eax
80108a7d:	83 e0 07             	and    $0x7,%eax
80108a80:	29 d0                	sub    %edx,%eax
80108a82:	89 c2                	mov    %eax,%edx
80108a84:	8b 45 08             	mov    0x8(%ebp),%eax
80108a87:	83 c2 0e             	add    $0xe,%edx
80108a8a:	8b 44 d0 0c          	mov    0xc(%eax,%edx,8),%eax
80108a8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
		//cprintf(" CHECK %x\n", check);
               //cprintf("--------%x\n",(uint)virt);

		if(check==virt)
80108a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a94:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108a97:	75 10                	jne    80108aa9 <inQ+0x5e>
                {
                       // cprintf("and they are equal\n");
			return i%CLOCKSIZE; 
80108a99:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108a9c:	99                   	cltd   
80108a9d:	c1 ea 1d             	shr    $0x1d,%edx
80108aa0:	01 d0                	add    %edx,%eax
80108aa2:	83 e0 07             	and    $0x7,%eax
80108aa5:	29 d0                	sub    %edx,%eax
80108aa7:	eb 14                	jmp    80108abd <inQ+0x72>
	 for(int i=myhead; i<myhead+CLOCKSIZE; i++)
80108aa9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80108aad:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108ab0:	83 c0 07             	add    $0x7,%eax
80108ab3:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80108ab6:	7e bc                	jle    80108a74 <inQ+0x29>
                }
	 } 

	 return -1;
80108ab8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80108abd:	c9                   	leave  
80108abe:	c3                   	ret    

80108abf <addClock>:



int addClock(struct proc * p, char *va)
{
80108abf:	f3 0f 1e fb          	endbr32 
80108ac3:	55                   	push   %ebp
80108ac4:	89 e5                	mov    %esp,%ebp
80108ac6:	83 ec 28             	sub    $0x28,%esp

        pde_t* mypd = p->pgdir;
80108ac9:	8b 45 08             	mov    0x8(%ebp),%eax
80108acc:	8b 40 04             	mov    0x4(%eax),%eax
80108acf:	89 45 e8             	mov    %eax,-0x18(%ebp)
       //pte_t * pte = walkpgdir(mypd, va, 0);
        int head = p->head;
80108ad2:	8b 45 08             	mov    0x8(%ebp),%eax
80108ad5:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
80108adb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	//int tail = (head-1+CLOCKSIZE)%CLOCKSIZE;
	//for (int i=tail; i)



        for(int i=head+CLOCKSIZE; i>head; i--)
80108ade:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108ae1:	83 c0 08             	add    $0x8,%eax
80108ae4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108ae7:	e9 8a 00 00 00       	jmp    80108b76 <addClock+0xb7>
        {
        if(p->clock[(i)%CLOCKSIZE].addr==0){
80108aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aef:	99                   	cltd   
80108af0:	c1 ea 1d             	shr    $0x1d,%edx
80108af3:	01 d0                	add    %edx,%eax
80108af5:	83 e0 07             	and    $0x7,%eax
80108af8:	29 d0                	sub    %edx,%eax
80108afa:	89 c2                	mov    %eax,%edx
80108afc:	8b 45 08             	mov    0x8(%ebp),%eax
80108aff:	83 c2 0e             	add    $0xe,%edx
80108b02:	8b 44 d0 0c          	mov    0xc(%eax,%edx,8),%eax
80108b06:	85 c0                	test   %eax,%eax
80108b08:	75 68                	jne    80108b72 <addClock+0xb3>
         	 p->clock[(i)%CLOCKSIZE].addr =va; //(char*)P2V(PTE_ADDR(*pte));  // pte;
80108b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b0d:	99                   	cltd   
80108b0e:	c1 ea 1d             	shr    $0x1d,%edx
80108b11:	01 d0                	add    %edx,%eax
80108b13:	83 e0 07             	and    $0x7,%eax
80108b16:	29 d0                	sub    %edx,%eax
80108b18:	89 c2                	mov    %eax,%edx
80108b1a:	8b 45 08             	mov    0x8(%ebp),%eax
80108b1d:	8d 4a 0e             	lea    0xe(%edx),%ecx
80108b20:	8b 55 0c             	mov    0xc(%ebp),%edx
80108b23:	89 54 c8 0c          	mov    %edx,0xc(%eax,%ecx,8)
               //p->head++;
	      p->head = (i+1)%CLOCKSIZE;
80108b27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b2a:	8d 50 01             	lea    0x1(%eax),%edx
80108b2d:	89 d0                	mov    %edx,%eax
80108b2f:	c1 f8 1f             	sar    $0x1f,%eax
80108b32:	c1 e8 1d             	shr    $0x1d,%eax
80108b35:	01 c2                	add    %eax,%edx
80108b37:	83 e2 07             	and    $0x7,%edx
80108b3a:	29 c2                	sub    %eax,%edx
80108b3c:	89 d0                	mov    %edx,%eax
80108b3e:	89 c2                	mov    %eax,%edx
80108b40:	8b 45 08             	mov    0x8(%ebp),%eax
80108b43:	89 90 bc 00 00 00    	mov    %edx,0xbc(%eax)
	                     cprintf("=========change head 4%d\n", i%CLOCKSIZE);
80108b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b4c:	99                   	cltd   
80108b4d:	c1 ea 1d             	shr    $0x1d,%edx
80108b50:	01 d0                	add    %edx,%eax
80108b52:	83 e0 07             	and    $0x7,%eax
80108b55:	29 d0                	sub    %edx,%eax
80108b57:	83 ec 08             	sub    $0x8,%esp
80108b5a:	50                   	push   %eax
80108b5b:	68 20 9e 10 80       	push   $0x80109e20
80108b60:	e8 b3 78 ff ff       	call   80100418 <cprintf>
80108b65:	83 c4 10             	add    $0x10,%esp

	       	return 0;
80108b68:	b8 00 00 00 00       	mov    $0x0,%eax
80108b6d:	e9 52 01 00 00       	jmp    80108cc4 <addClock+0x205>
        for(int i=head+CLOCKSIZE; i>head; i--)
80108b72:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80108b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b79:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
80108b7c:	0f 8f 6a ff ff ff    	jg     80108aec <addClock+0x2d>
        }
        }

 cprintf("-----------      trying to evictBEFORE \n");
80108b82:	83 ec 0c             	sub    $0xc,%esp
80108b85:	68 3c 9e 10 80       	push   $0x80109e3c
80108b8a:	e8 89 78 ff ff       	call   80100418 <cprintf>
80108b8f:	83 c4 10             	add    $0x10,%esp

        //if no empty spaces
         char* cur_va = p->clock[head].addr;
80108b92:	8b 45 08             	mov    0x8(%ebp),%eax
80108b95:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108b98:	83 c2 0e             	add    $0xe,%edx
80108b9b:	8b 44 d0 0c          	mov    0xc(%eax,%edx,8),%eax
80108b9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
         int found =0;
80108ba2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
         while(!found){
80108ba9:	e9 07 01 00 00       	jmp    80108cb5 <addClock+0x1f6>
               pte_t * pte = walkpgdir(mypd, cur_va, 0);
80108bae:	83 ec 04             	sub    $0x4,%esp
80108bb1:	6a 00                	push   $0x0
80108bb3:	ff 75 f0             	pushl  -0x10(%ebp)
80108bb6:	ff 75 e8             	pushl  -0x18(%ebp)
80108bb9:	e8 bb f3 ff ff       	call   80107f79 <walkpgdir>
80108bbe:	83 c4 10             	add    $0x10,%esp
80108bc1:	89 45 e0             	mov    %eax,-0x20(%ebp)
           //if pte_b's acces bit is 0 
               if(!(*pte & PTE_A)){
80108bc4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bc7:	8b 00                	mov    (%eax),%eax
80108bc9:	83 e0 20             	and    $0x20,%eax
80108bcc:	85 c0                	test   %eax,%eax
80108bce:	0f 85 a0 00 00 00    	jne    80108c74 <addClock+0x1b5>
               //evict
	       cprintf("-----------      trying to evict %x\n", (uint)cur_va);
80108bd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bd7:	83 ec 08             	sub    $0x8,%esp
80108bda:	50                   	push   %eax
80108bdb:	68 68 9e 10 80       	push   $0x80109e68
80108be0:	e8 33 78 ff ff       	call   80100418 <cprintf>
80108be5:	83 c4 10             	add    $0x10,%esp
  //       //make sure pte's access bit is set to 1 
  //       //encrypt pte_b
cprintf("----------------------MEMECRYPT   %d\n",  mencrypt(cur_va,1));//not sure
80108be8:	83 ec 08             	sub    $0x8,%esp
80108beb:	6a 01                	push   $0x1
80108bed:	ff 75 f0             	pushl  -0x10(%ebp)
80108bf0:	e8 38 04 00 00       	call   8010902d <mencrypt>
80108bf5:	83 c4 10             	add    $0x10,%esp
80108bf8:	83 ec 08             	sub    $0x8,%esp
80108bfb:	50                   	push   %eax
80108bfc:	68 90 9e 10 80       	push   $0x80109e90
80108c01:	e8 12 78 ff ff       	call   80100418 <cprintf>
80108c06:	83 c4 10             	add    $0x10,%esp

	     //  cprintf("CURVA MENCRYPT\n");
	       p->clock[head].addr = va;
80108c09:	8b 45 08             	mov    0x8(%ebp),%eax
80108c0c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108c0f:	8d 4a 0e             	lea    0xe(%edx),%ecx
80108c12:	8b 55 0c             	mov    0xc(%ebp),%edx
80108c15:	89 54 c8 0c          	mov    %edx,0xc(%eax,%ecx,8)
               *pte = *pte | PTE_E;
80108c19:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c1c:	8b 00                	mov    (%eax),%eax
80108c1e:	80 cc 04             	or     $0x4,%ah
80108c21:	89 c2                	mov    %eax,%edx
80108c23:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c26:	89 10                	mov    %edx,(%eax)
	 *pte = *pte & ~PTE_P;       
80108c28:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c2b:	8b 00                	mov    (%eax),%eax
80108c2d:	83 e0 fe             	and    $0xfffffffe,%eax
80108c30:	89 c2                	mov    %eax,%edx
80108c32:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c35:	89 10                	mov    %edx,(%eax)
               p->head += 1;
80108c37:	8b 45 08             	mov    0x8(%ebp),%eax
80108c3a:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
80108c40:	8d 50 01             	lea    0x1(%eax),%edx
80108c43:	8b 45 08             	mov    0x8(%ebp),%eax
80108c46:	89 90 bc 00 00 00    	mov    %edx,0xbc(%eax)
	       p->head = p->head%CLOCKSIZE;
80108c4c:	8b 45 08             	mov    0x8(%ebp),%eax
80108c4f:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
80108c55:	99                   	cltd   
80108c56:	c1 ea 1d             	shr    $0x1d,%edx
80108c59:	01 d0                	add    %edx,%eax
80108c5b:	83 e0 07             	and    $0x7,%eax
80108c5e:	29 d0                	sub    %edx,%eax
80108c60:	89 c2                	mov    %eax,%edx
80108c62:	8b 45 08             	mov    0x8(%ebp),%eax
80108c65:	89 90 bc 00 00 00    	mov    %edx,0xbc(%eax)
	       found =1;
80108c6b:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
80108c72:	eb 41                	jmp    80108cb5 <addClock+0x1f6>
          }
  //     //else //acces bit is 1//
          else{
  //       //set acces bit to 0 
          *pte = *pte & ~PTE_A;
80108c74:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c77:	8b 00                	mov    (%eax),%eax
80108c79:	83 e0 df             	and    $0xffffffdf,%eax
80108c7c:	89 c2                	mov    %eax,%edx
80108c7e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c81:	89 10                	mov    %edx,(%eax)
           p->head += 1;
80108c83:	8b 45 08             	mov    0x8(%ebp),%eax
80108c86:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
80108c8c:	8d 50 01             	lea    0x1(%eax),%edx
80108c8f:	8b 45 08             	mov    0x8(%ebp),%eax
80108c92:	89 90 bc 00 00 00    	mov    %edx,0xbc(%eax)
          cur_va = p->clock[head%CLOCKSIZE].addr;
80108c98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108c9b:	99                   	cltd   
80108c9c:	c1 ea 1d             	shr    $0x1d,%edx
80108c9f:	01 d0                	add    %edx,%eax
80108ca1:	83 e0 07             	and    $0x7,%eax
80108ca4:	29 d0                	sub    %edx,%eax
80108ca6:	89 c2                	mov    %eax,%edx
80108ca8:	8b 45 08             	mov    0x8(%ebp),%eax
80108cab:	83 c2 0e             	add    $0xe,%edx
80108cae:	8b 44 d0 0c          	mov    0xc(%eax,%edx,8),%eax
80108cb2:	89 45 f0             	mov    %eax,-0x10(%ebp)
         while(!found){
80108cb5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108cb9:	0f 84 ef fe ff ff    	je     80108bae <addClock+0xef>
          }
  }


        return 0;
80108cbf:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108cc4:	c9                   	leave  
80108cc5:	c3                   	ret    

80108cc6 <mdecrypt>:




int mdecrypt(char *virtual_addr) {
80108cc6:	f3 0f 1e fb          	endbr32 
80108cca:	55                   	push   %ebp
80108ccb:	89 e5                	mov    %esp,%ebp
80108ccd:	83 ec 48             	sub    $0x48,%esp
  cprintf("p4Debug:  mdecrypt VPN %d, %p, pid %d\n", PPN(virtual_addr), virtual_addr, myproc()->pid);
80108cd0:	e8 24 b8 ff ff       	call   801044f9 <myproc>
80108cd5:	8b 40 10             	mov    0x10(%eax),%eax
80108cd8:	8b 55 08             	mov    0x8(%ebp),%edx
80108cdb:	c1 ea 0c             	shr    $0xc,%edx
80108cde:	50                   	push   %eax
80108cdf:	ff 75 08             	pushl  0x8(%ebp)
80108ce2:	52                   	push   %edx
80108ce3:	68 b8 9e 10 80       	push   $0x80109eb8
80108ce8:	e8 2b 77 ff ff       	call   80100418 <cprintf>
80108ced:	83 c4 10             	add    $0x10,%esp
  //p4Debug: virtual_addr is a virtual address in this PID's userspace.
  struct proc * p = myproc();
80108cf0:	e8 04 b8 ff ff       	call   801044f9 <myproc>
80108cf5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  pde_t* mypd = p->pgdir;
80108cf8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108cfb:	8b 40 04             	mov    0x4(%eax),%eax
80108cfe:	89 45 d0             	mov    %eax,-0x30(%ebp)
  //set the present bit to true and encrypt bit to false
  pte_t * pte = walkpgdir(mypd, virtual_addr, 0);
80108d01:	83 ec 04             	sub    $0x4,%esp
80108d04:	6a 00                	push   $0x0
80108d06:	ff 75 08             	pushl  0x8(%ebp)
80108d09:	ff 75 d0             	pushl  -0x30(%ebp)
80108d0c:	e8 68 f2 ff ff       	call   80107f79 <walkpgdir>
80108d11:	83 c4 10             	add    $0x10,%esp
80108d14:	89 45 cc             	mov    %eax,-0x34(%ebp)

  if (!pte || *pte == 0) {
80108d17:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108d1b:	74 09                	je     80108d26 <mdecrypt+0x60>
80108d1d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108d20:	8b 00                	mov    (%eax),%eax
80108d22:	85 c0                	test   %eax,%eax
80108d24:	75 1a                	jne    80108d40 <mdecrypt+0x7a>
    cprintf("p4Debug: walkpgdir failed\n");
80108d26:	83 ec 0c             	sub    $0xc,%esp
80108d29:	68 df 9e 10 80       	push   $0x80109edf
80108d2e:	e8 e5 76 ff ff       	call   80100418 <cprintf>
80108d33:	83 c4 10             	add    $0x10,%esp
    return -1;
80108d36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d3b:	e9 eb 02 00 00       	jmp    8010902b <mdecrypt+0x365>
  }
  
  //CHECK IF QUEUE IS FULL
  int i=0;
80108d40:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  int k = 0;
80108d47:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  int empty = 0;
80108d4e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for (int i = p->head; k < CLOCKSIZE; k++,i++){
80108d55:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108d58:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
80108d5e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108d61:	eb 34                	jmp    80108d97 <mdecrypt+0xd1>
    if(p->clock[i + k%CLOCKSIZE].ref){
80108d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d66:	99                   	cltd   
80108d67:	c1 ea 1d             	shr    $0x1d,%edx
80108d6a:	01 d0                	add    %edx,%eax
80108d6c:	83 e0 07             	and    $0x7,%eax
80108d6f:	29 d0                	sub    %edx,%eax
80108d71:	89 c2                	mov    %eax,%edx
80108d73:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d76:	01 c2                	add    %eax,%edx
80108d78:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108d7b:	83 c2 0e             	add    $0xe,%edx
80108d7e:	8b 44 d0 10          	mov    0x10(%eax,%edx,8),%eax
80108d82:	85 c0                	test   %eax,%eax
80108d84:	74 09                	je     80108d8f <mdecrypt+0xc9>
      empty = 1;
80108d86:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      break;
80108d8d:	eb 0e                	jmp    80108d9d <mdecrypt+0xd7>
  for (int i = p->head; k < CLOCKSIZE; k++,i++){
80108d8f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108d93:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108d97:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80108d9b:	7e c6                	jle    80108d63 <mdecrypt+0x9d>
    }
  }
  
  if (!empty){
80108d9d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108da1:	75 69                	jne    80108e0c <mdecrypt+0x146>
    if(p->clock[i%CLOCKSIZE].addr == NULL){
80108da3:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108da6:	99                   	cltd   
80108da7:	c1 ea 1d             	shr    $0x1d,%edx
80108daa:	01 d0                	add    %edx,%eax
80108dac:	83 e0 07             	and    $0x7,%eax
80108daf:	29 d0                	sub    %edx,%eax
80108db1:	89 c2                	mov    %eax,%edx
80108db3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108db6:	83 c2 0e             	add    $0xe,%edx
80108db9:	8b 44 d0 0c          	mov    0xc(%eax,%edx,8),%eax
80108dbd:	85 c0                	test   %eax,%eax
80108dbf:	0f 85 1f 01 00 00    	jne    80108ee4 <mdecrypt+0x21e>
      p->clock[i%CLOCKSIZE].addr = (char*)PGROUNDDOWN((uint)virtual_addr);
80108dc5:	8b 45 08             	mov    0x8(%ebp),%eax
80108dc8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108dcd:	89 c1                	mov    %eax,%ecx
80108dcf:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108dd2:	99                   	cltd   
80108dd3:	c1 ea 1d             	shr    $0x1d,%edx
80108dd6:	01 d0                	add    %edx,%eax
80108dd8:	83 e0 07             	and    $0x7,%eax
80108ddb:	29 d0                	sub    %edx,%eax
80108ddd:	89 c2                	mov    %eax,%edx
80108ddf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108de2:	83 c2 0e             	add    $0xe,%edx
80108de5:	89 4c d0 0c          	mov    %ecx,0xc(%eax,%edx,8)
      p->clock[i%CLOCKSIZE].ref = 1;
80108de9:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108dec:	99                   	cltd   
80108ded:	c1 ea 1d             	shr    $0x1d,%edx
80108df0:	01 d0                	add    %edx,%eax
80108df2:	83 e0 07             	and    $0x7,%eax
80108df5:	29 d0                	sub    %edx,%eax
80108df7:	89 c2                	mov    %eax,%edx
80108df9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108dfc:	83 c2 0e             	add    $0xe,%edx
80108dff:	c7 44 d0 10 01 00 00 	movl   $0x1,0x10(%eax,%edx,8)
80108e06:	00 
80108e07:	e9 d8 00 00 00       	jmp    80108ee4 <mdecrypt+0x21e>
    }
  } else {
      int i = p->head;
80108e0c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108e0f:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
80108e15:	89 45 e8             	mov    %eax,-0x18(%ebp)
      pte_t *pte_updated = walkpgdir(p->pgdir, p->clock[i].addr,0);
80108e18:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108e1b:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108e1e:	83 c2 0e             	add    $0xe,%edx
80108e21:	8b 54 d0 0c          	mov    0xc(%eax,%edx,8),%edx
80108e25:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108e28:	8b 40 04             	mov    0x4(%eax),%eax
80108e2b:	83 ec 04             	sub    $0x4,%esp
80108e2e:	6a 00                	push   $0x0
80108e30:	52                   	push   %edx
80108e31:	50                   	push   %eax
80108e32:	e8 42 f1 ff ff       	call   80107f79 <walkpgdir>
80108e37:	83 c4 10             	add    $0x10,%esp
80108e3a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      while(*pte_updated & PTE_A){
80108e3d:	eb 45                	jmp    80108e84 <mdecrypt+0x1be>
        *pte_updated = *pte_updated & ~PTE_A;
80108e3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108e42:	8b 00                	mov    (%eax),%eax
80108e44:	83 e0 df             	and    $0xffffffdf,%eax
80108e47:	89 c2                	mov    %eax,%edx
80108e49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108e4c:	89 10                	mov    %edx,(%eax)
        i+=1;
80108e4e:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
        pte_updated = walkpgdir(p->pgdir, p->clock[i%CLOCKSIZE].addr,0);
80108e52:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e55:	99                   	cltd   
80108e56:	c1 ea 1d             	shr    $0x1d,%edx
80108e59:	01 d0                	add    %edx,%eax
80108e5b:	83 e0 07             	and    $0x7,%eax
80108e5e:	29 d0                	sub    %edx,%eax
80108e60:	89 c2                	mov    %eax,%edx
80108e62:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108e65:	83 c2 0e             	add    $0xe,%edx
80108e68:	8b 54 d0 0c          	mov    0xc(%eax,%edx,8),%edx
80108e6c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108e6f:	8b 40 04             	mov    0x4(%eax),%eax
80108e72:	83 ec 04             	sub    $0x4,%esp
80108e75:	6a 00                	push   $0x0
80108e77:	52                   	push   %edx
80108e78:	50                   	push   %eax
80108e79:	e8 fb f0 ff ff       	call   80107f79 <walkpgdir>
80108e7e:	83 c4 10             	add    $0x10,%esp
80108e81:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      while(*pte_updated & PTE_A){
80108e84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108e87:	8b 00                	mov    (%eax),%eax
80108e89:	83 e0 20             	and    $0x20,%eax
80108e8c:	85 c0                	test   %eax,%eax
80108e8e:	75 af                	jne    80108e3f <mdecrypt+0x179>
      }
      mencrypt(p->clock[i].addr,1);
80108e90:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108e93:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108e96:	83 c2 0e             	add    $0xe,%edx
80108e99:	8b 44 d0 0c          	mov    0xc(%eax,%edx,8),%eax
80108e9d:	83 ec 08             	sub    $0x8,%esp
80108ea0:	6a 01                	push   $0x1
80108ea2:	50                   	push   %eax
80108ea3:	e8 85 01 00 00       	call   8010902d <mencrypt>
80108ea8:	83 c4 10             	add    $0x10,%esp
      p->clock[i].addr = (char*)PGROUNDDOWN((uint)virtual_addr);
80108eab:	8b 45 08             	mov    0x8(%ebp),%eax
80108eae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108eb3:	89 c1                	mov    %eax,%ecx
80108eb5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108eb8:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108ebb:	83 c2 0e             	add    $0xe,%edx
80108ebe:	89 4c d0 0c          	mov    %ecx,0xc(%eax,%edx,8)
      p->head=(i+1)%CLOCKSIZE;
80108ec2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ec5:	8d 50 01             	lea    0x1(%eax),%edx
80108ec8:	89 d0                	mov    %edx,%eax
80108eca:	c1 f8 1f             	sar    $0x1f,%eax
80108ecd:	c1 e8 1d             	shr    $0x1d,%eax
80108ed0:	01 c2                	add    %eax,%edx
80108ed2:	83 e2 07             	and    $0x7,%edx
80108ed5:	29 c2                	sub    %eax,%edx
80108ed7:	89 d0                	mov    %edx,%eax
80108ed9:	89 c2                	mov    %eax,%edx
80108edb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108ede:	89 90 bc 00 00 00    	mov    %edx,0xbc(%eax)

  }

  cprintf("p4Debug: pte was %x\n", *pte);
80108ee4:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108ee7:	8b 00                	mov    (%eax),%eax
80108ee9:	83 ec 08             	sub    $0x8,%esp
80108eec:	50                   	push   %eax
80108eed:	68 fa 9e 10 80       	push   $0x80109efa
80108ef2:	e8 21 75 ff ff       	call   80100418 <cprintf>
80108ef7:	83 c4 10             	add    $0x10,%esp
  *pte = *pte & ~PTE_E;
80108efa:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108efd:	8b 00                	mov    (%eax),%eax
80108eff:	80 e4 fb             	and    $0xfb,%ah
80108f02:	89 c2                	mov    %eax,%edx
80108f04:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108f07:	89 10                	mov    %edx,(%eax)
  *pte = *pte | PTE_P;
80108f09:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108f0c:	8b 00                	mov    (%eax),%eax
80108f0e:	83 c8 01             	or     $0x1,%eax
80108f11:	89 c2                	mov    %eax,%edx
80108f13:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108f16:	89 10                	mov    %edx,(%eax)
  cprintf("p4Debug: pte is %x\n", *pte);
80108f18:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108f1b:	8b 00                	mov    (%eax),%eax
80108f1d:	83 ec 08             	sub    $0x8,%esp
80108f20:	50                   	push   %eax
80108f21:	68 0f 9f 10 80       	push   $0x80109f0f
80108f26:	e8 ed 74 ff ff       	call   80100418 <cprintf>
80108f2b:	83 c4 10             	add    $0x10,%esp
  char * original = uva2ka(mypd, virtual_addr) + OFFSET(virtual_addr);
80108f2e:	83 ec 08             	sub    $0x8,%esp
80108f31:	ff 75 08             	pushl  0x8(%ebp)
80108f34:	ff 75 d0             	pushl  -0x30(%ebp)
80108f37:	e8 21 f9 ff ff       	call   8010885d <uva2ka>
80108f3c:	83 c4 10             	add    $0x10,%esp
80108f3f:	8b 55 08             	mov    0x8(%ebp),%edx
80108f42:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
80108f48:	01 d0                	add    %edx,%eax
80108f4a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  cprintf("p4Debug: Original in decrypt was %p\n", original);
80108f4d:	83 ec 08             	sub    $0x8,%esp
80108f50:	ff 75 c4             	pushl  -0x3c(%ebp)
80108f53:	68 24 9f 10 80       	push   $0x80109f24
80108f58:	e8 bb 74 ff ff       	call   80100418 <cprintf>
80108f5d:	83 c4 10             	add    $0x10,%esp
  virtual_addr = (char *)PGROUNDDOWN((uint)virtual_addr);
80108f60:	8b 45 08             	mov    0x8(%ebp),%eax
80108f63:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f68:	89 45 08             	mov    %eax,0x8(%ebp)
  cprintf("pDebug: mdecrypt: rounded down va is %p\n", virtual_addr);
80108f6b:	83 ec 08             	sub    $0x8,%esp
80108f6e:	ff 75 08             	pushl  0x8(%ebp)
80108f71:	68 4c 9f 10 80       	push   $0x80109f4c
80108f76:	e8 9d 74 ff ff       	call   80100418 <cprintf>
80108f7b:	83 c4 10             	add    $0x10,%esp
//add to clock
//  if(inQ(p, (char*)virtual_addr)==-1)
//	  addClock(p, (char*)virtual_addr);


  for(int k=p->head; k<p->head + CLOCKSIZE; k++)
80108f7e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108f81:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
80108f87:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108f8a:	eb 2f                	jmp    80108fbb <mdecrypt+0x2f5>
              cprintf("BEFORE OUT CYCLE: %x\n", (uint)p->clock[k%CLOCKSIZE].addr);
80108f8c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f8f:	99                   	cltd   
80108f90:	c1 ea 1d             	shr    $0x1d,%edx
80108f93:	01 d0                	add    %edx,%eax
80108f95:	83 e0 07             	and    $0x7,%eax
80108f98:	29 d0                	sub    %edx,%eax
80108f9a:	89 c2                	mov    %eax,%edx
80108f9c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108f9f:	83 c2 0e             	add    $0xe,%edx
80108fa2:	8b 44 d0 0c          	mov    0xc(%eax,%edx,8),%eax
80108fa6:	83 ec 08             	sub    $0x8,%esp
80108fa9:	50                   	push   %eax
80108faa:	68 75 9f 10 80       	push   $0x80109f75
80108faf:	e8 64 74 ff ff       	call   80100418 <cprintf>
80108fb4:	83 c4 10             	add    $0x10,%esp
  for(int k=p->head; k<p->head + CLOCKSIZE; k++)
80108fb7:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108fbb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108fbe:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
80108fc4:	83 c0 07             	add    $0x7,%eax
80108fc7:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80108fca:	7e c0                	jle    80108f8c <mdecrypt+0x2c6>

  char * kvp = uva2ka(mypd, virtual_addr);
80108fcc:	83 ec 08             	sub    $0x8,%esp
80108fcf:	ff 75 08             	pushl  0x8(%ebp)
80108fd2:	ff 75 d0             	pushl  -0x30(%ebp)
80108fd5:	e8 83 f8 ff ff       	call   8010885d <uva2ka>
80108fda:	83 c4 10             	add    $0x10,%esp
80108fdd:	89 45 c0             	mov    %eax,-0x40(%ebp)
  if (!kvp || *kvp == 0) {
80108fe0:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
80108fe4:	74 0a                	je     80108ff0 <mdecrypt+0x32a>
80108fe6:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108fe9:	0f b6 00             	movzbl (%eax),%eax
80108fec:	84 c0                	test   %al,%al
80108fee:	75 07                	jne    80108ff7 <mdecrypt+0x331>
    return -1;
80108ff0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108ff5:	eb 34                	jmp    8010902b <mdecrypt+0x365>
  }
  char * slider = virtual_addr;
80108ff7:	8b 45 08             	mov    0x8(%ebp),%eax
80108ffa:	89 45 dc             	mov    %eax,-0x24(%ebp)
  for (int offset = 0; offset < PGSIZE; offset++) {
80108ffd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
80109004:	eb 17                	jmp    8010901d <mdecrypt+0x357>
    *slider = *slider ^ 0xFF;
80109006:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109009:	0f b6 00             	movzbl (%eax),%eax
8010900c:	f7 d0                	not    %eax
8010900e:	89 c2                	mov    %eax,%edx
80109010:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109013:	88 10                	mov    %dl,(%eax)
    slider++;
80109015:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  for (int offset = 0; offset < PGSIZE; offset++) {
80109019:	83 45 d8 01          	addl   $0x1,-0x28(%ebp)
8010901d:	81 7d d8 ff 0f 00 00 	cmpl   $0xfff,-0x28(%ebp)
80109024:	7e e0                	jle    80109006 <mdecrypt+0x340>
  }

//	for(int k=p->head; k<p->head + CLOCKSIZE; k++) 
//		cprintf("OUT CYCLE: %x\n", (uint)p->clock[k%CLOCKSIZE]);
  return 0;
80109026:	b8 00 00 00 00       	mov    $0x0,%eax

 }
8010902b:	c9                   	leave  
8010902c:	c3                   	ret    

8010902d <mencrypt>:


int mencrypt(char *virtual_addr, int len) {
8010902d:	f3 0f 1e fb          	endbr32 
80109031:	55                   	push   %ebp
80109032:	89 e5                	mov    %esp,%ebp
80109034:	83 ec 38             	sub    $0x38,%esp
  cprintf("p4Debug: mencrypt: %p %d\n", virtual_addr, len);
80109037:	83 ec 04             	sub    $0x4,%esp
8010903a:	ff 75 0c             	pushl  0xc(%ebp)
8010903d:	ff 75 08             	pushl  0x8(%ebp)
80109040:	68 8b 9f 10 80       	push   $0x80109f8b
80109045:	e8 ce 73 ff ff       	call   80100418 <cprintf>
8010904a:	83 c4 10             	add    $0x10,%esp
  //the given pointer is a virtual address in this pid's userspace
  struct proc * p = myproc();
8010904d:	e8 a7 b4 ff ff       	call   801044f9 <myproc>
80109052:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  pde_t* mypd = p->pgdir;
80109055:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109058:	8b 40 04             	mov    0x4(%eax),%eax
8010905b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  

  //if we encrypt, we kick a page out of the queue --
  //find a page, check it actually is in queue, set it to 0
 virtual_addr = (char *)PGROUNDDOWN((uint)virtual_addr);
8010905e:	8b 45 08             	mov    0x8(%ebp),%eax
80109061:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109066:	89 45 08             	mov    %eax,0x8(%ebp)

  //error checking first. all or nothing.
  char * slider = virtual_addr;
80109069:	8b 45 08             	mov    0x8(%ebp),%eax
8010906c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
8010906f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109076:	eb 55                	jmp    801090cd <mencrypt+0xa0>
    //check page table for each translation first
    char * kvp = uva2ka(mypd, slider);
80109078:	83 ec 08             	sub    $0x8,%esp
8010907b:	ff 75 f4             	pushl  -0xc(%ebp)
8010907e:	ff 75 e0             	pushl  -0x20(%ebp)
80109081:	e8 d7 f7 ff ff       	call   8010885d <uva2ka>
80109086:	83 c4 10             	add    $0x10,%esp
80109089:	89 45 cc             	mov    %eax,-0x34(%ebp)
    cprintf("p4Debug: slider %p, kvp for err check is %p\n",slider, kvp);
8010908c:	83 ec 04             	sub    $0x4,%esp
8010908f:	ff 75 cc             	pushl  -0x34(%ebp)
80109092:	ff 75 f4             	pushl  -0xc(%ebp)
80109095:	68 a8 9f 10 80       	push   $0x80109fa8
8010909a:	e8 79 73 ff ff       	call   80100418 <cprintf>
8010909f:	83 c4 10             	add    $0x10,%esp
    if (!kvp) {
801090a2:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
801090a6:	75 1a                	jne    801090c2 <mencrypt+0x95>
      cprintf("p4Debug: mencrypt: kvp = NULL\n");
801090a8:	83 ec 0c             	sub    $0xc,%esp
801090ab:	68 d8 9f 10 80       	push   $0x80109fd8
801090b0:	e8 63 73 ff ff       	call   80100418 <cprintf>
801090b5:	83 c4 10             	add    $0x10,%esp
      return -1;
801090b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801090bd:	e9 90 01 00 00       	jmp    80109252 <mencrypt+0x225>
    }
    slider = slider + PGSIZE;
801090c2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
801090c9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801090cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090d0:	3b 45 0c             	cmp    0xc(%ebp),%eax
801090d3:	7c a3                	jl     80109078 <mencrypt+0x4b>
  }

  //encrypt stage. Have to do this before setting flag 
  //or else we'll page fault
  slider = virtual_addr;
801090d5:	8b 45 08             	mov    0x8(%ebp),%eax
801090d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int i = 0; i < len; i++) {
801090db:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801090e2:	e9 0e 01 00 00       	jmp    801091f5 <mencrypt+0x1c8>
    cprintf("p4Debug: mencryptr: VPN %d, %p\n", PPN(slider), slider);
801090e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090ea:	c1 e8 0c             	shr    $0xc,%eax
801090ed:	83 ec 04             	sub    $0x4,%esp
801090f0:	ff 75 f4             	pushl  -0xc(%ebp)
801090f3:	50                   	push   %eax
801090f4:	68 f8 9f 10 80       	push   $0x80109ff8
801090f9:	e8 1a 73 ff ff       	call   80100418 <cprintf>
801090fe:	83 c4 10             	add    $0x10,%esp
    //kvp = kernel virtual pointer
    //virtual address in kernel space that maps to the given pointer
    char * kvp = uva2ka(mypd, slider);
80109101:	83 ec 08             	sub    $0x8,%esp
80109104:	ff 75 f4             	pushl  -0xc(%ebp)
80109107:	ff 75 e0             	pushl  -0x20(%ebp)
8010910a:	e8 4e f7 ff ff       	call   8010885d <uva2ka>
8010910f:	83 c4 10             	add    $0x10,%esp
80109112:	89 45 d8             	mov    %eax,-0x28(%ebp)
    cprintf("p4Debug: kvp for encrypt stage is %p\n", kvp);
80109115:	83 ec 08             	sub    $0x8,%esp
80109118:	ff 75 d8             	pushl  -0x28(%ebp)
8010911b:	68 18 a0 10 80       	push   $0x8010a018
80109120:	e8 f3 72 ff ff       	call   80100418 <cprintf>
80109125:	83 c4 10             	add    $0x10,%esp
    pte_t * mypte = walkpgdir(mypd, slider, 0);
80109128:	83 ec 04             	sub    $0x4,%esp
8010912b:	6a 00                	push   $0x0
8010912d:	ff 75 f4             	pushl  -0xc(%ebp)
80109130:	ff 75 e0             	pushl  -0x20(%ebp)
80109133:	e8 41 ee ff ff       	call   80107f79 <walkpgdir>
80109138:	83 c4 10             	add    $0x10,%esp
8010913b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    cprintf("p4Debug: pte is %x\n", *mypte);
8010913e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109141:	8b 00                	mov    (%eax),%eax
80109143:	83 ec 08             	sub    $0x8,%esp
80109146:	50                   	push   %eax
80109147:	68 0f 9f 10 80       	push   $0x80109f0f
8010914c:	e8 c7 72 ff ff       	call   80100418 <cprintf>
80109151:	83 c4 10             	add    $0x10,%esp
    if (*mypte & PTE_E) {
80109154:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109157:	8b 00                	mov    (%eax),%eax
80109159:	25 00 04 00 00       	and    $0x400,%eax
8010915e:	85 c0                	test   %eax,%eax
80109160:	74 1d                	je     8010917f <mencrypt+0x152>
     cprintf("p4Debug: already encrypted\n");
80109162:	83 ec 0c             	sub    $0xc,%esp
80109165:	68 3e a0 10 80       	push   $0x8010a03e
8010916a:	e8 a9 72 ff ff       	call   80100418 <cprintf>
8010916f:	83 c4 10             	add    $0x10,%esp
      slider += PGSIZE;
80109172:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  for (int i = 0; i < len; i++) {
80109179:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010917d:	eb 76                	jmp    801091f5 <mencrypt+0x1c8>
      continue;
    }
    for (int offset = 0; offset < PGSIZE; offset++) {
8010917f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
80109186:	eb 17                	jmp    8010919f <mencrypt+0x172>
      *slider = *slider ^ 0xFF;
80109188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010918b:	0f b6 00             	movzbl (%eax),%eax
8010918e:	f7 d0                	not    %eax
80109190:	89 c2                	mov    %eax,%edx
80109192:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109195:	88 10                	mov    %dl,(%eax)
      slider++;
80109197:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    for (int offset = 0; offset < PGSIZE; offset++) {
8010919b:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
8010919f:	81 7d e8 ff 0f 00 00 	cmpl   $0xfff,-0x18(%ebp)
801091a6:	7e e0                	jle    80109188 <mencrypt+0x15b>
    }
    char * kvp_translated = translate_and_set(mypd, slider-PGSIZE);
801091a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091ab:	2d 00 10 00 00       	sub    $0x1000,%eax
801091b0:	83 ec 08             	sub    $0x8,%esp
801091b3:	50                   	push   %eax
801091b4:	ff 75 e0             	pushl  -0x20(%ebp)
801091b7:	e8 9c f7 ff ff       	call   80108958 <translate_and_set>
801091bc:	83 c4 10             	add    $0x10,%esp
801091bf:	89 45 d0             	mov    %eax,-0x30(%ebp)
    if (!kvp_translated) {
801091c2:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
801091c6:	75 17                	jne    801091df <mencrypt+0x1b2>
      cprintf("p4Debug: translate failed!");
801091c8:	83 ec 0c             	sub    $0xc,%esp
801091cb:	68 5a a0 10 80       	push   $0x8010a05a
801091d0:	e8 43 72 ff ff       	call   80100418 <cprintf>
801091d5:	83 c4 10             	add    $0x10,%esp
      return -1;
801091d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801091dd:	eb 73                	jmp    80109252 <mencrypt+0x225>
    }
   *mypte = *mypte & ~PTE_A;  
801091df:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801091e2:	8b 00                	mov    (%eax),%eax
801091e4:	83 e0 df             	and    $0xffffffdf,%eax
801091e7:	89 c2                	mov    %eax,%edx
801091e9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801091ec:	89 10                	mov    %edx,(%eax)
return 0;
801091ee:	b8 00 00 00 00       	mov    $0x0,%eax
801091f3:	eb 5d                	jmp    80109252 <mencrypt+0x225>
  for (int i = 0; i < len; i++) {
801091f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091f8:	3b 45 0c             	cmp    0xc(%ebp),%eax
801091fb:	0f 8c e6 fe ff ff    	jl     801090e7 <mencrypt+0xba>
  }

int ind = inQ(p, virtual_addr);
80109201:	83 ec 08             	sub    $0x8,%esp
80109204:	ff 75 08             	pushl  0x8(%ebp)
80109207:	ff 75 e4             	pushl  -0x1c(%ebp)
8010920a:	e8 3c f8 ff ff       	call   80108a4b <inQ>
8010920f:	83 c4 10             	add    $0x10,%esp
80109212:	89 45 dc             	mov    %eax,-0x24(%ebp)
if(ind!=-1)
80109215:	83 7d dc ff          	cmpl   $0xffffffff,-0x24(%ebp)
80109219:	74 21                	je     8010923c <mencrypt+0x20f>
{
        p->clock[ind].addr=0;
8010921b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010921e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80109221:	83 c2 0e             	add    $0xe,%edx
80109224:	c7 44 d0 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,8)
8010922b:	00 
	//p->head  = (ind+1)%CLOCKSIZE;
               cprintf("=========change head 3\n");
8010922c:	83 ec 0c             	sub    $0xc,%esp
8010922f:	68 75 a0 10 80       	push   $0x8010a075
80109234:	e8 df 71 ff ff       	call   80100418 <cprintf>
80109239:	83 c4 10             	add    $0x10,%esp

}

  switchuvm(myproc());
8010923c:	e8 b8 b2 ff ff       	call   801044f9 <myproc>
80109241:	83 ec 0c             	sub    $0xc,%esp
80109244:	50                   	push   %eax
80109245:	e8 56 ef ff ff       	call   801081a0 <switchuvm>
8010924a:	83 c4 10             	add    $0x10,%esp
  return 0; 
8010924d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109252:	c9                   	leave  
80109253:	c3                   	ret    

80109254 <getpgtable>:

int getpgtable(struct pt_entry* pt_entries, int num, int wsetOnly) {
80109254:	f3 0f 1e fb          	endbr32 
80109258:	55                   	push   %ebp
80109259:	89 e5                	mov    %esp,%ebp
8010925b:	83 ec 28             	sub    $0x28,%esp
	cprintf("p4Debug: getpgtable: %p, %d\n", pt_entries, num);
8010925e:	83 ec 04             	sub    $0x4,%esp
80109261:	ff 75 0c             	pushl  0xc(%ebp)
80109264:	ff 75 08             	pushl  0x8(%ebp)
80109267:	68 8d a0 10 80       	push   $0x8010a08d
8010926c:	e8 a7 71 ff ff       	call   80100418 <cprintf>
80109271:	83 c4 10             	add    $0x10,%esp
  struct proc *curproc = myproc();
80109274:	e8 80 b2 ff ff       	call   801044f9 <myproc>
80109279:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pde_t *pgdir = curproc->pgdir;
8010927c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010927f:	8b 40 04             	mov    0x4(%eax),%eax
80109282:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint uva = 0;
80109285:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if (curproc->sz % PGSIZE == 0)
8010928c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010928f:	8b 00                	mov    (%eax),%eax
80109291:	25 ff 0f 00 00       	and    $0xfff,%eax
80109296:	85 c0                	test   %eax,%eax
80109298:	75 0f                	jne    801092a9 <getpgtable+0x55>
    uva = curproc->sz - PGSIZE;
8010929a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010929d:	8b 00                	mov    (%eax),%eax
8010929f:	2d 00 10 00 00       	sub    $0x1000,%eax
801092a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801092a7:	eb 0d                	jmp    801092b6 <getpgtable+0x62>
  else 
    uva = PGROUNDDOWN(curproc->sz);
801092a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801092ac:	8b 00                	mov    (%eax),%eax
801092ae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801092b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  int i = 0;
801092b6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  for (;;uva -=PGSIZE)
  {
    cprintf("THIS IS UVA %x\n",uva);
801092bd:	83 ec 08             	sub    $0x8,%esp
801092c0:	ff 75 f4             	pushl  -0xc(%ebp)
801092c3:	68 aa a0 10 80       	push   $0x8010a0aa
801092c8:	e8 4b 71 ff ff       	call   80100418 <cprintf>
801092cd:	83 c4 10             	add    $0x10,%esp
    pte_t *pte = walkpgdir(pgdir, (const void *)uva, 0);
801092d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092d3:	83 ec 04             	sub    $0x4,%esp
801092d6:	6a 00                	push   $0x0
801092d8:	50                   	push   %eax
801092d9:	ff 75 e8             	pushl  -0x18(%ebp)
801092dc:	e8 98 ec ff ff       	call   80107f79 <walkpgdir>
801092e1:	83 c4 10             	add    $0x10,%esp
801092e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	  char* check =(char *) uva;
801092e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if(wsetOnly && inQ(curproc, check)==-1)
801092ed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801092f1:	74 33                	je     80109326 <getpgtable+0xd2>
801092f3:	83 ec 08             	sub    $0x8,%esp
801092f6:	ff 75 e0             	pushl  -0x20(%ebp)
801092f9:	ff 75 ec             	pushl  -0x14(%ebp)
801092fc:	e8 4a f7 ff ff       	call   80108a4b <inQ>
80109301:	83 c4 10             	add    $0x10,%esp
80109304:	83 f8 ff             	cmp    $0xffffffff,%eax
80109307:	75 1d                	jne    80109326 <getpgtable+0xd2>
    { 
	    cprintf("p4Debug: this page is: %x",(uint)check);
80109309:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010930c:	83 ec 08             	sub    $0x8,%esp
8010930f:	50                   	push   %eax
80109310:	68 ba a0 10 80       	push   $0x8010a0ba
80109315:	e8 fe 70 ff ff       	call   80100418 <cprintf>
8010931a:	83 c4 10             	add    $0x10,%esp
    	    num++;
8010931d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
	    continue;
80109321:	e9 a2 01 00 00       	jmp    801094c8 <getpgtable+0x274>
    }
    if (!(*pte & PTE_U) || !(*pte & (PTE_P | PTE_E)))
80109326:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109329:	8b 00                	mov    (%eax),%eax
8010932b:	83 e0 04             	and    $0x4,%eax
8010932e:	85 c0                	test   %eax,%eax
80109330:	0f 84 91 01 00 00    	je     801094c7 <getpgtable+0x273>
80109336:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109339:	8b 00                	mov    (%eax),%eax
8010933b:	25 01 04 00 00       	and    $0x401,%eax
80109340:	85 c0                	test   %eax,%eax
80109342:	0f 84 7f 01 00 00    	je     801094c7 <getpgtable+0x273>
      continue;

    pt_entries[i].pdx = PDX(uva);
80109348:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010934b:	c1 e8 16             	shr    $0x16,%eax
8010934e:	89 c1                	mov    %eax,%ecx
80109350:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109353:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
8010935a:	8b 45 08             	mov    0x8(%ebp),%eax
8010935d:	01 c2                	add    %eax,%edx
8010935f:	89 c8                	mov    %ecx,%eax
80109361:	66 25 ff 03          	and    $0x3ff,%ax
80109365:	66 25 ff 03          	and    $0x3ff,%ax
80109369:	89 c1                	mov    %eax,%ecx
8010936b:	0f b7 02             	movzwl (%edx),%eax
8010936e:	66 25 00 fc          	and    $0xfc00,%ax
80109372:	09 c8                	or     %ecx,%eax
80109374:	66 89 02             	mov    %ax,(%edx)
    pt_entries[i].ptx = PTX(uva);
80109377:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010937a:	c1 e8 0c             	shr    $0xc,%eax
8010937d:	89 c1                	mov    %eax,%ecx
8010937f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109382:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80109389:	8b 45 08             	mov    0x8(%ebp),%eax
8010938c:	01 c2                	add    %eax,%edx
8010938e:	89 c8                	mov    %ecx,%eax
80109390:	66 25 ff 03          	and    $0x3ff,%ax
80109394:	0f b7 c0             	movzwl %ax,%eax
80109397:	25 ff 03 00 00       	and    $0x3ff,%eax
8010939c:	c1 e0 0a             	shl    $0xa,%eax
8010939f:	89 c1                	mov    %eax,%ecx
801093a1:	8b 02                	mov    (%edx),%eax
801093a3:	25 ff 03 f0 ff       	and    $0xfff003ff,%eax
801093a8:	09 c8                	or     %ecx,%eax
801093aa:	89 02                	mov    %eax,(%edx)
    pt_entries[i].ppage = *pte >> PTXSHIFT;
801093ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801093af:	8b 00                	mov    (%eax),%eax
801093b1:	c1 e8 0c             	shr    $0xc,%eax
801093b4:	89 c2                	mov    %eax,%edx
801093b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093b9:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
801093c0:	8b 45 08             	mov    0x8(%ebp),%eax
801093c3:	01 c8                	add    %ecx,%eax
801093c5:	81 e2 ff ff 0f 00    	and    $0xfffff,%edx
801093cb:	89 d1                	mov    %edx,%ecx
801093cd:	81 e1 ff ff 0f 00    	and    $0xfffff,%ecx
801093d3:	8b 50 04             	mov    0x4(%eax),%edx
801093d6:	81 e2 00 00 f0 ff    	and    $0xfff00000,%edx
801093dc:	09 ca                	or     %ecx,%edx
801093de:	89 50 04             	mov    %edx,0x4(%eax)
    pt_entries[i].present = *pte & PTE_P;
801093e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801093e4:	8b 08                	mov    (%eax),%ecx
801093e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093e9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
801093f0:	8b 45 08             	mov    0x8(%ebp),%eax
801093f3:	01 c2                	add    %eax,%edx
801093f5:	89 c8                	mov    %ecx,%eax
801093f7:	83 e0 01             	and    $0x1,%eax
801093fa:	83 e0 01             	and    $0x1,%eax
801093fd:	c1 e0 04             	shl    $0x4,%eax
80109400:	89 c1                	mov    %eax,%ecx
80109402:	0f b6 42 06          	movzbl 0x6(%edx),%eax
80109406:	83 e0 ef             	and    $0xffffffef,%eax
80109409:	09 c8                	or     %ecx,%eax
8010940b:	88 42 06             	mov    %al,0x6(%edx)
    pt_entries[i].writable = (*pte & PTE_W) > 0;
8010940e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109411:	8b 00                	mov    (%eax),%eax
80109413:	83 e0 02             	and    $0x2,%eax
80109416:	89 c2                	mov    %eax,%edx
80109418:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010941b:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80109422:	8b 45 08             	mov    0x8(%ebp),%eax
80109425:	01 c8                	add    %ecx,%eax
80109427:	85 d2                	test   %edx,%edx
80109429:	0f 95 c2             	setne  %dl
8010942c:	83 e2 01             	and    $0x1,%edx
8010942f:	89 d1                	mov    %edx,%ecx
80109431:	c1 e1 05             	shl    $0x5,%ecx
80109434:	0f b6 50 06          	movzbl 0x6(%eax),%edx
80109438:	83 e2 df             	and    $0xffffffdf,%edx
8010943b:	09 ca                	or     %ecx,%edx
8010943d:	88 50 06             	mov    %dl,0x6(%eax)
    pt_entries[i].encrypted = (*pte & PTE_E) > 0;
80109440:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109443:	8b 00                	mov    (%eax),%eax
80109445:	25 00 04 00 00       	and    $0x400,%eax
8010944a:	89 c2                	mov    %eax,%edx
8010944c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010944f:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80109456:	8b 45 08             	mov    0x8(%ebp),%eax
80109459:	01 c8                	add    %ecx,%eax
8010945b:	85 d2                	test   %edx,%edx
8010945d:	0f 95 c2             	setne  %dl
80109460:	89 d1                	mov    %edx,%ecx
80109462:	c1 e1 07             	shl    $0x7,%ecx
80109465:	0f b6 50 06          	movzbl 0x6(%eax),%edx
80109469:	83 e2 7f             	and    $0x7f,%edx
8010946c:	09 ca                	or     %ecx,%edx
8010946e:	88 50 06             	mov    %dl,0x6(%eax)
//*pte = (*pte & PTE_A);
    pt_entries[i].ref = (*pte & PTE_A) > 0;
80109471:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109474:	8b 00                	mov    (%eax),%eax
80109476:	83 e0 20             	and    $0x20,%eax
80109479:	89 c2                	mov    %eax,%edx
8010947b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010947e:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80109485:	8b 45 08             	mov    0x8(%ebp),%eax
80109488:	01 c8                	add    %ecx,%eax
8010948a:	85 d2                	test   %edx,%edx
8010948c:	0f 95 c2             	setne  %dl
8010948f:	89 d1                	mov    %edx,%ecx
80109491:	83 e1 01             	and    $0x1,%ecx
80109494:	0f b6 50 07          	movzbl 0x7(%eax),%edx
80109498:	83 e2 fe             	and    $0xfffffffe,%edx
8010949b:	09 ca                	or     %ecx,%edx
8010949d:	88 50 07             	mov    %dl,0x7(%eax)
    //PT_A flag needs to be modified as per clock algo.
    i ++;
801094a0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    if (uva == 0 || i == num) { cprintf("get page table i = %d\n", i); break;}
801094a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801094a8:	74 08                	je     801094b2 <getpgtable+0x25e>
801094aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094ad:	3b 45 0c             	cmp    0xc(%ebp),%eax
801094b0:	75 16                	jne    801094c8 <getpgtable+0x274>
801094b2:	83 ec 08             	sub    $0x8,%esp
801094b5:	ff 75 f0             	pushl  -0x10(%ebp)
801094b8:	68 d4 a0 10 80       	push   $0x8010a0d4
801094bd:	e8 56 6f ff ff       	call   80100418 <cprintf>
801094c2:	83 c4 10             	add    $0x10,%esp
801094c5:	eb 0d                	jmp    801094d4 <getpgtable+0x280>
      continue;
801094c7:	90                   	nop
  for (;;uva -=PGSIZE)
801094c8:	81 6d f4 00 10 00 00 	subl   $0x1000,-0xc(%ebp)
  {
801094cf:	e9 e9 fd ff ff       	jmp    801092bd <getpgtable+0x69>

  }
  
  return i;
801094d4:	8b 45 f0             	mov    -0x10(%ebp),%eax

}
801094d7:	c9                   	leave  
801094d8:	c3                   	ret    

801094d9 <dump_rawphymem>:


int dump_rawphymem(char *physical_addr, char * buffer) {
801094d9:	f3 0f 1e fb          	endbr32 
801094dd:	55                   	push   %ebp
801094de:	89 e5                	mov    %esp,%ebp
801094e0:	56                   	push   %esi
801094e1:	53                   	push   %ebx
801094e2:	83 ec 10             	sub    $0x10,%esp
  *buffer = *buffer;
801094e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801094e8:	0f b6 10             	movzbl (%eax),%edx
801094eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801094ee:	88 10                	mov    %dl,(%eax)
  cprintf("p4Debug: dump_rawphymem: %p, %p\n", physical_addr, buffer);
801094f0:	83 ec 04             	sub    $0x4,%esp
801094f3:	ff 75 0c             	pushl  0xc(%ebp)
801094f6:	ff 75 08             	pushl  0x8(%ebp)
801094f9:	68 ec a0 10 80       	push   $0x8010a0ec
801094fe:	e8 15 6f ff ff       	call   80100418 <cprintf>
80109503:	83 c4 10             	add    $0x10,%esp
  int retval = copyout(myproc()->pgdir, (uint) buffer, (void *) PGROUNDDOWN((int)P2V(physical_addr)), PGSIZE);
80109506:	8b 45 08             	mov    0x8(%ebp),%eax
80109509:	05 00 00 00 80       	add    $0x80000000,%eax
8010950e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109513:	89 c6                	mov    %eax,%esi
80109515:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80109518:	e8 dc af ff ff       	call   801044f9 <myproc>
8010951d:	8b 40 04             	mov    0x4(%eax),%eax
80109520:	68 00 10 00 00       	push   $0x1000
80109525:	56                   	push   %esi
80109526:	53                   	push   %ebx
80109527:	50                   	push   %eax
80109528:	e8 89 f3 ff ff       	call   801088b6 <copyout>
8010952d:	83 c4 10             	add    $0x10,%esp
80109530:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (retval)
80109533:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109537:	74 07                	je     80109540 <dump_rawphymem+0x67>
    return -1;
80109539:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010953e:	eb 05                	jmp    80109545 <dump_rawphymem+0x6c>
  return 0;
80109540:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109545:	8d 65 f8             	lea    -0x8(%ebp),%esp
80109548:	5b                   	pop    %ebx
80109549:	5e                   	pop    %esi
8010954a:	5d                   	pop    %ebp
8010954b:	c3                   	ret    
