
_test_8:     file format elf32-i386


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
  10:	68 bc 0c 00 00       	push   $0xcbc
  15:	6a 01                	push   $0x1
  17:	e8 d7 08 00 00       	call   8f3 <printf>
  1c:	83 c4 10             	add    $0x10,%esp
    exit();
  1f:	e8 3b 07 00 00       	call   75f <exit>

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
  5d:	68 d0 0c 00 00       	push   $0xcd0
  62:	6a 01                	push   $0x1
  64:	e8 8a 08 00 00       	call   8f3 <printf>
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
  87:	c7 45 c4 20 00 00 00 	movl   $0x20,-0x3c(%ebp)
    const uint expected_dummy_pages_num = 4;
  8e:	c7 45 c0 04 00 00 00 	movl   $0x4,-0x40(%ebp)
    // These pages are used to make sure the test result is consistent for different text pages number
    char *dummy_pages[expected_dummy_pages_num];
  95:	8b 45 c0             	mov    -0x40(%ebp),%eax
  98:	83 e8 01             	sub    $0x1,%eax
  9b:	89 45 bc             	mov    %eax,-0x44(%ebp)
  9e:	8b 45 c0             	mov    -0x40(%ebp),%eax
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
 111:	89 45 b8             	mov    %eax,-0x48(%ebp)
    char *buffer = sbrk(PGSIZE * sizeof(char));
 114:	83 ec 0c             	sub    $0xc,%esp
 117:	68 00 10 00 00       	push   $0x1000
 11c:	e8 c6 06 00 00       	call   7e7 <sbrk>
 121:	83 c4 10             	add    $0x10,%esp
 124:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    char *sp = buffer - PGSIZE;
 127:	8b 45 b4             	mov    -0x4c(%ebp),%eax
 12a:	2d 00 10 00 00       	sub    $0x1000,%eax
 12f:	89 45 b0             	mov    %eax,-0x50(%ebp)
    char *boundary = buffer - 2 * PGSIZE;
 132:	8b 45 b4             	mov    -0x4c(%ebp),%eax
 135:	2d 00 20 00 00       	sub    $0x2000,%eax
 13a:	89 45 ac             	mov    %eax,-0x54(%ebp)
    struct pt_entry pt_entries[PAGES_NUM];
 13d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 140:	83 e8 01             	sub    $0x1,%eax
 143:	89 45 a8             	mov    %eax,-0x58(%ebp)
 146:	8b 45 c4             	mov    -0x3c(%ebp),%eax
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
 1b9:	89 45 a4             	mov    %eax,-0x5c(%ebp)

    uint text_pages = (uint) boundary / PGSIZE;
 1bc:	8b 45 ac             	mov    -0x54(%ebp),%eax
 1bf:	c1 e8 0c             	shr    $0xc,%eax
 1c2:	89 45 a0             	mov    %eax,-0x60(%ebp)
    if (text_pages > expected_dummy_pages_num - 1)
 1c5:	8b 45 c0             	mov    -0x40(%ebp),%eax
 1c8:	83 e8 01             	sub    $0x1,%eax
 1cb:	39 45 a0             	cmp    %eax,-0x60(%ebp)
 1ce:	76 10                	jbe    1e0 <main+0x171>
        err("XV6_TEST_OUTPUT: program size exceeds the maximum allowed size. Please let us know if this case happens\n");
 1d0:	83 ec 0c             	sub    $0xc,%esp
 1d3:	68 d4 0c 00 00       	push   $0xcd4
 1d8:	e8 23 fe ff ff       	call   0 <err>
 1dd:	83 c4 10             	add    $0x10,%esp
    
    for (int i = 0; i < text_pages; i++)
 1e0:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
 1e7:	eb 15                	jmp    1fe <main+0x18f>
        dummy_pages[i] = (char *)(i * PGSIZE);
 1e9:	8b 45 c8             	mov    -0x38(%ebp),%eax
 1ec:	c1 e0 0c             	shl    $0xc,%eax
 1ef:	89 c1                	mov    %eax,%ecx
 1f1:	8b 45 b8             	mov    -0x48(%ebp),%eax
 1f4:	8b 55 c8             	mov    -0x38(%ebp),%edx
 1f7:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    for (int i = 0; i < text_pages; i++)
 1fa:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
 1fe:	8b 45 c8             	mov    -0x38(%ebp),%eax
 201:	39 45 a0             	cmp    %eax,-0x60(%ebp)
 204:	77 e3                	ja     1e9 <main+0x17a>
    dummy_pages[text_pages] = sp;
 206:	8b 45 b8             	mov    -0x48(%ebp),%eax
 209:	8b 55 a0             	mov    -0x60(%ebp),%edx
 20c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
 20f:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    for (int i = text_pages + 1; i < expected_dummy_pages_num; i++)
 212:	8b 45 a0             	mov    -0x60(%ebp),%eax
 215:	83 c0 01             	add    $0x1,%eax
 218:	89 45 cc             	mov    %eax,-0x34(%ebp)
 21b:	eb 1d                	jmp    23a <main+0x1cb>
        dummy_pages[i] = sbrk(PGSIZE * sizeof(char));
 21d:	83 ec 0c             	sub    $0xc,%esp
 220:	68 00 10 00 00       	push   $0x1000
 225:	e8 bd 05 00 00       	call   7e7 <sbrk>
 22a:	83 c4 10             	add    $0x10,%esp
 22d:	8b 55 b8             	mov    -0x48(%ebp),%edx
 230:	8b 4d cc             	mov    -0x34(%ebp),%ecx
 233:	89 04 8a             	mov    %eax,(%edx,%ecx,4)
    for (int i = text_pages + 1; i < expected_dummy_pages_num; i++)
 236:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
 23a:	8b 45 cc             	mov    -0x34(%ebp),%eax
 23d:	39 45 c0             	cmp    %eax,-0x40(%ebp)
 240:	77 db                	ja     21d <main+0x1ae>
    

    // After this call, all the dummy pages including text pages and stack pages
    // should be resident in the clock queue.
    access_all_dummy_pages(dummy_pages, expected_dummy_pages_num);
 242:	83 ec 08             	sub    $0x8,%esp
 245:	ff 75 c0             	pushl  -0x40(%ebp)
 248:	ff 75 b8             	pushl  -0x48(%ebp)
 24b:	e8 d4 fd ff ff       	call   24 <access_all_dummy_pages>
 250:	83 c4 10             	add    $0x10,%esp

    // Bring the buffer page into the clock queue
    buffer[0] = buffer[0];
 253:	8b 45 b4             	mov    -0x4c(%ebp),%eax
 256:	0f b6 10             	movzbl (%eax),%edx
 259:	8b 45 b4             	mov    -0x4c(%ebp),%eax
 25c:	88 10                	mov    %dl,(%eax)

    // Now we should have expected_dummy_pages_num + 1 (buffer) pages in the clock queue
    // Fill up the remainig slot with heap-allocated page
    // and bring all of them into the clock queue
    int heap_pages_num = CLOCKSIZE - expected_dummy_pages_num - 1;
 25e:	b8 07 00 00 00       	mov    $0x7,%eax
 263:	2b 45 c0             	sub    -0x40(%ebp),%eax
 266:	89 45 9c             	mov    %eax,-0x64(%ebp)
    char *ptr = sbrk(heap_pages_num * PGSIZE * sizeof(char));
 269:	8b 45 9c             	mov    -0x64(%ebp),%eax
 26c:	c1 e0 0c             	shl    $0xc,%eax
 26f:	83 ec 0c             	sub    $0xc,%esp
 272:	50                   	push   %eax
 273:	e8 6f 05 00 00       	call   7e7 <sbrk>
 278:	83 c4 10             	add    $0x10,%esp
 27b:	89 45 98             	mov    %eax,-0x68(%ebp)
    ptr[heap_pages_num / 2 * PGSIZE] = 0xAA;
 27e:	8b 45 9c             	mov    -0x64(%ebp),%eax
 281:	89 c2                	mov    %eax,%edx
 283:	c1 ea 1f             	shr    $0x1f,%edx
 286:	01 d0                	add    %edx,%eax
 288:	d1 f8                	sar    %eax
 28a:	c1 e0 0c             	shl    $0xc,%eax
 28d:	89 c2                	mov    %eax,%edx
 28f:	8b 45 98             	mov    -0x68(%ebp),%eax
 292:	01 d0                	add    %edx,%eax
 294:	c6 00 aa             	movb   $0xaa,(%eax)
    for (int i = 0; i < heap_pages_num; i++) {
 297:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
 29e:	eb 31                	jmp    2d1 <main+0x262>
      for (int j = 0; j < PGSIZE; j++) {
 2a0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 2a7:	eb 1b                	jmp    2c4 <main+0x255>
        ptr[i * PGSIZE + j] = 0xAA;
 2a9:	8b 45 d0             	mov    -0x30(%ebp),%eax
 2ac:	c1 e0 0c             	shl    $0xc,%eax
 2af:	89 c2                	mov    %eax,%edx
 2b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 2b4:	01 d0                	add    %edx,%eax
 2b6:	89 c2                	mov    %eax,%edx
 2b8:	8b 45 98             	mov    -0x68(%ebp),%eax
 2bb:	01 d0                	add    %edx,%eax
 2bd:	c6 00 aa             	movb   $0xaa,(%eax)
      for (int j = 0; j < PGSIZE; j++) {
 2c0:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
 2c4:	81 7d d4 ff 0f 00 00 	cmpl   $0xfff,-0x2c(%ebp)
 2cb:	7e dc                	jle    2a9 <main+0x23a>
    for (int i = 0; i < heap_pages_num; i++) {
 2cd:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
 2d1:	8b 45 d0             	mov    -0x30(%ebp),%eax
 2d4:	3b 45 9c             	cmp    -0x64(%ebp),%eax
 2d7:	7c c7                	jl     2a0 <main+0x231>
      }
    }
    
    // An extra page which will trigger the page eviction
    // This eviction will evict page 0
    char* extra_pages = sbrk(PGSIZE * sizeof(char));
 2d9:	83 ec 0c             	sub    $0xc,%esp
 2dc:	68 00 10 00 00       	push   $0x1000
 2e1:	e8 01 05 00 00       	call   7e7 <sbrk>
 2e6:	83 c4 10             	add    $0x10,%esp
 2e9:	89 45 94             	mov    %eax,-0x6c(%ebp)
    for (int j = 0; j < PGSIZE; j++) {
 2ec:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
 2f3:	eb 0f                	jmp    304 <main+0x295>
      extra_pages[j] = 0xAA;
 2f5:	8b 55 d8             	mov    -0x28(%ebp),%edx
 2f8:	8b 45 94             	mov    -0x6c(%ebp),%eax
 2fb:	01 d0                	add    %edx,%eax
 2fd:	c6 00 aa             	movb   $0xaa,(%eax)
    for (int j = 0; j < PGSIZE; j++) {
 300:	83 45 d8 01          	addl   $0x1,-0x28(%ebp)
 304:	81 7d d8 ff 0f 00 00 	cmpl   $0xfff,-0x28(%ebp)
 30b:	7e e8                	jle    2f5 <main+0x286>
    }

    // Bring all the dummy pages and buffer back to the 
    // clock queue and reset their ref to 1
    // At this time, the first heap-allocated page is ensured to be evicted
    access_all_dummy_pages(dummy_pages, expected_dummy_pages_num);
 30d:	83 ec 08             	sub    $0x8,%esp
 310:	ff 75 c0             	pushl  -0x40(%ebp)
 313:	ff 75 b8             	pushl  -0x48(%ebp)
 316:	e8 09 fd ff ff       	call   24 <access_all_dummy_pages>
 31b:	83 c4 10             	add    $0x10,%esp
    buffer[0] = buffer[0];
 31e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
 321:	0f b6 10             	movzbl (%eax),%edx
 324:	8b 45 b4             	mov    -0x4c(%ebp),%eax
 327:	88 10                	mov    %dl,(%eax)

    // Verify that the pages pointed by the ptr is evicted
    int retval = getpgtable(pt_entries, heap_pages_num + 1, 0);
 329:	8b 45 9c             	mov    -0x64(%ebp),%eax
 32c:	83 c0 01             	add    $0x1,%eax
 32f:	83 ec 04             	sub    $0x4,%esp
 332:	6a 00                	push   $0x0
 334:	50                   	push   %eax
 335:	ff 75 a4             	pushl  -0x5c(%ebp)
 338:	e8 ca 04 00 00       	call   807 <getpgtable>
 33d:	83 c4 10             	add    $0x10,%esp
 340:	89 45 90             	mov    %eax,-0x70(%ebp)
    if (retval == heap_pages_num + 1) {
 343:	8b 45 9c             	mov    -0x64(%ebp),%eax
 346:	83 c0 01             	add    $0x1,%eax
 349:	39 45 90             	cmp    %eax,-0x70(%ebp)
 34c:	0f 85 78 01 00 00    	jne    4ca <main+0x45b>
      for (int i = 0; i < retval; i++) {
 352:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
 359:	e9 5e 01 00 00       	jmp    4bc <main+0x44d>
              i,
              pt_entries[i].pdx,
              pt_entries[i].ptx,
              pt_entries[i].writable,
              pt_entries[i].encrypted,
              pt_entries[i].ref
 35e:	8b 45 a4             	mov    -0x5c(%ebp),%eax
 361:	8b 55 dc             	mov    -0x24(%ebp),%edx
 364:	0f b6 44 d0 07       	movzbl 0x7(%eax,%edx,8),%eax
 369:	83 e0 01             	and    $0x1,%eax
          printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, writable bit: %d, encrypted: %d, ref: %d\n", 
 36c:	0f b6 f0             	movzbl %al,%esi
              pt_entries[i].encrypted,
 36f:	8b 45 a4             	mov    -0x5c(%ebp),%eax
 372:	8b 55 dc             	mov    -0x24(%ebp),%edx
 375:	0f b6 44 d0 06       	movzbl 0x6(%eax,%edx,8),%eax
 37a:	c0 e8 07             	shr    $0x7,%al
          printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, writable bit: %d, encrypted: %d, ref: %d\n", 
 37d:	0f b6 d8             	movzbl %al,%ebx
              pt_entries[i].writable,
 380:	8b 45 a4             	mov    -0x5c(%ebp),%eax
 383:	8b 55 dc             	mov    -0x24(%ebp),%edx
 386:	0f b6 44 d0 06       	movzbl 0x6(%eax,%edx,8),%eax
 38b:	c0 e8 05             	shr    $0x5,%al
 38e:	83 e0 01             	and    $0x1,%eax
          printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, writable bit: %d, encrypted: %d, ref: %d\n", 
 391:	0f b6 c8             	movzbl %al,%ecx
              pt_entries[i].ptx,
 394:	8b 45 a4             	mov    -0x5c(%ebp),%eax
 397:	8b 55 dc             	mov    -0x24(%ebp),%edx
 39a:	8b 04 d0             	mov    (%eax,%edx,8),%eax
 39d:	c1 e8 0a             	shr    $0xa,%eax
 3a0:	66 25 ff 03          	and    $0x3ff,%ax
          printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, writable bit: %d, encrypted: %d, ref: %d\n", 
 3a4:	0f b7 d0             	movzwl %ax,%edx
              pt_entries[i].pdx,
 3a7:	8b 45 a4             	mov    -0x5c(%ebp),%eax
 3aa:	8b 7d dc             	mov    -0x24(%ebp),%edi
 3ad:	0f b7 04 f8          	movzwl (%eax,%edi,8),%eax
 3b1:	66 25 ff 03          	and    $0x3ff,%ax
          printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, writable bit: %d, encrypted: %d, ref: %d\n", 
 3b5:	0f b7 c0             	movzwl %ax,%eax
 3b8:	56                   	push   %esi
 3b9:	53                   	push   %ebx
 3ba:	51                   	push   %ecx
 3bb:	52                   	push   %edx
 3bc:	50                   	push   %eax
 3bd:	ff 75 dc             	pushl  -0x24(%ebp)
 3c0:	68 40 0d 00 00       	push   $0xd40
 3c5:	6a 01                	push   $0x1
 3c7:	e8 27 05 00 00       	call   8f3 <printf>
 3cc:	83 c4 20             	add    $0x20,%esp
          ); 
          
          uint expected = 0xAA;
 3cf:	c7 45 e0 aa 00 00 00 	movl   $0xaa,-0x20(%ebp)
          if (pt_entries[i].encrypted)
 3d6:	8b 45 a4             	mov    -0x5c(%ebp),%eax
 3d9:	8b 55 dc             	mov    -0x24(%ebp),%edx
 3dc:	0f b6 44 d0 06       	movzbl 0x6(%eax,%edx,8),%eax
 3e1:	c0 e8 07             	shr    $0x7,%al
 3e4:	84 c0                	test   %al,%al
 3e6:	74 07                	je     3ef <main+0x380>
            expected = ~0xAA;
 3e8:	c7 45 e0 55 ff ff ff 	movl   $0xffffff55,-0x20(%ebp)

          if (dump_rawphymem(pt_entries[i].ppage * PGSIZE, buffer) != 0)
 3ef:	8b 45 a4             	mov    -0x5c(%ebp),%eax
 3f2:	8b 55 dc             	mov    -0x24(%ebp),%edx
 3f5:	8b 44 d0 04          	mov    0x4(%eax,%edx,8),%eax
 3f9:	25 ff ff 0f 00       	and    $0xfffff,%eax
 3fe:	c1 e0 0c             	shl    $0xc,%eax
 401:	83 ec 08             	sub    $0x8,%esp
 404:	ff 75 b4             	pushl  -0x4c(%ebp)
 407:	50                   	push   %eax
 408:	e8 02 04 00 00       	call   80f <dump_rawphymem>
 40d:	83 c4 10             	add    $0x10,%esp
 410:	85 c0                	test   %eax,%eax
 412:	74 10                	je     424 <main+0x3b5>
              err("dump_rawphymem return non-zero value\n");
 414:	83 ec 0c             	sub    $0xc,%esp
 417:	68 9c 0d 00 00       	push   $0xd9c
 41c:	e8 df fb ff ff       	call   0 <err>
 421:	83 c4 10             	add    $0x10,%esp
          
          for (int j = 0; j < PGSIZE; j++) {
 424:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 42b:	eb 7e                	jmp    4ab <main+0x43c>
              if (buffer[j] != (char)expected) {
 42d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 430:	8b 45 b4             	mov    -0x4c(%ebp),%eax
 433:	01 d0                	add    %edx,%eax
 435:	0f b6 00             	movzbl (%eax),%eax
 438:	8b 55 e0             	mov    -0x20(%ebp),%edx
 43b:	38 d0                	cmp    %dl,%al
 43d:	74 68                	je     4a7 <main+0x438>
                  // err("physical memory is dumped incorrectly\n");
                    printf(1, "XV6_TEST_OUTPUT: content is incorrect at address 0x%x: expected 0x%x, got 0x%x\n", ((uint)(pt_entries[i].pdx) << 22 | (pt_entries[i].ptx) << 12) + j ,expected & 0xFF, buffer[j] & 0xFF);
 43f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 442:	8b 45 b4             	mov    -0x4c(%ebp),%eax
 445:	01 d0                	add    %edx,%eax
 447:	0f b6 00             	movzbl (%eax),%eax
 44a:	0f be c0             	movsbl %al,%eax
 44d:	0f b6 d0             	movzbl %al,%edx
 450:	8b 45 e0             	mov    -0x20(%ebp),%eax
 453:	0f b6 c0             	movzbl %al,%eax
 456:	8b 4d a4             	mov    -0x5c(%ebp),%ecx
 459:	8b 5d dc             	mov    -0x24(%ebp),%ebx
 45c:	0f b7 0c d9          	movzwl (%ecx,%ebx,8),%ecx
 460:	66 81 e1 ff 03       	and    $0x3ff,%cx
 465:	0f b7 c9             	movzwl %cx,%ecx
 468:	89 ce                	mov    %ecx,%esi
 46a:	c1 e6 16             	shl    $0x16,%esi
 46d:	8b 4d a4             	mov    -0x5c(%ebp),%ecx
 470:	8b 5d dc             	mov    -0x24(%ebp),%ebx
 473:	8b 0c d9             	mov    (%ecx,%ebx,8),%ecx
 476:	c1 e9 0a             	shr    $0xa,%ecx
 479:	66 81 e1 ff 03       	and    $0x3ff,%cx
 47e:	0f b7 c9             	movzwl %cx,%ecx
 481:	c1 e1 0c             	shl    $0xc,%ecx
 484:	89 f3                	mov    %esi,%ebx
 486:	09 cb                	or     %ecx,%ebx
 488:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
 48b:	01 d9                	add    %ebx,%ecx
 48d:	83 ec 0c             	sub    $0xc,%esp
 490:	52                   	push   %edx
 491:	50                   	push   %eax
 492:	51                   	push   %ecx
 493:	68 c4 0d 00 00       	push   $0xdc4
 498:	6a 01                	push   $0x1
 49a:	e8 54 04 00 00       	call   8f3 <printf>
 49f:	83 c4 20             	add    $0x20,%esp
                    exit();
 4a2:	e8 b8 02 00 00       	call   75f <exit>
          for (int j = 0; j < PGSIZE; j++) {
 4a7:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
 4ab:	81 7d e4 ff 0f 00 00 	cmpl   $0xfff,-0x1c(%ebp)
 4b2:	0f 8e 75 ff ff ff    	jle    42d <main+0x3be>
      for (int i = 0; i < retval; i++) {
 4b8:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
 4bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
 4bf:	3b 45 90             	cmp    -0x70(%ebp),%eax
 4c2:	0f 8c 96 fe ff ff    	jl     35e <main+0x2ef>
 4c8:	eb 15                	jmp    4df <main+0x470>
              }
          }

      }
    } else
        printf(1, "XV6_TEST_OUTPUT: getpgtable returned incorrect value: expected %d, got %d\n", heap_pages_num, retval);
 4ca:	ff 75 90             	pushl  -0x70(%ebp)
 4cd:	ff 75 9c             	pushl  -0x64(%ebp)
 4d0:	68 14 0e 00 00       	push   $0xe14
 4d5:	6a 01                	push   $0x1
 4d7:	e8 17 04 00 00       	call   8f3 <printf>
 4dc:	83 c4 10             	add    $0x10,%esp
    
    exit();
 4df:	e8 7b 02 00 00       	call   75f <exit>

000004e4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 4e4:	55                   	push   %ebp
 4e5:	89 e5                	mov    %esp,%ebp
 4e7:	57                   	push   %edi
 4e8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 4e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
 4ec:	8b 55 10             	mov    0x10(%ebp),%edx
 4ef:	8b 45 0c             	mov    0xc(%ebp),%eax
 4f2:	89 cb                	mov    %ecx,%ebx
 4f4:	89 df                	mov    %ebx,%edi
 4f6:	89 d1                	mov    %edx,%ecx
 4f8:	fc                   	cld    
 4f9:	f3 aa                	rep stos %al,%es:(%edi)
 4fb:	89 ca                	mov    %ecx,%edx
 4fd:	89 fb                	mov    %edi,%ebx
 4ff:	89 5d 08             	mov    %ebx,0x8(%ebp)
 502:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 505:	90                   	nop
 506:	5b                   	pop    %ebx
 507:	5f                   	pop    %edi
 508:	5d                   	pop    %ebp
 509:	c3                   	ret    

0000050a <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 50a:	f3 0f 1e fb          	endbr32 
 50e:	55                   	push   %ebp
 50f:	89 e5                	mov    %esp,%ebp
 511:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 514:	8b 45 08             	mov    0x8(%ebp),%eax
 517:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 51a:	90                   	nop
 51b:	8b 55 0c             	mov    0xc(%ebp),%edx
 51e:	8d 42 01             	lea    0x1(%edx),%eax
 521:	89 45 0c             	mov    %eax,0xc(%ebp)
 524:	8b 45 08             	mov    0x8(%ebp),%eax
 527:	8d 48 01             	lea    0x1(%eax),%ecx
 52a:	89 4d 08             	mov    %ecx,0x8(%ebp)
 52d:	0f b6 12             	movzbl (%edx),%edx
 530:	88 10                	mov    %dl,(%eax)
 532:	0f b6 00             	movzbl (%eax),%eax
 535:	84 c0                	test   %al,%al
 537:	75 e2                	jne    51b <strcpy+0x11>
    ;
  return os;
 539:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 53c:	c9                   	leave  
 53d:	c3                   	ret    

0000053e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 53e:	f3 0f 1e fb          	endbr32 
 542:	55                   	push   %ebp
 543:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 545:	eb 08                	jmp    54f <strcmp+0x11>
    p++, q++;
 547:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 54b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 54f:	8b 45 08             	mov    0x8(%ebp),%eax
 552:	0f b6 00             	movzbl (%eax),%eax
 555:	84 c0                	test   %al,%al
 557:	74 10                	je     569 <strcmp+0x2b>
 559:	8b 45 08             	mov    0x8(%ebp),%eax
 55c:	0f b6 10             	movzbl (%eax),%edx
 55f:	8b 45 0c             	mov    0xc(%ebp),%eax
 562:	0f b6 00             	movzbl (%eax),%eax
 565:	38 c2                	cmp    %al,%dl
 567:	74 de                	je     547 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 569:	8b 45 08             	mov    0x8(%ebp),%eax
 56c:	0f b6 00             	movzbl (%eax),%eax
 56f:	0f b6 d0             	movzbl %al,%edx
 572:	8b 45 0c             	mov    0xc(%ebp),%eax
 575:	0f b6 00             	movzbl (%eax),%eax
 578:	0f b6 c0             	movzbl %al,%eax
 57b:	29 c2                	sub    %eax,%edx
 57d:	89 d0                	mov    %edx,%eax
}
 57f:	5d                   	pop    %ebp
 580:	c3                   	ret    

00000581 <strlen>:

uint
strlen(const char *s)
{
 581:	f3 0f 1e fb          	endbr32 
 585:	55                   	push   %ebp
 586:	89 e5                	mov    %esp,%ebp
 588:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 58b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 592:	eb 04                	jmp    598 <strlen+0x17>
 594:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 598:	8b 55 fc             	mov    -0x4(%ebp),%edx
 59b:	8b 45 08             	mov    0x8(%ebp),%eax
 59e:	01 d0                	add    %edx,%eax
 5a0:	0f b6 00             	movzbl (%eax),%eax
 5a3:	84 c0                	test   %al,%al
 5a5:	75 ed                	jne    594 <strlen+0x13>
    ;
  return n;
 5a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 5aa:	c9                   	leave  
 5ab:	c3                   	ret    

000005ac <memset>:

void*
memset(void *dst, int c, uint n)
{
 5ac:	f3 0f 1e fb          	endbr32 
 5b0:	55                   	push   %ebp
 5b1:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 5b3:	8b 45 10             	mov    0x10(%ebp),%eax
 5b6:	50                   	push   %eax
 5b7:	ff 75 0c             	pushl  0xc(%ebp)
 5ba:	ff 75 08             	pushl  0x8(%ebp)
 5bd:	e8 22 ff ff ff       	call   4e4 <stosb>
 5c2:	83 c4 0c             	add    $0xc,%esp
  return dst;
 5c5:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5c8:	c9                   	leave  
 5c9:	c3                   	ret    

000005ca <strchr>:

char*
strchr(const char *s, char c)
{
 5ca:	f3 0f 1e fb          	endbr32 
 5ce:	55                   	push   %ebp
 5cf:	89 e5                	mov    %esp,%ebp
 5d1:	83 ec 04             	sub    $0x4,%esp
 5d4:	8b 45 0c             	mov    0xc(%ebp),%eax
 5d7:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 5da:	eb 14                	jmp    5f0 <strchr+0x26>
    if(*s == c)
 5dc:	8b 45 08             	mov    0x8(%ebp),%eax
 5df:	0f b6 00             	movzbl (%eax),%eax
 5e2:	38 45 fc             	cmp    %al,-0x4(%ebp)
 5e5:	75 05                	jne    5ec <strchr+0x22>
      return (char*)s;
 5e7:	8b 45 08             	mov    0x8(%ebp),%eax
 5ea:	eb 13                	jmp    5ff <strchr+0x35>
  for(; *s; s++)
 5ec:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 5f0:	8b 45 08             	mov    0x8(%ebp),%eax
 5f3:	0f b6 00             	movzbl (%eax),%eax
 5f6:	84 c0                	test   %al,%al
 5f8:	75 e2                	jne    5dc <strchr+0x12>
  return 0;
 5fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
 5ff:	c9                   	leave  
 600:	c3                   	ret    

00000601 <gets>:

char*
gets(char *buf, int max)
{
 601:	f3 0f 1e fb          	endbr32 
 605:	55                   	push   %ebp
 606:	89 e5                	mov    %esp,%ebp
 608:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 60b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 612:	eb 42                	jmp    656 <gets+0x55>
    cc = read(0, &c, 1);
 614:	83 ec 04             	sub    $0x4,%esp
 617:	6a 01                	push   $0x1
 619:	8d 45 ef             	lea    -0x11(%ebp),%eax
 61c:	50                   	push   %eax
 61d:	6a 00                	push   $0x0
 61f:	e8 53 01 00 00       	call   777 <read>
 624:	83 c4 10             	add    $0x10,%esp
 627:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 62a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 62e:	7e 33                	jle    663 <gets+0x62>
      break;
    buf[i++] = c;
 630:	8b 45 f4             	mov    -0xc(%ebp),%eax
 633:	8d 50 01             	lea    0x1(%eax),%edx
 636:	89 55 f4             	mov    %edx,-0xc(%ebp)
 639:	89 c2                	mov    %eax,%edx
 63b:	8b 45 08             	mov    0x8(%ebp),%eax
 63e:	01 c2                	add    %eax,%edx
 640:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 644:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 646:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 64a:	3c 0a                	cmp    $0xa,%al
 64c:	74 16                	je     664 <gets+0x63>
 64e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 652:	3c 0d                	cmp    $0xd,%al
 654:	74 0e                	je     664 <gets+0x63>
  for(i=0; i+1 < max; ){
 656:	8b 45 f4             	mov    -0xc(%ebp),%eax
 659:	83 c0 01             	add    $0x1,%eax
 65c:	39 45 0c             	cmp    %eax,0xc(%ebp)
 65f:	7f b3                	jg     614 <gets+0x13>
 661:	eb 01                	jmp    664 <gets+0x63>
      break;
 663:	90                   	nop
      break;
  }
  buf[i] = '\0';
 664:	8b 55 f4             	mov    -0xc(%ebp),%edx
 667:	8b 45 08             	mov    0x8(%ebp),%eax
 66a:	01 d0                	add    %edx,%eax
 66c:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 66f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 672:	c9                   	leave  
 673:	c3                   	ret    

00000674 <stat>:

int
stat(const char *n, struct stat *st)
{
 674:	f3 0f 1e fb          	endbr32 
 678:	55                   	push   %ebp
 679:	89 e5                	mov    %esp,%ebp
 67b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 67e:	83 ec 08             	sub    $0x8,%esp
 681:	6a 00                	push   $0x0
 683:	ff 75 08             	pushl  0x8(%ebp)
 686:	e8 14 01 00 00       	call   79f <open>
 68b:	83 c4 10             	add    $0x10,%esp
 68e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 691:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 695:	79 07                	jns    69e <stat+0x2a>
    return -1;
 697:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 69c:	eb 25                	jmp    6c3 <stat+0x4f>
  r = fstat(fd, st);
 69e:	83 ec 08             	sub    $0x8,%esp
 6a1:	ff 75 0c             	pushl  0xc(%ebp)
 6a4:	ff 75 f4             	pushl  -0xc(%ebp)
 6a7:	e8 0b 01 00 00       	call   7b7 <fstat>
 6ac:	83 c4 10             	add    $0x10,%esp
 6af:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 6b2:	83 ec 0c             	sub    $0xc,%esp
 6b5:	ff 75 f4             	pushl  -0xc(%ebp)
 6b8:	e8 ca 00 00 00       	call   787 <close>
 6bd:	83 c4 10             	add    $0x10,%esp
  return r;
 6c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 6c3:	c9                   	leave  
 6c4:	c3                   	ret    

000006c5 <atoi>:

int
atoi(const char *s)
{
 6c5:	f3 0f 1e fb          	endbr32 
 6c9:	55                   	push   %ebp
 6ca:	89 e5                	mov    %esp,%ebp
 6cc:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 6cf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 6d6:	eb 25                	jmp    6fd <atoi+0x38>
    n = n*10 + *s++ - '0';
 6d8:	8b 55 fc             	mov    -0x4(%ebp),%edx
 6db:	89 d0                	mov    %edx,%eax
 6dd:	c1 e0 02             	shl    $0x2,%eax
 6e0:	01 d0                	add    %edx,%eax
 6e2:	01 c0                	add    %eax,%eax
 6e4:	89 c1                	mov    %eax,%ecx
 6e6:	8b 45 08             	mov    0x8(%ebp),%eax
 6e9:	8d 50 01             	lea    0x1(%eax),%edx
 6ec:	89 55 08             	mov    %edx,0x8(%ebp)
 6ef:	0f b6 00             	movzbl (%eax),%eax
 6f2:	0f be c0             	movsbl %al,%eax
 6f5:	01 c8                	add    %ecx,%eax
 6f7:	83 e8 30             	sub    $0x30,%eax
 6fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 6fd:	8b 45 08             	mov    0x8(%ebp),%eax
 700:	0f b6 00             	movzbl (%eax),%eax
 703:	3c 2f                	cmp    $0x2f,%al
 705:	7e 0a                	jle    711 <atoi+0x4c>
 707:	8b 45 08             	mov    0x8(%ebp),%eax
 70a:	0f b6 00             	movzbl (%eax),%eax
 70d:	3c 39                	cmp    $0x39,%al
 70f:	7e c7                	jle    6d8 <atoi+0x13>
  return n;
 711:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 714:	c9                   	leave  
 715:	c3                   	ret    

00000716 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 716:	f3 0f 1e fb          	endbr32 
 71a:	55                   	push   %ebp
 71b:	89 e5                	mov    %esp,%ebp
 71d:	83 ec 10             	sub    $0x10,%esp
  char *dst;
  const char *src;

  dst = vdst;
 720:	8b 45 08             	mov    0x8(%ebp),%eax
 723:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 726:	8b 45 0c             	mov    0xc(%ebp),%eax
 729:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 72c:	eb 17                	jmp    745 <memmove+0x2f>
    *dst++ = *src++;
 72e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 731:	8d 42 01             	lea    0x1(%edx),%eax
 734:	89 45 f8             	mov    %eax,-0x8(%ebp)
 737:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73a:	8d 48 01             	lea    0x1(%eax),%ecx
 73d:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 740:	0f b6 12             	movzbl (%edx),%edx
 743:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 745:	8b 45 10             	mov    0x10(%ebp),%eax
 748:	8d 50 ff             	lea    -0x1(%eax),%edx
 74b:	89 55 10             	mov    %edx,0x10(%ebp)
 74e:	85 c0                	test   %eax,%eax
 750:	7f dc                	jg     72e <memmove+0x18>
  return vdst;
 752:	8b 45 08             	mov    0x8(%ebp),%eax
}
 755:	c9                   	leave  
 756:	c3                   	ret    

00000757 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 757:	b8 01 00 00 00       	mov    $0x1,%eax
 75c:	cd 40                	int    $0x40
 75e:	c3                   	ret    

0000075f <exit>:
SYSCALL(exit)
 75f:	b8 02 00 00 00       	mov    $0x2,%eax
 764:	cd 40                	int    $0x40
 766:	c3                   	ret    

00000767 <wait>:
SYSCALL(wait)
 767:	b8 03 00 00 00       	mov    $0x3,%eax
 76c:	cd 40                	int    $0x40
 76e:	c3                   	ret    

0000076f <pipe>:
SYSCALL(pipe)
 76f:	b8 04 00 00 00       	mov    $0x4,%eax
 774:	cd 40                	int    $0x40
 776:	c3                   	ret    

00000777 <read>:
SYSCALL(read)
 777:	b8 05 00 00 00       	mov    $0x5,%eax
 77c:	cd 40                	int    $0x40
 77e:	c3                   	ret    

0000077f <write>:
SYSCALL(write)
 77f:	b8 10 00 00 00       	mov    $0x10,%eax
 784:	cd 40                	int    $0x40
 786:	c3                   	ret    

00000787 <close>:
SYSCALL(close)
 787:	b8 15 00 00 00       	mov    $0x15,%eax
 78c:	cd 40                	int    $0x40
 78e:	c3                   	ret    

0000078f <kill>:
SYSCALL(kill)
 78f:	b8 06 00 00 00       	mov    $0x6,%eax
 794:	cd 40                	int    $0x40
 796:	c3                   	ret    

00000797 <exec>:
SYSCALL(exec)
 797:	b8 07 00 00 00       	mov    $0x7,%eax
 79c:	cd 40                	int    $0x40
 79e:	c3                   	ret    

0000079f <open>:
SYSCALL(open)
 79f:	b8 0f 00 00 00       	mov    $0xf,%eax
 7a4:	cd 40                	int    $0x40
 7a6:	c3                   	ret    

000007a7 <mknod>:
SYSCALL(mknod)
 7a7:	b8 11 00 00 00       	mov    $0x11,%eax
 7ac:	cd 40                	int    $0x40
 7ae:	c3                   	ret    

000007af <unlink>:
SYSCALL(unlink)
 7af:	b8 12 00 00 00       	mov    $0x12,%eax
 7b4:	cd 40                	int    $0x40
 7b6:	c3                   	ret    

000007b7 <fstat>:
SYSCALL(fstat)
 7b7:	b8 08 00 00 00       	mov    $0x8,%eax
 7bc:	cd 40                	int    $0x40
 7be:	c3                   	ret    

000007bf <link>:
SYSCALL(link)
 7bf:	b8 13 00 00 00       	mov    $0x13,%eax
 7c4:	cd 40                	int    $0x40
 7c6:	c3                   	ret    

000007c7 <mkdir>:
SYSCALL(mkdir)
 7c7:	b8 14 00 00 00       	mov    $0x14,%eax
 7cc:	cd 40                	int    $0x40
 7ce:	c3                   	ret    

000007cf <chdir>:
SYSCALL(chdir)
 7cf:	b8 09 00 00 00       	mov    $0x9,%eax
 7d4:	cd 40                	int    $0x40
 7d6:	c3                   	ret    

000007d7 <dup>:
SYSCALL(dup)
 7d7:	b8 0a 00 00 00       	mov    $0xa,%eax
 7dc:	cd 40                	int    $0x40
 7de:	c3                   	ret    

000007df <getpid>:
SYSCALL(getpid)
 7df:	b8 0b 00 00 00       	mov    $0xb,%eax
 7e4:	cd 40                	int    $0x40
 7e6:	c3                   	ret    

000007e7 <sbrk>:
SYSCALL(sbrk)
 7e7:	b8 0c 00 00 00       	mov    $0xc,%eax
 7ec:	cd 40                	int    $0x40
 7ee:	c3                   	ret    

000007ef <sleep>:
SYSCALL(sleep)
 7ef:	b8 0d 00 00 00       	mov    $0xd,%eax
 7f4:	cd 40                	int    $0x40
 7f6:	c3                   	ret    

000007f7 <uptime>:
SYSCALL(uptime)
 7f7:	b8 0e 00 00 00       	mov    $0xe,%eax
 7fc:	cd 40                	int    $0x40
 7fe:	c3                   	ret    

000007ff <mencrypt>:
SYSCALL(mencrypt)
 7ff:	b8 16 00 00 00       	mov    $0x16,%eax
 804:	cd 40                	int    $0x40
 806:	c3                   	ret    

00000807 <getpgtable>:
SYSCALL(getpgtable)
 807:	b8 17 00 00 00       	mov    $0x17,%eax
 80c:	cd 40                	int    $0x40
 80e:	c3                   	ret    

0000080f <dump_rawphymem>:
SYSCALL(dump_rawphymem)
 80f:	b8 18 00 00 00       	mov    $0x18,%eax
 814:	cd 40                	int    $0x40
 816:	c3                   	ret    

00000817 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 817:	f3 0f 1e fb          	endbr32 
 81b:	55                   	push   %ebp
 81c:	89 e5                	mov    %esp,%ebp
 81e:	83 ec 18             	sub    $0x18,%esp
 821:	8b 45 0c             	mov    0xc(%ebp),%eax
 824:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 827:	83 ec 04             	sub    $0x4,%esp
 82a:	6a 01                	push   $0x1
 82c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 82f:	50                   	push   %eax
 830:	ff 75 08             	pushl  0x8(%ebp)
 833:	e8 47 ff ff ff       	call   77f <write>
 838:	83 c4 10             	add    $0x10,%esp
}
 83b:	90                   	nop
 83c:	c9                   	leave  
 83d:	c3                   	ret    

0000083e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 83e:	f3 0f 1e fb          	endbr32 
 842:	55                   	push   %ebp
 843:	89 e5                	mov    %esp,%ebp
 845:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 848:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 84f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 853:	74 17                	je     86c <printint+0x2e>
 855:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 859:	79 11                	jns    86c <printint+0x2e>
    neg = 1;
 85b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 862:	8b 45 0c             	mov    0xc(%ebp),%eax
 865:	f7 d8                	neg    %eax
 867:	89 45 ec             	mov    %eax,-0x14(%ebp)
 86a:	eb 06                	jmp    872 <printint+0x34>
  } else {
    x = xx;
 86c:	8b 45 0c             	mov    0xc(%ebp),%eax
 86f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 872:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 879:	8b 4d 10             	mov    0x10(%ebp),%ecx
 87c:	8b 45 ec             	mov    -0x14(%ebp),%eax
 87f:	ba 00 00 00 00       	mov    $0x0,%edx
 884:	f7 f1                	div    %ecx
 886:	89 d1                	mov    %edx,%ecx
 888:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88b:	8d 50 01             	lea    0x1(%eax),%edx
 88e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 891:	0f b6 91 f4 10 00 00 	movzbl 0x10f4(%ecx),%edx
 898:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 89c:	8b 4d 10             	mov    0x10(%ebp),%ecx
 89f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8a2:	ba 00 00 00 00       	mov    $0x0,%edx
 8a7:	f7 f1                	div    %ecx
 8a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 8ac:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 8b0:	75 c7                	jne    879 <printint+0x3b>
  if(neg)
 8b2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8b6:	74 2d                	je     8e5 <printint+0xa7>
    buf[i++] = '-';
 8b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8bb:	8d 50 01             	lea    0x1(%eax),%edx
 8be:	89 55 f4             	mov    %edx,-0xc(%ebp)
 8c1:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 8c6:	eb 1d                	jmp    8e5 <printint+0xa7>
    putc(fd, buf[i]);
 8c8:	8d 55 dc             	lea    -0x24(%ebp),%edx
 8cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ce:	01 d0                	add    %edx,%eax
 8d0:	0f b6 00             	movzbl (%eax),%eax
 8d3:	0f be c0             	movsbl %al,%eax
 8d6:	83 ec 08             	sub    $0x8,%esp
 8d9:	50                   	push   %eax
 8da:	ff 75 08             	pushl  0x8(%ebp)
 8dd:	e8 35 ff ff ff       	call   817 <putc>
 8e2:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 8e5:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 8e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8ed:	79 d9                	jns    8c8 <printint+0x8a>
}
 8ef:	90                   	nop
 8f0:	90                   	nop
 8f1:	c9                   	leave  
 8f2:	c3                   	ret    

000008f3 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 8f3:	f3 0f 1e fb          	endbr32 
 8f7:	55                   	push   %ebp
 8f8:	89 e5                	mov    %esp,%ebp
 8fa:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 8fd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 904:	8d 45 0c             	lea    0xc(%ebp),%eax
 907:	83 c0 04             	add    $0x4,%eax
 90a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 90d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 914:	e9 59 01 00 00       	jmp    a72 <printf+0x17f>
    c = fmt[i] & 0xff;
 919:	8b 55 0c             	mov    0xc(%ebp),%edx
 91c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 91f:	01 d0                	add    %edx,%eax
 921:	0f b6 00             	movzbl (%eax),%eax
 924:	0f be c0             	movsbl %al,%eax
 927:	25 ff 00 00 00       	and    $0xff,%eax
 92c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 92f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 933:	75 2c                	jne    961 <printf+0x6e>
      if(c == '%'){
 935:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 939:	75 0c                	jne    947 <printf+0x54>
        state = '%';
 93b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 942:	e9 27 01 00 00       	jmp    a6e <printf+0x17b>
      } else {
        putc(fd, c);
 947:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 94a:	0f be c0             	movsbl %al,%eax
 94d:	83 ec 08             	sub    $0x8,%esp
 950:	50                   	push   %eax
 951:	ff 75 08             	pushl  0x8(%ebp)
 954:	e8 be fe ff ff       	call   817 <putc>
 959:	83 c4 10             	add    $0x10,%esp
 95c:	e9 0d 01 00 00       	jmp    a6e <printf+0x17b>
      }
    } else if(state == '%'){
 961:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 965:	0f 85 03 01 00 00    	jne    a6e <printf+0x17b>
      if(c == 'd'){
 96b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 96f:	75 1e                	jne    98f <printf+0x9c>
        printint(fd, *ap, 10, 1);
 971:	8b 45 e8             	mov    -0x18(%ebp),%eax
 974:	8b 00                	mov    (%eax),%eax
 976:	6a 01                	push   $0x1
 978:	6a 0a                	push   $0xa
 97a:	50                   	push   %eax
 97b:	ff 75 08             	pushl  0x8(%ebp)
 97e:	e8 bb fe ff ff       	call   83e <printint>
 983:	83 c4 10             	add    $0x10,%esp
        ap++;
 986:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 98a:	e9 d8 00 00 00       	jmp    a67 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 98f:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 993:	74 06                	je     99b <printf+0xa8>
 995:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 999:	75 1e                	jne    9b9 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 99b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 99e:	8b 00                	mov    (%eax),%eax
 9a0:	6a 00                	push   $0x0
 9a2:	6a 10                	push   $0x10
 9a4:	50                   	push   %eax
 9a5:	ff 75 08             	pushl  0x8(%ebp)
 9a8:	e8 91 fe ff ff       	call   83e <printint>
 9ad:	83 c4 10             	add    $0x10,%esp
        ap++;
 9b0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9b4:	e9 ae 00 00 00       	jmp    a67 <printf+0x174>
      } else if(c == 's'){
 9b9:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 9bd:	75 43                	jne    a02 <printf+0x10f>
        s = (char*)*ap;
 9bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9c2:	8b 00                	mov    (%eax),%eax
 9c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 9c7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 9cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9cf:	75 25                	jne    9f6 <printf+0x103>
          s = "(null)";
 9d1:	c7 45 f4 5f 0e 00 00 	movl   $0xe5f,-0xc(%ebp)
        while(*s != 0){
 9d8:	eb 1c                	jmp    9f6 <printf+0x103>
          putc(fd, *s);
 9da:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9dd:	0f b6 00             	movzbl (%eax),%eax
 9e0:	0f be c0             	movsbl %al,%eax
 9e3:	83 ec 08             	sub    $0x8,%esp
 9e6:	50                   	push   %eax
 9e7:	ff 75 08             	pushl  0x8(%ebp)
 9ea:	e8 28 fe ff ff       	call   817 <putc>
 9ef:	83 c4 10             	add    $0x10,%esp
          s++;
 9f2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 9f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f9:	0f b6 00             	movzbl (%eax),%eax
 9fc:	84 c0                	test   %al,%al
 9fe:	75 da                	jne    9da <printf+0xe7>
 a00:	eb 65                	jmp    a67 <printf+0x174>
        }
      } else if(c == 'c'){
 a02:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 a06:	75 1d                	jne    a25 <printf+0x132>
        putc(fd, *ap);
 a08:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a0b:	8b 00                	mov    (%eax),%eax
 a0d:	0f be c0             	movsbl %al,%eax
 a10:	83 ec 08             	sub    $0x8,%esp
 a13:	50                   	push   %eax
 a14:	ff 75 08             	pushl  0x8(%ebp)
 a17:	e8 fb fd ff ff       	call   817 <putc>
 a1c:	83 c4 10             	add    $0x10,%esp
        ap++;
 a1f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a23:	eb 42                	jmp    a67 <printf+0x174>
      } else if(c == '%'){
 a25:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 a29:	75 17                	jne    a42 <printf+0x14f>
        putc(fd, c);
 a2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a2e:	0f be c0             	movsbl %al,%eax
 a31:	83 ec 08             	sub    $0x8,%esp
 a34:	50                   	push   %eax
 a35:	ff 75 08             	pushl  0x8(%ebp)
 a38:	e8 da fd ff ff       	call   817 <putc>
 a3d:	83 c4 10             	add    $0x10,%esp
 a40:	eb 25                	jmp    a67 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 a42:	83 ec 08             	sub    $0x8,%esp
 a45:	6a 25                	push   $0x25
 a47:	ff 75 08             	pushl  0x8(%ebp)
 a4a:	e8 c8 fd ff ff       	call   817 <putc>
 a4f:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 a52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a55:	0f be c0             	movsbl %al,%eax
 a58:	83 ec 08             	sub    $0x8,%esp
 a5b:	50                   	push   %eax
 a5c:	ff 75 08             	pushl  0x8(%ebp)
 a5f:	e8 b3 fd ff ff       	call   817 <putc>
 a64:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 a67:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 a6e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 a72:	8b 55 0c             	mov    0xc(%ebp),%edx
 a75:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a78:	01 d0                	add    %edx,%eax
 a7a:	0f b6 00             	movzbl (%eax),%eax
 a7d:	84 c0                	test   %al,%al
 a7f:	0f 85 94 fe ff ff    	jne    919 <printf+0x26>
    }
  }
}
 a85:	90                   	nop
 a86:	90                   	nop
 a87:	c9                   	leave  
 a88:	c3                   	ret    

00000a89 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a89:	f3 0f 1e fb          	endbr32 
 a8d:	55                   	push   %ebp
 a8e:	89 e5                	mov    %esp,%ebp
 a90:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a93:	8b 45 08             	mov    0x8(%ebp),%eax
 a96:	83 e8 08             	sub    $0x8,%eax
 a99:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a9c:	a1 10 11 00 00       	mov    0x1110,%eax
 aa1:	89 45 fc             	mov    %eax,-0x4(%ebp)
 aa4:	eb 24                	jmp    aca <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 aa6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aa9:	8b 00                	mov    (%eax),%eax
 aab:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 aae:	72 12                	jb     ac2 <free+0x39>
 ab0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ab3:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 ab6:	77 24                	ja     adc <free+0x53>
 ab8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 abb:	8b 00                	mov    (%eax),%eax
 abd:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 ac0:	72 1a                	jb     adc <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ac2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ac5:	8b 00                	mov    (%eax),%eax
 ac7:	89 45 fc             	mov    %eax,-0x4(%ebp)
 aca:	8b 45 f8             	mov    -0x8(%ebp),%eax
 acd:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 ad0:	76 d4                	jbe    aa6 <free+0x1d>
 ad2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ad5:	8b 00                	mov    (%eax),%eax
 ad7:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 ada:	73 ca                	jae    aa6 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 adc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 adf:	8b 40 04             	mov    0x4(%eax),%eax
 ae2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 ae9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 aec:	01 c2                	add    %eax,%edx
 aee:	8b 45 fc             	mov    -0x4(%ebp),%eax
 af1:	8b 00                	mov    (%eax),%eax
 af3:	39 c2                	cmp    %eax,%edx
 af5:	75 24                	jne    b1b <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 af7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 afa:	8b 50 04             	mov    0x4(%eax),%edx
 afd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b00:	8b 00                	mov    (%eax),%eax
 b02:	8b 40 04             	mov    0x4(%eax),%eax
 b05:	01 c2                	add    %eax,%edx
 b07:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b0a:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 b0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b10:	8b 00                	mov    (%eax),%eax
 b12:	8b 10                	mov    (%eax),%edx
 b14:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b17:	89 10                	mov    %edx,(%eax)
 b19:	eb 0a                	jmp    b25 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 b1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b1e:	8b 10                	mov    (%eax),%edx
 b20:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b23:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 b25:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b28:	8b 40 04             	mov    0x4(%eax),%eax
 b2b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b32:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b35:	01 d0                	add    %edx,%eax
 b37:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 b3a:	75 20                	jne    b5c <free+0xd3>
    p->s.size += bp->s.size;
 b3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b3f:	8b 50 04             	mov    0x4(%eax),%edx
 b42:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b45:	8b 40 04             	mov    0x4(%eax),%eax
 b48:	01 c2                	add    %eax,%edx
 b4a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b4d:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 b50:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b53:	8b 10                	mov    (%eax),%edx
 b55:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b58:	89 10                	mov    %edx,(%eax)
 b5a:	eb 08                	jmp    b64 <free+0xdb>
  } else
    p->s.ptr = bp;
 b5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b5f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 b62:	89 10                	mov    %edx,(%eax)
  freep = p;
 b64:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b67:	a3 10 11 00 00       	mov    %eax,0x1110
}
 b6c:	90                   	nop
 b6d:	c9                   	leave  
 b6e:	c3                   	ret    

00000b6f <morecore>:

static Header*
morecore(uint nu)
{
 b6f:	f3 0f 1e fb          	endbr32 
 b73:	55                   	push   %ebp
 b74:	89 e5                	mov    %esp,%ebp
 b76:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 b79:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 b80:	77 07                	ja     b89 <morecore+0x1a>
    nu = 4096;
 b82:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 b89:	8b 45 08             	mov    0x8(%ebp),%eax
 b8c:	c1 e0 03             	shl    $0x3,%eax
 b8f:	83 ec 0c             	sub    $0xc,%esp
 b92:	50                   	push   %eax
 b93:	e8 4f fc ff ff       	call   7e7 <sbrk>
 b98:	83 c4 10             	add    $0x10,%esp
 b9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 b9e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 ba2:	75 07                	jne    bab <morecore+0x3c>
    return 0;
 ba4:	b8 00 00 00 00       	mov    $0x0,%eax
 ba9:	eb 26                	jmp    bd1 <morecore+0x62>
  hp = (Header*)p;
 bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 bb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bb4:	8b 55 08             	mov    0x8(%ebp),%edx
 bb7:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 bba:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bbd:	83 c0 08             	add    $0x8,%eax
 bc0:	83 ec 0c             	sub    $0xc,%esp
 bc3:	50                   	push   %eax
 bc4:	e8 c0 fe ff ff       	call   a89 <free>
 bc9:	83 c4 10             	add    $0x10,%esp
  return freep;
 bcc:	a1 10 11 00 00       	mov    0x1110,%eax
}
 bd1:	c9                   	leave  
 bd2:	c3                   	ret    

00000bd3 <malloc>:

void*
malloc(uint nbytes)
{
 bd3:	f3 0f 1e fb          	endbr32 
 bd7:	55                   	push   %ebp
 bd8:	89 e5                	mov    %esp,%ebp
 bda:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 bdd:	8b 45 08             	mov    0x8(%ebp),%eax
 be0:	83 c0 07             	add    $0x7,%eax
 be3:	c1 e8 03             	shr    $0x3,%eax
 be6:	83 c0 01             	add    $0x1,%eax
 be9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 bec:	a1 10 11 00 00       	mov    0x1110,%eax
 bf1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 bf4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 bf8:	75 23                	jne    c1d <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 bfa:	c7 45 f0 08 11 00 00 	movl   $0x1108,-0x10(%ebp)
 c01:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c04:	a3 10 11 00 00       	mov    %eax,0x1110
 c09:	a1 10 11 00 00       	mov    0x1110,%eax
 c0e:	a3 08 11 00 00       	mov    %eax,0x1108
    base.s.size = 0;
 c13:	c7 05 0c 11 00 00 00 	movl   $0x0,0x110c
 c1a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c20:	8b 00                	mov    (%eax),%eax
 c22:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c28:	8b 40 04             	mov    0x4(%eax),%eax
 c2b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 c2e:	77 4d                	ja     c7d <malloc+0xaa>
      if(p->s.size == nunits)
 c30:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c33:	8b 40 04             	mov    0x4(%eax),%eax
 c36:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 c39:	75 0c                	jne    c47 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c3e:	8b 10                	mov    (%eax),%edx
 c40:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c43:	89 10                	mov    %edx,(%eax)
 c45:	eb 26                	jmp    c6d <malloc+0x9a>
      else {
        p->s.size -= nunits;
 c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c4a:	8b 40 04             	mov    0x4(%eax),%eax
 c4d:	2b 45 ec             	sub    -0x14(%ebp),%eax
 c50:	89 c2                	mov    %eax,%edx
 c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c55:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c5b:	8b 40 04             	mov    0x4(%eax),%eax
 c5e:	c1 e0 03             	shl    $0x3,%eax
 c61:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c67:	8b 55 ec             	mov    -0x14(%ebp),%edx
 c6a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 c6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c70:	a3 10 11 00 00       	mov    %eax,0x1110
      return (void*)(p + 1);
 c75:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c78:	83 c0 08             	add    $0x8,%eax
 c7b:	eb 3b                	jmp    cb8 <malloc+0xe5>
    }
    if(p == freep)
 c7d:	a1 10 11 00 00       	mov    0x1110,%eax
 c82:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 c85:	75 1e                	jne    ca5 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 c87:	83 ec 0c             	sub    $0xc,%esp
 c8a:	ff 75 ec             	pushl  -0x14(%ebp)
 c8d:	e8 dd fe ff ff       	call   b6f <morecore>
 c92:	83 c4 10             	add    $0x10,%esp
 c95:	89 45 f4             	mov    %eax,-0xc(%ebp)
 c98:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 c9c:	75 07                	jne    ca5 <malloc+0xd2>
        return 0;
 c9e:	b8 00 00 00 00       	mov    $0x0,%eax
 ca3:	eb 13                	jmp    cb8 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ca8:	89 45 f0             	mov    %eax,-0x10(%ebp)
 cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cae:	8b 00                	mov    (%eax),%eax
 cb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 cb3:	e9 6d ff ff ff       	jmp    c25 <malloc+0x52>
  }
}
 cb8:	c9                   	leave  
 cb9:	c3                   	ret    
