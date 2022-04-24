
_test_7:     file format elf32-i386


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
  10:	68 5c 0c 00 00       	push   $0xc5c
  15:	6a 01                	push   $0x1
  17:	e8 79 08 00 00       	call   895 <printf>
  1c:	83 c4 10             	add    $0x10,%esp
    exit();
  1f:	e8 dd 06 00 00       	call   701 <exit>

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
  5d:	68 70 0c 00 00       	push   $0xc70
  62:	6a 01                	push   $0x1
  64:	e8 2c 08 00 00       	call   895 <printf>
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
  84:	83 ec 58             	sub    $0x58,%esp
    const uint PAGES_NUM = 32;
  87:	c7 45 c8 20 00 00 00 	movl   $0x20,-0x38(%ebp)
    const uint expected_dummy_pages_num = 4;
  8e:	c7 45 c4 04 00 00 00 	movl   $0x4,-0x3c(%ebp)
    // These pages are used to make sure the test result is consistent for different text pages number
    char *dummy_pages[expected_dummy_pages_num];
  95:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  98:	83 e8 01             	sub    $0x1,%eax
  9b:	89 45 c0             	mov    %eax,-0x40(%ebp)
  9e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
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
 111:	89 45 bc             	mov    %eax,-0x44(%ebp)
    char *buffer = sbrk(PGSIZE * sizeof(char));
 114:	83 ec 0c             	sub    $0xc,%esp
 117:	68 00 10 00 00       	push   $0x1000
 11c:	e8 68 06 00 00       	call   789 <sbrk>
 121:	83 c4 10             	add    $0x10,%esp
 124:	89 45 b8             	mov    %eax,-0x48(%ebp)
    char *sp = buffer - PGSIZE;
 127:	8b 45 b8             	mov    -0x48(%ebp),%eax
 12a:	2d 00 10 00 00       	sub    $0x1000,%eax
 12f:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    char *boundary = buffer - 2 * PGSIZE;
 132:	8b 45 b8             	mov    -0x48(%ebp),%eax
 135:	2d 00 20 00 00       	sub    $0x2000,%eax
 13a:	89 45 b0             	mov    %eax,-0x50(%ebp)
    struct pt_entry pt_entries[PAGES_NUM];
 13d:	8b 45 c8             	mov    -0x38(%ebp),%eax
 140:	83 e8 01             	sub    $0x1,%eax
 143:	89 45 ac             	mov    %eax,-0x54(%ebp)
 146:	8b 45 c8             	mov    -0x38(%ebp),%eax
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
 1b9:	89 45 a8             	mov    %eax,-0x58(%ebp)

    uint text_pages = (uint) boundary / PGSIZE;
 1bc:	8b 45 b0             	mov    -0x50(%ebp),%eax
 1bf:	c1 e8 0c             	shr    $0xc,%eax
 1c2:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    if (text_pages > expected_dummy_pages_num - 1)
 1c5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 1c8:	83 e8 01             	sub    $0x1,%eax
 1cb:	39 45 a4             	cmp    %eax,-0x5c(%ebp)
 1ce:	76 10                	jbe    1e0 <main+0x171>
        err("XV6_TEST_OUTPUT: program size exceeds the maximum allowed size. Please let us know if this case happens\n");
 1d0:	83 ec 0c             	sub    $0xc,%esp
 1d3:	68 74 0c 00 00       	push   $0xc74
 1d8:	e8 23 fe ff ff       	call   0 <err>
 1dd:	83 c4 10             	add    $0x10,%esp
    
    for (int i = 0; i < text_pages; i++)
 1e0:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
 1e7:	eb 15                	jmp    1fe <main+0x18f>
        dummy_pages[i] = (char *)(i * PGSIZE);
 1e9:	8b 45 cc             	mov    -0x34(%ebp),%eax
 1ec:	c1 e0 0c             	shl    $0xc,%eax
 1ef:	89 c1                	mov    %eax,%ecx
 1f1:	8b 45 bc             	mov    -0x44(%ebp),%eax
 1f4:	8b 55 cc             	mov    -0x34(%ebp),%edx
 1f7:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    for (int i = 0; i < text_pages; i++)
 1fa:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
 1fe:	8b 45 cc             	mov    -0x34(%ebp),%eax
 201:	39 45 a4             	cmp    %eax,-0x5c(%ebp)
 204:	77 e3                	ja     1e9 <main+0x17a>
    dummy_pages[text_pages] = sp;
 206:	8b 45 bc             	mov    -0x44(%ebp),%eax
 209:	8b 55 a4             	mov    -0x5c(%ebp),%edx
 20c:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
 20f:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    for (int i = text_pages + 1; i < expected_dummy_pages_num; i++)
 212:	8b 45 a4             	mov    -0x5c(%ebp),%eax
 215:	83 c0 01             	add    $0x1,%eax
 218:	89 45 d0             	mov    %eax,-0x30(%ebp)
 21b:	eb 1d                	jmp    23a <main+0x1cb>
        dummy_pages[i] = sbrk(PGSIZE * sizeof(char));
 21d:	83 ec 0c             	sub    $0xc,%esp
 220:	68 00 10 00 00       	push   $0x1000
 225:	e8 5f 05 00 00       	call   789 <sbrk>
 22a:	83 c4 10             	add    $0x10,%esp
 22d:	8b 55 bc             	mov    -0x44(%ebp),%edx
 230:	8b 4d d0             	mov    -0x30(%ebp),%ecx
 233:	89 04 8a             	mov    %eax,(%edx,%ecx,4)
    for (int i = text_pages + 1; i < expected_dummy_pages_num; i++)
 236:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
 23a:	8b 45 d0             	mov    -0x30(%ebp),%eax
 23d:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
 240:	77 db                	ja     21d <main+0x1ae>
    

    // After this call, all the dummy pages including text pages and stack pages
    // should be resident in the clock queue.
    access_all_dummy_pages(dummy_pages, expected_dummy_pages_num);
 242:	83 ec 08             	sub    $0x8,%esp
 245:	ff 75 c4             	pushl  -0x3c(%ebp)
 248:	ff 75 bc             	pushl  -0x44(%ebp)
 24b:	e8 d4 fd ff ff       	call   24 <access_all_dummy_pages>
 250:	83 c4 10             	add    $0x10,%esp

    // Bring the buffer page into the clock queue
    buffer[0] = buffer[0];
 253:	8b 45 b8             	mov    -0x48(%ebp),%eax
 256:	0f b6 10             	movzbl (%eax),%edx
 259:	8b 45 b8             	mov    -0x48(%ebp),%eax
 25c:	88 10                	mov    %dl,(%eax)

    // Now we should have expected_dummy_pages_num + 1 (buffer) pages in the clock queue
    // Fill up the remainig slot with heap-allocated page
    // and bring all of them into the clock queue
    int heap_pages_num = CLOCKSIZE - expected_dummy_pages_num - 1;
 25e:	b8 07 00 00 00       	mov    $0x7,%eax
 263:	2b 45 c4             	sub    -0x3c(%ebp),%eax
 266:	89 45 a0             	mov    %eax,-0x60(%ebp)
    char *ptr = sbrk(heap_pages_num * PGSIZE * sizeof(char));
 269:	8b 45 a0             	mov    -0x60(%ebp),%eax
 26c:	c1 e0 0c             	shl    $0xc,%eax
 26f:	83 ec 0c             	sub    $0xc,%esp
 272:	50                   	push   %eax
 273:	e8 11 05 00 00       	call   789 <sbrk>
 278:	83 c4 10             	add    $0x10,%esp
 27b:	89 45 9c             	mov    %eax,-0x64(%ebp)
    for (int i = 0; i < heap_pages_num; i++) {
 27e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 285:	eb 31                	jmp    2b8 <main+0x249>
      for (int j = 0; j < PGSIZE; j++) {
 287:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
 28e:	eb 1b                	jmp    2ab <main+0x23c>
        ptr[i * PGSIZE + j] = 0xAA;
 290:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 293:	c1 e0 0c             	shl    $0xc,%eax
 296:	89 c2                	mov    %eax,%edx
 298:	8b 45 d8             	mov    -0x28(%ebp),%eax
 29b:	01 d0                	add    %edx,%eax
 29d:	89 c2                	mov    %eax,%edx
 29f:	8b 45 9c             	mov    -0x64(%ebp),%eax
 2a2:	01 d0                	add    %edx,%eax
 2a4:	c6 00 aa             	movb   $0xaa,(%eax)
      for (int j = 0; j < PGSIZE; j++) {
 2a7:	83 45 d8 01          	addl   $0x1,-0x28(%ebp)
 2ab:	81 7d d8 ff 0f 00 00 	cmpl   $0xfff,-0x28(%ebp)
 2b2:	7e dc                	jle    290 <main+0x221>
    for (int i = 0; i < heap_pages_num; i++) {
 2b4:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
 2b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 2bb:	3b 45 a0             	cmp    -0x60(%ebp),%eax
 2be:	7c c7                	jl     287 <main+0x218>
      }
    }
    
    int retval = getpgtable(pt_entries, heap_pages_num, 0);
 2c0:	83 ec 04             	sub    $0x4,%esp
 2c3:	6a 00                	push   $0x0
 2c5:	ff 75 a0             	pushl  -0x60(%ebp)
 2c8:	ff 75 a8             	pushl  -0x58(%ebp)
 2cb:	e8 d9 04 00 00       	call   7a9 <getpgtable>
 2d0:	83 c4 10             	add    $0x10,%esp
 2d3:	89 45 98             	mov    %eax,-0x68(%ebp)
    //printf("=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~ retval is: %d\n",retval);
    printf(1,"trying my best here yuvraj\n");
 2d6:	83 ec 08             	sub    $0x8,%esp
 2d9:	68 dd 0c 00 00       	push   $0xcdd
 2de:	6a 01                	push   $0x1
 2e0:	e8 b0 05 00 00       	call   895 <printf>
 2e5:	83 c4 10             	add    $0x10,%esp
    if (retval == heap_pages_num) {
 2e8:	8b 45 98             	mov    -0x68(%ebp),%eax
 2eb:	3b 45 a0             	cmp    -0x60(%ebp),%eax
 2ee:	0f 85 78 01 00 00    	jne    46c <main+0x3fd>
      for (int i = 0; i < retval; i++) {
 2f4:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
 2fb:	e9 5e 01 00 00       	jmp    45e <main+0x3ef>
              i,
              pt_entries[i].pdx,
              pt_entries[i].ptx,
              pt_entries[i].writable,
              pt_entries[i].encrypted,
              pt_entries[i].ref
 300:	8b 45 a8             	mov    -0x58(%ebp),%eax
 303:	8b 55 dc             	mov    -0x24(%ebp),%edx
 306:	0f b6 44 d0 07       	movzbl 0x7(%eax,%edx,8),%eax
 30b:	83 e0 01             	and    $0x1,%eax
          printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, writable bit: %d, encrypted: %d, ref: %d\n", 
 30e:	0f b6 f0             	movzbl %al,%esi
              pt_entries[i].encrypted,
 311:	8b 45 a8             	mov    -0x58(%ebp),%eax
 314:	8b 55 dc             	mov    -0x24(%ebp),%edx
 317:	0f b6 44 d0 06       	movzbl 0x6(%eax,%edx,8),%eax
 31c:	c0 e8 07             	shr    $0x7,%al
          printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, writable bit: %d, encrypted: %d, ref: %d\n", 
 31f:	0f b6 d8             	movzbl %al,%ebx
              pt_entries[i].writable,
 322:	8b 45 a8             	mov    -0x58(%ebp),%eax
 325:	8b 55 dc             	mov    -0x24(%ebp),%edx
 328:	0f b6 44 d0 06       	movzbl 0x6(%eax,%edx,8),%eax
 32d:	c0 e8 05             	shr    $0x5,%al
 330:	83 e0 01             	and    $0x1,%eax
          printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, writable bit: %d, encrypted: %d, ref: %d\n", 
 333:	0f b6 c8             	movzbl %al,%ecx
              pt_entries[i].ptx,
 336:	8b 45 a8             	mov    -0x58(%ebp),%eax
 339:	8b 55 dc             	mov    -0x24(%ebp),%edx
 33c:	8b 04 d0             	mov    (%eax,%edx,8),%eax
 33f:	c1 e8 0a             	shr    $0xa,%eax
 342:	66 25 ff 03          	and    $0x3ff,%ax
          printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, writable bit: %d, encrypted: %d, ref: %d\n", 
 346:	0f b7 d0             	movzwl %ax,%edx
              pt_entries[i].pdx,
 349:	8b 45 a8             	mov    -0x58(%ebp),%eax
 34c:	8b 7d dc             	mov    -0x24(%ebp),%edi
 34f:	0f b7 04 f8          	movzwl (%eax,%edi,8),%eax
 353:	66 25 ff 03          	and    $0x3ff,%ax
          printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, writable bit: %d, encrypted: %d, ref: %d\n", 
 357:	0f b7 c0             	movzwl %ax,%eax
 35a:	56                   	push   %esi
 35b:	53                   	push   %ebx
 35c:	51                   	push   %ecx
 35d:	52                   	push   %edx
 35e:	50                   	push   %eax
 35f:	ff 75 dc             	pushl  -0x24(%ebp)
 362:	68 fc 0c 00 00       	push   $0xcfc
 367:	6a 01                	push   $0x1
 369:	e8 27 05 00 00       	call   895 <printf>
 36e:	83 c4 20             	add    $0x20,%esp
          ); 
          
          uint expected = 0xAA;
 371:	c7 45 e0 aa 00 00 00 	movl   $0xaa,-0x20(%ebp)
          if (pt_entries[i].encrypted)
 378:	8b 45 a8             	mov    -0x58(%ebp),%eax
 37b:	8b 55 dc             	mov    -0x24(%ebp),%edx
 37e:	0f b6 44 d0 06       	movzbl 0x6(%eax,%edx,8),%eax
 383:	c0 e8 07             	shr    $0x7,%al
 386:	84 c0                	test   %al,%al
 388:	74 07                	je     391 <main+0x322>
            expected = ~0xAA;
 38a:	c7 45 e0 55 ff ff ff 	movl   $0xffffff55,-0x20(%ebp)

          if (dump_rawphymem(pt_entries[i].ppage * PGSIZE, buffer) != 0)
 391:	8b 45 a8             	mov    -0x58(%ebp),%eax
 394:	8b 55 dc             	mov    -0x24(%ebp),%edx
 397:	8b 44 d0 04          	mov    0x4(%eax,%edx,8),%eax
 39b:	25 ff ff 0f 00       	and    $0xfffff,%eax
 3a0:	c1 e0 0c             	shl    $0xc,%eax
 3a3:	83 ec 08             	sub    $0x8,%esp
 3a6:	ff 75 b8             	pushl  -0x48(%ebp)
 3a9:	50                   	push   %eax
 3aa:	e8 02 04 00 00       	call   7b1 <dump_rawphymem>
 3af:	83 c4 10             	add    $0x10,%esp
 3b2:	85 c0                	test   %eax,%eax
 3b4:	74 10                	je     3c6 <main+0x357>
              err("dump_rawphymem return non-zero value\n");
 3b6:	83 ec 0c             	sub    $0xc,%esp
 3b9:	68 58 0d 00 00       	push   $0xd58
 3be:	e8 3d fc ff ff       	call   0 <err>
 3c3:	83 c4 10             	add    $0x10,%esp
          
          for (int j = 0; j < PGSIZE; j++) {
 3c6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 3cd:	eb 7e                	jmp    44d <main+0x3de>
              if (buffer[j] != (char)expected) {
 3cf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 3d2:	8b 45 b8             	mov    -0x48(%ebp),%eax
 3d5:	01 d0                	add    %edx,%eax
 3d7:	0f b6 00             	movzbl (%eax),%eax
 3da:	8b 55 e0             	mov    -0x20(%ebp),%edx
 3dd:	38 d0                	cmp    %dl,%al
 3df:	74 68                	je     449 <main+0x3da>
                  // err("physical memory is dumped incorrectly\n");
                    printf(1, "XV6_TEST_OUTPUT: content is incorrect at address 0x%x: expected 0x%x, got 0x%x\n", ((uint)(pt_entries[i].pdx) << 22 | (pt_entries[i].ptx) << 12) + j ,expected & 0xFF, buffer[j] & 0xFF);
 3e1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 3e4:	8b 45 b8             	mov    -0x48(%ebp),%eax
 3e7:	01 d0                	add    %edx,%eax
 3e9:	0f b6 00             	movzbl (%eax),%eax
 3ec:	0f be c0             	movsbl %al,%eax
 3ef:	0f b6 d0             	movzbl %al,%edx
 3f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
 3f5:	0f b6 c0             	movzbl %al,%eax
 3f8:	8b 4d a8             	mov    -0x58(%ebp),%ecx
 3fb:	8b 5d dc             	mov    -0x24(%ebp),%ebx
 3fe:	0f b7 0c d9          	movzwl (%ecx,%ebx,8),%ecx
 402:	66 81 e1 ff 03       	and    $0x3ff,%cx
 407:	0f b7 c9             	movzwl %cx,%ecx
 40a:	89 ce                	mov    %ecx,%esi
 40c:	c1 e6 16             	shl    $0x16,%esi
 40f:	8b 4d a8             	mov    -0x58(%ebp),%ecx
 412:	8b 5d dc             	mov    -0x24(%ebp),%ebx
 415:	8b 0c d9             	mov    (%ecx,%ebx,8),%ecx
 418:	c1 e9 0a             	shr    $0xa,%ecx
 41b:	66 81 e1 ff 03       	and    $0x3ff,%cx
 420:	0f b7 c9             	movzwl %cx,%ecx
 423:	c1 e1 0c             	shl    $0xc,%ecx
 426:	89 f3                	mov    %esi,%ebx
 428:	09 cb                	or     %ecx,%ebx
 42a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
 42d:	01 d9                	add    %ebx,%ecx
 42f:	83 ec 0c             	sub    $0xc,%esp
 432:	52                   	push   %edx
 433:	50                   	push   %eax
 434:	51                   	push   %ecx
 435:	68 80 0d 00 00       	push   $0xd80
 43a:	6a 01                	push   $0x1
 43c:	e8 54 04 00 00       	call   895 <printf>
 441:	83 c4 20             	add    $0x20,%esp
                    exit();
 444:	e8 b8 02 00 00       	call   701 <exit>
          for (int j = 0; j < PGSIZE; j++) {
 449:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
 44d:	81 7d e4 ff 0f 00 00 	cmpl   $0xfff,-0x1c(%ebp)
 454:	0f 8e 75 ff ff ff    	jle    3cf <main+0x360>
      for (int i = 0; i < retval; i++) {
 45a:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
 45e:	8b 45 dc             	mov    -0x24(%ebp),%eax
 461:	3b 45 98             	cmp    -0x68(%ebp),%eax
 464:	0f 8c 96 fe ff ff    	jl     300 <main+0x291>
 46a:	eb 15                	jmp    481 <main+0x412>
              }
          }

      }
    } else
        printf(1, "XV6_TEST_OUTPUT: getpgtable returned incorrect value: expected %d, got %d\n", heap_pages_num, retval);
 46c:	ff 75 98             	pushl  -0x68(%ebp)
 46f:	ff 75 a0             	pushl  -0x60(%ebp)
 472:	68 d0 0d 00 00       	push   $0xdd0
 477:	6a 01                	push   $0x1
 479:	e8 17 04 00 00       	call   895 <printf>
 47e:	83 c4 10             	add    $0x10,%esp
    
    exit();
 481:	e8 7b 02 00 00       	call   701 <exit>

00000486 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 486:	55                   	push   %ebp
 487:	89 e5                	mov    %esp,%ebp
 489:	57                   	push   %edi
 48a:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 48b:	8b 4d 08             	mov    0x8(%ebp),%ecx
 48e:	8b 55 10             	mov    0x10(%ebp),%edx
 491:	8b 45 0c             	mov    0xc(%ebp),%eax
 494:	89 cb                	mov    %ecx,%ebx
 496:	89 df                	mov    %ebx,%edi
 498:	89 d1                	mov    %edx,%ecx
 49a:	fc                   	cld    
 49b:	f3 aa                	rep stos %al,%es:(%edi)
 49d:	89 ca                	mov    %ecx,%edx
 49f:	89 fb                	mov    %edi,%ebx
 4a1:	89 5d 08             	mov    %ebx,0x8(%ebp)
 4a4:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 4a7:	90                   	nop
 4a8:	5b                   	pop    %ebx
 4a9:	5f                   	pop    %edi
 4aa:	5d                   	pop    %ebp
 4ab:	c3                   	ret    

000004ac <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 4ac:	f3 0f 1e fb          	endbr32 
 4b0:	55                   	push   %ebp
 4b1:	89 e5                	mov    %esp,%ebp
 4b3:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 4b6:	8b 45 08             	mov    0x8(%ebp),%eax
 4b9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 4bc:	90                   	nop
 4bd:	8b 55 0c             	mov    0xc(%ebp),%edx
 4c0:	8d 42 01             	lea    0x1(%edx),%eax
 4c3:	89 45 0c             	mov    %eax,0xc(%ebp)
 4c6:	8b 45 08             	mov    0x8(%ebp),%eax
 4c9:	8d 48 01             	lea    0x1(%eax),%ecx
 4cc:	89 4d 08             	mov    %ecx,0x8(%ebp)
 4cf:	0f b6 12             	movzbl (%edx),%edx
 4d2:	88 10                	mov    %dl,(%eax)
 4d4:	0f b6 00             	movzbl (%eax),%eax
 4d7:	84 c0                	test   %al,%al
 4d9:	75 e2                	jne    4bd <strcpy+0x11>
    ;
  return os;
 4db:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4de:	c9                   	leave  
 4df:	c3                   	ret    

000004e0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 4e0:	f3 0f 1e fb          	endbr32 
 4e4:	55                   	push   %ebp
 4e5:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 4e7:	eb 08                	jmp    4f1 <strcmp+0x11>
    p++, q++;
 4e9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4ed:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 4f1:	8b 45 08             	mov    0x8(%ebp),%eax
 4f4:	0f b6 00             	movzbl (%eax),%eax
 4f7:	84 c0                	test   %al,%al
 4f9:	74 10                	je     50b <strcmp+0x2b>
 4fb:	8b 45 08             	mov    0x8(%ebp),%eax
 4fe:	0f b6 10             	movzbl (%eax),%edx
 501:	8b 45 0c             	mov    0xc(%ebp),%eax
 504:	0f b6 00             	movzbl (%eax),%eax
 507:	38 c2                	cmp    %al,%dl
 509:	74 de                	je     4e9 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 50b:	8b 45 08             	mov    0x8(%ebp),%eax
 50e:	0f b6 00             	movzbl (%eax),%eax
 511:	0f b6 d0             	movzbl %al,%edx
 514:	8b 45 0c             	mov    0xc(%ebp),%eax
 517:	0f b6 00             	movzbl (%eax),%eax
 51a:	0f b6 c0             	movzbl %al,%eax
 51d:	29 c2                	sub    %eax,%edx
 51f:	89 d0                	mov    %edx,%eax
}
 521:	5d                   	pop    %ebp
 522:	c3                   	ret    

00000523 <strlen>:

uint
strlen(const char *s)
{
 523:	f3 0f 1e fb          	endbr32 
 527:	55                   	push   %ebp
 528:	89 e5                	mov    %esp,%ebp
 52a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 52d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 534:	eb 04                	jmp    53a <strlen+0x17>
 536:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 53a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 53d:	8b 45 08             	mov    0x8(%ebp),%eax
 540:	01 d0                	add    %edx,%eax
 542:	0f b6 00             	movzbl (%eax),%eax
 545:	84 c0                	test   %al,%al
 547:	75 ed                	jne    536 <strlen+0x13>
    ;
  return n;
 549:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 54c:	c9                   	leave  
 54d:	c3                   	ret    

0000054e <memset>:

void*
memset(void *dst, int c, uint n)
{
 54e:	f3 0f 1e fb          	endbr32 
 552:	55                   	push   %ebp
 553:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 555:	8b 45 10             	mov    0x10(%ebp),%eax
 558:	50                   	push   %eax
 559:	ff 75 0c             	pushl  0xc(%ebp)
 55c:	ff 75 08             	pushl  0x8(%ebp)
 55f:	e8 22 ff ff ff       	call   486 <stosb>
 564:	83 c4 0c             	add    $0xc,%esp
  return dst;
 567:	8b 45 08             	mov    0x8(%ebp),%eax
}
 56a:	c9                   	leave  
 56b:	c3                   	ret    

0000056c <strchr>:

char*
strchr(const char *s, char c)
{
 56c:	f3 0f 1e fb          	endbr32 
 570:	55                   	push   %ebp
 571:	89 e5                	mov    %esp,%ebp
 573:	83 ec 04             	sub    $0x4,%esp
 576:	8b 45 0c             	mov    0xc(%ebp),%eax
 579:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 57c:	eb 14                	jmp    592 <strchr+0x26>
    if(*s == c)
 57e:	8b 45 08             	mov    0x8(%ebp),%eax
 581:	0f b6 00             	movzbl (%eax),%eax
 584:	38 45 fc             	cmp    %al,-0x4(%ebp)
 587:	75 05                	jne    58e <strchr+0x22>
      return (char*)s;
 589:	8b 45 08             	mov    0x8(%ebp),%eax
 58c:	eb 13                	jmp    5a1 <strchr+0x35>
  for(; *s; s++)
 58e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 592:	8b 45 08             	mov    0x8(%ebp),%eax
 595:	0f b6 00             	movzbl (%eax),%eax
 598:	84 c0                	test   %al,%al
 59a:	75 e2                	jne    57e <strchr+0x12>
  return 0;
 59c:	b8 00 00 00 00       	mov    $0x0,%eax
}
 5a1:	c9                   	leave  
 5a2:	c3                   	ret    

000005a3 <gets>:

char*
gets(char *buf, int max)
{
 5a3:	f3 0f 1e fb          	endbr32 
 5a7:	55                   	push   %ebp
 5a8:	89 e5                	mov    %esp,%ebp
 5aa:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 5ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 5b4:	eb 42                	jmp    5f8 <gets+0x55>
    cc = read(0, &c, 1);
 5b6:	83 ec 04             	sub    $0x4,%esp
 5b9:	6a 01                	push   $0x1
 5bb:	8d 45 ef             	lea    -0x11(%ebp),%eax
 5be:	50                   	push   %eax
 5bf:	6a 00                	push   $0x0
 5c1:	e8 53 01 00 00       	call   719 <read>
 5c6:	83 c4 10             	add    $0x10,%esp
 5c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 5cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5d0:	7e 33                	jle    605 <gets+0x62>
      break;
    buf[i++] = c;
 5d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5d5:	8d 50 01             	lea    0x1(%eax),%edx
 5d8:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5db:	89 c2                	mov    %eax,%edx
 5dd:	8b 45 08             	mov    0x8(%ebp),%eax
 5e0:	01 c2                	add    %eax,%edx
 5e2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5e6:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 5e8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5ec:	3c 0a                	cmp    $0xa,%al
 5ee:	74 16                	je     606 <gets+0x63>
 5f0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5f4:	3c 0d                	cmp    $0xd,%al
 5f6:	74 0e                	je     606 <gets+0x63>
  for(i=0; i+1 < max; ){
 5f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5fb:	83 c0 01             	add    $0x1,%eax
 5fe:	39 45 0c             	cmp    %eax,0xc(%ebp)
 601:	7f b3                	jg     5b6 <gets+0x13>
 603:	eb 01                	jmp    606 <gets+0x63>
      break;
 605:	90                   	nop
      break;
  }
  buf[i] = '\0';
 606:	8b 55 f4             	mov    -0xc(%ebp),%edx
 609:	8b 45 08             	mov    0x8(%ebp),%eax
 60c:	01 d0                	add    %edx,%eax
 60e:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 611:	8b 45 08             	mov    0x8(%ebp),%eax
}
 614:	c9                   	leave  
 615:	c3                   	ret    

00000616 <stat>:

int
stat(const char *n, struct stat *st)
{
 616:	f3 0f 1e fb          	endbr32 
 61a:	55                   	push   %ebp
 61b:	89 e5                	mov    %esp,%ebp
 61d:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 620:	83 ec 08             	sub    $0x8,%esp
 623:	6a 00                	push   $0x0
 625:	ff 75 08             	pushl  0x8(%ebp)
 628:	e8 14 01 00 00       	call   741 <open>
 62d:	83 c4 10             	add    $0x10,%esp
 630:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 633:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 637:	79 07                	jns    640 <stat+0x2a>
    return -1;
 639:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 63e:	eb 25                	jmp    665 <stat+0x4f>
  r = fstat(fd, st);
 640:	83 ec 08             	sub    $0x8,%esp
 643:	ff 75 0c             	pushl  0xc(%ebp)
 646:	ff 75 f4             	pushl  -0xc(%ebp)
 649:	e8 0b 01 00 00       	call   759 <fstat>
 64e:	83 c4 10             	add    $0x10,%esp
 651:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 654:	83 ec 0c             	sub    $0xc,%esp
 657:	ff 75 f4             	pushl  -0xc(%ebp)
 65a:	e8 ca 00 00 00       	call   729 <close>
 65f:	83 c4 10             	add    $0x10,%esp
  return r;
 662:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 665:	c9                   	leave  
 666:	c3                   	ret    

00000667 <atoi>:

int
atoi(const char *s)
{
 667:	f3 0f 1e fb          	endbr32 
 66b:	55                   	push   %ebp
 66c:	89 e5                	mov    %esp,%ebp
 66e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 671:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 678:	eb 25                	jmp    69f <atoi+0x38>
    n = n*10 + *s++ - '0';
 67a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 67d:	89 d0                	mov    %edx,%eax
 67f:	c1 e0 02             	shl    $0x2,%eax
 682:	01 d0                	add    %edx,%eax
 684:	01 c0                	add    %eax,%eax
 686:	89 c1                	mov    %eax,%ecx
 688:	8b 45 08             	mov    0x8(%ebp),%eax
 68b:	8d 50 01             	lea    0x1(%eax),%edx
 68e:	89 55 08             	mov    %edx,0x8(%ebp)
 691:	0f b6 00             	movzbl (%eax),%eax
 694:	0f be c0             	movsbl %al,%eax
 697:	01 c8                	add    %ecx,%eax
 699:	83 e8 30             	sub    $0x30,%eax
 69c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 69f:	8b 45 08             	mov    0x8(%ebp),%eax
 6a2:	0f b6 00             	movzbl (%eax),%eax
 6a5:	3c 2f                	cmp    $0x2f,%al
 6a7:	7e 0a                	jle    6b3 <atoi+0x4c>
 6a9:	8b 45 08             	mov    0x8(%ebp),%eax
 6ac:	0f b6 00             	movzbl (%eax),%eax
 6af:	3c 39                	cmp    $0x39,%al
 6b1:	7e c7                	jle    67a <atoi+0x13>
  return n;
 6b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 6b6:	c9                   	leave  
 6b7:	c3                   	ret    

000006b8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 6b8:	f3 0f 1e fb          	endbr32 
 6bc:	55                   	push   %ebp
 6bd:	89 e5                	mov    %esp,%ebp
 6bf:	83 ec 10             	sub    $0x10,%esp
  char *dst;
  const char *src;

  dst = vdst;
 6c2:	8b 45 08             	mov    0x8(%ebp),%eax
 6c5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 6c8:	8b 45 0c             	mov    0xc(%ebp),%eax
 6cb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 6ce:	eb 17                	jmp    6e7 <memmove+0x2f>
    *dst++ = *src++;
 6d0:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6d3:	8d 42 01             	lea    0x1(%edx),%eax
 6d6:	89 45 f8             	mov    %eax,-0x8(%ebp)
 6d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6dc:	8d 48 01             	lea    0x1(%eax),%ecx
 6df:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 6e2:	0f b6 12             	movzbl (%edx),%edx
 6e5:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 6e7:	8b 45 10             	mov    0x10(%ebp),%eax
 6ea:	8d 50 ff             	lea    -0x1(%eax),%edx
 6ed:	89 55 10             	mov    %edx,0x10(%ebp)
 6f0:	85 c0                	test   %eax,%eax
 6f2:	7f dc                	jg     6d0 <memmove+0x18>
  return vdst;
 6f4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 6f7:	c9                   	leave  
 6f8:	c3                   	ret    

000006f9 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 6f9:	b8 01 00 00 00       	mov    $0x1,%eax
 6fe:	cd 40                	int    $0x40
 700:	c3                   	ret    

00000701 <exit>:
SYSCALL(exit)
 701:	b8 02 00 00 00       	mov    $0x2,%eax
 706:	cd 40                	int    $0x40
 708:	c3                   	ret    

00000709 <wait>:
SYSCALL(wait)
 709:	b8 03 00 00 00       	mov    $0x3,%eax
 70e:	cd 40                	int    $0x40
 710:	c3                   	ret    

00000711 <pipe>:
SYSCALL(pipe)
 711:	b8 04 00 00 00       	mov    $0x4,%eax
 716:	cd 40                	int    $0x40
 718:	c3                   	ret    

00000719 <read>:
SYSCALL(read)
 719:	b8 05 00 00 00       	mov    $0x5,%eax
 71e:	cd 40                	int    $0x40
 720:	c3                   	ret    

00000721 <write>:
SYSCALL(write)
 721:	b8 10 00 00 00       	mov    $0x10,%eax
 726:	cd 40                	int    $0x40
 728:	c3                   	ret    

00000729 <close>:
SYSCALL(close)
 729:	b8 15 00 00 00       	mov    $0x15,%eax
 72e:	cd 40                	int    $0x40
 730:	c3                   	ret    

00000731 <kill>:
SYSCALL(kill)
 731:	b8 06 00 00 00       	mov    $0x6,%eax
 736:	cd 40                	int    $0x40
 738:	c3                   	ret    

00000739 <exec>:
SYSCALL(exec)
 739:	b8 07 00 00 00       	mov    $0x7,%eax
 73e:	cd 40                	int    $0x40
 740:	c3                   	ret    

00000741 <open>:
SYSCALL(open)
 741:	b8 0f 00 00 00       	mov    $0xf,%eax
 746:	cd 40                	int    $0x40
 748:	c3                   	ret    

00000749 <mknod>:
SYSCALL(mknod)
 749:	b8 11 00 00 00       	mov    $0x11,%eax
 74e:	cd 40                	int    $0x40
 750:	c3                   	ret    

00000751 <unlink>:
SYSCALL(unlink)
 751:	b8 12 00 00 00       	mov    $0x12,%eax
 756:	cd 40                	int    $0x40
 758:	c3                   	ret    

00000759 <fstat>:
SYSCALL(fstat)
 759:	b8 08 00 00 00       	mov    $0x8,%eax
 75e:	cd 40                	int    $0x40
 760:	c3                   	ret    

00000761 <link>:
SYSCALL(link)
 761:	b8 13 00 00 00       	mov    $0x13,%eax
 766:	cd 40                	int    $0x40
 768:	c3                   	ret    

00000769 <mkdir>:
SYSCALL(mkdir)
 769:	b8 14 00 00 00       	mov    $0x14,%eax
 76e:	cd 40                	int    $0x40
 770:	c3                   	ret    

00000771 <chdir>:
SYSCALL(chdir)
 771:	b8 09 00 00 00       	mov    $0x9,%eax
 776:	cd 40                	int    $0x40
 778:	c3                   	ret    

00000779 <dup>:
SYSCALL(dup)
 779:	b8 0a 00 00 00       	mov    $0xa,%eax
 77e:	cd 40                	int    $0x40
 780:	c3                   	ret    

00000781 <getpid>:
SYSCALL(getpid)
 781:	b8 0b 00 00 00       	mov    $0xb,%eax
 786:	cd 40                	int    $0x40
 788:	c3                   	ret    

00000789 <sbrk>:
SYSCALL(sbrk)
 789:	b8 0c 00 00 00       	mov    $0xc,%eax
 78e:	cd 40                	int    $0x40
 790:	c3                   	ret    

00000791 <sleep>:
SYSCALL(sleep)
 791:	b8 0d 00 00 00       	mov    $0xd,%eax
 796:	cd 40                	int    $0x40
 798:	c3                   	ret    

00000799 <uptime>:
SYSCALL(uptime)
 799:	b8 0e 00 00 00       	mov    $0xe,%eax
 79e:	cd 40                	int    $0x40
 7a0:	c3                   	ret    

000007a1 <mencrypt>:
SYSCALL(mencrypt)
 7a1:	b8 16 00 00 00       	mov    $0x16,%eax
 7a6:	cd 40                	int    $0x40
 7a8:	c3                   	ret    

000007a9 <getpgtable>:
SYSCALL(getpgtable)
 7a9:	b8 17 00 00 00       	mov    $0x17,%eax
 7ae:	cd 40                	int    $0x40
 7b0:	c3                   	ret    

000007b1 <dump_rawphymem>:
SYSCALL(dump_rawphymem)
 7b1:	b8 18 00 00 00       	mov    $0x18,%eax
 7b6:	cd 40                	int    $0x40
 7b8:	c3                   	ret    

000007b9 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 7b9:	f3 0f 1e fb          	endbr32 
 7bd:	55                   	push   %ebp
 7be:	89 e5                	mov    %esp,%ebp
 7c0:	83 ec 18             	sub    $0x18,%esp
 7c3:	8b 45 0c             	mov    0xc(%ebp),%eax
 7c6:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 7c9:	83 ec 04             	sub    $0x4,%esp
 7cc:	6a 01                	push   $0x1
 7ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
 7d1:	50                   	push   %eax
 7d2:	ff 75 08             	pushl  0x8(%ebp)
 7d5:	e8 47 ff ff ff       	call   721 <write>
 7da:	83 c4 10             	add    $0x10,%esp
}
 7dd:	90                   	nop
 7de:	c9                   	leave  
 7df:	c3                   	ret    

000007e0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 7e0:	f3 0f 1e fb          	endbr32 
 7e4:	55                   	push   %ebp
 7e5:	89 e5                	mov    %esp,%ebp
 7e7:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 7ea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 7f1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 7f5:	74 17                	je     80e <printint+0x2e>
 7f7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 7fb:	79 11                	jns    80e <printint+0x2e>
    neg = 1;
 7fd:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 804:	8b 45 0c             	mov    0xc(%ebp),%eax
 807:	f7 d8                	neg    %eax
 809:	89 45 ec             	mov    %eax,-0x14(%ebp)
 80c:	eb 06                	jmp    814 <printint+0x34>
  } else {
    x = xx;
 80e:	8b 45 0c             	mov    0xc(%ebp),%eax
 811:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 814:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 81b:	8b 4d 10             	mov    0x10(%ebp),%ecx
 81e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 821:	ba 00 00 00 00       	mov    $0x0,%edx
 826:	f7 f1                	div    %ecx
 828:	89 d1                	mov    %edx,%ecx
 82a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82d:	8d 50 01             	lea    0x1(%eax),%edx
 830:	89 55 f4             	mov    %edx,-0xc(%ebp)
 833:	0f b6 91 b0 10 00 00 	movzbl 0x10b0(%ecx),%edx
 83a:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 83e:	8b 4d 10             	mov    0x10(%ebp),%ecx
 841:	8b 45 ec             	mov    -0x14(%ebp),%eax
 844:	ba 00 00 00 00       	mov    $0x0,%edx
 849:	f7 f1                	div    %ecx
 84b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 84e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 852:	75 c7                	jne    81b <printint+0x3b>
  if(neg)
 854:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 858:	74 2d                	je     887 <printint+0xa7>
    buf[i++] = '-';
 85a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85d:	8d 50 01             	lea    0x1(%eax),%edx
 860:	89 55 f4             	mov    %edx,-0xc(%ebp)
 863:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 868:	eb 1d                	jmp    887 <printint+0xa7>
    putc(fd, buf[i]);
 86a:	8d 55 dc             	lea    -0x24(%ebp),%edx
 86d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 870:	01 d0                	add    %edx,%eax
 872:	0f b6 00             	movzbl (%eax),%eax
 875:	0f be c0             	movsbl %al,%eax
 878:	83 ec 08             	sub    $0x8,%esp
 87b:	50                   	push   %eax
 87c:	ff 75 08             	pushl  0x8(%ebp)
 87f:	e8 35 ff ff ff       	call   7b9 <putc>
 884:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 887:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 88b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 88f:	79 d9                	jns    86a <printint+0x8a>
}
 891:	90                   	nop
 892:	90                   	nop
 893:	c9                   	leave  
 894:	c3                   	ret    

00000895 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 895:	f3 0f 1e fb          	endbr32 
 899:	55                   	push   %ebp
 89a:	89 e5                	mov    %esp,%ebp
 89c:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 89f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 8a6:	8d 45 0c             	lea    0xc(%ebp),%eax
 8a9:	83 c0 04             	add    $0x4,%eax
 8ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 8af:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 8b6:	e9 59 01 00 00       	jmp    a14 <printf+0x17f>
    c = fmt[i] & 0xff;
 8bb:	8b 55 0c             	mov    0xc(%ebp),%edx
 8be:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c1:	01 d0                	add    %edx,%eax
 8c3:	0f b6 00             	movzbl (%eax),%eax
 8c6:	0f be c0             	movsbl %al,%eax
 8c9:	25 ff 00 00 00       	and    $0xff,%eax
 8ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 8d1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 8d5:	75 2c                	jne    903 <printf+0x6e>
      if(c == '%'){
 8d7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8db:	75 0c                	jne    8e9 <printf+0x54>
        state = '%';
 8dd:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 8e4:	e9 27 01 00 00       	jmp    a10 <printf+0x17b>
      } else {
        putc(fd, c);
 8e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8ec:	0f be c0             	movsbl %al,%eax
 8ef:	83 ec 08             	sub    $0x8,%esp
 8f2:	50                   	push   %eax
 8f3:	ff 75 08             	pushl  0x8(%ebp)
 8f6:	e8 be fe ff ff       	call   7b9 <putc>
 8fb:	83 c4 10             	add    $0x10,%esp
 8fe:	e9 0d 01 00 00       	jmp    a10 <printf+0x17b>
      }
    } else if(state == '%'){
 903:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 907:	0f 85 03 01 00 00    	jne    a10 <printf+0x17b>
      if(c == 'd'){
 90d:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 911:	75 1e                	jne    931 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 913:	8b 45 e8             	mov    -0x18(%ebp),%eax
 916:	8b 00                	mov    (%eax),%eax
 918:	6a 01                	push   $0x1
 91a:	6a 0a                	push   $0xa
 91c:	50                   	push   %eax
 91d:	ff 75 08             	pushl  0x8(%ebp)
 920:	e8 bb fe ff ff       	call   7e0 <printint>
 925:	83 c4 10             	add    $0x10,%esp
        ap++;
 928:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 92c:	e9 d8 00 00 00       	jmp    a09 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 931:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 935:	74 06                	je     93d <printf+0xa8>
 937:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 93b:	75 1e                	jne    95b <printf+0xc6>
        printint(fd, *ap, 16, 0);
 93d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 940:	8b 00                	mov    (%eax),%eax
 942:	6a 00                	push   $0x0
 944:	6a 10                	push   $0x10
 946:	50                   	push   %eax
 947:	ff 75 08             	pushl  0x8(%ebp)
 94a:	e8 91 fe ff ff       	call   7e0 <printint>
 94f:	83 c4 10             	add    $0x10,%esp
        ap++;
 952:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 956:	e9 ae 00 00 00       	jmp    a09 <printf+0x174>
      } else if(c == 's'){
 95b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 95f:	75 43                	jne    9a4 <printf+0x10f>
        s = (char*)*ap;
 961:	8b 45 e8             	mov    -0x18(%ebp),%eax
 964:	8b 00                	mov    (%eax),%eax
 966:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 969:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 96d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 971:	75 25                	jne    998 <printf+0x103>
          s = "(null)";
 973:	c7 45 f4 1b 0e 00 00 	movl   $0xe1b,-0xc(%ebp)
        while(*s != 0){
 97a:	eb 1c                	jmp    998 <printf+0x103>
          putc(fd, *s);
 97c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 97f:	0f b6 00             	movzbl (%eax),%eax
 982:	0f be c0             	movsbl %al,%eax
 985:	83 ec 08             	sub    $0x8,%esp
 988:	50                   	push   %eax
 989:	ff 75 08             	pushl  0x8(%ebp)
 98c:	e8 28 fe ff ff       	call   7b9 <putc>
 991:	83 c4 10             	add    $0x10,%esp
          s++;
 994:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 998:	8b 45 f4             	mov    -0xc(%ebp),%eax
 99b:	0f b6 00             	movzbl (%eax),%eax
 99e:	84 c0                	test   %al,%al
 9a0:	75 da                	jne    97c <printf+0xe7>
 9a2:	eb 65                	jmp    a09 <printf+0x174>
        }
      } else if(c == 'c'){
 9a4:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 9a8:	75 1d                	jne    9c7 <printf+0x132>
        putc(fd, *ap);
 9aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9ad:	8b 00                	mov    (%eax),%eax
 9af:	0f be c0             	movsbl %al,%eax
 9b2:	83 ec 08             	sub    $0x8,%esp
 9b5:	50                   	push   %eax
 9b6:	ff 75 08             	pushl  0x8(%ebp)
 9b9:	e8 fb fd ff ff       	call   7b9 <putc>
 9be:	83 c4 10             	add    $0x10,%esp
        ap++;
 9c1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9c5:	eb 42                	jmp    a09 <printf+0x174>
      } else if(c == '%'){
 9c7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 9cb:	75 17                	jne    9e4 <printf+0x14f>
        putc(fd, c);
 9cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 9d0:	0f be c0             	movsbl %al,%eax
 9d3:	83 ec 08             	sub    $0x8,%esp
 9d6:	50                   	push   %eax
 9d7:	ff 75 08             	pushl  0x8(%ebp)
 9da:	e8 da fd ff ff       	call   7b9 <putc>
 9df:	83 c4 10             	add    $0x10,%esp
 9e2:	eb 25                	jmp    a09 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 9e4:	83 ec 08             	sub    $0x8,%esp
 9e7:	6a 25                	push   $0x25
 9e9:	ff 75 08             	pushl  0x8(%ebp)
 9ec:	e8 c8 fd ff ff       	call   7b9 <putc>
 9f1:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 9f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 9f7:	0f be c0             	movsbl %al,%eax
 9fa:	83 ec 08             	sub    $0x8,%esp
 9fd:	50                   	push   %eax
 9fe:	ff 75 08             	pushl  0x8(%ebp)
 a01:	e8 b3 fd ff ff       	call   7b9 <putc>
 a06:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 a09:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 a10:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 a14:	8b 55 0c             	mov    0xc(%ebp),%edx
 a17:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a1a:	01 d0                	add    %edx,%eax
 a1c:	0f b6 00             	movzbl (%eax),%eax
 a1f:	84 c0                	test   %al,%al
 a21:	0f 85 94 fe ff ff    	jne    8bb <printf+0x26>
    }
  }
}
 a27:	90                   	nop
 a28:	90                   	nop
 a29:	c9                   	leave  
 a2a:	c3                   	ret    

00000a2b <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a2b:	f3 0f 1e fb          	endbr32 
 a2f:	55                   	push   %ebp
 a30:	89 e5                	mov    %esp,%ebp
 a32:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a35:	8b 45 08             	mov    0x8(%ebp),%eax
 a38:	83 e8 08             	sub    $0x8,%eax
 a3b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a3e:	a1 cc 10 00 00       	mov    0x10cc,%eax
 a43:	89 45 fc             	mov    %eax,-0x4(%ebp)
 a46:	eb 24                	jmp    a6c <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a48:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a4b:	8b 00                	mov    (%eax),%eax
 a4d:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 a50:	72 12                	jb     a64 <free+0x39>
 a52:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a55:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 a58:	77 24                	ja     a7e <free+0x53>
 a5a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a5d:	8b 00                	mov    (%eax),%eax
 a5f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 a62:	72 1a                	jb     a7e <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a64:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a67:	8b 00                	mov    (%eax),%eax
 a69:	89 45 fc             	mov    %eax,-0x4(%ebp)
 a6c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a6f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 a72:	76 d4                	jbe    a48 <free+0x1d>
 a74:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a77:	8b 00                	mov    (%eax),%eax
 a79:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 a7c:	73 ca                	jae    a48 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 a7e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a81:	8b 40 04             	mov    0x4(%eax),%eax
 a84:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 a8b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a8e:	01 c2                	add    %eax,%edx
 a90:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a93:	8b 00                	mov    (%eax),%eax
 a95:	39 c2                	cmp    %eax,%edx
 a97:	75 24                	jne    abd <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 a99:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a9c:	8b 50 04             	mov    0x4(%eax),%edx
 a9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aa2:	8b 00                	mov    (%eax),%eax
 aa4:	8b 40 04             	mov    0x4(%eax),%eax
 aa7:	01 c2                	add    %eax,%edx
 aa9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 aac:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 aaf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ab2:	8b 00                	mov    (%eax),%eax
 ab4:	8b 10                	mov    (%eax),%edx
 ab6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ab9:	89 10                	mov    %edx,(%eax)
 abb:	eb 0a                	jmp    ac7 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 abd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ac0:	8b 10                	mov    (%eax),%edx
 ac2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ac5:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 ac7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aca:	8b 40 04             	mov    0x4(%eax),%eax
 acd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 ad4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ad7:	01 d0                	add    %edx,%eax
 ad9:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 adc:	75 20                	jne    afe <free+0xd3>
    p->s.size += bp->s.size;
 ade:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ae1:	8b 50 04             	mov    0x4(%eax),%edx
 ae4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ae7:	8b 40 04             	mov    0x4(%eax),%eax
 aea:	01 c2                	add    %eax,%edx
 aec:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aef:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 af2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 af5:	8b 10                	mov    (%eax),%edx
 af7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 afa:	89 10                	mov    %edx,(%eax)
 afc:	eb 08                	jmp    b06 <free+0xdb>
  } else
    p->s.ptr = bp;
 afe:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b01:	8b 55 f8             	mov    -0x8(%ebp),%edx
 b04:	89 10                	mov    %edx,(%eax)
  freep = p;
 b06:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b09:	a3 cc 10 00 00       	mov    %eax,0x10cc
}
 b0e:	90                   	nop
 b0f:	c9                   	leave  
 b10:	c3                   	ret    

00000b11 <morecore>:

static Header*
morecore(uint nu)
{
 b11:	f3 0f 1e fb          	endbr32 
 b15:	55                   	push   %ebp
 b16:	89 e5                	mov    %esp,%ebp
 b18:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 b1b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 b22:	77 07                	ja     b2b <morecore+0x1a>
    nu = 4096;
 b24:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 b2b:	8b 45 08             	mov    0x8(%ebp),%eax
 b2e:	c1 e0 03             	shl    $0x3,%eax
 b31:	83 ec 0c             	sub    $0xc,%esp
 b34:	50                   	push   %eax
 b35:	e8 4f fc ff ff       	call   789 <sbrk>
 b3a:	83 c4 10             	add    $0x10,%esp
 b3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 b40:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 b44:	75 07                	jne    b4d <morecore+0x3c>
    return 0;
 b46:	b8 00 00 00 00       	mov    $0x0,%eax
 b4b:	eb 26                	jmp    b73 <morecore+0x62>
  hp = (Header*)p;
 b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b50:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 b53:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b56:	8b 55 08             	mov    0x8(%ebp),%edx
 b59:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 b5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b5f:	83 c0 08             	add    $0x8,%eax
 b62:	83 ec 0c             	sub    $0xc,%esp
 b65:	50                   	push   %eax
 b66:	e8 c0 fe ff ff       	call   a2b <free>
 b6b:	83 c4 10             	add    $0x10,%esp
  return freep;
 b6e:	a1 cc 10 00 00       	mov    0x10cc,%eax
}
 b73:	c9                   	leave  
 b74:	c3                   	ret    

00000b75 <malloc>:

void*
malloc(uint nbytes)
{
 b75:	f3 0f 1e fb          	endbr32 
 b79:	55                   	push   %ebp
 b7a:	89 e5                	mov    %esp,%ebp
 b7c:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b7f:	8b 45 08             	mov    0x8(%ebp),%eax
 b82:	83 c0 07             	add    $0x7,%eax
 b85:	c1 e8 03             	shr    $0x3,%eax
 b88:	83 c0 01             	add    $0x1,%eax
 b8b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 b8e:	a1 cc 10 00 00       	mov    0x10cc,%eax
 b93:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b96:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 b9a:	75 23                	jne    bbf <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 b9c:	c7 45 f0 c4 10 00 00 	movl   $0x10c4,-0x10(%ebp)
 ba3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ba6:	a3 cc 10 00 00       	mov    %eax,0x10cc
 bab:	a1 cc 10 00 00       	mov    0x10cc,%eax
 bb0:	a3 c4 10 00 00       	mov    %eax,0x10c4
    base.s.size = 0;
 bb5:	c7 05 c8 10 00 00 00 	movl   $0x0,0x10c8
 bbc:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 bbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bc2:	8b 00                	mov    (%eax),%eax
 bc4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bca:	8b 40 04             	mov    0x4(%eax),%eax
 bcd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 bd0:	77 4d                	ja     c1f <malloc+0xaa>
      if(p->s.size == nunits)
 bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bd5:	8b 40 04             	mov    0x4(%eax),%eax
 bd8:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 bdb:	75 0c                	jne    be9 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 be0:	8b 10                	mov    (%eax),%edx
 be2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 be5:	89 10                	mov    %edx,(%eax)
 be7:	eb 26                	jmp    c0f <malloc+0x9a>
      else {
        p->s.size -= nunits;
 be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bec:	8b 40 04             	mov    0x4(%eax),%eax
 bef:	2b 45 ec             	sub    -0x14(%ebp),%eax
 bf2:	89 c2                	mov    %eax,%edx
 bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bf7:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 bfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bfd:	8b 40 04             	mov    0x4(%eax),%eax
 c00:	c1 e0 03             	shl    $0x3,%eax
 c03:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c09:	8b 55 ec             	mov    -0x14(%ebp),%edx
 c0c:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 c0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c12:	a3 cc 10 00 00       	mov    %eax,0x10cc
      return (void*)(p + 1);
 c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c1a:	83 c0 08             	add    $0x8,%eax
 c1d:	eb 3b                	jmp    c5a <malloc+0xe5>
    }
    if(p == freep)
 c1f:	a1 cc 10 00 00       	mov    0x10cc,%eax
 c24:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 c27:	75 1e                	jne    c47 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 c29:	83 ec 0c             	sub    $0xc,%esp
 c2c:	ff 75 ec             	pushl  -0x14(%ebp)
 c2f:	e8 dd fe ff ff       	call   b11 <morecore>
 c34:	83 c4 10             	add    $0x10,%esp
 c37:	89 45 f4             	mov    %eax,-0xc(%ebp)
 c3a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 c3e:	75 07                	jne    c47 <malloc+0xd2>
        return 0;
 c40:	b8 00 00 00 00       	mov    $0x0,%eax
 c45:	eb 13                	jmp    c5a <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c4a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c50:	8b 00                	mov    (%eax),%eax
 c52:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 c55:	e9 6d ff ff ff       	jmp    bc7 <malloc+0x52>
  }
}
 c5a:	c9                   	leave  
 c5b:	c3                   	ret    
