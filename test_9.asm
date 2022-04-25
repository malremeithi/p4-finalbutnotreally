
_test_9:     file format elf32-i386


Disassembly of section .text:

00000000 <err>:
#include "ptentry.h"

#define PGSIZE 4096

static int 
err(char *msg, ...) {
   0:	f3 0f 1e fb          	endbr32 
   4:	55                   	push   %ebp
   5:	89 e5                	mov    %esp,%ebp
   7:	83 ec 08             	sub    $0x8,%esp
    printf(1, "XV6_TEST_OUTPUT %s\n", msg);
   a:	83 ec 04             	sub    $0x4,%esp
   d:	ff 75 08             	pushl  0x8(%ebp)
  10:	68 c8 0c 00 00       	push   $0xcc8
  15:	6a 01                	push   $0x1
  17:	e8 e5 08 00 00       	call   901 <printf>
  1c:	83 c4 10             	add    $0x10,%esp
    exit();
  1f:	e8 49 07 00 00       	call   76d <exit>

00000024 <access_all_dummy_pages>:
}


void access_all_dummy_pages(char **dummy_pages, uint len) {
  24:	f3 0f 1e fb          	endbr32 
  28:	55                   	push   %ebp
  29:	89 e5                	mov    %esp,%ebp
  2b:	83 ec 18             	sub    $0x18,%esp
    for (int i = 0; i < len; i++) {
  2e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  35:	eb 1b                	jmp    52 <access_all_dummy_pages+0x2e>
        char temp = dummy_pages[i][0];
  37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  3a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  41:	8b 45 08             	mov    0x8(%ebp),%eax
  44:	01 d0                	add    %edx,%eax
  46:	8b 00                	mov    (%eax),%eax
  48:	0f b6 00             	movzbl (%eax),%eax
  4b:	88 45 f3             	mov    %al,-0xd(%ebp)
    for (int i = 0; i < len; i++) {
  4e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  55:	39 45 0c             	cmp    %eax,0xc(%ebp)
  58:	77 dd                	ja     37 <access_all_dummy_pages+0x13>
        temp = temp;
        // printf(1, "0x%x ", dummy_pages[i]);
    }
    printf(1, "\n");
  5a:	83 ec 08             	sub    $0x8,%esp
  5d:	68 dc 0c 00 00       	push   $0xcdc
  62:	6a 01                	push   $0x1
  64:	e8 98 08 00 00       	call   901 <printf>
  69:	83 c4 10             	add    $0x10,%esp
}
  6c:	90                   	nop
  6d:	c9                   	leave  
  6e:	c3                   	ret    

0000006f <main>:

int main(void) {
  6f:	f3 0f 1e fb          	endbr32 
  73:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  77:	83 e4 f0             	and    $0xfffffff0,%esp
  7a:	ff 71 fc             	pushl  -0x4(%ecx)
  7d:	55                   	push   %ebp
  7e:	89 e5                	mov    %esp,%ebp
  80:	57                   	push   %edi
  81:	56                   	push   %esi
  82:	53                   	push   %ebx
  83:	51                   	push   %ecx
  84:	83 ec 68             	sub    $0x68,%esp
    const uint PAGES_NUM = 32;
  87:	c7 45 c0 20 00 00 00 	movl   $0x20,-0x40(%ebp)
    const uint expected_dummy_pages_num = 4;
  8e:	c7 45 bc 04 00 00 00 	movl   $0x4,-0x44(%ebp)
    // These pages are used to make sure the test result is consistent for different text pages number
    char *dummy_pages[expected_dummy_pages_num];
  95:	8b 45 bc             	mov    -0x44(%ebp),%eax
  98:	83 e8 01             	sub    $0x1,%eax
  9b:	89 45 b8             	mov    %eax,-0x48(%ebp)
  9e:	8b 45 bc             	mov    -0x44(%ebp),%eax
  a1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  a8:	b8 10 00 00 00       	mov    $0x10,%eax
  ad:	83 e8 01             	sub    $0x1,%eax
  b0:	01 d0                	add    %edx,%eax
  b2:	bf 10 00 00 00       	mov    $0x10,%edi
  b7:	ba 00 00 00 00       	mov    $0x0,%edx
  bc:	f7 f7                	div    %edi
  be:	6b c0 10             	imul   $0x10,%eax,%eax
  c1:	89 c2                	mov    %eax,%edx
  c3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  c9:	89 e7                	mov    %esp,%edi
  cb:	29 d7                	sub    %edx,%edi
  cd:	89 fa                	mov    %edi,%edx
  cf:	39 d4                	cmp    %edx,%esp
  d1:	74 10                	je     e3 <main+0x74>
  d3:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  d9:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  e0:	00 
  e1:	eb ec                	jmp    cf <main+0x60>
  e3:	89 c2                	mov    %eax,%edx
  e5:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  eb:	29 d4                	sub    %edx,%esp
  ed:	89 c2                	mov    %eax,%edx
  ef:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  f5:	85 d2                	test   %edx,%edx
  f7:	74 0d                	je     106 <main+0x97>
  f9:	25 ff 0f 00 00       	and    $0xfff,%eax
  fe:	83 e8 04             	sub    $0x4,%eax
 101:	01 e0                	add    %esp,%eax
 103:	83 08 00             	orl    $0x0,(%eax)
 106:	89 e0                	mov    %esp,%eax
 108:	83 c0 03             	add    $0x3,%eax
 10b:	c1 e8 02             	shr    $0x2,%eax
 10e:	c1 e0 02             	shl    $0x2,%eax
 111:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    char *buffer = sbrk(PGSIZE * sizeof(char));
 114:	83 ec 0c             	sub    $0xc,%esp
 117:	68 00 10 00 00       	push   $0x1000
 11c:	e8 d4 06 00 00       	call   7f5 <sbrk>
 121:	83 c4 10             	add    $0x10,%esp
 124:	89 45 b0             	mov    %eax,-0x50(%ebp)
    char *sp = buffer - PGSIZE;
 127:	8b 45 b0             	mov    -0x50(%ebp),%eax
 12a:	2d 00 10 00 00       	sub    $0x1000,%eax
 12f:	89 45 ac             	mov    %eax,-0x54(%ebp)
    char *boundary = buffer - 2 * PGSIZE;
 132:	8b 45 b0             	mov    -0x50(%ebp),%eax
 135:	2d 00 20 00 00       	sub    $0x2000,%eax
 13a:	89 45 a8             	mov    %eax,-0x58(%ebp)
    struct pt_entry pt_entries[PAGES_NUM];
 13d:	8b 45 c0             	mov    -0x40(%ebp),%eax
 140:	83 e8 01             	sub    $0x1,%eax
 143:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 146:	8b 45 c0             	mov    -0x40(%ebp),%eax
 149:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 150:	b8 10 00 00 00       	mov    $0x10,%eax
 155:	83 e8 01             	sub    $0x1,%eax
 158:	01 d0                	add    %edx,%eax
 15a:	bf 10 00 00 00       	mov    $0x10,%edi
 15f:	ba 00 00 00 00       	mov    $0x0,%edx
 164:	f7 f7                	div    %edi
 166:	6b c0 10             	imul   $0x10,%eax,%eax
 169:	89 c2                	mov    %eax,%edx
 16b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
 171:	89 e6                	mov    %esp,%esi
 173:	29 d6                	sub    %edx,%esi
 175:	89 f2                	mov    %esi,%edx
 177:	39 d4                	cmp    %edx,%esp
 179:	74 10                	je     18b <main+0x11c>
 17b:	81 ec 00 10 00 00    	sub    $0x1000,%esp
 181:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
 188:	00 
 189:	eb ec                	jmp    177 <main+0x108>
 18b:	89 c2                	mov    %eax,%edx
 18d:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
 193:	29 d4                	sub    %edx,%esp
 195:	89 c2                	mov    %eax,%edx
 197:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
 19d:	85 d2                	test   %edx,%edx
 19f:	74 0d                	je     1ae <main+0x13f>
 1a1:	25 ff 0f 00 00       	and    $0xfff,%eax
 1a6:	83 e8 04             	sub    $0x4,%eax
 1a9:	01 e0                	add    %esp,%eax
 1ab:	83 08 00             	orl    $0x0,(%eax)
 1ae:	89 e0                	mov    %esp,%eax
 1b0:	83 c0 03             	add    $0x3,%eax
 1b3:	c1 e8 02             	shr    $0x2,%eax
 1b6:	c1 e0 02             	shl    $0x2,%eax
 1b9:	89 45 a0             	mov    %eax,-0x60(%ebp)

    uint text_pages = (uint) boundary / PGSIZE;
 1bc:	8b 45 a8             	mov    -0x58(%ebp),%eax
 1bf:	c1 e8 0c             	shr    $0xc,%eax
 1c2:	89 45 9c             	mov    %eax,-0x64(%ebp)
    if (text_pages > expected_dummy_pages_num - 1)
 1c5:	8b 45 bc             	mov    -0x44(%ebp),%eax
 1c8:	83 e8 01             	sub    $0x1,%eax
 1cb:	39 45 9c             	cmp    %eax,-0x64(%ebp)
 1ce:	76 10                	jbe    1e0 <main+0x171>
        err("XV6_TEST_OUTPUT: program size exceeds the maximum allowed size. Please let us know if this case happens\n");
 1d0:	83 ec 0c             	sub    $0xc,%esp
 1d3:	68 e0 0c 00 00       	push   $0xce0
 1d8:	e8 23 fe ff ff       	call   0 <err>
 1dd:	83 c4 10             	add    $0x10,%esp
    
    for (int i = 0; i < text_pages; i++)
 1e0:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
 1e7:	eb 15                	jmp    1fe <main+0x18f>
        dummy_pages[i] = (char *)(i * PGSIZE);
 1e9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 1ec:	c1 e0 0c             	shl    $0xc,%eax
 1ef:	89 c1                	mov    %eax,%ecx
 1f1:	8b 45 b4             	mov    -0x4c(%ebp),%eax
 1f4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
 1f7:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    for (int i = 0; i < text_pages; i++)
 1fa:	83 45 c4 01          	addl   $0x1,-0x3c(%ebp)
 1fe:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 201:	39 45 9c             	cmp    %eax,-0x64(%ebp)
 204:	77 e3                	ja     1e9 <main+0x17a>
    dummy_pages[text_pages] = sp;
 206:	8b 45 b4             	mov    -0x4c(%ebp),%eax
 209:	8b 55 9c             	mov    -0x64(%ebp),%edx
 20c:	8b 4d ac             	mov    -0x54(%ebp),%ecx
 20f:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    for (int i = text_pages + 1; i < expected_dummy_pages_num; i++)
 212:	8b 45 9c             	mov    -0x64(%ebp),%eax
 215:	83 c0 01             	add    $0x1,%eax
 218:	89 45 c8             	mov    %eax,-0x38(%ebp)
 21b:	eb 1d                	jmp    23a <main+0x1cb>
        dummy_pages[i] = sbrk(PGSIZE * sizeof(char));
 21d:	83 ec 0c             	sub    $0xc,%esp
 220:	68 00 10 00 00       	push   $0x1000
 225:	e8 cb 05 00 00       	call   7f5 <sbrk>
 22a:	83 c4 10             	add    $0x10,%esp
 22d:	8b 55 b4             	mov    -0x4c(%ebp),%edx
 230:	8b 4d c8             	mov    -0x38(%ebp),%ecx
 233:	89 04 8a             	mov    %eax,(%edx,%ecx,4)
    for (int i = text_pages + 1; i < expected_dummy_pages_num; i++)
 236:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
 23a:	8b 45 c8             	mov    -0x38(%ebp),%eax
 23d:	39 45 bc             	cmp    %eax,-0x44(%ebp)
 240:	77 db                	ja     21d <main+0x1ae>
    

    // After this call, all the dummy pages including text pages and stack pages
    // should be resident in the clock queue.
    access_all_dummy_pages(dummy_pages, expected_dummy_pages_num);
 242:	83 ec 08             	sub    $0x8,%esp
 245:	ff 75 bc             	pushl  -0x44(%ebp)
 248:	ff 75 b4             	pushl  -0x4c(%ebp)
 24b:	e8 d4 fd ff ff       	call   24 <access_all_dummy_pages>
 250:	83 c4 10             	add    $0x10,%esp

    // Bring the buffer page into the clock queue
    buffer[0] = buffer[0];
 253:	8b 45 b0             	mov    -0x50(%ebp),%eax
 256:	0f b6 10             	movzbl (%eax),%edx
 259:	8b 45 b0             	mov    -0x50(%ebp),%eax
 25c:	88 10                	mov    %dl,(%eax)

    // Now we should have expected_dummy_pages_num + 1 (buffer) pages in the clock queue
    // Fill up the remainig slot with heap-allocated page
    // and bring all of them into the clock queue
    int heap_pages_num = CLOCKSIZE - expected_dummy_pages_num - 1;
 25e:	b8 07 00 00 00       	mov    $0x7,%eax
 263:	2b 45 bc             	sub    -0x44(%ebp),%eax
 266:	89 45 98             	mov    %eax,-0x68(%ebp)
    char *ptr = sbrk(heap_pages_num * PGSIZE * sizeof(char));
 269:	8b 45 98             	mov    -0x68(%ebp),%eax
 26c:	c1 e0 0c             	shl    $0xc,%eax
 26f:	83 ec 0c             	sub    $0xc,%esp
 272:	50                   	push   %eax
 273:	e8 7d 05 00 00       	call   7f5 <sbrk>
 278:	83 c4 10             	add    $0x10,%esp
 27b:	89 45 94             	mov    %eax,-0x6c(%ebp)
    for (int j = 0; j < PGSIZE; j++) {
 27e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
 285:	eb 0f                	jmp    296 <main+0x227>
        ptr[j] = 0xAA;
 287:	8b 55 cc             	mov    -0x34(%ebp),%edx
 28a:	8b 45 94             	mov    -0x6c(%ebp),%eax
 28d:	01 d0                	add    %edx,%eax
 28f:	c6 00 aa             	movb   $0xaa,(%eax)
    for (int j = 0; j < PGSIZE; j++) {
 292:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
 296:	81 7d cc ff 0f 00 00 	cmpl   $0xfff,-0x34(%ebp)
 29d:	7e e8                	jle    287 <main+0x218>
    }
    for (int i = heap_pages_num - 1; i > 0; i--) {
 29f:	8b 45 98             	mov    -0x68(%ebp),%eax
 2a2:	83 e8 01             	sub    $0x1,%eax
 2a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
 2a8:	eb 31                	jmp    2db <main+0x26c>
      for (int j = 0; j < PGSIZE; j++) {
 2aa:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 2b1:	eb 1b                	jmp    2ce <main+0x25f>
        ptr[i * PGSIZE + j] = 0xAA;
 2b3:	8b 45 d0             	mov    -0x30(%ebp),%eax
 2b6:	c1 e0 0c             	shl    $0xc,%eax
 2b9:	89 c2                	mov    %eax,%edx
 2bb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 2be:	01 d0                	add    %edx,%eax
 2c0:	89 c2                	mov    %eax,%edx
 2c2:	8b 45 94             	mov    -0x6c(%ebp),%eax
 2c5:	01 d0                	add    %edx,%eax
 2c7:	c6 00 aa             	movb   $0xaa,(%eax)
      for (int j = 0; j < PGSIZE; j++) {
 2ca:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
 2ce:	81 7d d4 ff 0f 00 00 	cmpl   $0xfff,-0x2c(%ebp)
 2d5:	7e dc                	jle    2b3 <main+0x244>
    for (int i = heap_pages_num - 1; i > 0; i--) {
 2d7:	83 6d d0 01          	subl   $0x1,-0x30(%ebp)
 2db:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
 2df:	7f c9                	jg     2aa <main+0x23b>
      }
    }
    
    // An extra page which will trigger the page eviction
    // This eviction will evict page 0
    char* extra_pages = sbrk(PGSIZE * sizeof(char));
 2e1:	83 ec 0c             	sub    $0xc,%esp
 2e4:	68 00 10 00 00       	push   $0x1000
 2e9:	e8 07 05 00 00       	call   7f5 <sbrk>
 2ee:	83 c4 10             	add    $0x10,%esp
 2f1:	89 45 90             	mov    %eax,-0x70(%ebp)
    for (int j = 0; j < PGSIZE; j++) {
 2f4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
 2fb:	eb 0f                	jmp    30c <main+0x29d>
      extra_pages[j] = 0xAA;
 2fd:	8b 55 d8             	mov    -0x28(%ebp),%edx
 300:	8b 45 90             	mov    -0x70(%ebp),%eax
 303:	01 d0                	add    %edx,%eax
 305:	c6 00 aa             	movb   $0xaa,(%eax)
    for (int j = 0; j < PGSIZE; j++) {
 308:	83 45 d8 01          	addl   $0x1,-0x28(%ebp)
 30c:	81 7d d8 ff 0f 00 00 	cmpl   $0xfff,-0x28(%ebp)
 313:	7e e8                	jle    2fd <main+0x28e>
    }

    // Give this page a chance that will allow this page not evicted next round
    ptr[0] = 0xAA; 
 315:	8b 45 94             	mov    -0x6c(%ebp),%eax
 318:	c6 00 aa             	movb   $0xaa,(%eax)

    // Bring all the dummy pages and buffer back to the 
    // clock queue and reset their ref to 1
    access_all_dummy_pages(dummy_pages, expected_dummy_pages_num);
 31b:	83 ec 08             	sub    $0x8,%esp
 31e:	ff 75 bc             	pushl  -0x44(%ebp)
 321:	ff 75 b4             	pushl  -0x4c(%ebp)
 324:	e8 fb fc ff ff       	call   24 <access_all_dummy_pages>
 329:	83 c4 10             	add    $0x10,%esp
    buffer[0] = buffer[0];
 32c:	8b 45 b0             	mov    -0x50(%ebp),%eax
 32f:	0f b6 10             	movzbl (%eax),%edx
 332:	8b 45 b0             	mov    -0x50(%ebp),%eax
 335:	88 10                	mov    %dl,(%eax)

    int retval = getpgtable(pt_entries, heap_pages_num + 1, 0);
 337:	8b 45 98             	mov    -0x68(%ebp),%eax
 33a:	83 c0 01             	add    $0x1,%eax
 33d:	83 ec 04             	sub    $0x4,%esp
 340:	6a 00                	push   $0x0
 342:	50                   	push   %eax
 343:	ff 75 a0             	pushl  -0x60(%ebp)
 346:	e8 ca 04 00 00       	call   815 <getpgtable>
 34b:	83 c4 10             	add    $0x10,%esp
 34e:	89 45 8c             	mov    %eax,-0x74(%ebp)
    if (retval == heap_pages_num + 1) {
 351:	8b 45 98             	mov    -0x68(%ebp),%eax
 354:	83 c0 01             	add    $0x1,%eax
 357:	39 45 8c             	cmp    %eax,-0x74(%ebp)
 35a:	0f 85 78 01 00 00    	jne    4d8 <main+0x469>
      for (int i = 0; i < retval; i++) {
 360:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
 367:	e9 5e 01 00 00       	jmp    4ca <main+0x45b>
              i,
              pt_entries[i].pdx,
              pt_entries[i].ptx,
              pt_entries[i].writable,
              pt_entries[i].encrypted,
              pt_entries[i].ref
 36c:	8b 45 a0             	mov    -0x60(%ebp),%eax
 36f:	8b 55 dc             	mov    -0x24(%ebp),%edx
 372:	0f b6 44 d0 07       	movzbl 0x7(%eax,%edx,8),%eax
 377:	83 e0 01             	and    $0x1,%eax
          printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, writable bit: %d, encrypted: %d, ref: %d\n", 
 37a:	0f b6 f0             	movzbl %al,%esi
              pt_entries[i].encrypted,
 37d:	8b 45 a0             	mov    -0x60(%ebp),%eax
 380:	8b 55 dc             	mov    -0x24(%ebp),%edx
 383:	0f b6 44 d0 06       	movzbl 0x6(%eax,%edx,8),%eax
 388:	c0 e8 07             	shr    $0x7,%al
          printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, writable bit: %d, encrypted: %d, ref: %d\n", 
 38b:	0f b6 d8             	movzbl %al,%ebx
              pt_entries[i].writable,
 38e:	8b 45 a0             	mov    -0x60(%ebp),%eax
 391:	8b 55 dc             	mov    -0x24(%ebp),%edx
 394:	0f b6 44 d0 06       	movzbl 0x6(%eax,%edx,8),%eax
 399:	c0 e8 05             	shr    $0x5,%al
 39c:	83 e0 01             	and    $0x1,%eax
          printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, writable bit: %d, encrypted: %d, ref: %d\n", 
 39f:	0f b6 c8             	movzbl %al,%ecx
              pt_entries[i].ptx,
 3a2:	8b 45 a0             	mov    -0x60(%ebp),%eax
 3a5:	8b 55 dc             	mov    -0x24(%ebp),%edx
 3a8:	8b 04 d0             	mov    (%eax,%edx,8),%eax
 3ab:	c1 e8 0a             	shr    $0xa,%eax
 3ae:	66 25 ff 03          	and    $0x3ff,%ax
          printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, writable bit: %d, encrypted: %d, ref: %d\n", 
 3b2:	0f b7 d0             	movzwl %ax,%edx
              pt_entries[i].pdx,
 3b5:	8b 45 a0             	mov    -0x60(%ebp),%eax
 3b8:	8b 7d dc             	mov    -0x24(%ebp),%edi
 3bb:	0f b7 04 f8          	movzwl (%eax,%edi,8),%eax
 3bf:	66 25 ff 03          	and    $0x3ff,%ax
          printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, writable bit: %d, encrypted: %d, ref: %d\n", 
 3c3:	0f b7 c0             	movzwl %ax,%eax
 3c6:	56                   	push   %esi
 3c7:	53                   	push   %ebx
 3c8:	51                   	push   %ecx
 3c9:	52                   	push   %edx
 3ca:	50                   	push   %eax
 3cb:	ff 75 dc             	pushl  -0x24(%ebp)
 3ce:	68 4c 0d 00 00       	push   $0xd4c
 3d3:	6a 01                	push   $0x1
 3d5:	e8 27 05 00 00       	call   901 <printf>
 3da:	83 c4 20             	add    $0x20,%esp
          ); 
          
          uint expected = 0xAA;
 3dd:	c7 45 e0 aa 00 00 00 	movl   $0xaa,-0x20(%ebp)
          if (pt_entries[i].encrypted)
 3e4:	8b 45 a0             	mov    -0x60(%ebp),%eax
 3e7:	8b 55 dc             	mov    -0x24(%ebp),%edx
 3ea:	0f b6 44 d0 06       	movzbl 0x6(%eax,%edx,8),%eax
 3ef:	c0 e8 07             	shr    $0x7,%al
 3f2:	84 c0                	test   %al,%al
 3f4:	74 07                	je     3fd <main+0x38e>
            expected = ~0xAA;
 3f6:	c7 45 e0 55 ff ff ff 	movl   $0xffffff55,-0x20(%ebp)

          if (dump_rawphymem(pt_entries[i].ppage * PGSIZE, buffer) != 0)
 3fd:	8b 45 a0             	mov    -0x60(%ebp),%eax
 400:	8b 55 dc             	mov    -0x24(%ebp),%edx
 403:	8b 44 d0 04          	mov    0x4(%eax,%edx,8),%eax
 407:	25 ff ff 0f 00       	and    $0xfffff,%eax
 40c:	c1 e0 0c             	shl    $0xc,%eax
 40f:	83 ec 08             	sub    $0x8,%esp
 412:	ff 75 b0             	pushl  -0x50(%ebp)
 415:	50                   	push   %eax
 416:	e8 02 04 00 00       	call   81d <dump_rawphymem>
 41b:	83 c4 10             	add    $0x10,%esp
 41e:	85 c0                	test   %eax,%eax
 420:	74 10                	je     432 <main+0x3c3>
              err("dump_rawphymem return non-zero value\n");
 422:	83 ec 0c             	sub    $0xc,%esp
 425:	68 a8 0d 00 00       	push   $0xda8
 42a:	e8 d1 fb ff ff       	call   0 <err>
 42f:	83 c4 10             	add    $0x10,%esp
          
          for (int j = 0; j < PGSIZE; j++) {
 432:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 439:	eb 7e                	jmp    4b9 <main+0x44a>
              if (buffer[j] != (char)expected) {
 43b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 43e:	8b 45 b0             	mov    -0x50(%ebp),%eax
 441:	01 d0                	add    %edx,%eax
 443:	0f b6 00             	movzbl (%eax),%eax
 446:	8b 55 e0             	mov    -0x20(%ebp),%edx
 449:	38 d0                	cmp    %dl,%al
 44b:	74 68                	je     4b5 <main+0x446>
                    // err("physical memory is dumped incorrectly\n");
                    printf(1, "XV6_TEST_OUTPUT: content is incorrect at address 0x%x: expected 0x%x, got 0x%x\n", ((uint)(pt_entries[i].pdx) << 22 | (pt_entries[i].ptx) << 12) + j ,expected & 0xFF, buffer[j] & 0xFF);
 44d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 450:	8b 45 b0             	mov    -0x50(%ebp),%eax
 453:	01 d0                	add    %edx,%eax
 455:	0f b6 00             	movzbl (%eax),%eax
 458:	0f be c0             	movsbl %al,%eax
 45b:	0f b6 d0             	movzbl %al,%edx
 45e:	8b 45 e0             	mov    -0x20(%ebp),%eax
 461:	0f b6 c0             	movzbl %al,%eax
 464:	8b 4d a0             	mov    -0x60(%ebp),%ecx
 467:	8b 5d dc             	mov    -0x24(%ebp),%ebx
 46a:	0f b7 0c d9          	movzwl (%ecx,%ebx,8),%ecx
 46e:	66 81 e1 ff 03       	and    $0x3ff,%cx
 473:	0f b7 c9             	movzwl %cx,%ecx
 476:	89 ce                	mov    %ecx,%esi
 478:	c1 e6 16             	shl    $0x16,%esi
 47b:	8b 4d a0             	mov    -0x60(%ebp),%ecx
 47e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
 481:	8b 0c d9             	mov    (%ecx,%ebx,8),%ecx
 484:	c1 e9 0a             	shr    $0xa,%ecx
 487:	66 81 e1 ff 03       	and    $0x3ff,%cx
 48c:	0f b7 c9             	movzwl %cx,%ecx
 48f:	c1 e1 0c             	shl    $0xc,%ecx
 492:	89 f3                	mov    %esi,%ebx
 494:	09 cb                	or     %ecx,%ebx
 496:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
 499:	01 d9                	add    %ebx,%ecx
 49b:	83 ec 0c             	sub    $0xc,%esp
 49e:	52                   	push   %edx
 49f:	50                   	push   %eax
 4a0:	51                   	push   %ecx
 4a1:	68 d0 0d 00 00       	push   $0xdd0
 4a6:	6a 01                	push   $0x1
 4a8:	e8 54 04 00 00       	call   901 <printf>
 4ad:	83 c4 20             	add    $0x20,%esp
                    exit();
 4b0:	e8 b8 02 00 00       	call   76d <exit>
          for (int j = 0; j < PGSIZE; j++) {
 4b5:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
 4b9:	81 7d e4 ff 0f 00 00 	cmpl   $0xfff,-0x1c(%ebp)
 4c0:	0f 8e 75 ff ff ff    	jle    43b <main+0x3cc>
      for (int i = 0; i < retval; i++) {
 4c6:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
 4ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
 4cd:	3b 45 8c             	cmp    -0x74(%ebp),%eax
 4d0:	0f 8c 96 fe ff ff    	jl     36c <main+0x2fd>
 4d6:	eb 15                	jmp    4ed <main+0x47e>
              }
          }

      }
    } else
        printf(1, "XV6_TEST_OUTPUT: getpgtable returned incorrect value: expected %d, got %d\n", heap_pages_num, retval);
 4d8:	ff 75 8c             	pushl  -0x74(%ebp)
 4db:	ff 75 98             	pushl  -0x68(%ebp)
 4de:	68 20 0e 00 00       	push   $0xe20
 4e3:	6a 01                	push   $0x1
 4e5:	e8 17 04 00 00       	call   901 <printf>
 4ea:	83 c4 10             	add    $0x10,%esp
    
    exit();
 4ed:	e8 7b 02 00 00       	call   76d <exit>

000004f2 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 4f2:	55                   	push   %ebp
 4f3:	89 e5                	mov    %esp,%ebp
 4f5:	57                   	push   %edi
 4f6:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 4f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
 4fa:	8b 55 10             	mov    0x10(%ebp),%edx
 4fd:	8b 45 0c             	mov    0xc(%ebp),%eax
 500:	89 cb                	mov    %ecx,%ebx
 502:	89 df                	mov    %ebx,%edi
 504:	89 d1                	mov    %edx,%ecx
 506:	fc                   	cld    
 507:	f3 aa                	rep stos %al,%es:(%edi)
 509:	89 ca                	mov    %ecx,%edx
 50b:	89 fb                	mov    %edi,%ebx
 50d:	89 5d 08             	mov    %ebx,0x8(%ebp)
 510:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 513:	90                   	nop
 514:	5b                   	pop    %ebx
 515:	5f                   	pop    %edi
 516:	5d                   	pop    %ebp
 517:	c3                   	ret    

00000518 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 518:	f3 0f 1e fb          	endbr32 
 51c:	55                   	push   %ebp
 51d:	89 e5                	mov    %esp,%ebp
 51f:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 522:	8b 45 08             	mov    0x8(%ebp),%eax
 525:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 528:	90                   	nop
 529:	8b 55 0c             	mov    0xc(%ebp),%edx
 52c:	8d 42 01             	lea    0x1(%edx),%eax
 52f:	89 45 0c             	mov    %eax,0xc(%ebp)
 532:	8b 45 08             	mov    0x8(%ebp),%eax
 535:	8d 48 01             	lea    0x1(%eax),%ecx
 538:	89 4d 08             	mov    %ecx,0x8(%ebp)
 53b:	0f b6 12             	movzbl (%edx),%edx
 53e:	88 10                	mov    %dl,(%eax)
 540:	0f b6 00             	movzbl (%eax),%eax
 543:	84 c0                	test   %al,%al
 545:	75 e2                	jne    529 <strcpy+0x11>
    ;
  return os;
 547:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 54a:	c9                   	leave  
 54b:	c3                   	ret    

0000054c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 54c:	f3 0f 1e fb          	endbr32 
 550:	55                   	push   %ebp
 551:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 553:	eb 08                	jmp    55d <strcmp+0x11>
    p++, q++;
 555:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 559:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 55d:	8b 45 08             	mov    0x8(%ebp),%eax
 560:	0f b6 00             	movzbl (%eax),%eax
 563:	84 c0                	test   %al,%al
 565:	74 10                	je     577 <strcmp+0x2b>
 567:	8b 45 08             	mov    0x8(%ebp),%eax
 56a:	0f b6 10             	movzbl (%eax),%edx
 56d:	8b 45 0c             	mov    0xc(%ebp),%eax
 570:	0f b6 00             	movzbl (%eax),%eax
 573:	38 c2                	cmp    %al,%dl
 575:	74 de                	je     555 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 577:	8b 45 08             	mov    0x8(%ebp),%eax
 57a:	0f b6 00             	movzbl (%eax),%eax
 57d:	0f b6 d0             	movzbl %al,%edx
 580:	8b 45 0c             	mov    0xc(%ebp),%eax
 583:	0f b6 00             	movzbl (%eax),%eax
 586:	0f b6 c0             	movzbl %al,%eax
 589:	29 c2                	sub    %eax,%edx
 58b:	89 d0                	mov    %edx,%eax
}
 58d:	5d                   	pop    %ebp
 58e:	c3                   	ret    

0000058f <strlen>:

uint
strlen(const char *s)
{
 58f:	f3 0f 1e fb          	endbr32 
 593:	55                   	push   %ebp
 594:	89 e5                	mov    %esp,%ebp
 596:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 599:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 5a0:	eb 04                	jmp    5a6 <strlen+0x17>
 5a2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 5a6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 5a9:	8b 45 08             	mov    0x8(%ebp),%eax
 5ac:	01 d0                	add    %edx,%eax
 5ae:	0f b6 00             	movzbl (%eax),%eax
 5b1:	84 c0                	test   %al,%al
 5b3:	75 ed                	jne    5a2 <strlen+0x13>
    ;
  return n;
 5b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 5b8:	c9                   	leave  
 5b9:	c3                   	ret    

000005ba <memset>:

void*
memset(void *dst, int c, uint n)
{
 5ba:	f3 0f 1e fb          	endbr32 
 5be:	55                   	push   %ebp
 5bf:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 5c1:	8b 45 10             	mov    0x10(%ebp),%eax
 5c4:	50                   	push   %eax
 5c5:	ff 75 0c             	pushl  0xc(%ebp)
 5c8:	ff 75 08             	pushl  0x8(%ebp)
 5cb:	e8 22 ff ff ff       	call   4f2 <stosb>
 5d0:	83 c4 0c             	add    $0xc,%esp
  return dst;
 5d3:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5d6:	c9                   	leave  
 5d7:	c3                   	ret    

000005d8 <strchr>:

char*
strchr(const char *s, char c)
{
 5d8:	f3 0f 1e fb          	endbr32 
 5dc:	55                   	push   %ebp
 5dd:	89 e5                	mov    %esp,%ebp
 5df:	83 ec 04             	sub    $0x4,%esp
 5e2:	8b 45 0c             	mov    0xc(%ebp),%eax
 5e5:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 5e8:	eb 14                	jmp    5fe <strchr+0x26>
    if(*s == c)
 5ea:	8b 45 08             	mov    0x8(%ebp),%eax
 5ed:	0f b6 00             	movzbl (%eax),%eax
 5f0:	38 45 fc             	cmp    %al,-0x4(%ebp)
 5f3:	75 05                	jne    5fa <strchr+0x22>
      return (char*)s;
 5f5:	8b 45 08             	mov    0x8(%ebp),%eax
 5f8:	eb 13                	jmp    60d <strchr+0x35>
  for(; *s; s++)
 5fa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 5fe:	8b 45 08             	mov    0x8(%ebp),%eax
 601:	0f b6 00             	movzbl (%eax),%eax
 604:	84 c0                	test   %al,%al
 606:	75 e2                	jne    5ea <strchr+0x12>
  return 0;
 608:	b8 00 00 00 00       	mov    $0x0,%eax
}
 60d:	c9                   	leave  
 60e:	c3                   	ret    

0000060f <gets>:

char*
gets(char *buf, int max)
{
 60f:	f3 0f 1e fb          	endbr32 
 613:	55                   	push   %ebp
 614:	89 e5                	mov    %esp,%ebp
 616:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 619:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 620:	eb 42                	jmp    664 <gets+0x55>
    cc = read(0, &c, 1);
 622:	83 ec 04             	sub    $0x4,%esp
 625:	6a 01                	push   $0x1
 627:	8d 45 ef             	lea    -0x11(%ebp),%eax
 62a:	50                   	push   %eax
 62b:	6a 00                	push   $0x0
 62d:	e8 53 01 00 00       	call   785 <read>
 632:	83 c4 10             	add    $0x10,%esp
 635:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 638:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 63c:	7e 33                	jle    671 <gets+0x62>
      break;
    buf[i++] = c;
 63e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 641:	8d 50 01             	lea    0x1(%eax),%edx
 644:	89 55 f4             	mov    %edx,-0xc(%ebp)
 647:	89 c2                	mov    %eax,%edx
 649:	8b 45 08             	mov    0x8(%ebp),%eax
 64c:	01 c2                	add    %eax,%edx
 64e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 652:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 654:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 658:	3c 0a                	cmp    $0xa,%al
 65a:	74 16                	je     672 <gets+0x63>
 65c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 660:	3c 0d                	cmp    $0xd,%al
 662:	74 0e                	je     672 <gets+0x63>
  for(i=0; i+1 < max; ){
 664:	8b 45 f4             	mov    -0xc(%ebp),%eax
 667:	83 c0 01             	add    $0x1,%eax
 66a:	39 45 0c             	cmp    %eax,0xc(%ebp)
 66d:	7f b3                	jg     622 <gets+0x13>
 66f:	eb 01                	jmp    672 <gets+0x63>
      break;
 671:	90                   	nop
      break;
  }
  buf[i] = '\0';
 672:	8b 55 f4             	mov    -0xc(%ebp),%edx
 675:	8b 45 08             	mov    0x8(%ebp),%eax
 678:	01 d0                	add    %edx,%eax
 67a:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 67d:	8b 45 08             	mov    0x8(%ebp),%eax
}
 680:	c9                   	leave  
 681:	c3                   	ret    

00000682 <stat>:

int
stat(const char *n, struct stat *st)
{
 682:	f3 0f 1e fb          	endbr32 
 686:	55                   	push   %ebp
 687:	89 e5                	mov    %esp,%ebp
 689:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 68c:	83 ec 08             	sub    $0x8,%esp
 68f:	6a 00                	push   $0x0
 691:	ff 75 08             	pushl  0x8(%ebp)
 694:	e8 14 01 00 00       	call   7ad <open>
 699:	83 c4 10             	add    $0x10,%esp
 69c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 69f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6a3:	79 07                	jns    6ac <stat+0x2a>
    return -1;
 6a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 6aa:	eb 25                	jmp    6d1 <stat+0x4f>
  r = fstat(fd, st);
 6ac:	83 ec 08             	sub    $0x8,%esp
 6af:	ff 75 0c             	pushl  0xc(%ebp)
 6b2:	ff 75 f4             	pushl  -0xc(%ebp)
 6b5:	e8 0b 01 00 00       	call   7c5 <fstat>
 6ba:	83 c4 10             	add    $0x10,%esp
 6bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 6c0:	83 ec 0c             	sub    $0xc,%esp
 6c3:	ff 75 f4             	pushl  -0xc(%ebp)
 6c6:	e8 ca 00 00 00       	call   795 <close>
 6cb:	83 c4 10             	add    $0x10,%esp
  return r;
 6ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 6d1:	c9                   	leave  
 6d2:	c3                   	ret    

000006d3 <atoi>:

int
atoi(const char *s)
{
 6d3:	f3 0f 1e fb          	endbr32 
 6d7:	55                   	push   %ebp
 6d8:	89 e5                	mov    %esp,%ebp
 6da:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 6dd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 6e4:	eb 25                	jmp    70b <atoi+0x38>
    n = n*10 + *s++ - '0';
 6e6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 6e9:	89 d0                	mov    %edx,%eax
 6eb:	c1 e0 02             	shl    $0x2,%eax
 6ee:	01 d0                	add    %edx,%eax
 6f0:	01 c0                	add    %eax,%eax
 6f2:	89 c1                	mov    %eax,%ecx
 6f4:	8b 45 08             	mov    0x8(%ebp),%eax
 6f7:	8d 50 01             	lea    0x1(%eax),%edx
 6fa:	89 55 08             	mov    %edx,0x8(%ebp)
 6fd:	0f b6 00             	movzbl (%eax),%eax
 700:	0f be c0             	movsbl %al,%eax
 703:	01 c8                	add    %ecx,%eax
 705:	83 e8 30             	sub    $0x30,%eax
 708:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 70b:	8b 45 08             	mov    0x8(%ebp),%eax
 70e:	0f b6 00             	movzbl (%eax),%eax
 711:	3c 2f                	cmp    $0x2f,%al
 713:	7e 0a                	jle    71f <atoi+0x4c>
 715:	8b 45 08             	mov    0x8(%ebp),%eax
 718:	0f b6 00             	movzbl (%eax),%eax
 71b:	3c 39                	cmp    $0x39,%al
 71d:	7e c7                	jle    6e6 <atoi+0x13>
  return n;
 71f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 722:	c9                   	leave  
 723:	c3                   	ret    

00000724 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 724:	f3 0f 1e fb          	endbr32 
 728:	55                   	push   %ebp
 729:	89 e5                	mov    %esp,%ebp
 72b:	83 ec 10             	sub    $0x10,%esp
  char *dst;
  const char *src;

  dst = vdst;
 72e:	8b 45 08             	mov    0x8(%ebp),%eax
 731:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 734:	8b 45 0c             	mov    0xc(%ebp),%eax
 737:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 73a:	eb 17                	jmp    753 <memmove+0x2f>
    *dst++ = *src++;
 73c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 73f:	8d 42 01             	lea    0x1(%edx),%eax
 742:	89 45 f8             	mov    %eax,-0x8(%ebp)
 745:	8b 45 fc             	mov    -0x4(%ebp),%eax
 748:	8d 48 01             	lea    0x1(%eax),%ecx
 74b:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 74e:	0f b6 12             	movzbl (%edx),%edx
 751:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 753:	8b 45 10             	mov    0x10(%ebp),%eax
 756:	8d 50 ff             	lea    -0x1(%eax),%edx
 759:	89 55 10             	mov    %edx,0x10(%ebp)
 75c:	85 c0                	test   %eax,%eax
 75e:	7f dc                	jg     73c <memmove+0x18>
  return vdst;
 760:	8b 45 08             	mov    0x8(%ebp),%eax
}
 763:	c9                   	leave  
 764:	c3                   	ret    

00000765 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 765:	b8 01 00 00 00       	mov    $0x1,%eax
 76a:	cd 40                	int    $0x40
 76c:	c3                   	ret    

0000076d <exit>:
SYSCALL(exit)
 76d:	b8 02 00 00 00       	mov    $0x2,%eax
 772:	cd 40                	int    $0x40
 774:	c3                   	ret    

00000775 <wait>:
SYSCALL(wait)
 775:	b8 03 00 00 00       	mov    $0x3,%eax
 77a:	cd 40                	int    $0x40
 77c:	c3                   	ret    

0000077d <pipe>:
SYSCALL(pipe)
 77d:	b8 04 00 00 00       	mov    $0x4,%eax
 782:	cd 40                	int    $0x40
 784:	c3                   	ret    

00000785 <read>:
SYSCALL(read)
 785:	b8 05 00 00 00       	mov    $0x5,%eax
 78a:	cd 40                	int    $0x40
 78c:	c3                   	ret    

0000078d <write>:
SYSCALL(write)
 78d:	b8 10 00 00 00       	mov    $0x10,%eax
 792:	cd 40                	int    $0x40
 794:	c3                   	ret    

00000795 <close>:
SYSCALL(close)
 795:	b8 15 00 00 00       	mov    $0x15,%eax
 79a:	cd 40                	int    $0x40
 79c:	c3                   	ret    

0000079d <kill>:
SYSCALL(kill)
 79d:	b8 06 00 00 00       	mov    $0x6,%eax
 7a2:	cd 40                	int    $0x40
 7a4:	c3                   	ret    

000007a5 <exec>:
SYSCALL(exec)
 7a5:	b8 07 00 00 00       	mov    $0x7,%eax
 7aa:	cd 40                	int    $0x40
 7ac:	c3                   	ret    

000007ad <open>:
SYSCALL(open)
 7ad:	b8 0f 00 00 00       	mov    $0xf,%eax
 7b2:	cd 40                	int    $0x40
 7b4:	c3                   	ret    

000007b5 <mknod>:
SYSCALL(mknod)
 7b5:	b8 11 00 00 00       	mov    $0x11,%eax
 7ba:	cd 40                	int    $0x40
 7bc:	c3                   	ret    

000007bd <unlink>:
SYSCALL(unlink)
 7bd:	b8 12 00 00 00       	mov    $0x12,%eax
 7c2:	cd 40                	int    $0x40
 7c4:	c3                   	ret    

000007c5 <fstat>:
SYSCALL(fstat)
 7c5:	b8 08 00 00 00       	mov    $0x8,%eax
 7ca:	cd 40                	int    $0x40
 7cc:	c3                   	ret    

000007cd <link>:
SYSCALL(link)
 7cd:	b8 13 00 00 00       	mov    $0x13,%eax
 7d2:	cd 40                	int    $0x40
 7d4:	c3                   	ret    

000007d5 <mkdir>:
SYSCALL(mkdir)
 7d5:	b8 14 00 00 00       	mov    $0x14,%eax
 7da:	cd 40                	int    $0x40
 7dc:	c3                   	ret    

000007dd <chdir>:
SYSCALL(chdir)
 7dd:	b8 09 00 00 00       	mov    $0x9,%eax
 7e2:	cd 40                	int    $0x40
 7e4:	c3                   	ret    

000007e5 <dup>:
SYSCALL(dup)
 7e5:	b8 0a 00 00 00       	mov    $0xa,%eax
 7ea:	cd 40                	int    $0x40
 7ec:	c3                   	ret    

000007ed <getpid>:
SYSCALL(getpid)
 7ed:	b8 0b 00 00 00       	mov    $0xb,%eax
 7f2:	cd 40                	int    $0x40
 7f4:	c3                   	ret    

000007f5 <sbrk>:
SYSCALL(sbrk)
 7f5:	b8 0c 00 00 00       	mov    $0xc,%eax
 7fa:	cd 40                	int    $0x40
 7fc:	c3                   	ret    

000007fd <sleep>:
SYSCALL(sleep)
 7fd:	b8 0d 00 00 00       	mov    $0xd,%eax
 802:	cd 40                	int    $0x40
 804:	c3                   	ret    

00000805 <uptime>:
SYSCALL(uptime)
 805:	b8 0e 00 00 00       	mov    $0xe,%eax
 80a:	cd 40                	int    $0x40
 80c:	c3                   	ret    

0000080d <mencrypt>:
SYSCALL(mencrypt)
 80d:	b8 16 00 00 00       	mov    $0x16,%eax
 812:	cd 40                	int    $0x40
 814:	c3                   	ret    

00000815 <getpgtable>:
SYSCALL(getpgtable)
 815:	b8 17 00 00 00       	mov    $0x17,%eax
 81a:	cd 40                	int    $0x40
 81c:	c3                   	ret    

0000081d <dump_rawphymem>:
SYSCALL(dump_rawphymem)
 81d:	b8 18 00 00 00       	mov    $0x18,%eax
 822:	cd 40                	int    $0x40
 824:	c3                   	ret    

00000825 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 825:	f3 0f 1e fb          	endbr32 
 829:	55                   	push   %ebp
 82a:	89 e5                	mov    %esp,%ebp
 82c:	83 ec 18             	sub    $0x18,%esp
 82f:	8b 45 0c             	mov    0xc(%ebp),%eax
 832:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 835:	83 ec 04             	sub    $0x4,%esp
 838:	6a 01                	push   $0x1
 83a:	8d 45 f4             	lea    -0xc(%ebp),%eax
 83d:	50                   	push   %eax
 83e:	ff 75 08             	pushl  0x8(%ebp)
 841:	e8 47 ff ff ff       	call   78d <write>
 846:	83 c4 10             	add    $0x10,%esp
}
 849:	90                   	nop
 84a:	c9                   	leave  
 84b:	c3                   	ret    

0000084c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 84c:	f3 0f 1e fb          	endbr32 
 850:	55                   	push   %ebp
 851:	89 e5                	mov    %esp,%ebp
 853:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 856:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 85d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 861:	74 17                	je     87a <printint+0x2e>
 863:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 867:	79 11                	jns    87a <printint+0x2e>
    neg = 1;
 869:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 870:	8b 45 0c             	mov    0xc(%ebp),%eax
 873:	f7 d8                	neg    %eax
 875:	89 45 ec             	mov    %eax,-0x14(%ebp)
 878:	eb 06                	jmp    880 <printint+0x34>
  } else {
    x = xx;
 87a:	8b 45 0c             	mov    0xc(%ebp),%eax
 87d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 880:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 887:	8b 4d 10             	mov    0x10(%ebp),%ecx
 88a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 88d:	ba 00 00 00 00       	mov    $0x0,%edx
 892:	f7 f1                	div    %ecx
 894:	89 d1                	mov    %edx,%ecx
 896:	8b 45 f4             	mov    -0xc(%ebp),%eax
 899:	8d 50 01             	lea    0x1(%eax),%edx
 89c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 89f:	0f b6 91 00 11 00 00 	movzbl 0x1100(%ecx),%edx
 8a6:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 8aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
 8ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8b0:	ba 00 00 00 00       	mov    $0x0,%edx
 8b5:	f7 f1                	div    %ecx
 8b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 8ba:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 8be:	75 c7                	jne    887 <printint+0x3b>
  if(neg)
 8c0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8c4:	74 2d                	je     8f3 <printint+0xa7>
    buf[i++] = '-';
 8c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c9:	8d 50 01             	lea    0x1(%eax),%edx
 8cc:	89 55 f4             	mov    %edx,-0xc(%ebp)
 8cf:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 8d4:	eb 1d                	jmp    8f3 <printint+0xa7>
    putc(fd, buf[i]);
 8d6:	8d 55 dc             	lea    -0x24(%ebp),%edx
 8d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8dc:	01 d0                	add    %edx,%eax
 8de:	0f b6 00             	movzbl (%eax),%eax
 8e1:	0f be c0             	movsbl %al,%eax
 8e4:	83 ec 08             	sub    $0x8,%esp
 8e7:	50                   	push   %eax
 8e8:	ff 75 08             	pushl  0x8(%ebp)
 8eb:	e8 35 ff ff ff       	call   825 <putc>
 8f0:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 8f3:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 8f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8fb:	79 d9                	jns    8d6 <printint+0x8a>
}
 8fd:	90                   	nop
 8fe:	90                   	nop
 8ff:	c9                   	leave  
 900:	c3                   	ret    

00000901 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 901:	f3 0f 1e fb          	endbr32 
 905:	55                   	push   %ebp
 906:	89 e5                	mov    %esp,%ebp
 908:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 90b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 912:	8d 45 0c             	lea    0xc(%ebp),%eax
 915:	83 c0 04             	add    $0x4,%eax
 918:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 91b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 922:	e9 59 01 00 00       	jmp    a80 <printf+0x17f>
    c = fmt[i] & 0xff;
 927:	8b 55 0c             	mov    0xc(%ebp),%edx
 92a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 92d:	01 d0                	add    %edx,%eax
 92f:	0f b6 00             	movzbl (%eax),%eax
 932:	0f be c0             	movsbl %al,%eax
 935:	25 ff 00 00 00       	and    $0xff,%eax
 93a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 93d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 941:	75 2c                	jne    96f <printf+0x6e>
      if(c == '%'){
 943:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 947:	75 0c                	jne    955 <printf+0x54>
        state = '%';
 949:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 950:	e9 27 01 00 00       	jmp    a7c <printf+0x17b>
      } else {
        putc(fd, c);
 955:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 958:	0f be c0             	movsbl %al,%eax
 95b:	83 ec 08             	sub    $0x8,%esp
 95e:	50                   	push   %eax
 95f:	ff 75 08             	pushl  0x8(%ebp)
 962:	e8 be fe ff ff       	call   825 <putc>
 967:	83 c4 10             	add    $0x10,%esp
 96a:	e9 0d 01 00 00       	jmp    a7c <printf+0x17b>
      }
    } else if(state == '%'){
 96f:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 973:	0f 85 03 01 00 00    	jne    a7c <printf+0x17b>
      if(c == 'd'){
 979:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 97d:	75 1e                	jne    99d <printf+0x9c>
        printint(fd, *ap, 10, 1);
 97f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 982:	8b 00                	mov    (%eax),%eax
 984:	6a 01                	push   $0x1
 986:	6a 0a                	push   $0xa
 988:	50                   	push   %eax
 989:	ff 75 08             	pushl  0x8(%ebp)
 98c:	e8 bb fe ff ff       	call   84c <printint>
 991:	83 c4 10             	add    $0x10,%esp
        ap++;
 994:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 998:	e9 d8 00 00 00       	jmp    a75 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 99d:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 9a1:	74 06                	je     9a9 <printf+0xa8>
 9a3:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 9a7:	75 1e                	jne    9c7 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 9a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9ac:	8b 00                	mov    (%eax),%eax
 9ae:	6a 00                	push   $0x0
 9b0:	6a 10                	push   $0x10
 9b2:	50                   	push   %eax
 9b3:	ff 75 08             	pushl  0x8(%ebp)
 9b6:	e8 91 fe ff ff       	call   84c <printint>
 9bb:	83 c4 10             	add    $0x10,%esp
        ap++;
 9be:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9c2:	e9 ae 00 00 00       	jmp    a75 <printf+0x174>
      } else if(c == 's'){
 9c7:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 9cb:	75 43                	jne    a10 <printf+0x10f>
        s = (char*)*ap;
 9cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9d0:	8b 00                	mov    (%eax),%eax
 9d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 9d5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 9d9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9dd:	75 25                	jne    a04 <printf+0x103>
          s = "(null)";
 9df:	c7 45 f4 6b 0e 00 00 	movl   $0xe6b,-0xc(%ebp)
        while(*s != 0){
 9e6:	eb 1c                	jmp    a04 <printf+0x103>
          putc(fd, *s);
 9e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9eb:	0f b6 00             	movzbl (%eax),%eax
 9ee:	0f be c0             	movsbl %al,%eax
 9f1:	83 ec 08             	sub    $0x8,%esp
 9f4:	50                   	push   %eax
 9f5:	ff 75 08             	pushl  0x8(%ebp)
 9f8:	e8 28 fe ff ff       	call   825 <putc>
 9fd:	83 c4 10             	add    $0x10,%esp
          s++;
 a00:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a07:	0f b6 00             	movzbl (%eax),%eax
 a0a:	84 c0                	test   %al,%al
 a0c:	75 da                	jne    9e8 <printf+0xe7>
 a0e:	eb 65                	jmp    a75 <printf+0x174>
        }
      } else if(c == 'c'){
 a10:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 a14:	75 1d                	jne    a33 <printf+0x132>
        putc(fd, *ap);
 a16:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a19:	8b 00                	mov    (%eax),%eax
 a1b:	0f be c0             	movsbl %al,%eax
 a1e:	83 ec 08             	sub    $0x8,%esp
 a21:	50                   	push   %eax
 a22:	ff 75 08             	pushl  0x8(%ebp)
 a25:	e8 fb fd ff ff       	call   825 <putc>
 a2a:	83 c4 10             	add    $0x10,%esp
        ap++;
 a2d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a31:	eb 42                	jmp    a75 <printf+0x174>
      } else if(c == '%'){
 a33:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 a37:	75 17                	jne    a50 <printf+0x14f>
        putc(fd, c);
 a39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a3c:	0f be c0             	movsbl %al,%eax
 a3f:	83 ec 08             	sub    $0x8,%esp
 a42:	50                   	push   %eax
 a43:	ff 75 08             	pushl  0x8(%ebp)
 a46:	e8 da fd ff ff       	call   825 <putc>
 a4b:	83 c4 10             	add    $0x10,%esp
 a4e:	eb 25                	jmp    a75 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 a50:	83 ec 08             	sub    $0x8,%esp
 a53:	6a 25                	push   $0x25
 a55:	ff 75 08             	pushl  0x8(%ebp)
 a58:	e8 c8 fd ff ff       	call   825 <putc>
 a5d:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 a60:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a63:	0f be c0             	movsbl %al,%eax
 a66:	83 ec 08             	sub    $0x8,%esp
 a69:	50                   	push   %eax
 a6a:	ff 75 08             	pushl  0x8(%ebp)
 a6d:	e8 b3 fd ff ff       	call   825 <putc>
 a72:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 a75:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 a7c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 a80:	8b 55 0c             	mov    0xc(%ebp),%edx
 a83:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a86:	01 d0                	add    %edx,%eax
 a88:	0f b6 00             	movzbl (%eax),%eax
 a8b:	84 c0                	test   %al,%al
 a8d:	0f 85 94 fe ff ff    	jne    927 <printf+0x26>
    }
  }
}
 a93:	90                   	nop
 a94:	90                   	nop
 a95:	c9                   	leave  
 a96:	c3                   	ret    

00000a97 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a97:	f3 0f 1e fb          	endbr32 
 a9b:	55                   	push   %ebp
 a9c:	89 e5                	mov    %esp,%ebp
 a9e:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 aa1:	8b 45 08             	mov    0x8(%ebp),%eax
 aa4:	83 e8 08             	sub    $0x8,%eax
 aa7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 aaa:	a1 1c 11 00 00       	mov    0x111c,%eax
 aaf:	89 45 fc             	mov    %eax,-0x4(%ebp)
 ab2:	eb 24                	jmp    ad8 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ab4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ab7:	8b 00                	mov    (%eax),%eax
 ab9:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 abc:	72 12                	jb     ad0 <free+0x39>
 abe:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ac1:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 ac4:	77 24                	ja     aea <free+0x53>
 ac6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ac9:	8b 00                	mov    (%eax),%eax
 acb:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 ace:	72 1a                	jb     aea <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ad0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ad3:	8b 00                	mov    (%eax),%eax
 ad5:	89 45 fc             	mov    %eax,-0x4(%ebp)
 ad8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 adb:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 ade:	76 d4                	jbe    ab4 <free+0x1d>
 ae0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ae3:	8b 00                	mov    (%eax),%eax
 ae5:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 ae8:	73 ca                	jae    ab4 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 aea:	8b 45 f8             	mov    -0x8(%ebp),%eax
 aed:	8b 40 04             	mov    0x4(%eax),%eax
 af0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 af7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 afa:	01 c2                	add    %eax,%edx
 afc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aff:	8b 00                	mov    (%eax),%eax
 b01:	39 c2                	cmp    %eax,%edx
 b03:	75 24                	jne    b29 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 b05:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b08:	8b 50 04             	mov    0x4(%eax),%edx
 b0b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b0e:	8b 00                	mov    (%eax),%eax
 b10:	8b 40 04             	mov    0x4(%eax),%eax
 b13:	01 c2                	add    %eax,%edx
 b15:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b18:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 b1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b1e:	8b 00                	mov    (%eax),%eax
 b20:	8b 10                	mov    (%eax),%edx
 b22:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b25:	89 10                	mov    %edx,(%eax)
 b27:	eb 0a                	jmp    b33 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 b29:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b2c:	8b 10                	mov    (%eax),%edx
 b2e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b31:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 b33:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b36:	8b 40 04             	mov    0x4(%eax),%eax
 b39:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b40:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b43:	01 d0                	add    %edx,%eax
 b45:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 b48:	75 20                	jne    b6a <free+0xd3>
    p->s.size += bp->s.size;
 b4a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b4d:	8b 50 04             	mov    0x4(%eax),%edx
 b50:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b53:	8b 40 04             	mov    0x4(%eax),%eax
 b56:	01 c2                	add    %eax,%edx
 b58:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b5b:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 b5e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b61:	8b 10                	mov    (%eax),%edx
 b63:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b66:	89 10                	mov    %edx,(%eax)
 b68:	eb 08                	jmp    b72 <free+0xdb>
  } else
    p->s.ptr = bp;
 b6a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b6d:	8b 55 f8             	mov    -0x8(%ebp),%edx
 b70:	89 10                	mov    %edx,(%eax)
  freep = p;
 b72:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b75:	a3 1c 11 00 00       	mov    %eax,0x111c
}
 b7a:	90                   	nop
 b7b:	c9                   	leave  
 b7c:	c3                   	ret    

00000b7d <morecore>:

static Header*
morecore(uint nu)
{
 b7d:	f3 0f 1e fb          	endbr32 
 b81:	55                   	push   %ebp
 b82:	89 e5                	mov    %esp,%ebp
 b84:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 b87:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 b8e:	77 07                	ja     b97 <morecore+0x1a>
    nu = 4096;
 b90:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 b97:	8b 45 08             	mov    0x8(%ebp),%eax
 b9a:	c1 e0 03             	shl    $0x3,%eax
 b9d:	83 ec 0c             	sub    $0xc,%esp
 ba0:	50                   	push   %eax
 ba1:	e8 4f fc ff ff       	call   7f5 <sbrk>
 ba6:	83 c4 10             	add    $0x10,%esp
 ba9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 bac:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 bb0:	75 07                	jne    bb9 <morecore+0x3c>
    return 0;
 bb2:	b8 00 00 00 00       	mov    $0x0,%eax
 bb7:	eb 26                	jmp    bdf <morecore+0x62>
  hp = (Header*)p;
 bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bbc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 bbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bc2:	8b 55 08             	mov    0x8(%ebp),%edx
 bc5:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 bc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bcb:	83 c0 08             	add    $0x8,%eax
 bce:	83 ec 0c             	sub    $0xc,%esp
 bd1:	50                   	push   %eax
 bd2:	e8 c0 fe ff ff       	call   a97 <free>
 bd7:	83 c4 10             	add    $0x10,%esp
  return freep;
 bda:	a1 1c 11 00 00       	mov    0x111c,%eax
}
 bdf:	c9                   	leave  
 be0:	c3                   	ret    

00000be1 <malloc>:

void*
malloc(uint nbytes)
{
 be1:	f3 0f 1e fb          	endbr32 
 be5:	55                   	push   %ebp
 be6:	89 e5                	mov    %esp,%ebp
 be8:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 beb:	8b 45 08             	mov    0x8(%ebp),%eax
 bee:	83 c0 07             	add    $0x7,%eax
 bf1:	c1 e8 03             	shr    $0x3,%eax
 bf4:	83 c0 01             	add    $0x1,%eax
 bf7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 bfa:	a1 1c 11 00 00       	mov    0x111c,%eax
 bff:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c02:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 c06:	75 23                	jne    c2b <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 c08:	c7 45 f0 14 11 00 00 	movl   $0x1114,-0x10(%ebp)
 c0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c12:	a3 1c 11 00 00       	mov    %eax,0x111c
 c17:	a1 1c 11 00 00       	mov    0x111c,%eax
 c1c:	a3 14 11 00 00       	mov    %eax,0x1114
    base.s.size = 0;
 c21:	c7 05 18 11 00 00 00 	movl   $0x0,0x1118
 c28:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c2e:	8b 00                	mov    (%eax),%eax
 c30:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c36:	8b 40 04             	mov    0x4(%eax),%eax
 c39:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 c3c:	77 4d                	ja     c8b <malloc+0xaa>
      if(p->s.size == nunits)
 c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c41:	8b 40 04             	mov    0x4(%eax),%eax
 c44:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 c47:	75 0c                	jne    c55 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c4c:	8b 10                	mov    (%eax),%edx
 c4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c51:	89 10                	mov    %edx,(%eax)
 c53:	eb 26                	jmp    c7b <malloc+0x9a>
      else {
        p->s.size -= nunits;
 c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c58:	8b 40 04             	mov    0x4(%eax),%eax
 c5b:	2b 45 ec             	sub    -0x14(%ebp),%eax
 c5e:	89 c2                	mov    %eax,%edx
 c60:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c63:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c69:	8b 40 04             	mov    0x4(%eax),%eax
 c6c:	c1 e0 03             	shl    $0x3,%eax
 c6f:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c75:	8b 55 ec             	mov    -0x14(%ebp),%edx
 c78:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 c7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c7e:	a3 1c 11 00 00       	mov    %eax,0x111c
      return (void*)(p + 1);
 c83:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c86:	83 c0 08             	add    $0x8,%eax
 c89:	eb 3b                	jmp    cc6 <malloc+0xe5>
    }
    if(p == freep)
 c8b:	a1 1c 11 00 00       	mov    0x111c,%eax
 c90:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 c93:	75 1e                	jne    cb3 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 c95:	83 ec 0c             	sub    $0xc,%esp
 c98:	ff 75 ec             	pushl  -0x14(%ebp)
 c9b:	e8 dd fe ff ff       	call   b7d <morecore>
 ca0:	83 c4 10             	add    $0x10,%esp
 ca3:	89 45 f4             	mov    %eax,-0xc(%ebp)
 ca6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 caa:	75 07                	jne    cb3 <malloc+0xd2>
        return 0;
 cac:	b8 00 00 00 00       	mov    $0x0,%eax
 cb1:	eb 13                	jmp    cc6 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
 cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cbc:	8b 00                	mov    (%eax),%eax
 cbe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 cc1:	e9 6d ff ff ff       	jmp    c33 <malloc+0x52>
  }
}
 cc6:	c9                   	leave  
 cc7:	c3                   	ret    
