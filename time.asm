
_time:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
 *************************************************/

#include "types.h"
#include "user.h"

int main(int argc, char *argv[]) {
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
   f:	83 ec 20             	sub    $0x20,%esp
  12:	89 cb                	mov    %ecx,%ebx
	int runtime_1 = uptime();
  14:	e8 34 04 00 00       	call   44d <uptime>
  19:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int rc = fork();
  1c:	e8 8c 03 00 00       	call   3ad <fork>
  21:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(argc < 2) { printf(1, "time <executable>\n"); exit(); }
  24:	83 3b 01             	cmpl   $0x1,(%ebx)
  27:	7f 17                	jg     40 <main+0x40>
  29:	83 ec 08             	sub    $0x8,%esp
  2c:	68 e2 08 00 00       	push   $0x8e2
  31:	6a 01                	push   $0x1
  33:	e8 f4 04 00 00       	call   52c <printf>
  38:	83 c4 10             	add    $0x10,%esp
  3b:	e8 75 03 00 00       	call   3b5 <exit>
	
	if(rc<0){
  40:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  44:	79 17                	jns    5d <main+0x5d>
		printf(1,"fork() faild");
  46:	83 ec 08             	sub    $0x8,%esp
  49:	68 f5 08 00 00       	push   $0x8f5
  4e:	6a 01                	push   $0x1
  50:	e8 d7 04 00 00       	call   52c <printf>
  55:	83 c4 10             	add    $0x10,%esp
		exit();
  58:	e8 58 03 00 00       	call   3b5 <exit>
	}

	else if (rc>0){
  5d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  61:	0f 8e c5 00 00 00    	jle    12c <main+0x12c>
   // int pid = 0;
	 int runtime = 0;
  67:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    wait();
  6e:	e8 4a 03 00 00       	call   3bd <wait>
	 int runtime_2=uptime();
  73:	e8 d5 03 00 00       	call   44d <uptime>
  78:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	 runtime = runtime_2 - runtime_1;
  7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  7e:	2b 45 f0             	sub    -0x10(%ebp),%eax
  81:	89 45 e8             	mov    %eax,-0x18(%ebp)
    runtime = runtime *10;
  84:	8b 55 e8             	mov    -0x18(%ebp),%edx
  87:	89 d0                	mov    %edx,%eax
  89:	c1 e0 02             	shl    $0x2,%eax
  8c:	01 d0                	add    %edx,%eax
  8e:	01 c0                	add    %eax,%eax
  90:	89 45 e8             	mov    %eax,-0x18(%ebp)
	 for(int i = 1; i < argc; i++) { printf(1, "%s ", argv[i]); }
  93:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  9a:	eb 28                	jmp    c4 <main+0xc4>
  9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  9f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  a6:	8b 43 04             	mov    0x4(%ebx),%eax
  a9:	01 d0                	add    %edx,%eax
  ab:	8b 00                	mov    (%eax),%eax
  ad:	83 ec 04             	sub    $0x4,%esp
  b0:	50                   	push   %eax
  b1:	68 02 09 00 00       	push   $0x902
  b6:	6a 01                	push   $0x1
  b8:	e8 6f 04 00 00       	call   52c <printf>
  bd:	83 c4 10             	add    $0x10,%esp
  c0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  c7:	3b 03                	cmp    (%ebx),%eax
  c9:	7c d1                	jl     9c <main+0x9c>
   
	 printf(1, "(pid = %d): ",rc);
  cb:	83 ec 04             	sub    $0x4,%esp
  ce:	ff 75 ec             	pushl  -0x14(%ebp)
  d1:	68 06 09 00 00       	push   $0x906
  d6:	6a 01                	push   $0x1
  d8:	e8 4f 04 00 00       	call   52c <printf>
  dd:	83 c4 10             	add    $0x10,%esp
    printf(1, "runtime = %ds%dms\n", runtime/1000, runtime-runtime/1000);
  e0:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  e3:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  e8:	89 c8                	mov    %ecx,%eax
  ea:	f7 ea                	imul   %edx
  ec:	89 d0                	mov    %edx,%eax
  ee:	c1 f8 06             	sar    $0x6,%eax
  f1:	c1 f9 1f             	sar    $0x1f,%ecx
  f4:	89 ca                	mov    %ecx,%edx
  f6:	29 c2                	sub    %eax,%edx
  f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  fb:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
  fe:	8b 4d e8             	mov    -0x18(%ebp),%ecx
 101:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
 106:	89 c8                	mov    %ecx,%eax
 108:	f7 ea                	imul   %edx
 10a:	c1 fa 06             	sar    $0x6,%edx
 10d:	89 c8                	mov    %ecx,%eax
 10f:	c1 f8 1f             	sar    $0x1f,%eax
 112:	29 c2                	sub    %eax,%edx
 114:	89 d0                	mov    %edx,%eax
 116:	53                   	push   %ebx
 117:	50                   	push   %eax
 118:	68 13 09 00 00       	push   $0x913
 11d:	6a 01                	push   $0x1
 11f:	e8 08 04 00 00       	call   52c <printf>
 124:	83 c4 10             	add    $0x10,%esp
    exit();
 127:	e8 89 02 00 00       	call   3b5 <exit>
	}

	else {
		printf(1,"child process\n");
 12c:	83 ec 08             	sub    $0x8,%esp
 12f:	68 26 09 00 00       	push   $0x926
 134:	6a 01                	push   $0x1
 136:	e8 f1 03 00 00       	call   52c <printf>
 13b:	83 c4 10             	add    $0x10,%esp
		exec(argv[1],argv+1);
 13e:	8b 43 04             	mov    0x4(%ebx),%eax
 141:	8d 50 04             	lea    0x4(%eax),%edx
 144:	8b 43 04             	mov    0x4(%ebx),%eax
 147:	83 c0 04             	add    $0x4,%eax
 14a:	8b 00                	mov    (%eax),%eax
 14c:	83 ec 08             	sub    $0x8,%esp
 14f:	52                   	push   %edx
 150:	50                   	push   %eax
 151:	e8 97 02 00 00       	call   3ed <exec>
 156:	83 c4 10             	add    $0x10,%esp
		exit();
 159:	e8 57 02 00 00       	call   3b5 <exit>

0000015e <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 15e:	55                   	push   %ebp
 15f:	89 e5                	mov    %esp,%ebp
 161:	57                   	push   %edi
 162:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 163:	8b 4d 08             	mov    0x8(%ebp),%ecx
 166:	8b 55 10             	mov    0x10(%ebp),%edx
 169:	8b 45 0c             	mov    0xc(%ebp),%eax
 16c:	89 cb                	mov    %ecx,%ebx
 16e:	89 df                	mov    %ebx,%edi
 170:	89 d1                	mov    %edx,%ecx
 172:	fc                   	cld    
 173:	f3 aa                	rep stos %al,%es:(%edi)
 175:	89 ca                	mov    %ecx,%edx
 177:	89 fb                	mov    %edi,%ebx
 179:	89 5d 08             	mov    %ebx,0x8(%ebp)
 17c:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 17f:	90                   	nop
 180:	5b                   	pop    %ebx
 181:	5f                   	pop    %edi
 182:	5d                   	pop    %ebp
 183:	c3                   	ret    

00000184 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 184:	55                   	push   %ebp
 185:	89 e5                	mov    %esp,%ebp
 187:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 18a:	8b 45 08             	mov    0x8(%ebp),%eax
 18d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 190:	90                   	nop
 191:	8b 45 08             	mov    0x8(%ebp),%eax
 194:	8d 50 01             	lea    0x1(%eax),%edx
 197:	89 55 08             	mov    %edx,0x8(%ebp)
 19a:	8b 55 0c             	mov    0xc(%ebp),%edx
 19d:	8d 4a 01             	lea    0x1(%edx),%ecx
 1a0:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 1a3:	0f b6 12             	movzbl (%edx),%edx
 1a6:	88 10                	mov    %dl,(%eax)
 1a8:	0f b6 00             	movzbl (%eax),%eax
 1ab:	84 c0                	test   %al,%al
 1ad:	75 e2                	jne    191 <strcpy+0xd>
    ;
  return os;
 1af:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1b2:	c9                   	leave  
 1b3:	c3                   	ret    

000001b4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1b4:	55                   	push   %ebp
 1b5:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 1b7:	eb 08                	jmp    1c1 <strcmp+0xd>
    p++, q++;
 1b9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1bd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 1c1:	8b 45 08             	mov    0x8(%ebp),%eax
 1c4:	0f b6 00             	movzbl (%eax),%eax
 1c7:	84 c0                	test   %al,%al
 1c9:	74 10                	je     1db <strcmp+0x27>
 1cb:	8b 45 08             	mov    0x8(%ebp),%eax
 1ce:	0f b6 10             	movzbl (%eax),%edx
 1d1:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d4:	0f b6 00             	movzbl (%eax),%eax
 1d7:	38 c2                	cmp    %al,%dl
 1d9:	74 de                	je     1b9 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 1db:	8b 45 08             	mov    0x8(%ebp),%eax
 1de:	0f b6 00             	movzbl (%eax),%eax
 1e1:	0f b6 d0             	movzbl %al,%edx
 1e4:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e7:	0f b6 00             	movzbl (%eax),%eax
 1ea:	0f b6 c0             	movzbl %al,%eax
 1ed:	29 c2                	sub    %eax,%edx
 1ef:	89 d0                	mov    %edx,%eax
}
 1f1:	5d                   	pop    %ebp
 1f2:	c3                   	ret    

000001f3 <strlen>:

uint
strlen(char *s)
{
 1f3:	55                   	push   %ebp
 1f4:	89 e5                	mov    %esp,%ebp
 1f6:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1f9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 200:	eb 04                	jmp    206 <strlen+0x13>
 202:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 206:	8b 55 fc             	mov    -0x4(%ebp),%edx
 209:	8b 45 08             	mov    0x8(%ebp),%eax
 20c:	01 d0                	add    %edx,%eax
 20e:	0f b6 00             	movzbl (%eax),%eax
 211:	84 c0                	test   %al,%al
 213:	75 ed                	jne    202 <strlen+0xf>
    ;
  return n;
 215:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 218:	c9                   	leave  
 219:	c3                   	ret    

0000021a <memset>:

void*
memset(void *dst, int c, uint n)
{
 21a:	55                   	push   %ebp
 21b:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 21d:	8b 45 10             	mov    0x10(%ebp),%eax
 220:	50                   	push   %eax
 221:	ff 75 0c             	pushl  0xc(%ebp)
 224:	ff 75 08             	pushl  0x8(%ebp)
 227:	e8 32 ff ff ff       	call   15e <stosb>
 22c:	83 c4 0c             	add    $0xc,%esp
  return dst;
 22f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 232:	c9                   	leave  
 233:	c3                   	ret    

00000234 <strchr>:

char*
strchr(const char *s, char c)
{
 234:	55                   	push   %ebp
 235:	89 e5                	mov    %esp,%ebp
 237:	83 ec 04             	sub    $0x4,%esp
 23a:	8b 45 0c             	mov    0xc(%ebp),%eax
 23d:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 240:	eb 14                	jmp    256 <strchr+0x22>
    if(*s == c)
 242:	8b 45 08             	mov    0x8(%ebp),%eax
 245:	0f b6 00             	movzbl (%eax),%eax
 248:	3a 45 fc             	cmp    -0x4(%ebp),%al
 24b:	75 05                	jne    252 <strchr+0x1e>
      return (char*)s;
 24d:	8b 45 08             	mov    0x8(%ebp),%eax
 250:	eb 13                	jmp    265 <strchr+0x31>
  for(; *s; s++)
 252:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 256:	8b 45 08             	mov    0x8(%ebp),%eax
 259:	0f b6 00             	movzbl (%eax),%eax
 25c:	84 c0                	test   %al,%al
 25e:	75 e2                	jne    242 <strchr+0xe>
  return 0;
 260:	b8 00 00 00 00       	mov    $0x0,%eax
}
 265:	c9                   	leave  
 266:	c3                   	ret    

00000267 <gets>:

char*
gets(char *buf, int max)
{
 267:	55                   	push   %ebp
 268:	89 e5                	mov    %esp,%ebp
 26a:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 26d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 274:	eb 42                	jmp    2b8 <gets+0x51>
    cc = read(0, &c, 1);
 276:	83 ec 04             	sub    $0x4,%esp
 279:	6a 01                	push   $0x1
 27b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 27e:	50                   	push   %eax
 27f:	6a 00                	push   $0x0
 281:	e8 47 01 00 00       	call   3cd <read>
 286:	83 c4 10             	add    $0x10,%esp
 289:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 28c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 290:	7e 33                	jle    2c5 <gets+0x5e>
      break;
    buf[i++] = c;
 292:	8b 45 f4             	mov    -0xc(%ebp),%eax
 295:	8d 50 01             	lea    0x1(%eax),%edx
 298:	89 55 f4             	mov    %edx,-0xc(%ebp)
 29b:	89 c2                	mov    %eax,%edx
 29d:	8b 45 08             	mov    0x8(%ebp),%eax
 2a0:	01 c2                	add    %eax,%edx
 2a2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2a6:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 2a8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2ac:	3c 0a                	cmp    $0xa,%al
 2ae:	74 16                	je     2c6 <gets+0x5f>
 2b0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2b4:	3c 0d                	cmp    $0xd,%al
 2b6:	74 0e                	je     2c6 <gets+0x5f>
  for(i=0; i+1 < max; ){
 2b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2bb:	83 c0 01             	add    $0x1,%eax
 2be:	3b 45 0c             	cmp    0xc(%ebp),%eax
 2c1:	7c b3                	jl     276 <gets+0xf>
 2c3:	eb 01                	jmp    2c6 <gets+0x5f>
      break;
 2c5:	90                   	nop
      break;
  }
  buf[i] = '\0';
 2c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2c9:	8b 45 08             	mov    0x8(%ebp),%eax
 2cc:	01 d0                	add    %edx,%eax
 2ce:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2d1:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2d4:	c9                   	leave  
 2d5:	c3                   	ret    

000002d6 <stat>:

int
stat(char *n, struct stat *st)
{
 2d6:	55                   	push   %ebp
 2d7:	89 e5                	mov    %esp,%ebp
 2d9:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2dc:	83 ec 08             	sub    $0x8,%esp
 2df:	6a 00                	push   $0x0
 2e1:	ff 75 08             	pushl  0x8(%ebp)
 2e4:	e8 0c 01 00 00       	call   3f5 <open>
 2e9:	83 c4 10             	add    $0x10,%esp
 2ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2ef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2f3:	79 07                	jns    2fc <stat+0x26>
    return -1;
 2f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2fa:	eb 25                	jmp    321 <stat+0x4b>
  r = fstat(fd, st);
 2fc:	83 ec 08             	sub    $0x8,%esp
 2ff:	ff 75 0c             	pushl  0xc(%ebp)
 302:	ff 75 f4             	pushl  -0xc(%ebp)
 305:	e8 03 01 00 00       	call   40d <fstat>
 30a:	83 c4 10             	add    $0x10,%esp
 30d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 310:	83 ec 0c             	sub    $0xc,%esp
 313:	ff 75 f4             	pushl  -0xc(%ebp)
 316:	e8 c2 00 00 00       	call   3dd <close>
 31b:	83 c4 10             	add    $0x10,%esp
  return r;
 31e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 321:	c9                   	leave  
 322:	c3                   	ret    

00000323 <atoi>:

int
atoi(const char *s)
{
 323:	55                   	push   %ebp
 324:	89 e5                	mov    %esp,%ebp
 326:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 329:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 330:	eb 25                	jmp    357 <atoi+0x34>
    n = n*10 + *s++ - '0';
 332:	8b 55 fc             	mov    -0x4(%ebp),%edx
 335:	89 d0                	mov    %edx,%eax
 337:	c1 e0 02             	shl    $0x2,%eax
 33a:	01 d0                	add    %edx,%eax
 33c:	01 c0                	add    %eax,%eax
 33e:	89 c1                	mov    %eax,%ecx
 340:	8b 45 08             	mov    0x8(%ebp),%eax
 343:	8d 50 01             	lea    0x1(%eax),%edx
 346:	89 55 08             	mov    %edx,0x8(%ebp)
 349:	0f b6 00             	movzbl (%eax),%eax
 34c:	0f be c0             	movsbl %al,%eax
 34f:	01 c8                	add    %ecx,%eax
 351:	83 e8 30             	sub    $0x30,%eax
 354:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 357:	8b 45 08             	mov    0x8(%ebp),%eax
 35a:	0f b6 00             	movzbl (%eax),%eax
 35d:	3c 2f                	cmp    $0x2f,%al
 35f:	7e 0a                	jle    36b <atoi+0x48>
 361:	8b 45 08             	mov    0x8(%ebp),%eax
 364:	0f b6 00             	movzbl (%eax),%eax
 367:	3c 39                	cmp    $0x39,%al
 369:	7e c7                	jle    332 <atoi+0xf>
  return n;
 36b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 36e:	c9                   	leave  
 36f:	c3                   	ret    

00000370 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 370:	55                   	push   %ebp
 371:	89 e5                	mov    %esp,%ebp
 373:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 376:	8b 45 08             	mov    0x8(%ebp),%eax
 379:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 37c:	8b 45 0c             	mov    0xc(%ebp),%eax
 37f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 382:	eb 17                	jmp    39b <memmove+0x2b>
    *dst++ = *src++;
 384:	8b 45 fc             	mov    -0x4(%ebp),%eax
 387:	8d 50 01             	lea    0x1(%eax),%edx
 38a:	89 55 fc             	mov    %edx,-0x4(%ebp)
 38d:	8b 55 f8             	mov    -0x8(%ebp),%edx
 390:	8d 4a 01             	lea    0x1(%edx),%ecx
 393:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 396:	0f b6 12             	movzbl (%edx),%edx
 399:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 39b:	8b 45 10             	mov    0x10(%ebp),%eax
 39e:	8d 50 ff             	lea    -0x1(%eax),%edx
 3a1:	89 55 10             	mov    %edx,0x10(%ebp)
 3a4:	85 c0                	test   %eax,%eax
 3a6:	7f dc                	jg     384 <memmove+0x14>
  return vdst;
 3a8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3ab:	c9                   	leave  
 3ac:	c3                   	ret    

000003ad <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3ad:	b8 01 00 00 00       	mov    $0x1,%eax
 3b2:	cd 40                	int    $0x40
 3b4:	c3                   	ret    

000003b5 <exit>:
SYSCALL(exit)
 3b5:	b8 02 00 00 00       	mov    $0x2,%eax
 3ba:	cd 40                	int    $0x40
 3bc:	c3                   	ret    

000003bd <wait>:
SYSCALL(wait)
 3bd:	b8 03 00 00 00       	mov    $0x3,%eax
 3c2:	cd 40                	int    $0x40
 3c4:	c3                   	ret    

000003c5 <pipe>:
SYSCALL(pipe)
 3c5:	b8 04 00 00 00       	mov    $0x4,%eax
 3ca:	cd 40                	int    $0x40
 3cc:	c3                   	ret    

000003cd <read>:
SYSCALL(read)
 3cd:	b8 05 00 00 00       	mov    $0x5,%eax
 3d2:	cd 40                	int    $0x40
 3d4:	c3                   	ret    

000003d5 <write>:
SYSCALL(write)
 3d5:	b8 10 00 00 00       	mov    $0x10,%eax
 3da:	cd 40                	int    $0x40
 3dc:	c3                   	ret    

000003dd <close>:
SYSCALL(close)
 3dd:	b8 15 00 00 00       	mov    $0x15,%eax
 3e2:	cd 40                	int    $0x40
 3e4:	c3                   	ret    

000003e5 <kill>:
SYSCALL(kill)
 3e5:	b8 06 00 00 00       	mov    $0x6,%eax
 3ea:	cd 40                	int    $0x40
 3ec:	c3                   	ret    

000003ed <exec>:
SYSCALL(exec)
 3ed:	b8 07 00 00 00       	mov    $0x7,%eax
 3f2:	cd 40                	int    $0x40
 3f4:	c3                   	ret    

000003f5 <open>:
SYSCALL(open)
 3f5:	b8 0f 00 00 00       	mov    $0xf,%eax
 3fa:	cd 40                	int    $0x40
 3fc:	c3                   	ret    

000003fd <mknod>:
SYSCALL(mknod)
 3fd:	b8 11 00 00 00       	mov    $0x11,%eax
 402:	cd 40                	int    $0x40
 404:	c3                   	ret    

00000405 <unlink>:
SYSCALL(unlink)
 405:	b8 12 00 00 00       	mov    $0x12,%eax
 40a:	cd 40                	int    $0x40
 40c:	c3                   	ret    

0000040d <fstat>:
SYSCALL(fstat)
 40d:	b8 08 00 00 00       	mov    $0x8,%eax
 412:	cd 40                	int    $0x40
 414:	c3                   	ret    

00000415 <link>:
SYSCALL(link)
 415:	b8 13 00 00 00       	mov    $0x13,%eax
 41a:	cd 40                	int    $0x40
 41c:	c3                   	ret    

0000041d <mkdir>:
SYSCALL(mkdir)
 41d:	b8 14 00 00 00       	mov    $0x14,%eax
 422:	cd 40                	int    $0x40
 424:	c3                   	ret    

00000425 <chdir>:
SYSCALL(chdir)
 425:	b8 09 00 00 00       	mov    $0x9,%eax
 42a:	cd 40                	int    $0x40
 42c:	c3                   	ret    

0000042d <dup>:
SYSCALL(dup)
 42d:	b8 0a 00 00 00       	mov    $0xa,%eax
 432:	cd 40                	int    $0x40
 434:	c3                   	ret    

00000435 <getpid>:
SYSCALL(getpid)
 435:	b8 0b 00 00 00       	mov    $0xb,%eax
 43a:	cd 40                	int    $0x40
 43c:	c3                   	ret    

0000043d <sbrk>:
SYSCALL(sbrk)
 43d:	b8 0c 00 00 00       	mov    $0xc,%eax
 442:	cd 40                	int    $0x40
 444:	c3                   	ret    

00000445 <sleep>:
SYSCALL(sleep)
 445:	b8 0d 00 00 00       	mov    $0xd,%eax
 44a:	cd 40                	int    $0x40
 44c:	c3                   	ret    

0000044d <uptime>:
SYSCALL(uptime)
 44d:	b8 0e 00 00 00       	mov    $0xe,%eax
 452:	cd 40                	int    $0x40
 454:	c3                   	ret    

00000455 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 455:	55                   	push   %ebp
 456:	89 e5                	mov    %esp,%ebp
 458:	83 ec 18             	sub    $0x18,%esp
 45b:	8b 45 0c             	mov    0xc(%ebp),%eax
 45e:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 461:	83 ec 04             	sub    $0x4,%esp
 464:	6a 01                	push   $0x1
 466:	8d 45 f4             	lea    -0xc(%ebp),%eax
 469:	50                   	push   %eax
 46a:	ff 75 08             	pushl  0x8(%ebp)
 46d:	e8 63 ff ff ff       	call   3d5 <write>
 472:	83 c4 10             	add    $0x10,%esp
}
 475:	90                   	nop
 476:	c9                   	leave  
 477:	c3                   	ret    

00000478 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 478:	55                   	push   %ebp
 479:	89 e5                	mov    %esp,%ebp
 47b:	53                   	push   %ebx
 47c:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 47f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 486:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 48a:	74 17                	je     4a3 <printint+0x2b>
 48c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 490:	79 11                	jns    4a3 <printint+0x2b>
    neg = 1;
 492:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 499:	8b 45 0c             	mov    0xc(%ebp),%eax
 49c:	f7 d8                	neg    %eax
 49e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4a1:	eb 06                	jmp    4a9 <printint+0x31>
  } else {
    x = xx;
 4a3:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4b0:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 4b3:	8d 41 01             	lea    0x1(%ecx),%eax
 4b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 4b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4bf:	ba 00 00 00 00       	mov    $0x0,%edx
 4c4:	f7 f3                	div    %ebx
 4c6:	89 d0                	mov    %edx,%eax
 4c8:	0f b6 80 88 0b 00 00 	movzbl 0xb88(%eax),%eax
 4cf:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4d9:	ba 00 00 00 00       	mov    $0x0,%edx
 4de:	f7 f3                	div    %ebx
 4e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4e3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4e7:	75 c7                	jne    4b0 <printint+0x38>
  if(neg)
 4e9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4ed:	74 2d                	je     51c <printint+0xa4>
    buf[i++] = '-';
 4ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4f2:	8d 50 01             	lea    0x1(%eax),%edx
 4f5:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4f8:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4fd:	eb 1d                	jmp    51c <printint+0xa4>
    putc(fd, buf[i]);
 4ff:	8d 55 dc             	lea    -0x24(%ebp),%edx
 502:	8b 45 f4             	mov    -0xc(%ebp),%eax
 505:	01 d0                	add    %edx,%eax
 507:	0f b6 00             	movzbl (%eax),%eax
 50a:	0f be c0             	movsbl %al,%eax
 50d:	83 ec 08             	sub    $0x8,%esp
 510:	50                   	push   %eax
 511:	ff 75 08             	pushl  0x8(%ebp)
 514:	e8 3c ff ff ff       	call   455 <putc>
 519:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 51c:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 520:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 524:	79 d9                	jns    4ff <printint+0x87>
}
 526:	90                   	nop
 527:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 52a:	c9                   	leave  
 52b:	c3                   	ret    

0000052c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 52c:	55                   	push   %ebp
 52d:	89 e5                	mov    %esp,%ebp
 52f:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 532:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 539:	8d 45 0c             	lea    0xc(%ebp),%eax
 53c:	83 c0 04             	add    $0x4,%eax
 53f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 542:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 549:	e9 59 01 00 00       	jmp    6a7 <printf+0x17b>
    c = fmt[i] & 0xff;
 54e:	8b 55 0c             	mov    0xc(%ebp),%edx
 551:	8b 45 f0             	mov    -0x10(%ebp),%eax
 554:	01 d0                	add    %edx,%eax
 556:	0f b6 00             	movzbl (%eax),%eax
 559:	0f be c0             	movsbl %al,%eax
 55c:	25 ff 00 00 00       	and    $0xff,%eax
 561:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 564:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 568:	75 2c                	jne    596 <printf+0x6a>
      if(c == '%'){
 56a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 56e:	75 0c                	jne    57c <printf+0x50>
        state = '%';
 570:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 577:	e9 27 01 00 00       	jmp    6a3 <printf+0x177>
      } else {
        putc(fd, c);
 57c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 57f:	0f be c0             	movsbl %al,%eax
 582:	83 ec 08             	sub    $0x8,%esp
 585:	50                   	push   %eax
 586:	ff 75 08             	pushl  0x8(%ebp)
 589:	e8 c7 fe ff ff       	call   455 <putc>
 58e:	83 c4 10             	add    $0x10,%esp
 591:	e9 0d 01 00 00       	jmp    6a3 <printf+0x177>
      }
    } else if(state == '%'){
 596:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 59a:	0f 85 03 01 00 00    	jne    6a3 <printf+0x177>
      if(c == 'd'){
 5a0:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5a4:	75 1e                	jne    5c4 <printf+0x98>
        printint(fd, *ap, 10, 1);
 5a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5a9:	8b 00                	mov    (%eax),%eax
 5ab:	6a 01                	push   $0x1
 5ad:	6a 0a                	push   $0xa
 5af:	50                   	push   %eax
 5b0:	ff 75 08             	pushl  0x8(%ebp)
 5b3:	e8 c0 fe ff ff       	call   478 <printint>
 5b8:	83 c4 10             	add    $0x10,%esp
        ap++;
 5bb:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5bf:	e9 d8 00 00 00       	jmp    69c <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 5c4:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5c8:	74 06                	je     5d0 <printf+0xa4>
 5ca:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5ce:	75 1e                	jne    5ee <printf+0xc2>
        printint(fd, *ap, 16, 0);
 5d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5d3:	8b 00                	mov    (%eax),%eax
 5d5:	6a 00                	push   $0x0
 5d7:	6a 10                	push   $0x10
 5d9:	50                   	push   %eax
 5da:	ff 75 08             	pushl  0x8(%ebp)
 5dd:	e8 96 fe ff ff       	call   478 <printint>
 5e2:	83 c4 10             	add    $0x10,%esp
        ap++;
 5e5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5e9:	e9 ae 00 00 00       	jmp    69c <printf+0x170>
      } else if(c == 's'){
 5ee:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5f2:	75 43                	jne    637 <printf+0x10b>
        s = (char*)*ap;
 5f4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5f7:	8b 00                	mov    (%eax),%eax
 5f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5fc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 600:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 604:	75 25                	jne    62b <printf+0xff>
          s = "(null)";
 606:	c7 45 f4 35 09 00 00 	movl   $0x935,-0xc(%ebp)
        while(*s != 0){
 60d:	eb 1c                	jmp    62b <printf+0xff>
          putc(fd, *s);
 60f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 612:	0f b6 00             	movzbl (%eax),%eax
 615:	0f be c0             	movsbl %al,%eax
 618:	83 ec 08             	sub    $0x8,%esp
 61b:	50                   	push   %eax
 61c:	ff 75 08             	pushl  0x8(%ebp)
 61f:	e8 31 fe ff ff       	call   455 <putc>
 624:	83 c4 10             	add    $0x10,%esp
          s++;
 627:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 62b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 62e:	0f b6 00             	movzbl (%eax),%eax
 631:	84 c0                	test   %al,%al
 633:	75 da                	jne    60f <printf+0xe3>
 635:	eb 65                	jmp    69c <printf+0x170>
        }
      } else if(c == 'c'){
 637:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 63b:	75 1d                	jne    65a <printf+0x12e>
        putc(fd, *ap);
 63d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 640:	8b 00                	mov    (%eax),%eax
 642:	0f be c0             	movsbl %al,%eax
 645:	83 ec 08             	sub    $0x8,%esp
 648:	50                   	push   %eax
 649:	ff 75 08             	pushl  0x8(%ebp)
 64c:	e8 04 fe ff ff       	call   455 <putc>
 651:	83 c4 10             	add    $0x10,%esp
        ap++;
 654:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 658:	eb 42                	jmp    69c <printf+0x170>
      } else if(c == '%'){
 65a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 65e:	75 17                	jne    677 <printf+0x14b>
        putc(fd, c);
 660:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 663:	0f be c0             	movsbl %al,%eax
 666:	83 ec 08             	sub    $0x8,%esp
 669:	50                   	push   %eax
 66a:	ff 75 08             	pushl  0x8(%ebp)
 66d:	e8 e3 fd ff ff       	call   455 <putc>
 672:	83 c4 10             	add    $0x10,%esp
 675:	eb 25                	jmp    69c <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 677:	83 ec 08             	sub    $0x8,%esp
 67a:	6a 25                	push   $0x25
 67c:	ff 75 08             	pushl  0x8(%ebp)
 67f:	e8 d1 fd ff ff       	call   455 <putc>
 684:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 687:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 68a:	0f be c0             	movsbl %al,%eax
 68d:	83 ec 08             	sub    $0x8,%esp
 690:	50                   	push   %eax
 691:	ff 75 08             	pushl  0x8(%ebp)
 694:	e8 bc fd ff ff       	call   455 <putc>
 699:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 69c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 6a3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6a7:	8b 55 0c             	mov    0xc(%ebp),%edx
 6aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6ad:	01 d0                	add    %edx,%eax
 6af:	0f b6 00             	movzbl (%eax),%eax
 6b2:	84 c0                	test   %al,%al
 6b4:	0f 85 94 fe ff ff    	jne    54e <printf+0x22>
    }
  }
}
 6ba:	90                   	nop
 6bb:	c9                   	leave  
 6bc:	c3                   	ret    

000006bd <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6bd:	55                   	push   %ebp
 6be:	89 e5                	mov    %esp,%ebp
 6c0:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6c3:	8b 45 08             	mov    0x8(%ebp),%eax
 6c6:	83 e8 08             	sub    $0x8,%eax
 6c9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6cc:	a1 a4 0b 00 00       	mov    0xba4,%eax
 6d1:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6d4:	eb 24                	jmp    6fa <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d9:	8b 00                	mov    (%eax),%eax
 6db:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6de:	77 12                	ja     6f2 <free+0x35>
 6e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e3:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6e6:	77 24                	ja     70c <free+0x4f>
 6e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6eb:	8b 00                	mov    (%eax),%eax
 6ed:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6f0:	77 1a                	ja     70c <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f5:	8b 00                	mov    (%eax),%eax
 6f7:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6fa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6fd:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 700:	76 d4                	jbe    6d6 <free+0x19>
 702:	8b 45 fc             	mov    -0x4(%ebp),%eax
 705:	8b 00                	mov    (%eax),%eax
 707:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 70a:	76 ca                	jbe    6d6 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 70c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 70f:	8b 40 04             	mov    0x4(%eax),%eax
 712:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 719:	8b 45 f8             	mov    -0x8(%ebp),%eax
 71c:	01 c2                	add    %eax,%edx
 71e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 721:	8b 00                	mov    (%eax),%eax
 723:	39 c2                	cmp    %eax,%edx
 725:	75 24                	jne    74b <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 727:	8b 45 f8             	mov    -0x8(%ebp),%eax
 72a:	8b 50 04             	mov    0x4(%eax),%edx
 72d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 730:	8b 00                	mov    (%eax),%eax
 732:	8b 40 04             	mov    0x4(%eax),%eax
 735:	01 c2                	add    %eax,%edx
 737:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73a:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 73d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 740:	8b 00                	mov    (%eax),%eax
 742:	8b 10                	mov    (%eax),%edx
 744:	8b 45 f8             	mov    -0x8(%ebp),%eax
 747:	89 10                	mov    %edx,(%eax)
 749:	eb 0a                	jmp    755 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 74b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74e:	8b 10                	mov    (%eax),%edx
 750:	8b 45 f8             	mov    -0x8(%ebp),%eax
 753:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 755:	8b 45 fc             	mov    -0x4(%ebp),%eax
 758:	8b 40 04             	mov    0x4(%eax),%eax
 75b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 762:	8b 45 fc             	mov    -0x4(%ebp),%eax
 765:	01 d0                	add    %edx,%eax
 767:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 76a:	75 20                	jne    78c <free+0xcf>
    p->s.size += bp->s.size;
 76c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76f:	8b 50 04             	mov    0x4(%eax),%edx
 772:	8b 45 f8             	mov    -0x8(%ebp),%eax
 775:	8b 40 04             	mov    0x4(%eax),%eax
 778:	01 c2                	add    %eax,%edx
 77a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77d:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 780:	8b 45 f8             	mov    -0x8(%ebp),%eax
 783:	8b 10                	mov    (%eax),%edx
 785:	8b 45 fc             	mov    -0x4(%ebp),%eax
 788:	89 10                	mov    %edx,(%eax)
 78a:	eb 08                	jmp    794 <free+0xd7>
  } else
    p->s.ptr = bp;
 78c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 792:	89 10                	mov    %edx,(%eax)
  freep = p;
 794:	8b 45 fc             	mov    -0x4(%ebp),%eax
 797:	a3 a4 0b 00 00       	mov    %eax,0xba4
}
 79c:	90                   	nop
 79d:	c9                   	leave  
 79e:	c3                   	ret    

0000079f <morecore>:

static Header*
morecore(uint nu)
{
 79f:	55                   	push   %ebp
 7a0:	89 e5                	mov    %esp,%ebp
 7a2:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7a5:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7ac:	77 07                	ja     7b5 <morecore+0x16>
    nu = 4096;
 7ae:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7b5:	8b 45 08             	mov    0x8(%ebp),%eax
 7b8:	c1 e0 03             	shl    $0x3,%eax
 7bb:	83 ec 0c             	sub    $0xc,%esp
 7be:	50                   	push   %eax
 7bf:	e8 79 fc ff ff       	call   43d <sbrk>
 7c4:	83 c4 10             	add    $0x10,%esp
 7c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7ca:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7ce:	75 07                	jne    7d7 <morecore+0x38>
    return 0;
 7d0:	b8 00 00 00 00       	mov    $0x0,%eax
 7d5:	eb 26                	jmp    7fd <morecore+0x5e>
  hp = (Header*)p;
 7d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7da:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e0:	8b 55 08             	mov    0x8(%ebp),%edx
 7e3:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e9:	83 c0 08             	add    $0x8,%eax
 7ec:	83 ec 0c             	sub    $0xc,%esp
 7ef:	50                   	push   %eax
 7f0:	e8 c8 fe ff ff       	call   6bd <free>
 7f5:	83 c4 10             	add    $0x10,%esp
  return freep;
 7f8:	a1 a4 0b 00 00       	mov    0xba4,%eax
}
 7fd:	c9                   	leave  
 7fe:	c3                   	ret    

000007ff <malloc>:

void*
malloc(uint nbytes)
{
 7ff:	55                   	push   %ebp
 800:	89 e5                	mov    %esp,%ebp
 802:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 805:	8b 45 08             	mov    0x8(%ebp),%eax
 808:	83 c0 07             	add    $0x7,%eax
 80b:	c1 e8 03             	shr    $0x3,%eax
 80e:	83 c0 01             	add    $0x1,%eax
 811:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 814:	a1 a4 0b 00 00       	mov    0xba4,%eax
 819:	89 45 f0             	mov    %eax,-0x10(%ebp)
 81c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 820:	75 23                	jne    845 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 822:	c7 45 f0 9c 0b 00 00 	movl   $0xb9c,-0x10(%ebp)
 829:	8b 45 f0             	mov    -0x10(%ebp),%eax
 82c:	a3 a4 0b 00 00       	mov    %eax,0xba4
 831:	a1 a4 0b 00 00       	mov    0xba4,%eax
 836:	a3 9c 0b 00 00       	mov    %eax,0xb9c
    base.s.size = 0;
 83b:	c7 05 a0 0b 00 00 00 	movl   $0x0,0xba0
 842:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 845:	8b 45 f0             	mov    -0x10(%ebp),%eax
 848:	8b 00                	mov    (%eax),%eax
 84a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 84d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 850:	8b 40 04             	mov    0x4(%eax),%eax
 853:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 856:	72 4d                	jb     8a5 <malloc+0xa6>
      if(p->s.size == nunits)
 858:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85b:	8b 40 04             	mov    0x4(%eax),%eax
 85e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 861:	75 0c                	jne    86f <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 863:	8b 45 f4             	mov    -0xc(%ebp),%eax
 866:	8b 10                	mov    (%eax),%edx
 868:	8b 45 f0             	mov    -0x10(%ebp),%eax
 86b:	89 10                	mov    %edx,(%eax)
 86d:	eb 26                	jmp    895 <malloc+0x96>
      else {
        p->s.size -= nunits;
 86f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 872:	8b 40 04             	mov    0x4(%eax),%eax
 875:	2b 45 ec             	sub    -0x14(%ebp),%eax
 878:	89 c2                	mov    %eax,%edx
 87a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 880:	8b 45 f4             	mov    -0xc(%ebp),%eax
 883:	8b 40 04             	mov    0x4(%eax),%eax
 886:	c1 e0 03             	shl    $0x3,%eax
 889:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 88c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 892:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 895:	8b 45 f0             	mov    -0x10(%ebp),%eax
 898:	a3 a4 0b 00 00       	mov    %eax,0xba4
      return (void*)(p + 1);
 89d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a0:	83 c0 08             	add    $0x8,%eax
 8a3:	eb 3b                	jmp    8e0 <malloc+0xe1>
    }
    if(p == freep)
 8a5:	a1 a4 0b 00 00       	mov    0xba4,%eax
 8aa:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8ad:	75 1e                	jne    8cd <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 8af:	83 ec 0c             	sub    $0xc,%esp
 8b2:	ff 75 ec             	pushl  -0x14(%ebp)
 8b5:	e8 e5 fe ff ff       	call   79f <morecore>
 8ba:	83 c4 10             	add    $0x10,%esp
 8bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8c4:	75 07                	jne    8cd <malloc+0xce>
        return 0;
 8c6:	b8 00 00 00 00       	mov    $0x0,%eax
 8cb:	eb 13                	jmp    8e0 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d6:	8b 00                	mov    (%eax),%eax
 8d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8db:	e9 6d ff ff ff       	jmp    84d <malloc+0x4e>
  }
}
 8e0:	c9                   	leave  
 8e1:	c3                   	ret    
