
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
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
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
80100028:	bc 50 c6 10 80       	mov    $0x8010c650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 7d 34 10 80       	mov    $0x8010347d,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 34 81 10 80       	push   $0x80108134
80100042:	68 60 c6 10 80       	push   $0x8010c660
80100047:	e8 11 4c 00 00       	call   80104c5d <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 90 db 10 80 84 	movl   $0x8010db84,0x8010db90
80100056:	db 10 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 94 db 10 80 84 	movl   $0x8010db84,0x8010db94
80100060:	db 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 94 c6 10 80 	movl   $0x8010c694,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 94 db 10 80    	mov    0x8010db94,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c 84 db 10 80 	movl   $0x8010db84,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 94 db 10 80       	mov    0x8010db94,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 94 db 10 80       	mov    %eax,0x8010db94
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 84 db 10 80       	mov    $0x8010db84,%eax
801000ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ae:	72 bc                	jb     8010006c <binit+0x38>
  }
}
801000b0:	90                   	nop
801000b1:	c9                   	leave  
801000b2:	c3                   	ret    

801000b3 <bget>:
// Look through buffer cache for sector on device dev.
// If not found, allocate fresh block.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint sector)
{
801000b3:	55                   	push   %ebp
801000b4:	89 e5                	mov    %esp,%ebp
801000b6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b9:	83 ec 0c             	sub    $0xc,%esp
801000bc:	68 60 c6 10 80       	push   $0x8010c660
801000c1:	e8 b9 4b 00 00       	call   80104c7f <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c9:	a1 94 db 10 80       	mov    0x8010db94,%eax
801000ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d1:	eb 67                	jmp    8010013a <bget+0x87>
    if(b->dev == dev && b->sector == sector){
801000d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d6:	8b 40 04             	mov    0x4(%eax),%eax
801000d9:	3b 45 08             	cmp    0x8(%ebp),%eax
801000dc:	75 53                	jne    80100131 <bget+0x7e>
801000de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e1:	8b 40 08             	mov    0x8(%eax),%eax
801000e4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e7:	75 48                	jne    80100131 <bget+0x7e>
      if(!(b->flags & B_BUSY)){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 00                	mov    (%eax),%eax
801000ee:	83 e0 01             	and    $0x1,%eax
801000f1:	85 c0                	test   %eax,%eax
801000f3:	75 27                	jne    8010011c <bget+0x69>
        b->flags |= B_BUSY;
801000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f8:	8b 00                	mov    (%eax),%eax
801000fa:	83 c8 01             	or     $0x1,%eax
801000fd:	89 c2                	mov    %eax,%edx
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
80100104:	83 ec 0c             	sub    $0xc,%esp
80100107:	68 60 c6 10 80       	push   $0x8010c660
8010010c:	e8 d5 4b 00 00       	call   80104ce6 <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 60 c6 10 80       	push   $0x8010c660
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 5a 48 00 00       	call   80104986 <sleep>
8010012c:	83 c4 10             	add    $0x10,%esp
      goto loop;
8010012f:	eb 98                	jmp    801000c9 <bget+0x16>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100134:	8b 40 10             	mov    0x10(%eax),%eax
80100137:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010013a:	81 7d f4 84 db 10 80 	cmpl   $0x8010db84,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100143:	a1 90 db 10 80       	mov    0x8010db90,%eax
80100148:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014b:	eb 51                	jmp    8010019e <bget+0xeb>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010014d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100150:	8b 00                	mov    (%eax),%eax
80100152:	83 e0 01             	and    $0x1,%eax
80100155:	85 c0                	test   %eax,%eax
80100157:	75 3c                	jne    80100195 <bget+0xe2>
80100159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015c:	8b 00                	mov    (%eax),%eax
8010015e:	83 e0 04             	and    $0x4,%eax
80100161:	85 c0                	test   %eax,%eax
80100163:	75 30                	jne    80100195 <bget+0xe2>
      b->dev = dev;
80100165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100168:	8b 55 08             	mov    0x8(%ebp),%edx
8010016b:	89 50 04             	mov    %edx,0x4(%eax)
      b->sector = sector;
8010016e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100171:	8b 55 0c             	mov    0xc(%ebp),%edx
80100174:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100180:	83 ec 0c             	sub    $0xc,%esp
80100183:	68 60 c6 10 80       	push   $0x8010c660
80100188:	e8 59 4b 00 00       	call   80104ce6 <release>
8010018d:	83 c4 10             	add    $0x10,%esp
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1f                	jmp    801001b4 <bget+0x101>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 0c             	mov    0xc(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 84 db 10 80 	cmpl   $0x8010db84,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
    }
  }
  panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 3b 81 10 80       	push   $0x8010813b
801001af:	e8 b2 03 00 00       	call   80100566 <panic>
}
801001b4:	c9                   	leave  
801001b5:	c3                   	ret    

801001b6 <bread>:

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
801001b6:	55                   	push   %ebp
801001b7:	89 e5                	mov    %esp,%ebp
801001b9:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, sector);
801001bc:	83 ec 08             	sub    $0x8,%esp
801001bf:	ff 75 0c             	pushl  0xc(%ebp)
801001c2:	ff 75 08             	pushl  0x8(%ebp)
801001c5:	e8 e9 fe ff ff       	call   801000b3 <bget>
801001ca:	83 c4 10             	add    $0x10,%esp
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID))
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0e                	jne    801001ea <bread+0x34>
    iderw(b);
801001dc:	83 ec 0c             	sub    $0xc,%esp
801001df:	ff 75 f4             	pushl  -0xc(%ebp)
801001e2:	e8 71 26 00 00       	call   80102858 <iderw>
801001e7:	83 c4 10             	add    $0x10,%esp
  return b;
801001ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ed:	c9                   	leave  
801001ee:	c3                   	ret    

801001ef <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001ef:	55                   	push   %ebp
801001f0:	89 e5                	mov    %esp,%ebp
801001f2:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
801001f5:	8b 45 08             	mov    0x8(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 01             	and    $0x1,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0d                	jne    8010020e <bwrite+0x1f>
    panic("bwrite");
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	68 4c 81 10 80       	push   $0x8010814c
80100209:	e8 58 03 00 00       	call   80100566 <panic>
  b->flags |= B_DIRTY;
8010020e:	8b 45 08             	mov    0x8(%ebp),%eax
80100211:	8b 00                	mov    (%eax),%eax
80100213:	83 c8 04             	or     $0x4,%eax
80100216:	89 c2                	mov    %eax,%edx
80100218:	8b 45 08             	mov    0x8(%ebp),%eax
8010021b:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021d:	83 ec 0c             	sub    $0xc,%esp
80100220:	ff 75 08             	pushl  0x8(%ebp)
80100223:	e8 30 26 00 00       	call   80102858 <iderw>
80100228:	83 c4 10             	add    $0x10,%esp
}
8010022b:	90                   	nop
8010022c:	c9                   	leave  
8010022d:	c3                   	ret    

8010022e <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022e:	55                   	push   %ebp
8010022f:	89 e5                	mov    %esp,%ebp
80100231:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100234:	8b 45 08             	mov    0x8(%ebp),%eax
80100237:	8b 00                	mov    (%eax),%eax
80100239:	83 e0 01             	and    $0x1,%eax
8010023c:	85 c0                	test   %eax,%eax
8010023e:	75 0d                	jne    8010024d <brelse+0x1f>
    panic("brelse");
80100240:	83 ec 0c             	sub    $0xc,%esp
80100243:	68 53 81 10 80       	push   $0x80108153
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 60 c6 10 80       	push   $0x8010c660
80100255:	e8 25 4a 00 00       	call   80104c7f <acquire>
8010025a:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
8010025d:	8b 45 08             	mov    0x8(%ebp),%eax
80100260:	8b 40 10             	mov    0x10(%eax),%eax
80100263:	8b 55 08             	mov    0x8(%ebp),%edx
80100266:	8b 52 0c             	mov    0xc(%edx),%edx
80100269:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
8010026c:	8b 45 08             	mov    0x8(%ebp),%eax
8010026f:	8b 40 0c             	mov    0xc(%eax),%eax
80100272:	8b 55 08             	mov    0x8(%ebp),%edx
80100275:	8b 52 10             	mov    0x10(%edx),%edx
80100278:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010027b:	8b 15 94 db 10 80    	mov    0x8010db94,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c 84 db 10 80 	movl   $0x8010db84,0xc(%eax)
  bcache.head.next->prev = b;
80100291:	a1 94 db 10 80       	mov    0x8010db94,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 94 db 10 80       	mov    %eax,0x8010db94

  b->flags &= ~B_BUSY;
801002a4:	8b 45 08             	mov    0x8(%ebp),%eax
801002a7:	8b 00                	mov    (%eax),%eax
801002a9:	83 e0 fe             	and    $0xfffffffe,%eax
801002ac:	89 c2                	mov    %eax,%edx
801002ae:	8b 45 08             	mov    0x8(%ebp),%eax
801002b1:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	ff 75 08             	pushl  0x8(%ebp)
801002b9:	e8 b3 47 00 00       	call   80104a71 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 60 c6 10 80       	push   $0x8010c660
801002c9:	e8 18 4a 00 00       	call   80104ce6 <release>
801002ce:	83 c4 10             	add    $0x10,%esp
}
801002d1:	90                   	nop
801002d2:	c9                   	leave  
801002d3:	c3                   	ret    

801002d4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d4:	55                   	push   %ebp
801002d5:	89 e5                	mov    %esp,%ebp
801002d7:	83 ec 14             	sub    $0x14,%esp
801002da:	8b 45 08             	mov    0x8(%ebp),%eax
801002dd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e5:	89 c2                	mov    %eax,%edx
801002e7:	ec                   	in     (%dx),%al
801002e8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002eb:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002ef:	c9                   	leave  
801002f0:	c3                   	ret    

801002f1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	83 ec 08             	sub    $0x8,%esp
801002f7:	8b 55 08             	mov    0x8(%ebp),%edx
801002fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801002fd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80100301:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100304:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100308:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	90                   	nop
8010030e:	c9                   	leave  
8010030f:	c3                   	ret    

80100310 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100310:	55                   	push   %ebp
80100311:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100313:	fa                   	cli    
}
80100314:	90                   	nop
80100315:	5d                   	pop    %ebp
80100316:	c3                   	ret    

80100317 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100317:	55                   	push   %ebp
80100318:	89 e5                	mov    %esp,%ebp
8010031a:	53                   	push   %ebx
8010031b:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100322:	74 1c                	je     80100340 <printint+0x29>
80100324:	8b 45 08             	mov    0x8(%ebp),%eax
80100327:	c1 e8 1f             	shr    $0x1f,%eax
8010032a:	0f b6 c0             	movzbl %al,%eax
8010032d:	89 45 10             	mov    %eax,0x10(%ebp)
80100330:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100334:	74 0a                	je     80100340 <printint+0x29>
    x = -xx;
80100336:	8b 45 08             	mov    0x8(%ebp),%eax
80100339:	f7 d8                	neg    %eax
8010033b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033e:	eb 06                	jmp    80100346 <printint+0x2f>
  else
    x = xx;
80100340:	8b 45 08             	mov    0x8(%ebp),%eax
80100343:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100350:	8d 41 01             	lea    0x1(%ecx),%eax
80100353:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100359:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035c:	ba 00 00 00 00       	mov    $0x0,%edx
80100361:	f7 f3                	div    %ebx
80100363:	89 d0                	mov    %edx,%eax
80100365:	0f b6 80 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%eax
8010036c:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
80100370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100376:	ba 00 00 00 00       	mov    $0x0,%edx
8010037b:	f7 f3                	div    %ebx
8010037d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100380:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100384:	75 c7                	jne    8010034d <printint+0x36>

  if(sign)
80100386:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038a:	74 2a                	je     801003b6 <printint+0x9f>
    buf[i++] = '-';
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010039a:	eb 1a                	jmp    801003b6 <printint+0x9f>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	0f b6 00             	movzbl (%eax),%eax
801003a7:	0f be c0             	movsbl %al,%eax
801003aa:	83 ec 0c             	sub    $0xc,%esp
801003ad:	50                   	push   %eax
801003ae:	e8 c3 03 00 00       	call   80100776 <consputc>
801003b3:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003b6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003be:	79 dc                	jns    8010039c <printint+0x85>
}
801003c0:	90                   	nop
801003c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801003c4:	c9                   	leave  
801003c5:	c3                   	ret    

801003c6 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003cc:	a1 f4 b5 10 80       	mov    0x8010b5f4,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 c0 b5 10 80       	push   $0x8010b5c0
801003e2:	e8 98 48 00 00       	call   80104c7f <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 5a 81 10 80       	push   $0x8010815a
801003f9:	e8 68 01 00 00       	call   80100566 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003fe:	8d 45 0c             	lea    0xc(%ebp),%eax
80100401:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100404:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010040b:	e9 1a 01 00 00       	jmp    8010052a <cprintf+0x164>
    if(c != '%'){
80100410:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100414:	74 13                	je     80100429 <cprintf+0x63>
      consputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	ff 75 e4             	pushl  -0x1c(%ebp)
8010041c:	e8 55 03 00 00       	call   80100776 <consputc>
80100421:	83 c4 10             	add    $0x10,%esp
      continue;
80100424:	e9 fd 00 00 00       	jmp    80100526 <cprintf+0x160>
    }
    c = fmt[++i] & 0xff;
80100429:	8b 55 08             	mov    0x8(%ebp),%edx
8010042c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100433:	01 d0                	add    %edx,%eax
80100435:	0f b6 00             	movzbl (%eax),%eax
80100438:	0f be c0             	movsbl %al,%eax
8010043b:	25 ff 00 00 00       	and    $0xff,%eax
80100440:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100443:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100447:	0f 84 ff 00 00 00    	je     8010054c <cprintf+0x186>
      break;
    switch(c){
8010044d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100450:	83 f8 70             	cmp    $0x70,%eax
80100453:	74 47                	je     8010049c <cprintf+0xd6>
80100455:	83 f8 70             	cmp    $0x70,%eax
80100458:	7f 13                	jg     8010046d <cprintf+0xa7>
8010045a:	83 f8 25             	cmp    $0x25,%eax
8010045d:	0f 84 98 00 00 00    	je     801004fb <cprintf+0x135>
80100463:	83 f8 64             	cmp    $0x64,%eax
80100466:	74 14                	je     8010047c <cprintf+0xb6>
80100468:	e9 9d 00 00 00       	jmp    8010050a <cprintf+0x144>
8010046d:	83 f8 73             	cmp    $0x73,%eax
80100470:	74 47                	je     801004b9 <cprintf+0xf3>
80100472:	83 f8 78             	cmp    $0x78,%eax
80100475:	74 25                	je     8010049c <cprintf+0xd6>
80100477:	e9 8e 00 00 00       	jmp    8010050a <cprintf+0x144>
    case 'd':
      printint(*argp++, 10, 1);
8010047c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047f:	8d 50 04             	lea    0x4(%eax),%edx
80100482:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100485:	8b 00                	mov    (%eax),%eax
80100487:	83 ec 04             	sub    $0x4,%esp
8010048a:	6a 01                	push   $0x1
8010048c:	6a 0a                	push   $0xa
8010048e:	50                   	push   %eax
8010048f:	e8 83 fe ff ff       	call   80100317 <printint>
80100494:	83 c4 10             	add    $0x10,%esp
      break;
80100497:	e9 8a 00 00 00       	jmp    80100526 <cprintf+0x160>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	83 ec 04             	sub    $0x4,%esp
801004aa:	6a 00                	push   $0x0
801004ac:	6a 10                	push   $0x10
801004ae:	50                   	push   %eax
801004af:	e8 63 fe ff ff       	call   80100317 <printint>
801004b4:	83 c4 10             	add    $0x10,%esp
      break;
801004b7:	eb 6d                	jmp    80100526 <cprintf+0x160>
    case 's':
      if((s = (char*)*argp++) == 0)
801004b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004bc:	8d 50 04             	lea    0x4(%eax),%edx
801004bf:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c2:	8b 00                	mov    (%eax),%eax
801004c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cb:	75 22                	jne    801004ef <cprintf+0x129>
        s = "(null)";
801004cd:	c7 45 ec 63 81 10 80 	movl   $0x80108163,-0x14(%ebp)
      for(; *s; s++)
801004d4:	eb 19                	jmp    801004ef <cprintf+0x129>
        consputc(*s);
801004d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d9:	0f b6 00             	movzbl (%eax),%eax
801004dc:	0f be c0             	movsbl %al,%eax
801004df:	83 ec 0c             	sub    $0xc,%esp
801004e2:	50                   	push   %eax
801004e3:	e8 8e 02 00 00       	call   80100776 <consputc>
801004e8:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
801004eb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f2:	0f b6 00             	movzbl (%eax),%eax
801004f5:	84 c0                	test   %al,%al
801004f7:	75 dd                	jne    801004d6 <cprintf+0x110>
      break;
801004f9:	eb 2b                	jmp    80100526 <cprintf+0x160>
    case '%':
      consputc('%');
801004fb:	83 ec 0c             	sub    $0xc,%esp
801004fe:	6a 25                	push   $0x25
80100500:	e8 71 02 00 00       	call   80100776 <consputc>
80100505:	83 c4 10             	add    $0x10,%esp
      break;
80100508:	eb 1c                	jmp    80100526 <cprintf+0x160>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010050a:	83 ec 0c             	sub    $0xc,%esp
8010050d:	6a 25                	push   $0x25
8010050f:	e8 62 02 00 00       	call   80100776 <consputc>
80100514:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100517:	83 ec 0c             	sub    $0xc,%esp
8010051a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010051d:	e8 54 02 00 00       	call   80100776 <consputc>
80100522:	83 c4 10             	add    $0x10,%esp
      break;
80100525:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100526:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010052a:	8b 55 08             	mov    0x8(%ebp),%edx
8010052d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100530:	01 d0                	add    %edx,%eax
80100532:	0f b6 00             	movzbl (%eax),%eax
80100535:	0f be c0             	movsbl %al,%eax
80100538:	25 ff 00 00 00       	and    $0xff,%eax
8010053d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100540:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100544:	0f 85 c6 fe ff ff    	jne    80100410 <cprintf+0x4a>
8010054a:	eb 01                	jmp    8010054d <cprintf+0x187>
      break;
8010054c:	90                   	nop
    }
  }

  if(locking)
8010054d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100551:	74 10                	je     80100563 <cprintf+0x19d>
    release(&cons.lock);
80100553:	83 ec 0c             	sub    $0xc,%esp
80100556:	68 c0 b5 10 80       	push   $0x8010b5c0
8010055b:	e8 86 47 00 00       	call   80104ce6 <release>
80100560:	83 c4 10             	add    $0x10,%esp
}
80100563:	90                   	nop
80100564:	c9                   	leave  
80100565:	c3                   	ret    

80100566 <panic>:

void
panic(char *s)
{
80100566:	55                   	push   %ebp
80100567:	89 e5                	mov    %esp,%ebp
80100569:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];
  
  cli();
8010056c:	e8 9f fd ff ff       	call   80100310 <cli>
  cons.locking = 0;
80100571:	c7 05 f4 b5 10 80 00 	movl   $0x0,0x8010b5f4
80100578:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010057b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f b6 c0             	movzbl %al,%eax
80100587:	83 ec 08             	sub    $0x8,%esp
8010058a:	50                   	push   %eax
8010058b:	68 6a 81 10 80       	push   $0x8010816a
80100590:	e8 31 fe ff ff       	call   801003c6 <cprintf>
80100595:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100598:	8b 45 08             	mov    0x8(%ebp),%eax
8010059b:	83 ec 0c             	sub    $0xc,%esp
8010059e:	50                   	push   %eax
8010059f:	e8 22 fe ff ff       	call   801003c6 <cprintf>
801005a4:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005a7:	83 ec 0c             	sub    $0xc,%esp
801005aa:	68 79 81 10 80       	push   $0x80108179
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 71 47 00 00       	call   80104d38 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 7b 81 10 80       	push   $0x8010817b
801005e3:	e8 de fd ff ff       	call   801003c6 <cprintf>
801005e8:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005ef:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005f3:	7e de                	jle    801005d3 <panic+0x6d>
  panicked = 1; // freeze other CPU
801005f5:	c7 05 a0 b5 10 80 01 	movl   $0x1,0x8010b5a0
801005fc:	00 00 00 
  for(;;)
801005ff:	eb fe                	jmp    801005ff <panic+0x99>

80100601 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100601:	55                   	push   %ebp
80100602:	89 e5                	mov    %esp,%ebp
80100604:	83 ec 18             	sub    $0x18,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100607:	6a 0e                	push   $0xe
80100609:	68 d4 03 00 00       	push   $0x3d4
8010060e:	e8 de fc ff ff       	call   801002f1 <outb>
80100613:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
80100616:	68 d5 03 00 00       	push   $0x3d5
8010061b:	e8 b4 fc ff ff       	call   801002d4 <inb>
80100620:	83 c4 04             	add    $0x4,%esp
80100623:	0f b6 c0             	movzbl %al,%eax
80100626:	c1 e0 08             	shl    $0x8,%eax
80100629:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010062c:	6a 0f                	push   $0xf
8010062e:	68 d4 03 00 00       	push   $0x3d4
80100633:	e8 b9 fc ff ff       	call   801002f1 <outb>
80100638:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
8010063b:	68 d5 03 00 00       	push   $0x3d5
80100640:	e8 8f fc ff ff       	call   801002d4 <inb>
80100645:	83 c4 04             	add    $0x4,%esp
80100648:	0f b6 c0             	movzbl %al,%eax
8010064b:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010064e:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100652:	75 30                	jne    80100684 <cgaputc+0x83>
    pos += 80 - pos%80;
80100654:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100657:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010065c:	89 c8                	mov    %ecx,%eax
8010065e:	f7 ea                	imul   %edx
80100660:	c1 fa 05             	sar    $0x5,%edx
80100663:	89 c8                	mov    %ecx,%eax
80100665:	c1 f8 1f             	sar    $0x1f,%eax
80100668:	29 c2                	sub    %eax,%edx
8010066a:	89 d0                	mov    %edx,%eax
8010066c:	c1 e0 02             	shl    $0x2,%eax
8010066f:	01 d0                	add    %edx,%eax
80100671:	c1 e0 04             	shl    $0x4,%eax
80100674:	29 c1                	sub    %eax,%ecx
80100676:	89 ca                	mov    %ecx,%edx
80100678:	b8 50 00 00 00       	mov    $0x50,%eax
8010067d:	29 d0                	sub    %edx,%eax
8010067f:	01 45 f4             	add    %eax,-0xc(%ebp)
80100682:	eb 34                	jmp    801006b8 <cgaputc+0xb7>
  else if(c == BACKSPACE){
80100684:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010068b:	75 0c                	jne    80100699 <cgaputc+0x98>
    if(pos > 0) --pos;
8010068d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100691:	7e 25                	jle    801006b8 <cgaputc+0xb7>
80100693:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100697:	eb 1f                	jmp    801006b8 <cgaputc+0xb7>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100699:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
8010069f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006a2:	8d 50 01             	lea    0x1(%eax),%edx
801006a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006a8:	01 c0                	add    %eax,%eax
801006aa:	01 c8                	add    %ecx,%eax
801006ac:	8b 55 08             	mov    0x8(%ebp),%edx
801006af:	0f b6 d2             	movzbl %dl,%edx
801006b2:	80 ce 07             	or     $0x7,%dh
801006b5:	66 89 10             	mov    %dx,(%eax)
  
  if((pos/80) >= 24){  // Scroll up.
801006b8:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006bf:	7e 4c                	jle    8010070d <cgaputc+0x10c>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006c1:	a1 00 90 10 80       	mov    0x80109000,%eax
801006c6:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006cc:	a1 00 90 10 80       	mov    0x80109000,%eax
801006d1:	83 ec 04             	sub    $0x4,%esp
801006d4:	68 60 0e 00 00       	push   $0xe60
801006d9:	52                   	push   %edx
801006da:	50                   	push   %eax
801006db:	e8 c1 48 00 00       	call   80104fa1 <memmove>
801006e0:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801006e3:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006e7:	b8 80 07 00 00       	mov    $0x780,%eax
801006ec:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006ef:	8d 14 00             	lea    (%eax,%eax,1),%edx
801006f2:	a1 00 90 10 80       	mov    0x80109000,%eax
801006f7:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006fa:	01 c9                	add    %ecx,%ecx
801006fc:	01 c8                	add    %ecx,%eax
801006fe:	83 ec 04             	sub    $0x4,%esp
80100701:	52                   	push   %edx
80100702:	6a 00                	push   $0x0
80100704:	50                   	push   %eax
80100705:	e8 d8 47 00 00       	call   80104ee2 <memset>
8010070a:	83 c4 10             	add    $0x10,%esp
  }
  
  outb(CRTPORT, 14);
8010070d:	83 ec 08             	sub    $0x8,%esp
80100710:	6a 0e                	push   $0xe
80100712:	68 d4 03 00 00       	push   $0x3d4
80100717:	e8 d5 fb ff ff       	call   801002f1 <outb>
8010071c:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010071f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100722:	c1 f8 08             	sar    $0x8,%eax
80100725:	0f b6 c0             	movzbl %al,%eax
80100728:	83 ec 08             	sub    $0x8,%esp
8010072b:	50                   	push   %eax
8010072c:	68 d5 03 00 00       	push   $0x3d5
80100731:	e8 bb fb ff ff       	call   801002f1 <outb>
80100736:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
80100739:	83 ec 08             	sub    $0x8,%esp
8010073c:	6a 0f                	push   $0xf
8010073e:	68 d4 03 00 00       	push   $0x3d4
80100743:	e8 a9 fb ff ff       	call   801002f1 <outb>
80100748:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
8010074b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010074e:	0f b6 c0             	movzbl %al,%eax
80100751:	83 ec 08             	sub    $0x8,%esp
80100754:	50                   	push   %eax
80100755:	68 d5 03 00 00       	push   $0x3d5
8010075a:	e8 92 fb ff ff       	call   801002f1 <outb>
8010075f:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
80100762:	a1 00 90 10 80       	mov    0x80109000,%eax
80100767:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010076a:	01 d2                	add    %edx,%edx
8010076c:	01 d0                	add    %edx,%eax
8010076e:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100773:	90                   	nop
80100774:	c9                   	leave  
80100775:	c3                   	ret    

80100776 <consputc>:

void
consputc(int c)
{
80100776:	55                   	push   %ebp
80100777:	89 e5                	mov    %esp,%ebp
80100779:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
8010077c:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
80100781:	85 c0                	test   %eax,%eax
80100783:	74 07                	je     8010078c <consputc+0x16>
    cli();
80100785:	e8 86 fb ff ff       	call   80100310 <cli>
    for(;;)
8010078a:	eb fe                	jmp    8010078a <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
8010078c:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100793:	75 29                	jne    801007be <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100795:	83 ec 0c             	sub    $0xc,%esp
80100798:	6a 08                	push   $0x8
8010079a:	e8 2f 60 00 00       	call   801067ce <uartputc>
8010079f:	83 c4 10             	add    $0x10,%esp
801007a2:	83 ec 0c             	sub    $0xc,%esp
801007a5:	6a 20                	push   $0x20
801007a7:	e8 22 60 00 00       	call   801067ce <uartputc>
801007ac:	83 c4 10             	add    $0x10,%esp
801007af:	83 ec 0c             	sub    $0xc,%esp
801007b2:	6a 08                	push   $0x8
801007b4:	e8 15 60 00 00       	call   801067ce <uartputc>
801007b9:	83 c4 10             	add    $0x10,%esp
801007bc:	eb 0e                	jmp    801007cc <consputc+0x56>
  } else
    uartputc(c);
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	ff 75 08             	pushl  0x8(%ebp)
801007c4:	e8 05 60 00 00       	call   801067ce <uartputc>
801007c9:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
801007cc:	83 ec 0c             	sub    $0xc,%esp
801007cf:	ff 75 08             	pushl  0x8(%ebp)
801007d2:	e8 2a fe ff ff       	call   80100601 <cgaputc>
801007d7:	83 c4 10             	add    $0x10,%esp
}
801007da:	90                   	nop
801007db:	c9                   	leave  
801007dc:	c3                   	ret    

801007dd <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007dd:	55                   	push   %ebp
801007de:	89 e5                	mov    %esp,%ebp
801007e0:	83 ec 18             	sub    $0x18,%esp
  int c;

  acquire(&input.lock);
801007e3:	83 ec 0c             	sub    $0xc,%esp
801007e6:	68 a0 dd 10 80       	push   $0x8010dda0
801007eb:	e8 8f 44 00 00       	call   80104c7f <acquire>
801007f0:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801007f3:	e9 42 01 00 00       	jmp    8010093a <consoleintr+0x15d>
    switch(c){
801007f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007fb:	83 f8 10             	cmp    $0x10,%eax
801007fe:	74 1e                	je     8010081e <consoleintr+0x41>
80100800:	83 f8 10             	cmp    $0x10,%eax
80100803:	7f 0a                	jg     8010080f <consoleintr+0x32>
80100805:	83 f8 08             	cmp    $0x8,%eax
80100808:	74 69                	je     80100873 <consoleintr+0x96>
8010080a:	e9 99 00 00 00       	jmp    801008a8 <consoleintr+0xcb>
8010080f:	83 f8 15             	cmp    $0x15,%eax
80100812:	74 31                	je     80100845 <consoleintr+0x68>
80100814:	83 f8 7f             	cmp    $0x7f,%eax
80100817:	74 5a                	je     80100873 <consoleintr+0x96>
80100819:	e9 8a 00 00 00       	jmp    801008a8 <consoleintr+0xcb>
    case C('P'):  // Process listing.
      procdump();
8010081e:	e8 09 43 00 00       	call   80104b2c <procdump>
      break;
80100823:	e9 12 01 00 00       	jmp    8010093a <consoleintr+0x15d>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100828:	a1 5c de 10 80       	mov    0x8010de5c,%eax
8010082d:	83 e8 01             	sub    $0x1,%eax
80100830:	a3 5c de 10 80       	mov    %eax,0x8010de5c
        consputc(BACKSPACE);
80100835:	83 ec 0c             	sub    $0xc,%esp
80100838:	68 00 01 00 00       	push   $0x100
8010083d:	e8 34 ff ff ff       	call   80100776 <consputc>
80100842:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100845:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
8010084b:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100850:	39 c2                	cmp    %eax,%edx
80100852:	0f 84 e2 00 00 00    	je     8010093a <consoleintr+0x15d>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100858:	a1 5c de 10 80       	mov    0x8010de5c,%eax
8010085d:	83 e8 01             	sub    $0x1,%eax
80100860:	83 e0 7f             	and    $0x7f,%eax
80100863:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
      while(input.e != input.w &&
8010086a:	3c 0a                	cmp    $0xa,%al
8010086c:	75 ba                	jne    80100828 <consoleintr+0x4b>
      }
      break;
8010086e:	e9 c7 00 00 00       	jmp    8010093a <consoleintr+0x15d>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100873:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100879:	a1 58 de 10 80       	mov    0x8010de58,%eax
8010087e:	39 c2                	cmp    %eax,%edx
80100880:	0f 84 b4 00 00 00    	je     8010093a <consoleintr+0x15d>
        input.e--;
80100886:	a1 5c de 10 80       	mov    0x8010de5c,%eax
8010088b:	83 e8 01             	sub    $0x1,%eax
8010088e:	a3 5c de 10 80       	mov    %eax,0x8010de5c
        consputc(BACKSPACE);
80100893:	83 ec 0c             	sub    $0xc,%esp
80100896:	68 00 01 00 00       	push   $0x100
8010089b:	e8 d6 fe ff ff       	call   80100776 <consputc>
801008a0:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008a3:	e9 92 00 00 00       	jmp    8010093a <consoleintr+0x15d>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801008ac:	0f 84 87 00 00 00    	je     80100939 <consoleintr+0x15c>
801008b2:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
801008b8:	a1 54 de 10 80       	mov    0x8010de54,%eax
801008bd:	29 c2                	sub    %eax,%edx
801008bf:	89 d0                	mov    %edx,%eax
801008c1:	83 f8 7f             	cmp    $0x7f,%eax
801008c4:	77 73                	ja     80100939 <consoleintr+0x15c>
        c = (c == '\r') ? '\n' : c;
801008c6:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
801008ca:	74 05                	je     801008d1 <consoleintr+0xf4>
801008cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008cf:	eb 05                	jmp    801008d6 <consoleintr+0xf9>
801008d1:	b8 0a 00 00 00       	mov    $0xa,%eax
801008d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008d9:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801008de:	8d 50 01             	lea    0x1(%eax),%edx
801008e1:	89 15 5c de 10 80    	mov    %edx,0x8010de5c
801008e7:	83 e0 7f             	and    $0x7f,%eax
801008ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801008ed:	88 90 d4 dd 10 80    	mov    %dl,-0x7fef222c(%eax)
        consputc(c);
801008f3:	83 ec 0c             	sub    $0xc,%esp
801008f6:	ff 75 f4             	pushl  -0xc(%ebp)
801008f9:	e8 78 fe ff ff       	call   80100776 <consputc>
801008fe:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100901:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
80100905:	74 18                	je     8010091f <consoleintr+0x142>
80100907:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
8010090b:	74 12                	je     8010091f <consoleintr+0x142>
8010090d:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100912:	8b 15 54 de 10 80    	mov    0x8010de54,%edx
80100918:	83 ea 80             	sub    $0xffffff80,%edx
8010091b:	39 d0                	cmp    %edx,%eax
8010091d:	75 1a                	jne    80100939 <consoleintr+0x15c>
          input.w = input.e;
8010091f:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100924:	a3 58 de 10 80       	mov    %eax,0x8010de58
          wakeup(&input.r);
80100929:	83 ec 0c             	sub    $0xc,%esp
8010092c:	68 54 de 10 80       	push   $0x8010de54
80100931:	e8 3b 41 00 00       	call   80104a71 <wakeup>
80100936:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100939:	90                   	nop
  while((c = getc()) >= 0){
8010093a:	8b 45 08             	mov    0x8(%ebp),%eax
8010093d:	ff d0                	call   *%eax
8010093f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100942:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100946:	0f 89 ac fe ff ff    	jns    801007f8 <consoleintr+0x1b>
    }
  }
  release(&input.lock);
8010094c:	83 ec 0c             	sub    $0xc,%esp
8010094f:	68 a0 dd 10 80       	push   $0x8010dda0
80100954:	e8 8d 43 00 00       	call   80104ce6 <release>
80100959:	83 c4 10             	add    $0x10,%esp
}
8010095c:	90                   	nop
8010095d:	c9                   	leave  
8010095e:	c3                   	ret    

8010095f <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010095f:	55                   	push   %ebp
80100960:	89 e5                	mov    %esp,%ebp
80100962:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100965:	83 ec 0c             	sub    $0xc,%esp
80100968:	ff 75 08             	pushl  0x8(%ebp)
8010096b:	e8 df 10 00 00       	call   80101a4f <iunlock>
80100970:	83 c4 10             	add    $0x10,%esp
  target = n;
80100973:	8b 45 10             	mov    0x10(%ebp),%eax
80100976:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100979:	83 ec 0c             	sub    $0xc,%esp
8010097c:	68 a0 dd 10 80       	push   $0x8010dda0
80100981:	e8 f9 42 00 00       	call   80104c7f <acquire>
80100986:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100989:	e9 ac 00 00 00       	jmp    80100a3a <consoleread+0xdb>
    while(input.r == input.w){
      if(proc->killed){
8010098e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100994:	8b 40 24             	mov    0x24(%eax),%eax
80100997:	85 c0                	test   %eax,%eax
80100999:	74 28                	je     801009c3 <consoleread+0x64>
        release(&input.lock);
8010099b:	83 ec 0c             	sub    $0xc,%esp
8010099e:	68 a0 dd 10 80       	push   $0x8010dda0
801009a3:	e8 3e 43 00 00       	call   80104ce6 <release>
801009a8:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009ab:	83 ec 0c             	sub    $0xc,%esp
801009ae:	ff 75 08             	pushl  0x8(%ebp)
801009b1:	e8 41 0f 00 00       	call   801018f7 <ilock>
801009b6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009be:	e9 ab 00 00 00       	jmp    80100a6e <consoleread+0x10f>
      }
      sleep(&input.r, &input.lock);
801009c3:	83 ec 08             	sub    $0x8,%esp
801009c6:	68 a0 dd 10 80       	push   $0x8010dda0
801009cb:	68 54 de 10 80       	push   $0x8010de54
801009d0:	e8 b1 3f 00 00       	call   80104986 <sleep>
801009d5:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
801009d8:	8b 15 54 de 10 80    	mov    0x8010de54,%edx
801009de:	a1 58 de 10 80       	mov    0x8010de58,%eax
801009e3:	39 c2                	cmp    %eax,%edx
801009e5:	74 a7                	je     8010098e <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009e7:	a1 54 de 10 80       	mov    0x8010de54,%eax
801009ec:	8d 50 01             	lea    0x1(%eax),%edx
801009ef:	89 15 54 de 10 80    	mov    %edx,0x8010de54
801009f5:	83 e0 7f             	and    $0x7f,%eax
801009f8:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
801009ff:	0f be c0             	movsbl %al,%eax
80100a02:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a05:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a09:	75 17                	jne    80100a22 <consoleread+0xc3>
      if(n < target){
80100a0b:	8b 45 10             	mov    0x10(%ebp),%eax
80100a0e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a11:	73 2f                	jae    80100a42 <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a13:	a1 54 de 10 80       	mov    0x8010de54,%eax
80100a18:	83 e8 01             	sub    $0x1,%eax
80100a1b:	a3 54 de 10 80       	mov    %eax,0x8010de54
      }
      break;
80100a20:	eb 20                	jmp    80100a42 <consoleread+0xe3>
    }
    *dst++ = c;
80100a22:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a25:	8d 50 01             	lea    0x1(%eax),%edx
80100a28:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a2b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a2e:	88 10                	mov    %dl,(%eax)
    --n;
80100a30:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a34:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a38:	74 0b                	je     80100a45 <consoleread+0xe6>
  while(n > 0){
80100a3a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a3e:	7f 98                	jg     801009d8 <consoleread+0x79>
80100a40:	eb 04                	jmp    80100a46 <consoleread+0xe7>
      break;
80100a42:	90                   	nop
80100a43:	eb 01                	jmp    80100a46 <consoleread+0xe7>
      break;
80100a45:	90                   	nop
  }
  release(&input.lock);
80100a46:	83 ec 0c             	sub    $0xc,%esp
80100a49:	68 a0 dd 10 80       	push   $0x8010dda0
80100a4e:	e8 93 42 00 00       	call   80104ce6 <release>
80100a53:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a56:	83 ec 0c             	sub    $0xc,%esp
80100a59:	ff 75 08             	pushl  0x8(%ebp)
80100a5c:	e8 96 0e 00 00       	call   801018f7 <ilock>
80100a61:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a64:	8b 45 10             	mov    0x10(%ebp),%eax
80100a67:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a6a:	29 c2                	sub    %eax,%edx
80100a6c:	89 d0                	mov    %edx,%eax
}
80100a6e:	c9                   	leave  
80100a6f:	c3                   	ret    

80100a70 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a70:	55                   	push   %ebp
80100a71:	89 e5                	mov    %esp,%ebp
80100a73:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100a76:	83 ec 0c             	sub    $0xc,%esp
80100a79:	ff 75 08             	pushl  0x8(%ebp)
80100a7c:	e8 ce 0f 00 00       	call   80101a4f <iunlock>
80100a81:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a84:	83 ec 0c             	sub    $0xc,%esp
80100a87:	68 c0 b5 10 80       	push   $0x8010b5c0
80100a8c:	e8 ee 41 00 00       	call   80104c7f <acquire>
80100a91:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100a94:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a9b:	eb 21                	jmp    80100abe <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100a9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100aa0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100aa3:	01 d0                	add    %edx,%eax
80100aa5:	0f b6 00             	movzbl (%eax),%eax
80100aa8:	0f be c0             	movsbl %al,%eax
80100aab:	0f b6 c0             	movzbl %al,%eax
80100aae:	83 ec 0c             	sub    $0xc,%esp
80100ab1:	50                   	push   %eax
80100ab2:	e8 bf fc ff ff       	call   80100776 <consputc>
80100ab7:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100aba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ac1:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ac4:	7c d7                	jl     80100a9d <consolewrite+0x2d>
  release(&cons.lock);
80100ac6:	83 ec 0c             	sub    $0xc,%esp
80100ac9:	68 c0 b5 10 80       	push   $0x8010b5c0
80100ace:	e8 13 42 00 00       	call   80104ce6 <release>
80100ad3:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ad6:	83 ec 0c             	sub    $0xc,%esp
80100ad9:	ff 75 08             	pushl  0x8(%ebp)
80100adc:	e8 16 0e 00 00       	call   801018f7 <ilock>
80100ae1:	83 c4 10             	add    $0x10,%esp

  return n;
80100ae4:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100ae7:	c9                   	leave  
80100ae8:	c3                   	ret    

80100ae9 <consoleinit>:

void
consoleinit(void)
{
80100ae9:	55                   	push   %ebp
80100aea:	89 e5                	mov    %esp,%ebp
80100aec:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100aef:	83 ec 08             	sub    $0x8,%esp
80100af2:	68 7f 81 10 80       	push   $0x8010817f
80100af7:	68 c0 b5 10 80       	push   $0x8010b5c0
80100afc:	e8 5c 41 00 00       	call   80104c5d <initlock>
80100b01:	83 c4 10             	add    $0x10,%esp
  initlock(&input.lock, "input");
80100b04:	83 ec 08             	sub    $0x8,%esp
80100b07:	68 87 81 10 80       	push   $0x80108187
80100b0c:	68 a0 dd 10 80       	push   $0x8010dda0
80100b11:	e8 47 41 00 00       	call   80104c5d <initlock>
80100b16:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b19:	c7 05 0c e8 10 80 70 	movl   $0x80100a70,0x8010e80c
80100b20:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b23:	c7 05 08 e8 10 80 5f 	movl   $0x8010095f,0x8010e808
80100b2a:	09 10 80 
  cons.locking = 1;
80100b2d:	c7 05 f4 b5 10 80 01 	movl   $0x1,0x8010b5f4
80100b34:	00 00 00 

  picenable(IRQ_KBD);
80100b37:	83 ec 0c             	sub    $0xc,%esp
80100b3a:	6a 01                	push   $0x1
80100b3c:	e8 b3 2f 00 00       	call   80103af4 <picenable>
80100b41:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b44:	83 ec 08             	sub    $0x8,%esp
80100b47:	6a 00                	push   $0x0
80100b49:	6a 01                	push   $0x1
80100b4b:	e8 d5 1e 00 00       	call   80102a25 <ioapicenable>
80100b50:	83 c4 10             	add    $0x10,%esp
}
80100b53:	90                   	nop
80100b54:	c9                   	leave  
80100b55:	c3                   	ret    

80100b56 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b56:	55                   	push   %ebp
80100b57:	89 e5                	mov    %esp,%ebp
80100b59:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  if((ip = namei(path)) == 0)
80100b5f:	83 ec 0c             	sub    $0xc,%esp
80100b62:	ff 75 08             	pushl  0x8(%ebp)
80100b65:	e8 45 19 00 00       	call   801024af <namei>
80100b6a:	83 c4 10             	add    $0x10,%esp
80100b6d:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b70:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b74:	75 0a                	jne    80100b80 <exec+0x2a>
    return -1;
80100b76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b7b:	e9 c4 03 00 00       	jmp    80100f44 <exec+0x3ee>
  ilock(ip);
80100b80:	83 ec 0c             	sub    $0xc,%esp
80100b83:	ff 75 d8             	pushl  -0x28(%ebp)
80100b86:	e8 6c 0d 00 00       	call   801018f7 <ilock>
80100b8b:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100b8e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b95:	6a 34                	push   $0x34
80100b97:	6a 00                	push   $0x0
80100b99:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100b9f:	50                   	push   %eax
80100ba0:	ff 75 d8             	pushl  -0x28(%ebp)
80100ba3:	e8 b7 12 00 00       	call   80101e5f <readi>
80100ba8:	83 c4 10             	add    $0x10,%esp
80100bab:	83 f8 33             	cmp    $0x33,%eax
80100bae:	0f 86 44 03 00 00    	jbe    80100ef8 <exec+0x3a2>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100bb4:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100bba:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100bbf:	0f 85 36 03 00 00    	jne    80100efb <exec+0x3a5>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100bc5:	e8 59 6d 00 00       	call   80107923 <setupkvm>
80100bca:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100bcd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100bd1:	0f 84 27 03 00 00    	je     80100efe <exec+0x3a8>
    goto bad;

  // Load program into memory.
  sz = 0;
80100bd7:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100bde:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100be5:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100beb:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100bee:	e9 ab 00 00 00       	jmp    80100c9e <exec+0x148>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100bf3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100bf6:	6a 20                	push   $0x20
80100bf8:	50                   	push   %eax
80100bf9:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100bff:	50                   	push   %eax
80100c00:	ff 75 d8             	pushl  -0x28(%ebp)
80100c03:	e8 57 12 00 00       	call   80101e5f <readi>
80100c08:	83 c4 10             	add    $0x10,%esp
80100c0b:	83 f8 20             	cmp    $0x20,%eax
80100c0e:	0f 85 ed 02 00 00    	jne    80100f01 <exec+0x3ab>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c14:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c1a:	83 f8 01             	cmp    $0x1,%eax
80100c1d:	75 71                	jne    80100c90 <exec+0x13a>
      continue;
    if(ph.memsz < ph.filesz)
80100c1f:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c25:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c2b:	39 c2                	cmp    %eax,%edx
80100c2d:	0f 82 d1 02 00 00    	jb     80100f04 <exec+0x3ae>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c33:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c39:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c3f:	01 d0                	add    %edx,%eax
80100c41:	83 ec 04             	sub    $0x4,%esp
80100c44:	50                   	push   %eax
80100c45:	ff 75 e0             	pushl  -0x20(%ebp)
80100c48:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c4b:	e8 7a 70 00 00       	call   80107cca <allocuvm>
80100c50:	83 c4 10             	add    $0x10,%esp
80100c53:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c56:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c5a:	0f 84 a7 02 00 00    	je     80100f07 <exec+0x3b1>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c60:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c66:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c6c:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100c72:	83 ec 0c             	sub    $0xc,%esp
80100c75:	52                   	push   %edx
80100c76:	50                   	push   %eax
80100c77:	ff 75 d8             	pushl  -0x28(%ebp)
80100c7a:	51                   	push   %ecx
80100c7b:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c7e:	e8 70 6f 00 00       	call   80107bf3 <loaduvm>
80100c83:	83 c4 20             	add    $0x20,%esp
80100c86:	85 c0                	test   %eax,%eax
80100c88:	0f 88 7c 02 00 00    	js     80100f0a <exec+0x3b4>
80100c8e:	eb 01                	jmp    80100c91 <exec+0x13b>
      continue;
80100c90:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c91:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c95:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c98:	83 c0 20             	add    $0x20,%eax
80100c9b:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c9e:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100ca5:	0f b7 c0             	movzwl %ax,%eax
80100ca8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100cab:	0f 8f 42 ff ff ff    	jg     80100bf3 <exec+0x9d>
      goto bad;
  }
  iunlockput(ip);
80100cb1:	83 ec 0c             	sub    $0xc,%esp
80100cb4:	ff 75 d8             	pushl  -0x28(%ebp)
80100cb7:	e8 f5 0e 00 00       	call   80101bb1 <iunlockput>
80100cbc:	83 c4 10             	add    $0x10,%esp
  ip = 0;
80100cbf:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100cc6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cc9:	05 ff 0f 00 00       	add    $0xfff,%eax
80100cce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100cd3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100cd6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cd9:	05 00 20 00 00       	add    $0x2000,%eax
80100cde:	83 ec 04             	sub    $0x4,%esp
80100ce1:	50                   	push   %eax
80100ce2:	ff 75 e0             	pushl  -0x20(%ebp)
80100ce5:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ce8:	e8 dd 6f 00 00       	call   80107cca <allocuvm>
80100ced:	83 c4 10             	add    $0x10,%esp
80100cf0:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cf3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cf7:	0f 84 10 02 00 00    	je     80100f0d <exec+0x3b7>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100cfd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d00:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d05:	83 ec 08             	sub    $0x8,%esp
80100d08:	50                   	push   %eax
80100d09:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d0c:	e8 df 71 00 00       	call   80107ef0 <clearpteu>
80100d11:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d14:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d17:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d1a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d21:	e9 96 00 00 00       	jmp    80100dbc <exec+0x266>
    if(argc >= MAXARG)
80100d26:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d2a:	0f 87 e0 01 00 00    	ja     80100f10 <exec+0x3ba>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d33:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d3d:	01 d0                	add    %edx,%eax
80100d3f:	8b 00                	mov    (%eax),%eax
80100d41:	83 ec 0c             	sub    $0xc,%esp
80100d44:	50                   	push   %eax
80100d45:	e8 e5 43 00 00       	call   8010512f <strlen>
80100d4a:	83 c4 10             	add    $0x10,%esp
80100d4d:	89 c2                	mov    %eax,%edx
80100d4f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d52:	29 d0                	sub    %edx,%eax
80100d54:	83 e8 01             	sub    $0x1,%eax
80100d57:	83 e0 fc             	and    $0xfffffffc,%eax
80100d5a:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d60:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d67:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d6a:	01 d0                	add    %edx,%eax
80100d6c:	8b 00                	mov    (%eax),%eax
80100d6e:	83 ec 0c             	sub    $0xc,%esp
80100d71:	50                   	push   %eax
80100d72:	e8 b8 43 00 00       	call   8010512f <strlen>
80100d77:	83 c4 10             	add    $0x10,%esp
80100d7a:	83 c0 01             	add    $0x1,%eax
80100d7d:	89 c1                	mov    %eax,%ecx
80100d7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d82:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d89:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d8c:	01 d0                	add    %edx,%eax
80100d8e:	8b 00                	mov    (%eax),%eax
80100d90:	51                   	push   %ecx
80100d91:	50                   	push   %eax
80100d92:	ff 75 dc             	pushl  -0x24(%ebp)
80100d95:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d98:	e8 f7 72 00 00       	call   80108094 <copyout>
80100d9d:	83 c4 10             	add    $0x10,%esp
80100da0:	85 c0                	test   %eax,%eax
80100da2:	0f 88 6b 01 00 00    	js     80100f13 <exec+0x3bd>
      goto bad;
    ustack[3+argc] = sp;
80100da8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dab:	8d 50 03             	lea    0x3(%eax),%edx
80100dae:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100db1:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100db8:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100dbc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dbf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dc6:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dc9:	01 d0                	add    %edx,%eax
80100dcb:	8b 00                	mov    (%eax),%eax
80100dcd:	85 c0                	test   %eax,%eax
80100dcf:	0f 85 51 ff ff ff    	jne    80100d26 <exec+0x1d0>
  }
  ustack[3+argc] = 0;
80100dd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dd8:	83 c0 03             	add    $0x3,%eax
80100ddb:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100de2:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100de6:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100ded:	ff ff ff 
  ustack[1] = argc;
80100df0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100df3:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100df9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dfc:	83 c0 01             	add    $0x1,%eax
80100dff:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e06:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e09:	29 d0                	sub    %edx,%eax
80100e0b:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e14:	83 c0 04             	add    $0x4,%eax
80100e17:	c1 e0 02             	shl    $0x2,%eax
80100e1a:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e20:	83 c0 04             	add    $0x4,%eax
80100e23:	c1 e0 02             	shl    $0x2,%eax
80100e26:	50                   	push   %eax
80100e27:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e2d:	50                   	push   %eax
80100e2e:	ff 75 dc             	pushl  -0x24(%ebp)
80100e31:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e34:	e8 5b 72 00 00       	call   80108094 <copyout>
80100e39:	83 c4 10             	add    $0x10,%esp
80100e3c:	85 c0                	test   %eax,%eax
80100e3e:	0f 88 d2 00 00 00    	js     80100f16 <exec+0x3c0>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e44:	8b 45 08             	mov    0x8(%ebp),%eax
80100e47:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e50:	eb 17                	jmp    80100e69 <exec+0x313>
    if(*s == '/')
80100e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e55:	0f b6 00             	movzbl (%eax),%eax
80100e58:	3c 2f                	cmp    $0x2f,%al
80100e5a:	75 09                	jne    80100e65 <exec+0x30f>
      last = s+1;
80100e5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e5f:	83 c0 01             	add    $0x1,%eax
80100e62:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100e65:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e6c:	0f b6 00             	movzbl (%eax),%eax
80100e6f:	84 c0                	test   %al,%al
80100e71:	75 df                	jne    80100e52 <exec+0x2fc>
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e73:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e79:	83 c0 6c             	add    $0x6c,%eax
80100e7c:	83 ec 04             	sub    $0x4,%esp
80100e7f:	6a 10                	push   $0x10
80100e81:	ff 75 f0             	pushl  -0x10(%ebp)
80100e84:	50                   	push   %eax
80100e85:	e8 5b 42 00 00       	call   801050e5 <safestrcpy>
80100e8a:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e8d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e93:	8b 40 04             	mov    0x4(%eax),%eax
80100e96:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100e99:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e9f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100ea2:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100ea5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eab:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100eae:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100eb0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eb6:	8b 40 18             	mov    0x18(%eax),%eax
80100eb9:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100ebf:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100ec2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ec8:	8b 40 18             	mov    0x18(%eax),%eax
80100ecb:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ece:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100ed1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ed7:	83 ec 0c             	sub    $0xc,%esp
80100eda:	50                   	push   %eax
80100edb:	e8 2a 6b 00 00       	call   80107a0a <switchuvm>
80100ee0:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100ee3:	83 ec 0c             	sub    $0xc,%esp
80100ee6:	ff 75 d0             	pushl  -0x30(%ebp)
80100ee9:	e8 62 6f 00 00       	call   80107e50 <freevm>
80100eee:	83 c4 10             	add    $0x10,%esp
  return 0;
80100ef1:	b8 00 00 00 00       	mov    $0x0,%eax
80100ef6:	eb 4c                	jmp    80100f44 <exec+0x3ee>
    goto bad;
80100ef8:	90                   	nop
80100ef9:	eb 1c                	jmp    80100f17 <exec+0x3c1>
    goto bad;
80100efb:	90                   	nop
80100efc:	eb 19                	jmp    80100f17 <exec+0x3c1>
    goto bad;
80100efe:	90                   	nop
80100eff:	eb 16                	jmp    80100f17 <exec+0x3c1>
      goto bad;
80100f01:	90                   	nop
80100f02:	eb 13                	jmp    80100f17 <exec+0x3c1>
      goto bad;
80100f04:	90                   	nop
80100f05:	eb 10                	jmp    80100f17 <exec+0x3c1>
      goto bad;
80100f07:	90                   	nop
80100f08:	eb 0d                	jmp    80100f17 <exec+0x3c1>
      goto bad;
80100f0a:	90                   	nop
80100f0b:	eb 0a                	jmp    80100f17 <exec+0x3c1>
    goto bad;
80100f0d:	90                   	nop
80100f0e:	eb 07                	jmp    80100f17 <exec+0x3c1>
      goto bad;
80100f10:	90                   	nop
80100f11:	eb 04                	jmp    80100f17 <exec+0x3c1>
      goto bad;
80100f13:	90                   	nop
80100f14:	eb 01                	jmp    80100f17 <exec+0x3c1>
    goto bad;
80100f16:	90                   	nop

 bad:
  if(pgdir)
80100f17:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f1b:	74 0e                	je     80100f2b <exec+0x3d5>
    freevm(pgdir);
80100f1d:	83 ec 0c             	sub    $0xc,%esp
80100f20:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f23:	e8 28 6f 00 00       	call   80107e50 <freevm>
80100f28:	83 c4 10             	add    $0x10,%esp
  if(ip)
80100f2b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f2f:	74 0e                	je     80100f3f <exec+0x3e9>
    iunlockput(ip);
80100f31:	83 ec 0c             	sub    $0xc,%esp
80100f34:	ff 75 d8             	pushl  -0x28(%ebp)
80100f37:	e8 75 0c 00 00       	call   80101bb1 <iunlockput>
80100f3c:	83 c4 10             	add    $0x10,%esp
  return -1;
80100f3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f44:	c9                   	leave  
80100f45:	c3                   	ret    

80100f46 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f46:	55                   	push   %ebp
80100f47:	89 e5                	mov    %esp,%ebp
80100f49:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100f4c:	83 ec 08             	sub    $0x8,%esp
80100f4f:	68 8d 81 10 80       	push   $0x8010818d
80100f54:	68 60 de 10 80       	push   $0x8010de60
80100f59:	e8 ff 3c 00 00       	call   80104c5d <initlock>
80100f5e:	83 c4 10             	add    $0x10,%esp
}
80100f61:	90                   	nop
80100f62:	c9                   	leave  
80100f63:	c3                   	ret    

80100f64 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f64:	55                   	push   %ebp
80100f65:	89 e5                	mov    %esp,%ebp
80100f67:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f6a:	83 ec 0c             	sub    $0xc,%esp
80100f6d:	68 60 de 10 80       	push   $0x8010de60
80100f72:	e8 08 3d 00 00       	call   80104c7f <acquire>
80100f77:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f7a:	c7 45 f4 94 de 10 80 	movl   $0x8010de94,-0xc(%ebp)
80100f81:	eb 2d                	jmp    80100fb0 <filealloc+0x4c>
    if(f->ref == 0){
80100f83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f86:	8b 40 04             	mov    0x4(%eax),%eax
80100f89:	85 c0                	test   %eax,%eax
80100f8b:	75 1f                	jne    80100fac <filealloc+0x48>
      f->ref = 1;
80100f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f90:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f97:	83 ec 0c             	sub    $0xc,%esp
80100f9a:	68 60 de 10 80       	push   $0x8010de60
80100f9f:	e8 42 3d 00 00       	call   80104ce6 <release>
80100fa4:	83 c4 10             	add    $0x10,%esp
      return f;
80100fa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100faa:	eb 23                	jmp    80100fcf <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fac:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100fb0:	b8 f4 e7 10 80       	mov    $0x8010e7f4,%eax
80100fb5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100fb8:	72 c9                	jb     80100f83 <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
80100fba:	83 ec 0c             	sub    $0xc,%esp
80100fbd:	68 60 de 10 80       	push   $0x8010de60
80100fc2:	e8 1f 3d 00 00       	call   80104ce6 <release>
80100fc7:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fca:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100fcf:	c9                   	leave  
80100fd0:	c3                   	ret    

80100fd1 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100fd1:	55                   	push   %ebp
80100fd2:	89 e5                	mov    %esp,%ebp
80100fd4:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80100fd7:	83 ec 0c             	sub    $0xc,%esp
80100fda:	68 60 de 10 80       	push   $0x8010de60
80100fdf:	e8 9b 3c 00 00       	call   80104c7f <acquire>
80100fe4:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80100fe7:	8b 45 08             	mov    0x8(%ebp),%eax
80100fea:	8b 40 04             	mov    0x4(%eax),%eax
80100fed:	85 c0                	test   %eax,%eax
80100fef:	7f 0d                	jg     80100ffe <filedup+0x2d>
    panic("filedup");
80100ff1:	83 ec 0c             	sub    $0xc,%esp
80100ff4:	68 94 81 10 80       	push   $0x80108194
80100ff9:	e8 68 f5 ff ff       	call   80100566 <panic>
  f->ref++;
80100ffe:	8b 45 08             	mov    0x8(%ebp),%eax
80101001:	8b 40 04             	mov    0x4(%eax),%eax
80101004:	8d 50 01             	lea    0x1(%eax),%edx
80101007:	8b 45 08             	mov    0x8(%ebp),%eax
8010100a:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010100d:	83 ec 0c             	sub    $0xc,%esp
80101010:	68 60 de 10 80       	push   $0x8010de60
80101015:	e8 cc 3c 00 00       	call   80104ce6 <release>
8010101a:	83 c4 10             	add    $0x10,%esp
  return f;
8010101d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101020:	c9                   	leave  
80101021:	c3                   	ret    

80101022 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101022:	55                   	push   %ebp
80101023:	89 e5                	mov    %esp,%ebp
80101025:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101028:	83 ec 0c             	sub    $0xc,%esp
8010102b:	68 60 de 10 80       	push   $0x8010de60
80101030:	e8 4a 3c 00 00       	call   80104c7f <acquire>
80101035:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101038:	8b 45 08             	mov    0x8(%ebp),%eax
8010103b:	8b 40 04             	mov    0x4(%eax),%eax
8010103e:	85 c0                	test   %eax,%eax
80101040:	7f 0d                	jg     8010104f <fileclose+0x2d>
    panic("fileclose");
80101042:	83 ec 0c             	sub    $0xc,%esp
80101045:	68 9c 81 10 80       	push   $0x8010819c
8010104a:	e8 17 f5 ff ff       	call   80100566 <panic>
  if(--f->ref > 0){
8010104f:	8b 45 08             	mov    0x8(%ebp),%eax
80101052:	8b 40 04             	mov    0x4(%eax),%eax
80101055:	8d 50 ff             	lea    -0x1(%eax),%edx
80101058:	8b 45 08             	mov    0x8(%ebp),%eax
8010105b:	89 50 04             	mov    %edx,0x4(%eax)
8010105e:	8b 45 08             	mov    0x8(%ebp),%eax
80101061:	8b 40 04             	mov    0x4(%eax),%eax
80101064:	85 c0                	test   %eax,%eax
80101066:	7e 15                	jle    8010107d <fileclose+0x5b>
    release(&ftable.lock);
80101068:	83 ec 0c             	sub    $0xc,%esp
8010106b:	68 60 de 10 80       	push   $0x8010de60
80101070:	e8 71 3c 00 00       	call   80104ce6 <release>
80101075:	83 c4 10             	add    $0x10,%esp
80101078:	e9 8b 00 00 00       	jmp    80101108 <fileclose+0xe6>
    return;
  }
  ff = *f;
8010107d:	8b 45 08             	mov    0x8(%ebp),%eax
80101080:	8b 10                	mov    (%eax),%edx
80101082:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101085:	8b 50 04             	mov    0x4(%eax),%edx
80101088:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010108b:	8b 50 08             	mov    0x8(%eax),%edx
8010108e:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101091:	8b 50 0c             	mov    0xc(%eax),%edx
80101094:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101097:	8b 50 10             	mov    0x10(%eax),%edx
8010109a:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010109d:	8b 40 14             	mov    0x14(%eax),%eax
801010a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801010a3:	8b 45 08             	mov    0x8(%ebp),%eax
801010a6:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801010ad:	8b 45 08             	mov    0x8(%ebp),%eax
801010b0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801010b6:	83 ec 0c             	sub    $0xc,%esp
801010b9:	68 60 de 10 80       	push   $0x8010de60
801010be:	e8 23 3c 00 00       	call   80104ce6 <release>
801010c3:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
801010c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010c9:	83 f8 01             	cmp    $0x1,%eax
801010cc:	75 19                	jne    801010e7 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
801010ce:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801010d2:	0f be d0             	movsbl %al,%edx
801010d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801010d8:	83 ec 08             	sub    $0x8,%esp
801010db:	52                   	push   %edx
801010dc:	50                   	push   %eax
801010dd:	e8 7b 2c 00 00       	call   80103d5d <pipeclose>
801010e2:	83 c4 10             	add    $0x10,%esp
801010e5:	eb 21                	jmp    80101108 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
801010e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010ea:	83 f8 02             	cmp    $0x2,%eax
801010ed:	75 19                	jne    80101108 <fileclose+0xe6>
    begin_trans();
801010ef:	e8 87 21 00 00       	call   8010327b <begin_trans>
    iput(ff.ip);
801010f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801010f7:	83 ec 0c             	sub    $0xc,%esp
801010fa:	50                   	push   %eax
801010fb:	e8 c1 09 00 00       	call   80101ac1 <iput>
80101100:	83 c4 10             	add    $0x10,%esp
    commit_trans();
80101103:	e8 c6 21 00 00       	call   801032ce <commit_trans>
  }
}
80101108:	c9                   	leave  
80101109:	c3                   	ret    

8010110a <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010110a:	55                   	push   %ebp
8010110b:	89 e5                	mov    %esp,%ebp
8010110d:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101110:	8b 45 08             	mov    0x8(%ebp),%eax
80101113:	8b 00                	mov    (%eax),%eax
80101115:	83 f8 02             	cmp    $0x2,%eax
80101118:	75 40                	jne    8010115a <filestat+0x50>
    ilock(f->ip);
8010111a:	8b 45 08             	mov    0x8(%ebp),%eax
8010111d:	8b 40 10             	mov    0x10(%eax),%eax
80101120:	83 ec 0c             	sub    $0xc,%esp
80101123:	50                   	push   %eax
80101124:	e8 ce 07 00 00       	call   801018f7 <ilock>
80101129:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
8010112c:	8b 45 08             	mov    0x8(%ebp),%eax
8010112f:	8b 40 10             	mov    0x10(%eax),%eax
80101132:	83 ec 08             	sub    $0x8,%esp
80101135:	ff 75 0c             	pushl  0xc(%ebp)
80101138:	50                   	push   %eax
80101139:	e8 db 0c 00 00       	call   80101e19 <stati>
8010113e:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101141:	8b 45 08             	mov    0x8(%ebp),%eax
80101144:	8b 40 10             	mov    0x10(%eax),%eax
80101147:	83 ec 0c             	sub    $0xc,%esp
8010114a:	50                   	push   %eax
8010114b:	e8 ff 08 00 00       	call   80101a4f <iunlock>
80101150:	83 c4 10             	add    $0x10,%esp
    return 0;
80101153:	b8 00 00 00 00       	mov    $0x0,%eax
80101158:	eb 05                	jmp    8010115f <filestat+0x55>
  }
  return -1;
8010115a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010115f:	c9                   	leave  
80101160:	c3                   	ret    

80101161 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101161:	55                   	push   %ebp
80101162:	89 e5                	mov    %esp,%ebp
80101164:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101167:	8b 45 08             	mov    0x8(%ebp),%eax
8010116a:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010116e:	84 c0                	test   %al,%al
80101170:	75 0a                	jne    8010117c <fileread+0x1b>
    return -1;
80101172:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101177:	e9 9b 00 00 00       	jmp    80101217 <fileread+0xb6>
  if(f->type == FD_PIPE)
8010117c:	8b 45 08             	mov    0x8(%ebp),%eax
8010117f:	8b 00                	mov    (%eax),%eax
80101181:	83 f8 01             	cmp    $0x1,%eax
80101184:	75 1a                	jne    801011a0 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
80101186:	8b 45 08             	mov    0x8(%ebp),%eax
80101189:	8b 40 0c             	mov    0xc(%eax),%eax
8010118c:	83 ec 04             	sub    $0x4,%esp
8010118f:	ff 75 10             	pushl  0x10(%ebp)
80101192:	ff 75 0c             	pushl  0xc(%ebp)
80101195:	50                   	push   %eax
80101196:	e8 6a 2d 00 00       	call   80103f05 <piperead>
8010119b:	83 c4 10             	add    $0x10,%esp
8010119e:	eb 77                	jmp    80101217 <fileread+0xb6>
  if(f->type == FD_INODE){
801011a0:	8b 45 08             	mov    0x8(%ebp),%eax
801011a3:	8b 00                	mov    (%eax),%eax
801011a5:	83 f8 02             	cmp    $0x2,%eax
801011a8:	75 60                	jne    8010120a <fileread+0xa9>
    ilock(f->ip);
801011aa:	8b 45 08             	mov    0x8(%ebp),%eax
801011ad:	8b 40 10             	mov    0x10(%eax),%eax
801011b0:	83 ec 0c             	sub    $0xc,%esp
801011b3:	50                   	push   %eax
801011b4:	e8 3e 07 00 00       	call   801018f7 <ilock>
801011b9:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801011bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
801011bf:	8b 45 08             	mov    0x8(%ebp),%eax
801011c2:	8b 50 14             	mov    0x14(%eax),%edx
801011c5:	8b 45 08             	mov    0x8(%ebp),%eax
801011c8:	8b 40 10             	mov    0x10(%eax),%eax
801011cb:	51                   	push   %ecx
801011cc:	52                   	push   %edx
801011cd:	ff 75 0c             	pushl  0xc(%ebp)
801011d0:	50                   	push   %eax
801011d1:	e8 89 0c 00 00       	call   80101e5f <readi>
801011d6:	83 c4 10             	add    $0x10,%esp
801011d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801011dc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801011e0:	7e 11                	jle    801011f3 <fileread+0x92>
      f->off += r;
801011e2:	8b 45 08             	mov    0x8(%ebp),%eax
801011e5:	8b 50 14             	mov    0x14(%eax),%edx
801011e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011eb:	01 c2                	add    %eax,%edx
801011ed:	8b 45 08             	mov    0x8(%ebp),%eax
801011f0:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801011f3:	8b 45 08             	mov    0x8(%ebp),%eax
801011f6:	8b 40 10             	mov    0x10(%eax),%eax
801011f9:	83 ec 0c             	sub    $0xc,%esp
801011fc:	50                   	push   %eax
801011fd:	e8 4d 08 00 00       	call   80101a4f <iunlock>
80101202:	83 c4 10             	add    $0x10,%esp
    return r;
80101205:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101208:	eb 0d                	jmp    80101217 <fileread+0xb6>
  }
  panic("fileread");
8010120a:	83 ec 0c             	sub    $0xc,%esp
8010120d:	68 a6 81 10 80       	push   $0x801081a6
80101212:	e8 4f f3 ff ff       	call   80100566 <panic>
}
80101217:	c9                   	leave  
80101218:	c3                   	ret    

80101219 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101219:	55                   	push   %ebp
8010121a:	89 e5                	mov    %esp,%ebp
8010121c:	53                   	push   %ebx
8010121d:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101220:	8b 45 08             	mov    0x8(%ebp),%eax
80101223:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101227:	84 c0                	test   %al,%al
80101229:	75 0a                	jne    80101235 <filewrite+0x1c>
    return -1;
8010122b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101230:	e9 1b 01 00 00       	jmp    80101350 <filewrite+0x137>
  if(f->type == FD_PIPE)
80101235:	8b 45 08             	mov    0x8(%ebp),%eax
80101238:	8b 00                	mov    (%eax),%eax
8010123a:	83 f8 01             	cmp    $0x1,%eax
8010123d:	75 1d                	jne    8010125c <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
8010123f:	8b 45 08             	mov    0x8(%ebp),%eax
80101242:	8b 40 0c             	mov    0xc(%eax),%eax
80101245:	83 ec 04             	sub    $0x4,%esp
80101248:	ff 75 10             	pushl  0x10(%ebp)
8010124b:	ff 75 0c             	pushl  0xc(%ebp)
8010124e:	50                   	push   %eax
8010124f:	e8 b3 2b 00 00       	call   80103e07 <pipewrite>
80101254:	83 c4 10             	add    $0x10,%esp
80101257:	e9 f4 00 00 00       	jmp    80101350 <filewrite+0x137>
  if(f->type == FD_INODE){
8010125c:	8b 45 08             	mov    0x8(%ebp),%eax
8010125f:	8b 00                	mov    (%eax),%eax
80101261:	83 f8 02             	cmp    $0x2,%eax
80101264:	0f 85 d9 00 00 00    	jne    80101343 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010126a:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101271:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101278:	e9 a3 00 00 00       	jmp    80101320 <filewrite+0x107>
      int n1 = n - i;
8010127d:	8b 45 10             	mov    0x10(%ebp),%eax
80101280:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101283:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101286:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101289:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010128c:	7e 06                	jle    80101294 <filewrite+0x7b>
        n1 = max;
8010128e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101291:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_trans();
80101294:	e8 e2 1f 00 00       	call   8010327b <begin_trans>
      ilock(f->ip);
80101299:	8b 45 08             	mov    0x8(%ebp),%eax
8010129c:	8b 40 10             	mov    0x10(%eax),%eax
8010129f:	83 ec 0c             	sub    $0xc,%esp
801012a2:	50                   	push   %eax
801012a3:	e8 4f 06 00 00       	call   801018f7 <ilock>
801012a8:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801012ab:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801012ae:	8b 45 08             	mov    0x8(%ebp),%eax
801012b1:	8b 50 14             	mov    0x14(%eax),%edx
801012b4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801012b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801012ba:	01 c3                	add    %eax,%ebx
801012bc:	8b 45 08             	mov    0x8(%ebp),%eax
801012bf:	8b 40 10             	mov    0x10(%eax),%eax
801012c2:	51                   	push   %ecx
801012c3:	52                   	push   %edx
801012c4:	53                   	push   %ebx
801012c5:	50                   	push   %eax
801012c6:	e8 eb 0c 00 00       	call   80101fb6 <writei>
801012cb:	83 c4 10             	add    $0x10,%esp
801012ce:	89 45 e8             	mov    %eax,-0x18(%ebp)
801012d1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012d5:	7e 11                	jle    801012e8 <filewrite+0xcf>
        f->off += r;
801012d7:	8b 45 08             	mov    0x8(%ebp),%eax
801012da:	8b 50 14             	mov    0x14(%eax),%edx
801012dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012e0:	01 c2                	add    %eax,%edx
801012e2:	8b 45 08             	mov    0x8(%ebp),%eax
801012e5:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801012e8:	8b 45 08             	mov    0x8(%ebp),%eax
801012eb:	8b 40 10             	mov    0x10(%eax),%eax
801012ee:	83 ec 0c             	sub    $0xc,%esp
801012f1:	50                   	push   %eax
801012f2:	e8 58 07 00 00       	call   80101a4f <iunlock>
801012f7:	83 c4 10             	add    $0x10,%esp
      commit_trans();
801012fa:	e8 cf 1f 00 00       	call   801032ce <commit_trans>

      if(r < 0)
801012ff:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101303:	78 29                	js     8010132e <filewrite+0x115>
        break;
      if(r != n1)
80101305:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101308:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010130b:	74 0d                	je     8010131a <filewrite+0x101>
        panic("short filewrite");
8010130d:	83 ec 0c             	sub    $0xc,%esp
80101310:	68 af 81 10 80       	push   $0x801081af
80101315:	e8 4c f2 ff ff       	call   80100566 <panic>
      i += r;
8010131a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010131d:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
80101320:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101323:	3b 45 10             	cmp    0x10(%ebp),%eax
80101326:	0f 8c 51 ff ff ff    	jl     8010127d <filewrite+0x64>
8010132c:	eb 01                	jmp    8010132f <filewrite+0x116>
        break;
8010132e:	90                   	nop
    }
    return i == n ? n : -1;
8010132f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101332:	3b 45 10             	cmp    0x10(%ebp),%eax
80101335:	75 05                	jne    8010133c <filewrite+0x123>
80101337:	8b 45 10             	mov    0x10(%ebp),%eax
8010133a:	eb 14                	jmp    80101350 <filewrite+0x137>
8010133c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101341:	eb 0d                	jmp    80101350 <filewrite+0x137>
  }
  panic("filewrite");
80101343:	83 ec 0c             	sub    $0xc,%esp
80101346:	68 bf 81 10 80       	push   $0x801081bf
8010134b:	e8 16 f2 ff ff       	call   80100566 <panic>
}
80101350:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101353:	c9                   	leave  
80101354:	c3                   	ret    

80101355 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101355:	55                   	push   %ebp
80101356:	89 e5                	mov    %esp,%ebp
80101358:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
8010135b:	8b 45 08             	mov    0x8(%ebp),%eax
8010135e:	83 ec 08             	sub    $0x8,%esp
80101361:	6a 01                	push   $0x1
80101363:	50                   	push   %eax
80101364:	e8 4d ee ff ff       	call   801001b6 <bread>
80101369:	83 c4 10             	add    $0x10,%esp
8010136c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010136f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101372:	83 c0 18             	add    $0x18,%eax
80101375:	83 ec 04             	sub    $0x4,%esp
80101378:	6a 10                	push   $0x10
8010137a:	50                   	push   %eax
8010137b:	ff 75 0c             	pushl  0xc(%ebp)
8010137e:	e8 1e 3c 00 00       	call   80104fa1 <memmove>
80101383:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101386:	83 ec 0c             	sub    $0xc,%esp
80101389:	ff 75 f4             	pushl  -0xc(%ebp)
8010138c:	e8 9d ee ff ff       	call   8010022e <brelse>
80101391:	83 c4 10             	add    $0x10,%esp
}
80101394:	90                   	nop
80101395:	c9                   	leave  
80101396:	c3                   	ret    

80101397 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101397:	55                   	push   %ebp
80101398:	89 e5                	mov    %esp,%ebp
8010139a:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
8010139d:	8b 55 0c             	mov    0xc(%ebp),%edx
801013a0:	8b 45 08             	mov    0x8(%ebp),%eax
801013a3:	83 ec 08             	sub    $0x8,%esp
801013a6:	52                   	push   %edx
801013a7:	50                   	push   %eax
801013a8:	e8 09 ee ff ff       	call   801001b6 <bread>
801013ad:	83 c4 10             	add    $0x10,%esp
801013b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801013b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013b6:	83 c0 18             	add    $0x18,%eax
801013b9:	83 ec 04             	sub    $0x4,%esp
801013bc:	68 00 02 00 00       	push   $0x200
801013c1:	6a 00                	push   $0x0
801013c3:	50                   	push   %eax
801013c4:	e8 19 3b 00 00       	call   80104ee2 <memset>
801013c9:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801013cc:	83 ec 0c             	sub    $0xc,%esp
801013cf:	ff 75 f4             	pushl  -0xc(%ebp)
801013d2:	e8 5c 1f 00 00       	call   80103333 <log_write>
801013d7:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013da:	83 ec 0c             	sub    $0xc,%esp
801013dd:	ff 75 f4             	pushl  -0xc(%ebp)
801013e0:	e8 49 ee ff ff       	call   8010022e <brelse>
801013e5:	83 c4 10             	add    $0x10,%esp
}
801013e8:	90                   	nop
801013e9:	c9                   	leave  
801013ea:	c3                   	ret    

801013eb <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801013eb:	55                   	push   %ebp
801013ec:	89 e5                	mov    %esp,%ebp
801013ee:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
801013f1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
801013f8:	8b 45 08             	mov    0x8(%ebp),%eax
801013fb:	83 ec 08             	sub    $0x8,%esp
801013fe:	8d 55 d8             	lea    -0x28(%ebp),%edx
80101401:	52                   	push   %edx
80101402:	50                   	push   %eax
80101403:	e8 4d ff ff ff       	call   80101355 <readsb>
80101408:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
8010140b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101412:	e9 15 01 00 00       	jmp    8010152c <balloc+0x141>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
80101417:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010141a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101420:	85 c0                	test   %eax,%eax
80101422:	0f 48 c2             	cmovs  %edx,%eax
80101425:	c1 f8 0c             	sar    $0xc,%eax
80101428:	89 c2                	mov    %eax,%edx
8010142a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010142d:	c1 e8 03             	shr    $0x3,%eax
80101430:	01 d0                	add    %edx,%eax
80101432:	83 c0 03             	add    $0x3,%eax
80101435:	83 ec 08             	sub    $0x8,%esp
80101438:	50                   	push   %eax
80101439:	ff 75 08             	pushl  0x8(%ebp)
8010143c:	e8 75 ed ff ff       	call   801001b6 <bread>
80101441:	83 c4 10             	add    $0x10,%esp
80101444:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101447:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010144e:	e9 a6 00 00 00       	jmp    801014f9 <balloc+0x10e>
      m = 1 << (bi % 8);
80101453:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101456:	99                   	cltd   
80101457:	c1 ea 1d             	shr    $0x1d,%edx
8010145a:	01 d0                	add    %edx,%eax
8010145c:	83 e0 07             	and    $0x7,%eax
8010145f:	29 d0                	sub    %edx,%eax
80101461:	ba 01 00 00 00       	mov    $0x1,%edx
80101466:	89 c1                	mov    %eax,%ecx
80101468:	d3 e2                	shl    %cl,%edx
8010146a:	89 d0                	mov    %edx,%eax
8010146c:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010146f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101472:	8d 50 07             	lea    0x7(%eax),%edx
80101475:	85 c0                	test   %eax,%eax
80101477:	0f 48 c2             	cmovs  %edx,%eax
8010147a:	c1 f8 03             	sar    $0x3,%eax
8010147d:	89 c2                	mov    %eax,%edx
8010147f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101482:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
80101487:	0f b6 c0             	movzbl %al,%eax
8010148a:	23 45 e8             	and    -0x18(%ebp),%eax
8010148d:	85 c0                	test   %eax,%eax
8010148f:	75 64                	jne    801014f5 <balloc+0x10a>
        bp->data[bi/8] |= m;  // Mark block in use.
80101491:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101494:	8d 50 07             	lea    0x7(%eax),%edx
80101497:	85 c0                	test   %eax,%eax
80101499:	0f 48 c2             	cmovs  %edx,%eax
8010149c:	c1 f8 03             	sar    $0x3,%eax
8010149f:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014a2:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801014a7:	89 d1                	mov    %edx,%ecx
801014a9:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014ac:	09 ca                	or     %ecx,%edx
801014ae:	89 d1                	mov    %edx,%ecx
801014b0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014b3:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801014b7:	83 ec 0c             	sub    $0xc,%esp
801014ba:	ff 75 ec             	pushl  -0x14(%ebp)
801014bd:	e8 71 1e 00 00       	call   80103333 <log_write>
801014c2:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801014c5:	83 ec 0c             	sub    $0xc,%esp
801014c8:	ff 75 ec             	pushl  -0x14(%ebp)
801014cb:	e8 5e ed ff ff       	call   8010022e <brelse>
801014d0:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
801014d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014d9:	01 c2                	add    %eax,%edx
801014db:	8b 45 08             	mov    0x8(%ebp),%eax
801014de:	83 ec 08             	sub    $0x8,%esp
801014e1:	52                   	push   %edx
801014e2:	50                   	push   %eax
801014e3:	e8 af fe ff ff       	call   80101397 <bzero>
801014e8:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801014eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014f1:	01 d0                	add    %edx,%eax
801014f3:	eb 52                	jmp    80101547 <balloc+0x15c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014f5:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801014f9:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101500:	7f 15                	jg     80101517 <balloc+0x12c>
80101502:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101505:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101508:	01 d0                	add    %edx,%eax
8010150a:	89 c2                	mov    %eax,%edx
8010150c:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010150f:	39 c2                	cmp    %eax,%edx
80101511:	0f 82 3c ff ff ff    	jb     80101453 <balloc+0x68>
      }
    }
    brelse(bp);
80101517:	83 ec 0c             	sub    $0xc,%esp
8010151a:	ff 75 ec             	pushl  -0x14(%ebp)
8010151d:	e8 0c ed ff ff       	call   8010022e <brelse>
80101522:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101525:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010152c:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010152f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101532:	39 c2                	cmp    %eax,%edx
80101534:	0f 87 dd fe ff ff    	ja     80101417 <balloc+0x2c>
  }
  panic("balloc: out of blocks");
8010153a:	83 ec 0c             	sub    $0xc,%esp
8010153d:	68 c9 81 10 80       	push   $0x801081c9
80101542:	e8 1f f0 ff ff       	call   80100566 <panic>
}
80101547:	c9                   	leave  
80101548:	c3                   	ret    

80101549 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101549:	55                   	push   %ebp
8010154a:	89 e5                	mov    %esp,%ebp
8010154c:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
8010154f:	83 ec 08             	sub    $0x8,%esp
80101552:	8d 45 dc             	lea    -0x24(%ebp),%eax
80101555:	50                   	push   %eax
80101556:	ff 75 08             	pushl  0x8(%ebp)
80101559:	e8 f7 fd ff ff       	call   80101355 <readsb>
8010155e:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb.ninodes));
80101561:	8b 45 0c             	mov    0xc(%ebp),%eax
80101564:	c1 e8 0c             	shr    $0xc,%eax
80101567:	89 c2                	mov    %eax,%edx
80101569:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010156c:	c1 e8 03             	shr    $0x3,%eax
8010156f:	01 d0                	add    %edx,%eax
80101571:	8d 50 03             	lea    0x3(%eax),%edx
80101574:	8b 45 08             	mov    0x8(%ebp),%eax
80101577:	83 ec 08             	sub    $0x8,%esp
8010157a:	52                   	push   %edx
8010157b:	50                   	push   %eax
8010157c:	e8 35 ec ff ff       	call   801001b6 <bread>
80101581:	83 c4 10             	add    $0x10,%esp
80101584:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101587:	8b 45 0c             	mov    0xc(%ebp),%eax
8010158a:	25 ff 0f 00 00       	and    $0xfff,%eax
8010158f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101592:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101595:	99                   	cltd   
80101596:	c1 ea 1d             	shr    $0x1d,%edx
80101599:	01 d0                	add    %edx,%eax
8010159b:	83 e0 07             	and    $0x7,%eax
8010159e:	29 d0                	sub    %edx,%eax
801015a0:	ba 01 00 00 00       	mov    $0x1,%edx
801015a5:	89 c1                	mov    %eax,%ecx
801015a7:	d3 e2                	shl    %cl,%edx
801015a9:	89 d0                	mov    %edx,%eax
801015ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015b1:	8d 50 07             	lea    0x7(%eax),%edx
801015b4:	85 c0                	test   %eax,%eax
801015b6:	0f 48 c2             	cmovs  %edx,%eax
801015b9:	c1 f8 03             	sar    $0x3,%eax
801015bc:	89 c2                	mov    %eax,%edx
801015be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015c1:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801015c6:	0f b6 c0             	movzbl %al,%eax
801015c9:	23 45 ec             	and    -0x14(%ebp),%eax
801015cc:	85 c0                	test   %eax,%eax
801015ce:	75 0d                	jne    801015dd <bfree+0x94>
    panic("freeing free block");
801015d0:	83 ec 0c             	sub    $0xc,%esp
801015d3:	68 df 81 10 80       	push   $0x801081df
801015d8:	e8 89 ef ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
801015dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015e0:	8d 50 07             	lea    0x7(%eax),%edx
801015e3:	85 c0                	test   %eax,%eax
801015e5:	0f 48 c2             	cmovs  %edx,%eax
801015e8:	c1 f8 03             	sar    $0x3,%eax
801015eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015ee:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801015f3:	89 d1                	mov    %edx,%ecx
801015f5:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015f8:	f7 d2                	not    %edx
801015fa:	21 ca                	and    %ecx,%edx
801015fc:	89 d1                	mov    %edx,%ecx
801015fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101601:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101605:	83 ec 0c             	sub    $0xc,%esp
80101608:	ff 75 f4             	pushl  -0xc(%ebp)
8010160b:	e8 23 1d 00 00       	call   80103333 <log_write>
80101610:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101613:	83 ec 0c             	sub    $0xc,%esp
80101616:	ff 75 f4             	pushl  -0xc(%ebp)
80101619:	e8 10 ec ff ff       	call   8010022e <brelse>
8010161e:	83 c4 10             	add    $0x10,%esp
}
80101621:	90                   	nop
80101622:	c9                   	leave  
80101623:	c3                   	ret    

80101624 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
80101624:	55                   	push   %ebp
80101625:	89 e5                	mov    %esp,%ebp
80101627:	83 ec 08             	sub    $0x8,%esp
  initlock(&icache.lock, "icache");
8010162a:	83 ec 08             	sub    $0x8,%esp
8010162d:	68 f2 81 10 80       	push   $0x801081f2
80101632:	68 60 e8 10 80       	push   $0x8010e860
80101637:	e8 21 36 00 00       	call   80104c5d <initlock>
8010163c:	83 c4 10             	add    $0x10,%esp
}
8010163f:	90                   	nop
80101640:	c9                   	leave  
80101641:	c3                   	ret    

80101642 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101642:	55                   	push   %ebp
80101643:	89 e5                	mov    %esp,%ebp
80101645:	83 ec 38             	sub    $0x38,%esp
80101648:	8b 45 0c             	mov    0xc(%ebp),%eax
8010164b:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
8010164f:	8b 45 08             	mov    0x8(%ebp),%eax
80101652:	83 ec 08             	sub    $0x8,%esp
80101655:	8d 55 dc             	lea    -0x24(%ebp),%edx
80101658:	52                   	push   %edx
80101659:	50                   	push   %eax
8010165a:	e8 f6 fc ff ff       	call   80101355 <readsb>
8010165f:	83 c4 10             	add    $0x10,%esp

  for(inum = 1; inum < sb.ninodes; inum++){
80101662:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101669:	e9 98 00 00 00       	jmp    80101706 <ialloc+0xc4>
    bp = bread(dev, IBLOCK(inum));
8010166e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101671:	c1 e8 03             	shr    $0x3,%eax
80101674:	83 c0 02             	add    $0x2,%eax
80101677:	83 ec 08             	sub    $0x8,%esp
8010167a:	50                   	push   %eax
8010167b:	ff 75 08             	pushl  0x8(%ebp)
8010167e:	e8 33 eb ff ff       	call   801001b6 <bread>
80101683:	83 c4 10             	add    $0x10,%esp
80101686:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101689:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010168c:	8d 50 18             	lea    0x18(%eax),%edx
8010168f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101692:	83 e0 07             	and    $0x7,%eax
80101695:	c1 e0 06             	shl    $0x6,%eax
80101698:	01 d0                	add    %edx,%eax
8010169a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010169d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016a0:	0f b7 00             	movzwl (%eax),%eax
801016a3:	66 85 c0             	test   %ax,%ax
801016a6:	75 4c                	jne    801016f4 <ialloc+0xb2>
      memset(dip, 0, sizeof(*dip));
801016a8:	83 ec 04             	sub    $0x4,%esp
801016ab:	6a 40                	push   $0x40
801016ad:	6a 00                	push   $0x0
801016af:	ff 75 ec             	pushl  -0x14(%ebp)
801016b2:	e8 2b 38 00 00       	call   80104ee2 <memset>
801016b7:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801016ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016bd:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
801016c1:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801016c4:	83 ec 0c             	sub    $0xc,%esp
801016c7:	ff 75 f0             	pushl  -0x10(%ebp)
801016ca:	e8 64 1c 00 00       	call   80103333 <log_write>
801016cf:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801016d2:	83 ec 0c             	sub    $0xc,%esp
801016d5:	ff 75 f0             	pushl  -0x10(%ebp)
801016d8:	e8 51 eb ff ff       	call   8010022e <brelse>
801016dd:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801016e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016e3:	83 ec 08             	sub    $0x8,%esp
801016e6:	50                   	push   %eax
801016e7:	ff 75 08             	pushl  0x8(%ebp)
801016ea:	e8 ef 00 00 00       	call   801017de <iget>
801016ef:	83 c4 10             	add    $0x10,%esp
801016f2:	eb 2d                	jmp    80101721 <ialloc+0xdf>
    }
    brelse(bp);
801016f4:	83 ec 0c             	sub    $0xc,%esp
801016f7:	ff 75 f0             	pushl  -0x10(%ebp)
801016fa:	e8 2f eb ff ff       	call   8010022e <brelse>
801016ff:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
80101702:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101706:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101709:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010170c:	39 c2                	cmp    %eax,%edx
8010170e:	0f 87 5a ff ff ff    	ja     8010166e <ialloc+0x2c>
  }
  panic("ialloc: no inodes");
80101714:	83 ec 0c             	sub    $0xc,%esp
80101717:	68 f9 81 10 80       	push   $0x801081f9
8010171c:	e8 45 ee ff ff       	call   80100566 <panic>
}
80101721:	c9                   	leave  
80101722:	c3                   	ret    

80101723 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101723:	55                   	push   %ebp
80101724:	89 e5                	mov    %esp,%ebp
80101726:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
80101729:	8b 45 08             	mov    0x8(%ebp),%eax
8010172c:	8b 40 04             	mov    0x4(%eax),%eax
8010172f:	c1 e8 03             	shr    $0x3,%eax
80101732:	8d 50 02             	lea    0x2(%eax),%edx
80101735:	8b 45 08             	mov    0x8(%ebp),%eax
80101738:	8b 00                	mov    (%eax),%eax
8010173a:	83 ec 08             	sub    $0x8,%esp
8010173d:	52                   	push   %edx
8010173e:	50                   	push   %eax
8010173f:	e8 72 ea ff ff       	call   801001b6 <bread>
80101744:	83 c4 10             	add    $0x10,%esp
80101747:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010174a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010174d:	8d 50 18             	lea    0x18(%eax),%edx
80101750:	8b 45 08             	mov    0x8(%ebp),%eax
80101753:	8b 40 04             	mov    0x4(%eax),%eax
80101756:	83 e0 07             	and    $0x7,%eax
80101759:	c1 e0 06             	shl    $0x6,%eax
8010175c:	01 d0                	add    %edx,%eax
8010175e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101761:	8b 45 08             	mov    0x8(%ebp),%eax
80101764:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101768:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010176b:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010176e:	8b 45 08             	mov    0x8(%ebp),%eax
80101771:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101775:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101778:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010177c:	8b 45 08             	mov    0x8(%ebp),%eax
8010177f:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101783:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101786:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010178a:	8b 45 08             	mov    0x8(%ebp),%eax
8010178d:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101791:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101794:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101798:	8b 45 08             	mov    0x8(%ebp),%eax
8010179b:	8b 50 18             	mov    0x18(%eax),%edx
8010179e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017a1:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801017a4:	8b 45 08             	mov    0x8(%ebp),%eax
801017a7:	8d 50 1c             	lea    0x1c(%eax),%edx
801017aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017ad:	83 c0 0c             	add    $0xc,%eax
801017b0:	83 ec 04             	sub    $0x4,%esp
801017b3:	6a 34                	push   $0x34
801017b5:	52                   	push   %edx
801017b6:	50                   	push   %eax
801017b7:	e8 e5 37 00 00       	call   80104fa1 <memmove>
801017bc:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801017bf:	83 ec 0c             	sub    $0xc,%esp
801017c2:	ff 75 f4             	pushl  -0xc(%ebp)
801017c5:	e8 69 1b 00 00       	call   80103333 <log_write>
801017ca:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801017cd:	83 ec 0c             	sub    $0xc,%esp
801017d0:	ff 75 f4             	pushl  -0xc(%ebp)
801017d3:	e8 56 ea ff ff       	call   8010022e <brelse>
801017d8:	83 c4 10             	add    $0x10,%esp
}
801017db:	90                   	nop
801017dc:	c9                   	leave  
801017dd:	c3                   	ret    

801017de <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801017de:	55                   	push   %ebp
801017df:	89 e5                	mov    %esp,%ebp
801017e1:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801017e4:	83 ec 0c             	sub    $0xc,%esp
801017e7:	68 60 e8 10 80       	push   $0x8010e860
801017ec:	e8 8e 34 00 00       	call   80104c7f <acquire>
801017f1:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801017f4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017fb:	c7 45 f4 94 e8 10 80 	movl   $0x8010e894,-0xc(%ebp)
80101802:	eb 5d                	jmp    80101861 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101804:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101807:	8b 40 08             	mov    0x8(%eax),%eax
8010180a:	85 c0                	test   %eax,%eax
8010180c:	7e 39                	jle    80101847 <iget+0x69>
8010180e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101811:	8b 00                	mov    (%eax),%eax
80101813:	3b 45 08             	cmp    0x8(%ebp),%eax
80101816:	75 2f                	jne    80101847 <iget+0x69>
80101818:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010181b:	8b 40 04             	mov    0x4(%eax),%eax
8010181e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101821:	75 24                	jne    80101847 <iget+0x69>
      ip->ref++;
80101823:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101826:	8b 40 08             	mov    0x8(%eax),%eax
80101829:	8d 50 01             	lea    0x1(%eax),%edx
8010182c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010182f:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101832:	83 ec 0c             	sub    $0xc,%esp
80101835:	68 60 e8 10 80       	push   $0x8010e860
8010183a:	e8 a7 34 00 00       	call   80104ce6 <release>
8010183f:	83 c4 10             	add    $0x10,%esp
      return ip;
80101842:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101845:	eb 74                	jmp    801018bb <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101847:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010184b:	75 10                	jne    8010185d <iget+0x7f>
8010184d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101850:	8b 40 08             	mov    0x8(%eax),%eax
80101853:	85 c0                	test   %eax,%eax
80101855:	75 06                	jne    8010185d <iget+0x7f>
      empty = ip;
80101857:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010185a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010185d:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101861:	81 7d f4 34 f8 10 80 	cmpl   $0x8010f834,-0xc(%ebp)
80101868:	72 9a                	jb     80101804 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010186a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010186e:	75 0d                	jne    8010187d <iget+0x9f>
    panic("iget: no inodes");
80101870:	83 ec 0c             	sub    $0xc,%esp
80101873:	68 0b 82 10 80       	push   $0x8010820b
80101878:	e8 e9 ec ff ff       	call   80100566 <panic>

  ip = empty;
8010187d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101880:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101883:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101886:	8b 55 08             	mov    0x8(%ebp),%edx
80101889:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010188b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010188e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101891:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101894:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101897:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
8010189e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
801018a8:	83 ec 0c             	sub    $0xc,%esp
801018ab:	68 60 e8 10 80       	push   $0x8010e860
801018b0:	e8 31 34 00 00       	call   80104ce6 <release>
801018b5:	83 c4 10             	add    $0x10,%esp

  return ip;
801018b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801018bb:	c9                   	leave  
801018bc:	c3                   	ret    

801018bd <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801018bd:	55                   	push   %ebp
801018be:	89 e5                	mov    %esp,%ebp
801018c0:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801018c3:	83 ec 0c             	sub    $0xc,%esp
801018c6:	68 60 e8 10 80       	push   $0x8010e860
801018cb:	e8 af 33 00 00       	call   80104c7f <acquire>
801018d0:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801018d3:	8b 45 08             	mov    0x8(%ebp),%eax
801018d6:	8b 40 08             	mov    0x8(%eax),%eax
801018d9:	8d 50 01             	lea    0x1(%eax),%edx
801018dc:	8b 45 08             	mov    0x8(%ebp),%eax
801018df:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801018e2:	83 ec 0c             	sub    $0xc,%esp
801018e5:	68 60 e8 10 80       	push   $0x8010e860
801018ea:	e8 f7 33 00 00       	call   80104ce6 <release>
801018ef:	83 c4 10             	add    $0x10,%esp
  return ip;
801018f2:	8b 45 08             	mov    0x8(%ebp),%eax
}
801018f5:	c9                   	leave  
801018f6:	c3                   	ret    

801018f7 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801018f7:	55                   	push   %ebp
801018f8:	89 e5                	mov    %esp,%ebp
801018fa:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801018fd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101901:	74 0a                	je     8010190d <ilock+0x16>
80101903:	8b 45 08             	mov    0x8(%ebp),%eax
80101906:	8b 40 08             	mov    0x8(%eax),%eax
80101909:	85 c0                	test   %eax,%eax
8010190b:	7f 0d                	jg     8010191a <ilock+0x23>
    panic("ilock");
8010190d:	83 ec 0c             	sub    $0xc,%esp
80101910:	68 1b 82 10 80       	push   $0x8010821b
80101915:	e8 4c ec ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
8010191a:	83 ec 0c             	sub    $0xc,%esp
8010191d:	68 60 e8 10 80       	push   $0x8010e860
80101922:	e8 58 33 00 00       	call   80104c7f <acquire>
80101927:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
8010192a:	eb 13                	jmp    8010193f <ilock+0x48>
    sleep(ip, &icache.lock);
8010192c:	83 ec 08             	sub    $0x8,%esp
8010192f:	68 60 e8 10 80       	push   $0x8010e860
80101934:	ff 75 08             	pushl  0x8(%ebp)
80101937:	e8 4a 30 00 00       	call   80104986 <sleep>
8010193c:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
8010193f:	8b 45 08             	mov    0x8(%ebp),%eax
80101942:	8b 40 0c             	mov    0xc(%eax),%eax
80101945:	83 e0 01             	and    $0x1,%eax
80101948:	85 c0                	test   %eax,%eax
8010194a:	75 e0                	jne    8010192c <ilock+0x35>
  ip->flags |= I_BUSY;
8010194c:	8b 45 08             	mov    0x8(%ebp),%eax
8010194f:	8b 40 0c             	mov    0xc(%eax),%eax
80101952:	83 c8 01             	or     $0x1,%eax
80101955:	89 c2                	mov    %eax,%edx
80101957:	8b 45 08             	mov    0x8(%ebp),%eax
8010195a:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
8010195d:	83 ec 0c             	sub    $0xc,%esp
80101960:	68 60 e8 10 80       	push   $0x8010e860
80101965:	e8 7c 33 00 00       	call   80104ce6 <release>
8010196a:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
8010196d:	8b 45 08             	mov    0x8(%ebp),%eax
80101970:	8b 40 0c             	mov    0xc(%eax),%eax
80101973:	83 e0 02             	and    $0x2,%eax
80101976:	85 c0                	test   %eax,%eax
80101978:	0f 85 ce 00 00 00    	jne    80101a4c <ilock+0x155>
    bp = bread(ip->dev, IBLOCK(ip->inum));
8010197e:	8b 45 08             	mov    0x8(%ebp),%eax
80101981:	8b 40 04             	mov    0x4(%eax),%eax
80101984:	c1 e8 03             	shr    $0x3,%eax
80101987:	8d 50 02             	lea    0x2(%eax),%edx
8010198a:	8b 45 08             	mov    0x8(%ebp),%eax
8010198d:	8b 00                	mov    (%eax),%eax
8010198f:	83 ec 08             	sub    $0x8,%esp
80101992:	52                   	push   %edx
80101993:	50                   	push   %eax
80101994:	e8 1d e8 ff ff       	call   801001b6 <bread>
80101999:	83 c4 10             	add    $0x10,%esp
8010199c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
8010199f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a2:	8d 50 18             	lea    0x18(%eax),%edx
801019a5:	8b 45 08             	mov    0x8(%ebp),%eax
801019a8:	8b 40 04             	mov    0x4(%eax),%eax
801019ab:	83 e0 07             	and    $0x7,%eax
801019ae:	c1 e0 06             	shl    $0x6,%eax
801019b1:	01 d0                	add    %edx,%eax
801019b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
801019b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019b9:	0f b7 10             	movzwl (%eax),%edx
801019bc:	8b 45 08             	mov    0x8(%ebp),%eax
801019bf:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
801019c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019c6:	0f b7 50 02          	movzwl 0x2(%eax),%edx
801019ca:	8b 45 08             	mov    0x8(%ebp),%eax
801019cd:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
801019d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019d4:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801019d8:	8b 45 08             	mov    0x8(%ebp),%eax
801019db:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
801019df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019e2:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801019e6:	8b 45 08             	mov    0x8(%ebp),%eax
801019e9:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
801019ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019f0:	8b 50 08             	mov    0x8(%eax),%edx
801019f3:	8b 45 08             	mov    0x8(%ebp),%eax
801019f6:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801019f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019fc:	8d 50 0c             	lea    0xc(%eax),%edx
801019ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101a02:	83 c0 1c             	add    $0x1c,%eax
80101a05:	83 ec 04             	sub    $0x4,%esp
80101a08:	6a 34                	push   $0x34
80101a0a:	52                   	push   %edx
80101a0b:	50                   	push   %eax
80101a0c:	e8 90 35 00 00       	call   80104fa1 <memmove>
80101a11:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101a14:	83 ec 0c             	sub    $0xc,%esp
80101a17:	ff 75 f4             	pushl  -0xc(%ebp)
80101a1a:	e8 0f e8 ff ff       	call   8010022e <brelse>
80101a1f:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101a22:	8b 45 08             	mov    0x8(%ebp),%eax
80101a25:	8b 40 0c             	mov    0xc(%eax),%eax
80101a28:	83 c8 02             	or     $0x2,%eax
80101a2b:	89 c2                	mov    %eax,%edx
80101a2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a30:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101a33:	8b 45 08             	mov    0x8(%ebp),%eax
80101a36:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101a3a:	66 85 c0             	test   %ax,%ax
80101a3d:	75 0d                	jne    80101a4c <ilock+0x155>
      panic("ilock: no type");
80101a3f:	83 ec 0c             	sub    $0xc,%esp
80101a42:	68 21 82 10 80       	push   $0x80108221
80101a47:	e8 1a eb ff ff       	call   80100566 <panic>
  }
}
80101a4c:	90                   	nop
80101a4d:	c9                   	leave  
80101a4e:	c3                   	ret    

80101a4f <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101a4f:	55                   	push   %ebp
80101a50:	89 e5                	mov    %esp,%ebp
80101a52:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101a55:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a59:	74 17                	je     80101a72 <iunlock+0x23>
80101a5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5e:	8b 40 0c             	mov    0xc(%eax),%eax
80101a61:	83 e0 01             	and    $0x1,%eax
80101a64:	85 c0                	test   %eax,%eax
80101a66:	74 0a                	je     80101a72 <iunlock+0x23>
80101a68:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6b:	8b 40 08             	mov    0x8(%eax),%eax
80101a6e:	85 c0                	test   %eax,%eax
80101a70:	7f 0d                	jg     80101a7f <iunlock+0x30>
    panic("iunlock");
80101a72:	83 ec 0c             	sub    $0xc,%esp
80101a75:	68 30 82 10 80       	push   $0x80108230
80101a7a:	e8 e7 ea ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101a7f:	83 ec 0c             	sub    $0xc,%esp
80101a82:	68 60 e8 10 80       	push   $0x8010e860
80101a87:	e8 f3 31 00 00       	call   80104c7f <acquire>
80101a8c:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101a8f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a92:	8b 40 0c             	mov    0xc(%eax),%eax
80101a95:	83 e0 fe             	and    $0xfffffffe,%eax
80101a98:	89 c2                	mov    %eax,%edx
80101a9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9d:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101aa0:	83 ec 0c             	sub    $0xc,%esp
80101aa3:	ff 75 08             	pushl  0x8(%ebp)
80101aa6:	e8 c6 2f 00 00       	call   80104a71 <wakeup>
80101aab:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101aae:	83 ec 0c             	sub    $0xc,%esp
80101ab1:	68 60 e8 10 80       	push   $0x8010e860
80101ab6:	e8 2b 32 00 00       	call   80104ce6 <release>
80101abb:	83 c4 10             	add    $0x10,%esp
}
80101abe:	90                   	nop
80101abf:	c9                   	leave  
80101ac0:	c3                   	ret    

80101ac1 <iput>:
// be recycled.
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
void
iput(struct inode *ip)
{
80101ac1:	55                   	push   %ebp
80101ac2:	89 e5                	mov    %esp,%ebp
80101ac4:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101ac7:	83 ec 0c             	sub    $0xc,%esp
80101aca:	68 60 e8 10 80       	push   $0x8010e860
80101acf:	e8 ab 31 00 00       	call   80104c7f <acquire>
80101ad4:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101ad7:	8b 45 08             	mov    0x8(%ebp),%eax
80101ada:	8b 40 08             	mov    0x8(%eax),%eax
80101add:	83 f8 01             	cmp    $0x1,%eax
80101ae0:	0f 85 a9 00 00 00    	jne    80101b8f <iput+0xce>
80101ae6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae9:	8b 40 0c             	mov    0xc(%eax),%eax
80101aec:	83 e0 02             	and    $0x2,%eax
80101aef:	85 c0                	test   %eax,%eax
80101af1:	0f 84 98 00 00 00    	je     80101b8f <iput+0xce>
80101af7:	8b 45 08             	mov    0x8(%ebp),%eax
80101afa:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101afe:	66 85 c0             	test   %ax,%ax
80101b01:	0f 85 88 00 00 00    	jne    80101b8f <iput+0xce>
    // inode has no links: truncate and free inode.
    if(ip->flags & I_BUSY)
80101b07:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0a:	8b 40 0c             	mov    0xc(%eax),%eax
80101b0d:	83 e0 01             	and    $0x1,%eax
80101b10:	85 c0                	test   %eax,%eax
80101b12:	74 0d                	je     80101b21 <iput+0x60>
      panic("iput busy");
80101b14:	83 ec 0c             	sub    $0xc,%esp
80101b17:	68 38 82 10 80       	push   $0x80108238
80101b1c:	e8 45 ea ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101b21:	8b 45 08             	mov    0x8(%ebp),%eax
80101b24:	8b 40 0c             	mov    0xc(%eax),%eax
80101b27:	83 c8 01             	or     $0x1,%eax
80101b2a:	89 c2                	mov    %eax,%edx
80101b2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2f:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101b32:	83 ec 0c             	sub    $0xc,%esp
80101b35:	68 60 e8 10 80       	push   $0x8010e860
80101b3a:	e8 a7 31 00 00       	call   80104ce6 <release>
80101b3f:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101b42:	83 ec 0c             	sub    $0xc,%esp
80101b45:	ff 75 08             	pushl  0x8(%ebp)
80101b48:	e8 a8 01 00 00       	call   80101cf5 <itrunc>
80101b4d:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101b50:	8b 45 08             	mov    0x8(%ebp),%eax
80101b53:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101b59:	83 ec 0c             	sub    $0xc,%esp
80101b5c:	ff 75 08             	pushl  0x8(%ebp)
80101b5f:	e8 bf fb ff ff       	call   80101723 <iupdate>
80101b64:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101b67:	83 ec 0c             	sub    $0xc,%esp
80101b6a:	68 60 e8 10 80       	push   $0x8010e860
80101b6f:	e8 0b 31 00 00       	call   80104c7f <acquire>
80101b74:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101b77:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101b81:	83 ec 0c             	sub    $0xc,%esp
80101b84:	ff 75 08             	pushl  0x8(%ebp)
80101b87:	e8 e5 2e 00 00       	call   80104a71 <wakeup>
80101b8c:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101b8f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b92:	8b 40 08             	mov    0x8(%eax),%eax
80101b95:	8d 50 ff             	lea    -0x1(%eax),%edx
80101b98:	8b 45 08             	mov    0x8(%ebp),%eax
80101b9b:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b9e:	83 ec 0c             	sub    $0xc,%esp
80101ba1:	68 60 e8 10 80       	push   $0x8010e860
80101ba6:	e8 3b 31 00 00       	call   80104ce6 <release>
80101bab:	83 c4 10             	add    $0x10,%esp
}
80101bae:	90                   	nop
80101baf:	c9                   	leave  
80101bb0:	c3                   	ret    

80101bb1 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101bb1:	55                   	push   %ebp
80101bb2:	89 e5                	mov    %esp,%ebp
80101bb4:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101bb7:	83 ec 0c             	sub    $0xc,%esp
80101bba:	ff 75 08             	pushl  0x8(%ebp)
80101bbd:	e8 8d fe ff ff       	call   80101a4f <iunlock>
80101bc2:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101bc5:	83 ec 0c             	sub    $0xc,%esp
80101bc8:	ff 75 08             	pushl  0x8(%ebp)
80101bcb:	e8 f1 fe ff ff       	call   80101ac1 <iput>
80101bd0:	83 c4 10             	add    $0x10,%esp
}
80101bd3:	90                   	nop
80101bd4:	c9                   	leave  
80101bd5:	c3                   	ret    

80101bd6 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101bd6:	55                   	push   %ebp
80101bd7:	89 e5                	mov    %esp,%ebp
80101bd9:	53                   	push   %ebx
80101bda:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101bdd:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101be1:	77 42                	ja     80101c25 <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101be3:	8b 45 08             	mov    0x8(%ebp),%eax
80101be6:	8b 55 0c             	mov    0xc(%ebp),%edx
80101be9:	83 c2 04             	add    $0x4,%edx
80101bec:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101bf0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bf3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101bf7:	75 24                	jne    80101c1d <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101bf9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfc:	8b 00                	mov    (%eax),%eax
80101bfe:	83 ec 0c             	sub    $0xc,%esp
80101c01:	50                   	push   %eax
80101c02:	e8 e4 f7 ff ff       	call   801013eb <balloc>
80101c07:	83 c4 10             	add    $0x10,%esp
80101c0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c10:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c13:	8d 4a 04             	lea    0x4(%edx),%ecx
80101c16:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c19:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c20:	e9 cb 00 00 00       	jmp    80101cf0 <bmap+0x11a>
  }
  bn -= NDIRECT;
80101c25:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c29:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c2d:	0f 87 b0 00 00 00    	ja     80101ce3 <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c33:	8b 45 08             	mov    0x8(%ebp),%eax
80101c36:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c39:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c3c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c40:	75 1d                	jne    80101c5f <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101c42:	8b 45 08             	mov    0x8(%ebp),%eax
80101c45:	8b 00                	mov    (%eax),%eax
80101c47:	83 ec 0c             	sub    $0xc,%esp
80101c4a:	50                   	push   %eax
80101c4b:	e8 9b f7 ff ff       	call   801013eb <balloc>
80101c50:	83 c4 10             	add    $0x10,%esp
80101c53:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c56:	8b 45 08             	mov    0x8(%ebp),%eax
80101c59:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c5c:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101c5f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c62:	8b 00                	mov    (%eax),%eax
80101c64:	83 ec 08             	sub    $0x8,%esp
80101c67:	ff 75 f4             	pushl  -0xc(%ebp)
80101c6a:	50                   	push   %eax
80101c6b:	e8 46 e5 ff ff       	call   801001b6 <bread>
80101c70:	83 c4 10             	add    $0x10,%esp
80101c73:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101c76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c79:	83 c0 18             	add    $0x18,%eax
80101c7c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101c7f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c82:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101c89:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c8c:	01 d0                	add    %edx,%eax
80101c8e:	8b 00                	mov    (%eax),%eax
80101c90:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c93:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c97:	75 37                	jne    80101cd0 <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80101c99:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c9c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ca3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ca6:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101ca9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cac:	8b 00                	mov    (%eax),%eax
80101cae:	83 ec 0c             	sub    $0xc,%esp
80101cb1:	50                   	push   %eax
80101cb2:	e8 34 f7 ff ff       	call   801013eb <balloc>
80101cb7:	83 c4 10             	add    $0x10,%esp
80101cba:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cc0:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101cc2:	83 ec 0c             	sub    $0xc,%esp
80101cc5:	ff 75 f0             	pushl  -0x10(%ebp)
80101cc8:	e8 66 16 00 00       	call   80103333 <log_write>
80101ccd:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101cd0:	83 ec 0c             	sub    $0xc,%esp
80101cd3:	ff 75 f0             	pushl  -0x10(%ebp)
80101cd6:	e8 53 e5 ff ff       	call   8010022e <brelse>
80101cdb:	83 c4 10             	add    $0x10,%esp
    return addr;
80101cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ce1:	eb 0d                	jmp    80101cf0 <bmap+0x11a>
  }

  panic("bmap: out of range");
80101ce3:	83 ec 0c             	sub    $0xc,%esp
80101ce6:	68 42 82 10 80       	push   $0x80108242
80101ceb:	e8 76 e8 ff ff       	call   80100566 <panic>
}
80101cf0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101cf3:	c9                   	leave  
80101cf4:	c3                   	ret    

80101cf5 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101cf5:	55                   	push   %ebp
80101cf6:	89 e5                	mov    %esp,%ebp
80101cf8:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101cfb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d02:	eb 45                	jmp    80101d49 <itrunc+0x54>
    if(ip->addrs[i]){
80101d04:	8b 45 08             	mov    0x8(%ebp),%eax
80101d07:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d0a:	83 c2 04             	add    $0x4,%edx
80101d0d:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d11:	85 c0                	test   %eax,%eax
80101d13:	74 30                	je     80101d45 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d15:	8b 45 08             	mov    0x8(%ebp),%eax
80101d18:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d1b:	83 c2 04             	add    $0x4,%edx
80101d1e:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d22:	8b 55 08             	mov    0x8(%ebp),%edx
80101d25:	8b 12                	mov    (%edx),%edx
80101d27:	83 ec 08             	sub    $0x8,%esp
80101d2a:	50                   	push   %eax
80101d2b:	52                   	push   %edx
80101d2c:	e8 18 f8 ff ff       	call   80101549 <bfree>
80101d31:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101d34:	8b 45 08             	mov    0x8(%ebp),%eax
80101d37:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d3a:	83 c2 04             	add    $0x4,%edx
80101d3d:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101d44:	00 
  for(i = 0; i < NDIRECT; i++){
80101d45:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101d49:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101d4d:	7e b5                	jle    80101d04 <itrunc+0xf>
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101d4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d52:	8b 40 4c             	mov    0x4c(%eax),%eax
80101d55:	85 c0                	test   %eax,%eax
80101d57:	0f 84 a1 00 00 00    	je     80101dfe <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101d5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d60:	8b 50 4c             	mov    0x4c(%eax),%edx
80101d63:	8b 45 08             	mov    0x8(%ebp),%eax
80101d66:	8b 00                	mov    (%eax),%eax
80101d68:	83 ec 08             	sub    $0x8,%esp
80101d6b:	52                   	push   %edx
80101d6c:	50                   	push   %eax
80101d6d:	e8 44 e4 ff ff       	call   801001b6 <bread>
80101d72:	83 c4 10             	add    $0x10,%esp
80101d75:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101d78:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d7b:	83 c0 18             	add    $0x18,%eax
80101d7e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101d81:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101d88:	eb 3c                	jmp    80101dc6 <itrunc+0xd1>
      if(a[j])
80101d8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d8d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d94:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101d97:	01 d0                	add    %edx,%eax
80101d99:	8b 00                	mov    (%eax),%eax
80101d9b:	85 c0                	test   %eax,%eax
80101d9d:	74 23                	je     80101dc2 <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101d9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101da2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101da9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101dac:	01 d0                	add    %edx,%eax
80101dae:	8b 00                	mov    (%eax),%eax
80101db0:	8b 55 08             	mov    0x8(%ebp),%edx
80101db3:	8b 12                	mov    (%edx),%edx
80101db5:	83 ec 08             	sub    $0x8,%esp
80101db8:	50                   	push   %eax
80101db9:	52                   	push   %edx
80101dba:	e8 8a f7 ff ff       	call   80101549 <bfree>
80101dbf:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101dc2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101dc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dc9:	83 f8 7f             	cmp    $0x7f,%eax
80101dcc:	76 bc                	jbe    80101d8a <itrunc+0x95>
    }
    brelse(bp);
80101dce:	83 ec 0c             	sub    $0xc,%esp
80101dd1:	ff 75 ec             	pushl  -0x14(%ebp)
80101dd4:	e8 55 e4 ff ff       	call   8010022e <brelse>
80101dd9:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101ddc:	8b 45 08             	mov    0x8(%ebp),%eax
80101ddf:	8b 40 4c             	mov    0x4c(%eax),%eax
80101de2:	8b 55 08             	mov    0x8(%ebp),%edx
80101de5:	8b 12                	mov    (%edx),%edx
80101de7:	83 ec 08             	sub    $0x8,%esp
80101dea:	50                   	push   %eax
80101deb:	52                   	push   %edx
80101dec:	e8 58 f7 ff ff       	call   80101549 <bfree>
80101df1:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101df4:	8b 45 08             	mov    0x8(%ebp),%eax
80101df7:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101dfe:	8b 45 08             	mov    0x8(%ebp),%eax
80101e01:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101e08:	83 ec 0c             	sub    $0xc,%esp
80101e0b:	ff 75 08             	pushl  0x8(%ebp)
80101e0e:	e8 10 f9 ff ff       	call   80101723 <iupdate>
80101e13:	83 c4 10             	add    $0x10,%esp
}
80101e16:	90                   	nop
80101e17:	c9                   	leave  
80101e18:	c3                   	ret    

80101e19 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101e19:	55                   	push   %ebp
80101e1a:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1f:	8b 00                	mov    (%eax),%eax
80101e21:	89 c2                	mov    %eax,%edx
80101e23:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e26:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101e29:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2c:	8b 50 04             	mov    0x4(%eax),%edx
80101e2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e32:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101e35:	8b 45 08             	mov    0x8(%ebp),%eax
80101e38:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101e3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e3f:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101e42:	8b 45 08             	mov    0x8(%ebp),%eax
80101e45:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101e49:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e4c:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101e50:	8b 45 08             	mov    0x8(%ebp),%eax
80101e53:	8b 50 18             	mov    0x18(%eax),%edx
80101e56:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e59:	89 50 10             	mov    %edx,0x10(%eax)
}
80101e5c:	90                   	nop
80101e5d:	5d                   	pop    %ebp
80101e5e:	c3                   	ret    

80101e5f <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101e5f:	55                   	push   %ebp
80101e60:	89 e5                	mov    %esp,%ebp
80101e62:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101e65:	8b 45 08             	mov    0x8(%ebp),%eax
80101e68:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101e6c:	66 83 f8 03          	cmp    $0x3,%ax
80101e70:	75 5c                	jne    80101ece <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101e72:	8b 45 08             	mov    0x8(%ebp),%eax
80101e75:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e79:	66 85 c0             	test   %ax,%ax
80101e7c:	78 20                	js     80101e9e <readi+0x3f>
80101e7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e81:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e85:	66 83 f8 09          	cmp    $0x9,%ax
80101e89:	7f 13                	jg     80101e9e <readi+0x3f>
80101e8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e92:	98                   	cwtl   
80101e93:	8b 04 c5 00 e8 10 80 	mov    -0x7fef1800(,%eax,8),%eax
80101e9a:	85 c0                	test   %eax,%eax
80101e9c:	75 0a                	jne    80101ea8 <readi+0x49>
      return -1;
80101e9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ea3:	e9 0c 01 00 00       	jmp    80101fb4 <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80101ea8:	8b 45 08             	mov    0x8(%ebp),%eax
80101eab:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101eaf:	98                   	cwtl   
80101eb0:	8b 04 c5 00 e8 10 80 	mov    -0x7fef1800(,%eax,8),%eax
80101eb7:	8b 55 14             	mov    0x14(%ebp),%edx
80101eba:	83 ec 04             	sub    $0x4,%esp
80101ebd:	52                   	push   %edx
80101ebe:	ff 75 0c             	pushl  0xc(%ebp)
80101ec1:	ff 75 08             	pushl  0x8(%ebp)
80101ec4:	ff d0                	call   *%eax
80101ec6:	83 c4 10             	add    $0x10,%esp
80101ec9:	e9 e6 00 00 00       	jmp    80101fb4 <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80101ece:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed1:	8b 40 18             	mov    0x18(%eax),%eax
80101ed4:	3b 45 10             	cmp    0x10(%ebp),%eax
80101ed7:	72 0d                	jb     80101ee6 <readi+0x87>
80101ed9:	8b 55 10             	mov    0x10(%ebp),%edx
80101edc:	8b 45 14             	mov    0x14(%ebp),%eax
80101edf:	01 d0                	add    %edx,%eax
80101ee1:	3b 45 10             	cmp    0x10(%ebp),%eax
80101ee4:	73 0a                	jae    80101ef0 <readi+0x91>
    return -1;
80101ee6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101eeb:	e9 c4 00 00 00       	jmp    80101fb4 <readi+0x155>
  if(off + n > ip->size)
80101ef0:	8b 55 10             	mov    0x10(%ebp),%edx
80101ef3:	8b 45 14             	mov    0x14(%ebp),%eax
80101ef6:	01 c2                	add    %eax,%edx
80101ef8:	8b 45 08             	mov    0x8(%ebp),%eax
80101efb:	8b 40 18             	mov    0x18(%eax),%eax
80101efe:	39 c2                	cmp    %eax,%edx
80101f00:	76 0c                	jbe    80101f0e <readi+0xaf>
    n = ip->size - off;
80101f02:	8b 45 08             	mov    0x8(%ebp),%eax
80101f05:	8b 40 18             	mov    0x18(%eax),%eax
80101f08:	2b 45 10             	sub    0x10(%ebp),%eax
80101f0b:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f0e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f15:	e9 8b 00 00 00       	jmp    80101fa5 <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f1a:	8b 45 10             	mov    0x10(%ebp),%eax
80101f1d:	c1 e8 09             	shr    $0x9,%eax
80101f20:	83 ec 08             	sub    $0x8,%esp
80101f23:	50                   	push   %eax
80101f24:	ff 75 08             	pushl  0x8(%ebp)
80101f27:	e8 aa fc ff ff       	call   80101bd6 <bmap>
80101f2c:	83 c4 10             	add    $0x10,%esp
80101f2f:	89 c2                	mov    %eax,%edx
80101f31:	8b 45 08             	mov    0x8(%ebp),%eax
80101f34:	8b 00                	mov    (%eax),%eax
80101f36:	83 ec 08             	sub    $0x8,%esp
80101f39:	52                   	push   %edx
80101f3a:	50                   	push   %eax
80101f3b:	e8 76 e2 ff ff       	call   801001b6 <bread>
80101f40:	83 c4 10             	add    $0x10,%esp
80101f43:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101f46:	8b 45 10             	mov    0x10(%ebp),%eax
80101f49:	25 ff 01 00 00       	and    $0x1ff,%eax
80101f4e:	ba 00 02 00 00       	mov    $0x200,%edx
80101f53:	29 c2                	sub    %eax,%edx
80101f55:	8b 45 14             	mov    0x14(%ebp),%eax
80101f58:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101f5b:	39 c2                	cmp    %eax,%edx
80101f5d:	0f 46 c2             	cmovbe %edx,%eax
80101f60:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101f63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f66:	8d 50 18             	lea    0x18(%eax),%edx
80101f69:	8b 45 10             	mov    0x10(%ebp),%eax
80101f6c:	25 ff 01 00 00       	and    $0x1ff,%eax
80101f71:	01 d0                	add    %edx,%eax
80101f73:	83 ec 04             	sub    $0x4,%esp
80101f76:	ff 75 ec             	pushl  -0x14(%ebp)
80101f79:	50                   	push   %eax
80101f7a:	ff 75 0c             	pushl  0xc(%ebp)
80101f7d:	e8 1f 30 00 00       	call   80104fa1 <memmove>
80101f82:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101f85:	83 ec 0c             	sub    $0xc,%esp
80101f88:	ff 75 f0             	pushl  -0x10(%ebp)
80101f8b:	e8 9e e2 ff ff       	call   8010022e <brelse>
80101f90:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f93:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f96:	01 45 f4             	add    %eax,-0xc(%ebp)
80101f99:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f9c:	01 45 10             	add    %eax,0x10(%ebp)
80101f9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fa2:	01 45 0c             	add    %eax,0xc(%ebp)
80101fa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fa8:	3b 45 14             	cmp    0x14(%ebp),%eax
80101fab:	0f 82 69 ff ff ff    	jb     80101f1a <readi+0xbb>
  }
  return n;
80101fb1:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101fb4:	c9                   	leave  
80101fb5:	c3                   	ret    

80101fb6 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101fb6:	55                   	push   %ebp
80101fb7:	89 e5                	mov    %esp,%ebp
80101fb9:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101fbc:	8b 45 08             	mov    0x8(%ebp),%eax
80101fbf:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101fc3:	66 83 f8 03          	cmp    $0x3,%ax
80101fc7:	75 5c                	jne    80102025 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101fc9:	8b 45 08             	mov    0x8(%ebp),%eax
80101fcc:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fd0:	66 85 c0             	test   %ax,%ax
80101fd3:	78 20                	js     80101ff5 <writei+0x3f>
80101fd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd8:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fdc:	66 83 f8 09          	cmp    $0x9,%ax
80101fe0:	7f 13                	jg     80101ff5 <writei+0x3f>
80101fe2:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe5:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fe9:	98                   	cwtl   
80101fea:	8b 04 c5 04 e8 10 80 	mov    -0x7fef17fc(,%eax,8),%eax
80101ff1:	85 c0                	test   %eax,%eax
80101ff3:	75 0a                	jne    80101fff <writei+0x49>
      return -1;
80101ff5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ffa:	e9 3d 01 00 00       	jmp    8010213c <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
80101fff:	8b 45 08             	mov    0x8(%ebp),%eax
80102002:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102006:	98                   	cwtl   
80102007:	8b 04 c5 04 e8 10 80 	mov    -0x7fef17fc(,%eax,8),%eax
8010200e:	8b 55 14             	mov    0x14(%ebp),%edx
80102011:	83 ec 04             	sub    $0x4,%esp
80102014:	52                   	push   %edx
80102015:	ff 75 0c             	pushl  0xc(%ebp)
80102018:	ff 75 08             	pushl  0x8(%ebp)
8010201b:	ff d0                	call   *%eax
8010201d:	83 c4 10             	add    $0x10,%esp
80102020:	e9 17 01 00 00       	jmp    8010213c <writei+0x186>
  }

  if(off > ip->size || off + n < off)
80102025:	8b 45 08             	mov    0x8(%ebp),%eax
80102028:	8b 40 18             	mov    0x18(%eax),%eax
8010202b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010202e:	72 0d                	jb     8010203d <writei+0x87>
80102030:	8b 55 10             	mov    0x10(%ebp),%edx
80102033:	8b 45 14             	mov    0x14(%ebp),%eax
80102036:	01 d0                	add    %edx,%eax
80102038:	3b 45 10             	cmp    0x10(%ebp),%eax
8010203b:	73 0a                	jae    80102047 <writei+0x91>
    return -1;
8010203d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102042:	e9 f5 00 00 00       	jmp    8010213c <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
80102047:	8b 55 10             	mov    0x10(%ebp),%edx
8010204a:	8b 45 14             	mov    0x14(%ebp),%eax
8010204d:	01 d0                	add    %edx,%eax
8010204f:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102054:	76 0a                	jbe    80102060 <writei+0xaa>
    return -1;
80102056:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010205b:	e9 dc 00 00 00       	jmp    8010213c <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102060:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102067:	e9 99 00 00 00       	jmp    80102105 <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010206c:	8b 45 10             	mov    0x10(%ebp),%eax
8010206f:	c1 e8 09             	shr    $0x9,%eax
80102072:	83 ec 08             	sub    $0x8,%esp
80102075:	50                   	push   %eax
80102076:	ff 75 08             	pushl  0x8(%ebp)
80102079:	e8 58 fb ff ff       	call   80101bd6 <bmap>
8010207e:	83 c4 10             	add    $0x10,%esp
80102081:	89 c2                	mov    %eax,%edx
80102083:	8b 45 08             	mov    0x8(%ebp),%eax
80102086:	8b 00                	mov    (%eax),%eax
80102088:	83 ec 08             	sub    $0x8,%esp
8010208b:	52                   	push   %edx
8010208c:	50                   	push   %eax
8010208d:	e8 24 e1 ff ff       	call   801001b6 <bread>
80102092:	83 c4 10             	add    $0x10,%esp
80102095:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102098:	8b 45 10             	mov    0x10(%ebp),%eax
8010209b:	25 ff 01 00 00       	and    $0x1ff,%eax
801020a0:	ba 00 02 00 00       	mov    $0x200,%edx
801020a5:	29 c2                	sub    %eax,%edx
801020a7:	8b 45 14             	mov    0x14(%ebp),%eax
801020aa:	2b 45 f4             	sub    -0xc(%ebp),%eax
801020ad:	39 c2                	cmp    %eax,%edx
801020af:	0f 46 c2             	cmovbe %edx,%eax
801020b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801020b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020b8:	8d 50 18             	lea    0x18(%eax),%edx
801020bb:	8b 45 10             	mov    0x10(%ebp),%eax
801020be:	25 ff 01 00 00       	and    $0x1ff,%eax
801020c3:	01 d0                	add    %edx,%eax
801020c5:	83 ec 04             	sub    $0x4,%esp
801020c8:	ff 75 ec             	pushl  -0x14(%ebp)
801020cb:	ff 75 0c             	pushl  0xc(%ebp)
801020ce:	50                   	push   %eax
801020cf:	e8 cd 2e 00 00       	call   80104fa1 <memmove>
801020d4:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801020d7:	83 ec 0c             	sub    $0xc,%esp
801020da:	ff 75 f0             	pushl  -0x10(%ebp)
801020dd:	e8 51 12 00 00       	call   80103333 <log_write>
801020e2:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801020e5:	83 ec 0c             	sub    $0xc,%esp
801020e8:	ff 75 f0             	pushl  -0x10(%ebp)
801020eb:	e8 3e e1 ff ff       	call   8010022e <brelse>
801020f0:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020f6:	01 45 f4             	add    %eax,-0xc(%ebp)
801020f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020fc:	01 45 10             	add    %eax,0x10(%ebp)
801020ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102102:	01 45 0c             	add    %eax,0xc(%ebp)
80102105:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102108:	3b 45 14             	cmp    0x14(%ebp),%eax
8010210b:	0f 82 5b ff ff ff    	jb     8010206c <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
80102111:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102115:	74 22                	je     80102139 <writei+0x183>
80102117:	8b 45 08             	mov    0x8(%ebp),%eax
8010211a:	8b 40 18             	mov    0x18(%eax),%eax
8010211d:	3b 45 10             	cmp    0x10(%ebp),%eax
80102120:	73 17                	jae    80102139 <writei+0x183>
    ip->size = off;
80102122:	8b 45 08             	mov    0x8(%ebp),%eax
80102125:	8b 55 10             	mov    0x10(%ebp),%edx
80102128:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
8010212b:	83 ec 0c             	sub    $0xc,%esp
8010212e:	ff 75 08             	pushl  0x8(%ebp)
80102131:	e8 ed f5 ff ff       	call   80101723 <iupdate>
80102136:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102139:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010213c:	c9                   	leave  
8010213d:	c3                   	ret    

8010213e <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010213e:	55                   	push   %ebp
8010213f:	89 e5                	mov    %esp,%ebp
80102141:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102144:	83 ec 04             	sub    $0x4,%esp
80102147:	6a 0e                	push   $0xe
80102149:	ff 75 0c             	pushl  0xc(%ebp)
8010214c:	ff 75 08             	pushl  0x8(%ebp)
8010214f:	e8 e3 2e 00 00       	call   80105037 <strncmp>
80102154:	83 c4 10             	add    $0x10,%esp
}
80102157:	c9                   	leave  
80102158:	c3                   	ret    

80102159 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102159:	55                   	push   %ebp
8010215a:	89 e5                	mov    %esp,%ebp
8010215c:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
8010215f:	8b 45 08             	mov    0x8(%ebp),%eax
80102162:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102166:	66 83 f8 01          	cmp    $0x1,%ax
8010216a:	74 0d                	je     80102179 <dirlookup+0x20>
    panic("dirlookup not DIR");
8010216c:	83 ec 0c             	sub    $0xc,%esp
8010216f:	68 55 82 10 80       	push   $0x80108255
80102174:	e8 ed e3 ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102179:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102180:	eb 7b                	jmp    801021fd <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102182:	6a 10                	push   $0x10
80102184:	ff 75 f4             	pushl  -0xc(%ebp)
80102187:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010218a:	50                   	push   %eax
8010218b:	ff 75 08             	pushl  0x8(%ebp)
8010218e:	e8 cc fc ff ff       	call   80101e5f <readi>
80102193:	83 c4 10             	add    $0x10,%esp
80102196:	83 f8 10             	cmp    $0x10,%eax
80102199:	74 0d                	je     801021a8 <dirlookup+0x4f>
      panic("dirlink read");
8010219b:	83 ec 0c             	sub    $0xc,%esp
8010219e:	68 67 82 10 80       	push   $0x80108267
801021a3:	e8 be e3 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801021a8:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021ac:	66 85 c0             	test   %ax,%ax
801021af:	74 47                	je     801021f8 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
801021b1:	83 ec 08             	sub    $0x8,%esp
801021b4:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021b7:	83 c0 02             	add    $0x2,%eax
801021ba:	50                   	push   %eax
801021bb:	ff 75 0c             	pushl  0xc(%ebp)
801021be:	e8 7b ff ff ff       	call   8010213e <namecmp>
801021c3:	83 c4 10             	add    $0x10,%esp
801021c6:	85 c0                	test   %eax,%eax
801021c8:	75 2f                	jne    801021f9 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
801021ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801021ce:	74 08                	je     801021d8 <dirlookup+0x7f>
        *poff = off;
801021d0:	8b 45 10             	mov    0x10(%ebp),%eax
801021d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801021d6:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801021d8:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021dc:	0f b7 c0             	movzwl %ax,%eax
801021df:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801021e2:	8b 45 08             	mov    0x8(%ebp),%eax
801021e5:	8b 00                	mov    (%eax),%eax
801021e7:	83 ec 08             	sub    $0x8,%esp
801021ea:	ff 75 f0             	pushl  -0x10(%ebp)
801021ed:	50                   	push   %eax
801021ee:	e8 eb f5 ff ff       	call   801017de <iget>
801021f3:	83 c4 10             	add    $0x10,%esp
801021f6:	eb 19                	jmp    80102211 <dirlookup+0xb8>
      continue;
801021f8:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
801021f9:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801021fd:	8b 45 08             	mov    0x8(%ebp),%eax
80102200:	8b 40 18             	mov    0x18(%eax),%eax
80102203:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102206:	0f 87 76 ff ff ff    	ja     80102182 <dirlookup+0x29>
    }
  }

  return 0;
8010220c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102211:	c9                   	leave  
80102212:	c3                   	ret    

80102213 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102213:	55                   	push   %ebp
80102214:	89 e5                	mov    %esp,%ebp
80102216:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102219:	83 ec 04             	sub    $0x4,%esp
8010221c:	6a 00                	push   $0x0
8010221e:	ff 75 0c             	pushl  0xc(%ebp)
80102221:	ff 75 08             	pushl  0x8(%ebp)
80102224:	e8 30 ff ff ff       	call   80102159 <dirlookup>
80102229:	83 c4 10             	add    $0x10,%esp
8010222c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010222f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102233:	74 18                	je     8010224d <dirlink+0x3a>
    iput(ip);
80102235:	83 ec 0c             	sub    $0xc,%esp
80102238:	ff 75 f0             	pushl  -0x10(%ebp)
8010223b:	e8 81 f8 ff ff       	call   80101ac1 <iput>
80102240:	83 c4 10             	add    $0x10,%esp
    return -1;
80102243:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102248:	e9 9c 00 00 00       	jmp    801022e9 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010224d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102254:	eb 39                	jmp    8010228f <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102256:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102259:	6a 10                	push   $0x10
8010225b:	50                   	push   %eax
8010225c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010225f:	50                   	push   %eax
80102260:	ff 75 08             	pushl  0x8(%ebp)
80102263:	e8 f7 fb ff ff       	call   80101e5f <readi>
80102268:	83 c4 10             	add    $0x10,%esp
8010226b:	83 f8 10             	cmp    $0x10,%eax
8010226e:	74 0d                	je     8010227d <dirlink+0x6a>
      panic("dirlink read");
80102270:	83 ec 0c             	sub    $0xc,%esp
80102273:	68 67 82 10 80       	push   $0x80108267
80102278:	e8 e9 e2 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
8010227d:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102281:	66 85 c0             	test   %ax,%ax
80102284:	74 18                	je     8010229e <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102286:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102289:	83 c0 10             	add    $0x10,%eax
8010228c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010228f:	8b 45 08             	mov    0x8(%ebp),%eax
80102292:	8b 50 18             	mov    0x18(%eax),%edx
80102295:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102298:	39 c2                	cmp    %eax,%edx
8010229a:	77 ba                	ja     80102256 <dirlink+0x43>
8010229c:	eb 01                	jmp    8010229f <dirlink+0x8c>
      break;
8010229e:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
8010229f:	83 ec 04             	sub    $0x4,%esp
801022a2:	6a 0e                	push   $0xe
801022a4:	ff 75 0c             	pushl  0xc(%ebp)
801022a7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022aa:	83 c0 02             	add    $0x2,%eax
801022ad:	50                   	push   %eax
801022ae:	e8 da 2d 00 00       	call   8010508d <strncpy>
801022b3:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801022b6:	8b 45 10             	mov    0x10(%ebp),%eax
801022b9:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022c0:	6a 10                	push   $0x10
801022c2:	50                   	push   %eax
801022c3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022c6:	50                   	push   %eax
801022c7:	ff 75 08             	pushl  0x8(%ebp)
801022ca:	e8 e7 fc ff ff       	call   80101fb6 <writei>
801022cf:	83 c4 10             	add    $0x10,%esp
801022d2:	83 f8 10             	cmp    $0x10,%eax
801022d5:	74 0d                	je     801022e4 <dirlink+0xd1>
    panic("dirlink");
801022d7:	83 ec 0c             	sub    $0xc,%esp
801022da:	68 74 82 10 80       	push   $0x80108274
801022df:	e8 82 e2 ff ff       	call   80100566 <panic>
  
  return 0;
801022e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022e9:	c9                   	leave  
801022ea:	c3                   	ret    

801022eb <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801022eb:	55                   	push   %ebp
801022ec:	89 e5                	mov    %esp,%ebp
801022ee:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
801022f1:	eb 04                	jmp    801022f7 <skipelem+0xc>
    path++;
801022f3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801022f7:	8b 45 08             	mov    0x8(%ebp),%eax
801022fa:	0f b6 00             	movzbl (%eax),%eax
801022fd:	3c 2f                	cmp    $0x2f,%al
801022ff:	74 f2                	je     801022f3 <skipelem+0x8>
  if(*path == 0)
80102301:	8b 45 08             	mov    0x8(%ebp),%eax
80102304:	0f b6 00             	movzbl (%eax),%eax
80102307:	84 c0                	test   %al,%al
80102309:	75 07                	jne    80102312 <skipelem+0x27>
    return 0;
8010230b:	b8 00 00 00 00       	mov    $0x0,%eax
80102310:	eb 7b                	jmp    8010238d <skipelem+0xa2>
  s = path;
80102312:	8b 45 08             	mov    0x8(%ebp),%eax
80102315:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102318:	eb 04                	jmp    8010231e <skipelem+0x33>
    path++;
8010231a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
8010231e:	8b 45 08             	mov    0x8(%ebp),%eax
80102321:	0f b6 00             	movzbl (%eax),%eax
80102324:	3c 2f                	cmp    $0x2f,%al
80102326:	74 0a                	je     80102332 <skipelem+0x47>
80102328:	8b 45 08             	mov    0x8(%ebp),%eax
8010232b:	0f b6 00             	movzbl (%eax),%eax
8010232e:	84 c0                	test   %al,%al
80102330:	75 e8                	jne    8010231a <skipelem+0x2f>
  len = path - s;
80102332:	8b 55 08             	mov    0x8(%ebp),%edx
80102335:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102338:	29 c2                	sub    %eax,%edx
8010233a:	89 d0                	mov    %edx,%eax
8010233c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
8010233f:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102343:	7e 15                	jle    8010235a <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
80102345:	83 ec 04             	sub    $0x4,%esp
80102348:	6a 0e                	push   $0xe
8010234a:	ff 75 f4             	pushl  -0xc(%ebp)
8010234d:	ff 75 0c             	pushl  0xc(%ebp)
80102350:	e8 4c 2c 00 00       	call   80104fa1 <memmove>
80102355:	83 c4 10             	add    $0x10,%esp
80102358:	eb 26                	jmp    80102380 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010235a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010235d:	83 ec 04             	sub    $0x4,%esp
80102360:	50                   	push   %eax
80102361:	ff 75 f4             	pushl  -0xc(%ebp)
80102364:	ff 75 0c             	pushl  0xc(%ebp)
80102367:	e8 35 2c 00 00       	call   80104fa1 <memmove>
8010236c:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
8010236f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102372:	8b 45 0c             	mov    0xc(%ebp),%eax
80102375:	01 d0                	add    %edx,%eax
80102377:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
8010237a:	eb 04                	jmp    80102380 <skipelem+0x95>
    path++;
8010237c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102380:	8b 45 08             	mov    0x8(%ebp),%eax
80102383:	0f b6 00             	movzbl (%eax),%eax
80102386:	3c 2f                	cmp    $0x2f,%al
80102388:	74 f2                	je     8010237c <skipelem+0x91>
  return path;
8010238a:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010238d:	c9                   	leave  
8010238e:	c3                   	ret    

8010238f <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010238f:	55                   	push   %ebp
80102390:	89 e5                	mov    %esp,%ebp
80102392:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102395:	8b 45 08             	mov    0x8(%ebp),%eax
80102398:	0f b6 00             	movzbl (%eax),%eax
8010239b:	3c 2f                	cmp    $0x2f,%al
8010239d:	75 17                	jne    801023b6 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
8010239f:	83 ec 08             	sub    $0x8,%esp
801023a2:	6a 01                	push   $0x1
801023a4:	6a 01                	push   $0x1
801023a6:	e8 33 f4 ff ff       	call   801017de <iget>
801023ab:	83 c4 10             	add    $0x10,%esp
801023ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023b1:	e9 bb 00 00 00       	jmp    80102471 <namex+0xe2>
  else
    ip = idup(proc->cwd);
801023b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801023bc:	8b 40 68             	mov    0x68(%eax),%eax
801023bf:	83 ec 0c             	sub    $0xc,%esp
801023c2:	50                   	push   %eax
801023c3:	e8 f5 f4 ff ff       	call   801018bd <idup>
801023c8:	83 c4 10             	add    $0x10,%esp
801023cb:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801023ce:	e9 9e 00 00 00       	jmp    80102471 <namex+0xe2>
    ilock(ip);
801023d3:	83 ec 0c             	sub    $0xc,%esp
801023d6:	ff 75 f4             	pushl  -0xc(%ebp)
801023d9:	e8 19 f5 ff ff       	call   801018f7 <ilock>
801023de:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
801023e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023e4:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801023e8:	66 83 f8 01          	cmp    $0x1,%ax
801023ec:	74 18                	je     80102406 <namex+0x77>
      iunlockput(ip);
801023ee:	83 ec 0c             	sub    $0xc,%esp
801023f1:	ff 75 f4             	pushl  -0xc(%ebp)
801023f4:	e8 b8 f7 ff ff       	call   80101bb1 <iunlockput>
801023f9:	83 c4 10             	add    $0x10,%esp
      return 0;
801023fc:	b8 00 00 00 00       	mov    $0x0,%eax
80102401:	e9 a7 00 00 00       	jmp    801024ad <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
80102406:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010240a:	74 20                	je     8010242c <namex+0x9d>
8010240c:	8b 45 08             	mov    0x8(%ebp),%eax
8010240f:	0f b6 00             	movzbl (%eax),%eax
80102412:	84 c0                	test   %al,%al
80102414:	75 16                	jne    8010242c <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
80102416:	83 ec 0c             	sub    $0xc,%esp
80102419:	ff 75 f4             	pushl  -0xc(%ebp)
8010241c:	e8 2e f6 ff ff       	call   80101a4f <iunlock>
80102421:	83 c4 10             	add    $0x10,%esp
      return ip;
80102424:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102427:	e9 81 00 00 00       	jmp    801024ad <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010242c:	83 ec 04             	sub    $0x4,%esp
8010242f:	6a 00                	push   $0x0
80102431:	ff 75 10             	pushl  0x10(%ebp)
80102434:	ff 75 f4             	pushl  -0xc(%ebp)
80102437:	e8 1d fd ff ff       	call   80102159 <dirlookup>
8010243c:	83 c4 10             	add    $0x10,%esp
8010243f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102442:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102446:	75 15                	jne    8010245d <namex+0xce>
      iunlockput(ip);
80102448:	83 ec 0c             	sub    $0xc,%esp
8010244b:	ff 75 f4             	pushl  -0xc(%ebp)
8010244e:	e8 5e f7 ff ff       	call   80101bb1 <iunlockput>
80102453:	83 c4 10             	add    $0x10,%esp
      return 0;
80102456:	b8 00 00 00 00       	mov    $0x0,%eax
8010245b:	eb 50                	jmp    801024ad <namex+0x11e>
    }
    iunlockput(ip);
8010245d:	83 ec 0c             	sub    $0xc,%esp
80102460:	ff 75 f4             	pushl  -0xc(%ebp)
80102463:	e8 49 f7 ff ff       	call   80101bb1 <iunlockput>
80102468:	83 c4 10             	add    $0x10,%esp
    ip = next;
8010246b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010246e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
80102471:	83 ec 08             	sub    $0x8,%esp
80102474:	ff 75 10             	pushl  0x10(%ebp)
80102477:	ff 75 08             	pushl  0x8(%ebp)
8010247a:	e8 6c fe ff ff       	call   801022eb <skipelem>
8010247f:	83 c4 10             	add    $0x10,%esp
80102482:	89 45 08             	mov    %eax,0x8(%ebp)
80102485:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102489:	0f 85 44 ff ff ff    	jne    801023d3 <namex+0x44>
  }
  if(nameiparent){
8010248f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102493:	74 15                	je     801024aa <namex+0x11b>
    iput(ip);
80102495:	83 ec 0c             	sub    $0xc,%esp
80102498:	ff 75 f4             	pushl  -0xc(%ebp)
8010249b:	e8 21 f6 ff ff       	call   80101ac1 <iput>
801024a0:	83 c4 10             	add    $0x10,%esp
    return 0;
801024a3:	b8 00 00 00 00       	mov    $0x0,%eax
801024a8:	eb 03                	jmp    801024ad <namex+0x11e>
  }
  return ip;
801024aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801024ad:	c9                   	leave  
801024ae:	c3                   	ret    

801024af <namei>:

struct inode*
namei(char *path)
{
801024af:	55                   	push   %ebp
801024b0:	89 e5                	mov    %esp,%ebp
801024b2:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801024b5:	83 ec 04             	sub    $0x4,%esp
801024b8:	8d 45 ea             	lea    -0x16(%ebp),%eax
801024bb:	50                   	push   %eax
801024bc:	6a 00                	push   $0x0
801024be:	ff 75 08             	pushl  0x8(%ebp)
801024c1:	e8 c9 fe ff ff       	call   8010238f <namex>
801024c6:	83 c4 10             	add    $0x10,%esp
}
801024c9:	c9                   	leave  
801024ca:	c3                   	ret    

801024cb <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801024cb:	55                   	push   %ebp
801024cc:	89 e5                	mov    %esp,%ebp
801024ce:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
801024d1:	83 ec 04             	sub    $0x4,%esp
801024d4:	ff 75 0c             	pushl  0xc(%ebp)
801024d7:	6a 01                	push   $0x1
801024d9:	ff 75 08             	pushl  0x8(%ebp)
801024dc:	e8 ae fe ff ff       	call   8010238f <namex>
801024e1:	83 c4 10             	add    $0x10,%esp
}
801024e4:	c9                   	leave  
801024e5:	c3                   	ret    

801024e6 <inb>:
{
801024e6:	55                   	push   %ebp
801024e7:	89 e5                	mov    %esp,%ebp
801024e9:	83 ec 14             	sub    $0x14,%esp
801024ec:	8b 45 08             	mov    0x8(%ebp),%eax
801024ef:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801024f3:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801024f7:	89 c2                	mov    %eax,%edx
801024f9:	ec                   	in     (%dx),%al
801024fa:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801024fd:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102501:	c9                   	leave  
80102502:	c3                   	ret    

80102503 <insl>:
{
80102503:	55                   	push   %ebp
80102504:	89 e5                	mov    %esp,%ebp
80102506:	57                   	push   %edi
80102507:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102508:	8b 55 08             	mov    0x8(%ebp),%edx
8010250b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010250e:	8b 45 10             	mov    0x10(%ebp),%eax
80102511:	89 cb                	mov    %ecx,%ebx
80102513:	89 df                	mov    %ebx,%edi
80102515:	89 c1                	mov    %eax,%ecx
80102517:	fc                   	cld    
80102518:	f3 6d                	rep insl (%dx),%es:(%edi)
8010251a:	89 c8                	mov    %ecx,%eax
8010251c:	89 fb                	mov    %edi,%ebx
8010251e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102521:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102524:	90                   	nop
80102525:	5b                   	pop    %ebx
80102526:	5f                   	pop    %edi
80102527:	5d                   	pop    %ebp
80102528:	c3                   	ret    

80102529 <outb>:
{
80102529:	55                   	push   %ebp
8010252a:	89 e5                	mov    %esp,%ebp
8010252c:	83 ec 08             	sub    $0x8,%esp
8010252f:	8b 55 08             	mov    0x8(%ebp),%edx
80102532:	8b 45 0c             	mov    0xc(%ebp),%eax
80102535:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102539:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010253c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102540:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102544:	ee                   	out    %al,(%dx)
}
80102545:	90                   	nop
80102546:	c9                   	leave  
80102547:	c3                   	ret    

80102548 <outsl>:
{
80102548:	55                   	push   %ebp
80102549:	89 e5                	mov    %esp,%ebp
8010254b:	56                   	push   %esi
8010254c:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010254d:	8b 55 08             	mov    0x8(%ebp),%edx
80102550:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102553:	8b 45 10             	mov    0x10(%ebp),%eax
80102556:	89 cb                	mov    %ecx,%ebx
80102558:	89 de                	mov    %ebx,%esi
8010255a:	89 c1                	mov    %eax,%ecx
8010255c:	fc                   	cld    
8010255d:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010255f:	89 c8                	mov    %ecx,%eax
80102561:	89 f3                	mov    %esi,%ebx
80102563:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102566:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102569:	90                   	nop
8010256a:	5b                   	pop    %ebx
8010256b:	5e                   	pop    %esi
8010256c:	5d                   	pop    %ebp
8010256d:	c3                   	ret    

8010256e <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010256e:	55                   	push   %ebp
8010256f:	89 e5                	mov    %esp,%ebp
80102571:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102574:	90                   	nop
80102575:	68 f7 01 00 00       	push   $0x1f7
8010257a:	e8 67 ff ff ff       	call   801024e6 <inb>
8010257f:	83 c4 04             	add    $0x4,%esp
80102582:	0f b6 c0             	movzbl %al,%eax
80102585:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102588:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010258b:	25 c0 00 00 00       	and    $0xc0,%eax
80102590:	83 f8 40             	cmp    $0x40,%eax
80102593:	75 e0                	jne    80102575 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102595:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102599:	74 11                	je     801025ac <idewait+0x3e>
8010259b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010259e:	83 e0 21             	and    $0x21,%eax
801025a1:	85 c0                	test   %eax,%eax
801025a3:	74 07                	je     801025ac <idewait+0x3e>
    return -1;
801025a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801025aa:	eb 05                	jmp    801025b1 <idewait+0x43>
  return 0;
801025ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
801025b1:	c9                   	leave  
801025b2:	c3                   	ret    

801025b3 <ideinit>:

void
ideinit(void)
{
801025b3:	55                   	push   %ebp
801025b4:	89 e5                	mov    %esp,%ebp
801025b6:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
801025b9:	83 ec 08             	sub    $0x8,%esp
801025bc:	68 7c 82 10 80       	push   $0x8010827c
801025c1:	68 00 b6 10 80       	push   $0x8010b600
801025c6:	e8 92 26 00 00       	call   80104c5d <initlock>
801025cb:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
801025ce:	83 ec 0c             	sub    $0xc,%esp
801025d1:	6a 0e                	push   $0xe
801025d3:	e8 1c 15 00 00       	call   80103af4 <picenable>
801025d8:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801025db:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
801025e0:	83 e8 01             	sub    $0x1,%eax
801025e3:	83 ec 08             	sub    $0x8,%esp
801025e6:	50                   	push   %eax
801025e7:	6a 0e                	push   $0xe
801025e9:	e8 37 04 00 00       	call   80102a25 <ioapicenable>
801025ee:	83 c4 10             	add    $0x10,%esp
  idewait(0);
801025f1:	83 ec 0c             	sub    $0xc,%esp
801025f4:	6a 00                	push   $0x0
801025f6:	e8 73 ff ff ff       	call   8010256e <idewait>
801025fb:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801025fe:	83 ec 08             	sub    $0x8,%esp
80102601:	68 f0 00 00 00       	push   $0xf0
80102606:	68 f6 01 00 00       	push   $0x1f6
8010260b:	e8 19 ff ff ff       	call   80102529 <outb>
80102610:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102613:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010261a:	eb 24                	jmp    80102640 <ideinit+0x8d>
    if(inb(0x1f7) != 0){
8010261c:	83 ec 0c             	sub    $0xc,%esp
8010261f:	68 f7 01 00 00       	push   $0x1f7
80102624:	e8 bd fe ff ff       	call   801024e6 <inb>
80102629:	83 c4 10             	add    $0x10,%esp
8010262c:	84 c0                	test   %al,%al
8010262e:	74 0c                	je     8010263c <ideinit+0x89>
      havedisk1 = 1;
80102630:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
80102637:	00 00 00 
      break;
8010263a:	eb 0d                	jmp    80102649 <ideinit+0x96>
  for(i=0; i<1000; i++){
8010263c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102640:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102647:	7e d3                	jle    8010261c <ideinit+0x69>
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102649:	83 ec 08             	sub    $0x8,%esp
8010264c:	68 e0 00 00 00       	push   $0xe0
80102651:	68 f6 01 00 00       	push   $0x1f6
80102656:	e8 ce fe ff ff       	call   80102529 <outb>
8010265b:	83 c4 10             	add    $0x10,%esp
}
8010265e:	90                   	nop
8010265f:	c9                   	leave  
80102660:	c3                   	ret    

80102661 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102661:	55                   	push   %ebp
80102662:	89 e5                	mov    %esp,%ebp
80102664:	83 ec 08             	sub    $0x8,%esp
  if(b == 0)
80102667:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010266b:	75 0d                	jne    8010267a <idestart+0x19>
    panic("idestart");
8010266d:	83 ec 0c             	sub    $0xc,%esp
80102670:	68 80 82 10 80       	push   $0x80108280
80102675:	e8 ec de ff ff       	call   80100566 <panic>

  idewait(0);
8010267a:	83 ec 0c             	sub    $0xc,%esp
8010267d:	6a 00                	push   $0x0
8010267f:	e8 ea fe ff ff       	call   8010256e <idewait>
80102684:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102687:	83 ec 08             	sub    $0x8,%esp
8010268a:	6a 00                	push   $0x0
8010268c:	68 f6 03 00 00       	push   $0x3f6
80102691:	e8 93 fe ff ff       	call   80102529 <outb>
80102696:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, 1);  // number of sectors
80102699:	83 ec 08             	sub    $0x8,%esp
8010269c:	6a 01                	push   $0x1
8010269e:	68 f2 01 00 00       	push   $0x1f2
801026a3:	e8 81 fe ff ff       	call   80102529 <outb>
801026a8:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, b->sector & 0xff);
801026ab:	8b 45 08             	mov    0x8(%ebp),%eax
801026ae:	8b 40 08             	mov    0x8(%eax),%eax
801026b1:	0f b6 c0             	movzbl %al,%eax
801026b4:	83 ec 08             	sub    $0x8,%esp
801026b7:	50                   	push   %eax
801026b8:	68 f3 01 00 00       	push   $0x1f3
801026bd:	e8 67 fe ff ff       	call   80102529 <outb>
801026c2:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (b->sector >> 8) & 0xff);
801026c5:	8b 45 08             	mov    0x8(%ebp),%eax
801026c8:	8b 40 08             	mov    0x8(%eax),%eax
801026cb:	c1 e8 08             	shr    $0x8,%eax
801026ce:	0f b6 c0             	movzbl %al,%eax
801026d1:	83 ec 08             	sub    $0x8,%esp
801026d4:	50                   	push   %eax
801026d5:	68 f4 01 00 00       	push   $0x1f4
801026da:	e8 4a fe ff ff       	call   80102529 <outb>
801026df:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (b->sector >> 16) & 0xff);
801026e2:	8b 45 08             	mov    0x8(%ebp),%eax
801026e5:	8b 40 08             	mov    0x8(%eax),%eax
801026e8:	c1 e8 10             	shr    $0x10,%eax
801026eb:	0f b6 c0             	movzbl %al,%eax
801026ee:	83 ec 08             	sub    $0x8,%esp
801026f1:	50                   	push   %eax
801026f2:	68 f5 01 00 00       	push   $0x1f5
801026f7:	e8 2d fe ff ff       	call   80102529 <outb>
801026fc:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
801026ff:	8b 45 08             	mov    0x8(%ebp),%eax
80102702:	8b 40 04             	mov    0x4(%eax),%eax
80102705:	c1 e0 04             	shl    $0x4,%eax
80102708:	83 e0 10             	and    $0x10,%eax
8010270b:	89 c2                	mov    %eax,%edx
8010270d:	8b 45 08             	mov    0x8(%ebp),%eax
80102710:	8b 40 08             	mov    0x8(%eax),%eax
80102713:	c1 e8 18             	shr    $0x18,%eax
80102716:	83 e0 0f             	and    $0xf,%eax
80102719:	09 d0                	or     %edx,%eax
8010271b:	83 c8 e0             	or     $0xffffffe0,%eax
8010271e:	0f b6 c0             	movzbl %al,%eax
80102721:	83 ec 08             	sub    $0x8,%esp
80102724:	50                   	push   %eax
80102725:	68 f6 01 00 00       	push   $0x1f6
8010272a:	e8 fa fd ff ff       	call   80102529 <outb>
8010272f:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102732:	8b 45 08             	mov    0x8(%ebp),%eax
80102735:	8b 00                	mov    (%eax),%eax
80102737:	83 e0 04             	and    $0x4,%eax
8010273a:	85 c0                	test   %eax,%eax
8010273c:	74 30                	je     8010276e <idestart+0x10d>
    outb(0x1f7, IDE_CMD_WRITE);
8010273e:	83 ec 08             	sub    $0x8,%esp
80102741:	6a 30                	push   $0x30
80102743:	68 f7 01 00 00       	push   $0x1f7
80102748:	e8 dc fd ff ff       	call   80102529 <outb>
8010274d:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, 512/4);
80102750:	8b 45 08             	mov    0x8(%ebp),%eax
80102753:	83 c0 18             	add    $0x18,%eax
80102756:	83 ec 04             	sub    $0x4,%esp
80102759:	68 80 00 00 00       	push   $0x80
8010275e:	50                   	push   %eax
8010275f:	68 f0 01 00 00       	push   $0x1f0
80102764:	e8 df fd ff ff       	call   80102548 <outsl>
80102769:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
8010276c:	eb 12                	jmp    80102780 <idestart+0x11f>
    outb(0x1f7, IDE_CMD_READ);
8010276e:	83 ec 08             	sub    $0x8,%esp
80102771:	6a 20                	push   $0x20
80102773:	68 f7 01 00 00       	push   $0x1f7
80102778:	e8 ac fd ff ff       	call   80102529 <outb>
8010277d:	83 c4 10             	add    $0x10,%esp
}
80102780:	90                   	nop
80102781:	c9                   	leave  
80102782:	c3                   	ret    

80102783 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102783:	55                   	push   %ebp
80102784:	89 e5                	mov    %esp,%ebp
80102786:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102789:	83 ec 0c             	sub    $0xc,%esp
8010278c:	68 00 b6 10 80       	push   $0x8010b600
80102791:	e8 e9 24 00 00       	call   80104c7f <acquire>
80102796:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80102799:	a1 34 b6 10 80       	mov    0x8010b634,%eax
8010279e:	89 45 f4             	mov    %eax,-0xc(%ebp)
801027a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027a5:	75 15                	jne    801027bc <ideintr+0x39>
    release(&idelock);
801027a7:	83 ec 0c             	sub    $0xc,%esp
801027aa:	68 00 b6 10 80       	push   $0x8010b600
801027af:	e8 32 25 00 00       	call   80104ce6 <release>
801027b4:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
801027b7:	e9 9a 00 00 00       	jmp    80102856 <ideintr+0xd3>
  }
  idequeue = b->qnext;
801027bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027bf:	8b 40 14             	mov    0x14(%eax),%eax
801027c2:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801027c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027ca:	8b 00                	mov    (%eax),%eax
801027cc:	83 e0 04             	and    $0x4,%eax
801027cf:	85 c0                	test   %eax,%eax
801027d1:	75 2d                	jne    80102800 <ideintr+0x7d>
801027d3:	83 ec 0c             	sub    $0xc,%esp
801027d6:	6a 01                	push   $0x1
801027d8:	e8 91 fd ff ff       	call   8010256e <idewait>
801027dd:	83 c4 10             	add    $0x10,%esp
801027e0:	85 c0                	test   %eax,%eax
801027e2:	78 1c                	js     80102800 <ideintr+0x7d>
    insl(0x1f0, b->data, 512/4);
801027e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027e7:	83 c0 18             	add    $0x18,%eax
801027ea:	83 ec 04             	sub    $0x4,%esp
801027ed:	68 80 00 00 00       	push   $0x80
801027f2:	50                   	push   %eax
801027f3:	68 f0 01 00 00       	push   $0x1f0
801027f8:	e8 06 fd ff ff       	call   80102503 <insl>
801027fd:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102803:	8b 00                	mov    (%eax),%eax
80102805:	83 c8 02             	or     $0x2,%eax
80102808:	89 c2                	mov    %eax,%edx
8010280a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010280d:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
8010280f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102812:	8b 00                	mov    (%eax),%eax
80102814:	83 e0 fb             	and    $0xfffffffb,%eax
80102817:	89 c2                	mov    %eax,%edx
80102819:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010281c:	89 10                	mov    %edx,(%eax)
  wakeup(b);
8010281e:	83 ec 0c             	sub    $0xc,%esp
80102821:	ff 75 f4             	pushl  -0xc(%ebp)
80102824:	e8 48 22 00 00       	call   80104a71 <wakeup>
80102829:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
8010282c:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102831:	85 c0                	test   %eax,%eax
80102833:	74 11                	je     80102846 <ideintr+0xc3>
    idestart(idequeue);
80102835:	a1 34 b6 10 80       	mov    0x8010b634,%eax
8010283a:	83 ec 0c             	sub    $0xc,%esp
8010283d:	50                   	push   %eax
8010283e:	e8 1e fe ff ff       	call   80102661 <idestart>
80102843:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102846:	83 ec 0c             	sub    $0xc,%esp
80102849:	68 00 b6 10 80       	push   $0x8010b600
8010284e:	e8 93 24 00 00       	call   80104ce6 <release>
80102853:	83 c4 10             	add    $0x10,%esp
}
80102856:	c9                   	leave  
80102857:	c3                   	ret    

80102858 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102858:	55                   	push   %ebp
80102859:	89 e5                	mov    %esp,%ebp
8010285b:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
8010285e:	8b 45 08             	mov    0x8(%ebp),%eax
80102861:	8b 00                	mov    (%eax),%eax
80102863:	83 e0 01             	and    $0x1,%eax
80102866:	85 c0                	test   %eax,%eax
80102868:	75 0d                	jne    80102877 <iderw+0x1f>
    panic("iderw: buf not busy");
8010286a:	83 ec 0c             	sub    $0xc,%esp
8010286d:	68 89 82 10 80       	push   $0x80108289
80102872:	e8 ef dc ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102877:	8b 45 08             	mov    0x8(%ebp),%eax
8010287a:	8b 00                	mov    (%eax),%eax
8010287c:	83 e0 06             	and    $0x6,%eax
8010287f:	83 f8 02             	cmp    $0x2,%eax
80102882:	75 0d                	jne    80102891 <iderw+0x39>
    panic("iderw: nothing to do");
80102884:	83 ec 0c             	sub    $0xc,%esp
80102887:	68 9d 82 10 80       	push   $0x8010829d
8010288c:	e8 d5 dc ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
80102891:	8b 45 08             	mov    0x8(%ebp),%eax
80102894:	8b 40 04             	mov    0x4(%eax),%eax
80102897:	85 c0                	test   %eax,%eax
80102899:	74 16                	je     801028b1 <iderw+0x59>
8010289b:	a1 38 b6 10 80       	mov    0x8010b638,%eax
801028a0:	85 c0                	test   %eax,%eax
801028a2:	75 0d                	jne    801028b1 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
801028a4:	83 ec 0c             	sub    $0xc,%esp
801028a7:	68 b2 82 10 80       	push   $0x801082b2
801028ac:	e8 b5 dc ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801028b1:	83 ec 0c             	sub    $0xc,%esp
801028b4:	68 00 b6 10 80       	push   $0x8010b600
801028b9:	e8 c1 23 00 00       	call   80104c7f <acquire>
801028be:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
801028c1:	8b 45 08             	mov    0x8(%ebp),%eax
801028c4:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801028cb:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
801028d2:	eb 0b                	jmp    801028df <iderw+0x87>
801028d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d7:	8b 00                	mov    (%eax),%eax
801028d9:	83 c0 14             	add    $0x14,%eax
801028dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e2:	8b 00                	mov    (%eax),%eax
801028e4:	85 c0                	test   %eax,%eax
801028e6:	75 ec                	jne    801028d4 <iderw+0x7c>
    ;
  *pp = b;
801028e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028eb:	8b 55 08             	mov    0x8(%ebp),%edx
801028ee:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
801028f0:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801028f5:	3b 45 08             	cmp    0x8(%ebp),%eax
801028f8:	75 23                	jne    8010291d <iderw+0xc5>
    idestart(b);
801028fa:	83 ec 0c             	sub    $0xc,%esp
801028fd:	ff 75 08             	pushl  0x8(%ebp)
80102900:	e8 5c fd ff ff       	call   80102661 <idestart>
80102905:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102908:	eb 13                	jmp    8010291d <iderw+0xc5>
    sleep(b, &idelock);
8010290a:	83 ec 08             	sub    $0x8,%esp
8010290d:	68 00 b6 10 80       	push   $0x8010b600
80102912:	ff 75 08             	pushl  0x8(%ebp)
80102915:	e8 6c 20 00 00       	call   80104986 <sleep>
8010291a:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010291d:	8b 45 08             	mov    0x8(%ebp),%eax
80102920:	8b 00                	mov    (%eax),%eax
80102922:	83 e0 06             	and    $0x6,%eax
80102925:	83 f8 02             	cmp    $0x2,%eax
80102928:	75 e0                	jne    8010290a <iderw+0xb2>
  }

  release(&idelock);
8010292a:	83 ec 0c             	sub    $0xc,%esp
8010292d:	68 00 b6 10 80       	push   $0x8010b600
80102932:	e8 af 23 00 00       	call   80104ce6 <release>
80102937:	83 c4 10             	add    $0x10,%esp
}
8010293a:	90                   	nop
8010293b:	c9                   	leave  
8010293c:	c3                   	ret    

8010293d <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
8010293d:	55                   	push   %ebp
8010293e:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102940:	a1 34 f8 10 80       	mov    0x8010f834,%eax
80102945:	8b 55 08             	mov    0x8(%ebp),%edx
80102948:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
8010294a:	a1 34 f8 10 80       	mov    0x8010f834,%eax
8010294f:	8b 40 10             	mov    0x10(%eax),%eax
}
80102952:	5d                   	pop    %ebp
80102953:	c3                   	ret    

80102954 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102954:	55                   	push   %ebp
80102955:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102957:	a1 34 f8 10 80       	mov    0x8010f834,%eax
8010295c:	8b 55 08             	mov    0x8(%ebp),%edx
8010295f:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102961:	a1 34 f8 10 80       	mov    0x8010f834,%eax
80102966:	8b 55 0c             	mov    0xc(%ebp),%edx
80102969:	89 50 10             	mov    %edx,0x10(%eax)
}
8010296c:	90                   	nop
8010296d:	5d                   	pop    %ebp
8010296e:	c3                   	ret    

8010296f <ioapicinit>:

void
ioapicinit(void)
{
8010296f:	55                   	push   %ebp
80102970:	89 e5                	mov    %esp,%ebp
80102972:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102975:	a1 04 f9 10 80       	mov    0x8010f904,%eax
8010297a:	85 c0                	test   %eax,%eax
8010297c:	0f 84 a0 00 00 00    	je     80102a22 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102982:	c7 05 34 f8 10 80 00 	movl   $0xfec00000,0x8010f834
80102989:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
8010298c:	6a 01                	push   $0x1
8010298e:	e8 aa ff ff ff       	call   8010293d <ioapicread>
80102993:	83 c4 04             	add    $0x4,%esp
80102996:	c1 e8 10             	shr    $0x10,%eax
80102999:	25 ff 00 00 00       	and    $0xff,%eax
8010299e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801029a1:	6a 00                	push   $0x0
801029a3:	e8 95 ff ff ff       	call   8010293d <ioapicread>
801029a8:	83 c4 04             	add    $0x4,%esp
801029ab:	c1 e8 18             	shr    $0x18,%eax
801029ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801029b1:	0f b6 05 00 f9 10 80 	movzbl 0x8010f900,%eax
801029b8:	0f b6 c0             	movzbl %al,%eax
801029bb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801029be:	74 10                	je     801029d0 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801029c0:	83 ec 0c             	sub    $0xc,%esp
801029c3:	68 d0 82 10 80       	push   $0x801082d0
801029c8:	e8 f9 d9 ff ff       	call   801003c6 <cprintf>
801029cd:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801029d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801029d7:	eb 3f                	jmp    80102a18 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801029d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029dc:	83 c0 20             	add    $0x20,%eax
801029df:	0d 00 00 01 00       	or     $0x10000,%eax
801029e4:	89 c2                	mov    %eax,%edx
801029e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029e9:	83 c0 08             	add    $0x8,%eax
801029ec:	01 c0                	add    %eax,%eax
801029ee:	83 ec 08             	sub    $0x8,%esp
801029f1:	52                   	push   %edx
801029f2:	50                   	push   %eax
801029f3:	e8 5c ff ff ff       	call   80102954 <ioapicwrite>
801029f8:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
801029fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029fe:	83 c0 08             	add    $0x8,%eax
80102a01:	01 c0                	add    %eax,%eax
80102a03:	83 c0 01             	add    $0x1,%eax
80102a06:	83 ec 08             	sub    $0x8,%esp
80102a09:	6a 00                	push   $0x0
80102a0b:	50                   	push   %eax
80102a0c:	e8 43 ff ff ff       	call   80102954 <ioapicwrite>
80102a11:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102a14:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a1b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102a1e:	7e b9                	jle    801029d9 <ioapicinit+0x6a>
80102a20:	eb 01                	jmp    80102a23 <ioapicinit+0xb4>
    return;
80102a22:	90                   	nop
  }
}
80102a23:	c9                   	leave  
80102a24:	c3                   	ret    

80102a25 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102a25:	55                   	push   %ebp
80102a26:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102a28:	a1 04 f9 10 80       	mov    0x8010f904,%eax
80102a2d:	85 c0                	test   %eax,%eax
80102a2f:	74 39                	je     80102a6a <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102a31:	8b 45 08             	mov    0x8(%ebp),%eax
80102a34:	83 c0 20             	add    $0x20,%eax
80102a37:	89 c2                	mov    %eax,%edx
80102a39:	8b 45 08             	mov    0x8(%ebp),%eax
80102a3c:	83 c0 08             	add    $0x8,%eax
80102a3f:	01 c0                	add    %eax,%eax
80102a41:	52                   	push   %edx
80102a42:	50                   	push   %eax
80102a43:	e8 0c ff ff ff       	call   80102954 <ioapicwrite>
80102a48:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102a4b:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a4e:	c1 e0 18             	shl    $0x18,%eax
80102a51:	89 c2                	mov    %eax,%edx
80102a53:	8b 45 08             	mov    0x8(%ebp),%eax
80102a56:	83 c0 08             	add    $0x8,%eax
80102a59:	01 c0                	add    %eax,%eax
80102a5b:	83 c0 01             	add    $0x1,%eax
80102a5e:	52                   	push   %edx
80102a5f:	50                   	push   %eax
80102a60:	e8 ef fe ff ff       	call   80102954 <ioapicwrite>
80102a65:	83 c4 08             	add    $0x8,%esp
80102a68:	eb 01                	jmp    80102a6b <ioapicenable+0x46>
    return;
80102a6a:	90                   	nop
}
80102a6b:	c9                   	leave  
80102a6c:	c3                   	ret    

80102a6d <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102a6d:	55                   	push   %ebp
80102a6e:	89 e5                	mov    %esp,%ebp
80102a70:	8b 45 08             	mov    0x8(%ebp),%eax
80102a73:	05 00 00 00 80       	add    $0x80000000,%eax
80102a78:	5d                   	pop    %ebp
80102a79:	c3                   	ret    

80102a7a <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102a7a:	55                   	push   %ebp
80102a7b:	89 e5                	mov    %esp,%ebp
80102a7d:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102a80:	83 ec 08             	sub    $0x8,%esp
80102a83:	68 02 83 10 80       	push   $0x80108302
80102a88:	68 40 f8 10 80       	push   $0x8010f840
80102a8d:	e8 cb 21 00 00       	call   80104c5d <initlock>
80102a92:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102a95:	c7 05 74 f8 10 80 00 	movl   $0x0,0x8010f874
80102a9c:	00 00 00 
  freerange(vstart, vend);
80102a9f:	83 ec 08             	sub    $0x8,%esp
80102aa2:	ff 75 0c             	pushl  0xc(%ebp)
80102aa5:	ff 75 08             	pushl  0x8(%ebp)
80102aa8:	e8 2a 00 00 00       	call   80102ad7 <freerange>
80102aad:	83 c4 10             	add    $0x10,%esp
}
80102ab0:	90                   	nop
80102ab1:	c9                   	leave  
80102ab2:	c3                   	ret    

80102ab3 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102ab3:	55                   	push   %ebp
80102ab4:	89 e5                	mov    %esp,%ebp
80102ab6:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102ab9:	83 ec 08             	sub    $0x8,%esp
80102abc:	ff 75 0c             	pushl  0xc(%ebp)
80102abf:	ff 75 08             	pushl  0x8(%ebp)
80102ac2:	e8 10 00 00 00       	call   80102ad7 <freerange>
80102ac7:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102aca:	c7 05 74 f8 10 80 01 	movl   $0x1,0x8010f874
80102ad1:	00 00 00 
}
80102ad4:	90                   	nop
80102ad5:	c9                   	leave  
80102ad6:	c3                   	ret    

80102ad7 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102ad7:	55                   	push   %ebp
80102ad8:	89 e5                	mov    %esp,%ebp
80102ada:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102add:	8b 45 08             	mov    0x8(%ebp),%eax
80102ae0:	05 ff 0f 00 00       	add    $0xfff,%eax
80102ae5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102aea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102aed:	eb 15                	jmp    80102b04 <freerange+0x2d>
    kfree(p);
80102aef:	83 ec 0c             	sub    $0xc,%esp
80102af2:	ff 75 f4             	pushl  -0xc(%ebp)
80102af5:	e8 1a 00 00 00       	call   80102b14 <kfree>
80102afa:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102afd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b07:	05 00 10 00 00       	add    $0x1000,%eax
80102b0c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102b0f:	76 de                	jbe    80102aef <freerange+0x18>
}
80102b11:	90                   	nop
80102b12:	c9                   	leave  
80102b13:	c3                   	ret    

80102b14 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102b14:	55                   	push   %ebp
80102b15:	89 e5                	mov    %esp,%ebp
80102b17:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102b1a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b1d:	25 ff 0f 00 00       	and    $0xfff,%eax
80102b22:	85 c0                	test   %eax,%eax
80102b24:	75 1b                	jne    80102b41 <kfree+0x2d>
80102b26:	81 7d 08 fc 27 11 80 	cmpl   $0x801127fc,0x8(%ebp)
80102b2d:	72 12                	jb     80102b41 <kfree+0x2d>
80102b2f:	ff 75 08             	pushl  0x8(%ebp)
80102b32:	e8 36 ff ff ff       	call   80102a6d <v2p>
80102b37:	83 c4 04             	add    $0x4,%esp
80102b3a:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102b3f:	76 0d                	jbe    80102b4e <kfree+0x3a>
    panic("kfree");
80102b41:	83 ec 0c             	sub    $0xc,%esp
80102b44:	68 07 83 10 80       	push   $0x80108307
80102b49:	e8 18 da ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102b4e:	83 ec 04             	sub    $0x4,%esp
80102b51:	68 00 10 00 00       	push   $0x1000
80102b56:	6a 01                	push   $0x1
80102b58:	ff 75 08             	pushl  0x8(%ebp)
80102b5b:	e8 82 23 00 00       	call   80104ee2 <memset>
80102b60:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102b63:	a1 74 f8 10 80       	mov    0x8010f874,%eax
80102b68:	85 c0                	test   %eax,%eax
80102b6a:	74 10                	je     80102b7c <kfree+0x68>
    acquire(&kmem.lock);
80102b6c:	83 ec 0c             	sub    $0xc,%esp
80102b6f:	68 40 f8 10 80       	push   $0x8010f840
80102b74:	e8 06 21 00 00       	call   80104c7f <acquire>
80102b79:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102b7c:	8b 45 08             	mov    0x8(%ebp),%eax
80102b7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102b82:	8b 15 78 f8 10 80    	mov    0x8010f878,%edx
80102b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b8b:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b90:	a3 78 f8 10 80       	mov    %eax,0x8010f878
  if(kmem.use_lock)
80102b95:	a1 74 f8 10 80       	mov    0x8010f874,%eax
80102b9a:	85 c0                	test   %eax,%eax
80102b9c:	74 10                	je     80102bae <kfree+0x9a>
    release(&kmem.lock);
80102b9e:	83 ec 0c             	sub    $0xc,%esp
80102ba1:	68 40 f8 10 80       	push   $0x8010f840
80102ba6:	e8 3b 21 00 00       	call   80104ce6 <release>
80102bab:	83 c4 10             	add    $0x10,%esp
}
80102bae:	90                   	nop
80102baf:	c9                   	leave  
80102bb0:	c3                   	ret    

80102bb1 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102bb1:	55                   	push   %ebp
80102bb2:	89 e5                	mov    %esp,%ebp
80102bb4:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102bb7:	a1 74 f8 10 80       	mov    0x8010f874,%eax
80102bbc:	85 c0                	test   %eax,%eax
80102bbe:	74 10                	je     80102bd0 <kalloc+0x1f>
    acquire(&kmem.lock);
80102bc0:	83 ec 0c             	sub    $0xc,%esp
80102bc3:	68 40 f8 10 80       	push   $0x8010f840
80102bc8:	e8 b2 20 00 00       	call   80104c7f <acquire>
80102bcd:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102bd0:	a1 78 f8 10 80       	mov    0x8010f878,%eax
80102bd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102bd8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102bdc:	74 0a                	je     80102be8 <kalloc+0x37>
    kmem.freelist = r->next;
80102bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102be1:	8b 00                	mov    (%eax),%eax
80102be3:	a3 78 f8 10 80       	mov    %eax,0x8010f878
  if(kmem.use_lock)
80102be8:	a1 74 f8 10 80       	mov    0x8010f874,%eax
80102bed:	85 c0                	test   %eax,%eax
80102bef:	74 10                	je     80102c01 <kalloc+0x50>
    release(&kmem.lock);
80102bf1:	83 ec 0c             	sub    $0xc,%esp
80102bf4:	68 40 f8 10 80       	push   $0x8010f840
80102bf9:	e8 e8 20 00 00       	call   80104ce6 <release>
80102bfe:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102c04:	c9                   	leave  
80102c05:	c3                   	ret    

80102c06 <inb>:
{
80102c06:	55                   	push   %ebp
80102c07:	89 e5                	mov    %esp,%ebp
80102c09:	83 ec 14             	sub    $0x14,%esp
80102c0c:	8b 45 08             	mov    0x8(%ebp),%eax
80102c0f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c13:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102c17:	89 c2                	mov    %eax,%edx
80102c19:	ec                   	in     (%dx),%al
80102c1a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102c1d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102c21:	c9                   	leave  
80102c22:	c3                   	ret    

80102c23 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102c23:	55                   	push   %ebp
80102c24:	89 e5                	mov    %esp,%ebp
80102c26:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102c29:	6a 64                	push   $0x64
80102c2b:	e8 d6 ff ff ff       	call   80102c06 <inb>
80102c30:	83 c4 04             	add    $0x4,%esp
80102c33:	0f b6 c0             	movzbl %al,%eax
80102c36:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c3c:	83 e0 01             	and    $0x1,%eax
80102c3f:	85 c0                	test   %eax,%eax
80102c41:	75 0a                	jne    80102c4d <kbdgetc+0x2a>
    return -1;
80102c43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102c48:	e9 23 01 00 00       	jmp    80102d70 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102c4d:	6a 60                	push   $0x60
80102c4f:	e8 b2 ff ff ff       	call   80102c06 <inb>
80102c54:	83 c4 04             	add    $0x4,%esp
80102c57:	0f b6 c0             	movzbl %al,%eax
80102c5a:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102c5d:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102c64:	75 17                	jne    80102c7d <kbdgetc+0x5a>
    shift |= E0ESC;
80102c66:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c6b:	83 c8 40             	or     $0x40,%eax
80102c6e:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102c73:	b8 00 00 00 00       	mov    $0x0,%eax
80102c78:	e9 f3 00 00 00       	jmp    80102d70 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102c7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c80:	25 80 00 00 00       	and    $0x80,%eax
80102c85:	85 c0                	test   %eax,%eax
80102c87:	74 45                	je     80102cce <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102c89:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c8e:	83 e0 40             	and    $0x40,%eax
80102c91:	85 c0                	test   %eax,%eax
80102c93:	75 08                	jne    80102c9d <kbdgetc+0x7a>
80102c95:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c98:	83 e0 7f             	and    $0x7f,%eax
80102c9b:	eb 03                	jmp    80102ca0 <kbdgetc+0x7d>
80102c9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ca0:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102ca3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ca6:	05 20 90 10 80       	add    $0x80109020,%eax
80102cab:	0f b6 00             	movzbl (%eax),%eax
80102cae:	83 c8 40             	or     $0x40,%eax
80102cb1:	0f b6 c0             	movzbl %al,%eax
80102cb4:	f7 d0                	not    %eax
80102cb6:	89 c2                	mov    %eax,%edx
80102cb8:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102cbd:	21 d0                	and    %edx,%eax
80102cbf:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102cc4:	b8 00 00 00 00       	mov    $0x0,%eax
80102cc9:	e9 a2 00 00 00       	jmp    80102d70 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102cce:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102cd3:	83 e0 40             	and    $0x40,%eax
80102cd6:	85 c0                	test   %eax,%eax
80102cd8:	74 14                	je     80102cee <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102cda:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102ce1:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102ce6:	83 e0 bf             	and    $0xffffffbf,%eax
80102ce9:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
80102cee:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cf1:	05 20 90 10 80       	add    $0x80109020,%eax
80102cf6:	0f b6 00             	movzbl (%eax),%eax
80102cf9:	0f b6 d0             	movzbl %al,%edx
80102cfc:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d01:	09 d0                	or     %edx,%eax
80102d03:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80102d08:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d0b:	05 20 91 10 80       	add    $0x80109120,%eax
80102d10:	0f b6 00             	movzbl (%eax),%eax
80102d13:	0f b6 d0             	movzbl %al,%edx
80102d16:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d1b:	31 d0                	xor    %edx,%eax
80102d1d:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102d22:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d27:	83 e0 03             	and    $0x3,%eax
80102d2a:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102d31:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d34:	01 d0                	add    %edx,%eax
80102d36:	0f b6 00             	movzbl (%eax),%eax
80102d39:	0f b6 c0             	movzbl %al,%eax
80102d3c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102d3f:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d44:	83 e0 08             	and    $0x8,%eax
80102d47:	85 c0                	test   %eax,%eax
80102d49:	74 22                	je     80102d6d <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102d4b:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102d4f:	76 0c                	jbe    80102d5d <kbdgetc+0x13a>
80102d51:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102d55:	77 06                	ja     80102d5d <kbdgetc+0x13a>
      c += 'A' - 'a';
80102d57:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102d5b:	eb 10                	jmp    80102d6d <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102d5d:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102d61:	76 0a                	jbe    80102d6d <kbdgetc+0x14a>
80102d63:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102d67:	77 04                	ja     80102d6d <kbdgetc+0x14a>
      c += 'a' - 'A';
80102d69:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102d6d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102d70:	c9                   	leave  
80102d71:	c3                   	ret    

80102d72 <kbdintr>:

void
kbdintr(void)
{
80102d72:	55                   	push   %ebp
80102d73:	89 e5                	mov    %esp,%ebp
80102d75:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102d78:	83 ec 0c             	sub    $0xc,%esp
80102d7b:	68 23 2c 10 80       	push   $0x80102c23
80102d80:	e8 58 da ff ff       	call   801007dd <consoleintr>
80102d85:	83 c4 10             	add    $0x10,%esp
}
80102d88:	90                   	nop
80102d89:	c9                   	leave  
80102d8a:	c3                   	ret    

80102d8b <outb>:
{
80102d8b:	55                   	push   %ebp
80102d8c:	89 e5                	mov    %esp,%ebp
80102d8e:	83 ec 08             	sub    $0x8,%esp
80102d91:	8b 55 08             	mov    0x8(%ebp),%edx
80102d94:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d97:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102d9b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d9e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102da2:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102da6:	ee                   	out    %al,(%dx)
}
80102da7:	90                   	nop
80102da8:	c9                   	leave  
80102da9:	c3                   	ret    

80102daa <readeflags>:
{
80102daa:	55                   	push   %ebp
80102dab:	89 e5                	mov    %esp,%ebp
80102dad:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102db0:	9c                   	pushf  
80102db1:	58                   	pop    %eax
80102db2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102db5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102db8:	c9                   	leave  
80102db9:	c3                   	ret    

80102dba <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102dba:	55                   	push   %ebp
80102dbb:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102dbd:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102dc2:	8b 55 08             	mov    0x8(%ebp),%edx
80102dc5:	c1 e2 02             	shl    $0x2,%edx
80102dc8:	01 c2                	add    %eax,%edx
80102dca:	8b 45 0c             	mov    0xc(%ebp),%eax
80102dcd:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102dcf:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102dd4:	83 c0 20             	add    $0x20,%eax
80102dd7:	8b 00                	mov    (%eax),%eax
}
80102dd9:	90                   	nop
80102dda:	5d                   	pop    %ebp
80102ddb:	c3                   	ret    

80102ddc <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102ddc:	55                   	push   %ebp
80102ddd:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80102ddf:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102de4:	85 c0                	test   %eax,%eax
80102de6:	0f 84 0b 01 00 00    	je     80102ef7 <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102dec:	68 3f 01 00 00       	push   $0x13f
80102df1:	6a 3c                	push   $0x3c
80102df3:	e8 c2 ff ff ff       	call   80102dba <lapicw>
80102df8:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102dfb:	6a 0b                	push   $0xb
80102dfd:	68 f8 00 00 00       	push   $0xf8
80102e02:	e8 b3 ff ff ff       	call   80102dba <lapicw>
80102e07:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102e0a:	68 20 00 02 00       	push   $0x20020
80102e0f:	68 c8 00 00 00       	push   $0xc8
80102e14:	e8 a1 ff ff ff       	call   80102dba <lapicw>
80102e19:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
80102e1c:	68 80 96 98 00       	push   $0x989680
80102e21:	68 e0 00 00 00       	push   $0xe0
80102e26:	e8 8f ff ff ff       	call   80102dba <lapicw>
80102e2b:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102e2e:	68 00 00 01 00       	push   $0x10000
80102e33:	68 d4 00 00 00       	push   $0xd4
80102e38:	e8 7d ff ff ff       	call   80102dba <lapicw>
80102e3d:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102e40:	68 00 00 01 00       	push   $0x10000
80102e45:	68 d8 00 00 00       	push   $0xd8
80102e4a:	e8 6b ff ff ff       	call   80102dba <lapicw>
80102e4f:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102e52:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102e57:	83 c0 30             	add    $0x30,%eax
80102e5a:	8b 00                	mov    (%eax),%eax
80102e5c:	c1 e8 10             	shr    $0x10,%eax
80102e5f:	0f b6 c0             	movzbl %al,%eax
80102e62:	83 f8 03             	cmp    $0x3,%eax
80102e65:	76 12                	jbe    80102e79 <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80102e67:	68 00 00 01 00       	push   $0x10000
80102e6c:	68 d0 00 00 00       	push   $0xd0
80102e71:	e8 44 ff ff ff       	call   80102dba <lapicw>
80102e76:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102e79:	6a 33                	push   $0x33
80102e7b:	68 dc 00 00 00       	push   $0xdc
80102e80:	e8 35 ff ff ff       	call   80102dba <lapicw>
80102e85:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102e88:	6a 00                	push   $0x0
80102e8a:	68 a0 00 00 00       	push   $0xa0
80102e8f:	e8 26 ff ff ff       	call   80102dba <lapicw>
80102e94:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102e97:	6a 00                	push   $0x0
80102e99:	68 a0 00 00 00       	push   $0xa0
80102e9e:	e8 17 ff ff ff       	call   80102dba <lapicw>
80102ea3:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102ea6:	6a 00                	push   $0x0
80102ea8:	6a 2c                	push   $0x2c
80102eaa:	e8 0b ff ff ff       	call   80102dba <lapicw>
80102eaf:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102eb2:	6a 00                	push   $0x0
80102eb4:	68 c4 00 00 00       	push   $0xc4
80102eb9:	e8 fc fe ff ff       	call   80102dba <lapicw>
80102ebe:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102ec1:	68 00 85 08 00       	push   $0x88500
80102ec6:	68 c0 00 00 00       	push   $0xc0
80102ecb:	e8 ea fe ff ff       	call   80102dba <lapicw>
80102ed0:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102ed3:	90                   	nop
80102ed4:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102ed9:	05 00 03 00 00       	add    $0x300,%eax
80102ede:	8b 00                	mov    (%eax),%eax
80102ee0:	25 00 10 00 00       	and    $0x1000,%eax
80102ee5:	85 c0                	test   %eax,%eax
80102ee7:	75 eb                	jne    80102ed4 <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102ee9:	6a 00                	push   $0x0
80102eeb:	6a 20                	push   $0x20
80102eed:	e8 c8 fe ff ff       	call   80102dba <lapicw>
80102ef2:	83 c4 08             	add    $0x8,%esp
80102ef5:	eb 01                	jmp    80102ef8 <lapicinit+0x11c>
    return;
80102ef7:	90                   	nop
}
80102ef8:	c9                   	leave  
80102ef9:	c3                   	ret    

80102efa <cpunum>:

int
cpunum(void)
{
80102efa:	55                   	push   %ebp
80102efb:	89 e5                	mov    %esp,%ebp
80102efd:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102f00:	e8 a5 fe ff ff       	call   80102daa <readeflags>
80102f05:	25 00 02 00 00       	and    $0x200,%eax
80102f0a:	85 c0                	test   %eax,%eax
80102f0c:	74 26                	je     80102f34 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
80102f0e:	a1 40 b6 10 80       	mov    0x8010b640,%eax
80102f13:	8d 50 01             	lea    0x1(%eax),%edx
80102f16:	89 15 40 b6 10 80    	mov    %edx,0x8010b640
80102f1c:	85 c0                	test   %eax,%eax
80102f1e:	75 14                	jne    80102f34 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80102f20:	8b 45 04             	mov    0x4(%ebp),%eax
80102f23:	83 ec 08             	sub    $0x8,%esp
80102f26:	50                   	push   %eax
80102f27:	68 10 83 10 80       	push   $0x80108310
80102f2c:	e8 95 d4 ff ff       	call   801003c6 <cprintf>
80102f31:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
80102f34:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102f39:	85 c0                	test   %eax,%eax
80102f3b:	74 0f                	je     80102f4c <cpunum+0x52>
    return lapic[ID]>>24;
80102f3d:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102f42:	83 c0 20             	add    $0x20,%eax
80102f45:	8b 00                	mov    (%eax),%eax
80102f47:	c1 e8 18             	shr    $0x18,%eax
80102f4a:	eb 05                	jmp    80102f51 <cpunum+0x57>
  return 0;
80102f4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102f51:	c9                   	leave  
80102f52:	c3                   	ret    

80102f53 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102f53:	55                   	push   %ebp
80102f54:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102f56:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102f5b:	85 c0                	test   %eax,%eax
80102f5d:	74 0c                	je     80102f6b <lapiceoi+0x18>
    lapicw(EOI, 0);
80102f5f:	6a 00                	push   $0x0
80102f61:	6a 2c                	push   $0x2c
80102f63:	e8 52 fe ff ff       	call   80102dba <lapicw>
80102f68:	83 c4 08             	add    $0x8,%esp
}
80102f6b:	90                   	nop
80102f6c:	c9                   	leave  
80102f6d:	c3                   	ret    

80102f6e <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102f6e:	55                   	push   %ebp
80102f6f:	89 e5                	mov    %esp,%ebp
}
80102f71:	90                   	nop
80102f72:	5d                   	pop    %ebp
80102f73:	c3                   	ret    

80102f74 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102f74:	55                   	push   %ebp
80102f75:	89 e5                	mov    %esp,%ebp
80102f77:	83 ec 14             	sub    $0x14,%esp
80102f7a:	8b 45 08             	mov    0x8(%ebp),%eax
80102f7d:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
80102f80:	6a 0f                	push   $0xf
80102f82:	6a 70                	push   $0x70
80102f84:	e8 02 fe ff ff       	call   80102d8b <outb>
80102f89:	83 c4 08             	add    $0x8,%esp
  outb(IO_RTC+1, 0x0A);
80102f8c:	6a 0a                	push   $0xa
80102f8e:	6a 71                	push   $0x71
80102f90:	e8 f6 fd ff ff       	call   80102d8b <outb>
80102f95:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102f98:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102f9f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102fa2:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102fa7:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102faa:	83 c0 02             	add    $0x2,%eax
80102fad:	8b 55 0c             	mov    0xc(%ebp),%edx
80102fb0:	c1 ea 04             	shr    $0x4,%edx
80102fb3:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102fb6:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102fba:	c1 e0 18             	shl    $0x18,%eax
80102fbd:	50                   	push   %eax
80102fbe:	68 c4 00 00 00       	push   $0xc4
80102fc3:	e8 f2 fd ff ff       	call   80102dba <lapicw>
80102fc8:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102fcb:	68 00 c5 00 00       	push   $0xc500
80102fd0:	68 c0 00 00 00       	push   $0xc0
80102fd5:	e8 e0 fd ff ff       	call   80102dba <lapicw>
80102fda:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102fdd:	68 c8 00 00 00       	push   $0xc8
80102fe2:	e8 87 ff ff ff       	call   80102f6e <microdelay>
80102fe7:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102fea:	68 00 85 00 00       	push   $0x8500
80102fef:	68 c0 00 00 00       	push   $0xc0
80102ff4:	e8 c1 fd ff ff       	call   80102dba <lapicw>
80102ff9:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102ffc:	6a 64                	push   $0x64
80102ffe:	e8 6b ff ff ff       	call   80102f6e <microdelay>
80103003:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103006:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010300d:	eb 3d                	jmp    8010304c <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
8010300f:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103013:	c1 e0 18             	shl    $0x18,%eax
80103016:	50                   	push   %eax
80103017:	68 c4 00 00 00       	push   $0xc4
8010301c:	e8 99 fd ff ff       	call   80102dba <lapicw>
80103021:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103024:	8b 45 0c             	mov    0xc(%ebp),%eax
80103027:	c1 e8 0c             	shr    $0xc,%eax
8010302a:	80 cc 06             	or     $0x6,%ah
8010302d:	50                   	push   %eax
8010302e:	68 c0 00 00 00       	push   $0xc0
80103033:	e8 82 fd ff ff       	call   80102dba <lapicw>
80103038:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
8010303b:	68 c8 00 00 00       	push   $0xc8
80103040:	e8 29 ff ff ff       	call   80102f6e <microdelay>
80103045:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80103048:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010304c:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103050:	7e bd                	jle    8010300f <lapicstartap+0x9b>
  }
}
80103052:	90                   	nop
80103053:	c9                   	leave  
80103054:	c3                   	ret    

80103055 <initlog>:

static void recover_from_log(void);

void
initlog(void)
{
80103055:	55                   	push   %ebp
80103056:	89 e5                	mov    %esp,%ebp
80103058:	83 ec 18             	sub    $0x18,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010305b:	83 ec 08             	sub    $0x8,%esp
8010305e:	68 3c 83 10 80       	push   $0x8010833c
80103063:	68 80 f8 10 80       	push   $0x8010f880
80103068:	e8 f0 1b 00 00       	call   80104c5d <initlock>
8010306d:	83 c4 10             	add    $0x10,%esp
  readsb(ROOTDEV, &sb);
80103070:	83 ec 08             	sub    $0x8,%esp
80103073:	8d 45 e8             	lea    -0x18(%ebp),%eax
80103076:	50                   	push   %eax
80103077:	6a 01                	push   $0x1
80103079:	e8 d7 e2 ff ff       	call   80101355 <readsb>
8010307e:	83 c4 10             	add    $0x10,%esp
  log.start = sb.size - sb.nlog;
80103081:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103084:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103087:	29 c2                	sub    %eax,%edx
80103089:	89 d0                	mov    %edx,%eax
8010308b:	a3 b4 f8 10 80       	mov    %eax,0x8010f8b4
  log.size = sb.nlog;
80103090:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103093:	a3 b8 f8 10 80       	mov    %eax,0x8010f8b8
  log.dev = ROOTDEV;
80103098:	c7 05 c0 f8 10 80 01 	movl   $0x1,0x8010f8c0
8010309f:	00 00 00 
  recover_from_log();
801030a2:	e8 b2 01 00 00       	call   80103259 <recover_from_log>
}
801030a7:	90                   	nop
801030a8:	c9                   	leave  
801030a9:	c3                   	ret    

801030aa <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
801030aa:	55                   	push   %ebp
801030ab:	89 e5                	mov    %esp,%ebp
801030ad:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801030b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801030b7:	e9 95 00 00 00       	jmp    80103151 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801030bc:	8b 15 b4 f8 10 80    	mov    0x8010f8b4,%edx
801030c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030c5:	01 d0                	add    %edx,%eax
801030c7:	83 c0 01             	add    $0x1,%eax
801030ca:	89 c2                	mov    %eax,%edx
801030cc:	a1 c0 f8 10 80       	mov    0x8010f8c0,%eax
801030d1:	83 ec 08             	sub    $0x8,%esp
801030d4:	52                   	push   %edx
801030d5:	50                   	push   %eax
801030d6:	e8 db d0 ff ff       	call   801001b6 <bread>
801030db:	83 c4 10             	add    $0x10,%esp
801030de:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
801030e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030e4:	83 c0 10             	add    $0x10,%eax
801030e7:	8b 04 85 88 f8 10 80 	mov    -0x7fef0778(,%eax,4),%eax
801030ee:	89 c2                	mov    %eax,%edx
801030f0:	a1 c0 f8 10 80       	mov    0x8010f8c0,%eax
801030f5:	83 ec 08             	sub    $0x8,%esp
801030f8:	52                   	push   %edx
801030f9:	50                   	push   %eax
801030fa:	e8 b7 d0 ff ff       	call   801001b6 <bread>
801030ff:	83 c4 10             	add    $0x10,%esp
80103102:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103105:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103108:	8d 50 18             	lea    0x18(%eax),%edx
8010310b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010310e:	83 c0 18             	add    $0x18,%eax
80103111:	83 ec 04             	sub    $0x4,%esp
80103114:	68 00 02 00 00       	push   $0x200
80103119:	52                   	push   %edx
8010311a:	50                   	push   %eax
8010311b:	e8 81 1e 00 00       	call   80104fa1 <memmove>
80103120:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103123:	83 ec 0c             	sub    $0xc,%esp
80103126:	ff 75 ec             	pushl  -0x14(%ebp)
80103129:	e8 c1 d0 ff ff       	call   801001ef <bwrite>
8010312e:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103131:	83 ec 0c             	sub    $0xc,%esp
80103134:	ff 75 f0             	pushl  -0x10(%ebp)
80103137:	e8 f2 d0 ff ff       	call   8010022e <brelse>
8010313c:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
8010313f:	83 ec 0c             	sub    $0xc,%esp
80103142:	ff 75 ec             	pushl  -0x14(%ebp)
80103145:	e8 e4 d0 ff ff       	call   8010022e <brelse>
8010314a:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010314d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103151:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
80103156:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103159:	0f 8f 5d ff ff ff    	jg     801030bc <install_trans+0x12>
  }
}
8010315f:	90                   	nop
80103160:	c9                   	leave  
80103161:	c3                   	ret    

80103162 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103162:	55                   	push   %ebp
80103163:	89 e5                	mov    %esp,%ebp
80103165:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103168:	a1 b4 f8 10 80       	mov    0x8010f8b4,%eax
8010316d:	89 c2                	mov    %eax,%edx
8010316f:	a1 c0 f8 10 80       	mov    0x8010f8c0,%eax
80103174:	83 ec 08             	sub    $0x8,%esp
80103177:	52                   	push   %edx
80103178:	50                   	push   %eax
80103179:	e8 38 d0 ff ff       	call   801001b6 <bread>
8010317e:	83 c4 10             	add    $0x10,%esp
80103181:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103184:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103187:	83 c0 18             	add    $0x18,%eax
8010318a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010318d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103190:	8b 00                	mov    (%eax),%eax
80103192:	a3 c4 f8 10 80       	mov    %eax,0x8010f8c4
  for (i = 0; i < log.lh.n; i++) {
80103197:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010319e:	eb 1b                	jmp    801031bb <read_head+0x59>
    log.lh.sector[i] = lh->sector[i];
801031a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801031a6:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801031aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801031ad:	83 c2 10             	add    $0x10,%edx
801031b0:	89 04 95 88 f8 10 80 	mov    %eax,-0x7fef0778(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801031b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801031bb:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
801031c0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801031c3:	7f db                	jg     801031a0 <read_head+0x3e>
  }
  brelse(buf);
801031c5:	83 ec 0c             	sub    $0xc,%esp
801031c8:	ff 75 f0             	pushl  -0x10(%ebp)
801031cb:	e8 5e d0 ff ff       	call   8010022e <brelse>
801031d0:	83 c4 10             	add    $0x10,%esp
}
801031d3:	90                   	nop
801031d4:	c9                   	leave  
801031d5:	c3                   	ret    

801031d6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801031d6:	55                   	push   %ebp
801031d7:	89 e5                	mov    %esp,%ebp
801031d9:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801031dc:	a1 b4 f8 10 80       	mov    0x8010f8b4,%eax
801031e1:	89 c2                	mov    %eax,%edx
801031e3:	a1 c0 f8 10 80       	mov    0x8010f8c0,%eax
801031e8:	83 ec 08             	sub    $0x8,%esp
801031eb:	52                   	push   %edx
801031ec:	50                   	push   %eax
801031ed:	e8 c4 cf ff ff       	call   801001b6 <bread>
801031f2:	83 c4 10             	add    $0x10,%esp
801031f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801031f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031fb:	83 c0 18             	add    $0x18,%eax
801031fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103201:	8b 15 c4 f8 10 80    	mov    0x8010f8c4,%edx
80103207:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010320a:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010320c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103213:	eb 1b                	jmp    80103230 <write_head+0x5a>
    hb->sector[i] = log.lh.sector[i];
80103215:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103218:	83 c0 10             	add    $0x10,%eax
8010321b:	8b 0c 85 88 f8 10 80 	mov    -0x7fef0778(,%eax,4),%ecx
80103222:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103225:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103228:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010322c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103230:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
80103235:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103238:	7f db                	jg     80103215 <write_head+0x3f>
  }
  bwrite(buf);
8010323a:	83 ec 0c             	sub    $0xc,%esp
8010323d:	ff 75 f0             	pushl  -0x10(%ebp)
80103240:	e8 aa cf ff ff       	call   801001ef <bwrite>
80103245:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103248:	83 ec 0c             	sub    $0xc,%esp
8010324b:	ff 75 f0             	pushl  -0x10(%ebp)
8010324e:	e8 db cf ff ff       	call   8010022e <brelse>
80103253:	83 c4 10             	add    $0x10,%esp
}
80103256:	90                   	nop
80103257:	c9                   	leave  
80103258:	c3                   	ret    

80103259 <recover_from_log>:

static void
recover_from_log(void)
{
80103259:	55                   	push   %ebp
8010325a:	89 e5                	mov    %esp,%ebp
8010325c:	83 ec 08             	sub    $0x8,%esp
  read_head();      
8010325f:	e8 fe fe ff ff       	call   80103162 <read_head>
  install_trans(); // if committed, copy from log to disk
80103264:	e8 41 fe ff ff       	call   801030aa <install_trans>
  log.lh.n = 0;
80103269:	c7 05 c4 f8 10 80 00 	movl   $0x0,0x8010f8c4
80103270:	00 00 00 
  write_head(); // clear the log
80103273:	e8 5e ff ff ff       	call   801031d6 <write_head>
}
80103278:	90                   	nop
80103279:	c9                   	leave  
8010327a:	c3                   	ret    

8010327b <begin_trans>:

void
begin_trans(void)
{
8010327b:	55                   	push   %ebp
8010327c:	89 e5                	mov    %esp,%ebp
8010327e:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103281:	83 ec 0c             	sub    $0xc,%esp
80103284:	68 80 f8 10 80       	push   $0x8010f880
80103289:	e8 f1 19 00 00       	call   80104c7f <acquire>
8010328e:	83 c4 10             	add    $0x10,%esp
  while (log.busy) {
80103291:	eb 15                	jmp    801032a8 <begin_trans+0x2d>
    sleep(&log, &log.lock);
80103293:	83 ec 08             	sub    $0x8,%esp
80103296:	68 80 f8 10 80       	push   $0x8010f880
8010329b:	68 80 f8 10 80       	push   $0x8010f880
801032a0:	e8 e1 16 00 00       	call   80104986 <sleep>
801032a5:	83 c4 10             	add    $0x10,%esp
  while (log.busy) {
801032a8:	a1 bc f8 10 80       	mov    0x8010f8bc,%eax
801032ad:	85 c0                	test   %eax,%eax
801032af:	75 e2                	jne    80103293 <begin_trans+0x18>
  }
  log.busy = 1;
801032b1:	c7 05 bc f8 10 80 01 	movl   $0x1,0x8010f8bc
801032b8:	00 00 00 
  release(&log.lock);
801032bb:	83 ec 0c             	sub    $0xc,%esp
801032be:	68 80 f8 10 80       	push   $0x8010f880
801032c3:	e8 1e 1a 00 00       	call   80104ce6 <release>
801032c8:	83 c4 10             	add    $0x10,%esp
}
801032cb:	90                   	nop
801032cc:	c9                   	leave  
801032cd:	c3                   	ret    

801032ce <commit_trans>:

void
commit_trans(void)
{
801032ce:	55                   	push   %ebp
801032cf:	89 e5                	mov    %esp,%ebp
801032d1:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801032d4:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
801032d9:	85 c0                	test   %eax,%eax
801032db:	7e 19                	jle    801032f6 <commit_trans+0x28>
    write_head();    // Write header to disk -- the real commit
801032dd:	e8 f4 fe ff ff       	call   801031d6 <write_head>
    install_trans(); // Now install writes to home locations
801032e2:	e8 c3 fd ff ff       	call   801030aa <install_trans>
    log.lh.n = 0; 
801032e7:	c7 05 c4 f8 10 80 00 	movl   $0x0,0x8010f8c4
801032ee:	00 00 00 
    write_head();    // Erase the transaction from the log
801032f1:	e8 e0 fe ff ff       	call   801031d6 <write_head>
  }
  
  acquire(&log.lock);
801032f6:	83 ec 0c             	sub    $0xc,%esp
801032f9:	68 80 f8 10 80       	push   $0x8010f880
801032fe:	e8 7c 19 00 00       	call   80104c7f <acquire>
80103303:	83 c4 10             	add    $0x10,%esp
  log.busy = 0;
80103306:	c7 05 bc f8 10 80 00 	movl   $0x0,0x8010f8bc
8010330d:	00 00 00 
  wakeup(&log);
80103310:	83 ec 0c             	sub    $0xc,%esp
80103313:	68 80 f8 10 80       	push   $0x8010f880
80103318:	e8 54 17 00 00       	call   80104a71 <wakeup>
8010331d:	83 c4 10             	add    $0x10,%esp
  release(&log.lock);
80103320:	83 ec 0c             	sub    $0xc,%esp
80103323:	68 80 f8 10 80       	push   $0x8010f880
80103328:	e8 b9 19 00 00       	call   80104ce6 <release>
8010332d:	83 c4 10             	add    $0x10,%esp
}
80103330:	90                   	nop
80103331:	c9                   	leave  
80103332:	c3                   	ret    

80103333 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103333:	55                   	push   %ebp
80103334:	89 e5                	mov    %esp,%ebp
80103336:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103339:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
8010333e:	83 f8 09             	cmp    $0x9,%eax
80103341:	7f 12                	jg     80103355 <log_write+0x22>
80103343:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
80103348:	8b 15 b8 f8 10 80    	mov    0x8010f8b8,%edx
8010334e:	83 ea 01             	sub    $0x1,%edx
80103351:	39 d0                	cmp    %edx,%eax
80103353:	7c 0d                	jl     80103362 <log_write+0x2f>
    panic("too big a transaction");
80103355:	83 ec 0c             	sub    $0xc,%esp
80103358:	68 40 83 10 80       	push   $0x80108340
8010335d:	e8 04 d2 ff ff       	call   80100566 <panic>
  if (!log.busy)
80103362:	a1 bc f8 10 80       	mov    0x8010f8bc,%eax
80103367:	85 c0                	test   %eax,%eax
80103369:	75 0d                	jne    80103378 <log_write+0x45>
    panic("write outside of trans");
8010336b:	83 ec 0c             	sub    $0xc,%esp
8010336e:	68 56 83 10 80       	push   $0x80108356
80103373:	e8 ee d1 ff ff       	call   80100566 <panic>

  for (i = 0; i < log.lh.n; i++) {
80103378:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010337f:	eb 1d                	jmp    8010339e <log_write+0x6b>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
80103381:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103384:	83 c0 10             	add    $0x10,%eax
80103387:	8b 04 85 88 f8 10 80 	mov    -0x7fef0778(,%eax,4),%eax
8010338e:	89 c2                	mov    %eax,%edx
80103390:	8b 45 08             	mov    0x8(%ebp),%eax
80103393:	8b 40 08             	mov    0x8(%eax),%eax
80103396:	39 c2                	cmp    %eax,%edx
80103398:	74 10                	je     801033aa <log_write+0x77>
  for (i = 0; i < log.lh.n; i++) {
8010339a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010339e:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
801033a3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033a6:	7f d9                	jg     80103381 <log_write+0x4e>
801033a8:	eb 01                	jmp    801033ab <log_write+0x78>
      break;
801033aa:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
801033ab:	8b 45 08             	mov    0x8(%ebp),%eax
801033ae:	8b 40 08             	mov    0x8(%eax),%eax
801033b1:	89 c2                	mov    %eax,%edx
801033b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033b6:	83 c0 10             	add    $0x10,%eax
801033b9:	89 14 85 88 f8 10 80 	mov    %edx,-0x7fef0778(,%eax,4)
  struct buf *lbuf = bread(b->dev, log.start+i+1);
801033c0:	8b 15 b4 f8 10 80    	mov    0x8010f8b4,%edx
801033c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033c9:	01 d0                	add    %edx,%eax
801033cb:	83 c0 01             	add    $0x1,%eax
801033ce:	89 c2                	mov    %eax,%edx
801033d0:	8b 45 08             	mov    0x8(%ebp),%eax
801033d3:	8b 40 04             	mov    0x4(%eax),%eax
801033d6:	83 ec 08             	sub    $0x8,%esp
801033d9:	52                   	push   %edx
801033da:	50                   	push   %eax
801033db:	e8 d6 cd ff ff       	call   801001b6 <bread>
801033e0:	83 c4 10             	add    $0x10,%esp
801033e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(lbuf->data, b->data, BSIZE);
801033e6:	8b 45 08             	mov    0x8(%ebp),%eax
801033e9:	8d 50 18             	lea    0x18(%eax),%edx
801033ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033ef:	83 c0 18             	add    $0x18,%eax
801033f2:	83 ec 04             	sub    $0x4,%esp
801033f5:	68 00 02 00 00       	push   $0x200
801033fa:	52                   	push   %edx
801033fb:	50                   	push   %eax
801033fc:	e8 a0 1b 00 00       	call   80104fa1 <memmove>
80103401:	83 c4 10             	add    $0x10,%esp
  bwrite(lbuf);
80103404:	83 ec 0c             	sub    $0xc,%esp
80103407:	ff 75 f0             	pushl  -0x10(%ebp)
8010340a:	e8 e0 cd ff ff       	call   801001ef <bwrite>
8010340f:	83 c4 10             	add    $0x10,%esp
  brelse(lbuf);
80103412:	83 ec 0c             	sub    $0xc,%esp
80103415:	ff 75 f0             	pushl  -0x10(%ebp)
80103418:	e8 11 ce ff ff       	call   8010022e <brelse>
8010341d:	83 c4 10             	add    $0x10,%esp
  if (i == log.lh.n)
80103420:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
80103425:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103428:	75 0d                	jne    80103437 <log_write+0x104>
    log.lh.n++;
8010342a:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
8010342f:	83 c0 01             	add    $0x1,%eax
80103432:	a3 c4 f8 10 80       	mov    %eax,0x8010f8c4
  b->flags |= B_DIRTY; // XXX prevent eviction
80103437:	8b 45 08             	mov    0x8(%ebp),%eax
8010343a:	8b 00                	mov    (%eax),%eax
8010343c:	83 c8 04             	or     $0x4,%eax
8010343f:	89 c2                	mov    %eax,%edx
80103441:	8b 45 08             	mov    0x8(%ebp),%eax
80103444:	89 10                	mov    %edx,(%eax)
}
80103446:	90                   	nop
80103447:	c9                   	leave  
80103448:	c3                   	ret    

80103449 <v2p>:
80103449:	55                   	push   %ebp
8010344a:	89 e5                	mov    %esp,%ebp
8010344c:	8b 45 08             	mov    0x8(%ebp),%eax
8010344f:	05 00 00 00 80       	add    $0x80000000,%eax
80103454:	5d                   	pop    %ebp
80103455:	c3                   	ret    

80103456 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103456:	55                   	push   %ebp
80103457:	89 e5                	mov    %esp,%ebp
80103459:	8b 45 08             	mov    0x8(%ebp),%eax
8010345c:	05 00 00 00 80       	add    $0x80000000,%eax
80103461:	5d                   	pop    %ebp
80103462:	c3                   	ret    

80103463 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103463:	55                   	push   %ebp
80103464:	89 e5                	mov    %esp,%ebp
80103466:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103469:	8b 55 08             	mov    0x8(%ebp),%edx
8010346c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010346f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103472:	f0 87 02             	lock xchg %eax,(%edx)
80103475:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103478:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010347b:	c9                   	leave  
8010347c:	c3                   	ret    

8010347d <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010347d:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103481:	83 e4 f0             	and    $0xfffffff0,%esp
80103484:	ff 71 fc             	pushl  -0x4(%ecx)
80103487:	55                   	push   %ebp
80103488:	89 e5                	mov    %esp,%ebp
8010348a:	51                   	push   %ecx
8010348b:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010348e:	83 ec 08             	sub    $0x8,%esp
80103491:	68 00 00 40 80       	push   $0x80400000
80103496:	68 fc 27 11 80       	push   $0x801127fc
8010349b:	e8 da f5 ff ff       	call   80102a7a <kinit1>
801034a0:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801034a3:	e8 2d 45 00 00       	call   801079d5 <kvmalloc>
  mpinit();        // collect info about this machine
801034a8:	e8 1e 04 00 00       	call   801038cb <mpinit>
  lapicinit();
801034ad:	e8 2a f9 ff ff       	call   80102ddc <lapicinit>
  seginit();       // set up segments
801034b2:	e8 c7 3e 00 00       	call   8010737e <seginit>
  picinit();       // interrupt controller
801034b7:	e8 65 06 00 00       	call   80103b21 <picinit>
  ioapicinit();    // another interrupt controller
801034bc:	e8 ae f4 ff ff       	call   8010296f <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801034c1:	e8 23 d6 ff ff       	call   80100ae9 <consoleinit>
  uartinit();      // serial port
801034c6:	e8 3b 32 00 00       	call   80106706 <uartinit>
  pinit();         // process table
801034cb:	e8 4e 0b 00 00       	call   8010401e <pinit>
  tvinit();        // trap vectors
801034d0:	e8 fb 2d 00 00       	call   801062d0 <tvinit>
  binit();         // buffer cache
801034d5:	e8 5a cb ff ff       	call   80100034 <binit>
  fileinit();      // file table
801034da:	e8 67 da ff ff       	call   80100f46 <fileinit>
  iinit();         // inode cache
801034df:	e8 40 e1 ff ff       	call   80101624 <iinit>
  ideinit();       // disk
801034e4:	e8 ca f0 ff ff       	call   801025b3 <ideinit>
  if(!ismp)
801034e9:	a1 04 f9 10 80       	mov    0x8010f904,%eax
801034ee:	85 c0                	test   %eax,%eax
801034f0:	75 05                	jne    801034f7 <main+0x7a>
    timerinit();   // uniprocessor timer
801034f2:	e8 36 2d 00 00       	call   8010622d <timerinit>
  startothers();   // start other processors
801034f7:	e8 72 00 00 00       	call   8010356e <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801034fc:	83 ec 08             	sub    $0x8,%esp
801034ff:	68 00 00 00 8e       	push   $0x8e000000
80103504:	68 00 00 40 80       	push   $0x80400000
80103509:	e8 a5 f5 ff ff       	call   80102ab3 <kinit2>
8010350e:	83 c4 10             	add    $0x10,%esp

  cprintf("EEE3535 Operating Systems: starting xv6 ...\n");
80103511:	83 ec 0c             	sub    $0xc,%esp
80103514:	68 70 83 10 80       	push   $0x80108370
80103519:	e8 a8 ce ff ff       	call   801003c6 <cprintf>
8010351e:	83 c4 10             	add    $0x10,%esp

  userinit();      // first user process
80103521:	e8 78 0c 00 00       	call   8010419e <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103526:	e8 1a 00 00 00       	call   80103545 <mpmain>

8010352b <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010352b:	55                   	push   %ebp
8010352c:	89 e5                	mov    %esp,%ebp
8010352e:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80103531:	e8 b7 44 00 00       	call   801079ed <switchkvm>
  seginit();
80103536:	e8 43 3e 00 00       	call   8010737e <seginit>
  lapicinit();
8010353b:	e8 9c f8 ff ff       	call   80102ddc <lapicinit>
  mpmain();
80103540:	e8 00 00 00 00       	call   80103545 <mpmain>

80103545 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103545:	55                   	push   %ebp
80103546:	89 e5                	mov    %esp,%ebp
80103548:	83 ec 08             	sub    $0x8,%esp
  //cprintf("cpu%d: starting\n", cpu->id);
  idtinit();       // load idt register
8010354b:	e8 f6 2e 00 00       	call   80106446 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103550:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103556:	05 a8 00 00 00       	add    $0xa8,%eax
8010355b:	83 ec 08             	sub    $0x8,%esp
8010355e:	6a 01                	push   $0x1
80103560:	50                   	push   %eax
80103561:	e8 fd fe ff ff       	call   80103463 <xchg>
80103566:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103569:	e8 4b 12 00 00       	call   801047b9 <scheduler>

8010356e <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
8010356e:	55                   	push   %ebp
8010356f:	89 e5                	mov    %esp,%ebp
80103571:	53                   	push   %ebx
80103572:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103575:	68 00 70 00 00       	push   $0x7000
8010357a:	e8 d7 fe ff ff       	call   80103456 <p2v>
8010357f:	83 c4 04             	add    $0x4,%esp
80103582:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103585:	b8 8a 00 00 00       	mov    $0x8a,%eax
8010358a:	83 ec 04             	sub    $0x4,%esp
8010358d:	50                   	push   %eax
8010358e:	68 0c b5 10 80       	push   $0x8010b50c
80103593:	ff 75 f0             	pushl  -0x10(%ebp)
80103596:	e8 06 1a 00 00       	call   80104fa1 <memmove>
8010359b:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
8010359e:	c7 45 f4 20 f9 10 80 	movl   $0x8010f920,-0xc(%ebp)
801035a5:	e9 90 00 00 00       	jmp    8010363a <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
801035aa:	e8 4b f9 ff ff       	call   80102efa <cpunum>
801035af:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801035b5:	05 20 f9 10 80       	add    $0x8010f920,%eax
801035ba:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801035bd:	74 73                	je     80103632 <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801035bf:	e8 ed f5 ff ff       	call   80102bb1 <kalloc>
801035c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801035c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035ca:	83 e8 04             	sub    $0x4,%eax
801035cd:	8b 55 ec             	mov    -0x14(%ebp),%edx
801035d0:	81 c2 00 10 00 00    	add    $0x1000,%edx
801035d6:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801035d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035db:	83 e8 08             	sub    $0x8,%eax
801035de:	c7 00 2b 35 10 80    	movl   $0x8010352b,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
801035e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035e7:	8d 58 f4             	lea    -0xc(%eax),%ebx
801035ea:	83 ec 0c             	sub    $0xc,%esp
801035ed:	68 00 a0 10 80       	push   $0x8010a000
801035f2:	e8 52 fe ff ff       	call   80103449 <v2p>
801035f7:	83 c4 10             	add    $0x10,%esp
801035fa:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
801035fc:	83 ec 0c             	sub    $0xc,%esp
801035ff:	ff 75 f0             	pushl  -0x10(%ebp)
80103602:	e8 42 fe ff ff       	call   80103449 <v2p>
80103607:	83 c4 10             	add    $0x10,%esp
8010360a:	89 c2                	mov    %eax,%edx
8010360c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010360f:	0f b6 00             	movzbl (%eax),%eax
80103612:	0f b6 c0             	movzbl %al,%eax
80103615:	83 ec 08             	sub    $0x8,%esp
80103618:	52                   	push   %edx
80103619:	50                   	push   %eax
8010361a:	e8 55 f9 ff ff       	call   80102f74 <lapicstartap>
8010361f:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103622:	90                   	nop
80103623:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103626:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010362c:	85 c0                	test   %eax,%eax
8010362e:	74 f3                	je     80103623 <startothers+0xb5>
80103630:	eb 01                	jmp    80103633 <startothers+0xc5>
      continue;
80103632:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103633:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
8010363a:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
8010363f:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103645:	05 20 f9 10 80       	add    $0x8010f920,%eax
8010364a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010364d:	0f 87 57 ff ff ff    	ja     801035aa <startothers+0x3c>
      ;
  }
}
80103653:	90                   	nop
80103654:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103657:	c9                   	leave  
80103658:	c3                   	ret    

80103659 <p2v>:
80103659:	55                   	push   %ebp
8010365a:	89 e5                	mov    %esp,%ebp
8010365c:	8b 45 08             	mov    0x8(%ebp),%eax
8010365f:	05 00 00 00 80       	add    $0x80000000,%eax
80103664:	5d                   	pop    %ebp
80103665:	c3                   	ret    

80103666 <inb>:
{
80103666:	55                   	push   %ebp
80103667:	89 e5                	mov    %esp,%ebp
80103669:	83 ec 14             	sub    $0x14,%esp
8010366c:	8b 45 08             	mov    0x8(%ebp),%eax
8010366f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103673:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103677:	89 c2                	mov    %eax,%edx
80103679:	ec                   	in     (%dx),%al
8010367a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010367d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103681:	c9                   	leave  
80103682:	c3                   	ret    

80103683 <outb>:
{
80103683:	55                   	push   %ebp
80103684:	89 e5                	mov    %esp,%ebp
80103686:	83 ec 08             	sub    $0x8,%esp
80103689:	8b 55 08             	mov    0x8(%ebp),%edx
8010368c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010368f:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103693:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103696:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010369a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010369e:	ee                   	out    %al,(%dx)
}
8010369f:	90                   	nop
801036a0:	c9                   	leave  
801036a1:	c3                   	ret    

801036a2 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
801036a2:	55                   	push   %ebp
801036a3:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
801036a5:	a1 44 b6 10 80       	mov    0x8010b644,%eax
801036aa:	89 c2                	mov    %eax,%edx
801036ac:	b8 20 f9 10 80       	mov    $0x8010f920,%eax
801036b1:	29 c2                	sub    %eax,%edx
801036b3:	89 d0                	mov    %edx,%eax
801036b5:	c1 f8 02             	sar    $0x2,%eax
801036b8:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
801036be:	5d                   	pop    %ebp
801036bf:	c3                   	ret    

801036c0 <sum>:

static uchar
sum(uchar *addr, int len)
{
801036c0:	55                   	push   %ebp
801036c1:	89 e5                	mov    %esp,%ebp
801036c3:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
801036c6:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
801036cd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801036d4:	eb 15                	jmp    801036eb <sum+0x2b>
    sum += addr[i];
801036d6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801036d9:	8b 45 08             	mov    0x8(%ebp),%eax
801036dc:	01 d0                	add    %edx,%eax
801036de:	0f b6 00             	movzbl (%eax),%eax
801036e1:	0f b6 c0             	movzbl %al,%eax
801036e4:	01 45 f8             	add    %eax,-0x8(%ebp)
  for(i=0; i<len; i++)
801036e7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801036eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801036ee:	3b 45 0c             	cmp    0xc(%ebp),%eax
801036f1:	7c e3                	jl     801036d6 <sum+0x16>
  return sum;
801036f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801036f6:	c9                   	leave  
801036f7:	c3                   	ret    

801036f8 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
801036f8:	55                   	push   %ebp
801036f9:	89 e5                	mov    %esp,%ebp
801036fb:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
801036fe:	ff 75 08             	pushl  0x8(%ebp)
80103701:	e8 53 ff ff ff       	call   80103659 <p2v>
80103706:	83 c4 04             	add    $0x4,%esp
80103709:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
8010370c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010370f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103712:	01 d0                	add    %edx,%eax
80103714:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103717:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010371a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010371d:	eb 36                	jmp    80103755 <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
8010371f:	83 ec 04             	sub    $0x4,%esp
80103722:	6a 04                	push   $0x4
80103724:	68 a0 83 10 80       	push   $0x801083a0
80103729:	ff 75 f4             	pushl  -0xc(%ebp)
8010372c:	e8 18 18 00 00       	call   80104f49 <memcmp>
80103731:	83 c4 10             	add    $0x10,%esp
80103734:	85 c0                	test   %eax,%eax
80103736:	75 19                	jne    80103751 <mpsearch1+0x59>
80103738:	83 ec 08             	sub    $0x8,%esp
8010373b:	6a 10                	push   $0x10
8010373d:	ff 75 f4             	pushl  -0xc(%ebp)
80103740:	e8 7b ff ff ff       	call   801036c0 <sum>
80103745:	83 c4 10             	add    $0x10,%esp
80103748:	84 c0                	test   %al,%al
8010374a:	75 05                	jne    80103751 <mpsearch1+0x59>
      return (struct mp*)p;
8010374c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010374f:	eb 11                	jmp    80103762 <mpsearch1+0x6a>
  for(p = addr; p < e; p += sizeof(struct mp))
80103751:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103755:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103758:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010375b:	72 c2                	jb     8010371f <mpsearch1+0x27>
  return 0;
8010375d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103762:	c9                   	leave  
80103763:	c3                   	ret    

80103764 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103764:	55                   	push   %ebp
80103765:	89 e5                	mov    %esp,%ebp
80103767:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
8010376a:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103771:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103774:	83 c0 0f             	add    $0xf,%eax
80103777:	0f b6 00             	movzbl (%eax),%eax
8010377a:	0f b6 c0             	movzbl %al,%eax
8010377d:	c1 e0 08             	shl    $0x8,%eax
80103780:	89 c2                	mov    %eax,%edx
80103782:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103785:	83 c0 0e             	add    $0xe,%eax
80103788:	0f b6 00             	movzbl (%eax),%eax
8010378b:	0f b6 c0             	movzbl %al,%eax
8010378e:	09 d0                	or     %edx,%eax
80103790:	c1 e0 04             	shl    $0x4,%eax
80103793:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103796:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010379a:	74 21                	je     801037bd <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
8010379c:	83 ec 08             	sub    $0x8,%esp
8010379f:	68 00 04 00 00       	push   $0x400
801037a4:	ff 75 f0             	pushl  -0x10(%ebp)
801037a7:	e8 4c ff ff ff       	call   801036f8 <mpsearch1>
801037ac:	83 c4 10             	add    $0x10,%esp
801037af:	89 45 ec             	mov    %eax,-0x14(%ebp)
801037b2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801037b6:	74 51                	je     80103809 <mpsearch+0xa5>
      return mp;
801037b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037bb:	eb 61                	jmp    8010381e <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
801037bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037c0:	83 c0 14             	add    $0x14,%eax
801037c3:	0f b6 00             	movzbl (%eax),%eax
801037c6:	0f b6 c0             	movzbl %al,%eax
801037c9:	c1 e0 08             	shl    $0x8,%eax
801037cc:	89 c2                	mov    %eax,%edx
801037ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037d1:	83 c0 13             	add    $0x13,%eax
801037d4:	0f b6 00             	movzbl (%eax),%eax
801037d7:	0f b6 c0             	movzbl %al,%eax
801037da:	09 d0                	or     %edx,%eax
801037dc:	c1 e0 0a             	shl    $0xa,%eax
801037df:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
801037e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037e5:	2d 00 04 00 00       	sub    $0x400,%eax
801037ea:	83 ec 08             	sub    $0x8,%esp
801037ed:	68 00 04 00 00       	push   $0x400
801037f2:	50                   	push   %eax
801037f3:	e8 00 ff ff ff       	call   801036f8 <mpsearch1>
801037f8:	83 c4 10             	add    $0x10,%esp
801037fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
801037fe:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103802:	74 05                	je     80103809 <mpsearch+0xa5>
      return mp;
80103804:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103807:	eb 15                	jmp    8010381e <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103809:	83 ec 08             	sub    $0x8,%esp
8010380c:	68 00 00 01 00       	push   $0x10000
80103811:	68 00 00 0f 00       	push   $0xf0000
80103816:	e8 dd fe ff ff       	call   801036f8 <mpsearch1>
8010381b:	83 c4 10             	add    $0x10,%esp
}
8010381e:	c9                   	leave  
8010381f:	c3                   	ret    

80103820 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103820:	55                   	push   %ebp
80103821:	89 e5                	mov    %esp,%ebp
80103823:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103826:	e8 39 ff ff ff       	call   80103764 <mpsearch>
8010382b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010382e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103832:	74 0a                	je     8010383e <mpconfig+0x1e>
80103834:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103837:	8b 40 04             	mov    0x4(%eax),%eax
8010383a:	85 c0                	test   %eax,%eax
8010383c:	75 0a                	jne    80103848 <mpconfig+0x28>
    return 0;
8010383e:	b8 00 00 00 00       	mov    $0x0,%eax
80103843:	e9 81 00 00 00       	jmp    801038c9 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103848:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010384b:	8b 40 04             	mov    0x4(%eax),%eax
8010384e:	83 ec 0c             	sub    $0xc,%esp
80103851:	50                   	push   %eax
80103852:	e8 02 fe ff ff       	call   80103659 <p2v>
80103857:	83 c4 10             	add    $0x10,%esp
8010385a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
8010385d:	83 ec 04             	sub    $0x4,%esp
80103860:	6a 04                	push   $0x4
80103862:	68 a5 83 10 80       	push   $0x801083a5
80103867:	ff 75 f0             	pushl  -0x10(%ebp)
8010386a:	e8 da 16 00 00       	call   80104f49 <memcmp>
8010386f:	83 c4 10             	add    $0x10,%esp
80103872:	85 c0                	test   %eax,%eax
80103874:	74 07                	je     8010387d <mpconfig+0x5d>
    return 0;
80103876:	b8 00 00 00 00       	mov    $0x0,%eax
8010387b:	eb 4c                	jmp    801038c9 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
8010387d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103880:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103884:	3c 01                	cmp    $0x1,%al
80103886:	74 12                	je     8010389a <mpconfig+0x7a>
80103888:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010388b:	0f b6 40 06          	movzbl 0x6(%eax),%eax
8010388f:	3c 04                	cmp    $0x4,%al
80103891:	74 07                	je     8010389a <mpconfig+0x7a>
    return 0;
80103893:	b8 00 00 00 00       	mov    $0x0,%eax
80103898:	eb 2f                	jmp    801038c9 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
8010389a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010389d:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801038a1:	0f b7 c0             	movzwl %ax,%eax
801038a4:	83 ec 08             	sub    $0x8,%esp
801038a7:	50                   	push   %eax
801038a8:	ff 75 f0             	pushl  -0x10(%ebp)
801038ab:	e8 10 fe ff ff       	call   801036c0 <sum>
801038b0:	83 c4 10             	add    $0x10,%esp
801038b3:	84 c0                	test   %al,%al
801038b5:	74 07                	je     801038be <mpconfig+0x9e>
    return 0;
801038b7:	b8 00 00 00 00       	mov    $0x0,%eax
801038bc:	eb 0b                	jmp    801038c9 <mpconfig+0xa9>
  *pmp = mp;
801038be:	8b 45 08             	mov    0x8(%ebp),%eax
801038c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801038c4:	89 10                	mov    %edx,(%eax)
  return conf;
801038c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801038c9:	c9                   	leave  
801038ca:	c3                   	ret    

801038cb <mpinit>:

void
mpinit(void)
{
801038cb:	55                   	push   %ebp
801038cc:	89 e5                	mov    %esp,%ebp
801038ce:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
801038d1:	c7 05 44 b6 10 80 20 	movl   $0x8010f920,0x8010b644
801038d8:	f9 10 80 
  if((conf = mpconfig(&mp)) == 0)
801038db:	83 ec 0c             	sub    $0xc,%esp
801038de:	8d 45 e0             	lea    -0x20(%ebp),%eax
801038e1:	50                   	push   %eax
801038e2:	e8 39 ff ff ff       	call   80103820 <mpconfig>
801038e7:	83 c4 10             	add    $0x10,%esp
801038ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
801038ed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801038f1:	0f 84 96 01 00 00    	je     80103a8d <mpinit+0x1c2>
    return;
  ismp = 1;
801038f7:	c7 05 04 f9 10 80 01 	movl   $0x1,0x8010f904
801038fe:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103901:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103904:	8b 40 24             	mov    0x24(%eax),%eax
80103907:	a3 7c f8 10 80       	mov    %eax,0x8010f87c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010390c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010390f:	83 c0 2c             	add    $0x2c,%eax
80103912:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103915:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103918:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010391c:	0f b7 d0             	movzwl %ax,%edx
8010391f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103922:	01 d0                	add    %edx,%eax
80103924:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103927:	e9 f2 00 00 00       	jmp    80103a1e <mpinit+0x153>
    switch(*p){
8010392c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010392f:	0f b6 00             	movzbl (%eax),%eax
80103932:	0f b6 c0             	movzbl %al,%eax
80103935:	83 f8 04             	cmp    $0x4,%eax
80103938:	0f 87 bc 00 00 00    	ja     801039fa <mpinit+0x12f>
8010393e:	8b 04 85 e8 83 10 80 	mov    -0x7fef7c18(,%eax,4),%eax
80103945:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103947:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010394a:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
8010394d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103950:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103954:	0f b6 d0             	movzbl %al,%edx
80103957:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
8010395c:	39 c2                	cmp    %eax,%edx
8010395e:	74 2b                	je     8010398b <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103960:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103963:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103967:	0f b6 d0             	movzbl %al,%edx
8010396a:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
8010396f:	83 ec 04             	sub    $0x4,%esp
80103972:	52                   	push   %edx
80103973:	50                   	push   %eax
80103974:	68 aa 83 10 80       	push   $0x801083aa
80103979:	e8 48 ca ff ff       	call   801003c6 <cprintf>
8010397e:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103981:	c7 05 04 f9 10 80 00 	movl   $0x0,0x8010f904
80103988:	00 00 00 
      }
      if(proc->flags & MPBOOT)
8010398b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010398e:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103992:	0f b6 c0             	movzbl %al,%eax
80103995:	83 e0 02             	and    $0x2,%eax
80103998:	85 c0                	test   %eax,%eax
8010399a:	74 15                	je     801039b1 <mpinit+0xe6>
        bcpu = &cpus[ncpu];
8010399c:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
801039a1:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801039a7:	05 20 f9 10 80       	add    $0x8010f920,%eax
801039ac:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
801039b1:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
801039b6:	8b 15 00 ff 10 80    	mov    0x8010ff00,%edx
801039bc:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801039c2:	05 20 f9 10 80       	add    $0x8010f920,%eax
801039c7:	88 10                	mov    %dl,(%eax)
      ncpu++;
801039c9:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
801039ce:	83 c0 01             	add    $0x1,%eax
801039d1:	a3 00 ff 10 80       	mov    %eax,0x8010ff00
      p += sizeof(struct mpproc);
801039d6:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
801039da:	eb 42                	jmp    80103a1e <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
801039dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
801039e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801039e5:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801039e9:	a2 00 f9 10 80       	mov    %al,0x8010f900
      p += sizeof(struct mpioapic);
801039ee:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
801039f2:	eb 2a                	jmp    80103a1e <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
801039f4:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
801039f8:	eb 24                	jmp    80103a1e <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
801039fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039fd:	0f b6 00             	movzbl (%eax),%eax
80103a00:	0f b6 c0             	movzbl %al,%eax
80103a03:	83 ec 08             	sub    $0x8,%esp
80103a06:	50                   	push   %eax
80103a07:	68 c8 83 10 80       	push   $0x801083c8
80103a0c:	e8 b5 c9 ff ff       	call   801003c6 <cprintf>
80103a11:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103a14:	c7 05 04 f9 10 80 00 	movl   $0x0,0x8010f904
80103a1b:	00 00 00 
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a21:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103a24:	0f 82 02 ff ff ff    	jb     8010392c <mpinit+0x61>
    }
  }
  if(!ismp){
80103a2a:	a1 04 f9 10 80       	mov    0x8010f904,%eax
80103a2f:	85 c0                	test   %eax,%eax
80103a31:	75 1d                	jne    80103a50 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103a33:	c7 05 00 ff 10 80 01 	movl   $0x1,0x8010ff00
80103a3a:	00 00 00 
    lapic = 0;
80103a3d:	c7 05 7c f8 10 80 00 	movl   $0x0,0x8010f87c
80103a44:	00 00 00 
    ioapicid = 0;
80103a47:	c6 05 00 f9 10 80 00 	movb   $0x0,0x8010f900
    return;
80103a4e:	eb 3e                	jmp    80103a8e <mpinit+0x1c3>
  }

  if(mp->imcrp){
80103a50:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103a53:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103a57:	84 c0                	test   %al,%al
80103a59:	74 33                	je     80103a8e <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103a5b:	83 ec 08             	sub    $0x8,%esp
80103a5e:	6a 70                	push   $0x70
80103a60:	6a 22                	push   $0x22
80103a62:	e8 1c fc ff ff       	call   80103683 <outb>
80103a67:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103a6a:	83 ec 0c             	sub    $0xc,%esp
80103a6d:	6a 23                	push   $0x23
80103a6f:	e8 f2 fb ff ff       	call   80103666 <inb>
80103a74:	83 c4 10             	add    $0x10,%esp
80103a77:	83 c8 01             	or     $0x1,%eax
80103a7a:	0f b6 c0             	movzbl %al,%eax
80103a7d:	83 ec 08             	sub    $0x8,%esp
80103a80:	50                   	push   %eax
80103a81:	6a 23                	push   $0x23
80103a83:	e8 fb fb ff ff       	call   80103683 <outb>
80103a88:	83 c4 10             	add    $0x10,%esp
80103a8b:	eb 01                	jmp    80103a8e <mpinit+0x1c3>
    return;
80103a8d:	90                   	nop
  }
}
80103a8e:	c9                   	leave  
80103a8f:	c3                   	ret    

80103a90 <outb>:
{
80103a90:	55                   	push   %ebp
80103a91:	89 e5                	mov    %esp,%ebp
80103a93:	83 ec 08             	sub    $0x8,%esp
80103a96:	8b 55 08             	mov    0x8(%ebp),%edx
80103a99:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a9c:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103aa0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103aa3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103aa7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103aab:	ee                   	out    %al,(%dx)
}
80103aac:	90                   	nop
80103aad:	c9                   	leave  
80103aae:	c3                   	ret    

80103aaf <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103aaf:	55                   	push   %ebp
80103ab0:	89 e5                	mov    %esp,%ebp
80103ab2:	83 ec 04             	sub    $0x4,%esp
80103ab5:	8b 45 08             	mov    0x8(%ebp),%eax
80103ab8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103abc:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103ac0:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103ac6:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103aca:	0f b6 c0             	movzbl %al,%eax
80103acd:	50                   	push   %eax
80103ace:	6a 21                	push   $0x21
80103ad0:	e8 bb ff ff ff       	call   80103a90 <outb>
80103ad5:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80103ad8:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103adc:	66 c1 e8 08          	shr    $0x8,%ax
80103ae0:	0f b6 c0             	movzbl %al,%eax
80103ae3:	50                   	push   %eax
80103ae4:	68 a1 00 00 00       	push   $0xa1
80103ae9:	e8 a2 ff ff ff       	call   80103a90 <outb>
80103aee:	83 c4 08             	add    $0x8,%esp
}
80103af1:	90                   	nop
80103af2:	c9                   	leave  
80103af3:	c3                   	ret    

80103af4 <picenable>:

void
picenable(int irq)
{
80103af4:	55                   	push   %ebp
80103af5:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80103af7:	8b 45 08             	mov    0x8(%ebp),%eax
80103afa:	ba 01 00 00 00       	mov    $0x1,%edx
80103aff:	89 c1                	mov    %eax,%ecx
80103b01:	d3 e2                	shl    %cl,%edx
80103b03:	89 d0                	mov    %edx,%eax
80103b05:	f7 d0                	not    %eax
80103b07:	89 c2                	mov    %eax,%edx
80103b09:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103b10:	21 d0                	and    %edx,%eax
80103b12:	0f b7 c0             	movzwl %ax,%eax
80103b15:	50                   	push   %eax
80103b16:	e8 94 ff ff ff       	call   80103aaf <picsetmask>
80103b1b:	83 c4 04             	add    $0x4,%esp
}
80103b1e:	90                   	nop
80103b1f:	c9                   	leave  
80103b20:	c3                   	ret    

80103b21 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103b21:	55                   	push   %ebp
80103b22:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103b24:	68 ff 00 00 00       	push   $0xff
80103b29:	6a 21                	push   $0x21
80103b2b:	e8 60 ff ff ff       	call   80103a90 <outb>
80103b30:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103b33:	68 ff 00 00 00       	push   $0xff
80103b38:	68 a1 00 00 00       	push   $0xa1
80103b3d:	e8 4e ff ff ff       	call   80103a90 <outb>
80103b42:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103b45:	6a 11                	push   $0x11
80103b47:	6a 20                	push   $0x20
80103b49:	e8 42 ff ff ff       	call   80103a90 <outb>
80103b4e:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103b51:	6a 20                	push   $0x20
80103b53:	6a 21                	push   $0x21
80103b55:	e8 36 ff ff ff       	call   80103a90 <outb>
80103b5a:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103b5d:	6a 04                	push   $0x4
80103b5f:	6a 21                	push   $0x21
80103b61:	e8 2a ff ff ff       	call   80103a90 <outb>
80103b66:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103b69:	6a 03                	push   $0x3
80103b6b:	6a 21                	push   $0x21
80103b6d:	e8 1e ff ff ff       	call   80103a90 <outb>
80103b72:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103b75:	6a 11                	push   $0x11
80103b77:	68 a0 00 00 00       	push   $0xa0
80103b7c:	e8 0f ff ff ff       	call   80103a90 <outb>
80103b81:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103b84:	6a 28                	push   $0x28
80103b86:	68 a1 00 00 00       	push   $0xa1
80103b8b:	e8 00 ff ff ff       	call   80103a90 <outb>
80103b90:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103b93:	6a 02                	push   $0x2
80103b95:	68 a1 00 00 00       	push   $0xa1
80103b9a:	e8 f1 fe ff ff       	call   80103a90 <outb>
80103b9f:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103ba2:	6a 03                	push   $0x3
80103ba4:	68 a1 00 00 00       	push   $0xa1
80103ba9:	e8 e2 fe ff ff       	call   80103a90 <outb>
80103bae:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103bb1:	6a 68                	push   $0x68
80103bb3:	6a 20                	push   $0x20
80103bb5:	e8 d6 fe ff ff       	call   80103a90 <outb>
80103bba:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103bbd:	6a 0a                	push   $0xa
80103bbf:	6a 20                	push   $0x20
80103bc1:	e8 ca fe ff ff       	call   80103a90 <outb>
80103bc6:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80103bc9:	6a 68                	push   $0x68
80103bcb:	68 a0 00 00 00       	push   $0xa0
80103bd0:	e8 bb fe ff ff       	call   80103a90 <outb>
80103bd5:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80103bd8:	6a 0a                	push   $0xa
80103bda:	68 a0 00 00 00       	push   $0xa0
80103bdf:	e8 ac fe ff ff       	call   80103a90 <outb>
80103be4:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80103be7:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103bee:	66 83 f8 ff          	cmp    $0xffff,%ax
80103bf2:	74 13                	je     80103c07 <picinit+0xe6>
    picsetmask(irqmask);
80103bf4:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103bfb:	0f b7 c0             	movzwl %ax,%eax
80103bfe:	50                   	push   %eax
80103bff:	e8 ab fe ff ff       	call   80103aaf <picsetmask>
80103c04:	83 c4 04             	add    $0x4,%esp
}
80103c07:	90                   	nop
80103c08:	c9                   	leave  
80103c09:	c3                   	ret    

80103c0a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103c0a:	55                   	push   %ebp
80103c0b:	89 e5                	mov    %esp,%ebp
80103c0d:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103c10:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103c17:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c1a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103c20:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c23:	8b 10                	mov    (%eax),%edx
80103c25:	8b 45 08             	mov    0x8(%ebp),%eax
80103c28:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103c2a:	e8 35 d3 ff ff       	call   80100f64 <filealloc>
80103c2f:	89 c2                	mov    %eax,%edx
80103c31:	8b 45 08             	mov    0x8(%ebp),%eax
80103c34:	89 10                	mov    %edx,(%eax)
80103c36:	8b 45 08             	mov    0x8(%ebp),%eax
80103c39:	8b 00                	mov    (%eax),%eax
80103c3b:	85 c0                	test   %eax,%eax
80103c3d:	0f 84 cb 00 00 00    	je     80103d0e <pipealloc+0x104>
80103c43:	e8 1c d3 ff ff       	call   80100f64 <filealloc>
80103c48:	89 c2                	mov    %eax,%edx
80103c4a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c4d:	89 10                	mov    %edx,(%eax)
80103c4f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c52:	8b 00                	mov    (%eax),%eax
80103c54:	85 c0                	test   %eax,%eax
80103c56:	0f 84 b2 00 00 00    	je     80103d0e <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103c5c:	e8 50 ef ff ff       	call   80102bb1 <kalloc>
80103c61:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c64:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c68:	0f 84 9f 00 00 00    	je     80103d0d <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
80103c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c71:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103c78:	00 00 00 
  p->writeopen = 1;
80103c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7e:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103c85:	00 00 00 
  p->nwrite = 0;
80103c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c8b:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103c92:	00 00 00 
  p->nread = 0;
80103c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c98:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103c9f:	00 00 00 
  initlock(&p->lock, "pipe");
80103ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca5:	83 ec 08             	sub    $0x8,%esp
80103ca8:	68 fc 83 10 80       	push   $0x801083fc
80103cad:	50                   	push   %eax
80103cae:	e8 aa 0f 00 00       	call   80104c5d <initlock>
80103cb3:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103cb6:	8b 45 08             	mov    0x8(%ebp),%eax
80103cb9:	8b 00                	mov    (%eax),%eax
80103cbb:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103cc1:	8b 45 08             	mov    0x8(%ebp),%eax
80103cc4:	8b 00                	mov    (%eax),%eax
80103cc6:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103cca:	8b 45 08             	mov    0x8(%ebp),%eax
80103ccd:	8b 00                	mov    (%eax),%eax
80103ccf:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103cd3:	8b 45 08             	mov    0x8(%ebp),%eax
80103cd6:	8b 00                	mov    (%eax),%eax
80103cd8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cdb:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103cde:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ce1:	8b 00                	mov    (%eax),%eax
80103ce3:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103ce9:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cec:	8b 00                	mov    (%eax),%eax
80103cee:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103cf2:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cf5:	8b 00                	mov    (%eax),%eax
80103cf7:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103cfb:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cfe:	8b 00                	mov    (%eax),%eax
80103d00:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d03:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103d06:	b8 00 00 00 00       	mov    $0x0,%eax
80103d0b:	eb 4e                	jmp    80103d5b <pipealloc+0x151>
    goto bad;
80103d0d:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103d0e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d12:	74 0e                	je     80103d22 <pipealloc+0x118>
    kfree((char*)p);
80103d14:	83 ec 0c             	sub    $0xc,%esp
80103d17:	ff 75 f4             	pushl  -0xc(%ebp)
80103d1a:	e8 f5 ed ff ff       	call   80102b14 <kfree>
80103d1f:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103d22:	8b 45 08             	mov    0x8(%ebp),%eax
80103d25:	8b 00                	mov    (%eax),%eax
80103d27:	85 c0                	test   %eax,%eax
80103d29:	74 11                	je     80103d3c <pipealloc+0x132>
    fileclose(*f0);
80103d2b:	8b 45 08             	mov    0x8(%ebp),%eax
80103d2e:	8b 00                	mov    (%eax),%eax
80103d30:	83 ec 0c             	sub    $0xc,%esp
80103d33:	50                   	push   %eax
80103d34:	e8 e9 d2 ff ff       	call   80101022 <fileclose>
80103d39:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103d3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d3f:	8b 00                	mov    (%eax),%eax
80103d41:	85 c0                	test   %eax,%eax
80103d43:	74 11                	je     80103d56 <pipealloc+0x14c>
    fileclose(*f1);
80103d45:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d48:	8b 00                	mov    (%eax),%eax
80103d4a:	83 ec 0c             	sub    $0xc,%esp
80103d4d:	50                   	push   %eax
80103d4e:	e8 cf d2 ff ff       	call   80101022 <fileclose>
80103d53:	83 c4 10             	add    $0x10,%esp
  return -1;
80103d56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103d5b:	c9                   	leave  
80103d5c:	c3                   	ret    

80103d5d <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103d5d:	55                   	push   %ebp
80103d5e:	89 e5                	mov    %esp,%ebp
80103d60:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103d63:	8b 45 08             	mov    0x8(%ebp),%eax
80103d66:	83 ec 0c             	sub    $0xc,%esp
80103d69:	50                   	push   %eax
80103d6a:	e8 10 0f 00 00       	call   80104c7f <acquire>
80103d6f:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103d72:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103d76:	74 23                	je     80103d9b <pipeclose+0x3e>
    p->writeopen = 0;
80103d78:	8b 45 08             	mov    0x8(%ebp),%eax
80103d7b:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103d82:	00 00 00 
    wakeup(&p->nread);
80103d85:	8b 45 08             	mov    0x8(%ebp),%eax
80103d88:	05 34 02 00 00       	add    $0x234,%eax
80103d8d:	83 ec 0c             	sub    $0xc,%esp
80103d90:	50                   	push   %eax
80103d91:	e8 db 0c 00 00       	call   80104a71 <wakeup>
80103d96:	83 c4 10             	add    $0x10,%esp
80103d99:	eb 21                	jmp    80103dbc <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80103d9b:	8b 45 08             	mov    0x8(%ebp),%eax
80103d9e:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103da5:	00 00 00 
    wakeup(&p->nwrite);
80103da8:	8b 45 08             	mov    0x8(%ebp),%eax
80103dab:	05 38 02 00 00       	add    $0x238,%eax
80103db0:	83 ec 0c             	sub    $0xc,%esp
80103db3:	50                   	push   %eax
80103db4:	e8 b8 0c 00 00       	call   80104a71 <wakeup>
80103db9:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103dbc:	8b 45 08             	mov    0x8(%ebp),%eax
80103dbf:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103dc5:	85 c0                	test   %eax,%eax
80103dc7:	75 2c                	jne    80103df5 <pipeclose+0x98>
80103dc9:	8b 45 08             	mov    0x8(%ebp),%eax
80103dcc:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103dd2:	85 c0                	test   %eax,%eax
80103dd4:	75 1f                	jne    80103df5 <pipeclose+0x98>
    release(&p->lock);
80103dd6:	8b 45 08             	mov    0x8(%ebp),%eax
80103dd9:	83 ec 0c             	sub    $0xc,%esp
80103ddc:	50                   	push   %eax
80103ddd:	e8 04 0f 00 00       	call   80104ce6 <release>
80103de2:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103de5:	83 ec 0c             	sub    $0xc,%esp
80103de8:	ff 75 08             	pushl  0x8(%ebp)
80103deb:	e8 24 ed ff ff       	call   80102b14 <kfree>
80103df0:	83 c4 10             	add    $0x10,%esp
80103df3:	eb 0f                	jmp    80103e04 <pipeclose+0xa7>
  } else
    release(&p->lock);
80103df5:	8b 45 08             	mov    0x8(%ebp),%eax
80103df8:	83 ec 0c             	sub    $0xc,%esp
80103dfb:	50                   	push   %eax
80103dfc:	e8 e5 0e 00 00       	call   80104ce6 <release>
80103e01:	83 c4 10             	add    $0x10,%esp
}
80103e04:	90                   	nop
80103e05:	c9                   	leave  
80103e06:	c3                   	ret    

80103e07 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103e07:	55                   	push   %ebp
80103e08:	89 e5                	mov    %esp,%ebp
80103e0a:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103e0d:	8b 45 08             	mov    0x8(%ebp),%eax
80103e10:	83 ec 0c             	sub    $0xc,%esp
80103e13:	50                   	push   %eax
80103e14:	e8 66 0e 00 00       	call   80104c7f <acquire>
80103e19:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103e1c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103e23:	e9 ad 00 00 00       	jmp    80103ed5 <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80103e28:	8b 45 08             	mov    0x8(%ebp),%eax
80103e2b:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103e31:	85 c0                	test   %eax,%eax
80103e33:	74 0d                	je     80103e42 <pipewrite+0x3b>
80103e35:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103e3b:	8b 40 24             	mov    0x24(%eax),%eax
80103e3e:	85 c0                	test   %eax,%eax
80103e40:	74 19                	je     80103e5b <pipewrite+0x54>
        release(&p->lock);
80103e42:	8b 45 08             	mov    0x8(%ebp),%eax
80103e45:	83 ec 0c             	sub    $0xc,%esp
80103e48:	50                   	push   %eax
80103e49:	e8 98 0e 00 00       	call   80104ce6 <release>
80103e4e:	83 c4 10             	add    $0x10,%esp
        return -1;
80103e51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e56:	e9 a8 00 00 00       	jmp    80103f03 <pipewrite+0xfc>
      }
      wakeup(&p->nread);
80103e5b:	8b 45 08             	mov    0x8(%ebp),%eax
80103e5e:	05 34 02 00 00       	add    $0x234,%eax
80103e63:	83 ec 0c             	sub    $0xc,%esp
80103e66:	50                   	push   %eax
80103e67:	e8 05 0c 00 00       	call   80104a71 <wakeup>
80103e6c:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103e6f:	8b 45 08             	mov    0x8(%ebp),%eax
80103e72:	8b 55 08             	mov    0x8(%ebp),%edx
80103e75:	81 c2 38 02 00 00    	add    $0x238,%edx
80103e7b:	83 ec 08             	sub    $0x8,%esp
80103e7e:	50                   	push   %eax
80103e7f:	52                   	push   %edx
80103e80:	e8 01 0b 00 00       	call   80104986 <sleep>
80103e85:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103e88:	8b 45 08             	mov    0x8(%ebp),%eax
80103e8b:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103e91:	8b 45 08             	mov    0x8(%ebp),%eax
80103e94:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103e9a:	05 00 02 00 00       	add    $0x200,%eax
80103e9f:	39 c2                	cmp    %eax,%edx
80103ea1:	74 85                	je     80103e28 <pipewrite+0x21>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103ea3:	8b 45 08             	mov    0x8(%ebp),%eax
80103ea6:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103eac:	8d 48 01             	lea    0x1(%eax),%ecx
80103eaf:	8b 55 08             	mov    0x8(%ebp),%edx
80103eb2:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103eb8:	25 ff 01 00 00       	and    $0x1ff,%eax
80103ebd:	89 c1                	mov    %eax,%ecx
80103ebf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ec2:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ec5:	01 d0                	add    %edx,%eax
80103ec7:	0f b6 10             	movzbl (%eax),%edx
80103eca:	8b 45 08             	mov    0x8(%ebp),%eax
80103ecd:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103ed1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103ed5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ed8:	3b 45 10             	cmp    0x10(%ebp),%eax
80103edb:	7c ab                	jl     80103e88 <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103edd:	8b 45 08             	mov    0x8(%ebp),%eax
80103ee0:	05 34 02 00 00       	add    $0x234,%eax
80103ee5:	83 ec 0c             	sub    $0xc,%esp
80103ee8:	50                   	push   %eax
80103ee9:	e8 83 0b 00 00       	call   80104a71 <wakeup>
80103eee:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103ef1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ef4:	83 ec 0c             	sub    $0xc,%esp
80103ef7:	50                   	push   %eax
80103ef8:	e8 e9 0d 00 00       	call   80104ce6 <release>
80103efd:	83 c4 10             	add    $0x10,%esp
  return n;
80103f00:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103f03:	c9                   	leave  
80103f04:	c3                   	ret    

80103f05 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103f05:	55                   	push   %ebp
80103f06:	89 e5                	mov    %esp,%ebp
80103f08:	53                   	push   %ebx
80103f09:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103f0c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f0f:	83 ec 0c             	sub    $0xc,%esp
80103f12:	50                   	push   %eax
80103f13:	e8 67 0d 00 00       	call   80104c7f <acquire>
80103f18:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103f1b:	eb 3f                	jmp    80103f5c <piperead+0x57>
    if(proc->killed){
80103f1d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103f23:	8b 40 24             	mov    0x24(%eax),%eax
80103f26:	85 c0                	test   %eax,%eax
80103f28:	74 19                	je     80103f43 <piperead+0x3e>
      release(&p->lock);
80103f2a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f2d:	83 ec 0c             	sub    $0xc,%esp
80103f30:	50                   	push   %eax
80103f31:	e8 b0 0d 00 00       	call   80104ce6 <release>
80103f36:	83 c4 10             	add    $0x10,%esp
      return -1;
80103f39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f3e:	e9 bf 00 00 00       	jmp    80104002 <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103f43:	8b 45 08             	mov    0x8(%ebp),%eax
80103f46:	8b 55 08             	mov    0x8(%ebp),%edx
80103f49:	81 c2 34 02 00 00    	add    $0x234,%edx
80103f4f:	83 ec 08             	sub    $0x8,%esp
80103f52:	50                   	push   %eax
80103f53:	52                   	push   %edx
80103f54:	e8 2d 0a 00 00       	call   80104986 <sleep>
80103f59:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103f5c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f5f:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103f65:	8b 45 08             	mov    0x8(%ebp),%eax
80103f68:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103f6e:	39 c2                	cmp    %eax,%edx
80103f70:	75 0d                	jne    80103f7f <piperead+0x7a>
80103f72:	8b 45 08             	mov    0x8(%ebp),%eax
80103f75:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103f7b:	85 c0                	test   %eax,%eax
80103f7d:	75 9e                	jne    80103f1d <piperead+0x18>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103f7f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103f86:	eb 49                	jmp    80103fd1 <piperead+0xcc>
    if(p->nread == p->nwrite)
80103f88:	8b 45 08             	mov    0x8(%ebp),%eax
80103f8b:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103f91:	8b 45 08             	mov    0x8(%ebp),%eax
80103f94:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103f9a:	39 c2                	cmp    %eax,%edx
80103f9c:	74 3d                	je     80103fdb <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103f9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fa1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fa4:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80103fa7:	8b 45 08             	mov    0x8(%ebp),%eax
80103faa:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103fb0:	8d 48 01             	lea    0x1(%eax),%ecx
80103fb3:	8b 55 08             	mov    0x8(%ebp),%edx
80103fb6:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103fbc:	25 ff 01 00 00       	and    $0x1ff,%eax
80103fc1:	89 c2                	mov    %eax,%edx
80103fc3:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc6:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80103fcb:	88 03                	mov    %al,(%ebx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103fcd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103fd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fd4:	3b 45 10             	cmp    0x10(%ebp),%eax
80103fd7:	7c af                	jl     80103f88 <piperead+0x83>
80103fd9:	eb 01                	jmp    80103fdc <piperead+0xd7>
      break;
80103fdb:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103fdc:	8b 45 08             	mov    0x8(%ebp),%eax
80103fdf:	05 38 02 00 00       	add    $0x238,%eax
80103fe4:	83 ec 0c             	sub    $0xc,%esp
80103fe7:	50                   	push   %eax
80103fe8:	e8 84 0a 00 00       	call   80104a71 <wakeup>
80103fed:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103ff0:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff3:	83 ec 0c             	sub    $0xc,%esp
80103ff6:	50                   	push   %eax
80103ff7:	e8 ea 0c 00 00       	call   80104ce6 <release>
80103ffc:	83 c4 10             	add    $0x10,%esp
  return i;
80103fff:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104002:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104005:	c9                   	leave  
80104006:	c3                   	ret    

80104007 <readeflags>:
{
80104007:	55                   	push   %ebp
80104008:	89 e5                	mov    %esp,%ebp
8010400a:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010400d:	9c                   	pushf  
8010400e:	58                   	pop    %eax
8010400f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104012:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104015:	c9                   	leave  
80104016:	c3                   	ret    

80104017 <sti>:
{
80104017:	55                   	push   %ebp
80104018:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010401a:	fb                   	sti    
}
8010401b:	90                   	nop
8010401c:	5d                   	pop    %ebp
8010401d:	c3                   	ret    

8010401e <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010401e:	55                   	push   %ebp
8010401f:	89 e5                	mov    %esp,%ebp
80104021:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104024:	83 ec 08             	sub    $0x8,%esp
80104027:	68 04 84 10 80       	push   $0x80108404
8010402c:	68 20 ff 10 80       	push   $0x8010ff20
80104031:	e8 27 0c 00 00       	call   80104c5d <initlock>
80104036:	83 c4 10             	add    $0x10,%esp
}
80104039:	90                   	nop
8010403a:	c9                   	leave  
8010403b:	c3                   	ret    

8010403c <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010403c:	55                   	push   %ebp
8010403d:	89 e5                	mov    %esp,%ebp
8010403f:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;
   
 acquire(&ptable.lock);
80104042:	83 ec 0c             	sub    $0xc,%esp
80104045:	68 20 ff 10 80       	push   $0x8010ff20
8010404a:	e8 30 0c 00 00       	call   80104c7f <acquire>
8010404f:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104052:	c7 45 f4 54 ff 10 80 	movl   $0x8010ff54,-0xc(%ebp)
80104059:	eb 0e                	jmp    80104069 <allocproc+0x2d>
    if(p->state == UNUSED)
8010405b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010405e:	8b 40 0c             	mov    0xc(%eax),%eax
80104061:	85 c0                	test   %eax,%eax
80104063:	74 27                	je     8010408c <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104065:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104069:	81 7d f4 54 1f 11 80 	cmpl   $0x80111f54,-0xc(%ebp)
80104070:	72 e9                	jb     8010405b <allocproc+0x1f>
      goto found;
  release(&ptable.lock);
80104072:	83 ec 0c             	sub    $0xc,%esp
80104075:	68 20 ff 10 80       	push   $0x8010ff20
8010407a:	e8 67 0c 00 00       	call   80104ce6 <release>
8010407f:	83 c4 10             	add    $0x10,%esp
  return 0;
80104082:	b8 00 00 00 00       	mov    $0x0,%eax
80104087:	e9 10 01 00 00       	jmp    8010419c <allocproc+0x160>
      goto found;
8010408c:	90                   	nop

found:
  p->state = EMBRYO;
8010408d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104090:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104097:	a1 04 b0 10 80       	mov    0x8010b004,%eax
8010409c:	8d 50 01             	lea    0x1(%eax),%edx
8010409f:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
801040a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040a8:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
801040ab:	83 ec 0c             	sub    $0xc,%esp
801040ae:	68 20 ff 10 80       	push   $0x8010ff20
801040b3:	e8 2e 0c 00 00       	call   80104ce6 <release>
801040b8:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801040bb:	e8 f1 ea ff ff       	call   80102bb1 <kalloc>
801040c0:	89 c2                	mov    %eax,%edx
801040c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c5:	89 50 08             	mov    %edx,0x8(%eax)
801040c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040cb:	8b 40 08             	mov    0x8(%eax),%eax
801040ce:	85 c0                	test   %eax,%eax
801040d0:	75 14                	jne    801040e6 <allocproc+0xaa>
    p->state = UNUSED;
801040d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801040dc:	b8 00 00 00 00       	mov    $0x0,%eax
801040e1:	e9 b6 00 00 00       	jmp    8010419c <allocproc+0x160>
  }
  sp = p->kstack + KSTACKSIZE;
801040e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e9:	8b 40 08             	mov    0x8(%eax),%eax
801040ec:	05 00 10 00 00       	add    $0x1000,%eax
801040f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801040f4:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801040f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801040fe:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104101:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104105:	ba 8a 62 10 80       	mov    $0x8010628a,%edx
8010410a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010410d:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010410f:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104116:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104119:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010411c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010411f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104122:	83 ec 04             	sub    $0x4,%esp
80104125:	6a 14                	push   $0x14
80104127:	6a 00                	push   $0x0
80104129:	50                   	push   %eax
8010412a:	e8 b3 0d 00 00       	call   80104ee2 <memset>
8010412f:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104135:	8b 40 1c             	mov    0x1c(%eax),%eax
80104138:	ba 55 49 10 80       	mov    $0x80104955,%edx
8010413d:	89 50 10             	mov    %edx,0x10(%eax)

//my addtion start
  acquire(&tickslock);
80104140:	83 ec 0c             	sub    $0xc,%esp
80104143:	68 60 1f 11 80       	push   $0x80111f60
80104148:	e8 32 0b 00 00       	call   80104c7f <acquire>
8010414d:	83 c4 10             	add    $0x10,%esp
  p->start_tick = ticks;
80104150:	8b 15 a0 27 11 80    	mov    0x801127a0,%edx
80104156:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104159:	89 50 7c             	mov    %edx,0x7c(%eax)
  release(&tickslock);
8010415c:	83 ec 0c             	sub    $0xc,%esp
8010415f:	68 60 1f 11 80       	push   $0x80111f60
80104164:	e8 7d 0b 00 00       	call   80104ce6 <release>
80104169:	83 c4 10             	add    $0x10,%esp
  cprintf("------------process start----------------\n pid = %d,  name = %s,   start time = %d\n ",p->pid,p->name,p->start_tick*10);
8010416c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010416f:	8b 50 7c             	mov    0x7c(%eax),%edx
80104172:	89 d0                	mov    %edx,%eax
80104174:	c1 e0 02             	shl    $0x2,%eax
80104177:	01 d0                	add    %edx,%eax
80104179:	01 c0                	add    %eax,%eax
8010417b:	89 c1                	mov    %eax,%ecx
8010417d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104180:	8d 50 6c             	lea    0x6c(%eax),%edx
80104183:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104186:	8b 40 10             	mov    0x10(%eax),%eax
80104189:	51                   	push   %ecx
8010418a:	52                   	push   %edx
8010418b:	50                   	push   %eax
8010418c:	68 0c 84 10 80       	push   $0x8010840c
80104191:	e8 30 c2 ff ff       	call   801003c6 <cprintf>
80104196:	83 c4 10             	add    $0x10,%esp
//my addition end
  return p;
80104199:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010419c:	c9                   	leave  
8010419d:	c3                   	ret    

8010419e <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010419e:	55                   	push   %ebp
8010419f:	89 e5                	mov    %esp,%ebp
801041a1:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
801041a4:	e8 93 fe ff ff       	call   8010403c <allocproc>
801041a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801041ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041af:	a3 48 b6 10 80       	mov    %eax,0x8010b648
  if((p->pgdir = setupkvm()) == 0)
801041b4:	e8 6a 37 00 00       	call   80107923 <setupkvm>
801041b9:	89 c2                	mov    %eax,%edx
801041bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041be:	89 50 04             	mov    %edx,0x4(%eax)
801041c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041c4:	8b 40 04             	mov    0x4(%eax),%eax
801041c7:	85 c0                	test   %eax,%eax
801041c9:	75 0d                	jne    801041d8 <userinit+0x3a>
    panic("userinit: out of memory?");
801041cb:	83 ec 0c             	sub    $0xc,%esp
801041ce:	68 61 84 10 80       	push   $0x80108461
801041d3:	e8 8e c3 ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801041d8:	ba 2c 00 00 00       	mov    $0x2c,%edx
801041dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041e0:	8b 40 04             	mov    0x4(%eax),%eax
801041e3:	83 ec 04             	sub    $0x4,%esp
801041e6:	52                   	push   %edx
801041e7:	68 e0 b4 10 80       	push   $0x8010b4e0
801041ec:	50                   	push   %eax
801041ed:	e8 8b 39 00 00       	call   80107b7d <inituvm>
801041f2:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
801041f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041f8:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801041fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104201:	8b 40 18             	mov    0x18(%eax),%eax
80104204:	83 ec 04             	sub    $0x4,%esp
80104207:	6a 4c                	push   $0x4c
80104209:	6a 00                	push   $0x0
8010420b:	50                   	push   %eax
8010420c:	e8 d1 0c 00 00       	call   80104ee2 <memset>
80104211:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104214:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104217:	8b 40 18             	mov    0x18(%eax),%eax
8010421a:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104220:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104223:	8b 40 18             	mov    0x18(%eax),%eax
80104226:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010422c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010422f:	8b 40 18             	mov    0x18(%eax),%eax
80104232:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104235:	8b 52 18             	mov    0x18(%edx),%edx
80104238:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010423c:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104240:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104243:	8b 40 18             	mov    0x18(%eax),%eax
80104246:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104249:	8b 52 18             	mov    0x18(%edx),%edx
8010424c:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104250:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104254:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104257:	8b 40 18             	mov    0x18(%eax),%eax
8010425a:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104261:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104264:	8b 40 18             	mov    0x18(%eax),%eax
80104267:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010426e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104271:	8b 40 18             	mov    0x18(%eax),%eax
80104274:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010427b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010427e:	83 c0 6c             	add    $0x6c,%eax
80104281:	83 ec 04             	sub    $0x4,%esp
80104284:	6a 10                	push   $0x10
80104286:	68 7a 84 10 80       	push   $0x8010847a
8010428b:	50                   	push   %eax
8010428c:	e8 54 0e 00 00       	call   801050e5 <safestrcpy>
80104291:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104294:	83 ec 0c             	sub    $0xc,%esp
80104297:	68 83 84 10 80       	push   $0x80108483
8010429c:	e8 0e e2 ff ff       	call   801024af <namei>
801042a1:	83 c4 10             	add    $0x10,%esp
801042a4:	89 c2                	mov    %eax,%edx
801042a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042a9:	89 50 68             	mov    %edx,0x68(%eax)

  p->state = RUNNABLE;
801042ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042af:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801042b6:	90                   	nop
801042b7:	c9                   	leave  
801042b8:	c3                   	ret    

801042b9 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801042b9:	55                   	push   %ebp
801042ba:	89 e5                	mov    %esp,%ebp
801042bc:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
801042bf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042c5:	8b 00                	mov    (%eax),%eax
801042c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801042ca:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801042ce:	7e 31                	jle    80104301 <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801042d0:	8b 55 08             	mov    0x8(%ebp),%edx
801042d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042d6:	01 c2                	add    %eax,%edx
801042d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042de:	8b 40 04             	mov    0x4(%eax),%eax
801042e1:	83 ec 04             	sub    $0x4,%esp
801042e4:	52                   	push   %edx
801042e5:	ff 75 f4             	pushl  -0xc(%ebp)
801042e8:	50                   	push   %eax
801042e9:	e8 dc 39 00 00       	call   80107cca <allocuvm>
801042ee:	83 c4 10             	add    $0x10,%esp
801042f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801042f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801042f8:	75 3e                	jne    80104338 <growproc+0x7f>
      return -1;
801042fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042ff:	eb 59                	jmp    8010435a <growproc+0xa1>
  } else if(n < 0){
80104301:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104305:	79 31                	jns    80104338 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104307:	8b 55 08             	mov    0x8(%ebp),%edx
8010430a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010430d:	01 c2                	add    %eax,%edx
8010430f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104315:	8b 40 04             	mov    0x4(%eax),%eax
80104318:	83 ec 04             	sub    $0x4,%esp
8010431b:	52                   	push   %edx
8010431c:	ff 75 f4             	pushl  -0xc(%ebp)
8010431f:	50                   	push   %eax
80104320:	e8 6e 3a 00 00       	call   80107d93 <deallocuvm>
80104325:	83 c4 10             	add    $0x10,%esp
80104328:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010432b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010432f:	75 07                	jne    80104338 <growproc+0x7f>
      return -1;
80104331:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104336:	eb 22                	jmp    8010435a <growproc+0xa1>
  }
  proc->sz = sz;
80104338:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010433e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104341:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104343:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104349:	83 ec 0c             	sub    $0xc,%esp
8010434c:	50                   	push   %eax
8010434d:	e8 b8 36 00 00       	call   80107a0a <switchuvm>
80104352:	83 c4 10             	add    $0x10,%esp
  return 0;
80104355:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010435a:	c9                   	leave  
8010435b:	c3                   	ret    

8010435c <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010435c:	55                   	push   %ebp
8010435d:	89 e5                	mov    %esp,%ebp
8010435f:	57                   	push   %edi
80104360:	56                   	push   %esi
80104361:	53                   	push   %ebx
80104362:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104365:	e8 d2 fc ff ff       	call   8010403c <allocproc>
8010436a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010436d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104371:	75 0a                	jne    8010437d <fork+0x21>
    return -1;
80104373:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104378:	e9 48 01 00 00       	jmp    801044c5 <fork+0x169>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
8010437d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104383:	8b 10                	mov    (%eax),%edx
80104385:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010438b:	8b 40 04             	mov    0x4(%eax),%eax
8010438e:	83 ec 08             	sub    $0x8,%esp
80104391:	52                   	push   %edx
80104392:	50                   	push   %eax
80104393:	e8 99 3b 00 00       	call   80107f31 <copyuvm>
80104398:	83 c4 10             	add    $0x10,%esp
8010439b:	89 c2                	mov    %eax,%edx
8010439d:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043a0:	89 50 04             	mov    %edx,0x4(%eax)
801043a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043a6:	8b 40 04             	mov    0x4(%eax),%eax
801043a9:	85 c0                	test   %eax,%eax
801043ab:	75 30                	jne    801043dd <fork+0x81>
    kfree(np->kstack);
801043ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043b0:	8b 40 08             	mov    0x8(%eax),%eax
801043b3:	83 ec 0c             	sub    $0xc,%esp
801043b6:	50                   	push   %eax
801043b7:	e8 58 e7 ff ff       	call   80102b14 <kfree>
801043bc:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801043bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043c2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801043c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043cc:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801043d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043d8:	e9 e8 00 00 00       	jmp    801044c5 <fork+0x169>
  }
  np->sz = proc->sz;
801043dd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801043e3:	8b 10                	mov    (%eax),%edx
801043e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043e8:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801043ea:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801043f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043f4:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801043f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043fa:	8b 50 18             	mov    0x18(%eax),%edx
801043fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104403:	8b 40 18             	mov    0x18(%eax),%eax
80104406:	89 c3                	mov    %eax,%ebx
80104408:	b8 13 00 00 00       	mov    $0x13,%eax
8010440d:	89 d7                	mov    %edx,%edi
8010440f:	89 de                	mov    %ebx,%esi
80104411:	89 c1                	mov    %eax,%ecx
80104413:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104415:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104418:	8b 40 18             	mov    0x18(%eax),%eax
8010441b:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104422:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104429:	eb 43                	jmp    8010446e <fork+0x112>
    if(proc->ofile[i])
8010442b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104431:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104434:	83 c2 08             	add    $0x8,%edx
80104437:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010443b:	85 c0                	test   %eax,%eax
8010443d:	74 2b                	je     8010446a <fork+0x10e>
      np->ofile[i] = filedup(proc->ofile[i]);
8010443f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104445:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104448:	83 c2 08             	add    $0x8,%edx
8010444b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010444f:	83 ec 0c             	sub    $0xc,%esp
80104452:	50                   	push   %eax
80104453:	e8 79 cb ff ff       	call   80100fd1 <filedup>
80104458:	83 c4 10             	add    $0x10,%esp
8010445b:	89 c1                	mov    %eax,%ecx
8010445d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104460:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104463:	83 c2 08             	add    $0x8,%edx
80104466:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  for(i = 0; i < NOFILE; i++)
8010446a:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010446e:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104472:	7e b7                	jle    8010442b <fork+0xcf>
  np->cwd = idup(proc->cwd);
80104474:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010447a:	8b 40 68             	mov    0x68(%eax),%eax
8010447d:	83 ec 0c             	sub    $0xc,%esp
80104480:	50                   	push   %eax
80104481:	e8 37 d4 ff ff       	call   801018bd <idup>
80104486:	83 c4 10             	add    $0x10,%esp
80104489:	89 c2                	mov    %eax,%edx
8010448b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010448e:	89 50 68             	mov    %edx,0x68(%eax)
 
  pid = np->pid;
80104491:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104494:	8b 40 10             	mov    0x10(%eax),%eax
80104497:	89 45 dc             	mov    %eax,-0x24(%ebp)
  np->state = RUNNABLE;
8010449a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010449d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
801044a4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044aa:	8d 50 6c             	lea    0x6c(%eax),%edx
801044ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044b0:	83 c0 6c             	add    $0x6c,%eax
801044b3:	83 ec 04             	sub    $0x4,%esp
801044b6:	6a 10                	push   $0x10
801044b8:	52                   	push   %edx
801044b9:	50                   	push   %eax
801044ba:	e8 26 0c 00 00       	call   801050e5 <safestrcpy>
801044bf:	83 c4 10             	add    $0x10,%esp
  return pid;
801044c2:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801044c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801044c8:	5b                   	pop    %ebx
801044c9:	5e                   	pop    %esi
801044ca:	5f                   	pop    %edi
801044cb:	5d                   	pop    %ebp
801044cc:	c3                   	ret    

801044cd <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801044cd:	55                   	push   %ebp
801044ce:	89 e5                	mov    %esp,%ebp
801044d0:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;
  uint end_tick;
  uint second;
  uint msecond;
  if(proc == initproc)
801044d3:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801044da:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801044df:	39 c2                	cmp    %eax,%edx
801044e1:	75 0d                	jne    801044f0 <exit+0x23>
    panic("init exiting");
801044e3:	83 ec 0c             	sub    $0xc,%esp
801044e6:	68 85 84 10 80       	push   $0x80108485
801044eb:	e8 76 c0 ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801044f0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801044f7:	eb 48                	jmp    80104541 <exit+0x74>
    if(proc->ofile[fd]){
801044f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044ff:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104502:	83 c2 08             	add    $0x8,%edx
80104505:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104509:	85 c0                	test   %eax,%eax
8010450b:	74 30                	je     8010453d <exit+0x70>
      fileclose(proc->ofile[fd]);
8010450d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104513:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104516:	83 c2 08             	add    $0x8,%edx
80104519:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010451d:	83 ec 0c             	sub    $0xc,%esp
80104520:	50                   	push   %eax
80104521:	e8 fc ca ff ff       	call   80101022 <fileclose>
80104526:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80104529:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010452f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104532:	83 c2 08             	add    $0x8,%edx
80104535:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010453c:	00 
  for(fd = 0; fd < NOFILE; fd++){
8010453d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104541:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104545:	7e b2                	jle    801044f9 <exit+0x2c>
    }
  }

  iput(proc->cwd);
80104547:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010454d:	8b 40 68             	mov    0x68(%eax),%eax
80104550:	83 ec 0c             	sub    $0xc,%esp
80104553:	50                   	push   %eax
80104554:	e8 68 d5 ff ff       	call   80101ac1 <iput>
80104559:	83 c4 10             	add    $0x10,%esp
  proc->cwd = 0;
8010455c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104562:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)
  

  
  acquire(&ptable.lock);
80104569:	83 ec 0c             	sub    $0xc,%esp
8010456c:	68 20 ff 10 80       	push   $0x8010ff20
80104571:	e8 09 07 00 00       	call   80104c7f <acquire>
80104576:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104579:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010457f:	8b 40 14             	mov    0x14(%eax),%eax
80104582:	83 ec 0c             	sub    $0xc,%esp
80104585:	50                   	push   %eax
80104586:	e8 a7 04 00 00       	call   80104a32 <wakeup1>
8010458b:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010458e:	c7 45 f4 54 ff 10 80 	movl   $0x8010ff54,-0xc(%ebp)
80104595:	eb 3c                	jmp    801045d3 <exit+0x106>
    if(p->parent == proc){
80104597:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010459a:	8b 50 14             	mov    0x14(%eax),%edx
8010459d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045a3:	39 c2                	cmp    %eax,%edx
801045a5:	75 28                	jne    801045cf <exit+0x102>
      p->parent = initproc;
801045a7:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
801045ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b0:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801045b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b6:	8b 40 0c             	mov    0xc(%eax),%eax
801045b9:	83 f8 05             	cmp    $0x5,%eax
801045bc:	75 11                	jne    801045cf <exit+0x102>
        wakeup1(initproc);
801045be:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801045c3:	83 ec 0c             	sub    $0xc,%esp
801045c6:	50                   	push   %eax
801045c7:	e8 66 04 00 00       	call   80104a32 <wakeup1>
801045cc:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045cf:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801045d3:	81 7d f4 54 1f 11 80 	cmpl   $0x80111f54,-0xc(%ebp)
801045da:	72 bb                	jb     80104597 <exit+0xca>
    }
	 
  }
 
//my addition start 
  acquire(&tickslock);
801045dc:	83 ec 0c             	sub    $0xc,%esp
801045df:	68 60 1f 11 80       	push   $0x80111f60
801045e4:	e8 96 06 00 00       	call   80104c7f <acquire>
801045e9:	83 c4 10             	add    $0x10,%esp
  end_tick = ticks;
801045ec:	a1 a0 27 11 80       	mov    0x801127a0,%eax
801045f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  release(&tickslock);
801045f4:	83 ec 0c             	sub    $0xc,%esp
801045f7:	68 60 1f 11 80       	push   $0x80111f60
801045fc:	e8 e5 06 00 00       	call   80104ce6 <release>
80104601:	83 c4 10             	add    $0x10,%esp

  second = (end_tick-proc->start_tick)/100;
80104604:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010460a:	8b 40 7c             	mov    0x7c(%eax),%eax
8010460d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104610:	29 c2                	sub    %eax,%edx
80104612:	89 d0                	mov    %edx,%eax
80104614:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
80104619:	f7 e2                	mul    %edx
8010461b:	89 d0                	mov    %edx,%eax
8010461d:	c1 e8 05             	shr    $0x5,%eax
80104620:	89 45 e8             	mov    %eax,-0x18(%ebp)
  msecond = (end_tick-proc->start_tick)*10 - second*1000;
80104623:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104629:	8b 40 7c             	mov    0x7c(%eax),%eax
8010462c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010462f:	29 c2                	sub    %eax,%edx
80104631:	89 d0                	mov    %edx,%eax
80104633:	c1 e0 02             	shl    $0x2,%eax
80104636:	01 d0                	add    %edx,%eax
80104638:	01 c0                	add    %eax,%eax
8010463a:	89 c2                	mov    %eax,%edx
8010463c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010463f:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
80104645:	29 c2                	sub    %eax,%edx
80104647:	89 d0                	mov    %edx,%eax
80104649:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  cprintf("\n\npid = %d, name = %s, runtime = %ds %dms---\n",proc->pid,proc->name,second,msecond);
8010464c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104652:	8d 50 6c             	lea    0x6c(%eax),%edx
80104655:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010465b:	8b 40 10             	mov    0x10(%eax),%eax
8010465e:	83 ec 0c             	sub    $0xc,%esp
80104661:	ff 75 e4             	pushl  -0x1c(%ebp)
80104664:	ff 75 e8             	pushl  -0x18(%ebp)
80104667:	52                   	push   %edx
80104668:	50                   	push   %eax
80104669:	68 94 84 10 80       	push   $0x80108494
8010466e:	e8 53 bd ff ff       	call   801003c6 <cprintf>
80104673:	83 c4 20             	add    $0x20,%esp
  
//my addition end  


  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104676:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010467c:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104683:	e8 d6 01 00 00       	call   8010485e <sched>
  panic("zombie exit");
80104688:	83 ec 0c             	sub    $0xc,%esp
8010468b:	68 c2 84 10 80       	push   $0x801084c2
80104690:	e8 d1 be ff ff       	call   80100566 <panic>

80104695 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104695:	55                   	push   %ebp
80104696:	89 e5                	mov    %esp,%ebp
80104698:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
8010469b:	83 ec 0c             	sub    $0xc,%esp
8010469e:	68 20 ff 10 80       	push   $0x8010ff20
801046a3:	e8 d7 05 00 00       	call   80104c7f <acquire>
801046a8:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
801046ab:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046b2:	c7 45 f4 54 ff 10 80 	movl   $0x8010ff54,-0xc(%ebp)
801046b9:	e9 a6 00 00 00       	jmp    80104764 <wait+0xcf>
      if(p->parent != proc)
801046be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c1:	8b 50 14             	mov    0x14(%eax),%edx
801046c4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046ca:	39 c2                	cmp    %eax,%edx
801046cc:	0f 85 8d 00 00 00    	jne    8010475f <wait+0xca>
        continue;
      havekids = 1;
801046d2:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801046d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046dc:	8b 40 0c             	mov    0xc(%eax),%eax
801046df:	83 f8 05             	cmp    $0x5,%eax
801046e2:	75 7c                	jne    80104760 <wait+0xcb>
        // Found one.
        pid = p->pid;
801046e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e7:	8b 40 10             	mov    0x10(%eax),%eax
801046ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
801046ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f0:	8b 40 08             	mov    0x8(%eax),%eax
801046f3:	83 ec 0c             	sub    $0xc,%esp
801046f6:	50                   	push   %eax
801046f7:	e8 18 e4 ff ff       	call   80102b14 <kfree>
801046fc:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
801046ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104702:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104709:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010470c:	8b 40 04             	mov    0x4(%eax),%eax
8010470f:	83 ec 0c             	sub    $0xc,%esp
80104712:	50                   	push   %eax
80104713:	e8 38 37 00 00       	call   80107e50 <freevm>
80104718:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
8010471b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010471e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104725:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104728:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010472f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104732:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104739:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010473c:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104740:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104743:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
8010474a:	83 ec 0c             	sub    $0xc,%esp
8010474d:	68 20 ff 10 80       	push   $0x8010ff20
80104752:	e8 8f 05 00 00       	call   80104ce6 <release>
80104757:	83 c4 10             	add    $0x10,%esp
        return pid;
8010475a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010475d:	eb 58                	jmp    801047b7 <wait+0x122>
        continue;
8010475f:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104760:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104764:	81 7d f4 54 1f 11 80 	cmpl   $0x80111f54,-0xc(%ebp)
8010476b:	0f 82 4d ff ff ff    	jb     801046be <wait+0x29>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104771:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104775:	74 0d                	je     80104784 <wait+0xef>
80104777:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010477d:	8b 40 24             	mov    0x24(%eax),%eax
80104780:	85 c0                	test   %eax,%eax
80104782:	74 17                	je     8010479b <wait+0x106>
      release(&ptable.lock);
80104784:	83 ec 0c             	sub    $0xc,%esp
80104787:	68 20 ff 10 80       	push   $0x8010ff20
8010478c:	e8 55 05 00 00       	call   80104ce6 <release>
80104791:	83 c4 10             	add    $0x10,%esp
      return -1;
80104794:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104799:	eb 1c                	jmp    801047b7 <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
8010479b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047a1:	83 ec 08             	sub    $0x8,%esp
801047a4:	68 20 ff 10 80       	push   $0x8010ff20
801047a9:	50                   	push   %eax
801047aa:	e8 d7 01 00 00       	call   80104986 <sleep>
801047af:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801047b2:	e9 f4 fe ff ff       	jmp    801046ab <wait+0x16>
  }
}
801047b7:	c9                   	leave  
801047b8:	c3                   	ret    

801047b9 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801047b9:	55                   	push   %ebp
801047ba:	89 e5                	mov    %esp,%ebp
801047bc:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
801047bf:	e8 53 f8 ff ff       	call   80104017 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801047c4:	83 ec 0c             	sub    $0xc,%esp
801047c7:	68 20 ff 10 80       	push   $0x8010ff20
801047cc:	e8 ae 04 00 00       	call   80104c7f <acquire>
801047d1:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047d4:	c7 45 f4 54 ff 10 80 	movl   $0x8010ff54,-0xc(%ebp)
801047db:	eb 63                	jmp    80104840 <scheduler+0x87>
      if(p->state != RUNNABLE)
801047dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e0:	8b 40 0c             	mov    0xc(%eax),%eax
801047e3:	83 f8 03             	cmp    $0x3,%eax
801047e6:	75 53                	jne    8010483b <scheduler+0x82>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
801047e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047eb:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
801047f1:	83 ec 0c             	sub    $0xc,%esp
801047f4:	ff 75 f4             	pushl  -0xc(%ebp)
801047f7:	e8 0e 32 00 00       	call   80107a0a <switchuvm>
801047fc:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
801047ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104802:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104809:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010480f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104812:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104819:	83 c2 04             	add    $0x4,%edx
8010481c:	83 ec 08             	sub    $0x8,%esp
8010481f:	50                   	push   %eax
80104820:	52                   	push   %edx
80104821:	e8 30 09 00 00       	call   80105156 <swtch>
80104826:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104829:	e8 bf 31 00 00       	call   801079ed <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
8010482e:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104835:	00 00 00 00 
80104839:	eb 01                	jmp    8010483c <scheduler+0x83>
        continue;
8010483b:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010483c:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104840:	81 7d f4 54 1f 11 80 	cmpl   $0x80111f54,-0xc(%ebp)
80104847:	72 94                	jb     801047dd <scheduler+0x24>
    }
    release(&ptable.lock);
80104849:	83 ec 0c             	sub    $0xc,%esp
8010484c:	68 20 ff 10 80       	push   $0x8010ff20
80104851:	e8 90 04 00 00       	call   80104ce6 <release>
80104856:	83 c4 10             	add    $0x10,%esp
    sti();
80104859:	e9 61 ff ff ff       	jmp    801047bf <scheduler+0x6>

8010485e <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
8010485e:	55                   	push   %ebp
8010485f:	89 e5                	mov    %esp,%ebp
80104861:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80104864:	83 ec 0c             	sub    $0xc,%esp
80104867:	68 20 ff 10 80       	push   $0x8010ff20
8010486c:	e8 41 05 00 00       	call   80104db2 <holding>
80104871:	83 c4 10             	add    $0x10,%esp
80104874:	85 c0                	test   %eax,%eax
80104876:	75 0d                	jne    80104885 <sched+0x27>
    panic("sched ptable.lock");
80104878:	83 ec 0c             	sub    $0xc,%esp
8010487b:	68 ce 84 10 80       	push   $0x801084ce
80104880:	e8 e1 bc ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
80104885:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010488b:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104891:	83 f8 01             	cmp    $0x1,%eax
80104894:	74 0d                	je     801048a3 <sched+0x45>
    panic("sched locks");
80104896:	83 ec 0c             	sub    $0xc,%esp
80104899:	68 e0 84 10 80       	push   $0x801084e0
8010489e:	e8 c3 bc ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
801048a3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048a9:	8b 40 0c             	mov    0xc(%eax),%eax
801048ac:	83 f8 04             	cmp    $0x4,%eax
801048af:	75 0d                	jne    801048be <sched+0x60>
    panic("sched running");
801048b1:	83 ec 0c             	sub    $0xc,%esp
801048b4:	68 ec 84 10 80       	push   $0x801084ec
801048b9:	e8 a8 bc ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
801048be:	e8 44 f7 ff ff       	call   80104007 <readeflags>
801048c3:	25 00 02 00 00       	and    $0x200,%eax
801048c8:	85 c0                	test   %eax,%eax
801048ca:	74 0d                	je     801048d9 <sched+0x7b>
    panic("sched interruptible");
801048cc:	83 ec 0c             	sub    $0xc,%esp
801048cf:	68 fa 84 10 80       	push   $0x801084fa
801048d4:	e8 8d bc ff ff       	call   80100566 <panic>
  intena = cpu->intena;
801048d9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801048df:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801048e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
801048e8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801048ee:	8b 40 04             	mov    0x4(%eax),%eax
801048f1:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801048f8:	83 c2 1c             	add    $0x1c,%edx
801048fb:	83 ec 08             	sub    $0x8,%esp
801048fe:	50                   	push   %eax
801048ff:	52                   	push   %edx
80104900:	e8 51 08 00 00       	call   80105156 <swtch>
80104905:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80104908:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010490e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104911:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104917:	90                   	nop
80104918:	c9                   	leave  
80104919:	c3                   	ret    

8010491a <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010491a:	55                   	push   %ebp
8010491b:	89 e5                	mov    %esp,%ebp
8010491d:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104920:	83 ec 0c             	sub    $0xc,%esp
80104923:	68 20 ff 10 80       	push   $0x8010ff20
80104928:	e8 52 03 00 00       	call   80104c7f <acquire>
8010492d:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80104930:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104936:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010493d:	e8 1c ff ff ff       	call   8010485e <sched>
  release(&ptable.lock);
80104942:	83 ec 0c             	sub    $0xc,%esp
80104945:	68 20 ff 10 80       	push   $0x8010ff20
8010494a:	e8 97 03 00 00       	call   80104ce6 <release>
8010494f:	83 c4 10             	add    $0x10,%esp
}
80104952:	90                   	nop
80104953:	c9                   	leave  
80104954:	c3                   	ret    

80104955 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104955:	55                   	push   %ebp
80104956:	89 e5                	mov    %esp,%ebp
80104958:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010495b:	83 ec 0c             	sub    $0xc,%esp
8010495e:	68 20 ff 10 80       	push   $0x8010ff20
80104963:	e8 7e 03 00 00       	call   80104ce6 <release>
80104968:	83 c4 10             	add    $0x10,%esp

  if (first) {
8010496b:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104970:	85 c0                	test   %eax,%eax
80104972:	74 0f                	je     80104983 <forkret+0x2e>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104974:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
8010497b:	00 00 00 
    initlog();
8010497e:	e8 d2 e6 ff ff       	call   80103055 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104983:	90                   	nop
80104984:	c9                   	leave  
80104985:	c3                   	ret    

80104986 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104986:	55                   	push   %ebp
80104987:	89 e5                	mov    %esp,%ebp
80104989:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
8010498c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104992:	85 c0                	test   %eax,%eax
80104994:	75 0d                	jne    801049a3 <sleep+0x1d>
    panic("sleep");
80104996:	83 ec 0c             	sub    $0xc,%esp
80104999:	68 0e 85 10 80       	push   $0x8010850e
8010499e:	e8 c3 bb ff ff       	call   80100566 <panic>

  if(lk == 0)
801049a3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801049a7:	75 0d                	jne    801049b6 <sleep+0x30>
    panic("sleep without lk");
801049a9:	83 ec 0c             	sub    $0xc,%esp
801049ac:	68 14 85 10 80       	push   $0x80108514
801049b1:	e8 b0 bb ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801049b6:	81 7d 0c 20 ff 10 80 	cmpl   $0x8010ff20,0xc(%ebp)
801049bd:	74 1e                	je     801049dd <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
801049bf:	83 ec 0c             	sub    $0xc,%esp
801049c2:	68 20 ff 10 80       	push   $0x8010ff20
801049c7:	e8 b3 02 00 00       	call   80104c7f <acquire>
801049cc:	83 c4 10             	add    $0x10,%esp
    release(lk);
801049cf:	83 ec 0c             	sub    $0xc,%esp
801049d2:	ff 75 0c             	pushl  0xc(%ebp)
801049d5:	e8 0c 03 00 00       	call   80104ce6 <release>
801049da:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
801049dd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049e3:	8b 55 08             	mov    0x8(%ebp),%edx
801049e6:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
801049e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049ef:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
801049f6:	e8 63 fe ff ff       	call   8010485e <sched>

  // Tidy up.
  proc->chan = 0;
801049fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a01:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104a08:	81 7d 0c 20 ff 10 80 	cmpl   $0x8010ff20,0xc(%ebp)
80104a0f:	74 1e                	je     80104a2f <sleep+0xa9>
    release(&ptable.lock);
80104a11:	83 ec 0c             	sub    $0xc,%esp
80104a14:	68 20 ff 10 80       	push   $0x8010ff20
80104a19:	e8 c8 02 00 00       	call   80104ce6 <release>
80104a1e:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104a21:	83 ec 0c             	sub    $0xc,%esp
80104a24:	ff 75 0c             	pushl  0xc(%ebp)
80104a27:	e8 53 02 00 00       	call   80104c7f <acquire>
80104a2c:	83 c4 10             	add    $0x10,%esp
  }
}
80104a2f:	90                   	nop
80104a30:	c9                   	leave  
80104a31:	c3                   	ret    

80104a32 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104a32:	55                   	push   %ebp
80104a33:	89 e5                	mov    %esp,%ebp
80104a35:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104a38:	c7 45 fc 54 ff 10 80 	movl   $0x8010ff54,-0x4(%ebp)
80104a3f:	eb 24                	jmp    80104a65 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104a41:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a44:	8b 40 0c             	mov    0xc(%eax),%eax
80104a47:	83 f8 02             	cmp    $0x2,%eax
80104a4a:	75 15                	jne    80104a61 <wakeup1+0x2f>
80104a4c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a4f:	8b 40 20             	mov    0x20(%eax),%eax
80104a52:	3b 45 08             	cmp    0x8(%ebp),%eax
80104a55:	75 0a                	jne    80104a61 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104a57:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a5a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104a61:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
80104a65:	81 7d fc 54 1f 11 80 	cmpl   $0x80111f54,-0x4(%ebp)
80104a6c:	72 d3                	jb     80104a41 <wakeup1+0xf>
}
80104a6e:	90                   	nop
80104a6f:	c9                   	leave  
80104a70:	c3                   	ret    

80104a71 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104a71:	55                   	push   %ebp
80104a72:	89 e5                	mov    %esp,%ebp
80104a74:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104a77:	83 ec 0c             	sub    $0xc,%esp
80104a7a:	68 20 ff 10 80       	push   $0x8010ff20
80104a7f:	e8 fb 01 00 00       	call   80104c7f <acquire>
80104a84:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104a87:	83 ec 0c             	sub    $0xc,%esp
80104a8a:	ff 75 08             	pushl  0x8(%ebp)
80104a8d:	e8 a0 ff ff ff       	call   80104a32 <wakeup1>
80104a92:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104a95:	83 ec 0c             	sub    $0xc,%esp
80104a98:	68 20 ff 10 80       	push   $0x8010ff20
80104a9d:	e8 44 02 00 00       	call   80104ce6 <release>
80104aa2:	83 c4 10             	add    $0x10,%esp
}
80104aa5:	90                   	nop
80104aa6:	c9                   	leave  
80104aa7:	c3                   	ret    

80104aa8 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104aa8:	55                   	push   %ebp
80104aa9:	89 e5                	mov    %esp,%ebp
80104aab:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104aae:	83 ec 0c             	sub    $0xc,%esp
80104ab1:	68 20 ff 10 80       	push   $0x8010ff20
80104ab6:	e8 c4 01 00 00       	call   80104c7f <acquire>
80104abb:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104abe:	c7 45 f4 54 ff 10 80 	movl   $0x8010ff54,-0xc(%ebp)
80104ac5:	eb 45                	jmp    80104b0c <kill+0x64>
    if(p->pid == pid){
80104ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aca:	8b 40 10             	mov    0x10(%eax),%eax
80104acd:	3b 45 08             	cmp    0x8(%ebp),%eax
80104ad0:	75 36                	jne    80104b08 <kill+0x60>
      p->killed = 1;
80104ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad5:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104adf:	8b 40 0c             	mov    0xc(%eax),%eax
80104ae2:	83 f8 02             	cmp    $0x2,%eax
80104ae5:	75 0a                	jne    80104af1 <kill+0x49>
        p->state = RUNNABLE;
80104ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aea:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104af1:	83 ec 0c             	sub    $0xc,%esp
80104af4:	68 20 ff 10 80       	push   $0x8010ff20
80104af9:	e8 e8 01 00 00       	call   80104ce6 <release>
80104afe:	83 c4 10             	add    $0x10,%esp
      return 0;
80104b01:	b8 00 00 00 00       	mov    $0x0,%eax
80104b06:	eb 22                	jmp    80104b2a <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b08:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104b0c:	81 7d f4 54 1f 11 80 	cmpl   $0x80111f54,-0xc(%ebp)
80104b13:	72 b2                	jb     80104ac7 <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104b15:	83 ec 0c             	sub    $0xc,%esp
80104b18:	68 20 ff 10 80       	push   $0x8010ff20
80104b1d:	e8 c4 01 00 00       	call   80104ce6 <release>
80104b22:	83 c4 10             	add    $0x10,%esp
  return -1;
80104b25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104b2a:	c9                   	leave  
80104b2b:	c3                   	ret    

80104b2c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104b2c:	55                   	push   %ebp
80104b2d:	89 e5                	mov    %esp,%ebp
80104b2f:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b32:	c7 45 f0 54 ff 10 80 	movl   $0x8010ff54,-0x10(%ebp)
80104b39:	e9 d7 00 00 00       	jmp    80104c15 <procdump+0xe9>
    if(p->state == UNUSED)
80104b3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b41:	8b 40 0c             	mov    0xc(%eax),%eax
80104b44:	85 c0                	test   %eax,%eax
80104b46:	0f 84 c4 00 00 00    	je     80104c10 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104b4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b4f:	8b 40 0c             	mov    0xc(%eax),%eax
80104b52:	83 f8 05             	cmp    $0x5,%eax
80104b55:	77 23                	ja     80104b7a <procdump+0x4e>
80104b57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b5a:	8b 40 0c             	mov    0xc(%eax),%eax
80104b5d:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104b64:	85 c0                	test   %eax,%eax
80104b66:	74 12                	je     80104b7a <procdump+0x4e>
      state = states[p->state];
80104b68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b6b:	8b 40 0c             	mov    0xc(%eax),%eax
80104b6e:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104b75:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104b78:	eb 07                	jmp    80104b81 <procdump+0x55>
    else
      state = "???";
80104b7a:	c7 45 ec 25 85 10 80 	movl   $0x80108525,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104b81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b84:	8d 50 6c             	lea    0x6c(%eax),%edx
80104b87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b8a:	8b 40 10             	mov    0x10(%eax),%eax
80104b8d:	52                   	push   %edx
80104b8e:	ff 75 ec             	pushl  -0x14(%ebp)
80104b91:	50                   	push   %eax
80104b92:	68 29 85 10 80       	push   $0x80108529
80104b97:	e8 2a b8 ff ff       	call   801003c6 <cprintf>
80104b9c:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104b9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ba2:	8b 40 0c             	mov    0xc(%eax),%eax
80104ba5:	83 f8 02             	cmp    $0x2,%eax
80104ba8:	75 54                	jne    80104bfe <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104baa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bad:	8b 40 1c             	mov    0x1c(%eax),%eax
80104bb0:	8b 40 0c             	mov    0xc(%eax),%eax
80104bb3:	83 c0 08             	add    $0x8,%eax
80104bb6:	89 c2                	mov    %eax,%edx
80104bb8:	83 ec 08             	sub    $0x8,%esp
80104bbb:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104bbe:	50                   	push   %eax
80104bbf:	52                   	push   %edx
80104bc0:	e8 73 01 00 00       	call   80104d38 <getcallerpcs>
80104bc5:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104bc8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104bcf:	eb 1c                	jmp    80104bed <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd4:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104bd8:	83 ec 08             	sub    $0x8,%esp
80104bdb:	50                   	push   %eax
80104bdc:	68 32 85 10 80       	push   $0x80108532
80104be1:	e8 e0 b7 ff ff       	call   801003c6 <cprintf>
80104be6:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104be9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104bed:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104bf1:	7f 0b                	jg     80104bfe <procdump+0xd2>
80104bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf6:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104bfa:	85 c0                	test   %eax,%eax
80104bfc:	75 d3                	jne    80104bd1 <procdump+0xa5>
    }
    cprintf("\n");
80104bfe:	83 ec 0c             	sub    $0xc,%esp
80104c01:	68 36 85 10 80       	push   $0x80108536
80104c06:	e8 bb b7 ff ff       	call   801003c6 <cprintf>
80104c0b:	83 c4 10             	add    $0x10,%esp
80104c0e:	eb 01                	jmp    80104c11 <procdump+0xe5>
      continue;
80104c10:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c11:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
80104c15:	81 7d f0 54 1f 11 80 	cmpl   $0x80111f54,-0x10(%ebp)
80104c1c:	0f 82 1c ff ff ff    	jb     80104b3e <procdump+0x12>
  }
}
80104c22:	90                   	nop
80104c23:	c9                   	leave  
80104c24:	c3                   	ret    

80104c25 <readeflags>:
{
80104c25:	55                   	push   %ebp
80104c26:	89 e5                	mov    %esp,%ebp
80104c28:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104c2b:	9c                   	pushf  
80104c2c:	58                   	pop    %eax
80104c2d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104c30:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104c33:	c9                   	leave  
80104c34:	c3                   	ret    

80104c35 <cli>:
{
80104c35:	55                   	push   %ebp
80104c36:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104c38:	fa                   	cli    
}
80104c39:	90                   	nop
80104c3a:	5d                   	pop    %ebp
80104c3b:	c3                   	ret    

80104c3c <sti>:
{
80104c3c:	55                   	push   %ebp
80104c3d:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104c3f:	fb                   	sti    
}
80104c40:	90                   	nop
80104c41:	5d                   	pop    %ebp
80104c42:	c3                   	ret    

80104c43 <xchg>:
{
80104c43:	55                   	push   %ebp
80104c44:	89 e5                	mov    %esp,%ebp
80104c46:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104c49:	8b 55 08             	mov    0x8(%ebp),%edx
80104c4c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104c52:	f0 87 02             	lock xchg %eax,(%edx)
80104c55:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104c58:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104c5b:	c9                   	leave  
80104c5c:	c3                   	ret    

80104c5d <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104c5d:	55                   	push   %ebp
80104c5e:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104c60:	8b 45 08             	mov    0x8(%ebp),%eax
80104c63:	8b 55 0c             	mov    0xc(%ebp),%edx
80104c66:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104c69:	8b 45 08             	mov    0x8(%ebp),%eax
80104c6c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104c72:	8b 45 08             	mov    0x8(%ebp),%eax
80104c75:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104c7c:	90                   	nop
80104c7d:	5d                   	pop    %ebp
80104c7e:	c3                   	ret    

80104c7f <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104c7f:	55                   	push   %ebp
80104c80:	89 e5                	mov    %esp,%ebp
80104c82:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104c85:	e8 52 01 00 00       	call   80104ddc <pushcli>
  if(holding(lk))
80104c8a:	8b 45 08             	mov    0x8(%ebp),%eax
80104c8d:	83 ec 0c             	sub    $0xc,%esp
80104c90:	50                   	push   %eax
80104c91:	e8 1c 01 00 00       	call   80104db2 <holding>
80104c96:	83 c4 10             	add    $0x10,%esp
80104c99:	85 c0                	test   %eax,%eax
80104c9b:	74 0d                	je     80104caa <acquire+0x2b>
    panic("acquire");
80104c9d:	83 ec 0c             	sub    $0xc,%esp
80104ca0:	68 62 85 10 80       	push   $0x80108562
80104ca5:	e8 bc b8 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80104caa:	90                   	nop
80104cab:	8b 45 08             	mov    0x8(%ebp),%eax
80104cae:	83 ec 08             	sub    $0x8,%esp
80104cb1:	6a 01                	push   $0x1
80104cb3:	50                   	push   %eax
80104cb4:	e8 8a ff ff ff       	call   80104c43 <xchg>
80104cb9:	83 c4 10             	add    $0x10,%esp
80104cbc:	85 c0                	test   %eax,%eax
80104cbe:	75 eb                	jne    80104cab <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80104cc0:	8b 45 08             	mov    0x8(%ebp),%eax
80104cc3:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104cca:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80104ccd:	8b 45 08             	mov    0x8(%ebp),%eax
80104cd0:	83 c0 0c             	add    $0xc,%eax
80104cd3:	83 ec 08             	sub    $0x8,%esp
80104cd6:	50                   	push   %eax
80104cd7:	8d 45 08             	lea    0x8(%ebp),%eax
80104cda:	50                   	push   %eax
80104cdb:	e8 58 00 00 00       	call   80104d38 <getcallerpcs>
80104ce0:	83 c4 10             	add    $0x10,%esp
}
80104ce3:	90                   	nop
80104ce4:	c9                   	leave  
80104ce5:	c3                   	ret    

80104ce6 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104ce6:	55                   	push   %ebp
80104ce7:	89 e5                	mov    %esp,%ebp
80104ce9:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104cec:	83 ec 0c             	sub    $0xc,%esp
80104cef:	ff 75 08             	pushl  0x8(%ebp)
80104cf2:	e8 bb 00 00 00       	call   80104db2 <holding>
80104cf7:	83 c4 10             	add    $0x10,%esp
80104cfa:	85 c0                	test   %eax,%eax
80104cfc:	75 0d                	jne    80104d0b <release+0x25>
    panic("release");
80104cfe:	83 ec 0c             	sub    $0xc,%esp
80104d01:	68 6a 85 10 80       	push   $0x8010856a
80104d06:	e8 5b b8 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80104d0b:	8b 45 08             	mov    0x8(%ebp),%eax
80104d0e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104d15:	8b 45 08             	mov    0x8(%ebp),%eax
80104d18:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80104d1f:	8b 45 08             	mov    0x8(%ebp),%eax
80104d22:	83 ec 08             	sub    $0x8,%esp
80104d25:	6a 00                	push   $0x0
80104d27:	50                   	push   %eax
80104d28:	e8 16 ff ff ff       	call   80104c43 <xchg>
80104d2d:	83 c4 10             	add    $0x10,%esp

  popcli();
80104d30:	e8 ec 00 00 00       	call   80104e21 <popcli>
}
80104d35:	90                   	nop
80104d36:	c9                   	leave  
80104d37:	c3                   	ret    

80104d38 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104d38:	55                   	push   %ebp
80104d39:	89 e5                	mov    %esp,%ebp
80104d3b:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80104d3e:	8b 45 08             	mov    0x8(%ebp),%eax
80104d41:	83 e8 08             	sub    $0x8,%eax
80104d44:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104d47:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104d4e:	eb 38                	jmp    80104d88 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104d50:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104d54:	74 53                	je     80104da9 <getcallerpcs+0x71>
80104d56:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104d5d:	76 4a                	jbe    80104da9 <getcallerpcs+0x71>
80104d5f:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104d63:	74 44                	je     80104da9 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104d65:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104d68:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104d6f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d72:	01 c2                	add    %eax,%edx
80104d74:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d77:	8b 40 04             	mov    0x4(%eax),%eax
80104d7a:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104d7c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d7f:	8b 00                	mov    (%eax),%eax
80104d81:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104d84:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104d88:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104d8c:	7e c2                	jle    80104d50 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104d8e:	eb 19                	jmp    80104da9 <getcallerpcs+0x71>
    pcs[i] = 0;
80104d90:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104d93:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104d9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d9d:	01 d0                	add    %edx,%eax
80104d9f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104da5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104da9:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104dad:	7e e1                	jle    80104d90 <getcallerpcs+0x58>
}
80104daf:	90                   	nop
80104db0:	c9                   	leave  
80104db1:	c3                   	ret    

80104db2 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104db2:	55                   	push   %ebp
80104db3:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80104db5:	8b 45 08             	mov    0x8(%ebp),%eax
80104db8:	8b 00                	mov    (%eax),%eax
80104dba:	85 c0                	test   %eax,%eax
80104dbc:	74 17                	je     80104dd5 <holding+0x23>
80104dbe:	8b 45 08             	mov    0x8(%ebp),%eax
80104dc1:	8b 50 08             	mov    0x8(%eax),%edx
80104dc4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104dca:	39 c2                	cmp    %eax,%edx
80104dcc:	75 07                	jne    80104dd5 <holding+0x23>
80104dce:	b8 01 00 00 00       	mov    $0x1,%eax
80104dd3:	eb 05                	jmp    80104dda <holding+0x28>
80104dd5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104dda:	5d                   	pop    %ebp
80104ddb:	c3                   	ret    

80104ddc <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104ddc:	55                   	push   %ebp
80104ddd:	89 e5                	mov    %esp,%ebp
80104ddf:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80104de2:	e8 3e fe ff ff       	call   80104c25 <readeflags>
80104de7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80104dea:	e8 46 fe ff ff       	call   80104c35 <cli>
  if(cpu->ncli++ == 0)
80104def:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104df6:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80104dfc:	8d 48 01             	lea    0x1(%eax),%ecx
80104dff:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80104e05:	85 c0                	test   %eax,%eax
80104e07:	75 15                	jne    80104e1e <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80104e09:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104e0f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104e12:	81 e2 00 02 00 00    	and    $0x200,%edx
80104e18:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104e1e:	90                   	nop
80104e1f:	c9                   	leave  
80104e20:	c3                   	ret    

80104e21 <popcli>:

void
popcli(void)
{
80104e21:	55                   	push   %ebp
80104e22:	89 e5                	mov    %esp,%ebp
80104e24:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104e27:	e8 f9 fd ff ff       	call   80104c25 <readeflags>
80104e2c:	25 00 02 00 00       	and    $0x200,%eax
80104e31:	85 c0                	test   %eax,%eax
80104e33:	74 0d                	je     80104e42 <popcli+0x21>
    panic("popcli - interruptible");
80104e35:	83 ec 0c             	sub    $0xc,%esp
80104e38:	68 72 85 10 80       	push   $0x80108572
80104e3d:	e8 24 b7 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80104e42:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104e48:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80104e4e:	83 ea 01             	sub    $0x1,%edx
80104e51:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80104e57:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104e5d:	85 c0                	test   %eax,%eax
80104e5f:	79 0d                	jns    80104e6e <popcli+0x4d>
    panic("popcli");
80104e61:	83 ec 0c             	sub    $0xc,%esp
80104e64:	68 89 85 10 80       	push   $0x80108589
80104e69:	e8 f8 b6 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80104e6e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104e74:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104e7a:	85 c0                	test   %eax,%eax
80104e7c:	75 15                	jne    80104e93 <popcli+0x72>
80104e7e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104e84:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104e8a:	85 c0                	test   %eax,%eax
80104e8c:	74 05                	je     80104e93 <popcli+0x72>
    sti();
80104e8e:	e8 a9 fd ff ff       	call   80104c3c <sti>
}
80104e93:	90                   	nop
80104e94:	c9                   	leave  
80104e95:	c3                   	ret    

80104e96 <stosb>:
{
80104e96:	55                   	push   %ebp
80104e97:	89 e5                	mov    %esp,%ebp
80104e99:	57                   	push   %edi
80104e9a:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104e9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104e9e:	8b 55 10             	mov    0x10(%ebp),%edx
80104ea1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ea4:	89 cb                	mov    %ecx,%ebx
80104ea6:	89 df                	mov    %ebx,%edi
80104ea8:	89 d1                	mov    %edx,%ecx
80104eaa:	fc                   	cld    
80104eab:	f3 aa                	rep stos %al,%es:(%edi)
80104ead:	89 ca                	mov    %ecx,%edx
80104eaf:	89 fb                	mov    %edi,%ebx
80104eb1:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104eb4:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104eb7:	90                   	nop
80104eb8:	5b                   	pop    %ebx
80104eb9:	5f                   	pop    %edi
80104eba:	5d                   	pop    %ebp
80104ebb:	c3                   	ret    

80104ebc <stosl>:
{
80104ebc:	55                   	push   %ebp
80104ebd:	89 e5                	mov    %esp,%ebp
80104ebf:	57                   	push   %edi
80104ec0:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104ec1:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104ec4:	8b 55 10             	mov    0x10(%ebp),%edx
80104ec7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104eca:	89 cb                	mov    %ecx,%ebx
80104ecc:	89 df                	mov    %ebx,%edi
80104ece:	89 d1                	mov    %edx,%ecx
80104ed0:	fc                   	cld    
80104ed1:	f3 ab                	rep stos %eax,%es:(%edi)
80104ed3:	89 ca                	mov    %ecx,%edx
80104ed5:	89 fb                	mov    %edi,%ebx
80104ed7:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104eda:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104edd:	90                   	nop
80104ede:	5b                   	pop    %ebx
80104edf:	5f                   	pop    %edi
80104ee0:	5d                   	pop    %ebp
80104ee1:	c3                   	ret    

80104ee2 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104ee2:	55                   	push   %ebp
80104ee3:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104ee5:	8b 45 08             	mov    0x8(%ebp),%eax
80104ee8:	83 e0 03             	and    $0x3,%eax
80104eeb:	85 c0                	test   %eax,%eax
80104eed:	75 43                	jne    80104f32 <memset+0x50>
80104eef:	8b 45 10             	mov    0x10(%ebp),%eax
80104ef2:	83 e0 03             	and    $0x3,%eax
80104ef5:	85 c0                	test   %eax,%eax
80104ef7:	75 39                	jne    80104f32 <memset+0x50>
    c &= 0xFF;
80104ef9:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104f00:	8b 45 10             	mov    0x10(%ebp),%eax
80104f03:	c1 e8 02             	shr    $0x2,%eax
80104f06:	89 c1                	mov    %eax,%ecx
80104f08:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f0b:	c1 e0 18             	shl    $0x18,%eax
80104f0e:	89 c2                	mov    %eax,%edx
80104f10:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f13:	c1 e0 10             	shl    $0x10,%eax
80104f16:	09 c2                	or     %eax,%edx
80104f18:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f1b:	c1 e0 08             	shl    $0x8,%eax
80104f1e:	09 d0                	or     %edx,%eax
80104f20:	0b 45 0c             	or     0xc(%ebp),%eax
80104f23:	51                   	push   %ecx
80104f24:	50                   	push   %eax
80104f25:	ff 75 08             	pushl  0x8(%ebp)
80104f28:	e8 8f ff ff ff       	call   80104ebc <stosl>
80104f2d:	83 c4 0c             	add    $0xc,%esp
80104f30:	eb 12                	jmp    80104f44 <memset+0x62>
  } else
    stosb(dst, c, n);
80104f32:	8b 45 10             	mov    0x10(%ebp),%eax
80104f35:	50                   	push   %eax
80104f36:	ff 75 0c             	pushl  0xc(%ebp)
80104f39:	ff 75 08             	pushl  0x8(%ebp)
80104f3c:	e8 55 ff ff ff       	call   80104e96 <stosb>
80104f41:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104f44:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104f47:	c9                   	leave  
80104f48:	c3                   	ret    

80104f49 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104f49:	55                   	push   %ebp
80104f4a:	89 e5                	mov    %esp,%ebp
80104f4c:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80104f4f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f52:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104f55:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f58:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104f5b:	eb 30                	jmp    80104f8d <memcmp+0x44>
    if(*s1 != *s2)
80104f5d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f60:	0f b6 10             	movzbl (%eax),%edx
80104f63:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f66:	0f b6 00             	movzbl (%eax),%eax
80104f69:	38 c2                	cmp    %al,%dl
80104f6b:	74 18                	je     80104f85 <memcmp+0x3c>
      return *s1 - *s2;
80104f6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f70:	0f b6 00             	movzbl (%eax),%eax
80104f73:	0f b6 d0             	movzbl %al,%edx
80104f76:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f79:	0f b6 00             	movzbl (%eax),%eax
80104f7c:	0f b6 c0             	movzbl %al,%eax
80104f7f:	29 c2                	sub    %eax,%edx
80104f81:	89 d0                	mov    %edx,%eax
80104f83:	eb 1a                	jmp    80104f9f <memcmp+0x56>
    s1++, s2++;
80104f85:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104f89:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104f8d:	8b 45 10             	mov    0x10(%ebp),%eax
80104f90:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f93:	89 55 10             	mov    %edx,0x10(%ebp)
80104f96:	85 c0                	test   %eax,%eax
80104f98:	75 c3                	jne    80104f5d <memcmp+0x14>
  }

  return 0;
80104f9a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f9f:	c9                   	leave  
80104fa0:	c3                   	ret    

80104fa1 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104fa1:	55                   	push   %ebp
80104fa2:	89 e5                	mov    %esp,%ebp
80104fa4:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104fa7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104faa:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104fad:	8b 45 08             	mov    0x8(%ebp),%eax
80104fb0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104fb3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fb6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104fb9:	73 54                	jae    8010500f <memmove+0x6e>
80104fbb:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104fbe:	8b 45 10             	mov    0x10(%ebp),%eax
80104fc1:	01 d0                	add    %edx,%eax
80104fc3:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104fc6:	76 47                	jbe    8010500f <memmove+0x6e>
    s += n;
80104fc8:	8b 45 10             	mov    0x10(%ebp),%eax
80104fcb:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104fce:	8b 45 10             	mov    0x10(%ebp),%eax
80104fd1:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104fd4:	eb 13                	jmp    80104fe9 <memmove+0x48>
      *--d = *--s;
80104fd6:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104fda:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104fde:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fe1:	0f b6 10             	movzbl (%eax),%edx
80104fe4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104fe7:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104fe9:	8b 45 10             	mov    0x10(%ebp),%eax
80104fec:	8d 50 ff             	lea    -0x1(%eax),%edx
80104fef:	89 55 10             	mov    %edx,0x10(%ebp)
80104ff2:	85 c0                	test   %eax,%eax
80104ff4:	75 e0                	jne    80104fd6 <memmove+0x35>
  if(s < d && s + n > d){
80104ff6:	eb 24                	jmp    8010501c <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104ff8:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ffb:	8d 50 01             	lea    0x1(%eax),%edx
80104ffe:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105001:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105004:	8d 4a 01             	lea    0x1(%edx),%ecx
80105007:	89 4d fc             	mov    %ecx,-0x4(%ebp)
8010500a:	0f b6 12             	movzbl (%edx),%edx
8010500d:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
8010500f:	8b 45 10             	mov    0x10(%ebp),%eax
80105012:	8d 50 ff             	lea    -0x1(%eax),%edx
80105015:	89 55 10             	mov    %edx,0x10(%ebp)
80105018:	85 c0                	test   %eax,%eax
8010501a:	75 dc                	jne    80104ff8 <memmove+0x57>

  return dst;
8010501c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010501f:	c9                   	leave  
80105020:	c3                   	ret    

80105021 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105021:	55                   	push   %ebp
80105022:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105024:	ff 75 10             	pushl  0x10(%ebp)
80105027:	ff 75 0c             	pushl  0xc(%ebp)
8010502a:	ff 75 08             	pushl  0x8(%ebp)
8010502d:	e8 6f ff ff ff       	call   80104fa1 <memmove>
80105032:	83 c4 0c             	add    $0xc,%esp
}
80105035:	c9                   	leave  
80105036:	c3                   	ret    

80105037 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105037:	55                   	push   %ebp
80105038:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010503a:	eb 0c                	jmp    80105048 <strncmp+0x11>
    n--, p++, q++;
8010503c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105040:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105044:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80105048:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010504c:	74 1a                	je     80105068 <strncmp+0x31>
8010504e:	8b 45 08             	mov    0x8(%ebp),%eax
80105051:	0f b6 00             	movzbl (%eax),%eax
80105054:	84 c0                	test   %al,%al
80105056:	74 10                	je     80105068 <strncmp+0x31>
80105058:	8b 45 08             	mov    0x8(%ebp),%eax
8010505b:	0f b6 10             	movzbl (%eax),%edx
8010505e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105061:	0f b6 00             	movzbl (%eax),%eax
80105064:	38 c2                	cmp    %al,%dl
80105066:	74 d4                	je     8010503c <strncmp+0x5>
  if(n == 0)
80105068:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010506c:	75 07                	jne    80105075 <strncmp+0x3e>
    return 0;
8010506e:	b8 00 00 00 00       	mov    $0x0,%eax
80105073:	eb 16                	jmp    8010508b <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105075:	8b 45 08             	mov    0x8(%ebp),%eax
80105078:	0f b6 00             	movzbl (%eax),%eax
8010507b:	0f b6 d0             	movzbl %al,%edx
8010507e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105081:	0f b6 00             	movzbl (%eax),%eax
80105084:	0f b6 c0             	movzbl %al,%eax
80105087:	29 c2                	sub    %eax,%edx
80105089:	89 d0                	mov    %edx,%eax
}
8010508b:	5d                   	pop    %ebp
8010508c:	c3                   	ret    

8010508d <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010508d:	55                   	push   %ebp
8010508e:	89 e5                	mov    %esp,%ebp
80105090:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105093:	8b 45 08             	mov    0x8(%ebp),%eax
80105096:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105099:	90                   	nop
8010509a:	8b 45 10             	mov    0x10(%ebp),%eax
8010509d:	8d 50 ff             	lea    -0x1(%eax),%edx
801050a0:	89 55 10             	mov    %edx,0x10(%ebp)
801050a3:	85 c0                	test   %eax,%eax
801050a5:	7e 2c                	jle    801050d3 <strncpy+0x46>
801050a7:	8b 45 08             	mov    0x8(%ebp),%eax
801050aa:	8d 50 01             	lea    0x1(%eax),%edx
801050ad:	89 55 08             	mov    %edx,0x8(%ebp)
801050b0:	8b 55 0c             	mov    0xc(%ebp),%edx
801050b3:	8d 4a 01             	lea    0x1(%edx),%ecx
801050b6:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801050b9:	0f b6 12             	movzbl (%edx),%edx
801050bc:	88 10                	mov    %dl,(%eax)
801050be:	0f b6 00             	movzbl (%eax),%eax
801050c1:	84 c0                	test   %al,%al
801050c3:	75 d5                	jne    8010509a <strncpy+0xd>
    ;
  while(n-- > 0)
801050c5:	eb 0c                	jmp    801050d3 <strncpy+0x46>
    *s++ = 0;
801050c7:	8b 45 08             	mov    0x8(%ebp),%eax
801050ca:	8d 50 01             	lea    0x1(%eax),%edx
801050cd:	89 55 08             	mov    %edx,0x8(%ebp)
801050d0:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
801050d3:	8b 45 10             	mov    0x10(%ebp),%eax
801050d6:	8d 50 ff             	lea    -0x1(%eax),%edx
801050d9:	89 55 10             	mov    %edx,0x10(%ebp)
801050dc:	85 c0                	test   %eax,%eax
801050de:	7f e7                	jg     801050c7 <strncpy+0x3a>
  return os;
801050e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801050e3:	c9                   	leave  
801050e4:	c3                   	ret    

801050e5 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801050e5:	55                   	push   %ebp
801050e6:	89 e5                	mov    %esp,%ebp
801050e8:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801050eb:	8b 45 08             	mov    0x8(%ebp),%eax
801050ee:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801050f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801050f5:	7f 05                	jg     801050fc <safestrcpy+0x17>
    return os;
801050f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050fa:	eb 31                	jmp    8010512d <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
801050fc:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105100:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105104:	7e 1e                	jle    80105124 <safestrcpy+0x3f>
80105106:	8b 45 08             	mov    0x8(%ebp),%eax
80105109:	8d 50 01             	lea    0x1(%eax),%edx
8010510c:	89 55 08             	mov    %edx,0x8(%ebp)
8010510f:	8b 55 0c             	mov    0xc(%ebp),%edx
80105112:	8d 4a 01             	lea    0x1(%edx),%ecx
80105115:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105118:	0f b6 12             	movzbl (%edx),%edx
8010511b:	88 10                	mov    %dl,(%eax)
8010511d:	0f b6 00             	movzbl (%eax),%eax
80105120:	84 c0                	test   %al,%al
80105122:	75 d8                	jne    801050fc <safestrcpy+0x17>
    ;
  *s = 0;
80105124:	8b 45 08             	mov    0x8(%ebp),%eax
80105127:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010512a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010512d:	c9                   	leave  
8010512e:	c3                   	ret    

8010512f <strlen>:

int
strlen(const char *s)
{
8010512f:	55                   	push   %ebp
80105130:	89 e5                	mov    %esp,%ebp
80105132:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105135:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010513c:	eb 04                	jmp    80105142 <strlen+0x13>
8010513e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105142:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105145:	8b 45 08             	mov    0x8(%ebp),%eax
80105148:	01 d0                	add    %edx,%eax
8010514a:	0f b6 00             	movzbl (%eax),%eax
8010514d:	84 c0                	test   %al,%al
8010514f:	75 ed                	jne    8010513e <strlen+0xf>
    ;
  return n;
80105151:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105154:	c9                   	leave  
80105155:	c3                   	ret    

80105156 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105156:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010515a:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
8010515e:	55                   	push   %ebp
  pushl %ebx
8010515f:	53                   	push   %ebx
  pushl %esi
80105160:	56                   	push   %esi
  pushl %edi
80105161:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105162:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105164:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105166:	5f                   	pop    %edi
  popl %esi
80105167:	5e                   	pop    %esi
  popl %ebx
80105168:	5b                   	pop    %ebx
  popl %ebp
80105169:	5d                   	pop    %ebp
  ret
8010516a:	c3                   	ret    

8010516b <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010516b:	55                   	push   %ebp
8010516c:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
8010516e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105174:	8b 00                	mov    (%eax),%eax
80105176:	3b 45 08             	cmp    0x8(%ebp),%eax
80105179:	76 12                	jbe    8010518d <fetchint+0x22>
8010517b:	8b 45 08             	mov    0x8(%ebp),%eax
8010517e:	8d 50 04             	lea    0x4(%eax),%edx
80105181:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105187:	8b 00                	mov    (%eax),%eax
80105189:	39 c2                	cmp    %eax,%edx
8010518b:	76 07                	jbe    80105194 <fetchint+0x29>
    return -1;
8010518d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105192:	eb 0f                	jmp    801051a3 <fetchint+0x38>
  *ip = *(int*)(addr);
80105194:	8b 45 08             	mov    0x8(%ebp),%eax
80105197:	8b 10                	mov    (%eax),%edx
80105199:	8b 45 0c             	mov    0xc(%ebp),%eax
8010519c:	89 10                	mov    %edx,(%eax)
  return 0;
8010519e:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051a3:	5d                   	pop    %ebp
801051a4:	c3                   	ret    

801051a5 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801051a5:	55                   	push   %ebp
801051a6:	89 e5                	mov    %esp,%ebp
801051a8:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801051ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051b1:	8b 00                	mov    (%eax),%eax
801051b3:	3b 45 08             	cmp    0x8(%ebp),%eax
801051b6:	77 07                	ja     801051bf <fetchstr+0x1a>
    return -1;
801051b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051bd:	eb 46                	jmp    80105205 <fetchstr+0x60>
  *pp = (char*)addr;
801051bf:	8b 55 08             	mov    0x8(%ebp),%edx
801051c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801051c5:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801051c7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051cd:	8b 00                	mov    (%eax),%eax
801051cf:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801051d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801051d5:	8b 00                	mov    (%eax),%eax
801051d7:	89 45 fc             	mov    %eax,-0x4(%ebp)
801051da:	eb 1c                	jmp    801051f8 <fetchstr+0x53>
    if(*s == 0)
801051dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051df:	0f b6 00             	movzbl (%eax),%eax
801051e2:	84 c0                	test   %al,%al
801051e4:	75 0e                	jne    801051f4 <fetchstr+0x4f>
      return s - *pp;
801051e6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801051e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801051ec:	8b 00                	mov    (%eax),%eax
801051ee:	29 c2                	sub    %eax,%edx
801051f0:	89 d0                	mov    %edx,%eax
801051f2:	eb 11                	jmp    80105205 <fetchstr+0x60>
  for(s = *pp; s < ep; s++)
801051f4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801051f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051fb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801051fe:	72 dc                	jb     801051dc <fetchstr+0x37>
  return -1;
80105200:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105205:	c9                   	leave  
80105206:	c3                   	ret    

80105207 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105207:	55                   	push   %ebp
80105208:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
8010520a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105210:	8b 40 18             	mov    0x18(%eax),%eax
80105213:	8b 40 44             	mov    0x44(%eax),%eax
80105216:	8b 55 08             	mov    0x8(%ebp),%edx
80105219:	c1 e2 02             	shl    $0x2,%edx
8010521c:	01 d0                	add    %edx,%eax
8010521e:	83 c0 04             	add    $0x4,%eax
80105221:	ff 75 0c             	pushl  0xc(%ebp)
80105224:	50                   	push   %eax
80105225:	e8 41 ff ff ff       	call   8010516b <fetchint>
8010522a:	83 c4 08             	add    $0x8,%esp
}
8010522d:	c9                   	leave  
8010522e:	c3                   	ret    

8010522f <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010522f:	55                   	push   %ebp
80105230:	89 e5                	mov    %esp,%ebp
80105232:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105235:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105238:	50                   	push   %eax
80105239:	ff 75 08             	pushl  0x8(%ebp)
8010523c:	e8 c6 ff ff ff       	call   80105207 <argint>
80105241:	83 c4 08             	add    $0x8,%esp
80105244:	85 c0                	test   %eax,%eax
80105246:	79 07                	jns    8010524f <argptr+0x20>
    return -1;
80105248:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010524d:	eb 3b                	jmp    8010528a <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
8010524f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105255:	8b 00                	mov    (%eax),%eax
80105257:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010525a:	39 d0                	cmp    %edx,%eax
8010525c:	76 16                	jbe    80105274 <argptr+0x45>
8010525e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105261:	89 c2                	mov    %eax,%edx
80105263:	8b 45 10             	mov    0x10(%ebp),%eax
80105266:	01 c2                	add    %eax,%edx
80105268:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010526e:	8b 00                	mov    (%eax),%eax
80105270:	39 c2                	cmp    %eax,%edx
80105272:	76 07                	jbe    8010527b <argptr+0x4c>
    return -1;
80105274:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105279:	eb 0f                	jmp    8010528a <argptr+0x5b>
  *pp = (char*)i;
8010527b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010527e:	89 c2                	mov    %eax,%edx
80105280:	8b 45 0c             	mov    0xc(%ebp),%eax
80105283:	89 10                	mov    %edx,(%eax)
  return 0;
80105285:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010528a:	c9                   	leave  
8010528b:	c3                   	ret    

8010528c <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010528c:	55                   	push   %ebp
8010528d:	89 e5                	mov    %esp,%ebp
8010528f:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105292:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105295:	50                   	push   %eax
80105296:	ff 75 08             	pushl  0x8(%ebp)
80105299:	e8 69 ff ff ff       	call   80105207 <argint>
8010529e:	83 c4 08             	add    $0x8,%esp
801052a1:	85 c0                	test   %eax,%eax
801052a3:	79 07                	jns    801052ac <argstr+0x20>
    return -1;
801052a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052aa:	eb 0f                	jmp    801052bb <argstr+0x2f>
  return fetchstr(addr, pp);
801052ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052af:	ff 75 0c             	pushl  0xc(%ebp)
801052b2:	50                   	push   %eax
801052b3:	e8 ed fe ff ff       	call   801051a5 <fetchstr>
801052b8:	83 c4 08             	add    $0x8,%esp
}
801052bb:	c9                   	leave  
801052bc:	c3                   	ret    

801052bd <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
801052bd:	55                   	push   %ebp
801052be:	89 e5                	mov    %esp,%ebp
801052c0:	53                   	push   %ebx
801052c1:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
801052c4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052ca:	8b 40 18             	mov    0x18(%eax),%eax
801052cd:	8b 40 1c             	mov    0x1c(%eax),%eax
801052d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801052d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052d7:	7e 30                	jle    80105309 <syscall+0x4c>
801052d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052dc:	83 f8 15             	cmp    $0x15,%eax
801052df:	77 28                	ja     80105309 <syscall+0x4c>
801052e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052e4:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801052eb:	85 c0                	test   %eax,%eax
801052ed:	74 1a                	je     80105309 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
801052ef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052f5:	8b 58 18             	mov    0x18(%eax),%ebx
801052f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052fb:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105302:	ff d0                	call   *%eax
80105304:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105307:	eb 34                	jmp    8010533d <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105309:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010530f:	8d 50 6c             	lea    0x6c(%eax),%edx
80105312:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
    cprintf("%d %s: unknown sys call %d\n",
80105318:	8b 40 10             	mov    0x10(%eax),%eax
8010531b:	ff 75 f4             	pushl  -0xc(%ebp)
8010531e:	52                   	push   %edx
8010531f:	50                   	push   %eax
80105320:	68 90 85 10 80       	push   $0x80108590
80105325:	e8 9c b0 ff ff       	call   801003c6 <cprintf>
8010532a:	83 c4 10             	add    $0x10,%esp
    proc->tf->eax = -1;
8010532d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105333:	8b 40 18             	mov    0x18(%eax),%eax
80105336:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010533d:	90                   	nop
8010533e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105341:	c9                   	leave  
80105342:	c3                   	ret    

80105343 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105343:	55                   	push   %ebp
80105344:	89 e5                	mov    %esp,%ebp
80105346:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105349:	83 ec 08             	sub    $0x8,%esp
8010534c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010534f:	50                   	push   %eax
80105350:	ff 75 08             	pushl  0x8(%ebp)
80105353:	e8 af fe ff ff       	call   80105207 <argint>
80105358:	83 c4 10             	add    $0x10,%esp
8010535b:	85 c0                	test   %eax,%eax
8010535d:	79 07                	jns    80105366 <argfd+0x23>
    return -1;
8010535f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105364:	eb 50                	jmp    801053b6 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105366:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105369:	85 c0                	test   %eax,%eax
8010536b:	78 21                	js     8010538e <argfd+0x4b>
8010536d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105370:	83 f8 0f             	cmp    $0xf,%eax
80105373:	7f 19                	jg     8010538e <argfd+0x4b>
80105375:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010537b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010537e:	83 c2 08             	add    $0x8,%edx
80105381:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105385:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105388:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010538c:	75 07                	jne    80105395 <argfd+0x52>
    return -1;
8010538e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105393:	eb 21                	jmp    801053b6 <argfd+0x73>
  if(pfd)
80105395:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105399:	74 08                	je     801053a3 <argfd+0x60>
    *pfd = fd;
8010539b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010539e:	8b 45 0c             	mov    0xc(%ebp),%eax
801053a1:	89 10                	mov    %edx,(%eax)
  if(pf)
801053a3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801053a7:	74 08                	je     801053b1 <argfd+0x6e>
    *pf = f;
801053a9:	8b 45 10             	mov    0x10(%ebp),%eax
801053ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
801053af:	89 10                	mov    %edx,(%eax)
  return 0;
801053b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053b6:	c9                   	leave  
801053b7:	c3                   	ret    

801053b8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801053b8:	55                   	push   %ebp
801053b9:	89 e5                	mov    %esp,%ebp
801053bb:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801053be:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801053c5:	eb 30                	jmp    801053f7 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
801053c7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053cd:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053d0:	83 c2 08             	add    $0x8,%edx
801053d3:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801053d7:	85 c0                	test   %eax,%eax
801053d9:	75 18                	jne    801053f3 <fdalloc+0x3b>
      proc->ofile[fd] = f;
801053db:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053e1:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053e4:	8d 4a 08             	lea    0x8(%edx),%ecx
801053e7:	8b 55 08             	mov    0x8(%ebp),%edx
801053ea:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801053ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053f1:	eb 0f                	jmp    80105402 <fdalloc+0x4a>
  for(fd = 0; fd < NOFILE; fd++){
801053f3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801053f7:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801053fb:	7e ca                	jle    801053c7 <fdalloc+0xf>
    }
  }
  return -1;
801053fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105402:	c9                   	leave  
80105403:	c3                   	ret    

80105404 <sys_dup>:

int
sys_dup(void)
{
80105404:	55                   	push   %ebp
80105405:	89 e5                	mov    %esp,%ebp
80105407:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
8010540a:	83 ec 04             	sub    $0x4,%esp
8010540d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105410:	50                   	push   %eax
80105411:	6a 00                	push   $0x0
80105413:	6a 00                	push   $0x0
80105415:	e8 29 ff ff ff       	call   80105343 <argfd>
8010541a:	83 c4 10             	add    $0x10,%esp
8010541d:	85 c0                	test   %eax,%eax
8010541f:	79 07                	jns    80105428 <sys_dup+0x24>
    return -1;
80105421:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105426:	eb 31                	jmp    80105459 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105428:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010542b:	83 ec 0c             	sub    $0xc,%esp
8010542e:	50                   	push   %eax
8010542f:	e8 84 ff ff ff       	call   801053b8 <fdalloc>
80105434:	83 c4 10             	add    $0x10,%esp
80105437:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010543a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010543e:	79 07                	jns    80105447 <sys_dup+0x43>
    return -1;
80105440:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105445:	eb 12                	jmp    80105459 <sys_dup+0x55>
  filedup(f);
80105447:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010544a:	83 ec 0c             	sub    $0xc,%esp
8010544d:	50                   	push   %eax
8010544e:	e8 7e bb ff ff       	call   80100fd1 <filedup>
80105453:	83 c4 10             	add    $0x10,%esp
  return fd;
80105456:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105459:	c9                   	leave  
8010545a:	c3                   	ret    

8010545b <sys_read>:

int
sys_read(void)
{
8010545b:	55                   	push   %ebp
8010545c:	89 e5                	mov    %esp,%ebp
8010545e:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105461:	83 ec 04             	sub    $0x4,%esp
80105464:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105467:	50                   	push   %eax
80105468:	6a 00                	push   $0x0
8010546a:	6a 00                	push   $0x0
8010546c:	e8 d2 fe ff ff       	call   80105343 <argfd>
80105471:	83 c4 10             	add    $0x10,%esp
80105474:	85 c0                	test   %eax,%eax
80105476:	78 2e                	js     801054a6 <sys_read+0x4b>
80105478:	83 ec 08             	sub    $0x8,%esp
8010547b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010547e:	50                   	push   %eax
8010547f:	6a 02                	push   $0x2
80105481:	e8 81 fd ff ff       	call   80105207 <argint>
80105486:	83 c4 10             	add    $0x10,%esp
80105489:	85 c0                	test   %eax,%eax
8010548b:	78 19                	js     801054a6 <sys_read+0x4b>
8010548d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105490:	83 ec 04             	sub    $0x4,%esp
80105493:	50                   	push   %eax
80105494:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105497:	50                   	push   %eax
80105498:	6a 01                	push   $0x1
8010549a:	e8 90 fd ff ff       	call   8010522f <argptr>
8010549f:	83 c4 10             	add    $0x10,%esp
801054a2:	85 c0                	test   %eax,%eax
801054a4:	79 07                	jns    801054ad <sys_read+0x52>
    return -1;
801054a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054ab:	eb 17                	jmp    801054c4 <sys_read+0x69>
  return fileread(f, p, n);
801054ad:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801054b0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801054b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054b6:	83 ec 04             	sub    $0x4,%esp
801054b9:	51                   	push   %ecx
801054ba:	52                   	push   %edx
801054bb:	50                   	push   %eax
801054bc:	e8 a0 bc ff ff       	call   80101161 <fileread>
801054c1:	83 c4 10             	add    $0x10,%esp
}
801054c4:	c9                   	leave  
801054c5:	c3                   	ret    

801054c6 <sys_write>:

int
sys_write(void)
{
801054c6:	55                   	push   %ebp
801054c7:	89 e5                	mov    %esp,%ebp
801054c9:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801054cc:	83 ec 04             	sub    $0x4,%esp
801054cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
801054d2:	50                   	push   %eax
801054d3:	6a 00                	push   $0x0
801054d5:	6a 00                	push   $0x0
801054d7:	e8 67 fe ff ff       	call   80105343 <argfd>
801054dc:	83 c4 10             	add    $0x10,%esp
801054df:	85 c0                	test   %eax,%eax
801054e1:	78 2e                	js     80105511 <sys_write+0x4b>
801054e3:	83 ec 08             	sub    $0x8,%esp
801054e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054e9:	50                   	push   %eax
801054ea:	6a 02                	push   $0x2
801054ec:	e8 16 fd ff ff       	call   80105207 <argint>
801054f1:	83 c4 10             	add    $0x10,%esp
801054f4:	85 c0                	test   %eax,%eax
801054f6:	78 19                	js     80105511 <sys_write+0x4b>
801054f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054fb:	83 ec 04             	sub    $0x4,%esp
801054fe:	50                   	push   %eax
801054ff:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105502:	50                   	push   %eax
80105503:	6a 01                	push   $0x1
80105505:	e8 25 fd ff ff       	call   8010522f <argptr>
8010550a:	83 c4 10             	add    $0x10,%esp
8010550d:	85 c0                	test   %eax,%eax
8010550f:	79 07                	jns    80105518 <sys_write+0x52>
    return -1;
80105511:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105516:	eb 17                	jmp    8010552f <sys_write+0x69>
  return filewrite(f, p, n);
80105518:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010551b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010551e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105521:	83 ec 04             	sub    $0x4,%esp
80105524:	51                   	push   %ecx
80105525:	52                   	push   %edx
80105526:	50                   	push   %eax
80105527:	e8 ed bc ff ff       	call   80101219 <filewrite>
8010552c:	83 c4 10             	add    $0x10,%esp
}
8010552f:	c9                   	leave  
80105530:	c3                   	ret    

80105531 <sys_close>:

int
sys_close(void)
{
80105531:	55                   	push   %ebp
80105532:	89 e5                	mov    %esp,%ebp
80105534:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105537:	83 ec 04             	sub    $0x4,%esp
8010553a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010553d:	50                   	push   %eax
8010553e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105541:	50                   	push   %eax
80105542:	6a 00                	push   $0x0
80105544:	e8 fa fd ff ff       	call   80105343 <argfd>
80105549:	83 c4 10             	add    $0x10,%esp
8010554c:	85 c0                	test   %eax,%eax
8010554e:	79 07                	jns    80105557 <sys_close+0x26>
    return -1;
80105550:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105555:	eb 28                	jmp    8010557f <sys_close+0x4e>
  proc->ofile[fd] = 0;
80105557:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010555d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105560:	83 c2 08             	add    $0x8,%edx
80105563:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010556a:	00 
  fileclose(f);
8010556b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010556e:	83 ec 0c             	sub    $0xc,%esp
80105571:	50                   	push   %eax
80105572:	e8 ab ba ff ff       	call   80101022 <fileclose>
80105577:	83 c4 10             	add    $0x10,%esp
  return 0;
8010557a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010557f:	c9                   	leave  
80105580:	c3                   	ret    

80105581 <sys_fstat>:

int
sys_fstat(void)
{
80105581:	55                   	push   %ebp
80105582:	89 e5                	mov    %esp,%ebp
80105584:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105587:	83 ec 04             	sub    $0x4,%esp
8010558a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010558d:	50                   	push   %eax
8010558e:	6a 00                	push   $0x0
80105590:	6a 00                	push   $0x0
80105592:	e8 ac fd ff ff       	call   80105343 <argfd>
80105597:	83 c4 10             	add    $0x10,%esp
8010559a:	85 c0                	test   %eax,%eax
8010559c:	78 17                	js     801055b5 <sys_fstat+0x34>
8010559e:	83 ec 04             	sub    $0x4,%esp
801055a1:	6a 14                	push   $0x14
801055a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801055a6:	50                   	push   %eax
801055a7:	6a 01                	push   $0x1
801055a9:	e8 81 fc ff ff       	call   8010522f <argptr>
801055ae:	83 c4 10             	add    $0x10,%esp
801055b1:	85 c0                	test   %eax,%eax
801055b3:	79 07                	jns    801055bc <sys_fstat+0x3b>
    return -1;
801055b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055ba:	eb 13                	jmp    801055cf <sys_fstat+0x4e>
  return filestat(f, st);
801055bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801055bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055c2:	83 ec 08             	sub    $0x8,%esp
801055c5:	52                   	push   %edx
801055c6:	50                   	push   %eax
801055c7:	e8 3e bb ff ff       	call   8010110a <filestat>
801055cc:	83 c4 10             	add    $0x10,%esp
}
801055cf:	c9                   	leave  
801055d0:	c3                   	ret    

801055d1 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801055d1:	55                   	push   %ebp
801055d2:	89 e5                	mov    %esp,%ebp
801055d4:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801055d7:	83 ec 08             	sub    $0x8,%esp
801055da:	8d 45 d8             	lea    -0x28(%ebp),%eax
801055dd:	50                   	push   %eax
801055de:	6a 00                	push   $0x0
801055e0:	e8 a7 fc ff ff       	call   8010528c <argstr>
801055e5:	83 c4 10             	add    $0x10,%esp
801055e8:	85 c0                	test   %eax,%eax
801055ea:	78 15                	js     80105601 <sys_link+0x30>
801055ec:	83 ec 08             	sub    $0x8,%esp
801055ef:	8d 45 dc             	lea    -0x24(%ebp),%eax
801055f2:	50                   	push   %eax
801055f3:	6a 01                	push   $0x1
801055f5:	e8 92 fc ff ff       	call   8010528c <argstr>
801055fa:	83 c4 10             	add    $0x10,%esp
801055fd:	85 c0                	test   %eax,%eax
801055ff:	79 0a                	jns    8010560b <sys_link+0x3a>
    return -1;
80105601:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105606:	e9 63 01 00 00       	jmp    8010576e <sys_link+0x19d>
  if((ip = namei(old)) == 0)
8010560b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010560e:	83 ec 0c             	sub    $0xc,%esp
80105611:	50                   	push   %eax
80105612:	e8 98 ce ff ff       	call   801024af <namei>
80105617:	83 c4 10             	add    $0x10,%esp
8010561a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010561d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105621:	75 0a                	jne    8010562d <sys_link+0x5c>
    return -1;
80105623:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105628:	e9 41 01 00 00       	jmp    8010576e <sys_link+0x19d>

  begin_trans();
8010562d:	e8 49 dc ff ff       	call   8010327b <begin_trans>

  ilock(ip);
80105632:	83 ec 0c             	sub    $0xc,%esp
80105635:	ff 75 f4             	pushl  -0xc(%ebp)
80105638:	e8 ba c2 ff ff       	call   801018f7 <ilock>
8010563d:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105640:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105643:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105647:	66 83 f8 01          	cmp    $0x1,%ax
8010564b:	75 1d                	jne    8010566a <sys_link+0x99>
    iunlockput(ip);
8010564d:	83 ec 0c             	sub    $0xc,%esp
80105650:	ff 75 f4             	pushl  -0xc(%ebp)
80105653:	e8 59 c5 ff ff       	call   80101bb1 <iunlockput>
80105658:	83 c4 10             	add    $0x10,%esp
    commit_trans();
8010565b:	e8 6e dc ff ff       	call   801032ce <commit_trans>
    return -1;
80105660:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105665:	e9 04 01 00 00       	jmp    8010576e <sys_link+0x19d>
  }

  ip->nlink++;
8010566a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010566d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105671:	83 c0 01             	add    $0x1,%eax
80105674:	89 c2                	mov    %eax,%edx
80105676:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105679:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010567d:	83 ec 0c             	sub    $0xc,%esp
80105680:	ff 75 f4             	pushl  -0xc(%ebp)
80105683:	e8 9b c0 ff ff       	call   80101723 <iupdate>
80105688:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
8010568b:	83 ec 0c             	sub    $0xc,%esp
8010568e:	ff 75 f4             	pushl  -0xc(%ebp)
80105691:	e8 b9 c3 ff ff       	call   80101a4f <iunlock>
80105696:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105699:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010569c:	83 ec 08             	sub    $0x8,%esp
8010569f:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801056a2:	52                   	push   %edx
801056a3:	50                   	push   %eax
801056a4:	e8 22 ce ff ff       	call   801024cb <nameiparent>
801056a9:	83 c4 10             	add    $0x10,%esp
801056ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
801056af:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801056b3:	74 71                	je     80105726 <sys_link+0x155>
    goto bad;
  ilock(dp);
801056b5:	83 ec 0c             	sub    $0xc,%esp
801056b8:	ff 75 f0             	pushl  -0x10(%ebp)
801056bb:	e8 37 c2 ff ff       	call   801018f7 <ilock>
801056c0:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801056c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056c6:	8b 10                	mov    (%eax),%edx
801056c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056cb:	8b 00                	mov    (%eax),%eax
801056cd:	39 c2                	cmp    %eax,%edx
801056cf:	75 1d                	jne    801056ee <sys_link+0x11d>
801056d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056d4:	8b 40 04             	mov    0x4(%eax),%eax
801056d7:	83 ec 04             	sub    $0x4,%esp
801056da:	50                   	push   %eax
801056db:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801056de:	50                   	push   %eax
801056df:	ff 75 f0             	pushl  -0x10(%ebp)
801056e2:	e8 2c cb ff ff       	call   80102213 <dirlink>
801056e7:	83 c4 10             	add    $0x10,%esp
801056ea:	85 c0                	test   %eax,%eax
801056ec:	79 10                	jns    801056fe <sys_link+0x12d>
    iunlockput(dp);
801056ee:	83 ec 0c             	sub    $0xc,%esp
801056f1:	ff 75 f0             	pushl  -0x10(%ebp)
801056f4:	e8 b8 c4 ff ff       	call   80101bb1 <iunlockput>
801056f9:	83 c4 10             	add    $0x10,%esp
    goto bad;
801056fc:	eb 29                	jmp    80105727 <sys_link+0x156>
  }
  iunlockput(dp);
801056fe:	83 ec 0c             	sub    $0xc,%esp
80105701:	ff 75 f0             	pushl  -0x10(%ebp)
80105704:	e8 a8 c4 ff ff       	call   80101bb1 <iunlockput>
80105709:	83 c4 10             	add    $0x10,%esp
  iput(ip);
8010570c:	83 ec 0c             	sub    $0xc,%esp
8010570f:	ff 75 f4             	pushl  -0xc(%ebp)
80105712:	e8 aa c3 ff ff       	call   80101ac1 <iput>
80105717:	83 c4 10             	add    $0x10,%esp

  commit_trans();
8010571a:	e8 af db ff ff       	call   801032ce <commit_trans>

  return 0;
8010571f:	b8 00 00 00 00       	mov    $0x0,%eax
80105724:	eb 48                	jmp    8010576e <sys_link+0x19d>
    goto bad;
80105726:	90                   	nop

bad:
  ilock(ip);
80105727:	83 ec 0c             	sub    $0xc,%esp
8010572a:	ff 75 f4             	pushl  -0xc(%ebp)
8010572d:	e8 c5 c1 ff ff       	call   801018f7 <ilock>
80105732:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105735:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105738:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010573c:	83 e8 01             	sub    $0x1,%eax
8010573f:	89 c2                	mov    %eax,%edx
80105741:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105744:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105748:	83 ec 0c             	sub    $0xc,%esp
8010574b:	ff 75 f4             	pushl  -0xc(%ebp)
8010574e:	e8 d0 bf ff ff       	call   80101723 <iupdate>
80105753:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105756:	83 ec 0c             	sub    $0xc,%esp
80105759:	ff 75 f4             	pushl  -0xc(%ebp)
8010575c:	e8 50 c4 ff ff       	call   80101bb1 <iunlockput>
80105761:	83 c4 10             	add    $0x10,%esp
  commit_trans();
80105764:	e8 65 db ff ff       	call   801032ce <commit_trans>
  return -1;
80105769:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010576e:	c9                   	leave  
8010576f:	c3                   	ret    

80105770 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105770:	55                   	push   %ebp
80105771:	89 e5                	mov    %esp,%ebp
80105773:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105776:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010577d:	eb 40                	jmp    801057bf <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010577f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105782:	6a 10                	push   $0x10
80105784:	50                   	push   %eax
80105785:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105788:	50                   	push   %eax
80105789:	ff 75 08             	pushl  0x8(%ebp)
8010578c:	e8 ce c6 ff ff       	call   80101e5f <readi>
80105791:	83 c4 10             	add    $0x10,%esp
80105794:	83 f8 10             	cmp    $0x10,%eax
80105797:	74 0d                	je     801057a6 <isdirempty+0x36>
      panic("isdirempty: readi");
80105799:	83 ec 0c             	sub    $0xc,%esp
8010579c:	68 ac 85 10 80       	push   $0x801085ac
801057a1:	e8 c0 ad ff ff       	call   80100566 <panic>
    if(de.inum != 0)
801057a6:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801057aa:	66 85 c0             	test   %ax,%ax
801057ad:	74 07                	je     801057b6 <isdirempty+0x46>
      return 0;
801057af:	b8 00 00 00 00       	mov    $0x0,%eax
801057b4:	eb 1b                	jmp    801057d1 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801057b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057b9:	83 c0 10             	add    $0x10,%eax
801057bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057bf:	8b 45 08             	mov    0x8(%ebp),%eax
801057c2:	8b 50 18             	mov    0x18(%eax),%edx
801057c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057c8:	39 c2                	cmp    %eax,%edx
801057ca:	77 b3                	ja     8010577f <isdirempty+0xf>
  }
  return 1;
801057cc:	b8 01 00 00 00       	mov    $0x1,%eax
}
801057d1:	c9                   	leave  
801057d2:	c3                   	ret    

801057d3 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801057d3:	55                   	push   %ebp
801057d4:	89 e5                	mov    %esp,%ebp
801057d6:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801057d9:	83 ec 08             	sub    $0x8,%esp
801057dc:	8d 45 cc             	lea    -0x34(%ebp),%eax
801057df:	50                   	push   %eax
801057e0:	6a 00                	push   $0x0
801057e2:	e8 a5 fa ff ff       	call   8010528c <argstr>
801057e7:	83 c4 10             	add    $0x10,%esp
801057ea:	85 c0                	test   %eax,%eax
801057ec:	79 0a                	jns    801057f8 <sys_unlink+0x25>
    return -1;
801057ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057f3:	e9 b7 01 00 00       	jmp    801059af <sys_unlink+0x1dc>
  if((dp = nameiparent(path, name)) == 0)
801057f8:	8b 45 cc             	mov    -0x34(%ebp),%eax
801057fb:	83 ec 08             	sub    $0x8,%esp
801057fe:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105801:	52                   	push   %edx
80105802:	50                   	push   %eax
80105803:	e8 c3 cc ff ff       	call   801024cb <nameiparent>
80105808:	83 c4 10             	add    $0x10,%esp
8010580b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010580e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105812:	75 0a                	jne    8010581e <sys_unlink+0x4b>
    return -1;
80105814:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105819:	e9 91 01 00 00       	jmp    801059af <sys_unlink+0x1dc>

  begin_trans();
8010581e:	e8 58 da ff ff       	call   8010327b <begin_trans>

  ilock(dp);
80105823:	83 ec 0c             	sub    $0xc,%esp
80105826:	ff 75 f4             	pushl  -0xc(%ebp)
80105829:	e8 c9 c0 ff ff       	call   801018f7 <ilock>
8010582e:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105831:	83 ec 08             	sub    $0x8,%esp
80105834:	68 be 85 10 80       	push   $0x801085be
80105839:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010583c:	50                   	push   %eax
8010583d:	e8 fc c8 ff ff       	call   8010213e <namecmp>
80105842:	83 c4 10             	add    $0x10,%esp
80105845:	85 c0                	test   %eax,%eax
80105847:	0f 84 4a 01 00 00    	je     80105997 <sys_unlink+0x1c4>
8010584d:	83 ec 08             	sub    $0x8,%esp
80105850:	68 c0 85 10 80       	push   $0x801085c0
80105855:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105858:	50                   	push   %eax
80105859:	e8 e0 c8 ff ff       	call   8010213e <namecmp>
8010585e:	83 c4 10             	add    $0x10,%esp
80105861:	85 c0                	test   %eax,%eax
80105863:	0f 84 2e 01 00 00    	je     80105997 <sys_unlink+0x1c4>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105869:	83 ec 04             	sub    $0x4,%esp
8010586c:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010586f:	50                   	push   %eax
80105870:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105873:	50                   	push   %eax
80105874:	ff 75 f4             	pushl  -0xc(%ebp)
80105877:	e8 dd c8 ff ff       	call   80102159 <dirlookup>
8010587c:	83 c4 10             	add    $0x10,%esp
8010587f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105882:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105886:	0f 84 0a 01 00 00    	je     80105996 <sys_unlink+0x1c3>
    goto bad;
  ilock(ip);
8010588c:	83 ec 0c             	sub    $0xc,%esp
8010588f:	ff 75 f0             	pushl  -0x10(%ebp)
80105892:	e8 60 c0 ff ff       	call   801018f7 <ilock>
80105897:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
8010589a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010589d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801058a1:	66 85 c0             	test   %ax,%ax
801058a4:	7f 0d                	jg     801058b3 <sys_unlink+0xe0>
    panic("unlink: nlink < 1");
801058a6:	83 ec 0c             	sub    $0xc,%esp
801058a9:	68 c3 85 10 80       	push   $0x801085c3
801058ae:	e8 b3 ac ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801058b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058b6:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801058ba:	66 83 f8 01          	cmp    $0x1,%ax
801058be:	75 25                	jne    801058e5 <sys_unlink+0x112>
801058c0:	83 ec 0c             	sub    $0xc,%esp
801058c3:	ff 75 f0             	pushl  -0x10(%ebp)
801058c6:	e8 a5 fe ff ff       	call   80105770 <isdirempty>
801058cb:	83 c4 10             	add    $0x10,%esp
801058ce:	85 c0                	test   %eax,%eax
801058d0:	75 13                	jne    801058e5 <sys_unlink+0x112>
    iunlockput(ip);
801058d2:	83 ec 0c             	sub    $0xc,%esp
801058d5:	ff 75 f0             	pushl  -0x10(%ebp)
801058d8:	e8 d4 c2 ff ff       	call   80101bb1 <iunlockput>
801058dd:	83 c4 10             	add    $0x10,%esp
    goto bad;
801058e0:	e9 b2 00 00 00       	jmp    80105997 <sys_unlink+0x1c4>
  }

  memset(&de, 0, sizeof(de));
801058e5:	83 ec 04             	sub    $0x4,%esp
801058e8:	6a 10                	push   $0x10
801058ea:	6a 00                	push   $0x0
801058ec:	8d 45 e0             	lea    -0x20(%ebp),%eax
801058ef:	50                   	push   %eax
801058f0:	e8 ed f5 ff ff       	call   80104ee2 <memset>
801058f5:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801058f8:	8b 45 c8             	mov    -0x38(%ebp),%eax
801058fb:	6a 10                	push   $0x10
801058fd:	50                   	push   %eax
801058fe:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105901:	50                   	push   %eax
80105902:	ff 75 f4             	pushl  -0xc(%ebp)
80105905:	e8 ac c6 ff ff       	call   80101fb6 <writei>
8010590a:	83 c4 10             	add    $0x10,%esp
8010590d:	83 f8 10             	cmp    $0x10,%eax
80105910:	74 0d                	je     8010591f <sys_unlink+0x14c>
    panic("unlink: writei");
80105912:	83 ec 0c             	sub    $0xc,%esp
80105915:	68 d5 85 10 80       	push   $0x801085d5
8010591a:	e8 47 ac ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
8010591f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105922:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105926:	66 83 f8 01          	cmp    $0x1,%ax
8010592a:	75 21                	jne    8010594d <sys_unlink+0x17a>
    dp->nlink--;
8010592c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010592f:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105933:	83 e8 01             	sub    $0x1,%eax
80105936:	89 c2                	mov    %eax,%edx
80105938:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010593b:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
8010593f:	83 ec 0c             	sub    $0xc,%esp
80105942:	ff 75 f4             	pushl  -0xc(%ebp)
80105945:	e8 d9 bd ff ff       	call   80101723 <iupdate>
8010594a:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
8010594d:	83 ec 0c             	sub    $0xc,%esp
80105950:	ff 75 f4             	pushl  -0xc(%ebp)
80105953:	e8 59 c2 ff ff       	call   80101bb1 <iunlockput>
80105958:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
8010595b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010595e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105962:	83 e8 01             	sub    $0x1,%eax
80105965:	89 c2                	mov    %eax,%edx
80105967:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010596a:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010596e:	83 ec 0c             	sub    $0xc,%esp
80105971:	ff 75 f0             	pushl  -0x10(%ebp)
80105974:	e8 aa bd ff ff       	call   80101723 <iupdate>
80105979:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010597c:	83 ec 0c             	sub    $0xc,%esp
8010597f:	ff 75 f0             	pushl  -0x10(%ebp)
80105982:	e8 2a c2 ff ff       	call   80101bb1 <iunlockput>
80105987:	83 c4 10             	add    $0x10,%esp

  commit_trans();
8010598a:	e8 3f d9 ff ff       	call   801032ce <commit_trans>

  return 0;
8010598f:	b8 00 00 00 00       	mov    $0x0,%eax
80105994:	eb 19                	jmp    801059af <sys_unlink+0x1dc>
    goto bad;
80105996:	90                   	nop

bad:
  iunlockput(dp);
80105997:	83 ec 0c             	sub    $0xc,%esp
8010599a:	ff 75 f4             	pushl  -0xc(%ebp)
8010599d:	e8 0f c2 ff ff       	call   80101bb1 <iunlockput>
801059a2:	83 c4 10             	add    $0x10,%esp
  commit_trans();
801059a5:	e8 24 d9 ff ff       	call   801032ce <commit_trans>
  return -1;
801059aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801059af:	c9                   	leave  
801059b0:	c3                   	ret    

801059b1 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801059b1:	55                   	push   %ebp
801059b2:	89 e5                	mov    %esp,%ebp
801059b4:	83 ec 38             	sub    $0x38,%esp
801059b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801059ba:	8b 55 10             	mov    0x10(%ebp),%edx
801059bd:	8b 45 14             	mov    0x14(%ebp),%eax
801059c0:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801059c4:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801059c8:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801059cc:	83 ec 08             	sub    $0x8,%esp
801059cf:	8d 45 de             	lea    -0x22(%ebp),%eax
801059d2:	50                   	push   %eax
801059d3:	ff 75 08             	pushl  0x8(%ebp)
801059d6:	e8 f0 ca ff ff       	call   801024cb <nameiparent>
801059db:	83 c4 10             	add    $0x10,%esp
801059de:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059e5:	75 0a                	jne    801059f1 <create+0x40>
    return 0;
801059e7:	b8 00 00 00 00       	mov    $0x0,%eax
801059ec:	e9 90 01 00 00       	jmp    80105b81 <create+0x1d0>
  ilock(dp);
801059f1:	83 ec 0c             	sub    $0xc,%esp
801059f4:	ff 75 f4             	pushl  -0xc(%ebp)
801059f7:	e8 fb be ff ff       	call   801018f7 <ilock>
801059fc:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801059ff:	83 ec 04             	sub    $0x4,%esp
80105a02:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a05:	50                   	push   %eax
80105a06:	8d 45 de             	lea    -0x22(%ebp),%eax
80105a09:	50                   	push   %eax
80105a0a:	ff 75 f4             	pushl  -0xc(%ebp)
80105a0d:	e8 47 c7 ff ff       	call   80102159 <dirlookup>
80105a12:	83 c4 10             	add    $0x10,%esp
80105a15:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a18:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a1c:	74 50                	je     80105a6e <create+0xbd>
    iunlockput(dp);
80105a1e:	83 ec 0c             	sub    $0xc,%esp
80105a21:	ff 75 f4             	pushl  -0xc(%ebp)
80105a24:	e8 88 c1 ff ff       	call   80101bb1 <iunlockput>
80105a29:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105a2c:	83 ec 0c             	sub    $0xc,%esp
80105a2f:	ff 75 f0             	pushl  -0x10(%ebp)
80105a32:	e8 c0 be ff ff       	call   801018f7 <ilock>
80105a37:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105a3a:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105a3f:	75 15                	jne    80105a56 <create+0xa5>
80105a41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a44:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105a48:	66 83 f8 02          	cmp    $0x2,%ax
80105a4c:	75 08                	jne    80105a56 <create+0xa5>
      return ip;
80105a4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a51:	e9 2b 01 00 00       	jmp    80105b81 <create+0x1d0>
    iunlockput(ip);
80105a56:	83 ec 0c             	sub    $0xc,%esp
80105a59:	ff 75 f0             	pushl  -0x10(%ebp)
80105a5c:	e8 50 c1 ff ff       	call   80101bb1 <iunlockput>
80105a61:	83 c4 10             	add    $0x10,%esp
    return 0;
80105a64:	b8 00 00 00 00       	mov    $0x0,%eax
80105a69:	e9 13 01 00 00       	jmp    80105b81 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105a6e:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a75:	8b 00                	mov    (%eax),%eax
80105a77:	83 ec 08             	sub    $0x8,%esp
80105a7a:	52                   	push   %edx
80105a7b:	50                   	push   %eax
80105a7c:	e8 c1 bb ff ff       	call   80101642 <ialloc>
80105a81:	83 c4 10             	add    $0x10,%esp
80105a84:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a87:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a8b:	75 0d                	jne    80105a9a <create+0xe9>
    panic("create: ialloc");
80105a8d:	83 ec 0c             	sub    $0xc,%esp
80105a90:	68 e4 85 10 80       	push   $0x801085e4
80105a95:	e8 cc aa ff ff       	call   80100566 <panic>

  ilock(ip);
80105a9a:	83 ec 0c             	sub    $0xc,%esp
80105a9d:	ff 75 f0             	pushl  -0x10(%ebp)
80105aa0:	e8 52 be ff ff       	call   801018f7 <ilock>
80105aa5:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105aa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aab:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105aaf:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105ab3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ab6:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105aba:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105abe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ac1:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105ac7:	83 ec 0c             	sub    $0xc,%esp
80105aca:	ff 75 f0             	pushl  -0x10(%ebp)
80105acd:	e8 51 bc ff ff       	call   80101723 <iupdate>
80105ad2:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105ad5:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105ada:	75 6a                	jne    80105b46 <create+0x195>
    dp->nlink++;  // for ".."
80105adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105adf:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ae3:	83 c0 01             	add    $0x1,%eax
80105ae6:	89 c2                	mov    %eax,%edx
80105ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aeb:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105aef:	83 ec 0c             	sub    $0xc,%esp
80105af2:	ff 75 f4             	pushl  -0xc(%ebp)
80105af5:	e8 29 bc ff ff       	call   80101723 <iupdate>
80105afa:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105afd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b00:	8b 40 04             	mov    0x4(%eax),%eax
80105b03:	83 ec 04             	sub    $0x4,%esp
80105b06:	50                   	push   %eax
80105b07:	68 be 85 10 80       	push   $0x801085be
80105b0c:	ff 75 f0             	pushl  -0x10(%ebp)
80105b0f:	e8 ff c6 ff ff       	call   80102213 <dirlink>
80105b14:	83 c4 10             	add    $0x10,%esp
80105b17:	85 c0                	test   %eax,%eax
80105b19:	78 1e                	js     80105b39 <create+0x188>
80105b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b1e:	8b 40 04             	mov    0x4(%eax),%eax
80105b21:	83 ec 04             	sub    $0x4,%esp
80105b24:	50                   	push   %eax
80105b25:	68 c0 85 10 80       	push   $0x801085c0
80105b2a:	ff 75 f0             	pushl  -0x10(%ebp)
80105b2d:	e8 e1 c6 ff ff       	call   80102213 <dirlink>
80105b32:	83 c4 10             	add    $0x10,%esp
80105b35:	85 c0                	test   %eax,%eax
80105b37:	79 0d                	jns    80105b46 <create+0x195>
      panic("create dots");
80105b39:	83 ec 0c             	sub    $0xc,%esp
80105b3c:	68 f3 85 10 80       	push   $0x801085f3
80105b41:	e8 20 aa ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105b46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b49:	8b 40 04             	mov    0x4(%eax),%eax
80105b4c:	83 ec 04             	sub    $0x4,%esp
80105b4f:	50                   	push   %eax
80105b50:	8d 45 de             	lea    -0x22(%ebp),%eax
80105b53:	50                   	push   %eax
80105b54:	ff 75 f4             	pushl  -0xc(%ebp)
80105b57:	e8 b7 c6 ff ff       	call   80102213 <dirlink>
80105b5c:	83 c4 10             	add    $0x10,%esp
80105b5f:	85 c0                	test   %eax,%eax
80105b61:	79 0d                	jns    80105b70 <create+0x1bf>
    panic("create: dirlink");
80105b63:	83 ec 0c             	sub    $0xc,%esp
80105b66:	68 ff 85 10 80       	push   $0x801085ff
80105b6b:	e8 f6 a9 ff ff       	call   80100566 <panic>

  iunlockput(dp);
80105b70:	83 ec 0c             	sub    $0xc,%esp
80105b73:	ff 75 f4             	pushl  -0xc(%ebp)
80105b76:	e8 36 c0 ff ff       	call   80101bb1 <iunlockput>
80105b7b:	83 c4 10             	add    $0x10,%esp

  return ip;
80105b7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105b81:	c9                   	leave  
80105b82:	c3                   	ret    

80105b83 <sys_open>:

int
sys_open(void)
{
80105b83:	55                   	push   %ebp
80105b84:	89 e5                	mov    %esp,%ebp
80105b86:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105b89:	83 ec 08             	sub    $0x8,%esp
80105b8c:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105b8f:	50                   	push   %eax
80105b90:	6a 00                	push   $0x0
80105b92:	e8 f5 f6 ff ff       	call   8010528c <argstr>
80105b97:	83 c4 10             	add    $0x10,%esp
80105b9a:	85 c0                	test   %eax,%eax
80105b9c:	78 15                	js     80105bb3 <sys_open+0x30>
80105b9e:	83 ec 08             	sub    $0x8,%esp
80105ba1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105ba4:	50                   	push   %eax
80105ba5:	6a 01                	push   $0x1
80105ba7:	e8 5b f6 ff ff       	call   80105207 <argint>
80105bac:	83 c4 10             	add    $0x10,%esp
80105baf:	85 c0                	test   %eax,%eax
80105bb1:	79 0a                	jns    80105bbd <sys_open+0x3a>
    return -1;
80105bb3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bb8:	e9 4d 01 00 00       	jmp    80105d0a <sys_open+0x187>
  if(omode & O_CREATE){
80105bbd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bc0:	25 00 02 00 00       	and    $0x200,%eax
80105bc5:	85 c0                	test   %eax,%eax
80105bc7:	74 2f                	je     80105bf8 <sys_open+0x75>
    begin_trans();
80105bc9:	e8 ad d6 ff ff       	call   8010327b <begin_trans>
    ip = create(path, T_FILE, 0, 0);
80105bce:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105bd1:	6a 00                	push   $0x0
80105bd3:	6a 00                	push   $0x0
80105bd5:	6a 02                	push   $0x2
80105bd7:	50                   	push   %eax
80105bd8:	e8 d4 fd ff ff       	call   801059b1 <create>
80105bdd:	83 c4 10             	add    $0x10,%esp
80105be0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    commit_trans();
80105be3:	e8 e6 d6 ff ff       	call   801032ce <commit_trans>
    if(ip == 0)
80105be8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bec:	75 66                	jne    80105c54 <sys_open+0xd1>
      return -1;
80105bee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bf3:	e9 12 01 00 00       	jmp    80105d0a <sys_open+0x187>
  } else {
    if((ip = namei(path)) == 0)
80105bf8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105bfb:	83 ec 0c             	sub    $0xc,%esp
80105bfe:	50                   	push   %eax
80105bff:	e8 ab c8 ff ff       	call   801024af <namei>
80105c04:	83 c4 10             	add    $0x10,%esp
80105c07:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c0a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c0e:	75 0a                	jne    80105c1a <sys_open+0x97>
      return -1;
80105c10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c15:	e9 f0 00 00 00       	jmp    80105d0a <sys_open+0x187>
    ilock(ip);
80105c1a:	83 ec 0c             	sub    $0xc,%esp
80105c1d:	ff 75 f4             	pushl  -0xc(%ebp)
80105c20:	e8 d2 bc ff ff       	call   801018f7 <ilock>
80105c25:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c2b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105c2f:	66 83 f8 01          	cmp    $0x1,%ax
80105c33:	75 1f                	jne    80105c54 <sys_open+0xd1>
80105c35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c38:	85 c0                	test   %eax,%eax
80105c3a:	74 18                	je     80105c54 <sys_open+0xd1>
      iunlockput(ip);
80105c3c:	83 ec 0c             	sub    $0xc,%esp
80105c3f:	ff 75 f4             	pushl  -0xc(%ebp)
80105c42:	e8 6a bf ff ff       	call   80101bb1 <iunlockput>
80105c47:	83 c4 10             	add    $0x10,%esp
      return -1;
80105c4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c4f:	e9 b6 00 00 00       	jmp    80105d0a <sys_open+0x187>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105c54:	e8 0b b3 ff ff       	call   80100f64 <filealloc>
80105c59:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c5c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c60:	74 17                	je     80105c79 <sys_open+0xf6>
80105c62:	83 ec 0c             	sub    $0xc,%esp
80105c65:	ff 75 f0             	pushl  -0x10(%ebp)
80105c68:	e8 4b f7 ff ff       	call   801053b8 <fdalloc>
80105c6d:	83 c4 10             	add    $0x10,%esp
80105c70:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105c73:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105c77:	79 29                	jns    80105ca2 <sys_open+0x11f>
    if(f)
80105c79:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c7d:	74 0e                	je     80105c8d <sys_open+0x10a>
      fileclose(f);
80105c7f:	83 ec 0c             	sub    $0xc,%esp
80105c82:	ff 75 f0             	pushl  -0x10(%ebp)
80105c85:	e8 98 b3 ff ff       	call   80101022 <fileclose>
80105c8a:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105c8d:	83 ec 0c             	sub    $0xc,%esp
80105c90:	ff 75 f4             	pushl  -0xc(%ebp)
80105c93:	e8 19 bf ff ff       	call   80101bb1 <iunlockput>
80105c98:	83 c4 10             	add    $0x10,%esp
    return -1;
80105c9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ca0:	eb 68                	jmp    80105d0a <sys_open+0x187>
  }
  iunlock(ip);
80105ca2:	83 ec 0c             	sub    $0xc,%esp
80105ca5:	ff 75 f4             	pushl  -0xc(%ebp)
80105ca8:	e8 a2 bd ff ff       	call   80101a4f <iunlock>
80105cad:	83 c4 10             	add    $0x10,%esp

  f->type = FD_INODE;
80105cb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cb3:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105cb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cbc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105cbf:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105cc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cc5:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105ccc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ccf:	83 e0 01             	and    $0x1,%eax
80105cd2:	85 c0                	test   %eax,%eax
80105cd4:	0f 94 c0             	sete   %al
80105cd7:	89 c2                	mov    %eax,%edx
80105cd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cdc:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105cdf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ce2:	83 e0 01             	and    $0x1,%eax
80105ce5:	85 c0                	test   %eax,%eax
80105ce7:	75 0a                	jne    80105cf3 <sys_open+0x170>
80105ce9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105cec:	83 e0 02             	and    $0x2,%eax
80105cef:	85 c0                	test   %eax,%eax
80105cf1:	74 07                	je     80105cfa <sys_open+0x177>
80105cf3:	b8 01 00 00 00       	mov    $0x1,%eax
80105cf8:	eb 05                	jmp    80105cff <sys_open+0x17c>
80105cfa:	b8 00 00 00 00       	mov    $0x0,%eax
80105cff:	89 c2                	mov    %eax,%edx
80105d01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d04:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105d07:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105d0a:	c9                   	leave  
80105d0b:	c3                   	ret    

80105d0c <sys_mkdir>:

int
sys_mkdir(void)
{
80105d0c:	55                   	push   %ebp
80105d0d:	89 e5                	mov    %esp,%ebp
80105d0f:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_trans();
80105d12:	e8 64 d5 ff ff       	call   8010327b <begin_trans>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105d17:	83 ec 08             	sub    $0x8,%esp
80105d1a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d1d:	50                   	push   %eax
80105d1e:	6a 00                	push   $0x0
80105d20:	e8 67 f5 ff ff       	call   8010528c <argstr>
80105d25:	83 c4 10             	add    $0x10,%esp
80105d28:	85 c0                	test   %eax,%eax
80105d2a:	78 1b                	js     80105d47 <sys_mkdir+0x3b>
80105d2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d2f:	6a 00                	push   $0x0
80105d31:	6a 00                	push   $0x0
80105d33:	6a 01                	push   $0x1
80105d35:	50                   	push   %eax
80105d36:	e8 76 fc ff ff       	call   801059b1 <create>
80105d3b:	83 c4 10             	add    $0x10,%esp
80105d3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d41:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d45:	75 0c                	jne    80105d53 <sys_mkdir+0x47>
    commit_trans();
80105d47:	e8 82 d5 ff ff       	call   801032ce <commit_trans>
    return -1;
80105d4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d51:	eb 18                	jmp    80105d6b <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105d53:	83 ec 0c             	sub    $0xc,%esp
80105d56:	ff 75 f4             	pushl  -0xc(%ebp)
80105d59:	e8 53 be ff ff       	call   80101bb1 <iunlockput>
80105d5e:	83 c4 10             	add    $0x10,%esp
  commit_trans();
80105d61:	e8 68 d5 ff ff       	call   801032ce <commit_trans>
  return 0;
80105d66:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d6b:	c9                   	leave  
80105d6c:	c3                   	ret    

80105d6d <sys_mknod>:

int
sys_mknod(void)
{
80105d6d:	55                   	push   %ebp
80105d6e:	89 e5                	mov    %esp,%ebp
80105d70:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
80105d73:	e8 03 d5 ff ff       	call   8010327b <begin_trans>
  if((len=argstr(0, &path)) < 0 ||
80105d78:	83 ec 08             	sub    $0x8,%esp
80105d7b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d7e:	50                   	push   %eax
80105d7f:	6a 00                	push   $0x0
80105d81:	e8 06 f5 ff ff       	call   8010528c <argstr>
80105d86:	83 c4 10             	add    $0x10,%esp
80105d89:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d8c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d90:	78 4f                	js     80105de1 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80105d92:	83 ec 08             	sub    $0x8,%esp
80105d95:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105d98:	50                   	push   %eax
80105d99:	6a 01                	push   $0x1
80105d9b:	e8 67 f4 ff ff       	call   80105207 <argint>
80105da0:	83 c4 10             	add    $0x10,%esp
  if((len=argstr(0, &path)) < 0 ||
80105da3:	85 c0                	test   %eax,%eax
80105da5:	78 3a                	js     80105de1 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
80105da7:	83 ec 08             	sub    $0x8,%esp
80105daa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105dad:	50                   	push   %eax
80105dae:	6a 02                	push   $0x2
80105db0:	e8 52 f4 ff ff       	call   80105207 <argint>
80105db5:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105db8:	85 c0                	test   %eax,%eax
80105dba:	78 25                	js     80105de1 <sys_mknod+0x74>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105dbc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105dbf:	0f bf c8             	movswl %ax,%ecx
80105dc2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105dc5:	0f bf d0             	movswl %ax,%edx
80105dc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
     argint(2, &minor) < 0 ||
80105dcb:	51                   	push   %ecx
80105dcc:	52                   	push   %edx
80105dcd:	6a 03                	push   $0x3
80105dcf:	50                   	push   %eax
80105dd0:	e8 dc fb ff ff       	call   801059b1 <create>
80105dd5:	83 c4 10             	add    $0x10,%esp
80105dd8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ddb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ddf:	75 0c                	jne    80105ded <sys_mknod+0x80>
    commit_trans();
80105de1:	e8 e8 d4 ff ff       	call   801032ce <commit_trans>
    return -1;
80105de6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105deb:	eb 18                	jmp    80105e05 <sys_mknod+0x98>
  }
  iunlockput(ip);
80105ded:	83 ec 0c             	sub    $0xc,%esp
80105df0:	ff 75 f0             	pushl  -0x10(%ebp)
80105df3:	e8 b9 bd ff ff       	call   80101bb1 <iunlockput>
80105df8:	83 c4 10             	add    $0x10,%esp
  commit_trans();
80105dfb:	e8 ce d4 ff ff       	call   801032ce <commit_trans>
  return 0;
80105e00:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e05:	c9                   	leave  
80105e06:	c3                   	ret    

80105e07 <sys_chdir>:

int
sys_chdir(void)
{
80105e07:	55                   	push   %ebp
80105e08:	89 e5                	mov    %esp,%ebp
80105e0a:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
80105e0d:	83 ec 08             	sub    $0x8,%esp
80105e10:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e13:	50                   	push   %eax
80105e14:	6a 00                	push   $0x0
80105e16:	e8 71 f4 ff ff       	call   8010528c <argstr>
80105e1b:	83 c4 10             	add    $0x10,%esp
80105e1e:	85 c0                	test   %eax,%eax
80105e20:	78 18                	js     80105e3a <sys_chdir+0x33>
80105e22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e25:	83 ec 0c             	sub    $0xc,%esp
80105e28:	50                   	push   %eax
80105e29:	e8 81 c6 ff ff       	call   801024af <namei>
80105e2e:	83 c4 10             	add    $0x10,%esp
80105e31:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e34:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e38:	75 07                	jne    80105e41 <sys_chdir+0x3a>
    return -1;
80105e3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e3f:	eb 64                	jmp    80105ea5 <sys_chdir+0x9e>
  ilock(ip);
80105e41:	83 ec 0c             	sub    $0xc,%esp
80105e44:	ff 75 f4             	pushl  -0xc(%ebp)
80105e47:	e8 ab ba ff ff       	call   801018f7 <ilock>
80105e4c:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e52:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e56:	66 83 f8 01          	cmp    $0x1,%ax
80105e5a:	74 15                	je     80105e71 <sys_chdir+0x6a>
    iunlockput(ip);
80105e5c:	83 ec 0c             	sub    $0xc,%esp
80105e5f:	ff 75 f4             	pushl  -0xc(%ebp)
80105e62:	e8 4a bd ff ff       	call   80101bb1 <iunlockput>
80105e67:	83 c4 10             	add    $0x10,%esp
    return -1;
80105e6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e6f:	eb 34                	jmp    80105ea5 <sys_chdir+0x9e>
  }
  iunlock(ip);
80105e71:	83 ec 0c             	sub    $0xc,%esp
80105e74:	ff 75 f4             	pushl  -0xc(%ebp)
80105e77:	e8 d3 bb ff ff       	call   80101a4f <iunlock>
80105e7c:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80105e7f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e85:	8b 40 68             	mov    0x68(%eax),%eax
80105e88:	83 ec 0c             	sub    $0xc,%esp
80105e8b:	50                   	push   %eax
80105e8c:	e8 30 bc ff ff       	call   80101ac1 <iput>
80105e91:	83 c4 10             	add    $0x10,%esp
  proc->cwd = ip;
80105e94:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e9a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e9d:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105ea0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ea5:	c9                   	leave  
80105ea6:	c3                   	ret    

80105ea7 <sys_exec>:

int
sys_exec(void)
{
80105ea7:	55                   	push   %ebp
80105ea8:	89 e5                	mov    %esp,%ebp
80105eaa:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105eb0:	83 ec 08             	sub    $0x8,%esp
80105eb3:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105eb6:	50                   	push   %eax
80105eb7:	6a 00                	push   $0x0
80105eb9:	e8 ce f3 ff ff       	call   8010528c <argstr>
80105ebe:	83 c4 10             	add    $0x10,%esp
80105ec1:	85 c0                	test   %eax,%eax
80105ec3:	78 18                	js     80105edd <sys_exec+0x36>
80105ec5:	83 ec 08             	sub    $0x8,%esp
80105ec8:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105ece:	50                   	push   %eax
80105ecf:	6a 01                	push   $0x1
80105ed1:	e8 31 f3 ff ff       	call   80105207 <argint>
80105ed6:	83 c4 10             	add    $0x10,%esp
80105ed9:	85 c0                	test   %eax,%eax
80105edb:	79 0a                	jns    80105ee7 <sys_exec+0x40>
    return -1;
80105edd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ee2:	e9 c6 00 00 00       	jmp    80105fad <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105ee7:	83 ec 04             	sub    $0x4,%esp
80105eea:	68 80 00 00 00       	push   $0x80
80105eef:	6a 00                	push   $0x0
80105ef1:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105ef7:	50                   	push   %eax
80105ef8:	e8 e5 ef ff ff       	call   80104ee2 <memset>
80105efd:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105f00:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105f07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f0a:	83 f8 1f             	cmp    $0x1f,%eax
80105f0d:	76 0a                	jbe    80105f19 <sys_exec+0x72>
      return -1;
80105f0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f14:	e9 94 00 00 00       	jmp    80105fad <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105f19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f1c:	c1 e0 02             	shl    $0x2,%eax
80105f1f:	89 c2                	mov    %eax,%edx
80105f21:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105f27:	01 c2                	add    %eax,%edx
80105f29:	83 ec 08             	sub    $0x8,%esp
80105f2c:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105f32:	50                   	push   %eax
80105f33:	52                   	push   %edx
80105f34:	e8 32 f2 ff ff       	call   8010516b <fetchint>
80105f39:	83 c4 10             	add    $0x10,%esp
80105f3c:	85 c0                	test   %eax,%eax
80105f3e:	79 07                	jns    80105f47 <sys_exec+0xa0>
      return -1;
80105f40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f45:	eb 66                	jmp    80105fad <sys_exec+0x106>
    if(uarg == 0){
80105f47:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105f4d:	85 c0                	test   %eax,%eax
80105f4f:	75 27                	jne    80105f78 <sys_exec+0xd1>
      argv[i] = 0;
80105f51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f54:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105f5b:	00 00 00 00 
      break;
80105f5f:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105f60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f63:	83 ec 08             	sub    $0x8,%esp
80105f66:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105f6c:	52                   	push   %edx
80105f6d:	50                   	push   %eax
80105f6e:	e8 e3 ab ff ff       	call   80100b56 <exec>
80105f73:	83 c4 10             	add    $0x10,%esp
80105f76:	eb 35                	jmp    80105fad <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105f78:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105f7e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f81:	c1 e2 02             	shl    $0x2,%edx
80105f84:	01 c2                	add    %eax,%edx
80105f86:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105f8c:	83 ec 08             	sub    $0x8,%esp
80105f8f:	52                   	push   %edx
80105f90:	50                   	push   %eax
80105f91:	e8 0f f2 ff ff       	call   801051a5 <fetchstr>
80105f96:	83 c4 10             	add    $0x10,%esp
80105f99:	85 c0                	test   %eax,%eax
80105f9b:	79 07                	jns    80105fa4 <sys_exec+0xfd>
      return -1;
80105f9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fa2:	eb 09                	jmp    80105fad <sys_exec+0x106>
  for(i=0;; i++){
80105fa4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105fa8:	e9 5a ff ff ff       	jmp    80105f07 <sys_exec+0x60>
}
80105fad:	c9                   	leave  
80105fae:	c3                   	ret    

80105faf <sys_pipe>:

int
sys_pipe(void)
{
80105faf:	55                   	push   %ebp
80105fb0:	89 e5                	mov    %esp,%ebp
80105fb2:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105fb5:	83 ec 04             	sub    $0x4,%esp
80105fb8:	6a 08                	push   $0x8
80105fba:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105fbd:	50                   	push   %eax
80105fbe:	6a 00                	push   $0x0
80105fc0:	e8 6a f2 ff ff       	call   8010522f <argptr>
80105fc5:	83 c4 10             	add    $0x10,%esp
80105fc8:	85 c0                	test   %eax,%eax
80105fca:	79 0a                	jns    80105fd6 <sys_pipe+0x27>
    return -1;
80105fcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fd1:	e9 af 00 00 00       	jmp    80106085 <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80105fd6:	83 ec 08             	sub    $0x8,%esp
80105fd9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105fdc:	50                   	push   %eax
80105fdd:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105fe0:	50                   	push   %eax
80105fe1:	e8 24 dc ff ff       	call   80103c0a <pipealloc>
80105fe6:	83 c4 10             	add    $0x10,%esp
80105fe9:	85 c0                	test   %eax,%eax
80105feb:	79 0a                	jns    80105ff7 <sys_pipe+0x48>
    return -1;
80105fed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ff2:	e9 8e 00 00 00       	jmp    80106085 <sys_pipe+0xd6>
  fd0 = -1;
80105ff7:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105ffe:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106001:	83 ec 0c             	sub    $0xc,%esp
80106004:	50                   	push   %eax
80106005:	e8 ae f3 ff ff       	call   801053b8 <fdalloc>
8010600a:	83 c4 10             	add    $0x10,%esp
8010600d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106010:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106014:	78 18                	js     8010602e <sys_pipe+0x7f>
80106016:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106019:	83 ec 0c             	sub    $0xc,%esp
8010601c:	50                   	push   %eax
8010601d:	e8 96 f3 ff ff       	call   801053b8 <fdalloc>
80106022:	83 c4 10             	add    $0x10,%esp
80106025:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106028:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010602c:	79 3f                	jns    8010606d <sys_pipe+0xbe>
    if(fd0 >= 0)
8010602e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106032:	78 14                	js     80106048 <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80106034:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010603a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010603d:	83 c2 08             	add    $0x8,%edx
80106040:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106047:	00 
    fileclose(rf);
80106048:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010604b:	83 ec 0c             	sub    $0xc,%esp
8010604e:	50                   	push   %eax
8010604f:	e8 ce af ff ff       	call   80101022 <fileclose>
80106054:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106057:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010605a:	83 ec 0c             	sub    $0xc,%esp
8010605d:	50                   	push   %eax
8010605e:	e8 bf af ff ff       	call   80101022 <fileclose>
80106063:	83 c4 10             	add    $0x10,%esp
    return -1;
80106066:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010606b:	eb 18                	jmp    80106085 <sys_pipe+0xd6>
  }
  fd[0] = fd0;
8010606d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106070:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106073:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106075:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106078:	8d 50 04             	lea    0x4(%eax),%edx
8010607b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010607e:	89 02                	mov    %eax,(%edx)
  return 0;
80106080:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106085:	c9                   	leave  
80106086:	c3                   	ret    

80106087 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106087:	55                   	push   %ebp
80106088:	89 e5                	mov    %esp,%ebp
8010608a:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010608d:	e8 ca e2 ff ff       	call   8010435c <fork>
}
80106092:	c9                   	leave  
80106093:	c3                   	ret    

80106094 <sys_exit>:

int
sys_exit(void)
{
80106094:	55                   	push   %ebp
80106095:	89 e5                	mov    %esp,%ebp
80106097:	83 ec 08             	sub    $0x8,%esp
  exit();
8010609a:	e8 2e e4 ff ff       	call   801044cd <exit>
  return 0;  // not reached
8010609f:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060a4:	c9                   	leave  
801060a5:	c3                   	ret    

801060a6 <sys_wait>:

int
sys_wait(void)
{
801060a6:	55                   	push   %ebp
801060a7:	89 e5                	mov    %esp,%ebp
801060a9:	83 ec 08             	sub    $0x8,%esp
  return wait();
801060ac:	e8 e4 e5 ff ff       	call   80104695 <wait>
}
801060b1:	c9                   	leave  
801060b2:	c3                   	ret    

801060b3 <sys_kill>:

int
sys_kill(void)
{
801060b3:	55                   	push   %ebp
801060b4:	89 e5                	mov    %esp,%ebp
801060b6:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801060b9:	83 ec 08             	sub    $0x8,%esp
801060bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
801060bf:	50                   	push   %eax
801060c0:	6a 00                	push   $0x0
801060c2:	e8 40 f1 ff ff       	call   80105207 <argint>
801060c7:	83 c4 10             	add    $0x10,%esp
801060ca:	85 c0                	test   %eax,%eax
801060cc:	79 07                	jns    801060d5 <sys_kill+0x22>
    return -1;
801060ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060d3:	eb 0f                	jmp    801060e4 <sys_kill+0x31>
  return kill(pid);
801060d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060d8:	83 ec 0c             	sub    $0xc,%esp
801060db:	50                   	push   %eax
801060dc:	e8 c7 e9 ff ff       	call   80104aa8 <kill>
801060e1:	83 c4 10             	add    $0x10,%esp
}
801060e4:	c9                   	leave  
801060e5:	c3                   	ret    

801060e6 <sys_getpid>:

int
sys_getpid(void)
{
801060e6:	55                   	push   %ebp
801060e7:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801060e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060ef:	8b 40 10             	mov    0x10(%eax),%eax
}
801060f2:	5d                   	pop    %ebp
801060f3:	c3                   	ret    

801060f4 <sys_sbrk>:

int
sys_sbrk(void)
{
801060f4:	55                   	push   %ebp
801060f5:	89 e5                	mov    %esp,%ebp
801060f7:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801060fa:	83 ec 08             	sub    $0x8,%esp
801060fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106100:	50                   	push   %eax
80106101:	6a 00                	push   $0x0
80106103:	e8 ff f0 ff ff       	call   80105207 <argint>
80106108:	83 c4 10             	add    $0x10,%esp
8010610b:	85 c0                	test   %eax,%eax
8010610d:	79 07                	jns    80106116 <sys_sbrk+0x22>
    return -1;
8010610f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106114:	eb 28                	jmp    8010613e <sys_sbrk+0x4a>
  addr = proc->sz;
80106116:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010611c:	8b 00                	mov    (%eax),%eax
8010611e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106121:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106124:	83 ec 0c             	sub    $0xc,%esp
80106127:	50                   	push   %eax
80106128:	e8 8c e1 ff ff       	call   801042b9 <growproc>
8010612d:	83 c4 10             	add    $0x10,%esp
80106130:	85 c0                	test   %eax,%eax
80106132:	79 07                	jns    8010613b <sys_sbrk+0x47>
    return -1;
80106134:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106139:	eb 03                	jmp    8010613e <sys_sbrk+0x4a>
  return addr;
8010613b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010613e:	c9                   	leave  
8010613f:	c3                   	ret    

80106140 <sys_sleep>:

int
sys_sleep(void)
{
80106140:	55                   	push   %ebp
80106141:	89 e5                	mov    %esp,%ebp
80106143:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106146:	83 ec 08             	sub    $0x8,%esp
80106149:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010614c:	50                   	push   %eax
8010614d:	6a 00                	push   $0x0
8010614f:	e8 b3 f0 ff ff       	call   80105207 <argint>
80106154:	83 c4 10             	add    $0x10,%esp
80106157:	85 c0                	test   %eax,%eax
80106159:	79 07                	jns    80106162 <sys_sleep+0x22>
    return -1;
8010615b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106160:	eb 77                	jmp    801061d9 <sys_sleep+0x99>
  acquire(&tickslock);
80106162:	83 ec 0c             	sub    $0xc,%esp
80106165:	68 60 1f 11 80       	push   $0x80111f60
8010616a:	e8 10 eb ff ff       	call   80104c7f <acquire>
8010616f:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106172:	a1 a0 27 11 80       	mov    0x801127a0,%eax
80106177:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010617a:	eb 39                	jmp    801061b5 <sys_sleep+0x75>
    if(proc->killed){
8010617c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106182:	8b 40 24             	mov    0x24(%eax),%eax
80106185:	85 c0                	test   %eax,%eax
80106187:	74 17                	je     801061a0 <sys_sleep+0x60>
      release(&tickslock);
80106189:	83 ec 0c             	sub    $0xc,%esp
8010618c:	68 60 1f 11 80       	push   $0x80111f60
80106191:	e8 50 eb ff ff       	call   80104ce6 <release>
80106196:	83 c4 10             	add    $0x10,%esp
      return -1;
80106199:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010619e:	eb 39                	jmp    801061d9 <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
801061a0:	83 ec 08             	sub    $0x8,%esp
801061a3:	68 60 1f 11 80       	push   $0x80111f60
801061a8:	68 a0 27 11 80       	push   $0x801127a0
801061ad:	e8 d4 e7 ff ff       	call   80104986 <sleep>
801061b2:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
801061b5:	a1 a0 27 11 80       	mov    0x801127a0,%eax
801061ba:	2b 45 f4             	sub    -0xc(%ebp),%eax
801061bd:	8b 55 f0             	mov    -0x10(%ebp),%edx
801061c0:	39 d0                	cmp    %edx,%eax
801061c2:	72 b8                	jb     8010617c <sys_sleep+0x3c>
  }
  release(&tickslock);
801061c4:	83 ec 0c             	sub    $0xc,%esp
801061c7:	68 60 1f 11 80       	push   $0x80111f60
801061cc:	e8 15 eb ff ff       	call   80104ce6 <release>
801061d1:	83 c4 10             	add    $0x10,%esp
  return 0;
801061d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061d9:	c9                   	leave  
801061da:	c3                   	ret    

801061db <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801061db:	55                   	push   %ebp
801061dc:	89 e5                	mov    %esp,%ebp
801061de:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
801061e1:	83 ec 0c             	sub    $0xc,%esp
801061e4:	68 60 1f 11 80       	push   $0x80111f60
801061e9:	e8 91 ea ff ff       	call   80104c7f <acquire>
801061ee:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801061f1:	a1 a0 27 11 80       	mov    0x801127a0,%eax
801061f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801061f9:	83 ec 0c             	sub    $0xc,%esp
801061fc:	68 60 1f 11 80       	push   $0x80111f60
80106201:	e8 e0 ea ff ff       	call   80104ce6 <release>
80106206:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106209:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010620c:	c9                   	leave  
8010620d:	c3                   	ret    

8010620e <outb>:
{
8010620e:	55                   	push   %ebp
8010620f:	89 e5                	mov    %esp,%ebp
80106211:	83 ec 08             	sub    $0x8,%esp
80106214:	8b 55 08             	mov    0x8(%ebp),%edx
80106217:	8b 45 0c             	mov    0xc(%ebp),%eax
8010621a:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010621e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106221:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106225:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106229:	ee                   	out    %al,(%dx)
}
8010622a:	90                   	nop
8010622b:	c9                   	leave  
8010622c:	c3                   	ret    

8010622d <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
8010622d:	55                   	push   %ebp
8010622e:	89 e5                	mov    %esp,%ebp
80106230:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106233:	6a 34                	push   $0x34
80106235:	6a 43                	push   $0x43
80106237:	e8 d2 ff ff ff       	call   8010620e <outb>
8010623c:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
8010623f:	68 9c 00 00 00       	push   $0x9c
80106244:	6a 40                	push   $0x40
80106246:	e8 c3 ff ff ff       	call   8010620e <outb>
8010624b:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
8010624e:	6a 2e                	push   $0x2e
80106250:	6a 40                	push   $0x40
80106252:	e8 b7 ff ff ff       	call   8010620e <outb>
80106257:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
8010625a:	83 ec 0c             	sub    $0xc,%esp
8010625d:	6a 00                	push   $0x0
8010625f:	e8 90 d8 ff ff       	call   80103af4 <picenable>
80106264:	83 c4 10             	add    $0x10,%esp
}
80106267:	90                   	nop
80106268:	c9                   	leave  
80106269:	c3                   	ret    

8010626a <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010626a:	1e                   	push   %ds
  pushl %es
8010626b:	06                   	push   %es
  pushl %fs
8010626c:	0f a0                	push   %fs
  pushl %gs
8010626e:	0f a8                	push   %gs
  pushal
80106270:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106271:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106275:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106277:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106279:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
8010627d:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
8010627f:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106281:	54                   	push   %esp
  call trap
80106282:	e8 d7 01 00 00       	call   8010645e <trap>
  addl $4, %esp
80106287:	83 c4 04             	add    $0x4,%esp

8010628a <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010628a:	61                   	popa   
  popl %gs
8010628b:	0f a9                	pop    %gs
  popl %fs
8010628d:	0f a1                	pop    %fs
  popl %es
8010628f:	07                   	pop    %es
  popl %ds
80106290:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106291:	83 c4 08             	add    $0x8,%esp
  iret
80106294:	cf                   	iret   

80106295 <lidt>:
{
80106295:	55                   	push   %ebp
80106296:	89 e5                	mov    %esp,%ebp
80106298:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010629b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010629e:	83 e8 01             	sub    $0x1,%eax
801062a1:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801062a5:	8b 45 08             	mov    0x8(%ebp),%eax
801062a8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801062ac:	8b 45 08             	mov    0x8(%ebp),%eax
801062af:	c1 e8 10             	shr    $0x10,%eax
801062b2:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801062b6:	8d 45 fa             	lea    -0x6(%ebp),%eax
801062b9:	0f 01 18             	lidtl  (%eax)
}
801062bc:	90                   	nop
801062bd:	c9                   	leave  
801062be:	c3                   	ret    

801062bf <rcr2>:

static inline uint
rcr2(void)
{
801062bf:	55                   	push   %ebp
801062c0:	89 e5                	mov    %esp,%ebp
801062c2:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801062c5:	0f 20 d0             	mov    %cr2,%eax
801062c8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801062cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801062ce:	c9                   	leave  
801062cf:	c3                   	ret    

801062d0 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801062d0:	55                   	push   %ebp
801062d1:	89 e5                	mov    %esp,%ebp
801062d3:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801062d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801062dd:	e9 c3 00 00 00       	jmp    801063a5 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801062e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e5:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
801062ec:	89 c2                	mov    %eax,%edx
801062ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062f1:	66 89 14 c5 a0 1f 11 	mov    %dx,-0x7feee060(,%eax,8)
801062f8:	80 
801062f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062fc:	66 c7 04 c5 a2 1f 11 	movw   $0x8,-0x7feee05e(,%eax,8)
80106303:	80 08 00 
80106306:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106309:	0f b6 14 c5 a4 1f 11 	movzbl -0x7feee05c(,%eax,8),%edx
80106310:	80 
80106311:	83 e2 e0             	and    $0xffffffe0,%edx
80106314:	88 14 c5 a4 1f 11 80 	mov    %dl,-0x7feee05c(,%eax,8)
8010631b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010631e:	0f b6 14 c5 a4 1f 11 	movzbl -0x7feee05c(,%eax,8),%edx
80106325:	80 
80106326:	83 e2 1f             	and    $0x1f,%edx
80106329:	88 14 c5 a4 1f 11 80 	mov    %dl,-0x7feee05c(,%eax,8)
80106330:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106333:	0f b6 14 c5 a5 1f 11 	movzbl -0x7feee05b(,%eax,8),%edx
8010633a:	80 
8010633b:	83 e2 f0             	and    $0xfffffff0,%edx
8010633e:	83 ca 0e             	or     $0xe,%edx
80106341:	88 14 c5 a5 1f 11 80 	mov    %dl,-0x7feee05b(,%eax,8)
80106348:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010634b:	0f b6 14 c5 a5 1f 11 	movzbl -0x7feee05b(,%eax,8),%edx
80106352:	80 
80106353:	83 e2 ef             	and    $0xffffffef,%edx
80106356:	88 14 c5 a5 1f 11 80 	mov    %dl,-0x7feee05b(,%eax,8)
8010635d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106360:	0f b6 14 c5 a5 1f 11 	movzbl -0x7feee05b(,%eax,8),%edx
80106367:	80 
80106368:	83 e2 9f             	and    $0xffffff9f,%edx
8010636b:	88 14 c5 a5 1f 11 80 	mov    %dl,-0x7feee05b(,%eax,8)
80106372:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106375:	0f b6 14 c5 a5 1f 11 	movzbl -0x7feee05b(,%eax,8),%edx
8010637c:	80 
8010637d:	83 ca 80             	or     $0xffffff80,%edx
80106380:	88 14 c5 a5 1f 11 80 	mov    %dl,-0x7feee05b(,%eax,8)
80106387:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010638a:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
80106391:	c1 e8 10             	shr    $0x10,%eax
80106394:	89 c2                	mov    %eax,%edx
80106396:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106399:	66 89 14 c5 a6 1f 11 	mov    %dx,-0x7feee05a(,%eax,8)
801063a0:	80 
  for(i = 0; i < 256; i++)
801063a1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801063a5:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801063ac:	0f 8e 30 ff ff ff    	jle    801062e2 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801063b2:	a1 98 b1 10 80       	mov    0x8010b198,%eax
801063b7:	66 a3 a0 21 11 80    	mov    %ax,0x801121a0
801063bd:	66 c7 05 a2 21 11 80 	movw   $0x8,0x801121a2
801063c4:	08 00 
801063c6:	0f b6 05 a4 21 11 80 	movzbl 0x801121a4,%eax
801063cd:	83 e0 e0             	and    $0xffffffe0,%eax
801063d0:	a2 a4 21 11 80       	mov    %al,0x801121a4
801063d5:	0f b6 05 a4 21 11 80 	movzbl 0x801121a4,%eax
801063dc:	83 e0 1f             	and    $0x1f,%eax
801063df:	a2 a4 21 11 80       	mov    %al,0x801121a4
801063e4:	0f b6 05 a5 21 11 80 	movzbl 0x801121a5,%eax
801063eb:	83 c8 0f             	or     $0xf,%eax
801063ee:	a2 a5 21 11 80       	mov    %al,0x801121a5
801063f3:	0f b6 05 a5 21 11 80 	movzbl 0x801121a5,%eax
801063fa:	83 e0 ef             	and    $0xffffffef,%eax
801063fd:	a2 a5 21 11 80       	mov    %al,0x801121a5
80106402:	0f b6 05 a5 21 11 80 	movzbl 0x801121a5,%eax
80106409:	83 c8 60             	or     $0x60,%eax
8010640c:	a2 a5 21 11 80       	mov    %al,0x801121a5
80106411:	0f b6 05 a5 21 11 80 	movzbl 0x801121a5,%eax
80106418:	83 c8 80             	or     $0xffffff80,%eax
8010641b:	a2 a5 21 11 80       	mov    %al,0x801121a5
80106420:	a1 98 b1 10 80       	mov    0x8010b198,%eax
80106425:	c1 e8 10             	shr    $0x10,%eax
80106428:	66 a3 a6 21 11 80    	mov    %ax,0x801121a6
  
  initlock(&tickslock, "time");
8010642e:	83 ec 08             	sub    $0x8,%esp
80106431:	68 10 86 10 80       	push   $0x80108610
80106436:	68 60 1f 11 80       	push   $0x80111f60
8010643b:	e8 1d e8 ff ff       	call   80104c5d <initlock>
80106440:	83 c4 10             	add    $0x10,%esp
}
80106443:	90                   	nop
80106444:	c9                   	leave  
80106445:	c3                   	ret    

80106446 <idtinit>:

void
idtinit(void)
{
80106446:	55                   	push   %ebp
80106447:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106449:	68 00 08 00 00       	push   $0x800
8010644e:	68 a0 1f 11 80       	push   $0x80111fa0
80106453:	e8 3d fe ff ff       	call   80106295 <lidt>
80106458:	83 c4 08             	add    $0x8,%esp
}
8010645b:	90                   	nop
8010645c:	c9                   	leave  
8010645d:	c3                   	ret    

8010645e <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010645e:	55                   	push   %ebp
8010645f:	89 e5                	mov    %esp,%ebp
80106461:	57                   	push   %edi
80106462:	56                   	push   %esi
80106463:	53                   	push   %ebx
80106464:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80106467:	8b 45 08             	mov    0x8(%ebp),%eax
8010646a:	8b 40 30             	mov    0x30(%eax),%eax
8010646d:	83 f8 40             	cmp    $0x40,%eax
80106470:	75 3e                	jne    801064b0 <trap+0x52>
    if(proc->killed)
80106472:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106478:	8b 40 24             	mov    0x24(%eax),%eax
8010647b:	85 c0                	test   %eax,%eax
8010647d:	74 05                	je     80106484 <trap+0x26>
      exit();
8010647f:	e8 49 e0 ff ff       	call   801044cd <exit>
    proc->tf = tf;
80106484:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010648a:	8b 55 08             	mov    0x8(%ebp),%edx
8010648d:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106490:	e8 28 ee ff ff       	call   801052bd <syscall>
    if(proc->killed)
80106495:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010649b:	8b 40 24             	mov    0x24(%eax),%eax
8010649e:	85 c0                	test   %eax,%eax
801064a0:	0f 84 1b 02 00 00    	je     801066c1 <trap+0x263>
      exit();
801064a6:	e8 22 e0 ff ff       	call   801044cd <exit>
    return;
801064ab:	e9 11 02 00 00       	jmp    801066c1 <trap+0x263>
  }

  switch(tf->trapno){
801064b0:	8b 45 08             	mov    0x8(%ebp),%eax
801064b3:	8b 40 30             	mov    0x30(%eax),%eax
801064b6:	83 e8 20             	sub    $0x20,%eax
801064b9:	83 f8 1f             	cmp    $0x1f,%eax
801064bc:	0f 87 c0 00 00 00    	ja     80106582 <trap+0x124>
801064c2:	8b 04 85 b8 86 10 80 	mov    -0x7fef7948(,%eax,4),%eax
801064c9:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
801064cb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801064d1:	0f b6 00             	movzbl (%eax),%eax
801064d4:	84 c0                	test   %al,%al
801064d6:	75 3d                	jne    80106515 <trap+0xb7>
      acquire(&tickslock);
801064d8:	83 ec 0c             	sub    $0xc,%esp
801064db:	68 60 1f 11 80       	push   $0x80111f60
801064e0:	e8 9a e7 ff ff       	call   80104c7f <acquire>
801064e5:	83 c4 10             	add    $0x10,%esp
      ticks++;
801064e8:	a1 a0 27 11 80       	mov    0x801127a0,%eax
801064ed:	83 c0 01             	add    $0x1,%eax
801064f0:	a3 a0 27 11 80       	mov    %eax,0x801127a0
      wakeup(&ticks);
801064f5:	83 ec 0c             	sub    $0xc,%esp
801064f8:	68 a0 27 11 80       	push   $0x801127a0
801064fd:	e8 6f e5 ff ff       	call   80104a71 <wakeup>
80106502:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106505:	83 ec 0c             	sub    $0xc,%esp
80106508:	68 60 1f 11 80       	push   $0x80111f60
8010650d:	e8 d4 e7 ff ff       	call   80104ce6 <release>
80106512:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106515:	e8 39 ca ff ff       	call   80102f53 <lapiceoi>
    break;
8010651a:	e9 1c 01 00 00       	jmp    8010663b <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010651f:	e8 5f c2 ff ff       	call   80102783 <ideintr>
    lapiceoi();
80106524:	e8 2a ca ff ff       	call   80102f53 <lapiceoi>
    break;
80106529:	e9 0d 01 00 00       	jmp    8010663b <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010652e:	e8 3f c8 ff ff       	call   80102d72 <kbdintr>
    lapiceoi();
80106533:	e8 1b ca ff ff       	call   80102f53 <lapiceoi>
    break;
80106538:	e9 fe 00 00 00       	jmp    8010663b <trap+0x1dd>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010653d:	e8 34 03 00 00       	call   80106876 <uartintr>
    lapiceoi();
80106542:	e8 0c ca ff ff       	call   80102f53 <lapiceoi>
    break;
80106547:	e9 ef 00 00 00       	jmp    8010663b <trap+0x1dd>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010654c:	8b 45 08             	mov    0x8(%ebp),%eax
8010654f:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106552:	8b 45 08             	mov    0x8(%ebp),%eax
80106555:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106559:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
8010655c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106562:	0f b6 00             	movzbl (%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106565:	0f b6 c0             	movzbl %al,%eax
80106568:	51                   	push   %ecx
80106569:	52                   	push   %edx
8010656a:	50                   	push   %eax
8010656b:	68 18 86 10 80       	push   $0x80108618
80106570:	e8 51 9e ff ff       	call   801003c6 <cprintf>
80106575:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106578:	e8 d6 c9 ff ff       	call   80102f53 <lapiceoi>
    break;
8010657d:	e9 b9 00 00 00       	jmp    8010663b <trap+0x1dd>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106582:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106588:	85 c0                	test   %eax,%eax
8010658a:	74 11                	je     8010659d <trap+0x13f>
8010658c:	8b 45 08             	mov    0x8(%ebp),%eax
8010658f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106593:	0f b7 c0             	movzwl %ax,%eax
80106596:	83 e0 03             	and    $0x3,%eax
80106599:	85 c0                	test   %eax,%eax
8010659b:	75 40                	jne    801065dd <trap+0x17f>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010659d:	e8 1d fd ff ff       	call   801062bf <rcr2>
801065a2:	89 c3                	mov    %eax,%ebx
801065a4:	8b 45 08             	mov    0x8(%ebp),%eax
801065a7:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
801065aa:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801065b0:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801065b3:	0f b6 d0             	movzbl %al,%edx
801065b6:	8b 45 08             	mov    0x8(%ebp),%eax
801065b9:	8b 40 30             	mov    0x30(%eax),%eax
801065bc:	83 ec 0c             	sub    $0xc,%esp
801065bf:	53                   	push   %ebx
801065c0:	51                   	push   %ecx
801065c1:	52                   	push   %edx
801065c2:	50                   	push   %eax
801065c3:	68 3c 86 10 80       	push   $0x8010863c
801065c8:	e8 f9 9d ff ff       	call   801003c6 <cprintf>
801065cd:	83 c4 20             	add    $0x20,%esp
      panic("trap");
801065d0:	83 ec 0c             	sub    $0xc,%esp
801065d3:	68 6e 86 10 80       	push   $0x8010866e
801065d8:	e8 89 9f ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801065dd:	e8 dd fc ff ff       	call   801062bf <rcr2>
801065e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801065e5:	8b 45 08             	mov    0x8(%ebp),%eax
801065e8:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801065eb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801065f1:	0f b6 00             	movzbl (%eax),%eax
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801065f4:	0f b6 d8             	movzbl %al,%ebx
801065f7:	8b 45 08             	mov    0x8(%ebp),%eax
801065fa:	8b 48 34             	mov    0x34(%eax),%ecx
801065fd:	8b 45 08             	mov    0x8(%ebp),%eax
80106600:	8b 50 30             	mov    0x30(%eax),%edx
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106603:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106609:	8d 78 6c             	lea    0x6c(%eax),%edi
8010660c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106612:	8b 40 10             	mov    0x10(%eax),%eax
80106615:	ff 75 e4             	pushl  -0x1c(%ebp)
80106618:	56                   	push   %esi
80106619:	53                   	push   %ebx
8010661a:	51                   	push   %ecx
8010661b:	52                   	push   %edx
8010661c:	57                   	push   %edi
8010661d:	50                   	push   %eax
8010661e:	68 74 86 10 80       	push   $0x80108674
80106623:	e8 9e 9d ff ff       	call   801003c6 <cprintf>
80106628:	83 c4 20             	add    $0x20,%esp
            rcr2());
    proc->killed = 1;
8010662b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106631:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106638:	eb 01                	jmp    8010663b <trap+0x1dd>
    break;
8010663a:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010663b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106641:	85 c0                	test   %eax,%eax
80106643:	74 24                	je     80106669 <trap+0x20b>
80106645:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010664b:	8b 40 24             	mov    0x24(%eax),%eax
8010664e:	85 c0                	test   %eax,%eax
80106650:	74 17                	je     80106669 <trap+0x20b>
80106652:	8b 45 08             	mov    0x8(%ebp),%eax
80106655:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106659:	0f b7 c0             	movzwl %ax,%eax
8010665c:	83 e0 03             	and    $0x3,%eax
8010665f:	83 f8 03             	cmp    $0x3,%eax
80106662:	75 05                	jne    80106669 <trap+0x20b>
    exit();
80106664:	e8 64 de ff ff       	call   801044cd <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106669:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010666f:	85 c0                	test   %eax,%eax
80106671:	74 1e                	je     80106691 <trap+0x233>
80106673:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106679:	8b 40 0c             	mov    0xc(%eax),%eax
8010667c:	83 f8 04             	cmp    $0x4,%eax
8010667f:	75 10                	jne    80106691 <trap+0x233>
80106681:	8b 45 08             	mov    0x8(%ebp),%eax
80106684:	8b 40 30             	mov    0x30(%eax),%eax
80106687:	83 f8 20             	cmp    $0x20,%eax
8010668a:	75 05                	jne    80106691 <trap+0x233>
    yield();
8010668c:	e8 89 e2 ff ff       	call   8010491a <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106691:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106697:	85 c0                	test   %eax,%eax
80106699:	74 27                	je     801066c2 <trap+0x264>
8010669b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066a1:	8b 40 24             	mov    0x24(%eax),%eax
801066a4:	85 c0                	test   %eax,%eax
801066a6:	74 1a                	je     801066c2 <trap+0x264>
801066a8:	8b 45 08             	mov    0x8(%ebp),%eax
801066ab:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801066af:	0f b7 c0             	movzwl %ax,%eax
801066b2:	83 e0 03             	and    $0x3,%eax
801066b5:	83 f8 03             	cmp    $0x3,%eax
801066b8:	75 08                	jne    801066c2 <trap+0x264>
    exit();
801066ba:	e8 0e de ff ff       	call   801044cd <exit>
801066bf:	eb 01                	jmp    801066c2 <trap+0x264>
    return;
801066c1:	90                   	nop
}
801066c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801066c5:	5b                   	pop    %ebx
801066c6:	5e                   	pop    %esi
801066c7:	5f                   	pop    %edi
801066c8:	5d                   	pop    %ebp
801066c9:	c3                   	ret    

801066ca <inb>:
{
801066ca:	55                   	push   %ebp
801066cb:	89 e5                	mov    %esp,%ebp
801066cd:	83 ec 14             	sub    $0x14,%esp
801066d0:	8b 45 08             	mov    0x8(%ebp),%eax
801066d3:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801066d7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801066db:	89 c2                	mov    %eax,%edx
801066dd:	ec                   	in     (%dx),%al
801066de:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801066e1:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801066e5:	c9                   	leave  
801066e6:	c3                   	ret    

801066e7 <outb>:
{
801066e7:	55                   	push   %ebp
801066e8:	89 e5                	mov    %esp,%ebp
801066ea:	83 ec 08             	sub    $0x8,%esp
801066ed:	8b 55 08             	mov    0x8(%ebp),%edx
801066f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801066f3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801066f7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801066fa:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801066fe:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106702:	ee                   	out    %al,(%dx)
}
80106703:	90                   	nop
80106704:	c9                   	leave  
80106705:	c3                   	ret    

80106706 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106706:	55                   	push   %ebp
80106707:	89 e5                	mov    %esp,%ebp
80106709:	83 ec 08             	sub    $0x8,%esp
  //char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
8010670c:	6a 00                	push   $0x0
8010670e:	68 fa 03 00 00       	push   $0x3fa
80106713:	e8 cf ff ff ff       	call   801066e7 <outb>
80106718:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010671b:	68 80 00 00 00       	push   $0x80
80106720:	68 fb 03 00 00       	push   $0x3fb
80106725:	e8 bd ff ff ff       	call   801066e7 <outb>
8010672a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
8010672d:	6a 0c                	push   $0xc
8010672f:	68 f8 03 00 00       	push   $0x3f8
80106734:	e8 ae ff ff ff       	call   801066e7 <outb>
80106739:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
8010673c:	6a 00                	push   $0x0
8010673e:	68 f9 03 00 00       	push   $0x3f9
80106743:	e8 9f ff ff ff       	call   801066e7 <outb>
80106748:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010674b:	6a 03                	push   $0x3
8010674d:	68 fb 03 00 00       	push   $0x3fb
80106752:	e8 90 ff ff ff       	call   801066e7 <outb>
80106757:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010675a:	6a 00                	push   $0x0
8010675c:	68 fc 03 00 00       	push   $0x3fc
80106761:	e8 81 ff ff ff       	call   801066e7 <outb>
80106766:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106769:	6a 01                	push   $0x1
8010676b:	68 f9 03 00 00       	push   $0x3f9
80106770:	e8 72 ff ff ff       	call   801066e7 <outb>
80106775:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106778:	68 fd 03 00 00       	push   $0x3fd
8010677d:	e8 48 ff ff ff       	call   801066ca <inb>
80106782:	83 c4 04             	add    $0x4,%esp
80106785:	3c ff                	cmp    $0xff,%al
80106787:	74 42                	je     801067cb <uartinit+0xc5>
    return;
  uart = 1;
80106789:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
80106790:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106793:	68 fa 03 00 00       	push   $0x3fa
80106798:	e8 2d ff ff ff       	call   801066ca <inb>
8010679d:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801067a0:	68 f8 03 00 00       	push   $0x3f8
801067a5:	e8 20 ff ff ff       	call   801066ca <inb>
801067aa:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
801067ad:	83 ec 0c             	sub    $0xc,%esp
801067b0:	6a 04                	push   $0x4
801067b2:	e8 3d d3 ff ff       	call   80103af4 <picenable>
801067b7:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
801067ba:	83 ec 08             	sub    $0x8,%esp
801067bd:	6a 00                	push   $0x0
801067bf:	6a 04                	push   $0x4
801067c1:	e8 5f c2 ff ff       	call   80102a25 <ioapicenable>
801067c6:	83 c4 10             	add    $0x10,%esp
801067c9:	eb 01                	jmp    801067cc <uartinit+0xc6>
    return;
801067cb:	90                   	nop
  
  // Announce that we're here.
  //for(p="xv6...\n"; *p; p++)
  //  uartputc(*p);
}
801067cc:	c9                   	leave  
801067cd:	c3                   	ret    

801067ce <uartputc>:

void
uartputc(int c)
{
801067ce:	55                   	push   %ebp
801067cf:	89 e5                	mov    %esp,%ebp
801067d1:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801067d4:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
801067d9:	85 c0                	test   %eax,%eax
801067db:	74 53                	je     80106830 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801067dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801067e4:	eb 11                	jmp    801067f7 <uartputc+0x29>
    microdelay(10);
801067e6:	83 ec 0c             	sub    $0xc,%esp
801067e9:	6a 0a                	push   $0xa
801067eb:	e8 7e c7 ff ff       	call   80102f6e <microdelay>
801067f0:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801067f3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801067f7:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801067fb:	7f 1a                	jg     80106817 <uartputc+0x49>
801067fd:	83 ec 0c             	sub    $0xc,%esp
80106800:	68 fd 03 00 00       	push   $0x3fd
80106805:	e8 c0 fe ff ff       	call   801066ca <inb>
8010680a:	83 c4 10             	add    $0x10,%esp
8010680d:	0f b6 c0             	movzbl %al,%eax
80106810:	83 e0 20             	and    $0x20,%eax
80106813:	85 c0                	test   %eax,%eax
80106815:	74 cf                	je     801067e6 <uartputc+0x18>
  outb(COM1+0, c);
80106817:	8b 45 08             	mov    0x8(%ebp),%eax
8010681a:	0f b6 c0             	movzbl %al,%eax
8010681d:	83 ec 08             	sub    $0x8,%esp
80106820:	50                   	push   %eax
80106821:	68 f8 03 00 00       	push   $0x3f8
80106826:	e8 bc fe ff ff       	call   801066e7 <outb>
8010682b:	83 c4 10             	add    $0x10,%esp
8010682e:	eb 01                	jmp    80106831 <uartputc+0x63>
    return;
80106830:	90                   	nop
}
80106831:	c9                   	leave  
80106832:	c3                   	ret    

80106833 <uartgetc>:

static int
uartgetc(void)
{
80106833:	55                   	push   %ebp
80106834:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106836:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
8010683b:	85 c0                	test   %eax,%eax
8010683d:	75 07                	jne    80106846 <uartgetc+0x13>
    return -1;
8010683f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106844:	eb 2e                	jmp    80106874 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106846:	68 fd 03 00 00       	push   $0x3fd
8010684b:	e8 7a fe ff ff       	call   801066ca <inb>
80106850:	83 c4 04             	add    $0x4,%esp
80106853:	0f b6 c0             	movzbl %al,%eax
80106856:	83 e0 01             	and    $0x1,%eax
80106859:	85 c0                	test   %eax,%eax
8010685b:	75 07                	jne    80106864 <uartgetc+0x31>
    return -1;
8010685d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106862:	eb 10                	jmp    80106874 <uartgetc+0x41>
  return inb(COM1+0);
80106864:	68 f8 03 00 00       	push   $0x3f8
80106869:	e8 5c fe ff ff       	call   801066ca <inb>
8010686e:	83 c4 04             	add    $0x4,%esp
80106871:	0f b6 c0             	movzbl %al,%eax
}
80106874:	c9                   	leave  
80106875:	c3                   	ret    

80106876 <uartintr>:

void
uartintr(void)
{
80106876:	55                   	push   %ebp
80106877:	89 e5                	mov    %esp,%ebp
80106879:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
8010687c:	83 ec 0c             	sub    $0xc,%esp
8010687f:	68 33 68 10 80       	push   $0x80106833
80106884:	e8 54 9f ff ff       	call   801007dd <consoleintr>
80106889:	83 c4 10             	add    $0x10,%esp
}
8010688c:	90                   	nop
8010688d:	c9                   	leave  
8010688e:	c3                   	ret    

8010688f <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010688f:	6a 00                	push   $0x0
  pushl $0
80106891:	6a 00                	push   $0x0
  jmp alltraps
80106893:	e9 d2 f9 ff ff       	jmp    8010626a <alltraps>

80106898 <vector1>:
.globl vector1
vector1:
  pushl $0
80106898:	6a 00                	push   $0x0
  pushl $1
8010689a:	6a 01                	push   $0x1
  jmp alltraps
8010689c:	e9 c9 f9 ff ff       	jmp    8010626a <alltraps>

801068a1 <vector2>:
.globl vector2
vector2:
  pushl $0
801068a1:	6a 00                	push   $0x0
  pushl $2
801068a3:	6a 02                	push   $0x2
  jmp alltraps
801068a5:	e9 c0 f9 ff ff       	jmp    8010626a <alltraps>

801068aa <vector3>:
.globl vector3
vector3:
  pushl $0
801068aa:	6a 00                	push   $0x0
  pushl $3
801068ac:	6a 03                	push   $0x3
  jmp alltraps
801068ae:	e9 b7 f9 ff ff       	jmp    8010626a <alltraps>

801068b3 <vector4>:
.globl vector4
vector4:
  pushl $0
801068b3:	6a 00                	push   $0x0
  pushl $4
801068b5:	6a 04                	push   $0x4
  jmp alltraps
801068b7:	e9 ae f9 ff ff       	jmp    8010626a <alltraps>

801068bc <vector5>:
.globl vector5
vector5:
  pushl $0
801068bc:	6a 00                	push   $0x0
  pushl $5
801068be:	6a 05                	push   $0x5
  jmp alltraps
801068c0:	e9 a5 f9 ff ff       	jmp    8010626a <alltraps>

801068c5 <vector6>:
.globl vector6
vector6:
  pushl $0
801068c5:	6a 00                	push   $0x0
  pushl $6
801068c7:	6a 06                	push   $0x6
  jmp alltraps
801068c9:	e9 9c f9 ff ff       	jmp    8010626a <alltraps>

801068ce <vector7>:
.globl vector7
vector7:
  pushl $0
801068ce:	6a 00                	push   $0x0
  pushl $7
801068d0:	6a 07                	push   $0x7
  jmp alltraps
801068d2:	e9 93 f9 ff ff       	jmp    8010626a <alltraps>

801068d7 <vector8>:
.globl vector8
vector8:
  pushl $8
801068d7:	6a 08                	push   $0x8
  jmp alltraps
801068d9:	e9 8c f9 ff ff       	jmp    8010626a <alltraps>

801068de <vector9>:
.globl vector9
vector9:
  pushl $0
801068de:	6a 00                	push   $0x0
  pushl $9
801068e0:	6a 09                	push   $0x9
  jmp alltraps
801068e2:	e9 83 f9 ff ff       	jmp    8010626a <alltraps>

801068e7 <vector10>:
.globl vector10
vector10:
  pushl $10
801068e7:	6a 0a                	push   $0xa
  jmp alltraps
801068e9:	e9 7c f9 ff ff       	jmp    8010626a <alltraps>

801068ee <vector11>:
.globl vector11
vector11:
  pushl $11
801068ee:	6a 0b                	push   $0xb
  jmp alltraps
801068f0:	e9 75 f9 ff ff       	jmp    8010626a <alltraps>

801068f5 <vector12>:
.globl vector12
vector12:
  pushl $12
801068f5:	6a 0c                	push   $0xc
  jmp alltraps
801068f7:	e9 6e f9 ff ff       	jmp    8010626a <alltraps>

801068fc <vector13>:
.globl vector13
vector13:
  pushl $13
801068fc:	6a 0d                	push   $0xd
  jmp alltraps
801068fe:	e9 67 f9 ff ff       	jmp    8010626a <alltraps>

80106903 <vector14>:
.globl vector14
vector14:
  pushl $14
80106903:	6a 0e                	push   $0xe
  jmp alltraps
80106905:	e9 60 f9 ff ff       	jmp    8010626a <alltraps>

8010690a <vector15>:
.globl vector15
vector15:
  pushl $0
8010690a:	6a 00                	push   $0x0
  pushl $15
8010690c:	6a 0f                	push   $0xf
  jmp alltraps
8010690e:	e9 57 f9 ff ff       	jmp    8010626a <alltraps>

80106913 <vector16>:
.globl vector16
vector16:
  pushl $0
80106913:	6a 00                	push   $0x0
  pushl $16
80106915:	6a 10                	push   $0x10
  jmp alltraps
80106917:	e9 4e f9 ff ff       	jmp    8010626a <alltraps>

8010691c <vector17>:
.globl vector17
vector17:
  pushl $17
8010691c:	6a 11                	push   $0x11
  jmp alltraps
8010691e:	e9 47 f9 ff ff       	jmp    8010626a <alltraps>

80106923 <vector18>:
.globl vector18
vector18:
  pushl $0
80106923:	6a 00                	push   $0x0
  pushl $18
80106925:	6a 12                	push   $0x12
  jmp alltraps
80106927:	e9 3e f9 ff ff       	jmp    8010626a <alltraps>

8010692c <vector19>:
.globl vector19
vector19:
  pushl $0
8010692c:	6a 00                	push   $0x0
  pushl $19
8010692e:	6a 13                	push   $0x13
  jmp alltraps
80106930:	e9 35 f9 ff ff       	jmp    8010626a <alltraps>

80106935 <vector20>:
.globl vector20
vector20:
  pushl $0
80106935:	6a 00                	push   $0x0
  pushl $20
80106937:	6a 14                	push   $0x14
  jmp alltraps
80106939:	e9 2c f9 ff ff       	jmp    8010626a <alltraps>

8010693e <vector21>:
.globl vector21
vector21:
  pushl $0
8010693e:	6a 00                	push   $0x0
  pushl $21
80106940:	6a 15                	push   $0x15
  jmp alltraps
80106942:	e9 23 f9 ff ff       	jmp    8010626a <alltraps>

80106947 <vector22>:
.globl vector22
vector22:
  pushl $0
80106947:	6a 00                	push   $0x0
  pushl $22
80106949:	6a 16                	push   $0x16
  jmp alltraps
8010694b:	e9 1a f9 ff ff       	jmp    8010626a <alltraps>

80106950 <vector23>:
.globl vector23
vector23:
  pushl $0
80106950:	6a 00                	push   $0x0
  pushl $23
80106952:	6a 17                	push   $0x17
  jmp alltraps
80106954:	e9 11 f9 ff ff       	jmp    8010626a <alltraps>

80106959 <vector24>:
.globl vector24
vector24:
  pushl $0
80106959:	6a 00                	push   $0x0
  pushl $24
8010695b:	6a 18                	push   $0x18
  jmp alltraps
8010695d:	e9 08 f9 ff ff       	jmp    8010626a <alltraps>

80106962 <vector25>:
.globl vector25
vector25:
  pushl $0
80106962:	6a 00                	push   $0x0
  pushl $25
80106964:	6a 19                	push   $0x19
  jmp alltraps
80106966:	e9 ff f8 ff ff       	jmp    8010626a <alltraps>

8010696b <vector26>:
.globl vector26
vector26:
  pushl $0
8010696b:	6a 00                	push   $0x0
  pushl $26
8010696d:	6a 1a                	push   $0x1a
  jmp alltraps
8010696f:	e9 f6 f8 ff ff       	jmp    8010626a <alltraps>

80106974 <vector27>:
.globl vector27
vector27:
  pushl $0
80106974:	6a 00                	push   $0x0
  pushl $27
80106976:	6a 1b                	push   $0x1b
  jmp alltraps
80106978:	e9 ed f8 ff ff       	jmp    8010626a <alltraps>

8010697d <vector28>:
.globl vector28
vector28:
  pushl $0
8010697d:	6a 00                	push   $0x0
  pushl $28
8010697f:	6a 1c                	push   $0x1c
  jmp alltraps
80106981:	e9 e4 f8 ff ff       	jmp    8010626a <alltraps>

80106986 <vector29>:
.globl vector29
vector29:
  pushl $0
80106986:	6a 00                	push   $0x0
  pushl $29
80106988:	6a 1d                	push   $0x1d
  jmp alltraps
8010698a:	e9 db f8 ff ff       	jmp    8010626a <alltraps>

8010698f <vector30>:
.globl vector30
vector30:
  pushl $0
8010698f:	6a 00                	push   $0x0
  pushl $30
80106991:	6a 1e                	push   $0x1e
  jmp alltraps
80106993:	e9 d2 f8 ff ff       	jmp    8010626a <alltraps>

80106998 <vector31>:
.globl vector31
vector31:
  pushl $0
80106998:	6a 00                	push   $0x0
  pushl $31
8010699a:	6a 1f                	push   $0x1f
  jmp alltraps
8010699c:	e9 c9 f8 ff ff       	jmp    8010626a <alltraps>

801069a1 <vector32>:
.globl vector32
vector32:
  pushl $0
801069a1:	6a 00                	push   $0x0
  pushl $32
801069a3:	6a 20                	push   $0x20
  jmp alltraps
801069a5:	e9 c0 f8 ff ff       	jmp    8010626a <alltraps>

801069aa <vector33>:
.globl vector33
vector33:
  pushl $0
801069aa:	6a 00                	push   $0x0
  pushl $33
801069ac:	6a 21                	push   $0x21
  jmp alltraps
801069ae:	e9 b7 f8 ff ff       	jmp    8010626a <alltraps>

801069b3 <vector34>:
.globl vector34
vector34:
  pushl $0
801069b3:	6a 00                	push   $0x0
  pushl $34
801069b5:	6a 22                	push   $0x22
  jmp alltraps
801069b7:	e9 ae f8 ff ff       	jmp    8010626a <alltraps>

801069bc <vector35>:
.globl vector35
vector35:
  pushl $0
801069bc:	6a 00                	push   $0x0
  pushl $35
801069be:	6a 23                	push   $0x23
  jmp alltraps
801069c0:	e9 a5 f8 ff ff       	jmp    8010626a <alltraps>

801069c5 <vector36>:
.globl vector36
vector36:
  pushl $0
801069c5:	6a 00                	push   $0x0
  pushl $36
801069c7:	6a 24                	push   $0x24
  jmp alltraps
801069c9:	e9 9c f8 ff ff       	jmp    8010626a <alltraps>

801069ce <vector37>:
.globl vector37
vector37:
  pushl $0
801069ce:	6a 00                	push   $0x0
  pushl $37
801069d0:	6a 25                	push   $0x25
  jmp alltraps
801069d2:	e9 93 f8 ff ff       	jmp    8010626a <alltraps>

801069d7 <vector38>:
.globl vector38
vector38:
  pushl $0
801069d7:	6a 00                	push   $0x0
  pushl $38
801069d9:	6a 26                	push   $0x26
  jmp alltraps
801069db:	e9 8a f8 ff ff       	jmp    8010626a <alltraps>

801069e0 <vector39>:
.globl vector39
vector39:
  pushl $0
801069e0:	6a 00                	push   $0x0
  pushl $39
801069e2:	6a 27                	push   $0x27
  jmp alltraps
801069e4:	e9 81 f8 ff ff       	jmp    8010626a <alltraps>

801069e9 <vector40>:
.globl vector40
vector40:
  pushl $0
801069e9:	6a 00                	push   $0x0
  pushl $40
801069eb:	6a 28                	push   $0x28
  jmp alltraps
801069ed:	e9 78 f8 ff ff       	jmp    8010626a <alltraps>

801069f2 <vector41>:
.globl vector41
vector41:
  pushl $0
801069f2:	6a 00                	push   $0x0
  pushl $41
801069f4:	6a 29                	push   $0x29
  jmp alltraps
801069f6:	e9 6f f8 ff ff       	jmp    8010626a <alltraps>

801069fb <vector42>:
.globl vector42
vector42:
  pushl $0
801069fb:	6a 00                	push   $0x0
  pushl $42
801069fd:	6a 2a                	push   $0x2a
  jmp alltraps
801069ff:	e9 66 f8 ff ff       	jmp    8010626a <alltraps>

80106a04 <vector43>:
.globl vector43
vector43:
  pushl $0
80106a04:	6a 00                	push   $0x0
  pushl $43
80106a06:	6a 2b                	push   $0x2b
  jmp alltraps
80106a08:	e9 5d f8 ff ff       	jmp    8010626a <alltraps>

80106a0d <vector44>:
.globl vector44
vector44:
  pushl $0
80106a0d:	6a 00                	push   $0x0
  pushl $44
80106a0f:	6a 2c                	push   $0x2c
  jmp alltraps
80106a11:	e9 54 f8 ff ff       	jmp    8010626a <alltraps>

80106a16 <vector45>:
.globl vector45
vector45:
  pushl $0
80106a16:	6a 00                	push   $0x0
  pushl $45
80106a18:	6a 2d                	push   $0x2d
  jmp alltraps
80106a1a:	e9 4b f8 ff ff       	jmp    8010626a <alltraps>

80106a1f <vector46>:
.globl vector46
vector46:
  pushl $0
80106a1f:	6a 00                	push   $0x0
  pushl $46
80106a21:	6a 2e                	push   $0x2e
  jmp alltraps
80106a23:	e9 42 f8 ff ff       	jmp    8010626a <alltraps>

80106a28 <vector47>:
.globl vector47
vector47:
  pushl $0
80106a28:	6a 00                	push   $0x0
  pushl $47
80106a2a:	6a 2f                	push   $0x2f
  jmp alltraps
80106a2c:	e9 39 f8 ff ff       	jmp    8010626a <alltraps>

80106a31 <vector48>:
.globl vector48
vector48:
  pushl $0
80106a31:	6a 00                	push   $0x0
  pushl $48
80106a33:	6a 30                	push   $0x30
  jmp alltraps
80106a35:	e9 30 f8 ff ff       	jmp    8010626a <alltraps>

80106a3a <vector49>:
.globl vector49
vector49:
  pushl $0
80106a3a:	6a 00                	push   $0x0
  pushl $49
80106a3c:	6a 31                	push   $0x31
  jmp alltraps
80106a3e:	e9 27 f8 ff ff       	jmp    8010626a <alltraps>

80106a43 <vector50>:
.globl vector50
vector50:
  pushl $0
80106a43:	6a 00                	push   $0x0
  pushl $50
80106a45:	6a 32                	push   $0x32
  jmp alltraps
80106a47:	e9 1e f8 ff ff       	jmp    8010626a <alltraps>

80106a4c <vector51>:
.globl vector51
vector51:
  pushl $0
80106a4c:	6a 00                	push   $0x0
  pushl $51
80106a4e:	6a 33                	push   $0x33
  jmp alltraps
80106a50:	e9 15 f8 ff ff       	jmp    8010626a <alltraps>

80106a55 <vector52>:
.globl vector52
vector52:
  pushl $0
80106a55:	6a 00                	push   $0x0
  pushl $52
80106a57:	6a 34                	push   $0x34
  jmp alltraps
80106a59:	e9 0c f8 ff ff       	jmp    8010626a <alltraps>

80106a5e <vector53>:
.globl vector53
vector53:
  pushl $0
80106a5e:	6a 00                	push   $0x0
  pushl $53
80106a60:	6a 35                	push   $0x35
  jmp alltraps
80106a62:	e9 03 f8 ff ff       	jmp    8010626a <alltraps>

80106a67 <vector54>:
.globl vector54
vector54:
  pushl $0
80106a67:	6a 00                	push   $0x0
  pushl $54
80106a69:	6a 36                	push   $0x36
  jmp alltraps
80106a6b:	e9 fa f7 ff ff       	jmp    8010626a <alltraps>

80106a70 <vector55>:
.globl vector55
vector55:
  pushl $0
80106a70:	6a 00                	push   $0x0
  pushl $55
80106a72:	6a 37                	push   $0x37
  jmp alltraps
80106a74:	e9 f1 f7 ff ff       	jmp    8010626a <alltraps>

80106a79 <vector56>:
.globl vector56
vector56:
  pushl $0
80106a79:	6a 00                	push   $0x0
  pushl $56
80106a7b:	6a 38                	push   $0x38
  jmp alltraps
80106a7d:	e9 e8 f7 ff ff       	jmp    8010626a <alltraps>

80106a82 <vector57>:
.globl vector57
vector57:
  pushl $0
80106a82:	6a 00                	push   $0x0
  pushl $57
80106a84:	6a 39                	push   $0x39
  jmp alltraps
80106a86:	e9 df f7 ff ff       	jmp    8010626a <alltraps>

80106a8b <vector58>:
.globl vector58
vector58:
  pushl $0
80106a8b:	6a 00                	push   $0x0
  pushl $58
80106a8d:	6a 3a                	push   $0x3a
  jmp alltraps
80106a8f:	e9 d6 f7 ff ff       	jmp    8010626a <alltraps>

80106a94 <vector59>:
.globl vector59
vector59:
  pushl $0
80106a94:	6a 00                	push   $0x0
  pushl $59
80106a96:	6a 3b                	push   $0x3b
  jmp alltraps
80106a98:	e9 cd f7 ff ff       	jmp    8010626a <alltraps>

80106a9d <vector60>:
.globl vector60
vector60:
  pushl $0
80106a9d:	6a 00                	push   $0x0
  pushl $60
80106a9f:	6a 3c                	push   $0x3c
  jmp alltraps
80106aa1:	e9 c4 f7 ff ff       	jmp    8010626a <alltraps>

80106aa6 <vector61>:
.globl vector61
vector61:
  pushl $0
80106aa6:	6a 00                	push   $0x0
  pushl $61
80106aa8:	6a 3d                	push   $0x3d
  jmp alltraps
80106aaa:	e9 bb f7 ff ff       	jmp    8010626a <alltraps>

80106aaf <vector62>:
.globl vector62
vector62:
  pushl $0
80106aaf:	6a 00                	push   $0x0
  pushl $62
80106ab1:	6a 3e                	push   $0x3e
  jmp alltraps
80106ab3:	e9 b2 f7 ff ff       	jmp    8010626a <alltraps>

80106ab8 <vector63>:
.globl vector63
vector63:
  pushl $0
80106ab8:	6a 00                	push   $0x0
  pushl $63
80106aba:	6a 3f                	push   $0x3f
  jmp alltraps
80106abc:	e9 a9 f7 ff ff       	jmp    8010626a <alltraps>

80106ac1 <vector64>:
.globl vector64
vector64:
  pushl $0
80106ac1:	6a 00                	push   $0x0
  pushl $64
80106ac3:	6a 40                	push   $0x40
  jmp alltraps
80106ac5:	e9 a0 f7 ff ff       	jmp    8010626a <alltraps>

80106aca <vector65>:
.globl vector65
vector65:
  pushl $0
80106aca:	6a 00                	push   $0x0
  pushl $65
80106acc:	6a 41                	push   $0x41
  jmp alltraps
80106ace:	e9 97 f7 ff ff       	jmp    8010626a <alltraps>

80106ad3 <vector66>:
.globl vector66
vector66:
  pushl $0
80106ad3:	6a 00                	push   $0x0
  pushl $66
80106ad5:	6a 42                	push   $0x42
  jmp alltraps
80106ad7:	e9 8e f7 ff ff       	jmp    8010626a <alltraps>

80106adc <vector67>:
.globl vector67
vector67:
  pushl $0
80106adc:	6a 00                	push   $0x0
  pushl $67
80106ade:	6a 43                	push   $0x43
  jmp alltraps
80106ae0:	e9 85 f7 ff ff       	jmp    8010626a <alltraps>

80106ae5 <vector68>:
.globl vector68
vector68:
  pushl $0
80106ae5:	6a 00                	push   $0x0
  pushl $68
80106ae7:	6a 44                	push   $0x44
  jmp alltraps
80106ae9:	e9 7c f7 ff ff       	jmp    8010626a <alltraps>

80106aee <vector69>:
.globl vector69
vector69:
  pushl $0
80106aee:	6a 00                	push   $0x0
  pushl $69
80106af0:	6a 45                	push   $0x45
  jmp alltraps
80106af2:	e9 73 f7 ff ff       	jmp    8010626a <alltraps>

80106af7 <vector70>:
.globl vector70
vector70:
  pushl $0
80106af7:	6a 00                	push   $0x0
  pushl $70
80106af9:	6a 46                	push   $0x46
  jmp alltraps
80106afb:	e9 6a f7 ff ff       	jmp    8010626a <alltraps>

80106b00 <vector71>:
.globl vector71
vector71:
  pushl $0
80106b00:	6a 00                	push   $0x0
  pushl $71
80106b02:	6a 47                	push   $0x47
  jmp alltraps
80106b04:	e9 61 f7 ff ff       	jmp    8010626a <alltraps>

80106b09 <vector72>:
.globl vector72
vector72:
  pushl $0
80106b09:	6a 00                	push   $0x0
  pushl $72
80106b0b:	6a 48                	push   $0x48
  jmp alltraps
80106b0d:	e9 58 f7 ff ff       	jmp    8010626a <alltraps>

80106b12 <vector73>:
.globl vector73
vector73:
  pushl $0
80106b12:	6a 00                	push   $0x0
  pushl $73
80106b14:	6a 49                	push   $0x49
  jmp alltraps
80106b16:	e9 4f f7 ff ff       	jmp    8010626a <alltraps>

80106b1b <vector74>:
.globl vector74
vector74:
  pushl $0
80106b1b:	6a 00                	push   $0x0
  pushl $74
80106b1d:	6a 4a                	push   $0x4a
  jmp alltraps
80106b1f:	e9 46 f7 ff ff       	jmp    8010626a <alltraps>

80106b24 <vector75>:
.globl vector75
vector75:
  pushl $0
80106b24:	6a 00                	push   $0x0
  pushl $75
80106b26:	6a 4b                	push   $0x4b
  jmp alltraps
80106b28:	e9 3d f7 ff ff       	jmp    8010626a <alltraps>

80106b2d <vector76>:
.globl vector76
vector76:
  pushl $0
80106b2d:	6a 00                	push   $0x0
  pushl $76
80106b2f:	6a 4c                	push   $0x4c
  jmp alltraps
80106b31:	e9 34 f7 ff ff       	jmp    8010626a <alltraps>

80106b36 <vector77>:
.globl vector77
vector77:
  pushl $0
80106b36:	6a 00                	push   $0x0
  pushl $77
80106b38:	6a 4d                	push   $0x4d
  jmp alltraps
80106b3a:	e9 2b f7 ff ff       	jmp    8010626a <alltraps>

80106b3f <vector78>:
.globl vector78
vector78:
  pushl $0
80106b3f:	6a 00                	push   $0x0
  pushl $78
80106b41:	6a 4e                	push   $0x4e
  jmp alltraps
80106b43:	e9 22 f7 ff ff       	jmp    8010626a <alltraps>

80106b48 <vector79>:
.globl vector79
vector79:
  pushl $0
80106b48:	6a 00                	push   $0x0
  pushl $79
80106b4a:	6a 4f                	push   $0x4f
  jmp alltraps
80106b4c:	e9 19 f7 ff ff       	jmp    8010626a <alltraps>

80106b51 <vector80>:
.globl vector80
vector80:
  pushl $0
80106b51:	6a 00                	push   $0x0
  pushl $80
80106b53:	6a 50                	push   $0x50
  jmp alltraps
80106b55:	e9 10 f7 ff ff       	jmp    8010626a <alltraps>

80106b5a <vector81>:
.globl vector81
vector81:
  pushl $0
80106b5a:	6a 00                	push   $0x0
  pushl $81
80106b5c:	6a 51                	push   $0x51
  jmp alltraps
80106b5e:	e9 07 f7 ff ff       	jmp    8010626a <alltraps>

80106b63 <vector82>:
.globl vector82
vector82:
  pushl $0
80106b63:	6a 00                	push   $0x0
  pushl $82
80106b65:	6a 52                	push   $0x52
  jmp alltraps
80106b67:	e9 fe f6 ff ff       	jmp    8010626a <alltraps>

80106b6c <vector83>:
.globl vector83
vector83:
  pushl $0
80106b6c:	6a 00                	push   $0x0
  pushl $83
80106b6e:	6a 53                	push   $0x53
  jmp alltraps
80106b70:	e9 f5 f6 ff ff       	jmp    8010626a <alltraps>

80106b75 <vector84>:
.globl vector84
vector84:
  pushl $0
80106b75:	6a 00                	push   $0x0
  pushl $84
80106b77:	6a 54                	push   $0x54
  jmp alltraps
80106b79:	e9 ec f6 ff ff       	jmp    8010626a <alltraps>

80106b7e <vector85>:
.globl vector85
vector85:
  pushl $0
80106b7e:	6a 00                	push   $0x0
  pushl $85
80106b80:	6a 55                	push   $0x55
  jmp alltraps
80106b82:	e9 e3 f6 ff ff       	jmp    8010626a <alltraps>

80106b87 <vector86>:
.globl vector86
vector86:
  pushl $0
80106b87:	6a 00                	push   $0x0
  pushl $86
80106b89:	6a 56                	push   $0x56
  jmp alltraps
80106b8b:	e9 da f6 ff ff       	jmp    8010626a <alltraps>

80106b90 <vector87>:
.globl vector87
vector87:
  pushl $0
80106b90:	6a 00                	push   $0x0
  pushl $87
80106b92:	6a 57                	push   $0x57
  jmp alltraps
80106b94:	e9 d1 f6 ff ff       	jmp    8010626a <alltraps>

80106b99 <vector88>:
.globl vector88
vector88:
  pushl $0
80106b99:	6a 00                	push   $0x0
  pushl $88
80106b9b:	6a 58                	push   $0x58
  jmp alltraps
80106b9d:	e9 c8 f6 ff ff       	jmp    8010626a <alltraps>

80106ba2 <vector89>:
.globl vector89
vector89:
  pushl $0
80106ba2:	6a 00                	push   $0x0
  pushl $89
80106ba4:	6a 59                	push   $0x59
  jmp alltraps
80106ba6:	e9 bf f6 ff ff       	jmp    8010626a <alltraps>

80106bab <vector90>:
.globl vector90
vector90:
  pushl $0
80106bab:	6a 00                	push   $0x0
  pushl $90
80106bad:	6a 5a                	push   $0x5a
  jmp alltraps
80106baf:	e9 b6 f6 ff ff       	jmp    8010626a <alltraps>

80106bb4 <vector91>:
.globl vector91
vector91:
  pushl $0
80106bb4:	6a 00                	push   $0x0
  pushl $91
80106bb6:	6a 5b                	push   $0x5b
  jmp alltraps
80106bb8:	e9 ad f6 ff ff       	jmp    8010626a <alltraps>

80106bbd <vector92>:
.globl vector92
vector92:
  pushl $0
80106bbd:	6a 00                	push   $0x0
  pushl $92
80106bbf:	6a 5c                	push   $0x5c
  jmp alltraps
80106bc1:	e9 a4 f6 ff ff       	jmp    8010626a <alltraps>

80106bc6 <vector93>:
.globl vector93
vector93:
  pushl $0
80106bc6:	6a 00                	push   $0x0
  pushl $93
80106bc8:	6a 5d                	push   $0x5d
  jmp alltraps
80106bca:	e9 9b f6 ff ff       	jmp    8010626a <alltraps>

80106bcf <vector94>:
.globl vector94
vector94:
  pushl $0
80106bcf:	6a 00                	push   $0x0
  pushl $94
80106bd1:	6a 5e                	push   $0x5e
  jmp alltraps
80106bd3:	e9 92 f6 ff ff       	jmp    8010626a <alltraps>

80106bd8 <vector95>:
.globl vector95
vector95:
  pushl $0
80106bd8:	6a 00                	push   $0x0
  pushl $95
80106bda:	6a 5f                	push   $0x5f
  jmp alltraps
80106bdc:	e9 89 f6 ff ff       	jmp    8010626a <alltraps>

80106be1 <vector96>:
.globl vector96
vector96:
  pushl $0
80106be1:	6a 00                	push   $0x0
  pushl $96
80106be3:	6a 60                	push   $0x60
  jmp alltraps
80106be5:	e9 80 f6 ff ff       	jmp    8010626a <alltraps>

80106bea <vector97>:
.globl vector97
vector97:
  pushl $0
80106bea:	6a 00                	push   $0x0
  pushl $97
80106bec:	6a 61                	push   $0x61
  jmp alltraps
80106bee:	e9 77 f6 ff ff       	jmp    8010626a <alltraps>

80106bf3 <vector98>:
.globl vector98
vector98:
  pushl $0
80106bf3:	6a 00                	push   $0x0
  pushl $98
80106bf5:	6a 62                	push   $0x62
  jmp alltraps
80106bf7:	e9 6e f6 ff ff       	jmp    8010626a <alltraps>

80106bfc <vector99>:
.globl vector99
vector99:
  pushl $0
80106bfc:	6a 00                	push   $0x0
  pushl $99
80106bfe:	6a 63                	push   $0x63
  jmp alltraps
80106c00:	e9 65 f6 ff ff       	jmp    8010626a <alltraps>

80106c05 <vector100>:
.globl vector100
vector100:
  pushl $0
80106c05:	6a 00                	push   $0x0
  pushl $100
80106c07:	6a 64                	push   $0x64
  jmp alltraps
80106c09:	e9 5c f6 ff ff       	jmp    8010626a <alltraps>

80106c0e <vector101>:
.globl vector101
vector101:
  pushl $0
80106c0e:	6a 00                	push   $0x0
  pushl $101
80106c10:	6a 65                	push   $0x65
  jmp alltraps
80106c12:	e9 53 f6 ff ff       	jmp    8010626a <alltraps>

80106c17 <vector102>:
.globl vector102
vector102:
  pushl $0
80106c17:	6a 00                	push   $0x0
  pushl $102
80106c19:	6a 66                	push   $0x66
  jmp alltraps
80106c1b:	e9 4a f6 ff ff       	jmp    8010626a <alltraps>

80106c20 <vector103>:
.globl vector103
vector103:
  pushl $0
80106c20:	6a 00                	push   $0x0
  pushl $103
80106c22:	6a 67                	push   $0x67
  jmp alltraps
80106c24:	e9 41 f6 ff ff       	jmp    8010626a <alltraps>

80106c29 <vector104>:
.globl vector104
vector104:
  pushl $0
80106c29:	6a 00                	push   $0x0
  pushl $104
80106c2b:	6a 68                	push   $0x68
  jmp alltraps
80106c2d:	e9 38 f6 ff ff       	jmp    8010626a <alltraps>

80106c32 <vector105>:
.globl vector105
vector105:
  pushl $0
80106c32:	6a 00                	push   $0x0
  pushl $105
80106c34:	6a 69                	push   $0x69
  jmp alltraps
80106c36:	e9 2f f6 ff ff       	jmp    8010626a <alltraps>

80106c3b <vector106>:
.globl vector106
vector106:
  pushl $0
80106c3b:	6a 00                	push   $0x0
  pushl $106
80106c3d:	6a 6a                	push   $0x6a
  jmp alltraps
80106c3f:	e9 26 f6 ff ff       	jmp    8010626a <alltraps>

80106c44 <vector107>:
.globl vector107
vector107:
  pushl $0
80106c44:	6a 00                	push   $0x0
  pushl $107
80106c46:	6a 6b                	push   $0x6b
  jmp alltraps
80106c48:	e9 1d f6 ff ff       	jmp    8010626a <alltraps>

80106c4d <vector108>:
.globl vector108
vector108:
  pushl $0
80106c4d:	6a 00                	push   $0x0
  pushl $108
80106c4f:	6a 6c                	push   $0x6c
  jmp alltraps
80106c51:	e9 14 f6 ff ff       	jmp    8010626a <alltraps>

80106c56 <vector109>:
.globl vector109
vector109:
  pushl $0
80106c56:	6a 00                	push   $0x0
  pushl $109
80106c58:	6a 6d                	push   $0x6d
  jmp alltraps
80106c5a:	e9 0b f6 ff ff       	jmp    8010626a <alltraps>

80106c5f <vector110>:
.globl vector110
vector110:
  pushl $0
80106c5f:	6a 00                	push   $0x0
  pushl $110
80106c61:	6a 6e                	push   $0x6e
  jmp alltraps
80106c63:	e9 02 f6 ff ff       	jmp    8010626a <alltraps>

80106c68 <vector111>:
.globl vector111
vector111:
  pushl $0
80106c68:	6a 00                	push   $0x0
  pushl $111
80106c6a:	6a 6f                	push   $0x6f
  jmp alltraps
80106c6c:	e9 f9 f5 ff ff       	jmp    8010626a <alltraps>

80106c71 <vector112>:
.globl vector112
vector112:
  pushl $0
80106c71:	6a 00                	push   $0x0
  pushl $112
80106c73:	6a 70                	push   $0x70
  jmp alltraps
80106c75:	e9 f0 f5 ff ff       	jmp    8010626a <alltraps>

80106c7a <vector113>:
.globl vector113
vector113:
  pushl $0
80106c7a:	6a 00                	push   $0x0
  pushl $113
80106c7c:	6a 71                	push   $0x71
  jmp alltraps
80106c7e:	e9 e7 f5 ff ff       	jmp    8010626a <alltraps>

80106c83 <vector114>:
.globl vector114
vector114:
  pushl $0
80106c83:	6a 00                	push   $0x0
  pushl $114
80106c85:	6a 72                	push   $0x72
  jmp alltraps
80106c87:	e9 de f5 ff ff       	jmp    8010626a <alltraps>

80106c8c <vector115>:
.globl vector115
vector115:
  pushl $0
80106c8c:	6a 00                	push   $0x0
  pushl $115
80106c8e:	6a 73                	push   $0x73
  jmp alltraps
80106c90:	e9 d5 f5 ff ff       	jmp    8010626a <alltraps>

80106c95 <vector116>:
.globl vector116
vector116:
  pushl $0
80106c95:	6a 00                	push   $0x0
  pushl $116
80106c97:	6a 74                	push   $0x74
  jmp alltraps
80106c99:	e9 cc f5 ff ff       	jmp    8010626a <alltraps>

80106c9e <vector117>:
.globl vector117
vector117:
  pushl $0
80106c9e:	6a 00                	push   $0x0
  pushl $117
80106ca0:	6a 75                	push   $0x75
  jmp alltraps
80106ca2:	e9 c3 f5 ff ff       	jmp    8010626a <alltraps>

80106ca7 <vector118>:
.globl vector118
vector118:
  pushl $0
80106ca7:	6a 00                	push   $0x0
  pushl $118
80106ca9:	6a 76                	push   $0x76
  jmp alltraps
80106cab:	e9 ba f5 ff ff       	jmp    8010626a <alltraps>

80106cb0 <vector119>:
.globl vector119
vector119:
  pushl $0
80106cb0:	6a 00                	push   $0x0
  pushl $119
80106cb2:	6a 77                	push   $0x77
  jmp alltraps
80106cb4:	e9 b1 f5 ff ff       	jmp    8010626a <alltraps>

80106cb9 <vector120>:
.globl vector120
vector120:
  pushl $0
80106cb9:	6a 00                	push   $0x0
  pushl $120
80106cbb:	6a 78                	push   $0x78
  jmp alltraps
80106cbd:	e9 a8 f5 ff ff       	jmp    8010626a <alltraps>

80106cc2 <vector121>:
.globl vector121
vector121:
  pushl $0
80106cc2:	6a 00                	push   $0x0
  pushl $121
80106cc4:	6a 79                	push   $0x79
  jmp alltraps
80106cc6:	e9 9f f5 ff ff       	jmp    8010626a <alltraps>

80106ccb <vector122>:
.globl vector122
vector122:
  pushl $0
80106ccb:	6a 00                	push   $0x0
  pushl $122
80106ccd:	6a 7a                	push   $0x7a
  jmp alltraps
80106ccf:	e9 96 f5 ff ff       	jmp    8010626a <alltraps>

80106cd4 <vector123>:
.globl vector123
vector123:
  pushl $0
80106cd4:	6a 00                	push   $0x0
  pushl $123
80106cd6:	6a 7b                	push   $0x7b
  jmp alltraps
80106cd8:	e9 8d f5 ff ff       	jmp    8010626a <alltraps>

80106cdd <vector124>:
.globl vector124
vector124:
  pushl $0
80106cdd:	6a 00                	push   $0x0
  pushl $124
80106cdf:	6a 7c                	push   $0x7c
  jmp alltraps
80106ce1:	e9 84 f5 ff ff       	jmp    8010626a <alltraps>

80106ce6 <vector125>:
.globl vector125
vector125:
  pushl $0
80106ce6:	6a 00                	push   $0x0
  pushl $125
80106ce8:	6a 7d                	push   $0x7d
  jmp alltraps
80106cea:	e9 7b f5 ff ff       	jmp    8010626a <alltraps>

80106cef <vector126>:
.globl vector126
vector126:
  pushl $0
80106cef:	6a 00                	push   $0x0
  pushl $126
80106cf1:	6a 7e                	push   $0x7e
  jmp alltraps
80106cf3:	e9 72 f5 ff ff       	jmp    8010626a <alltraps>

80106cf8 <vector127>:
.globl vector127
vector127:
  pushl $0
80106cf8:	6a 00                	push   $0x0
  pushl $127
80106cfa:	6a 7f                	push   $0x7f
  jmp alltraps
80106cfc:	e9 69 f5 ff ff       	jmp    8010626a <alltraps>

80106d01 <vector128>:
.globl vector128
vector128:
  pushl $0
80106d01:	6a 00                	push   $0x0
  pushl $128
80106d03:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106d08:	e9 5d f5 ff ff       	jmp    8010626a <alltraps>

80106d0d <vector129>:
.globl vector129
vector129:
  pushl $0
80106d0d:	6a 00                	push   $0x0
  pushl $129
80106d0f:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106d14:	e9 51 f5 ff ff       	jmp    8010626a <alltraps>

80106d19 <vector130>:
.globl vector130
vector130:
  pushl $0
80106d19:	6a 00                	push   $0x0
  pushl $130
80106d1b:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106d20:	e9 45 f5 ff ff       	jmp    8010626a <alltraps>

80106d25 <vector131>:
.globl vector131
vector131:
  pushl $0
80106d25:	6a 00                	push   $0x0
  pushl $131
80106d27:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106d2c:	e9 39 f5 ff ff       	jmp    8010626a <alltraps>

80106d31 <vector132>:
.globl vector132
vector132:
  pushl $0
80106d31:	6a 00                	push   $0x0
  pushl $132
80106d33:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106d38:	e9 2d f5 ff ff       	jmp    8010626a <alltraps>

80106d3d <vector133>:
.globl vector133
vector133:
  pushl $0
80106d3d:	6a 00                	push   $0x0
  pushl $133
80106d3f:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106d44:	e9 21 f5 ff ff       	jmp    8010626a <alltraps>

80106d49 <vector134>:
.globl vector134
vector134:
  pushl $0
80106d49:	6a 00                	push   $0x0
  pushl $134
80106d4b:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106d50:	e9 15 f5 ff ff       	jmp    8010626a <alltraps>

80106d55 <vector135>:
.globl vector135
vector135:
  pushl $0
80106d55:	6a 00                	push   $0x0
  pushl $135
80106d57:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106d5c:	e9 09 f5 ff ff       	jmp    8010626a <alltraps>

80106d61 <vector136>:
.globl vector136
vector136:
  pushl $0
80106d61:	6a 00                	push   $0x0
  pushl $136
80106d63:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106d68:	e9 fd f4 ff ff       	jmp    8010626a <alltraps>

80106d6d <vector137>:
.globl vector137
vector137:
  pushl $0
80106d6d:	6a 00                	push   $0x0
  pushl $137
80106d6f:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106d74:	e9 f1 f4 ff ff       	jmp    8010626a <alltraps>

80106d79 <vector138>:
.globl vector138
vector138:
  pushl $0
80106d79:	6a 00                	push   $0x0
  pushl $138
80106d7b:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106d80:	e9 e5 f4 ff ff       	jmp    8010626a <alltraps>

80106d85 <vector139>:
.globl vector139
vector139:
  pushl $0
80106d85:	6a 00                	push   $0x0
  pushl $139
80106d87:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106d8c:	e9 d9 f4 ff ff       	jmp    8010626a <alltraps>

80106d91 <vector140>:
.globl vector140
vector140:
  pushl $0
80106d91:	6a 00                	push   $0x0
  pushl $140
80106d93:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106d98:	e9 cd f4 ff ff       	jmp    8010626a <alltraps>

80106d9d <vector141>:
.globl vector141
vector141:
  pushl $0
80106d9d:	6a 00                	push   $0x0
  pushl $141
80106d9f:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106da4:	e9 c1 f4 ff ff       	jmp    8010626a <alltraps>

80106da9 <vector142>:
.globl vector142
vector142:
  pushl $0
80106da9:	6a 00                	push   $0x0
  pushl $142
80106dab:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106db0:	e9 b5 f4 ff ff       	jmp    8010626a <alltraps>

80106db5 <vector143>:
.globl vector143
vector143:
  pushl $0
80106db5:	6a 00                	push   $0x0
  pushl $143
80106db7:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106dbc:	e9 a9 f4 ff ff       	jmp    8010626a <alltraps>

80106dc1 <vector144>:
.globl vector144
vector144:
  pushl $0
80106dc1:	6a 00                	push   $0x0
  pushl $144
80106dc3:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106dc8:	e9 9d f4 ff ff       	jmp    8010626a <alltraps>

80106dcd <vector145>:
.globl vector145
vector145:
  pushl $0
80106dcd:	6a 00                	push   $0x0
  pushl $145
80106dcf:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106dd4:	e9 91 f4 ff ff       	jmp    8010626a <alltraps>

80106dd9 <vector146>:
.globl vector146
vector146:
  pushl $0
80106dd9:	6a 00                	push   $0x0
  pushl $146
80106ddb:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106de0:	e9 85 f4 ff ff       	jmp    8010626a <alltraps>

80106de5 <vector147>:
.globl vector147
vector147:
  pushl $0
80106de5:	6a 00                	push   $0x0
  pushl $147
80106de7:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106dec:	e9 79 f4 ff ff       	jmp    8010626a <alltraps>

80106df1 <vector148>:
.globl vector148
vector148:
  pushl $0
80106df1:	6a 00                	push   $0x0
  pushl $148
80106df3:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106df8:	e9 6d f4 ff ff       	jmp    8010626a <alltraps>

80106dfd <vector149>:
.globl vector149
vector149:
  pushl $0
80106dfd:	6a 00                	push   $0x0
  pushl $149
80106dff:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106e04:	e9 61 f4 ff ff       	jmp    8010626a <alltraps>

80106e09 <vector150>:
.globl vector150
vector150:
  pushl $0
80106e09:	6a 00                	push   $0x0
  pushl $150
80106e0b:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106e10:	e9 55 f4 ff ff       	jmp    8010626a <alltraps>

80106e15 <vector151>:
.globl vector151
vector151:
  pushl $0
80106e15:	6a 00                	push   $0x0
  pushl $151
80106e17:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106e1c:	e9 49 f4 ff ff       	jmp    8010626a <alltraps>

80106e21 <vector152>:
.globl vector152
vector152:
  pushl $0
80106e21:	6a 00                	push   $0x0
  pushl $152
80106e23:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106e28:	e9 3d f4 ff ff       	jmp    8010626a <alltraps>

80106e2d <vector153>:
.globl vector153
vector153:
  pushl $0
80106e2d:	6a 00                	push   $0x0
  pushl $153
80106e2f:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106e34:	e9 31 f4 ff ff       	jmp    8010626a <alltraps>

80106e39 <vector154>:
.globl vector154
vector154:
  pushl $0
80106e39:	6a 00                	push   $0x0
  pushl $154
80106e3b:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106e40:	e9 25 f4 ff ff       	jmp    8010626a <alltraps>

80106e45 <vector155>:
.globl vector155
vector155:
  pushl $0
80106e45:	6a 00                	push   $0x0
  pushl $155
80106e47:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106e4c:	e9 19 f4 ff ff       	jmp    8010626a <alltraps>

80106e51 <vector156>:
.globl vector156
vector156:
  pushl $0
80106e51:	6a 00                	push   $0x0
  pushl $156
80106e53:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106e58:	e9 0d f4 ff ff       	jmp    8010626a <alltraps>

80106e5d <vector157>:
.globl vector157
vector157:
  pushl $0
80106e5d:	6a 00                	push   $0x0
  pushl $157
80106e5f:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106e64:	e9 01 f4 ff ff       	jmp    8010626a <alltraps>

80106e69 <vector158>:
.globl vector158
vector158:
  pushl $0
80106e69:	6a 00                	push   $0x0
  pushl $158
80106e6b:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106e70:	e9 f5 f3 ff ff       	jmp    8010626a <alltraps>

80106e75 <vector159>:
.globl vector159
vector159:
  pushl $0
80106e75:	6a 00                	push   $0x0
  pushl $159
80106e77:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106e7c:	e9 e9 f3 ff ff       	jmp    8010626a <alltraps>

80106e81 <vector160>:
.globl vector160
vector160:
  pushl $0
80106e81:	6a 00                	push   $0x0
  pushl $160
80106e83:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106e88:	e9 dd f3 ff ff       	jmp    8010626a <alltraps>

80106e8d <vector161>:
.globl vector161
vector161:
  pushl $0
80106e8d:	6a 00                	push   $0x0
  pushl $161
80106e8f:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106e94:	e9 d1 f3 ff ff       	jmp    8010626a <alltraps>

80106e99 <vector162>:
.globl vector162
vector162:
  pushl $0
80106e99:	6a 00                	push   $0x0
  pushl $162
80106e9b:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106ea0:	e9 c5 f3 ff ff       	jmp    8010626a <alltraps>

80106ea5 <vector163>:
.globl vector163
vector163:
  pushl $0
80106ea5:	6a 00                	push   $0x0
  pushl $163
80106ea7:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106eac:	e9 b9 f3 ff ff       	jmp    8010626a <alltraps>

80106eb1 <vector164>:
.globl vector164
vector164:
  pushl $0
80106eb1:	6a 00                	push   $0x0
  pushl $164
80106eb3:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106eb8:	e9 ad f3 ff ff       	jmp    8010626a <alltraps>

80106ebd <vector165>:
.globl vector165
vector165:
  pushl $0
80106ebd:	6a 00                	push   $0x0
  pushl $165
80106ebf:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106ec4:	e9 a1 f3 ff ff       	jmp    8010626a <alltraps>

80106ec9 <vector166>:
.globl vector166
vector166:
  pushl $0
80106ec9:	6a 00                	push   $0x0
  pushl $166
80106ecb:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106ed0:	e9 95 f3 ff ff       	jmp    8010626a <alltraps>

80106ed5 <vector167>:
.globl vector167
vector167:
  pushl $0
80106ed5:	6a 00                	push   $0x0
  pushl $167
80106ed7:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106edc:	e9 89 f3 ff ff       	jmp    8010626a <alltraps>

80106ee1 <vector168>:
.globl vector168
vector168:
  pushl $0
80106ee1:	6a 00                	push   $0x0
  pushl $168
80106ee3:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106ee8:	e9 7d f3 ff ff       	jmp    8010626a <alltraps>

80106eed <vector169>:
.globl vector169
vector169:
  pushl $0
80106eed:	6a 00                	push   $0x0
  pushl $169
80106eef:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106ef4:	e9 71 f3 ff ff       	jmp    8010626a <alltraps>

80106ef9 <vector170>:
.globl vector170
vector170:
  pushl $0
80106ef9:	6a 00                	push   $0x0
  pushl $170
80106efb:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106f00:	e9 65 f3 ff ff       	jmp    8010626a <alltraps>

80106f05 <vector171>:
.globl vector171
vector171:
  pushl $0
80106f05:	6a 00                	push   $0x0
  pushl $171
80106f07:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106f0c:	e9 59 f3 ff ff       	jmp    8010626a <alltraps>

80106f11 <vector172>:
.globl vector172
vector172:
  pushl $0
80106f11:	6a 00                	push   $0x0
  pushl $172
80106f13:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106f18:	e9 4d f3 ff ff       	jmp    8010626a <alltraps>

80106f1d <vector173>:
.globl vector173
vector173:
  pushl $0
80106f1d:	6a 00                	push   $0x0
  pushl $173
80106f1f:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106f24:	e9 41 f3 ff ff       	jmp    8010626a <alltraps>

80106f29 <vector174>:
.globl vector174
vector174:
  pushl $0
80106f29:	6a 00                	push   $0x0
  pushl $174
80106f2b:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106f30:	e9 35 f3 ff ff       	jmp    8010626a <alltraps>

80106f35 <vector175>:
.globl vector175
vector175:
  pushl $0
80106f35:	6a 00                	push   $0x0
  pushl $175
80106f37:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106f3c:	e9 29 f3 ff ff       	jmp    8010626a <alltraps>

80106f41 <vector176>:
.globl vector176
vector176:
  pushl $0
80106f41:	6a 00                	push   $0x0
  pushl $176
80106f43:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106f48:	e9 1d f3 ff ff       	jmp    8010626a <alltraps>

80106f4d <vector177>:
.globl vector177
vector177:
  pushl $0
80106f4d:	6a 00                	push   $0x0
  pushl $177
80106f4f:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106f54:	e9 11 f3 ff ff       	jmp    8010626a <alltraps>

80106f59 <vector178>:
.globl vector178
vector178:
  pushl $0
80106f59:	6a 00                	push   $0x0
  pushl $178
80106f5b:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106f60:	e9 05 f3 ff ff       	jmp    8010626a <alltraps>

80106f65 <vector179>:
.globl vector179
vector179:
  pushl $0
80106f65:	6a 00                	push   $0x0
  pushl $179
80106f67:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106f6c:	e9 f9 f2 ff ff       	jmp    8010626a <alltraps>

80106f71 <vector180>:
.globl vector180
vector180:
  pushl $0
80106f71:	6a 00                	push   $0x0
  pushl $180
80106f73:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106f78:	e9 ed f2 ff ff       	jmp    8010626a <alltraps>

80106f7d <vector181>:
.globl vector181
vector181:
  pushl $0
80106f7d:	6a 00                	push   $0x0
  pushl $181
80106f7f:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106f84:	e9 e1 f2 ff ff       	jmp    8010626a <alltraps>

80106f89 <vector182>:
.globl vector182
vector182:
  pushl $0
80106f89:	6a 00                	push   $0x0
  pushl $182
80106f8b:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106f90:	e9 d5 f2 ff ff       	jmp    8010626a <alltraps>

80106f95 <vector183>:
.globl vector183
vector183:
  pushl $0
80106f95:	6a 00                	push   $0x0
  pushl $183
80106f97:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106f9c:	e9 c9 f2 ff ff       	jmp    8010626a <alltraps>

80106fa1 <vector184>:
.globl vector184
vector184:
  pushl $0
80106fa1:	6a 00                	push   $0x0
  pushl $184
80106fa3:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106fa8:	e9 bd f2 ff ff       	jmp    8010626a <alltraps>

80106fad <vector185>:
.globl vector185
vector185:
  pushl $0
80106fad:	6a 00                	push   $0x0
  pushl $185
80106faf:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106fb4:	e9 b1 f2 ff ff       	jmp    8010626a <alltraps>

80106fb9 <vector186>:
.globl vector186
vector186:
  pushl $0
80106fb9:	6a 00                	push   $0x0
  pushl $186
80106fbb:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106fc0:	e9 a5 f2 ff ff       	jmp    8010626a <alltraps>

80106fc5 <vector187>:
.globl vector187
vector187:
  pushl $0
80106fc5:	6a 00                	push   $0x0
  pushl $187
80106fc7:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106fcc:	e9 99 f2 ff ff       	jmp    8010626a <alltraps>

80106fd1 <vector188>:
.globl vector188
vector188:
  pushl $0
80106fd1:	6a 00                	push   $0x0
  pushl $188
80106fd3:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106fd8:	e9 8d f2 ff ff       	jmp    8010626a <alltraps>

80106fdd <vector189>:
.globl vector189
vector189:
  pushl $0
80106fdd:	6a 00                	push   $0x0
  pushl $189
80106fdf:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106fe4:	e9 81 f2 ff ff       	jmp    8010626a <alltraps>

80106fe9 <vector190>:
.globl vector190
vector190:
  pushl $0
80106fe9:	6a 00                	push   $0x0
  pushl $190
80106feb:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106ff0:	e9 75 f2 ff ff       	jmp    8010626a <alltraps>

80106ff5 <vector191>:
.globl vector191
vector191:
  pushl $0
80106ff5:	6a 00                	push   $0x0
  pushl $191
80106ff7:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106ffc:	e9 69 f2 ff ff       	jmp    8010626a <alltraps>

80107001 <vector192>:
.globl vector192
vector192:
  pushl $0
80107001:	6a 00                	push   $0x0
  pushl $192
80107003:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107008:	e9 5d f2 ff ff       	jmp    8010626a <alltraps>

8010700d <vector193>:
.globl vector193
vector193:
  pushl $0
8010700d:	6a 00                	push   $0x0
  pushl $193
8010700f:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107014:	e9 51 f2 ff ff       	jmp    8010626a <alltraps>

80107019 <vector194>:
.globl vector194
vector194:
  pushl $0
80107019:	6a 00                	push   $0x0
  pushl $194
8010701b:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107020:	e9 45 f2 ff ff       	jmp    8010626a <alltraps>

80107025 <vector195>:
.globl vector195
vector195:
  pushl $0
80107025:	6a 00                	push   $0x0
  pushl $195
80107027:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010702c:	e9 39 f2 ff ff       	jmp    8010626a <alltraps>

80107031 <vector196>:
.globl vector196
vector196:
  pushl $0
80107031:	6a 00                	push   $0x0
  pushl $196
80107033:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107038:	e9 2d f2 ff ff       	jmp    8010626a <alltraps>

8010703d <vector197>:
.globl vector197
vector197:
  pushl $0
8010703d:	6a 00                	push   $0x0
  pushl $197
8010703f:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107044:	e9 21 f2 ff ff       	jmp    8010626a <alltraps>

80107049 <vector198>:
.globl vector198
vector198:
  pushl $0
80107049:	6a 00                	push   $0x0
  pushl $198
8010704b:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107050:	e9 15 f2 ff ff       	jmp    8010626a <alltraps>

80107055 <vector199>:
.globl vector199
vector199:
  pushl $0
80107055:	6a 00                	push   $0x0
  pushl $199
80107057:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010705c:	e9 09 f2 ff ff       	jmp    8010626a <alltraps>

80107061 <vector200>:
.globl vector200
vector200:
  pushl $0
80107061:	6a 00                	push   $0x0
  pushl $200
80107063:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107068:	e9 fd f1 ff ff       	jmp    8010626a <alltraps>

8010706d <vector201>:
.globl vector201
vector201:
  pushl $0
8010706d:	6a 00                	push   $0x0
  pushl $201
8010706f:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107074:	e9 f1 f1 ff ff       	jmp    8010626a <alltraps>

80107079 <vector202>:
.globl vector202
vector202:
  pushl $0
80107079:	6a 00                	push   $0x0
  pushl $202
8010707b:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107080:	e9 e5 f1 ff ff       	jmp    8010626a <alltraps>

80107085 <vector203>:
.globl vector203
vector203:
  pushl $0
80107085:	6a 00                	push   $0x0
  pushl $203
80107087:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010708c:	e9 d9 f1 ff ff       	jmp    8010626a <alltraps>

80107091 <vector204>:
.globl vector204
vector204:
  pushl $0
80107091:	6a 00                	push   $0x0
  pushl $204
80107093:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107098:	e9 cd f1 ff ff       	jmp    8010626a <alltraps>

8010709d <vector205>:
.globl vector205
vector205:
  pushl $0
8010709d:	6a 00                	push   $0x0
  pushl $205
8010709f:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801070a4:	e9 c1 f1 ff ff       	jmp    8010626a <alltraps>

801070a9 <vector206>:
.globl vector206
vector206:
  pushl $0
801070a9:	6a 00                	push   $0x0
  pushl $206
801070ab:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801070b0:	e9 b5 f1 ff ff       	jmp    8010626a <alltraps>

801070b5 <vector207>:
.globl vector207
vector207:
  pushl $0
801070b5:	6a 00                	push   $0x0
  pushl $207
801070b7:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801070bc:	e9 a9 f1 ff ff       	jmp    8010626a <alltraps>

801070c1 <vector208>:
.globl vector208
vector208:
  pushl $0
801070c1:	6a 00                	push   $0x0
  pushl $208
801070c3:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801070c8:	e9 9d f1 ff ff       	jmp    8010626a <alltraps>

801070cd <vector209>:
.globl vector209
vector209:
  pushl $0
801070cd:	6a 00                	push   $0x0
  pushl $209
801070cf:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801070d4:	e9 91 f1 ff ff       	jmp    8010626a <alltraps>

801070d9 <vector210>:
.globl vector210
vector210:
  pushl $0
801070d9:	6a 00                	push   $0x0
  pushl $210
801070db:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801070e0:	e9 85 f1 ff ff       	jmp    8010626a <alltraps>

801070e5 <vector211>:
.globl vector211
vector211:
  pushl $0
801070e5:	6a 00                	push   $0x0
  pushl $211
801070e7:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801070ec:	e9 79 f1 ff ff       	jmp    8010626a <alltraps>

801070f1 <vector212>:
.globl vector212
vector212:
  pushl $0
801070f1:	6a 00                	push   $0x0
  pushl $212
801070f3:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801070f8:	e9 6d f1 ff ff       	jmp    8010626a <alltraps>

801070fd <vector213>:
.globl vector213
vector213:
  pushl $0
801070fd:	6a 00                	push   $0x0
  pushl $213
801070ff:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107104:	e9 61 f1 ff ff       	jmp    8010626a <alltraps>

80107109 <vector214>:
.globl vector214
vector214:
  pushl $0
80107109:	6a 00                	push   $0x0
  pushl $214
8010710b:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107110:	e9 55 f1 ff ff       	jmp    8010626a <alltraps>

80107115 <vector215>:
.globl vector215
vector215:
  pushl $0
80107115:	6a 00                	push   $0x0
  pushl $215
80107117:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010711c:	e9 49 f1 ff ff       	jmp    8010626a <alltraps>

80107121 <vector216>:
.globl vector216
vector216:
  pushl $0
80107121:	6a 00                	push   $0x0
  pushl $216
80107123:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107128:	e9 3d f1 ff ff       	jmp    8010626a <alltraps>

8010712d <vector217>:
.globl vector217
vector217:
  pushl $0
8010712d:	6a 00                	push   $0x0
  pushl $217
8010712f:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107134:	e9 31 f1 ff ff       	jmp    8010626a <alltraps>

80107139 <vector218>:
.globl vector218
vector218:
  pushl $0
80107139:	6a 00                	push   $0x0
  pushl $218
8010713b:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107140:	e9 25 f1 ff ff       	jmp    8010626a <alltraps>

80107145 <vector219>:
.globl vector219
vector219:
  pushl $0
80107145:	6a 00                	push   $0x0
  pushl $219
80107147:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010714c:	e9 19 f1 ff ff       	jmp    8010626a <alltraps>

80107151 <vector220>:
.globl vector220
vector220:
  pushl $0
80107151:	6a 00                	push   $0x0
  pushl $220
80107153:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107158:	e9 0d f1 ff ff       	jmp    8010626a <alltraps>

8010715d <vector221>:
.globl vector221
vector221:
  pushl $0
8010715d:	6a 00                	push   $0x0
  pushl $221
8010715f:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107164:	e9 01 f1 ff ff       	jmp    8010626a <alltraps>

80107169 <vector222>:
.globl vector222
vector222:
  pushl $0
80107169:	6a 00                	push   $0x0
  pushl $222
8010716b:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107170:	e9 f5 f0 ff ff       	jmp    8010626a <alltraps>

80107175 <vector223>:
.globl vector223
vector223:
  pushl $0
80107175:	6a 00                	push   $0x0
  pushl $223
80107177:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010717c:	e9 e9 f0 ff ff       	jmp    8010626a <alltraps>

80107181 <vector224>:
.globl vector224
vector224:
  pushl $0
80107181:	6a 00                	push   $0x0
  pushl $224
80107183:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107188:	e9 dd f0 ff ff       	jmp    8010626a <alltraps>

8010718d <vector225>:
.globl vector225
vector225:
  pushl $0
8010718d:	6a 00                	push   $0x0
  pushl $225
8010718f:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107194:	e9 d1 f0 ff ff       	jmp    8010626a <alltraps>

80107199 <vector226>:
.globl vector226
vector226:
  pushl $0
80107199:	6a 00                	push   $0x0
  pushl $226
8010719b:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801071a0:	e9 c5 f0 ff ff       	jmp    8010626a <alltraps>

801071a5 <vector227>:
.globl vector227
vector227:
  pushl $0
801071a5:	6a 00                	push   $0x0
  pushl $227
801071a7:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801071ac:	e9 b9 f0 ff ff       	jmp    8010626a <alltraps>

801071b1 <vector228>:
.globl vector228
vector228:
  pushl $0
801071b1:	6a 00                	push   $0x0
  pushl $228
801071b3:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801071b8:	e9 ad f0 ff ff       	jmp    8010626a <alltraps>

801071bd <vector229>:
.globl vector229
vector229:
  pushl $0
801071bd:	6a 00                	push   $0x0
  pushl $229
801071bf:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801071c4:	e9 a1 f0 ff ff       	jmp    8010626a <alltraps>

801071c9 <vector230>:
.globl vector230
vector230:
  pushl $0
801071c9:	6a 00                	push   $0x0
  pushl $230
801071cb:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801071d0:	e9 95 f0 ff ff       	jmp    8010626a <alltraps>

801071d5 <vector231>:
.globl vector231
vector231:
  pushl $0
801071d5:	6a 00                	push   $0x0
  pushl $231
801071d7:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801071dc:	e9 89 f0 ff ff       	jmp    8010626a <alltraps>

801071e1 <vector232>:
.globl vector232
vector232:
  pushl $0
801071e1:	6a 00                	push   $0x0
  pushl $232
801071e3:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801071e8:	e9 7d f0 ff ff       	jmp    8010626a <alltraps>

801071ed <vector233>:
.globl vector233
vector233:
  pushl $0
801071ed:	6a 00                	push   $0x0
  pushl $233
801071ef:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801071f4:	e9 71 f0 ff ff       	jmp    8010626a <alltraps>

801071f9 <vector234>:
.globl vector234
vector234:
  pushl $0
801071f9:	6a 00                	push   $0x0
  pushl $234
801071fb:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107200:	e9 65 f0 ff ff       	jmp    8010626a <alltraps>

80107205 <vector235>:
.globl vector235
vector235:
  pushl $0
80107205:	6a 00                	push   $0x0
  pushl $235
80107207:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
8010720c:	e9 59 f0 ff ff       	jmp    8010626a <alltraps>

80107211 <vector236>:
.globl vector236
vector236:
  pushl $0
80107211:	6a 00                	push   $0x0
  pushl $236
80107213:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107218:	e9 4d f0 ff ff       	jmp    8010626a <alltraps>

8010721d <vector237>:
.globl vector237
vector237:
  pushl $0
8010721d:	6a 00                	push   $0x0
  pushl $237
8010721f:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107224:	e9 41 f0 ff ff       	jmp    8010626a <alltraps>

80107229 <vector238>:
.globl vector238
vector238:
  pushl $0
80107229:	6a 00                	push   $0x0
  pushl $238
8010722b:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107230:	e9 35 f0 ff ff       	jmp    8010626a <alltraps>

80107235 <vector239>:
.globl vector239
vector239:
  pushl $0
80107235:	6a 00                	push   $0x0
  pushl $239
80107237:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010723c:	e9 29 f0 ff ff       	jmp    8010626a <alltraps>

80107241 <vector240>:
.globl vector240
vector240:
  pushl $0
80107241:	6a 00                	push   $0x0
  pushl $240
80107243:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107248:	e9 1d f0 ff ff       	jmp    8010626a <alltraps>

8010724d <vector241>:
.globl vector241
vector241:
  pushl $0
8010724d:	6a 00                	push   $0x0
  pushl $241
8010724f:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107254:	e9 11 f0 ff ff       	jmp    8010626a <alltraps>

80107259 <vector242>:
.globl vector242
vector242:
  pushl $0
80107259:	6a 00                	push   $0x0
  pushl $242
8010725b:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107260:	e9 05 f0 ff ff       	jmp    8010626a <alltraps>

80107265 <vector243>:
.globl vector243
vector243:
  pushl $0
80107265:	6a 00                	push   $0x0
  pushl $243
80107267:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010726c:	e9 f9 ef ff ff       	jmp    8010626a <alltraps>

80107271 <vector244>:
.globl vector244
vector244:
  pushl $0
80107271:	6a 00                	push   $0x0
  pushl $244
80107273:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107278:	e9 ed ef ff ff       	jmp    8010626a <alltraps>

8010727d <vector245>:
.globl vector245
vector245:
  pushl $0
8010727d:	6a 00                	push   $0x0
  pushl $245
8010727f:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107284:	e9 e1 ef ff ff       	jmp    8010626a <alltraps>

80107289 <vector246>:
.globl vector246
vector246:
  pushl $0
80107289:	6a 00                	push   $0x0
  pushl $246
8010728b:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107290:	e9 d5 ef ff ff       	jmp    8010626a <alltraps>

80107295 <vector247>:
.globl vector247
vector247:
  pushl $0
80107295:	6a 00                	push   $0x0
  pushl $247
80107297:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010729c:	e9 c9 ef ff ff       	jmp    8010626a <alltraps>

801072a1 <vector248>:
.globl vector248
vector248:
  pushl $0
801072a1:	6a 00                	push   $0x0
  pushl $248
801072a3:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801072a8:	e9 bd ef ff ff       	jmp    8010626a <alltraps>

801072ad <vector249>:
.globl vector249
vector249:
  pushl $0
801072ad:	6a 00                	push   $0x0
  pushl $249
801072af:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801072b4:	e9 b1 ef ff ff       	jmp    8010626a <alltraps>

801072b9 <vector250>:
.globl vector250
vector250:
  pushl $0
801072b9:	6a 00                	push   $0x0
  pushl $250
801072bb:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801072c0:	e9 a5 ef ff ff       	jmp    8010626a <alltraps>

801072c5 <vector251>:
.globl vector251
vector251:
  pushl $0
801072c5:	6a 00                	push   $0x0
  pushl $251
801072c7:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801072cc:	e9 99 ef ff ff       	jmp    8010626a <alltraps>

801072d1 <vector252>:
.globl vector252
vector252:
  pushl $0
801072d1:	6a 00                	push   $0x0
  pushl $252
801072d3:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801072d8:	e9 8d ef ff ff       	jmp    8010626a <alltraps>

801072dd <vector253>:
.globl vector253
vector253:
  pushl $0
801072dd:	6a 00                	push   $0x0
  pushl $253
801072df:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801072e4:	e9 81 ef ff ff       	jmp    8010626a <alltraps>

801072e9 <vector254>:
.globl vector254
vector254:
  pushl $0
801072e9:	6a 00                	push   $0x0
  pushl $254
801072eb:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801072f0:	e9 75 ef ff ff       	jmp    8010626a <alltraps>

801072f5 <vector255>:
.globl vector255
vector255:
  pushl $0
801072f5:	6a 00                	push   $0x0
  pushl $255
801072f7:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801072fc:	e9 69 ef ff ff       	jmp    8010626a <alltraps>

80107301 <lgdt>:
{
80107301:	55                   	push   %ebp
80107302:	89 e5                	mov    %esp,%ebp
80107304:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107307:	8b 45 0c             	mov    0xc(%ebp),%eax
8010730a:	83 e8 01             	sub    $0x1,%eax
8010730d:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107311:	8b 45 08             	mov    0x8(%ebp),%eax
80107314:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107318:	8b 45 08             	mov    0x8(%ebp),%eax
8010731b:	c1 e8 10             	shr    $0x10,%eax
8010731e:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107322:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107325:	0f 01 10             	lgdtl  (%eax)
}
80107328:	90                   	nop
80107329:	c9                   	leave  
8010732a:	c3                   	ret    

8010732b <ltr>:
{
8010732b:	55                   	push   %ebp
8010732c:	89 e5                	mov    %esp,%ebp
8010732e:	83 ec 04             	sub    $0x4,%esp
80107331:	8b 45 08             	mov    0x8(%ebp),%eax
80107334:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107338:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010733c:	0f 00 d8             	ltr    %ax
}
8010733f:	90                   	nop
80107340:	c9                   	leave  
80107341:	c3                   	ret    

80107342 <loadgs>:
{
80107342:	55                   	push   %ebp
80107343:	89 e5                	mov    %esp,%ebp
80107345:	83 ec 04             	sub    $0x4,%esp
80107348:	8b 45 08             	mov    0x8(%ebp),%eax
8010734b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
8010734f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107353:	8e e8                	mov    %eax,%gs
}
80107355:	90                   	nop
80107356:	c9                   	leave  
80107357:	c3                   	ret    

80107358 <lcr3>:

static inline void
lcr3(uint val) 
{
80107358:	55                   	push   %ebp
80107359:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010735b:	8b 45 08             	mov    0x8(%ebp),%eax
8010735e:	0f 22 d8             	mov    %eax,%cr3
}
80107361:	90                   	nop
80107362:	5d                   	pop    %ebp
80107363:	c3                   	ret    

80107364 <v2p>:
static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107364:	55                   	push   %ebp
80107365:	89 e5                	mov    %esp,%ebp
80107367:	8b 45 08             	mov    0x8(%ebp),%eax
8010736a:	05 00 00 00 80       	add    $0x80000000,%eax
8010736f:	5d                   	pop    %ebp
80107370:	c3                   	ret    

80107371 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107371:	55                   	push   %ebp
80107372:	89 e5                	mov    %esp,%ebp
80107374:	8b 45 08             	mov    0x8(%ebp),%eax
80107377:	05 00 00 00 80       	add    $0x80000000,%eax
8010737c:	5d                   	pop    %ebp
8010737d:	c3                   	ret    

8010737e <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010737e:	55                   	push   %ebp
8010737f:	89 e5                	mov    %esp,%ebp
80107381:	53                   	push   %ebx
80107382:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107385:	e8 70 bb ff ff       	call   80102efa <cpunum>
8010738a:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107390:	05 20 f9 10 80       	add    $0x8010f920,%eax
80107395:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107398:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010739b:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801073a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073a4:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801073aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073ad:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801073b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073b4:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801073b8:	83 e2 f0             	and    $0xfffffff0,%edx
801073bb:	83 ca 0a             	or     $0xa,%edx
801073be:	88 50 7d             	mov    %dl,0x7d(%eax)
801073c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073c4:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801073c8:	83 ca 10             	or     $0x10,%edx
801073cb:	88 50 7d             	mov    %dl,0x7d(%eax)
801073ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d1:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801073d5:	83 e2 9f             	and    $0xffffff9f,%edx
801073d8:	88 50 7d             	mov    %dl,0x7d(%eax)
801073db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073de:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801073e2:	83 ca 80             	or     $0xffffff80,%edx
801073e5:	88 50 7d             	mov    %dl,0x7d(%eax)
801073e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073eb:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073ef:	83 ca 0f             	or     $0xf,%edx
801073f2:	88 50 7e             	mov    %dl,0x7e(%eax)
801073f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073f8:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073fc:	83 e2 ef             	and    $0xffffffef,%edx
801073ff:	88 50 7e             	mov    %dl,0x7e(%eax)
80107402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107405:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107409:	83 e2 df             	and    $0xffffffdf,%edx
8010740c:	88 50 7e             	mov    %dl,0x7e(%eax)
8010740f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107412:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107416:	83 ca 40             	or     $0x40,%edx
80107419:	88 50 7e             	mov    %dl,0x7e(%eax)
8010741c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010741f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107423:	83 ca 80             	or     $0xffffff80,%edx
80107426:	88 50 7e             	mov    %dl,0x7e(%eax)
80107429:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010742c:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107433:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010743a:	ff ff 
8010743c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010743f:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107446:	00 00 
80107448:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010744b:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107452:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107455:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010745c:	83 e2 f0             	and    $0xfffffff0,%edx
8010745f:	83 ca 02             	or     $0x2,%edx
80107462:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107468:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010746b:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107472:	83 ca 10             	or     $0x10,%edx
80107475:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010747b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010747e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107485:	83 e2 9f             	and    $0xffffff9f,%edx
80107488:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010748e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107491:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107498:	83 ca 80             	or     $0xffffff80,%edx
8010749b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801074a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074a4:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074ab:	83 ca 0f             	or     $0xf,%edx
801074ae:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074b7:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074be:	83 e2 ef             	and    $0xffffffef,%edx
801074c1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ca:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074d1:	83 e2 df             	and    $0xffffffdf,%edx
801074d4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074dd:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074e4:	83 ca 40             	or     $0x40,%edx
801074e7:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074f7:	83 ca 80             	or     $0xffffff80,%edx
801074fa:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107503:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010750a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010750d:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107514:	ff ff 
80107516:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107519:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107520:	00 00 
80107522:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107525:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010752c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010752f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107536:	83 e2 f0             	and    $0xfffffff0,%edx
80107539:	83 ca 0a             	or     $0xa,%edx
8010753c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107542:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107545:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010754c:	83 ca 10             	or     $0x10,%edx
8010754f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107555:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107558:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010755f:	83 ca 60             	or     $0x60,%edx
80107562:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107568:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010756b:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107572:	83 ca 80             	or     $0xffffff80,%edx
80107575:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010757b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010757e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107585:	83 ca 0f             	or     $0xf,%edx
80107588:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010758e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107591:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107598:	83 e2 ef             	and    $0xffffffef,%edx
8010759b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801075a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a4:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801075ab:	83 e2 df             	and    $0xffffffdf,%edx
801075ae:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801075b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b7:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801075be:	83 ca 40             	or     $0x40,%edx
801075c1:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801075c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ca:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801075d1:	83 ca 80             	or     $0xffffff80,%edx
801075d4:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801075da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075dd:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801075e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e7:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
801075ee:	ff ff 
801075f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f3:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
801075fa:	00 00 
801075fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ff:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107609:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107610:	83 e2 f0             	and    $0xfffffff0,%edx
80107613:	83 ca 02             	or     $0x2,%edx
80107616:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010761c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010761f:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107626:	83 ca 10             	or     $0x10,%edx
80107629:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010762f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107632:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107639:	83 ca 60             	or     $0x60,%edx
8010763c:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107642:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107645:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010764c:	83 ca 80             	or     $0xffffff80,%edx
8010764f:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107655:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107658:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010765f:	83 ca 0f             	or     $0xf,%edx
80107662:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107668:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010766b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107672:	83 e2 ef             	and    $0xffffffef,%edx
80107675:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010767b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010767e:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107685:	83 e2 df             	and    $0xffffffdf,%edx
80107688:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010768e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107691:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107698:	83 ca 40             	or     $0x40,%edx
8010769b:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801076a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a4:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801076ab:	83 ca 80             	or     $0xffffff80,%edx
801076ae:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801076b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b7:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801076be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c1:	05 b4 00 00 00       	add    $0xb4,%eax
801076c6:	89 c3                	mov    %eax,%ebx
801076c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076cb:	05 b4 00 00 00       	add    $0xb4,%eax
801076d0:	c1 e8 10             	shr    $0x10,%eax
801076d3:	89 c2                	mov    %eax,%edx
801076d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076d8:	05 b4 00 00 00       	add    $0xb4,%eax
801076dd:	c1 e8 18             	shr    $0x18,%eax
801076e0:	89 c1                	mov    %eax,%ecx
801076e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076e5:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
801076ec:	00 00 
801076ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f1:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
801076f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076fb:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80107701:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107704:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010770b:	83 e2 f0             	and    $0xfffffff0,%edx
8010770e:	83 ca 02             	or     $0x2,%edx
80107711:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107717:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010771a:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107721:	83 ca 10             	or     $0x10,%edx
80107724:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010772a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010772d:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107734:	83 e2 9f             	and    $0xffffff9f,%edx
80107737:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010773d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107740:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107747:	83 ca 80             	or     $0xffffff80,%edx
8010774a:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107750:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107753:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010775a:	83 e2 f0             	and    $0xfffffff0,%edx
8010775d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107763:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107766:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010776d:	83 e2 ef             	and    $0xffffffef,%edx
80107770:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107779:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107780:	83 e2 df             	and    $0xffffffdf,%edx
80107783:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107789:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010778c:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107793:	83 ca 40             	or     $0x40,%edx
80107796:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010779c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010779f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801077a6:	83 ca 80             	or     $0xffffff80,%edx
801077a9:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801077af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b2:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
801077b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077bb:	83 c0 70             	add    $0x70,%eax
801077be:	83 ec 08             	sub    $0x8,%esp
801077c1:	6a 38                	push   $0x38
801077c3:	50                   	push   %eax
801077c4:	e8 38 fb ff ff       	call   80107301 <lgdt>
801077c9:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
801077cc:	83 ec 0c             	sub    $0xc,%esp
801077cf:	6a 18                	push   $0x18
801077d1:	e8 6c fb ff ff       	call   80107342 <loadgs>
801077d6:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
801077d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077dc:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
801077e2:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801077e9:	00 00 00 00 
}
801077ed:	90                   	nop
801077ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801077f1:	c9                   	leave  
801077f2:	c3                   	ret    

801077f3 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801077f3:	55                   	push   %ebp
801077f4:	89 e5                	mov    %esp,%ebp
801077f6:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801077f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801077fc:	c1 e8 16             	shr    $0x16,%eax
801077ff:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107806:	8b 45 08             	mov    0x8(%ebp),%eax
80107809:	01 d0                	add    %edx,%eax
8010780b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
8010780e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107811:	8b 00                	mov    (%eax),%eax
80107813:	83 e0 01             	and    $0x1,%eax
80107816:	85 c0                	test   %eax,%eax
80107818:	74 18                	je     80107832 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
8010781a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010781d:	8b 00                	mov    (%eax),%eax
8010781f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107824:	50                   	push   %eax
80107825:	e8 47 fb ff ff       	call   80107371 <p2v>
8010782a:	83 c4 04             	add    $0x4,%esp
8010782d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107830:	eb 48                	jmp    8010787a <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107832:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107836:	74 0e                	je     80107846 <walkpgdir+0x53>
80107838:	e8 74 b3 ff ff       	call   80102bb1 <kalloc>
8010783d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107840:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107844:	75 07                	jne    8010784d <walkpgdir+0x5a>
      return 0;
80107846:	b8 00 00 00 00       	mov    $0x0,%eax
8010784b:	eb 44                	jmp    80107891 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
8010784d:	83 ec 04             	sub    $0x4,%esp
80107850:	68 00 10 00 00       	push   $0x1000
80107855:	6a 00                	push   $0x0
80107857:	ff 75 f4             	pushl  -0xc(%ebp)
8010785a:	e8 83 d6 ff ff       	call   80104ee2 <memset>
8010785f:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107862:	83 ec 0c             	sub    $0xc,%esp
80107865:	ff 75 f4             	pushl  -0xc(%ebp)
80107868:	e8 f7 fa ff ff       	call   80107364 <v2p>
8010786d:	83 c4 10             	add    $0x10,%esp
80107870:	83 c8 07             	or     $0x7,%eax
80107873:	89 c2                	mov    %eax,%edx
80107875:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107878:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010787a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010787d:	c1 e8 0c             	shr    $0xc,%eax
80107880:	25 ff 03 00 00       	and    $0x3ff,%eax
80107885:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010788c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010788f:	01 d0                	add    %edx,%eax
}
80107891:	c9                   	leave  
80107892:	c3                   	ret    

80107893 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107893:	55                   	push   %ebp
80107894:	89 e5                	mov    %esp,%ebp
80107896:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107899:	8b 45 0c             	mov    0xc(%ebp),%eax
8010789c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801078a4:	8b 55 0c             	mov    0xc(%ebp),%edx
801078a7:	8b 45 10             	mov    0x10(%ebp),%eax
801078aa:	01 d0                	add    %edx,%eax
801078ac:	83 e8 01             	sub    $0x1,%eax
801078af:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801078b7:	83 ec 04             	sub    $0x4,%esp
801078ba:	6a 01                	push   $0x1
801078bc:	ff 75 f4             	pushl  -0xc(%ebp)
801078bf:	ff 75 08             	pushl  0x8(%ebp)
801078c2:	e8 2c ff ff ff       	call   801077f3 <walkpgdir>
801078c7:	83 c4 10             	add    $0x10,%esp
801078ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
801078cd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801078d1:	75 07                	jne    801078da <mappages+0x47>
      return -1;
801078d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801078d8:	eb 47                	jmp    80107921 <mappages+0x8e>
    if(*pte & PTE_P)
801078da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801078dd:	8b 00                	mov    (%eax),%eax
801078df:	83 e0 01             	and    $0x1,%eax
801078e2:	85 c0                	test   %eax,%eax
801078e4:	74 0d                	je     801078f3 <mappages+0x60>
      panic("remap");
801078e6:	83 ec 0c             	sub    $0xc,%esp
801078e9:	68 38 87 10 80       	push   $0x80108738
801078ee:	e8 73 8c ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
801078f3:	8b 45 18             	mov    0x18(%ebp),%eax
801078f6:	0b 45 14             	or     0x14(%ebp),%eax
801078f9:	83 c8 01             	or     $0x1,%eax
801078fc:	89 c2                	mov    %eax,%edx
801078fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107901:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107903:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107906:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107909:	74 10                	je     8010791b <mappages+0x88>
      break;
    a += PGSIZE;
8010790b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107912:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107919:	eb 9c                	jmp    801078b7 <mappages+0x24>
      break;
8010791b:	90                   	nop
  }
  return 0;
8010791c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107921:	c9                   	leave  
80107922:	c3                   	ret    

80107923 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107923:	55                   	push   %ebp
80107924:	89 e5                	mov    %esp,%ebp
80107926:	53                   	push   %ebx
80107927:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
8010792a:	e8 82 b2 ff ff       	call   80102bb1 <kalloc>
8010792f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107932:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107936:	75 0a                	jne    80107942 <setupkvm+0x1f>
    return 0;
80107938:	b8 00 00 00 00       	mov    $0x0,%eax
8010793d:	e9 8e 00 00 00       	jmp    801079d0 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80107942:	83 ec 04             	sub    $0x4,%esp
80107945:	68 00 10 00 00       	push   $0x1000
8010794a:	6a 00                	push   $0x0
8010794c:	ff 75 f0             	pushl  -0x10(%ebp)
8010794f:	e8 8e d5 ff ff       	call   80104ee2 <memset>
80107954:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107957:	83 ec 0c             	sub    $0xc,%esp
8010795a:	68 00 00 00 0e       	push   $0xe000000
8010795f:	e8 0d fa ff ff       	call   80107371 <p2v>
80107964:	83 c4 10             	add    $0x10,%esp
80107967:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
8010796c:	76 0d                	jbe    8010797b <setupkvm+0x58>
    panic("PHYSTOP too high");
8010796e:	83 ec 0c             	sub    $0xc,%esp
80107971:	68 3e 87 10 80       	push   $0x8010873e
80107976:	e8 eb 8b ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010797b:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80107982:	eb 40                	jmp    801079c4 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107987:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
8010798a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010798d:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107990:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107993:	8b 58 08             	mov    0x8(%eax),%ebx
80107996:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107999:	8b 40 04             	mov    0x4(%eax),%eax
8010799c:	29 c3                	sub    %eax,%ebx
8010799e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a1:	8b 00                	mov    (%eax),%eax
801079a3:	83 ec 0c             	sub    $0xc,%esp
801079a6:	51                   	push   %ecx
801079a7:	52                   	push   %edx
801079a8:	53                   	push   %ebx
801079a9:	50                   	push   %eax
801079aa:	ff 75 f0             	pushl  -0x10(%ebp)
801079ad:	e8 e1 fe ff ff       	call   80107893 <mappages>
801079b2:	83 c4 20             	add    $0x20,%esp
801079b5:	85 c0                	test   %eax,%eax
801079b7:	79 07                	jns    801079c0 <setupkvm+0x9d>
      return 0;
801079b9:	b8 00 00 00 00       	mov    $0x0,%eax
801079be:	eb 10                	jmp    801079d0 <setupkvm+0xad>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801079c0:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801079c4:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
801079cb:	72 b7                	jb     80107984 <setupkvm+0x61>
  return pgdir;
801079cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801079d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801079d3:	c9                   	leave  
801079d4:	c3                   	ret    

801079d5 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801079d5:	55                   	push   %ebp
801079d6:	89 e5                	mov    %esp,%ebp
801079d8:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801079db:	e8 43 ff ff ff       	call   80107923 <setupkvm>
801079e0:	a3 f8 27 11 80       	mov    %eax,0x801127f8
  switchkvm();
801079e5:	e8 03 00 00 00       	call   801079ed <switchkvm>
}
801079ea:	90                   	nop
801079eb:	c9                   	leave  
801079ec:	c3                   	ret    

801079ed <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801079ed:	55                   	push   %ebp
801079ee:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
801079f0:	a1 f8 27 11 80       	mov    0x801127f8,%eax
801079f5:	50                   	push   %eax
801079f6:	e8 69 f9 ff ff       	call   80107364 <v2p>
801079fb:	83 c4 04             	add    $0x4,%esp
801079fe:	50                   	push   %eax
801079ff:	e8 54 f9 ff ff       	call   80107358 <lcr3>
80107a04:	83 c4 04             	add    $0x4,%esp
}
80107a07:	90                   	nop
80107a08:	c9                   	leave  
80107a09:	c3                   	ret    

80107a0a <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107a0a:	55                   	push   %ebp
80107a0b:	89 e5                	mov    %esp,%ebp
80107a0d:	56                   	push   %esi
80107a0e:	53                   	push   %ebx
  pushcli();
80107a0f:	e8 c8 d3 ff ff       	call   80104ddc <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107a14:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107a1a:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107a21:	83 c2 08             	add    $0x8,%edx
80107a24:	89 d6                	mov    %edx,%esi
80107a26:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107a2d:	83 c2 08             	add    $0x8,%edx
80107a30:	c1 ea 10             	shr    $0x10,%edx
80107a33:	89 d3                	mov    %edx,%ebx
80107a35:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107a3c:	83 c2 08             	add    $0x8,%edx
80107a3f:	c1 ea 18             	shr    $0x18,%edx
80107a42:	89 d1                	mov    %edx,%ecx
80107a44:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80107a4b:	67 00 
80107a4d:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80107a54:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80107a5a:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107a61:	83 e2 f0             	and    $0xfffffff0,%edx
80107a64:	83 ca 09             	or     $0x9,%edx
80107a67:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107a6d:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107a74:	83 ca 10             	or     $0x10,%edx
80107a77:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107a7d:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107a84:	83 e2 9f             	and    $0xffffff9f,%edx
80107a87:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107a8d:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107a94:	83 ca 80             	or     $0xffffff80,%edx
80107a97:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107a9d:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107aa4:	83 e2 f0             	and    $0xfffffff0,%edx
80107aa7:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107aad:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107ab4:	83 e2 ef             	and    $0xffffffef,%edx
80107ab7:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107abd:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107ac4:	83 e2 df             	and    $0xffffffdf,%edx
80107ac7:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107acd:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107ad4:	83 ca 40             	or     $0x40,%edx
80107ad7:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107add:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107ae4:	83 e2 7f             	and    $0x7f,%edx
80107ae7:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107aed:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80107af3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107af9:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107b00:	83 e2 ef             	and    $0xffffffef,%edx
80107b03:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80107b09:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107b0f:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107b15:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107b1b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80107b22:	8b 52 08             	mov    0x8(%edx),%edx
80107b25:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107b2b:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80107b2e:	83 ec 0c             	sub    $0xc,%esp
80107b31:	6a 30                	push   $0x30
80107b33:	e8 f3 f7 ff ff       	call   8010732b <ltr>
80107b38:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80107b3b:	8b 45 08             	mov    0x8(%ebp),%eax
80107b3e:	8b 40 04             	mov    0x4(%eax),%eax
80107b41:	85 c0                	test   %eax,%eax
80107b43:	75 0d                	jne    80107b52 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80107b45:	83 ec 0c             	sub    $0xc,%esp
80107b48:	68 4f 87 10 80       	push   $0x8010874f
80107b4d:	e8 14 8a ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80107b52:	8b 45 08             	mov    0x8(%ebp),%eax
80107b55:	8b 40 04             	mov    0x4(%eax),%eax
80107b58:	83 ec 0c             	sub    $0xc,%esp
80107b5b:	50                   	push   %eax
80107b5c:	e8 03 f8 ff ff       	call   80107364 <v2p>
80107b61:	83 c4 10             	add    $0x10,%esp
80107b64:	83 ec 0c             	sub    $0xc,%esp
80107b67:	50                   	push   %eax
80107b68:	e8 eb f7 ff ff       	call   80107358 <lcr3>
80107b6d:	83 c4 10             	add    $0x10,%esp
  popcli();
80107b70:	e8 ac d2 ff ff       	call   80104e21 <popcli>
}
80107b75:	90                   	nop
80107b76:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107b79:	5b                   	pop    %ebx
80107b7a:	5e                   	pop    %esi
80107b7b:	5d                   	pop    %ebp
80107b7c:	c3                   	ret    

80107b7d <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107b7d:	55                   	push   %ebp
80107b7e:	89 e5                	mov    %esp,%ebp
80107b80:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80107b83:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107b8a:	76 0d                	jbe    80107b99 <inituvm+0x1c>
    panic("inituvm: more than a page");
80107b8c:	83 ec 0c             	sub    $0xc,%esp
80107b8f:	68 63 87 10 80       	push   $0x80108763
80107b94:	e8 cd 89 ff ff       	call   80100566 <panic>
  mem = kalloc();
80107b99:	e8 13 b0 ff ff       	call   80102bb1 <kalloc>
80107b9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107ba1:	83 ec 04             	sub    $0x4,%esp
80107ba4:	68 00 10 00 00       	push   $0x1000
80107ba9:	6a 00                	push   $0x0
80107bab:	ff 75 f4             	pushl  -0xc(%ebp)
80107bae:	e8 2f d3 ff ff       	call   80104ee2 <memset>
80107bb3:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80107bb6:	83 ec 0c             	sub    $0xc,%esp
80107bb9:	ff 75 f4             	pushl  -0xc(%ebp)
80107bbc:	e8 a3 f7 ff ff       	call   80107364 <v2p>
80107bc1:	83 c4 10             	add    $0x10,%esp
80107bc4:	83 ec 0c             	sub    $0xc,%esp
80107bc7:	6a 06                	push   $0x6
80107bc9:	50                   	push   %eax
80107bca:	68 00 10 00 00       	push   $0x1000
80107bcf:	6a 00                	push   $0x0
80107bd1:	ff 75 08             	pushl  0x8(%ebp)
80107bd4:	e8 ba fc ff ff       	call   80107893 <mappages>
80107bd9:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107bdc:	83 ec 04             	sub    $0x4,%esp
80107bdf:	ff 75 10             	pushl  0x10(%ebp)
80107be2:	ff 75 0c             	pushl  0xc(%ebp)
80107be5:	ff 75 f4             	pushl  -0xc(%ebp)
80107be8:	e8 b4 d3 ff ff       	call   80104fa1 <memmove>
80107bed:	83 c4 10             	add    $0x10,%esp
}
80107bf0:	90                   	nop
80107bf1:	c9                   	leave  
80107bf2:	c3                   	ret    

80107bf3 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107bf3:	55                   	push   %ebp
80107bf4:	89 e5                	mov    %esp,%ebp
80107bf6:	53                   	push   %ebx
80107bf7:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107bfa:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bfd:	25 ff 0f 00 00       	and    $0xfff,%eax
80107c02:	85 c0                	test   %eax,%eax
80107c04:	74 0d                	je     80107c13 <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80107c06:	83 ec 0c             	sub    $0xc,%esp
80107c09:	68 80 87 10 80       	push   $0x80108780
80107c0e:	e8 53 89 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107c13:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107c1a:	e9 95 00 00 00       	jmp    80107cb4 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107c1f:	8b 55 0c             	mov    0xc(%ebp),%edx
80107c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c25:	01 d0                	add    %edx,%eax
80107c27:	83 ec 04             	sub    $0x4,%esp
80107c2a:	6a 00                	push   $0x0
80107c2c:	50                   	push   %eax
80107c2d:	ff 75 08             	pushl  0x8(%ebp)
80107c30:	e8 be fb ff ff       	call   801077f3 <walkpgdir>
80107c35:	83 c4 10             	add    $0x10,%esp
80107c38:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107c3b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107c3f:	75 0d                	jne    80107c4e <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80107c41:	83 ec 0c             	sub    $0xc,%esp
80107c44:	68 a3 87 10 80       	push   $0x801087a3
80107c49:	e8 18 89 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80107c4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c51:	8b 00                	mov    (%eax),%eax
80107c53:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c58:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107c5b:	8b 45 18             	mov    0x18(%ebp),%eax
80107c5e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107c61:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107c66:	77 0b                	ja     80107c73 <loaduvm+0x80>
      n = sz - i;
80107c68:	8b 45 18             	mov    0x18(%ebp),%eax
80107c6b:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107c6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107c71:	eb 07                	jmp    80107c7a <loaduvm+0x87>
    else
      n = PGSIZE;
80107c73:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80107c7a:	8b 55 14             	mov    0x14(%ebp),%edx
80107c7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c80:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80107c83:	83 ec 0c             	sub    $0xc,%esp
80107c86:	ff 75 e8             	pushl  -0x18(%ebp)
80107c89:	e8 e3 f6 ff ff       	call   80107371 <p2v>
80107c8e:	83 c4 10             	add    $0x10,%esp
80107c91:	ff 75 f0             	pushl  -0x10(%ebp)
80107c94:	53                   	push   %ebx
80107c95:	50                   	push   %eax
80107c96:	ff 75 10             	pushl  0x10(%ebp)
80107c99:	e8 c1 a1 ff ff       	call   80101e5f <readi>
80107c9e:	83 c4 10             	add    $0x10,%esp
80107ca1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107ca4:	74 07                	je     80107cad <loaduvm+0xba>
      return -1;
80107ca6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107cab:	eb 18                	jmp    80107cc5 <loaduvm+0xd2>
  for(i = 0; i < sz; i += PGSIZE){
80107cad:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb7:	3b 45 18             	cmp    0x18(%ebp),%eax
80107cba:	0f 82 5f ff ff ff    	jb     80107c1f <loaduvm+0x2c>
  }
  return 0;
80107cc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107cc5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107cc8:	c9                   	leave  
80107cc9:	c3                   	ret    

80107cca <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107cca:	55                   	push   %ebp
80107ccb:	89 e5                	mov    %esp,%ebp
80107ccd:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107cd0:	8b 45 10             	mov    0x10(%ebp),%eax
80107cd3:	85 c0                	test   %eax,%eax
80107cd5:	79 0a                	jns    80107ce1 <allocuvm+0x17>
    return 0;
80107cd7:	b8 00 00 00 00       	mov    $0x0,%eax
80107cdc:	e9 b0 00 00 00       	jmp    80107d91 <allocuvm+0xc7>
  if(newsz < oldsz)
80107ce1:	8b 45 10             	mov    0x10(%ebp),%eax
80107ce4:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107ce7:	73 08                	jae    80107cf1 <allocuvm+0x27>
    return oldsz;
80107ce9:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cec:	e9 a0 00 00 00       	jmp    80107d91 <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80107cf1:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cf4:	05 ff 0f 00 00       	add    $0xfff,%eax
80107cf9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107cfe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107d01:	eb 7f                	jmp    80107d82 <allocuvm+0xb8>
    mem = kalloc();
80107d03:	e8 a9 ae ff ff       	call   80102bb1 <kalloc>
80107d08:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107d0b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d0f:	75 2b                	jne    80107d3c <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80107d11:	83 ec 0c             	sub    $0xc,%esp
80107d14:	68 c1 87 10 80       	push   $0x801087c1
80107d19:	e8 a8 86 ff ff       	call   801003c6 <cprintf>
80107d1e:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107d21:	83 ec 04             	sub    $0x4,%esp
80107d24:	ff 75 0c             	pushl  0xc(%ebp)
80107d27:	ff 75 10             	pushl  0x10(%ebp)
80107d2a:	ff 75 08             	pushl  0x8(%ebp)
80107d2d:	e8 61 00 00 00       	call   80107d93 <deallocuvm>
80107d32:	83 c4 10             	add    $0x10,%esp
      return 0;
80107d35:	b8 00 00 00 00       	mov    $0x0,%eax
80107d3a:	eb 55                	jmp    80107d91 <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
80107d3c:	83 ec 04             	sub    $0x4,%esp
80107d3f:	68 00 10 00 00       	push   $0x1000
80107d44:	6a 00                	push   $0x0
80107d46:	ff 75 f0             	pushl  -0x10(%ebp)
80107d49:	e8 94 d1 ff ff       	call   80104ee2 <memset>
80107d4e:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80107d51:	83 ec 0c             	sub    $0xc,%esp
80107d54:	ff 75 f0             	pushl  -0x10(%ebp)
80107d57:	e8 08 f6 ff ff       	call   80107364 <v2p>
80107d5c:	83 c4 10             	add    $0x10,%esp
80107d5f:	89 c2                	mov    %eax,%edx
80107d61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d64:	83 ec 0c             	sub    $0xc,%esp
80107d67:	6a 06                	push   $0x6
80107d69:	52                   	push   %edx
80107d6a:	68 00 10 00 00       	push   $0x1000
80107d6f:	50                   	push   %eax
80107d70:	ff 75 08             	pushl  0x8(%ebp)
80107d73:	e8 1b fb ff ff       	call   80107893 <mappages>
80107d78:	83 c4 20             	add    $0x20,%esp
  for(; a < newsz; a += PGSIZE){
80107d7b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107d82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d85:	3b 45 10             	cmp    0x10(%ebp),%eax
80107d88:	0f 82 75 ff ff ff    	jb     80107d03 <allocuvm+0x39>
  }
  return newsz;
80107d8e:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107d91:	c9                   	leave  
80107d92:	c3                   	ret    

80107d93 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107d93:	55                   	push   %ebp
80107d94:	89 e5                	mov    %esp,%ebp
80107d96:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107d99:	8b 45 10             	mov    0x10(%ebp),%eax
80107d9c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107d9f:	72 08                	jb     80107da9 <deallocuvm+0x16>
    return oldsz;
80107da1:	8b 45 0c             	mov    0xc(%ebp),%eax
80107da4:	e9 a5 00 00 00       	jmp    80107e4e <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80107da9:	8b 45 10             	mov    0x10(%ebp),%eax
80107dac:	05 ff 0f 00 00       	add    $0xfff,%eax
80107db1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107db6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107db9:	e9 81 00 00 00       	jmp    80107e3f <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc1:	83 ec 04             	sub    $0x4,%esp
80107dc4:	6a 00                	push   $0x0
80107dc6:	50                   	push   %eax
80107dc7:	ff 75 08             	pushl  0x8(%ebp)
80107dca:	e8 24 fa ff ff       	call   801077f3 <walkpgdir>
80107dcf:	83 c4 10             	add    $0x10,%esp
80107dd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107dd5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107dd9:	75 09                	jne    80107de4 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80107ddb:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80107de2:	eb 54                	jmp    80107e38 <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
80107de4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107de7:	8b 00                	mov    (%eax),%eax
80107de9:	83 e0 01             	and    $0x1,%eax
80107dec:	85 c0                	test   %eax,%eax
80107dee:	74 48                	je     80107e38 <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
80107df0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107df3:	8b 00                	mov    (%eax),%eax
80107df5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107dfa:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107dfd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107e01:	75 0d                	jne    80107e10 <deallocuvm+0x7d>
        panic("kfree");
80107e03:	83 ec 0c             	sub    $0xc,%esp
80107e06:	68 d9 87 10 80       	push   $0x801087d9
80107e0b:	e8 56 87 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
80107e10:	83 ec 0c             	sub    $0xc,%esp
80107e13:	ff 75 ec             	pushl  -0x14(%ebp)
80107e16:	e8 56 f5 ff ff       	call   80107371 <p2v>
80107e1b:	83 c4 10             	add    $0x10,%esp
80107e1e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107e21:	83 ec 0c             	sub    $0xc,%esp
80107e24:	ff 75 e8             	pushl  -0x18(%ebp)
80107e27:	e8 e8 ac ff ff       	call   80102b14 <kfree>
80107e2c:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107e2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e32:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107e38:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e42:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107e45:	0f 82 73 ff ff ff    	jb     80107dbe <deallocuvm+0x2b>
    }
  }
  return newsz;
80107e4b:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107e4e:	c9                   	leave  
80107e4f:	c3                   	ret    

80107e50 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107e50:	55                   	push   %ebp
80107e51:	89 e5                	mov    %esp,%ebp
80107e53:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107e56:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107e5a:	75 0d                	jne    80107e69 <freevm+0x19>
    panic("freevm: no pgdir");
80107e5c:	83 ec 0c             	sub    $0xc,%esp
80107e5f:	68 df 87 10 80       	push   $0x801087df
80107e64:	e8 fd 86 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107e69:	83 ec 04             	sub    $0x4,%esp
80107e6c:	6a 00                	push   $0x0
80107e6e:	68 00 00 00 80       	push   $0x80000000
80107e73:	ff 75 08             	pushl  0x8(%ebp)
80107e76:	e8 18 ff ff ff       	call   80107d93 <deallocuvm>
80107e7b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107e7e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107e85:	eb 4f                	jmp    80107ed6 <freevm+0x86>
    if(pgdir[i] & PTE_P){
80107e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e8a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107e91:	8b 45 08             	mov    0x8(%ebp),%eax
80107e94:	01 d0                	add    %edx,%eax
80107e96:	8b 00                	mov    (%eax),%eax
80107e98:	83 e0 01             	and    $0x1,%eax
80107e9b:	85 c0                	test   %eax,%eax
80107e9d:	74 33                	je     80107ed2 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80107e9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107ea9:	8b 45 08             	mov    0x8(%ebp),%eax
80107eac:	01 d0                	add    %edx,%eax
80107eae:	8b 00                	mov    (%eax),%eax
80107eb0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107eb5:	83 ec 0c             	sub    $0xc,%esp
80107eb8:	50                   	push   %eax
80107eb9:	e8 b3 f4 ff ff       	call   80107371 <p2v>
80107ebe:	83 c4 10             	add    $0x10,%esp
80107ec1:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107ec4:	83 ec 0c             	sub    $0xc,%esp
80107ec7:	ff 75 f0             	pushl  -0x10(%ebp)
80107eca:	e8 45 ac ff ff       	call   80102b14 <kfree>
80107ecf:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107ed2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107ed6:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107edd:	76 a8                	jbe    80107e87 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107edf:	83 ec 0c             	sub    $0xc,%esp
80107ee2:	ff 75 08             	pushl  0x8(%ebp)
80107ee5:	e8 2a ac ff ff       	call   80102b14 <kfree>
80107eea:	83 c4 10             	add    $0x10,%esp
}
80107eed:	90                   	nop
80107eee:	c9                   	leave  
80107eef:	c3                   	ret    

80107ef0 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107ef0:	55                   	push   %ebp
80107ef1:	89 e5                	mov    %esp,%ebp
80107ef3:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107ef6:	83 ec 04             	sub    $0x4,%esp
80107ef9:	6a 00                	push   $0x0
80107efb:	ff 75 0c             	pushl  0xc(%ebp)
80107efe:	ff 75 08             	pushl  0x8(%ebp)
80107f01:	e8 ed f8 ff ff       	call   801077f3 <walkpgdir>
80107f06:	83 c4 10             	add    $0x10,%esp
80107f09:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107f0c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107f10:	75 0d                	jne    80107f1f <clearpteu+0x2f>
    panic("clearpteu");
80107f12:	83 ec 0c             	sub    $0xc,%esp
80107f15:	68 f0 87 10 80       	push   $0x801087f0
80107f1a:	e8 47 86 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
80107f1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f22:	8b 00                	mov    (%eax),%eax
80107f24:	83 e0 fb             	and    $0xfffffffb,%eax
80107f27:	89 c2                	mov    %eax,%edx
80107f29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f2c:	89 10                	mov    %edx,(%eax)
}
80107f2e:	90                   	nop
80107f2f:	c9                   	leave  
80107f30:	c3                   	ret    

80107f31 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107f31:	55                   	push   %ebp
80107f32:	89 e5                	mov    %esp,%ebp
80107f34:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
80107f37:	e8 e7 f9 ff ff       	call   80107923 <setupkvm>
80107f3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107f3f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f43:	75 0a                	jne    80107f4f <copyuvm+0x1e>
    return 0;
80107f45:	b8 00 00 00 00       	mov    $0x0,%eax
80107f4a:	e9 e9 00 00 00       	jmp    80108038 <copyuvm+0x107>
  for(i = 0; i < sz; i += PGSIZE){
80107f4f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f56:	e9 b5 00 00 00       	jmp    80108010 <copyuvm+0xdf>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107f5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f5e:	83 ec 04             	sub    $0x4,%esp
80107f61:	6a 00                	push   $0x0
80107f63:	50                   	push   %eax
80107f64:	ff 75 08             	pushl  0x8(%ebp)
80107f67:	e8 87 f8 ff ff       	call   801077f3 <walkpgdir>
80107f6c:	83 c4 10             	add    $0x10,%esp
80107f6f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107f72:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f76:	75 0d                	jne    80107f85 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
80107f78:	83 ec 0c             	sub    $0xc,%esp
80107f7b:	68 fa 87 10 80       	push   $0x801087fa
80107f80:	e8 e1 85 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
80107f85:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f88:	8b 00                	mov    (%eax),%eax
80107f8a:	83 e0 01             	and    $0x1,%eax
80107f8d:	85 c0                	test   %eax,%eax
80107f8f:	75 0d                	jne    80107f9e <copyuvm+0x6d>
      panic("copyuvm: page not present");
80107f91:	83 ec 0c             	sub    $0xc,%esp
80107f94:	68 14 88 10 80       	push   $0x80108814
80107f99:	e8 c8 85 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80107f9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fa1:	8b 00                	mov    (%eax),%eax
80107fa3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fa8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if((mem = kalloc()) == 0)
80107fab:	e8 01 ac ff ff       	call   80102bb1 <kalloc>
80107fb0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107fb3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80107fb7:	74 68                	je     80108021 <copyuvm+0xf0>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80107fb9:	83 ec 0c             	sub    $0xc,%esp
80107fbc:	ff 75 e8             	pushl  -0x18(%ebp)
80107fbf:	e8 ad f3 ff ff       	call   80107371 <p2v>
80107fc4:	83 c4 10             	add    $0x10,%esp
80107fc7:	83 ec 04             	sub    $0x4,%esp
80107fca:	68 00 10 00 00       	push   $0x1000
80107fcf:	50                   	push   %eax
80107fd0:	ff 75 e4             	pushl  -0x1c(%ebp)
80107fd3:	e8 c9 cf ff ff       	call   80104fa1 <memmove>
80107fd8:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
80107fdb:	83 ec 0c             	sub    $0xc,%esp
80107fde:	ff 75 e4             	pushl  -0x1c(%ebp)
80107fe1:	e8 7e f3 ff ff       	call   80107364 <v2p>
80107fe6:	83 c4 10             	add    $0x10,%esp
80107fe9:	89 c2                	mov    %eax,%edx
80107feb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fee:	83 ec 0c             	sub    $0xc,%esp
80107ff1:	6a 06                	push   $0x6
80107ff3:	52                   	push   %edx
80107ff4:	68 00 10 00 00       	push   $0x1000
80107ff9:	50                   	push   %eax
80107ffa:	ff 75 f0             	pushl  -0x10(%ebp)
80107ffd:	e8 91 f8 ff ff       	call   80107893 <mappages>
80108002:	83 c4 20             	add    $0x20,%esp
80108005:	85 c0                	test   %eax,%eax
80108007:	78 1b                	js     80108024 <copyuvm+0xf3>
  for(i = 0; i < sz; i += PGSIZE){
80108009:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108010:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108013:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108016:	0f 82 3f ff ff ff    	jb     80107f5b <copyuvm+0x2a>
      goto bad;
  }
  return d;
8010801c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010801f:	eb 17                	jmp    80108038 <copyuvm+0x107>
      goto bad;
80108021:	90                   	nop
80108022:	eb 01                	jmp    80108025 <copyuvm+0xf4>
      goto bad;
80108024:	90                   	nop

bad:
  freevm(d);
80108025:	83 ec 0c             	sub    $0xc,%esp
80108028:	ff 75 f0             	pushl  -0x10(%ebp)
8010802b:	e8 20 fe ff ff       	call   80107e50 <freevm>
80108030:	83 c4 10             	add    $0x10,%esp
  return 0;
80108033:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108038:	c9                   	leave  
80108039:	c3                   	ret    

8010803a <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010803a:	55                   	push   %ebp
8010803b:	89 e5                	mov    %esp,%ebp
8010803d:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108040:	83 ec 04             	sub    $0x4,%esp
80108043:	6a 00                	push   $0x0
80108045:	ff 75 0c             	pushl  0xc(%ebp)
80108048:	ff 75 08             	pushl  0x8(%ebp)
8010804b:	e8 a3 f7 ff ff       	call   801077f3 <walkpgdir>
80108050:	83 c4 10             	add    $0x10,%esp
80108053:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108056:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108059:	8b 00                	mov    (%eax),%eax
8010805b:	83 e0 01             	and    $0x1,%eax
8010805e:	85 c0                	test   %eax,%eax
80108060:	75 07                	jne    80108069 <uva2ka+0x2f>
    return 0;
80108062:	b8 00 00 00 00       	mov    $0x0,%eax
80108067:	eb 29                	jmp    80108092 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80108069:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010806c:	8b 00                	mov    (%eax),%eax
8010806e:	83 e0 04             	and    $0x4,%eax
80108071:	85 c0                	test   %eax,%eax
80108073:	75 07                	jne    8010807c <uva2ka+0x42>
    return 0;
80108075:	b8 00 00 00 00       	mov    $0x0,%eax
8010807a:	eb 16                	jmp    80108092 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
8010807c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010807f:	8b 00                	mov    (%eax),%eax
80108081:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108086:	83 ec 0c             	sub    $0xc,%esp
80108089:	50                   	push   %eax
8010808a:	e8 e2 f2 ff ff       	call   80107371 <p2v>
8010808f:	83 c4 10             	add    $0x10,%esp
}
80108092:	c9                   	leave  
80108093:	c3                   	ret    

80108094 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108094:	55                   	push   %ebp
80108095:	89 e5                	mov    %esp,%ebp
80108097:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010809a:	8b 45 10             	mov    0x10(%ebp),%eax
8010809d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801080a0:	eb 7f                	jmp    80108121 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
801080a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801080a5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801080ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080b0:	83 ec 08             	sub    $0x8,%esp
801080b3:	50                   	push   %eax
801080b4:	ff 75 08             	pushl  0x8(%ebp)
801080b7:	e8 7e ff ff ff       	call   8010803a <uva2ka>
801080bc:	83 c4 10             	add    $0x10,%esp
801080bf:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801080c2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801080c6:	75 07                	jne    801080cf <copyout+0x3b>
      return -1;
801080c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801080cd:	eb 61                	jmp    80108130 <copyout+0x9c>
    n = PGSIZE - (va - va0);
801080cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080d2:	2b 45 0c             	sub    0xc(%ebp),%eax
801080d5:	05 00 10 00 00       	add    $0x1000,%eax
801080da:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801080dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080e0:	3b 45 14             	cmp    0x14(%ebp),%eax
801080e3:	76 06                	jbe    801080eb <copyout+0x57>
      n = len;
801080e5:	8b 45 14             	mov    0x14(%ebp),%eax
801080e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801080eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801080ee:	2b 45 ec             	sub    -0x14(%ebp),%eax
801080f1:	89 c2                	mov    %eax,%edx
801080f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801080f6:	01 d0                	add    %edx,%eax
801080f8:	83 ec 04             	sub    $0x4,%esp
801080fb:	ff 75 f0             	pushl  -0x10(%ebp)
801080fe:	ff 75 f4             	pushl  -0xc(%ebp)
80108101:	50                   	push   %eax
80108102:	e8 9a ce ff ff       	call   80104fa1 <memmove>
80108107:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010810a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010810d:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108110:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108113:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108116:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108119:	05 00 10 00 00       	add    $0x1000,%eax
8010811e:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108121:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108125:	0f 85 77 ff ff ff    	jne    801080a2 <copyout+0xe>
  }
  return 0;
8010812b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108130:	c9                   	leave  
80108131:	c3                   	ret    
