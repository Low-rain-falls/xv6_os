
user/_trace:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user/user.h"

int main (int argc, char* argv[]) {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
    if (argc < 3) {
   8:	4789                	li	a5,2
   a:	00a7c663          	blt	a5,a0,16 <main+0x16>
   e:	e426                	sd	s1,8(sp)
        exit(0);
  10:	4501                	li	a0,0
  12:	28c000ef          	jal	29e <exit>
  16:	e426                	sd	s1,8(sp)
  18:	84ae                	mv	s1,a1
    }

    int mask = atoi(argv[1]);
  1a:	6588                	ld	a0,8(a1)
  1c:	18c000ef          	jal	1a8 <atoi>
    trace(mask);
  20:	32e000ef          	jal	34e <trace>

    exec(argv[2], &argv[2]);
  24:	01048593          	addi	a1,s1,16
  28:	6888                	ld	a0,16(s1)
  2a:	2ac000ef          	jal	2d6 <exec>
    exit(0);
  2e:	4501                	li	a0,0
  30:	26e000ef          	jal	29e <exit>

0000000000000034 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
  34:	1141                	addi	sp,sp,-16
  36:	e406                	sd	ra,8(sp)
  38:	e022                	sd	s0,0(sp)
  3a:	0800                	addi	s0,sp,16
  extern int main();
  main();
  3c:	fc5ff0ef          	jal	0 <main>
  exit(0);
  40:	4501                	li	a0,0
  42:	25c000ef          	jal	29e <exit>

0000000000000046 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  46:	1141                	addi	sp,sp,-16
  48:	e422                	sd	s0,8(sp)
  4a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  4c:	87aa                	mv	a5,a0
  4e:	0585                	addi	a1,a1,1
  50:	0785                	addi	a5,a5,1
  52:	fff5c703          	lbu	a4,-1(a1)
  56:	fee78fa3          	sb	a4,-1(a5)
  5a:	fb75                	bnez	a4,4e <strcpy+0x8>
    ;
  return os;
}
  5c:	6422                	ld	s0,8(sp)
  5e:	0141                	addi	sp,sp,16
  60:	8082                	ret

0000000000000062 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  62:	1141                	addi	sp,sp,-16
  64:	e422                	sd	s0,8(sp)
  66:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  68:	00054783          	lbu	a5,0(a0)
  6c:	cb91                	beqz	a5,80 <strcmp+0x1e>
  6e:	0005c703          	lbu	a4,0(a1)
  72:	00f71763          	bne	a4,a5,80 <strcmp+0x1e>
    p++, q++;
  76:	0505                	addi	a0,a0,1
  78:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  7a:	00054783          	lbu	a5,0(a0)
  7e:	fbe5                	bnez	a5,6e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  80:	0005c503          	lbu	a0,0(a1)
}
  84:	40a7853b          	subw	a0,a5,a0
  88:	6422                	ld	s0,8(sp)
  8a:	0141                	addi	sp,sp,16
  8c:	8082                	ret

000000000000008e <strlen>:

uint
strlen(const char *s)
{
  8e:	1141                	addi	sp,sp,-16
  90:	e422                	sd	s0,8(sp)
  92:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  94:	00054783          	lbu	a5,0(a0)
  98:	cf91                	beqz	a5,b4 <strlen+0x26>
  9a:	0505                	addi	a0,a0,1
  9c:	87aa                	mv	a5,a0
  9e:	86be                	mv	a3,a5
  a0:	0785                	addi	a5,a5,1
  a2:	fff7c703          	lbu	a4,-1(a5)
  a6:	ff65                	bnez	a4,9e <strlen+0x10>
  a8:	40a6853b          	subw	a0,a3,a0
  ac:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  ae:	6422                	ld	s0,8(sp)
  b0:	0141                	addi	sp,sp,16
  b2:	8082                	ret
  for(n = 0; s[n]; n++)
  b4:	4501                	li	a0,0
  b6:	bfe5                	j	ae <strlen+0x20>

00000000000000b8 <memset>:

void*
memset(void *dst, int c, uint n)
{
  b8:	1141                	addi	sp,sp,-16
  ba:	e422                	sd	s0,8(sp)
  bc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  be:	ca19                	beqz	a2,d4 <memset+0x1c>
  c0:	87aa                	mv	a5,a0
  c2:	1602                	slli	a2,a2,0x20
  c4:	9201                	srli	a2,a2,0x20
  c6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  ca:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  ce:	0785                	addi	a5,a5,1
  d0:	fee79de3          	bne	a5,a4,ca <memset+0x12>
  }
  return dst;
}
  d4:	6422                	ld	s0,8(sp)
  d6:	0141                	addi	sp,sp,16
  d8:	8082                	ret

00000000000000da <strchr>:

char*
strchr(const char *s, char c)
{
  da:	1141                	addi	sp,sp,-16
  dc:	e422                	sd	s0,8(sp)
  de:	0800                	addi	s0,sp,16
  for(; *s; s++)
  e0:	00054783          	lbu	a5,0(a0)
  e4:	cb99                	beqz	a5,fa <strchr+0x20>
    if(*s == c)
  e6:	00f58763          	beq	a1,a5,f4 <strchr+0x1a>
  for(; *s; s++)
  ea:	0505                	addi	a0,a0,1
  ec:	00054783          	lbu	a5,0(a0)
  f0:	fbfd                	bnez	a5,e6 <strchr+0xc>
      return (char*)s;
  return 0;
  f2:	4501                	li	a0,0
}
  f4:	6422                	ld	s0,8(sp)
  f6:	0141                	addi	sp,sp,16
  f8:	8082                	ret
  return 0;
  fa:	4501                	li	a0,0
  fc:	bfe5                	j	f4 <strchr+0x1a>

00000000000000fe <gets>:

char*
gets(char *buf, int max)
{
  fe:	711d                	addi	sp,sp,-96
 100:	ec86                	sd	ra,88(sp)
 102:	e8a2                	sd	s0,80(sp)
 104:	e4a6                	sd	s1,72(sp)
 106:	e0ca                	sd	s2,64(sp)
 108:	fc4e                	sd	s3,56(sp)
 10a:	f852                	sd	s4,48(sp)
 10c:	f456                	sd	s5,40(sp)
 10e:	f05a                	sd	s6,32(sp)
 110:	ec5e                	sd	s7,24(sp)
 112:	1080                	addi	s0,sp,96
 114:	8baa                	mv	s7,a0
 116:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 118:	892a                	mv	s2,a0
 11a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 11c:	4aa9                	li	s5,10
 11e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 120:	89a6                	mv	s3,s1
 122:	2485                	addiw	s1,s1,1
 124:	0344d663          	bge	s1,s4,150 <gets+0x52>
    cc = read(0, &c, 1);
 128:	4605                	li	a2,1
 12a:	faf40593          	addi	a1,s0,-81
 12e:	4501                	li	a0,0
 130:	186000ef          	jal	2b6 <read>
    if(cc < 1)
 134:	00a05e63          	blez	a0,150 <gets+0x52>
    buf[i++] = c;
 138:	faf44783          	lbu	a5,-81(s0)
 13c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 140:	01578763          	beq	a5,s5,14e <gets+0x50>
 144:	0905                	addi	s2,s2,1
 146:	fd679de3          	bne	a5,s6,120 <gets+0x22>
    buf[i++] = c;
 14a:	89a6                	mv	s3,s1
 14c:	a011                	j	150 <gets+0x52>
 14e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 150:	99de                	add	s3,s3,s7
 152:	00098023          	sb	zero,0(s3)
  return buf;
}
 156:	855e                	mv	a0,s7
 158:	60e6                	ld	ra,88(sp)
 15a:	6446                	ld	s0,80(sp)
 15c:	64a6                	ld	s1,72(sp)
 15e:	6906                	ld	s2,64(sp)
 160:	79e2                	ld	s3,56(sp)
 162:	7a42                	ld	s4,48(sp)
 164:	7aa2                	ld	s5,40(sp)
 166:	7b02                	ld	s6,32(sp)
 168:	6be2                	ld	s7,24(sp)
 16a:	6125                	addi	sp,sp,96
 16c:	8082                	ret

000000000000016e <stat>:

int
stat(const char *n, struct stat *st)
{
 16e:	1101                	addi	sp,sp,-32
 170:	ec06                	sd	ra,24(sp)
 172:	e822                	sd	s0,16(sp)
 174:	e04a                	sd	s2,0(sp)
 176:	1000                	addi	s0,sp,32
 178:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 17a:	4581                	li	a1,0
 17c:	162000ef          	jal	2de <open>
  if(fd < 0)
 180:	02054263          	bltz	a0,1a4 <stat+0x36>
 184:	e426                	sd	s1,8(sp)
 186:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 188:	85ca                	mv	a1,s2
 18a:	16c000ef          	jal	2f6 <fstat>
 18e:	892a                	mv	s2,a0
  close(fd);
 190:	8526                	mv	a0,s1
 192:	134000ef          	jal	2c6 <close>
  return r;
 196:	64a2                	ld	s1,8(sp)
}
 198:	854a                	mv	a0,s2
 19a:	60e2                	ld	ra,24(sp)
 19c:	6442                	ld	s0,16(sp)
 19e:	6902                	ld	s2,0(sp)
 1a0:	6105                	addi	sp,sp,32
 1a2:	8082                	ret
    return -1;
 1a4:	597d                	li	s2,-1
 1a6:	bfcd                	j	198 <stat+0x2a>

00000000000001a8 <atoi>:

int
atoi(const char *s)
{
 1a8:	1141                	addi	sp,sp,-16
 1aa:	e422                	sd	s0,8(sp)
 1ac:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1ae:	00054683          	lbu	a3,0(a0)
 1b2:	fd06879b          	addiw	a5,a3,-48
 1b6:	0ff7f793          	zext.b	a5,a5
 1ba:	4625                	li	a2,9
 1bc:	02f66863          	bltu	a2,a5,1ec <atoi+0x44>
 1c0:	872a                	mv	a4,a0
  n = 0;
 1c2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1c4:	0705                	addi	a4,a4,1
 1c6:	0025179b          	slliw	a5,a0,0x2
 1ca:	9fa9                	addw	a5,a5,a0
 1cc:	0017979b          	slliw	a5,a5,0x1
 1d0:	9fb5                	addw	a5,a5,a3
 1d2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1d6:	00074683          	lbu	a3,0(a4)
 1da:	fd06879b          	addiw	a5,a3,-48
 1de:	0ff7f793          	zext.b	a5,a5
 1e2:	fef671e3          	bgeu	a2,a5,1c4 <atoi+0x1c>
  return n;
}
 1e6:	6422                	ld	s0,8(sp)
 1e8:	0141                	addi	sp,sp,16
 1ea:	8082                	ret
  n = 0;
 1ec:	4501                	li	a0,0
 1ee:	bfe5                	j	1e6 <atoi+0x3e>

00000000000001f0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1f0:	1141                	addi	sp,sp,-16
 1f2:	e422                	sd	s0,8(sp)
 1f4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1f6:	02b57463          	bgeu	a0,a1,21e <memmove+0x2e>
    while(n-- > 0)
 1fa:	00c05f63          	blez	a2,218 <memmove+0x28>
 1fe:	1602                	slli	a2,a2,0x20
 200:	9201                	srli	a2,a2,0x20
 202:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 206:	872a                	mv	a4,a0
      *dst++ = *src++;
 208:	0585                	addi	a1,a1,1
 20a:	0705                	addi	a4,a4,1
 20c:	fff5c683          	lbu	a3,-1(a1)
 210:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 214:	fef71ae3          	bne	a4,a5,208 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 218:	6422                	ld	s0,8(sp)
 21a:	0141                	addi	sp,sp,16
 21c:	8082                	ret
    dst += n;
 21e:	00c50733          	add	a4,a0,a2
    src += n;
 222:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 224:	fec05ae3          	blez	a2,218 <memmove+0x28>
 228:	fff6079b          	addiw	a5,a2,-1
 22c:	1782                	slli	a5,a5,0x20
 22e:	9381                	srli	a5,a5,0x20
 230:	fff7c793          	not	a5,a5
 234:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 236:	15fd                	addi	a1,a1,-1
 238:	177d                	addi	a4,a4,-1
 23a:	0005c683          	lbu	a3,0(a1)
 23e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 242:	fee79ae3          	bne	a5,a4,236 <memmove+0x46>
 246:	bfc9                	j	218 <memmove+0x28>

0000000000000248 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 248:	1141                	addi	sp,sp,-16
 24a:	e422                	sd	s0,8(sp)
 24c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 24e:	ca05                	beqz	a2,27e <memcmp+0x36>
 250:	fff6069b          	addiw	a3,a2,-1
 254:	1682                	slli	a3,a3,0x20
 256:	9281                	srli	a3,a3,0x20
 258:	0685                	addi	a3,a3,1
 25a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 25c:	00054783          	lbu	a5,0(a0)
 260:	0005c703          	lbu	a4,0(a1)
 264:	00e79863          	bne	a5,a4,274 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 268:	0505                	addi	a0,a0,1
    p2++;
 26a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 26c:	fed518e3          	bne	a0,a3,25c <memcmp+0x14>
  }
  return 0;
 270:	4501                	li	a0,0
 272:	a019                	j	278 <memcmp+0x30>
      return *p1 - *p2;
 274:	40e7853b          	subw	a0,a5,a4
}
 278:	6422                	ld	s0,8(sp)
 27a:	0141                	addi	sp,sp,16
 27c:	8082                	ret
  return 0;
 27e:	4501                	li	a0,0
 280:	bfe5                	j	278 <memcmp+0x30>

0000000000000282 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 282:	1141                	addi	sp,sp,-16
 284:	e406                	sd	ra,8(sp)
 286:	e022                	sd	s0,0(sp)
 288:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 28a:	f67ff0ef          	jal	1f0 <memmove>
}
 28e:	60a2                	ld	ra,8(sp)
 290:	6402                	ld	s0,0(sp)
 292:	0141                	addi	sp,sp,16
 294:	8082                	ret

0000000000000296 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 296:	4885                	li	a7,1
 ecall
 298:	00000073          	ecall
 ret
 29c:	8082                	ret

000000000000029e <exit>:
.global exit
exit:
 li a7, SYS_exit
 29e:	4889                	li	a7,2
 ecall
 2a0:	00000073          	ecall
 ret
 2a4:	8082                	ret

00000000000002a6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2a6:	488d                	li	a7,3
 ecall
 2a8:	00000073          	ecall
 ret
 2ac:	8082                	ret

00000000000002ae <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2ae:	4891                	li	a7,4
 ecall
 2b0:	00000073          	ecall
 ret
 2b4:	8082                	ret

00000000000002b6 <read>:
.global read
read:
 li a7, SYS_read
 2b6:	4895                	li	a7,5
 ecall
 2b8:	00000073          	ecall
 ret
 2bc:	8082                	ret

00000000000002be <write>:
.global write
write:
 li a7, SYS_write
 2be:	48c1                	li	a7,16
 ecall
 2c0:	00000073          	ecall
 ret
 2c4:	8082                	ret

00000000000002c6 <close>:
.global close
close:
 li a7, SYS_close
 2c6:	48d5                	li	a7,21
 ecall
 2c8:	00000073          	ecall
 ret
 2cc:	8082                	ret

00000000000002ce <kill>:
.global kill
kill:
 li a7, SYS_kill
 2ce:	4899                	li	a7,6
 ecall
 2d0:	00000073          	ecall
 ret
 2d4:	8082                	ret

00000000000002d6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 2d6:	489d                	li	a7,7
 ecall
 2d8:	00000073          	ecall
 ret
 2dc:	8082                	ret

00000000000002de <open>:
.global open
open:
 li a7, SYS_open
 2de:	48bd                	li	a7,15
 ecall
 2e0:	00000073          	ecall
 ret
 2e4:	8082                	ret

00000000000002e6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2e6:	48c5                	li	a7,17
 ecall
 2e8:	00000073          	ecall
 ret
 2ec:	8082                	ret

00000000000002ee <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 2ee:	48c9                	li	a7,18
 ecall
 2f0:	00000073          	ecall
 ret
 2f4:	8082                	ret

00000000000002f6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 2f6:	48a1                	li	a7,8
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <link>:
.global link
link:
 li a7, SYS_link
 2fe:	48cd                	li	a7,19
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 306:	48d1                	li	a7,20
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 30e:	48a5                	li	a7,9
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <dup>:
.global dup
dup:
 li a7, SYS_dup
 316:	48a9                	li	a7,10
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 31e:	48ad                	li	a7,11
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 326:	48b1                	li	a7,12
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 32e:	48b5                	li	a7,13
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 336:	48b9                	li	a7,14
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <hello>:
.global hello
hello:
 li a7, SYS_hello
 33e:	48d9                	li	a7,22
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <xv6>:
.global xv6
xv6:
 li a7, SYS_xv6
 346:	48dd                	li	a7,23
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <trace>:
.global trace
trace:
 li a7, SYS_trace
 34e:	48e1                	li	a7,24
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 356:	1101                	addi	sp,sp,-32
 358:	ec06                	sd	ra,24(sp)
 35a:	e822                	sd	s0,16(sp)
 35c:	1000                	addi	s0,sp,32
 35e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 362:	4605                	li	a2,1
 364:	fef40593          	addi	a1,s0,-17
 368:	f57ff0ef          	jal	2be <write>
}
 36c:	60e2                	ld	ra,24(sp)
 36e:	6442                	ld	s0,16(sp)
 370:	6105                	addi	sp,sp,32
 372:	8082                	ret

0000000000000374 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 374:	7139                	addi	sp,sp,-64
 376:	fc06                	sd	ra,56(sp)
 378:	f822                	sd	s0,48(sp)
 37a:	f426                	sd	s1,40(sp)
 37c:	0080                	addi	s0,sp,64
 37e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 380:	c299                	beqz	a3,386 <printint+0x12>
 382:	0805c963          	bltz	a1,414 <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 386:	2581                	sext.w	a1,a1
  neg = 0;
 388:	4881                	li	a7,0
 38a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 38e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 390:	2601                	sext.w	a2,a2
 392:	00000517          	auipc	a0,0x0
 396:	4f650513          	addi	a0,a0,1270 # 888 <digits>
 39a:	883a                	mv	a6,a4
 39c:	2705                	addiw	a4,a4,1
 39e:	02c5f7bb          	remuw	a5,a1,a2
 3a2:	1782                	slli	a5,a5,0x20
 3a4:	9381                	srli	a5,a5,0x20
 3a6:	97aa                	add	a5,a5,a0
 3a8:	0007c783          	lbu	a5,0(a5)
 3ac:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3b0:	0005879b          	sext.w	a5,a1
 3b4:	02c5d5bb          	divuw	a1,a1,a2
 3b8:	0685                	addi	a3,a3,1
 3ba:	fec7f0e3          	bgeu	a5,a2,39a <printint+0x26>
  if(neg)
 3be:	00088c63          	beqz	a7,3d6 <printint+0x62>
    buf[i++] = '-';
 3c2:	fd070793          	addi	a5,a4,-48
 3c6:	00878733          	add	a4,a5,s0
 3ca:	02d00793          	li	a5,45
 3ce:	fef70823          	sb	a5,-16(a4)
 3d2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3d6:	02e05a63          	blez	a4,40a <printint+0x96>
 3da:	f04a                	sd	s2,32(sp)
 3dc:	ec4e                	sd	s3,24(sp)
 3de:	fc040793          	addi	a5,s0,-64
 3e2:	00e78933          	add	s2,a5,a4
 3e6:	fff78993          	addi	s3,a5,-1
 3ea:	99ba                	add	s3,s3,a4
 3ec:	377d                	addiw	a4,a4,-1
 3ee:	1702                	slli	a4,a4,0x20
 3f0:	9301                	srli	a4,a4,0x20
 3f2:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 3f6:	fff94583          	lbu	a1,-1(s2)
 3fa:	8526                	mv	a0,s1
 3fc:	f5bff0ef          	jal	356 <putc>
  while(--i >= 0)
 400:	197d                	addi	s2,s2,-1
 402:	ff391ae3          	bne	s2,s3,3f6 <printint+0x82>
 406:	7902                	ld	s2,32(sp)
 408:	69e2                	ld	s3,24(sp)
}
 40a:	70e2                	ld	ra,56(sp)
 40c:	7442                	ld	s0,48(sp)
 40e:	74a2                	ld	s1,40(sp)
 410:	6121                	addi	sp,sp,64
 412:	8082                	ret
    x = -xx;
 414:	40b005bb          	negw	a1,a1
    neg = 1;
 418:	4885                	li	a7,1
    x = -xx;
 41a:	bf85                	j	38a <printint+0x16>

000000000000041c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 41c:	711d                	addi	sp,sp,-96
 41e:	ec86                	sd	ra,88(sp)
 420:	e8a2                	sd	s0,80(sp)
 422:	e0ca                	sd	s2,64(sp)
 424:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 426:	0005c903          	lbu	s2,0(a1)
 42a:	26090863          	beqz	s2,69a <vprintf+0x27e>
 42e:	e4a6                	sd	s1,72(sp)
 430:	fc4e                	sd	s3,56(sp)
 432:	f852                	sd	s4,48(sp)
 434:	f456                	sd	s5,40(sp)
 436:	f05a                	sd	s6,32(sp)
 438:	ec5e                	sd	s7,24(sp)
 43a:	e862                	sd	s8,16(sp)
 43c:	e466                	sd	s9,8(sp)
 43e:	8b2a                	mv	s6,a0
 440:	8a2e                	mv	s4,a1
 442:	8bb2                	mv	s7,a2
  state = 0;
 444:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 446:	4481                	li	s1,0
 448:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 44a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 44e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 452:	06c00c93          	li	s9,108
 456:	a005                	j	476 <vprintf+0x5a>
        putc(fd, c0);
 458:	85ca                	mv	a1,s2
 45a:	855a                	mv	a0,s6
 45c:	efbff0ef          	jal	356 <putc>
 460:	a019                	j	466 <vprintf+0x4a>
    } else if(state == '%'){
 462:	03598263          	beq	s3,s5,486 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 466:	2485                	addiw	s1,s1,1
 468:	8726                	mv	a4,s1
 46a:	009a07b3          	add	a5,s4,s1
 46e:	0007c903          	lbu	s2,0(a5)
 472:	20090c63          	beqz	s2,68a <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 476:	0009079b          	sext.w	a5,s2
    if(state == 0){
 47a:	fe0994e3          	bnez	s3,462 <vprintf+0x46>
      if(c0 == '%'){
 47e:	fd579de3          	bne	a5,s5,458 <vprintf+0x3c>
        state = '%';
 482:	89be                	mv	s3,a5
 484:	b7cd                	j	466 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 486:	00ea06b3          	add	a3,s4,a4
 48a:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 48e:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 490:	c681                	beqz	a3,498 <vprintf+0x7c>
 492:	9752                	add	a4,a4,s4
 494:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 498:	03878f63          	beq	a5,s8,4d6 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 49c:	05978963          	beq	a5,s9,4ee <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4a0:	07500713          	li	a4,117
 4a4:	0ee78363          	beq	a5,a4,58a <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 4a8:	07800713          	li	a4,120
 4ac:	12e78563          	beq	a5,a4,5d6 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 4b0:	07000713          	li	a4,112
 4b4:	14e78a63          	beq	a5,a4,608 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 4b8:	07300713          	li	a4,115
 4bc:	18e78a63          	beq	a5,a4,650 <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 4c0:	02500713          	li	a4,37
 4c4:	04e79563          	bne	a5,a4,50e <vprintf+0xf2>
        putc(fd, '%');
 4c8:	02500593          	li	a1,37
 4cc:	855a                	mv	a0,s6
 4ce:	e89ff0ef          	jal	356 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 4d2:	4981                	li	s3,0
 4d4:	bf49                	j	466 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 4d6:	008b8913          	addi	s2,s7,8
 4da:	4685                	li	a3,1
 4dc:	4629                	li	a2,10
 4de:	000ba583          	lw	a1,0(s7)
 4e2:	855a                	mv	a0,s6
 4e4:	e91ff0ef          	jal	374 <printint>
 4e8:	8bca                	mv	s7,s2
      state = 0;
 4ea:	4981                	li	s3,0
 4ec:	bfad                	j	466 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 4ee:	06400793          	li	a5,100
 4f2:	02f68963          	beq	a3,a5,524 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 4f6:	06c00793          	li	a5,108
 4fa:	04f68263          	beq	a3,a5,53e <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 4fe:	07500793          	li	a5,117
 502:	0af68063          	beq	a3,a5,5a2 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 506:	07800793          	li	a5,120
 50a:	0ef68263          	beq	a3,a5,5ee <vprintf+0x1d2>
        putc(fd, '%');
 50e:	02500593          	li	a1,37
 512:	855a                	mv	a0,s6
 514:	e43ff0ef          	jal	356 <putc>
        putc(fd, c0);
 518:	85ca                	mv	a1,s2
 51a:	855a                	mv	a0,s6
 51c:	e3bff0ef          	jal	356 <putc>
      state = 0;
 520:	4981                	li	s3,0
 522:	b791                	j	466 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 524:	008b8913          	addi	s2,s7,8
 528:	4685                	li	a3,1
 52a:	4629                	li	a2,10
 52c:	000ba583          	lw	a1,0(s7)
 530:	855a                	mv	a0,s6
 532:	e43ff0ef          	jal	374 <printint>
        i += 1;
 536:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 538:	8bca                	mv	s7,s2
      state = 0;
 53a:	4981                	li	s3,0
        i += 1;
 53c:	b72d                	j	466 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 53e:	06400793          	li	a5,100
 542:	02f60763          	beq	a2,a5,570 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 546:	07500793          	li	a5,117
 54a:	06f60963          	beq	a2,a5,5bc <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 54e:	07800793          	li	a5,120
 552:	faf61ee3          	bne	a2,a5,50e <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 556:	008b8913          	addi	s2,s7,8
 55a:	4681                	li	a3,0
 55c:	4641                	li	a2,16
 55e:	000ba583          	lw	a1,0(s7)
 562:	855a                	mv	a0,s6
 564:	e11ff0ef          	jal	374 <printint>
        i += 2;
 568:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 56a:	8bca                	mv	s7,s2
      state = 0;
 56c:	4981                	li	s3,0
        i += 2;
 56e:	bde5                	j	466 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 570:	008b8913          	addi	s2,s7,8
 574:	4685                	li	a3,1
 576:	4629                	li	a2,10
 578:	000ba583          	lw	a1,0(s7)
 57c:	855a                	mv	a0,s6
 57e:	df7ff0ef          	jal	374 <printint>
        i += 2;
 582:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 584:	8bca                	mv	s7,s2
      state = 0;
 586:	4981                	li	s3,0
        i += 2;
 588:	bdf9                	j	466 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 58a:	008b8913          	addi	s2,s7,8
 58e:	4681                	li	a3,0
 590:	4629                	li	a2,10
 592:	000ba583          	lw	a1,0(s7)
 596:	855a                	mv	a0,s6
 598:	dddff0ef          	jal	374 <printint>
 59c:	8bca                	mv	s7,s2
      state = 0;
 59e:	4981                	li	s3,0
 5a0:	b5d9                	j	466 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5a2:	008b8913          	addi	s2,s7,8
 5a6:	4681                	li	a3,0
 5a8:	4629                	li	a2,10
 5aa:	000ba583          	lw	a1,0(s7)
 5ae:	855a                	mv	a0,s6
 5b0:	dc5ff0ef          	jal	374 <printint>
        i += 1;
 5b4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5b6:	8bca                	mv	s7,s2
      state = 0;
 5b8:	4981                	li	s3,0
        i += 1;
 5ba:	b575                	j	466 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5bc:	008b8913          	addi	s2,s7,8
 5c0:	4681                	li	a3,0
 5c2:	4629                	li	a2,10
 5c4:	000ba583          	lw	a1,0(s7)
 5c8:	855a                	mv	a0,s6
 5ca:	dabff0ef          	jal	374 <printint>
        i += 2;
 5ce:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5d0:	8bca                	mv	s7,s2
      state = 0;
 5d2:	4981                	li	s3,0
        i += 2;
 5d4:	bd49                	j	466 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 5d6:	008b8913          	addi	s2,s7,8
 5da:	4681                	li	a3,0
 5dc:	4641                	li	a2,16
 5de:	000ba583          	lw	a1,0(s7)
 5e2:	855a                	mv	a0,s6
 5e4:	d91ff0ef          	jal	374 <printint>
 5e8:	8bca                	mv	s7,s2
      state = 0;
 5ea:	4981                	li	s3,0
 5ec:	bdad                	j	466 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5ee:	008b8913          	addi	s2,s7,8
 5f2:	4681                	li	a3,0
 5f4:	4641                	li	a2,16
 5f6:	000ba583          	lw	a1,0(s7)
 5fa:	855a                	mv	a0,s6
 5fc:	d79ff0ef          	jal	374 <printint>
        i += 1;
 600:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 602:	8bca                	mv	s7,s2
      state = 0;
 604:	4981                	li	s3,0
        i += 1;
 606:	b585                	j	466 <vprintf+0x4a>
 608:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 60a:	008b8d13          	addi	s10,s7,8
 60e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 612:	03000593          	li	a1,48
 616:	855a                	mv	a0,s6
 618:	d3fff0ef          	jal	356 <putc>
  putc(fd, 'x');
 61c:	07800593          	li	a1,120
 620:	855a                	mv	a0,s6
 622:	d35ff0ef          	jal	356 <putc>
 626:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 628:	00000b97          	auipc	s7,0x0
 62c:	260b8b93          	addi	s7,s7,608 # 888 <digits>
 630:	03c9d793          	srli	a5,s3,0x3c
 634:	97de                	add	a5,a5,s7
 636:	0007c583          	lbu	a1,0(a5)
 63a:	855a                	mv	a0,s6
 63c:	d1bff0ef          	jal	356 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 640:	0992                	slli	s3,s3,0x4
 642:	397d                	addiw	s2,s2,-1
 644:	fe0916e3          	bnez	s2,630 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 648:	8bea                	mv	s7,s10
      state = 0;
 64a:	4981                	li	s3,0
 64c:	6d02                	ld	s10,0(sp)
 64e:	bd21                	j	466 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 650:	008b8993          	addi	s3,s7,8
 654:	000bb903          	ld	s2,0(s7)
 658:	00090f63          	beqz	s2,676 <vprintf+0x25a>
        for(; *s; s++)
 65c:	00094583          	lbu	a1,0(s2)
 660:	c195                	beqz	a1,684 <vprintf+0x268>
          putc(fd, *s);
 662:	855a                	mv	a0,s6
 664:	cf3ff0ef          	jal	356 <putc>
        for(; *s; s++)
 668:	0905                	addi	s2,s2,1
 66a:	00094583          	lbu	a1,0(s2)
 66e:	f9f5                	bnez	a1,662 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 670:	8bce                	mv	s7,s3
      state = 0;
 672:	4981                	li	s3,0
 674:	bbcd                	j	466 <vprintf+0x4a>
          s = "(null)";
 676:	00000917          	auipc	s2,0x0
 67a:	20a90913          	addi	s2,s2,522 # 880 <malloc+0xfe>
        for(; *s; s++)
 67e:	02800593          	li	a1,40
 682:	b7c5                	j	662 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 684:	8bce                	mv	s7,s3
      state = 0;
 686:	4981                	li	s3,0
 688:	bbf9                	j	466 <vprintf+0x4a>
 68a:	64a6                	ld	s1,72(sp)
 68c:	79e2                	ld	s3,56(sp)
 68e:	7a42                	ld	s4,48(sp)
 690:	7aa2                	ld	s5,40(sp)
 692:	7b02                	ld	s6,32(sp)
 694:	6be2                	ld	s7,24(sp)
 696:	6c42                	ld	s8,16(sp)
 698:	6ca2                	ld	s9,8(sp)
    }
  }
}
 69a:	60e6                	ld	ra,88(sp)
 69c:	6446                	ld	s0,80(sp)
 69e:	6906                	ld	s2,64(sp)
 6a0:	6125                	addi	sp,sp,96
 6a2:	8082                	ret

00000000000006a4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6a4:	715d                	addi	sp,sp,-80
 6a6:	ec06                	sd	ra,24(sp)
 6a8:	e822                	sd	s0,16(sp)
 6aa:	1000                	addi	s0,sp,32
 6ac:	e010                	sd	a2,0(s0)
 6ae:	e414                	sd	a3,8(s0)
 6b0:	e818                	sd	a4,16(s0)
 6b2:	ec1c                	sd	a5,24(s0)
 6b4:	03043023          	sd	a6,32(s0)
 6b8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6bc:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6c0:	8622                	mv	a2,s0
 6c2:	d5bff0ef          	jal	41c <vprintf>
}
 6c6:	60e2                	ld	ra,24(sp)
 6c8:	6442                	ld	s0,16(sp)
 6ca:	6161                	addi	sp,sp,80
 6cc:	8082                	ret

00000000000006ce <printf>:

void
printf(const char *fmt, ...)
{
 6ce:	711d                	addi	sp,sp,-96
 6d0:	ec06                	sd	ra,24(sp)
 6d2:	e822                	sd	s0,16(sp)
 6d4:	1000                	addi	s0,sp,32
 6d6:	e40c                	sd	a1,8(s0)
 6d8:	e810                	sd	a2,16(s0)
 6da:	ec14                	sd	a3,24(s0)
 6dc:	f018                	sd	a4,32(s0)
 6de:	f41c                	sd	a5,40(s0)
 6e0:	03043823          	sd	a6,48(s0)
 6e4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6e8:	00840613          	addi	a2,s0,8
 6ec:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6f0:	85aa                	mv	a1,a0
 6f2:	4505                	li	a0,1
 6f4:	d29ff0ef          	jal	41c <vprintf>
}
 6f8:	60e2                	ld	ra,24(sp)
 6fa:	6442                	ld	s0,16(sp)
 6fc:	6125                	addi	sp,sp,96
 6fe:	8082                	ret

0000000000000700 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 700:	1141                	addi	sp,sp,-16
 702:	e422                	sd	s0,8(sp)
 704:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 706:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 70a:	00001797          	auipc	a5,0x1
 70e:	8f67b783          	ld	a5,-1802(a5) # 1000 <freep>
 712:	a02d                	j	73c <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 714:	4618                	lw	a4,8(a2)
 716:	9f2d                	addw	a4,a4,a1
 718:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 71c:	6398                	ld	a4,0(a5)
 71e:	6310                	ld	a2,0(a4)
 720:	a83d                	j	75e <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 722:	ff852703          	lw	a4,-8(a0)
 726:	9f31                	addw	a4,a4,a2
 728:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 72a:	ff053683          	ld	a3,-16(a0)
 72e:	a091                	j	772 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 730:	6398                	ld	a4,0(a5)
 732:	00e7e463          	bltu	a5,a4,73a <free+0x3a>
 736:	00e6ea63          	bltu	a3,a4,74a <free+0x4a>
{
 73a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 73c:	fed7fae3          	bgeu	a5,a3,730 <free+0x30>
 740:	6398                	ld	a4,0(a5)
 742:	00e6e463          	bltu	a3,a4,74a <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 746:	fee7eae3          	bltu	a5,a4,73a <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 74a:	ff852583          	lw	a1,-8(a0)
 74e:	6390                	ld	a2,0(a5)
 750:	02059813          	slli	a6,a1,0x20
 754:	01c85713          	srli	a4,a6,0x1c
 758:	9736                	add	a4,a4,a3
 75a:	fae60de3          	beq	a2,a4,714 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 75e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 762:	4790                	lw	a2,8(a5)
 764:	02061593          	slli	a1,a2,0x20
 768:	01c5d713          	srli	a4,a1,0x1c
 76c:	973e                	add	a4,a4,a5
 76e:	fae68ae3          	beq	a3,a4,722 <free+0x22>
    p->s.ptr = bp->s.ptr;
 772:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 774:	00001717          	auipc	a4,0x1
 778:	88f73623          	sd	a5,-1908(a4) # 1000 <freep>
}
 77c:	6422                	ld	s0,8(sp)
 77e:	0141                	addi	sp,sp,16
 780:	8082                	ret

0000000000000782 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 782:	7139                	addi	sp,sp,-64
 784:	fc06                	sd	ra,56(sp)
 786:	f822                	sd	s0,48(sp)
 788:	f426                	sd	s1,40(sp)
 78a:	ec4e                	sd	s3,24(sp)
 78c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 78e:	02051493          	slli	s1,a0,0x20
 792:	9081                	srli	s1,s1,0x20
 794:	04bd                	addi	s1,s1,15
 796:	8091                	srli	s1,s1,0x4
 798:	0014899b          	addiw	s3,s1,1
 79c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 79e:	00001517          	auipc	a0,0x1
 7a2:	86253503          	ld	a0,-1950(a0) # 1000 <freep>
 7a6:	c915                	beqz	a0,7da <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7a8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7aa:	4798                	lw	a4,8(a5)
 7ac:	08977a63          	bgeu	a4,s1,840 <malloc+0xbe>
 7b0:	f04a                	sd	s2,32(sp)
 7b2:	e852                	sd	s4,16(sp)
 7b4:	e456                	sd	s5,8(sp)
 7b6:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 7b8:	8a4e                	mv	s4,s3
 7ba:	0009871b          	sext.w	a4,s3
 7be:	6685                	lui	a3,0x1
 7c0:	00d77363          	bgeu	a4,a3,7c6 <malloc+0x44>
 7c4:	6a05                	lui	s4,0x1
 7c6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7ca:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7ce:	00001917          	auipc	s2,0x1
 7d2:	83290913          	addi	s2,s2,-1998 # 1000 <freep>
  if(p == (char*)-1)
 7d6:	5afd                	li	s5,-1
 7d8:	a081                	j	818 <malloc+0x96>
 7da:	f04a                	sd	s2,32(sp)
 7dc:	e852                	sd	s4,16(sp)
 7de:	e456                	sd	s5,8(sp)
 7e0:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 7e2:	00001797          	auipc	a5,0x1
 7e6:	82e78793          	addi	a5,a5,-2002 # 1010 <base>
 7ea:	00001717          	auipc	a4,0x1
 7ee:	80f73b23          	sd	a5,-2026(a4) # 1000 <freep>
 7f2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7f4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7f8:	b7c1                	j	7b8 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 7fa:	6398                	ld	a4,0(a5)
 7fc:	e118                	sd	a4,0(a0)
 7fe:	a8a9                	j	858 <malloc+0xd6>
  hp->s.size = nu;
 800:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 804:	0541                	addi	a0,a0,16
 806:	efbff0ef          	jal	700 <free>
  return freep;
 80a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 80e:	c12d                	beqz	a0,870 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 810:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 812:	4798                	lw	a4,8(a5)
 814:	02977263          	bgeu	a4,s1,838 <malloc+0xb6>
    if(p == freep)
 818:	00093703          	ld	a4,0(s2)
 81c:	853e                	mv	a0,a5
 81e:	fef719e3          	bne	a4,a5,810 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 822:	8552                	mv	a0,s4
 824:	b03ff0ef          	jal	326 <sbrk>
  if(p == (char*)-1)
 828:	fd551ce3          	bne	a0,s5,800 <malloc+0x7e>
        return 0;
 82c:	4501                	li	a0,0
 82e:	7902                	ld	s2,32(sp)
 830:	6a42                	ld	s4,16(sp)
 832:	6aa2                	ld	s5,8(sp)
 834:	6b02                	ld	s6,0(sp)
 836:	a03d                	j	864 <malloc+0xe2>
 838:	7902                	ld	s2,32(sp)
 83a:	6a42                	ld	s4,16(sp)
 83c:	6aa2                	ld	s5,8(sp)
 83e:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 840:	fae48de3          	beq	s1,a4,7fa <malloc+0x78>
        p->s.size -= nunits;
 844:	4137073b          	subw	a4,a4,s3
 848:	c798                	sw	a4,8(a5)
        p += p->s.size;
 84a:	02071693          	slli	a3,a4,0x20
 84e:	01c6d713          	srli	a4,a3,0x1c
 852:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 854:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 858:	00000717          	auipc	a4,0x0
 85c:	7aa73423          	sd	a0,1960(a4) # 1000 <freep>
      return (void*)(p + 1);
 860:	01078513          	addi	a0,a5,16
  }
}
 864:	70e2                	ld	ra,56(sp)
 866:	7442                	ld	s0,48(sp)
 868:	74a2                	ld	s1,40(sp)
 86a:	69e2                	ld	s3,24(sp)
 86c:	6121                	addi	sp,sp,64
 86e:	8082                	ret
 870:	7902                	ld	s2,32(sp)
 872:	6a42                	ld	s4,16(sp)
 874:	6aa2                	ld	s5,8(sp)
 876:	6b02                	ld	s6,0(sp)
 878:	b7f5                	j	864 <malloc+0xe2>
