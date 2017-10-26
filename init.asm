
_init:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 14             	sub    $0x14,%esp
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
  11:	83 ec 08             	sub    $0x8,%esp
  14:	6a 02                	push   $0x2
  16:	68 72 08 00 00       	push   $0x872
  1b:	e8 62 03 00 00       	call   382 <open>
  20:	83 c4 10             	add    $0x10,%esp
  23:	85 c0                	test   %eax,%eax
  25:	79 26                	jns    4d <main+0x4d>
    mknod("console", 1, 1);
  27:	83 ec 04             	sub    $0x4,%esp
  2a:	6a 01                	push   $0x1
  2c:	6a 01                	push   $0x1
  2e:	68 72 08 00 00       	push   $0x872
  33:	e8 52 03 00 00       	call   38a <mknod>
  38:	83 c4 10             	add    $0x10,%esp
    open("console", O_RDWR);
  3b:	83 ec 08             	sub    $0x8,%esp
  3e:	6a 02                	push   $0x2
  40:	68 72 08 00 00       	push   $0x872
  45:	e8 38 03 00 00       	call   382 <open>
  4a:	83 c4 10             	add    $0x10,%esp
  }
  dup(0);  // stdout
  4d:	83 ec 0c             	sub    $0xc,%esp
  50:	6a 00                	push   $0x0
  52:	e8 63 03 00 00       	call   3ba <dup>
  57:	83 c4 10             	add    $0x10,%esp
  dup(0);  // stderr
  5a:	83 ec 0c             	sub    $0xc,%esp
  5d:	6a 00                	push   $0x0
  5f:	e8 56 03 00 00       	call   3ba <dup>
  64:	83 c4 10             	add    $0x10,%esp

  for(;;){
    pid = fork();
  67:	e8 ce 02 00 00       	call   33a <fork>
  6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(pid < 0){
  6f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  73:	79 17                	jns    8c <main+0x8c>
      printf(1, "init: fork failed\n");
  75:	83 ec 08             	sub    $0x8,%esp
  78:	68 7a 08 00 00       	push   $0x87a
  7d:	6a 01                	push   $0x1
  7f:	e8 35 04 00 00       	call   4b9 <printf>
  84:	83 c4 10             	add    $0x10,%esp
      exit();
  87:	e8 b6 02 00 00       	call   342 <exit>
    }
    if(pid == 0){
  8c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  90:	75 3e                	jne    d0 <main+0xd0>
      exec("sh", argv);
  92:	83 ec 08             	sub    $0x8,%esp
  95:	68 fc 0a 00 00       	push   $0xafc
  9a:	68 6f 08 00 00       	push   $0x86f
  9f:	e8 d6 02 00 00       	call   37a <exec>
  a4:	83 c4 10             	add    $0x10,%esp
      printf(1, "init: exec sh failed\n");
  a7:	83 ec 08             	sub    $0x8,%esp
  aa:	68 8d 08 00 00       	push   $0x88d
  af:	6a 01                	push   $0x1
  b1:	e8 03 04 00 00       	call   4b9 <printf>
  b6:	83 c4 10             	add    $0x10,%esp
      exit();
  b9:	e8 84 02 00 00       	call   342 <exit>
    }
    while((wpid=wait()) >= 0 && wpid != pid)
      printf(1, "zombie!\n");
  be:	83 ec 08             	sub    $0x8,%esp
  c1:	68 a3 08 00 00       	push   $0x8a3
  c6:	6a 01                	push   $0x1
  c8:	e8 ec 03 00 00       	call   4b9 <printf>
  cd:	83 c4 10             	add    $0x10,%esp
    while((wpid=wait()) >= 0 && wpid != pid)
  d0:	e8 75 02 00 00       	call   34a <wait>
  d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  d8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  dc:	78 89                	js     67 <main+0x67>
  de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  e1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  e4:	75 d8                	jne    be <main+0xbe>
    pid = fork();
  e6:	e9 7c ff ff ff       	jmp    67 <main+0x67>

000000eb <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  eb:	55                   	push   %ebp
  ec:	89 e5                	mov    %esp,%ebp
  ee:	57                   	push   %edi
  ef:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  f3:	8b 55 10             	mov    0x10(%ebp),%edx
  f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  f9:	89 cb                	mov    %ecx,%ebx
  fb:	89 df                	mov    %ebx,%edi
  fd:	89 d1                	mov    %edx,%ecx
  ff:	fc                   	cld    
 100:	f3 aa                	rep stos %al,%es:(%edi)
 102:	89 ca                	mov    %ecx,%edx
 104:	89 fb                	mov    %edi,%ebx
 106:	89 5d 08             	mov    %ebx,0x8(%ebp)
 109:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 10c:	90                   	nop
 10d:	5b                   	pop    %ebx
 10e:	5f                   	pop    %edi
 10f:	5d                   	pop    %ebp
 110:	c3                   	ret    

00000111 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 111:	55                   	push   %ebp
 112:	89 e5                	mov    %esp,%ebp
 114:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 117:	8b 45 08             	mov    0x8(%ebp),%eax
 11a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 11d:	90                   	nop
 11e:	8b 45 08             	mov    0x8(%ebp),%eax
 121:	8d 50 01             	lea    0x1(%eax),%edx
 124:	89 55 08             	mov    %edx,0x8(%ebp)
 127:	8b 55 0c             	mov    0xc(%ebp),%edx
 12a:	8d 4a 01             	lea    0x1(%edx),%ecx
 12d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 130:	0f b6 12             	movzbl (%edx),%edx
 133:	88 10                	mov    %dl,(%eax)
 135:	0f b6 00             	movzbl (%eax),%eax
 138:	84 c0                	test   %al,%al
 13a:	75 e2                	jne    11e <strcpy+0xd>
    ;
  return os;
 13c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 13f:	c9                   	leave  
 140:	c3                   	ret    

00000141 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 141:	55                   	push   %ebp
 142:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 144:	eb 08                	jmp    14e <strcmp+0xd>
    p++, q++;
 146:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 14a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 14e:	8b 45 08             	mov    0x8(%ebp),%eax
 151:	0f b6 00             	movzbl (%eax),%eax
 154:	84 c0                	test   %al,%al
 156:	74 10                	je     168 <strcmp+0x27>
 158:	8b 45 08             	mov    0x8(%ebp),%eax
 15b:	0f b6 10             	movzbl (%eax),%edx
 15e:	8b 45 0c             	mov    0xc(%ebp),%eax
 161:	0f b6 00             	movzbl (%eax),%eax
 164:	38 c2                	cmp    %al,%dl
 166:	74 de                	je     146 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 168:	8b 45 08             	mov    0x8(%ebp),%eax
 16b:	0f b6 00             	movzbl (%eax),%eax
 16e:	0f b6 d0             	movzbl %al,%edx
 171:	8b 45 0c             	mov    0xc(%ebp),%eax
 174:	0f b6 00             	movzbl (%eax),%eax
 177:	0f b6 c0             	movzbl %al,%eax
 17a:	29 c2                	sub    %eax,%edx
 17c:	89 d0                	mov    %edx,%eax
}
 17e:	5d                   	pop    %ebp
 17f:	c3                   	ret    

00000180 <strlen>:

uint
strlen(char *s)
{
 180:	55                   	push   %ebp
 181:	89 e5                	mov    %esp,%ebp
 183:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 186:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 18d:	eb 04                	jmp    193 <strlen+0x13>
 18f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 193:	8b 55 fc             	mov    -0x4(%ebp),%edx
 196:	8b 45 08             	mov    0x8(%ebp),%eax
 199:	01 d0                	add    %edx,%eax
 19b:	0f b6 00             	movzbl (%eax),%eax
 19e:	84 c0                	test   %al,%al
 1a0:	75 ed                	jne    18f <strlen+0xf>
    ;
  return n;
 1a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1a5:	c9                   	leave  
 1a6:	c3                   	ret    

000001a7 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1a7:	55                   	push   %ebp
 1a8:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 1aa:	8b 45 10             	mov    0x10(%ebp),%eax
 1ad:	50                   	push   %eax
 1ae:	ff 75 0c             	pushl  0xc(%ebp)
 1b1:	ff 75 08             	pushl  0x8(%ebp)
 1b4:	e8 32 ff ff ff       	call   eb <stosb>
 1b9:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1bc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1bf:	c9                   	leave  
 1c0:	c3                   	ret    

000001c1 <strchr>:

char*
strchr(const char *s, char c)
{
 1c1:	55                   	push   %ebp
 1c2:	89 e5                	mov    %esp,%ebp
 1c4:	83 ec 04             	sub    $0x4,%esp
 1c7:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ca:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1cd:	eb 14                	jmp    1e3 <strchr+0x22>
    if(*s == c)
 1cf:	8b 45 08             	mov    0x8(%ebp),%eax
 1d2:	0f b6 00             	movzbl (%eax),%eax
 1d5:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1d8:	75 05                	jne    1df <strchr+0x1e>
      return (char*)s;
 1da:	8b 45 08             	mov    0x8(%ebp),%eax
 1dd:	eb 13                	jmp    1f2 <strchr+0x31>
  for(; *s; s++)
 1df:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1e3:	8b 45 08             	mov    0x8(%ebp),%eax
 1e6:	0f b6 00             	movzbl (%eax),%eax
 1e9:	84 c0                	test   %al,%al
 1eb:	75 e2                	jne    1cf <strchr+0xe>
  return 0;
 1ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1f2:	c9                   	leave  
 1f3:	c3                   	ret    

000001f4 <gets>:

char*
gets(char *buf, int max)
{
 1f4:	55                   	push   %ebp
 1f5:	89 e5                	mov    %esp,%ebp
 1f7:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 201:	eb 42                	jmp    245 <gets+0x51>
    cc = read(0, &c, 1);
 203:	83 ec 04             	sub    $0x4,%esp
 206:	6a 01                	push   $0x1
 208:	8d 45 ef             	lea    -0x11(%ebp),%eax
 20b:	50                   	push   %eax
 20c:	6a 00                	push   $0x0
 20e:	e8 47 01 00 00       	call   35a <read>
 213:	83 c4 10             	add    $0x10,%esp
 216:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 219:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 21d:	7e 33                	jle    252 <gets+0x5e>
      break;
    buf[i++] = c;
 21f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 222:	8d 50 01             	lea    0x1(%eax),%edx
 225:	89 55 f4             	mov    %edx,-0xc(%ebp)
 228:	89 c2                	mov    %eax,%edx
 22a:	8b 45 08             	mov    0x8(%ebp),%eax
 22d:	01 c2                	add    %eax,%edx
 22f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 233:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 235:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 239:	3c 0a                	cmp    $0xa,%al
 23b:	74 16                	je     253 <gets+0x5f>
 23d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 241:	3c 0d                	cmp    $0xd,%al
 243:	74 0e                	je     253 <gets+0x5f>
  for(i=0; i+1 < max; ){
 245:	8b 45 f4             	mov    -0xc(%ebp),%eax
 248:	83 c0 01             	add    $0x1,%eax
 24b:	3b 45 0c             	cmp    0xc(%ebp),%eax
 24e:	7c b3                	jl     203 <gets+0xf>
 250:	eb 01                	jmp    253 <gets+0x5f>
      break;
 252:	90                   	nop
      break;
  }
  buf[i] = '\0';
 253:	8b 55 f4             	mov    -0xc(%ebp),%edx
 256:	8b 45 08             	mov    0x8(%ebp),%eax
 259:	01 d0                	add    %edx,%eax
 25b:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 25e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 261:	c9                   	leave  
 262:	c3                   	ret    

00000263 <stat>:

int
stat(char *n, struct stat *st)
{
 263:	55                   	push   %ebp
 264:	89 e5                	mov    %esp,%ebp
 266:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 269:	83 ec 08             	sub    $0x8,%esp
 26c:	6a 00                	push   $0x0
 26e:	ff 75 08             	pushl  0x8(%ebp)
 271:	e8 0c 01 00 00       	call   382 <open>
 276:	83 c4 10             	add    $0x10,%esp
 279:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 27c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 280:	79 07                	jns    289 <stat+0x26>
    return -1;
 282:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 287:	eb 25                	jmp    2ae <stat+0x4b>
  r = fstat(fd, st);
 289:	83 ec 08             	sub    $0x8,%esp
 28c:	ff 75 0c             	pushl  0xc(%ebp)
 28f:	ff 75 f4             	pushl  -0xc(%ebp)
 292:	e8 03 01 00 00       	call   39a <fstat>
 297:	83 c4 10             	add    $0x10,%esp
 29a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 29d:	83 ec 0c             	sub    $0xc,%esp
 2a0:	ff 75 f4             	pushl  -0xc(%ebp)
 2a3:	e8 c2 00 00 00       	call   36a <close>
 2a8:	83 c4 10             	add    $0x10,%esp
  return r;
 2ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2ae:	c9                   	leave  
 2af:	c3                   	ret    

000002b0 <atoi>:

int
atoi(const char *s)
{
 2b0:	55                   	push   %ebp
 2b1:	89 e5                	mov    %esp,%ebp
 2b3:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2b6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2bd:	eb 25                	jmp    2e4 <atoi+0x34>
    n = n*10 + *s++ - '0';
 2bf:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2c2:	89 d0                	mov    %edx,%eax
 2c4:	c1 e0 02             	shl    $0x2,%eax
 2c7:	01 d0                	add    %edx,%eax
 2c9:	01 c0                	add    %eax,%eax
 2cb:	89 c1                	mov    %eax,%ecx
 2cd:	8b 45 08             	mov    0x8(%ebp),%eax
 2d0:	8d 50 01             	lea    0x1(%eax),%edx
 2d3:	89 55 08             	mov    %edx,0x8(%ebp)
 2d6:	0f b6 00             	movzbl (%eax),%eax
 2d9:	0f be c0             	movsbl %al,%eax
 2dc:	01 c8                	add    %ecx,%eax
 2de:	83 e8 30             	sub    $0x30,%eax
 2e1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2e4:	8b 45 08             	mov    0x8(%ebp),%eax
 2e7:	0f b6 00             	movzbl (%eax),%eax
 2ea:	3c 2f                	cmp    $0x2f,%al
 2ec:	7e 0a                	jle    2f8 <atoi+0x48>
 2ee:	8b 45 08             	mov    0x8(%ebp),%eax
 2f1:	0f b6 00             	movzbl (%eax),%eax
 2f4:	3c 39                	cmp    $0x39,%al
 2f6:	7e c7                	jle    2bf <atoi+0xf>
  return n;
 2f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2fb:	c9                   	leave  
 2fc:	c3                   	ret    

000002fd <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2fd:	55                   	push   %ebp
 2fe:	89 e5                	mov    %esp,%ebp
 300:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 303:	8b 45 08             	mov    0x8(%ebp),%eax
 306:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 309:	8b 45 0c             	mov    0xc(%ebp),%eax
 30c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 30f:	eb 17                	jmp    328 <memmove+0x2b>
    *dst++ = *src++;
 311:	8b 45 fc             	mov    -0x4(%ebp),%eax
 314:	8d 50 01             	lea    0x1(%eax),%edx
 317:	89 55 fc             	mov    %edx,-0x4(%ebp)
 31a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 31d:	8d 4a 01             	lea    0x1(%edx),%ecx
 320:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 323:	0f b6 12             	movzbl (%edx),%edx
 326:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 328:	8b 45 10             	mov    0x10(%ebp),%eax
 32b:	8d 50 ff             	lea    -0x1(%eax),%edx
 32e:	89 55 10             	mov    %edx,0x10(%ebp)
 331:	85 c0                	test   %eax,%eax
 333:	7f dc                	jg     311 <memmove+0x14>
  return vdst;
 335:	8b 45 08             	mov    0x8(%ebp),%eax
}
 338:	c9                   	leave  
 339:	c3                   	ret    

0000033a <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 33a:	b8 01 00 00 00       	mov    $0x1,%eax
 33f:	cd 40                	int    $0x40
 341:	c3                   	ret    

00000342 <exit>:
SYSCALL(exit)
 342:	b8 02 00 00 00       	mov    $0x2,%eax
 347:	cd 40                	int    $0x40
 349:	c3                   	ret    

0000034a <wait>:
SYSCALL(wait)
 34a:	b8 03 00 00 00       	mov    $0x3,%eax
 34f:	cd 40                	int    $0x40
 351:	c3                   	ret    

00000352 <pipe>:
SYSCALL(pipe)
 352:	b8 04 00 00 00       	mov    $0x4,%eax
 357:	cd 40                	int    $0x40
 359:	c3                   	ret    

0000035a <read>:
SYSCALL(read)
 35a:	b8 05 00 00 00       	mov    $0x5,%eax
 35f:	cd 40                	int    $0x40
 361:	c3                   	ret    

00000362 <write>:
SYSCALL(write)
 362:	b8 10 00 00 00       	mov    $0x10,%eax
 367:	cd 40                	int    $0x40
 369:	c3                   	ret    

0000036a <close>:
SYSCALL(close)
 36a:	b8 15 00 00 00       	mov    $0x15,%eax
 36f:	cd 40                	int    $0x40
 371:	c3                   	ret    

00000372 <kill>:
SYSCALL(kill)
 372:	b8 06 00 00 00       	mov    $0x6,%eax
 377:	cd 40                	int    $0x40
 379:	c3                   	ret    

0000037a <exec>:
SYSCALL(exec)
 37a:	b8 07 00 00 00       	mov    $0x7,%eax
 37f:	cd 40                	int    $0x40
 381:	c3                   	ret    

00000382 <open>:
SYSCALL(open)
 382:	b8 0f 00 00 00       	mov    $0xf,%eax
 387:	cd 40                	int    $0x40
 389:	c3                   	ret    

0000038a <mknod>:
SYSCALL(mknod)
 38a:	b8 11 00 00 00       	mov    $0x11,%eax
 38f:	cd 40                	int    $0x40
 391:	c3                   	ret    

00000392 <unlink>:
SYSCALL(unlink)
 392:	b8 12 00 00 00       	mov    $0x12,%eax
 397:	cd 40                	int    $0x40
 399:	c3                   	ret    

0000039a <fstat>:
SYSCALL(fstat)
 39a:	b8 08 00 00 00       	mov    $0x8,%eax
 39f:	cd 40                	int    $0x40
 3a1:	c3                   	ret    

000003a2 <link>:
SYSCALL(link)
 3a2:	b8 13 00 00 00       	mov    $0x13,%eax
 3a7:	cd 40                	int    $0x40
 3a9:	c3                   	ret    

000003aa <mkdir>:
SYSCALL(mkdir)
 3aa:	b8 14 00 00 00       	mov    $0x14,%eax
 3af:	cd 40                	int    $0x40
 3b1:	c3                   	ret    

000003b2 <chdir>:
SYSCALL(chdir)
 3b2:	b8 09 00 00 00       	mov    $0x9,%eax
 3b7:	cd 40                	int    $0x40
 3b9:	c3                   	ret    

000003ba <dup>:
SYSCALL(dup)
 3ba:	b8 0a 00 00 00       	mov    $0xa,%eax
 3bf:	cd 40                	int    $0x40
 3c1:	c3                   	ret    

000003c2 <getpid>:
SYSCALL(getpid)
 3c2:	b8 0b 00 00 00       	mov    $0xb,%eax
 3c7:	cd 40                	int    $0x40
 3c9:	c3                   	ret    

000003ca <sbrk>:
SYSCALL(sbrk)
 3ca:	b8 0c 00 00 00       	mov    $0xc,%eax
 3cf:	cd 40                	int    $0x40
 3d1:	c3                   	ret    

000003d2 <sleep>:
SYSCALL(sleep)
 3d2:	b8 0d 00 00 00       	mov    $0xd,%eax
 3d7:	cd 40                	int    $0x40
 3d9:	c3                   	ret    

000003da <uptime>:
SYSCALL(uptime)
 3da:	b8 0e 00 00 00       	mov    $0xe,%eax
 3df:	cd 40                	int    $0x40
 3e1:	c3                   	ret    

000003e2 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3e2:	55                   	push   %ebp
 3e3:	89 e5                	mov    %esp,%ebp
 3e5:	83 ec 18             	sub    $0x18,%esp
 3e8:	8b 45 0c             	mov    0xc(%ebp),%eax
 3eb:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3ee:	83 ec 04             	sub    $0x4,%esp
 3f1:	6a 01                	push   $0x1
 3f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3f6:	50                   	push   %eax
 3f7:	ff 75 08             	pushl  0x8(%ebp)
 3fa:	e8 63 ff ff ff       	call   362 <write>
 3ff:	83 c4 10             	add    $0x10,%esp
}
 402:	90                   	nop
 403:	c9                   	leave  
 404:	c3                   	ret    

00000405 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 405:	55                   	push   %ebp
 406:	89 e5                	mov    %esp,%ebp
 408:	53                   	push   %ebx
 409:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 40c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 413:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 417:	74 17                	je     430 <printint+0x2b>
 419:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 41d:	79 11                	jns    430 <printint+0x2b>
    neg = 1;
 41f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 426:	8b 45 0c             	mov    0xc(%ebp),%eax
 429:	f7 d8                	neg    %eax
 42b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 42e:	eb 06                	jmp    436 <printint+0x31>
  } else {
    x = xx;
 430:	8b 45 0c             	mov    0xc(%ebp),%eax
 433:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 436:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 43d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 440:	8d 41 01             	lea    0x1(%ecx),%eax
 443:	89 45 f4             	mov    %eax,-0xc(%ebp)
 446:	8b 5d 10             	mov    0x10(%ebp),%ebx
 449:	8b 45 ec             	mov    -0x14(%ebp),%eax
 44c:	ba 00 00 00 00       	mov    $0x0,%edx
 451:	f7 f3                	div    %ebx
 453:	89 d0                	mov    %edx,%eax
 455:	0f b6 80 04 0b 00 00 	movzbl 0xb04(%eax),%eax
 45c:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 460:	8b 5d 10             	mov    0x10(%ebp),%ebx
 463:	8b 45 ec             	mov    -0x14(%ebp),%eax
 466:	ba 00 00 00 00       	mov    $0x0,%edx
 46b:	f7 f3                	div    %ebx
 46d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 470:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 474:	75 c7                	jne    43d <printint+0x38>
  if(neg)
 476:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 47a:	74 2d                	je     4a9 <printint+0xa4>
    buf[i++] = '-';
 47c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 47f:	8d 50 01             	lea    0x1(%eax),%edx
 482:	89 55 f4             	mov    %edx,-0xc(%ebp)
 485:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 48a:	eb 1d                	jmp    4a9 <printint+0xa4>
    putc(fd, buf[i]);
 48c:	8d 55 dc             	lea    -0x24(%ebp),%edx
 48f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 492:	01 d0                	add    %edx,%eax
 494:	0f b6 00             	movzbl (%eax),%eax
 497:	0f be c0             	movsbl %al,%eax
 49a:	83 ec 08             	sub    $0x8,%esp
 49d:	50                   	push   %eax
 49e:	ff 75 08             	pushl  0x8(%ebp)
 4a1:	e8 3c ff ff ff       	call   3e2 <putc>
 4a6:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 4a9:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4b1:	79 d9                	jns    48c <printint+0x87>
}
 4b3:	90                   	nop
 4b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 4b7:	c9                   	leave  
 4b8:	c3                   	ret    

000004b9 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4b9:	55                   	push   %ebp
 4ba:	89 e5                	mov    %esp,%ebp
 4bc:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4bf:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4c6:	8d 45 0c             	lea    0xc(%ebp),%eax
 4c9:	83 c0 04             	add    $0x4,%eax
 4cc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4cf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4d6:	e9 59 01 00 00       	jmp    634 <printf+0x17b>
    c = fmt[i] & 0xff;
 4db:	8b 55 0c             	mov    0xc(%ebp),%edx
 4de:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4e1:	01 d0                	add    %edx,%eax
 4e3:	0f b6 00             	movzbl (%eax),%eax
 4e6:	0f be c0             	movsbl %al,%eax
 4e9:	25 ff 00 00 00       	and    $0xff,%eax
 4ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4f1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4f5:	75 2c                	jne    523 <printf+0x6a>
      if(c == '%'){
 4f7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4fb:	75 0c                	jne    509 <printf+0x50>
        state = '%';
 4fd:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 504:	e9 27 01 00 00       	jmp    630 <printf+0x177>
      } else {
        putc(fd, c);
 509:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 50c:	0f be c0             	movsbl %al,%eax
 50f:	83 ec 08             	sub    $0x8,%esp
 512:	50                   	push   %eax
 513:	ff 75 08             	pushl  0x8(%ebp)
 516:	e8 c7 fe ff ff       	call   3e2 <putc>
 51b:	83 c4 10             	add    $0x10,%esp
 51e:	e9 0d 01 00 00       	jmp    630 <printf+0x177>
      }
    } else if(state == '%'){
 523:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 527:	0f 85 03 01 00 00    	jne    630 <printf+0x177>
      if(c == 'd'){
 52d:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 531:	75 1e                	jne    551 <printf+0x98>
        printint(fd, *ap, 10, 1);
 533:	8b 45 e8             	mov    -0x18(%ebp),%eax
 536:	8b 00                	mov    (%eax),%eax
 538:	6a 01                	push   $0x1
 53a:	6a 0a                	push   $0xa
 53c:	50                   	push   %eax
 53d:	ff 75 08             	pushl  0x8(%ebp)
 540:	e8 c0 fe ff ff       	call   405 <printint>
 545:	83 c4 10             	add    $0x10,%esp
        ap++;
 548:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 54c:	e9 d8 00 00 00       	jmp    629 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 551:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 555:	74 06                	je     55d <printf+0xa4>
 557:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 55b:	75 1e                	jne    57b <printf+0xc2>
        printint(fd, *ap, 16, 0);
 55d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 560:	8b 00                	mov    (%eax),%eax
 562:	6a 00                	push   $0x0
 564:	6a 10                	push   $0x10
 566:	50                   	push   %eax
 567:	ff 75 08             	pushl  0x8(%ebp)
 56a:	e8 96 fe ff ff       	call   405 <printint>
 56f:	83 c4 10             	add    $0x10,%esp
        ap++;
 572:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 576:	e9 ae 00 00 00       	jmp    629 <printf+0x170>
      } else if(c == 's'){
 57b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 57f:	75 43                	jne    5c4 <printf+0x10b>
        s = (char*)*ap;
 581:	8b 45 e8             	mov    -0x18(%ebp),%eax
 584:	8b 00                	mov    (%eax),%eax
 586:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 589:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 58d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 591:	75 25                	jne    5b8 <printf+0xff>
          s = "(null)";
 593:	c7 45 f4 ac 08 00 00 	movl   $0x8ac,-0xc(%ebp)
        while(*s != 0){
 59a:	eb 1c                	jmp    5b8 <printf+0xff>
          putc(fd, *s);
 59c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 59f:	0f b6 00             	movzbl (%eax),%eax
 5a2:	0f be c0             	movsbl %al,%eax
 5a5:	83 ec 08             	sub    $0x8,%esp
 5a8:	50                   	push   %eax
 5a9:	ff 75 08             	pushl  0x8(%ebp)
 5ac:	e8 31 fe ff ff       	call   3e2 <putc>
 5b1:	83 c4 10             	add    $0x10,%esp
          s++;
 5b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 5b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5bb:	0f b6 00             	movzbl (%eax),%eax
 5be:	84 c0                	test   %al,%al
 5c0:	75 da                	jne    59c <printf+0xe3>
 5c2:	eb 65                	jmp    629 <printf+0x170>
        }
      } else if(c == 'c'){
 5c4:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5c8:	75 1d                	jne    5e7 <printf+0x12e>
        putc(fd, *ap);
 5ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5cd:	8b 00                	mov    (%eax),%eax
 5cf:	0f be c0             	movsbl %al,%eax
 5d2:	83 ec 08             	sub    $0x8,%esp
 5d5:	50                   	push   %eax
 5d6:	ff 75 08             	pushl  0x8(%ebp)
 5d9:	e8 04 fe ff ff       	call   3e2 <putc>
 5de:	83 c4 10             	add    $0x10,%esp
        ap++;
 5e1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5e5:	eb 42                	jmp    629 <printf+0x170>
      } else if(c == '%'){
 5e7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5eb:	75 17                	jne    604 <printf+0x14b>
        putc(fd, c);
 5ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5f0:	0f be c0             	movsbl %al,%eax
 5f3:	83 ec 08             	sub    $0x8,%esp
 5f6:	50                   	push   %eax
 5f7:	ff 75 08             	pushl  0x8(%ebp)
 5fa:	e8 e3 fd ff ff       	call   3e2 <putc>
 5ff:	83 c4 10             	add    $0x10,%esp
 602:	eb 25                	jmp    629 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 604:	83 ec 08             	sub    $0x8,%esp
 607:	6a 25                	push   $0x25
 609:	ff 75 08             	pushl  0x8(%ebp)
 60c:	e8 d1 fd ff ff       	call   3e2 <putc>
 611:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 614:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 617:	0f be c0             	movsbl %al,%eax
 61a:	83 ec 08             	sub    $0x8,%esp
 61d:	50                   	push   %eax
 61e:	ff 75 08             	pushl  0x8(%ebp)
 621:	e8 bc fd ff ff       	call   3e2 <putc>
 626:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 629:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 630:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 634:	8b 55 0c             	mov    0xc(%ebp),%edx
 637:	8b 45 f0             	mov    -0x10(%ebp),%eax
 63a:	01 d0                	add    %edx,%eax
 63c:	0f b6 00             	movzbl (%eax),%eax
 63f:	84 c0                	test   %al,%al
 641:	0f 85 94 fe ff ff    	jne    4db <printf+0x22>
    }
  }
}
 647:	90                   	nop
 648:	c9                   	leave  
 649:	c3                   	ret    

0000064a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 64a:	55                   	push   %ebp
 64b:	89 e5                	mov    %esp,%ebp
 64d:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 650:	8b 45 08             	mov    0x8(%ebp),%eax
 653:	83 e8 08             	sub    $0x8,%eax
 656:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 659:	a1 20 0b 00 00       	mov    0xb20,%eax
 65e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 661:	eb 24                	jmp    687 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 663:	8b 45 fc             	mov    -0x4(%ebp),%eax
 666:	8b 00                	mov    (%eax),%eax
 668:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 66b:	77 12                	ja     67f <free+0x35>
 66d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 670:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 673:	77 24                	ja     699 <free+0x4f>
 675:	8b 45 fc             	mov    -0x4(%ebp),%eax
 678:	8b 00                	mov    (%eax),%eax
 67a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 67d:	77 1a                	ja     699 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 67f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 682:	8b 00                	mov    (%eax),%eax
 684:	89 45 fc             	mov    %eax,-0x4(%ebp)
 687:	8b 45 f8             	mov    -0x8(%ebp),%eax
 68a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 68d:	76 d4                	jbe    663 <free+0x19>
 68f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 692:	8b 00                	mov    (%eax),%eax
 694:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 697:	76 ca                	jbe    663 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 699:	8b 45 f8             	mov    -0x8(%ebp),%eax
 69c:	8b 40 04             	mov    0x4(%eax),%eax
 69f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a9:	01 c2                	add    %eax,%edx
 6ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ae:	8b 00                	mov    (%eax),%eax
 6b0:	39 c2                	cmp    %eax,%edx
 6b2:	75 24                	jne    6d8 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 6b4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b7:	8b 50 04             	mov    0x4(%eax),%edx
 6ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6bd:	8b 00                	mov    (%eax),%eax
 6bf:	8b 40 04             	mov    0x4(%eax),%eax
 6c2:	01 c2                	add    %eax,%edx
 6c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c7:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cd:	8b 00                	mov    (%eax),%eax
 6cf:	8b 10                	mov    (%eax),%edx
 6d1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d4:	89 10                	mov    %edx,(%eax)
 6d6:	eb 0a                	jmp    6e2 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6db:	8b 10                	mov    (%eax),%edx
 6dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e0:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e5:	8b 40 04             	mov    0x4(%eax),%eax
 6e8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f2:	01 d0                	add    %edx,%eax
 6f4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6f7:	75 20                	jne    719 <free+0xcf>
    p->s.size += bp->s.size;
 6f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fc:	8b 50 04             	mov    0x4(%eax),%edx
 6ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
 702:	8b 40 04             	mov    0x4(%eax),%eax
 705:	01 c2                	add    %eax,%edx
 707:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 70d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 710:	8b 10                	mov    (%eax),%edx
 712:	8b 45 fc             	mov    -0x4(%ebp),%eax
 715:	89 10                	mov    %edx,(%eax)
 717:	eb 08                	jmp    721 <free+0xd7>
  } else
    p->s.ptr = bp;
 719:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 71f:	89 10                	mov    %edx,(%eax)
  freep = p;
 721:	8b 45 fc             	mov    -0x4(%ebp),%eax
 724:	a3 20 0b 00 00       	mov    %eax,0xb20
}
 729:	90                   	nop
 72a:	c9                   	leave  
 72b:	c3                   	ret    

0000072c <morecore>:

static Header*
morecore(uint nu)
{
 72c:	55                   	push   %ebp
 72d:	89 e5                	mov    %esp,%ebp
 72f:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 732:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 739:	77 07                	ja     742 <morecore+0x16>
    nu = 4096;
 73b:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 742:	8b 45 08             	mov    0x8(%ebp),%eax
 745:	c1 e0 03             	shl    $0x3,%eax
 748:	83 ec 0c             	sub    $0xc,%esp
 74b:	50                   	push   %eax
 74c:	e8 79 fc ff ff       	call   3ca <sbrk>
 751:	83 c4 10             	add    $0x10,%esp
 754:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 757:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 75b:	75 07                	jne    764 <morecore+0x38>
    return 0;
 75d:	b8 00 00 00 00       	mov    $0x0,%eax
 762:	eb 26                	jmp    78a <morecore+0x5e>
  hp = (Header*)p;
 764:	8b 45 f4             	mov    -0xc(%ebp),%eax
 767:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 76a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 76d:	8b 55 08             	mov    0x8(%ebp),%edx
 770:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 773:	8b 45 f0             	mov    -0x10(%ebp),%eax
 776:	83 c0 08             	add    $0x8,%eax
 779:	83 ec 0c             	sub    $0xc,%esp
 77c:	50                   	push   %eax
 77d:	e8 c8 fe ff ff       	call   64a <free>
 782:	83 c4 10             	add    $0x10,%esp
  return freep;
 785:	a1 20 0b 00 00       	mov    0xb20,%eax
}
 78a:	c9                   	leave  
 78b:	c3                   	ret    

0000078c <malloc>:

void*
malloc(uint nbytes)
{
 78c:	55                   	push   %ebp
 78d:	89 e5                	mov    %esp,%ebp
 78f:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 792:	8b 45 08             	mov    0x8(%ebp),%eax
 795:	83 c0 07             	add    $0x7,%eax
 798:	c1 e8 03             	shr    $0x3,%eax
 79b:	83 c0 01             	add    $0x1,%eax
 79e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7a1:	a1 20 0b 00 00       	mov    0xb20,%eax
 7a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7ad:	75 23                	jne    7d2 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 7af:	c7 45 f0 18 0b 00 00 	movl   $0xb18,-0x10(%ebp)
 7b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b9:	a3 20 0b 00 00       	mov    %eax,0xb20
 7be:	a1 20 0b 00 00       	mov    0xb20,%eax
 7c3:	a3 18 0b 00 00       	mov    %eax,0xb18
    base.s.size = 0;
 7c8:	c7 05 1c 0b 00 00 00 	movl   $0x0,0xb1c
 7cf:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d5:	8b 00                	mov    (%eax),%eax
 7d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7da:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7dd:	8b 40 04             	mov    0x4(%eax),%eax
 7e0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7e3:	72 4d                	jb     832 <malloc+0xa6>
      if(p->s.size == nunits)
 7e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e8:	8b 40 04             	mov    0x4(%eax),%eax
 7eb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7ee:	75 0c                	jne    7fc <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f3:	8b 10                	mov    (%eax),%edx
 7f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7f8:	89 10                	mov    %edx,(%eax)
 7fa:	eb 26                	jmp    822 <malloc+0x96>
      else {
        p->s.size -= nunits;
 7fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ff:	8b 40 04             	mov    0x4(%eax),%eax
 802:	2b 45 ec             	sub    -0x14(%ebp),%eax
 805:	89 c2                	mov    %eax,%edx
 807:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80a:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 80d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 810:	8b 40 04             	mov    0x4(%eax),%eax
 813:	c1 e0 03             	shl    $0x3,%eax
 816:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 819:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81c:	8b 55 ec             	mov    -0x14(%ebp),%edx
 81f:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 822:	8b 45 f0             	mov    -0x10(%ebp),%eax
 825:	a3 20 0b 00 00       	mov    %eax,0xb20
      return (void*)(p + 1);
 82a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82d:	83 c0 08             	add    $0x8,%eax
 830:	eb 3b                	jmp    86d <malloc+0xe1>
    }
    if(p == freep)
 832:	a1 20 0b 00 00       	mov    0xb20,%eax
 837:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 83a:	75 1e                	jne    85a <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 83c:	83 ec 0c             	sub    $0xc,%esp
 83f:	ff 75 ec             	pushl  -0x14(%ebp)
 842:	e8 e5 fe ff ff       	call   72c <morecore>
 847:	83 c4 10             	add    $0x10,%esp
 84a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 84d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 851:	75 07                	jne    85a <malloc+0xce>
        return 0;
 853:	b8 00 00 00 00       	mov    $0x0,%eax
 858:	eb 13                	jmp    86d <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 85a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 860:	8b 45 f4             	mov    -0xc(%ebp),%eax
 863:	8b 00                	mov    (%eax),%eax
 865:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 868:	e9 6d ff ff ff       	jmp    7da <malloc+0x4e>
  }
}
 86d:	c9                   	leave  
 86e:	c3                   	ret    
